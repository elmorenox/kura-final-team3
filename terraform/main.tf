module "vpc_us_east_1" {
  source     = "./vpc_module"
  az        = ["us-east-1a", "us-east-1b"]
  region     = "us-east-1"
    access_key =    var.access_key
    secret_key =    var.secret_key
}