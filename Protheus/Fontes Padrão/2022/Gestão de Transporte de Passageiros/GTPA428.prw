#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'

Function GTPA428()

Return()


Static Function ModelDef()

Local oModel		:= Nil
Local oStruCab  	:= FWFormModelStruct():New()
Local oStruIt   	:= FWFormStruct(1, "GZU") //Resumo de Movimento Diário
Local aRelation 	:= {} 
Local bLoadCab	    := {|oFieldModel| G428CabLoad(oFieldModel)}

G428Struct(@oStruCab,"M")

oModel := MPFormModel():New('GTPA428',/*bPreValid*/, /*bPosValid*/,/* {|oMdl| G428Commit(oMdl)}*/, /*bCancel*/)

oModel:AddFields("CABMASTER", ,oStruCab,,,bLoadCab)

oModel:AddGrid("ITDETAIL", "CABMASTER", oStruIt, , , , ,)

aRelation	:= {{"GZU_FILIAL","xFilial('GZU')"},;
						{"GZU_CODG59","GZUCODG59"}	,;
						{"GZU_AGENCI","GZUAGENCI"}	}
						
oModel:SetRelation( 'ITDETAIL', aRelation )

oModel:GetModel("ITDETAIL"):SetDescription("RMD Itens") 


oModel:GetModel("CABMASTER"):SetOnlyQuery(.T.)
oModel:GetModel ("ITDETAIL"):SetOptional(.T.)
	
oModel:GetModel("CABMASTER"):SetDescription("RMD") 
	
oModel:SetDescription("RMD") 
	
oModel:SetPrimaryKey({})
	

Return(oModel)

Static Function ViewDef()

Local oModel		:= FWLoadModel("GTPA428")
Local oStruCab	    := FWFormViewStruct():New()
Local oStruIt   	:= FWFormStruct(2, "GZU", {|cCampo|  !AllTrim(cCampo) $ "|GZU_FILIAL|GZU_CODG59|GZU_AGENCI|"}) //Resumo de Movimento Diário

oView := FWFormView():New()

G428Struct(@oStruCab,"V")

oView:SetModel(oModel)	

oView:SetDescription("RMD")

oView:AddField("VIEW_CAB",oStruCab,"CABMASTER")
oView:AddGrid("V_ITEM"  ,oStruIt,"ITDETAIL")

oView:CreateHorizontalBox("CABECALHO" , 25) // Cabeçalho
oView:CreateHorizontalBox("ITEMRMD" , 75) // Item RMD

oView:SetOwnerView( "VIEW_CAB", "CABECALHO")
oView:SetOwnerView( "V_ITEM", "ITEMRMD")

Return(oView) 


Static Function G428Struct(oStruCab,cTipo)

If cTipo == "M"
	
	If ValType( oStruCab ) == "O"
	
		oStruCab:AddTable("   ",{" "}," ")
		oStruCab:AddField("FILIAL",;									// 	[01]  C   Titulo do campo // "Filial"
					 		"FILIAL",;									// 	[02]  C   ToolTip do campo // "Filial"
					 		"FILIAL",;							// 	[03]  C   Id do Field // "Filial"
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("GZU_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	    oStruCab:AddField("Agencia",;									// 	[01]  C   Titulo do campo  
					 		"Agencia",;									// 	[02]  C   ToolTip do campo 
					 		"GZUAGENCI",;							// 	[03]  C   Id do Field
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

		oStruCab:AddField("Cod Arrec",;								// 	[01]  C   Titulo do campo // "Agência"
				 		    "Cod Arrec",;					// 	[02]  C   ToolTip do campo // "Código da Agência"
					 		"GZUCODG59",;								// 	[03]  C   Id do Field
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
	Endif	
Else
	If ValType( oStruCab ) == "O"
	
			
			oStruCab:AddField(	"GZUAGENCI",;				// [01]  C   Nome do Campo
		                        "02",;						// [02]  C   Ordem
		                        "Agencia",;						// [03]  C   Titulo do campo // "Caixa"
		                        "Agencia",;						// [04]  C   Descricao do campo // "Caixa"
		                        {"Agencia"},;					// [05]  A   Array com Help // "Selecionar" // "Caixa"
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
		
		    oStruCab:AddField(	"GZUCODG59",;				// [01]  C   Nome do Campo
		                        "03",;						// [02]  C   Ordem
		                        "Cod Arrec",;						// [03]  C   Titulo do campo // "Agência"
		                        "Cod Arrec",;						// [04]  C   Descricao do campo // "Código da Agência"
		                        {"Cod Arrec"},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência"
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

    Endif

Endif

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} G428CabLoad()

Função responsável pelo Load do Cabeçalho da Tesouraria.
 
@sample	G428CabLoad()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		23/06/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------


Static Function G428CabLoad(oFieldModel)

Local aLoad 	:= {}
Local aCampos 	:= {}
Local aArea		:= GetArea()

Local nOperacao := oFieldModel:GetOperation()

If ( /*nOperacao == 1 .Or. */ nOperacao == 2 )

	aAdd(aCampos,xFilial("GZU"))
	aAdd(aCampos,Space(TamSx3("GZU_AGENCI")[1]))
	aAdd(aCampos,Space(TamSx3("GZU_CODG59")[1]))
	
	Aadd(aLoad,aCampos)
	Aadd(aLoad,0)

Else

	aAdd(aCampos,xFilial("GZU"))
	aAdd(aCampos,GZU->GZU_AGENCI)
	aAdd(aCampos,GZU->GZU_CODG59)
	
	
	
	Aadd(aLoad,aCampos)
	Aadd(aLoad,G6T->(Recno()))
	

EndIf

RestArea(aArea)

Return aLoad
