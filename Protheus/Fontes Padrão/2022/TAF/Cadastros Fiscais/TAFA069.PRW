#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA069.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA069
Cadastro MVC - Bens incorporados ao Ativo Imobilizado - Operacoes geradoras de creditos com base no valor de aquisicao/contribuicao

@author Rodrigo Aguilar
@since 06/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA069
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Bens Inc.Ativo Imob - Op Creditos Aquisicao/Contribuicao
oBrw:SetAlias( 'C4L' )
oBrw:SetMenuDef( 'TAFA069' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu
                                                                                        

@author Rodrigo Aguilar
@since 06/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf069Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA069" , , aFuncao)

Return( aRotina )      

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 06/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4L 	:= 	FWFormStruct( 1, 'C4L' )
Local oStruC4M 	:= 	FWFormStruct( 1, 'C4M' )

Local oModel		:= MPFormModel():New( 'TAFA069' ,,,{|oModel| SaveModel(oModel)} )
      
oModel:AddFields('MODEL_C4L', /*cOwner*/, oStruC4L )

oModel:AddGrid('MODEL_C4M', 'MODEL_C4L', oStruC4M)  
oModel:GetModel( 'MODEL_C4M' ):SetOptional( .T. )
oModel:GetModel( 'MODEL_C4M' ):SetUniqueLine( { 'C4M_NUMPRO' } )

oModel:SetRelation( 'MODEL_C4M' , { { 'C4M_FILIAL' , 'xFilial( "C4M" )' } , { 'C4M_ID' , 'C4L_ID' } } , C4M->( IndexKey( 1 ) ) )

//Para o registro F130 do Sped Contribuições não existe chave unica, o PVA aceita todos os campos
//repetidos durante a integracao
//oModel:GetModel( "MODEL_C4L" ):SetPrimaryKey( { } )                                                                   

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 06/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA069' )
Local oStruC4L 	:= 	FWFormStruct( 2, 'C4L' ) //Bens incorp. Ativo Imobilizado     
Local oStruC4M 	:= 	FWFormStruct( 2, 'C4M' ) //Proc.Ref - Bens Incorp. At.Imb

Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C4L', oStruC4L, 'MODEL_C4L' )
oView:AddGrid ( 'VIEW_C4M', oStruC4M, 'MODEL_C4M' )                     

oView:EnableTitleView( 'VIEW_C4M', STR0002 )	//Processos Referenciados - Op.Creditos Aquisicao/Contribuicao

oView:CreateHorizontalBox( 'FIELDSC4L', 60 )          
oView:CreateHorizontalBox( 'GRIDC4M', 40 )

If TamSX3("C4L_CODCTA")[1] == 36
	oStruC4L:RemoveField( "C4L_CODCTA")
	oStruC4L:SetProperty( "C4L_CTACTB", MVC_VIEW_ORDEM, "25" )
EndIf	
oView:SetOwnerView( 'VIEW_C4L', 'FIELDSC4L' )
oView:SetOwnerView( 'VIEW_C4M', 'GRIDC4M' )

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
		TAFAltStat( "C4L", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF069Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF069Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local cC4MKey		:= ""
Local nValBase	:= 0
Local nValPIS		:= 0
Local nValCOF		:= 0

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4L->( Recno() ) 

If C4L->C4L_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C4L->C4L_PERIOD)
		AADD(aLogErro,{"C4L_PERIOD","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_NATBCR)
		AADD(aLogErro,{"C4L_NATBCR","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_IDBMOB)
		AADD(aLogErro,{"C4L_IDBMOB","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_UTBIMO)
		AADD(aLogErro,{"C4L_UTBIMO","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_VLAQBM)
		AADD(aLogErro,{"C4L_VLAQBM","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_BCCRED)
		AADD(aLogErro,{"C4L_BCCRED","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_INDNPC)
		AADD(aLogErro,{"C4L_INDNPC","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_CSTPIS)
		AADD(aLogErro,{"C4L_CSTPIS","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4L->C4L_CSTCOF)
		AADD(aLogErro,{"C4L_CSTCOF","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty(C4L->C4L_NATBCR)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4L->C4L_NATBCR
		xValRegTab("C11",cChave,3,,@aLogErro,, { "C4L", "C4L_NATBCR", nRecno } )
	EndIf	

	If !Empty(C4L->C4L_IDBMOB)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4L->C4L_IDBMOB
		xValRegTab("C4K",cChave,3,,@aLogErro,, { "C4L", "C4L_IDBMOB", nRecno })
	EndIf	

	If !Empty(C4L->C4L_CSTPIS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4L->C4L_CSTPIS
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C4L", "C4L_CSTPIS", nRecno })
	EndIf	

	If !Empty(C4L->C4L_CSTCOF)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4L->C4L_CSTCOF
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C4L", "C4L_CSTCOF", nRecno })
	EndIf	

	If !Empty(C4L->C4L_CODCTA)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4L->C4L_CODCTA
		xValRegTab("C1O",cChave,3,,@aLogErro,, { "C4L", "C4L_CODCTA", nRecno })
	EndIf	

	If !Empty(C4L->C4L_CODCUS)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C4L->C4L_CODCUS
		xValRegTab("C1P",cChave,3,,@aLogErro,, { "C4L", "C4L_CODCUS", nRecno })
	EndIf	

	//--------
	// Combos
	//--------
	If !C4L->C4L_INDORI $ (' 0|1')
		AADD(aLogErro,{"C4L_INDORI","000006", "C4L",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	If !C4L->C4L_UTBIMO $ (' 1|2|3|9')
		AADD(aLogErro,{"C4L_UTBIMO","000006", "C4L",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	If !C4L->C4L_INDNPC $ (' 1|2|3|4|5|9')
		AADD(aLogErro,{"C4L_INDNPC","000006", "C4L",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	//--------------------
	// Regras específicas
	//--------------------
	If !Empty(C4L->C4L_VLAQBM) .And. !Empty(C4L->C4L_PAVAQS) 
		nValBase := C4L->C4L_VLAQBM - C4L->C4L_PAVAQS
		
		If !(C4L->C4L_VLBPIS == nValBase)
			AADD(aLogErro,{"C4L_VLBPIS","000528", "C4L",nRecno }) //STR0528 - "A base de PIS deve corresponder à subtração de 'Vlr Aq Bem' menos 'Par Vlr Aqs'."   
		EndIf  

		If !(C4L->C4L_VLBCOF == nValBase)
			AADD(aLogErro,{"C4L_VLBCOF","000529", "C4L",nRecno }) //STR0529 - "A base de COFINS deve corresponder à subtração de 'Vlr Aq Bem' menos 'Par Vlr Aqs'."   
		EndIf  
	EndIf	

	If !Empty(C4L->C4L_VLBPIS) .And. !Empty(C4L->C4L_ALQPIS) 
		nValPIS := C4L->C4L_VLBPIS * (C4L->C4L_ALQPIS / 100)
		
		If !(Round(C4L->C4L_VLPIS,2) == Round(nValPIS,2))
			AADD(aLogErro,{"C4L_VLPIS","000524", "C4L",nRecno }) //STR0524 - "O valor do PIS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do PIS."   
		EndIf  
	EndIf	

	If !Empty(C4L->C4L_VLBCOF) .And. !Empty(C4L->C4L_ALQCOF) 
		nValCOF := C4L->C4L_VLBCOF * (C4L->C4L_ALQCOF / 100)
		
		If !(Round(C4L->C4L_VLRCOF,2) == Round(nValCOF,2))
			AADD(aLogErro,{"C4L_VLRCOF","000525", "C4L",nRecno }) //STR0525 - "O valor do COFINS deve corresponder ao valor da base de cálculo multiplicado pela alíquota aplicável do COFINS."   
		EndIf  
	EndIf
	

	//INICIO C4M
	C4M->( DBSetOrder(1) )
	
	cC4MKey := C4L->C4L_ID
	If C4M->( MsSeek( xFilial("C4M") + cC4MKey ) )

		Do While !C4M->( Eof() ) .And. cC4MKey == C4M->C4M_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C4M->C4M_NUMPRO)
				AADD(aLogErro,{"C4M_NUMPRO","000010", "C4L",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C4M->C4M_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C4M->C4M_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, { "C4L", "C4M_NUMPRO", nRecno } )
			EndIf	

			C4M->( DbSkip() )
		EndDo
	EndIf
	//FIM C4M

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4L", cStatus )

Else
	AADD(aLogErro,{"C4L_ID","000305","C4L",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
