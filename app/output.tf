output "web_lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = concat(aws_alb.web.*.dns_name, [""])[0]
}

output "web_lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch."
  value       = concat(aws_alb.web.*.arn_suffix, [""])[0]
}

output "web_lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records."
  value       = concat(aws_alb.web.*.zone_id, [""])[0]
}
