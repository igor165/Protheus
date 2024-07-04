#include "QIPA071.CH"
#include "PROTHEUS.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QIPA071  � Autor � Cleber Souza          � Data � 26/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de atualizacao de Amarracao Prod.xCliente - Ensaio���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Sigaqip                                                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������� 
*/
Function QIPA071() 
PRIVATE cCadastro:= STR0001	//"Amarra��o Produto x Cliente"
//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	 �
//� ----------- Elementos contidos por dimensao ------------	 �
//� 1. Nome a aparecer no cabecalho 							 �
//� 2. Nome da Rotina associada									 �
//� 3. Usado pela rotina										 �
//� 4. Tipo de Transa��o a ser efetuada							 �
//�	 1 - Pesquisa e Posiciona em um Banco de Dados				 �
//�	 2 - Simplesmente Mostra os Campos							 �
//�	 3 - Inclui registros no Bancos de Dados					 �
//�	 4 - Altera o registro corrente								 �
//�	 5 - Remove o registro corrente do Banco de Dados			 �
//�	 6 - Nao permite inclusao na getdados						 �
//����������������������������������������������������������������
Private aRotina := {	{STR0024	,"AxPesqui"		, 0 , 1},; //"Pesquisar"
						{STR0025	,"QP071Manu"	, 0 , 2},; //"Visualizar"
						{STR0026	,"QP071Manu"	, 0 , 3},; //"Incluir"
						{STR0027	,"QP071Manu"	, 0 , 4},; //"Alterar"
						{STR0028	,"QP071Manu"	, 0 , 5 , 3 } } //"Excluir"
						
//�����������������������������������������������������������������������������������������Ŀ
//� Chama a funcao de BROWSE com filtro Obs: Voltar sempre para aOrdem 4 na MBrowse         �
//�������������������������������������������������������������������������������������������    
Mbrowse( 6, 1,22,75,"QQ4",,,,,,,,)
Return NIL

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun�ao    �QP071Manu  � Autor � Cleber Souza          � Data � 26/03/04 ���
��������������������������������������������������������������������������Ĵ��
���Descri�ao �Tela de manutencao Amarracao Produto x Cliente :INC/ALT/VIS  ���
��������������������������������������������������������������������������Ĵ��
��� Uso      � QIPA071                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Function QP071Manu(cAlias,nReg,nOpc)
Local oTempTable	:= NIL
Local oDlg
Local oGetCli   
Local cXMark		:= ''
Local cArqTrab	:= ''
Local nC         	:= 0
Local aStru		:= {}
Local aCampos		:= {}
Local aButtons	:= {}     
Local aFields		:= {}
Local aCampGet 	:= {} 
Local aPosObj 	:= {}
Local oSize
                       
Private cChave	:= ''
Private cEspecie	:= "QIPA070 "				//Para gravacao de textos
Private axtextos 	:= {}						//Vetor que contem os textos dos Produtos
Private oMark

//��������������������������������������������������������Ŀ
//� Cria Arquivo de Trabalho                               �
//����������������������������������������������������������
Aadd( aStru,{ "TB_OK"   		,	"C",01,0} )
Aadd( aStru,{ "TB_OPER"		,	"C",TamSX3("QQK_OPERAC")[1]	,0} )
Aadd( aStru,{ "TB_CODREC"	,	"C",TamSX3("QQK_CODIGO")[1]	,0} )
Aadd( aStru,{ "TB_LABOR"		,	"C",TamSX3("QP7_LABOR")[1]	,0} )
Aadd( aStru,{ "TB_ENSAIO"	,	"C",TamSX3("QP7_ENSAIO")[1]	,0} )
Aadd( aStru,{ "TB_ENSOBR"	,	"C",TamSX3("QP7_ENSOBR")[1]	,0} )
Aadd( aStru,{ "TB_CERTIF"	,	"C",TamSX3("QP7_CERTIF")[1]	,0} )
Aadd( aStru,{ "TB_DESENS"	,	"C",TamSX3("QP1_DESCPO")[1]	,0} )
Aadd( aStru,{ "TB_CARTA"		,	"C",TamSX3("QP1_CARTA")[1]	,0} )
Aadd( aStru,{ "TB_CLIENTE"	,	"C",TamSX3("QQ7_CLIENT")[1]	,0} )
Aadd( aStru,{ "TB_PRODUTO"	,	"C",TamSX3("QQ7_PRODUT")[1]	,0} )
Aadd( aStru,{ "TB_LOJA"		,	"C",TamSX3("QQ7_LOJA")[1]	,0} )
Aadd( aStru,{ "TB_FORMUL"	,	"C",TamSX3("QP7_FORMUL")[1]	,0} )

oTempTable := FWTemporaryTable():New( "TRB" )
oTempTable:SetFields( aStru )
oTempTable:AddIndex("indice1", {"TB_OPER"} )
oTempTable:Create()

cXMark := GetMark()

//��������������������������������������������������������������Ŀ
//� Redefinicao do aCampos para utilizar no MarkBrow             �
//����������������������������������������������������������������
aCampos := {	{"TB_OK"		,""," "		}	,;	//"Ok"
				{"TB_ENSAIO"	,"",STR0007	}	,;	//"Ensaio"
				{"TB_DESENS"	,"",STR0008	}	,;	//"Descricao"
				{"TB_LABOR"	,"",STR0006	}	,;	//"Laboratorio"
				{"TB_CODREC"	,"",STR0002	}	,;	//"Roteiro"
				{"TB_OPER"		,"",STR0003	}	,;	//"Operacao"
				{"TB_ENSOBR"	,"",STR0004	}	,;	//"Ensaio Obrig."
				{"TB_CERTIF"	,"",STR0005	}	,;	//"Consta Certif."
				{"TB_CARTA"	,"",STR0009	} }		//"Carta"
				
nOpca := 0

oSize := FwDefSize():New(.T.)

oSize:AddObject('HEADER',100,70,.T.,.F.)
oSize:AddObject('GRID'  ,100,10,.T.,.T.)

oSize:aMargins 	:= { 3, 3, 3, 3 }
oSize:Process()

aAdd(aPosObj,{oSize:GetDimension('HEADER', 'LININI'),oSize:GetDimension('HEADER', 'COLINI'),oSize:GetDimension('HEADER', 'LINEND'),oSize:GetDimension('HEADER', 'COLEND')})
aAdd(aPosObj,{oSize:GetDimension('GRID'  , 'LININI'),oSize:GetDimension('GRID'  , 'COLINI'),oSize:GetDimension('GRID'  , 'LINEND'),oSize:GetDimension('GRID'  , 'COLEND')})

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL		//"Amarra��o Produto x Cliente"

If !INCLUI
	aRotina[nOpc][4] := 4
EndIf    

//������������������������������������������������������Ŀ
//� Campos que devem aparecer na Enchoice                �
//��������������������������������������������������������
aFields	:= {}
aCampGet := {"QQ4_PRODUT","QQ4_DESPRO","QQ4_CLIENT","QQ4_LOJA","QQ4_DESCLI"}

For nC := 1 To Len(aCampGet)
	Aadd(aFields,aCampGet[nC])
Next nC

RegToMemory("QQ4",(INCLUI))
oGetCli:=MsMGet():New("QQ4",nReg,nOpc,,,,aFields,aPosObj[1],,3,,,,oDlg,,.T.,,,,,,,.T.)

oMark := MsSelect():New("TRB","TB_OK",,aCampos,,"x",aPosObj[2])
If nOpc == 3 .Or. nOpc == 4
	oMark:oBrowse:bAllMark	:= {| | QP071MkAll(oDlg,nOpc)}
Else
	oMark:bAval				:= {|| .T. }
EndIf
oMark:oBrowse:Refresh()
oMark:oBrowse:SetFocus()   

If !INCLUI
	QP071Ens(QQ4->QQ4_PRODUT,QQ4->QQ4_CLIENT,QQ4->QQ4_LOJA)
	VerifChav(QQ4->QQ4_PRODUT,QQ4->QQ4_CLIENT,QQ4->QQ4_LOJA,oDlg)
EndIf

//�������������������������������������������������Ŀ
//� Cria botao para Observacao                   	�
//���������������������������������������������������
AAdd(aButtons,{"RELATORIO",{|| qp071Texto("TRB",Recno(),nOpc)},STR0019,STR0031}) //"Observacoes..."###"Observac"

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nopca:=1,If(A071Ok(M->QQ4_CLIENT,M->QQ4_LOJA) .And. A071VldEns(),oDlg:End(),nOpca:=0)},{||nopca:=0,oDlg:End()},,aButtons)  

If nOpca == 1  
	//Exclusao
	If nOpc == 5
		cChaveQQ4 := xFilial("QQ4")+M->QQ4_PRODUT+M->QQ4_CLIENT+M->QQ4_LOJA
		Begin Transaction
		dbSelectArea('QQ7')
		dbSetOrder(1)
		If dbSeek(cChaveQQ4)
			While !EOF() .And. QQ7_FILIAL+QQ7_PRODUT+QQ7_CLIENT+QQ7_LOJA==cChaveQQ4
				RecLock("QQ7")
				dbDelete()
				MsUnlock()
				dbSkip()
			EndDo
		EndIf
		
		dbSelectArea('QQ4')
		dbSetOrder(1)
		If dbSeek(cChaveQQ4)
			RecLock("QQ4")
			dbDelete()
			MsUnlock()
		EndIf  
		End Transaction   

	//Inclusao e Alteracao	
	ElseIf nOpc == 4 .OR. nOpc == 3 

		Begin Transaction
		a071Grava(M->QQ4_PRODUT,M->QQ4_CLIENT,M->QQ4_LOJA)
		End Transaction

	EndIf
EndIf

oTempTable:Delete() //-- Deleta arquivo temporario

Return(.T.)
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QP071MkAll � Autor �Cleber Souza 	 	� Data � 26/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte Marcadas/Desmarcadas                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIPA071                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP071MkAll(oDlg,nOpcao)
Local nRecno:= Recno()
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	If Empty(TRB->TB_OK)
		Replace TRB->TB_OK With "x"
	Else
		Replace TRB->TB_OK With " "
	Endif
	MsUnlock()
	dbSkip()
EndDo
dbGoto(nRecno)
oDlg:Refresh()
Return .T.
/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A071Grava� Autor � Cleber Souza          � Data � 26/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a amarra��o dos produtos x Clientes dos ensaios      ���
���          � Selecionados.                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QIPA071                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A071Grava()
Local nC		:= 0
Local aCpos		:= {}
Local aStruAlias := FWFormStruct(3, "QQ4",,.F.)[3]
Local nX
//��������������������������������������������Ŀ
//� Verifica campos do usuario      		   �
//����������������������������������������������
For nX := 1 To Len(aStruAlias)
	If GetSx3Cache(aStruAlias[nX,1], "X3_PROPRI") == "U"
		Aadd(aCpos,aStruAlias[nX,1])
	EndIf
Next nX

//����������������������������������������������Ŀ
//� Gravacao do Cabecalho do Relacionamento QQ4  �
//������������������������������������������������
dbSelectArea("QQ4")
QQ4->(dbSetOrder(1))
If QQ4->(dbSeek(xFilial("QQ4")+M->QQ4_PRODUT+M->QQ4_CLIENT+M->QQ4_LOJA))
	RecLock("QQ4",.F.)
Else
	RecLock("QQ4",.T.)
	QQ4->QQ4_FILIAL := xFilial("QQ4")
EndIf
                
QQ4->QQ4_PRODUT		:= M->QQ4_PRODUT
QQ4->QQ4_CLIENT		:= M->QQ4_CLIENT
QQ4->QQ4_LOJA		:= M->QQ4_LOJA

//����������������������������������������������������������Ŀ
//� Efetua a gravacao da chave em todo a arquivo tempor�rio  �
//������������������������������������������������������������
If !Empty(cChave)
	QQ4->QQ4_CHAVE := cChave
Endif	
//��������������������������������������������Ŀ
//� Faz a gravacao de campos de usuario        �
//����������������������������������������������
For nC := 1 To Len(aCpos)
	FieldPut(FieldPos(aCpos[nC]),M->&(aCpos[nC]))
Next nC
MsUnlock()           

If !Empty(cChave)
	//����������������������������������������������������������Ŀ
	//� Grava Texto do Produto no QA2							 �
	//������������������������������������������������������������
	QA_GrvTxt(cChave,cEspecie,1,@axtextos)
Endif	


dbSelectArea("TRB")
dbGoTop()
While !Eof()
	//��������������������������������������������������������������Ŀ
	//� Verifica se ja existe o registro.                            �
	//����������������������������������������������������������������
	QQ7->(dbSetOrder(1))
	If QQ7->(dbSeek(xFilial("QQ7")+M->QQ4_PRODUT+M->QQ4_CLIENT+M->QQ4_LOJA+TRB->TB_LABOR+;
		TRB->TB_ENSAIO+TRB->TB_CODREC+TRB->TB_OPER))
		RecLock("QQ7",.F.)
		QQ7->(dbDelete())
		MsUnlock()
	EndIf

	If Empty(TRB->TB_OK)
		dbSelectArea("TRB")
		dbSkip()
		Loop
	EndIf
	
	dbSelectArea("QQ7")
	RecLock("QQ7",.T.)
	QQ7->QQ7_FILIAL		:=	xFilial("QQ7")
	QQ7->QQ7_PRODUT		:= M->QQ4_PRODUT
	QQ7->QQ7_CLIENT		:= M->QQ4_CLIENT
	QQ7->QQ7_LOJA		:= M->QQ4_LOJA
	QQ7->QQ7_LABOR		:= TRB->TB_LABOR
	QQ7->QQ7_ENSAIO		:= TRB->TB_ENSAIO
	QQ7->QQ7_OPERAC		:= TRB->TB_OPER
	QQ7->QQ7_CODREC 	:= TRB->TB_CODREC
	QQ7->QQ7_CHAVE		:= QQ4->QQ4_CHAVE
	MsUnlock()
	dbSelectArea("TRB")
	dbSkip()
EndDo
Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � A071OK   � Autor � Cleber Souza          � Data �26/03/04  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Verifica se o cliente e a loja foram informados antes de   ���
���          � executar a grava��o.                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa071                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A071OK(cCli,cLoj)
Local lRet := .T.
If Empty(cCli) .Or. Empty(cLoj)
	Help(" ",1,"QA_CPOOBR")
	lRet := .F.
EndIf
Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   � VerifChav� Autor � Cleber Souza          � Data �26/03/04  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o� Verifica se existe a amarra��o Prod x Cliente              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa071                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VerifChav(cProd,cCliente,cLoja,oDlg)
Local cChave	:= '', nRecno := 0
dbGotop()
While !Eof()
	RecLock("TRB",.F.)
	TRB->TB_OK 			:=" "
	TRB->TB_CLIENTE		:=cCliente
	TRB->TB_LOJA		:=cLoja
	TRB->TB_PRODUTO		:=cProd
	MsUnlock()
	dbSkip()
EndDo

cChave	:= xFilial("QQ7")+cProd+cCliente+cLoja
dbSelectArea("QQ7")
dbSetOrder(1)
nRecno := Recno()
If dbSeek(cChave)
	While !Eof() .And. cChave == QQ7->QQ7_FILIAL+QQ7->QQ7_PRODUT+QQ7->QQ7_CLIENT+QQ7->QQ7_LOJA
		dbSelectArea("TRB")
		dbGoTop()
		While !Eof()
			If QQ7->QQ7_CODREC+QQ7->QQ7_OPERAC+QQ7->QQ7_LABOR+QQ7->QQ7_ENSAIO == ;
				TRB->TB_CODREC+TRB->TB_OPER+TRB->TB_LABOR+TRB->TB_ENSAIO
				RecLock("TRB",.F.)
				TRB->TB_OK	:="x"
				MsUnlock()
			EndIf
			dbSkip()
		EndDo
		dbSelectArea("QQ7")
		dbSkip()
	EndDo
EndIf
DbGoto(nRecno)
oDlg:Refresh()
dbSelectArea("TRB")
dbGoTop()
Return(.T.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �qp071Texto� Autor � Cleber Souza          � Data � 26/03/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cadastra Texto do Produto            					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � qp071Texto(ExpC1,ExpN1,ExpN2)	                   		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo									  ���
���			 � ExpN1 = Numero do registro 								  ���
���			 � ExpN2 = Opcao selecionada								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIPA010													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function qp071Texto(cAlias,nReg,nOpc)
Local cCabec	:=""
Local cTitulo	:= OemtoAnsi(STR0021)		//"Produto"
Local nTamLin	:= TamSX3("QA2_TEXTO")[1]
//���������������������������������������������������������������������Ŀ
//� Caso seja Delecao ou Visualizacao a Observacao nao serah alteravel	�
//�����������������������������������������������������������������������
Local lEditObs	:= Iif(nOpc==2 .Or. nOpc==5,.F.,.T.)	//Caso seja 
Local lRetTex   := .T.
cCabec	:= OemtoAnsi(STR0022)				//"Texto do Produto"

dbSelectArea("QQ4")
dbSetOrder(1)

If Empty(M->QQ4_PRODUT) .Or. Empty(M->QQ4_CLIENT) .Or. Empty(M->QQ4_LOJA) .And. (nOpc == 3 .Or. nOpc == 4)
	MsgStop(OemToAnsi(STR0032))
	Return
EndIf

//����������������������������������������������������������Ŀ
//� Gera/obtem a chave de ligacao com o texto do Produto/Rv  �
//������������������������������������������������������������
If dbSeek(xFilial("QQ4")+M->QQ4_PRODUT+M->QQ4_CLIENT+M->QQ4_LOJA)
	cChave := QQ4->QQ4_CHAVE
ElseIf Empty(cChave)
	cChave := QA_CvKey(xFilial("QQ7")+M->QQ4_PRODUT+M->QQ4_CLIENT+M->QQ4_LOJA,"QQ7", 1)
EndIf

//����������������������������������������������������������Ŀ
//� Digita o Texto do Produto    							 �
//������������������������������������������������������������
lRetTex := QA_TEXTO(cChave,cEspecie,nTamlin,cTitulo,STR0021+": "+AllTrim(M->QQ4_PRODUT)+"  - "+STR0023+M->QQ4_CLIENT+"-"+M->QQ4_LOJA,@axtextos,1 ,cCabec,lEditObs)		//"Produto"###"Cliente : "

If nOpc == 4 .and. Len(axTextos) > 0 .and. Empty(cChave)// Caso de alteracao, com texto novo... 
	cChave := QA_CvKey(xFilial("QQ7")+M->QQ4_PRODUT+M->QQ4_CLIENT+M->QQ4_LOJA,"QQ7", 1)		
Endif

dbselectArea("TRB")

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �QP071Ens  � Autor � Cleber Souza          � Data �26/03/04  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Carrega o arquivo temporario sobre os ensaios               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa071                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP071Ens(cProdut,cCliente,cLoja)
Local aARea	:= GetArea()
Local lRet  := .T.
Local cRevi := QA_UltRevEsp(cProdut,dDataBase,,,"QIP")

If !Empty(cCliente) .Or. !Empty(cLoja)
	If ReadVar() = "M->QQ4_CLIENT" .And. Empty(cLoja)
		lRet := ExistCpo("SA1", cCliente)
	Else
		lRet := ExistCpo("SA1", cCliente + cLoja)
	Endif
Endif
If lRet .And. !Empty(cProdut) .And. !Empty(cCliente) .And. !Empty(cLoja)
	If Inclui
		QQ7->(dbSetOrder(1))
		If QQ7->(dbSeek(xFilial("QQ7")+M->QQ4_PRODUT+cCliente+cLoja))
			Help(" ",1,"QP070TCHV")	//Existe amarracao Produto x Cliente ja cadastrada.
			lRet := .F.
		EndIf
	EndIf
	
	If lRet .And. (ReadVar() = "M->QQ4_PRODUT" .Or. TRB->(LastRec()) = 0)
		If TRB->(LastRec())	 > 0
			TRB->(__DbZap())
		Endif
		QP7->(dbSeek(xFilial("QP7")+cProdut+cRevi))
		While !QP7->(Eof()) .And.QP7->QP7_FILIAL+QP7->QP7_PRODUT+QP7->QP7_REVI ==	xFilial("QP7")+cProdut+cRevi
			QP1->(dbSeek(xFilial("QP1")+QP7->QP7_ENSAIO))
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			TB_LABOR	:=QP7->QP7_LABOR
			TB_CODREC	:=QP7->QP7_CODREC
			TB_OPER		:=QP7->QP7_OPERAC
			TB_ENSAIO	:=QP7->QP7_ENSAIO
			TB_ENSOBR	:=Iif(QP7->QP7_ENSOBR=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_CERTIF   :=Iif(QP7->QP7_CERTIF=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_DESENS   :=QP1->QP1_DESCPO
			TB_CARTA	:=QP1->QP1_CARTA
			TB_FORMUL	:=QP7->QP7_FORMUL
			MsUnLock()
			QP7->(dbSkip())
		EndDo
		QP8->(dbSeek(xFilial("QP8")+cProdut+cRevi))
		While !QP8->(Eof()) .And. QP8->QP8_FILIAL+QP8->QP8_PRODUTO+QP8->QP8_REVI ==xFilial("QP8")+cProdut+cRevi
			QP1->(dbSeek(xFilial("QP1")+QP8->QP8_ENSAIO))
			dbSelectArea("TRB")
			RecLock("TRB",.T.)
			TB_LABOR	:=	QP8->QP8_LABOR
			TB_CODREC	:=	QP8->QP8_CODREC
			TB_OPER		:=	QP8->QP8_OPERAC
			TB_ENSAIO	:=	QP8->QP8_ENSAIO
			TB_ENSOBR	:=	Iif(QP8->QP8_ENSOBR=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_CERTIF	:=	Iif(QP8->QP8_CERTIF=='S',STR0029,STR0030) //'Sim'###'Nao'
			TB_DESENS	:=	QP1->QP1_DESCPO
			TB_CARTA	:=	QP1->QP1_CARTA
			MsUnLock()
			QP8->(dbSkip())
		EndDo
		
		dbSelectArea("TRB")
		dbGoTop()
		If BOF() .And. EOF()
			HELP(" ",1,"QP070NTENS")	//Nao existe especificacao de produtos cadastrado.
		EndIf
		oMark:oBrowse:Refresh()
		oMark:oBrowse:SetFocus()
	EndIf
EndIf
RestArea(aArea)
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �QP071Chv  � Autor � Cleber Souza          � Data �26/03/04  ���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Validacao dos campos chave                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Qipa071                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QP071Chv()
Local lRet := .T.
If !Empty(M->QQ4_PRODUT) .and. !Empty(M->QQ4_CLIENT) .and. !Empty(M->QQ4_LOJA)
   dbSelectArea("QQ7")
   dbSetOrder(1)
   If dbSeek( xFilial() + M->QQ4_PRODUT + M->QQ4_CLIENT + M->QQ4_LOJA )
      Help( " ", 1, "JAGRAVADO" )
      lRet := .F.
   Endif
EndIf
Return(lRet)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A071VldEns  � Autor � Sergio S. Fuzinaka  � Data � 07.11.08 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Valida Ensaios Calculados                                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       �QIPA071                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A071VldEns()

Local lRet		:= .T.
Local aArea		:= GetArea()
Local aAreaTRB	:= TRB->(GetArea())
Local aEnsCalc	:= {}
Local aEns		:= {}
Local nX		:= 0
Local nY		:= 0

dbSelectArea("TRB")
dbGoTop()
While !Eof()
	If !Empty(TRB->TB_FORMUL) .And. !Empty(TRB->TB_OK)
		AADD(aEnsCalc,{TRB->TB_ENSAIO,TRB->TB_CODREC,TRB->TB_OPER,TRB->TB_FORMUL})
	Else
		AADD(aEns,{TRB->TB_ENSAIO,TRB->TB_CODREC,TRB->TB_OPER,TRB->TB_OK})
	Endif
	dbSkip()
Enddo

For nX := 1 To Len( aEnsCalc )
	For nY := 1 To Len( aEns )
		If aEnsCalc[nX][2]+aEnsCalc[nX][3] == aEns[nY][2]+aEns[nY][3]
			If AllTrim(Upper(aEns[nY][1])) $ Upper(aEnsCalc[nX][4])
				If Empty( aEns[nY][4] )
					MsgStop(OemToAnsi(STR0033)+Trim(aEns[nY][1])+OemtoAnsi(STR0034)+Trim(aEnsCalc[nX][1])+OemToAnsi(STR0035)+aEns[nY][2]+"/"+aEns[nY][3]+"]",OemToAnsi(STR0018))
					lRet := .F.
					Exit
				Endif
			Endif				
		Endif
	Next
Next

RestArea( aAreaTRB )
RestArea( aArea )

Return( lRet )
