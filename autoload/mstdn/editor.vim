let s:file_prefix = 'mstdn-editor:'
let s:prefix_len = len(s:file_prefix)
let s:buffer_defaults = {}
let s:buffer_editing = {}

" open editor buffer
function mstdn#editor#open(user, opts = {}) abort
	let opts = extend(#{opener: g:mstdn_editor_opener, defaults: {}}, a:opts)
	exe opts.opener
	setl bt=acwrite bufhidden=wipe noswapfile
	let s:buffer_defaults[bufnr()] = opts.defaults
	call mstdn#editor#set_user(a:user)

	" initialize buffer
	call s:initialize(bufnr())

	autocmd BufWriteCmd <buffer> call s:send(str2nr(expand('<abuf>')))
	autocmd BufWipeout <buffer> call remove(s:buffer_defaults, str2nr(expand('<abuf>'))) | call remove(s:buffer_editing, str2nr(expand('<abuf>')))
	nn <buffer> <esc> <cmd>sil! q<cr>
endfunction

" set user to buffer
function mstdn#editor#set_user(user) abort
	if index(mstdn#user#login_users(), a:user) < 0
		throw 'user not found'
	elseif !has_key(s:buffer_defaults, '' .. bufnr())
		throw 'this is not mstdn-editor buffer'
	endif
	exe 'f ' .. s:file_prefix .. a:user
endfunction

" send status
function s:send(edbufnr) abort
	let text = trim(join(getbufline(a:edbufnr, 1, '$'), "\n"))
	if text == ''
		throw 'content is empty'
	endif
	let s:buffer_editing[a:edbufnr].status = text
	call mstdn#request#post(strpart(bufname(a:edbufnr), s:prefix_len), s:buffer_editing[a:edbufnr])

	" re-initialize buffer
	call s:initialize(a:edbufnr)
endfunction

" initialize buffer text
function s:initialize(edbufnr) abort
	let s:buffer_editing[bufnr()] = copy(s:buffer_defaults[bufnr()])

	let old_undolevels = getbufvar(a:edbufnr, '&undolevels')
	call setbufvar(a:edbufnr, '&undolevels', -1)
	sil! %d _
	if has_key(s:buffer_editing[a:edbufnr], 'status')
		call setbufline(a:edbufnr, 1, split(remove(s:buffer_editing[a:edbufnr], 'status'), '\n'))
	endif
	call setbufvar(a:edbufnr, '&undolevels', old_undolevels)
	call setbufvar(a:edbufnr, '&modified', 0)
endfunction
