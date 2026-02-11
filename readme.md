# UltraKey

## Note from the Creator

As of **1/13/2026**, the remote host for UltraKey has been suspended.

From memory, the UI and authentication layers are somewhat coupled to the web service, but this should be easy to decouple. You can likely point the UI to a different service by modifying a small set of variables in a shared header or config file.

---

## Version 1.1.x — Original Proof of Concept

This is the original UltraKey proof of concept. It converts mouse and keyboard input into controller input using:

- ViGEmBus  
- Oblitum input interception  

### Build Requirements
- GCC compiler  
- `py-to-exe`  
- PowerShell (used for the current build system, but can be ported to shell or another scripting language)

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

## Version 1.2.x — Consumer-Facing Rewrite (Non-Functional)

This is a non-functional rewrite of UltraKey intended for consumer use. The UI was rebuilt using **Flutter SDK** targeting Windows.

### Build Requirements
- GCC compiler  
- Flutter SDK  
- PowerShell (used for the current build system, but can be ported easily)

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
