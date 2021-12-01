#!/bin/bash

# Variables

den=$1
mesiac=$2
rok=${3: -2}
pohlavie=$4
regex='^[0-9]+$'

if [[ $den -lt 10 ]]
then
	den="0$den"
fi

# Checks if input is female or male, if male then adds a digit 0 when argument less than 10 

if [[ $pohlavie == "M" ]]
then

	if [[ $mesiac -lt 10 ]]
	then 
		mesiac="0$mesiac"
	fi
else
	mesiac=$(($mesiac+50))

fi

# Lists all ID numbers divided by 11 

function writeAllNumbers(){
	for number in {0000..9999..1} ; do
		if [[ $(($rok$mesiac$den$number % 11)) -eq 0 ]]
		then
			echo $rok$mesiac$den"/"$number

		fi

	done
}

# Checks the count of arguments and if they are of required data type

if [ -z $5 ]
then
	if [ -z $4 ]
	then 
		echo "Zadal si nespravny pocet argumentov"
	else
		if [[ $1 =~ $regex ]] && [[ $2 =~ $regex ]] && [[ $3 =~ $regex ]]
		then
			if [[ $pohlavie == "M" ]] || [[ $pohlavie == "Z" ]]
			then
				writeAllNumbers
			else
				echo "Zadal si nespravne pohlavie"
			fi
		else
			echo "Na vstupe sa ockava datum vo formate DD MM RRRR P(ohlavie)"
		fi
	fi

else
	echo "Zadal si nespravny pocet argumentov"
fi

