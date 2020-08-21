#Cambiar fecha de cierre
library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener a?o
library(DescTools)#Sumar meses a fecha
library(dplyr)
rm(list=ls())#Limpia objetos
fecStart <-Sys.time()
setwd(dirname(getActiveDocumentContext()$path))
#Cambiar en cada Ejecucion
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/Positiva Vida/2019/122019/SCTR/CIA"
nombreBD <- "N-6-05 Reservas t?cnicas por primas_SCTR ONP 31.12.19.xlsx"
hojaBD <- "N-6-4.1"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y")
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 

#Colocar en 0 la tasa de ajuste VAC
#Colocar en Texto en Columnas Pension 


BD_RRVV <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("text","text","text","text","text","text","text","text","numeric",
                                                       "text","text","text","numeric","numeric","date","date","numeric","date","text","text","text","date","date","text","text","numeric","numeric","numeric","numeric","numeric","text","date","text","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric","numeric"))
#View(BD_RRVV)
#BD_RRVV$`Reserva Base Soles`
BD_RRVV_TIT <- BD_RRVV[BD_RRVV$`Relaci?n familiar` == "T",]

dfValidador <- data.frame(BD_RRVV_TIT$`P?liza/Siniestros`, # ID
                          BD_RRVV_TIT$`P?liza/Siniestros`, # Poliza
                          as.Date(rep(x = fecCierre,nrow(BD_RRVV_TIT)), format = "%d/%m/%Y"), #Periodo
                          BD_RRVV_TIT$`Fecha de devengue`,#Inicio de Vigencia
                          BD_RRVV_TIT$`Fecha Fin de Invalidez`,
                          BD_RRVV_TIT$`Fecha de devengue`,#Fec. Seleccion de Tablas
                          0,#BD_RRVV_TIT$`Per?odo diferido`*12, #"PDIFERIDO"
                          0,#BD_RRVV_TIT$`Per?odo garantizado`*12, #"PGarantizado"
                          0,#1,#Porc. PG
                          substr(BD_RRVV_TIT$Prestaci?n,1,3),#"COBERTURA"
                          with(BD_RRVV_TIT, `Remuneraci?n Base`*`Ajuste de la pensi?n`), #ifelse(BD_RRVV_TIT$`%RVE`>0,with(BD_RRVV_TIT,`Pensi?n 1? Tramo RVE`*`Ajuste de la pensi?n`),with(BD_RRVV_TIT, `Remuneraci?n Base`*`Ajuste de la pensi?n`)),#"PENSION_BASE" 0
                          12,#ifelse(BD_RRVV_TIT$`Gratificaci?n?` == "S",14,12),#Cantidad de Pagos (Gratificacion o no) 12
                          "PEN",
                          BD_RRVV_TIT$`Tasa de Ajuste`,
                          0,#ifelse(BD_RRVV_TIT$`Indicador de Derecho a Crecer`=="N",0,1),
                          BD_RRVV_TIT$`Tasa de Costo Equivalente`, #"TASA_COSTO_EQUIV_RV"
                          BD_RRVV_TIT$`Tasa de Costo Equivalente`, #"TASA_COSTO_EQUIV_GS"
                          0,#BD_RRVV_TIT$`Tasa de Venta`, 
                          0.03,#BD_RRVV_TIT$`Tasa de Mercado`,#Campo Tasa Mercado 0
                          BD_RRVV_TIT$`Fecha de entrada en vigencia de la p?liza`, # Fecha de Emision
                          0, #Campo CADUCADA para BD Rimac
                          0,#BD_RRVV_TIT$`Pago de Periodo Garantizado?`,
                          ifelse(fecFallecimiento<BD_RRVV_TIT$`Fecha de fallecimiento pensionista`,"S","N"), #Campo PAGO_GASTO_FUNERARIO para BD Rimac
                          0,#BD_RRVV_TIT$PRIMER_TRAMO*12,#Duracion tramo sin renta escalonada, es 0 cuando no es renta escalonada  0
                          0,#BD_RRVV_TIT$`%RVE`, #Porcentaje Segundo Tramo 0
                          BD_RRVV_TIT$`Fecha de nacimiento pensionista`,
                          BD_RRVV_TIT$Sexo,
                          BD_RRVV_TIT$Salud,
                          BD_RRVV_TIT$`% Beneficio`,
                          BD_RRVV_TIT$`Fecha de fallecimiento pensionista`,
                          BD_RRVV_TIT$`Categor?a Prestaci?n`,#Determina grado de invalidez
                          BD_RRVV_TIT$`Fecha de Devengue de la Solicitud`,
                          stringsAsFactors = FALSE
)
str(dfValidador)
#POR_PG=BD_RRVV%>% group_by(P?liza) %>% summarise(x = sum(`% Beneficio`)-1)
names(dfValidador) <- c("ID","POLIZA", "PERIODO",
                        "FECHAINIVIG",
                        "FECHAFINVIG,",
                        "FEC_SEL_TABLA",
                        "PDIFERIDO",
                        "PGARANTIZADO",
                        "PORC_PG",
                        "COBERTURA",
                        "PENSION_BASE",
                        "FRECUENCIA",
                        "MONEDA",
                        "AJUSTE",
                        "DERECHO_ACRECER",
                        "TASA_COSTO_EQUIV_RV",
                        "TASA_COSTO_EQUIV_GS",
                        "TASA_COSTO_VENTA",
                        "TASA_MERCADO",
                        "FECHA_EMISION",
                        "CADUCADA",
                        "PAGO_PG",
                        "PAGO_GASTO_FUNERARIO",
                        "PERIODO_TEMPORAL",
                        "PORC_SEGUNDO_TRAMO",
                        "FECNAC_TIT",
                        "SEXO_TIT",
                        "SALUD_TIT",
                        "PORC_TIT",
                        "FECFALLECIMIENTO_TIT",
                        #"MTO_PENSIONGAR",
                        "TIPO_PRESTACION",
                        "FECHA_DEVENGUE_SOLICITUD"
)

#solo para generar los campos

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

#llena los campos

#i<-1  
for(i in 1:filas) {
  #Fecha de Seleccion de Tabla para produccion 2019
  if(!is.na(dfValidador[i,"FECHA_EMISION"]) &&  dfValidador[i,"FECHA_EMISION"]>=fecProdTablasNueva)
    {dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]}
  if(dfValidador[i,"COBERTURA"]=="INV")
    {dfValidador[i,"SALUD_TIT"]<-dfValidador[i,"TIPO_PRESTACION"]}
  
  contHijos <- 0
  
  dfBeneficiarios <- BD_RRVV[BD_RRVV$`P?liza/Siniestros`==dfValidador[i,"ID"] & BD_RRVV$`Relaci?n familiar` != "T" &
                            BD_RRVV$`% Beneficio` >0 & is.na(BD_RRVV$`Fecha de fallecimiento pensionista`),]          
                                     
  benefVigentes<-nrow(dfBeneficiarios)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  
  if(benefVigentes==0){
    next
  } #j<-1 
  for(j in 1:benefVigentes) {
    #2 o 3: Conyuge o Concubina
    if(dfBeneficiarios[j,"Relaci?n familiar"]=="C"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fecha de nacimiento pensionista"]
      dfValidador[i,"SALUD_CONY"] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,"% Beneficio"]
    #4: Padre o Madre    
    }else if(dfBeneficiarios[j,"Relaci?n familiar"]=="P"){
      if(dfBeneficiarios[j,"Sexo"]=="M"){
        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"Fecha de nacimiento pensionista"]
        dfValidador[i,"SALUD_PAD"] <- dfBeneficiarios[j,"Salud"]
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,"% Beneficio"]        
      }else{
        dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"Fecha de nacimiento pensionista"]
        dfValidador[i,"SALUD_MAD"] <- dfBeneficiarios[j,"Salud"]
        dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,"% Beneficio"]        
      }
    #5: Hijos      
    }else if(dfBeneficiarios[j,"Relaci?n familiar"]=="H"){
      contHijos <- contHijos + 1  
      dfValidador[i,paste("SEXO_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,paste("FECNAC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Fecha de nacimiento pensionista"]
      dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,paste("PORC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"% Beneficio"]        
      #Permite verificar si se calcula hasta 28 o 18 a?os la pension
      fecCumple18 <- dfBeneficiarios[j,"Fecha de nacimiento pensionista"][[1]]
      AddMonths(fecCumple18,18*12)
      fecCumple18 <- AddMonths(fecCumple18,18*12)
      if(dfBeneficiarios[j,"Salud"]=="I"){
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 111  
      #}else if(dfValidador[i,"FECHA_EMISION"]<fecHijos28){
      }else if(dfValidador[i,"FECHA_DEVENGUE_SOLICITUD"]<fecHijos28){
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 18
      }else if(fecCumple18>fecCierre){  
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 28        
      }else if(dfBeneficiarios[j,"Acreditaci?n de Estudios (Hijos)"]=="N"){
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 18
      }else{
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 28
      }
      
    }
  }
  dfValidador[i,"TOTAL_HIJ"]<-contHijos

}


dfValidador$TIPO_PRESTACION <- NULL
dfValidador$FECHA_DEVENGUE_SOLICITUD <- NULL

#dfValidador$PENSION_BASE=if_else(dfValidador$=="SOB",POR_PG$x,1)


#View(dfValidador)
library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BaseRRVV_Positiva_",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
