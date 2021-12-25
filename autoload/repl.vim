function! s:on_exit(id, data, event) abort
  let s:is_repl_active = 0
endfunction

function! s:on_stdout(id, data, event) abort
  call repl#move_bottom()
endfunction

function! repl#open(cmd) abort
  let cur_winid = win_getid()

  vnew
  let option = {
        \ 'on_exit': function('s:on_exit'),
        \ 'on_stdout': function('s:on_stdout'),
        \ 'on_stderr': function('s:on_stdout'),
        \ }
  let s:repl_id = termopen(a:cmd, option)
  let s:repl_buffer = bufname()
  let s:is_repl_active = 1

  call win_gotoid(cur_winid)
endfunction

function! repl#info() abort
  let info = { 'jobid': s:repl_id, 'buffer': s:repl_buffer }
  return info
endfunction

function! repl#send(data) abort
  if get(s:, 'is_repl_active', 0)
    call chansend(s:repl_id, a:data)
  endif
endfunction


function! repl#sendln(data) abort
  if type(a:data) == v:t_string
    call repl#send(a:data . "\n")
  elseif type(a:data) == v:t_list
    call add(a:data, '')
    call repl#send(a:data)
  endif
endfunction


function! repl#send_curline() abort
  let line = getline('.')
  call repl#sendln(line)
endfunction


function! repl#send_visual() abort range
  let lines = getline(a:firstline, a:lastline)
  call repl#sendln(lines)
endfunction

function! repl#move_bottom() abort
  if exists('s:repl_buffer')
    let winid = bufwinid(s:repl_buffer)
    if winid != -1
      call win_execute(winid, '$')
    endif
  endif
endfunction

let s:input_buffer = 'REPL-Input'

function s:send_input() abort
  call repl#sendln(getline(2))
  bwipeout!
endfunction

function! repl#open_input() abort
  let winid = bufwinid(s:input_buffer)
  if winid != -1
    call win_gotoid(winid)
  else
    execute 'botright' '2split' s:input_buffer

    call setline(1, ['Input:', ''])
    call cursor(2, 0)

    nnoremap <silent> <buffer>
          \ <CR>
          \ :<C-u>call <SID>send_input()<CR>
    nnoremap <silent> <buffer>
          \ q
          \ :<C-u>bwipeout!<CR>
  endif
endfunction

function! repl#map_keys() abort
  nnoremap <silent> <LocalLeader>ss
        \ :<C-u>call repl#send_curline()<CR>
  vnoremap <silent> <LocalLeader>s
        \ :call repl#send_visual()<CR>
  nnoremap <silent> <LocalLeader>i
        \ :<C-u>:call repl#open_input()<CR>
  nnoremap <silent> <LocalLeader>cd
        \ :<C-u>:call repl#send("\<C-d>")<CR>
  nnoremap <silent> <LocalLeader>cc
        \ :<C-u>call repl#send("\<C-c>")<CR>
endfunction
