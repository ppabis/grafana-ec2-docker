This project will deploy:

- A VPC with a public subnet and IGW
- An EC2 instance with public IP and Docker installed
- Deploy Nginx and Grafana containers on EC2 with configuration
- Self-signed SSL certificate for Nginx

Change the VPC's IPv4 subnet as variable `cidr_block`.

Go to `tofu output site_ipv6` or `tofu output site_ipv4` in your browser.

Grafana admin password will be randomly generated. You can get it via
`tofu output grafana_password` (no quotes). Default username is `secretadmin`.

```bash
$ tofu init
$ tofu apply
$ tofu output site_ipv6 # or site_ipv4
$ tofu output grafana_password
```