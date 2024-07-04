#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA450.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA450
Cadastro MVC de Informações Econômicas

@author Rafael Völtz
@since 10/08/2016
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA450()

Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Informações Econômicas por Período"                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
oBrw:SetAlias( 'CWY' )
oBrw:SetCacheView( .F. )
oBrw:SetMenuDef( 'TAFA450' )
oBrw:Activate()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf450Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA450" , , aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCWY := FWFormStruct( 1, 'CWY' )
Local oModel 	 := MPFormModel():New( 'TAFA450')

oModel:AddFields( 'MODEL_CWY' , /*cOwner*/ , oStruCWY )

oModel:GetModel( 'MODEL_CWY' ):SetPrimaryKey( { 'CWY_MESREF', 'CWY_ANOREF'} )

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	 := FWLoadModel( 'TAFA450' )

Local oStruCWY := FWFormStruct( 2, 'CWY' )
Local oView 	 := FWFormView():New()

oStruCWY:RemoveField( 'CWY_ID' )

oView:SetModel( oModel )

oView:AddField( 'VIEW_CWY', oStruCWY, 'MODEL_CWY' )
oView:EnableTitleView( 'VIEW_CWY', STR0001 ) //"Informações Econômicas por Período"                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

oView:CreateHorizontalBox( 'FIELDSCWY', 100 )
oView:SetOwnerView( 'VIEW_CWY', 'FIELDSCWY' )


Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF450Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Rafael Völtz
@since 10/08/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF450Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

//Garanto que o Recno seja da tabela referente ao cadastro principal
//nRecno := CWY->( Recno() )

Default lJob := .F. 

If CWY->CWY_STATUS $ ( " |1" )

	
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(CWY->CWY_MESREF)
		AADD(aLogErro,{"CWY_MESREF","000010", "CWY",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(CWY->CWY_ANOREF)
		AADD(aLogErro,{"CWY_ANOREF","000010", "CWY",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	
	If !Empty(CWY->CWY_MESREF)
		IF Val(CWY->CWY_MESREF) <= 0 .OR. Val(CWY->CWY_MESREF) > 12
			AADD(aLogErro,{"CWY_MESREF","000006", "CWY",nRecno }) //"Campo Inválido"
		EndIF
	EndIf
		
	//Atualizo o Status do Registro
	cStatus := Iif(Len(aLogErro) > 0, "1", "0" )
	TAFAltStat( "CWY", cStatus )

Else
	AADD(aLogErro,{"CWY_ID","000305","CWY",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados	
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr( aLogErro )
EndIf	


Return( aLogErro )