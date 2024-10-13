locals {
  code_\{i} = (try(local.iter_\{pi}.code_ptr < length(var.code), false)
    ? slice(var.code, local.iter_\{pi}.code_ptr, local.iter_\{pi}.code_ptr + 2)
    : [null])

  input_\{i} = (local.code_\{i}[0] == ","
    ? substr(local.input_\{pi}, local.code_\{i}[1], -1)
    : local.input_\{pi})

  iter_\{i} = try(local.iter_\{pi}.code_ptr >= length(var.code), true) ? local.iter_\{pi} : {
    output = (local.code_\{i}[0] == "."
      ? "${local.iter_\{pi}.output}${join("", [for _ in range(local.code_\{i}[1]) : jsondecode(format("\"\\u%04x\"", local.iter_\{pi}.tape[local.iter_\{pi}.tape_ptr]))])}"
      : local.iter_\{pi}.output)
    
    tape = (
      local.code_\{i}[0] == "+"
        ? [for i, b in local.iter_\{pi}.tape : (i == local.iter_\{pi}.tape_ptr ? (b + local.code_\{i}[1]) % 256 : b)] :
      local.code_\{i}[0] == "-"
        ? [for i, b in local.iter_\{pi}.tape : (i == local.iter_\{pi}.tape_ptr ? (b - local.code_\{i}[1] + 256) % 256 : b)] :
      local.code_\{i}[0] == ","
        ? [for i, b in local.iter_\{pi}.tape : (i == local.iter_\{pi}.tape_ptr ? local.ascii_lookup[substr(local.input_\{i}, 0, 1)] : b)]
        : local.iter_\{pi}.tape)

    tape_ptr = (
      local.code_\{i}[0] == "<"
        ? local.iter_\{pi}.tape_ptr - local.code_\{i}[1] :
      local.code_\{i}[0] == ">"
        ? local.iter_\{pi}.tape_ptr + local.code_\{i}[1]
        : local.iter_\{pi}.tape_ptr)

    code_ptr = 2 + (
      local.code_\{i}[0] == "["
        ? local.iter_\{pi}.tape[local.iter_\{pi}.tape_ptr] == 0 ? var.bracket_lut[tostring(local.iter_\{pi}.code_ptr)] : local.iter_\{pi}.code_ptr :
      local.code_\{i}[0] == "]"
        ? local.iter_\{pi}.tape[local.iter_\{pi}.tape_ptr] != 0 ? var.bracket_lut[tostring(local.iter_\{pi}.code_ptr)] : local.iter_\{pi}.code_ptr
        : local.iter_\{pi}.code_ptr)

    steps_taken = 1 + local.iter_\{pi}.steps_taken
  }
}
