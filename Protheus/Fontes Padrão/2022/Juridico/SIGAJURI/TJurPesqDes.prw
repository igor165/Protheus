#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TJURPESQDES.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "TOTVS.CH"

//---------------------------- ---------------------------------------
/*/{Protheus.doc} JurPesqDes
CLASS TJurPesqDes

@author Reginaldo N Soares
@since 12/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurPesqDes FROM TJurPesquisa

	DATA cRotina //indica a rotina utilizada nas operações

	METHOD New (cTipo, cTitulo, cRotina) CONSTRUCTOR
	METHOD SetMEBrowse (oLstPesq)
	METHOD LoadRotina(cFil,cCod,cCajur, nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa)
	METHOD getCajuri (nLinha)
	METHOD getCodigo (nLinha)
	METHOD getMenu(oMenu)
	METHOD getBrHeader()
	METHOD getBrCols(cSQL, cCampos, aHead)
	METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca)
	METHOD OpAltLote(aCampos, aCampDe)
	METHOD getFilial (nLinha)
	METHOD menuAnexos()
	METHOD getFilDes(nLinha)
ENDCLASS


//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqDes
CLASS TJurPesqDes

@author Reginaldo N Soares
@since 12/09/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTipo, cTitulo, cRotina) CLASS TJurPesqDes

Default cRotina := "JURA099"

_Super:New (cTitulo)

Self:setTipoPesq(cTipo)
Self:SetTabPadrao("NT3")
Self:cRotina := cRotina
Self:cTabPadrao := "NT3"
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

@author Reginaldo N Soares
@since 12/09/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetMEBrowse (oLstPesq) CLASS TJurPesqDes
oLstPesq:SetDoubleClick({|| IIF(Self:oLstPesq:oBrowse:ColPos()==1,Self:MostraLegAnex(oLstPesq,STR0001),Self:JA162Menu(1,oLstPesq))}) //"Legenda de Despesas"
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
METHOD LoadRotina(cFil,cCod,cCajur, nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa) CLASS TJurPesqDes

Local lOK	:= .T.
Local nRet	:= 1
Local oM099
Local cNT3Cod := ""
Local bOk     := {|| IIF(nOper == 3,cNT3Cod := oM099:GetValue("NT3MASTER","NT3_COD"),), .T.}
Local bClose  := {|| .T.}

Default oModel 	:= NIl
Default nTela 	:= 0
Default lFecha	:= .F.
Default lFazPesquisa := .T. // Usado na rotina de Despesas. Indica se realiza a pesquisa após a Despesa ser alterado e houver confirmação (essa alteração dita é quando a Despesa é reaberto em modo de alteração após a inclusão) e a tela for fechada.

If nOper == 3 .And. (cTipoAJ == '000' .Or. cTipoAJ == '')
  If cTipoAJ == '000'
	  Alert(STR0002) //"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	EndIf
  lOK := .F.
Else
	If !cCod == NIL .And. !Empty(cCod)                  // condicacao para posicionar o cajuri + codigo - LPS
		If Empty(AllTrim(cCajur))
			NT3->(DBSetOrder(2))
			NT3->(dbSeek(xFilial("NT3") + cCod))
		Else
			NT3->(DBSetOrder(1))
			NT3->(dbSeek(xFilial("NT3") + cCajur + cCod))
		EndIf
	Else
		lOK := (nOper == 3)
	EndIf

	If nOper == 4 .And. SuperGetMV("MV_JINTVAL", , "2") == "1" .And. JurGetDados("NSR", 1, xFilial("NSR") + NT3->NT3_CTPDES, "NSR_INTCTB") == "1"
		lOK := .F.
		MsgAlert(STR0012)	//"Não é possível efetuar a alteração pois a integração do SIGAJURI com o módulo SIGAFIN está habilitada"
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
		oM099 := FWLoadModel( 'JURA099' )
		oM099:SetOperation( nOper )
		oM099:Activate()
		bClose := Nil
	Else
		oM099 := Nil
	Endif

	MsgRun(STR0008,STR0009,{|| nRet:=FWExecView(cMsg,Self:cRotina, nOper,,bClose, bOk ,,,,,,oM099 )}) //"Carregando..." e "Pesquisa de Despesas"

	If INCLUI .AND. nRet == 0 .And. ("5" $ JGetParTpa( cTipoAJ, "MV_JALTREG", "1"))
		cCajur := NT3->NT3_CAJURI

		If !Empty(cNT3Cod) .AND. !Empty(cCajur)
			//Se incluiu e foi criado um assunto jurídico, abrir o mesmo.
			Self:JurProc(xFilial('NT3'),cNT3Cod,cCajur,4)
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
METHOD getCajuri (nLinha) CLASS TJurPesqDes
Return Self:JA162Assjur("NT3_CAJURI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodigo
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCodigo (nLinha) CLASS TJurPesqDes
Return Self:JA162Assjur("NT3_COD", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMenu()
Função que monta o menu lateral principal.

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getMenu(oMenu) CLASS TJurPesqDes
Local aRelat := {}
Local aEspec	:= {}

If (SuperGetMV('MV_JINTVAL',, '2') == '1')
	aAdd(aEspec,{STR0010,{|| IIF(Self:befAction(), JurTitPag('NT3',Self:getCajuri(),Self:getCodigo()),)} }) //"Títulos"#"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	If (SuperGetMV('MV_JALCADA',, '2') == '1')
		aAdd(aEspec,{STR0011,{|| IIF(Self:befAction(),JurLibDoc('NT3','3',Self:getCajuri(),Self:getCodigo()),)} }) //"Liberação de Dctos"#"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	EndIf
EndIf

aAdd(aRelat, {STR0003,{||	IIF(Self:befAction(),RelDesp(Self:getCajuri(), Self:getFilial(), self:getfiltro()),)} }) //"Despesas"

oMenu := Self:setMenuPadrao(oMenu, , , aRelat,aEspec, '08') //Rotina Despesas

Return oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrHeader() CLASS TJurPesqDes
Local aCampos := {}

//Campos padrão
aAdd(aCampos, {"NT3_COD",JA160X3Des("NT3_COD"),"2"})
aAdd(aCampos, {"NT3_CAJURI",JA160X3Des("NT3_CAJURI"), "2"})
aAdd(aCampos, {"NT3_FILIAL",JA160X3Des("NT3_FILIAL") ,"2"})

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrCols()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrCols(cSQL, cCampos, aHead) CLASS TJurPesqDes
Local aCol		:= {}
Local aArea    := GetArea()
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

	aManual := {}
	AAdd(aManual,{"NT3", "NT3001", "NSZ", "NSZ001", ""})

	cSQL := "SELECT "+cCampos+" FROM " +RetSqlname('NT3') + " NT3001 "
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
			aCol[nCols][nX] := Self:getLegAnexo((cLista)->NT3_COD, (cLista)->NT3_CAJURI)
		Elseif (aHead[nX][10] != "V") //Valida se não é um campo virtual para evitar um fieldget/fieldpos
			aCol[nCols][nX] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))
		EndIf
	Next nX

	aCol[nCols][LEN(aHead)+1] := (cLista)->NT3_COD
	aCol[nCols][LEN(aHead)+2] := (cLista)->NT3_CAJURI
	aCol[nCols][LEN(aHead)+3] := (cLista)->NT3_FILIAL
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
METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca) CLASS TJurPesqDes
Local nI, cSQL   := ''
Local aSQL       := {}
Local aSQLRest   := {}
Local cTpAJ      := ""
Local NT3Name    := Alltrim(RetSqlName("NT3"))
Local aFilUsr    := JURFILUSR( __CUSERID, "NT3" )
Local cTpPesq    := Self:cTipoPesq
Local cPesqAtv   := oCmbConfig:cValor

AAdd(aManual,{"NT3", "NT3001", "NSZ", "NSZ001", ""})
AAdd(aTroca,{"NT3", "NT3001"})

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
cSQL += " 	FROM "+NT3Name+" NT3001 " + CRLF
cSQL := Self:JQryPesq(cSQL,Self:cTabPadrao, aManual)

If ( VerSenha(114) .or. VerSenha(115) )
	cSQL += " WHERE NT3_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) +  CRLF
Else
	cSQL += " WHERE NT3_FILIAL = '"+xFilial("NT3")+"'"+ CRLF
Endif

//<- Adiciona a restrição de Acesso ->
If !Empty(aSQLRest)
	cSQL += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ)+")"
EndIf

//Ponto de Entrada de Cláusula para Query - JA162QRY
If ExistBlock("JA162QRY")
	cSQL += ExecBlock("JA162QRY",.F.,.F.,{cTpAJ,cTpPesq,cPesqAtv})
EndIf

cSQL += "   	AND NT3001.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += "   	AND NSZ_TIPOAS IN (" + cTpAJ + ")" + CRLF

cSQL += VerRestricao()  //Restricao de Escritorio e Area

cSQL += Self:GetCondicao(aSQL, NT3Name) + CRLF

If "SELECT NUQ_" $ cSql
	cSQL += " AND NSZ_TIPOAS <> '009' "
EndIf

Return cSQL

//---------------------------------------------------------------------------
/*/{Protheus.doc} OpAltLote

Função que faz a alteração em lote da tabela principal da pesquisa usando os campos

@param		aCampos

@author	André Spirigoni Pinto
@since		09/02/2015
/*/
//---------------------------------------------------------------------------
METHOD OpAltLote(aCampos, aCampDe) CLASS TJurPesqDes
Local aArea     := GetArea()
Local cAlote    := GetNextAlias()
Local cSQL      := Self:MontaSQL()
Local aAltera   := {}
Local oModel099 := Nil
Local oNT3      := Nil
Local cCampo    := ""
Local nI        := 0
Local nC        := 0
Local nQtd      := 0
Local aExcecao  := Self:getExcecaoLote()
Local aErro     := {}
Local cMsg      := ""

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlote, .T., .F.)

//Preenche o array com os registros que serão alterados
While (cAlote)->(!Eof())
	aAdd(aAltera,{(cAlote)->NT3_FILIAL,(cAlote)->NT3_COD})
	(cAlote)->(dbSkip())
End

ProcRegua(Len(aAltera)) //Preenche a lista de registros que serão alterados.

(cAlote)->( dbcloseArea() )

DbSelectArea("NT3")
NT3->(DBSetOrder(2)) //NT3_FILIAL+NT3_COD

For nI := 1 to len(aAltera)

	If lAbortPrint //Indica que a operação foi abortada
		Exit
	EndIf

	if NT3->(dbSeek(aAltera[nI][1] + aAltera[nI][2]))

		lPesquisa := .F.

		oModel099 := FWLoadModel( 'JURA099' )
		oModel099:SetOperation( 4 )
		oModel099:Activate()

		INCLUI := .F.
		ALTERA := .T.

		oNT3 := oModel099:GetModel( 'NT3MASTER' )

		//Valida se o modelo está no mesmo registro
		if (oNT3:GetValue("NT3_FILIAL") == aAltera[nI][1] .And. oNT3:GetValue("NT3_COD") == aAltera[nI][2])
			For nC := 1 to len(aCampos)
				cCampo := aCampos[nC]:cNomeCampo
				if !Empty(aCampos[nC]:Valor) //valida se o valor foi preenchido
					//valida se o valor do campo é igual ao antigo
					if (aScan(aExcecao,cCampo)>0 .Or. oNT3:GetValue(cCampo) == aCampDe[aScan(aCampDe,{|x| x[1]==cCampo})][2])
						oNT3:SetValue(cCampo,aCampos[nC]:Valor) //seta o valor novo
					endif
				Endif
			Next
		endif

		If oModel099:VldData()
			nQtd++
			oModel099:CommitData()
		else
			aErro := oModel099:GetErrorMessage()

			cMsg  := AllToChar( aErro[6] ) + CRLF //"Mensagem do erro: "

			Alert( STR0004 + cMsg ) //"Erro na alteração em lote: "

			if ApMsgYesNo(STR0005) //"Deseja continuar a alteração de forma manual?"
				if (Self:JurProc(aAltera[nI][1],aAltera[nI][2],,4,10,oModel099))
					nQtd++
				endif
			endif
		endif

		oModel099:DeActivate()

		IncProc(I18N(STR0006,{AllTrim(str(nI)),Alltrim(str(Len(aAltera)))} )) //"Processando registro #1 de #2"

	Endif

Next

ApMsgInfo(I18N(STR0007,{AllTrim(str(nQtd))})) //"#1 Registros alterados."

lAbortPrint := .F.

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilial
Função que retorna a filial do registro posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFilial (nLinha) CLASS TJurPesqDes

Return Self:JA162Assjur("NT3_FILIAL", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} menuAnexos
Metodo de Anexos

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD menuAnexos() CLASS TJurPesqDes

JurAnexos(Self:cTabPadrao, Self:getCajuri()+Self:getCodigo(), 1, Self:getFilial() )

self:refreshLegenda()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilDes
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author Marcelo Araujo Dente
@since 26/03/18
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFilDes(nLinha) CLASS TJurPesqDes
Return Self:JA162Assjur("NT3_FILDES", nLinha)
