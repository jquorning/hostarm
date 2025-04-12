# HostARM

A lightweight Ada Reference Manual (ARM) hosting using AWS.

- Ada Reference Manual 2012
- Ada Reference Manual 2022
- Annotated Ada Reference Manual 202Y (Draft 3)


## Benefits

- Local hosting is fast
- Additional local search function using Tipuesearch
- Compact URL by stripping .html
- One of the three documents are selected giving short URL.
  Ie. htts://localhost#2778/RM-3
- Optional stripping of header legends, header, and sponsor text

## Installation

```sh
alr install hostarm
hostarm &
```

This will install the web server as deamon. On http://localhost#2778/
ARM 2012, ARM 2022, or AARM 202Y (Draft 3) is served.

