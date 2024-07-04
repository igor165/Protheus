#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA071.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA071
Cadastro MVC Contribuicao retida na fonte 

@author Danilo L Zanaga
@since 16/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA071()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Contribuicao retida na fonte
oBrw:SetAlias( 'C5I')
oBrw:SetMenuDef( 'TAFA071' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Danilo L Zanaga
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf071Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA071" , , aFuncao)

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC5I 	:= 	FWFormStruct( 1, 'C5I' )
Local oModel		:= MPFormModel():New( 'TAFA070' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C5I', /*cOwner*/, oStruC5I)    
oModel:GetModel( "MODEL_C5I" ):SetPrimaryKey( { "C5I_NATRET", "C5I_DTRETE", "C5I_CNPJ", "C5I_INDDEC", "C5I_CODREC", "C5I_NATREC" } )                                                                                                      

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 16/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA071' )
Local 	oStruC5I 	:= 	FWFormStruct( 2, 'C5I' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C5I', oStruC5I, 'MODEL_C5I' )

oView:EnableTitleView( 'VIEW_C5I', STR0001 ) //Contribuicao retida na fonte
oView:CreateHorizontalBox( 'FIELDSC5I', 100 )
oView:SetOwnerView( 'VIEW_C5I', 'FIELDSC5I' )

Return oView	

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C5I", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF071Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF071Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5I->( Recno() )

If C5I->C5I_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C5I->C5I_NATRET)
		AADD(aLogErro,{"C5I_NATRET","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5I->C5I_DTRETE)
		AADD(aLogErro,{"C5I_DTRETE","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5I->C5I_CNPJ)
		AADD(aLogErro,{"C5I_CNPJ","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	Else
		If !CGC(C5I->C5I_CNPJ, , .F.)
			AADD(aLogErro,{"C5I_CNPJ","000005", "C5I",nRecno }) //STR0005 - //CPF/CNPJ Inconsistente
		EndIf
	EndIf

	If Empty(C5I->C5I_INDDEC)
		AADD(aLogErro,{"C5I_INDDEC","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	Else
		If !C5I->C5I_INDDEC $ ('0|1')
			AADD(aLogErro,{"C5I_INDDEC","000006", "C5I",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
		EndIf	
	EndIf

	If Empty(C5I->C5I_VBCRET)
		AADD(aLogErro,{"C5I_VBCRET","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5I->C5I_RETPIS)
		AADD(aLogErro,{"C5I_RETPIS","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5I->C5I_RETCOF)
		AADD(aLogErro,{"C5I_RETCOF","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5I->C5I_VLRETE)
		AADD(aLogErro,{"C5I_VLRETE","000010", "C5I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty(C5I->C5I_NATRET)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C5I->C5I_NATRET
		xValRegTab("C1Q",cChave,3,,@aLogErro,, { "C5I", "C5I_NATRET", nRecno } )
	EndIf	

	//--------
	// Combos
	//--------

	If !C5I->C5I_NATREC $ ('0|1')
		AADD(aLogErro,{"C5I_NATREC","000006", "C5I",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	
	
	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C5I", cStatus )

Else
	AADD(aLogErro,{"C5I_ID","000305","C5I",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)