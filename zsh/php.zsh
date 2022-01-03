_find_composer_root() {
    for dir in ~/.composer ~/.config/composer; do
        if [[ -d $dir && -d $dir/vendor/bin ]]; then
            COMPOSER_ROOT=$dir
            return 0
        fi
    done
    return 1
}

[[ -f ~/.cache/dotfiles/php_versions.sh ]] && source ~/.cache/dotfiles/php_versions.sh || true
if [[ ${PHP_DIRS+x} = '' ]]; then # empty
    export COMPOSER_BIN=$(which composer)
    eval "$(~/dotfiles/python/dotfiles/php_versions.py init)"
fi

# TODO:
chphp() {
    new_path=$(~/dotfiles/python/dotfiles/php_versions.py switch "$1") || return 2
    PATH=$new_path
}

_find_composer_root && \
    path+=($COMPOSER_ROOT/vendor/bin)

# Path for current project
path+=(./vendor/bin)
