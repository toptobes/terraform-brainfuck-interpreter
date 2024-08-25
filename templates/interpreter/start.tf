variable "code" {}

variable "tape" {}

variable "tape_ptr" {}

variable "code_ptr" {}

variable "input" {}

variable "output" {}

variable "bracket_lut" {}

locals {
  ascii_lookup = { for i in range(0, 255) : jsondecode(format("\"\\u%04x\"", i)) => i }

  iter_0 = {
    input       = var.input
    output      = var.output
    tape        = var.tape
    tape_ptr    = var.tape_ptr
    code_ptr    = var.code_ptr
    steps_taken = 0
  }
}
