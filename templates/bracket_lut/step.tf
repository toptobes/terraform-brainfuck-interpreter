locals {
  idx_\{i} = min(try(index(local.code_\{pi}, "["), 999999999), try(index(local.code_\{pi}, "]"), 999999999))

  code_\{i} = (local.idx_\{i} != 999999999
    ? slice(local.code_\{pi}, local.idx_\{i} + 1, length(local.code_\{pi}))
    : null)
    
  abs_idx_\{i} = local.idx_\{i} + local.abs_idx_\{pi} + 1

  lut_\{i} = local.idx_\{i} == 999999999 ? local.lut_\{pi} : (
    (try(index(local.code_\{pi}, "["), null) == local.idx_\{i} 
      ? concat([[local.abs_idx_\{i}]], local.lut_\{pi}) 
      : [for p in local.lut_\{pi} : (p[0] == [for p2 in local.lut_\{pi} : p2 if length(p2) == 1][0][0] ? [p[0], local.abs_idx_\{i}] : p)])
  )
}
