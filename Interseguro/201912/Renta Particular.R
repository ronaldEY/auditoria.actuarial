
#Cambiar fecha de cierre

library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener año
library (dplyr)

# Inicia borrando todo lo previamente cargada
rm(list=ls())

fecStart <-Sys.time() #toma como fecha de inicio la de la computadora

setwd(dirname(getActiveDocumentContext()$path))

#Cambiar en cada ejecución (la fecha en comillas)
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/Interseguro/SBS/122019/Renta Particular/CIA"
nombreBD <- "Q-1-3 Reserva de Primas de Renta Particular Plus al 31.12.19_mod.xlsx"
hojaBD <- "Q-1-3-1"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 

BD_RP <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("date","numeric","numeric","text","numeric",
                                                       "text","text","numeric","text","text","text",
                                                       "text","text","numeric","text","date","date",
                                                       "date","text","text","text","date","numeric",
                                                       "numeric","text","numeric","numeric","numeric",
                                                       "numeric","numeric","numeric","numeric","text",
                                                       "numeric","numeric","numeric","numeric","text",
                                                       "numeric","numeric","numeric","numeric","date",
                                                       "date","date","numeric","date","numeric","numeric",
                                                       "numeric","numeric","numeric","numeric","numeric",
                                                       "date"))

BD_RP_TIT <- BD_RP[BD_RP$`Cod. Parentesco` == 80,]


#Parentescos
#Titular:80
#Conyuge:10
#Hijos:30
#Padres:40
#Hermano:92
#Sobrino:93
#Otro:94
#Nieto:95

dfValidador <- data.frame(BD_RP_TIT$`Nro. Póliza`, # ID
                          BD_RP_TIT$`Nro. Póliza`, # Número de la Póliza
                          as.Date(rep(x = fecCierre,nrow(BD_RP_TIT)), format = "%d/%m/%Y"), # Periodo
                          BD_RP_TIT$`Fec. Devengue`, #Inicio de Vigencia
                          BD_RP_TIT$`Fec. Cotización`, #Fecha de seleccion de tabla
                          #apply(data.frame(BD_RP_TIT$`Nro. Meses Diferido`, BD_RP_TIT$`Nro. Meses Temporalidad`,BD_RP_TIT$`Nro. Meses Garantizados`),1,max), #Periodo Total
                          ifelse(BD_RP_TIT$`Nro. Meses Temporalidad`==0, 1332,BD_RP_TIT$`Nro. Meses Temporalidad`), #Periodo Total
                          BD_RP_TIT$`Nro. Meses Diferido`, #Periodo diferido
                          apply(data.frame(BD_RP_TIT$`Nro. Meses Garantizados`-BD_RP_TIT$`Nro. Meses Diferido`,0),1,max), #Periodo garantizado
                          1, #Porcentaje Garantizado
                          "JUB",#Cobertura
                          BD_RP_TIT$`Renta 1° Tramo`, #Pensión base
                          12, #Frecuencia
                          ifelse(BD_RP_TIT$`Moneda de la Renta`=="SOLES","VAC",ifelse(BD_RP_TIT$`Moneda de la Renta`=="Soles Ajustados", "PEN","USD")), #Moneda
                          BD_RP_TIT$`% Ajuste`,#Ajuste
                          0, #Derecho acrecer
                          BD_RP_TIT$`Tasa de Reserva`, #Tasa de costo equivalente RV
                          BD_RP_TIT$`Tasa de Reserva`, #Tasa de costo equivalente GS
                          BD_RP_TIT$`Tasa de venta IS`, #Tasa costo de venta
                          NA,#Tasa de mercado
                          BD_RP_TIT$`Fec. Emisión Póliza`, #Fecha de Emisión
                          0, #Caducada
                          0, #Pago gasto funerario
                          BD_RP_TIT$`Nro. Meses Doble Pago`, #Periodo temporal
                          BD_RP_TIT$`% 2° Tramo`, #Porcentaje Segundo Tramo
                          BD_RP_TIT$`Devolución Fallecimiento`,#% de Fallecimiento (momentáneo)
                          BD_RP_TIT$`Monto PU Cotización`,#Monto Transferido
                          BD_RP_TIT$`Devolución Sobrevivencia`,#Porcentaje de Devolución
                          BD_RP_TIT$`Fec. Nacimiento`, #Fecha de nacimiento
                          BD_RP_TIT$Sexo, #Sexo del titular
                          "S",#Salud (momentáneamente)
                          BD_RP_TIT$`% Renta`, #Porcentaje de Pensión
                          BD_RP_TIT$`Fec. Fallecimiento`, #Fallecimiento del pensionista
                          stringsAsFactors = FALSE
                          )

str(dfValidador)
names(dfValidador) <- c('ID','POLIZA','PERIODO','FECHAINIVIG','FEC_SEL_TABLA', 'PTOTAL',
                        'PDIFERIDO','PGARANTIZADO','PORC_PG','COBERTURA','PENSION_BASE','FRECUENCIA',
                        'MONEDA','AJUSTE','DERECHO_ACRECER','TASA_COSTO_EQUIV_RV','TASA_COSTO_EQUIV_GS',
                        'TASA_COSTO_VENTA','TASA_MERCADO','FECHA_EMISION','CADUCADA','PAGO_GASTO_FUNERARIO',
                        'PERIODO_TEMPORAL','PORC_SEGUNDO_TRAMO','GS','MTO TRANSFERIDO','PORC_DEV','FECNAC_TIT',
                        'SEXO_TIT','SALUD_TIT','PORC_TIT','FECFALLECIMIENTO_TIT'
                        )



dfValidador[1,"SEXO_CONY"]<-dfValidador[1,"SEXO_TIT"]
dfValidador[1,"FECNAC_CONY"]<-dfValidador[1,"FECNAC_TIT"]
dfValidador[1,"SALUD_CONY"]<-dfValidador[1,"SALUD_TIT"]
dfValidador[1,"PORC_CONY"]<-0.42
#dfValidador[1,"PERIODO_CONY"]<-0


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
#dfValidador[1,"PERIODO_CONY"]<-NA

dfValidador[1,"FECNAC_PAD"]<-NA
dfValidador[1,"SALUD_PAD"]<-NA
dfValidador[1,"PORC_PAD"]<-NA

dfValidador[1,"FECNAC_MAD"]<-NA
dfValidador[1,"SALUD_MAD"]<-NA
dfValidador[1,"PORC_MAD"]<-NA

str(dfValidador)
filas <-nrow(dfValidador)

#i<-2

for (i in 1:filas) {
  contHijos <- 0
  dfBeneficiarios <- BD_RP[BD_RP$`Nro. Póliza`==dfValidador[i,"ID"] & BD_RP$`Cod. Parentesco` != 80,]
  benefVigentes<-nrow(dfBeneficiarios)
  contHijos<-nrow(BD_RP[BD_RP$`Nro. Póliza`==dfValidador[i,"ID"]  & BD_RP$`Cod. Parentesco` ==30,])
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  #j<-2
  if(benefVigentes==0) next
  
  ##################################################################################################
  #j<-1
  cont<-0
  for(j in 1:benefVigentes) {
    #Para la CONYUGUE O CONCUBINA
    if(dfBeneficiarios[j,"Cod. Parentesco"]==10){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fec. Nacimiento"]
      dfValidador[i,"SALUD_CONY"] <- "S"
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,'% Renta']
      #dfValidador[i,"PERIODO_CONY"]<-dfValidador[i,"PTOTAL"]
      
    #PARA EL PADRE
    }else if(dfBeneficiarios[j,"Cod. Parentesco"]==40 & dfBeneficiarios[j,"Sexo"]=="M"){

        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"Fec. Nacimiento"]
        dfValidador[i,"SALUD_PAD"] <- "S"
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,'% Renta']

    #Para la madre
    }else if(dfBeneficiarios[j,"Cod. Parentesco"]==40 & dfBeneficiarios[j,"Sexo"]=="F"){

      dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"Fec. Nacimiento"]
      dfValidador[i,"SALUD_MAD"] <- "S"
      dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,'% Renta']
    }else{
      cont<-cont+1
      dfValidador[i,paste0("SEXO_BENEF",cont)]<-dfBeneficiarios[j,"Sexo"]
      dfValidador[i,paste0("FECNAC_BENEF",cont)] <- dfBeneficiarios[j,"Fec. Nacimiento"]
      dfValidador[i,paste0("SALUD_BENEF",cont)] <- "S"
      dfValidador[i,paste0("PORC_BENEF",cont)] <- dfBeneficiarios[j,'% Renta']
      dfValidador[i,paste0("EDAD_MAX_BENEF",cont)] <- 18
    } 
    
  }
  #################################################################################################
}

library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BASE_RP_IS",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
