#!/bin/bash

# Esegui il programma per valori di input da 0 a 15.000 con incrementi di 100
for ((n=250; n<=10000; n+=250)); do
  for ((i=1; i<=2; i++)); do
    echo "Esecuzione con input $n - Iterazione $i:"
    echo $n | mpiexec -np 1 Parallelo
    echo "----------------------"
  done
done

for ((n=250; n<=10000; n+=250)); do
  for ((i=1; i<=2; i++)); do
    echo "Esecuzione con input $n - Iterazione $i:"
    echo $n | mpiexec -np 2 Parallelo
    echo "----------------------"
  done
done

