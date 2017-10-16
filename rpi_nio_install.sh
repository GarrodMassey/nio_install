read -p "Enter the path of your binary file (ex. ~/nio_lite-20171006-py3-none-any.whl): " binary
read -p "Enter a name for your project: " proj

echo UPDATING INSTALLED PACKAGES
echo ---------------------------
sudo apt-get update -y
sudo apt-get dist-upgrade -y
sudo apt-get install vim -y
sudo apt-get install --reinstall git -y
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y
sudo pip3 install -U pip

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
Description=nio
After=network.target

[Service]
WorkingDirectory=/home/pi/nio/projects/'$proj'
ExecStart='`which nio_run`'
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
#Restart=on-failure

[Install]
WantedBy=multi-user.target' > nio.service
sudo mv nio.service /etc/systemd/system/.

echo
echo CREATING PROJECT
echo ----------------
mkdir -p nio/projects
cd nio/projects/
git clone https://github.com/niolabs/project_template.git $proj
cd $proj/blocks
git submodule update --init --recursive
cd ..

echo
echo STARTING SERVICE
echo ----------------
sudo systemctl enable nio.service
sudo systemctl start nio.service

echo
echo SERVICE STARTED
echo ---------------
echo
echo To use pubkeeper communication, configure nio.env and restart the nio service (sudo service nio restart)
