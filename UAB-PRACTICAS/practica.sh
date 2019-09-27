#Imprimir el menu en pantalla
menu(){
	echo "1. Recomanació ràpida"
	echo "2. Llistar per any"
	echo "3. Llistar per rating"
	echo "4. Sortir"
}

#Imprimir "Recomanació ràpida"
recomanacio_rapida(){
	#grep -u netflix.csv > datos1.txt
	clear
	num1=$((( $RANDOM % 1001 )+1 ))
	tail -$num1 netflix.csv | head -1 > datos.txt
	cut -d',' -f1 datos.txt
	nom=$( cut -d',' -f1 datos.txt )
	any=$( cut -d',' -f5 datos.txt )
	rating=$( cut -d',' -f2 datos.txt )
	desc=$( cut -d',' -f3 datos.txt )
	echo "--------------------------------------------------"
	echo " Recomanació ràpida                               "
	echo "--------------------------------------------------"
    echo "                                                  "
	echo "$nom , $any"
	echo "$rating"
	echo "$desc"
	sleep 2
}

#Imprimir 
llistar_per_any(){
	clear
	#grep -u netflix.csv > datos1.txt
	echo "--------------------------------------------------"
	echo " Llistat per any"
	echo "--------------------------------------------------"
	echo "Any : "
	read any
	grep $any netflix.csv | cut -d',' -f1,5 > datos.txt
	less datos.txt
}



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
			clear
			echo "En desenvolupament"
			sleep 2
			clear
		;;
		4)
			clear
			echo "Adéu"
			sleep 0.5
			clear
			on=false
		;;
		*)
			clear
			echo "Error: $opc no es una opcion valida"
			sleep 1
	esac
done

