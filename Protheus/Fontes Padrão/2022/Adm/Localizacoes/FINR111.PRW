#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFINRPER   บAutor  ณ Pedro Pereira Lima บ Data ณ  18/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FINR111()
Local aMeses := {	"01 - Enero",;
						"02 - Febrero",;
						"03 - Marzo",;
						"04 - Abril",;
						"05 - Mayo",;
						"06 - Junio",;
						"07 - Julio",;
						"08 - Agosto",;
						"09 - Setiembre",;
						"10 - Octubre",;
						"11 - Noviembre",;
						"12 - Diciembre"}
Local aParam := {}

Private oFontTop  	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Private oFontCabec	:= TFont():New("Arial",8,8,,.T.,,,,.T.,.F.)  
Private oFontCorpo	:= TFont():New("Arial",7,7,,.F.,,,,.T.,.F.)
Private oPrint

aAdd(aParam,{2,"Seleccione el mes",,aMeses,60,,.T.})
aAdd(aParam,{1,"Rellene el a๑o",Space(4),,,,,60,.T.})

If !Parambox(aParam,"Parametros")
	Return
EndIf

oPrint := TMSPrinter():New("LIBRO DE INGRESOS Y GASTOS - RENTAS DE CUARTA CATEGORอA") // Monta objeto para impressใo
oPrint:SetLandscape()                                                                 // Define orienta็ใo da pแgina
oPrint:SetPaperSize(9)																	              // A4 210 x 297 mm
oPrint:Setup() 

//Impressใo do corpo do relat๓rio com as informa็๕es conforme o filtro
RepBody()

oPrint:Preview()                                                         // Mostra tela de visualiza็ใo de impressใo

oPrint := Nil

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRepStruct บAutor  ณ Pedro Pereira Lima บ Data ณ  18/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RepStruct()
Local lin  	:= 10     // Distancia da linha vertical da margem esquerda
Local lin1 	:= 80     // Distancia da linha vertical da margem superior
Local lin2 	:= 2100   // Tamanho vertical da linha   

oPrint:StartPage() // Inicia pแgina

oPrint:Line(lin1,lin,lin1,3300)   	          	//Linha Horizontal - Inํcio do relat๓rio
oPrint:Line(lin1+1,lin,lin1+1,3300)

oPrint:Line(lin1+80,lin+590,lin1+80,lin+2290)	//Linha Horizontal - Quebra do cabe็alho
oPrint:Line(lin1+81,lin+590,lin1+81,lin+2290)                                                    

oPrint:Line(lin1+195,lin,lin1+195,3300)			//Linha Horizontal - Fim do cabe็alho
oPrint:Line(lin1+194,lin,lin1+194,3300)

oPrint:Line(lin2,lin,lin1,lin)						//1ช linha vertical
oPrint:Line(lin2,lin+1,lin1,lin+1)

oPrint:Line(lin2,lin+280,lin1,lin+280)				//2ช linha vertical
oPrint:Line(lin2,lin+279,lin1,lin+279)

oPrint:Line(lin2,lin+450,lin1,lin+450)				//3ช linha vertical
oPrint:Line(lin2,lin+449,lin1,lin+449)

oPrint:Line(lin2,lin+590,lin1,lin+590)				//4ช linha vertical
oPrint:Line(lin2,lin+589,lin1,lin+589)

oPrint:Line(lin2,lin+700,lin1+80,lin+700)	  		//5ช linha vertical
oPrint:Line(lin2,lin+699,lin1+80,lin+699)

oPrint:Line(lin2,lin+890,lin1,lin+890)				//6ช linha vertical
oPrint:Line(lin2,lin+889,lin1,lin+889)

oPrint:Line(lin2,lin+1100,lin1+80,lin+1100)		//7ช linha vertical
oPrint:Line(lin2,lin+1099,lin1+80,lin+1099)

oPrint:Line(lin2,lin+1370,lin1+80,lin+1370)		//8ช linha vertical
oPrint:Line(lin2,lin+1369,lin1+80,lin+1369)

oPrint:Line(lin2,lin+2290,lin1,lin+2290)			//9ช linha vertical
oPrint:Line(lin2,lin+2289,lin1,lin+2289)

oPrint:Line(lin2,lin+2540,lin1,lin+2540)			//10ช linha vertical
oPrint:Line(lin2,lin+2539,lin1,lin+2539)

oPrint:Line(lin2,lin+2790,lin1,lin+2790)			//11ช linha vertical
oPrint:Line(lin2,lin+2789,lin1,lin+2789)

oPrint:Line(lin2,lin+3040,lin1,lin+3040)			//12ช linha vertical
oPrint:Line(lin2,lin+3039,lin1,lin+3039)

oPrint:Line(lin2,lin+3290,lin1,lin+3290)			//13ช linha vertical
oPrint:Line(lin2,lin+3289,lin1,lin+3289)

oPrint:Line(lin2,10,lin2,3300)						//Linha Horizontal - Fim do relat๓rio
oPrint:Line(lin2-1,11,lin2-1,3299)

Return             

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RepPrint บAutor  ณ Pedro Pereira Lima บ Data ณ  19/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RepPrint()                
Local nLin  := 88
Local nCol1 := 150

oPrint:Say(nLin-50,nCol1-140 ,"PERอODO: " + AllTrim(Upper(SubStr(MV_PAR01,5,Len(MV_PAR01)))) + "/" + AllTrim(MV_PAR02),oFontTop)
oPrint:Say(nLin-83,nCol1+1000,"LIBRO DE INGRESOS Y GASTOS - RENTAS DE CUARTA CATEGORอA",oFontTop)
//1ช Coluna
oPrint:Say(nLin+10 ,nCol1,"FECHA DE COBRO,",oFontCabec,,0,,2)
oPrint:Say(nLin+40 ,nCol1,"INGRESO O",oFontCabec,,0,,2)
oPrint:Say(nLin+70 ,nCol1,"PUESTA",oFontCabec,,0,,2)
oPrint:Say(nLin+100,nCol1,"A DISPOSICIำN",oFontCabec,,0,,2)
oPrint:Say(nLin+130,nCol1,"dd/mm/aaaa",oFontCabec,,0,,2)

//2ช Coluna
oPrint:Say(nLin+40,nCol1+225,"FECHA DE",oFontCabec,,0,,2)
oPrint:Say(nLin+70,nCol1+225,"EMISIำN",oFontCabec,,0,,2)
oPrint:Say(nLin+100,nCol1+225,"dd/mm/aaaa",oFontCabec,,0,,2)

//3ช Coluna
oPrint:Say(nLin+40 ,nCol1+380,"INCISO",oFontCabec,,0,,2)
oPrint:Say(nLin+70 ,nCol1+380,"APLICA-",oFontCabec,,0,,2)
oPrint:Say(nLin+100,nCol1+380,"BLE (1)",oFontCabec,,0,,2)

//4ช Coluna
//Linha 1
oPrint:Say(nLin   ,nCol1+600,"COMPROBANTE DE",oFontCabec,,0,,2)
oPrint:Say(nLin+30,nCol1+600,"PAGO EMITIDO",oFontCabec,,0,,2)
//Linha 2
//4ช Coluna - A
oPrint:Say(nLin+120,nCol1+505,"SERIE",oFontCabec,,0,,2)
//4ช Coluna - B
oPrint:Say(nLin+120,nCol1+650,"NUMERO",oFontCabec,,0,,2)

//5ช Coluna
//Linha 1
oPrint:Say(nLin+20,nCol1+1450,"USUARIO DEL SERVICIO",oFontCabec,,0,,2)
//Linha 2
//5ช Coluna - A
oPrint:Say(nLin+90,nCol1+860,"TIPO DE",oFontCabec,,0,,2)
oPrint:Say(nLin+120,nCol1+860,"DOCUMENTO",oFontCabec,,0,,2)
oPrint:Say(nLin+150,nCol1+860,"(TABLA 2)",oFontCabec,,0,,2)
//5ช Coluna - B
oPrint:Say(nLin+90,nCol1+1090,"Nบ DE",oFontCabec,,0,,2)
oPrint:Say(nLin+120,nCol1+1090,"DOCUMENTO",oFontCabec,,0,,2)
//5ช Coluna - C
oPrint:Say(nLin+90,nCol1+1700,"APELLIDOS Y NOMBRES,",oFontCabec,,0,,2)
oPrint:Say(nLin+120,nCol1+1700,"DENOMINACIำN O RAZำN",oFontCabec,,0,,2)
oPrint:Say(nLin+150,nCol1+1700,"SOCIAL",oFontCabec,,0,,2)

//6ช Coluna
oPrint:Say(nLin+60,nCol1+2275,"RENTA",oFontCabec,,0,,2)
oPrint:Say(nLin+90,nCol1+2275,"BRUTA",oFontCabec,,0,,2)

//7ช Coluna
oPrint:Say(nLin+40 ,nCol1+2525,"IMPUESTO",oFontCabec,,0,,2)
oPrint:Say(nLin+70 ,nCol1+2525,"A LA RENTA",oFontCabec,,0,,2)
oPrint:Say(nLin+100,nCol1+2525,"RETENIDO",oFontCabec,,0,,2)

//8ช Coluna
oPrint:Say(nLin+60,nCol1+2775,"OTRAS",oFontCabec,,0,,2)
oPrint:Say(nLin+90,nCol1+2775,"RETENCIONES",oFontCabec,,0,,2)

//9ช Coluna
oPrint:Say(nLin+10 ,nCol1+3025,"MONTO",oFontCabec,,0,,2)
oPrint:Say(nLin+40 ,nCol1+3025,"COBRADO,",oFontCabec,,0,,2)
oPrint:Say(nLin+70 ,nCol1+3025,"INGRESADO O",oFontCabec,,0,,2)
oPrint:Say(nLin+100,nCol1+3025,"PUESTO A",oFontCabec,,0,,2)
oPrint:Say(nLin+130,nCol1+3025,"DISPOSICIำN",oFontCabec,,0,,2)

//Rodap้ - Inciso Aplicable
oPrint:Say(nLin+2022,nCol1+50,"(1) Inciso aplicable del Artํculo 33ฐ de la Ley del Impuesto a la Renta:",oFontCorpo,,0,,)
oPrint:Say(nLin+2052,nCol1+70,"a) El ejercicio individual, de cualquier profesi๓n, arte, ciencia, oficio o actividades no incluidas expresamente en la tercera categorํa.",oFontCorpo,,0,,)
oPrint:Say(nLin+2082,nCol1+70,"b) El desempe๑o de funciones de director de empresas, sํndico, mandatario, gestor de negocios, albacea y actividades similares.",oFontCorpo,,0,,)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RepBody  บAutor  ณ Pedro Pereira Lima บ Data ณ  24/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RepBody()
Local nLin  	:= 300
Local nCol  	:= 150 
Local nLinAt	:= 0
Local nRecs 	:= 0
Local nPage 	:= 1
Local cAliasR	:= ""
Local cAliasI	:= ""
Local cQuery	:= ""
Local nValBase	:= 0
Local nValIR	:= 0
Local nValIGV	:= 0
Local nValMt	:= 0
Local nTValBase:= 0
Local nTValIR	:= 0
Local nTValIGV	:= 0
Local nTValMt	:= 0
Local cSelect := Iif(SerieNfId("SFE",3,"FE_SERIE")<>"FE_SERIE",",FE_SDOC","")


cAliasR 	:= GetNextAlias()
cQuery 	:= "SELECT FE_ORDPAGO, E2_EMISSAO,FE_SERIE,FE_NFISCAL,FE_EMISSAO,FE_RETENC,FE_VALBASE,A2_NOME,A2_TIPDOC,A2_PFISICA,A2_INCISO"
cQuery 	+= cSelect + "FROM "+RetSqlName("SFE")+" SFE, "+RetSqlName("SA2")+" SA2, " + RetSqlName("SE2") + " SE2 "
cQuery	+= " WHERE FE_FILIAL = '"+xFilial("SFE")+"' AND " 
cQuery	+= " A2_FILIAL = '"+xFilial("SA2")+"' AND "
cQuery	+= " E2_FILIAL = '"+xFilial("SE2")+"' AND "
cQuery	+= " A2_R4ACAT = '1' AND "
cQuery	+= " A2_TIPO = '2' AND "
cQuery	+= " (A2_INCISO = '1' OR A2_INCISO = '2') AND "
cQuery   += " FE_FORNECE = A2_COD "+"AND "
cQuery  	+= " FE_LOJA = A2_LOJA "+"AND "
cQuery	+= " E2_PREFIXO = FE_SERIE AND "
cQuery	+= " E2_NUM = FE_NFISCAL AND "
cQuery	+= " E2_PARCELA = FE_PARCELA AND "
cQuery	+= " E2_TIPO = FE_ESPECIE AND "
cQuery	+= " E2_FORNECE = FE_FORNECE AND "
cQuery	+= " E2_LOJA = FE_LOJA AND "
cQuery  += " FE_TIPO = 'R' "+"AND"


If cPaisLoc $ "ARG|COS|PAR"
	cQuery  += " FE_DTESTOR = '' "+"AND" 
EndIf 
cQuery 	+= " SUBSTRING(FE_EMISSAO,5,2) = '" + SubStr(MV_PAR01,1,2) + "' AND"  
cQuery 	+= " SUBSTRING(FE_EMISSAO,1,4) = '" + Alltrim(MV_PAR02) + "' AND"  
cQuery 	+= " SFE.D_E_L_E_T_ = ' ' AND"
cQuery	+= " SE2.D_E_L_E_T_ = ' ' AND"
cQuery 	+= " SA2.D_E_L_E_T_ = ' '" 
cQuery 	+= " ORDER BY FE_EMISSAO  " 

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasR, .F., .T.)

cAliasI 	:= GetNextAlias()

DbSelectArea(cAliasR)
(cAliasR)->(dbGoTop())

RepStruct()
RepPrint()

While !(cAliasR)->(Eof())   
	nRecs++
	If nRecs == 51 //Excedeu o tamanho da pแgina
		nRecs := 1
		nLinAt:= 0
		oPrint:Say(nLin+1880,nCol+2990,"PมGINA: " + STR(nPage),oFontCorpo,,0,,2)
		nPage++
		oPrint:EndPage()
		RepStruct()
		RepPrint()		
	EndIf
	//Coluna 1
	oPrint:Say(nLin+nLinAt,nCol,DtoC(StoD((cAliasR)->FE_EMISSAO)),oFontCorpo,,0,,2)
	//Coluna 2
	oPrint:Say(nLin+nLinAt,nCol+230,DtoC(StoD((cAliasR)->E2_EMISSAO)),oFontCorpo,,0,,2)
	//Coluna 3
	oPrint:Say(nLin+nLinAt,nCol+380,IIf((cAliasR)->A2_INCISO == '1',"(a)","(b)"),oFontCorpo,,0,,2)
	//Coluna 4
	oPrint:Say(nLin+nLinAt,nCol+505,Alltrim((cAliasR)->&(SerieNfId("SFE",3,"FE_SERIE"))),oFontCorpo,,0,,2)
	//Coluna 5
	oPrint:Say(nLin+nLinAt,nCol+570,(cAliasR)->FE_NFISCAL,oFontCorpo,,0,,0)
	//Coluna 6
	oPrint:Say(nLin+nLinAt,nCol+860,(cAliasR)->A2_TIPDOC,oFontCorpo,,0,,2)
	//Coluna 7
	oPrint:Say(nLin+nLinAt,nCol+970,(cAliasR)->A2_PFISICA,oFontCorpo,,0,,0)
	//Coluna 8
	oPrint:Say(nLin+nLinAt,nCol+1250,(cAliasR)->A2_NOME,oFontCorpo,,0,,0)
	
	nValBase := (cAliasR)->FE_VALBASE
	nTValBase+= nValBase
	
	nValIR	:= (cAliasR)->FE_RETENC
	nTValIR	+= nValIR

	BeginSQL ALIAS cAliasI
		SELECT FE_RETENC IGV FROM %TABLE:SFE% SFE
		WHERE 	 FE_FILIAL = %EXP:xFilial("SFE")%
   			AND FE_ORDPAGO = %EXP:(cAliasR)->FE_ORDPAGO%
   			AND FE_NFISCAL = %EXP:(cAliasR)->FE_NFISCAL%
   			AND FE_TIPO = %EXP:'I'%
   			AND SFE.%NotDel% 	
  	EndSQL

	nValIGV	:= (cAliasI)->IGV
	nTValIGV	+= nValIGV
	
	nValMt	:= nValBase - (nValIR + nValIGV)
	nTValMt	+= nValMt
	
	//Coluna 10
	oPrint:Say(nLin+nLinAt,nCol+2390,Transform(nValBase,PesqPict("SFE","FE_VALBASE")),oFontCorpo,,0,,1)
	//Coluna 11
	oPrint:Say(nLin+nLinAt,nCol+2640,Transform(nValIR,PesqPict("SFE","FE_RETENC")),oFontCorpo,,0,,1)
	//Coluna 12
	oPrint:Say(nLin+nLinAt,nCol+2890,Transform(nValIGV,PesqPict("SFE","FE_RETENC")),oFontCorpo,,0,,1)
	//Coluna 13
	oPrint:Say(nLin+nLinAt,nCol+3140,Transform(nValMt,PesqPict("SFE","FE_VALBASE")),oFontCorpo,,0,,1)
	
	nLinAt += 35
	
	(cAliasI)->(dbCloseArea())
	
	(cAliasR)->(dbSkip())	
EndDo

(cAliasR)->(dbCloseArea())


RepTotal(nTValBase,nTValIR,nTValIGV,nTValMt)
oPrint:Say(nLin+1880,nCol+2990,"PมGINA: " + STR(nPage),oFontCorpo,,0,,2)

oPrint:EndPage()// Termina a pแgina

Return  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RepTotal บAutor  ณ Pedro Pereira Lima บ Data ณ  25/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RepTotal(nTotBase,nTotIR,nTotIGV,nTotLiq)
Local lin  	:= 10     // Distancia da linha vertical da margem esquerda
Local lin1 	:= 2100   // Distancia da linha vertical da margem superior
Local lin2 	:= 2150   // Tamanho vertical da linha  
Local nLin  := 300
Local nCol  := 150  

oPrint:Line(lin2,lin+2290,lin1,lin+2290)			//9ช linha vertical
oPrint:Line(lin2,lin+2289,lin1,lin+2289)

oPrint:Line(lin2,lin+2540,lin1,lin+2540)			//10ช linha vertical
oPrint:Line(lin2,lin+2539,lin1,lin+2539)

oPrint:Line(lin2,lin+2790,lin1,lin+2790)			//11ช linha vertical
oPrint:Line(lin2,lin+2789,lin1,lin+2789)

oPrint:Line(lin2,lin+3040,lin1,lin+3040)			//12ช linha vertical
oPrint:Line(lin2,lin+3039,lin1,lin+3039)

oPrint:Line(lin2,lin+3290,lin1,lin+3290)			//13ช linha vertical
oPrint:Line(lin2,lin+3289,lin1,lin+3289)

oPrint:Line(lin2  ,lin+2290,lin2  ,3300)	      //Linha Horizontal - Fim do relat๓rio
oPrint:Line(lin2-1,lin+2290,lin2-1,3300)

oPrint:Say(nLin+1810,nCol+2390,Transform(nTotBase,PesqPict("SFE","FE_VALBASE")),oFontCorpo,,0,,1)
oPrint:Say(nLin+1810,nCol+2640,Transform(nTotIR,PesqPict("SFE","FE_RETENC")),oFontCorpo,,0,,1)
oPrint:Say(nLin+1810,nCol+2890,Transform(nTotIGV,PesqPict("SFE","FE_RETENC")),oFontCorpo,,0,,1)
oPrint:Say(nLin+1810,nCol+3140,Transform(nTotLiq,PesqPict("SFE","FE_VALBASE")),oFontCorpo,,0,,1)

oPrint:Say(nLin+1810,nCol+2000,"TOTALES",oFontCabec,,0,,2)

Return             