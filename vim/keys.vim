if !has("gui_running")

  "set <C-F1>=O1;5P
  "set <C-F2>=O1;5Q
  "set <C-F3>=O1;5R
  "set <C-F4>=O1;5S

  "set <C-S-F1>=O1;6P
  "set <C-S-F2>=O1;6Q
  "set <C-S-F3>=O1;6R
  "set <C-S-F4>=O1;6S

  set <S-F1>=[1;2P
  set <S-F2>=[1;2Q
  set <S-F3>=[1;2R
  set <S-F4>=[1;2S
  set <S-F5>=[15;2~
  set <S-F6>=[17;2~
  set <S-F7>=[18;2~
  set <S-F8>=[19;2~

  set <t_xl>=[1;3D
  set <t_xr>=[1;3C
  set <c-left>=[1;5D
  set <c-right>=[1;5C

  if strpart(&term, 0, 6) == "screen"
    set <t_kN>=[6;*~
    set <t_kP>=[5;*~
  endif
endif

