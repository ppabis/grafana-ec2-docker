resource "random_string" "grafana_password" {
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "grafana_ini" {
  name = "/habitica/grafana/ini"
  type = "SecureString"
  value = templatefile("./resources/sample.ini", {
    password = random_string.grafana_password.result
  })
}

resource "aws_ssm_parameter" "nginx_conf" {
  name  = "/habitica/nginx/conf"
  type  = "String"
  value = file("./resources/nginx.conf")
}

resource "aws_ssm_parameter" "docker_compose" {
  name  = "/habitica/docker_compose"
  type  = "String"
  value = file("./resources/docker-compose.yml")
}
