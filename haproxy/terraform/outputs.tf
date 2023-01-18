output "my_haproxy_ip" {
  description = "Elatic IP address assigned to our HAProxy"
  value       = aws_eip.HaProxy_IP.public_ip
}
output "my_worker_ip_1" {
  description = "Worker ID"
  value       = aws_eip.Worker_IP_1.public_ip
}
output "my_worker_ip_2" {
  description = "Worker ID"
  value       = aws_eip.Worker_IP_2.public_ip
}
output "my_worker_ip_3" {
  description = "Worker ID"
  value       = aws_eip.Worker_IP_3.public_ip
}

