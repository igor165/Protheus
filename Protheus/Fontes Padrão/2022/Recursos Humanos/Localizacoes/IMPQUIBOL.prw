#INCLUDE "Protheus.CH"
#INCLUDE "IMPRESBOL.CH"
#INCLUDE "MSOLE.CH"
#DEFINE   nColMax	2350

/*                       
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIMPQUIBOL บAutor  ณRicardo Berti         บ Data ณ  20/05/13   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณImpressao do QUINQUENIO -  modo Grafico. (Localizacao Bolivia)บฑฑ
ฑฑบ          ณObs.: SRA deve estar posicionado.                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPER145                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 

User Function IMPQUIBOL()
  
Local cFileLogo1	:= ""
Local cFileLogo2	:= ""
Local cStartPath	:= GetSrvProfString("Startpath","")
Local cHoras	    := " "
Local nValor		:= 0                  
Local nVal			:= 0                  
Local cDesc			:= ""
Local cMesMed		:= ""
Local nTotDeduccion := 0
Local cIdade        := ""
//Local aTempoServico := {}
Local cActividad    := ""  
Local nTotRemuner	:= 0
Local nTot1Remun 	:= 0
Local nTot2Remun 	:= 0
Local nTot3Remun 	:= 0
Local nTotBenSocial	:= 0  
Local nTotD123	 	:= 0
Local nValorAux		:= 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณObjetos para Impressao Grafica - Declaracao das Fontes Utilizadas.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Private oFont08, oFont08n, oFont09, oFont28n 

oFont08	:= TFont():New("Courier New"	 ,08,08,,.F.,,,,.T.,.F.)
oFont08n:= TFont():New("Times New Roman",08,08,,.T.,,,,.T.,.F.)	 //Negrito
oFont09	:= TFont():New("Courier New"	 ,09,09,,.F.,,,,.T.,.F.)
oFont28n:= TFont():New("Times New Roman",28,28,,.T.,,,,.T.,.F.)    //Negrito

nEpoca:= SET(5,1910)

SET CENTURY ON //-- MUDA ANO PARA 4 DIGITOS 

cIdade := AllTrim(Str(Calc_Idade(dDtPagoQui, SRA->RA_NASC)))
//aTempoServico := DateDiffYMD( SRA->RA_ADMISSA , SRA->RA_DEMISSA )
cActividad:= fTabela( "S007",1 ,8 , )
cActividad:= If( Type("cActividad") == "U",  "", cActividad )

oPrint:StartPage() 			//Inicia uma nova pagina   

oPrint:Box ( 0020, 0035, 2650, nColMax )
oPrint:Box ( 0027, 0045, 2638, nColMax-7 )

cFileLogo1 	:= cStartPath+ "BOL_140A.BMP"	// Logo: ESTADO PLURINACIONAL DE BOLIVIA
cFileLogo2 	:= cStartPath+ "BOL_140C.BMP"	// Logo: MINISTERIO DE TRABAJO EMPLEO Y PREVISION SOCIAL

If File( cFileLogo1 )
	oPrint:SayBitmap(050,225, cFileLogo1,255,220)
EndIf	
If File( cFileLogo2 )
	oPrint:SayBitmap(050,1875, cFileLogo2,235,220)
EndIf

oPrint:say(272,120,"ESTADO PLURINACIONAL DE",oFont08n)
oPrint:say(305,270,"BOLIVIA",oFont08n)

oPrint:say(275,1810,"MINISTERIO DE TRABAJO,",oFont08n)
oPrint:say(305,1780,"EMPLEO Y PREVISION SOCIAL",oFont08n)

oPrint:say ( 0145, 0910, "FINIQUITO", oFont28n )
oPrint:line( 0375, 0060, 0375, nColMax-21 )		//Linha Horizontal
oPrint:line( 0380, 0060, 0380, nColMax-21 )		//Linha Horizontal   

oPrint:say ( 0400, 0068, STR0002, oFont09 ) 	//"I - DATOS GENERALES"  
oPrint:Box ( 0456, 0062, 0880, nColMax-21 )    				//Box
	oPrint:say ( 0464, 0064, STR0003+aInfo[3], oFont09 )		//"RAZON SOCIAL O NOMBRE DE LA EMPRESA: "
		oPrint:line ( 0456, 1950, 0509, 1950) 				
		oPrint:line ( 0456, 2150, 0509, 2150) 					
	oPrint:line( 0509, 0062, 0509, nColMax-21 ) 		   		//Linha Horizontal 
	oPrint:say ( 0517, 0064, STR0004+ cActividad, oFont09 )		//"RAMA DE ACTIVIDAD ECONOMICA: "  
		oPrint:line ( 0509, 0950, 0562, 0950)
		oPrint:line ( 0509, 1050, 0562, 1050) 					
		oPrint:line ( 0509, 1200, 0562, 1200) 						
	oPrint:say ( 0517, 1210, STR0005 + aInfo[4], oFont09 )		//"DOMICILIO: "
	oPrint:line( 0562, 0062, 0562, nColMax-21 ) 		   		//Linha Horizontal
	oPrint:say ( 0570, 0064, STR0006+(SRA->RA_NOME), oFont09 )    //"NOMBRE DEL TRABAJADOR: "
   		oPrint:line ( 0562, 1950, 0615, 1950) 					 
   		oPrint:line ( 0562, 2150, 0615, 2150) 					
	oPrint:line( 0615, 0062, 0615, nColMax-21 ) 		   		//Linha Horizontal
	oPrint:say ( 0623, 0064, STR0007+;
		(fDesc("SX5","33"+SRA->RA_ESTCIVI,fDescSX5(2),15)), oFont09 )    //"ESTADO CIVIL: " 
		oPrint:line ( 0615, 0825, 0668, 0825)						                      
		oPrint:line ( 0615, 0950, 0668, 0950)
	oPrint:say ( 0623, 0960, STR0008+cIdade, oFont09 )    //"EDAD:"
		oPrint:line ( 0615, 1300, 0668, 1300) 				
		oPrint:line ( 0615, 1400, 0668, 1400) 					
	oPrint:say ( 0626, 1418, STR0005+SRA->RA_ENDEREC, oFont09 )    //"DOMICILIO:"
	oPrint:line( 0668, 0062, 0668, nColMax-21 ) 		   		//Linha Horizontal
	oPrint:say ( 0676, 0064, STR0009+fDesc("SRJ",SRA->RA_CODFUNC,"RJ_DESC"), oFont09 )//"PROFESION U OCUPACION: "                             
   		oPrint:line ( 0668, 1950, 0721, 1950) 					
   		oPrint:line ( 0668, 2150, 0721, 2150) 					
	oPrint:line( 0721, 0062, 0721, nColMax-21 ) 		   		//Linha Horizontal	
	oPrint:say ( 0729, 0064, STR0010+SRA->RA_CIC, oFont09 )    //"CI: "   
		oPrint:line ( 0721, 0600, 0774, 0600)
	oPrint:say ( 0729, 0610, STR0011+DtoC(SRA->RA_ADMISSA), oFont09 )    //"FECHA DE INGRESO: " 
		oPrint:line ( 0721, 1400, 0774, 1400) 					
	oPrint:say ( 0729, 1410, STR0012+DtoC(dDtPagoQui), oFont09 )    //"FECHA DE RETIRO" 
	oPrint:line( 0774, 0062, 0774, nColMax-21 ) 		   		//Linha Horizontal
		oPrint:say ( 0782, 0064, "PAGO DE INDEMNIZACION: "+"PAGO "+cCausa+". "+"QUINQUENIO", oFont09 )    //STR0013 "PAGO DE INDEMNIZACION: " ## STR0075"PAGO "##"QUINQUENIO" STR0001
		oPrint:line ( 0774, 1050, 0827, 1050) 
		oPrint:line ( 0774, 1200, 0827, 1200)
	oPrint:say ( 0782, 1210, STR0014+Transform( nSalario , GetSx3Cache("RA_SALARIO","X3_PICTURE") ), oFont09 )    //"REMUNERACION MENSUAL Bs: "
		oPrint:line ( 0774, 2150, 0880, 2150) 					
	oPrint:line( 0827, 0062, 0827, nColMax-21 ) 		   		//Linha Horizontal
	oPrint:say ( 0835, 0064, STR0015, oFont09 )    //"TIEMPO DE SERVICIO: " 
	oPrint:say ( 0835, 0450, AllTrim(Str(5*Val(cCausa))), oFont09 )        
	oPrint:say ( 0835, 0500, STR0016, oFont09 )    //"ANOS"
    oPrint:say ( 0835, 0650, AllTrim(Str(0)), oFont09 )
	oPrint:say ( 0835, 0700, STR0017, oFont09 )    //"MESES"
	oPrint:say ( 0835, 0850, AllTrim(Str(0)), oFont09 )
	oPrint:say ( 0835, 0900, STR0018, oFont09 )    //"DIAS"	                
		oPrint:line ( 0827, 1850, 0880, 1850)
		oPrint:line ( 0827, 1950, 0880, 1950) 					
oPrint:line( 0902, 0062, 0902, nColMax-21 ) 		   		//Linha Horizontal
oPrint:line( 0907, 0062, 0907, nColMax-21 ) 		   		//Linha Horizontal 

				      
oPrint:say ( 0924, 0068, STR0019, oFont09 )		//"II - LIQUIDACION DE LA REMUNERACION PROMEDIO INDEMNIZABEL EN BASE A LOS 3 ULTIMO MESES"
oPrint:line( 0977, 0062, 0977, nColMax-21 ) 		   		//Linha Horizontal
oPrint:line( 0982, 0062, 0982, nColMax-21 ) 		   		//Linha Horizontal  
oPrint:Box ( 1004, 0062, 1466, nColMax-21 )    				//Box
		oPrint:line ( 1004, 0500, 1466, 0500)						//Linhas Verticais 
		oPrint:line ( 1004, 0950, 1466, 0950) 					
		oPrint:line ( 1004, 1400, 1466, 1400) 					
		oPrint:line ( 1004, 1850, 1466, 1850) 
	oPrint:say ( 1012, 0064, STR0020, oFont09 )    //"A)MESES"   
	oPrint:say ( 1012, 2020, STR0021, oFont09 )    //"TOTALES"
	oPrint:line( 1057, 0062, 1057, nColMax-21 ) 		   	//Linha Horizontal   
	
// REFAZER MEDIAS

If RetHoraVal( "0760", @cHoras, @nValor, @cDesc, @cMesMed ) 
	If !Empty(cMesMed)
		oPrint:say ( 1012, 1600, Upper(FDESC_MES(Val(SubsTr(cMesMed,5,2)))), oFont08)
	EndIf
	oPrint:say ( 1065, 1600, Transform(nValor, "@E 99,999,999.99"), oFont08) 
	nTot3Remun := nValor
	nTotRemuner+= nValor   

	RetHoraVal( "0755", @cHoras, @nValor, @cDesc, @cMesMed )	
	If !Empty(cMesMed)
		oPrint:say ( 1012, 0630, Upper(FDESC_MES(Val(SubsTr(cMesMed,5,2)))), oFont08)
    EndIf
    nValorAux:= nValor

	RetHoraVal( "0754", @cHoras, @nValor, @cDesc, @cMesMed )
	nValorAux += nValor
	oPrint:say ( 1065, 0650, Transform(nValorAux, "@E 99,999,999.99"), oFont08) 
	nTot1Remun := nValorAux
	nTotRemuner+= nValorAux         

	RetHoraVal( "0756", @cHoras, @nValor, @cDesc, @cMesMed )
	If !Empty(cMesMed)
		oPrint:say ( 1012, 1100, Upper(FDESC_MES(Val(SubsTr(cMesMed,5,2)))), oFont08)
    EndIf
	oPrint:say ( 1065, 1150, Transform(nValor, "@E 99,999,999.99"), oFont08)  
	nTot2Remun := nValor
	nTotRemuner+= nValor
Else 
	RetHoraVal( "0754", @cHoras, @nValor, @cDesc, @cMesMed )  
	If !Empty(cMesMed)
		oPrint:say ( 1012, 0630, Upper(FDESC_MES(Val(SubsTr(cMesMed,5,2)))), oFont08)
	EndIf
	oPrint:say ( 1065, 0650, Transform(nValor, "@E 99,999,999.99"), oFont08) 
	nTot1Remun := nValor
	nTotRemuner+= nValor

	RetHoraVal( "0755", @cHoras, @nValor, @cDesc, @cMesMed )	
	If !Empty(cMesMed)
		oPrint:say ( 1012, 1100, Upper(FDESC_MES(Val(SubsTr(cMesMed,5,2)))), oFont08)
    EndIf
	oPrint:say ( 1065, 1150, Transform(nValor, "@E 99,999,999.99"), oFont08) 
	nTot2Remun := nValor
	nTotRemuner+= nValor

	RetHoraVal( "0756", @cHoras, @nValor, @cDesc, @cMesMed )
	If !Empty(cMesMed)
		oPrint:say ( 1012, 1600, Upper(FDESC_MES(Val(SubsTr(cMesMed,5,2)))), oFont08)
    EndIf
	oPrint:say ( 1065, 1600, Transform(nValor, "@E 99,999,999.99"), oFont08)  
	nTot3Remun := nValor
	nTotRemuner+= nValor     
Endif

	oPrint:say ( 1065, 0064, STR0022, oFont09 )    //"REMUNERACION MENSUAL" 
		oPrint:line ( 1057, 0600, 1110, 0600)						//Linha Vertical
		oPrint:line ( 1057, 1050, 1110, 1050) 						//Linha Vertical		
		oPrint:line ( 1057, 1500, 1110, 1500) 						//Linha Vertical 
		oPrint:line ( 1057, 1950, 1110, 1950) 						//Linha Vertical  
	oPrint:say ( 1065, 0510, STR0023, oFont09 )    //"Bs"	
	oPrint:say ( 1065, 0960, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1065, 1410, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1065, 1860, STR0023, oFont09 )    //"Bs"
	                    
	oPrint:say ( 1065, 2000, Transform(nTotRemuner, "@E 99,999,999.99"), oFont08)     
	oPrint:line( 1110, 0062, 1110, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1118, 0064, STR0024, oFont09 )    //"B)OTROS CONCEPTOS"
	oPrint:say ( 1156, 0064, STR0025, oFont09 )    //"PERCIBIDOS EN EL MES"
	oPrint:line( 1201, 0062, 1201, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1209, 0510, STR0023, oFont09 )    //"Bs" 
	oPrint:say ( 1209, 0960, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1209, 1410, STR0023, oFont09 )    //"Bs" 
	oPrint:say ( 1209, 1860, STR0023, oFont09 )    //"Bs"	                  
		oPrint:line ( 1201, 0600, 1413, 0600)						//Linha Vertical	    
		oPrint:line ( 1201, 1050, 1413, 1050) 						//Linha Vertical  
		oPrint:line ( 1201, 1500, 1413, 1500) 						//Linha Vertical
		oPrint:line ( 1201, 1950, 1413, 1950) 						//Linha Vertical
	oPrint:line( 1254, 0062, 1254, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1262, 0510, STR0023, oFont09 )    //"Bs"	
	oPrint:say ( 1262, 0960, STR0023, oFont09 )    //"Bs"		
	oPrint:say ( 1262, 1410, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1262, 1860, STR0023, oFont09 )    //"Bs"           
	oPrint:line( 1307, 0062, 1307, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1315, 0510, STR0023, oFont09 )    //"Bs"	
	oPrint:say ( 1315, 0960, STR0023, oFont09 )    //"Bs"		
	oPrint:say ( 1315, 1410, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1315, 1860, STR0023, oFont09 )    //"Bs"    
	oPrint:line( 1360, 0062, 1360, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1368, 0510, STR0023, oFont09 )    //"Bs"	
	oPrint:say ( 1368, 0960, STR0023, oFont09 )    //"Bs"		
	oPrint:say ( 1368, 1410, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1368, 1860, STR0023, oFont09 )    //"Bs"
	oPrint:line( 1413, 0062, 1413, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1421, 0064, STR0039, oFont09 )    //"TOTAL Bs"	 
	oPrint:say ( 1421, 0650, Transform(nTot1Remun, "@E 99,999,999.99"), oFont08) 
	oPrint:say ( 1421, 1150, Transform(nTot2Remun, "@E 99,999,999.99"), oFont08) 
	oPrint:say ( 1421, 1600, Transform(nTot3Remun, "@E 99,999,999.99"), oFont08)  
	oPrint:say ( 1421, 2000, Transform(nTotRemuner,"@E 99,999,999.99"), oFont08)
oPrint:line( 1471, 0062, 1471, nColMax-21 ) 		   	//Linha Horizontal

oPrint:say ( 1488, 0068, STR0027, oFont09 )		//"III - TOTAL REMUNERACION PROMEDIO INDEMNIZABLE (A+B) DIVIDIDO ENTRE 3:"
oPrint:line ( 1471, 1850, 1541, 1850) 						//Linha Vertical	 
oPrint:say ( 1488, 1860, STR0023, oFont09 )    //"Bs"   
RetHoraVal( "0761", @cHoras, @nValor, @cDesc )
oPrint:say ( 1488, 2000, Transform(nValor, "@E 99,999,999.99"), oFont08 )                           
	oPrint:line ( 1471, nColMax-21, 1541, nColMax-21) 						//Linha Vertical
	oPrint:line ( 1471, nColMax-26, 1541, nColMax-26) 						//Linha Vertical
oPrint:line( 1541, 0062, 1541, nColMax-21 ) 		   	//Linha Horizontal
oPrint:line( 1546, 0062, 1546, nColMax-21 ) 		   	//Linha Horizontal
oPrint:Box ( 1568, 0062, 2052, nColMax-21 )    			//Box     
	oPrint:line ( 1568, 1850, 2052, 1850) 						//Linha Vertical
	oPrint:line ( 1568, 1950, 2052, 1950) 						//Linha Vertical
	oPrint:say ( 1576, 0064, STR0028, oFont09 )		//"C)DESAHUCIO TRES MESES (EN CASO DE RETIRO FORSOZO)"
	oPrint:say ( 1576, 1860, STR0023, oFont09 )    //"Bs"
	
	oPrint:line( 1628, 0062, 1628, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1636, 0064, STR0029, oFont09 )    //"D)INDEMNIZACION POR TIEMPO DE TRABAJO:"
	oPrint:line ( 1628, 0850, 1946, 0850)						//Linha Vertical
	oPrint:say ( 1636, 0860, STR0030, oFont09 )    //"DE"           
	oPrint:line( 1628, 0950, 1946, 0950) 						//Linha Vertical
    //-------------------------------------------------------------

	oPrint:say ( 1636, 1000, " 5" , oFont08)  // Transform(5*Val(cCausa), "99")
	oPrint:line( 1628, 1200, 1946, 1200) 						//Linha Vertical
	oPrint:say ( 1636, 1210, STR0016, oFont09 )    //"ANOS" 
	oPrint:line( 1628, 1375, 1946, 1375) 						//Linha Vertical
	oPrint:say ( 1636, 1385, STR0023, oFont09 )    //"Bs"
	oPrint:line( 1628, 1500, 1787, 1500) 						//Linha Vertical

	RetHoraVal( "1274", @cHoras, @nValor, @cDesc )
	oPrint:say ( 1636, 1550, Transform(nValor, "@E 99,999,999.99"), oFont08)
	nTotD123 := nValor
	nTotBenSocial+= nValor
	oPrint:say ( 1636, 1860, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1636, 2000, Transform(nTotD123, "@E 99,999,999.99"), oFont08)

    //-------------------------------------------------------------
	oPrint:line( 1681, 0062, 1681, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1689, 0860, STR0030, oFont09 )    //"DE"
	oPrint:say ( 1689, 1000, Transform( 0 , "999"), oFont08 )   // Val(cHoras)
	oPrint:say ( 1689, 1210, STR0017, oFont09 )    //"MESES"
	oPrint:say ( 1689, 1385, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1689, 1550, Transform( 0 , "@E 99,999,999.99"), oFont08)  // nValor
    //-------------------------------------------------------------
	oPrint:line( 1734, 0062, 1734, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1742, 0860, STR0030, oFont09 )    //"DE"
	oPrint:say ( 1742, 1000, Transform( 0 , "999"), oFont08)
	oPrint:say ( 1742, 1210, STR0018, oFont09 )    //"DIAS"
	oPrint:say ( 1742, 1385, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1742, 1550, Transform( 0 , "@E 99,999,999.99"), oFont08)
    //-------------------------------------------------------------
   	oPrint:line( 1787, 0062, 1787, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1795, 0064, STR0031, oFont09 )    //"AGUINALDO DE NAVIDAD"
	oPrint:say ( 1795, 0860, STR0030, oFont09 )    //"DE"                  
	oPrint:say ( 1795, 1000, Transform( 0 , "999"), oFont08)
	oPrint:say ( 1795, 1210, STR0032, oFont09 )    //"MESES Y"                     
	oPrint:say ( 1795, 1500, Transform( 0 , "999"), oFont08)
	oPrint:line ( 1787, 1675, 1946, 1675) 						//Linha Vertical
	oPrint:say ( 1795, 1685, STR0018, oFont09 )    //"DIAS" 
	oPrint:say ( 1795, 1860, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 1795, 2000, Transform( 0 , "@E 99,999,999.99"), oFont08)
	oPrint:line( 1840, 0062, 1840, nColMax-21 ) 		   	//Linha Horizontal	
	oPrint:say ( 1848, 0064, STR0033, oFont09 )    //"VACACION"
	oPrint:say ( 1848, 0860, STR0030, oFont09 )    //"DE"     

	oPrint:say ( 1848, 1040, Transform( 0 , "999"), oFont08)

	oPrint:say ( 1848, 1210, STR0032, oFont09 )    //"MESES Y" 

	oPrint:say ( 1848, 1500, Transform( 0 , "999"), oFont08)
	oPrint:say ( 1848, 1685, STR0018, oFont09 )    //"DIAS"

	oPrint:say ( 1848, 1860, STR0023, oFont09 )    //"Bs" 
	oPrint:say ( 1848, 2000, Transform( 0 , "@E 99,999,999.99"), oFont08) 
	oPrint:line( 1893, 0062, 1893, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 1901, 0064, STR0034, oFont09 )    //"PRIMA LEGAL (SI CORRESPONDE)"
	oPrint:say ( 1901, 0860, STR0030, oFont09 )    //"DE" 
	oPrint:say ( 1901, 1040, Transform( 0 , "999"), oFont08)	 
	oPrint:say ( 1901, 1210, STR0032, oFont09 )    //"MESES Y"
	oPrint:say ( 1901, 1500, Transform( 0 , "999"), oFont08)
	oPrint:say ( 1901, 1685, STR0018, oFont09 )    //"DIAS"
	oPrint:say ( 1901, 1860, STR0023, oFont09 )    //"Bs"	
	oPrint:say ( 1901, 2000, Transform( 0 , "@E 99,999,999.99"), oFont08)

	oPrint:line( 1946, 0062, 1946, nColMax-21 ) 	//Linha Horizontal  
	oPrint:say ( 1954, 0064, STR0035, oFont09 ) 	//"OTROS"
	oPrint:line ( 1946, 0200, 1999, 0200)			//Linha Vertical
	// Multa quinquenio
    RetHoraVal( "1275", @cHoras, @nValor, @cDesc )
    nVal:=nValor
	oPrint:say ( 1954, 1860, STR0023, oFont09 )    //"Bs"	
	oPrint:say ( 1954, 2000, Transform(nVal, "@E 99,999,999.99"), ofont08)
	nTotBenSocial+= nVal
	oPrint:line( 1999, 0062, 1999, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:line ( 1999, 0370, 2052, 0370)				//Linha Vertical

	oPrint:say ( 2007, 0500, STR0036, oFont09 )    //"GESTION"
		oPrint:line ( 1999, 0750, 2052, 0750)						//Linha Vertical

		oPrint:line ( 1999, 1200, 2052, 1200) 						//Linha Vertical 
	oPrint:say ( 2007, 1210, STR0030, oFont09 )    //"DE 
		oPrint:line ( 1999, 1300, 2052, 1300) 						//Linha Vertical 

	oPrint:say ( 2007, 1450, Transform( 0 , "999"), oFont09)            
		oPrint:line ( 1999, 1675, 2052, 1675) 						//Linha Vertical
	oPrint:say ( 2007, 1685, STR0018, oFont09 )    //"DIAS"
	oPrint:say ( 2007, 1860, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 2007, 2000, Transform( 0 , "@E 99,999,999.99"), ofont08)

oPrint:line( 2057, 0062, 2057, nColMax-21 ) 		   	//Linha Horizontal 


oPrint:say ( 2074, 0068, STR0037, oFont09 )		//"IV. - TOTAL BENEFICIOS SOCIALES: C+D"
oPrint:say ( 2074, 1860, STR0023, oFont09 )    //"Bs"                
oPrint:line ( 2057, 1950, 2132, 1950) 						//Linha Vertical  
oPrint:say ( 2074, 2000, Transform(nTotBenSocial, "@E 99,999,999.99"), oFont08)
oPrint:line( 2127, 0062, 2127, nColMax-21 ) 		   	//Linha Horizontal
oPrint:line( 2132, 0062, 2132, nColMax-21 ) 		   	//Linha Horizontal 
oPrint:Box ( 2154, 0062, 2472, nColMax-21 )    			//Box  
			oPrint:line ( 2154, 0370, 2472, 0370)						//Linha Vertical
			oPrint:line ( 2154, 1050, 2472, 1050) 						//Linha Vertical
			oPrint:line ( 2154, 1200, 2472, 1200) 						//Linha Vertical
			oPrint:line ( 2154, 1675, 2472, 1675) 						//Linha Vertical 
			oPrint:line ( 2154, 1950, 2472, 1950) 						//Linha Vertical     
	oPrint:say ( 2162, 0064, STR0038, oFont09 )		//"E)DEDUCCIONES:"
	oPrint:say ( 2162, 1060, STR0023, oFont09 )    //"Bs" 
	oPrint:line( 2207, 0062, 2207, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 2215, 1060, STR0023, oFont09 )    //"Bs"
	oPrint:line( 2260, 0062, 2260, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 2268, 1060, STR0023, oFont09 )    //"Bs"
	oPrint:line( 2313, 0062, 2313, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 2321, 1060, STR0023, oFont09 )    //"Bs"
	oPrint:line( 2366, 0062, 2366, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 2374, 1060, STR0023, oFont09 )    //"Bs"
	oPrint:line( 2419, 0062, 2419, nColMax-21 ) 		   	//Linha Horizontal
	oPrint:say ( 2427, 1060, STR0023, oFont09 )    //"Bs"
	oPrint:say ( 2427, 1685, STR0039, oFont09 )    //"TOTAL Bs"          
oPrint:line( 2477, 0062, 2477, nColMax-21 ) 		   	//Linha Horizontal

oPrint:say ( 2427, 2000, Transform(nTotDeduccion, "@E 99,999,999.99"), oFont08)                                   	

oPrint:say ( 2494, 0064, STR0040, oFont09 )    //"V. IMPORTE LIQUIDO A PAGAR C+D-E="
	oPrint:line ( 2477, 1850, 2547, 1850) 						//Linha Vertical
	oPrint:line ( 2477, 1855, 2547, 1855) 						//Linha Vertical
oPrint:say ( 2494, 1865, STR0023, oFont09 )    //"Bs"
oPrint:say ( 2494, 2000, Transform(nTotBenSocial-nTotDeduccion, "@E 99,999,999.99"), oFont08)
oPrint:line( 2547, 0062, 2547, nColMax-21 ) 		   	//Linha Horizontal
oPrint:line( 2552, 0062, 2552, nColMax-21 ) 		   	//Linha Horizontal
                
	oPrint:EndPage() 
	oPrint:StartPage()
	
	oPrint:Box ( 0020, 0035, 2650, nColMax )
	oPrint:Box ( 0027, 0045, 2638, nColMax-7 )


	oPrint:say ( 0100, 0100, STR0041, oFont09 )    //"FORMA DE PAGO"
	oPrint:say ( 0100, 0400, STR0042, oFont09 )    //"EFECTIVO   (     )"
	oPrint:say ( 0100, 0800, STR0043, oFont09 )    //"CHEQUE   (     )"     

	If nPagTipo == 1
		oPrint:say ( 0100, 0660, "X", oFont09 )                         
		oPrint:say ( 0100, 1180, STR0044, oFont09 )    //"Nบ"
		oPrint:say ( 0100, 1580, STR0045, oFont09 )    //"C/BANCO"
	Else
		oPrint:say ( 0100, 1010, "X", oFont09 )                  
		oPrint:say ( 0100, 1180, STR0044+cNCheque, oFont09 )    //"Nบ"
		oPrint:say ( 0100, 1580, STR0045+" "+cNomeBanco, oFont09 )    //"C/BANCO"
	Endif
	
	oPrint:say ( 0150, 0100, STR0046, oFont09 )    //"IMPORTE DE LA SUMA CANCELADA"   
	oPrint:say ( 0195, 0100, Extenso(nTotBenSocial-nTotDeduccion,.T.,1," ","2",.T.,.T.,.F.,"3")+ "  " + STR0074, oFont08)
	oPrint:say ( 0200, 0100, "...........................................................................................................", oFont09 )    
	oPrint:say ( 0240, 0100, "...........................................................................................................", oFont09 )   
	
	oPrint:line( 0280, 0072, 0280, nColMax-36 ) 		   	//Linha Horizontal
	oPrint:line( 0285, 0072, 0285, nColMax-36 ) 		   	//Linha Horizontal 
	
	oPrint:say ( 0350, 0150, STR0047, oFont09 )    //"YO"
	oPrint:say ( 0350, 0250, (SRA->RA_NOME), oFont09 )
	oPrint:say ( 0500, 0150, STR0048, oFont09 )    //"MAYOR DE EDAD, CON C.I. Nบ" 
	oPrint:say ( 0500, 0700, (SRA->RA_CIC), oFont09 )
	oPrint:say ( 0500, 1050, STR0049, oFont09 )    //"DECLARO QUE EN LA FECHA RECIBO A MI ENTERA SATISFACCIำN EL "
	oPrint:say ( 0550, 0150, STR0050+"  "+;			//"IMPORTE DE Bs."
	Transform(nTotBenSocial-nTotDeduccion, "@E 99,999,999.99") , oFont09 )   
	oPrint:say ( 0550, 0800, STR0051, oFont09 )    //"POR CONCEPTO DE LA LIQUIDACION DE MIS BENEFICIOS SOCIALES, DE CONFORMIDAD"
	oPrint:say ( 0600, 0150, "CON LA LEY GENERAL DEL TRABAJO, SU DECRETO REGLAMENTARIO Y DISPOSICIONES CONEXAS.", oFont09 )    //STR0052"CON LA LEY GENERAL DEL TRABAJO, SU DECRETO REGLAMENTARIO Y DISPOSICIONES CONEXAS."
	
	oPrint:say ( 0750, 0100, STR0053+"   "+Trim(aInfo[5]), oFont09 )    //"LUGAR Y FECHA"
	oPrint:say ( 0750, 0800, ",", oFont09 )           
	oPrint:say ( 0750, 0850, Transform(Day(Date()),"99"), oFont09) 
	oPrint:say ( 0750, 1000, STR0030, oFont09 )    //"DE"  
	oPrint:say ( 0750, 1070, MesExtenso(Month(Date())), oFont09)
	oPrint:say ( 0750, 1500, STR0030, oFont09 )    //"DE"
	oPrint:say ( 0750, 1570, Transform(Year(Date()),"9999"), oFont09)
	
	oPrint:say ( 1000, 0100, "............................................", oFont09 )   
	oPrint:say ( 1000, 1400, "............................................", oFont09 )    
	oPrint:say ( 1050, 0400, STR0054, oFont09 )    //"INTERESADO"      
	oPrint:say ( 1050, 1650, STR0055, oFont09 )    //"GERENTE GENERAL"    
	oPrint:say ( 1250, 0100, "............................................", oFont09 )   
	oPrint:say ( 1300, 0200, STR0056, oFont09 )    //"Vo. Bo. MINISTERIO DE TRABAJO"
	oPrint:say ( 1300, 1750, STR0057, oFont09 )    //"SELLO"   
	
	oPrint:line( 1425, 0072, 1425, nColMax-36 ) 		   	//Linha Horizontal
	oPrint:line( 1430, 0072, 1430, nColMax-36 ) 		   	//Linha Horizontal 

	oPrint:say ( 1550, 1000, STR0058, oFont09 )    //"INSTRUCCIONES"
	oPrint:say ( 1650, 0350, STR0059, oFont09 )    //"1. En todos los casos en los cuales proceda el pago de benefํcios sociales y que no"
	oPrint:say ( 1700, 0350, STR0060, oFont09 )    //"est้n comprendidos en el despido por las causales en el Art. 16 de la  Ley  General"
	oPrint:say ( 1750, 0350, STR0061, oFont09 )    //"del Trabajo y el Art. 9 de su Reglamento, el Finiquito de contrato se suscribirแ en"
	oPrint:say ( 1800, 0350, STR0062, oFont09 )    //"el presente FORMULARIO."

	oPrint:say ( 1875, 0350, STR0063, oFont09 )    //"2. Los se๑ores Directores, Jefes Departamentales e Inspectores  Regionales, son los"
	oPrint:say ( 1925, 0350, STR0064, oFont09 )    //"๚nicos funcionarios facultados para revisar y refrendar todo Finiquito de  contrato"
	oPrint:say ( 1975, 0350, STR0065, oFont09 )    //"de Trabajo, concuya intervenci๓n alcanzarแ la correspondiente eficacia jurํdica, en"
	oPrint:say ( 2025, 0350, STR0066, oFont09 )    //"aplicaci๓n del Art. 22 de la Ley General del Trabajo."
	oPrint:say ( 2075, 0350, STR0067, oFont09 )    //"La  intervenci๓n  de  cualquer  otro   funcionario  del  Ministerio  de  Trabajo  y"
	oPrint:say ( 2125, 0350, STR0068, oFont09 )    //"Microempresa carecerแ de toda validez legal."

	oPrint:say ( 2200, 0350, STR0069, oFont09 )    //"3. Las  partes  intervinientes  en  la  suscripci๓n del presente FINIQUITO, deberแn"
	oPrint:say ( 2250, 0350, STR0070, oFont09 )    //"acreditar suidentidad personal con los documentos se๑alados por ley."

	oPrint:say ( 2325, 0350, STR0071, oFont09 )    //"4. Este  Formulario  no  constituye  Ley entre partes por su carแcter esencialmente"
	oPrint:say ( 2375, 0350, STR0072, oFont09 )    //"revisable, por lo tanto las cifras en el contenidas no causan estado ni revisten el" 
	oPrint:say ( 2425, 0350, STR0073, oFont09 )    //"sello de cosa juzgada"

oPrint:EndPage()

Set(5,nEpoca)
If nTdata > 8
	SET CENTURY ON
Else
	SET CENTURY OFF
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณrethoravalบAutor  ณErika Kanamori      บ Data ณ  01/16/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna hora e valor correspondente ao identificador de cal-บฑฑ
ฑฑบ          ณculo informado em cIdCalc, baseados nas informacoes em aBol.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function RetHoraVal(cIdCalc, cHoras, nValor, cDesc, cMesMed)  

Local nAux
Local lAux := .F.
/* aBol:= { [x][1]- nบ do identificador de calculo
          [x][2]- descricao
          [x][3]- horas
          [x][4]- valor }
          [x][5]- AAAAMM usado para media indeniz.}	*/

cHoras	:= " "
nValor	:= 0
cDesc 	:= ""	
cMesMed := ""

For nAux:=1 to len(aBol)
	If aBol[nAux][1] == cIdCalc                                                
		cDesc	:= aBol[nAux][2]  
		cHoras	:= aBol[nAux][3]
		nValor	:= aBol[nAux][4]
		cMesMed	:= If( ValType(aBol[nAux][5]) == "C", aBol[nAux][5] , "" ) // AAAAMM
		lAux	:= .T.
		nAux	:= len(aBol)
	Endif
Next nAux
Return lAux 
