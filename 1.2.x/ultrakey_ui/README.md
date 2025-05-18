# ultrakey_ui

<!-- package into runner (with packer sig) -->
re-add configs
ship it


UI:
- UI asthetic rework
- automatic driver installation
    - checks drivers on launch and installs them if necessary
- added advanced stick settings
    - stick smoothing and sensitivity
    - stabilizer controls
    - keepalive controls
- improved sign in and authorization
- enhanced security
- configs are now basic json files
- scripts shared accross all configs
- start/stop controls improved

Emulator:
- full rewrite
- better stick control with smoothing for better compatibility
- higher polling rate
    - 2,000hz output polling (was 600hz)
    - 20,000hz internal polling (was 600hz)
- thread volatility fix (improves consistency accross frame rates)
- better stabilizer and keepalive (less shake)