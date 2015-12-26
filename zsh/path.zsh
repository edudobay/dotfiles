_path_print_usage() {
cat <<EOF
usage: path <command> [<args>]
Display and modify the executable search path.

Available commands are:

   help
            show this usage help
   show                                 (aliases: list, ls, print, dump)
            print the search path in vertical format
   remove INDEX...                                           (alias: rm)
            remove one or more directories by index
   append DIR...                                            (alias: add)
            add directories after last entry
   prepend DIR...
            add directories before current entry
   insert INDEX DIR...                                      (alias: ins)
            add directories starting at the specified position

Note: all indices are 1-based, as can be seen in the 'show' subcommand.
EOF
}

_path_show() {
   local i=1
   while [[ $i -le $#path ]]; do
      print "[$i]" ${path[$i]}
      let i++
   done
}

_path_remove_indices() {
   local i indices
   # arguments sorted in *descending* numerical order
   indices=(${(On)@})

   for i in $indices; do
      path[$i]=()
   done
}

_path_append() {
   path+=($@)
}

_path_prepend() {
   path=($@ $path)
}

_path_insert() {
   local pos=$1
   shift
   path[$pos]=($@ $path[$pos])
}

path() {
   if [[ $# -eq 0 ]]; then
      _path_show
      return
   else
      case $1 in
         show|list|ls|print|dump)
            _path_show ;;
         rm|remove)
            _path_remove_indices $@ ;;
         add|append)
            _path_append $@ ;;
         prepend)
            _path_prepend $@ ;;
         ins|insert)
            _path_insert $@ ;;
         help)
            _path_print_usage ;;
         *)
            _path_print_usage
            return 1
            ;;
      esac
   fi
}

