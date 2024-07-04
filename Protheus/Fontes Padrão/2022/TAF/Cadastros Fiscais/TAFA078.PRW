#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA078.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA078
Cadastro MVC - Detalhamento das receitas isentas

@author Rodrigo Aguilar
@since 14/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA078
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Detalhamento das receitas isentas"
oBrw:SetAlias( 'C58' )
oBrw:SetMenuDef( 'TAFA078' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu                                                                                        

@author Rodrigo Aguilar
@since 14/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf078Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA078" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 14/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()             

Local oStruC58 := FWFormStruct( 1, 'C58' )
Local oModel   := MPFormModel():New( 'TAFA078' ,,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields( 'MODEL_C58', /*cOwner*/, oStruC58 )  
oModel:GetModel( "MODEL_C58" ):SetPrimaryKey ( { "C58_PERIOD", "C58_TPTRIB", "C58_CSTPC", "C58_NATREC" } )                                                                                                     

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 14/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA078' )
Local oStruC58 	:= 	FWFormStruct( 2, 'C58' ) //Detalhamento das receitas isentas

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C58', oStruC58, 'MODEL_C58' )

oView:CreateHorizontalBox( 'FIELDSC58', 100 )          

If TamSX3("C58_CODCTA")[1] == 36
	oStruC58:RemoveField( "C58_CODCTA")
	oStruC58:SetProperty( "C58_CTACTB", MVC_VIEW_ORDEM, "10" )
EndIf	
oView:SetOwnerView( 'VIEW_C58', 'FIELDSC58' )

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
		TAFAltStat( "C58", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF078Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF078Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C58->( Recno() )

If C58->C58_STATUS $ ( " |1" )

	If Empty(C58->C58_PERIOD)
		AADD(aLogErro,{"C58_PERIOD","000010", "C58",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C58->C58_TPTRIB)
		AADD(aLogErro,{"C58_TPTRIB","000010", "C58",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C58->C58_CSTPC)
		AADD(aLogErro,{"C58_CSTPC","000010", "C58",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C58->C58_NATREC)
		AADD(aLogErro,{"C58_NATREC","000010", "C58",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C58->C58_VLRECB)
		AADD(aLogErro,{"C58_VLRECB","000010", "C58",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If !Empty(C58->C58_CSTPC)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C58->C58_CSTPC
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C58", "C58_CSTPC", nRecno } )
	EndIf	

	If !Empty(C58->C58_NATREC)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C58->C58_NATREC
		xValRegTab("C1U",cChave,6,,@aLogErro,, { "C58", "C58_NATREC", nRecno })
	EndIf	

	If !Empty(C58->C58_CODCTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C58->C58_CODCTA
		xValRegTab("C1O",cChave,3,,@aLogErro,, { "C58", "C58_CODCTA", nRecno })
	EndIf

	If !Empty(C58->C58_TPTRIB)
		If !C58->C58_TPTRIB $ ('1|2')
			AADD(aLogErro,{"C58_TPTRIB","000006", "C58",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
		EndIf
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C58", cStatus )

Else
	AADD(aLogErro,{"C58_ID","000305","C58",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
