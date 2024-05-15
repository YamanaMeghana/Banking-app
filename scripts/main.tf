resource "aws_instance" "Financedeploy-server" {
  ami           = "ami-07caf09b362be10b8" 
  instance_type = "t2.micro" 
  key_name = "My-gitdevops"
  vpc_security_group_ids= ["sg-0e254c5d2f76c6398"]
  tags = {
    Name = "Financedeploy-server"
  }
}
  resource "aws_resource" "install_grafana" {
  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("./My-gitdevops.pem")
    host        = aws_instance.Financedeploy-server.public_ip
  }
  provisioner "remote-exec" {

    inline = [
      "echo 'wait to start instance'",
      "sudo yum-get update",
      "sudo yum-get install -y apt-transport-https software-properties-common wget",
      "sudo mkdir -p /etc/apt/keyrings/",
      "sudo wget -q -O - https://yum.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/yum/keyrings/grafana.gpg > /dev/null",
      "sudo sh -c 'echo \"deb [signed-by=/etc/yum/keyrings/grafana.gpg] https://yum.grafana.com stable main\" > /etc/yum/sources.list.d/grafana.list'",
      "sudo yum-get update",
      "sudo yum-get install -y grafana",
      "sudo systemctl start grafana-server"
     ]
  }
  provisioner "local-exec" {
        command = " echo ${aws_instance.Financedeploy-server.public_ip} > inventory "
  }
   provisioner "local-exec" {
  command = "ansible-playbook /var/lib/jenkins/workspace/Banking-app/scripts/monitoring.yml "
  } 
}
