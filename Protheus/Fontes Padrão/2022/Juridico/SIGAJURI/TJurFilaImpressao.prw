#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TJURFILAIMPRESSAO.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "TOTVS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFilaImpressao
CLASS TJurPesqFW 

@author Andr� Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
CLASS TJurFilaImpressao

	DATA cRotina //indica a rotina utilizada nas opera��es
	DATA oPanel //Painbel pai onde a fila ser� inclu�da.
	DATA lDesAtivo
	DATA lVincAtivo
	DATA oCountFila
	DATA __nCntNQ3
	DATA cCfgFila
	DATA oLstFila
	DATA oPnlFila
	DATA oLstPesq //objeto que representa o grid de resultados
	DATA cUser
	DATA cThread
	DATA oPesquisa
	DATA cTipoFi //Tipo do assunto jur�dico da fila de impress�o
	DATA oItens //objeto hashmap para guardar os itens da fila e evitar o dbseek
	DATA lBlLstg //vari�vel que vai guardar se existe o ponto de entrada 
	DATA cFilNQ3 //filial da tabela NQ3
	DATA lAutRec //determina se o auto recno est� habilitado na NQ3 para fazer inserts.
	DATA cAlQry //Alias utilizado para fazer as consultas
	DATA nMaxQry //n�mero m�ximo de registros
	DATA nCurRec //recno posicionado no alias
	
	METHOD New (cTipo, cTitulo, cRotina) CONSTRUCTOR
	METHOD ListaColImp(aHead, cUser, cThread)
	METHOD MenuPopImp(oObj, nRow, nCol, oLstPesq, oLstFila, cUser, cThread, cCajur, oCmbConfig)
	METHOD GetListaImp(oLstFila, cCampo, nLinha)
	METHOD getCajuri (nLinha)
	METHOD getFilial (nLinha)
	METHOD getChaveItem (nLinha)
	METHOD PnlFila(lMostra)
	METHOD AtuCountFila(nQtdFila)
	METHOD GetNCntNQ3()
	METHOD SetNCntNQ3(nQdade)
	METHOD AtuBtnsFila(cCfgFila, oChkDes, oChkVinc)
	METHOD AtuFilaImp()
	METHOD DelAllReg()
	METHOD OpcAddFila(cCajur, cOpcFila, lDes, lVinc, cFili, cTipoAs)
	METHOD AddReg(cCajur, cUser, cThread, oLstFila, cFilBrw, cTipoAs)
	METHOD AddRegDes(cCajur, cUser, cThread, lDesAtivo, cFili, cTipoAs)
	METHOD JVldFila(cTipoAs, cTipoFi)
	METHOD AddRegVinc(cCajur, cUser, cThread, lVinc, cFili, cTipoAs)
	METHOD DelReg()
	METHOD ExibeFila()
	METHOD EscondeFila()
	METHOD MenuPopPesq(oObj, nRow, nCol, oLstPesq, cOpcFila, lDes, lVinc)
	METHOD AddAllReg(cUser, cThread, oLstPesq, lDes, lVinc, cOpcFila, oPesquisa)
	METHOD getTipoAs()
	METHOD getQtdReg()
	METHOD DeActivate()
	METHOD LstHeadFila()
	
ENDCLASS

//-------------------------------------------------------------------
/*/{Protheus.doc} JurFilaImpressao
CLASS TJurFilaImpressao

@author Andr� Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD New (oPanel, oPesquisa, oPnlCfgFila, oLstPesq) CLASS TJurFilaImpressao	
Local oCmbCfgFila
Local oChkDes
Local oChkVinc
Local aCampFila := {}
Local aItems       := {'',STR0001, STR0002, STR0003}
Local oDescricao
Local oFont
Local oPnlTop 

Self:oLstPesq := oLstPesq
Self:oPesquisa := oPesquisa
Self:cUser		:= RetCodUsr()
Self:cThread	:= SubStr(AllTrim(Str(ThreadId())),1,4)
Self:cTipoFi := ""
Self:oItens := HMNew()
Self:__nCntNQ3 := 0
Self:lBlLstg := .T.
Self:cFilNQ3 := xFilial('NQ3')
Self:lAutRec := (InfoSX2('NQ3','X2_AUTREC') == '1')
Self:nMaxQry := 20 //n�mero m�ximo de registros que devem ser exibidos no grid
Self:nCurRec := 0

//************** Bot�es Fila Impress�o *****************
oCmbCfgFila := TComboBox():New(02,01,{|u|if(pCount()>0,Self:cCfgFila:=u,Self:cCfgFila)},aItems,110,10,oPnlCfgFila,,{||},,,,.T.,,,,,,,,,'cCfgRelat')
oCmbCfgFila:bLostFocus := {|| Self:AtuBtnsFila(Self:cCfgFila, oChkDes, oChkVinc)}
oChkDes     := TCheckBox():Create(oPnlCfgFila,{|u|if( pCount()>0,Self:lDesAtivo  := u, Self:lDesAtivo)},02,120,STR0004,100,10,,,,,,,,.T.,,,) //"Incidentes Ativos?"
oChkVinc    := TCheckBox():Create(oPnlCfgFila,{|u|if( pCount()>0,Self:lVincAtivo := u,Self:lVincAtivo)},02,200,STR0005,100,10,,,,,,,,.T.,,,) //"Vinculados Ativos?"

oChkDes:Disable()
oChkVinc:Disable()

//***************  Panel Fila Impress�o ****************
Self:oPnlFila := tPanel():New(0,0,"",oPanel,,,,,CLR_WHITE,0,0,.T.,.T.)
//Self:oPnlFila:Align    := CONTROL_ALIGN_RIGHT
Self:oPnlFila:Align    := CONTROL_ALIGN_BOTTOM
Self:oPnlFila:nCLRPANE := CLR_WHITE
Self:oPnlFila:Hide()

oPnlTop := tPanel():New(0,0,'',Self:oPnlFila,,,,,,40,10)
oPnlTop:Align := CONTROL_ALIGN_TOP
oPnlTop:nCLRPANE := RGB(240,240,240)

oFont := TFont():New('Arial',,16,.T.,.T.)

oDescricao := tSay():New(01,01,{|| STR0006},oPnlTop,,oFont,,,,.T.,CLR_BLACK,,100,10) //"Fila de Impress�o:"
oDescricao:Align := CONTROL_ALIGN_LEFT

Self:oCountFila := tSay():New(01,01,{||'  '},oPnlTop,,,,,,.T.,,,100,10)
Self:oCountFila:Align := CONTROL_ALIGN_RIGHT
Self:oCountFila:lWordWrap    := .T.
Self:oCountFila:lTransparent := .T.

Self:oLstFila := TJurBrowse():New(Self:oPnlFila)
Self:oLstFila:SetDataArray()
Self:oLstFila:SetDescription("Fila de Impress�o")

aCampFila := aClone(Self:LstHeadFila())

Self:oLstFila:setHeaderSX3(aCampFila)
Self:oLstFila:Activate()
Self:oLstFila:SetArray(Self:ListaColImp(Self:oLstFila:getHeader()))
Self:oLstFila:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
Self:oLstFila:SetRightClick({ | oObj, nRow, nCol | Self:MenuPopImp(oObj, nRow, nCol, oLstPesq, Self:oLstFila,Self:cUser, Self:cThread, Self:getCajuri(), Self:oPesquisa:oCmbConfig)})
Self:oLstFila:Refresh()
Self:oLstFila:Disable()

//*************/  Fim Panel Fila Impress�o /**************/

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ListaColImp(aHead, cUser, cThread)
Fun��o utilizada para preencher a lista.
Uso Geral.
@Param		aHead   Array com o cabe�alho da lista.
@Param		cUser   C�digo do usu�rio do sistema
@Param    cThread C�digo da Thread
@Return		aCol	Array com o registros.
@author Cl�vis Eduardo Teixeira
@since 05/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ListaColImp(aHead, cUser, cThread) CLASS TJurFilaImpressao
Local aCol   := {}
Local aArea  := GetArea()
Local nCols  := 0
Local cLista := GetNextAlias()
Local nX     := 0
Local nQtd   := 0
Local cSQL

Default cUser   := Self:cUser
Default cThread := Self:cThread

cSQL := "SELECT NQ3_CAJURI, NQ3_CUSER, NQ3_SECAO, NQ3_FILORI,NQ3.R_E_C_N_O_ " +;
        "  FROM " + RetSqlName('NQ3') + ' NQ3 '    +;
   		"WHERE NQ3_CUSER  = "+ "'"+cUser+"'"      +;
	  	" AND NQ3_FILIAL = '"+xFilial("NQ3")+"'" +;
	  	" AND NQ3_SECAO  = "+ "'"+cThread+"'"    +;
		" AND D_E_L_E_T_ = ' ' "

	If ExistBlock("J162LstQ")   ////// novo Flavio --- Incluir campos na fila de impress�o - Alterar a Query.
		cSQL := ExecBlock("J162LstQ",.F.,.F.,{cSQL,cUser,cThread})
	EndIf

cSQL := ChangeQuery(cSQL)
dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cLista, .T., .F.)

dbSelectArea(cLista)

While (cLista)->(!Eof())
	nQtd++	
	if (nQtd <= Self:nMaxQry)
		aAdd(aCol,Array(LEN(aHead)+1))
		nCols++
	
		For nX := 1 To LEN(aHead)
	    	aCol[nCols][nX] := (cLista)->(FieldGet(FieldPos(aHead[nX][2])))
		Next nX
	
		aCol[nCols][LEN(aHead)+1] := .F.
	Else
		if (Self:nCurRec==0)
			Self:nCurRec := (cLista)->R_E_C_N_O_
			Self:cAlQry := cLista
		Endif
	Endif
	(cLista)->(dbSkip())
End

if (Self:nCurRec==0) //se n�o houve pagina��o, pode fechar o alias
	(cLista)->( dbcloseArea() )
Endif

RestArea( aArea )
Self:AtuCountFila(nQtd)

/*
	//<- Chama a fun��o static para inserir a quantidade de registros para ->
	//<- da fila de impress�o. 													 ->
	//<- ATEN��O: Usado para o ponto de entrada da fun��o MENUPOPIMP 		 ->	
*/
Self:SetNCntNQ3(nQtd)

Return aCol

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuPopImp(oObj, nRow, nCol, oLstPesq, oLstFila,
                             oPanel, oPanelPai, cUser, cThread, cCajur)
Fun��o utilizada para configurar o cabe�alho da lista
Uso Geral.
@Param oObj      Nome do Objeto
@Param nRow      Numero da linha
@Param nCol      Numero da coluna
@Param oLstPesq  ListBox da pesquisa de Processo
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Objeto contendo o panel da fila de impress�o
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Param cUser     C�digo do Usu�rio
@Param cThread   C�digo da Thread
@Param cCajur    C�digo do assunto jur�dico
@Return	Nil
@author Cl�vis Eduardo Teixeira
@since 05/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MenuPopImp(oObj, nRow, nCol, oLstPesq, oLstFila, cUser, cThread, cCajur, oCmbConfig) CLASS TJurFilaImpressao
Local oMenu
Local oMenuItem	 := {}
Local nCountFila	:= 0 

MENU oMenu POPUP of oObj

	aAdd(oMenuItem, MenuAddItem(STR0007,,,.T.,,,'PGPREV_MDI.PNG',oMenu,{||Self:DelReg()},,,,, {||.T.} )) //"Excluir o processo da fila de impress�o" 
	aAdd(oMenuItem, MenuAddItem(STR0008,,,.T.,,,'TOP_MDI.PNG',oMenu,{|| MsgRun(STR0020,STR0006,{||Self:DelAllReg()})},,,,, {||.T.} )) //"Excluir todos os processos da fila de impress�o" 
	If JA162AcRst('13')
		aAdd(oMenuItem, MenuAddItem(STR0009,,,.T.,,,'IMPRESSAO.PNG', oMenu,{|| IIf(ApMsgYesNo(STR0010), (Self:oPesquisa:ParamRelat(oLstPesq, oLstFila, cUser, cThread, oCmbConfig)), )},,,,, {||.T.} )) //"Imprimir processos da fila de impress�o"
	EndIf

	If Self:cTipoFi $ "008" .And. JA162AcRst('15')
		aAdd(oMenuItem, MenuAddItem(STR0011,,,.T.,,,'IMPRESSAO.PNG', oMenu,{||(Self:oPesquisa:J162PConc(oLstPesq, oLstFila, cUser, cThread, oCmbConfig))},,,,, {||.T.} )) //"Imprimir Concess�es da Fila de Impress�o"
	EndIf

	If JA162AcRst('12')
		aAdd(oMenuItem, MenuAddItem(STR0012,,,.T.,,,'SDUFIELDS.PNG', oMenu,{|| IIf(ApMsgYesNo(STR0010), (JURA108(Self,Self:getTipoAs(), Self:oPesquisa:getFiltro(),.T. /*lFila*/), MsgRun(STR0020,STR0006,{||Self:DelAllReg()})), )},,,,, {||.T.} )) //"Exporta��o Personalizada" 
	EndIf
	
	nCountFila	:= Self:GetNCntNQ3()	// Fun��o static

//-------------------------------------------------------------------
/*/ JA162MENUP 
Ponto de entrada que permite manipular o menu da fila de impress�o

@param oMenu - Menu da fila de impress�o
@param oMenuItem - �tens do menu da fila de impress�o
@param nCountFila - Quantidade de registros na fila
@param cUser - Usu�rio logado
@param oLstFila - Objeto da fila de impress�o
@param cThread - Id da Thread que est� sendo executada 
@param oPanel - Painel da fila
@param oPanelPai - Painel da pesquisa
@param Self:oCountFila - Label da quantidade de registros em fila

@return oMenu - Objeto do menu alterado
/*/
//-------------------------------------------------------------------
	If (Existblock( 'JA162MENUP' ))
		ExecBlock( 'JA162MENUP', .F., .F., {oMenu, oMenuItem, nCountFila, cUser, oLstFila, cThread, Self:oPnlFila, Self:oLstPesq:oBackPanel, Self:oCountFila } )
	EndIf 

ENDMENU

If JurVerSCHtml("N") < 23016 .AND. (GetRemoteType() == 5)
	Activate POPUP oMenu AT nRow+1000, nCol+300
Else
	Activate POPUP oMenu AT nRow, nCol+10
EndIf

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GetListaImp(oLstPesq, cCampo)
Fun��o utilizada para pegar o c�digo(NQ3_CAJURI_COD) do registro.
Uso Geral.
@param		oLstFila	Lista de registros na fila de impress�o
@param		cCampo		Nome do campo a ser pesquisado
@param		nLinha		N�mero da linha
@Return 	C�digo do registro
@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetListaImp(cCampo, nLinha) CLASS TJurFilaImpressao
Local nPosCol 	:= 0
Local cRetorno	:= ""
Default cCampo 	:= "NQ3_CAJURI"
Default nLinha	:= Self:oLstFila:NAT

If Len(Self:oLstFila:aCols) > 0 
	nPosCol := aScan(Self:oLstFila:aHeader,{ |z| Alltrim(z[2]) == cCampo })
	If nPosCol > 0 
		cRetorno := Self:oLstFila:aCols[nLinha][nPosCol]	
	Endif 	
Endif

Return IIF( LEN(Self:oLstFila:aCols)>0, cRetorno, "" )

//-------------------------------------------------------------------
/*/{Protheus.doc} getFilial
Fun��o que retorna a filial do registro posicionado no Grid ou na linha escolhida

@author Andr� Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getFilial (nLinha) CLASS TJurFilaImpressao
Return Self:GetListaImp("NQ3_FILORI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCajuri
Fun��o que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author Andr� Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getCajuri (nLinha) CLASS TJurFilaImpressao	
Return Self:GetListaImp("NQ3_CAJURI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} getCajuri
Fun��o que retorna o Cajuri posicionado no Grid ou na linha escolhida

@author Andr� Spirigoni Pinto
@since 08/05/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getTipoAs() CLASS TJurFilaImpressao	
Return JurGetDados('NSZ',1,Self:getChaveItem(),'NSZ_TIPOAS')

//-------------------------------------------------------------------
/*/{Protheus.doc} getChaveItem
Fun��o que retorna o Cajuri + filial origem posicionado no Grid ou na linha escolhida

@author Andr� Spirigoni Pinto
@since 29/01/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getChaveItem (nLinha) CLASS TJurFilaImpressao	
Return Self:GetListaImp("NQ3_FILORI", nLinha) + Self:GetListaImp("NQ3_CAJURI", nLinha)

//-------------------------------------------------------------------
/*/{Protheus.doc} PnlFila(oPanelPai, oPanel)
Fun��o para controle da visualiza��o do grid de fila de impress�o
Uso Geral
@Param oPanelPai Obejto contendo o panel da pesquisa de processo
@Param oPanel    Obejto contendo o panel da fila de impress�o
@author Cl�vis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD PnlFila() CLASS TJurFilaImpressao
If !Self:oPnlFila:lVisible
	Self:ExibeFila()
Else
	Self:EscondeFila()
Endif
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuCountFila(nQtd)
Fun��o utilizada para informar a quantidade de registros a pesquisa
retornou.
Uso Geral.

@Param	nQtd	Quantidade de resistros.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AtuCountFila(nQtdFila) CLASS TJurFilaImpressao
  Self:oCountFila:cCaption := ' '+STR0013+' '+Alltrim(Str(nQtdFila)) //"Quantidade de Registros na Fila:"
  Self:oCountFila:Refresh()
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} SetNCntNQ3(nQdade)
Fun��o utilizada para gravar na propriedade de classe a quantidade
de registros retornados na pesquisa
<- Encapsulamento: nCntNQ3  ->

@Param	nQdade	Quantidade de resistros.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD SetNCntNQ3(nQdade) CLASS TJurFilaImpressao
Return Self:__nCntNQ3 := nQdade

//-------------------------------------------------------------------
/*/{Protheus.doc} GetNCntNQ3()
Fun��o utilizada para retornar a quantidade
de registros retornados na pesquisa
<- Encapsulamento: nCntNQ3  ->

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD GetNCntNQ3() CLASS TJurFilaImpressao
Return Self:__nCntNQ3

//-------------------------------------------------------------------
/*/{Protheus.doc} getQtdReg
Fun��o utilizada para informar a quantidade de registros est�o na fila de impress�o.
Uso Geral.

@Param	nQtd	Quantidade de registros.

@author Felipe Bonvicini Conti
@since 19/10/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD getQtdReg() CLASS TJurFilaImpressao
Return Self:GetNCntNQ3()

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuBtnsFila(cCfgFila, oChkDes, oChkVinc)
Fun��o utilizada para controlar os bot�es checks da fila de impress�o
Uso Geral.
@Return NIL
@Param cCfgFila Campo de caracater com a op��o selecionado no combo
@Param oChkDes  Objeto de controle para valida��o de desdobramento ativos
@Param oChkVinc Objeto de controle para valida��o de vinculados ativos
@author Cl�vis Eduardo Teixeira
@since 04/02/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AtuBtnsFila(cCfgFila, oChkDes, oChkVinc) CLASS TJurFilaImpressao
Local cOpc := IIF(!Empty(cCfgFila), SubStr(cCfgFila,1,1),)

//Muda a marca��o dos componentes de acordo com a op��o escolhida.
If Empty(cOpc)
	oChkVinc:lActive := .F.
	oChkDes:lActive := .F.
	oChkDes:Disable()
	oChkVinc:Disable()
	oChkVinc:CtrlRefresh ()
	oChkDes:CtrlRefresh ()
Elseif cOpc == '1'
	oChkDes:Enable()
	oChkVinc:lActive := .F.
	oChkVinc:Disable()
	oChkVinc:CtrlRefresh ()
Elseif cOpc == '2'
	oChkDes:Disable()
	oChkDes:lActive := .F.

	oChkVinc:Enable()
	oChkDes:CtrlRefresh ()
Elseif cOpc == '3'
	oChkDes:Enable()
	oChkVinc:Enable()
Endif

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuFilaImp(oLstFila, cUser, cThread, oPanel, oPanelPai)
Fun��o utilizada para atualizar a fila de impress�o
Uso Geral.
@param oLstFila	Lista da fila de impress�o
@Param cUser	   Objeto de cria��o do menu
@Param cThread   Posi��o da linha do Grid
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Objeto contendo o panel da fila de impress�o
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Return Nil
@author Cl�vis Eduardo Teixeira
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AtuFilaImp() CLASS TJurFilaImpressao

Self:oLstFila:SetArray(Self:ListaColImp(Self:oLstFila:aHeader, Self:cUser, Self:cThread))
Self:oLstFila:Refresh()

if LEN(Self:oLstFila:ACOLS) == 0
 	Self:oLstFila:Disable()
 	Self:cTipoFi := ""
Else
 	Self:oLstFila:Enable()
 	Self:ExibeFila()
Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} DelAllReg(cUser, cThread, oLstFila)
Fun��o para exclus�o de todos os registros da fila de impress�o
Uso Geral
@Param cUser	   C�digo do usu�rio do sistema
@Param cThread   C�digo da Thread
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Obejto contendo o panel da fila de impress�o
@Param oPanelPai Obejto contendo o panel da pesquisa de processo
@Return lRet
@author Cl�vis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD DelAllReg() CLASS TJurFilaImpressao
Local lRet 		 := .T.
Local cSQLNQ3	 := ""

// Verifica se h� mais de um item na fila
If Len(Self:oLstFila:aCols) > 0 

	cSQLNQ3 += "DELETE FROM "+RetSqlName("NQ3")+" "
	cSQLNQ3 += "WHERE NQ3_FILIAL='"+xFilial("NQ3")+"' AND "
	cSQLNQ3 += "NQ3_CUSER='"+Self:cUser+"' AND "
	cSQLNQ3 += "NQ3_SECAO='"+Self:cThread+"' "

	//Limpa a hashtable com os itens
	If TcSqlExec(cSQLNQ3) >= 0
		HMClean(Self:oItens)
	EndIf
Endif

If Self:oLstFila != NIL
	//Atualiza a fila de impress�o
	Self:AtuFilaImp()
	Self:EscondeFila()
	aSize(Self:oLstFila:aCols,0)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} OpcAddFila(cCajur, cUser, cThread, oLstFila, oPnlFila, oSplPesqL, cOpcFila)
Fun��o para informar os parametros do relat�rio de processo
Uso Geral
@ParamcCajur     C�digo do Assunto Jur�dico
@Param cUser	   C�digo do usu�rio
@Param cThread   C�digo da Thread
@Param oLstFila  ListBox da fila de impress�o
@Param oPnlFila  Objeto contendo o panel da fila de impress�o
@Param oSplPesqL Objeto da pesquisa SQL
@Param cOpcFila  Op��o selecionado pelo usu�rio no
@Return Nil
@author Cl�vis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD OpcAddFila(cCajur, cOpcFila, lDes, lVinc, cFili, cTipoAs) CLASS TJurFilaImpressao
Local aArea := GetArea()
Local cOpc  := IIF(!Empty(cOpcFila), SubStr(cOpcFila,1,1) , '')
Local cCajurPai := ''

NQ3->(DBSetOrder(1))

If cOpc == '1'
  cCajurPai := JurCodPai(cCajur)
  Self:AddReg(cCajur, Self:cUser, Self:cThread, cFili, cTipoAs)
  Self:AddRegDes(cCajurPai, Self:cUser, Self:cThread, lDes, cFili, cTipoAs)

Elseif cOpc == '2'
  Self:AddRegVinc(cCajur, Self:cUser, Self:cThread, lVinc, cFili, cTipoAs)

Elseif cOpc == '3'
  cCajurPai := JurCodPai(cCajur)
  Self:AddReg(cCajur, Self:cUser, Self:cThread, cFili, cTipoAs)
  Self:AddRegDes(cCajurPai, Self:cUser, Self:cThread, lDes, cFili, cTipoAs)
  Self:AddRegVinc(cCajur, Self:cUser, Self:cThread, lVinc, cFili, cTipoAs)

Else
  Self:AddReg(cCajur,Self:cUser, Self:cThread, cFili, cTipoAs )
Endif

//Atualiza a fila de impress�o
Self:AtuFilaImp()

//Sobe ao topo da lista da fila
Self:oLstFila:goTop()

RestArea(aArea)
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} AddRegDes(cCajur, cUser, cThread, oLstFila, oPanel,
                            oPanelPai, lDes)
Fun��o para adicionar os registros na fila de impress�o de processos
Uso Geral
@ParamcCajur     C�digo do Assunto Jur�dico
@Param cUser	   C�digo do usu�rio
@Param cThread   C�digo da Thread
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Objeto contendo o panel da fila de impress�o
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Param lDesAtivoCampo l�gico para considerar apenas desdobramentos ativos
@Return lRet
@author Cl�vis Eduardo Teixeira
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AddRegDes(cCajur, cUser, cThread, lDesAtivo, cFili, cTipoAs) CLASS TJurFilaImpressao
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local lRet		  := .T.

BeginSql Alias cAliasQry
	SELECT NSZ.NSZ_COD, NSZ.NSZ_SITUAC
	FROM %Table:NSZ% NSZ
	WHERE NSZ.NSZ_CPRORI = %Exp:cCajur%
	AND NSZ.NSZ_FILIAL = %xFilial:NSZ%
	AND NSZ.%notDEL%
EndSql
dbSelectArea(cAliasQry)

If (cAliasQry)->(EOF())
	If !lDesAtivo	//Flag - Incluir apenas desdobramento ativos?
		Self:AddReg(cCajur, cUser, cThread, cFili, cTipoAs)
	Elseif (cAliasQry)->NSZ_SITUAC = '1'
		Self:AddReg(cCajur, cUser, cThread, cFili, cTipoAs)
	Endif
Else
	While !(cAliasQry)->( EOF())
		if !lDesAtivo //Flag - Incluir apenas desdobramento ativos?
			lRet:=	Self:AddReg((cAliasQry)->NSZ_COD, cUser, cThread, cFili, cTipoAs)
		Elseif (cAliasQry)->NSZ_SITUAC = '1'
			lRet:=	Self:AddReg((cAliasQry)->NSZ_COD, cUser, cThread, cFili, cTipoAs)
		Endif

		If !lRet
			Exit
		EndIf
		Self:AddRegDes((cAliasQry)->NSZ_COD, cUser, cThread, lDesAtivo, cFili, cTipoAs)
		(cAliasQry)->( dbSkip())
	End //End While
End

(cAliasQry)->(dbCloseArea())

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddReg(cCajur, cUser, cThread, oLstFila, oPanel, cFilBrw, cTipoAs)
Fun��o para adicionar os registros na fila de impress�o de processos
Uso Geral
@ParamcCajur     C�digo do Assunto Jur�dico
@Param cUser	   C�digo do usu�rio
@Param cThread   C�digo da Thread
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Objeto contendo o panel da fila de impress�o
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Param cFilBrw   Filial do assunto jur�dico que ser� inclu�do na fila
@Param cTipoAs	 Tipo do assunto jur�dico que ser� inclu�do na fila
, nLinha
@Return lRet
@author Cl�vis Eduardo Teixeira
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AddReg(cCajur, cUser, cThread, cFilBrw, cTipoAs, lValida) CLASS TJurFilaImpressao
Local lRet    := .T.
Local nHash	  := 0 //tempor�rio. n�o � de fato utilizado.
Local cSQL := ""

Default lValida := .T.

If !lValida .Or. !HMGet(Self:oItens, (cFilBrw + cCajur + cUser + cThread), nHash)                                                                                 

	If Self:JVldFila(cTipoAs, Self:cTipoFi)
			
			if (Self:lAutRec) //valida se o autorecno est� habilitado
				//monta o insert
				cSQL := "INSERT INTO " + RetSqlName("NQ3") + "(NQ3_FILIAL,NQ3_CAJURI,NQ3_CUSER,NQ3_SECAO,NQ3_FILORI, D_E_L_E_T_) VALUES ("
				cSQL += "'" + Self:cFilNQ3 + "','" + cCajur + "','" + cUser + "','" + cThread + "','" + cFilBrw + "', ' ')"
				
				If tcSQLExec(cSQL) == 0
					lRet := .T.
				Else
					lRet := .F.
				Endif
			Else
				NQ3->( dbSetOrder( 1 ) )
				NSZ ->(DBSetOrder(1))
				If NSZ->(dbSeek(cFilBrw + cCajur)) .AND. !NQ3->(dbSeek(xFilial("NQ3")+cFilBrw + cCajur + cUser + cThread)) // Verifica se o processo existe E se o registro ja n�o esta presente naquela se��o
					If RecLock('NQ3',.T. )
						NQ3->NQ3_FILIAL := xFilial("NQ3")
						NQ3->NQ3_CAJURI := cCajur
						NQ3->NQ3_CUSER  := cUser
						NQ3->NQ3_SECAO  := cThread
						NQ3->NQ3_FILORI := cFilBrw
						NQ3-> (MsUnlock())
					
						lRet := .T.
					Else
						lRet := .F.
					Endif
				EndIf
			Endif
			
			If lRet //valida se a inclus�o na fila ocorreu com sucesso
			
				If Self:lBlLstg .And. ExistBlock("J162LstG") // novo PE Flavio.
					ExecBlock('J162LstG',.F.,.F.,{cCajur,cUser,cThread,NQ3->(Recno())})
				Else
					Self:lBlLstg := .F. //seta que n�o existe o c�digo para poupar tempo de processamento.
				EndIf
				
				//Se tiver vazio, preenche o assunto da fila.
				if Empty(Self:cTipoFi)
					Self:cTipoFi := cTipoAs
				Endif
				
				//Inclui o registro na lista
				HMSet(Self:oItens, (cFilBrw+cCajur+cUser+cThread),nHash)

			Else
				lRet := .F.
				JurMsgErro(STR0015) //"Erro ao incluir os registros na fila de impress�o"
			Endif
	Else
		lRet:=	.F. //Tipo de assunto diferente.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JU162VldFila(cCajur, cUser, cThread, oLstFila, oPanel, oPanelPai)
Fun��o para adicionar os registros na fila de impress�o de processos
Uso Geral
@ParamcCajur     C�digo do Assunto Jur�dico
@Param cUser	   C�digo do usu�rio
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Return lRet
@author Cl�vis Eduardo Teixeira
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD JVldFila(cTipoAs, cTipoFi) CLASS TJurFilaImpressao
Local lRet := .T.

  if !Empty(cTipoFi)
	  if cTipoAs <> cTipoFi
  	  JurMsgErro(STR0016) //'N�o � possivel incluir processos de assunto juridicos diferentes na fila de impress�o.'
    	lRet := .F.
  	Endif
  Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AddRegVinc(cCajur, cUser, cThread, oLstFila, oPanel, oPanelPai)
Fun��o para adicionar os registros na fila de impress�o de processos
Uso Geral
@ParamcCajur     C�digo do Assunto Jur�dico
@Param cUser	   C�digo do usu�rio
@Param cThread   C�digo da Thread
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Objeto contendo o panel da fila de impress�o
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Param lVinc     Campo l�gico para considerar processso vinculados ativos
@Return lRet
@author Cl�vis Eduardo Teixeira
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AddRegVinc(cCajur, cUser, cThread, lVinc, cFili, cTipoAs) CLASS TJurFilaImpressao
Local aArea     := GetArea()
Local cAliasQry := GetNextAlias()
Local lRet		:=	.T.

BeginSql Alias cAliasQry
	SELECT NVO.NVO_CAJUR2, NSZ.NSZ_SITUAC
	FROM %Table:NVO% NVO,
	%Table:NSZ% NSZ
	WHERE NVO.NVO_CAJUR1 = %Exp:cCajur%
	AND NSZ.NSZ_COD    = NVO.NVO_CAJUR2
	AND NVO.NVO_FILIAL = %xFilial:NVO%
	AND NSZ.NSZ_FILIAL = %xFilial:NSZ%
	AND NVO.%notDEL%
	AND NSZ.%notDEL%
EndSql
dbSelectArea(cAliasQry)

While !(cAliasQry)->( EOF())

	if !lVinc
		lRet:=	Self:AddReg((cAliasQry)->NVO_CAJUR2, cUser, cThread, cFili, cTipoAs)
	Elseif (cAliasQry)->NSZ_SITUAC = '1'
		lRet:=	Self:AddReg((cAliasQry)->NVO_CAJUR2, cUser, cThread, cFili, cTipoAs)
	Endif

	If  !lRet
		Exit
	EndIf

	(cAliasQry)->( dbSkip())
End

Self:AddReg(cCajur, cUser, cThread, cFili, cTipoAs)

(cAliasQry)->(dbCloseArea())

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} DelReg(cCajur, cUser, cThread, oLstFila, oPanel, oPanelPai)
Fun��o para exclus�o de um �nico registro da fila de impress�o
Uso Geral
@Param cCajur    C�digo do assunto jur�dico
@Param cUser	   C�digo do usu�rio
@Param cThread   C�digo da Thread
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Obejto contendo o panel da fila de impress�o
@Param oPanelPai Obejto contendo o panel da pesquisa de processo
@Return lRet
@author Cl�vis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD DelReg() CLASS TJurFilaImpressao 
Local lRet := .T.

NQ3->(dbSetOrder(1))

If NQ3->( dbSeek(Self:cFilNQ3 + Self:getFilial() +Self:getCajuri() +Self:cUser +Self:cThread ))
	Reclock( 'NQ3', .F. )
	dbDelete()
	MsUnlock()
	
	//remove o item da lista
	HMDel(Self:oItens, (Self:getFilial() +Self:getCajuri()+Self:cUser+Self:cThread))
EndIf

//Atualiza a fila de impress�o
Self:AtuFilaImp()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibeFila()
Fun��o para controle da visualiza��o do grid de fila de impress�o
Uso Geral
@Param oPanelPai Obejto contendo o panel da pesquisa de processo
@Param oPanel    Obejto contendo o panel da fila de impress�o
@author Cl�vis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD ExibeFila() CLASS TJurFilaImpressao
Self:oPnlFila:NHEIGHT := 150
Self:oPnlFila:Show()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ExibeFila()
Fun��o para controle da visualiza��o do grid de fila de impress�o
Uso Geral
@Param oPanelPai Obejto contendo o panel da pesquisa de processo
@Param oPanel    Obejto contendo o panel da fila de impress�o
@author Cl�vis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD EscondeFila() CLASS TJurFilaImpressao
Self:oPnlFila:Hide()
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuPopPesqu 
oObj, nRow, nCol, oLstPesq, oLstFila,
                              oSplPesqL, oPnlFila, cUser, cThread, lDes, lVinc)
Fun��o utilizada para o menu pop up
Uso Geral
@Param	oObj	Objeto de cria��o do menu
@Param	nRow  Posi��o da linha do Grid
@Return nCol	Posi��o da coluna do Grid
@author Cl�vis Eduardo Teixeira
@since 14/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD MenuPopPesq(oObj, nRow, nCol, oLstPesq, cOpcFila, lDes, lVinc) CLASS TJurFilaImpressao
Local aArea  := GetArea()
Local oMenu
Local oMenuItem := {}

If Len(oLstPesq:aCols) > 0 

	MENU oMenu POPUP of oObj
		aAdd(oMenuItem, MenuAddItem(STR0017,,, .T.,,,'PGNEXT_MDI.PNG',oMenu,{||Self:OpcAddFila(Self:oPesquisa:getCodigo(),; //"Inserir o processo na fila de impress�o"
									cOpcFila, lDes, lVinc, Self:oPesquisa:getFilial(), Self:oPesquisa:JA162Assjur("NSZ_TIPOAS"))},,,,,{||.T.} ))
		aAdd(oMenuItem, MenuAddItem(STR0018,,, .T.,,,'BOTTOM_MDI.PNG',oMenu,{|| MsgRun(STR0019,STR0006,; // "Incluindo registros na fila..." "Fila de Impress�o" 		
		{||Self:AddAllReg(Self:cUser, Self:cThread, oLstPesq,; //"Inserir todos os processos na fila de impress�o"
									lDes, lVinc, cOpcFila, Self:oPesquisa)})},,,,,{||.T.} ))
	ENDMENU
	
	If JurVerSCHtml("N") < 23016 .AND. (GetRemoteType() == 5)// Se vers�o smartClient HTML
		ACTIVATE POPUP oMenu AT nRow+100, nCol+480
	Else
		ACTIVATE POPUP oMenu AT nRow, nCol+10
	EndIF

EndIf

RestArea(aArea)

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} AddAllReg(cUser, cThread, oLstPesq, oLstFila, oPanel, oPanelPai)
Fun��o para adicionar os registros na fila de impress�o de processos
Uso Geral
@Param cUser	   C�digo do usu�rio
@Param cThread   C�digo da Thread
@ParamoLstPesq   ListBox da pesquisa de processo
@Param oLstFila  ListBox da fila de impress�o
@Param oPanel    Objeto contendo o panel da fila de impress�o
@Param oPanelPai Objeto contendo o panel da pesquisa de processo
@Return lRet
@author Cl�vis Eduardo Teixeira
@since 30/12/09
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD AddAllReg(cUser, cThread, oLstPesq, lDes, lVinc, cOpcFila, oPesquisa) CLASS TJurFilaImpressao
Local aArea     := GetArea()
Local cOpc      := IIF(!Empty(cOpcFila), SubStr(cOpcFila,1,1) , '')
Local cCajurPai := ''
Local lRet 		:= .T.
Local nI, nHash
Local lValida := Self:__nCntNQ3>0
Local cAlQry
Local cSQL := ""

If cOpc == '1'

	oPesquisa:fillGrid() //garantir que todos os registros estejam no grid

	For nI := 1 To Len(oLstPesq:aCols)
		cCajurPai := JurCodPai(oPesquisa:getCodigo(nI))
		If !Self:AddReg(oPesquisa:getCodigo(nI), cUser, cThread, oPesquisa:getFilial(nI),oPesquisa:JA162Assjur("NSZ_TIPOAS",nI),lValida)
			Exit
		EndIf
		Self:AddRegDes(cCajurPai, cUser, cThread, lDes,oPesquisa:getFilial(nI),oPesquisa:JA162Assjur("NSZ_TIPOAS",nI) )
	Next

Elseif cOpc == '2'

	oPesquisa:fillGrid() //garantir que todos os registros estejam no grid
	
	For nI := 1 To Len(oLstPesq:aCols)
		Self:AddRegVinc(oPesquisa:getCodigo(nI), cUser, cThread, lVinc, oPesquisa:getFilial(nI),oPesquisa:JA162Assjur("NSZ_TIPOAS",nI))
	Next

Elseif cOpc == '3'

	oPesquisa:fillGrid() //garantir que todos os registros estejam no grid
	
	For nI := 1 To Len(oLstPesq:aCols)
		cCajurPai := JurCodPai(oPesquisa:getCodigo(nI))
		if !Self:AddReg(oPesquisa:getCodigo(nI), cUser, cThread, oPesquisa:getFilial(nI),oPesquisa:JA162Assjur("NSZ_TIPOAS",nI),lValida)
			Exit
		EndIf
		Self:AddRegDes(cCajurPai, cUser, cThread, lDes, oPesquisa:getFilial(nI),oPesquisa:JA162Assjur("NSZ_TIPOAS",nI))
		Self:AddRegVinc(oPesquisa:getCodigo(nI), cUser, cThread, lVinc, oPesquisa:getFilial(nI),oPesquisa:JA162Assjur("NSZ_TIPOAS",nI))
	Next

Else

	if (Self:lAutRec) //valida se o autorecno est� habilitado
		
		//se n�o esta usando nenhum filtro, vamos mudar para fazer um insert s�.
		cSqlFila := "INSERT INTO " + RetSqlName("NQ3") + "(NQ3_FILIAL,NQ3_CAJURI,NQ3_CUSER,NQ3_SECAO,NQ3_FILORI, D_E_L_E_T_ ) "
		cSqlFila += " SELECT DISTINCT '" + Self:cFilNQ3 + "', "
		cSqlFila +=        " NSZ_COD, "
		cSqlFila +=        "'" + cUser + "',"
		cSqlFila +=        "'" + cThread + "', "
		cSqlFila +=        " NSZ_FILIAL, "
		cSqlFila +=        " ' ' D_E_L_E_T_ "
		cSqlFila += " " + right(Self:oPesquisa:cSQLFeito,1+len(Self:oPesquisa:cSQLFeito)-at("FROM",Self:oPesquisa:cSQLFeito))
		cSqlFila := Left(cSqlFila,At("ORDER BY",cSqlFila)-1)
		cSqlFila += " AND NSZ_TIPOAS = '" + oPesquisa:JA162Assjur("NSZ_TIPOAS",nI) + "'"
		cSqlFila += " AND NOT EXISTS (SELECT 1 FROM " + RetSqlName("NQ3") + " WHERE NQ3_CAJURI = NSZ_COD AND NQ3_CUSER = '" + cUser + "' AND NQ3_SECAO = '" + cThread + "' AND NQ3_FILORI = NSZ_FILIAL AND D_E_L_E_T_ = ' ')" 
		
		If tcSQLExec(cSqlFila) == 0
			lRet := .T.
			//Inclui o registro na lista
			cAlQry := GetNextAlias()
			
			cSQL := "SELECT NQ3_CAJURI,NQ3_FILORI"
			cSQL +=  " FROM " + RetSqlName('NQ3') + ' NQ3 '
			cSQL += " WHERE NQ3_CUSER  = " + "'" + cUser + "' "
			cSQL +=   " AND NQ3_FILIAL = '" + Self:cFilNQ3 + "' "
			cSQL +=   " AND NQ3_SECAO  = " + "'" + cThread + "' "
			cSQL +=   " AND D_E_L_E_T_ = ' ' "
			
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T., 'TOPCONN', TcGenQry( ,, cSQL ) , cAlQry, .T., .F.)
			
			While (cAlQry)->(!Eof())
				HMSet(Self:oItens, ((cAlQry)->NQ3_FILORI+(cAlQry)->NQ3_CAJURI+cUser+cThread),nHash)
				(cAlQry)->(DBSkip())
			End
			
			(cAlQry)->( dbcloseArea() )
			
		Else
			lRet := .F.
			JurMsgErro(STR0015) //"Erro ao incluir os registros na fila de impress�o"
		Endif
	Else	
		oPesquisa:fillGrid() //garantir que todos os registros estejam no grid
		
		For nI := 1 To Len(oLstPesq:aCols)
		  If !Self:AddReg(oPesquisa:getCodigo(nI), cUser, cThread, oPesquisa:getFilial(nI),oPesquisa:JA162Assjur("NSZ_TIPOAS",nI),lValida)
		   Exit
		  EndIf
		Next nI
	Endif

Endif

//Atualiza a fila de impress�o
Self:AtuFilaImp()

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DeActivate()
Libera os componentes utilizados 
@author Andr� Spirigoni Pinto
@since 09/11/15
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD DeActivate() CLASS TJurFilaImpressao

	Self:DelAllReg()
	
	If Self:oPanel != Nil
		Self:oPanel:Destroy()
		Self:oPanel := Nil
	Endif
	
	If Self:oPnlFila != Nil
		Self:oPnlFila:Destroy()
		Self:oPnlFila := Nil
	Endif
	
	aSize(Self:oLstFila:aCols,0) //limpa o array
	
	Self:oLstFila:DeActivate()
	
	//valida se o alias ainda est� ativo
	If select(Self:cAlQry)>0 
		(Self:cAlQry)->( dbcloseArea() )
	Endif 
	
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LstHeadFila()
Fun��o utilizada para configurar o cabe�alho da lista
Uso Geral.
@Return	aHead	Array com o cabe�alho
@author Cl�vis Eduardo Teixeira
@since 05/01/2010
@version 1.0
/*/
//-------------------------------------------------------------------
METHOD LstHeadFila() CLASS TJurFilaImpressao
Local aArea   := GetArea()
Local aHead   := {}
Local nI
Local aCampos := {"NQ3_FILORI","NQ3_CAJURI","NQ3_CUSER","NQ3_SECAO"}

If  ExistBlock("J162LstF")   //Incluir campos na fila de impress�o.
    aCampos := ExecBlock("J162LstF",.F.,.F.,{aCampos})
EndIf

For nI := 1 To Len(aCampos)
	If X3USO(  GetSX3Cache(aCampos[nI], "X3_USADO") ) .AND. GetSX3Cache(aCampos[nI], "X3_NIVEL") >= 1
		aAdd(aHead, {aCampos[nI], JA160X3Des(aCampos[nI]), "NQ3","NQ3001", Nil, "NQ3", "NQ3001", aCampos[nI], .T.} )  
	EndIf
Next nI
	 
RestArea(aArea)

Return aHead
