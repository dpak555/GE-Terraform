variable "numberofmachines" {
  description = "Number of machines to provision"
  default     = 1
}

variable "key_name" {
  description = "Name of the SSH keypair to use in AWS."
}

variable "private_key" {
  description = "Location of private key for the key_name keypair"
}

variable "kms_key_id" {
  description = "KMS key ID to use for encryption of root volume"
  default     = "arn:aws:kms:us-east-1:276489634567:key/dee00010-a077-4583-b119-3ee6b8306997"
}

# Not setting a default here, will mean it will have to be specified in every
# provisioning script

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-east-1"
}

variable "subnet_id" {
  description = "Subnet to launch servers."
  default     = "subnet-0676a3be4825d9f6c"
}

#variable "albextrasubnet" {
#  description = "Additional subnet to use for ALB"
#  # Do not define this, so that all scripts can be caught that do not yet
#  # have the albextrasubnet listed
#  default     = "Not Defined"
#}

#variable "subnets" {
#  description = "array of subnets to use for AZs and hopefully instances"
#  # default = ["subnet-c65452a3","subnet-ea33ebb0","subnet-3336951f "]
#  # complains about multiple subnets in same AZ
#  type        = list(string)
#  # dealing with version 12 changes trying to get subnets to be properly passed again
#  default     = ["subnet-c65452a3","subnet-ea33ebb0" ]
#}

variable "vpc_id" {
  description = "vpc to launch servers."
  default     = "vpc-0924aa6f"
}

variable "instance_port" {
  description = "Port instance listens on"
  default     = "30845"
}

variable "exposed_mongo_port" {
  description = "When debugging kubectl turned on mongo can be exposed on this port  making it a range from instance port to exposed mongo port"
  default     = "30846"
}

variable "kubermanagement_port" {
  description = "Port instance listens on"
  default     = "6443"
}

variable "lb_port" {
  description = "Port Load balancer listens on"
  default     = "443"
  # GE windows pac settings or firewall settings won't let me get to port 8081 or port 80 on load balancer
  # setting to port 3389, and connection goes through

}

#variable "certificate_arn" {
#  description = "Pre-existing certificate to be used by load balanacer"
#  default     = "arn:aws:iam::809168911871:server-certificate/prod.sisense2019.digital.ge.com"
#}


variable "instance_name" {
  description = "Name for instance."
  default     = "SisenseLinuxPOC"
}

variable "instance_type" {
  description = "Type for instance."
  default     = "i3en.2xlarge"
  # will want local volumes for actual systems, marked increase in performance
}

variable "volume_size" {
  description = "size of root volume"
  default     = "50"
}

variable "tag_uai" {
  description = "UAI for tag specification"
  default     = "UAI1010163"
}
variable "tag_purpose" {
  description = "Diferentiator between Data Analytics subteams"
  default     = "ctr-data-analytics-d-platform"
}

variable "tag_env" {
  description = "Environment (dev/prod/etc)"
  default     = "dev"
}
# note uniqueflagvalue and uniquevalueflag possible swap in deploy scripts
variable "uniqueflagvalue" {
  description = "Change this value to force regeneration of ELB.  Reuse existing value to maintain existing ELB possibly linked to DNS alias"
  default     = "dev"
}

#variable "mostrecentbackupkeyprefix" {
#  description = "prefix to the most recent backup so that multiple sets can be stored in same bucket"
#  default = "Generic"
#}

#variable "SkipSisenseInstall" {
#  description = "Set to true to skip sisense install and to reuse orchestration for other purposes"
#  default = "false"
#}

#variable "GErootpath" {
#  description = "Name of GE Enterprise root certificate"
#  default = "GE_Enterprise_Root_CA_2_1.cer"
#}


variable "bucket_name" {
  description = "Suffix for bucket to use for file copy"
  default     = "sisenseFebconfig"
}

variable "role_name" {
  description = "Instance role that can read the bucket_name bucket"
  default     = "AR-EC2-Dev-SisensePlatformTeam"
}


variable "oauthtoken" {
  description = "oauthtoken to provide access to github respositories"
  #default = "DONOTCOMMITACTUALTOKENS"
  #also Removing the default, so that if it doesn't get defined then it 'fails fast' instead of an hour later when you look at the setup
}

# Moving to get files from github instead of pushing them to S3
# dont need to name them this way

#variable "cloudwatchconfigjson_path" {
#  description = "path in bucket containing the clouwatch config base file"
#  default = "basecloudwatch.json"
#}


#variable "userscube" {
#  description ="Cube that contains user data"
#  default ="Users_sandbox"
#}

# activation method changed in version 8-linux

variable "sisense_username" {
  description = "Username for Sisense activation"
}

variable "sisense_password" {
  description = "Password for Sisense activation"
}


variable "sisense_contentmd5" {
  description = "Content-MD5 to provide as header"
}


variable "sisense_executable" {
  description = "Tar file containing the installation for linux"
  default     = "Sisense-L8.2.1.tar.gz"
}


variable "sisense_directory" {
  description = "Directory tarfile will expand to  export form of sisense-L8.0.3.148"
  default     = "sisense-L8.2.1.309"
}

#variable "Dumplocation" {
#  description = "Where to store regularly performed mongodumps"
#  default = "\\mongodumps"
#}


#variable "importuserdata"{
#  description = "value of True imports user data.  Else does not import data"
#  default = "True"
#}


#variable "Installversion"{
#  description = "Which version to install presume 6 or 7 for now"
#  default = "8"
#}

#variable "S3BackupLocation" {
#  description = "Bucket to eventually be used to store backups and from which to restore previous"
#  default = "s3://ctr-data-platform-sisense-backup"
#}


#variable "ecr_name" {
#  description = "Repository name to push image"
#  default = "276489634567.dkr.ecr.us-east-1.amazonaws.com/dev-sis-sweeperTOBEREMOTEDHEREONLYTOKEEPCODEINTEMPLATE"
#}

# values to be passed to pip install
# right now just using http_proxy
# issue encountered with kubernetes when /etc/environment was populated with these and a more complex no_proxy

variable "http_proxy" {
  description = "HTTP PROXY"
  default     = "http://cis-americas-pitc-cinciz.proxy.corporate.ge.com:80"
}

variable "https_proxy" {
  description = "HTTPS PROXY"
  default     = "http://cis-americas-pitc-cinciz.proxy.corporate.ge.com:80"
}

variable "no_proxy_base" {
  description = "NO PROXY BASE"
  default     = ".ge.com"
}
