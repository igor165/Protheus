#Include 'TmsAF12.ch'
#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"

Static cRota 		:= ''
Static aRoteiro 	:= {}
Static nQtdFolder	:= 1 
Static cSerTms		:= ''
Static aRetpag		:= {}
Static aRetpagOri	:= {}
Static aDelDocs		:= {}
Static lExbSugRot 	:= SuperGetMV("MV_EXSGROT",.F., .F.) // Verifica se exibe seguestão de Rota
Static lEditKM		:= SuperGetMV("MV_TMALTKM",.F., .F.) 
Static aNewRot		:= {}
Static cFilVge   	:= ""
Static cViagem   	:= ""
Static aMDFe     	:= {}
Static lTMF12Rot 	:= ExistBlock("TMF12Rot")	//-- Manipulação e validação do Roteiro
Static lF12Disarm	:= .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} Tmsaf12
Tela de Roteiro da Viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Function TMSAF12()

Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DJF")
oBrowse:SetDescription(STR0001) //'Roteiro da Viagem'	
oBrowse:Activate()
oBrowse:SetCacheView(.F.) // Desabilita Cache da View, pois gera colunas dinamicamente
// Limpa as Variaveis Staticas 
Af12ClrSts()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Tela de Roteiro da viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0	
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel		:= Nil
Local oStruCab 	:= Nil
Local oStruDJF 	:= TMF12DfStr(1)
Local oStruDJK	:= F12StrDJK(1)  
Local nCnt2			:= 0
Local bLoadGrig	:= NIL

oStruCab:= FWFormModelStruct():New()

aRoteiro := {}

	//-- Campo Dummy (Sem Utilização - Somente Para Compatibilidade MVC)
	oStruCab:AddField(	'RPT'			, ; //-- Titulo do campo  //-- "Repete Valores Para Todos Itens"
							'RPT'			, ; //-- ToolTip do campo //-- "Repete Valores Para Todos Itens"
							'RPT_ALL' 		, ; //-- Nome do Campo
							'L' 			, ; //-- Tipo do campo
							1	 			, ; //-- Tamanho do campo
							0 				, ; //-- Decimal do campo
							NIL				, ; //-- Code-block de validação do campo
							NIL				, ; //-- Code-block de validação When do campo
							{} 				, ; //-- Lista de valores permitido do campo
							.F.				, ; //-- Indica se o campo tem preenchimento obrigatório
							NIL				, ; //-- Code-block de inicializacao do campo
							NIL 			, ; //-- Indica se trata de um campo chave
							NIL 			, ; //-- Indica se o campo pode receber valor em uma operação de update.
							.T. 			)   //-- Indica se o campo é virtual


oModel:= MpFormMOdel():New("TMSAF12",  /*bPreValid*/ ,{ |oModel| PosVldMdl(oModel) },{ |oModel| CommitMdl(oModel) } ,/*bCancel*/ )
oModel:SetDescription(STR0001) //'Roteiro da Viagem'	

oModel:AddFields("MdFieldDJF",Nil,oStruCab,/*prevalid*/,,/*bCarga*/{||}) 
oModel:GetModel("MdFieldDJF"):SetDescription( "CAB" )//-- "Agendamento"
oModel:SetPrimaryKey({ "DJF_ROTA","DJF_ROTEIR" ,'DJF_CLIENT', 'DJF_LOJA','DJF_SEQEND','DJF_SEQUEN'})

For nCnt2:= 1 To nQtdFolder
	bLoadGrig := &("{|oModel| TmsF10Qry1( oModel, @cRota,.T.,"+ cValToChar(nCnt2) +",cSerTms,aRetpag,aRetpagOri,cFilVge,cViagem)}")
	oModel:AddGrid("MdGridDJF"+AllTrim(Str(nCnt2)), "MdFieldDJF", oStruDJF , {|oModelGrid,nLine,cAction| PreVldMdl(oModelGrid,nLine,cAction)} , /*bLinePost*/	 , /*bPre*/,/*bpos*/,bLoadGrig)
	
	oModel:GetModel( "MdGridDJF"+AllTrim(Str(nCnt2)) ):SetUniqueLine( { "DJF_ROTA","DJF_ROTEIR","DJF_CLIENT", "DJF_LOJA", "DJF_SEQUEN" } )
	
	oModel:GetModel("MdGridDJF"+AllTrim(Str(nCnt2))):SetDescription( "GRID"+AllTrim(Str(nCnt2)) )//-- "Agendamento"


	// Desabilita insersão de Linhas para os Grids diferentes do Geral
	If nCnt2 > 1
		oModel:GetModel("MdGridDJF"+AllTrim(Str(nCnt2))):SetOptional( .T. )
	Else
		oModel:AddGrid("MdGridDJK", "MdFieldDJF", oStruDJK ,  {|oModelGrid,nLine,cAction| PreVldDJK(oModelGrid,nLine,cAction)} , /*bLinePost*/	 , /*bPre*/,/*bpos*/,)
		oModel:GetModel("MdGridDJK"):SetUniqueLine( { "DJK_SEQUEN","DJK_EST" } )
		oModel:GetModel("MdGridDJK"):SetDescription( STR0048 )//-- "Estados de Passagem"
		oModel:GetModel("MdGridDJK"):SetNoInsertLine(.T.)
	EndIf
	
Next nCnt2 

//-- Ativação Da Model Com Execução De Rotina Posterior a Montagem Da Model
oModel:SetActivate( { |oModel| ActiveMdl( oModel ) } ) 

Return ( oModel )                   

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de Roteiro da viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oModel 		:= FwLoadModel("TMSAF12")
Local oView 		:= Nil
Local nCnt2			:= 0 
Local cNomeReduz	:= ""
Local cNomeDev	:= ""
Local oStruDJK	:= F12StrDJK(2)  //
Local oStruDJF	:= TmF12DfStr(2)
Local oStruCab	:= Nil

Local cRota   	:= ""
Local cRoteir 	:= ""
Local cFunction	:= 'TMSAF12'

IIf(ExistFunc('FWPdLogUser'),FwPdLogUser(cFunction),)
oStruCab:= FWFormViewStruct():New()
oStruCab:AddField(	'RPT_ALL'	, ; // Nome do Campo
						'01'   	, ; // Ordem
						'RPT'	, ; // Titulo do campo  		//-- "Repete Valores Para Todos Itens"
						'RPT'	, ; // Descrição do campo	//-- "Repete Valores Para Todos Itens"
						{" "}  	, ; // Array com Help
						'L'    	, ; // Tipo do campo
						''     	, ; // Picture
						NIL    	, ; // Bloco de Picture Var
						''     	, ; // Consulta F3
						.T.    	, ; // Indica se o campo é editável
						NIL    	, ; // Pasta do campo
						NIL    	, ; // Agrupamento do campo
						{ }    	, ; // Lista de valores permitido do campo (Combo)
						NIL    	, ; // Tamanho Maximo da maior opção do combo
						NIL    	, ; // Inicializador de Browse
						.T.    	, ; // Indica se o campo é virtual
						NIL      	)   // Picture Variável



oView := FwFormView():New()
oView:SetModel(oModel)

oView:CreateHorizontalBox( 'BoxOcult', 0) // Cab Oculto
oView:CreateHorizontalBox( 'BoxCorpoH', 100) // Corpo

//--Cria Folder
oView:CreateFolder( 'Folder', 'BoxCorpoH')

oView:AddField('VwFieldDJF' , oStruCab, 'MdFieldDJF' ) // ocult

//--Cria Sheet's 
For nCnt2 := 1 To nQtdFolder
	cRota   := ""
	cRoteir := ""
	If nCnt2 > 1 
		If Len(aRetpagOri) >0
			cNomeReduz := Posicione("SA1",1,FWxFilial('SA1')+aRetpagOri[nCnt2,1]+aRetpagOri[nCnt2,2],"A1_NREDUZ")
			cNomeDev   := SA1->A1_NOME			
		Else
			cNomeReduz := Posicione("SA1",1,FWxFilial('SA1')+aRetPag[nCnt2-1,2]+aRetPag[nCnt2-1,3],"A1_NREDUZ")
			cNomeDev   := SA1->A1_NOME
		EndIf
		If Empty(cNomeDev)
			cNomeReduz := STR0051	//-- "Sem Devedor"
			cNomeDev   := STR0051	//-- "Sem Devedor"
		EndIf
	EndIf	

	If Len(aRetpagOri) >0
		cRota   := aRetpagOri[nCnt2,3]
		cRoteir := aRetpagOri[nCnt2,4]
	EndIf	

	oView:AddGrid('VwGridDJF' + AllTrim(Str(nCnt2)), oStruDJF, 'MdGridDJF'+AllTrim(Str(nCnt2)))  // corpo
	oView:AddSheet('Folder',"Fld" + AllTrim(Str(nCnt2)),IIf(nCnt2==1,STR0008,AllTrim(cNomeReduz))) // "Geral "###"Cliente:"
	oView:EnableTitleView('VwGridDJF' + AllTrim(Str(nCnt2)) ,IIf(nCnt2==1,STR0008, AllTrim(cNomeDev)) + " - " + cRota + "/" + cRoteir) // "Geral "###"Cliente:"###"Rota : "
	oView:AddIncrementField('VwGridDJF' + AllTrim(Str(nCnt2)),"DJF_SEQUEN") 
	oView:SetViewProperty("VwGridDJF"+AllTrim(Str(nCnt2)), "GRIDDOUBLECLICK", {{ |oGrdView,cFieldName,nLineGrid,nLineModel| F12DbClick(oGrdView,cFieldName,nLineGrid,nLineModel)}}) 
	
	If nCnt2 == 1 // Aba Geral
		
		
		oView:CreateHorizontalBox( 'FLDGrd_' + AllTrim(Str(nCnt2)), 60,,, 'Folder', 'Fld' + Alltrim(Str(nCnt2)) )
		oView:SetOwnerView("VwGridDJF"  + AllTrim(Str(nCnt2)),"FLDGrd_" + AllTrim(Str(nCnt2)))
		
		// Grid de pontos do MDF-e
		oView:AddGrid('VwGridDJK', oStruDJK, 'MdGridDJK')
		oView:AddIncrementField('VwGridDJK',"DJK_SEQUEN") 
		oView:CreateHorizontalBox( 'FLDGrdDJK', 40,,, 'Folder', 'Fld' + Alltrim(Str(nCnt2)) )
		oView:SetOwnerView("VwGridDJK","FLDGrdDJK")	
		oView:EnableTitleView("VwGridDJK" ,STR0048) // "Estados de Passagem"
		oView:SetViewProperty("VwGridDJK", "GRIDDOUBLECLICK", {{ |oGrdView,cFieldName,nLineGrid,nLineModel| oGrdView:GetModel():SetNoInsertLine(.F.) , F12DbClick(oGrdView,cFieldName,nLineGrid,nLineModel),oGrdView:GetModel():SetNoInsertLine(.T.)}}) 
		
	Else
		oView:CreateHorizontalBox( 'FLDGrd_' + AllTrim(Str(nCnt2)), 100,,, 'Folder', 'Fld' + Alltrim(Str(nCnt2)) )
		oView:SetOwnerView("VwGridDJF"  + AllTrim(Str(nCnt2)),"FLDGrd_" + AllTrim(Str(nCnt2)))
	EndIf
	
Next nCnt2
oView:SetOwnerView('VwFieldDJF','BoxOcult')

// Ações após ativação da view e do model antes da abertura da tela
oView:SetAfterViewActivate({|oView| AfterVwAct(oView)}) 

If oModel:GetOperation() == MODEL_OPERATION_VIEW
	//-- Não Permite Abertura Da Tela De "Salvar Dados Do Formulário"
	oView:SetViewAction("ASKONCANCELSHOW",{||.F.})
EndIf

If !IsInCallStack("TMSAF12Vis")
	oView:addUserButton(STR0049, 'CLIPS', { |oView| F12DlLnDJK(oView) } ) //"Limpa.Est.Del."
EndIf

oView:SetFieldAction( 'DJF_SEQUEN'		, { |oView,cIdForm,cIdCampo,cValue| Af012Reord(oView,cIdForm,cIdCampo,cValue) } )
oView:SetFieldAction( 'DJF_CLIENT'		, { |oView,cIdForm,cIdCampo,cValue| Af12GatCli(oView,cIdForm,cIdCampo,cValue) } )
oView:SetFieldAction( 'DJF_LOJA'		, { |oView,cIdForm,cIdCampo,cValue| Af12GatCli(oView,cIdForm,cIdCampo,cValue) } )
oView:SetFieldAction( 'DJF_SEQEND'		, { |oView,cIdForm,cIdCampo,cValue| Af12GatCli(oView,cIdForm,cIdCampo,cValue) } )
Return(oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
View de Roteiro da viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         	OPERATION 1 ACCESS 0  //"Pesquisar" 
ADD OPTION aRotina TITLE STR0003 	ACTION "TMSAF12Vis" 			OPERATION 2 ACCESS 0  //"Visualizar
ADD OPTION aRotina TITLE STR0004 	ACTION "TMSAF12Inc"  		OPERATION 3 ACCESS 0  //"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "TMSAF12Alt"   		OPERATION 4 ACCESS 0  //"Alterar" 
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSAF12" 	OPERATION 5 ACCESS 0  //"Excluir" 

If ExistBlock("TMAF12MNU")
	ExecBlock("TMAF12MNU",.F.,.F.)
EndIf

Return ( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} TmF12DfStr
Define o modelo de dados para a rotina de Roteiro da Viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function TmF12DfStr(nType)

Local oStruDJF := Nil

Default nType := 1 //-- 1=Model;2=View
If nType == 1
	oStruDJF := FwFormStruct( nType, "DJF")
ElseIf nType == 2
	oStruDJF := FwFormStruct( nType, 'DJF',  {|cCampo| AllTrim(cCampo)+"|" $ "|DJF_LEGRAT|DJF_LEGDOC|DJF_LEGVAL|DJF_SEQUEN|DJF_TIPOPE|DJF_KM|DJF_CLIENT|DJF_LOJA|DJF_SEQEND|DJF_DATPRE|DJF_HORPRE|DJF_NOME|DJF_END|DJF_BAIRRO|DJF_MUN|DJF_EST|"})    
EndIf

If nType == 1

	// Se for executado apartir da rotina de aprovação
	
	// Adiciona o Campo de Legenda
	oStruDJF:AddField(STR0010		, ; // Titulo do campo    //"Rat"
						STR0011		, ; // ToolTip do campo  // "Rateio"
						'DJF_LEGRAT' 	, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						20	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}			, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||"BR_AMARELO"}, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
						
	// Adiciona o Campo de Legenda
	oStruDJF:AddField( STR0012		, ; // Titulo do campo //'Doc'
						 STR0013		, ; // ToolTip do campo //'Docto.Gerado'
						'DJF_LEGDOC' 	, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						20	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}			, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||"BR_AMARELO"}, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
						
	// Adiciona o Campo de Legenda
	oStruDJF:AddField( STR0014		, ; // Titulo do campo  //'Val'	
						 STR0015		, ; // ToolTip do campo  //'Val. Trecho'
						'DJF_LEGVAL' 	, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						20	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}			, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||"BR_AMARELO"}, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
	
	
	// Adiciona o Campo de DOCS				
	oStruDJF:AddField(	"Docs"			, ; //-- Titulo do campo  //-- "Repete Valores Para Todos Itens"
							"Docs"			, ; //-- ToolTip do campo //-- "Repete Valores Para Todos Itens"
							'DJF_DOCS'		, ; //-- Nome do Campo
							'M' 			, ; //-- Tipo do campo
							10				, ; //-- Tamanho do campo
							0				, ; //-- Decimal do campo
							NIL				, ; //-- Code-block de validação do campo
							NIL				, ; //-- Code-block de validação When do campo
							{} 				, ; //-- Lista de valores permitido do campo
							.F.				, ; //-- Indica se o campo tem preenchimento obrigatório
							NIL				, ; //-- Code-block de inicializacao do campo
							NIL 			, ; //-- Indica se trata de um campo chave
							NIL 			, ; //-- Indica se o campo pode receber valor em uma operação de update.
							.T. 			)   //-- Indica se o campo é virtual
							
	// Adiciona o Campo de Descrição do Roteiro
	
	If GetSX3Cache("DJG_DESCRI", "X3_CAMPO") <> Nil
		oStruDJF:AddField(	FwX3Titulo("DJG_DESCRI")		, ; //-- Titulo do campo  //-- "Repete Valores Para Todos Itens"
								FwX3Titulo("DJG_DESCRI")		, ; //-- ToolTip do campo //-- "Repete Valores Para Todos Itens"
								'DJF_DESCRI'	, ; //-- Nome do Campo
								GetSX3Cache("DJG_DESCRI", "X3_TIPO") 		, ; //-- Tipo do campo
								GetSX3Cache("DJG_DESCRI", "X3_TAMANHO")		, ; //-- Tamanho do campo
								GetSX3Cache("DJG_DESCRI", "X3_DECIMAL")		, ; //-- Decimal do campo
								NIL				, ; //-- Code-block de validação do campo
								NIL				, ; //-- Code-block de validação When do campo
								{} 				, ; //-- Lista de valores permitido do campo
								.F.				, ; //-- Indica se o campo tem preenchimento obrigatório
								NIL				, ; //-- Code-block de inicializacao do campo
								NIL 			, ; //-- Indica se trata de um campo chave
								NIL 			, ; //-- Indica se o campo pode receber valor em uma operação de update.
								.T. 			)   //-- Indica se o campo é virtual
	EndIf
	
	
	// Adiciona o Campo de Descrição do Roteiro

	If GetSX3Cache("DJF_DATPRE", "X3_CAMPO") <> Nil
		oStruDJF:AddField(	"Data DTW"		, ; //-- Titulo do campo  //-- "Repete Valores Para Todos Itens"
								"Data DTW"		, ; //-- ToolTip do campo //-- "Repete Valores Para Todos Itens"
								'DJF_DATDTW'	, ; //-- Nome do Campo
								GetSX3Cache("DJF_DATPRE", "X3_TIPO") 		, ; //-- Tipo do campo
								GetSX3Cache("DJF_DATPRE", "X3_TAMANHO")		, ; //-- Tamanho do campo
								GetSX3Cache("DJF_DATPRE", "X3_DECIMAL")		, ; //-- Decimal do campo
								NIL				, ; //-- Code-block de validação do campo
								NIL				, ; //-- Code-block de validação When do campo
								{} 				, ; //-- Lista de valores permitido do campo
								.F.				, ; //-- Indica se o campo tem preenchimento obrigatório
								NIL				, ; //-- Code-block de inicializacao do campo
								NIL 			, ; //-- Indica se trata de um campo chave
								NIL 			, ; //-- Indica se o campo pode receber valor em uma operação de update.
								.T. 			)   //-- Indica se o campo é virtual
	EndIf
	
	If GetSX3Cache("DJF_HORPRE", "X3_CAMPO") <> Nil
		oStruDJF:AddField(	"Hora DTW"		, ; //-- Titulo do campo  //-- "Repete Valores Para Todos Itens"
								"Hora DTW"		, ; //-- ToolTip do campo //-- "Repete Valores Para Todos Itens"
								'DJF_HORDTW'	, ; //-- Nome do Campo
								GetSX3Cache("DJF_HORPRE", "X3_TIPO") 		, ; //-- Tipo do campo
								GetSX3Cache("DJF_HORPRE", "X3_TAMANHO")		, ; //-- Tamanho do campo
								GetSX3Cache("DJF_HORPRE", "X3_DECIMAL")		, ; //-- Decimal do campo
								NIL				, ; //-- Code-block de validação do campo
								NIL				, ; //-- Code-block de validação When do campo
								{} 				, ; //-- Lista de valores permitido do campo
								.F.				, ; //-- Indica se o campo tem preenchimento obrigatório
								NIL				, ; //-- Code-block de inicializacao do campo
								NIL 			, ; //-- Indica se trata de um campo chave
								NIL 			, ; //-- Indica se o campo pode receber valor em uma operação de update.
								.T. 			)   //-- Indica se o campo é virtual
	EndIf
	
		// Adiciona o Campo de Exclusão na viagem				
	oStruDJF:AddField(	"Exc Viag"			, ; //-- Titulo do campo  //-- "Repete Valores Para Todos Itens"
							"Exc Viag"			, ; //-- ToolTip do campo //-- "Repete Valores Para Todos Itens"
							'DJF_EXCVIA'		, ; //-- Nome do Campo
							'L' 			, ; //-- Tipo do campo
							1				, ; //-- Tamanho do campo
							0				, ; //-- Decimal do campo
							NIL				, ; //-- Code-block de validação do campo
							NIL				, ; //-- Code-block de validação When do campo
							{} 				, ; //-- Lista de valores permitido do campo
							.F.				, ; //-- Indica se o campo tem preenchimento obrigatório
							{|| .F.}		, ; //-- Code-block de inicializacao do campo
							NIL 			, ; //-- Indica se trata de um campo chave
							NIL 			, ; //-- Indica se o campo pode receber valor em uma operação de update.
							.T. 			)   //-- Indica se o campo é virtual
							
												
	

Else

	oStruDJF:AddField(	'DJF_LEGRAT' 	, ; // Nome do Campo
					'01' 			, ; // Ordem   
					 STR0010		, ; // Titulo do campo  //"Rat"
					 STR0011 		, ; // Descrição do campo  // "Rateio"
					{''} 			, ; // Array com Help
					'C' 			, ; // Tipo do campo
					'@BMP' 			, ; // Picture
					NIL 			, ; // Bloco de Picture Var
					'' 				, ; // Consulta F3
					.T. 			, ; // Indica se o campo é evitável
					NIL 			, ; // Pasta do campo
					NIL 			, ; // Agrupamento do campo
					{ }				, ; // Lista de valores permitido do campo (Combo)
					NIL 			, ; // Tamanho Maximo da maior opção do combo
					"" 				, ; // Inicializador de Browse
					.T. 			, ; // Indica se o campo é virtual
					"" 			  ) // Picture Variável
					
	oStruDJF:AddField(	'DJF_LEGDOC' 	, ; // Nome do Campo
					'02' 			, ; // Ordem
					STR0012 		, ; // Titulo do campo  //'Doc'
					STR0013		, ; // Descrição do campo   //'Docto.Gerado'
					{''} 			, ; // Array com Help
					'C' 			, ; // Tipo do campo
					'@BMP' 			, ; // Picture
					NIL 			, ; // Bloco de Picture Var
					'' 				, ; // Consulta F3
					.T. 			, ; // Indica se o campo é evitável
					NIL 			, ; // Pasta do campo
					NIL 			, ; // Agrupamento do campo
					{ }				, ; // Lista de valores permitido do campo (Combo)
					NIL 			, ; // Tamanho Maximo da maior opção do combo
					"" 				, ; // Inicializador de Browse
					.T. 			, ; // Indica se o campo é virtual
					"" 			  ) // Picture Variável
					
	oStruDJF:AddField(	'DJF_LEGVAL' 	, ; // Nome do Campo
					'03' 			, ; // Ordem
					STR0014		, ; // Titulo do campo	//'Val'	
					STR0015		, ; // Descrição do campo //'Val. Trecho'
					{''} 			, ; // Array com Help
					'C' 			, ; // Tipo do campo
					'@BMP' 			, ; // Picture
					NIL 			, ; // Bloco de Picture Var
					'' 				, ; // Consulta F3
					.T. 			, ; // Indica se o campo é evitável
					NIL 			, ; // Pasta do campo
					NIL 			, ; // Agrupamento do campo
					{ }				, ; // Lista de valores permitido do campo (Combo)
					NIL 			, ; // Tamanho Maximo da maior opção do combo
					"" 				, ; // Inicializador de Browse
					.T. 			, ; // Indica se o campo é virtual
					"" 			  ) // Picture Variável													
EndIf

Return oStruDJF

//-------------------------------------------------------------------
/*/{Protheus.doc} F12StrDJK
Define o modelo de dados para a rotina de MDF-e

@author Paulo Henrique Corrêa Cardoso

@since 28/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function F12StrDJK(nType)

Local oStruDJK := Nil

Default nType := 1 //-- 1=Model;2=View
If nType == 1
	oStruDJK := FwFormStruct( 1 , "DJK") 
ElseIf nType == 2
	oStruDJK := FwFormStruct( 2 , "DJK",  {|cCampo| AllTrim(cCampo)+"|" $ "|DJK_SEQUEN|DJK_EST|"}) 
EndIf

If nType == 1
	
							
							
	
	// Adiciona o Campo de Legenda
	oStruDJK:AddField(  ""			, ; // Titulo do campo    
 						  ""			, ; // ToolTip do campo 
						'DJK_LEGORI' 	, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						20	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}		, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||"BR_AMARELO"}, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
	
	// Adiciona o Campo de Legenda
	oStruDJK:AddField( STR0050		, ; // Titulo do campo    // "Adiciona Linha"
						STR0050		, ; // ToolTip do campo // "Adiciona Linha"
						'DJK_BTTOP' 	, ; // Nome do Campo
						'BT' 			, ; // Tipo do campo
						1	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}		, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||"PMSSETAUP"}   , ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
	
	// Adiciona o Campo de Legenda
	oStruDJK:AddField( STR0050			, ; // Titulo do campo  // "Adiciona Linha"   
						STR0050			, ; // ToolTip do campo  // "Adiciona Linha"
						'DJK_BTLOW' 	, ; // Nome do Campo
						'BT' 			, ; // Tipo do campo
						1	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}		, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||"PMSSETADOWN"}, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual

Else
	oStruDJK:AddField(	'DJK_LEGORI' 	, ; // Nome do Campo
					'01' 				, ; // Ordem   
					 ""					, ; // Titulo do campo  
					 "" 				, ; // Descrição do campo 
					{''} 				, ; // Array com Help
					'C' 				, ; // Tipo do campo
					'@BMP' 				, ; // Picture
					NIL 				, ; // Bloco de Picture Var
					'' 					, ; // Consulta F3
					.T. 				, ; // Indica se o campo é evitável
					NIL 				, ; // Pasta do campo
					NIL 				, ; // Agrupamento do campo
					{ }					, ; // Lista de valores permitido do campo (Combo)
					NIL 				, ; // Tamanho Maximo da maior opção do combo
					"" 					, ; // Inicializador de Browse
					.T. 				, ; // Indica se o campo é virtual
					"" 					  ) // Picture Variável
	If !IsInCallStack("TMSAF12Vis")
		oStruDJK:AddField(	'DJK_BTTOP' 	, ; // Nome do Campo
						'08' 				, ; // Ordem   
						STR0050					, ; // Titulo do campo  // "Adiciona Linha"
						"" 				, ; // Descrição do campo 
						{''} 				, ; // Array com Help
						'BT' 				, ; // Tipo do campo
						'@BMP'				, ; // Picture
						NIL 				, ; // Bloco de Picture Var
						NIL					, ; // Consulta F3
						.T. 				, ; // Indica se o campo é evitável
						NIL 				, ; // Pasta do campo
						NIL 				, ; // Agrupamento do campo
						NIL					, ; // Lista de valores permitido do campo (Combo)
						NIL 				, ; // Tamanho Maximo da maior opção do combo
						"" 					, ; // Inicializador de Browse
						.T. 				, ; // Indica se o campo é virtual
						"" 					  ) // Picture Variável
						
			oStruDJK:AddField(	'DJK_BTLOW' 	, ; // Nome do Campo
						'09' 				, ; // Ordem   
						STR0050				, ; // Titulo do campo  // "Adiciona Linha"
						"" 				, ; // Descrição do campo 
						{''} 				, ; // Array com Help
						'BT' 				, ; // Tipo do campo
						'@BMP'				, ; // Picture
						NIL 				, ; // Bloco de Picture Var
						NIL					, ; // Consulta F3
						.T. 				, ; // Indica se o campo é evitável
						NIL 				, ; // Pasta do campo
						NIL 				, ; // Agrupamento do campo
						NIL					, ; // Lista de valores permitido do campo (Combo)
						NIL 				, ; // Tamanho Maximo da maior opção do combo
						"" 					, ; // Inicializador de Browse
						.T. 				, ; // Indica se o campo é virtual
						"" 					  ) // Picture Variável
	EndIf
EndIf

Return oStruDJK

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ActiveMdl
			Função Dummy Para o Sistema Entender Que a Tela Foi Alterada Permitindo Assim a Sua Gravação
@author  	Eduardo Alberti
@version 	Versao P12
@since		16/Mar/2016
@return 	Booleano
@obs .
/*/
//--------------------------------------------------------------------------------------------------------
Static Function ActiveMdl(oModel)

Local lRet       := .T.            // Recebe o Retorno
Local lRptAll    := .T.            // Recebe o valor do campo do Cab	

// Inicializa alterações nos objetos
oModel:LoadValue( 'MdFieldDJF', 'RPT_ALL', lRptAll  )	
oModel:LoadValue( 'MdGridDJF1', 'DJF_SEQUEN', oModel:GetValue( 'MdGridDJF1', 'DJF_SEQUEN' )	  )	
	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} AfterVwAct
Ações apos a ativação da View e do Model antes de abrir a tela

Uso: TMSAF12

@sample
//AfterVwAct(oView)

@author Paulo Henrique Corrêa Cardoso.
@since 28/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function AfterVwAct(oView)

Default oView   := FwViewActive()

// Carrega as Linhas do MDF-e
AF12LdMDFe(oView)

// Deleta as linhas referentes aos docs da viagem	
AF12DelDoc(oView)

Return

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl
Função que realiza a validação do Modelo antes da Gravação

Uso: TMSAF12

@sample
//APosVldMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 19/04/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet        := .T.             // Recebe o Retorno
Local aAreaAtu    := GetArea()       // Recebe a Area Atual
Local nCnt        := 0               // Recebe o Contador do Primeiro For
Local nCntAux     := 0               // Recebe o Contador Auxiliar
Local oModelGrd   := NIL             // Recebe o Modelo do Grid
Local oMdlGrdDJK  := NIL             //  Recebe o modelo do grid da DJK
Local oView       := FWViewActive()  // Recebe a View Ativa
Local oObjView    := Nil             // Recebe o objeto da View do Grid
Local aFolderAct  := {}              // Recebe os dados da Folder ativa
Local cCliDev     := ""              // Recebe o codigo do cliente devedor
Local cLojDev     := ""              // Recebe a loja do cliente devedor
Local cContrat    := ""              // Recebe o numero do contrato
Local cCdrOri     := ""              // Recebe o codigo da Região de origem
Local cMunOri     := ""              // Recebe o municipio de origem
Local cCdrDes     := ""              // Recebe o codigo da Região de destino
Local cMunDes     := ""              // Recebe o municipio de destino
Local nTotalKM    := 0               // Recebe o total de KM do Roteiro
Local aRotCli     := {}              // Recebe o Roteiro do cliente
Local aDescri     := {}              // Recebe os Municipios da descrição automatica
Local nPosMun     := 0               // Recebe a posição no array de Municipios da descrição automatica
Local cDescri     := ""              // Recebe a descrição automatica do roteiro
Local aRotaRotei  := ""              // Recebe as Rotas e roteiros da busca de exatamente igual
Local lRoteiro    := ""              // Recebe recebe true se existe roteiro exatamente igual
Local cNewRoteir  := ""              // Recebe o codido do Roteiro
Local aVetRoteir  := {}              // Recebe o Vetor de Roteiros
Local aVetTrecho  := {}              // Recebe o vetor de trochos do roteiro
Local lVldRot     := .F.             // Valida o Roteiro ja existente
Local nSavSx8Len  := GetSx8Len()     // Salva o tamanho do SX8
Local aVetBsc2    := {}              // Recebe retorno de busca de rotas com mesma origem e destino
Local aRotInc     := {}              // Recebe os Roteiros que serão incluidos
Local cRotaDef    := ""              // Recebe a rota encontrada 
Local cEstAnt     := ""              // Recebe o Estado anterior do grid DJK
Local lRotaIgual  := .F.	     	 // Recebe se a Rota não mudou na alteração
Local aRetUsu     := {}
Local lDigRot     := TmsA144Sta("lDigRot")

Default oModel    := Nil             // Recebe o modelo principal

lF12Disarm	:= .F. 
FwClearHLP()

// Varre todos os Folders
For nCnt:= 1 To nQtdFolder
	
	// Limpa as variaveis reutilizadas 
	aVetTrecho  := {}
	aRotCli     := {}
	aDescri     := {}
	cDescri     := ""
	nTotalKM    := 0
	lRotaIgual  := .F.	
	
	// Pega o Modelo de cada folder
	oModelGrd := oModel:GetModel("MdGridDJF"+AllTrim(Str(nCnt)))
	
	// Se o Grid estiver preenchido
	If oModelGrd:Length(.T.) > 0
		
		// Seleciona os objetos do folder
		oObjView := oView:GetViewObj("VwGridDJF"+AllTrim(Str(nCnt)))
		oView:SelectFolder("Folder",nCnt,2)
		aFolderAct := oView:GetFolderActive("Folder",2)
		
		// Posiciona na primeira linha valida do modelo 
		oModelGrd:GoLine(1) 
		If oModelGrd:IsDeleted()
			oModelGrd:GoLine( LinValida(oModelGrd,1,.T.) )
		EndIf
		
		// Recebe os dados comuns para as linhas
		cCliDev := oModelGrd:GetValue("DJF_CLIDEV")
		cLojDev := oModelGrd:GetValue("DJF_LOJDEV")
		cContrat:= oModelGrd:GetValue("DJF_NCONTR")
		cRotaDef:= oModelGrd:GetValue("DJF_ROTA")
		
		// Recebe a Regiao de Origem e municipio ref. ao primeiro trecho do roteiro 
		cCdrOri := Tf12OriDes(oModelGrd:GetValue('DJF_SEQEND'),oModelGrd:GetValue('DJF_CLIENT'),oModelGrd:GetValue('DJF_LOJA'))
		cMunOri := oModelGrd:GetValue('DJF_MUN')
		
		// Varre os pontos do roteiro
		For nCntAux := 1 To oModelGrd:GetQTDLine()
		
			oModelGrd:GoLine(nCntAux)		
			If !oModelGrd:IsDeleted()
			
				// Monta o Array com o Roteiro do Cliente
				AAdd(aRotCli,{oModelGrd:GetValue("DJF_SEQUEN"),oModelGrd:GetValue("DJF_CLIENT"),oModelGrd:GetValue("DJF_LOJA"),oModelGrd:GetValue("DJF_MUN"),oModelGrd:GetValue("DJF_EST"),oModelGrd:GetValue("DJF_SEQEND")})
				
				// Recebe a Km Total do Roteiro
				nTotalKM += oModelGrd:GetValue('DJF_KM')
				
				// Monta o Array de municipios
				nPosMun := aScan(aDescri,{|x| AllTrim(x[1]) == AllTrim(oModelGrd:GetVAlue("DJF_MUN")) })
				If nPosMun > 0
					aDescri[nPosMun][2] += 1		
				Else
					AADD(aDescri,{AllTrim(oModelGrd:GetVAlue("DJF_MUN")),1})
				EndIf
			EndIf
			
		Next nCntAux
		
		// Monta a Descrição de municipios 
		For nCntAux := 1 To Len(aDescri)
			cDescri += aDescri[nCntAux][1]+ Iif(aDescri[nCntAux][2]> 1,"("+ cValToChar(aDescri[nCntAux][2]) +")", "")
			
			If nCntAux < Len(aDescri)
				cDescri += "-"
			EndIf
		Next nCntAux
		cDescri := SubStr( cDescri, 1, 254 )
		
		// Preenche o campo de descrição
		For nCntAux := 1 To oModelGrd:GetQTDLine()
			oModelGrd:GoLine(nCntAux)		
			
			If !oModelGrd:IsDeleted()
				oModelGrd:LoadValue("DJF_DESCRI",cDescri)
			EndIf
		Next nCntAux
		
		// Cria o Array de MDF-e

		If nCnt == 1
			aMDFe := {}
			cEstAnt := ""
			// Pega o Modelo do Grid da DJK
			oMdlGrdDJK := oModel:GetModel("MdGridDJK")
			
			// Verifica se o grid possui mais de uma linha valida
			If oMdlGrdDJK:Length(.T.) > 1
								
				// Varre as linhas do Grid DJK
				For nCntAux := 1 To oMdlGrdDJK:Length()
					
					oMdlGrdDJK:GoLine(nCntAux)
				
					// Adiciona os estados, removendo duplicidades em sequencia
					If !oMdlGrdDJK:IsDeleted() .AND. oMdlGrdDJK:GetValue("DJK_EST") != cEstAnt
						
						AADD(aMDFe,oMdlGrdDJK:GetValue("DJK_EST"))
						
						cEstAnt := oMdlGrdDJK:GetValue("DJK_EST")
					EndIf
					
				Next nCntAux
				
			EndIf
			
		EndIf
		
		// Posiciona na ultima linha valida
		oModelGrd:GoLine(oModelGrd:GetQTDLine())	
		If oModelGrd:IsDeleted()
			oModelGrd:GoLine( LinValida(oModelGrd,oModelGrd:GetQTDLine(),.F.) )
		EndIf
		
		// Recebe a Regiao de destino e municipio ref. ao ultimo trecho do roteiro 
		cCdrDes := Tf12OriDes(oModelGrd:GetValue('DJF_SEQEND'),oModelGrd:GetValue('DJF_CLIENT'),oModelGrd:GetValue('DJF_LOJA'))
		cMunDes := oModelGrd:GetValue('DJF_MUN')
		
		// Busca Roteiro Exatamente Igual 
		aRotaRotei := {}
		lRoteiro   := F13RotIdnt(aRotCli,cSerTms,@aRotaRotei,Iif(nCnt == 1,aClone(aMDFe),{})) 
		
		// Pega o código do Roteiro
		If lRoteiro
			cNewRoteir := aRotaRotei[1][1]
			
			// Se existir um roteiro exatamente igual
			If Len(aRotaRotei[2]) == 1
				cRotaDef := aRotaRotei[2][1][1]
				
			ElseIf Len(aRotaRotei[2]) > 1
				If aScan(aRotaRotei[2],{|x| AllTrim(x[1]) == AllTrim(cRotaDef) .AND. AllTrim(x[2]) == AllTrim(cNewRoteir) }) > 0
					lRotaIgual := .T.
				EndIf
			EndIf
			
		Else
			cNewRoteir := GetSX8Num("DJG","DJG_ROTEIR")
		EndIf
		
		// Verifica se o Roteiro já existe na tela
		lVldRot := TF12VldRot(oModelGrd,aVetRoteir,@aVetTrecho,@cNewRoteir)
		
		// Realiza o RollBack caso exista um roteiro igual na tela e o codigo atual tenha sido obtido apartir do GetSx8Num
		If !lVldRot  .AND. !lRoteiro 
			RollBackSX8()
		EndIf
		
		// Se for para sempre mostrar sug. Rota ou Tiver mais de uma rota exatamente igual ou não possuir rotas exatamente iguais
		If lExbSugRot .OR.  Len(aRotaRotei[2]) != 1 .Or. lDigRot
		
			// Verifica se na base existe um roteiro com a mesma origem e destino
			If  ( Empty(aVetBsc2 :=( F13RotSem(aRotCli,cSerTms,aClone(aRotaRotei[2]),lRoteiro,Iif(nCnt == 1,aClone(aMDFe),{})) ) ) )
				
				// Inclui o Roteiro
				AADD(aRotInc,{'3',"", cNewRoteir , Iif(Empty(cCliDev),Iif(nCnt == 1,cCliDev,"SEMDEV"),cCliDev), cLojDev, cContrat ,nTotalKm, cMunOri, cMunDes, cCdrOri, cCdrDes,cSerTms,oModelGrd,{}})	
				
				// Se o Roteiro ainda não existir no grid
				If lVldRot		
					AADD(aVetRoteir,aVetTrecho)
				EndIf
				
			Else
				// Inclui o Roteiro
				AADD(aRotInc,{Iif( Len(aRotaRotei[2]) == 1 .OR. lRotaIgual,'1',IIf(lRoteiro ,'4' ,'2')),Iif(Len(aRotaRotei[2]) >= 1,cRotaDef,""), cNewRoteir , Iif(Empty(cCliDev),Iif(nCnt == 1,cCliDev,"SEMDEV"),cCliDev), cLojDev, cContrat, nTotalKm, cMunOri, cMunDes, cCdrOri, cCdrDes,cSerTms,oModelGrd,aVetBsc2})	
				
				// Se o Roteiro ainda não existir no grid	
				If  lVldRot			
					AADD(aVetRoteir,aVetTrecho)
				EndIf	
			EndIf
		Else
	
			// Adiciona os dados do roteiro
			lRet :=  AddRoteiro(oModelGrd,cFilVge,cViagem,aRotaRotei[2][1][1],aRotaRotei[1][1],cCliDev,cLojDev,cContrat)
			
		EndIf
		
	EndIf
	
Next nCnt

//Chama tela para demonstrar os roteiros que precisam ser atrelados a uma nova rota
If !Empty(aRotInc) .AND. lRet
	
	// Reordena o Array Codigo da Rota e Codigo do Roteiro
//	ASort( aRotInc,,,{|x,y| x[2]+x[3] < y[2]+y[3] } )
	
	// Chama tela de Vinculo de Rota aos Roteiros
	TMSAF13Mnt(@aRotInc,aNewRot,oModel)
	
	// Caso não tenha nenhum roteiro pendente de rota 
	If aScan(aRotInc,{|x|x[1]<> '1'}) == 0	
	
		// Varre os Arrays de Roteiro para atualizar a Rota
		For nCnt := 1 To Len (aRotInc)		
			oModelGrd := aRotInc[nCnt,13]
			
			// Adiciona os dados do roteiro
			lRet := AddRoteiro(oModelGrd,cFilVge,cViagem,aRotInc[nCnt,2],aRotInc[nCnt,3],aRotInc[nCnt,4],aRotInc[nCnt,5],aRotInc[nCnt,6])
						
		Next nCnt
	Else
		lRet := .F.	
	EndIf
	
EndIf

RestArea(aAreaAtu)

// Se houve erro 
If !lRet
	oModel:GetModel():SetErrorMessage(oModel:GetId(),"DJF_ROTEIR",,,,STR0031)//"Existem roteiros que não foram vinculados a uma Rota."	
EndIf

// Grava ou estorna os SX8
While (GetSx8Len() > nSavSx8Len)
	If lRet
		ConfirmSX8()
	Else
		RollBackSX8()
	Endif
EndDo	

//-- Permite a validação e manipulação dos dados do roteiro
If lTMF12Rot
	aRetUsu := ExecBlock("TMF12Rot",.F.,.F.,{2,,,oModel})	//-- Acao (1-Na carga do grid / 2-Na validação da model)
															//-- Vetor com os dados do roteiro (Somente na carga do grid)
															//-- Folder
															//-- Model (Somente na validação da model)
	If ValType(aRetUsu) != "A" .Or. Len(aRetUsu) != 2 .Or. ValType(aRetUsu[1]) != "L"
		lRet := .F.
	Else
		lRet   := aRetUsu[1]
		oModel := aRetUsu[2]
	Endif
EndIf

Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} AddRoteiro()
Adiciona os dados do roteiro

Uso: TMSAF12

@sample
// AddRoteiro(oModelGrd,cFilVge,cViagem,cRota,cRoteiro,cCliDev,cLojDev,cContrat)

@author Paulo Henrique Corrêa Cardoso.
@since 14/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function AddRoteiro(oModelGrd,cFilOri,cViag,cRota,cRoteiro,cCliDev,cLojDev,cContrat)
Local lRet        := .T.           // Recebe o retorno
Local nCntAux     := 0             // Recebe o contador do for

Default oModelGrd := NIL           // Recebe o modelo do grid
Default cFilOri   := ""            // Recebe a filial da viagem
Default cViag   := ""            // Recebe a viagem
Default cRota     := ""            // Recebe a Rota
Default cRoteiro  := ""            // Recebe o Roteiro
Default cCliDev   := ""            // Recebe o cliente devedor
Default cLojDev   := ""            // Recebe a loja do cliente devedor
Default cContrat  := ""            // Recebe o numero do contrato

If !Empty(oModelGrd) .AND. !Empty(cFilOri) .AND. !Empty(cViag) .AND. !Empty(cRota) .AND. !Empty(cRoteiro)


	// Adiciona o Roteiro no array
	For nCntAux := 1 To oModelGrd:GetQTDLine()
		oModelGrd:GoLine(nCntAux)	
		
		If 	!oModelGrd:IsDeleted()
			
			oModelGrd:LoadValue("DJF_FILIAL"	,FwxFilial('DJF'))
			oModelGrd:LoadValue("DJF_FILORI"	,cFilOri)
			oModelGrd:LoadValue("DJF_VIAGEM"	,cViag)      
			oModelGrd:LoadValue("DJF_ROTA"		,cRota  )
			oModelGrd:LoadValue("DJF_ROTEIR"	,cRoteiro)
			oModelGrd:LoadValue("DJF_CLIDEV"	,oModelGrd:GetValue("DJF_CLIDEV") )
			oModelGrd:LoadValue("DJF_LOJDEV"	,oModelGrd:GetValue("DJF_LOJDEV") )
			oModelGrd:LoadValue("DJF_KM"		,oModelGrd:GetValue("DJF_KM")     )
			oModelGrd:LoadValue("DJF_NCONTR"	,oModelGrd:GetValue("DJF_NCONTR") )
			oModelGrd:LoadValue("DJF_SEQUEN"	,oModelGrd:GetValue("DJF_SEQUEN") )
			oModelGrd:LoadValue("DJF_CLIENT"	,oModelGrd:GetValue("DJF_CLIENT") )
			oModelGrd:LoadValue("DJF_LOJA"		,oModelGrd:GetValue("DJF_LOJA")   )
			oModelGrd:LoadValue("DJF_RATEIO"	,oModelGrd:GetValue("DJF_RATEIO") )
			oModelGrd:LoadValue("DJF_DOCGER"	,oModelGrd:GetValue("DJF_DOCGER") )
			oModelGrd:LoadValue("DJF_VALTRE"	,oModelGrd:GetValue("DJF_VALTRE") )
			oModelGrd:LoadValue("DJF_TIPOPE"	,oModelGrd:GetValue("DJF_TIPOPE") )
			oModelGrd:LoadValue("DJF_DATPRE"	,oModelGrd:GetValue("DJF_DATPRE") )
			oModelGrd:LoadValue("DJF_HORPRE"	,oModelGrd:GetValue("DJF_HORPRE") )
			oModelGrd:LoadValue("DJF_SEQEND"	,oModelGrd:GetValue("DJF_SEQEND") )
			oModelGrd:LoadValue("DJF_TIPOKM"	,oModelGrd:GetValue("DJF_TIPOKM") )
			oModelGrd:LoadValue("DJF_IDLIN"		,oModelGrd:GetValue("DJF_IDLIN" ) )
			
			AADD(aRoteiro,{cRota,cRoteiro,cCliDev, cLojDev,cContrat,oModelGrd:GetValue("DJF_SEQUEN"),oModelGrd:GetValue("DJF_KM"),oModelGrd:GetValue("DJF_CLIENT"),oModelGrd:GetValue("DJF_LOJA")})
		EndIf
		
	Next nCntAux
Else
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} CommitMdl
Gravacao dos dados do roteiro da viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CommitMdl( oModel )

Local lRet        	:= .T.              // Recebe o Retorno
Local cErro			:= STR0053 + chr(13) + chr(10) + STR0054 //-- "Ocorreu um erro durante a gravação do Roteiro da Viagem."/ "Verifique os dados informados, e tente novamente."  
Local bError   	  	:= ErrorBlock( {|e| lRet := .F. , cErro :=  e:Description + e:ErrorStack } )

Default oModel    	:= FwModelActive()  // Recebe o Modelo 

BEGIN SEQUENCE

// Salva Distancias entre Clientes - DDO
lRet := A12SavDDO(oModel,.T.)

// Salva dados do Roteiro - DJG, DDJ, DJH e DJK 
If lRet
	lRet := A12SvRotei(oModel,.T.)

	If lRet
		If IsInCallStack("TMSAF12Alt")
			TF10GrRote(5, cFilVge,cViagem,,.F.)
		EndIf

		lRet:= FWFormCommit( oModel )
	EndIf

EndIf

END SEQUENCE

ErrorBlock(bError)

If !lRet
	oModel:GetModel():SetErrorMessage(oModel:GetId(),"DJF_ROTEIR",,,,cErro)
	lF12Disarm	:= .T. 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAF12Inc
Gravacao dos dados do roteiro da viagem

@author Leandro Paulino
@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSAF12Inc(aPag,cTipSrv,cFilOri,cViag)

Local nRet	:= 0

Default aPag     := {}
Default cTipSrv  := ''
Default cFilOri  := Iif(DTQ->(!EOF()),DTQ->DTQ_FILORI,"")
Default cViag  := Iif(DTQ->(!EOF()),DTQ->DTQ_VIAGEM,"")

aRetpag 	:= aPag
cSerTms	:= cTipSrv
cFilVge	:= cFilOri
cViagem	:= cViag

// Verifica a quantidade de Abas
nQtdFolder := Len(aRetPag)+1

If !Empty(cFilOri) .AND.  !Empty(cViagem)
	
	BEGIN TRANSACTION 
	
	nRet := FWExecView( STR0016 ,'TMSAF12',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },,,{ || .T. })  //-- "Geração Agendamento"  ###"Roteiro"
	
	If lF12Disarm
		DisarmTransaction()
	EndIf

	END TRANSACTION
Else
	Alert("Viagem não Posicionada")
EndIf
// Limpa as Variaveis Staticas 
Af12ClrSts()

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAF12Alt
Gravacao dos dados do roteiro da viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSAF12Alt(aPag,aPagOri,aDelItens,cTipSrv,cFilOri,cViag)
Local nRet	:= 0

Default aPag     := {}
Default aPagOri  := {}
Default aDelDocs := {}
Default cTipSrv  := ''
Default cFilVge  := Iif(DTQ->(!EOF()),DTQ->DTQ_FILORI,"")
Default cViagem  := Iif(DTQ->(!EOF()),DTQ->DTQ_VIAGEM,"")

aRetpag    := aPag
aRetpagOri := aPagOri
aDelDocs   := aDelItens
cSerTms    := cTipSrv
cFilVge    := cFilOri
cViagem    := cViag

// Verifica a quantidade de Abas
If Len(aRetpagOri) > 0
	ASort(aRetpagOri,,,{|x,y| x[1] + x[2] < y[1] + y[2]  } )
	nQtdFolder := Len(aRetpagOri)
Else
	nQtdFolder := Len(aRetPag)+1 
EndIf

If !Empty(cFilOri) .AND.  !Empty(cViagem)
	
	BEGIN TRANSACTION
	
	nRet :=  FWExecView( STR0016 ,'TMSAF12',MODEL_OPERATION_UPDATE,, { || .T. },{ || .T. },,,{ || .T. })  //-- "Geração Agendamento" ###"Roteiro"
	
	If lF12Disarm
		DisarmTransaction()
	EndIf

	END TRANSACTION
Else
	Alert("Viagem não Posicionada")
EndIf

// Limpa as Variaveis Staticas 
Af12ClrSts()

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAF12Vis
Visualização dos dados do roteiro da viagem

@author Leandro Paulino

@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TMSAF12Vis(aPag,aPagOri,aDelItens,cTipSrv,cFilOri,cViag)
Local nRet	:= 0

Default aPag     := {}
Default aPagOri  := {}
Default aDelDocs := {}
Default cTipSrv  := ''
Default cFilVge  := Iif(DTQ->(!EOF()),DTQ->DTQ_FILORI,"")
Default cViagem  := Iif(DTQ->(!EOF()),DTQ->DTQ_VIAGEM,"")

aRetpag    := aPag
aRetpagOri := aPagOri
aDelDocs   := aDelItens
cSerTms    := cTipSrv
cFilVge    := cFilOri
cViagem    := cViag

// Verifica a quantidade de Abas
If Len(aRetpagOri) > 0
	ASort(aRetpagOri,,,{|x,y| x[1] + x[2] < y[1] + y[2]  } )
	nQtdFolder := Len(aRetpagOri)
Else
	nQtdFolder := Len(aRetPag)+1 
EndIf

If !Empty(cFilOri) .AND.  !Empty(cViagem)
	nRet :=  FWExecView( STR0016 ,'TMSAF12',MODEL_OPERATION_VIEW,, { || .T. },{ || .T. },,,{ || .T. })  //-- "Geração Agendamento" ###"Roteiro"
Else
	Alert("Viagem não Posicionada")
EndIf

// Limpa as Variaveis Staticas 
Af12ClrSts()

Return nRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TF12RetRot
Retorna cRota

@author Leandro Paulino
@Param  Quais roteiros serão retornados (1=Todos;2=Geral;3=Roteiros de Todos Pagadores) 
@since 08/04/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TF12RetRot(nAcao)

Local nCount 	:= 1
Local aRet		:= {}

Default nAcao := 1 //--Retorna todos os roteiros

If nAcao == 2
	ASort( aRoteiro,,,{|x,y| x[3] + x[6] < y[3] + y[6]  } )
	While nCount <= Len(aRoteiro) .And. Empty(aRoteiro[nCount,3])  
		aAdd(aRet,aRoteiro[nCount])		
		nCount++			
	EndDo
Else
	aRet := aClone(aRoteiro)
EndIf

Return aRet


/*/-----------------------------------------------------------
{Protheus.doc} Af012Reord
Realiza a Reordenação do Grid de Roteiros acertando a KM entre os pontos

Uso: TMSAF12

@sample
//Af012Reord(oView,cIdForm,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso.
@since 26/06/2016
@version 1.0
-----------------------------------------------------------/*/
Function Af012Reord(oView,cIdForm,cIdCampo,cValue)
Local aArea      := GetArea()      // Recebe a Area Atual
Local nLinOri    := 0              // Recebe a linha de origem
Local nLinDest   := 0              // Recebe a linha de destino
Local nLinAnt    := 0              // Recebe a linha anterior
Local nLinProx   := 0              // Recebe a proxima linha
Local aRetOrd    := {}             // Recebe o retorno da função de ordenação
Local oModel     := NIL            // Recebe o modelo
Local nLine      := 0              // Recebe a Linha atual
Local cValor     := ""             // Recebe o Valor Ajustado 
Local cIdOri     := ""             // Recebe o Id de Origem do Campo
Local cIdDes     := ""             // Recebe o Id de destino do Campo
Local oMdlGrdDJK := NIL            // Recebe o Modelo do Grid DJK
Local cSeqDesDJK := ""             // Recebe a Sequencia de Destino do Grid DJK
Local nValueAnt  := 0              // Recebe o Valor numerico da linha anterior
Local aParVldDTW := {}				// Recebe os parametros do DTW 
 
Default oView    := FwViewActive() // Recebe a View ativa
Default cIdForm  := ""             // Recebe o Id do formulario
Default cIdCampo := ""             // Recebe o Id do Campo
Default cValue   := ""             // Recebe o valor do campo

// Monta o objeto do ModelGrid
oModel := oView:GetModel()
oViewObj := oView:GetViewObj(cIdForm)     
oModelGrid := oModel:GetModel( oViewObj[6] )
nLine := oModelGrid:GetLine()


// Pega a aba ativa
aFldActive:= oView:GetFolderActive("Folder",2)

// Prepara os dados para a atualização do Grid de MDF-e	
If aFldActive[1] == 1
	cIdOri := oModelGrid:GetValue("DJF_IDLIN",nLine)
	
	// Acerta o Valor de destino
	cValor := TMSOrdValD(oModelGrid,cIdCampo,cValue)
	
	// Acerta o Valor da sequncia antes da busca
	nLinAnt := LinValida(oModelGrid,nLine,.F.) 
	If nLinAnt == 0
		nValueAnt := 1
	Else
		nValueAnt := Val(oModelGrid:GetValue(cIdCampo,nLinAnt)) + 1
	EndIf
	oModelGrid:LoadValue(cIdCampo,STRZERO( nValueAnt, TamSx3(cIdCampo)[1]) )
	
	// Busca a sequencia de destino
	If oModelGrid:SeekLine({{ "DJF_SEQUEN", cValor }})
		cIdDes := oModelGrid:GetValue("DJF_IDLIN")
	EndIf
	oModelGrid:GoLine(nLine)
	
	// Restaura o valor digitado
	oModelGrid:LoadValue(cIdCampo,cValue )
	
	nLinAnt := 0
EndIf


// Chama a Função de Reordenação
AADD(aParVldDTW,oModelGrid)
AADD(aParVldDTW,nLine)
AADD(aParVldDTW,cValor) 
aRetOrd  := TMSOrdGrd(oView,oModelGrid,cIdForm,cIdCampo,cValue,"F12VldDTW",aClone(aParVldDTW))

nLinOri  := aRetOrd[1] 
nLinDest := aRetOrd[2]

If  nLinDest > 0 .AND. nLinOri > 0 .AND.  nLinOri != nLinDest
	
	// Atualiza o grid do MDF-e
	If aFldActive[1] == 1
		oMdlGrdDJK := oModel:GetModel("MdGridDJK")
		
		// Busca o Id da linha de destino
		If oMdlGrdDJK:SeekLine({{ "DJK_IDDJF", cIdDes }})
			
			// Pega a sequencia da linha de destino
			cSeqDesDJK := oMdlGrdDJK:GetValue("DJK_SEQUEN")
			
			//Busca a sequencia da linha de origem
			If oMdlGrdDJK:SeekLine({{ "DJK_IDDJF", cIdOri }})
				
				// Reordena o grid DJK
				TMSOrdGrd(oView,oMdlGrdDJK,"VwGridDJK","DJK_SEQUEN",cSeqDesDJK)
				oMdlGrdDJK:Goline(1)	
			EndIf
				
		EndIf
			
		
	EndIf
	
	// O Atualiza o KM da Linha de origem da Reordenação
	oModelGrid:GoLine(nLinOri)
	
	If oModelGrid:IsDeleted()
		nLinOri := LinValida(oModelGrid,nLinOri,.F.)
	EndIf
	
	If nLinOri > 0                     
		nLinProx  := LinValida(oModelGrid,nLinOri,.T.)
		
		// Busca o KM
		nKm := F012RetKM(oModelGrid,nLinOri,nLinProx)
		
		// Atualiza o Km
		oModelGrid:GoLine(nLinProx)
		oModelGrid:LoadValue("DJF_KM",nKm)
	EndIf
	
	
	// O Atualiza o KM da Linha de anterior da linha de destino para a linha de destino da Reordenação
	nLinAnt  := LinValida(oModelGrid,nLinOri,.F.)
	
	If nLinAnt > 0
		// Busca o KM
		nKm := F012RetKM(oModelGrid,nLinAnt,nLinOri)
		
		// Atualiza o Km
		oModelGrid:GoLine(nLinOri)
		oModelGrid:LoadValue("DJF_KM",nKm)
	EndIf
	
	// O Atualiza o KM da Linha de destino para a proxima linha
	nLinProx := LinValida(oModelGrid,nLinOri,.T.)
	If nLinProx > 0
		// Busca o KM
		nKm := F012RetKM(oModelGrid,nLinOri,nLinProx)
		
		// Atualiza o Km
		oModelGrid:GoLine(nLinProx)
		oModelGrid:LoadValue("DJF_KM",nKm)
	EndIf
	
	oModelGrid:GoLine(nLinDest) //posiciona na linha 
EndIf

 //Atualiza a tela     
oView:Refresh(cIdForm) //Atualiza a tela   
oView:GoLine(oModelGrid:getId(),nLine)


RestArea(aArea)
Return

/*/-----------------------------------------------------------
{Protheus.doc} F012RetKM
Retorna a Km do Trecho

Uso: TMSAF12

@sample
//F012RetKM(oModelGrid,nLinOri,nLinDest)

@author Paulo Henrique Corrêa Cardoso.
@since 26/06/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function F012RetKM(oModelGrid,nLinOri,nLinDest)
Local nRetKm       := 0                               // Recebe o KM de retorno
Local cDeCodCli    := ""                              // Recebe o codigo do cliente De
Local cDeLojCli    := ""                              // Recebe o codigo da loja De
Local cDeSeqEnd    := ""                              // Recebe a sequencia de endereço De
Local cAteCodCli   := ""                              // Recebe o codigo do cliente Ate
Local cAteLojCli   := ""                              // Recebe a loja do cliente Ate
Local cAteSeqEnd   := ""                              // Recebe a sequencia de endereço Ate
Local cCliGen      := SuperGetMV("MV_CLIGEN",.F., "") // Recebe o cliente generico
Local cLojGen      := ""                              // Recebe a loja do cliente generico
Local aCliDev      := {}                              // Recebe o array contendo os dados do cliente devedor
Local cCliDev      := ""                              // Recebe o codigo do cliente devedor
Local cLojDev      := ""                              // Recebe a loja do cliente devedor
 
Default oModelGrid := NIL                             // Recebe o Modelo do Grid
Default nLinOri    := 0                               // Recebe a linha de origem
Default nLinDest   := 0                               // Recebe a linha de destino

If nLinOri > 0 .AND. nLinDest > 0
	// Busca o Cliente Generico            
	SA1->(DbSetOrder(1))
	If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
		cCliGen := SA1->A1_COD
		cLojGen := SA1->A1_LOJA
	EndIf
	
	// Pega os dados do cliente De
	cDeCodCli := oModelGrid:GetValue("DJF_CLIENT",nLinOri)
	cDeLojCli := oModelGrid:GetValue("DJF_LOJA"  ,nLinOri)
	cDeSeqEnd := oModelGrid:GetValue("DJF_SEQEND",nLinOri)

	// Pega os dados do cliente Ate
	cAteCodCli := oModelGrid:GetValue("DJF_CLIENT",nLinDest)
	cAteLojCli := oModelGrid:GetValue("DJF_LOJA"  ,nLinDest)                    
	cAteSeqEnd := oModelGrid:GetValue("DJF_SEQEND",nLinDest)                    
					 
	// Verifica o Cliente Devedor 
	If !Empty(oModelGrid:GetValue("DJF_CLIDEV",nLinOri))  
		aCliDev := Taf12TipKM(oModelGrid:GetValue("DJF_TIPOKM",nLinOri),oModelGrid:GetValue("DJF_CLIDEV",nLinOri),oModelGrid:GetValue("DJF_LOJDEV",nLinOri)   )
		cCliDev := aCliDev[2]
		cLojDev := aCliDev[3]
	Else
		cCliDev := cCliGen
		cLojDev := cLojGen
	EndIf

	// Busca o KM na tabela DDO	
	dbSelectArea("DDO")
	DDO->(DbSetOrder(1))

	If DDO->(DbSeek(xFilial("DDO") + cCliDev + cLojDev + cDeCodCli + cDeLojCli + cDeSeqEnd + cAteCodCli + cAteLojCli + cAteSeqEnd ))
		nRetKM := DDO->DDO_KM
	EndIf
EndIf

Return nRetKM
 
//-------------------------------------------------------------------
/*/{Protheus.doc} Af12GatCli
Gatilha os Campos apartir do Cliente

@author Paulo Henrique  

@since 07/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function Af12GatCli(oView,cIdForm,cIdCampo,cValue)
Local oModel		 := NIL				// Recebe o Modelo 
Local oModelGrid	 := NIL				// Recebe o Modelo do Grid
Local aArea		 := GetArea()			// Recebe a area Ativa
Local oViewObj   	 := NIL				// Recebe o Objeto contendo dados da View
Local cClient		 := ""					// Recebe o Cliente
Local cLoja		 := ""					// Recebe a loja do Cliente
Local nLineAtu	 := 0					// Recebe a Linha atual
Local nAntLine	 := 0					// Recebe a linha anterior
Local nProxLine	 := 0					// Recebe a proxima linha
Local cSeqEnd		 := ""					// Recebe a Sequencia de Endereço
Local aCliDDO		 := {} 				// Recebe os clientes que serão utilizadas para consulta ou gravação da KM na Tabela DDO (Cliente poderá ser Genérico ou o DEVEDOR).
Local cCliDDO	  	 := ""
Local cLojDDO		 := ""
Local cCliGen		 := SuperGetMV("MV_CLIGEN",.F., "") 
Local cLojGen		 := ""
Local cSeqAtu		 := ""
Local cSeqAnt		 := ""					
Local aFldActive	 := {}

Default oView		 := FwViewActive() 	// Recebe o Objeto do View
Default cIdForm	 := "" 				// Recebe o Id do Formulario
Default cIdCampo	 := "" 				// Recebe o Id do Campo
Default cValue	 := "" 				// Recebe o Valor do campo

// Busca o Cliente Generico	
SA1->(DbSetOrder(1))
If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
	cCliGen := SA1->A1_COD
	cLojGen := SA1->A1_LOJA
EndIf

// Recebe o Modelo do Grid
oModel := oView:GetModel()

// Recebe as Informações da view apartir do nome do formulario
oViewObj := oView:GetViewObj(cIdForm)

// Recebe o modelo do grid     
oModelGrid := oModel:GetModel( oViewObj[6] ) //Grid do folder

// recebe a linha atual
nLineAtu := oModelGrid:GetLine()


// Ajusta a Sequencia da linha 	
nAntLine := LinValida(oModelGrid,nLineAtu,.F.)
cSeqAtu :=  oModelGrid:GetValue("DJF_SEQUEN",nLineAtu)

If nAntLine > 0	
	cSeqAnt :=  oModelGrid:GetValue("DJF_SEQUEN",nAntLine)	
EndIf

If Val(cSeqAnt) + 1 != Val(cSeqAtu)  
	oModelGrid:LoadValue("DJF_SEQUEN", STRZERO( Val(cSeqAnt) + 1 , TamSx3('DJF_SEQUEN')[1]) )	
EndIf


//Preenche as variaveis de Cliente e loja
If cIdCampo == "DJF_CLIENT"
	
	cClient := cValue
	cLoja	 := oModelGrid:GetValue("DJF_LOJA")
	cSeqEnd := oModelGrid:GetValue("DJF_SEQEND")
	
ElseIf cIdCampo == "DJF_LOJA"
	
	cClient := oModelGrid:GetValue("DJF_CLIENT")
	cLoja	 := cValue
	cSeqEnd := oModelGrid:GetValue("DJF_SEQEND")
	
ElseIf cIdCampo == "DJF_SEQEND"

	cClient := oModelGrid:GetValue("DJF_CLIENT")
	cLoja	 := oModelGrid:GetValue("DJF_LOJA")
	cSeqEnd := cValue
	
EndIf

If !Empty(cClient) .AND. !Empty(cLoja)
	
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	
	If SA1->( dbSeek(FwxFilial("SA1") + cClient + cLoja) )
		
		// Preenche os dados do Cliente
		oModelGrid:LoadValue("DJF_NOME",	SA1->A1_NOME)
		oModelGrid:LoadValue("DJF_END",		SA1->A1_END)
		oModelGrid:LoadValue("DJF_BAIRRO",	SA1->A1_BAIRRO)
		oModelGrid:LoadValue("DJF_MUN",		SA1->A1_MUN)
		oModelGrid:LoadValue("DJF_EST",		SA1->A1_EST)
		
		// Verifica campo sequencia de Endereço
		If !Empty(cSeqEnd)
			dbSelectArea("DUL")
			DUL->(dbSetOrder(2))
			If DUL->( dbSeek(FwxFilial("DUL") + cClient + cLoja +  cSeqEnd ) )
				oModelGrid:LoadValue("DJF_END",		DUL->DUL_END)
				oModelGrid:LoadValue("DJF_BAIRRO",	DUL->DUL_BAIRRO)
				oModelGrid:LoadValue("DJF_MUN",		DUL->DUL_MUN)
				oModelGrid:LoadValue("DJF_EST",		DUL->DUL_EST)
			EndIf
		EndIf
		
		aFldActive:= oView:GetFolderActive("Folder",2)
		
		If aFldActive[1] == 1
			//Altera MDF-e
			
			If Empty(oModelGrid:GetValue("DJF_IDLIN"))
				oModelGrid:LoadValue("DJF_IDLIN",StrZero(Randomize(1,999999999),9,0))
			EndIf
		
			F12EdtMDFe(oModel,oView,"2",oModelGrid:GetValue("DJF_EST"),oModelGrid:GetValue("DJF_IDLIN"),.T.)
			oView:Refresh("VwGridDJK") //Atualiza a tela de MDF-e
		EndIf
		
		dbSelectArea("DDO")
		DDO->(DbSetOrder(1))
		
		//Preenche a Distancia Entre o Cliente anterior e o Atual
		If nLineAtu > 1
		
			// Busca a linha anterior valida
			nAntLine := LinValida(oModelGrid,nLineAtu,.F.)
			If nAntLine > 0
				
				// Verifica o Cliente Devedor
				If !Empty(oModelGrid:GetValue("DJF_CLIDEV",nAntLine))
					aCliDDO := Taf12TipKM(oModelGrid:GetValue("DJF_TIPOKM",nAntLine),oModelGrid:GetValue("DJF_CLIDEV",nAntLine),oModelGrid:GetValue("DJF_LOJDEV",nAntLine)   )
		          	cCliDDO := aCliDDO[2]
					cLojDDO := aCliDDO[3]  
				Else				
					cCliDDO := cCliGen
					cLojDDO := cLojGen
				EndIf 
				
				If DDO->(DbSeek(xFilial("DDO") + cCliDDO + cLojDDO + oModelGrid:GetValue("DJF_CLIENT",nAntLine) + oModelGrid:GetValue("DJF_LOJA",nAntLine)+ oModelGrid:GetValue("DJF_SEQEND",nAntLine) + cClient + cLoja + cSeqEnd))
		   			oModelGrid:LoadValue("DJF_KM", DDO->DDO_KM) 
		   		Else
		   			oModelGrid:LoadValue("DJF_KM", 0) 
		       EndIf
			EndIf
		EndIf
		
		//Preenche a Distancia Entre o Cliente Atual e o Proximo
		If nLineAtu < oModelGrid:Length()
			
			// Busca a Proxima linha valida 
			nProxLine := LinValida(oModelGrid,nLineAtu,.T.)
			If nProxLine > 0
				
				// Verifica o Cliente Devedor
				If !Empty(oModelGrid:GetValue("DJF_CLIDEV",nProxLine))
					aCliDDO := Taf12TipKM(oModelGrid:GetValue("DJF_TIPOKM",nProxLine),oModelGrid:GetValue("DJF_CLIDEV",nProxLine),oModelGrid:GetValue("DJF_LOJDEV",nProxLine)   )  
					cCliDDO := aCliDDO[2]
					cLojDDO := aCliDDO[3]   
				Else
					cCliDDO := cCliGen
					cLojDDO := cLojGen
				EndIf
			
				If DDO->(DbSeek(xFilial("DDO") + cCliDDO + cLojDDO + cClient + cLoja + cSeqEnd + oModelGrid:GetValue("DJF_CLIENT",nProxLine) + oModelGrid:GetValue("DJF_LOJA",nProxLine) + oModelGrid:GetValue("DJF_SEQEND",nProxLine)))
					oModelGrid:GoLine( nProxLine )
		   			oModelGrid:LoadValue("DJF_KM", DDO->DDO_KM) 
		   			oModelGrid:GoLine(nLineAtu)
		   		Else
		   			oModelGrid:GoLine( nProxLine )
		   			oModelGrid:LoadValue("DJF_KM", 0) 
		   			oModelGrid:GoLine(nLineAtu)
		       EndIf
			EndIf
		EndIf 
	EndIf

Else
	// Limpa os dados do Cliente 
	oModelGrid:LoadValue("DJF_NOME",	"")
	oModelGrid:LoadValue("DJF_END",		"")
	oModelGrid:LoadValue("DJF_BAIRRO",	"")
	oModelGrid:LoadValue("DJF_MUN",		"")
	oModelGrid:LoadValue("DJF_EST",		"")		
EndIf

oModelGrid:GoLine(nLineAtu) //posiciona na linha    
oView:Refresh(cIdForm) //Atualiza a tela 

RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AF12VldFld
Valida os campos de Cliente e loja

@author Paulo Henrique  

@since 07/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF12VldFld(cCampo)
Local lRet  	   := .T. 				// Recebe o Retorno
Local oView 	   := FwViewActive()	// Recebe a View Ativa
Local oModel	   := FwModelActive()// Recebe o Model Ativo
Local oModelGrid := NIL				// Recebe o Modelo do Grid 
Local oViewObj   := NIL				// Recebe o Objeto do View
Local aCurrSel   := {}				// Recebe o Objeto selecionado 
Local cCliente   := ""				// Recebe o Cliente 
Local cLoja	   := ""				// Recebe a Loja do Cliente 
Local cSeqEnd    := ""				// Recebe a Sequencia de Endereço
Local nLinha     := 0				// Recebe a Linha atual
Local cHora	   := ""				// Recebe o valor da hora digitada
Local dData	   := CTOD("")		// Recebe o valor da data digitada
Local nFolder	   := 0  				//--Contador dos Folders	
Local cTipoKM	   := "" 				//--Tipo de KM a ser utilizada 1=Transportadora;2=Cliente
Local aRet 	   := {} 				//--Recebe a informação da KM é por cliente ou da transportadora
Local cCliDe	   := "" 				//--Codigo do cliente da origem do trecho
Local cCliAte	   := "" 				//--Codigo do cliente do destino do trecho
Local cLojAte	   := "" 				//--Loja do destino do trecho
Local nLinhaAnt  := 0  				//--Linha da Origem do Trecho
Local cSeqAte	   := "" 				//--Sequencia de endereço do detino do trecho 
Local cSeqDe	   := "" 				//--Sequencia de endereço da origem do trecho
Local aFldActive := {} 				//--Array que receberá o conteúdo do Folder Ativo
Local aFldRpt	   := {} 				//--Folders que possuem o mesmo trecho, no qual o usuário está alterando a KM
Local oMdlGrdAtu := Nil				//--Recebe os modelos que serão atualizados com o novo KM
Local aAreaSA1   := SA1->(GetArea())
Local cViewId		:= ""
Local nCntFor1      := 0
Local aRetAtu       := {}
Local cCliDevAtu    := ""
Local cLojDevAtu    := ""
Local cTipoKMAtu    := ""

Default cCampo := ReadVar()

aCurrSel   := oView:GetCurrentSelect()
oViewObj   := oView:GetViewObj(aCurrSel[1])
oModelGrid := oModel:GetModel( oViewObj[6] ) //grid do folder
nLinha     := oModelGrid:GetLine() 


If cCampo $ "M->DJF_CLIENT|M->DJF_LOJA|M->DJF_SEQEND"

	cCliente := oModelGrid:GetValue("DJF_CLIENT",nLinha)
	cLoja	  := oModelGrid:GetValue("DJF_LOJA",nLinha)
	cSeqEnd  := oModelGrid:GetValue("DJF_SEQEND",nLinha)
	
	// Verifica se o cliente e Loja estão preenchidos
	If !Empty( cCliente ) .AND. !Empty( cLoja )
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		lRet :=  SA1->(dbSeek(FwxFilial("SA1")+ cCliente + cLoja)) // Valida se os dados do cliente existem na tabela SA1
	
		If lRet 
			If !Empty( cSeqEnd )
				
				DUL->(DbSetOrder(2))
				If !DUL->(MsSeek(xFilial("DUL")+ cCliente + cLoja + cSeqEnd))
						Help(" ",1,"TMSAF1201") //-- Sequencia de endereco nao encontrada para o Cliente.
						lRet := .F.   
				EndIf
			EndIf
		Else
			Help(" ",1,"TMSAF1205") //-- Cliente e Loja não encontrados.	
		EndIf
		
	EndIf
	
ElseIf cCampo $ "M->DJF_HORPRE|M->DJF_DATPRE"

	cHora	:= oModelGrid:GetValue("DJF_HORPRE",nLinha)
	dData  := oModelGrid:GetValue("DJF_DATPRE",nLinha)

	If !Empty(dData) .AND. !Empty(cHora)
	
		If !ValDatHor(dData,cHora,dDataBase,StrTran(Left(Time(),5),':',''),,,,.F.)
			lRet := .F.
			Help(" ",1,"TMSAF1202") //-- Data e hora não podem ser menor que a Atual
		EndIf
		
	ElseIf !Empty(dData)
		
		If !ValDatHor(dData,StrTran(Left(Time(),5),':',''),dDataBase,StrTran(Left(Time(),5),':',''),,,,.F.)
			lRet := .F.
			Help(" ",1,"TMSAF1203") //-- Data não pode ser menor que data Atual
		EndIf
		
	ElseIf !Empty(cHora)
		
		If !ValDatHor(dDataBase + 1,cHora,dDataBase,StrTran(Left(Time(),5),':',''),,,,.F.)
			lRet := .F.
			Help(" ",1,"TMSAF1204") //-- Hora Invalida
		EndIf
		
	EndIf
	
ElseIf cCampo $ "M->DJF_KM"

	cCliAte   := oModelGrid:GetValue("DJF_CLIENT",nLinha)
	cLojAte  := oModelGrid:GetValue("DJF_LOJA",nLinha)
	cSeqEnd  := oModelGrid:GetValue("DJF_SEQEND",nLinha)
	nLinhaAnt := LinValida(oModelGrid,nLinha,.F.) //--Busca proxima linha valida
	If nLinhaAnt > 0 
		cCliDe  := oModelGrid:GetValue("DJF_CLIENT",nLinhaAnt)
		cLojDe  := oModelGrid:GetValue("DJF_LOJA",nLinhaAnt)
		cSeqDe  := oModelGrid:GetValue("DJF_SEQEND",nLinhaAnt)
	Else
		Help(" ",1,"TMSAF1208") //-- O primeiro trecho de passagem não possuirá KM.	
		lRet := .F.
	EndIf
	//--Determinar qual é o folder ativo para desconsiderá-lo na busca...
	If lRet
		cCliDev := oModelGrid:GetValue("DJF_CLIDEV",nLinha)
		cLojDev := oModelGrid:GetValue("DJF_LOJDEV",nLinha)
		cTipoKM := oModelGrid:GetValue("DJF_TIPOKM",nLinha)
		
		aRet := Taf12TipKM (cTipoKM, cCliDev, cLojDev)
		//--Verifica se o devedor possui KM genérica. (KM da Transportadora)
		If aRet[1] == '1' //--Cliente Generico
			aFldActive:= oView:GetFolderActive("Folder",2)
			//--Sendo cliente generico será necessario procurar nos outros folders se existe o mesmo trecho
			//--Não considera o primeiro folder, pois este trata-se de Folder Geral.
			For nFolder:= 1 To nQtdFolder
				
				//--Ignora comparacao com o Folder Ativo na validação do campo	
				If aFldActive[1] <> nFolder  
				
					oModelGrid := oModel:GetModel("MdGridDJF"+AllTrim(Str(nFolder)))
					cViewId := "VwGridDJF"+AllTrim(Str(nFolder))

					cCliDevAtu := oModelGrid:GetValue("DJF_CLIDEV",1)
					cLojDevAtu := oModelGrid:GetValue("DJF_LOJDEV",1)
					cTipoKMAtu := oModelGrid:GetValue("DJF_TIPOKM",1)
					aRetAtu    := Taf12TipKM (cTipoKMAtu, cCliDevAtu, cLojDevAtu)
					
					//--Pesquisa o mesmo trecho (dois pontos) em outro folder 
					If aRetAtu[1] == '1' //--Cliente Generico
						For nCntFor1 := 1 To oModelGrid:Length(.F.)
							//--Busca a linha anterior valida do folder que possui o mesmo cliente do folder atual
							nLinhaAnt:=  LinValida(oModelGrid,nCntFor1,.f.)
							//--Dados da linha anterior do folder que possui o mesmo cliente do folder atual
							If nLinhaAnt > 0											
								If PadR(cCliDe,Len(SA1->A1_COD))  + PadR(cLojDe,Len(SA1->A1_LOJA))  + PadR(cSeqDe,Len(DUL->DUL_SEQEND))  == ;
								   PadR(oModelGrid:GetValue("DJF_CLIENT",nLinhaAnt),Len(SA1->A1_COD)) + PadR(oModelGrid:GetValue("DJF_LOJA",nLinhaAnt),Len(SA1->A1_LOJA)) + PadR(oModelGrid:GetValue("DJF_SEQEND",nLinhaAnt),Len(DUL->DUL_SEQEND)) .And. ;
								   PadR(cCliAte,Len(SA1->A1_COD)) + PadR(cLojAte,Len(SA1->A1_LOJA)) + PadR(cSeqAte,Len(DUL->DUL_SEQEND)) == ;
								   PadR(oModelGrid:GetValue("DJF_CLIENT",nCntFor1),Len(SA1->A1_COD))  + PadR(oModelGrid:GetValue("DJF_LOJA",nCntFor1),Len(SA1->A1_LOJA))  + PadR(oModelGrid:GetValue("DJF_SEQEND",nCntFor1),Len(DUL->DUL_SEQEND))
									//--Verifica se o Tipo da Quilmetragem do cliente devedor é Genérico
									//--Se for genérico não apresenta Avisa o Usuário que a alteração não poderá ser realizada..
									
									aRet := Taf12TipKM (oModelGrid:GetValue("DJF_TIPOKM"), oModelGrid:GetValue("DJF_CLIDEV"), oModelGrid:GetValue("DJF_LOJDEV"))
									If Len(aRet) > 0
										If aRet[1] == '1'											
											aAdd(aFldRpt,{oModelGrid:GetValue("DJF_CLIDEV"),oModelGrid:GetValue("DJF_LOJDEV"),oModelGrid,cViewId,nCntFor1})
										EndIf
									EndIf
										
								EndIf	
							EndIf
						Next nCntFor1
					EndIf
				EndIf	  
			Next nFolder
			//--Atualza o mesmo trecho identificado em outros roteiros
			For nFolder := 1 To Len (aFldRpt)			
				oMdlGrdAtu := aFldRpt[nFolder,3]
				oMdlGrdAtu:GoLine(aFldRpt[nFolder,5])
				oMdlGrdAtu:LoadValue("DJF_KM",&cCampo)							
				oView:Refresh(aFldRpt[nFolder,4])
			Next nFolder 
		EndIf	
	EndIf
ElseIf cCampo $ "M->DJF_SEQUEN"
	If Empty(oModelGrid:GetValue("DJF_SEQUEN",nLinha))
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaSa1)


Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PreVldMdl
Pré-valida a Linha do grid

Uso: TMSAF12

@sample
//PreVldMdl(oModelGrid,nLine,cAction)

@author Paulo Henrique Corrêa Cardoso.
@since 08/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldMdl(oModelGrid,nLine,cAction)
Local lRet 		:= .T.					// Recebe o Retorno
Local aAreaDJF	:= DJF->(GetArea())	// Recebe a Area da tebela DJF

oModelGrid:GoLine(nLine)
If cAction == 'DELETE' // Reordenação quando linha estiver sendo excluida
	// Verifica se a Linha poderá ser excluida 
	If lRet :=(( oModelGrid:GetValue("DJF_DOCGER",nLine) $ "1|3" .OR.( oModelGrid:GetValue("DJF_RATEIO",nLine) $ "2|3" ;
		.AND. oModelGrid:GetValue("DJF_VALTRE",nLine) $ "2|3" )) .OR. IsInCallStack("AF12DelDoc"))
		
		If cSerTms == '3' .And. oModelGrid:GetValue("DJF_SEQUEN",nLine) == '01' .And. oModelGrid:GetValue("DJF_TIPOPE",nLine) $ "6"   //Filial 
			MsgAlert(STR0052) ////"Ao excluir o ponto inicial (Filial) do roteiro, o sistema assumirá a Região do ponto seguinte como sendo a Origem da Rota. Caso deseje indicar outra Região para o iníco da rota, inclua um ponto de Apoio, informando o Código do Cliente onde a operação se iniciará."
		EndIf	
	
		AF12OrdSeq(oModelGrid,nLine,.F.)
		
	Else
		Help(" ",1,"TMSAF1206") //-- O trecho não pode ser excluido! Somente trechos do Tipo de Operação igual a "Filial" ou "Apoio", trechos com CTRC/NFS gerados ,ou trechos sem documento(S) de rateio e que não sejam Valorizados, poderão ser excluidos.       
	EndIf
	
ElseIf cAction == 'UNDELETE'   // Reordenação quando linha estiver sendo Recuperada
	
	If lRet := !oModelGrid:GetValue("DJF_EXCVIA",nLine)
		AF12OrdSeq(oModelGrid,nLine,.T.)
	Else
		Help(" ",1,"TMSAF1207") // "O trecho não pode ser recuperado pois o mesmo foi excluido a partir da viagem."  
	EndIf
	
ElseIf cAction ==  "CANSETVALUE"

	If oModelGrid:cId != "MdGridDJF1" .AND.  Empty(oModelGrid:GetValue("DJF_CLIDEV",nLine))
		oModelGrid:LoadValue("DJF_CLIDEV",oModelGrid:GetValue("DJF_CLIDEV",LinValida(oModelGrid,nLine,.F.)))
		oModelGrid:LoadValue("DJF_LOJDEV",oModelGrid:GetValue("DJF_LOJDEV",LinValida(oModelGrid,nLine,.F.)))
	EndIf 
	
	// Preenche Filial de Origem e Viagem 
	If Empty(oModelGrid:GetValue("DJF_FILORI",nLine)) .OR. Empty(oModelGrid:GetValue("DJF_VIAGEM",nLine))
		oModelGrid:LoadValue("DJF_FILORI", cFilVge )
		oModelGrid:LoadValue("DJF_VIAGEM", cViagem )
	EndIf
EndIf

RestArea(aAreaDJF)	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PreVldDJK
Pré-valida a Linha do grid DJK

Uso: TMSAF12

@sample
//PreVldDJK(oModelGrid,nLine,cAction)

@author Paulo Henrique Corrêa Cardoso.
@since 28/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldDJK(oModelGrid,nLine,cAction)
Local lRet 		:= .T.					// Recebe o Retorno
Local aAreaDJK	:= DJK->(GetArea())	// Recebe a Area da tebela DJK
Local lEdit		:= .F.					// Recebe se a edição poderá ser ralizada
Local oView		:= FwViewActive() 	// Recebe a View Ativa

oModelGrid:GoLine(nLine)


lEdit :=  IsInCallStack("F12EdtMDFe") .OR. Empty(oModelGrid:GetValue("DJK_IDDJF",nLine)) .OR. IsInCallStack("AF12OrdSeq") .OR. IsInCallStack("Af012Reord") 

If cAction == 'DELETE'  //Verifica se pode excluir a linha	

	If lEdit
		TMSOrdDel(oView,oModelGrid,"DJK_SEQUEN",nLine,.F.)
	Else
		lRet := .F.
	EndIf
	
EndIf

If cAction == 'UNDELETE' //Verifica se pode recuperar a linha	
	If lEdit
		TMSOrdDel(oView,oModelGrid,"DJK_SEQUEN",nLine,.T.)
	Else
		lRet := .F.
	EndIf
EndIf

If cAction == 'CANSETVALUE' .AND. !lEdit //Verifica se pode editar a linha	
	lRet := .F.
Else
	oModelGrid:LoadValue("DJK_FILORI",cFilVge)
	oModelGrid:LoadValue("DJK_VIAGEM",cViagem)
EndIf

RestArea(aAreaDJK)	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} AF12OrdSeq
Realiza a Ordenação de exclusão e recuperação da Linha

Uso: TMSAF12

@sample
//AF12OrdSeq(oModelGrid,nLine,lRecupera)

@author Paulo Henrique Corrêa Cardoso.
@since 09/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function AF12OrdSeq(oModelGrid,nLine,lRecupera)
Local aArea       := GetArea()      // Recebe a Area Atual
Local oView       := FwViewActive() // Recebe a View Ativa
Local oModel      := Iif(oModelGrid <> Nil, oModelGrid:oFormModel, Nil) //FwModelActive()// Recebe o modelo ativo
Local aRetView    := {}             // Recebe o ultimo Componente selecionado da View
Local nAntLine    := 0              // Recebe a linha anterior Valida
Local nProxLine   := 0              // Recebe a Proxima linha valida
Local nLineDDO    := 0              // Recebe a linha que deve atualizar a DDO
Local aCliDDO     := {}             // Recebe os clientes que serão utilizadas para consulta ou gravação da KM na Tabela DDO (Cliente poderá ser Genérico ou o DEVEDOR).
Local cCliDDO     := ""
Local cLojDDO     := ""
Local cCliGen     := SuperGetMV("MV_CLIGEN",.F., "") 
Local cLojGen     := ""
Local oMdlGrdDJK  := NIL
Local aFldActive  := {}

Default oModelGrid   := NIL        // Recebe o Modelo do Grid
Default nLine        := 0          // Recebe a linha atual
Default lRecupera    := .F.        // Recebe a variavel de controle de Exclusção ou recuperação de linha

// Recebe o ultimo Componente selecionado da View
aRetView := oView:GetCurrentSelect()


// Busca o Cliente Generico
SA1->(DbSetOrder(1))
If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
	cCliGen := SA1->A1_COD
	cLojGen := SA1->A1_LOJA
EndIf


// Realiza a reordenação de linhas após exclusão
If TMSOrdDel(oView,oModelGrid,"DJF_SEQUEN",nLine,lRecupera)

	// Pega a aba ativa
	aFldActive:= oView:GetFolderActive("Folder",2)
		
	If aFldActive[1] == 1
	
		// Recebe o modelo do DJK
		oMdlGrdDJK := oModel:GetModel("MdGridDJK")
		
		// Apaga a linha correspondente do grid DJK
		If ValType(oMdlGrdDJK) <> "U" .And. oMdlGrdDJK:SeekLine( {{ "DJK_IDDJF", oModelGrid:GetValue("DJF_IDLIN") }},.T. )
			
			If !Empty(oMdlGrdDJK:GetValue("DJK_IDDJF"))
				If lRecupera
					oMdlGrdDJK:UnDeleteLine()
				Else
					oMdlGrdDJK:DeleteLine()
				EndIf
			EndIf
		EndIf
		oMdlGrdDJK:GoLine(1)
	EndIf
	
	ChkFile("DDO")
	dbSelectArea("DDO")
	DDO->(DbSetOrder(1))
		
	If lRecupera
		nLineDDO := nLine 	
	Else
	
		nLineDDO := LinValida(oModelGrid,nLine,.T.)
	EndIf
		
	//Preenche a Distancia Entre o Cliente anterior e o Atual
	If nLineDDO > 1
		// Busca a linha anterior valida
		nAntLine := LinValida(oModelGrid,nLine,.F.)
		
		If nAntLine > 0
			
			// Verifica o Cliente Devedor
			If !Empty(oModelGrid:GetValue("DJF_CLIDEV",nAntLine))  
				aCliDDO := Taf12TipKM(oModelGrid:GetValue("DJF_TIPOKM",nAntLine),oModelGrid:GetValue("DJF_CLIDEV",nAntLine),oModelGrid:GetValue("DJF_LOJDEV",nAntLine)   )
				cCliDDO := aCliDDO[2]
				cLojDDO := aCliDDO[3]   
			Else
				cCliDDO := cCliGen
				cLojDDO := cLojGen
			EndIf 
		
			If DDO->(DbSeek(xFilial("DDO") + cLojDDO + cLojDDO + oModelGrid:GetValue("DJF_CLIENT",nAntLine) + oModelGrid:GetValue("DJF_LOJA",nAntLine)+ oModelGrid:GetValue("DJF_SEQEND",nAntLine)+ ;
			 oModelGrid:GetValue("DJF_CLIENT",nLineDDO) + oModelGrid:GetValue("DJF_LOJA",nLineDDO)+  oModelGrid:GetValue("DJF_SEQEND",nLineDDO)))
				oModelGrid:GoLine(nLineDDO)
	   			oModelGrid:LoadValue("DJF_KM", DDO->DDO_KM) 
	   		Else
	   			oModelGrid:GoLine(nLineDDO)
	   			oModelGrid:LoadValue("DJF_KM", 0) 
	       EndIf
	   	Else
	   		oModelGrid:GoLine(nLineDDO)
	   		oModelGrid:LoadValue("DJF_KM", 0) 
	   EndIf
	EndIf
	
	//Preenche a Distancia Entre o Cliente Atual e o Proximo
	If nLineDDO < oModelGrid:Length() .AND. nLineDDO > 0
	
		// Busca a proxima linha valida
		nProxLine := LinValida(oModelGrid,nLineDDO,.T.)
		If nProxLine > 0 
			
			// Verifica o Cliente Devedor
			If !Empty(oModelGrid:GetValue("DJF_CLIDEV",nLineDDO))  
				aCliDDO := Taf12TipKM(oModelGrid:GetValue("DJF_TIPOKM",nLineDDO),oModelGrid:GetValue("DJF_CLIDEV",nLineDDO),oModelGrid:GetValue("DJF_LOJDEV",nLineDDO)   )
				cCliDDO := aCliDDO[2]
				cLojDDO := aCliDDO[3]
			Else
				cCliDDO := cCliGen
				cLojDDO := cLojGen
			EndIf 
			
			If DDO->(DbSeek(xFilial("DDO") + cCliDDO + cLojDDO + oModelGrid:GetValue("DJF_CLIENT",nLineDDO ) + oModelGrid:GetValue("DJF_LOJA",nLineDDO) + oModelGrid:GetValue("DJF_SEQEND",nLineDDO)+ ;
			 oModelGrid:GetValue("DJF_CLIENT",nProxLine) + oModelGrid:GetValue("DJF_LOJA",nProxLine) + oModelGrid:GetValue("DJF_SEQEND",nProxLine) ))
			 
				oModelGrid:GoLine(nProxLine)
	   			oModelGrid:LoadValue("DJF_KM", DDO->DDO_KM) 
	   			oModelGrid:GoLine(nLineDDO)
	   		Else
	   			oModelGrid:GoLine(nProxLine)
	   			oModelGrid:LoadValue("DJF_KM",0) 
	   			oModelGrid:GoLine(nLineDDO)
	       EndIf
	   EndIf
	EndIf

EndIf

oModelGrid:GoLine(nLine) //posiciona na linha   
If !Empty(aRetView[1])
	oView:Refresh(aRetView[1]) 
EndIf

RestArea(aArea)
Return


/*/-----------------------------------------------------------
{Protheus.doc} Tf12OriDes
Busca a regiao de origem do roteiro informado

Uso: TMSAF12

@sample
//Tf12OriDes(cSeqend,cClient,cLoja)

@author Leandro
@since 12/05/2016
@version 1.0
-----------------------------------------------------------/*/

Static Function Tf12OriDes(cSeqEnd,cClient,cLoja)

Local cRet		   := ''

Default cSeqEnd 	:= ''
Default cClient 	:= ''
Default cLoja 	:= ''

If !Empty(cClient) .And. !Empty(cLoja)
	If Empty(cSeqEnd) 
		SA1->(dbSetOrder(1))
		If SA1->(MsSeek(FwxFilial('SA1')+cClient+cLoja))
			cRet := SA1->A1_CDRDES
		EndIf			
	Else
		DUL->(dbSetOrder(2))
		If DUL->(MsSeek(FwxFilial('DUL')+cClient+cLoja+cSeqEnd))
			cRet := DUL->DUL_CDRDES	 
		EndIf 
	EndIf
EndIf
	
Return cRet


/*/-----------------------------------------------------------
{Protheus.doc} A12SavDDO
Salva os Registros da Tabela DDO

Uso: TMSAF12

@sample
//A12SavDDO(oModel,lVisual)

@author Paulo Henrique Corrêa Cardoso
@since 19/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A12SavDDO(oModel,lVisual)
Local lRet	 		:= .T.					// Recebe o retorno
Local oMdlGrid		:= NIL					// Recebe o Modelo do Grid
Local nCount		:= 0					// Recebe o Contador do primeiro for
Local nCount2		:= 0					// Recebe o Contador do segundo for
Local aSaveLine		:= FWSaveRows()			// Salva as posições de linha do Grid
Local cCliAnt		:= ""					// Recebe o Cliente da Linha anterior 
Local cLojAnt		:= ""					// Recebe a loja do cliente da linha anterior
Local cSeqAnt		:= ""					// Recebe a sequenciaa de endereço da linha anterior
Local cCliAtu		:= ""					// Recebe o Cliente da Linha Atual 
Local cLojAtu		:= ""					// Recebe a loja do cliente da linha Atual
Local cSeqAtu		:= ""					// Recebe a sequenciaa de endereço da linha Atual
Local cCliKm		:= ""					// Recebe o cliente responsavel pelo KM
Local cLojKm		:= ""					// Recebe a Loja do cliente Responsavel pelo KM
Local aConteud		:= {}					// Recebe o Conteudo que será gravado na DDO
Local aRetAut		:= {}					// Recebe o Retorno da Rotina Automatica
Local cCliDDO	  	 := ""
Local cLojDDO		 := ""
Local cCliGen		 := SuperGetMV("MV_CLIGEN",.F., "") 
Local cLojGen		 := ""

Default oModel	:= FwModelActive()	// Recebe o Modelo 
Default lVisual	:= .T.					// Recebe se deve exibir componentes de tela

// Busca o Cliente Generico	
SA1->(DbSetOrder(1))
If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
	cCliGen := SA1->A1_COD
	cLojGen := SA1->A1_LOJA
EndIf

dbSelectArea("DDO")
DDO->( dbSetOrder(1) )

For nCount:= 1 To nQtdFolder
	oMdlGrid := oModel:GetModel("MdGridDJF"+AllTrim(Str(nCount)))
	
	cCliAnt := ""
	cLojAnt := ""
	cSeqAnt := ""
			
	For nCount2 := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nCount2)
		
		If !oMdlGrid:IsDeleted() 
			cCliKm  := oMdlGrid:GetValue("DJF_CLIDEV")
			cLojKm  := oMdlGrid:GetValue("DJF_LOJDEV")
			cCliAtu := oMdlGrid:GetValue("DJF_CLIENT")
			cLojAtu := oMdlGrid:GetValue("DJF_LOJA")
			cSeqAtu := oMdlGrid:GetValue("DJF_SEQEND")
			
			If !Empty(cCliAnt) .AND. !Empty(cLojAnt).AND. oMdlGrid:GetValue("DJF_KM") > 0
				aConteud := {}

				// Verifica o Cliente Devedor
				If !Empty(cCliKm)  
					
					cCliDDO := cCliKm
					cLojDDO := cLojKm 
				Else
					cCliDDO := cCliGen
					cLojDDO := cLojGen
				EndIf 
				
				AADD(aConteud,{"DDO_CODCLI",cCliDDO})
				AADD(aConteud,{"DDO_LOJCLI",cLojDDO})
				AADD(aConteud,{"DDO_CLIDE",cCliAnt})
				AADD(aConteud,{"DDO_LOJDE",cLojAnt})
				AADD(aConteud,{"DDO_SEQDE",cSeqAnt})
				AADD(aConteud,{"DDO_CLIATE",cCliAtu})
				AADD(aConteud,{"DDO_LOJATE",cLojAtu})
				AADD(aConteud,{"DDO_SEQATE",cSeqAtu})
				AADD(aConteud,{"DDO_KM",oMdlGrid:GetValue("DJF_KM")})
				
				If cCliAnt + cLojAnt + cSeqAnt != cCliAtu + cLojAtu + cSeqAtu
					If DDO->( dbSeek( FwxFilial("DDO") + cCliDDO + cLojDDO + cCliAnt + cLojAnt + cSeqAnt + cCliAtu + cLojAtu + cSeqAtu  )  )
						If Empty(DDO->DDO_KM)
							aRetAut := AF14xAut(aConteud,MODEL_OPERATION_UPDATE,lVisual)
						EndIf
					Else
						aRetAut :=  AF14xAut(aConteud,MODEL_OPERATION_INSERT,lVisual)
					EndIf
					
					If Len(aRetAut) > 0
						If !aRetAut[1]
							lRet := .F.
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
			
			cCliAnt := cCliAtu
			cLojAnt := cLojAtu
			cSeqAnt := cSeqAtu
			
		EndIf
		
	Next nCount2
	
Next nCount 

FWRestRows( aSaveLine )

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} F12DbClick
Salva os Registros da Tabela DDO

Uso: TMSAF12

@sample
//F12DbClick(oForm,cFieldName,nLineGrid,nLineModel)

@author Paulo Henrique Corrêa Cardoso
@since 19/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function F12DbClick(oGrdView,cFieldName,nLineGrid,nLineModel)
Local aArea			:= GetArea()
Local oModelGrid		:= NIL
Local cValue			:= ""
Local aLegenda		:= {}		
Local cTitulo			:= ''
Local oView          := FwViewActive()

Default oGrdView 	 	:= NIL
Default cFieldName 	:= ""
Default nLineGrid  	:= 0
Default nLineModel 	:= 0

oModelGrid := oGrdView:GetModel()
oModelGrid:GoLine(nLineModel)

If cFieldName == "DJF_LEGRAT"
	cValue := oModelGrid:GetValue("DJF_RATEIO")
	
	Aadd(aLegenda,{"BR_VERDE", STR0022}) //"Trecho com documento(S) de rateio"
	Aadd(aLegenda,{"BR_AZUL" , STR0023}) //"Trecho sem documento(S) de rateio" 
	Aadd(aLegenda,{"BR_AMARELO" , STR0024}) //"Não Verifica"
	cTitulo:= STR0011 //"Rateio"
	
ElseIf cFieldName == "DJF_LEGDOC"
	cValue := oModelGrid:GetValue("DJF_DOCGER")
	
	Aadd(aLegenda,{"BR_VERDE", STR0025}) //"Trecho com CTRC/NFS"
	Aadd(aLegenda,{"BR_AZUL" , STR0026}) //"Trecho sem CTRC/NFS"
	Aadd(aLegenda,{"BR_AMARELO" , STR0024}) //"Não Verifica"
	cTitulo:= STR0013 //"Docto.Gerado"
	
ElseIf cFieldName == "DJF_LEGVAL"

	cValue := oModelGrid:GetValue("DJF_VALTRE")
	
	Aadd(aLegenda,{"BR_VERDE", STR0027}) //"Valoriza o Trecho"
	Aadd(aLegenda,{"BR_AZUL" , STR0028}) //"Não Valoriza o Trecho"
	Aadd(aLegenda,{"BR_AMARELO" , STR0024}) //"Não Verifica"
	cTitulo:= STR0029 //"Valorização do Trecho" 
	
ElseIf cFieldName == "DJK_LEGORI"

	
	Aadd(aLegenda,{"BR_VERDE"   , "Pontos do Roteiro"})  //"Pontos do Roteiro"
	Aadd(aLegenda,{"BR_AMARELO" , "Pontos Adicionados"}) //"Pontos Adicionados"
	cTitulo:= STR0030 //"Legenda"
	
ElseIf cFieldName == "DJK_BTTOP" // Botão de adicionar linha a cima
	
	If !oModelGrid:IsDeleted()
		cValue := oModelGrid:GetValue("DJK_SEQUEN")
		TMSAddLnMd(oView,oModelGrid,"VwGridDJK","DJK_SEQUEN",.F.,cValue)
	EndIf
	
ElseIf cFieldName == "DJK_BTLOW"  // Botão de adicionar linha a baixo
	
	If !oModelGrid:IsDeleted()
		cValue := oModelGrid:GetValue("DJK_SEQUEN")
		TMSAddLnMd(oView,oModelGrid,"VwGridDJK","DJK_SEQUEN",.T.,cValue)
		oModelGrid:GoLine(nLineGrid)
	EndIf
	
EndIf

If Len(aLegenda) > 0  
	BrwLegenda(cTitulo, STR0030 , aLegenda) //"Legenda"
EndIf


RestArea(aArea)

Return .T.
/*/-----------------------------------------------------------
{Protheus.doc} TF12VldRot
Função: Chama função que verificará se o roteiro já foi inserido em outro folder
		 A mesma função incluirá os dados no vetor aRotInc, vetor que apresentará 
		 os roteiros que precisam de uma rota

Uso: TMSAF12

@sample
			
//TF12VldRot(oModelGrd, aVetRoteir, aVetTrecho,cNewRot)

@author Leandro Paulino
@since 27/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function TF12VldRot(oModelGrd, aVetRoteir, aVetTrecho,cNewRot)

Local nCnt1			:= 0
Local nCnt2			:= 0
Local lRet				:= .T.
Local cRotIdent		:= ""

Default oModelGrd  	:= Nil
Default aVetRoteir	:= {}
Default aVetTrecho	:= {}
Default cNewRot		:= ''

If ValType (oModelGrd) == 'O' 
	//Guarda todas as sequencias do roteiro, para garantir que não será cadastrado roteiros duplicados
	For nCnT1 := 1 To oModelGrd:GetQTDLine()
		
		oModelGrd:GoLine(nCnt1)
		If !oModelGrd:IsDeleted() 
			AADD(aVetTrecho,{oModelGrd:GetValue("DJF_SEQUEN"),oModelGrd:GetValue("DJF_CLIENT"),oModelGrd:GetValue("DJF_LOJA"),oModelGrd:GetValue("DJF_KM"),cNewRot})
		EndIf
		
	Next nCnt1
	//--Pesquisa se o aVetRoteir já consta um roteiro  identico
	
	If !Empty(aVetRoteir)
		For nCnt1 := 1 To Len (aVetRoteir)
			If Len(aVetRoteir[nCnt1]) == Len(aVetTrecho) //--VErifica se a quantidade de trechos do roteiro atuais (aVEtTrecho) é igual a qtde. de trechos do roteiro anterior (aVetTrecho)
				For nCnt2:= 1 To Len(aVetTrecho)
					//--Se um dos trechos do roteiro atual (aVEtTrecho) for diferente dos trechos anteriores (aVEtRoteir)...Considera que este trecho será gravado 
					If aVetRoteir[nCnt1,nCnt2,1] <> aVetTrecho[nCnt2,1] .Or. aVetRoteir[nCnt1,nCnt2,2] <> aVetTrecho[nCnt2,2] .Or. aVetRoteir[nCnt1,nCnt2,3] <> aVetTrecho[nCnt2,3]
						lRet := .T.
						Exit						
					Else
						cRotIdent := aVetRoteiro[nCnt1,nCnt2,5]
						lRet := .F.				
					EndIf  
				Next nCnt2				
			EndIf 
		Next  nCnt1
	EndIf	
EndIf

// Caso p roteiro seja identico Retorna o mesmo numero 
If !lRet
	cNewRot := cRotIdent
EndIf 
			
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} Taf12TipKM
Função: Verifica qual o tipo de KM do devedor.

Uso: TMSAF12

Return: Retorna o codigo do cliente que devera ser utilizado 
		 na pesquisa ou gravação do DDO.

@sample
			
//Taf12TipKM(cTipoKm,cCliDev,cLojDev)

@author Leandro Paulino
@since 27/05/2016
@version 1.0
-----------------------------------------------------------/*/

Function Taf12TipKM (cTipoKm, cCliDev, cLojDev)
	
Local aRet		:= {}
Local cCliGen	:= SuperGetMV("MV_CLIGEN",.F., "") 
Local cLojGen	:= ""

Default cTipoKm := ''
Default cCliDev := ''
Default cLojDev := ''


If  Empty(cTipoKM) .Or. cTipoKM == '1'

	// Busca o Cliente Generico            
	SA1->(DbSetOrder(1))
	If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
		cCliGen := SA1->A1_COD
		cLojGen := SA1->A1_LOJA
	EndIf

	AADD(aRet,'1'	)
	AADD(aRet,cCliGen)
	AADD(aRet,cLojGen)
		
ElseIf cTipoKM == '2'

	AADD(aRet,cTipoKM)
	AADD(aRet,cCliDev)
	AADD(aRet,cLojDev)
	
EndIf

Return aRet
/*/-----------------------------------------------------------
{Protheus.doc} TF12When
Função: Permite ou bloqueia a edição do Campo

Uso: TMSAF12

@sample
			
//TF12When()

@author Paulo Henrique Corrêa Cardoso
@since 12/06/2016
@version 1.0
-----------------------------------------------------------/*/
Function TF12When(cCampo)
Local lRet  	   := .T. 				// Recebe o Retorno
Local oView 	   := FwViewActive()	// Recebe a View Ativa
Local oModel	   := FwModelActive()	// Recebe o Model Ativo
Local oModelGrid := NIL				// Recebe o Modelo do Grid 
Local oViewObj   := NIL				// Recebe o Objeto do View
Local aCurrSel   := {}					// Recebe o Objeto selecionado 
Local nLinha     := 0					// Recebe a Linha atual
Local aCliDDO    := {} 				// Recebe os clientes que serão utilizadas para consulta ou gravação da KM na Tabela DDO (Cliente poderá ser Genérico ou o DEVEDOR).
Local cCliDDO    := ""					// Recebe o Cliente Devedor para busca na DDO
Local cLojDDO    := ""					// Recebe a Loja do Cliente Devedor para busca na DDO
Local cCliGen    := SuperGetMV("MV_CLIGEN",.F., "") // Recebe o Cliente Generico 
Local cLojGen    := ""					// Recebe a Loja do Cliente Generico
Local nLineAnt   := 0					// Recebe a Linha Anterior

Default cCampo := ReadVar()


aCurrSel := oView:GetCurrentSelect()
oViewObj := oView:GetViewObj(aCurrSel[1])
oModelGrid := oModel:GetModel( oViewObj[6] ) //grid do folder
nLinha := oModelGrid:GetLine() 

// Busca o Cliente Generico
SA1->(DbSetOrder(1))
If	SA1->(MsSeek(xFilial('SA1')+cCliGen))
	cCliGen := SA1->A1_COD
	cLojGen := SA1->A1_LOJA
EndIf


If cCampo $ "M->DJF_CLIENT|M->DJF_LOJA|M->DJF_SEQEND"
	lRet := oModelGrid:GetValue("DJF_TIPOPE",nLinha) == "1" 
	
ElseIf  cCampo $ "M->DJF_KM"
	
	// Verifica se o parametro  MV_TMALTKM esta Ativo
	If lEditKM
		lRet := .T.
	Else
		// Verifica o Cliente Devedor
		If !Empty(oModelGrid:GetValue("DJF_CLIDEV",nLinha))  
			aCliDDO := Taf12TipKM(oModelGrid:GetValue("DJF_TIPOKM",nLinha),oModelGrid:GetValue("DJF_CLIDEV",nLinha),oModelGrid:GetValue("DJF_LOJDEV",nLinha)   )
			cCliDDO := aCliDDO[2]
			cLojDDO := aCliDDO[3]
		Else
			cCliDDO := cCliGen
			cLojDDO := cLojGen
		EndIf 
		nLineAnt := LinValida(oModelGrid,nLinha,.F.)
		
		// Busca a Km do trecho 
		If nLineAnt > 0
			dbSelectArea("DDO")
			DDO->( dbSetOrder(1) )
			If DDO->(DbSeek(xFilial("DDO") + cCliDDO + cLojDDO + oModelGrid:GetValue("DJF_CLIENT",nLineAnt ) + oModelGrid:GetValue("DJF_LOJA",nLineAnt) + oModelGrid:GetValue("DJF_SEQEND",nLineAnt)+ ;
				 oModelGrid:GetValue("DJF_CLIENT",nLinha) + oModelGrid:GetValue("DJF_LOJA",nLinha) + oModelGrid:GetValue("DJF_SEQEND",nLinha) ))
				
				If DDO->DDO_KM > 0
					lRet := .F. // Só permite gravação caso a Km esteja zerada
				EndIf	
			EndIf
		EndIf	
		
	EndIf	
	
	
ElseIf cCampo $ "M->DJF_DATPRE|M->DJF_HORPRE" // Verificar docmentação MV_TMALTKM
	
	// Caso documento gerado não será possivel alterar a data e hora
	If oModelGrid:GetValue("DJF_DOCGER",nLinha)  == "1"
		lRet := .F.
	EndIf
EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} Af12ClrSts
Função: Limpa as Variaveis Staticas 

Uso: TMSAF12

@sample
			
//Af12ClrSts()

@author Paulo Henrique Corrêa Cardoso
@since 22/06/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function Af12ClrSts()

cRota      := ''
nQtdFolder := 1 
cSerTms    := ''
aRetpag    := {}
aRetpagOri := {}
aDelDocs   := {}
lExbSugRot := SuperGetMV("MV_EXSGROT",.F., .F.) // Verifica se exibe seguestão de Rota
lEditKM    := SuperGetMV("MV_TMALTKM",.F., .F.) 
aNewRot    := {}
cFilVge    := ""
cViagem    := ""
aMDFe      := {}

Return

/*/-----------------------------------------------------------
{Protheus.doc} A12SvRotei
Salva os Registros das Tabelas DJG, DDJ, DJH e DJJ

Uso: TMSAF12

@sample
//A12SvRotei(oModel,lVisual)

@author Paulo Henrique Corrêa Cardoso
@since 01/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function A12SvRotei(oModel,lVisual)
Local lRet       := .T.              // Recebe o retorno
Local oMdlGrid   := NIL              // Recebe o Modelo do Grid
Local nCount     := 0                // Recebe o Contador do primeiro for
Local nCount2    := 0                // Recebe o Contador do segundo for
Local nCount3    := 0                // Recebe o Contador do terceiro for
Local aSaveLine  := FWSaveRows()     // Salva as posições de linha do Grid
Local aCab       := {}               // Recebe o Conteudo que será gravado no cab - DJG
Local aItens     := {}               // Recebe o Conteudo que será gravado no Grid - DDJ
Local aRetAut    := {}               // Recebe o Retorno da Rotina Automatica
Local nOperat    := 0                // Recebe a operação da DDJ
Local cRoteiro   := ""               // Recebe o Codigo do Roteiro
Local cRota      := ""               // Recebe o Codigo da Rota
Local cDescri    := ""               // Recebe a Descrição do Roteiro
Local aLinha     := {}               // Recebe a linha 
Local aVetDlg    := {}               // Recebe o Vetor de docs quebrado em colunas
Local nCntDoc    := 0                // Recebe o contador de docs
Local lGrvDJJ    := .T.              // Recebe se grava na tabela de documentos do ponto   
Local lDelet     := .F.              // Recebe se apaga na tabela de documentos do ponto
Local aLinDIQ    := {}               // Recebe as linhas da DIQ
Local aValDIQ    := {}               // Recebe os valores dos campos da DIQ

Default oModel	:= FwModelActive()	// Recebe o Modelo 
Default lVisual	:= .T.					// Recebe se deve exibir componentes de tela

dbSelectArea("DJG")
DJG->( dbSetOrder(1) )

For nCount:= 1 To nQtdFolder
	
	// Limpa as variaveis
	aCab   := {}
	aItens := {}
	
	// Recebe o Grid da aba
	oMdlGrid := oModel:GetModel("MdGridDJF"+AllTrim(Str(nCount)))
	
	cRoteiro := oMdlGrid:GetValue("DJF_ROTEIR",LinValida(oMdlGrid,1,.T.))
	cRota    := oMdlGrid:GetValue("DJF_ROTA",LinValida(oMdlGrid,1,.T.))
	cDescri  := oMdlGrid:GetValue("DJF_DESCRI",LinValida(oMdlGrid,1,.T.))
	
	// Define a Operação da DJG
	If DJG->( dbSeek( FwxFilial("DJG")+ cRoteiro ) )
		nOperat := MODEL_OPERATION_UPDATE
	Else
		nOperat := MODEL_OPERATION_INSERT
	EndIf			
	
	//Preenche o Cabeçalho
	AADD(aCab,{"DJG_ROTEIR",cRoteiro})
	AADD(aCab,{"DJG_DESCRI",cDescri })
	
	// Preenche os Itens
	For nCount2 := 1 To oMdlGrid:Length()
		oMdlGrid:GoLine(nCount2)
		
		If !oMdlGrid:IsDeleted() 
			aLinha := {}
			
			AADD(aLinha,{"DDJ_ROTEIR", cRoteiro })
			AADD(aLinha,{"DDJ_SEQUEN", oMdlGrid:GetValue("DJF_SEQUEN") })
			AADD(aLinha,{"DDJ_CLIENT", oMdlGrid:GetValue("DJF_CLIENT") })
			AADD(aLinha,{"DDJ_LOJA"  , oMdlGrid:GetValue("DJF_LOJA")   })
			AADD(aLinha,{"DDJ_SEQEND", oMdlGrid:GetValue("DJF_SEQEND") })
				
			AADD(aItens,aClone(aLinha))			 

		EndIf	
		
		
		If 	!Empty(oMdlGrid:GetValue("DJF_DOCS"))		
			
			// Transforma o campo de Docs em um vetor
			aVetDlg :=	Af12QbrMtD(oMdlGrid:GetValue("DJF_DOCS"),"#","|")
			
			For nCntDoc := 1 To Len(aVetDlg)
				
				dbSelectArea("DJJ")
				DJJ->(dbSetOrder(1))
				
				
				lGrvDJJ := .T.
				lDelet  := .F.

				If DJJ->( dbSeek( FwxFilial("DJJ") + oMdlGrid:GetValue("DJF_FILORI")+ oMdlGrid:GetValue("DJF_VIAGEM")+;
				oMdlGrid:GetValue("DJF_CLIDEV") + oMdlGrid:GetValue("DJF_LOJDEV") + oMdlGrid:GetValue("DJF_CLIENT") + ;
				oMdlGrid:GetValue("DJF_LOJA") + oMdlGrid:GetValue("DJF_SEQEND") ) ) 
					
					While  DJJ->(!EOF()) .AND. DJJ->DJJ_FILIAL == FwxFilial("DJJ") ;
						 .AND. DJJ->DJJ_FILORI == oMdlGrid:GetValue("DJF_FILORI") ;
						 .AND. DJJ->DJJ_VIAGEM == oMdlGrid:GetValue("DJF_VIAGEM") ;
						 .AND. DJJ->DJJ_CLIDEV == oMdlGrid:GetValue("DJF_CLIDEV") ;
						 .AND. DJJ->DJJ_LOJDEV == oMdlGrid:GetValue("DJF_LOJDEV") ;
						 .AND. DJJ->DJJ_CLIENT == oMdlGrid:GetValue("DJF_CLIENT") ;
						 .AND. DJJ->DJJ_LOJA   == oMdlGrid:GetValue("DJF_LOJA")   ;
						 .AND. DJJ->DJJ_SEQEND == oMdlGrid:GetValue("DJF_SEQEND") ;
						 
						 If  DJJ->DJJ_TABELA == aVetDlg[nCntDoc][1] .AND. DJJ->DJJ_INDICE == aVetDlg[nCntDoc][2] .AND. RTrim(DJJ->DJJ_CHAVE)  == aVetDlg[nCntDoc][3]
							lGrvDJJ := .F.
							
							// Se a linha estiver deletada
							If oMdlGrid:IsDeleted() .OR. Ascan(aDelDocs, {|x| x[1] == aVetDlg[nCntDoc][1] .AND. x[2] == aVetDlg[nCntDoc][2] .AND. x[3] == aVetDlg[nCntDoc][3]   } )
								lDelet := .T.
							EndIf
							
							Exit
						 EndIf
						DJJ->(DbSkip())
					EndDo
					
				Else
					
					// Se a linha estiver deletada
					If oMdlGrid:IsDeleted()
						lGrvDJJ := .F.
					Else
						lGrvDJJ := .T.
					EndIf
				EndIf
				
				// Grava o Item
				If lGrvDJJ
					RecLock("DJJ",.T.)
					DJJ->DJJ_FILIAL := FwxFilial("DJJ")
					DJJ->DJJ_FILORI := oMdlGrid:GetValue("DJF_FILORI")
					DJJ->DJJ_VIAGEM := oMdlGrid:GetValue("DJF_VIAGEM")
					DJJ->DJJ_CLIDEV := oMdlGrid:GetValue("DJF_CLIDEV")
					DJJ->DJJ_LOJDEV := oMdlGrid:GetValue("DJF_LOJDEV")
					DJJ->DJJ_CLIENT := oMdlGrid:GetValue("DJF_CLIENT")
					DJJ->DJJ_LOJA   := oMdlGrid:GetValue("DJF_LOJA")
					DJJ->DJJ_SEQEND := oMdlGrid:GetValue("DJF_SEQEND")
					DJJ->DJJ_TABELA := aVetDlg[nCntDoc][1]
					DJJ->DJJ_INDICE := aVetDlg[nCntDoc][2]
					DJJ->DJJ_CHAVE  := aVetDlg[nCntDoc][3]
					DJJ->(MsUnlock())	
				EndIf
				
				// Exclui o item
				If lDelet
					RecLock("DJJ",.F.)
					DJJ->(DbDelete())
					DJJ->(MsUnlock())	
				EndIf
								
			Next nCntDoc
		EndIf
		
	Next nCount2
	
	If !Empty(cRoteiro) .AND. !Empty(cRota) 
		// Executa a Rotina Automatica
		If nOperat == MODEL_OPERATION_INSERT .AND. Len(aCab) > 0 .AND. Len(aItens) > 0
			aRetAut := AF11xAut(aCab,aItens,nOperat,lVisual)
		EndIf
		
		// Verifica erro em Rotina Automatica
		If Len(aRetAut) > 0
			If !aRetAut[1]
				lRet := .F.
				Exit
			EndIf
		EndIf
		
		If lRet
			
			dbSelectArea("DIQ")
			DIQ->( dbSetOrder(2) )
			
			// Limpa as variaveis
			aCab    := {}
			aItens  := {}
			aLinha  := {}
			aLinDIQ := {}
			
			If !DIQ->( dbSeek( FwxFilial("DIQ") + cRota + cRoteiro ) )
								
				If nCount == 1 .AND. Len(aMDFe) > 1
					
					For nCount3 := 1 To Len(aMDFe)
						aValDIQ := {}
						AADD(aValDIQ,{"DIQ_ROTA"   , cRota           })
						AADD(aValDIQ,{"DIQ_SEQUEN" , STRZERO( nCount3 , TamSx3('DIQ_SEQUEN')[1])   })
						AADD(aValDIQ,{"DIQ_EST"    , aMDFe[nCount3]  })
						AADD(aValDIQ,{"DIQ_ROTEIR" , cRoteiro        })
						AADD(aLinDIQ,aValDIQ)
					Next nCount3
				
				EndIf
			EndIf	
			
			//Preenche o Cabeçalho
			AADD(aCab,{"DA8_COD",cRota})
			
			// Preenche os Itens
			AADD(aLinha,{"DJH_ROTA"  , cRota    })
			AADD(aLinha,{"DJH_ROTEIR", cRoteiro })
			AADD(aLinha,{"DJG_DESCRI", cDescri  })
			AADD(aLinha,{"DIQ", aLinDIQ})
			AADD(aItens,aClone(aLinha))	
			
			If Len(aCab) > 0 .AND. Len(aItens) > 0
				// Executa a inclusão do Vinculo Rota x Roteiro e do percurso do MDF-e
			  	aRetAut :=  RelRotRtei(aCab,aItens,MODEL_OPERATION_UPDATE,lVisual)
				
				// Verifica erro em Rotina Automatica
				If Len(aRetAut) > 0
					If !aRetAut[1]
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
Next nCount 

FWRestRows( aSaveLine )

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} RelRotRtei()
Rotina automatica de Cadastro de Distancia entre Clientes

Uso: TMSAF12

@sample
// RelRotRtei(aCab,aItens,nOperat,lVisual)

@author Paulo Henrique Corrêa Cardoso.
@since 13/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function RelRotRtei(aCab,aItens,nOperat,lVisual)

Local lRet        := .T.    // Recebe o Retorno Logico
Local aAreas      := {}     // Recebe as Areas Ativas
Local aErro       := {}     // Recebe o Array de Erros do MVC 
Local aErroAuto   := {}     // Recebe o Array de Erros do GetAutoGRLog()
Local cRetErro    := ""     // Recebe o Erro de Retorno
Local oModel      := NIL    // Recebe o modelo
Local oMdlGrdDJH  := NIL    // Recebe o Objeto do Modelo do Grid DJH	
Local oStrucDJH   := NIL    // Recebe a Estrutura do Modelo do Grid DJH
Local aGrdDJH     := {}     // Recebe os Campos do Grid DJH
Local nCount      := 0      // Recebe o Contador
Local nCount2     := 0      // Recebe o Contador 2
Local nItErro     := 0      // Recebe a linha de erro do grid
Local nPosRotDJH  := 0      // Recebe a Posição do campo de Rota do Grid
Local nPosRtrDJH  := 0      // Recebe a Posição do campo de Roteiro do Grid
Local nLenGrdDJH  := 0      // Recebe a linha do grid que foi adicionada
Local nLenGrdDIQ  := 0      // Recebe a linha do grid DIQ que foi adicionada
Local nPosRota    := 0      // Recebe a posição do campo Rota no cabeçalho
Local oMdlGrdDIQ  := NIL    // Recebe o Objeto do Modelo do Grid DJH	
Local oStrucDIQ   := NIL    // Recebe a Estrutura do Modelo do Grid DJH
Local aGrdDIQ     := {}     // Recebe os Campos do Grid DJH
Local nCount3     := 0      // Recebe o Contador 3
Local aDIQ        := {}     // Recebe os itens da DIQ referente a cada roteiro 	
Local nCount4     := 0		// Recebe o Contador 4

If Type('n') == 'U'
	Private n := 0
EndIf

Default aCab     := {}                      // Recebe o Conteudo dos campos do cabeçalho
Default aItens   := {}                      // Recebe o Conteudo dos campos
Default nOperat  := MODEL_OPERATION_INSERT  // Recebe a Operação
Default lVisual  := .T.                     // Recebe se deve exibir componentes de tela

aAreas	:= { DJH->(GetArea()), GetArea() }

If Len(aCab) > 0 .AND. Len(aItens) > 0
	nPosRota := aScan(aCab,{|x| AllTrim(x[1]) == "DA8_COD"})
	
	If nOperat == MODEL_OPERATION_UPDATE
		dbSelectArea("DA8")
		DA8->( dbSetOrder(1) )
		If !DA8->( dbSeek (FwxFilial("DA8") + aCab[nPosRota][2]   ) )
		
			AutoGrLog(STR0032)  //"Resgistro não foi encontrado."
			cRetErro := STR0032 //"Resgistro não foi encontrado."
			lRet := .F.
		EndIf
		
		If lRet 
			// Inicializa o modelo
			oModel := FwLoadModel("OMSA100") 
			oModel:SetOperation(nOperat)
			oModel:Activate()
						
			oMdlGrdDJH := oModel:GetModel( "MdGridDJHF6" )
			oStrucDJH  := oMdlGrdDJH:GetStruct()
			aGrdDJH    := oStrucDJH:GetFields()
			
			oMdlGrdDIQ := oModel:GetModel( "MdGridDIQG2" )
			oStrucDIQ  := oMdlGrdDIQ:GetStruct()
			aGrdDIQ    := oStrucDIQ:GetFields()
			
			// Grid
			For nCount := 1 To Len( aItens )	
				
				nPosRotDJH := aScan(aItens[nCount],{|x| AllTrim(x[1]) == "DJH_ROTA"})
				nPosRtrDJH := aScan(aItens[nCount],{|x| AllTrim(x[1]) == "DJH_ROTEIR"})
				
				DJH->( DbSetOrder(1) )
				If DJH->( MsSeek(xFilial("DJH") + aItens[nCount][nPosRotDJH][2] + aItens[nCount][nPosRtrDJH][2] ) )
					// Posiciona na etiqueta
					oMdlGrdDJH:SeekLine( {{ "DJH_ROTA", aItens[nCount][nPosRotDJH][2]},{ "DJH_ROTEIR", aItens[nCount][nPosRtrDJH][2]}} )
				Else
					// Adiciona uma nova linha no Grid DDR
					nLenGrdDJH := oMdlGrdDJH:AddLine()
					
					// Posiciona na linha
					oMdlGrdDJH:GoLine(nLenGrdDJH)
				EndIf
				
				// Insere os valores do Grid DJH
				For nCount2 := 1 To Len( aItens[nCount] )
					If ( aScan( aGrdDJH, { |x| AllTrim( x[3] ) == AllTrim( aItens[nCount][nCount2][1] ) } ) ) > 0
						If !Empty( aItens[nCount][nCount2][2])
							If !(oModel:LoadValue( "MdGridDJHF6" , aItens[nCount][nCount2][1], aItens[nCount][nCount2][2]))
								lRet := .F.
								nItErro := nCount
								Exit
							EndIf
						EndIf
					ElseIf AllTrim( aItens[nCount][nCount2][1]) == "DIQ"
						aDIQ := {}
						aDIQ := aClone(aItens[nCount][nCount2][2])
						
						oMdlGrdDIQ:GoLine(1)
						// Itens da DIQ
						For nCount3 := 1 To Len( aDIQ )
							
							If !(nCount3 == 1 .AND. Empty(oMdlGrdDIQ:GetValue("DIQ_EST")))
								// Adiciona uma nova linha no Grid DIQ
								nLenGrdDIQ := oMdlGrdDIQ:AddLine()
							EndIf
							
							// Posiciona na linha
							oMdlGrdDIQ:GoLine(nLenGrdDIQ)
							
							For nCount4 := 1 To Len( aDIQ[nCount3] )
								If ( aScan( aGrdDIQ, { |x| AllTrim( x[3] ) == AllTrim( aDIQ[nCount3][nCount4][1] ) } ) ) > 0
									If !Empty( aDIQ[nCount3][nCount4][2])
										If !(oModel:LoadValue( "MdGridDIQG2" , aDIQ[nCount3][nCount4][1], aDIQ[nCount3][nCount4][2]))
											lRet := .F.
											nItErro := nCount
											Exit
										EndIf
									EndIf
								EndIf
							Next nCount4
							If !lRet
								Exit
							EndIf
						Next nCount3
						
						If !lRet
							Exit
						EndIf
						
					EndIf
				Next nCount2
				If !lRet
					Exit
				EndIf
			Next nCount
			
		
			// Valida e grava as informações.
			If (lRet := oModel:VldData())
				lRet := oModel:CommitData()
			EndIf
			
			If !lRet		
				// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
				aErro := oModel:GetErrorMessage()
		        
				If Len(aErro) > 0 
					AutoGrLog(STR0033 + ' [' + AllToChar(aErro[1] ) + ']' ) //"Id do formulário de origem:"
					AutoGrLog(STR0034 + ' [' + AllToChar(aErro[2] ) + ']' ) //"Id do campo de origem: "
					AutoGrLog(STR0035 + ' [' + AllToChar(aErro[3] ) + ']' ) //"Id do formulário de erro: " 
					AutoGrLog(STR0036 + ' [' + AllToChar(aErro[4] ) + ']' ) //"Id do campo de erro: "
					AutoGrLog(STR0037 + ' [' + AllToChar(aErro[5] ) + ']' ) //"Id do erro: " 
					AutoGrLog(STR0038 + ' [' + AllToChar(aErro[6] ) + ']' ) //"Mensagem do erro: "
					AutoGrLog(STR0039 + ' [' + AllToChar(aErro[7] ) + ']' ) //"Mensagem da solução: "
					AutoGrLog(STR0040 + ' [' + AllToChar(aErro[8] ) + ']' ) //"Valor atribuído: " 
					AutoGrLog(STR0041 + ' [' + AllToChar(aErro[9] ) + ']' ) //"Valor anterior: "
					
					//Se o Erro ocorrer nos itens
					If nItErro > 0
						AutoGrLog(STR0042 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) //"Erro no Item: "	
					EndIf
					
				EndIf	
				
				// Monta o Erro de Retorno	
				aErroAuto := GetAutoGRLog()	 
				
				For nCount := 1 To Len(aErroAuto)
					TMSLogMsg("Error",aErroAuto[nCount])
					cRetErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + (" ")
				Next
				cRetErro := EncodeUTF8(cRetErro)	
					
			EndIf
				
			oModel:DeActivate()
			
		EndIf
								
	EndIf
Else
	AutoGrLog(STR0043) //"Conteudo do registro DA8 e/ou DJH não foi preenchido"
	cRetErro := STR0043 //"Conteudo do registro DA8 e/ou DJH não foi preenchido"
	lRet := .F.
EndIf

// Exibe o Erro 	
If lVisual .AND. !lRet
	MostraErro()
EndIf

AEval( aAreas, { |x| RestArea(x) } )

Return({lRet,cRetErro})

/*/-----------------------------------------------------------
{Protheus.doc} Af12QbrMtD
Realiza conversão de Meta Dados em array

Uso: TMSAF12

@sample
//Af12QbrMtD(cString,cCarLin,cCarCol)

@author Paulo Henrique Corrêa Cardoso
@since 23/09/2016
@version 1.0
-----------------------------------------------------------/*/
Function Af12QbrMtD(cString,cCarLin,cCarCol)
Local aVetLn      := {}     // Recebe o vetor de linhas
Local aVetCol     := {}     // Recebe o vetor de colunas
Local nCount      := 0      // Recebe o contador 

Default cString   := ""     // Recebe a String original
Default cCarLin   := "#"    // Recebe o caracter de quebra de linha
Default cCarCoL   := "|"    // Recebe o caracter de quebra de coluna 

// Remove o ultimo Caracter de linha
cString := SubStr( cString, 1 ,Rat(cCarLin,cString) -1  ) 

cString := RTrim(cString)

If 	!Empty(cString)		
	//-- Proteção De Erro Para Função StrToKarr - Caracter de linha
	cString := StrTran(cString,cCarLin + cCarLin, cCarLin + " " + cCarLin)
					
	//-- Proteção De Erro Para Função StrToKarr - Caracter de coluna
	cString := StrTran(cString,cCarCol + cCarCol, cCarCol + " " + cCarCol)

	//-- Converte Cada caracter de linha encontrado no campo tipo 'Memo' em uma linha
	aVetLn := StrToKarr(cString,cCarLin)

	//-- Converte Cada caracter de coluna em um campo do vetor
	aVetCol := {}
	For nCount := 1 To Len(aVetLn)

		aAdd(aVetCol,StrToKarr(aVetLn[nCount],cCarCol))

	Next nCount
EndIf 

Return aVetCol


/*/-----------------------------------------------------------
{Protheus.doc} AF12DelDoc
Deleta as linhas dos pontos que tiveram todos os docs excluidos na viagem

Uso: TMSAF12

@sample
//AF12DelDoc(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 23/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function AF12DelDoc(oView)

Local oModel 	   := Nil         	// Recebe o Model 
Local nFolder    := 0              // Recebe o numero da folder
Local nCntLinha  := 0              // Recebe o contador de linhas
Local oModelGrid := NIL            // Recebe o modelo do grid
Local cViewId    := ""             // Recebe o Id da View
Local aDelItens  := {}             // Recebe os Docs deletados 
Local nCntDocs   := 0              // Recebe o contador de documentos
Local lDel       := .F.				// Recebe se a linha foi excluida

Default oView   := FwModelActive() // Recebe o Modelo Ativo

oModel := oView:GetModel()

aDelItens := aDelDocs

If Len(aDelItens) > 0
	// Varre as pastas
	For nFolder := 1 To nQtdFolder
		
		// Recebe o modelo do grid
		oModelGrid := oModel:GetModel("MdGridDJF"+AllTrim(Str(nFolder)))
			
		// Recebe o Id da View do Grid
		cViewId := "VwGridDJF"+AllTrim(Str(nFolder))
		
		// Varre as linhas 
		For nCntLinha := 1 To oModelGrid:Length()
			
			oModelGrid:GoLine(nCntLinha)
			
			If !oModelGrid:IsDeleted()
				aDocsDJF := Af12QbrMtD(oModelGrid:GetValue("DJF_DOCS"),"#","|") 
				
				nDel := 0
				
				For nCntDocs := 1 To Len(aDocsDJF)
					If Ascan(aDelItens, {|x| x[1] == aDocsDJF[nCntDocs][1] .AND. x[2] == aDocsDJF[nCntDocs][2] .AND. x[3] == aDocsDJF[nCntDocs][3]  }) > 0
						nDel += 1
					EndIf
				Next nCntDocs
			
				// Apaga alinha 
				If nDel == Len(aDocsDJF) .AND. nDel > 0
					oModelGrid:LoadValue("DJF_EXCVIA",.T.)
					lDel := oModelGrid:DeleteLine()
				EndIf
				
			EndIf
			
		Next nCntLinha
		
		// Atualiza a tela
		oModelGrid:GoLine(1)
		oView:Refresh(cViewId)
		
	Next nFolder
EndIf	

Return 


/*/-----------------------------------------------------------
{Protheus.doc} AF12LdMDFe
Carrega as linhas do Percurso do MDF-e

Uso: TMSAF12

@sample
//AF12LdMDFe(oView)

@author Paulo Henrique Corrêa Cardoso.
@since 28/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function AF12LdMDFe(oView)
Local oModel       := NIL              // Recebe o modelo 
Local oMdlGrdDJF   := NIL              // Recebe o modelo do grid DJF
Local oMdlGrdDJK   := NIL              // Recebe o modelo do grid DJK
Local nCount       := 0                // Recebe o contador

Default oView      := FwViewActive()   // Recebe a view ativa

oModel := oView:GetModel()

// Recebe os Grids
oMdlGrdDJF := oModel:GetModel("MdGridDJF1")
oMdlGrdDJK := oModel:GetModel("MdGridDJK")

dbSelectArea("DJK")
DJK->(dbSetOrder(1))

// Carrega os itens já gravados na DJK
If DJK->( dbSeek(FwxFilial("DJK")+ cFilVge + cViagem ) )
	While  DJK->(!EOF()) .AND. DJK->DJK_FILIAL == FwxFilial("DJK") .AND. DJK->DJK_FILORI == cFilVge .AND. DJK->DJK_VIAGEM == cViagem
		F12EdtMDFe(oModel,oView,DJK->DJK_ORIGEM,DJK->DJK_EST,DJK->DJK_IDDJF)
		 DJK->(dbSkip())
	EndDo
EndIf

// Percorre o grid de Pontos do Roteiro
For nCount := 1 To oMdlGrdDJF:Length()
	
	oMdlGrdDJF:GoLine(nCount)
		
	If !oMdlGrdDJF:IsDeleted()
		
		// Cria a chave randomica da linha
		If Empty(oMdlGrdDJF:GetValue("DJF_IDLIN"))
			oMdlGrdDJF:LoadValue("DJF_IDLIN",StrZero(Randomize(1,999999999),9,0))
		EndIf
		
		// Adiciona a linha no grid DJF
		If !oMdlGrdDJK:SeekLine( { {"DJK_IDDJF", oMdlGrdDJF:GetValue("DJF_IDLIN") } } )	
			F12EdtMDFe(oModel,oView,"2",oMdlGrdDJF:GetValue("DJF_EST"),oMdlGrdDJF:GetValue("DJF_IDLIN"))
		EndIf
	EndIf
	
Next nCount

// Atualiza a tela
oMdlGrdDJF:GoLine(1)
oMdlGrdDJK:GoLine(1)

oView:Refresh("VwGridDJK")

Return 

/*/-----------------------------------------------------------
{Protheus.doc} AF12LdMDFe
Carrega as linhas do Percurso do MDF-e

Uso: TMSAF12

@sample
//AF12LdMDFe(oView)

@author Paulo Henrique Corrêa Cardoso.
@since 28/09/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function F12EdtMDFe(oModel,oView,cOrigem,cUf,cIdDJF,lPosIni)
Local oMdlGrdDJK   := NIL              // Recebe o Grid de Estados de Passagem
Local cLegenda     := ""               // Recebe a legenda
Local nOper        := 0				   // Recebe o Operation

Default oModel     := FwModelActive()  // Recebe o modelo
Default oView      := FwViewActive()   // Recebe a view 
Default cOrigem    := "1"              // Recebe a origem da linha
Default cUf        := ""               // Recebe o estado
Default cIdDJF     := ""               // Recebe o id da linha da DJF
Default lPosIni    := .F.              // Recebe se deve posicionar na linha inicial

oMdlGrdDJK := oModel:GetModel("MdGridDJK")
nTamDJK    := oMdlGrdDJK:Length()

// Identifica qual linha devera ser utilizada ou insere uma nova linha
If  oMdlGrdDJK:SeekLine( { {"DJK_IDDJF", cIdDJF } } )
	
	nTamDJK := oMdlGrdDJK:GetLine()
	
Else
	oMdlGrdDJK:Goline(nTamDJK)
	If oMdlGrdDJK:IsDeleted() .OR. !Empty(oMdlGrdDJK:GetValue("DJK_EST"))
		
		If (nOper := oModel:nOperation) == 1
			oModel:nOperation := 4
		EndIf

		oMdlGrdDJK:SetNoInsertLine(.F.)
		nTamDJK := oMdlGrdDJK:AddLine()
		oMdlGrdDJK:SetNoInsertLine(.T.)
		
		If nOper == 1
			oModel:nOperation := nOper
		EndIf

	EndIf
EndIf

// define a legenda
If cOrigem =="1"
	cLegenda := "BR_AMARELO"
ElseIf  cOrigem =="2"
	cLegenda := "BR_VERDE"
EndIf

// preenche os campos
oMdlGrdDJK:Goline(nTamDJK)	
oMdlGrdDJK:LoadValue("DJK_FILORI",cFilVge)
oMdlGrdDJK:LoadValue("DJK_VIAGEM",cViagem)
oMdlGrdDJK:LoadValue("DJK_LEGORI",cLegenda)
oMdlGrdDJK:LoadValue("DJK_ORIGEM",cOrigem)
oMdlGrdDJK:LoadValue("DJK_EST",cUf)
oMdlGrdDJK:LoadValue("DJK_IDDJF",cIdDJF)
oMdlGrdDJK:LoadValue("DJK_BTTOP","PMSSETAUP")
oMdlGrdDJK:LoadValue("DJK_BTLOW","PMSSETADOWN")

// Posiciona na primeira linha
If lPosIni
	oMdlGrdDJK:Goline(1)
EndIf

// Atualiza a tela
oView:Refresh("VwGridDJK")

Return 


/*/-----------------------------------------------------------
{Protheus.doc} TMSDelLnGrd
Exclui a linha fisicamente do grid
Uso: TMSF12

@sample
//F12DlLnDJK(oView,cIdView,nLine)

@author Paulo Henrique Corrêa Cardoso.
@since 30/09/2016
@version 1.0
-----------------------------------------------------------/*/
Function F12DlLnDJK(oView)
Local oModel         := NIL      // Recebe o Modelo 
Local oModelGrid     := NIL      // Recebe o Modelo do Grid
Local nCount         := 0        // Recebe o contador
Local nTamGrid       := 0        // Recebe o Tamanho do Grid

Default oView        := FwViewActive()

oModel := oView:GetModel()
oModelGrid := oModel:GetModel("MdGridDJK")

nTamGrid :=  oModelGrid:Length()

For nCount :=1 To nTamGrid
	If nCount <= nTamGrid
		oModelGrid:GoLine(nCount)
		If oModelGrid:IsDeleted() .AND. Empty(oModelGrid:GetValue("DJK_IDDJF",nCount))
			
			// Deleta a linha fisicamente do grid
			TMSDelLnGrd(oView,oModelGrid,nCount,"VwGridDJK")
			nTamGrid :=  nTamGrid -1 
			nCount  := nCount -1
		EndIf
	EndIf
Next nCount

oModelGrid:GoLine(1)
	
Return

/*/-----------------------------------------------------------
{Protheus.doc} F12VldDTW
Valida a Reordenação com as linhas da DTW
Uso: TMSF12

@sample
//F12VldDTW(oMdlGrd,nline,cValor)

@author Paulo Henrique Corrêa Cardoso.
@since 13/10/2016
@version 1.0
-----------------------------------------------------------/*/
Function F12VldDTW(oMdlGrd,nline,cValor)
Local lRet       := .T.              // Recebe o retorno

Default oMdlGrd  := NIL              // Recebe o modelo do grid
Default nline    := 0                // Recebe a linha atual
Default cValor   := ""               // Recebe o valor da linha de destino


If !Empty(oMdlGrd)
	
	If !oMdlGrd:IsDeleted() .AND. !Empty(oMdlGrd:GetValue("DJF_DATDTW"))
		lRet  := .F.
		Aviso( STR0044, STR0045 , {STR0047} ) // "Reordenar"###"O registro selecionado não poderá ser reordenado poís já foi realizado apontamento de operação para o mesmo.###"OK"
	Else
		If oMdlGrd:SeekLine({{ "DJF_SEQUEN", cValor }})
			If  !Empty(oMdlGrd:GetValue("DJF_DATDTW"))
				lRet  := .F.
				Aviso(STR0044,STR0046 , {STR0047} ) //"Reordenar" ###"O registro de destino não poderá ser reordenado poís já foi realizado apontamento de operação para o mesmo."###"OK"
			EndIf
		EndIf
		oMdlGrd:GoLine(nLine)
	EndIf

EndIf

Return lRet


