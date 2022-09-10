function error()
{
    if [ ! -z "$1" ]
    then
      echo "$1"
    fi
    exit 1
}

if [ -z $SQUID_CONFIG ]
then
  error "SQUID_CONFIG environment variable is required."
fi

echo "$SQUID_CONFIG" | base64 -d > squid.conf

files=$(echo "$FILES" | tr ";" "\n")
for file in $files
do
  name="$(cut -d':' -f1 <<<"$file")"
  content="$(cut -d':' -f2 <<<"$file")"
  if [ -f "$name" ]
  then
    error "File $name already exists, please choose different name."
  fi
  echo "$content" | base64 -d > "$name"
done

/usr/local/squid/sbin/squid start -f squid.conf

echo "* * * * * /rotate_access_logs_and_cleanup.sh" | crontab -
service cron restart

tail -F /usr/local/squid/var/logs/access.log
