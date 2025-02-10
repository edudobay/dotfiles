alias gfa="git-allrepos -0 | xargs -0 -P7 -I\% bash -c 'git -C % fetch --prune || { echo -e \"\\e[1;31mFailed: %\\e[0;39m\"; false; }'"
alias gmall="git-allrepos -0 | xargs -0 -n1 -I\% bash -c 'echo %; git -C % merge --ff-only; echo'"
alias gf="git fetch --prune"
alias gs="git switch"

# So many aliases!!!1 (From oh-my-zsh git plugin)
unalias git-svn-dcommit-push glum gmom gmum g gam gama gamc gams gamscp gap gapa gapt gau gav gbs gbsb gbsg gbsr gbss 'gcan!' 'gcans!' gcd gcf gcl gcmsg 'gcn!' gcount gfg gga ghh gignore gignored gk gke gpristine gpu gpv gr gra grev grh grhh grm grmc grmv groh grrm grs grset grss grt gru grup grv gsb gsd gsh gsi gsps gsr gss gsta gstaa gstall gstc gstd gstl gstp gsts gstu gsu gts gtv gunignore gunwip gup gupa gupav gupv gwch gwip


git-delete-merged-branches() {
	local filename=$(mktemp --tmpdir merged-branches.XXXXXX)
	git branch --merged >"$filename" && \
		$EDITOR "$filename" && \
		xargs git branch -d <"$filename"
}

cpb() {
    echo -n $(git branch --show-current) | clipcopy
}
