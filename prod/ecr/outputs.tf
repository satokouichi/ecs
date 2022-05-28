output "web" {
  value = module.web.ecr_repository_this_repository_url
}

output "php" {
  value = module.php.ecr_repository_this_repository_url
}

output "db" {
  value = module.db.ecr_repository_this_repository_url
}