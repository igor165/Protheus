#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TJURPESQGAR.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "TOTVS.CH"

//----------------------------------------- --------------------------
/*/{Protheus.doc} JurPesqGar
CLASS TJurPesqGar

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurPesqGar FROM TJurPesquisa

	DATA cRotina //indica a rotina utilizada nas operações

	METHOD New (cTipo, cTitulo, cRotina) CONSTRUCTOR
	METHOD SetMEBrowse (oLstPesq)
	METHOD LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa)
	METHOD getCajuri (nLinha)
	METHOD getCodigo (nLinha)
	METHOD getMenu(oMenu)
	METHOD getBrHeader()
	METHOD getBrCols(cSQL, cCampos, aHead)
	METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca)
	METHOD getFilial(nLinha)
	METHOD MenuLev(oLstPesq, oObj)
	METHOD OpAltLote(aCampos, aCampDe)
	METHOD JHabLote()
	METHOD menuAnexos()
	METHOD getFilDes(nLinha)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqGar
CLASS TJurPesqGar

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTipo, cTitulo, cRotina) CLASS TJurPesqGar
Default cRotina := "JURA098"

_Super:New (cTitulo)

Self:setTipoPesq(cTipo)
Self:SetTabPadrao("NT2")
Self:cRotina := cRotina
Self:cTabPadrao := "NT2"
Self:bLegenda := {|| Self:getLegAnexo(self:getCodigo(), self:getCajuri())} //bloco de atualização de legenda de anexos

If !(self:montalayout())

	Self:oDesk:SetLayout({{"01",30,.T.},{"02",70,.T.}}) //layout da tela.

	Self:oPnlPrinc := Self:loadCmbConfig(Self:oDesk:getPanel("01"))

	Self:loadGrid(Self:oDesk:getPanel("02"))
	Self:loadAreaCampos(Self:oPnlPrinc)
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
METHOD SetMEBrowse (oLstPesq) CLASS TJurPesqGar
oLstPesq:SetDoubleClick({|| IIF(Self:oLstPesq:oBrowse:ColPos()==1,Self:MostraLegAnex(oLstPesq,STR0001),Self:JA162Menu(1,oLstPesq))}) //"Legenda de Garantias"
Return nil

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
METHOD LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa) CLASS TJurPesqGar
Local lOK	:= .T.
Local nRet	:= 1

Local oM098
Local cNT2Cod := ""
Local bOk := {|| IIF(nOper == 3,cNT2Cod := oM098:GetValue("NT2MASTER","NT2_COD"),), .T.}
Local bClose := {|| .T.}

Default oModel 	:= NIl
Default nTela	:= 0
Default lFecha 	:= .F.
Default lFazPesquisa := .T. // Usado na rotina de Follow-up. Indica se realiza a pesquisa após o Fup ser alterado e houver confirmação (essa alteração dita é quando o Fup é reaberto em modo de alteração após a inclusão) e a tela for fechada.

If nOper == 3 .And. (cTipoAJ == '000' .Or. cTipoAJ == '')
  If cTipoAJ == '000'
	  Alert(STR0002) //"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	EndIf
  lOK := .F.
Else
	If !cCod == NIL .And. !Empty(cCod)
		If Empty(AllTrim(cCajur))
			NT2->(DBSetOrder(2))
			NT2->(dbSeek(xFilial("NT2") + cCod))
		Else
			NT2->(DBSetOrder(1))
			NT2->(dbSeek(xFilial("NT2") + cCajur + cCod))
		EndIf
	Else
		lOK := (nOper == 3)
	EndIf

	If nOper == 4 .And. SuperGetMV("MV_JINTVAL", , "2") == "1" .And. NT2->NT2_INTFIN == "1"
		lOK := .F.
		MsgAlert(STR0017)	//"Não é possível efetuar a alteração pois a integração do SIGAJURI com o módulo SIGAFIN está habilitada"
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
		oM098 := FWLoadModel( 'JURA098' )
		oM098:SetOperation( nOper )
		oM098:Activate()
		bClose := Nil
	Else
		oM098 := Nil
	Endif

	MsgRun(STR0003,STR0004,{|| nRet:=FWExecView(cMsg,Self:cRotina, nOper,,bClose, bOk ,nTela,,,,,oM098 )}) //"Carregando..." e "Pesquisa de Garantias"

	If INCLUI .AND. nRet == 0 .And. ("3" $ JGetParTpa(cTipoAJ, "MV_JALTREG", "1"))
		cCajur := NT2->NT2_CAJURI

		If !Empty(cNT2Cod) .AND. !Empty(cCajur)
			//Se incluiu e foi criado um assunto jurídico, abrir o mesmo.
			Self:JurProc(xFilial('NT2'),cNT2Cod,cCajur,4)
		Endif
	Endif
Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} getCajuri
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCajuri (nLinha) CLASS TJurPesqGar
Return Self:JA162Assjur("NT2_CAJURI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodigo
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCodigo (nLinha) CLASS TJurPesqGar
Return Self:JA162Assjur("NT2_COD", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMenu()
Função que monta o menu lateral principal.

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getMenu(oMenu) CLASS TJurPesqGar

Local aRelat	:= {}
Local aEspec	:= {}
Local bCorrecao

if Self:lAnoMes
	bCorrecao := {| oObj | IIf(Empty(Self:oLstPesq:aCols),Alert(STR0002),Self:MenuCorr(Self:oLstPesq,oObj,Self:aTables))} //"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
else
	bCorrecao := {|| IIF(Self:befAction(),Self:JA162BCorr(Self:oLstPesq,Self:aTables,val(Self:cTipoPesq),.F.),) }
endif

aAdd(aEspec,{STR0005 + IIF(Self:lAnoMes," >",""),bCorrecao }) //"Correção Monetária"
aAdd(aEspec,{STR0006 + " >",{| oObj | IIF(Self:befAction(),Self:MenuLev(Self:oLstPesq,oObj),)} }) //"Levantamento"#"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"

If (SuperGetMV('MV_JINTVAL',, '2') == '1')
	aAdd(aEspec,{STR0007,{|| IIF(Self:befAction(), JurTitPag('NT2',Self:getCajuri(),Self:getCodigo()),)} }) //"Títulos"#"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	If (SuperGetMV('MV_JALCADA',, '2') == '1')
		aAdd(aEspec,{STR0008,{|| IIF(Self:befAction(),JurLibDoc('NT2','2',Self:getCajuri(),Self:getCodigo()),)} }) //"Liberação de Dctos"#"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	EndIf
EndIf

aAdd(aRelat, {STR0009,{|| IIF(Self:befAction(),JA098RelG(Self:getCajuri(), self:getFilial()),)} }) //"Extrato de Garantias"#"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"

oMenu := Self:setMenuPadrao(oMenu, , , aRelat, aEspec, '07')

Return oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrHeader() CLASS TJurPesqGar
Local aCampos := {}

//Campos padrão
aAdd(aCampos, {"NT2_COD",JA160X3Des("NT2_COD"),"2"})
aAdd(aCampos, {"NT2_CAJURI",JA160X3Des("NT2_CAJURI"), "2"})
aAdd(aCampos, {"NT2_FILIAL",JA160X3Des("NT2_FILIAL") ,"2"})
aAdd(aCampos, {"NT2_MOVFIN",JA160X3Des("NT2_MOVFIN"), "2"})

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrCols(cSQL, cCampos, aHead) CLASS TJurPesqGar
Local aCol		:= {}
Local aArea     := GetArea()
Local cLista	:= GetNextAlias()
Local lShowPes	:= .F.
Local nQtd		:= 0
Local nCols		:= 0
Local nX		:= 0
Local aManual	:= {}

If ValType(cSql) == "U" .Or. Empty(cSQL)
	If ValType(cSql) == "U"
		lShowPes:= .T.
	EndIf

	cSQL := "SELECT "+cCampos+" FROM " +RetSqlname('NT2') + " NT2001"

	aManual := {}
	AAdd(aManual,{"NT2", "NT2001", "NQW", "NQW001", ""})

	cSQL := Self:JQryPesq(cSQL, Self:cTabPadrao, aManual)
	cSQL += " Where 1=2 "

EndIf

cSQL := ChangeQuery(cSQL)
//Change query troca '' por ' ', o que compromete com a pesquisa
cSql := StrTran(cSql,",' '",",''")
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cLista, .T., .F.)

dbSelectArea(cLista)
(cLista)->(dbGoTop())

While (cLista)->(!Eof())
	aAdd(aCol,Array(LEN(aHead)+4))
	nCols++
	nQtd++

	For nX := 1 To LEN(aHead)
		If nX == 1
			aCol[nCols][nX] := Self:getLegAnexo((cLista)->NT2_COD, (cLista)->NT2_CAJURI)
		Elseif (aHead[nX][10] != "V") //Valida se não é um campo virtual para evitar um fieldget/fieldpos
		 	aCol[nCols][nX] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))
		EndIf
	Next nX

	aCol[nCols][LEN(aHead)+1] := (cLista)->NT2_COD
	aCol[nCols][LEN(aHead)+2] := (cLista)->NT2_CAJURI
	aCol[nCols][LEN(aHead)+3] := (cLista)->NT2_FILIAL
	aCol[nCols][LEN(aHead)+4] := .F.
	dbSelectArea(cLista)
	(cLista)->(dbSkip())
End

RestArea( aArea )
Self:AtuCount(nQtd)
Self:cSQLFeito := cSQL

Return aCol

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
METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca) CLASS TJurPesqGar
Local nI, cSQL   := ''
Local aSQL      := {}
Local aSQLRest  := {}
Local cTpAJ     := ""
Local NT2Name   := Alltrim(RetSqlName("NT2"))
Local aFilUsr   := JURFILUSR( __CUSERID, "NT2" )
Local cTpPesq   := Self:cTipoPesq
Local cPesqAtv  := oCmbConfig:cValor

AAdd(aManual,{"NT2", "NT2001", "NQW", "NQW001", ""})
AAdd(aManual,{"NT2", "NT2001", "NSZ", "NSZ001", ""})
AAdd(aTroca,{"NT2", "NT2001"})

For nI := 1 to LEN(aObj)
	If !(aObj[nI] == NIL) .And. !(Empty(aObj[nI]:Valor))
		If aObj[nI]:GetNameField() $ 'NUQ_CCOMAR/NUQ_CLOC2/NUQ_CLOC3/NUQ_NUMPRO/NSZ_CCLIEN/NUQ_CCORRE'
				AAdd(aManual,{"NSZ", "NSZ001", "NUQ", "NUQ001", "NUQ001.NUQ_INSATU = '1'"})
		Endif
		aAdd(aSQL, {aObj[nI]:GetTable(),Self:TrocaWhere(aObj[nI],aTroca)})// Tabela  Where
  EndIf
Next

cTpAJ := AllTrim( JurSetTAS(.F.) )

//Tratamento de aspas simples para a query
cTpAJ := IIf(  Left(cTpAJ,1) == "'", "", "'" ) + cTpAJ
cTpAJ += IIf( Right(cTpAJ,1) == "'", "", "'" )

//<- Pega restrição de cliente ou correspondentes ->
aSQLRest := Ja162RstUs()

cSQL := "SELECT "+cCampos+ CRLF
cSQL += " 	FROM "+NT2Name+" NT2001 "+ CRLF
cSQL := Self:JQryPesq(cSQL,Self:cTabPadrao, aManual)

If ( VerSenha(114) .or. VerSenha(115) )
	cSQL += " WHERE NT2_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) +  CRLF
Else
	cSQL += " WHERE NT2_FILIAL = '"+xFilial("NT2")+"'"+ CRLF
Endif

//<- Adiciona a restrição de Acesso ->
If !Empty(aSQLRest)
	cSQL += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ)+")"
EndIf

//Ponto de Entrada de Cláusula para Query - JA162QRY
If ExistBlock("JA162QRY")
	cSQL += ExecBlock("JA162QRY",.F.,.F.,{cTpAJ,cTpPesq,cPesqAtv})
EndIf

cSQL += "			AND NT2_DATA IS NOT NULL "
cSQL += "   	AND NT2001.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += "   	AND NSZ_TIPOAS IN (" + cTpAJ + ")" + CRLF

cSQL += VerRestricao()  //Restricao de Escritorio e Area

cSQL += Self:GetCondicao(aSQL, NT2Name) + CRLF

If "SELECT NUQ_" $ cSql
	cSQL += " AND NSZ_TIPOAS <> '006' "
EndIf

cSQL += ' ORDER BY NT2_CAJURI, NT2_FILIAL ASC'

Return cSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilial
Função que retorna a filial do registro posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFilial (nLinha) CLASS TJurPesqGar
Return Self:JA162Assjur("NT2_FILIAL", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuLev
Monta o menu de opções de levantamentos (Ações em lote)
Uso no cadastro de Assunto Jurídico.

@author André Spirigoni Pinto
@since 22/07/13
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MenuLev(oLstPesq, oObj) CLASS TJurPesqGar
Local oMenu
Local oMenuItem	 := {}

MENU oMenu POPUP of oObj:oSay
	aAdd(oMenuItem, MenuAddItem(STR0010,,, .T.,,,,oMenu,{||	JA098LEV(1, Self:getCajuri() )},,,,,{||.T.} )) //"Inclusão"
	aAdd(oMenuItem, MenuAddItem(STR0011,,, .T.,,,,oMenu,{||	J098EXLEV(Self:getCajuri() )},,,,,{||.T.} )) //"Exclusão"
ENDMENU

Activate POPUP oMenu AT 40, 20 of oObj:oSay

Return NIL

//---------------------------------------------------------------------------
/*/{Protheus.doc} OpAltLote

Função que faz a alteração em lote da tabela principal da pesquisa usando os campos

@param		aCampos

@author	André Spirigoni Pinto
@since		09/02/2015
/*/
//---------------------------------------------------------------------------
METHOD OpAltLote(aCampos, aCampDe) CLASS TJurPesqGar
Local aArea     := GetArea()
Local cAlote    := GetNextAlias()
Local cSQL      := Self:MontaSQL()
Local aAltera   := {}
Local oModel098 := Nil
Local oNT2      := Nil
Local cCampo    := ""
Local nI        := 0
Local nC        := 0
Local nQtd      := 0
Local aExcecao  := Self:getExcecaoLote()
Local aErro     := {}
Local cMsg      := ""

If Type("INCLUI") == "U"
	INCLUI := .F.
	ALTERA := .T.
EndIf

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlote, .T., .F.)

//Preenche o array com os registros que serão alterados
While (cAlote)->(!Eof())
	aAdd(aAltera,{(cAlote)->NT2_FILIAL,(cAlote)->NT2_CAJURI,(cAlote)->NT2_COD})
	(cAlote)->(dbSkip())
End

ProcRegua(Len(aAltera)) //Preenche a lista de registros que serão alterados.

(cAlote)->( dbcloseArea() )

DbSelectArea("NT2")
NT2->(DBSetOrder(1))

For nI := 1 to len(aAltera)

	If lAbortPrint //Indica que a operação foi abortada
		Exit
	EndIf

	if NT2->(dbSeek(aAltera[nI][1] + aAltera[nI][2] + aAltera[nI][3]))
		lPesquisa := .F.

		oModel098 := FWLoadModel( 'JURA098' )
		oModel098:SetOperation( 4 )

		If oModel098:Activate()

			INCLUI := .F.
			ALTERA := .T.

			oNT2 := oModel098:GetModel( 'NT2MASTER' )

			//Valida se o modelo está no mesmo registro
			if (oNT2:GetValue("NT2_FILIAL") == aAltera[nI][1] .And. oNT2:GetValue("NT2_CAJURI") == aAltera[nI][2] .And. oNT2:GetValue("NT2_COD") == aAltera[nI][3] )
				For nC := 1 to len(aCampos)
					cCampo := aCampos[nC]:cNomeCampo
					if !Empty(aCampos[nC]:Valor) //valida se o valor foi preenchido
						//valida se o valor do campo é igual ao antigo
						if (aScan(aExcecao,cCampo)>0 .Or. oNT2:GetValue(cCampo) == aCampDe[aScan(aCampDe,{|x| x[1]==cCampo})][2])
							oNT2:SetValue(cCampo,aCampos[nC]:Valor) //seta o valor novo
						endif
					Endif
				Next
			endif

			If oModel098:VldData()
				nQtd++
				oModel098:CommitData()
			else
				aErro := oModel098:GetErrorMessage()

				cMsg  := AllToChar( aErro[6] ) + CRLF //"Mensagem do erro: "

				Alert( STR0012 + cMsg ) //"Erro na alteração em lote: "

				if ApMsgYesNo(STR0013) //"Deseja continuar a alteração de forma manual?"
					if (Self:JurProc(aAltera[nI][1],aAltera[nI][2],,4,10,oModel098))
						nQtd++
					endif
				endif
			endif

			oModel098:DeActivate()

			IncProc(I18N(STR0014,{AllTrim(str(nI)),Alltrim(str(Len(aAltera)))} )) //"Processando registro #1 de #2"
		Else

			JurMsgErro(STR0016) //"Alteração não pode ser efetuada, pois existe um tilulo no modulo SIGAFIN para essa garantia"

		Endif

	Endif

Next


ApMsgInfo(I18N(STR0015,{AllTrim(str(nQtd))})) //"#1 Registros alterados."

lAbortPrint := .F.

RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} JHabLote()
Função utilizada para habilitar a exibição do botão de Alteração em Lote
Uso Geral.

@author Wellington Coelho
@since 09/12/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JHabLote() CLASS TJurPesqGar
Local lRet := .T.

If (SuperGetMV('MV_JINTVAL',, '2') == '1')
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} menuAnexos
Metodo de Anexos

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD menuAnexos() CLASS TJurPesqGar

JurAnexos(Self:cTabPadrao, Self:getCajuri()+Self:getCodigo(), 1, Self:getFilial())

self:refreshLegenda()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilDes
Função que retorna o filial de destino posicionado no Grid ou na linha escolhida

@author Marcelo Araujo Dente
@since 26/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFilDes(nLinha) CLASS TJurPesqGar
Return Self:JA162Assjur("NT2_FILDES", nLinha)
