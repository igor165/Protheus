#INCLUDE "JURA063.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWMBROWSE.CH"

Static cNumCaso     := SuperGetMV('MV_JCASO1',, '1') // 1 = Depende do Cliente; 2 = Independente de Cliente
Static lPreservCaso := (cNumCaso == "2") .And. SuperGetMV('MV_JCASO3',, .F.) // .T./.F. = Preserva ou não o número do Caso de Origem quando for Independente de Cliente.

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA063()
Tela de remanejamento de casos.

@author Jacques Alves Xavier
@since 24/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA063(cClient, cLoja, cCaso, cCliDes, cLojaDes, cCasoDest, lAutomato)
Local oCliOri     := Nil
Local oLojaOri    := Nil
Local oGetCaso    := Nil
Local oCliDes     := Nil
Local oLojaDes    := Nil
Local cGetCaso    := Iif(Empty(cCaso), Criavar('NVE_NUMCAS', .F.), cCaso)
Local cPart       := JurUsuario(__CUSERID)
Local oPanel      := Nil
Local oPanelA     := Nil
Local oPanelB     := Nil
Local oGroupA     := Nil
Local oGroupB     := Nil
Local lLojAuto    := SuperGetMv("MV_JLOJAUT", .F., "2") == "1"  //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
Local nLocCas     := 0
Local bBntOk      := {||}
Local lIsCaso     := IsInCallStack('JURA070')
Local aRet        := {.F., ""}

Private cGetClie  := Iif(Empty(cClient), Criavar('NVE_CCLIEN', .F.), cClient)
Private cGetLoja  := Iif(Empty(cLoja)  , Criavar('NVE_LCLIEN', .F.), cLoja  )

Default cCasoDest := ""
Default lAutomato := .F.

	If lAutomato
		aRet := J063Remanj(cClient, cLoja, cCaso, cCliDes, cLojaDes, cCasoDest, lAutomato)
	Else
		If !Empty(cPart)
			oModal := FWDialogModal():New()
			oModal:SetFreeArea(260, 150)
			oModal:SetEscClose(.T.)
			oModal:SetBackground(.T.) //Escurece o fundo da janela
			oModal:SetTitle(STR0023) //# Remanejamento de Casos
			oModal:CreateDialog()
			oMainColl := oModal:GetPanelMain()

			oPanel := tPanel():New(0,0,'',oMainColl,,,,,,0,0,.F.,.F.)
			oPanel:Align := CONTROL_ALIGN_ALLCLIENT

			oGroupA := TGroup():New( 008, 018, 058, 210, STR0024, oPanel, , , .T. )  //Origem
			oPanelA := tPanel():New(008+8, 018+3,'',oGroupA,,,,,/*CLR_YELLOW*/,180,40,.F.,.F.)

			oCliOri := TJurPnlCampo():New(010, 005, 050, 022, oPanelA, ,'NUE_CCLIEN', {|| }, {|| }, cGetClie, Nil, Nil, 'SA1NUH') //"Cliente"
			oCliOri:SetValid( {|| JurTrgGCLC( , , @oCliOri, @cGetClie, @oLojaOri, @cGetLoja, @oGetCaso, , "CLI") })

			oLojaOri := TJurPnlCampo():New(010, 060, 040, 022, oPanelA, ,'NVE_LCLIEN', {|| }, {|| }, cGetLoja) //"Loja"
			oLojaOri:SetValid( {|| JurTrgGCLC( , , @oCliOri, @cGetClie, @oLojaOri, @cGetLoja, @oGetCaso, , "LOJ") .And. J063VldCl("O", cGetClie, cGetLoja)})
			oLojaOri:Visible(!lLojAuto)

			Iif(!lLojAuto, nLocCas := 110, nLocCas := 70)
			oGetCaso := TJurPnlCampo():New(010, nLocCas, 050, 022, oPanelA, ,'NUE_CCASO', {|| }, {|| }, cGetCaso, Nil, Nil, 'NVENX0') //"Caso"
			oGetCaso:SetValid({|| JurTrgGCLC( , , @oCliOri, @cGetClie, @oLojaOri, @cGetLoja, @oGetCaso, , "CAS") })
			oGetCaso:SetWhen( {|| (cNumCaso == '2') .Or. (!Empty(oLojaOri:GetValue()) .And. !Empty(oCliOri:GetValue())) } )

			oGroupB := TGroup():New( 068, 018, 118, 210, STR0025, oPanel, , , .T. )  //Origem
			oPanelB := tPanel():New( 068+8, 018+3,'',oGroupB, , , , ,/*CLR_YELLOW*/,180,40,.F.,.F.)

			oCliDes := TJurPnlCampo():New(010, 005, 050, 022, oPanelB, ,'NUE_CCLIEN', {|| }, {|| }, Nil, Nil, Nil, 'SA1NUH') //"Cliente"
			oCliDes:SetValid( {|| JurTrgGCLC( , , @oCliDes, , @oLojaDes, , , , "CLI") })
			Iif(!Empty(cGetCaso), oCliDes:SetFocus(), Nil)

			oLojaDes := TJurPnlCampo():New(010, 060, 040, 022, oPanelB, ,'NVE_LCLIEN') //"Loja"
			oLojaDes:SetValid( {|| JurTrgGCLC( , , @oCliDes, , @oLojaDes, , , , "LOJ") .And. J063VldCl("O", oCliDes:GetValue(), oLojaDes:GetValue())})
			oLojaDes:Visible(!lLojAuto)

			bBntOk := {|| Processa({|| aRet := J063Remanj(oCliOri:GetValue(), oLojaOri:GetValue(), oGetCaso:GetValue(), ;
														  oCliDes:GetValue(), oLojaDes:GetValue())}, STR0088, STR0111, .F.), ; // 'Aguarde...' e 'Gerando...
									   Iif(lIsCaso .And. aRet[1], oModal:oOwner:End(), Nil) }

			oModal:addOkButton(bBntOk)
			oModal:addCloseButton()
			oModal:activate()

		Else
			ApMsgInfo(STR0022) // "É necessário vincular o usuário do sistema a um participante antes de utilizar a rotina de remanejamento."
		EndIf
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063Remanj()
Rotina que valida e efetua o remanejamento de casos

@Param  cCliOri   - Cliente origem
@Param  cLojOri   - Loja Origem
@Param  cCaso     - Caso origem (opcional)
@Param  cCliDes   - Cliente destino
@Param  cLojDes   - Loja destino
@Param  lAutomato - Tratamento da rotina de automação

@author Jacques Alves Xavier
@since 25/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function J063Remanj(cCliOri, cLojOri, cCaso, cCliDes, cLojDes, cCasoDest, lAutomato)
Local lRet        := .T.
Local cQuery      := ""
Local cGrpDes     := Posicione('SA1', 1, xFilial('SA1') + cCliDes + cLojDes, 'A1_GRPVEN')
Local aCasos      := {}
Local nI          := 0
Local cMsg        := ""
Local cRet        := ""
Local lSitCaso    := NVE->(ColumnPos("NVE_SITCAD")) > 0

Private oModelNVE := Nil //
Private oModelNUE := Nil //
Private oModelNV4 := Nil // *** Infelizmente isto é necessário para melhora de performance! Felipe Conti ***
Private oModelNVY := Nil //
Private oModelNSZ := Nil //
Private oModelNUV := Nil //
Private oModelNWM := Nil //

Default cCasoDest := Criavar('NVE_NUMCAS', .F.)
Default lAutomato := .F.

	If !Empty(cCliOri) .And. !Empty(cLojOri) .And. !Empty(cCliDes) .And. !Empty(cLojDes)
		cQuery := " SELECT NVE_NUMCAS " + IIF(lSitCaso, ", NVE_SITCAD", ", '1' NVE_SITCAD")
		cQuery +=   " FROM " + RetSqlName( "NVE" ) + " NVE "
		cQuery +=  " WHERE NVE.D_E_L_E_T_ = ' ' "
		cQuery +=    " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
		cQuery +=    " AND NVE.NVE_CCLIEN = '" + cCliOri + "' "
		cQuery +=    " AND NVE.NVE_LCLIEN = '" + cLojOri + "' "
		If !Empty(cCaso)
			cQuery +=  " AND NVE.NVE_NUMCAS = '" + cCaso + "' "
		EndIf
		cQuery +=  " ORDER BY NVE.NVE_CCLIEN, NVE.NVE_LCLIEN, NVE.NVE_NUMCAS "

		aCasos := JurSQL(cQuery, {"NVE_NUMCAS","NVE_SITCAD"})
	Else
		lRet := .F.
		cRet := STR0016 //#"É necessário preencher as informações de cliente origem e destino antes de confirmar."
		ApMsgAlert(cRet, STR0023) //# Remanejamento de Casos
	EndIf

	// Verificar se o caso definitivo está sendo remanejado para cliente provisório
	If lRet .And. lSitCaso .And. JurGetDados("NUH", 1, xFilial("NUH") + cCliDes + cLojDes, "NUH_SITCAD") == "1"
		If aScan(aCasos, {|c| c[2] == "2"}) > 0
			lRet := .F.
			cRet := STR0121 // "Não é permitido remanejar casos definitivos para clientes provisórios."
			ApMsgAlert(cRet, STR0023) // "Remanejamento de Casos"
		EndIf
	EndIf

	If lRet .And. ExistBlock( 'JA063CAN' )
		/*
		PARAMIXB
		Variavel
		cCliOri      [01] C Cód. Cliente Origem
		cLojOri      [02] C Cód. Loja Origem
		cCaso        [03] C Cód. Caso  Origem
		cCliDes      [01] C Cód. Cliente Destino
		cLojDes      [02] C Cód. Loja Destino
		*/

		lRet := ExecBlock( 'JA063CAN', .F., .F. , {cCliOri, cLojOri, cCaso, cCliDes, cLojDes } )
	EndIf

	If lRet .And. !(SuperGetMV('MV_JCASO1',, '1') == '1' .And. SuperGetMV('MV_JCASO3',, .F.)) .And. (cCliOri == cCliDes .And. cLojOri == cLojDes)
		lRet := .F.
		cRet := STR0108 //#"Não é possível remanejar um caso para mesmo cliente."
		ApMsgAlert(cRet, STR0023)
	EndIf

	If lRet

		If !Empty(aCasos)

			ProcRegua(6) // Quantidade de models a serem carregados
			IncProc(STR0102) // "Carregando Caso..."
			oModelNVE := FWLoadModel("JURA070")
			IncProc(STR0103) // "Carregando TS..."
			oModelNUE := FWLoadModel("JURA144")
			IncProc(STR0104) // "Carregando Despesa..."
			oModelNVY := FWLoadModel("JURA049")
			IncProc(STR0105) // "Carregando Tabelado..."
			oModelNV4 := FWLoadModel("JURA027")
			IncProc(STR0106) // "Carregando Processo..."
			oModelNSZ := FWLoadModel("JURA095")
			IncProc(STR0106) // "Carregando Processo..."
			oModelNUV := FWLoadModel("JURA166")
			IncProc(STR0107) // "Carregando Tabelado em Lote..."
			oModelNWM := FWLoadModel("JURA109")
			ProcRegua(0)
			IncProc(STR0088) // "Aguarde..."

			For nI := 1 To Len(aCasos)

				If lPreservCaso // Independente de Cliente/Loja e Preserva o numero do caso origem.
					cCasoDest := aCasos[nI][1]
				EndIf

				cMsg += JRemCas(cCliOri, cLojOri, aCasos[nI][1], cGrpDes, cCliDes, cLojDes, cCasoDest)

			Next nI

			If Empty(cMsg)
				cRet := STR0006 //#"Remanejamento realizado com sucesso."
				Iif(!lAutomato, ApMsgInfo(cRet, STR0023), Nil) //# Remanejamento de Casos
			Else
				cRet := STR0007 + CRLF + CRLF + cMsg  //#"Erro no remanejamento dos casos: "
				lRet := .F.
				AutoGrLog(cRet)
				Iif(!lAutomato, MostraErro(), Nil)
			EndIf
		Else
			lRet := .F.
			cRet := STR0072 + CRLF + CRLF + STR0073 //#"Não foram localizados casos para remanejar." ##"É possível que o cliente não tenha casos ou seus casos já tenham sido remanejados."
			Iif(!lAutomato, ApMsgAlert(cRet, STR0023), Nil) //## Remanejamento de Casos
		EndIf

	EndIf

Return {lRet, cRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} JRemCas
Rotina para Remanejar o caso

@author Jacques Alves Xavier
@since 25/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRemCas(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasoDest)
Local aDados    := {}
Local nI        := 0
Local cCasNovo  := ""
Local aArea     := GetArea()
Local cRet      := STR0036 + cCasoOri + ": " + CRLF // "Remanejando caso "
Local cAux      := ""
Local aCasNovo  := {}
Local lExistia  := .F.
Local lEncerrei := .F.
Local nRecnoOri := 0

Default cCasoDest := ""

	Begin Transaction

	NVE->(dbSetOrder(1))
	NVE->(dbSeek(xFilial('NVE') + cCliOri + cLojOri + cCasoOri))
	nRecnoOri := NVE->(Recno())

	For nI:= 1 to NVE->(Fcount())
		aADD(aDados, { NVE->(FieldName(nI)), NVE->(FieldGet(nI)) })
	Next

	If NVE->NVE_SITUAC == "1" // Se estiver aberto
		lEncerrei := .T.
		RecLock("NVE",.F.)
		NVE->NVE_SITUAC := "2" // Encerro para passar nas validações da tela de caso... Mais abaixo na JA063ENCER o caso é encerrado corretamente!
		NVE->(MsUnlock())
		//Grava na fila de sincronização
		J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
	EndIf

	lExistia := !Empty(cCasoDest) .And. ExistCaso(cCliDes, cLojDes, cCasoDest, .F., 1)
	If Empty(cCasoDest) .Or. !lExistia .Or. lPreservCaso

		If lPreservCaso // Independente de Cliente/Loja e Preserva o numero do caso origem.
			cAux := J063Reabre(cCliDes, cLojDes, cCasoDest) // Reabre o caso se estiver encerrado
		EndIf

		If Empty(cAux)
			aCasNovo := J063NovCas(aDados, cGrpDes, cCliDes, cLojDes, cCasoDest, lExistia) // Cria novo caso
			cCasNovo := aCasNovo[1]
			cAux     += aCasNovo[2]
		EndIf

	Else
		cCasNovo := cCasoDest
	EndIf

	If !Empty(cCasNovo) .And. Empty(cAux)

		cRet += STR0037 + cCasNovo + CRLF // "Caso novo: "

		IIF(Empty(cAux), cAux += JA063NSZ(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo), ) // Processos
		IIF(Empty(cAux), cAux += JA063NUE(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo), ) // Time Sheet
		IIF(Empty(cAux), cAux += JA063NV4(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo), ) // Lançamento Tabelado
		IIF(Empty(cAux), cAux += JA063NVY(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo), ) // Despesas

		// Não mudar a ordem de chamada das funções ABAIXO (JA063Hist, JA063ENCER e JA063TBLote)
		If Empty(cAux) .And. lPreservCaso
			cAux += JA063Hist(nRecnoOri,cCasNovo) // Histórico do remanejamento
		EndIf
		
		If Empty(cAux)
			cAux += JA063ENCER(cCliOri,cLojOri,cCasoOri,cGrpDes,cCliDes,cLojDes,cCasNovo) // Encerrar Caso Origem
		EndIf
		
		IIF(Empty(cAux), cAux += JA063TBLote(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo), )  // "Lançamento tabelado em lote"

		// Contratos
		If Empty(cAux) .And. !lExistia //Se o caso já exisitia não deve fazer.
			cAux += JA063NT0(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo) // Vincula o caso novo ao Contrato
		EndIf

		If !Empty(cAux)
			If lEncerrei // Se deu algum erro e EU encerrei o caso então reabro.
				NVE->(dbGoTo(nRecnoOri))
				RecLock("NVE", .F.)
				NVE->NVE_SITUAC := '1' // Reabro o caso.
				NVE->(MsUnlock())
				//Grava na fila de sincronização
				J170GRAVA("NVE", xFilial("NVE") + NVE->NVE_CCLIEN + NVE->NVE_LCLIEN + NVE->NVE_NUMCAS, "4")
			EndIf
		EndIf

	Else
		cAux += STR0038 // "Erro ao incluir Caso novo."
	EndIf

	If Empty(cAux)
		cRet := ""
	Else
		cRet += cAux + CRLF + STR0035 + CRLF
		DisarmTransaction()

		While __lSX8  //Libera os registros usados na transação
			RollBackSX8()
		EndDo

	EndIf

	End Transaction
	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063NovCas
Rotina para criar novo caso

@author Jacques Alves Xavier
@since 25/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J063NovCas(aDados, cGrpDest, cCliDes, cLojDes, cCasoDest, lExistia)
Local aArea       := GetArea()
Local lOk         := .T.
Local cRet        := ""
Local cCodNovo    := ""
Local cCliOld     := JA063GETCP(aDados, 'NVE_CCLIEN')
Local cLojOld     := JA063GETCP(aDados, 'NVE_LCLIEN')
Local cCasOld     := JA063GETCP(aDados, 'NVE_NUMCAS')
Local nI          := 0
Local cCampo      := ""
Local xData       := Nil
Local lForce      := .F. //Força o LoadValue no campo
Local aSigla      := {}
Local lAltera     := .F.

Default cCasoDest := ""
Default lExistia  := .F.

	DbSelectArea("NVE")
	If lExistia .And. !Empty(cCasoDest) // Por garantia verifico se esta preenchido!
		NVE->(dbSetOrder(1))
		NVE->(dbSeek(xFilial("NVE") + cCliDes + cLojDes + cCasoDest))
		oModelNVE:SetOperation(MODEL_OPERATION_UPDATE)
		lAltera := .T.
	Else
		oModelNVE:SetOperation(MODEL_OPERATION_INSERT)
	EndIf
	oModelNVE:Activate()

	For nI := 1 To Len(aDados)

		cCampo := Alltrim(aDados[nI][1])
		xData  := aDados[nI][2]
		lForce := .F.

		Do Case
			Case cCampo == "NVE_CGRPCL"
				xData  := cGrpDest
				lForce := !Empty(cCasoDest) //Se manter a numeração do caso, forca o loadvalue para mudar o cliente e loja
			Case cCampo == "NVE_CCLIEN"
				xData  := cCliDes
				lForce := !Empty(cCasoDest)
			Case cCampo == "NVE_LCLIEN"
				xData  := cLojDes
				lForce := !Empty(cCasoDest)
			Case cCampo == "NVE_NUMCAS"
				lForce := !Empty(cCasoDest)
				xData  := Iif(lForce, cCasoDest, "") //Se o caso destino for novo, manda vazio parar obdecer o inicializador padrão de autonumeração do caso.
			Case "NVE_CPART" $ cCampo //Altera o campo de CPART para SIGLA, obedencendo as regras de validação do modelo
				aSigla := JRetSigla(cCampo, xData)
				cCampo := aSigla[1]
				xData  := aSigla[2]
			Case cCampo == "NVE_REVISA"
				xData  := "2"
			Case cCampo == "NVE_CCLIAN"
				xData  := cCliOld
			Case cCampo == "NVE_CLOJAN"
				xData  := cLojOld
			Case cCampo == "NVE_CCASAN"
				xData  := cCasOld
			Case cCampo == "NVE_TITSUG"
				lForce := .T.
			Case cCampo $ "NVE_CCLINV|NVE_CLJNV|NVE_CCASNV" .And. lAltera // Campos de cliente, loja e caso novo
				xData := ""
		EndCase

		If !Empty(xData)
			If oModelNVE:CanSetValue('NVEMASTER', cCampo) .And. !lForce
				lOk := oModelNVE:SetValue('NVEMASTER', cCampo, xData )
			Else
				lOk := oModelNVE:LoadValue('NVEMASTER', cCampo, xData )
			EndIf
		EndIf

		If !lOk
			Exit
		EndIf
	Next nI

	If lOk
		If Empty(cCasoDest)
			cCodNovo := oModelNVE:GetValue('NVEMASTER', 'NVE_NUMCAS')
		Else
			cCodNovo := cCasoDest
		EndIf

		Iif(Empty(cRet), Processa( {|| cRet += JA63NVEX(oModelNVE, "NUU", "NUU_CCASO" , cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCodNovo) }, STR0036 + cCasOld, STR0085 + STR0074, .F.), Nil) // #"Remanejando caso " ##"Remanejando " ### "Histórico Caso"
		Iif(Empty(cRet), Processa( {|| cRet += JA63NVEX(oModelNVE, "NUW", "NUW_CCASO" , cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCodNovo) }, STR0036 + cCasOld, STR0085 + STR0040, .F.), Nil) // #"Remanejando caso " ##"Remanejando " ### "Excessao Da Tab Honor - Cat"
		Iif(Empty(cRet), Processa( {|| cRet += JA63NVEX(oModelNVE, "NV0", "NV0_CCASO" , cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCodNovo) }, STR0036 + cCasOld, STR0085 + STR0040, .F.), Nil) // #"Remanejando caso " ##"Remanejando " ### "Excessao Da Tab Honor - Part"
		Iif(Empty(cRet), Processa( {|| cRet += JA63NVEX(oModelNVE, "NUK", "NUK_NUMCAS", cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCodNovo) }, STR0036 + cCasOld, STR0085 + STR0041, .F.), Nil) // #"Remanejando caso " ##"Remanejando " ### "Participação"
		Iif(Empty(cRet), Processa( {|| cRet += JA63NVEX(oModelNVE, "NVF", "NVF_NUMCAS", cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCodNovo) }, STR0036 + cCasOld, STR0085 + STR0041, .F.), Nil) // #"Remanejando caso " ##"Remanejando " ### "Participação"
		Iif(Empty(cRet), Processa( {|| cRet += JA63NVEX(oModelNVE, "NT7", "NT7_CCASO" , cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCodNovo) }, STR0036 + cCasOld, STR0085 + STR0042, .F.), Nil) // #"Remanejando caso " ##"Remanejando " ### "Título do Caso por Idioma"
		Iif(Empty(cRet), Processa( {|| cRet += JA63NVEX(oModelNVE, "NWL", "NWL_NUMCAS", cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCodNovo) }, STR0036 + cCasOld, STR0085 + STR0086, .F.), Nil) // #"Remanejando caso " ##"Remanejando " ### "Condição de Exito"

	Else
		cRet += JA063GetErr(oModelNVE, {{'NVE_NUMCAS', cCodNovo}}, STR0015)  //"Erro ao criar o novo caso para o remanejamento"
	EndIf

	If Empty(cRet)
		lOk := (oModelNVE:VldData() .And. oModelNVE:CommitData())

		If !lOk
			cRet += JA063GetErr(oModelNVE, {{'NVE_NUMCAS', cCodNovo}}, STR0015)  //"Erro ao criar o novo caso para o remanejamento"
		EndIf
	EndIf
	oModelNVE:DeActivate()

	RestArea(aArea)

Return {cCodNovo, cRet}



//-------------------------------------------------------------------
/*/{Protheus.doc} JRetSigla
Rotina para retornar um array com campo e o codigo da sigla, quando
informado o campo de participante e codigo da NVE.

@Param cCampo    Campo de paricipante da NVE
@Param cCodigo   Código do participante referente ao campo.

@return aRet     Array com o campo e codigo da sigla

@Obs protecão para criação campo de participante pelo cliente. 

@author Luciano Pereira dos Santos
@since 15/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JRetSigla(cCampo, cCodigo)
	Local aRet     := {}
	Local lCpoUser := GetSx3Cache(cCampo, "X3_PROPRI") == "U"

	If !lCpoUser
		cCampo  := "NVE_SIGLA" + SubStr(cCampo, Len(cCampo), 1)
		cCodigo := JurGetDados('RD0', 1, xFilial('RD0') + cCodigo, 'RD0_SIGLA')
	EndIf
	
	aRet := {cCampo, cCodigo}

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} J063GetLanc
Rotina para retornar um array com os lançamentos do caso de origem
para remanejar.

@Param cTab    Alias da tabela do lançamento Ex: "NUE"
@Param cCliOri Cliente de origem
@Param cLojOri Loja do cliente de origem
@Param cCaso   Caso a ser remanejado

@author Luciano Pereira dos Santos
@since 07/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J063GetLanc(cTab, cCliOri, cLojOri, cCaso, cFiltro)
	Local cQuery := ""
	Local aSQL   := {}

	Default cFiltro := ""

	cQuery := "SELECT R_E_C_N_O_ NRECNO "
	cQuery +=   "FROM " + RetSqlName(cTab) + " "
	cQuery += " WHERE " + cTab + "_FILIAL = '" + xFilial(cTab) + "' "
	cQuery +=   " AND " + cTab + "_CCLIEN = '" + cCliOri + "' "
	cQuery +=   " AND " + cTab + "_CLOJA  = '" + cLojOri + "' "
	cQuery +=   " AND " + cTab + "_CCASO  = '" + cCaso + "' "
	cQuery +=   " AND " + cTab + "_SITUAC = '1' "
	If !Empty(cFiltro)
		cQuery += " AND " + cFiltro
	EndIf
	cQuery +=   " AND " + cTab + "_CPREFT = '" + Criavar(cTab + '_CPREFT', .F.) + "' "
	cQuery +=   " AND D_E_L_E_T_ = ' ' "

	aSQL := JurSQL(cQuery, {"NRECNO"})

Return aSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063NUE
Rotina para remanejar TS

@author Felipe Bonvicini Conti
@since 28/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063NUE(cCliOri, cLojOri, cCaso, cGrpCli, cCliDes, cLojDes, cCasNovo)
Local lOk       := .T.
Local cCodCat   := ""
Local aArea     := GetArea()
Local cNUECod   := ""
Local cRet      := CRLF + STR0043 + CRLF // "Time Sheet: "
Local nCtTS     := 0
Local nI        := 0
Local nRemanj   := 0
Local aEbil     := {.F.,,,,,,,.F.}
Local aSQL      := {}
Local cCodDoc   := ""
Local cCodFase  := ""
Local cCodTaref := ""
Local cCodAtiv  := ""
Local lEbilOk   := .F.

aSQL := J063GetLanc("NUE", cCliOri, cLojOri, cCaso)

nCtTS := Len(aSQL)
If nCtTS > 0

	ProcRegua(nCtTS)
	DbSelectArea("NUE")

	For nI := 1 To nCtTS

		IncProc(STR0080 + AllTrim(Str(nI)) + STR0084 + AllTrim(Str(nCtTS)))//"Remanejando TS: " e " de "

		NUE->(dbGoto(aSQL[nI][1]))

		oModelNUE:SetOperation(MODEL_OPERATION_UPDATE)
		oModelNUE:Activate()

		cNUECod := NUE->NUE_COD
		cCodCat := NUE->NUE_CATIVI
		cCodDoc := NUE->NUE_CDOC
		If !Empty(cCodDoc)
			cCodFase  := NUE->NUE_CFASE
			cCodTaref := NUE->NUE_CTAREF
			cCodAtiv  := NUE->NUE_CTAREB
		EndIf

		IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CGRPCL', cGrpCli),  Nil)
		IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CCLIEN', cCliDes),  Nil) //LoadValue para nao executar validacao, apenas na loja
		IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CLOJA' , cLojDes),  Nil)
		IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CCASO' , cCasNovo), Nil)
		IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CATIVI', cCodCat),  Nil)

		// Preenche as informações e-billing com o conteúdo original quando o Doc do Cli Origem for igual ao Cli Destino
		If lOk .And. !Empty(cCodDoc) .And. cCodDoc == oModelNUE:GetValue('NUEMASTER', 'NUE_CDOC')
			IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CTAREB', cCodAtiv),  Nil)
			IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CFASE' , cCodFase),  Nil)
			IIF(lOk, lOk := oModelNUE:SetValue('NUEMASTER', 'NUE_CTAREF', cCodTaref), Nil)
			lEbilOk := .T.
		EndIf

		If lOk .And. !lEbilOk
			If JA144Ebil(cCliOri, cLojOri, cCliDes, cLojDes, cNUECod)
				If nRemanj < 1
					aEbil := JA148AEBIL(cCliDes, cLojDes,, .T.,, cCasNovo)
					nRemanj += 1
				EndIf

				If lOk := aEbil[1]
					lOk := JA063REbil(aEbil[2], aEbil[5], aEbil[6], aEbil[7])
				EndIf
			EndIf
		EndIf

		If lOk
			lOk := oModelNUE:VldData() .And. oModelNUE:CommitData()
		EndIf

		If !lOk
			cRet += JA063GetErr(oModelNUE, {{'NUE_COD', cNUECod}}, STR0001) //"Erro no remanejamento dos time-sheets"
			oModelNUE:DeActivate()
			Exit
		Else
			oModelNUE:DeActivate()
		EndIf

	Next nI

EndIf

If lOk
	cRet := ""
	ProcRegua(0)
	IncProc(STR0036 + cCaso) // "Remanejando caso "
EndIf

JurFreeArr(@aSQL)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063NV4
Rotina para remanejar Lançamento Tabelado

@author Felipe Bonvicini Conti
@since 28/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063NV4(cCliOri, cLojOri, cCaso, cGrpCli, cCliDes, cLojDes, cCasNovo)
Local lOk        := .T.
Local aArea      := GetArea()
Local cNV4Cod    := ""
Local cRet       := CRLF + STR0044 + CRLF // "Lançamento Tabelado: "
Local nCtLT      := 0
Local nI         := 0
Local aSQL       := {}
Local cTipoServ  := ""

	aSQL := J063GetLanc("NV4", cCliOri, cLojOri, cCaso)

	nCtLT := Len(aSQL)
	If nCtLT > 0

		ProcRegua(nCtLT)
		dbSelectArea("NV4")
		For nI := 1 To nCtLT

			IncProc(STR0081 + AllTrim(Str(nI)) + STR0084 + AllTrim(Str(nCtLT)))//"Remanejando Tabelados: " e " de "

			NV4->(dbGoto(aSQL[nI][1]))

			oModelNV4:SetOperation(MODEL_OPERATION_UPDATE)
			oModelNV4:Activate()
			cTipoServ := oModelNV4:GetValue('NV4MASTER', 'NV4_CTPSRV')

			IIF(lOk, lOk:= oModelNV4:SetValue('NV4MASTER', 'NV4_CGRUPO', cGrpCli) , Nil)
			IIF(lOk, lOk:= oModelNV4:LoadValue('NV4MASTER', 'NV4_CCLIEN', cCliDes), Nil) //LoadValue para nao executar validacao, apenas na loja
			IIF(lOk, lOk:= oModelNV4:SetValue('NV4MASTER', 'NV4_CLOJA' , cLojDes) , Nil)
			IIF(lOk, lOk:= oModelNV4:SetValue('NV4MASTER', 'NV4_CCASO' , cCasNovo), Nil)
			IIF(lOk, lOk:= oModelNV4:SetValue('NV4MASTER', 'NV4_CTPSRV' , cTipoServ), Nil) // Gatilho do cliente/caso apaga o tipo de serviço

			lOk := lOk .And. oModelNV4:VldData() .And. oModelNV4:CommitData()
			If !lOk
				cRet += JA063GetErr(oModelNV4, {{'NV4_COD', cNV4Cod}}, STR0002) //"Erro no remanejamento dos lançamentos tabelados"
				oModelNV4:DeActivate()
				Exit
			Else
				oModelNV4:DeActivate()
			EndIf

		Next nI

	EndIf

	If lOk
		cRet := ""
		ProcRegua(0)
		IncProc(STR0036 + cCaso) // "Remanejando caso "
	EndIf

	JurFreeArr(@aSQL)
	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063NVY
Rotina para remanejar Despesas

@author Felipe Bonvicini Conti
@since 28/09/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063NVY(cCliOri, cLojOri, cCaso, cGrpCli, cCliDes, cLojDes, cCasNovo)
Local aArea     := GetArea()
Local cRet      := CRLF + STR0045 + CRLF // "Despeas: "
Local lOk       := .T.
Local nCtDP     := 0
Local nI        := 0
Local aSQL      := {}
Local lJA063DES := ExistBlock( 'JA063DES' )
Local cFiltro   := ""

cFiltro := " NVY_DESDIV = '2' "

aSQL := J063GetLanc("NVY", cCliOri, cLojOri, cCaso, cFiltro)

nCtDP := Len(aSQL)
If nCtDP > 0

	ProcRegua(nCtDP)
	dbSelectArea("NVY")

	For nI := 1 To nCtDP

		IncProc(STR0082 + AllTrim(Str(nI)) + STR0084 + AllTrim(Str(nCtDP)))//"Remanejando Despesas: " e " de "

		NVY->(dbGoto(aSQL[nI][1]))

		oModelNVY:SetOperation(MODEL_OPERATION_UPDATE)
		oModelNVY:Activate()
		cNVYCod := NVY->NVY_COD
		IIF(lOk, lOk := oModelNVY:SetValue('NVYMASTER', 'NVY_CGRUPO', cGrpCli), Nil)
		IIF(lOk, lOk := oModelNVY:LoadValue('NVYMASTER', 'NVY_CCLIEN', cCliDes), Nil) //LoadValue para nao executar validacao, apenas na loja
		IIF(lOk, lOk := oModelNVY:SetValue('NVYMASTER', 'NVY_CLOJA', cLojDes), Nil)
		IIF(lOk, lOk := oModelNVY:SetValue('NVYMASTER', 'NVY_CCASO', cCasNovo), Nil)

		If lOk
			lOk := oModelNVY:VldData() .And. oModelNVY:CommitData()
		EndIf

		If !lOk
			cRet += JA063GetErr(oModelNVY, {{'NVY_COD', cNVYCod}}, STR0003) //"Erro no remanejamento das despesas"
			oModelNVY:DeActivate()
			Exit
		Else
			If lJA063DES
				ExecBlock( 'JA063DES', .F., .F., {cCliOri, cLojOri, cCaso, cCliDes, cLojDes} )
			EndIf

			oModelNVY:DeActivate()
		EndIf

	Next nI

EndIf

If lOk
	cRet := ""
	ProcRegua(0)
	IncProc(STR0036 + cCaso) // "Remanejando caso "
EndIf

JurFreeArr(@aSQL)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063NSZ
Rotina para remanejamento do caso do processo

@Return oModelNSZ	 	Model

@param 	cCliOri      	Código do cliente origem
@param 	cLojOri     	Código da loja origem
@param 	cCaso       	Código do número do caso origem
@param 	cGrpCli  		Código do grupo de cliente origem
@param 	cCliDes  		Código do cliente destino
@param 	cLojDes  		Código da loja destino
@param 	cCasNovo  		Código do número do caso destino

@author Juliana Iwayama Velho
@since 09/16/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063NSZ(cCliOri, cLojOri, cCaso, cGrpCli, cCliDes, cLojDes, cCasNovo)
Local cQuery    := ""
Local aArea     := GetArea()
Local aAreaNSZ  := NSZ->(GetArea())
Local cRet      := CRLF + STR0051 + CRLF // "Processos: "
Local lOk       := .T.
Local cNSZCod   := ""
Local nCtPR     := 0
Local nI        := 0
Local aSQL      := {}
Local lRemProc  := SuperGetMV('MV_JREMPRO', , .T.) // A rotina de remanejamento ira transferir somente os processos em andamento? (.T. -> Sim / .F. -> Nao)
Local cMotProc  := SuperGetMV('MV_JMOTREM', , '') //  Motivo padrão utilizado no remanejamento de Processos encerrados.
Local cPerJus   := SuperGetMV('MV_JTVENJF', , '1') //  Permitir alterar com justificativa as telas bloqueadas no encerramento do processo? (1=Sim;2=Não).
Local cFilProc  := xFilial("NSZ") // Filial do Processo
Local cFilAux   := cFilAnt
Local cUsuAlt   := AllTrim(PswChave(__CUSERID))
Local cJustif   := JurGetDados('NQX', 1, xFilial('NQX') + cMotProc, 'NQX_DESC')

Private c162TipoAS := ""
Private cTipoAsJ   := ""

cQuery += "SELECT NSZ.R_E_C_N_O_ NSZRECNO "
cQuery +=   " FROM " + RetSqlName("NSZ") + " NSZ " //Não verifica a filial pois a NSZ não é compatilhada.
cQuery +=   " WHERE NSZ.NSZ_CCLIEN = '" + cCliOri + "' "
cQuery +=     " AND NSZ.NSZ_LCLIEN = '" + cLojOri + "' "
cQuery +=     " AND NSZ.NSZ_NUMCAS = '" + cCaso   + "' "
If lRemProc
	cQuery += " AND NSZ.NSZ_SITUAC = '1' "
EndIf
cQuery +=     " AND NSZ.D_E_L_E_T_ = ' ' "

aSQL := JurSQL(cQuery, {"NSZRECNO"})

nCtPR := Len(aSQL)
If nCtPR > 0

	ProcRegua(nCtPR)
	dbSelectArea("NSZ")
	For nI := 1 To nCtPR

		IncProc(STR0083 + AllTrim(Str(nI)) + STR0084 + AllTrim(Str(nCtPR)))//"Remanejando Processos: " e " de "

		NSZ->(dbGoTo(aSQL[nI][1]))
		c162TipoAS := NSZ->NSZ_TIPOAS
		cTipoAsJ   := c162TipoAS
		cNSZCod    := NSZ->NSZ_COD

		If !Empty(cFilProc)
			cFilAnt := NSZ->NSZ_FILIAL // Setado ambiente com a filial do processo para correta carga dos filhos.
		EndIf

		oModelNSZ:SetOperation(MODEL_OPERATION_UPDATE)
		oModelNSZ:Activate()

		IIF(lOk, lOk := oModelNSZ:SetValue( 'NSZMASTER', 'NSZ_CGRCLI', cGrpCli ), Nil)
		IIF(lOk, lOk := oModelNSZ:SetValue( 'NSZMASTER', 'NSZ_CCLIEN', cCliDes ), Nil)
		IIF(lOk, lOk := oModelNSZ:SetValue( 'NSZMASTER', 'NSZ_LCLIEN', cLojDes ), Nil)
		IIF(lOk, lOk := oModelNSZ:SetValue( 'NSZMASTER', 'NSZ_NUMCAS', cCasNovo), Nil)

		// Em conversa com o Juridico (André e o Ronaldo) foi alinhado que no remanejamento do processo o cliente e loja do envolvido (NT9) não deveriam ser alterados.

		If lOk .And. NSZ->NSZ_SITUAC == "2" .And. cPerJus == '1'
			If !Empty(cMotProc)
				oModelNUV:SetOperation(MODEL_OPERATION_INSERT)
				oModelNUV:Activate()

				//--Proteção para aumento no tamanho do campo NUV_USUALT
				cUsuAlt := Substr( cUsuAlt, 1, GetSx3Cache("NUV_USUALT", "X3_TAMANHO") )

				IIF(lOk, lOk := oModelNUV:SetValue( 'NUVMASTER', 'NUV_CAJURI', cNSZCod ), Nil)
				IIF(lOk, lOk := oModelNUV:SetValue( 'NUVMASTER', 'NUV_USUALT', cUsuAlt ), Nil)
				IIF(lOk, lOk := oModelNUV:SetValue( 'NUVMASTER', 'NUV_DTALT' , Date()  ), Nil)
				IIF(lOk, lOk := oModelNUV:SetValue( 'NUVMASTER', 'NUV_CMOTIV', cMotProc ), Nil)
				IIF(lOk, lOk := oModelNUV:SetValue( 'NUVMASTER', 'NUV_JUSTIF', cJustif  ), Nil)
	
				If lOk
					lOk := oModelNUV:VldData() .And. oModelNUV:CommitData()
				EndIf
	
				If !lOk
						cRet += JA063GetErr(oModelNUV, {{'NUV_CAJURI',cNSZCod}}, STR0005) //"O Processso"
					Exit
				EndIf
	
				oModelNUV:DeActivate()
				oModelNSZ:Activate() // Volta ao modelo da NSZ
			Else
				cRet += JA063GetErr(Nil, {{'NSZ_COD', cNSZCod}}, STR0119 + CRLF + CRLF + STR0120) // "O parâmetro 'MV_JTVENJF', que permite alterar processos encerrados com justificativa, está ativo, porém o parâmetro 'MV_JMOTREM', com o motivo de alteração padrão para remanejamento não está preenchido."
				lOk := .F.                                                                        // "Desabilite o parâmetro 'MV_JTVENJF' ou informe um código de motivo de alteração no parâmetro 'MV_JMOTREM'."
				Exit
			EndIf
		EndIf
		
		If lOk
			lOk := oModelNSZ:VldData() .And. oModelNSZ:CommitData()
		EndIf

		If !lOk
			cRet += JA063GetErr(oModelNSZ, {{'NSZ_COD', cNSZCod}}, STR0005) //"Erro no remanejamento dos processos"
			Exit
		Endif
		oModelNSZ:DeActivate()

	Next nI

EndIf

If lOk
	cRet := ""
	ProcRegua(0)
	IncProc(STR0036 + cCaso) // "Remanejando caso "
EndIf

cFilAnt := cFilAux

JurFreeArr(@aSQL)

RestArea(aAreaNSZ)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063NVE
Filtra a consulta padrão de caso conforme o cliente

@Return cRet	Comando
@author Juliana Iwayama Velho
@since 14/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA063NVE()
Local cRet := "@#@#"

	If !Empty(MV_PAR01)
		cRet := "@#NVE->NVE_CCLIEN == '" + PadR(MV_PAR01, 6) + "' .AND. NVE->NVE_LCLIEN == '" + PadR(MV_PAR02, 2) + "'@#"
	EndIF

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063VNVE
Valida o caso

@Return lRet	.T./.F. As informações são válidas ou não
@author Juliana Iwayama Velho
@since 14/06/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA063VNVE()
Return IF(!EMPTY(mv_par01), ExistCpo("NVE", mv_par01 + mv_par02 + mv_par03), .T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063NT0
Vincula o novo caso ao contrato do caso remanejado.

@author Felipe Bonvicini Conti
@since 06/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063NT0(cCliOri, cLojOri, cCaso, cGrpCli, cCliDes, cLojDes, cCasNovo)
Local lOk      := .T.
Local aArea    := GetArea()
Local cQuery   := ""
Local aSQL     := {}
Local cRet     := STR0087 + CRLF + STR0052 + CRLF // "Vincula o caso novo ao Contrato" e "Contrato: "
Local nI       := 0
Local nQtd     := 0
Local aValores := {}
Local aCampos  := {}

	cQuery += " SELECT NUT.NUT_CCONTR "
	cQuery +=   " FROM " + RetSqlName("NUT") + " NUT "
	cQuery +=  " WHERE NUT.NUT_FILIAL = '" + xFilial("NUT") +"' "
	cQuery +=    " AND NUT.NUT_CCLIEN = '"+ cCliOri +"' "
	cQuery +=    " AND NUT.NUT_CLOJA = '"+ cLojOri +"' "
	cQuery +=    " AND NUT.NUT_CCASO = '"+ cCaso +"' "
	cQuery +=    " AND NUT.D_E_L_E_T_ = ' ' "

 	aSQL := JurSQL(cQuery, {"NUT_CCONTR"})

	If !Empty(aSQL)
		nQtd := Len(aSQL)
		ProcRegua(nQtd)
		For nI := 1 To nQtd
			IncProc(STR0027 + " " + AllTrim(Str(nI)) + STR0084 + AllTrim(Str(nQtd))) //"Contrato" ## " de "

			aValores := {aSQL[nI][1] , cCliDes     , cLojDes    , cCasNovo   }
			aCampos  := {"NUT_CCONTR", "NUT_CCLIEN", "NUT_CLOJA", "NUT_CCASO"}
			
			lOk := JurOperacao(3, "NUT", 1, /*Chave*/, aCampos, aValores)
			
			If !lOk
				cRet += STR0047 + aSQL[nI][1] + STR0048 + CRLF // "Cód: " e " - Erro"
				Exit
			EndIf
		Next nI
	EndIf

	If lOk
		cRet := ""
		ProcRegua(0)
		IncProc(STR0036 + cCaso) // "Remanejando caso "
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063GetErr
Função utilizada para retornar o erro do Model

@author Felipe Bonvicini Conti
@since 01/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063GetErr(oModel, aDados, cRotina)
Local cRet      := ""
Local aErro     := {}

Default cRotina := ""
Default aDados  := {}

cRet += Replicate('-', 78) + CRLF
cRet += cRotina + CRLF
If oModel != Nil
	aErro := oModel:GetErrorMessage()
	cRet += JurShowErro(aErro, aDados, Nil, .F., .F.)
Else
	cRet += CRLF + JuraDataStr(aDados , .T.)
	cRet += Replicate('-', 78) + CRLF
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063ENCER
Função utilizada para encerrar o caso

@author Felipe Bonvicini Conti
@since 02/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063ENCER(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo)
Local lOk     := .T.
Local cRet    := ""
Local aArea   := GetArea()
Local cPart   := JurUsuario(__CUSERID)
Local aMaster := {}

	NVE->(dbSetOrder(1))
	If NVE->(dbSeek(xFilial('NVE') + cCliOri + cLojOri + cCasoOri))

		oModelNVE:SetOperation(MODEL_OPERATION_UPDATE)
		oModelNVE:Activate()

		If Empty(oModelNVE:GetValue('NVEMASTER', 'NVE_DTENCE'))
			IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_SITUAC', '2'), )
			IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_DTENCE', dDataBase), )
			IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_DETENC', STR0004), )
			IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_CPART3', cPart ), )
		EndIf
		IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_CCLINV', cCliDes), )
		IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_CLJNV', cLojDes), )
		IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_CCASNV', cCasNovo), )
		IIF(lOk, lOk := oModelNVE:SetValue('NVEMASTER', 'NVE_REVISA', '2'), ) // Seto como não revisado.
		IIF(lOk, lOk := oModelNVE:LoadValue('NVEMASTER', 'NVE_DTREAB', CtoD('')), )
		IIF(lOk, lOk := oModelNVE:LoadValue('NVEMASTER', 'NVE_DETREA', ''), )
		IIF(lOk, lOk := oModelNVE:LoadValue('NVEMASTER', 'NVE_CPART4', ''), )

		If lOk
			lOk := oModelNVE:VldData() .And. oModelNVE:CommitData()
		EndIf

		If !lOk
			AAdd( aMaster, {'NVE_CCLIEN', cCliOri } )
			AAdd( aMaster, {'NVE_LCLIEN', cLojOri } )
			AAdd( aMaster, {'NVE_NUMCAS', cCasoOri} )
			AAdd( aMaster, {'NVE_CPART3', cPart   } )

			cRet += JA063GetErr(oModelNVE, aMaster, STR0069) //"Erro ao encerrar o caso origem"

		EndIf
		oModelNVE:DeActivate()

	EndIf

	If lOk
		cRet := ""
		ProcRegua(0)
		IncProc(STR0088) // "Aguarde..."
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063GETCP
Função utilizada para retornar o valor encontrado no Array

@author Felipe Bonvicini Conti
@since 02/10/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063GETCP(aDados, cCampo)
Local nQtd    := Len(aDados)
Local xValor
Local nI

	For nI := 1 To nQtd
		If aDados[nI][1] == cCampo
			Do Case
				Case aDados[nI][2] == NIL
					xValor := CriaVar(aDados[nI][1], .F.)
				Case ValType(aDados[nI][2]) == "C"
					xValor := AllTrim(aDados[nI][2])
				OtherWise
					xValor := aDados[nI][2]
			EndCase
			Exit
		EndIf
	Next nI

Return xValor

//-------------------------------------------------------------------
/*/{Protheus.doc} JA63NVEX
Função utilizada para incluir nas tabelas relacionadas a NVE

@author Luciano Pereira dos Santos
@since 15/02/2019
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA63NVEX(oModelNVE, cTabela, cCpoCaso, cCliOld, cLojOld, cCasOld, cCliDes, cLojDes, cCasDes, cTitulo)
Local oModelX   := oModelNVE:GetModel(cTabela + 'DETAIL')
Local aArea     := GetArea()
Local aStruct   := (cTabela)->(DbStruct())
Local aRelation := oModelX:GetRelation()[1]
Local cCpoNGrav := ""
Local cRet      := ""
Local cAux      := CRLF + "- " + oModelX:GetDescription() + CRLF
Local nI        := 0
Local nY        := 0
Local lRet      := .T.
Local aCampos   := {}
Local cQuery    := ""
Local aQuery    := {}
Local xData     := Nil
Local cCpoClie  := cTabela + "_CCLIEN"
Local cCpoLoja  := cTabela + "_CLOJA"
Local nLines    := 0
Local lForce    := .T.

cQuery := " SELECT R_E_C_N_O_ RECNO "
cQuery += " FROM " + RetSqlName(cTabela) + " "
cQuery += " WHERE " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "' "
cQuery +=   " AND " + cCpoClie + " = '" + cCliOld + "' "
cQuery +=   " AND " + cCpoLoja + " = '" + cLojOld + "' "
cQuery +=   " AND " + cCpoCaso + " = '" + cCasOld + "' "
cQuery +=   " AND D_E_L_E_T_ = ' ' "

aQuery := JurSQL(cQuery, {"RECNO"})
ProcRegua(Len(aQuery))

Aeval(aRelation, {|aX| cCpoNGrav += aX[1] + "|"})
cCpoNGrav += cTabela + "_COD" // O campo de codigo tem preenchimento automatico

If Len(aQuery) > 0

	For nI := 1 To Len(aQuery)
		IncProc()
		(cTabela)->(DbGoto(aQuery[nI][1]))

		If !oModelX:IsEmpty()
			If nI == 1 //Limpa os registros existentes no grid do caso destino
				For nY := 1 To oModelX:GetQtdLines()
					oModelX:GoLine(nY)
					oModelX:DeleteLine()
				Next nY
			EndIf

			nLines := oModelX:Length()
			If (oModelX:AddLine() == nLines)
				cRet +=  JA063GetErr( , , cAux + STR0118) //"Não foi possível incluir as informações do caso origem."
				lRet := .F.
				Exit
			EndIf
		EndIf

		For nY := 1 To Len(aStruct)
			cCampo := Alltrim(aStruct[nY][1])
			xData  := (cTabela)->(FieldGet(FieldPos(cCampo)))
			lForce := (cCampo == cTabela + "_CPART") //Forçando a gravação do codigo por problemas do FW ao gatilhar o participante através do sigla.

			aAdd(aCampos, {cCampo, xData})
			If !Empty(xData) .And. !(cCampo $ cCpoNGrav)
				If oModelX:CanSetValue(cCampo) .And. !lForce
					lRet := oModelX:SetValue(cCampo, xData )
				Else
					lRet := oModelX:LoadValue(cCampo, xData )
				EndIf
			EndIf

			If !lRet
				Exit
			EndIf
		Next nY

		If !lRet .Or. !oModelX:VldData()
			cRet += JA063GetErr(oModelNVE, aCampos, cAux)
			lRet:= .F.
			Exit
		EndIf

	Next nI

EndIf

JurFreeArr(@aQuery)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063VldCl(cTipo, oCliente, oLoja, cCliente, cLoja, oCaso, lLojAuto)
Rotina que valida se o cliente é Cliente/Pagador ou Somente Pagador

@Param    cTipo     - Tipo: O - origem; D - destino
@Param    cCliente  - Codigo do Codigo do Cliente (Por referencia)
@Param    cLoja     - Codigo da Loja (Por referencia)
@Param    lLojAuto  - .T. preenche a loja automaticamente (MV_JLOJAUT)

@author Luciano Pereira dos Santos
@since 15/06/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J063VldCl(cTipo, cCliente, cLoja)
Local lRet       := .T.
Local aArea      := GetArea()

If !Empty(cCliente) .And. !Empty(cLoja)
	SA1->(DbSetOrder(1)) //A1_FILIAL + A1_COD + A1_LOJA
	If SA1->(DbSeek(xFilial("SA1") + cCliente + cLoja))
		If (JurGetDados('NUH',1, xFilial('NUH') + cCliente + cLoja, 'NUH_PERFIL') == '2')
			lRet := JurMsgErro(Iif(cTipo == "O", STR0078, STR0079), , STR0117)//#"O cliente origem não pode ter casos pois é somente cliente pagador."
		EndIf //##"O cliente destino não pode receber casos pois é somente cliente pagador." ### "Verifique o cadastro ou selecione outro cliente para remanejamento."
	Else
		lRet := JurMsgErro(STR0109, , STR0117) //#"O Cliente informado não é válido." ## "Verifique o cadastro ou selecione outro cliente para remanejamento."
	EndIf
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExistCaso()
Rotina para validar se existe o caso informado

@author Felipe Bonvicini Conti
@since 29/05/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ExistCaso(cCliente, cLoja, cCasoDest, lMsg, nIndice)
Local lRet      := .T.
Local aArea     := GetArea()

Default lMsg    := .F.
Default nIndice := IIF(cNumCaso == '1', 1, 3)

If !Empty(cCasoDest)
	Do Case
		Case nIndice == 1
			lRet := ExistCpo("NVE", cCliente + cLoja + cCasoDest, 1, ,lMsg)
		Case nIndice == 3
			lRet := ExistCpo("NVE", cCasoDest, 3, ,lMsg)
	End Case
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063REbil()
Verificação para Clientes Ebilling

@author Jorge Luis Branco Martins Junior
@since 01/06/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA063REbil(cTSCod,cFase,cTarefa,cAtivi)
Local aArea  := GetArea()
Local oModel := FWModelActive()
Local lRet   := .F.

	If oModel:LoadValue('NUEMASTER', 'NUE_CFASE', cFase )
		If oModel:LoadValue('NUEMASTER', 'NUE_CTAREF', cTarefa)
			If oModel:LoadValue('NUEMASTER', 'NUE_CTAREB', cAtivi )
				lRet := .T.
			EndIf
		EndIf
	EndIf

RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063Reabre()
Rotina para reabrir o caso

@author Felipe Bonvicini Conti
@since 06/11/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function J063Reabre(cCliDes, cLojDes, cCasoDest)
Local lOk      := .T.
Local cRet     := ""
Local aArea    := GetArea()
Local cPart    := JurUsuario(__CUSERID)
Local cSigla   := JurGetDados("RD0", 1, xFilial("RD0")+cPart, "RD0_SIGLA")
Local aCampos  := {}
Local aValores := {}

	NVE->(dbSetOrder(1))
	If NVE->(dbSeek(xFilial("NVE") + cCliDes + cLojDes + cCasoDest)) .And. NVE->NVE_SITUAC == "2" // Se o caso estiver encerrado, reabro!

		aCampos  := {"NVE_SITUAC", "NVE_DTREAB", "NVE_DETREA", "NVE_CPART4", "NVE_DTENCE", "NVE_DETENC", "NVE_CPART3", "NVE_CCLINV", "NVE_CLJNV", "NVE_CCASNV"}
		aAdd(aValores, "1")
		aAdd(aValores, dDataBase)
		aAdd(aValores, STR0091 + cSigla + STR0092)  // "Reaberto por " e " na rotina de remanejamento de casos."
		aAdd(aValores, cPart)
		aAdd(aValores, CTOD(""))
		aAdd(aValores, "")
		aAdd(aValores, "")
		aAdd(aValores, "")
		aAdd(aValores, "")
		aAdd(aValores, "")

		lOk := JurOperacao(MODEL_OPERATION_UPDATE, "NVE", 1, xFilial("NVE") + cCliDes + cLojDes + cCasoDest, aCampos, aValores)

		If lOk
			cRet := ""
			ProcRegua(0)
			IncProc(STR0088) // "Aguarde..."
		Else
			cRet += CRLF + STR0093 + cCasoDest + CRLF // "Erro ao reabrir o caso: "
		EndIf


	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063TBLote
Remaneja o Lançamento tabelado em lote, removendo o caso antigo do lote e
criando novo lote para o caso novo, se no lote antigo houver apenas o caso antigo,
então este é finalizando colocando como Ano-Mês final o da data do remanejamento.

@author Felipe Bonvicini Conti
@since 06/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function JA063TBLote(cCliOri, cLojOri, cCasoOri, cGrpDes, cCliDes, cLojDes, cCasNovo)
Local lOk       := .T.
Local cRet      := ""
Local aArea     := GetArea()
Local cQuery    := ""
Local aSQL      := {}
Local aDados    := {}
Local nQtd, nI, nY

	cQuery := " SELECT NWN.NWN_CLOTE, NWN.NWN_CPART "
	cQuery +=   " FROM " + RetSqlName("NWN") + " NWN, "
	cQuery +=        " " + RetSqlName("NWM") + " NWM "
	cQuery +=  " WHERE NWN.NWN_FILIAL = '" + xFilial("NWN") + "' "
	cQuery +=    " AND NWM.NWM_FILIAL = '" + xFilial("NWM") + "' "
	cQuery +=    " AND NWM.NWM_COD = NWN.NWN_CLOTE "
	cQuery +=    " AND NWM.NWM_CCLIEN = '" + cCliOri + "' "
	cQuery +=    " AND NWM.NWM_CLOJA = '" + cLojOri + "' "
	cQuery +=    " AND NWN.NWN_CCASO  = '" + cCasoOri + "' "
	cQuery +=    " AND NWN.D_E_L_E_T_ = ' ' "
	cQuery +=    " AND NWM.D_E_L_E_T_ = ' ' "

	aSQL := JurSQL(cQuery, {"NWN_CLOTE", "NWN_CPART"})

	nQtd := Len(aSQL)
	For nI := 1 To nQtd
		ProcRegua(nQtd)
		NWM->(dbSetOrder(1))
		If lOk .and. NWM->(dbSeek(xFilial("NWM") + aSQL[nI][1]))

			IncProc(STR0095 + AllTrim(Str(nI)) + STR0084 + AllTrim(Str(nQtd))) //#"Remanejando lançamento tabelado em lote: "  ##"  de "

			aDados := {}
			For nY:= 1 to NWM->(Fcount())
				aADD(aDados, { NWM->(FieldName(nY)), NWM->(FieldGet(nY)) })
			Next

			// Copio o cabeçalho
			oModelNWM:SetOperation(MODEL_OPERATION_INSERT)
			oModelNWM:Activate()
			IIF(lOk, lOk := oModelNWM:SetValue("NWMMASTER", "NWM_CGRUPO", cGrpDes), )
			IIF(lOk, lOk := oModelNWM:LoadValue("NWMMASTER", "NWM_CCLIEN", cCliDes), ) //LoadValue para nao executar validacao, apenas na loja
			IIF(lOk, lOk := oModelNWM:SetValue("NWMMASTER", "NWM_CLOJA", cLojDes), )

			For nY := 1 to NWM->(Fcount())
				If !JurIN(NWM->(FieldName(nY)), {"NWM_FILIAL", "NWM_COD", "NWM_CGRUPO", "NWM_CCLIEN", "NWM_CLOJA"})
					oModelNWM:LoadValue( "NWMMASTER", NWM->(FieldName(nY)), JA063GETCP(aDados, NWM->(FieldName(nY))) )
				EndIf
			Next

			IIF(lOk, lOk := oModelNWM:SetValue("NWNDETAIL", "NWN_CCASO", cCasNovo), )
			IIF(lOk, lOk := oModelNWM:SetValue("NWNDETAIL", "NWN_CPART", aSQL[nI][2]), ) // Participante
			IIF(lOk, lOk := oModelNWM:SetValue("NWNDETAIL", "NWN_SIGLA", POSICIONE("RD0", 1, xFilial("RD0") + aSQL[nI][2], "RD0_SIGLA")), ) // Sigla
			IIF(lOk, lOk := oModelNWM:SetValue("NWMMASTER", "NWM_SIGLA", POSICIONE("RD0", 1, xFilial("RD0") + aSQL[nI][2], "RD0_SIGLA")), ) // Sigla

			If lOk
				lOk := oModelNWM:VldData() .And. oModelNWM:CommitData()
			EndIf

			If !lOk
				cRet += JA063GetErr(oModelNWM, {{'NWN_CLOTE', aSQL[nI][1]}}, STR0095 ) //"Erro ao remanejar lançamento tabelado em lote"
				Exit
			EndIf
			oModelNWM:DeActivate()

			If lOk // Se inseriu corretamente, então verifico se o lote apenas tinha o caso origem vinculado, se sim, então removo-o e finalizo o lote, caso contrario apenas removo o caso.

				If lOk := JurOperacao(MODEL_OPERATION_DELETE, "NWN", 1, xFilial("NWM") + aSQL[nI][1] + cCasoOri) // Removo o Caso do Lote antigo

					If J063ZeroCasoLote(aSQL[nI][1]) // Se não tiver mais nenhum caso no lote, então encerro o lote
						NWM->(dbSetOrder(1))
						If NWM->(dbSeek(xFilial("NWM") + aSQL[nI][1]))
							RecLock("NWM",.F.)
							NWM->NWM_AMFIM := StrZero(Year(Date()), 4) + StrZero(Month(Date()), 2)
							NWM->(MsUnlock())
						EndIf
					EndIf

				EndIf
			EndIf

		Else
			cRet += CRLF + STR0096 + cCasNovo + STR0097 + aSQL[nI][1] + CRLF // "Erro ao remanejar lançamento tabelado em lote: Caso - " e " Lote - "
			Exit
		EndIf
	Next

	If lOk
		cRet := ""
		ProcRegua(0)
		IncProc(STR0088) // "Aguarde..."
	EndIf

	JurFreeArr(@aSQL)
	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063ZeroCasoLote(cLote)
Função utilizada para verificar se o lote não está mais vinculado a nenhum caso

@author Felipe Bonvicini Conti
@since 08/11/2012
/*/
//-------------------------------------------------------------------*/
Static Function J063ZeroCasoLote(cLote)
Local cQry    := ""

Default cLote := ""

	cQry := " SELECT COUNT(NWN.R_E_C_N_O_) QTD "
	cQry +=   " FROM " + RetSqlName("NWN") + " NWN "
	cQry +=  " WHERE NWN.NWN_FILIAL = '" + xFilial("NWN") +"' "
	cQry +=    " AND NWN.NWN_CLOTE  = '"+cLote+"' "
	cQry +=    " AND NWN.D_E_L_E_T_ = ' ' "

Return JurSQL(cQry, "QTD")[1][1] == 0

//-------------------------------------------------------------------
/*/{Protheus.doc} JA063Hist(nRecnoOri,cCasNovo)
Função utilizada para inserir novo histórico do remanejamento do caso.

@author Felipe Bonvicini Conti
@since 09/11/2012
/*/
//-------------------------------------------------------------------*/
Static Function JA063Hist(nRecnoOri,cCasNovo)
Local cRet     := STR0098 + STR0099 // "Gravando" e "Histórico do Remanejamento."
Local lOk      := .T.
Local aArea    := GetArea()
Local aCampos  := {"NY1_CCLIEN","NY1_CLOJA","NY1_CCASO","NY1_DTREM","NY1_CPART","NY1_PERINI","NY1_PERFIM","NY1_REVISA","NY1_DTREVI","NY1_CPARTR","NY1_OBS","NY1_SEQ"}
Local aValores := {}

	ProcRegua(1)
	IncProc(STR0099 + STR0100 + cCasNovo) // "Histórico do Remanejamento" e "Caso: "

	NVE->(dbGoTo(nRecnoOri))

	aAdd(aValores, NVE->NVE_CCLIEN) // "NY1_CCLIEN"
	aAdd(aValores, NVE->NVE_LCLIEN) // "NY1_CLOJA"
	aAdd(aValores, cCasNovo) // "NY1_CCASO"
	aAdd(aValores, DToS(dDataBase)) // "NY1_DTREM"
	aAdd(aValores, JurUsuario(__CUSERID)) // "NY1_CPART"
	aAdd(aValores, J063HistDtIni(cCasNovo, NVE->NVE_DTENTR)) // "NY1_PERINI"
	aAdd(aValores, DToS(dDataBase)) // "NY1_PERFIM"
	aAdd(aValores, NVE->NVE_REVISA) // "NY1_REVISA"
	aAdd(aValores, NVE->NVE_DTREVI) // "NY1_DTREVI"
	aAdd(aValores, NVE->NVE_CPARTR) // "NY1_CPARTR"
	aAdd(aValores, NVE->NVE_OBSREV) // "NY1_OBS"
	aAdd(aValores, J063HistSeq(cCasNovo)) // "NY1_SEQ"

	lOk := JurOperacao(MODEL_OPERATION_INSERT, "NY1", /*Indice*/, /*Chave*/, aCampos, aValores)

	If lOk
		cRet := ""
		ProcRegua(0)
		IncProc(STR0088) // "Aguarde..."
	Else
		cRet += CRLF + STR0101 + STR0099 + STR0100 + cCasNovo + CRLF // "Erro ao gravar o " e "Histórico do Remanejamento" e "Caso: "
	EndIf

	RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063HistDtIni(cCaso)
Função utilizada para buscar a data final do histórico do caso.

@author Felipe Bonvicini Conti
@since 10/11/2012
/*/
//-------------------------------------------------------------------*/
Static Function J063HistDtIni(cCaso, cData)
Local cRet := ""
Local cQry := ""

	cQry := " SELECT ISNULL(MAX(NY1_PERFIM), 'ZERO') DATAFIM "
	cQry +=   " FROM " + RetSqlName("NY1") + " "
	cQry +=  " WHERE NY1_FILIAL = '" + xFilial("NY1") +"' "
	cQry +=    " AND NY1_CCASO  = '" + cCaso + "' "
	cQry +=    " AND D_E_L_E_T_ = ' ' "

	If AllTrim(cRet := JurSQL(cQry, "DATAFIM")[1][1]) == "ZERO"
		cRet := cData
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063HistSeq(cCaso)
Função utilizada para buscar a numeração sequencial para o Caso.

@author Jacques Alves Xavier
@since 17/12/2012
/*/
//-------------------------------------------------------------------*/
Static Function J063HistSeq(cCaso)
Local nRet := 0
Local cQry := ""

	cQry := " SELECT ISNULL(MAX(NY1_SEQ), 0) + 1 NY1_SEQ "
	cQry +=   " FROM " + RetSqlName("NY1") + " "
	cQry +=  " WHERE NY1_FILIAL = '" + xFilial("NY1") +"' "
	cQry +=    " AND NY1_CCASO  = '" + cCaso + "' "
	cQry +=    " AND D_E_L_E_T_ = ' ' "

	nRet := JurSQL(cQry, "NY1_SEQ")[1][1]

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J063VldNT9
Validar os campos da tabela NT9 passados como parâmetros para a função.

@author Julio de Paula Paz
@since 18/08/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J063VldNT9(cCampo)
Local lRet := .T.

Begin Sequence
   Do Case
      Case cCampo == "NT9_CEMPCL"
           lRet := JVldClRst(FwFldGet("NT9_CEMPCL"), FwFldGet("NT9_LOJACL"))
      Case cCampo == "NT9_LOJACL"
           lRet := ExistCpo('SA1', FWFldGet('NT9_CEMPCL') + FWFldGet('NT9_LOJACL'))
      Case cCampo == "NT9_CMUNIC"
           lRet := ExistCpo('CC2', FWFldGet('NT9_ESTADO') + FWFldGet('NT9_CMUNIC'))
   EndCase
End Sequence

Return lRet
