#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TECA490.CH'

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TECA490
	Constr�i o browse para as opera��es relacionadas com a gest�o da investiga��o

@sample		TECA490(Nil)
	
@since		06/02/2014 
@version 	P12

@param		cFilDef, Caracter, filtro padr�o a ser inserido na exibi��o do browse

/*/
//--------------------------------------------------------------------------------------------------------------------
Function TECA490(cFilDef)

Local oBrw := FwMBrowse():New()

Default cFilDef := ''

oBrw:SetAlias( 'TIW' )
oBrw:SetMenudef( "TECA490" )
oBrw:SetDescription( OEmToAnsi( STR0001 ) ) // "Gest�o de Investiga��o"
oBrw:AddStatusColumns( { || AT490Status(TIW->TIW_FECHAR) }, { || AT490Legen() } )

If !Empty(cFilDef)
	oBrw:SetFilterDefault(cFilDef)
EndIf

oBrw:Activate()

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} Menudef
	Rotina para constru��o do menu
@sample 	Menudef() 
@since		06/09/2013       
@version 	P11.90

/*/
//------------------------------------------------------------------------------
Static Function Menudef()

Local aMenu := FWMVCMenu("TECA490")

Return aMenu
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Defini��o do interface

@author arthur.colado

@since 06/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef() 
Local oStr3:= FWFormStruct(2, 'TIW')
Local oStr4:= FWFormStruct(2, 'TIY')
Local oStr5:= FWFormStruct(2, 'TIY')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FORM4' , oStr3,'TIW' )
oView:AddField('FORM6' , oStr4,'TIY_2' )
oView:AddGrid('FORM8' , oStr5,'TIY')    
oView:CreateFolder( 'FOLDER1')
oView:AddSheet('FOLDER1','SHEET3','Principal') //VER
oView:AddSheet('FOLDER1','SHEET2','Vers�es')    //VER

oStr5:RemoveField( 'TIY_DESCRI' )
oStr5:RemoveField( 'TIY_CODTIW' )

oView:CreateHorizontalBox( 'BOXFORM8', 50, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')

oStr4:RemoveField( 'TIY_OBS' )
oStr4:RemoveField( 'TIY_DATA' )
oStr4:RemoveField( 'TIY_NOME' )
oStr4:RemoveField( 'TIY_PARTES' )
oStr4:RemoveField( 'TIY_ITEM' )
oStr4:RemoveField( 'TIY_CODTIW' )

oView:CreateHorizontalBox( 'BOXFORM6', 50, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET2')
oView:SetOwnerView('FORM8','BOXFORM8')
oView:SetOwnerView('FORM6','BOXFORM6')
oView:CreateHorizontalBox( 'BOXFORM4', 100, /*owner*/, /*lUsePixel*/, 'FOLDER1', 'SHEET3')
oView:SetOwnerView('FORM4','BOXFORM4')
oView:AddIncrementField('FORM8' , 'TIY_ITEM' ) 

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Defini��o do modelo de Dados

@author arthur.colado

@since 06/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel
local bFechar := Nil
Local oStr1:= FWFormStruct(1,'TIW')
Local oStr3:= FWFormStruct(1,'TIY')
Local oStr4:= FWFormStruct(1,'TIY')

oModel := MPFormModel():New('TECA490')
oModel:SetDescription(STR0001)	//'Gest�o de Investiga��o'
oModel:addFields('TIW',,oStr1)
oModel:SetPrimaryKey({ 'TIW_FILIAL', 'TIW_CODIGO' })

oStr3:SetProperty('TIY_ITEM',MODEL_FIELD_OBRIGAT,.F.)

oModel:addGrid('TIY','TIW',oStr3)

oStr4:RemoveField( 'TIY_OBS' )
oStr4:RemoveField( 'TIY_DATA' )
oStr4:RemoveField( 'TIY_NOME' )
oStr4:RemoveField( 'TIY_PARTES' )
oStr4:SetProperty('TIY_ITEM',MODEL_FIELD_OBRIGAT,.F.)
oStr4:AddTrigger( 'TIY_DESCRI', 'TIY_DESCRI', { || .T. },{||At490Trg()}  )

oModel:Addfields('TIY_2','TIY',oStr4)
oModel:SetRelation('TIY', { { 'TIY_FILIAL', 'xFilial("TIY")' }, { 'TIY_CODTIW', 'TIW_CODIGO' } }, TIY->(IndexKey(1)) )
oModel:SetRelation('TIY_2', { { 'TIY_FILIAL', 'xFilial("TIY")' }, { 'TIY_CODTIW', 'TIY_CODTIW' }, { 'TIY_ITEM', 'TIY_ITEM' } }, TIY->(IndexKey(1)) )
oModel:getModel('TIW'):SetDescription(STR0002)	//'Fatos da Investiga��o'
oModel:getModel('TIY'):SetDescription(STR0003)	//'Vers�es da Investiga��o
oModel:getModel('TIY_2'):SetDescription(STR0004)	//'Relatos da Investiga��o'
oModel:getModel('TIY_2'):SetOnlyQuery(.T.)

bFechar := {|oModel| At490VdAct(oModel)}  

oModel:SetVldActivate(bFechar) 
oModel:GetModel( 'TIY' ):SetOptional( .T. )
oModel:GetModel( 'TIY_2' ):SetOptional( .T. )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} At490VdAct
8Defini��o do modo de Edi��o da Tela ap�s encerrada a investiga��o

@author arthur.colado

@since 06/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function At490VdAct(oMdlGeral)

Local lRet := .T.

If ( oMdlGeral:GetOperation() == MODEL_OPERATION_UPDATE .Or. ;
	oMdlGeral:GetOperation() == MODEL_OPERATION_DELETE ) .And. ;
	TIW->TIW_FECHAR == "1"
	lRet := .F.
	
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At490Trg( )
Trata o campo TIY_DESCRI para que seja gravado na mesma linha na tabela conforme o registro que est� posicionado no GRID

@author arthur.colado
@since 06/02/2014

@version 1.0
/*/
//-------------------------------------------------------------------

Function At490Trg( )

Local cRet      := ''
Local oMdlGeral := FwModelActive()
Local oMdlTIY   := Nil

If oMdlGeral <> Nil .And. oMdlGeral:GetId()=='TECA490'
	oMdlTIY := oMdlGeral:GetModel('TIY')
	cRet := oMdlGeral:GetModel('TIY_2'):GetValue('TIY_DESCRI')
	oMdlTIY:SetValue('TIY_DESCRI', cRet )

EndIf
Return cRet 

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT490Status

Define a cor da legenda que deve ser visualizada baseada na regra

@author arthur.colado

@since 10/02/2014
@version 1.0
/*/
//------------------------------------------------------------------------------

Static Function AT490Status(cStatus)

	
If cStatus == "1"
	cStatus := STR0005	//"BR_VERDE"
Else
	cStatus := STR0006	//"BR_VERMELHO"
EndIf		
			
Return cStatus

//------------------------------------------------------------------------------
/*/{Protheus.doc} AT490Legen

Bloco de c�digo que define a cor da legenda

@owner  	arthur.colado
@author  	arthur.colado
@version 	V119
@since   	09/10/2013 
@return 	Nil
/*/
//------------------------------------------------------------------------------

Static Function AT490Legen()
Local oLegenda  :=  FWLegend():New()

oLegenda:Add( '', "BR_VERDE" , STR0007 )	//"Investiga��o Conclu�da"
oLegenda:Add( '', "BR_VERMELHO" , STR0008 )	//"Investiga��o N�o Conclu�da"
	
oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

Return Nil
