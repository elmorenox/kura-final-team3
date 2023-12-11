module "vpc_us_west_2" {
  source     = "./vpc_module"
  az        = ["us-west-2a", "us-west-2b"]
  region     = "us-west-2"
    access_key =    var.access_key
    secret_key =    var.secret_key
}
