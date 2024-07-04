#include "protheus.ch"
#include "tmsa161.ch"

/*/{Protheus.doc} TMSA161
	Rotina para troca de cartao.
	@type Function
	@author arume.alexandre
	@since 13/06/2018
	@version version
	@return lRet, logic, Sucesso ou não na troca do cartao.
/*/
Function TMSA161()

	Local aArea 	:= GetArea()
	Local lRet		:= .T.
	Local cCodOpe	:= ""
	Local cCodFor	:= ""
	Local cLojFor	:= ""
	Local aRetCNPJ 	:= {}
	Local aFields 	:= {}
	Local cStatus	:= ""
	Local aCards	:= {}
	Local cQuery	:= ""
	Local cAlias	:= ""
	Local cCodMot	:= ""
	Local cCondut	:= ""
	
	If IsInCallStack("TMSA250")
		DTQ->(dbSetOrder(2)) 
		DTQ->(MsSeek(FwxFilial('DTQ') + DTY->(DTY_FILORI+DTY_VIAGEM) ))
	EndIf

	// Veículos
	DTR->(dbSetOrder(1)) //DTR_FILIAL+DTR_FILORI+DTR_VIAGEM+DTR_ITEM
	If DTR->(MsSeek(FwxFilial('DTR') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
		cCodOpe := DTR->DTR_CODOPE
		cCodFor := DTR->DTR_CODFOR
		cLojFor := DTR->DTR_LOJFOR
		If cCodOpe <> "02"
			Help( , , STR0001, , STR0002, 1, 0) //"Troca de cartão""O código da operadora é diferente de 02 - Pamcard."
			lRet := .F.
		EndIf
	EndIf

	If lRet
		// Se a viagem possuir contrato, o contrato não pode estar com o saldo liberado ou quitado
		DTY->(dbSetOrder(2)) //DTY_FILIAL+DTY_FILORI+DTY_VIAGEM+DTY_NUMCTC
		If DTY->(MsSeek(FwxFilial("DTY") + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
			lRet := (DTY->DTY_STATUS $ "1,2") // O contrato não pode estar com status Lib. p/ Pagto, Cotr. Quitado/Pagto.
		EndIf

		If lRet
			// Se a viagem possuir CIOT por período (DEJ), o CIOT deve estar com status aberto ou fechado.
			If AliasInDic("DJL") .AND. DTR->(ColumnPos("DTR_TPCIOT")) > 0 .AND. DTR->(ColumnPos('DTR_CIOT')) > 0
				
				cQuery := " SELECT "
				cQuery += "    DJL.DJL_STATUS "
				cQuery += " FROM " + RetSqlName("DJL") + " DJL "
				cQuery += " INNER JOIN " + RetSqlName("DTR") + " DTR  "
				cQuery += "     ON DTR.DTR_FILIAL   = '" + xFilial("DTR") + "' "
				cQuery += "    AND DTR.DTR_CIOT   = DJL.DJL_CIOT "
				cQuery += "    AND DTR.DTR_CODVEI = DJL.DJL_CODVEI "
				cQuery += "    AND DTR.D_E_L_E_T_ = ' ' "
				cQuery += " WHERE "
				cQuery += "        DJL.DJL_FILIAL   = '" + xFilial("DJL") + "' "
				cQuery += "    AND DJL.DJL_STATUS NOT IN ('1', '2')" // Aberto ou fechado
				cQuery += "    AND DJL.D_E_L_E_T_ = ' ' "
				cQuery += "    AND DTR.DTR_TPCIOT = '2'" // Por período
				cQuery += "    AND DTR.DTR_CIOT  != ' '"
				cQuery += "    AND DTR.DTR_FILORI = '" + DTQ->DTQ_FILORI + "'"
				cQuery += "    AND DTR.DTR_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"

				cQuery := ChangeQuery(cQuery)
				cAlias := GetNextAlias()
				dbUseArea(.T., 'TOPCONN', TCGenQry(, , cQuery), cAlias, .F., .T.)
				
				If (cAlias)->(!Eof())
					Help( , , STR0001, , STR0003, 1, 0) //"Troca de cartão""A viagem possui CIOT por periodo com status encerrado ou anulado."
					lRet := .F.
				EndIf

				(cAlias)->(dbCloseArea())
				
				If lRet
					//Função para obter CNPJ da contrante e filial de origem
					aRetCNPJ := PamCNPJEmp(cCodOpe, DTQ->DTQ_FILORI)

					// Consultar o status do(s) cartão(ões)
					If AliasInDic("DLD")
						DLD->(dbSetOrder(1)) //DLD_FILIAL+DLD_FILORI+DLD_VIAGEM+DLD_ITEDTR+DLD_CODVEI+DLD_TIPPAR+DLD_RECEB+DLD_FORPAG
						If DLD->(MsSeek(FwxFilial("DLD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
							While DLD->(!Eof()) .AND. FwxFilial("DLD") + DLD->DLD_FILORI + DLD->DLD_VIAGEM == FwxFilial("DLD") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM
								DUP->(dbSetOrder(1)) //DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR+DUP_CODMOT
								If DUP->(MsSeek(FwxFilial("DUP") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
									cCodMot := DUP->DUP_CODMOT
									cCondut	:= DUP->DUP_CONDUT
								EndIf
								AAdd(aFields, {'viagem.contratante.documento.numero'	, aRetCNPJ[1]})
								AAdd(aFields, {'viagem.unidade.documento.tipo'      	, aRetCNPJ[2]})
								AAdd(aFields, {'viagem.unidade.documento.numero'    	, aRetCNPJ[3]})
								AAdd(aFields, {'viagem.cartao.numero'					, AllTriM(DLD->DLD_IDOPE)})

								If PamFindCar(aFields, .T., , @cStatus, , , , .T.)
									If cStatus == "3" .AND. aScan(aCards, {|x| x[1] == AllTrim(DLD->DLD_IDOPE)}) == 0 //Cancelado e não existente.
										aAdd(aCards, {AllTrim(DLD->DLD_IDOPE), STR0004, BSCXBOX('DLD_FORPAG', DLD->DLD_FORPAG), cCodMot, DLD->DLD_RECEB, DLD->DLD_CODVEI, cCondut})
									EndIf
								EndIf
								cCodMot := ""
								DLD->(dbSkip())
							End
						EndIf
					Else
						DUP->(dbSetOrder(1)) //DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR+DUP_CODMOT
						If DUP->(MsSeek(FwxFilial("DUP") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM))
							While DUP->(!Eof()) .AND. FwxFilial("DUP") + DUP->DUP_FILORI + DUP->DUP_VIAGEM == FwxFilial("DUP") + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM
								
								AAdd(aFields, {'viagem.contratante.documento.numero'	, aRetCNPJ[1]})
								AAdd(aFields, {'viagem.unidade.documento.tipo'      	, aRetCNPJ[2]})
								AAdd(aFields, {'viagem.unidade.documento.numero'    	, aRetCNPJ[3]})
								AAdd(aFields, {'viagem.cartao.numero'					, AllTriM(DUP->DUP_IDOPE)})

								If PamFindCar(aFields, .T., , @cStatus, , , , .T.)
									If cStatus == "3" .AND. aScan(aCards, {|x| x[1] == AllTrim(DLD->DLD_IDOPE)}) == 0 //Cancelado e não existente.
										aAdd(aCards, {AllTrim(DUP->DUP_IDOPE), STR0004, BSCXBOX('DUP_FORADT', DUP->DUP_FORADT), DUP->DUP_CODMOT, , DUP->DUP_CODVEI, DUP->DUP_CONDUT})
									EndIf
								EndIf
								DUP->(dbSkip())
							End
						EndIf
					EndIf
					If Empty(aCards)
						Help( , , STR0001, , STR0005, 1, 0) //"Troca de cartão""Não é possível efetuar a troca do cartão devido o(s) mesmo(s) não estar(em) cancelado(s)."
						lRet := .F.
					Else
						TMSA161NCt(aCards, cCodOpe)
					EndIf
					
					aSize(aRetCNPJ, 0)
					aRetCNPJ := Nil

					aSize(aCards, 0)
					aCards := Nil
				EndIf
			Else
				Help( , , STR0001, , STR0006, 1, 0) //"Troca de cartão""Inconsistencia no banco de dados, favor verificar."
				lRet := .F.
			EndIf
		Else
			Help( , , STR0001, , STR0007, 1, 0) //"Troca de cartão""O contrato não pode estar com o saldo liberado ou quitado."
			lRet := .F.
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} TMSA161NCt
	Tela com os cartões cancelados
	@type Static Function
	@author arume.alexandre
	@since 13/06/2018
	@version version
	@param aCards, array, Cartões cancelados
	@param cCodOpe, character, Codigo da operacao
	@return lRet, logic, True or False
/*/
Static Function TMSA161NCt(aCards, cCodOpe)

	Local oDlg		:= Nil
	Local oLbx		:= Nil
	Local lRet		:= .T.

	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 0, 0 TO 240, 600 PIXEL style 128 //"Troca de cartão"

	@ 000, 000 LISTBOX oLbx FIELDS HEADER ;
		RetTitle('DDQ_IDCART'), RetTitle('DDQ_STATUS'), RetTitle('DUP_FORADT');
	   	SIZE 302, 105 OF oDlg PIXEL
	
	oLbx:SetArray(aCards)
	oLbx:bLine := {|| {	aCards[oLbx:nAt, 1],;
						aCards[oLbx:nAt, 2],;
						aCards[oLbx:nAt, 3]}}
	
	DEFINE SBUTTON FROM 107, 243 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 107, 273 TYPE 1 ACTION (If(TMSA161New(aCards[oLbx:nAt, 1], cCodOpe, aCards[oLbx:nAt, 4], aCards[oLbx:nAt, 5], aCards[oLbx:nAt, 6], aCards[oLbx:nAt, 7]), oDlg:End(),Nil)) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTER

Return lRet

/*/{Protheus.doc} TMSA161New
	Tela para informar o novo cartão.
	@type Static Function
	@author arume.alexandre
	@since 13/06/2018
	@version version
	@param cOldCard, character, Codigo da cartao antigo
	@param cCodOpe, character, Codigo da operacao
	@param cCodMot, character, Codigo do motorista
	@param cCodReceb, character, Codigo do recebedor
	@param cCodVei, character, Codigo do veiculo
	@param cCondut, character, Codigo do condutor
	@return lRet, logic, True or False
/*/
Static Function TMSA161New(cOldCard, cCodOpe, cCodMot, cCodReceb, cCodVei, cCondut)

	Local oDlg	:= Nil
	Local cF3	:= "DDQDEL"
	Local lRet	:= .T.

	Private cCard		:= Space(Len(DUP->DUP_IDOPE))
	Private cReceb		:= cCodReceb
	Private cCodVeic	:= cCodVei
	Private cCodMoto	:= cCodMot
	Private cCondutor	:= cCondut

	DEFINE MSDIALOG oDlg FROM 00, 00 TO 80, 400 PIXEL TITLE STR0008 //"Novo Cartão"

	@ 05, 05 MSGET cCard F3 cF3 SIZE 195, 10 PIXEL

	DEFINE SBUTTON FROM 20, 140 TYPE 2 OF oDlg ENABLE ACTION oDlg:End()
	DEFINE SBUTTON FROM 20, 170 TYPE 1 OF oDlg ENABLE ACTION (If(TMSA161Chg(cOldCard, cCard, cCodOpe, cCodMot), oDlg:End(), Nil))

	ACTIVATE MSDIALOG oDlg CENTERED

Return lRet

/*/{Protheus.doc} TMSA161VlC
	Validacao do cartao.
	@type Function
	@author arume.alexandre
	@since 21/06/2018
	@version version
	@param cCodOpe, character, Codigo da operacao
	@param cIdOpe, character, Numero do cartao
	@param cCodMot, character, Codigo do motorista
	@return lRet, logic, return_description
/*/
Static Function TMSA161VlC(cCodOpe, cIdOpe, cCodMot)

	Local aArea     	:= GetArea()
	Local lRet      	:= .F.
	Local aConsCard 	:= {}
	Local cCodFor 	 	:= ""
	Local cLojFor	 	:= ""
	Local lRespCart 	:= .F.

	aRetCNPJ := PamCNPJEmp(cCodOpe, cFilAnt) //Função para obter CNPJ da contrante e filial de origem
	
	//-- Montagem Array para Integração com PamCard
	AAdd(aConsCard,{'viagem.contratante.documento.numero',aRetCNPJ[1]})
	AAdd(aConsCard,{'viagem.unidade.documento.tipo'      ,aRetCNPJ[2]})
	AAdd(aConsCard,{'viagem.unidade.documento.numero'    ,aRetCNPJ[3]}) 
	AAdd(aConsCard,{'viagem.cartao.numero', AllTrim(cIdOpe) } )
		
	//Verifica os dados do fornecedor portador do cartão(conceito novo) ou do fornecedor do motorista(conceito antigo)
	DDQ->(dbSetOrder(1))	
	If DDQ->(MsSeek(xFilial('DDQ')+cIdOpe))
		cCodFor   := DDQ->DDQ_CODFOR
		cLojFor   := DDQ->DDQ_LOJFOR
		lRespCart := .T.
	Else                                     
		DA4->( DbSetOrder(1) )
		If DA4->( MsSeek(xFilial("DA4") + cCodMot, .F. ))
			cCodFor := DA4->DA4_FORNEC
			cLojFor := DA4->DA4_LOJA
		EndIf	
	EndIf
			 
	If PamVldFor(cCodFor, cLojFor, lRespCart) 
		lRet := PamFindCar(aConsCard, .T.)
	EndIf

	RestArea( aArea )

Return lRet

/*/{Protheus.doc} TMSA161Chg
	Rotina da troca do cartão.
	@type Static Function
	@author user
	@since date
	@version version
	@param cOldCard, character, Numero do cartao antigo
	@param cCard, character, Numero do cartao
	@param cCodOpe, character, Codigo da operacao
	@param cCodMot, character, Codigo do motorista
	@return lRet, logic, True or False
/*/
Static Function TMSA161Chg(cOldCard, cCard, cCodOpe, cCodMot)

	Local lRet		:= .T.
	Local aRetCNPJ	:= {}
	Local aFields	:= {}
	Local cAlias	:= ""
    Local cCiot     := ""
	Local cTipFav	:= ""

	If (lRet := TMSA161VlC(cCodOpe, cCard, cCodMot))

		aRetCNPJ := PamCNPJEmp(cCodOpe, DTQ->DTQ_FILORI) //Função para obter CNPJ da contrante e filial de origem

		cTipFav := PamGetFav(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, aRetCNPJ, DTQ->DTQ_IDOPE, cOldCard)

		aAdd(aFields, {'viagem.contratante.documento.numero', aRetCNPJ[1]})
		aAdd(aFields, {'viagem.id', AllTrim(DTQ->DTQ_IDOPE)})
		aAdd(aFields, {'viagem.favorecido.qtde', '1' })
		aAdd(aFields, {'viagem.favorecido1.tipo',cTipFav })
		aAdd(aFields, {'viagem.favorecido1.cartao.numero', AllTrim(cCard)})


		If (lRet := PamAltCtWs(aFields, AllTrim(DTQ->DTQ_IDCLI)))

			cAlias := GetNextAlias()

			BeginSQL Alias cAlias
				SELECT DTR.DTR_CIOT
				FROM %Table:DTR% DTR
				WHERE DTR.DTR_FILIAL = %xFilial:DTR%
				AND DTR.DTR_FILORI = %Exp:DTQ->DTQ_FILORI%
				AND DTR.DTR_VIAGEM = %Exp:DTQ->DTQ_VIAGEM%
				AND DTR.%NotDel%
			EndSQL

			If (cAlias)->(!EoF())
				cCiot := (cAlias)->DTR_CIOT
				(cAlias)->(DbSkip())
			EndIf

			(cAlias)->(DbCloseArea())

			// Se a viagem possuir CIOT por período atualizar todas as viagens que possuem o mesmo número de CIOT que possuem contratos pendentes.
			If AliasInDic("DLD")

				BeginSQL Alias cAlias
					 SELECT DLD.R_E_C_N_O_ DLDRECNO, DTY.DTY_STATUS
					   FROM %Table:DLD% DLD
					  INNER JOIN %Table:DTR% DTR
						 ON DTR.DTR_FILIAL = %xFilial:DTR%
						AND DTR.DTR_FILORI = DLD.DLD_FILORI
						AND DTR.DTR_VIAGEM = DLD.DLD_VIAGEM
						AND DTR.%NotDel%
					   LEFT JOIN %Table:DTY% DTY
						 ON DTY.DTY_FILIAL = %xFilial:DTY%
						AND DTY.DTY_FILORI = DLD.DLD_FILORI
						AND DTY.DTY_VIAGEM = DLD.DLD_VIAGEM
						AND DTY.%NotDel%
					  WHERE DLD.DLD_FILIAL = %XFilial:DLD%
						AND DLD.%NotDel%
						AND DLD.DLD_IDOPE = %Exp:cOldCard%
						AND DTR.DTR_CIOT   = %Exp:cCiot%
				EndSQL

				While (cAlias)->(!Eof())
					If Empty((cAlias)->DTY_STATUS) .Or. (cAlias)->DTY_STATUS $ "12"
						DLD->(DbGoTo((cAlias)->DLDRECNO))
						RecLock("DLD", .F.)
						DLD->DLD_CARCAN := DLD->DLD_IDOPE
						DLD->DLD_IDOPE := cCard
						DLD->(MsUnlock())
					EndIf
					(cAlias)->(DbSkip())
				EndDo

				(cAlias)->(DbCloseArea())
			EndIf

			BeginSQL Alias cAlias
				SELECT DUP.R_E_C_N_O_ DUPRECNO, DTY.DTY_STATUS
				FROM %Table:DUP% DUP
				INNER JOIN %Table:DTR% DTR
					ON DTR.DTR_FILIAL = %xFilial:DTR%
					AND DTR.DTR_FILORI = DUP.DUP_FILORI
					AND DTR.DTR_VIAGEM = DUP.DUP_VIAGEM
					AND DTR.%NotDel%
				LEFT JOIN %Table:DTY% DTY
					ON DTY.DTY_FILIAL = %xFilial:DTY%
					AND DTY.DTY_FILORI = DUP.DUP_FILORI
					AND DTY.DTY_VIAGEM = DUP.DUP_VIAGEM
					AND DTY.%NotDel%
				WHERE DUP.DUP_FILIAL = %XFilial:DUP%
					AND DUP.%NotDel%
					AND DTR.DTR_CIOT   = %Exp:cCiot%
					AND DUP.DUP_IDOPE = %Exp:cOldCard%
			EndSQL

			While (cAlias)->(!Eof())
				If Empty((cAlias)->DTY_STATUS) .Or. (cAlias)->DTY_STATUS $ "12"
					DUP->(DbGoTo((cAlias)->DUPRECNO))
					RecLock("DUP", .F.)
					DUP->DUP_IDOPE := cCard
					DUP->(MsUnlock())					
				EndIf
				(cAlias)->(DbSkip())
			EndDo

			(cAlias)->(dbCloseArea())
		Else
			Help( , , STR0001, , STR0009, 1, 0) //"Troca de cartão""Não foi possível efetuar a trocar do cartão, favor verificar a rotina PamAltCtWs."
		EndIf

		aSize(aRetCNPJ, 0)
		aRetCNPJ := Nil

		aSize(aFields, 0)
		aFields := Nil

	EndIf

Return lRet