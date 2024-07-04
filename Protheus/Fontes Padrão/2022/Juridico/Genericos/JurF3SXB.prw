
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JurF3SXB.ch"

#DEFINE DEFAULTSPACE 10
#DEFINE DEFAULTGETSPACE SPACE(60)

#DEFINE CSSLABEL "QLabel{" +;
  "font-size:12px;" +;
  "font: 12px Arial;" +;
  "}"
  //Formatação da label palavra chave

#DEFINE CSSEDIT "QLineEdit {" +;
  "border-width: 2px;" +;
  "border: 1px solid #C0C0C0;" +;
  "border-radius: 3px;" +;
  "border-color: #C0C0C0;" +;
  "font: 12px Arial;" +;
  "}"
  //Formatação do campo de busca (oGetSearch)

#DEFINE CSSBUTTON "QPushButton {" +;
	"cursor: pointer; color: rgb(79, 84, 94);" +;
	"border: 1px solid rgb(216, 216, 216);" +;
	"border-radius: 3px;" +;
	"background-color: rgb(245, 245, 245);"+;
	"}" +;
	"QPushButton:hover:!pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(255, 255, 255), stop: 1 rgb(230, 230, 230));}"+;
	"QPushButton:hover:pressed {background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 rgb(230, 230, 230), stop: 1 rgb(255, 255, 255));}"
	//Formatação do botão Pesquisar

static _WhereSQL := cleanSQL(.T.)
static _cTable := ""
static _cFields := ""
static _aCampos := {}
static _cFilter := ""

static _BKPcTable   := ""
static _BKPcFields  := ""
static _BKPaCampos  := {}
static _BKPcFilter  := ""

//-------------------------------------------------------------------
/*/{Protheus.doc} JurF3SXB(cTable,aCampos,cFilter,lVisualiza,lInclui,cFonte,cSQL)
Função generica para consultas especificas

@Param cTable  Nome da tabela
@Param aCampos  Array com os campos que devem ser exibidos no grid
@Param cFilter  Filtro (where) que será concatenado na query. Obs.: Sem o AND no inicio.
@Param lVisualiza  Define se o botão Visualizar será apresentado. Padrão .T.
@Param lInclui  Define se o botão Incluir será apresentado. Padrão .T.
@Param cFonte  Nome do fonte (JURAXXX), Utilizado
@Param cSQL    Query pronta, caso deseja ter uma busca específica, por exemplo valores de mais de uma tabela
@Param lExibeDados  Indica se a consulta apresenta dados na sua abertura. .T. = Apresenta dados / .F. = Não presenta dados
                       Se for .F. também não permite realizar pesquisa com filtro em branco. Padrão .T.
@Param nReduz Percentual de redução da view quando é informado o fonte
@Param lAltera  Define se o botão Alterar será apresentado. Padrão .F.

@Return nResult Registro selecionado

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JurF3SXB(cTable,aCampos,cFilter,lVisualiza,lInclui,cFonte,cSQL,lExibeDados, nReduz, lAltera, cGroupBy, cOrderBy)
local cWhere  := DEFAULTGETSPACE
local nResult := 0
Local nRecno  := 0
Local cNameTable := ""
Local cFields  := ""
Local aButtons := {}
Local aHeader  := {}
Local aCols    := {}
Local oModal, oMain, oPSearch, oPGrid, oBtnSearch, oGetSearch, oSaySearch, oGetData, oBtnClear

default cTable     := ""
default aCampos    := {}
default cFilter    := ""
default lVisualiza := .T.
default lInclui    := .T.
default cFonte     := ""
default cSQL       := ""
default lExibeDados:= .T.
default nReduz     := 0
default lAltera    := .F.
default cGroupBy   := ""
default cOrderBy   := ""

// Faz o tratamento do filtro, para que seja transformado em filtro de query
cFilter := JF3TrtFilt(cFilter,cTable)

If Empty(cSQL) // Só será necessário caso a query seja montada na própria consulta. Quando já existir uma query não usará essa variável
	cFields := getFields(aCampos, cTable)
EndIf

// Seta variaveis de BKP e variáveis estaticas de controle
JF3SetBKP(cTable,aCampos,cFilter,cFields)

If Len(cTable) == 2
	cNameTable := AllTrim(JurGetDados('SX5',1,XFILIAL('SX5')+'00'+cTable,'X5_DESCRI'))
Else
	cNameTable := AllTrim(FWX2Nome(_cTable))
EndIf

oModal := FWDialogModal():New()
oModal:SetFreeArea(420,180)
oModal:SetEscClose(.T.)
oModal:SetTitle(STR0008 + cNameTable ) //"Consulta - "
oModal:createDialog()
oModal:addOkButton({|| nResult := outData(oGetData), oModal:oOwner:End() })
oModal:addCloseButton()
If lExibeDados // Executa bloco de inicialização, somente se o browse na abertura puder apresentar dados
	oModal:setInitBlock({|| seekData(oGetData, cWhere, cSQL, cTable, aCampos, cFilter, cFields,, cGroupBy, cOrderBy)})
EndIf

oMain := oModal:GetPanelMain()

oPSearch := TPanel():Create(oMain,02,,,,,,,/*CLR_RED*/,,20)
oPSearch:Align := CONTROL_ALIGN_TOP

oPGrid := TPanel():Create(oMain,02,,,,,,,/*CLR_BLUE*/)
oPGrid:Align := CONTROL_ALIGN_ALLCLIENT

//Cria uma lista de regras CSS para serem aplicadas aos objetos no momento de sua criação
AddCSSRule("TButton",CSSBUTTON)
AddCSSRule("TGET",CSSEDIT)
AddCSSRule("TSAY",CSSLABEL)

oBtnClear := TButton():Create(oPSearch)
oBtnClear:cName := "oBtnClear"
oBtnClear:cCaption := STR0001//"Limpar"
oBtnClear:blClicked	:= {|| cWhere := DEFAULTGETSPACE, seekData(oGetData, cWhere, cSQL, cTable, aCampos, cFilter, cFields, lExibeDados, cGroupBy, cOrderBy), oGetSearch:SetFocus() }
oBtnClear:nTop := 05
oBtnClear:nWidth := 90
oBtnClear:nHeight := 32
oBtnClear:nLeft := oMain:nWidth/*Janela*/ - (DEFAULTSPACE*10)

oBtnSearch := TButton():Create(oPSearch)
oBtnSearch:cName := "oBtnSearch"
oBtnSearch:cCaption := STR0002//"Pesquisar"
oBtnSearch:blClicked := {|| seekData(oGetData, cWhere, cSQL, cTable, aCampos, cFilter, cFields, lExibeDados, cGroupBy, cOrderBy)}
oBtnSearch:nTop := 05
oBtnSearch:nWidth := 90
oBtnSearch:nHeight := 32
oBtnSearch:nLeft := oMain:nWidth/*Janela*/ - oBtnClear:nWidth - (DEFAULTSPACE*11)

oGetSearch := TGET():Create(oPSearch)
oGetSearch:cName := "oGetSearch"
oGetSearch:bSetGet := {|u| if( pCount() > 0, cWhere := u, cWhere)}
oGetSearch:nTop := 07
oGetSearch:nWidth := 315
oGetSearch:nLeft := oMain:nWidth/*Janela*/ - oBtnClear:nWidth - oGetSearch:nWidth/*Cpo Palavra chave*/ - (DEFAULTSPACE*12)
oGetSearch:nHeight := 27
oGetSearch:SetFocus()

oSaySearch := TSAY():Create(oPSearch)
oSaySearch:cName := "oSaySearch"
oSaySearch:cCaption	:= STR0003//"Palavra-chave:"
oSaySearch:nTop := 12
oSaySearch:nWidth := 90
oSaySearch:nLeft := oMain:nWidth/*Janela*/ - oBtnClear:nWidth - oSaySearch:nWidth/*Palavra-chave*/ - oGetSearch:nWidth/*Cpo Palavra chave*/ - (DEFAULTSPACE*13)
oSaySearch:nHeight := 32

aHeader := getHeader(aCampos)

oGetData := TJurBrowse():New(oPGrid)
oGetData:SetDataArray()
oGetData:setHeaderSX3(aHeader)
oGetData:Activate()
oGetData:SetDoubleClick({|| nResult := outData(oGetData), oModal:oOwner:End() })

If lInclui
	If cTable == 'NQE' .OR. cTable == 'NQC'
		nRecno := RECNO()
		aAdd(aButtons,{,STR0007,{|| (cTable)->( dbGoto( nRecno ) ), IIF(nRecno > 0 ,ExecOpc(STR0007,4,cTable,cFonte,nReduz),), seekData(oGetData, cWhere, cSQL, cTable, aCampos, cFilter, cFields, lExibeDados, cGroupBy, cOrderBy) },,,.T.,.T.})
	Else
		aAdd(aButtons,{,STR0007,{|| ExecOpc(STR0007,3,cTable,cFonte,nReduz), seekData(oGetData, cWhere, cSQL, cTable,aCampos,cFilter,cFields,lExibeDados, cGroupBy, cOrderBy) },,,.T.,.T.}) // "Incluir"
	EndIf
EndIf
If lVisualiza
	aAdd(aButtons,{,STR0005,{|| nRecno := outData(oGetData), (cTable)->( dbGoto( nRecno ) ), IIF(nRecno > 0 ,ExecOpc(STR0005,1,cTable,cFonte,nReduz),)  },,,.T.,.T.}) // "Visualizar"
EndIf

//-- Se esta no campo de Foro ou Vara pela tela de processo precisamos verificar se permite apresentar os botões de INCLUIR e ALTERAR, pois ao selecionar uma dessas operações será apresentado o cadastro completo de Comarcas.
If lAltera
	nRecno := RECNO()	
	If (cTable == 'NQE' .OR. cTable == 'NQC') .AND. lInclui
		aAdd(aButtons,{,STR0010,{|| (cTable)->( dbGoto( nRecno ) ), IIF(nRecno > 0 ,ExecOpc(STR0010,4,cTable,cFonte,nReduz),), seekData(oGetData, cWhere, cSQL, cTable, aCampos, cFilter, cFields, lExibeDados, cGroupBy, cOrderBy) },,,.T.,.T.})
	EndIf
EndIf

oModal:addButtons(aButtons)
oModal:activate()

If Valtype(nResult) <> 'N'
	nResult:= Alltrim(nResult)
	nResult:= Val(nResult)
EndIf

aSize(aCols,0)
aSize(aButtons,0)
aSize(oGetData:aCols,0)
aSize(aHeader,0)
aSize(aCampos,0)
oGetData:Deactivate()
oModal:Deactivate()
FWFreeObj(oGetData)
FWFreeObj(oMain)
FWFreeObj(oPSearch)
FWFreeObj(oPGrid)
FWFreeObj(oModal)

return nResult

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados Fake para uso na nova consulta

@author Jorge Luis Branco Martins Junior
@since 01/09/16
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel := MPFormModel():New("F3SXB",/*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
Local oStruct

If !Empty(_cTable)
	oStruct := FWFormStruct(1,_cTable)
	oModel:AddFields(_cTable, Nil , oStruct,/*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)

	oModel:SetDescription(INFOSX2( _cTable , 'X2_NOME' ))
	oModel:GetModel(_cTable):SetDescription(INFOSX2( _cTable , 'X2_NOME' ))

EndIf
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados Fake para uso na nova consulta

@author Jorge Luis Branco Martins Junior
@since 01/09/16
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel := Modeldef()
Local oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField(_cTable, FWFormStruct(2,_cTable))
oView:CreateHorizontalBox("ALL",100)
oView:SetOwnerView(_cTable,"ALL")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} getHeader(aCampos)
Função responsavel por montar Header

@Param aCampos Array com os campo que devem ser apresentados no header

@Return aHeader Array com o Header

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static function getHeader(aCampos)
local aHeader := {}
local nI := 0

if Len(aCampos) > 0
	for nI := 1 to Len(aCampos)
		If ValType(aCampos[nI]) == "A"
			Aadd(aHeader,{aCampos[nI][2],AllTrim(RetTitle(aCampos[nI][2])),,,,,,aCampos[nI][2]})
		Else
			Aadd(aHeader,{aCampos[nI],AllTrim(RetTitle(aCampos[nI])),,,,,,aCampos[nI]})
		EndIf
	next
endif

Aadd(aHeader,{"recno","recno","",0,0,"","","N","","" })

return aHeader

//-------------------------------------------------------------------
/*/{Protheus.doc} getFields(aCampos)
Função para montar o select

@Param aCampos Array com os campo que devem ser apresentados no header

@Return cFields Campos do select com apelido

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static function getFields(aCampos, cTable)
local cFields   := ""
local nI        := 0
Local aCmpsDisp := {}

If Len(aCampos) > 0

	aCmpsDisp := JCmpDispPD(aCampos)

	For nI := 1 To Len(aCampos)
		If Len(aCmpsDisp) > 0 .And. aScan(aCmpsDisp[1],aCampos[nI]) = 0
			cFields += "'*****',"
		Else
			If Len(cTable) == 2 // Tabela de SX5
				cFields += I18N( "SX5.#1,",{aCampos[nI]})
			Else
				cFields += I18N( cTable + ".#1,",{aCampos[nI]})
			EndIf			
		EndIf
	Next
Endif

return cFields
//-------------------------------------------------------------------
/*/{Protheus.doc} getWhere()
Função para adicionar condição da palavra chave no where

@Return cFields trecho com condição da palavrava chave para ser concatenado no where

@author  Raphael Zei Cartaxo Silva
@since   12/08/16
@version 2.0
/*/
//-------------------------------------------------------------------
static function getWhere(cWhere)//Alterada funcao getWhere para montar o cSql com as condicoes cWhere para cada campo contido no _aCampos. LPS

	local nI     := 0
	local lIni   := .F.
	local cSql   := ''
	Local cCampo := ""

	For nI := 1 to Len(_aCampos)
		//trata quando a estrutura do acampos recebe a tabela e o campo em um array bidimensional
		If valtype(_aCampos[nI]) == "C"
			cCampo := _aCampos[nI]
		Else
			cCampo := _aCampos[nI][2]
		Endif

		If !lIni
			cSql += "  AND ( " + replace(_WhereSQL,'##COLUMN##', cCampo)  + " LIKE '%" + cleanString(cWhere,.T.) + "%'" + CRLF
		Else
			cSql += "  OR " + replace(_WhereSQL,'##COLUMN##', cCampo)  + " LIKE '%" + cleanString(cWhere,.T.) + "%'" + CRLF
		EndIf
		lIni := .T.
	Next nI

	If lIni
		cSql += ")"
	EndIf

Return cSql

//-------------------------------------------------------------------
/*/{Protheus.doc} seekData(oGetData, cWhere, cTable,aCampos,cFilter,cFields)
Verifica se existem resultados para os filtros, se sim adiciona(drawGrid) no Grid, se não limpa(cleanGrid) o Grid

@Param oGetData Objeto do Grid
@Param cWhere Palavra chave
@Param cSQL   Query pronta em casos que a consulta já possuí query especifica
@Param cTable Nome da tabela
@Param aCampos  Array com os campos que devem ser exibidos no grid
@Param cFilter  Filtro (where) que será concatenado na query. Obs.: Sem o AND no inicio.
@Param cFields  Campos do select com apelido
@Param lExibeDados  Indica se a consulta apresenta dados na sua abertura. .T. = Apresenta dados / .F. = Não presenta dados
                       Se for .F. também não permite realizar pesquisa com filtro em branco. Padrão .T.

@Return Nil

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static function seekData(oGetData, cWhere, cSQL, cTable,aCampos,cFilter,cFields, lExibeDados, cGroupBy, cOrderBy)
local aCols := {}

default lExibeDados := .T.
 default cGroupBy   := ""
 default cOrderBy   := ""

aCols  := getData(cWhere, cSQL, cTable, aCampos, cFilter, cFields, lExibeDados, cGroupBy, cOrderBy)

If !lExibeDados .Or. Len(aCols) > 0
	// Sempre que a opção de o browse não exibir dados sem uma pesquisa estiver ativa,
	// o sistema executa a rotina de carregar o grid e não a de limpar o grid,
	// para que seja executado o filtro indicado acima ("1=2") e não trazer nenhum registro.
	drawGrid(oGetData,aCols)
else
	cleanGrid(oGetData)
endif

return nil
//-------------------------------------------------------------------
/*/{Protheus.doc} getData(cWhere,cSQL,cTable,aCampos,cFilter,cFields)
Monta a query, com os campos do grid, filtros da consulta e restrição de cadastro

@Param cWhere Palavra chave
@Param cSQL   Query pronta em casos que a consulta já possuí query especifica

@Return aCols Array com os registros obtidos na query

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static function getData(cWhere, cSQL, cTable, aCampos, cFilter, cFields, lExibeDados, cGroupBy, cOrderBy)
Local aSql     := {}
Local aCols    := {}
Local cRestri  := ""
Local nI       := 0
Local nJ       := 0
Local aReplace := {}

Default cWhere := ""
Default cSQL   := ""
Default lExibeDados := .T.
Default cGroupBy    := ""
Default cOrderBy    := ""

If !lExibeDados
	If Empty(AllTrim(cWhere))
		If Empty(AllTrim(cFilter))
			cFilter += "1=2"
		Else
			cFilter += " AND 1=2 "
		EndIf
	EndIf
EndIf

// Preenche as variáveis estáticas de controle com os valores das variáveis de BKP
JF3GetBKP(cTable,aCampos,cFilter,cFields)

If Empty(cSql)
	// Consultas que não tem query pronta, terão sua query montada nesse trecho

	// Query de consultas SX5
	If AT("X5_TABELA", _cFilter) > 0
		cSql := " SELECT " + _cFields + "SX5.R_E_C_N_O_ recno" + CRLF
		cSql += "   FROM " + RetSqlName("SX5") + " SX5 " + CRLF
		cSql += "  WHERE SX5.D_E_L_E_T_ = ' ' " + CRLF
		cSql += "    AND SX5." + colFilial("SX5")  + " = '" + xFilial("SX5") + "' " + CRLF
	EndIf

	// Query de consultas SXB
	If Empty(cSql)
		cSql := " SELECT " + _cFields + _cTable + ".R_E_C_N_O_ recno" + CRLF
		cSql += "   FROM " + RetSqlName(_cTable) + " " +  _cTable + CRLF
		cSql += "  WHERE " + _cTable + ".D_E_L_E_T_ =  ' ' " + CRLF
		If !(('_FILIAL') $ cFilter)
			cSql += "    AND " + _cTable + "." + colFilial(_cTable)  + " = '" + xFilial(_cTable) + "' " + CRLF
		EndIf
	EndIf

	If !Empty(cWhere)
		cSql += getWhere(cWhere)               //Alterado retorno do cSql - LPS
	endif

ElseIf !Empty(cWhere) .And. !( Len(_aCampos) > 0 .And. ValType(_aCampos[1]) == "A" )
	// Consulta com query pronta que possuem campos de uma única tabela.
	// Dessa forma o array aCampos possuí apenas os nomes dos campos
	if (At("UNION",UPPER(cSql)) > 0)   //Caso tenha union a condicao Where deverá estar fora da query. --LPS
		cSql := "SELECT * FROM (" + cSql + ") " + cTable + " WHERE 1=1 "
	Endif
	cSql += getWhere(cWhere)  	              //Alterado retorno do cSql - LPS

Else
	// Consulta com query pronta que possuem campos de mais de uma tabela.
	// Dessa forma o array aCampos possuí um array com as tabelas e nomes dos campos
	If !Empty(cWhere) .And. Len(_aCampos) > 0
		cSql += getWhere(cWhere)			 //Alterado retorno do cSql - LPS
	EndIf
EndIf

cRestri := JurFiltRst(_cTable, .T.) // Verifica se existe restrição de cadastro

If !EMPTY(cRestri)
	cSql += " AND (" + cRestri + ")"  // Adiciona restrições de cadastro
EndIf

If !Empty(_cFilter) .AND. !(_cFilter $ cSql) //Adiciona condição (where) passada na função da consulta
	cSql += "  AND " + _cFilter
EndIf

cSql += cGroupBy

If Empty(cOrderBy)
	cSql += " ORDER BY 1"
Else
	cSql += cOrderBy
EndIf

cSql := Replace(cSql, ",'')",",'**')")//ajuste para o replace funcionar após o changeQuery
aAdd(aReplace,{",'**')", ",'')"})

aSql := JURSQL(cSql,"*",,aReplace)

If !Empty(aSQL)
	for nI := 1 to Len(aSql)
		aAux := {}
		for nJ := 1 to (Len(_aCampos) + 1)
			If Len(aSql[nI]) >= nJ
				Aadd(aAux,aSql[nI][nJ])
			Endif
		next
		Aadd(aAux,.F.)
		Aadd(aCols,aClone(aAux))
		aSize(aAux,0)
	next
EndIf

aSize(aSql,0)
cSql := Nil

Return aCols
//-------------------------------------------------------------------
/*/{Protheus.doc} drawGrid(oGetData,aCols)
Adiciona os registros obtidos na query no Grid

@Param oGetData Objeto do Grid
@Param aCols Array com os registros obtidos na query

@Return Nil

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static function drawGrid(oGetData,aCols)
  oGetData:setArray(aCols)
  oGetData:Enable()
return
//-------------------------------------------------------------------
/*/{Protheus.doc} cleanGrid(oGetData)
Limpa os registros do Grid

@Param oGetData Objeto do Grid

@Return Nil

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static function cleanGrid(oGetData)
  oGetData:setArray({})
  oGetData:Disable()
return
//-------------------------------------------------------------------
/*/{Protheus.doc} outData(oGetData)
Função para obter o registro selecionado, utilizado nos eventosde botões ou de duplo click

@Param oGetData Objeto do Grid

@Return nResult registro selecionado

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static Function outData(oGetData)
local nLine   := oGetData:nAt
local nResult := 0
local nPos    := 0

IIf( ValType(nLine) <> "N", nLine := 0 , )

If Len(oGetData:aCols) >= nLine
	nPos    := Len(oGetData:aCols[nLine])-1
	nResult := oGetData:aCols[nLine][nPos]
endif

Return nResult
//-------------------------------------------------------------------
/*/{Protheus.doc} colFilial(cTable)
Função utilizada para tratar alias da tabela, para que seja utilizada na na montagem da query

@Param cTable Nome da tabela

@Return cColFilial Alias com tratamento

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
static function colFilial(cTable)
local cColFilial := I18N("#1_FILIAL",{cTable})
local cIniChar := Substr(cColFilial,1,1)

if cIniChar = "S"
  cColFilial := Substr(cColFilial,2,len(cColFilial))
endif

return cColFilial

//-------------------------------------------------------------------
/*/{Protheus.doc} cleanString(cString, lSpace)
Função utiliza para tratar a palavra chave, substituindo caracteres especiais.

@Param cString Palavra chave
@Param lSpace Parametro que define se os espaços da palavra chave devem ser removidos

@Return cString Paravra chave sem caracteres especiais

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function cleanString(cString, lSpace)

cString := UPPER(Alltrim(cString))

if lSpace
	cString := replace(cString,' ','')
Endif

cString := replace(cString,"'",'')
cString := replace(cString,"''",'')
cString := replace(cString,'´','')
cString := replace(cString,'`','')
cString := replace(cString,',','')
cString := replace(cString,'.','')
cString := replace(cString,'(','')
cString := replace(cString,')','')
cString := replace(cString,'/','')
cString := replace(cString,'\','')
cString := replace(cString,'-','')
cString := replace(cString,':','')
cString := replace(cString,'¿','')
cString := replace(cString,'*','')
cString := replace(cString,'+','')
cString := replace(cString,'"','')
cString := replace(cString,'_','')
cString := replace(cString,'ª','')
cString := replace(cString,'º','')
cString := replace(cString,'Á','A')
cString := replace(cString,'À','A')
cString := replace(cString,'Ã','A')
cString := replace(cString,'Â','A')
cString := replace(cString,'Ä','A')
cString := replace(cString,'É','E')
cString := replace(cString,'È','E')
cString := replace(cString,'Ê','E')
cString := replace(cString,'Ë','E')
cString := replace(cString,'Í','I')
cString := replace(cString,'Ì','I')
cString := replace(cString,'Î','I')
cString := replace(cString,'Ï','I')
cString := replace(cString,'Ó','O')
cString := replace(cString,'Ò','O')
cString := replace(cString,'Õ','O')
cString := replace(cString,'Ô','O')
cString := replace(cString,'Ö','O')
cString := replace(cString,'Û','U')
cString := replace(cString,'Ú','U')
cString := replace(cString,'Ù','U')
cString := replace(cString,'Ü','U')
cString := replace(cString,'Ç','C')

Return cString
//-------------------------------------------------------------------
/*/{Protheus.doc} cleanSQL(lString)
Função utiliza para montar o replace da query, para localizar os registros com ou sem caracteres especiais

@Param lString Define se a palavra chave deve ser convertida pra letra maiuscula na query

@Return cString Palavra chave com replace

@author Raphael Zei Cartaxo Silva
@since 12/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
function cleanSQL(lString)
Local cString := "UPPER(##COLUMN##)"

cString := I18N("replace(#1,'''','')",{cString})
cString := I18N("replace(#1,'´','')",{cString})
cString := I18N("replace(#1,'`','')",{cString})
cString := I18N("replace(#1,',','')",{cString})
cString := I18N("replace(#1,'.','')",{cString})
cString := I18N("replace(#1,'(','')",{cString})
cString := I18N("replace(#1,')','')",{cString})
cString := I18N("replace(#1,'/','')",{cString})
cString := I18N("replace(#1,'\','')",{cString})
cString := I18N("replace(#1,'-','')",{cString})
cString := I18N("replace(#1,':','')",{cString})
cString := I18N("replace(#1,'¿','')",{cString})
cString := I18N("replace(#1,'*','')",{cString})
cString := I18N("replace(#1,'+','')",{cString})
cString := I18N("replace(#1,'#2','')",{cString,'"'})
cString := I18N("replace(#1,'_','')",{cString})

If lString
	cString := I18N("replace(#1,' ','')",{cString})
	cString := I18N("replace(#1,'ª','')",{cString})
	cString := I18N("replace(#1,'º','')",{cString})
	cString := I18N("replace(#1,'Á','A')",{cString})
	cString := I18N("replace(#1,'À','A')",{cString})
	cString := I18N("replace(#1,'Ã','A')",{cString})
	cString := I18N("replace(#1,'Â','A')",{cString})
	cString := I18N("replace(#1,'Ä','A')",{cString})
	cString := I18N("replace(#1,'É','E')",{cString})
	cString := I18N("replace(#1,'È','E')",{cString})
	cString := I18N("replace(#1,'Ê','E')",{cString})
	cString := I18N("replace(#1,'Ë','E')",{cString})
	cString := I18N("replace(#1,'Í','I')",{cString})
	cString := I18N("replace(#1,'Ì','I')",{cString})
	cString := I18N("replace(#1,'Î','I')",{cString})
	cString := I18N("replace(#1,'Ï','I')",{cString})
	cString := I18N("replace(#1,'Ó','O')",{cString})
	cString := I18N("replace(#1,'Ò','O')",{cString})
	cString := I18N("replace(#1,'Õ','O')",{cString})
	cString := I18N("replace(#1,'Ô','O')",{cString})
	cString := I18N("replace(#1,'Ö','O')",{cString})
	cString := I18N("replace(#1,'Û','U')",{cString})
	cString := I18N("replace(#1,'Ú','U')",{cString})
	cString := I18N("replace(#1,'Ù','U')",{cString})
	cString := I18N("replace(#1,'Ü','U')",{cString})
	cString := I18N("replace(#1,'Ç','C')",{cString})
EndIf

Return cString

//-------------------------------------------------------------------
/*/{Protheus.doc} ExecOpc(cTitulo,nOpc,cTabela,cFonte)
Função utilizada para iniciar abertura da view para operações de
inclusão ou visualização

@Param cTitulo Titulo da operação
@Param nOpc    Operação: 1 - Visualizar, 3 - Incluir, 4 - Alterar
@Param cTabela Tabela para consulta
@Param cFonte Nome do fonte (JURAXXX) utilizado para abertura da view
@Param nReduz Percentual de redução da view quando é informado o fonte

@Return

@author Jorge Luis Branco Martins Junior
@since 31/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function ExecOpc(cTitulo,nOpc,cTabela,cFonte,nReduz)
	Local oView    := ViewDef()
	Default nReduz := 0
	OpenView(cTitulo,nOpc,cTabela,oView,cFonte,nReduz)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} OpenView(cTitulo,nOpc,cTabela,oView,cFonte)
Função utilizada para abrir a view recebida por parâmetro para
operações de inclusão ou visualização

@Param cTitulo Titulo da operação
@Param nOpc    Operação: 1 - Visualizar, 3 - Incluir
@Param cTabela Tabela para consulta
@Param oView   Objeto da View de dados a ser exibida
@Param cFonte Nome do fonte (JURAXXX) utilizado para abertura da view
@Param nReduz Percentual de redução da view quando é informado o fonte

@Return

@author Jorge Luis Branco Martins Junior
@since 31/08/16
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function OpenView(cTitulo,nOpc,cTabela,oView,cFonte,nReduz)
Default cFonte := INFOSX2( cTabela , 'X2_SYSOBJ' )
Default nReduz := 0

If Empty(cFonte)
	oExecView := FWViewExec():New()
	oExecView:setTitle(cTitulo + " - " + INFOSX2( _cTable , 'X2_NOME' ) )

	oExecView:setOK({|| .T.})

	oExecView:setReduction(10)

	oExecView:setOperation(nOpc)
	oExecView:setView(oView)
	oExecView:setModel(oView:GeTModel())

	oExecView:openView(.F.)
Else
	FWExecView(cTitulo,cFonte,nOpc,,{||.T.},,nReduz)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JF3TrtFilt(cFiltro,cTab)
Função utilizada para tratar os filtros recebidos transformando-os em
filtros de query

@Param cFiltro Filtro a ser tratado
@Param cTab    Tabela em que será executado o filtro

@Return cFiltro Filtro tratado

@author Jorge Luis Branco Martins Junior
@since 08/09/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JF3TrtFilt(cFiltro,cTab)
Local aParse    := {}
Local cTemp     := ""
Local lVolta    := .F.
Local nCt       := 0

If !Empty(cFiltro)
	//Filtro com função
	if AT("@#",cFiltro) > 0
		cTemp := AllTrim(SubStr(cFiltro,3))
		cFiltro := Eval({|| &(cTemp)})
		cFiltro := Replace(cFiltro,"@#","")
		cFiltro := Replace(cFiltro,"#@","")
	Endif

	//Filtro de consulta padrão
	aParse := STRTOKARR(cFiltro,"==")
	For nCt := 1 to len(aParse)
		if !lVolta //valida se o loop não foi recuado
			cTemp := aParse[nCt]
			lVolta := .F.
		Endif

		if At("M->",cTemp) > 0 .Or. (At("->",cTemp) > 0 .And. cTab != SubString(cTemp,AT("->",cTemp)-3,3))
			cTemp := "'" + &(cTemp) + "'"
			/*if EMPTY(replace(cTemp,"'",""))
				Loop
			Endif*/
		ElseIf At("FWFLDGET",cTemp) > 0
			cTemp := "'" + &(cTemp) + "'"
		Elseif cTab == SubString(cTemp,AT("->",cTemp)-3,3)
			cTemp := Replace(cTemp,SubStr(cTemp,AT("->",cTemp)-3,5),SubStr(cTemp,AT("->",cTemp)-3,3) + ".")
		Endif

		if AT("->",cTemp) > 0
			nCt--
			lVolta := .T.
		Else
			cFiltro := Replace(cFiltro,aParse[nCt],cTemp)
		Endif

	Next

Endif

cFiltro := replace(cFiltro,"=="," = ")
cFiltro := replace(cFiltro,".AND."," and ")
cFiltro := replace(cFiltro,".OR."," or ")

Return cFiltro

//-------------------------------------------------------------------
/*/{Protheus.doc} JF3SetBKP(cTable,aCampos,cFilter,cFields)
Função utilizada para setar variáveis de BKP e variáveis estáticas de controle

@param cTable  Tabela da consulta
@param aCampos Array com campos que serão exibidos na consulta
@param cFilter Filtro a ser tratado
@param cFields Campos da consulta

@author Jorge Luis Branco Martins Junior
@since  09/09/16
/*/
//-------------------------------------------------------------------
Static Function JF3SetBKP(cTable, aCampos, cFilter, cFields)

	If _cTable <> cTable .Or. _aCampos <> aCampos .Or. _cFilter <> cFilter .Or. _cFields <> cFields
		_BKPcTable := _cTable
		_cTable    := cTable

		_BKPaCampos := _aCampos
		_aCampos    := aCampos

		_BKPcFilter := _cFilter
		_cFilter    := cFilter

		_BKPcFields := _cFields
		_cFields    := cFields
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} JF3GetBKP(cTable,aCampos,cFilter,cFields)
Função utilizada para preencher as variáveis estáticas de controle com os
valores das variáveis de BKP

@Param cTable  Tabela da consulta
@Param aCampos Array com campos que serão exibidos na consulta
@Param cFilter Filtro a ser tratado
@Param cFields Campos da consulta

@author Jorge Luis Branco Martins Junior
@since  09/09/16
/*/
//-------------------------------------------------------------------
Static Function JF3GetBKP(cTable,aCampos,cFilter,cFields)

If _BKPcTable <> cTable
	JF3SetBKP(cTable, aCampos, cFilter, cFields)
EndIf

If !Empty(_BKPcTable)  .And. _BKPcTable == cTable   .And. _BKPcTable <> _cTable
	_cTable  := _BKPcTable
EndIf
If !Empty(_BKPaCampos) .And. _BKPaCampos == aCampos .And. _BKPaCampos <> _aCampos
	_aCampos := _BKPaCampos
EndIf
If !Empty(_BKPcFilter) .And. _BKPcFilter == cFilter .And. _BKPcFilter <> _cFilter
	_cFilter := _BKPcFilter
EndIf
If !Empty(_BKPcFields) .And. _BKPcFields == cFields .And. _BKPcFields <> _cFields
	_cFields := _BKPcFields
EndIf

Return
