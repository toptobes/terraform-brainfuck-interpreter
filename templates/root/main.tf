variable "code" {
  type = string
}

variable "tape" {
  type = list(number)
}

variable "tape_ptr" {
  type = number
}

variable "code_ptr" {
  type = number
}

variable "input" {
  type = string
}

variable "output" {
  type = string
}

variable "bracket_lut" {
  type = map(number)
}

module "i" {
  source      = "./modules/interpreter"
  code        = var.code
  bracket_lut = var.bracket_lut
  code_ptr    = var.code_ptr
  input       = var.input
  output      = var.output
  tape        = var.tape
  tape_ptr    = var.tape_ptr
}

output "results" {
  value = module.i
}
