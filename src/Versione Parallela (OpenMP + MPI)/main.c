#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <mpi.h>
#include "Solve_LinearSystems.h"


void salva_su_CSV(int N, double t, int NP, int n_thread, const char *filename);


int main() {

    int rank, size;
    MPI_Init(NULL, NULL);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    int n;
    struct timeval start_real, end_real;
    double real_time_used;



    if (rank == 0) {

        printf("\n+=========================================================================================+");
        printf("\n+====================| Decomposizione LU: Risoluzione di Sistemi Lineari |================+");
        printf("\n+=========================================================================================+\n");

        // Processo 0 legge la dimensione della matrice
        printf("\nInserisci la dimensione della matrice [N x N]: \n");

        if (scanf("%d", &n) != 1 || n <= 0) {
            fprintf(stderr, "Errore: Inserisci un valore numerico valido e positivo per N.\n");
            MPI_Abort(MPI_COMM_WORLD, -1);
        }

    }

    // Broadcast della dimensione della matrice (N) a tutti i processi
    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);


    //================== MATRICE DEI COEFFICIENTI & VETTORE TERMINI NOTI ============//

    // Allocazione dinamica della memoria:
    double *matrice = (double *)malloc(n * n * sizeof(double));
    double *b = (double *)malloc(n * sizeof(double));

    if (matrice == NULL || b == NULL) {
        fprintf(stderr, "Errore: Impossibile allocare memoria.\n");
        MPI_Abort(MPI_COMM_WORLD, -2);
    }

    //===============================================================================//


    if (rank == 0) {

        //Generazione di valori pseudo-casuali ma normalizzati
        double min = -10000.0;
        double max = 10000.0;
        srand(100);

        //Popolamento della matrice dei coefficienti:
        for (int i = 0; i < n * n; i++)
            matrice[i] = (double) rand() / RAND_MAX * (max - min);

        //Popolamento del vettore dei termini noti:
        for (int i = 0; i < n; i++)
            b[i] = (double) rand() / RAND_MAX * (max - min);

        //Misurazione del tempo di inizio
        gettimeofday(&start_real, NULL);

    }

    /*******************   Risolvi il sistema usando la LU Decomposizione!!!  *******************/

    int num_cores;

    //Decomposizione della "Matrice dei Coefficienti" (OpenMP)
    if(rank == 0) {

        num_cores = LUDecompose(matrice, n);

    }

    //Invio della matrice a tutti i processi
    MPI_Bcast(matrice, n * n, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    //Tutti i processi sono coinvolti nella "Soluzione dei Sistema Lineare" (MPI)
    LUSolve(matrice, b, n, size, rank);

    /********************************************************************************************/


    if (rank == 0) {

        // Misurazione del tempo impiegato
        gettimeofday(&end_real, NULL);

        // Calcola il tempo impiegato
        real_time_used = (double)(end_real.tv_sec - start_real.tv_sec) +
                     (double)(end_real.tv_usec - start_real.tv_usec) / 1000000.0;

        // Stampa risultati
        printf("\n\nRisultato del sistema di equazioni:\n\n");
        for (int i = 0; i < n; i++)
            printf("x%d = %f\n", i + 1, b[i]);

        printf("\n\n=========================================");
        printf("\nTempo reale impiegato: %.6f secondi\n\n", real_time_used);

        salva_su_CSV(n, real_time_used, size, num_cores, "Parallelo.csv");

    }



    // Deallocazione della memoria
    free(matrice);
    free(b);


    MPI_Finalize();


    return 0;

}





void salva_su_CSV(int N, double t, int NP, int n_thread, const char *filename){


    FILE *file = fopen(filename, "a");

    if (file != NULL) {

        // Determina se il file è appena stato creato
        long pos = ftell(file);

        if (pos == 0) {
            // Il file è vuoto, quindi scrivo l'intestazione
            fprintf(file, "Dimensione Matrice (NxN) ; Tempo di Esecuzione (sec) ; Processi MPI ; Threads OpenMP\n");
        }

        fprintf(file, "%d ; %f ; %d ; %d\n", N, t, NP, n_thread);

        fclose(file);

    }   else {
        perror("\nErrore nel salvataggio dei dati sul CSV !\n");
    }


}