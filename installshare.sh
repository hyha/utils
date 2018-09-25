#!/bin/bash

MOUNTNAME=$1
SHARENAME=$2
USERNAME=$3
PASSWORD=$4
DIRROOT=/etc/smbcredentials
CREDFILE="$DIRROOT/$USERNAME.cred"
SHAREFULLNAME="//$USERNAME.file.core.windows.net/$SHARENAME"

if [ -z "$1" ]; then
  echo -e "MOUNT_NAME not specified, please check usage wiki and retry"
  exit 1
fi

if [ -z "$2" ]; then
  echo -e "SHARE_NAME not specified, please check usage wiki and retry"
  exit 1
fi

if [ -z "$3" ]; then
  echo -e "Azure Storage Account USERNAME not specified, please check usage wiki and retry"
  exit 1
fi

if [ -z "$4" ]; then
  echo -e "Azure Storage Account PASSWORD not specified, please check usage wiki and retry"
  exit 1
fi

if [ -d "$MOUNTNAME" ]; then
  echo -e "Mount Target Directory already exists! Must target to a non-existing directory"
  exit 1
fi

if [ -f "$CREDFILE" ]; then
  echo -e "Local Credential File already exists! For your safety please manually backup and remove the file and retry"
  exit 1
fi

echo "Azure File Share Installer"
echo ""
echo "Azure Storage Account: $USERNAME"
echo "Azure File Share Name: $SHARENAME"
echo "Mount to directory   : $MOUNTNAME"
echo "Full Share Link      : $SHAREFULLNAME"
echo ""
echo "Local Credential File: $CREDFILE"
echo ""
echo "Hit ENTER to continue or Ctrl-C to Cancel"

read confirm

if [ ! -d "$DIRROOT" ]; then
  echo "Creating Local Credential File Directory"
  mkdir "$DIRROOT"
else
  echo "Found previously created Local Credential File directory, reusing."
fi

echo "Creating Mount Target directory: $MOUNTNAME"
mkdir "$MOUNTNAME"

echo "Writing Local Credential File"
echo "username=$USERNAME" >> "$CREDFILE"
echo "password=$PASSWORD" >> "$CREDFILE"

echo "Securing Local Credential File"
chmod 600 "$CREDFILE"

if ! grep -q "$SHAREFULLNAME" /etc/fstab; then
  echo "Updating /etc/fstab"
  echo "$SHAREFULLNAME $MOUNTNAME cifs nofail,vers=3.0,credentials=$CREDFILE,dir_mode=0777,file_mode=0777,serverino" >> /etc/fstab
else
  echo "Not updating /etc/fstab file as it already contains same share link"
fi

echo "Testing and Mounting"
sudo mount -a

echo "Showing Mounted Share"
df -h|grep "$MOUNTNAME"

echo "All done."
