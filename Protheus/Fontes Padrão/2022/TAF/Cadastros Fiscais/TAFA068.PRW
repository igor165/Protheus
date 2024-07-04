#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA068.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA068
Cadastro MVC - Enc/Depr Bens Ativ

@author Gustavo G. Rueda
@since 08/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA068
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //Enc/Depr Bens Ativ
oBrw:SetAlias( 'C4I' )
oBrw:SetMenuDef( 'TAFA068' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu
                                                                                        

@author Gustavo G. Rueda
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf068Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA068" , , aFuncao)

Return( aRotina )      

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Gustavo G. Rueda
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4I 	:= 	FWFormStruct( 1, 'C4I' )
Local oStruC4J 	:= 	FWFormStruct( 1, 'C4J' )

Local oModel		:= MPFormModel():New( 'TAFA068' ,,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields('MODEL_C4I', /*cOwner*/, oStruC4I )

oModel:AddGrid('MODEL_C4J', 'MODEL_C4I', oStruC4J)  
oModel:GetModel( 'MODEL_C4J' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C4J' ):SetUniqueLine( { 'C4J_NUMPRO' } )

oModel:SetRelation( 'MODEL_C4J' , { { 'C4J_FILIAL' , 'xFilial( "C4J" )' } , { 'C4J_ID' , 'C4I_ID' } } , C4J->( IndexKey( 2 ) ) )

If TAFColumnPos( "C4I_CODID" )
	oModel:GetModel( "MODEL_C4I" ):SetPrimaryKey( { "C4I_PERIOD", "C4I_NATBCR", "C4I_IDBMOB", "C4I_INDORI", "C4I_UTBIMO", "C4I_CSTPIS", "C4I_CSTCOF", "C4I_CODID" } )
Else
	oModel:GetModel( "MODEL_C4I" ):SetPrimaryKey( { "C4I_PERIOD", "C4I_NATBCR", "C4I_IDBMOB", "C4I_INDORI", "C4I_UTBIMO", "C4I_CSTPIS", "C4I_CSTCOF" } )
EndIf

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Gustavo G. Rueda
@since 08/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA068' )
Local oStruC4I 	:= 	FWFormStruct( 2, 'C4I' )     
Local oStruC4J 	:= 	FWFormStruct( 2, 'C4J' )

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C4I', oStruC4I, 'MODEL_C4I' )

oView:AddGrid ( 'VIEW_C4J', oStruC4J, 'MODEL_C4J' )
oView:EnableTitleView( 'VIEW_C4J', STR0002 )	//Processos Referenciados

oView:CreateHorizontalBox( 'FIELDSC4I', 60 )          
oView:CreateHorizontalBox( 'GRIDC4J', 40 )

If TamSX3("C4I_CODCTA")[1] == 36
	oStruC4I:RemoveField( "C4I_CODCTA")
	oStruC4I:SetProperty( "C4I_CTACTB", MVC_VIEW_ORDEM, "22" )
EndIf	
oView:SetOwnerView( 'VIEW_C4I', 'FIELDSC4I' )
oView:SetOwnerView( 'VIEW_C4J', 'GRIDC4J' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo

@param  oModel -> Modelo de dados
@return .T.

@author Anderson Costa
@since 18/02/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel(oModel)

Local nOperation := oModel:GetOperation()

Begin Transaction 
	
	If nOperation == MODEL_OPERATION_UPDATE 
		TAFAltStat( "C4I", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF068Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 18/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF068Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local cC4JKey		:= ""
Local nValBase	:= 0
Local nValPIS		:= 0
Local nValCOF		:= 0

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4I->( Recno() )

If C4I->C4I_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C4I->C4I_PERIOD)
		AADD(aLogErro,{"C4I_PERIOD","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4I->C4I_NATBCR)
		AADD(aLogErro,{"C4I_NATBCR","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4I->C4I_IDBMOB)
		AADD(aLogErro,{"C4I_IDBMOB","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4I->C4I_INDORI)
		AADD(aLogErro,{"C4I_INDORI","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4I->C4I_UTBIMO)
		AADD(aLogErro,{"C4I_UTBIMO","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4I->C4I_CSTPIS)
		AADD(aLogErro,{"C4I_CSTPIS","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4I->C4I_CSTCOF)
		AADD(aLogErro,{"C4I_CSTCOF","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4I->C4I_VLENDE)
		AADD(aLogErro,{"C4I_VLENDE","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If TAFColumnPos( "C4I_CODID" ) .And. Empty(C4I->C4I_CODID)
		AADD(aLogErro,{"C4I_CODID","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty(C4I->C4I_NATBCR)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4I->C4I_NATBCR
		xValRegTab("C11",cChave,3,,@aLogErro,, { "C4I", "C4I_NATBCR", nRecno } )
	EndIf	

	If !Empty(C4I->C4I_IDBMOB)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4I->C4I_IDBMOB
		xValRegTab("C4K",cChave,3,,@aLogErro,, { "C4I", "C4I_IDBMOB", nRecno } )
	EndIf	

	If !Empty(C4I->C4I_CSTPIS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4I->C4I_CSTPIS
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C4I", "C4I_CSTPIS", nRecno } )
	EndIf	

	If !Empty(C4I->C4I_CSTCOF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4I->C4I_CSTCOF
		xValRegTab("C17",cChave,3,,@aLogErro,,  { "C4I", "C4I_CSTCOF", nRecno })
	EndIf	

	If !Empty(C4I->C4I_CODCTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4I->C4I_CODCTA
		xValRegTab("C1O",cChave,3,,@aLogErro,,  { "C4I", "C4I_CODCTA", nRecno })
	EndIf	

	If !Empty(C4I->C4I_CODCUS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4I->C4I_CODCUS
		xValRegTab("C1P",cChave,3,,@aLogErro,,  { "C4I", "C4I_CODCUS", nRecno })
	EndIf	

	//--------
	// Combos
	//--------
	If !C4I->C4I_INDORI $ ('0|1')
		AADD(aLogErro,{"C4I_INDORI","000006", "C4I",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	If !C4I->C4I_UTBIMO $ ('1|2|3|9')
		AADD(aLogErro,{"C4I_UTBIMO","000006", "C4I",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	//--------------------
	// Regras específicas
	//--------------------
	If !Empty(C4I->C4I_VLENDE) .And. !Empty(C4I->C4I_PAVLEN) 
		nValBase := C4I->C4I_VLENDE - C4I->C4I_PAVLEN
		
		If !(C4I->C4I_VLBPIS == nValBase)
			AADD(aLogErro,{"C4I_VLBPIS","000526", "C4I",nRecno }) //STR0526 - "A base de PIS deve corresponder à subtração de 'Vlr Enc Depr' menos 'Par Vlr Enc'."   
		EndIf  

		If !(C4I->C4I_VLBCOF == nValBase)
			AADD(aLogErro,{"C4I_VLBCOF","000527", "C4I",nRecno }) //STR0000 - "A base de COFINS deve corresponder à subtração de 'Vlr Enc Depr' menos 'Par Vlr Enc'."   
		EndIf  
	EndIf	

	If !Empty(C4I->C4I_VLBPIS) .And. !Empty(C4I->C4I_ALQPIS) 
		nValPIS := (C4I->C4I_VLBPIS) * (C4I->C4I_ALQPIS / 100)
		
		If !(C4I->C4I_VLPIS == Round(nValPIS, 2))
			AADD(aLogErro,{"C4I_VLBPIS","000524", "C4I",nRecno }) //STR0000 - "O valor do PIS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do PIS."   
		EndIf  
	EndIf	

	If !Empty(C4I->C4I_VLBCOF) .And. !Empty(C4I->C4I_ALQCOF) 
		nValCOF := (C4I->C4I_VLBCOF) * (C4I->C4I_ALQCOF / 100)
		
		If !(C4I->C4I_VLRCOF == Round(nValCOF, 2))
			AADD(aLogErro,{"C4I_VLBCOF","000525", "C4I",nRecno }) //STR0000 - "O valor do COFINS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do COFINS."   
		EndIf  
	EndIf	

	//INICIO C4J
	C4J->( DBSetOrder(2) )
	
	cC4JKey := C4I->C4I_ID
	If C4J->( MsSeek( xFilial("C4J") + cC4JKey ) )

		Do While !C4J->( Eof() ) .And. cC4JKey == C4J->C4J_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C4J->C4J_NUMPRO)
				AADD(aLogErro,{"C4J_NUMPRO","000010", "C4I",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C4J->C4J_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C4J->C4J_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, { "C4I", "C4J_NUMPRO", nRecno }  )
			EndIf	

			C4J->( DbSkip() )
		EndDo
	EndIf
	//FIM C4J

	//ATUALIZO O STATUS DO REGISTRO          
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4I", cStatus )

Else
	AADD(aLogErro,{"C4I_ID","000305","C4I",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar³
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
