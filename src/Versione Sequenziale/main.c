#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include "Solve_LinearSystems.h"


void salva_su_CSV(int N, double t, const char *filename);


int main() {

    struct timeval start_real, end_real;
    double real_time_used;

    printf("\n+=========================================================================================+");
    printf("\n+====================| Decomposizione LU: Risoluzione di Sistemi Lineari |================+");
    printf("\n+=========================================================================================+\n");

    int valore;
    printf("\nInserisci la dimensione della matrice [N x N] \n");
    printf("Inserisci il valore di N: ");

    if (scanf("%d", &valore) != 1 || valore <= 0) {
        fprintf(stderr, "Errore: Inserisci un valore numerico valido e positivo per N.\n");
        return -1;
    }

    const int n = valore;


    //=========================== MATRICE DEI COEFFICIENTI ========================//

    /*Allocazione dinamica della matrice*/
    double *matrice = (double *)malloc(n * n * sizeof(double));

    if (matrice == NULL) {
        fprintf(stderr, "Errore: Impossibile allocare tutta questa memoria.\n");
        return -1;
    }


    /*Generazione di valori pseudo-casuali ma normalizzati*/
    double min = -10000.0;
    double max = 10000.0;
    srand(100);

    /*Popolamento della matrice dei coefficienti*/
    for (int i = 0; i < n * n; i++)
        matrice[i] = (double)rand() / RAND_MAX * (max - min);

    //=============================================================================//



    //========================= VETTORE DEI TERMINI NOTI ==========================//

    // Allocazione dinamica del vettore dei termini noti 'b'
    double *b = (double *)malloc(n * sizeof(double));

    if (b == NULL) {
        fprintf(stderr, "Errore: Impossibile allocare tutta questa memoria.\n");
        free(matrice); // Libera la memoria precedentemente allocata per la matrice
        return -1;
    }


    /*Popolamento del vettore b con valori casuali*/
    for (int i = 0; i < n; i++)
        b[i] = (double)rand() / RAND_MAX * (max - min);

    //=============================================================================//



    gettimeofday(&start_real, NULL);



    /*******   Risolvi il sistema usando la LU Decomposizione!!!  *******/

                        LUDecompose(matrice, n);
                        LUSolve(matrice, b, n);

    /********************************************************************/



    gettimeofday(&end_real, NULL);


    //Calcola il tempo impiegato:
    real_time_used = (double)(end_real.tv_sec - start_real.tv_sec) + (double)(end_real.tv_usec - start_real.tv_usec) / 1000000.0;



    //=============================================================================//



    //Stampa a video i risultati del sistema di equazioni lineari //
    printf("\nRisultato del sistema di equazioni:\n\n");
    for (int i = 0; i < n; i++)
        printf("x%d = %f\n", i + 1, b[i]);

    //Stampa a video il tempo impiegato
    printf("\n\n=========================================");
    printf("\nTempo reale impiegato: %.6f secondi\n\n", real_time_used);


    salva_su_CSV(n, real_time_used, "Sequenziale.csv");


    // Deallocazione della memoria allocata
    free(matrice);
    free(b);



    return 0;

}





void salva_su_CSV(int N, double t, const char *filename){


    FILE *file = fopen(filename, "a");

    if (file != NULL) {

        // Determina se il file è appena stato creato
        long pos = ftell(file);

        if (pos == 0) {
            // Il file è vuoto, quindi scrivo l'intestazione
            fprintf(file, "Dimensione Matrice (NxN) ; Tempo di Esecuzione (sec)\n");
        }

        fprintf(file, "%d;%f\n", N, t);

        fclose(file);

    }   else {
                perror("\nErrore nel salvataggio dei dati sul CSV !\n");
             }


}