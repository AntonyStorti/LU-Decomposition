/*
** Questo file contiene le funzioni per risolvere un sistema di equazioni lineari NxN utilizzando la decomposizione LU.
** L'implementazione si basa sul materiale teorico, reperito in rete, contenuto in:
**
**      - "Numerical Methods - A Software Approach" di Johnston (1982), pp.28-44
**      - "The C Programming Language" di Kernighan & Ritchie (1978), p.104
**      - "An efficient implementation of LU decomposition in C" di A. Meyer (1988)
**
** Le funzioni:
**
**      LUDecompose --> esegue la fase di decomposizione.
**      LUSolve --> risolve un sistema dato un vettore b dei termini noti.
**
*/

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include "Solve_LinearSystems.h"


static int *pivot = NULL;       //Vettore Pivot

#define SMALLEST_PIVOT 1.0e-5   //Più piccolo pivot non-singolare consentito



/*
** Questa funzione esegue la fase di decomposizione LU. La matrice dei coefficienti in input verrà sovrascritta
** con le matrici Lu (Low & Upper) computate nel processo.
**
**  Parametri :
**
**  mat - È la matrice dei coefficienti. Questa funzione esegue la lettura per riga per riga:
**        si dichiara la matrice come un puntatore ad un array monodimensionale. Non si utilizza l'inefficiente
 *        implementazione di vettore bidimensionale ( double mat[SIZE][SIZE] ), come già fornito dal linguaggio.
**
**  n -   Questo parametro indica la dimensione del sistema corrente (NxN).
**
*/

int LUDecompose(double *mat, int n) {

    int i, j, k, n_meno_1 = n - 1;
    double dtmp1, *dptr1, *dptr2;
    int numcols = n;   //Del tutto superfluo (la matrice è quadrata), ma rende più leggibile il codice!


    // Alloca memoria per il vettore pivot:
    if (pivot != NULL)
        free(pivot);

    if ((pivot = (int *)malloc(n * sizeof(int))) == NULL) {
        fprintf(stderr, "Errore in LUDecompose - malloc \n");
        return -2;
    }


    // Inizializza il pivot:
    for (i = 0; i < n_meno_1; i++)
        *(pivot + i) = i;

    *(pivot + n_meno_1) = 1;

    // Loop che implementa la LU Decomposition riga per riga:
    for (i = 0; i < n_meno_1; i++) {

        // Cerco il pivot maggiore
        k = i;  //Sarà la riga del pivot

        dptr1 = dptr2 = mat + i * (numcols + 1);    //Puntano all'elemento del pivot


        for (j = i + 1; j < n; j++) {

            dptr2 += numcols;

            if (fabs(*dptr2) > fabs(*dptr1)) {      //La riga corrente è la nuova riga del pivot
                dptr1 = dptr2;
                k = j;
            }

        }



        //K ora indica la riga contenente il più grande pivot, e, dptr1 punta all'elemento//
        if (fabs(*dptr1) < SMALLEST_PIVOT) {
            fprintf(stderr, "Errore in LUDecompose - La matrice è singolare !!! \n");
            return -1;
        }


        //Scambia riga i e k, aggiorna il pivot//
        if (k != i) {
            *(pivot + i) = k;
            *(pivot + n_meno_1) = - *(pivot + n_meno_1);
            dptr1 = mat + i * numcols;
            dptr2 = mat + k * numcols;

            for (j = 0; j < n; j++, dptr1++, dptr2++) {
                dtmp1 = *dptr1;
                *dptr1 = *dptr2;
                *dptr2 = dtmp1;
            }
        }


        //A questo punto, il più grande pivot è stato trovato e la riga i ne contiene il valore//
        //Il ciclo sottostante opera le opportune eliminazioni//
        for (j = i + 1; j < n; j++) {

            dtmp1 = *(mat + j * numcols + i) / *(mat + i * numcols + i);
            dptr1 = mat + j * numcols + i + 1;
            dptr2 = mat + i * numcols + i + 1;

            for (k = i + 1; k < n; k++, dptr1++, dptr2++)
                *dptr1 -= dtmp1 * (*dptr2);

            *(mat + j * numcols + i) = dtmp1;

        }

    }

    return 1;

}



/*
**  Questa funzione risolve un sistema di equazioni lineari, dato il vettore dei termini noti.
**  La Matrice dei Coefficienti va prima decomposta in forma LU, e solo poi si può risolvere!
**
**    Parametri:
**
**    mat - E' la LU Decomposizione della matrice dei coefficienti iniziale.
**          La matrice originale va prima passata alla funzione di decomposizione
**          per essere risolta.
**
**    b -   E' il vettore dei termini noti, questa funzione computa il vettore dei
**          risultati e lo ritorna sovrascrivvendolo in b.
**
**    n -   Questo parametro indica la dimensione del sistema corrente (NxN).
**
*/

void LUSolve(double *mat, double *b, int n) {

    int i, j, n_meno_1 = n - 1;
    double dtmp1, *dptr1;
    int numcols = n;   //Del tutto superfluo (la matrice è quadrata), ma rende più leggibile il codice!


    //Scambia le righe del pivot sul vettore b
    for (i = 0; i < n_meno_1; i++) {

        j = *(pivot + i);

        //Scambia i e j
        if (j != i) {
            dtmp1 = *(b + i);
            *(b + i) = *(b + j);
            *(b + j) = dtmp1;
        }

    }


    //Risolve il sistema Ld = Pb in d, d sovrascrive b.
    for (i = 0; i < n; i++) {

        dtmp1 = *(b + i);

        for (j = 0, dptr1 = mat + i * numcols; j < i; j++, dptr1++)
            dtmp1 -= *dptr1 * *(b + j);

        *(b + i) = dtmp1;

    }


    //Risolve il sistema Ux = d in x, x sovrascrive b, e, d.
    for (i = n_meno_1; i >= 0; i--) {

        dtmp1 = *(b + i);
        dptr1 = mat + i * numcols + n - 1;

        for (j = n_meno_1; j > i; j--) {
            dtmp1 -= *dptr1 * *(b + j);
            dptr1--;
        }

        *(b + i) = dtmp1 / *dptr1;

    }


}