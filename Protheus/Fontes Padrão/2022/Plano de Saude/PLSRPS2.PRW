#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TOTVS.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA813
Funcao para abrir o Credenciamento do Candidato
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSARPS2(cCodRDA,lAutoma)

Local aCoors := FWGetDialogSize( oMainWnd )
Local oPanelUp	:= NIL
Local oFWLayer	:= NIL
Local oPanelDown	:= NIL
Local oBrowseUp		:= NIL
Local oBrowseDown	:= NIL
Local oRelac		:= NIL
Local oDialog		:= NIL
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 //Para fins de automação

if !lAutoma
	DEFINE MsDialog oDialog Title 'Locais de atendimento - ' + cCodRDA From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDialog, .F., .T. )

	// Define Painel Superior
	oFWLayer:AddLine( 'UP', 40, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )

	// Painel Inferior
	oFWLayer:AddLine( 'DOWN', 60, .F. )
	oFWLayer:AddCollumn( 'TUDO' , 100, .T., 'DOWN' )
	oPanelDown := oFWLayer:GetColPanel( 'TUDO', 'DOWN' ) 
Endif
// FWmBrowse Superior Candidatos
oBrowseUp:= FWmBrowse():New()
// Aqui se associa o browse ao componente de tela
oBrowseUp:SetOwner( oPanelUp )
oBrowseUp:SetDescription( "Locais de Atendimento" )
oBrowseUp:SetAlias( "BB8" )
// Define de onde virao os botoes deste browse
oBrowseUp:SetMenuDef( 'PLSRPS2' )
oBrowseUp:SetProfileID( '1' )
oBrowseUp:ForceQuitButton()

//Cria Legenda do Browse
oBrowseUp:DisableDetails()
oBrowseUp:setfilterDefault("BB8_CODIGO == '" + cCodRDA + "'")

iif(!lAutoma, oBrowseUp:Activate(), '')

// FWmBrowse Inferior Especialidades
oBrowseDown:= FWMBrowse():New()
oBrowseDown:SetOwner( oPanelDown )
oBrowseDown:SetDescription( 'Vínculos' )
oBrowseDown:SetAlias( "B84" )
// Referencia vazia para que nao exiba nenhum botao
oBrowseDown:SetMenuDef( 'PLSRPS3' )
oBrowseDown:SetProfileID( '2' )

oBrowseDown:DisableDetails()
oBrowseDown:SetAmbiente(.F.)
oBrowseDown:SetWalkThru(.F.)

iif(!lAutoma, oBrowseDown:Activate(), '')


// Relacionamento entre os Paineis
oRelac:= FWBrwRelation():New()
oRelac:AddRelation( oBrowseUp , oBrowseDown , { 	{ 'B84_FILIAL', 'xFilial( "B84" )' },;
													   	{ 'B84_CODIGO', 'BB8_CODIGO'		},;
													   	{ 'B84_CODLOC', 'BB8_CODLOC'		}	} )
oRelac:Activate()

if !lAutoma
	Activate MsDialog oDialog Center
Endif 	
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Add Option aRotina Title 'Visualizar' Action 'VIEWDEF.PLSRPS2' Operation 2 Access 0
Add Option aRotina Title 'Alterar'    Action 'VIEWDEF.PLSRPS2' Operation 4 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel // Modelo de dados construído
Local oStrBB8:= FWFormStruct(1,'BB8', { |cCampo| PLSRPS2FI(cCampo) } )// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que iráconsiderar

oModel := MPFormModel():New( 'PLSRPS2', , , {|oModel| PGRVRPSLB8(oModel) } ) // Cria o objeto do Modelo de Dados e insere a funçao de pós-validação

oModel:addFields('MasterBB8',/*cOwner*/,oStrBB8)  // Adiciona ao modelo um componente de formulário

oModel:GetModel('MasterBB8'):SetDescription('Locais de Atendimento') // Adiciona a descrição do Modelo de Dados

oModel:SetPrimaryKey( {"BB8_FILIAL", "BB8_CODIGO", "BB8_CODLOC"} )

oStrBB8:SetProperty( 'BB8_CPFCGC' , MODEL_FIELD_VALID, { || PlVdCCBB8(oModel) } )
oStrBB8:SetProperty( 'BB8_CPFCGC' , MODEL_FIELD_OBRIGAT, .t. )

Return oModel // Retorna o Modelo de dados


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef() // Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado

Local oView  // Interface de visualização construída
Local oModel := FWLoadModel( 'PLSRPS2' ) // Cria as estruturas a serem usadas na View
Local oStrBB8:= FWFormStruct(2, 'BB8', { |cCampo| PLSRPS2FI(cCampo) } )

oView := FWFormView():New() // Cria o objeto de View

oView:SetModel(oModel)		// Define qual Modelo de dados será utilizado

oView:AddField('ViewBB8' , oStrBB8,'MasterBB8' ) // Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)

oView:CreateHorizontalBox( 'SUPERIOR' , 100 ) // Cria um "box" horizontal para receber cada elemento da view e Associa à Aba Correspondente

oStrBB8:SetProperty( 'BB8_TIPLOG', MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_DESLOC', MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_END'   , MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_NR_END', MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_COMEND', MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_CODMUN', MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_MUN'   , MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_EST'   , MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetProperty( 'BB8_BAIRRO', MVC_VIEW_CANCHANGE, .F.)
oStrBB8:SetNoFolder()

oView:SetOwnerView('ViewBB8','SUPERIOR') // Relaciona o identificador (ID) da View com o "box" para exibição

Return oView // Retorna o objeto de View criado


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSRPS2FI
Tratamento para ajustar os campos a ser utilizados da tabela B9Q.
@author Oscar Zanin
@since 02/10/2018
@version P12
/*/
//-------------------------------------------------------------------
Function PLSRPS2FI(cCampo)

Local lRet	:= .F.

If cCampo == "BB8_LOCAL" 
	lRet := .T.
EndIf

If cCampo == "BB8_DESLOC" 
	lRet := .T.
EndIf

If cCampo == "BB8_CEP   " 
	lRet := .T.
EndIf

If cCampo == "BB8_TIPLOG" 
	lRet := .T.
EndIf

If cCampo == "BB8_END   " 
	lRet := .T.
EndIf

If cCampo == "BB8_NR_END" 
	lRet := .T.
EndIf

If cCampo == "BB8_COMEND" 
	lRet := .T.
EndIf

If cCampo == "BB8_CODMUN" 
	lRet := .T.
EndIf

If cCampo == "BB8_MUN   " 
	lRet := .T.
EndIf

If cCampo == "BB8_EST   " 
	lRet := .T.
EndIf

If cCampo == "BB8_BAIRRO" 
	lRet := .T.
EndIf

If cCampo == "BB8_CNES  " 
	lRet := .T.
EndIf

If cCampo == "BB8_CPFCGC" 
	lRet := .T.
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PGRVRPSLB8
Função de commit do Model. (Tabela BB8)
Grava o modelo e verifica se deve gravar as tabelas de geração de RPS, caso
deva gravar, realiza a gravação
@author Oscar Zanin
@since 04/10/2018
@version P12
/*/
//-------------------------------------------------------------------
function PGRVRPSLB8(oModel)

Local aAlt	:= {}
Local cTpArq	:= ""
Local oBB8	:= oModel:getModel("MasterBB8")
Local aVerifica := {"BB8_CODMUN", "BB8_EST", "BB8_CNES", "BB8_CPFCGC" }
Local nI	:= 1
Local aChvAnt	  := { "DEFAULT", "DEFAULT", "DEFAULT" }

if oBB8:IsFieldUpdated("BB8_CPFCGC")
	aChvAnt[1] := BB8->BB8_CPFCGC
endif	
If oBB8:IsFieldUpdated("BB8_CNES")
	aChvAnt[2] := BB8->BB8_CNES
endif	
If oBB8:IsFieldUpdated("BB8_CODMUN")
	aChvAnt[3] := BB8->BB8_CODMUN
endIf

FWFormCommit(oModel)

If BAU->BAU_GERRPS == "1"
	For nI := 1 To Len(aVerifica)
		If oBB8:IsFieldUpdated(aVerifica[nI])
			aadd(aAlt, aVerifica[nI])
		EndIf
	Next
	
	If Len(aAlt) > 0
		If BAU->BAU_ENVRPS $ "1,3"
			cTpArq := "1"
		Elseif BAU->BAU_ENVRPS $ " ,0"
			cTpArq := "0"
		EndIf
		PLSRPSALT(PLSINTPAD(), BAU->(Recno()), BB8->(Recno()), 0, aAlt, cTpArq, aChvAnt)
	EndIf

	If cTpArq == "1" .AND. BAU->BAU_ENVRPS == "1"
		BAU->(RecLock("BAU", .F.))
			BAU->BAU_ENVRPS := "3"
		BAU->(MsUnLock())
	endIf	
	
	PLRP5clr()
EndIf

return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} PlVdCCBB8
Realiza a validação do CPF/CNPJ digitado pelo usuário na BB8, evitando dados incorretos.
@author Renan Martins
@since 02/2018
@version P12
/*/
//-------------------------------------------------------------------
static function PlVdCCBB8(oModel)
Local lRet := .T.
Local cCampo := Alltrim(oModel:GetValue('MasterBB8', 'BB8_CPFCGC'))

if empty(cCampo)
	Help( ,, 'Help',, 'Informe o CPF/CGC!', 1, 0 )
	lRet := .f.
else
	lRet := CGC(cCampo)
endif	

Return lRet
