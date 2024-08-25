locals {
  idx_\{index} = min(try(index(local.code_\{prev_index}, "["), 999999999), try(index(local.code_\{prev_index}, "]"), 999999999))

  code_\{index} = (local.idx_\{index} != 999999999
    ? slice(local.code_\{prev_index}, local.idx_\{index} + 1, length(local.code_\{prev_index}))
    : null)
    
  abs_idx_\{index} = local.idx_\{index} + local.abs_idx_\{prev_index} + 1

  lut_\{index} = local.idx_\{index} == 999999999 ? local.lut_\{prev_index} : (
    (try(index(local.code_\{prev_index}, "["), null) == local.idx_\{index} 
      ? concat([[local.abs_idx_\{index}]], local.lut_\{prev_index}) 
      : [for p in local.lut_\{prev_index} : (p[0] == [for p2 in local.lut_\{prev_index} : p2 if length(p2) == 1][0][0] ? [p[0], local.abs_idx_\{index}] : p)])
  )
}
