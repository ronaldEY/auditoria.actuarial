
#Cambiar fecha de cierre

library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener a?o
library (dplyr)
#library(plyr)
library(openxlsx)

# Inicia borrando todo lo previamente cargada
rm(list=ls())

fecStart <-Sys.time() #toma como fecha de inicio la de la computadora

setwd(dirname(getActiveDocumentContext()$path))

#Cambiar en cada ejecuci?n (la fecha en comillas)
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/Positiva Vida/2019/122019/Previsionales/CIA"
nombreBD <- "3.15 - Reservas siniestros Previsionales Reg. Definitivo - 12.2019 EY.xlsx"
hojaBD <- "REGIMEN DEFINITIVO - PROFUTURO"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 


BD_PREVRD <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("text","numeric","date","text",
                                                                             "text","text","date","numeric",
                                                                             "text","numeric","date","numeric",
                                                                             "date","text","numeric","numeric",
                                                                             "numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric",
                                                                             "numeric"))

BD_PREVRD_TIT <- BD_PREVRD


dfValidador <- data.frame(BD_PREVRD_TIT$`Nro. Sntro.`, # ID
                          BD_PREVRD_TIT$`Nro. Sntro.`, # N?mero de la p?liza
                          as.Date(rep(x = fecCierre,nrow(BD_PREVRD_TIT)), format = "%d/%m/%Y"), # Periodo
                          BD_PREVRD_TIT$`Fecha de Devengue`, #Inicio de Vigencia
                          BD_PREVRD_TIT$`Fecha de Devengue`, #Fecha de seleccion de tabla
                          NA, #Periodo diferido
                          NA, #Periodo garantizado
                          NA, #Porcentaje Garantizado
                          ifelse(BD_PREVRD_TIT$`Tipo de Sntro.`=="S" | BD_PREVRD_TIT$`Tipo de Sntro.`=="S+I", "SOB","INV"),#Cobertura
                          BD_PREVRD_TIT$Remuneraci?n, #Pensi?n base
                          12, #Frecuencia
                          ifelse(BD_PREVRD_TIT$Moneda=="US$", "USD","PEN"), #Moneda
                          ifelse(BD_PREVRD_TIT$Moneda=="NS Ajust", 0.02,0.00),#Ajuste
                          0, #Derecho acrecer
                          0.03, #Tasa de costo equivalente RV
                          0.03, #Tasa de costo equivalente GS
                          NA, #Tasa costo de venta
                          NA,#Tasa de mercado
                          BD_PREVRD_TIT$`Fecha de Devengue`, #Fecha de emisi?n
                          0, #Caducada
                          0,#Pago PG
                          ifelse(BD_PREVRD_TIT$`Tipo de C?lculo`=="Sobrevivencia Costo Real","S","N"), #Pago gasto funerario
                          0, #Periodo temporal
                          0, #Porcentaje Segundo Tramo
                          BD_PREVRD_TIT$`Fecha Nacimiento`, #Fecha de nacimiento
                          ifelse(BD_PREVRD_TIT$Sexo=="H","M","F"), #Sexo del titular
                          ifelse(substr(BD_PREVRD_TIT$`Tipo de Sntro.`,1,2)=="IT","IT", ifelse(substr(BD_PREVRD_TIT$`Tipo de Sntro.`,1,2)=="IP","IP","S")),#Salud
                          1, #Porcentaje de pensi?n
                          NA, #Fallecimiento del pensionista
                          stringsAsFactors = FALSE
                          )

str(dfValidador)
names(dfValidador) <- c('ID','POLIZA','PERIODO','FECHAINIVIG','FEC_SEL_TABLA',
                        'PDIFERIDO','PGARANTIZADO','PORC_PG','COBERTURA','PENSION_BASE','FRECUENCIA',
                        'MONEDA','AJUSTE','DERECHO_ACRECER','TASA_COSTO_EQUIV_RV','TASA_COSTO_EQUIV_GS',
                        'TASA_COSTO_VENTA','TASA_MERCADO','FECHA_EMISION','CADUCADA','PAGO_PG','PAGO_GASTO_FUNERARIO',
                        'PERIODO_TEMPORAL','PORC_SEGUNDO_TRAMO','FECNAC_TIT','SEXO_TIT','SALUD_TIT','PORC_TIT',
                        'FECFALLECIMIENTO_TIT'
                        )



dfValidador[1,"SEXO_CONY"]<-dfValidador[1,"SEXO_TIT"]
dfValidador[1,"FECNAC_CONY"]<-dfValidador[1,"FECNAC_TIT"]
dfValidador[1,"SALUD_CONY"]<-dfValidador[1,"SALUD_TIT"]
dfValidador[1,"PORC_CONY"]<-0.42

dfValidador[1,"FECNAC_PAD"]<-dfValidador[1,"FECNAC_TIT"]
dfValidador[1,"SALUD_PAD"]<-dfValidador[1,"SALUD_TIT"]
dfValidador[1,"PORC_PAD"]<-0.14

dfValidador[1,"FECNAC_MAD"]<-dfValidador[1,"FECNAC_TIT"]
dfValidador[1,"SALUD_MAD"]<-dfValidador[1,"SALUD_TIT"]
dfValidador[1,"PORC_MAD"]<-0.14

#Limpiando valores
dfValidador[1,"SEXO_CONY"]<-NA
dfValidador[1,"FECNAC_CONY"]<-NA
dfValidador[1,"SALUD_CONY"]<-NA
dfValidador[1,"PORC_CONY"]<-NA

dfValidador[1,"FECNAC_PAD"]<-NA
dfValidador[1,"SALUD_PAD"]<-NA
dfValidador[1,"PORC_PAD"]<-NA

dfValidador[1,"FECNAC_MAD"]<-NA
dfValidador[1,"SALUD_MAD"]<-NA
dfValidador[1,"PORC_MAD"]<-NA

#str(dfValidador)
filas <-nrow(dfValidador)

dfBeneficiarios <- read_excel("CIA/3.15 - Reservas siniestros Previsionales Reg. Definitivo - 12.2019 EY.xlsx", 
                              sheet = "Beneficiarios", col_types = c("text",	"numeric",	"date",
                                                                     "numeric",	"numeric",	"numeric"))
#i<-7
names(dfBeneficiarios)[2]<-"ID"

for (i in 1:filas) {
  contHijos <- 0
  
  dfBENEF<-dfBeneficiarios[dfBeneficiarios$ID==dfValidador[i,"ID"],]
  
  contHijos<-nrow(dfBENEF[dfBENEF$`C?d. Beneficiario`==2 | dfBENEF$`C?d. Beneficiario`==5|dfBENEF$`C?d. Beneficiario`==7 |dfBENEF$`C?d. Beneficiario`==8,])
  
  benefVigentes<-nrow(dfBENEF)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  
  
  #j<-2
  if(benefVigentes==0) next
  cont<-0
  for(j in 1:benefVigentes) {
    #Para la C?NYUGUE O CONCUBINA
    if(dfBENEF[j,"C?d. Beneficiario"]==1 | dfBENEF[j,"C?d. Beneficiario"]==4){
      dfValidador[i,"SEXO_CONY"] <- ifelse(dfBENEF[j,"C?d. Beneficiario"]==1,"M","F")
      dfValidador[i,"FECNAC_CONY"] <- dfBENEF[j,"Fecha Nacimiento"]
      dfValidador[i,"SALUD_CONY"] <- "S"
      dfValidador[i,"PORC_CONY"] <- dfBENEF[j,'% Remuneraci?n']
      
    #PARA EL PADRE
    }else if(dfBENEF[j,"C?d. Beneficiario"]==3){
        dfValidador[i,"FECNAC_PAD"] <- dfBENEF[j,"Fecha Nacimiento"]
        dfValidador[i,"SALUD_PAD"] <- "S"
        dfValidador[i,"PORC_PAD"] <- dfBENEF[j,'% Remuneraci?n']

    #Para la madre
    }else if(dfBENEF[j,"C?d. Beneficiario"]==6){
      dfValidador[i,"FECNAC_MAD"] <- dfBENEF[j,"Fecha Nacimiento"]
      dfValidador[i,"SALUD_MAD"] <- "S"
      dfValidador[i,"PORC_MAD"] <- dfBENEF[j,'% Remuneraci?n']
    }else{
      cont<-cont+1
      if(dfBENEF[j,"C?d. Beneficiario"]==2){
        dfValidador[i,paste0("SEXO_HIJ",cont)]<-"M"
        dfValidador[i,paste0("FECNAC_HIJ",cont)] <- dfBENEF[j,"Fecha Nacimiento"]
        dfValidador[i,paste0("SALUD_HIJ",cont)] <- "S"
      }else if(dfBENEF[j,"C?d. Beneficiario"]==5){
        dfValidador[i,paste0("SEXO_HIJ",cont)]<-"F"
        dfValidador[i,paste0("FECNAC_HIJ",cont)] <- dfBENEF[j,"Fecha Nacimiento"]
        dfValidador[i,paste0("SALUD_HIJ",cont)] <- "S"
      }else if(dfBENEF[j,"C?d. Beneficiario"]==7){  
        dfValidador[i,paste0("SEXO_HIJ",cont)]<-"M"
        dfValidador[i,paste0("FECNAC_HIJ",cont)] <- dfBENEF[j,"Fecha Nacimiento"]
        dfValidador[i,paste0("SALUD_HIJ",cont)] <- "IT"
      }else{
        dfValidador[i,paste0("SEXO_HIJ",cont)]<-"F"
        dfValidador[i,paste0("FECNAC_HIJ",cont)] <- dfBENEF[j,"Fecha Nacimiento"]
        dfValidador[i,paste0("SALUD_HIJ",cont)] <- "IT"
      }
      dfValidador[i,paste0("PORC_HIJ",cont)] <- dfBENEF[j,'% Remuneraci?n']
      if(dfValidador[i,paste0("SALUD_HIJ",cont)]=="IT"){
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 111  
      }else if(dfValidador[i,"FECHAINIVIG"]<fecHijos28){
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 18
      }else{
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 28
      }    
    } 
   }
 }

write.xlsx(dfValidador, file=paste(directorioBD,"/../BASE_PREVI_RD_LPV_",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()

print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
