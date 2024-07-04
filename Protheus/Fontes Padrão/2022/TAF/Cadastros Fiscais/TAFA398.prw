#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TAFA398.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA398    

ADMINISTRADORES DE CENTROS COMERCIAIS

@author David Costa 
@since 22/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFA398()

Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) // Administradores de Centros Comerciais 
oBrw:SetAlias( 'T30' )
oBrw:SetMenuDef( 'TAFA398' )
oBrw:Activate()

Return ( Nil ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef                

Funcao generica MVC com as opcoes de menu

@author David Costa 
@since 22/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf398Vld" , "2" } )
aRotina	:=	xFunMnuTAF( "TAFA398" , , aFuncao)

Return ( aRotina )
 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author David Costa 
@since 22/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruT30 	:= FWFormStruct( 1, 'T30' )
Local oStruT31 	:= FWFormStruct( 1, 'T31' )
Local oModel		:= MPFormModel():New( 'TAFA398' , , , {|oModel| SaveModel( oModel ) } )

oModel:AddFields('MODEL_T30', /*cOwner*/, oStruT30 )

oModel:AddGrid('MODEL_T31', 'MODEL_T30', oStruT31)  //Faturamento dos Lojistas
oModel:GetModel( 'MODEL_T31' ):SetUniqueLine( { 'T31_CODPAR' } )
oModel:GetModel( 'MODEL_T31' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_T31' , { { 'T31_FILIAL' , 'xFilial( "T30" )' } , { 'T31_ID' ,'T30_ID' }} , T31->( IndexKey( 1 ) ) )

oModel:GetModel('MODEL_T30'):SetPrimaryKey( { "T30_PERIOD" } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author David Costa 
@since 22/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 

Local 	oModel 	:= 	FWLoadModel( 'TAFA398' )
Local 	oStruT30 	:= 	FWFormStruct( 2, 'T30' )
Local 	oStruT31 	:= 	FWFormStruct( 2, 'T31' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_T30', oStruT30, 'MODEL_T30' )

oView:EnableTitleView( 'VIEW_T30', STR0002 ) // Centros Comerciais
oView:CreateHorizontalBox( 'FIELDST30', 30 )
oView:SetOwnerView( 'VIEW_T30', 'FIELDST30' )

oView:AddGrid ( 'VIEW_T31', oStruT31, 'MODEL_T31' )  //Faturamento dos Lojistas
oView:CreateHorizontalBox( 'PANELT31', 70 )

oView:CreateFolder( 'FOLDER1', 'PANELT31' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0003) // Faturamento dos Lojistas
oView:CreateHorizontalBox( 'GRIDT31',100,,, 'FOLDER1', 'ABA01' )

If TamSX3("T31_CODPAR")[1] == 36
	oStruT31:RemoveField( "T31_CODPAR")
	oStruT31:SetProperty( "T31_PARTIC", MVC_VIEW_ORDEM, "12" )
	oStruT31:SetProperty( "T31_NOME", MVC_VIEW_ORDEM, "13" )
EndIf
oView:SetOwnerView( 'VIEW_T31', 'GRIDT31' )

// Removendo o ID da visão
oStruT31:RemoveField( 'T31_ID' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados
@return .T.

@author David Costa
@since 22/09/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )

Local nOperation := oModel:GetOperation()

Begin Transaction

	If nOperation == MODEL_OPERATION_UPDATE
		//Funcao responsavel por setar o Status do registro para Branco
		TAFAltStat( "T30", " " )
	EndIf
	FwFormCommit( oModel ) 
	
End Transaction

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf398Vld

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
@since 22/09/2015
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function Taf398Vld( cAlias, nRecno, nOpc, lJob )

Local aLogErro	:= {}

Default lJob := .F.

nRecno := T30->( Recno() )

If T30->T30_STATUS $ ( " |1" )
//3 Criar consistencias
Else
	AADD(aLogErro,{"T30_ID","000305", "T30", nRecno })//Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf

Return(aLogErro)

