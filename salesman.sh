#!/bin/bash

#................................"Add Delivery Task" Option.............................
function add_delivery
{

MYSQL=`which mysql`

yad --form --height 700 --width 600 --center --field="Customer Name" --field="Customer Address" --field="Phone" --field="Product Details" --field="Payment" --field="Delivery Date":DT --title "Add Deliery Task" --text "Add new delivery task here:" --date-format="%Y-%m-%d" --button="Add":0 --button=gtk-cancel:1 > /tmp/entries 

cus_name=`cut -d "|" -f 1 /tmp/entries`
cus_address=`cut -d "|" -f 2 /tmp/entries`
cus_phone=`cut -d "|" -f 3 /tmp/entries`
product_details=`cut -d "|" -f 4 /tmp/entries`
payment=`cut -d "|" -f 5 /tmp/entries`
date_input=`cut -d "|" -f 6 /tmp/entries`
state=Pending


a=`$MYSQL salesman -u personalproject -Bse "SELECT MAX(order_id) FROM customer"`
a=$(($a+1))
$MYSQL salesman -u personalproject -e "INSERT INTO customer VALUES ($a, '$cus_name', '$cus_address', '$cus_phone', '$product_details', '$payment', '$date_input', '$state');"
   
if [ $? -eq 0 ]
then
    yad --center --width=300 --height=50 --image="gtk-info" --text="\nData Added Successfully" --no-buttons
elif [ $deliver -eq 1]
    then
        yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nCancled" --no-buttons
else
    yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nProblem in Adding Data" --no-buttons
fi
}
#..................................................................................




#.............................Today's delivery list Option...............................................
function delivery_list
{

today_date=`date -I`
MYSQL=`which mysql`

$MYSQL salesman -u personalproject -Ne "SELECT order_id, cus_name, cus_address, cus_phone, payment, status FROM customer WHERE delivery='$today_date' ORDER BY status DESC"|tr '\t' '\n'|yad --center --width 1280 --height 720 --text-info --justify="CENTER" --fontname="luxi-serif" --list --no-selection--grid-lines="VERTICAL" --column "Order no." --column "       Customer Name         " --column "                           Address                             " --column "      Phone     " --column "         Payment       " --column "    Status    " --title "Today's($today_date) Delivery" --height 720 --width 1280 --button="Deliver":0 --button=gtk-cancel:1 > /tmp/entries 

deliver=$?
state=Delivered
oid=`cut -d "|" -f 1 /tmp/entries`

if [ $deliver -eq 0 ]
then
    $MYSQL salesman -u personalproject -e "UPDATE customer SET status='$state' WHERE order_id=$oid"
    yad --center --width=300 --height=50 --image="gtk-info" --text="\nDelivery Successfully" --no-buttons
elif [ $deliver -eq 1 ]
    then
        yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nCancled" --no-buttons
else
    yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nProblem in Delivery" --no-buttons
fi
}
#........................................................................................................




#.................................."Next" Option (in Filtered Event).......................................
function next_delivery
{

MYSQL=`which mysql`
$MYSQL salesman -u personalproject -Ne "SELECT order_id, delivery, cus_name, cus_address, cus_phone, payment FROM customer WHERE delivery >= CURDATE() ORDER BY delivery"|tr '\t' '\n'|yad --center --list --no-selection--grid-lines="VERTICAL" --column "Order no." --column "      Date		" --column "          Customer Name         " --column "                        Address                             " --column "      Phone     " --column "       Payment       " --title "Next customer" --height 720 --width 1280 --button="Back":3 > /tmp/entries

if [ $? -eq 3 ]
then
  inner_option 
fi

}
#..........................................................................................................




#........................................"Failed Delivery" Option ..............................................
function failed
{
    MYSQL=`which mysql`
    $MYSQL salesman -u personalproject -Ne "SELECT delivery, cus_name, cus_address, cus_phone, payment, status FROM customer WHERE status='Failed'"|tr '\t' '\n'|yad --center --width 1280 --height 720 --text-info --justify="CENTER" --fontname="luxi-serif" --list --no-selection--grid-lines="VERTICAL" --column "Delivery Date" --column "       Customer Name         " --column "                           Address                             " --column "      Phone     " --column "         Payment       " --column "         Status       " --title "Failed Delivery List" --height 720 --width 1280 --button="Back":3 > /tmp/entries
if [ $? -eq 3 ]
then
  inner_option 
fi
}
#...............................................................................................................



#........................................."Edit entry" Option ..................................................
function all_delivery
{

MYSQL=`which mysql`
$MYSQL salesman -u personalproject -Ne "SELECT order_id, delivery, cus_name, cus_address, cus_phone, product_details, payment, status FROM customer ORDER BY delivery"|tr '\t' '\n'|yad --center --list --column "Order no." --column "     Date     " --column "        Customer Name        " --column "                         Address                         " --column "   Phone  " --column "             Product Description              " --column "         Payment       " --column "         Status       " --text "" --title "Edit Current customer" --height 720 --width 1280 --button="gtk-edit":0 --button="gtk-delete":2  --hide-column=1 > /tmp/entries

button_choice=$?

oid=`cut -d "|" -f 1 /tmp/entries`
date_input=`cut -d "|" -f 2 /tmp/entries`
cus_name=`cut -d "|" -f 3 /tmp/entries`
cus_address=`cut -d "|" -f 4 /tmp/entries`
cus_phone=`cut -d "|" -f 5 /tmp/entries`
product_details=`cut -d "|" -f 6 /tmp/entries`
payment=`cut -d "|" -f 7 /tmp/entries`
state=`cut -d "|" -f 8 /tmp/entries`


if [ $button_choice -eq 0 ]
then
   yad --height 720 --width 1280 --center --form --field="Date":DT --field="Customer Name" --field="Address" --field="Phone" --field="Product Description" --field="Payment" --field="Status" "$date_input" "$cus_name" "$cus_address" "$cus_phone" "$product_details" "$payment" "$state" --title "Update entry" --text "Update entry Here:" --date-format="%Y-%m-%d" --button="Update":0 --button=gtk-cancel:1 > /tmp/entries
   update_choice=$?


   date_update=`cut -d "|" -f 1 /tmp/entries`
   name_update=`cut -d "|" -f 2 /tmp/entries`
   address_update=`cut -d "|" -f 3 /tmp/entries`
   phone_update=`cut -d "|" -f 4 /tmp/entries`
   product_update=`cut -d "|" -f 5 /tmp/entries`
   payment_update=`cut -d "|" -f 6 /tmp/entries`
   state_update=`cut -d "|" -f 7 /tmp/entries`
   
   if [[ $? -eq 0 && $update_choice -eq 0 ]]
   then
       $MYSQL salesman -u personalproject -e "UPDATE customer SET delivery='$date_update' WHERE order_id=$oid"
       $MYSQL salesman -u personalproject -e "UPDATE customer SET cus_name='$name_update' WHERE order_id=$oid"
       $MYSQL salesman -u personalproject -e "UPDATE customer SET cus_address='$address_update' WHERE order_id=$oid"
       $MYSQL salesman -u personalproject -e "UPDATE customer SET cus_phone='$phone_update' WHERE order_id=$oid"
       $MYSQL salesman -u personalproject -e "UPDATE customer SET product_details='$product_update' WHERE order_id=$oid"
       $MYSQL salesman -u personalproject -e "UPDATE customer SET payment='$payment_update' WHERE order_id=$oid"
       $MYSQL salesman -u personalproject -e "UPDATE customer SET status='$state_update' WHERE order_id=$oid"
       yad --center --width=300 --height=50 --image="gtk-info" --text="\nData Updated Successfully" --no-buttons
   else
       yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nProblem in Updating Data" --no-buttons
   fi
elif [ $button_choice -eq 2 ]
then 
   
   $MYSQL salesman -u personalproject -e "DELETE FROM customer WHERE order_id=$oid"
   
   if [ $? -eq 0 ]
   then
       yad --center --width=300 --height=50 --image="gtk-info" --text="\nData Deleted Successfully" --no-buttons
   else
       yad --center --width=300 --height=50 --image="gtk-dialog-error" --text="\nProblem in Deleting Data" --no-buttons
   fi

    
fi

}
#...........................................................................................................



#......................................"This Month" Option (in Filtered Event)................................
function this_month
{

MYSQL=`which mysql`
$MYSQL salesman -u personalproject -Ne "SELECT order_id, delivery, cus_name, cus_address, cus_phone, payment FROM customer WHERE MONTH(delivery) = MONTH(CURDATE()) AND YEAR(delivery) = YEAR(CURDATE()) ORDER BY delivery"|tr '\t' '\n'|yad --center --list --no-selection--grid-lines="VERTICAL" --column "Order no." --column "Date		" --column "Customer Name         " --column "Address                             " --column "Phone     " --column "Payment       " --title "This Month customer" --height 720 --width 1280 --button="Back":3 > /tmp/entries

if [ $? -eq 3 ]
then
  inner_option 
fi

}
#...........................................................................................................





#................................"This Year" Option (in filtered event).....................................
function this_year
{

MYSQL=`which mysql`
$MYSQL salesman -u personalproject -Ne "SELECT order_id, delivery, cus_name, cus_address, cus_phone, payment FROM customer WHERE YEAR(delivery) = YEAR(CURDATE()) ORDER BY delivery"|tr '\t' '\n'|yad --center --list --no-selection--grid-lines="VERTICAL" --column "Order no." --column "       Date		" --column "            Customer Name           " --column "                             Address                               " --column "       Phone       " --column "             Payment         " --title "This Year customer" --height 720 --width 1280 --button="Back":3 > /tmp/entries

if [ $? -eq 3 ]
then
  inner_option 
fi

}
#............................................................................................................




#....................................."Filtered delivery list" option................................................
function inner_option
{
 
yad --center --width 300 --height 300 --list --text "Select your desired range of time:" --title "Choose to Filter" --radiolist --column "SELECT" --column "OPTION" TRUE "Next" FALSE "This Month" FALSE "This Year" FALSE "Failed Delivery" FALSE "Back" --button="Find":0 --button="gtk-cancel":1 > /tmp/entries 
op=`cut -d "|" -f 2 /tmp/entries`

case "${op}" in
    "This Month" )
           this_month;;
    "This Year" )
           this_year;;
    "Next")
           next_delivery;;
    "Failed Delivery")
            failed;;
    "Back")
           continue;;
esac
}
#............................................................................................................




#..........................................Main Menu.........................................................

while true
do

 yad --center --width 300 --height 300 --list --text "Select an Option:" --title "Sales Portal" --radiolist --column "SELECT" --column "OPTION" TRUE "Add Delivery Task" FALSE "Today's Delivery List" FALSE "Check Delivery list" FALSE "Edit Entry" FALSE "Exit" --no-selection --button="Choose":0 --button="gtk-cancel":1 > /tmp/entries
choice=`cut -d "|" -f 2 /tmp/entries`
MYSQL=`which mysql`
state=Failed
state1=Pending
$MYSQL salesman -u personalproject -e "UPDATE customer SET status='$state' WHERE delivery < CURDATE() AND status='$state1'"

    case "${choice}" in
       "Add Delivery Task" )
             add_delivery;;
       "Today's Delivery List" )
             delivery_list;;
       "Check Delivery list")
             inner_option;;
       "Edit Entry")
           all_delivery;;
        *)
            break;;
     esac

if [ $? -eq 255 ]
then
   break
fi

done
#.............................................................................................................
