library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener a?o
rm(list=ls())#Limpia objetos
fecStart <-Sys.time()
setwd(dirname(getActiveDocumentContext()$path))
#Cambiar en cada Ejecucion
fecCierre <- as.Date("30/11/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/Rimac/SBS/112019/Previsionales/CIA"
nombreBD <- "PREVISIONALES_112019.xlsx"

Tramas_TIT <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                              sheet = "Poliza", col_types = c("date", 
                                                              "numeric", "text", "numeric", "date", 
                                                              "date", "text", "text", "text", "text", 
                                                              "numeric", "numeric", "numeric", 
                                                              "numeric", "numeric", "numeric", 
                                                              "numeric", "text", "text", "text", 
                                                              "text", "text", "text", "date", "date", 
                                                              "text", "numeric", "text", "text", 
                                                              "text", "date", "text", "date", "date", 
                                                              "text", "date", "date", "text", "date", 
                                                              "numeric", "date", "date", "date", 
                                                              "numeric", "numeric", "date"))

Tramas_TIT <- Tramas_TIT[Tramas_TIT$EXPREV_REGIMEN=="T" & Tramas_TIT$EXPREV_TIPO_RVA !="SL",]          


Tramas_BEN <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                         sheet = "Beneficiario", col_types = c("numeric", 
                                                               "text", "text", "text", "text", "text", 
                                                               "text", "text", "date", "date", "text", 
                                                               "numeric", "numeric", "text"))

dfValidador <- data.frame(Tramas_TIT$EXPREV_NUMERO_SINIESTRO,
                          Tramas_TIT$EXPREV_NUMERO_POLIZA,
                          Tramas_TIT$EXPREV_PERIODO,
                          Tramas_TIT$EXPREV_FECHA_SINIESTRO,
                          Tramas_TIT$EXPREV_FECHA_SINIESTRO,
                          rep(x = 0,nrow(Tramas_TIT)),#Periodo Diferido
                          rep(x = 0,nrow(Tramas_TIT)),#Periodo Garantizado
                          rep(x = 0,nrow(Tramas_TIT)),#Porc. PG
                          Tramas_TIT$EXPREV_TIPO_COBERTURA,
                          Tramas_TIT$EXPREV_REMUNERACION,
                          rep(x = 12,nrow(Tramas_TIT)),#Cantidad de Pagos (Gratificacion o no)
                          ifelse(Tramas_TIT$EXPREV_MONEDA=="001","PEN","USD"),
                          Tramas_TIT$EXPREV_PORCE_AJUSTE/100,
                          rep(x = 0,nrow(Tramas_TIT)),#Derecho Acrecer en RRVV
                          rep(x = 0.03,nrow(Tramas_TIT)),#Tramas_TIT$EXPREV_TASA_COSTO_EQUIVALENTE/100,
                          rep(x = 0.03,nrow(Tramas_TIT)),#Tramas_TIT$EXPREV_TASA_COSTO_EQUIVALENTE/100,
                          rep(x = 0,nrow(Tramas_TIT)),#Tasa de Venta para RRVV
                          rep(x = 0,nrow(Tramas_TIT)),#Campo Tasa Mercado
                          Tramas_TIT$EXPREV_FECHA_SINIESTRO,#Fecha Emision en RRVV
                          rep(x = 0,nrow(Tramas_TIT)),#Caducada de RRVV Rimac
                          Tramas_TIT$EXPREV_PAGO_GASTO_FUNERARIO,
                          rep(x = 0,nrow(Tramas_TIT)),#Periodo de Renta Escalonada de RRVV
                          rep(x = 0,nrow(Tramas_TIT)),#Porcentaje de Renta Escalonada de RRVV
                          Tramas_TIT$EXPREV_FECHA_NACIMIENTO,
                          Tramas_TIT$EXPREV_SEXO,
                          ifelse(Tramas_TIT$EXPREV_ESTADO_PSICOFISICO=="A","S",Tramas_TIT$EXPREV_ESTADO_PSICOFISICO),
                          Tramas_TIT$EXPREV_PORCE_BENEFICIO/100,
                          Tramas_TIT$EXPREV_FECHA_FALLECIMIENTO,
                          stringsAsFactors = FALSE
)
str(dfValidador)
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
                        "FECFALLECIMIENTO_TIT"
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
fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
  
for(i in 1:filas) {
  # #Fecha de Seleccion de Tabla para produccion 2019
  # if(!is.na(dfValidador[i,"FECHA_EMISION"]) &&  dfValidador[i,"FECHA_EMISION"]>=fecProdTablasNueva){
  #   dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]
  # }
    
  #Campo de Salud del Titular
  if(dfValidador[i,"COBERTURA"] == "PARC"){
    dfValidador[i,"SALUD_TIT"] <- "IP"
  }else if(dfValidador[i,"COBERTURA"] == "TOTAL"){
    dfValidador[i,"SALUD_TIT"] <- "IT"
  }else if(dfValidador[i,"COBERTURA"] == "SOB"){
    dfValidador[i,"FECHAINIVIG"] <- dfValidador[i,"FECFALLECIMIENTO_TIT"]#La remuneracion base se actualiza hasta la fecha de fallecimiento
  }  
  contHijos <- 0
  dfBeneficiarios <- Tramas_BEN[Tramas_BEN$EXPREVPB_NUMERO_SINIESTRO==dfValidador[i,"ID"] &
                                     Tramas_BEN$EXPREVPB_PORCENTAJE_BENEFICIO >0 &
                                     Tramas_BEN$EXPREVPB_FECHA_FALLECIMIENTO < fecFallecimiento,]          
                                     #as.numeric(format(Tramas_BEN$EXPREVPB_FECHA_FALLECIMIENTO,"%Y")) <= 1900,]

  benefVigentes<-nrow(dfBeneficiarios)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  if(benefVigentes==0) next 
  for(j in 1:benefVigentes) {
    #2 o 3: Conyuge o Concubina
    if(dfBeneficiarios[j,"EXPREVPB_PARENTESCO"]=="2" || dfBeneficiarios[j,"EXPREVPB_PARENTESCO"]=="3"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"EXPREVPB_SEXO"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"EXPREVPB_FECHA_NACIMIENTO"]
      dfValidador[i,"SALUD_CONY"] <- ifelse(dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"])
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,"EXPREVPB_PORCENTAJE_BENEFICIO"]/100
    #4: Padre o Madre    
    }else if(dfBeneficiarios[j,"EXPREVPB_PARENTESCO"]=="4"){
      if(dfBeneficiarios[j,"EXPREVPB_SEXO"]=="M"){
        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"EXPREVPB_FECHA_NACIMIENTO"]
        dfValidador[i,"SALUD_PAD"] <- ifelse(dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"])
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,"EXPREVPB_PORCENTAJE_BENEFICIO"]/100        
      }else{
        dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"EXPREVPB_FECHA_NACIMIENTO"]
        dfValidador[i,"SALUD_MAD"] <- ifelse(dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"])
        dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,"EXPREVPB_PORCENTAJE_BENEFICIO"]/100        
      }
    #5: Hijos      
    }else if(dfBeneficiarios[j,"EXPREVPB_PARENTESCO"]=="5"){
      contHijos <- contHijos + 1  
      dfValidador[i,paste("SEXO_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXPREVPB_SEXO"]
      dfValidador[i,paste("FECNAC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXPREVPB_FECHA_NACIMIENTO"]
      dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- ifelse(dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXPREVPB_ESTADO_PSICOFISICO"])
      dfValidador[i,paste("PORC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXPREVPB_PORCENTAJE_BENEFICIO"]/100        
      dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXPREVPB_EDAD_MAX_HIJO"]
    }
  }
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
}
#Eliminando campos innecesarios
dfValidador$TIPO_SINIESTRO<-NULL
dfValidador$PRESTACION<-NULL
#View(dfValidador)
library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BaseRRVV_RIMAC_RT_SPL_",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
