#INCLUDE "TMSA038.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA038()
Tarifas X Bancos para Pagamento de SAQUE ou TRANSFERECIA (Operadores de Frota)
@author Fabio Marchiori Sampaio
@since 09/12/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------

Function TMSA038()

Local oMBrowse	:= Nil       

Private aRotina	:= MenuDef()

oMBrowse:= FwMBrowse():New()
oMBrowse:SetAlias( "DJB" )
oMBrowse:SetDescription( STR0001 )
                                                            
oMBrowse:SetCacheView( .F. )
oMBrowse:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo
@author Fabio Marchiori Sampaio
@since 09/12/2015
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStruDJB	:= FwFormStruct( 1, 'DJB' ) 
                                                         
oModel := MpFormModel():New( 'TMSA038', /*bPreValidacao*/ , { |oMdl| TMSA038Pos( oModel ) } /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
  
oModel:SetDescription( STR0001 )

oModel:AddFields( 'MdFieldDJB', Nil, oStruDJB )

//oModel:GetModel ( 'MdFieldDJB' )
//oModel:SetPrimaryKey({"DJB_FILIAL", "DJB_CODBAN", "DJB_TARIFA", "DJB_CODTAF" }) 

oModel:GetModel( 'MdFieldDJB' ):SetDescription( 'Tarifas de Banco X Operador de Frota (SAQUE X TRANSFERENCIA)' )

 Return( oModel )
 
 //--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View
@author Fabio Marchiori Sampaio
@since 09/12/2015
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------

Static Function ViewDef()

Local oView		:= Nil
Local oModel		:= FwLoadModel( 'TMSA038' )
Local oStruDJB	:= FwFormStruct( 2, 'DJB') 
                     
oView := FwFormView():New()
oView:SetModel( oModel )

oView:AddField( 'VwFieldDJB', oStruDJB, 'MdFieldDJB' )

oView:CreateHorizontalBox( 'FieldDJB', 060 )

oView:SetOwnerView( 'VwFieldDJB', 'FieldDJB' )
                                                             
oView:EnableTitleView( 'VwFieldDJB' , STR0001 )  

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definicao do Menu
@author Fabio Marchiori Sampaio
@since 09/12/2015
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
                 
Local aRotina := {}

	aAdd( aRotina, { 'Visualizar', 'VIEWDEF.TMSA038', 0, 2, 0, NIL } )
	aAdd( aRotina, { 'Incluir'   , 'VIEWDEF.TMSA038', 0, 3, 0, NIL } )
	aAdd( aRotina, { 'Alterar'   , 'VIEWDEF.TMSA038', 0, 4, 0, NIL } )
	aAdd( aRotina, { 'Excluir'   , 'VIEWDEF.TMSA038', 0, 5, 0, NIL } )
		
Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSA038Vld()
Definicao de Validação
@author Fabio Marchiori Sampaio
@since 09/12/2015
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------

Function TMSA038Pos(oMdl) 

Local lRet			:= .T.
Local aArea		:= DJB->( GetArea() )
Local oModel		:= oMdl:GetModel()
Local cCodBan		:= ""
Local cTarifa		:= ""
Local cCodTaf		:= ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		
		cCodBan := oModel:GetValue( 'MdFieldDJB', 'DJB_CODBAN')
		cTarifa := oModel:GetValue( 'MdFieldDJB', 'DJB_TARIFA')
		cCodTaf := oModel:GetValue( 'MdFieldDJB', 'DJB_CODTAF')
		
		DbSelectArea("DJB")
		DJB->(DbSetOrder(1)) //-- //DJB_FILIAL+DJB_CODBAN+DJB_TARIFA+DJB_CODTAF 
		If DJB->(MsSeek(xFilial("DJB")+cCodBan+cTarifa+cCodTaf))
			Help("",1,"JAGRAVADO") //Ja existe registro com esta informacao.
			lRet := .F.
		EndIf
	EndIf

RestArea(aArea)

Return(lRet)
