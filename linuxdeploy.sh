#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Set UNIQUEBATCH value as argument"
    exit
fi
export UNIQUEVALUEFLAG=$1

. ~/Desktop/bin/credprep.sh $UNIQUEVALUEFLAG
# credprep has 'secrets' is not checked into github
#if [ $# -ne 1 ];
#    then echo "Set UNIQUEBATCH value as argument"
#    exit
#fi
#export UNIQUEVALUEFLAG=$1
#export OAUTHTOKEN=
#export SISENSEUSERNAME=
#export SISENSEPASSWORD=

if [ -z "$OAUTHTOKEN" ]; then
    echo "Please set OAUTHTOKEN enironment variable"
    exit 1
fi

terraform workspace select $UNIQUEVALUEFLAG

if [ $? -eq 0 ]; then
    echo "Switching workspaces"
else
    terraform workspace new $UNIQUEVALUEFLAG
fi

if [ -z "$SISENSEPASSWORD" ]; then
    echo "Please set SISENSEPASSWORD enironment variable"
    exit 1
fi

if [ -z "$SISENSEUSERNAME" ]; then
    echo "Please set SISENSEUSERNAME environment variable"
    exit 1
fi

if [ -z "$UNIQUEVALUEFLAG" ]; then
    echo "Please set UNIQUEVALUEFLAG"
    export UNIQUEVALUEFLAG=dev
else
    echo "Using user supplied uniquevalueflag"
    echo $UNIQUEVALUEFLAG
fi

export EXETOUSE=Sisense-L8.2.1.tar.gz
export DIRTOUSE=sisense-L8.2.1.309

itype=i3en.2xlarge

subnettouse=subnet-0676a3be4825d9f6c # us-east-1a

#albextrasubnet=subnet-0eac31f3b125d1593 #us-east-1f

#terraform init

terraform apply -var 'key_name=212804341' \
    -var "private_key=~/.ssh/id_rsa" \
    -var "sisense_username=$SISENSEUSERNAME" \
    -var "sisense_password=$SISENSEPASSWORD" \
    -var "oauthtoken=$OAUTHTOKEN" \
    -var "subnet_id=$subnettouse" \
    -var 'vpc_id=vpc-0924aa6f' \
    -var 'bucket_name=ctr-data-platform-sisenseversion8linuxconfig' \
    -var 'role_name=AR-EC2-Dev-SisensePlatformTeam' \
    -var 'sisense_contentmd5=2f6ca01738244e335f75bbe4cdb6e09b'  \
    -var 'volume_size=900' \
    -var "sisense_executable=$EXETOUSE" \
    -var "sisense_directory=$DIRTOUSE" \
    -var "instance_type=$itype" \
    -var "uniqueflagvalue=$UNIQUEVALUEFLAG" \
    -var "numberofmachines=1" \
    -auto-approve
  
# need lambda role that can write to AmazonCloudWatchAgent
