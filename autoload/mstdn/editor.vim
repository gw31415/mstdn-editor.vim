function mstdn#editor#open(user) abort
	exe g:mstdn_editor_opener
	exe 'f mstdneditor://' .. a:user
	setl bt=acwrite bufhidden=wipe noswapfile
	let b:mstdn_editing_user = a:user
	autocmd BufWriteCmd <buffer> call s:send(str2nr(expand('<abuf>')))
	nn <buffer> <esc> <cmd>sil! q<cr>
endfunction

function s:send(edbufnr) abort
	let text = trim(join(getbufline(a:edbufnr, 1, '$'), "\n"))
	if text == ''
		echoerr 'Content is empty.'
		return
	endif
	call mstdn#request#post(getbufvar(a:edbufnr, 'mstdn_editing_user'), #{status: text})
	let old_undolevels = getbufvar(a:edbufnr, '&undolevels')
	call setbufvar(a:edbufnr, '&undolevels', -1)
	sil! %d _
	call setbufvar(a:edbufnr, '&undolevels', old_undolevels)
	unlet old_undolevels
	call setbufvar(a:edbufnr, '&modified', 0)
endfunction
