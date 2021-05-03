# Specify the provider and access details
provider "aws" {
  region = var.aws_region
}

# Default security group to access the instances via WinRM over HTTP and HTTPS
resource "aws_security_group" "default" {
  name        = "tf_sisense_${var.uniqueflagvalue}${random_id.fakeuuid.hex}"
  description = "Used by terraform to enable access to the sisene listener"
  vpc_id      = var.vpc_id
  tags = {
    Name        = "${var.instance_name}"
    uai         = "${var.tag_uai}"
    purpose     = "${var.tag_purpose}"
    env         = "${var.tag_env}"
    uniquebatch = "${var.uniqueflagvalue}"

  }

  ingress {
    from_port   = var.lb_port
    to_port     = var.lb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.instance_port
    to_port     = var.exposed_mongo_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # may want to change this to the load balancer
  ingress {
    from_port   = var.kubermanagement_port
    to_port     = var.kubermanagement_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["3.0.0.0/8"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8"]
  }
}

# Default security group to access the instances via WinRM over HTTP and HTTPS
resource "aws_security_group" "selfreferencing" {
  name        = "tf_sisense_self${var.uniqueflagvalue}${random_id.fakeuuid.hex}"
  description = "Used by terraform to enable access cluster of machines if set up in cluster"
  vpc_id      = var.vpc_id
  tags = {
    Name        = "${var.instance_name}"
    uai         = "${var.tag_uai}"
    purpose     = "${var.tag_purpose}"
    env         = "${var.tag_env}"
    uniquebatch = "${var.uniqueflagvalue}"

  }

  # sample for cluster access from self   anywhere is just temporary for testing
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    #  cidr_blocks = ["0.0.0.0/0"]  do not uncommment will be unsafe
    # unable to add rules without a cidr_block, generating fake cider block
    # using amazon meta data service IP as the additional address
    cidr_blocks = ["169.254.169.254/32"]
    self        = true
  }
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Lookup the correct AMI based on the region specified
data "aws_ami" "Canonical_ubuntu18" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name = "name"
    # values = ["Ubuntu Server 18.04 LTS (HVM)-*"]
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    #  Ubuntu Server 18.04 LTS (HVM)
  }
}

resource "aws_instance" "sisenseinstance" {

  count                  = var.numberofmachines
  user_data              = data.template_file.user_data.rendered
  instance_type          = var.instance_type
  ami                    = data.aws_ami.Canonical_ubuntu18.image_id
  subnet_id              = var.subnet_id
  iam_instance_profile   = var.role_name
  key_name               = var.key_name
  vpc_security_group_ids = ["${aws_security_group.default.id}", "${aws_security_group.selfreferencing.id}"]

  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${var.private_key}")
    host        = self.private_ip

  }

  tags = {
    Name         = "${var.instance_name}${count.index}${var.uniqueflagvalue}"
    uai          = "${var.tag_uai}"
    purpose      = "${var.tag_purpose}"
    env          = "${var.tag_env}"
    uniquebatch  = "${var.uniqueflagvalue}"
    EC2ART       = "AgentsOnly"
    remediatable = "yes"
  }

  volume_tags = {
    Name = "${var.instance_name}${count.index}${var.uniqueflagvalue}"
    env  = "${var.tag_env}"
    uai  = "${var.tag_uai}"

  }

  root_block_device {
    volume_size = "150"
    encrypted   = true
    kms_key_id  = var.kms_key_id

  }

  # Need Data Disk for sisense mount /opt/sisense
  ebs_block_device {
    device_name           = "/dev/sdg"
    volume_type           = "gp2"
    volume_size           = var.volume_size
    delete_on_termination = true
    encrypted             = true

  }

}

data "template_file" "user_data" {
  template = file("templates/user_data.tpl")
  vars = {
    oauthtoken = "${var.oauthtoken}"
    #ecr_name              = "${var.ecr_name}"
    region           = "${var.aws_region}"
    configbucketname = "${var.bucket_name}"
    keyoftarfile     = "${var.sisense_executable}"
    directoryoftar   = "${var.sisense_directory}"
    username         = "${var.sisense_username}"
    password         = "${var.sisense_password}"
    #baseurl               = "http://localhost:30845"
    http_proxy  = "${var.http_proxy}"
    https_proxy = "${var.https_proxy}"
    no_proxy    = "${var.no_proxy_base}"
  }

}

resource "random_id" "fakeuuid" {
  keepers = {
    # Generate a new id each time only when new value is specified
    # This will allow reuse of ELBs and security groups unless
    # a new unique value variable is chosen.
    ami_id = "${var.uniqueflagvalue}"
  }

  byte_length = 8
}
