# ultrakey_ui

- add export config button
    - show a menu with a server ID and a roll ID
        - if server ID and roll ID, sign the config with the roll ID and
        embed it as a signed header, then attach the server ID to the top unsigned
        - if server ID and no roll ID or vice versa, error
        - if no server ID and no roll ID, attach NULL for the server ID and sign it with 0s

- add import config button
    - seach for .ukbundle files on the PC
    - once imported, copy the file into the configs folder and validate
    - on boot, iterate through the signed configs and unsign/validate them into memory
        - throw an in-app popup on error and skip the import
    - also iterate through unsigned configs and load them into the same memory format

- add option to extract source code with a key from imported configs

- add in runtime wrapper that extracts bundles which have been loaded onto github releases
    include:
    - drivers
    - data
    - assets
    - dlls
    - launcher.exe

