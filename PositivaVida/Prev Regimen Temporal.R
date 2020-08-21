#Cambiar fecha de cierre

library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener a?o
library (dplyr)
#library(plyr)

# Inicia borrando todo lo previamente cargada
rm(list=ls())

fecStart <-Sys.time() #toma como fecha de inicio la de la computadora

setwd(dirname(getActiveDocumentContext()$path))

#Cambiar en cada ejecuci?n (la fecha en comillas)
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/Positiva Vida/2019/122019/Previsionales/CIA"
nombreBD <- "N-5-1.2 Reservas técnicas por siniestros_previsionales RT 31.12.19.xlsx"
hojaBD <- "N-5-1.2.2"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 

BD_PREVRT <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("text","date","date","numeric","numeric","numeric",
                                                         "text","numeric","date","numeric","numeric","numeric",
                                                         "numeric","date","text","text","numeric"))

BD_PREVRT_TIT <- BD_PREVRT[BD_PREVRT$`Beneficiario` == "TITULAR",]


dfValidador <- data.frame(BD_PREVRT_TIT$`N?mero de Siniestro`, # ID
                          BD_PREVRT_TIT$`N?mero de Siniestro`, # N?mero de la p?liza
                          BD_PREVRT_TIT$`Fecha de C?lculo`, # Periodo
                          BD_PREVRT_TIT$`Fecha de siniestro`, #Inicio de Vigencia
                          BD_PREVRT_TIT$`Fecha de siniestro`, #Fecha de seleccion de tabla
                          NA, #Periodo diferido
                          NA, #Periodo garantizado
                          1, #Porcentaje Garantizado
                          BD_PREVRT_TIT$Cobertura,#Cobertura
                          BD_PREVRT_TIT$`Remuneraci?n promedio`, #Pensi?n base
                          12, #Frecuencia
                          "PEN", #Moneda
                          0,#Ajuste
                          0, #Derecho acrecer
                          BD_PREVRT_TIT$`Costo Equivalente`, #Tasa de costo equivalente RV
                          BD_PREVRT_TIT$`Costo Equivalente`, #Tasa de costo equivalente GS
                          NA, #Tasa costo de venta
                          NA,#Tasa de mercado
                          BD_PREVRT_TIT$`Fecha de siniestro`, #Fecha de emisi?n
                          0, #Caducada
                          0,#Pago PG
                          0, #Pago gasto funerario
                          0, #Periodo temporal
                          0, #Porcentaje Segundo Tramo
                          BD_PREVRT_TIT$`Fecha de Nacimiento`, #Fecha de nacimiento
                          "M", #Sexo del titular
                          BD_PREVRT_TIT$Salud,#Salud
                          BD_PREVRT_TIT$`% de Beneficio`, #Porcentaje de pensi?n
                          BD_PREVRT_TIT$`Fecha Fallecimiento`, #Fallecimiento del pensionista
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

str(dfValidador)
filas <-nrow(dfValidador)

#i<-1

for (i in 1:filas) {
  contHijos <- 0
  dfBeneficiarios <- BD_PREVRT[BD_PREVRT$`N?mero de Siniestro`==dfValidador[i,"ID"] & BD_PREVRT$Beneficiario!="TITULAR",]
  benefVigentes<-nrow(dfBeneficiarios)
  contHijos<-nrow(BD_PREVRT[BD_PREVRT$`N?mero de Siniestro`==dfValidador[i,"ID"]  & substr(BD_PREVRT$Beneficiario,1,1)=="H",])
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  #j<-2
  if(benefVigentes==0) next
  
  ##################################################################################################
  #j<-1
  cont<-0
  for(j in 1:benefVigentes) {
    #Para la C?NYUGUE O CONCUBINA
    if(dfBeneficiarios[j,"Beneficiario"]=="ESPOSO" | dfBeneficiarios[j,"Beneficiario"]=="ESPOSA"){
      dfValidador[i,"SEXO_CONY"] <- ifelse(dfBeneficiarios[j,"Beneficiario"]=="ESPOSO","M","F")
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
      dfValidador[i,"SALUD_CONY"] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,'% de Beneficio']
      
    #PARA EL PADRE
    }else if(dfBeneficiarios[j,"Beneficiario"]=="PADRE"){

        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
        dfValidador[i,"SALUD_PAD"] <- dfBeneficiarios[j,"Salud"]
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,'% de Beneficio']

    #Para la madre
    }else if(dfBeneficiarios[j,"Beneficiario"]=="MADRE"){

      dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
      dfValidador[i,"SALUD_MAD"] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,'% de Beneficio']
    }else{
      cont<-cont+1
      dfValidador[i,paste0("SEXO_HIJ",cont)]<-ifelse(dfBeneficiarios[j,"Beneficiario"]=="HIJO","M","F")
      dfValidador[i,paste0("FECNAC_HIJ",cont)] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
      dfValidador[i,paste0("SALUD_HIJ",cont)] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,paste0("PORC_HIJ",cont)] <- dfBeneficiarios[j,'% de Beneficio']
      dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 18
    } 
    
  }
  #################################################################################################
}

library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BASE_PREVRT",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
