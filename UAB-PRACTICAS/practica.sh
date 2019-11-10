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

	local fitxer='netflix_unique.csv'

	if [ -f "preferencies" ]; then
		fitxer='filtrat_preferencies.csv'
	fi

	if [ ! -s "$fitxer" ]; then
		echo "No hi ha series que coincideixin amb les teves preferències"
		sleep 2
		return 0
	fi

	# escollir número aleatori entre 1 i la longitud del fitxer
	local index=$(( $RANDOM % $(wc -l < $fitxer) + 1 ))

	# obtenir la fila a l'index escollit
	local row=$( tail -$index $fitxer | head -1 )

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
				;;
				2)
					local min_rating=65
				;;
				3)
					local min_rating=75
				;;
				4)
					local min_rating=85
				;;
				5)
					local min_rating=95
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

		local max_rating=101

		# sortim si on es false
		# aixo es una guard clause
		# https://en.wikipedia.org/wiki/Guard_(computer_science)
		# https://www.artansoft.com/2017/01/guard-clauses-definicion-beneficios/
		if [ $on = false ];
		then
			return 0;
		fi

		# filtrar
		local filtered_series=$(filtrar_per_rating "$series" $min_rating $max_rating)

		local sorted_series=$(echo "$filtered_series" | sort -t ',' -n -k3)

		# donar format
		local formatted_series=$(format_series "$sorted_series")

		# mostrar
		prompt_less_insctructions
		sleep 5
		echo "$formatted_series" | column -t -s "," | less
	done
}

#
function criteris_de_cerca() {
	local on=true
	while $on
	do
		clear
		echo "--------------------------------------------------"
		echo " Criteris de cerca"
		echo "--------------------------------------------------"
		echo " 1. Modificar preferències"
		echo " 2. Eliminar preferències"
		echo " 3. Preferències actuals"
		echo " 4. Sortir"
		local opc
		read opc
		case $opc in
			1)
				modificar_preferencies
				aplicar_preferencies
			;;
			2)
				eliminar_preferencies
			;;
			3)
				mostrar_preferencies
			;;
			4)
				clear
				echo "Sortint"
				sleep 1
				on=false
			;;
			*)
		esac
	done
}

function modificar_preferencies() {
	clear
	echo "Si deixes l'espai en blanc, no s'aplicara com a criteri."$'\n'
	echo "Modificar Any"
	echo "Introdueix els anys separats per comes sense espais."
	local anys=$(head -1 preferencies 2> /dev/null || echo "")
	read -e -i "$anys" anys

	clear
	echo "Si deixes l'espai en blanc, no s'aplicara com a criteri."$'\n'
	echo "Modificar Ratings"
	echo "Introdueix els ratings separats per comes sense espais."
	echo "Els ratings disponibles són: PG-13, R, TV-14, TV-PG, TV-MA, TV-Y, NR, TV-Y7-FV, UR, G"
	local ratings=$(head -2 preferencies 2> /dev/null | tail -1 2> /dev/null || echo "")
	read -e -i "$ratings" ratings

	clear
	echo "Si deixes l'espai en blanc, no s'aplicara com a criteri."$'\n'
	echo "Modificar Stars"
	echo "Introdueix el valor entre l'1 i el 5 (ambdós inclosos)"
	local stars=$(head -3 preferencies 2> /dev/null | tail -1 2> /dev/null || echo "")
	read -e -i "$stars" stars

	echo -e "$anys\n$ratings\n$stars" > preferencies

	echo "Preferencies modificades"
}

function eliminar_preferencies() {
	clear
	rm preferencies 2> /dev/null
	echo "Preferències eliminades"
	sleep 3
}

function mostrar_preferencies() {
	clear
	# controlem si no existeixen les preferencies
	if [ ! -f "preferencies" ]; then
		echo "Encara no hi ha preferències."
		sleep 3
		return 0;
	fi

	# llegim les preferencies
	local anys=$(head -1 preferencies)
	local ratings=$(head -2 preferencies | tail -1)
	local stars=$(head -3 preferencies | tail -1)

	# mostrem les preferencies
	echo -e "Anys: $anys\nRatings: $ratings\nStars: $stars"
	sleep 3
}

function aplicar_preferencies() {
	echo "Aplicant preferències..."

	# recuperem les preferencies
	local anys=$(head -1 preferencies)
	local ratings=$(head -2 preferencies | tail -1)
	local stars=$(head -3 preferencies | tail -1)

	# recuperem les series del fitxer de series sense duplicats
	local series=$(cat netflix_unique.csv)

	local filtered_series=""
	IFS=$'\n'
	# per cada serie
	for serie in $series
	do
		# afafem els camps any, rating i user_rating
		local serie_any=$( echo $serie | cut -d',' -f5 )
		local serie_rating=$( echo $serie | cut -d',' -f2 )
		local serie_user_rating=$( echo $serie | cut -d',' -f6 )

		# aquestes variables indiquen si la serie compleix els requisits
		# per defecte no els compleix
		local any_valid=false
		local rating_valid=false
		local stars_valid=false

		IFS=,

		# si la preferencia d'anys no esta especificada
		# permetem que agafi tots els anys
		if [ "$anys" = "" ]; then
			any_valid=true
		else
			# mirem que l'any de la serie coincideixi amb un dels anys de les preferencies
			for any in $anys
			do
				if [ "$any" -eq "$serie_any" ]; then
					any_valid=true
					break
				fi
			done
		fi

		# si la preferencia de ratings no esta especificada
		# permetem que agafi tots els ratings
		if [ "$ratings" = "" ]; then
			rating_valid=true
		else
			# mirem que el rating sigui a les preferencies
			for rating in $ratings
			do
				if [ "$rating" = "$serie_rating" ]; then
					rating_valid=true
					break
				fi
			done
		fi

		if [ "$stars" = "" ]; then
			stars_valid=true
		else
			# ignorar les series que no tinguin user_rating
			if [ -z $serie_user_rating ]; then
				IFS=$'\n'
				continue
			fi
			# agafem el rating d'estrelles a partir del user_rating
			local serie_stars=$(rating_estrelles_from_rating $serie_user_rating)

			# mirem que el rating d'estrelles sigui a les preferències
			for star in $stars
			do
				if [ "$star" -eq "$serie_stars" ]; then
					stars_valid=true
					break
				fi
			done
		fi

		# si compleix les 3 condicions, afegim la serie a un acumulador
		if [ "$any_valid" = "true" ] && [ "$rating_valid" = "true" ] && [ "$stars_valid" = "true" ]; then
			filtered_series="$filtered_series""$serie"$'\n'
		fi

		IFS=$'\n'
	done

	# si no s'han trobat series ho avisem
	if [ "$filtered_series" = "" ]; then
		echo "No s'han trobat series per aquestes preferències."
	fi

	# guardem les series filtrades
	echo -n "$filtered_series" > 'filtrat_preferencies.csv'
}

function clean() {
	rm netflix_unique.csv 2> /dev/null
	rm filtrat_preferencies.csv 2> /dev/null
}

#Escull quina llista utlizar, la modificada(criteris de cerca) o la predeterminada(nomes els arxius unics)
tail +2 netflix.csv | sort -u > netflix_unique.csv

if [ -f "preferencies" ]; then
	aplicar_preferencies
fi

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

clean
