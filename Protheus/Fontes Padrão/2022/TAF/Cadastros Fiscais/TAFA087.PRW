#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA087.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA087
Cadastro MVC - Controle de Valores Retidos na Fonte - Pis/Pasep/Cofins

@author Rodrigo Aguilar
@since 20/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA087
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Controle de Valores Retidos na Fonte - Pis/Pasep/Cofins"
oBrw:SetAlias( 'C5Z' )
oBrw:SetMenuDef( 'TAFA087' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu                                                                                        

@author Rodrigo Aguilar
@since 20/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf087Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA087" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 20/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()             
Local oStruC5Z	:= FWFormStruct( 1, 'C5Z' )

Local oModel		:= MPFormModel():New( 'TAFA087',,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields( 'MODEL_C5Z', /*cOwner*/, oStruC5Z )   

oModel:GetModel( "MODEL_C5Z" ):SetPrimaryKey( { "C5Z_TPTRIB", "C5Z_PERIOD", "C5Z_INDNAT", "C5Z_PERRET" } )                                                                                                    

oStruC5Z:SetProperty( 'C5Z_VLRRET', MODEL_FIELD_OBRIGAT , .F.  )
oStruC5Z:SetProperty( 'C5Z_VLRRTD', MODEL_FIELD_OBRIGAT , .F.  )
oStruC5Z:SetProperty( 'C5Z_VLRRES', MODEL_FIELD_OBRIGAT , .F.  )
oStruC5Z:SetProperty( 'C5Z_VLRRDC', MODEL_FIELD_OBRIGAT , .F.  )

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 20/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA087' )
Local oStruC5Z 	:= 	FWFormStruct( 2, 'C5Z' ) //Contr.Val.Ret.Pis/Pasep/Cofins

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C5Z', oStruC5Z, 'MODEL_C5Z' )       
oView:EnableTitleView( 'VIEW_C5Z', STR0001) //"Controle de Valores Retidos na Fonte - Pis/Pasep/Cofins"

oView:CreateHorizontalBox( 'FIELDSC5Z', 100 )          

oView:SetOwnerView( 'VIEW_C5Z', 'FIELDSC5Z' )


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
		TAFAltStat( "C5Z", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF087Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 26/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF087Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C5Z->( Recno() )

If C5Z->C5Z_STATUS $ ( " |1" )

	//Validação de campos obrigatórios
	If Empty(C5Z->C5Z_TPTRIB)
		AADD(aLogErro,{"C5Z_TPTRIB","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5Z->C5Z_PERIOD)
		AADD(aLogErro,{"C5Z_PERIOD","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5Z->C5Z_INDNAT)
		AADD(aLogErro,{"C5Z_INDNAT","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5Z->C5Z_PERRET)
		AADD(aLogErro,{"C5Z_PERRET","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	/*
	If Empty(C5Z->C5Z_VLRRET)
		AADD(aLogErro,{"C5Z_VLRRET","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5Z->C5Z_VLRRTD)
		AADD(aLogErro,{"C5Z_VLRRTD","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5Z->C5Z_VLRRES)
		AADD(aLogErro,{"C5Z_VLRRES","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C5Z->C5Z_VLRRDC)
		AADD(aLogErro,{"C5Z_VLRRDC","000010", "C5Z",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf
	*/
	//Validação de consulta padrão
	If !Empty(C5Z->C5Z_INDNAT)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C5Z->C5Z_INDNAT
		xValRegTab("C1Q",cChave,3,,@aLogErro,, { "C5Z", "C5Z_INDNAT", nRecno } )
	EndIf
	
	//Validação de combobox
	If !Empty(C5Z->C5Z_TPTRIB)
		If !(C5Z->C5Z_TPTRIB $ ("1|2"))
			AADD(aLogErro,{"C5Z_TPTRIB","000006", "C5Z",nRecno }) //STR0006 - "Campo Inconsistente ou Vazio"
		EndIf
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C5Z", cStatus )

Else
	AADD(aLogErro,{"C5Z_ID","000305","C5Z",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)