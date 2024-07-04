#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FINXSE5.CH"

#DEFINE MOVIMENTO_BCO 			1
#DEFINE BAIXAS_PAGAR 			2
#DEFINE BAIXAS_RECEBER			3
#DEFINE ATUALIZA_CHEQUE			4

STATIC aCamposFK1 	:= FINLisCpo('FK1')
STATIC aCamposFK2 	:= FINLisCpo('FK2')
STATIC aCamposFK5 	:= FINLisCpo('FK5')
STATIC aCamposFK6 	:= FINLisCpo('FK6')
STATIC aCamposFK8 	:= FINLisCpo('FK8')
STATIC aDeParaFK1 	:= FINLisCpo('FK1')
STATIC aDeParaFK5 	:= FINLisCpo('FK5')
STATIC aDeParaFK2 	:= FINLisCpo('FK2')
STATIC aDeParaFK6 	:= FINLisCpo('FK6')
Static __aRFK6SE5 	:= {}
Static lFilExclus 	:= FWModeAccess("SE5",3) == "E"
Static nTamFil		:= Len(cFilAnt)
Static __nTamSeq	:= Nil
Static lSE5GRVFK	:= ExistBlock("SE5GRVFK")
Static aSE5GRVFK	:= {}
Static lBxMovPA 	:= .F.
Static _lTemMR		:= If(FindFunction("FTemMotor"), FTemMotor(), .F.)
Static __lTemCmp 	:= FindFunction("CtbLP596Cr")
Static __aVaToCTB	:= {}
Static __lFK7Cpos	:= NIL
Static __aTamCpos	:= {}
Static _aCmpFKC
Static _lInDicFKK
Static _lInDicFKC
Static _lInDicFKD
Static __cQryFKK 

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} FINXSE5
Funções auxiliares para os modelos de dados - Reestruturação SE5.
@author Totvs
@param nPos    Parametro que recebe a posição da SE5 para ser atualizada.
@param nTipo  Parametro que informa qual modelo será utilizado para a atualização.
1 = Movimento Bancario.
2 = Baixas a Pagar.
3 = Baixas a Receber.
4 = Cheques.
--------------------
@since 10/04/2014
@version P12
/*/
//-----------------------------------------------------------------------------------------
Function FINXSE5(nPos, nTipo, lAutomato)
	Local oProcesso := Nil
	Local aInfo		:= {}
	Local bProcess  := {|oProcesso| FinSE5ToFKS(oProcesso) }

	Default nPos := 0
	Default nTipo := 0
	Default lAutomato := .F.

	If lAutomato
		FnBaixaE1()
		FnBaixaE2()
		FnBuscaEF()
		FnBuscaSE5()
	ElseIf nPos > 0
		DbSelectArea('SE5')
		SE5->(DbGoto( nPos ))

		Do Case

		Case nTipo == BAIXAS_RECEBER		//Baixas a receber.
			FnBaixaE1(nPos)

		Case nTipo == BAIXAS_PAGAR			//Baixas a Pagar.
			FnBaixaE2(nPos)

		Case nTipo == ATUALIZA_CHEQUE		//Cheque.
			FnBuscaEF(nPos)

		Case nTipo == MOVIMENTO_BCO		//Mov. Bancario.
			FnBuscaSE5(nPos)

		EndCase
	Else

		oProcesso := tNewProcess():New("FINXSE5",;
			STR0001,; //"Contabilização Off-Line do Ativo Fixo"
			bProcess,;
			STR0002,;
			"FINSE5",;
			aInfo,;
			.T.,;
			5,;
			STR0003,; //"Descrição do painel Auxiliar"
		.T.)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FINProcFKs
Função para retornar a identificação do processo do movimento
financeiro

@param cChave, Identificação do registro de origem
@param cAlias, Identificação da tabela de origem
@param cSeq, Sequencia de baixa usando para rastreio de processos de baixas e adiantamento
@param lMovDireto Indica se é um movimento direto do FINA100
@return cRet, Número do processo

@author Totvs
@since 10/04/2014
@version P12
/*/
//-------------------------------------------------------------------

Function FINProcFKs(cChave, cAlias, cSeq, lMovDireto)
	Local cRet := ""
	Local aAreaAnt := GetArea()

	Default cChave := ""
	Default cAlias := ""
	Default cSeq := ""
	Default lMovDireto := .F.

	If lBxMovPA//Na bx de PA ou geração de mov. banc nas rotinas de bxs aut cp, utiliza o msm processo gerado na inclusão
		cRet := FKA->FKA_IDPROC
		lBxMovPA := .F.
	ElseIf !Empty(cChave) .And. !Empty(cAlias)
		dbSelectArea(cAlias)
		(cAlias)->( DbSetOrder(1) ) //Se FK1/FK2 - FILIAL + IDFK	Se FK5 FILIAL +

		If (lMovDireto .or. (cAlias)->(MsSeek(xFilial(cAlias)+cChave)) )
			dbSelectArea("FKA")
			FKA->( DbSetOrder( 3 ) ) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
			If MsSeek( xFilial("FKA") + cAlias + cChave)
				cRet := FKA->FKA_IDPROC
			Endif
		Endif
	EndIf
	RestArea( aAreaAnt )
Return cRet

/*/{Protheus.doc}FINLisCpo
Função de de/para das FKs para SE5.
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FINLisCpo(cTabela)
	Local aAux := {}
	Local aRet	 := {}
	Local lCmpFK1 	:= FK1->(FieldPos("FK1_DTDISP")) > 0 .and. FK1->(FieldPos("FK1_DTDIGI")) > 0
	Local lCmpFK2 	:= FK2->(FieldPos("FK2_DTDISP")) > 0 .and. FK2->(FieldPos("FK2_DTDIGI")) > 0
	Local lCmpFK6	:= FK6->(FieldPos("FK6_MOEDA"))	 > 0 .and. FK6->(FieldPos("FK6_TXMOED")) > 0

	Default cTabela := ''

	Do Case
	Case cTabela == 'FK1' //Baixas a Pagar.

		aAdd(aAux,{'FK1_DATA','E5_DATA'})
		aAdd(aAux,{'FK1_VALOR','E5_VALOR'})
		aAdd(aAux,{'FK1_MOEDA','E5_MOEDA'})
		aAdd(aAux,{'FK1_NATURE','E5_NATUREZ'})
		aAdd(aAux,{'FK1_VENCTO','E5_VENCTO'})
		aAdd(aAux,{'FK1_RECPAG','E5_RECPAG'})
		aAdd(aAux,{'FK1_TPDOC','E5_TIPODOC'})
		aAdd(aAux,{'FK1_HISTOR','E5_HISTOR'})
		aAdd(aAux,{'FK1_VLMOE2','E5_VLMOED2'})
		aAdd(aAux,{'FK1_LOTE','E5_LOTE'})
		aAdd(aAux,{'FK1_MOTBX','E5_MOTBX'})
		aAdd(aAux,{'FK1_ORDREC','E5_ORDREC'})
		aAdd(aAux,{'FK1_FILORI','E5_FILORIG'})
		aAdd(aAux,{'FK1_ARCNAB',	'E5_ARQCNAB'})
		aAdd(aAux,{'FK1_CNABOC','E5_CNABOC'})
		aAdd(aAux,{'FK1_TXMOED','E5_TXMOEDA'})
		aAdd(aAux,{'FK1_SITCOB','E5_SITCOB'})
		aAdd(aAux,{'FK1_SERREC','E5_SERREC'})
		aAdd(aAux,{'FK1_MULNAT','E5_MULTNAT'})
		aAdd(aAux,{'FK1_AUTBCO','E5_AUTBCO'})
		aAdd(aAux,{'FK1_CCUSTO' ,'E5_CCUSTO'})
		aAdd(aAux,{'FK1_SEQ','E5_SEQ'})
		aAdd(aAux,{'FK1_DIACTB','E5_DIACTB'})
		aAdd(aAux,{'FK1_NODIA','E5_NODIA'})
		aAdd(aAux,{'FK1_LA','E5_LA'})
		aAdd(aAux,{'FK1_DOC','E5_DOCUMEN'})
		aAdd(aAux,{'FK1_ORIGEM','E5_ORIGEM'})
		If lCmpFK1
			aAdd(aAux,{'FK1_DTDISP','E5_DTDISPO'})
			aAdd(aAux,{'FK1_DTDIGI','E5_DTDIGIT'})
		EndIF
	Case cTabela == 'FK2' //Baixas a Pagar.

		aAdd(aAux,{'FK2_DATA','E5_DATA'})
		aAdd(aAux,{'FK2_VALOR','E5_VALOR'})
		aAdd(aAux,{'FK2_MOEDA','E5_MOEDA'})
		aAdd(aAux,{'FK2_NATURE','E5_NATUREZ'})
		aAdd(aAux,{'FK2_VENCTO','E5_VENCTO'})
		aAdd(aAux,{'FK2_RECPAG','E5_RECPAG'})
		aAdd(aAux,{'FK2_TPDOC','E5_TIPODOC'})
		aAdd(aAux,{'FK2_HISTOR','E5_HISTOR'})
		aAdd(aAux,{'FK2_VLMOE2','E5_VLMOED2'})
		aAdd(aAux,{'FK2_LOTE','E5_LOTE'})
		aAdd(aAux,{'FK2_MOTBX','E5_MOTBX'})
		aAdd(aAux,{'FK2_ORDREC','E5_ORDREC'})
		aAdd(aAux,{'FK2_FILORI','E5_FILORIG'})
		aAdd(aAux,{'FK2_ARCNAB','E5_ARQCNAB'})
		aAdd(aAux,{'FK2_CNABOC','E5_CNABOC'})
		aAdd(aAux,{'FK2_TXMOED','E5_TXMOEDA'})
		aAdd(aAux,{'FK2_MULNAT','E5_MULTNAT'})
		aAdd(aAux,{'FK2_AUTBCO','E5_AUTBCO'})
		aAdd(aAux,{'FK2_CCUSTO' ,'E5_CCUSTO'})
		aAdd(aAux,{'FK2_SEQ','E5_SEQ'})
		aAdd(aAux,{'FK2_DIACTB','E5_DIACTB'})
		aAdd(aAux,{'FK2_NODIA','E5_NODIA'})
		aAdd(aAux,{'FK2_LA','E5_LA'})
		aAdd(aAux,{'FK2_SERREC','E5_SERREC'})
		aAdd(aAux,{'FK2_DOC','E5_DOCUMEN'})
		aAdd(aAux,{'FK2_ORIGEM','E5_ORIGEM'})
		If lCmpFK2
			aAdd(aAux,{'FK2_DTDISP','E5_DTDISPO'})
			aAdd(aAux,{'FK2_DTDIGI','E5_DTDIGIT'})
		EndIF
	Case cTabela == 'FK3' //Impostos Calculados.

		aAdd(aAux,{'FK3_DATA','E5_DATA'})
		aAdd(aAux,{'FK3_RECPAG','E5_RECPAG'})
		aAdd(aAux,{'FK3_MOEDA','E5_MOEDA'})
		aAdd(aAux,{'FK3_FILORI','E5_FILORIG'})

	Case cTabela == 'FK4' //Impostos Retidos.

		aAdd(aAux,{'FK4_DATA','E5_DATA'})
		aAdd(aAux,{'FK4_RECPAG','E5_RECPAG'})
		aAdd(aAux,{'FK4_MOEDA','E5_MOEDA'})
		aAdd(aAux,{'FK4_FILORI','E5_FILORIG'})

	Case cTabela == 'FK5' //Mov. Bancaria

		aAdd(aAux,{'FK5_DATA','E5_DATA'})
		aAdd(aAux,{'FK5_VALOR','E5_VALOR'})
		aAdd(aAux,{'FK5_MOEDA','E5_MOEDA'})
		aAdd(aAux,{'FK5_NATURE','E5_NATUREZ'})
		aAdd(aAux,{'FK5_BANCO','E5_BANCO'})
		aAdd(aAux,{'FK5_AGENCI'	,'E5_AGENCIA'})
		aAdd(aAux,{'FK5_CONTA','E5_CONTA'})
		aAdd(aAux,{'FK5_NUMCH','E5_NUMCHEQ'})
		aAdd(aAux,{'FK5_DOC','E5_DOCUMEN'})
		aAdd(aAux,{'FK5_LOTE','E5_LOTE'})
		aAdd(aAux,{'FK5_RECPAG','E5_RECPAG'})
		aAdd(aAux,{'FK5_HISTOR','E5_HISTOR'})
		aAdd(aAux,{'FK5_TPDOC','E5_TIPODOC'})
		aAdd(aAux,{'FK5_VLMOE2','E5_VLMOED2'})
		aAdd(aAux,{'FK5_DTDISP','E5_DTDISPO'})
		aAdd(aAux,{'FK5_FILORI','E5_FILORIG'})
		aAdd(aAux,{'FK5_MODSPB','E5_MODSPB'})
		aAdd(aAux,{'FK5_SEQCON','E5_SEQCON'})
		aAdd(aAux,{'FK5_TERCEI','E5_TERCEIR'})
		aAdd(aAux,{'FK5_TPMOV','E5_TIPOMOV'})
		aAdd(aAux,{'FK5_OK','E5_OK'})
		aAdd(aAux,{'FK5_RATEIO','E5_RATEIO'})
		aAdd(aAux,{'FK5_SEQ','E5_SEQ'})
		aAdd(aAux,{'FK5_PROTRA','E5_PROCTRA'})
		aAdd(aAux,{'FK5_CCUSTO','E5_CCUSTO'})
		aAdd(aAux,{'FK5_LA','E5_LA'})
		aAdd(aAux,{'FK5_ORDREC','E5_ORDREC'})
		aAdd(aAux,{'FK5_TXMOED','E5_TXMOEDA'})
		aAdd(aAux,{'FK5_ORIGEM','E5_ORIGEM'})

	Case cTabela == 'FK6' //Valores Acessorios.

		aAdd(aAux,{'FK6_TPDESC','E5_TPDESC'})
		aAdd(aAux,{'FK6_TPDOC','E5_TIPODOC'})
		aAdd(aAux,{'FK6_RECPAG','E5_RECPAG'})
		aAdd(aAux,{'FK6_VALMOV','E5_VALOR'})
		aAdd(aAux,{'FK6_HISTOR','E5_HISTOR'})

		If lCmpFK6
			aAdd(aAux,{'FK6_DATA'  ,'E5_DATA'})
			aAdd(aAux,{'FK6_MOEDA' ,'E5_MOEDA'})
			aAdd(aAux,{'FK6_TXMOED','E5_TXMOEDA'})
			aAdd(aAux,{'FK6_VLMOE2','E5_VLMOED2'})
			aAdd(aAux,{'FK6_LA'    ,'E5_LA'})
			aAdd(aAux,{'FK6_TXMOED','E5_TXMOEDA'})
			aAdd(aAux,{'FK6_ORIGEM','E5_ORIGEM'})
		Endif

	Case cTabela == 'FK8'

		aAdd(aAux,{'FK8_TPLAN','E5_TIPOLAN'})
		aAdd(aAux,{'FK8_DEBITO','E5_DEBITO'})
		aAdd(aAux,{'FK8_CREDIT','E5_CREDITO'})
		aAdd(aAux,{'FK8_RATEIO','E5_RATEIO'})
		aAdd(aAux,{'FK8_CCD','E5_CCD'})
		aAdd(aAux,{'FK8_CCC','E5_CCC'})
		aAdd(aAux,{'FK8_ARQRAT','E5_ARQRAT'})
		aAdd(aAux,{'FK8_ITEMD','E5_ITEMD'})
		aAdd(aAux,{'FK8_ITEMC','E5_ITEMC'})
		aAdd(aAux,{'FK8_CLVLDB','E5_CLVLDB'})
		aAdd(aAux,{'FK8_CLVLCR','E5_CLVLCR'})
		aAdd(aAux,{'FK8_DIACTB','E5_DIACTB'})
		aAdd(aAux,{'FK8_NODIA','E5_NODIA'})

	Case cTabela == 'FK9'

		aAdd(aAux,{'FK9_SITUA','E5_SITUA'})
		aAdd(aAux,{'FK9_PRJPMS','E5_PROJPMS'})
		aAdd(aAux,{'FK9_EDTPMS','E5_EDTPMS'})
		aAdd(aAux,{'FK9_TASPMS','E5_TASKPMS'})
		aAdd(aAux,{'FK9_OPERAD','E5_OPERAD'})
		aAdd(aAux,{'FK9_NUMMOV','E5_NUMMOV'})
		aAdd(aAux,{'FK9_FLDMED','E5_FLDMED'})
		aAdd(aAux,{'FK9_FORMPG','E5_FORMAPG'})

	End Case

	aRet := aClone(aAux)
	aSize(aAux,0)
	aAux := Nil
Return aRet

/*/{Protheus.doc}FinGrvSE5
Função que faz a gravação dos valores na SE5.
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FinGrvSE5(aCamposOrig, aDePara,oDetail,nLinha)
	Local nY := 0
	Local nPos := 0
	Default oDetail :=  NIL
	Default aCamposOrig := {}
	Default aDePara 	  :=  {}
	Default nLinha := 1

	For nY := 1 To Len(aCamposOrig)

		If oDetail:IsFieldUpdated(aCamposOrig[nY][1])  //Retorna se campo foi atualizado.
			//Grava SE5 com valores da FK6.
			If ( nPos := aScan(aDePara,{|x| AllTrim( x[1] ) == aCamposOrig[nY][1] } ) ) > 0
				&(aDePara[nPos,2]) := oDetail:GetValue(aCamposOrig[nY][1],nLinha)
			EndIf
		EndIf

	Next nY

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FINDELFKs
Função para retornar a identificação do processo do movimento
financeiro

@param cChave, Identificação do registro de origem
@param cAlias, Identificação da tabela de origem

@author Totvs
@since 18/04/2014
@version P12
/*/
//-------------------------------------------------------------------

Function FINDELFKs(cChave, cAlias)

	Local aArea := GetArea()
	Local cIdDOCFK7 := ""
	Local cChaveFKD := ""
	Local lLocBRA   := cPaisLoc == "BRA"

	dbSelectArea( "FK7" )
	FK7->(DbSetOrder(2)) //FK7_FILIAL+FK7_ALIAS+FK7_CHAVE
	If MsSeek(xFilial("FK7")+cAlias+cChave)
		If ExistBlock("FFKDLIB")
			ExecBlock("FFKDLIB",.F.,.F.)
		Endif

		cIdDOCFK7 := FK7->FK7_IDDOC

		If lLocBRA
            Fa986excl(cAlias)
        EndIf

		Reclock("FK7", .F.)
		FK7->(DbDelete())
		FK7->(Msunlock())

		//Valores Acessorios - Exclusão
		If FInDicTVA()
			FKD->(dbSetOrder(2))		//FKD_FILIAL+FKD_IDDOC+FKD_CODIGO
			If FKD->(DbSeek(xFilial("FKD")+cIdDOCFK7))

				cChaveFKD := xFilial("FKD")+cIdDOCFK7

				While FKD->(!EOF()) .AND. FKD->(FKD_FILIAL+FKD_IDDOC) == cChaveFKD
					RecLock("FKD",.F.)
					FKD->(DbDelete())
					FKD->(MsUnlock())

					FKD->(dbSkip())
				EndDo

			Endif
		Endif
	Endif

	RestArea(aArea)

Return


/*{Protheus.doc}FINVerMov
Função que retorna se o TIPODOC movimenta banco
@author Totvs
@since  23/04/2014
@version P12
*/
Function FINVerMov(cTipoDoc)
	Local lRet := .T.
	Default cTipoDoc	:= ""

	lRet := GetAdvFVal("FKB","FKB_ATUBCO",xFilial("FKB")+cTipoDoc,1,"") == "1"

Return lRet


//----------------------------------------------------------------------
/*{Protheus.doc}FINGRVFK7
Verifica se existe FK7 para o título, caso não exista grava
Retorno: FK7_IDDOC
@author Totvs
@since  23/04/2014
@version P12
*/
//----------------------------------------------------------------------
Function FINGRVFK7(cAlias, cChave, cFilMov)
	Local aAreaAnt	:= GetArea()
	Local cRet 		:= ""
	Local lChave	:= .T.
	Local cFilFK7	:= ""

	If __lFK7Cpos == NIL
		__lFK7Cpos	:= FK7->(ColumnPos("FK7_CLIFOR")) > 0
	Endif

	Default cFilMov := Substr(cChave,1,nTamFil)

	cFilFK7 := PadR(xFilial("FK7", cFilMov),nTamFil)

	dbSelectArea("FK7")
	dbSetOrder(2)

	If msSeek(cFilFK7 + cAlias + cChave)
		cRet := FK7->FK7_IDDOC
	Else
		//Tratativa para validar a ocorrência de repetição da chave da FWUUIDV4, caso ocorra
		FK7->(dbSetOrder(1))
		While lChave

			cRet := FWUUIDV4()
			If LockByName( cRet, .T./*lEmpresa*/, .T./*lFilial*/ )

				If MsSeek( cFilFK7 + cRet )
					lChave = .T.
				Else
					Reclock("FK7", .T.)
						FK7_FILIAL	:= xFilial("FK7", cFilMov)
						FK7_IDDOC	:= cRet
						FK7_ALIAS	:= cAlias
						FK7_CHAVE	:= cChave
					FK7->(MsUnlock())

					//Grava os novos campos
					If __lFK7Cpos .and. Empty(FK7->FK7_CLIFOR)
						FinFK7Cpos (FK7->FK7_CHAVE)
					Endif

					lChave := .F.
				EndIf
				UnLockByName( cRet, .T./*lEmpresa*/, .T./*lFilial*/ )

			EndIf
		EndDo
	Endif

	RestArea(aAreaAnt)
	FwFreeArray(aAreaAnt)

Return cRet

/*/{Protheus.doc}FINGrvFK5
Faz a gravação dos valores na FK5 com base na FK1/FK2.
@author William Matos Gundim Junior
@since  27/04/2014
@version 12
/*/
Function FINGrvFK5( oModel, cTipo )
	Local oFK5 			:= oModel:GetModel('FK5DETAIL')
	Local oFKA 			:= oModel:GetModel('FKADETAIL')
	Local oDetail		:= Nil
	Local nX			:= 0
	Local cAux			:= ""
	Local aAux 			:= {}
	Local aCampos 		:= {}
	Local aCamposFK5	:= FK5->(DbStruct())

	If cTipo == 'FK1'
		aCampos := FK1->(DbStruct())
		oDetail := oModel:GetModel('FK1DETAIL')
	Else
		aCampos := FK2->(DbStruct())
		oDetail := oModel:GetModel('FK2DETAIL')
	EndIf

	If oFKA:SeekLine( { {"FKA_TABORI", cTipo }})

		If FINVerMov(oDetail:GetValue(cTipo + "_" + "TPDOC"))

			//Grava valores no array para alimentar FK5
			For nX := 1 To Len(aCampos)

				aAdd(aAux, {	Substr(aCampos[nX][1],5, Len(aCampos[nX][1] ) ) , oDetail:GetValue(aCampos[nX][1]) })

			Next nX

		EndIf

	EndIf

	If Len(aAux) > 0

		//Busca no modelo
		If !oFKA:SeekLine( { {"FKA_TABORI","FK5"}})

			//Não encontrou FK5 com valores, grava nova FKA com valores na FK5
			oFKA:AddLine()
			oFKA:SetValue('FKA_IDORIG', FWUUIDV4() )
			oFKA:SetValue('FKA_TABORI', 'FK5')

		EndIf

		//Alimenta a FK5 com os valores da FK1 que pertence a outra FKA.
		For nX := 1 To Len(aAux)

			cAux := 'FK5_' + aAux[nX][1] //Auxiliar para campo FK5.
			If ( aScan(aCamposFK5,{|x| AllTrim( x[1] ) == cAux } ) ) > 0

				If !oFK5:IsFieldUpdated(cAux) .AND. oFK5:CanSetValue(cAux)

					oFK5:SetValue( cAux, aAux[nX][2]  )

				EndIf

			EndIf

		Next nX

	EndIf

	aSize(aAux,0)
	aSize(aCampos,0)
	aSize(aCamposFK5,0)

Return

/*/{Protheus.doc} FinSE5ToFKS
Funções auxiliares para os modelos de dados - Reestruturação SE5.
@author William Matos Gundim Junior
@since 10/04/2014
@version P12
/*/
Function FinSE5ToFKS(oProcesso)
	Local lRet := .T.

	MsgRun (STR0004,"FnBaixaE1",{||FnBaixaE1()})

	MsgRun (STR0005,"FnBuscaEF",{||FnBuscaEF()})

	MsgRun (STR0006,"FnBaixaE2",{||FnBaixaE2()})

	MsgRun (STR0007,"FnBuscaSE5",{||FnBuscaSE5()})

	MsgInfo(STR0008, STR0001)

Return lRet

/*/{Protheus.doc} FnBuscaSE5
Filtra os dados da SE5 com TIPODOC = '' ou TR.
@author William Matos Gundim Junior
@since 10/04/2014
@version P12
/*/
Function FnBuscaSE5(nPosSE5)
	Local cQuery 	:= ""
	Local cProc		:= ""
	Local cIdOrig 	:= ""
	Local nX		:= 0
	Local lRet 		:= .T.
	Local cAliasSE5	:= GetNextAlias()
	Local cFilBkp 	:= cFilAnt
	Local cBanco 		:= ""
	Local cAgencia 	:= ""
	Local cConta 		:= ""
	Local cNatureza	:= ""
	Local cCart		:= ""
	Local cFilSe5		:= ""


	Default nPosSE5 := 0

	If nPosSE5 = 0
		cQuery := "SELECT SE5.R_E_C_N_O_ RECNO "	+ CRLF
		cQuery += " FROM " +	RetSQLTab('SE5')	+	 CRLF
		cQuery += " WHERE " +	 CRLF
		cQuery += " E5_TIPODOC IN('','TR') AND " 	 + CRLF
		cQuery += " E5_DATA >= '" + DTOS(MV_PAR01) + "' AND " + CRLF
		cQuery += " E5_DATA <= '" + DTOS(MV_PAR02) + "' AND " + CRLF
		cQuery += "	E5_SITUACA NOT IN ('C')  AND "			+ CRLF // retirada o X, pois se trata de momentos estornados pelo FINA100 e retirada o E que é o movimento de estorno em si
		// esses movimentos estornados estão visiveis no extrato e passiveis de conciliação.
		cQuery += " E5_MOVFKS  <> 'S' AND " 		+ CRLF
		cQuery += " SE5.D_E_L_E_T_ = ' ' " 		+ CRLF

		cQuery += " UNION " + CRLF

		//Documento que movimenta banco e não esta relacionado a nenhum titulo.
		cQuery += "SELECT SE5.R_E_C_N_O_ RECNO "	+ CRLF
		cQuery += " FROM " +	RetSQLTab('SE5')			+	CRLF
		cQuery += " WHERE E5_TIPODOC IN ( " 			+	CRLF
		cQuery += " 			SELECT FKB_TPDOC " + " FROM " +	RetSQLTab('FKB') + " WHERE FKB_ATUBCO = '1' AND "	+	CRLF
		//Cheques são filtrados na FnBuscaEF.
		cQuery += " 			FKB_TPDOC <> 'TR' AND D_E_L_E_T_ = ' ') AND " +	CRLF
		cQuery += " E5_DATA >= '" + DTOS(MV_PAR01) + "' AND " + CRLF
		cQuery += " E5_DATA <= '" + DTOS(MV_PAR02) + "' AND " + CRLF
		cQuery += "	E5_SITUACA NOT IN ('C','E','X')  		AND (( "	+ CRLF
		//Não relacionado a nenhum titulo.
		cQuery += " E5_PREFIXO = '' AND " 		+ CRLF
		cQuery += " E5_NUMERO  = '' AND " 		+ CRLF
		cQuery += " E5_PARCELA = '') OR " 		+ CRLF
		//Despesas bancárias geradas pelo retorno CNAB
		cQuery += " E5_TIPODOC IN ( 'DB', 'OD' )) AND " 		+ CRLF
		//
		cQuery += " E5_MOVFKS  <> 'S' AND " + CRLF
		cQuery += " SE5.D_E_L_E_T_ = ' ' " + CRLF
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.T.,.T.)
		dbSelectArea(cAliasSE5)
		DbGotop()
		lRet := !(cAliasSE5)->(EOF())

	EndIf

	dbSelectArea('SE5')
	dbSelectArea('SA6')
	SA6-> (DbSetOrder(1))

	While lRet

		If nPosSE5 = 0
			SE5->(dbGoTo(	(cAliasSE5)->RECNO))
		Else
			SE5->(dbGoTo(nPosSE5))
		EndIf
		If Alltrim(SE5->E5_TIPODOC) $ "BA|VL|V2|LJ|CP" .and. Empty(SE5->E5_KEY)
			If nPosSE5 > 0
				lRet := .F.
				Exit
			Else
				(cAliasSE5)->(dbSkip())
				lRet := !(cAliasSE5)->(EOF())
				Loop
			EndIf
		EndIf
		If lFilExclus
			cFilAnt := SE5->E5_FILIAL
		EndIf

		cBanco		:= SE5->E5_BANCO
		cAgencia 	:= SE5->E5_AGENCIA
		cConta	 	:= SE5->E5_CONTA
		cCart		:= SE5->E5_RECPAG
		cFilSe5		:= SE5->E5_FILIAL

		//Novo processo
		cProc	:= FINFKSID('FKA','FKA_IDPROC')
		cIdOrig := FWUUIDV4()

		//Grava FKA - Auxiliar
		RecLock("FKA", .T.)
		FKA_FILIAL 	:= SE5->E5_FILIAL
		FKA_IDFKA	:= FWUUIDV4()
		FKA_IDPROC	:= cProc
		FKA_IDORIG	:= cIdOrig
		FKA_TABORI	:= "FK5"
		FKA->(MsUnlock())

		If lSE5GRVFK
			aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK5", aCamposFK5})
			If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
				aCamposFK5 := Aclone(aSE5GRVFK)
			EndIf
			Asize(aSE5GRVFK, 0)
			aSE5GRVFK := Nil
		EndIf

		RecLock("FK5", .T.)

		For nX := 1 To Len(aCamposFK5)

			nPos := SE5->(FieldPos(aCamposFK5[nX][2]) )
			If nPos > 0

				FieldPut(FK5->(FieldPos(aCamposFK5[nX][1])), SE5->(FieldGet(nPos) ) )

				If aCamposFK5[nX][2] == "E5_MOEDA" .AND. Empty(SE5->(FieldGet(nPos)))
					If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
						FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), StrZero(SA6->A6_MOEDA,2) )
					Else
						FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), "01" )
					EndIf
				EndIf
				If aCamposFK5[nX][2] == "E5_NATUREZ" .AND. Empty(SE5->(FieldGet(nPos)))
					cNatureza := FINNATMOV(cCart)
					FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), cNatureza )
				EndIf
				If aCamposFK5[nX][2] == "E5_FILORIG" .AND. Empty(SE5->(FieldGet(nPos)))
					FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), cFilSe5 )
				EndIf

			EndIf

		Next nX

		FK5->FK5_FILIAL := SE5->E5_FILIAL
		FK5->FK5_IDMOV 	:= cIdOrig
		FK5->FK5_ORIGEM := "FINXSE5"
		FK5->FK5_STATUS := CriaVar("FK5_STATUS")
		FK5->FK5_TERCEI	:= CriaVar("FK5_TERCEI")
		FK5->FK5_TPMOV	:= CriaVar("FK5_TPMOV")

		If AllTrim(FK5->FK5_TPDOC) $ 'OD|DB' .And. !Empty(SE5->E5_NUMERO)
			cChave := xFilial("SE1", SE5->E5_FILORIG) + "|" +  SE5->E5_PREFIXO + "|" + SE5->E5_NUMERO + "|" + SE5->E5_PARCELA + "|" + SE5->E5_TIPO + "|" +;
			SE5->E5_CLIFOR + "|" + SE5->E5_LOJA

			FK5->FK5_IDDOC := FINGRVFK7('SE1', cChave)
		EndIf

		If Empty(FK5->FK5_TPDOC)
			FK5->FK5_TPDOC := "DH"
		EndIf
		FK5->FK5_RATEIO := If(SE5->E5_RATEIO == 'S','1','2')
		FK5->(MsUnlock())

		//Grava valores na FK8 com os dados contabeis.
		If !Empty(SE5->E5_TIPOLAN)

			If lSE5GRVFK
				aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK8", aCamposFK8})
				If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
					aCamposFK8 := Aclone(aSE5GRVFK)
				EndIf
				Asize(aSE5GRVFK, 0)
				aSE5GRVFK := Nil
			EndIf

			RecLock("FK8", .T.)
			For nX := 1 To Len(aCamposFK8)

				nPos := SE5->(FieldPos(aCamposFK8[nX][2]) )
				If nPos > 0

					FieldPut(FK8->(FieldPos(aCamposFK8[nX][1])), SE5->(FieldGet(nPos) ) )

				EndIf

			Next nX
			FK8->FK8_FILIAL := SE5->E5_FILIAL
			FK8->FK8_IDMOV 	:= cIdOrig
			FK8->FK8_TPLAN := If(SE5->E5_TIPOLAN == 'D','1', If(SE5->E5_TIPOLAN == 'C','2','X'))
			FK8->(MsUnlock())

		EndIf

		//Atualiza o campo E5_MOVFKS = 'S' -> Campo de controle do migrador.
		Reclock("SE5", .F.)
		E5_MOVFKS := "S"
		E5_IDORIG := cIdOrig
		E5_TABORI := "FK5"
		SE5->(MsUnlock())

		If nPosSE5 > 0
			lRet := .F.
		Else
			(cAliasSE5)->(dbSkip())
			lRet := !(cAliasSE5)->(EOF())
		EndIf
	End
	If nPosSE5 = 0
		(cAliasSE5)->(DBCloseArea())
	EndIf
	FErase(cAliasSE5 + GetDBExtension())
	cFilAnt := cFilBkp
Return

/*/{Protheus.doc} FnBaixaE2
Filtra os dados baixados da SE2.
@author William Matos Gundim Junior
@since 10/04/2014
@version P12
/*/
Function FnBaixaE2(nPosSE5)
	Local nX		:= 0
	Local cQuery	:= ''
	Local cChave	:= ''
	Local cIdDoc	:= ''
	Local cIdOrig	:= ''
	Local cIdOrigFK5 := ''
	Local cProc	:= ''
	Local cAliasSE2 := GetNextAlias()
	Local cGeraFK6  := 'C2|CM|CX|DC|J2|JR|M2|MT|VM'
	Local cTabOri := ""
	Local cIdOrigEs := ""
	Local cFilBkp := cFilAnt
	Local cSeqAtu := ""
	Local cChaveAnt 	:= ""
	Local cBanco 		:= ""
	Local cAgencia 	:= ""
	Local cConta 		:= ""
	Local cNatureza	:= ""
	Local cTipDoc :="ES"
	Local lCmpFK2 	:= FK2->(FieldPos("FK2_DTDISP")) > 0  .and. FK2->(FieldPos("FK2_DTDIGI")) > 0
	Local cTpDesc	:= ""

	Default nPosSE5 := 0 //Variavel com posição da SE5 que deve ser atualizada.

	If cPaisLoc<> "BRA"
		cTipDoc:="ES|BA|CP"
	EndIf

	//Baixas a Pagar.
	cQuery := "SELECT SE5.R_E_C_N_O_ RECNO, E5_TIPODOC TPDOC"	+ CRLF
	cQuery += " FROM " +	RetSQLTab('SE5')	+	 CRLF
	cQuery += "	JOIN " + RetSQLTab('SE2')+ CRLF
	cQuery += " ON   SE5.E5_FILORIG = SE2.E2_FILORIG	AND " + CRLF
	cQuery += "      SE5.E5_PREFIXO = SE2.E2_PREFIXO	AND " + CRLF
	cQuery += "      SE5.E5_NUMERO  = SE2.E2_NUM		AND " + CRLF
	cQuery += "      SE5.E5_PARCELA = SE2.E2_PARCELA 	AND " + CRLF
	cQuery += "      SE5.E5_TIPO	= SE2.E2_TIPO 		AND " + CRLF
	cQuery += "      SE5.E5_CLIFOR 	= SE2.E2_FORNECE 	AND " + CRLF
	cQuery += "      SE5.E5_CLIENTE	= ' '			 	AND " + CRLF
	cQuery += "      SE5.E5_LOJA	= SE2.E2_LOJA AND " 	      + CRLF
	cQuery += "      SE5.E5_NATUREZ = SE2.E2_NATUREZ AND " 	      + CRLF
	cQuery += "      SE2.D_E_L_E_T_ = ' ' " 	      + CRLF
	cQuery += " WHERE "  			 				+ CRLF

	//Filtra pelo RECNO informado.
	If nPosSE5 > 0
		cQuery += " E5_PREFIXO = '" + SE5->E5_PREFIXO	+ "' AND "	+ CRLF
		cQuery += " E5_NUMERO  = '" + SE5->E5_NUMERO	+ "' AND "	+ CRLF
		cQuery += " E5_PARCELA = '" + SE5->E5_PARCELA	+ "' AND "	+ CRLF
		cQuery += " E5_TIPO = '"	+ SE5->E5_TIPO		+ "' AND "	+ CRLF

		cQuery += " E5_CLIFOR = '"  + SE5->E5_CLIFOR	+ "' AND "	+ CRLF
		cQuery += " E5_LOJA = '"	+ SE5->E5_LOJA		+ "' AND "	+ CRLF
		cQuery += " E5_TIPODOC NOT IN ('PA') AND " + CRLF
		cQuery += " E5_SITUACA NOT IN ('C','E','X') AND "			+ CRLF

	Else

		cQuery += " E5_DATA >= '" 	+ DTOS(MV_PAR01) + "' AND " 	+ CRLF
		cQuery += " E5_DATA  <= '" + DTOS(MV_PAR02) + "' AND " 	+ CRLF
		cQuery += "	E5_SITUACA NOT IN ('C','E','X')  AND "				+ CRLF
		cQuery += " E5_MOVFKS  <> 'S' AND " 		+ CRLF
		cQuery += " E5_TIPODOC NOT IN ('PA') AND " + CRLF
		cQuery += " SE5.D_E_L_E_T_ = ' ' " 		+ CRLF

		cQuery += " UNION " + CRLF

		//Adiantamento - PA.
		cQuery += "SELECT SE5.R_E_C_N_O_ RECNO, E5_TIPODOC TPDOC"	+ CRLF
		cQuery += " FROM " +	RetSQLTab('SE5')	+	 CRLF
		cQuery += "	JOIN " + RetSQLTab('SE2')+ CRLF
		cQuery += " ON   SE5.E5_FILORIG = SE2.E2_FILORIG	AND " + CRLF
		cQuery += "      SE5.E5_PREFIXO = SE2.E2_PREFIXO	AND " + CRLF
		cQuery += "      SE5.E5_NUMERO  = SE2.E2_NUM		AND " + CRLF
		cQuery += "      SE5.E5_PARCELA = SE2.E2_PARCELA 	AND " + CRLF
		cQuery += "      SE5.E5_TIPO	= SE2.E2_TIPO 		AND " + CRLF
		cQuery += "      SE5.E5_CLIFOR 	= SE2.E2_FORNECE 	AND " + CRLF
		cQuery += "      SE5.E5_CLIENTE	= ' '			 	AND " + CRLF
		cQuery += "      SE5.E5_LOJA	= SE2.E2_LOJA AND " 	      + CRLF
		cQuery += "      SE5.E5_NATUREZ = SE2.E2_NATUREZ AND " 	      + CRLF
		cQuery += "      SE2.D_E_L_E_T_ = ' ' " 	      + CRLF
		cQuery += " WHERE "																									+ CRLF
		cQuery += " E5_TIPODOC IN('PA','BA') AND "  			 					+ CRLF
		cQuery += " E5_DATA >= '" + DTOS(MV_PAR01) + "' AND " 	+ CRLF
		cQuery += " E5_DATA <= '" + DTOS(MV_PAR02) + "' AND " 	+ CRLF
		cQuery += " E5_MOTBX <> 'CMP' AND " 													+ CRLF
		cQuery += "	E5_SITUACA NOT IN ('C','E','X')  AND "				+ CRLF
		cQuery += " E5_MOVFKS  <> 'S' AND " 		+ CRLF
	EndIf
	cQuery += " SE5.D_E_L_E_T_ = ' ' " 			+ CRLF
	cQuery += " ORDER BY RECNO,TPDOC " + CRLF

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.T.,.T.)
	dbSelectArea(cAliasSE2)

	DbGotop()

	dbSelectArea('SE5')
	dbSelectArea('SA6')
	SA6-> (DbSetOrder(1))
	While !(cAliasSE2)->(Eof())

		SE5->(dbGoTo((cAliasSE2)->RECNO))

		cTabOri := ""
		cIdOrigFK5 := ""
		cProc := ""
		cIdOrigEs := ""

		If lFilExclus
			cFilAnt := SE5->E5_FILIAL
		EndIf
		//se for estorno de cheque, nao migrar aqui e sim este deve ser no finm030
		If Alltrim(SE5->E5_TIPODOC) == "ES" .And. Empty(SE5->E5_MOTBX) .And. !Empty(SE5->E5_NUMCHEQ)
			(cAliasSE2)->(dbSkip())
			Loop
		EndIf

		//Chave para ser gravada na FK7.
		cChave :=  xFilial("SE5", SE5->E5_FILORIG) + "|" +  SE5->E5_PREFIXO + "|" + SE5->E5_NUMERO + "|" + SE5->E5_PARCELA + "|" + SE5->E5_TIPO + "|" +;
					SE5->E5_CLIFOR + "|" + SE5->E5_LOJA

		//tratamento para base antiga em que os valores acessorios sao gravados primeiro
		// que o registro da Baixa, para que seja criado primeiro o registro FK1
		If (cSeqAtu != SE5->E5_SEQ .or. cChaveAnt != cChave .or. SE5->E5_TIPODOC $ cTipDoc)
			cIdOrig := FWUUIDV4()
			cSeqAtu := SE5->E5_SEQ
			cChaveAnt := cChave
		Endif

		//somente gera FK2 para tipodoc de baixa BA VL ou CP

		If Alltrim(SE5->E5_TIPODOC) $ "BA|VL|V2|ES|LJ|CP"
			cIdDoc := FINGRVFK7('SE2', cChave)

			If Alltrim(SE5->E5_TIPODOC) == "ES"
				cIdOrigEs := GeraEstFK5( "P" )
			EndIf

			//Novo processo
			If Empty(cProc := FINProcFKs(If(!Empty(cIdOrigEs) ,cIdOrigEs,SE5->E5_IDORIG), "FK2" ))
				cProc := FINFKSID('FKA','FKA_IDPROC')
			EndIf
			//Grava FKA - Rastreio de movimento---------------------
			RecLock("FKA", .T.)
			FKA_FILIAL	:= SE5->E5_FILIAL
			FKA_IDFKA	:= FWUUIDV4()
			FKA_IDPROC	:= cProc
			FKA_IDORIG	:= cIdOrig
			FKA_TABORI	:= "FK2"
			FKA->(MsUnlock())

			If lSE5GRVFK
				aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK2", aCamposFK2})
				If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
					aCamposFK2 := Aclone(aSE5GRVFK)
				EndIf
				Asize(aSE5GRVFK, 0)
				aSE5GRVFK := Nil
			EndIf

			RecLock("FK2", .T.)
			//Grava FK2 - Baixas a Pagar-----------------------------
			For nX := 1 To Len(aCamposFK2)
				nPos := SE5->(FieldPos(aCamposFK2[nX][2]) )
				If nPos > 0
					FieldPut(FK2->(FieldPos(aCamposFK2[nX][1])), SE5->(FieldGet(nPos) ) )
				EndIf
			Next nX

			FK2->FK2_FILIAL := SE5->E5_FILIAL
			FK2->FK2_IDFK2 := cIdOrig
			FK2->FK2_IDDOC  := cIdDoc
			FK2->FK2_IDPROC := SE5->E5_IDENTEE
			FK2->FK2_ORIGEM	:= "FINXSE5"
			If Empty(SE5->E5_MOEDA)
				FK2->FK2_MOEDA := "01"
			EndIf

			//Gravação dos campos FK2_DTDISP e FK2_DTDIG
			If lCmpFK2
				FK2->FK2_DTDISP := SE5->E5_DTDISPO
				FK2->FK2_DTDIGI := SE5->E5_DTDIGIT
			Endif

			FK2->(MsUnlock())
			cTabOri := "FK2"

		ElseIf Alltrim(SE5->E5_TIPODOC) == "CH"
			FnBuscaEF( (cAliasSE2)->RECNO )
			(cAliasSE2)->(dbSkip())
			Loop
		EndIf


		//------------------------------------------------------
		Do Case
			//Grava FK6 - Valores acessórios.
		Case SE5->E5_TIPODOC $ cGeraFK6

			cIdFK6 := FINFKSID('FK6', 'FK6_IDFK6')

			If lSE5GRVFK
				aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK6", aCamposFK6})
				If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
					aCamposFK6 := Aclone(aSE5GRVFK)
				EndIf
				Asize(aSE5GRVFK, 0)
				aSE5GRVFK := Nil
			EndIf

			RecLock("FK6", .T.)
			For nX := 1 To Len(aCamposFK6)

				nPos := SE5->(FieldPos(aCamposFK6[nX][2]) )
				If nPos > 0

					FieldPut(FK6->(FieldPos(aCamposFK6[nX][1])),SE5->(FieldGet(nPos)))

				EndIf

			Next nX

			cTpDesc := IIF(FK6->FK6_TPDESC == "C","1","2")

			FK6->FK6_FILIAL := SE5->E5_FILIAL
			FK6->FK6_IDFK6	:= cIdFK6
			FK6->FK6_IDORIG := cIdOrig
			FK6->FK6_TABORI := 'FK2'
			FK6->FK6_TPDESC := cTpDesc

			FK6->(MsUnlock())
			cTabOri := "FK2"
			cIdFK6 := "" //Limpa o IDFK6
			// FK5 - Grava valores na tabela de movimentação bancaria.
		Case	FINVerMov(SE5->E5_TIPODOC).AND. MovBcobx(SE5->E5_MOTBX , .F.)//Só gera FK5 se o motivo de baixa atualiza banco

			cIdOrigFK5 := FWUUIDV4()

			If Empty(cProc)
				If Empty(cProc := FINProcFKs(SE5->E5_IDORIG, "FK2" ))
					cProc := FINFKSID('FKA','FKA_IDPROC')
				EndIf
			EndIf
			cBanco		:= SE5->E5_BANCO
			cAgencia 	:= SE5->E5_AGENCIA
			cConta 	    := SE5->E5_CONTA

			//
			RecLock("FKA", .T.)
			FKA_FILIAL 	:= SE5->E5_FILIAL
			FKA_IDFKA	:= FWUUIDV4()
			FKA_IDPROC	:= cProc
			FKA_IDORIG	:= cIdOrigFK5
			FKA_TABORI	:= "FK5"
			FKA->(MsUnlock())

			If lSE5GRVFK
				aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK5", aCamposFK5})
				If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
					aCamposFK5 := Aclone(aSE5GRVFK)
				EndIf
				Asize(aSE5GRVFK, 0)
				aSE5GRVFK := Nil
			EndIf

			RecLock("FK5", .T.)

			For nX := 1 To Len(aCamposFK5)

				nPos := SE5->(FieldPos(aCamposFK5[nX][2]) )
				If nPos > 0

					FieldPut(FK5->(FieldPos(aCamposFK5[nX][1])), SE5->(FieldGet(nPos) ) )
					If aCamposFK5[nX][2] == "E5_MOEDA" .AND. Empty(SE5->(FieldGet(nPos)))
						If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
							FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), StrZero(SA6->A6_MOEDA,2) )
						Else
							FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), "01" )
						EndIf
					EndIf

					If aCamposFK5[nX][2] == "E5_NATUREZ" .AND. Empty(SE5->(FieldGet(nPos)))
						cNatureza := FINNATMOV("P")
						FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), cNatureza )
					EndIf

				EndIf

			Next nX

			FK5->FK5_FILIAL := SE5->E5_FILIAL
			FK5->FK5_IDMOV 	:= cIdOrigFK5
			FK5->FK5_ORIGEM:= "FINXSE5"


			cTabOri := Iif(cTabOri == "FK2", cTabOri, "FK5")
			cIdOrig := Iif(cTabOri == "FK2",cIdOrig ,cIdOrigFK5)
			FK5->(MsUnlock())

		EndCase

		//Atualiza o campo E5_MOVFKS = 'S' -> Campo de controle do migrador.
		Reclock("SE5", .F.)
		E5_MOVFKS := "S"
		E5_IDORIG := cIdOrig
		E5_TABORI := cTabOri
		SE5->(MsUnlock())
		//-------------------------------------------------------------
		(cAliasSE2)->(dbSkip())

	Enddo
	(cAliasSE2)->(DBCloseArea())
	FErase(cAliasSE2 + GetDBExtension())

	//Reposiciona na SE5
	If nPosSE5 > 0
		SE5->(dbGoTo(nPosSE5))
	EndIf
	cFilAnt := cFilBkp
Return

/*/{Protheus.doc} FnBaixaE1
Filtra os dados baixados da SE1 - Baixas a Receber.
@author William Matos Gundim Junior
@since 10/04/2014
@version P12
/*/
Function FnBaixaE1(nPosSE5)
	Local nX 			:= 0
	Local cQuery := ''
	Local cProc	:= ''
	Local cChave := ''
	Local cIdDoc 	:= ''
	Local cIdOrig := ''
	Local cAliasSE1 := GetNextAlias()
	Local cGeraFK6  := 'C2|CM|CX|DC|J2|JR|M2|MT|VM'
	Local cTabOri := ""
	Local cIdOrigFK5 := ""
	Local cIdOrigEs := ""
	Local cFilBkp := cFilAnt
	Local cSeqAtu	:= ""
	Local cChaveAnt := ""
	Local cBanco 		:= ""
	Local cAgencia 		:= ""
	Local cConta 		:= ""
	Local cNatureza	:= ""
	Local cTipDoc:="ES"
	Local cCodNat	:= FINNATFKS()
	Local aAliasAnt	:= ""
	Local lCmpFK1 	:= FK1->(FieldPos("FK1_DTDISP")) .and. FK1->(FieldPos("FK1_DTDIGI"))
	Local lFina087	:= .F.
	Local aRecSe5	:= {}
	Local nCnt		:= 0
	Local cTpDesc	:=""
	Default nPosSE5 := 0

	If cPaisLoc<> "BRA"
		cTipDoc:="ES|BA|CP"
	EndIf

	//Baixas a Receber.
	cQuery := "SELECT SE5.R_E_C_N_O_ RECNO, E5_TIPODOC TPDOC"	+ CRLF
	cQuery += " FROM " +	RetSQLTab('SE5')	+	 CRLF
	cQuery += "	JOIN " + RetSQLTab('SE1')+ CRLF
	cQuery += " ON   SE5.E5_FILORIG = SE1.E1_FILORIG	AND " + CRLF
	cQuery += "      SE5.E5_PREFIXO = SE1.E1_PREFIXO	AND " + CRLF
	cQuery += "      SE5.E5_NUMERO  = SE1.E1_NUM		AND " + CRLF
	cQuery += "      SE5.E5_PARCELA = SE1.E1_PARCELA 	AND " + CRLF
	cQuery += "      SE5.E5_TIPO	= SE1.E1_TIPO 		AND " + CRLF
	cQuery += "      SE5.E5_CLIFOR 	= SE1.E1_CLIENTE 	AND " + CRLF
	cQuery += "      SE5.E5_FORNECE	= ' '			 	AND " + CRLF
	cQuery += "      SE5.E5_LOJA	= SE1.E1_LOJA AND " 	+ CRLF
	cQuery += "      SE5.E5_NATUREZ = SE1.E1_NATUREZ AND " 	+ CRLF
	cQuery += "      SE1.D_E_L_E_T_ = ' '   " 	+ CRLF
	cQuery += " WHERE " 	+ CRLF
	//Filtra apenas o recno informado.
	If nPosSE5 > 0
		cQuery += " E5_PREFIXO = '" + SE5->E5_PREFIXO  	+ "' AND "	+ CRLF
		cQuery += " E5_NUMERO  = '" + SE5->E5_NUMERO	+ "' AND "	+ CRLF
		cQuery += " E5_PARCELA = '" + SE5->E5_PARCELA	+ "' AND "	+ CRLF
		cQuery += " E5_TIPO = '"	+ SE5->E5_TIPO		+ "' AND "	+ CRLF
		cQuery += " E5_CLIFOR = '"	+ SE5->E5_CLIFOR	+ "' AND "	+ CRLF
		cQuery += " E5_LOJA = '"	+ SE5->E5_LOJA		+ "' AND "	+ CRLF
		cQuery += " E5_TIPODOC NOT IN ('RA') AND " 			+ CRLF //Não importar RA, pois o mesmo deve ser importado apenas para FK5
		cQuery += "	E5_SITUACA NOT IN ('C','E','X') AND	"			+ CRLF
		cQuery += " SE5.D_E_L_E_T_ = ' ' " 		+ CRLF
	Else

		cQuery += " E5_DATA >= '" 	+ DTOS(MV_PAR01)	+ "' AND " 	+ CRLF
		cQuery += " E5_DATA  <= '" + DTOS(MV_PAR02)		+ "' AND " 	+ CRLF
		cQuery += " E5_SITUACA NOT IN ('C','E','X') AND "			+ CRLF
		cQuery += " E5_MOVFKS  <> 'S' AND " 						+ CRLF
		cQuery += " E5_TIPODOC NOT IN ('RA') AND " 			+ CRLF //ADICIONEI TRATAMENTO A BAIXA DO TIPO BA
		cQuery += " SE5.D_E_L_E_T_ = ' ' " 							+ CRLF

		cQuery += " UNION "

		//Adiantamento - RA.
		cQuery += "SELECT SE5.R_E_C_N_O_ RECNO, E5_TIPODOC TPDOC"	+ CRLF
		cQuery += " FROM " +	RetSQLTab('SE5')	+	 CRLF
		cQuery += "	JOIN " + RetSQLTab('SE1')+ CRLF
		cQuery += " ON   SE5.E5_FILORIG = SE1.E1_FILORIG	AND " + CRLF
		cQuery += "      SE5.E5_PREFIXO = SE1.E1_PREFIXO	AND " + CRLF
		cQuery += "      SE5.E5_NUMERO  = SE1.E1_NUM		AND " + CRLF
		cQuery += "      SE5.E5_PARCELA = SE1.E1_PARCELA 	AND " + CRLF
		cQuery += "      SE5.E5_TIPO	= SE1.E1_TIPO 		AND " + CRLF
		cQuery += "      SE5.E5_CLIFOR 	= SE1.E1_CLIENTE 	AND " + CRLF
		cQuery += "      SE5.E5_FORNECE	= ' '			 	AND " + CRLF
		cQuery += "      SE5.E5_LOJA	= SE1.E1_LOJA AND "			  + CRLF
		cQuery += "      SE5.E5_NATUREZ	= SE1.E1_NATUREZ AND "			  + CRLF
		cQuery += "      SE1.D_E_L_E_T_ = ' ' "			  + CRLF
		cQuery += " WHERE " 				+ CRLF
		cQuery += " E5_TIPODOC IN('RA','BA') AND "  	 + CRLF
		cQuery += " E5_DATA >= '" + DTOS(MV_PAR01) + "' AND " 	+ CRLF
		cQuery += " E5_DATA <= '" + DTOS(MV_PAR02) + "' AND " 	+ CRLF
		cQuery += " E5_MOTBX <> 'CMP' AND " 					+ CRLF
		cQuery += "	E5_SITUACA NOT IN ('C','E','X')  AND "		+ CRLF
		cQuery += " E5_MOVFKS  <> 'S' AND " 	+ CRLF
		cQuery += " SE5.D_E_L_E_T_ = ' ' " 		+ CRLF
	EndIf

	cQuery += " ORDER BY RECNO,TPDOC "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.T.,.T.)
	dbSelectArea(cAliasSE1)
	DbGotop()

	dbSelectArea('SE5')
	dbSelectArea('SA6')
	SA6-> (DbSetOrder(1))
	While !(cAliasSE1)->(Eof())
		aRecSe5 := {}
		lFina087 := .F.
		SE5->(dbGoTo((cAliasSE1)->RECNO))
		aAdd(aRecSe5, (cAliasSE1)->RECNO)
		//Tratamento baixa por Recebimentos Diversos
		//Todos movimentos do recibo possuem o mesmo número de processo
		If AllTrim(SE5->E5_MOVFKS) $ "S"
			(cAliasSE1)->(DbSkip())
			Loop
		EndIf
		If AllTrim(SE5->E5_ORIGEM) $ 'FINA087A|FINA846|FINA840'
			aRecSe5 := BxReciboE1((cAliasSE1)->RECNO)
			lFina087 := .T.
		EndIf
		cProc := ""
		For nCnt := 1 to Len(aRecSe5)
			SE5->(dbGoTo(aRecSe5[nCnt]))
			If Empty(SE5->E5_NATUREZ)
				aAliasAnt	:= GetArea()
				SE1->(dbSetOrder(1))
				If SE1->(dbSeek(xFilial("SE1")+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO))
					Reclock("SE1",.F.)
					SE1->E1_NATUREZ	:= cCodNat
					MsUnlock()
				EndIf

				Reclock("SE5",.F.)
				SE5->E5_NATUREZ	:= cCodNat
				MsUnlock()
				RestArea(aAliasAnt)
			Endif
			cTabOri := ""
			cIdOrigFK5 := ""
			cIdOrigEs := ""
			If lFilExclus
				cFilAnt := SE5->E5_FILIAL
			EndIf

			//Chave para ser gravada na FK7.
			cChave := xFilial("SE1",SE5->E5_FILORIG) + "|" +  SE5->E5_PREFIXO + "|" + SE5->E5_NUMERO + "|" + SE5->E5_PARCELA + "|" + SE5->E5_TIPO + "|" +;
				SE5->E5_CLIFOR + "|" + SE5->E5_LOJA

			//se for estorno de cheque, nao migrar aqui e sim este deve ser no finm030
			If Alltrim(SE5->E5_TIPODOC) == "ES" .And. !Empty(SE5->E5_NUMCHEQ)
				(cAliasSE1)->(dbSkip())
				Loop
			EndIf

			//tratamento para base antiga em que os valores acessorios sao gravados primeiro
			// que o registro da Baixa, para que seja gravado o mesmo idorig
			If (cSeqAtu != SE5->E5_SEQ .or. cChaveAnt != cChave .or. SE5->E5_TIPODOC $ cTipDoc)
				cIdOrig := FWUUIDV4()
				cSeqAtu := SE5->E5_SEQ
				cChaveAnt:= cChave
			Endif

			// somente gera FK1 para tipodoc de baixa BA VL ou CP
			If Alltrim(SE5->E5_TIPODOC) $ "BA|VL|V2|ES|LJ|CP" .AND. !(lFina087 .AND. Alltrim(SE5->E5_TIPODOC) $ "VL")
				//Grava FK7 - Auxiliar da SE1|SE2-----------------------
				cIdDoc := FINGRVFK7('SE1', cChave)
				cIdOrig := FWUUIDV4()

				If Alltrim(SE5->E5_TIPODOC) == "ES"
					cIdOrigEs := GeraEstFK5( "R" )
				EndIf

				//Novo processo
				If !lFina087 .Or. Empty(cProc)
					If Empty(cProc := FINProcFKs(Iif(!Empty(cIdOrigEs),cIdOrigEs,SE5->E5_IDORIG), "FK1" ))
						cProc := FINFKSID('FKA','FKA_IDPROC')
					EndIf
				EndIf

				//Grava FKA - Rastreio de movimento---------------------
				RecLock("FKA", .T.)
				FKA_FILIAL 	    := SE5->E5_FILIAL
				FKA_IDFKA	 	:= FWUUIDV4()
				FKA_IDPROC		:= cProc
				FKA_IDORIG		:= cIdOrig
				FKA_TABORI		:= "FK1"
				FKA->(MsUnlock())

				If lSE5GRVFK
					aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK1", aCamposFK1})
					If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
						aCamposFK1 := Aclone(aSE5GRVFK)
					EndIf
					Asize(aSE5GRVFK, 0)
					aSE5GRVFK := Nil
				EndIf

				//Grava FK1 - Baixas a Receber-----------------------------
				RecLock("FK1", .T.)
				For nX := 1 To Len(aCamposFK1)

					nPos := SE5->(FieldPos(aCamposFK1[nX][2]) )
					If nPos > 0

						FieldPut(FK1->(FieldPos(aCamposFK1[nX][1])), SE5->(FieldGet(nPos) ) )

					EndIf

				Next nX

				FK1_FILIAL := SE5->E5_FILIAL
				FK1_IDFK1  := cIdOrig
				FK1_IDDOC  := cIdDoc
				FK1_IDPROC := SE5->E5_IDENTEE
				FK1_ORIGEM := If(Empty(FK1->FK1_ORIGEM),"FINXSE5",FK1->FK1_ORIGEM)

				cTabOri    := "FK1"

				//Gravação dos campos FK1_DTDISP e FK1_DTDIGI
				If lCmpFK1
					FK1->FK1_DTDISP := SE5->E5_DTDISPO
					FK1->FK1_DTDIGI := SE5->E5_DTDIGIT
				Endif
				FK1->(MsUnlock())

			ElseIf Alltrim(SE5->E5_TIPODOC) == "CH"
				FnBuscaEF( (cAliasSE1)->RECNO )
				(cAliasSE1)->(dbSkip())
				Loop

			EndIf


			//------------------------------------------------------
			Do Case

				//Grava FK6 - Valores acessórios.
			Case SE5->E5_TIPODOC $ cGeraFK6
				cIdFk6 := FINFKSID('FK6', 'FK6_IDFK6')

				If lSE5GRVFK
					aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK6", aCamposFK6})
					If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
						aCamposFK6 := Aclone(aSE5GRVFK)
					EndIf
					Asize(aSE5GRVFK, 0)
					aSE5GRVFK := Nil
				EndIf

				RecLock("FK6", .T.)
				For nX := 1 To Len(aCamposFK6)

					nPos := SE5->(FieldPos(aCamposFK6[nX][2]) )
					If nPos > 0
						FieldPut(FK6->(FieldPos(aCamposFK6[nX][1])),SE5->(FieldGet(nPos)))
					EndIf

				Next nX

				cTpDesc := IIF(FK6->FK6_TPDESC == "C","1","2")

				FK6->FK6_FILIAL := SE5->E5_FILIAL
				FK6->FK6_IDFK6	:= cIdFk6
				FK6->FK6_IDORIG := cIdOrig
				FK6->FK6_TABORI := 'FK1'
				FK6->FK6_TPDESC := cTpDesc
				FK6->(MsUnlock())
				cTabOri := "FK1"
				cIdFk6 := "" //Limpa o ID gerado

				// FK5 - Grava valores na tabela de movimentação bancaria.
			Case FINVerMov(SE5->E5_TIPODOC) .AND. (MovBcobx(SE5->E5_MOTBX , .F.) .OR. lFina087)//Só gera FK5 se o motivo de baixa atualiza banco

				cIdOrigFK5 := FWUUIDV4()
				If Empty(cProc)
					If Empty(cProc := FINProcFKs(SE5->E5_IDORIG, "FK1" ))
						cProc := FINFKSID('FKA','FKA_IDPROC')
					EndIf
				EndIf

				cBanco		:= SE5->E5_BANCO
				cAgencia 	:= SE5->E5_AGENCIA
				cConta 	    := SE5->E5_CONTA


				RecLock("FKA", .T.)
				FKA_FILIAL 	    := SE5->E5_FILIAL
				FKA_IDFKA		:= FWUUIDV4()
				FKA_IDPROC		:= cProc
				FKA_IDORIG		:= cIdOrigFK5
				FKA_TABORI		:= "FK5"
				FKA->(MsUnlock())

				If lSE5GRVFK
					aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK5", aCamposFK5})
					If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
						aCamposFK5 := Aclone(aSE5GRVFK)
					EndIf
					Asize(aSE5GRVFK, 0)
					aSE5GRVFK := Nil
				EndIf

				RecLock("FK5", .T.)

				For nX := 1 To Len(aCamposFK5)

					nPos := SE5->(FieldPos(aCamposFK5[nX][2]) )
					If nPos > 0
						FieldPut(FK5->(FieldPos(aCamposFK5[nX][1])), SE5->(FieldGet(nPos) ) )

						If aCamposFK5[nX][2] == "E5_MOEDA" .AND. Empty(SE5->(FieldGet(nPos)))
							If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
								FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), StrZero(SA6->A6_MOEDA,2) )
							Else
								FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), "01" )
							EndIf
						EndIf
						If aCamposFK5[nX][2] == "E5_NATUREZ" .AND. Empty(SE5->(FieldGet(nPos)))
							cNatureza := FINNATMOV("R")
							FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), cNatureza )
						EndIf
					EndIf

				Next nX

				FK5->FK5_FILIAL	:= SE5->E5_FILIAL
				FK5->FK5_IDMOV 	:= cIdOrigFK5
				FK5->FK5_ORIGEM	:= If(Empty(FK5->FK5_ORIGEM),"FINXSE5",FK5->FK5_ORIGEM)

				If FK5->FK5_TPDOC == 'RA' .And. !Empty(SE5->E5_NUMERO)
					cChave := xFilial("SE1", SE5->E5_FILORIG) + "|" +  SE5->E5_PREFIXO + "|" + SE5->E5_NUMERO + "|" + SE5->E5_PARCELA + "|" + SE5->E5_TIPO + "|" +;
					SE5->E5_CLIFOR + "|" + SE5->E5_LOJA

					FK5->FK5_IDDOC := FINGRVFK7('SE1', cChave)
				EndIf

				FK5->(MsUnlock())
				cTabOri := If(cTabOri == "FK1", cTabOri, "FK5")
				cIdOrig := If(cTabOri == "FK1",cIdOrig, cIdOrigFK5)
			EndCase

			//Atualiza o campo E5_MOVFKS = 'S' -> Campo de controle do migrador.
			Reclock("SE5", .F.)
			E5_MOVFKS := "S"
			E5_IDORIG := cIdOrig
			E5_TABORI := cTabOri
			SE5->(MsUnlock())
		Next
		//-------------------------------------------------------------
		(cAliasSE1)->(dbSkip())
	Enddo
	(cAliasSE1)->(DBCloseArea())
	FErase(cAliasSE1 + GetDBExtension())

	//Reposiciona na SE5
	If nPosSE5 > 0
		SE5->(dbGoTo(nPosSE5))
	EndIf
	cFilAnt := cFilBkp
Return

/*/{Protheus.doc} FnBuscaEF
Filtra os dados baixados da SEF - cheques.
@author William Matos Gundim Junior
@since 10/04/2014
@version P12
/*/
Function FnBuscaEF(nPosSE5)
	Local nX 			:= 0
	Local cQuery 		:= ''
	Local cIdOrig 	    := ''
	Local cAliasSEF 	:= GetNextAlias()
	Local cProc		    := ''
	Local cFilBkp 	    := cFilAnt
	Local cBanco 		:= ""
	Local cAgencia	    := ""
	Local cConta 		:= ""
	Local cNatureza	    := ""
	Local cCart		    := ""

	Default nPosSE5 := 0 // Variavel com posição da SE5 que deve ser atualizado.

	//Cheque.
	cQuery := "SELECT SE5.R_E_C_N_O_ RECNO, SEF.R_E_C_N_O_ RECSEF "	+	CRLF
	cQuery += " FROM " +	RetSQLTab('SE5')			+	CRLF
	cQuery += "	JOIN " + RetSQLTab('SEF')			+	CRLF
	cQuery += " ON   SE5.E5_FILIAL  	= SEF.EF_FILIAL		AND " + CRLF
	cQuery += "      SE5.E5_PREFIXO  = SEF.EF_PREFIXO		AND " + CRLF
	cQuery += "      SE5.E5_NUMERO 		= SEF.EF_TITULO 		AND " + CRLF
	cQuery += "      SE5.E5_PARCELA  = SEF.EF_PARCELA  AND "		+ CRLF
	cQuery += "      SE5.E5_NUMCHEQ		= SEF.EF_NUM	AND	"			+ CRLF
	cQuery += " 	   SE5.E5_DATA   >= SEF.EF_DATA 		 " + CRLF

	cQuery += " WHERE " 				 			 					+ CRLF

	If nPosSE5 > 0
		cQuery += "      SE5.E5_PREFIXO  = '" + SE5->E5_PREFIXO + "' AND " + CRLF
		cQuery += "      SE5.E5_NUMERO 		= '" + SE5->E5_NUMERO  + "' AND " + CRLF
		cQuery += "      SE5.E5_PARCELA  = '" + SE5->E5_PARCELA + "' AND " + CRLF
		cQuery += "      SE5.E5_NUMCHEQ		= '" + SE5->E5_NUMCHEQ + "' AND " + CRLF
		cQuery += "      SE5.E5_BANCO		= '" + SE5->E5_BANCO + "' AND " + CRLF
		cQuery += "      SE5.E5_AGENCIA		= '" + SE5->E5_AGENCIA + "' AND " + CRLF
		cQuery += "      SE5.E5_CONTA		= '" + SE5->E5_CONTA + "' AND " + CRLF
		cQuery += " SE5.E5_TIPODOC = 'CH' AND "
	Else
		cQuery += " E5_DATA >= '" + DTOS(MV_PAR01) + "' AND " 		+ CRLF
		cQuery += " E5_DATA <= '" + DTOS(MV_PAR02) + "' AND " 		+ CRLF
		cQuery += "	E5_SITUACA NOT IN ('C','E','X') 			AND "	  	+ CRLF
		cQuery += " E5_MOVFKS  <> 'S' AND " + CRLF
		cQuery += " E5_TIPODOC = 'CH' AND " + CRLF
		cQuery += " E5_NUMCHEQ <> ''  AND " + CRLF
		cQuery += " SE5.E5_SEQ	  = SEF.EF_SEQUENC AND " + CRLF
	EndIf
	cQuery += " SEF.D_E_L_E_T_ = ' ' AND " 	+ CRLF
	cQuery += " SE5.D_E_L_E_T_ = ' ' " 	+ CRLF
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSEF,.T.,.T.)
	dbSelectArea(cAliasSEF)

	DbGotop()
	dbSelectArea('SEF')
	dbSelectArea('SE5')
	dbSelectArea('SA6')
	dbSelectArea('FKA')
	SA6-> (DbSetOrder(1))
	FKA-> (DbSetOrder(3))//FKA_FILIAL+FKA_TABORI+FKA_IDORIG
	While !(cAliasSEF)->(Eof())

		SE5->(dbGoTo(	(cAliasSEF)->RECNO))

		If lFilExclus
			cFilAnt := SE5->E5_FILIAL
		EndIf
		//tratamento para casos que houve a geracao e cancelamento do cheque e regerou novamente o mesmo numero
		If !Empty(SE5->E5_IDORIG)
			(cAliasSEF)->(DBSkip())
			Loop
		EndIf

		SEF->(dbGoTo(	(cAliasSEF)->RECSEF))
		If (FKA->(dbSeek(xFilial("FKA")+SEF->EF_IDSEF+"SEF")))
			(cAliasSEF)->(DBSkip())
			Loop
		EndIf

		If TemEstChq( (cAliasSEF)->RECNO  )
			(cAliasSEF)->(dbSkip())
			Loop
		EndIf
		cCart		:= SE5->E5_RECPAG
		cBanco		:= SE5->E5_BANCO
		cAgencia 	:= SE5->E5_AGENCIA
		cConta 	    := SE5->E5_CONTA
		//
		cIdOrig     := FWUUIDV4()
		cProc	    := FINFKSID('FKA','FKA_IDPROC')
		//
		RecLock("FKA", .T.)
		FKA_FILIAL  := SE5->E5_FILIAL
		FKA_IDFKA	:= FWUUIDV4()
		FKA_IDPROC	:= cProc
		FKA_IDORIG	:= cIdOrig
		FKA_TABORI	:= "FK5"
		FKA->(MsUnlock())

		If lSE5GRVFK
			aSE5GRVFK := ExecBlock("SE5GRVFK",.F.,.F.,{"FK5", aCamposFK5})
			If ValType(aSE5GRVFK) == "A" .and. !Empty(aSE5GRVFK)
				aCamposFK5 := Aclone(aSE5GRVFK)
			EndIf
			Asize(aSE5GRVFK, 0)
			aSE5GRVFK := Nil
		EndIf

		RecLock("FK5", .T.)

		For nX := 1 To Len(aCamposFK5)

			nPos := SE5->(FieldPos(aCamposFK5[nX][2]) )
			If nPos > 0

				FieldPut(FK5->(FieldPos(aCamposFK5[nX][1])), SE5->(FieldGet(nPos) ) )
				If aCamposFK5[nX][2] == "E5_MOEDA" .AND. Empty(SE5->(FieldGet(nPos)))
					If SA6->(dbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
						FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), StrZero(SA6->A6_MOEDA,2) )
					Else
						FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), "01" )
					EndIf
				Endif
				If aCamposFK5[nX][2] == "E5_NATUREZ" .AND. Empty(SE5->(FieldGet(nPos)))
					cNatureza := FINNATMOV(cCart)
					FieldPut( FK5->(FieldPos(aCamposFK5[nX][1])), cNatureza )
				EndIf

			EndIf

		Next nX

		FK5->FK5_FILIAL := SE5->E5_FILIAL
		FK5->FK5_IDMOV 	:= cIdOrig
		FK5->FK5_ORIGEM := "FINXSE5"

		FK5->(MsUnlock())

		//Atualiza o campo E5_MOVFKS = 'S' -> Campo de controle do migrador.
		Reclock("SE5", .F.)
		E5_MOVFKS := "S"
		E5_IDORIG := cIdOrig
		E5_TABORI := "FK5"
		SE5->(MsUnlock())

		cIdOrig := FWUUIDV4()

		RecLock("FKA", .T.)
		FKA_FILIAL := SE5->E5_FILIAL
		FKA_IDFKA  := FWUUIDV4()
		FKA_IDPROC := cProc
		FKA_IDORIG := cIdOrig
		FKA_TABORI := "SEF"
		FKA->(MsUnlock())
		//Atualiza SEF.
		RecLock("SEF", .F.)
		EF_IDSEF   := cIdOrig
		SEF->(MsUnlock())

		(cAliasSEF)->(dbSkip())
	End//Do
	(cAliasSEF)->(DBCloseArea())
	FErase(cAliasSEF + GetDBExtension())
	cFilAnt := cFilBkp
Return

/*/{Protheus.doc} FINBuscaFK7
Realiza busca na FK7 pela chave gerada FK1/FK2.
@author William Matos Gundim Junior
@since 10/04/2014
@version P12
/*/
Function FINBuscaFK7(cChave As Char, cAliasSEs As Char, cFilOriTit As Char)
	Local cIdDoc     As Char
	Local cPesquisa  As Char
	Local aAreaAtual As Array

	Default cChave     := ""
	Default cAliasSEs  := ""
	Default cFilOriTit := ""

	//Inicializa variáveis.
	cIdDoc     := ""
	cPesquisa  := Iif(Empty(cFilOriTit), xFilial('FK7'), xFilial('FK7', cFilOriTit)) + (cAliasSEs+cChave)
	aAreaAtual := GetArea()

	//Realiza busca na FK7 - Rastreio SE1|SE2
	If ChkFile("FK7")
		DbSelectArea('FK7')
		FK7->(dbSetOrder(2)) //FK7_FILIAL + FK7_ALIAS + FK7_CHAVE

		If FK7->(DbSeek(cPesquisa))
			cIdDoc := FK7->FK7_IDDOC
		EndIf
	Endif

	RestArea(aAreaAtual)
	FwFreeArray(aAreaAtual)
Return cIdDoc

/*/{Protheus.doc}FinGrvFK6
Faz a gravação dos valores na SE5 com base na FK6.
@author William Matos Gundim Junior
@since  04/04/2014
@version 12
/*/
Function FinGrvFK6(cIdent AS CHARACTER, aAux AS ARRAY )
	Local aCamposFK1 	AS ARRAY
	Local aCamposFK2 	AS ARRAY
	Local aCamposFK5 	AS ARRAY
	Local aCamposFK6 	AS ARRAY
	Local aPosField		AS ARRAY
	Local cFilSE5		AS CHARACTER
	Local nX  			AS NUMERIC
	Local nY  			AS NUMERIC
	Local oFK1			AS OBJECT
	Local oFK2 			AS OBJECT
	Local oFK5			AS OBJECT
	Local oFK6			AS OBJECT
	Local oFKA			AS OBJECT
	Local oModel		AS OBJECT
	
    oModel      := FWModelActive()
	oFK6        := oModel:GetModel('FK6DETAIL')

	Default cIdent  := ''
	Default aAux    := {}

	__aRFK6SE5 := {}

	If !oFK6:IsEmpty() .And.;
        (oFK6:GetValue('FK6_VALMOV') != 0 .or. oFK6:GetValue('FK6_VALCAL') != 0)

        oFK1        := oModel:GetModel('FK1DETAIL')
        oFK2        := oModel:GetModel('FK2DETAIL')
        oFK5        := oModel:GetModel('FK5DETAIL')
        oFKA        := oModel:GetModel('FKADETAIL')
        aCamposFK1  := FK1->(DbStruct())
        aCamposFK2  := FK2->(DbStruct())
        aCamposFK5  := FK5->(DbStruct())
        aCamposFK6  := FK6->(DbStruct())
        cFilSE5     := FWxfilial("SE5")

        //Ajusto somente os campos chave da SE5 atraves do cCamposE5
        aPosField   := {}
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_TIPO'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_PREFIXO'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_NUMERO'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_PARCELA'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_CLIFOR'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_LOJA'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_BENEF'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DTDIGIT'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DTDISPO'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_CLIENTE'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DTDISPO'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_BANCO'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_AGENCIA'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_CONTA'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_FORNECE'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_LA'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_MOTBX'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_FATURA'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_FATPREF'}))
        aAdd(aPosField,aScan(aAux,{|x| x[1] == 'E5_DOCUMEN'}))

		For nX := 1 To oFK6:Length()
			oFK6:GoLine(nX)

			oFK6:SetValue("FK6_IDORIG",oFKA:GetValue('FKA_IDORIG'))
			oFK6:SetValue("FK6_IDFK6" ,FINFKSID('FK6', 'FK6_IDFK6') )

			If oFK6:GetValue('FK6_GRVSE5') .and. oFK6:GetValue('FK6_VALMOV') != 0  //Indica se grava SE5 para os valores acessorios
				RecLock("SE5",.T.)
				If !oFK5:IsEmpty() //Complementa a FK6 com valores da FK5.
					//Grava os dados na SE5 com base na FK5.
					FinGrvSE5(aCamposFK5,aDeParaFK5,oFK5)
				Else
					If cIdent == 'FK1'
						//Grava os dados na SE5 com base na FK1.
						FinGrvSE5(aCamposFK1,aDeParaFK1,oFK1)
					Else
						//Grava os dados na SE5 com base na FK2.
						FinGrvSE5(aCamposFK2,aDeParaFK2,oFK2)
					EndIf
				EndIf

				//Grava os dados na SE5 com base na FK6.
				FinGrvSE5(aCamposFK6,aDeParaFK6,oFK6,nX)

				E5_FILIAL := cFilSE5

				If cPaisLoc == "BRA"
					E5_TPDESC := If((Empty(oFK6:getvalue("FK6_TPDESC")) .Or. oFK6:getvalue("FK6_TPDESC") == "2"), "I", "C")
				Endif

				If cIdent == 'FK1'
					E5_TABORI := "FK1"
					E5_IDORIG := oFKA:GetValue('FKA_IDORIG')
					E5_DATA := oFK1:GetValue('FK1_DATA')
				ElseIf cIdent == 'FK2'
					E5_TABORI := "FK2"
					E5_IDORIG := oFKA:GetValue('FKA_IDORIG')
					E5_DATA := oFK2:GetValue('FK2_DATA')
				ElseIf cIdent == 'FK5'
					E5_TABORI := "FK5"
					E5_IDORIG := oFKA:GetValue('FKA_IDORIG')
					E5_DATA   := oFK5:GetValue('FK5_DATA')
				EndIf
				E5_MOVFKS := 'S'	// Campo de controle para migração dos dados.

				If cIdent == 'FK1'
					//Verifica Gravacao do Valor na Moeda2
					If oFK1:GetValue('FK1_VALOR') == oFK1:GetValue('FK1_VLMOE2') .AND. !Empty( oFK1:GetValue('FK1_VALOR') + oFK1:GetValue('FK1_VLMOE2') )
						E5_VLMOED2 := oFK6:GetValue('FK6_VALMOV')
					Else
						E5_VLMOED2 := ROUND(oFK6:GetValue('FK6_VALMOV') / oFK1:GetValue('FK1_TXMOED'),2)
					Endif
				ElseIf cIdent == 'FK2'
					If !oFK2:GetValue('FK2_VALOR') <> oFK2:GetValue('FK2_VLMOE2')
						E5_VLMOED2 := oFK6:GetValue('FK6_VALMOV')
					Elseif Val(Substr(oFK2:GetValue('FK2_MOEDA'),1,2)) > 1 .AND. oFK6:GetValue('FK6_TPDOC') $ "JR|DC|VA|MT"
						E5_VLMOED2 := ROUND(oFK6:GetValue('FK6_VALMOV') * oFK2:GetValue('FK2_TXMOED'),2)
					Else
						E5_VLMOED2 := ROUND(oFK6:GetValue('FK6_VALMOV') / oFK2:GetValue('FK2_TXMOED'),2)
					Endif
					// Exemplo: baixado somente desconto, valor do pagamento zerado
					If oFK2:GetValue('FK2_VALOR') == 0 .AND. oFK2:GetValue('FK2_VLMOE2') == 0
						If oFK2:GetValue('FK2_TXMOED') == 0 // Tit e banoo em moeda 1 grava Taxa 0, considerar o valor
							E5_VLMOED2 := oFK6:GetValue('FK6_VALMOV')
						Else
							E5_VLMOED2 := ROUND(oFK6:GetValue('FK6_VALMOV') / oFK2:GetValue('FK2_TXMOED'),2)
						EndIf
					EndIf
				Else
					E5_VLMOED2 := oFK6:GetValue('FK6_VALMOV')
				EndIf

				For nY := 1 to Len(aPosField)
					If aPosField[nY] > 0
						SE5->(FieldPut(FieldPos(aAux[aPosField[nY]][1]),aAux[aPosField[nY]][2]))
					EndIf
				Next nY

				//IOF de cobranca descontada - Grava Motivo de baixa especifico
				If cIdent == 'FK5' .and. SE5->E5_TIPODOC $ "I2|EI"
					E5_MOTBX := "IOF"
				Endif

				If AllTrim(SE5->E5_TIPODOC) == "CM"
					SE5->E5_MOEDA := "01"
				EndIf

				SE5->(MsUnlock())
				aAdd( __aRFK6SE5, SE5->( Recno() ) )
			Endif

		Next nX
	EndIf
	aCamposFK6 := NIL
	aCamposFK5 := NIL
	aCamposFK1 := NIL
	aCamposFK2 := NIL
    aPosField := NIL

Return


/*/{Protheus.doc}FinEstFK6
Faz a gravação dos ESTORNO da FK6.
@author Pequim
@since  05/05/2014
@version 12
/*/
Function FinEstFK6( cCart, aOldFK6 )
	Local oModel		:= FWModelActive()
	Local oSubFKA		:= oModel:GetModel('FKADETAIL')
	Local oSubFK6		:= oModel:GetModel('FK6DETAIL')
	Local aCamposFK6	:= FK6->(DbStruct())
	Local nX			:= 0
	Local nZ			:= 0
	Local nValEstIOF	:= 0
	Local cTpDoc		:= ""

	Default cCart		:= "P"
	Default aOldFK6	:= {}

	If oModel:GetId() == "FINM030"
		nValEstIOF := oModel:GetValue( "MASTER", "VALESTIOF" )
	EndIf

	If !Empty(aOldFK6)

		For nX := 1 To Len(aOldFK6)

			aAuxFK6 := aClone(aOldFK6[nX])

			//Estorno de valores acessorios (cancelamento de baixa)
			If !oSubFK6:IsEmpty()
				oSubFK6:AddLine()
				oSubFK6:GoLine( oSubFK6:Length() )
			Endif

			For nZ := 1 To Len(aCamposFK6)
				oSubFK6:LoadValue(aCamposFK6[nZ][1],aAuxFK6[nZ])
			Next nZ

			cCart := oSubFK6:GetValue("FK6_RECPAG")

			oSubFK6:SetValue("FK6_IDORIG" ,oSubFKA:GetValue('FKA_IDORIG'))
			oSubFK6:SetValue("FK6_IDFK6"  ,FINFKSID('FK6', 'FK6_IDFK6'))
			oSubFK6:SetValue("FK6_RECPAG" ,If (cCart == "P", "R", "P") )

			//Tratamento para se caso seja informado um valor de estorno de IOF diferente do valor original (utilizado para cancelamento de borderô descontado que teve um título estornado para carteira)
			cTpDoc := oSubFK6:GetValue("FK6_TPDOC")
			If nValEstIOF > 0 .And. cTpDoc == "I2"
				oSubFK6:SetValue( "FK6_VALCAL", nValEstIOF )
				oSubFK6:SetValue( "FK6_VALMOV", nValEstIOF )
				oSubFK6:SetValue( "FK6_TPDOC", "EI" )
				oSubFK6:SetValue( "FK6_HISTOR", STR0011 ) //"Cancelamento de cob de IOF"
			Endif

		Next nX
	EndIf

Return

/*/{Protheus.doc}FinEstFK34
Faz a gravação estorno dos valores de impostos
FK3 - Impostos calculados
FK4 - Impostos retidos
@author Mauricio Pequim Jr
@since  04/05/2014
@version 12
/*/
Function FinEstFK34()
	Local oModel	:= FWModelActive()
	Local oSubFK3	:= oModel:GetModel('FK3DETAIL')
	Local oSubFK4	:= oModel:GetModel('FK4DETAIL')
	Local nX		:= 0
	Local aArea		:= GetArea()
	Local cAllIdRet := ""
	Local cQuery	:= ""
	Local cAliasQry := ""

	If !oSubFK3:IsEmpty()
		//Obtenho todos os IDs de retencao para limpar na FK3
		For nX := 1 to oSubFK3:Length()
			oSubFK3:GoLine(nX)

			If nX == oSubFK3:Length()
				cAllIdRet += oSubFK3:GetValue("FK3_IDRET")
			Else
				cAllIdRet += oSubFK3:GetValue("FK3_IDRET") +"|"
			EndIf
		Next
	Endif

	If !oSubFK4:IsEmpty() .and. !Empty(cAllIdRet)

		cAliasQry := GetNextAlias()


		cQuery 	:= " SELECT R_E_C_N_O_ RECNOFK3 FROM "+RetSqlName("FK3")+" WHERE "
		cQuery  += " FK3_FILIAL = '" + xFilial("FK3") + "' AND "
		cQuery 	+= " FK3_IDRET IN " + FormatIn(cAllIdRet,"|") + " AND "
		cQuery 	+= " D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

		(cAliasQry)->(dbGoTop())
		While !( cAliasQRY )->( Eof())
			dbSelectArea("FK3")
			FK3->(dbGoTo(( cAliasQRY )->RECNOFK3 ) )
			RecLock("FK3")
			FK3->FK3_IDRET := ""
			MsUnlock()
			(cAliasQry)->(dbSkip())
		Enddo
		(cAliasQry)->(dbCloseArea())
	Endif

	RestArea(aArea)

Return


/*/{Protheus.doc}FGrvEstFks
Faz a gravação estorno dos valores de impostos
FK3 - Impostos calculados
FK4 - Impostos retidos
@author Totvs
@since  10/01/2015
@version 12
/*/
Function FGrvEstFks(aOldFK3, aOldFK4, lIsPA)

	Local nX  			:= 0
	Local nZ  			:= 0
	Local cCart			:= ""
	Local oModel		:= FWModelActive()
	Local oSubFK3		:= oModel:GetModel('FK3DETAIL')
	Local oSubFK4		:= oModel:GetModel('FK4DETAIL')
	Local oSubFKA		:= oModel:GetModel('FKADETAIL')
	Local aCamposFK3 	:= FK3->(DbStruct())
	Local aCamposFK4 	:= FK4->(DbStruct())
	Local aFK0			:= {}
	Local aAreaAtu		:= {}

	Default aOldFK3	:= {}
	Default aOldFK4	:= {}
	Default lIsPA	:= .F.

	If !Empty(aOldFK3)

		For nX := 1 To Len(aOldFK3)

			If lIsPA .and. !Empty(aOldFK3[nX,21])	//Codigo Imposto Configurador de Tributos
				Aadd(aFK0, aOldFK3[nX,1] + aOldFK3[nX,14] + aOldFK3[nX,21] )	//FK3_FILIAL, FK3_IDORIG, FK3_CODFKM
			Endif

			aAuxFK3 := aClone(aOldFK3[nX])

			//Estorno de valores acessorios (cancelamento de baixa)
			If !oSubFK3:IsEmpty()
				oSubFK3:AddLine()
				oSubFK3:GoLine( oSubFK3:Length() )
			Endif

			For nZ := 1 To Len(aCamposFK3)
				oSubFK3:LoadValue(aCamposFK3[nZ][1],aAuxFK3[nZ])
			Next nZ

			cCart := oSubFK3:GetValue("FK3_RECPAG")

			oSubFK3:SetValue("FK3_IDORIG" ,oSubFKA:GetValue('FKA_IDORIG'))
			oSubFK3:SetValue("FK3_IDFK3"  ,FINFKSID('FK3', 'FK3_IDFK3'))
			oSubFK3:SetValue("FK3_RECPAG" ,If (cCart == "P", "R", "P") )
			oSubFK3:SetValue("FK3_STATUS" ,"2" )
			oSubFK3:SetValue("FK3_IDRET"  ," " )

		Next nX
	EndIf
	If !Empty(aOldFK4)

		For nX := 1 To Len(aOldFK4)

			aAuxFK4 := aClone(aOldFK4[nX])

			//Estorno de valores acessorios (cancelamento de baixa)
			If !oSubFK4:IsEmpty()
				oSubFK4:AddLine()
				oSubFK4:GoLine( oSubFK4:Length() )
			Endif

			For nZ := 1 To Len(aCamposFK4)
				oSubFK4:LoadValue(aCamposFK4[nZ][1],aAuxFK4[nZ])
			Next nZ

			cCart := oSubFK4:GetValue("FK4_RECPAG")

			oSubFK4:SetValue("FK4_IDORIG" ,oSubFKA:GetValue('FKA_IDORIG'))
			oSubFK4:SetValue("FK4_IDFK4"  ,FINFKSID('FK4', 'FK4_IDFK4'))
			oSubFK4:SetValue("FK4_RECPAG" ,If (cCart == "P", "R", "P") )
			oSubFK4:SetValue("FK4_STATUS" ,"2" )
		Next nX
	EndIf

	//Deleto registros referente a tabela FK0
	If (nLenFK0 := Len(aFK0)) > 0
		aAreaAtu := GetArea()

		FK0->(dbSetOrder(4))
		For nZ := 1 to nLenFK0
			If FK0->(MsSeek(aFK0[nZ,1]))
				RecLock("FK0")
				dbDelete()
				FK0->(MsUnlock())
			Endif
		Next nZ

		RestArea(aAreaAtu)
		FwFreeArray(aAreaAtu)
		FwFreeArray(aFK0)
	Endif

Return


/*/{Protheus.doc}FXBuscaIRF
Busca na FK3 pelo imposto IRF.
@author William Matos G Junior.
@since  04/09/2014
@version 12
/*/
Function FXBuscaIRF( oModel )
	Local lRet		:= .F.
	Local oFKA		:= oModel:GetModel('FKADETAIL')
	Local oFK1		:= oModel:GetModel('FK1DETAIL')
	Local oFK3 	:= oModel:GetModel('FK3DETAIL')
	Local nX		:= 1
	Local nLine	:= oFKA:GetLine()

	While nX <= oFKA:Length() .AND. !lRet

		oFKA:SetLine(nX)
		If !oFK1:IsEmpty()
			lRet := oFK3:SeekLine( { {"FK3_IMPOS", "IRF" } } )
		EndIf
		nX ++

	EndDo

	oFKA:SetLine(nLine)
Return lRet

/*/{Protheus.doc} FK6SE5
Função que retorna os Recnos de SE5 gravados a partir da FK6.
@author Pedro Alencar
@since  06/09/2014
@version P12
/*/
Function FK6SE5Recs()
Return aClone(__aRFK6SE5)


/*/{Protheus.doc} DesFK6Recs
Função para zerar o array de Recnos de SE5 gravados a partir da FK6.
@author Rodrigo Oliveira
@since  02/08/2016
@version P12
/*/
Function DesFK6Recs()

	__aRFK6SE5 := {}

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FINCARVAR
Função para carregar as variáveis de contabilização.
@author TOTVS
@since  18/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function FINCARVAR()

	Local nPos as Numeric
	Local aArea 	:= GetArea()
	Local aAreaSE5	:= SE5->(GetArea())
	Local cKeyFK3	:= ''
	Local cKeyFK4	:= ''
	Local cIMPOS	:= ''
	Local nRecOrig	:=0

	nPos := 0

	PIS		:= 0
	COFINS	:= 0
	CSLL	:= 0
	IRF		:= 0
	ISS		:= 0
	INSS	:= 0
	JUROS1	:= 0
	JUROS2	:= 0
	JUROS3	:= 0
	MULTA1	:= 0
	MULTA2	:= 0
	DESC1	:= 0
	DESC2	:= 0
	CMONET1	:= 0
	CMONET2	:= 0

	// Valores Acessorios - Necessario limpar estas PRIVATEs a cada chamada FINCARVAR()
	// Elas são criadas ou atualizadas na chamada da FSetVA2CTB() abaixo
	For nPos := 1 To LEN(__aVaToCTB)
		&(__aVaToCTB[nPos][1]) := 0
	Next nPos

	// Verifica se há registro de origem no processo de compensação do Contas a Receber (Ctbafin)
	If __lTemCmp
		If ( nRecOrig:=CtbLP596Cr() ) > 0
			SE5->(dbGoTo(nRecOrig))
		EndIF
	EndIf

	If !Empty(SE5->E5_IDORIG)

		If SE5->E5_TABORI == "FK1"
			dbSelectArea( "FK1" )	//Baixas a receber
			FK1->(dbSetOrder(1))	//FK1_FILIAL, FK1_IDFK1, R_E_C_N_O_, D_E_L_E_T_
			FK1->(MSSEEK(xFilial("FK1")+ SE5->E5_IDORIG))
		ElseIf SE5->E5_TABORI == "FK2"
			dbSelectArea( "FK2" )	//Baixas a pagar
			FK2->(dbSetOrder(1))	//FK2_FILIAL, FK2_IDFK2, R_E_C_N_O_, D_E_L_E_T_
			FK2->(MSSEEK(xFilial("FK2")+ SE5->E5_IDORIG))
		Else
			dbSelectArea( "FK5" )	//Movimentos bancários
			FK5->(dbSetOrder(1))	//FK5_FILIAL, FK5_IDMOV, R_E_C_N_O_, D_E_L_E_T_
			FK5->(MSSEEK(xFilial("FK5")+ SE5->E5_IDORIG))
		Endif

		FK3->(dbSetOrder(2))		//FK3_FILIAL, FK3_TABORI, FK3_IDORIG, FK3_IMPOS, R_E_C_N_O_, D_E_L_E_T_
		FK4->(dbSetOrder(1))
		cKeyFK3 := xFilial("FK3",SE5->E5_FILORIG) + SE5->(E5_TABORI + E5_IDORIG)
		FK3->(MSSEEK(cKeyFK3))

		While !FK3->(EOF()) .AND. cKeyFK3 == FK3->(FK3_FILIAL + FK3_TABORI + FK3_IDORIG)
			cKeyFK4 := (xFilial("FK4",FK3->FK3_FILORI) + FK3->FK3_IDRET)
			FK4->(MSSEEK(cKeyFK4))

			While !FK4->(EOF()) .AND. cKeyFK4 == FK4->(FK4_FILIAL + FK4_IDFK4)
				cIMPOS := Alltrim(FK4->FK4_IMPOS)

				If _lTemMR .And. !Empty(FK4->FK4_CODFKM)
					FSetMt2CTB(FK4->FK4_CODFKM, FK4->FK4_VALOR)
				Else
					Do Case
						Case cIMPOS	== "PIS"
							PIS := FK4->FK4_VALOR
						Case cIMPOS	== "COF"
							COFINS := FK4->FK4_VALOR
						Case cIMPOS	== "CSL"
							CSLL := FK4->FK4_VALOR
						Case cIMPOS	== "IRF"
							IRF := FK4->FK4_VALOR
						Case cIMPOS	== "ISS"
							ISS := FK4->FK4_VALOR
						Case cIMPOS	== "INS"
							INSS := FK4->FK4_VALOR
					Endcase
				EndIf
				FK4->(DBSkip())
			EndDo
			FK3->(DbSkip())
		EndDo

		dbSelectArea('FK6')		//Valores acessórios
		FK6->(dbSetOrder(2))	//FK6_FILIAL, FK6_IDORIG, FK6_TABORI, FK6_IDFK6, R_E_C_N_O_, D_E_L_E_T_
		cKeyFK := (xFilial("FK6",SE5->E5_FILORIG) + SE5->E5_IDORIG)
		FK6->(MSSEEK(cKeyFK))

		While !FK6->(EOF()) .AND. cKeyFK == FK6->(FK6_FILIAL + FK6_IDORIG)
			Do Case
				Case FK6->FK6_TPDOC == "JR"
					JUROS1:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "J2"
					JUROS2:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "MT"
					MULTA1:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "M2"
					MULTA2:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "DC"
					DESC1:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "D2"
					DESC2:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "CM"
					CMONET1:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "C2"
					CMONET2:= FK6->FK6_VALMOV
				Case FK6->FK6_TPDOC == "VA"
					FSetVA2CTB(FK6->FK6_CODVAL,FK6->FK6_VALMOV)
			Endcase
			FK6->(DBSkip())
		EndDo

	EndIf

	RestArea(aAreaSE5)
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FINVARCTB
Função para declarar as variáveis de contabilização.
@author TOTVS
@since  18/12/2014
@version P12
/*/
//-------------------------------------------------------------------
Function FINVARCTB()
	Local cFunc 	AS CHARACTER
	Local cAliasFKK AS CHARACTER 
	Local nX        AS NUMERIC
	Local cAlias    AS CHARACTER
	Local cQuery    AS CHARACTER
	Local aBind     AS ARRAY

	cFunc := FunName()

	cAlias := Alias()

	If _lInDicFKK == nil
		_lInDicFKK := TableInDic("FKK")
	EndIF

	//Tratamento para não dar problema com o FunName em caso de chamadas por Mensagem Única
	If (AllTrim( Upper( cFunc ) ) == "RPC" .OR. IsInCallStack( "INTEGDEF" ) ) .AND. IsInCallStack( "HeadProva" ) //Se não tem função definida (chamada de job / Mensagem Única, por exemplo) e a função estiver sendo chamada da HeadProva
		cFunc := ProcName( 2 ) //Pega o nome da rotina que chamou o HeadProva (nível 2 da pilha de chamadas / ProcName: 0 = FINVARCTB, 1 = HeadProva, 2 = Rotina que chamou HeadProva ).
		If cFunc == "A370CABECALHO" // Tratamento Contabilização Off (FINA370 descontinuado)
			cFunc := ProcName( 3 )
		EndIf
		If cFunc == "MULTNATC"
			cFunc := ProcName( 3 ) // FA070TIT
		EndIf
	Endif

	If ! Empty( cFunc ) .AND. IsInCallStack( cFunc )
		_SetNamedPrvt( "PIS"    , 0, cFunc )
		_SetNamedPrvt( "COFINS" , 0, cFunc )
		_SetNamedPrvt( "CSLL"   , 0, cFunc )
		_SetNamedPrvt( "IRF"    , 0, cFunc )
		_SetNamedPrvt( "ISS"    , 0, cFunc )
		_SetNamedPrvt( "INSS"   , 0, cFunc )
		_SetNamedPrvt( "JUROS1" , 0, cFunc )
		_SetNamedPrvt( "JUROS2" , 0, cFunc )
		_SetNamedPrvt( "JUROS3" , 0, cFunc )
		_SetNamedPrvt( "MULTA1" , 0, cFunc )
		_SetNamedPrvt( "MULTA2" , 0, cFunc )
		_SetNamedPrvt( "DESC1"  , 0, cFunc )
		_SetNamedPrvt( "DESC2"  , 0, cFunc )
		_SetNamedPrvt( "CMONET1", 0, cFunc )
		_SetNamedPrvt( "CMONET2", 0, cFunc )

		If FInDicTVA()
			If _aCmpFKC == nil
				cQuery := "SELECT DISTINCT FKC_VARCTB FROM "
				cQuery += RetSqlName("FKC")
				cQuery += " WHERE D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				MPSysOpenQuery(cQuery, '_QFKC')

				_aCmpFKC := {}
				While _QFKC->(!EOF())
					AADD(_aCmpFKC,Alltrim(_QFKC->FKC_VARCTB))
					_QFKC->(DBsKIP())
				EndDo
				_QFKC->(dbCloseArea())
				If !Empty(cAlias)
					DbSelectArea(cAlias)
				EndIf
			EndIF

			For nX := 1 to Len(_aCmpFKC)
				_SetNamedPrvt( _aCmpFKC[nX], 0, cFunc )
			Next nX
		Endif

		//Instância as variáveis dos tipos de retenção do motor
		If _lTemMR .And. _lInDicFKK
			If __cQryFKK == nil 
				__cQryFKK := "SELECT FKK_VARCTB FROM "
				__cQryFKK += RetSqlName("FKK")+" FKK "
				__cQryFKK += " WHERE FKK.FKK_FILIAL = ?"
				__cQryFKK += " AND FKK.FKK_ATIVO    = ?"
				__cQryFKK += " AND FKK.FKK_VIGINI  <= ? "
				__cQryFKK += " AND FKK.FKK_VIGFIM  >= ? "
				__cQryFKK += " AND FKK.FKK_VARCTB  <> ? "
				__cQryFKK += " AND FKK.D_E_L_E_T_   = ? "
				__cQryFKK += " GROUP BY FKK_VARCTB"
				__cQryFKK := ChangeQuery(__cQryFKK)
			EndIf 
			cAliasFKK := GetNextAlias()
			aBind := {}
			AADD(aBind,xFilial("FKK"))
			AADD(aBind,'1')
			AADD(aBind,dTos(dDataBase))
			AADD(aBind,dTos(dDataBase))
			AADD(aBind,Space(Len(FKK->FKK_VARCTB)))
			AADD(aBind,Space(1))
			
			dbUseArea(.T.,"TOPCONN",TcGenQry2(,,__cQryFKK, aBind),cAliasFKK,.T.,.T.)


			While (cAliasFKK)->(!Eof())
				_SetNamedPrvt(Alltrim(FKK->FKK_VARCTB), 0, cFunc)
				(cAliasFKK)->(dbSkip())
			EndDo
			(cAliasFKK)->(dbCloseArea())
		Endif
	Endif
	If !Empty(cAlias) 
		dbSelectArea(cAlias)
	EndIf 
Return

/*/{Protheus.doc} FINFKSID
Função para definir o ID usando GETSX8NUM
@author TOTVS
@since  09/02/2015
@version P12
/*/
Function FINFKSID(cAliasFks, cCampoFks, nIndex)
	Local cIdFks	:= ""
	Local aArea	:= GetArea()

	Default nIndex := 1 // Indice de ordenacao do cCampoFks

	DbSelectArea(cAliasFks)
	If cAliasFks == "FKA"
		nIndex := 2
		DbSetOrder(nIndex)//FKA_FILIAL+FKA_IDPROC+FKA_IDORIG+FKA_TABORI
	Else
		DbSetOrder(nIndex)
	EndIf

	While .T.
		cIdFks := GetSXENum(cAliasFks, cCampoFks,,nIndex)
		If !(DbSeek(xFilial(cAliasFks)+cIdFks))
			ConfirmSx8()
			Exit
		EndIf
	EndDo

	RestArea(aArea)

Return cIdFks

//Função que verifica se houve estorno do cheque,
//pois quando cancela o cheque e gera novamente N vezes, fica com a mesma chave
//não possibilitando a busca de qual foi a ultima geração ou estorno
Static Function TemEstChq(nRecnoSE5)
	Local cQuery
	Local lEstorno := .F.
	Local cAliasSE5 := GetNextAlias()

	Default nRecnoSE5 := 0

	DbSelectArea("SE5")
	SE5->(DBGoto(nREcnoSE5))

	cQuery := "SELECT SE5.R_E_C_N_O_  FROM " + RetSqlName("SE5") + " SE5"
	cQuery += " WHERE SE5.E5_FILIAL = '" + SE5->E5_FILIAL  + "' "
	cQuery += " AND SE5.E5_BANCO = '"    + SE5->E5_BANCO   + "' "
	cQuery += " AND SE5.E5_AGENCIA = '"  + SE5->E5_AGENCIA + "' "
	cQuery += " AND SE5.E5_CONTA = '"    + SE5->E5_CONTA   + "' "
	cQuery += " AND SE5.E5_NUMCHEQ = '"  + SE5->E5_NUMCHEQ + "' "
	cQuery += " AND SE5.E5_PREFIXO = '"  + SE5->E5_PREFIXO + "' "
	cQuery += " AND SE5.E5_NUMERO = '"   + SE5->E5_NUMERO  + "' "
	cQuery += " AND SE5.E5_PARCELA = '"  + SE5->E5_PARCELA + "' "
	cQuery += " AND SE5.E5_SEQ = '"      + SE5->E5_SEQ     + "' "
	cQuery += " AND SE5.R_E_C_N_O_ > "   + str(nREcnoSE5)
	cQuery += " AND SE5.E5_TIPODOC = 'ES' "
	cQuery += " AND SE5.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE5,.T.,.T.)

	If (cAliasSE5)->(!Eof())
		//se encontrou TIPODOC = ES é porque houve estorno de cheque
		lEstorno := .T.
	EndIF
	(cAliasSE5)->(DBCloseArea())

	FErase(cAliasSE5 + GetDBExtension())
Return lEstorno

//Função que realiza o estorno de registro da SE5 de estorno
//que ainda não houve migração
Static Function GeraEstFK5(cTipo)
	Local aAreaSE5 := GetArea()
	Local cQuery := ""
	Local cAliasTrb := GetNextAlias()
	Local cIdOrigBx := ""

	cQuery := "SELECT E5_IDORIG FROM " + RetSqlName("SE5")
	cQuery += " WHERE E5_FILIAL = '" + SE5->E5_FILIAL + "' AND "
	cQuery += "E5_PREFIXO='"+SE5->E5_PREFIXO+"' AND "
	cQuery += "E5_NUMERO='"+SE5->E5_NUMERO+"' AND "
	cQuery += "E5_PARCELA='"+SE5->E5_PARCELA+"' AND "
	cQuery += "E5_TIPO='"+SE5->E5_TIPO+"' AND "
	cQuery += "E5_CLIFOR='"+SE5->E5_CLIFOR+"' AND "
	cQuery += "E5_LOJA='"+SE5->E5_LOJA+"' AND "
	cQuery += "E5_SEQ='"+SE5->E5_SEQ+"' AND "
	cQuery += "E5_TIPODOC IN ('BA','VL', 'CP') AND "
	If cTipo == "R"
		cQuery += "E5_RECPAG = 'R' AND "
	Else
		cQuery += "E5_RECPAG = 'P' AND "
	EndIf
	cQuery += "D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTrb,.T.,.T.)
	If (cAliasTrb)->(!Eof())
		cIdOrigBx := (cAliasTrb)->E5_IDORIG
	EndIf

	(cAliasTrb)->(DbCloseArea())

	RestArea(aAreaSE5)

Return cIdOrigBx


/*/{Protheus.doc} FINNATMOV
Função gravar a natureza de movimento bancário, pagar ou receber
@author Pâmela Bernardo
@since  19/11/2015
@version P12
/*/
Function FINNATMOV(cCart)

	Local cNatureza := ""
	Local aArea		:= GetArea()
	Local nTamNat	:= TamSx3("E1_NATUREZ")[1]

	Default cCart 	:= "P"

	DbSelectArea("SED")
	DbSetOrder(1)

	If cCart == "P"
		cNatureza := Pad(SuperGetMV("MV_NATMOVP",,"NATMOVP"),nTamNat)
	Else
		cNatureza := Pad(SuperGetMV("MV_NATMOVR",,"NATMOVR"),nTamNat)
	Endif
	If ( ! DbSeek( xFilial("SED") + cNatureza ) )
		RecLock("SED",.T.)
		SED->ED_FILIAL  	:= xFilial("SED")
		SED->ED_CODIGO  	:= cNatureza
		SED->ED_CALCIRF 	:= "N"
		SED->ED_CALCISS 	:= "N"
		SED->ED_CALCINS 	:= "N"
		SED->ED_CALCCSL 	:= "N"
		SED->ED_CALCCOF 	:= "N"
		SED->ED_CALCPIS 	:= "N"
		SED->ED_DESCRIC 	:= If (cCart == "P", STR0009,STR0010 )
		SED->ED_TIPO		:= "2"
		SED->ED_MOVBCO	:= "1"
		SED->ED_COND 		:= If (cCart == "P", "D","R" )
		MsUnlock()
	EndIf

	RestArea(aArea)

Return cNatureza

/*/{Protheus.doc} FINNATFKS
Função gravar a natureza no contas a receber
@author Simone Kakinoana
@since  09/02/2018
@version P12
/*/
Function FINNATFKS()

	Local cNatureza 	:= ""
	Local aArea		:=GetArea()
	Local nTamNat	:= TamSx3("E1_NATUREZ")[1]

	DbSelectArea("SED")
	DbSetOrder(1)

	cNatureza := Pad(SuperGetMV("MV_NATFKS",,"NAT_FK"),nTamNat)

	If ( ! DbSeek( xFilial("SED") + cNatureza ) )
		RecLock("SED",.T.)
		SED->ED_FILIAL  	:= xFilial("SED")
		SED->ED_CODIGO  	:= cNatureza
		SED->ED_CALCIRF 	:= "N"
		SED->ED_CALCISS 	:= "N"
		SED->ED_CALCINS 	:= "N"
		SED->ED_CALCCSL 	:= "N"
		SED->ED_CALCCOF 	:= "N"
		SED->ED_CALCPIS 	:= "N"
		SED->ED_DESCRIC 	:= STR0012	//"Natureza FKS"
		SED->ED_TIPO		:= "2"
		SED->ED_MOVBCO		:= "1"
		SED->ED_COND 		:= "R"
		MsUnlock()
	EndIf

	RestArea(aArea)

Return cNatureza

//------------------------------------------------------------------------------
/*/{Protheus.doc} FSetVA2CTB
Função para carregar os valores acessórios nas variáveis de contabilização
relacionadas

@author Pequim
@since  04/09/2015
@version P12
/*/
//------------------------------------------------------------------------------
Function FSetVA2CTB(cCodVA AS Character,nValVA AS Numeric)
	Local nPos AS Numeric
	DEFAULT cCodVA := ""
	DEFAULT nValVa := 0

	nPos := 0

	If FInDicTVA()

		If !Empty(cCodVA)
			FKC->(dbSetOrder(1))
			If FKC->(MsSeek(xFilial("FKC")+cCodVA))

				// Valores Acessorios - Guarda as PRIVATEs criadas para zerar
				// toda vez que a FINCARVAR() for chamada.
				If (nPos := ASCAN(__aVaToCTB,{|e| e[1]==FKC->FKC_VARCTB})) == 0
					AADD(__aVaToCTB,{FKC->FKC_VARCTB,nValVa})
				Else
					__aVaToCTB[nPos][2] := nValVa
				EndIF

				&(Alltrim(FKC->FKC_VARCTB)) := ABS(nValVa)
			Endif
		Endif

	Endif

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}FinFK7Key
Processa e retorna a chave do título gravada na tabela FK7

@param cKeyOrig, Chave original gravada na tabela FK7 para processamento
@param cIdDoc, IdDoc da tabela FK7. Caso seja passado posicionará a tabela FK7 para obter a chave (FK7_CHAVE)

@return cChave, Chave processada para utilizar em Seeks e demais posicionamentos de títulos

@author Pedro Pereira Lima
@since  09/09/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------------------------------------------------
Function FinFK7Key(cKeyOrig,cIdDoc)
	Local cChave	:= ''
	Local aQuebra	:= {}

	Default cKeyOrig	:= ''
	Default cIdDoc		:= ''

	If Empty(__aTamCpos)
		aAdd(__aTamCpos,TamSXG('033')[1])
		aAdd(__aTamCpos,               3)
		aAdd(__aTamCpos,TamSXG('018')[1])
		aAdd(__aTamCpos,TamSXG('011')[1])
		aAdd(__aTamCpos,               3)
		aAdd(__aTamCpos,TamSXG('001')[1])
		aAdd(__aTamCpos,TamSXG('002')[1])
	Endif

	If !Empty(cIdDoc)
		FK7->(DbSetOrder(1)) // Filial + IdDoc
		FK7->(DbSeek(xFilial('FK7')+cIdDoc))
		cKeyOrig := FK7->FK7_CHAVE
	EndIf

	//Transforma a linha em um array com todos os registros
	aQuebra := StrToKarr(cKeyOrig,'|')

	cChave := PadR(aQuebra[1],__aTamCpos[1]) // Filial
	cChave += PadR(aQuebra[2],__aTamCpos[2]) // Prefixo
	cChave += PadR(aQuebra[3],__aTamCpos[3]) // Numero
	cChave += PadR(aQuebra[4],__aTamCpos[4]) // Parcela
	cChave += PadR(aQuebra[5],__aTamCpos[5]) // Tipo
	cChave += PadR(aQuebra[6],__aTamCpos[6]) // Cliente
	cChave += PadR(aQuebra[7],__aTamCpos[7]) // Loja

Return cChave

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}FGrvCpoSE5
Grava os campos complementares do SE5

@param cVetAux, String contendo o vetor com valores atribuídos no bloco de campos do SE5 para gravação de
informações específicas.

@author Mauricio Pequim Jr
@since  23/10/2015
@version 12.1.7
/*/
//-------------------------------------------------------------------------------------------------------------
Function FGrvCpoSE5(cVetAux,aAux)

	Local cAspas	:= ""
	Local cLinha	:= ""
	Local cCel01	:= ""
	Local xCel02	:= ""
	Local nTamVet	:= 0
	Local nDivisor	:= 0
	Local nLenAux	:= 0
	Local nW		:= 0
	Local nPosCpo	:= 0

	Default cVetAux := ""
	Default aAux	:= {}

	//-------------------  ATENÇÃO -----------------------------
	// Tenha muito cuidado ao alterar essa função
	// Ela afeta toda a gravação dos Models da SE5/FKS
	//----------------------------------------------------------

	If !Empty(cVetAux)
		//Retiro as chaves iniciais e finais
		If cPaisLoc == "RUS"
			//parser below in next While can't be used
			//because it has troubles with double quotes
			aAux    := aClone(&(cVetAux))
			cVetAux := ""
		Else
			nTamVet := Len(cVetAux)-2
			cVetAux := Ltrim(SUBSTR(cVetAux,2,nTamVet))
		EndIf

		//Descubro se o delimitador de string é aspas duplas ou simples
		cAspas	:= IIF(At('"',cVetAux) > 0, '"',"'")

		//Transformo o texto em array. Não utilize STRTOKARR pois a virgula que separa as linhas do array também separa as colunas.
		While !Empty(cVetAux)
			//Acho o conteudo de uma linha do array
			cLinha := SubStr(cVetAux,At("{",cVetAux)+1)
			cLinha := SubStr(cLinha,1,At("}",cLinha)-1)

			//Obtenho a posição da virgula do array
			nDivisor := At(",",cLinha)

			//Obtenho o nome do campo
			cCel01 := Alltrim(Substr(cLinha,At(cAspas,cLinha)+1,nDivisor))
			cCel01 := Alltrim(Substr(cCel01,1,At(cAspas,cCel01)-1))

			//Obtenho o valor a ser gravado no campo
			xCel02 := Alltrim(Substr(cLinha,nDivisor+1,Len(cLinha)-1))
			IF Substr(xCel02,1,1) == cAspas
				xCel02 := Substr(xCel02,2,RAT(cAspas,xCel02)-2)
			Else
				xCel02 := &(xCel02)
			Endif

			AADD(aAux, {cCel01,xCel02})

			cVetAux := SubStr(cVetAux,At("}",cVetAux)+1)
			cVetAux := SubStr(cVetAux,At("{",cVetAux))

		Enddo
		If (nLenAux := Len(aAux)) > 0
			For nW := 1 to nLenAux
				nPosCpo := SE5->(FieldPos(aAux[nW][1]))
				If nPosCpo > 0
					SE5->(FieldPut(nPosCpo ,aAux[nW][2]))
				Endif
			Next nW
		Endif

	Endif

Return .T.

/*/{Protheus.doc} FINGRVFKD
Função Responsavel por efetuar a Gravação da tabela FKD
@type function
@author jose.aribeiro
@since 14/09/2016
@version 1.0
@param cChaveFK7, character, Chave de Busca da tabela FK7
@param aValorVa, array, Vetor contendo o Codigo do Valor Acessorio e o valor monetario
/*/
Function FINGRVFKD(cChaveFK7,aValorVa,lLiqui)

	Local nLaco := 0

	DEFAULT lLiqui := .F.

	If TableInDic('FKD')
		DbSelectArea("FKD")
		DbSetOrder(2)
		For nLaco := 1 To Len(aValorVA)
			If FKD->(DbSeek(xFilial("FKD")+cChaveFK7+ aValorVA[nLaco][1]))

				RecLock("FKD",.F.)
				If(Val(aValorVA[nLaco,2]) == 0)
					FKD->(DbDelete())
				Else
					FKD->FKD_VALOR  := Val(aValorVA[nLaco][2])
					FKD->FKD_SALDO  := 0
					FKD->FKD_DTBAIX := CtoD("//")
					If(lLiqui)
						FKD->FKD_VLINFO := Val(aValorVA[nLaco][2])
						FKD->FKD_VLCALC := Val(aValorVA[nLaco][2])
					EndIf
				EndIf

				FKD->(MsUnlock())
			Else
				If(Val(aValorVA[nLaco,2]) != 0)
					RecLock("FKD",.T.)
					FKD->FKD_FILIAL := xFilial("FKD")
					FKD->FKD_CODIGO := aValorVA[nLaco][1]
					FKD->FKD_VALOR  := Val(aValorVA[nLaco][2])
					FKD->FKD_IDDOC  := cChaveFK7
					FKD->FKD_SALDO  := 0
					FKD->FKD_DTBAIX := CtoD("//")

					If(lLiqui)
						FKD->FKD_VLINFO := Val(aValorVA[nLaco][2])
						FKD->FKD_VLCALC := Val(aValorVA[nLaco][2])
					EndIf

					FKD->(MsUnlock())

				EndIf
			EndIf
		Next nLaco
	EndIf
Return


/*/{Protheus.doc} FINFK5BUSCA
Função para localizar FK5 a partir do movimento SE5
@author Norberto Monteiro de Melo
@param cChave Correspondente à seguinte estrutura: E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
@param cAliasOrig Determina uma pesquisa relativa à uma tabela específica, por exemplo: SEF
@param lEstorno determina se será retornado o ID da FK5 referente ao estorno da baixa.
@Return	uRet Atendendo ao parâmetro cChave: Identificador FK5 correspondente ao registro de movimentação da tabela SE5
uRet Atendendo ao parâmetro cAliasOrig: Identificador SE5 correspondente ao registro de movimentação da tabela FKA
@since  28/09/2016
@version P12
/*/
Function FINFK5BUSCA(cChave,cAliasOrig, lEstorno, aCpos)
	Local uRet 		:= ""
	Local cQuery 	:= ""

	Default cChave 		:= ''
	Default cAliasOrig 	:= 'SE5'
	Default lEstorno 	:= .F.
	Default aCpos		:= {}

	If __nTamSeq == Nil
		__nTamSeq := TamSX3("FK5_SEQ")[1]
	EndIf

	If cAliasOrig == 'SEF'
		cQuery := "SELECT SE5.R_E_C_N_O_ URET"
		cQuery += "FROM "+RetSqlName("SEF")+" SEF "
		cQuery += "INNER JOIN "+RetSqlName("FKA")+" FKA ON FKA.FKA_FILIAL = SEF.EF_FILIAL AND FKA.FKA_IDORIG = SEF.EF_IDSEF AND FKA.FKA_TABORI = 'SEF' "
		cQuery += " LEFT JOIN "+RetSqlName("FKA")+" FKA2 ON FKA2.FKA_FILIAL = FKA.FKA_FILIAL AND FKA2.FKA_IDPROC = FKA.FKA_IDPROC AND FKA2.FKA_TABORI = 'FK5' "
		cQuery += "INNER JOIN "+RetSqlName("SE5")+" SE5 ON SE5.E5_FILIAL = FKA2.FKA_FILIAL AND SE5.E5_IDORIG = FKA2.FKA_IDORIG AND SE5.E5_TABORI = 'FK5' "
		cQuery += "WHERE SEF.R_E_C_N_O_ = " + AllTrim(Str(SEF->(RECNO())))
	Elseif cAliasOrig == 'SE5'
		cQuery := "SELECT FK5.FK5_IDMOV URET"
		cQuery += "FROM "+RetSqlName("SE5")+" SE5 "
		cQuery += "INNER JOIN "+RetSqlName("FKA")+" FKA1 ON FKA1.FKA_FILIAL = SE5.E5_FILIAL   AND FKA1.FKA_IDORIG = SE5.E5_IDORIG "
		cQuery += " LEFT JOIN "+RetSqlName("FKA")+" FKA2 ON FKA2.FKA_FILIAL = FKA1.FKA_FILIAL AND FKA2.FKA_IDPROC = FKA1.FKA_IDPROC "
		cQuery += "INNER JOIN "+RetSqlName("FK5")+" FK5  ON  FK5.FK5_FILIAL = FKA2.FKA_FILIAL AND FKA2.FKA_TABORI = 'FK5' AND FK5.FK5_IDMOV = FKA2.FKA_IDORIG "
		If lEstorno
			cQuery += "AND FK5.FK5_TPDOC = 'ES' "
		EndIf
		cQuery += "WHERE "
		If Len(aCpos) > 0
			cQuery += "SE5.E5_FILIAL = '" 	+ aCpos[1] + "' AND "
			cQuery += "SE5.E5_PREFIXO = '" 	+ aCpos[2] + "' AND "
			cQuery += "SE5.E5_NUMERO = '" 	+ aCpos[3] + "' AND "
			cQuery += "SE5.E5_PARCELA = '" 	+ aCpos[4] + "' AND "
			cQuery += "SE5.E5_TIPO = '" 	+ aCpos[5] + "' AND "
			cQuery += "SE5.E5_CLIFOR = '" 	+ aCpos[6] + "' AND "
			cQuery += "SE5.E5_LOJA = '" 	+ aCpos[7] + "' AND "
			cQuery += "SE5.E5_SEQ = '" + PadR(aCpos[8], __nTamSeq) + "' "
		Else
			cQuery += "SE5.E5_FILIAL || SE5.E5_PREFIXO || SE5.E5_NUMERO || SE5.E5_PARCELA || SE5.E5_TIPO || SE5.E5_CLIFOR || SE5.E5_LOJA || SE5.E5_SEQ = '" + cChave + "' "
		EndIf
		If lEstorno
			cQuery += "AND SE5.E5_TIPODOC = 'ES' "
		EndIf
		cQuery += "AND SE5.D_E_L_E_T_ = ' '"
	Elseif cAliasOrig == 'FK7'
		cQuery := "SELECT FK5.FK5_IDMOV URET"
		cQuery += "FROM "+RetSqlName("FK7")+" FK7 "
		cQuery += "INNER JOIN "+RetSqlName("FK2")+" FK2 ON FK2.FK2_FILIAL = FK7.FK7_FILIAL   AND FK2.FK2_IDDOC = FK7.FK7_IDDOC "
		cQuery += "INNER JOIN "+RetSqlName("FKA")+" FKA1 ON FKA1.FKA_FILIAL = FK2.FK2_FILIAL   AND FKA1.FKA_IDORIG = FK2.FK2_IDFK2 "
		cQuery += " LEFT JOIN "+RetSqlName("FKA")+" FKA2 ON FKA2.FKA_FILIAL = FKA1.FKA_FILIAL AND FKA2.FKA_IDPROC = FKA1.FKA_IDPROC "
		cQuery += "INNER JOIN "+RetSqlName("FK5")+" FK5  ON  FK5.FK5_FILIAL = FKA2.FKA_FILIAL AND FKA2.FKA_TABORI = 'FK5' AND FK5.FK5_IDMOV = FKA2.FKA_IDORIG "
		If lEstorno
			cQuery += "AND FK5.FK5_TPDOC = 'ES' "
		EndIf
		cQuery += "WHERE "
		cQuery += "FK7.FK7_CHAVE = '" + cChave + "'"
		cQuery += "AND FK7.D_E_L_E_T_ = ' '"
	EndIf

	cQuery := ChangeQuery(cQuery)
	uRet   := MpSysExecScalar(cQuery,"URET")

Return uRet

//-------------------------------------------------------------------
/*/ {Protheus.doc} FindBxKey
Verifica se o titulo possui baixas e retorna ID da baixa

@param cAlias	- Alias da tabela ref. a carteira
@param cChave   - Chave do titulo para pesquisa (formato FK7_CHAVE)
@param cSeqBx	- Sequencia da baixa


@author Igor Sousa do Nascimento
@since 24/05/2017

@return cChaveBx - Chave unica da baixa
/*/
//-------------------------------------------------------------------
Function FindBxKey(cAlias,cChave,cSeqBx,lEst)
	Local cAliasTmp    := CriaTrab(,.F.)
	Local cChaveBx := ""
	Local cQry	    := ""
	Local oTmp
	Default cAlias := Alias()
	Default cChave  := ""
	Default cSeqBx  := ""
	Default lEst 	:= .F.

	If oTmp <> Nil
		oTmp:Delete()
		oTmp:= Nil
	Endif

	oTmp := FwTemporaryTable():New(cAliasTmp)

	oTmp:SetFields({ {"FK7_FILIAL","C",TamSX3("FK7_FILIAL")[1],0},{"FK7_IDDOC","C",TamSX3("FK7_IDDOC")[1],0} })
	oTmp:AddIndex("1",{"FK7_FILIAL","FK7_IDDOC"})
	oTmp:Create()

	If cAlias $ "SE1|FK1"
		cQry += "SELECT FK1_IDFK1 FROM " + RetSqlName("FK1") + " FK1"
		cQry += " INNER JOIN " + RetSqlName("FK7") + " FK7"
		cQry += " ON FK7.FK7_IDDOC = FK1.FK1_IDDOC "
		cQry += " WHERE "
		cQry += " FK7_FILIAL = '" + xFilial("FK7") + "' "
		cQry += " AND FK7_CHAVE = '" + cChave + "'"
		cQry += " AND FK7.D_E_L_E_T_ = ' '"
		If !lEst
		cQry += " AND NOT EXISTS( "
		cQry += " 	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST"
		cQry += " 	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL"
		cQry += " 	AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
		cQry += " 	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
		cQry += " 	AND FK1EST.FK1_TPDOC = 'ES' "
		cQry += " 	AND FK1EST.D_E_L_E_T_ = ' ') "
		Else
			cQry += " AND FK1.FK1_TPDOC = 'ES' "
		Endif
		If !Empty(cSeqBx)
			cQry += " AND FK1_SEQ = '" + cSeqBx + "'"
		EndIf
		cQry += " AND FK1.D_E_L_E_T_ = ' '"

		cQry := ChangeQuery(cQry)
		MPSysOpenQuery(cQry, cAliasTmp)

		dbSelectArea(cAliasTmp)
		If !(cAliasTmp)->(EoF())
			cChaveBx := (cAliasTmp)->FK1_IDFK1	// Chave da baixa
		EndIf
	ElseIf cAlias $ "SE2|FK2"
		cQry += "SELECT FK2_IDFK2 FROM " + RetSqlName("FK2") + " FK2"
		cQry += " INNER JOIN " + RetSqlName("FK7") + " FK7"
		cQry += " ON FK7.FK7_IDDOC = FK2.FK2_IDDOC "
		cQry += " WHERE "
		cQry += " FK7_FILIAL = '" + xFilial("FK7") + "' "
		cQry += " AND FK7_CHAVE = '" + cChave + "'"
		cQry += " AND FK7.D_E_L_E_T_ = ' '"
		If !lEst
		cQry += " AND NOT EXISTS( "
		cQry += " 	SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST"
		cQry += " 	WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
		cQry += " 	AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
		cQry += " 	AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
		cQry += " 	AND FK2EST.FK2_TPDOC = 'ES' "
		cQry += " 	AND FK2EST.D_E_L_E_T_ = ' ') "
		Else
			cQry += " AND FK2.FK2_TPDOC = 'ES' "
		Endif
		If !Empty(cSeqBx)
			cQry += " AND FK2_SEQ = '" + cSeqBx + "'"
		EndIf
		cQry += " AND FK2.D_E_L_E_T_ = ' '"

		cQry := ChangeQuery(cQry)
		MPSysOpenQuery(cQry, cAliasTmp)

		dbSelectArea(cAliasTmp)
		If !(cAliasTmp)->(EoF())
			cChaveBx := (cAliasTmp)->FK2_IDFK2	// Chave da baixa
		EndIf
	EndIf

	(cAliasTmp)->(dbCloseArea())

	oTmp:Delete()
	oTmp:= Nil

Return cChaveBx

//-------------------------------------------------------------------
/*/{Protheus.doc} FSetMt2CTB
Função para carregar os valores de impostos retidos nas variáveis de
contabilização

@param cCodRet, Código do tipo de retenção cadastrado no FKM
@param nValRet, Valor de retenção

@author Pedro Alencar
@since 15/03/2018
@version P12
/*/
//-------------------------------------------------------------------
Function FSetMt2CTB( cCodRet As Char, nValRet As Numeric )
	Local cVarCtb As Char

	Default cCodRet := ""
	Default nValRet := 0

	//inicilaiza variáveis.
	cVarCtb := ""

	If !Empty( cCodRet )
		nRecFKK := FinFKKVig(cCodRet, dDataBase)
		FKK->(dbGoTo(nRecFKK))

		If !Empty(FKK->FKK_VARCTB)
			cVarCtb := Alltrim(FKK->FKK_VARCTB)

			If FKK->FKK_FATGER == "2" .And. Type(cVarCtb) == "N"
				&( cVarCtb ) := nValRet
			EndIf
		EndIf
	EndIf

Return Nil

//--------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FinCarVarE
Função para carregar os valores de impostos retidos pelo motor, na emissão, nas variáveis de contabilização

@param aMotRet, Vetor retornado no cálculo do motor de retenções

@author Pedro Alencar
@since 15/03/2018
@version P12
/*/
//--------------------------------------------------------------------------------------------------------------
Function FinCarVarE( aMotRet As Array )

	Local nI As Numeric
	Local nValRet As Numeric
	Local cVarCtb As Char

	Default aMotRet := {}

	nI := 0
	nValRet := 0
	cVarCtb := ""

	If Len( aMotRet ) > 0
		For nI := 1 To Len( aMotRet )
			nValRet := aMotRet[nI,5]
			//Se houve valor de retenção, então soma na variável de contabilização
			If nValRet > 0
				cVarCtb := AllTrim( aMotRet[nI,17] )
				If Type(cVarCtb) != "N"
					exit
				EndIf

				If aMotRet[nI,9] == "1"
					&(cVarCtb) += nValRet
				EndIf
			EndIf
		Next nI
	EndIF

Return Nil

/*/{Protheus.doc} BxGerMovPA
Define se na baixa do PA ou geração do mov. banc será gerado um novo processo na FKA,
ou será utilizado o processo da FKA gerado na inclusão do PA

@author Sivaldo Oliveira
@since 28/03/2018
@version 12
/*/
Function BxGerMovPA(lOk As Logical)
	Default lOk := .F.
	lBxMovPA := lOk
Return Nil

/*/{Protheus.doc} BxReciboE1
	Busca todos movimentos do mesmo recibo
	@type  Function
	@author renato.ito
	@since 19/11/2019
	@version 12
	@param nRecSe5, Numeric, Recno da SE5 de partida para a busca
	@return aRet, Array, Retorna todos os recnos do mesmo recibo
/*/
Function BxReciboE1(nRecSe5 As Numeric) As Array

	Local aRet			As Array
	Local oTmpRecib 	As Object
	Local cQuery		As Character
	Local cTblRecib		As Character

	aRet		:= {}
	oTmpRecib	:= NIL
	cQuery		:= ""
	cTblRecib	:= ""

	DbSelectArea("SE5")
	SE5->(DbGoTo(nRecSe5))

	cQuery := "SELECT R_E_C_N_O_ RECNO FROM " + RetSqlName("SE5") + " SE5 WHERE "
	cQuery += " SE5.E5_FILIAL = ? "
	cQuery += " AND SE5.E5_ORDREC = ? "
	cQuery += " AND SE5.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	oTmpRecib:=FWPreparedStatement():New( cQuery )
	oTmpRecib:SetString( 1, SE5->E5_FILIAL )
	oTmpRecib:SetString( 2, SE5->E5_ORDREC )

	cQuery		:= oTmpRecib:GetFixQuery()
	cTblRecib	:= MpSysOpenQuery(cQuery)

	While (cTblRecib)->(!Eof())
		AAdd(aRet,(cTblRecib)->RECNO)
		(cTblRecib)->(DbSkip())
	EndDo
	(cTblRecib)->(DbCloseArea())

Return aRet


//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}FinFK7Cpos
Processa e retorna a chave do título gravada na tabela FK7 para a gravção dos campos referentes aos dados dos
títulos

@param cKeyOrig, Chave original gravada na tabela FK7 para processamento
@param cIdDoc, IdDoc da tabela FK7. Caso seja passado posicionará a tabela FK7 para obter a chave (FK7_CHAVE)

@author Mauricio Pequim Jr
@since  10/09/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------------------------------------------------
Function FinFK7Cpos(cKeyOrig As Character, cIdDoc As Character)
	Local cChave	AS Character
	Local aQuebra	As Array

	Default cKeyOrig	:= ''
	Default cIdDoc		:= ''

	cChave	:= ""
	aQuebra := {}

	If Empty(__aTamCpos)
		aAdd(__aTamCpos,TamSXG('033')[1])
		aAdd(__aTamCpos,               3)
		aAdd(__aTamCpos,TamSXG('018')[1])
		aAdd(__aTamCpos,TamSXG('011')[1])
		aAdd(__aTamCpos,               3)
		aAdd(__aTamCpos,TamSXG('001')[1])
		aAdd(__aTamCpos,TamSXG('002')[1])
	Endif

	If !Empty(cIdDoc)
		FK7->(DbSetOrder(1)) // Filial + IdDoc
		FK7->(DbSeek(xFilial('FK7')+cIdDoc))
		cKeyOrig := FK7->FK7_CHAVE
	EndIf

	//Transforma a linha em um array com todos os registros
	aQuebra := StrToKarr(cKeyOrig,'|')

	If Len(aQuebra) == 7
		RecLock("FK7")
			FK7->FK7_FILTIT := PadR(aQuebra[1],__aTamCpos[1]) // Filial
			FK7->FK7_PREFIX := PadR(aQuebra[2],__aTamCpos[2]) // Prefixo
			FK7->FK7_NUM	:= PadR(aQuebra[3],__aTamCpos[3]) // Numero
			FK7->FK7_PARCEL	:= PadR(aQuebra[4],__aTamCpos[4]) // Parcela
			FK7->FK7_TIPO	:= PadR(aQuebra[5],__aTamCpos[5]) // Tipo
			FK7->FK7_CLIFOR	:= PadR(aQuebra[6],__aTamCpos[6]) // Cliente
			FK7->FK7_LOJA	:= PadR(aQuebra[7],__aTamCpos[7]) // Loja
		MsUnlock()
	Endif

	FwFreeArray(aQuebra)

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc}FInDicTVA
Verifica se as tabelas referentes a VA (valores acessórios) estão no dicionário

@author Mauricio Pequim Jr
@since  04/04/2022
@version 12.1.33
/*/
//-------------------------------------------------------------------------------------------------------------
Function FInDicTVA()

	Local lRet AS Logical

	lRet := .F.

	If _lInDicFKC == nil
		_lInDicFKC := TableInDic("FKC")
	EndIF

	If _lInDicFKD == nil
		_lInDicFKD := TableInDic("FKD")
	EndIF

	If _lInDicFKC .and. _lInDicFKD
		lRet := .T.
	Endif

Return lRet

