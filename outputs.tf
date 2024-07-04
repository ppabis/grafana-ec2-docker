output "ipv4" {
  value = aws_instance.grafana.public_ip
}

output "ipv6" {
  value = aws_instance.grafana.ipv6_addresses[0]
}

output "grafana_password" {
  value     = random_string.grafana_password.result
  sensitive = true
}

output "site_ipv6" {
  value = "https://[${aws_instance.grafana.ipv6_addresses[0]}]"
}

output "site_ipv4" {
  value = "https://${aws_instance.grafana.public_ip}"
}
