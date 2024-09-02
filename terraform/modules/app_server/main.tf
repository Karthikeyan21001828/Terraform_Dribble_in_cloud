provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Security group for Jenkins, SonarQube, and Apache2"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  security_groups = [aws_security_group.app_sg.name]
  key_name      = var.key_name
  tags = {
    Name = "app-server"
  }

  user_data = <<-EOF
              #!/bin/bash
              

              # Install Apache2
              sudo apt update
              sudo apt install -y apache2
              sudo systemctl start apache2
              sudo systemctl enable apache2
              sudo systemctl status apache2


              # Install Jenkins
              sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
                https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
              echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
                https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
                /etc/apt/sources.list.d/jenkins.list > /dev/null
              sudo apt-get update
              sudo apt-get install jenkins -y
              sudo apt update
              sudo apt install fontconfig openjdk-17-jre -y
              java -version
              sudo systemctl start jenkins
              sudo systemctl enable jenkins
              sudo systemctl status jenkins


              # Install SonarQube
              wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-10.5.1.90531.zip -O /opt/sonarqube.zip
              sudo apt-get install -y zip
              unzip /opt/sonarqube.zip -d /opt/
              sudo mv /opt/sonarqube-10.5.1.90531 /opt/sonarqube
              sudo chown -R ubuntu:ubuntu /opt/sonarqube

              # Create and configure SonarQube systemd service
              sudo tee /etc/systemd/system/sonarqube.service > /dev/null <<EOL
              [Unit]
              Description=SonarQube service
              After=network.target

              [Service]
              Type=forking
              User=ubuntu
              Group=ubuntu
              ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start
              ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop
              Restart=on-failure

              [Install]
              WantedBy=multi-user.target
              EOL

              sudo systemctl daemon-reload
              sudo systemctl start sonarqube
              sudo systemctl enable sonarqube
              sudo systemctl status sonarqube

              # Install SonarScanner
              sudo wget https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-6.1.0.4477-linux-x64.zip?_gl=1*xu8jv6*_gcl_au*MzE3Mzc5Mzk3LjE3MjUxOTIzODA.*_ga*MTU5OTM5MDIyNi4xNzI1MTkyMzgx*_ga_9JZ0GZ5TC6*MTcyNTI5NTQ3Mi40LjEuMTcyNTMwMjc5OS4zOS4wLjA.
              unzip sonar-scanner-cli-6.1.0.4477-linux-x64.zip?_gl=1*xu8jv6*_gcl_au*MzE3Mzc5Mzk3LjE3MjUxOTIzODA.*_ga*MTU5OTM5MDIyNi4xNzI1MTkyMzgx*_ga_9JZ0GZ5TC6*MTcyNTI5NTQ3Mi40LjEuMTcyNTMwMjc5OS4zOS4wLjA. -d /opt
              echo "export PATH=$PATH:/opt/sonar-scanner-6.1.0.4477-linux-x64/bin" >> ~/.bashrc
              echo "export SONAR_SCANNER_HOME=/opt/sonar-scanner-6.1.0.4477-linux-x64" >> ~/.bashrc
              source ~/.bashrc

              # Clean up
              rm /opt/sonar-scanner.zip
              rm /opt/sonarqube.zip

              EOF
}


