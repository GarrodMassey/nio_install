read -p "Enter the path of your binary file (ex: nio_lite-20171006-py3-none-any.whl): " binary
read -p "Enter a name for your project: " proj

echo
echo UPDATING INSTALLED PACKAGES
echo ---------------------------
sudo apt-get update -y -q
sudo apt-get dist-upgrade -y -qq
sudo apt-get install vim -y -q
sudo apt-get install --reinstall git -y -q

echo
echo INSTALLING PYTHON 3 AND PIP
echo ---------------------------
sudo apt-get install python3 -y -q
sudo apt-get install python3-pip -y -q
sudo pip3 install -U pip

echo
echo INSTALLING NIO CLI
echo ------------------
sudo pip3 install nio-cli -U

echo
echo LOOKING FOR EXISTING NIO BINARY
echo -------------------------------
nio_location="$(which nio_run)"

if [ $nio_location ]; then
  echo ... FOUND AT $nio_location
else
  echo ... INSTALLING NIO FROM SPECIFIED BINARY
  sudo pip3 install $binary #nio_lite-20171006-py3-none-any.whl
fi

sudo echo \
'[Unit]
Description='$proj'
After=network.target

[Service]
WorkingDirectory=/home/pi/nio/projects/'$proj'
ExecStart='`which niod`'
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
#Restart=on-failure

[Install]
WantedBy=multi-user.target' > $proj.service
sudo mv $proj.service /etc/systemd/system/.

echo
echo CREATING PROJECT
echo ----------------
mkdir -p nio/projects
cd nio/projects/
nio new $proj
cd $proj

echo
echo STARTING SERVICE
echo ----------------
sudo systemctl enable $proj.service
sudo systemctl start $proj.service

echo
echo SERVICE STARTED
echo ---------------
echo 'Success! nio has been successfully installed and an instance is now currently running on this machine.'
