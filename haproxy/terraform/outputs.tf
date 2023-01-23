output "my_haproxy_ip_external" {
  description = "Elatic IP address assigned to our HAProxy"
  value       = aws_eip.HaProxy_IP.public_ip
}
output "my_worker_ip_1" {
  description = "Worker-1 IP"
  value       = aws_instance.My_Worker[0].private_ip
}
output "my_worker_ip_2" {
  description = "Worker-2 IP"
  value       = aws_instance.My_Worker[1].private_ip
}
output "my_worker_ip_3" {
  description = "Worker-3 IP"
  value       = aws_instance.My_Worker[2].private_ip
}

