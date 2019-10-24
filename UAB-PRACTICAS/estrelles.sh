function estrelles_per_numero() {
	local estrelles=" "
  local remaining=$((5-$1))
  for i in $( seq 1 $remaining)
	do
		estrelles="$estrelles "
	done

	for i in $( seq 1 $1)
	do
		estrelles="$estrelles* "
	done

  for i in $( seq 1 $remaining)
  do
    estrelles="$estrelles "
  done

	echo "[$estrelles]"
}

echo "aaaaa"
estrelles_per_numero $1
