#include <stdio.h>
#include <stdlib.h>
#include <cuda.h>
#include <omp.h>
#include <time.h>
#include <sys/time.h>
#include "Solve_Systems.cu"

//Per assicurarmi di non eccedere il limite dei 1024 blocchi della "Tesla T4"
#define TILE 16


void salva_su_CSV(int N, double t, const char *filename);


int main(int argc, char** argv) {


    printf("\n+=========================================================================================+");
    printf("\n+====================| Decomposizione LU: Risoluzione di Sistemi Lineari |================+");
    printf("\n+=========================================================================================+\n\n");


    struct timeval start_real, end_real;
    double tempo_impiegato;

    //Dimensione della matrice (N x N)
    int n = atoi(argv[1]);


    //=========================== ALLOCAZIONE DINAMICA MEMORIA ========================//

    srand(100);

    //Matrice dei coefficienti
    double *a = (double*)malloc(n * n * sizeof(double));

    //Matrice Decomposta ( A = L*U )
    double *decomposta = (double*)malloc(n * n * sizeof(double));


    generaMatrice(a, n);


    //Vettore dei termini noti
    double *b = (double*)malloc(n * sizeof(double));

    //Popolamento del vettore dei termini noti:
    double min = -100;
    double max = 100;

    for (int i = 0; i < n; i++)
        b[i] = (double) rand() / RAND_MAX * (max - min);


    //=================================================================================//



    //=========================== ALLOCAZIONE MEMORIA SULLA GPU =======================//

    double *gpu_a;
    int numblock = n / TILE + ((n % TILE) ? 1 : 0);

    cudaMalloc(&gpu_a, n * n * sizeof(double));
    cudaMemcpy(gpu_a, a, n * n * sizeof(double), cudaMemcpyHostToDevice);


    gettimeofday(&start_real, NULL);

    //##################################################################################//


                            LUDecompose(gpu_a, n, numblock);


    //##################################################################################//


    //Salvo la matrice decomposta sulla memoria della CPU
    cudaMemcpy(decomposta, gpu_a, n * n * sizeof(double), cudaMemcpyDeviceToHost);

    double** A = (double**)malloc(n * sizeof(double*));
    double** u = (double**)malloc(n * sizeof(double*));
    double** l = (double**)malloc(n * sizeof(double*));

    initialize_matrices(A, l, u, n);

    //Ottengo dalla matrice decomposta: L ed U
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < n; ++j) {
            A[i][j] = decomposta[i * n + j];
        }
    }

    for (int i = 0; i < n; i++) {
        for (int j = 0; j < n; j++) {
            for (int k = 0; k < n; k++) {
                if (i >= k)
                    l[i][k] = A[i][k];
                else
                    l[i][k] = 0;

                if (k == j)
                    u[k][j] = 1;
                else if (k < j)
                    u[k][j] = A[k][j];
                else
                    u[k][j] = 0.0;
            }
        }
    }


    //##################################################################################//


                            int core_usati = LUSolve(n, l, u, b);


    //##################################################################################//


    gettimeofday(&end_real, NULL);
    tempo_impiegato = (double)(end_real.tv_sec - start_real.tv_sec) +
                      (double)(end_real.tv_usec - start_real.tv_usec) / 1000000.0;


    // Stampa risultati
    printf("\n\nRisultato del sistema di equazioni:\n\n");
    for (int i = 0; i < n; i++)
        printf("x%d = %f\n", i + 1, b[i]);

    printf("\n\nLa CPU remota ha disponibili: %d cores\n", core_usati);
    printf("Sono stati usati per la parallelizzazione: %d cores !\n", core_usati);

    printf("\n\n=========================================");
    printf("\nIl Tempo impiegato per risolvere il sistema è: %lf\n", tempo_impiegato);
    printf("\n\n\n");


    salva_su_CSV(n, tempo_impiegato, "CUDA.csv");


    cudaFree(gpu_a);
    free(a);
    free(decomposta);
    free(b);
    deallocate_matrices(A, l, u, n);



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