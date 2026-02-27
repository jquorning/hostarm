
# HostARM

![Badge](https://img.shields.io/endpoint?url=https://alire.ada.dev/badges/hostarm.json)

HostARM is a local hosting of
- Ada Reference Manual 2012
- Ada Reference Manual 2022
- Annotated Ada Reference Manual 202Y (Draft 5)

HostARM focuses on user friendliness and more modern look of the manuals.

Benefits
- Search not dependant on external hosts
- Keypress navigation
- Shorter URL: Remove two levels of the URL and no html ending
- Optional stripping of navigation bars
- Alphabet navigation bar in index

## Installation

HostARM is distributed as an [Alire](https://alire.ada.dev) crate.

```sh
alr install hostarm
```

## Invocation

```sh
hostarm &
```
This will start HostARM as a daemon and the manuals are now accessible at
[/localhost:2778/](http://localhost:2778/).

## Links

Alire [crate](https://alire.ada.dev/crates/hostarm).

[Project website](https://github.com/jquorning/hostarm).

## Screenshot

![Screenshot](https://repository-images.githubusercontent.com/963019187/b0e8a4ad-44b1-4a60-9282-ee6e2b1a91e4)
