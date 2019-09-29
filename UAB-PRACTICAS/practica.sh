#A datos1.txt estan guardats els noms unics de l'arxiu netflix.csv
#datos.txt es un arxiu que guarda informació temporal
#Imprimir el menu en pantalla
menu(){
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
	echo "|        4. Sortir                     |"
	echo "|______________________________________|"
}
#Treu els repetits de la llista
sort -u netflix.csv > datos1.txt

#Imprimir "Recomanació ràpida"
	#A datos.txt esat guardada l'informació del programa/peli que s'ha extret de datos1.txt
recomanacio_rapida(){
clear
num1=$((( $RANDOM % 502 )+1 ))
tail -$num1 datos1.txt | head -1 > datos.txt
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

#Imprimir "Llistar per any"
llistar_per_any(){
clear
echo "--------------------------------------------------"
echo " Llistat per any"
echo "--------------------------------------------------"
echo "Any : "
read any1
grep $any1 datos1.txt | cut -d',' -f1,2 > datos.txt
clear
echo "Utilitza les fletxes ↑ i ↓ per navegar per la llista."
echo "Per sortir presiona Q."
sleep 5
less datos.txt
}

#Conseguir el programa/peli
opc_ordre_llista(){
clear
echo "1. Endreçar de major a menor "
echo "2. Endreçar de menor a major"
read num3
clear
case $num3 in
	1)
		sort -k3 -nr -t',' datos2.txt > datos3.txt
		clear
		cut -d, -f1,2,3 datos3.txt > datos.txt
		clear
		cat rating$1.txt > rating.txt
		paste -d, rating.txt datos.txt | grep "[0-9]$" > datos3.txt
		echo "Utilitza les fletxes ↑ i ↓ per navegar per la llista."
		echo "Per sortir presiona Q."
		sleep 5
		less datos3.txt
	;;
	2)
		
		cut -d, -f1,2,3 datos2.txt > datos.txt
		clear
		cat rating$1.txt > rating.txt
		paste -d, rating.txt datos.txt | grep "[0-9]$" > datos3.txt
		echo "Utilitza les fletxes ↑ i ↓ per navegar per la llista."
		echo "Per sortir presiona Q."
		sleep 5
		less datos3.txt
	;;
	*)
		clear
		echo "Error: $num3 no es una opcion valida"
		sleep 1
	esac
}

#Imprimir "Llistar per rating"
llistar_per_rating(){
on2=true
while $on2
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
	read num2
	case $num2 in
		1)
			clear
			sort -k6 -t',' datos1.txt
			clear
			cut -d',' -f1,5,6 datos1.txt > datos.txt
			clear
			grep "[5-6][0-9]$" datos.txt | grep -v "[6][5-9]$" | sort -k3 -t',' > datos2.txt
			opc_ordre_llista $num2
		;;
		2)
			sort -k6 -t',' datos1.txt
			clear
			cut -d',' -f1,5,6 datos1.txt > datos.txt 
			clear	
			grep "[6-7][0-9]$" datos.txt | grep -v "[6][0-4]$" | grep -v "[7][5-9]$" | sort -k3 -t',' > datos2.txt
			opc_ordre_llista $num2
		;;
		3)
			sort -k6 -t',' datos1.txt
			clear
			cut -d',' -f1,5,6 datos1.txt > datos.txt
			clear
			grep "[7-8][0-9]$" datos.txt | grep -v "[7][0-4]$" | grep -v "[8][5-9]$" | sort -k3 -t',' > datos2.txt
			opc_ordre_llista $num2
		;;
		4)
			sort -k6 -t',' datos1.txt
			clear
			cut -d',' -f1,5,6 datos1.txt > datos.txt
			clear
			grep "[8-9][0-9]$" datos.txt | grep -v "[8][0-4]$" | grep -v "[9][5-9]$" | sort -k3 -t',' > datos2.txt
			opc_ordre_llista $num2
		;;
		5)
			sort -k6 -t',' datos1.txt
			clear
			cut -d',' -f1,5,6 datos1.txt > datos.txt
			clear
			grep "[9][5-9]$" datos.txt | sort -k3 -t',' > datos2.txt
			opc_ordre_llista $num2
		;;
		6)
			clear
			echo "Sortint"
			sleep 1
			on2=false
		;;
		*)
			clear
			echo "Error: $num2 no es una opcion valida"
			sleep 1
	esac
done
}


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

