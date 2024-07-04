#INCLUDE "PROTHEUS.CH"  
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA074.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA074
Cadastro MVC Crédito Presumido Sobre Estoque de Abertura

@author Danilo L Zanaga
@since 24/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA074()
Local	oBrw		:=	FWmBrowse():New()

oBrw:SetDescription(STR0001) //Crédito Presumido Sobre Estoque de Abertura
oBrw:SetAlias( 'C6M')
oBrw:SetMenuDef( 'TAFA074' )
oBrw:Activate()

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Danilo L Zanaga
@since 24/08/2012
@version 1.0                                 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf074Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA074" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Danilo L Zanaga
@since 24/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC6M 	:= 	FWFormStruct( 1, 'C6M' )
Local oModel		:= MPFormModel():New( 'TAFA074' ,,,{|oModel| SaveModel(oModel)} )

oModel:AddFields('MODEL_C6M', /*cOwner*/, oStruC6M)  
oModel:GetModel( "MODEL_C6M" ):SetPrimaryKey( { "C6M_PERIOD", "C6M_NATOPE" } )                                                                                                                          

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Danilo L Zanaga
@since 24/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local 	oModel 		:= 	FWLoadModel( 'TAFA074' )
Local 	oStruC6M 	:= 	FWFormStruct( 2, 'C6M' )
Local 	oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C6M', oStruC6M, 'MODEL_C6M' )

oView:EnableTitleView( 'VIEW_C6M', STR0001 ) //Crédito Presumido Sobre Estoque de Abertura
oView:CreateHorizontalBox( 'FIELDSC6M', 100 )
If TamSX3("C6M_CODCTA")[1] == 36
	oStruC6M:RemoveField( "C6M_CODCTA")
	oStruC6M:SetProperty( "C6M_CTACTB", MVC_VIEW_ORDEM, "19" )
EndIf
oView:SetOwnerView( 'VIEW_C6M', 'FIELDSC6M' )

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
		TAFAltStat( "C6M", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF074Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF074Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local nValPIS		:= 0
Local nValCOF		:= 0

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C6M->( Recno() )

If C6M->C6M_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C6M->C6M_PERIOD)
		AADD(aLogErro,{"C6M_PERIOD","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_NATOPE)
		AADD(aLogErro,{"C6M_NATOPE","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_TOTEST)
		AADD(aLogErro,{"C6M_TOTEST","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_VBCEST)
		AADD(aLogErro,{"C6M_VBCEST","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_VBCMES)
		AADD(aLogErro,{"C6M_VBCMES","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_CSTPIS)
		AADD(aLogErro,{"C6M_CSTPIS","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_ALQPIS)
		AADD(aLogErro,{"C6M_ALQPIS","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_CRDPIS)
		AADD(aLogErro,{"C6M_CRDPIS","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_CSTCOF)
		AADD(aLogErro,{"C6M_CSTCOF","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_ALQCOF)
		AADD(aLogErro,{"C6M_ALQCOF","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C6M->C6M_CRDCOF)
		AADD(aLogErro,{"C6M_CRDCOF","000010", "C6M",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	// Demetrio - 27/08/2014 - Alterada Tabela de consulta da regra. 
	If !Empty(C6M->C6M_NATOPE)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C6M->C6M_NATOPE
		xValRegTab("C11",cChave,3,,@aLogErro,, { "C6M", "C6M_NATOPE", nRecno } )
	EndIf	

	If !Empty(C6M->C6M_CSTPIS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C6M->C6M_CSTPIS
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C6M", "C6M_CSTPIS", nRecno })
	EndIf	

	If !Empty(C6M->C6M_CSTCOF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C6M->C6M_CSTCOF
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C6M", "C6M_CSTCOF", nRecno })
	EndIf	

	If !Empty(C6M->C6M_CODCTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C6M->C6M_CODCTA
		xValRegTab("C1O",cChave,3,,@aLogErro,, { "C6M", "C6M_CODCTA", nRecno })
	EndIf	

	//--------------------
	// Regras específicas
	//--------------------
	If !Empty(C6M->C6M_TOTEST) .And. !Empty(C6M->C6M_ESTIMP)
		If !(C6M->C6M_VBCEST == (C6M->C6M_TOTEST - C6M->C6M_ESTIMP)) 
			AADD(aLogErro,{"C6M_VBCEST","000530", "C6M",nRecno }) //STR0530 - "A base de cálculo do estoque deve corresponder à subtração de 'Vl Tot Est' menos 'Vl Est Imp'."
		EndIf   
	EndIf	

	If !Empty(C6M->C6M_VBCEST) .And. !Empty(C6M->C6M_VBCMES)
		If !(C6M->C6M_VBCMES == Round((C6M->C6M_VBCEST / 12),2)) 
			AADD(aLogErro,{"C6M_VBCMES","000531", "C6M",nRecno }) //STR0531 - "A base de Cálculo Mensal deve corresponder a 1/12 avos de 'Vl Base Est'."
		EndIf   
	EndIf	

	If !Empty(C6M->C6M_VBCMES) .And. !Empty(C6M->C6M_ALQPIS) 
		nValPIS := Round(C6M->C6M_VBCMES * (C6M->C6M_ALQPIS / 100),2)
		
		If !(C6M->C6M_CRDPIS == nValPIS)
			AADD(aLogErro,{"C6M_CRDPIS","000524", "C6M",nRecno }) //STR0524 - "O valor do PIS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do PIS."   
		EndIf  
	EndIf	

	If !Empty(C6M->C6M_VBCMES) .And. !Empty(C6M->C6M_ALQCOF) 
		nValCOF := Round(C6M->C6M_VBCMES * (C6M->C6M_ALQCOF / 100),2)
		
		If !(C6M->C6M_CRDCOF == nValCOF)
			AADD(aLogErro,{"C6M_CRDCOF","000525", "C6M",nRecno }) //STR0525 - "O valor do COFINS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do COFINS."   
		EndIf  
	EndIf	

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C6M", cStatus )

Else
	AADD(aLogErro,{"C6M_ID","000305","C6M",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
