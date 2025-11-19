#!/bin/sh

StartMessage()
{
    echo "Starting Dental Clinic Database Management System..."
    echo "Normalized Schema (3NF/BCNF) with Sequences"
    echo "Press any key to continue..."
    read -n 1
}


MainMenu()
{
    CHOICE=""
    while [ "$CHOICE" != "START" ]  
    do
        clear
        echo "================================================================="
        echo "| Oracle All Inclusive Tool |"
        echo "| Main Menu - Select Desired Operation(s): |"
        echo "| <CTRL-Z Anytime to Enter Interactive CMD Prompt> |"
        echo "-----------------------------------------------------------------"

        echo " $IS_SELECTEDM M) View Manual"
        echo " "
        echo " $IS_SELECTED1 1) Drop Tables"
        echo " $IS_SELECTED2 2) Create Tables"
        echo " $IS_SELECTED3 3) Populate Tables"
        echo " $IS_SELECTED4 4) Query Tables"
        echo " "
        echo " $IS_SELECTEDE E) End/Exit"
        echo "Choose: "
        
        read CHOICE
        
        if [ "$CHOICE" = "M" ]
        then
            echo "Please select any number from 1-4 or E to exit. "
            read -p "Press [Enter] to continue"
        elif [ "$CHOICE" = "1" ]
        then
            bash drop_tables.sh
            read -p "Press [Enter] to continue"
        elif [ "$CHOICE" = "2" ]
        then
            bash create_tables.sh
            read -p "Press [Enter] to continue"
        elif [ "$CHOICE" = "3" ]
        then
            bash populate_tables.sh
            read -p "Press [Enter] to continue"
        elif [ "$CHOICE" = "4" ]
        then
            bash queries.sh
            read -p "Press [Enter] to continue"
        elif [ "$CHOICE" = "E" ]
        then
            exit
        fi
    done
}

#--COMMENTS BLOCK--
# Main Program
#--COMMENTS BLOCK--
ProgramStart()
{
    StartMessage
    while true
    do
        MainMenu
    done
}

ProgramStart
