#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TJURPESQDOC.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqDoc
CLASS TJurPesqDoc

@author Reginaldo N Soares
@since 12/09/2016
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurPesqDoc FROM TJurPesquisa

	DATA cRotina //indica a rotina utilizada nas operações
	
	METHOD New (cTipo, cTitulo, cRotina) CONSTRUCTOR
	METHOD SetMEBrowse (oLstPesq)
	METHOD LoadRotina(cFil,cCod,cCajur, nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa)
	METHOD getCajuri(nLinha)
	METHOD getCodigo(nLinha)
	METHOD getMenu(oMenu)
	METHOD getBrHeader()
	METHOD getBrCols(cSQL, cCampos, aHead)
	METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca)
	METHOD MostraLegenda(oLstPesq)
	METHOD getFilial(nLinha)
	METHOD GetLegenda(cStatus)
	METHOD menuAnexos()
	METHOD refreshLegenda(lHasNum)
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurPesqDoc
CLASS TJurPesqDoc

@author Reginaldo N Soares
@since 12/09/16
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (cTipo, cTitulo, cRotina) CLASS TJurPesqDoc	

Default cRotina := "JURA254"

_Super:New (cTitulo)

Self:setTipoPesq(cTipo)
Self:SetTabPadrao("O0M")
Self:cRotina := cRotina
Self:cTabPadrao := "O0M"
Self:bLegenda := {|| Self:GetLegenda(cStatus)} //bloco de atualização de legenda de anexos

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
METHOD SetMEBrowse (oLstPesq) CLASS TJurPesqDoc	
oLstPesq:SetDoubleClick({|| IIF(Self:oLstPesq:oBrowse:ColPos()==1,Self:MostraLegAnex(oLstPesq,STR0001),Self:JA162Menu(1,oLstPesq))}) //"Legenda de Documentos"
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
METHOD LoadRotina(cFil,cCod,cCajur, nOper, cMsg, nTela, oModel, lModelo, lFecha, lFazPesquisa) CLASS TJurPesqDoc	

Local lOK	:= .T.
Local nRet	:= 1
Local oM254
Local cO0MCod := ""
Local bOk     := {|| IIF(nOper == 3,cO0MCod := oM254:GetValue("O0MMASTER","O0M_COD"),), .T.}
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
		O0M->(DBSetOrder(1))
		O0M->(dbSeek(xFilial("O0M") + cCod))
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
		oM254 := FWLoadModel( 'JURA254' )
		oM254:SetOperation( nOper )
		oM254:Activate()
		bClose := Nil
	Else
		oM254 := Nil
	Endif
	
	MsgRun(STR0008,STR0009,{|| nRet:=FWExecView(cMsg,Self:cRotina, nOper,,bClose, bOk ,,,,,,oM254 )}) //"Carregando..." e "Pesquisa de Documentos"
	
	If INCLUI .AND. nRet == 0 .And. ("6" $ JGetParTpa( cTipoAJ, "MV_JALTREG", "1"))
		If !Empty(cO0MCod)
			//Se incluiu e foi criado um assunto jurídico, abrir o mesmo.
			Self:JurProc(xFilial('O0M'),cO0MCod,,4) 
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
METHOD getCajuri (nLinha) CLASS TJurPesqDoc	
Return Self:JA162Assjur("O0M_CAJURI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCodigo
Função que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCodigo (nLinha) CLASS TJurPesqDoc	
Return Self:JA162Assjur("O0M_COD", nLinha) + Self:JA162Assjur("O0N_SEQ", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} setMenu()
Função que monta o menu lateral principal.

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getMenu(oMenu) CLASS TJurPesqDoc
Local aRelat  := {}
Local aEspec  := {}
Local cRotina := '19'
Local aOpera  := {}

aAdd(aOpera, {STR0012,{|| IIF(Self:befAction(),Self:JA162Menu(1,Self:oLstPesq,,Self:oCmbConfig),)},{|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 2)) .Or. Empty(Self:cGrpRest)) }}) //"Visualizar"
aAdd(aOpera, {STR0013,{|| Self:JA162Menu(3,Self:oLstPesq,Self:aObj,Self:oCmbConfig)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 3)) .Or. Empty(Self:cGrpRest))},K_ALT_I }) //"Incluir"//incluido parâmetro de tecla de atalho
aAdd(aOpera, {STR0014,{|| IIF(Self:befAction(), ( Self:JA162Menu(4,Self:oLstPesq,Self:aObj,Self:oCmbConfig) ),)}, {|| ((Self:cGrpRest $ 'CORRESPONDENTES/CLIENTES/MATRIZ' .And. JA162AcRst(cRotina, 4)) .Or. Empty(Self:cGrpRest))},K_ALT_A }) //"Alterar"//incluido parâmetro de tecla de atalho

oMenu := Self:setMenuPadrao(oMenu, , aOpera, aRelat,aEspec, '19')

Return oMenu

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrHeader()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrHeader() CLASS TJurPesqDoc
Local aCampos := {}

//Campos padrão
aAdd(aCampos, {"O0M_COD",    JA160X3Des("O0M_COD"),    "2"})
aAdd(aCampos, {"O0M_CAJURI", JA160X3Des("O0M_CAJURI"), "2"})
aAdd(aCampos, {"O0M_FILIAL", JA160X3Des("O0M_FILIAL"), "2"})
aAdd(aCampos, {"O0N_SEQ",    JA160X3Des("O0N_SEQ") ,   "2"})
aAdd(aCampos, {"O0N_STATUS", JA160X3Des("O0N_STATUS"), "2"})

Return aCampos

//-------------------------------------------------------------------
/*/{Protheus.doc} getBrCols()
Função que seta o header do grid

@author André Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getBrCols(cSQL, cCampos, aHead) CLASS TJurPesqDoc
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
	AAdd(aManual,{"O0M", "O0M001", "NSZ", "NSZ001", ""})
	AAdd(aManual,{"O0N", "O0N001", "O0M", "O0M001", ""})

	cSQL := "SELECT "+cCampos+" FROM " +RetSqlname('O0M') + " O0M001 "
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
	aAdd(aCol,Array(LEN(aHead)+6))
	nCols++
	nQtd++

	For nX := 1 To LEN(aHead)
		If nX == 1
			aCol[nCols][nX] := Self:GetLegenda((cLista)->O0N_STATUS)
		Elseif (aHead[nX][10] != "V") //Valida se não é um campo virtual para evitar um fieldget/fieldpos
			aCol[nCols][nX] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))				
		EndIf		
	Next nX
	
	aCol[nCols][LEN(aHead)+1] := (cLista)->O0M_COD
	aCol[nCols][LEN(aHead)+2] := (cLista)->O0M_CAJURI
	aCol[nCols][LEN(aHead)+3] := (cLista)->O0M_FILIAL
	aCol[nCols][LEN(aHead)+4] := (cLista)->O0N_SEQ
	aCol[nCols][LEN(aHead)+5] := (cLista)->O0N_STATUS
	aCol[nCols][LEN(aHead)+6] := .F.
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
METHOD getSQLPesq(aObj,oCmbConfig, cCampos, aManual, aTroca) CLASS TJurPesqDoc
Local nI, cSQL   := ''
Local aSQL       := {}
Local aSQLRest   := {}
Local cTpAJ      := ""
Local O0MName    := Alltrim(RetSqlName("O0M"))
Local aFilUsr    := JURFILUSR( __CUSERID, "O0M" )
Local cTpPesq    := Self:cTipoPesq
Local cPesqAtv   := oCmbConfig:cValor

AAdd(aManual,{"O0M", "O0M001", "NSZ", "NSZ001", ""})
AAdd(aManual,{"O0N", "O0N001", "O0M", "O0M001", ""})
AAdd(aTroca,{"O0M", "O0M001"})

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
cSQL += " 	FROM "+O0MName+" O0M001 " + CRLF
cSQL := Self:JQryPesq(cSQL,Self:cTabPadrao, aManual)

If ( VerSenha(114) .or. VerSenha(115) ) 
	cSQL += " WHERE O0M_FILIAL IN " + FORMATIN(aFilUsr[1],aFilUsr[2]) +  CRLF
Else
	cSQL += " WHERE O0M_FILIAL = '"+xFilial("O0M")+"'"+ CRLF
Endif

//<- Adiciona a restrição de Acesso ->
If !Empty(aSQLRest)
	cSQL += " AND ("+Ja162SQLRt(aSQLRest, , , , , , , , , cTpAJ)+")"
EndIf

//Ponto de Entrada de Cláusula para Query - JA162QRY
If ExistBlock("JA162QRY") 
	cSQL += ExecBlock("JA162QRY",.F.,.F.,{cTpAJ,cTpPesq,cPesqAtv})
EndIf

cSQL += " AND O0M001.D_E_L_E_T_ = ' ' "+ CRLF
cSQL += " AND NSZ_TIPOAS IN (" + cTpAJ + ")" + CRLF

cSQL += VerRestricao()  //Restricao de Escritorio e Area

cSQL += Self:GetCondicao(aSQL, O0MName) + CRLF

If "SELECT NUQ_" $ cSql
	cSQL += " AND NSZ_TIPOAS <> '009' " 
EndIf

Return cSQL

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
METHOD MostraLegenda(oLstPesq) CLASS TJurPesqDoc
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
METHOD getFilial (nLinha) CLASS TJurPesqDoc

Return Self:JA162Assjur("O0M_FILIAL", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} GetLegenda(cStatus)
Função utilizada para retornar a cor referente ao tipo de assunto jurídico.
Uso Geral.

@Param	cTipoAS		Código do tipo de assunto jurídico.
@Return	cImagem		Nome do BMP da cor.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetLegenda(cStatus) CLASS TJurPesqDoc
Local cImagem := ''

Do Case
	Case cStatus == '1'
		cImagem := 'BR_VERMELHO.PNG'
	Case cStatus == '2'
		cImagem := 'BR_VERDE.PNG'
	Otherwise 
		cImagem := 'BR_BRANCO.PNG'
End Case

Return cImagem

//-------------------------------------------------------------------
/*/{Protheus.doc} menuAnexos
Metodo de Anexos

@author Willian.Kazahaya
@since 02/03/2018
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD menuAnexos() CLASS TJurPesqDoc
Local lHasNum := .F.

JurAnexos("O0N", self:getCodigo(), 4, Self:getFilial())

lHasNum := JurVldNUM(self:getCodigo(), "O0N")

Processa({|lEnd| J254EnvEml(self:getCodigo(), '2', @lEnd)}, STR0016, STR0017, .T.)			
		
self:refreshLegenda(lHasNum)

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} refreshLegenda
Faz a atualização da coluna de legenda da linha posicionada.
  
@author	André Spirigoni Pinto
@since	09/02/2017
/*/
//---------------------------------------------------------------------------
METHOD refreshLegenda(lHasNum) CLASS TJurPesqDoc
Local cStatus := '1'

If lHasNum 
	cStatus := '2'
EndIf

if self:bLegenda != Nil
	self:oLstPesq:aCols[self:oLstPesq:nAt][1] := Eval(self:bLegenda)
	Self:oLstPesq:Refresh()
Endif

Return .T.
