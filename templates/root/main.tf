variable "code" {
  type        = string
  description = "The actual brainfuck code to interpret (e.g. \">+[+[<]>>+<+]>.\")"\{maybe_default_code}
}

variable "tape" {
  type        = list(number)
  description = "Brainfuck's memory tape (e.g. [0, 0, 0, 0, 0, 0, 0, 0, 0, 0])"\{maybe_default_tape}
}

variable "input" {
  type        = string
  description = "The input to pull from when the ',' command is used (e.g. \"Hi!\"). Must correspond to a byte between 0-255"
  default     = \{default_input}
}

variable "tape_ptr" {
  type        = number
  description = "The initial starting index in the memory tape"
  default     = 0
}

variable "code_ptr" {
  type        = number
  description = "The initial starting index in the brainfuck code"
  default     = 0
}

variable "output" {
  type        = string
  description = "The initial output string (not sure why you wouldn't just leave it blank but whatever)"
  default     = ""
}

locals {
  code = replace(replace(join("", regexall("[.,<>+\\-[\\]]+", var.code)), "[+]", "0"), "[-]", "0")
}

module "bracket_lut" {
  source = "./modules/bracket_lut"
  code   = local.groups
}

module "interpreter" {
  source      = "./modules/interpreter"
  code        = local.groups
  bracket_lut = module.bracket_lut.lut
  code_ptr    = var.code_ptr
  input       = var.input
  output      = var.output
  tape        = var.tape
  tape_ptr    = var.tape_ptr
}

output "output" {
  value       = module.interpreter.output
  description = "The output values from the brainfuck code (if you used the '.' command)"
}

output "tape" {
  value       = module.interpreter.tape
  description = "The resulting tape after the modifications made by the brainfuck code"
}

output "debug" {
  value = {
    final_input    = module.interpreter.final_input
    final_tape_ptr = module.interpreter.final_iteration.tape_ptr
    final_code_ptr = module.interpreter.final_iteration.code_ptr
    steps_taken    = module.interpreter.final_iteration.steps_taken
    bracket_lut    = module.bracket_lut.lut
  }
  description = "Various values that may be useful for debugging any terrafucked-up output"
}

locals {
  chars = split("", local.code)

  start_indices = [
    for i, _ in local.chars :
    i
    if i == 0 ? true : (local.chars[i] == "[" || local.chars[i] == "]" || local.chars[i] != local.chars[i - 1])
  ]

  groups = flatten([
    for i, index in local.start_indices :
    [local.chars[index], (i == length(local.start_indices) - 1 ? length(local.chars) : local.start_indices[i + 1]) - index]
  ])
}
