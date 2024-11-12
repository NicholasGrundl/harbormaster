# Welcome

This document outlines the first step to setting up a WSL environment

# Steps

1. Enable WSL on Windows:
   - Open PowerShell as Administrator and run:
     ```
     dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
     ```

2. Enable Virtual Machine feature:
   - In the same PowerShell window, run:
     ```
     dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
     ```

3. Restart your computer to complete the WSL installation.

4. Download and install the Linux kernel update package:
   - Download from: https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi
   - Run the downloaded `.msi` file

5. Set WSL 2 as the default version:
   - Open PowerShell and run:
     ```
     wsl --set-default-version 2
     ```

6. Install Ubuntu from the Microsoft Store:
   - Open the Microsoft Store
   - Search for "Ubuntu"
   - Click "Get" to install

7. Launch Ubuntu and set up your user account:
   - Open the Start menu and click on Ubuntu
   - When prompted, create a username and password for your Ubuntu account

8. Update and upgrade Ubuntu packages:
   - In the Ubuntu terminal, run:
     ```
     sudo apt update && sudo apt upgrade -y
     ```

## Verification
- Open a command prompt and run `wsl -l -v`. You should see Ubuntu listed with version 2.
- Open Ubuntu and ensure you can run basic Linux commands.

## Troubleshooting
- If you encounter any issues, refer to the official Microsoft documentation: https://learn.microsoft.com/en-us/windows/wsl/