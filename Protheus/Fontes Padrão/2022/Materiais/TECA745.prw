#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA745.CH'

//Status do orçamento de serviços
#DEFINE DEF_TFJ_ATIVO     "1"			//TFJ_STATUS Contrato Gerado
#DEFINE DEF_TFJ_EMREVISAO "2"			//TFJ_STATUS Em Revisão
#DEFINE DEF_TFJ_REVISADO  "3"			//TFJ_STATUS Revisado
#DEFINE DEF_TFJ_AGDAPROVA "4"			//TFJ_STATUS Aguardando Aprovação
#DEFINE DEF_TFJ_ENCERRADO "5"			//TFJ_STATUS Encerrado
#DEFINE DEF_TFJ_CANCELADO "6"			//TFJ_STATUS Cancelado
#DEFINE DEF_TFJ_INATIVO   "7"			//TFJ_STATUS Inativo

Static aTabPrc := {}
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA745
Browse orçamento simplificado

@since		27/02/2018
@author	matheus.raimundo
/*/
//------------------------------------------------------------------------------
Function TECA745(lAutomato, bSemTela)
Local oBrw
Local cFiltro := "TFJ_ORCSIM == '1' .AND. EMPTY(TFJ_CODVIS)"+IIF(TFJ->(ColumnPos("TFJ_RESTEC"))>0," .AND. TFJ_RESTEC <> '2'","")

Default lAutomato := .F.
Default bSemTela := {|| .T.}

aTabPrc := {}
If !lAutomato
	oBrw := FwMBrowse():New()
	oBrw:SetAlias( 'TFJ' )
	oBrw:SetDescription( OEmToAnsi( STR0001) ) //STR0001 //'Orçamento para Serviços'
	
	oBrw:AddLegend("EMPTY(TFJ->TFJ_CONTRT) .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_INATIVO + "'","BR_VERDE",STR0002) //STR0002 //"Orçamento em Aberto"
	oBrw:AddLegend("!EMPTY(TFJ->TFJ_CONTRT) .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_INATIVO + "' .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_REVISADO + "'","BR_VERMELHO",STR0003) //STR0003 //"Contrato Gerado"
	oBrw:AddLegend("!EMPTY(TFJ->TFJ_CONTRT) .AND. TFJ->TFJ_STATUS != '" + DEF_TFJ_INATIVO + "' .AND. TFJ->TFJ_STATUS == '" + DEF_TFJ_REVISADO + "'","BR_BRANCO",STR0004) //STR0004 //"Contrato Revisado"
	oBrw:AddLegend("TFJ->TFJ_STATUS == '" + DEF_TFJ_INATIVO + "'","BR_CANCEL",STR0005) //STR0005 //"Orçamento Inativo"
	
	oBrw:SetFilterDefault(cFiltro)
	
	oBrw:Activate()
Else
	EVal(bSemTela)
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
Construção do Menu

@since		27/02/2018
@author	matheus.raimundo
/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := {}

ADD OPTION aMenu Title STR0006 Action 'a745VisOrc(TFJ->TFJ_CODTAB,TFJ->TFJ_TABREV)' OPERATION 2 ACCESS 0 	//"Visualizar" //'Visualizar'
ADD OPTION aMenu Title STR0007 Action 'a745IncOrc()' OPERATION 3 ACCESS 0	//"Incluir" //'Incluir'
ADD OPTION aMenu Title STR0008 Action 'a745AltOrc(TFJ->TFJ_CONTRT,TFJ->TFJ_CODTAB,TFJ->TFJ_TABREV,TFJ->TFJ_STATUS)' OPERATION 4 ACCESS 0 	//"Alterar" //'Alterar'
ADD OPTION aMenu Title STR0009  Action 'a745ExcOrc(TFJ->TFJ_CONTRT,TFJ->TFJ_CODTAB,TFJ->TFJ_TABREV)' OPERATION 5 ACCESS 0 	//"Excluir" //'Excluir'
ADD OPTION aMenu Title STR0010  Action 'At745Ctr(TFJ->TFJ_CODIGO,TFJ->TFJ_CONREV,TFJ->TFJ_CONTRT,TFJ->TFJ_STATUS)' OPERATION 5 ACCESS 0 	//"Assistente de contrato" //'Assistente de contrato'
ADD OPTION aMenu Title STR0011 Action 'At745Load("At745VisCt", TFJ->TFJ_CONTRT, TFJ->TFJ_CONREV)' OPERATION 2 ACCESS 0 	//"Visualizar Contrato" //'Visualizar Contrato'
ADD OPTION aMenu Title STR0012 Action 'At745Imp(TFJ->TFJ_STATUS)' OPERATION 2 ACCESS 0 	//"Impressão do Orçamento" //'Impressão do Orçamento'
ADD OPTION aMenu Title STR0013 Action 'AT745Ativ(TFJ->TFJ_CODIGO,TFJ->TFJ_STATUS, TFJ->TFJ_CONTRT)' OPERATION 4 ACCESS 0 	//"Inativar / Ativar" //'Ativar / Inativar'
ADD OPTION aMenu Title STR0014 Action 'At745ImpVs()' OPERATION 3 ACCESS 0 	 //'Importar vistoria'

aAdd( aMenu, { STR0015,"At745Legen()", 0 , 2,,.F.} )	//STR0015 //"Legenda"

Return aMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} TCFA040Leg()
Legendas do Orçamento Simplificado

@author mateus.barbosa
@since 27/02/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function At745Legen()

Local aLegenda	:= {}
Local aSvKeys	:= GetKeys()
	
aLegenda := {;
				{ "BR_VERDE",OemToAnsi(STR0002) } ,;	//STR0002 //"Orçamento em Aberto"
				{ "BR_VERMELHO",OemToAnsi(STR0003) } ,; 	//STR0003 //"Contrato Gerado"
				{ "BR_BRANCO",OemToAnsi(STR0004) } ,; 	//STR0004 //"Contrato Revisado"
				{ "BR_CANCEL",OemToAnsi(STR0005) } ; 	//STR0005 //"Orçamento Inativo"
			}
	
BrwLegenda( STR0016,"", aLegenda ) //STR0016 //"Legendas Orçamentos Simplificados"

RestKeys( aSvKeys )

Return( NIL )

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745Ctr
Chama o Assistente de Contratos

@since		27/02/2018
@author	matheus.raimundo
/*/
//------------------------------------------------------------------------------

Function At745Ctr(cCodigo, cConRev, cContrt, cStatus, lAuto, aDados)
Local aAreaTFJ := TFJ->(GetArea())
Default cContrt := ""

If AT745VerIn(cStatus)
	If Empty(cContrt)
		TECA850(cCodigo, ,cConRev, ,lAuto ,aDados ,)
	Else
		DbSelectArea("CN9")
		CN9->(DbSetOrder(7)) //CN9_FILIAL+CN9_NUMERO+CN9_SITUAC
		IF CN9->( MSSEEK( xFilial("CN9")+cContrt+'02' ) )	
			RestArea(aAreaTFJ)
			TECA850(cCodigo, cContrt, cConRev,,lAuto,aDados,.T.)
		Else
			Help(,,"AT745NTCONTRT",,STR0017,1,0)	 //'Orçamento com contrato gerado, não poderá ser gerado novamente'
		EndIf
	EndIf
EndIf

RestArea(aAreaTFJ)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} a745IncOrc
    Inclusão de orçamento
@since		27/02/2018       
@version	P12
@author	matheus.raimundo
/*/
//------------------------------------------------------------------------------
Function a745IncOrc(lAutomato, bSemTela)
Local cModOrc := ""
Local lConfirm := .F.
Local lRet := .T.
Local lConPrc := .T.
Local lOrcPrc	  	:= SuperGetMv("MV_ORCPRC",,.F.)
Local lGSRH := GSGetIns("RH")
Default lAutomato := .F.
Default bSemTela := {|| .T.}

If SuperGetMV('MV_ORCSIMP',, '2') == '1'

	If SuperGetMV('MV_ORCPRC')
		cModOrc := "TECA740F"
		If !lAutomato  .AND. lGSRH
			lConPrc := Conpad1( NIL, NIL, NIL, "TV6" )
		EndIf
		If lConPrc  .And. At740fchk( TV6->TV6_NUMERO, TV6->TV6_REVISA )
			a745SetTab( TV6->TV6_NUMERO, TV6->TV6_REVISA )
		Else
			lRet := .F.
		EndIf	
	Else
		cModOrc := "TECA740"	
	EndIf
	
	If lRet
		lRet := TEC745View(cModOrc,MODEL_OPERATION_INSERT,lAutomato, bSemTela)
	EndIf											
Else
	Help(,,"AT745NORC",,STR0026,1,0) //'Para a inclusão de orçamento simplificado é necessário ativar o parâmetro MV_ORCSIMP'
	lRet := .F.
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} a745SetTab
    Atribui a tabela de precificação selecionada
@since		27/02/2018       
@version	P12
@author	matheus.raimundo
/*/
//------------------------------------------------------------------------------
Function a745SetTab(cTab, cRevisa)
aTabPrc := {}
Aadd(aTabPrc, cTab)
Aadd(aTabPrc,cRevisa)
Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} a745GetTab
    Retorna a tabela de precificação selecionada 
@since		27/02/2018       
@version	P12
@author	matheus.raimundo
/*/
//------------------------------------------------------------------------------
Function a745GetTab()

Return aTabPrc

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745VisCt
    Visualiza o Contrato do Orçamento Selecionado
@since		27/02/2018       
@version	P12
@author	mateus.barbosa
/*/
//------------------------------------------------------------------------------
Static Function At745VisCt(cCodTFJ, cCONREV)
Local aAreaTFJ := TFJ->(GetArea())

DbSelectArea("CN9")
CN9->(DbSetOrder(1)) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA

If CN9->( DbSeek( xFilial("CN9")+ cCodTFJ + cCONREV ) )
	Inclui := .F.
	Altera := .F.
	CN300Visua()
	Inclui := nil
	Altera := nil
Else
	Help( ' ', 1, "At745VisCt", , STR0027, 1, 0 )	// STR0027 //"Orçamento de Serviços ou contrato do GCT não localizado"
EndIf

RestArea(aAreaTFJ)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At745Load
    Exibe MsgRun antes da chamada da rotina
@since		27/02/2018       
@version	P12
@author	mateus.barbosa
/*/
//------------------------------------------------------------------------------
Function At745Load(cFunName, uParam1, uParam2, uParam3, uParam4)
Local bBlock := &( "{ |a,b,c,d| " + cFunName + "(a,b,c,d) }" )

Return MsgRun(STR0029,STR0028,{|| Eval( bBlock, uParam1, uParam2, uParam3, uParam4) } ) // STR0029##STR0028 //"Aguarde" //"Montando os componentes visuais..."

//------------------------------------------------------------------------------
/*/{Protheus.doc} a745AltOrc
    Rotina de alteração do orçamento simplificado
@sample	Menudef() 
@since		28/02/2018       
@version	P12
/*/
//------------------------------------------------------------------------------
Function a745AltOrc(cContrato, cCodTab, cTabRev, cStatus, lAutomato, bSemtela)
Local lRet := .F.
Local lOk := .T.    
Default lAutomato := .F.
Default bSemtela := {|| .T.}
If AT745VerIn(cStatus)

	If Empty(cContrato) 
		If SuperGetMV('MV_ORCPRC')
			a745SetTab(cCodTab, cTabRev) 
			cModOrc := "TECA740F"	
			If Empty(cCodTab)
				Help(,,"AT745ORCPRC",,STR0030,1,0) //'Orçamento gerado sem precificação, desative o parâmetro MV_ORCPRC para prosseguir com a alteração'
				lOk := .F.
			EndIf	
		ElseIf !SuperGetMV('MV_ORCPRC') 
			cModOrc := "TECA740"	
			If  !Empty(cCodTab)
				Help(,,"AT745ORCPRC",,STR0031,1,0) //'Orçamento gerado com precificação, ative o parâmetro MV_ORCPRC para prosseguir com a alteração'
				lOk := .F.
			EndIf	
		EndIf	
		
		If lOk
			lRet := TEC745View(cModOrc,MODEL_OPERATION_UPDATE,lAutomato,bSemtela)					
		EndIf
	Else
		Help(,,"AT745NTDEL",,STR0032,1,0) //'Orçamento com contrato gerado, não poderá ser alterado'
	EndIf
EndIf

Return lRet 


//------------------------------------------------------------------------------
/*/{Protheus.doc} TEC745View
    Executa a view de um determinado modelo
@sample	Menudef() 
@since		28/02/2018       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function TEC745View(cModOrc,nOperation, lAutomato, bSemTela)
Local lRet := .F.
Local oModel
Default lAutomato := .F.
Default bSemTela := {||.T.}
If !lAutomato
	MsgRun(STR0029,STR0028,{||  lRet := ( FWExecView( STR0033, "VIEWDEF." + cModOrc, nOperation, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // 'Orçamento Serviços' //"Montando os componentes visuais..." //"Aguarde" //'Orçamento de serviços'
											{||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ ,,,) == 0 )})
Else
	oModel := FwLoadModel(cModOrc)
	oModel:SetOperation( nOperation )
	lRet := oModel:Activate()
	lRet := lRet .And. EVal( bSemTela, oModel)
	If nOperation == MODEL_OPERATION_DELETE
		lRet := lRet .And. FwFormCommit(oModel)
	Else
		lRet := lRet .And. oModel:VldData() .And. oModel:CommitData()
	EndIf
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} a745VisOrc
    Rotina de visualização do orçamento simplificado
@sample	Menudef() 
@since		28/02/2018       
@version	P12
/*/
//------------------------------------------------------------------------------
Function a745VisOrc(cCodtab, cTabRev)
Local lRet := .F.
Local cModOrc  := ""

If SuperGetMV('MV_ORCPRC')
	a745SetTab(cCodtab, cTabRev)
	cModOrc := "TECA740F"
Else
	cModOrc := "TECA740"
EndIf	

lRet := TEC745View(cModOrc,MODEL_OPERATION_VIEW)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} a745ExcOrc
    Rotina de exclusão do orçamento simplificado
@sample	Menudef() 
@since		28/02/2018       
@version	P12
/*/
//------------------------------------------------------------------------------
Function a745ExcOrc(cContrato,cCodTab,cTabRev,lAutomato,bSemTela)
Local lRet := .F.
Local lOk := .T.
Default lAutomato := .F.
Default bSemTela := {||.T.}

If Empty(cContrato)
	If SuperGetMV('MV_ORCPRC')
		cModOrc := "TECA740F"
		If Empty(cCodTab)
			Help(,,"AT745ORCPRC",,STR0034,1,0) //'Orçamento gerado sem precificação, desative o parâmetro MV_ORCPRC para prosseguir com a exclusão'
			lOk := .F.
		EndIf	
		a745SetTab(cCodTab,cTabRev)
	Else	
		cModOrc := "TECA740"
		If  !Empty(cCodTab)
			Help(,,"AT745ORCPRC",,STR0031,1,0) //'Orçamento gerado com precificação, ative o parâmetro MV_ORCPRC para prosseguir com a alteração'
			lOk := .F.
		EndIf	
	EndIf
	If lOk 
		lRet := TEC745View(cModOrc,MODEL_OPERATION_DELETE,lAutomato,bSemTela)
	EndIf		
Else
	Help(,,"AT745NTDEL",,STR0035,1,0) //'Orçamento com contrato gerado, não podera ser excluido'
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At745Imp()
Impressão do Orçamento

@author mateus.barbosa
@since 06/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function At745Imp(cStatus)

If AT745VerIn(cStatus)
	If FindFunction("U_FT600IMP")
		lRetorno := U_FT600IMP()
		If	ValType(lRetorno) == "L"
			lRetorno := .T.
		EndIf
	Else
		MsgAlert(STR0036)  //"Para utilizar essa opção é necessário compilar o fonte FT600IMP ou possuir a função U_FT600IMP() no RPO."
		//Para utilizar essa opção é necessário compilar o fonte FT600IMP ou possuir a função U_FT600IMP() no RPO.
	EndIf
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AT745Ativ()
Ativa / Inativa o Orçamento

@author mateus.barbosa
@since 20/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function AT745Ativ(cCodigo, cStatus, cContrato)
Local lRet := .F.
Local cMsg := ""

If EMPTY(cContrato) .AND. cStatus == DEF_TFJ_INATIVO
	lRet := AT745AltSt(cCodigo, DEF_TFJ_ATIVO)
	cMsg := STR0037 //ativado //"ativado"
ElseIf EMPTY(cContrato) .AND. cStatus == DEF_TFJ_ATIVO
	lRet := AT745AltSt(cCodigo, DEF_TFJ_INATIVO)
	cMsg := STR0038 //inativado //"inativado"
Else
	Help( ,, 'AT745INATIV',, STR0039 + " " + STR0040, 1, 0 )
EndIf

If lRet
	MsgInfo(STR0041 + " " + ALLTRIM(cCodigo) +; //"Orçamento"
				 " " + cMsg + STR0042, STR0047 ) //"Orçamento" ## " com sucesso" //" com sucesso."
EndIf
 
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT745AltSt()
Altera o status de um Orçamento

@author mateus.barbosa
@since 20/03/2018

@param cCodOrc, string, código do Orçamento que será alterado (TFJ_CODIGO)
@param cNewStatus, string, novo status do Orçamento

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AT745AltSt(cCodOrc, cNewStatus)
Local aArea := GetArea()
Local lRet := .F.

DbSelectArea("TFJ")
DbSetOrder(1)
If ( lRet := TFJ->(MsSeek(xFilial("TFJ")+cCodOrc)) )
	RecLock("TFJ", .F.)
		TFJ->TFJ_STATUS := cNewStatus
	MsUnlock()
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT745VerIn()
Verifica se o status de um Orçamento é Inativo

@author mateus.barbosa
@since 20/03/2018

@param cStatus, string, Status atual do Orçamento
@param lShowMsg, bool, indica se deve exibir o Help de Orçamento Inativo

@return lRet, bool, se retornar .F. indica que o Orçamento está inativo

@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AT745VerIn(cStatus, lShowMsg)
Local lRet := .T.
Default lShowMsg := .T.

If !( lRet := (cStatus != DEF_TFJ_INATIVO) ) .AND. lShowMsg
	 Help(,,"AT745ORCINAT",,STR0043+; //'Operação não permitida para Orçamentos Inativos.'
	 		STR0044,1,0) //' Utilize a opção "Ativar / Inativar " para ativar este Orçamento'
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT745Simp()
Retorna se um Orçamento é simplificado

@author mateus.barbosa
@since 20/03/2018

@param cCodTFJ, string, código da TFJ que deve ser pesquisado

@return lRet, bool, se retornar .T. indica que o Orçamento é simplificado

@version 1.0
/*/
//-------------------------------------------------------------------
Function AT745Simp(cCodTFJ)
Local lRet := .F.
Local aArea := GetArea()
Local aAreaTFJ := TFJ->(GetArea())

DbSelectArea("TFJ")
DbSetOrder(1)

lRet := MsSeek(xFilial("TFJ") + cCodTFJ) .AND. (TFJ->TFJ_ORCSIM == '1')

RestArea(aAreaTFJ)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AT745Simp()
Retorna se um Contrato foi gerado de um Orçamento Simplificado

@author mateus.barbosa
@since 23/03/2018

@param cNumContr, string, número do contrato
@param cRevContr, string, revisão do contrato

@return lRet, bool, se retornar .T. indica que foi gerado de um Orçamento simplificado

@version 1.0
/*/
//-------------------------------------------------------------------
Function AT745Contr(cNumContr, cRevContr)
Local lRet := .F.
Local aArea := GetArea()
Local aAreaTFJ := TFJ->(GetArea())

Default cNumContr := ""

If !EMPTY(cNumContr)
	DbSelectArea("TFJ")
	DbSetOrder(5)
	lRet := MsSeek(xFilial("TFJ") + cNumContr + cRevContr) .AND. AT745Simp(TFJ->TFJ_CODIGO)
EndIf

RestArea(aAreaTFJ)
RestArea(aArea)
Return lRet





/*/{Protheus.doc} ()
Seta os valores de referência para os itens agrupadores do orçamento

@author diego.bezerra
@since 22/03/2018

@version 1.0
/*/

function AT745RefProd(oModel)
Local oModOrc := oModel:GetModel('TFJ_REFER')
Local cRet			:= ""
Local nI			:= 0
Local nJ			:= 0
Local nCtemp		:= 0
Local nPos			:= 0	
Local aAux 	    	:= {}	// Array auxiliar com itens únicos
Local aItens	    := {}	// Array com nome dos itens agrupadores
Local aRefs 		:= { { 'TFJ_GRPRH', 'TFJ_ITEMRH', }, ;
			     	{ 'TFJ_GRPMI', 'TFJ_ITEMMI', }, ;
			     	{ 'TFJ_GRPMC', 'TFJ_ITEMMC',}, ;
			     	{ 'TFJ_GRPLE', 'TFJ_ITEMLE',} }	



For nI := 1 to Len ( aRefs )
// Populando o array aItens com os itens escolhidos nos agrupadores
	aAdd(aItens, {oModOrc:GetValue(aRefs[nI][1])})

// Populando o array aAux sem itens repetidos
	nPos := ASCAN(aAux, {|x| x[1] == aItens[nI][1]})
	
	If( nPos == 0 )
		aAdd(aAux, {aItens[nI][1]})
	EndIf
	
Next nI

For nI := 1 to Len ( aAux )
	
	For nJ := 1 to Len ( aItens )
		// Agrupando os itens e salvando no modelo, conforme ordenado no aAux
		If aAux[nI][1] == aItens[nJ][1]
			// Formatando o valor corretamente para o formato aceito no modelo
			nCtemp := STRZERO(nI)
			cRet := SUBSTR(nCtemp,Len(nCtemp)-1,Len(nCtemp))
			oModOrc:SetValue(aRefs[nj][2], cRet )
		EndIf
		
	Next nJ
	
Next nI

Return 


Function At745ImpVs()
Local lOrcSimp	 	:= SuperGetMV('MV_ORCSIMP',, '2') == '1'

If lOrcSimp
	A600ConVis()
Else
	Help(,,"AT745NORCIMP",,STR0046,1,0) //'O parâmetro MV_ORCSIMP está desativado, não será possível importar vistórias'
EndIf	


Return 
