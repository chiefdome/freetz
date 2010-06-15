#!/bin/sh
page="${FA_BASE}${FA_NEXT_PAGE}"
log_info "have to prepare page [$page]"
if [ -d "${page}.$FA_THEME" -o -d "${page}" ]; then
   log_info "have to process directory ..."
   base="${page}"
   if [ -d "${page}.$FA_THEME" ]; then
      base="${page}.$FA_THEME"
   fi
   log_info "directory is [$base]"
   echo '#!/usr/bin/haserl' > "$FA_WORK_FILE"
   for f in $base/*; do
      log_info "processing file [$f]"                   
      case $f in
      *.avm)
         ./webcm "getpage=$f" | grep -v '^#!' >> "$FA_WORK_FILE"
         ;;
      *.html)
         cat "$f" >> "$FA_WORK_FILE"
         ;;
      *.hsl)
         cat "$f" | grep -v '^#!' >> "$FA_WORK_FILE"
         ;;
      *.sh)
         $f >> "$FA_WORK_FILE"
         ;;
      esac
   done   
   chmod +x "$FA_WORK_FILE"
elif [ -s "${page}.avm" ]; then
   log_info "page [${page}] is avm-page"
   ./webcm "getpage=${page}.avm" | grep -v '^#!' > "$FA_WORK_FILE"
   chmod +x "$FA_WORK_FILE"
fi
