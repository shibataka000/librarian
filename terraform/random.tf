resource "random_string" "aoss_collection_name_suffix" {
  length  = 8
  upper   = false
  special = false
}
