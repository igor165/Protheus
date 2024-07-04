#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA055.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA055
Cadastro MVC de Unidades de Medida

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA055()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Unidades de Medida
oBrw:SetAlias('C1J')
oBrw:SetMenuDef( 'TAFA055' )
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

Aadd( aFuncao, { "" , "Taf055Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA055" , , aFuncao )

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
Local oStruC1J 	:= 	FWFormStruct( 1, 'C1J' )
Local 	oModel 	 := MPFormModel():New( 'TAFA055' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_C1J', /*cOwner*/, oStruC1J)            
oModel:GetModel( 'MODEL_C1J' ):SetPrimaryKey( { "C1J_CODIGO" } )

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA055' )
Local 	oStruC1J 	:= 	FWFormStruct( 2, 'C1J' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oStruC1J:RemoveField('C1J_IDUMEC')
oView:AddField( 'VIEW_C1J', oStruC1J, 'MODEL_C1J' )

oView:EnableTitleView( 'VIEW_C1J', STR0001 ) //Cadastro de Unidades de Medida
oView:CreateHorizontalBox( 'FIELDSC1J', 100 )
oView:SetOwnerView( 'VIEW_C1J', 'FIELDSC1J' )

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
		TAFAltStat( "C1J", " " )	
	EndIf
	FwFormCommit( oModel )       
End Transaction
       
Return .T.
 
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Taf055Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacões caso seja necessario gerar um XML

lJob - Informa se foi chamado por Job

@return .T.

@author Denis R. de Oliveira
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//------------------------------------------------------------------------------------
Function TAF055Vld(cAlias,nRecno,nOpc,lJob)
Local aLogErro	:= {}

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C1J->( Recno() )

If C1J->C1J_STATUS $ ( " |1" )

	//Valida o Codigo
	If Empty(C1J->C1J_CODIGO)
		Aadd( aLogErro, { "C1J_CODIGO", "000010", "C1J", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Valida a Descrição
	If Empty(C1J->C1J_DESCRI)
		Aadd( aLogErro, { "C1J_DESCRI", "000010", "C1J", nRecno } ) //000010 - Campo Inconsistente ou Vazio
	EndIf
	
	//Campos UNID e DESCR
	If (Alltrim(C1J->C1J_CODIGO) == Alltrim(C1J->C1J_DESCRI))
		AADD(aLogErro,{"C1J_DESCRI","000519","C1J", nRecno }) //STR0519 - "O valor dos campos Cod Unidade e Descr UM. não podem possuir o mesmo conteúdo."
	EndIF 
	
	//Atualizo o Status do Registro
	If Len(aLogErro)>0
		//Utilizo RecLock, pois o SETVALUE somente funciona em campos Usados
		RecLock("C1J",.F.)
		C1J->C1J_STATUS := "1"
		C1J->( MsUnlock() )
	Else
		RecLock("C1J",.F.)
			C1J->C1J_STATUS := "0"
		C1J->( MsUnlock() )
	EndIf
	
Else 	
	AADD(aLogErro,{"C1J_ID","000305", "C1J", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados  		
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)