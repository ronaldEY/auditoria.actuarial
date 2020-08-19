#Cambiar fecha de cierre
library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener año
library(DescTools)#Sumar meses a fecha
library(dplyr)
rm(list=ls())#Limpia objetos
fecStart <-Sys.time()
setwd(dirname(getActiveDocumentContext()$path))
#Cambiar en cada Ejecucion
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y")
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 

#Colocar en 0 la tasa de ajuste VAC
#Colocar en Texto en Columnas Pension 
BD_RRVV <- read_excel("CIA/RRVV LPV - Copy.xlsx", 
                      sheet = "RRVV", col_types = c("text","text", "text", "text", "text", 
                                                       "text","text", "numeric", "text", "numeric", 
                                                       "text", "numeric", "text", "date", "date", 
                                                       "numeric", "date", "text", "text", "text",
                                                       "text", "date", "date", "text", "text", 
                                                       "numeric", "numeric", "text", "text", "numeric", 
                                                       "numeric", "numeric", "numeric", "numeric", "numeric", 
                                                       "numeric", "numeric", "numeric", "numeric", "date", 
                                                       "text", "text", "numeric", "numeric", "numeric", 
                                                       "numeric", "numeric", "numeric", "numeric", "numeric", 
                                                       "numeric", "numeric", "numeric", "numeric", "numeric"))
#View(BD_RRVV)
#BD_RRVV$`Reserva Base Soles`
BD_RRVV_TIT <- BD_RRVV[BD_RRVV$`Relación familiar` == "T",]

dfValidador <- data.frame(BD_RRVV_TIT$Póliza,
                          BD_RRVV_TIT$Póliza,
                          as.Date(rep(x = fecCierre,nrow(BD_RRVV_TIT)), format = "%d/%m/%Y"),
                          BD_RRVV_TIT$`Fecha de devengue`,#Inicio de Vigencia
                          BD_RRVV_TIT$`Fecha de entrada en vigencia de la póliza`,#Fec. Seleccion de Tablas
                          BD_RRVV_TIT$`Período diferido`*12,
                          BD_RRVV_TIT$`Período garantizado`*12,
                          #rep(x = 1,nrow(BD_RRVV_TIT)),#Porc. PG
                          BD_RRVV_TIT$`% Beneficio`,#Porc. PG
                          substr(BD_RRVV_TIT$Prestación,1,3),
                          ifelse(BD_RRVV_TIT$`%RVE`>0,with(BD_RRVV_TIT,`Pensión 1° Tramo RVE`*`Ajuste de la pensión`),with(BD_RRVV_TIT, `Remuneración Base`*`Ajuste de la pensión`)),
                          ifelse(BD_RRVV_TIT$`Gratificación?` == "S",14,12),#Cantidad de Pagos (Gratificacion o no)
                          ifelse(substr(BD_RRVV_TIT$`Descripción Moneda`,1,3) == "S/.","PEN","USD"),
                          BD_RRVV_TIT$`Tasa de Ajuste`,
                          ifelse(BD_RRVV_TIT$`Indicador de Derecho a Crecer`=="N",0,1),
                          BD_RRVV_TIT$`Tasa de Costo Equivalente`,
                          BD_RRVV_TIT$`Tasa de Costo Equivalente`,
                          BD_RRVV_TIT$`Tasa de Venta`,
                          BD_RRVV_TIT$`Tasa de Mercado`,#Campo Tasa Mercado
                          BD_RRVV_TIT$`Fecha de entrada en vigencia de la póliza`, # Fecha de Emision
                          ifelse(BD_RRVV_TIT$`Pago de Periodo Garantizado?`=="S",1,0),#Campo CADUCADA para BD Rimac
                          ifelse(fecFallecimiento<BD_RRVV_TIT$`Fecha de fallecimiento pensionista`,"S","N"), #Campo PAGO_GASTO_FUNERARIO para BD Rimac
                          BD_RRVV_TIT$PRIMER_TRAMO*12,#Duracion tramo sin renta escalonada, es 0 cuando no es renta escalonada
                          BD_RRVV_TIT$`%RVE`, #Porcentaje Segundo Tramo
                          BD_RRVV_TIT$`Fecha de nacimiento pensionista`,
                          BD_RRVV_TIT$Sexo,
                          BD_RRVV_TIT$Salud,
                          BD_RRVV_TIT$`% Beneficio`,
                          BD_RRVV_TIT$`Fecha de fallecimiento pensionista`,
                          #ifelse(BD_RRVV_TIT$`%RVE`>0,BD_RRVV_TIT$`Pensión 1° Tramo RVE`,BD_RRVV_TIT$`Remuneración Base`),#Pension PG
                          BD_RRVV_TIT$`Categoría Prestación`,#Determina grado de invalidez
                          BD_RRVV_TIT$`Fecha de Devengue de la Solicitud`,
                          stringsAsFactors = FALSE
)
str(dfValidador)
#POR_PG=BD_RRVV%>% group_by(Póliza) %>% summarise(x = sum(`% Beneficio`)-1)
names(dfValidador) <- c("ID","POLIZA", "PERIODO",
                        "FECHAINIVIG",
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
  if(!is.na(dfValidador[i,"FECHA_EMISION"]) &&  dfValidador[i,"FECHA_EMISION"]>=fecProdTablasNueva){
    dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]
  }
  if(dfValidador[i,"COBERTURA"]=="INV"){
    dfValidador[i,"SALUD_TIT"]<-ifelse(dfValidador[i,"TIPO_PRESTACION"] == "INVALIDEZ TOTAL","IT","IP")
  }
  contHijos <- 0
  
  dfBeneficiarios <- BD_RRVV[BD_RRVV$Póliza==dfValidador[i,"ID"] & BD_RRVV$`Relación familiar` != "T" &
                               BD_RRVV$`% Beneficio` >0 &
                               is.na(BD_RRVV$`Fecha de fallecimiento pensionista`),]          
                                     #as.numeric(format(Tramas_RRVV_BEN$EXRVPB_FECHA_FALLECIMIENTO,"%Y")) <= 1900,]
                             
  benefVigentes<-nrow(dfBeneficiarios)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  # if(dfValidador[i,"FECFALLECIMIENTO_TIT"]>fecFallecimiento){
  #   dfValidador[i,"PORC_PG"]<-dfValidador[i,"MTO_PENSIONGAR"]/dfValidador[i,"PENSION_BASE"]
  # }  
  #Para Polizas en Soles VAC no hay amortizacion desde 09.2019
  # if(dfValidador[i,"MONEDA"]=="PEN" && dfValidador[i,"AJUSTE"]==0 &&
  #    dfValidador[i,"FEC_SEL_TABLA"]<fecProdTablasNueva){
  #   dfValidador[i,"FEC_SEL_TABLA"]<-fecProdTablasNueva
  #   dfValidador[i,"TASA_COSTO_EQUIV_RV"]<-dfValidador[i,"TASA_MERCADO"]
  #   dfValidador[i,"TASA_COSTO_EQUIV_GS"]<-dfValidador[i,"TASA_MERCADO"]    
  # }  
  
  if(benefVigentes==0){
    #En Sobrevivencias cuando no hay beneficiarios vigentes, usar la pension del PG
    # if(dfValidador[i,"COBERTURA"]=="SOB" && dfValidador[i,"PENSION_BASE"]==0){
    #   dfValidador[i,"PENSION_BASE"]<-dfValidador[i,"MTO_PENSIONGAR"]
    #   dfValidador[i,"PORC_PG"]<-1
    # }
    next
  } #j<-2 
  for(j in 1:benefVigentes) {
    #2 o 3: Conyuge o Concubina
    if(dfBeneficiarios[j,"Relación familiar"]=="C"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fecha de nacimiento pensionista"]
      dfValidador[i,"SALUD_CONY"] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,"% Beneficio"]
    #4: Padre o Madre    
    }else if(dfBeneficiarios[j,"Relación familiar"]=="P"){
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
    }else if(dfBeneficiarios[j,"Relación familiar"]=="H"){
      contHijos <- contHijos + 1  
      dfValidador[i,paste("SEXO_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,paste("FECNAC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Fecha de nacimiento pensionista"]
      dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Salud"]
      dfValidador[i,paste("PORC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"% Beneficio"]        
      #Permite verificar si se calcula hasta 28 o 18 años la pension
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
      }else if(dfBeneficiarios[j,"Acreditación de Estudios (Hijos)"]=="N"){
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

#dfValidador$PORC_PG=if_else(dfValidador$COBERTURA=="SOB",POR_PG$x,1)


#View(dfValidador)
library(openxlsx)
write.xlsx(dfValidador, file=paste("BaseRRVV_Positiva_",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
