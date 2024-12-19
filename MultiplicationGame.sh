#!/bin/bash

#That remove the Delete key char so when prompted user *can* delete what they enter
stty erase ^H
#This set the score to 0 (dont cheat)
score=0
life=3
#This setup the colors with tput and if its not present it use ANSI colors
if command -v tput >/dev/null 2>&1; then
    # Define colors using tput
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    BLUE=$(tput setaf 4)
    NC=$(tput sgr0)  # Reset color
else
    # Fallback to ANSI escape sequences if tput is not available
    RED='\033[31m'
    GREEN='\033[32m'
    BLUE='\033[34m'
    NC='\033[0m'  # Reset color
fi
if [[ ! -d ~/.config/MultiplicationCLI/ ]]; then
    mkdir ~/.config/MultiplicationCLI/
fi
#This function make a new config file located at /home/yourusername/MultiplicationCLI/config.conf
MakeANewConfig() {
    echo ""
    echo "First of all, enter the multiplication tables you want"
    echo "In one of the following format : ranges like 0-12 OR specific tables like 4,6,7 OR both at the same time like 3,6-12" 
    echo "Note : You need to place it from smallest to greatest (ex. you can't do 3-7,2) and you can't enter floating numbers" 
    read -e -r -p "Now enter the tables: " tables
    array=( $(echo {1..100} | { cut -d" " -f"${tables// /,}"; } ) )
    echo "The game will use the following numbers :" 
    echo {1..100} | { cut -d" " -f"${tables// /,}"; }
    read -e -r -p "Now, do you want only multiplications (m), only division (d) or both (b) ? [m/d/b] " operations
    echo {1..100} | { cut -d" " -f"${tables// /,}"; }  > ~/.config/MultiplicationCLI/config.conf
    echo $operations >> ~/.config/MultiplicationCLI/config.conf
    echo ""
    echo "Right! Now we can start!"
    echo ""
}

#This function generate a multiplication with FirstNumber (from the array), SecondNumber from 0-12 and Result, the product of both
MakeAMultiplication(){
    FirstNumber=${array[ $RANDOM % ${#array[@]} ]}
    SecondNumber=$(($RANDOM%13))
    Result=$(($FirstNumber * $SecondNumber))
    echo ""
    read -e -r -p "What does $FirstNumber x $SecondNumber do ? " response
    if [[ $response == "$Result" ]]; then
        echo "${GREEN}You're right!${NC}"
        score=$((score+1))
        echo ""
        echo "${GREEN}Your score is $score ! Keep going! ${NC}"

    else
        echo "${RED}No... it's $Result ${NC}"
        life=$((life-1))
        echo ""
        if [[ "$life" -gt "0" ]]; then
            echo "${RED}You have $life live(s) left... ${NC}"
        fi
    fi
    #echo $FirstNumber 
    #echo $SecondNumber
    #echo $Result
}

#This function generate a division by first doing (number from array) x (number 0-12), then asking to divide this number by the afformentionned number from 0-12.
MakeADivision(){
    SecondNumber=$(($RANDOM%13))
    while [[ $SecondNumber -eq 0 ]]; do
        SecondNumber=$(($RANDOM % 13))
    done
    Result=${array[ $RANDOM % ${#array[@]} ]}
    NumberToDivide=$(($Result * $SecondNumber))
    echo ""
    read -e -r -p "What does $NumberToDivide / $SecondNumber do ? " response
    if [[ $response == "$Result" ]]; then
        echo "${GREEN}You're right!${NC}"
        score=$((score+1))
        echo ""
        echo "${GREEN}Your score is $score ! Keep going! ${NC}"


    else
        echo "${RED}No... it's $Result${NC}"
        life=$((life-1))
        echo ""
        if [[ "$life" -gt "0" ]]; then
            echo "${RED}You have $life live(s) left... ${NC}"
        fi
    fi
    
    #echo $NumberToDivide
    #echo $SecondNumber
    #echo $Result
}
#Welcome message, ask the user to clear the terminal for better visibility
echo "${BLUE}" 

echo "  __  __       _ _   _       _ _           _   _              _____ _      _____ ";
echo " |  \/  |     | | | (_)     | (_)         | | (_)            / ____| |    |_   _|";
echo " | \  / |_   _| | |_ _ _ __ | |_  ___ __ _| |_ _  ___  _ __ | |    | |      | |  ";
echo " | |\/| | | | | | __| | '_ \| | |/ __/ _\` | __| |/ _ \| '_ \| |    | |      | |  ";
echo " | |  | | |_| | | |_| | |_) | | | (_| (_| | |_| | (_) | | | | |____| |____ _| |_ ";
echo " |_|  |_|\__,_|_|\__|_| .__/|_|_|\___\__,_|\__|_|\___/|_| |_|\_____|______|_____|";
echo "                      | |                                                        ";
echo "                      |_|                                                        ";

echo "${NC}"
echo "MultiplicationCLI : a Bash multiplication & division game"
echo ""
echo "by @Hash-AK, on GitHub"
echo ""
echo "Coded for HackClub HighSeas 2024 (https://highseas.hackclub.com/)"
echo ""
read -e -r -p "The terminal will clear for a better visibility. Is it ok with you [Y/N] ? " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        clear
        ;;
    *)
        echo "No problem I guess..." 
        echo ""
        ;;
esac
echo "Now we can start..."
#Verify if the config file 

if [[ -e ~/.config/MultiplicationCLI/config.conf ]]; then
    echo "Config file found"
    echo ""
    read -e -r -p "Do you want to make a new one? [Y/N] " response
    case "$response" in
    [yY][eE][sS]|[yY]) 
        MakeANewConfig
        ;;
    *)
        echo "Ok using that one then!" 
        ;;
esac
else
    echo "No config file found... Let's make one!"
    echo ""
    MakeANewConfig
fi
#Tell the user how to fix a corrupted config file (why would it even be corrupted...? Who is going to manually modify it?)
echo ""
echo "If there's errors related to the config file, just delete it"
echo "By typing (in annother terminal) 'rm $HOME/.config/MultiplicationCLI/config.conf'"
echo ""
#Load the config file (even if its corrupted)
array=( $(head -n 1 ~/.config/MultiplicationCLI/config.conf ) )
operations=$(sed -n '2p' ~/.config/MultiplicationCLI/config.conf)
#Do exactly what it say : priting that you have 3 lives
echo "You have 3 lives"
#Man the game have more lives than us
start_time=$(date +%s.%N)
#If user  want both give them what they want
if [[ "$operations" == "b" ]]; then
    while [[ "$life" -gt "0" ]]; do    
        OpRandom=0
        OpRandom=$(( RANDOM % 2 ))
        #Choose randomly either multiplication or division 
        if [[ "$OpRandom" == "0" ]]; then
            MakeAMultiplication
        else 
            MakeADivision
        fi
    done
    #If user only want multiplication give them what they want
elif [[ "$operations" == "m" ]]; then
    while [[ "$life" -gt "0" ]]; do    
       MakeAMultiplication
    done
    #If user only want division give them what they want
elif [[ "$operations" == "d" ]]; then
    while [[ "$life" -gt "0" ]]; do    
        MakeADivision
    done
fi
#Game over message with score and runtime
echo "${RED}Game Over! Your score is : $score ! ${NC}"
end_time=$(date +%s.%N)
echo ""
runtime=$( echo "$end_time - $start_time" | bc )
echo "Total time spent on the game.: $runtime seconds"
