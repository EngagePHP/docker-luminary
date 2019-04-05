#!/bin/bash

AES=`cat /var/run/s6/container_environment/AES`

cd /var/www

#----------------------------------------------------------
# Create and decrypt the application .env file
#----------------------------------------------------------

# Create the codeship.aes file
touch codeship.aes
chmod 0644 codeship.aes

# Add the encryption key
echo "${AES}" > codeship.aes

# decrypt the environment variables
/usr/local/bin/jet decrypt env.encrypted .env

# remove the codeship.aes file
rm -f codeship.aes

#----------------------------------------------------------
# Create a bash env to source
#----------------------------------------------------------

pattern='if [ -f /opt/envars.sh ]; then source /opt/envars.sh; fi'
source=/opt/envars.sh

if [ ! -f ${source} ]; then
    touch ${source} && chmod 0644 ${source}
fi

echo "#!/bin/bash" > ${source}

if [ ! -f /root/.bashrc ]; then
    touch /root/.bashrc
fi

if ! grep -Fxq '$pattern' /root/.bashrc ; then
    echo -e "${pattern}" >> /root/.bashrc
fi

#----------------------------------------------------------
# Generate the php-fpm config file
#----------------------------------------------------------

conf=/etc/php7/php-fpm.d/envars.conf

if [ ! -f ${conf} ]; then
    touch ${conf} && chmod 0644 ${conf}
fi

# Clear and set the file for environment variables
echo "[www]" > ${conf}

#----------------------------------------------------------
# Generate the php-cli ini file
#----------------------------------------------------------

ini=/etc/php7/conf.d/envars.ini

if [ ! -f ${ini} ]; then
    touch ${ini} && chmod 0644 ${ini}
fi

# Empty the ini file
echo "" > ${ini}

#----------------------------------------------------------
# Add the container environment variables to all files
#----------------------------------------------------------

echo "Generating Environment Variables"

sed -e '/^\s*#.*$/d' -e '/^\s*$/d' .env | cat | while IFS="=" read -r name value
do
    echo "export ${name}='${value}'" >> ${source}
    echo "env[${name}] = '${value}'" >> ${conf}
    echo "env[${name}] = '${value}'" >> ${ini}
done