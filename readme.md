# UltraKey

## Note from the Creator

As of **1/13/2026**, the remote host for UltraKey has been suspended.

From memory, the UI and authentication layers are somewhat coupled to the web service, but this should be easy to decouple. You can likely point the UI to a different service by modifying a small set of variables in a shared header or config file.

## Core emulator
The core emulator can be extracted and will be perfectly functional without the UI.
The emulator had some major changes from 1.1.x to 1.2.x including:

- Increased polling rate
- LUA Scripting interface changes
- Thread contention and high core usage fixes
- Internal task scheduler & ISR added
- Obfuscator removed

---

## Version 1.1.x

This is the original UltraKey proof of concept. It converts mouse and keyboard input into controller input using:

- ViGEmBus  
- Oblitum Interception  

### Build Requirements
- [GCC compiler](https://www.msys2.org/)
- [py2exe](https://www.py2exe.org/)
- [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.5)

### Authentication
To enable frontend authentication, insert your Discord API keys into:


> ⚠️ The software will **not function** without valid API keys.

### Project Structure
- **Backend:** `1.1.x/ultrakey_emu`  
- **Frontend:** `1.1.x/ultrakey_ui`  

### Packaging & Obfuscation
This version includes a basic binary obfuscator/wrapper:

- The build process packages and encrypts the executable.
- `ultrakey_run` decrypts, unpacks, and executes the binary in the background at runtime.

---

## Version 1.2.x — (Non-Functional, Flutter Port)

This is a non-functional rewrite of UltraKey intended for consumer use. The UI was rebuilt using **Flutter SDK** targeting Windows.

### Build Requirements
- [GCC compiler](https://www.msys2.org/)
- [Flutter SDK](https://docs.flutter.dev/install)
- [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/)

### Authentication
To enable frontend authentication, insert your Discord API keys into:

> ⚠️ The software will **not function** without valid API keys.

### Project Structure
- **Backend:** `1.2.x/ultrakey_emu`  
- **Frontend:** `1.2.x/ultrakey_ui`  

> Note: This version follows a similar architecture to 1.1.x, including a packer/runner used to hide the executable while running.

---

## Auth Server

The authentication server is implemented in:
`server.py`
It must be hosted remotely for authentication to function.
