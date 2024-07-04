#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "FISA809.CH"

Static oTRBpSICOL	:= Nil
Static oTRBrSICOL	:= Nil
Static aArqTrab		:= {}

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ FISA809  ³ Autor ³ Juan Roberto González    ³ Fecha ³28/08/2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripcion³ Genera Archivo de Retenciones y/o percepciones                 ³±±  
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marco A. Glz³27/03/17³  MMI-271 ³Se replica llamado (TVWLUN - V11.8), Se    ³±±
±±³            ³        ³          ³agrega funcionalidad para que se generen   ³±±
±±³            ³        ³          ³archivos de texto para Percepciones/Reten- ³±±
±±³            ³        ³          ³ciones. (ARG)                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function FISA809()

	Local aStruRETP	:= {}
	Local aStruRETR	:= {}
	Local aOrdem1	:= {}
	Local aOrdem2	:= {}

	//Estrutura para Percepciones - Informaciones para INI        
	Aadd(aStruRETP,	{"CGC"		, "C", 11, 0}) //CUIT del agente de percepción **14
	Aadd(aStruRETP,	{"NFISCAL"	, "C", 8 , 0}) //Número del comprobante **12A2_CGC
	Aadd(aStruRETP,	{"EMISSAO"	, "C", 10, 0}) //Fecha de Emisión del Comprobante
	Aadd(aStruRETP,	{"FILIAL"	, "C", 4 , 0}) //Número de Sucursal	
	Aadd(aStruRETP,	{"BASIMP"	, "N", 16, 2}) //Monto base Percepción	14,2
	Aadd(aStruRETP,	{"VALIMP"	, "N", 16, 2}) //Importe de la percepción 	**10,2
	Aadd(aStruRETP,	{"COMPROB"	, "C", 1 , 0}) //Tipo de Comprobante
	Aadd(aStruRETP,	{"SERIE"	, "C", 1 , 0}) //Letra del Comprobante **3
	
	aOrdem1 := {"CGC", "NFISCAL"}
	
	oTRBpSICOL := FWTemporaryTable():New("TRBp")
	oTRBpSICOL:SetFields(aStruRETP)
	oTRBpSICOL:AddIndex("IN1", aOrdem1)
	oTRBpSICOL:Create()

	aAdd(aArqTrab, {'oTRBpSICOL', 'TRBp'})

	//Estrutura para Retenciones - Informaciones para INI
	Aadd(aStruRETR, {"CGC"		, "C", 11, 0}) //CUIT del agente de retención **14
	Aadd(aStruRETR, {"EMISSAO"	, "C", 10, 0}) //Fecha de la retención	
	Aadd(aStruRETR, {"NROCERT"	, "C", 8 , 0}) //Número de comprobante **14
	Aadd(aStruRETR, {"VALBASE"	, "N", 16, 2}) //Monto base de la retención	
	Aadd(aStruRETR, {"RETENC"	, "N", 16, 2}) //Importe de la retención	

	aOrdem2 := {"CGC", "NROCERT"}
	
	oTRBrSICOL := FWTemporaryTable():New("TRBr")
	oTRBrSICOL:SetFields(aStruRETR)
	oTRBrSICOL:AddIndex("IN1", aOrdem2)
	oTRBrSICOL:Create()

	aAdd(aArqTrab, {'oTRBrSICOL', 'TRBr'})

	If _aTotal[7][1][2] =='1'//Retención
		FRET()
	ElseIf _aTotal[7][1][2] == '2'//Percepción
		FPER()
	EndIf	
	
Return aArqTrab

/*/
Programa: FRET
Autor: Juan Roberto González Rivas
Fecha: 22/07/2016
Descripción: Genera Archivo de Retenciones
/*/
Static Function FRET() 	
	
	Local cQueryR	:= "" 
	Local cArquivo	:= ""
	Local cChave	:= ""

	//Retencion
	//Query para Retención
	cQueryR := "SELECT SA2.A2_CGC AS CGC, SFE.FE_EMISSAO AS EMISSAO, SFE.FE_NROCERT AS NROCERT, SUM(SFE.FE_VALBASE) AS VALBASE, SUM(SFE.FE_RETENC) AS RETENC "
	cQueryR += "FROM " + RetSqlName('SA2') + "  SA2 "
	cQueryR += "INNER JOIN " + RetSqlName('SFE') + "  SFE ON SFE.FE_FORNECE = SA2.A2_COD AND SFE.FE_FILIAL = '" + xFilial('SFE') + "' " 
	cQueryR += "AND SFE.D_E_L_E_T_ = '' AND SFE.FE_LOJA = SA2.A2_LOJA "
	cQueryR += "WHERE SA2.A2_FILIAL = '" + xFilial('SA2') + "' AND SA2.D_E_L_E_T_ = '' AND SFE.FE_EST = '" + _aTotal[07][1][1] + "' AND SA2.A2_CGC <> '' "
	cQueryR += "AND SFE.FE_EMISSAO BETWEEN '" + dTOs(MV_PAR01) + "' AND '" + dTOs(MV_PAR02) + "' AND SFE.FE_TIPO = 'B' "
	cQueryR += "GROUP BY SA2.A2_CGC, SFE.FE_EMISSAO, SFE.FE_NROCERT "
	cQueryR += "ORDER BY SFE.FE_EMISSAO"

	cQueryR := ChangeQuery(cQueryR)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryR),"TraR",.T.,.F.)

	TCSetField("TraR", "EMISSAO", "D", 08, 00)
	TCSetField("TraR", "VALBASE", "N", 16, 02)
	TCSetField("TraR", "RETENC", "N", 16, 02)

	TraR->(dbGotop())

	dbSelectArea("TRBr")
	TRBr->(DbSetOrder(1))

	While TraR->(!Eof())		
		//Se crea tabla temporal para la creación del txt.
		If TRBr->(Dbseek(TraR->CGC + TraR->NROCERT))
			RecLock("TRBr",.F.) 
			TRBr->VALBASE := TRBr->VALBASE + ROUND(TraR->VALBASE,2) 
			TRBr->RETENC := TRBr->RETENC + ROUND(TraR->RETENC,2)			
		Else
			RecLock("TRBr",.T.) 
			TRBr->CGC := TraR->CGC
			TRBr->EMISSAO := DTOS(TraR->EMISSAO)
			TRBr->NROCERT := Substr(TraR->NROCERT, Len(TraR->NROCERT) - 7, Len(TraR->NROCERT)) 
			TRBr->VALBASE := TraR->VALBASE
			TRBr->RETENC := TraR->RETENC
		EndIf
		MsUnlock()
		TraR->(dbSkip())
	End

	If MsgYesNo(STR0001) //"¿Desea verificar los datos para la exportación?"
		TRelSICOL('TRBr')
	EndIf
	TraR->(dbCloseArea())
	
Return 

/*/
Programa: FRET
Autor: Juan Roberto González Rivas
Fecha: 26/07/2016
Descripción: Genera Archivo de Percepciones
/*/
Static Function FPER()
	
	Local nVal		:= 0
	Local cQueryP	:= ""
	Local aLivros	:= {}
	Local nBas		:= 0
	Local lLivros	:= .F.

	//busca numero dos livros no arquivo SFB e monta o campo de acordo com on numero do livro
	aLivros := BUSCASFB()

	If Len(aLivros) != 0
		//Query para Percepcion 
		cQueryP := "SELECT CASE WHEN SF3.F3_TIPOMOV = 'C' THEN SA2.A2_CGC WHEN SF3.F3_TIPOMOV = 'V' THEN SA1.A1_CGC END AS CGC, " 
		cQueryP += "SF3.F3_NFISCAL AS NFISCAL, SF3.F3_EMISSAO AS EMISSAO, SF3.F3_FILIAL AS FILIAL, "

		//Base impuesto
		For nBas := 1 To Len(aLivros)
			If nBas < Len(aLivros)
				cQueryP += "SF3.F3_BASIMP" + aLivros[nBas] + " + "
			Else	
				cQueryP += "SF3.F3_BASIMP" + aLivros[nBas] + " "
			EndIf
		Next
		cQueryP += "AS BASIMP, "	

		//Total monto retenido 		
		For nVal := 1 To Len(aLivros)
			If nVal < Len(aLivros)  
				cQueryP += "SF3.F3_VALIMP" + aLivros[nVal] + " + "
			Else
				cQueryP += "SF3.F3_VALIMP" + aLivros[nVal] + " "
			EndIf		
		Next
		cQueryP += "AS VALIMP, "

		cQueryP += "CASE WHEN SF3.F3_ESPECIE = 'NF' THEN 'F' WHEN SF3.F3_ESPECIE IN ('NCP','NCE') THEN 'C' WHEN SF3.F3_ESPECIE IN ('NDE','NDP') THEN 'D' END AS COMPROB, SF3.F3_SERIE AS SERIE "		
		cQueryP += "FROM " + RetSqlName('SF3') + " AS SF3 "
		cQueryP += "LEFT JOIN " + RetSqlName('SA1') + " AS SA1 "
		cQueryP += "ON SF3.F3_CLIEFOR = SA1.A1_COD AND SF3.F3_LOJA = SA1.A1_LOJA AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' AND SA1.D_E_L_E_T_ = '' AND SA1.A1_CGC != '' "
		cQueryP += "LEFT JOIN " + RetSqlName('SA2') + " AS SA2 "
		cQueryP += "ON SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SA2.A2_FILIAL = '" + xFilial('SA2') + "' AND SA2.D_E_L_E_T_ = '' AND SA2.A2_CGC != ''"
		cQueryP += "WHERE SF3.F3_FILIAL = '" + xFilial('SF3') + "' AND SF3.D_E_L_E_T_ = '' AND SF3.F3_ESTADO = '" + _aTotal[07][1][1] + "' "
		cQueryP += "AND SF3.F3_EMISSAO BETWEEN '" + dTOs(MV_PAR01) + "' AND '" + dTOs(MV_PAR02) + "' "
		For nVal := 1 To Len(aLivros)		
			cQueryP += "AND SF3.F3_BASIMP" + aLivros[nVal] + " != 0 "
		Next
		cQueryP += "ORDER BY SF3.F3_EMISSAO"

		cQueryP := ChangeQuery(cQueryP)	

		dbUseArea(.T., "TOPCONN", TcGenQry( , , cQueryP), "TraP", .T., .F.)

		TCSetField("TraP", "EMISSAO"	, "D", 08, 00)
		TCSetField("TraP", "BASIMP"	 	, "N", 16, 02)		
		TCSetField("TraP", "VALIMP"		, "N", 16, 02)

		TraP->(dbGotop())

		While TraP->(!Eof())
			dbSelectArea("TRBp")

			If (TraP->BASIMP > 0) 
				If RecLock("TRBp",.T.)
					TRBp->CGC := TraP->CGC
					TRBp->NFISCAL	:= Substr(TraP->NFISCAL, Len(TraP->NFISCAL) - 7, Len(TraP->NFISCAL))  
					TRBp->EMISSAO	:= DTOS(TraP->EMISSAO)
					TRBp->FILIAL	:= TraP->FILIAL
					TRBp->BASIMP	:= TraP->BASIMP
					TRBp->VALIMP	:= TraP->VALIMP
					TRBp->COMPROB	:= TraP->COMPROB
					TRBp->SERIE		:= TraP->SERIE
				EndIf
			EndIf

			MsUnlock()
			TraP->(dbSkip())
		End

		If MsgYesNo(STR0001) //"¿Desea verificar los datos para la exportación?"
			TRelSICOL('TRBp')
		EndIf
	EndIf
	
Return

/*/
Programa: BuscaSFB
Autor: Juan Roberto González Rivas
Fecha: 26/07/2016
Descripción: Busca los número de los libros para F3_VALIMP y F3_BASIMP.
/*/
Static Function BuscaSFB()
	
	Local cQuery := "" 
	Local aLivro := {}

	cQuery := "SELECT FB_CPOLVRO LIVRO"
	cQuery += " FROM "+RetSqlName('SFB')+" SFB"
	cQuery += " WHERE FB_CLASSE = 'P'"
	cQuery += " AND SFB.D_E_L_E_T_ = ''	
	cQuery += " AND SFB.FB_FILIAL = '"+xFilial('SFB')+"'"	
	cQuery += " AND SFB.FB_CLASSIF = '1'"
	cQuery += " AND SFB.FB_ESTADO = '" + _aTotal[07][1][1] + "'"

	cQuery := ChangeQuery(cQuery)		

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRA",.T.,.F.)

	While TRA->(!Eof())
		aAdd(aLivro,TRA->LIVRO)
		TRA->(dbSkip())
	EndDo
	
Return aLivro

/*/
Programa: TRelSICOL
Autor: Juan Roberto González Rivas
Fecha: 26/07/2016
Descripción: Relación para exportar el archivo txt SICOL
/*/
Function TRelSICOL(cArq)
	
	Local olReport
	Private cArqTrab := cArq

	If TRepInUse()
		olReport := ReportDef()
		olReport:PrintDialog()
	EndIf

Return Nil

/*/
Programa: ReportDef
Autor: Juan Roberto González Rivas
Fecha: 26/07/2016
Descripción: 	Definición de la relación.
/*/
Static Function ReportDef()
	
	Local olReport
	Local oSection

	If cArqTrab == 'TRBp'
		olReport := TReport():New("SicolPercepcionesTxt",STR0002,,{|olReport| PrintReport(olReport)},STR0003) // "Datos para exportación" - "Conferencia de los datos de Percepciones para exportación txt"
		oSection := TRSection():new(olReport,"Percepciones",{cArqTrab})
		olReport:SetLandScape(.T.)

		TRCell():New(oSection,"CGC",,,"@E!",11)
		TRCell():New(oSection,"NFISCAL",,,"@E!",08)
		TRCell():New(oSection,"EMISSAO",,,"@E!",10)
		TRCell():New(oSection,"FILIAL",,,"@E!",04)
		TRCell():New(oSection,"BASIMP",,,"@E 9,999,999,999.99",16)
		TRCell():New(oSection,"VALIMP",,,"@E 9,999,999,999.99",16)
		TRCell():New(oSection,"COMPROB",,,,01)
		TRCell():New(oSection,"SERIE",,,,01)
	Else
		olReport := TReport():New("SicolRetencionesTxt",STR0002,,{|olReport| PrintReport(olReport)},STR0004) // "Datos para exportación" - "Conferencia de los datos de Retenciones para exportación txt"
		oSection := TRSection():new(olReport,"Retenciones",{cArqTrab})
		olReport:SetLandScape(.T.)

		TRCell():New(oSection,"CGC",,,"@E!",11)
		TRCell():New(oSection,"EMISSAO",,,"@E!",10)
		TRCell():New(oSection,"NROCERT",,,"@E!",08)
		TRCell():New(oSection,"VALBASE",,,"@E 9,999,999,999.99",16)
		TRCell():New(oSection,"RETENC",,,"@E 9,999,999,999.99",16)
	EndIf
	
Return olReport

/*/
Programa: PrintReport
Autor: Juan Roberto González Rivas
Fecha: 26/07/2016
Descripción: Impresión de la relación.
/*/
Static Function PrintReport(olReport)
	
	Local olSection := olReport:Section(1)

	If cArqTrab == 'TRBp'
		olReport:Section(1):Cell("CGC"):SetBlock({||TRBp->CGC})	
		olReport:Section(1):Cell("NFISCAL"):SetBlock({||TRBp->NFISCAL})	
		olReport:Section(1):Cell("EMISSAO"):SetBlock({||TRBp->EMISSAO})	
		olReport:Section(1):Cell("FILIAL"):SetBlock({||TRBp->FILIAL})	
		olReport:Section(1):Cell("BASIMP"):SetBlock({||TRBp->BASIMP})	
		olReport:Section(1):Cell("VALIMP"):SetBlock({||TRBp->VALIMP})	
		olReport:Section(1):Cell("COMPROB"):SetBlock({||TRBp->COMPROB})	
		olReport:Section(1):Cell("SERIE"):SetBlock({||TRBp->SERIE})	
	Else
		olReport:Section(1):Cell("CGC"):SetBlock({||TRBr->CGC})		
		olReport:Section(1):Cell("EMISSAO"):SetBlock({||TRBr->EMISSAO})	
		olReport:Section(1):Cell("NROCERT"):SetBlock({||TRBr->NROCERT})	
		olReport:Section(1):Cell("VALBASE"):SetBlock({||TRBr->VALBASE})	
		olReport:Section(1):Cell("RETENC"):SetBlock({||TRBr->RETENC})	
	EndIf
	olSection:Print()

Return Nil

/*/
Programa: DelSICOL
Autor: Juan Roberto González Rivas
Fecha: 26/07/2016
Descripción: Excluye el archivo temporario procesado
/*/
Function DelSICOL(aArqTrab)
	
	Local nArq:= 0

	For nArq := 1 To Len(aArqTrab)
		If &(aArqTrab[nArq, 1]) <> Nil
			&(aArqTrab[nArq, 1]):Delete()
			&(aArqTrab[nArq, 1]) := Nil
		EndIf
	Next
	
Return Nil