
# HostARM

HostARM is a local hosting of
- Ada Reference Manual 2012
- Ada Reference Manual 2022
- Annotated Ada Reference Manual 202Y (Draft 3)

HostARM focuses on user friendliness and more modern look of the manuals.

Benefits
- Shorter URL: Remove two levels of the URL and no html ending
- Optional stripping of navigation bars
- Keypress navigation
- Local search not dependant on external hosts
- Alphabet navigation bar in index

## Installation

HostARM is distributed as an [Alire](https://alire.ada.dev) crate.

```sh
$ alr install hostarm
```

## Invocation

```sh
$ hostarm &
```
This will start HostARM as a deamon and the manuals are now accessable on
[localhost](http://localhost:2778/readme).

## Links

[Project website](https://github.com/jquorning/hostarm).

Alire [crate](https://alire.ada.dev/crates/hostarm.html).
