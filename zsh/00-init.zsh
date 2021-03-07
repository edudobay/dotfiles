for dir in /code /Volumes/Code; do
	if [[ -d $dir ]]; then
		CODE_ROOT=$dir
	fi
done

autoload -Uz compinit && compinit
autoload -U bashcompinit && bashcompinit
