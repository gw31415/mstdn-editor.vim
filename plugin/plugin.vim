nor <Plug>(mstdn-editor-open) <cmd>call mstdn#editor#open(<SID>get_user(), #{defaults: mstdn#timeline#status_defaults()})<cr>
let g:mstdn_editor_opener = '4new'
let g:mstdn_editor_defaultuser = v:null
function s:get_user() abort
	try
		return mstdn#timeline#user()
	cat /.*/
		if g:mstdn_editor_defaultuser != v:null
			retu g:mstdn_editor_defaultuser
		endi
		retu mstdn#user#login_users()[0]
	endt
endfunction
