output "tape" {
  value = local.iter_\{pi}.tape
}

output "output" {
  value = local.iter_\{pi}.output
}

output "final_iteration" {
  value = local.iter_\{pi}
}

output "final_input" {
  value = local.code_\{pi}.input
}
