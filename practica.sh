#Imprimir el menu en pantalla
menu(){
	echo "1. Opcio 1."
	echo "2. Opcio 2."
	echo "3. Opcio 3."
}

#Imprimir el contenido de cada opcion
mostrar_opcion(){
	clear
	echo "La opcio $1 esta en desenvolupament"
	sleep 1
}

on=true
while $on
do
	clear
	menu
	read opc
	case $opc in 
		1)
			mostrar_opcion $opc
		;;
		2)
			mostrar_opcion $opc
		;;
		3)
			clear
			echo "Adios"
			on=false
		;;
		*)
			clear
			echo "Error: $opc no es una opcion valida"
			sleep 1
	esac
done

