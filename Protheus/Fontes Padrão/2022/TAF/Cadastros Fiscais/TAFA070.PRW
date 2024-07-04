#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA070.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA070
Cadastro MVC de Operacoes da atividade imobiliaria - Unidade imobiliaria vendida

@author Fabio V Santana
@since 26/07/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA070
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription(STR0001)//Operacoes da atividade imobiliaria - Unidade imobiliaria vendida
oBrw:SetAlias( 'C40')
oBrw:SetMenuDef( 'TAFA070' )
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf070Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA070" , , aFuncao)

Return( aRotina )      
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC40 	:= 	FWFormStruct( 1, 'C40' ) 
Local oStruC44 	:= 	FWFormStruct( 1, 'C44' )
Local oStruC45 	:= 	FWFormStruct( 1, 'C45' )
Local oStruC43 	:= 	FWFormStruct( 1, 'C43' )

Local oModel	:= MPFormModel():New( 'TAFA070',,{ |oModel| ValidModel( oModel ) } ,{|oModel| SaveModel(oModel)})

oModel:AddFields('MODEL_C40', /*cOwner*/, oStruC40)

oModel:AddGrid('MODEL_C44', 'MODEL_C40', oStruC44)
oModel:GetModel( 'MODEL_C44' ):SetUniqueLine( { 'C44_CSTPIS','C44_CSTCOF'} )  

oModel:AddGrid('MODEL_C45', 'MODEL_C40', oStruC45)
oModel:GetModel( 'MODEL_C45' ):SetUniqueLine( { 'C45_CSTPIS','C45_CSTCOF'} )  

oModel:AddGrid('MODEL_C43', 'MODEL_C40', oStruC43)
oModel:GetModel( 'MODEL_C43' ):SetUniqueLine( { 'C43_NUMPRO'} )   

oModel:SetRelation( 'MODEL_C44' , { { 'C44_FILIAL' , 'xFilial( "C44" )' } , { 'C44_ID' , 'C40_ID' }} , C44->( IndexKey( 1 ) ) ) 
oModel:GetModel( 'MODEL_C44' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C45' , { { 'C45_FILIAL' , 'xFilial( "C45" )' } , { 'C45_ID' , 'C40_ID' }} , C45->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C45' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C43' , { { 'C43_FILIAL' , 'xFilial( "C43" )' } , { 'C43_ID' , 'C40_ID' }} , C43->( IndexKey( 1 ) ) )
oModel:GetModel( 'MODEL_C43' ):SetOptional( .T. )                                                                                            

oModel:GetModel( "MODEL_C40" ):SetPrimaryKey( { "C40_IO", "C40_UI", "C40_IEMP", "C40_CPF", "C40_CNPJ", "C40_DTO", "C40_CSTP", "C40_CSTC" } )                                                                              

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Fabio V Santana
@since 26/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA070' )
Local oStruC40 	:= 	FWFormStruct( 2, 'C40' )
Local oStruC44 	:= 	FWFormStruct( 2, 'C44' )
Local oStruC45 	:= 	FWFormStruct( 2, 'C45' ) 
Local oStruC43 	:= 	FWFormStruct( 2, 'C43' )

Local oView 		:= 	FWFormView():New()

oView:SetModel( oModel )
oView:AddField( 'VIEW_C40', oStruC40, 'MODEL_C40' )
oView:EnableTitleView( 'VIEW_C40', STR0001) //Operacoes da atividade imobiliaria - Unidade imobiliaria vendida

oView:AddGrid ( 'VIEW_C44', oStruC44, 'MODEL_C44' )
oView:AddGrid ( 'VIEW_C45', oStruC45, 'MODEL_C45' )
oView:AddGrid ( 'VIEW_C43', oStruC43, 'MODEL_C43' )

oView:CreateHorizontalBox( 'FIELDSC40', 60 )          
oView:CreateHorizontalBox( 'FOLDERGERAL', 40 )

oView:CreateFolder( 'FOLDER1', 'FOLDERGERAL' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0002) //Custos Incorridos da UI
oView:CreateHorizontalBox( 'GRIDC44', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0003) //Custos Orçados da UI Vendida
oView:CreateHorizontalBox( 'GRIDC45', 100,,, 'FOLDER1', 'ABA02' )

oView:AddSheet( 'FOLDER1', 'ABA03', STR0004) //Processos Referenciados da UI
oView:CreateHorizontalBox( 'GRIDC43', 100,,, 'FOLDER1', 'ABA03' )

oView:SetOwnerView( 'VIEW_C40', 'FIELDSC40' )
oView:SetOwnerView( 'VIEW_C44', 'GRIDC44' )
oView:SetOwnerView( 'VIEW_C45', 'GRIDC45' ) 
oView:SetOwnerView( 'VIEW_C43', 'GRIDC43' )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de validacao de alguns campos do model.

@param  oModel - parametro com o Model MVC 

@return lRet - Flag de validacao, onde .T. eh valido e .F. NAO valido

@author Fabio V santana
@since 18/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local	lRet		:=	.T.

Local	cCNPJ 	:= 	oModel:GetValue( 'MODEL_C40' , 'C40_CNPJ' )
Local	cCPF 	:= 	oModel:GetValue( 'MODEL_C40' , 'C40_CPF' )

//Validacao do campo CNPJ/CPF, dependendo do Tipo de Participante. PJ habilita o CNPJ, Fisica o CPF.
If (Empty(cCPF).And.Empty(cCNPJ)) .Or. (!Empty(cCPF).And.!Empty(cCNPJ))
	Help( ,,"CNPJOUCPF",,, 1, 0 ) 
	lRet	:=	.F.
EndIf

Return lRet

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
		TAFAltStat( "C40", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} TAF070Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF070Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro	:= {}
Local cStatus		:= ""
Local cChave		:= ""
Local cC43Key		:= ""
Local cC44Key		:= ""
Local cC45Key		:= ""
Local nValBase	:= 0
Local nValPIS		:= 0
Local nValCOF		:= 0

Default lJob := .F.

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C40->( Recno() )

If C40->C40_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C40->C40_DTO)
		AADD(aLogErro,{"C40_DTO","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C40->C40_IO)
		AADD(aLogErro,{"C40_IO","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C40->C40_UI)
		AADD(aLogErro,{"C40_UI","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C40->C40_IEMP)
		AADD(aLogErro,{"C40_IEMP","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C40->C40_CSTP)
		AADD(aLogErro,{"C40_CSTP","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C40->C40_CSTC)
		AADD(aLogErro,{"C40_CSTC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C40->C40_VTOTVE)
		AADD(aLogErro,{"C40_VTOTVE","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C40->C40_VTOTRE)
		AADD(aLogErro,{"C40_VTOTRE","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//------------------
	// Consultas padrão
	//------------------
	If !Empty(C40->C40_IO)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C40->C40_IO
		xValRegTab("C41",cChave,3,,@aLogErro,, { "C40", "C40_IO", nRecno } )
	EndIf	

	If !Empty(C40->C40_UI)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C40->C40_UI
		xValRegTab("C42",cChave,3,,@aLogErro,, { "C40", "C40_UI", nRecno } )
	EndIf	

	If !Empty(C40->C40_CSTP)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C40->C40_CSTP
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C40", "C40_CSTP", nRecno } )
	EndIf	

	If !Empty(C40->C40_CSTC)
		//Chave de busca na tabela FILHO ou Consulta padrao
		cChave := C40->C40_CSTC
		xValRegTab("C17",cChave,3,,@aLogErro,, { "C40", "C40_CSTC", nRecno } )
	EndIf	

	//--------
	// Combos
	//--------
	If !C40->C40_INDNAT $ (" |1|2|3|4")
		AADD(aLogErro,{"C40_INDNAT","000006", "C40",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
	EndIf	

	//INICIO C43
	C43->( DBSetOrder(1) )
	
	cC43Key := C40->C40_ID
	If C43->( MsSeek( xFilial("C43") + cC43Key ) )

		Do While !C43->( Eof() ) .And. cC43Key == C43->C43_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C43->C43_NUMPRO)
				AADD(aLogErro,{"C43_NUMPRO","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C43->C43_NUMPRO)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C43->C43_NUMPRO
				xValRegTab("C1G",cChave,3,,@aLogErro,, { "C40", "C43_NUMPRO", nRecno } )
			EndIf	

			C43->( DbSkip() )
		EndDo
	EndIf
	//FIM C43

	//INICIO C44
	C44->( DBSetOrder(1) )
	
	cC44Key := C40->C40_ID
	If C44->( MsSeek( xFilial("C44") + cC44Key ) )

		Do While !C44->( Eof() ) .And. cC44Key == C44->C44_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C44->C44_CSTPIS)
				AADD(aLogErro,{"C44_CSTPIS","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CSTCOF)
				AADD(aLogErro,{"C44_CSTCOF","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_INCANT)
				AADD(aLogErro,{"C44_INCANT","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_INCESC)
				AADD(aLogErro,{"C44_INCESC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_INCACU)
				AADD(aLogErro,{"C44_INCACU","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_EXCBC)
				AADD(aLogErro,{"C44_EXCBC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_BCINC)
				AADD(aLogErro,{"C44_BCINC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_ALQPIS)
				AADD(aLogErro,{"C44_ALQPIS","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDACP)
				AADD(aLogErro,{"C44_CRDACP","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDANP)
				AADD(aLogErro,{"C44_CRDANP","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDDEP)
				AADD(aLogErro,{"C44_CRDDEP","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDFUP)
				AADD(aLogErro,{"C44_CRDFUP","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_ALQCOF)
				AADD(aLogErro,{"C44_ALQCOF","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDACC)
				AADD(aLogErro,{"C44_CRDACC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDANC)
				AADD(aLogErro,{"C44_CRDANC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDDEC)
				AADD(aLogErro,{"C44_CRDDEC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C44->C44_CRDFUC)
				AADD(aLogErro,{"C44_CRDFUC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C44->C44_CSTPIS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C44->C44_CSTPIS
				xValRegTab("C17",cChave,3,,@aLogErro,, { "C40", "C44_CSTPIS", nRecno })
			EndIf	

			If !Empty(C44->C44_CSTCOF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C44->C44_CSTCOF
				xValRegTab("C17",cChave,3,,@aLogErro,, { "C40", "C44_CSTCOF", nRecno })
			EndIf	

			C44->( DbSkip() )
		EndDo
	EndIf
	//FIM C44

	//INICIO C45
	C45->( DBSetOrder(1) )
	
	cC45Key := C40->C40_ID
	If C45->( MsSeek( xFilial("C45") + cC45Key ) )

		Do While !C45->( Eof() ) .And. cC45Key == C45->C45_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C45->C45_CSTPIS)
				AADD(aLogErro,{"C45_CSTPIS","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C45->C45_CSTCOF)
				AADD(aLogErro,{"C45_CSTCOF","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C45->C45_CUSORC)
				AADD(aLogErro,{"C45_CUSORC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C45->C45_VEXC)
				AADD(aLogErro,{"C45_VEXC","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C45->C45_CUSAJU)
				AADD(aLogErro,{"C45_CUSAJU","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If Empty(C45->C45_BCCRED)
				AADD(aLogErro,{"C45_BCCRED","000010", "C40",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C45->C45_CSTPIS)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C45->C45_CSTPIS
				xValRegTab("C17",cChave,3,,@aLogErro,, {"C40", "C45_CSTPIS", nRecno } )
			EndIf	

			If !Empty(C45->C45_CSTCOF)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C45->C45_CSTCOF
				xValRegTab("C17",cChave,3,,@aLogErro,, {"C40", "C45_CSTCOF", nRecno })
			EndIf	

			C45->( DbSkip() )
		EndDo
	EndIf
	//FIM C45

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C40", cStatus )

Else
	AADD(aLogErro,{"C40_ID","000305","C40",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)