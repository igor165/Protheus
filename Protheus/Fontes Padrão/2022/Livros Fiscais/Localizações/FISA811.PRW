#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Fisa811.ch"
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³FISA811   ³ Autor ³Juan Roberto González  ³ Data ³16.11.2016³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Aplicativo - Entre Rios - DRG 66-13 - SIAGER.               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Arreglo con los datos solicitados.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³N/A                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function FISA811()
    
	Local 	aStruRETP := {}
	Local 	aStruRETR := {}	
	Local nProcFil := 0
	Local cBkpFil := ""
	Local cCuitFil := ""
	Local lFistCuit := .F.
	
	Private cArqTrabP := ""
	Private cArqTrabR := ""		
	Private aArqTrab := {}
	private oTmpTable
	Private cManejador := Upper(TCGetDB())
	Private lMsfil			:= .F.
	
	//Estrutura para Retenciones - Informaciones para INI
	Aadd(aStruRETR, {"TIPO", "N", 1, 0}) //Tipo de Agente
	Aadd(aStruRETR, {"MOV", "C", 2, 0}) //Motivo Movimiento
	Aadd(aStruRETR, {"CGC", "C", 14, 0}) //CUIT del Proveedor
	Aadd(aStruRETR, {"NROCERT", "C", 12, 0}) //Número de Constancia
	Aadd(aStruRETR, {"EMISSAORET", "C", 10, 0}) //Fecha de la Retención
	Aadd(aStruRETR, {"EMISSAOCOM", "C", 10, 0}) //Fecha del Comprobante
	Aadd(aStruRETR, {"TIPOCOMP", "C", 6, 0}) //Tipo de Comprobante
	Aadd(aStruRETR, {"LETRACOMP", "C", 1, 0}) //Letra Comprobante
	Aadd(aStruRETR, {"NUMCOMP", "C", 12, 0}) //Número comprobante
	Aadd(aStruRETR, {"BASIMP", "N", 15, 2}) //Importe Base
	Aadd(aStruRETR, {"ALQ", "N", 6, 2}) //Alícuota
	Aadd(aStruRETR, {"RETIMP", "N", 15, 2}) //Importe Retenido
	Aadd(aStruRETR, {"ANUL", "N", 1, 0}) //Anulación
	Aadd(aStruRETR, {"CM", "N", 1, 0}) //Contribuyente Conv. Multilat.
	
	cTemp:= "TRBr"
	oTmpTable:= FWTemporaryTable():New(cTemp) 
	oTmpTable:SetFields( aStruRETR ) 
	oTmpTable:AddIndex("1", {'TIPO'})
	//Creacion de la tabla
	oTmpTable:Create()
	
	//Estrutura para Percepciones - Informaciones para INI
	Aadd(aStruRETP, {"TIPO", "N", 1, 0}) //Tipo de Agente
	Aadd(aStruRETP, {"MOV", "C", 2, 0}) //Motivo Movimiento
	Aadd(aStruRETP, {"CGC", "C", 14, 0}) //CUIT del Cliente/Proveedor
	Aadd(aStruRETP, {"EMISSAOPER", "C", 10, 0}) //Fecha de la Percepción
	Aadd(aStruRETP, {"TIPOCOMP", "C", 6, 0}) //Tipo de Comprobante
	Aadd(aStruRETP, {"LETRACOMP", "C", 1, 0}) //Letra Comprobante
	Aadd(aStruRETP, {"NUMCOMP", "C", 12, 0}) //Número comprobante
	Aadd(aStruRETP, {"BASIMP", "N", 15, 2}) //Importe Base
	Aadd(aStruRETP, {"ALQ", "N", 6, 2}) //Alícuota
	Aadd(aStruRETP, {"PERIMP", "N", 15, 2}) //Importe Percibido
	Aadd(aStruRETP, {"ANUL", "N", 1, 0}) //Anulación
	Aadd(aStruRETP, {"CM", "N", 1, 0}) //Contribuyente Conv. Multilat.
	
	cTemp:= "TRBp"
	oTmpTable:= FWTemporaryTable():New(cTemp) 
	oTmpTable:SetFields( aStruRETP ) 
	oTmpTable:AddIndex("1", {'TIPO'})
	//Creacion de la tabla
	oTmpTable:Create()
	
	cBkpFil := cFilAnt
	
	If Substr(_aTotal[07][1][5],1,1) == "1"   
		For nProcFil := 1 To Len(aFilsCalc)
			If aFilsCalc[nProcFil,1]
				If !lFistCuit
					cCuitFil := aFilsCalc[nProcFil,4]
					lFistCuit := .T.
				EndIf
				If cCuitFil == aFilsCalc[nProcFil,4]
					cFilAnt := aFilsCalc[nProcFil,2] // cFilAnt es la variable global que indica en que sucursal estamos trabajando
					FRET()
					FPER()
					aFilsCalc[nProcFil,1] := .F.
				EndIf
			Endif
		Next nProcFil
	Else
		FRET()
		FPER()
	EndIf
	
	TRelSIAGER('TRBr')
	TRelSIAGER('TRBp')
	
	cFilAnt := cBkpFil
	
Return aArqTrab

/*/
Programa: FRET
Autor: Juan Roberto González Rivas
Fecha: 16/11/2016
Descripción: Genera Archivo de Retenciones
/*/
Static Function FRET() 	
	Local cQueryR := ""
	Local cTabEqui := ""
	Local nSFHVig := 0
	Local cArquivo
	Local cChave := "CGC+NUMCOMP"
	Local cFilRet := ""
	
	cFilRet := RetFilCE("SFE",cFilAnt)
	lMsfil := SFE->(ColumnPos("FE_MSFIL")) > 0	
	
	//Retencion
	//Query para Retención
	cQueryR := "SELECT SA2.A2_COD AS COD, SA2.A2_LOJA AS LOJA, SA2.A2_CGC AS CGC, SFE.FE_NROCERT AS NROCERT, SFE.FE_EMISSAO AS EMISSAO, SFE.FE_ORDPAGO AS NUMCOMP, SUM(SFE.FE_VALBASE) AS BASIMP, SFE.FE_ALIQ AS ALQ, SUM(SFE.FE_RETENC) AS RETIMP, "
	cQueryR += "CASE WHEN SFE.FE_DTRETOR != '' THEN 1 ELSE 0 END AS ANUL, SFE.FE_CFO AS CFO "
	cQueryR += "FROM " + RetSqlName('SA2') + " SA2  INNER JOIN " + RetSqlName('SFE') + " SFE"
	cQueryR += " ON SFE.FE_FORNECE = SA2.A2_COD AND SFE.FE_FILIAL = '" + cFilRet + "' " 
	cQueryR += "AND SFE.D_E_L_E_T_ = '' AND SFE.FE_LOJA = SA2.A2_LOJA "
	cQueryR += "WHERE SA2.A2_FILIAL = '" + xFilial('SA2') + "' AND SA2.D_E_L_E_T_ = '' AND SFE.FE_NROCERT <> 'NORET' AND SFE.FE_EST = '" + _aTotal[07][1][1] + "' AND SA2.A2_CGC !='' "
	If("MSSQL" $ cManejador)
		cQueryR += " AND MONTH(SFE.FE_EMISSAO) = " + SUBSTR(_aTotal[07][1][2],1,2) + " AND YEAR(SFE.FE_EMISSAO) = " + SUBSTR(_aTotal[07][1][2],3)
	Else // postgres y oracle
		cQueryR +=" AND SUBSTR(SFE.FE_EMISSAO,5,2) = '" + SUBSTR(_aTotal[07][1][2],1,2) + "' AND SUBSTR(SFE.FE_EMISSAO,1,4) = '"+ SUBSTR(_aTotal[07][1][2],3)+"' "
	EndIf
	cQueryR += " AND SFE.FE_TIPO = 'B' "
	If lMsfil
		cQueryR += " AND SFE.FE_MSFIL=  '" + cFilAnt + "'
	EndIf	
	cQueryR += " GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.A2_CGC, SFE.FE_NROCERT, SFE.FE_EMISSAO, SFE.FE_ORDPAGO, SFE.FE_ALIQ, SFE.FE_DTRETOR, SFE.FE_CFO "
	cQueryR += " ORDER BY SFE.FE_EMISSAO"
	cQueryR:=ChangeQuery(cQueryR)
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQueryR), "TraR", .T., .F.)
	
	TCSetField("TraR", "EMISSAO", "D", 08, 00)
	TCSetField("TraR", "VALBASE", "N", 16, 02)
	TCSetField("TraR", "ALQ", "N", 6, 02)
	TCSetField("TraR", "RETENC", "N", 16, 02)
	
	TraR->(dbGotop())

	dbSelectArea("TRBr")
	cArquivo := GetNextAlias()
	IndRegua("TRBr",cArquivo,cChave)
	DbSetOrder(1)

	While TraR->(!Eof())		
		//Se crea tabla temporal para la creación del txt.
		If TRBr->(Dbseek(TraR->CGC + TraR->NUMCOMP))
			RecLock("TRBr",.F.)
			If  TRBr->ANUL == 1 .Or. TraR->ANUL == 1
				TRBr->(dbDelete())
			Else
				TRBr->BASIMP += TraR->BASIMP
				TRBr->RETIMP += TraR->RETIMP
				If  TRBr->BASIMP == 0 .Or. TRBr->RETIMP == 0
					TRBr->(dbDelete())
				EndIf
			End
		Else
			cTabEqui := ""
			DbSelectArea("CCP")//TABELA DE EQUIVALENCIA

			CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
			CCP->(DbGoTop())
			If DbSeek(xFilial("CCP")+Avkey(_aTotal[07][1][3],"CCP_COD")+AvKey(TraR->CFO,"CCP_VORIGE"))//SEGUNDA TABELA DE EQUIVALENCIA
				cTabEqui := SubStr(CCP->CCP_VDESTI,1,2)
			Else
				cTabEqui := "  "
			Endif
			
			nSFHVig := BuscaSFH(TraR->COD, 1, TraR->LOJA, "IBR", TraR->EMISSAO)
			
			RecLock("TRBr",.T.)
			TRBr->TIPO := 2
			TRBr->MOV := cTabEqui
			TRBr->CGC := TraR->CGC
			TRBr->NROCERT := SubStr(TraR->NROCERT, (Len(TraR->NROCERT) - 11), Len(TraR->NROCERT)) 
			TRBr->EMISSAORET := Substr(DTOS(TraR->EMISSAO),7,2)+"/"+Substr(DTOS(TraR->EMISSAO),5,2)+"/"+Substr(DTOS(TraR->EMISSAO),1,4) //Formato dd/mm/yyyy.
			TRBr->EMISSAOCOM := Substr(DTOS(TraR->EMISSAO),7,2)+"/"+Substr(DTOS(TraR->EMISSAO),5,2)+"/"+Substr(DTOS(TraR->EMISSAO),1,4) //Formato dd/mm/yyyy.
			TRBr->TIPOCOMP := "OP    " 
			TRBr->LETRACOMP := " "
			TRBr->NUMCOMP := SubStr(TraR->NUMCOMP, (Len(TraR->NUMCOMP) - 11), Len(TraR->NUMCOMP))
			TRBr->BASIMP := Iif(TraR->ANUL == 1, ABS(TraR->BASIMP), TraR->BASIMP)
			TRBr->ALQ := TraR->ALQ
			TRBr->RETIMP := Iif(TraR->ANUL == 1, ABS(TraR->RETIMP), TraR->RETIMP)
			TRBr->ANUL := TraR->ANUL
			TRBr->CM := nSFHVig
		EndIf
		MsUnlock()
		TraR->(dbSkip())
	End
	
	TraR->(dbCloseArea())
Return 

/*/
Programa: FRET
Autor: Juan Roberto González Rivas
Fecha: 16/11/2016
Descripción: Genera Archivo de Percepciones
/*/
Static Function FPER()
	Local nVal := 0
	Local cQueryP := ""
	Local cTabEqui := ""
	Local aLivros := {}
	
	//busca numero dos livros no arquivo SFB e monta o campo de acordo com on numero do livro
	aLivros := BUSCASFB()
	
	If Len(aLivros) != 0
		//Query para Percepcion
		cQueryP := "SELECT CASE WHEN SF3.F3_TIPOMOV = 'C' THEN SA2.A2_CGC WHEN SF3.F3_TIPOMOV = 'V' THEN SA1.A1_CGC END AS CGC, SF3.F3_EMISSAO AS EMISSAO, "
		cQueryP += "CASE WHEN SF3.F3_TIPOMOV = 'C' THEN 1 WHEN SF3.F3_TIPOMOV = 'V' THEN 2 END AS TIPO, "
		cQueryP += "CASE WHEN SF3.F3_TIPOMOV = 'C' THEN SA2.A2_COD WHEN SF3.F3_TIPOMOV = 'V' THEN SA1.A1_COD END AS COD, "
		cQueryP += "CASE WHEN SF3.F3_TIPOMOV = 'C' THEN SA2.A2_LOJA WHEN SF3.F3_TIPOMOV = 'V' THEN SA1.A1_LOJA END AS LOJA, "
		cQueryP += "CASE WHEN SF3.F3_ESPECIE = 'NF' THEN 'F' WHEN SF3.F3_ESPECIE IN ('NDC','NDI') THEN 'D' WHEN SF3.F3_ESPECIE IN ('NCC','NCI') THEN 'C' END AS TIPOCOMP, "
		cQueryP += "SF3.F3_SERIE AS LETRACOMP, SF3.F3_NFISCAL AS NUMCOMP, "

		//Base impuesto
		For nVal := 1 To Len(aLivros)
			If nVal < Len(aLivros)
				cQueryP += "SF3.F3_BASIMP" + aLivros[nVal][1] + " + "
			Else	
				cQueryP += "SF3.F3_BASIMP" + aLivros[nVal][1] + " "
			EndIf
		Next
		cQueryP += "AS BASIMP, "
		
		//Alicuota	
		For nVal := 1 To Len(aLivros)
			If nVal < Len(aLivros)  
				cQueryP += "SF3.F3_ALQIMP" + aLivros[nVal][1] + " + "
			Else
				cQueryP += "SF3.F3_ALQIMP" + aLivros[nVal][1] + " "
			EndIf		
		Next
		cQueryP += "AS ALQ, "
		
		//Total monto retenido 		
		For nVal := 1 To Len(aLivros)
			If nVal < Len(aLivros)  
				cQueryP += "SF3.F3_VALIMP" + aLivros[nVal][1] + " + "
			Else
				cQueryP += "SF3.F3_VALIMP" + aLivros[nVal][1] + " "
			EndIf		
		Next
		cQueryP += "AS PERIMP, "
		cQueryP += "SF3.F3_CFO AS CFO "
		cQueryP += " FROM " + RetSqlName('SF3') + " SF3 LEFT JOIN " + RetSqlName('SA1') + " SA1 "
        cQueryP += "ON SF3.F3_CLIEFOR = SA1.A1_COD AND SF3.F3_LOJA = SA1.A1_LOJA AND SA1.A1_FILIAL = '" + xFilial('SA1') + "' AND SA1.D_E_L_E_T_ = '' AND SA1.A1_CGC != '' "
        cQueryP += "LEFT JOIN " + RetSqlName('SA2') + " SA2 "
        cQueryP += "ON SF3.F3_CLIEFOR = SA2.A2_COD AND SF3.F3_LOJA = SA2.A2_LOJA AND SA2.A2_FILIAL = '" + xFilial('SA2') + "' AND SA2.D_E_L_E_T_ = '' AND SA2.A2_CGC !='' "
        cQueryP += "WHERE SF3.F3_FILIAL = '" + xFilial('SF3') + "' AND SF3.D_E_L_E_T_ = '' "
		If("MSSQL" $ cManejador)
			cQueryP += " AND MONTH(SF3.F3_EMISSAO) = " + SUBSTR(_aTotal[07][1][2],1,2) + " AND YEAR(SF3.F3_EMISSAO) = "+ SUBSTR(_aTotal[07][1][2],3) + " "
		Else // postgres y oracle
			cQueryP +=" AND SUBSTR(SF3.F3_EMISSAO,5,2) = '" + SUBSTR(_aTotal[07][1][2],1,2) + "' AND SUBSTR(SF3.F3_EMISSAO,1,4) = '" + SUBSTR(_aTotal[07][1][2],3) + "' "
		EndIf
		For nVal := 1 To Len(aLivros)
			If nVal == 1
				cQueryP += "AND ( SF3.F3_BASIMP" + aLivros[nVal][1] + " != 0 "
			Else
				cQueryP += "OR SF3.F3_BASIMP" + aLivros[nVal][1] + " != 0 "
			EndIf
		Next
		cQueryP += ") AND ((SF3.F3_TIPOMOV = 'C' AND SF3.F3_ESPECIE IN ('NDI', 'NCI')) OR (SF3.F3_TIPOMOV = 'V' AND SF3.F3_ESPECIE IN ('NF', 'NDC', 'NCC')))"
		cQueryP += " ORDER BY SF3.F3_EMISSAO"
		
		cQueryP := ChangeQuery(cQueryP)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryP),"TraP",.T.,.F.)
		
		TCSetField("TraP", "EMISSAO" ,"D", 08, 00)
		TCSetField("TraP", "BASIMP" ,"N", 16, 02)
		TCSetField("TraP", "ALQ", "N", 6, 02)
		TCSetField("TraP", "VALIMP", "N", 16, 02)
		
		TraP->(dbGotop())
		
		While TraP->(!Eof())
			dbSelectArea("TRBp")
			
			If (TraP->BASIMP > 0)
				cTabEqui := ""
				DbSelectArea("CCP")//TABELA DE EQUIVALENCIA
				CCP->(DbSetOrder(1))//CCP_FILIAL+CCP_COD+CCP_VORIGE
				CCP->(DbGoTop())
				If DbSeek(xFilial("CCP")+Avkey(_aTotal[07][1][4],"CCP_COD")+AvKey(TraP->CFO,"CCP_VORIGE"))//SEGUNDA TABELA DE EQUIVALENCIA
					cTabEqui := SubStr(CCP->CCP_VDESTI,1,2)
				Else
					cTabEqui := "  "
				Endif
				
				For nVal := 1 To Len(aLivros)
					 nSFHVig := BuscaSFH(TraP->COD, TraP->TIPO, TraP->LOJA, aLivros[nVal][2], TraP->EMISSAO)
				Next
				
				If RecLock("TRBp",.T.)
					TRBp->TIPO := 1
					TRBp->MOV := cTabEqui
					TRBp->CGC := TraP->CGC
					TRBp->EMISSAOPER := Substr(DTOS(TraP->EMISSAO),7,2)+"/"+Substr(DTOS(TraP->EMISSAO),5,2)+"/"+Substr(DTOS(TraP->EMISSAO),1,4) //Formato dd/mm/yyyy.
					TRBp->TIPOCOMP := TraP->TIPOCOMP
					TRBp->LETRACOMP := TraP->LETRACOMP
					TRBp->NUMCOMP := TraP->NUMCOMP
					TRBp->BASIMP :=TraP->BASIMP
					TRBp->ALQ := TraP->ALQ
					TRBp->PERIMP := TraP->PERIMP
					TRBp->ANUL := 0
					TRBp->CM := nSFHVig
				 EndIf
			EndIf
			
			MsUnlock()
			TraP->(dbSkip())
		End
		
		TraP->(dbCloseArea())
	EndIf
Return

/*/
Programa: BuscaSFB
Autor: Juan Roberto González Rivas
Fecha: 16/11/2016
Descripción: Busca los número de los libros para F3_VALIMP y F3_BASIMP.
/*/
Static Function BuscaSFB()
	Local cQuery := ""
	Local aLivro := {}
	
	cQuery := "SELECT FB_CPOLVRO AS LIVRO, FB_CODIGO AS CODIGO "
	cQuery += "FROM "+RetSqlName('SFB')+" SFB "
	cQuery += "WHERE FB_CLASSE = 'P' "
	cQuery += "AND SFB.D_E_L_E_T_ = ' '
	cQuery += "AND SFB.FB_FILIAL = '"+xFilial('SFB')+"' "
	cQuery += "AND SFB.FB_CLASSIF = '1' " 
	cQuery += "AND SFB.FB_ESTADO = '" + _aTotal[07][1][1] + "' "
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), "TRA", .T., .F.)

	While TRA->(!Eof())
		aAdd(aLivro,{TRA->LIVRO,TRA->CODIGO})
		TRA->(dbSkip())
	End
	
	dbCloseArea()
	Ferase("TRA")
Return aLivro

/*/
Programa: TRelSIAGER
Autor: Juan Roberto González Rivas
Fecha: 16/11/2016
Descripción: Relación para exportar el archivo txt SICOL
/*/
Function TRelSIAGER(cArq)
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
Fecha: 16/11/2016
Descripción: 	Definición de la relación.
/*/
Static Function ReportDef()
	Local olReport
	Local oSection
	
	If cArqTrab == 'TRBp'
		olReport:=TReport():New("SIAFEREPercepcionesTxt-" + Alltrim(SM0->M0_CGC),"Datos para exportación",,{|olReport| PrintReport(olReport)},"Conferencia de los datos de Percepciones para exportacion txt")
		oSection:=TRSection():new(olReport,"Percepciones",{cArqTrab})
		olReport:SetLandScape(.T.)
		
		TRCell():New(oSection,"TIPO",,,"@E!",01)
		TRCell():New(oSection,"MOV",,,"@E!",02)
		TRCell():New(oSection,"CGC",,,"@E!",11)
		TRCell():New(oSection,"EMISSAOPER",,,"@E!",10)
		TRCell():New(oSection,"TIPOCOMP",,,"@E!",06)
		TRCell():New(oSection,"LETRACOMP",,,"@E!",01)
		TRCell():New(oSection,"NUMCOMP",,,"@E!",12)
		TRCell():New(oSection,"BASIMP",,,"@E 999999999999.99",15)
		TRCell():New(oSection,"ALIQ",,,"@E 999.99",06)
		TRCell():New(oSection,"PERIMP",,,"@E 999999999999.99",15)
  		TRCell():New(oSection,"ANUL",,,,01)
  		TRCell():New(oSection,"CONVM",,,,01)
	Else
		olReport:=TReport():New("SIAFERERetencionesTxt-" + Alltrim(SM0->M0_CGC),"Datos para exportación",,{|olReport| PrintReport(olReport)},"Conferencia de los datos de Retenciones para exportacion txt")
		oSection:=TRSection():new(olReport,"Retenciones",{cArqTrab})
		olReport:SetLandScape(.T.)
		
		TRCell():New(oSection,"TIPO",,,"@E!",01)
		TRCell():New(oSection,"MOV",,,"@E!",02)
		TRCell():New(oSection,"CGC",,,"@E!",11)
		TRCell():New(oSection,"NROCERT",,,"@E!",12)
		TRCell():New(oSection,"EMISSAORET",,,"@E!",10)
		TRCell():New(oSection,"EMISSAOCOM",,,"@E!",10)
		TRCell():New(oSection,"TIPOCOMP",,,"@E!",06)
		TRCell():New(oSection,"LETRACOMP",,,"@E!",01)
		TRCell():New(oSection,"NUMCOMP",,,"@E!",12)
		TRCell():New(oSection,"BASIMP",,,"@E 999999999999.99",15)
		TRCell():New(oSection,"ALIQ",,,"@E 999.99",06)
		TRCell():New(oSection,"RETIMP",,,"@E 999999999999.99",15)
  		TRCell():New(oSection,"ANUL",,,,01)
  		TRCell():New(oSection,"CONVM",,,,01)
	EndIf
Return olReport

/*/
Programa: PrintReport
Autor: Juan Roberto González Rivas
Fecha: 16/11/2016
Descripción: Impresión de la relación.
/*/
Static Function PrintReport(olReport)
	Local olSection:=olReport:Section(1)

	If cArqTrab == 'TRBp'
		olReport:Section(1):Cell("TIPO"):SetBlock({||TRBp->TIPO})
		olReport:Section(1):Cell("MOV"):SetBlock({||TRBp->MOV})
		olReport:Section(1):Cell("CGC"):SetBlock({||TRBp->CGC})	
		olReport:Section(1):Cell("EMISSAOPER"):SetBlock({||TRBp->EMISSAOPER})
		olReport:Section(1):Cell("TIPOCOMP"):SetBlock({||TRBp->TIPOCOMP})	
	  	olReport:Section(1):Cell("LETRACOMP"):SetBlock({||TRBp->LETRACOMP})	
		olReport:Section(1):Cell("NUMCOMP"):SetBlock({||TRBp->NUMCOMP})	
		olReport:Section(1):Cell("BASIMP"):SetBlock({||PadL(AllTrim(Transform(TRBp->BASIMP,"@E 999999999999.99")),15,"0")})	
		olReport:Section(1):Cell("ALIQ"):SetBlock({||PadL(AllTrim(Transform(TRBp->ALQ,"@E 999.99")),6,"0")})
		olReport:Section(1):Cell("PERIMP"):SetBlock({||PadL(AllTrim(Transform(TRBp->PERIMP,"@E 999999999999.99")),15,"0")})	
		olReport:Section(1):Cell("ANUL"):SetBlock({||TRBp->ANUL})	
		olReport:Section(1):Cell("CONVM"):SetBlock({||TRBp->CM})	
	Else
		olReport:Section(1):Cell("TIPO"):SetBlock({||TRBr->TIPO})		
		olReport:Section(1):Cell("MOV"):SetBlock({||TRBr->MOV})	
		olReport:Section(1):Cell("CGC"):SetBlock({||TRBr->CGC})	
		olReport:Section(1):Cell("NROCERT"):SetBlock({||TRBr->NROCERT})	
		olReport:Section(1):Cell("EMISSAORET"):SetBlock({||TRBr->EMISSAORET})
		olReport:Section(1):Cell("EMISSAOCOM"):SetBlock({||TRBr->EMISSAOCOM})		
		olReport:Section(1):Cell("TIPOCOMP"):SetBlock({||TRBr->TIPOCOMP})	
		olReport:Section(1):Cell("LETRACOMP"):SetBlock({||TRBr->LETRACOMP})	
		olReport:Section(1):Cell("NUMCOMP"):SetBlock({||TRBr->NUMCOMP})	
		olReport:Section(1):Cell("BASIMP"):SetBlock({||PadL(AllTrim(Transform(TRBr->BASIMP,"@E 999999999999.99")),15,"0")})
		olReport:Section(1):Cell("ALIQ"):SetBlock({||PadL(AllTrim(Transform(TRBr->ALQ,"@E 999.99")),6,"0")})		
		olReport:Section(1):Cell("RETIMP"):SetBlock({||PadL(AllTrim(Transform(TRBr->RETIMP,"@E 999999999999.99")),15,"0")})	
		olReport:Section(1):Cell("ANUL"):SetBlock({||TRBr->ANUL})	
		olReport:Section(1):Cell("CONVM"):SetBlock({||TRBr->CM})		
	EndIf
	olSection:Print()
	
Return Nil

/*/
Programa: DelSIAGER
Autor: Juan Roberto González Rivas
Fecha: 16/11/2016
Descripción: Excluye el archivo temporario procesado
/*/
Function DelSIAGER(aArqTrab)
	Local nArq:= 0
	
	For nArq:=1 To Len(aArqTrab)
		If File(aArqTrab[nArq,1]+GetDBExtension())
			dbSelectArea(aArqTrab[nArq,2])
			dbCloseArea()
			Ferase(aArqTrab[nArq,1]+GetDBExtension())
			Ferase(aArqTrab[nArq,1]+OrdBagExt())
		Endif	
	Next
Return Nil

/*/
Programa: BuscaSFH
Autor: Juan Roberto González Rivas
Fecha: 16/11/2016
Descripción: Valida registro válido para la tabla SFH según la información proporcionada.
/*/
Function BuscaSFH(cCliFor, cTipo, cLoja, cImpuesto, dEmissao)
	Local aAreaSFH := SFH->(GetArea())
	Local aSFHVig := {}
	Local lValor := .F.
	Local nValorRet := 0
	Local nRetOrd := 0

	Aadd(aSFHVig,{0,0})
	Aadd(aSFHVig,{0,0})
	Aadd(aSFHVig,{0,0})
	Aadd(aSFHVig,{0,0})
	
	If cTipo == 1
		nRetOrd := RETORDEM("SFH","FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS")
	Else
		nRetOrd := RETORDEM("SFH","FH_FILIAL+FH_CLIENTE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS")
	EndIf
	
	DbSelectArea("SFH")
	SFH->(DbSetOrder(nRetOrd))//FH_FILIAL+FH_FORNECE+FH_LOJA+FH_IMPOSTO+FH_ZONFIS
	SFH->(DbGoTop())
	If SFH->(MsSeek(xFilial("SFH") + cCliFor + cLoja + cImpuesto + _aTotal[07][1][1]))
		Do While SFH->(!Eof()) .And. Iif(cTipo == 1, SFH->FH_FORNECE == cCliFor, SFH->FH_CLIENTE == cCliFor) .And. SFH->FH_LOJA == cLoja;  
			.And. SFH->FH_IMPOSTO == cImpuesto .And. SFH->FH_ZONFIS == _aTotal[07][1][1]
			
			lValor := .T.
			If Empty(SFH->FH_INIVIGE)
				If Empty(SFH->FH_FIMVIGE)
					aSFHVig[1][1] := 1
					aSFHVig[1][2] := Iif(SFH->FH_TIPO == 'V', 1, 0)
				ElseIf dEmissao < SFH->FH_FIMVIGE
					aSFHVig[2][1] := 1
					aSFHVig[2][2] := Iif(SFH->FH_TIPO == 'V', 1, 0)
				EndIf
			ElseIf dEmissao > SFH->FH_INIVIGE
				If Empty(SFH->FH_FIMVIGE)
					aSFHVig[3][1] := 1
					aSFHVig[3][2] := Iif(SFH->FH_TIPO == 'V', 1, 0)
				ElseIf dEmissao < SFH->FH_FIMVIGE
					aSFHVig[4][1] := 1
					aSFHVig[4][2] := Iif(SFH->FH_TIPO == 'V', 1, 0)
				EndIf
			EndIf
			SFH->(DbSkip())
		EndDo
	EndIf
	
	If lValor
		If aSFHVig[1][1] == 1
			nValorRet := aSFHVig[1][2]
		ElseIf aSFHVig[2][1] == 1
			nValorRet := aSFHVig[2][2]
		ElseIf aSFHVig[3][1] == 1
			nValorRet := aSFHVig[3][2]
		ElseIf aSFHVig[4][1] == 1
			nValorRet := aSFHVig[4][2]
		EndIf
	EndIf
	
	RestArea(aAreaSFH)

Return nValorRet

/*
±±³Fun‡…o    ³RetFilCE  ³ Autor ³ Danilo Santos    ³ Data ³ 22.07.19 ³±±
±±³Descri‡…o ³ Retorna filial quando a tabela é compartilhada ou exclusiva ³±±
*/
Static Function RetFilCE(cAliasSFE,cNumFil)
Local cFilRet := ""
Local nDif	:= 0
Local nDif1	:= 0
Local cLayout := ""
Local lEmp	:= .F.
Local lUnid := .F.
Local lFil	:= .F.
Local nAchou := 0

DEFAULT cAliasSFE  := "SFE"
DEFAULT cNumFil := cFilAnt   

If cPaisLoc == "ARG" .And. (FWModeAccess(cAliasSFE,1) == "C" .OR. FWModeAccess(cAliasSFE,2) == "C" .OR. FWModeAccess(cAliasSFE,3) == "C")
	cLayout := ALLTRIM(FWSM0Layout())
	Do Case
		Case FWModeAccess(cAliasSFE,1) == "C"
			lEmp := .T.
		Case FWModeAccess(cAliasSFE,2) == "C"
			lUnid := .T.
		Case FWModeAccess(cAliasSFE,3) == "C"
			lFil := .T.
	EndCase
		
	IF !lEmp
		IF !lUnid
			IF lFil
				nAchou := at("F",cLayout)
			EndIf
		Else
			nAchou := at("U",cLayout)
		EndIf
	Else
		nAchou := at("E",cLayout)
	EndIf
		
	IF nAchou <= 1
		cFilRet := Space(FwSizeFilial())
	Else
		cFilRet := SUBSTR(cNumFil,1,nAchou-1)
		cFilRet := cFilRet+SPACE(LEN(cFilRet)-len(cFilRet))
	EndIf
ElseIf FwSizeFilial() >= 4 .And. FWModeAccess(cAliasSFE,3) == "E"
	cFilRet := cNumFil
Else 
	cFilRet := cFilAnt
EndIf

Return cFilRet