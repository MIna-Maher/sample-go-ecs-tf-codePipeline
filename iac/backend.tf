terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket         = "prd-s3-bakend-demo"
    key            = "s3/terraform.tfstate"
    #dynamodb_table = "prd-s3-bakend-demo"
    region         = "us-east-1"
    encrypt        = true
  }
}