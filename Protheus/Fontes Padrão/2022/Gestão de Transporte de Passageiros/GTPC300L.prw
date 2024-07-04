#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "GTPC300L.CH"

/*/{Protheus.doc} GTPC300L
Consulta Veiculos em manutenção por filial
@type function
@author jacomo.fernandes
@since 26/04/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300L()
	Local aButtons      := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0001},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Cancelar" //"Fechar"
	FWExecView( STR0002, 'VIEWDEF.GTPC300L', MODEL_OPERATION_INSERT, , { || .T. },,,aButtons,{|| GC300LFech()} )//"Alocação de Recursos" //"Consultas"
	
Return

/*/{Protheus.doc} ModelDef
Função responsavel pela criação do modelo de dados
@type function
@author jacomo.fernandes
@since 26/04/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= nil
Local oStrCab	:= FWFormModelStruct():New()
Local oStrGrd	:= FWFormStruct(1,"STJ")

ModelStruct(oStrCab,oStrGrd)

oModel := MPFormModel():New("GTPC300L")

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields("MASTER", , oStrCab)

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid("DETAIL", "MASTER", oStrGrd)

oModel:SetRelation("DETAIL", {{"TJ_FILIAL","xFilial('STJ')"}}, STJ->(IndexKey(1)))

oModel:SetDescription(STR0003)//"Alocações dos Recursos" //"Veiculos em Manutenção"
oModel:GetModel("MASTER"):SetDescription(STR0004)//"Recurso" //"Filtro"
oModel:GetModel("DETAIL"):SetDescription(STR0005)//"Alocações" //"Veiculos em Manutençã"

//Somente Leitura
oModel:GetModel("MASTER"):SetOnlyQuery(.T.)
oModel:GetModel("DETAIL"):SetOnlyQuery(.T.)

//Opcional
oModel:GetModel("DETAIL"):SetOptional(.t.)

//Bloqueia inserção e exclusão de linhas
oModel:GetModel('DETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('DETAIL'):SetNoUpdateLine(.T.)
oModel:GetModel('DETAIL'):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 26/04/2018
@version 1.0
@param oStrCab, objeto, (Descrição do parâmetro)
@param oStrGrd, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelStruct(oStrCab,oStrGrd)

oStrCab:AddTable("XXX", , "XXX_TABLE")
oStrCab:AddField(;
					STR0006				,;	// 	[01]  C   Titulo do campo	// "Filial" //"Data De"
					STR0006				,;	// 	[02]  C   ToolTip do campo	// "Filial" //"Data De"
					"DATADE"				,;	// 	[03]  C   Id do Field
					"D"						,;	// 	[04]  C   Tipo do campo
					8						,;	// 	[05]  N   Tamanho do campo
					0						,;	// 	[06]  N   Decimal do campo
					NIL						,;	// 	[07]  B   Code-block de validação do campo
					NIL 					,;	// 	[08]  B   Code-block de validação When do campo
					NIL						,;	//	[09]  A   Lista de valores permitido do campo
					.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{||dDataBase}			,;	//	[11]  B   Code-block de inicializacao do campo
					.F.						,;	//	[12]  L   Indica se trata-se de um campo chave
					.T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						;	// 	[14]  L   Indica se o campo é virtual
				)

oStrCab:AddField(;
					STR0007				,;	// 	[01]  C   Titulo do campo	// "Filial" //"Data Ate"
					STR0007				,;	// 	[02]  C   ToolTip do campo	// "Filial" //"Data Ate"
					"DATAATE"				,;	// 	[03]  C   Id do Field
					"D"						,;	// 	[04]  C   Tipo do campo
					8						,;	// 	[05]  N   Tamanho do campo
					0						,;	// 	[06]  N   Decimal do campo
					NIL						,;	// 	[07]  B   Code-block de validação do campo
					NIL 					,;	// 	[08]  B   Code-block de validação When do campo
					NIL						,;	//	[09]  A   Lista de valores permitido do campo
					.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{||dDataBase}			,;	//	[11]  B   Code-block de inicializacao do campo
					.F.						,;	//	[12]  L   Indica se trata-se de um campo chave
					.T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						;	// 	[14]  L   Indica se o campo é virtual
				)

oStrCab:AddField(;
					STR0008				,;	// 	[01]  C   Titulo do campo	// STR0008 //"Filial"
					STR0008				,;	// 	[02]  C   ToolTip do campo	// STR0008 //"Filial"
					"FILIAL"				,;	// 	[03]  C   Id do Field
					"C"						,;	// 	[04]  C   Tipo do campo
					FWSizeFilial()			,;	// 	[05]  N   Tamanho do campo
					0						,;	// 	[06]  N   Decimal do campo
					NIL						,;	// 	[07]  B   Code-block de validação do campo
					NIL 					,;	// 	[08]  B   Code-block de validação When do campo
					NIL						,;	//	[09]  A   Lista de valores permitido do campo
					.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{||xFilial('STJ')}		,;	//	[11]  B   Code-block de inicializacao do campo
					.F.						,;	//	[12]  L   Indica se trata-se de um campo chave
					.T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						;	// 	[14]  L   Indica se o campo é virtual
				)

oStrCab:AddField(;
					STR0009			,;	// 	[01]  C   Titulo do campo	// "Filial" //"Nome Filial"
					STR0009			,;	// 	[02]  C   ToolTip do campo	// "Filial" //"Nome Filial"
					"NOME_FILIAL"			,;	// 	[03]  C   Id do Field
					"C"						,;	// 	[04]  C   Tipo do campo
					50						,;	// 	[05]  N   Tamanho do campo
					0						,;	// 	[06]  N   Decimal do campo
					NIL						,;	// 	[07]  B   Code-block de validação do campo
					NIL 					,;	// 	[08]  B   Code-block de validação When do campo
					NIL						,;	//	[09]  A   Lista de valores permitido do campo
					.F.						,;	//	[10]  L   Indica se o campo tem preenchimento obrigatório
					{||FWFilialName(cEmpAnt,cFilAnt)}		,;	//	[11]  B   Code-block de inicializacao do campo
					.F.						,;	//	[12]  L   Indica se trata-se de um campo chave
					.T.						,;	//	[13]  L   Indica se o campo pode receber valor em uma operação de update.
					.T.						;	// 	[14]  L   Indica se o campo é virtual
				)
 
oStrCab:AddTrigger('FILIAL','NOME_FILIAL',{||.T.},{|oMdl,cField,xVal|FWFilialName(cEmpAnt,xVal)})
oStrCab:SetProperty("FILIAL"	, MODEL_FIELD_VALID	, {|oMdl,cField,cNewValue,cOldValue|FWFilExist(cEmpAnt,cNewValue) } )

oStrGrd:AddField('','','LEGENDA1','BT',1,,,,,,,,,.T.,)
oStrGrd:AddField('','','LEGENDA2','BT',1,,,,,,,,,.T.,)
oStrGrd:SetProperty("*"	, MODEL_FIELD_OBRIGAT	, .F.)

oStrGrd:SetProperty("*"			, MODEL_FIELD_INIT		, {||NIL})
oStrGrd:SetProperty("TJ_NOMBEM"	, MODEL_FIELD_TAMANHO	, TamSx3('T9_NOME')[1])
oStrGrd:SetProperty("TJ_NOMSERV", MODEL_FIELD_TAMANHO	, TamSx3('T4_NOME')[1])
oStrGrd:SetProperty("TJ_NOMTIPO", MODEL_FIELD_TAMANHO	, TamSx3('TE_NOME')[1])
oStrGrd:SetProperty("TJ_NOMAREA", MODEL_FIELD_TAMANHO	, TamSx3('TD_NOME')[1])

Return
/*/{Protheus.doc} ViewDef	
(long_description)
@type function
@author jacomo.fernandes
@since 26/04/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPC300L')
Local oStrCab	:= FWFormViewStruct():New()
Local oStrGrd	:= FWFormStruct(2,"STJ",{|x| ALLTRIM(x)+"|" $ "TJ_FILIAL|TJ_ORDEM|TJ_PLANO|TJ_DTORIGI|TJ_CODBEM|TJ_NOMBEM|TJ_SERVICO|TJ_NOMSERV|TJ_SEQRELA|TJ_TIPO|TJ_NOMTIPO|TJ_CODAREA|TJ_NOMAREA|TJ_POSCONT|TJ_DTPRINI|TJ_HOPRINI|TJ_DTPRFIM|TJ_HOPRFIM|TJ_DTMPINI|TJ_HOMPINI|TJ_DTMPFIM|TJ_HOMPFIM|TJ_DTMRINI|TJ_HOMRINI|TJ_DTMRFIM|TJ_HOMRFIM|"} )

ViewStruct(oStrCab,oStrGrd)

// Define qual o Modelo de dados será utilizado
oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_MASTER', oStrCab, 'MASTER')
oView:AddGrid('VIEW_DETAIL'	, oStrGrd, 'DETAIL')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('TOP', 20)
oView:CreateHorizontalBox('BOT', 80)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_MASTER', 'TOP')
oView:SetOwnerView('VIEW_DETAIL', 'BOT')

//habilita o filtro e a pesquisa
oView:SetViewProperty("DETAIL", "GRIDSEEK"		, {.T.})
oView:SetViewProperty("DETAIL", "GRIDFILTER"	, {.T.})

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView('VIEW_MASTER')
oView:EnableTitleView('VIEW_DETAIL')
		
//Adiciona Botoes (Items em Acoes Relacionadas)
oView:AddUserButton(STR0010,"",{|oView| G300LFiltro(oView) } ,,VK_F5) //STR0010 //"Executar Filtro"

oView:SetViewProperty("VIEW_DETAIL", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| GC300LDbClk(oGrid,cField,nLineGrid,nLineModel)}})

Return oView

/*/{Protheus.doc} ViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 26/04/2018
@version 1.0
@param oStrCab, objeto, (Descrição do parâmetro)
@param oStrGrd, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewStruct(oStrCab,oStrGrd)

oStrCab:AddField(;
					"DATADE"     ,;	// [01]  C   Nome do Campo
					"01"             ,;	// [02]  C   Ordem
					STR0006          ,;	// [03]  C   Titulo do campo		// "Ent. Adicional" //"Data De"
					STR0006		,;	// [04]  C   Descricao do campo		// "Ent. Adicional" //"Data De"
					{""}			,;	// [05]  A   Array com Help			// "Informe o Código de Entidade Adicional do Cliente."
					"D"              ,;	// [06]  C   Tipo do campo
					"@D"             ,;	// [07]  C   Picture
					NIL              ,;	// [08]  B   Bloco de Picture Var
					""		         ,;	// [09]  C   Consulta F3
					.T.              ,;	// [10]  L   Indica se o campo é alteravel
					NIL              ,;	// [11]  C   Pasta do campo
					NIL              ,;	// [12]  C   Agrupamento do campo
					NIL              ,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL              ,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL              ,;	// [15]  C   Inicializador de Browse
					.T.              ,;	// [16]  L   Indica se o campo é virtual
					NIL              ,;	// [17]  C   Picture Variavel
					.F.	            ;	// [18]  L   Indica pulo de linha após o campo
				)

oStrCab:AddField(;
					"DATAATE"     ,;	// [01]  C   Nome do Campo
					"02"             ,;	// [02]  C   Ordem
					STR0007       ,;	// [03]  C   Titulo do campo		// "Ent. Adicional" //"Data Ate"
					STR0007		,;	// [04]  C   Descricao do campo		// "Ent. Adicional" //"Data Ate"
					{""}			,;	// [05]  A   Array com Help			// "Informe o Código de Entidade Adicional do Cliente."
					"D"              ,;	// [06]  C   Tipo do campo
					"@D"             ,;	// [07]  C   Picture
					NIL              ,;	// [08]  B   Bloco de Picture Var
					""		         ,;	// [09]  C   Consulta F3
					.T.              ,;	// [10]  L   Indica se o campo é alteravel
					NIL              ,;	// [11]  C   Pasta do campo
					NIL              ,;	// [12]  C   Agrupamento do campo
					NIL              ,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL              ,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL              ,;	// [15]  C   Inicializador de Browse
					.T.              ,;	// [16]  L   Indica se o campo é virtual
					NIL              ,;	// [17]  C   Picture Variavel
					.F.	            ;	// [18]  L   Indica pulo de linha após o campo
				)
oStrCab:AddField(;
					"FILIAL"     ,;	// [01]  C   Nome do Campo
					"03"             ,;	// [02]  C   Ordem
					STR0008       ,;	// [03]  C   Titulo do campo		// "Ent. Adicional" //"Filial"
					STR0008		,;	// [04]  C   Descricao do campo		// "Ent. Adicional" //"Filial"
					{""}			,;	// [05]  A   Array com Help			// "Informe o Código de Entidade Adicional do Cliente."
					"C"              ,;	// [06]  C   Tipo do campo
					""             ,;	// [07]  C   Picture
					NIL              ,;	// [08]  B   Bloco de Picture Var
					"SM0"		         ,;	// [09]  C   Consulta F3
					.T.              ,;	// [10]  L   Indica se o campo é alteravel
					NIL              ,;	// [11]  C   Pasta do campo
					NIL              ,;	// [12]  C   Agrupamento do campo
					NIL              ,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL              ,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL              ,;	// [15]  C   Inicializador de Browse
					.T.              ,;	// [16]  L   Indica se o campo é virtual
					NIL              ,;	// [17]  C   Picture Variavel
					.F.	            ;	// [18]  L   Indica pulo de linha após o campo
				)

oStrCab:AddField(;
					"NOME_FILIAL"     ,;	// [01]  C   Nome do Campo
					"04"             ,;	// [02]  C   Ordem
					STR0009       ,;	// [03]  C   Titulo do campo		// "Ent. Adicional" //"Nome Filial"
					STR0009		,;	// [04]  C   Descricao do campo		// "Ent. Adicional" //"Nome Filial"
					{""}			,;	// [05]  A   Array com Help			// "Informe o Código de Entidade Adicional do Cliente."
					"C"              ,;	// [06]  C   Tipo do campo
					""             ,;	// [07]  C   Picture
					NIL              ,;	// [08]  B   Bloco de Picture Var
					""		         ,;	// [09]  C   Consulta F3
					.F.              ,;	// [10]  L   Indica se o campo é alteravel
					NIL              ,;	// [11]  C   Pasta do campo
					NIL              ,;	// [12]  C   Agrupamento do campo
					NIL              ,;	// [13]  A   Lista de valores permitido do campo (Combo)
					NIL              ,;	// [14]  N   Tamanho maximo da maior opção do combo
					NIL              ,;	// [15]  C   Inicializador de Browse
					.T.              ,;	// [16]  L   Indica se o campo é virtual
					NIL              ,;	// [17]  C   Picture Variavel
					.F.	            ;	// [18]  L   Indica pulo de linha após o campo
				)

oStrGrd:AddField("LEGENDA1","00","","",{},"BT","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)
oStrGrd:AddField("LEGENDA2","01","","",{},"BT","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)

Return

/*/{Protheus.doc} GC300LFech
(long_description)
@type function
@author jacomo.fernandes
@since 26/04/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GC300LFech() 

Local oView	:= FwViewActive()
		
oView:SetModified(.f.)
	
Return(.t.)


/*/{Protheus.doc} G300LFiltro
Função Responsavel pelo filtro dos veiculos em manutenção
@type function
@author jacomo.fernandes
@since 26/04/2018
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function G300LFiltro(oView)
Local oModel	:= oView:GetModel()
Local oMdlCab	:= oModel:GetModel('MASTER')
Local oMdlGrd	:= oModel:GetModel('DETAIL')
Local oStruGrd	:= oMdlGrd:GetStruct() 
Local cTmpAlias	:= GetNextAlias()
Local aField	:= nil 
Local nI		:= 0

oMdlGrd:ClearData()
	
BeginSql Alias cTmpAlias
	SELECT
		(Case
			WHEN TJ_TERMINO = 'S' THEN 'BR_VERDE'
			WHEN TJ_TERMINO = 'N' THEN 'BR_VERMELHO'
			ELSE ''
		End)AS LEGENDA1,
		(Case
			WHEN TJ_SITUACA = 'L' THEN 'BR_VERDE'
			WHEN TJ_SITUACA = 'P' THEN 'BR_VERMELHO'
			WHEN TJ_SITUACA = 'C' THEN 'BR_PRETO'
			ELSE ''
		End)AS LEGENDA2,
		STJ.TJ_FILIAL,
		STJ.TJ_ORDEM,
		STJ.TJ_PLANO,
		STJ.TJ_DTORIGI,
		STJ.TJ_CODBEM,
		ST9.T9_NOME AS TJ_NOMBEM,
		STJ.TJ_SERVICO,
		ST4.T4_NOME AS TJ_NOMSERV,
		STJ.TJ_SEQRELA,
		STJ.TJ_TIPO,
		STE.TE_NOME AS TJ_NOMTIPO,
		STJ.TJ_CODAREA,
		STD.TD_NOME AS TJ_NOMAREA,
		STJ.TJ_POSCONT,
		STJ.TJ_DTPRINI,
		STJ.TJ_HOPRINI,
		STJ.TJ_DTPRFIM,
		STJ.TJ_HOPRFIM,
		STJ.TJ_DTMPINI,
		STJ.TJ_HOMPINI,
		STJ.TJ_DTMPFIM,
		STJ.TJ_HOMPFIM,
		STJ.TJ_DTMRINI,
		STJ.TJ_HOMRINI,
		STJ.TJ_DTMRFIM,
		STJ.TJ_HOMRFIM
	
	
	FROM %Table:STJ% STJ
		INNER JOIN %Table:ST9% ST9 ON
			ST9.T9_FILIAL = %xFilial:ST9%
			AND ST9.T9_CODBEM = TJ_CODBEM
			AND ST9.%NotDel%
		INNER JOIN %Table:ST4% ST4 ON
			ST4.T4_FILIAL = %xFilial:ST4%
			AND T4_SERVICO = STJ.TJ_SERVICO
			AND ST4.%NotDel%
		INNER JOIN %Table:STE% STE ON
			STE.TE_FILIAL = %xFilial:STE%
			AND STE.TE_TIPOMAN = STJ.TJ_TIPO
			AND STE.%NotDel%
		INNER JOIN %Table:STD% STD ON
			STD.TD_FILIAL = %xFilial:STD%
			AND STD.TD_CODAREA = STJ.TJ_CODAREA
			AND STD.%NotDel%
	WHERE 
		STJ.TJ_FILIAL = %Exp:oMdlCab:GetValue('FILIAL')%
		AND TJ_TIPOOS = 'B'
		AND (
				(	
					(TJ_DTPRINI>= %Exp:DtoS(oMdlCab:GetValue('DATADE'))% AND TJ_DTPRFIM <= %Exp:DtoS(oMdlCab:GetValue('DATAATE'))%)
					OR
					(%Exp:DtoS(oMdlCab:GetValue('DATADE'))% BETWEEN TJ_DTPRINI AND TJ_DTPRFIM)
					OR
					(%Exp:DtoS(oMdlCab:GetValue('DATAATE'))% BETWEEN TJ_DTPRINI AND TJ_DTPRFIM)
				)
				OR
				(	
					(TJ_DTMPINI>= %Exp:DtoS(oMdlCab:GetValue('DATADE'))% AND TJ_DTMPFIM <= %Exp:DtoS(oMdlCab:GetValue('DATAATE'))%)
					OR
					(%Exp:DtoS(oMdlCab:GetValue('DATADE'))% BETWEEN TJ_DTMPINI AND TJ_DTMPFIM)
					OR
					(%Exp:DtoS(oMdlCab:GetValue('DATAATE'))% BETWEEN TJ_DTMPINI AND TJ_DTMPFIM)
				)
				OR
				(	
					(TJ_DTMRINI>= %Exp:DtoS(oMdlCab:GetValue('DATADE'))% AND TJ_DTMRFIM <= %Exp:DtoS(oMdlCab:GetValue('DATAATE'))%)
					OR
					(%Exp:DtoS(oMdlCab:GetValue('DATADE'))% BETWEEN TJ_DTMRINI AND TJ_DTMRFIM)
					OR
					(%Exp:DtoS(oMdlCab:GetValue('DATAATE'))% BETWEEN TJ_DTMRINI AND TJ_DTMRFIM)
				)
			)
		AND STJ.%NotDel%
		
	ORDER BY STJ.TJ_DTPRINI,STJ.TJ_HOPRINI
EndSql

//Desbloqueia inserção e exclusão de linhas
oMdlGrd:SetNoInsertLine(.F.)
oMdlGrd:SetNoUpdateLine(.F.)
oMdlGrd:SetNoDeleteLine(.F.)
lRet:= .T.
aField := (cTmpAlias)->(DbStruct())
While (cTmpAlias)->(!EoF())
	If !oMdlGrd:IsEmpty()
		 oMdlGrd:AddLine()
	EndIf
	For nI := 1 to Len(aField)
		If ( oStruGrd:HasField(aField[nI][1]) )
			If aField[nI][1] <> 'LEGENDA1' .AND. aField[nI][1] <> 'LEGENDA2'  
				lRet := oMdlGrd:LoadValue(aField[nI][1],GTPCastType((cTmpAlias)->&(aField[nI][1]),TamSx3(aField[nI][1])[3]))
			Else
				lRet := oMdlGrd:LoadValue(aField[nI][1],(cTmpAlias)->&(aField[nI][1]))
			Endif
		EndIf
	Next
	(cTmpAlias)->(DbSkip())
	
EndDo

(cTmpAlias)->(DbCloseArea())

oMdlGrd:GoLine(1)

//Bloqueia inserção e exclusão de linhas
oMdlGrd:SetNoInsertLine(.T.)
oMdlGrd:SetNoUpdateLine(.T.)
oMdlGrd:SetNoDeleteLine(.T.)

oView:Refresh()

GTPDestroy(aField)

Return

Static Function GC300LDbClk(oView,cField,nLineGrid,nLineModel)
If  "LEGENDA" $ cField
	GC300Legend(oView,cField)	
Endif
Return

Static Function GC300Legend(oView,cField)

Local oLegenda		:= FWLegend():New()
Local oModel		:= oView:GetModel()
Local oMdlAux		:= oModel:GetModel("DETAIL")
Local aLegend		:= {}
Local n1			:= 0

	If cField == 'LEGENDA1'
		aAdd(aLegend,{{|| oMdlAux:GetValue(cField) == "BR_VERDE"	} ,"BR_VERDE"		, STR0011		}) //"Terminado"
		aAdd(aLegend,{{|| oMdlAux:GetValue(cField) == "BR_VERMELHO"	} ,"BR_VERMELHO"	, STR0012	}) //"Não Terminado"
		
	Else
		aAdd(aLegend,{{|| oMdlAux:GetValue(cField) == "BR_VERDE"	} ,"BR_VERDE"		, STR0013	}) //"Liberado"
		aAdd(aLegend,{{|| oMdlAux:GetValue(cField) == "BR_VERMELHO"	} ,"BR_VERMELHO"	, STR0014	}) //"Pendente"
		aAdd(aLegend,{{|| oMdlAux:GetValue(cField) == "BR_PRETO"	} ,"BR_PRETO"		, STR0015	}) //"Cancelado"
		
	Endif

For n1 := 1 To Len(aLegend)
	oLegenda:Add(aLegend[n1][1]	,aLegend[n1][2]		,aLegend[n1][3])
Next

oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

GTPDestroy(oLegenda) //Destroi o objeto
GTPDestroy(aLegend)	//Destroi o array
Return
