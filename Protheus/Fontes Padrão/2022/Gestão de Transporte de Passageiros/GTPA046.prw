#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'GTPA046.CH'

Function GTPA046()

Local oBrowse := FWMBrowse():New()

oBrowse:SetAlias("G58")
oBrowse:SetDescription(STR0001) //"Administradoras X Bandeiras"
oBrowse:DisableDetails()
oBrowse:Activate()

Return oBrowse


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu
 
@sample	MenuDef()
 
@return	aRotina - Array com opções do menu
 
@author	Renan Ribeiro Brando -  Inovação
@since		08/03/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
Local oModel  := FwModelActive()

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GTPA046" OPERATION 2 ACCESS 0 // Visualizar //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GTPA046" OPERATION 3 ACCESS 0 // Incluir //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA046" OPERATION 4 ACCESS 0 // Alterar //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GTPA046" OPERATION 5 ACCESS 0 // Excluir //"Excluir"

Return aRotina



Static Function ModelDef() 

Local oModel		:= Nil
Local oStruCab  	:= FWFormModelStruct():New()
Local oStruIt   	:= FWFormStruct(1, "G58") 
Local aRelation 	:= {} 
Local bLoadCab	    := {|oFieldModel| G046CabLoad(oFieldModel)}

G046Struct(@oStruCab,@oStruIt,"M")

oModel := MPFormModel():New('GTPA046',/*bPreValid*/, /*bPosValid*/,/* {|oMdl| G428Commit(oMdl)}*/, /*bCancel*/)

oModel:AddFields("CABMASTER", ,oStruCab,,,bLoadCab)

oModel:AddGrid("ITDETAIL", "CABMASTER", oStruIt, , , , ,)

aRelation	:= {{"G58_FILIAL","xFilial('G58')"},;
						{"G58_CODADM","CODIGO"}	,;
						{"G58_NATURE","NATUREZA"}	,;
						{"G58_CLIENT","CLIENT"},;	
						{"G58_LOJA","LOJA"}}
						
oModel:SetRelation( 'ITDETAIL', aRelation )

oModel:GetModel("ITDETAIL"):SetDescription(STR0006)  //"Bandeiras"


oModel:GetModel("CABMASTER"):SetOnlyQuery(.T.)
oModel:GetModel ("ITDETAIL"):SetOptional(.F.)
oModel:GetModel( 'ITDETAIL' ):SetUniqueLine( { 'G58_BAND' } )
	
oModel:GetModel("CABMASTER"):SetDescription(STR0007)  //"Administradoras"
	
oModel:SetDescription(STR0007)  //"Administradoras"
	
oModel:SetPrimaryKey({})
oModel:SetActivate({|oModel| GLoadIt(oModel)})	

Return(oModel)

Static Function ViewDef()

Local oModel		:= FWLoadModel("GTPA046")
Local oStruCab	    := FWFormViewStruct():New()
Local oStruIt   	:= FWFormStruct(2, "G58", {|cCampo|  !AllTrim(cCampo) $ "|G58_FILIAL|G58_CODADM|G58_DESCRI|G58_NATURE|G58_CLIENT|G58_LOJA|G58_NOMCLI|"}) 

oView := FWFormView():New()

G046Struct(@oStruCab,"V")

oView:SetModel(oModel)	

oView:SetDescription(STR0007) //"Administradoras"

oView:AddField("VIEW_CAB",oStruCab,"CABMASTER")
oView:AddGrid("V_ITEM"  ,oStruIt,"ITDETAIL")

oView:CreateHorizontalBox("CABECALHO" , 25) // Cabeçalho
oView:CreateHorizontalBox("BANDEIRAS" , 75) // 

oView:SetOwnerView( "VIEW_CAB", "CABECALHO")
oView:SetOwnerView( "V_ITEM", "BANDEIRAS")

Return(oView) 


Static Function G046Struct(oStruCab,oStruIt,cTipo)

If cTipo == "M"
	
	If ValType( oStruCab ) == "O"
	
		oStruCab:AddTable("   ",{" "}," ")
		oStruCab:AddField("FILIAL",;									// 	[01]  C   Titulo do campo // "Filial"
					 		"FILIAL",;									// 	[02]  C   ToolTip do campo // "Filial"
					 		"FILIAL",;							// 	[03]  C   Id do Field // "Filial"
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("G58_FILIAL")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
			
	    oStruCab:AddField(STR0008,;									// 	[01]  C   Titulo do campo   //"Administradora"
					 		STR0008,;									// 	[02]  C   ToolTip do campo  //"Administradora"
					 		"CODIGO",;							// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("G58_CODADM")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oModel,cCampo| VldBand(oModel,cCampo)    },;			// 	[07]  B   Code-block de validação do campo
					 		{|| INCLUI},;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual

		oStruCab:AddField("Descrição",;								// 	[01]  C   Titulo do campo // "Agência"
				 		    STR0009,;					// 	[02]  C   ToolTip do campo // "Código da Agência" //"Descrição"
					 		"DESCRI",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("AE_DESC")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		Nil,;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruCab:AddField("Natureza",;								// 	[01]  C   Titulo do campo // "Agência"
				 		    STR0010,;					// 	[02]  C   ToolTip do campo // "Código da Agência" //"Natureza"
					 		"NATUREZA",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("ED_CODIGO")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oModel,cCampo| VldBand(oModel,cCampo)    },;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
		
		oStruCab:AddField("Cliente",;								// 	[01]  C   Titulo do campo // "Agência"
				 		    STR0011,;					// 	[02]  C   ToolTip do campo // "Código da Agência" //"Cliente"
					 		"CLIENT",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("A1_COD")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oModel,cCampo| VldBand(oModel,cCampo)    },;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.T.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruCab:AddField("Loja",;								// 	[01]  C   Titulo do campo // "Agência"
				 		    STR0012,;					// 	[02]  C   ToolTip do campo // "Código da Agência" //"Loja"
					 		"LOJA",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("A1_LOJA")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oModel,cCampo| VldBand(oModel,cCampo)    },;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruCab:AddField(STR0013,;								// 	[01]  C   Titulo do campo // "Agência" //"Nome"
				 		    STR0013,;					// 	[02]  C   ToolTip do campo // "Código da Agência" //"Nome"
					 		"NOMCLI",;								// 	[03]  C   Id do Field
					 		"C",;									// 	[04]  C   Tipo do campo
					 		TAMSX3("A1_NOME")[1],;										// 	[05]  N   Tamanho do campo
					 		0,;										// 	[06]  N   Decimal do campo
					 		{|oModel,cCampo| VldBand(oModel,cCampo)    },;									// 	[07]  B   Code-block de validação do campo
					 		Nil,;									// 	[08]  B   Code-block de validação When do campo
					 		Nil,;									//	[09]  A   Lista de valores permitido do campo
					 		.F.,;									//	[10]  L   Indica se o campo tem preenchimento obrigatório
					 		Nil,;									//	[11]  B   Code-block de inicializacao do campo
					 		.F.,;									//	[12]  L   Indica se trata-se de um campo chave
					 		.F.,;									//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					 		.T.)									// 	[14]  L   Indica se o campo é virtual
					 		
		oStruCab:AddTrigger('CODIGO','DESCRI',{ || .T.}, { |oModel,cCampo,nValor|GTP046Gat(oModel,cCampo,nValor) } )
		oStruCab:AddTrigger('CLIENTE','NOMCLI',{ || .T.}, { |oModel,cCampo,nValor|GTP046Gat(oModel,cCampo,nValor) } )
		oStruCab:AddTrigger('LOJA','NOMCLI',{ || .T.}, { |oModel,cCampo,nValor|GTP046Gat(oModel,cCampo,nValor) } )	
	Endif
	If ValType( oStruIt ) == "O"
		oStruIt:AddTrigger('G58_BAND','G58_NOMBAN',{ || .T.}, { |oModel,cCampo,nValor| GTP046Gat(oModel,cCampo,nValor) } )
		oStruIt:SetProperty( "G58_BAND" , MODEL_FIELD_VALID , {|oModel,cCampo| VldBand(oModel,cCampo) } )
		
	Endif	
Else
	If ValType( oStruCab ) == "O"
	
			
			oStruCab:AddField(	"CODIGO",;				// [01]  C   Nome do Campo
		                        "02",;						// [02]  C   Ordem
		                        STR0008,;						// [03]  C   Titulo do campo // "Caixa" //"Administradora"
		                        STR0008,;						// [04]  C   Descricao do campo // "Caixa" //"Administradora"
		                        {STR0008},;					// [05]  A   Array com Help // "Selecionar" // "Caixa" //"Administradora"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "SAE",;						// [09]  C   Consulta F3
		                        .T.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
		
		    oStruCab:AddField(	"DESCRI",;				// [01]  C   Nome do Campo
		                        "03",;						// [02]  C   Ordem
		                        STR0009,;						// [03]  C   Titulo do campo // "Agência" //"Descrição"
		                        STR0009,;						// [04]  C   Descricao do campo // "Código da Agência" //"Descrição"
		                        {STR0009},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência" //"Descrição"
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
		                        
		      oStruCab:AddField(	"NATUREZA",;				// [01]  C   Nome do Campo
		                        "04",;						// [02]  C   Ordem
		                        STR0010,;						// [03]  C   Titulo do campo // "Agência" //"Natureza"
		                        STR0010,;						// [04]  C   Descricao do campo // "Código da Agência" //"Natureza"
		                        {STR0010},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência" //"Natureza"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "SED",;						// [09]  C   Consulta F3
		                        .T.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
		                        
		       oStruCab:AddField(	"CLIENT",;				// [01]  C   Nome do Campo
		                        "05",;						// [02]  C   Ordem
		                        STR0011,;						// [03]  C   Titulo do campo // "Agência" //"Cliente"
		                        STR0011,;						// [04]  C   Descricao do campo // "Código da Agência" //"Cliente"
		                        {STR0014},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência" //"Client"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
		                        NIL,;						// [08]  B   Bloco de Picture Var
		                        "SA1",;						// [09]  C   Consulta F3
		                        .T.,;						// [10]  L   Indica se o campo é alteravel
		                        NIL,;						// [11]  C   Pasta do campo
		                        "",;						// [12]  C   Agrupamento do campo
		                        NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
		                        NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
		                        NIL,;						// [15]  C   Inicializador de Browse
		                        .T.,;						// [16]  L   Indica se o campo é virtual
		                        NIL,;						// [17]  C   Picture Variavel
		                        .F.)						// [18]  L   Indica pulo de linha após o campo
		                  
		        oStruCab:AddField(	"LOJA",;				// [01]  C   Nome do Campo
		                        "06",;						// [02]  C   Ordem
		                        STR0012,;						// [03]  C   Titulo do campo // "Agência" //"Loja"
		                        STR0012,;						// [04]  C   Descricao do campo // "Código da Agência" //"Loja"
		                        {STR0012},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência" //"Loja"
		                        "GET",;					// [06]  C   Tipo do campo
		                        "",;						// [07]  C   Picture
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
		                        
		 oStruCab:AddField(	"NOMCLI",;				// [01]  C   Nome do Campo
		                        "07",;						// [02]  C   Ordem
		                        STR0013,;						// [03]  C   Titulo do campo // "Agência" //"Nome"
		                        STR0013,;						// [04]  C   Descricao do campo // "Código da Agência" //"Nome"
		                        {STR0013},;					// [05]  A   Array com Help // "Selecionar" // "Código da Agência" //"Nome"
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
/*/{Protheus.doc} G046CabLoad()

Função responsável pelo Load do Cabeçalho das Administradoras
 
@sample	G046CabLoad()
 
@return	
 
@author	SIGAGTP | Fernando Amorim(Cafu)
@since		03/10/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function G046CabLoad(oFieldModel)

Local aLoad 	:= {}
Local aCampos 	:= {}
Local aArea		:= GetArea()

aAdd(aCampos,xFilial("G58"))
aAdd(aCampos,G58->G58_CODADM)
aAdd(aCampos,Posicione("SAE",1,xFilial("SAE")+G58->G58_CODADM,"AE_DESC") )
aAdd(aCampos,G58->G58_NATURE)
aAdd(aCampos,G58->G58_CLIENT)
aAdd(aCampos,G58->G58_LOJA)
aAdd(aCampos,Posicione("SA1",1,xFilial("SA1")+G58->G58_CLIENT+G58->G58_LOJA,"A1_NOME"))
	
	Aadd(aLoad,aCampos)
Aadd(aLoad,G58->(Recno()))
	
RestArea(aArea)

Return aLoad
//-----------------------------------------------------------------------
Static Function GTP046Gat(oModel,cCampo,nValor)

Local xRet	 := 0

If cCampo == "CODIGO" .OR. cCampo == "G58_BAND"
	xRet := Posicione("SAE",1,xFilial("SAE")+oModel:GetValue(cCampo),"AE_DESC") 
ElseIf cCampo == "CLIENT" 
	xRet := Posicione("SA1",1,xFilial("SA1")+oModel:GetValue(cCampo)+ oModel:GetValue("LOJA"),"A1_NOME")
ElseIf cCampo == "LOJA" 
	xRet := Posicione("SA1",1,xFilial("SA1")+oModel:GetValue("CLIENT")+ oModel:GetValue(cCampo),"A1_NOME")		
Endif
	
Return xRet

Static Function VldBand(oModel, cCampo)
Local lRet			:= .T.
Local cAliasTMP		:= GetNextAlias()
Local cErro			:= ''
Local cSolucao		:= ''

If cCampo == "CODIGO"
	If (!ExistCpo("SAE", oModel:GetValue("CODIGO")))
		lRet			:= .F.	
		cErro			:= STR0015 //'Não existe esse codigo de Administradora'
		cSolucao		:= STR0016 //'Informe uma Administradora valida'
	Endif
	If lRet
		If Select(cAliasTMP) > 0
			(cAliasTMP)->(DbCloseArea())
		EndIf 
				
		BeginSql Alias cAliasTmp
			Select G58_CODADM
			From %Table:G58%
			Where
				G58_FILIAL = %xFilial:G58%
				and (G58_CODADM = %Exp:oModel:GetValue("CODIGO")% OR  G58_BAND = %Exp:oModel:GetValue("CODIGO")% )
				and %NotDel%
		EndSql
							
		If (cAliasTMP)->(!Eof())
			lRet			:= .F.	
			cErro			:= STR0017 //'Este codigo já existe'
			cSolucao		:= STR0018 //'Informe outro codigo para administradora'
		Endif
		If Select(cAliasTMP) > 0
			(cAliasTMP)->(DbCloseArea())
		EndIf
	Endif
ElseIf cCampo == "NATUREZA"
	If (!ExistCpo("SED", oModel:GetValue("NATUREZA")))
		lRet			:= .F.	
		cErro			:= STR0019 //'Não existe esse codigo de Natureza'
		cSolucao		:= STR0020 //'Informe uma Natureza valida'
	Endif
ElseIf cCampo == "LOJA"
	If (!ExistCpo("SA1", oModel:GetValue("CLIENT")+oModel:GetValue("LOJA")))
		lRet			:= .F.	
		cErro			:= STR0021 //'Não existe esse codigo de Cliente'
		cSolucao		:= STR0022 //'Informe uma cliente valida'
	Endif

ElseIf cCampo == "G58_BAND"
	If (!ExistCpo("SAE", oModel:GetValue("G58_BAND")))
		lRet			:= .F.	
		cErro			:= STR0015 //'Não existe esse codigo de Administradora'
		cSolucao		:= STR0016 //'Informe uma Administradora valida'
	Endif
	iF lRet
		If Select(cAliasTMP) > 0
			(cAliasTMP)->(DbCloseArea())
		EndIf 
				
		BeginSql Alias cAliasTmp
			Select G58_BAND
			From %Table:G58%
			Where
				G58_FILIAL = %xFilial:G58%
				and G58_BAND = %Exp:oModel:GetValue("G58_BAND")%
				and %NotDel%
		EndSql
							
		If (cAliasTMP)->(!Eof())
			lRet			:= .F.	
			cErro			:= STR0023 //'Esta bandeira já existe em amarração com outra administradora'
			cSolucao		:= STR0024 //'Informe outro codigo para bandeira'
		Endif
		If Select(cAliasTMP) > 0
			(cAliasTMP)->(DbCloseArea())
		EndIf 
	Endif
Endif
If !lRet
	oModel:GetModel():SetErrorMessage(oModel:GetId(),cCampo,oModel:GetId(),cCampo,"Valid",cErro,cSolucao)
Endif
Return lRet



Static Function GLoadIT(oModel)


oModel:GetModel("ITDETAIL"):FORCEValue("G58_NOMCLI",Posicione("SAE",1,xFilial("SAE")+oModel:GetModel("ITDETAIL"):GetValue("G58_BAND"),"AE_DESC"))

Return(.t.)
