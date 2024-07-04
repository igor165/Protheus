#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA472.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA472
Cadastro MVC das Operações específicas ANP 

@author Rafael Völtz
@since 03/04/2017
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA472()

Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Operações específicas ANP "                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
oBrw:SetAlias( 'T6L' )
oBrw:SetCacheView( .F. )
oBrw:SetMenuDef( 'TAFA472' )
oBrw:Activate()

Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Rafael Völtz
@since 03/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf472Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA472" , , aFuncao )

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rafael Völtz
@since 03/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruT6L := FWFormStruct( 1, 'T6L' )
Local oModel 	 := MPFormModel():New( 'TAFA472', /*bPre */, {|oModel| validaPos(oModel) }, /*bCommit */, /*bCancel */)

oModel:AddFields( 'MODEL_T6L' , /*cOwner*/ , oStruT6L )

oModel:GetModel( 'MODEL_T6L' ):SetPrimaryKey( { 'DTOS(T6L_DTLANC)', 'T6L_IDANPI', 'T6L_IDOANP'} )

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rafael Völtz
@since 03/04/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel 	 := FWLoadModel( 'TAFA472' )

Local oStruT6L := FWFormStruct( 2, 'T6L' )
Local oView 	 := FWFormView():New()

oStruT6L:RemoveField( 'T6L_ID' )
oStruT6L:RemoveField( 'T6L_IDANPI' )
oStruT6L:RemoveField( 'T6L_IDANPT' )
oStruT6L:RemoveField( 'T6L_IDOANP' )

oView:SetModel( oModel )

oView:AddField( 'VIEW_T6L', oStruT6L, 'MODEL_T6L' )
oView:EnableTitleView( 'VIEW_T6L', STR0001 ) //"Operações específicas ANP "                                                                                                                                                                                                                                                                                                                                                                                                                                                                             

oView:CreateHorizontalBox( 'FIELDST6L', 100 )
oView:SetOwnerView( 'VIEW_T6L', 'FIELDST6L' )

Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf472Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Rafael Völtz
@since 03/04/2017
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf472Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

//Garanto que o Recno seja da tabela referente ao cadastro principal
//nRecno := T6L->( Recno() )

Default lJob := .F. 

If T6L->T6L_STATUS $ ( " |1" )

	
	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(T6L->T6L_DTLANC)
		AADD(aLogErro,{"T6L_DTLANC","000010", "T6L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(T6L->T6L_IDANPI)
		AADD(aLogErro,{"T6L_IDANPI","000010", "T6L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
		
	//Atualizo o Status do Registro
	cStatus := Iif(Len(aLogErro) > 0, "1", "0" )
	TAFAltStat( "T6L", cStatus )

Else
	AADD(aLogErro,{"T6L_ID","000305","T6L",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados	
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr( aLogErro )
EndIf	


Return( aLogErro )


//-------------------------------------------------------------------
/*/{Protheus.doc} validaPos

Função para realizar validações após a confirmação dos dados pelo 
usuário.

oModel - Modelo de dados.

@return lRet - Resultado da validação (.T. or .F.)

@author Rafael Völtz
@since 04/04/2017
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function validaPos(oModel as object)
	
	Local lRet as logical
	
	lRet := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		lRet := XFUNVldUni("T6L",2, DTOS(FWFLDGET("T6L_DTLANC"))+FWFLDGET("T6L_IDANPI")+FWFLDGET("T6L_IDOANP"), .F.)
	EndIf
	
Return lRet
