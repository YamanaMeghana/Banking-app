resource "aws_instance" "Financedeploy-server" {
  ami           = "ami-07caf09b362be10b8" 
  instance_type = "t2.micro" 
  key_name = "My-gitdevops"
  vpc_security_group_ids= ["sg-0e254c5d2f76c6398"]
  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("./My-gitdevops.pem")
    host     = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [ "echo 'wait to start instance' "]
  }
  tags = {
    Name = "Financedeploy-server"
  }
  provisioner "local-exec" {
        command = " echo ${aws_instance.Financedeploy.public_ip} > inventory "
  }
   provisioner "local-exec" {
  command = "ansible-playbook /var/lib/jenkins/workspace/Banking/scripts/finance-playbook.yml "
  } 
}
