#!/bin/bash

# This script only download packages through pip. (django, django-environ & psycopg2)

#==============
# Begin process 
#==============

echo "[*] Retrieving template information..."

typeset -A config

config=(
    [projectname]="my_project"
    [dbengine]="postgresql"
    [dbname]="mydb"
    [user]="root"
    [password]="root"
    [host]=127.0.0.1
    [port]=5432
    [djangoversion]="4.1.2"
    [djangoapps]=false
    [appname]=[]
    )

while read line
do 
    if echo $line | grep -F = &>/dev/null
    then
	varname=$(echo "$line" | awk -F = '{print $1}')
	config[$varname]=$(echo $line | awk -F = '{print $2}')
    fi
done < config.cfg

#=============================
# Create a virtual environment
#=============================

echo "[*] Creating a Python virtual environment..."
python3 -m venv venv
source venv/bin/activate

# ======================
# Install Django version
# ======================

TODO: Need improvement
if [[ ${config[djangoversion]} != '4.1.2' ]];then
    echo "[*] Installing Django ${config[djandoversion]} and other packages..."
    pip install django==${config[djangoversion]} django-environ
else
    echo "[*] Installing latest version of Django and other packages..."
    pip install django django-environ
fi

# ================
# DB installations 
# ================

if [[ ${config[dbengine]} == 'postgresql' ]];then
    echo "[*] installing database dependencies..."
    pip install psycopg2
fi

# =============================
# project creation with django
# =============================

if [[ $? -eq 0 ]]; then
    echo "[*] Creating Django project..."
    django-admin startproject ${config[projectname]}
fi

# =================================
# Creating content of the .env file
# =================================

echo "[*] Working on environment variables..."

SETTINGSFILE=${config[projectname]}/${config[projectname]}/settings.py
SECRETKEY=$(grep SECRET_KEY $SETTINGSFILE | awk -F ' ' {'print $3'})

echo "SECRET_KEY=$SECRETKEY" > ${config[projectname]}/.env
echo "ENGINE='django.db.backends.${config[dbengine]}'" >> ${config[projectname]}/.env
echo "NAME='${config[dbname]}'" >> ${config[projectname]}/.env
echo "USER=${config[user]}" >> ${config[projectname]}/.env
echo "PASSWORD=${config[password]}" >> ${config[projectname]}/.env
echo "HOST=${config[host]}" >> ${config[projectname]}/.env
echo "PORT=${config[port]}" >> ${config[projectname]}/.env

# ============================
# Modifying the settings file
# ============================

sed -Ei '/from.*/a import environ\nimport os' $SETTINGSFILE
sed -Ei '/BASE_DIR = Path.*/a env = environ.Env()' $SETTINGSFILE
sed -Ei "/env =.*/a environ.Env.read_env(os.path.join(BASE_DIR, \'.env\'))" $SETTINGSFILE
sed -Ei "s/SECRET_KEY =.*/SECRET_KEY = env(\'SECRET_KEY\')/" $SETTINGSFILE
sed -Ei "s/'ENGINE':.*/'ENGINE': env('ENGINE'),/" $SETTINGSFILE
sed -Ei "s/'NAME': BASE.*/'NAME': env('NAME'),\n\t\t'USER': env('USER'),\n\t\t'PASSWORD': env('PASSWORD'),\n\t\t'HOST': env('HOST'),\n\t\t'PORT': env('PORT'),/" $SETTINGSFILE

# ============
# App creation
# ============

if [[ ${config[djangoapps]} -eq true ]]; then
    echo "[*] Creating applications"

    cd ${config[projectname]}
    for app in ${config[appname]};do
	python manage.py startapp $app
    done
fi

#===========
# Git config
#===========

echo "[*] Initialising git..."

git init
touch .gitignore
echo -e '.gitignore\n.env' >> .gitignore

# =================
# Finishing process
# =================

echo "[*] Program finished. Happy coding!"
deactivate


