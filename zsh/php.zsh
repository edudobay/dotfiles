_find_composer_root() {
    for dir in ~/.composer ~/.config/composer; do
        if [[ -d $dir && -d $dir/vendor/bin ]]; then
            COMPOSER_ROOT=$dir
            return 0
        fi
    done
    return 1
}

_find_composer_root && \
    path+=($COMPOSER_ROOT/vendor/bin)

# Path for current project
path+=(./vendor/bin)
