let s:file_prefix = 'mstdn-editor:'
let s:prefix_len = len(s:file_prefix)

let s:buffer_defaults = {}
let s:buffer_editing = {}

function s:create_virtual_filename(edbufnr, newUser = v:null) abort
	let username = a:newUser != v:null ? a:newUser : mstdn#editor#get_username(a:edbufnr)
	let params = mstdn#editor#get_statusparams(a:edbufnr)

	let f = s:file_prefix .. username
	if has_key(params, 'in_reply_to_id')
		let f .= '?in_reply_to_id=' .. params.in_reply_to_id
	endif
	return f
endfunction

function mstdn#editor#get_username(edbufnr = bufnr()) abort
	if !has_key(s:buffer_defaults, '' .. a:edbufnr)
		throw 'this is not mstdn-editor buffer'
	endif
	let username_and_query = strpart(bufname(a:edbufnr), s:prefix_len)
	" First ? Get before
	let username = matchstr(username_and_query, '^\zs[^?]*')
	return username
endfunction

" get CreateStatusParams
function mstdn#editor#get_statusparams(edbufnr = bufnr()) abort
	if !has_key(s:buffer_defaults, '' .. a:edbufnr)
		throw 'this is not mstdn-editor buffer'
	endif
	let text = trim(join(getbufline(a:edbufnr, 1, '$'), "\n"))
	return extendnew(s:buffer_editing[a:edbufnr], #{status: text})
endfunction

" update CreateStatusParams
function mstdn#editor#update_statusparams(obj, edbufnr = bufnr()) abort
	call extend(s:buffer_editing[a:edbufnr], a:obj)
	exe 'f ' .. s:create_virtual_filename(a:edbufnr)
	doautocmd User MstdnEditorUpdateParams
endfunction

" open editor buffer
function mstdn#editor#open(user, opts = {}) abort
	let opts = extend(#{opener: g:mstdn_editor_opener, defaults: {}}, a:opts)
	exe opts.opener
	setl bt=acwrite bufhidden=wipe noswapfile
	let s:buffer_defaults[bufnr()] = opts.defaults
	let s:buffer_editing[bufnr()] = opts.defaults
	call mstdn#editor#set_user(a:user)
	doautocmd User MstdnEditorOpen

	" initialize buffer
	call s:initialize(bufnr())

	autocmd BufWriteCmd <buffer> call s:send(str2nr(expand('<abuf>')))
	autocmd BufWipeout <buffer> call remove(s:buffer_defaults, str2nr(expand('<abuf>'))) | call remove(s:buffer_editing, str2nr(expand('<abuf>')))
	nn <buffer> <esc> <cmd>sil! q<cr>
endfunction

" set user to buffer
function mstdn#editor#set_user(user, edbufnr = bufnr()) abort
	if index(mstdn#user#login_users(), a:user) < 0
		throw 'user not found'
	elseif !has_key(s:buffer_defaults, '' .. a:edbufnr)
		throw 'this is not mstdn-editor buffer'
	endif
	exe 'f ' .. s:create_virtual_filename(a:edbufnr, a:user)
endfunction

" send status
function s:send(edbufnr) abort
	let sp = mstdn#editor#get_statusparams(a:edbufnr)
	if sp.status == ''
		throw 'content is empty'
	endif
	call mstdn#request#post(mstdn#editor#get_username(a:edbufnr), sp)

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
