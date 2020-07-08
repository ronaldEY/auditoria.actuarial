library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener a?o
rm(list=ls())#Limpia objetos
fecStart <-Sys.time()
setwd(dirname(getActiveDocumentContext()$path))
#Cambiar en cada Ejecucion
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")  
directorioBD <- "C:/Ronald/Auditorias/Rimac/SBS/122019/RRVV/CIA"
nombreBD <- "Trama_RRVV_122019.xlsx"

Tramas_RRVV_TIT <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                                 sheet = "Poliza", col_types = c("date","text", "text", "text", "date",  
                                                                 "date","numeric", "text", "text",  
                                                                 "text","text", "text", "numeric",  
                                                                 "numeric","numeric", "numeric","numeric", 
                                                                 "numeric", "numeric", "numeric", "numeric",
                                                                  "text", "text", "text", "text",
                                                                  "text", "text", "date", "date", 
                                                                 "text", "text", "date", "numeric", 
                                                                 "numeric", "date", "date", "text", 
                                                                 "text", "numeric", "numeric"))
#View(Tramas_RRVV_TIT)
Tramas_RRVV_BEN <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                                 sheet = "Beneficiario", col_types = c("text", "text", "text", "text",
                                                                      "text", "text",  "text", "text",
                                                                      "date", "date", "text", "numeric",
                                                                      "numeric", "numeric", "text"))

dfValidador <- data.frame(Tramas_RRVV_TIT$EXRVP_NUMERO_SINIESTRO,
                          Tramas_RRVV_TIT$EXRVP_NUMERO_POLIZA,
                          Tramas_RRVV_TIT$EXRVP_PERIODO,
                          Tramas_RRVV_TIT$EXRVP_INICIO_VIGENCIA,
                          Tramas_RRVV_TIT$EXRVP_FECHA_COTIZACION,
                          Tramas_RRVV_TIT$EXRVP_PLAZO_TEMPORAL,
                          Tramas_RRVV_TIT$EXRVP_PLAZO_GARANTIZADO,
                          rep(x = 1,nrow(Tramas_RRVV_TIT)),#Porc. PG
                          Tramas_RRVV_TIT$EXRVP_ORIGEN,
                          Tramas_RRVV_TIT$EXRVP_TIPO_SINIESTRO,
                          Tramas_RRVV_TIT$EXRVP_PENSION_BASE,
                          numeric(nrow(Tramas_RRVV_TIT)),#Cantidad de Pagos (Gratificacion o no)
                          ifelse(Tramas_RRVV_TIT$EXRVP_MONEDA=="001","PEN","USD"),
                          Tramas_RRVV_TIT$EXRVP_PORCE_AJUSTE/100,
                          Tramas_RRVV_TIT$EXRVP_ACRECER,
                          Tramas_RRVV_TIT$EXRVP_TASA_COSTO_EQUIVALENTE/100,
                          Tramas_RRVV_TIT$EXRVP_TASA_COSTO_EQUIVALENTE/100,
                          Tramas_RRVV_TIT$EXRVP_TASA_VENTA/100,
                          numeric(nrow(Tramas_RRVV_TIT)),#Campo Tasa Mercado
                          Tramas_RRVV_TIT$EXRVP_FECHA_EMISION,
                          Tramas_RRVV_TIT$EXRVP_CADUCADA,
                          Tramas_RRVV_TIT$EXRVP_PAGO_GASTO_FUNERARIO,
                          Tramas_RRVV_TIT$EXRVP_ANIOS_PRIMER_TRAMO_RVE*12,
                          Tramas_RRVV_TIT$EXRVP_PORCENTAJE_SEGUNDO_TRAMO_RVE/100,
                          Tramas_RRVV_TIT$EXRVP_FECHA_NACIMIENTO,
                          Tramas_RRVV_TIT$EXRVP_SEXO,
                          ifelse(Tramas_RRVV_TIT$EXRVP_ESTADO_PSICOFISICO=="A","S",Tramas_RRVV_TIT$EXRVP_ESTADO_PSICOFISICO),
                          rep(x = 1,nrow(Tramas_RRVV_TIT)),
                          Tramas_RRVV_TIT$EXRVP_FECHA_FALLECIMIENTO,
                          Tramas_RRVV_TIT$EXRVP_PRESTACION,
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
                        "TIPO_SINIESTRO",
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
                        "PRESTACION"
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
  if(!is.na(dfValidador[i,"FECHA_EMISION"]) &&  dfValidador[i,"FECHA_EMISION"]>=fecProdTablasNueva){
    dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]
  }
    
  if(dfValidador[i,"TIPO_SINIESTRO"] == "032" || dfValidador[i,"TIPO_SINIESTRO"] == "033" ||
     dfValidador[i,"TIPO_SINIESTRO"] == "034" || dfValidador[i,"TIPO_SINIESTRO"] == "035" ||
     dfValidador[i,"TIPO_SINIESTRO"] == "036" || dfValidador[i,"TIPO_SINIESTRO"] == "037" ||
     dfValidador[i,"TIPO_SINIESTRO"] == "047" || dfValidador[i,"TIPO_SINIESTRO"] == "049" ||
     dfValidador[i,"TIPO_SINIESTRO"] == "051" || dfValidador[i,"TIPO_SINIESTRO"] == "053" 
     ){
    dfValidador[i,"FRECUENCIA"] <- 14
  }else{
    dfValidador[i,"FRECUENCIA"] <- 12
  }
  #Campo de Salud del Titular
  if(dfValidador[i,"PRESTACION"] == "04" || dfValidador[i,"PRESTACION"] == "08"){
    dfValidador[i,"SALUD_TIT"] <- "IP"
  }else if(dfValidador[i,"PRESTACION"] == "06" || dfValidador[i,"PRESTACION"] == "09"){
    dfValidador[i,"SALUD_TIT"] <- "IT"
  }  
  contHijos <- 0
  dfBeneficiarios <- Tramas_RRVV_BEN[Tramas_RRVV_BEN$EXRVPB_NUMERO_SINIESTRO==dfValidador[i,"ID"] & Tramas_RRVV_BEN$EXRVPB_BAJA ==0 &
                                     Tramas_RRVV_BEN$EXRVPB_PORCENTAJE_BENEFICIO >0 &
                                     Tramas_RRVV_BEN$EXRVPB_FECHA_FALLECIMIENTO < fecFallecimiento,]          
                                     #as.numeric(format(Tramas_RRVV_BEN$EXRVPB_FECHA_FALLECIMIENTO,"%Y")) <= 1900,]

    
  benefVigentes<-nrow(dfBeneficiarios)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  if(benefVigentes==0) next 
  for(j in 1:benefVigentes) {
    #2 o 3: Conyuge o Concubina
    if(dfBeneficiarios[j,"EXRVPB_PARENTESCO"]=="2" || dfBeneficiarios[j,"EXRVPB_PARENTESCO"]=="3"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"EXRVPB_SEXO"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"EXRVPB_FECHA_NACIMIENTO"]
      dfValidador[i,"SALUD_CONY"] <- ifelse(dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"])
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,"EXRVPB_PORCENTAJE_BENEFICIO"]/100
    #4: Padre o Madre    
    }else if(dfBeneficiarios[j,"EXRVPB_PARENTESCO"]=="4"){
      if(dfBeneficiarios[j,"EXRVPB_SEXO"]=="M"){
        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"EXRVPB_FECHA_NACIMIENTO"]
        dfValidador[i,"SALUD_PAD"] <- ifelse(dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"])
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,"EXRVPB_PORCENTAJE_BENEFICIO"]/100        
      }else{
        dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"EXRVPB_FECHA_NACIMIENTO"]
        dfValidador[i,"SALUD_MAD"] <- ifelse(dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"])
        dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,"EXRVPB_PORCENTAJE_BENEFICIO"]/100        
      }
    #5: Hijos      
    }else if(dfBeneficiarios[j,"EXRVPB_PARENTESCO"]=="5"){
      contHijos <- contHijos + 1  
      dfValidador[i,paste("SEXO_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXRVPB_SEXO"]
      dfValidador[i,paste("FECNAC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXRVPB_FECHA_NACIMIENTO"]
      dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- ifelse(dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXRVPB_ESTADO_PSICOFISICO"])
      dfValidador[i,paste("PORC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXRVPB_PORCENTAJE_BENEFICIO"]/100        
      dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXRVPB_EDAD_MAX_HIJO"]
    }
  }
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
}
#Eliminando campos innecesarios
dfValidador$TIPO_SINIESTRO<-NULL
dfValidador$PRESTACION<-NULL
#View(dfValidador)
library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BaseRRVV_RIMAC_",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
