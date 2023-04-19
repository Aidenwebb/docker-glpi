#!/bin/bash
# If GLPI web root folder has content, then assume GLPI is already present. If not, it's likely a fresh mount/volume and we should populate it with the GLPI files.

if [ "$(ls /var/www/html/glpi/)" ]; then
    echo "GLPI is already installed"
else
    echo "GLPI is not present in web root installed, copying files to web root"
    # Copy GLPI files to web root
    cp -rp /usr/local/src/glpi /var/www/html
fi

# Start Apache
/usr/sbin/apache2ctl -D FOREGROUND
