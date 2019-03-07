# Raspberry Pi nio Install Script
A script for installing nio onto a Raspberry Pi

This script can be run from a Raspberry Pi to create and run a new nio instance. The script will update all installed packages onthe Pi, install Python 3, pip, the nio binary from a `.whl` file. During installation you will be prompted to enter several values:

* **Enter a name for your project:** A unique name by which the project and associated [systemd](https://manpages.debian.org/stretch/systemd/systemd.service.5.en.html) service will be referenced.
* **Enter your Pubkeeper hostname:** Pubkeeper server to use for this project. If left empty you must modify `nio.conf` in the project root with your desired configuration.
* **Enter your Pubkeeper token:** Authorization token for pubkeeper server.

A nio binary must be copied onto the Pi for this script to install. Download your binary [from here](https://account.n.io/binaries/download), and then run the following command to copy it onto your Pi.

**IMPORTANT:** Windows users skip this step, and [proceed here](#windows).
```
scp nio_full-<version>-py3-none-any.whl pi@<hostname or IP>:~
```

### <a name="windows"></a>Windows Users
You will need to download and use a program called [PuTTY](https://www.putty.org/) which is the standard tool for managing SSH connections, and associated copy operations, from Windows. Once PuTTY has been installed, open a command prompt and run the following commands. Note that this assumes default download and installation directories.
```
cd C:\Program Files (x86)\PuTTY\
pscp -scp %USERPROFILE%\Downloads\nio_full-<version>-py3-none-any.whl pi@<hostname or IP>:~
```

To open an SSH connection start PuTTY from your Start Menu, enter the hostname or IP address of your Pi, and click Open. A new terminal window will open, and prompt for the login for your Raspberry Pi.

### How To Run
Once the Binary has been copied onto your Raspberry Pi, open an SSH session to the Pi, log in, and follow these steps to install nio:
* One Line Install Command (recommended):
```
bash -c "$(curl -s https://raw.githubusercontent.com/niolabs/nio_install/master/rpi_nio_install.sh)" && source ~/.bashrc
```
* or, Download and Run Manually:
  * Download this script onto the Pi and give it executbable permission:
  ```
  wget https://raw.githubusercontent.com/niolabs/nio_install/master/rpi_nio_install.sh
  chmod +x rpi_nio_install.sh
  ```
  * Execute the install script:
  ```
  ./rpi_nio_install.sh
  source ~/.bashrc
  ```

If you haven't yet configured `git`, you may see a warning like `*** Please tell me who you are...`. This is safe to ignore.

### Start and Stop the Instance
When the script finishes, a `systemd` service will have been created and started your new nio instance. This instance will start automatically when the Pi is turned on. You can control this instance with these commands:
```
sudo systemctl <start|stop|restart|enable|disable> <project name>
```
