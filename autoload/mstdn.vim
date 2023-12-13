function s:send(edbufnr) abort
	let text = trim(join(getbufline(a:edbufnr, 1, '$'), "\n"))
	if text == ''
		return
	endif
	call mstdn#request#post(b:mstdn#user, #{status: text})
	let old_undolevels = &l:undolevels
	setlocal undolevels=-1
	sil! %d _
	let &l:undolevels = old_undolevels
	unlet old_undolevels
	setl nomodified
endfunction

function mstdn#open_editor() abort
	4new mstdn-editor
	setl bt=acwrite bufhidden=wipe noswapfile
	nn <buffer> <esc> <cmd>sil! q<cr>
	let b:mstdn#user = mstdn#timeline#user()
	autocmd BufWriteCmd <buffer><cmd>call <sid>send(str2nr(expand('<abuf>')))<cr>
endfunction
