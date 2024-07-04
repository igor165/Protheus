#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA230.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA230

Histórico de integração com o TOTVS Connect Bank

@author  Edson Borges de Melo
@since   15/09/2020
@Version 12.1.027
/*/
//-------------------------------------------------------------------
Function FINA230()

	Local aArea As Array
	Local oBrowse as Object
	Private aRot as Array

	If !AliasInDic("FWO")
		Help("",1,"NODICTCB",,STR0007,1,0)	//Atualize o dicionário de dados para usar as funcionalidades do TCB.
		Return
	EndIf
	
	aArea := GetArea()
	
	if !Pergunte('FINA230')
		return
	Endif
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("FWO")
	oBrowse:SetDescription(STR0001)  // "Monitor de integração - TOTVS Connect Bank"
	if Empty(MV_PAR03)
		oBrowse:SetFilterDefault("FWO->FWO_DTENV >= MV_PAR01 .and. FWO->FWO_DTENV <= MV_PAR02 ")
	else
		oBrowse:SetFilterDefault("FWO->FWO_DTENV >= MV_PAR01 .and. FWO->FWO_DTENV <= MV_PAR02 .and. FWO->FWO_USUAR == MV_PAR03")
	EndIf
	
	oBrowse:AddLegend( "FWO->FWO_STATUS == '0'", "BLUE",	STR0003 )	// "Transmitido"
	oBrowse:AddLegend( "FWO->FWO_STATUS == '1'", "RED" 	,	STR0002 )  	// "Falha"
	oBrowse:AddLegend( "FWO->FWO_STATUS == '2'", "GREEN",	STR0006 )	// "Processado"
	
	oBrowse:Activate()
	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@Author  Edson Borges de Melo
@since   15/09/2020
@Version 12.1.027
@Return
/*/
//-------------------------------------------------------------------
Static Function MenuDef() as Array

	Local aRotina as Array
	
	aRotina := {}
	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.FINA230" OPERATION 2 ACCESS 0	// "Visualizar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@Author  Edson Borges de Melo
@since   15/09/2020
@Version 12.1.027
@Return
/*/
//-------------------------------------------------------------------
Static Function ViewDef() as Object

	Local oView as Object
	Local oModel as Object
	Local oStruFNM as Object

	oModel 	:= FWLoadModel( 'FINA230' ) 	
	oStruFNM 	:= FWFormStruct( 2, 'FWO' ) 

	// Cria o objeto de View 
	oView := FWFormView():New() 
	// Define qual o Modelo de dados será utilizado na View 
	oView:SetModel( oModel ) 
	// Adiciona no nosso View um controle do tipo formulário  
	oView:AddField( 'VIEWFWO', oStruFNM, 'FWOMASTER' )
	// Criar um "box" horizontal para receber algum elemento da view 
	oView:CreateHorizontalBox( 'TELA' , 100 ) 
	// Relaciona o identificador (ID) da View com o "box" para exibição 
	oView:SetOwnerView( 'VIEWFWO', 'TELA' ) 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@Author  Edson Borges de Melo
@since   15/09/2020
@Version 12.1.027
@Return
/*/
//-------------------------------------------------------------------
Static Function ModelDef() as Object
	Local oStruFWO As Object 
	Local oModel   As Object
	
	oStruFWO := FWFormStruct(1, "FWO") 
	oModel   := MPFormModel():New("FINA230")
	
	oModel:AddFields("FWOMASTER", /*cOwner*/, oStruFWO)
	oModel:SetPrimaryKey({'FWO_LOTE'})
	oModel:SetDescription(STR0001)
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} F230GRAVA
Função para gravação do registro histórico da FWO

@Author  Edson Borges de Melo
@since   15/09/2020
@Version 12.1.027
@Return
/*/
//-------------------------------------------------------------------

Function F230GRAVA(cNumBor As Char, cFile As Char, cUserID As Char, nIdRet As Numeric, cCodRet As Char, cJson As Char)
	Local lNovoReg As Logical
	Local cIdTCB   As Char
	Local nCodret  As Numeric
	
	Default cNumBor := ""
	Default cFile   := ""
	Default cUserID := ""
	Default nIdRet  := 0
	Default cCodRet := ""
	Default cJson   := ""

	//Inicializa variáveis.	
	lNovoReg := .T.
	cIdTCB   := cValToChar(nIdRet)
	nCodRet  := 0
	
	If !Empty(cCodRet)
		nCodRet := Val(cCodRet)
	EndIf
	
	If !Empty(cIdTCB)
		FWO->(dbSetOrder(2))
		lNovoReg := !FWO->(dbSeek(FWxFilial("FWO") + cIdTCB)) 
	EndIf
	
	Reclock("FWO", lNovoReg)	
	FWO->FWO_FILIAL	 := FWxFilial("FWO")
	FWO->FWO_LOTE 	 := GetSxeNum("FWO", "FWO_LOTE")
	FWO->FWO_NUMBOR	 := cNumBor
	FWO->FWO_ARQUIV	 := cFile
	FWO->FWO_DTENV	 := Date()
	FWO->FWO_HRENV	 := Time()
	FWO->FWO_USUAR	 := cUserID
	FWO->FWO_IDTCB	 := cIdTCB
	FWO->FWO_CODRET  := nCodRet
	FWO->FWO_STATUS  := "1"
	FWO->FWO_JSONRT  := cJson
	
	If cCodRet == "200"
		FWO->FWO_STATUS := "0"
	EndIf	
	
	FWO->(MsUnlock())
	FWO->(ConfirmSX8())
Return

