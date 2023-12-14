let s:file_prefix = 'mstdn-editor:'
let s:prefix_len = len(s:file_prefix)

" open editor buffer
function mstdn#editor#open(user, opts = {}) abort
	let opts = extend(#{ opener: g:mstdn_editor_opener, defaults: #{} }, a:opts)
	exe opts.opener
	setl bt=acwrite bufhidden=wipe noswapfile
	call s:set_user(a:user)

	" Insert default status
	let b:mstdn_editing_status = opts.defaults
	let text = v:null
	if has_key(b:mstdn_editing_status, 'status')
		let text = remove(b:mstdn_editing_status, 'status')
	endif
	call s:init_buftxt(bufnr(), text)

	autocmd BufWriteCmd <buffer> call s:send(str2nr(expand('<abuf>')))
	nn <buffer> <esc> <cmd>sil! q<cr>
endfunction

" set user to buffer
function s:set_user(user) abort
	if index(mstdn#user#login_users(), a:user) < 0
		throw 'user not found'
	endif
	exe 'f ' .. s:file_prefix .. a:user
endfunction

" send status
function s:send(edbufnr) abort
	let text = trim(join(getbufline(a:edbufnr, 1, '$'), "\n"))
	if text == ''
		throw 'content is empty'
	endif
	let b:mstdn_editing_status.status = text
	call mstdn#request#post(strpart(bufname(a:edbufnr), s:prefix_len), b:mstdn_editing_status)
	call s:init_buftxt(a:edbufnr)
endfunction

" initialize buffer text
function s:init_buftxt(bufnr, text = v:null) abort
	let old_undolevels = getbufvar(a:bufnr, '&undolevels')
	call setbufvar(a:bufnr, '&undolevels', -1)
	sil! %d _
	if a:text != v:null
		call setbufline(a:bufnr, 1, split(a:text, '\n'))
	endif
	call setbufvar(a:bufnr, '&undolevels', old_undolevels)
	call setbufvar(a:bufnr, '&modified', 0)
endfunction
