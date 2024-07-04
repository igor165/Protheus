#INCLUDE "qipc020.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPC020  � Autor � Marcelo Pimentel      � Data � 13/07/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Rastreabilidade do Produto                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef()

Local aRotina := {	{STR0002,"AxPesqui"		, 0 , 1},; //"Pesquisar"
					{STR0003,"QpC020ras"	, 0 , 2},; //"Rastrear"
					{STR0004,"Qpc020leg"	, 0 ,6,,.F.} } //"Legenda"
					
Return aRotina

Function QipC020()
LOCAL cCond			:=""
PRIVATE cCadastro	:=STR0001 //"Rastreabilidade"
PRIVATE __cPRODUTO := CriaVar("QP6_PRODUT") //Codigo do Produto, quando a Especificacao for em Grupo      
PRIVATE lProduto   := .F.

If Pergunte("QPC020",.T.)
	//��������������������������������������������������������������Ŀ
	//� Define Array contendo as Rotinas a executar do programa      �
	//� ----------- Elementos contidos por dimensao ------------     �
	//� 1. Nome a aparecer no cabecalho                              �
	//� 2. Nome da Rotina associada                                  �
	//� 3. Usado pela rotina                                         �
	//� 4. Tipo de Transa��o a ser efetuada                          �
	//�    1 -Pesquisa e Posiciona em um Banco de Dados              �
	//�    2 -Simplesmente Mostra os Campos                          �
	//�    3 -Inclui registros no Bancos de Dados                    �
	//�    4 -Altera o registro corrente                             �
	//�    5 -Estorna registro selecionado gerando uma contra-partida�
	//����������������������������������������������������������������
	Private aRotina := MenuDef()

	cCond := "QP6->QP6_PRODUT>='" +mv_par01 + "'"
	cCond += ".AND. QP6->QP6_PRODUT<='" +mv_par02 + "'"

	dbSelectArea("QP6")
	dbSetOrder(1)
	MsgRun(STR0005,STR0006,{||dbSetFilter({||&cCond},cCond)}) //"Selecionando os Produtos..."###"Aguarde..."
	
	dbGoTop()
	If Eof()
		Help(" ",1,"RECNO")   
	Else
		//��������������������������������������������������������������Ŀ
		//� Endereca a funcao de BROWSE                                  �
		//����������������������������������������������������������������
		mBrowse( 6, 1,22,75,"QP6",,,,,, Qpc020leg())
	EndIf
	dbSelectArea("QP6")
	Set Filter To
EndIf
Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QpC020ras � Autor � Marcelo Pimentel      � Data � 13/05/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a dialog da Rastreabilidade do Produto posicionado   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QpC020ras()
LOCAL oTree
LOCAL oDlg
LOCAL oFont
LOCAL oPanel
LOCAL oPanel1
LOCAL oLbx
LOCAL nTop			:= oMainWnd:nTop+23
LOCAL nLeft			:= 5 //oMainWnd:nLeft+5
LOCAL nBottom		:= oMainWnd:nBottom-60
LOCAL nRight		:= oMainWnd:nRight-20  //oMainWnd:nRight-10
LOCAL nOldEnch		:= 1
LOCAL bChange		:= {|| Nil }
LOCAL aFields		:= {}
Local aCampos		:= {}
LOCAL nC			:= 0
LOCAL aDados		:= {}
LOCAL aPos     		:= {0,0,((nBottom-nTop)/2)-24,(nRight-nLeft)/2-130} //codeblock
LOCAL aDadosQPK		:= {}
LOCAL nCount		:= 0
LOCAL cDados		:= ""
PRIVATE aEnch[2]
PRIVATE aSVAlias	:= {}
PRIVATE aRegs		:= {}
Private oScroll

//������������������������������������������������������Ŀ
//� Carrega as variaveis de memoria do QP6               �
//��������������������������������������������������������
AADD(aSVAlias,"QP6")
RegToMemory("QP6",.F.)
//������������������������������������������������������Ŀ
//� Exibe informacoes do Produto						 �
//��������������������������������������������������������
For nC := 1 To FCount()
	If FieldName(nC) $ "QP6_PRODUT.QP6_REVI.QP6_DESCPO.QP6_CROQUI.QP6_DTINI.QP6_PTOLER.QP6_TIPO.QP6_SITPRD.QP6_DESSTP"
		If ValType(&(FieldName(nC))) == "D"
			cDados := Dtoc(FieldGet(nC))
		ElseIf ValType(&(FieldName(nC))) == "N"
			cDados := Str(FieldGet(nC))
		Else
			cDados := FieldGet(nC)
		EndIf
		AADD(aDados,{RetTitle(FieldName(nC)),cDados})
	EndIf
Next nC

dbSelectArea("QPK")
dbSetOrder(2)
dbSeek(xFilial("QPK")+QP6->QP6_PRODUT)
While !Eof() .And. xFilial("QPK") == QPK->QPK_FILIAL .And. QPK->QPK_PRODUT == QP6->QP6_PRODUT
	If QPK->QPK_REVI == QP6->QP6_REVI
		nRecnoQPK:= Recno()
		nCount++
		
		//���������������������������������������������������������������������������Ŀ
		//� Cria Array com as Ordens de Producoes que utilizam o produto selecionado  �
		//�����������������������������������������������������������������������������
		AADD(aDadosQPK,{QPK->QPK_OP,"QPK",StrZero(nRecnoQPK,12),;
		QPK->QPK_PRODUT,QP6->QP6_CODREC,QPK->QPK_LOTE,QPK->QPK_NUMSER})
	Endif
	DbSkip()
EndDo	

DEFINE FONT oFont NAME "Arial" SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
oFolder := TFolder():New(12,0,{STR0007},{},oDlg,,,, .T., .F.,Iif(!setMDIChild(),nRight-nLeft,nRight-nLeft-500),Iif(!setMDIChild(),nBottom-nTop-12,nBottom-nTop-300),) //"Consulta"
oFolder:aDialogs[1]:oFont := oDlg:oFont
oTree := dbTree():New(2, 2,((nBottom-nTop)/2)-34,159,oFolder:aDialogs[1],,,.T.)
//������������������������������������������������������Ŀ
//� Monta Tree dos Produtos                              �
//��������������������������������������������������������
QPC020Tree(@oTree,aDadosQPK,"QPK",.T.)
lOneColumn := If((nRight-nLeft)/2-178>312,.F.,.T.)
oPanel := TPanel():New(2,160,'',oFolder:aDialogs[1], oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-160,((nBottom-nTop)/2)-35,.T.,.T. )
//������������������������������������������������������Ŀ
//� Panel das movimentacoes da Rastreabilidade           �
//��������������������������������������������������������
oPanel1:= TPanel():New(2,160,'',oFolder:aDialogs[1], oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-160,((nBottom-nTop)/2)-35,.T.,.T. )
//������������������������������������������������������Ŀ
//� Campos que devem aparecer na Enchoice                �
//��������������������������������������������������������
aFields	:= {}
aCampos := {"QPK_OP","QPK_LOTE","QPK_NUMSER","QPK_PRODUT","QPK_REVI","QPK_TAMLOT","QPK_UM","QPK_DTPROD",;
			"QPK_EMISSA","QPK_LAUDO","QPK_CERQUA"}

For nC := 1 To Len(aCampos)
	Aadd(aFields,aCampos[nC])
Next nC

AADD(aSVAlias,"QPK")
RegToMemory("QPK",.F.)
aEnch[1]:= MsMGet():New("QPK",QPK->(RecNo()),2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
aEnch[1]:Hide()
aCampos := {}
AADD(aDados,{"",""})
AADD(aDados,{STR0008,AllTrim(Str(nCount))}) //"OPs vinculadas ao Produto"
AADD(aDados,{"",""})
oScroll:= TScrollBox():New(oPanel,aPos[1],aPos[2],aPos[3],aPos[4])
QPScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})

//������������������������������������������������������Ŀ
//� Cria uma linha na ListBox em Branco                  �
//��������������������������������������������������������
AADD(aRegs,{'','','','','','','',''})

//������������������������������������������������������Ŀ
//� Monta LisBox das movimentacoes da Rastreabilidade    �
//��������������������������������������������������������
@ 28,2 LISTBOX oLbx FIELDS HEADER ;
RetTitle("QQG_ORIGEM"),;
RetTitle("QQG_PRODUT"),;
RetTitle("QQG_DESC"),;
RetTitle("QQG_LOTE"),;
RetTitle("QQG_LAUDO"),;
RetTitle("QQG_QTDE"),;
RetTitle("QQG_TIPO");
COLSIZES 60,60,130,60,30,30,250;
SIZE (nRight-nLeft)/2-164,((nBottom-nTop)/2)-55  OF oPanel1 PIXEL

oLbx:SetArray(aRegs)
oLbx:bLDblClick := { || QPC020VDet(aRegs,oLbx:nAT)}
oLbx:bLine := {|| {aRegs[oLbx:nAT,1],aRegs[oLbx:nAT,2],aRegs[oLbx:nAT,3],aRegs[oLbx:nAT,4],aRegs[oLbx:nAT,5],aRegs[oLbx:nAT,6],aRegs[oLbx:nAT,7]}}
oLbx:Hide()
oPanel1:Hide()

oTree:bChange := {|| QPC020View(@oTree,aSValias,aPos,@nOldEnch,@oPanel,@oScroll,@oLbx,@oPanel1),Eval(bChange)}
oTree:SetFont(oFont)
DbSelectArea(oTree:cArqTree)
DbGotop()
oTree:TreeSeek(T_CARGO)
oTree:Refresh()
aCampos	:= {}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| DbSelectArea(oTree:cArqTree), oTree:EndTree(), oDlg:End()},{|| DbSelectArea(oTree:cArqTree), oTree:EndTree(), oDlg:End()})

//������������������������������������������������������Ŀ
//� Retorna a Ordem do QPK 							     �
//��������������������������������������������������������
dbSelectArea("QPK")
dbSetOrder(1)
Return(.T.)
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
��� Fun�ao   �QPC020Tree� Autor � Marcelo Pimentel      � Data � 26/07/2002 ���
���������������������������������������������������������������������������Ĵ��
��� Descri�ao� Funcao que monta o Tree da consulta da Rastreabilidade       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � QIPC020                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function QPC020Tree(oTree,aLinhas,cAlias,lTodos)
LOCAL aArea	   	:= GetArea()
LOCAL cOldCargo	:= oTree:GetCargo()
LOCAL nX		:= 0
LOCAL aOper		:= {}
LOCAL nC		:= 0
LOCAL cRevi		:= ""
DEFAULT cAlias := ''
DEFAULT lTodos := .F.

//���������������������������������Ŀ
//� Monta Tree na primeira vez    	�
//�����������������������������������
If Empty(cAlias) .And. !lTodos
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()
EndIf 

oTree:BeginUpdate()
oTree:TreeSeek("")
oTree:AddItem(RetTitle("QP6_PRODUT")+":"+QP6->QP6_PRODUT+Space(18),"01QP6"+StrZero(QP6->(Recno()),12),"BMPCONS","BMPCONS",,,1)
//����������������������������������������������������������������Ŀ
//� Monta  Tree baseado nos dados do QPK						   �
//������������������������������������������������������������������
AADD(aSVAlias,"QQG")

For nX := 1 To Len(aLinhas)
	oTree:TreeSeek("01QP6"+StrZero(QP6->(Recno()),12))
	oTree:AddItem(STR0009+aLinhas[nX,1]+STR0033+aLinhas[nX,6]+STR0034 +aLinhas[nX,7],"02QPK"+aLinhas[nX,3],"BMPTABLE","BMPTABLE",,,2) //"O.P.: "
	
	QPR->(dbSetOrder(9))
	If QPR->(dbSeek(xFilial("QPR")+aLinhas[nX,1]+aLinhas[nX,6]+aLinhas[nX,7]+QP6->QP6_CODREC))
		nRecnoQPR	:=QPR->(Recno())
		cRevi		:=QPR->QPR_REVI
	EndIf
	//���������������������������������Ŀ
	//� Monta  array das Operacoes  	�
	//�����������������������������������
	aOper := QPC020Ope(aLinhas[nX,4],aLinhas[nX,5],aLinhas[nX,1],cRevi)
	For nC := 1 To Len(aOper)
		QQG->(dbSelectArea("QQG"))
		QQG->(dbSetOrder(1))
		If QQG->(dbSeek(xFilial("QQG")+aLinhas[nX,1]+aOper[nC,1],.T.))
			oTree:TreeSeek("02QPK"+aLinhas[nX,3])
			oTree:AddItem(STR0010+aOper[nC,1]+" "+aOper[nC,2],"03QQG"+StrZero(QQG->(Recno()),12),"BMPTABLE","BMPTABLE",,,2) //"Operacao "
		EndIf
	Next nC
Next nX

oTree:EndUpdate()
oTree:Refresh()
If lTodos
	oTree:TreeSeek(cOldCargo)
EndIf
RestArea(aArea)
Return .T.
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC020View� Autor � Marcelo Pimentel      � Data � 26/07/2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao que exibe os movimentos do Produto                    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � QIPC020                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QPC020View(oTree,aSVAlias,aPos,nOldEnch,oPanel,oScroll,oLbx,oPanel1)
LOCAL cAlias	:= SubStr(oTree:GetCargo(),3,3)
LOCAL nRecView	:= Val(SubStr(oTree:GetCargo(),6,12))
LOCAL nPosAlias	:= aScan(aSVAlias,cAlias)
LOCAL cRastro	:= ''
LOCAL cLote		:= ''
LOCAL cLaudo	:= ''
LOCAL nQtde		:= ''
LOCAL cOperac	:= ''
LOCAL cOP		:= ''
LOCAL aAreaQQG	:= {}

aRegs:={}
oLbx:Hide()
oPanel1:Hide()
oScroll:Hide()
dbSelectArea(cAlias)
MsGoto(nRecView)
aEnch[nOldEnch]:Hide()
RegToMemory(cAlias,.F.)
If nPosAlias > 0 
	Do Case
		Case cAlias == "QP6"
			//������������������������������������������������������Ŀ
			//� Exibe informacoes de Historico de Produtos			 �
			//��������������������������������������������������������
			oScroll:Show()
		Case cAlias == "QPK"
			aEnch[1]:EnchRefreshAll()
			aEnch[1]:Show()
			nOldEnch:=1
		Case cAlias == "QQG"
			aAreaQQG	:= GetArea()
			cRastro		:= QQG->QQG_RASTRO
			cLote		:= QQG->QQG_LOTE
			cLaudo		:= QQG->QQG_LAUDO
			nQtde		:= QQG->QQG_QTDE
			cOperac		:= QQG->QQG_OPERAC
			cOP			:= QQG->QQG_OP
			While QQG->(!Eof()) .And. xFilial("QQG") == QQG->QQG_FILIAL .And. ;
				QQG->QQG_OP		== cOP		.And.;
				QQG->QQG_RASTRO == cRastro	.And.;
				QQG->QQG_OPERAC == cOperac
				Aadd(aRegs,{X3COMBO("QQG_ORIGEM",QQG->QQG_ORIGEM),QQG->QQG_PRODUT,A010DProd(QQG->QQG_PRODUT),;
				QQG->QQG_LOTE,QQG->QQG_LAUDO,QQG->QQG_QTDE,QQG->QQG_TIPO,QQG->QQG_ORIGEM})
				QQG->(dbSkip())
			EndDo
			@ 07,2    SAY   Iif(Len(AllTrim(Alias())) == 0,;
							{DbSelectArea("QQG"),RetTitle("QP6_PRODUT")+":"},; // Inserido devido a problemas de mudanca de Tela
							RetTitle("QP6_PRODUT")+":")  OF oPanel1 SIZE 30,8 PIXEL
			@ 07,30   MSGET oRastro VAR A010DProd(cRastro) OF oPanel1 SIZE 206,8 PIXEL When .F.
			oRastro:cSX1Hlp := "QQG_RASTRO"
						
			oLbx:SetArray(aRegs)
			oLbx:bLine := {|| {aRegs[oLbx:nAT,1],aRegs[oLbx:nAT,2],aRegs[oLbx:nAT,3],aRegs[oLbx:nAT,4],aRegs[oLbx:nAT,5],aRegs[oLbx:nAT,6],aRegs[oLbx:nAT,7]} }
			oLbx:Show()
			oPanel1:Show()
			oLbx:Refresh()
			RestArea(aAreaQQG)
	EndCase
Else
	oPanel:Hide()
	Do Case
		Case cAlias == "QPK "
			aAdd(aSVAlias,"QPK")
			aEnch[1]:= MsMGet():New("QPK",QPK->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
			aEnch[1]:EnchRefreshAll()
			nOldEnch:=1
	EndCase		
EndIf
oPanel:Refresh()
oScroll:Refresh()
Return .T.
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC020Ope  � Autor �Marcelo Pimentel      � Data � 28-06-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta vetor para o Roteiro das Operacoes					    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QPC020Ope(cProduto,cRoteiro,cOrdProd,cRevi)

LOCAL cQuery			:= ''
LOCAL aOper				:= {}
LOCAL aArea				:= GetArea()

//���������������������������������Ŀ
//� Adiciona em array as Operacoes  �
//�����������������������������������
dbSelectArea("QQK")
dbSetOrder(1)
cQuery := "SELECT QQK_FILIAL, QQK_PRODUT, QQK_CODIGO, QQK_OPERAC, QQK_DESCRI, QQK_RECURS, QQK_OPE_OB, QQK_SEQ_OB, QQK_LAU_OB"
cQuery += " FROM " + RetSqlName("QQK")
cQuery += " QQK WHERE QQK_FILIAL = '" + xFilial("QQK") + "' AND "
cQuery += " QQK.QQK_PRODUT = '" + cProduto + "' AND "
cQuery += " QQK.QQK_CODIGO = '" + cRoteiro + "' AND " 
cQuery += " QQK.QQK_REVIPR = '" + cRevi + "'AND " 
    cQuery += " QQK.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(QQK->(IndexKey()))
		
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"QIPTRB", .F., .T.)
dbSelectArea("QIPTRB")
While !Eof()
	Aadd(aOper,{ QIPTRB->QQK_OPERAC, QIPTRB->QQK_DESCRI, QIPTRB->QQK_RECURS, QIPTRB->QQK_OPE_OB, QIPTRB->QQK_SEQ_OB, QIPTRB->QQK_LAU_OB })
	cOpera := QIPTRB->QQK_OPERAC
	dbSkip()
Enddo
dbCloseArea()
RestArea(aArea)

RestArea(aARea)
Return(aOper)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Qpc020leg  � Autor � Marcelo Pimentel     � Data �25.07.2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse ou retorna a ���
���          � para o BROWSE                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Qpc020leg(cAlias, nReg)
LOCAL aLegenda := {	{"BR_CINZA"	,STR0011 },;	//"Sem Resultados"
					{"BR_AZUL"	,STR0012 }}		//"Com Resultados"
					
LOCAL uRetorno := .T.
If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, { 'EMPTY(QP6->QP6_RESULT)'	, aLegenda[1][1] })
	Aadd(uRetorno, { '!EMPTY(QP6->QP6_RESULT)'	, aLegenda[2][1] })
Else
	BrwLegenda(STR0001, STR0004 , aLegenda) //"Rastreabilidade"###"Legenda"
Endif
Return uRetorno

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC020VDet� Autor � Marcelo Pimentel      � Data � 01/08/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � visualizacao detalhada                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       �QIPC020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QPC020VDet(aRegs,nPos)

//�����������������������������������������������������������������Ŀ
//� Inspecao de Entrada                                             �
//�������������������������������������������������������������������
If aRegs[nPos,8] == "1"
	dbSelectArea('QEK')
	dbSetOrder(6)
	If dbSeek(xFilial('QEK')+aRegs[nPos,4])
		QPC020Vis(QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+QEK->QEK_ENTINV+QEK->QEK_LOTINV,"QIE")
	EndIf
	QEK->(dbSetOrder(1))
Else
	//�����������������������������������������������������������������Ŀ
	//� Inspecao de Processos                                           �
	//�������������������������������������������������������������������
	dbSelectArea('QPR')
	dbSetOrder(7)
	If dbSeek(xFilial('QPR')+aRegs[nPos,4])
		QPC020Vis(QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER,"QIP")
	EndIf
	QPR->(dbSetOrder(1))
EndIf
Return(NIL)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC020Vis � Autor � Marcelo Pimentel      � Data � 13/05/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a dialog da consulta                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQIP                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QPC020Vis(cChave,cOrigem)
LOCAL oTree
LOCAL oDlg
LOCAL oFont
LOCAL oPanel
LOCAL aEnch[5]
LOCAL nTop			:= oMainWnd:nTop+100
LOCAL nLeft			:= oMainWnd:nLeft+40
LOCAL nBottom		:= oMainWnd:nBottom-100
LOCAL nRight		:= oMainWnd:nRight-50
LOCAL nOldEnch		:= 1
LOCAL bChange		:= {|| Nil }
LOCAL lFoundQPLF	:=.F.		//Flag para informar se encontrou Laudo Final
LOCAL lFoundQPM 	:=.F.		//Flag para informar se encontrou Laudo da Operacao
LOCAL lFoundQPLL	:=.F.		//Flag para informar se encontrou Laudo do Laboratorio
LOCAL lFoundQELF	:=.F.
LOCAL lFoundQELL	:=.F.
LOCAL aFields		:= {}
LOCAL aSVAlias		:= {}
LOCAL aCampos		:= {}
LOCAL nC			:= 0
LOCAL nRecnoQPLL	:= 0
LOCAL nRecnoQPLF	:= 0
LOCAL nRecnoQPM		:= 0
LOCAL cLaborQPL		:= Criavar("QPL_LABOR")
LOCAL nRecnoQPR		:= 0
LOCAL cLaborQEL		:= Criavar("QEL_LABOR")
LOCAL nRecnoQER		:= 0
LOCAL nRecnoQELF	:= 0
LOCAL nRecnoQELL	:= 0

If cOrigem == "QIP"
	//������������������������������������������������������Ŀ
	//� Carrega as variaveis de memoria do QPK               �
	//��������������������������������������������������������
	dbSelectArea("QPK")
	dbSetOrder(1)
	dbSeek(xFilial("QPK")+cChave)
	
	AADD(aSVAlias,"QPK ")
	RegToMemory("QPK",.F.)
	
	dbSelectArea("QPR")
	dbSetOrder(9)
	dbSeek(xFilial("QPR")+QPK->QPK_OP+QPK->QPK_LOTE+QPK_NUMSER)
	nRecnoQPR:= Recno()
	                      
	//Posiciona QP6
	dbSelectArea("QP6")
	dbSetOrder(1)
	dbSeek(xFilial("QP6")+QPR->QPR_PRODUT+Inverte(QPR->QPR_REVI))
	
	//�����������������������������������������������������������������������Ŀ
	//� Posiciona para carregar variaveis de memoria do QPL - Laudo Final     �
	//� Executa esse processo para agilizar na visualizacao                   �
	//�������������������������������������������������������������������������
	dbSelectArea("QPL")
	dbSetOrder(3)
	lFoundQPLF:=dbSeek(xFilial("QPL")+QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER+QP6->QP6_CODREC+Space(02)+cLaborQPL,.T.)
	If lFoundQPLF
		nRecnoQPLF:=Recno()
	EndIf
	
	//�����������������������������������������������������������������������Ŀ
	//� Posiciona para carregar variaveis de memoria do QPL - Laudo Labor     �
	//� Executa esse processo para agilizar na visualizacao                   �
	//�������������������������������������������������������������������������
	dbSelectArea("QPL")
	dbSetOrder(1)
	lFoundQPLL:=dbSeek(xFilial("QPL")+QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER+QP6->QP6_CODREC+QPR->QPR_OPERAC+QPR->QPR_LABOR,.T.)
	If lFoundQPLL
		nRecnoQPLL:=Recno()
	EndIf
	
	//�����������������������������������������������������������������������Ŀ
	//� Posiciona para carregar variaveis de memoria do QPM - Laudo Operacao  �
	//� Executa esse processo para agilizar na visualizacao                   �
	//�������������������������������������������������������������������������
	dbSelectArea("QPM")
	dbSetOrder(1)
	lFoundQPM:=dbSeek(xFilial("QPM")+QPR->QPR_OP+QPR->QPR_LOTE+QPR->QPR_NUMSER+QP6->QP6_CODREC+QPR->QPR_OPERAC,.T.)
	If lFoundQPM
		nRecnoQPM:=Recno()
	EndIf
Else
	//������������������������������������������������������Ŀ
	//� Carrega as variaveis de memoria do QEK               �
	//��������������������������������������������������������
	dbSelectArea("QEK")
	dbSetOrder(1)
	dbSeek(xFilial("QEK")+cChave)
	
	AADD(aSVAlias,"QEK ")
	RegToMemory("QEK",.F.)
	
	dbSelectArea("QER")
	dbSetOrder(1)
	dbSeek(xFilial("QER")+QEK->QEK_PRODUT+QEK->QEK_REVI+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE)
	nRecnoQER:= Recno()
	
	//�����������������������������������������������������������������������Ŀ
	//� Posiciona para carregar variaveis de memoria do QEL - Laudo Final     �
	//� Executa esse processo para agilizar na visualizacao                   �
	//�������������������������������������������������������������������������
	dbSelectArea("QEL")
	dbSetOrder(1)
	lFoundQELF:=dbSeek(xFilial("QEL")+QER->QER_FORNEC+QER->QER_LOJFOR+QER->QER_PRODUT+;
	Dtos(QER->QER_DTENTR)+QER->QER_LOTE+cLaborQEL)
	If lFoundQELF
		nRecnoQELF:=Recno()
	EndIf
	
	//�����������������������������������������������������������������������Ŀ
	//� Posiciona para carregar variaveis de memoria do QEL - Laudo Labor     �
	//� Executa esse processo para agilizar na visualizacao                   �
	//�������������������������������������������������������������������������
	dbSelectArea("QEL")
	dbSetOrder(1)
	lFoundQELL:=dbSeek(xFilial("QEL")+QER->QER_FORNEC+QER->QER_LOJFOR+QER->QER_PRODUT+;
	Dtos(QER->QER_DTENTR)+QER->QER_LOTE+QER->QER_LABOR)
	If lFoundQELL
		nRecnoQELL:=Recno()
	EndIf
EndIf

DEFINE FONT oFont NAME "Arial" SIZE 0, -10
DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
oFolder := TFolder():New(12,0,{STR0013},{},oDlg,,,, .T., .F.,nRight-nLeft,nBottom-nTop-12,) //"Visualiza��o Detalhada"
oFolder:aDialogs[1]:oFont := oDlg:oFont
oTree := dbTree():New(2, 2,((nBottom-nTop)/2)-24,159,oFolder:aDialogs[1],,,.T.)
oTree:bChange := {|| QPC021DlgV(@oTree,aSValias,@aEnch,{0,0,((nBottom-nTop)/2)-24,(nRight-nLeft)/2-160},@nOldEnch,@oPanel,nRecnoQPLL,nRecnoQPLF,nRecnoQPR,nRecnoQPM,cOrigem,nRecnoQELL,nRecnoQELF,nRecnoQER),Eval(bChange)}
oTree:SetFont(oFont)
oPanel := TPanel():New(2,160,'',oFolder:aDialogs[1], oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-160,((nBottom-nTop)/2)-25,.T.,.T. )
QPC021Tree(@oTree,"",Iif(cOrigem == "QIP",nRecnoQPLF,nRecnoQELF),cOrigem)
lOneColumn := If((nRight-nLeft)/2-178>312,.F.,.T.)

If cOrigem == "QIP"
	If lFoundQPLF
		//������������������������������������������������������Ŀ
		//� Campos que devem aparecer na Enchoice                �
		//��������������������������������������������������������
		aCampos	:= {"QPL_DTENLA","QPL_HRENLA","QPL_LAUDO","QPL_DTLAUD","QPL_HRLAUD","QPL_DTVAL",;
		"QPL_TAMLOT","QPL_QTREJ","QPL_DTDILA","QPL_HRDILA","QPL_JUSTLA"}
		
		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC
		
		AADD(aSVAlias,"QPL ")
		RegToMemory("QPL",.F.)
		aEnch[2]:=MsMGet():New("QPL",QPL->(RecNo()),	2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aEnch[2]:Hide()
		aCampos := {}
	EndIf
	If lFoundQPM
		//������������������������������������������������������Ŀ
		//� Campos que devem aparecer na Enchoice                �
		//��������������������������������������������������������
		aCampos	:= {"QPM_DTENLA","QPM_HRENLA","QPM_LAUDO","QPM_DTLAUD","QPM_HRLAUD","QPM_DTVAL",;
		"QPM_TAMLOT","QPM_QTREJ","QPM_DTDILA","QPM_HRDILA","QPM_JUSTLA"}
		
		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC
		
		AADD(aSVAlias,"QPM ")
		RegToMemory("QPM",.F.)
		aEnch[3]:=MsMGet():New("QPM",QPM->(RecNo()),	2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aEnch[3]:Hide()
		aCampos := {}
	EndIf
	If lFoundQPLL
		//������������������������������������������������������Ŀ
		//� Campos que devem aparecer na Enchoice                �
		//��������������������������������������������������������
		aCampos := {"QPL_DTENLA","QPL_HRENLA","QPL_LAUDO","QPL_DTLAUD","QPL_HRLAUD","QPL_DTVAL",;
		"QPL_TAMLOT","QPL_QTREJ","QPL_DTDILA","QPL_HRDILA","QPL_JUSTLA"}
		
		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC
		
		AADD(aSVAlias,"QPLL")
		RegToMemory("QPL",.F.)
		aEnch[4]:=MsMGet():New("QPL",QPL->(RecNo()),	2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aEnch[4]:Hide()
		aCampos := {}
	EndIf
	
	//������������������������������������������������������Ŀ
	//� Campos que devem aparecer na Enchoice                �
	//��������������������������������������������������������
	aFields	:= {}
	aCampos := {"QPK_OP","QPK_LOTE","QPK_NUMSER","QPK_PRODUT","QPK_REVI","QPK_TAMLOT","QPK_UM","QPK_DTPROD",;
			"QPK_EMISSA","QPK_LAUDO","QPK_CERQUA"}

	
	For nC := 1 To Len(aCampos)
		Aadd(aFields,aCampos[nC])
	Next nC
	
	aEnch[1]:= MsMGet():New("QPK",QPK->(RecNo()),2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
Else
	If lFoundQELF
		//������������������������������������������������������Ŀ
		//� Campos que devem aparecer na Enchoice                �
		//��������������������������������������������������������
		aCampos	:= {"QEL_DTENLA","QEL_HRENLA","QEL_LAUDO","QEL_DTLAUD","QEL_HRLAUD","QEL_DTVAL",;
		"QEL_TAMLOT","QEL_QTREJ","QEL_DTDILA","QEL_HRDILA","QEL_JUSTLA"}

		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC
		
		AADD(aSVAlias,"QEL ")
		RegToMemory("QEL",.F.)
		aEnch[2]:=MsMGet():New("QEL",QPL->(RecNo()),	2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aEnch[2]:Hide()
		aCampos := {}
	EndIf
	
	If lFoundQELL
		//������������������������������������������������������Ŀ
		//� Campos que devem aparecer na Enchoice                �
		//��������������������������������������������������������
		aCampos := {"QEL_DTENLA","QEL_HRENLA","QEL_LAUDO","QEL_DTLAUD","QEL_HRLAUD","QEL_DTVAL",;
		"QEL_TAMLOT","QEL_QTREJ","QEL_DTDILA","QEL_HRDILA","QEL_JUSTLA"}
		
		For nC := 1 To Len(aCampos)
			Aadd(aFields,aCampos[nC])
		Next nC
		
		AADD(aSVAlias,"QELL")
		RegToMemory("QEL",.F.)
		aEnch[3]:=MsMGet():New("QEL",QEL->(RecNo()),	2,,,,aFields,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
		aEnch[3]:Hide()
		aCampos := {}
	EndIf
	aEnch[1]:= MsMGet():New("QEK",QEK->(RecNo()),2,,,,,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,,lOneColumn)
EndIf

DbSelectArea(oTree:cArqTree)
DbGotop()
oTree:TreeSeek(T_CARGO)
oTree:Refresh()
aCampos	:= {}
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()})
Release Object oTree

Return(.T.) 
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC021Tree� Autor �Marcelo Pimentel       � Data � 15-05-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que monta o Tree da consulta de produto                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function QPC021Tree(oTree,cAlias,nRecLaudo,cOrigem)
LOCAL cChaveQPL	:= ""
LOCAL cChaveQPR	:= ""
LOCAL cEnsaio	:= ""
LOCAL cProduto	:= ""
LOCAL cRoteiro	:= ""
LOCAL cRevi		:= ""
LOCAL aOper		:= {}
LOCAL cOrdProd	:= ""
LOCAL nC		:= 0
LOCAL nClab		:= 0
LOCAL aOperacao	:= {}
LOCAL cLabor	:= ""
LOCAL nRecnoQPM	:= 0
LOCAL nRecnoQPL	:= 0
LOCAL cChaveQEL	:= ""
LOCAL cChaveQER	:= ""
LOCAL cRecnoQELF	:= ""

DEFAULT cAlias	:= ""

//������������������������������������������������������Ŀ
//� Monta Tree na Primeira Vez                           �
//��������������������������������������������������������
If Empty(cAlias)
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()
EndIf

oTree:BeginUpdate()
If cOrigem == "QIP"
	If Empty(cAlias)
		//������������������������������������������������������Ŀ
		//� Verifica dados cadastrais do produto                 �
		//��������������������������������������������������������
		oTree:TreeSeek("")
		oTree:AddItem(STR0014+QPK->QPK_PRODUT+"-"+STR0015+QPK->QPK_OP+" Lote: "+QPK->QPK_LOTE+" Num Ser:"+QPK->QPK_NUMSER+Space(10),"01QPK "+StrZero(QPK->(Recno()),11),"BMPCONS","BMPCONS",,,1) //"Produto:"###"Dados Gerais - O.P.: "
	EndIf
	//������������������������������������������������������Ŀ
	//� Monta Laudo Final                                    �
	//��������������������������������������������������������
	If Empty(cAlias).And. nRecLaudo <> 0
		oTree:TreeSeek("01QPK "+StrZero(QPK->(Recno()),11))
		oTree:AddItem(STR0016,"02QPL "+StrZero(nRecLaudo,11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Final"
	EndIf
	cProduto	:= QPK->QPK_PRODUT
	cRoteiro	:= Posicione("SC2",1,xFilial("SC2")+QPK->QPK_OP,"C2_ROTEIRO")
	cRevi		:= QPR->QPR_REVI
	cOrdProd	:= QPK->QPK_OP
	//���������������������������������Ŀ
	//� Monta  array das Operacoes  	�
	//�����������������������������������
	aOper := QPC020Ope(cProduto,cRoteiro,cOrdProd,cRevi)
	For nC := 1 To Len(aOper)
		dbSelectArea("QPM")
		dbSetOrder(1)
		If dbSeek(xFilial("QPM")+QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOper[nC,1])
			oTree:TreeSeek("01QPK "+StrZero(QPK->(Recno()),11))
			oTree:AddItem(STR0017+QPM->QPM_OPERAC+"-"+AllTrim(aOper[nC,2]),"03QPM "+StrZero(Recno(),11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Opera��o: "
			nRecnoQPM := "03QPM "+StrZero(Recno(),11)
		Else
			nRecnoQPM := "01QPK "+StrZero(QPK->(Recno()),11)
		EndIf
		
		aOperacao	:= aClone(aOper[nC])
		aLab		:= QPC020LabP(cProduto,cRoteiro,aOperacao,cRevi)
		cLabor		:= ''
		For nClab	:= 1 To Len(aLab)
			
			If cLabor <> aLab[nCLab,1]
				cLabor := aLab[nCLab,1]
				
				cChaveQPL	:= QPK->QPK_OP+QPK->QPK_LOTE+QPK->QPK_NUMSER+cRoteiro+aOper[nC,1]+aLab[nCLab,1]
				dbSelectArea("QPL")
				dbSetOrder(3)
				If dbSeek(xFilial("QPL")+cChaveQPL)
					//������������������������������������������������������Ŀ
					//� Monta Laudo Laboratorio        						 �
					//��������������������������������������������������������
					oTree:TreeSeek(nRecnoQPM)
					oTree:AddItem(STR0018+QPL->QPL_LABOR,"04QPLL"+StrZero(Recno(),11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Laborat�rio: "
					nRecnoQPL := "04QPLL"+StrZero(Recno(),11)
				Else
					nRecnoQPL := "01QPK "+StrZero(QPK->(Recno()),11)
				EndIf
				
				cChaveQPR	:= cOrdProd+aOper[nC,1]+aLab[nClab,1]
				cEnsaio		:= ''
				
				dbSelectArea("QPR")
				dbSetOrder(1)
				dbSeek(xFilial("QPR")+cChaveQPR)
				While !Eof() .And. QPR->QPR_FILIAL == xFilial("QPR") .And.;
					QPR->QPR_OP+QPR->QPR_OPERAC+QPR->QPR_LABOR == cChaveQPR
					//������������������������������������������������������Ŀ
					//� Monta Ensaios               						 �
					//��������������������������������������������������������
					If cEnsaio <> QPR->QPR_ENSAIO
						cEnsaio := QPR->QPR_ENSAIO
						oTree:TreeSeek(nRecnoQPL)
						oTree:AddItem(STR0019+QPR->QPR_ENSAIO,"05QPR "+StrZero(QPR->(Recno()),11),"BMPTABLE","BMPTABLE",,,2) //"Ensaio: "
					EndIf
					dbSkip()
				EndDo
			EndIf
		Next nClab
	Next nC
Else
	If Empty(cAlias)
		//������������������������������������������������������Ŀ
		//� Verifica dados cadastrais do produto                 �
		//��������������������������������������������������������
		oTree:TreeSeek("")
		oTree:AddItem(STR0014+QEK->QEK_PRODUT+STR0020+QEK->QEK_LOTE+STR0021+QEK->QEK_FORNEC,"01QEK "+StrZero(QEK->(Recno()),11),"BMPCONS","BMPCONS",,,1) //"Produto:"###" Lote: "###" Fornecedor: "
	EndIf
	//������������������������������������������������������Ŀ
	//� Monta Laudo Final            						 �
	//��������������������������������������������������������
	If Empty(cAlias).And. nRecLaudo <> 0
		oTree:TreeSeek("01QEK "+StrZero(QEK->(Recno()),11))
		oTree:AddItem(STR0016,"02QEL "+StrZero(nRecLaudo,11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Final"
		cRecnoQELF := "02QEL "+StrZero(nRecLaudo,11)
	EndIf

	cProduto	:= QEK->QEK_PRODUT
	cRevi		:= QEK->QEK_REVI
	cChaveQEL	:= QEK->QEK_FORNEC+QEK->QEK_LOJFOR+QEK->QEK_PRODUT+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE
	cChaveQER	:= QEK->QEK_PRODUT+QEK->QEK_REVI+QEK->QEK_FORNEC+QEK->QEK_LOJFOR+Dtos(QEK->QEK_DTENTR)+QEK->QEK_LOTE
	//������������������������������������������������������Ŀ
	//� Monta array dos Laboratorios 						 �
	//��������������������������������������������������������
	aLab	:= QPC020LabE(cProduto,cRevi)
	cLabor		:= ''
	For nClab	:= 1 To Len(aLab)
		If cLabor <> aLab[nCLab,1]
			cLabor := aLab[nCLab,1]
			dbSelectArea("QEL")
			dbSetOrder(1)
			If dbSeek(xFilial("QEL")+cChaveQEL+aLab[nCLab,1])
				//������������������������������������������������������Ŀ
				//� Monta Laudo Laboratorio                     		 �
				//��������������������������������������������������������
				oTree:TreeSeek(cRecnoQELF)
				oTree:AddItem(STR0018+QEL->QEL_LABOR,"03QELL"+StrZero(Recno(),11),"BMPTABLE","BMPTABLE",,,2) //"Laudo Laborat�rio: "
				cRecnoQEL := "03QELL"+StrZero(Recno(),11)
			Else
				cRecnoQEL := "01QEK "+StrZero(QEK->(Recno()),11)
			EndIf
                             
			cEnsaio		:= ''
			dbSelectArea("QER")
			dbSetOrder(1)
			dbSeek(xFilial("QER")+cChaveQER+aLab[nCLab,1])
			While !Eof() .And. QER->QER_FILIAL == xFilial("QER") .And.;
				QER->QER_PRODUT+QER->QER_REVI+QER->QER_FORNEC+QER->QER_LOJFOR+;
				Dtos(QER->QER_DTENTR)+QER->QER_LOTE+QER->QER_LABOR == cChaveQER+aLab[nCLab,1]
				//������������������������������������������������������Ŀ
				//� Monta Ensaios                               		 �
				//��������������������������������������������������������
				If cEnsaio <> QER->QER_ENSAIO
					cEnsaio := QER->QER_ENSAIO
					oTree:TreeSeek(cRecnoQEL)
					oTree:AddItem(STR0019+QER->QER_ENSAIO,"04QER "+StrZero(QER->(Recno()),11),"BMPTABLE","BMPTABLE",,,2) //"Ensaio: "
				EndIf
				dbSkip()
			EndDo
		EndIf
	Next nClab
EndIf
oTree:EndUpdate()
oTree:Refresh() 
Return
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC020LabP � Autor �Marcelo Pimentel      � Data � 28-06-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta vetor para o Laboratorio na especificacao - Processos   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QPC020LabP(cProduto,cRoteiro,aOperacao,cRevi)
LOCAL cQuery			:= ''
LOCAL aLab				:= {}
LOCAL aArea				:= GetArea()

aLab := {}
dbSelectArea("QP7")
dbSetOrder(1)
	
aAreaQP7 := GetArea()
cQuery := "SELECT QP7.QP7_FILIAL, QP7.QP7_PRODUT, QP7.QP7_REVI, QP7.QP7_CODREC, QP7.QP7_OPERAC, QP7.QP7_ENSAIO, QP7.QP7_LABOR, QP7.QP7_SEQLAB, QP7.QP7_ENSOBR, QP7.QP7_PLAMO"
cQuery += " FROM " + RetSqlName("QP7")
cQuery += " QP7 WHERE QP7.QP7_FILIAL = '" + xFilial("QP7") + "' AND "
cQuery += " QP7.QP7_PRODUT = '" + cProduto + "' AND "
cQuery += " QP7.QP7_REVI = '" + cRevi + "' AND "
cQuery += " QP7.QP7_CODREC = '" + cRoteiro + "' AND "
cQuery += " QP7.QP7_OPERAC = '" + aOperacao[1] + "' AND "
    cQuery += " QP7.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(QP7->(IndexKey()))

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBQP7", .F., .T.)
dbSelectArea("TRBQP7")
While !Eof()
	Aadd( aLab, {TRBQP7->QP7_LABOR, TRBQP7->QP7_SEQLAB,TRBQP7->QP7_ENSAIO,TRBQP7->QP7_ENSOBR,;
	TRBQP7->QP7_CODREC, TRBQP7->QP7_PLAMO } )
	dbSkip()
EndDo
dbCloseArea()
RestArea(aAreaQP7)

	
dbSelectArea("QP8")
dbSetOrder(1)
aAreaQP8 := GetArea()
cQuery := "SELECT QP8.QP8_FILIAL,QP8.QP8_PRODUT,QP8.QP8_REVI,QP8.QP8_CODREC,QP8.QP8_OPERAC,QP8.QP8_ENSAIO,QP8.QP8_LABOR,QP8.QP8_SEQLAB,QP8.QP8_ENSOBR,QP8.QP8_PLAMO"
cQuery += " FROM " + RetSqlName("QP8")
cQuery += " QP8 WHERE QP8.QP8_FILIAL = '" + xFilial("QP8") + "' AND "
cQuery += " QP8.QP8_PRODUT = '" + cProduto + "' AND "
cQuery += " QP8.QP8_REVI = '" + cRevi + "' AND "
cQuery += " QP8.QP8_CODREC = '" + cRoteiro + "' AND "
cQuery += " QP8.QP8_OPERAC = '" + aOperacao[1] + "' AND "
    cQuery += " QP8.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(QP8->(IndexKey()))

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBQP8", .F., .T.)
dbSelectArea("TRBQP8")
While !Eof()
	Aadd( aLab, {TRBQP8->QP8_LABOR, TRBQP8->QP8_SEQLAB, TRBQP8->QP8_ENSAIO,;
	TRBQP8->QP8_ENSOBR, TRBQP8->QP8_CODREC, TRBQP8->QP8_PLAMO} )
	dbSkip()
Enddo
dbCloseArea()
RestArea(aAreaQP8)

RestArea(aArea)

aLab := ASort( aLab ,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )

Return(aLab)
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC020LabE � Autor �Marcelo Pimentel      � Data � 28-06-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta vetor para o Laboratorio na especificacao - Entregas    ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QPC020LabE(cProduto,cRevi)
LOCAL cQuery			:= ''
LOCAL aLab				:= {}
LOCAL aArea				:= GetArea()

dbSelectArea("QE7")
dbSetOrder(1)
aAreaQE7 := GetArea()
cQuery := "SELECT QE7.QE7_FILIAL, QE7.QE7_PRODUT, QE7.QE7_REVI, QE7.QE7_ENSAIO, QE7.QE7_LABOR, QE7.QE7_SEQLAB"
cQuery += " FROM " + RetSqlName("QE7")
cQuery += " QE7 WHERE QE7.QE7_FILIAL = '" + xFilial("QE7") + "' AND "
cQuery += " QE7.QE7_PRODUT = '" + cProduto + "' AND "
cQuery += " QE7.QE7_REVI = '" + cRevi + "' AND "
    cQuery += " QE7.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + SqlOrder(QE7->(IndexKey()))

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBQE7", .F., .T.)
dbSelectArea("TRBQE7")
While !Eof()
	Aadd( aLab, {TRBQE7->QE7_LABOR, TRBQE7->QE7_SEQLAB,TRBQE7->QE7_ENSAIO})
	dbSkip()
EndDo
dbCloseArea()
RestArea(aAreaQE7)

	
dbSelectArea("QE8")
dbSetOrder(1)
aAreaQE8 := GetArea()
cQuery := "SELECT QE8.QE8_FILIAL,QE8.QE8_PRODUT,QE8.QE8_REVI,QE8.QE8_ENSAIO,QE8.QE8_LABOR,QE8.QE8_SEQLAB"
cQuery += " FROM " + RetSqlName("QE8")
cQuery += " QE8 WHERE QE8.QE8_FILIAL = '" + xFilial("QE8") + "' AND "
cQuery += " QE8.QE8_PRODUT = '" + cProduto + "' AND "
cQuery += " QE8.QE8_REVI = '" + cRevi + "' AND "
    cQuery += " QE8.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY " + (QE8->(IndexKey()))    

cQuery := ChangeQuery( cQuery ) 
  
If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"		// Sinal de concatencao nesses ambientes
	cQuery := StrTran(cQuery, "+", "||")
Endif

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery),"TRBQE8", .F., .T.)
dbSelectArea("TRBQE8")
While !Eof()
	Aadd( aLab, {TRBQE8->QE8_LABOR, TRBQE8->QE8_SEQLAB, TRBQE8->QE8_ENSAIO} )
	dbSkip()
Enddo
dbCloseArea()
RestArea(aAreaQE8)

RestArea(aArea)
aLab := ASort( aLab ,,, { |x,y| x[1]+x[2] < y[1]+y[2] } )
Return(aLab)
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QPC021DlgV� Autor �Marcelo Pimentel       � Data � 15-05-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao que mostra as informacoes detalhadas da consulta       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QPC021DlgV(oTree,aSVAlias,aEnch,aPos,nOldEnch,oPanel,nRecnoQPLL,nRecnoQPLF,nRecnoQPR,nRecnoQPM,cOrigem,nRecnoQELL,nRecnoQELF,nRecnoQEK)
LOCAL cAlias	:= SubStr(oTree:GetCargo(),3,4)
LOCAL nRecView	:= Val(SubStr(oTree:GetCargo(),7,11))
LOCAL nPosAlias	:= aScan(aSVAlias,cAlias)
LOCAL lOneColumn:= If(aPos[4]-aPos[2]>312,.F.,.T.)
LOCAL aDados	:= {}
LOCAL oScroll

If cOrigem == "QIP"
	If nRecView <> 0 .And. cAlias <> "QPR"
		dbSelectArea(Substr(cAlias,1,3))
		MsGoto(nRecView)
		aEnch[nOldEnch]:Hide()
		RegToMemory(cAlias,.F.)
		If nPosAlias > 0
			Do Case
				Case cAlias == "QPK "
					aEnch[1]:EnchRefreshAll()
					aEnch[1]:Show()
					nOldEnch:=1
				Case cAlias == "QPL " .And. nRecnoQPLL <> 0
					aEnch[2]:EnchRefreshAll()
					aEnch[2]:Show()
					nOldEnch:=2
				Case cAlias == "QPM " .And. nRecnoQPM <> 0
					aEnch[3]:EnchRefreshAll()
					aEnch[3]:Show()
					nOldEnch:=3
				Case cAlias == "QPLL" .And. nRecnoQPLL <> 0
					aEnch[4]:EnchRefreshAll()
					aEnch[4]:Show()
					nOldEnch:=4
			EndCase
		Else
			oPanel:Hide()
			Do Case
				Case cAlias == "QPK "
					aAdd(aSVAlias,"QPK")
					aEnch[1]:= MsMGet():New("QPK",QPK->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
					aEnch[1]:EnchRefreshAll()
					nOldEnch:=1
				Case cAlias == "QPL "
					aAdd(aSVAlias,"QPL")
					aEnch[2]:= MsMGet():New("QPL",nRecnoQPLF,2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
					aEnch[2]:EnchRefreshAll()
					nOldEnch:=2
				Case cAlias == "QPM "
					aAdd(aSVAlias,"QPM")
					aEnch[3]:= MsMGet():New("QPM",QPM->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
					aEnch[3]:EnchRefreshAll()
					nOldEnch:=3
				Case cAlias == "QPLL"
					aAdd(aSVAlias,"QPLL")
					aEnch[4]:= MsMGet():New("QPL",nRecnoQPLL,2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
					aEnch[4]:EnchRefreshAll()
					nOldEnch:=4
			EndCase
			oPanel:Show()
		EndIf
	ElseIf cAlias == "QPR "
		aEnch[nOldEnch]:Hide()
		aDados	:= QpcGetDdQP(nRecView)
		oScroll:= TScrollBox():New(oPanel,aPos[1],aPos[2],aPos[3],aPos[4])
		QPScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
		aEnch[5]:=oScroll
		aEnch[5]:Show()
		nOldEnch:=5
	EndIf
Else
	If nRecView <> 0 .And. cAlias <> "QER"
		dbSelectArea(Substr(cAlias,1,3))
		MsGoto(nRecView)
		aEnch[nOldEnch]:Hide()
		RegToMemory(cAlias,.F.)
		If nPosAlias > 0
			Do Case
				Case cAlias == "QEK "
					aEnch[1]:EnchRefreshAll()
					aEnch[1]:Show()
					nOldEnch:=1
				Case cAlias == "QEL " .And. nRecnoQELL <> 0
					aEnch[2]:EnchRefreshAll()
					aEnch[2]:Show()
					nOldEnch:=2
				Case cAlias == "QELL" .And. nRecnoQELL <> 0
					aEnch[3]:EnchRefreshAll()
					aEnch[3]:Show()
					nOldEnch:=3
			EndCase
		Else
			oPanel:Hide()
			Do Case
				Case cAlias == "QEK "
					aAdd(aSVAlias,"QEK")
					aEnch[1]:= MsMGet():New("QEK",QEK->(RecNo()),2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
					aEnch[1]:EnchRefreshAll()
					nOldEnch:=1
				Case cAlias == "QEL "
					aAdd(aSVAlias,"QEL")
					aEnch[2]:= MsMGet():New("QEL",nRecnoQELF,2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
					aEnch[2]:EnchRefreshAll()
					nOldEnch:=2
				Case cAlias == "QELL"
					aAdd(aSVAlias,"QELL")
					aEnch[3]:= MsMGet():New("QEL",nRecnoQELL,2,,,,,aPos,,3,,,,oPanel,,,lOneColumn)
					aEnch[3]:EnchRefreshAll()
					nOldEnch:=3
			EndCase
			oPanel:Show()
		EndIf
	ElseIf cAlias == "QER "
		aEnch[nOldEnch]:Hide()
		aDados	:= QpcGetDdQE(nRecView)
		oScroll:= TScrollBox():New(oPanel,aPos[1],aPos[2],aPos[3],aPos[4])
		QPScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
		aEnch[4]:=oScroll
		aEnch[4]:Show()
		nOldEnch:=4
	EndIf
EndIf
Return
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QpcGetDdQP � Autor �Marcelo Pimentel      � Data � 20-06-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta vetor para visualizar o descritivo do ensaio - PROCESSOS���
���������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QpcGetDdQP(nRecnoQPR)
LOCAL aDados	:= {}
LOCAL aArea		:= GetArea()
LOCAL cOperac	:= ""
LOCAL cLabor	:= ""
LOCAL cOP		:= ""
LOCAL cEnsaio	:= ""
LOCAL nResApr	:= 0
LOCAL nResRep	:= 0
LOCAL cCarta	:= ""
LOCAL cPlAmEns	:= ""
LOCAL cChave	:= ""
LOCAL cNewEns	:= ""
LOCAL nCQpuQpt	:= 0
LOCAL nCountLin	:= 0

dbSelectArea("QPR")
dbGoTo(nRecnoQPR)
cChave := QPR_OP+QPR_OPERAC+QPR_LABOR+QPR_ENSAIO
While !Eof() .And. QPR->QPR_FILIAL == xFilial("QPR") .And.	QPR->QPR_OP+QPR->QPR_OPERAC+QPR->QPR_LABOR+QPR->QPR_ENSAIO == cChave
	If cNewEns <> QPR->QPR_ENSAIO
		cNewEns := QPR->QPR_ENSAIO  
		
		QP6->(dbSetOrder(1))
		QP6->(dbSeek(xFilial("QP6")+QPR->QPR_PRODUT+Inverte(QPR->QPR_REVI)))
		
		QP1->(dbSetOrder(1))
		If QP1->(dbSeek(xFilial("QP1")+QPR->QPR_ENSAIO))
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0022,QP1->QP1_ENSAIO}) //"Ensaio "
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0023,QP1->QP1_CARTA}) //"Carta "
			Aadd(aDados,{"",""})
			cCarta := QPCarta(QP1->QP1_ENSAIO)
			If cCarta <> "TXT"
				QP7->(dbSetOrder(1))
				If QP7->(dbSeek(xFilial("QP7")+QPR->QPR_PRODUT+QPR->QPR_REVI+QP6->QP6_CODREC+QPR->QPR_OPERAC+QPR->QPR_ENSAIO))
					If QP7->QP7_PLAMO == "I"
						cPlAmEns	:= QP7->QP7_DESPLA
					ElseIf QP7->QP7_PLAMO == "N"
						Aadd(aDados,{STR0024,"NBR5426"}) //"Plano de Amostragem "
						Aadd(aDados,{Substr(QP7->QP7_DESPLA,1,3),AllTrim(Substr(QP7->QP7_DESPLA,4,16))})
						Aadd(aDados,{Substr(QP7->QP7_DESPLA,20,13),AllTrim(substr(QP7->QP7_DESPLA,33,3))})
						Aadd(aDados,{Substr(QP7->QP7_DESPLA,36,10),AllTrim(substr(QP7->QP7_DESPLA,49,2))})
						cPlAmEns	:= ""
					ElseIf QP7->QP7_PLAMO == "T"
						cPlAmEns	:= "Texto "+QP7->QP7_DESPLA
					ElseIf QP7->QP7_PLAMO == "Z"
						cPlAmEns	:= STR0025+QP7->QP7_DESPLA //"Zero Defeito "
					EndIf
				EndIf
			Else
				QP8->(dbSetOrder(1))
				If QP8->(dbSeek(xFilial("QP8")+QPR->QPR_PRODUT+QPR->QPR_REVI+QP6->QP6_CODREC+QPR->QPR_OPERAC+QPR->QPR_ENSAIO))
					If QP8->QP8_PLAMO == "I"
						cPlAmEns	:= QP8->QP8_DESPLA
					ElseIf QP8->QP8_PLAMO == "N"
						Aadd(aDados,{STR0024,"NBR5426"}) //"Plano de Amostragem "
						Aadd(aDados,{Substr(QP8->QP8_DESPLA,1,3),AllTrim(Substr(QP8->QP8_DESPLA,4,16))})
						Aadd(aDados,{Substr(QP8->QP8_DESPLA,20,13),AllTrim(substr(QP8->QP8_DESPLA,33,3))})
						Aadd(aDados,{Substr(QP8->QP8_DESPLA,36,10),AllTrim(substr(QP8->QP8_DESPLA,49,2))})
						cPlAmEns	:= ""
					ElseIf QP8->QP8_PLAMO == "T"
						cPlAmEns	:= STR0026+QP8->QP8_DESPLA //"Texto "
					ElseIf QP8->QP8_PLAMO == "Z"
						cPlAmEns	:= STR0025+QP8->QP8_DESPLA //"Zero Defeito "
					EndIf
				EndIf
			EndIf
			If !Empty(cPlAmEns)
				Aadd(aDados,{"",""})
				Aadd(aDados,{STR0024,AllTrim(cPlAmEns)}) //"Plano de Amostragem "
			EndIf
			
			aAreaBack:=GetArea()
			cOperac	:= QPR->QPR_OPERAC
			cLabor	:= QPR->QPR_LABOR
			cOP		:= QPR->QPR_OP
			cEnsaio	:= QPR->QPR_ENSAIO
			dbSelectArea("QPR")
			dbSetOrder(1)
			If dbSeek(xFilial("QPR")+cOp+cOperac+cLabor+cEnsaio)
				While !Eof() .And. QPR_FILIAL+QPR_OP+QPR_OPERAC+QPR_LABOR+QPR_ENSAIO == xFilial()+cOp+cOperac+cLabor+cEnsaio
					If QPR->QPR_RESULT == "A"
						nResApr++
					Else
						nResRep++
					EndIf
					nCountLin++

					QPU->(dbSetOrder(1))
					If QPU->(dbSeek(xFilial("QPU")+QPR->QPR_CHAVE))
						Aadd(aDados,{"",""})
						Aadd(aDados,{STR0027,AllTrim(StrZero(nCountLin,2))}) //"Medi��o"
						While ( ! QPU->(Eof()) .And. QPU->QPU_FILIAL == xFilial("QPU") .And.;
							QPU->QPU_CODMED == QPR->QPR_CHAVE)
							Aadd(aDados, {Iif(nCQpuQpt==0,STR0028,""),QipxDNCo(QPU->QPU_NAOCON)}) //"N�o-Conformidade(s)"
							nCQpuQpt++
							QPU->(dbSkip())
						EndDo
					EndIf
					If QPT->(dbSeek(xFilial("QPT")+QPR->QPR_CHAVE))
						Aadd(aDados,{"",""})
						If nCQpuQpt == 0
							Aadd(aDados,{STR0027,AllTrim(StrZero(nCountLin,2))}) //"Medi��o"
						EndIf
						nCQpuQpt	:= 0
						QM2->(dbSetOrder(1))
						While ( ! QPT->(Eof()) .And. QPT->QPT_FILIAL == xFilial("QPT") .And.;
							QPT->QPT_CODMED == QPR->QPR_CHAVE )
							If QM2->(dbSeek(xFilial("QM2")+QPT->QPT_INSTR))
								Aadd(aDados, {Iif(nCQpuQpt==0,STR0029,""),QPT->QPT_INSTR}) //"Instrumento(s)"
								nCQpuQpt++
							Endif
							QPT->(dbSkip())
						EndDo
					EndIf
					nCQpuQpt	:= 0
					dbSkip()
				EndDo
			EndIf
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0030,AllTrim(Str(nResApr+nResRep,8))}) //"Total de Medi��es   "
			Aadd(aDados,{STR0031,AllTrim(Str(nResApr,8))}) //"Medi��es Aprovadas  "
			Aadd(aDados,{STR0032,AllTrim(Str(nResRep,8))}) //"Medi��es Reprovadas "
			RestArea(aAreaBack)
		EndIf
	EndIf
	dbSkip()
EndDo
RestArea(aArea)
Return(aDados)
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �QpcGetDdQE � Autor �Marcelo Pimentel      � Data � 20-06-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o �Monta vetor para visualizar o descritivo do ensaio-ENTREGAS   ���
���������������������������������������������������������������������������Ĵ��
��� Uso      �QIPC020                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function QpcGetDdQE(nRecnoQER)
LOCAL aDados	:= {}
LOCAL aArea		:= GetArea()
LOCAL nResApr	:= 0
LOCAL nResRep	:= 0
LOCAL cChave	:= ""
LOCAL cNewEns	:= ""
LOCAL nCQpuQpt	:= 0
LOCAL nCountLin	:= 0
LOCAL cProduto	:= ""
LOCAL cRevi		:= ""
LOCAL cFornec	:= ""
LOCAL cLoja		:= ""
LOCAL dDtEntr	:= ""
LOCAL cLote		:= ""
LOCAL cLabor	:= ""
LOCAL cEnsaio	:= ""
LOCAL cDesNaoCon:= ""

dbSelectArea("QER")
dbGoTo(nRecnoQER)
cChave := QER->QER_PRODUT+QER->QER_REVI+QER->QER_FORNEC+QER->QER_LOJFOR+Dtos(QER->QER_DTENTR)+QER->QER_LOTE+QER->QER_LABOR
While !Eof() .And. QER->QER_FILIAL == xFilial("QER") .And.	;
	QER->QER_PRODUT+QER->QER_REVI+QER->QER_FORNEC+QER->QER_LOJFOR+Dtos(QER->QER_DTENTR)+QER->QER_LOTE+QER->QER_LABOR == cChave
	If cNewEns <> QER->QER_ENSAIO
		cNewEns := QER->QER_ENSAIO
		
		QE1->(dbSetOrder(1))
		If QE1->(dbSeek(xFilial("QE1")+QER->QER_ENSAIO))
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0022,QE1->QE1_ENSAIO}) //"Ensaio "
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0023,QE1->QE1_CARTA}) //"Carta "
			Aadd(aDados,{"",""})
			
			//O arquivo QEK encontra-se posicionado
			aAreaAnt := GetArea()
			If QEK->QEK_TIPONF $ "D�B"
				dbSelectArea("QF6")
				dbSetOrder(1)
				dbSeek(xFilial("QF6")+QER->QER_FORNEC+QER->QER_LOJFOR+QER->QER_PRODUT+QER->QER_REVI+QER->QER_ENSAIO)
				If !Eof()
					Aadd(aDados,{STR0024,X3COMBO("QF6_TIPAMO",QF6->QF6_TIPAMO)}) //"Plano de Amostragem "
					Aadd(aDados,{RetTitle("QF6_NIVEL"),QF6->QF6_NIVEL})
					Aadd(aDados,{RetTitle("QF6_PLAMO"),QF6->QF6_PLAMO})
					Aadd(aDados,{RetTitle("QF6_NQA"),QF6->QF6_NQA})
					Aadd(aDados,{"",""})
				EndIf
			Else
				dbSelectArea("QF4")
				dbSetOrder(1)
				dbSeek(xFilial("QF4")+QER->QER_FORNEC+QER->QER_LOJFOR+QER->QER_PRODUT+QER->QER_REVI+QER->QER_ENSAIO)
				If !Eof()
					Aadd(aDados,{STR0024,X3COMBO("QF4_TIPAMO",QF4->QF4_TIPAMO)}) //"Plano de Amostragem "
					Aadd(aDados,{RetTitle("QF4_NIVEL"),QF4->QF4_NIVEL})
					Aadd(aDados,{RetTitle("QF4_PLAMO"),QF4->QF4_PLAMO})
					Aadd(aDados,{RetTitle("QF4_NQA"),QF4->QF4_NQA})
					Aadd(aDados,{"",""})
				EndIf
			EndIf
			RestArea(aAreaAnt)		
			
			aAreaBack:=GetArea()
			cProduto:= QER->QER_PRODUT
			cRevi	:= QER->QER_REVI
			cFornec	:= QER->QER_FORNEC
			cLoja	:= QER->QER_LOJFOR
			dDtEntr	:= QER->QER_DTENTR
			cLote	:= QER->QER_LOTE
			cLabor	:= QER->QER_LABOR
			cEnsaio	:= QER->QER_ENSAIO
			
			dbSelectArea("QER")
			dbSetOrder(1)
			If dbSeek(xFilial("QER")+cProduto+cRevi+cFornec+cLoja+dTos(dDtEntr)+cLote+cLabor+cEnsaio)
				While !Eof() .And. QER_FILIAL+QER_PRODUT+QER_REVI+QER_FORNEC+QER_LOJFOR+;
					Dtos(QER_DTENTR)+QER_LOTE+QER_LABOR+QER_ENSAIO == ;
					xFilial()+cProduto+cRevi+cFornec+cLoja+Dtos(dDtEntr)+cLote+cLabor+cEnsaio
					If QER->QER_RESULT == "A"
						nResApr++
					Else
						nResRep++
					EndIf
					nCountLin++

					QEU->(dbSetOrder(1))
					If QEU->(dbSeek(xFilial("QEU")+QER->QER_CHAVE))
						Aadd(aDados,{"",""})
						Aadd(aDados,{STR0027,AllTrim(StrZero(nCountLin,2))}) //"Medi��o"
						While ( ! QEU->(Eof()) .And. QEU->QEU_FILIAL == xFilial("QEU") .And.;
							QEU->QEU_CODMED == QER->QER_CHAVE)
							cDesNaoCon := Posicione("SAG",1,xFilial("SAG")+QEU->QEU_NAOCON,"AG_DESCPO")
							Aadd(aDados, {Iif(nCQpuQpt==0,STR0028,""),cDesNaoCon}) //"N�o-Conformidade(s)"
							nCQpuQpt++
							QEU->(dbSkip())
						EndDo
					EndIf
					If QET->(dbSeek(xFilial("QET")+QER->QER_CHAVE))
						Aadd(aDados,{"",""})
						If nCQpuQpt == 0
							Aadd(aDados,{STR0027,AllTrim(StrZero(nCountLin,2))}) //"Medi��o"
						EndIf
						nCQpuQpt	:= 0
						While ( ! QET->(Eof()) .And. QET->QET_FILIAL == xFilial("QET") .And.;
							QET->QET_CODMED == QER->QER_CHAVE )
							Aadd(aDados, {Iif(nCQpuQpt==0,STR0029,""),QET->QET_INSTR}) //"Instrumento(s)"
							nCQpuQpt++
							QET->(dbSkip())
						EndDo
					EndIf
					nCQpuQpt	:= 0
					dbSkip()
				EndDo
			EndIf
			Aadd(aDados,{"",""})
			Aadd(aDados,{STR0030,AllTrim(Str(nResApr+nResRep,8))}) //"Total de Medi��es   "
			Aadd(aDados,{STR0031,AllTrim(Str(nResApr,8))}) //"Medi��es Aprovadas  "
			Aadd(aDados,{STR0032,AllTrim(Str(nResRep,8))}) //"Medi��es Reprovadas "
			RestArea(aAreaBack)
		EndIf
	EndIf
	dbSkip()
EndDo
RestArea(aArea)
Return(aDados)
