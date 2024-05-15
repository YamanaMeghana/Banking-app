resource "aws_instance" "Financedeploy-server" {
  ami           = "ami-07caf09b362be10b8" 
  instance_type = "t2.micro" 
  key_name = "My-gitdevops"
  vpc_security_group_ids= ["sg-0e254c5d2f76c6398"]
  tags = {
    Name = "Financedeploy-server"
  }
}
  resource "null_resource" "install_grafana" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./My-gitdevops.pem")
    host        = aws_instance.Financedeploy-server.public_ip
  }
  provisioner "remote-exec" {

    inline = [
      "echo 'wait to start instance'",
      "wget -q -O gpg.key https://rpm.grafana.com/gpg.key",
      "sudo rpm --import gpg.key",
      "[grafana]\nname=grafana\nbaseurl=https://rpm.grafana.com\nrepo_gpgcheck=1\nenabled=1\ngpgcheck=1\ngpgkey=https://rpm.grafana.com/gpg.key\nsslverify=1\nsslcacert=/etc/pki/tls/certs/ca-bundle.crt",
      "sudo dnf install grafana",
      "sudo dnf install grafana-enterprise",
     ]
  }
  provisioner "local-exec" {
        command = " echo ${aws_instance.Financedeploy-server.public_ip} > inventory "
  }
   provisioner "local-exec" {
  command = "ansible-playbook /var/lib/jenkins/workspace/Banking-app/scripts/monitoring.yml "
  } 
}
