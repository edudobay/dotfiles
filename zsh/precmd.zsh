precmd() {
    # Show at mose 2 leading path components
    local dirname=${PWD%/*}
    local basename=${PWD##*/}

    local dirbasename=${dirname##*/}
    local rest='…'

    [[ -z $dirname ]] && rest=''
    [[ $dirname = "/$dirbasename" ]] && rest='/'

    settitle "$rest$dirbasename/$basename"
}
