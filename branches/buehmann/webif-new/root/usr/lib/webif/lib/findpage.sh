# find the longest match of $path in the page directory
find_page() {
    local path=$1 page_dir tail segment extended page=

    # FIXME: validate path
    # FIXME: normalize path

    # FIXME: conf
    page_dir="$ROOT/page"

    if [ -d "${page_dir}$path" ]; then
	page=${path%/}
    else
	tail=$path
	while true; do
	    case $tail in
		/?*)
		    segment=${tail#/}
		    segment="/${segment%%/*}"
		    tail=${tail#"$segment"}
		    extended="$page$segment"
		    if [ -d "${page_dir}$extended" ]; then
			page=$extended
		    else
			break
		    fi
		    ;;
		/|"") 
		    break
		    ;;
		*)
		    echo "Unexpected path '$path'" >&2
		    return 1
		    ;;
	    esac
	done
    fi

    echo "$page"
    return 0
}
