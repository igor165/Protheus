#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWADAPTEREAI.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA012
Funcao que prepara as as informacao para o envio da mensagem PeriodGlBalance

@param		dDataIni, Data Inicial para o saldo contabil
@param		dDataFim, Data Final para o saldo contabil

@author	Alvaro Camillo Neto
@since		14/11/2013
@version	MP11.90
/*/
//-------------------------------------------------------------------
Function CTBA012A(dDataIni,dDataFim)
Local aArea 	:= GetArea()
Local cFilx 	:= cFilAnt
Local aSM0		:= FWLoadSM0()
Local nX		:= 0
Local cFilCTG	:= xFilial("CTG")
Local cFilAux	:= ""
Local lRet		:= .T.

// Tratamento Gestao Corporativa
// Serão exportadas todas as filiais do calendario
For nX := 1 to Len(aSM0)
	cFilAnt := aSM0[nX][2]
	If Alltrim(aSM0[nX][1]) == Alltrim(cEmpAnt)
		If cFilCTG == xFilial("CTG")
			If cFilAux != xFilial("CT2")
				cFilAux := xFilial("CT2")
				lRet := CT012EAI(dDataIni,dDataFim)
				If !lRet
					Exit
				EndIf
			EndIf
		EndIf
	EndIf
Next nX

cFilAnt := cFilx
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CT012EAI
Funcao que prepara as as informacao para o envio da mensagem PeriodGlBalance

@param		dDataIni, Data Inicial para o saldo contabil
@param		dDataFim, Data Final para o saldo contabil

@author	Alvaro Camillo Neto
@since		14/11/2013
@version	MP11.90


/*/
//-------------------------------------------------------------------
Static Function CT012EAI(dDataIni,dDataFim)

Local cArqTmp		:= ""
Local cContaDe 	    := ""
Local cContaAte	    := Replicate("Z",TamSX3("CT1_CONTA")[1])
Local cCCDe		    := ""
Local cCCAte		:= Replicate("Z",TamSX3("CTT_CUSTO")[1])
Local cItemDe	    := ""
Local cItemAte		:= Replicate("Z",TamSX3("CTD_ITEM")[1])
Local cClVlDe       := ""
Local cClVlAte		:= Replicate("Z",TamSX3("CTH_CLVL")[1])
Local cMoeda		:= "01"
Local cSaldo		:= '1'
Local lImpMov		:= .F.
Local lVlrZerado	:= .F.
Local lImpSint   	:= .F.
Local nCount		:= 0
Local cXml			:= ""
Local nMax			:= 10
Local cDataFim      := Substr(DtoS(dDataFim),1,4) + '-' + Substr(DtoS(dDataFim),5,2) + '-' +  Substr(DtoS(dDataFim),7,2)
Local aSetOfBook    := CTBSetOf("")
Local nDivide		:= 1
Local aDados		:= {}
Local nY			:= 0
Local nZ			:= 0 //Controle do FOR
Local lRet			:= .T.
Local aInteg        := {}
Local cVersion      := FWXX4Version('PERIODGLBALANCE') //Versão da Mensagem
Local cAliasSld     := '' //Alias de Saldo Contábil
Local aEntCtb       := CarrEntCtb() //array de verificação das entidades contabeis adicionais, com 5 posicoes

DBSelectArea("CT1")
CT1->(dbSetOrder(1))

If ExistBlock ("CT012INTEG")
	//O retorno do array deve conter todas as posicoes preenchidas, mesmo que nao alteradas.
	aInteg := ExecBlock("CT012Integ",.F.,.F.,{dDataIni,dDataFim,cContaDe,cContaAte,cCCDe,cCCAte,cMoeda,cSaldo})

	If ValType(aInteg) == "A" .and. Len(aInteg) == 8
		dDataIni	:= aInteg[1]
		dDataFim	:= aInteg[2]
		cContaDe	:= aInteg[3]
		cContaAte	:= aInteg[4]
		cCCDe		:= aInteg[5]
		cCCAte		:= aInteg[6]
		cMoeda		:= aInteg[7]
		cSaldo		:= aInteg[8]
	EndIf
EndIf

If cVersion = "2."
	//Retornando o Alias do Saldo Contábil
	cAliasSld := AliasSldCt()

	//Caso seja entidades Adicionais, compor saldo de forma diferente
	If (cAliasSld == 'CVY')
		SldCtbCVY(@cArqTmp, dDataIni, dDataFim, cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda, cSaldo, lVlrZerado)
	ElseIf cAliasSld == 'CTI'
		CTGerPlan( , , , .F. ,@cArqTmp,;
					dDataIni,dDataFim, cAliasSld,"",cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda,;
					cSaldo,aSetOfBook,,,,,;
					.F.,.T.,, "CTT",.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,,,,,,.T.,.T.)
	Else
		CTGerPlan( , , , .F. ,@cArqTmp,;
				dDataIni,dDataFim, cAliasSld,"",cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda,;
				cSaldo,aSetOfBook,,,,, !lImpMov,.T.,,"CT1",;
					.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,,,,,,;
					.F.,,,,,,,,,,,.F.,,,,,,,,)
	EndIf
Else
	CTGerPlan( , , , .F. ,@cArqTmp,;
			  dDataIni,dDataFim,"CT3","",cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda,;
			   cSaldo,aSetOfBook,,,,, !lImpMov,.T.,,"CT1",;
				.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,,,,,,;
				,,,,,,,,,,,.F.,,,,,,,,)
EndIf

cArqTmp->(dbGoTop())

aTMPStr := cArqTmp->(DBStruct())

While cArqTmp->( !Eof() )

	If cAliasSld == "CTI" .And. cArqTmp->TIPOCLVL<> "2"
		cArqTmp->(dbSkip())
		Loop		
	EndIf	

	IF cArqTmp->SALDODEB == 0 .And. cArqTmp->SALDOCRD == 0
		cArqTmp->(dbSkip())
		Loop
	Endif

	If CT1->(MsSeek(xFilial("CT1") + cArqTmp->CONTA )) .And. Alltrim(CT1->CT1_INTP) != '1'
		cArqTmp->(dbSkip())
		Loop
	EndIf

	aAdd(aDados,{cArqTmp->CONTA,cArqTmp->CUSTO,cArqTmp->SALDOANT,cArqTmp->SALDOCRD,cArqTmp->SALDODEB,cArqTmp->SALDOATU})

	//Verifica se tem suporte a todas as entidades adicionais
	If (cVersion = "2.")
		//Adicionando Item Contábil e Centro de Custo
		AAdd(aDados[Len(aDados)], cArqTmp->ITEM)
		AAdd(aDados[Len(aDados)], cArqTmp->CLVL)

		//Percorrendo array de Entidades Adicionais
		For nY := 01 To Len(aEntCtb)
			//Verifica se possui campo
			If !(Type("cArqTmp->" + aEntCtb[nY, 02]) == "U")
				AAdd(aDados[Len(aDados)], cArqTmp->&(aEntCtb[nY, 02]))
				aEntCtb[nY, 01] := .T.
			Else
				AAdd(aDados[Len(aDados)], "")
			EndIf
		Next nY
	EndIf

	cArqTmp->(dbSkip())
EndDo

For nY := 1 to Len(aDados)

	If nCount == 0
		cXml	:= ''

		cXml := ' <BusinessEvent>'
		cXml +=     ' <Entity>PeriodGlBalance</Entity>'
		cXml +=     ' <Event>upsert</Event>'
		cXml += ' </BusinessEvent>'

		cXml	+= '<BusinessContent>'
		cXml	+= '  <PeriodGlBalance>'
		cXml	+= '    <SelectionInformation>'
		cXml	+= '      <ListOfRuleInformation>'
		cXml	+= '        <RuleInformation>'
		cXml	+= '          <RuleType></RuleType>'
		cXml	+= '          <InitialValue></InitialValue>'
		cXml	+= '          <FinalValue></FinalValue>'
		cXml	+= '        </RuleInformation>'
		cXml	+= '      </ListOfRuleInformation>'
		cXml	+= '    </SelectionInformation>'
		cXml	+= '    <ParametersInformation>'
		cXml	+= '      <PeriodInformation>'
		cXml	+= '        <GLPeriodDate>'+cDataFim+'</GLPeriodDate>'
		cXml	+= '      </PeriodInformation>'
		cXml	+= '      <FirstPart></FirstPart>'
		cXml	+= '    </ParametersInformation>'
		cXml	+= '    <ListOfPeriodGLBalanceInformation>'
   	EndIf

	cXml	+= '		<PeriodGLBalanceInformation>'
	cXml	+= '        <CompanyId>'+cEmpAnt+'</CompanyId>'
	cXml	+= '        <BranchId>'+cFilAnt+'</BranchId>'
	cXml	+= '        <CompanyInternalId>'+cEmpAnt+'|'+cFilAnt+'</CompanyInternalId>'
	//Verifica se tem suporte a todas as entidades adicionais
	If (cVersion = "2.")
		/**Entidades Contábeis**/
		//Conta Contábil
		If !(Empty(aDados[nY][01]))
			cXml	+= '          <AccountantAccountInternalId>' + cEmpAnt + "|" + FWxFilial("CT1") + "|" + _NoTags( AllTrim( aDados[nY][01] ) ) + '</AccountantAccountInternalId>'
			cXml	+= '          <AccountantAccountCode>' + _NoTags( AllTrim( aDados[nY][01] ) ) + '</AccountantAccountCode>'
		Else
			cXml	+= '          <AccountantAccountInternalId/>'
			cXml	+= '          <AccountantAccountCode/>'
		EndIf
		//Centro de Custo
		If !(Empty(aDados[nY][02]))
			cXml	+= '          <CostCenterInternalId>' + cEmpAnt + "|" + FWxFilial("CTT") + "|" + _NoTags( AllTrim( aDados[nY][02] ) ) + '</CostCenterInternalId>'
			cXml	+= '          <CostCenterCode>' + _NoTags( AllTrim( aDados[nY][02] ) ) + '</CostCenterCode>'
		Else
			cXml	+= '          <CostCenterInternalId/>'
			cXml	+= '          <CostCenterCode/>'
		EndIf
		//Item Contábil
		If !(Empty(aDados[nY][07]))
			cXml	+= '          <AccountantItemInternalId>' + cEmpAnt + "|" + FWxFilial("CTD") + "|" + _NoTags( AllTrim( aDados[nY][07] ) ) + '</AccountantItemInternalId>'
			cXml	+= '          <AccountantItemCode>' + _NoTags( AllTrim( aDados[nY][07] ) ) + '</AccountantItemCode>'
		Else
			cXml	+= '          <AccountantItemInternalId/>'
			cXml	+= '          <AccountantItemCode/>'
		EndIf
		//Classe de Valor
		If !(Empty(aDados[nY][08]))
			cXml	+= '          <ClassValueInternalId>' + cEmpAnt + "|" + FWxFilial("CTH") + "|" + _NoTags( AllTrim( aDados[nY][08] ) ) + '</ClassValueInternalId>'
			cXml	+= '          <ClassValueCode>' + _NoTags( AllTrim( aDados[nY][08] ) ) + '</ClassValueCode>'
		Else
			cXml	+= '          <ClassValueInternalId/>'
			cXml	+= '          <ClassValueCode/>'
		EndIf
		//Entidades Adicionais
		nEntAux := 05
		For nZ := 09 To Len(aDados[nY])
			If !(Empty(aDados[nY][nZ]))
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'InternalId>' + cEmpAnt + "|" + FWxFilial("CT0") + "|" + _NoTags( AllTrim( aDados[nY][nZ] ) ) + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'InternalId>'
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Code>' + _NoTags( AllTrim( aDados[nY][nZ] ) ) + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Code>'
			Else
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'InternalId/>'
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Code/>'
			EndIf
			nEntAux ++ //Incrementando Entidade
		Next nZ
	Else
		cXml	+= '        <CostCenterInformation>'
		cXml	+= '          <CostCenterCode>' + _NoTags( AllTrim( aDados[nY][2] ) ) + '</CostCenterCode>'
		cXml	+= '        </CostCenterInformation>'
		cXml	+= '       <AccountInformation>'
		cXml	+= '        <AccountCode>' + _NoTags( AllTrim( aDados[nY][1] ) ) + '</AccountCode>'
		cXml	+= '       </AccountInformation>'
	EndIf
  	cXml	+= '      <InitialBalance>'+cValtoChar(ABS(aDados[nY][3]))+'</InitialBalance>'
  	cXml	+= '      <CreditValue>'+cValtoChar(ABS(aDados[nY][4]))+'</CreditValue>'
  	cXml	+= '      <DebitValue>'+cValtoChar(ABS(aDados[nY][5]))+'</DebitValue>'
  	cXml	+= '      <FinalBalance>'+cValtoChar(ABS(aDados[nY][6]))+'</FinalBalance>'
  	cXml	+= '    </PeriodGLBalanceInformation>'

	nCount++

	If nCount >= nMax .Or. ( (nY) >= Len(aDados) )
		cXml	+= '   </ListOfPeriodGLBalanceInformation> '
		cXml	+= '  </PeriodGlBalance> '
		cXml	+= ' </BusinessContent>	'
		nCount := 0

		FwIntegDef( 'CTBA012A', , , cXml, 'CTBA012A' )
	EndIf

Next nY

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
Ferase(cArqTmp+GetDBExtension())
FErase("cArqInd"+OrdBagExt())

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Funcao para a interacao com EAI recebimento da mensagem de financiamento da integracao
Protheus X PIMS

@author	Alvaro Camillo Neto
@since		14/11/2013
@version	MP11.90


/*/
//-------------------------------------------------------------------
STATIC FUNCTION IntegDef( cXml, cTypeTrans, cTypeMsg, cVersion, cTransac )

Local aRet := {}

aRet:= CTBI012A( cXml, cTypeTrans, cTypeMsg, cVersion, cTransac )

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Retorna xml a ser enviado Protheus X PIMS

@author	    Totvs
@since		06/03/2018

/*/
//-------------------------------------------------------------------

Function CT012Xml(dDataIni,dDataFim)

Local cArqTmp		:= ""
Local cContaDe 	    := ""
Local cContaAte	    := Replicate("Z",TamSX3("CT1_CONTA")[1])
Local cCCDe		    := ""
Local cCCAte		:= Replicate("Z",TamSX3("CTT_CUSTO")[1])
Local cItemDe	    := ""
Local cItemAte		:= Replicate("Z",TamSX3("CTD_ITEM")[1])
Local cClVlDe       := ""
Local cClVlAte		:= Replicate("Z",TamSX3("CTH_CLVL")[1])
Local cMoeda		:= "01"
Local cSaldo		:= '1'
Local lImpMov		:= .F.
Local lVlrZerado	:= .F.
Local lImpSint   	:= .F.
Local nCount		:= 0
Local cXml			:= ""
Local nMax			:= 10
Local cDataFim      := Substr(DtoS(dDataFim),1,4) + '-' + Substr(DtoS(dDataFim),5,2) + '-' +  Substr(DtoS(dDataFim),7,2)
Local aSetOfBook    := CTBSetOf("")
Local nDivide		:= 1
Local aDados		:= {}
Local nY			:= 0
Local nZ			:= 0 //Controle do FOR
Local lRet			:= .T.
Local aInteg        := {}
Local cVersion      := FWXX4Version('PERIODGLBALANCE') //Versão da Mensagem
Local cAliasSld     := '' //Alias de Saldo Contábil
Local aEntCtb       := CarrEntCtb() //array de verificação das entidades contabeis adicionais, com 5 posicoes

DBSelectArea("CT1")
CT1->(dbSetOrder(1))

If ExistBlock ("CT012INTEG")
	//O retorno do array deve conter todas as posicoes preenchidas, mesmo que nao alteradas.
	aInteg := ExecBlock("CT012Integ",.F.,.F.,{dDataIni,dDataFim,cContaDe,cContaAte,cCCDe,cCCAte,cMoeda,cSaldo})

	If ValType(aInteg) == "A" .and. Len(aInteg) == 8
		dDataIni	:= aInteg[1]
		dDataFim	:= aInteg[2]
		cContaDe	:= aInteg[3]
		cContaAte	:= aInteg[4]
		cCCDe		:= aInteg[5]
		cCCAte		:= aInteg[6]
		cMoeda		:= aInteg[7]
		cSaldo		:= aInteg[8]
	EndIf
EndIf

If cVersion = "2."
	//Retornando o Alias do Saldo Contábil
	cAliasSld := AliasSldCt()

	//Caso seja entidades Adicionais, compor saldo de forma diferente
	If (cAliasSld == 'CVY')
		SldCtbCVY(@cArqTmp, dDataIni, dDataFim, cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda, cSaldo, lVlrZerado)
	ElseIf cAliasSld == 'CTI'
		CTGerPlan( , , , .F. ,@cArqTmp,;
					dDataIni,dDataFim, cAliasSld,"",cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda,;
					cSaldo,aSetOfBook,,,,,;
					.F.,.T.,, "CTT",.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,,,,,,.T.,.T.)
	Else
		CTGerPlan( , , , .F. ,@cArqTmp,;
				dDataIni,dDataFim, cAliasSld,"",cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda,;
				cSaldo,aSetOfBook,,,,, !lImpMov,.T.,,"CT1",;
					.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,,,,,,;
					.F.,,,,,,,,,,,.F.,,,,,,,,)
	EndIf
Else
	CTGerPlan( , , , .F. ,@cArqTmp,;
			  dDataIni,dDataFim,"CT3","",cContaDe,cContaAte,cCCDe,cCCAte,cItemDe,cItemAte,cClVlDe,cClVlAte,cMoeda,;
			   cSaldo,aSetOfBook,,,,, !lImpMov,.T.,,"CT1",;
				.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,,,,,,;
				,,,,,,,,,,,.F.,,,,,,,,)
EndIf

cArqTmp->(dbGoTop())

aTMPStr := cArqTmp->(DBStruct())

While cArqTmp->( !Eof() )

	If cAliasSld == "CTI" .And. cArqTmp->TIPOCLVL<> "2"
		cArqTmp->(dbSkip())
		Loop		
	EndIf

	IF cArqTmp->SALDODEB == 0 .And. cArqTmp->SALDOCRD == 0
		cArqTmp->(dbSkip())
		Loop
	Endif

	If CT1->(MsSeek(xFilial("CT1") + cArqTmp->CONTA )) .And. Alltrim(CT1->CT1_INTP) != '1'
		cArqTmp->(dbSkip())
		Loop
	EndIf

	aAdd(aDados,{cArqTmp->CONTA,cArqTmp->CUSTO,cArqTmp->SALDOANT,cArqTmp->SALDOCRD,cArqTmp->SALDODEB,cArqTmp->SALDOATU})

	//Verifica se tem suporte a todas as entidades adicionais
	If (cVersion = "2.")
		//Adicionando Item Contábil e Centro de Custo
		AAdd(aDados[Len(aDados)], cArqTmp->ITEM)
		AAdd(aDados[Len(aDados)], cArqTmp->CLVL)

		//Percorrendo array de Entidades Adicionais
		For nY := 01 To Len(aEntCtb)
			//Verifica se possui campo
			If !(Type("cArqTmp->" + aEntCtb[nY, 02]) == "U")
				AAdd(aDados[Len(aDados)], cArqTmp->&(aEntCtb[nY, 02]))
				aEntCtb[nY, 01] := .T.
			Else
				AAdd(aDados[Len(aDados)], "")
			EndIf
		Next nY
	EndIf

	cArqTmp->(dbSkip())
EndDo

For nY := 1 to Len(aDados)

	If nCount == 0
		cXml	:= ''

		cXml := ' <BusinessEvent>'
		cXml +=     ' <Entity>PeriodGlBalance</Entity>'
		cXml +=     ' <Event>upsert</Event>'
		cXml += ' </BusinessEvent>'

		cXml	+= '<BusinessContent>'
		cXml	+= '  <PeriodGlBalance>'
		cXml	+= '    <SelectionInformation>'
		cXml	+= '      <ListOfRuleInformation>'
		cXml	+= '        <RuleInformation>'
		cXml	+= '          <RuleType></RuleType>'
		cXml	+= '          <InitialValue></InitialValue>'
		cXml	+= '          <FinalValue></FinalValue>'
		cXml	+= '        </RuleInformation>'
		cXml	+= '      </ListOfRuleInformation>'
		cXml	+= '    </SelectionInformation>'
		cXml	+= '    <ParametersInformation>'
		cXml	+= '      <PeriodInformation>'
		cXml	+= '        <GLPeriodDate>'+cDataFim+'</GLPeriodDate>'
		cXml	+= '      </PeriodInformation>'
		cXml	+= '      <FirstPart></FirstPart>'
		cXml	+= '    </ParametersInformation>'
		cXml	+= '    <ListOfPeriodGLBalanceInformation>'
   	EndIf

	cXml	+= '		<PeriodGLBalanceInformation>'
	cXml	+= '        <CompanyId>'+cEmpAnt+'</CompanyId>'
	cXml	+= '        <BranchId>'+cFilAnt+'</BranchId>'
	cXml	+= '        <CompanyInternalId>'+cEmpAnt+'|'+cFilAnt+'</CompanyInternalId>'
	//Verifica se tem suporte a todas as entidades adicionais
	If (cVersion = "2.")
		/**Entidades Contábeis**/
		//Conta Contábil
		If !(Empty(aDados[nY][01]))
			cXml	+= '          <AccountantAccountInternalId>' + cEmpAnt + "|" + FWxFilial("CT1") + "|" + _NoTags( AllTrim( aDados[nY][01] ) ) + '</AccountantAccountInternalId>'
			cXml	+= '          <AccountantAccountCode>' + _NoTags( AllTrim( aDados[nY][01] ) ) + '</AccountantAccountCode>'
		Else
			cXml	+= '          <AccountantAccountInternalId/>'
			cXml	+= '          <AccountantAccountCode/>'
		EndIf
		//Centro de Custo
		If !(Empty(aDados[nY][02]))
			cXml	+= '          <CostCenterInternalId>' + cEmpAnt + "|" + FWxFilial("CTT") + "|" + _NoTags( AllTrim( aDados[nY][02] ) ) + '</CostCenterInternalId>'
			cXml	+= '          <CostCenterCode>' + _NoTags( AllTrim( aDados[nY][02] ) ) + '</CostCenterCode>'
		Else
			cXml	+= '          <CostCenterInternalId/>'
			cXml	+= '          <CostCenterCode/>'
		EndIf
		//Item Contábil
		If !(Empty(aDados[nY][07]))
			cXml	+= '          <AccountantItemInternalId>' + cEmpAnt + "|" + FWxFilial("CTD") + "|" + _NoTags( AllTrim( aDados[nY][07] ) ) + '</AccountantItemInternalId>'
			cXml	+= '          <AccountantItemCode>' + _NoTags( AllTrim( aDados[nY][07] ) ) + '</AccountantItemCode>'
		Else
			cXml	+= '          <AccountantItemInternalId/>'
			cXml	+= '          <AccountantItemCode/>'
		EndIf
		//Classe de Valor
		If !(Empty(aDados[nY][08]))
			cXml	+= '          <ClassValueInternalId>' + cEmpAnt + "|" + FWxFilial("CTH") + "|" + _NoTags( AllTrim( aDados[nY][08] ) ) + '</ClassValueInternalId>'
			cXml	+= '          <ClassValueCode>' + _NoTags( AllTrim( aDados[nY][08] ) ) + '</ClassValueCode>'
		Else
			cXml	+= '          <ClassValueInternalId/>'
			cXml	+= '          <ClassValueCode/>'
		EndIf
		//Entidades Adicionais
		nEntAux := 05
		For nZ := 09 To Len(aDados[nY])
			If !(Empty(aDados[nY][nZ]))
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'InternalId>' + cEmpAnt + "|" + FWxFilial("CT0") + "|" + _NoTags( AllTrim( aDados[nY][nZ] ) ) + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'InternalId>'
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Code>' + _NoTags( AllTrim( aDados[nY][nZ] ) ) + '</ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Code>'
			Else
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'InternalId/>'
				cXml	+= '          <ManagerialAccountingEntity' + StrZero(nEntAux, 02) + 'Code/>'
			EndIf
			nEntAux ++ //Incrementando Entidade
		Next nZ
	Else
		cXml	+= '        <CostCenterInformation>'
		cXml	+= '          <CostCenterCode>' + _NoTags( AllTrim( aDados[nY][2] ) ) + '</CostCenterCode>'
		cXml	+= '        </CostCenterInformation>'
		cXml	+= '       <AccountInformation>'
		cXml	+= '        <AccountCode>' + _NoTags( AllTrim( aDados[nY][1] ) ) + '</AccountCode>'
		cXml	+= '       </AccountInformation>'
	EndIf
  	cXml	+= '      <InitialBalance>'+cValtoChar(ABS(aDados[nY][3]))+'</InitialBalance>'
  	cXml	+= '      <CreditValue>'+cValtoChar(ABS(aDados[nY][4]))+'</CreditValue>'
  	cXml	+= '      <DebitValue>'+cValtoChar(ABS(aDados[nY][5]))+'</DebitValue>'
  	cXml	+= '      <FinalBalance>'+cValtoChar(ABS(aDados[nY][6]))+'</FinalBalance>'
  	cXml	+= '    </PeriodGLBalanceInformation>'

	nCount++

	If nCount >= nMax .Or. ( (nY) >= Len(aDados) )
		cXml	+= '   </ListOfPeriodGLBalanceInformation> '
		cXml	+= '  </PeriodGlBalance> '
		cXml	+= ' </BusinessContent>	'
		nCount := 0
	EndIf

Next nY

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
Ferase(cArqTmp+GetDBExtension())
FErase("cArqInd"+OrdBagExt())

Return cXml

/**
	Carrega Array com informações dos Campos de Entidades Contábeis
**/
Static Function CarrEntCtb()
	Local aRetEnt := {} //Array de Retorno
	Local nQtdEnt := 05 //Quantidade de Entidades Adicionais
	Local nE      := 0 //Controle de FOR

	//Montando array com cammpos
	For nE := 01 To nQtdEnt
		//Compondo Campos
		AAdd(aRetEnt, {.F., "CODENT" + StrZero(nE + 04, 02)})
	Next nE

Return aRetEnt

/**
	Retorna o Alias para composição do Saldo
**/
Static Function AliasSldCt()
    Local aArea     := GetArea() //Reservando a Área
    Local cAliasSld := '' //Alias para Saldo Contábil
    Local nQtdEnt   := 0 //Quantidade de Entidades Contábeis

    //Verifica a Quantidade de Entidades Contábeis
    nQtdEnt := CtbQtdEntd()

    //Caso seja maior que 04, o Saldo virá pelo Cubo (CVX e CVY)
    If (nQtdEnt > 04)
        cAliasSld := 'CVY'
    Else
        //Compondo a Quantidade de Entidades a partir das que movimentam Saldo
        nQtdEnt := 01 //Inicia-se com 01 pois Plano de Contas é entidade principal
        /**  Verificando quais movimentam **/
        If (CtbMovSaldo("CTT")) //Centro de Custo
            nQtdEnt ++
        EndIf
        If (CtbMovSaldo("CTD")) //Item Contábil
            nQtdEnt ++
        EndIf
        If (CtbMovSaldo("CTH")) //Classe de Valor
            nQtdEnt ++
        EndIf

        /** A partir da Quantidade de de Entidades definir o Alias */
        Do Case
            Case nQtdEnt == 01 //Plano de Contas
                cAliasSld := 'CT7'
            Case nQtdEnt == 02 //Centro de Custo
                cAliasSld := 'CT3'
            Case nQtdEnt == 03 //Item Contábil
                cAliasSld := 'CT4'
            Case nQtdEnt == 04 //Classe de Valor
                cAliasSld := 'CTI'
            OtherWise
                cAliasSld := 'CT7'
        EndCase
    EndIf

    RestArea(aArea) //Restaurando a Área
Return cAliasSld

Static Function SldCtbCVY(cArqTmp, dDataIni,dDataFim, cContaDe, cContaAte, cCCDe, cCCAte, cItemDe, cItemAte, cClVlDe, cClVlAte, cMoeda, cSaldo, lVlrZerado)
	Local cSQL    := '' //Consulta SQL
	Local nQtdEnt := CtbQtdEntd() //Quantidade de Entidades Contábeis
	Local nX      := 0 //Controle de For
	Local aDbStr  := {} //Struct da Tabela
	Local aTamVlr := TamSX3('CT2_VALOR') //Tamanho para Campos Numéricos

	Private _oTempTable := Nil //Tabela Temporária

	cArqTmp := "cArqTmp"

	//Compondo Consulta SQL
	cSQL += "SELECT" + CRLF
	cSQL += "	CVX.CVX_CONFIG CONFIG," + CRLF
	cSQL += "	CVX.CVX_NIV01 CONTA," + CRLF
	cSQL += "	CVX.CVX_NIV02 CUSTO," + CRLF
	cSQL += "	CVX.CVX_NIV03 ITEM," + CRLF
	cSQL += "	CVX.CVX_NIV04 CLVL," + CRLF

	//Entidades Adicionais + CRLF
	For nX := 05 To nQtdEnt
		cSQL += "	CVX.CVX_NIV" + StrZero(nX, 02) + " CODENT" + StrZero(nX, 02) + "," + CRLF
	Next nX

	cSQL += "	SUM(CVX.CVX_SLDDEB) SALDODEB," + CRLF
	cSQL += "	SUM(CVX.CVX_SLDCRD) SALDOCRD," + CRLF
	cSQL += "	(" + CRLF
	cSQL += "		SELECT" + CRLF
	cSQL += "			ISNULL(SUM(CVXA.CVX_SLDDEB), 0)" + CRLF
	cSQL += "		FROM" + CRLF
	cSQL += "			" + RetSQLName('CVX') + " CVXA" + CRLF
	cSQL += "		WHERE" + CRLF
	cSQL += "			CVXA.CVX_FILIAL = '" + FWxFilial('CVX') + "' AND" + CRLF
	cSQL += "			CVXA.CVX_NIV01 = CVX.CVX_NIV01 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV02 = CVX.CVX_NIV02 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV03 = CVX.CVX_NIV03 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV04 = CVX.CVX_NIV04 AND" + CRLF

	//Entidades Adicionais
	For nX := 05 To nQtdEnt
		cSQL += "			CVXA.CVX_NIV" + StrZero(nX, 02) + " = CVX.CVX_NIV" + StrZero(nX, 02) + " AND" + CRLF
	Next nX

	cSQL += "			CVXA.CVX_CONFIG = CVX.CVX_CONFIG AND" + CRLF
	cSQL += "			CVXA.CVX_MOEDA = '" + cMoeda + "' AND" + CRLF
	cSQL += "			CVXA.CVX_TPSALD = '" + cSaldo + "' AND" + CRLF
	cSQL += "			CVXA.D_E_L_E_T_ = ' '" + CRLF
	cSQL += "	) SALDOANTDB," + CRLF
	cSQL += "	(" + CRLF
	cSQL += "		SELECT" + CRLF
	cSQL += "			ISNULL(SUM(CVXA.CVX_SLDCRD), 0)" + CRLF
	cSQL += "		FROM" + CRLF
	cSQL += "			" + RetSQLName('CVX') + " CVXA" + CRLF
	cSQL += "		WHERE" + CRLF
	cSQL += "			CVXA.CVX_FILIAL = '" + FWxFilial('CVX') + "' AND" + CRLF
	cSQL += "			CVXA.CVX_NIV01 = CVX.CVX_NIV01 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV02 = CVX.CVX_NIV02 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV03 = CVX.CVX_NIV03 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV04 = CVX.CVX_NIV04 AND" + CRLF

	//Entidades Adicionais
	For nX := 05 To nQtdEnt
		cSQL += "			CVXA.CVX_NIV" + StrZero(nX, 02) + " = CVX.CVX_NIV" + StrZero(nX, 02) + " AND" + CRLF
	Next nX

	cSQL += "			CVXA.CVX_CONFIG = CVX.CVX_CONFIG AND" + CRLF
	cSQL += "			CVXA.CVX_MOEDA = '" + cMoeda + "' AND" + CRLF
	cSQL += "			CVXA.CVX_TPSALD = '" + cSaldo + "' AND" + CRLF
	cSQL += "			CVXA.D_E_L_E_T_ = ' '" + CRLF
	cSQL += "	) SALDOANTCR," + CRLF
	cSQL += "	(" + CRLF
	cSQL += "		SELECT" + CRLF
	cSQL += "			ISNULL(SUM(CVXA.CVX_SLDDEB - CVXA.CVX_SLDCRD), 0)" + CRLF
	cSQL += "		FROM" + CRLF
	cSQL += "			" + RetSQLName('CVX') + " CVXA" + CRLF
	cSQL += "		WHERE" + CRLF
	cSQL += "			CVXA.CVX_FILIAL = '" + FWxFilial('CVX') + "' AND" + CRLF
	cSQL += "			CVXA.CVX_NIV01 = CVX.CVX_NIV01 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV02 = CVX.CVX_NIV02 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV03 = CVX.CVX_NIV03 AND" + CRLF
	cSQL += "			CVXA.CVX_NIV04 = CVX.CVX_NIV04 AND" + CRLF

	//Entidades Adicionais
	For nX := 05 To nQtdEnt
		cSQL += "			CVXA.CVX_NIV" + StrZero(nX, 02) + " = CVX.CVX_NIV" + StrZero(nX, 02) + " AND" + CRLF
	Next nX

	cSQL += "			CVXA.CVX_CONFIG = CVX.CVX_CONFIG AND" + CRLF
	cSQL += "			CVXA.CVX_MOEDA = '" + cMoeda + "' AND" + CRLF
	cSQL += "			CVXA.CVX_TPSALD = '" + cSaldo + "' AND" + CRLF
	cSQL += "			CVXA.D_E_L_E_T_ = ' '" + CRLF
	cSQL += "	) SALDOANT," + CRLF
	cSQL += "	SUM(CVX.CVX_SLDDEB - CVX.CVX_SLDCRD) SALDOATU" + CRLF
	cSQL += "FROM" + CRLF
	cSQL += "	" + RetSQLName('CVX') + " CVX" + CRLF
	cSQL += "WHERE" + CRLF
	cSQL += "	CVX.CVX_FILIAL = '" + FWxFilial('CVX') + "' AND" + CRLF
	cSQL += "	CVX_DATA BETWEEN '" + DToS(dDataIni) + "' AND '" + DToS(dDataFim) + "' AND" + CRLF
	cSQL += "	CVX_CONFIG = '" + StrZero(nQtdEnt, 02) + "' AND" + CRLF
	cSQL += "	CVX.CVX_MOEDA = '" + cMoeda + "' AND" + CRLF
	cSQL += "	CVX.CVX_TPSALD = '" + cSaldo + "' AND" + CRLF

	//Entidades Contábbeis
	cSQL += "	CVX_NIV01 BETWEEN '" + cContaDe + "' AND '" + cContaAte + "' AND" + CRLF
	cSQL += "	CVX_NIV02 BETWEEN '" + cCCDe + "' AND '" + cCCAte + "' AND" + CRLF
	cSQL += "	CVX_NIV03 BETWEEN '" + cItemDe + "' AND '" + cItemAte + "' AND" + CRLF
	cSQL += "	CVX_NIV04 BETWEEN '" + cClVlDe + "' AND '" + cClVlAte + "' AND" + CRLF

	cSQL += "	CVX.D_E_L_E_T_ = ' '" + CRLF
	cSQL += "GROUP BY" + CRLF
	cSQL += "	CVX.CVX_CONFIG," + CRLF
	cSQL += "	CVX.CVX_NIV01," + CRLF
	cSQL += "	CVX.CVX_NIV02," + CRLF
	cSQL += "	CVX.CVX_NIV03," + CRLF
	cSQL += "	CVX.CVX_NIV04," + CRLF

	//Entidades Adicionais
	For nX := 05 To nQtdEnt
		cSQL += "	CVX.CVX_NIV" + StrZero(nX, 02) + IIf(nX < nQtdEnt, ",", "") + CRLF
	Next nX

	//Valores Zerados
	If !(lVlrZerado)
		cSQL += "HAVING" + CRLF
		cSQL += "	(SUM(CVX.CVX_SLDDEB) <> 0 OR" + CRLF
		cSQL += "	SUM(CVX.CVX_SLDCRD) <> 0)" + CRLF
	EndIf

	cSQL += "ORDER BY CVX_NIV01" + CRLF

	//Fechando Area caso aberta
	If (Select("TMP") > 0)
		TMP->(DBCloseArea())
	EndIf

	//Abrindo Area pela consulta SQL
	PlsQuery(cSQL, "TMP")

	//Definindo Tamanho Campos Numéricos
	aDbStr := TMP->(DBStruct())
	For nX := 01 To Len(aDbStr)
		//Verificando Tipo do Campo
		If (aDbStr[nX, 02] == "N")
			//Alterando
			TcSetField("TMP", aDbStr[nX, 01], "N", aTamVlr[01], aTamVlr[02])
			aDbStr[nX, 03] := aTamVlr[01] //Tamanho
			aDbStr[nX, 04] := aTamVlr[02] //Decimais
		EndIf
	Next nX

	//Criando Temporária
	_oTempTable := FWTemporaryTable():New(cArqTmp)
	_oTempTable:SetFields( aDbStr )
	_oTempTable:AddIndex("1", {"CONTA"})
	//------------------
	//Criação da tabela
	//------------------
	_oTempTable:Create()
	cTableNam1 := _oTempTable:GetRealName()

	//Alimentando Temporária
	While !(TMP->(EOF()))
		If (RecLock(cArqTmp, .T.))
			For nX := 01 To Len(aDbStr)
				(cArqTmp)->&(aDbStr[nX, 01]) := TMP->&(aDbStr[nX, 01])
			Next nX
			(cArqTmp)->(MsUnlock())
		EndIf
		//Pulando registro
		TMP->(DBSkip())
	EndDo

Return