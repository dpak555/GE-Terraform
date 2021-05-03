#!/bin/bash
# reviewing July 20th to see behavior with 8.2.1.309
# install seems to be good, import is having issues

# deal with sisense insistence of a separate mount point
# for the /opt/sisense filesystem
echo -e "\nCreating file systems for sisense mount /opt/sisense"
mkfs -t ext4 /dev/nvme1n1
mkdir /opt/sisense
mount /dev/nvme1n1 /opt/sisense
cp /etc/fstab /etc/fstab.orig
newuuidvalue="$(lsblk -o +UUID | grep nvme1n1 | awk '{print $8; exit}')"
echo "UUID=$newuuidvalue  /opt/sisense  ext4  defaults,nofail  0  2" >>/etc/fstab

# may be missing node.local variants
# If skipping use of these entries will need to manually get requirements for windows2linux import
echo -e "\nImporting  server certificate....."
curl --create-dirs https://static.gecirtnotification.com/browser_remediation/packages/GE_External_Root_CA_2_1.crt -o /usr/local/share/ca-certificates/GE_External_Root_CA_2_1.crt && update-ca-certificates

# expecting GE cert to be in place prior to docker installation startup

echo -e "\nRefreshing repos and importing key."
apt-get update && apt-get install -y apt-transport-https ca-certificates

apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo -e "Keyserver gets cranky, putting in retry-fallback logic\n"

echo -e "\nInstalling aws cli."
apt-get update && apt-get install -y awscli

echo -e "\nNeed new rsa key to be in place so ssh and sisense ansible doesnt ask for password."
sudo -u ubuntu ssh-keygen -t rsa -N '' -f /home/ubuntu/.ssh/id_rsa <<<y
cat /home/ubuntu/.ssh/id_rsa.pub >>/home/ubuntu/.ssh/authorized_keys

echo -e "\nInitialize and pull the git repo."
mkdir /home/ubuntu/geaws && cd /home/ubuntu/geaws
git init
git pull https://${oauthtoken}@github.build.ge.com/212804341/geaws
chown -R ubuntu:ubuntu /home/ubuntu/geaws


echo -e "\nDownloading required files from s3 bucket."
mkdir /home/ubuntu/bunchoffiles
aws s3 sync s3://${configbucketname}/ /home/ubuntu/bunchoffiles/
chown -R ubuntu:ubuntu /home/ubuntu/bunchoffiles/

echo -e "\nStarting sisense installation ${directoryoftar} ..."
cd /home/ubuntu
tar xzvf /home/ubuntu/bunchoffiles/${keyoftarfile}
chown -R ubuntu:ubuntu /home/ubuntu/${directoryoftar}

# 8.0.5 version no longer accepts 0.0.0.0 as listening address, need to put actual IP in to the config file
sudo -u ubuntu cp /home/ubuntu/${directoryoftar}/single_config.yaml /home/ubuntu/${directoryoftar}/single_config.yaml-orig

ip="$(ip route get 8.8.8.8 | awk '{print $7; exit}')"
sed "s/I.I.I.I/$ip/g" </home/ubuntu/geaws/sisenseonlinux/single_config.yaml | sed "s/E.E.E.E/$ip/g" >/home/ubuntu/${directoryoftar}/single_config.yaml

##steps  for sisense version 8.x..###
cd /home/ubuntu/${directoryoftar}
echo -e "\nNext line needs to be rewritten to function in bash works from commandline just not in script."
sed 's/>\{0,2\}\s\/dev\/null 2>\&1//g' sisense.sh >sisense_debug.sh && chmod +x sisense_debug.sh
sed "s#pip install#pip install --proxy=${http_proxy}#g" sisense_debug.sh >sisense_proxy.sh && chmod +x sisense_proxy.sh
# consider adding logic for debugging by parameter
sudo -u ubuntu ./sisense_proxy.sh /home/ubuntu/${directoryoftar}/single_config.yaml -y
##End section 8.x ###

## Installation steps for sisense version sisense-L8.2.1.309 ...
##Sisense provides an easy-to-use installer wrapper that runs the sisense installation Docker image.
#chmod +x /home/ubuntu/geaws/sisenseonlinux/apps/sisense_install.sh
#su - ubuntu -c "env directoryoftar=${directoryoftar}  http_proxy=${http_proxy} /home/ubuntu/geaws/sisenseonlinux/apps/sisense_install.sh"
##End sisense-L8.2.1.309 section##

echo -e "\nAt this stage Sisense install work finished."
echo -e "Testing for incident 150226."
sleep 30

echo -e "\nStart Sisense License activation pieces here."
IP="$(hostname -I | cut -f1 -d' ')"
# deal with non license activation not being responsive to localhost

python /home/ubuntu/geaws/sisenseonlinux/apps/activate.py --baseurl "http://$IP:30845" --username "${username}" --password "${password}"
sleep 180

echo -e "\nTry to update replicate sets to get rid of 1.5 GB limit for mongo-d and export."
sudo -u ubuntu kubectl --kubeconfig=/home/ubuntu/.kube/config -n sisense patch statefulsets sisense-mongod --patch '{"spec":{"containers":[{"name":"metrics","resources":{"limits":{"memory":"25120Mi"}}}]}}'
sudo -u ubuntu kubectl --kubeconfig=/home/ubuntu/.kube/config -n sisense patch statefulsets sisense-mongod --patch '{"spec":{"containers":[{"name":"mongod-container","resources":{"limits":{"memory":"25120Mi"}}}]}}'
# concerned those are not actually modifying the memory
sudo -u ubuntu kubectl --kubeconfig=/home/ubuntu/.kube/config get -n sisense statefulsets sisense-mongod -o yaml | sed 's/memory\: 1512Mi/memory\: 15120Mi/g' | kubectl apply --kubeconfig=/home/ubuntu/.kube/config -f -
sudo -u ubuntu kubectl --kubeconfig=/home/ubuntu/.kube/config get -n sisense statefulsets sisense-mongod -o yaml | sed 's/memory\: 3000Mi/memory\: 30000Mi/g' | kubectl apply --kubeconfig=/home/ubuntu/.kube/config -f -
sudo -u ubuntu kubectl delete pod -n sisense sisense-mongod-0
echo "Wait for mongo to restart from stateful set."
sleep 50    
echo  -e "End of user_data...\n"
exit

