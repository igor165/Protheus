#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA079.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA079
Cadastro MVC de Informações Complementares

@author Fabio V. Santana
@since 03/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA079()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Informações Complementares
oBrw:SetAlias( 'C3Q')
oBrw:SetMenuDef( 'TAFA079' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 03/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf079Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA079" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 03/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC3Q 	:= 	FWFormStruct( 1, 'C3Q' )
Local oModel		:= MPFormModel():New( 'TAFA079' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C3Q', /*cOwner*/, oStruC3Q)          

oModel:GetModel( "MODEL_C3Q" ):SetPrimaryKey( { "C3Q_CODINF" } )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 03/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA079' )
Local 	oStruC3Q 	:= 	FWFormStruct( 2, 'C3Q' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C3Q', oStruC3Q, 'MODEL_C3Q' )

oView:EnableTitleView( 'VIEW_C3Q', STR0001 ) //Informações Complementares
oView:CreateHorizontalBox( 'FIELDSC3Q', 100 )
oView:SetOwnerView( 'VIEW_C3Q', 'FIELDSC3Q' )

If TamSX3("C3Q_ID")[1] == 36
	oStruC3Q:RemoveField( "C3Q_ID")	
EndIf

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C3Q", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF079Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 17/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF079Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C3Q->( Recno() )

If C3Q->C3Q_STATUS $ ( " |1" )

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C3Q", cStatus )

Else
	AADD(aLogErro,{"C3Q_ID","000305","C3Q",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)