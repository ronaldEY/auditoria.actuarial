library(rstudioapi)#Para obtener ruta en el directorio
library(readxl)#Leer Excel
library(lubridate)#Obtener a?o
library(DescTools)#Sumar meses a fecha
rm(list=ls())#Limpia objetos
fecStart <-Sys.time()
setwd(dirname(getActiveDocumentContext()$path))

#Parametros CP
grupoFamiliarCP <- read_excel("C:/Ronald/Auditorias/Rimac/SBS/122019/SCTR/grupoFamiliarCP.xlsx")
#View(grupoFamiliarCP)

#Cambiar en cada Ejecucion
fecCierre <- as.Date("31/12/2019", format = "%d/%m/%Y")    
directorioBD <- "C:/Ronald/Auditorias/Rimac/SBS/122019/SCTR/CIA"
nombreBD <- "TramasAutomaticas_SCTR_122019.xlsx"

Tramas_TIT <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                              sheet = "Poliza", col_types = c("date", "numeric", "text", 
                                                              "numeric", "text", "text", "date", 
                                                              "date", "text", "text", "text", "numeric", 
                                                              "numeric", "numeric", "text", "text", 
                                                              "text", "text", "text", "text", "date", 
                                                              "date", "text", "text", "text", "text", 
                                                              "text", "date", "date", "text", "numeric", 
                                                              "text", "date", "text", "date", "date", 
                                                              "text", "numeric", "date", "date", 
                                                              "date", "text", "date", "date", "text", 
                                                              "numeric", "date", "date", "date","date"))
#Consideramos s?lo Agravamientos
Tramas_TIT <- Tramas_TIT[Tramas_TIT$EXSCTR_TIPO_RVA !="SL" &
                        Tramas_TIT$EXSCTR_NUMERO_SINIESTRO>1399000000,]          

#No considerar agravamientos
# Tramas_TIT <- Tramas_TIT[Tramas_TIT$EXSCTR_TIPO_RVA !="SL" &
#                         Tramas_TIT$EXSCTR_NUMERO_SINIESTRO<1399000000,]          

Tramas_BEN <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                              sheet = "Beneficiario", col_types = c("numeric", 
                                                                    "text", "text", "text", "text", "text", 
                                                                    "text", "text", "date", "date", "text", 
                                                                    "numeric"))

dfValidador <- data.frame(Tramas_TIT$EXSCTR_NUMERO_SINIESTRO - 99000000,
                          Tramas_TIT$EXSCTR_NUMERO_SINIESTRO,
                          Tramas_TIT$EXSCTR_NUMERO_POLIZA,
                          Tramas_TIT$EXSCTR_PERIODO,
                          Tramas_TIT$EXSCTR_FECHA_INICIO_COBERTURA,#Fecha de Ini Vigencia
                          Tramas_TIT$EXSCTR_FECHA_FIN_COBERTURA,#Fecha de Fin Vigencia
                          Tramas_TIT$EXSCTR_FECHA_INICIO_COBERTURA,#Fecha Seleccion de Tabla
                          0,#Periodo Diferido
                          0,#Periodo Garantizado
                          0,#Porc. PG
                          Tramas_TIT$EXSCTR_TIPO_RVA,#Tipo de Reserva
                          Tramas_TIT$EXSCTR_TIPO_COBERTURA,
                          NA,#COBERTURA ANTERIOR
                          Tramas_TIT$EXSCTR_REMUNERACION,
                          12,#Cantidad de Pagos (Gratificacion o no)
                          ifelse(Tramas_TIT$EXSCTR_MONEDA=="001","PEN","USD"),
                          Tramas_TIT$EXSCTR_PORCE_AJUSTE/100,
                          0,#Derecho Acrecer en RRVV
                          0.03,#Tramas_TIT$EXSCTR_TASA_COSTO_EQUIVALENTE/100,
                          0.03,#Tramas_TIT$EXSCTR_TASA_COSTO_EQUIVALENTE/100,
                          0,#Tasa de Venta para RRVV
                          0,#Campo Tasa Mercado
                          Tramas_TIT$FEC_EMISION_ACTUAL,#Fecha Emision en RRVV
                          Tramas_TIT$EXSCTR_FECHA_SINIESTRO,
                          0,#Caducada de RRVV Rimac
                          ifelse(is.na(Tramas_TIT$EXSCTR_PAGO_GASTO_FUNERARIO),"N",Tramas_TIT$EXSCTR_PAGO_GASTO_FUNERARIO),
                          0,#Periodo de Renta Escalonada de RRVV
                          0,#Porcentaje de Renta Escalonada de RRVV
                          Tramas_TIT$EXSCTR_FECHA_NACIMIENTO,
                          Tramas_TIT$EXSCTR_SEXO,
                          ifelse(Tramas_TIT$EXSCTR_ESTADO_PSICOFISICO=="A","S",Tramas_TIT$EXSCTR_ESTADO_PSICOFISICO),
                          Tramas_TIT$EXSCTR_PORCE_BENEFICIO/100,
                          Tramas_TIT$EXSCTR_FECHA_FALLECIMIENTO,
                          Tramas_TIT$EXSCTR_AGRAV1_TIPO_COBERTURA,
                          Tramas_TIT$EXSCTR_AGRAV2_TIPO_COBERTURA,
                          stringsAsFactors = FALSE
)
#str(dfValidador)
names(dfValidador) <- c("SINIESTRO","ID","POLIZA", "PERIODO",
                        "FECHAINIVIG",
                        "FECHAFINVIG",
                        "FEC_SEL_TABLA",
                        "PDIFERIDO",
                        "PGARANTIZADO",
                        "PORC_PG",
                        "TIPO_RVA",
                        "COBERTURA",
                        "COBERTURA_ANT",
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
                        "FECHA_SINIESTRO",
                        "CADUCADA",
                        "PAGO_GASTO_FUNERARIO",
                        "PERIODO_TEMPORAL",
                        "PORC_SEGUNDO_TRAMO",
                        "FECNAC_TIT",
                        "SEXO_TIT",
                        "SALUD_TIT",
                        "PORC_TIT",
                        "FECFALLECIMIENTO_TIT",
                        "COBERTURA_AGRAV1",
                        "COBERTURA_AGRAV2"
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
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 
#i<-9
for(i in 1:filas) {
    
  #Campo de Salud del Titular
  if(dfValidador[i,"COBERTURA"] == "PP"){
    dfValidador[i,"SALUD_TIT"] <- "IP"
  }else if(dfValidador[i,"COBERTURA"] == "TP"){
    dfValidador[i,"SALUD_TIT"] <- "IT"
  }else if(dfValidador[i,"COBERTURA"] == "SOB"){
    dfValidador[i,"FECHAINIVIG"] <- max(dfValidador[i,"FECFALLECIMIENTO_TIT"],dfValidador[i,"FECHAINIVIG"]) #La remuneracion base se actualiza hasta la fecha de fallecimiento
  }
  
  if(dfValidador[i,"FEC_SEL_TABLA"]>= fecProdTablasNueva &&
     dfValidador[i,"FECHA_EMISION"]<fecProdTablasNueva){
    dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]
  }else if(dfValidador[i,"FECHA_EMISION"]>=fecProdTablasNueva &&
           dfValidador[i,"FEC_SEL_TABLA"]<fecProdTablasNueva){
    dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]
  }
  # dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHAINIVIG"]
  # #Fecha de Seleccion de Tabla para produccion 2019
  # if(!is.na(dfValidador[i,"FECHA_EMISION"]) &&  dfValidador[i,"FECHA_EMISION"]>=fecProdTablasNueva){
  #   dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]
  # }  
  contHijos <- 0
  dfBeneficiarios <- Tramas_BEN[Tramas_BEN$EXSCTRB_NUMERO_SINIESTRO==dfValidador[i,"ID"] &
                                Tramas_BEN$EXSCTRB_PORCENTAJE_BENEFICIO >0
                                & is.na(Tramas_BEN$EXSCTRB_FECHA_FALLECIMIENTO) 
                                ,]          
                                     #as.numeric(format(Tramas_BEN$EXSCTRB_FECHA_FALLECIMIENTO,"%Y")) <= 1900,]
  
  benefVigentes<-nrow(dfBeneficiarios)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  #Cambios Agravamientos
  if(dfValidador[i,"ID"]>1399000000){
    dfValidador[i,"TIPO_RVA"]<-"SPL"
    
    # #Primer Agravamiento
    # if(dfValidador[i,"COBERTURA_AGRAV1"] == "PP"){
    #   dfValidador[i,"SALUD_TIT"] <- "IP"
    #   dfValidador[i,"PORC_TIT"] <- 0.5
    #   dfValidador[i,"COBERTURA"] <- dfValidador[i,"COBERTURA_AGRAV1"]
    # }else if(dfValidador[i,"COBERTURA_AGRAV1"] == "TP"){
    #   dfValidador[i,"SALUD_TIT"] <- "IT"
    #   dfValidador[i,"PORC_TIT"] <- 0.7
    #   dfValidador[i,"COBERTURA"] <- dfValidador[i,"COBERTURA_AGRAV1"]
    # }else if(dfValidador[i,"COBERTURA_AGRAV1"] == "GI"){
    #   dfValidador[i,"SALUD_TIT"] <- "IT"
    #   dfValidador[i,"PORC_TIT"] <- 1
    #   dfValidador[i,"COBERTURA"] <- dfValidador[i,"COBERTURA_AGRAV1"]
    # }
    # #Segundo Agravamiento
    # if(dfValidador[i,"COBERTURA_AGRAV2"] == "PP"){
    #   dfValidador[i,"SALUD_TIT"] <- "IP"
    #   dfValidador[i,"PORC_TIT"] <- 0.5
    #   dfValidador[i,"COBERTURA"] <- dfValidador[i,"COBERTURA_AGRAV2"]
    # }else if(dfValidador[i,"COBERTURA_AGRAV2"] == "TP"){
    #   dfValidador[i,"SALUD_TIT"] <- "IT"
    #   dfValidador[i,"PORC_TIT"] <- 0.7
    #   dfValidador[i,"COBERTURA"] <- dfValidador[i,"COBERTURA_AGRAV2"]
    # }else if(dfValidador[i,"COBERTURA_AGRAV2"] == "GI"){
    #   dfValidador[i,"SALUD_TIT"] <- "IT"
    #   dfValidador[i,"PORC_TIT"] <- 1
    #   dfValidador[i,"COBERTURA"] <- dfValidador[i,"COBERTURA_AGRAV2"]
    # }  
    
    if(dfValidador[i,"SALUD_TIT"] == "IP"){
      dfValidador[i,"PORC_TIT"]<-0.5
    }else if(dfValidador[i,"SALUD_TIT"] == "IT"){
      dfValidador[i,"PORC_TIT"]<-0.7
    #Gran Invalidez
    }else{
      dfValidador[i,"PORC_TIT"]<-1
    }
  }
  if(benefVigentes==0 && dfValidador[i,"TIPO_RVA"]=="SPL") next 
  ##############################
  #Grupo Familiar del CP
  if(benefVigentes==0){
    if(dfValidador[i,"COBERTURA"] == "SOB"){
      if(dfValidador[i,"SEXO_TIT"]=="M"){
        dfValidador[i,"SEXO_CONY"] <- "F"  
        dfValidador[i,"FECNAC_CONY"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_cony_F_SOB)
        diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_cony_F_SOB-trunc(grupoFamiliarCP$Edad_cony_F_SOB)))
        dfValidador[i,"FECNAC_CONY"] <- dfValidador[i,"FECNAC_CONY"] + days(diasRestantes)
      }else{
        dfValidador[i,"SEXO_CONY"] <- "M"  
        dfValidador[i,"FECNAC_CONY"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_cony_M_SOB)
        diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_cony_M_SOB-trunc(grupoFamiliarCP$Edad_cony_M_SOB)))
        dfValidador[i,"FECNAC_CONY"] <- dfValidador[i,"FECNAC_CONY"] + days(diasRestantes)
      }
      dfValidador[i,"SALUD_CONY"] <- "S"
      dfValidador[i,"PORC_CONY"] <- grupoFamiliarCP$Porc_cony_SOB      
      
      dfValidador[i,"FECNAC_MAD"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_padre_SOB)
      diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_padre_SOB-trunc(grupoFamiliarCP$Edad_padre_SOB)))
      dfValidador[i,"FECNAC_MAD"] <- dfValidador[i,"FECNAC_MAD"] + days(diasRestantes)
      dfValidador[i,"SALUD_MAD"] <- "S"
      dfValidador[i,"PORC_MAD"] <- grupoFamiliarCP$Porc_padre_SOB
      
      dfValidador[i,"SEXO_HIJ_1"] <- "F"
      dfValidador[i,"FECNAC_HIJ_1"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_Hijo_SOB)
      diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_Hijo_SOB-trunc(grupoFamiliarCP$Edad_Hijo_SOB)))
      dfValidador[i,"FECNAC_HIJ_1"] <- dfValidador[i,"FECNAC_HIJ_1"] + days(diasRestantes)
      dfValidador[i,"SALUD_HIJ_1"] <- "S"
      dfValidador[i,"PORC_HIJ_1"] <- grupoFamiliarCP$Porc_hijo_SOB
      
      #Fecha de Siniestro posterior a 01/08/2013, calcular hijos hasta 28
      if(dfValidador[i,"FECHA_SINIESTRO"]>=fecHijos28){
        dfValidador[i,"EDAD_MAX_HIJ_1"] <- 28
      }else{
        dfValidador[i,"EDAD_MAX_HIJ_1"] <- 18
      }      
      
    }else{
      if(dfValidador[i,"SEXO_TIT"]=="M"){
        dfValidador[i,"SEXO_CONY"] <- "F"  
        dfValidador[i,"FECNAC_CONY"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_cony_F_INV)
        diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_cony_F_INV-trunc(grupoFamiliarCP$Edad_cony_F_INV)))
        dfValidador[i,"FECNAC_CONY"] <- dfValidador[i,"FECNAC_CONY"] + days(diasRestantes)
      }else{
        dfValidador[i,"SEXO_CONY"] <- "M"  
        dfValidador[i,"FECNAC_CONY"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_cony_M_INV)
        diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_cony_M_INV-trunc(grupoFamiliarCP$Edad_cony_M_INV)))
        dfValidador[i,"FECNAC_CONY"] <- dfValidador[i,"FECNAC_CONY"] + days(diasRestantes)
      }
      dfValidador[i,"SALUD_CONY"] <- "S"
      dfValidador[i,"PORC_CONY"] <- grupoFamiliarCP$Porc_cony_INV

      dfValidador[i,"FECNAC_MAD"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_padre_INV)
      diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_padre_INV-trunc(grupoFamiliarCP$Edad_padre_INV)))
      dfValidador[i,"FECNAC_MAD"] <- dfValidador[i,"FECNAC_MAD"] + days(diasRestantes)
      dfValidador[i,"SALUD_MAD"] <- "S"
      dfValidador[i,"PORC_MAD"] <- grupoFamiliarCP$Porc_padre_INV            
      
      dfValidador[i,"SEXO_HIJ_1"] <- "F"
      dfValidador[i,"FECNAC_HIJ_1"] <- AddMonths(dfValidador[i,"FECNAC_TIT"],-12*grupoFamiliarCP$Edad_Hijo_INV)
      diasRestantes <- -trunc(30*(grupoFamiliarCP$Edad_Hijo_INV-trunc(grupoFamiliarCP$Edad_Hijo_INV)))
      dfValidador[i,"FECNAC_HIJ_1"] <- dfValidador[i,"FECNAC_HIJ_1"] + days(diasRestantes)
      dfValidador[i,"SALUD_HIJ_1"] <- "S"
      dfValidador[i,"PORC_HIJ_1"] <- grupoFamiliarCP$Porc_hijo_INV
      
      #Fecha de Siniestro posterior a 01/08/2013, calcular hijos hasta 28
      if(dfValidador[i,"FECHA_SINIESTRO"]>=fecHijos28){
        dfValidador[i,"EDAD_MAX_HIJ_1"] <- 28
      }else{
        dfValidador[i,"EDAD_MAX_HIJ_1"] <- 18
      }            
    }
    next
  }
  for(j in 1:benefVigentes) {
    #2 o 3: Conyuge o Concubina
    if(dfBeneficiarios[j,"EXSCTRB_PARENTESCO"]=="2" || dfBeneficiarios[j,"EXSCTRB_PARENTESCO"]=="3"){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"EXSCTRB_SEXO"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"EXSCTRB_FECHA_NACIMIENTO"]
      dfValidador[i,"SALUD_CONY"] <- ifelse(dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"])
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,"EXSCTRB_PORCENTAJE_BENEFICIO"]/100
    #4: Padre o Madre    
    }else if(dfBeneficiarios[j,"EXSCTRB_PARENTESCO"]=="4"){
      if(dfBeneficiarios[j,"EXSCTRB_SEXO"]=="M"){
        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"EXSCTRB_FECHA_NACIMIENTO"]
        dfValidador[i,"SALUD_PAD"] <- ifelse(dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"])
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,"EXSCTRB_PORCENTAJE_BENEFICIO"]/100        
      }else{
        dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"EXSCTRB_FECHA_NACIMIENTO"]
        dfValidador[i,"SALUD_MAD"] <- ifelse(dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"])
        dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,"EXSCTRB_PORCENTAJE_BENEFICIO"]/100        
      }
    #5: Hijos      
    }else if(dfBeneficiarios[j,"EXSCTRB_PARENTESCO"]=="5"){
      contHijos <- contHijos + 1  
      dfValidador[i,paste("SEXO_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXSCTRB_SEXO"]
      dfValidador[i,paste("FECNAC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXSCTRB_FECHA_NACIMIENTO"]
      dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- ifelse(dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"]=="A","S",dfBeneficiarios[j,"EXSCTRB_ESTADO_PSICOFISICO"])
      dfValidador[i,paste("PORC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"EXSCTRB_PORCENTAJE_BENEFICIO"]/100        
      
      #Fecha de Siniestro posterior a 01/08/2013, calcular hijos hasta 28
      if(dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")]=="I"){
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 111  
      }else if(dfValidador[i,"FECHA_SINIESTRO"]>=fecHijos28){
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 28
      }else{
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 18
      }
      
    }
  }
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
}
#View(dfValidador)
dfValidador$FECHA_SINIESTRO<-NULL
dfValidador$COBERTURA_AGRAV1<-NULL
dfValidador$COBERTURA_AGRAV2<-NULL
library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../BaseRRVV_RIMAC_SCTR_SPL_Agravamientos_",as.character(fecCierre,format = "%m%Y"),".xlsx",sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
