# This will retrieve your public IPv4
data "http" "ip" {
  url = "https://api.ipify.org/?format=json"
}

resource "aws_security_group" "grafana_sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "grafana-sg-${random_string.stack_id.result}"

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    # This will allow anyone to acecss via HTTPS when using IPv6 or just your IPv4
    ipv6_cidr_blocks = ["::/0"]
    cidr_blocks      = ["${jsondecode(data.http.ip.response_body).ip}/32"]
  }
}

resource "aws_instance" "grafana" {
  ami           = data.aws_ssm_parameter.al2023.value
  instance_type = "t4g.micro"

  vpc_security_group_ids      = [aws_security_group.grafana_sg.id]
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true
  ipv6_address_count          = 1

  iam_instance_profile = aws_iam_instance_profile.grafana_ec2_profile.name
  user_data = templatefile("./resources/user-data.sh", {
    param_docker_compose = aws_ssm_parameter.docker_compose.name,
    param_nginx_conf     = aws_ssm_parameter.nginx_conf.name,
    param_grafana_ini    = aws_ssm_parameter.grafana_ini.name
  })

  tags = {
    Name = "grafana-${random_string.stack_id.result}"
  }
}

