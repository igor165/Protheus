#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"    
#INCLUDE "TAFA075.CH"

STATIC aCmpsAlts	:=	{}

//--------------------------------------------------------------------
/*/{Protheus.doc} TAFA075
Cadastro MVC - Credito de ICMS sobre Ativo Permanente

@author Rodrigo Aguilar
@since 13/08/2012
@version 1.0

/*/
//-------------------------------------------------------------------
Function TAFA075
Local	oBrw	:= FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Crédito de ICMS sobre Ativo Permanente"                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
oBrw:SetAlias( 'C4R' )
oBrw:SetMenuDef( 'TAFA075' )
oBrw:SetCacheView(.F.)
oBrw:Activate()  

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@return aRotina - Array com as opcoes de menu

@author Rodrigo Aguilar
@since 13/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , "Taf075Vld" , "2" } )
aRotina := xFunMnuTAF( "TAFA075" , , aFuncao)

Return( aRotina )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Rodrigo Aguilar
@since 13/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruC4R 	:= 	FWFormStruct( 1, 'C4R' )
Local oStruC4S 	:= 	FWFormStruct( 1, 'C4S' )
Local oStruC4T 	:= 	FWFormStruct( 1, 'C4T' )
Local oStruC4U 	:= 	FWFormStruct( 1, 'C4U' )
Local oStruC4V 	:= 	FWFormStruct( 1, 'C4V' )
Local oModel		:=	MPFormModel():New( 'TAFA075' ,,{ |oModel| ValidModel( oModel ) },{|oModel| SaveModel(oModel)} )

aCmpsAlts	:=	{}
      
oModel:AddFields('MODEL_C4R', /*cOwner*/, oStruC4R )

oModel:AddGrid('MODEL_C4S', 'MODEL_C4R', oStruC4S)  
oModel:GetModel( 'MODEL_C4S' ):SetUniqueLine( { 'C4S_INDBEM', 'C4S_DTMOV', 'C4S_TPMOV' } )

oModel:AddGrid('MODEL_C4T', 'MODEL_C4S', oStruC4T)   
oModel:GetModel( 'MODEL_C4T' ):SetUniqueLine( { 'C4T_DINIPR', 'C4T_DFINPR', 'C4T_NUMPAR' } )
oModel:GetModel( 'MODEL_C4T' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C4U', 'MODEL_C4S', oStruC4U)   
oModel:GetModel( 'MODEL_C4U' ):SetUniqueLine( { 'C4U_INDEMT', 'C4U_CODPAR', 'C4U_CODMOD', 'C4U_SERIE', 'C4U_NUMDOC', 'C4U_DTEMIS' } )
oModel:GetModel( 'MODEL_C4U' ):SetOptional( .T. )

oModel:AddGrid('MODEL_C4V', 'MODEL_C4U', oStruC4V)   
oModel:GetModel( 'MODEL_C4V' ):SetUniqueLine( { 'C4V_NUMITE', 'C4V_CODITE' })
oModel:GetModel( 'MODEL_C4V' ):SetOptional( .T. )

oModel:SetRelation( 'MODEL_C4S' , { { 'C4S_FILIAL' , 'xFilial( "C4S" )' } , { 'C4S_ID' , 'C4R_ID' } } , C4S->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C4T' , { { 'C4T_FILIAL' , 'xFilial( "C4T" )' } , { 'C4T_ID' , 'C4R_ID' },  { 'C4T_INDBEM ' , 'C4S_INDBEM' }, { 'C4T_DTMOV' , 'C4S_DTMOV' },{ 'C4T_TPMOV' , 'C4S_TPMOV' }} , C4T->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C4U' , { { 'C4U_FILIAL' , 'xFilial( "C4U" )' } , { 'C4U_ID' , 'C4R_ID' },  { 'C4U_INDBEM ' , 'C4S_INDBEM' }, { 'C4U_DTMOV' , 'C4S_DTMOV' },{ 'C4U_TPMOV' , 'C4S_TPMOV' }} , C4U->( IndexKey( 1 ) ) )
oModel:SetRelation( 'MODEL_C4V' , { { 'C4V_FILIAL' , 'xFilial( "C4V" )' } , { 'C4V_ID' , 'C4R_ID' },  { 'C4V_INDBEM'  , 'C4S_INDBEM' }, { 'C4V_DTMOV' , 'C4S_DTMOV' },{ 'C4V_TPMOV' , 'C4S_TPMOV' },{ 'C4V_INDEMT' , 'C4U_INDEMT' },{ 'C4V_CODPAR' , 'C4U_CODPAR' },{ 'C4V_CODMOD' , 'C4U_CODMOD' },{ 'C4V_SERIE' , 'C4U_SERIE' },{ 'C4V_NUMDOC' , 'C4U_NUMDOC' },{ 'C4V_DTEMIS' , 'C4U_DTEMIS' }} , C4V->( IndexKey( 1 ) ) )

oModel:GetModel( "MODEL_C4R" ):SetPrimaryKey( { "C4R_DTINI", "C4R_DTFIN" } )                                                                                                                      

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Rodrigo Aguilar
@since 13/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 	:= 	FWLoadModel( 'TAFA075' )
Local oStruC4R 	:= 	FWFormStruct( 2, 'C4R' ) //Cred.ICMS sobre Ativo Perman
Local oStruC4S 	:= 	FWFormStruct( 2, 'C4S' ) //Movto.Bem.Comp.Atv.Imobilizado
Local oStruC4T 	:= 	FWFormStruct( 2, 'C4T' ) //Outros Créditos CIAP
Local oStruC4U 	:= 	FWFormStruct( 2, 'C4U' ) //Ind.Doc.Fiscais - CIAP
Local oStruC4V 	:= 	FWFormStruct( 2, 'C4V' ) //Ind.It.Doc.Fis - CIAP
Local oView 	:= 	FWFormView():New()

oView:SetModel( oModel )

oView:AddField( 'VIEW_C4R', oStruC4R, 'MODEL_C4R' )
oView:EnableTitleView( 'VIEW_C4R', STR0002) //"Informações de Crédito de Icms Sobre Ativo Permanente"

oView:AddGrid ( 'VIEW_C4S', oStruC4S, 'MODEL_C4S' )
oView:EnableTitleView( 'VIEW_C4S', STR0003) //"Movimentação do Bem/Componente referente Ativo Imobilizado"

oView:AddGrid ( 'VIEW_C4T', oStruC4T, 'MODEL_C4T' )
//oView:EnableTitleView( 'VIEW_C4T', STR0004) 

oView:AddGrid ( 'VIEW_C4U', oStruC4U, 'MODEL_C4U' )
//oView:EnableTitleView( 'VIEW_C4U', STR0005) 

oView:AddGrid ( 'VIEW_C4V', oStruC4V, 'MODEL_C4V' )
oView:EnableTitleView( 'VIEW_C4V', STR0004) //"Itens do Documento Fiscal"

oView:CreateHorizontalBox( 'FIELDSC4R', 20 )          
oView:CreateHorizontalBox( 'GRIDC4S', 30 ) 

oView:CreateHorizontalBox( 'PANFOLDER1', 50 )
oView:CreateFolder( 'FOLDER1', 'PANFOLDER1' )

oView:AddSheet( 'FOLDER1', 'ABA01', STR0005) //"Outros Créditos CIAP"
oView:CreateHorizontalBox( 'GRIDC4T', 100,,, 'FOLDER1', 'ABA01' )

oView:AddSheet( 'FOLDER1', 'ABA02', STR0006) //"Documentos Fiscais" 
oView:CreateHorizontalBox( 'GRIDC4U', 30,,, 'FOLDER1', 'ABA02' )
oView:CreateHorizontalBox( 'GRIDC4V', 70,,, 'FOLDER1', 'ABA02' )

oView:SetOwnerView( 'VIEW_C4R', 'FIELDSC4R' )
oView:SetOwnerView( 'VIEW_C4S', 'GRIDC4S' )
oView:SetOwnerView( 'VIEW_C4T', 'GRIDC4T' )
oView:SetOwnerView( 'VIEW_C4U', 'GRIDC4U' )
oView:SetOwnerView( 'VIEW_C4V', 'GRIDC4V' )

If TamSX3("C4U_CODPAR")[1] == 36
	oStruC4U:RemoveField("C4U_CODPAR")
	oStruC4U:SetProperty("C4U_CPARTI", MVC_VIEW_ORDEM, "04" )	
EndIf
If TamSX3("C4V_CODITE")[1] == 36
	oStruC4V:RemoveField("C4V_CODITE")
	oStruC4V:SetProperty("C4V_ITEM", MVC_VIEW_ORDEM, "10" )	
EndIf


Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ValidModel
Funcao de valida da inclusao dos dados, chamada no final, no momento da gravacao do modelo

@param  oModel -> Modelo de dados
@return .T. ou  .F.

@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ValidModel( oModel )
Local 	nOperation 	:= 	oModel:GetOperation()
Return XFUNReflex( nOperation , aCmpsAlts , 'TAFA075' )
//-------------------------------------------------------------------
/*/{Protheus.doc} A075LogAlt
Funcao utilizada para atualizar uma variavel STATIC tratada no SAVE no modelo.
	Tratamento passado por framework para podermos identificar os campos alterados
	no modelo para podermos exibir alguns alertas.

@param  Nil

@return Sempre .T.
                
@author Gustavo G. Rueda
@since 01/08/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function A075LogAlt()

If ValType( aCmpsAlts ) == "A" .And. aScan( aCmpsAlts , ReadVar() ) == 0
	aAdd( aCmpsAlts , ReadVar() )
EndIf

Return .T.

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
		TAFAltStat( "C4R", " " )
	EndIf  

	FwFormCommit( oModel )
			
End Transaction 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF075Vld

Funcao que valida os dados do registro posicionado,
verificando se ha incoerencias nas informacoes

lJob - Informa se foi chamado por Job

@return .T.

@author Anderson Costa
@since 19/02/2014
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF075Vld(cAlias,nRecno,nOpc,lJob)

Local aLogErro := {}
Local cStatus  := ""
Local cChave   := ""
Local nValPIS  := 0
Local nValCOF	 := 0
Local nSomPar	 := 0
Local nOutCre	 := 0
Local cC4SKey  := ""
Local cC4TKey  := ""
Local cC4UKey  := ""
Local cC4VKey  := ""

Default lJob := .F. 

//Garanto que o Recno seja da tabela referente ao cadastro principal
nRecno := C4R->( Recno() )

If C4R->C4R_STATUS $ ( " |1" )

	//---------------------
	// Campos obrigatórios
	//---------------------
	If Empty(C4R->C4R_DTINI)
		AADD(aLogErro,{"C4R_DTINI","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4R->C4R_DTFIN)
		AADD(aLogErro,{"C4R_DTFIN","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4R->C4R_SOMPAR)
		AADD(aLogErro,{"C4R_SOMPAR","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4R->C4R_VLTREX)
		AADD(aLogErro,{"C4R_VLTREX","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4R->C4R_VLTOTS)
		AADD(aLogErro,{"C4R_VLTOTS","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4R->C4R_INDPVL)
		AADD(aLogErro,{"C4R_INDPVL","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	If Empty(C4R->C4R_VLICAP)
		AADD(aLogErro,{"C4R_VLICAP","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
	EndIf

	//--------------------
	// Regras específicas
	//--------------------
	If !Empty(C4R->C4R_VLTREX) .And. !Empty(C4R->C4R_VLTOTS)
		If C4R->C4R_VLTREX > C4R->C4R_VLTOTS
			AADD(aLogErro,{"C4R_VLTREX","000532", "C4R",nRecno }) //STR0532 - "O valor informado deve ser menor ou igual ao valor informado no campo 'V Tot Saidas'."
		EndIf

		If !(C4R->C4R_INDPVL == Round(C4R->C4R_VLTREX / C4R->C4R_VLTOTS,8))
			AADD(aLogErro,{"C4R_INDPVL","000533", "C4R",nRecno }) //STR0533 - "O índice deve corresponder ao resultado da divisão do campo 'Vl Trib Exp' pelo campo 'V Tot Saidas'."
		EndIf
	EndIf	

	If !Empty(C4R->C4R_SOMPAR) .And. !Empty(C4R->C4R_INDPVL)
		If !(C4R->C4R_VLICAP == ( Round( C4R->C4R_SOMPAR * C4R->C4R_INDPVL, 2 ) ) )
			AADD(aLogErro,{"C4R_VLICAP","000534", "C4R",nRecno }) //STR0534 - "O valor deve corresponder à multiplicação do campo 'Som. Par. ICMS' pelo índice calculado no campo 'Par. S. Trb. Exp.'"
		EndIf   
	EndIf	

	//INICIO C4S
	C4S->( DBSetOrder(1) )
	
	cC4SKey := C4R->C4R_ID
	If C4S->( MsSeek( xFilial("C4S") + cC4SKey ) )

		Do While !C4S->( Eof() ) .And. cC4SKey == C4S->C4S_ID

			//---------------------
			// Campos obrigatórios
			//---------------------
			If Empty(C4S->C4S_INDBEM)
				AADD(aLogErro,{"C4S_INDBEM","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C4S->C4S_DTMOV)
				AADD(aLogErro,{"C4S_DTMOV","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			If Empty(C4S->C4S_TPMOV)
				AADD(aLogErro,{"C4S_TPMOV","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf

			//------------------
			// Consultas padrão
			//------------------
			If !Empty(C4S->C4S_INDBEM)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C4S->C4S_INDBEM
				xValRegTab("C2L",cChave,3,,@aLogErro,, { "C4R", "C4S_INDBEM", nRecno } )
			EndIf	

			If !Empty(C4S->C4S_TPMOV)
				//Chave de busca na tabela FILHO ou Consulta padrao
				cChave := C4S->C4S_TPMOV
				xValRegTab("C52",cChave,3,,@aLogErro,, { "C4R", "C4S_TPMOV", nRecno })
			EndIf
			
			//--------------------
			// Regras específicas
			//--------------------
			If !Empty(C4S->C4S_VLPRPS) .And. Empty(C4S->C4S_NUMPAR)
				AADD(aLogErro,{"C4S_NUMPAR","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			If !Empty(C4S->C4S_NUMPAR) .And. Empty(C4S->C4S_VLPRPS)
				AADD(aLogErro,{"C4S_VLPRPS","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
			EndIf
			
			//INICIO C4T
			C4T->( DBSetOrder(1) )
			
			cC4TKey := C4S->(C4S_ID + C4S_INDBEM + DToS(C4S_DTMOV) + C4S_TPMOV)
			If C4T->( MsSeek( xFilial("C4T") + cC4TKey ) )
		
				Do While !C4T->( Eof() ) .And. cC4TKey == C4T->(C4T_ID + C4T_INDBEM + DToS(C4T_DTMOV) + C4T_TPMOV)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C4T->C4T_DINIPR)
						AADD(aLogErro,{"C4T_DINIPR","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4T->C4T_DFINPR)
						AADD(aLogErro,{"C4T_DFINPR","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4T->C4T_NUMPAR)
						AADD(aLogErro,{"C4T_NUMPAR","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4T->C4T_VLPRIC)
						AADD(aLogErro,{"C4T_VLPRIC","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4T->C4T_VLSTRB)
						AADD(aLogErro,{"C4T_VLSTRB","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4T->C4T_VLTOT)
						AADD(aLogErro,{"C4T_VLTOT","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4T->C4T_IDPTVL)
						AADD(aLogErro,{"C4T_IDPTVL","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4T->C4T_VLOTCR)
						AADD(aLogErro,{"C4T_VLOTCR","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//--------------------
					// Regras específicas
					//--------------------
					If !Empty(C4T->C4T_VLSTRB) .And. !Empty(C4T->C4T_VLTOT)
						If !(C4T->C4T_IDPTVL == Round(C4T->C4T_VLSTRB / C4T->C4T_VLTOT,8))
							AADD(aLogErro,{"C4T_IDPTVL","000535", "C4R",nRecno }) //STR0535 - "O índice deve corresponder ao resultado da divisão do campo 'Vl. Sd. Trb. Exp.' pelo campo 'Vl. Said. Trib.'."
						EndIf
					EndIf

					If !Empty(C4T->C4T_VLPRIC) .And. !Empty(C4T->C4T_IDPTVL)
						If !(C4T->C4T_VLOTCR <= Round(C4T->C4T_VLPRIC * C4T->C4T_IDPTVL,2))
							AADD(aLogErro,{"C4T_VLOTCR","000536", "C4R",nRecno }) //STR0536 - "O valor deve ser menor ou igual ao resultado da multiplicação do campo 'Vlr. Parc. Icm' pelo índice 'Ind. Part. Val'."
						EndIf
					EndIf
					
					nOutCre := nOutCre + C4T->C4T_VLOTCR 
		
					C4T->( DbSkip() )
				EndDo
			EndIf
			//FIM C4T

			//INICIO C4U
			C4U->( DBSetOrder(1) )
			
			cC4UKey := C4S->(C4S_ID + C4S_INDBEM + DToS(C4S_DTMOV) + C4S_TPMOV)
			If C4U->( MsSeek( xFilial("C4U") + cC4UKey ) )
		
				Do While !C4U->( Eof() ) .And. cC4UKey == C4U->(C4U_ID + C4U_INDBEM + DToS(C4U_DTMOV) + C4U_TPMOV)
		
					//---------------------
					// Campos obrigatórios
					//---------------------
					If Empty(C4U->C4U_INDEMT)
						AADD(aLogErro,{"C4U_INDEMT","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4U->C4U_CODPAR)
						AADD(aLogErro,{"C4U_CODPAR","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4U->C4U_CODMOD)
						AADD(aLogErro,{"C4U_CODMOD","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4U->C4U_NUMDOC)
						AADD(aLogErro,{"C4U_NUMDOC","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					If Empty(C4U->C4U_DTEMIS)
						AADD(aLogErro,{"C4U_DTEMIS","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
					EndIf

					//------------------
					// Consultas padrão
					//------------------
					If !Empty(C4U->C4U_CODPAR)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C4U->C4U_CODPAR
						xValRegTab("C1H",cChave,5,,@aLogErro,, { "C4R", "C4U_CODPAR",nRecno } )
					EndIf	

					If !Empty(C4U->C4U_CODMOD)
						//Chave de busca na tabela FILHO ou Consulta padrao
						cChave := C4U->C4U_CODMOD
						xValRegTab("C01",cChave,3,,@aLogErro,, { "C4R", "C4U_CODMOD",nRecno } )
					EndIf	

					//--------
					// Combos
					//--------
					If !Empty(C4U->C4U_INDEMT)
						If !C4U->C4U_INDEMT $ ('0|1')
							AADD(aLogErro,{"C4U_INDEMT","000006", "C4R",nRecno }) //STR0006 - "Conteúdo do campo não condiz com as opções possíveis"   
						EndIf
					EndIf
	
					//INICIO C4V
					C4V->( DBSetOrder(1) )
					
					cC4VKey := C4U->(C4U_ID + C4U_INDBEM + DToS(C4U_DTMOV) + C4U_TPMOV + C4U_INDEMT + C4U_CODPAR + C4U_CODMOD + C4U_SERIE + C4U_NUMDOC + DToS(C4U_DTEMIS))
					If C4V->( MsSeek( xFilial("C4V") + cC4VKey ) )
				
						Do While !C4V->( Eof() ) .And. cC4VKey == C4V->(C4V_ID + C4V_INDBEM + DToS(C4V_DTMOV) + C4V_TPMOV + C4V_INDEMT + C4V_CODPAR + C4V_CODMOD + C4V_SERIE + C4V_NUMDOC + DToS(C4V_DTEMIS))
				
							//---------------------
							// Campos obrigatórios
							//---------------------
							If Empty(C4V->C4V_NUMITE)
								AADD(aLogErro,{"C4V_NUMITE","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
							EndIf

							If Empty(C4V->C4V_CODITE)
								AADD(aLogErro,{"C4V_CODITE","000010", "C4R",nRecno }) //STR0010 - "Campo Inconsistente ou Vazio"
							EndIf

							//------------------
							// Consultas padrão
							//------------------
							If !Empty(C4V->C4V_CODITE)
								//Chave de busca na tabela FILHO ou Consulta padrao
								cChave := C4V->C4V_CODITE
								xValRegTab("C1L",cChave,3,,@aLogErro,, { "C4R", "C4V_CODITE", nRecno } )
							EndIf	
				
							C4V->( DbSkip() )
						EndDo
					EndIf
					//FIM C4V		
					C4U->( DbSkip() )
				EndDo
			EndIf
			//FIM C4U

			nSomPar := nSomPar + C4S->C4S_VLPRPS

			C4S->( DbSkip() )
		EndDo
	EndIf
	//FIM C4S
	
	If !Empty(C4R->C4R_SOMPAR) .And. !Empty(nSomPar)
		If !(C4R->C4R_SOMPAR == nSomPar)
			AADD(aLogErro,{"C4R_SOMPAR","000537", "C4R",nRecno }) //STR0537 - "O valor deve corresponder ao somatório de todos os valores informados no campo 'Vl. Par. Apr.' (C4S_VLPRPS)."
		EndIf 
	EndIf
	
	If !Empty(C4R->C4R_VLOCRD) .And. !Empty(nOutCre)
		If !(C4R->C4R_VLOCRD == nOutCre)
			AADD(aLogErro,{"C4R_VLOCRD","000538", "C4R",nRecno }) //STR0538 - "O valor deve corresponder ao somatório de todos os valores informados no campo 'Vlr. Out. Crd.' (C4T_VLOTCR)."
		EndIf 
	EndIf

	//ATUALIZO O STATUS DO REGISTRO
	cStatus := Iif(Len(aLogErro) > 0,"1","0")
	TAFAltStat( "C4R", cStatus )

Else
	AADD(aLogErro,{"C4R_ID","000305","C4R",nRecno}) //Registros que já foram transmitidos ao Fisco, não podem ser validados
EndIf

//Não apresento o alert quando utilizo o JOB para validar
If !lJob
	xValLogEr(aLogErro)
EndIf	

Return(aLogErro)
