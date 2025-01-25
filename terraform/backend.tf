terraform {
  backend "s3" {
    bucket       = "sbtk-tfstate"
    key          = "librarian"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
