output "image_id" {
  value = data.aws_ami.Canonical_ubuntu18.id
}

output "instance_id" {
  value = aws_instance.sisenseinstance.*.id

}

output "private_ip" {
  value = aws_instance.sisenseinstance.*.private_ip

}


# No longer using classic load balancers
#output "Classic_Load_Balancer" {
#  value = "${aws_elb.web.dns_name}" # want internal name here
#}

#output "Application_Load_Balancer" {
#  value = "${aws_alb.alb_front.dns_name}" # want internal name here
#}
