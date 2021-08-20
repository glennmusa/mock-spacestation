#!/bin/bash

# some hello world stuff
hostToSync="hostToSyncDefaultValue"
echo "Here's where you set up synching to $hostToSync! If Bicep magic worked, you should see a machine name. If it didn't, you'll see some default value." >> /home/azureuser/helloWorld.txt

# setup trials directory
mkdir /home/azureuser/trials

# write private key
echo "privateKeyDefaultValue" >> /home/azureuser/.ssh/mockSpacestationPrivateKey
chmod 600 /home/azureuser/.ssh/mockSpacestationPrivateKey

# setup sync script
mkdir /home/azureuser/scripts
touch /home/azureuser/scripts/sync.sh
cat > /home/azureuser/scripts/sync.sh <<EOF
#!/bin/bash
rsync -arvz --bwlimit=250 -e "ssh -i /home/azureuser/.ssh/mockSpacestationPrivateKey" azureuser@hostToSyncDefaultValue:/trials/* /trials/
EOF

# register cron
# echo "* * * * * echo hello" >> syncJob
# echo "*/5 * * * * /home/azureuser/scripts/sync.sh >> /home/azureuser/azure-sync.log 2>&1" >> syncJob
# crontab syncJob
# rm syncJob
# crontab -l
