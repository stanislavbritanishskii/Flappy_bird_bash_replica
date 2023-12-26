#!/bin/bash

# set float separator to dot
LC_NUMERIC=C

# Hide cursor
tput civis
# Hide input
stty -echo
# Get amount of rows and columns
rows=$(stty size | cut -d " " -f1)
cols=$(stty size | cut -d " " -f2)
# Set player coordinate
x=$(($rows - 3))
y=10
x_speed=0
# Set wall parameters
wall1_y=$(($cols - 1))
wall_hole_height=20
wall_hole_pos=$(($RANDOM % $(($rows - $wall_hole_height))))
wall_speed=1

# Draw wall
draw_wall() {
	for ((i = 0; i <= $rows; i++)); do
		if [ $i -lt $wall_hole_pos ] || [ $i -ge $((wall_hole_pos + wall_hole_height)) ]; then
			# draws wall in red in background
			echo -en "\033[41m\033[$i;$(($wall1_y))H \033[m"
		fi
	done
}

# Recalculate wall position
move_wall() {
	wall1_y=$(echo "$wall1_y - $wall_speed" | bc)

	# If wall has reached left wall reset wall to right wall, decrease size of the hole and change it's position
	if [ $wall1_y -le 0 ]; then
		wall1_y=$(($cols - 1))
		wall_hole_height=$((wall_hole_height - 1))
		wall_hole_pos=$(($RANDOM % $(($rows - $wall_hole_height))))

	fi

}

# Checks if player is touching wall and exits
check_death() {
	# Checks if the wall has reached player
	if [ $y -ge $(($wall1_y - 6)) ] && [ $y -le $wall1_y ]; then
		# Getting local integer x value
		l_x=$(printf "%.0f" "$x")
		# Checking if player is touching the wall
		if [ $l_x -le $(($wall_hole_pos - 1)) ] || [ $l_x -ge $(($wall_hole_pos + $wall_hole_height - 2)) ]; then
			# Prints lost message
			echo -ne "\033[2J\033[$(($rows / 2));$(($cols / 2))H\033[31mYOU LOST\033[0;0H"
			# To show input after game
			stty echo
			# "Unhide" cursor
			tput cnorm
			# Exit without error
			exit 0
		fi

	fi

}

# Recalculates x position of player
recalculate_x() {
	# Moving x
	x=$(echo "$x - $x_speed" | bc)
	# Applying gravity
	x_speed=$(echo "$x_speed - 0.3" | bc)
	# Checking if player is on the ground
	if [ $(printf "%.0f" "$x") -ge $(($rows - 2)) ]; then
		x=$(($rows - 2))
		x_speed=0
	fi
}

# Draws player with open eyes
draw_char_closed_eyes() {
	echo -en "\033[34m"
	echo -en "\033[$1;$2H |  |"
	echo -en "\033[$(($1 + 1));$2H\    /"
	echo -en "\033[$(($1 + 2));$2H ---- "
}
# Draws player with closed eyes
draw_char() {
	echo -en "\033[94m"

	echo -en "\033[$1;$2H 0  0"
	echo -en "\033[$(($1 + 1));$2H\    /"
	echo -en "\033[$(($1 + 2));$2H ---- "
}

# Draws either player with open or with closed eyes based on time
draw_current_char() {

	if [ $(($(date +%s) % 2)) -eq 0 ]; then
		draw_char $1 $2
	else
		draw_char_closed_eyes $1 $2
	fi
}
# Clears the screen
clear_screen() {
	echo -en "\033[2J\033[0;1H"
}

# Main loop
while true; do
	# Reading character and making space a valid char
	IFS= read -n1 -s -t 0.001 val
	# Reading through all the rest of the characters if there were multiple keys pressed
	while read -n1 -t 0; do read -n1; done
	case $val in
	# Some old testing controls
	#        'w') x=$(($x - 1));;
	#        's') x=$(($x + 1));;
	#        'a') y=$(($y - 1));;
	#        'd') y=$(($y + 1));;
	' ') x_speed=2 ;;
		#        'q') break;;
	esac
	# Clearing screen
	clear_screen
	# Draws current character
	draw_current_char $(printf "%.0f" "$x") $y
	# Draws wall
	draw_wall
	#  Checks if the character has hit the wall
	check_death
	# Recalculates x position of the character
	recalculate_x
	# Recalculates position of the wall
	move_wall
	# Sleeps for a little while
	sleep 0.05

done

