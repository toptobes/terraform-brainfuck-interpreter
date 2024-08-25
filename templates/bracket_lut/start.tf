variable "code" {}

locals {
  code_list = split("", var.code)
  idx_0     = -1
  abs_idx_0 = -1
  code_0    = local.code_list
  depth_0   = 0
  lut_0     = []
}
