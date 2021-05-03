#!/bin/bash
##installation steps for sisense version ${directoryoftar} ...
##Sisense provides an easy-to-use installer wrapper that runs the sisense installation Docker image.
##Any files that are part of your installation, such as PEM keys, SSL certificates, etc. 
##should be located in ${directoryoftar}/installer_wrapper/ext_dependencies directory.
cp /home/ubuntu/.ssh/id_rsa /home/ubuntu/${directoryoftar}/installer_wrapper/ext_dependencies/
sed -i  's/ssh_key: "\/home\/ubuntu\/.ssh\/id_rsa"/ssh_key: "\/sisense\/ext_dependencies\/id_rsa"/g' /home/ubuntu/${directoryoftar}/single_config.yaml
cd ~/${directoryoftar}/installer_wrapper/deployment_utils/
cp sisense.sh sisense.sh-orig
echo -e "\nNext line needs to be rewritten to function in bash works from commandline just not in script."
sed -i 's/>\{0,2\}\s\/dev\/null 2>\&1//g' sisense.sh 
sed -i "s#pip install#pip install --proxy=${http_proxy}#g" sisense.sh
cd /home/ubuntu/${directoryoftar}/installer_wrapper
#Installer options
#-v (version): Indicates the current version being installed
#-t (installation_template): This is an optional parameter with a default value of single. It can hold any of the following values: default, cloud, cluster, openshift, single
#-c install : 
#-l (lowercase L - local): Indicates a local-installation
#-s (silent): Indicates if you want to install Sisense silently, with no user approval prompts.
./install.sh -v ${directoryoftar} -c install -t single -l -s
## Check the sisense install status
echo -e "\nLoad container logs to verify the sisense installation status." 
container_id=`sudo docker ps -a|grep docker_installer|awk '{ print $1 }'`
sudo docker logs ${container_id}
exit
