
let g:neocomplcache_jsx_executable_path = get(g:, "neocomplcache_jsx_executable_path", "jsx")
let s:source = {
      \ 'name': 'jsx_complete',
      \ 'kind': 'ftplugin',
      \ 'filetypes': { 'jsx': 1 },
      \ }

" Store plugin path, as this is available only when sourcing the file,
" not during a function call.
let s:plugin_path = escape(expand('<sfile>:p:h'), '\')


function! s:source.initialize()
	call neocomplcache#set_completion_length('jsx', 0)
endfunction

function! s:source.finalize()
endfunction


function! s:source.get_keyword_pos(cur_text)
	if neocomplcache#is_auto_complete()
				\ && a:cur_text !~ '\%(\.\)\%(\h\w*\)\?$'
		" auto complete is very slow!
		return -1
	endif

	let line = getline('.')

	let start = col('.') - 1
	let wsstart = start
	if line[wsstart - 1] =~ '\s'
		while wsstart > 0 && line[wsstart - 1] =~ '\s'
			let wsstart -= 1
		endwhile
	endif
	if line[wsstart - 1] =~ '[(,]'
		let b:should_overload = 1
		return wsstart
	endif
	let b:should_overload = 0
	while start > 0 && line[start - 1] =~ '\i'
		let start -= 1
	endwhile
	return start
endfunction

function! s:source.get_complete_words(cur_keyword_pos, cur_keyword_str)
	if bufname('%') == ''
		return []
	endif

	let buf = getline(1, '$')
	let tempfile = expand('%:p:h') . '/' . localtime() . expand('%:t')
	let pre_cmd = ""
	if neocomplcache#is_win()
		let tempfile = substitute(tempfile, '\\', '/', 'g')
	endif
	call writefile(buf, tempfile)
	let escaped_tempfile = shellescape(tempfile)

	let command = g:neocomplcache_jsx_executable_path
				\ . ' --complete '.line('.').":".(a:cur_keyword_pos)
				\ . " " . escaped_tempfile
	let result = system(command)

	sandbox let output = eval(result[ 0 : len(result) - 2])

	call delete(tempfile)
	
	return map(output, '{ "word" : v:val }')
endfunction

function! neocomplcache#sources#jsx_complete#define()
	return s:source
endfunction


