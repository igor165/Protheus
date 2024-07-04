#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TJURPESQASJ.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "MSOLE.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqAsj
CLASS TJurPesqAsj
@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurPesqAsj FROM TJurPesquisa

	DATA cRotina //indica a rotina utilizada nas operações

	METHOD New (cTipo, cTitulo, cRotina) CONSTRUCTOR
	METHOD SetMEBrowse (oLstPesq)
	METHOD LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa)
	METHOD getCajuri (nLinha)
	METHOD getCodigo (nLinha)
	METHOD getFilPro (nLinha)
	METHOD getMenu(oMenu)
	METHOD getBrHeader()
	METHOD getBrCols(cSQL, cCampos, aHead)
	METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca)
	METHOD MostraLegenda(oLstPesq)
	METHOD getFilial (nLinha)
	METHOD GetLegenda(cTipoAS)
	METHOD TmpPicture( cUser, cThread, nOperation )
	METHOD CallRelGen(cCfgRel, lIndPag, cUser, cThread, oLstFila, cAssunto, lConcessao )
	METHOD ConcValida( oCombo, cAssunto, lConcessao )
	METHOD aLstCbox(cUser, cThread, cTipoAs)
	METHOD J162PConc(oLstPesq, oLstFila, cUser, cThread,oCmbConfig)
	METHOD ParamRelat( oLstPesq, oLstFila, cUser, cThread, oCmbConfig)
	METHOD VldRelat(cCbAndUlt, cTGetQtd, cCBIntDat, dTGetDt1, dTGetDt2, oCombo1)
	METHOD SetDftValue(lImpAnd, cCbAndCli, cCbAndUlt, cTGetQtd,cCBIntDat, dTGetDt1, dTGetDt2, oLstFila, cUser,cThread, cCfgRelat, oDlg, lChkPag, lChkGar, lChkDoc,cCbVlrHist, cAnoMes, cTipImpr)
	METHOD ImpRelDot(oLstFila, cCfgRelat, cRelDot, lChkDoc, cChrTipImp)
	METHOD ImpRep01(cUser, cThread, cImpAnd, cAndCli, cAndUlt,cAndQtd, cIntDat, cDtIni, cDtFim,cCfgRelat, oDlg, cImpPag,cImpGar, cImphist, cAnoMes)
	METHOD J162ObPar(cCampo, cAssJur)
	METHOD J162WhenCp(cConf, oChkPag, oChkAnd, oChkGar, oCbAndCli, oCbAndUlt, oCBIntDat, lChkPag, lCheck, lChkGar, cCbAndCli, cCbAndUlt, oTGetQtd, cCBIntDat, oTGetDt1, oTGetDt2, oChkDoc, lChkDoc, oTipImpr, oCbTipImpr)
	METHOD OpAltLote(aCampos, aCampDe)
	METHOD SelModel(cTipoAj)
	METHOD J162IncMod(oModel, cCodMod)
	METHOD J162ExcMod(cCodMod)
	METHOD J162SelMod()
	METHOD dblClickBrw()
	METHOD J162RelDot(cRelat, aTxt, aVar, nCont, cPath, lChkDoc)
	METHOD getComplLote()
	METHOD getMoreRows(nQtd)
	METHOD gOnMove(nLinha)
	METHOD getExcecaoLote()
	METHOD getComplExc()
	METHOD getTelaExtr(cCampo)
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqAsj
CLASS TJurPesqAsj

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTipo, cTitulo, cRotina) CLASS TJurPesqAsj
Default cRotina := "JURA095"

_Super:New (cTitulo)

Self:setTipoPesq(cTipo)
Self:SetTabPadrao("NSZ")
Self:cRotina := cRotina
Self:cTabPadrao := "NSZ"

If !(self:montalayout())
	Self:oDesk:SetLayout({{"01",30,.T.},{"02",70,.T.}}) //layout da tela.

	Self:oPnlPrinc := Self:loadCmbConfig(Self:oDesk:getPanel("01"))

	Self:loadGrid(Self:oDesk:getPanel("02"))
	Self:loadAreaCampos(Self:oPnlPrinc)

	Self:oFila := TJurFilaImpressao():New(Self:oDesk:getPanel("02"),Self,Self:oPnlCfgFila,Self:oLstPesq)
	J106MetFup() // Valida se há configuração de envio de e-mail de prazos e tarefas (Fups) para envio de metricas para o License server
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
METHOD SetMEBrowse (oLstPesq) CLASS TJurPesqAsj
oLstPesq:SetDoubleClick({|| Self:dblClickBrw() })

oLstPesq:SetRightClick({ | oObj, nRow, nCol | Self:oFila:MenuPopPesq(oObj, nRow, nCol, Self:oLstPesq, Self:oFila:cCfgFila, Self:oFila:lDesAtivo, Self:oFila:lVincAtivo)})

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} getCajuri
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCajuri (nLinha) CLASS TJurPesqAsj
Return Self:JA162Assjur("NSZ_COD", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodigo
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCodigo (nLinha) CLASS TJurPesqAsj
Return Self:JA162Assjur("NSZ_COD", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilPro
Função que retorna a filial do processo posicionado no Grid ou na linha escolhida

@param  nLinha  - Linha do grid selecionada no grid de pesquisas
@return Retorna a filial da linha posicionada. Conteudo do campo NSZ_FILIAL

@since 17/12/2020
/*/
//-------------------------------------------------------------------
METHOD getFilPro (nLinha) CLASS TJurPesqAsj
Return Self:JA162Assjur("NSZ_FILIAL", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getMenu()
Função que monta o menu lateral principal.

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getMenu(oMenu) CLASS TJurPesqAsj
Local aRelat 	:= {}
Local aEspec	:= {}
Local bCorrecao

if Self:lAnoMes
	bCorrecao := {| oObj | IIF(Self:befAction(),Self:MenuCorr(Self:oLstPesq,oObj,Self:aTables),)}
else
	bCorrecao := {|| Self:JA162BCorr(Self:oLstPesq,Self:aTables,val(Self:cTipoPesq),.F.) }
endif

aAdd(aEspec,{STR0046,{|| Self:JA162Menu(3,Self:oLstPesq,Self:aObj,Self:oCmbConfig,.T. /*lModelo*/)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst('14', 3)) .Or. Empty(Self:cGrpRest))} }) //"Incluir com Modelo"
aAdd(aEspec,{STR0047,{|| Self:J162SelMod()}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst('14', 5)) .Or. Empty(Self:cGrpRest))} }) //"Excluir Modelo"
aAdd(aEspec,{STR0003 + IIF(Self:lAnoMes," >",""),bCorrecao,{|| JA162AcRst('16', 3) } }) //"Correção Monetária"

aAdd(aRelat, {STR0008,{||Self:oFila:PnlFila()} }) //"Fila de Impressão"

oMenu := Self:setMenuPadrao(oMenu, , , aRelat, aEspec, '14')

Return oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrHeader() CLASS TJurPesqAsj
Local aCampos := {}

//Campos padrão
aAdd(aCampos, {"NSZ_COD",JA160X3Des("NSZ_COD"),"2"})
aAdd(aCampos, {"NSZ_FILIAL",JA160X3Des("NSZ_FILIAL"), "2"})
aAdd(aCampos, {"NSZ_TIPOAS",JA160X3Des("NSZ_TIPOAS"), "2"})

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrCols()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrCols(cSQL, cCampos, aHead) CLASS TJurPesqAsj
Local aCol			:= {}
Local aArea     	:= GetArea()
Local aAreaNSZ	:= NSZ->( GetArea() )
Local cLista		:= GetNextAlias()
Local lShowPes	:= .F.
Local nQtd			:= 0
Local nCols		:= 0
Local nX			:= 0
Local cTpPai		:= "" //Variável auxiliar que guarda o assunto pai do processo da fila
Local cTpAs		:= "" //Variável auxiliar que guarda o assunto do processo da fila

If ValType(cSql) == "U" .Or. Empty(cSQL)
	If ValType(cSql) == "U"
		lShowPes:= .T.
	EndIf

	cSQL := "SELECT "+cCampos+ ", " + "NSZ001.R_E_C_N_O_ " + CRLF
	cSQL += "  FROM "+RetSQlName('NSZ')+" NSZ001 "+ CRLF
	cSQL := Self:JQryPesq(cSQL, Self:cTabPadrao)
	cSQL += " Where 1=2 "

EndIf

cSQL := ChangeQuery(cSQL)
//O change query está trocando '' por ' ', que está comprometendo a consulta
cSQL := StrTran(cSQL,",' '",",''")
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cLista, .T., .F.)

dbSelectArea(cLista)

Self:cCurRec := ""
Self:oLstPesq:clearPaginacao()

While (cLista)->(!Eof())

	//incrementa quantidade de linhas
	nQtd++

	if nQtd <= Self:nMaxQry
		//Posiciona no assunto jurídico que esta sendo inserido no grid
		DbSelectArea("NSZ")
		NSZ->( DbSetOrder(1) )	//NSZ_FILIAL_NSZ_COD
		NSZ->( DbSeek((cLista)->NSZ_FILIAL + (cLista)->NSZ_COD) )

		aAdd(aCol,Array(LEN(aHead)+4))
		nCols++

		//usado na legenda. Por questões de performance, pesquisa assuntos pais o mínimo de vezes possível.
		if (cTpAs != (cLista)->NSZ_TIPOAS)
			cTpAs := (cLista)->NSZ_TIPOAS
			If cTpAs > '050'
				cTpPai := J162PaiAJur(cTpAs)
			Else
				cTpPai := ""
			EndIf
		Endif


		For nX := 1 To LEN(aHead)

			If nX == 1
				aCol[nCols][nX] := Self:GetLegenda(IIF(Empty(cTpPai),cTpAs,cTpPai))
			Elseif (aHead[nX][10] != "V") //Valida se não é um campo virtual para evitar um fieldget/fieldpos
				aCol[nCols][nX] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))
			EndIf

		Next nX

		aCol[nCols][LEN(aHead)+1] := (cLista)->NSZ_COD
		aCol[nCols][LEN(aHead)+2] := (cLista)->NSZ_FILIAL
		aCol[nCols][LEN(aHead)+3] := (cLista)->NSZ_TIPOAS
		aCol[nCols][LEN(aHead)+4] := .F.
	Else
		if Empty(Self:cCurRec)
			Self:cCurRec := (cLista)->NSZ_COD
			Self:cAlQry := cLista
			Self:oLstPesq:SetPaginacao(self) //bloco definido gOnMove
		Endif
	Endif

	(cLista)->(dbSkip())
End

if Empty(Self:cCurRec) //se não houve paginação, pode fechar o alias
	(cLista)->( dbcloseArea() )
	Self:oLstPesq:clearPaginacao()
Endif

RestArea( aAreaNSZ )
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
METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca) CLASS TJurPesqAsj
Local cSQL       := ''
Local aSQL       := {}
Local aSQLRest   := {}
Local cTpAJ      := ""
Local cExists    := ""
Local cWhere     := ""
Local NSZName    := Alltrim(RetSqlName("NSZ"))
Local aFilUsr    := JURFILUSR( __CUSERID, "NSZ" )
Local cValorCpo  := ''
Local cTpPesq	 := Self:cTipoPesq
Local cPesqAtv	 := oCmbConfig:cValor
Local nI         := 1

cValorCpo := IIf (Self:lPesqGeral, Alltrim(Lower(aObj[1]:Valor)),'')

aSQLRest := Ja162RstUs()

cSQL := "SELECT "+cCampos+ ", NSZ001.R_E_C_N_O_ " + CRLF
cSQL += "  FROM "+NSZName+" NSZ001"+ CRLF

If SuperGetMV("MV_JORDENA",, "1") == "2"
	AAdd(aManual,{"NSZ", "NSZ001", "NT9", "NT9A", "NT9A.NT9_TIPOEN = '1' AND NT9A.NT9_PRINCI = '1'"})
	AAdd(aManual,{"NSZ", "NSZ001", "NT9", "NT9R", "NT9R.NT9_TIPOEN = '2' AND NT9R.NT9_PRINCI = '1'"})
Endif

For nI := 1 to LEN(aObj)
	If !(aObj[nI] == NIL) .And. !(Empty(aObj[nI]:Valor))
		If aObj[nI]:GetNameField() $ 'NUQ_CCOMAR/NUQ_CLOC2/NUQ_CLOC3/NUQ_NUMPRO/NSZ_CCLIEN/NUQ_CCORRE'
			AAdd(aManual,{"NSZ", "NSZ001", "NUQ", "NUQ001", "NUQ001.NUQ_INSATU = '1'"})
		Endif
		aAdd(aSQL, {aObj[nI]:GetTable(),Self:TrocaWhere(aObj[nI],aTroca)})// Tabela  Where
	EndIf
Next

cSQL := Self:JQryPesq(cSQL,Self:cTabPadrao, aManual)
cTpAJ := AllTrim( JurSetTAS(.F.) )

//Tratamento de aspas simples para a query
cTpAJ := IIf(  Left(cTpAJ,1) == "'", "", "'" ) + cTpAJ
cTpAJ += IIf( Right(cTpAJ,1) == "'", "", "'" )

If ( VerSenha(114) .or. VerSenha(115) )
	cSQL += " WHERE NSZ_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) +  CRLF
Else
	cSQL += " WHERE NSZ_FILIAL = '"+xFilial("NSZ")+"'"+ CRLF
Endif

//Ponto de Entrada de Cláusula para Query - JA162QRY
If ExistBlock("JA162QRY")
	cSQL += ExecBlock("JA162QRY",.F.,.F.,{cTpAJ,cTpPesq,cPesqAtv})
EndIf

cSQL += "   AND NSZ001.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += "   AND NSZ_TIPOAS IN (" + cTpAJ + ")" + CRLF

cSQL += VerRestricao()  //Restricao de Escritorio e Area

cSQL += Self:GetCondicao(aSQL, NSZName) + CRLF

If !Empty(aSQLRest)
	cSQL += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ)+")"
EndIf

If !Empty(cValorCpo)
	cValorCpo	:=	StrTran(JurLmpCpo( cValorCpo,.F. ),'#','')

	cWhere		:= " AND " + JurFormat("NT9_NOME", .T./*lAcentua*/,.T./*lPontua*/) + " Like '%" +cValorCpo+ "%'" + CRLF
	cExists	:= " AND (" + SUBSTR(Self:GetEXISTS(RetSqlName("NT9"), cWhere),5)
	cSQL		+= cExists

	cWhere		:= " AND " + JurFormat("NUQ_NUMPRO", .F./*lAcentua*/,.T./*lPontua*/) + " Like '%" +cValorCpo+ "%'" + CRLF
	cExists	:= " OR " + SUBSTR(Self:GetEXISTS(RetSqlName("NUQ"), cWhere),5)
	cSQL		+= cExists

	cWhere		:= " AND " + JurFormat("NSZ_DETALH", .T./*lAcentua*/,.T./*lPontua*/) + " Like '%" +cValorCpo+ "%'" + CRLF
	cExists	:= " OR " + SUBSTR(Self:GetEXISTS(RetSqlName("NSZ"), cWhere),5)
	cSQL		+= cExists

	cWhere		:= " AND " + JurFormat("NSZ_NUMCON", .T./*lAcentua*/,.T./*lPontua*/) + " Like '%" +cValorCpo+ "%'" + CRLF
	cExists	:= " OR " + SUBSTR(Self:GetEXISTS(RetSqlName("NSZ"), cWhere),5)
	cSQL		+= cExists

	cSQL += " ) "
EndIf

if SuperGetMV("MV_JORDENA",, "1") == "2"
	cSQL += " ORDER BY NT9A.NT9_NOME, NT9R.NT9_NOME	"
else
	cSQL += " ORDER BY NSZ_CCLIEN, NSZ_LCLIEN, NSZ_NUMCAS "
endif

aSize(aSQL,0)
aSize(aSQLRest,0)
aSize(aFilUsr,0)

Return cSQL

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadRotina
Função genérica para criação do oModel com os campos correpondentes
ao tipo de assunto jurídico, follow up ou garantia.
Uso Geral.
@param  cCod    	    Código do assunto jurídico / follow up /garantia
@param  nOper   	    Código da operação do Protheus
@Param	 aObj 		    Array com os Objetos de campos de filtro.
@Param	 oLstPesq	  Grid.
@Param  oCmbConfig	Combo que contém as configurações de Layout.
@Param  cRotina    	Nome da Rotina que será aberta



@author Clóvis Teixeira
@since 02/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa) CLASS TJurPesqAsj
Local lOK       := .T.
Local nRet      := 1
Local oM95      := Nil
Local cNszFil   := ""
Local cNszCod   := ""
Local bOk       := {|| IIF(nOper == 3, (cNszFil := xFilial("NSZ"), cNszCod := oM95:GetValue("NSZMASTER","NSZ_COD")),), .T.}
Local cCodMod   := ""
Local bClose    := {|| !("1" $ JGetParTpa(cTipoAJ, "MV_JALTREG", "1"))}//Define se a tela irá continuar aberta ou não, após inclusão ou Alteração

Default oModel  := NIl
Default nTela   := 0
Default lFecha  := .F.
Default lFazPesquisa := .T. // Usado na rotina de Processos. Indica se realiza a pesquisa após o Processo ser alterado e houver confirmação (essa alteração dita é quando o Processo é reaberto em modo de alteração após a inclusão) e a tela for fechada.

If nOper == 3 .And. (cTipoAJ == '000' .Or. cTipoAJ == '')
	If cTipoAJ == '000'
		Alert(STR0002) //"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!"
	EndIf
	lOK := .F.
Else
	If !Empty(cCod)
		NSZ->(DBSetOrder(1))
		NSZ->(dbSeek(cFil + cCod))
		If Empty(cTipoAJ)
			c162TipoAs := JurGetDados('NSZ', 1, cFil + cCod, 'NSZ_TIPOAS')
		Else
			c162TipoAs := cTipoAJ
		Endif
	Else
		lOK := (nOper == 3)
		c162TipoAs := cTipoAJ
	EndIf
EndIf

cTipoAsJ := c162TipoAs

If lOK
	INCLUI := (nOper==3)
	ALTERA := (nOper==4)

	If INCLUI
		if oModel == NIl
			oM95 := FWLoadModel( 'JURA095' )
			oM95:SetOperation( nOper )
			oM95:Activate()
			oM95:SetValue("NSZMASTER","NSZ_TIPOAS",cTipoAsJ)
		Endif

		If lModelo
			cCodMod := Self:SelModel(cTipoAJ) // Seleciona o modelo
			oM95    := Self:J162IncMod(oM95, cCodMod)
		EndIf

		bClose := Nil

	Else
		if (oModel != NIl)
			oM95 := oModel
			lfecha := .T.
		else
			oM95 := Nil
		endif
	Endif

	If (lModelo .AND. !Empty(cCodMod)) .Or. (!lModelo)
		MsgRun(STR0009,STR0010,{|| nRet:=FWExecView(cMsg,Self:cRotina, nOper,,bClose, bOk ,nTela,,,,,oM95 )}) //"Carregando..." e "Pesquisa de Processos"
	EndIf

	If INCLUI .AND. nRet == 0 .And. ("1" $ JGetParTpa(cTipoAJ, "MV_JALTREG", "1"))
		If !Empty(cNszCod)
			//Se incluiu e foi criado um assunto jurídico, abrir o mesmo.
			Self:JurProc(cNszFil,cNszCod,,4)
		Endif
	Endif

Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MostraLegenda(oLstPesq)
Função utilizada para mostrar uma tela com a legenda das cores dos
tipos de Assunto Jurídico.
Uso Geral.

@Param	oLstPesq		Lista de registros(Grid).

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MostraLegenda(oLstPesq) CLASS TJurPesqAsj
Local oDlg, nI, aBmp := {}, aSay := {}
Local oPnlOK, oPnlImg, oPnlDesc, oBtnOK
Local cCor
Local nEscolhida

Begin Sequence

    If  (Len(oLstPesq:aCols) == NIL)
        Break
    EndIf

    cCor := oLstPesq:aCols[oLstPesq:NAT][1]

    // Caso nao der o Activate() depois que criou o dialogo abaixo, ira anular o botao sair da tela principal.
    oDlg := MSDialog():New(0,0,300,350,STR0011,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Legenda do Tipo de Assunto"

    oPnlOK   := tPanel():New(0,0,'',oDlg,,,,,,10,10)
    oPnlImg  := tPanel():New(0,0,'',oDlg,,,,,,10,10)
    oPnlDesc := tPanel():New(0,0,'',oDlg,,,,,,90,10)
    oPnlOK:Align   := CONTROL_ALIGN_BOTTOM
    oPnlImg:Align  := CONTROL_ALIGN_LEFT
    oPnlDesc:Align := CONTROL_ALIGN_ALLCLIENT

    For nI := 1 to 11
        aAdd(aBmp, TBitmap():New(0,0,10,10,,Self:GetLegenda(PADL(nI,3,'0')),.T.,oPnlImg,{|| },,.F.,.F.,,,.F.,,.T.,,.F.) )
        aBmp[nI]:Align := CONTROL_ALIGN_TOP

        If  (aBmp[nI]:CBMPFILE == cCor)
		 	  nEscolhida := nI
        EndIf
    Next nI

    NYB->(DBSetOrder(1))
    NYB->(dbGoTop())

    If  NYB->( DBSeek(XFILIAL('NYB')+'001') )
        nI := 1

        Do  While NYB->( !( Eof() ) .And.  (NYB_COD < '051') )

            aAdd(aSay, tSay():New(01,01,{|| ''},oPnlDesc,,,,,,.T.,,,10,10))

            aSay[LEN(aSay)]:Align        := CONTROL_ALIGN_TOP
            aSay[LEN(aSay)]:SetText(AllTrim(NYB->NYB_DESC)+IIF(nEscolhida == nI, '	* ', ''))
            aSay[LEN(aSay)]:lWordWrap    := .T.
            aSay[LEN(aSay)]:lTransparent := .T.

            NYB->(dbSkip())
            nI += 1
        EndDo

    EndIf

    oBtnOK := SButton():New( 01,01,1,{|| oDlg:End()},oPnlOK,.T.,,)
    oBtnOK:Align := CONTROL_ALIGN_LEFT

    oDlg:Activate(,,,.T.,,,)

    For nI := 1 to len(aBmp)
        If aBmp[nI] != NIl
	        aBmp[nI]:Destroy()
	        aBmp[nI]:= Nil
        Endif
    Next nI

    For nI := 1 to len(aSay)
        If aSay[nI] != NIl
	        aSay[nI]:Destroy()
	        aSay[nI]:= Nil
        Endif
    Next nI

    aSize(aBmp,0)
    aSize(aSay,0)

End Sequence

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilial
Função que retorna a filial do registro posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFilial (nLinha) CLASS TJurPesqAsj
Return Self:JA162Assjur("NSZ_FILIAL", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLegenda(cTipoAS)
Função utilizada para retornar a cor referente ao tipo de assunto jurídico.
Uso Geral.

@Param	cTipoAS		Código do tipo de assunto jurídico.
@Return	cImagem		Nome do BMP da cor.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetLegenda(cTipoAS) CLASS TJurPesqAsj
Local cImagem := ''

If cTipoAS > '050'
	cTipoAS := J162PaiAJur(cTipoAS)
EndIf

Do Case
	Case cTipoAS == '001'; cImagem := 'BR_AZUL.PNG'
	Case cTipoAS == '002'; cImagem := 'BR_BRANCO.PNG'
	Case cTipoAS == '003'; cImagem := 'BR_VERDE.PNG'
	Case cTipoAS == '004'; cImagem := 'BR_AMARELO.PNG'
	Case cTipoAS == '005'; cImagem := 'BR_MARROM.PNG'
	Case cTipoAS == '006'; cImagem := 'BR_LARANJA.PNG'
	Case cTipoAS == '007'; cImagem := 'BR_PRETO.PNG'
	Case cTipoAS == '008'; cImagem := 'BR_VERMELHO.PNG'
	Case cTipoAS == '009'; cImagem := 'BR_CINZA.PNG'
	Case cTipoAS == '010'; cImagem := 'BR_PINK.PNG'
	Case cTipoAS == '011'; cImagem := 'BR_VIOLETA.PNG'
End Case

Return cImagem

//-------------------------------------------------------------------
/*/{Protheus.doc} CallRelGen
Rotina que gera os relatorios Crystal

@owner      rodrigo.guerato
@author     rodrigo.guerato
@since      25/07/2013
@version    1.0
/*/
//+--------------------------------------------------------------------------
METHOD CallRelGen(cCfgRel, lIndPag, cUser, cThread, oLstFila, cAssunto, lConcessao ) CLASS TJurPesqAsj
Local cRelat		:= ""
Local cParams		:= ""
Local cOptions	:= "1;0;1;"
Local cAliasNQ9	:= GetNextAlias()
Local cAliasNQK	:= GetNextAlias()
Local cAliasNQR	:= GetNextAlias()
Local aArea		:= GetArea()
Local aAreaNSZ	:= NSZ->( GetArea() )
Local cTipos		:= SuperGetMv("MV_JRELCON",,"")
Local cSituacao	:= SuperGetMv("MV_JSOCAND",,"")
Local cDTipos		:= ""
Local aTipos		:= {}
Local nX			:= 0
Local aTab			:= {}
Local xResult		:= {}	// Utilizado para geracao de relatorio de marcas e paten.
Local cExtens		:= ""
	//Padrao
	cParams := cUser
	cParams += ';' + cThread
	cParams += ';' + Iif(lIndPag,"S","N")

	//Societario
	If cAssunto == '008'
		If !lConcessao //Concessoes
			cTipos := SuperGetMV("MV_JTER95B",,"")
			aTipos := StrTokArr( cTipos, "/" )

			For nX := 1 to Len( aTipos )
				If Empty( cDTipos )
					cDTipos := AllTrim( JurGetDados('NQA', 1, xFilial('NQA') + aTipos[nX], 'NQA_DESC') )
				Else
					cDTipos += "/" + AllTrim( JurGetDados('NQA', 1, xFilial('NQA') + aTipos[nX], 'NQA_DESC') )
				Endif
			Next nX
		Endif

		cParams := cUser
		cParams += ';' + cThread
		cParams += ';' + cTipos

		If lConcessao
			cParams += ';' + cSituacao
		Else
			cParams += ';' + cDTipos
		EndIf

		cParams += ';' + Iif(lIndPag,"S","N")

		If !lConcessao
			cParams += ';' + cFilAnt //Envia a filial ao RPT.
		Endif

	Endif

	BeginSQL Alias cAliasNQR

	  SELECT NQR_NOMRPT, NQR_EXTENS
	    FROM %Table:NQR% NQR
	   WHERE NQR_COD = (SELECT NQY_CRPT
	                      FROM %Table:NQY% NQY
	                     WHERE NQY_COD = %Exp:cCfgRel%
	                       AND NQY.%notDel%)
	     AND NQR.%notDel%

	EndSQL
	dbSelectArea(cAliasNQR)

	cRelat := AllTrim((cAliasNQR)->NQR_NOMRPT)

	cExtens := AllTrim((cAliasNQR)->NQR_EXTENS)

	BeginSQL Alias cAliasNQ9

		SELECT *
	  	FROM %Table:NQ9% NQ9
		 WHERE NQ9_CODRPT = (SELECT NQY_CRPT
	  	                     FROM %Table:NQY% NQY
	    	                  WHERE NQY_COD = %Exp:cCfgRel%
	    	                    AND NQY.%notDel%
	    	                    AND NQY.NQY_FILIAL = %xFilial:NQY%)
	     AND NQ9.%notDel%
	     AND NQ9.NQ9_FILIAL = %xFilial:NQ9%
		ORDER BY NQ9_PARAM

	EndSQL
	dbSelectArea(cAliasNQ9)
	(cAliasNQ9)->(DbgoTop())

	BeginSQL Alias cAliasNQK

	  SELECT *
	    FROM %Table:NQK% NQK
	   WHERE NQK_CCONF = %Exp:cCfgRel%
	     AND NQK.NQK_FILIAL = %xFilial:NQK%
	     AND NQK.%notDel%

	EndSQL
	dbSelectArea(cAliasNQK)

	While !(cAliasNQ9)->(EOF())

	  (cAliasNQK)->(DbgoTop())
	  cParam := ''

	  While !(cAliasNQK)->(EOF())

	    If (cAliasNQ9)->NQ9_COD == (cAliasNQK)->NQK_CCAMPO

	      If NQK_IMPRIM == '2'
	        cParam := 'N'
	      Else
	        cParam := RTrim((cAliasNQK)->NQK_DISPLY)
	      Endif

	    Endif

	    (cAliasNQK)->(dbSkip())
	  End

	  cParams += ';' +cParam
	  (cAliasNQ9)->(dbSkip())

	End

	cParams += ';'
	(cAliasNQR)->(DbCloseArea())
	(cAliasNQK)->(DbCloseArea())
	(cAliasNQ9)->(DbCloseArea())

	If cAssunto == "011" //Marcas e Patentes
		xResult:= Self:TmpPicture( cUser, cThread, 1 ) // Cria a pasta temporaria para a imagem no relatório
		/*
			xResult[1] => .T. ou .F.
			xResult[2] => Diretorio temporario para geração da imagem p/ relatorio
		*/

		IF xResult[1]
			cParams := cUser
			cParams += ';' + cThread
			cParams += ';' + Iif(lIndPag,"S","N")
			cParams += ';' + xResult[2]	// Adiciona o diretorio temporario para o parametro do relatorio

		 	cDir := xResult[2] + cUser + cThread + "\"
			If cExtens == "3" //Verifica se o relatório tem extensão .PRW
				bRelat := &("{|cUser, cThread, cDir| " + (cRelat) + "(cUser, cThread, cDir)}")
				Eval(bRelat, cUser, cThread, cDir) //Chamada do relatório PRW
			Else
				JCallCrys(cRelat, cParams, cOptions,.T.,.T.)//Chamada da função de impressão do relatório
			EndIf

			Self:TmpPicture( cUser, cThread, 2 )	// Deleta a pasta temporaria
		EndIF
	Else
		If cExtens == "3" //Verifica se o relatório tem extensão .PRW
			bRelat := &("{|cUser, cThread| " + (cRelat) + "(cUser, cThread)}")
			Eval(bRelat, cUser, cThread) //Chamada do relatório PRW
		Else
			JCallCrys(cRelat,cParams,cOptions,.T.,.T.,,aTab)//Chamada da função de impressão do relatório JUR095B/JUR095B
		EndIf
	Endif

	Self:oFila:DelAllReg() //Limpa Fila de Impressão

	RestArea( aArea )
	NSZ->( RestArea( aAreaNSZ ) )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TmpPicture
Manutencao das Imagens para geracao do relatorio de marcas e patentes

@param		cUser: Usuario da Fila
@param	 	cThread: Thread da Fila
@Param		nOperation: Operacao
@author	rodrigo.guerato
@since    	25/07/2013
@version  	1.0
/*/
//+--------------------------------------------------------------------------
METHOD TmpPicture( cUser, cThread, nOperation ) CLASS TJurPesqAsj
Local lRet 	 	:= .T.
Local aArea 	:= GetArea()
Local aAreaNSZ	:= NSZ->( GetArea() )
Local aAreaNQ3	:= NQ3->( GetArea() )
Local cTmpAlias	:= GetNextAlias()
Local cTmpDir	:= GetTempPath() +cUser + cThread
Local aFiles	:= {}
Local nI	 	:= 0
Local cSQL		:= ""

Default nOperation := 1 //1=cria Imagens - 2=Apaga Imagens

If nOperation == 1 //Cria dados

	/* Gera o diretorio */
	lRet :=  ( MakeDir(cTmpDir) == 0 )

	If lRet
		cSQL := "SELECT DISTINCT NSZ_COD, NSZ_BITMAP"+CRLF
		cSQL+= " FROM " + RetSqlName('NSZ')+" NSZ " + CRLF
		cSQL+= " JOIN " + RetSqlName('NQ3')+" NQ3 " + CRLF
		cSQL+= " ON NSZ.NSZ_COD = NQ3.NQ3_CAJURI " + CRLF
		cSQL+= " WHERE  NSZ.NSZ_BITMAP != '  ' AND  NQ3.D_E_L_E_T_ = ' ' AND NSZ.D_E_L_E_T_ = ' ' "

		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cTmpAlias, .T., .F.)

		(cTmpAlias)->( dbGoTop() )

		While (cTmpAlias)->( !Eof() )
			    lRet := RepExtract( (cTmpAlias)->NSZ_BITMAP, cTmpDir + "\" + (cTmpAlias)->NSZ_COD  )
			(cTmpAlias)->( dbSkip() )
		EndDo

		(cTmpAlias)->( dbCloseArea() )
	Else
		// "Não foi possivel criar o diretório temporário em: "
		JurMsgErro( STR0048 + cTmpDir )
	EndIf
Endif

If nOperation == 2 //Apaga o diretorio temp.

	aFiles := Directory( cTmpDir  + "\*.*")

	For nI := 1 To Len( aFiles )
		lRet := ( FErase( cTmpDir  + "\" + aFiles[nI][1] ) == 0 )
	Next nI

	if lRet
		DirRemove( cTmpDir )
	EndIF
Endif

RestArea( aArea )
NSZ->( RestArea( aAreaNSZ ) )
NQ3->( RestArea( aAreaNQ3 ) )

Return { lRet , GetTempPath() }

//-------------------------------------------------------------------
/*/{Protheus.doc} ConcValida
Valida os Parametros do Relatorio

@owner      rodrigo.guerato
@author     rodrigo.guerato
@since      25/07/2013
/*/
//--------------------------------------------------------------------------
METHOD ConcValida( oCombo, cAssunto, lConcessao ) CLASS TJurPesqAsj
	Local lRet		:= .T.
	Local cTipos 	:= SuperGetMv("MV_JRELCON",,"")
	LOcal cSitua	:= SuperGetMv("MV_JSOCAND",,"")

	If Empty(oCombo:cValor)
		JurMsgErro(STR0012) //"É necessário selecionar uma configuração para geração do relatório"
		lRet := .F.
	Endif

	If cAssunto == "008" .and. lConcessao
		If lRet .and. Empty( cTipos )
			JurMsgErro(STR0013) //"É necessário preencher o parâmetro MV_JRELCON para emissão do relatório. Verifique !"
			lRet := .F.
		Endif

		If lRet .and. Empty( cSitua )
			JurMsgErro(STR0014) //"É necessário preencher o parâmetro MV_JSOCAND para emissão do relatório. Verifique !"
			lRet := .F.
		Endif
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J162PConc
Parametros do relatório de concessões

@owner      rodrigo.guerato
@author     rodrigo.guerato
@since      25/07/2013
@param      uParam
@return     uReturn
@sample     Exemplo de como deve ser executada a funcao

@project    project
@menu       Posição no menu
@version    1.0
@obs        Observacoes
/*/
//--------------------------------------------------------------------------
METHOD J162PConc(oLstPesq, oLstFila, cUser, cThread,oCmbConfig) CLASS TJurPesqAsj
Local oDlg
Local oCombo1
Local oCfgRelat
Local oChkPag
Local aAreaNSZ := NSZ->( GetArea() )
Local aArea    := GetArea()
//é preciso trabalhar com o assunto jurídico pai e não o filho.
Local cAJuri   := J162PaiAJur(JurGetDados('NSZ', 1, Self:oFila:getFilial() + Self:oFila:getCajuri(), 'NSZ_TIPOAS'))


  DEFINE DIALOG oDlg TITLE STR0015 FROM 180,180 TO 410,670 PIXEL //"Parâmetros do Relatórios"

    aItemsCb  := Self:aLstCbox(cUser, cThread, cAJuri)
    lChkPag   := .T.

    oCfgRelat := TSay():New(03,010,{||STR0016},oDlg,,,,,,.T.,,,100,10) //"Config. Relatório"
    oCombo1   := TJurCmbBox():New(10,10,160,10,oDlg,aItemsCb,{||})
    oChkPag   := TCheckBox():Create( oDlg,{|u|if( pcount()>0,lChkPag := u, lChkPag)},22,10,STR0017,100,10,,,,,,,,.T.,,,) //"Imprimir nº de Página"

    Define SButton From 100, 215 Type 2 Enable Of oDlg Action oDlg:End()
    Define SButton From 100, 170 Type 1 Enable Of oDlg Action {||oDlg:SetFocus(), Iif( Self:ConcValida(oCombo1,cAJuri,.T.), ;
    																							(Self:CallRelGen(oCombo1:cValor, lChkPag, cUser, cThread, oLstFila, cAJuri, .T. ),oDlg:End()), ;
    																							) }
    ACTIVATE DIALOG oDlg CENTERED

    RestArea( aArea )
    NSZ->( RestArea( aAreaNSZ ) )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} aLstCbox(cUser, cThread, cTipoAs)
Função utilizada para criar a lista de configurações do relatório
Uso Geral.
@Return 	Array com a lista de configurações
@author Clóvis Eduardo Teixeira
@since 18/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD aLstCbox(cUser, cThread, cTipoAs) CLASS TJurPesqAsj
Local aRet      := {""}
Local aArea     := GetArea()
Local cSQL  	:= ''
Local cAliasQry := GetNextAlias()

cSQL:= "SELECT NQY_COD ||' = '|| NQY_DESC NQY_DESC "
cSQL+= " FROM " + RetSqlName('NVL')+" NVL, " + RetSqlName('NQY')+ " NQY"
cSQL+= " WHERE NQY_COD = NVL_CODCON AND "
cSQL+= " NVL_CTIPOA = '" + cTipoAs +"' AND "
cSQL+= " NVL.NVL_FILIAL = '" + xFilial('NVL')+"' AND"
cSQL+= " NQY.NQY_FILIAL = '" + xFilial('NQY')+"' AND"
cSQL+= " NVL.D_E_L_E_T_ = ' ' AND NQY.D_E_L_E_T_ = ' '"

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAliasQry, .T., .F.)

dbSelectArea(cAliasQry)
(cAliasQry)->(DbgoTop())

While !(cAliasQry)->(EOF())
	aAdd(aRet, (cAliasQry)->NQY_DESC )
	(cAliasQry)->(dbSkip())
End

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ParamRelat(oLstPesq)
Função para informar os parametros do relatório de processo
Uso Geral
@Param	oLstPesq	Objeto com o grid da pesquisa
@Param	oLstFila  Objeto da Fila de Impressão
@Param	cUser     Código do usuário
@Param	cThread   Código da Thread
@Param	oPanel    Panel de Fila de Impressão
@Param	oPanelPai Panel Principal da tela de pesquisa
@Return Nil
@author Clóvis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ParamRelat( oLstPesq, oLstFila, cUser, cThread, oCmbConfig) CLASS TJurPesqAsj
Local oAndCli, oAndUlt, oIntDat, oCombo1, oCfgRelat, oChkPag, oChkGar, oChkDoc, cCbVlrHist, oTGetAnomes, oCbVlrHist
Local oDlg, oChkAnd, oCbAndCli, oVlrHist, oCbAndUlt, oTGetQtd, oCBIntDat, oTGetDt1, oTGetDt2
Local lCheck, lChkDesd, lChkVinc, lChkPag, lChkGar, lChkDoc
Local cCbAndCli, cCbAndUlt, cCBIntDat, cCfgRelat, cTGetQtd, cTipImpr
Local oTipImpr
Local oCbTipImpr
Local nI         := 1
Local bAction    := {||}
Local aAreaNSZ   := NSZ->( GetArea() )
Local aArea 	 := GetArea()
//é preciso trabalhar com o assunto jurídico pai e não o filho.
Local cTaJuri    := J162PaiAJur(JurGetDados('NSZ', 1, Self:oFila:getFilial() + Self:oFila:getCajuri(), 'NSZ_TIPOAS'))
Local aItemsCb   := {}
Local aItems     := {}
Local aItemsCl   := {}
Local aItemsImp  := {}
Local lAnoMes    := (SuperGetMV('MV_JVLHIST',, '2') == '1')
Local cValAnoMes := ""
Local cGrpRest   := JurGrpRest()

	DEFINE MSDIALOG oDlg TITLE STR0015 FROM 180,180 TO 410,670 PIXEL //"Parâmetros do Relatórios"

	aItemsCb  := Self:aLstCbox(cUser, cThread, cTaJuri)
	lCheck    := .T.
	lChkDesd  := .F.
	lChkVinc  := .F.
	lChkPag   := .T.
	lChkGar   := .T.
	lChkDoc   := .F.
	aItems    := {STR0025, STR0024}          //{'Não', 'Sim'}
	aItemsCl  := {STR0037, STR0025, STR0024} //{'Todos', 'Não', 'Sim'}
	aItemsImp := {STR0054, STR0055}

	If Existblock("JA162AndCli")
		nI := ExecBlock("JA162AndCli",.F.,.F.)
	EndIf

	If 'CLIENTES' $ cGrpRest
		cCbAndCli  := aItemsCl[3]
	Else
		cCbAndCli  := aItemsCl[nI]
	EndIf

	cCbAndCli  := aItemsCl[nI]
	cCbAndUlt  := aItemsCl[1]
	cCbVlrHist := aItems[1]
	cCBIntDat  := aItems[1]
	cCfgRelat  := aItemsCb[1]
	cTGetQtd   := "   "

	//Estes Campos serao padrao para todos os relatorios

	If cTaJuri $ "011/008" //Marcas e Patentes //Societario
		oCfgRelat := TSay():New(03,010,{||STR0016},oDlg,,,,,,.T.,,,100,10) // "Config. Relatório"
		oCombo1   := TJurCmbBox():New(10,10,160,10,oDlg,aItemsCb,{||})
		oChkPag   := TCheckBox():Create( oDlg,{|u|if( pcount()>0,lChkPag := u, lChkPag)},22,10,STR0017,100,10,,,,,,,,.T.,,,)   //"Imprimir nº de Página"

		bAction := {|| oDlg:SetFocus(), ;
		               Iif( Self:ConcValida( oCombo1, cTaJuri, .F. ),;
		               Self:CallRelGen(oCombo1:cValor, lChkPag, cUser, cThread, oLstFila, cTaJuri, .F. ),),;
		               oDlg:End()}
	Else
		oCfgRelat := TSay():New(03,010,{||STR0016},oDlg,,,,,,.T.,,,100,10)   //"Config. Relatório"
		oCombo1   := TJurCmbBox():New(010,010,160,10,oDlg,aItemsCb,{|| Self:J162WhenCp(oCombo1:cValor,;
		                                                                              @oChkPag, @oChkAnd, @oChkGar, @oCbAndCli, @oCbAndUlt, @oCBIntDat,;
		                                                                              @lChkPag, @lCheck , @lChkGar, @cCbAndCli, @cCbAndUlt, @oTGetQtd, ;
		                                                                              @cCBIntDat,;
		                                                                              @oTGetDt1 , @oTGetDt2, @oChkDoc, @lChkDoc,;
		                                                                              @oTipImpr , @oCbTipImpr)})

		oChkPag   := TCheckBox():Create( oDlg,{|u|if( pcount()>0,lChkPag := u, lChkPag)},22,10,STR0017,100,10,,,,,,,,.T.,,,) // "Imprimir nº de Página"
		oChkAnd   := TCheckBox():Create( oDlg,{|u|if( pcount()>0,lCheck  := u, lCheck)} ,22,90,STR0018,100,10,,,,,,,,.T.,,,) // "Imprimir Andamentos"
		oChkGar   := TCheckBox():Create( oDlg,{|u|if( pcount()>0,lChkGar := u, lChkGar)},22,170,STR0019,100,10,,,,,,,,.T.,,,)// "Imprimir Garantias"
		oChkDoc   := TCheckBox():Create( oDlg,{|u|if( pcount()>0,lChkDoc := u, lChkDoc)},10,170,STR0020,100,10,,,,,,,,.T.,,,)// "Imprimir Documentos"

		oAndCli   := TSay():New(033,010,{||STR0021},oDlg,,,,,,.T.,,,100,10) //"Apenas Andamento p/ Cliente"
		oCbAndCli := TComboBox():New(42,10,{|u|if(PCount()>0,cCbAndCli:=u,cCbAndCli)},aItemsCl,70,10,oDlg,,{||},,,,.T.,,,,{|u|!('CLIENTES' $ cGrpRest) .AND. !u:lReadOnly},,,,,'cCbAndCli')

		If lAnoMes
			oVlrHist   := TSay():New(033,090,{||STR0022},oDlg,,,,,,.T.,,,100,10) //"Valores Históricos"
			oCbVlrHist := TComboBox():New(42,090,{|u|if(PCount()>0,cCbVlrHist:=u,cCbVlrHist)},aItems,70,10,oDlg,,{||},,,,.T.,,,,{|| lAnoMes},,,,,'cCbVlrHist')

			oTGetAnomes := TJurPnlCampo():New(033,170,70,20,oDlg,STR0023,"NYZ_ANOMES",{|| },{|| },) //"Ano-Mês Atualização:"
			oTGetAnomes:oCampo:bWhen := {|| lAnoMes .And. cCbVlrHist == STR0024 }//"Sim"
			oTGetAnomes:SetChange({|| cValAnoMes := oTGetAnomes:Valor, .T.})
		Else
			cCbVlrHist := STR0025 //"Não"
		EndIf

		oAndUlt   := TSay():New(55,010,{||STR0026},oDlg,,,,,,.T.,,,100,10) //"Os últimos x Andamentos"
		oCbAndUlt := TComboBox():New(64,010,{|u|if(PCount()>0,cCbAndUlt:=u,cCbAndUlt)},aItems,70,10,oDlg,,{||},,,,.T.,,,,{|u| !u:lReadOnly},,,,,'cCbAndUlt')


		oTGetQtd := TJurPnlCampo():New(55,90,70,20,oDlg,STR0027,"NQY_COD",{|| },{|| },) //"Quantidade"
		oTGetQtd:oCampo:bWhen := {|| cCbAndUlt == STR0024 } //'Sim'

		oIntDat   := TSay():New(77,010,{||STR0028},oDlg,,,,,,.T.,,,100,10)    //"Intervalo entre Datas"
		oCBIntDat := TComboBox():New(86,010,{|u|if(PCount()>0,cCBIntDat:=u,cCBIntDat)},aItems,70,10,oDlg,,{||},,,,.T.,,,,{|u| !u:lReadOnly},,,,,'cCBIntDat')

		oTipImpr  := TSay():New(55,170,{ || STR0056 },oDlg,,,,,,.T.,,,100,10)    //"Tipo de impressão"
		oCbTipImpr:= TComboBox():New(64,170,{|u|if(PCount()>0,cTipImpr:=u,cTipImpr)},aItemsImp,70,10,oDlg,,{||},,,,.T.,,,,{|u| !u:lReadOnly},,,,,'cTipImpr')

		oTGetDt1 := TJurPnlCampo():New(77,90,70,20,oDlg,STR0029,"NSZ_DTENTR",{|| },{|| },) //"Data Inicial"
		oTGetDt1:oCampo:bWhen := {|| cCBIntDat == STR0024 } //'Sim'

		oTGetDt2 := TJurPnlCampo():New(77,170,70,20,oDlg,STR0030,"NSZ_DTENTR",{|| },{|| },)	//"Data Final"
		oTGetDt2:oCampo:bWhen := {|| cCBIntDat == STR0024 } //'Sim'

		bAction := {||oDlg:SetFocus(),IIF (Self:vldRelat(cCbAndUlt, oTGetQtd:Valor, cCBIntDat, ;
		                                                 oTGetDt1:Valor, oTGetDt2:Valor, oCombo1:cValor),;
		                                  (Self:SetDftValue(lCheck, cCbAndCli, cCbAndUlt, oTGetQtd:Valor, ;
		                                                    cCBIntDat, oTGetDt1:Valor, oTGetDt2:Valor,;
		                                                    oLstFila, cUser, cThread, oCombo1:cValor, oDlg,;
		                                                    lChkPag, lChkGar, lChkDoc,cCbVlrHist, cValAnoMes,;
		                                                    cTipImpr),;
		                                   oDlg:End()),) }
	Endif

	Define SButton From 102, 215 Type 2 Enable Of oDlg Action oDlg:End()
	Define SButton From 102, 170 Type 1 Enable Of oDlg Action (Eval(bAction))
	ACTIVATE MSDIALOG oDlg CENTERED

	RestArea( aArea )
	NSZ->( RestArea( aAreaNSZ ) )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} VldRelat(cCbAndUlt, cTGetQtd, cCBIntDat, dTGetDt1,
                           dTGetDt2, cCfgRelat)
Função utilizada para validar a rotina de geração do relatório
Uso Geral.
@Param	cCbAndUlt Imprimir 'N' ultimos andamentos? S/N
@Param	cTGetQtd  Quantidade de andamentos
@Param	cCBIntDat Intervalo de datas
@Param	dTGetDt1  Data Inicial
@Param	dTGetDt2  Data Final
@Param	cCfgRelat Configuração do Relatório
@Return lRet
@author Clóvis Eduardo Teixeira
@since 22/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD VldRelat(cCbAndUlt, cTGetQtd, cCBIntDat, dTGetDt1, dTGetDt2, oCombo1) CLASS TJurPesqAsj
Local lRet := .T.

If Empty(oCombo1)
  JurMsgErro(STR0012) //"É necessário selecionar uma configuração para geração do relatório"
  lRet := .F.

ElseIf (cCbAndUlt == STR0024) .And. (AllTrim(cTGetQtd) == "") //'Sim'
  JurMsgErro(STR0031) //É necessário preencher a quantidade de andamentos
  lRet := .F.

ElseIf (cCBIntDat == STR0024) .And. (dToC(dTGetDt1) == '  /  /  ' .Or. dToC(dTGetDt2) == '  /  /  ') //'Sim'
  JurMsgErro(STR0032) //"É necessário preenhcer os dois campos do intervalos entre datas"
  lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} SetDftValue(lImpAnd, cCbAndCli, cCbAndUlt, cTGetQtd,
                              cCBIntDat, dTGetDt1, dTGetDt2, cUser,
                              cThread, oPanel, oPanelPai, cCfgRelat, oDlg, lChkPag, cTipImp)
Função para informar os parametros do relatório de processo
Uso Geral
@Param	lImpAnd   Imprimir Andamentos? S/N
@Param	cCbAndCli Apenas andamentos para cliente? S/N
@Param	cCbAndUlt Apenas os "x" ultimos andamentos S/N
@Param	cTGetQtd  Quantidade dos "x" ultimos andamentos
@Param	cCBIntDat Intervalo de Datas? S/N
@Param	dTGetDt1  Data Inicial
@Param	dTGetDt2  Data Final
@Param  cUser     Código Usuário
@Param  cThread   Codigo Sessão
@Param  oPanel    Objeto contendo o panel da fila de impressão
@Param  oPanelPai Objeto contendo o panel da pesquisa de processo
@Param  cCfgRelat Configuração do Relatório
@Param  oDlg      Caixa de Dialogo de Parametros
@Param  lChkPag   Imprimir Número de Página S/N
@Param  cCbVlrHist Imprimir Sub Valores históricos S/N
@Param  cAnomes   Ano-Mes referência informado

@Return Nil
@author Clóvis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetDftValue(lImpAnd, cCbAndCli, cCbAndUlt, cTGetQtd, ;
                   cCBIntDat, dTGetDt1, dTGetDt2,;
                   oLstFila, cUser, cThread, cCfgRelat, oDlg,;
                   lChkPag, lChkGar, lChkDoc,cCbVlrHist, cAnoMes,;
                   cTipImpr ) CLASS TJurPesqAsj

Local cImpAnd  := 'N'
Local cAndCli  := 'T'
Local cAndUlt  := 'N'
Local cQtdAnd  := '0'
Local cIntDat  := 'N'
Local cDtIni   := ''
Local cDtFim   := ''
Local lRet     := .T.
Local cImpPag  := 'N'
Local cImpGar  := 'N'
Local cRelat   := Alltrim(JurGetDados("NQY", 1, xFilial("NQY")+ SubStr(cCfgRelat,1,TAMSX3('NQY_COD')[1]), "NQY_CRPT"))
Local lDoc     := Alltrim(JurGetDados("NQR", 1, xFilial("NQR")+ SubStr(cRelat,1,TAMSX3('NQY_CRPT')[1]), "NQR_EXTENS")) == "2"
Local cImphist := 'N'
Local cChrTipImp := "W"
If lImpAnd
  cImpAnd := 'S'
Endif

If cCbAndCli == STR0024 //'Sim'
  cAndCli := 'S'
Elseif cCbAndCli == STR0025 //'Não'
  cAndCli := 'N'
Endif

if cCbAndUlt == STR0024 //'Sim'
  cAndUlt := 'S'
Endif

if AllTrim(cTGetQtd) == ""
  cQtdAnd := '0'
else
  cQtdAnd := AllTrim(cTGetQtd)
Endif

if cCBIntDat = STR0024 //'Sim'
  cIntDat := 'S'
Endif

if cCbVlrHist = STR0024 //'Sim'
  cImphist := 'S'
Endif

if dToC(dTGetDt1) == '  /  /    '
  cDtIni := '01/01/1900'
else
  cDtIni := DtoS(dTGetDt1)
  cDtIni := SubStr(cDtIni,7,2)+'/'+SubStr(cDtIni,5,2)+'/'+SubStr(cDtIni,1,4)
Endif

if dToC(dTGetDt2) == '  /  /    '
  cDtFim := '31/12/2050'
else
  cDtFim := DtoS(dTGetDt2)
  cDtFim := SubStr(cDtFim,7,2)+'/'+SubStr(cDtFim,5,2)+'/'+SubStr(cDtFim,1,4)
Endif

if lChkPag
  cImpPag := 'S'
endif

if lChkGar
  cImpGar := 'S'
Endif

// Verifica qual opção foi selecionada
If cTipImpr == STR0054
	cChrTipImp := "W"
Else
	cChrTipImp := "P"
EndIf

if lRet
	If lDoc //Relatório de arquivo tipo DOT
		Self:ImpRelDot(oLstFila, cCfgRelat, cRelat, lChkDoc, cChrTipImp)
	Else
		Self:ImpRep01(cUser, cThread, cImpAnd, cAndCli, cAndUlt, cQtdAnd, cIntDat,;
			cDtIni, cDtFim, cCfgRelat, oDlg, cImpPag, cImpGar,cImphist, cAnoMes)
	EndIf
Else
	JurMsgErro(STR0033) //"Erro ao gerar o relatório"
Endif


Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpRelDot(cUser, cThread, oLstFila, oPanel, oPanelPai,
                              cCfgRelat, cRelDot, lChkDoc, cTipImpr)

Função para impressão dos modelos de petição em arquivo DOT

Uso Geral

@Param cUser     Código do usuário
@Param cThread   Código da Thread
@Param oLstFila  Listbox da Fila de Impressão
@Param oPanel    Objeto contendo o panel da fila de impressão
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Param cCfgRelat Código do Relatório
@Param cRelDot   Relatório .DOT
@Param lChkDoc   Indica se haverá impressão
@Param cTipImpr  Tipo de impressão - Word ou PDF

@Return lRet	   Boolean

@author Jorge Luis Branco Martins Junior
@since 30/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ImpRelDot(oLstFila, cCfgRelat, cRelDot, lChkDoc, cChrTipImp) CLASS TJurPesqAsj
Local aArea     := GetArea()
Local lRet      := .T.
Local cArq      := ''
Local cPath	  	:= ''
Local lHtml    	:= (GetRemoteType() == 5) //Valida se o ambiente é SmartClientHtml
Local cFunction	:= "CpyS2TW"
Local cExtens	:= "" //"Arquivo DOC | *.doc| Arquivo PDF | *.pdf"
Local nI
Default cChrTipImp := "W"

If cChrTipImp == "W"
	cExtens := STR0057 //"Arquivo DOC | *.doc "
Else
	cExtens := STR0058 //"Arquivo PDF | *.pdf"
EndIf

For nI := 1 to Len(oLstFila:aCols)

	If !lHtml
		cPath := cGetFile(cExtens,STR0049,,'C:\',.F., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE) //"Salvar como"
		cArq  := ImpPeticao(cCfgRelat, Self:oFila:getCajuri(nI),, Self:oFila:getFilial(nI),cPath, cChrTipImp )

	//Gera via server
	Else
		cArq := J162StartBG(cCfgRelat,Self:oFila:getCajuri(nI),,.F.,Self:oFila:getFilial(nI), cChrTipImp) //chama para rodar no server
	EndIf

	If lHtml .And. FindFunction(cFunction) .And. !Empty(cArq)
		//Executa o download no navegador do cliente
		&(cFunction+'("' + cArq + '")')
	EndIf
Next

If !Empty(cArq)
	ApMsgInfo( I18n(STR0034, {cValToChar(Len(oLstFila:aCols))}) )	//"#1 documento(s) emitido(s)"
	Self:oFila:DelAllReg() //Limpa Fila de Impressão
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpRep01(cUser, cThread, cImpAnd, cAndCli, cAndUlt,
                           cAndQtd, cIntDat, cDtIni, cDtFim, oLstFila,
                           oPanel, oPanelPai, cCfgRelat, oDlg, cImpPag, cImpGar)
Função para impressão do relatório de processo
Uso Geral
@Param cUser     Código do usuário
@Param cThread   Código da Thread
@Param cImpAnd   Imprimir Andamentos S/N
@Param cAndCli   Apenas andamento para clientes S/N
@Param cAndUlt   Os ultimos N andamentos S/N
@Param cAndQtd   Qtd de andamentos
@Param cIntDat   Intervalo de Datas S/N
@Param cDtIni    Data Inicial
@Param cDtFim    Data Final
@Param oLstFila  Listbox da Fila de Impressão
@Param oPanel    Objeto contendo o panel da fila de impressão
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Param cCfgRelat Código do Relatório
@Param oDlg      Caixa de Dialogo
@Param cImpPag   Imprimir Número de Página S/N
@Param cImpHist   Imprimir histórico de Valores S/N
@Param cAnoMes   Ano-Mês Referência informado pelo usuário

@Return lRet	   Boolean
@author Clóvis Eduardo Teixeira
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ImpRep01(cUser, cThread, cImpAnd, cAndCli, cAndUlt,cAndQtd, cIntDat, cDtIni, cDtFim,cCfgRelat, oDlg, cImpPag,cImpGar, cImphist, cAnoMes) CLASS TJurPesqAsj
Local aArea     := GetArea()
Local cParams
Local cOptions  := "1;0;1;Relatório de Processo"
Local lRet      := .T.
Local cAliasNQ9 := GetNextAlias()
Local cAliasNQK := GetNextAlias()
Local cAliasNQR := GetNextAlias()
Local cParam
Local cCfgRel   := SubStr(cCfgRelat,1,3)
Local cRelat    := ''
Local cParPE    := '' //Ponto de entrada
Local aTab      := {}
Local cCfgJur   := ''
Local cAssJur   := JurGetDados("NSZ", 1, Self:oFila:getChaveItem() , "NSZ_TIPOAS")
Local cExtens   := ""
Local bRelat

If NQY->(FieldPos('NQY_CFGJUR')) > 0
	cCfgJur := JurGetDados("NQY", 1, xFilial("NQY") + cCfgRel, 'NQY_CFGJUR')
EndIf

cParams := cUser
cParams += ';' +cThread
cParams += ';' +cImpAnd
cParams += ';' +cAndCli
cParams += ';' +cAndUlt
cParams += ';' +cAndQtd
cParams += ';' +cIntDat
cParams += ';' +cDtIni
cParams += ';' +cDtFim
cParams += ';' +cImpPag
cParams += ';' +cImpGar

BeginSQL Alias cAliasNQR

  SELECT NQR_NOMRPT, NQR_EXTENS
    FROM %Table:NQR% NQR
   WHERE NQR_COD = (SELECT NQY_CRPT
                      FROM %Table:NQY% NQY
                     WHERE NQY_COD = %Exp:cCfgRel%
                       AND NQY.%notDel%)
     AND NQR.%notDel%

EndSQL
dbSelectArea(cAliasNQR)

cRelat := AllTrim((cAliasNQR)->NQR_NOMRPT)

cExtens := AllTrim((cAliasNQR)->NQR_EXTENS)

//Validação do parâmetro de filial que por enquanto só existe no JUR095.
If cRelat == "JUR095" .OR. cRelat == "JURR095"
	cParams += ';' +cFilAnt
	cParams += ';' +cImphist
	cParams += ';' +cAnoMes
Endif

If ExistBlock('J162PAR')
	cParPE := ExecBlock('J162PAR',.F.,.F.,{cRelat,cParams,cOptions})
	If ValType(cParPE) == 'C'
		cParams += AllTrim(cParPE)
	EndIf
	If Right(cParams,1) != ';'
		cParams += ';'
	EndIf
EndIf

BeginSQL Alias cAliasNQ9

	SELECT *
  	FROM %Table:NQ9% NQ9
	 WHERE NQ9_CODRPT = (SELECT NQY_CRPT
  	                     FROM %Table:NQY% NQY
    	                  WHERE NQY_COD = %Exp:cCfgRel%
    	                    AND NQY.%notDel%
    	                    AND NQY.NQY_FILIAL = %xFilial:NQY%)
     AND NQ9.%notDel%
     AND NQ9.NQ9_FILIAL = %xFilial:NQ9%
	ORDER BY NQ9_PARAM

EndSQL
dbSelectArea(cAliasNQ9)
(cAliasNQ9)->(DbgoTop())

BeginSQL Alias cAliasNQK

  SELECT *
    FROM %Table:NQK% NQK
   WHERE NQK_CCONF = %Exp:cCfgRel%
     AND NQK.NQK_FILIAL = %xFilial:NQK%
     AND NQK.%notDel%

EndSQL
dbSelectArea(cAliasNQK)

While !(cAliasNQ9)->(EOF())

	(cAliasNQK)->(DbgoTop())
	cParam := ''

	If NQ9->(FieldPos('NQ9_CCAMPO')) > 0 .and. cCfgJur = '1'
		cParam := Self:J162ObPar((cAliasNQ9)->NQ9_CCAMPO, cAssJur)
	EndIf

	If !(cAliasNQK)->(EOF())
		While !(cAliasNQK)->(EOF())

			If (cAliasNQ9)->NQ9_COD == (cAliasNQK)->NQK_CCAMPO


				If NQK_IMPRIM == '2'
					cParam := 'N'

				Else
					cParam := RTrim((cAliasNQK)->NQK_DISPLY)
				EndIf

			EndIf

			(cAliasNQK)->(dbSkip())
		End
	EndIf

	cParams += ';' + AllTrim(cParam)
	(cAliasNQ9)->(dbSkip())

End

cParams += ';'

(cAliasNQR)->(DbCloseArea())
(cAliasNQK)->(DbCloseArea())
(cAliasNQ9)->(DbCloseArea())

If cExtens == "3" //Verifica se o relatório tem extensão .PRW
	//JURR095(cAssJur,cUser, cThread,cParams)
	bRelat := &("{|cAssJur,cUser, cThread,cParams,cCfgRel| " + (cRelat) + "(cAssJur,cUser, cThread,cParams,cCfgRel)}")
	Eval(bRelat,cAssJur,cUser,cThread,cParams,cCfgRel) //Chamada do relatório PRW

Else
	JCallCrys(cRelat,cParams,cOptions,.T.,.T.,,aTab)//Chamada da função de impressão do relatório
EndIF
Self:oFila:DelAllReg() //Limpa Fila de Impressão

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} J162ObPar()
Função para obter parâmetro quando o controle dos campos a serem
exibidos no relatório depende da configuração de campos do assunto
jurídico

Uso Geral
@Param cCampo    Campo ser verificado
@Param cAssJur   Tipo de Assunto Jurídico

@Return cParam

@author Jorge Luis Branco Martins Junior
@since 10/12/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD J162ObPar(cCampo, cAssJur) CLASS TJurPesqAsj
Local aArea      := GetArea()
Local aAreaNUZ   := NUZ->( GetArea() )
Local cAssJurOri := ''
Local cParam     := ''
Local cTabCpo    := ''
Local cTabelas   := 'NSZ|NTA|NT4'
Local cTabSec    := 'NUQ|NT9|NYP|NXY|NYJ'

Default cCampo  := ''
Default cAssJur := ''

	If !Empty(cCampo) .And. !Empty(cAssJur)

		cTabCpo := SubStr(cCampo,1,3)

		If cTabCpo $ cTabelas .Or. cTabCpo $ cTabSec

			NYC->( dbSetOrder( 1 ) )

			If cTabCpo $ cTabelas .Or. ( cTabCpo $ cTabSec .And. (NYC->( dbSeek( xFilial( 'NYC' ) + cAssJur + PadR( cTabCpo, 10 ) ) ) ) )

				If cAssJur > '050'
					cAssJurOri := JurGetDados("NYB",1,XFILIAL("NYB")+cAssJur, "NYB_CORIG")
				EndIf

				NYD->( dbSetOrder( 1 ) )

				If (cAssJur > '050' .AND. (NYD->( dbSeek( xFilial( 'NYD' ) + cAssJur + PadR( cCampo, 10 ) ) ) ) )
					cParam := 'N'
				Else
					NUZ->( dbSetOrder( 1 ) )
					If ( !(X3Obrigat( PadR( cCampo, 10 ) ) ) )
						If !( cAssJur > '050' .AND. NUZ->( dbSeek( xFilial( 'NUZ' ) + cAssJurOri + PadR( cCampo, 10 ) ) ) )
							If !( NUZ->( dbSeek( xFilial( 'NUZ' ) + cAssJur + PadR( cCampo, 10 ) ) ) )
								cParam := 'N'
							Else
								cParam := NUZ->NUZ_DESCPO
							EndIf
						Else
							cParam := NUZ->NUZ_DESCPO
						EndIf
					EndIf
				EndIf

			Else
				cParam := 'N'
			EndIf

		EndIf

	EndIf

RestArea( aAreaNUZ )
RestArea( aArea )

Return cParam

//-------------------------------------------------------------------
/*/{Protheus.doc} J162WhenCp()
Função utilizada para habilitar e desabilitar opções da fila de
impressão quando o tipo de relatório for DOT
Uso Geral.

@author Jorge Luis Branco Martins Junior
@since 29/01/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD J162WhenCp(cConf,;
                  oChkPag, oChkAnd, oChkGar, oCbAndCli, oCbAndUlt, oCBIntDat,;
                  lChkPag, lCheck , lChkGar, cCbAndCli, cCbAndUlt, oTGetQtd, ;
                  cCBIntDat, ;
                  oTGetDt1, oTGetDt2, oChkDoc, lChkDoc,;
                  oTipImpr, oCbTipImpr) CLASS TJurPesqAsj

Local cRelat := Alltrim(JurGetDados("NQY", 1, xFilial("NQY")+ SubStr(cConf,1,TAMSX3('NQY_COD')[1]), "NQY_CRPT"))
Local lExt   := Alltrim(JurGetDados("NQR", 1, xFilial("NQR")+ SubStr(cRelat,1,TAMSX3('NQY_CRPT')[1]), "NQR_EXTENS")) == "2"

oChkPag:lReadOnly   := lExt
oChkPag:lVisibleControl  := !lExt

oChkAnd:lReadOnly   := lExt
oChkAnd:lVisibleControl  := !lExt

oChkGar:lReadOnly   := lExt
oChkGar:lVisibleControl  := !lExt

oCbAndCli:lReadOnly := lExt
oCbAndUlt:lReadOnly := lExt
oCBIntDat:lReadOnly := lExt

oChkDoc:lReadOnly   := !lExt
oChkDoc:lVisibleControl  := lExt

If lExt
	lChkPag        := .T.
	lCheck         := .T.
	lChkGar        := .T.
	cCbAndCli      := STR0037 //"Todos"
	cCbAndUlt      := STR0025 //"Não"
	oTGetQtd:Valor := AvKey("","NQY_COD")
	cCBIntDat      := STR0025 //"Não"
	oTGetDt1:Valor := CToD("")
	oTGetDt2:Valor := CToD("")
Else
	lChkDoc        := .F.
EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} OpAltLote

Função que faz a alteração em lote da tabela principal da pesquisa usando os campos

@param		aCampos

@author	André Spirigoni Pinto
@since		09/02/2015
/*/
//---------------------------------------------------------------------------
METHOD OpAltLote(aCampos, aCampDe) CLASS TJurPesqAsj
Local aArea     := GetArea()
Local cAlote    := GetNextAlias()
Local cSQL      := Self:MontaSQL()
Local aAltera   := {}
Local oModel095 := Nil
Local oNSZ      := Nil
Local cCampo    := ""
Local nI        := 0
Local nC        := 0
Local nQtd      := 0
Local aErro     := {}
Local cMsg      := ""
Local cJurProc  := ""
Local nTotalRegs:= 0
Local xValor    := Nil
Local oModelNUV := Nil
Local nPosMotiv := 0
Local nPosJustif:= 0
Local nPosCCorr := 0
Local oNUQ      := Nil
Local cFilBkp   := cFilAnt
Local nCnt      := 0
Local cMotivoCor:= ""

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlote, .T., .F.)

//Preenche o array com os registros que serão alterados
While (cAlote)->(!Eof())
	aAdd(aAltera,{(cAlote)->NSZ_FILIAL,(cAlote)->NSZ_COD})
	(cAlote)->(dbSkip())
End
(cAlote)->( dbcloseArea() )

nTotalRegs := Len(aAltera)
ProcRegua(0)	//Para ficar com a regua continua, para atualizar a tela mais rapido

//Verifica se é algum dos campos virtuais de SIGLA e troca pelo CODIGO do participante, porque a partir de uma grande
//quantidade de registros (1000), o sistema se perdia e dava mensagem de erro nos gatilhos NSZ_SIGLAx ou NSZ_CPARTx
For nC := 1 to len(aCampos)

	cCampo := AllTrim( aCampos[nC]:cNomeCampo )
	xValor := aCampos[nC]:Valor

	If (cCampo == "NSZ_SIGLA1" .Or. cCampo == "NSZ_SIGLA2" .Or. cCampo == "NSZ_SIGLA3") .And. !Empty(xValor)

		cCampo  := StrTran(cCampo, "NSZ_SIGLA", "NSZ_CPART")
		xValor  := JurGetDados("RD0", 9, xFilial("RD0") + xValor, "RD0_CODIGO")

		aCampos[nC]:cNomeCampo := cCampo
		aCampos[nC]:Valor      := xValor
	EndIf
Next

DbSelectArea("NSZ")
NSZ->(DBSetOrder(1))

For nI := 1 to nTotalRegs

	If lAbortPrint
		Exit
	EndIf

	If NSZ->(dbSeek(aAltera[nI][1] + aAltera[nI][2]))

		//Seta variáveis estáticas
		c162TipoAs := NSZ->NSZ_TIPOAS
		cTipoAsJ   := NSZ->NSZ_TIPOAS
		
		If !Empty(aAltera[nI][1])//se estiver em branco mantém a filial logada
			cFilAnt := aAltera[nI][1]
		EndIf

		//Destroy o model e carrega novamente
		If (cJurProc != c162TipoAs)

			Self:Destroy( @oModel095 )
			cJurProc  := c162TipoAs
			oModel095 := FWLoadModel( 'JURA095' )
		Endif

		lPesquisa := .F.

		oModel095:SetOperation( 4 )
		oModel095:Activate()

		INCLUI := .F.
		ALTERA := .T.

		//Seta as propriedade porque quando era aberto outro view, no proximo registros elas não eram atualizadas, mesmo dando um Activate()
		oModel095:lModify := .T.
		oModel095:lValid  := .F.

		oNSZ := oModel095:GetModel( 'NSZMASTER' )

		//Valida se o modelo está no mesmo registro
		If (oNSZ:GetValue("NSZ_FILIAL") == aAltera[nI][1] .And. oNSZ:GetValue("NSZ_COD") == aAltera[nI][2])
			For nC := 1 to len(aCampos)
				cCampo := aCampos[nC]:cNomeCampo
				If !Empty(aCampos[nC]:Valor) //valida se o valor foi preenchido
					If LEFT(cCampo,3) == "NSZ"
						oNSZ:SetValue(cCampo,aCampos[nC]:Valor) //seta o valor novo
					ElseIf LEFT(cCampo,3) == "NUQ"
						oNUQ := oModel095:GetModel('NUQDETAIL')
						For nCnt := 1 To oNUQ:Length()
							oNUQ:GoLine(nCnt)
							If oNUQ:GetValue("NUQ_INSATU", nCnt) == '1'
								oNUQ:SetValue(cCampo,aCampos[nC]:Valor)
							EndIf
						Next
					Else
						Exit
					EndIf
				Endif
			Next
		Endif

		If ( lRet := oModel095:VldData() )

			nPosMotiv    := aScan(aCampos, {|ax| ax:cNomeCampo == "NUV_CMOTIV" } )
			nPosJustif   := aScan(aCampos, {|ax| ax:cNomeCampo == "NUV_JUSTIF" } )
			nPosCCorr    := aScan(aCampos, {|ax| ax:cNomeCampo == "NUQ_CCORRE" } )

			If nPosMotiv > 0 .AND. nPosJustif > 0 	//valida se os campos estão na tela
				If Empty(aCampos[nPosMotiv]:Valor) .OR. Empty(aCampos[nPosJustif]:Valor) .OR. Empty(JurGetDados("NQX", 1, xFilial("NQX") + aCampos[nPosMotiv]:Valor, "NQX_COD"))

					lRet := .F.
					ApMsgInfo (STR0053) //"Verifique os campos de motivo e Justificativa"

				Else

					oModelNUV := FWLoadModel( 'JURA166' )
					oModelNUV:SetOperation( 3 )
					oModelNUV:Activate()

					oModelNUV:SetValue("NUVMASTER","NUV_FILIAL",oNSZ:GetValue("NSZ_FILIAL") )
					oModelNUV:SetValue("NUVMASTER","NUV_CAJURI",oNSZ:GetValue("NSZ_COD"))
					oModelNUV:SetValue("NUVMASTER","NUV_CMOTIV",aCampos[nPosMotiv]:Valor)
					oModelNUV:SetValue("NUVMASTER","NUV_JUSTIF",aCampos[nPosJustif]:Valor)

					If ( lRet := oModelNUV:VldData() )
						oModelNUV:CommitData()
					EndIf

					oModelNUV:Deactivate()
					Self:Destroy( oModelNUV )

					//Volta o Jura095 como modelo ativo
					oModel095:Activate() 
				EndIf
			Endif
			//Historico de correspondente
			If nPosCCorr > 0 .And. !Empty(aCampos[nPosCCorr]:Valor) 
				If oNUQ:IsFieldUpdate('NUQ_CCORRE') //valida se o campo esta na tela
					If !Empty(aCampos[nPosCCorr]:Valor) .And. Empty(cMotivoCor)
						//Chama a tela com o motivo da alteração de correspondente
						cMotivoCor := Self:getTelaExtr("NUQ_CCORRE")
						//Se não informou a justificativa, passa para o proximo e pede novamente a informação
						If Empty(cMotivoCor)
							lRet := .F.
						EndIf
					EndIf
	
					If !Empty(cMotivoCor)
						lRet := JCall093(oNSZ, oNUQ, cMotivoCor, Self)
						oModel095:Activate() 
					EndIf
				EndIf
			EndIf
			If lRet
				lRet := oModel095:CommitData()
			EndIf

			If lRet
				MsUnLockAll()
				nQtd := nQtd + 1
			EndIf
		Else
			aErro := oModel095:GetErrorMessage()

			cMsg  := AllToChar( aErro[6] ) + CRLF //"Mensagem do erro: "

			Alert( STR0040 + cMsg ) //"Erro na alteração em lote: "

			If ApMsgYesNo(STR0041) //"Deseja continuar a alteração de forma manual?"
				If (Self:JurProc(aAltera[nI][1],aAltera[nI][2],,4,10,oModel095))
					nQtd++
				EndIf

				//Inicializa variavel para carregar novamente o model
				cJurProc := ""
			endif

		EndIf

		oModel095:DeActivate()

		IncProc( I18N(STR0038, {cValToChar(nI), cValToChar(nTotalRegs)}) ) //"Processando registro #1 de #2"
	Endif
Next

cFilAnt  := cFilBkp
//Destroy objeto
Self:Destroy( @oModel095 )

ApMsgInfo(I18N(STR0039,{AllTrim(str(nQtd))})) //"#1 Registro(s) alterado(s)."

lAbortPrint := .F.
aSize(aAltera,0) //limpra o array

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SelModel(cTipoAj)
Função utilizada para selecionar um modelo para inclusão de processos
Uso Geral.
@param cTipoAj Tipo de assunto juridico selecionado pelo usuario (entre os que ele esta autorizado a utilizar).
@author Wellington Coelho
@since 11/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SelModel(cTipoAj) CLASS TJurPesqAsj
Local aArea     := GetArea()
Local cIdBrowse := ''
Local cIdRodape := ''
Local cModelo   := ''
Local oBrowse//, oColumn
Local oDlgTpAS, oTela
Local oPnlBrw, oPnlRoda
Local oBtnOk, oBtnCancel

Define MsDialog oDlgTpAS FROM 0, 0 To 400, 800 Title STR0042 Pixel style DS_MODALFRAME //"Selecione o modelo

oTela     := FWFormContainer():New( oDlgTpAS )
cIdBrowse := oTela:CreateHorizontalBox( 84 )
cIdRodape := oTela:CreateHorizontalBox( 16 )
oTela:Activate( oDlgTpAS, .F. )
oPnlBrw   := oTela:GeTPanel( cIdBrowse )
oPnlRoda  := oTela:GeTPanel( cIdRodape )

//-------------------------------------------------------------------
// Define o Browse
//-------------------------------------------------------------------
oBrowse := FWMBrowse():New()
oBrowse:SetOwner( oPnlBrw )
oBrowse:SetMenuDef( '' )
oBrowse:ForceQuitButton()
oBrowse:SetAlias("NZ3")
oBrowse:SetDescription('') 		//"Selecione o modelo
//Adiciona um filtro ao browse
oBrowse:SetFilterDefault( "NZ3_TIPOAS = '"+cTipoAj+"' .AND. NZ3_TIPO = '1'"	)
//Seta o duplo clique
oBrowse:SetDoubleClick( {||cModelo := AllTrim(NZ3->NZ3_COD),oDlgTpAS:End()} )
//Desliga a exibição dos detalhes
oBrowse:DisableDetails()
oBrowse:Activate()

	//Botão Ok
@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 21 Button oBtnOk  Prompt STR0043 ;
	Size 25 , 12 Of oPnlRoda Pixel Action ( cModelo := AllTrim( NZ3->NZ3_COD ), oDlgTpAS:End())

	//Botão Cancelar
@ oPnlRoda:nTop + 05, oPnlRoda:nLeft + 73 Button oBtnCancel Prompt STR0044;
	Size 25 , 12 Of oPnlRoda Pixel Action ( cModelo := "", oDlgTpAS:End() )

	//-------------------------------------------------------------------
	// Ativação do janela
	//-------------------------------------------------------------------

Activate MsDialog oDlgTpAS Centered

RestArea(aArea)

Return cModelo
//-------------------------------------------------------------------
/*/{Protheus.doc} J162IncMod(oModel, cCodMod)
Função para incluir um processo com as informações do modelo selecionado

Uso Geral
@Param oModel  Modelo de dados
@Param cCodMod  Codigo do modelo para inclusão de
@Return
@author Wellington Coelho
@since 09/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD J162IncMod(oModel, cCodMod) CLASS TJurPesqAsj
Local aArea     := GetArea()
Local aAreaNZ4  := NZ4->( GetArea() )
Local dValor
Local oStructNXX := Nil
Local lUpd
Local ni		:= 0
Local nj		:= 0
Local aDetail	:= {}
Local aModelos	:= oModel:GetModelIds()

DbSelectArea("NZ4")
NZ4->(DbSetOrder(1))
if NZ4->(dbSeek(xFilial('NZ4')+cCodMod))
	
	While NZ4->(!Eof()) .And. NZ4->NZ4_CMOD == cCodMod .And. NZ4->NZ4_FILIAL == xFilial('NZ4')
		//Verifica se o ID do modelo existe
		If !( Ascan(aModelos, {|x| AllTrim(x) == AllTrim(NZ4->NZ4_NOMEMD)  } ) > 0 )
			NZ4->( DbSkip() )
			Loop
		EndIf

		dValor := Alltrim(NZ4->NZ4_VALORC)
		If NZ4->NZ4_TIPO == "D"
			dValor := CTOD(Alltrim(dValor))
		EndIf
		If NZ4->NZ4_TIPO == "N"
			dValor := Val(Alltrim(dValor))
		EndIf

		lGrid    := (AllTrim(NZ4->NZ4_NOMEMD) $ "NT9DETAIL/NUQDETAIL/NYJDETAIL/NXYDETAIL/NYPDETAIL")

		If !lGrid
			oStructNXX := oModel:GetModel(AllTrim(NZ4->NZ4_NOMEMD)):GetStruct()
			lUpd := oStructNXX:GetProperty(Alltrim(NZ4->NZ4_NOMEC), MODEL_FIELD_NOUPD)//Verifica os campos que não podem ser editados

			If !lUpd
				oModel:SetValue(AllTrim(NZ4->NZ4_NOMEMD),AllTrim(NZ4->NZ4_NOMEC), dValor)
			Endif

			NZ4->(dbSkip())

		Else

			cModelGrv 	:= NZ4->NZ4_NOMEMD
			cItem 		:= NZ4->NZ4_ITEM
			aAux		:= {}
			aDetail		:= {}
 			While NZ4->(!Eof()) .And. NZ4->NZ4_CMOD == cCodMod .And. NZ4->NZ4_FILIAL == xFilial('NZ4') .And. AllTrim(NZ4->NZ4_NOMEMD) == AllTrim(cModelGrv)

				dValor := Alltrim(NZ4->NZ4_VALORC)
				If NZ4->NZ4_TIPO == "D"
					dValor := CTOD(Alltrim(dValor))
				EndIf
				If NZ4->NZ4_TIPO == "N"
					dValor := Val(Alltrim(dValor))
				EndIf

				If cItem == NZ4->NZ4_ITEM
					aAdd( aAux, { AllTrim(NZ4->NZ4_NOMEC), dValor } )
				Else
					aAdd(aDetail, aAux)
					aAux := {}
					cItem := NZ4->NZ4_ITEM
					aAdd( aAux, { AllTrim(NZ4->NZ4_NOMEC), dValor } )
				EndIf

				NZ4->(dbSkip())
			EndDo
			aAdd(aDetail, aAux)

			oStructNXX 	:= oModel:GetModel(AllTrim(cModelGrv)):GetStruct()
			aAux	 	:= oStructNXX:GetFields()

			For nI := 1 To Len( aDetail )

				If oModel:GetModel(AllTrim(cModelGrv)):GetQtdLine() > 1 .Or. !( oModel:GetModel(AllTrim(cModelGrv)):IsEmpty(1) )
					oModel:GetModel(AllTrim(cModelGrv)):AddLine()
				EndIf

				For nJ := 1 To Len( aDetail[nI] )

					lUpd := oStructNXX:GetProperty(Alltrim(aDetail[nI][nJ][1]), MODEL_FIELD_NOUPD)//Verifica os campos que não podem ser editados

					If !lUpd
						oModel:SetValue(AllTrim(cModelGrv),aDetail[nI][nJ][1], aDetail[nI][nJ][2])
					Endif

				Next

			Next

		EndIf

	EndDo

	//Grava o codigo do modelo no processo
	oModel:SetValue("NSZMASTER","NSZ__CMOD",cCodMod)

EndIf

RestArea(aArea)
RestArea(aAreaNZ4)

aSize(aModelos,0)

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} J162ExcMod(cCodMod)
Função para excluir um modelo
Uso Geral
@Param cCodMod  Codigo do modelo para inclusão de
@Return
@author Wellington Coelho
@since 20/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD J162ExcMod(cCodMod) CLASS TJurPesqAsj
Local aArea    := GetArea()
Local aAreaNZ3 := NZ3->( GetArea() )
Local aAreaNZ4 := NZ4->( GetArea() )

DbSelectArea("NZ3")
NZ3->(DbSetOrder(1))
If NZ3->(dbSeek(xFilial('NZ3')+cCodMod))
	Reclock( "NZ3", .F. )
	dbDelete()
	MsUnLock()
EndIf

DbSelectArea("NZ4")
NZ4->(DbSetOrder(1))
If NZ4->(dbSeek(xFilial("NZ4")+cCodMod))
	While NZ4->(!Eof()) .And. NZ4->NZ4_CMOD == cCodMod .And. NZ4->NZ4_FILIAL == xFilial("NZ4")
		Reclock( "NZ4", .F. )
		dbDelete()
		MsUnLock()
		NZ4->(DbSkip())
	End
EndIf

RestArea(aArea)
RestArea(aAreaNZ3)
RestArea(aAreaNZ4)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J162SelMod()
Função para selecionar o modelo que será excluido

Uso Geral
@Return
@author Wellington Coelho
@since 20/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD J162SelMod() CLASS TJurPesqAsj
Local cTipoAJ  := JurSetTAS(.T.) // Retorna os assuntos juridicos permitidos para o usuario
Local cCodMod  := Self:SelModel(cTipoAJ) // Retorna o modelo selecionado

If !Empty(cCodMod)
	Self:J162ExcMod(cCodMod) // Exclui o modelo
	Return ApMsgInfo(STR0045) //"Modelo excluido com sucesso!"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} dblClickBrw()
Função para selecionar o modelo que será excluido

Uso Geral
@Return
@author Wellington Coelho
@since 20/02/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD dblClickBrw() CLASS TJurPesqAsj
Local aRelacio := {{"1","NSZ_QTINCI"}, {"2","NSZ_QTVINC"},{"3","NSZ_QTRELA"}}
Local nTemp
Local lAltPro  := (SuperGetMV('MV_JALTPRO',, '1') == '2') //parametro que Define de o duploclik no grid da tela de Assunto Juridico (1=irá chamar a função para Alterar ou 2= Continuará chamando para Visualizar)

If !LEN(Self:oLstPesq:aCols) == NIL
	If Self:oLstPesq:oBrowse:ColPos() == 1 //valida se deve ser exibida a legenda
		Self:MostraLegenda(Self:oLstPesq)
	Else
		nTemp := aScan(aRelacio,{|x| Self:getPosCmp(x[2]) == Self:oLstPesq:oBrowse:ColPos()})
		If nTemp > 0
			MsgRun(STR0009,STR0010,{|| JA095Tela(Self:getFilial(), Self:getCodigo(), aRelacio[nTemp][1], Self:JA162Assjur("NSZ_TIPOAS"),4)}) //"Carregando..." e "Pesquisa de Processos"
		ElseIf (Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ') .Or. Empty(Self:cGrpRest)
			If lAltPro .And. JA162AcRst('14', 2)
				Self:JA162Menu(1,Self:oLstPesq,,Self:oCmbConfig)
			ElseIf JA162AcRst('14', 4)
				Self:JA162Menu(4,Self:oLstPesq,,Self:oCmbConfig)
			Endif
		Endif
	Endif
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} J162RelDot
Rotina que emite relatório .DOT

@author Jorge Luis Branco Martins Junior
@since 03/02/14
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD J162RelDot(cRelat, aTxt, aVar, nCont, cPath, lChkDoc) CLASS TJurPesqAsj
Local oWord
Local nI := 0
Local cExtens  := "Arquivo DOC | *.doc"
Local cCliente := JurGetDados("NSZ",1,Self:oFila:getChaveItem(nCont), "NSZ_CCLIEN")
Local cLoja    := JurGetDados("NSZ",1,Self:oFila:getChaveItem(nCont), "NSZ_LCLIEN")
Local cCaso    := JurGetDados("NSZ",1,Self:oFila:getChaveItem(nCont), "NSZ_NUMCAS")
Local cArq     := ""
Local cFileDot
Local cTempPath
Local cFileDotTmp

Default cPath := ""

If Empty(AllTrim(cPath))
	cArq := cGetFile(cExtens,STR0049,,'C:\',.F., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE) //"Salvar como"
Else
	cArq := cPath
EndIf

If !Empty(AllTrim(cArq))

	cFileDot := GetSrvProfString("StartPath", "\undefined") + ALLTRIM(cRelat) +'.dot'

	If !File( cFileDot )

		cFileDot := GetSrvProfString("StartPath", "\undefined") + ALLTRIM(cRelat) +'.dotx'

		If !File( cFileDot )
			ApMsgAlert( STR0050, 'xxx' ) //"Modelo de integração com MS-Word (.DOT / .DOTX) não encontrado."
			Return NIL
		Endif

	EndIf

	// Joga o .DOT para o diretorio TEMP da maquina do usuario para executar
	cTempPath := GetTempPath()
	cTempPath += IIf( Right( AllTrim( cTempPath ) , 1 ) <> '\' , '\', '' )

	cFileDotTmp := cTempPath + ExtractFile( cFileDot )

	If File( cFileDotTmp )
		If FErase( cFileDotTmp ) < 0
			ApMsgAlert( STR0051, 'xxx' ) //"Não foi possível deletar o arquivo de modelo do MS-Word (.DOT) da pasta temporária "
			Return NIL
		EndIf
	EndIf

	If !CpyS2T( cFileDot, cTempPath )
		ApMsgAlert( STR0052, 'xxx' ) //"Não foi possível transferir para pasta temporária o arquivo de modelo do MS-Word (.DOT)"
		Return NIL
	EndIf

	If oWord <> NIL
		If SubStr( Trim( oApp:cVersion ) , 1, 3 ) == 'MP8'
			OLE_CloseLink( oWord , .F. )
		Else
			OLE_CloseLink( oWord )
		EndIf
	EndIf

	oWord := OLE_CreateLink( 'TMsOleWord97' )

	//Abre o arquivo e ajusta as suas propriedades
	OLE_NewFile( oWord, cFileDotTmp )
	//OLE_SetProperty( oWord, oleWdVisible,   .F. )
	OLE_SetProperty( oWord, oleWdPrintBack, .T. )

	For nI := 1 to Len(aTxt)
		If Self:oFila:getCajuri(nCont) == aTxt[nI][3]
			OLE_SetDocumentVar( oWord, aTxt[nI][1], aTxt[nI][2] )
		EndIf
	Next
	For nI := 1 to Len(aVar)
		If Self:oFila:getCajuri(nCont) == aVar[nI][3]
			OLE_SetDocumentVar( oWord, aVar[nI][1], aVar[nI][2] )
		EndIf
	Next
	OLE_UpdateFields(oWord)

	If lChkDoc
		OLE_PrintFile( oWord, "ALL",,, 1 )
	EndIf

	OLE_SaveAsFile ( oWord, cArq+cRelat+"_"+cCliente+"_"+cLoja+"_"+cCaso+"_"+Self:oFila:getCajuri(nCont)+".doc" )

	OLE_CloseFile( oWord )
	OLE_CloseLink( oWord )

EndIf

Return cArq

//---------------------------------------------------------------------------
/*/{Protheus.doc} getComplLote

Função que retorna campos que contenham campos complementares de tabelas que devem aparecer na alteração em lote

@author	André Lago
@since		04/05/2015
/*/
//---------------------------------------------------------------------------
METHOD getComplLote() CLASS TJurPesqAsj
Local aRet := {}
aAdd(aRet,{"NSZ_SITUAC",{"NSZ_CMOENC","NSZ_DETENC","NUV_CMOTIV","NUV_JUSTIF"},{52,150,52,150},{22,60,22,60}})

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} getMoreRows

Função que retorna mais linhas para o grid de pesquisa, caso ele esteja paginado.
Este método precisa ter este nome para ser invocado da classe TJurPesquisa.

@author	André Spirigoni Pinto
@since		23/06/2016
/*/
//---------------------------------------------------------------------------
METHOD getMoreRows(nQtd) CLASS TJurPesqAsj
Local aCol		:= aClone(Self:oLstPesq:aCols)
Local aArea     := GetArea()
Local nDone		:= 0
Local nCols		:= len(aCol)
Local nX		:= 0
Local cTpPai	:= "" //Variável auxiliar que guarda o assunto pai do processo da fila
Local cTpAs		:= "" //Variável auxiliar que guarda o assunto do processo da fila
Local aHead     := Self:oLstPesq:getHeader()
Local nAtBkp	:= Self:oLstPesq:nAt //backup da posição do registro atual
Local nColBkp	:= 0

Default nQtd := 0

dbSelectArea(Self:cAlQry)
(Self:cAlQry)->(dbGoTop())

//movimenta a té a última linha posicionada.
While (Self:cAlQry)->(!Eof()) .And. (Self:cAlQry)->NSZ_COD !=  Self:cCurRec
	(Self:cAlQry)->(dbSkip())
End

While (Self:cAlQry)->(!Eof()) .And. (nQtd == 0 .Or. nDone <= nQtd)

	aAdd(aCol,Array(LEN(aHead)+4))
	nCols++
	nDone++

	//usado na legenda. Por questões de performance, pesquisa assuntos pais o mínimo de vezes possível.
	if (cTpAs != (Self:cAlQry)->NSZ_TIPOAS)
		cTpAs := (Self:cAlQry)->NSZ_TIPOAS
		If cTpAs > '050'
			cTpPai := J162PaiAJur(cTpAs)
		Else
			cTpPai := ""
		EndIf
	Endif


	For nX := 1 To LEN(aHead)

		If nX == 1
			aCol[nCols][nX] := Self:GetLegenda(IIF(Empty(cTpPai),cTpAs,cTpPai))
		Elseif (aHead[nX][10] != "V") //Valida se não é um campo virtual para evitar um fieldget/fieldpos
			aCol[nCols][nX] := (Self:cAlQry)->(FieldGet(FieldPos(aHead[nX][2])))
		EndIf

	Next nX

	aCol[nCols][LEN(aHead)+1] := (Self:cAlQry)->NSZ_COD
	aCol[nCols][LEN(aHead)+2] := (Self:cAlQry)->NSZ_FILIAL
	aCol[nCols][LEN(aHead)+3] := (Self:cAlQry)->NSZ_TIPOAS
	aCol[nCols][LEN(aHead)+4] := .F.

	(Self:cAlQry)->(dbSkip())
End

//valida se não foi retornado todas as linhas e apenas uma quantidade.
if (nQtd > 0)
	Self:cCurRec	:= (Self:cAlQry)->NSZ_COD
Else
	//não existem mais linhas a serem retornadas.
	(Self:cAlQry)->( dbcloseArea() )
	Self:cCurRec	:= ""
	Self:oLstPesq:clearPaginacao()
Endif

//Atualiza o grid
nColBkp := Self:oLstPesq:colPos() //backup da coluna do registro atual
Self:oLstPesq:SetArray(aCol)
Self:oLstPesq:nAt := nAtBkp //volta o grid
Self:oLstPesq:GoColumn(nColBkp)

RestArea( aArea )

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} gOnMove

Método obrigatório para paginação do grid. Ele que vai receber as notificações
da classe TJURBROWSE

@param nLinha Posição da linha selecionada no grid
@param lEnd Indica se o usuário solicitou que fosse para o final do grid

@author	André Spirigoni Pinto
@since		23/06/2016
/*/
//---------------------------------------------------------------------------
METHOD gOnMove(nLinha,lEnd) CLASS TJurPesqAsj
Local nPercen := 0
Local nPasso := 0
Local lCont := .F. //determina se mais linhsa devem ser solicitadas do banco para o grid

if !Empty(Self:cCurRec) //valida se o grid está paginado
	if lEnd
		nPasso := 0
		lCont := .T.
	Else
		nPercen := (nLinha * 100) / (Self:nPagDados * Self:nMaxQry)

		if (nPercen >= 80) //se a moveimentação estiver em mais de 80% das linhas visíveis, carrega mais dados.
			nPasso := Self:nMaxQry
			Self:nPagDados++
			lCont := .T.
		Endif
	Endif

	if lCont //carrega nais linhas do alias para o grid.
		MsgRun(STR0009,STR0010,{|| Self:getMoreRows(nPasso) }) //"Carregando..."
	Endif
Endif

Return Nil
//---------------------------------------------------------------------------
/*/{Protheus.doc} getExcecaoLote

Função que retorna campos de tabelas que devem aparecer na alteração em lote

@Return  aCampos Array de campos que sao exceção

@author  Breno Gomes
@since   04/05/2018
/*/
//---------------------------------------------------------------------------
METHOD getExcecaoLote() CLASS TJurPesqAsj
Local aCampos := {}
Local nI      := 0
	For nI := 1 to Len(Self:aObj)
		If Self:aObj[nI]:cNomeCampo == 'NUQ_ANDAUT'//O campo só será adicionado se estiver preenchido
			If !Empty(Self:aObj[nI]:Valor)
				aCampos := {"NUQ_ANDAUT"}
			EndIf
		EndIf
		If Self:aObj[nI]:cNomeCampo == 'NUQ_CCORRE'//O campo só será adicionado se estiver preenchido
			If !Empty(Self:aObj[nI]:Valor)
				aADD(aCampos,"NUQ_CCORRE")
				aADD(aCampos,"NUQ_LCORRE")
			EndIf
		EndIf
	Next
Return aCampos

//---------------------------------------------------------------------------
/*/{Protheus.doc} getComplExc

Função que retorna campos complementares que contenham campos em excecao de tabelas que devem aparecer na alteração em lote

@Return  aRet Array de campos que sao complementares de campos da exceção

@author  Breno Gomes
@since   27/12/2019
/*/
//---------------------------------------------------------------------------
METHOD getComplExc() CLASS TJurPesqAsj
Local aRet := {}

aAdd(aRet,{"NUQ_CCORRE",{"NTC_MOTIVO"},{150},{60}})

Return aRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} getTelaExtr

Abre tela com campo complementar diferente diferente dos campos de motivo de encerramento

@Return  lRet

@author  Breno Gomes
@since   30/12/2019
/*/
//---------------------------------------------------------------------------
METHOD getTelaExtr(cCampo) CLASS TJurPesqAsj
Local oDlg := Nil
Local oPanel    := Nil
Local oPnlCpos  := Nil
Local oSplPesq  := Nil
Local oPnlScr   := Nil
Local oPnlRod   := Nil
Local cStyle    := "QFrame{ background-color:#FFFFFF }"
Local aComplExc := Self:getComplExc()
Local aObjAux   := {}
Local nX, nCpl  := 0
Local aCampDe   := {}
Local cRet      := ""
	

	oDlg := MSDialog():New(0,0,245,345,STR0060,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //"Histórico de correspondente"

	oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlg, .F., .F.)

	// Painel central
	oFWLayer:AddLine('ACIMA', 65, .F. )
	oFWLayer:AddCollumn('ALL' , 100, .T., 'ACIMA')
	oPanel          := oFWLayer:GetColPanel('ALL' , 'ACIMA')
	oPanel:Align    := CONTROL_ALIGN_ALLCLIENT
	oPanel:nCLRPANE := RGB(255,255,255)

	oPnlCpos          := tPanel():New(0,0,'',oPanel,,,,,,60,15)
	oPnlCpos:Align    := CONTROL_ALIGN_TOP
	oPnlCpos:nCLRPANE := RGB(224,229,234)

	oSplPesq := TScrollArea():New(oPanel,0,0,oPanel:nHeight-oPnlCpos:nHeight,oPanel:nWidth,.T.,.T.,.T.)
	oSplPesq:Align    := CONTROL_ALIGN_ALLCLIENT
	oSplPesq:nCLRPANE := RGB(255,255,255)
	oSplPesq:ReadClientCoors( .T., .T.)

	oPnlScr := tPanelCSS():New(0,0,'',oSplPesq,,,,,,0,0)
	oSplPesq:SetFrame( oPnlScr )
	oPnlScr:setCSS(cStyle)
	oPnlScr:nWidth  := oPanel:nWidth
	oPnlScr:nHeight := oPanel:nHeight-oPnlCpos:nHeight
	oPnlScr:ReadClientCoors( .T., .T.)
	
	oDesc := TSay():New(5,5,{||STR0059},oPnlCpos,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oFWLayer:AddLine('ROD', 15, .F.)
	oFWLayer:AddCollumn('ALL', 100, .T., 'ROD')
	oPnlRod := oFWLayer:GetColPanel( 'ALL', 'ROD' )
	
	If len(aComplExc) > 0 .And. (nCpl := aScan(aComplExc,{|x| AllTrim(x[1]) == AllTrim(cCampo)})) > 0
		For nX := 1 to LEN(aComplExc[nCpl][2])

			cNomeCompl := aComplExc[nCpl][2][nX]
			
			If cNomeCompl != nil
				//Verifica se o campo ja foi incluido
				If Ascan(aCampDe, {|x| AllTrim(x[1]) == AllTrim(cNomeCompl) } ) == 0
						
					aPOS := Self:PosTela({}, 1,Int(oPnlScr:nWidth/130))

					aAdd(aObjAux, TJurPnlCampo():New(aPOS[1],aPOS[2],aComplExc[nCpl][3][nX],aComplExc[nCpl][4][nX],oPnlScr,RetTitle(cNomeCompl),cNomeCompl,;
					{|| },;
					{|| },,,) )
					
					aAdd(aCampDe,{cNomeCompl,Space(TamSx3(cNomeCompl)[1]) })

					aObjAux[1]:SetbF3(.T.)

				EndIf
			Endif
		Next
	EndIf
	//Ajusta o tamanho (Height) da janelala de campos
	If (oPnlScr:nHeight < Round(oPnlScr:nWidth/130,0) * 28)
		oPnlScr:nHeight  := Round(oPnlScr:nWidth/130,0) * 28
	Endif

	DEFINE SBUTTON FROM 10, 100 TYPE 1 ENABLE OF oPnlRod ACTION ( If(Self:VlAltLote(aObjAux,aCampDe),(Processa({|| cRet := aObjAux[1]:Valor}),oDlg:End()),))//OK
	DEFINE SBUTTON FROM 10, 140 TYPE 2 ENABLE OF oPnlRod ACTION (oDlg:End())//CANCELA
	
	If len(aObjAux)>0
		oDlg:Activate( , , , , , , ) //ativa a janela apenas se tiverem campos na mesma.
	EndIf
	
Return cRet


//---------------------------------------------------------------------------
/*/{Protheus.doc} JCall093

Função que grava o motivo na tela de historico de correspondente 

@Return  lRet .T. / .F. - retorna se a inclusão do motivo foi feita corretamente

@author  Breno Gomes
@since   27/12/2019
/*/
//---------------------------------------------------------------------------

Static Function JCall093(oModel, oModelNUQ, cValor, Self)
Local oModelNTC := Nil
Local lRet      := .F.

//Privates utilizadas nos campos da NTC
Private c095Cajuri := oModel:GetValue("NSZ_COD")
Private c095NumPro := oModelNUQ:GetValue('NUQ_NUMPRO')
Private c095Instan := oModelNUQ:GetValue('NUQ_INSTAN')
Private c095cCor   := oModelNUQ:GetValue('NUQ_CCORRE')
Private c095lCor   := oModelNUQ:GetValue('NUQ_LCORRE')
Private c095dCor   := ''
Private d095Data   := Date()

	oModelNTC := FWLoadModel('JURA093')
	oModelNTC:SetOperation(3)
	oModelNTC:Activate()
	
	oModelNTC:SetValue("NTCMASTER","NTC_FILIAL", oModel:GetValue("NSZ_FILIAL"))
	oModelNTC:SetValue("NTCMASTER","NTC_CAJURI", oModel:GetValue("NSZ_COD"))
	oModelNTC:SetValue("NTCMASTER","NTC_NUMPRO", oModelNUQ:GetValue("NUQ_NUMPRO"))
	oModelNTC:SetValue("NTCMASTER","NTC_INSTAN", oModelNUQ:GetValue("NUQ_INSTAN"))
	oModelNTC:SetValue("NTCMASTER","NTC_CCORES", oModelNUQ:GetValue("NUQ_CCORRE"))
	oModelNTC:SetValue("NTCMASTER","NTC_LCORRE", oModelNUQ:GetValue("NUQ_LCORRE"))
	oModelNTC:SetValue("NTCMASTER","NTC_DCORRE", JurGetDados('SA2',1,xFilial('SA2') + oModelNUQ:GetValue("NUQ_CCORRE") + oModelNUQ:GetValue("NUQ_LCORRE"),'A2_NOME'))
	oModelNTC:SetValue("NTCMASTER","NTC_MOTIVO", cValor)
	
	If ( lRet := oModelNTC:VldData() )
		lRet := oModelNTC:CommitData()
	EndIf

	oModelNTC:Deactivate()
	Self:Destroy( oModelNTC )

Return lRet
