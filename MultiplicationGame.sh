#!/usr/bin/env bash

#That remove the Delete key char so when prompted user *can* delete what they enter
stty erase ^H
#This set the score to 0 (dont cheat)
score=0
life=3
SCORE_FILE="$HOME/.config/MultiplicationCLI/bestscore"
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
    mkdir -p ~/.config/MultiplicationCLI/
fi
if [ ! -f "$SCORE_FILE" ]; then
    echo "0" > "$SCORE_FILE"
fi
best_score=$(cat "$SCORE_FILE")

#This function make a new config file located at /home/yourusername/MultiplicationCLI/config.conf
MakeANewConfig() {
    echo ""
    echo "Alright let's make that config!"
    echo "First of all, enter the multiplication tables you want"
    echo "In one of the following format : ranges like 0-12 OR specific tables like 4,6,7 OR both at the same time like 3,6-12" 
    echo "Note : You need to place it from smallest to greatest (ex. you can't do 3-7,2) and you can't enter floating numbers" 
    read -e -r -p "Now enter the tables: " tables
    # Cut the numbers to transform it
    # To a list
    # Ex 3-7 will become 3 4 5 6 7
    # Code from StackOverflow
    array=( "$(echo {1..100} | { cut -d" " -f"${tables// /,}"; } ) ")
    echo "The game will use the following numbers :" 
    echo {1..100} | { cut -d" " -f"${tables// /,}"; }
    read -e -r -p "Now, do you want only multiplications (m), only division (d) or both (b) ? [m/d/b] " operations
    # Saving the user's choice in the config file
    #echo {1..100} | { cut -d" " -f"${tables// /,}"; }  > ~/.config/MultiplicationCLI/config.conf
    echo "${array[*]}" | tr ' ' ',' > ~/.config/MultiplicationCLI/config.conf
    echo "$operations" >> ~/.config/MultiplicationCLI/config.conf
    echo ""
    echo "Right! Now we can start!"
    echo ""
}

#This function generate a multiplication with FirstNumber (from the array), SecondNumber from 0-12 and Result, the product of both
MakeAMultiplication(){
    #FirstNumber=${array[ $RANDOM % ${#array[@]} ]}
    FirstNumber=${array[$((RANDOM % ${#array[@]}))]}
    SecondNumber=$((RANDOM%13))
    Result=$(("$FirstNumber" * "$SecondNumber"))
    echo ""
    read -e -r -p "What does $FirstNumber x $SecondNumber do ? " response
    if [[ "$response" == "$Result" ]]; then
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
  
}

#This function generate a division by first doing (number from array) x (number 0-12), then asking to divide this number by the afformentionned number from 0-12.
MakeADivision(){
    SecondNumber=$((RANDOM%13))
    while [[ $SecondNumber -eq 0 ]]; do
        SecondNumber=$((RANDOM % 13))
    done
    echo "Debug: SecondNumber: $SecondNumber"
    #Result=${array[ $RANDOM % ${#array[@]} ]}
    Result=${array[$((RANDOM % ${#array[@]}))]}
    NumberToDivide=$((Result * SecondNumber))
    echo ""
    read -e -r -p "What does $NumberToDivide / $SecondNumber do ? " response
    if [[ "$response" == "$Result" ]]; then
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
    
   
}
# Welcome message, ask the user to clear the terminal for better visibility
# Set background color for a better style
tput setab 0
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
echo "by ${RED}@Hash-AK${NC}, on GitHub"
echo ""
echo "Coded for HackClub HighSeas 2024 (https://highseas.hackclub.com/)"
echo ""
echo "The terminal will clear for a better visibility, so you can see what the script is saying"
echo "This mean that all previous commands outputs will get cleared"
read -e -r -p "Is it ok with you [Y/N] ? " response
case "$response" in
    [yY][eE][sS]|[yY]) 
        echo "Clearing..."
        clear
        ;;
    *)
        echo "No problem I guess..."
        echo "This won't affect the script. The output will just be a little less focalized" 
        echo ""
        ;;
esac
echo "Now we can start..."
# Verify if the config file exist or not
# If it exist then prompt the user of they want to keep the current config
# Or make a new one with MakeANewConfig
if [[ -e ~/.config/MultiplicationCLI/config.conf ]]; then
    echo "Config file found!"
    echo "That mean that I can restore your previous"
    echo "choices, like which table to use and if you want"
    echo "mutliplication and/or division"
    echo ""
    echo "The current config contain the following information : "
    echo ""
    # Displays the content of the config file
    echo "Tables : ${GREEN}$(head -n 1 ~/.config/MultiplicationCLI/config.conf)${NC}"
    echo ""
    echo "Multiplication/Division/Both : ${GREEN}$(sed -n '2p' ~/.config/MultiplicationCLI/config.conf)${NC}"
    # REad user's entry
    read -e -r -p "Do you want to make a new one or keep this one? N = Make a new one K = keep that one [N/K] " response
    case "$response" in
    [kK][eE][sS]|[nN]) 
        MakeANewConfig
        ;;
    *)
        echo "Ok using that one then!" 
        ;;
esac
# If no config was found
# Then default to make a new one
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
#array=( "$(head -n 1 ~/.config/MultiplicationCLI/config.conf ) ")
IFS=',' read -ra array <<< "$(head -n 1 ~/.config/MultiplicationCLI/config.conf)"
operations=$(sed -n '2p' ~/.config/MultiplicationCLI/config.conf)
#D Print the number of life
echo "You have 3 lives"
start_time=$(date +%s.%N)
#If user  want both give them what they want
if [[ "$operations" == "b" ]]; then
    while [[ "$life" -gt "0" ]]; do    
        OpRandom=0
        OpRandom=$(( RANDOM % 2 ))
        #Choose randomly either multiplication o/r division 
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
if [ "$score" -gt "$best_score" ]; then
    echo "You beat the current highscore!"
    echo "Old highscore : $best_score"
    echo "Your new highscore is $score"
    best_score=$score
    echo "$best_score" > "$SCORE_FILE"
else 
    echo "Best score : $best_score"
fi
end_time=$(date +%s.%N)
echo ""
# Calculate the amount of time spent
# Then round it to 2 number after the .
runtime=$(printf "%.2f" "$(echo "$end_time - $start_time" | bc)")
echo "Total time spent on the game: $runtime seconds"


