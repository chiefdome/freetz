frm_begin() {
    local url
    case $1 in
	mod) url=/conf ;;
	*)   url="/packages/$1" ;;
    esac
    echo "<form action='/freetz${url}' method='post'>"
}

frm_end() {
cat << EOF
<div class="btn"><input type="submit" value="$(lang de:"&Uuml;bernehmen" en:"Apply")"></div>
</form>
<form class="btn" action="/cgi-bin/save.cgi?form=def_$1" method="post">
<div class="btn"><input type="submit" value="$(lang de:"Standard" en:"Defaults")"></div>
</form>
EOF
}
