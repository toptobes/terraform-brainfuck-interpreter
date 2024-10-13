output "lut" {
  value = merge({
    for p in local.lut_\{pi} : tostring(p[0]) => p[1]
  }, {
    for p in local.lut_\{pi} : tostring(p[1]) => p[0]
  })
}
