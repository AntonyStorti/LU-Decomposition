#install.packages("ggplot2") --> "Solo se non è già installata !"
library(ggplot2)


# N.B. Percorso relativo alla mia machina --> "Da modificare per testare !!!"
setwd("./")


# Carica i dati dai CSV
risultati_sequenziale <- read.csv("1) Risultati Sequenziale.csv", sep = ";", 
                                  header = TRUE, check.names = FALSE)
risultati_parallelo <- read.csv("2) Risultati Parallelo.csv", sep = ";", 
                                header = TRUE, check.names = FALSE)



################################################################################
################################### SEQUENZIALE ################################
################################################################################



################################################################################
# Calcola il valore minimo del tempo di esecuzione raggruppando per dimensione #
#     [ Questo permette di ripulire il dataset da valori fuorvianti!!! ]       #
################################################################################


minimi_tempi_sequenziale <- aggregate(`Tempo di Esecuzione (sec)` ~ `Dimensione Matrice (NxN)`, 
                                      data = risultati_sequenziale, FUN = min)

colnames(minimi_tempi_sequenziale) <- c("Dimensione Matrice (NxN)", "Tempo di Esecuzione (sec)")



png("Andamento Teorico.png")

# Curva Teorica dei tempi di esecuzione: O(N^3)
plot(minimi_tempi_sequenziale$`Dimensione Matrice (NxN)`, minimi_tempi_sequenziale$`Dimensione Matrice (NxN)`^3,
     type = "l", col = "red", lty = 2,
     main = "Curva di Complessità: O(N^3)",
     xlab = "Dimensione Matrice (NxN)", ylab = "Tempo di Esecuzione (ms)")

grid()

dev.off()



png("./Sequenziale/Tempo.png")

# Crea grafico sequenziale:
plot(minimi_tempi_sequenziale$`Dimensione Matrice (NxN)`, minimi_tempi_sequenziale$`Tempo di Esecuzione (sec)`,
     type = "l",
     main = "Esecuzione Sequenziale",
     xlab = "Dimensione Matrice (NxN)", ylab = "Tempo di Esecuzione (sec)")

polygon(c(minimi_tempi_sequenziale$`Dimensione Matrice (NxN)`, rev(minimi_tempi_sequenziale$`Dimensione Matrice (NxN)`)),
        c(minimi_tempi_sequenziale$`Tempo di Esecuzione (sec)`, rev(rep(0, length(minimi_tempi_sequenziale$`Tempo di Esecuzione (sec)`)))),
        col = rgb(0, 0, 1, alpha = 0.3), border = NA)

grid(lty = 2, col = "gray")

points(minimi_tempi_sequenziale$`Dimensione Matrice (NxN)`, minimi_tempi_sequenziale$`Tempo di Esecuzione (sec)`, col = "blue", pch = 16)

dev.off()



# Esporta il dataframe come un file CSV
write.csv(minimi_tempi_sequenziale, "./Sequenziale/Sequenziale Ripulito.csv", row.names = FALSE)





################################################################################
#################################### PARALLELO #################################
################################################################################



################################################################################
# Calcola il valore minimo del tempo di esecuzione raggruppando per dimensione #
#     [ Questo permette di ripulire il dataset da valori fuorvianti!!! ]       #
################################################################################


minimi_tempi_parallelo <- aggregate(`Tempo di Esecuzione (sec)` ~ `Dimensione Matrice (NxN)` + `Processi MPI` + `Threads OpenMP`, 
                                    data = risultati_parallelo, 
                                    FUN = min)

colnames(minimi_tempi_parallelo) <- c("Dimensione Matrice (NxN)", "Processi MPI", "Threads OpenMP", "Tempo Minimo")


# Filtra i dati per MPI 1
mpi1_data <- minimi_tempi_parallelo[minimi_tempi_parallelo$`Processi MPI` == 1, ]
mpi1_data$`Threads OpenMP` <- as.character(mpi1_data$`Threads OpenMP`)


ggplot(mpi1_data, aes(x = `Dimensione Matrice (NxN)`, y = `Tempo Minimo`, color = `Threads OpenMP`)) +
  geom_line() +
  geom_point() +
  labs(title = "Esecuzione Parallela - MPI 1", x = "Dimensione Matrice (NxN)", y = "Tempi di Esecuzione (sec)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  scale_color_manual(name = "Threads OpenMP", values = c("4" = "green", "6" = "blue", "8" = "red", unique(mpi1_data$`Threads OpenMP`)))


# Filtra i dati per MPI 2
mpi2_data <- minimi_tempi_parallelo[minimi_tempi_parallelo$`Processi MPI` == 2, ]
mpi2_data$`Threads OpenMP` <- as.character(mpi2_data$`Threads OpenMP`)


ggplot(mpi2_data, aes(x = `Dimensione Matrice (NxN)`, y = `Tempo Minimo`, color = `Threads OpenMP`)) +
  geom_line() +
  geom_point() +
  labs(title = "Esecuzione Parallela - MPI 2", x = "Dimensione Matrice (NxN)", y = "Tempo di Esecuzione (sec)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  scale_color_manual(name = "Threads OpenMP", values = c("4" = "green", "6" = "blue", "8" = "red", unique(mpi2_data$`Threads OpenMP`)))


#SPEEDUP:

dataset_statistiche <- merge(minimi_tempi_parallelo, minimi_tempi_sequenziale, by = "Dimensione Matrice (NxN)")

dataset_statistiche$Speedup <- dataset_statistiche$`Tempo di Esecuzione (sec)` / dataset_statistiche$`Tempo Minimo`
colnames(dataset_statistiche) <- c("Dimensione Matrice (NxN)", "Processi MPI", "Threads OpenMP", "Tempo Parallelo", "Tempo Sequenziale", "Speedup")

write.csv(dataset_statistiche, "./Parallelo/SpeedUP.csv", row.names = FALSE)



# Create plots separati per MPI 1 e MPI 2
plot_mpi1 <- ggplot(subset(dataset_statistiche, `Processi MPI` == 1), aes(x = `Dimensione Matrice (NxN)`, y = Speedup, color = factor(`Threads OpenMP`))) +
  geom_line() +
  geom_point() +
  labs(title = "SpeedUp - MPI 1", x = "Dimensione Matrice (NxN)", y = "Speedup", color = "Threads OpenMP") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  scale_color_manual(values = c("blue", "green", "red"))  # Set custom colors for threads

plot_mpi2 <- ggplot(subset(dataset_statistiche, `Processi MPI` == 2), aes(x = `Dimensione Matrice (NxN)`, y = Speedup, color = factor(`Threads OpenMP`))) +
  geom_line() +
  geom_point() +
  labs(title = "SpeedUp - MPI 2", x = "Dimensione Matrice (NxN)", y = "Speedup", color = "Threads OpenMP") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  scale_color_manual(values = c("blue", "green", "red"))  # Set custom colors for threads


ggsave("./Parallelo/MPI 1.png",plot_mpi1)
ggsave("./Parallelo/MPI 2.png",plot_mpi2)



dataset_statistiche$Efficienza <- (dataset_statistiche$Speedup / (dataset_statistiche$`Processi MPI` * dataset_statistiche$`Threads OpenMP`)) * 100

colnames(dataset_statistiche) <- c("Dimensione Matrice (NxN)", "Processi MPI", "Threads OpenMP", "Tempo Parallelo", "Tempo Sequenziale", "Speedup", "Efficienza (%)")


# Crea un oggetto per MPI 1 (Efficienza)
mpi1_data_efficiency <- ggplot(dataset_statistiche[dataset_statistiche$`Processi MPI` == 1, ], 
                               aes(x = `Dimensione Matrice (NxN)`, y = `Efficienza (%)`, color = factor(`Threads OpenMP`))) +
  geom_line() +
  geom_point() +
  labs(title = "Efficienza - MPI 1",
       x = "Dimensione Matrice (NxN)",
       y = "Efficienza (%)",
       color = "Threads OpenMP") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  scale_color_discrete(name = "Threads OpenMP", labels = c("8", "6", "4"))

# Crea un oggetto per MPI 2 (Efficienza)
mpi2_data_efficiency <- ggplot(dataset_statistiche[dataset_statistiche$`Processi MPI` == 2, ], 
                               aes(x = `Dimensione Matrice (NxN)`, y = `Efficienza (%)`, color = factor(`Threads OpenMP`))) +
  geom_line() +
  geom_point() +
  labs(title = "Efficienza - MPI 2",
       x = "Dimensione Matrice (NxN)",
       y = "Efficienza (%)",
       color = "Threads OpenMP") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  scale_color_discrete(name = "Threads OpenMP", labels = c("8", "6", "4"))


ggsave("./Parallelo/MPI 1 Eff.png",mpi1_data_efficiency)
ggsave("./Parallelo/MPI 2 Eff.png",mpi2_data_efficiency)



# Esporta il risultati come CSV
write.csv(minimi_tempi_parallelo, "./Parallelo/Parallelo Ripulito.csv", row.names = FALSE)
write.csv(mpi1_data, "./Parallelo/Parallelo MPI 1.csv", row.names = FALSE)
write.csv(mpi2_data, "./Parallelo/Parallelo MPI 2.csv", row.names = FALSE)





################################################################################
####################################### CUDA ###################################
################################################################################



################################################################################
# Calcola il valore minimo del tempo di esecuzione raggruppando per dimensione #
#     [ Questo permette di ripulire il dataset da valori fuorvianti!!! ]       #
################################################################################


risultati_cuda <- read.csv("3) Risultati CUDA.csv", sep = ";", 
                           header = TRUE, check.names = FALSE)



plot_cuda <- ggplot(risultati_cuda, aes(x = `Dimensione Matrice (NxN)`, y = `Tempo di Esecuzione (sec)`)) +
  geom_point(color = "red") +
  geom_line(color = "red") +
  labs(title = "Esecuzione - CUDA (con OpenMP = 2)",
       x = "Dimensione Matrice (NxN)",
       y = "Tempo di Esecuzione (sec)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("./CUDA/CUDA.png", plot_cuda)



#SPEEDUP:

dataset_statistiche_CUDA <- merge(risultati_cuda, minimi_tempi_sequenziale, by = "Dimensione Matrice (NxN)")

colnames(dataset_statistiche_CUDA) <- c("Dimensione Matrice (NxN)", "Tempo CUDA", "Tempo Sequenziale")

dataset_statistiche_CUDA$Speedup <- dataset_statistiche_CUDA$`Tempo Sequenziale` / dataset_statistiche_CUDA$`Tempo CUDA`

colnames(dataset_statistiche_CUDA) <- c("Dimensione Matrice (NxN)", "Tempo CUDA", "Tempo Sequenziale", "Speedup")




plot_C <- ggplot(dataset_statistiche_CUDA, aes(x = `Dimensione Matrice (NxN)`, y = `Speedup`)) +
  geom_point(color = "red") +
  geom_line(color = "red") +
  labs(title = "Esecuzione - CUDA (con OpenMP = 2)",
       x = "Dimensione Matrice (NxN)",
       y = "SpeedUp") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold"))

ggsave("./CUDA/CUDA Speed.png", plot_C)



dataset_statistiche <- merge(dataset_statistiche, risultati_cuda[, c("Dimensione Matrice (NxN)", "Tempo di Esecuzione (sec)")] , by = "Dimensione Matrice (NxN)", suffixes = c("", "_CUDA"))

colnames(dataset_statistiche) <- c("Dimensione Matrice (NxN)", "Processi MPI", "Threads OpenMP", "Tempo Parallelo", "Tempo Sequenziale", "Speedup", "Efficienza (%)", "Tempo CUDA")



completo <- ggplot(dataset_statistiche, aes(x = `Dimensione Matrice (NxN)`, color = factor(`Threads OpenMP`))) +
  geom_line(aes(y = `Tempo Parallelo`, linetype = "Tempo Parallelo"), size = 0.5) +
  geom_line(aes(y = `Tempo Sequenziale`, linetype = "Tempo Sequenziale"), color = "black", size = 0.5) +
  geom_line(aes(y = `Tempo CUDA`, linetype = "Tempo CUDA"), color = "red", size = 0.5) +
  labs(title = "Esecuzione Parallela vs Sequenziale vs CUDA",
       x = "Dimensione Matrice (NxN)",
       y = "Tempo di Esecuzione (sec)") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5, face = "bold")) +
  scale_color_manual(name = "Threads OpenMP", values = c("4" = "green", "6" = "blue", "8" = "red")) +
  scale_linetype_manual(name = "", values = c("Tempo Parallelo" = "solid", "Tempo Sequenziale" = "dashed", "Tempo CUDA" = "dotted")) +
  facet_grid(`Processi MPI` ~ ., labeller = labeller(`Processi MPI` = c("1" = "MPI 1", "2" = "MPI 2")))

ggsave("Completo.png", completo)

