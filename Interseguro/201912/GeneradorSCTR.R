
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
directorioBD <- "C:/Ronald/Auditorias/Interseguro/SBS/122019/SCTR/CIA"
nombreBD <- "SCTR Sura.xlsx"
hojaBD <- "SCTR Soles"

fecFallecimiento <- as.Date("01/02/1900", format = "%d/%m/%Y")
fecProdTablasNueva <- as.Date("01/01/2019", format = "%d/%m/%Y") 
fecHijos28 <- as.Date("01/08/2013", format = "%d/%m/%Y") 

BD_RRVV <- read_excel(paste(directorioBD,nombreBD,sep = "/"), 
                      sheet = hojaBD, col_types = c("numeric", "numeric", "text", "date", "text", 
                                                             "text", "numeric", "numeric", "numeric", "numeric", 
                                                             "numeric", "date", "numeric", "date", "numeric", 
                                                             "text", "text", "numeric", "text", "numeric", 
                                                             "numeric", "numeric", "numeric", "numeric", "numeric", 
                                                             "numeric", "numeric", "numeric", "numeric", "text", 
                                                             "text", "text", "numeric", "numeric", "numeric", 
                                                             "numeric", "numeric", "date", "numeric", "text", 
                                                             "date", "text", "numeric", "numeric", "numeric", 
                                                             "numeric", "numeric", "numeric", "date", "numeric", 
                                                             "numeric", "text", "text", "numeric", "text", 
                                                             "text", "numeric", "numeric", "numeric", "numeric", 
                                                             "numeric", "numeric", "numeric", "numeric", "numeric", 
                                                             "numeric", "numeric","numeric", "text"
                                                              
                                                             ))

#Parentescos
#Titular:80
#Conyuge:10
#Hijos:30
#Padres:40
#BD_RRVV$`Reserva Base Soles`
BD_RRVV_TIT <- BD_RRVV[BD_RRVV$Parentesco == 80,]


dfValidador <- data.frame(BD_RRVV_TIT$Póliza,
                          BD_RRVV_TIT$Póliza,
                          as.Date(rep(x = fecCierre,nrow(BD_RRVV_TIT)), format = "%d/%m/%Y"),
                          BD_RRVV_TIT$Fec.Ini.Vigencia,#Inicio de Vigencia
                          BD_RRVV_TIT$Fec.Ini.Vigencia,#Fecha seleccion tabla CAMBIAR POR FECHA DE INICIO DE VIGENCIA
                          #ifelse(BD_RRVV_TIT$PCT_RENTA_TEMPORAL<1,0,BD_RRVV_TIT$PERIODO_DIFERIDO*12),#Considerar Polizas Escalonadas
                          ifelse(BD_RRVV_TIT$`Porc. Escalonada`>0,0,BD_RRVV_TIT$`Meses Dif.`),
                          BD_RRVV_TIT$`Meses Gar.`,
                          0,#Porc. PG
                          ifelse(BD_RRVV_TIT$`Tipo Pensión` == "S","SOB",if_else(BD_RRVV_TIT$`Tipo Pensión`=="I" |BD_RRVV_TIT$`Tipo Pensión`=="IP" ,"INV",if_else(BD_RRVV_TIT$`Tipo Pensión`=="V","JUB", if_else(BD_RRVV_TIT$`Tipo Pensión`=="A"&BD_RRVV_TIT$Inválido=="N","JUB",if_else(BD_RRVV_TIT$`Tipo Pensión`=="A"&BD_RRVV_TIT$Inválido=="S","INV",BD_RRVV_TIT$`Tipo Pensión`))))),#BD_RRVV_TIT$`Tipo Pensión`), #Cobertura
                                                     BD_RRVV_TIT$`Pensión Orig.`,
                          ifelse(BD_RRVV_TIT$Gratificación == "S",14,12),
                          ifelse(BD_RRVV_TIT$Moneda == "001" | BD_RRVV_TIT$Moneda == "013","PEN","USD"),
                          BD_RRVV_TIT$`Tasa de Ajuste Anual`/100,
                          ifelse(BD_RRVV_TIT$`Derecho a Crecer`=="N",0,1),
                          #ifelse(!is.na(BD_RRVV_TIT$`Fecha de envío al MELER`) & fecProdTablasNueva<=BD_RRVV_TIT$`Fecha de envío al MELER`,BD_RRVV_TIT$`Tasa de Reserva Matemática SPP`,BD_RRVV_TIT$`Tasa de Costo Equivalente`)/100,
                          #ifelse(!is.na(BD_RRVV_TIT$`Fecha de envío al MELER`) & fecProdTablasNueva<=BD_RRVV_TIT$`Fecha de envío al MELER`,BD_RRVV_TIT$`Tasa de Reserva Matemática SPP`,BD_RRVV_TIT$`Tasa de Costo Equivalente`)/100,
                          0.03,
                          0.03,
                          BD_RRVV_TIT$`Tasa de Venta`/100,
                          BD_RRVV_TIT$`Tasa de Mercado`/100,#Campo Tasa Mercado
                          BD_RRVV_TIT$Fec.Pago, # Fecha de Emision
                          ifelse(BD_RRVV_TIT$`Estado Póliza`==3,1,0), #Campo CADUCADA para BD Rimac
                          ifelse(fecFallecimiento<BD_RRVV_TIT$`Fecha Fallecimiento`,"S","N"), #Campo PAGO_GASTO_FUNERARIO para BD Rimac
                          BD_RRVV_TIT$`Meses Dif.`,#Porcentaje Renta Temporal
                          BD_RRVV_TIT$`Porc. Escalonada`/100, #Porcentaje Segundo Tramo
                          BD_RRVV_TIT$Fec.Nacim.,
                          BD_RRVV_TIT$Sexo,
                          ifelse(BD_RRVV_TIT$`Tipo Invalidez`!="N","I","S"),#Salud
                          BD_RRVV_TIT$`% Pensión Ajustado`/100,
                          BD_RRVV_TIT$`Fecha Fallecimiento`,
                          BD_RRVV_TIT$`Fecha de Solicitud de Pensión`,
                          BD_RRVV_TIT$`Tipo Invalidez`,
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
                        "FECFALLECIMIENTO_TIT",
                        "FECSOLICITUD_PEN",
                        "TIPO_INVALIDEZ"
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
for(i in 1:filas) {
  #Fecha de Seleccion de Tabla para produccion 2019
  if(!is.na(dfValidador[i,"FECHA_EMISION"]) &&  dfValidador[i,"FECHA_EMISION"]>=fecProdTablasNueva){
    dfValidador[i,"FEC_SEL_TABLA"]<-dfValidador[i,"FECHA_EMISION"]
  #Para las polizas del calce, usar la menor de la tasa de calce y venta   
  }else if(dfValidador[i,"TASA_COSTO_VENTA"]>0){
    dfValidador[i,"TASA_COSTO_EQUIV_RV"]<-min(dfValidador[i,"TASA_COSTO_EQUIV_RV"],dfValidador[i,"TASA_COSTO_VENTA"])
    dfValidador[i,"TASA_COSTO_EQUIV_GS"]<-    dfValidador[i,"TASA_COSTO_EQUIV_RV"]
  }
  
  if(dfValidador[i,"SALUD_TIT"] == "I"){
    if(dfValidador[i,"TIPO_INVALIDEZ"] == "P"){
      dfValidador[i,"SALUD_TIT"] <- "IP"
    }else{
      dfValidador[i,"SALUD_TIT"] <- "IT"
    }     
  }
  
  contHijos <- 0
  dfBeneficiarios <- BD_RRVV[BD_RRVV$Póliza==dfValidador[i,"ID"] & BD_RRVV$Parentesco != 80 &
                               BD_RRVV$`% Pensión Ajustado` >0 &
                               is.na(BD_RRVV$`Fecha Fallecimiento`) & BD_RRVV$`Estado Ben.`!="TERM",]          
                                     #as.numeric(format(Tramas_RRVV_BEN$EXRVPB_FECHA_FALLECIMIENTO,"%Y")) <= 1900,]

    benefVigentes<-nrow(dfBeneficiarios)
  dfValidador[i,"TOTAL_BENEF"]<-benefVigentes
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  # if(dfValidador[i,"FECFALLECIMIENTO_TIT"]>fecFallecimiento){
  #   dfValidador[i,"PORC_PG"]<-dfValidador[i,"MTO_PENSIONGAR"]/dfValidador[i,"PENSION_BASE"]
  # }  
  #Para Polizas en Soles VAC no hay amortizacion desde 09.2019 (Protecta)
  # if(dfValidador[i,"MONEDA"]=="PEN" && dfValidador[i,"AJUSTE"]==0 &&
  #    dfValidador[i,"FEC_SEL_TABLA"]<fecProdTablasNueva){
  #   dfValidador[i,"FEC_SEL_TABLA"]<-fecProdTablasNueva
  #   dfValidador[i,"TASA_COSTO_EQUIV_RV"]<-dfValidador[i,"TASA_MERCADO"]
  #   dfValidador[i,"TASA_COSTO_EQUIV_GS"]<-dfValidador[i,"TASA_MERCADO"]    
  # }  
  
  # if(benefVigentes==0){
  #   #En Sobrevivencias cuando no hay beneficiarios vigentes, usar la pension del PG
  #   if(dfValidador[i,"COBERTURA"]=="SOB" && dfValidador[i,"PENSION_BASE"]==0){
  #     dfValidador[i,"PENSION_BASE"]<-dfValidador[i,"MTO_PENSIONGAR"]
  #     dfValidador[i,"PORC_PG"]<-1
  #   }
  #   next
  # }  
  #j<-2
  if(benefVigentes==0) next
  
  for(j in 1:benefVigentes) {
    #10: Conyuge o Concubina
    if(dfBeneficiarios[j,"Parentesco"]==10){
      dfValidador[i,"SEXO_CONY"] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,"FECNAC_CONY"] <- dfBeneficiarios[j,"Fec.Nacim."]
      if(dfBeneficiarios[j,"Inválido"] == "N"){
        dfValidador[i,"SALUD_CONY"] <- "S"  
      }else if(dfBeneficiarios[j,"Tipo Invalidez"] == "P"){
        dfValidador[i,"SALUD_CONY"] <- "IP"
      }else{
        dfValidador[i,"SALUD_CONY"] <- "IT"
      }
      
      dfValidador[i,"PORC_CONY"] <- dfBeneficiarios[j,"% Pensión Ajustado"]/100
    #40: Padre o Madre    
    }else if(dfBeneficiarios[j,"Parentesco"]==40){
      if(dfBeneficiarios[j,"Sexo"]=="M"){
        dfValidador[i,"FECNAC_PAD"] <- dfBeneficiarios[j,"Fec.Nacim."]
        if(dfBeneficiarios[j,"Inválido"] == "N"){
          dfValidador[i,"SALUD_PAD"] <- "S"  
        }else if(dfBeneficiarios[j,"Tipo Invalidez"] == "P"){
          dfValidador[i,"SALUD_PAD"] <- "IP"
        }else{
          dfValidador[i,"SALUD_PAD"] <- "IT"
        }        
        dfValidador[i,"PORC_PAD"] <- dfBeneficiarios[j,"% Pensión Ajustado"]/100        
      }else{
        dfValidador[i,"FECNAC_MAD"] <- dfBeneficiarios[j,"Fec.Nacim."]
        if(dfBeneficiarios[j,"Inválido"] == "N"){
          dfValidador[i,"SALUD_MAD"] <- "S"  
        }else if(dfBeneficiarios[j,"Tipo Invalidez"] == "P"){
          dfValidador[i,"SALUD_MAD"] <- "IP"
        }else{
          dfValidador[i,"SALUD_MAD"] <- "IT"
        }        
        dfValidador[i,"PORC_MAD"] <- dfBeneficiarios[j,"% Pensión Ajustado"]/100        
      }
    #30: Hijos      
    }else if(dfBeneficiarios[j,"Parentesco"]==30){
      contHijos <- contHijos + 1  
      dfValidador[i,paste("SEXO_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Sexo"]
      dfValidador[i,paste("FECNAC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"Fec.Nacim."]
      if(dfBeneficiarios[j,"Inválido"] == "N"){
        dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- "S"  
      }else if(dfBeneficiarios[j,"Tipo Invalidez"] == "P"){
        dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- "IP"
      }else{
        dfValidador[i,paste("SALUD_HIJ_",contHijos,sep = "")] <- "IT"
      }              
      dfValidador[i,paste("PORC_HIJ_",contHijos,sep = "")] <- dfBeneficiarios[j,"% Pensión Ajustado"]/100
            if(dfBeneficiarios[j,"Inválido"] != "N"){
        dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 111  
       }else if(dfValidador[i,"FECHAINIVIG"]<fecHijos28){ #USAR FECHA DE INICIO DE VIGENCIA SCTR Y PREVI
         dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 18
       }else{
         dfValidador[i,paste("EDAD_MAX_HIJ_",contHijos,sep = "")] <- 28
       }
      
    }
    #Acumulador %PG para SOB
    #Limpias la informacion de fallecidos
  }
  
  dfValidador[i,"TOTAL_HIJ"]<-contHijos
  #Asignas el PG en la SOB
}



dfValidador$FECSOLICITUD_PEN <- NULL
dfValidador$TIPO_INVALIDEZ<-NULL


#View(dfValidador)
library(openxlsx)
write.xlsx(dfValidador, file=paste(directorioBD,"/../Base_",hojaBD,"_Interseguro_",as.character(fecCierre,format = "%m%Y"),"_",nombreBD,sep=""))
fecEnd <-Sys.time()
print(paste("Inicio:",format(fecStart,"%H:%M:%S"),"Fin:",format(fecEnd,"%H:%M:%S")))
