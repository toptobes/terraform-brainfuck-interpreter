output "tape" {
  value = local.iter_\{prev_index}.tape
}

output "output" {
  value = local.iter_\{prev_index}.output
}

output "code_ptr" {
  value = local.iter_\{prev_index}.code_ptr
}

output "steps_taken" {
  value = local.iter_\{prev_index}.steps_taken
}
