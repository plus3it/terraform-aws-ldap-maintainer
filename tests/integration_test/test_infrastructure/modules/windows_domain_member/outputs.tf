output "public_ip" {
  value       = join("", aws_instance.win.*.public_ip)
  description = "Public IP address of the windows instance"
}
