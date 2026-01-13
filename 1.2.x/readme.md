# UltraKey
### Note from creator
I have suspended the remove host for UltraKey as of 1/13/2026.
I do not remember how coupled the UI and auth is to the web service but from memory, you can port a couple variables in a header somewhere in the UI to change services.

### 1.1.x
This is the original proof of concept for UltraKey which uses
VigemBus and Oblitum interception to convert mouse and keyboard to controller.

You need a gcc compiler to build the project along with py-to-exe.

Currently, powershell is being used for the build system but it can be easily ported to shell or any other script type.

Insert your discord API keys into `1.1.x/ultrakey_ui/login.key` to enable authentication for the front end. The software will not work without it.

The source for the backend is under `1.1.x/ultrakey_emu` and the source for the frontend is under `1.1.x/ultrakey_ui`. I have a basic binary obfuscator/wrapper to hide the program which packages and encrypts the project binary in the build folder. ultrakey_run unpacks this binary and executes it in the background.

### 1.2.x
This is the non-functional consumer facing rewrite for UltraKey. This was done using FlutterSDK compiled for windows.

You need a gcc compiler and Flutter SDK to build the project.

Currently, powershell is being used for the build system but it can be easily ported to shell or any other script type.

Insert your discord API keys into `1.2.x/ultrakey_ui/license.key`to enable authentication for the front end. The software will not work without it.

The source for the backend is under `1.2.x/ultrakey_emu` and the front end is under `1.1.x/ultrakey_ui`. Similar to 1.1.x this version contains a packer/runner to hide the program while running.

### Auth Server
The auth server is under server.py and needs to be hosted remotely.