#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA088.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA088
Cadastro MVC de Informacoes sobre valores agregados

@author Fabio V. Santana
@since 09/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA088()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Informacoes sobre valores agregados
oBrw:SetAlias( 'C4X')
oBrw:SetMenuDef( 'TAFA088' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf088Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA088" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4X 	:= 	FWFormStruct( 1, 'C4X' )

Local oModel		:= MPFormModel():New( 'TAFA088',,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C4X', /*cOwner*/, oStruC4X)    
oModel:GetModel( "MODEL_C4X" ):SetPrimaryKey( { "C4X_PERIOD", "C4X_CODITE", "C4X_UF", "C4X_CODMUN" } )                                                                                                        

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 09/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA088' )
Local 	oStruC4X 	:= 	FWFormStruct( 2, 'C4X' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4X', oStruC4X, 'MODEL_C4X' )

oView:EnableTitleView( 'VIEW_C4X', STR0001 ) //Informacoes sobre valores agregados
oView:CreateHorizontalBox( 'FIELDSC4X', 100 )
oView:SetOwnerView( 'VIEW_C4X', 'FIELDSC4X' )

If TamSX3("C4X_CODITE")[1] == 36
	oStruC4X:RemoveField("C4X_CODITE")
	oStruC4X:SetProperty("C4X_ITEM", MVC_VIEW_ORDEM, "04" )	
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
		TAFAltStat( "C4X", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF088Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF088Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4X->( Recno() )

If C4X->C4X_STATUS $ ( " |1" )

	If Empty(C4X->C4X_PERIOD)
		AADD(aLogErro,{"C4X_PERIOD","000010", "C4X",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4X->C4X_CODITE)
		AADD(aLogErro,{"C4X_CODITE","000010", "C4X",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4X->C4X_UF)
		AADD(aLogErro,{"C4X_UF","000010", "C4X",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4X->C4X_CODMUN)
		AADD(aLogErro,{"C4X_CODMUN","000010", "C4X",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4X->C4X_VALOR)
		AADD(aLogErro,{"C4X_VALOR","000010", "C4X",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C4X->C4X_CODITE)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4X->C4X_CODITE
		xValRegTab("C1L",cChave,3,,@aLogErro,, { "C4X", "C4X_CODITE", nRecno } )
	EndIf	

	If !Empty(C4X->C4X_UF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4X->C4X_UF
		xValRegTab("C09",cChave,3,,@aLogErro,, { "C4X", "C4X_UF", nRecno })
	EndIf	

	If !Empty(C4X->C4X_CODMUN)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4X->C4X_CODMUN
		xValRegTab("C07",cChave,3,,@aLogErro,, { "C4X", "C4X_CODMUN", nRecno })
	EndIf	

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4X", cStatus )

Else
	AADD(aLogErro,{"C4X_ID","000305","C4X",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)