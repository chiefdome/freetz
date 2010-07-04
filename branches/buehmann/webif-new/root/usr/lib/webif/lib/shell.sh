# prints $1 with all shell meta-characters escaped
shell_escape() {
    echo "'${1//'/'\\''}'"
}

