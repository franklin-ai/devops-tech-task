output "hello_world_hostname" {
  description = "hostname to access hello world app"
  value       = module.ecs.hello_world_hostname
}

#output "acmpca_root_ca" {
#  description = "aws acm pca root ca certificate"
#  value       = module.ecs.acmpca_root_ca
#}
