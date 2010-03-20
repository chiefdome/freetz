frm_begin() {
    case $1 in
	mod) _frm_url=/conf ;;
	*)   _frm_url="/packages/$1" ;;
    esac
    readonly _frm_url
    echo "<form action='/freetz${_frm_url}' method='post'>"
}

frm_end() {
cat << EOF
<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>
</form>
<form class="btn" action="/freetz${_frm_url}?form=def_$1" method="post">
<div class="btn"><input type="submit" value="$(lang de:"Standard" en:"Defaults")"></div>
</form>
EOF
}
