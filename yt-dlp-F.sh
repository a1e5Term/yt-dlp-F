#!/bin/bash

FILE=filefile.txt
PATHSAVE="$HOME/.local/bin/yt-dlp"

#Colours green, blue, yellow, lcyan, normal
COLOURS=('\033[32m' '\033[01;34m' '\e[1;33m' '\033[1;36m' '\e[0m')

function install_soft (){
	SOFT="$1"
	if ! command -v "$SOFT" >/dev/null 2>&1 ; then
		echo "Установить $SOFT? (y/n)"
		read a
		if [[ $a == "y" ]]; then
			
			echo -e ${COLOURS[0]}установка ${SOFT}${COLOURS[4]}
			
			if command -v apt &> /dev/null; then
				su -c "apt install \"$SOFT\" -y" -
				#sudo apt-get install "$SOFT"
			elif command -v dnf &> /dev/null; then
				sudo dnf install "$SOFT"
			elif command -v brew &> /dev/null; then
				brew install "$SOFT"
			else
				echo "Установщик пакетов не найден. Пожалуйста, установите \"$SOFT\" вручную."
			fi
		else
			echo "Установка отменена."
		fi
	fi  
}

function first () {

	[[ ! -x $PATHSAVE ]] &&	su -c "chmod a+rx \"$PATHSAVE\"" -

	LIST=()
	echo -e ${COLOURS[0]}вставить URL:${COLOURS[4]}
	read URL
	[[ -z $URL ]] && URL=""
	clear
	echo -e ${COLOURS[0]}URL:${COLOURS[4]}
	echo $URL
	
	echo
	

	if ! command -v fzf >/dev/null 2>&1 ; then
		echo -e "$URL\n"
		HAT=$(yt-dlp -F $URL | awk '/^ID/')
		echo -e "   $HAT"
		$PATHSAVE -F $URL | awk '/^-----------/{found=1; next} found' > $FILE
		second
		tree
	else
		TITLE=$(yt-dlp --get-title $URL)
		SELECT=$($PATHSAVE -F $URL | awk 'NR==7 {print; next} NR==8 {print; next} NR>8 {print NR-8, $0}' | fzf --reverse --header-lines=2 --header="$(printf "\n%s\n%s\n " "$URL" "$TITLE")" --no-info)

		PART=$(echo "$SELECT" | awk '{print $2}')
	fi

	#$PATHSAVE -F $URL | awk 'NR>=7'
	#SELECT=$($PATHSAVE -F $URL | awk 'NR>=7' | nl | fzf --reverse --header-lines=2 --header="$URL")
	#SELECT=$($PATHSAVE -F $URL | awk 'NR==7 {print; next} NR==8 {print; next} NR>8 {print NR-2, $0}' | fzf --reverse --header-lines=2 --header="$URL")
}

function second () {
	count=1
	IFS=$'\n'

	itemArray=()

	for item in $(cat $FILE); do
		echo -e "${COLOURS[2]}$count. ${COLOURS[4]}$item"  # Выводим номер и элемент

		itemArray+=("$item")  # Добавляем каждую строку в массив

		((count++))  # Увеличиваем счетчик
	done

	echo
}

function tree ()
{
	echo -e "${COLOURS[0]}ввод${COLOURS[4]}"
	read a
	PART=$(echo "${itemArray[$a]}" | awk '{print $1}')
}

function four (){
	$PATHSAVE -f $PART -o "$HOME/Videos/%(title)s.%(ext)s" $URL
}

function main (){
	
	install_soft "ffmpeg"
	install_soft "fzf"
	
	first
	four
	#rm $FILE
}

main
