#include "protheus.ch"
#include "TopConn.ch"
#include "Matr992.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³MatR992 ¦ Autor ¦ Rafael de Paula Goncalves¦ Data ¦ 15.12.09     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Programa que Imprime certificado de rentencao de fonte por renda.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametros³alDados: Recebe os dados dos fornecedores da rotina FISA015, de  ³±±
±±³			 ³acordo com os parametros preenchido pelo usuario.				   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³FISA015(Colombia)											       ³±±
±±³          ³                   							                   ³±± 
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina³13/03/13³TFVWHC³ Se agrego leyenda en el pie del certificado.  ³±±
±±³Antonio Trejo ³03/07/13³THE177³ Se anexo la inclusión de los datos del      ³±±
±±³ 							   proveedor en el caso de personas físicas.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³27/05/16³TUMAXX³ se quita la impresion de No. Factura en       ³±±
±±³            ³        ³      ³ PrintReport                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³15/06/16³TUMAXX³ en PrintReport se asigna el número de         ³±±
±±³            ³        ³      ³ Certificado en el encabezado del informe COL  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³15/07/16³TVPSL8³ se quita la impresion de Periodo  en          ³±±
±±³            ³        ³      ³ PrintReport  COLOMBIA                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÄÄÃÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³26/09/16³TVUOWT³ en Func PrintReport se agrega validacion si   ³±±
±±³            ³        ³      ³ A2_PFISICA es vacio toma A2_CGC NIT Retenido  ³±±
±±³LuisEnríquezº07/11/18ºDMINA-º Se agrega llamado a función FLgEmp() p/ impre-º±±
±±³            º        º4393  º sión de logotipo de empresa (COL)             º±±
±±³Andres S.   º25/09/19ºDMINA-º Se realiza actualización de strings para la   º±±
±±³Eduardo P.  º        º7399  º impresion (COL)                               º±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function MatR992(alDados)

	Local olReport	:= NIL
	
	If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
		olReport := GeraReport(alDados)
		olReport:PrintDialog()
	Endif

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GeraReport ¦ Autor ¦ Rafael de Paula Goncalves¦ Data ¦ 15.12.09	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera o objeto olReport, retornando objeto olReport.             	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³alDados: Recebe os dados dos fornecedores da rotina FISA015, de	³±±
±±³			 ³acordo com os parametros preenchido pelo usuario.				 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Chamado na funcao MatR992.	    							   	³±±
±±³          ³								                                   	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraReport(alDados)

	Local olReport	:= TReport():New("Matr992",,,{|olReport|PrintReport(olReport,alDados)},"")
	olReport:LHEADERVISIBLE		:= .F. 	// Nao imprime cabecalho do protheus
	olReport:LFOOTERVISIBLE  	:= .F.	// Nao imprime rodape do protheus
	olReport:LPARAMPAGE			:= .F.	// Nao imprime pagina de parametros
	olReport:oPage:NPAPERSIZE	:= 9 	// Impressao em papel A4 
		
Return olReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PrintReport ¦ Autor ¦ Rafael de Paula Goncalves¦ Data ¦ 15.12.09	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao do certificado de retencao na fonte.		   			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametros³olReport: Recebe o objeto gerado na funcao GeraReport.		 	³±±
±±³			 ³alDados : Recebe os dados dos fornecedores da rotina FISA015, de	³±±
±±³			 ³acordo com os parametros preenchido pelo usuario.				 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Chamado na funcao GeraReport. 		 						  	³±±
±±³          ³								                                   	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PrintReport(olReport,alDados)
    
    Local clData	:= ""
    Local nlLin		:= 0
    Local nlI		:= 0
    Local nlX		:= 0
    Local olFontN 	:= TFont():New("Courier New",,-16,,.T.)
    Local olFontI 	:= TFont():New("Courier New",,-14,,,,,,,,.T.)
    Local olFont 	:= TFont():New("Courier New",,-12,,)
    Local olFont10 	:= TFont():New("Courier New",,-10,,)
    Local olFont9 	:= TFont():New("Courier New",,-9,,)
    Local nlChave	:= TamSx3("X5_CHAVE")[1]
	Local nlForn	:= TamSx3("F3_CLIEFOR")[1]
	Local nlLoja	:= TamSx3("F3_LOJA")[1]
	Local nlNota	:= TamSx3("F3_NFISCAL")[1]
	Local nlSerie	:= TamSx3("F3_SERIE")[1]
	Local clForn	:= ""
	Local clLoja	:= ""
	Local nlPags	:= 1
    Local nlCont	:= 0
    Local alFornPag	:= {}
	Local nlPos		:= 0
	Local clNomRet	:= ""
	Local nColMax	:= 2390
	Local cNitCC	:= ""
	Local cPicNit	:= ""
	Local cPicNitAg	:= GetSx3Cache( "A2_CGC" , "X3_PICTURE" )
	Local dDtAnoFis	:= dDataBase
    Local aDatosEmp := {}
    Local aFieldSM0 := {}
	Local cFilSx5 := xFilial("SX5")
	Local cDscDpto := ""

	For nlI	:= 1 to Len(alDados)
	    	    	    
		clData	:= SubStr(DtoS(dDataBase),7,2)+"."+SubStr(DtoS(dDataBase),5,2)+"."+SubStr(DtoS(dDataBase),1,4)
		olReport:SayBitmap(olReport:Row()+50,olReport:Col()+1050,FLgEmp(),330,170)
		olReport:Box(0300,0050,3050,nColMax)
		
		If cPaisLoc == 'COL'
			olReport:Say(0250,1790, STR0019 + alDados[nlI][1],olFont,10,,) //"CERTIFICADO No.:"
		EndIf
		//Fecha de Expedición 
		olReport:Say(0350,1790,STR0002,olFont,10,,) // "Fecha de Expedición"
		
		//DIA MES AÑO
		olReport:Say(0430,1890,STR0003,olFont,10,,) // "DIA MES AÑO"
		olReport:Say(0480,1910,clData ,olFont,10,,)
		 
		//CERTIFICADO DE RETENCIÓN EN LA FUENTE POR RENTA	
		olReport:Say(0550,0300,MemoLine(STR0001,37,1,2,.T.),olFontN,10,,) // "CERTIFICADO DE RETENCIÓN EN LA FUENTE POR RENTA"
	    olReport:Say(0610,0680,MemoLine(STR0001,37,2,2,.T.),olFontN,10,,) // "CERTIFICADO DE RETENCIÓN EN LA FUENTE POR RENTA"
	    olReport:Line(0300,1600,1000,1600)
	    olReport:Line(0700,1600,0700,nColMax)
	    
	    If cPaisLoc=="COL"  
	    	aAreaAt:=GetArea()
	    	aAreaSF3:=SF3->(GetArea())
	    	DbSelectArea("SF3")
	    	DbSetOrder(4)
	    	DbSeek(xFilial("SF3")+PadR(alDados[nlI,3],nlForn)+PadR(alDados[nlI,4],nlLoja)+PadR(alDados[nlI,6],nlNota)+PadR(alDados[nlI,7],nlSerie))
	    	dDtAnoFis:= SF3->F3_ENTRADA
	    	SF3->(RestArea(aAreaSF3))
	    	RestArea(aAreaAt)
	    EndIf
	    
	    //AÑO FISCAL
	    olReport:Say(0750,1880,STR0004 						 	,olFontN,10,,) // "AÑO FISCAL"
	    olReport:Say(0850,1950,Alltrim(Str(Year(dDtAnoFis)))	,olFontN,10,,)
	    olReport:Line(1000,0050,1000,nColMax)

        //Se configurar los campos a retornar
		aFieldSM0 := {"M0_CIDENT", "M0_NOMECOM",  "M0_CGC", "M0_ENDENT", "M0_ESTENT"}
			
		aDatosEmp	:= FWSM0Util():GetSM0Data(cEmpAnt, cFilAnt, aFieldSM0)

        /* Retorna array "aDatosEmp" con la siguiente estructura:
        * aDatosEmp[1]		:= M0_CIDENT
        * aDatosEmp[1][2]	:= Contenido
        * aDatosEmp[2]		:= M0_NOMECOM
        * aDatosEmp[2][2]	:= Contenido
        * aDatosEmp[3]		:= M0_CGC
        * aDatosEmp[3][2]	:= Contenido
        * aDatosEmp[4]		:= M0_ENDENT
        * aDatosEmp[4][2]	:= Contenido
        * aDatosEmp[5]		:= M0_ESTENT
        * aDatosEmp[5][2]	:= Contenido
        */                  	

	    //Ciudad donde se consigna la retención
	    olReport:Say(1030,0080,STR0005 						  	,olFontI,10,,) // "Ciudad donde se consigna la retención"
	    olReport:Say(1100,0120,Alltrim(aDatosEmp[1][2])			,olFont,10,,)
	    olReport:Line(1170,0050,1170,nColMax)
		olReport:Line(1170,1930,1680,1930)
		
	    //Nombre o razón socíal a quien se el practica la retención 
	    olReport:Say(1200,0080,STR0006 						 	,olFontI,10,,) // "Nombre o razón socíal a quien se el practica la retención"
	    //C.C o NIT
	    olReport:Say(1200,1960,STR0007				 			,olFontI,10,,) // "C.C o NIT"
	    
	    DbSelectArea("SA2")
	    if DbSeek(xFilial("SA2")+PadR(alDados[nlI,3],nlForn)+PadR(alDados[nlI,4],nlLoja))
	    	
			//If SA2->A2_PESSOA == "F"
			IF !Empty(SA2->A2_PFISICA)
	    		If AllTrim(SA2->A2_NOMEMAT + SA2->A2_NOMEPAT) <> ""
	    			clNomRet := RTRIM(SA2->A2_NOMEPRI) + RTRIM(" "+SA2->A2_NOMEPES) + RTRIM(" "+SA2->A2_NOMEMAT) + RTRIM(" "+SA2->A2_NOMEPAT)
	    		Else
	    			clNomRet := Alltrim(SA2->A2_NOME)
	    		EndIf
	   			cNitCC 	:= SA2->A2_PFISICA
	    		cPicNit	:= GetSx3Cache( "A2_PFISICA" , "X3_PICTURE" )
			Else
	   			clNomRet := RTRIM(SA2->A2_NOME)
	   			cNitCC 	:= SA2->A2_CGC
	    		cPicNit	:= GetSx3Cache( "A2_CGC" , "X3_PICTURE" )
	    	EndIf
	    	

	    	olReport:Say(1270,0120,clNomRet					,olFont ,10,,)
			olReport:Say(1270,1960,Transf(cNitCC,cPicNit)	,olFont ,10,,)
		Endif
	    
	    olReport:Line(1340,0050,1340,nColMax)
     
	    // Razón social completa o Nombres del Agente retenedor
	    olReport:Say(1370,0080,STR0008				 	,olFontI,10,,) // "Razón social completa o Nombres del Agente retenedor"
	    olReport:Say(1440,0120,Alltrim(aDatosEmp[2][2]),olFont ,10,,)
	    olReport:Line(1510,0050,1510,nColMax)
	    
	    //C.C o NIT
	    olReport:Say(1370,1960,STR0007				 	,olFontI,10,,) // "C.C o NIT"
	    olReport:Say(1440,1960,If(cPaisLoc =='COL',aDatosEmp[3][2], Transf(Alltrim(aDatosEmp[3][2]),cPicNitAg))	,olFont ,10,,)   
	    
	    //Dirección del Agente Retenedor
	    olReport:Say(1540,0080,STR0009				 	,olFontI,10,,) // "Dirección del Agente Retenedor"
	    olReport:Say(1610,0120,Alltrim(aDatosEmp[4][2])	,olFont ,10,,)
	    olReport:Line(1680,0050,1680,nColMax)
	    
	    //Municipio
	    olReport:Say(1540,1500,STR0010				 	,olFontI,10,,) // "Municipio"
	    olReport:Say(1610,1500,Alltrim(aDatosEmp[1][2])	,olFont ,10,,)
   		olReport:Line(1510,1470,1680,1470)
	    
	    //Departamento
	    olReport:Say(1540,1960,STR0011				 			,olFontI,10,,) // "Departamento"
		IF cPaisLoc =='COL'
			//Busca código de departamento (aDatosEmp[5][2]) en tabla 12 para obtener su descripción.
			DbSelectArea("SX5")
			SX5->(DbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
				If SX5->(MsSeek(cFilSx5+"12"+AllTrim(aDatosEmp[5][2])))
					cDscDpto := Alltrim((X5Descri()))
				EndIf
		ENDIF
		olReport:Say(1610,1960,IiF(cPaisLoc =='COL',cDscDpto,Alltrim(aDatosEmp[5][2])) ,olFont ,10,,)

	    //Concepto
	    olReport:Say(1710,0080,STR0012				 			,olFontI,10,,) // "Concepto"
	    olReport:Line(1680,1130,2700,1130)
	    
	    IF cPaisLoc !='COL'
		    //No. Factura
		    olReport:Say(1710,1150,STR0013				 			,olFontI,10,,) // "No. Factura"
		    olReport:Line(1680,1470,2700,1470)
		    
		    //Período
		    olReport:Say(1710,1480,STR0014				 			,olFontI,10,,) // "Período"
		    olReport:Line(1680,1700,2700,1700)
	    ENDIF
	    //Monto Total
	    If cPaisLoc == "COL"
		    olReport:Say(1710,1400,MemoLine(STR0020,19,1,1,.F.)		,olFontI,10,,) //"Monto total sujeto a retención"
		    olReport:Say(1750,1400,MemoLine(STR0020,19,2,1,.F.)		,olFontI,10,,) //"Monto total sujeto a retención"
		Else
			olReport:Say(1710,1790,MemoLine(STR0015,5,1,2,.T.)		,olFontI,10,,) //"Valor total"
			olReport:Say(1750,1790,MemoLine(STR0015,5,2,2,.T.)		,olFontI,10,,) //"Valor total"
		EndIf
	    olReport:Line(1680,2050,2700,2050)
	    
	    //Valor Retención
	    If cPaisLoc == "COL"
	    	olReport:Say(1710,2120,MemoLine(STR0021,8,1,2,.T.)		,olFontI,10,,) //"Valor retenido"
	    	olReport:Say(1750,2100,MemoLine(STR0021,8,2,2,.T.)		,olFontI,10,,) //"Valor retenido"
		Else
			olReport:Say(1710,2120,MemoLine(STR0016,5,1,2,.T.)		,olFontI,10,,) //"Valor de la retención"
			olReport:Say(1750,2100,MemoLine(STR0016,9,2,2,.T.)		,olFontI,10,,) //"Valor de la retención"
		EndIf
		
		olReport:Line(1820,0050,1820,nColMax)
		nlLin	:= 1830           
		clForn	:= alDados[nlI,3]
		clLoja	:= alDados[nlI,4]

		DbSelectArea("SF3")
		DbSetOrder(4)
		//Impressao dos dados do mesmo fornecedor
		While alDados[nlI,3] == clForn .and. clLoja	 == alDados[nlI,4]	        
	        
			If nlLin <= 2630
				if DbSeek(xFilial("SF3")+PadR(alDados[nlI,3],nlForn)+PadR(alDados[nlI,4],nlLoja)+PadR(alDados[nlI,6],nlNota)+PadR(alDados[nlI,7],nlSerie))
					clData	:= SubStr(DtoS(SF3->F3_ENTRADA),5,2)+"/"+SubStr(DtoS(SF3->F3_ENTRADA),1,4)
					Iif(cPaisLoc !='COL',olReport:Say(nlLin,1480,clData,olFont10,10,,),)
					olReport:Say(nlLin,0060,fDesc("SX5","13"+PadR(alDados[nlI][14],nlChave),"X5DESCRI()"),olFont9,10,,) // alDados[nlI,13]
					
				EndIf
				Iif(cPaisLoc !='COL',olReport:Say(nlLin,1135,alDados[nlI,6],olFont10,10,,),)
				olReport:Say(nlLin,1730,Transform(alDados[nlI,8] ,"@E 999,999,999,999.99") 	,olFont10,10,,) // V.Base
				olReport:Say(nlLin,2080,Transform(alDados[nlI,12],"@E 999,999,999,999.99") 	,olFont10,10,,) // V.Ret.
				nlLin	+= 50
				nlX++	//Conta quantas faturas foram impressas por pagina.								
			EndIf
			nlI++
			nlCont++  //Conta quantas faturas o mesmo fornecedor tem.       
	        if nlI > Len(alDados)
	        	Exit
	        Endif
 
		EndDo

		olReport:Line(2700,0050,2700,nColMax)
		
		//Leyenda
		If cPaisLoc == "COL"
		    olReport:Say(2720,0080,MemoLine(STR0022+STR0023+STR0024,89,1,2,.T.)	,olFontI,10,,) //"Este documento no requiere ..." ## " Decreto 836 de 1991, recopilado en el artículo..." ## " que regula el contenido del certificado ..."
		    olReport:Say(2770,0080,MemoLine(STR0022+STR0023+STR0024,89,2,2,.T.)	,olFontI,10,,) //"Este documento no requiere ..." ## " Decreto 836 de 1991, recopilado en el artículo..." ## " que regula el contenido del certificado ..."
		    olReport:Say(2820,0080,MemoLine(STR0022+STR0023+STR0024,89,3,2,.T.)	,olFontI,10,,) //"Este documento no requiere ..." ## " Decreto 836 de 1991, recopilado en el artículo..." ## " que regula el contenido del certificado ..."
		    
		    olReport:Say(2920,0080,STR0025	,olFontI,10,,) //"Se expide este certificado para dar cumplimiento a lo Dispuesto en el artículo 381"
		    olReport:Say(2970,0080,STR0026	,olFontI,10,,) //" del Estatuto Tributario."
	    Else
	    	olReport:Say(2720,0080,MemoLine(STR0017+STR0018,73,1,2,.T.)	,olFontI,10,,) //"Certificado de retención en la fuente ..." ## "firma legalizada ( Art.10 D.R. 836/91)."
	    	olReport:Say(2800,0080,MemoLine(STR0017+STR0018,73,2,2,.T.)	,olFontI,10,,) //"Certificado de retención en la fuente ..." ## "firma legalizada ( Art.10 D.R. 836/91)."
	    EndIf
	    
		
        nlI		:= nlX  //Volta para a ultima fatura impressa.        
	
		nlPos	:= aScan(alFornPag,{|aX| aX[1] == clForn .and. aX[2] == clLoja})
		If nlPos == 0			
			nlPags	:= Int(nlCont/17)
			If nlPags == 0
				nlPags	:= 1			
			ElseIf nlCont%17 > 0
				nlPags++
			EndIf

			aAdd(alFornPag,{clForn,clLoja,1,nlPags})
					
		Else			
			alFornPag[nlPos,3]++
		Endif
		nlCont	:= 0

	    DbSelectArea("SFB")
	    DbSetOrder(1)
	    if DbSeek(xFilial("SFB")+"RF0")
	    	olReport:Say(2760,0110,MemoLine(SFB->FB_CERTIF,16,1,3,.T.),olFont,10,,)
	    	olReport:Say(2860,0110,MemoLine(SFB->FB_CERTIF,17,2,3,.T.),olFont,10,,)
		    olReport:Say(2960,0110,MemoLine(SFB->FB_CERTIF,38,3,3,.T.),olFont,10,,)
	    Endif
	    
	    nlPos	:= aScan(alFornPag,{|aX| aX[1] == clForn .and. aX[2] == clLoja})
		If nlPos > 0
	    	olReport:Say(3000,2170,Alltrim(Str(alFornPag[nlPos,3]))+" / "+Alltrim(Str(alFornPag[nlPos,4])),olFont,10,,)
		Endif
		
	    olReport:EndPage()
	  
	Next nlI
Return
