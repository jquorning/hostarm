# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

HostARM is an Ada web application (built on AWS — Ada Web Server) that locally
hosts the Ada Reference Manual 2012, Ada Reference Manual 2022, and the
Annotated Ada Reference Manual 202Y. It serves the manuals from static HTML
with added features: fast local search (Tipuesearch), keypress navigation,
shortened URLs, and optional UI modernization/stripped nav bars. It runs as a
standalone daemon listening on port 2778.

Distributed as an [Alire](https://alire.ada.dev) crate (`alr install hostarm`).

## Build / run / test

This project uses Alire (`alr`), not raw `gprbuild`, for day-to-day commands:

```sh
alr build              # build the hostarm executable into bin/
alr run                # build and run the daemon
alr run -- --port=8080 # run on a custom port
alr run -- --help      # CLI usage
alr test                       # run the test suite (see tests/)
alr test -- --filter=NAME     # run a subset (alr-test / gnattest driven, see tests/hostarm_tests.gpr)
```

The executable expects its working directory to contain `share/hostarm/`
(ARM HTML sources, `www/` templates, `assets/`) — see the header comment in
`source/hostarm_configuration.ads`. When run via `alr run`/installed via Alire,
the `Resources` crate locates this directory automatically
(`source/hostarm.adb` calls `Resources.Resource_Path` and `Set_Directory`).

Manual invocation as a background daemon (per README):

```sh
nohup hostarm </dev/null >/dev/null 2>&1 &
```

There is no separate lint step beyond compiler warnings; `hostarm.gpr` builds
with `-gnatwa` (all warnings) and `-gnatyy-s` (default style checks +
specific casing), so style violations show up as build warnings/errors.

## Architecture

**Entry point**: `source/hostarm.adb` — parses `--version`/`--help`/`--port=`,
locates the resource directory, builds the Tipuesearch content databases for
all three manual versions (`HostARM_Tipue.Build_Content`), then starts and
waits on the AWS server (`HostARM_Server.Start` / `.Wait` / `.Stop`).

**Request flow** goes through `source/hostarm_server.adb`, which registers a
URI dispatch table (`Register_Dispatcher`) mapping paths/regexes to service
functions:
- `/`, `/home` → `Service_Home` (reads/writes the user's `State_Type` via a
  cookie; POST updates preferences, GET reads them)
- `/search` → `Service_Search`
- `/RM-*`, `/AA-*` → `Service_ARM` (serves manual pages, rewrites navigation)
- `/assets/tipuesearch/*` → `Service_Tipue` (search JS/CSS/content)
- `/assets/css/*.css`, `*.jpg`, `*.png`, `*.gif` → static asset services
- `*.html` → `Service_Redirect` (redirects to the URL with `.html` stripped —
  this is the "shorter URL" feature)
- catch-all → `Service_Default` (redirects to `/`)

Every manual page passes through a pipeline before being returned: load the
static file (`HostARM_Tools.Load_File`) → parse/rewrite navigation
(`HostARM_Navigate`) → inject keypress navigation JS → apply
"pyning" (`HostARM_Pyning.Pyne` — strips/injects nav bars, banner, sponsor
blocks, doctype rewriting, CSS link injection) based on the user's cookie
state.

**Per-user preferences** (`HostARM_Configuration.State_Type`): which manual
version, whether to show Pyne banner/top-nav/bottom-nav/sponsor, and whether
to "modernize" the look. Persisted client-side as cookies
(`HostARM_Cookie.Get_Or_Default` / `.Set`), read via CGI's `Cookie_Value` /
`Set_Cookie` (see below). If cookies are missing/invalid, the server falls
back to `Config.Default_State`.

**Key source modules** (`source/`):
- `hostarm_configuration.ads/.adb` — global config, `ARM_Version` enum,
  per-manual base paths/URIs, `State_Type` record and its default
- `hostarm_server.ads/.adb` — AWS server setup, dispatch table, all
  `Service_*` request handlers
- `hostarm_cookie.ads/.adb` — reads/writes `State_Type` to/from HTTP cookies
- `hostarm_navigate.ads/.adb` — parses manual pages' existing nav links
  (`Nav_Info`) and injects keyboard-shortcut navigation JS
- `hostarm_pyning.ads/.adb` — "pynes" a page: doctype fixup, CSS link
  rewriting, nav bar stripping/insertion, per the user's `State_Type`
- `hostarm_modern.ads/.adb` — builds/injects the modernized navigation `DIV`
- `hostarm_tipue.ads/.adb` — builds and serves the Tipuesearch content
  database per manual version
- `hostarm_tools.ads/.adb` — shared string/file helpers (`UString` =
  `Unbounded_String`, `Load_File`, `Replace`, `Strip_Slash`, `Tail_Is`)

**`adacgi/cgi.ads`/`.adb`** — a vendored copy of David A. Wheeler's AdaCGI
library (LGPL), used only for its RFC 3875 cookie handling
(`Cookie_Value`, `Set_Cookie`). `source/hostarm_rfc3875.ads` is a one-line
renaming (`package HostARM_RFC3875 renames CGI;`) so the rest of the codebase
never references `CGI` directly. It has been reformatted to the project's
GNAT style and cleaned of compiler warnings (see below), but keep its public
API and behavior untouched — it still tracks upstream AdaCGI, so avoid
functional changes beyond bug fixes.

**`config/`** — Alire-generated `hostarm_config.gpr`/`.ads`/`.h` (crate
name/version, build profile, dependency `with`s). Regenerated by `alr`; don't
hand-edit expecting changes to persist.

**`tests/`** — a separate Alire crate (`hostarm_tests`) pinned to the parent
crate via a local path, built with its own `hostarm_tests.gpr`. Test sources
live in `tests/src/`; `tests/common/hostarm_tests.ads` is the shared test
package spec. Run via `alr test` from the repo root.

**`ARM/`** — the raw HTML sources for the three manual versions
(`Ada_2012/`, `Ada_2022/`, `Ada_202Y/`), copied into `share/hostarm/ARM` for
runtime serving. **`share/hostarm/`** is the actual runtime resource tree
(ARM HTML + `assets/` + `www/` templates) that ships with the Alire package
and is what `HostARM_Configuration.Set_Directory` points at.

**`attic/`** — leftover Jekyll-based GitHub Pages site (old project home
page), unrelated to the Ada application build.

## Style conventions

- Package naming: `HostARM_<Area>` (note the mixed-case "HostARM"); file
  names are all-lowercase (`hostarm_server.adb`), consistent with GNAT
  default file naming.
- `UString` is the conventional local subtype alias for
  `Ada.Strings.Unbounded.Unbounded_String` throughout — reuse it rather than
  writing out the full type.
- Local package renames at the top of specs/bodies (e.g.
  `package Config renames HostARM_Configuration;`) are the norm — follow this
  pattern instead of fully qualifying names everywhere.
- Compiler runs with `-gnatyy-s` style checks and `-gnatwa`; keep new code
  warning- and style-clean rather than suppressing checks.
- Full-line (whole-line) comments require *two* spaces after `--`
  (`--  Like this`); trailing end-of-line comments after code need only one.
  This is `-gnatyc`/`-gnatyt` and is easy to miss since it's not obvious from
  reading the GNAT style-check option list.
- `gprbuild`/`alr build` treats up-to-date objects as cached and won't
  re-report warnings for a file that hasn't changed — `touch` the file (or
  `alr build --force`) before rebuilding if you're iterating on
  warnings/style fixes for a specific unit.
- To auto-format a file to the project's style, run `gnatpp` inside the
  Alire environment so it can see dependency project files (aws, xmlada,
  gnatcoll):
  ```sh
  alr exec -- gnatpp -P hostarm.gpr --indentation=3 path/to/file.adb
  ```
  `gnatpp` fixes indentation/spacing/casing but not semantic warnings
  (unused variables, missing `end <name>` labels, "could be constant",
  obsolescent renamings) — those still need manual fixes.
