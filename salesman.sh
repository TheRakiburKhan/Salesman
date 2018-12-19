#!/bin/bash

#................................"Create Event" Option.............................
function cr_eve
{

MYSQL=`which mysql`

yad --form --center --field="Event Date":DT --field="Event Description" --title "Create Event" --text "Create New Event Here:" --date-format="%Y-%m-%d" --button="Create":0 --button=gtk-cancel:1 > /tmp/entries 

date_input=`cut -d "|" -f 1 /tmp/entries`
eve=`cut -d "|" -f 2 /tmp/entries`


a=`$MYSQL test -u test -Bse "SELECT MAX(id) FROM events"`
a=$(($a+1))
$MYSQL test -u test -e "INSERT INTO events VALUES ($a, '$date_input','$eve');"
   
if [ $? -eq 0 ]
then
    yad --center --width=300 --height=50 --image="gtk-info" --text="\nData Added Successfully" --no-buttons
else
    yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nProblem in Adding Data" --no-buttons
fi

}
#..................................................................................




#.............................Check Today's Events Option...............................................
function show_eve
{

today_date=`date -I`
MYSQL=`which mysql`

$MYSQL test -u test -Ne "SELECT event_desc FROM events WHERE date='$today_date'"|tr '\t' '\n'|yad --center --width 300 --height 200 --text-info --justify="CENTER" --fontname="luxi-serif" --title "Today's($today_date) Events" > /tmp/entries 
}
#........................................................................................................




#.................................."Next" Option (in Filtered Event).......................................
function next_eve
{

MYSQL=`which mysql`
$MYSQL test -u test -Ne "SELECT date, event_desc FROM events WHERE date >= CURDATE() ORDER BY date"|tr '\t' '\n'|yad --center --list --no-selection--grid-lines="VERTICAL" --column "Date		" --column "Event"   --title "Next Events" --height 300 --width 300 --button="Back":3 > /tmp/entries

if [ $? -eq 3 ]
then
  inner_option 
fi

}
#..........................................................................................................





#................................"Edit Event" Option.........................................................
function all_eve
{

MYSQL=`which mysql`
$MYSQL test -u test -Ne "SELECT id, date, event_desc FROM events ORDER BY date"|tr '\t' '\n'|yad --center --list --column "ID	" --column "Date		" --column "Event" --text "" --title "Edit Current Events" --height 300 --width 300 --button="gtk-edit":0 --button="gtk-delete":2 --button="Back":3 --hide-column=1 > /tmp/entries

button_choice=$?

ide=`cut -d "|" -f 1 /tmp/entries`
date_input=`cut -d "|" -f 2 /tmp/entries`
eve=`cut -d "|" -f 3 /tmp/entries`


if [ $button_choice -eq 0 ]
then
   yad --center --form --field="Event Date":DT --field="Event Description" "$date_input" "$eve" --title "Update Event" --text "Update Event Here:" --date-format="%Y-%m-%d" --button="Update":0 --button=gtk-cancel:1 > /tmp/entries
   update_choice=$?


   date_update=`cut -d "|" -f 1 /tmp/entries`
   eve_update=`cut -d "|" -f 2 /tmp/entries`
   
   if [[ $? -eq 0 && $update_choice -eq 0 ]]
   then
       $MYSQL test -u test -e "UPDATE events SET date='$date_update' WHERE id=$ide"
       $MYSQL test -u test -e "UPDATE events SET event_desc='$eve_update' WHERE id=$ide"
       yad --center --width=300 --height=50 --image="gtk-info" --text="\nData Updated Successfully" --no-buttons
   else
       yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nProblem in Updating Data" --no-buttons
   fi
elif [ $button_choice -eq 2 ]
then 
   
   $MYSQL test -u test -e "DELETE FROM events WHERE id=$ide"
   
   if [ $? -eq 0 ]
   then
       yad --center --width=300 --height=50 --image="gtk-info" --text="\nData Deleted Successfully" --no-buttons
   else
       yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nProblem in Deleting Data" --no-buttons
   fi
else
    inner_option
    
fi

}
#...........................................................................................................



#......................................"This Month" Option (in Filtered Event)................................
function monthly_eve
{

MYSQL=`which mysql`
$MYSQL test -u test -Ne "SELECT date, event_desc FROM events WHERE MONTH(date) = MONTH(CURDATE()) ORDER BY date"|tr '\t' '\n'|yad --center --list --no-selection--grid-lines="VERTICAL" --column "Date		" --column "Event"   --title "This Month Events" --height 300 --width 300 --button="Back":3 > /tmp/entries

if [ $? -eq 3 ]
then
  inner_option 
fi

}
#...........................................................................................................





#................................"This Year" Option (in filtered event).....................................
function yearly_eve
{

MYSQL=`which mysql`
$MYSQL test -u test -Ne "SELECT date, event_desc FROM events WHERE YEAR(date) = YEAR(CURDATE()) ORDER BY date"|tr '\t' '\n'|yad --center --list --no-selection--grid-lines="VERTICAL" --column "Date		" --column "Event"   --title "This Year Events" --height 300 --width 300 --button="Back":3 > /tmp/entries

if [ $? -eq 3 ]
then
  inner_option 
fi

}
#............................................................................................................




#....................................."Filtered Event" option................................................
function inner_option
{
 
yad --center --width 250 --height 250 --list --text "Select an Option:" --title "Choose to Filter" --radiolist --column "SELECT" --column "OPTION" TRUE "Next" FALSE "This Month" FALSE "This Year" FALSE "Back" --button="Choose":0 --button="gtk-cancel":1 > /tmp/entries 
op=`cut -d "|" -f 2 /tmp/entries`

case "${op}" in
    "This Month" )
           monthly_eve;;
    "This Year" )
           yearly_eve;;
    "Next")
           next_eve;;
    "Back")
           continue;;
esac
}
#............................................................................................................




#..........................................Main Menu.........................................................
while true
do

 yad --center --width 250 --height 250 --list --text "Select an Option:" --title "Main Menu" --radiolist --column "SELECT" --column "OPTION" TRUE "Create Event" FALSE "Check Today's Event" FALSE "Filtered Event" FALSE "Edit Event" FALSE "Exit" --no-selection --button="Choose":0 --button="gtk-cancel":1 > /tmp/entries
choice=`cut -d "|" -f 2 /tmp/entries`

    case "${choice}" in
       "Create Event" )
             cr_eve;;
       "Check Today's Event" )
             show_eve;;
       "Filtered Event")
             inner_option;;
       "Edit Event")
           all_eve;;
        *)
            break;;
     esac

if [ $? -eq 255 ]
then
   break
fi

done
#.............................................................................................................
