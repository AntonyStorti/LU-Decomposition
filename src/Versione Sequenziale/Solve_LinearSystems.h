#ifndef INC_1__VERSIONE_SEQUENZIALE_SOLVE_LINEARSYSTEMS_H
#define INC_1__VERSIONE_SEQUENZIALE_SOLVE_LINEARSYSTEMS_H


//Funzione per eseguire la decomposizione LU della matrice dei coefficienti
int LUDecompose(double *mat, int n);

//Funzione per risolvere un sistema di equazioni lineari (NxN) utilizzando la decomposizione LU
void LUSolve(double *mat, double *b, int n);


#endif //INC_1__VERSIONE_SEQUENZIALE_SOLVE_LINEARSYSTEMS_H
