variable "use_strategy" {
  type        = string
  description = <<-EOT
    Whether to find or select an image.
    If set to `find`, type is required and must be in the list of types.
    If set to `select`, type is ignored and image is required.
    If set to `skip`, nothing will be done, helpful to get the list of available images.
  EOT
  validation {
    condition     = contains(["find", "select", "skip"], var.use_strategy)
    error_message = "The use_strategy value must be `find`, `select`,  or `skip`."
  }
}
variable "type" {
  type        = string
  description = <<-EOT
    A type from the types.tf file.
    Types represent a standard set of opinionated options that we select for you.
    Don't use this if you want to supply your own AMI id.
  EOT
  default     = ""
}

variable "image" {
  type = object({
    id          = string
    user        = string
    admin_group = string
    workfolder  = string
  })
  description = <<-EOT
    An image type to use.
    This is required when the use_strategy is "select".
    Notice the id field, this is the AMI to select.
  EOT
  default = {
    id          = ""
    user        = ""
    admin_group = ""
    workfolder  = ""
  }
}
variable "custom_types" {
  type = map(object({
    user         = string
    group        = string
    workfolder   = string
    name         = string
    name_regex   = string
    product_code = string
    owners       = list(string)
    architecture = string
  }))
  description = <<-EOT
    A custom type to inject into the types.tf file.
    This is helpful when you want to search for an AMI that is not in our selections.
    This simply adds the new type to the types, you must use the "find" use strategy and the new type's key as the type.
  EOT
  default = {
    default = {
      user         = ""
      group        = ""
      workfolder   = ""
      name         = ""
      name_regex   = ""
      product_code = ""
      owners       = []
      architecture = ""
    }
  }
}
