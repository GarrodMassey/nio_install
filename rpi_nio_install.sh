read -p "Enter a name for your project: " proj
read -p "Enter your Pubkeeper hostname: " pk_host
read -p "Enter your Pubkeeper token: " pk_token

echo
echo UPDATING INSTALLED PACKAGES
echo ---------------------------
sudo apt update -y -q
sudo apt install vim -y -q
sudo apt install --reinstall git -y -q

echo
echo INSTALLING PYTHON3 AND PIP3
echo ---------------------------
sudo apt install python3 python3-dev -y -q
wget https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
echo ‘export PATH=/home/pi/.local/bin:$PATH’ >> ~/.bashrc
source ~/.bashrc

echo
echo LOOKING FOR EXISTING NIO BINARY
echo -------------------------------
nio_location="$(which niod)"

if [ $nio_location ]; then
  echo ... FOUND INSTALLED EXECUTABLE AT $nio_location
else
  echo ... INSTALLING NIO FROM WHEEL FILE
  pip3 install `find ~ -name "nio_lite-*-py3-none-any.whl" | head -n 1` --user
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

[Install]
WantedBy=multi-user.target' > $proj.service
sudo mv $proj.service /etc/systemd/system/.

sudo iw dev wlan0 set power_save off

echo
echo CREATING PROJECT
echo ----------------
mkdir -p nio/projects
cd nio/projects/
nio new $proj --pubkeeper-hostname $pk_host --pubkeeper-token $pk_token
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
	echo 'Something went wrong. Please see any errors in the console above and attempt to manually install the nio wheel.'
fi
