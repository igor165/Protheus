#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"                               
#INCLUDE "TAFA180.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA180
Cadastro MVC dos Modelos de Documentos Fiscais 

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA180()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001)	//"Observação do Lançamento Fiscal dos Documentos"
oBrw:SetAlias( 'C3R')
oBrw:SetMenuDef( 'TAFA180' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf180Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA180" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3R 	:= 	FWFormStruct( 1, 'C3R' )

Local oModel		:= MPFormModel():New( 'TAFA180' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C3R', /*cOwner*/, oStruC3R)    
oModel:GetModel( "MODEL_C3R" ):SetPrimaryKey( { "C3R_CODIGO" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA180' )
Local 	oStruC3R 	:= 	FWFormStruct( 2, 'C3R' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3R', oStruC3R, 'MODEL_C3R' )

oView:EnableTitleView( 'VIEW_C3R', STR0001 )	//"Observação do Lançamento Fiscal dos Documentos"
oView:CreateHorizontalBox( 'FIELDSC3R', 100 )
oView:SetOwnerView( 'VIEW_C3R', 'FIELDSC3R' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C3R", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF180Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF180Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C3R->( Recno() )

If C3R->C3R_STATUS $ ( " |1" )

	If Empty(C3R->C3R_CODIGO)
		AADD(aLogErro,{"C3R_CODIGO","000010", "C3R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C3R->C3R_DESCRI)
		AADD(aLogErro,{"C3R_DESCRI","000010", "C3R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	
	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C3R", cStatus )

Else
	AADD(aLogErro,{"C3R_ID","000305","C3R",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)