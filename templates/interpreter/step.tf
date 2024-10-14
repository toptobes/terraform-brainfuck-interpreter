locals {
  code_\{i} = (local.iter_\{pi}.code_ptr < length(var.code) ? {
    code = (local.iter_\{pi}.code_ptr < length(var.code)
      ? slice(var.code, local.iter_\{pi}.code_ptr, local.iter_\{pi}.code_ptr + 2)
      : [null])
    input = (local.iter_\{pi}.code_ptr < length(var.code) ? false : slice(var.code, local.iter_\{pi}.code_ptr, local.iter_\{pi}.code_ptr + 2)[0] == ","
      ? substr(local.code_\{pi}.input, slice(var.code, local.iter_\{pi}.code_ptr, local.iter_\{pi}.code_ptr + 2)[1], -1)
      : local.code_\{pi}.input)
  } : null)

  iter_\{i} = local.iter_\{pi}.code_ptr >= length(var.code) ? local.iter_\{pi} : {
    output = (local.code_\{i}.code[0] == "."
      ? "${local.iter_\{pi}.output}${join("", [for _ in range(local.code_\{i}.code[1]) : jsondecode(format("\"\\u%04x\"", local.iter_\{pi}.tape[local.iter_\{pi}.tape_ptr]))])}"
      : local.iter_\{pi}.output)
    
    tape = (
      local.code_\{i}.code[0] == "+"
        ? [for i, b in local.iter_\{pi}.tape : (i == local.iter_\{pi}.tape_ptr ? (b + local.code_\{i}.code[1]) % 256 : b)] :
      local.code_\{i}.code[0] == "-"
        ? [for i, b in local.iter_\{pi}.tape : (i == local.iter_\{pi}.tape_ptr ? (b - local.code_\{i}.code[1] + 256) % 256 : b)] :
      local.code_\{i}.code[0] == ","
        ? [for i, b in local.iter_\{pi}.tape : (i == local.iter_\{pi}.tape_ptr ? local.ascii_lookup[substr(local.code_\{i}.input, 0, 1)] : b)] :
      local.code_\{i}.code[0] == "0"
        ? [for i, b in local.iter_\{pi}.tape : (i == local.iter_\{pi}.tape_ptr ? 0 : b)]
        : local.iter_\{pi}.tape)

    tape_ptr = (
      local.code_\{i}.code[0] == "<"
        ? local.iter_\{pi}.tape_ptr - local.code_\{i}.code[1] :
      local.code_\{i}.code[0] == ">"
        ? local.iter_\{pi}.tape_ptr + local.code_\{i}.code[1]
        : local.iter_\{pi}.tape_ptr)

    code_ptr = 2 + (
      local.code_\{i}.code[0] == "["
        ? local.iter_\{pi}.tape[local.iter_\{pi}.tape_ptr] == 0 ? var.bracket_lut[tostring(local.iter_\{pi}.code_ptr)] : local.iter_\{pi}.code_ptr :
      local.code_\{i}.code[0] == "]"
        ? local.iter_\{pi}.tape[local.iter_\{pi}.tape_ptr] != 0 ? var.bracket_lut[tostring(local.iter_\{pi}.code_ptr)] : local.iter_\{pi}.code_ptr
        : local.iter_\{pi}.code_ptr)

    steps_taken = 1 + local.iter_\{pi}.steps_taken
  }
}
