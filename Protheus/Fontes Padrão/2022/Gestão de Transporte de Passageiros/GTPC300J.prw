#Include "GTPC300J.ch"
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'TOTVS.ch'

Function GTPC300J()
	Local aButtons      := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar" //"Fechar"
	FWExecView( STR0002, 'VIEWDEF.GTPC300J', MODEL_OPERATION_INSERT, , { || .T. },,,aButtons,/*{|| GC300EFech()} */)//"Alocação de Recursos" //"Consulta"

Return()



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

Local oView			:= FwLoadView('GTPC300E')
Local oModel		:= oView:GetModel() 

GC300JStruc(oView)	
Return(oView)

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
Static Function GC300JStruc(oView)
Local oStrCabView	:= oView:GetViewStruct('VW_GQEMASTER')
Local oStrGrdView	:= oView:GetViewStruct('VW_G55DETAIL')
Local aOrdem		:= {}

oStrCabView:RemoveField("GQE_RECURS")
oStrCabView:RemoveField("GQE_DRECUR")
oStrCabView:RemoveField("GQE_DTREF")
oStrGrdView:RemoveField("G55_SEQ")
oStrGrdView:RemoveField("G55_DESORI")
oStrGrdView:RemoveField("G55TPDIA")
oStrGrdView:RemoveField("G55TPESC")

oStrCabView:AddField("LOCALI",;				// [01]  C   Nome do Campo
				"01",;						// [02]  C   Ordem
				STR0003,;						// [03]  C   Titulo do campo //"Localidade"
				STR0003,;						// [04]  C   Descricao do campo //"Localidade"
				{STR0003},;					// [05]  A   Array com Help // "Selecionar" //"Localidade"
				"GET",;					// [06]  C   Tipo do campo
				"@!",;						// [07]  C   Picture
				NIL,;						// [08]  B   Bloco de Picture Var
				"GI1",;						// [09]  C   Consulta F3
				.T.,;						// [10]  L   Indica se o campo é alteravel
				NIL,;						// [11]  C   Pasta do campo
				"",;						// [12]  C   Agrupamento do campo
				NIL,;						// [13]  A   Lista de valores permitido do campo (Combo)
				NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
				NIL,;						// [15]  C   Inicializador de Browse
				.T.,;						// [16]  L   Indica se o campo é virtual
				NIL,;						// [17]  C   Picture Variavel
				.F.)						// [18]  L   Indica pulo de linha após o campo
				
oStrCabView:AddField("DESLOC",;				// [01]  C   Nome do Campo
				"02",;						// [02]  C   Ordem
				STR0004,;						// [03]  C   Titulo do campo //"Des. Local"
				STR0004,;						// [04]  C   Descricao do campo //"Des. Local"
				{STR0004},;					// [05]  A   Array com Help // "Selecionar" //"Des. Local"
				"GET",;					// [06]  C   Tipo do campo
				"@!",;						// [07]  C   Picture
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
				

aAdd(aOrdem,{"GQE_TRECUR","LOCALI"})
aAdd(aOrdem,{"LOCALI","DESLOC"})
aAdd(aOrdem,{"DESLOC","DTDE"})
aAdd(aOrdem,{"DTDE","DTATE"}) 

GTPOrdVwStruct(oStrCabView,aOrdem)		

oStrGrdView:AddField("G55_ALOC",;				// [01]  C   Nome do Campo
				"10",;						// [02]  C   Ordem
				STR0005,;						// [03]  C   Titulo do campo //"Alocado?"
				STR0005,;						// [04]  C   Descricao do campo //"Alocado?"
				{STR0006},;					// [05]  A   Array com Help // "Selecionar" //"Alocado"
				"GET",;					// [06]  C   Tipo do campo
				"@!",;						// [07]  C   Picture
				NIL,;						// [08]  B   Bloco de Picture Var
				"",;						// [09]  C   Consulta F3
				.F.,;						// [10]  L   Indica se o campo é alteravel
				NIL,;						// [11]  C   Pasta do campo
				"",;						// [12]  C   Agrupamento do campo
				{"1=Sim", "2=Não"},;						// [13]  A   Lista de valores permitido do campo (Combo)
				NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
				NIL,;						// [15]  C   Inicializador de Browse
				.T.,;						// [16]  L   Indica se o campo é virtual
				NIL,;						// [17]  C   Picture Variavel
				.F.)						// [18]  L   Indica pulo de linha após o campo
				
oStrGrdView:AddField("G55_RECUR",;				// [01]  C   Nome do Campo
				"10",;						// [02]  C   Ordem
				STR0007,;						// [03]  C   Titulo do campo //"Recurso"
				STR0007,;						// [04]  C   Descricao do campo //"Recurso"
				{STR0007},;					// [05]  A   Array com Help // "Selecionar" //"Recurso"
				"GET",;					// [06]  C   Tipo do campo
				"@!",;						// [07]  C   Picture
				NIL,;						// [08]  B   Bloco de Picture Var
				"",;						// [09]  C   Consulta F3
				.F.,;						// [10]  L   Indica se o campo é alteravel
				NIL,;						// [11]  C   Pasta do campo
				"",;						// [12]  C   Agrupamento do campo
				Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
				NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
				NIL,;						// [15]  C   Inicializador de Browse
				.T.,;						// [16]  L   Indica se o campo é virtual
				NIL,;						// [17]  C   Picture Variavel
				.F.)						// [18]  L   Indica pulo de linha após o campo

oStrGrdView:AddField("G55_DSCREC",;				// [01]  C   Nome do Campo
				"11",;						// [02]  C   Ordem
				STR0008,;						// [03]  C   Titulo do campo //"Des. Recur"
				STR0008,;						// [04]  C   Descricao do campo //"Des. Recur"
				{STR0008},;					// [05]  A   Array com Help // "Selecionar" //"Des. Recur"
				"GET",;					// [06]  C   Tipo do campo
				"@!",;						// [07]  C   Picture
				NIL,;						// [08]  B   Bloco de Picture Var
				"",;						// [09]  C   Consulta F3
				.F.,;						// [10]  L   Indica se o campo é alteravel
				NIL,;						// [11]  C   Pasta do campo
				"",;						// [12]  C   Agrupamento do campo
				Nil,;						// [13]  A   Lista de valores permitido do campo (Combo)
				NIL,;						// [14]  N   Tamanho maximo da maior opção do combo
				NIL,;						// [15]  C   Inicializador de Browse
				.T.,;						// [16]  L   Indica se o campo é virtual
				NIL,;						// [17]  C   Picture Variavel
				.F.)						// [18]  L   Indica pulo de linha após o campo
				

				
aOrdem	:= {}
aAdd(aOrdem,{"G55_ALOC","G55_RECUR"})
aAdd(aOrdem,{"G55_RECUR","G55_DSCREC"})
aAdd(aOrdem,{"G55_DSCREC","G55_CODVIA"})
aAdd(aOrdem,{"G55_CODVIA","G55_DTPART"}) 
aAdd(aOrdem,{"G55_DTPART","G55_HRINI"}) 
aAdd(aOrdem,{"G55_HRINI","G55_DTCHEG"}) 
aAdd(aOrdem,{"G55_DTCHEG","G55_HRFIM"}) 
aAdd(aOrdem,{"G55_HRFIM","G55_DESDES"})

GTPOrdVwStruct(oStrGrdView,aOrdem)	

Return
