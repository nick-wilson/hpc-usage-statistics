if [ $UID -gt 10000 ] ; then
 if [ ${_USAGE_MESSAGE:-0} -eq 0 ] ; then
  if [ ! -e "$HOME/.hushlogin" ] ; then
   tty > /dev/null 2>&1 && /app/pbs/bin/myusage 1>&2
  fi
 fi
fi
_USAGE_MESSAGE=1 ; export _USAGE_MESSAGE
