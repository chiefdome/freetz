use logging
use shell

generate_page() {
    local page=$1
    local tmp_file="${SESSION:-/tmp}/page-$$"
    trace pagegen "Preparing page [$page]:"

    # FIXME: theme selection
    # local THEME=dummy
    # if base="${page}.$THEME" && [ -d "${base}" ] ||
    #	base="${page}" && [ -d "$base" ]; then
    local base=${page}

    local n=0 f func
    for f in $base/*.avm; do
	[ -e "$f" ] || continue
	func="__print_avm_$n"
	echo "$func() { %><? include '$f' ?><% }"
	let n++
    done > "$tmp_file.avm"

    # optimize processing when no haserl run is required
    local haserl=false
    {
	echo "<%" # may be overwritten below if not needed
	if [ $n -gt 0 ]; then
	    haserl=true
	    trace pagegen "  preprocessing $n AVM parts"
	    webcm getpage="$tmp_file.avm"
	fi
	n=0
	for f in $base/[^+.]*; do
	    trace pagegen "  processing part [$f]"			  
	    case $f in
		*.avm)
		    func="__print_avm_$n"; let n++
		    echo "$func"
		    ;;
		*.html)	echo "cat $(shell_escape "$f")" ;;
		*.hsl)	echo "%><%in $f %><%"; haserl=true ;;
		*.sh)	echo "( source $(shell_escape "$f") )" ;;
		*)	
		    if [ -d "$f" ]; then
			: # skip it
		    elif [ -x "$f" ]; then
			echo "$(shell_escape "$f")"
		    else
			warn pagegen "Don't know what to do with $f"
		    fi
		    ;;
	    esac
	done 
	$haserl && echo "%>"
    } > "$tmp_file"  
    if ! $haserl; then
	echo "# " 1<> "$tmp_file" # overwrite "<%"
    fi

    trace pagegen "Delivering page [$page]"
    if $haserl; then
	haserl --accept-none "$tmp_file" < /dev/null 
    else
	( source "$tmp_file" )
    fi
    # FIXME: only for debugging
    local ext
    for ext in "" ".avm"; do
	mv "$tmp_file$ext" "${SESSION:-/tmp}/page-latest$ext"
    done
}
