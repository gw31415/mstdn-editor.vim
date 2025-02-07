nor <Plug>(mstdn-editor-open) <cmd>call mstdn#editor#open(<SID>get_user(), #{defaults: mstdn#timeline#status_defaults()})<cr>
nor <Plug>(mstdn-editor-open-reply) <cmd>call mstdn#editor#open(<SID>get_user(), #{defaults: <SID>status_defaults_reply()})<cr>

let g:mstdn_editor_opener = '4new'
let g:mstdn_editor_defaultuser = v:null
fun s:get_user() abort
	try
		return mstdn#timeline#user()
	cat /.*/
		if g:mstdn_editor_defaultuser != v:null
			retu g:mstdn_editor_defaultuser
		endi
		retu mstdn#user#login_users()[0]
	endt
endf

fun s:status_defaults_reply() abort
	let status = mstdn#timeline#status()
	let id = status['id']
	let acct = status['account']['acct']

	return #{in_reply_to_id: id, status: " @". acct}
endf
