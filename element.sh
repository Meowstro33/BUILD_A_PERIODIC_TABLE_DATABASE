#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    INPUT_ROW_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE atomic_number = $1")
  elif [[ $1 =~ ^[a-zA-Z]+$ ]]
  then
    INPUT_ROW_RESULT=$($PSQL "SELECT atomic_number, symbol, name FROM elements WHERE LOWER(symbol) = LOWER('$1') OR LOWER(name) = LOWER('$1')")
  fi

  # echo "$INPUT_ROW_RESULT"

  if [[ -z $INPUT_ROW_RESULT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS='|' read ATOMIC_NUMBER SYMBOL NAME <<< "$INPUT_ROW_RESULT"
    PROPERTIES_RESULT=$($PSQL "SELECT atomic_mass, melting_point_celsius, boiling_point_celsius, type_id FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    IFS='|' read ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE_ID <<< "$PROPERTIES_RESULT"
    TYPE=$($PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID")
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  fi
fi
