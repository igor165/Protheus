#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TJURPESQFW.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqFW
CLASS TJurPesqFW

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurPesqFW FROM TJurPesquisa

	DATA cRotina //indica a rotina utilizada nas operações
	DATA oCalend
	DATA aGraficos
	DATA cCodEquipe //codigo da equipe
	DATA oCmbEquipe //Combo de equipes
	DATA oCmbPart //Combo de participantes
	DATA cCodPart //Codigo do participante
	DATA oPnlEquipe //Panel de equipes
	DATA aListaPart // Array de participantes da equipe

	METHOD New (cTipo, cTitulo, cRotina) CONSTRUCTOR
	METHOD SetMEBrowse (oLstPesq)
	METHOD LegFollUp()
	METHOD LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa)
	METHOD MenJur162(oObj, nRow, nCol)
	METHOD getCajuri(nLinha)
	METHOD getCodigo(nLinha)
	METHOD RelTMS(cTpRel,oLstPesq)
	METHOD getMenu(oMenu)
	METHOD getBrHeader()
	METHOD getBrCols(cSQL, cCampos, aHead)
	METHOD getCalendario(oPanel)
	METHOD CalRefresh( dDate, oCmbEquipe, oCmbPart, cCodEquipe )
	METHOD CalRClick( oItem )
	METHOD calAddFW( dDate, cTimeIni, cTimeFim )
	METHOD GetCondicao(aSQL, cNSZName)
	METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca, xFiltro)
	METHOD getExcecaoLote()
	METHOD OpAltLote(aCampos, aCampDe)
	METHOD getFilial(nLinha)
	METHOD ProcNWG(oLstPesq)
	METHOD Atualiza()
	METHOD ListaEquip()
	METHOD ListaPart(cCodEquipe)
	METHOD getparts()
	METHOD atuCmbPart()
	METHOD ReenvWfCor()
	METHOD getComplLote()
	METHOD VlAltLote()
	METHOD dblClickBrw()

ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqFW
CLASS TJurPesqFW

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTipo, cTitulo, cRotina) CLASS TJurPesqFW
Default cRotina := "JURA106"

_Super:New (cTitulo)

Self:setTipoPesq(cTipo)
Self:SetTabPadrao("NTA")
Self:cRotina := cRotina
Self:aGraficos := {}

If !(self:montalayout())
	//Self:oDesk:SetLayout({{"01",50,.F.},{"02",50,.F.},{"03",50,.T.},{"04",50,.F.},{"05",50,.F.}}) //layout da tela.
	Self:oDesk:SetLayout({{"01",50,.F.},{"02",50,.F.},{"03",50,.T.}}) //layout da tela. (Retirada a áre dos gráficos para análise.

	Self:oPnlPrinc := Self:loadCmbConfig(Self:oDesk:getPanel("01"))

	Self:loadGrid(Self:oDesk:getPanel("03"))
	Self:loadAreaCampos(Self:oPnlPrinc)
	Self:getCalendario(Self:oDesk:getPanel("02"))
//	aAdd(Self:aGraficos,Self:getGrafico(Self:oDesk:getPanel("04"), "NTA", "JURA106", MODE_VIEW_CHART, "_FW001" /*DSFWMesP*/ ) )
//	aAdd(Self:aGraficos,Self:getGrafico(Self:oDesk:getPanel("05"), "NTA", "JURA106", MODE_VIEW_CHART, "_FW005" /*DSFWSemanaP*/ ) )
EndIf

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} SetMEBrowse
Função que faz a configuração dos eventos do mouse no Browse

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetMEBrowse (oLstPesq) CLASS TJurPesqFW

oLstPesq:SetDoubleClick({|| Self:dblClickBrw() })
oLstPesq:SetRightClick({|oObj, nRow, nCol| Self:MenJur162(oObj, nRow, nCol)})

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LegFollUp
Legenda da pesquisa do tipo de Follow Up

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD LegFollUp() CLASS TJurPesqFW
Local aCor := {}
Local cCadastro:="Status Follow Up"//"Status Follow Up"

aAdd(aCor,{"BR_VERDE"	, STR0002})	//"BR_VERDE"#"Efetuado"
aAdd(aCor,{"BR_VERMELHO", STR0003})	//"BR_VERMELHO"#"Pendente - Em Atraso"
aAdd(aCor,{"BR_CINZA"	, STR0004})	//"BR_CINZA"#"Cancelado"
aAdd(aCor,{"BR_AMARELO"	, STR0005})	//"BR_AMARELO"#"Pendente - Em Andamento"
aAdd(aCor,{"BR_AZUL"	, STR0006})	//"BR_AZUL"#"Reagendado"
aAdd(aCor,{"BR_BRANCO"	, STR0043})	//"BR_BRANCO"#"Em Aprovação"

BrwLegenda(cCadastro,OemToAnsi(STR0007),aCor)//"Status"

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadRotina
Função genérica para criação do oModel com os campos correpondentes
ao tipo de assunto jurídico, follow up ou garantia.
Uso Geral.
@param  cCod    	    Código do assunto jurídico / follow up /garantia
@param  nOper   	    Código da operação do Protheus
@Param	 aObj 		    Array com os Objetos de campos de filtro.

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa) CLASS TJurPesqFW
Local lOK	:= .T.
Local nRet	:= 1

Local oM106
Local cNTACod := ""
Local bOk := {|| IIF(nOper == 3,cNTACod := oM106:GetValue("NTAMASTER","NTA_COD"),), .T.}
Local bClose := {|| .T.}

Default oModel := NIl
Default nTela := 0
Default lFecha 	:= .F.
Default lFazPesquisa := .T. // Usado na rotina de Follow-up. Indica se realiza a pesquisa após o Fup ser alterado e houver confirmação (essa alteração dita é quando o Fup é reaberto em modo de alteração após a inclusão) e a tela for fechada.

If !Empty(nOper)

	If nOper == 3 .And. (cTipoAJ == '000' .Or. cTipoAJ == '')
		If cTipoAJ == '000'
	  		Alert(STR0008) //"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	  		lOk := .F. // Necessário para não abrir a tela de pequisa
	  		nRet := 1 // Necessário para não abrir a tela de pequisa
		EndIf

	ElseIf nOper <> 3
		If cCod <> NIL .And. !Empty(cCod)
			DbSelectArea("NTA")
			NTA->(DBSetOrder(1))
			NTA->(dbSeek(cFil + cCod))
		Else
			lOk:= .F.
		EndIf
	EndIf

	cTipoAsJ := c162TipoAs

	If lOK
		INCLUI := (nOper==3)
		ALTERA := (nOper==4)

		//Caso seja enviado algum modelo para abrir os dados, fechar a tela automaticamente.
		if oModel != Nil
			lFecha := .T.
		endif

		If INCLUI
			oM106 := FWLoadModel( 'JURA106' )
			oM106:SetOperation( nOper )
			oM106:Activate()
			bClose := NIL
		Else
			oM106 := Nil
		Endif

		MsgRun(STR0009,STR0010,{|| nRet:=FWExecView(cMsg,Self:cRotina, nOper,, , bOk ,,,,,,oM106 )}) //"Carregando..." e "Pesquisa de Follow-up"

		If INCLUI .AND. nRet == 0 .And. ("2" $ JGetParTpa(cTipoAJ, "MV_JALTREG", "1"))
			If !Empty(cNTACod)
				//Se incluiu e foi criado um assunto jurídico, abrir o mesmo.
				Self:JurProc(xFilial('NTA'),cNTACod,,4,,,,,.F.)
			Endif
		Endif

		if  nRet == 0
			//Atualiza os componentes da tela
			Self:Atualiza()
		Endif

	EndIf

Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MenJur162()
Função que monta o menu de relatórios de follow up ao clicar com
o botão direito do mouse no grid de resultados.


@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MenJur162(oObj, nRow, nCol) CLASS TJurPesqFW
Local oMenu
Local oMenuItem := {}

MENU oMenu POPUP of oObj

aAdd( oMenuItem, MenuAddItem( "Relatorio Follow-Up",,, .T.,,,, oMenu, { ||Self:RelTMS("F",Self:oLstPesq)},,,,, { || .T. } ) )//"Relatorio Follow-Up"
aAdd( oMenuItem, MenuAddItem( "Relatorio Pauta Compromisso",,, .T.,,,, oMenu, { ||Self:RelTMS("P",Self:oLstPesq)},,,,, { || .T. } ) )//"Relatorio Pauta Compromisso"
ENDMENU

ACTIVATE POPUP oMenu AT nRow, nCol

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getCajuri
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCajuri (nLinha) CLASS TJurPesqFW
Return Self:JA162Assjur("NTA_CAJURI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodigo
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCodigo (nLinha) CLASS TJurPesqFW
Return Self:JA162Assjur("NTA_COD", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} RelTMS
Função que gera o relatorio TMS Printer para Follow-Ups


@author Marcos Kato
@since 08/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD RelTMS(cTpRel,oLstPesq) CLASS TJurPesqFW
Local lAndam   := .F.
Local lAtvAnd  := .T.
Local lImpTMS  := .T.
Local oRelat   := NIL
Local oGroup   := NIL
Local oAndam   := NIL

If !cTpRel=="P"
	DEFINE MSDIALOG oRelat TITLE STR0013 FROM 000, 000  TO 100, 280  PIXEL STYLE DS_MODALFRAME//"Follow Ups"
	@ 005, 005 GROUP oGroup TO 045, 140 PROMPT ""   OF oRelat  PIXEL
	@ 010, 010 CHECKBOX oAndam  VAR lAndam  PROMPT STR0020 When lAtvAnd SIZE 055, 010 OF oGroup PIXEL//"Andamento"
	Define SButton From 010, 110 Type 1 Enable OF oRelat Action oRelat:End()
	Define SButton From 025, 110 Type 2 Enable OF oRelat Action (lImpTMS:=.F.,oRelat:End())
	oRelat:lEscClose:=.F.

	ACTIVATE MSDIALOG oRelat CENTERED
Else
	lAtvAnd := .F.
EndIf

MsgRun(STR0022,STR0023, {||Self:ProcNWG(oLstPesq)})//"Processando Follow-Ups"#"Aguarde...",

If lImpTMS
	If cTpRel=="F"//Follow Up
		If Existblock( 'JURR106' )
			U_JURR106(Self:cUser, Self:cThread,lAndam)
		Else
			JURR106(Self:cUser, Self:cThread,lAndam)
		EndIf
	ElseIf cTpRel=="P"//Pauta de Compromisso
		If Existblock( 'JURR106P' )
			U_JURR106P(Self:cUser, Self:cThread)
		Else
			JURR106P(Self:cUser, Self:cThread)
		EndIf
	Endif
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} setMenu()
Função que monta o menu lateral principal.

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getMenu(oMenu) CLASS TJurPesqFW
Local aRelat   := {}
Local aOpera   := {}
Local aEspec   := {}
Local cRotina  := '05'

aAdd(aRelat, {STR0013,{|| IIF(Self:befAction(),Self:RelTMS("F",Self:oLstPesq),)} }) //"Follow-Ups"
aAdd(aRelat, {STR0025,{|| IIF(Self:befAction(),Self:RelTMS("P",Self:oLstPesq),)} }) //"Pauta Compromissos"

aAdd(aOpera, {STR0044,{|| IIF(Self:befAction(),Self:JA162Menu(1,Self:oLstPesq,,Self:oCmbConfig),)},{|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 2)) .Or. Empty(Self:cGrpRest)) }}) //"Visualizar"
aAdd(aOpera, {STR0045,{|| Self:JA162Menu(3,Self:oLstPesq,Self:aObj,Self:oCmbConfig)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 3)) .Or. Empty(Self:cGrpRest))},K_ALT_I }) //"Incluir"
aAdd(aOpera, {STR0030,{|| IIF(Self:befAction(), ( Self:JA162Menu(4,Self:oLstPesq,Self:aObj,Self:oCmbConfig) ),)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 4)) .Or. Empty(Self:cGrpRest))},K_ALT_A }) //"Alterar"
aAdd(aOpera, {STR0026,{|| IIF(Self:befAction(),Self:JA162Menu(5,Self:oLstPesq,Self:aObj,Self:oCmbConfig),)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 5)) .Or. Empty(Self:cGrpRest)) },K_ALT_E }) //"Excluir"

//Fluxo de correspondente 1=Follow-up
If SuperGetMV("MV_JFLXCOR", , 1) == 1
	Aadd(aEspec, {STR0046, {|| IIF(Self:befAction(), Processa( { || Self:ReenvWfCor() } ), )} }) //"Reenvia WF"
EndIf

oMenu := Self:setMenuPadrao(oMenu, ,aOpera, aRelat, aEspec, cRotina)

Return oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrHeader() CLASS TJurPesqFW
Local aCampos := {}

//Campos padrão
aAdd(aCampos, {"NTA_COD",JA160X3Des("NTA_COD"),"2"})
aAdd(aCampos, {"NTA_CAJURI",JA160X3Des("NTA_CAJURI"), "2"})
aAdd(aCampos, {"NTA_FILIAL",JA160X3Des("NTA_FILIAL"), "2"})
aAdd(aCampos, {"NTA_DTFLWP",JA160X3Des("NTA_DTFLWP"), "2"})
aAdd(aCampos, {"NTA_REAGEN",JA160X3Des("NTA_REAGEN"), "2"})
aAdd(aCampos, {"NTA_CRESUL",JA160X3Des("NTA_CRESUL"), "2"})


Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrCols()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrCols(cSQL, cCampos, aHead) CLASS TJurPesqFW
Local aCol		:= {}
Local aArea    := GetArea()
Local cLista	:= GetNextAlias()
Local nQtd		:= 0
Local nCols		:= 0
Local nX		:= 0
Local nLinha	:= 0
Local cTipo		:= "" //guarda o tipo para preencher a legenda.

//Proteção para caso não venha uma query montada
cSQL := Iif( ValType(cSql) == "U" .Or. Empty(cSQL),;
			Self:JQryPesq("SELECT "+cCampos+" FROM "+RetSqlName("NTA")+" NTA001 ",Self:cTabPadrao) +" WHERE 1=2 ",;
			cSql)


cSQL := ChangeQuery(cSQL)
//Change query troca '' por ' ', o que compromete com a pesquisa
cSQL := StrTran(cSQL,",' '",",''")
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cLista, .T., .F.)

nQtd:=0
dbSelectArea(cLista)

While (cLista)->(!Eof())

	cTipo := Posicione('NQN',1,xFilial('NQN')+(cLista)->NTA_CRESUL,'NQN_TIPO')

	aAdd(aCol,Array(LEN(aHead)+4))
	nQtd++
	nLinha++
	nCols:=0
	For nX := 1 To LEN(aHead)
		nCols++
		If nX == 1
			Do case
				Case cTipo == '2' //==>GREEN - EFETUADO
				  aCol[nLinha][nCols] :=Self:oVerde
				Case cTipo == '1' .And. SToD((cLista)->NTA_DTFLWP)<DATE()// ==>RED - PENDENTE EM ATRASO
				  aCol[nLinha][nCols] :=Self:oVermelho
				Case cTipo == '3' //==>GRAY-CANCELADO
				  aCol[nLinha][nCols] :=Self:oCinza
				Case (cTipo == '1' .Or. cTipo == '5') .AND. SToD((cLista)->NTA_DTFLWP) >= DATE() .AND. (cLista)->NTA_REAGEN == '2'//==>YELLOW-PENDENTE EM ANDAMENTO
				  aCol[nLinha][nCols] :=Self:oAmarelo
				Case cTipo == '1' .AND. SToD((cLista)->NTA_DTFLWP) >= DATE() .AND. (cLista)->NTA_REAGEN == '1'//==>BLUE-REAGENDADO
				  aCol[nLinha][nCols] :=Self:oAzul
				Case cTipo == '4' //==>WHITE-EM APROVACAO
				  aCol[nLinha][nCols] :=Self:oBranco
				Case cTipo == '5'
				  aCol[nLinha][nCols] :=Self:oAmarelo
			EndCase
		Elseif (aHead[nX][10] != "V") //Valida se não é um campo virtual para evitar um fieldget/fieldpos
			aCol[nLinha][nCols] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))
		Endif
	Next nX

	aCol[nLinha][LEN(aHead)+1] := (cLista)->NTA_COD
	aCol[nLinha][LEN(aHead)+2] := (cLista)->NTA_CAJURI
	aCol[nLinha][LEN(aHead)+3] := (cLista)->NTA_FILIAL
	aCol[nLinha][LEN(aHead)+4] := .F.

	(cLista)->(dbSkip())
End

(cLista)->( dbcloseArea() )
RestArea( aArea )
Self:AtuCount(nQtd)
Self:cSQLFeito := cSQL

Return aCol

//-------------------------------------------------------------------
/*/{Protheus.doc} getCalendario
Função que cria o componente de calendário e coloca na tela.

@author André Spirigoni Pinto
@since 09/06/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCalendario( oPanel ) CLASS TJurPesqFW

//Panel do combo
Self:oPnlEquipe				:= tPanel():New(0,0,'',oPanel,,,,,,60,15)
Self:oPnlEquipe:Align		:= CONTROL_ALIGN_TOP
Self:oPnlEquipe:nCLRPANE	:= RGB(240,240,240)

//Combo de equipe
@ 001, 001 Say STR0035 Size 030, 020 Pixel Of Self:oPnlEquipe //Equipe
Self:oCmbEquipe	:= TJurCmbBox():New(1,30,65,10,Self:oPnlEquipe,Self:ListaEquip(),{|| self:atuCmbPart() },.F. /*lPanel*/,,'::cCmbEquipe')

//Calendario
Self:oCalend := Nil
Self:oCalend := FWCalendarWidget():New( oPanel )

Self:oCalend:SetbNewActivity( { | dDate, cTimeIni, cTimeFin | IIF(((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst("05", 3)) .Or. Empty(Self:cGrpRest)),Self:calAddFW( dDate, cTimeIni, cTimeFin ), MsgAlert(STR0040) ) } ) //"Operação não permitida"
Self:oCalend:SetbClickActivity( { | oItem | IIF(((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst("05", 4)) .Or. Empty(Self:cGrpRest)),Self:JurProc(xFilial("NTA"),oItem:cId,,4,10), MsgAlert(STR0040) ) } ) //"Operação não permitida"
Self:oCalend:SetbRefresh( { | dDate | Self:CalRefresh( dDate, Self:oCmbEquipe, Self:oCmbPart, Self:cCodEquipe ) } )
Self:oCalend:SetbRightClick( { | oItem | Self:CalRClick( oItem ) } )
Self:oCalend:Activate()

Return Self:oCalend

//---------------------------------------------------------------------------
/*/{Protheus.doc} CalRefresh

Funcao chamada para atualizar os dados do calendario
Essa funcao recebe uma data e deverá retornar um array de objetos do tipo
FWCalendarActivity() com as atividades que devem ser exibidas no calendario

@sample	CA290SkTsk( cRotina, cFonte )

@param		cRotina - Nome da rotina
			cFonte	- Nome do fonte da rotina

@return	Nenhum

@author	André Spirigoni Pinto
@since		30/01/2015
@version	P12
/*/
//---------------------------------------------------------------------------
METHOD CalRefresh( dDate, oCmbEquipe, oCmbPart, cCodEquipe ) CLASS TJurPesqFW
Local aArea      := GetArea()
Local aItems     := {}
Local oItem      := Nil
Local aPrior     := { FWCALENDAR_PRIORITY_HIGH, FWCALENDAR_PRIORITY_MEDIUM, FWCALENDAR_PRIORITY_LOW, FWCALENDAR_PRIORITY_HIGH, FWCALENDAR_PRIORITY_MEDIUM }
Local cAliasTmp  := GetNextAlias()
Local cCodUsr    := Self:cUser
Local cQuery     := ""
Local cParts     := ""
Local nSumDay    := 0
Local cHorIni    := "0001"
Local cHorFim    := ""
Local dDuracao   := "0059"
Local cCodPar

DbSelectArea( "NTA" )		// Atividades
NTA->( DbSetOrder( 1 ) )		// AOF_FILIAL+AOF_CODIGO

/*
Obs: é possivel definir a cor da atividade de duas formas.
1) Utilizando o metodo SetPriority(), será definida uma cor padrao de acordo com a prioridade da tarefa passada
2) Utilizando o metodo SetColor(cHexColor) e passando uma cor em hexadecimal
Se utilizar o SetColor() não utilize o SetPriority.
*/

cQuery := "SELECT NTA.NTA_FILIAL, NTA.NTA_COD, NQN.NQN_TIPO "+ CRLF
cQuery += " FROM " + RetSqlName("NTA") + " NTA " + CRLF
cQuery +=   " JOIN " + RetSqlName("NQN") + " NQN " + CRLF
cQuery +=    " ON (NQN.NQN_COD = NTA_CRESUL) " + CRLF
cQuery += " WHERE NTA.NTA_FILIAL = '" + FwxFilial("NTA") + "'" + CRLF
cQuery +=   " AND NTA.NTA_DTFLWP = '" + dTos(dDate) + "'" + CRLF
cQuery +=   " AND NTA.D_E_L_E_T_= ' '" + CRLF
cQuery +=   " AND NQN.D_E_L_E_T_= ' '" + CRLF
cQuery +=   " AND EXISTS ("+ CRLF
cQuery +=       " SELECT 1 FROM " + RetSqlName("NTE") + " NTE " + CRLF
cQuery +=         " JOIN " + RetSqlName("RD0") + " RD0 " + CRLF
cQuery +=           " ON (RD0.RD0_CODIGO = NTE.NTE_CPART " + CRLF
cQuery +=           " AND RD0.RD0_FILIAL = '" + FwxFilial("RD0") + "'" + CRLF
cQuery +=           " AND RD0.D_E_L_E_T_ = ' ' )" + CRLF
cQuery +=        " WHERE NTA.NTA_FILIAL = NTE.NTE_FILIAL " + CRLF
cQuery +=          " AND NTA.NTA_COD = NTE.NTE_CFLWP " + CRLF
cQuery +=          " AND NTE.D_E_L_E_T_ = ' '" + CRLF


//Verifica se alguma equipe foi selecionada
If !EMPTY(Self:oCmbEquipe:cValor)
	Self:cCodEquipe := SubStr(Self:oCmbEquipe:cValor,1,6) //Guarda codigo da equipe

	cQuery += " AND ( EXISTS (SELECT 1 FROM " + RetSqlName("NZ9")+ " NZ9"+ CRLF
	cQuery += " WHERE NZ9.NZ9_CEQUIP = " + "'"+ Self:cCodEquipe + "'" + CRLF
	cQuery +=   " AND NZ9.NZ9_FILIAL = '" + FwxFilial("NZ9") + "'" + CRLF
	cQuery +=   " AND NZ9.D_E_L_E_T_ = ' '" + CRLF
	cQuery +=   " AND NZ9.NZ9_CPART = RD0.RD0_CODIGO " + CRLF

	//Cria o combo de participantes, se já não estiver criado
	If (Self:oCmbPart == NIL)
		@ 001, 110 Say STR0036 Size 040, 020 Pixel Of Self:oPnlEquipe //Participantes
		//Self:oCmbPart	:= TJurCmbBox():New(1,150,60,10,Self:oPnlEquipe,Self:ListaPart(Self:cCodEquipe),{|| Self:oCalend:Refresh()},.F. /*lPanel*/, {|| !Empty(Self:oCmbEquipe:cValor)} )
		Self:oCmbPart := TComboBox():New(1,150,{|u|if(PCount()>0,Self:cCodPart:=u,Self:cCodPart)},Self:ListaPart(Self:cCodEquipe),60,10,Self:oPnlEquipe,,{|| Self:oCalend:Refresh() },,,,.T.,,,,{ || !Empty(Self:oCmbEquipe:cValor) },,,,,'Self:cCodPart')
	EndIf

	//Verifica se algum participante foi selecionado.
	If	(Self:oCmbPart != NIL) .AND. (Self:cCodPart != STR0037) //"Todos"
		cCodPar := SubStr(Self:cCodPart,1,6)
		cQuery +=   " AND NZ9_CPART = " + "'" + cCodPar  +"' ) )" + CRLF
	Else
		cQuery +=   " ) OR RD0.RD0_USER = '" + cCodUsr + "' )" + CRLF
	EndIf

Else
	cQuery += "AND RD0.RD0_USER = '" + cCodUsr + "'" + CRLF
Endif

cQuery +=   " ) "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cAliasTmp, .T., .F.)

While (cAliasTmp)->(!Eof())
	//usuarioRD0 += " " + (cAliasTmp)->RD0_NOME

	If NTA->(DbSeek((cAliasTmp)->NTA_FILIAL+(cAliasTmp)->NTA_COD))

		cParts := self:getparts(NTA->NTA_COD)

		oItem := FWCalendarActivity():New()

		oItem:SetID(NTA->NTA_COD)
		oItem:SetTitle(JurGetDados('NQS',1,xFilial('NQS')+NTA->NTA_CTIPO,'NQS_DESC'))
		oItem:SetNotes(cParts + ' - ' + SubStr(NTA->NTA_DESC,1,200))

		If (val((cAliasTmp)->NQN_TIPO) > Len(aPrior))
			oItem:SetPriority(aPrior[Len(aPrior)])
		Else
			oItem:SetPriority(aPrior[val((cAliasTmp)->NQN_TIPO)])
		EndIf

		oItem:SetDtIni(NTA->NTA_DTFLWP)

		If !Empty(NTA->NTA_HORA)
			cHorIni := JurHora(NTA->NTA_HORA)
			oItem:SetHrIni(cHorIni)

			If !Empty(NTA->NTA_DURACA)
				dDuracao := NTA->NTA_DURACA
			Else
				dDuracao := "0100"
			EndIf

			//fazer a conta com o campo duração para preencher o campo de hora fim.
			cHorFim := JurSumHora(StrTran(cHorIni,":",""),dDuracao, .F.,@nSumDay)
			oItem:SetHrFin(cHorFim)

		Else
			oItem:SetHrIni(JurHora(cHorIni))
			cHorFim := JurSumHora(cHorIni,dDuracao, .F.,@nSumDay)
			oItem:SetHrFin(cHorFim)
		EndIf

		If nSumDay > 0
			oItem:SetDtFin(NTA->NTA_DTFLWP + nSumDay)
		Else
			oItem:SetDtFin(NTA->NTA_DTFLWP)
		EndIf

		aAdd(aItems,oItem)

	EndIf

	(cAliasTmp)->(DbSkip())
End

(cAliasTmp)->( dbcloseArea() )

RestArea(aArea)

Return(aItems)

//---------------------------------------------------------------------------
/*/{Protheus.doc} CalRClick

Funcao chamada ao clicar com o botao direito

@param		oItem - Item do calendário sobre o qual foi clicado com o botão direito

@return	Nenhum

@author	André Spirigoni Pinto
@since		30/01/2015
@version	P12
/*/
//---------------------------------------------------------------------------
METHOD CalRClick( oItem ) CLASS TJurPesqFW
Local aMenu := {}

If oItem != nil
	//-------------------------------------------------------
	// Quando clicou com o direito sobre algum agendamento
	//-------------------------------------------------------
	aAdd( aMenu, { STR0030, "J106CalOp(Self,'" + oItem:cId + "',4) " } )	// "Alterar"
	aAdd( aMenu, { STR0026, "J106CalOp('" + oItem:cId + "',5) " } )			// "Excluir"
Else
	//-------------------------------------------------------
	// Quando clicou com o direito sobre um horário livre
	//-------------------------------------------------------
	aAdd( aMenu, { STR0027, "J106CalOp( /*cCodigo*/ ,3 )"  } )		// "+ Criar Atividade"
EndIf

Return {}

//---------------------------------------------------------------------------
/*/{Protheus.doc} calAddFW

Funcao que realiza a chamada da rotina de inclusao de atividades

@param		dDate - Dia da atividade
			cTimeIni - Hora inicial da atividade
			cTimeFim - Hora final da atividade

@author	André Spirigoni Pinto
@since		26/01/2015
/*/
//---------------------------------------------------------------------------
METHOD calAddFW( dDate, cTimeIni, cTimeFim ) CLASS TJurPesqFW
Local oModel	:= Nil

oModel := FWLoadModel( Self:cRotina )
oModel:SetOperation( MODEL_OPERATION_INSERT )
oModel:Activate()
oModel:SetValue( "NTAMASTER","NTA_DTFLWP", dDate )
oModel:SetValue( "NTAMASTER","NTA_HORA", cTimeIni )

Self:JurProc(,,,MODEL_OPERATION_INSERT,10,oModel)

Return ( .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} GetCondicao(aSQL, cNSZName)
Função utilizada para pegar todas as condições refernte a tabela a
ser utilizada para a montagem do SQL da pesquisa.
Uso Geral.

@Param	aSQL				Array com todas as condições dos campso a serem
										utilizados no filtro.
@Param	cNSZName		Nome da tabela NSZ.
@Return	cCondicao	todas as condições referente a tabela.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetCondicao(aSQL, cNSZName) CLASS TJurPesqFW
Local nI, cCondicao := " "
Local nQtd, aAux := {}
Local nFound := 0
Local aNTE :={}

aNTE:={}
nQtd := LEN(aSQL)
For nI := 1 to nQtd
	If !Empty(aSQL[nI][2])
		IF nI == 1
			If aSQL[nI][1]<>"NTE990"
				aAdd(aAux, {aSQL[nI][1], aSQL[nI][2]} )
			Else
				aAdd(aNTE,{Substr(aSql[nI][2],At("NTE_",aSql[nI][2]),Len(aSql[nI][2])-At("=",aSql[nI][2])),Substr(aSql[nI][2],At("'",aSql[nI][2])+1,Len(aSql[1][2])-At("'",aSql[nI][2])-1)})
			Endif
		Else
			nFound := aScan(aAux, { |aX| ALLTRIM(aX[1]) == ALLTRIM(aSQL[nI][1]) })
			If nFound > 0
				aAux[nFound][2] += " " + aSQL[nI][2] + " "
			Else
				aAdd(aAux, {aSQL[nI][1], aSQL[nI][2]})
			EndIF
		EndiF
	Endif
Next

//Verifica se foi pesquisado por algum campo da NTE
nFound := Ascan(aAux, {|aX| AllTrim(aX[1]) == RetSqlName("NTE")} )
If nFound > 0
	aAux[nFound][2] += " AND NTA_COD = NTE_CFLWP "
EndIf

nQtd := LEN(aAux)
For nI := 1 to nQtd
	IF aAux[nI][1] == cNSZName
		cCondicao += aAux[nI][2] +" "
	Else
		cCondicao += Self:GetEXISTS(aAux[nI][1], aAux[nI][2])
	EndIf
Next

Return cCondicao

//-------------------------------------------------------------------
/*/{Protheus.doc} getSQLPesq
Função utilizada para montar o SQL da pesquisa.
Uso Geral.

@Param	aObj	    Array com todos os campos de filtro da tela.
@Param  oCmbConfig	Combo que contém as configurações de Layout.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca, xFiltro) CLASS TJurPesqFW
Local nI, cSQL := ''
Local aSQL	     := {}
Local aSQLRest := {}
Local cTpAJ      := ""
Local NTAName  := Alltrim(RetSqlName("NTA"))
Local aFilUsr   := JURFILUSR( __CUSERID, "NTA" )
Local cTpPesq	:= Self:cTipoPesq
Local cPesqAtv	:= oCmbConfig:cValor

AAdd(aManual,{"NTA", "NTA001", "NSZ", "NSZ001", ""})
AAdd(aTroca,{"NTA", "NTA001"})

For nI := 1 to LEN(aObj)
	If !(aObj[nI] == NIL) .And. !(Empty(aObj[nI]:Valor))

		If  aObj[nI]:GetNameField() $ 'NUQ_CCOMAR/NUQ_CLOC2/NUQ_CLOC3/NUQ_NUMPRO/NSZ_CCLIEN/NUQ_CCORRE'
				AAdd(aManual,{"NSZ", "NSZ001", "NUQ", "NUQ001", "NUQ001.NUQ_INSATU = '1'"})
		Endif
		aAdd(aSQL, {aObj[nI]:GetTable(),Self:TrocaWhere(aObj[nI],aTroca)})// Tabela  Where
  EndIf
Next

cTpAJ := AllTrim( JurSetTAS(.F.) )

//Tratamento de aspas simples para a query
cTpAJ := IIf(  Left(cTpAJ,1) == "'", "", "'" ) + cTpAJ
cTpAJ += IIf( Right(cTpAJ,1) == "'", "", "'" )

//<- Restrição de cliente->
aSQLRest := Ja162RstUs()

cSQL := "SELECT "+cCampos+" "
cSQL += "FROM "+NTAName+" NTA001 "
cSQL := Self:JQryPesq(cSQL,Self:cTabPadrao, aManual)

If ( VerSenha(114) .or. VerSenha(115) )
	cSQL += " WHERE NTA_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) +  CRLF
Else
	cSQL += " WHERE NTA_FILIAL = '"+xFilial("NTA")+"'"+ CRLF
Endif

//Ponto de Entrada de Cláusula para Query - JA162QRY
If ExistBlock("JA162QRY")
	cSQL += ExecBlock("JA162QRY",.F.,.F.,{cTpAJ,cTpPesq,cPesqAtv})
EndIf

cSQL += "AND NTA001.D_E_L_E_T_ = ' ' "
cSQL += "AND NTA_DTFLWP <>' ' "

//<- Adiciona a restrição de Acesso ->
If !Empty(aSQLRest)
	cSQL += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ, /*cCodPart*/, /*cPesq*/, "NTA")+")"
EndIf

cSQL += " AND NSZ001.NSZ_TIPOAS IN (" + cTpAJ + ")"

cSQL += VerRestricao()  //Restricao de Escritorio e Area

If Len(aSql)>0
	cSQL += Self:GetCondicao(aSQL, NTAName)
Endif

//Ordenação
cSQL += " ORDER BY NTA001.NTA_DTFLWP, NTA001.NTA_HORA, NTA001.NTA_COD"

Return cSQL

//---------------------------------------------------------------------------
/*/{Protheus.doc} OpAltLote

Função que faz a alteração em lote da tabela principal da pesquisa usando os campos

@param		aCampos

@author	André Spirigoni Pinto
@since		09/02/2015
/*/
//---------------------------------------------------------------------------
METHOD OpAltLote(aCampos, aCampDe) CLASS TJurPesqFW
Local aArea   := GetArea()
Local cAlote  := GetNextAlias()
Local cSQL    := Self:MontaSQL()
Local aAltera := {}
Local oModel106
Local oNTA
Local oNTE
Local cCampo   := ""
Local nL       := 0
Local nI       := 0
Local nC       := 0
Local nQtd     := 0
Local aExcecao := Self:getExcecaoLote()
Local aErro    := {}
Local cMsg     := ""
Local nAltera  := 0
Local cJurProc := ""

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlote, .T., .F.)

//Preenche o array com os registros que serão alterados
While (cAlote)->(!Eof())
	aAdd(aAltera,{(cAlote)->NTA_FILIAL,(cAlote)->NTA_COD})
	(cAlote)->(dbSkip())
End
nAltera := Len(aAltera)

ProcRegua( nAltera ) //Preenche a lista de registros que serão alterados.
(cAlote)->( dbcloseArea() )

If (nAltera > 0)

DbSelectArea("NTA")
NTA->( DBSetOrder(1) )

For nI := 1 To nAltera

	If lAbortPrint //Indica que a operação foi abortada
		Exit
	EndIf

	if NTA->(dbSeek(aAltera[nI][1] + aAltera[nI][2]))

		//Seta variáveis estáticas
		c162TipoAs := JurGetDados("NSZ", 1, xFilial("NSZ") + NTA->NTA_CAJURI, "NSZ_TIPOAS")		//NSZ_FILIAL+NSZ_COD
		cTipoAsJ   := c162TipoAs

		//Destroy o model e carrega novamente
		If (cJurProc != c162TipoAs)

			cJurProc 	:= c162TipoAs
			Self:Destroy( oModel106 )
			oModel106 	:= FWLoadModel( 'JURA106' )
		Endif

		lPesquisa := .F.

		oModel106:SetOperation( 4 )
		oModel106:Activate()

		INCLUI := .F.
		ALTERA := .T.

		oNTA := oModel106:GetModel( 'NTAMASTER' )
		oNTE := oModel106:GetModel( 'NTEDETAIL' )

		//Valida se o modelo está no mesmo registro
		if (oNTA:GetValue("NTA_FILIAL") == aAltera[nI][1] .And. oNTA:GetValue("NTA_COD") == aAltera[nI][2])
			For nC := 1 to len(aCampos)
				cCampo := aCampos[nC]:cNomeCampo
				if !Empty(aCampos[nC]:Valor) //valida se o valor foi preenchido
					if LEFT(cCampo,3) == "NTA"
						oModel106:SetValue("NTAMASTER", cCampo,aCampos[nC]:Valor) //seta o valor novo
					elseif AllTrim(cCampo) == "NTE_CPART" .Or. AllTrim(cCampo) == "NTE_SIGLA"
						For nL := 1 to oNTE:GetQtdLine()
							//valida se o valor do campo é igual ao antigo
							if ( AllTrim(oNTE:GetValue(cCampo,nL)) $ aCampDe[aScan(aCampDe,{|x| x[1]==cCampo})][2] )
								oNTE:GoLine(nL)
								oModel106:SetValue("NTEDETAIL", cCampo, aCampos[nC]:Valor ) //seta o valor novo
							endif
						Next
					endif
				Endif
			Next
		endif

		If oModel106:VldData()
			nQtd++
			oModel106:CommitData()
		else
			aErro := oModel106:GetErrorMessage()

			cMsg  := AllToChar( aErro[6] ) + CRLF //"Mensagem do erro: "

			Alert( STR0031 + cMsg ) //"Erro na alteração em lote: "

			if ApMsgYesNo(STR0032) //"Deseja continuar a alteração de forma manual?"
				if (Self:JurProc(aAltera[nI][1],aAltera[nI][2],,4,10,oModel106))
					nQtd++
				endif

				//Inicializa variavel para carregar novamente o model
				cJurProc := ""
			endif
		endif

		oModel106:DeActivate()

		IncProc(I18N(STR0028,{AllTrim(str(nI)),Alltrim(str(nAltera))} )) //"Processando registro #1 de #2"
	Endif
Next

//Destroy objeto
Self:Destroy( oModel106 )

ApMsgInfo(I18N(STR0029,{AllTrim(str(nQtd))})) //"#1 Registros alterados."

Else
	Alert(STR0042)//"Nenhum registro encontrado. Atualizar a pesquisa"
EndIf


lAbortPrint := .F.

//Atualiza os componentes da tela
Self:Atualiza()

//Limpa memória
aSize(aAltera,0)
aSize(aExcecao,0)
aSize(aErro,0)
cSQL := ""

RestArea(aArea)

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} getExcecaoLote

Função que retorna campos de tabelas que devem aparecer na alteração em lote

@param		aCampos

@author	André Spirigoni Pinto
@since		09/02/2015
/*/
//---------------------------------------------------------------------------
METHOD getExcecaoLote() CLASS TJurPesqFW
Local aRet := {"NTA_DTFLWP"}
Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilial
Função que retorna a filial do registro posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFilial (nLinha) CLASS TJurPesqFW
Return Self:JA162Assjur("NTA_FILIAL", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcNWG

Função processa informacao que alimenta a tabela da lista
de impressao follow-up

@author Marcos Kato
@since 10/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ProcNWG(oLstPesq) CLASS TJurPesqFW
Local nCont		:= 0
Local dDTFLWP 	:= CToD("//")
Local cHora		:= ""

If NWG->(FieldPos("NWG_CUSER")) > 0
	NWG->(DbSetOrder(3))
	NWG->(DbSeek(xFilial("NWG")+Self:cUser))
	Do While NWG->(!Eof()) .and. Self:cUser == NWG->NWG_CUSER
		RecLock("NWG",.F.)
		 NWG->(DbDelete())
		 NWG->(MsUnlock())
		NWG->(DbSkip())
	End
Else
	NWG->(DbSetOrder(1))
	NWG->(DbGoTop())
	Do While NWG->(!Eof())
		RecLock("NWG",.F.)
		 NWG->(DbDelete())
		 NWG->(MsUnlock())
		NWG->(DbSkip())
	End
EndIf

If Valtype(oLstPesq)=="O" .And. Len(oLstPesq:aCols)>0

	Begin Transaction

		DbSelectArea("NWG")

		For nCont := 1 To Len(oLstPesq:aCols)

			If ValType(Self:JA162Assjur("NTA_DTFLWP", nCont)) == 'D'
				dDTFLWP := Self:JA162Assjur("NTA_DTFLWP", nCont)
			ElseIf ValType(Self:JA162Assjur("NTA_DTFLWP", nCont)) == 'C'
				dDTFLWP := stod(Self:JA162Assjur("NTA_DTFLWP", nCont))
			EndIf

//12.1.5
			If aScan(oLstPesq:aHeader,{|x| 'NTA_HORA' $ AllTrim(x[2])}) <> 0
				cHora := Self:JA162Assjur("NTA_HORA", nCont)
			Else
				cHora := Posicione('NTA',1,xFilial('NTA')+Self:getCodigo(nCont),'NTA_HORA')
			EndIf
//12.1.5

			RecLock("NWG",.T.)
			NWG->NWG_FILIAL := FWxFilial( "NWG",cFilAnt)
			NWG->NWG_CAJURI := Self:getCajuri(nCont)
			NWG->NWG_CODFOL := Self:getCodigo(nCont)

			If NWG->(FieldPos("NWG_CUSER")) > 0
				NWG->NWG_CUSER  := Self:cUser
				NWG->NWG_SECAO  := Self:cThread
			EndIf

			NWG->NWG_FILORI := Self:getFilial(nCont)  // Filial de Origem da tabela de Follow-Ups
			NWG->NWG_DTFLWP := dDTFLWP
			NWG->NWG_HORA   := cHora		//12.1.5
			NWG->( MsUnlock() )

		Next nCont

	End Transaction

Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Atualiza
Função que faz a configuração dos eventos do mouse no Browse

@author André Spirigoni Pinto
@since 25/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD Atualiza() CLASS TJurPesqFW
Local nCt := 0

//Atualiza o calendário
If !Empty(Self:oCalend)
	Self:oCalend:Refresh()
EndIf

If Len(Self:aGraficos) > 0
	For nCt := 1 to len(Self:aGraficos)
		Self:aGraficos[nCt]:Refresh()
	Next
EndIf
Return nil
//-------------------------------------------------------------------
/*/{Protheus.doc} ListaEquip()
Função utilizada para gerar a query com as equipes.
Uso Geral.

@Return	aListEquip  lista de equipes

@author Wellington Coelho
@since 14/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ListaEquip() CLASS TJurPesqFW
Local aArea		:= GetArea()
Local cConfigs	:= GetNextAlias()
Local aListEquip	:= {}
Local cQuery		:= ""
Local cCodUsr		:= Self:cUser

cQuery := "SELECT NZ8.NZ8_COD,NZ8.NZ8_DESC " + CRLF
cQuery += "FROM " + RetSqlName("NZ8") +" NZ8,"+ CRLF
cQuery += RetSqlName("RD0") +" RD0 "+  CRLF
cQuery += "WHERE NZ8.NZ8_FILIAL = '"+xFilial("NZ8")+"'"+ CRLF
cQuery += "AND RD0.RD0_USER = " + "'" + cCodUsr + "'"+ CRLF
cQuery += "AND RD0.RD0_CODIGO = NZ8.NZ8_CPARTL"+ CRLF
cQuery += "AND NZ8.D_E_L_E_T_=' '"

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cConfigs, .T., .F.)

aAdd(aListEquip, '')
While (cConfigs)->(!Eof())
	aAdd(aListEquip,(cConfigs)->NZ8_COD+'-'+(cConfigs)->NZ8_DESC)
	(cConfigs)->(dbSkip())
End

(cConfigs)->( dbcloseArea() )
RestArea(aArea)

Return aListEquip

//-------------------------------------------------------------------
/*/{Protheus.doc} ListaPart(cCodEquipe)
Função utilizada para gerar a query com participantes da equipe selecionada.
Uso Geral.

@Return	aListaPart  lista de participantes da equipe.

@author Wellington Coelho
@since 16/04/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ListaPart(cCodEquipe) CLASS TJurPesqFW
Local aArea		:= GetArea()
Local cConfigs	:= GetNextAlias()
Local cQuery		:= ""

Self:aListaPart	:= {}

If !EMPTY(Self:oCmbEquipe:cValor)

	cQuery := "SELECT NZ9.NZ9_CEQUIP, NZ9.NZ9_CPART, " + CRLF
	cQuery += "RD0.RD0_SIGLA" + CRLF
	cQuery += "FROM " + RetSqlName("NZ9") +" NZ9,"+ CRLF
	cQuery += + RetSqlName("RD0") +" RD0"+ CRLF
	cQuery += "WHERE NZ9.NZ9_FILIAL = '"+xFilial("NZ9")+"'"+ CRLF
	cQuery += "AND NZ9.D_E_L_E_T_=' '"+ CRLF
	cQuery += "AND NZ9.NZ9_CEQUIP = " + "'" + Self:cCodEquipe + "'"+ CRLF
	cQuery += "AND RD0.RD0_CODIGO = NZ9_CPART"+ CRLF

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cConfigs, .T., .F.)

	aAdd(Self:aListaPart, STR0037)//"Todos"

	While (cConfigs)->(!Eof())
		aAdd(Self:aListaPart,(cConfigs)->NZ9_CPART+'-'+(cConfigs)->RD0_SIGLA)
		(cConfigs)->(dbSkip())
	End
	(cConfigs)->( dbcloseArea() )
	RestArea(aArea)

EndIf
IF (Len(Self:aListaPart) == 0)
	aAdd(Self:aListaPart, STR0037)//"Todos"
EndIf

Return Self:aListaPart

//-------------------------------------------------------------------
/*/{Protheus.doc} getparts(cFup)
Retorna os participantes responsáveis pelo Fup
Uso Geral.

@Return	cParts  lista de participantes responsáveis pelo FUP.

@author Jorge Luis Branco Martins Junior
@since 07/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getparts(cFup) CLASS TJurPesqFW
Local aArea    := GetArea()
Local aAreaNTE := NTE->( GetArea() )
Local aAreaRD0 := RD0->( GetArea() )
Local cParts   := ""
Local nCont    := 0

DbSelectArea("NTE")
NTE->(DbSetOrder(2))//NTE_FILIAL, NTE_CFOLWP

If NTE->(DbSeek(xFilial("NTE")+AvKey(cFup,"NTE_CFLWP")))

	DbSelectArea("RD0")
	RD0->(DbSetOrder(1))//RD0_FILIAL, RD0_COD

	Do While NTE->(!Eof()) .And. Alltrim(NTE->NTE_CFLWP) == AllTrim(cFup)

		If RD0->(DbSeek(xFilial("RD0")+AvKey(NTE->NTE_CPART,"RD0_COD")))
			If !(Alltrim(RD0->RD0_SIGLA) $ cParts)
				If nCont == 0
					nCont := 1
					cParts += Alltrim(RD0->RD0_SIGLA)
				Else
					cParts += "/" + Alltrim(RD0->RD0_SIGLA)
				EndIf
			Endif
		Endif

		NTE->(DbSkip())
	End
EndIf

RestArea( aAreaRD0 )
RestArea( aAreaNTE )
RestArea( aArea )

Return cParts

//-------------------------------------------------------------------
/*/{Protheus.doc} atuCmbPart
Atuializa combo de participantes quando alterar a equipe.

@author Jorge Luis Branco Martins Junior
@since 14/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD atuCmbPart() CLASS TJurPesqFW

If Self:oCmbPart <> NIL
	Self:oCmbPart:SetItems({})
	Self:oCmbPart:SetItems(Self:ListaPart(Self:oCmbEquipe:cValor))
Else
	Self:oCalend:Refresh()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReenvWfCor
Reenvia workflow para correspondente.

@author Rafael Tenorio da Costa
@since 25/06/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ReenvWfCor() CLASS TJurPesqFW

	Local aArea 	:= GetArea()
	Local cTabela 	:= GetNextAlias()
	Local cQuery 	:= Self:MontaSQL()
	Local aEnvia 	:= {}
	Local oModel106	:= Nil
	Local nReg		:= 0
	Local nEnviados	:= 0
	Local cAux		:= ""
	Local cErro		:= ""

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., 'TOPCONN', TcGenQry( ,, cQuery ) , cTabela, .T., .F.)

	//Preenche o array com os registros que serão alterados
	While !(cTabela)->( Eof() )
		Aadd(aEnvia, { (cTabela)->NTA_FILIAL, (cTabela)->NTA_COD } )
		(cTabela)->( DbSkip() )
	EndDo

	ProcRegua( Len(aEnvia) ) //Preenche a lista de registros que serão alterados.
	(cTabela)->( DbcloseArea() )

	DbSelectArea("NTA")
	NTA->( DBSetOrder(1) )		//NTA_FILIAL+NTA_COD

	oModel106 := FWLoadModel( "JURA106" )

	For nReg := 1 To Len(aEnvia)

		If NTA->( DbSeek(aEnvia[nReg][1] + aEnvia[nReg][2]) )

			IncProc( I18N( STR0028, { cValToChar(nReg), cValToChar( Len(aEnvia) ) } ) ) //"Processando registro #1 de #2"

			cAux		:= ""
			oModel106:SetOperation( 4 )
			oModel106:Activate()

			//Envia workflow
			If JA106WFECO(oModel106, .T., @cAux)
				nEnviados++
			Else

				//Erro no envio do e-mail ira acontecer com todos os outros
				If Empty(cAux)
					oModel106:DeActivate()
					Exit
				Else
					cErro += AllTrim( cAux ) + CRLF
				EndIf
			EndIf

			oModel106:DeActivate()
		Endif
	Next nReg

	If !Empty( cErro )
		JurErrLog(cErro, STR0039)	//"Workflows não reenviados"
	EndIf

	//Destroy objeto
	Self:Destroy( oModel106 )

	ApMsgInfo( cValToChar(nEnviados) + " " + STR0038 ) //"#1 Registros enviados."

	//Atualiza os componentes da tela
	Self:Atualiza()

	RestArea(aArea)

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} getComplLote
Retorna campos que contenham campos complementares de tabelas que devem aparecer na alteração em lote

@author	Rafael Tenorio da Costa
@since	25/06/2015
/*/
//---------------------------------------------------------------------------
METHOD getComplLote() CLASS TJurPesqFW
Local aRet := {}

Aadd(aRet, {"NTA_ACEITO", {"NTA_JUSTIF", "NTA_CCORRE", "NTA_LCORRE"} ,{55,55,50},{40,20,20}} 	)

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} VlAltLote

Função que faz a validação da alteração em lote da tabela principal da pesquisa usando os campos

@param		aCampos

@author	André Lago
@since		06/08/2015
/*/
//---------------------------------------------------------------------------
METHOD VlAltLote(aCampos, aCampDe) CLASS TJurPesqFW
Local aArea := GetArea()
Local cCampo := ""
Local nC
Local lRet 		:= .T.
Local lVlJust 	:= .F.

For nC := 1 to len(aCampos)
	cCampo := aCampos[nC]:cNomeCampo
	If AllTrim(cCampo) == "NTA_ACEITO"
		if !Empty(aCampos[nC]:Valor) .and. aCampos[nC]:Valor == "2" //valida se o valor foi preenchido e se é nao
			lVlJust := .T.
		EndIf
	ElseIf AllTrim(cCampo) == "NTA_JUSTIF"
		if Empty(aCampos[nC]:Valor) .and. lVlJust //valida se o valor foi preenchido e se tem que validar
			Alert( STR0031 + STR0041 + AllTrim(aCampos[nC]:cDescCampo)  )
			lRet := .F.
			Exit
		EndIf
	EndIf
Next

RestArea(aArea)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} dblClickBrw()
Função para definir a ações do doubleclick

Uso Geral
@Return
@author Cristiane Nishizaka/ Lucivan Severo
@since 16/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
METHOD dblClickBrw() CLASS TJurPesqFW

Local lAltPro  := (SuperGetMV('MV_JALTPRO',, '1') == '2') //parametro que define a operação do doubleclick no grid de Follow Up (1=Alterar ou 2= Visualizar)

If !LEN(Self:oLstPesq:aCols) == NIL
	If Self:oLstPesq:oBrowse:ColPos() == 1 //valida se deve ser exibida a legenda
		Self:LegFollUp()
	Else
		If lAltPro .And. JA162AcRst('05', 2)
			Self:JA162Menu(1,Self:oLstPesq,,Self:oCmbConfig)
		ElseIf JA162AcRst('05', 4)
			Self:JA162Menu(4,Self:oLstPesq,,Self:oCmbConfig)
		Endif
	Endif
Endif

Return
