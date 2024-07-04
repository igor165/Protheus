#include "protheus.ch"
#include "FWMVCDEF.CH"
#include "OMSXFUNI.CH"

//-----------------------------------------------------------
/*/{Protheus.doc} OMSGrvCoEn
Monta tela para seleção dos registros que irão para a tabela intermediária de histórico de envios à gestão de entregas
@author Valdemar Roberto Mognon
@version P12
@Since	24/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSGrvCoEn(cCodVei,cCodMot)
Local lRet      := .T.
Local aAreas    := {GetArea()}
Local aRotBak   := {}
Local nQtdCar   := 0
Local nRegistro := 0
Local cFiltro   := ""
Local cMark     := GetMark()
Local oDlgMrk

Default cCodVei := DAK->DAK_CAMINH
Default cCodMot := DAK->DAK_MOTORI

lRet := (!Empty(cCodVei) .And. !Empty(cCodMot))

If lRet
	lRet := OMSValCoEn(1,,)
EndIf

If lRet
	//-- Verifica a quantidade de cargas
	cFiltro := "AND  DAK.DAK_PROCES = ' ' "
	cFiltro += "AND  DAK.DAK_CAMINH = '" + cCodVei + "' "
	cFiltro += "AND  DAK.DAK_MOTORI = '" + cCodMot + "' "
	cFiltro += "AND  DAK.DAK_FEZNF  = '1' "
	cFiltro += "AND  DAK.DAK_ACECAR = '2' "
	cFiltro += "AND (DAK.DAK_BLQCAR = '2' OR DAK.DAK_BLQCAR = ' ') "
	cFiltro += "AND (DAK.DAK_JUNTOU = 'MANUAL' OR DAK.DAK_JUNTOU = 'ASSOCI' OR DAK.DAK_JUNTOU = 'JUNTOU') "
	nQtdCar := OMSQtdCarg(cFiltro,@nRegistro)

	If nQtdCar == 0	//-- Não existem cargas
		Help(" ",1,"OMSXFUNI01")	//-- "Não foram encontradas cargas para este veículo e motorista." # "Selecione um veículo e motorista que possua carga para enviar ao portal coleta/entrega."
	ElseIf nQtdCar == 1	//-- Assume a carga automaticamente e gera DN5
		DAK->(DbGoTo(nRegistro))
		Reclock("DAK",.F.)
		DAK->DAK_OK := cMark
		DAK->(MsUnlock())
		//-- Executa gravação do histórico de integrações
		OMSSupCoEn(1,,cMark,DAK->(DAK_COD + DAK_SEQCAR),)
	ElseIf nQtdCar > 1	//-- Monta tela para seleção das cargas
		aRotBak := Aclone(aRotina)
		aRotina := {{OemtoAnsi(STR0001),"OMSSupCoEn(1,oMrkBrowse,oMrkBrowse:Mark())",0,1,0,.F.}}	//-- "Confirma"
	
		oMrkBrowse:= FWMarkBrowse():New()
		oMrkBrowse:SetFieldMark("DAK_OK")
		oMrkBrowse:SetOwner(oDlgMrk)
		oMrkBrowse:SetAlias("DAK")
		oMrkBrowse:SetMenuDef("")
		oMrkBrowse:AddFilter("MANUAL","Empty(DAK->DAK_PROCES) .And. DAK->DAK_CAMINH == '" + cCodVei + "' .And. DAK->DAK_MOTORI == '" + cCodMot + "' .And. DAK->DAK_FEZNF == '1' .And. DAK->DAK_ACECAR == '2' .And. (DAK->DAK_BLQCAR == '2' .Or. DAK->DAK_BLQCAR == ' ') .And. (DAK->DAK_JUNTOU == 'MANUAL' .Or. DAK->DAK_JUNTOU == 'ASSOCI' .Or. DAK->DAK_JUNTOU == 'JUNTOU')",.T.,.T.)
		oMrkBrowse:SetDescription(STR0002)	//-- "Selecione as cargas"
		oMrkBrowse:bAllMark := {|| OMSMrkAll(oMrkBrowse,oMrkBrowse:Mark())}
		oMrkBrowse:DisableReport()
		oMrkBrowse:DisableConfig()
		oMrkBrowse:DisableDetails() 
		oMrkBrowse:Activate()

		aRotina := Aclone(aRotBak)
	EndIf
	
	AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSEstCoEn
Estorna os registros da tabela intermediária de histórico que ainda não foram enviados à gestão de entregas
@author Valdemar Roberto Mognon
@version P12
@Since	31/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSEstCoEn(cProces)
Local aAreas     := {DN4->(GetArea()),DN5->(GetArea()),DN1->(GetArea()),DAK->(GetArea()),GetArea()}
Local aStruct    := {}
Local aStatusVia := {}
Local nCntFor2   := 0
Local nRegistro  := 0
Local lOk        := .T.
Local lPrimeiro  := .T.
Local lCont      := .T.
Local cAliasDN5  := ""
Local cQuery     := ""
Local oColEnt

Default cProces := DAK->DAK_PROCES

If lCont
	lCont := OMSValCoEn(2,cProces,)
EndIf

If lCont
	lOk := MsgYesNo(STR0003 + cProces)	//-- "Confirma Estorno do Envio da Carga No. "

	If lOk
		oColEnt := TMSBCACOLENT():New("DN1")
		If oColEnt:DbGetToken()
			DN1->(DbGoTo(oColEnt:config_recno))
		
			//-- Inicializa a estrutura
			aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)
		
			//-- Localiza primeiro registro da estrutura
			For nCntFor2 := 1 To Len(aStruct)
				//-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
				If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nCntFor2,1] + aStruct[nCntFor2,2]}) == 0) .And. ;
													aStruct[nCntFor2,10] == "2" .And. Empty(aStruct[nCntFor2,6])
					Exit
				EndIf
			Next nCntFor2
		
			If ExisteDN5(aStruct[nCntFor2,1],aStruct[nCntFor2,2],PadR(cProces,Len(DN5->DN5_PROCES)),{"1","2"},@nRegistro)
				DN5->(DbGoTo(nRegistro))
				If DN5->DN5_STATUS == "1" .Or. DN5->DN5_STATUS == "2"
					If DN5->DN5_STATUS == "1"
						If (aStatusVia := TMSAC30GDV(DN5->DN5_IDEXT,,.F.))[1]
							If aStatusVia[2] != "AGUARDANDO_DESPACHO"
								Help(" ", , STR0004, , STR0005 + aStatusVia[2], 2, 1)	//-- "Não é possível estonar a carga" # "Carga já manipulada no portal de Coleta/entrega com status diferente do esperado. Status atual: "
								lOk := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

If lOk .And. (Empty(DN5->DN5_IDEXT) .Or. TMSAC30ExA(AllTrim(DN5->DN5_IDEXT)))
	cAliasDN5 := GetNextAlias()
	cQuery := "SELECT DN5.DN5_CODFON DN5_CODFON, DN5.DN5_CODREG DN5_CODREG,DN5.R_E_C_N_O_ REGISTRO "
	cQuery += "  FROM " + RetSqlName("DN5") + " DN5 "
	cQuery += " WHERE DN5.DN5_FILIAL = '" + xFilial("DN5") + "' "
	cQuery += "   AND DN5.DN5_CODFON = '" + DN1->DN1_CODFON + "' "
	cQuery += "   AND DN5.DN5_PROCES = '" + cProces + "' "
	cQuery += "   AND DN5.DN5_STATUS IN('1','2') "
	cQuery += "   AND DN5.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDN5,.F.,.T.)

	DN4->(DbSetOrder(1))

	While (cAliasDN5)->(!Eof())
		//-- Estorna registro na DN5
		DN5->(DbGoTo((cAliasDN5)->REGISTRO))
		RecLock("DN5",.F.)
		DN5->DN5_STATUS := Iif(Empty(DN5->DN5_IDEXT),"6","5")	//-- Estornado Envio ou Estornado
		DN5->DN5_SITUAC := StrZero(3,Len(DN5->DN5_SITUAC))	//-- Estornado
		DN5->(MsUnLock())

		//-- Estorna registro na DN4
		DN4->(MsSeek(xFilial("DN4")+DN5->(DN5_CODFON+DN5_CODREG+DN5_CHAVE)))
		RecLock("DN4",.F.)
		DN4->DN4_IDEXT  := ""
		DN4->DN4_STATUS := '2'
		DN4->(MsUnLock())

		If lPrimeiro
			DNC->(DbSetOrder(1))
			If DNC->(DbSeek(xFilial("DNC") + DN5->(DN5_CODFON + DN5_PROCES)))
				Reclock("DNC",.F.)
				DNC->DNC_STATUS := DN5->DN5_STATUS	//-- Estornado Envio ou Estornado
				DNC->DNC_SITUAC := DN5->DN5_SITUAC	//-- Estornado
				DNC->DNC_DATULT := dDataBase
				DNC->DNC_HORULT := SubStr(Time(),1,2) + SubStr(Time(),4,2)
				DNC->(MsUnlock())
			EndIf
			lPrimeiro := .F.
		EndIf

		(cAliasDN5)->(DbSkip())
	EndDo

	(cAliasDN5)->(DbCloseArea())

	//-- Retira o processo da carga e retorna o status (DAK_COLENT) para 2-Não Integrado
	cQuery := " UPDATE " + RetSqlName("DAK")
	cQuery += "    SET DAK_PROCES = '" + Space(Len(DAK->DAK_PROCES)) + "', "
	cQuery += "        DAK_OK     = '" + Space(Len(DAK->DAK_OK)) + "', "
	cQuery += "        DAK_COLENT = '2' "
	cQuery += "  WHERE DAK_FILIAL = '" + xFilial("DAK") + "' "
	cQuery += "    AND DAK_PROCES = '" + PadR(cProces,Len(DN5->DN5_PROCES)) + "' "
	cQuery += "    AND D_E_L_E_T_ = ' ' "
	TCSqlExec(cQuery)
	
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSIntCoEn
Integra a carga na gestão de entregas
@author Valdemar Roberto Mognon
@version P12
@Since	24/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSIntCoEn(cProces,lColEnt)
Local lRet     := .T.
Local cStatus  := ""
Local oColEnt

Default cProces := DAK->DAK_PROCES
Default lColEnt := (DAK->DAK_COLENT == "1")

lRet := OMSValCoEn(3,cProces,lColEnt)

If lRet
	OMSSupCoEn(3,,,cProces)

	//-- Atualiza a tabela de cargas com o status da integração com o portal coleta/entrega
	oColEnt  := TMSBCACOLENT():New("DN1")
	If oColEnt:DbGetToken() .And. !Empty(oColEnt:filext)
		DN1->(DbGoTo(oColEnt:config_recno))
		DNC->(DbSetOrder(1))
		If DNC->(DbSeek(xFilial("DNC") + DN1->DN1_CODFON + cProces))
			cStatus := Iif(DNC->DNC_STATUS == "1","1","2")

			cQuery := " UPDATE " + RetSqlName("DAK")
			cQuery += "    SET DAK_COLENT = '" + cStatus + "' "
			cQuery += "  WHERE DAK_FILIAL = '" + xFilial("DAK") + "' "
			cQuery += "    AND DAK_PROCES = '" + PadR(cProces,Len(DAK->DAK_PROCES)) + "' "
			cQuery += "    AND D_E_L_E_T_ = ' ' "
			TCSqlExec(cQuery)

		EndIf
	EndIf
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSEnvCoEn
Controla o Envio e a Retirada da carga ao motorista
@author Valdemar Roberto Mognon
@version P12
@Since	24/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSEnvCoEn(nAcao,cProces)
Local lCont     := .T.
Local lOk       := .T.

Default nAcao   := 0
Default cProces := DAK->DAK_PROCES

If nAcao == 1 .Or. nAcao == 2	//-- 1=Envia e 2=Retira
	lCont := OMSValCoEn(nAcao + 3,,)
	
	If lCont
		lOk := MsgYesNo(Iif(nAcao == 1,STR0008,STR0009) + " " + cProces)	//-- "Confirma o Envio da Carga ao Motorista ?" # "Confirma a Retirada da Carga do Motorista ?"
		
		If lOk
			OMSSupCoEn(4,,,cProces,nAcao)
		EndIf
	EndIf
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSValCoEn
Validações da integração com coleta/entrega
@author Valdemar Roberto Mognon
@version P12
@Since	25/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSValCoEn(nAcao,cProces,lColEnt)
Local lRet    := .F.
Local oColEnt

Default nAcao   := 0
Default cProces := ""
Default lColEnt := .F.

//-- Todas as validações devem verificar se o coleta entrega está ativo
oColEnt  := TMSBCACOLENT():New("DN1")
If oColEnt:DbGetToken() .And. !Empty(oColEnt:filext)
	lRet := .T.
EndIf

If lRet
	If nAcao == 2	//-- Estorna
		If Empty(cProces)
			Help(" ",1,"OMSXFUNI02")	//-- "Carga não possui integração para estorno." # "Selecione uma carga integrada com o portal coleta/entrega."
			lRet := .F.
		EndIf
	ElseIf nAcao == 3	//-- Envia ao Portal
		If Empty(cProces)
			Help(" ",1,"OMSXFUNI04")	//-- "Carga não possui histórico para envio." # "Selecione uma carga com histórico para envio ao portal."
			lRet := .F.
		EndIf
		If lRet
			If lColEnt
				Help(" ",1,"OMSXFUNI03")	//-- "Carga já integrada." # "Selecione uma carga que ainda não foi integrada."
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} OMSGrvDN5
Gravação na tabela de histórico de envios para a gestão de entregas
@author Valdemar Roberto Mognon
@version P12
@Since	29/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSGrvDN5(oMarkBrw,cMark)
Local aAreas    := {DA4->(GetArea()),DN1->(GetArea()),DAK->(GetArea()),GetArea()}
Local aAreaDN5  := {}
Local aCargas   := {}
Local aStruct   := {}
Local aLayout   := {}
Local nCntFor1  := 0
Local nCntFor2  := 0
Local cQuery    := ""
Local cAliasDAK := GetNextAlias()
Local cCarga    := ""
Local cSeqCar   := ""
Local cSequen   := ""
Local oColEnt

Default oMarkBrw := Nil

cQuery := "SELECT DAK_COD,DAK_SEQCAR "
cQuery += "  FROM  " + RetSQLName("DAK") + " DAK "
cQuery += " WHERE DAK_FILIAL = '" + xFilial("DAK") + "' "
cQuery += "   AND DAK_OK     = '" + cMark + "' "
cQuery += "   AND DAK.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY DAK_COD,DAK_SEQCAR"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDAK)

While (cAliasDAK)->(!Eof())  
	Aadd(aCargas,{(cAliasDAK)->DAK_COD,(cAliasDAK)->DAK_SEQCAR})
	(cAliasDAK)->(DbSkip())
EndDo
(cAliasDAK)->(DbCloseArea())

If !Empty(aCargas)
	oColEnt  := TMSBCACOLENT():New("DN1")
	If oColEnt:DbGetToken() .And. !Empty(oColEnt:filext)
		DN1->(DbGoTo(oColEnt:config_recno))

		//-- Armazena a primeira carga
		cCarga  := aCargas[1,1]
		cSeqCar := aCargas[1,2]

		//-- Inicializa sequencia
		TMSSetVar("nSeqCarga",0)

		For nCntFor1 := 1 To Len(aCargas)		
			//-- Posiciona na carga
			DAK->(DbSetOrder(1))
			DAK->(DbSeek(xFilial("DAK") + aCargas[nCntFor1,1] + aCargas[nCntFor1,2]))
			
			//-- Inicializa a estrutura
			aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)
			TMSSetVar("aStruct",aStruct)
			
			//-- Define o processo
			TMSSetVar("cProcesso",cCarga + cSeqCar)

			//-- Inicializa o localizador
			TMSSetVar("aLocaliza",{})

			DA4->(DbSetOrder(1))	
			If DA4->(DbSeek(xFilial("DA4") + DAK->DAK_MOTORI)) .And. !Empty(BscIDMot(DAK->DAK_MOTORI,DN1->DN1_CODFON,))
				For nCntFor2 := 1 To Len(aStruct)
					If (Ascan(aStruct,{|x| x[11] + x[12] ==  aStruct[nCntFor2,1] +  aStruct[nCntFor2,2]}) == 0) .And. aStruct[nCntFor2,10] == "2"	//-- Não é adicional de ninguém e ainda não foi processado
						aLayout := BscLayout(aStruct[nCntFor2,1],aStruct[nCntFor2,2])
						If !Empty(aLayout)
							If Empty(aStruct[nCntFor2,6])
								//-- Localiza a sequencia no caso de mais de uma carga
								If Len(aCargas) > 1 .And. nCntFor1 > 1
									aAreaDN5 := DN5->(GetArea())
									DN5->(DbSetOrder(3))
									DN5->(DbSeek(cSeekDN5 := xFilial("DN5") + aStruct[nCntFor2,1] + aStruct[nCntFor2,2] + cCarga + cSeqCar))
									Do While !DN5->(Eof()) .And. cSeekDN5 == DN5->(DN5_FILIAL + DN5_CODFON + DN5_CODREG + RTrim(DN5_PROCES))
										cSequen := DN5->DN5_SEQUEN
										DN5->(DbSkip())
									EndDo
									RestArea(aAreaDN5)
								EndIf
								//-- Inicia a gravação dos registros
								MontaReg(Aclone(aLayout),nCntFor2,aCargas[nCntFor1,1] + aCargas[nCntFor1,2] == cCarga + cSeqCar,cSequen,.T.)
								TMSCtrLoop(Aclone(aLayout),nCntFor2)
							EndIf
						EndIf
					EndIf
					aStruct := TMSGetVar("aStruct")
				Next nCntFor2
			EndIf
			
			//-- Grava processo na carga
			RecLock("DAK",.F.)
			DAK->DAK_PROCES := cCarga + cSeqCar
			DAK->(MsUnlock())
		Next nCntFor1
		
		//-- Chama a integração com portal
		If DN1->DN1_INTEGR == "2"	//-- Automática
			OMSIntCoEn(cCarga + cSeqCar)
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

If !Empty(oMarkBrw)
	oMarkBrw:Refresh()
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSMrkAll
Marca/Desmarca todos os registros
@author Valdemar Roberto Mognon
@version P12
@Since 31/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSMrkAll(oMarkBrw,cMark)

DAK->(DbGoTop())

While DAK->(!Eof())
	If DAK->(MsRLock())
		If DAK->DAK_OK == cMark
			DAK->DAK_OK := "  "
			DAK->(MsUnlock())
		Else
			DAK->DAK_OK := cMark
		Endif
	Endif
	DAK->(DbSkip())
Enddo

DAK->(DbGoTop())

oMarkBrw:Refresh()

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSExcCoEn
Rotina que chama o estorno da carga no portal de coleta/entrega
@author Valdemar Roberto Mognon
@version P12
@Since 08/09/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSExcCoEn(cProces)
Local lCont := .T.

Default cProces := DAK->DAK_PROCES

If lCont
	lCont := OMSValCoEn(2,cProces)
EndIf

If lCont
	OMSSupCoEn(2,,,cProces)
EndIf

Return lCont

//-----------------------------------------------------------
/*/{Protheus.doc} OMSMotCoEn
Envia/Retira carga ao motorista
@author Valdemar Roberto Mognon
@version P12
@Since	24/08/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSMotCoEn(nAcao,cProces)
Local lOk       := .T.
Local nCntFor2  := 0
Local nRegistro := 0
Local cEndPoint := ""
Local cJson     := ""
Local aResult   := {}

Default nAcao   := 0
Default cProces := DAK->DAK_PROCES

oColEnt := TMSBCACOLENT():New("DN1")
If oColEnt:DbGetToken()
	DN1->(DbGoTo(oColEnt:config_recno))

	//-- Inicializa a estrutura
	aStruct := TMSMntStru(DN1->DN1_CODFON,.T.)

	//-- Localiza primeiro registro da estrutura
	For nCntFor2 := 1 To Len(aStruct)
		//-- Não é adicional de ninguém, ainda não foi processado e não dependente de ninguém
		If (Ascan(aStruct,{|x| x[11] + x[12] == aStruct[nCntFor2,1] + aStruct[nCntFor2,2]}) == 0) .And. ;
											aStruct[nCntFor2,10] == "2" .And. Empty(aStruct[nCntFor2,6])
			Exit
		EndIf
	Next nCntFor2

	If ExisteDN5(aStruct[nCntFor2,1],aStruct[nCntFor2,2],PadR(cProces,Len(DN5->DN5_PROCES)),{"1","2"},@nRegistro)
		DN5->(DbGoTo(nRegistro))
		If (nAcao == 1 .And. DN5->DN5_STATUS == "1" .Or. DN5->DN5_STATUS == "2") .Or. (nAcao == 2 .And. DN5->DN5_STATUS == "1")
			If DN5->DN5_STATUS == "1"
				If (aStatusVia := TMSAC30GDV(DN5->DN5_IDEXT,,.F.))[1]
					If (nAcao == 1 .And. aStatusVia[2] != "AGUARDANDO_DESPACHO") .Or. (nAcao == 2 .And. aStatusVia[2] != "AGUARDANDO_CONFIRMACAO_DESPACHO")
						Help(" ", , STR0004,,STR0005 + aStatusVia[2], 2, 1)	//-- "Não é possível estonar a carga" # "Carga já manipulada no portal de Coleta/entrega com status diferente do esperado. Status atual: "
						lOk := .F.
					Else
						If nAcao == 1	//-- Envia
							cEndPoint := "coletaentrega/core/api/v1/viagens/" + AllTrim(DN5->DN5_IDEXT) + "/despachar"
						Else	//-- Retira
							cEndPoint := "coletaentrega/core/api/v1/viagens/" + AllTrim(DN5->DN5_IDEXT) + "/estornarDespacho"
						EndIf
						If !Empty(DN5->DN5_IDEXT)
							If !(aResult := oColEnt:Post(cEndPoint,cJson))[1]
								TMSAC30Err("TMSAI86002",oColEnt:last_error,oColEnt:desc_error)
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSSupCoEn
Rotina de suporte que chama as funções da integração com coleta/entrega.
@author Valdemar Roberto Mognon
@version P12
@Since 15/09/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSSupCoEn(nAcao,oObjBrowse,oMrkBrowse,cProces,nEnvRet)

Default nAcao   := 0
Default nEnvRet := 0

If nAcao == 1	//-- Gravação da DN5
	FWMsgrun(,{|| OMSGrvDN5(oObjBrowse,oMrkBrowse)},STR0010,STR0012)	//-- "Aguarde" # "Gerando Histórico de Integração"
ElseIf nAcao == 2	//-- Estorno
    FWMsgrun(,{|| OMSEstCoEn(cProces)},STR0010,STR0011)	//-- "Aguarde" # "Estornando Integração com Coleta/Entrega"
ElseIf nAcao == 3	//-- Envio ao Portal
    FWMsgrun(,{|| TMSAI86AUX(cProces)},STR0006,STR0007)	//-- "Job de Envio de Integração" # "Aguarde enquanto o Job é executado."
ElseIf nAcao == 4	//-- Envio/Retirada do Motorista
	If nEnvRet == 1 .Or. nEnvRet == 2
	    FWMsgrun(,{|| OMSMotCoEn(nEnvRet,cProces)},STR0010,Iif(nEnvRet == 1,STR0013,STR0014) + STR0015)	//-- "Aguarde" # "Enviando ao " # "Retirando do " # "Motorista"
	EndIf
EndIf

Return

//-----------------------------------------------------------
/*/{Protheus.doc} OMSQtdCarg
Retorna a quantidade de cargas referentes ao filtro enviado.
@author Valdemar Roberto Mognon
@version P12
@Since 16/09/2022
@version 1.0
/*/
//-----------------------------------------------------------
Function OMSQtdCarg(cFiltro,nRegistro)
Local nRet      := 0
Local aAreas    := {GetArea()}
Local cQuery    := ""
Local cAliasDAK := ""

Default cFiltro   := ""
Default nRegistro := 0

If !Empty(cFiltro)
	cAliasDAK := GetNextAlias()
	cQuery := "SELECT COUNT(DAK_COD) QUANTIDADE "
	cQuery += "  FROM " + RetSqlName("DAK") + " DAK "
	cQuery += " WHERE DAK.DAK_FILIAL = '" + xFilial("DAK") + "' "
	cQuery += cFiltro
	cQuery += "   AND DAK.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDAK,.F.,.T.)
	If (cAliasDAK)->(!Eof())
		nRet := (cAliasDAK)->QUANTIDADE
	EndIf
	(cAliasDAK)->(DbCloseArea())

	//-- Se existir apenas um registro devolve o recno
	If nRet == 1
		cAliasDAK := GetNextAlias()
		cQuery := "SELECT DAK.R_E_C_N_O_ REGISTRO "
		cQuery += "  FROM " + RetSqlName("DAK") + " DAK "
		cQuery += " WHERE DAK.DAK_FILIAL = '" + xFilial("DAK") + "' "
		cQuery += cFiltro
		cQuery += "   AND DAK.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDAK,.F.,.T.)
		If (cAliasDAK)->(!Eof())
			nRegistro := (cAliasDAK)->REGISTRO
		EndIf
		(cAliasDAK)->(DbCloseArea())
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return nRet
