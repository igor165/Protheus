#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA073.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA073
Cadastro MVC de Creditos decorrentes de eventos de incorporacao, fusao e cisao

@author Fabio V. Santana
@since 12/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA073()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Cadastro de Creditos decorrentes de eventos de incorporacao, fusao e cisao
oBrw:SetAlias( 'C4B')
oBrw:SetMenuDef( 'TAFA073' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf073Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA073" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4B 	:= 	FWFormStruct( 1, 'C4B' )
Local oModel		:= MPFormModel():New( 'TAFA073' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C4B', /*cOwner*/, oStruC4B)                                 
oModel:GetModel( "MODEL_C4B" ):SetPrimaryKey( { "C4B_INDNAT", "C4B_DTEVEN", "C4B_CNPJ" } )                                                                                                                 

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V. Santana
@since 12/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA073' )
Local 	oStruC4B 	:= 	FWFormStruct( 2, 'C4B' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C4B', oStruC4B, 'MODEL_C4B' )

oView:EnableTitleView( 'VIEW_C4B', STR0001 ) //Cadastro de Creditos decorrentes de eventos de incorporacao, fusao e cisao
oView:CreateHorizontalBox( 'FIELDSC4B', 100 )
oView:SetOwnerView( 'VIEW_C4B', 'FIELDSC4B' )

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
		TAFAltStat( "C4B", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF073Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF073Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4B->( Recno() )

If C4B->C4B_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C4B->C4B_INDNAT)
		AADD(aLogErro,{"C4B_INDNAT","000010", "C4B",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4B->C4B_DTEVEN)
		AADD(aLogErro,{"C4B_DTEVEN","000010", "C4B",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4B->C4B_CNPJ)
		AADD(aLogErro,{"C4B_CNPJ","000010", "C4B",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf


	If Empty(C4B->C4B_PACONT)
		AADD(aLogErro,{"C4B_PACONT","000010", "C4B",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf


	If Empty(C4B->C4B_CODCRD)
		AADD(aLogErro,{"C4B_CODCRD","000010", "C4B",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf


	If Empty(C4B->C4B_VCRDPI)
		AADD(aLogErro,{"C4B_VCRDPI","000010", "C4B",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf


	If Empty(C4B->C4B_VCRDCO)
		AADD(aLogErro,{"C4B_VCRDCO","000010", "C4B",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty(C4B->C4B_CODCRD)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4B->C4B_CODCRD
		xValRegTab("C4D",cChave,3,,@aLogErro,, { "C4B", "C4B_CODCRD", nRecno } )
	EndIf	

	//--------
	// Combos
	//--------
	If !C4B->C4B_INDNAT $ ('01|02|03|04|99')
		AADD(aLogErro,{"C4B_INDNAT","000006", "C4B",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	
	
	//--------------------
	// Regras específicas
	//--------------------
	//Valido o campo de CNPJ, passando o terceiro parametro da funcao CGC como .F.
	//Para que nao seja apresentado o alert de validacao                          
	If !Empty(C4B->C4B_CNPJ)
		If !CGC(C4B->C4B_CNPJ,,.F.)
			AADD(aLogErro,{"C4B_CNPJ", "000005", "C4B", nRecno }) //STR0005 - "CPF/CNPJ Inconsistente"
		EndIf
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4B", cStatus )

Else
	AADD(aLogErro,{"C4B_ID","000305","C4B",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar³
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)