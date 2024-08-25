output "tape" {
  value = local.iter_\{prev_index}.tape
}

output "output" {
  value = local.iter_\{prev_index}.output
}

output "final_iteration" {
  value = local.iter_\{prev_index}
}
