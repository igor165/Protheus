#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA399.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA399    

Compensação de Dívida Ativa

@author David Costa 
@since 21/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA399()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) // Compensação de Dívida Ativa
oBrw:SetAlias( 'T32' )
oBrw:SetMenuDef( 'TAFA399' )
oBrw:Activate()

Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef                

Funcao generica MVC com as opcoes de menu

@author David Costa 
@since 21/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf399Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA399" , , aFuncao)

Return ( aRotina )
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author David Costa 
@since 21/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT32 	:= FWFormStruct( 1, 'T32' )
Local oStruT33 	:= FWFormStruct( 1, 'T33' )
Local oModel		:= MPFormModel():New( 'TAFA399' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_T32', /*cOwner*/, oStruT32 )

oModel:AddGrid('MODEL_T33', 'MODEL_T32', oStruT33)  //Compensações de Dívidas Ativas
oModel:GetModel( 'MODEL_T33' ):SetUniqueLine( { 'T33_NDIV' } )
oModel:GetModel( 'MODEL_T33' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_T33' , { { 'T33_FILIAL' , 'xFilial( "T32" )' } , { 'T33_ID' ,'T32_ID' }} , T33->( IndexKey( 1 ) ) )

oModel:GetModel('MODEL_T32'):SetPrimaryKey( { "T32_PERIOD" } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author David Costa 
@since 21/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

Local 	oModel 	:= 	FWLoadModel( 'TAFA399' )
Local 	oStruT32 	:= 	FWFormStruct( 2, 'T32' )
Local 	oStruT33 	:= 	FWFormStruct( 2, 'T33' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_T32', oStruT32, 'MODEL_T32' )

oView:EnableTitleView( 'VIEW_T32', STR0002 ) //Dívida Ativa
oView:CreateHorizontalBox( 'FIELDST32', 30 )
oView:SetOwnerView( 'VIEW_T32', 'FIELDST32' )

oView:AddGrid ( 'VIEW_T33', oStruT33, 'MODEL_T33' )  //Dívida Ativa
oView:CreateHorizontalBox( 'PANELT33', 70 )

oView:CreateFolder( 'FOLDER1', 'PANELT33' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //Dívida Ativa
oView:CreateHorizontalBox( 'GRIDT33',100,,, 'FOLDER1', 'ABA01' )

oView:SetOwnerView( 'VIEW_T33', 'GRIDT33' )

// Removendo o ID da visão
oStruT33:RemoveField( 'T33_ID' )
oStruT33:RemoveField( 'T33_CHVDIV' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author David Costa
@since 21/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "T32", " " )
	EndIf
	
	FwFormCommit( oModel ) 
	
End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf399Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacos 
para geracao do XML

@Param
cAlias -> Alias da Tabela
nRecno -> Recno do Registro corrente
nOpc   -> Operacao a ser realizada
lJob   -> Job / Aplicacao

@return ( T. )

@author David Costa
@since 21/09/2015
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf399Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro	:= {}

Default lJob := .F.

nRecno := T32->( Recno() )

If T32->T32_STATUS $ ( " |1" )
//3 Criar consistencias
Else
	AADD(aLogErro,{"T32_ID","000305", "T32", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)

