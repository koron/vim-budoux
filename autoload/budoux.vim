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
  let model.base_score = -sum / 2
  let model.parse = function('s:ModelParse')
  return model
endfunction

function! budoux#model_path(name)
  return expand(expand('<script>:p:h:h') . '/models/' . a:name, v:true)
endfunction

function! budoux#load_japanese_model()
  return budoux#load_model(budoux#model_path('ja.json'))
endfunction

function! budoux#parse(model, str)
  let chars = split(a:str, '\zs')
  if len(chars) == 0
      return []
  endif
  let chunks = [chars[0]]
  let last = len(chars)
  for i in range(1, last - 1)
    let v = a:model.base_score

    if i > 2
      let v += a:model.UW1->get(chars[i-3], 0)
    endif
    if i > 1
      let v += a:model.UW2->get(chars[i-2], 0)
    endif
    let v += a:model.UW3->get(chars[i-1], 0)
    let v += a:model.UW4->get(chars[i], 0)
    if i + 1 < last
      let v += a:model.UW5->get(chars[i+1], 0)
    endif
    if i + 2 < last
      let v += a:model.UW5->get(chars[i+2], 0)
    endif

    if i > 1
      let v += a:model.BW1->get(join(chars[i-2:i], ''), 0)
    endif
    let v += a:model.BW2->get(join(chars[i-1:i+1], ''), 0)
    if i + 1 < last
      let v += a:model.BW3->get(join(chars[i:i+2], ''), 0)
    endif

    if i > 2
      let v += a:model.TW1->get(join(chars[i-3:i], ''), 0)
    endif
    if i > 1
      let v += a:model.TW2->get(join(chars[i-2:i+1], ''), 0)
    endif
    if i + 1 < last
      let v += a:model.TW3->get(join(chars[i-1:i+2], ''), 0)
    endif
    if i + 2 < last
      let v += a:model.TW4->get(join(chars[i:i+3], ''), 0)
    endif

    if v > 0
      call add(chunks, chars[i])
    else
      let chunks[-1] .= chars[i]
    endif
  endfor
  return chunks
endfunction
