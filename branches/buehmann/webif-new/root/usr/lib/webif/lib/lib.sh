# include a library only once
use() {
    local lib=$1
    let "_L_$lib++" || source "$ROOT/lib/$lib.sh"
}
