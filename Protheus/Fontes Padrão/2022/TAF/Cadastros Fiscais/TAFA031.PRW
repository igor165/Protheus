#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA031.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA031
Cadastro MVC de ECF

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA031()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de ECF
oBrw:SetAlias( 'C0W' )
oBrw:SetMenuDef( 'TAFA031' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu
@author Denis R de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf031Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA031" , , aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC0W 	:= 	FWFormStruct( 1, 'C0W' )
Local 	oModel 	:= MPFormModel():New( 'TAFA031' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C0W', /*cOwner*/, oStruC0W)   
oModel:GetModel( "MODEL_C0W" ):SetPrimaryKey( { "C0W_CODIGO" } ) 

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA031' )
Local 	oStruC0W 	:= 	FWFormStruct( 2, 'C0W' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C0W', oStruC0W, 'MODEL_C0W' )

oView:EnableTitleView( 'VIEW_C0W', STR0001 ) //Cadastro de ECF
oView:CreateHorizontalBox( 'FIELDSC0W', 100 )
oView:SetOwnerView( 'VIEW_C0W', 'FIELDSC0W' )

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Denis R. de Oliveira
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "C0W", " " )
	EndIf
	FwFormCommit( oModel ) 
	
End Transaction
       
Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf031Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/
//------------------------------------------------------------------------------------
Function Taf031Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro := {}
Local cComb    := ""
Local cIdMemo  := ""

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C0W->( Recno() )

If C0W->C0W_STATUS $ ( " |1" )
	
	//Valida o Codigo
	If Empty(C0W->C0W_CODIGO)
		Aadd( aLogErro, { "C0W_CODIGO", "000010", "C0W", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida a Descrição
	If Empty(C0W->C0W_DESCRI)
		Aadd( aLogErro, { "C0W_DESCRI", "000010", "C0W", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida o Modelo Equipamento ECF
	If Empty(C0W->C0W_ECFMOD)
		Aadd( aLogErro, { "C0W_ECFMOD", "000010", "C0W", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida o Num Serie do Equipamento 
	If Empty(C0W->C0W_ECFFAB)
		Aadd( aLogErro, { "C0W_ECFFAB", "000010", "C0W", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//Valida o Numero do Caixa atribuido ao ECF 
	If Empty(C0W->C0W_ECFCX)
		Aadd( aLogErro, { "C0W_ECFCX", "000010", "C0W", nRecno } ) //000010 - Campo Inconsistente ou Vazio	
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ATUALIZO O STATUS DO REGISTRO³
	//³1 = Registro Invalido        ³
	//³0 = Registro Valido          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aLogErro)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Utilizo RecLock, pois o SETVALUE somente funciona em campos USADOS³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("C0W",.F.)
		C0W->C0W_STATUS := "1"
		MsUnlock()
	Else
		RecLock("C0W",.F.)
		C0W->C0W_STATUS := "0"
		MsUnlock()
	EndIf
	
Else
	AADD(aLogErro,{"C0W_ID","000305", "C0W", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return( aLogErro )
