#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FINA985.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA985 
Cadastro dos complementos dos impostos - tabela FKE

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function FINA985 ()
	Local oBrowse As Object
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FKE')
	oBrowse:SetDescription(STR0001) //'Complemento do imposto'
	oBrowse:Activate()
	
	FWFreeObj(oBrowse)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef 
Definição de menu da rotina de cadastro dos complementos dos impostos

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function MenuDef() As Array
	Local aRotina As Array

	aRotina := {}
	ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.FINA985' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FINA985' OPERATION 3 ACCESS 0 //'Incluir' 
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FINA985' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FINA985' OPERATION 5 ACCESS 0 //'Excluir' 
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FINA985' OPERATION 8 ACCESS 0 //'Imprimir'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef 
Definição do modelo de dados da rotina de cadastro dos complementos 
dos impostos

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function ModelDef() As Object
	Local oStruFKE As Object
	Local oModel As Object
	
	oStruFKE := FWFormStruct( 1, 'FKE', /*bAvalCampo*/,/*lViewUsado*/ )
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('FKEMODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	
	//Gatilho no campo FKE_TPIMP - Se imposto for IR a aplicacao deve ser na base (provisorio para o projeto FINA406, reavaliar na descida do REINF)
	oStruFKE:AddTrigger( "FKE_TPIMP", "FKE_APLICA", {|| ValidIR(oModel) }  , {|oModel| "1" } )
	
	//Bloqueia a edição do campo de Tipo de Imposto quando o dicionario não estiver atualizado (mantem o legado)
	oStruFKE:SetProperty( "FKE_TPIMP", MODEL_FIELD_WHEN, {||VldEdImp()} )
	
	//Inicializador padrão a ser executado quando o dicionario não estiver atualizado (mantem o legado)
	oStruFKE:SetProperty( "FKE_TPIMP", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, IF(VldEdImp(),'','"INSS"')))
	
	//Validação para não permitir selecionar a carteira RECEBER ou AMBOS caso o tipo de imposto seja diferente de INSS
	oStruFKE:SetProperty('FKE_CARTEI' ,MODEL_FIELD_VALID, {||( VldCart(oModel) )})
	
	//Bloqueia a edição do campo de APLICACAO o imposto for IR
	oStruFKE:SetProperty( 'FKE_APLICA' , MODEL_FIELD_WHEN, {|| !ValidIR(oModel) })
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'FKEMASTER', /*cOwner*/, oStruFKE, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	oModel:SetActivate ()
	
	oModel:SetPrimaryKey( { "FKE_FILIAL", "FKE_IDFKE" } )
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0007 ) //'Cadastro de Complemento do Imposto'
	
	oModel:GetModel( 'FKEMASTER' ):SetDescription(STR0001 ) //"Complemento do Imposto"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef 
Definição da view da rotina de cadastro dos complementos 
dos impostos

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oStruFKE As Object
	Local oView As Object
	
	oModel := FWLoadModel( 'FINA985' )
	oStruFKE := FWFormStruct( 2, 'FKE' )
	
	oStruFKE:SetProperty( 'FKE_IDFKE'  , MVC_VIEW_ORDEM, '02' )
	oStruFKE:SetProperty( 'FKE_DESCR'  , MVC_VIEW_ORDEM, '03' )
	oStruFKE:SetProperty( 'FKE_TPIMP'  , MVC_VIEW_ORDEM, '04' )
	oStruFKE:SetProperty( 'FKE_DEDACR' , MVC_VIEW_ORDEM, '05' )
	oStruFKE:SetProperty( 'FKE_APLICA' , MVC_VIEW_ORDEM, '06' )
	oStruFKE:SetProperty( 'FKE_CARTEI' , MVC_VIEW_ORDEM, '07' )
	oStruFKE:SetProperty( 'FKE_CALCUL' , MVC_VIEW_ORDEM, '08' )
	oStruFKE:SetProperty( 'FKE_PERCEN' , MVC_VIEW_ORDEM, '09' )
	oStruFKE:SetProperty( 'FKE_TPATRB' , MVC_VIEW_ORDEM, '10' )
	oStruFKE:SetProperty( 'FKE_DESATR' , MVC_VIEW_ORDEM, '11' )
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_FKE', oStruFKE, 'FKEMASTER' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F985VldATRB 
Função que valida o FKE_TPATRB para usar apenas os tipos
que podem ser por base ou por valor

@return lRet

@author Pâmela Bernardo
@since 15/05/2017
@version P11
/*/
//-------------------------------------------------------------------
Function F985VldATRB() As Logical
	Local lRet As Logical 
	Local cFiltro As Char
	
	lRet := .T.
	cFiltro := F985FilImp()
	
	If Alltrim(M->FKE_TPIMP) == "INSS"
	
		If M->FKE_APLICA == "1"  
			If !(M->FKE_TPATRB $ cFiltro) // BASE
				lRet := .F.
				Help(" ",1,"TPACAOINVAL")
			Endif
		Else
			If !(M->FKE_TPATRB $ cFiltro)    
		   		lRet := .F.
				Help(" ",1,"TPACAOINVAL")
			Endif                                                                                                                                                                             	
		EndIf	

	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F985FilImp 
Filtro da consulta SXB 0D do campo FKE_TPATRB para trazer somente os tipos
que podem ser por base ou por valor

@return cFiltro, retorna os códigos a serem exibidos no campo FKE_TPATRB

@author Karen Honda
@since 28/07/2016
@version P11
/*/
//-------------------------------------------------------------------
Function F985FilImp() As Char
	Local cFiltro As Char
	
	cFiltro := ""
	If Alltrim(M->FKE_TPIMP) == "INSS"
		If M->FKE_APLICA == "1" // BASE
			cFiltro := "001   |002   |003   |006   "
		Else
			cFiltro := "004   |005   |006   |007   |008   |009   "
		EndIf
	ElseIf Alltrim(M->FKE_TPIMP) == "IRF"
		cFiltro := "013   |"
	Else
		cFiltro := "001   |002   |003   |004   |005   |006   |007   |008   |009   "
	EndIf

	If Existblock("FA985TPA",)
		cFiltro += ExecBlock("FA985TPA",.F.,.F.)
	EndIf
Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} F985Fil0C 
Função que determina quais opções serão apresentadas na consulta do campo FKE_TPIMP
*Utilizado na consulta padrão (SXB) "SX50C"

@return cRet, opções válidas para o campo FKE_TPIMP

@author Fabio Casagrande Lima
@since 01/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Function F985Fil0C() As Char
	Local cRet As Char	
	cRet := "INSS  |IRF   |"	
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldEdImp
Define a liberacao da edição do campo FKE_TPIMP
Obs: Funcao provisoria para o projeto FINA406 (Autonomos Datasul). 
	 Quando descer o REINF da inovacao deve ser substituida pela 
	 funcao "VldFKF".

@return lRet

@author Fabio Casagrande Lima
@since 02/12/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldEdImp() As Logical
	Local lRet As Logical
	Local aAreaSX5 As Array

	lRet := .F.
	aAreaSX5 := SX5->( GetArea() )

	//Busca a consulta padrao do campo Tipo de Imposto
	If GetSX3Cache("FKE_TPIMP", "X3_F3") == "SX50C "  
		lRet := .T.
	Endif

	RestArea(aAreaSX5)
	FwFreeArray(aAreaSX5)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F985VldTp 
Função que valida o FKE_TPIMP para usar apenas os tipos
de impostos validos na consulta padrão "SX50C"

@return lRet

@author Fabio Casagrande Lima
@since 18/02/2018
@version P11
/*/
//-------------------------------------------------------------------
Function F985VldTp() As Logical
	Local lRet As Logical
	Local cFiltro As Char
	
	lRet := .T.
	cFiltro := F985Fil0C()
	
	If Alltrim(M->FKE_CARTEI) == "1" .Or. Empty(M->FKE_CARTEI) //Pagar
		If !M->FKE_TPIMP $ cFiltro
			lRet := .F.
			HELP(' ',1,"FA985CARTP",,STR0010,2,0,,,,,,{STR0009}) //"O tipo de imposto selecionado não está habilitado para a carteira a pagar." ## "Revise a carteira ou o tipo de imposto selecionado." 
		Endif
	Else
		If ALLTRIM(M->FKE_TPIMP) <> "INSS"
			lRet := .F.
			HELP(' ',1,"FA985CARTR" ,,STR0008,2,0,,,,,, {STR0009})	//"O tipo de imposto selecionado não está habilitado para a carteira a receber." ## "Revise a carteira ou o tipo de imposto selecionado."
		Endif
	EndIf
	
Return lRet
	
//-------------------------------------------------------------------
/*/{Protheus.doc} VldCart
Função que valida se a carteira (FKE_CARTEI) pode ser usada para o
tipo de imposto selecionado (FKE_TPIMP)

@author Fabio Casagrande Lima
@since 01/03/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function VldCart( oModel As Object ) As logical
	Local lRet   As Logical
	Local cCart  As Char
	Local cTpImp As Char
	
	lRet   := .T.
	cCart  := oModel:GetValue('FKEMASTER', "FKE_CARTEI")
	cTpImp := oModel:GetValue('FKEMASTER', "FKE_TPIMP")
	
	If cCart <> "1" .And. cTpImp <> "INSS  "
		lRet  := .F. 
		HELP(' ',1,"FA985CARTR" ,,STR0008,2,0,,,,,, {STR0009}) //"O tipo de imposto selecionado não está habilitado para a carteira a receber." ## "Revise a carteira ou o tipo de imposto selecionado."
	EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidIR
Verifica se o imposto selecionado é IR.
Obs: Funcao provisoria para o projeto FINA406 (Autonomos Datasul). 
	 Ja que a deducao de pensao alimenticia so deve ser aplicada
	 na base. Rever futuramente.

@author Fabio Casagrande Lima 
@since 02/12/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ValidIR(oModel) As Logical
	Local lRet As Logical
	Local cTpImp As Character

	lRet   := .F.
	cTpImp := oModel:GetValue('FKEMASTER', "FKE_TPIMP")
	
	If Alltrim(cTpImp) == "IRF"
		lRet := .T.
	EndIf 
	
Return lRet