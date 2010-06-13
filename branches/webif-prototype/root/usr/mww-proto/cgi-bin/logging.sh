# Log informational messages
log_info() {
    logger -t "freetz[$$]" -p user.info "$@"
}
