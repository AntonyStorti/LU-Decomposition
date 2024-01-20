#ifndef LU_DECOMPOSITION_H
#define LU_DECOMPOSITION_H


//########  LU DECOMPOSITION - Linear Systems   #######//
void LUDecompose(double* gpu_a, int n, int numblock);
__global__ void scala_Indice(double *matrix, int n, int index);
__global__ void eliminazione_gaussiana(double *A, int n, int index, int bsize);
int LUSolve(int n, double** L, double** U, double* b);


//#######   GESTIONE MATRICI DINAMICHE  #######//
void generaMatrice(double* a, int n);
void initialize_matrices(double** a, double** l, double** u, int size);
void deallocate_matrices(double** a, double** l, double** u, int size);



#endif  // LU_DECOMPOSITION_H
