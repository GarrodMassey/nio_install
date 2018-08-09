read -p "Enter a name for your project: " proj
read -p "Enter your Pubkeeper hostname: " pk_host
read -p "Enter your Pubkeeper token: " pk_token

echo
echo UPDATING INSTALLED PACKAGES
echo ---------------------------
sudo apt update -y -q
sudo apt install --reinstall git -y -q

echo
echo CHECKING PYTHON3 AND PIP
echo ---------------------------
if which python3 > /dev/null
then
	echo PYTHON3 INSTALL FOUND
	if which python3-dev > /dev/null
	then
		:
	else
		echo INSTALLING PYTHON3 DEVELOPMENT PACKAGE
		sudo apt install python3-dev -y -q
	fi
else
	sudo apt install python3 python3-dev -y -q
fi

if which pip3 > /dev/null
then
	echo PIP3 INSTALL FOUND
else
	wget https://bootstrap.pypa.io/get-pip.py
	python3 get-pip.py --user
	echo 'export PATH=/home/pi/.local/bin:$PATH' >> ~/.bashrc
	source ~/.bashrc
fi

echo
echo INSTALLING NIO BINARY INTO VIRTUAL ENVIRONMENT
echo ----------------------------------------------
pip3 install virtualenv --user
mkdir -p nio
cd nio
virtualenv env
source env/bin/activate
cd ..
pip install -U `find ~ -name "nio_lite-*-py3-none-any.whl" | head -n 1`

echo
echo CHECKING INSTALL
echo ----------------
if which niod > /dev/null
then
	echo 'nio has successfully been installed in your environment.'
else
	echo 'Something went wrong. Please see any errors in the console above and attempt to re-run this script.'
	exit 1
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

echo
echo CREATING PROJECT
echo ----------------
cd nio
mkdir -p projects
cd projects/
nio new $proj --pubkeeper-hostname $pk_host --pubkeeper-token $pk_token
cd $proj

echo
echo STARTING SERVICE
echo ----------------
sudo systemctl daemon-reload
sudo systemctl enable $proj.service
sudo systemctl start $proj.service

echo
echo CHECKING INSTANCE STATUS
echo ---------------
if ps ax | grep -v grep | grep niod > /dev/null
then
	echo 'Your instance has started successfully'
else
	echo 'Your instance cannot be started, please try starting it with "niod"'
	exit 2
fi