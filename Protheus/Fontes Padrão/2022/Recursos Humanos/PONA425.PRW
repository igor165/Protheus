#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONA425.CH"


/*/{Protheus.doc} PONA425
Cadastro de escala de horas de sobreaviso
@type Function
@author Cícero Alves
@since 05/10/2020
@see (links_or_references)
/*/
Function PONA425()
	
	Local oBrowseSRA := FWmBrowse():New()

	If !ChkFile("RRS")
		Help( " ", 1, OemToAnsi( STR0039 ),, OemToAnsi( STR0040 ), 1, 0 ) //"Tabela RRS não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."##"Fechar"
		Return
	EndIf

	oBrowseSRA:SetAlias("SRA")
	oBrowseSRA:SetDescription(STR0029)	// Sobreaviso
	oBrowseSRA:DisableDetails()
	GpLegMVC(@oBrowseSRA)
	
	oBrowseSRA:Activate()
	
Return

/*/{Protheus.doc} MenuDef
Cria as opções de menu da rotina
@type Static Function
@author Cícero Alves
@since 05/10/2020
@return aRotina, Array, Opções do menu da rotina
/*/
Static Function MenuDef(param_name)
	
	Local aRotina := {} 
	
	ADD OPTION aRotina TITLE STR0002 ACTION "ViewDef.PONA425" OPERATION 4 ACCESS 0 	// Manutenção
	ADD OPTION aRotina TITLE STR0003 ACTION "Lote425()" OPERATION 4 ACCESS 0		// Inclusão em Lote
	ADD OPTION aRotina TITLE STR0004 ACTION "ViewDef.PONA425" OPERATION 5 ACCESS 0	// Excluir
	ADD OPTION aRotina TITLE STR0005 ACTION "ViewDef.PONA425" OPERATION 2 ACCESS 0	// Visualizar
	
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de dados utilizado na rotina
@type Static Function
@author Cícero Alves
@since 05/10/2020
@return oModel, Objeto, Instância da classe MPFormModel com as definicões da rotina
/*/
Static Function ModelDef()
	
	Local oModel 	:= MPFormModel():New( 'PONA425', ,{|oModel| VdlPos(oModel)} )
	Local oStruSRA 	:= FWFormStruct( 1, "SRA",  { |cCampo| AllTrim(cCampo) $ "RA_MAT|RA_NOME" })
	Local oStruRRS 	:= FWFormStruct( 1, "RRS")

	oStruRRS:SetProperty( "RRS_HRINI", MODEL_FIELD_OBRIGAT, .F. )
	oStruRRS:SetProperty( "RRS_HRINI", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,"VldHora(M->RRS_HRINI)"))
	oStruRRS:SetProperty( "RRS_HRFIM", MODEL_FIELD_OBRIGAT, .F. )
	oStruRRS:SetProperty( "RRS_HRFIM", MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID,"VldHora(M->RRS_HRFIM)"))
	
	oModel:AddFields("PONA425_MSRA", NIL, oStruSRA )
	oModel:GetModel("PONA425_MSRA" ):SetDescription( STR0001 ) // Funcionários
	oModel:GetModel("PONA425_MSRA"):SetOnlyQuery(.T.)
	oModel:GetModel("PONA425_MSRA"):SetOnlyView(.T.)
	
	oStruRRS:SetProperty( 'RRS_MAT' , MODEL_FIELD_INIT, {|| SRA->RA_MAT})
	
	oModel:AddGrid( 'PONA425_MRRS', 'PONA425_MSRA', oStruRRS, , { |oModelGrid, nLine | LinhaOK(oModelGrid, nLine) } )
	oModel:SetRelation( "PONA425_MRRS", {{ "RRS_FILIAL", "SRA->RA_FILIAL" }, { "RRS_MAT", "SRA->RA_MAT" }}, RRS->( IndexKey( 1 )))
	oModel:GetModel("PONA425_MRRS" ):SetOptional( .T. )
	oModel:GetModel("PONA425_MRRS" ):SetDescription( STR0006 ) // Horas de Sobreaviso
	oModel:GetModel("PONA425_MRRS"):SetUniqueLine({"RRS_FILIAL", "RRS_MAT", "RRS_DTINI", "RRS_HRINI", "RRS_DIAS"})
	
Return oModel

/*/{Protheus.doc} ViewDef
Definição dos componentes visuais da rotina
@type Static Function
@author Cícero Alves
@since 05/10/2020
@version version
@return oView, Objeto, Instância da classe FWFormView com os componentes visuais utilizados na rotina
/*/
Static Function ViewDef()
	
	Local oModel 	:= FWLoadModel("PONA425")
	Local oView 	:= FWFormView():New()
	Local oStruSRA 	:= FWFormStruct( 2, "SRA",  { |cCampo| AllTrim(cCampo) $ "RA_MAT|RA_NOME" })
	Local oStruRRS 	:= FWFormStruct( 2, "RRS" )
	
	oView:SetModel(oModel)
	
	oStruSRA:SetNoFolder()
	
	oView:AddField("PONA425_VSRA", oStruSRA, "PONA425_MSRA" )
	
	oStruRRS:RemoveField( "RRS_MAT" )
	oView:AddGrid("PONA425_VRRS", oStruRRS, "PONA425_MRRS" )
	
	oView:EnableTitleView('PONA425_VRRS')
	
	oView:CreateHorizontalBox("SRA_HEAD", 10)
	oView:CreateHorizontalBox("RRS_GRID", 90)
	
	oView:SetOwnerView( "PONA425_VSRA", "SRA_HEAD" )
	oView:SetOwnerView( "PONA425_VRRS", "RRS_GRID" )
	
Return oView

/*/{Protheus.doc} fDiasOpc
Apresenta uma tela para a seleção dos dias da semana
@type  Function
@author Cícero Alves
@since 06/10/2020
@param lValid, Lógico, Indica se a chamada da função veio de uma validação de campo
@return cDias, Caracter, Dias da semana selecionados, quando chamado pelo F3
/*/
Function fDiasOpc(lValid)
	
	Local cOpcoes	:= "2345671"
	Local aDiasSem	:= {STR0008, STR0009, STR0010, STR0011, STR0012, STR0013, STR0007 } // Segunda, Terça, Quarta, Quinta, Sexta, Sábado, Domingo
	
	Local cDias 	:= &(ReadVar())
	
	Default lValid := .F.
	
	f_Opcoes(	@cDias		,;	//Variavel de Retorno
				STR0014		,;	//Titulo da Coluna com as opcoes # "Dias da semana"
				aDiasSem	,;	//Opcoes de Escolha (Array de Opcoes)
				cOpcoes		,;	//String de Opcoes para Retorno
				NIL			,;	//Nao Utilizado
				NIL			,;	//Nao Utilizado
				.F.			,;	//Se a Selecao sera de apenas 1 Elemento por vez
				1			,;	//Tamanho da Chave
				7			,;	//No maximo de elementos na variavel de retorno
				.T.			,;	//Inclui Botoes para Selecao de Multiplos Itens
				.F.			,;	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
				NIL			,;	//Qual o Campo para a Montagem do aOpcoes
				.T.			,;	//Nao Permite a Ordenacao
				.T.			,;	//Nao Permite a Pesquisa
				.F.   		,;	//Forca o Retorno Como Array
				NIL			 ;	//Consulta F3
			)
	
	cDias := StrTran(cDias, "*", "0")
	
	If lValid
		&(ReadVar()) := cDias
		Return
	EndIf
	
Return cDias

/*/{Protheus.doc} VldDiaSem
Verifica se a informação do campo RRS_DIAS é válida
@type  Function
@author Cícero Alves
@since 06/10/2020
@param cDias, Caracter, Conteúdo do campo RRS_DIAS
@return lRet, Lógico, Indica se o conteúdo é válido
/*/
Function VldDiaSem(cDias)
	
	Local lRet := .T.
	Local nI
	
	cDias := AllTrim(cDias)
	
	If Val(cDias) == 0
		lRet := .F.
	Else
		For nI := 1 To Len(cDias)
			If !IsDigit(SubStr(cDias, nI, 1)) .Or. Val(SubStr(cDias, nI, 1)) > 7 
				lRet := .F.
				EXIT
			EndIf
		Next
	EndIf
	
	If !lRet
		// Dia Inválido. Informe ou selecione os dias da semana.
		// "Informe ou selecione os números referentes aos dias da semana. Em que o funcionário irá realizar as horas de sobreaviso"
		Help( ,, "Help", , STR0015, 1, 0,,,,,, {STR0016} )
	EndIf
	
Return lRet

/*/{Protheus.doc} Lote425
Realiza a inclusão em lote da programação de horas de sobreaviso
@type Function
@author Cícero Alves
@since 07/10/2020
@version version
@return return_var, return_type, return_description
@see (links_or_references)
/*/
Function Lote425()
	
	Local cAliasTemp 	:= GetNextAlias()
	Local cWhere		:= ""
	Local cPerg			:= "PONA425"
	Local aErro			:= {}
	local aLogOK		:= {}
	Local oModel
	Local oGrid
	
	Private aLog := {}
	Private aLogTitulo := {}
	
	Static lShowMsg	:= .T.
	Static lLog := .F.
	
	If Pergunte(cPerg, !IsBlind()) .And. ValidPerg()
		
		cWhere := GetWhere()
		
		BeginSQL Alias cAliasTemp
			SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.R_E_C_N_O_ AS RECNO
			FROM %Table:SRA% SRA
			WHERE %Exp:cWhere%
			AND SRA.%NotDel%
		EndSQL
		
		If(cAliasTemp)->(!EoF())
			
			dbSelectArea("SRA")
			
			While (cAliasTemp)->(!EoF())
				
				SRA->(dbGoTo((cAliasTemp)->RECNO))
				
				oModel := FWLoadModel("PONA425")
				oModel:SetOperation(MODEL_OPERATION_UPDATE)
				oModel:Activate()
				
				oGrid := oModel:GetModel("PONA425_MRRS")
				
				oGrid:AddLine()
				
				oGrid:SetValue("RRS_DTINI", MV_PAR05)	// Data Inicial
				oGrid:SetValue("RRS_DTFIM", MV_PAR06)	// Data Final
				oGrid:SetValue("RRS_HRINI", MV_PAR07)	// Hora Inicial
				oGrid:SetValue("RRS_HRFIM", MV_PAR08)	// Hora Final
				oGrid:SetValue("RRS_DIAS" , MV_PAR09)	// Dias da Semana
				
				lShowMsg := .F.
				lLog := .T.
				If oModel:VldData()
					oModel:CommitData()
					aAdd(aLogOK, STR0037 + SRA->RA_FILIAL + " - " + STR0038 + SRA->RA_MAT)
				Else
					aErro := oModel:GetErrorMessage()
					aAdd(aLogTitulo, STR0017) // Funcionário não Processado
					aAdd(aLog, {STR0018 +": " + SRA->RA_FILIAL + " - " + SRA->RA_MAT})
					If Len(aErro) > 6 .And. ! Empty(aErro[6]) 
						aAdd(aLog, {aErro[6]})
					EndIf 
				EndIf
				
				oModel:DeActivate()
				oModel:Destroy()
				oModel := NIL
				oGrid := NIL
				
				(cAliasTemp)->(dbSkip())
				
			EndDo
		Else
			aAdd(aLogTitulo, STR0019) // Nenhum registro encontrado
			aAdd(aLog, {STR0020}) // Verifique as informações de filtro nas perguntas da rotina.
		EndIf
		
		(cAliasTemp)->(dbCloseArea())
	EndIf
	
	If Len(aLogOK) > 0
		aAdd(aLogTitulo, STR0036 ) // "Incluído com sucesso para os Funcionários abaixo:"
		aAdd(aLog, aLogOK)
	EndIf
	
	fMakeLog( aLog, aLogTitulo, cPerg,,,,, "P")
	
Return

/*/{Protheus.doc} GetWhere
Monta a cláusula where para a busca dos funcionários utilizando as perguntas da rotina
@type  Static Function
@author Cícero Alves
@since 07/10/2020
@return cWhere, Caracter, Cláusula where em SQL
/*/
Static Function GetWhere()
	
	Local cWhere := ""
	
	// Categorias
	MV_PAR04 := Separa(MV_PAR04, 1, .T.)
	MV_PAR04 := If(Empty(MV_PAR04), "*", MV_PAR04)
	
	MakeSqlExp("PONA425")
	
	cWhere := MV_PAR04 // Categorias
	cWhere += If(!Empty(MV_PAR01), " AND " + MV_PAR01, "") // Filiais
	cWhere += If(!Empty(MV_PAR02), " AND " + MV_PAR02, "") // Matrículas
	cWhere += If(!Empty(MV_PAR03), " AND " + MV_PAR03, "") // Turnos
	
	cWhere := "%" + cWhere + "%" 
	
Return cWhere

/*/{Protheus.doc} ValidPer
Valida se as informações necessárias foram informadas para a inclusão em lote
@type  Static Function
@author Cícero Alves
@since 08/10/2020
@version version
@return lValido, Lógico, Define se as informações são válidas
/*/
Static Function ValidPerg()
	
	Local lValido := .T.
	
	If Empty(MV_PAR05) 
		lValido := .F.
		aAdd(aLogTitulo, STR0021) // Data Inicio não informada
		aAdd(aLog, {STR0022}) // É necessário informar a data inicial da programação de sobreaviso.
	EndIf
	
	If Empty(MV_PAR07) .Or. Empty(MV_PAR08)
		lValido := .F.
		aAdd(aLogTitulo, STR0023) // "Horário não expecificado"
		aAdd(aLog, {STR0024}) // É necessário informar a Hora Inicial e a Hora Final do sobreaviso.
	EndIf
	
	If Empty(MV_PAR07)
		lValido := .F.
		aAdd(aLogTitulo, STR0025) // Dias não informados
		aAdd(aLog, {STR0026}) // É necessário informar em quais dias da semana o sobreaviso será realizado.
	EndIf
	
Return lValido

/*/{Protheus.doc} Separa
Inclui um separador entre os caracteres de um texto
@type  Static Function
@author Cícero Alves
@since 07/10/2020
@param cTexto, Caractere, Texto que serÃ¡ alterado
@param nCaracter, Numérico, Frequência para inclusão do separador
@param lAspas, Lógico, Indica se inclui aspas simples 
@return cSeparado, Caractere, cTexto com o separador incluído na frequência indicada
@example Separa("123456789", 3, .T.) => "'123';'456';'789'"
/*/
Static Function Separa(cTexto, nCaracter, lAspas)
	
	Local cSeparado := ""
	Local cPedaco	:= ""
	Local nI
	
	For nI := 1 To Len(RTrim(cTexto)) STEP nCaracter
		If AllTrim((cPedaco := SubStr( cTexto, nI, nCaracter))) != "*"
			If lAspas
				cSeparado += "'" + cPedaco + "';"
			Else
				cSeparado += cPedaco + ";"
			EndIf
		EndIf
	Next
	
	// Reitra o último caracter
	cSeparado := Left(cSeparado, Len(cSeparado) - 1)
	
Return cSeparado

/*/{Protheus.doc} VdlPos
Realiza a validação das informações antes da gravação
@type  Static Function
@author Cícero Alves
@since 08/10/2020
@version version
@param oModel, Objeto, Modelo da rotina, definido na função ModelDef
@return lValido, Lógico, Indica se as informações do modelo são válidas
/*/
Static Function VdlPos(oModel)
	
	Local lValido := .T.
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .And. ! IsBlind() .And. lShowMsg
		// Só serão apontadas como Horas de Sobreaviso o período cadastrado nesta rotina que estiver fora da jornada padrão do funcionário. # Atenção
		MsgAlert(STR0027, STR0028)
	EndIf
	
	
Return lValido

/*/{Protheus.doc} LinhaOK
(long_description)
@type  Static Function
@author user
@since 08/10/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function LinhaOK(oGrid, nLinha)
	
	Local lRet		:= .T.
	Local nI, nJ	:= 0
	Local cChaveAtu := dToS(oGrid:GetValue("RRS_DTINI")) + Str(oGrid:GetValue("RRS_HRINI"))
	Local cDias		:=  oGrid:GetValue("RRS_DIAS")
	Local cChave	:= ""
	
	For nI := 1 To oGrid:Length()
		oGrid:GoLine(nI)
		
		If nI != nLinha .And. ! oGrid:IsDeleted()
			cChave := dToS(oGrid:GetValue("RRS_DTINI")) + Str(oGrid:GetValue("RRS_HRINI"))
			If cChave == cChaveAtu
				For nJ := 1 To Len(cDias) 
					If(SubStr(cDias, nJ, 1) $ oGrid:GetValue("RRS_DIAS"))
						lRet := .F.
						If lShowMsg
							// "Linha Duplicada" # "As informações já estão presentes na linha " # "Revise as datas, horários ou dias da semana."
							Help( ,, STR0030, , STR0031 + Str(nI), 1, 0,,,,,, {STR0032} )
						ElseIf lLog
							aAdd(aLogTitulo, STR0033) // "Informações já cadastradas"
							// "O registro não foi inserido para o funcionário " # ". já consta um cadastro com as mesmas informações."
							aAdd(aLog, {STR0034 + SRA->RA_FILIAL + " - " + SRA->RA_MAT + STR0035})
						EndIf
						EXIT
					EndIf
				Next	
			EndIf
		EndIf
	Next
	
Return lRet
