read -p "Enter the version of your nio binary (ex: 20180130): " binary
read -p "Enter a name for your project: " proj

echo
echo UPDATING INSTALLED PACKAGES
echo ---------------------------
sudo apt-get update -y -q
sudo apt-get upgrade -y -qq
sudo apt-get install vim -y -q
sudo apt-get install --reinstall git -y -q

echo
echo INSTALLING PYTHON 3 AND PIP
echo ---------------------------
sudo apt-get install python3 -y -q
sudo apt-get install python3-pip -y -q
sudo pip3 install -U pip

echo
echo LOOKING FOR EXISTING NIO BINARY
echo -------------------------------
nio_location="$(which niod)"

if [ $nio_location ]; then
  echo ... FOUND AT $nio_location
else
  echo ... INSTALLING NIO FROM SPECIFIED BINARY
  sudo pip3 install `find ~ -name "nio_lite-$binary\-py3-none-any.whl" | head -n 1`
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

sudo iw dev wlan0 set power_save off

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
sudo systemctl daemon-reload
sudo systemctl enable $proj.service
sudo systemctl start $proj.service

echo
echo CHECKING STATUS
echo ---------------
if which niod > /dev/null
then
	echo 'Success! nio has been installed in your environment.'
	if ps ax | grep -v grep | grep niod > /dev/null
	then
		echo 'Your instance has started successfully'
	else
		echo 'Your instance cannot be started, please try starting it with "niod"'
	fi
else
	echo 'Something went wrong. Please check that the version of your nio binary and run this script again.'
fi
