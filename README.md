# Raspberry Pi nio Install Script
A script for installing nio onto a Raspberry Pi

This script can be run from a Raspberry Pi to create and run a new nio instance. The script will update all installed packages onthe Pi, install Python 3, pip, the nio binary from a `.whl` file. This script will also create the nio project on the Pi and set it up as a service that can be easiy stopped, started, and restarted with the command:
```
sudo service [project name] [start/stop/restart]
```

A nio binary must be copied onto the Pi for this script to install.
To get your binary onto the Pi, run the following:
```
scp nio_lite-20XXXXXX-py3-none-any.whl pi@XXX.XXX.XXX.XXX:~
```

### How To Run
* One Line Install Command:
```
bash -c "$(curl -s https://raw.githubusercontent.com/niolabs/nio_install/master/rpi_nio_install.sh)"
```
* Download and Install:
  * Download this script onto the Pi and give it executbable permission:
  ```
  chmod +x rpi_nio_install.sh
  ```

  * Finally run the install script:
  ```
  ./rpi_nio_install.sh
  ```
