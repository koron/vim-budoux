scriptencoding utf-8

function! s:ModelParse(str) dict
  return budoux#parse(self, a:str)
endfunction

function! budoux#load_model(path)
  let raw = json_decode(join(readfile(a:path), "\n"))
  let model = {
        \ 'UW1': raw->get('UW1', {}),
        \ 'UW2': raw->get('UW2', {}),
        \ 'UW3': raw->get('UW3', {}),
        \ 'UW4': raw->get('UW4', {}),
        \ 'UW5': raw->get('UW5', {}),
        \ 'UW6': raw->get('UW6', {}),
        \ 'BW1': raw->get('BW1', {}),
        \ 'BW2': raw->get('BW2', {}),
        \ 'BW3': raw->get('BW3', {}),
        \ 'TW1': raw->get('TW1', {}),
        \ 'TW2': raw->get('TW2', {}),
        \ 'TW3': raw->get('TW3', {}),
        \ 'TW4': raw->get('TW4', {}),
        \ }
  " calculate base score (bias)
  let sum = 0
  for [key, value] in model->items()
    if key =~# '^[UBT]W\d$'
      for v in value->values()
        let sum += v
      endfor
    endif
  endfor
  let model.base_score = sum / 2
  let model.parse = function('s:ModelParse')
  return model
endfunction

function! budoux#model_path(name)
  return expand(expand('<script>:p:h:h') . '/models/' . a:name, v:true)
endfunction

function! budoux#load_japanese_model()
  return budoux#load_model(budoux#model_path('ja.json'))
endfunction

function! budoux#score(model, chars, i)
  let last = len(a:chars)
  let v = {}

  let v.UW1 = a:i   > 2    ? a:model.UW1->get(a:chars[a:i-3], 0) : 0
  let v.UW2 = a:i   > 1    ? a:model.UW2->get(a:chars[a:i-2], 0) : 0
  let v.UW3 =                a:model.UW3->get(a:chars[a:i-1], 0)
  let v.UW4 =                a:model.UW4->get(a:chars[a:i  ], 0)
  let v.UW5 = a:i+1 < last ? a:model.UW5->get(a:chars[a:i+1], 0) : 0
  let v.UW6 = a:i+2 < last ? a:model.UW6->get(a:chars[a:i+2], 0) : 0

  let v.BW1 = a:i   > 2    ? a:model.BW1->get(join(a:chars[a:i-2 : a:i  ]), 0) : 0
  let v.BW2 = a:i   > 1    ? a:model.BW2->get(join(a:chars[a:i-1 : a:i+1]), 0) : 0
  let v.BW3 = a:i+1 < last ? a:model.BW3->get(join(a:chars[a:i   : a:i+2]), 0) : 0

  let v.TW1 = a:i   > 2    ? a:model.TW1->get(join(a:chars[a:i-3 : a:i  ]), 0) : 0
  let v.TW2 = a:i   > 1    ? a:model.TW2->get(join(a:chars[a:i-2 : a:i+1]), 0) : 0
  let v.TW3 = a:i+1 < last ? a:model.TW3->get(join(a:chars[a:i-1 : a:i+2]), 0) : 0
  let v.TW4 = a:i+2 < last ? a:model.TW4->get(join(a:chars[a:i   : a:i+3]), 0) : 0

  let total = 0
  for w in v->values()
    let total += w
  endfor
  let v._total = total
  return v
endfunction

function! budoux#parse(model, str)
  let chars = split(a:str, '\zs')
  if len(chars) == 0
      return []
  endif
  let chunks = [chars[0]]
  let last = len(chars)
  for i in range(1, last - 1)
    let v = budoux#score(a:model, chars, i)
    if v._total > a:model.base_score
      call add(chunks, chars[i])
    else
      let chunks[-1] .= chars[i]
    endif
  endfor
  return chunks
endfunction
