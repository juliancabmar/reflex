#Change Path to app path
cd /data/data/com.termux/files/home/tools/reflex
#Import functions
source ./functions
# Import config values
source ./config
# Verify if has new records on record path and if is some add to dbFile with the default average
addNews $recordsPath $dbFile $defaultAverage
# Wellcome message
echo "Wellcome to REFLEX"
# Ask to enter categories separated by comma and press enter (empty = all)
echo -ne "Enter categories separated by comma and press enter (empty = all)\nCategories: "
read categories
counter=0
# Start Loop
while true; do
    # Filter dbFile with categories and send value to currentDb variable
    currentDb=$(filterByCategories $dbFile $categories)
    # Wait with a prompt till the user is ready to begin
    getInput "Press any char when you are ready to begin..."
    # Sort db by average (high to low) <<<A>>>
    currentDb=$(sortDb "$currentDb")
    # Get the answer of the top item from db
    correctAnswer=$(echo $currentDb | cut -d "#" -f 2)
    # Get the $averageTime of the top item from db
    currentAverage=$(getAverageTime "$currentDb")
    # Create audio file list
    audioFileList=$(createAudioFileList "$currentDb" $audioFileExtension $recordsPath)
    # Play the first file on db list
    playFirstFile "$audioFileList" $recordsPath
    # Get the current date miliseconds
    startTime=$(($(date +%s%N)/1000000))
    # Show "Click any char for response"
    getInput "Press any char for response..."
    # Get the timeElapsed
    timeElapsed=$(( $(($(date +%s%N)/1000000)) - $startTime ))
    # Ask if the response was correct
    echo
    getInput "Press any char for see the answer..."
    echo -e "\nAnswer: $correctAnswer"
    read -n1 -p "You answer right?(y/n): " answer
    # If the response was correct
    if [[ "$answer" == "y" ]]; then
        currentAverage=$(echo "($currentAverage + $timeElapsed)/2" | bc | awk '{printf "%.0f\n", $0}')
        # Increase counter
        counter=$(($counter + 1))
    else
        currentAverage=$(echo "($currentAverage * (1 + $penalty))" | bc | awk '{printf "%.0f\n", $0}')
    fi
    # Update db with the new average
    updateDb "$(echo "$currentDb" | head -1 | cut -d " " -f 1,2)" $dbFile $currentAverage "$correctAnswer"
    # Clean Screen
    clear
    # Show the counter
    echo -e "\nReflex count: $counter"
# End Loop
done
