#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSXFUNH.CH"

Static lTMChkObs := ExistBlock("TMCHKOBS")
Static _cURLChk  := GetURLChk()	//-- URL Check-List
Static lDM0      := TableInDic("DM0")

/*/{Protheus.doc} TMSNFcECmp
Busca as notas fiscais a partir de um CTe
@author Valdemar Roberto Mognon
@since 30/07/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSNFcECmp(aChvCte)
Local aRet      := {}
Local aAreas    := {DT6->(GetArea()),GetArea()}
Local aVetWrk   := {}
Local cQuery    := ""
Local cAliasDTC := ""
Local nCntFor1  := 0

Default aChvCte := ""

//-- Mapa do vetor aRet
//-- 01 - Chave do CTe
//-- 02 - Vetor com as notas do CTe
//--      01 - Codigo do remetente
//--      02 - Loja do remetente
//--      03 - Numero da nota fiscal
//--      04 - Serie da nota fiscal
//--      05 - Data de emissao da nota fiscal
//--      06 - RECNO da nota fiscal (DTC)

If !Empty(aChvCte)
	For nCntFor1 := 1 To Len(aChvCte)
		DT6->(DbSetOrder(18))
		If DT6->(DbSeek(xFilial("DT6") + aChvCte[nCntFor1]))
			cAliasDTC := GetNextAlias()
			cQuery := "SELECT DISTINCT DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_EMINFC,DTC.R_E_C_N_O_ NUMREC "

			cQuery += "  FROM " + RetSqlName("DTC") + " DTC "

			cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery += "    ON DT6_FILIAL = '" + xFilial("DT6") + "' "
			cQuery += "   AND DT6_CHVCTE = '" + aChvCte[nCntFor1] + "' "
			cQuery += "   AND DT6.D_E_L_E_T_ = ' '"

			cQuery += " WHERE DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += "   AND DTC_FILDOC = DT6_FILDOC "
			cQuery += "   AND DTC_DOC    = DT6_DOC "
			cQuery += "   AND DTC_SERIE  = DT6_SERIE "
			cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDTC)

			aVetWrk := {}
					
			While (cAliasDTC)->(!Eof())
				Aadd(aVetWrk,{(cAliasDTC)->DTC_CLIREM,(cAliasDTC)->DTC_LOJREM,(cAliasDTC)->DTC_NUMNFC,(cAliasDTC)->DTC_SERNFC,;
							  (cAliasDTC)->DTC_EMINFC,(cAliasDTC)->NUMREC})
				(cAliasDTC)->(DbSkip())
			EndDo
			If !Empty(aVetWrk)
				Aadd(aRet,{aChvCte[nCntFor1],aVetWrk})
			EndIf
			(cAliasDTC)->(DbCloseArea())
		EndIf
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

/*/{Protheus.doc} TMSVldECmp
Valida a exclusão do evento de cancelamento do comprovante de entrega junto à SEFAZ
@author Valdemar Roberto Mognon
@since 30/07/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVldECmp(aRecNFc,aChvCte)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local aVetWrk   := {}
Local cQuery    := ""
Local cAliasDLY := ""
Local cAcaoDLY  := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local lCondNFc  := .T.
Local lCondCte  := .T.

Default aRecNFc := {}
Default aChvCte := {}

//-- Mapa do vetor aRet
//-- 01 - Chave do CTe
//-- 02 - Condicao lógica de continuidade do processo de estorno da ocorrência do CTe no TMSA360(.T. ou .F.)
//-- 03 - Status do evento da DLY
//-- 04 - Vetor com as notas do CTe que recebeu a ocorrência
//--      01 - Codigo do remetente
//--      02 - Loja do remetente
//--      03 - Numero da nota fiscal
//--      04 - Serie da nota fiscal
//--      05 - Data de emissao da nota fiscal
//--      06 - RECNO do ultimo evento da nota fiscal (DLY)
//--      07 - Condição de estorno do evento da nota fiscal (.T. ou .F.)
//--      08 - Ação que deve ser tomada na tabela de eventos da nota fiscal (DLY) (0=Nenhuma Ação, 1=Exclui Registro ou 2=Gera Evento de Cancelamento)

If !Empty(aChvCte)
	aRecNFc := TMSNFcECmp(Aclone(aChvCte))
EndIf

If !Empty(aRecNFc)
	For nCntFor1 := 1 To Len(aRecNFc)

		aVetWrk  := {}
		lCondCte := .T.
		
		For nCntFor2 := 1 To Len(aRecNFc[nCntFor1,2])

			cAliasDLY := GetNextAlias()
			cQuery := " SELECT DLY1.DLY_TIPEVE,DLY1.DLY_STATUS,DLY1.R_E_C_N_O_ ULTIMO1"

			cQuery += "  FROM " + RetSqlName("DLY") + " DLY1 "

			cQuery += " WHERE DLY1.DLY_FILIAL = '" + xFilial("DLY") + "' "
			cQuery += "   AND DLY1.R_E_C_N_O_ = (SELECT MAX(DLY2.R_E_C_N_O_) ULTIMO2 "
			cQuery += "                            FROM " + RetSqlName("DLY") + " DLY2 "
			cQuery += "                           WHERE DLY2.DLY_FILIAL = '" + xFilial("DLY") + "' "
			cQuery += "                             AND DLY2.DLY_CLIREM = '" + aRecNFc[nCntFor1,2,nCntFor2,1] + "' "
			cQuery += "                             AND DLY2.DLY_LOJREM = '" + aRecNFc[nCntFor1,2,nCntFor2,2] + "' "
			cQuery += "                             AND DLY2.DLY_NUMNFC = '" + aRecNFc[nCntFor1,2,nCntFor2,3] + "' "
			cQuery += "                             AND DLY2.DLY_SERNFC = '" + aRecNFc[nCntFor1,2,nCntFor2,4] + "' "
			cQuery += "                             AND DLY2.DLY_EMINFC = '" + aRecNFc[nCntFor1,2,nCntFor2,5] + "' "
			cQuery += "                             AND DLY2.D_E_L_E_T_ = ' ')
			cQuery += "   AND DLY1.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

			While (cAliasDLY)->(!Eof())

				lCondNFc := .T.
				cAcaoDLY := ""
				//-- Se for um registro de Envio com status 1-nao apto ou 2-apto permite cancelar.
				//-- Já que se for a primeira transmissão não existe na sefaz e se for do tipo cancelamento
				//-- segue para a próxima validação.
				If (cAliasDLY)->DLY_STATUS $ "12" .And. (cAliasDLY)->DLY_TIPEVE == "1"
					lCondNFc := .T.
					cAcaoDLY := "1"	//-- Exclui Registro
				//-- Se for um registro de Cancelamento e o status for 1-nao apto ou 2-apto, não permite
				//-- cancelar porque o registro de cancelamento não altorizando considerando assim o ultimo
				//-- registro que é de envio e está autorizado.
				ElseIf (cAliasDLY)->DLY_STATUS $ "12" .And. (cAliasDLY)->DLY_TIPEVE == "2"
					lCondNFc := .F. //-- não permite estornar a ocorrencia
					cAcaoDLY := "0" //-- não faz nada
				ElseIf (cAliasDLY)->DLY_STATUS $ "3"	//-- Transmitido
					lCondNFc := .F.
					cAcaoDLY := "0"	//-- Nenhuma Acao
				ElseIf (cAliasDLY)->DLY_STATUS $ "4" .And. (cAliasDLY)->DLY_TIPEVE == "1"	//-- Autorizado - Envio
					lCondNFc := .F.
					cAcaoDLY := "2"	//-- Gera Evento de Cancelamento
				ElseIf (cAliasDLY)->DLY_STATUS $ "4" .And. (cAliasDLY)->DLY_TIPEVE == "2"	//-- Autorizado - Cancelamento na SEFAZ
					lCondNFc := .T.
					cAcaoDLY := "0"	//-- Nenhuma Ação \ não gera DLY
				ElseIf (cAliasDLY)->DLY_STATUS $ "5" .And. (cAliasDLY)->DLY_TIPEVE == "1"	//-- Rejeitado - Envio
					lCondNFc := .T.
					cAcaoDLY := "0"	//-- Nenhuma Ação \ não gera DLY
				ElseIf (cAliasDLY)->DLY_STATUS $ "5" .And. (cAliasDLY)->DLY_TIPEVE == "2"	//-- Rejeitado - Cancelamento
					lCondNFc := .F.
					cAcaoDLY := "0"	//-- Nenhuma Acao
				EndIf

				Aadd(aVetWrk,{aRecNFc[nCntFor1,2,nCntFor2,1],aRecNFc[nCntFor1,2,nCntFor2,2],aRecNFc[nCntFor1,2,nCntFor2,3],;
							  aRecNFc[nCntFor1,2,nCntFor2,4],aRecNFc[nCntFor1,2,nCntFor2,5],(cAliasDLY)->ULTIMO1,lCondNFc,cAcaoDLY})
				If lCondCte .And. !lCondNFc
					lCondCte := .F.
				EndIf
				(cAliasDLY)->(DbSkip())
			EndDo
			(cAliasDLY)->(DbCloseArea())

		Next nCntFor2

		If !Empty(aVetWrk)
			Aadd(aRet,{aRecNFc[nCntFor1,1],lCondCte,,aVetWrk})
		EndIf

	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

/*/{Protheus.doc} TMSCanECmp
Exclusão do evento de cancelamento do comprovante de entrega junto à SEFAZ
@author Valdemar Roberto Mognon
@since 30/07/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSCanECmp(aRecNFc,cTipCan)
Local aAreas   := {DLY->(GetArea()),GetArea()}
Local aEventos := {}
Local nCntFor1 := 0
Local nCntFor2 := 0

Default aRecNFc := {}
Default cTipCan := ""

If !Empty(aRecNFc)
	For nCntFor1 := 1 To Len(aRecNFc)
		For nCntFor2 := 1 To Len(aRecNFc[nCntFor1,4])

			If aRecNFc[nCntFor1,2] .Or. (!aRecNFc[nCntFor1,2] .And. aRecNFc[nCntFor1,4,nCntFor2,8] == "2")	//-- Pode estornar a ocorrência do CTe ou
				//-- Não pode estornar porém gera DLY de cancelamento

				If (aRecNFc[nCntFor1,4,nCntFor2,7] .And. aRecNFc[nCntFor1,4,nCntFor2,8] != "0") .Or. (!aRecNFc[nCntFor1,4,nCntFor2,7] .And. aRecNFc[nCntFor1,4,nCntFor2,8] == "2") //-- Pode estornar o evento da nota fiscal, 
					//-- e existe ação a ser feita
					DLY->(DbGoTo(aRecNFc[nCntFor1,4,nCntFor2,6]))
					If aRecNFc[nCntFor1,4,nCntFor2,8] == "1" .And. cTipCan == "2"	//-- Exclui Registro
						aRecNFc[nCntFor1,3] := DLY->DLY_STATUS

						RecLock("DLY",.F.)
						DLY->(DbDelete())
						DLY->(MsUnlock())
					ElseIf aRecNFc[nCntFor1,4,nCntFor2,8] == "2"	//-- Gera Evento de Cancelamento
						aRecNFc[nCntFor1,3] := DLY->DLY_STATUS

						aEventos := {}
						Aadd(aEventos,{"DLY_CLIREM",DLY->DLY_CLIREM,Nil})
						Aadd(aEventos,{"DLY_LOJREM",DLY->DLY_LOJREM,Nil})
						Aadd(aEventos,{"DLY_NUMNFC",DLY->DLY_NUMNFC,Nil})
						Aadd(aEventos,{"DLY_SERNFC",DLY->DLY_SERNFC,Nil})
						Aadd(aEventos,{"DLY_EMINFC",DLY->DLY_EMINFC,Nil})
						Aadd(aEventos,{"DLY_TIPEVE",StrZero(2,Len(DLY->DLY_TIPEVE)),Nil})	//-- Cancelamento
						Aadd(aEventos,{"DLY_TIPCAN",cTipCan        ,Nil})	//-- 0=Não se Aplica, 1=Manual ou 2=Automático
						Aadd(aEventos,{"DLY_STATUS",StrZero(2,Len(DLY->DLY_TIPEVE)),Nil})	//-- Apto
						Aadd(aEventos,{"DLY_NFEID ",DLY->DLY_NFEID ,Nil})
						Aadd(aEventos,{"DLY_CHVCTE",DLY->DLY_CHVCTE,Nil})
						Aadd(aEventos,{"DLY_RECEBE",DLY->DLY_RECEBE,Nil})
						Aadd(aEventos,{"DLY_DOCREC",DLY->DLY_DOCREC,Nil})
						Aadd(aEventos,{"DLY_DIRIMG",DLY->DLY_DIRIMG,Nil})
						Aadd(aEventos,{"DLY_DATENT",DLY->DLY_DATENT,Nil})
						Aadd(aEventos,{"DLY_HORENT",DLY->DLY_HORENT,Nil})
						If DLY->(ColumnPos("DLY_FILDOC")) > 0 .And. DLY->(ColumnPos("DLY_DOC")) > 0 .And. DLY->(ColumnPos("DLY_SERIE")) > 0
							Aadd(aEventos,{"DLY_FILDOC",DLY->DLY_FILDOC,Nil})
							Aadd(aEventos,{"DLY_DOC"   ,DLY->DLY_DOC   ,Nil})
							Aadd(aEventos,{"DLY_SERIE" ,DLY->DLY_SERIE ,Nil})
						EndIf
						TMSIncDLY(aEventos)
					EndIf
				EndIf
			EndIf
		Next nCntFor2
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRecNFc
/*/-----------------------------------------------------------
{Protheus.doc} TMSIncDLY()
Inclui o registro na DLY de acordo com o array passado

@author Daniel Leme
@since 01/08/2019
-----------------------------------------------------------/*/
Function TMSIncDLY(aDados,nOpcx)
Local cChvCTe := ""
Local cCliRem := ""
Local cLojRem := ""
Local cNumNFc := ""
Local cSerNFc := ""
Local dEmiNFc := CToD("")

Local lGrava   := .F.
Local aAreaDM0 := {}

Default aDados	:= {}
Default nOpcx 	:= 3

If nOpcx == 3
	cChvCTe := aDados[Ascan(aDados,{|x| x[1] == "DLY_CHVCTE"}),2]
	cCliRem := aDados[Ascan(aDados,{|x| x[1] == "DLY_CLIREM"}),2]
	cLojRem := aDados[Ascan(aDados,{|x| x[1] == "DLY_LOJREM"}),2]
	cNumNFc := aDados[Ascan(aDados,{|x| x[1] == "DLY_NUMNFC"}),2]
	cSerNFc := aDados[Ascan(aDados,{|x| x[1] == "DLY_SERNFC"}),2]
	dEmiNFc := aDados[Ascan(aDados,{|x| x[1] == "DLY_EMINFC"}),2]

	RecLock("DLY",.T.)
	DLY->DLY_FILIAL := xFilial("DLY")
	DLY->DLY_SEQEVE := DLY->(TMSSeqDLY(cChvCTe,cCliRem,cLojRem,cNumNFc,cSerNFc,dEmiNFc))
ElseIf DLY->(!Eof())
	RecLock("DLY",.F.)
ElseIf DLY->(Eof()) 
	RestArea(aAreaDM0)
	Return Nil
EndIf

If nOpcx != 5
	aEval(aDados,{|x| Iif( !(AllTrim(x[1]) $ "DLY_FILIAL|DLY_SEQEVE"), DLY->(FieldPut(FieldPos(x[1]),x[2])), Nil) })
Else
	DLY->(DbDelete())
Endif

DLY->(MSUnlock())

//-- Atualiza o status da DLY de 0 para 2 quando da atualização da DLY vindo do Check List
//-- É alteração
//-- Os campos de Recebedor, Documento do Recebedor e Imagem estão preenchidos
//-- O status da DLY é 0=Integração
If nOpcx == 4 .And. !Empty(DLY->DLY_RECEBE) .And. !Empty(DLY->DLY_DOCREC) .And. DLY->DLY_STATUS == "1"
	If !lDM0 .And. !Empty(DLY->DLY_DIRIMG)
		lGrava := .T.
	ElseIf lDM0
		aAreaDM0 := DM0->(GetArea())
		DM0->(DbSetOrder(1))
		If DM0->(DbSeek(xFilial("DM0") + DLY->(DLY_FILDOC + DLY_DOC + DLY_SERIE))) .And. !Empty(DM0->DM0_EXTENS)
			lGrava := .T.
			RestArea(aAreaDM0)
		EndIf
	EndIf
	If lGrava
		RecLock("DLY",.F.)
		DLY->DLY_STATUS := "2"
		DLY->(MsUnlock())
	EndIf
EndIf

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} TMSSeqDLY()
Retorna a próxima sequencia de uma chave na tabela DLY

@author Daniel Leme
@since 30/07/2019
-----------------------------------------------------------/*/
Static Function TMSSeqDLY(cChvCte,cCliRem,cLojRem,cNumNfc,cSerNfc,dEmiNfc)
Local cRet   := StrZero(1,Len(DLY->DLY_SEQEVE))
Local aArea  := GetArea()
Local cQuery := ""
Local cAlias := GetNextAlias()

cQuery := " SELECT MAX(DLY_SEQEVE) DLY_SEQEVE"
cQuery += " FROM " + RetSqlName("DLY") + " DLY "
cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "'"
cQuery += "   AND DLY.DLY_CLIREM = '" + cCliRem + "'"
cQuery += "   AND DLY.DLY_LOJREM = '" + cLojRem + "'"
cQuery += "   AND DLY.DLY_NUMNFC = '" + cNumNfc + "'"
cQuery += "   AND DLY.DLY_SERNFC = '" + cSerNfc + "'"
cQuery += "   AND DLY.DLY_EMINFC = '" + DtoS(dEmiNfc) + "'"
cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAlias, .F., .T.)

If (cAlias)->(!Eof()) .And. !Empty((cAlias)->DLY_SEQEVE)
	cRet := Soma1((cAlias)->DLY_SEQEVE)
EndIf

(cAlias)->(DbCloseArea())

RestArea(aArea)

Return cRet

/*/{Protheus.doc} TMSPrcCmp
Processa comprovante de entrega para envio ao TSS
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSPrcCmp(aChvCTe)
Local aAreas    := {GetArea()}
Local aDadosCmp := {}
Local cQuery    := ""
Local cAliasDLY := ""
Local nCntFor1  := 0

Local lStaDM0   := DM0->(ColumnPos("DM0_STATUS")) > 0
Local cNomRec   := ""
Local cDocRec   := ""

Default aChvCTe := {}

If !Empty(aChvCTe)
	For nCntFor1 := 1 To Len(aChvCTe)
		cAliasDLY := GetNextAlias()
		cQuery := "SELECT DLY.* "
		If lDM0
		    cQuery += ", DM0.R_E_C_N_O_ DM0_RECNO "
		EndIf

		If lStaDM0
			cQuery += ", DM0.DM0_NOMRES, DM0.DM0_DOCRES "
		EndIf
		
		cQuery += "  FROM " + RetSqlName("DLY") + " DLY "

		If lDM0
            cQuery += " INNER JOIN " + RetSqlName("DM0") + " DM0 "
            cQuery += "   ON DM0.DM0_FILDOC = DLY.DLY_FILDOC "
            cQuery += "   AND DM0.DM0_DOC = DLY.DLY_DOC "
            cQuery += "   AND DM0.DM0_SERIE = DLY.DLY_SERIE "
            cQuery += "   AND DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
            cQuery += "   AND DM0.D_E_L_E_T_ = ' ' "
        EndIf

		cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
		cQuery += "   AND DLY.DLY_CHVCTE = '" + aChvCTe[nCntFor1] + "' "
		cQuery += "   AND DLY.DLY_STATUS = '2' "
		cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

		TCSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
		TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
		TCSetField(cAliasDLY,"DLY_DATENT","D",8,0)

		aDadosCmp := {}
		If lDM0
			DM0->(DbGoTo((cAliasDLY)->DM0_RECNO))
		EndIf
		While (cAliasDLY)->(!Eof())
			If lStaDM0
				cNomRec := If( Empty( (cAliasDLY)->DM0_NOMRES ), (cAliasDLY)->DLY_RECEBE, (cAliasDLY)->DM0_NOMRES )
				cDocRec := If( Empty( (cAliasDLY)->DM0_DOCRES ), (cAliasDLY)->DLY_DOCREC, (cAliasDLY)->DM0_DOCRES )
			Else
				cNomRec := (cAliasDLY)->DLY_RECEBE
				cDocRec := (cAliasDLY)->DLY_DOCREC
			EndIf
			Aadd(aDadosCmp,{(cAliasDLY)->DLY_CLIREM,(cAliasDLY)->DLY_LOJREM,(cAliasDLY)->DLY_NUMNFC,(cAliasDLY)->DLY_SERNFC,;
							(cAliasDLY)->DLY_EMINFC,(cAliasDLY)->DLY_SEQEVE,(cAliasDLY)->DLY_DATENV,(cAliasDLY)->DLY_HORENV,;
							(cAliasDLY)->DLY_TIPEVE,(cAliasDLY)->DLY_TIPCAN,(cAliasDLY)->DLY_STATUS,(cAliasDLY)->DLY_IDREVE,;
							(cAliasDLY)->DLY_RETEVE,(cAliasDLY)->DLY_NFEID ,(cAliasDLY)->DLY_CHVCTE,cNomRec,;
							cDocRec,IIf(!lDM0, (cAliasDLY)->DLY_DIRIMG, DM0->DM0_IMAGEM),(cAliasDLY)->DLY_DATENT,(cAliasDLY)->DLY_HORENT,;
							(cAliasDLY)->DLY_PROTOC})
			(cAliasDLY)->(DbSkip())
		EndDo
		(cAliasDLY)->(DbCloseArea())

		If !Empty(aDadosCmp)
			TMSEnvCmp(Aclone(aDadosCmp),aDadosCmp[1,9])
		EndIf
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSEnvCmp
Envia XML de comprovante de entrega ao TSS
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSEnvCmp(aDadosCmp,cTipo)
Local aAreas    := {DT6->(GetArea()),GetArea()}
Local aCTe      := {}
Local cXML      := ""
Local cIdEnt    := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cErro     := ""
Local cRetorno  := ""
Local cQuery    := ""
Local cIdEven   := ""
Local lUsaColab := UsaColaboracao("2")
Local lRetorno  := .F.

Local cHshImg   := ""
Local cFilVia   := ""
Local cNumVia   := ""
Local lTemVia   := DLY->(ColumnPos("DLY_FILORI") > 0) .And. DLY->(ColumnPos("DLY_VIAGEM") > 0) .And. DLY->(ColumnPos("DLY_HSHIMG") > 0)

If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)
EndIf

If !Empty(cIdEnt)

	cXML := TMSXMLCmp(Aclone(aDadosCmp),cTipo,cIdEnt,lUsaColab,.T.,@aCTe,@cHshImg)

	If lUsaColab
		If ColEnvEvento("CEC",aCte,cXML,@cIdEven,@cErro,,,.T.,,Iif(cTipo == "1",.F.,.T.))
			lRetorno := .T.
		EndIf
	Else
		// Chamado do método e envio
		oWs:= WsNFeSBra():New()
		oWs:cUserToken	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWs:cXML_LOTE	:= cXML
		oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
	
		If oWs:RemessaEvento()
			If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
				lRetorno := .T.
			EndIf
		Else
			cErro	:= IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3))
		Endif

		If !lRetorno
			cRetorno := STR0001 + CRLF + CRLF	//-- "Houve erro durante a transmissão para o Totvs Services SPED."
			cRetorno += cErro
		EndIf
	EndIf
	
	If lRetorno
		DT6->(DbSetOrder(18))	//-- DT6_FILIAL + DT6_CHVCTE
		If DT6->(DbSeek(xFilial("DT6") + aDadosCmp[1,15]))
			cFilVia := DT6->DT6_FILVGA
			cNumVia := DT6->DT6_NUMVGA
		EndIf
		//-- Atualiza a DLY
		cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
		cQuery += "    SET DLY_DATENV = '" + DToS(dDataBase) + "', " + CRLF
		cQuery += "        DLY_HORENV = '" + SubStr(Time(),1,2) + SubStr(Time(),4,2) + "', " + CRLF
		cQuery += "        DLY_STATUS = '3' " + CRLF
		If lTemVia
			cQuery += "    , DLY_FILORI = '" + cFilVia + "' "
			cQuery += "    , DLY_VIAGEM = '" + cNumVia + "' "
			cQuery += "    , DLY_HSHIMG = '" + cHshImg + "' "
		EndIf
		cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
		cQuery += "    AND DLY_CHVCTE = '" + aDadosCmp[1,15] + "' " + CRLF
		cQuery += "    AND DLY_STATUS = '2' "
		cQuery += "    AND D_E_L_E_T_ = ' ' "
		TCSqlExec(cQuery)
	EndIf

Else
	Aviso("SPED","Atenção",{STR0002},3)	//-- "Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
Endif

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSXMLCmp
Monta XML de comprovante de entrega
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSXMLCmp(aDadosCmp,cTipo,cIdEnt,lUsaColab,lReady,aCTe,cHash)
Local aAreas    := {DT6->(GetArea()),SF2->(GetArea()),DLY->(GetArea()),GetArea()}
Local aUF       := {}
Local cCnpj     := SM0->M0_CGC
Local cUF       := Upper(Left(LTrim(SM0->M0_ESTENT),2))
Local cRet      := ""
Local cRetNF    := "" 
Local cDatEnt   := ""
Local cDatHsh   := ""
Local cError    := ""
Local cModel    := "57"
Local cAmbiente := ""
Local dDataEnt  := ""
Local cHoraEnt  := ""
Local cVerLayout:= ""
Local cVerLayEven := ""
Local cVerEven  := ""
Local cCodOrgao := ""
Local cEvento   := ""
Local nCntFor1  := 0
Local nPosUf    := 0
Local lHVerao	:= SuperGetMv("MV_HVERAO",,.F.)

Default aDadosCmp := {}
Default cTipo     := ""
Default cIdEnt    := ""
Default lUsaColab := UsaColaboracao("2")
Default lReady    := .F.

If !Empty(aDadosCmp)

	If lUsaColab
		//-- Dados do CTe
		DT6->(DbSetOrder(18))	//-- DT6_FILIAL + DT6_CHVCTE
		DT6->(DbSeek(xFilial("DT6") + AllTrim(aDadosCmp[1,15])))
		SF2->(DbSetOrder(1))	//-- F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA + F2_FORMUL + F2_TIPO
		SF2->(DbSeek(DT6->(DT6_FILORI + DT6_DOC + DT6_SERIE)))
		aCTe := {SF2->F2_CHVNFE,;	//-- 01-Chave da Nfe
				 SF2->(RECNO()),;	//-- 02-Recno 
				 SF2->F2_SERIE ,;	//-- 03-Serie
				 SF2->F2_DOC}		//-- 04-Cte

		//-- Parâmetros de integração
		cAmbiente   := ColGetPar("MV_AMBICTE","")
		cVerLayout  := ColGetPar("MV_VLAYCTE","3.00")
		cVerLayEven := ColGetPar("MV_EVENCTE","3.00")
		cVerEven    := ColGetPar("MV_LAYOCTE","3.00")

		//-- Sequencia do evento do CTe
		cSeqEven := ColSeqCCe(aCte)
		If cSeqEven == "00"
			cSeqEven := "01"
		EndIf

		//-- Data do Evento
		cDatEve := TMSConvDat(dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2),cIdEnt)

		//-- Tabela do IBGE
		aUf := SpedTabIBGE()

		//-- Codigo do Orgão
		nPosUf := aScan(aUf,{|x| Upper(x[1]) == cUF})
		If nPosUf > 0
			cCodOrgao := aUf[nPosUf][4]
		EndIf

		//-- Montagem do ID do evento
		cEvento := "ID" + Iif(cTipo == "1","110180","110181") + AllTrim(aDadosCmp[1,15]) + cSeqEven

		//-- Monta início do XML
		cRet := '<?xml version="1.0" encoding="UTF-8"?>'
		cRet += '<eventoCTe xmlns="http://www.portalfiscal.inf.br/cte" versao="' + cVerLayEven + '">'
		cRet +=		'<infEvento Id="' + cEvento + '">'
		cRet +=			'<cOrgao>' + cCodOrgao + '</cOrgao>'
		cRet += 		'<tpAmb>' + cAmbiente + '</tpAmb>'
		cRet += 		'<CNPJ>' + cCnpj + '</CNPJ>'
		cRet +=			'<chCTe>' + AllTrim(aDadosCmp[1,15]) + '</chCTe>'
		cRet += 		'<dhEvento>' + cDatEve + '</dhEvento>'
		cRet += 		'<tpEvento>' + Iif(cTipo == "1","110180","110181") + '</tpEvento>'
		cRet += 		'<nSeqEvento>' + cValToChar(Val(cSeqEven)) + '</nSeqEvento>'
		cRet += 		'<detEvento versaoEvento="' + cVerEven + '">'

		//-- Monta corpo do XML
		If cTipo == "1"	//-- Envio do Comprovante de Entrega
			cDatEnt  := TMSConvDat(aDadosCmp[1,19],aDadosCmp[1,20],cIdEnt)
			cDatHsh  := TMSConvDat(dDataBase,SubStr(Time(),1,2) + SubStr(Time(),4,2),cIdEnt)
			cHash    := TMSMntHsh(aDadosCmp[1,15],aDadosCmp[1,18])	//-- Chave eletrônica do CTe e nomer do arquivo de imagem
			cRet += 		'<evCECTe>'
			cRet += 			'<descEvento>' + 'Comprovante de Entrega do CT-e' + '</descEvento>'
			cRet += 			'<nProt>' + AllTrim(DT6->DT6_PROCTE) + '</nProt>'
			cRet += 			'<dhEntrega>' + AllTrim(cDatEnt) + '</dhEntrega>'
			cRet += 			'<nDoc>' + AllTrim(aDadosCmp[1,17]) + '</nDoc>'
			cRet += 			'<xNome>' + AllTrim(aDadosCmp[1,16]) + '</xNome>'
			cRet += 			'<hashEntrega>' + AllTrim(cHash) + '</hashEntrega>'
			cRet += 			'<dhHashEntrega>' + AllTrim(cDatHsh) + '</dhHashEntrega>'
			cRet += 			'<infEntrega>'

			For nCntFor1 := 1 To Len(aDadosCmp)
				If !Empty(aDadosCmp[nCntFor1,14])
					cRet += 		'<chNFe>' + AllTrim(aDadosCmp[nCntFor1,14]) + '</chNFe>'
				EndIf
			Next nCntFor1

			cRet += 			'</infEntrega>'
			cRet += 		'</evCECTe>'

		ElseIf cTipo == "2"	//-- Envio do Cancelamento do Comprovante de Entrega
			DLY->(DbSetOrder(1))
			DLY->(DbSeek(xFilial("DLY") + aDadosCmp[1,1] + aDadosCmp[1,2] + aDadosCmp[1,3] + aDadosCmp[1,4] + DToS(aDadosCmp[1,5]) + ;
										  StrZero(Val(aDadosCmp[1,6]) - 1,Len(DLY->DLY_SEQEVE))))

			cRet += 		'<evCancCECTe>'
			cRet += 			'<descEvento>Cancelamento do Comprovante de Entrega do CT-e</descEvento>'
			cRet += 			'<nProt>' + AllTrim(DT6->DT6_PROCTE) + '</nProt>'
			cRet += 			'<nProtCE>' + AllTrim(DLY->DLY_PROTOC) + '</nProtCE>'
			cRet += 		'</evCancCECTe>'

		EndIf

		cRet += 		'</detEvento>'
		cRet += 	'</infEvento>'
		cRet += '</eventoCTe>'

	Else

		cAmbiente := getCfgAmbiente(@cError, cIdEnt, cModel)

		If Empty(cError)			 
			If cTipo == "1"	//-- Envio do Comprovante de Entrega
				cDatEnt := TMSConvDat(aDadosCmp[1,19],aDadosCmp[1,20],cIdEnt)
				
				//--considerando fusos de cada estado.
				DateTimeFS(/*cUF*/, lHVerao,@dDataEnt,@cHoraEnt)
				cDatHsh := TMSConvDat(dDataBase,cHoraEnt,cIdEnt)

				cHash   := TMSMntHsh(aDadosCmp[1,15],aDadosCmp[1,18])	//-- Chave eletrônica do CTe e nomer do arquivo de imagem
				cRet := "<envEvento>"
				cRet += 	"<eventos>"
				cRet += 		"<detEvento>"
				cRet += 			"<tpEvento>110180</tpEvento>"
				cRet += 			"<chnfe>" + AllTrim(aDadosCmp[1,15]) + "</chnfe>"
				cRet += 			"<ambiente>" + AllTrim(cAmbiente) + "</ambiente>"
				cRet += 			"<comprovanteEntrega>"
				cRet += 				"<docIdent>" + AllTrim(aDadosCmp[1,17]) + "</docIdent>"
				cRet += 				"<dhEntrega>" + AllTrim(cDatEnt) + "</dhEntrega>"
				cRet += 				"<nomeIdent>" + AllTrim(aDadosCmp[1,16]) + "</nomeIdent>"
				cRet += 				"<hashEntrega>" + AllTrim(cHash) + "</hashEntrega>"
				cRet += 				"<dhHashEntrega>" + AllTrim(cDatHsh) + "</dhHashEntrega>"
				
				For nCntFor1 := 1 To Len(aDadosCmp)
					If !Empty(aDadosCmp[nCntFor1,14])
						cRetNF += 	"<nfe>" + AllTrim(aDadosCmp[nCntFor1,14]) + "</nfe>"
					EndIf
				Next nCntFor1
				If !Empty(cRetNF)
					cRet += "<nfes>"
					cRet +=       cRetNF
					cRet += "</nfes>"
				EndIf
				
				cRet += 			"</comprovanteEntrega>"
				cRet += 		"</detEvento>"
				cRet += 	"</eventos>"
				cRet += "</envEvento>"
			ElseIf cTipo == "2"	//-- Envio do Cancelamento do Comprovante de Entrega
				DLY->(DbSetOrder(1))
				DLY->(DbSeek(xFilial("DLY") + aDadosCmp[1,1] + aDadosCmp[1,2] + aDadosCmp[1,3] + aDadosCmp[1,4] + DToS(aDadosCmp[1,5]) + ;
											  StrZero(Val(aDadosCmp[1,6]) - 1,Len(DLY->DLY_SEQEVE))))
				cRet := "<envEvento>"
				cRet += 	"<eventos>"
				cRet += 		"<detEvento>"
				cRet += 			"<tpEvento>110181</tpEvento>"
				cRet += 			"<chnfe>" + AllTrim(aDadosCmp[1,15]) + "</chnfe>"
				cRet += 			"<ambiente>" + AllTrim(cAmbiente) + "</ambiente>"
				cRet += 			"<cancComprovanteEntrega>"
				cRet += 				"<protCE>" + AllTrim(DLY->DLY_PROTOC) + "</protCE>"
				cRet += 			"</cancComprovanteEntrega>"
				cRet += 		"</detEvento>"
				cRet += 	"</eventos>"
				cRet += "</envEvento>"
			EndIf
		EndIf
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

/*/{Protheus.doc} TMSConvDat
Converte data e hora para formato de envio à SEFAZ
@author Valdemar Roberto Mognon
@since 06/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Static Function TMSConvDat(dData,cHora,cIdEnt)
Local cRet      := ""
Local cFuso     := ""

Default dData  := CToD("")
Default cHora  := ""
Default cIdEnt := ""

If !Empty(dData) .And. !Empty(cHora)
	If !Empty(cIdEnt)
		cFuso := StaticCall(SPEDNFE,TZoneUTC,cIdEnt)
	Else
		cFuso := "-00:00"
	EndIf
	
	cRet := SubStr(DToS(dData),1,4) + "-" + SubStr(DToS(dData),5,2) + "-" + SubStr(DToS(dData),7,2) + "T" + SubStr(cHora,1,2) + ":" + ;
			SubStr(cHora,3,2) + ":00" + cFuso
EndIf

Return cRet

/*/{Protheus.doc} TMSConvUTC
Converte data e hora para formato de envio ao App CheckList
@author Rodrigo Pirolo
@since 21/05/2021
@version 12.1.25
@return caracter
@param 
@type function
/*/

Static Function TMSConvUTC(dData,cHora,cIdEnt)

Local cRet      := ""

Default dData  := CToD("")
Default cHora  := ""
Default cIdEnt := ""

If !Empty(dData) .And. !Empty(cHora)
	
	If !(":" $ cHora) .AND. Len(cHora) == 4
		cHora := SubStr( cHora, 1, 2 ) + ":" + SubStr( cHora, 3, 2 ) + ":00"
	EndIf

	cRet := FWTimeStamp(5, dData, cHora)
		
EndIf

Return cRet

/*/{Protheus.doc} TMSRefCmp
Busca status do comprovante de entrega
@author Valdemar Roberto Mognon
@since 07/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSRefCmp(aVetEnv,aVetCan)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local aDLY      := {}
Local lUsaColab := UsaColaboracao("2")
Local cIdEnt    := ""
Local cQuery    := ""
Local cAliasDLY := ""
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)
Local cErro     := ""
Local cAviso    := ""
Local nCntFor1  := 0
Local oWs
Local oDados
Local oMonEvt   := NIL
Local oEvento
Local oXMLRet

//-- Variaveis de retorno Totvs Colaboração
Local cStatEven  := ""
Local cMotEven   := ""
Local cProtocolo := ""
Local cTpEvento  := ""

Default aVetEnv := {}
Default aVetCan := {}

// Verifica se a entidade foi configurada
If CTIsReady(,,,lUsaColab)
	cIdEnt := RetIdEnti(lUsaColab)
EndIf

If !Empty(cIdEnt)

	If lUsaColab

		If !Empty(aVetEnv)
			aVetEnv := ASort(aVetEnv,,,{|x,y| x < y})

			DT6->(DbSetOrder(18))
			
			For nCntFor1 := 1 To Len(aVetEnv)
				FwFreeObj(oEvento)

				If DT6->(DbSeek(xFilial("DT6") + aVetEnv[nCntFor1]))
					oEvento := ColaboracaoDocumentos():new()
					oEvento:cModelo	 := "CEC"
					oEvento:cTipoMov := "1"
					oEvento:cIdErp   := DT6->DT6_SERIE + DT6->DT6_DOC + FWGrpCompany() + FWCodFil()
			
					If oEvento:consultar()
						If !Empty(oEvento:cXMLRet)
							cXmlRet := oEvento:cXMLRet
							oXmlRet := XmlParser(cXmlRet,"_",@cAviso,@cErro)
							If ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO) == "O"
								cStatEven  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT:TEXT)
								cMotEven   := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO:TEXT)
								cProtocolo := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT)
								cTpEvento  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO:TEXT)

								If cTpEvento == "110180"
									//-- Gera novo evento caso ocorra recusa
									If cStatEven != "135"
										cAliasDLY := GetNextAlias()
										cQuery := "SELECT * "
										cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
										cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
										cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' "
										cQuery += "   AND DLY.DLY_STATUS = '3' "
										cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
										cQuery := ChangeQuery(cQuery)
										DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)
		
										TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
										TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
										TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)
		
										While (cAliasDLY)->(!Eof())
											aDLY := {}
											aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
											aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
											aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
											aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
											aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
											aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
											aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
											aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
											aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
											aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
											aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
											aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
											aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
											aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
											aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
											If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
												aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
												aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
												aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
											EndIf
											//-- Inclui os dados na tabela DLY
											TMSIncDLY(aDLY)
											(cAliasDLY)->(DbSkip())
										EndDo
										(cAliasDLY)->(DbCloseArea())
									EndIf

									//-- Atualiza a DLY
									cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
									cQuery += "    SET DLY_STATUS = '" + Iif(cStatEven == "135","4","5") + "', " + CRLF
									cQuery += "        DLY_IDREVE = '" + AllTrim(cStatEven) + "', " + CRLF
									cQuery += "        DLY_RETEVE = '" + PadR(StrTran(cMotEven,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
									cQuery += "        DLY_PROTOC = '" + Iif(cProtocolo == "0","",AllTrim(cProtocolo)) + "' " + CRLF
									cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
									cQuery += "    AND DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' " + CRLF
									cQuery += "    AND DLY_STATUS = '3' "
									cQuery += "    AND D_E_L_E_T_ = ' ' "
									TCSqlExec(cQuery)
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nCntFor1
		EndIf

		If !Empty(aVetCan)
			aVetCan := ASort(aVetCan,,,{|x,y| x < y})

			DT6->(DbSetOrder(18))

			For nCntFor1 := 1 To Len(aVetCan)
				FwFreeObj(oEvento)

				If DT6->(DbSeek(xFilial("DT6") + aVetCan[nCntFor1]))
					oEvento := ColaboracaoDocumentos():new()
					oEvento:cModelo	 := "CEC"
					oEvento:cTipoMov := "1"
					oEvento:cIdErp   := DT6->DT6_SERIE + DT6->DT6_DOC + FWGrpCompany() + FWCodFil()
			
					If oEvento:consultar()
						If !Empty(oEvento:cXMLRet)
							cXmlRet := oEvento:cXMLRet
							oXmlRet := XmlParser(cXmlRet,"_",@cAviso,@cErro)
							If ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT) == "O" .And. ;
							   ValType(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO) == "O"
								cStatEven  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_CSTAT:TEXT)
								cMotEven   := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_XMOTIVO:TEXT)
								cProtocolo := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_NPROT:TEXT)
								cTpEvento  := AllTrim(oXmlRet:_PROCEVENTOCTE:_RETEVENTOCTE:_INFEVENTO:_TPEVENTO:TEXT)

								If cTpEvento == "110181"
									//-- Gera novo evento caso ocorra autorização
									If cStatEven == "135"
										cAliasDLY := GetNextAlias()
										cQuery := "SELECT * "
										cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
										cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
										cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' "
										cQuery += "   AND DLY.DLY_STATUS = '3' "
										cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
										cQuery := ChangeQuery(cQuery)
										DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)
		
										TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
										TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
										TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)
		
										While (cAliasDLY)->(!Eof())
											aDLY := {}
											aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
											aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
											aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
											aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
											aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
											aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
											aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
											aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
											aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
											aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
											aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
											aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
											aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
											aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
											aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
											If !lDM0
												aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
											EndIf
											If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
												aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
												aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
												aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
											EndIf
		
											//-- Inclui os dados na tabela DLY
											TMSIncDLY(aDLY)
											(cAliasDLY)->(DbSkip())
										EndDo
										(cAliasDLY)->(DbCloseArea())
									EndIf
		
									//-- Atualiza a DLY
									cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
									cQuery += "    SET DLY_STATUS = '" + Iif(cStatEven == "135","4","5") + "', " + CRLF
									cQuery += "        DLY_IDREVE = '" + AllTrim(cStatEven) + "', " + CRLF
									cQuery += "        DLY_RETEVE = '" + PadR(StrTran(cMotEven,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
									cQuery += "        DLY_PROTOC = '" + Iif(cProtocolo == "0","",AllTrim(cProtocolo)) + "' " + CRLF
									cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
									cQuery += "    AND DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' " + CRLF
									cQuery += "    AND DLY_STATUS = '3' "
									cQuery += "    AND D_E_L_E_T_ = ' ' "
									TCSqlExec(cQuery)
									//-- Inclui novo registro da DLY para nova tentativa de transmissao
									If cStatEven != "135"
										aRet := TMSVldECmp({},aVetCan[nCntFor1])
										If !Empty(aRet)
											TMSCanECmp(aRet,"1")
										EndIf
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Next nCntFor1
		EndIf
		
	Else

		If !Empty(aVetEnv)
			aVetEnv := ASort(aVetEnv,,,{|x,y| x < y})

			For nCntFor1 := 1 To Len(aVetEnv)
				// Executa o metodo NfeRetornaEvento()
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN	:= "TOTVS"
				oWS:cID_ENT		:= cIdEnt
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cEVENTO		:= "110180"
				oWS:cCHVINICIAL	:= aVetEnv[nCntFor1]
				oWS:cCHVFINAL	:= aVetEnv[nCntFor1]
				lOk := oWS:NFEMONITORLOTEEVENTO()
		
				If lOk		
					// Tratamento do retorno do evento			
					If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U"
	
						oMonEvt := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
						//-- Parece que quando o TSS não está atualizado(Schemas e RPO)
						//-- o objecto wsnfemonitorloteEventoResult vem vazio.
						If Empty(oMonEvt)
							Return Nil
						EndIf

						oDados  := oMonEvt[Len(oMonEvt)]
	
						If oDados:nTipoEvento == 110180
							//-- tag nSTATUS retornada pelo TSS (código interno)
						    // Status 1 - Recebido
							// Status 2 - Assinado
							// Status 3 - Erro, erro de schema
							// Status 4 - Consulta no governo - só foi transmitido
							// Status 5 - Rejeitado pelo governo - transmitido com retorno
							// Status 6 - Autorizado - transmitido com retorno
							If  oDados:nCSTATEVEN != 0 .And. oDados:nCSTATENV != 135 .And. oDados:nSTATUS > 4
								cAliasDLY := GetNextAlias()
								cQuery := "SELECT * "
								cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
								cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
								cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' "
								cQuery += "   AND DLY.DLY_STATUS = '3' "
								cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
								cQuery := ChangeQuery(cQuery)
								DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

								TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
								TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
								TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)

								While (cAliasDLY)->(!Eof())
									aDLY := {}
									aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
									aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
									aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
									aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
									aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
									aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
									aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
									aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
									aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
									aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
									aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
									aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
									aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
									aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
									If !lDM0
										aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
									EndIf
									If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
										aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
										aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
										aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
									EndIf
									//-- Inclui os dados na tabela DLY
									TMSIncDLY(aDLY)
									(cAliasDLY)->(DbSkip())
								EndDo
								(cAliasDLY)->(DbCloseArea())
							EndIf

							//-- Atualiza a DLY
							If oDados:nSTATUS > 4 .And. oDados:nCSTATEVEN != 0
								cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
								cQuery += "    SET DLY_STATUS = '" + Iif(oDados:nCSTATENV == 135,"4","5") + "', " + CRLF
								cQuery += "        DLY_IDREVE = '" + AllTrim(Str(oDados:nCSTATEVEN)) + "', " + CRLF
								cQuery += "        DLY_RETEVE = '" + PadR(StrTran(oDados:cCMOTEVEN,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
								cQuery += "        DLY_PROTOC = '" + Iif(oDados:nPROTOCOLO == 0,"",AllTrim(Str(oDados:nPROTOCOLO))) + "' " + CRLF
								cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
								cQuery += "    AND DLY_CHVCTE = '" + aVetEnv[nCntFor1] + "' " + CRLF
								cQuery += "    AND DLY_STATUS = '3' "
								cQuery += "    AND D_E_L_E_T_ = ' ' "
								TCSqlExec(cQuery)
							EndIf
						
						EndIf
					Endif
				EndIf
            Next nCntFor1

		EndIf

		If !Empty(aVetCan)
			aVetCan := ASort(aVetCan,,,{|x,y| x < y})

			For nCntFor1 := 1 To Len(aVetCan)
				// Executa o metodo NfeRetornaEvento()
				oWS:= WSNFeSBRA():New()
				oWS:cUSERTOKEN	:= "TOTVS"
				oWS:cID_ENT		:= cIdEnt
				oWS:_URL		:= AllTrim(cURL)+"/NFeSBRA.apw"
				oWS:cEVENTO		:= "110181"
				oWS:cCHVINICIAL	:= aVetCan[nCntFor1]
				oWS:cCHVFINAL	:= aVetCan[nCntFor1]
				lOk := oWS:NFEMONITORLOTEEVENTO()
		
				If lOk		
					// Tratamento do retorno do evento			
					If ValType(oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento) <> "U"
	
						oMonEvt := oWS:oWsNfemonitorLoteEventoResult:OWSNfeMonitorEvento
						//-- Parece que quando o TSS não está atualizado(Schemas e RPO)
						//-- o objecto wsnfemonitorloteEventoResult vem vazio.
						If Empty(oMonEvt)
							Return Nil
						EndIf

						oDados  := oMonEvt[Len(oMonEvt)]
	
						If oDados:nTipoEvento == 110181
							If oDados:nCSTATENV == 135
								cAliasDLY := GetNextAlias()
								cQuery := "SELECT * "
								cQuery += "  FROM " + RetSqlName("DLY") + " DLY "
								cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
								cQuery += "   AND DLY.DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' "
								cQuery += "   AND DLY.DLY_STATUS = '3' "
								cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
								cQuery := ChangeQuery(cQuery)
								DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDLY)

								TcSetField(cAliasDLY,"DLY_EMINFC","D",8,0)
								TCSetField(cAliasDLY,"DLY_DATENV","D",8,0)
								TcSetField(cAliasDLY,"DLY_DATENT","D",8,0)

								While (cAliasDLY)->(!Eof())
									aDLY := {}
									aAdd(aDLY, {"DLY_CLIREM", (cAliasDLY)->DLY_CLIREM, Nil })
									aAdd(aDLY, {"DLY_LOJREM", (cAliasDLY)->DLY_LOJREM, Nil })
									aAdd(aDLY, {"DLY_NUMNFC", (cAliasDLY)->DLY_NUMNFC, Nil })
									aAdd(aDLY, {"DLY_SERNFC", (cAliasDLY)->DLY_SERNFC, Nil })
									aAdd(aDLY, {"DLY_EMINFC", (cAliasDLY)->DLY_EMINFC, Nil })
									aAdd(aDLY, {"DLY_STATUS", "2"                    , Nil }) //-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
									aAdd(aDLY, {"DLY_IDREVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_RETEVE", ""                     , Nil })
									aAdd(aDLY, {"DLY_NFEID" , (cAliasDLY)->DLY_NFEID , Nil })
									aAdd(aDLY, {"DLY_CHVCTE", (cAliasDLY)->DLY_CHVCTE, Nil })
									aAdd(aDLY, {"DLY_TIPEVE", "1"                    , Nil }) //-- 1=Envio;2=Cancelamento
									aAdd(aDLY, {"DLY_TIPCAN", "0"                    , Nil }) //-- 0=Não se Aplica;1=Manual;2=Automático
									aAdd(aDLY, {"DLY_DATENT", (cAliasDLY)->DLY_DATENT, Nil })
									aAdd(aDLY, {"DLY_HORENT", (cAliasDLY)->DLY_HORENT, Nil })
									aAdd(aDLY, {"DLY_RECEBE", (cAliasDLY)->DLY_RECEBE, Nil })
									aAdd(aDLY, {"DLY_DOCREC", (cAliasDLY)->DLY_DOCREC, Nil })
									aAdd(aDLY, {"DLY_DIRIMG", (cAliasDLY)->DLY_DIRIMG, Nil })
									If DLY->(ColumnPos("DLY_FILDOC")>0) .And. DLY->(ColumnPos("DLY_DOC")>0) .And. DLY->(ColumnPos("DLY_SERIE")>0)
										aAdd(aDLY, {"DLY_FILDOC", (cAliasDLY)->DLY_FILDOC, Nil })
										aAdd(aDLY, {"DLY_DOC"   , (cAliasDLY)->DLY_DOC   , Nil })
										aAdd(aDLY, {"DLY_SERIE" , (cAliasDLY)->DLY_SERIE , Nil })
									EndIf

									//-- Inclui os dados na tabela DLY
									TMSIncDLY(aDLY)
									(cAliasDLY)->(DbSkip())
								EndDo
								(cAliasDLY)->(DbCloseArea())
							EndIf

							//-- tag nSTATUS retornada pelo TSS (código interno)
						    // Status 1 - Recebido
							// Status 2 - Assinado - Não Transmitiu
							// Status 3 - Erro, erro de schema
							// Status 4 - Consulta no governo
							// Status 5 - Rejeitado pelo governo
							// Status 6 - Autorizado 
							//-- Atualiza a DLY
							If oDados:nSTATUS > 4
								cQuery := " UPDATE " + RetSqlName("DLY") + CRLF
								cQuery += "    SET DLY_STATUS = '" + Iif(oDados:nCSTATENV == 135,"4","5") + "', " + CRLF
								cQuery += "        DLY_IDREVE = '" + AllTrim(Str(oDados:nCSTATEVEN)) + "', " + CRLF
								cQuery += "        DLY_RETEVE = '" + PadR(StrTran(oDados:cCMOTEVEN,"'",""),GetSX3Cache("DLY_RETEVE","X3_TAMANHO")) + "', " + CRLF
								cQuery += "        DLY_PROTOC = '" + Iif(oDados:nPROTOCOLO == 0,"",AllTrim(Str(oDados:nPROTOCOLO))) + "' " + CRLF
								cQuery += "  WHERE DLY_FILIAL = '" + xFilial("DLY") + "' " + CRLF
								cQuery += "    AND DLY_CHVCTE = '" + aVetCan[nCntFor1] + "' " + CRLF
								cQuery += "    AND DLY_STATUS = '3' "
								cQuery += "    AND D_E_L_E_T_ = ' ' "
								TCSqlExec(cQuery)
								//-- Inclui novo registro da DLY para nova tentativa de transmissao
								If oDados:nCSTATENV != 135
									aRet := TMSVldECmp({},aVetCan[nCntFor1])
									If !Empty(aRet)
										TMSCanECmp(aRet,"1")
									EndIf
								EndIf
							EndIf
						EndIf
					Endif
				EndIf
            Next nCntFor1
            
		EndIf

	EndIf
Else
	Aviso("SPED","Atenção",{STR0002},3)	//-- "Execute o módulo de configuração do serviço, antes de utilizar esta opção!!!"
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSMntHsh
Busca status do comprovante de entrega
@author Valdemar Roberto Mognon
@since 07/08/2013
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSMntHsh(cChvCte,cArquivo)
Local nHeader := 0
Local nTam    := 0
Local cBuffer := ""
Local cRet    := ""
Local cBase64 := ""
Local cHash   := ""

Local aAreas  := {}

Default cChvCte  := ""
Default cArquivo := ""

If lDM0
	aAreas := {DM0->(GetArea()),DTC->(GetArea()),DT6->(GetArea()),GetArea()}
EndIf

If !Empty(cChvCte)
	If lDM0	//-- O sistema está gravando a imagem no banco de dados já em base64
		DT6->(DbSetOrder(18))	//-- DT6_FILIAL + DT6_CHVCTE
		If DT6->(DbSeek(xFilial("DT6") + cChvCte))
			DM0->(DbsetOrder(1))
			If DM0->(DbSeek(xFilial("DM0") + DT6->(DT6_FILDOC + DT6_DOC + DT6_SERIE)))
				cBase64 := DM0->DM0_IMAGEM
			EndIf
		EndIf
	EndIf
	
	If !lDM0 .Or. Empty(cBase64)	//-- O sistema está gravando o caminho de onde se localiza o arquivo de imagem
		If !Empty(cArquivo)
			//-- Abre e lê o arquivo de imagem
			nHeader := FOpen(cArquivo)
			//-- Pega o tamanho da imagem 
			nTam := FSeek(nHeader,0,2)
			FSeek(nHeader,0)
			FRead(nHeader,@cBuffer,nTam)
			FClose(nHeader)
		
			cBase64 := Encode64(cBuffer)
		EndIf
	EndIf

	If !Empty(cBase64)	
		//-- Converte imagem para 64 e concatena com a chave eletrônica do CTe
		cBase64 := cChvCte + cBase64

		//-- Gera o SHA1 em binário (não Hexadecimal) 
		cHash := Sha1(cBase64,1) 
	
		//-- Converte o Hash em 64
		cRet := Encode64(cHash)
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

/*/{Protheus.doc} FDocApoio()
	(long_description)
	@type  Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Function FDocApoio(cDocTms)
 Local lResult  := .F.
 //Local aEspecie := {}
 Local cSerie   := ""
 Local cDocFat  := ""
		
		//-- Pesquisa DUI para verificar se o campo DUI_DOCFAT está preenchido
		DUI->(DbSetOrder(1))
		If DUI->(MsSeek(xFilial("DUI") + cDocTms))
			cSerie  := DUI->DUI_SERIE
			cDocFat := DUI->DUI_DOCFAT
		EndIf

		If !Empty(cDocFat)
			lResult := .T.
		//-- Verifica se o tipo do Documento de Transporte for: 'B','C','H','I','N','O'
		//-- Para implementacoes futuras
		// Else
		//  aEspecie := StrTokArr2(SuperGetMv("MV_ESPECIE",,""),";")
		// 	nPos := AScan(aEspecie,{|x| SubStr(x,1,3) $ DT6->DT6_SERIE})
		// 	If nPos = 0
		// 		lEletronico := SubStr(aEspecie[nPos],At("=",aEspecie[nPos])+1) == "CTE"
		// 	EndIf
		EndIf
Return lResult

/*/{Protheus.doc} TMSLstChk
Busca documentos para envio ao aplicativo Meu Check-List
@author Valdemar Roberto Mognon
@since 21/10/2019
@version 12.1.25
@return Array
@param 
@type function
/*/

Function TMSLstChk( cFilOri, cViagem, cCHVCTE, cFilDoc, cDoc, cSerie, aSaiApoio )
Local cQuery    := ""
Local cAliasQry := ""
Local aAreas    := { DTC->(GetArea()) ,GetArea() }
Local aVetNom   := {}

Local cObserv	:= ""
Local nPosCli   := 0
Local nPosDoc   := 0
Local aCliente  := {}

Local lUsaCli   := .T.
Local nQTDVol   := 0
Local cNfsDocs  := ""
Local aParPE    := {}
Local aRetPE    := {}
Local n1, n2

Default cFilOri   := ""
Default cViagem   := ""
Default cCHVCTE   := ""
Default cFilDoc   := ""
Default cDoc	  := ""
Default cSerie	  := ""
Default cSerTms	  := ""
DEFAULT aSaiApoio := {}

lUsaCli := !Empty(TMF10RtVge(cFilOri,cViagem,,,,2))

DTC->( DbSetOrder(3) )

//-- Mapa do vetor aVetNom
//-- 01-Nome do Solicitante/Remetente/Destinatário
//-- 02-Código do Solicitante/Remetente/Destinatário
//-- 03-Loja do Solicitante/Remetente/Destinatário
//-- 04-Vetor com os CTes/Coleta
//-- 04-01-Filial do Documento/Coleta
//-- 04-02-Número do Documento/Coleta
//-- 04-03-Série do Documento/Coleta
//-- 04-04-Chave Eletrônica do CTe/Coleta
//-- 04-05-Vetor com as Notas Fiscais do CTe
//-- 04-06-Observação (Nome/Endereço/QtdVol/Nfs)
//-- 04-07-Tipo de Documento
//-- 04-05-01-Código do Remetente
//-- 04-05-02-Loja do Remetente
//-- 04-05-03-Número da Nota Fiscal
//-- 04-05-04-Série da Nota Fiscal
//-- 04-05-05-Data de Emissão da Nota Fiscal
//-- 04-05-06-Chave Eletrônica da NFe

cAliasQry := GetNextAlias()

cQuery := "SELECT " + CRLF
cQuery += "DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_CHVCTE, DT6.DT6_DOCTMS " + CRLF
If lUsaCli
	cQuery += "FROM " + RetSqlName("DLT") + " DLT " + CRLF
Else
	cQuery += "FROM " + RetSqlName("DUD") + " DUD " + CRLF
EndIf
cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 " + CRLF
cQuery += "  ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' " + CRLF
If lUsaCli
	cQuery += " AND DT6.DT6_FILDOC = DLT.DLT_FILDOC " + CRLF
	cQuery += " AND DT6.DT6_DOC    = DLT.DLT_DOC " + CRLF
	cQuery += " AND DT6.DT6_SERIE  = DLT.DLT_SERIE " + CRLF
Else
	cQuery += " AND DT6.DT6_FILDOC = DUD.DUD_FILDOC " + CRLF
	cQuery += " AND DT6.DT6_DOC    = DUD.DUD_DOC " + CRLF
	cQuery += " AND DT6.DT6_SERIE  = DUD.DUD_SERIE " + CRLF
EndIf
If Len(aSaiApoio) > 0
	cQuery += " AND DT6.DT6_CLIREM = '" + aSaiApoio[1] + "' " + CRLF
	cQuery += " AND DT6.DT6_LOJREM = '" + aSaiApoio[2] + "' " + CRLF
	cQuery += " AND DT6.DT6_DOCTMS <> '1' " + CRLF
ElseIf !Empty(cFilDoc) .And. !Empty(cDoc) .And. !Empty(cSerie)
	cQuery += " AND DT6.DT6_FILDOC = '" + cFilDoc + "' " + CRLF
	cQuery += " AND DT6.DT6_DOC    = '" + cDoc + "' " + CRLF
	cQuery += " AND DT6.DT6_SERIE  = '" + cSerie + "' " + CRLF
ElseIf !Empty(cCHVCTE)
	cQuery += " AND DT6.DT6_CHVCTE = '" + cCHVCTE + "' " + CRLF
EndIf
cQuery += " AND DT6.D_E_L_E_T_ = ' '" + CRLF
If lUsaCli
	cQuery += "WHERE DLT_FILIAL = '" + xFilial("DLT") + "' " + CRLF
	cQuery += "AND DLT_FILORI = '" + cFilOri + "' " + CRLF
	cQuery += "AND DLT_VIAGEM = '" + cViagem + "' " + CRLF
	cQuery += "AND DLT_OPEDOC = '1' " + CRLF
	cQuery += "AND DLT.D_E_L_E_T_ = ' ' " + CRLF
Else
	cQuery += "WHERE DUD_FILIAL = '" + xFilial("DUD") + "' " + CRLF
	cQuery += "AND DUD_FILORI = '" + cFilOri + "' " + CRLF
	cQuery += "AND DUD_VIAGEM = '" + cViagem + "' " + CRLF
	cQuery += "AND DUD.D_E_L_E_T_ = ' ' " + CRLF
EndIf
If Len(aSaiApoio) > 0
	cQuery += "AND NOT EXISTS(SELECT 1 QTDE " + CRLF
	cQuery += "     FROM " + RetSqlName("DM0") + " DM0 " + CRLF
	cQuery += "     WHERE DM0_FILIAL = '" + xFilial("DM0") + "' " + CRLF
	cQuery += "     AND DM0.DM0_FILDOC = DT6.DT6_FILDOC " + CRLF
	cQuery += "     AND DM0.DM0_DOC = DT6.DT6_DOC " + CRLF
	cQuery += "     AND DM0.DM0_SERIE = DT6.DT6_SERIE " + CRLF
	cQuery += "     AND DM0.D_E_L_E_T_ = ' ' ) " + CRLF
EndIf

cQuery += "GROUP BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_CHVCTE, DT6.DT6_DOCTMS " + CRLF
cQuery += "ORDER BY DT6.DT6_FILDOC, DT6.DT6_DOC, DT6.DT6_SERIE, DT6.DT6_CHVCTE, DT6.DT6_DOCTMS " + CRLF

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry )

TcSetField( cAliasQry, "DTC_EMINFC", "D", 8, 0 )

While (cAliasQry)->(!Eof())

	(cAliasQry)->( aCliente := TMSDocEnd( DT6_FILDOC, DT6_DOC, DT6_SERIE )[1] )
    cObserv := "<br><b>"+aCliente[8]+"</b><br>"
	If (cAliasQry)->DT6_DOCTMS == StrZero(1,Len(DT6->DT6_DOCTMS))	//-- É uma coleta
		cObserv += "<i>Local Coleta:</i><br>"
	Else
		cObserv += "<i>Local Entrega:</i><br>"
	EndIf
	cObserv += aCliente[1] + "<br> " + aCliente[2] + "<br>" + aCliente[4] + " - " + aCliente[5] //--  Endereço, bairro, município, estado (retirado o CEP depois do Bairro)

	If ( nPosCli := AScan( aVetNom, {|x| x[2]+x[3] == aCliente[6] + aCliente[7] } ) ) == 0
		AAdd( aVetNom, { aCliente[8], aCliente[6], aCliente[7], {} } ) // Nome Reduzido, Codigo, Loja
		nPosCli := Len(aVetNom)
	EndIf

	(cAliasQry)->( Aadd( aVetNom[nPosCli][4], { DT6_FILDOC, DT6_DOC, DT6_SERIE, DT6_CHVCTE, {}, cObserv, DT6_DOCTMS } ) )
	nPosDoc := Len(aVetNom[nPosCli][4])

	If (cAliasQry)->DT6_DOCTMS == StrZero(1,Len(DT6->DT6_DOCTMS))	//-- Diferente de coleta Busca Notas Fiscais
        aVetNom[nPosCli][4][nPosDoc][6] += "<br><b>Coleta: " + (cAliasQry)->( DT6_DOC + "-" + DT6_SERIE ) + "</b>"
    Else
        aVetNom[nPosCli][4][nPosDoc][6] += "<br><b>Documento: " + (cAliasQry)->( DT6_DOC + "-" + DT6_SERIE ) + "</b>"

		cNfsDocs := ""
		nQTDVol  := 0

		DTC->( MsSeek(xFilial("DTC")+(cAliasQry)->(DT6_FILDOC+DT6_DOC+DT6_SERIE)) )
		While DTC->(!Eof()) .And. xFilial("DTC")+(cAliasQry)->(DT6_FILDOC+DT6_DOC+DT6_SERIE) == DTC->(DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE)
			DTC->( Aadd( aVetNom[nPosCli][4][nPosDoc][5], { DTC_CLIREM,DTC_LOJREM,DTC_NUMNFC,DTC_SERNFC,DTC_EMINFC,DTC_NFEID } ) )
            cNfsDocs += DTC->( DTC_NUMNFC + "/" + DTC_SERNFC + ", " )
			nQTDVol  += DTC->DTC_QTDVOL
			DTC->( DbSkip() )
		EndDo
        aVetNom[nPosCli][4][nPosDoc][6] += "<br><b>Qtd. Volumes Total: " + AllTrim(Str(nQTDVol)) + "</b>"
		aVetNom[nPosCli][4][nPosDoc][6] += "<br><i>NF Cliente: " + cNfsDocs + "</i>"
	EndIf

	(cAliasQry)->(AAdd( aParPE, { DT6_FILDOC, DT6_DOC, DT6_SERIE, aVetNom[nPosCli][4][nPosDoc][6], nPosCli, nPosDoc } ) )
	(cAliasQry)->(DbSkip())

EndDo

If lTMChkObs
	aRetPE := ExecBlock( "TMCHKOBS", .F., .F., AClone(aParPE) )
	If Len(aRetPE) > 0
		For n1 := 1 To Len(aRetPE)
			If ( n2 := AScan( aParPE, {|x| x[1]+x[2]+x[3] == aRetPE[n1][1]+aRetPE[n1][2]+aRetPE[n1][3] } ) ) > 0
				nPosCli := aParPE[n2][5]
				nPosDoc := aParPE[n2][6]
				aVetNom[nPosCli][4][nPosDoc][6] := aRetPE[n1][4]
			EndIf
		Next
	EndIf
EndIf

(cAliasQry)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return Aclone(aVetNom)

/*/{Protheus.doc} TMSEnvChk
Efetua o envio dos CTes para o Check List
@author Valdemar Roberto Mognon
@since 23/10/2019
@version 12.1.25
@return Array
@param 
@type function
/*/

Function TMSEnvChk( aLstChk, cFilOri, cViagem, aMsgChk, aReenvC, lSaiApoio )
Local aHeader   := {}
Local aRet      := {}
Local aAreas    := {DTW->(GetArea()),DA4->(GetArea()),DUP->(GetArea()),DTQ->(GetArea()),GetArea()}
Local aVetCHK   := {}
Local cDatIni   := ""
Local cDatFim   := ""
Local cToken    := ""
Local cIdCHK    := ""
Local cIdObj    := ""
Local cHasScr   := ""
Local cHasScrCol:= ""
Local cHasScrEnt:= ""
Local cHasObj   := ""
Local cHasCHK   := ""
Local cHasExe   := ""
Local cResScr   := ""
Local cResObj   := ""
Local cResCHK   := ""
Local cDocume   := ""
Local nCntFor1  := 0
Local nCntFor2  := 0
Local nRegDTW   := 0
Local oClient   := Nil
Local cDateTime := DtoS(Date()) + SubStr(StrTran(Time(),":",""),1,6)
Local lEnviado  := .F.
Local cRetChec	:= ""

Local lHaveScr  := DLZ->(ColumnPos("DLZ_SCRCOL")) > 0 .And. DLZ->(ColumnPos("DLZ_SCRENT")) > 0
Local lStaDM0   := DM0->(ColumnPos("DM0_STATUS")) > 0
Local cDM0Stat  := StrZero(1,Len(DM0->DM0_STATUS)) 

Default aLstChk := {}
Default cFilOri := ""
Default cViagem := ""
Default aMsgChk := {}
Default aReenvC := {}
DEFAULT lSaiApoio := .F.

If lSaiApoio
	cDM0Stat  := StrZero(3,Len(DM0->DM0_STATUS)) 
EndIf

oClient	:= FwRest():New(  _cURLChk + "/checklist/core/api" )

If Len(aLstChk) > 0 

	//-- Obtém ID do Motorista
	cHasExe		:= GetDriverID( cFilOri , cViagem )

	If Empty(cHasExe)
		MsgAlert(STR0003 + STR0005,STR0004)	//-- "Log in do executor não encontrado."#" Check-List não será gerado."#"Atenção!!!"
	Else

		nRegDTW := Tm351IdDTW(cFilOri,cViagem,2)
		DTW->(DbGoTo(nRegDTW))
	
		cDatIni := TMSConvUTC(dDataBase, Time() )
		cDatFim := TMSConvUTC(DTW->DTW_DATPRE,DTW->DTW_HORPRE)
		//cDatFim := TMSConvDat(DTW->DTW_DATPRE,DTW->DTW_HORPRE)

	
		//+----------------------------------------
		//| Gera Header para consumir a API
		//+----------------------------------------
		cToken := geraTokAPI()

		Aadd(aHeader, 'Content-Type: application/json')
		Aadd(aHeader, 'Authorization: Bearer ' + cToken)

		If lHaveScr
			//-- Gera Script Coleta
			cHasScrCol := TMSGerScr(oClient,@cResScr,aHeader,"COL")
			//-- Gera Script Entrega
			cHasScrEnt := TMSGerScr(oClient,@cResScr,aHeader,"ENT")
		Else
			//-- Gera Script
			cHasScr := TMSGerScr(oClient,@cResScr,aHeader)
		EndIf
	
		For nCntFor1 := 1 To Len(aLstChk)
			For nCntFor2 := 1 To Len(aLstChk[nCntFor1,4])
				If (aLstChk[ nCntFor1, 4, nCntfor2, 7 ] == "1" .And. !Empty(cHasScrCol)) .Or. ;
				   (aLstChk[ nCntFor1, 4, nCntfor2, 7 ] != "1" .And. !Empty(cHasScrEnt)) .Or. !Empty(cHasScr)

					//-- Monta os Identificadores de objetos e do check list
					cDocume := AllTrim(aLstChk[nCntFor1,4,nCntfor2,2]) //Numero documento
					cDocume += StrTran( AllTrim(aLstChk[nCntFor1,4,nCntfor2,3]), " ", "") //Serie sem Espacos
					cIdObj := StrTran( PadR(aLstChk[nCntFor1][1],24 - Len(cDocume),"_"), " ", "_") + "_" //Cliente (NREDUZ) com tamanho variando de acordo com o documento
					cIdObj += cDocume + "_" + cDateTime // Dcumento + YYYYMMDDHHmmss
					cIdCHK := AllTrim(cViagem) + "_" + cDocume + "_" + cDateTime

					//-- Gera Objeto
					cHasObj := TMSGerObj(oClient,cIdObj,@cResObj,aHeader, Iif( aLstChk[ nCntFor1, 4, nCntfor2, 7 ] == "1", "Coleta","Entrega" ) )
					
					If !Empty(cHasObj)
						//-- Gera Check List
						aVetCHK := TMSGerCHK(	oClient, ;
												cIdCHK, ;
												cHasObj, ;
												cDatIni, ;
												cDatFim, ;
												cHasExe, ;
												If( !Empty(cHasScr),cHasScr,Iif(AllTrim(aLstChk[nCntFor1,4,nCntfor2,3]) == "COL",cHasScrCol,cHasScrEnt) ), ;
												@cHasCHK, ;
												@cResCHK, ;
												aHeader, ;
												aLstChk[ nCntFor1, 4, nCntfor2, 1 ], ;
												aLstChk[ nCntFor1, 4, nCntfor2, 2 ], ;
												aLstChk[ nCntFor1, 4, nCntfor2, 3 ], ;
												cFilOri, ;
												cViagem, ;
												@lEnviado, ;
												aLstChk[ nCntFor1, 4, nCntfor2, 6 ],;
												@cRetChec, ;
												lSaiApoio )
						
						Aadd( aMsgChk, {	STR0010 + ;
											aLstChk[nCntFor1,4,nCntfor2,1] + "-" + ;
											aLstChk[nCntFor1,4,nCntfor2,2] + "-" + ;
											aLstChk[nCntFor1,4,nCntfor2,3] + ;
											If( lEnviado, STR0011, STR0012 + STR0022 + cRetChec ) } ) // STR0022 " Mensagem App Checklist: "
						
						If !lEnviado
							
							nPos := AScan( aReenvC, { |x| x[2] + x[3] == aLstChk[nCntFor1,2] + aLstChk[nCntFor1,3] } )

							If nPos == 0
								AAdd( aReenvC, { aLstChk[nCntFor1][1], aLstChk[nCntFor1][2], aLstChk[nCntFor1][3], { AClone( aLstChk[ nCntFor1 ][4][nCntfor2] ) } } )
							Else
								AAdd( aReenvC[nPos][4], AClone( aLstChk[ nCntFor1 ][4][nCntfor2] ) )
							EndIf

							nPos := 0
						EndIf

						If !Empty(aVetCHK)
							Aadd(aVetCHK, { "DM0_FILDOC", aLstChk[nCntFor1,4,nCntfor2,1], Nil } )
							Aadd(aVetCHK, { "DM0_DOC"   , aLstChk[nCntFor1,4,nCntfor2,2], Nil } )
							Aadd(aVetCHK, { "DM0_SERIE" , aLstChk[nCntFor1,4,nCntfor2,3], Nil } )
							If lStaDM0
								Aadd(aVetCHK,{"DM0_STATUS",cDM0Stat,Nil})
							EndIf
							Aadd( aRet, Aclone(aVetCHK) )
						EndIf
						
					EndIf
				EndIf
			Next nCntFor2
		Next nCntFor1
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

/*/{Protheus.doc} TMSVetChk
Monta o vetor base para inclusão da DLY a partir da viagem (TMSA310, TMSA350, Schedule)
@author Valdemar Roberto Mognon
@since 28/10/2019
@version 12.1.25
@return Array
@param 
@type function
/*/

Function TMSVetChk(aDocsChk,cFilOri,cViagem)
Local aRet     := {}
Local aDLY     := {}
Local aVetDoc  := {}
Local aVetNFc  := {}
Local nCntFor1 := 0
Local nCntFor2 := 0
Local nCntFor3 := 0
Local lExist   := .T.
Local dDataEnt := ""
Local cHoraEnt := ""
Local lHVerao	:= SuperGetMv("MV_HVERAO",,.F.)
Local lHasDLYDoc := TableInDic("DLY") .And. DLY->(ColumnPos("DLY_FILDOC")) > 0 .And. DLY->(ColumnPos("DLY_DOC")) > 0 .And. DLY->(ColumnPos("DLY_SERIE")) > 0
Local lHasDLYVia := TableInDic("DLY") .And. DLY->(ColumnPos("DLY_FILORI")) > 0 .And. DLY->(ColumnPos("DLY_VIAGEM")) > 0

Default aDocsChk := {}
Default cFilOri  := ""
Default cViagem  := ""

For nCntFor1 := 1 To Len(aDocsChk)	//-- Cliente
	aVetDoc := aDocsChk[nCntFor1,4]
	For nCntFor2 := 1 To Len(aVetDoc)	//-- Documentos
		aVetNfc := aVetDoc[nCntFor2,5]
		For nCntFor3 := 1 To Len(aVetNfc)	//-- Notas
			If ExistFunc("TMSVerDLY")
				lExist := TMSVerDLY(aVetDoc[nCntFor2,4]) //--cChvCTe
			EndIf

			If !lExist
				aDLY := {}
				//--Valida fuso horario de acordo com a filial logada.
				DateTimeFS(/*cUF*/,lHVerao,@dDataEnt,@cHoraEnt)
				
				Aadd(aDLY,{"DLY_CLIREM",aVetNfc[nCntFor3,1],Nil})
				Aadd(aDLY,{"DLY_LOJREM",aVetNfc[nCntFor3,2],Nil})
				Aadd(aDLY,{"DLY_NUMNFC",aVetNfc[nCntFor3,3],Nil})
				Aadd(aDLY,{"DLY_SERNFC",aVetNfc[nCntFor3,4],Nil})
				Aadd(aDLY,{"DLY_EMINFC",aVetNfc[nCntFor3,5],Nil})
				Aadd(aDLY,{"DLY_STATUS","1"                ,Nil})	//-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
				Aadd(aDLY,{"DLY_IDREVE",""                 ,Nil})
				Aadd(aDLY,{"DLY_RETEVE",""                 ,Nil})
				Aadd(aDLY,{"DLY_NFEID" ,aVetNfc[nCntFor3,6],Nil})
				Aadd(aDLY,{"DLY_CHVCTE",aVetDoc[nCntFor2,4],Nil})
				Aadd(aDLY,{"DLY_TIPEVE","1"                ,Nil})	//-- 1=Envio;2=Cancelamento
				Aadd(aDLY,{"DLY_TIPCAN","0"                ,Nil})	//-- 0=Não se Aplica;1=Manual;2=Automático
				Aadd(aDLY,{"DLY_DATENT",dDataBase          ,Nil})
				Aadd(aDLY,{"DLY_IDINTG",""                 ,Nil})
				Aadd(aDLY,{"DLY_HORENT",cHoraEnt		   ,Nil})
				If lHasDLYDoc
					Aadd(aDLY,{"DLY_FILDOC",aVetDoc[nCntFor2,1],Nil})
					Aadd(aDLY,{"DLY_DOC"   ,aVetDoc[nCntFor2,2],Nil})
					Aadd(aDLY,{"DLY_SERIE" ,aVetDoc[nCntFor2,3],Nil})
				EndIf
				If lHasDLYVia
					Aadd(aDLY,{"DLY_FILORI",cFilOri,Nil})
					Aadd(aDLY,{"DLY_VIAGEM",cViagem,Nil})
				EndIf

				Aadd(aRet,aClone(aDLY))
			EndIf
		Next nCntFor3
	Next nCntFor2
Next nCntFor1

Return aRet

/*/{Protheus.doc} TMSIntChk
Controlador da integração entre TMS e CheckList
@author Daniel Carlos Leme
@since 24/10/2019
@version 12.1.25
@param 
@type function
/*/

Function TMSIntChk(cAcao,aVetDLY)
Local aAreas   := {DLY->(GetArea()),GetArea()}
Local aDocsDLY := {}
Local aDocsDM0 := {}
Local nCntFor1 := 0
Local nRegDLY  := 0
Local nRegDM0  := 0

Default cAcao   := ""
Default aVetDLY := {}

If cAcao == "1"	//-- Inclui registros na DLY a partir do TMSA310(Fechamento da viagem) e TMSA350(Apontamento de operações)
	For nCntFor1 := 1 To Len(aVetDLY)
		aDocsDLY := aVetDLY[nCntFor1]
		TMSIncDLY(Aclone(aDocsDLY),3)
	Next nCntFor1
ElseIf cAcao == "2"	//-- Inclui registros na DLY a partir do TMSA360(Registro de ocorrências)
	TMSIncDLY(Aclone(aVetDLY),3)
ElseIf cAcao == "3"	//-- Exclui registros da DLY
	nRegDLY  := aVetDLY[1,1]
	DLY->(DbGoTo(nRegDLY))
	TMSIncDLY(,5)
ElseIf cAcao == "4"	//-- Altera registros da DLY
	For nCntFor1 := 1 To Len(aVetDLY)
		nRegDLY  := aVetDLY[nCntFor1,1]
		aDocsDLY := aVetDLY[nCntFor1,2]
		If !Empty(aDocsDLY)
			DLY->(DbGoTo(nRegDLY))
			TMSIncDLY(Aclone(aDocsDLY),4)
		EndIf
	Next nCntFor1
ElseIf cAcao == "5"	//-- Altera registros da DM0
	nRegDM0  := aVetDLY[1]
	aDocsDM0 := aVetDLY[2]
	If !Empty(aDocsDM0)
		DM0->(DbGoTo(nRegDM0))
		TMSIncDM0(Aclone(aDocsDM0),4)
	EndIf
ElseIf cAcao == "6"	//-- Inclui registros da DM0
	TMSIncDM0(Aclone(aVetDLY),3)
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

aSize(aDocsDLY,0);aVetDoc := Nil

Return

/*/{Protheus.doc} TMSVerDLY
Verifica a existência do registro na DLY
@author Valdemar Roberto Mognon
@since 28/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVerDLY(cChvCTe,cCliRem,cLojRem,cNumNFc,cSerNFc,dEmiNFc)
Local aAreas := {DLY->(GetArea()),GetArea()}
Local lRet		:= .T.
Local cAlias	:= ""
Local cQuery	:= ""
Default cChvCTe := ""
Default cCliRem := ""
Default cLojRem := ""
Default cNumNFc := ""
Default cSerNFc := ""
Default dEmiNFc := CToD("")

	//-- CHAVE 1 = DLY_FILIAL+DLY_CLIREM+DLY_LOJREM+DLY_NUMNFC+DLY_SERNFC+DTOS(DLY_EMINFC)+DLY_SEQEVE
	//-- CHAVE 2 = DLY_FILIAL+DLY_CHVCTE+DLY_NFEID
	cQuery := "SELECT R_E_C_N_O_ FROM " + RetSqlName("DLY") + " WHERE "
	cQuery += " D_E_L_E_T_ = ' ' "
	cQuery += " AND DLY_FILIAL = '" + xFilial("DLY") + "' "
	cQuery += " AND DLY_CHVCTE = '" + cChvCTe + "' "
	cQuery += " AND DLY_CLIREM = '" + cCliRem + "' "
	cQuery += " AND DLY_LOJREM = '" + cLojRem + "' "
	cQuery += " AND DLY_NUMNFC = '" + cNumNFC + "' "
	cQuery += " AND DLY_SERNFC = '" + cSerNFc + "' "
	cQuery += " AND DLY_EMINFC = '" + DTOS(dEmiNfc) + "' "

	cQuery := ChangeQuery(cQuery)
	cAlias := GetNextAlias()
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	lRet := !(cAlias)->(EOF())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

/*/{Protheus.doc} geraTokAPI()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function geraTokAPI()
Local cToken	:= ""

//-- filial + msblql + id
DLZ->(dbSetOrder(2))
If DLZ->( MsSeek( xFilial("DLZ") + "2" ))
	cToken	:=  TMSChkTok( DLZ->DLZ_ID , DLZ->DLZ_SECRET , DLZ->DLZ_TENANT , DLZ->DLZ_URLTOK , DLZ->DLZ_USER , DLZ->DLZ_PASSW , DLZ->DLZ_SEQUEN )[2]
EndIf

Return cToken 

/*/{Protheus.doc} TMSCHKLIST(cMethod,cPath,cQueryParam)
    (long_description)
    @type  Function
    @author user
    @since date
    @version version
    @param cMethod deve ser GET,POST,DELETE,PUT
    @param cPath informar o caminho da API que contem a função desejada por exemplo. 'checklists/'
    @param cQueryParam String no seguinte formado ?campo1=valor1&campo2=valor2&campo-n=valor-n
    @param nOrder ordem em que os dados serão apresentados ????
    @param nPage numero da pagina para filtro em pesquisa
    @param nPageSize define o tamanho 
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMSCHKLIST(cMethod,cPath,oJBody,cQueryParam,cPathParam,cHTTPCode,nOrder,nPage,nPageSize,cBaseURL,lImagem,lFoundatio,cVersGet)
Local cResJson   := ""

Default cMethod		:= ""
Default cPath		:= ""
Default oJBody   	:= NIL
Default cQueryParam := ""
Default cPathParam	:= ""
Default cHTTPCode	:= ""
Default nOrder		:= 1 
Default nPage		:= 0 
Default nPageSize	:= 0 
Default cBaseURL 	:= ""
Default lImagem     := .F.
Default lFoundatio  := .F.
Default cVersGet    := "v1"

//+--------------------------------------------------------------
//| METODOS GET
//+--------------------------------------------------------------
//| 1 - Consulta Objetos de Checklist
If Upper(cMethod) == "GET"

	cResJson := getChkList(cPath+"/",cQueryParam,cPathParam,cBaseURL,lImagem,lFoundatio,cVersGet)

//+--------------------------------------------------------------
//| METODOS POST
//+--------------------------------------------------------------
ElseIf Upper(cMethod) == "POST"

	cResJson := posChkList(cPath+"/",oJBody,@cHTTPCode,cBaseURL)

//+--------------------------------------------------------------
//| METODOS DELETE
//+--------------------------------------------------------------
ElseIf Upper(cMethod) == "DELETE"

EndIf

Return cResJson

/*/{Protheus.doc} getChkList
    Realiza o GET do Object de Checklist
    para obter uma lista de objetos:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/ 
    para obter um único objeto:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/{checklistId}
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function getChkList(cPath,cQueryParam,cPathParam,cBaseURL,lImagem,lFoundatio,cVersGet)
Local cResult := ""
Local oClient := NIL
Local oJBody  := JsonObject():New()
Local cURL    := ""
Local aHeader := {}
Local cToken  := ""
Local cCompl  := ""

Default cPath       := ""
Default cQueryParam := ""
Default cPathParam  := ""
Default cBaseURL    := ""
Default lImagem     := .F. 
Default lFoundatio  := .F.
DEFAULT cVersGet    := "v1"

cURL := _cURLChk
If lImagem
	cURL += "/storage/core/api/v1/file/"
ElseIf lFoundatio
	cURL += "/foundation/query/api/v1/"
Else
	cURL += "/checklist/query/api/" + cVersGet + "/"
EndIf
If cVersGet == "v2"
	cCompl := "/nonCompliances"
EndIf

//+-------------------------------------------------
//| Define a URL Base
//+-------------------------------------------------
If !Empty(cBaseUrl)
	cURL := cBaseURL
EndIf

//+-------------------------------------------------
//| GetToken - gera a chave de autorização necessária para consumo da API
//+-------------------------------------------------
cToken := geraTokAPI()

//+-------------------------------------------------
//| Definição do tipo de envio JSON ou URLEncode
//+-------------------------------------------------
Aadd(aHeader,"Content-Type: application/json;charset=UTF-8")
Aadd(aHeader,"Authorization: Bearer " + cToken )

//+-------------------------------------------------
//| Setting e Consumo da API
//+-------------------------------------------------
oClient := FwRest():New(cURL)
If !Empty(cQueryParam)
	oClient:SetPath( cPath + "?" + cQueryParam )
ElseIf !Empty( cPathParam )
	oClient:SetPath( cPath + cPathParam + cCompl )
ElseIf Empty( cPathParam )
	oClient:SetPath( cPath )
EndIf

If oClient:Get(aHeader)
	cResult := oClient:GetResult()
Else
	cResult := oClient:GetLastError()
EndIf

FreeObj(oJBody)

Return cResult

/*/{Protheus.doc} posChkList
    Realiza o POST do Object de Checklist
    para obter uma lista de objetos:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/ 
    para obter um único objeto:
    url: https://totvs.logistica.totvs.app/checklist/query/api/v1/checklistObjects/{checklistId}
    @type  Function
    @author user
    @since date
    @version version
    @param cPath : é o apontamento do endpoint 
	@param oJBody: Objeto JSon que contem as informações que serão lançadas no corpo da requisição HTTP POST
	@param cHTTPCode : Retorno do código HTTP Exemplo: 200 sucesso de transmissao; 201 Sucesso de transmissão e processamento. 500-Internal Error etc.
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function posChkList(cPath,oJBody,cHttpCode,cBaseURL)
Local cResult		:= ""
Local oClient		:= NIL
Local cURL			:= _cURLChk + "/checklist/core/api/v1/"
Local aHeader		:= {}
Local cToken		:= ""

Default cPath		:= ""
Default oJBody		:= Nil 
Default cHttpCode	:= ""
Default cBaseURL	:= ""	

//+-------------------------------------------------
//| Define a URL Base
//+-------------------------------------------------
If !Empty(cBaseUrl)
	cURL := cBaseURL
EndIf

//+-------------------------------------------------
//| GetToken - gera a chave de autorização necessária para consumo da API
//+-------------------------------------------------
cToken := geraTokAPI()

//+-------------------------------------------------
//| Definição do tipo de envio JSON ou URLEncode
//+-------------------------------------------------
Aadd(aHeader,"Content-Type: application/json;charset=UTF-8")
Aadd(aHeader,"Authorization: Bearer " + cToken )

//+-------------------------------------------------
//| Setting e Consumo da API
//+-------------------------------------------------
oClient := FwRest():New(cURL)
oClient:SetPath( cPath )
oClient:SetPostParams(oJBody:toJson())
If oClient:Post(aHeader)
	cResult   := oClient:GetResult()
	cHttpCode := HTTPGetStatus(cHttpCode)
Else
	cResult := oClient:GetLastError()
EndIf

FreeObj(oJBody)

Return cResult

/*/{Protheus.doc} TMSMovImg
Move e renomeia imagens para gravação na DLY
@author Felipe Barbiere	
@since 25/10/2019
@version 12.1.25
@return Logico
@param Estrutura aVetImg
		[1]FILDOC
		[2]DOC
		[3]SERIE
		[4]EXTENSAO DA IMAGEM - Ex. ".JPG"
		[5]BINARIO DA IMAGEM
@type function
/*/
Function TMSMovImg(aVetImg)
Local nCont  	:= 0
Local lRet  	:= .T.
Local aVetDLY   := {}
Local aAreas    := {}
Local nRecnoDLY := 0
Local lDM0 		:= TableIndic("DM0")

Local cImgVinc  := SuperGetMV("MV_TMSIMGC",.F.,"")
Local cPastaDef := "COMPR_ENTREGA"
Local cPath 	:=""
Local nArquivo 	:= 0

Default aVetImg := {}

If lDM0
	aAreas    := { DM0->(GetArea()),GetArea() }
EndIf

If Empty(aVetImg)
	Return .F.
EndIf

If !lDM0
	If IsSrvUnix()
		cPastaDef += "/" 
	Else
		cPastaDef += "\" 
	EndIf
	If !ExistDir(cPastaDef)     
		MakeDir(cPastaDef)
	EndIf
	If Empty(cImgVinc)
		cImgVinc := cPastaDef
	EndIf
	For nCont := 1 to Len(aVetImg)
		If DT6->(DbSeek(xFilial("DT6")+aVetImg[nCont][1]+aVetImg[nCont][2]+aVetImg[nCont][3])) .And. !Empty(DT6->DT6_CHVCTE);
			.And. DT6->DT6_SITCTE == "2"
			cPath := cImgVinc + "CTe_" + DT6->DT6_CHVCTE + Iif(SubStr(aVetImg[nCont][4],1,1) <> ".",".","") + aVetImg[nCont][4]
			nRecnoDLY := TMSUltDLY(DT6->DT6_CHVCTE)
			If nRecnoDLY > 0			
				If File(cPath)
					If FERASE(cPath) < 0
						lRet := .F.
					EndIf
				EndIf
				
				nArquivo := FCREATE(cPath)
				If nArquivo >= 0
					FWrite(nArquivo, aVetImg[nCont][5])
					FClose(nArquivo)
					Aadd(aVetDLY,{nRecnoDLY,{{"DLY_DIRIMG",cPath,Nil}}})
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf	
	Next nCont
	If !Empty(aVetDLY)
		TMSIntChk("4",aVetDLY)
	EndIf
Else
	DM0->(DbSetOrder(1))
	For nCont := 1 to Len(aVetImg)
		If DM0->(DbSeek(xFilial("DM0") + aVetImg[nCont,1] + aVetImg[nCont,2] + aVetImg[nCont,3]))
			Aadd(aVetDLY,{{"DM0_EXTENS",aVetImg[nCont,4],Nil}, ;
						  {"DM0_IMAGEM",aVetImg[nCont,5],Nil}})
		EndIf
		If !Empty(aVetDLY)
			TMSIntChk("5",{DM0->(Recno()),aVetDLY})
		EndIf
	Next nCont
	aEval(aAreas,{|xArea| RestArea(xArea)})
EndIf

Return lRet

/*/{Protheus.doc} TMSUltDLY
Retorna o ultimio RECNO da DLY em array de acordo com a chave do CTE
@author Felipe Barbiere	
@since 29/10/2019
@version 12.1.25
@return Logico
@param Chave do CTE e Status da DLY (Padrão 0)
@type function
/*/
Function TMSUltDLY(cChaveCTe, cStatusDLY)
Local aAreas    := {GetArea()}
Local cQuery 	:= ""
Local nRecnoDLY	:= 0
Local cAliasQry := GetNextAlias()

Default cChaveCTe  := ""
Default cStatusDLY := "0"

cQuery := " SELECT MAX(R_E_C_N_O_) DLY_RECNO"
cQuery += " FROM " + RetSqlName("DLY") + " DLY "
cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "'"
cQuery += "   AND DLY.DLY_CHVCTE = '" + cChaveCTe + "'"
cQuery += "   AND DLY.DLY_STATUS = '" + cStatusDLY + "'"
cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof()) .And. !Empty((cAliasQry)->DLY_RECNO)
	nRecnoDLY := (cAliasQry)->DLY_RECNO
EndIf
(cAliasQry)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return nRecnoDLY

/*/{Protheus.doc} TMSGerScr
Cria o script automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSGerScr(oClient,cResult,aHeader,cTipDoc)
Local oItems as Object
Local cRet    	:= ""
Local cDescrScr := ""
Local cTitleScr := ""

Default cTipDoc     := ""

//+----------------------------------------
//| Verifica se o Script Existe
//+----------------------------------------
cRet := TMSVerScr(@oItems,cTipDoc,@cDescrScr,@cTitleScr)

If !Empty(cRet)
	cRet := oItems[1]["id"]
EndIf

Return cRet

/*/{Protheus.doc} TMSGerObj
Cria o objeto automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/
Static Function TMSGerObj(oClient,cIdObj,cResult,aHeader,cLabelComp)
Local cRet        	:= ""
Local oBody			:= Nil
Local oItems		:= Nil
Local cHttpCode		:= ""
Local cVerChk       := ""
Local cFilExt       := ""

Default oClient		:= Nil
Default cIdObj		:= ""
Default cResult		:= ""
Default aHeader		:= {} 
Default cTipDoc     := ""
DEFAULT cLabelComp  := "Entrega"

//+----------------------------------------
//| Verifica se o Objeto Existe
//+----------------------------------------
cRet := TMSVerObj(cIdObj,@oItems)

If !Empty(cRet)
	cRet := oItems[1]["id"]
	cResult := cIdObj
Else
	//+----------------------------------------
	//| Montagem do Objeto CTe
	//+----------------------------------------
	oBody := JSonObject():New()
	oBody["categoryClass"] := "STANDARD"
	oBody["customId"]      := cIdObj
	oBody["description"]   := "Comprovante_de_"+cLabelComp
	If TMSChkVer2( @cVerChk, @cFilExt )
		oBody["branchId"] := cFilExt
	EndIf

	oClient:SetPath( "/" + cVerChk + "/checklistObjects/" )
	oClient:SetPostParams(oBody:toJson())
	
	If oClient:Post(aHeader)
	    cResult  := oClient:GetResult()
		If HTTPGetStatus(@cHttpCode) == 201
			cRet := TMSVerObj(cIdObj,@oItems)
		EndIf
		If !Empty(oItems)
			cRet := oItems[1]["id"]
		EndIf
	Else
	    cResult := oClient:GetLastError()
	EndIf
EndIf

Return cRet

/*/{Protheus.doc} TMSGerCHK
Cria o Check List automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSGerCHK(oClient,cIdCHK,cHasObj,cDatIni,cDatFim,cHasExe,cHasScr,cHasCHK,cResult,aHeader,cFilDoc,cDoc,cSerie,cFilOri,cViagem,lEnviado,cObserv,cRetChec, lSaiApoio)
Local cRet        := ""
Local cStatus     := ""
Local aRet        := {}
Local oBody		  := NIL
Local oItems	  := NIL
Local cHTTPCode   := ""

Default oClient		:= Nil
Default cIdCHK		:= ""
Default cHasObj		:= ""
Default cDatIni		:= ""
Default cDatFim		:= ""
Default cHasExe		:= ""
Default cHasScr		:= ""
Default cHasCHK		:= ""
Default cResult		:= ""
Default aHeader		:= {} 
Default cFilDoc	  	:= ""
Default cDoc	  	:= ""
Default cSerie	  	:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
Default lEnviado    := .F.
Default cObserv		:= ""
Default cRetChec	:= ""
DEFAULT lSaiApoio   := .F.

//+----------------------------------------
//| Verifica se o Check List Existe
//+----------------------------------------
cRet := TMSVerCHK( cIdCHK, @oItems, @cStatus )

If Empty(cRet) .OR. ( !Empty(cRet) .AND. cStatus == "CANCELED" )
	//+----------------------------------------
	//| Montagem do Check List Viagem
	//+----------------------------------------
	oBody := JSonObject():New()
	oBody["checklistCustomId"]		:= cIdCHK
	oBody["checklistObjectId"]		:= cHasObj
	oBody["creationDateReference"]	:= cDatIni
	oBody["executorId"]				:= cHasExe
	oBody["observation"]			:= PadR( EncodeUtf8( cObserv, ), 600 )
	//oBody["periodEnd"]			:= "2021-02-24T18:18:16.059Z"
	//oBody["periodStart"]			:= "2021-02-24T18:18:16.059Z"
	oBody["scriptId"]				:= cHasScr
	
	oClient:SetPath( "/v1/checklist/" )
	oClient:SetPostParams(oBody:toJson())

	If oClient:Post(aHeader)
	    cResult := oClient:GetResult()
		
		If HTTPGetStatus(@cHttpCode) == 201 //--Checklist created successfully.
			cResult := TMSVerCHK(cIdCHK,@oItems,@cStatus)
		Else
			lEnviado := .F.
		EndIf
	
		If !Empty(oItems)
		 	cHasCHK := oItems[1]["checklistId"]
		Else
			cHasCHK	:= ""
		EndIf

		If lDM0
			Aadd(aRet,{"DM0_IDINTG",cHasCHK,Nil})
			Aadd(aRet,{"DM0_INIINT",cDatIni,Nil})
			Aadd(aRet,{"DM0_FIMINT",cDatFim,Nil})
		EndIf

		//-- Atualiza DM0
		If lDM0
			AtuDM0Int( cFilDoc, cDoc , cSerie , cHasCHK , cDatIni, cDatFim , cFilOri , cViagem, lSaiApoio  )
			lEnviado := .T.
		EndIf
	Else
	    cResult := oClient:GetResult()
		cRetChec := cResult
		lEnviado := .F.
	EndIf
Else
	If !Empty(oItems)
		cHasCHK := oItems[1]["checklistId"]
	EndIf
	
	If lDM0
		Aadd(aRet,{"DM0_IDINTG",cHasCHK,Nil})
	EndIf

	lEnviado := .T.
EndIf

Return aRet

/*/{Protheus.doc} TMSCanChk
Estorno do check list no Estorno do Fechamento da Viagem ou Saída da Filial verificando o parâmetro MV_TMINTEV
@author Fabio Marchiori Sampaio
@since 28/10/2019
@version 12.1.25
@return Undefined
@param 
@type function
/*/
Function TMSCanChk(cChkCustId, cFilOri, cViagem, cObserv )
Local aHeader     := {}
Local cToken      := ""
Local cHasChk     := ""
Local cStatus     := ""
Local nCntFor1    := 0
Local oClient
Local oBody		
Local oItems
Local lIs310350		:= FwIsInCallStack('TMSA310EST') .OR. ( FwIsInCallStack('TMSA350Grv') .AND. FwIsInCallStack('EstDocChk') )

Default cChkCustId 	:= ""
Default dDataDe    	:= ""
Default dDataAte   	:= ""
Default cFilOri    	:= ""
Default cViagem    	:= ""
Default cObserv		:= "Comprovante de Entrega Cancelado"

cIdCHK := AllTrim(cViagem)

//+----------------------------------------
//| Verifica se o Check List Existe
//+----------------------------------------
cRet := TMSVerCHK(cIdCHK,@oItems,@cStatus, cChkCustId)

If ValType(oItems) == "A" .And. !Empty(oItems)

	For nCntFor1 := 1 To Len(oItems)
		
		cStatus	:= oItems[nCntFor1]["status"]

		If ValType(cStatus) == "J" 
			cStatus	:= oItems[nCntFor1]["status"]["id"]
		EndIf

		If ( cStatus == "CANCELED" .OR. cStatus == "PENDING" ) .AND. lIs310350

			cHasChk := oItems[nCntFor1]["checklistId"]
			aHeader	:= {} 

			//+----------------------------------------
			//| Montagem do Objeto CTe
			//+----------------------------------------
			oBody := JSonObject():New()
			oBody["observation"] := cObserv

			//+----------------------------------------
			//| Gera Header para consumir a API
			//+----------------------------------------
			cToken := geraTokAPI()
			Aadd(aHeader, 'Content-Type: application/json')
			Aadd(aHeader, 'Authorization: Bearer ' + cToken)

			oClient := FwRest():New( _cURLChk + "/checklist/core/api/" )
			oClient:SetPath( "/v1/checklist/" + cHasChk + "/cancel/" )
			oClient:SetPostParams(oBody:toJson())
			
			If oClient:Post(aHeader)

				cResult := oClient:GetResult()

				//-- Excluir DM0
				If lDM0

					DelDM0( cHasChk , cFilOri , cViagem )
				EndIf

			Else
				cResult := oClient:GetLastError()
			EndIf

			FwFreeArray(aHeader)

		EndIf
				
	Next nCntFor1
EndIf

Return

/*/{Protheus.doc} TMSChkDLY
Pega o cheklist da DLY
@author Fabio Marchiori Sampaio
@since 28/10/2019
@version 12.1.25
@return Undefined
@param 
@type function
/*/

Function TMSChkDLY(cChaveCTe)
Local aRet      := {}
Local aResult   := {}
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

Local lTemIni   := DLY->(ColumnPos("DLY_INIINT")) > 0
Local lTemVia   := DLY->(ColumnPos("DLY_FILORI")) > 0
Local lTemDM0   := TableInDic("DM0")
Local lCont     := .T.

Default cChaveCTe := ""

cQuery := " SELECT DLY.R_E_C_N_O_ DLY_RECNO , DLY.DLY_IDINTG DLY_IDINTG, DLY.DLY_DATENT DLY_DATENT, DLY.DLY_HORENT DLY_HORENT "
If lTemIni
	cQuery += "   ,DLY.DLY_INIINT DLY_INIINT, DLY.DLY_FIMINT DLY_FIMINT "
EndIf
If lTemVia
	cQuery += "   ,DLY.DLY_FILORI DLY_FILORI, DLY.DLY_VIAGEM DLY_VIAGEM "
EndIf
cQuery += "       ,DT6.DT6_FILDOC DT6_FILDOC, DT6.DT6_DOC    DT6_DOC   , DT6.DT6_SERIE  DT6_SERIE , DT6.DT6_CHVCTE DT6_CHVCTE "
If lTemDM0
	cQuery += "   ,DM0.DM0_IDINTG DM0_IDINTG, DM0.DM0_INIINT DM0_INIINT, DM0.DM0_FIMINT DM0_FIMINT "
EndIf

cQuery += "        FROM " + RetSqlName("DLY") + " DLY "

cQuery += "        JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += " 	     ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += " 	    AND DT6.DT6_CHVCTE = DLY.DLY_CHVCTE "
cQuery += " 	    AND DT6.D_E_L_E_T_ = ' ' "

If lTemDM0
	cQuery += "    JOIN " + RetSqlName("DM0") + " DM0 "
	cQuery += " 	 ON DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
	cQuery += " 	AND DM0.DM0_FILDOC = DT6.DT6_FILDOC "
	cQuery += " 	AND DM0.DM0_DOC    = DT6.DT6_DOC "
	cQuery += " 	AND DM0.DM0_SERIE  = DT6.DT6_SERIE "
	cQuery += "     AND DM0.DM0_IDINTG <> ' ' "
	cQuery += "     AND DM0.DM0_EXTENS = ' ' "
	cQuery += " 	AND DM0.D_E_L_E_T_ = ' ' "
EndIf

cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
cQuery += "   AND DLY.DLY_CHVCTE <> ' ' "
If !Empty(cChaveCTe)
	cQuery += "   AND DLY.DLY_CHVCTE = '" + cChaveCTe + "' "
EndIf
cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
	lCont := !Empty((cAliasQry)->DLY_IDINTG)
	If !lCont .And. lTemDM0
		lCont := !Empty((cAliasQry)->DM0_IDINTG)
	EndIf

	If lCont
		aRet := {}
		Aadd(aRet, (cAliasQry)->DLY_RECNO)												//-- [1] Numero do RECNO
		Aadd(aRet, Iif(!Empty((cAliasQry)->DLY_IDINTG),(cAliasQry)->DLY_IDINTG,(cAliasQry)->DM0_IDINTG))	//-- [2] Id do Cheklist - não é o customId e sim o checklistId retornado pela API
		Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [3] Data Inicio
		Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [4] Data Ate
		Aadd(aRet, Iif(lTemVia,(cAliasQry)->DLY_FILORI,"") ) //-- [5] Filial Origem Viagem
		Aadd(aRet, Iif(lTemVia,(cAliasQry)->DLY_VIAGEM,"") ) //-- [6] Numero da Viagem
		If DLY->(ColumnPos("DLY_INIINT")) > 0
			Aadd(aRet, (cAliasQry)->DLY_INIINT ) //-- [7] equivalente ao planningDateFrom
			Aadd(aRet, (cAliasQry)->DLY_FIMINT ) //-- [8] equivalente ao planningDateUntil
		Else
			Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [7] Data Inicio
			Aadd(aRet, TMSConvDat(stod((cAliasQry)->DLY_DATENT),(cAliasQry)->DLY_HORENT)) 	//-- [8] Data Ate
		EndIf
		Aadd(aRet, (cAliasQry)->DT6_FILDOC ) //-- [9 ] Filial Documento
		Aadd(aRet, (cAliasQry)->DT6_DOC    ) //-- [10] Numero Documento
		Aadd(aRet, (cAliasQry)->DT6_SERIE  ) //-- [11] Série  Documento
		Aadd(aRet, (cAliasQry)->DT6_CHVCTE ) //-- [12] chave do documento eletronico
		//-- Adiciona vetor a matriz.
		AADD(aResult,aClone(aRet))
	EndIf

	//-- Next Record
	(cAliasQry)->(DbSkip())
EndDo
(cAliasQry)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aResult


/*/{Protheus.doc} TMSCLOcor
Executa o apontamento da ocorrência via TMSA360
@author Felipe Barbiere	
@since 31/10/2019
@version 12.1.25
@param Estrutura aVetOcor
		[1]Chave do CT-e
		[2]DATA OCORRENCIA
		[3]HORA OCORRENCIA
		[4]FILORI VIAGEM
		[5]NUMERO VIAGEM
		[6]Filial de Origem do Documento
		[7]Número do Documento
		[8]Série do Documento
@return Logico
@type function
/*/
Function TMSCLOcor(aVetOcor)
Local cQuery   	:= ""
Local cAliasQry	:= ""
Local aItens   	:= {}
Local aCab		:= {}
Local cOcorEnt 	:= SuperGetMV( 'MV_OCORENT',.F., '' )
Local cOcorCol 	:= SuperGetMV( 'MV_OCORCOL',.F., '' )
Local nCont 	:= 0
Local nLenCont	:= 0
Local nDecQTD	:= TamSX3("DUA_PESOCO")[2]
Local nPeso		:= 0
Local nVolOri	:= 0

Private lMsErroAuto := .F.

Default aVetOcor := {}

If !Empty(cOcorEnt) .And. !Empty(aVetOcor)
	
	For nCont := 1 To Len( aVetOcor )
 	 	//-- Cabecalho da Ocorrencia
		Aadd( aCab, { 'DUA_FILORI', aVetOcor[nCont][4], NIL } )
		Aadd( aCab, { 'DUA_VIAGEM', aVetOcor[nCont][5], NIL } )
		
		If nCont == 1
			nLenCont := Len( aVetOcor[nCont] )
 		EndIf

		cAliasQry := GetNextAlias()

		cQuery := "SELECT DT6_FILDOC,DT6_DOC,DT6_SERIE,DT6_VOLORI,DT6_PESO,DT6_SERTMS "
		cQuery += "  FROM " + RetSqlName("DT6") + " DT6 "
		cQuery += " WHERE DT6_FILIAL = '" + xFilial ("DT6") + "' "
		cQuery += "   AND DT6_FILDOC = '" + aVetOcor[nCont,6] + "' "
		cQuery += "   AND DT6_DOC    = '" + aVetOcor[nCont,7] + "' "
		cQuery += "   AND DT6_SERIE  = '" + aVetOcor[nCont,8] + "' "
		cQuery += "   AND DT6.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)
		
		While (cAliasQry)->(!Eof())
			If (cAliasQry)->DT6_SERTMS == "1"

				If nLenCont == 10 .AND. aVetOcor[ nCont, 9 ] > 0
					nPeso	:= NoRound( aVetOcor[ nCont, 9 ], nDecQTD )
				Else
					nPeso	:= 1
				EndIf

				If nLenCont == 10 .AND. aVetOcor[ nCont, 10 ] > 0
					nVolOri	:= aVetOcor[ nCont, 10 ]
				Else
					nVolOri	:= 1
				EndIf
				
			Else
				nVolOri	:= (cAliasQry)->DT6_VOLORI
				nPeso	:= (cAliasQry)->DT6_PESO
			EndIf

			aAdd( aItens, {	;
				 {"DUA_SEQOCO", StrZero(1,Len(DUA->DUA_SEQOCO)) , NIL},;
		         {"DUA_DATOCO", CToD(aVetOcor[nCont][2])		, NIL},;
		         {"DUA_HOROCO", aVetOcor[nCont][3]				, NIL},;
		         {"DUA_CODOCO", If( (cAliasQry)->DT6_SERIE == "COL", cOcorCol, cOcorEnt ), NIL },;
				 {'DUA_SERTMS', (cAliasQry)->DT6_SERTMS         , Nil},;
		         {"DUA_FILDOC", (cAliasQry)->DT6_FILDOC			, NIL},;
		         {"DUA_DOC"   , (cAliasQry)->DT6_DOC			, NIL},;
		         {"DUA_SERIE" , (cAliasQry)->DT6_SERIE			, NIL},;
		         {"DUA_QTDOCO", nVolOri							, NIL},;
		         {"DUA_PESOCO", nPeso							, NIL},;
		         {"DUA_ORIGEM", "TMSAE71"						, NIL}})
			(cAliasQry)->(DbSkip())
		EndDo

		MsExecAuto( { | x,y,z | Tmsa360( x, y, z ) }, aCab, aItens, {}, 3 )
		
		If lMsErroAuto
			If !IsBlind()
				MostraErro()
			EndIf
		EndIf

		aCab := {}
		aItens := {}
		(cAliasQry)->(DbCloseArea())
	Next nCont
EndIf

Return .T.

/*/{Protheus.doc} TMSLeExec
Verifica a existência do objeto e o cria automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/
Function TMSLeExec(  )

Local cQueryParam := ""
Local aRet        := {}
Local nCount      := 0
Local oResult     := Nil
Local cVerChk     := ""
Local cFilExt     := ""
Local cResult     := ""

If TMSChkVer2( @cVerChk, @cFilExt )
	cQueryParam	+= "branchId="+cFilExt+""
EndIf
cQueryParam	+= "&pageSize=500"
cResult := TMSCHKLIST( "GET", "executors", , cQueryParam,,,,,,,,, cVerChk )

If FWJsonDeserialize( cResult, @oResult )
	If AttIsMemberOf( oResult, "items" )
		For nCount := 1 To Len( oResult:items )
			AAdd( aRet, { DeCodeUTF8( oResult:items[nCount]:FULLNAME ), oResult:items[nCount]:ExternalUserID, oResult:items[nCount]:ID } )
		Next nCount
		ASort(aRet,,,{|x,y| x[1] < y[1]})
	EndIf
EndIf

FwFreeObj(oResult)

Return aRet

/*/{Protheus.doc} TMSVerScr
Verifica a existência do script
@author Valdemar Roberto Mognon
@since 05/11/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/
Static Function TMSVerScr(oItems,cTipDoc,cDescrScr,cTitleScr)
Local cQueryParam := ""
Local cRet        := ""
Local cResult     := ""
Local oJSonRes
Local lHaveScr    := DLZ->(ColumnPos("DLZ_SCRCOL")) > 0 .And. DLZ->(ColumnPos("DLZ_SCRENT")) > 0
Local cVerChk     := ""
Local cFilExt     := ""

Default oItems		:= Nil
Default cTipDoc     := ""

//+----------------------------------------
//| Verifica se o Script Existe
//+----------------------------------------
If lHaveScr
	cDescrScr := GetScrChk(cTipDoc)
	cTitleScr := cDescrScr
Else
	cDescrScr := "Data de Entrega"
	cTitleScr := "Data_Entrega"
EndIf

If TMSChkVer2( @cVerChk, @cFilExt )
	cQueryParam	+= "branchId="+cFilExt+"&"
EndIf
cQueryParam += "searchTerm=" + cTitleScr

cResult  := TMSCHKLIST( "GET", "scripts",, cQueryParam,,,,,,,,, cVerChk )

oJSonRes := JsonObject():New()
oJSonRes:fromJSon(cResult)

oItems   := oJSonRes["items"]

If !Empty(oItems)
	cRet := oItems[1]["title"]
EndIf

Return cRet

/*/{Protheus.doc} TMSVerObj
Verifica a existência do objeto
@author Valdemar Roberto Mognon
@since 05/11/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVerObj(cIdObj,oItems)
Local cQueryParam := ""
Local cRet        := ""
Local cResult     := ""
Local oJSonRes
Local cVerChk     := ""
Local cFilExt     := ""

Default cIdObj	:= ""
Default oItems	:= Nil

//+----------------------------------------
//| Verifica se o Objeto Existe
//+----------------------------------------
If TMSChkVer2( @cVerChk, @cFilExt )
	cQueryParam	+= "branchId="+cFilExt+"&"
EndIf
cQueryParam += "customId=" + cIdObj

cResult  := TMSCHKLIST( "GET", "checklistObjects",, cQueryParam,,,,,,,,, cVerChk )

oJSonRes := JsonObject():New()
oJSonRes:fromJSon(cResult)

oItems   := oJSonRes["items"]
If !Empty(oItems)
	cRet := oItems[1]["customId"]
EndIf

Return cRet

/*/{Protheus.doc} TMSVerCHK
Verifica a existência do check list e o cria automaticamente
@author Valdemar Roberto Mognon
@since 30/10/2019
@version 12.1.25
@return Logico
@param 
@type function
/*/

Function TMSVerCHK(cCustomID,oItems,cStatus,cIdCHK)
Local cQueryParam := ""
Local cRet        := ""
Local cIniPsq     := ""
Local cFimPsq     := ""
Local cResult     := ""
Local oJSonRes
Local cPathParam  := ""
Local cVerChk     := ""
Local cFilExt     := ""

Default	cCustomID	:= ""
Default oItems		:= Nil
Default cStatus		:= ""
Default cIdCHK		:= ""

//+----------------------------------------
//| Verifica se o Check List Existe
//+----------------------------------------
cIniPsq := TMSConvDat(dDataBase - 182,"0000") //MEIO ANO ANTES DA DATABASE
cFimPsq := TMSConvDat(dDataBase + 182,"2359") //MEIO ANO DEPOIS DA DATABASE

If TMSChkVer2( @cVerChk, @cFilExt )
	cQueryParam	+= "branchId="+cFilExt+"&"
EndIf
If Empty(cIdCHK)
	cQueryParam += "checklistCustomId=" + RTrim(cCustomID)
	cQueryparam += "&planningDateFrom=" + cIniPsq
	cQueryParam += "&planningDateUntil="+ cFimPsq
Else
	cQueryParam += "checklistCustomId=" + Padr( RTrim(cCustomID), TamSx3('DTQ_VIAGEM')[1] )
	cQueryparam += "&planningDateFrom=" + cIniPsq
	cQueryParam += "&planningDateUntil="+ cFimPsq
	cPathParam := RTrim(cIdCHK)
EndIf

cResult  := TMSCHKLIST( "GET", "checklists",, cQueryParam, cPathParam,,,,,,,, cVerChk)

oJSonRes := JsonObject():New()
oJSonRes:fromJSon(cResult)

oItems   := oJSonRes["items"]

If !Empty(oItems)
	cRet    := oItems[1]["checklistCustomId"]
	cStatus := oItems[1]["status"]
Else

	oItems	:= { oJsonRes }

	cRet    := oItems[1]["checklistCustomId"]
		
	If ValType(oItems[1]["status"]) == "J"
		cStatus	:= oItems[1]["status"]["id"]
	Else
		cStatus := oItems[1]["status"]
	EndIf

EndIf

Return cRet

/*/{Protheus.doc} DateTimeFS
	Retorna a data
	@type  Function
	@author Tiago dos Santos
	@since 25/11/2019 
	@version 12.1.25
	@param  cUF	   , char,	 UF da filial emissora (default obtem pela região cadastrada no parametro MV_CDRORI)
			lHVerao, logic,	 informa se a hora está em horario de verão (default obtem do cadastro de parâmetro MV_TMSHRVR)
			@cData , Date,	 Retorno da data por referência
			@cHora , char,   Retorno da hora por referência
	@return não há retorno
/*/
Function DateTimeFS(cUF,lHVerao,cData,cHora)
 Local aAreaDUY		:= DUY->(GetArea())
 Local aDataBase	:= {}

 Default cUF		:= ""
 Default lHVerao	:= SuperGetMV("MV_TMSHRVR",,.F.) //-- Define se encontra-se no periodo de horario de verao.

//-- Obtém a UF da filial de emissão
If Empty(cUF)
	cUF := Posicione("DUY",1,xFilial("DUY") + SuperGetMV("MV_CDRORI" ,,"" ),"DUY_EST")
EndIf
If	FindFunction("FwTimeUF")
	aDataBase	:= FwTimeUF(cUF,,lHVerao)
	cData		:= STOD(aDataBase[1])
	cHora		:= StrTran(Left(aDataBase[2],5),':','')
EndIf

RestArea(aAreaDUY)

Return Nil

/*/{Protheus.doc} TMSCmpTrb
Cria Arquivo de Trabalho para Filtrar pelo Painel de Agendamentos/Viagem
@author Valdemar Roberto Mognon
@since 30/03/2020
@version 12.1.28
@return Logico
@param 
@type function
/*/

Function TMSCmpTrb(oTempTable,cAlias,cTableName)
Local aStruct := {}

//-- Cria estrutura do arquivo de trabalho
AAdd(aStruct,{"TRB_FILDOC","C",FWGETTAMFILIAL,0})
AAdd(aStruct,{"TRB_DOC"   ,"C",TamSX3("DT6_DOC")[1],0})
AAdd(aStruct,{"TRB_SERIE" ,"C",TamSX3("DT6_SERIE")[1],0})

cArqTrb := GetNextAlias()
oTempTable:= FWTemporaryTable():New()
oTempTable:SetFields(aStruct)
oTempTable:AddIndex("01",{"TRB_FILDOC","TRB_DOC","TRB_SERIE"} )
oTempTable:Create()

cAlias     := oTempTable:GetAlias()
cTableName := oTempTable:GetRealName()

Return

/*/{Protheus.doc} TMSCmpGrv
Grava Arquivo de Trabalho para Filtrar pelo Painel de Agendamentos/Viagem
@author Valdemar Roberto Mognon
@since 30/03/2020
@version 12.1.28
@return Logico
@param 1=Viagem / 2=Painel de Agendamentos
       Filial de Origem da Viagem
       Numero da Viagem
       Arquivo de Trabalho
@type function
/*/

Function TMSCmpGrv(nAcao,cFilOri,cViagem,cArqTrb,aAgends)
Local cQuery    := ""
Local cAliasDUD := ""
Local nCntFor1  := 0
Local aAreas    := {DF1->(GetArea()),DTC->(GetArea()),GetArea()}
Local aCab      := {}
Local aItens    := {}

Default nAcao   := 0
Default cFilOri := ""
Default cViagem := ""
Default cArqTrb := ""
Default aAgends := {}

If nAcao == 1	//-- Viagem
	If !Empty(cFilOri) .And. !Empty(cViagem)
		cAliasDUD := GetNextAlias()
		cQuery := "SELECT DISTINCT DUD_FILDOC,DUD_DOC,DUD_SERIE "

		cQuery += "  FROM " + RetSqlName("DUD") + " DUD "

		cQuery += "  JOIN " + RetSqlName("DUA") + " DUA "
		cQuery += "    ON DUA_FILIAL = '" + xFilial("DUA") + "' "
		cQuery += "   AND DUA_FILDOC = DUD_FILDOC "
		cQuery += "   AND DUA_DOC    = DUD_DOC "
		cQuery += "   AND DUA_SERIE  = DUD_SERIE "
		cQuery += "   AND DUA.D_E_L_E_T_ = ' ' "

		cQuery += "  JOIN " + RetSqlName("DT2") + " DT2 "
		cQuery += "    ON DT2_FILIAL = '" + xFilial("DT2") + "' "
		cQuery += "   AND DT2_CODOCO = DUA_CODOCO "
		cQuery += "   AND DT2_CMPENT = '1' "
		cQuery += "   AND DT2.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUD_FILORI = '" + cFilOri + "' "
		cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDUD)

		(cArqTrb)->(DbSetOrder(1))
		While (cAliasDUD)->(!Eof())
			RecLock((cArqTrb),.T.)
			(cArqTrb)->TRB_FILDOC := (cAliasDUD)->DUD_FILDOC
			(cArqTrb)->TRB_DOC    := (cAliasDUD)->DUD_DOC
			(cArqTrb)->TRB_SERIE  := (cAliasDUD)->DUD_SERIE
			(cArqTrb)->(MsUnlock())
			(cAliasDUD)->(DbSkip())
		EndDo
		(cAliasDUD)->(DbCloseArea())
	EndIf
ElseIf nAcao == 2	//-- Painel de Agendamentos
	aCab   := StrTokArr(StrTran(aAgends[1],"'",""),",")
	aItens := StrTokArr(StrTran(aAgends[2],"'",""),",")
	DF1->(DbSetOrder(1))
	DTC->(DbSetOrder(8))
	For nCntFor1 := 1 To Len(aCab)
		If DF1->(DbSeek(xFilial("DF1") + aCab[1] + aItens[1]))
			If DTC->(DbSeek(xFilial("DTC") + DF1->(DF1_FILDOC + DF1_DOC)))
				While DTC->(!Eof()) .And. DTC->(DTC_FILIAL + DTC_FILORI + DTC_NUMSOL) == DF1->(DF1_FILIAL + DF1_FILDOC + DF1_DOC)
					If !Empty(DTC->DTC_DOC)
						RecLock((cArqTrb),.T.)
						(cArqTrb)->TRB_FILDOC := DTC->DTC_FILDOC
						(cArqTrb)->TRB_DOC    := DTC->DTC_DOC
						(cArqTrb)->TRB_SERIE  := DTC->DTC_SERIE
						(cArqTrb)->(MsUnlock())
					EndIf
					DTC->(DbSkip())
				EndDo
			EndIf
		EndIf
	Next nCntFor1
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return

/*/{Protheus.doc} TMSCmpDel
Deleta Arquivo de Trabalho que Filtra pelo Painel de Agendamentos/Viagem
@author Valdemar Roberto Mognon
@since 30/03/2020
@version 12.1.28
@return Logico
@param 
@type function
/*/

Function TMSCmpDel(oTempTable)

If !Empty(oTempTable)
	oTempTable:Delete()	
EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} TMSIncDM0()
Inclui o registro na DM0 de acordo com o array passado

@author Felipe Barbiere
@since 16/04/2020
-----------------------------------------------------------/*/
Function TMSIncDM0(aDados,nOpcx)
Local nCntFor	:= 0
Local aAreaDM0	:= DM0->(GetArea())
Local aArea		:= GetArea()
// Salva bloco de código do tratamento de erro
Local oError := ErrorBlock( { |e| FunHError( e, DM0->( RECNO() ), aDados ) } )

Default aDados := {}
Default nOpcx  := 0

If lDM0
	If nOpcx == 3	//-- Inclusao
		For nCntFor := 1 To Len(aDados)
			RecLock("DM0",.T.)
				DM0->DM0_FILIAL := xFilial("DM0")
				aEval(aDados[nCntFor],{|x| Iif(!(AllTrim(x[1]) $ "DM0_FILIAL"),DM0->(FieldPut(FieldPos(x[1]),x[2])),Nil)})
			DM0->(MsUnlock())
		Next nCntFor1
	ElseIf nOpcx == 4	//-- Alteraçao
		Begin Sequence
			RecLock("DM0",.F.)
				aEval(aDados[1],{|x| Iif(!(AllTrim(x[1]) $ "DM0_FILIAL"),DM0->(FieldPut(FieldPos(x[1]),x[2])),Nil)})
			DM0->(MsUnlock())
		End Sequence
		ErrorBlock(oError)
	EndIf
EndIf

RestArea(aArea)
RestArea(aAreaDM0)

Return Nil

/*/-----------------------------------------------------------
{Protheus.doc} TMSChkTok()
Obtém Token do APP Meu Check-List

@author Caio Murakami
@since 16/04/2020
@version 1.0
-----------------------------------------------------------/*/
Function TMSChkTok( cId , cSecret , cAcrValues , cUrlTok , cUser , cPassword , cSequen )
Local oCheck  		:= TMSBCAMeuChecklist():New()  
Local lRet			:= .T. 

Default cID			:= ""
Default cSecret		:= ""
Default cAcrValues	:= ""
Default cUrlTok		:= ""
Default cUser		:= ""
Default cPassword	:= ""
Default cSequen		:= ""

If !Empty(cUrlTok) .And. Right(AllTrim(cUrlTok),1) != "/"
	cUrlTok := AllTrim(cUrlTok) + "/"
EndIf

cResult	:= oCheck:GetToken( cUrlTok,  cId , cSecret , cAcrValues , cUser , cPassword , cSequen ) 

If Empty(cResult)
	lRet	:= .F. 
	cResult	:= oCheck:GetLastError()
Endif

FwFreeObj(oCheck)

Return { lRet , cResult }


/*{Protheus.doc} TMSListE
Realiza a consulta no serviço do Meu Checklist pelos executores
@author Rodrigo.Pirolo
@since 17/04/2020
@version 12
*/

Function TMSListE()
Local aExec		As Array
Local oDlg		As Object
Local oListBox	As Object
Local lRet := .F.

If TMSDLZAti() // Verifica se existe parametro de CheckList Ativo
	aExec  := TMSLeExec()
	If Len(aExec) > 0
		DEFINE MSDIALOG oDlg TITLE STR0006 FROM 180, 180 TO 530, 910 PIXEL // STR0006 "Meu Check List - Executores"
			@ 005, 005 LISTBOX oListBox FIELDS HEADER STR0007, STR0008, STR0009 SIZE 360, 150 OF oDlg PIXEL //STR0007 "Nome" STR0008 "External ID" STR0009 "ID"
			oListBox:SetArray( aExec )
			oListBox:bLine := { | | { 	aExec[oListBox:nAt][1], aExec[oListBox:nAt][2], aExec[oListBox:nAt][3] } }
			DEFINE SButton FROM 160, 300 TYPE 1 ENABLE OF oDlg ACTION ( lRet := .T., Var_IXB := aExec[oListBox:nAt][3], oDlg:End() )
			DEFINE SButton FROM 160, 335 TYPE 2 ENABLE Of oDlg ACTION oDlg:End()
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} TMSDLZAti
Verifica se existe parametro de CheckList Ativo
@author Rodrigo.Pirolo
@since 17/04/2020
@version 12
/*/
Function TMSDLZAti() As Logical
Local aArea		As Array
Local aAreaDLZ	As Array
Local lRet		As Logical

If TableInDic("DLZ") .And. lDM0
	aArea    := GetArea()
	aAreaDLZ := DLZ->(GetArea())
	lRet     := .F.
	DLZ->( DbSetOrder(2) )	
	If DLZ->( DbSeek( xFilial("DLZ") + "2" ) )
		lRet := .T.
	EndIf
	RestArea(aAreaDLZ)
	RestArea(aArea)
Else
	lRet := .F. 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetURLChk
Obtém a partir da tabela DLZ o endereço de comunicação com o Meu-Check-List

@author Caio Murakami
@since 30/04/2020
@version 12
@return Logico
@param 
@type function
/*/
//-------------------------------------------------------------------
Static Function GetURLChk()
Local cUrl		:= ""
Local aArea		:= {} 

If TableInDic("DLZ")
	aArea	:= DLZ->(GetArea())

	DLZ->(dbSetOrder(2))
	If DLZ->( MsSeek(xFilial("DLZ") + "2" ) )
		cUrl	:= RTrim(DLZ->DLZ_URLCHK)

		If RAt("/",cUrl) == Len(cUrl)
			cUrl	:= SubStr( cUrl , 1 , Len(cUrl) - 1 )
		EndIf

	EndIf

	RestArea(aArea)
EndIf

Return cUrl

//--------------------------------------------------------------------
/*/{Protheus.doc} GetScrChk
Realiza a busca do ID do roteiro do checklist
@author Valdemar Roberto Mognon
@since 10/10/2020
@version 12.1.28
@return Logico
@param Tipo de documento
@type function
/*/
//--------------------------------------------------------------------
Function GetScrChk(cTipDoc)
Local cRet   := ""
Local aAreas := {DLZ->(GetArea()),GetArea()}

Default cTipDoc := ""

If TableInDic("DLZ")
	DLZ->(DbSetOrder(2))
	If DLZ->(DbSeek(xFilial("DLZ") + "2"))
		cRet := AllTrim(Iif(cTipDoc == "COL",DLZ->DLZ_SCRCOL,DLZ->DLZ_SCRENT))
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return cRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AtuDM0Int()

Atualiza o ID Integração com a tabela DM0

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Function AtuDM0Int( cFilDoc, cDoc , cSerie , cIdInt , cIniInt, cFimInt , cFilOri, cViagem, lSaiApoio )
Local lRet			:= .T. 
Local aAreas        := {DM0->(GetArea()),DT6->(GetArea()),GetArea()}
Local cDMStatus     := StrZero(1,Len(DM0->DM0_STATUS))

Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cIdInt		:= ""
Default cIniInt		:= ""
Default cFimInt		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""
DEFAULT lSaiApoio   := .F.

If lSaiApoio
	cDMStatus := StrZero(3,Len(DM0->DM0_STATUS))
EndIf

//-- FILDOC+DOC+SERIE
DM0->(dbSetOrder(1))
If !DM0->( MsSeek( xFilial("DM0") + cFilDoc + cDoc + cSerie ))
	RecLock("DM0",.T.)
	DM0->DM0_FILIAL := xFilial("DM0")
	DM0->DM0_FILDOC := cFilDoc
	DM0->DM0_DOC    := cDoc
	DM0->DM0_SERIE  := cSerie
	DM0->DM0_STATUS := cDMStatus
	DM0->DM0_IDINTG := cIdInt
	DM0->DM0_INIINT := cIniInt
	DM0->DM0_FIMINT := cFimInt
	DM0->( MsUnlock())
EndIf

//-- Atualiza a DLY
If cSerie != "COL"
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie)) .And. !Empty(DT6->DT6_CHVCTE) .And. !DT6->DT6_DOCTMS $ "5,D,F,G"
		AtuDLYInt( cFilOri, cViagem , cFilDoc, cDoc , cSerie , cIdInt , cIniInt, cFimInt )
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DelDM0()

Apaga ID de integração na DM0

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Function DelDM0( cIdInt , cFilOri , cViagem )
Local aAreas    := {DM0->(GetArea()),DT6->(GetArea()),GetArea()}
Local lRet		:= .T. 
Local cFilDoc	:= ""
Local cDoc		:= ""
Local cSerie	:= ""
Local lDM0Pos	:= DM0->(FieldPos("DM0_IDMPOS")) > 0

Default cIdInt		:= ""
Default cFilOri		:= ""
Default cViagem		:= ""

DM0->(dbSetOrder(2)) //-- ID CHK
If DM0->( MsSeek( xFilial("DM0") + RTrim(cIdInt) ) )
	
	cFilDoc		:= DM0->DM0_FILDOC
	cDoc		:= DM0->DM0_DOC
	cSerie		:= DM0->DM0_SERIE
	
	If lDM0Pos .AND. !Empty(DM0->DM0_IDMPOS)
 		TMSDelDAV(DM0->DM0_IDMPOS)
	EndIf

	RecLock("DM0",.F.)
		DM0->( dbDelete() )
	DM0->(MsUnlock())
Else
	lRet	:= .F. 
Endif

If lRet .And. cSerie != "COL"
	DT6->(DbSetOrder(1))
	If DT6->(DbSeek(xFilial("DT6") + cFilDoc + cDoc + cSerie)) .And. !Empty(DT6->DT6_CHVCTE) .And. !DT6->DT6_DOCTMS $ "5,D,F,G"
		DelDLY( cFilOri, cViagem , cFilDoc , cDoc , cSerie )
	EndIf
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AtuDLYInt()

Atualiza o ID Integração com a tabela DLY

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function AtuDLYInt( cFilOri, cViagem , cFilDoc, cDoc , cSerie , cIdInt , cIniInt, cFimInt )
Local lRet		:= .T. 
Local aArea		:= GetArea()
Local aAreaDLY	:= DLY->(GetArea())
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local aRet		:= {}
Local aDLY		:= {}
Local nCount	:= 1
Local nOpcx		:= 3 
Local lDLYDOC	:= DLY->(FieldPos("DLY_FILDOC")) > 0 .AND. DLY->(FieldPos("DLY_DOC")) > 0 .AND. DLY->(FieldPos("DLY_SERIE")) > 0
Local nPosIdIn	:= 0
Local nPosIni	:= 0
Local nPosFim	:= 0

Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""
Default cIdInt		:= ""
Default cIniInt		:= ""
Default cFimInt		:= ""

cQuery	:= " SELECT DT6_CHVCTE , DTC_CLIREM , DTC_LOJREM , DTC_NUMNFC , DTC_SERNFC , DTC_EMINFC, DTC_NFEID "
cQuery	+= " FROM " + RetSqlName("DUD") +  " DUD "
cQuery	+= " INNER JOIN " + RetSqlName("DT6") + " DT6 "
cQuery	+= " ON DT6_FILIAL 			= '" + xFilial("DT6") + "' "
cQuery	+= " 	AND DT6_FILDOC		= DUD_FILDOC "
cQuery	+= " 	AND DT6_DOC			= DUD_DOC "
cQuery	+= " 	AND DT6_SERIE		= DUD_SERIE "
cQuery	+= " 	AND DT6.D_E_L_E_T_ 	= '' "
cQuery	+= " INNER JOIN " + RetSqlName("DTC") + " DTC " 
cQuery	+= "	ON DTC_FILIAL 	= '" + xFilial("DTC") + "' "
cQuery	+= " 	AND DTC_FILDOC		= DT6_FILDOC "
cQuery	+= " 	AND DTC_DOC			= DT6_DOC "
cQuery	+= " 	AND DTC_SERIE		= DT6_SERIE "
cQuery	+= " 	AND DTC.D_E_L_E_T_ = '' "
cQuery	+= " WHERE DUD_FILIAL 		= '" + xFilial("DUD") + "' "
cQuery	+= " 	AND DUD_FILORI		= '" + cFilOri	+ "' " 
cQuery	+= "	AND DUD_VIAGEM		= '" + cViagem + "' "
cQuery	+= " 	AND DUD_FILDOC		= '" + cFilDoc + "' "
cQuery	+= " 	AND DUD_DOC			= '" + cDoc + "' "
cQuery	+= " 	AND DUD_SERIE		= '" + cSerie + "' "
cQuery	+= " 	AND DUD.D_E_L_E_T_ = '' "

cQuery	:= ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

//-- Transforma para tipo Data
TCSetField(cAliasQry,"DTC_EMINFC","D",8,0)
	
While (cAliasQry)->( !Eof() )

	aDLY	:= {} 

	Aadd(aDLY,{"DLY_CLIREM", (cAliasQry)->DTC_CLIREM	,Nil})
	Aadd(aDLY,{"DLY_LOJREM", (cAliasQry)->DTC_LOJREM	,Nil})
	Aadd(aDLY,{"DLY_NUMNFC", (cAliasQry)->DTC_NUMNFC	,Nil})
	Aadd(aDLY,{"DLY_SERNFC", (cAliasQry)->DTC_SERNFC	,Nil})
	Aadd(aDLY,{"DLY_EMINFC", (cAliasQry)->DTC_EMINFC	,Nil})
	Aadd(aDLY,{"DLY_STATUS","1"                			,Nil})	//-- 1=Não Apto;2=Apto;3=Transmitido;4=Autorizado;5=Rejeitado
	Aadd(aDLY,{"DLY_IDREVE",""                 			,Nil})
	Aadd(aDLY,{"DLY_RETEVE",""                 			,Nil})
	Aadd(aDLY,{"DLY_NFEID" , (cAliasQry)->DTC_NFEID 	,Nil})
	Aadd(aDLY,{"DLY_CHVCTE", (cAliasQry)->DT6_CHVCTE 	,Nil})
	Aadd(aDLY,{"DLY_TIPEVE", "1"                		,Nil})	//-- 1=Envio;2=Cancelamento
	Aadd(aDLY,{"DLY_TIPCAN", "0"                		,Nil})	//-- 0=Não se Aplica;1=Manual;2=Automático
	Aadd(aDLY,{"DLY_DATENT", dDataBase          		,Nil})
	Aadd(aDLY,{"DLY_IDINTG", cIdInt             		,Nil})
	Aadd(aDLY,{"DLY_HORENT", SubStr(Time(),1,2) + SubStr(Time(),4,2) ,Nil})
	If lDLYDOC
		Aadd(aDLY,{"DLY_FILDOC", cFilDoc					,Nil})
		Aadd(aDLY,{"DLY_DOC"   , cDoc						,Nil})
		Aadd(aDLY,{"DLY_SERIE" , cSerie						,Nil})
	EndIf
	Aadd(aDLY,{"DLY_FILORI", cFilOri					,Nil})
	Aadd(aDLY,{"DLY_VIAGEM", cViagem					,Nil})
	Aadd(aDLY,{"DLY_INIINT", cIniInt					,Nil})
	Aadd(aDLY,{"DLY_FIMINT", cFimInt					,Nil})

	Aadd( aRet, aClone(aDLY) )
	
	(cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->( dbCloseArea() )

If Len(aRet) > 0
	nPosIdIn:= AScan( aRet[1], { |x| x[1] == "DLY_IDINTG" } )
	nPosIni	:= AScan( aRet[1], { |x| x[1] == "DLY_INIINT" } )
	nPosFim	:= AScan( aRet[1], { |x| x[1] == "DLY_FIMINT" } )
	DLY->( dbSetOrder(1) )
	//-- Realiza inclusão na DLY
	For nCount := 1 To Len( aRet )
		
		//-- DLY_FILIAL+DLY_CLIREM+DLY_LOJREM+DLY_NUMNFC+DLY_SERNFC+DTOS(DLY_EMINFC)+DLY_SEQEVE
		
		If DLY->( MsSeek( xFilial("DLY") + aRet[nCount][1,2] + aRet[nCount][2,2] + aRet[nCount][3,2] + aRet[nCount][4,2] + DToS(aRet[nCount][5,2])) )
			nOpcx 	:= 4
			If Empty(aRet[nCount][nPosIdIn][2])    //Se vier em branco do TMSA360 inclui valores no array direto da tabela
				aRet[nCount][nPosIdIn][2] := AllTrim(DLY->DLY_IDINTG)
			EndIf

			If Empty(aRet[nCount][nPosIni][2])	
				aRet[nCount][nPosIni][2] := AllTrim( DLY->DLY_INIINT)
			EndIf
			
			If Empty(aRet[nCount][nPosFim][2])	
				aRet[nCount][nPosFim][2] := Alltrim(DLY->DLY_FIMINT)
			EndIf

		Else
			nOpcx	:= 3 
		EndIf

		//-- Grava DLY
		TMSIncDLY( aClone(aRet[nCount]) ,nOpcx )

	Next nCount
EndIf
//-- Libera memória de array
FwFreeArray(aDLY)
FwFreeArray(aRet)

//-- Restaura áreas
RestArea( aAreaDLY )
RestArea( aArea )
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DelDLY()

Excluir DLY

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function DelDLY( cFilOri, cViagem , cFilDoc , cDoc , cSerie )
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()
Local lDLYDOC	:= DLY->(FieldPos("DLY_FILDOC")) > 0 .AND. DLY->(FieldPos("DLY_DOC")) > 0 .AND. DLY->(FieldPos("DLY_SERIE")) > 0

Default cFilOri		:= ""
Default cViagem		:= ""
Default cFilDoc		:= ""
Default cDoc		:= ""
Default cSerie		:= ""

cQuery	:= " SELECT DLY.R_E_C_N_O_  RECNODLY "
cQuery	+= " FROM " + RetSqlName("DLY") + " DLY "
cQuery	+= " WHERE DLY_FILIAL 		= '" + xFilial("DLY") + "' "
cQuery	+= " 	AND DLY_FILORI		= '" + cFilOri + "' "
cQuery	+= " 	AND DLY_VIAGEM		= '" + cViagem + "' "
If lDLYDOC
	cQuery	+= " 	AND DLY_FILDOC		= '" + cFilDoc + "' "
	cQuery	+= " 	AND DLY_DOC			= '" + cDoc + "' "
	cQuery	+= " 	AND DLY_SERIE		= '" + cSerie + "' "
EndIf
cQuery	+= " 	AND DLY.D_E_L_E_T_ 	= '' "

cQuery	:= ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

While (cAliasQry)->( !Eof() )
	
	//-- Excluir DLY
	DLY->(DbGoTo( (cAliasQry)->RECNODLY ))
	TMSIncDLY(,5)

	(cAliasQry)->( dbSkip() )
EndDo


(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDriverID()

Obtém ID do motorista

@author Caio Murakami
@since 07/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function GetDriverID( cFilOri, cViagem )
Local cHasExe	:= ""
Local aAreas  := {DA4->(GetArea()),DLZ->(GetArea()),DTQ->(GetArea()),DUP->(GetArea()),GetArea()}
Local oColEnt

DTQ->(DbSetOrder(2))
DTQ->(DbSeek(xFilial("DTQ") + cFilOri + cViagem))

DUP->(DbSetOrder(1))
DUP->(DbSeek(xFilial("DUP") + cFilOri + cViagem))

If FindFunction("BSCIDMOT") .And. FindFunction("TMSAC30") .And. AliasInDic("DN0")
	oColEnt := TMSBCACOLENT():New("DLZ")
	If oColEnt:DbGetToken()
		DLZ->(DbGoTo(oColEnt:config_recno))
		cHasExe := AllTrim(BscIDMot(DUP->DUP_CODMOT,DLZ->DLZ_CODFON,.T.))
	EndIf
Else
	DA4->(DbSetOrder(1))
	DA4->(DbSeek(xFilial("DA4") + DUP->DUP_CODMOT))
	cHasExe := RTrim(DA4->DA4_APPLOG)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return cHasExe

//--------------------------------------------------------------------
/*/{Protheus.doc} TMSImgDM0
Verifica se existe imagem gravada na tabela de imagens do Check List
@author Valdemar Roberto Mognon
@since 30/04/2020
@version 12.1.28
@return Logico
@param Chave eletronica do CTe
@type function
/*/
//--------------------------------------------------------------------
Function TMSImgDM0(cFilDoc,cDoc,cSerie)
Local lRet   := .F.
Local aAreas := {DM0->(GetArea()),GetArea()}

DM0->(DbSetOrder(1))
If DM0->(DbSeek(xFilial("DM0") + cFilDoc + cDoc + cSerie)) .And. !Empty(DM0->DM0_EXTENS)
	lRet := .T.
EndIf

aEval(aAreas,{|xArea| RestArea(xArea)})

Return lRet

/*/{Protheus.doc} TMSChkDM0
Pega o cheklist da DM0
@author Valdemar Roberto Mognon
@since 10/10/2020
@version 12.1.25
@return Undefined
@param 
@type function
/*/

Function TMSChkDM0()
Local aRet      := {}
Local aVetWrk   := {}
Local aAreas    := {DUD->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDM0 := ""
Local nRecDUD   := ""

cAliasDM0 := GetNextAlias()
cQuery := " SELECT DM0.R_E_C_N_O_ DM0_RECNO, DM0.DM0_IDINTG DM0_IDINTG, DM0.DM0_DATREA DM0_DATREA, DM0.DM0_HORREA DM0_HORREA "
cQuery += 		" ,DT6.DT6_FILDOC DT6_FILDOC, DT6.DT6_DOC DT6_DOC, DT6.DT6_SERIE DT6_SERIE, DT6.DT6_CHVCTE DT6_CHVCTE, DT6.DT6_CDRDES DT6_CDRDES "
cQuery += "   FROM " + RetSqlName("DM0") + " DM0 "
cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "     ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
cQuery += "    AND DT6.DT6_FILDOC = DM0.DM0_FILDOC "
cQuery += "    AND DT6.DT6_DOC    = DM0.DM0_DOC "
cQuery += "    AND DT6.DT6_SERIE  = DM0.DM0_SERIE "
cQuery += "    AND DT6.D_E_L_E_T_ = ' ' "
cQuery += "  WHERE DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
cQuery += "    AND DM0.DM0_IDINTG <> ' ' "
cQuery += "    AND DM0.DM0_EXTENS = ' ' "
cQuery += "    AND ( DM0.DM0_STATUS = '" + StrZero(1,Len(DM0->DM0_STATUS)) + "' OR DM0.DM0_STATUS = '" + StrZero(3,Len(DM0->DM0_STATUS)) + "' ) "
cQuery += "    AND DM0.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDM0,.F.,.T.)

While (cAliasDM0)->(!Eof())
	aVetWrk := {}

	Aadd(aVetWrk,(cAliasDM0)->DM0_RECNO)
	Aadd(aVetWrk,(cAliasDM0)->DM0_IDINTG)
	Aadd(aVetWrk,TMSConvDat(SToD((cAliasDM0)->DM0_DATREA),(cAliasDM0)->DM0_HORREA))
	Aadd(aVetWrk,TMSConvDat(SToD((cAliasDM0)->DM0_DATREA),(cAliasDM0)->DM0_HORREA))

	nRecDUD := TMSRecDUD((cAliasDM0)->DT6_FILDOC,(cAliasDM0)->DT6_DOC,(cAliasDM0)->DT6_SERIE)
	If nRecDUD != 0
		DUD->(DbGoTo(nRecDUD))
		Aadd(aVetWrk,DUD->DUD_FILORI)
		Aadd(aVetWrk,DUD->DUD_VIAGEM)
	Else
		Aadd(aVetWrk,"")
		Aadd(aVetWrk,"")
	EndIf

	Aadd(aVetWrk,"")	//-- Somente para compatibilizar com a função TMSChkDM0
	Aadd(aVetWrk,"")	//-- Somente para compatibilizar com a função TMSChkDM0

	Aadd( aVetWrk, (cAliasDM0)->DT6_FILDOC	)
	Aadd( aVetWrk, (cAliasDM0)->DT6_DOC		)
	Aadd( aVetWrk, (cAliasDM0)->DT6_SERIE	)
	Aadd( aVetWrk, (cAliasDM0)->DT6_CHVCTE	)
	Aadd( aVetWrk, (cAliasDM0)->DT6_CDRDES	)

	Aadd(aRet,aClone(aVetWrk))

	(cAliasDM0)->(DbSkip())
EndDo

(cAliasDM0)->(DbCloseArea())

aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} FunHError
Função auxiliar para tratar possivel erro de DM0: TOPCONN - UpdateMemos error (-19).

@author Rodrigo Pirolo
@since 20/11/2020
@version 1.0
*/
//-------------------------------------------------------------------

Static Function FunHError( oErrorH, nRegDM0, aDados )

	Local lImagem	:= FwIsInCallStack("TMSMOVIMG")

	DEFAULT oErrorH := Nil
	DEFAULT nRegDM0	:= 0
	DEFAULT aDados	:= {}

	If !Empty( oErrorH:Description )
		Help( '', 1, "TMSXFUNHError", , STR0013 + chr(10) + oErrorH:Description, 1 ) //"Erro encontrado na Função executada: " ####
		If lImagem
			TMSGrvErr( nRegDM0 )
		EndIf
	EndIf

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} TMSImgInf
Realiza a comunicação e o tratamento do retorno do Get Metadata
@author Rodrigo Pirolo
@since 24/11/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSImgInf( cPathParam, cQueryParam )

	Local aRet			:= {}
	Local oResult		:= Nil
	Local cResult		:= ""
	
	Default cPathParam	:= ""
	Default cQueryParam	:= ""
	
	cResult		:= TMSCHKLIST("GET",cPathParam,,cQueryParam,"metadata",,,,,,.T.)
	
	If FWJsonDeserialize( cResult, @oResult )
		aRet := { oResult:lastModified, oResult:length, oResult:name, oResult:type }
	Else
		aRet := { "", 0, "", "" }
	EndIf
	
	FwFreeObj(oResult)

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMSGrvErr
Realiza a gravação da mensagem de erro na DM0
@author Rodrigo Pirolo
@since 24/11/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSGrvErr( nRegDM0 )

	Local lRet := .F.

	Default nRegDM0	:= 0

	If nRegDM0 > 0
		lRet := .T.
		DM0->( DbGoTo( nRegDM0 ) )
		RecLock( "DM0", .F. )
			DM0->DM0_IMAGEM := ""
			DM0->DM0_EXTENS := ""
			DM0->DM0_OBSERV := STR0014 //"A imagem ultrapassou o limite de 10 mb. Realizar o upload via Protheus."
		DM0->(MsUnlock())
	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMSGrvErr
Realiza a gravação da mensagem de erro na DM0
@author Rodrigo Pirolo
@since 02/06/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSReevCh( aMsgErr, aReenvC )

	Local lRet		:= .F.
	Local aDocsChk	:= {}
	Local aMsg		:= {}
	Local nX		:= 0
	Local nY		:= 0

	Default aMsgErr	:= {}
	Default aReenvC	:= {}

	If Len(aReenvC) > 0
		aDocsChk:= AClone(aReenvC)
		aReenvC	:= {}
		Processa( { || TMSEnvChk( aDocsChk, DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, @aMsg, @aReenvC ) }, STR0015, STR0016 ) //"Integração Protheus TMS x Meu Checklist" "Aguarde..."
		
		For nX := 1 To Len(aMsg)
			For nY := 1 To Len(aMsgErr)
				If PadR(aMsg[nX,1],40) $ aMsgErr[nY,1]
					aMsgErr[nY,1] := aMsg[nX,1]
				EndIf
			Next nY
		Next nX

		lRet := Len(aReenvC) == 0
	Else
		Help( '', 1, "TMSXFUNH", , STR0017, 1 ) // "A Viagem não possui documentos pendentes de integração."
	EndIf

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMSButCh
Realiza a gravação da mensagem de erro na DM0
@author Rodrigo Pirolo
@since 07/06/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMSButCh()

	Local aSays		:= {}
	Local aButtons	:= {}
	Local aArea		:= GetArea()
	Local aAreaDTX	:= DTX->( GetArea() )
	Local aAreaDTQ	:= DTQ->( GetArea() )
	Local aAreaDTW	:= DTW->( GetArea() )
	Local aAreaDUA	:= DUA->( GetArea() )
	Local aAreaDTR	:= DTR->( GetArea() )
	Local aAreaDUV	:= DUV->( GetArea() )
	Local aAreaDA3	:= DA3->( GetArea() )
	Local cFilOri	:= DTQ->DTQ_FILORI
	Local cViagem	:= DTQ->DTQ_VIAGEM
		
	Local lFechada	:= DTQ->DTQ_STATUS == '5'
	Local lTransi	:= DTQ->DTQ_STATUS == '2'
	Local aMsgChk	:= {}
	Local aDocsChk	:= {}
	Local aReenvC	:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local nPos		:= 0
	Local lFecha	:= SuperGetMV( "MV_TMINTEV", , "" ) == "1"
	Local lContinua	:= .F.
	Local cHelp     := ""

	// Busca os documentos da viagem
	aDocsChk := TMSLstChk( cFilOri, cViagem )
	
	If lFecha .And. ( lFechada .Or. lTransi )
		lContinua := .T.
	ElseIf !lFecha .And. lTransi
		lContinua := .T.
	EndIf

	If lContinua
		For nX := 1 To Len( aDocsChk )
			For nY := 1 To Len( aDocsChk[nX,4] )

				lFeito := VerInteg( aDocsChk[nX,4,nY,1], aDocsChk[nX,4,nY,2], aDocsChk[nX,4,nY,3] )

				If !lFeito
					
					nPos := AScan( aReenvC, { |x| x[2] + x[3] == aDocsChk[nX,2] + aDocsChk[nX,3] } )

					If nPos == 0
						AAdd( aReenvC, { aDocsChk[nX][1], aDocsChk[nX][2], aDocsChk[nX][3], { AClone( aDocsChk[ nX ][4][nY] ) } } )
					Else
						AAdd( aReenvC[nPos][4], AClone( aDocsChk[ nX ][4][nY] ) )
					EndIf

					nPos := 0

				EndIf

			Next nY

		Next nX

		aDocsChk	:= {}
		aDocsChk	:= AClone( aReenvC )
		aReenvC		:= {}
		aMsgChk		:= {}

		If Len(aDocsChk) > 0

			AAdd( aSays, STR0020 ) //'Este programa tem como objetivo, efetuar o reenvio dos documentos da viagem '
			AAdd( aSays, STR0021 ) //'para Integração Protheus TMS x Meu Checklist. '

			AAdd( aButtons, { 1, .T., { |o| Processa( { || TMSEnvChk( Aclone(aDocsChk), cFilOri, cViagem, @aMsgChk, @aReenvC ) , TmsMsgErr( aMsgChk, , , .T., AClone(aReenvC) ) }, STR0015, STR0016 ), o:oWnd:End() } } ) //"Integração Protheus TMS x Meu Checklist" "Aguarde..."
			AAdd( aButtons, { 2, .T., { |o| o:oWnd:End() } } )

			FormBatch( STR0015, aSays, aButtons ) //"Integração Protheus TMS x Meu Checklist"
		Else
			If lFecha
				cHelp := STR0018 //"A integração TMS x Meu Checklist está configurada para integrar no Fechamento da Viagem. Portanto a Viagem precisa estar 'Fechada' e ter documentos não integrados para utilizar esta rotina."
			Else
				cHelp := STR0019 // "A integração TMS x Meu Checklist está configurada para integrar no Apontamento de Saída da Viagem. Portanto a Viagem precisa estar 'Em Transito' e ter documentos não integrados para utilizar esta rotina."
			EndIf
			Help( '', 1, "TMSXFUNH", , STR0017, 1 ) // "A Viagem não possui documentos pendentes de integração."
		EndIf
	Else
		Help( '', 1, "TMSXFUNH", , cHelp, 1 )
	EndIf

	FwFreeArray(aDocsChk)
	FwFreeArray(aReenvC)
	FwFreeArray(aMsgChk)

	RestArea(aAreaDTX)
	RestArea(aAreaDTQ)
	RestArea(aAreaDTW)
	RestArea(aAreaDUA)
	RestArea(aAreaDTR)
	RestArea(aAreaDUV)
	RestArea(aAreaDA3)
	RestArea(aArea)

Return lContinua

//-------------------------------------------------------------------
/*{Protheus.doc} VerInteg
Verifica se documento foi gravado na DM0 e gerado ID de Integração
@author Rodrigo Pirolo
@since 07/06/2020
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Static Function VerInteg( cFilDoc, cDoc, cSerie )

	Local cQuery	:= ""
	Local cAlias	:= ""
	Local lFeito	:= .F.

	Default cFilDoc	:= ""
	Default cDoc	:= ""
	Default cSerie	:= ""

	If !Empty(cFilDoc) .AND. !Empty(cDoc) .AND. !Empty(cSerie)
		cAlias := GetNextAlias()
		If lDM0

			cQuery :=	" SELECT DM0.DM0_IDINTG IDINTG "
			cQuery += 	" FROM " + RetSqlName("DM0") + " DM0 "
			cQuery += 	" JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery += 		" ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
			cQuery += 			" AND DT6.DT6_FILDOC = DM0.DM0_FILDOC "
			cQuery += 			" AND DT6.DT6_DOC    = DM0.DM0_DOC "
			cQuery += 			" AND DT6.DT6_SERIE  = DM0.DM0_SERIE "
			cQuery += 			" AND DT6.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE DM0.DM0_FILIAL = '" + xFilial("DM0") + "' "
			cQuery += 		" AND DM0.DM0_FILDOC = '" + cFilDoc + "'"
			cQuery += 		" AND DM0.DM0_DOC = '" + cDoc + "'"
			cQuery += 		" AND DM0.DM0_SERIE = '" + cSerie + "'"
			cQuery += 		" AND DM0.D_E_L_E_T_ = ' ' "

		Else

			cQuery := " SELECT DLY.DLY_IDINTG IDINTG "
			cQuery += " FROM " + RetSqlName("DLY") + " DLY "
			cQuery += " JOIN " + RetSqlName("DT6") + " DT6 "
			cQuery += 	" ON DT6.DT6_FILIAL = '" + xFilial("DT6") + "' "
			cQuery += 		" AND DT6.DT6_CHVCTE = DLY.DLY_CHVCTE "
			cQuery += 		" AND DT6.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE DLY.DLY_FILIAL = '" + xFilial("DLY") + "' "
			cQuery += "   AND DLY.DLY_FILDOC = '" + cFilDoc + "' "
			cQuery += "   AND DLY.DLY_DOC = '" + cDoc + "' "
			cQuery += "   AND DLY.DLY_SERIE = '" + cSerie + "' "
			cQuery += "   AND DLY.D_E_L_E_T_ = ' ' "

		EndIf

		cQuery := ChangeQuery(cQuery)

		DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAlias, .F., .T. )

		If !( (cAlias)->( EOF() ) )
			If !Empty( (cAlias)->IDINTG )
				lFeito := .T.
			EndIf
		EndIf

		(cAlias)->( DbCloseArea() )
	EndIf

Return lFeito

//-------------------------------------------------------------------
/*{Protheus.doc} TMSDelDAV
Deleta DAV vinculada com a DM0
@author Rodrigo Pirolo
@since 29/10/2021
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Static Function TMSDelDAV( cIDMPos )

	Local aArea		:= GetArea()
	Local aAreaDM0	:= DM0->( GetArea() )

	Default cIDMPos := ""

	DbSelectArea("DAV")
	DAV->( DbSetOrder( 1 ) )

	If DAV->( DbSeek( FwxFilial("DAV") + cIDMPos ) )
		RecLock("DAV", .F. )
			DAV->( DbDelete() )
		DAV->( MsUnlock() )
	EndIf

	RestArea(aArea)
	RestArea(aAreaDM0)

Return .T.


/*/{Protheus.doc} TMSListU
Realiza a consulta no serviço do Meu Checklist pelos executores
@author Carlos A. Gomes Jr.
@since 17/04/2020
/*/
Function TMSListU()

Local aExec		As Array
Local oDlg		As Object
Local oListBox	As Object
Local lRet := .F.

If TMSDLZAti() // Verifica se existe parametro de CheckList Ativo
    Var_IXB := ""
    aExec   := TMSLeUnid()
	If Len(aExec) > 0
		DEFINE MSDIALOG oDlg TITLE "Meu Check List - Unidades" FROM 180, 180 TO 530, 910 PIXEL
			@ 005, 005 LISTBOX oListBox FIELDS HEADER "Nome", "Apelido", "ID" SIZE 360, 150 OF oDlg PIXEL
			oListBox:SetArray( aExec )
			oListBox:bLine := { | | { 	aExec[oListBox:nAt][1],;
										aExec[oListBox:nAt][2],;
										aExec[oListBox:nAt][3] } }
			DEFINE SButton FROM 160, 300 TYPE 1 ENABLE OF oDlg ACTION ( lRet := .T., Var_IXB := aExec[oListBox:nAt][3], oDlg:End() )
			DEFINE SButton FROM 160, 335 TYPE 2 ENABLE Of oDlg ACTION oDlg:End()
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} TMSLeUnid
Busca lista de Unidades do Foundation
Carlos A. Gomes Jr.
@since 20/01/2022
@return aRet Vetor com as unidades ativas
/*/
Static Function TMSLeUnid()

Local cQryParam	:= ""
Local nCount    := 0
Local cResult   := ""
Local oResult
Local aRet      := {}

cQryParam += "&pageSize=500"
cResult   := TMSCHKLIST( "GET", "unidades", , cQryParam, , , , , , , , .T. )

If FWJsonDeserialize( cResult, @oResult )
	If AttIsMemberOf( oResult, "items" )
		aRet := {}

        For nCount := 1 To Len( oResult:items )
            If oResult:items[nCount]:SITUACAO == "ATIVO"
                AAdd( aRet, { Iif(!Empty(oResult:items[nCount]:NOME),DeCodeUTF8(oResult:items[nCount]:NOME),""),;
                              Iif(!Empty(oResult:items[nCount]:APELIDO),DeCodeUTF8(oResult:items[nCount]:APELIDO),""),;
                              oResult:items[nCount]:ID } )
            EndIf
        Next nCount

        ASort(aRet,,,{|x,y| x[1] < y[1]})

	EndIf
EndIf

FwFreeObj(oResult)

Return aRet

/*/{Protheus.doc} TMSChkVer2
Verifica a versão a ser executada do checklist
Carlos A. Gomes Jr.
@since 21/01/2022
@Return Se versão 2 retorna .T. se versão 1 retrona .F.
/*/

Function TMSChkVer2(cVerChk, cFilExt)
Local aAreas
DEFAULT cVerChk := ""
DEFAULT cFilExt := ""

cVerChk := "v1"
cFilExt := ""
If DVL->(ColumnPos("DVL_FILEXT")) > 0
	aAreas := {GetArea("DVL"),GetArea()}
	DVL->(DbSetOrder(1))
	If DVL->(MsSeek(xFilial("DVL")+cFilAnt)) .And. !Empty(DVL->DVL_FILEXT)
		cVerChk := "v2"
		cFilExt := AllTrim(DVL->DVL_FILEXT)
	EndIf
	AEval( aAreas, { |aArea| RestArea(aArea) } )
EndIf

Return ( cVerChk == "v2" )

/*{Protheus.doc} TMSDocEnd
Busca endereço de coleta/entrega seja ele do solicitante ou cliente ou sequencia de endereço
Seguindo a regra do documento.
@author Carlos A. Gomes Jr.
@since 11/05/22
*/
#DEFINE NDOCEND_END    01
#DEFINE NDOCEND_BAIRRO 02
#DEFINE NDOCEND_CEP    03
#DEFINE NDOCEND_MUN    04
#DEFINE NDOCEND_EST    05
#DEFINE NDOCEND_CODIGO 06
#DEFINE NDOCEND_LOJA   07
#DEFINE NDOCEND_NREDUZ 08
#DEFINE NDOCEND_NOME   09
#DEFINE NDOCEND_CGC    10
#DEFINE NDOCEND_PESSOA 11
#DEFINE NDOCEND_PAIS   12
#DEFINE NDOCEND_TEL    13
#DEFINE NDOCEND_LENVET 13

Function TMSDocEnd( cFilDoc, cDoc, cSerie )
Local aAreas := { DT6->(GetArea()), DTC->(GetArea()), SA1->(GetArea()), DT5->(GetArea()), DUE->(GetArea()), DUL->(GetArea()), GetArea() }
Local aRet   := { Array(NDOCEND_LENVET), Array(NDOCEND_LENVET) }

Default cFilDoc := ""
Default cDoc    := ""
Default cSerie  := ""

	DT6->(DbSetOrder(1))
	If DT6->(MsSeek(xFilial("DT6")+cFilDoc+cDoc+cSerie))
		AFill(aRet[1],"")
		aRet[1][NDOCEND_PAIS] := { "BR", "BRASIL" }
		AFill(aRet[2],"")
		aRet[2][NDOCEND_PAIS] := { "BR", "BRASIL" }
		If DT6->DT6_DOCTMS != StrZero( 1, Len(DT6->DT6_DOCTMS) )	//-- Diferente de coleta
			DTC->(DbSetOrder(3))
			DTC->(MsSeek(xFilial("DTC")+cFilDoc+cDoc+cSerie))
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1") + DTC->(DTC_CLIDES + DTC_LOJDES)))
				aRet[1][NDOCEND_CODIGO] := SA1->A1_COD
				aRet[1][NDOCEND_LOJA  ] := SA1->A1_LOJA
				aRet[1][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
				aRet[1][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
				aRet[1][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
				aRet[1][NDOCEND_PESSOA] := SA1->A1_PESSOA
				aRet[1][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
				If Empty(DTC->DTC_SQEDES)
					aRet[1][NDOCEND_END   ] := AllTrim(SA1->A1_END)
					aRet[1][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
					aRet[1][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
					aRet[1][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
					aRet[1][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
					aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
				Else
					DUL->(DbSetOrder(2))
					If DUL->(DbSeek(xFilial("DUL") + DTC->(DTC_CLIDES + DTC_LOJDES + DTC_SQEDES)))
						aRet[1][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
						aRet[1][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
						aRet[1][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
						aRet[1][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
						aRet[1][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
						aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
					EndIf
				EndIf
			EndIf
			If SA1->(DbSeek(xFilial("SA1") + DTC->(DTC_CLIREM + DTC_LOJREM)))
				aRet[2][NDOCEND_CODIGO] := SA1->A1_COD
				aRet[2][NDOCEND_LOJA  ] := SA1->A1_LOJA
				aRet[2][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
				aRet[2][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
				aRet[2][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
				aRet[2][NDOCEND_PESSOA] := SA1->A1_PESSOA
				aRet[2][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
				aRet[2][NDOCEND_END   ] := AllTrim(SA1->A1_END)
				aRet[2][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
				aRet[2][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
				aRet[2][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
				aRet[2][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
				aRet[2][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
			EndIf
		Else	//-- Coleta
			DT5->(DbSetOrder(4))
			If DT5->(DbSeek(xFilial("DT5") + cFilDoc + cDoc + cSerie))
				If Empty(DT5->(DT5_CLIREM + DT5_LOJREM))
					DUE->(DbSetOrder(1))
					If DUE->(DbSeek(xFilial("DUE") + DT5->DT5_CODSOL))
						aRet[1][NDOCEND_CODIGO] := DUE->DUE_CODSOL
						aRet[1][NDOCEND_NOME  ] := AllTrim(DUE->DUE_NOME)
						aRet[1][NDOCEND_NREDUZ] := AllTrim(DUE->DUE_NREDUZ)
						aRet[1][NDOCEND_CGC   ] := AllTrim(DUE->DUE_CGC)
						aRet[1][NDOCEND_PESSOA] := Iif(Len(aRet[1][NDOCEND_CGC]) == 11,"F","J")
						If Empty(DT5->DT5_SEQEND)
							aRet[1][NDOCEND_END   ] := AllTrim(DUE->DUE_END)
							aRet[1][NDOCEND_BAIRRO] := AllTrim(DUE->DUE_BAIRRO)
							aRet[1][NDOCEND_CEP   ] := AllTrim(DUE->DUE_CEP)
							aRet[1][NDOCEND_MUN   ] := AllTrim(DUE->DUE_MUN)
							aRet[1][NDOCEND_EST   ] := AllTrim(DUE->DUE_EST)
							aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUE->DUE_DDD),"("+AllTrim(DUE->DUE_DDD)+")","")+DUE->DUE_TEL)
						Else
							DUL->(DbSetOrder(3))
							If DUL->(DbSeek(xFilial("DUL") + DT5->(DT5_CODSOL + DT5_SEQEND)))
								aRet[1][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
								aRet[1][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
								aRet[1][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
								aRet[1][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
								aRet[1][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
								aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
							EndIf
						EndIf
					EndIf
				Else
					SA1->(DbSetOrder(1))
					If SA1->(DbSeek(xFilial("SA1") + DT5->(DT5_CLIREM + DT5_LOJREM)))
						aRet[1][NDOCEND_CODIGO] := SA1->A1_COD
						aRet[1][NDOCEND_LOJA  ] := SA1->A1_LOJA
						aRet[1][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
						aRet[1][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
						aRet[1][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
						aRet[1][NDOCEND_PESSOA] := SA1->A1_PESSOA
						aRet[1][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
						If Empty(DT5->DT5_SQEREM)
							aRet[1][NDOCEND_END   ] := AllTrim(SA1->A1_END)
							aRet[1][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
							aRet[1][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
							aRet[1][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
							aRet[1][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
							aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
						Else
							DUL->(DbSetOrder(2))
							If DUL->(DbSeek(xFilial("DUL") + DT5->(DT5_CLIREM + DT5_LOJREM + DT5_SQEREM)))
								aRet[1][NDOCEND_END   ] := AllTrim(DUL->DUL_END)
								aRet[1][NDOCEND_BAIRRO] := AllTrim(DUL->DUL_BAIRRO)
								aRet[1][NDOCEND_CEP   ] := AllTrim(DUL->DUL_CEP)
								aRet[1][NDOCEND_MUN   ] := AllTrim(DUL->DUL_MUN)
								aRet[1][NDOCEND_EST   ] := AllTrim(DUL->DUL_EST)
								aRet[1][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(DUL->DUL_DDD),"("+AllTrim(DUL->DUL_DDD)+")","")+DUL->DUL_TEL)
							EndIf
						EndIf
					EndIf
				EndIf
				If !Empty(DT5->(DT5_CLIDES + DT5_LOJDES)) .And. SA1->(DbSeek(xFilial("SA1") + DT5->(DT5_CLIDES + DT5_LOJDES)))
					aRet[2][NDOCEND_CODIGO] := SA1->A1_COD
					aRet[2][NDOCEND_LOJA  ] := SA1->A1_LOJA
					aRet[2][NDOCEND_NREDUZ] := AllTrim(SA1->A1_NREDUZ)
					aRet[2][NDOCEND_NOME  ] := AllTrim(SA1->A1_NOME)
					aRet[2][NDOCEND_CGC   ] := AllTrim(SA1->A1_CGC)
					aRet[2][NDOCEND_PESSOA] := SA1->A1_PESSOA
					aRet[2][NDOCEND_PAIS  ] := { AllTrim(Posicione("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_SIGLA")), AllTrim(SYA->YA_DESCR) }
					aRet[2][NDOCEND_END   ] := AllTrim(SA1->A1_END)
					aRet[2][NDOCEND_BAIRRO] := AllTrim(SA1->A1_BAIRRO)
					aRet[2][NDOCEND_CEP   ] := AllTrim(SA1->A1_CEP)
					aRet[2][NDOCEND_MUN   ] := AllTrim(SA1->A1_MUN)
					aRet[2][NDOCEND_EST   ] := AllTrim(SA1->A1_EST)
					aRet[2][NDOCEND_TEL   ] := AllTrim(Iif(!Empty(SA1->A1_DDD),"("+AllTrim(SA1->A1_DDD)+")","")+SA1->A1_TEL)
				EndIf
			EndIf
		EndIf
	EndIf

	aEval(aAreas,{|xArea| RestArea(xArea)})

Return aRet

//-------------------------------------------------------------------
/*{Protheus.doc} TMHVerFinTMHVerFin
Realiza verificação na DM0 se houve algum documento entregue
@author Rodrigo Pirolo
@since 29/10/2021
@version 12.1.27
@return Logico
@param 
@type function
*/
//-------------------------------------------------------------------

Function TMHVerFin( cFilOri, cViagem )

	Local aArea		:= GetArea()
	Local aAreaDM0	:= DM0->( GetArea() )
	Local aAreaDTA	:= DTA->( GetArea() )

	Local lRet		:= .T.
	Local lFinish	:= .F.

	Local nX		:= 0

	Local oItems	:= Nil

	Local cQuery	:= ""
	Local cIdCHK	:= ""
	Local cStatus	:= ""
	Local cAliasQry	:= GetNextAlias()

	Default cFilOri	:= ""
	Default cViagem	:= ""

	cQuery := " SELECT DUD_FILDOC, DUD_DOC, DUD_SERIE "
	cQuery += " FROM " + RetSQLName('DUD') + " DUD "
	cQuery += " WHERE DUD.DUD_FILORI = '" + cFilOri + "' "
	cQuery += 		" AND DUD.DUD_VIAGEM = '" + cViagem + "' "
	cQuery += 		" AND DUD.D_E_L_E_T_ = ' ' "

	DbUseArea( .T., "TOPCONN", TCGenQRY( , , cQuery ), cAliasQry, .F., .T. )

	If (cAliasQry)->( !Eof() )
		While (cAliasQry)->( !Eof() )
			
			DbSelectArea("DM0")
			DM0->( DbSetOrder( 1 ) ) //DM0_FILIAL, DM0_FILDOC, DM0_DOC, DM0_SERIE

			cIdCHK := AllTrim(cViagem) + "_" + (cAliasQry)->DUD_DOC + (cAliasQry)->DUD_SERIE
			oItems := Nil
			// Verifica se o Check List Existe
			cRet := TMSVerCHK(cIdCHK, @oItems )

			If ValType(oItems) == "A" .And. !Empty(oItems)

				For nX := 1 To Len(oItems)
					
					cStatus	:= oItems[nX]["status"]

					If cStatus == "FINISHED"
						lFinish := .T.
						Exit
					EndIf
				
				Next nX

			EndIf

			If lFinish
				lRet := .F.
				Exit
			EndIf

			(cAliasQry)->(  DbSkip() )
		EndDo
	EndIf

	(cAliasQry)->( DbCloseArea() )

	FwFreeObj(oItems)

	RestArea(aArea)
	RestArea(aAreaDM0)
	RestArea(aAreaDTA)

Return lRet
