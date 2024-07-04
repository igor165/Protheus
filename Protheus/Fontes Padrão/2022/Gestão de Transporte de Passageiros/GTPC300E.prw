#include "GTPC300E.CH"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*
	MVC - Confirmação e cancelamento da confirmação de Viagens
*/

Function GTPC300E()
	Local aButtons      := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0034},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Fechar"
	FWExecView( STR0013, 'VIEWDEF.GTPC300E', MODEL_OPERATION_INSERT, , { || .T. },,,aButtons,{|| GC300EFech()} )//"Alocação de Recursos"#"Consulta"

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ModelDef

Definição do Modelo do MVC

@return: 
	oModel:	Object. Objeto da classe MPFormModel

@sample: oModel := ModelDef()

@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStrCab	:= FWFormStruct(1,"GQE")
Local oStrGrd	:= FWFormStruct(1,"G55")

GC300ESetStruct(@oStrCab, @oStrGrd)

oModel := MPFormModel():New("GTPC300E")

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("GQEMASTER", , oStrCab)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("G55DETAIL", "GQEMASTER", oStrGrd)

oModel:SetRelation("G55DETAIL", {{"G55_FILIAL","xFilial('GQE')"},{"G55_CODVIA","GQE_VIACOD"},{"G55_SEQ","GQE_SEQ"}}, G55->(IndexKey(1)))

//Define as descrições dos submodelos
If fwisincallstack("GTPC300J")
	oModel:SetDescription(STR0014)//"Alocações de Recursos por Localidade"
Else
	oModel:SetDescription(STR0001)//"Alocações dos Recursos"
EndIf 

oModel:GetModel("GQEMASTER"):SetDescription(STR0004)//"Recurso"
oModel:GetModel("G55DETAIL"):SetDescription(STR0006)//"Alocações"

//Somente Leitura
oModel:GetModel("GQEMASTER"):SetOnlyQuery(.t.)
oModel:GetModel("G55DETAIL"):SetOnlyQuery(.t.)

//Opcional
oModel:GetModel("G55DETAIL"):SetOptional(.t.)

//Bloqueia inserção e exclusão de linhas
oModel:GetModel('G55DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('G55DETAIL'):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

Return(oModel)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} ViewDef

Definição da View do MVC

@return: 
	oView:	Object. Objeto da classe FWFormView

@sample: oView := ViewDef()

@author Fernando Radu Muscalu

@since 18/08/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	:= ModelDef()
Local oView		:= Nil
Local oStrCab	:= FWFormStruct(2,"GQE")
Local oStrGrd	:= FWFormStruct(2,"G55")

GC300ESetStruct(@oStrCab, @oStrGrd, .F.)

oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VW_GQEMASTER', oStrCab, 'GQEMASTER')
oView:AddGrid('VW_G55DETAIL', oStrGrd, 'G55DETAIL')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('CABEC', 30)
oView:CreateHorizontalBox('CORPO', 70)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VW_GQEMASTER', 'CABEC')
oView:SetOwnerView('VW_G55DETAIL', 'CORPO')

//habilita o filtro e a pesquisa
oView:SetViewProperty("G55DETAIL", "GRIDSEEK"	, {.T.})
oView:SetViewProperty("G55DETAIL", "GRIDFILTER"	, {.T.})


//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView('VW_GQEMASTER')
oView:EnableTitleView('VW_G55DETAIL')
		
//Adiciona Botoes (Items em Acoes Relacionadas)
oView:AddUserButton(STR0015,"",{|oView| G300ESetTable(oView) } ,,VK_F5) //"Executar Filtro"

Return(oView)

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300ESetStruct

Função responsável pela definição das estruturas utilizadas no Model ou na View.

@Params: 
	oStrCab:	Objeto da Classe FWFormModelStruct ou FWFormViewStruct, dependendo do parâmetro lModel 	
	oStrGrd:	Objeto da Classe FwFormStruct.
	lModel:		Lógico. .t. - Será criado/atualizado a estrutura do Model; .f. - será criado/atualizado a
	estrutura da View
	
@sample: GC300ESetStruct(oStrCab, oStrGrd, lModel)

@author Fernando Radu Muscalu

@since 07/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Static Function GC300ESetStruct(oStrCab, oStrGrd, lModel)

Local aFields	:= {}

Local cFields	:= ""

Local nI		:= 0
Local aTrigAux	:= {}
Local aOrdem	:= {}
Default lModel := .t.

If ( !lModel )

	aFields := aClone(oStrCab:GetFields())
	
	cFields := "GQE_RECURS|GQE_TRECUR|GQE_DRECUR|DATADE|DATADE|GQE_TERC"
	
	For nI := 1 to Len(aFields)
		
		If ( !(aFields[nI,1] $ cFields) )
		
			If ( oStrCab:HasField(aFields[nI,1]) )
				oStrCab:RemoveField(aFields[nI,1])
			EndIf
				
		EndIf	
		
	Next nI
	
	oStrCab:SetProperty("GQE_RECURS",MVC_VIEW_LOOKUP,"REC001")
	
	aFields := aClone(oStrGrd:GetFields())
	
	cFields := "G55_LEGEND|G55_DTPART|G55_HRINI|G55_DTCHEG|G55_HRFIM|G55_DESORI|G55_DESDES|G55_CODVIA|G55_SEQ" 
	
	For nI := 1 to Len(aFields)
		
		If ( !(aFields[nI,1] $ cFields) )
		
			If ( oStrGrd:HasField(aFields[nI,1]) )
				oStrGrd:RemoveField(aFields[nI,1])
			EndIf
				
		EndIf	
		
	Next nI
	
	oStrCab:AddField("DTDE",;				// [01]  C   Nome do Campo
				"03",;						// [02]  C   Ordem
				STR0016,;//"Data de",;						// [03]  C   Titulo do campo
				STR0016,;//"Data de",;						// [04]  C   Descricao do campo
				Nil,;					// [05]  A   Array com Help // "Selecionar"
				"GET",;					// [06]  C   Tipo do campo
				"@D",;						// [07]  C   Picture
				NIL,;						// [08]  B   Bloco de Picture Var
				"",;						// [09]  C   Consulta F3
				.T.,;						// [10]  L   Indica se o campo é alteravel
				NIL,;						// [11]  C   Pasta do campo
				"",;						// [12]  C   Agrupamento do campo
				NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
				NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
				NIL,;						// [15]  C   Inicializador de Browse
				.T.,;						// [16]  L   Indica se o campo é virtual
				NIL,;						// [17]  C   Picture Variavel
				.F.)						// [18]  L   Indica pulo de linha após o campo

	oStrCab:AddField("DTATE",;				// [01]  C   Nome do Campo
				"04",;						// [02]  C   Ordem
				STR0017,;//"Data até",;						// [03]  C   Titulo do campo
				STR0017,;//"Data até",;						// [04]  C   Descricao do campo
				Nil,;					// [05]  A   Array com Help // "Selecionar"
				"GET",;					// [06]  C   Tipo do campo
				"@D",;						// [07]  C   Picture
				NIL,;						// [08]  B   Bloco de Picture Var
				"",;						// [09]  C   Consulta F3
				.T.,;						// [10]  L   Indica se o campo é alteravel
				NIL,;						// [11]  C   Pasta do campo
				"",;						// [12]  C   Agrupamento do campo
				NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
				NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
				NIL,;						// [15]  C   Inicializador de Browse
				.T.,;						// [16]  L   Indica se o campo é virtual
				NIL,;						// [17]  C   Picture Variavel
				.F.)						// [18]  L   Indica pulo de linha após o campo
	
	oStrGrd:AddField( 				  ; // Ord. Tipo Desc.
						"G55TPDIA"  , ; // [01] C Nome do Campo
						"98"  			, ; // [02] C Ordem
						STR0018,;//"Tipo Dia" 					, ; // [03] C Titulo do campo
						STR0018,;//"Tipo Dia" 					, ; // [04] C Descrição do campo
						NIL   						, ; // [05] A Array com Help
						"COMBO"   				, ; // [06] C Tipo do campo
						"@!" 			, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.F.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						{'1=Alocado','2=Plantão','3=Folga','4=Não Trabalhado','5=Indisponivel','6=DSR'}   					, ; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.F.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
	oStrGrd:AddField( 				  ; // Ord. Tipo Desc.
						"G55TPESC"  , ; // [01] C Nome do Campo
						"99"  			, ; // [02] C Ordem
						STR0019,;//"Tp Esc Ext" 					, ; // [03] C Titulo do campo
						STR0019,;//"Tp Esc Ext" 					, ; // [04] C Descrição do campo
						NIL   						, ; // [05] A Array com Help
						"GET"   				, ; // [06] C Tipo do campo
						"@!" 			, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.F.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						NIL   					, ; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.F.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
						
	oStrGrd:AddField( 				  ; // Ord. Tipo Desc.
						"T9_POSCONT"  , ; // [01] C Nome do Campo
						"A0"  			, ; // [02] C Ordem
						STR0020,;//"KM Atual" 					, ; // [03] C Titulo do campo
						STR0020,;//"KM Atual" 					, ; // [04] C Descrição do campo
						NIL   						, ; // [05] A Array com Help
						"GET"   				, ; // [06] C Tipo do campo
						"@!" 			, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.F.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						NIL   					, ; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.F.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
	
	oStrGrd:AddField( 				  			  ; // Ord. Tipo Desc.
						"GQE_TPCONF"  				, ; // [01] C Nome do Campo
						"A1"  						, ; // [02] C Ordem
						STR0021,;//"Tp Confirm?" 				, ; // [03] C Titulo do campo
						STR0022,;//"Tipo de Confirmação?" 		, ; // [04] C Descrição do campo
						NIL   						, ; // [05] A Array com Help
						"COMBO"   					, ; // [06] C Tipo do campo
						"@!" 						, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.T.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						GTPXCBox('GQE_TPCONF'),; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.F.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
	
	oStrGrd:AddField( 				  			  ; // Ord. Tipo Desc.
						"GQE_USRCON"  				, ; // [01] C Nome do Campo
						"A2"  						, ; // [02] C Ordem
						STR0023,;//"Usuario Conf" 				, ; // [03] C Titulo do campo
						STR0024,;//"Usuario Confirmação?" 		, ; // [04] C Descrição do campo
						NIL   						, ; // [05] A Array com Help
						"Get"   					, ; // [06] C Tipo do campo
						"@!" 						, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.F.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						NIL							, ; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.F.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
	
	oStrGrd:AddField( 				  			  ; // Ord. Tipo Desc.
						"GQE_DTREF"  				, ; // [01] C Nome do Campo
						"01"  						, ; // [02] C Ordem
						STR0025,;//"Data Ref." 				, ; // [03] C Titulo do campo
						STR0025,;//"Data Ref." 		, ; // [04] C Descrição do campo
						NIL   						, ; // [05] A Array com Help
						"Get"   					, ; // [06] C Tipo do campo
						"@D" 						, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.F.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						NIL							, ; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.F.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
	
	oStrGrd:AddField( 				  			  ; // Ord. Tipo Desc.
						"GYN_FINAL"  				, ; // [01] C Nome do Campo
						"A3"  						, ; // [02] C Ordem
						"Finalizada?",;//"Finalizada" 				, ; // [03] C Titulo do campo
						"Finalizada?",;//"Finalizada" 		, ; // [04] C Descrição do campo
						NIL   						, ; // [05] A Array com Help
						"COMBO"   					, ; // [06] C Tipo do campo
						"@!" 						, ; // [07] C Picture
						NIL    						, ; // [08] B Bloco de Picture Var
						""     						, ; // [09] C Consulta F3
						.F.    						, ; // [10] L Indica se o campo é editável
						NIL    						, ; // [11] C Pasta do campo
						NIL    						, ; // [12] C Agrupamento do campo
						GTPXCBox('GYN_FINAL')		, ; // [13] A Lista de valores permitido do campo (Combo)
						NIL    						, ; // [14] N Tamanho Máximo da maior opção do combo
						NIL    						, ; // [15] C Inicializador de Browse
						.T.    						, ; // [16] L Indica se o campo é virtual
						NIL    						  ) // [17] C Picture Variável
	
	
	oStrGrd:SetProperty("*",MVC_VIEW_CANCHANGE,.F.)
	oStrGrd:SetProperty('G55_CODVIA',MVC_VIEW_TITULO,STR0026)//'Viag./Aloc.'
	
	aAdd(aOrdem,{"GQE_TRECUR","GQE_RECURS"})
	aAdd(aOrdem,{"GQE_RECURS","GQE_DRECUR"})
	aAdd(aOrdem,{"GQE_DRECUR","DTDE"})
	aAdd(aOrdem,{"DTDE","DTATE"}) 
	
	GTPOrdVwStruct(oStrCab,aOrdem)	
	
Else
	
	oStrCab:AddTrigger( ;
		'GQE_RECURS'  , ;                  	// [01] Id do campo de origem
		'GQE_DRECUR'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { |oMdlGQE| GC300DscRec(oMdlGQE)	} ) // [04] Bloco de codigo de execução do gatilho
		 
	oStrCab:AddTrigger( ;
		'GQE_TERC'  , ;                  	// [01] Id do campo de origem
		'GQE_RECURS'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 					// [03] Bloco de codigo de validação da execução do gatilho
		 { || ''	} ) 					// [04] Bloco de codigo de execução do gatilho
	
	oStrCab:AddTrigger( ;
		'GQE_TERC'  , ;                  	// [01] Id do campo de origem
		'GQE_DRECUR'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 					// [03] Bloco de codigo de validação da execução do gatilho
		 { || ''	} ) 					// [04] Bloco de codigo de execução do gatilho	 
		 	 
	oStrGrd:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
	
	oStrGrd:AddField(STR0031,;//"TABELA",;									// 	[01]  C   Titulo do campo
			 		STR0031,;//"TABELA",;									// 	[02]  C   ToolTip do campo
			 		"TABELA",;								// 	[03]  C   Id do Field
			 		"C",;									// 	[04]  C   Tipo do campo
			 		3,;										// 	[05]  N   Tamanho do campo
			 		0,;										// 	[06]  N   Decimal do campo
			 		Nil,;									// 	[07]  B   Code-block de validação do campo
			 		Nil,;									// 	[08]  B   Code-block de validação When do campo
			 		NIL,;									//	[09]  A   Lista de valores permitido do campo
			 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
			 		NIL,;									//	[11]  B   Code-block de inicializacao do campo
			 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
			 		.T.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
			 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
	
	If FwIsInCallStack("GTPC300k")
		oStrCab:AddField(STR0021,;//"Tp Confirm?",;									// 	[01]  C   Titulo do campo
				 		STR0022,;//"Tipo de Confirmação?",;									// 	[02]  C   ToolTip do campo
				 		"TPCONFIRM",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		1,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		GTPXCBox('GQE_TPCONF'),;				//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		{||'1'},;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.T.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
	Endif
	If FwIsInCallStack("GTPC300I") .OR. FwIsInCallStack("GTPC300k") // remoção de recursos ou confirmação de recurso
		oStrCab:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		oStrCab:SetProperty("GQE_RECURS",MODEL_FIELD_OBRIGAT,.T.)
		oStrGrd:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)
		oStrGrd:AddField("",;									// 	[01]  C   Titulo do campo
				 		"",;									// 	[02]  C   ToolTip do campo
				 		"G55_MARK",;							// 	[03]  C   Id do Field
				 		"L",;									// 	[04]  C   Tipo do campo
				 		1,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	

		
	Endif
	
	oStrCab:AddField(STR0016,;//"Data de",;									// 	[01]  C   Titulo do campo
				 		STR0016,;//"Data de",;									// 	[02]  C   ToolTip do campo
				 		"DTDE",;							// 	[03]  C   Id do Field
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
				 		
	oStrCab:AddField(STR0017,;//"Data Até",;									// 	[01]  C   Titulo do campo
			 		STR0017,;//"Data Até",;									// 	[02]  C   ToolTip do campo
			 		"DTATE",;							// 	[03]  C   Id do Field
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
				 		
	
	oStrGrd:AddField(	STR0018,;//"Tipo Dia",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
							STR0018,;//"Tipo Dia",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
							"G55TPDIA",;	// 	[03]  C   Id do Field
							"C",;		// 	[04]  C   Tipo do campo
							1,;		// 	[05]  N   Tamanho do campo
							0,;			// 	[06]  N   Decimal do campo
							Nil,;		// 	[07]  B   Code-block de validação do campo
							Nil,;		// 	[08]  B   Code-block de validação When do campo
							Nil,;		//	[09]  A   Lista de valores permitido do campo
							.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
							NIL,;		//	[11]  B   Code-block de inicializacao do campo
							.F.,;		//	[12]  L   Indica se trata-se de um campo chave
							.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T.)		// 	[14]  L   Indica se o campo é virtual

	oStrGrd:AddField(	STR0019,;//"Tp Esc Ext",;	// 	[01]  C   Titulo do campo // "Arq. Flash"
							STR0019,;//"Tp Esc Ext",;	// 	[02]  C   ToolTip do campo // "Diretório dos arquivos Flash"
							"G55TPESC",;	// 	[03]  C   Id do Field
							"C",;		// 	[04]  C   Tipo do campo
							50,;		// 	[05]  N   Tamanho do campo
							0,;			// 	[06]  N   Decimal do campo
							Nil,;		// 	[07]  B   Code-block de validação do campo
							Nil,;		// 	[08]  B   Code-block de validação When do campo
							Nil,;		//	[09]  A   Lista de valores permitido do campo
							.F.,;		//	[10]  L   Indica se o campo tem preenchimento obrigatório
							NIL,;		//	[11]  B   Code-block de inicializacao do campo
							.F.,;		//	[12]  L   Indica se trata-se de um campo chave
							.F.,;		//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
							.T.)		// 	[14]  L   Indica se o campo é virtual
	
	oStrGrd:AddField(STR0020,;//"Km Atual",;									// 	[01]  C   Titulo do campo
				 		STR0020,;//"Km Atual",;									// 	[02]  C   ToolTip do campo
				 		"T9_POSCONT",;							// 	[03]  C   Id do Field
				 		"N",;									// 	[04]  C   Tipo do campo
				 		9,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
	oStrGrd:AddField(STR0032,;//"Linha",;									// 	[01]  C   Titulo do campo
				 		STR0032,;//"Linha",;									// 	[02]  C   ToolTip do campo
				 		"GYN_LINCOD",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		TamSx3('GYN_LINCOD')[1],;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual
	
	oStrGrd:AddField(STR0021,;//"Tp Confirm?",;									// 	[01]  C   Titulo do campo
				 		STR0022,;//"Tipo de Confirmação?",;									// 	[02]  C   ToolTip do campo
				 		"GQE_TPCONF",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		1,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		GTPXCBox('GQE_TPCONF'),;				//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		{||'1'},;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.T.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
	oStrGrd:AddField(STR0033,;//"Usuário",;									// 	[01]  C   Titulo do campo
				 		STR0033,;//"Usuário",;									// 	[02]  C   ToolTip do campo
				 		"GQE_USRCON",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		TamSx3('GQE_USRCON')[1],;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual
				 		
	oStrGrd:AddField(STR0025,;//"Data Ref.",;									// 	[01]  C   Titulo do campo
				 		STR0025,;//"Data Ref.",;									// 	[02]  C   ToolTip do campo
				 		"GQE_DTREF",;							// 	[03]  C   Id do Field
				 		"D",;									// 	[04]  C   Tipo do campo
				 		TamSx3('GQE_DTREF')[1],;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual
	
	oStrGrd:AddField("Finalizada?",;//"Km Atual",;									// 	[01]  C   Titulo do campo
				 		"Finalizada?",;//"Km Atual",;									// 	[02]  C   ToolTip do campo
				 		"GYN_FINAL",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		1,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
			
	
	If fwisincallstack("GTPC300J") // remoção de recursos
		oStrCab:AddField(STR0030,;//"Localidade",;									// 	[01]  C   Titulo do campo
				 		STR0030,;//"Localidade",;									// 	[02]  C   ToolTip do campo
				 		"LOCALI",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
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
				 		
		oStrCab:AddField(STR0029,;//"Des. Local",;									// 	[01]  C   Titulo do campo
				 		STR0029,;//"Des. Local",;									// 	[02]  C   ToolTip do campo
				 		"DESLOC",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		40,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual
				 		
		oStrGrd:AddField(STR0028,;//"Alocado?",;									// 	[01]  C   Titulo do campo
				 		STR0028,;//"Alocado?",;									// 	[02]  C   ToolTip do campo
				 		"G55_ALOC",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		1,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		{"1=Sim","2=Não"},;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
		oStrGrd:AddField(STR0004,;//"Recurso",;									// 	[01]  C   Titulo do campo
				 		STR0004,;//"Recurso",;									// 	[02]  C   ToolTip do campo
				 		"G55_RECUR",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		16,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
		oStrGrd:AddField(STR0027,;//"Desc. Recu",;									// 	[01]  C   Titulo do campo
				 		STR0027,;//"Desc. Recu",;									// 	[02]  C   ToolTip do campo
				 		"G55_DSCREC",;							// 	[03]  C   Id do Field
				 		"C",;									// 	[04]  C   Tipo do campo
				 		40,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
		oStrGrd:AddField(STR0020,;//"Km Atual",;									// 	[01]  C   Titulo do campo
				 		STR0020,;//"Km Atual",;									// 	[02]  C   ToolTip do campo
				 		"T9_POSCONT",;							// 	[03]  C   Id do Field
				 		"N",;									// 	[04]  C   Tipo do campo
				 		9,;										// 	[05]  N   Tamanho do campo
				 		0,;										// 	[06]  N   Decimal do campo
				 		Nil,;									// 	[07]  B   Code-block de validação do campo
				 		Nil,;									// 	[08]  B   Code-block de validação When do campo
				 		Nil,;									//	[09]  A   Lista de valores permitido do campo
				 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
				 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
				 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
				 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
				 		.T.)									// 	[14]  L   Indica se o campo é virtual	
		
		aTrigAux := FwStruTrigger("LOCALI", "DESLOC", "Posicione('GI1',1,xFilial('GI1') + FwFldGet('LOCALI'), 'GI1_DESCRI')")
		oStrCab:AddTrigger(aTrigAux[1],aTrigAux[2],aTrigAux[3],aTrigAux[4])	
		
	Endif
Endif

Return()

//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} G300ESetTable()
Realiza a caraga das alocação de acordo com a viagem
 
@Params:
	oSubMdl:	O Sub modelo

@Return
		 						
@sample aRet := GCE300Cabec(oModel)
@author Fernando Radu Muscalu

@since 07/12/2015
@version 1.0
*/
//------------------------------------------------------------------------------------------------------
Function G300ESetTable(oView)
Local oModel	:= oView:GetModel()
Local oMdlGQE	:= oView:GetModel('GQEMASTER')
Local oMdlG55	:= oView:GetModel('G55DETAIL')
Local aFldG55	:= {}
Local cAliasG55	:= GetNextAlias() 
Local cAliasLoc	:= GetNextAlias() 
Local cAliasConf:= GetNextAlias() 
Local oStruG55	:= oMdlG55:GetStruct()
Local nI		:= 0
Local cUnion	:= "%%"
Local lLocOk 	:= .F.
Local cDescri	:= ''
Local cInnerST9	:= "%%"
Local cPosCont	:= "% 0 %"
Local cTerceiro := IIF( oMdlGQE:GetValue("GQE_TERC") == '1', "%'1'%", "%'2',' '%" )
Local lBOracle	:= Trim(TcGetDb()) = 'ORACLE'
Local lBPOSTGr	:= Trim(TcGetDb()) = 'POSTGRES'
Local cCond     := ""

If lBOracle .OR. lBPOSTGr
	cCond := "%G55_DTCHEG||G55_HRFIM%"  
Else
	cCond := "%G55_DTCHEG+G55_HRFIM%" 
EndIf

oMdlG55:ClearData()
//Desbloqueia inserção e exclusão de linhas
oModel:GetModel('G55DETAIL'):SetNoInsertLine(.F.)
oModel:GetModel('G55DETAIL'):SetNoDeleteLine(.F.)

If oMdlGQE:GetValue("GQE_TRECUR") == '1'
	cUnion	:= "%"+CHR(13)+CHR(10)
	cUnion	+= " UNION ALL "+CHR(13)+CHR(10) 
	cUnion	+= " " +CHR(13)+CHR(10)
	cUnion	+= " SELECT " +CHR(13)+CHR(10)
	cUnion	+= "	'GQK' AS TABELA, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK.GQK_DTREF AS GQE_DTREF, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK.GQK_DTINI AS G55_DTPART, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK.GQK_HRINI AS G55_HRINI, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK.GQK_DTFIM AS G55_DTCHEG, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK.GQK_HRFIM AS G55_HRFIM, "+CHR(13)+CHR(10)
	cUnion	+= "	GI1ORI.GI1_DESCRI AS G55_DESORI, "+CHR(13)+CHR(10)
	cUnion	+= "	GI1DES.GI1_DESCRI AS G55_DESDES, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK.GQK_CODIGO As G55_CODVIA, "+CHR(13)+CHR(10)
	cUnion	+= "	'' AS G55_SEQ, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK.GQK_TPDIA AS G55TPDIA, "+CHR(13)+CHR(10)
	cUnion	+= "	GZS.GZS_DESCRI AS G55TPESC, "+CHR(13)+CHR(10)
	cUnion	+= "	0 AS T9_POSCONT, "+CHR(13)+CHR(10)
	cUnion	+= "	'' AS GYN_LINCOD, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK_TPCONF AS GQE_TPCONF, "+CHR(13)+CHR(10)
	cUnion	+= "	GQK_USRCON AS GQE_USRCON, "+CHR(13)+CHR(10)
	cUnion	+= "	(CASE GQK.GQK_MARCAD WHEN '1' THEN '1' ELSE '2' END) AS GYN_FINAL "+CHR(13)+CHR(10)
	 	
	cUnion	+= " FROM "+RetSqlName('GQK')+" GQK  "+CHR(13)+CHR(10)
	cUnion	+= "	LEFT JOIN "+RetSqlName('GI1')+" GI1ORI ON "+CHR(13)+CHR(10)
	cUnion	+= "		GI1ORI.GI1_FILIAL = '"+xFilial('GI1')+"' "+CHR(13)+CHR(10)
	cUnion	+= "		AND GI1ORI.GI1_COD = GQK.GQK_LOCORI "+CHR(13)+CHR(10)
	cUnion	+= "		AND GI1ORI.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cUnion	+= "	LEFT JOIN "+RetSqlName('GI1')+" GI1DES ON "+CHR(13)+CHR(10)
	cUnion	+= "		GI1DES.GI1_FILIAL = '"+xFilial('GI1')+"' "+CHR(13)+CHR(10)
	cUnion	+= "		AND GI1DES.GI1_COD = GQK.GQK_LOCDES "+CHR(13)+CHR(10)
	cUnion	+= "		AND GI1DES.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	
	cUnion	+= "	LEFT JOIN "+RetSqlName('GZS')+" GZS ON "+CHR(13)+CHR(10)
	cUnion	+= "		GZS.GZS_FILIAL = '"+xFilial('GZS')+"' "+CHR(13)+CHR(10)
	cUnion	+= "		AND GZS.GZS_CODIGO = GQK.GQK_CODGZS "+CHR(13)+CHR(10)
	cUnion	+= "		AND GZS.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	
	cUnion	+= " WHERE  "+CHR(13)+CHR(10)
	cUnion	+= "	GQK_FILIAL = '"+xFilial('GQK')+"' "+CHR(13)+CHR(10)
	cUnion	+= "	AND GQK_RECURS = '"+oMdlGQE:GetValue("GQE_RECURS")+"' "+CHR(13)+CHR(10)	
	
	cUnion	+= "	AND ((GQK.GQK_DTINI >= '" + DTOS(oMdlGQE:GetValue('DTDE')) + "'" +CHR(13)+CHR(10)
	cUnion	+= "	AND GQK.GQK_DTFIM <= '" + DTOS(oMdlGQE:GetValue('DTATE')) + "')" +CHR(13)+CHR(10)
	cUnion	+= "	OR ('" + DtoS(oMdlGQE:GetValue('DTDE')) + "' Between GQK.GQK_DTINI AND GQK.GQK_DTFIM)"+CHR(13)+CHR(10)
	cUnion	+= "	OR ('" + DTOS(oMdlGQE:GetValue('DTATE')) + "' Between GQK.GQK_DTINI AND GQK.GQK_DTFIM))"+CHR(13)+CHR(10)
	cUnion	+= "	AND GQK.D_E_L_E_T_= ' ' "+CHR(13)+CHR(10)
	cUnion	+= "%"

Else
	If oMdlGQE:GetValue("GQE_TERC") == '2'
		cInnerST9	:= "%"
		cInnerST9	+= " Inner Join "+RetSqlName('ST9')+" ST9 on "
		cInnerST9	+= "	ST9.T9_FILIAL = '"+xFilial('ST9')+"' "
		cInnerST9	+= "	AND ST9.T9_CODBEM = '"+oMdlGQE:GetValue("GQE_RECURS")+"' "
		cInnerST9	+= "	AND ST9.D_E_L_E_T_= ' ' "
		cInnerST9	+= "%"
	
		cPosCont	:= "% ST9.T9_POSCONT %"
	Endif
	
	If FwIsInCallStack('GTPC300E')
		cUnion	:= "%"+CHR(13)+CHR(10)                                     
		cUnion	+= " UNION ALL "+CHR(13)+CHR(10) 
		cUnion	+= " " +CHR(13)+CHR(10)
		cUnion	+= " SELECT                                                "+CHR(13)+CHR(10)
		cUnion	+= " 	'STJ' AS TABELA,                                   "+CHR(13)+CHR(10)
		cUnion	+= " 	'' as GQE_DTREF,                                   "+CHR(13)+CHR(10)
		cUnion	+= " 	TJ_DTPPINI AS G55_DTPART,                          "+CHR(13)+CHR(10)
		cUnion	+= " 	Cast(REPLACE(TJ_HOPPINI,':','') as varchar(4) ) AS G55_HRINI,           "+CHR(13)+CHR(10)
		cUnion	+= " 	TJ_DTPPFIM AS G55_DTCHEG,                          "+CHR(13)+CHR(10)
		cUnion	+= " 	Cast(REPLACE(TJ_HOPPFIM,':','') as varchar(4) ) AS G55_HRFIM,            "+CHR(13)+CHR(10)
		cUnion	+= " 	'' AS G55_DESORI,                                  "+CHR(13)+CHR(10)
		cUnion	+= " 	'' AS G55_DESDES,                                  "+CHR(13)+CHR(10)
		cUnion	+= " 	'' as G55_CODVIA,                                  "+CHR(13)+CHR(10)
		cUnion	+= " 	'' as G55_SEQ,                                     "+CHR(13)+CHR(10)
		cUnion	+= " 	'5' as G55TPDIA,	                               "+CHR(13)+CHR(10)
		cUnion	+= " 	'Manutenção' AS G55TPESC,                          "+CHR(13)+CHR(10)
		cUnion	+= " 	STF.TF_CONMANU as T9_POSCONT,                      "+CHR(13)+CHR(10)
		cUnion	+= " 	''  AS GYN_LINCOD,                                 "+CHR(13)+CHR(10)
		cUnion	+= " 	''  AS GQE_TPCONF,                                 "+CHR(13)+CHR(10)
		cUnion	+= " 	''  AS GQE_USRCON,                                  "+CHR(13)+CHR(10)
		cUnion	+= " 	''  AS GYN_FINAL                                   "+CHR(13)+CHR(10)
		cUnion	+= " FROM                                                  "+CHR(13)+CHR(10)
		cUnion	+= " 	"+RetSqlName('STF')+" STF                          "+CHR(13)+CHR(10)
		cUnion	+= " INNER JOIN                                            "+CHR(13)+CHR(10)
		cUnion	+= " 	"+RetSqlName('STJ')+" STJ                          "+CHR(13)+CHR(10)
		cUnion	+= " ON                                                    "+CHR(13)+CHR(10)
		cUnion	+= " 	TJ_FILIAL like RTRIM(TF_FILIAL)+'%'                "+CHR(13)+CHR(10)
		cUnion	+= " 	AND TJ_CODBEM = TF_CODBEM                          "+CHR(13)+CHR(10)
		cUnion	+= " 	AND TJ_SERVICO = TF_SERVICO                        "+CHR(13)+CHR(10)
		cUnion	+= " 	AND TJ_SEQRELA = TF_SEQRELA                        "+CHR(13)+CHR(10)
		cUnion	+= " 	AND                                                "+CHR(13)+CHR(10)
		cUnion	+= " 		(                                              "+CHR(13)+CHR(10)
		cUnion	+= " 			TJ_SITUACA = 'P'                           "+CHR(13)+CHR(10)
		cUnion	+= " 			OR (TJ_SITUACA = 'L' AND TJ_TERMINO = 'N') "+CHR(13)+CHR(10)
		cUnion	+= " 		)                                              "+CHR(13)+CHR(10)
		cUnion	+= " 	AND STJ.D_E_L_E_T_ = ' '                            "+CHR(13)+CHR(10)
		cUnion	+= " WHERE                                                 "+CHR(13)+CHR(10)
		cUnion	+= " 	TF_FILIAL = '"+xFilial('STF')+"'                     "+CHR(13)+CHR(10)
		cUnion	+= " 	AND TF_CODBEM = '"+oMdlGQE:GetValue("GQE_RECURS")+"' "+CHR(13)+CHR(10)
		cUnion	+= " 	AND TF_ATIVO IN('S','')                            "+CHR(13)+CHR(10)
		cUnion	+= " 	AND ((STJ.TJ_DTPPINI >= '" + DTOS(oMdlGQE:GetValue('DTDE')) + "'" +CHR(13)+CHR(10)
		cUnion	+= " 	AND STJ.TJ_DTPPFIM <= '" + DTOS(oMdlGQE:GetValue('DTATE')) + "')" +CHR(13)+CHR(10)
		cUnion	+= "	OR ('" + DtoS(oMdlGQE:GetValue('DTDE')) + "' Between STJ.TJ_DTPPINI AND STJ.TJ_DTPPFIM) "+CHR(13)+CHR(10)
		cUnion	+= " 	OR ('" + DTOS(oMdlGQE:GetValue('DTATE')) + "' Between STJ.TJ_DTPPINI AND STJ.TJ_DTPPFIM)) "+CHR(13)+CHR(10)
		cUnion	+= " 	AND STF.D_E_L_E_T_ = ' '                            "+CHR(13)+CHR(10)
		cUnion	+= "%"			                                                       
	Endif
Endif

if  FwIsInCallStack('GTPC300J')
	
	BeginSql Alias cAliasLoc
	
	SELECT 
		distinct (GQE_RECURS),
		MAX(%Exp:cCond%)	
	FROM %Table:GQE% GQE
	Inner Join %Table:G55% G55 on
		G55_FILIAL = %xFilial:G55%
		AND GQE_VIACOD = G55_CODVIA
		AND GQE_SEQ = G55_SEQ
		AND G55.%NotDel%
		AND G55_LOCDES = %Exp:oMdlGQE:GetValue("LOCALI")%
		AND G55_DTCHEG BETWEEN %Exp:oMdlGQE:GetValue("DTDE")-16% AND %Exp:oMdlGQE:GetValue("DTDE")- 1 %
		AND G55.G55_CANCEL <> '2'			
	WHERE
		GQE_FILIAL = %xFilial:GQE%
		AND GQE_TRECUR = %Exp:oMdlGQE:GetValue("GQE_TRECUR")%		
		AND GQE.%NotDel%
	GROUP BY 
		GQE_RECURS
	ORDER BY 
		GQE_RECURS	
		
	EndSql
	
	While (cAliasLoc)->(!EOF())
		
		BeginSql Alias cAliasConf
		
		SELECT 
			G55_LOCDES,G55_CODVIA
		FROM %Table:GQE% GQE 
		INNER JOIN %Table:G55% G55 ON
			G55_FILIAL = %xFilial:G55% AND
			G55_CODVIA = GQE_VIACOD AND
			G55_SEQ = GQE_SEQ AND
			G55.G55_CANCEL <> '2' AND
			G55.%NotDel% AND
			G55_DTCHEG+G55_HRFIM =(
									SELECT 
										maX(%Exp:cCond%)AS DT 
									FROM %Table:GQE% GQE 
									INNER JOIN %Table:G55% G55 ON
										G55_FILIAL = %xFilial:G55% AND
										G55_CODVIA = GQE_VIACOD AND
										G55_SEQ = GQE_SEQ AND
										G55_DTCHEG <  %Exp:oMdlGQE:GetValue("DTDE")% AND
										G55.G55_CANCEL <> '2' AND
										G55.%NotDel%
									WHERE
										GQE_FILIAL = %xFilial:GQE% AND
										GQE_TRECUR = %Exp:oMdlGQE:GetValue("GQE_TRECUR")% AND
										GQE_RECURS = %Exp:(cAliasLoc)->GQE_RECURS% AND 
										GQE.%NotDel%)
		WHERE 
			GQE_RECURS = %Exp:(cAliasLoc)->GQE_RECURS% AND 
			GQE.%NotDel%
		
		EndSql
		lLocOk := .F.
		If (cAliasConf)->(!EOF())
			if alltrim((cAliasConf)->G55_LOCDES) == alltrim(oMdlGQE:GetValue("LOCALI"))
				lLocOk := .T.
			Endif
		Endif
		(cAliasConf)->(DbCloseArea())
		
		If lLocOk 
			BeginSql Alias cAliasG55
			
			SELECT 
				'GQE' AS TABELA,
				GQE_RECURS as G55_RECUR,
				G55_CODVIA ,
				G55_DTPART,
				G55_HRINI,
				G55_DTCHEG,
				G55_HRFIM,
				G55_LOCDES,
				GI1DES.GI1_DESCRI AS G55_DESDES,
				%Exp:cPosCont% as T9_POSCONT
			FROM %Table:GQE% GQE  
			INNER JOIN %Table:G55% G55  ON 
				G55_FILIAL = %xFilial:G55% AND 
				G55_CODVIA = GQE_VIACOD AND 
				G55_SEQ = GQE_SEQ AND 
				G55.%NotDel% AND
				G55_DTPART BETWEEN  %Exp:oMdlGQE:GetValue("DTDE")% AND %Exp:oMdlGQE:GetValue("DTATE")%
				AND G55_LOCORI = %Exp:oMdlGQE:GetValue("LOCALI")%
				AND G55.G55_CANCEL <> '2'
			Inner Join %Table:GI1% GI1DES on
				GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = G55.G55_LOCDES
				AND GI1DES.%NotDel%
			Left Join %Table:ST9% ST9 on
				ST9.T9_FILIAL = %xFilial:ST9%
				AND ST9.T9_CODBEM = GQE_RECURS
				AND ST9.%NotDel%
				
			WHERE  
				GQE_FILIAL = %xFilial:GQE% AND
				GQE_TRECUR = %Exp:alltrim(oMdlGQE:GetValue("GQE_TRECUR"))% AND
				GQE_RECURS = %Exp:(cAliasLoc)->GQE_RECURS% AND
				GQE.%NotDel%
			ORDER BY
   				G55_DTPART
			EndSql
			
			
			
			
			If (cAliasG55)->(!EOF())
			
				aFldG55 := (cAliasG55)->(DbStruct())
				Do While (cAliasG55)->(!EOF())
					If !oMdlG55:IsEmpty()
						 oMdlG55:AddLine()
					EndIf
					oMdlG55:LoadValue('G55_ALOC','1')
					If oMdlGQE:GetValue("GQE_TRECUR") == "1"
						cDescri :=  Posicione("GYG",1,xFilial("GYG")+ (cAliasLoc)->GQE_RECURS,"GYG_NOME"  )
					Else 
						cDescri :=  Posicione("ST9",1,xFilial("ST9")+ (cAliasLoc)->GQE_RECURS,"T9_NOME"  )
					EndIf
					oMdlG55:LoadValue('G55_DSCREC',cDescri)
					For nI := 1 to Len(aFldG55)
						If Alltrim(aFldG55[nI][1]) $ 'G55_RECUR/G55_DESDES/TABELA'
							oMdlG55:LoadValue(aFldG55[nI][1],(cAliasG55)->&(aFldG55[nI][1]))
						Else
							oMdlG55:LoadValue(aFldG55[nI][1],GTPCastType((cAliasG55)->&(aFldG55[nI][1]),TamSx3(aFldG55[nI][1])[3]))
						Endif
					
					Next
					(cAliasG55)->(DbSkip())
				EndDo
			Else
				If !oMdlG55:IsEmpty()
					 oMdlG55:AddLine()
				EndIf
				oMdlG55:LoadValue('G55_ALOC','2')	
				oMdlG55:LoadValue('G55_RECUR',(cAliasLoc)->GQE_RECURS)
				If oMdlGQE:GetValue("GQE_TRECUR") == "1"
					cDescri :=  Posicione("GYG",1,xFilial("GYG")+ (cAliasLoc)->GQE_RECURS,"GYG_NOME"  )
				Else 
					cDescri :=  Posicione("ST9",1,xFilial("ST9")+ (cAliasLoc)->GQE_RECURS,"T9_NOME"  )
				EndIf
				oMdlG55:LoadValue('G55_DSCREC',cDescri)
			EndIf
			(cAliasG55)->(DbCloseArea())
		EndIf	
		(cAliasLoc)->(DbSkip())
	End
	(cAliasLoc)->(DbCloseArea())
Else
	BeginSql Alias cAliasG55
		SELECT 
			'GQE' AS TABELA,
			GQE_DTREF,
			G55_DTPART,
			G55_HRINI,
			G55_DTCHEG,
			G55_HRFIM,
			GI1ORI.GI1_DESCRI AS G55_DESORI,
			GI1DES.GI1_DESCRI AS G55_DESDES,
			G55_CODVIA,
			G55_SEQ,
			'1' as G55TPDIA,	//Alocado
			'' AS G55TPESC,
			%Exp:cPosCont% as T9_POSCONT,
			GYN.GYN_LINCOD,
			GQE.GQE_TPCONF,
			GQE.GQE_USRCON,
			GYN.GYN_FINAL	

		FROM %Table:G55% G55
			Inner Join %Table:GYN% GYN on
				GYN.GYN_FILIAL = %xFilial:GYN%
				AND GYN.GYN_CODIGO = G55.G55_CODVIA
				AND GYN.%NotDel%
			Inner Join %Table:GQE% GQE on
				GQE_FILIAL = %xFilial:GQE%
				AND GQE_VIACOD = G55_CODVIA
				AND GQE_SEQ = G55_SEQ
				AND GQE_TRECUR = %Exp:oMdlGQE:GetValue("GQE_TRECUR")%
				AND GQE_RECURS = %Exp:oMdlGQE:GetValue("GQE_RECURS")%
				AND GQE_TERC IN (%Exp:cTerceiro%)
				AND GQE.%NotDel%
			Inner Join %Table:GI1% GI1ORI on
				GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD = G55.G55_LOCORI
				AND GI1ORI.%NotDel%
			Inner Join %Table:GI1% GI1DES on
				GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = G55.G55_LOCDES
				AND GI1DES.%NotDel%
			
			%Exp:cInnerST9%
			
		WHERE
			G55_FILIAL = %xFilial:G55%
			AND G55.G55_CANCEL <> '2'
			AND 1 =  (
						(Case
							When GYN.GYN_TIPO = '1' THEN 
								(CASE 
									WHEN (G55.G55_DTPART >= %Exp:DTOS(oMdlGQE:GetValue("DTDE"))%
										AND G55.G55_DTCHEG <= %Exp:DTOS(oMdlGQE:GetValue("DTATE"))%)
										OR (%Exp:DTOS(oMdlGQE:GetValue("DTDE"))% Between G55.G55_DTPART AND G55.G55_DTCHEG)
										OR (%Exp:DTOS(oMdlGQE:GetValue("DTATE"))% Between G55.G55_DTPART AND G55.G55_DTCHEG) THEN 1 
									ELSE 0 
								End)
							ELSE 
								(CASE 
									WHEN GQE.GQE_TRECUR = '1' 
										AND GYN.GYN_FINAL = '1'
										AND EXISTS (	Select 1 
										 				From %Table:GQK% GQK 
										 				Where 
										 					GQK_FILIAL = G55.G55_FILIAL 
										 					AND GQK.GQK_CODVIA = G55.G55_CODVIA 
										 					AND GQK.GQK_RECURS = GQE.GQE_RECURS
										 					AND GQK.%NotDel%
										 			)  
										THEN 0
									WHEN (GYN.GYN_DTINI >= %Exp:DTOS(oMdlGQE:GetValue("DTDE"))%
										AND GYN.GYN_DTFIM <= %Exp:DTOS(oMdlGQE:GetValue("DTATE"))%)
										OR (%Exp:DTOS(oMdlGQE:GetValue("DTDE"))% Between GYN.GYN_DTINI AND GYN.GYN_DTFIM)
										OR (%Exp:DTOS(oMdlGQE:GetValue("DTATE"))% Between GYN.GYN_DTINI AND GYN.GYN_DTFIM) THEN 1 
									ELSE 0 
								End)
						End)
					)
			
			AND G55.%NotDel%
			%Exp:cUnion%
		ORDER BY
			GQE_DTREF,G55_DTPART,G55_HRINI
	EndSql
	
	
	If (cAliasG55)->(!EOF())
		aFldG55 := (cAliasG55)->(DbStruct())
		Do While (cAliasG55)->(!EOF())
			If !oMdlG55:IsEmpty()
				 oMdlG55:AddLine()
			EndIf
			For nI := 1 to Len(aFldG55)
				If ( oStruG55:HasField(aFldG55[nI][1]) )
					If aFldG55[nI][1] <> 'G55TPDIA' .AND. aFldG55[nI][1] <> 'G55TPESC' .and. aFldG55[nI][1] <> 'TABELA'  
						lREt := oMdlG55:LoadValue(aFldG55[nI][1],GTPCastType((cAliasG55)->&(aFldG55[nI][1]),TamSx3(aFldG55[nI][1])[3]))
					Else
						lREt := oMdlG55:LoadValue(aFldG55[nI][1],(cAliasG55)->&(aFldG55[nI][1]))
					Endif
				EndIf
			Next
			(cAliasG55)->(DbSkip())
		EndDo
	EndIf
	(cAliasG55)->(DbCloseArea())
Endif
	

oMdlG55:GoLine(1)
GTPDestroy(aFldG55)

//Bloqueia inserção e exclusão de linhas
oModel:GetModel('G55DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('G55DETAIL'):SetNoDeleteLine(.T.)

oView:Refresh()

Return



//------------------------------------------------------------------------------------------------------
/*{Protheus.doc} GC300DscRec

Função responsável para buscar a descrição do recurso de acordo 
com tipo do recurso e o código do recurso 

@Param
			oMdlGQE	- O modelo recurso da viagem

@Return 	cDescri - Descrição do campo
		
@sample GTPC300()
@author Fernando Radu Muscalu

@since 28/08/2017
@version 1.0
*/
//------------------------------------------------------------------------------------------------------

Static Function GC300DscRec(oMdlGQE)

Local cDescri	:= ""
Local lTerceiro := oMdlGQE:GetValue("GQE_TERC") == "1"

If lTerceiro
	cDescri :=  Posicione("G6Z",1,xFilial("G6Z")+ oMdlGQE:GetValue("GQE_RECURS"),"G6Z_NOME"  )
Else
	If oMdlGQE:GetValue("GQE_TRECUR") == "1"
		cDescri :=  Posicione("GYG",1,xFilial("GYG")+ oMdlGQE:GetValue("GQE_RECURS"),"GYG_NOME"  )
	Else
		cDescri :=  Posicione("ST9",1,xFilial("ST9")+ oMdlGQE:GetValue("GQE_RECURS"),"T9_NOME"  )
	EndIf
EndIf

Return(cDescri)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GC300EFech

Função executada através do bloco de Cancelamento da Tela. Configura a View
como se não tivesse sido alterada. O MVC TURA067 não persiste dados em banco.

@param		Nenhum
@since		01/12/2016
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function GC300EFech() 

Local oView	:= FwViewActive()
		
oView:SetModified(.f.)
	
Return(.t.)
