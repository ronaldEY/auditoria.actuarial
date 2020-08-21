
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
directorioBD <- "C:/Ronald/Auditorias/Positiva Vida/2019/122019/Renta Particular/CIA"
nombreBD <- "N-6-3 Reservas técnicas por primas_renta particular al 31.12.19.xlsx"
hojaBD <- "N-6-3.1"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 

BD_RP <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("numeric","text","numeric","text","text","text","text","numeric",
                                                       "date","numeric","text","numeric","text","text","numeric","text",
                                                       "numeric","numeric","numeric","numeric","numeric","text","text","numeric",
                                                       "text","numeric","text","text","text","date","date","numeric","numeric",
                                                       "numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric",
                                                       "numeric","numeric","numeric","numeric"))

#Parentescos
#Titular:80
#Conyuge:10
#Hijos:30
#Padres:40
#BD_RRVV$`Reserva Base Soles`

BD_RP_TIT <- BD_RP[BD_RP$`Tipo de pensionista` == "T",]


dfValidador <- data.frame(BD_RP_TIT$`Número de la póliza`, # ID
                          BD_RP_TIT$`Número de la póliza`, # Número de la póliza
                          as.Date(rep(x = fecCierre,nrow(BD_RP_TIT)), format = "%d/%m/%Y"),
                          BD_RP_TIT$`Fecha Inicio Vigencia`, #Inicio de Vigencia
                          BD_RP_TIT$`Fecha Inicio Vigencia`, #Fecha seleccion tabla
                          ifelse(BD_RP_TIT$`Tipo Renta`=="Renta Temporal",BD_RP_TIT$`Vigencia Total (años)`*12+BD_RP_TIT$`Años Período Diferido`*12, 111*12), #Periodo Total
                          BD_RP_TIT$`Años Período Diferido`*12, #Periodo Diferido
                          BD_RP_TIT$`Años Período Garantizado`*12, #Periodo Garantizado
                          1, #Porcentaje Garantizado
                          BD_RP_TIT$`Tipo Renta`, #Cobertura
                          with(BD_RP_TIT,BD_RP_TIT$`Monto de la pensión actualizada`/BD_RP_TIT$`% Renta Temporal`), # Pensión Base
                          ifelse(BD_RP_TIT$`Gratificación?`=="N",12,14), # Frecuencia
                          ifelse(toupper(BD_RP_TIT$`Moneda de la Renta`) =="SOLES","PEN", "USD"), # Moneda
                          BD_RP_TIT$`% Ajuste Moneda de la Renta`, #Ajuste
                          ifelse(BD_RP_TIT$`Derecho a Crecer?`=="N",0,1), #Derecho a crecer
                          BD_RP_TIT$`Tasa de Reserva`, #Tasa costo equivalente RV
                          BD_RP_TIT$`Tasa de Reserva`, #Tasa costo equivalente GS
                          BD_RP_TIT$`Tasa de Venta`, #Tasa de venta
                          0, #Tasa de mercado
                          BD_RP_TIT$`Fecha Inicio Vigencia`, #Fecha de emisión
                          0, #Caducada
                          NA, #Pago gastos funerarios
                          BD_RP_TIT$`Tramo 1`*12, #Periodo temporal
                          BD_RP_TIT$`% Renta Temporal`,#Porcentaje Segundo Tramo
                          BD_RP_TIT$`Suma Asegurada Sepelio (Moneda de la Renta)`, #GS
                          BD_RP_TIT$`Prima Única (Moneda Original)`, #Monto transferido
                          BD_RP_TIT$`% Devolución de Prima Única`, #Porcentaje de Devolución
                          BD_RP_TIT$`Fecha de Nacimiento`, #Fecha de Nacimiento del titular
                          BD_RP_TIT$Género, #Sexo del titular
                          BD_RP_TIT$`Condición de Salud`, #Salud del titular
                          BD_RP_TIT$`Porcentaje Pensión`, #% de pensión del titular
                          BD_RP_TIT$`Fecha de Fallecimiento`, #Fecha de fallecimeinto del titular
                          stringsAsFactors = FALSE
                          )

str(dfValidador)
names(dfValidador) <- c('ID','POLIZA','PERIODO','FECHAINIVIG','FEC_SEL_TABLA','PTOTAL','PDIFERIDO',
                        'PGARANTIZADO','PORC_PG','COBERTURA','PENSION_BASE','FRECUENCIA','MONEDA','AJUSTE',
                        'DERECHO_ACRECER','TASA_COSTO_EQUIV_RV','TASA_COSTO_EQUIV_GS','TASA_COSTO_VENTA',
                        'TASA_MERCADO','FECHA_EMISION','CADUCADA','PAGO_GASTO_FUNERARIO','PERIODO_TEMPORAL',
                        'PORC_SEGUNDO_TRAMO','GS','MTO TRANSFERIDO','PORC_DEV','FECNAC_TIT','SEXO_TIT',
                        'SALUD_TIT','PORC_TIT','FECFALLECIMIENTO_TIT'
                        )



dfValidador[1,"SEXO_CONY"]<-dfValidador[1,"SEXO_TIT"]
dfValidador[1,"FECNAC_CONY"]<-dfValidador[1,"FECNAC_TIT"]
dfValidador[1,"SALUD_CONY"]<-dfValidador[1,"SALUD_TIT"]
dfValidador[1,"PORC_CONY"]<-0.42
dfValidador[1,"PERIODO_CONY"]<-0

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
dfValidador[1,"PERIODO_CONY"]<-NA

dfValidador[1,"FECNAC_PAD"]<-NA
dfValidador[1,"SALUD_PAD"]<-NA
dfValidador[1,"PORC_PAD"]<-NA

dfValidador[1,"FECNAC_MAD"]<-NA
dfValidador[1,"SALUD_MAD"]<-NA
dfValidador[1,"PORC_MAD"]<-NA

str(dfValidador)
filas <-nrow(dfValidador)

#i<-12
for (i in 1:filas) {
  contHijos <- 0
  dfBeneficiarios <- BD_RP[BD_RP$`Número de la póliza`==dfValidador[i,"ID"] & BD_RP$`Tipo de pensionista` != "T",]
  benefVigentes<-nrow(dfBeneficiarios)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos

  #j<-2
  if(benefVigentes==0) next
  
  ##################################################################################################
  #j<-1
  cont<-0
  for(j in 1:benefVigentes) {
    #Para la CÓNYUGUE O CONCUBINA
    if(dfBeneficiarios[j,"Parentesco"]=="CO"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"Género"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
      dfValidador[i,"SALUD_CONY"] <- dfBeneficiarios[j,"Condición de Salud"]
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,'Porcentaje Pensión']
      dfValidador[i,"PERIODO_CONY"]<- ifelse(is.na(dfBeneficiarios[j,'Vigencia Pensionista (años)']),111*12,dfValidador[i,"PDIFERIDO"]+dfBeneficiarios[j,'Vigencia Pensionista (años)']*12 )
      #En vitalicias carga como NA
      # if(is.na(dfBeneficiarios[j,'Vigencia Pensionista (años)'])){
      #   dfValidador[i,"PERIODO_CONY"]<- 111*12
      # }else{
      #   dfValidador[i,"PERIODO_CONY"]<- dfValidador[i,"PDIFERIDO"]+dfBeneficiarios[j,'Vigencia Pensionista (años)']*12  
      # }
    #PARA EL PADRE
    }else if(dfBeneficiarios[j,"Parentesco"]=="PA"){

        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
        dfValidador[i,"SALUD_PAD"] <- dfBeneficiarios[j,"Condición de Salud"]
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,'Porcentaje Pensión']

    #Para la madre
    }else if(dfBeneficiarios[j,"Parentesco"]=="MA"){

      dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
      dfValidador[i,"SALUD_MAD"] <- dfBeneficiarios[j,"Condición de Salud"]
      dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,'Porcentaje Pensión']
    }else{
      cont<-cont+1
      dfValidador[i,paste0("SEXO_BEN",cont)]<-dfBeneficiarios[j,"Género"]
      dfValidador[i,paste0("FECNAC_BEN",cont)] <- dfBeneficiarios[j,"Fecha de Nacimiento"]
      dfValidador[i,paste0("SALUD_BEN",cont)] <- dfBeneficiarios[j,"Condición de Salud"]
      dfValidador[i,paste0("PORC_BEN",cont)] <- dfBeneficiarios[j,'Porcentaje Pensión']
      dfValidador[i,paste0("PERIODO_BEN",cont)] <- ifelse(is.na(dfBeneficiarios[j,'Vigencia Pensionista (años)']),111*12,dfValidador[i,"PDIFERIDO"]+dfBeneficiarios[j,'Vigencia Pensionista (años)']*12 )
    } 
    
  }
}

  
#View(dfValidador)
library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BASE_RP_LPV",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
