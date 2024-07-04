#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE TOTVS "TOTVS"
#DEFINE CAMPO   01
#DEFINE TIPO    02
#DEFINE TAMANHO 03
#DEFINE DECIMAL 04

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das opções do menu

@author vinicius.nicolau
@since 12/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local cRotCmpAns 	:= 'PLSSIBESP( Val( (oTmpTab:getAlias())->B3F_CHVORI ) )'
	Local cRotDifCnx 	:= 'PLSB3KB3W( Val( (oTmpTab:getAlias())->B3F_CHVORI ), .F.)'
	Local cRotAtu		:= 'Processa( { || CenAtuImp(oMark) },"Atualizando registros","Processando...",.F.)'
	Local cAtviv		:= 'Processa( { || CenAtuImp(oMark,"1") },"Selecionando Ativos na Central de Obrigações","Processando...",.F.)'
	Local cBlque		:= 'Processa( { || CenAtuImp(oMark,"2") },"Selecionando bloqueados na central de obrigações independente do seu status na ANS","Processando...",.F.)'

	Private aRotina 	:= {}

	ADD OPTION aRotina Title 'Atualizar'	            Action 	cRotAtu										OPERATION 3 ACCESS 0
	If B3F->(FieldPos("B3F_OK")) > 0
		ADD OPTION aRotina Title 'Agrupar Criticas' 	Action 'CenMrkAgr()'	                			OPERATION 2 ACCESS 0
	EndIf
	ADD OPTION aRotina Title 'Ativo na Central'        	Action  cAtviv	    								OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Bloqueado na Central'    	Action  cBlque  									OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Exibir dif. CNX' 			Action  cRotDifCnx									OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title 'Importar CNX'	            Action 'PLSVALIDSIB()'								OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Validar CNX' 			    Action  cRotCmpAns                      			OPERATION 3 ACCESS 0
	ADD OPTION aRotina Title 'Visualizar Beneficiário' 	Action  'CenExiCad(.F.,oTmpTab)'					OPERATION 2 ACCESS 0

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Central Critica Espelho

Chamada das rotinas ao abrir a tela de Critica de espelho

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CnCritEsp(lAuto,cTipo)
	Local	cAliasCon	:= GetNextAlias()
	Local 	cAliasTmp	:= GetNextAlias()
	Local 	aRetFun		:= {.F.,"Nehum registro criticado encontrado para ser corrigido.",""}
	Default cTipo       := ""
	Private oMark		:= Nil
	Private cGrpInt		:= ""
	Private cRegInt		:= ""
	Default lAuto		:= .F.


	MsgRun("Definindo consulta de registros",TOTVS,{ || aRetFun := RetornaConsulta(cTipo) })

	If aRetFun[1]
		MsgRun("Consultando registros criticados",TOTVS,{ || aRetFun := ExecutaConsulta(aRetFun[3],cAliasCon) })

		MsgRun("Definindo campos da tabela",TOTVS,{ || aRetFun := RetornaCampos() })

		aCampos := aRetFun[3]
		MsgRun("Criando tabela de trabalho",TOTVS,{ || aRetFun := CriaTabTemp(cAliasTmp,aCampos) })

		oTmpTab := aRetFun[3]
		MsgRun("Carregando tabela",TOTVS,{ || aRetFun := CarregaArqTmp(cAliasCon,cAliasTmp,cTipo) })

		MsgRun("Montando visualização dos registros",TOTVS,{ || aRetFun := CriaMarkBrowse(oMark,cAliasTmp,oTmpTab,aCampos,lAuto) })
	EndIf

	If !aRetFun[1]
		Help(,,'Aviso',,aRetFun[2],1,0)
	EndIf

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Cria Mark Browse

Função criada para criar o Mark Browse, filtros e funções.

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaMarkBrowse(oMark,cAliasTmp,oTmpTab,aCampos,lAuto)

	Local 	aRetFun 	:= {.T.,"Não foi possível criar o browse para marcar os registros",""}
	Default cAliasTmp 	:= ""
	Default oMark 		:= Nil
	Default oTmpTab 	:= Nil
	Default aCampos 	:= {}
	Default aSeek 		:= {}
	Default aFieFilter 	:= {}
	Default lAuto 		:= .F.

	If cAliasTmp <> "" .And. oTmpTab <> Nil .And. Len(aCampos) > 0

		oMark	:= FWMarkBrowse():New()
		oMark:SetDescription( "Críticas de Espelho")
		oMark:SetAlias(cAliasTmp)
		oMark:SetFieldMark("B3F_MARK")
		oMark:oBrowse:SetDBFFilter(.T.)
		oMark:oBrowse:SetUseFilter(.T.)
		oMark:oBrowse:SetFixedBrowse(.T.)
		oMark:SetWalkThru(.F.)
		oMark:SetAmbiente(.T.)
		oMark:SetTemporary()
		oMark:oBrowse:SetSeek(.T.,RetornaSeek())
		oMark:oBrowse:SetFieldFilter(RetornaFilter())
		oMark:SetAllMark({ || MarcaBrw(oMark,cAliasTmp) })
		oMark:SetMenuDef('CENCRITESP')
		oMark:ForceQuitButton()
		oMark:SetProfileID('CENCRITESP')
		oMark:AddButton("Enviar Alt. ANS"	, { || AjustaCritica(oMark,cAliasTmp)},,,, .F., 3 )

		oMark:SetFields(CarregaCampos(aCampos))

		If !lAuto
			oMark:Activate()
		EndIf
	Else
		aRetFun[1] := .F.
	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSVALIDSIB

Função criada para intermediar a validação do CNX após a importação.

@param cRotCmpAns - Chamada da função de validação

@author Vinícius Nicolau
@since 18/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Function PLSVALIDSIB()
	If PLSSIBCNX("2") > 0
		If IsBlind() .OR. MsgYesNo("Deseja validar o CNX ?", "TOTVS")
			PLSSIBESP()
		EndIf
	EndIf
Return


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CENATUIMP

Função que deleta a tabela temporária e cria novamente a tabela com registros atualizados
@author Vinícius Nicolau
@since 18/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CenAtuImp(oMark,cTipo)
	//Deletar o conteudo da tabela temp
	Local cAliasTmp := oMark:Alias()
	Local cAliasCon := GetNextAlias()
	Local aRetFun	:= {}
	Local cQuery    := ""
	Default cTipo   := ""

	ProcRegua(3)
	cQuery  += "DELETE FROM "
	cQuery  += oTmpTab:getrealName()
	CenCommit(cQuery)
	IncProc()

	//Refazer a consulta na tabela real
	aRetFun := RetornaConsulta(cTipo)
	ExecutaConsulta(aRetFun[3],cAliasCon)
	IncProc()

	//Realimentar a tabela temp
	CarregaArqTmp(cAliasCon,cAliasTmp,cTipo)
	IncProc()

	//Pedir para dar refresh na tela
	oMark:oBrowse:Refresh(.T.)
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenExiCad

Funcao criada para exibir as telas de cadastros de beneficiario.

@author vinicius.nicolau
@since 05/06/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CenExiCad(lAuto,oTmpTab)

	Local lOk 		:= .F.
	Local cAliasOri := oTmpTab:getAlias()
	Local nRecno 	:= AllTrim((cAliasOri)->B3FREC)
	Local cCodope 	:= (cAliasOri)->B3F_CODOPE
	Local cMatric 	:= AllTrim((cAliasOri)->B3F_IDEORI)
	Local cRotina 	:= ""
	Local aArea 	:= {}

	Default lAuto := .F.

	If Empty(cAliasOri)
		If !lAuto
			Alert("Selecione uma crítica para visualizar o cadastro de origem")
		EndIf
	Else

		aArea := (cAliasOri)->(GetArea())
		(cAliasOri)->(DbGoTo(Val(nRecno)))

		If cAliasOri == oTmpTab:getAlias()
			B3K->(MsSeek(xFilial("B3K")+cCodope+PADR(cMatric,tamSX3("B3K_MATRIC")[1])))
			cRotina := 'PLSMVCBENE'
		EndIf

		If Empty(cRotina)
			If !lAuto
				Alert("Não existe rotina para visualizar o cadastro da tabela " + cAliasOri)
			EndIf
		Else
			If !lAuto
				FWExecView('Visualização',cRotina,MODEL_OPERATION_VIEW)
			EndIf
			lOk := .T.
		EndIf

		(cAliasOri)->(RestArea(aArea))

	EndIf

Return lOk

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Retorna um array de campos

Retorna campos de filtro por chave

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Function RetornaSeek()

	Local aSeek := {}

	aAdd(aSeek,{"Código da Operadora"	,{{"","C",006,0,"Código da Operadora"	,"@!"}} } )
	aAdd(aSeek,{"Chave de Origem"		,{{"","C",050,0,"Chave de Origem"		,"@!"}} } )
	aAdd(aSeek,{"Código da Crítica"		,{{"","C",004,0,"Código da Crítica"		,"@!"}} } )

Return aSeek

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Retorna um array de campos

Retorna campos que formam a tela de Criar novos filtros

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Function RetornaFilter()

	Local aFieFilter := {}

	Aadd(aFieFilter,{"B3F_CODOPE","Registro da operadora","C",006, 0,"@!"})
	Aadd(aFieFilter,{"B3F_CODCRI","Codigo da Critica"	 ,"C",004, 0,"@!"})
	Aadd(aFieFilter,{"B3F_DESCRI","Descricao da Critica" ,"C",254, 0,"@!"})
	Aadd(aFieFilter,{"B3F_CAMPOS","Campos Afetados"      ,"C",100, 0,"@!"})
	Aadd(aFieFilter,{"B3F_IDEORI","Chave Ident Origem"   ,"C",150, 0,"@!"})
	Aadd(aFieFilter,{"B3F_DESORI","Descrição na Origem"  ,"C",254, 0,"@!"})
	Aadd(aFieFilter,{"B3K_DATBLO","Situação"             ,"C",009, 0,"@!"})

Return aFieFilter

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaCampos

Retorna os campos para criar a tabela temporaria

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaCampos()

	Local aCampos := {}
	Local aRetFun := {.F.,"Não foi possível definir os campos da tabela",""}

	aAdd(aCampos,{"B3F_MARK"   ,"C",002,0})
	aAdd(aCampos,{"B3F_CODOPE" ,"C",006,0})
	aAdd(aCampos,{"B3F_IDEORI" ,"C",150,0})
	aAdd(aCampos,{"B3F_CODCRI" ,"C",004,0})
	aAdd(aCampos,{"B3F_DESCRI" ,"C",254,0})
	aAdd(aCampos,{"B3F_CAMPOS" ,"C",100,0})
	aAdd(aCampos,{"B3F_DESORI" ,"C",254,0})
	aAdd(aCampos,{"B3FREC"	   ,"C",016,0})
	aAdd(aCampos,{"B3F_CHVORI" ,"C",016,0})
	aAdd(aCampos,{"B3K_DATBLO" ,"C",009,0})

	If Len(aCampos) > 0
		aRetFun[1] := .T.
		aRetFun[3] := aCampos
	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp

Cria a tabela temporária que será utilizada no MarkBrowse

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaTabTemp(cAliasTmp,aCampos)
	Local   aRetFun := {.F.,"Não foi possível definir uma tabela de trabalho",""}
	Private oTmpTab := Nil
	Default aCampos := {}

	oTmpTab := FWTemporaryTable():New( cAliasTmp )
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex("01",{"B3F_CODOPE"})
	oTmpTab:AddIndex("02",{"B3F_IDEORI"})
	oTmpTab:AddIndex("03",{"B3F_CODCRI"})
	oTmpTab:Create()

	aRetFun[1] := .T.
	aRetFun[3] := oTmpTab

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaConsulta

Função responsável por montar a query que irá buscar os registros

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaConsulta(cTipo)
	Local cConsulta	:= ""
	Local aRetFun 	:= {.F.,"Não foi possível definir a consulta",""}
	default cTipo   := ""

	If cTipo == "1"  //Listará todos os clientes ativos da central mesmo que bloqueados na ANS
		cConsulta := " SELECT B3F_CODOPE,B3F_IDEORI,B3F_CODCRI,B3F_DESCRI,B3F_CAMPOS,B3F_DESORI,B3F.R_E_C_N_O_ B3FREC,B3F_CHVORI, "
		cConsulta  += " CASE WHEN B3K_DATBLO = ' ' OR B3K_DATBLO > '"+DTOS(dDataBase)+"' THEN 'ATIVO' ELSE 'BLOQUEADO' END B3K_DATBLO "
		cConsulta  += " FROM " + RetSqlName("B3F") + " B3F, " + RetSqlName("B3K") + " B3K "
		cConsulta += " WHERE "
		cConsulta += " B3F.B3F_FILIAL = '"+xFilial("B3F")+"' AND B3K.B3K_FILIAL = '"+xFilial("B3F")+"' "
		cConsulta += " AND B3F.B3F_CODOPE = B3K.B3K_CODOPE "
		cConsulta += " AND B3F.B3F_IDEORI = B3K.B3K_MATRIC "
		cConsulta += " AND (B3K.B3K_DATBLO = ' ' OR B3K.B3K_DATBLO > '"+DTOS(dDataBase)+"') "
		cConsulta += " AND B3F.B3F_ORICRI IN ('B3W','B3K') "
		cConsulta += " AND B3F.B3F_CODCRI LIKE 'E%' "
		cConsulta += " AND B3F.D_E_L_E_T_ <> '*'  "
		cConsulta += " AND B3K.D_E_L_E_T_ <> '*'  "
		cConsulta += " ORDER BY B3F.B3F_CODOPE,B3F.B3F_IDEORI,B3F.B3F_CODCRI  "

	elseIf cTipo == "2" //Listará todos bloqueados na central independente do seu status na ANS
		cConsulta := " SELECT B3F_CODOPE,B3F_IDEORI,B3F_CODCRI,B3F_DESCRI,B3F_CAMPOS,B3F_DESORI,B3F.R_E_C_N_O_ B3FREC,B3F_CHVORI, "
		cConsulta  += " CASE WHEN B3K_DATBLO <> ' ' AND B3K_DATBLO <= '"+DTOS(dDataBase)+"' THEN 'ATIVO' ELSE 'BLOQUEADO' END B3K_DATBLO "
		cConsulta  += " FROM " + RetSqlName("B3F") + " B3F, " + RetSqlName("B3K") + " B3K "
		cConsulta += " WHERE "
		cConsulta += " B3F.B3F_FILIAL = '"+xFilial("B3F")+"' AND B3K.B3K_FILIAL = '"+xFilial("B3F")+"' "
		cConsulta += " AND B3F.B3F_CODOPE = B3K.B3K_CODOPE "
		cConsulta += " AND B3F.B3F_IDEORI = B3K.B3K_MATRIC "
		cConsulta += " AND (B3K.B3K_DATBLO <> ' ' AND B3K.B3K_DATBLO <= '"+DTOS(dDataBase)+"') "
		cConsulta += " AND B3F.B3F_ORICRI IN ('B3W','B3K') "
		cConsulta += " AND B3F.B3F_CODCRI LIKE 'E%' "
		cConsulta += " AND B3F.D_E_L_E_T_ <> '*'  "
		cConsulta += " AND B3K.D_E_L_E_T_ <> '*'  "
		cConsulta += " ORDER BY B3F.B3F_CODOPE,B3F.B3F_IDEORI,B3F.B3F_CODCRI  "

	Else
		cConsulta := " SELECT B3F_CODOPE,B3F_IDEORI,B3F_CODCRI,B3F_DESCRI,B3F_CAMPOS,B3F_DESORI,B3F.R_E_C_N_O_ B3FREC,B3F_CHVORI, "
		cConsulta  += " CASE WHEN B3K_DATBLO = ' ' OR B3K_DATBLO > '"+DTOS(dDataBase)+"' THEN 'ATIVO' ELSE 'BLOQUEADO' END B3K_DATBLO "
		cConsulta  += " FROM " + RetSqlName("B3F") + " B3F, " + RetSqlName("B3K") + " B3K "
		cConsulta += " WHERE "
		cConsulta += " B3F.B3F_FILIAL = '"+xFilial("B3F")+"' AND B3K.B3K_FILIAL = '"+xFilial("B3F")+"' "
		cConsulta += " AND B3F.B3F_CODOPE = B3K.B3K_CODOPE "
		cConsulta += " AND B3F.B3F_IDEORI = B3K.B3K_MATRIC "
		cConsulta += " AND B3F.B3F_ORICRI IN ('B3W','B3K') "
		cConsulta += " AND B3F.B3F_CODCRI LIKE 'E%' "
		cConsulta += " AND B3F.D_E_L_E_T_ <> '*'  "
		cConsulta += " AND B3K.D_E_L_E_T_ <> '*'  "
		cConsulta += " ORDER BY B3F.B3F_CODOPE,B3F.B3F_IDEORI,B3F.B3F_CODCRI  "

	EndIf



	If !Empty(cConsulta)
		aRetFun[1] := .T.
		aRetFun[3] := cConsulta
	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecutaConsulta

Executa a query da função RetornaConsulta()

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------

Static Function ExecutaConsulta(cConsulta,cAliasTmp)

	Local 	aRetFun 	:= {.F.,"Nenhum registro encontrado para ser apresentado",""}
	Default cConsulta 	:= ""
	Default cAliasTmp 	:= ""

	If !Empty(cConsulta) .And. !Empty(cAliasTmp)

		If (Select(cAliasTmp) <> 0)
			dbSelectArea(cAliasTmp)
			(cAliasTmp)->(dbCloseArea())
		EndIf

		cConsulta := ChangeQuery(cConsulta)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cConsulta),cAliasTmp,.F.,.T.)

		If !(cAliasTmp)->(Eof())
			aRetFun[1] := .T.
		EndIf

	EndIf

Return aRetFun

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com os registros criticados

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(cAliasCon,cAliasTmp,cTipo)

	Local aRetFun := {.F.,"Não foi possível carregar o arquivo de trabalho",""}
	Local cQuery  := ""
	Default cTipo := ""

	If !aRetFun[1]
		aRetFun[1] := .T.
	EndIf

	cQuery  += "INSERT INTO "
	cQuery  += oTmpTab:getrealName()
	cQuery  += " (B3F_CODOPE,B3F_IDEORI,B3F_CODCRI,B3F_DESCRI,B3F_CAMPOS,B3F_DESORI,B3FREC,B3F_CHVORI,B3K_DATBLO) "
	cQuery  += " SELECT B3F_CODOPE,B3F_IDEORI,B3F_CODCRI,B3F_DESCRI,B3F_CAMPOS,B3F_DESORI,B3F.R_E_C_N_O_ B3FREC,B3F_CHVORI, "
	cQuery  += " CASE WHEN B3K_DATBLO = ' ' OR B3K_DATBLO > '"+DTOS(dDataBase)+"' THEN 'ATIVO' ELSE 'BLOQUEADO' END B3K_DATBLO "
	cQuery  += " FROM "
	cQuery  += RetSqlName("B3F") + " B3F, "
	cQuery  += RetSqlName("B3K") + " B3K "
	cQuery  += " WHERE B3F.B3F_FILIAL = '"+xFilial("B3F")+"' "
	cQuery  += " AND B3K.B3K_FILIAL = '"+xFilial("B3F")+"' "
	cQuery  += " AND B3F.B3F_CODOPE = B3K.B3K_CODOPE "
	cQuery  += " AND B3F.B3F_IDEORI = B3K.B3K_MATRIC "

	If !Empty(cTipo)

		If cTipo == "1"
			cQuery  += " AND (B3K.B3K_DATBLO = ' ' OR B3K.B3K_DATBLO > '"+DTOS(dDataBase)+"') "

		elseIf cTipo == "2"
			cQuery += " AND (B3K.B3K_DATBLO <> ' ' AND B3K.B3K_DATBLO <= '"+DTOS(dDataBase)+"') "

		EndIf
	EndIf

	cQuery  += " AND B3F.B3F_ORICRI IN ('B3W','B3K') AND B3F.B3F_CODCRI LIKE 'E%' AND B3F.D_E_L_E_T_ <> '*' AND B3K.D_E_L_E_T_ <> '*' "
	cQuery  += " ORDER BY B3F.B3F_CODOPE,B3F.B3F_IDEORI,B3F.B3F_CODCRI "

	CenCommit(cQuery)

Return aRetFun

/*/{Protheus.doc} CenCommit
Commit na tabela temporaria.
@author Vinícius Nicolau
@since  08/06/2021
@version 1.0
/*/
Function CenCommit(cSql)

	nRet := tcSqlExec(cSql)

	if nRet < 0

		userException("Erro na execução do update PLSCOMMIT -> [ " + tcSqlERROR() + "]")

	elseIf tcIsconnected() .and. ( "ORACLE" $ upper(TCGetDb()) )

		tcSqlExec("COMMIT")

	endIf

return (nRet >= 0)

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaCampos

Carrega os campos do browse

@author	vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaCampos(aCampos)

	Local cPicture := "@!"
	Local aFields  := {}
	Local nI 	   := 0

	For nI := 2 to 10
		If nI < 8 .Or. nI == 10
			aAdd(aFields,GetColuna(aCampos[nI,CAMPO] ,IIF(nI==10,"Situação",X3Desc(aCampos[nI,CAMPO])),aCampos[nI,TIPO],aCampos[nI,TAMANHO],aCampos[nI,DECIMAL],cPicture))
		EndIf
	Next nI

Return aFields

Static Function X3Desc(cCampo)
	Local cDesc := ""
	SX3->( dbSetOrder(2) )
	If SX3->( dbSeek( cCampo ) )
		cDesc := X3Descric()
	EndIf
Return cDesc

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetColuna

Retorna uma coluna para o markbrowse

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)

	Local aColuna    := {}
	Local bData      := &("{||" + cCampo +"}")
	Default nAlign   := 1
	Default nSize    := 20
	Default nDecimal := 0
	Default cTipo    := "C"

	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MarcaBrw

Chama a funcao para marcar/desmarcar todos os registros da markbrowse

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function MarcaBrw(oMark,cAliasTmp)
	Default oMark 	  := Nil
	Default cAliasTmp := ""

	MsgRun("Marcando / Desmarcando registros do browse",TOTVS,{ || PrcMarcaBrw(oMark,cAliasTmp) })

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrcMarcaBrw

Marcar/desmarcar todos os registros da markbrowse

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrcMarcaBrw(oMark,cAliasTmp)
	Default oMark 	  := Nil
	Default cAliasTmp := ""

	If !Empty(cAliasTmp) .And. oMark <> Nil
		(cAliasTmp)->(dbGoTop())
		While !(cAliasTmp)->(Eof())

			oMark:MarkRec()
			(cAliasTmp)->(dbSkip())
		EndDo
		oMark:oBrowse:Refresh(.T.)
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaCritica

Envia a mensagem para a tela de correção ou não

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Function AjustaCritica(oMark,cAliasTmp)

	If MsgYesNo("Deseja enviar as alterações para ANS?")
		MsgRun("Enviando registros criticados",TOTVS,{ || ProcEnvCritica(oMark,cAliasTmp) } )
	Else
		MsgInfo("Ação cancelada pelo usuário.")
	EndIf

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaCritica

Chama o processamento de corrigir as criticas do registros selecionados

@author vinicius.nicolau
@since 25/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Function ProcEnvCritica(oMark,cAliasTmp)
	Local   cMarca   	:= ""
	Local 	cAliasMrk	:= getNextAlias()
	Default oMark    	:= Nil

	If !Empty(cAliasTmp) .And. oMark <> Nil

		(cAliasTmp)->(dbGoTop())
		cMarca := oMark:Mark()

		cSql := " SELECT B3FREC "
		cSql += " FROM " + oTmpTab:getrealName()
		cSql += " WHERE B3F_MARK = '" + cMarca + "' "

		cSql := ChangeQuery(cSql)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasMrk,.F.,.T.)

		(cAliasMrk)->(dbGoTop())
		While !(cAliasMrk)->(Eof())
			MV_PAR01 := dDataBase
			cRec := allTrim((cAliasMrk)->B3FREC)
			PLSALTANS(.F., .T., cRec)
			(cAliasMrk)->(dbSkip())
		EndDo
		(cAliasMrk)->(dbCloseArea())

		Processa( { || CenAtuImp(oMark) },"Atualizando registros","Processando...",.F.)
		MsgInfo("Movimentação criada no compromisso vigente.")
	EndIf

Return .T.
