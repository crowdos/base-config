#!/bin/sh

# based on Debian /etc/init.d/kmod

load_module() {
  local module args
  module="$1"
  args="$2"

  /sbin/modprobe $module $args > /dev/null 2>&1 || true
}

modules_files() {
  local modules_load_dirs='/etc/modules-load.d /run/modules-load.d /lib/modules-load.d'
  local processed=' '

  for dir in $modules_load_dirs; do
    [ -d $dir ] || continue
    for file in $(/bin/run-parts --list --regex='\.conf$' $dir 2> /dev/null || true); do
      local base=${file##*/}
      if echo -n "$processed" | grep -qF " $base "; then
        continue
      fi

      processed="$processed$base "
      echo $file
    done
  done
}

files=$(modules_files)
if [ "$files" ] ; then
  grep -h '^[^#]' $files |
  while read module args; do
    [ "$module" ] || continue
    load_module "$module" "$args"
  done
fi
