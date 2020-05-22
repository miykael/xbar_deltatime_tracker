#!/usr/bin/env bash

# <bitbar.title>Track Time Delta</bitbar.title>
# <bitbar.version>v0.1</bitbar.version>
# <bitbar.author>Michael Notter</bitbar.author>
# <bitbar.author.github>miykael</bitbar.author.github>
# <bitbar.desc>Computes Time Delta to previous Timestamp</bitbar.desc>
# <bitbar.dependencies>bash</bitbar.dependencies>

# Specify working file for time deltas
FILENAMES='/tmp/timedeltas.rst'
TRACKERSTATUS='/tmp/tracker_on'
TEMPFILE='/tmp/temp.rst'

# Define duration (in seconds) for color switches
YELLOWSWITCH=$((30*60))
REDSWITCH=$((45*60))

# Maximum lenght of tracks
NMAX=6

# Create timedeltas logfile if it doesn't exist
if [[ ! -f $FILENAMES ]]
then
  date +"%s" > $FILENAMES
  date +"%s" >> $FILENAMES
fi

# Define clock icon
icon='iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAAxklEQVQ4jcXRMU6CQRAF4C8WeAYbQfAOQkdDvIOeRbgEEbiIF5GGhAIsjHoDKix2EjbwL5uYEF8zO28mb97MckEssY/4Z+xrDVcN3B0W2Ea+whQ3GNYcPeIHL+iihV7kn/gOkUZ08YWHjFtn737UOyWBRUzKcXyDMeYlgY9wcU7g3uE2J9hJO+d4P8qvo6/ooFcqZg42OZF/4xueKgLP0deIjnTlfqE+iPrtuQmjaBpL67Qk25PgRxWHoI2ZdO1dxNfa5P/DL1ATJzlH6JmYAAAAAElFTkSuQmCC'

# Update timedelta file content
if [ "$1" = 'update_deltas' ]
then

  # Add new timestamp to file
  date +"%s" >> $FILENAMES
  tail -n $NMAX $FILENAMES > $TEMPFILE
  mv $TEMPFILE $FILENAMES

  # Creat tracker status file
  touch -a $TRACKERSTATUS
  exit 0
fi

# Turn tracker off
if [ "$1" = 'tracker_off' ]
then
  date +"%s" >> $FILENAMES
  tail -n $NMAX $FILENAMES > $TEMPFILE
  mv $TEMPFILE $FILENAMES
  
  # Remove tracker status file if exist
  if [ -f $TRACKERSTATUS ] ; then
    rm $TRACKERSTATUS
  fi
  exit 0
fi

# Get Running Delta to first entry
NLINES=`cat $FILENAMES | wc -l`
stop=`date +"%s"`
start=`sed "${NLINES}q;d" $FILENAMES`
delta=$((stop-start))
delta_now=`echo $delta | awk '{printf "%01d:%02d min\n", $1/3600, ($1/60)%60}'`

# Specify in which color to write time delta
RED='1;31'
GREEN='1;32'
YELLOW='1;33'
BLUE='1;36'

if [ "$delta" -lt  "$YELLOWSWITCH" ]; then
  COLOR=$GREEN
elif [ "$delta" -lt  "$REDSWITCH" ]; then
  COLOR=$YELLOW
else
  COLOR=$RED
fi

# Create primary output
output="\033[${COLOR}m${delta_now}\033[0m | templateImage='$icon'"

# Check if tracker is on or off
if [ ! -f $TRACKERSTATUS ] ; then
  output="∞"
fi

output="${output}\n---\n"

# Go through file and return time deltas
for N in `seq $NLINES -1 2`
do

  # Extract timestamps for differenc computation
  stop=`sed "${N}q;d" $FILENAMES`
  start=`sed "$((N-1))q;d" $FILENAMES`

  # Compute delta
  delta=$((stop-start))
  new_delta=`echo $delta | awk '{printf "%02d:%02d:%02d\n", $1/3600, ($1/60)%60, $1%60}'`
  output="${output}\nt-$((NLINES-N+1)): ${new_delta}"

done

echo -e "$output"

echo "---"
echo "Update Timedelta | bash='$0' param1=update_deltas terminal=false"
echo "Stop Tracker | bash='$0' param1=tracker_off terminal=false"
