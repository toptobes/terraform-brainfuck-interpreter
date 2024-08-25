locals {
  end_of_code_\{index} = try(local.iter_\{prev_index}.code_ptr >= length(var.code), true)

  curr_\{index} = local.end_of_code_\{index} ? null : {
    code = substr(var.code, local.iter_\{prev_index}.code_ptr, 1)
    input = substr(var.code, local.iter_\{prev_index}.code_ptr, 1) == "," ? substr(local.iter_\{prev_index}.input, 0, 1) : null
  }

  iter_\{index} = local.end_of_code_\{index} ? local.iter_\{prev_index} : {
    input = (local.curr_\{index}.code == ","
      ? substr(local.iter_\{prev_index}.input, 1, -1)
      : local.iter_\{prev_index}.input)

    output = (local.curr_\{index}.code == "."
      ? "${local.iter_\{prev_index}.output}${jsondecode(format("\"\\u%04x\"", local.iter_\{prev_index}.tape[local.iter_\{prev_index}.tape_ptr]))}"
      : local.iter_\{prev_index}.output)

    tape = local.curr_\{index}.code == "+" || local.curr_\{index}.code == "-" || local.curr_\{index}.code == "," ? (
      local.curr_\{index}.code == "+"
        ? [for i, b in local.iter_\{prev_index}.tape : (i == local.iter_\{prev_index}.tape_ptr ? (b + 1) % 256 : b)] :
      local.curr_\{index}.code == "-"
        ? [for i, b in local.iter_\{prev_index}.tape : (i == local.iter_\{prev_index}.tape_ptr ? (b == 0 ? 255 : b - 1) : b)]
        : [for i, b in local.iter_\{prev_index}.tape : (i == local.iter_\{prev_index}.tape_ptr ? one([for c in range(0, 255) : c if local.curr_\{index}.input == jsondecode(format("\"\\u%04x\"", c))]) : b)]
    ) : local.iter_\{prev_index}.tape

    tape_ptr = local.curr_\{index}.code == "<" || local.curr_\{index}.code == ">" ? (
      local.curr_\{index}.code == "<"
        ? local.iter_\{prev_index}.tape_ptr == 0 ? length(local.iter_\{prev_index}.tape) - 1 : local.iter_\{prev_index}.tape_ptr - 1
        : local.iter_\{prev_index}.tape_ptr == length(local.iter_\{prev_index}.tape) - 1 ? 0 : local.iter_\{prev_index}.tape_ptr + 1
    ) : local.iter_\{prev_index}.tape_ptr

    code_ptr = 1 + (local.curr_\{index}.code == "[" || local.curr_\{index}.code == "]" ? (
      local.curr_\{index}.code == "["
        ? local.iter_\{prev_index}.tape[local.iter_\{prev_index}.tape_ptr] == 0 ? var.bracket_lut[tostring(local.iter_\{prev_index}.code_ptr)] : local.iter_\{prev_index}.code_ptr
        : local.iter_\{prev_index}.tape[local.iter_\{prev_index}.tape_ptr] != 0 ? var.bracket_lut[tostring(local.iter_\{prev_index}.code_ptr)] : local.iter_\{prev_index}.code_ptr
    ) : local.iter_\{prev_index}.code_ptr)

    steps_taken = 1 + local.iter_\{prev_index}.steps_taken
  }
}
