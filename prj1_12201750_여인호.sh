#!/bin/bash

item=$1
data=$2
user=$3

input=0


echo "-----------------------------------------"
echo "User Name: Yeo Inho"
echo "Student Number: 12201759"
echo "[MENU]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get the data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data'"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "-----------------------------------------"

while true;
do

read -p "Enter your choice [ 1-9 ] " input

if [ $input -eq 1 ]
then
read -p "Please enter 'movie id' (1~1682):" mov_id
cat $item | awk -F\| -v _id=$mov_id '_id==$1{print $0}'

elif [ $input -eq 2 ]
then
read -p "Do you want to get the data of 'action' genre movies from 'u.item'?(y/n):" yn
if [ $yn != "y" ]
then continue;
fi
cat $item | awk -F\| '$7==1{print $1,$2}' | head -n 10

elif [ $input -eq 3 ]
then
read -p "Please enter 'movie id' (1~1682):" mov_id
cat $data | awk -v _id=$mov_id '_id==$2{sum+=$3} _id==$2{cnt+=1} END {printf "%.5f\n", sum/cnt}'

elif [ $input -eq 4 ]
then
read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n):" yn
if [ $yn != "y" ]
then continue;
fi

cat $item | head -n 10 | sed -E 's/http:[^)]*)//g'

elif [ $input -eq 5 ]
then
read -p "Do you want to get the data about users from 'u.user'? (y/n):" yn
if [ $yn != "y" ]
then continue;
fi
cat $user | head -n 10 | awk -F\| '{printf("user %d is %d years old %s %s\n", $1, $2, $3, $4)}' | sed -e 's/M/male/g' -e 's/F/female/g'

elif [ $input -eq 6 ]
then
read -p "Do you want to Modify the format of 'release data' in 'u.item'?(y/n):" yn
if [ $yn != "y" ]
then continue;
fi
cat $item | awk -F\| '$1>=1673&&$1<=1682{print $0}' | sed -Ee 's/([0-9][0-9])(-...)(-[0-9][0-9][0-9][0-9])/ \3\2\1 /g' -e 's/-Jan/01/g' -e 's/-Feb/02/g' -e 's/-Mar/03/g' -e 's/-Sep/09/g' -e 's/-Oct/10/g' -e 's/\| \-/|/g' -e 's/ \|/|/g'

elif [ $input -eq 7 ]
then
read -p "Please enter the 'user id' (1~943):" user_id
tmp=$(cat $data | awk -v _id=$user_id '_id==$1{print $2}' | sort -n)
echo $tmp | tr ' ' '|'

tmp=$(echo $tmp | tr ' ' '\n' | head -n 10 | tr '\n' ' ')
echo ""

for j in $tmp
do
cat $item | awk -F\| -v _comp=$j '_comp==$1{printf("%d|%s\n",$1, $2)}'
done

elif [ $input -eq 8 ]
then
read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n):" yn
if [ $yn != "y" ]
then continue;
fi

young=$(cat $user | awk -F\| '$2>=20&&$2<=29&&$4=="programmer"{print $1}')


for i in $young
do
cat $data | awk -v _ind=$i '$1==_ind{print $2, $3 >> "Inho_tmp.txt"}'
done

count=$(cat $item | wc -l)

comp=1
until [ $comp -gt $count ]
do

cat Inho_tmp.txt | awk -v _ind=$comp '_ind==$1{sum+=$2} _ind==$1{cnt+=1} END {if(cnt!=0)printf("%d, %.5f\n", _ind, sum/cnt)}' | sed -Ee 's/0+$//g' -e 's/\.$//g'
comp=$(( $comp+1 ))
done



elif [ $input -eq 9 ]
then
echo "Bye!"
break;

fi

done