function! ClearGui()
  set go-=T go-=m
endfunction

function! ParseFontSpec(font)
  let pos = match(a:font, '\v:h\zs\d+\ze(\.\d+)?$')
  if pos >= 0
    let fontsize = str2float(strpart(a:font, pos))
    let fontname = strpart(a:font, 0, pos - 2)
  else
    let fontsize = v:null
    let fontname = a:font
  endif
  return [fontsize, fontname]
endfunction

function! BuildFontSpec(fontname, fontsize)
  return printf("%s:h%.0f", a:fontname, a:fontsize)
endfunction

function! AddToFontSize(amount)
  let [fontSize, fontName] = ParseFontSpec(&guifont)
  if type(fontSize) == v:null
    let fontSize = 10
  endif

  let newFontSize = fontSize + a:amount
  if newFontSize < 1
    let newFontSize = 1
  endif

  let &guifont = BuildFontSpec(fontName, newFontSize)
  if !empty(&guifontwide)
    let [wideFontSize, wideFontName] = ParseFontSpec(&guifontwide)
    let &guifontwide = BuildFontSpec(wideFontName, newFontSize)
  endif
endfunction

function! ToggleToolAndMenuBar()
  if stridx(&guioptions, "T") != -1 || stridx(&guioptions, "m") != -1
    set guioptions-=T guioptions-=m
  else
    set guioptions+=Tm
  endif
endfunction
