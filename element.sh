#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
  exit 0
fi

INPUT=$1

# Detect if input is atomic_number (digits only)
if [[ $INPUT =~ ^[0-9]+$ ]]
then
  QUERY=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number JOIN types t ON p.type_id = t.type_id WHERE e.atomic_number = $INPUT")
# Detect if input is symbol (1 or 2 letters)
elif [[ $INPUT =~ ^[A-Za-z]{1,2}$ ]]
then
  # Capitalize first letter, lowercase second letter if exists
  SYMBOL="$(tr '[:lower:]' '[:upper:]' <<< ${INPUT:0:1})$(tr '[:upper:]' '[:lower:]' <<< ${INPUT:1:1})"
  QUERY=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number JOIN types t ON p.type_id = t.type_id WHERE e.symbol = '$SYMBOL'")
else
  # Assume name, capitalize first letter only
  NAME="$(tr '[:lower:]' '[:upper:]' <<< ${INPUT:0:1})${INPUT:1}"
  QUERY=$($PSQL "SELECT e.atomic_number, e.name, e.symbol, t.type, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius FROM elements e JOIN properties p ON e.atomic_number = p.atomic_number JOIN types t ON p.type_id = t.type_id WHERE e.name = '$NAME'")
fi

if [[ -z $QUERY ]]
then
  echo "I could not find that element in the database."
  exit 0
fi

# Parse results
IFS="|" read ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$QUERY"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
