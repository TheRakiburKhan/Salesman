#!/bin/bash
MYSQL=`which mysql`

#dbs=
$MYSQL salesman -u personalproject -e 'CREATE TABLE events(id int not null, date DATE, event_desc varchar(50), primary key(id));'

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
