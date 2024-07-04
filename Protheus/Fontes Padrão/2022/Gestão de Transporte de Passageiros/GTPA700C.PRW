#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fwmvcdef.ch'
#include 'totvs.ch'
#include 'gtpa700c.ch'



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA700C()

Tela de Lançamento diário de Taxas Avulsas - Financeiro
 
@sample	GTPA700C()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA700C(nOperation)
Local oMdl700B	:= FwLoadModel('GTPA700B')

If FwIsInCallStack("G700LoadMov")

	oMdl700B:SetOperation(MODEL_OPERATION_UPDATE)
	oMdl700B:Activate()
	oMdl700B:CommitData()
	oMdl700B:Destroy()
	
Else
	FWExecView(STR0003, 'VIEWDEF.GTPA700C', nOperation, , { || .T. } )  //'Lançamentos de Taxas Avulsas' 
Endif

Return 

Static Function ViewDef()

Local oStruCab	    := FWFormViewStruct():New()
Local oStruGrd	    := FWFormViewStruct():New()
Local oModel			:= FWLoadModel("GTPA700B")
Local oStruG6Y      := FWFormStruct(2,"G6Y")
Local oStruTot1     := FWCalcStruct( oModel:GetModel('700TOTAL1') )
Local oStruTot2     := FWCalcStruct( oModel:GetModel('700TOTAL2') )

	G700CStruct(oStruCab,oStruGrd,oStruG6Y,"V")
	
	oView := FWFormView():New()

	oView:SetModel(oModel)	
	
	oView:SetDescription(STR0016) // "Taxas Avulsas"

	oView:AddField("VIEW_CAB",oStruCab,"CABESC")
	oView:AddGrid("V_FICHA"  ,oStruGrd,"GRID1")
	oView:AddGrid("V_LANCAM" ,oStruG6Y,"GRID2")
	oView:AddField("V_TOTAL1" ,oStruTot1,'700TOTAL1')
	oView:AddField("V_TOTAL2" ,oStruTot2,'700TOTAL2')

	oView:CreateHorizontalBox("CABECALHO" , 15) // Cabeçalho
	oView:CreateHorizontalBox("FCHDEREME" , 15) // Ficha de Remessa
	oView:CreateHorizontalBox("LANCAMENT" , 55) // Lançamentos Diários
	oView:CreateHorizontalBox("TOTALIZA"  , 15) // Totalizadores

	oView:CreateVerticalBox("TOTAL1",50,"TOTALIZA")
	oView:CreateVerticalBox("TOTAL2",50,"TOTALIZA")
	
	oView:EnableTitleView("V_LANCAM", STR0016) // "Taxas Avulsas"
	oView:EnableTitleView("V_TOTAL1", STR0017) // "Total Ficha de Remessa"
	oView:EnableTitleView("V_TOTAL2", STR0018) // "Total de Taxas Avulsas"
	
	oView:SetOwnerView( "VIEW_CAB", "CABECALHO")
	oView:SetOwnerView( "V_FICHA", "FCHDEREME")
	oView:SetOwnerView( "V_LANCAM", "LANCAMENT")
	oView:SetOwnerView( "V_TOTAL1", "TOTAL1")
	oView:SetOwnerView( "V_TOTAL2", "TOTAL2")
	
	oView:AddIncrementalField('V_LANCAM','G6Y_ITEM')
	
	oView:SetNoDeleteLine('V_FICHA')
	
Return(oView)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G708BStruct(oStruCab,oStruGrd,cTipo)

Define as estruturas da Tela em MVC - Model e View
 
@sample	GTPA700C()
 
@return	
 
@author	SIGAGTP | Flavio Martins
@since		31/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function G700CStruct(oStruCab,oStruGrd,oStruG6Y,cTipo)
	
Local cFieldsIn := ""
Local aFldStr   := {}
Local aOrdem    := {}
Local nI        := 0


	If cTipo == "M"
	
		If ValType( oStruCab ) == "O"
	
		oStruCab:AddTable("   ",{" "}," ")
		oStruCab:AddField(STR0007,;									// 	[01]  C   Titulo do campo // "Filial"
					 		STR0007,;									// 	[02]  C   ToolTip do campo // "Filial"
					 		"FILIAL",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("G6T_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	    oStruCab:AddField(STR0008,;									// 	[01]  C   Titulo do campo // "Caixa"
					 		STR0008,;									// 	[02]  C   ToolTip do campo // "Caixa"
					 		"CAIXA",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual

		oStruCab:AddField(STR0009,;								// 	[01]  C   Titulo do campo // "Agência"
				 		    STR0010,;					// 	[02]  C   ToolTip do campo // "Código da Agência"
					 		"AGENCIA",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruCab:AddField(STR0009,;							// 	[01]  C   Titulo do campo // "Descrição"
					 		 STR0009,;				// 	[02]  C   ToolTip do campo // "Descrição da Agência"
					 		"DESCRIAGEN",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
							 TamSx3("GI6_DESCRI")[1] , ;			// 	[05]  N   Tamanho do campo						
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		 				 		
		EndIf
		
		If ValType( oStruGrd ) == "O"
			oStruGrd:AddTable("   ",{" "}," ")
			oStruGrd:AddField(STR0007,;									// 	[01]  C   Titulo do campo // "Filial"
						 		STR0007,;									// 	[02]  C   ToolTip do campo // "Filial"
						 		"FILIAL",;							// 	[03]  C   Id do Field
						 		"C",;									// 	[04]  C   Tipo do campo
						 		TAMSX3("G6T_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual
						 		
			oStruGrd:AddField(STR0008,;									// 	[01]  C   Titulo do campo // 	"Caixa"
					 		STR0008,;									// 	[02]  C   ToolTip do campo // 	"Caixa"
					 		"CODCX",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			oStruGrd:AddField(STR0009,;									// 	[01]  C   Titulo do campo // 	"Agencia"
					 		STR0009,;									// 	[02]  C   ToolTip do campo // 	"Agencia"
					 		"CODAGE",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		6,;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
				
		    oStruGrd:AddField(STR0004,;					// 	[01]  C   Titulo do campo // 	"Ficha de Remessa"
						 		STR0004,;					// 	[02]  C   ToolTip do campo // 	"Ficha de Remessa"
						 		"FICHA",;								// 	[03]  C   Id do Field
						 		"C",;									// 	[04]  C   Tipo do campo
						 		10,;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual
	
			oStruGrd:AddField(STR0013 ,;								// 	[01]  C   Titulo do campo // "Data"
					 		    STR0014,;					// 	[02]  C   ToolTip do campo // "Data Inicial"
						 		"DTINI",;								// 	[03]  C   Id do Field
						 		"D",;									// 	[04]  C   Tipo do campo
						 		8,;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual
			oStruGrd:AddField(STR0013,;								// 	[01]  C   Titulo do campo // "Data"
					 		    STR0015,;					// 	[02]  C   ToolTip do campo // "Data Final"
						 		"DTFIN",;								// 	[03]  C   Id do Field
						 		"D",;									// 	[04]  C   Tipo do campo
						 		8,;										// 	[05]  N   Tamanho do campo
						 		0,;										// 	[06]  N   Decimal do campo
						 		Nil,;									// 	[07]  B   Code-block de validação do campo
						 		Nil,;									// 	[08]  B   Code-block de validação When do campo
						 		Nil,;									//	[09]  A   Lista de valores permitido do campo
						 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
						 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
						 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
						 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
						 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
						 		
		EndIf
		
	Else
		If ValType( oStruCab ) == "O"
	
			oStruCab:AddField(	"FILIAL",;				// [01]  C   Nome do Campo
		                        "01",;						// [02]  C   Ordem
		                        STR0007,;						// [03]  C   Titulo do campo // "Filial"
		                        STR0007,;						// [04]  C   Descricao do campo // "Filial"
		                        {STR0007},;					// [05]  A   Array com Help // "Selecionar" // "Filial"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
			
			oStruCab:AddField(	"CAIXA",;				// [01]  C   Nome do Campo
		                        "02",;						// [02]  C   Ordem
		                        STR0008,;						// [03]  C   Titulo do campo // "Caixa"
		                        STR0008,;						// [04]  C   Descricao do campo // "Caixa"
		                        {STR0008},;					// [05]  A   Array com Help // "Selecionar" // "Caixa"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
		
		    oStruCab:AddField(	"AGENCIA",;				// [01]  C   Nome do Campo
		                        "03",;						// [02]  C   Ordem
		                        STR0009,;						// [03]  C   Titulo do campo // "Agência"
		                        STR0010,;						// [04]  C   Descricao do campo // "Código da Agência"
		                        {STR0010},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
					
		    oStruCab:AddField(	"DESCRIAGEN",;				// [01]  C   Nome do Campo
		                        "04",;						// [02]  C   Ordem
		                        STR0011,;						// [03]  C   Titulo do campo // "Descrição"
		                        STR0012,;						// [04]  C   Descricao do campo // "Descrição da Agência"
		                        {STR0012},;					// [05]  A   Array com Help // "Selecionar" // "Descrição da Agência"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "",;						// [09]  C   Consulta F3
		                        .F.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
						 		
		    cFieldsIn := "CAIXA|AGENCIA|DESCRIAGEN"
			
				
			aFldStr := aClone(oStruCab:GetFields())
			
			For nI := 1 to Len(aFldStr)
			
				If ( !(aFldStr[nI,1] $ cFieldsIn) )
					oStruCab:RemoveField(aFldStr[nI,1])
			    EndIf
			
			Next nI
			                    
		EndIf
		
		If ValType( oStruGrd ) == "O"
			
			oStruGrd:AddField(	"FILIAL",;				// [01]  C   Nome do Campo
	                        "01",;						// [02]  C   Ordem
	                        STR0007,;						// [03]  C   Titulo do campo // "Filial"
	                        STR0007,;						// [04]  C   Descricao do campo // "Filial"
	                        {STR0007},;					// [05]  A   Array com Help // "Selecionar" // "Filial"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	        
	        oStruGrd:AddField(	"CODCX",;				// [01]  C   Nome do Campo
	                        "02",;						// [02]  C   Ordem
	                        STR0008,;						// [03]  C   Titulo do campo // "Caixa"
	                        STR0008,;						// [04]  C   Descricao do campo  // "Caixa" 
	                        {STR0008},;					// [05]  A   Array com Help // "Selecionar"  // "Caixa"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	         oStruGrd:AddField(	"CODAGE",;				// [01]  C   Nome do Campo
	                        "03",;						// [02]  C   Ordem
	                        STR0009,;						// [03]  C   Titulo do campo // "Agencia"
	                        STR0010,;						// [04]  C   Descricao do campo // "Código da Agencia"
	                        {STR0010},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agencia"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo         
	
					 		
			oStruGrd:AddField(	"FICHA",;				// [01]  C   Nome do Campo
	                        "04",;						// [02]  C   Ordem
	                        STR0004,;						// [03]  C   Titulo do campo // "Ficha de Remessa"
	                        STR0004,;						// [04]  C   Descricao do campo // "Ficha de Remessa"
	                        {STR0004},;					// [05]  A   Array com Help // "Selecionar" // "Ficha de Remessa"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo
	                        
	                        
	            
	                        
	        oStruGrd:AddField(	"DTINI",;				// [01]  C   Nome do Campo
	                        "05",;						// [02]  C   Ordem
	                        STR0014,;						// [03]  C   Titulo do campo // "Data Incial"
	                        STR0014,;						// [04]  C   Descricao do campo  // "Data Incial"
	                        {STR0014},;					// [05]  A   Array com Help // "Selecionar"  // "Data Incial"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo	
			
			oStruGrd:AddField(	"DTFIN",;				// [01]  C   Nome do Campo
	                        "06",;						// [02]  C   Ordem
	                        STR0015,;						// [03]  C   Titulo do campo // "Data Final"
	                        STR0015,;						// [04]  C   Descricao do campo // "Data Final"
	                        {STR0015},;					// [05]  A   Array com Help // "Selecionar" // "Data Final"
	                        "GET",;					// [06]  C   Tipo do campo
	                        "",;						// [07]  C   Picture
	                        NIL,;						// [08]  B   Bloco de Picture Var
	                        "",;						// [09]  C   Consulta F3
	                        .F.,;						// [10]  L   Indica se o campo é alteravel
	                        NIL,;						// [11]  C   Pasta do campo
	                        "",;						// [12]  C   Agrupamento do campo
	                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
	                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
	                        NIL,;						// [15]  C   Inicializador de Browse
	                        .T.,;						// [16]  L   Indica se o campo é virtual
	                        NIL,;						// [17]  C   Picture Variavel
	                        .F.)						// [18]  L   Indica pulo de linha após o campo	
			
	        	cFieldsIn := "FICHA|DTINI|DTFIN|"
	
		
	        	aFldStr := aClone(oStruGrd:GetFields())
	
			    For nI := 1 to Len(aFldStr)
			
			        If ( !(aFldStr[nI,1] $ cFieldsIn) )
			            oStruGrd:RemoveField(aFldStr[nI,1])
			        EndIf
			
			    Next nI
			    
		EndIf
		
		If ValType( oStruG6Y ) == "O"
				
				//Ajusta quais os campos que deverão aparecer na tela - Grid GYPDETAIL

			cFieldsIn := "G6Y_ITEM|G6Y_CODG57|G6Y_DATA|G6Y_VALOR|G6Y_MOTLAN|G6Y_LOCORI|G6Y_NLOCOR"
			
			aFldStr := aClone(oStruG6Y:GetFields())
			
			For nI := 1 to Len(aFldStr)
			
		        If ( !(aFldStr[nI,1] $ cFieldsIn) )
		            oStruG6Y:RemoveField(aFldStr[nI,1])
		        EndIf
		        
		        If ( (aFldStr[nI,1] $ cFieldsIn) )
		            oStruG6Y:SetProperty(aFldStr[nI,1], MVC_VIEW_CANCHANGE,  .F. )  
		        EndIf
			
			Next nI
			
          oStruG6Y:SetProperty('G6Y_VALOR', MVC_VIEW_CANCHANGE,  .T. )  
          oStruG6Y:SetProperty('G6Y_MOTLAN', MVC_VIEW_CANCHANGE, .T. )  
			    
		    AAdd(aOrdem,{"G6Y_ITEM", "G6Y_CODG57"})
		    AAdd(aOrdem,{"G6Y_DATA","G6Y_VALOR"})
		    AAdd(aOrdem,{"G6Y_LOCORI","G6Y_NLOCOR"})
		    AAdd(aOrdem,{"G6Y_NLOCOR","G6Y_MOTLAN"})
		    					    
		    GTPOrdVwStruct(oStruG6Y,aOrdem)
		    
        EndIf
			
		
	EndIf
	
Return
