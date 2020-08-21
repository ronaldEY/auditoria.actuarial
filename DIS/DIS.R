
#Cambiar fecha de cierre

library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener año
library (dplyr)
library(DescTools)#Sumar meses a fecha

# Inicia borrando todo lo previamente cargada
rm(list=ls())

fecStart <-Sys.time() #toma como fecha de inicio la de la computadora

setwd(dirname(getActiveDocumentContext()$path))

#Cambiar en cada ejecución (la fecha en comillas)
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/DIS/CIA"
nombreBD <- "RSP_12_2019_C3.xlsx"
hojaBD <- "12.2019"
contratoDIS <- "3"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 


BD_DIS <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("text","text","text","text","text","numeric",
                                                                             "numeric","date","date","numeric","text","numeric",
                                                                             "date","numeric","numeric","numeric","numeric","text",
                                                                             "date","date","numeric","text","text","date","text",
                                                                             "text","text","numeric","text","text","date","text",
                                                                             "text","date","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","date",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","numeric","numeric","numeric",
                                                                             "numeric","numeric","date","text","text"))
View(BD_DIS)
BD_DIS_TIT <- BD_DIS[BD_DIS$`Tipo de pensionista` == "T" & BD_DIS$`Estado del siniestro a la fecha de reporte`!="Terminado",]


dfValidador <- data.frame(BD_DIS_TIT$`NUMERO UNICO DE SINIESTRO`, # ID
                          BD_DIS_TIT$`Número de solicitud`, # Número de la póliza
                          as.Date(rep(x = fecCierre,nrow(BD_DIS_TIT)), format = "%d/%m/%Y"), # Periodo
                          BD_DIS_TIT$`Fecha de devengo`, #Inicio de Vigencia
                          BD_DIS_TIT$`Fecha de devengo`, #Fecha de seleccion de tabla
                          BD_DIS_TIT$n2, #Periodo diferido
                          0, #Periodo garantizado
                          0, #Porcentaje Garantizado
                          ifelse(BD_DIS_TIT$`Tipo de Cobertura`=="GS","GS",ifelse(BD_DIS_TIT$`Tipo de Cobertura`=="S","SOB","INV")),#Cobertura
                          ifelse(BD_DIS_TIT$`Remuneración mensual`==0,BD_DIS_TIT$`Remuneración Mensual ajustada a fecha de reserva`/BD_DIS_TIT$`Factor de ajuste de Pensiones a fecha de reserva`,BD_DIS_TIT$`Remuneración mensual`), #Pensión base
                          12, #Frecuencia
                          ifelse(is.na(BD_DIS_TIT$Moneda) , "PEN",ifelse(BD_DIS_TIT$Moneda==1| BD_DIS_TIT$Moneda==3, "PEN","USD")), #Moneda
                          BD_DIS_TIT$`Tasa de ajuste`,#Ajuste
                          0, #Derecho acrecer
                          #ifelse(BD_DIS_TIT$Moneda==1, 0.0241,ifelse(BD_DIS_TIT$Moneda==3, 0.0567,ifelse(BD_DIS_TIT$Moneda==4,0.0426,0.033900))), #Tasa de costo equivalente RV
                          ifelse(is.na(BD_DIS_TIT$Moneda), 0.033900,ifelse(BD_DIS_TIT$Moneda==3, 0.0567,ifelse(BD_DIS_TIT$Moneda==4,0.0426,0.0241))), #Tasa de costo equivalente RV
                          0.0241, #Tasa de costo equivalente GS
                          NA, #Tasa costo de venta
                          NA,#Tasa de mercado
                          NA, #Fecha de emisión
                          0, #Caducada
                          ifelse(BD_DIS_TIT$`Tipo de pensionista`=="S","S","N"), #Pago gasto funerario
                          0, #Periodo temporal
                          0, #Porcentaje Segundo Tramo
                          BD_DIS_TIT$`Fecha de nacimiento`, #Fecha de nacimiento
                          BD_DIS_TIT$Sexo, #Sexo del titular
                          ifelse(BD_DIS_TIT$Salud=="I", substr(BD_DIS_TIT$`Tipo de Cobertura`,1,2),BD_DIS_TIT$Salud),#Salud
                          BD_DIS_TIT$`% de beneficio`, #Porcentaje de pensión
                          BD_DIS_TIT$`Fecha de fallecimiento`, #Fallecimiento del pensionista
                          stringsAsFactors = FALSE
                          )

str(dfValidador)
names(dfValidador) <- c('ID','POLIZA','PERIODO','FECHAINIVIG','FEC_SEL_TABLA',
                        'PDIFERIDO','PGARANTIZADO','PORC_PG','COBERTURA','PENSION_BASE','FRECUENCIA',
                        'MONEDA','AJUSTE','DERECHO_ACRECER','TASA_COSTO_EQUIV_RV','TASA_COSTO_EQUIV_GS',
                        'TASA_COSTO_VENTA','TASA_MERCADO','FECHA_EMISION','CADUCADA','PAGO_GASTO_FUNERARIO',
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

#i<-10

for (i in 1:filas) {
  contHijos <- 0
  dfBeneficiarios <- BD_DIS[BD_DIS$`NUMERO UNICO DE SINIESTRO`==dfValidador[i,"ID"] & BD_DIS$`Tipo de pensionista` != "T" & BD_DIS$`% de beneficio`>0,]
  benefVigentes<-nrow(dfBeneficiarios)
  contHijos<-nrow(BD_DIS[BD_DIS$`NUMERO UNICO DE SINIESTRO`==dfValidador[i,"ID"]  &BD_DIS$`Tipo de pensionista`=="H",])
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  #j<-2
  if(benefVigentes==0) next
  
  ##################################################################################################
  #j<-2
  cont<-0
  for(j in 1:benefVigentes) {
    #Para la CÓNYUGUE O CONCUBINA
    if(dfBeneficiarios[j,"Parentesco"]=="C"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fecha de nacimiento"]
      dfValidador[i,"SALUD_CONY"] <- ifelse(dfBeneficiarios[j,"Salud"]=="I",substr(dfBeneficiarios[j,"Salud"],1,2),dfBeneficiarios[j,"Salud"])
      #dfValidador[i,"PORC_CONY"] <- 1
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,'% de beneficio']
      
    #PARA EL PADRE
    }else if(dfBeneficiarios[j,"Parentesco"]=="P" & dfBeneficiarios[j,"Sexo"]=="M"){

        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"Fecha de nacimiento"]
        dfValidador[i,"SALUD_PAD"] <- ifelse(dfBeneficiarios[j,"Salud"]=="I",substr(dfBeneficiarios[j,"Salud"],1,2),dfBeneficiarios[j,"Salud"])
        #dfValidador[i,"PORC_PAD"] <- 1
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,'% de beneficio']

    #Para la madre
    }else if(dfBeneficiarios[j,"Parentesco"]=="P" & dfBeneficiarios[j,"Sexo"]=="F"){

      dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"Fecha de nacimiento"]
      dfValidador[i,"SALUD_MAD"] <- ifelse(dfBeneficiarios[j,"Salud"]=="I",substr(dfBeneficiarios[j,"Salud"],1,2),dfBeneficiarios[j,"Salud"])
      #dfValidador[i,"PORC_MAD"] <- 1
      dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,'% de beneficio']
    }else{
      cont<-cont+1
      dfValidador[i,paste0("SEXO_HIJ",cont)]<-dfBeneficiarios[j,"Sexo"]
      dfValidador[i,paste0("FECNAC_HIJ",cont)] <- dfBeneficiarios[j,"Fecha de nacimiento"]
      #dfValidador[i,paste0("SALUD_HIJ",cont)] <- ifelse(dfBeneficiarios[j,"Salud"]=="I",substr(dfBeneficiarios[j,"Salud"],1,2),dfBeneficiarios[j,"Salud"])
      dfValidador[i,paste0("SALUD_HIJ",cont)] <- ifelse(dfBeneficiarios[j,"Salud"]=="E","S",dfBeneficiarios[j,"Salud"])
      #dfValidador[i,paste0("PORC_HIJ",cont)] <- 1
      dfValidador[i,paste0("PORC_HIJ",cont)] <- dfBeneficiarios[j,'% de beneficio']
      #fechaLimite28 <- AddMonths(dfValidador[i,paste0("FECNAC_HIJ",cont)],18*12+7)#Se da meses de tolerancia
      fechaLimite28 <- AddMonths(dfValidador[i,paste0("FECNAC_HIJ",cont)],18*12+6)#Se da meses de tolerancia
      fechaCumple18 <- AddMonths(dfValidador[i,paste0("FECNAC_HIJ",cont)],18*12)
      if(dfValidador[i,paste0("SALUD_HIJ",cont)]=="I"){
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 111
      }else if(fechaCumple18<fecCierre & fechaLimite28<fecCierre & dfBeneficiarios[j,"Salud"]!="E"){
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 18  
      }else{
        dfValidador[i,paste0("EDAD_MAX_HIJ",cont)] <- 28  
      }
    } 
  }
  #################################################################################################
}

library(openxlsx)
write.xlsx(dfValidador, file=paste0(directorioBD,"/../BASE_DIS_",contratoDIS,"_",as.character(fecCierre,format = "%m%Y"),".xlsx"))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
