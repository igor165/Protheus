#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TECA530.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECA530
Cadastro de motivos de manutenção da agenda.

@sample 	TECA530()

@author	Danilo Dias
@since		21/11/2012
@version	P11.80
/*/
//-------------------------------------------------------------------
Function TECA530()

Local oBrowse	:= nil

Private aRotina 	:= MenuDef()	// Monta menu da Browse
Private cCadastro	:= STR0001		// "Motivos de Manutenção da Agenda"

oBrowse := FWMBrowse():New()

oBrowse:SetAlias( "ABN" )
oBrowse:SetDescription( cCadastro )
oBrowse:Activate()	//Ativa tela principal (Browse)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Função para montar o menu principal da rotina.

@sample 	MenuDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.80
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action "VIEWDEF.TECA530" 	OPERATION MODEL_OPERATION_VIEW 		ACCESS 0	//"Visualizar"
ADD OPTION aRotina Title STR0003 Action "VIEWDEF.TECA530" 	OPERATION MODEL_OPERATION_INSERT 	ACCESS 0	//"Incluir"
ADD OPTION aRotina Title STR0004 Action "VIEWDEF.TECA530" 	OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0	//"Alterar"
ADD OPTION aRotina Title STR0005 Action "VIEWDEF.TECA530" 	OPERATION MODEL_OPERATION_DELETE 	ACCESS 0	//"Excluir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função para definir o model da rotina.

@sample 	ModelDef()

@author	Danilo Dias
@since		21/11/2012
@version	P11.80
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= nil
Local oStruABN	:= nil
Local aUniqueLine	:= { "ABN_CODIGO" }

If TYPE("cCadastro") == 'U'
	cCadastro	:= STR0001
EndIf

oModel 		:= MPFormModel():New( "TECA530", , { |oModel| AT530Vld( oModel ) } )	//Cria um objeto de Modelo de dados baseado no fonte informado
oStruABN		:= FWFormStruct( 1, "ABN" )			//Cria as estruturas a serem usadas na View

oStruABN:SetProperty( 'ABN_SERVIC', MODEL_FIELD_WHEN, { || AT530When( oModel, 'ABN_SERVIC' ) } )

oModel:AddFields( "ABNMASTER", , oStruABN )		//Adiciona um controle do tipo formulário
oModel:GetModel("ABNMASTER"):SetDescription( cCadastro )
oModel:SetPrimaryKey( { "ABN_FILIAL", "ABN_CODIGO" } )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função para criar a visualização da rotina.

@sample 	ViewDef()

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel		:= nil
Local oStruABN	:= nil
Local oView		:= nil

oModel		:= FWLoadModel( "TECA530" )	//Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
oStruABN	:= FWFormStruct( 2, "ABN" )	//Cria as estruturas a serem usadas na View
oView 		:= FWFormView():New()		//Cria o objeto de View

oView:SetModel( oModel )										//Define qual Modelo de dados será utilizado
oView:AddField( "VIEW_ABN", oStruABN, "ABNMASTER" )		//Adiciona no nosso View um controle do tipo formulário
oView:CreateHorizontalBox( "MASTER", 100 )				//Cria um box superior para exibir a Master
oView:SetOwnerView( "VIEW_ABN", "MASTER" )				//Relaciona o identificador (ID) da View com o "box" para exibição

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} AT530Vld
Validação final.

@sample 	AT530Vld( oModel )

@param		oModel		Modelo de dados.
@return	lRet		Indica se os dados são válidos ou não.

@author	Danilo Dias
@since		30/05/2012
@version	P12
/*/
//-------------------------------------------------------------------
Function AT530Vld( oModel )

Local aArea	:= GetArea()
Local cTipo 	:= oModel:GetValue( 'ABNMASTER', 'ABN_TIPO' )
Local cServ	:= oModel:GetValue( 'ABNMASTER', 'ABN_SERVIC' )
Local lRet		:= .T.

If ( cTipo != '04' ) .And. ( !Empty( cServ ) )
	lRet := .F.
	Help( ' ', 1, 'AT530Vld', , STR0006, 1, 0 )	//'Apenas o tipo 04 pode ter um serviço definido.'
EndIf

If cTipo == '09' .AND. ( !FindFunction("TecABRComp") .OR. !TecABRComp() )
	lRet := .F.
	Help( ' ', 1, 'AT530Vld', , STR0007, 1, 0 ) //"Não é possível cadastrar o tipo Compensação sem o campo ABR_COMPEN configurado."
EndIf

RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AT530When
Validação final.

@sample 	AT530When( cCampo )

@param		oModel		Modelo de dados.
			cCampo		Campo a ser avaliado.
@return	lRet		Indica se habilita ou não o campo.

@author	Danilo Dias
@since		27/02/2013
@version	P12
/*/
//-------------------------------------------------------------------
Function AT530When( oModel, cCampo )

Local lRet := .T.

Do Case

	//Habilita o campo ABN_SERVIC apenas para o tipo Hora Extra (04)
	Case cCampo == 'ABN_SERVIC'
		If ( FwFldGet('ABN_TIPO') == '04' )
			lRet := .T.
		Else
			If ( !Empty( oModel:GetValue( 'ABNMASTER', 'ABN_SERVIC' ) ) )
				oModel:LoadValue( 'ABNMASTER', 'ABN_SERVIC', '' )
			EndIf
			lRet := .F.
		EndIf
		
End Case

Return lRet