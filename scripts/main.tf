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
      "ssh -i /.ssh/My-gitdevops.pem ec2-52-91-98-158.compute-1.amazonaws.com",
      "sudo tee /etc/yum.repos.d/grafana.repo <<EOF
       [grafana]
       name=grafana
       baseurl=https://packages.grafana.com/oss/rpm
       repo_gpgcheck=1
       enabled=1
       gpgcheck=1
       gpgkey=https://packages.grafana.com/gpg.key
       sslverify=1
       EOF
     "sudo yum update -y",
     "sudo yum install grafana -y",
     "sudo systemctl start grafana-server",
     "sudo systemctl enable grafana-server"
     ]
  }
  provisioner "local-exec" {
        command = " echo ${aws_instance.Financedeploy-server.public_ip} > inventory "
  }
   provisioner "local-exec" {
  command = "ansible-playbook /var/lib/jenkins/workspace/Banking-app/scripts/monitoring.yml "
  } 
}
