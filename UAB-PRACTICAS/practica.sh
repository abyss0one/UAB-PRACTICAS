#A netflix_unique.csv estan guardats els noms unics de l'arxiu netflix.csv
#datos.txt es un arxiu que guarda informació temporal
#Imprimir el menu en pantalla
function menu() {
	echo " FAKE                                   "
	echo " _   _ _____ _____ _____ _     _____  __"
	echo "| \ | | ____|_   _|  ___| |   |_ _\ \/ /"
	echo "|  \| |  _|   | | | |_  | |    | | \  / "
	echo "| |\  | |___  | | |  _| | |___ | | /  \ "
	echo "|_| \_|_____| |_| |_|   |_____|___/_/\_\ "
	echo "________________________________________"
	echo "|                                      |"
	echo "|        1. Recomanació ràpida         |"
	echo "|        2. Llistar per any            |"
	echo "|        3. Llistar per rating         |"
	echo "|        4. Criteris de cerca          |"
	echo "|        5. Sortir                     |"
	echo "|______________________________________|"
}

# aquesta funció mostra les instruccions de la comanda less
function prompt_less_insctructions() {
	echo "Utilitza les fletxes ↑ i ↓ per navegar per la llista."
	echo "Per sortir presiona Q."
}

#Imprimir "Recomanació ràpida"
function recomanacio_rapida() {
	clear
	# escollir número aleatori entre 1 i la longitud del fitxer
	local index=$(( $RANDOM % $(wc -l < netflix_unique.csv) + 1 ))

	# obtenir la fila a l'index escollit
	local row=$( tail -$index netflix_unique.csv | head -1 )

	# extreure els camps de la fila
	local nom=$( echo $row | cut -d',' -f1 )
	local any=$( echo $row | cut -d',' -f5 )
	local rating=$( echo $row | cut -d',' -f2 )
	local desc=$( echo $row | cut -d',' -f3 )

	# mostrar recomanació
	echo "--------------------------------------------------"
	echo " Recomanació ràpida                               "
	echo "--------------------------------------------------"
	echo "                                                  "
	echo "$nom , $any"
	echo "$rating"
	echo "$desc"
	sleep 2
}

#Imprimir "Llistar per any"
function llistar_per_any() {
	clear
	echo "--------------------------------------------------"
	echo " Llistat per any"
	echo "--------------------------------------------------"
	# llegim l'any
	local any
	read -p "Introdueix l'any: " any
	clear
	prompt_less_insctructions
	sleep 5
	# filtrar per any, obtenir les columnes 1 i 2, formatar en columna i fer un less
	# regex: les linies que acabin per l'any
	# i dos camps numerics que poden o no tenir un valor, separats per comes
	grep ",$any,[0-9]*,[0-9]*$" netflix_unique.csv | cut -d',' -f1,2 | column -t -s "," | less
}

# genera la cadena d'estrelles a mostrar a partir d'un rating de 1 a 5
function estrelles_per_numero() {
	# variable acumuladora de la cadena d'estrelles
	local estrelles=""
	# calcular quant falta per arribar desde el rating donat a 5
	# per saber quants espais cal posar davant i derrere
  local remaining=$((5-$1))
	local padding=""
	# creem una cadena amb tants espais com calguin
  for i in $( seq 1 $remaining)
	do
		padding="$padding "
	done

	# creem una cadena amb (estrelles i espais), s'afegeix una per cada rating donat
	# una estrella per rating 1, dos per rating 2, etc
	for i in $( seq 1 $1)
	do
		estrelles="$estrelles* "
	done

	# es construeix el resultat final
	echo "[$padding $estrelles$padding]"
}


#Conseguir el programa/peli
function opc_ordre_llista() {
	local series="$1"
	local rating_num="$2"

	clear
	echo "1. Ordenar de major a menor"
	echo "2. Ordenar de menor a major"
	local option
	read option

	if [ "$option" -ne "1" ] && [ "$option" -ne "2" ];
	then
		#clear
		echo "Error: $option no es una opcion valida"
		sleep 5
		return 1
	fi

	if [ "$option" -eq "1" ];
	then
		series=$(echo "$series" | sort -k3 -nr -t',')
	else
		series=$(echo "$series" | sort -k3 -n -t',')
	fi

	clear
	local formatted_series=""
	IFS=$'\n'
	for serie in $series
	do
		local rating=$(echo $serie | cut -d',' -f3)
		local title=$(echo $serie | cut -d',' -f1,2)
		local stars=$(estrelles_per_numero $rating_num)
		formatted_series="$formatted_series"$'\n'"$stars,$title"
	done
	prompt_less_insctructions
	sleep 5
	echo "$formatted_series" | column -t -s "," | less
}

# filtrar per rating
# $1 han de ser les series amb el format <any>,<any>,<rating>, és a dir el rating a la columna 3
# $2 i $3 han de ser el rating minim i el rating maxim respectivament
function filtrar_per_rating() {
  local series="$1"
	local min_rating="$2"
	local max_rating="$3"

	local filtered_series=""
	IFS=$'\n'
	for serie in $series
	do
		local rating=$( echo $serie | cut -d',' -f3 )
		# es comprova que el rating existeixi
		# i que estigui entre el minim i el maxim
		if [ ! -z $rating ] && [ $rating -ge $min_rating ] && [ $rating -lt $max_rating ];
		then
			filtered_series="$filtered_series"$'\n'"$serie"
		fi
	done
	echo "$filtered_series"
}

# donar el format correcte a les series per mostrar-les
function format_series() {
	local series="$1"
	# donar format
	local formatted_series=""
	IFS=$'\n'
	for serie in $series
	do
		# obtenim els camps desitjats
		local rating=$(echo $serie | cut -d',' -f3)
		local title=$(echo $serie | cut -d',' -f1,2)
		# obtenim el rating de 1 a 5 a partir del de 0 a 100
		local rating_num=$(rating_estrelles_from_rating $rating)
		# obtenim les estrelles a partir del rating de 1 a 5
		local stars=$(estrelles_per_numero $rating_num)
		formatted_series="$formatted_series"$'\n'"$stars,$title"
	done

	echo "$formatted_series"
}

function rating_range_from_stars() {
	local stars="$1"
	case $option in
		1)
			local min_rating=0
			local max_rating=65
		;;
		2)
			local min_rating=65
			local max_rating=75
		;;
		3)
			local min_rating=75
			local max_rating=85
		;;
		4)
			local min_rating=85
			local max_rating=95
		;;
		5)
			local min_rating=95
			local max_rating=999
		;;
		*)
			return 1
	esac

	echo $min_rating:$max_rating
}

# obtenir el rating de 1 a 5 a partir del rating de 0 a 100
function rating_estrelles_from_rating() {
	local rating="$1"

	if [ $rating -lt 65 ];
	then
		echo 1
	elif [ $rating -lt 75 ];
	then
		echo 2
	elif [ $rating -lt 85 ];
	then
		echo 3
	elif [ $rating -lt 95 ];
	then
		echo 4
	else
		echo 5
	fi
}

#Imprimir "Llistar per rating"
function llistar_per_rating() {
	local on=true
	while $on
	do
		local option min_rating max_rating series
		local valid_option=false
		series=$(cut -d',' -f1,5,6 netflix_unique.csv)
		while [ $valid_option = false ]
		do
			clear
			echo "--------------------------------------------------"
			echo " Llistat per rating"
			echo "--------------------------------------------------"
			echo " 1. [     *     ]"
			echo " 2. [    * *    ]"
			echo " 3. [   * * *   ]"
			echo " 4. [  * * * *  ]"
			echo " 5. [ * * * * * ]"
			echo " 6. Sortir"
			valid_option=true
			read option
			# si la opcio esta entre el 1 i el 5, obtenim el rating minim i el maxim
			# si no, es 6, per tant sortim, o es una opcio incorrecta
			case $option in
				1)
					local min_rating=0
					local max_rating=65
				;;
				2)
					local min_rating=65
					local max_rating=75
				;;
				3)
					local min_rating=75
					local max_rating=85
				;;
				4)
					local min_rating=85
					local max_rating=95
				;;
				5)
					local min_rating=95
					local max_rating=999
				;;
				6)
					clear
					echo "Sortint"
					sleep 1
					local on=false
				;;
				*)
					clear
					valid_option=false
					echo "Error: $option no és una opció vàlida"
					sleep 1
			esac
		done

		local max_rating=999

		if [ $on = false ];
		then
			return 0;
		fi

		# filtrar
		filtered_series=$(filtrar_per_rating "$series" $min_rating $max_rating)
		# donar format
		formatted_series=$(format_series "$filtered_series")

		# mostrar
		prompt_less_insctructions
		sleep 5
		echo "$formatted_series" | column -t -s "," | less
	done
}

#
function criteris_de_cerca() {
	on3=true
	while $on3
	do
		clear
		echo "--------------------------------------------------"
		echo " Criteris de cerca"
		echo "--------------------------------------------------"
		echo " 1. Modificar preferències"
		echo " 2. Eliminar preferències"
		echo " 3. Preferències actuals"
		echo " 4. Sortir"
		read opc
		case $opc in
			1)
				modificar_pref
			;;
			2)
				tail +2 netflix.csv | sort -u > netflix_unique.csv
				echo 0 > pref.txt
			;;
			3)
			;;
			4)
				clear
				echo "Sortint"
				sleep 1
				on3=false
			;;
			*)
		esac
	done
}

function modificar_pref() {
	clear
	on4=true
	while $on4 in
	do
		echo "Modificar :"
		echo "1. Any"
		echo "2. Rating"
		echo "3. Estrelles"
		echo "4. Sortir"
		read opc
		case $opc in
			1)
				clear
				cat netflix_unique.csv > datosPref.txt
				cat netflix_unique.csv > netflix_unique.csv
				read -p "Des de : " any1
				read -p "Fins a : " any2
				while [ $any1 -le $any2 ]
				do
					grep ,$any1, datosPref.txt >> netflix_unique.csv
					any1=$(($any1+1))
				done
				echo 1 > pref.txt
				less netflix_unique.csv
				clear
			;;
			2)
				clear
				cat netflix_unique.csv > datosPref.txt
				cat netflix_unique.csv > netflix_unique.csv
				echo "[PG-13, R, TV-14, TV-PG, TV-MA, TV-Y, NR, TV-Y7-FV,UR,G]"
				read -p "Escriu els ratings que vulguis separats per un espai : " ratings
				for rat in $ratings
				do
					egrep ,$rat, datosPref.txt >> netflix_unique.csv
				done
				echo 1 > pref.txt
				less netflix_unique.csv
				clear
			;;
			3)
			;;
			4)
				clear
				echo "Sortint"
				sleep 1
				on4=false
			;;
			*)
		esac
	done
}

#Escull quina llista utlizar, la modificada(criteris de cerca) o la predeterminada(nomes els arxius unics)
tail +2 netflix.csv | sort -u > netflix_unique.csv

#Bucle principal
#La variable on ens fa entrar i sortir del bucle while
on=true
while $on
do
	clear
	menu
	read opc
	case $opc in
		1)
			recomanacio_rapida
		;;
		2)
			llistar_per_any
		;;
		3)
			llistar_per_rating
		;;
		4)
			criteris_de_cerca
		;;
		5)
			clear
			echo "Adeu"
			sleep 0.15
			#Ara fem que on sigui false per sortir del bucle while
			on=false
		;;
		*)
			clear
			echo "Error: $opc no es una opcion valida"
			sleep 1
	esac
done
