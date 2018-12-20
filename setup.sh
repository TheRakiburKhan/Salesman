#!/bin/bash
MYSQL=`which mysql`

#dbs=
$MYSQL salesman -u personalproject -e 'CREATE TABLE customer(order_id int not null, cus_name varchar(45) not null, cus_address varchar(80) not null, cus_phone varchar(15) not null, primary key (cus_id));'

if [ $? -eq 0 ]
then
   echo "Table Created Successfully!!!"
else
   echo "Problem in table Creation"
fi

<<Y
for db in $dbs
do
  echo $db
done  
Y

<<X
$MYSQL salesman -u personalproject <<EOF
SHOW TABLES;
select * from employees;
EOF
X
