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

locals {
  curr_code = substr(var.code, var.code_ptr, var.code_ptr + 1)
  curr_input = local.curr_code == "," ? substr(var.input, 0, 1) : null

  updated_input = (local.curr_code == ","
    ? substr(var.input, 1, length(var.input))
    : var.input)

  updated_output = (local.curr_code == "."
    ? "${var.output}${jsondecode(format("\"\\u%04x\"", var.tape[var.tape_ptr]))}"
    : var.output)

  updated_tape = local.curr_code == "+" || local.curr_code == "-" || local.curr_code == "," ? (
    local.curr_code == "+"
      ? [for i, b in var.tape : (i == var.tape_ptr ? (b + 1) % 256 : b)] :
    local.curr_code == "-"
      ? [for i, b in var.tape : (i == var.tape_ptr ? (b == 0 ? 255 : b - 1) : b)]
      : [for i, b in var.tape : (i == var.tape_ptr ? one([for c in range(0, 255) : c if local.curr_input == jsondecode(format("\"\\u%04x\"", c))]) : b)]
  ) : var.tape

  updated_tape_ptr = local.curr_code == "<" || local.curr_code == ">" ? (
    local.curr_code == "<"
      ? var.tape_ptr == 0 ? length(var.tape) - 1 : var.tape_ptr - 1
      : var.tape_ptr == length(var.tape) - 1 ? 0 : var.tape_ptr + 1
  ) : var.tape_ptr

  updated_code_ptr = local.curr_code == "[" || local.curr_code == "]" ? (
    local.curr_code == "["
      ? var.tape[var.tape_ptr] == 0 ? var.bracket_lut[tostring(var.code_ptr)] : var.code_ptr
      : var.tape[var.tape_ptr] != 0 ? var.bracket_lut[tostring(var.code_ptr)] : var.code_ptr
  ) : (var.code_ptr + 1)
}

output "tape" {
  value = local.updated_tape
}

output "output" {
  value = local.updated_output
}

output "code_ptr" {
  value = local.updated_code_ptr
}
