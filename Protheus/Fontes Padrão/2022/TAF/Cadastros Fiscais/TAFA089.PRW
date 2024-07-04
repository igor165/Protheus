#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA089.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA089
Cadastro MVC de Cadastro de Codigos de Tributos 

@author Danilo L Zanaga
@since 15/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA089()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Totais de operacoes com cartao de credito/debito
oBrw:SetAlias( 'C59')
oBrw:SetMenuDef( 'TAFA089' )
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

Aadd( aFuncao, { "" , "Taf089Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA089" , , aFuncao)

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
Local oStruC59 	:= 	FWFormStruct( 1, 'C59' )

Local oModel		:= MPFormModel():New( 'TAFA089',,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C59', /*cOwner*/, oStruC59)
oModel:GetModel( "MODEL_C59" ):SetPrimaryKey( { "C59_PERIOD", "C59_CODPAR" } )                                                                                                                          

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
Local 	oModel 		:= 	FWLoadModel( 'TAFA089' )
Local 	oStruC59 	:= 	FWFormStruct( 2, 'C59' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C59', oStruC59, 'MODEL_C59' )

oView:EnableTitleView( 'VIEW_C59', STR0001 ) //Totais de operacoes com cartao de credito/debito
oView:CreateHorizontalBox( 'FIELDSC59', 100 )
oView:SetOwnerView( 'VIEW_C59', 'FIELDSC59' )

If TamSX3("C59_CODPAR")[1] == 36
	oStruC59:SetProperty("C59_CPARTI", MVC_VIEW_ORDEM, "04" )
	oStruC59:RemoveField("C59_CODPAR")
EndIf

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
		TAFAltStat( "C59", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF089Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF089Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C59->( Recno() )

If C59->C59_STATUS $ ( " |1" )

	If Empty(C59->C59_PERIOD)
		AADD(aLogErro,{"C59_PERIOD","000010", "C59",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C59->C59_CODPAR)
		AADD(aLogErro,{"C59_CODPAR","000010", "C59",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C59->C59_TOTCRD)
		AADD(aLogErro,{"C59_TOTCRD","000010", "C59",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C59->C59_TOTDEB)
		AADD(aLogErro,{"C59_TOTDEB","000010", "C59",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C59->C59_CODPAR)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C59->C59_CODPAR
		xValRegTab("C1H",cChave,5,,@aLogErro,, { "C59", "C59_CODPAR", nRecno } )
	EndIf	

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C59", cStatus )

Else
	AADD(aLogErro,{"C59_ID","000305","C59",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
