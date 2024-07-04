#INCLUDE "FISA141.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄ¿±±
±±³Fun‡…o    ³ FISA141   ³ Autor ³    ³ Data ³ 11.05.18 ³           ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄ´±±
±±³Descri‡…o ³ cADASTRO fORMA lIVRE- Venezuela			   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FISA141()							                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA141()

Local oBrowse := Nil

oBrowse := FWMBrowse():New()
oBrowse:SetAlias( "F3L" )
oBrowse:SetDescription( STR0001 )//"Cadastro de Cadastro de Forma Livre
oBrowse:Activate()

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro de Forma Livre
/*/
//--------------------------------------------------------------------------
Static Function ModelDef()
Local oStruF3L := FwFormStruct( 1, "F3L", {|cCampo|!AllTrim(cCampo)+"|" $ "F3L_FILIAL|"} )
Local oModel   := MpFormModel():New( "FISA141", , { |oModel| ValidForm( oModel ) } )

oModel:AddFields( "MODEL_F3L", /*cOwner*/, oStruF3L )
oModel:SetDescription( STR0001 ) //"Cadastro de Cadastro de Forma Livre
oModel:SetPrimaryKey({"F3L_FILIAL","F3L_FILUSO","F3_NUMINI"})
oStruF3L:SetProperty( "F3L_FILUSO", MODEL_FIELD_WHEN, {|| oModel:GetOperation() == MODEL_OPERATION_INSERT })


Return oModel
//-----------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro de Cadastro de Forma Livre

/*/
//-----------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FwLoadModel( "FISA141" )
Local oStruF0F := FwFormStruct( 2, "F3L", {|cCampo|!AllTrim(cCampo)+"|" $ "F3L_FILIAL|"} )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_F3L", oStruF0F, "MODEL_F3L" )

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro de Cadastro de Forma Livre

/*/
//----------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.FISA141" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.FISA141" OPERATION 3 ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.FISA141" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.FISA141" OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina
//----------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas
/*/
//----------------------------------------------------------------
Static Function ValidForm(oModel)
Local lRet := .T.
Local nOperation := oModel:GetOperation()
Local cCodFil    := oModel:GetValue( "MODEL_F3L", "F3L_FILUSO" )+ oModel:GetValue( "MODEL_F3L", "F3L_NUMINI" )

If (nOperation == MODEL_OPERATION_INSERT)
	DbSetOrder(1)
	If F3L->( dbSeek( xFilial( "F3L" ) + cCodFil ) )
		Help( " ", 1, "JAGRAVADO" )
		lRet := .F.
	EndIf
EndIf

If (nOperation == MODEL_OPERATION_DELETE)
	DbSetOrder(1)
	If !Empty(F3L_NUMATU)
		Help( ,,STR0001,,STR0006,1,0 )
		lRet := .F.
	EndIf
EndIf

Return lRet
