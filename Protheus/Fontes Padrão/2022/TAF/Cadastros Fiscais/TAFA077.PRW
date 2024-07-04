#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA077.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA077
Cadastro MVC de PIS/PASEP Folha de Salarios

@author Danilo L Zanaga
@since 15/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA077()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //PIS/PASEP Folha de Salarios
oBrw:SetAlias( 'C5E')
oBrw:SetMenuDef( 'TAFA077' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Danilo L Zanaga
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf077Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA077" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5E 	:= 	FWFormStruct( 1, 'C5E' )
Local oModel		:=	MPFormModel():New( 'TAFA077' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C5E', /*cOwner*/, oStruC5E)     
oModel:GetModel( "MODEL_C5E" ):SetPrimaryKey( { "C5E_PERIOD", "C5E_ALQPIS" } )                                                                                                      

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 15/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA077' )
Local 	oStruC5E 	:= 	FWFormStruct( 2, 'C5E' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5E', oStruC5E, 'MODEL_C5E' )

oView:EnableTitleView( 'VIEW_C5E', STR0001 ) //PIS/PASEP Folha de Salarios
oView:CreateHorizontalBox( 'FIELDSC5E', 100 )
oView:SetOwnerView( 'VIEW_C5E', 'FIELDSC5E' )

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
		TAFAltStat( "C5E", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF077Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF077Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5E->( Recno() )

If C5E->C5E_STATUS $ ( " |1" )

	If Empty(C5E->C5E_PERIOD)
		AADD(aLogErro,{"C5E_PERIOD","000010", "C5E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5E->C5E_TOTFOL)
		AADD(aLogErro,{"C5E_TOTFOL","000010", "C5E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5E->C5E_TOEXBC)
		AADD(aLogErro,{"C5E_TOEXBC","000010", "C5E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5E->C5E_VTOTBC)
		AADD(aLogErro,{"C5E_VTOTBC","000010", "C5E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5E->C5E_ALQPIS)
		AADD(aLogErro,{"C5E_ALQPIS","000010", "C5E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5E->C5E_VCOFOL)
		AADD(aLogErro,{"C5E_VCOFOL","000010", "C5E",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C5E->C5E_VTOTBC) .And. !Empty(C5E->C5E_ALQPIS)
		If !(C5E->C5E_VCOFOL == Round(C5E->C5E_VTOTBC * (C5E->C5E_ALQPIS / 100),2))
			AADD(aLogErro,{"C5E_VCOFOL","000540", "C5E",nRecno }) //STR0540 - "O valor deve corresponder ao campo 'Vl. Tot. Bc.' multiplicado pela alíquota do PIS."
		EndIf   
	EndIf	

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C5E", cStatus )

Else
	AADD(aLogErro,{"C5E_ID","000305","C5E",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)