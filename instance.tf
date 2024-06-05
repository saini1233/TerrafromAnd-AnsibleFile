provider "aws" {
    region     = var.zone
    access_key = var.access_key
    secret_key = var.secret_key
}

resource "tls_private_key" "vmkey" {
    algorithm = "RSA"
    rsa_bits  = 4096
}

resource "local_file" "pem_key_file" {
    content         = tls_private_key.vmkey.private_key_pem
    filename        = "./vault/vmkey.pem"
    file_permission = "0400"
}

resource "aws_key_pair" "ssh_key" {
    key_name   = "vmkey"
    public_key = tls_private_key.vmkey.public_key_openssh
}

resource "aws_instance" "test1" {
    ami                    = "ami-0e001c9271cf7f3b9"
    instance_type          = "t2.micro"
    key_name               = aws_key_pair.ssh_key.key_name
    vpc_security_group_ids = [aws_security_group.allow_tls.id]
    tags = {
        Name = "Tomcat"
    }

    # user_data = file("${path.path.module}./script.sh")

    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = tls_private_key.vmkey.private_key_pem
        host        = "${self.public_ip}"
    }

    provisioner "file" {
        source      = "./id_rsa.pub"
        destination = "/home/ubuntu/"
    }

    provisioner "remote-exec" {
        inline = [
            "cat /home/ubuntu/ubuntu >> /home/ubuntu/.ssh/authorized_keys",
        ]
    }

    provisioner "local-exec" {
        command = "echo ${self.private_ip} >/etc/ansible/hosts"
    }
}