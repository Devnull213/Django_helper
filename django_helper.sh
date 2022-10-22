#!/bin/bash

#==============
# Begin process 
#==============

echo "[*] Retrieving template information..."

PROJECTNAME=$(grep projectname template | awk -F = {'print $2'})
SECRETKEY=$(grep secret_key template | awk -F = {'print $2'})
DATABASE=$(grep database template | awk -F = {'print $2'})
USER=$(grep user template | awk -F = {'print $2'})
PASSWORD=$(grep password template | awk -F = {'print $2'})
HOST=$(grep host template | awk -F = {'print $2'})
PORT=$(grep port template | awk -F = {'print $2'})
SETTINGSFILE=$PROJECTNAME/$PROJECTNAME/settings.py


#=============================
# Create a virtual environment
#=============================

echo "[*] Creating a Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# ==============================
# Install latest Django version
# ==============================

echo "[*] Installing Django and other packages..."
pip install django 
pip install django-environ

# =============================
# project creation with django
# =============================

if [[ $? -eq 0 ]]; then
    echo "[*] Creating Django project..."
    django-admin startproject $PROJECTNAME
fi

# =================================
# Creating content of the .env file
# =================================

echo "[*] Working on environment variables..."
echo "SECRET_KEY=$SECRETKEY" > $PROJECTNAME/.env
echo "DATABASE=$DATABASE" >> $PROJECTNAME/.env
echo "USER=$USER" >> $PROJECTNAME/.env
echo "PASSWORD=$PASSWORD" >> $PROJECTNAME/.env
echo "HOST=$HOST" >> $PROJECTNAME/.env
echo "PORT=$PORT" >> $PROJECTNAME/.env

# ============================
# Modifying the settings file
# ============================

sed -Ei '/from.*/a import environ\nimport os' $PROJECTNAME/$PROJECTNAME/settings.py
sed -Ei '/BASE_DIR = Path.*/a env = environ.Env()' $PROJECTNAME/$PROJECTNAME/settings.py

