// providers
provider "aws" {
  version = "~> 2.41"
  profile = "default"
  region  = var.region
}
provider "random" { version = "~> 2.2" }
provider "template" { version = "~> 2.1" }

// set up route53 zone and certificate
module "r53_zone" {
  source  = "./r53_zone"
  domain  = var.domain
  comment = "Zone for var.domain} // Managed by Terraform"
}

#Grabbing index files and error files

module "s3-website" {
  source = "./html"

}

// set up S3 buckets, IAM user, policies, and cloudfront
module "site_bucket" {
  source                  = "./site_main"
  region                  = var.region
  domain                  = var.domain
  site_bucket_name        = "${var.domain}-site"
  logs_bucket_name        = "${var.domain}-logs"
  admin                   = "${var.domain}-admin"
  acm_certificate_arn     = module.r53_zone.certificate_arn
  not_found_response_path = "error.html"
}

// set up ALIAS entry to map to cloudfront distribution
module "r53_alias" {
  source             = "./r53_alias"
  domain             = var.domain
  target             = module.site_bucket.website_cdn_hostname
  cdn_hosted_zone_id = module.site_bucket.website_cdn_zone_id
  route53_zone_id    = module.r53_zone.zone_id
}
