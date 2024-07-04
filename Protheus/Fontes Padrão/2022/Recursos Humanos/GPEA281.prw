#Include 'Protheus.ch'
#Include "FWMVCDef.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Função     ³ GPEA281                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Descriçao  ³ Rotina de cadastro de plano de saúde para cálculo por agrupamento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe    ³ GPEA281()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Uso        ³ GPEA281()                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³                 ATUALIZACOES SOFRIDAS DESDE A CONSTRUÇAO INICIAL.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function GPEA281()
	Local oMBrowse
	Local cFiltraRh

	oMBrowse := FWMBrowse():New()

	oMBrowse:SetAlias("SM3")
	oMBrowse:SetDescription("Manutenção de Cheques") //"Manutenção de Cheques"

	oMBrowse:AddLegend("SM3->M3_IMPRESS=='C'", 'RED', "Cancelado") //"Cancelado"
	oMBrowse:AddLegend("SM3->M3_IMPRESS=='S'", 'GREEN', "Impresso") //"Impresso"

	oMBrowse:SetMenuDef( 'GPEA281' )
	//oMBrowse:ForceQuitButton() //"Incluir botao de sair" 

	//Inicializa o filtro utilizando a funcao FilBrowse

	cFiltraRh := CHKRH("GPEA281","SM3","1")
	oMBrowse:SetFilterDefault( cFiltraRh )

	oMBrowse:DisableDetails()

	oMBrowse:Activate()
Return

/*/{Protheus.doc}MenuDef
Criacao do Menu do Browse
@author Gabriel de Souza Almeida
@since 03/11/2015
@version P12
@return array, aRotina
/*/
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"         ACTION "PESQBRW"          OPERATION 1 ACCESS 0 DISABLE MENU //'Pesquisar' 
	ADD OPTION aRotina TITLE "Visualizar"        ACTION "VIEWDEF.GPEA281"  OPERATION 2 ACCESS 0              //'Visualizar'
	ADD OPTION aRotina TITLE "Manutenção"        ACTION "VIEWDEF.GPEA281"  OPERATION 4 ACCESS 0              //'Manutenção'
	
Return aRotina


/*/{Protheus.doc}ModelDef
Regras de modelagem da gravação
@author Gabriel de Souza Almeida
@since 03/11/2015
@version P12
@return objeto, oModel
/*/
Static Function ModelDef()

	Local oModel
	Local oStructSM3
	
	// Criacao do Objeto de Modelagem de dados
	oModel := MPFormModel():New("GPEA281",/*bPreValid*/,{ |oModel| fPosValid(oModel) },/*bCommiM040*/,/*bCancel*/)
	oModel:SetDescription( "Manutenção de Cheques" ) //"Manutenção de Cheques"
    
	//Dados do Cheque - SM3 (Cheques)
	oStructSM3 := FWFormStruct(1,"SM3", { |cCampo| fSM3Struct(cCampo) })
	oModel:AddFields("GPEA281_MSM3", NIL, oStructSM3)
	oModel:SetPrimaryKey({ 'M3_FILIAL', 'M3_BANCO','M3_AGENCIA' ,'M3_CONTA','M3_NUMCHEQ'})
	oModel:GetModel( "GPEA281_MSM3" ):SetDescription("Dados do Cheque") //"Manutenção de Cheques"
	
	oModel:SetActivate()
	
Return(oModel)

/*/{Protheus.doc}ViewDef
Regras de Interface
@author Gabriel de Souza Almeida
@since 03/11/2015
@version P12
@return objeto, oView
/*/
Static Function ViewDef()
	Local oView 
	Local oModel
	Local oStructSM3

	//Vincular o View ao Model
	oModel := FWLoadModel("GPEA281")

	//Criacao da Interface
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Dados do Cheque - SM3 (Cheques)
	oStructSM3 := FWFormStruct(2,"SM3", { |cCampo| fSM3Struct(cCampo) })
	oStructSM3:SetNoFolder()
	oView:AddField("GPEA281_VSM3", oStructSM3, "GPEA281_MSM3" )

	oView:SetCloseOnOk({|| .T. })//Apos COMMIT gravacao fecha a tela
Return oView

/*/{Protheus.doc} fSM3Struct
Carregamento dos campos da estrutura
@author Gabriel de Souza Almeida
@since 03/11/2015
@version P12
@param cCampo, varchar, Campo a ser carregado
@return lRet
/*/
Static Function fSM3Struct( cCampo )
	Local lRet := .T.
	Local lIntgTRB := SuperGetMv('MV_INTGTRB',.F.)
	
	cCampo := AllTrim( cCampo )
	If !lIntgTRB .And. cCampo $ 'M3_CREDITO*M3_DEBITO*M3_ITEMC*M3_CODHIST' 
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} fPosValid
Cancelamento do Cheque na SEF
@author Gabriel de Souza Almeida
@since 03/11/2015
@version P12
@param oModel, objeto, Modelo Atual
@return lRet
/*/
Static Function fPosValid( oModel )
	Local lRet := .T.
	Local cStatus := oModel:GetValue("GPEA281_MSM3","M3_IMPRESS")
	Local cBanco
	Local cAgencia
	Local cConta
	Local cNum
	
	If SM3->M3_IMPRESS <> 'C' .And. cStatus == 'C'
		If MsgYesNo("Deseja realmente cancelar o cheque?","Cancelamento de Cheque") //Confirmação - "Cancelamento de Cheque"
			cBanco := oModel:GetValue("GPEA281_MSM3","M3_BANCO")
			cAgencia := oModel:GetValue("GPEA281_MSM3","M3_AGENCIA")
			cConta := oModel:GetValue("GPEA281_MSM3","M3_CONTA")
			cNum := oModel:GetValue("GPEA281_MSM3","M3_NUMCHEQ")
			
			DbSelectArea("SEF")
			SEF->(DbSetOrder(1)) //EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
			
			If SEF->(MsSeek(xFilial("SEF")+cBanco+cAgencia+cConta+cNum))
				RecLock("SEF",.F.)
				SEF->EF_IMPRESS := cStatus
				SEF->(MsUnlock())
			EndIf
		Else
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} IntegDef
Chama rotina de integração - Mensagem Única
@author Gabriel de Souza Almeida
@since 03/11/2015
@version P12
@return aRet
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage, cVersion )
	Local aRet := {}
	aRet:= GPEI281 ( cXml, nTypeTrans, cTypeMessage, cVersion )
Return aRet
