#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# 1) jika tidak ada argumen
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit
fi

ARG="$1"

# 2) kalau argumen hanya angka => atomic_number
if [[ $ARG =~ ^[0-9]+$ ]]
then
  QUERY="SELECT e.atomic_number,e.name,e.symbol,t.type,p.atomic_mass,p.melting_point_celsius,p.boiling_point_celsius
         FROM elements e
         JOIN properties p USING(atomic_number)
         JOIN types t USING(type_id)
         WHERE e.atomic_number = $ARG;"
else
  # else, coba match symbol (case-insensitive) atau name (case-insensitive)
  # gunakan dua query OR untuk mengecek symbol atau name
  QUERY="SELECT e.atomic_number,e.name,e.symbol,t.type,p.atomic_mass,p.melting_point_celsius,p.boiling_point_celsius
         FROM elements e
         JOIN properties p USING(atomic_number)
         JOIN types t USING(type_id)
         WHERE LOWER(e.symbol) = LOWER('$ARG') OR LOWER(e.name) = LOWER('$ARG');"
fi

RESULT=$($PSQL "$QUERY")

if [[ -z $RESULT ]]
then
  echo "I could not find that element in the database."
  exit
fi

# parse result (PSQL -t --no-align -c uses | as delimiter)
IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELT BOIL <<< "$RESULT"

# trim whitespace just in case (from psql)
NAME=$(echo "$NAME" | sed -r 's/^ *| *$//g')
SYMBOL=$(echo "$SYMBOL" | sed -r 's/^ *| *$//g')
TYPE=$(echo "$TYPE" | sed -r 's/^ *| *$//g')
MASS=$(echo "$MASS" | sed -r 's/^ *| *$//g')
MELT=$(echo "$MELT" | sed -r 's/^ *| *$//g')
BOIL=$(echo "$BOIL" | sed -r 's/^ *| *$//g')

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELT celsius and a boiling point of $BOIL celsius."
