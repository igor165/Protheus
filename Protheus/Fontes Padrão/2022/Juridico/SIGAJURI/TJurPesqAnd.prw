#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TJURPESQAND.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqAnd
CLASS TJurPesqAnd

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurPesqAnd FROM TJurPesquisa

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
	METHOD OpAltLote(aCampos, aCampDe)
	METHOD getFilial (nLinha)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqAnd
CLASS TJurPesqAnd

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTipo, cTitulo, cRotina) CLASS TJurPesqAnd
Default cRotina := "JURA100"

_Super:New (cTitulo)

Self:setTipoPesq(cTipo)
Self:SetTabPadrao("NT4")
Self:cRotina := cRotina
Self:cTabPadrao := "NT4"
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
METHOD SetMEBrowse (oLstPesq) CLASS TJurPesqAnd	
oLstPesq:SetDoubleClick({|| IIF(Self:oLstPesq:oBrowse:ColPos()==1,Self:MostraLegAnex(oLstPesq,STR0001),Self:JA162Menu(1,oLstPesq))}) //"Legenda de Andamentos"
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
METHOD LoadRotina(cFil,cCod,cCajur,nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa) CLASS TJurPesqAnd	
Local lOK	:= .T.
Local nRet	:= 1

Local oM100
Local cNT4Cod := ""
Local bOk     := {|| IIF(nOper == 3,cNT4Cod := oM100:GetValue("NT4MASTER","NT4_COD"),), .T.}
Local bClose  := {|| .T.}

Default oModel 	:= NIl
Default nTela 	:= 0
Default lFecha	:= .F.
Default lFazPesquisa := .T. // Usado na rotina de Andamentos. Indica se realiza a pesquisa após o Andamento ser alterado e houver confirmação (essa alteração dita é quando o Andamento é reaberto em modo de alteração após a inclusão) e a tela for fechada.

If nOper == 3 .And. (cTipoAJ == '000' .Or. cTipoAJ == '')
  If cTipoAJ == '000'
	  Alert(STR0002) //"Configuração inválida ou perfil de pesquisa não está vinculado a nenhum tipo de assunto jurídico. Operação cancelada!" 
	EndIf
  lOK := .F.
Else
	If !cCod == NIL .And. !Empty(cCod)
		NT4->(DBSetOrder(1))
		NT4->(dbSeek(xFilial('NT4') +AVKEY(cCod,"NT4_COD")))
	Else
		lOK := (nOper == 3)
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
		oM100 := FWLoadModel( 'JURA100' )
		oM100:SetOperation( nOper )
		oM100:Activate()
		bClose := Nil
	Else
		oM100 := Nil
	Endif
	
	MsgRun(STR0008,STR0009,{|| nRet:=FWExecView(cMsg,Self:cRotina, nOper,,bClose, bOk ,,,,,,oM100 )}) //"Carregando..." e "Pesquisa de Andamentos"
	
	If INCLUI .AND. nRet == 0 .And. ("4" $ JGetParTpa( cTipoAJ, "MV_JALTREG", "1"))
		If !Empty(cNT4Cod)
			//Se incluiu e foi criado um assunto jurídico, abrir o mesmo.
			Self:JurProc(xFilial('NT4'),cNT4Cod,,4)
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
METHOD getCajuri (nLinha) CLASS TJurPesqAnd	
Return Self:JA162Assjur("NT4_CAJURI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodigo
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCodigo (nLinha) CLASS TJurPesqAnd	
Return Self:JA162Assjur("NT4_COD", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMenu()
Função que monta o menu lateral principal.

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getMenu(oMenu) CLASS TJurPesqAnd
Local aRelat := {}

aAdd(aRelat, {STR0003,{||	IIF(Self:befAction(),RelatAnd(Self:getCajuri(), Self:getFilial(), self:getfiltro()),)} }) //"Andamentos"

oMenu := Self:setMenuPadrao(oMenu, , , aRelat, , '04')

Return oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrHeader() CLASS TJurPesqAnd
Local aCampos := {}

//Campos padrão
aAdd(aCampos, {"NT4_COD",JA160X3Des("NT4_COD"),"2"})
aAdd(aCampos, {"NT4_CAJURI",JA160X3Des("NT4_CAJURI"), "2"})
aAdd(aCampos, {"NT4_FILIAL",JA160X3Des("NT4_FILIAL") ,"2"})

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrCols(cSQL, cCampos, aHead) CLASS TJurPesqAnd
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
	AAdd(aManual,{"NT4", "NT4001", "NSZ", "NSZ001", ""})

	cSQL := "SELECT "+cCampos+" FROM " +RetSqlname('NT4') + " NT4001 "
	cSQL := Self:JQryPesq(cSQL, Self:cTabPadrao, aManual)
	cSQL += " Where 1=2 "

EndIf	
 
cSQL := ChangeQuery(cSQL)
//Change query troca '' por ' ', o que compromete com a pesquisa
cSQL := StrTran(cSQL,",' '",",''") 
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cLista, .T., .F.)

dbSelectArea(cLista)
(cLista)->(dbGoTop())

While (cLista)->(!Eof())
	aAdd(aCol,Array(LEN(aHead)+4))
	nCols++
	nQtd++
  
	For nX := 1 To LEN(aHead)
		If nX == 1
			aCol[nCols][nX] := Self:getLegAnexo((cLista)->NT4_COD, (cLista)->NT4_CAJURI)
		Elseif (aHead[nX][10] != "V") //Valida se não é um campo virtual para evitar um fieldget/fieldpos
			aCol[nCols][nX] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))				
		EndIf		
	Next nX
	
	aCol[nCols][LEN(aHead)+1] := (cLista)->NT4_COD
	aCol[nCols][LEN(aHead)+2] := (cLista)->NT4_CAJURI
	aCol[nCols][LEN(aHead)+3] := (cLista)->NT4_FILIAL
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
METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca) CLASS TJurPesqAnd
Local nI, cSQL   := ''
Local aSQL	     := {}
Local aSQLRest   := {}
Local cTpAJ      := ""
Local NT4Name    := Alltrim(RetSqlName("NT4"))
Local aFilUsr   := JURFILUSR( __CUSERID, "NT4" )
Local cTpPesq	 := Self:cTipoPesq
Local cPesqAtv	 := oCmbConfig:cValor
Local cGrpRest 	 := JurGrpRest()

AAdd(aManual,{"NT4", "NT4001", "NSZ", "NSZ001", ""})
AAdd(aTroca,{"NT4", "NT4001"})

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
cSQL += " 	FROM "+NT4Name+" NT4001 " + CRLF
cSQL := Self:JQryPesq(cSQL,Self:cTabPadrao, aManual)

If ( VerSenha(114) .or. VerSenha(115) ) 
	cSQL += " WHERE NT4_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) +  CRLF
Else
	cSQL += " WHERE NT4_FILIAL = '"+xFilial("NT4")+"'"+ CRLF
Endif

//<- Adiciona a restrição de Acesso ->
If !Empty(aSQLRest)
	cSQL += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ)+")"
EndIf

//Ponto de Entrada de Cláusula para Query - JA162QRY
If ExistBlock("JA162QRY") 
	cSQL += ExecBlock("JA162QRY",.F.,.F.,{cTpAJ,cTpPesq,cPesqAtv})
EndIf

//Verifica se o usuario logado é cliente ou correspondente para filtrar apenas o andamento que ele tem acesso
If "CLIENTES" $ cGrpRest .Or. "CORRESPONDENTES" $ cGrpRest
	cSQL += " AND NT4001.NT4_PCLIEN = '1'"
EndIf

cSQL += "   	AND NT4001.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += "   	AND NSZ_TIPOAS IN (" + cTpAJ + ")" + CRLF

cSQL += VerRestricao()  //Restricao de Escritorio e Area

cSQL += Self:GetCondicao(aSQL, NT4Name) + CRLF

If "SELECT NUQ_" $ cSql
	cSQL += " AND NSZ_TIPOAS <> '006' "
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
METHOD OpAltLote(aCampos, aCampDe) CLASS TJurPesqAnd
Local aArea    := GetArea()
Local cAlote   := GetNextAlias()
Local cSQL     := Self:MontaSQL()
Local aAltera  := {}
Local oModel100
Local oNT4
Local cCampo   := ""
Local nI       := 0
Local nC       := 0
Local nQtd     := 0
Local aExcecao := Self:getExcecaoLote()
Local aErro    := {}
Local cMsg     := ""

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlote, .T., .F.)

//Preenche o array com os registros que serão alterados
While (cAlote)->(!Eof())
	aAdd(aAltera,{(cAlote)->NT4_FILIAL,(cAlote)->NT4_COD})
	(cAlote)->(dbSkip())
End

ProcRegua(Len(aAltera)) //Preenche a lista de registros que serão alterados.

(cAlote)->( dbcloseArea() )

DbSelectArea("NT4")
NT4->(DBSetOrder(1))

For nI := 1 to len(aAltera)

	If lAbortPrint //Indica que a operação foi abortada
		Exit
	EndIf
		
	if NT4->(dbSeek(aAltera[nI][1] + aAltera[nI][2]))
	
		lPesquisa := .F.
		
		oModel100 := FWLoadModel( 'JURA100' )
		oModel100:SetOperation( 4 )
		oModel100:Activate()
		
		INCLUI := .F.
		ALTERA := .T.

		oNT4 := oModel100:GetModel( 'NT4MASTER' )
		
		//Valida se o modelo está no mesmo registro
		if (oNT4:GetValue("NT4_FILIAL") == aAltera[nI][1] .And. oNT4:GetValue("NT4_COD") == aAltera[nI][2])
			For nC := 1 to len(aCampos)
				cCampo := aCampos[nC]:cNomeCampo
				if !Empty(aCampos[nC]:Valor) //valida se o valor foi preenchido
					//valida se o valor do campo é igual ao antigo
					if (aScan(aExcecao,cCampo)>0 .Or. oNT4:GetValue(cCampo) == aCampDe[aScan(aCampDe,{|x| x[1]==cCampo})][2])
						oNT4:SetValue(cCampo,aCampos[nC]:Valor) //seta o valor novo
					endif
				Endif
			Next
		endif
			
		If oModel100:VldData()
			nQtd++
			oModel100:CommitData()
		else
			aErro := oModel100:GetErrorMessage()
			
			cMsg  := AllToChar( aErro[6] ) + CRLF //"Mensagem do erro: "

			Alert( STR0004 + cMsg ) //"Erro na alteração em lote: "

			if ApMsgYesNo(STR0005) //"Deseja continuar a alteração de forma manual?"
				if (Self:JurProc(aAltera[nI][1],aAltera[nI][2],,4,10,oModel100))
					nQtd++
				endif
			endif
		endif
		
		oModel100:DeActivate()
		
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
METHOD getFilial (nLinha) CLASS TJurPesqAnd
Return Self:JA162Assjur("NT4_FILIAL", nLinha)
