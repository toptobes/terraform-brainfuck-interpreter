variable "code" {
  type = string
}

variable "tape" {
  type = list(number)
}

variable "tape_ptr" {
  type    = number
  default = 0
}

variable "code_ptr" {
  type    = number
  default = 0
}

variable "input" {
  type    = string
  default = ""
}

variable "output" {
  type    = string
  default = ""
}

module "bracket_lut" {
  source = "./modules/bracket_lut"
  code   = var.code
}

module "interpreter" {
  source      = "./modules/interpreter"
  code        = var.code
  bracket_lut = module.bracket_lut.lut
  code_ptr    = var.code_ptr
  input       = var.input
  output      = var.output
  tape        = var.tape
  tape_ptr    = var.tape_ptr
}

output "results" {
  value = module.interpreter
}

output "bracket_lut" {
  value = module.bracket_lut
}
