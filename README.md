# LU-Decomposition
Implementazione parallela della "LU Decomposizione" per risolvere Sistemi Lineari di equazioni.

1) Versione Sequenziale
2) Versione "OpenMP + MPI"
3) Versione "OpenMP + CUDA"





COME ESEGUIRE ???




1)	Nella cartella "src" è possibile: compilare, eseguire e testare il codice. 
	Navigando da terminale in una delle tre cartelle (CUDA, OpenMP+MPI, Sequenziale) è presente un MakeFile. 
	Posizionati in quella cartella basta invocare il comando "make".
	Il codice verrà compilato e richiamerà uno script shell che si occupa di passare gli input per effettuare i test.
	Se lo script non viene eseguito per problemi di permessi, eseguire il seguente comando: "chmod +x esegui_test.sh".
	Successivamente rilanciare il Make.


2)	Nella cartella "data" sono presenti i file CSV prodotti, per ottenere i grafici: posizionarsi in quella cartella da terminale ed eseguire il "make". 
	Verrà eseguito lo script R associato, ma, solo se tale applicativo è installato sul PC.



3)	Per eseguire il codice CUDA in locale serve una GPU Nvidia, non avendone una a disposizione non ho potuto predisporre alcun MakeFile!




	N.B. --> Concedere i privilegi da amministratore altrimenti verrà inibita l'esecuzione dello Script shell per il test !!!
