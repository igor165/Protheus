#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSA200V
    Cria viagem automática a partir do lote
    @type Function
    @author Valdemar Roberto Mognon
    @since 12/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA200V()
    (examples)
    @see (links_or_references)
*/
Function TMSA200V(cLote)
Local aAreas    := {GetArea()}
Local aDadosDTQ := {}
Local aDadosDM3 := {}
Local aDadosDTR := {}
Local aDadosDUP := {}
Local aMaster   := {}
Local aGrid     := {}
Local lTemMod3  := ExistFunc("TMSAF60") .And. AliasIndic("DM3")
Local lCont     := .T.
Local cQuery    := ""
Local cAliasDT6 := ""
Local nSeqDM3   := 0
Local nSeqDTR   := 0

Default cLote := ""

If !Empty(cLote) .And. lTemMod3 .And. AliasInDic("DMQ")
	cAliasDT6 := GetNextAlias()

	cQuery := "SELECT DT6_FILDOC,DT6_DOC,DT6_SERIE,"
	cQuery += "       DMQ_CODVEI,DMQ_CODRB1,DMQ_CODRB2,DMQ_CODRB3,"
	cQuery += "       DTP_SERTMS,DTP_ROTA,"
	cQuery += "       DA3_MOTORI "
	cQuery += "  FROM " + RetSqlName("DT6") + " DT6 "

	cQuery += "  JOIN " + RetSqlName("DMQ") + " DMQ "
	cQuery += "    ON DMQ_FILIAL = '" + xFilial("DMQ") + "' "
	cQuery += "   AND DMQ_LOTNFC = '" + cLote + "' "
	cQuery += "   AND DMQ.D_E_L_E_T_ = ' '"

	cQuery += "  JOIN " + RetSqlName("DTP") + " DTP "
	cQuery += "    ON DTP_FILIAL = '" + xFilial("DTP") + "' "
	cQuery += "   AND DTP_LOTNFC = '" + cLote + "' "
	cQuery += "   AND DTP.D_E_L_E_T_ = ' '"

	cQuery += "  JOIN " + RetSqlName("DA3") + " DA3 "
	cQuery += "    ON DA3_FILIAL = '" + xFilial("DA3") + "' "
	cQuery += "   AND DA3_COD    = DMQ_CODVEI "
	cQuery += "   AND DA3.D_E_L_E_T_ = ' '"

	cQuery += " WHERE DT6_FILIAL = '" + xFilial("DT6") + "' "
	cQuery += "   AND DT6_LOTNFC = '" + cLote + "' "
	cQuery += "   AND DT6.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDT6,.F.,.T.)

	If (cAliasDT6)->(!Eof())
		//-- Cabeçalho da viagem
		Aadd(aDadosDTQ,{"DTQ_SERTMS",(cAliasDT6)->DTP_SERTMS        ,Nil})	//-- Transferência ou Entrega
		Aadd(aDadosDTQ,{"DTQ_TIPTRA",StrZero(1,Len(DTQ->DTQ_TIPTRA)),Nil})	//-- Rodoviária
		Aadd(aDadosDTQ,{"DTQ_TIPVIA",StrZero(3,Len(DTQ->DTQ_TIPVIA)),Nil})	//-- Planejada
		Aadd(aDadosDTQ,{"DTQ_ROTA"  ,(cAliasDT6)->DTP_ROTA          ,Nil})
		While (cAliasDT6)->(!Eof())
			//-- Documentos da viagem
			If Ascan(aDadosDM3,{|x| x[2] + x[3] + x[4] == (cAliasDT6)->(DMQ_FILDOC + DMQ_DOC + DMQ_SERIE)}) == 0
				nSeqDM3 ++
				Aadd(aDadosDM3,{})
				Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_SEQUEN",StrZero(nSeqDM3,Len(DM3->DM3_SEQUEN)),Nil})
				Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_FILDOC",(cAliasDT6)->DT6_FILDOC,Nil})
				Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_DOC"   ,(cAliasDT6)->DT6_DOC   ,Nil})
				Aadd(aDadosDM3[Len(aDadosDM3)],{"DM3_SERIE" ,(cAliasDT6)->DT6_SERIE ,Nil})
			EndIf
			//-- Veículos da viagem
			If Ascan(aDadosDTR,{|x| x[2] == (cAliasDT6)->DMQ_CODVEI}) == 0
				nSeqDTR ++
				Aadd(aDadosDTR,{})
				Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_ITEM"  ,StrZero(nSeqDTR,Len(DTR->DTR_ITEM)),Nil})
				Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_CODVEI",(cAliasDT6)->DMQ_CODVEI,Nil})
				If !Empty((cAliasDT6)->DMQ_CODRB1)
					Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_CODRB1",(cAliasDT6)->DMQ_CODRB1,Nil})
				EndIf
				If !Empty((cAliasDT6)->DMQ_CODRB2)
					Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_CODRB2",(cAliasDT6)->DMQ_CODRB2,Nil})
				EndIf
				If !Empty((cAliasDT6)->DMQ_CODRB3)
					Aadd(aDadosDTR[Len(aDadosDTR)],{"DTR_CODRB3",(cAliasDT6)->DMQ_CODRB3,Nil})
				EndIf
				//-- Motoristas da viagem
				If !Empty((cAliasDT6)->DA3_MOTORI)
					Aadd(aDadosDUP,{})
					Aadd(aDadosDUP[Len(aDadosDUP)],{"DUP_ITEDTR",StrZero(nSeqDTR,Len(DTR->DTR_ITEM)),Nil})
					Aadd(aDadosDUP[Len(aDadosDUP)],{"DUP_CODMOT",(cAliasDT6)->DA3_MOTORI,Nil})
				EndIf
			EndIf
			(cAliasDT6)->(DbSkip())
		EndDo

		//-- Executa a criação da viagem
		Aadd(aMaster,{})
		Aadd(aMaster[Len(aMaster)],aClone(aDadosDTQ))
		Aadd(aMaster[Len(aMaster)],"MdFieldDTQ")
		Aadd(aMaster[Len(aMaster)],"DTQ")

		If Len(aDadosDM3) > 0
			Aadd(aGrid,{})
			Aadd(aGrid[Len(aGrid)],aClone(aDadosDM3))
			Aadd(aGrid[Len(aGrid)],"MdGridDM3")
			Aadd(aGrid[Len(aGrid)],"DM3")
		EndIf

		If Len(aDadosDTR) > 0
			Aadd(aGrid,{})
			Aadd(aGrid[Len(aGrid)],aClone(aDadosDTR))
			Aadd(aGrid[Len(aGrid)],"MdGridDTR")
			Aadd(aGrid[Len(aGrid)],"DTR")
			Aadd(aGrid[Len(aGrid)],.F.)	//-- Indica que a linha do GRID será pesquisada para alteração
		EndIf

		If Len(aDadosDUP) > 0
			Aadd(aGrid,{})
			Aadd(aGrid[Len(aGrid)],aClone(aDadosDUP))
			Aadd(aGrid[Len(aGrid)],"MdGridDUP")
			Aadd(aGrid[Len(aGrid)],"DUP")
			Aadd(aGrid[Len(aGrid)],.F.)	//-- Indica que a linha do GRID será pesquisada para alteração
		EndIf

		If Len(aMaster) > 0
			lCont := TMSExecAuto("TMSAF60",aMaster,aGrid,3,.T.)
		EndIf

	EndIf
		
	(cAliasDT6)->(DbCloseArea())

EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return
