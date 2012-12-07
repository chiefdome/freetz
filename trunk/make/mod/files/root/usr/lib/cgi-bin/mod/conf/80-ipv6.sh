
sec_begin 'IPv6'
cat << EOF

<p>
$(lang de:"Interfaces IPv6-Adressen zuweisen" en:"Assign IPv6 adresses to interfaces").<br>
$(lang de:"Syntax" en:"Syntax"): <interface> <IPv6><br>
$(lang de:"Beispiel" en:"Example"): lan fd21:23c2:dd2f::1/64<br>
</p>
<p><textarea name="ipv6_assign" rows="5" cols="50" maxlength="255">$(html "$MOD_IPV6_ASSIGN")</textarea></p>

cgi_print_checkbox_p "ipv6_forward" "$MOD_IPV6_FORWARD" \
	"$(lang de:"Forwarding aktivieren." en:"Enable forwarding.")"

EOF
sec_end
