output "server" {
  value = module.this.server
}
output "access" {
  value     = module.access
  sensitive = true
}
output "image" {
  value = module.this.image
}
