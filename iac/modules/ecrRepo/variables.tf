variable "environment" {
  type = string
}

variable "serviceName" {
  type = string
}


variable "scan_on_push" {
  description = "Indicates whether images are scanned after being pushed to the repository (true) or not scanned (false)."
  type        = bool
}
variable "image_tag_mutability" {
  description = "The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE"
  type        = string
}

variable "kms_key" {
  description = " The ARN of the KMS key to use when encryption_type is KMS. If not specified, uses the default AWS managed key for ECR."
  type        = string
  default     = ""
}
variable "encryption_type" {
  description = "The encryption type to use for the repository. Valid values are AES256 or KMS. Defaults to AES256"
  type        = string
}
variable "image_expiration_in_days" {
  type = number
}
variable "image_tag_status" {
  description = "filtering images, untagged, tagged, any"
  type        = string
}



