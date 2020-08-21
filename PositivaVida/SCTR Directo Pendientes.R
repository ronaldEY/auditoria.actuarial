
#Cambiar fecha de cierre

library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener a?o
library (dplyr)

# Inicia borrando todo lo previamente cargada
rm(list=ls())

fecStart <-Sys.time() #toma como fecha de inicio la de la computadora

setwd(dirname(getActiveDocumentContext()$path))

#Cambiar en cada ejecuci?n (la fecha en comillas)
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/Positiva Vida/2019/122019/SCTR/CIA"
nombreBD <- "SCTR Directos BD Siniestros Pendientes - 12.2019.xlsx"
hojaBD <- "BD Siniestros Pendientes SCTR"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 

BD_SCTRD <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("text","text","text","numeric","numeric",
                                                                             "numeric","text","numeric","text",
                                                                             "date","text","text","numeric",
                                                                             "numeric","text","date","date",
                                                                             "date","numeric","numeric",
                                                                             "numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric",
                                                                             "numeric","text"))
BD_SCTRD_TIT <- BD_SCTRD[BD_SCTRD$`Tipo de Pensionista` == "T",]


dfValidador <- data.frame(BD_SCTRD_TIT$ID, # ID
                          BD_SCTRD_TIT$`N?mero de P?liza`, # N?mero de la p?liza
                          as.Date(rep(x = fecCierre,nrow(BD_SCTRD_TIT)), format = "%d/%m/%Y"), # Periodo
                          BD_SCTRD_TIT$`Fecha de Ocurrencia del Siniestro`, #Inicio de Vigencia
                          NA, #Fin de vigencia
                          BD_SCTRD_TIT$`Fecha de Ocurrencia del Siniestro`, #Fecha de seleccion de tabla
                          NA, #Periodo diferido
                          NA, #Periodo garantizado
                          NA, #Porcentaje Garantizado
                          ifelse(BD_SCTRD_TIT$`Tipo de Cobertura`=="IT" | BD_SCTRD_TIT$`Tipo de Cobertura`=="IP", "INV","SOB"),#Cobertura
                          BD_SCTRD_TIT$`Monto de la Remuneraci?n Base`, #Pensi?n base
                          ifelse(BD_SCTRD_TIT$Gratificaci?n=="S",14,12), #Frecuencia
                          ifelse(BD_SCTRD_TIT$Moneda==1, "PEN","USD"), #Moneda
                          BD_SCTRD_TIT$`Tasa de Reajuste`,#Ajuste
                          0, #Derecho acrecer
                          0.03, #Tasa de costo equivalente RV
                          0.03, #Tasa de costo equivalente GS
                          NA, #Tasa costo de venta
                          NA,#Tasa de mercado
                          BD_SCTRD_TIT$`Fecha de Ocurrencia del Siniestro`, #Fecha de emisi?n
                          0, #Caducada
                          0,#Pago PG
                          0, #Pago gasto funerario
                          0, #Periodo temporal
                          0, #Porcentaje Segundo Tramo
                          BD_SCTRD_TIT$`Fecha de Nacimiento del Pensionista`, #Fecha de nacimiento
                          BD_SCTRD_TIT$Sexo, #Sexo del titular
                          BD_SCTRD_TIT$`Tipo de Cobertura`,#Salud
                          BD_SCTRD_TIT$`% Pensi?n`, #Porcentaje de pensi?n
                          BD_SCTRD_TIT$`Fecha de Fallecimiento del Pensionista`, #Fallecimiento del pensionista
                          stringsAsFactors = FALSE
                          )

str(dfValidador)
names(dfValidador) <- c('ID','POLIZA','PERIODO','FECHAINIVIG','FECHAFINVIG','FEC_SEL_TABLA',
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

str(dfValidador)
filas <-nrow(dfValidador)

#i<-1

for (i in 1:filas) {
  contHijos <- 0
  dfBeneficiarios <- BD_SCTRD[BD_SCTRD$ID==dfValidador[i,"ID"] & BD_SCTRD$`Tipo de Pensionista` != "T",]
  benefVigentes<-nrow(dfBeneficiarios)
  contHijos<-nrow(BD_SCTRD[BD_SCTRD$`N?mero de P?liza`==dfValidador[i,"ID"]  &BD_SCTRD$`Relaci?n Familiar`=="H",])
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  #j<-2
  if(benefVigentes==0) next
  
  ##################################################################################################
  #j<-1
  cont<-0
  for(j in 1:benefVigentes) {
    #Para la C?NYUGUE O CONCUBINA
    if(dfBeneficiarios[j,"Relaci?n Familiar"]=="C"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fecha de Nacimiento del Pensionista"]
      dfValidador[i,"SALUD_CONY"] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,'% Pensi?n']
      
    #PARA EL PADRE
    }else if(dfBeneficiarios[j,"Relaci?n Familiar"]=="P" & dfBeneficiarios[j,"Sexo"]=="M"){

        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"Fecha de Nacimiento del Pensionista"]
        dfValidador[i,"SALUD_PAD"] <- dfBeneficiarios[j,"Salud"]
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,'% Pensi?n']

    #Para la madre
    }else if(dfBeneficiarios[j,"Relaci?n Familiar"]=="P" & dfBeneficiarios[j,"Sexo"]=="F"){

      dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"Fecha de Nacimiento del Pensionista"]
      dfValidador[i,"SALUD_MAD"] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,'% Pensi?n']
    }else{
      cont<-cont+1
      dfValidador[i,paste0("SEXO_HIJ",cont)]<-dfBeneficiarios[j,"Sexo"]
      dfValidador[i,paste0("FECNAC_HIJ",cont)] <- dfBeneficiarios[j,"Fecha de Nacimiento del Pensionista"]
      dfValidador[i,paste0("SALUD_HIJ",cont)] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,paste0("PORC_HIJ",cont)] <- dfBeneficiarios[j,'% Pensi?n']
      if(dfValidador[i,paste0("SALUD_HIJ",cont)]=="I"){
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 111  
      }else if(dfValidador[i,"FECHAINIVIG"]<fecHijos28){
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 18
      }else{
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 28
      }
        
      
    } 
    
  }
}

library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BASE_SCTRD_Pendientes_",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
