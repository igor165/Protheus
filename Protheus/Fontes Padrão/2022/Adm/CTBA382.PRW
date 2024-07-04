#INCLUDE 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#Include "CTBA382.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBA382
Tela Variação Cambial
@author Thiago Murakami Malaquias da Silva
@since  18/11/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function CTBA382()
Local		oBrowse  	:= FWmBrowse():New()
Private	cCadastro	:= STR0001 //Processamento Variação Cambial

oBrowse:SetAlias('CQC')
oBrowse:SetDescription(cCadastro)
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Menu da Variação Cambial
@author Thiago Murakami Malaquias da Silva
@since  21/11/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

AADD(aRotina, {STR0002, "AxPesqui" 	, 0, 1})	//"Pesquisar"
AADD(aRotina, {STR0011, "AxVisual" 	, 0, 2})	//"Visualizar"
AADD(aRotina, {STR0012, "AxAltera" 	, 0, 4})	//"Alterar"
AADD(aRotina, {STR0003, "CTB382Perg" 	, 0, 3})	//"Processar"
AADD(aRotina, {STR0008, "CTB382APg" 	, 0, 5})	//"Estorno"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}CTB382Perg
Parametrização para o processamento
@author Totvs
@since  03/12/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function CTB382Perg()

//---------------------------
// Processamento da Variação
//---------------------------
	If Pergunte("CTB382", .T.)
		MsgRun(STR0005,STR0001,{|| CTB382Proc() }) //"Processando a variação cambial. Aguarde..."###"Processamento Variação Cambial"
	EndIf

	MBrChgLoop(.F.) //Desabilita a chamada da tela de inclusão novamente.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}CTB382Proc
Processamento Variação Cambial
@author Thiago Murakami Malaquias da Silva
@since  21/11/2014
@version 11.80
/*/
//-------------------------------------------------------------------

Function CTB382Proc()
Local cAliasQry	:= GetNextAlias()
Local cChave		:= ""
Local nCotac		:= 0 //Cotação
Local nSldOpe		:= 0 //Saldo na moeda do fato
Local nSldAntOpe	:= 0 //Saldo anterior na moeda do fato
Local nCotacAnt	:= 0 //Cotação anterior
Local nSld01		:= 0 //Saldo na moeda 01
Local nSldAnt01	:= 0 //Saldo anterior na moeda 01
Local nSldAtu01	:= 0 //Saldo anterior atualizado na moeda 01
Local nVar			:= 0 //Varição cambial
Local nVarAcm		:= 0 //Variação cambial acumulada
Local cMoeda		:= ""
Local cConta		:= ""
Local cCCusto		:= ""
Local cItem		:= ""
Local cClVl		:= ""
Local cEnt05		:= ""
Local cEnt06		:= ""
Local cEnt07		:= ""
Local cEnt08		:= ""
Local cEnt09		:= ""
Local dDataAnt	:= SToD("//")
Local lGravaCQC	:= .F.
Local cCod			:= ""

//Variaveis para contabilizacao
Local cLote		:= ""
Local cArquivo	:= ""
Local lLancPad	:= .T.
Local lPrim		:= .T.
Local nHdlPrv		:= 0
Local nTotal		:= 0
Local lMostrLanc	:= .T.
Local lAglutLanc	:= .T.

Pergunte("CTB382", .F.)

lLancPad	:= VerPadrao(MV_PAR05)
lMostrLanc	:= MV_PAR06 == 1
lAglutLanc	:= MV_PAR07 == 1
cLote		:= MV_PAR10

If CTBA382Qry(@cAliasQry)

	//---------------------------------------------------------------------------
	// Obtém o código do processamento da variação, relacionando a CQC com a CQB
	//---------------------------------------------------------------------------
	While .T.
		cCod := GetSx8Num("CQC","CQC_COD")
		CQC->(ConfirmSX8())
		DbSelectArea("CQC")
		CQC->(DbSetOrder(1)) //CQC_FILIAL+CQC_CODIGO

		If !DbSeek(Xfilial("CQC")+cCod)
			Exit
		EndIf
	EndDo

	//---------------------
	// Processa a Variação
	//---------------------
	While .T.

		If cChave != (cAliasQry)->(CQB_FILIAL + CQB_MOEDA + CQB_CONTA + CQB_CCUSTO + CQB_ITEM + CQB_CLVL + CQB_ENT05 + CQB_ENT06 + CQB_ENT07 + CQB_ENT08 + CQB_ENT09) 

			If !Empty(cChave)

				If dDataAnt != MV_PAR01

					nCotacAnt	:= nCotac
					nCotac		:= RecMoeda(MV_PAR01,cMoeda)

					nSld01		:= nSldOpe * nCotac
					nSldAnt01	:= nSldOpe * nCotacAnt
					nSldAtu01	:= nSldOpe * nCotac
					nVar		:= nSldAtu01 - nSldAnt01
					nVarAcm	:= nVar + nVarAcm

				EndIf	

				If nVarAcm != 0 //Grava a variacao se houver valor acumulado
					If lPrim .And. (nHdlPrv <= 0) .And. lLancPad
						nHdlPrv	:= HeadProva(cLote,"CTBA382",Substr(cUsername,1,6),@cArquivo)
						lPrim		:= .F.
					Endif

					//------------------------------------------------------
					// Gravacao do calcula da variacao do periodo informado
					//------------------------------------------------------
					Reclock("CQB", .T.)
					CQB->CQB_FILIAL	:= XFilial("CQB")
					CQB->CQB_IDSLD	:= FWUUIDV4()
					CQB->CQB_DATA		:= MV_PAR01
					CQB->CQB_COTMOE	:= nCotac
					CQB->CQB_MOEDA	:= cMoeda
					CQB->CQB_CONTA	:= cConta
					CQB->CQB_CCUSTO	:= cCCusto
					CQB->CQB_ITEM		:= cItem
					CQB->CQB_CLVL		:= cCLVL
					CQB->CQB_ENT05	:= cEnt05
					CQB->CQB_ENT06	:= cEnt06
					CQB->CQB_ENT07	:= cEnt07
					CQB->CQB_ENT08	:= cEnt08
					CQB->CQB_ENT09	:= cEnt09
					If nSldOpe > 0
						CQB->CQB_CREDIT := nSldOpe
					ElseIf nSldOpe < 0
						CQB->CQB_DEBITO := ABS (nSldOpe)
					EndIf
					CQB->CQB_VARIAC	:= nVarAcm
					CQB->CQB_CODORI	:= cCod
					CQB->(MsUnlock())

					If lLancPad
						nTotal += DetProva(nHdlPrv,MV_PAR05,"CTBA382",cLote)
					EndIf
				EndIf

				If (cAliasQry)->(Eof())
					Exit
				EndIf

			EndIf
			//-------------------------------------------
			// Armazena os valores para calculo do saldo
			//-------------------------------------------
			cChave		:= (cAliasQry)->(CQB_FILIAL + CQB_MOEDA + CQB_CONTA + CQB_CCUSTO + CQB_ITEM + CQB_CLVL + CQB_ENT05 + CQB_ENT06 + CQB_ENT07 + CQB_ENT08 + CQB_ENT09)
			nCotac		:= (cAliasQry)->( CQB_COTMOE )
			nSldOpe	:= (cAliasQry)->( CQB_CREDIT - CQB_DEBITO )
			nSldAntOpe	:= 0
			nSld01		:= nSldOpe * nCotac
			nCotacAnt	:= 0
			nSldAnt01	:= 0
			nSldAtu01	:= 0
			nVar		:= 0
			nVarAcm	:= 0
			dDataAnt	:= (cAliasQry)->( CQB_DATA )

			//-----------------------------------------------------
			// Guarda a chave do saldo para lancamento da variacao
			//-----------------------------------------------------
			cMoeda		:= (cAliasQry)->( CQB_MOEDA )
			cConta		:= (cAliasQry)->( CQB_CONTA )
			cCCusto	:= (cAliasQry)->( CQB_CCUSTO )
			cItem		:= (cAliasQry)->( CQB_ITEM )
			cCLVL		:= (cAliasQry)->( CQB_CLVL )
			cEnt05		:= (cAliasQry)->( CQB_ENT05 )
			cEnt06		:= (cAliasQry)->( CQB_ENT06 )
			cEnt07		:= (cAliasQry)->( CQB_ENT07 )
			cEnt08		:= (cAliasQry)->( CQB_ENT08 )
			cEnt09		:= (cAliasQry)->( CQB_ENT09 )

			//-------------------------------------
			// Atualiza o registro como processado
			//-------------------------------------
			CQB->(DBGoTo((cAliasQry)->R_E_C_N_O_ ))
			Reclock("CQB", .F.)
			CQB->CQB_DTVAR	:= MV_PAR01
			CQB->CQB_COD		:= cCod
			CQB->(MsUnlock())
			
			lGravaCQC := .T.

		Else
			//-----------------
			// Calcula o saldo
			//-----------------
			nCotacAnt	:= nCotac
			nCotac		:= (cAliasQry)->( CQB_COTMOE )

			nSldAntOpe	:= nSldOpe
			nSldOpe	:= nSldAntOpe + (cAliasQry)->( CQB_CREDIT - CQB_DEBITO )

			nSld01		:= nSldOpe * nCotac
			nSldAnt01	:= nSldAntOpe * nCotacAnt
			nSldAtu01	:= nSldAntOpe * nCotac
			nVar		:= nSldAtu01 - nSldAnt01
			nVarAcm	:= nVar + nVarAcm

			//-------------------------------------
			// Atualiza o registro como processado
			//-------------------------------------
			CQB->(DBGoTo((cAliasQry)->R_E_C_N_O_ ))
			Reclock("CQB", .F.)
			CQB->CQB_DTVAR	:= MV_PAR01
			CQB->CQB_COD		:= cCod
			CQB->(MsUnlock())

			lGravaCQC := .T.

		EndIf	

	(cAliasQry)->(DbSkip())
	EndDo

	If lLancPad .And. nHdlPrv > 0 .And. nTotal > 0
		RodaProva(nHdlPrv,nTotal)
		cA100Incl(cArquivo,nHdlPrv,2,cLote,lMostrLanc,lAglutLanc )
	Endif

	//----------------------------------------
	// Inclusão do cabeçalho do processamento
	//----------------------------------------
	If lGravaCQC
		RecLock("CQC",.T.)
		CQC->CQC_FILIAL	:= XFilial("CQC")
		CQC->CQC_COD		:= cCod
		CQC->CQC_DATA		:= MV_PAR01
		CQC->CQC_DESCR	:= Transform(MV_PAR11, X3Picture('CQC_DESCR '))
		CQC->(MsUnlock())
	EndIf

Else
	Help( " ", 1, "CTB382PROC",,STR0004, 1, 0 ) //"Não foram encontrados registros de acordo com os paramentros informados"
Endif

If Select(cAliasQry) > 0
	DbSelectArea(cAliasQry)
	DbCloseArea()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBA382Qry
@author Thiago Murakami Malaquias da Silva
@since  18/11/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function CTBA382Qry(cAliasQry)
Local aArea	:= GetArea()
Local cQuery	:= ""
Local lRet		:= .T.
Local aTamVl	:= TamSX3("CQB_DEBITO")
Local aTamVlCM	:= TamSX3("CQB_COTMOE")

Pergunte("CTB382", .F.)

cQuery := " SELECT CQB_FILIAL, CQB_DATA, CQB_MOEDA, CQB_CONTA, CQB_CCUSTO, CQB_ITEM, CQB_CLVL, CQB_ENT05, CQB_ENT06, CQB_ENT07, CQB_ENT08, CQB_ENT09, CQB_DEBITO, CQB_CREDIT, CQB_COTMOE, R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("CQB") + " CQB "
cQuery += " WHERE "
cQuery += " CQB_FILIAL = '" + XFilial("CQB") + "' AND "
cQuery += " CQB_DATA		BETWEEN	'" + Dtos(MV_PAR02) + "' AND '" + DToS(MV_PAR01) + "' AND "
cQuery += " CQB_MOEDA	BETWEEN	'" + MV_PAR03 + "' AND '" + MV_PAR04 + "' AND "
cQuery += " CQB_CONTA	BETWEEN	'" + MV_PAR08 + "' AND '" + MV_PAR09 + "' AND "
cQuery += " CQB_DTVAR = ' ' AND "
cQuery += " CQB.D_E_L_E_T_ = '' "
cQuery += " ORDER BY CQB_FILIAL, CQB_MOEDA, CQB_CONTA, CQB_CCUSTO, CQB_ITEM, CQB_CLVL, CQB_ENT05, CQB_ENT06, CQB_ENT07, CQB_ENT08, CQB_ENT09, CQB_DATA "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasQry,.T.,.T.)
TcSetField(cAliasQry, "CQB_DATA", "D", 8, 0)
TcSetField(cAliasQry, "CQB_DEBITO", "N", aTamVl[1], aTamVl[2])
TcSetField(cAliasQry, "CQB_CREDIT", "N", aTamVl[1], aTamVl[2])
TcSetField(cAliasQry, "CQB_COTMOE", "N", aTamVlCM[1], aTamVlCM[2])

lRet := (cAliasQry)->(!Eof())

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}CTB382APg
Processamento do estorno da Variação
@author Totvs
@since  03/12/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function CTB382APg()

If Pergunte("CTB382A", .T.)
	MsgRun(STR0009,STR0010,{|| CTBA382Est() }) //"Processando o estorno da variação cambial. Aguarde..."###"Processamento do estorno Variação Cambial"
EndIf

Return	

//-------------------------------------------------------------------
/*/{Protheus.doc}CTBA382Est
Estorno
@author Thiago Murakami Malaquias da Silva
@since  16/12/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function CTBA382Est()
Local cAliasEst	:= GetNextAlias()
Local aArea		:= GetArea()
Local lRet			:= .T.

//Variaveis para contabilizacao
Local cLote		:= ""
Local cArquivo	:= ""
Local lLancPad	:= .T.
Local lPrim		:= .T.
Local nHdlPrv		:= 0
Local nTotal		:= 0
Local lMostrLanc	:= .T.
Local lAglutLanc	:= .T.

Pergunte("CTB382A", .F.)

lLancPad	:= VerPadrao(MV_PAR01)
lMostrLanc	:= MV_PAR02 == 1
lAglutLanc	:= MV_PAR03 == 1
cLote		:= MV_PAR04

If CTB382Est(@cAliasEst)

	//------------
	// Validação
	//------------
	While (cAliasEst)->(!EOF())
	
		If !Empty((cAliasEst)->CQB_CODORI) .And. ((cAliasEst)->CQB_CODORI) == CQC->CQC_COD .And. !Empty((cAliasEst)->CQB_COD)
			lRet := .F.
				Help(" ", 1, "CTBA382EST",,STR0007, 1, 0 ) //O registro foi considerado em processamento posterior, deverá estornar esse cálculo primeiro
			Exit
		EndIf
	
	(cAliasEst)->(DbSkip())
	EndDo
	
	If lRet
		(cAliasEst)->(DbGoTop())
		While (cAliasEst)->(!EOF())
	
			CQB->(DBGoTo((cAliasEst)->R_E_C_N_O_ ))
	
			//Liberação dos registro de saldos
			If Empty(CQB->CQB_CODORI) .Or. CQB->CQB_CODORI != CQC->CQC_COD
	
				Reclock("CQB", .F.)
				CQB->CQB_COD		:= ""
				CQB->CQB_DTVAR	:= Stod("")
				CQB->(MsUnlock())
	
			Else
	
				//Exclusão dos registro de cálculos
				If lPrim .And. (nHdlPrv <= 0) .And. lLancPad
					nHdlPrv := HeadProva(cLote,"CTBA382",Substr(cUsername,1,6),@cArquivo)
					lPrim := .F.
				Endif
	
				If lLancPad
					nTotal += DetProva( nHdlPrv,MV_PAR01,"CTBA382",cLote)
				EndIf
	
				Reclock("CQB", .F.)
				CQB->(DbDelete())
				CQB->(MsUnlock())
	
			EndIf
	
		(cAliasEst)->(DbSkip())
		EndDo
	
		If lLancPad .And. nHdlPrv > 0 .And. nTotal > 0
			RodaProva(nHdlPrv,nTotal)
			cA100Incl(cArquivo,nHdlPrv,2,cLote,lMostrLanc,lAglutLanc)
		Endif
		
		//Exclusão da CQC
		Reclock("CQC", .F.)
		CQC->(DbDelete())
		CQC->(MsUnlock())
	
	EndIf
EndIf	

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}CTB382Est
Query realização do Estorno
@author Thiago Murakami Malaquias da Silva
@since  16/12/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function CTB382Est(cAliasEst)
Local cQuery	:= ""
Local lRet		:= .T.

cQuery := " SELECT CQB_FILIAL, CQB_COD, CQB_CODORI, R_E_C_N_O_ "
cQuery += " FROM " + RetSqlName("CQB") + " CQB "
cQuery += " WHERE "
cQuery += " CQB_FILIAL = '" + XFilial("CQB") + "' AND "
cQuery += " CQB_COD = '" + CQC->CQC_COD + "' OR "
cQuery += " CQB_CODORI = '" + CQC->CQC_COD + "' AND "
cQuery += " CQB.D_E_L_E_T_ = ' ' "
cQuery += " ORDER BY CQB_FILIAL, CQB_COD, CQB_CODORI "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery), cAliasEst,.T.,.T.)

lRet := (cAliasEst)->(!Eof())

Return lRet
