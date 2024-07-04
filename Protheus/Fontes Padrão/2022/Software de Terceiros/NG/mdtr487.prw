#INCLUDE "MDTR487.CH"
#INCLUDE "MSOLE.CH"
#Include "Protheus.ch"

#DEFINE _nVERSAO 02 //Versao do fonte

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MDTR487  � Autor � Jackson Machado       � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Compara��o de Resultados dos Exames de Audiometria          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MDTR487()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function MDTR487()

//��������������������������������������������Ŀ
//�Guarda conteudo e declara variaveis padroes �
//����������������������������������������������
Local aNGBEGINPRM := NGBEGINPRM(_nVERSAO)

Private lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )

Private lMdtUnix := If( GetRemoteType() == 2 .or. isSRVunix() , .T. , .F. ) //Verifica se servidor ou estacao � Linux

//Variavel necess�ria na fun��o NGCRITRB
Private aVetinr := {}
//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de baixas                         �
//����������������������������������������������������������������
PRIVATE aRotina := MenuDef()

If !MDTRESTRI(cPrograma)
	//�����������������������������������������������������������������������Ŀ
	//� Devolve variaveis armazenadas (NGRIGHTCLICK) 			 			  �
	//�������������������������������������������������������������������������
	NGRETURNPRM(aNGBEGINPRM)
	Return .F.
Endif

If lSigaMdtps
	cCadastro := OemtoAnsi(STR0002)//Clientes

	DbSelectArea("SA1")
	DbSetOrder(1)

	mBrowse( 6, 1,22,75,"SA1")
Else
	cCadastro := OemToAnsi(STR0003)//Ficha M�dica

	//��������������������������������������������������������������Ŀ
	//� Endereca a funcao de BROWSE                                  �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"TM0")

	//��������������������������������������������������������������Ŀ
	//� Recupera a Ordem Original do arquivo principal               �
	//����������������������������������������������������������������
	dbSelectArea("TM0")
	dbSetOrder(1)
Endif

//��������������������������������������������Ŀ
//�Retorna conteudo de variaveis padroes       �
//����������������������������������������������
NGRETURNPRM(aNGBEGINPRM)
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT487EXA � Autor � Jackson Machado		  � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta um browse dos Exames                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function MDT487EXA()
//Variaveis de bkp
Local OldCad := cCadastro
Local nTamExa := If(TAMSX3("TM4_EXAME")[1] < 1, 6, TAMSX3("TM4_EXAME")[1])

//Blocos de codigo para exibicao dos campos virtuais no mark browse
Local bBloco1 := FIELDBLOCK("TRBAUD->TM9_ODRESU")
Local bBloco2 := FIELDBLOCK("TRBAUD->TM9_DESVIA")
Local bBloco3 := FIELDBLOCK("TRBAUD->TM9_ODREFE")

//Paineis
Local oPnlPai
Local oPnlTop

//Variaveis da cria��o do TRB
Local aDBF
Local aTRBAUD
Local oTempTRB
Private lInverte := .f.
Private cMARCA   := GetMark()
Private lQuery   := .t.

//Variavel necess�ria na fun��o NGCRITRB
Private aVetinr := {}

//Variaveis de tela
Private aSize := MsAdvSize(,.f.,430), aObjects := {}
Aadd(aObjects,{050,050,.t.,.t.})
Aadd(aObjects,{020,020,.t.,.t.})
Aadd(aObjects,{100,100,.t.,.t.})
aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],0,0}
aPosObj := MsObjSize(aInfo, aObjects,.t.)

//Variaveis de controle
Private lMdtUnix := If( GetRemoteType() == 2 .or. isSRVunix() , .T. , .F. ) //Verifica se servidor ou estacao � Linux

//Variaveis de radio
Private oRadOp
Private nViaRad  := 1

//Varaveis de markbrowse
Private oMark

cCadastro := OemToAnsi(STR0001)//"Resultados dos Exames de Audiometria"

//Criacao da TRB
dbSelectArea("TM9")

aDBF := {}
AADD(aDBF,{ "TM9_OK"     , "C" ,02, 0 })
AADD(aDBF,{ "TM9_NUMFIC" , "C" ,09, 0 })
AADD(aDBF,{ "TM9_EXAME"  , "C" ,nTamExa, 0 })
AADD(aDBF,{ "TM9_DTPROG" , "D" ,08, 0 })
AADD(aDBF,{ "TM9_HRPROG" , "C" ,05, 0 })
AADD(aDBF,{ "TM9_EQPTO"  , "C" ,06, 0 })
AADD(aDBF,{ "TM9_INDVIA" , "C" ,01, 0 })
AADD(aDBF,{ "TM9_DESVIA" , "C" ,11, 0 })
AADD(aDBF,{ "TM9_ODREFE" , "C" ,03, 0 })
AADD(aDBF,{ "TM9_ODRESU" , "C" ,28, 0 })

aTRBAUD := {}
AADD(aTRBAUD,{ "TM9_OK"     , NIL ," "    ,})
AADD(aTRBAUD,{ "TM9_NUMFIC" , NIL ,STR0003,})//"Ficha Medica"
AADD(aTRBAUD,{ "TM9_EXAME"  , NIL ,STR0004,}) //"Exame"
AADD(aTRBAUD,{ "TM9_DTPROG" , NIL ,STR0005,})//"Data Exame"
AADD(aTRBAUD,{ "TM9_HRPROG" , NIL ,STR0006,})//"Hor�rio Exame"
AADD(aTRBAUD,{ "TM9_EQPTO"  , NIL ,STR0007,})//"Equipamento"
AADD(aTRBAUD,{ "TM9_DESVIA" , NIL ,STR0008,})//"Via Condu��o"
AADD(aTRBAUD,{ "TM9_ODREFE" , NIL ,STR0009,})//"Refer. O.D."
AADD(aTRBAUD,{ "TM9_ODRESU" , NIL ,STR0010,})//"Result. O.D."

oTempTRB := FWTemporaryTable():New( "TRBAUD", aDBF )
oTempTRB:AddIndex( "1", {"TM9_NUMFIC","TM9_DTPROG","TM9_HRPROG","TM9_EXAME"} )
oTempTRB:Create()

//Append dos dados necess�rio para inicializa��o do TRB
APPEND FROM "TM9" FIELDS "TM9_NUMFIC", "TM9_EXAME", "TM9_DTPROG", "TM9_HRPROG", "TM9_EQPTO", "TM9_INDVIA",;
						 "TM9_ODREFE", "TM9_ODRESU" FOR (TM9->TM9_FILIAL+TM9->TM9_NUMFIC+TM9->TM9_INDVIA == xFilial("TM9")+TM0->TM0_NUMFIC+AllTrim(Str(nViaRad)) )

//Busca dos campos virtuais
Dbselectarea("TRBAUD")
Dbgotop()
While !Eof()
	RecLock( "TRBAUD" , .F. )
	TRBAUD->TM9_ODRESU := ResulDes(TRBAUD->TM9_ODRESU)
	TRBAUD->TM9_INDVIA := ViaDesc(TRBAUD->TM9_INDVIA)
	TRBAUD->TM9_ODREFE := RefDesc(TRBAUD->TM9_ODREFE)
	MsUnLock()
	Dbselectarea("TRBAUD")
	dbSkip()
End

//Neces�rio para nao deixar TRB em fim de arquivo (!EOF()) para exibicao de browse
dbGoTop()

Define MsDialog oDlg Title STR0011+TM0->TM0_NUMFIC+" - "+TM0->TM0_NOMFIC  From aSize[7],0 To aSize[6],aSize[5] Of oMainWnd Pixel  //"Exames do Funcion�rio: "
//Criado dois panels para adequacoes de tela na nova vers�o
oPnlPai := TPanel():New(00,00,,oDlg,,,,,,aSize[5],aSize[6],.F.,.F.)
	oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT


/*/������������������������Ŀ
	�Parte Top(Cima) da tela �
	��������������������������/*/

oPnlTop := TPanel():New(00,00,,oPnlPai,,,,,,aSize[5],aSize[6],.F.,.F.)
	oPnlTop:Align := CONTROL_ALIGN_TOP
	oPnlTop:nHeight := 70
@ 05,2 TO 30,150 LABEL STR0012 Color CLR_HBLUE of oPnlTop PIXEL//"Via de Condu��o"
@ 12,5  SAY OemToAnsi(STR0013) Color CLR_HBLUE PIXEL Of oPnlTop//"Via"
@ 11,20 RADIO oRadOp VAR nViaRad ITEMS	STR0014,STR0015;//"A�rea"###"�ssea"
			 	3D ON CHANGE Processa({|lEnd| fInvRad(nViaRad)},STR0016,STR0017,.T.) SIZE 123,11.5 PIXEL OF oPnlTop//"Aguarde..."###"Carregando Informa��es..."
@ 13,182 Button oBtn8 Prompt OemToAnsi(STR0018) Size 062,011 Of oPnlTop Pixel;//"Imprimir"
		    Action fValidImp()
@ 13,252 Button oBtn8 Prompt OemToAnsi(STR0019) Size 062,011 Of oPnlTop Pixel;//"Sair"
		    Action oDlg:End()

/*/����������������������������Ŀ
	�Parte Bottom(Baixo) da tela �
	������������������������������/*/
oMark := MsSelect():NEW("TRBAUD","TM9_OK",,aTRBAUD,@lINVERTE,@cMARCA,aPosObj[1],,,oPnlPai)
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oMark:oBrowse:bAllMark := {|| A487Invert(cMarca) }
	oMark:oBrowse:lHASMARK := .T.
	oMark:oBrowse:lCANALLMARK := .F.
Activate MsDialog oDlg Centered

dbSelectArea("TRBAUD")
oTempTRB:Delete()

//Retorno das vari�veis de bkp
cCadastro := OldCad

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ResulDes  � Autor � Jackson Machado		  � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Coloca a descricao do Resultado da Portaria 19 no campo    ���
���          � do TRB                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodResu - Codigo do resultado do exame                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function ResulDes(cCodResu)

Local cDesc := ""
cCodResu := AllTrim(cCodResu)

If cCodResu = "1"
	cDesc := STR0020//"Requer Interpreta��o"
Elseif cCodResu = "2"
	cDesc := STR0021//"Limiares Aceit�veis"
ElseIf cCodResu = "3"
	cDesc := STR0022//"Sugestivo de PAIR"
ElseIf cCodResu = "4"
	cDesc := STR0023//"Nao Sugestivo de PAIR"
ElseIf cCodResu = "5"
	cDesc := STR0024//"Sugestivo de Desencadeamento"
ElseIf cCodResu = "6"
	cDesc := STR0025//"Sugestivo de Agravamento
ElseIf cCodResu = "7"
	cDesc := STR0026//"Perda auditiva"
Endif

Return cDesc
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ViaDesc   � Autor � Jackson Machado		  � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Coloca a descricao da Via de Conducao no campo do TRB      ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCodVia - Codigo da via do exame                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function ViaDesc(cCodVia)

Local cDesc := ""
cCodVia := AllTrim(cCodVia)

If cCodVia == "1"
	cDesc := STR0014//"A�rea"
Elseif cCodVia == "2"
	cDesc := STR0015//"�ssea"
Endif

Return cDesc
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �RefDesc   � Autor � Jackson Machado		  � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Coloca a descricao do campo Referencial do TRB.            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCod - Indica se o exame e' referencial                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Static Function RefDesc(cCod)

Local cDesc := ""
cCod := AllTrim(cCod)

If cCod == "1"
	cDesc := STR0027//"Sim"
Elseif cCod == "2"
	cDesc := STR0028//"N�o"
Endif

Return cDesc

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MenuDef  � Autor � Jackson Machado		  � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Utilizacao de Menu Funcional.                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados      	  ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � F.O  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Local lSigaMdtPS := If( SuperGetMv("MV_MDTPS",.F.,"N") == "S", .t. , .f. )
Local aRotina

If lSigaMdtps
	aRotina := { { STR0029, "AxPesqui"  , 0 , 1},;//"Pesquisar"
	             { STR0030, "NGCAD01"   , 0 , 2},;//"Visualizar"
	             { STR0031, "MDT487TM0" , 0 , 4} }//"Fichas M�dicas"
Else
	aRotina := { { STR0029, "AxPesqui"  , 0 , 1},;//"Pesquisar"
				 { STR0030, "NGCAD01"  , 0 , 2},;//"Visualizar"
     			 { STR0032, "MDT487EXA"   , 0 , 3}}//"Exames"
Endif

Return aRotina
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT487TM0 � Autor � Jackson Machado		  � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Browse das fichas m�dicas do cliente.                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR488                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������/*/
Function MDT487TM0()

Local aArea	:= GetArea()
Local oldROTINA := aCLONE(aROTINA)
Local oldCad := cCadastro
cCliMdtPs := SA1->A1_COD+SA1->A1_LOJA

aRotina := { { STR0029, "AxPesqui"  , 0 , 1},;//"Pesquisar"
			 { STR0030, "NGCAD01"  , 0 , 2},;//"Visualizar"
			 { STR0032, "MDT487EXA"   , 0 , 3} }//"Exames"

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
cCadastro := OemtoAnsi(STR0031)//"Fichas M�dicas"

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
DbSelectArea("TM0")
Set Filter To TM0->(TM0_CLIENT+TM0_LOJA) == cCliMdtps
DbSetOrder(1)
mBrowse( 6, 1,22,75,"TM0")

DbSelectArea("TM0")
Set Filter To

aROTINA := aCLONE(oldROTINA)
RestArea(aArea)
cCadastro := oldCad

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A487Invert� Autor � Jackson Machado       � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inverte marcacoes - Windows                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cMarca - Marcacao                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A487Invert(cMarca)

Local nReg := TRBAUD->(Recno())

dbSelectArea("TRBAUD")
dbGoTop()
While !eof()
	RecLock("TRBAUD",.F.)
	TRBAUD->TM9_OK := IF(Empty(TRBAUD->TM9_OK),cMarca,"  ")
	MsUnLock("TRBAUD")
	dbSkip()
End

TRBAUD->(dbGoTo(nReg))
lRefresh := .T.

RETURN NIL
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A487Invert� Autor � Jackson Machado       � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Fun��o chamada na troca do radio buttom                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nVia - Codigo que identifica a via do exame (1 - Aerea;	  ���
���			 �	2 - Ossea)												              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fInvRad(nVia)
//Blocos de codigo para exibicao dos campos virtuais no mark browse
Local bBloco1 := FIELDBLOCK("TRBAUD->TM9_ODRESU")
Local bBloco2 := FIELDBLOCK("TRBAUD->TM9_DESVIA")
Local bBloco3 := FIELDBLOCK("TRBAUD->TM9_ODREFE")
Default nVia := 1

//Apaga o TRB
dbSelectArea("TRBAUD")
Zap
//Append da dados referentes a nova via
APPEND FROM "TM9" FIELDS "TM9_NUMFIC", "TM9_EXAME", "TM9_DTPROG", "TM9_HRPROG", "TM9_EQPTO", "TM9_INDVIA",;
						 "TM9_ODREFE", "TM9_ODRESU" FOR (TM9->TM9_FILIAL+TM9->TM9_NUMFIC+TM9->TM9_INDVIA == xFilial("TM9")+TM0->TM0_NUMFIC+AllTrim(Str(nVia)) )

//Busca dos campos virtuais
Dbselectarea("TRBAUD")
Dbgotop()
While !Eof()
	EVAL(bBloco1,ResulDes(TRBAUD->TM9_ODRESU))
	EVAL(bBloco2,ViaDesc(TRBAUD->TM9_INDVIA))
	EVAL(bBloco3,RefDesc(TRBAUD->TM9_ODREFE))
	dbSkip()
End
//Neces�rio para nao deixar TRB em fim de arquivo (!EOF()) para exibicao de browse
dbGoTop()

oMark:oBrowse:Refresh()

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fValidImp � Autor � Jackson Machado       � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a impress�o							                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function fValidImp()
Local nOk := 0
Local cPerg	:= "MDT487"

dbSelectArea("TRBAUD")
dbGoTop()
While !eof()
	If !Empty(TRBAUD->TM9_OK)
		nOk++
	Endif
	dbSkip()
End
dbSelectArea("TRBAUD")
dbGoTop()

If nOk <= 1
	ShowHelpDlg(STR0033,{STR0034},2,{STR0035},2)//"ATEN��O"###"N�o h� dados para impress�o."###"Para compara��o de exames � necess�rio a sele��o de mais de um exame."
	Return .F.
Elseif nOk > 8
	ShowHelpDlg(STR0033,{STR0036},2,{STR0037},2)//"ATEN��O"###"N�o � poss�vel imprimir."###"Para compara��o de exames deve ser informado de 2 a 8 exames."
	Return .F.
Endif

If Pergunte(cPerg,.T.)
	Processa({|lEnd| MDT487IMP()})  //Imprime
Endif

Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MDT487IMP � Autor � Jackson Machado       � Data � 22/08/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chama a impressao 							                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MDT487IMP()
Local cArquivo,lImpress,cArqSaida,cType
Local cPathDot := Alltrim(GetMv("MV_DIRACA"))	// Path do arquivo modelo do Word
Local cPathEst := Alltrim(GetMv("MV_DIREST"))	// PATH DO ARQUIVO A SER ARMAZENADO NA ESTACAO DE TRABALHOZ
Local cRootPath
Local i
Local cBarraRem := "\"
Local cBarraSrv := "\"
Local cWordExt  := ".dot"
Local cArqDot //Nome do arquivo modelo do Word (Tem que ser .dot)
Local nCor	:= 1
Local nDat	:= 0
//��������������������������������������������������������������Ŀ
//� Verifica vers�o do Word                                      �
//����������������������������������������������������������������
If mv_par03 == 2
	cWordExt := ".dotm"
Endif
cArqDot  := "compaudio"+cWordExt // Nome do arquivo modelo do Word (Tem que ser .dot ou .dotm para vers�o acima de 2007)

Private lMdtUnix := If( GetRemoteType() == 2 .or. isSRVunix() , .T. , .F. ) //Verifica se servidor ou estacao � Linux

//-----------------------//
//Preparacao do documento//
//-----------------------//
*******************************************************************************

If GetRemoteType() == 2  //estacao com sistema operacional linux
	cBarraRem := "/"
Endif
If isSRVunix()  //servidor eh da familia Unix (linux, solaris, free-bsd, hp-ux, etc.)
	cBarraSrv := "/"
Endif

cPathDot += If(Substr(cPathDot,len(cPathDot),1) != cBarraSrv,cBarraSrv,"") + cArqDot
cPathEst += If(Substr(cPathEst,len(cPathEst),1) != cBarraRem,cBarraRem,"")

//Cria diretorio se nao existir
MontaDir(cPathEst)

//Se existir .dot na estacao, apaga!
If File( cPathEst + cArqDot )
	Ferase( cPathEst + cArqDot )
EndIf
If !File(cPathDot)
		MsgStop(If(cWordExt==".dotm",STR0048,STR0049)+chr(10)+STR0050,STR0033)//"O arquivo compaudio.dotm n�o foi encontrado no servidor."###"O arquivo compaudio.dot n�o foi encontrado no servidor."###"Verifique o par�metro 'MV_DIRACA'."###"ATEN��O"
	Return
EndIf
CpyS2T(cPathDot,cPathEst,.T.) 	// Copia do Server para o Remote, eh necessario
// para que o wordview e o proprio word possam preparar o arquivo para impressao e
// ou visualizacao .... copia o DOT que esta no ROOTPATH Protheus para o PATH da
// estacao , por exemplo C:\WORDTMP

// Seleciona Arquivo Modelo
lImpress	:= If(mv_par01 == 1,.t.,.f.)	// Verifica se a saida sera em Tela ou Impressora
cArqSaida	:= Upper(If(Empty(mv_par02),"Documento1",AllTrim(mv_par02)))	// Nome do arquivo de saida
If cWordExt == ".dotm"
	If !(".DOCX" $ cArqSaida)
		cArqSaida := StrTran( cArqSaida, ".DOC", ".DOCX" )
	Endif
Else
	cArqSaida := StrTran( cArqSaida, ".DOCX", ".DOC" )
Endif

oWord := OLE_CreateLink("TMsOleWord97")// Cria link como Word
If lImpress
	OLE_SetProperty(oWord,oleWdVisible,  .F.)
	OLE_SetProperty(oWord,oleWdPrintBack,.T.)
Else
	OLE_SetProperty(oWord,oleWdVisible,  .F.)
	OLE_SetProperty(oWord,oleWdPrintBack,.F.)
EndIf
cType := "compaudio| *"+cWordExt

OLE_NewFile(oWord,cPathEst + cArqDot) //Abrindo o arquivo modelo automaticamente

cRootPath := GetPvProfString( GetEnvServer(), "RootPath", "ERROR", GetADV97() )
cRootPath := IF( RIGHT(cRootPath,1) == cBarraSrv,SubStr(cRootPath,1,Len(cRootPath)-1), cRootPath)
*******************************************************************************
//aCols com as posicoes de impressao em tela (final)
PRIVATE aPosDB := {200,207,214,221,228,235,242,249,256,263,270,277,284,291,;
					299,306,313,320,327,334,341,348,355,362,369,376,383,390,397}
PRIVATE aPosHz := {107,136,165,194,209,224,239,254,370,399,428,457,472,487,502,517}
//aCols com as posicoes do resultado
PRIVATE aDICBS := {-10,-5,0,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,;
                   80,85,90,95,100,105,110,115,120,125,130}
//aCols de cores RGB(Red, Green, Blue)
PRIVATE aColors := {{"0","0","200"},{"243","224","48"},{"255","0","0"},{"24","191","32"},;
							{"208","32","144"},{"160","32","240"},{"139","69","19"},;
							{"131","139","131"}}//AZUL(NAVY),YELLOW,VERMELHO,VERDE,ROSA,ROXO,MARRON,CINZA
//Posicoes das impressoes
PRIVATE nDBInicio := 0
PRIVATE nHZInicio := 0
PRIVATE nposDBfi := 0
PRIVATE nposHZfi := 0

//Variaveis para busca de campos
PRIVATE fCCusto := "SRA->RA_CC"
PRIVATE fNome   := "SRA->RA_NOME"
PRIVATE fFuncao := "SRA->RA_CODFUNC"
PRIVATE fRG     := "SRA->RA_RG"
PRIVATE fCPF    := "SRA->RA_CIC"
PRIVATE fNasc   := "SRA->RA_NASC"
PRIVATE fDtAdm  := "SRA->RA_ADMISSA"
PRIVATE fSexo   := "SRA->RA_SEXO"
PRIVATE lTm0 := .f.

//Variaveis para impressa da legenda
PRIVATE cData	:= ""
PRIVATE cCor	:= ""

//��������������������������������������������������������������Ŀ
//� Impressao do cabecalho de informacoes                        �
//����������������������������������������������������������������
dbSelectArea("TRBAUD")
dbGoTop()
dbSelectArea("TM9")
dbSetOrder(03)
If dbSeek(xFilial("TM9")+TRBAUD->TM9_NUMFIC)
    dbSelectArea("TM0")
    dbSetOrder(01)
    dbSeek(xFilial("TM0")+TM9->TM9_NUMFIC)

    //Verificacao se tem registro como funcionario
    dbSelectArea("SRA")
    dbSetOrder(01)
    If dbSeek(xFilial("SRA",TM0->TM0_FILFUN)+TM0->TM0_MAT)
		fCCusto := "SRA->RA_CC"
		fNome   := "SRA->RA_NOME"
		fFuncao := "SRA->RA_CODFUNC"
		fRG     := "SRA->RA_RG"
		fCPF    := "SRA->RA_CIC"
		fNasc   := 	"SRA->RA_NASC"
		fSexo   := "SRA->RA_SEXO"
		fDtAdm  := "SRA->RA_ADMISSA"
    Else
	   lTm0 := .t.
      fNome := "TM0->TM0_NOMFIC"
      fRG   := "TM0->TM0_RG"
     	fNasc := "TM0->TM0_DTNASC"
     	fCPF    := "TM0->TM0_CPF"
    	fCCusto := "TM0->TM0_CC"
    	fFuncao := "TM0->TM0_CODFUN"
    	fSexo   := "TM0->TM0_SEXO"
	Endif
 	If lSigaMdtps
		dbSelectArea("SA1")
		dbSetOrder(1)
		dbSeek(xFilial("SA1")+TM0->(TM0_CLIENT+TM0_LOJA))
		OLE_SetDocumentVar(oWord,"cEmpresa",Substr(SA1->A1_NOME,1,35))
	Else
		OLE_SetDocumentVar(oWord,"cEmpresa",Substr(SM0->M0_NOMECOM,1,35))
	Endif

	OLE_SetDocumentVar(oWord,"cMat",If(lTM0,TM0->TM0_CANDID,TM0->TM0_MAT))//Matricula do Funcionario
	OLE_SetDocumentVar(oWord,"cNome",Substr(&fNome,1,40))//Nome do Funcionario
	OLE_SetDocumentVar(oWord,"cRG",&fRG)  //Rg
	OLE_SetDocumentVar(oWord,"cCPF",&fCPF)
	If lTM0
		OLE_SetDocumentVar(oWord,"cSexo",If(&fSexo == "1",STR0051,If(&fSexo == "2",STR0052,"")))//"Masculino"###"Feminino"
	Else
   	OLE_SetDocumentVar(oWord,"cSexo",If(&fSexo == "M",STR0051,If(&fSexo == "F",STR0052,"")))//"Masculino"###"Feminino"
	Endif
   OLE_SetDocumentVar(oWord,"dDtAdm",If(!lTM0,&fDtAdm,STOD(Space(8))))
   cCargo := ""
   dbSelectArea("SRJ")
   dbSetOrder(01)
   dbSeek(xFilial("SRJ",TM0->TM0_FILFUN)+&fFuncao)
   OLE_SetDocumentVar(oWord,"cFuncao",Substr(SRJ->RJ_DESC,1,40))//Funcao
	If !lTM0
		If !Empty(SRA->RA_CARGO)
			dbSelectArea("SQ3")
			dbSetOrder(1)
			If dbSeek(xFilial("SQ3")+SRA->RA_CARGO)
				cCargo := SQ3->Q3_DESCSUM
			Endif
		Else
			dbSelectArea("SQ3")
			dbSetOrder(1)
			If dbSeek(xFilial("SQ3")+SRJ->RJ_CARGO)
				cCargo := SQ3->Q3_DESCSUM
			Endif
		Endif
	Else
		dbSelectArea("SQ3")
		dbSetOrder(1)
		If dbSeek(xFilial("SQ3")+SRJ->RJ_CARGO)
			cCargo := SQ3->Q3_DESCSUM
		Endif
	Endif
	OLE_SetDocumentVar(oWord,"cCargo",cCargo)//Cargo
	OLE_SetDocumentVar(oWord,"nIdade",fCalcIdade(&fNasc))//Data de Nasc.

   dbSelectArea("SI3")
   dbSetOrder(01)
   dbSeek(xFilial("SI3",TM0->TM0_FILFUN)+&fCCusto)
   OLE_SetDocumentVar(oWord,"cCusto",Substr(SI3->I3_DESC,1,40))//Centro de Custo

   OLE_SetDocumentVar(oWord,"dData",DATE())
   OLE_SetDocumentVar(oWord,"cTime",TIME())
   OLE_SetDocumentVar(oWord,"cViaExa" ,If(nViaRad == 1,STR0014,STR0015))//"A�rea"###"�ssea"

   dbSelectArea("TRBAUD")
	dbGoTop()
	While !Eof()
		If Empty(TRBAUD->TM9_OK)
			dbSkip()
			Loop
		Endif
		dbSelectArea("TM9")
		dbSetOrder(03)
		If dbSeek(xFilial("TM9")+TRBAUD->TM9_NUMFIC+DTOS(TRBAUD->TM9_DTPROG)+TRBAUD->TM9_HRPROG+TRBAUD->TM9_EXAME)
			//��������������Ŀ
			//�ORELHA DIREITA�
			//����������������
			nDBInicio := 0
			nHZInicio := 0
			//Concatena datas para impressao da legenda
			cData += AllTrim(DTOC(TM9->TM9_DTPROG)) + "#*"
			nDat++
			//Concatena cores para impressao da legenda
			cCor	+= aColors[nDat][1]+","+aColors[nDat][2]+","+aColors[nDat][3]+ "#*"
			//nVALOR,nCOL
			If nViaRad == 1  //Via Aerea
				MATRIZLIM(TM9->TM9_OD025K,1,nCor)
			Endif
			MATRIZLIM(TM9->TM9_OD05KH,2,nCor)
			MATRIZLIM(TM9->TM9_OD1KHZ,3,nCor)
			MATRIZLIM(TM9->TM9_OD2KHZ,4,nCor)
			MATRIZLIM(TM9->TM9_OD3KHZ,5,nCor)
			MATRIZLIM(TM9->TM9_OD4KHZ,6,nCor)
			If nViaRad == 1  //Via Aerea
				MATRIZLIM(TM9->TM9_OD6KHZ,7,nCor)
				MATRIZLIM(TM9->TM9_OD8KHZ,8,nCor)
			Endif

			//���������������Ŀ
			//�ORELHA ESQUERDA�
			//�����������������
			nDBInicio := 0
			nHZInicio := 0

			If nViaRad == 1  //Via Aerea
				MATRIZLIM(TM9->TM9_OE025K,9,nCor)
			Endif
			MATRIZLIM(TM9->TM9_OE05KH,10,nCor)
			MATRIZLIM(TM9->TM9_OE1KHZ,11,nCor)
			MATRIZLIM(TM9->TM9_OE2KHZ,12,nCor)
			MATRIZLIM(TM9->TM9_OE3KHZ,13,nCor)
			MATRIZLIM(TM9->TM9_OE4KHZ,14,nCor)
			If nViaRad == 1  //Via Aerea
				MATRIZLIM(TM9->TM9_OE6KHZ,15,nCor)
				MATRIZLIM(TM9->TM9_OE8KHZ,16,nCor)
			Endif
		Endif
		nCor++
		dbSelectArea("TRBAUD")
		dbSkip()
	End
	dbSelectArea("TRBAUD")
	dbGoTop()

   OLE_ExecuteMacro(oWord,"Somalinha")
	OLE_ExecuteMacro(oWord,"Somalinha")
	//Variaveis para impressao da legenda
	OLE_SetDocumentVar(oWord,"nTotDat",nDat)
	OLE_SetDocumentVar(oWord,"cCor",cCor)
	OLE_SetDocumentVar(oWord,"cData",cData)
	OLE_ExecuteMacro(oWord,"ImpLegenda")

	OLE_ExecuteMacro(oWord,"Posiciona_Cursor")
   OLE_ExecuteMacro(oWord,"Atualiza")

	OLE_SetProperty(oWord,oleWdVisible,.t.)
	OLE_ExecuteMacro(oWord,"Maximiza_Tela")
	If !lMdtUnix //Se for windows
		If DIRR487(cRootPath+cBarraSrv+"RELATO"+cBarraSrv)
			OLE_SaveAsFile(oWord,cRootPath+cBarraSrv+"RELATO"+cBarraSrv+cArqSaida,,,.f.,oleWdFormatDocument)
		Else
			OLE_SaveAsFile(oWord,cPathEst+cArqSaida,,,.f.,oleWdFormatDocument)
		Endif
	Endif
	OLE_ExecuteMacro(oWord,"Atualiza")
	MsgInfo(STR0053)//"Alterne para o programa do Ms-Word para visualizar o documento ou clique no botao para fechar."

	OLE_CloseLink(oWord)
Endif

Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �fCalcIdade| Autor � Jackson Machado       � Data �26/08/2011���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Calcula a idade.                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros� dNasc  - Data de Nascimento                                ���
���          � dFim   - Data Fim para calculo, caso nao seja passada,     ���
���          �          pegara como padrao a data atual (Date())          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function fCalcIdade(dNasc,dFim)

Local nIdade := 0

If dFim == nil
	dFim := Date()
Endif

nIdade := Year(dFim) - Year(dNasc)
If Month(dFim) < Month(dNasc)
	nIdade := nIdade - 1
Elseif Month(dFim) == Month(dNasc)
	If Day(dFim) < Day(dNasc)
		nIdade := nIdade - 1
	Endif
Endif

Return nIdade

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �DIRR487   |Autor  � Jackson Machado       � Data �26/08/2011���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Busca o caminho do arquivo.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cCaminho - Caminho do arquivo                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR487                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function DIRR487(cCaminho)
Local lDir := .F.
Local cBARRAS   := If(isSRVunix(),"/","\")
Local cBARRAD := If(isSRVunix(),"//","\\")
Private lMdtUnix := If( GetRemoteType() == 2 .or. isSRVunix() , .T. , .F. ) //Verifica se servidor ou estacao � Linux
If !empty(cCaminho) .and. !(cBARRAD$cCaminho)
	cCaminho := alltrim(cCaminho)
	if Right(cCaminho,1) == cBARRAS
		cCaminho := SubStr(cCaminho,1,len(cCaminho)-1)
	Endif
	lDir :=(Ascan( Directory(cCaminho,"D"),{|_Vet | "D" $ _Vet[5] } ) > 0)
EndIf

Return lDir

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
��� Fun��o   �MATRIZLIM� Autor  �Denis Hyroshi de Souza � Data �07/03/2003���
�������������������������������������������������������������������������Ĵ��
��� Descri��o�Monta a matriz com as referencia do exame (LIMIAR)          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nValor - Decibeis                                          ���
���          � nCOL   - 1 ate 8  -> Freq de 0.25 ate 8khz OD              ���
���          �          9 ate 16 -> Freq de 0.25 ate 8khz OE              ���
���          � nCor   - Valor da posicao do aCols de cores RGB            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MDTR488                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������/*/
Static Function MATRIZLIM(nVALOR,nCOL,nCor)

Local nposHZ, nposDB, nPos , nLIN
If nViaRad == 2  //Via Ossea
	If nVALOR == -2 //Ausente
		nVALOR := 75
	Endif
Else
	If nVALOR == -2 //Ausente
		nVALOR := 130
	Endif
Endif

nLIN := aScan(aDICBS,{|X| X == nVALOR})
If nLIN <= 0
	Return .t.
Endif

nPos   := nLIN
nposDB := aposDB[nPos]
nposHZ := aposHZ[nCOL]
//Passa as cores nas posicoes do RGB(Red, Green, Blue)
OLE_SetDocumentVar(oWord,"cRGB1",aColors[nCor][1])
OLE_SetDocumentVar(oWord,"cRGB2",aColors[nCor][2])
OLE_SetDocumentVar(oWord,"cRGB3",aColors[nCor][3])
If nDBInicio = 0 .and. nHZInicio = 0
	nDBInicio := nposDB
	nHZInicio := nposHZ
	OLE_SetDocumentVar(oWord,"HZini",nHZInicio)
	OLE_SetDocumentVar(oWord,"DBini",nDBInicio)
	OLE_SetDocumentVar(oWord,"HZfim",nposHZ)
	OLE_SetDocumentVar(oWord,"DBfim",nposDB)
	Return .t.
Else
	OLE_SetDocumentVar(oWord,"HZini",nHZInicio)
	OLE_SetDocumentVar(oWord,"DBini",nDBInicio)
	OLE_SetDocumentVar(oWord,"HZfim",nposHZ)
	OLE_SetDocumentVar(oWord,"DBfim",nposDB)

   //Impressao da linha
	OLE_ExecuteMacro(oWord,"Orelha")

Endif

nDBInicio := nposDB
nHZInicio := nposHZ

Return .t.