#Include "Protheus.ch"
#Include "FILEIO.CH"
#Include "FINA317.CH"
#Include "FWMVCDEF.CH"

STATIC lExistVa		:= ExistFunc("FValAcess")

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Oswaldo Leite         � Data �09/08/11  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function MenuDef() As Array

Local aRotina := {  { "Pesquisar"     , "AxPesqui" , 0 , 1,,.F.} ,;
					{ "Visualizar"    ,	"AxVisual"  , 0 , 2} ,;
					{ "Compensar"	  ,	"CNI317PR"  , 0 , 4} ,;
 					{ "Estornar"	  ,	"Cni317RE"  , 0 , 4} ,;
					{ "Legenda"		  ,	"CNI317Leg"	, 0	, 7, ,.F.}}

Return(aRotina)

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � CNI317RE   � Autor � Mauricio Pequim Jr.	 � Data � 20/12/98  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cancelamento de Liquida��o                 				    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CNI317RE()													���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CNI317RE(cAlias,cCampo,nOpcx,aCampos)

Local cIndex 	:= ""
Local cTitulo 	:= STR0001			/////"Cancelamento"
Local nOpct 	:= 0

Private cCompCan := CriaVar("E1_NUM" , .F.)

cCompCan	:= SE2->E2_IDENTEE

DEFINE MSDIALOG oDlg4 FROM	20,1 TO 120,340 TITLE cTitulo PIXEL

	nEspLarg := 2
	nEspLin  := 2
	oDlg4:lMaximized := .F.
	oPanel4 := TPanel():New(0,0,'',oDlg4,, .T., .T.,, ,20,20)
	oPanel4:Align := CONTROL_ALIGN_ALLCLIENT

	@ nEspLin,  nEspLarg TO 36+nEspLin, 125+nEspLarg OF oPanel4 PIXEL
	@ 21+nEspLin, 14+nEspLarg MSGET cCompCan Valid If(nOpcT<>0,NaoVazio(cCompCan),.T.) SIZE 49, 11 OF oPanel4 PIXEL
	@ 11+nEspLin, 14+nEspLarg SAY STR0002 SIZE 49, 07 OF oPanel4 PIXEL                                 /////"Nro. Compensa��o"

	DEFINE SBUTTON FROM 10, 133 TYPE 1 ACTION (nOpct:=1,;
	IIF(CNI317CalCn(cCompCan,@cIndex),oDlg4:End(),nOpct:=0)) ENABLE OF oDlg4
	DEFINE SBUTTON FROM 23, 133 TYPE 2 ACTION (nOpcT:=0,oDlg4:End()) ENABLE OF oDlg4

ACTIVATE MSDIALOG oDlg4 CENTERED

If nOpct > 0//Inicia Regua de Andamento do Processamento
	Processa(  {|| Cni317Can(cAlias,cCampo,nOpcx,aCampos, nOpcT, cIndex) } , STR0003, STR0004, .F. )           ////"Aguarde"    "Executando processo"
Else
	Cni317Can(cAlias,cCampo,nOpcx,aCampos, nOpcT, cIndex)
EndIf

Return

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � CNI317CAN  � Autor � Mauricio Pequim Jr.	 � Data � 20/12/98  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Cancelamento de Liquida��o                 				    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CNI317CAN()													���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CNI317CAN(cAlias,cCampo,nOpcx,aCampos, nOpct, cIndex) As Logical
//��������������������������������������������������������������Ŀ
//� Define Variaveis 										  	 �
//����������������������������������������������������������������
Local cArquivo	:= ""
Local nTotal	:= 0
Local nHdlPrv	:= 0
Local lCabec 	:= .F.
Local lPadrao	:= VerPadrao("535")  // Cancelamento de Comp. Carteiras
Local cPadrao 	:= "535"
Local lDigita 	:= .T.
Local nTotAbat 	:= 0
Local nValRec 	:= 0
Local nValPag 	:= 0
Local lBxUnica 	:= .F.
Local nRec450 	:= Recno()
Local nJuros 	:= 0
Local nDescont 	:= 0
Local nMulta	:= 0
Local cFornece	:= ""
Local cLoja		:= ""
local aBaixaSE3 := {}
Local nDecs		:=	2
Local nTaxa		:=	1
Local nValDifC	:=	0
Local lF450SE1C := ExistBlock("F450SE1C")
Local lF450SE2C := ExistBlock("F450SE2C")
Local aEstorno 	:= {}
Local lEstorna 	:= .F.
Local nX		:= 0
Local aCancela 	:= {}
Local cFilAtu	:= cFilAnt
Local nRecPnl	:= SE2->(Recno())
Local aFlagCTB 	:= {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local aSM0		:= {}
Local cCompEfetuada := ""
Local cLayOut 	:= SM0->M0_LEIAUTE
Local lAchou	:= .F.

Private cLote		:= ""
Private StrLctPad   := ""

aSM0	:= CniAbreSM0()
// Zerar variaveis para contabilizar os impostos da lei 10925.
VALOR5 := 0
VALOR6 := 0
VALOR7 := 0

// Estorna a operacao caso a matriz de rotina esteja com o conteudo 5 na posicao 4.
lEstorna := aRotina[nOpcx][4]==5
If lEstorna
	cTitulo := STR0102				////"Estornar"
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica o numero do Lote 											  �
//����������������������������������������������������������������
LoteCont("FIN")

//Abertura dos arquivos para utilizacao nas funcoes SumAbatPag e SumAbatRec
//Se faz necessario devido ao controle de transacao nao permitir abertura de arquivos
If Select("__SE1") == 0
	ChkFile("SE1",.F.,"__SE1")
EndIf
If Select("__SE2") == 0
	ChkFile("SE2",.F.,"__SE2")
EndIf

//��������������������������������������������������������������Ŀ
//� Carrega funcao Pergunte												  �
//����������������������������������������������������������������
SetKey (VK_F12,{|a,b| AcessaPerg("AFI450",.T.)})
pergunte("AFI450",.F.)

//���������������������������������������������������������������������������Ŀ
//� Ponto de entrada que controla se o titulo sera cancelado/extornado ou nao �
//�����������������������������������������������������������������������������
If ExistBlock("F450CAES")
	nOpct :=  ExecBlock("F450CAES",.F.,.F.,{cCompCan,nOpct})
EndIf

//�����������������������������������������������������Ŀ
//�Integracao com o SIGAPCO para lancamento via processo�
//�PcoIniLan("000018")                                  �
//�������������������������������������������������������
PcoIniLan("000018")

If nOpct == 1
	//-- Parametros da Funcao LockByName() :
	//   1o - Nome da Trava
	//   2o - usa informacoes da Empresa na chave
	//   3o - usa informacoes da Filial na chave

	If LockByName(cCompCan,.T.,.F.)

		SE5->(dbGoTop())

		ProcRegua( 0 )

		aEstorno := {}

		Begin Transaction

		While SE5->(!Eof())

			If SE5->E5_TIPODOC $ "DC/JR/MT/CM"

				SE5->(dbSkip())
				IncProc(STR0005)                        ////'Selecionando Registros'
				Loop
			EndIf
			lAchou	:= .F.

			If (SE5->E5_RECPAG == "R" .And. !(SE5->E5_TIPO $ MV_CPNEG+"/"+MVPAGANT) ) .Or.( SE5->E5_RECPAG == "P" .And. ( SE5->E5_TIPO $ MV_CRNEG+"/"+MVRECANT ) )

				cCompEfetuada := cCompCan

				//����������������������������������������������������������Ŀ
				//� Cancela a compensacao de titulo a receber				 �
				//������������������������������������������������������������
				dbSelectArea("SE1")
				dbSetOrder(2)

				If dbSeek(SE5->E5_FILIAL + SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO))

					lAchou		:= .T.
					nDecs		:=	MsDecimais(SE1->E1_MOEDA)
					nTaxa		:=	SE5->E5_VALOR/SE5->E5_VLMOED2
					nTotAbat 	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,	SE1->E1_PARCELA,SE1->E1_MOEDA,"V",SE5->E5_DATA)
					If cPaisLoc == "BRA"
						If SE1->E1_MOEDA <= 1
							nValRec		:= xMoeda(SE5->E5_VALOR,1,SE1->E1_MOEDA,SE5->E5_DATA)
						Else
							nValRec		:= Round(NoRound(xMoeda(SE5->E5_VALOR,1,SE1->E1_MOEDA,SE5->E5_DATA,3),3),2)
						EndIf
						nJuros		:= xMoeda(SE5->E5_VLJUROS,1,SE1->E1_MOEDA,SE5->E5_DATA)
						nDescont	:= xMoeda(SE5->E5_VLDESCO,1,SE1->E1_MOEDA,SE5->E5_DATA)
						nMulta		:= xMoeda(SE5->E5_VLMULTA,1,SE1->E1_MOEDA,SE5->E5_DATA)
					Else
						nValRec		:= SE5->E5_VLMOED2
						nJuros		:= xMoeda(SE5->E5_VLJUROS,1,SE1->E1_MOEDA,SE5->E5_DATA,nDecs+1,Nil,nTaxa)
						nDescont	:= xMoeda(SE5->E5_VLDESCO,1,SE1->E1_MOEDA,SE5->E5_DATA,nDecs+1,Nil,nTaxa)
						nMulta		:= xMoeda(SE5->E5_VLMULTA,1,SE1->E1_MOEDA,SE5->E5_DATA,nDecs+1,Nil,nTaxa)
						nValDifC	:= SE5->E5_VLCORRE
					EndIf
					nValRec		+= nDescont - nJuros - nMulta
					nRec450 	:= SE1->(Recno())
					lBxUnica 	:= IIf(STR(nValRec+nTotAbat+SE1->E1_SALDO,17,2) == STR(SE1->E1_VALOR,17,2),.T.,.F.)
					StrLctPad   := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
					If nTotAbat > 0 .AND. SE1->E1_SALDO == 0
						nValRec += nTotAbat
						//������������������������������������������������������������������Ŀ
						//�Verifica se h� abatimentos para voltar a carteira                 �
						//��������������������������������������������������������������������
						SE1->(dbSetOrder(1))
						If SE1->(dbSeek(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA))
							cTitAnt := (SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
							While SE1->(!Eof()) .and. cTitAnt == (SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA)
								If !SE1->E1_TIPO  $MVABATIM
									SE1->(dbSkip())
									Loop
								EndIf
								//������������������������������������������������������������������Ŀ
								//�Volta t�tulo para carteira                                       �
								//��������������������������������������������������������������������
								Reclock("SE1")
								SE1->E1_BAIXA   := Ctod(" /  /  ")
								SE1->E1_SALDO   := E1_VALOR
								SE1->E1_DESCONT := 0
								SE1->E1_JUROS   := 0
								SE1->E1_MULTA   := 0
								SE1->E1_CORREC  := 0
								SE1->E1_VARURV  := 0
								SE1->E1_VALLIQ  := 0
								SE1->E1_LOTE    := Space(Len(E1_LOTE))
								SE1->E1_DATABOR := Ctod(" /  /  ")
								SE1->E1_STATUS  := "A"
								SE1->E1_IDENTEE := ""
								//����������������������������������������������Ŀ
								//� Carrega variaveis para contabilizacao dos    �
								//� abatimentos (impostos da lei 10925).         �
								//������������������������������������������������
								If SE1->E1_TIPO == MVPIABT
									VALOR5 := SE1->E1_VALOR
								ElseIf SE1->E1_TIPO == MVCFABT
									VALOR6 := SE1->E1_VALOR
								ElseIf SE1->E1_TIPO == MVCSABT
									VALOR7 := SE1->E1_VALOR
								EndIf
								MsUnlock()
								SE1->(dbSkip())
							EndDo
						EndIf
					EndIf
					SE1->(dbGoto(nRec450))
					RecLock("SE1")
					SE1->E1_SALDO += nValRec
					SE1->E1_IDENTEE := ""
					If cPaisLoc == "CHI" .And. nValDifC <> 0
						E1_CAMBIO	-=	nValDifC
					EndIf
					If lBxUnica
						SE1->E1_BAIXA   := Ctod(" /  /  ")
						SE1->E1_VALLIQ  := 0
						SE1->E1_SDACRES := SE1->E1_ACRESC
						SE1->E1_SDDECRE := SE1->E1_DECRESC
						SE1->E1_DESCONT := 0
						SE1->E1_JUROS   := 0
						SE1->E1_MULTA   := 0
						SE1->E1_CORREC  := 0
						SE1->E1_VARURV  := 0
						SE1->E1_VALLIQ  := 0
						SE1->E1_STATUS  := "A"
					EndIf
					MsUnLock()
					//Ponto de entrada para gravacoes complementares
					If lF450SE1C
						ExecBlock("F450SE1C",.F.,.F.)
					EndIf

					//����������������������������������������������������������Ŀ
					//� Inicializa variaveis para contabilizacao				 �
					//������������������������������������������������������������
					VALOR 		:= SE5->E5_VALOR
					VLRINSTR 	:= VALOR
					If SE1->E1_MOEDA <= 5 .And. SE1->E1_MOEDA > 1
						cVal := Str(SE1->E1_MOEDA,1)
						If cPaisLoc == "BRA"
							VALOR&cVal := xMoeda(SE5->E5_VALOR,1,SE1->E1_MOEDA,SE5->E5_DATA)
						Else
							VALOR&cVal := SE5->E5_VLMOED2
						EndIf
					EndIf
					//����������������������������������������������������������Ŀ
					//� Cancela compensacao						 							 �
					//������������������������������������������������������������
					dbSelectArea("SE5")
					nRecSE5 := SE5->(recno())
					SE5->(dbGotop())
					While SE5->(!Eof()) .and. SE5->E5_IDENTEE == cCompCan
						If xFilial("SE5", SE1->E1_FILORIG)+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == ;
							xFilial("SE1", SE1->E1_FILORIG)+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
							If ! lEstorna
							    aadd(aCancela,SE5->(Recno()))
							Else
								aadd(aEstorno,SE5->(Recno()))
							EndIf
							aadd(aBaixaSE3,{ SE5->E5_MOTBX , SE5->E5_SEQ , SE5->(Recno()) })
						EndIf

						SE5->(dbSkip())
					EndDo
					SE5->(dbGoto(nRecSE5))
				EndIf
			Else
				//����������������������������������������������������������Ŀ
				//� Cancela a compensacao de titulo a Pagar					 �
				//������������������������������������������������������������
				dbSelectArea("SE2")
				dbSetOrder(6)

				cCompEfetuada := cCompCan

				If dbSeek(SE5->E5_FILIAL+SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO))
					lAchou	:= .T.
					nDecs	:=	MsDecimais(SE2->E2_MOEDA)
					nTaxa	:=	SE5->E5_VALOR/SE5->E5_VLMOED2

					nTotAbat 	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA, 	SE2->E2_FORNECE,SE2->E2_MOEDA,"V",SE5->E5_DATA,SE2->E2_LOJA)
					If cPaisLoc == "BRA"
						If SE2->E2_MOEDA <= 1
							nValPag		:= xMoeda(SE5->E5_VALOR,1,SE2->E2_MOEDA,SE5->E5_DATA)
						Else
							nValPag		:= Round(NoRound(xMoeda(SE5->E5_VALOR,1,SE2->E2_MOEDA,SE5->E5_DATA,3),3),2)
						EndIf
						nJuros		:= xMoeda(SE5->E5_VLJUROS,1,SE2->E2_MOEDA,SE5->E5_DATA)
						nDescont	:= xMoeda(SE5->E5_VLDESCO,1,SE2->E2_MOEDA,SE5->E5_DATA)
						nMulta		:= xMoeda(SE5->E5_VLMULTA,1,SE2->E2_MOEDA,SE5->E5_DATA)
					Else
						nValPag		:= SE5->E5_VLMOED2
						nJuros		:= xMoeda(SE5->E5_VLJUROS,1,SE2->E2_MOEDA,SE5->E5_DATA,nDecs+1,Nil,nTaxa)
						nDescont	:= xMoeda(SE5->E5_VLDESCO,1,SE2->E2_MOEDA,SE5->E5_DATA,nDecs+1,Nil,nTaxa)
						nMulta		:= xMoeda(SE5->E5_VLMULTA,1,SE2->E2_MOEDA,SE5->E5_DATA,nDecs+1,Nil,nTaxa)
						nValDifC	:= SE5->E5_VLCORRE
					EndIf
					nValPag		+= nDescont - nJuros - nMulta
					cFornece	:= SE2->E2_FORNECE
					cLoja		:= SE2->E2_LOJA
					StrLctPad   := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO)
					nRec450 	:= SE2->(Recno())
					//����������������������������������������������������������������Ŀ
					//� Caso esteja utilizando outras moedas, faz o acerto do valor do �
					//� titulo se a diferen�a for de 0.01				           	   �
					//������������������������������������������������������������������
					If SE2->E2_MOEDA > 1 .And. Round(((nValPag+nTotAbat+SE2->E2_SALDO)-SE2->E2_VALOR),2) = 0.01
						nValPag -= 0.01
					EndIf

					lBxUnica := IIf(STR(nValPag+nTotAbat+SE2->E2_SALDO,17,2) == STR(SE2->E2_VALOR,17,2),.T.,.F.)
					If lBxUnica .and. nTotAbat > 0
						nValPag += nTotAbat
						*������������������������������������������������������������������Ŀ
						*�Verifica se h� abatimentos para voltar a carteira					  �
						*��������������������������������������������������������������������
						SE2->(dbSetOrder(1))
						If SE2->(dbSeek(SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA))
							cTitAnt := (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
							While !SE2->(Eof()) .and. cTitAnt == (SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA)
								If !SE2->E2_TIPO $ MVABATIM
									SE2->(dbSkip())
									Loop
								EndIf
								If SE2->E2_FORNECE+SE2->E2_LOJA != cFornece+cLoja
									SE2->(dbSkip())
									Loop
								EndIf
								//�����������������������������������������Ŀ
								//�Volta titulo para carteira 				  �
								//�������������������������������������������
								Reclock("SE2")
								SE2->E2_BAIXA	:= Ctod(" /  /  ")
								SE2->E2_SALDO	:= E2_VALOR
								SE2->E2_VALLIQ	:= 0
								SE2->E2_IDENTEE := ""
								SE2->E2_DESCONT := 0
								SE2->E2_JUROS   := 0
								SE2->E2_MULTA   := 0
								SE2->E2_CORREC  := 0
								MsUnlock()
								SE2->(dbSkip())
							EndDo
						EndIf

					EndIf

					SE2->(dbGoto(nRec450))
					RecLock("SE2")
					SE2->E2_SALDO += nValPag
					SE2->E2_IDENTEE := ""
					If cPaisLoc == "CHI" .And. nValDifC <> 0
						E2_CAMBIO	-=	nValDifC
					EndIf
					If lBxUnica
						SE2->E2_BAIXA   := Ctod(" /  /  ")
						SE2->E2_VALLIQ  := 0
						SE2->E2_SDACRES := SE2->E2_ACRESC
						SE2->E2_SDDECRE := SE2->E2_DECRESC
						SE2->E2_DESCONT := 0
						SE2->E2_JUROS   := 0
						SE2->E2_MULTA   := 0
						SE2->E2_CORREC  := 0
					EndIf
					MsUnLock()
					//Ponto de entrada para gravacoes complementares
					If lF450SE2C
						ExecBlock("F450SE2C",.F.,.F.)
					EndIf

					//����������������������������������������������������������Ŀ
					//� Inicializa variaveis para contabilizacao 				 �
					//������������������������������������������������������������
					VALOR 		:= SE5->E5_VALOR
					VLRINSTR 	:= VALOR
					If SE2->E2_MOEDA <= 5 .And. SE2->E2_MOEDA > 1
						cVal := Str(SE2->E2_MOEDA,1)
						If cPaisLoc == "BRA"
							VALOR&cVal := xMoeda(SE5->E5_VALOR,1,SE2->E2_MOEDA,SE5->E5_DATA)
						Else
							VALOR&cVal := SE5->E5_VLMOED2
						EndIf
					EndIf

					//����������������������������������������������������������Ŀ
					//� Cancela compensacao						 							 �
					//������������������������������������������������������������
					dbSelectArea("SE5")
					nRecSE5 := Recno()
					SE5->(dbGotop())
					While SE5->(!Eof()) .And. SE5->E5_IDENTEE == cCompCan
						If SE5->(!Eof()) .and. xFilial("SE5", SE2->E2_FILORIG) + SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == ;
							xFilial("SE2", SE2->E2_FILORIG)+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
							If ! lEstorna
								Aadd(aCancela, SE5->(Recno()))
							Else
								Aadd(aEstorno, SE5->(Recno()))
							EndIf
						EndIf

						SE5->(dbSkip())
					EndDo

					SE5->(dbGoto(nRecSE5))
				EndIf
			EndIf

			If lAchou
				If (SE5->E5_RECPAG == "R" .And. !(SE5->E5_TIPO $ MV_CPNEG+"/"+MVPAGANT) ) .Or.( SE5->E5_RECPAG == "P" .And. (SE5->E5_TIPO $ MV_CRNEG+"/"+MVRECANT))
					//����������������������������������������������������������Ŀ
					//� Posiciona SA1 para contabiliza��o        					 �
					//������������������������������������������������������������
					dbSelectArea("SA1")

					dbSeek(  CNI317VrfFilial( xFilial("SA1"), SE1->E1_FILIAL, cLayOut)  +  SE1->E1_CLIENTE  +  SE1->E1_LOJA)

					If SE5->E5_RECPAG == "R" .And. SE5->E5_TIPO $ MV_CPNEG+"/"+MVPAGANT  .Or.  SE5->E5_RECPAG == "P" .And. SE5->E5_TIPO $ MV_CRNEG+"/"+MVRECANT
						AtuSalDup("-",nValRec,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
					Else
						AtuSalDup("+",nValRec,SE1->E1_MOEDA,SE1->E1_TIPO,,SE1->E1_EMISSAO)
					EndIf

					dbSelectArea("SE2")
					dbGobottom()
					dbSkip()
				Else

					//����������������������������������������������������������Ŀ
					//� Posiciona SA2 para contabiliza��o        					 �
					//������������������������������������������������������������
					DbSelectArea("SA2")
					DbSetOrder(1)
					SA2->(DbGoTop())

					SA2->( DbSeek(  CNI317VrfFilial ( xFilial("SA2"), SE2->E2_FILIAL, cLayOut)  +  SE2->E2_FORNECE  +  SE2->E2_LOJA) )

					RecLock("SA2")
					IF SE5->E5_RECPAG == "R" .And. SE5->E5_TIPO $ MV_CPNEG+"/"+MVPAGANT  .Or.  SE5->E5_RECPAG == "P" .And. SE5->E5_TIPO $ MV_CRNEG+"/"+MVRECANT
						SA2->A2_SALDUP	-= nValPag
						SA2->A2_SALDUPM -= xMoeda(nValPag,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO,3)
					Else
						SA2->A2_SALDUP	+= nValPag
						SA2->A2_SALDUPM += xMoeda(nValPag,1,Val(GetMv("MV_MCUSTO")),SE2->E2_EMISSAO,3)
					EndIf
					MsUnLock()

					SA2->(dbCLoseArea())

					dbSelectArea("SE1")
					dbGobottom()
					dbSkip()
				EndIf
			EndIf

			//����������������������������������������������������������Ŀ
			//� Contabiliza															 �
			//������������������������������������������������������������
			If !lCabec .and. lPadrao
				nHdlPrv := HeadProva(  cLote,;
				                      "FINA450",;
				                      Substr( cUsuario, 7, 6 ),;
				                      @cArquivo )

				lCabec := .t.
			EndIf
			If lCabec .and. lPadrao .and. (VALOR+VALOR2+VALOR3+VALOR4+VALOR5) > 0
				nTotal += DetProva( nHdlPrv,;
				                    cPadrao,;
				                    "FINA450",;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    .F.,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )

			EndIf

			dbSelectArea("SE5")
			IncProc(STR0005)                        ////'Selecionando Registros'IncProc("Selecionando Registros...")
			SE5-> (dbSkip())

		EndDo

		//��������������������������������������������������������������Ŀ
		//� Recupera a Integridade dos dados									  �
		//����������������������������������������������������������������
		dbSelectArea("SE5")
		RetIndex("SE5")
		Set Filter to
		If !Empty(cIndex)
			Ferase(cIndex+OrdBagExt())
		EndIf

		For nx := 1 To Len(aCancela)
			SE5->(dbGoto(aCancela[nx]))
			CniGrvEst(aCancela[nX], lUsaFlag, aFlagCTB, .F. ) // Gera registro de estorno da compensacao
		Next

		For nx :=1 To Len(aEstorno)
			SE5->(dbGoto(aEstorno[nx]))
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
			EndIf

			CniGrvEst(aEstorno[nX], lUsaFlag, aFlagCTB, .T. ) // Gera registro de estorno da compensacao
		Next

		If lPadrao .and. lCabec .and. nTotal > 0
			//�����������������������������������������������������Ŀ
			//� Envia para Lancamento Contabil							  �
			//�������������������������������������������������������
			lDigita:=.T.
			lAglut :=IIF(mv_par02==1,.T.,.F.)
			cA100Incl( cArquivo,;
			           nHdlPrv,;
			           3,;
			           cLote,;
			           lDigita,;
			           lAglut,;
			           /*cOnLine*/,;
			           /*dData*/,;
			           /*dReproc*/,;
			           @aFlagCTB,;
			           /*aDadosProva*/,;
			           /*aDiario*/ )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

		EndIf

		If !Empty( cCompEfetuada )
		  	CNI317ExcTitsComp(cCompEfetuada)
		EndIf

		UnLockByName(cCompCan,.T.,.F.)
		End Transaction

		//�����������������������������������������������������Ŀ
		//�Integracao com o SIGAPCO para lancamento via processo�
		//�PCODetLan("000018","01","FINA450",.T.)               �
		//�������������������������������������������������������
		PCODetLan("000018","01","FINA450",.F.)

	Else
		MsgAlert( STR0006+STR0007 , STR0008 )      ///"Existe outro usu�rio cancelando esta compensa��o." "N�o � permitido o cancelamento da mesma compensa��o por dois usu�rios ao mesmo tempo."     "Aten��o"
	EndIf
EndIf

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados									  �
//����������������������������������������������������������������
dbSelectArea("SE5")
RetIndex("SE5")
Set Filter to
If !Empty(cIndex)
	Ferase(cIndex+OrdBagExt())
EndIf
//��������������������������������������������������������������Ŀ
//� Estorna Comissao                                             �
//����������������������������������������������������������������
Fa440DeleB(aBaixaSE3,.F.,.F.,"FINA070")

cFilAnt := cFilAtu

//�����������������������������������������������������Ŀ
//�Integracao com o SIGAPCO para lancamento via processo�
//�PcoFinLan("000018")                                  �
//�������������������������������������������������������
PcoFinLan("000018")

SE2->(MSGOTO(nRecPnl))

Return (.T.)

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �ExcTitsComp� Autor � Oswaldo Leite         � Data � 10/08/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Excluir todos os titulos que participaram do estorno		   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe	 � ExcTitsComp              								   ���
��������������������������������������������������������������������������Ĵ��
���Parametros� aExclSE1,consiste em array de titulos localizados na SE1	   ���
���Parametros� aExclSE2,consiste em array de titulos localizados na SE2	   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/

Static Function CNI317ExcTitsComp(cCompEfetuada)

Local aVetor := {}
Local cQuery	:= ""
Local cFilBackup
Local aArea := GetArea()
Private cmsg		:= ''
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

cQuery    := "SELECT E1_FILIAL, E1_NUM, E1_PREFIXO, E1_PARCELA, E1_TIPO, E1_CLIENTE, E1_LOJA  FROM "
cQuery    +=  RetSqlName("SE1") + " WHERE E1_NUM = '" + cCompEfetuada + "' and E1_PREFIXO = 'DME' AND D_E_L_E_T_ <> '*' "
cQuery    := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TIT_DME',.T.,.T.)
dbSelectArea('TIT_DME')

While TIT_DME->(!Eof())

	aVetor := {	{"E1_FILIAL"      ,TIT_DME->E1_FILIAL          ,Nil},;
	            {"E1_NUM"         ,TIT_DME->E1_NUM             ,Nil},;
	   	        {"E1_PREFIXO"     ,TIT_DME->E1_PREFIXO			,Nil},;
	       	   	{"E1_PARCELA"     ,TIT_DME->E1_PARCELA			,Nil},;
	           	{"E1_TIPO"        ,TIT_DME->E1_TIPO				,Nil},;
	            {"E1_CLIENTE"     ,TIT_DME->E1_CLIENTE			,Nil},;
	            {"E1_LOJA"        ,TIT_DME->E1_LOJA				,Nil}}

	cFilBackup := cFilAnt
	cFilAnt := TIT_DME->E1_FILIAL
	MSExecAuto({|x,y| Fina040(x,y)},aVetor,5)  //5-EXCLUSAO
	cFilAnt := cFilBackup

	IncProc(STR0009) 				//////'Processando Registros'
	dbSelectArea('TIT_DME')
	dbSkip()
End

dbSelectArea('TIT_DME')
TIT_DME->(dbCloseArea())

cmsg		:= ''
lMsHelpAuto := .T.
lMsErroAuto := .F.
cQuery    := "SELECT E2_FILIAL, E2_NUM, E2_PREFIXO, E2_PARCELA, E2_TIPO, E2_FORNECE, E2_LOJA  FROM "
cQuery    += RetSqlName("SE2") + " WHERE E2_NUM = '" + cCompEfetuada + "' and E2_PREFIXO = 'DME'  AND D_E_L_E_T_ <> '*' "
cQuery    := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TIT_DME',.T.,.T.)
dbSelectArea('TIT_DME')

While TIT_DME->(!Eof())

	aVetor := {	{"E2_FILIAL"      ,TIT_DME->E2_FILIAL          ,Nil},;
	            {"E2_NUM"         ,TIT_DME->E2_NUM             ,Nil},;
    	        {"E2_PREFIXO"     ,TIT_DME->E2_PREFIXO			,Nil},;
        	   	{"E2_PARCELA"     ,TIT_DME->E2_PARCELA			,Nil},;
            	{"E2_TIPO"        ,TIT_DME->E2_TIPO				,Nil},;
	            {"E2_FORNECE"     ,TIT_DME->E2_FORNECE			,Nil},;
	            {"E2_LOJA"        ,TIT_DME->E2_LOJA				,Nil}}

	cFilBackup := cFilAnt
	cFilAnt := TIT_DME->E2_FILIAL
	MSExecAuto({|x, y, z| FINA050(x, y, z)}, aVetor, 5, 5)
	cFilAnt := cFilBackup

	IncProc(STR0009)			//////'Processando Registros')
	dbSelectArea('TIT_DME')
	dbSkip()
End

dbSelectArea('TIT_DME')
TIT_DME->(dbCloseArea())

RestArea(aArea)

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o	 �CniGrvEst  � Autor � Oswaldo Leite         � Data �  9/08/11 ���
��������������������������������������������������������������������������Ĵ��
���Descri��o � Grava o movimento de estorno da baixa por CEC       		   ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CniGrvEst(ExpN1)          										   ���
��������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Numero do registro do movimento a ser estornado	   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CNiGrvEst(nRecnoSe5, lUsaFlag, aFlagCTB, lEstorno)

	Local aAreaAnt	:= {}
	Local oModelMov	:= NIL 
	Local cLog		:= ""
	Local lRet		:= .T.
	Local cAliasFK	:= ""
	Local cFkGrv	:= ""
	Local lTitCred	:= .F.
	Local cChaveSe5 := SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
	Local cTipodoc  := "DC|MT|JR|CM|VA"
	Local cCamposE5	:= ""
	Local cFilBkp	:= cFilant

	lTitCred := SE5->E5_TIPO $ MVRECANT+"/"+MVPAGANT+"/"+MV_CRNEG+"/"+MV_CPNEG 

	If lTitCred 
		cAliasFK := if(SE5->E5_RECPAG= "R","FK2", "FK1")
	Else
		cAliasFK := if(SE5->E5_RECPAG= "R","FK1", "FK2")
	EndIf

	If AllTrim( SE5->E5_TABORI ) == cAliasFK
		aAreaAnt := GetArea()
		dbSelectArea("FKA")
		("FKA")->(DbSetOrder(3)) //FKA_FILIAL+FKA_TABORI+FKA_IDORIG
		cFilant := SE5->E5_FILORIG

		If FKA->(MsSeek( xFilial("FKA", SE5->E5_FILORIG) + SE5->E5_TABORI+ SE5->E5_IDORIG ))
			If !( SE5->E5_TIPODOC $ cTipodoc )
				If lTitCred
					oModelMov 	:= FWLoadModel(If(SE5->E5_RECPAG= "R","FINM020","FINM010"))
					cFkGrv		:= If(SE5->E5_RECPAG= "R","FK2","FK1")
				Else
					oModelMov := FWLoadModel(If(SE5->E5_RECPAG= "R","FINM010","FINM020"))
					cFkGrv		:= If(SE5->E5_RECPAG= "R","FK1","FK2")
				EndIf
			
				oModelMov:SetOperation( MODEL_OPERATION_UPDATE )
				oModelMov:Activate()      
				oSubFKA := oModelMov:GetModel( "FKADETAIL" )
			
				If lEstorno
					cCamposE5 := "{ {'E5_SITUACA', 'X'} "
					cCamposE5 += " ,{ 'E5_DATA', '" + dDatabase + "' } "
					cCamposE5 += " ,{ 'E5_RECPAG', '" + Iif(SE5->E5_RECPAG=="P","R",Iif(SE5->E5_RECPAG=="R","P","")) + "' } "
					cCamposE5 += " ,{ 'E5_LA', '" + If( !lUsaFlag, "S", "N" ) + "' } "
					cCamposE5 += " ,{ 'E5_TIPODOC', 'ES' } "
					cCamposE5 += " ,{ 'E5_DTDIGIT', '" + dDataBase + "' } "
					cCamposE5 += " ,{ 'E5_DTDISPO', '" + dDataBase + "' } "
					cCamposE5 += " ,{ 'E5_HISTOR', '" + STR0010 + "' } "				/////"Estorno de CEC"
				Else
					cCamposE5 := "{ {'E5_SITUACA', 'C'} "
				EndIf
				cCamposE5 += " } "
				oModelMov:SetValue("MASTER", "E5_CAMPOS", cCamposE5)
						
				oModelMov:SetValue('MASTER','HISTMOV', STR0010)
				oModelMov:SetValue("MASTER", "E5_GRV", .T. )
				oModelMov:SetValue("MASTER", "E5_OPERACAO", If(lEstorno, 2, 1))
					
				If oModelMov:VldData()
					oModelMov:CommitData()
					SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
				Else
					lRet := .F.
					cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
					cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
					cLog += cValToChar(oModelMov:GetErrorMessage()[6])
					
				EndIf
				
				oModelMov:DeActivate()
				oModelMov:Destroy()
				oModelMov:= NIL
			EndIf
			
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
				aAdd( aFlagCTB, {cAliasFK + "_LA", "S", cAliasFK, (cAliasFK)->( Recno() ), 0, 0, 0} )
			EndIf
		EndIf

		//Limpar o n�mero da compensa��o nos valores acessorios (DC|MT|JR|CM|VA)
		SE5->(dbSetOrder(7))
		If SE5->(dbSeek(cChaveSE5))
			While !SE5->(EOF()) .AND. cChaveSe5 == SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)
				If SE5->E5_TIPODOC $ cTipodoc
					RecLock("SE5")
					If lEstorno
						Replace SE5->E5_SITUACA With "X"
					Else
						Replace SE5->E5_SITUACA With "C"
					EndIf
					If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
						aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
					Else
						Replace SE5->E5_LA With "S"
					EndIf
					SE5->(MsUnLock())
				EndIf
				SE5->(dbSkip())
			EndDo
		EndIf
		
		RestArea(aAreaAnt)
		cFilant := cFilBkp
	EndIf

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AdmAbreSM0� Autor � Orizio                � Data � 22/01/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Retorna um array com as informacoes das filias das empresas ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function CniAbreSM0() As Array
	Local aArea			:= SM0->( GetArea() )
	Local aAux			:= {}
	Local aRetSM0		:= {}
	Local lFWLoadSM0	:= .T.
	Local lFWCodFilSM0 	:= .T.

	If lFWLoadSM0
		aRetSM0	:= FWLoadSM0()
	Else
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		While SM0->( !Eof() )
			aAux := { 	SM0->M0_CODIGO,;
						IIf( lFWCodFilSM0, FWGETCODFILIAL, SM0->M0_CODFIL ),;
						"",;
						"",;
						"",;
						SM0->M0_NOME,;
						SM0->M0_FILIAL }

			aAdd( aRetSM0, aClone( aAux ) )
			SM0->( DbSkip() )
		End
	EndIf

	RestArea( aArea )
Return aRetSM0

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CNI317   �Autor  �Oswaldo Leite       � Data �  09/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � FUn��o respons�vel por listar tabela SE2 no grid           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CNI317()

Private aRotina := MenuDef()
//��������������������������������������������������������������Ŀ
//� Verifica o n�mero do Lote 											  �
//����������������������������������������������������������������
Private cLote		:= ""
Private cMarca 		:= GetMark()
Private lInverte
Private cTipos 		:= ""
Private cCadastro 	:= STR0011			/////"Compensa��o Pagar/Receber entre Empresas"
Private cModSpb 	:= "1"
//���������������������������������������������������������������������������Ŀ
//�Usado no Chile, indica se serao compensados titulos de credito ou de debito�
//�����������������������������������������������������������������������������
Private nDebCred	:=	1
Private lMsErroAuto := .f.
Private nAFI45001	:= 0
Private nAFI45002	:= 0

//Vari�veis utilizadas no FINA080 (n�o remover)
PRIVATE nDescCalc 	:= 0
PRIVATE nJurosCalc 	:= 0
PRIVATE nVACalc 	:= 0
PRIVATE nMultaCalc 	:= 0
PRIVATE nCorrCalc	:= 0
PRIVATE nDifCamCalc	:= 0
PRIVATE nImpSubCalc	:= 0
PRIVATE nPisCalc	:= 0
PRIVATE nCofCalc	:= 0
PRIVATE nCslCalc	:= 0
PRIVATE nIrfCalc	:= 0
PRIVATE nIssCalc	:= 0
PRIVATE nPisBaseR 	:= 0
PRIVATE nCofBaseR	:= 0
PRIVATE nCslBaseR 	:= 0
PRIVATE nIrfBaseR 	:= 0
PRIVATE nIssBaseR 	:= 0
PRIVATE nPisBaseC 	:= 0
PRIVATE nCofBaseC 	:= 0
PRIVATE nCslBaseC 	:= 0
PRIVATE nIrfBaseC 	:= 0
PRIVATE nIssBaseC 	:= 0
PRIVATE nCidBase	:= 0
PRIVATE nPis		:= 0
PRIVATE nCofins		:= 0
PRIVATE nCsll		:= 0
PRIVATE nIrrf		:= 0
PRIVATE nIss		:= 0
PRIVATE nCm			:= 0

CniMotBx("CEC","COMP CARTE","ASSS")

VALOR 		:= 0
VALOR2		:= 0
VALOR3		:= 0
VALOR4		:= 0
VALOR5		:= 0
VLRINSTR    := 0

SetKey (VK_F12,{|a,b| AcessaPerg("AFI450",.T.)})

pergunte("AFI450",.F.)

nAFI45001 := mv_par01
nAFI45002 := mv_par02

mBrowse(6,1,22,75,"SE2",,,,,,CNI317Leg())

dbSelectArea("SE5") //TABELA DE MOVTOS BANCARIOS
dbSetOrder(1)	&& devolve ordem principal
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CniMotBX  �Autor  � Oswaldo Leite      � Data �  09/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Funcao criar automaticamente o motivo de baixa CEC na      ���
���          � tabela Mot baixas                                          ���
�������������������������������������������������������������������������͹��
���Uso       � CNI317                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CniMotBx(cMot,cNomMot, cConfMot)
	Local lMotBxEsp	:= .F.
	Local aMotbx 	:= ReadMotBx(@lMotBxEsp)
	Local nHdlMot	:= 0
	Local I			:= 0
	Local cFile := "SIGAADV.MOT"
	Local nTamLn	:= 19

	If lMotBxEsp
		nTamLn	:= 20
		cConfMot	:= cConfMot + "N"
	EndIf
	If ExistBlock("FILEMOT")
		cFile := ExecBlock("FILEMOT",.F.,.F.,{cFile})
	Endif

	If Ascan(aMotbx, {|x| Substr(x,1,3) == Upper(cMot)}) < 1
		nHdlMot := FOPEN(cFile,FO_READWRITE)
		If nHdlMot <0
			HELP(" ",1,"SIGAADV.MOT")
			Final("SIGAADV.MOT")
		Endif

		nTamArq:=FSEEK(nHdlMot,0,2)	// VerIfica tamanho do arquivo
		FSEEK(nHdlMot,0,0)			// Volta para inicio do arquivo

		For I:= 0 to  nTamArq step nTamLn // Processo para ir para o final do arquivo
			xBuffer:=Space(nTamLn)
			FREAD(nHdlMot,@xBuffer,nTamLn)
	    Next

		fWrite(nHdlMot,cMot+cNomMot+cConfMot+chr(13)+chr(10))
		fClose(nHdlMot)
	EndIf
Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������ͻ��
���Programa  �Cni317Leg �Autor  �Oswaldo Leite         � Data �  09/08/11   ���
���������������������������������������������������������������������������͹��
���Desc.     � Legendas                                                     ���
���          �                                                              ���
���������������������������������������������������������������������������͹��
���Uso       �CNI317                                                        ���
���������������������������������������������������������������������������ͼ��
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function Cni317Leg(nReg)

Local uRetorno	:= .T.
Local aLegen	:= {{"ENABLE",STR0012},{"DISABLE",STR0013},{"BR_AZUL",STR0014}}     /////STR0012"Titulo no compensado"},{"DISABLE",STR0013"Titulo totalmente compensado"},{"BR_AZUL",STR0014"Titulo parcialmente compensado"}}

If Empty(nReg)
	uRetorno := {}
	aAdd(uRetorno, {'E2_SALDO =  E2_VALOR .AND. E2_ACRESC = E2_SDACRES', aLegen[1][1]}) // Titulo nao Compensado
	aAdd(uRetorno, {'E2_SALDO =  0'									   , aLegen[2][1]}) // Titulo Compensado Totalmente
	aAdd(uRetorno, {'E2_SALDO <> 0'									   , aLegen[3][1]})	 // Titulo Compensado Parcialmente
Else
	BrwLegenda(cCadastro,STR0015,aLegen)                   ////"Legenda"
Endif

Return(uRetorno)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CNI317   �Autor  �Microsiga           � Data �  06/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Compensa��o entre carteiras simultanea em duas empresas    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function CNI317PR()

Local nOpca 			:= 0
Local aSays				:={}
Local aButtons			:={}

Private  cEmpPri		:= " "

Private  cCliePri 		:= " "
Private  cLojCliPri		:= " "
Private  cFornPri		:= " "
Private  cLojForPri 	:= " "

Private  cEmpSec 		:= " "

Private  cClieSec 		:= " "
Private  cLojCliSec		:= " "
Private  cFornSec		:= " "
Private  cLojForSec		:= " "

Private  dDataIni		:= " "
Private  dDataFim		:= " "

Private  nMoeda			:= 1

Private	aRecPri			:= {}
Private	aPagPRi			:= {}
Private	aRecSec			:= {}
Private	aPagSec			:= {}
Private	nTotRecPri		:= 0
Private	nTotPagSec		:= 0
Private	nTotRecSec		:= 0
Private	nTotPagPri		:= 0
Private cMarca 			:= GetMark()
Private aTxMoedas		:=	{}

If !Pergunte("FIN317",.T.)
	Return
EndIf

cEmpPri			:= mv_par01

cCliePri 		:= mv_par02
cLojCliPri		:= mv_par03
cFornPri		:= mv_par04
cLojForPri 		:= mv_par05

cEmpSec 		:= mv_par06

cClieSec 		:= mv_par07
cLojCliSec		:= mv_par08
cFornSec		:= mv_par09
cLojForSec		:= mv_par10

dDataIni		:= mv_par11
dDataFim		:= mv_par12

nMoeda			:= mv_par13

AADD(aSays,STR0016)						///////"Este programa tem por objetivo efetuar uma compensa��o entre  carteiras")
AADD(aSays,STR0017)						///////"simultaneamente em duas Empresas/Filiais e gerar uma fatura dos titulos")
AADD(aSays,STR0018)						///////"restantes da compensa��o" )

AADD(aButtons, { 5,.T.,{|| Pergunte("FIN317",.T.) } } )

AADD(aButtons, { 1,.T.,{|o| nOpca:= 1,o:oWnd:End()}} )
AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
FormBatch( STR0019, aSays, aButtons )                     ////"Compensa��o entre Carteiras e Empresas/Filiais"

If nOpcA == 1
	Processa({|| C01Proc() })  // Chamada da funcao de processamento
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CNI317    �Autor  �Microsiga           � Data �  06/10/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Processamento                                               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function C01Proc()

Local cQuery 	:= ""
Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
Local cSepProv  := If("|"$MVPROVIS,"|",",")
Local cSepRec   := If("|"$MVPAGANT,"|",",")
Local cFilOld	:= cFilAnt
Local na		:= 0
Local ni		:= 0
Local nx		:= 0
Local cNumComp	:= ""
Local lPadrao 	:= .F.
Local cPadrao 	:= "594"
Local lCabec 	:= .F.
Local aFlagCTB 	:= {}
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lCtLiPag	:= SuperGetMV( "MV_CTLIPAG", .F., .T. )
Local aSE5Recs	:= {}
Local aAux		:= {}
Local lProcessou:= .T.
Local nValDif	:= 0
Local cArquivo	:= ""
Local nValMax	:= 0
Local nValMaxP 	:= 0
Local nValMaxR	:= 0

Private nTotal		:= 0
Private nPisBaseC	:= 0
Private nCofBaseC	:= 0
Private nCslBaseC	:= 0

lPadrao	:= VerPadrao(cPadrao)

cQuery := "SELECT SE1.R_E_C_N_O_ AS CRECNO, "
cQuery += "'SE1' AS ALIAS, "
cQuery += "E1_OK AS OK, "
cQuery += "E1_FILIAL AS FILIAL, "
cQuery += "E1_PREFIXO AS PREFIXO, "
cQuery += "E1_NUM AS NUM, "
cQuery += "E1_PARCELA AS PARCELA, "
cQuery += "E1_TIPO AS TIPO, "
cQuery += "E1_EMISSAO AS EMISSAO, "
cQuery += "E1_VENCREA AS VENCTO, "
cQuery += "E1_HIST AS HISTOR, "
cQuery += "E1_SALDO AS VALOR "
cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
cQuery += "WHERE  E1_CLIENTE = '"+cCliePri+"'  "
cQuery += "AND E1_LOJA = '"+cLojCliPri+"' "
cQuery += "AND E1_FILIAL = '"+cEmpPri+"' "
cQuery += "AND E1_VENCREA >= '"+DtoS(dDataIni)+"' "
cQuery += "AND E1_VENCREA <= '"+DtoS(dDataFim)+"' "
cQuery += "AND E1_SALDO > 0 "
cQuery += "AND E1_MOEDA = "+AllTrim(Str(nMoeda,1))+" "
cQuery += "AND E1_EMISSAO <='" + DTOS(dDataBase) + "' "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)  + " "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " "
cQuery += "AND E1_SITUACA IN ('0','F','G') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += "UNION "
cQuery += "SELECT SE2.R_E_C_N_O_ AS CRECNO, "
cQuery += "'SE2' AS ALIAS, "
cQuery += "E2_OK AS OK, "
cQuery += "E2_FILIAL AS FILIAL, "
cQuery += "E2_PREFIXO AS PREFIXO, "
cQuery += "E2_NUM AS NUM, "
cQuery += "E2_PARCELA AS PARCELA, "
cQuery += "E2_TIPO AS TIPO, "
cQuery += "E2_EMISSAO AS EMISSAO, "
cQuery += "E2_VENCREA AS VENCTO, "
cQuery += "E2_HIST AS HISTOR, "
cQuery += "E2_SALDO AS VALOR "
cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
cQuery += "WHERE E2_FORNECE = '"+cFornPri+"'  "
cQuery += "AND E2_LOJA = '"+cLojForPri+"' "
cQuery += "AND E2_FILIAL = '"+cEmpPri+"' "
cQuery += "AND E2_VENCREA >= '"+DtoS(dDataIni)+"' "
cQuery += "AND E2_VENCREA <= '"+DtoS(dDataFim)+"' "
If lCtLiPag
	cQuery += "AND E2_DATALIB <> '' "
EndIf
cQuery += "AND E2_SALDO > 0 "
cQuery += "AND E2_MOEDA = '"+AllTrim(Str(nMoeda,1))+"' "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)  + " "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " "
cQuery += "AND E2_EMIS1 <='" + DTOS(dDataBase) + "' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += "UNION "
cQuery += "SELECT SE1.R_E_C_N_O_ AS CRECNO, "
cQuery += "'SE1' AS ALIAS, "
cQuery += "E1_OK AS OK, "
cQuery += "E1_FILIAL AS FILIAL, "
cQuery += "E1_PREFIXO AS PREFIXO, "
cQuery += "E1_NUM AS NUM, "
cQuery += "E1_PARCELA AS PARCELA, "
cQuery += "E1_TIPO AS TIPO, "
cQuery += "E1_EMISSAO AS EMISSAO, "
cQuery += "E1_VENCREA AS VENCTO, "
cQuery += "E1_HIST AS HISTOR, "
cQuery += "E1_SALDO AS VALOR "
cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
cQuery += "WHERE E1_CLIENTE = '"+cClieSec+"'  "
cQuery += "AND E1_LOJA = '"+cLojCliSec+"' "
cQuery += "AND E1_FILIAL = '"+cEmpSec+"' "
cQuery += "AND E1_VENCREA >= '"+DtoS(dDataIni)+"' "
cQuery += "AND E1_VENCREA <= '"+DtoS(dDataFim)+"' "
cQuery += "AND E1_SALDO > 0 "
cQuery += "AND E1_MOEDA = '"+AllTrim(Str(nMoeda,1))+"' "
cQuery += "AND E1_EMISSAO <='" + DTOS(dDataBase) + "' "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)  + " "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " "
cQuery += "AND E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " "
cQuery += "AND E1_SITUACA IN ('0','F','G') "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += "UNION "
cQuery += "SELECT SE2.R_E_C_N_O_ AS CRECNO, "
cQuery += "'SE2' AS ALIAS, "
cQuery += "E2_OK AS OK, "
cQuery += "E2_FILIAL AS FILIAL, "
cQuery += "E2_PREFIXO AS PREFIXO, "
cQuery += "E2_NUM AS NUM, "
cQuery += "E2_PARCELA AS PARCELA, "
cQuery += "E2_TIPO AS TIPO, "
cQuery += "E2_EMISSAO AS EMISSAO, "
cQuery += "E2_VENCREA AS VENCTO, "
cQuery += "E2_HIST AS HISTOR, "
cQuery += "E2_SALDO AS VALOR "
cQuery += "FROM "+RetSqlName("SE2")+ " SE2 "
cQuery += "WHERE E2_FORNECE = '"+cFornSec+"' "
cQuery += "AND E2_LOJA = '"+cLojForSec+"' "
cQuery += "AND E2_FILIAL = '"+cEmpSec+"' "
cQuery += "AND E2_VENCREA >= '"+DtoS(dDataIni)+"' "
cQuery += "AND E2_VENCREA <= '"+DtoS(dDataFim)+"' "
If lCtLiPag
	cQuery += "AND E2_DATALIB <> '' "
EndIf
cQuery += "AND E2_SALDO > 0 "
cQuery += "AND E2_MOEDA = '"+AllTrim(Str(nMoeda,1))+"' "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)  + " "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " "
cQuery += "AND E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " "
cQuery += "AND E2_EMIS1 <='" + DTOS(dDataBase) + "' "
cQuery += " AND D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY FILIAL,NUM "

cQuery := ChangeQuery( cQuery )
dbUseArea( .t., "TOPCONN", Tcgenqry( , , cQuery ), "TMPCMP", .F., .T. )
TMPCMP->(dbGoTop())

ProcRegua(5) //COMPENSA��O

While !TMPCMP->(Eof())
	If TMPCMP->FILIAL == cEmpPri
		aAux := {}
		aAux := Fa317Repl("TMPCMP", TMPCMP->ALIAS)
		If TMPCMP->ALIAS == "SE1"
			aAdd(aRecPri,{cMarca, TMPCMP->CRECNO, TMPCMP->FILIAL, TMPCMP->PREFIXO, TMPCMP->NUM, TMPCMP->PARCELA, TMPCMP->TIPO, aAux[1], aAux[2], aAux[3], aAux[6], aAux[4], aAux[5] })
			nTotRecPri += aAux[1]
		Else
			aADD(aPagPRi,{cMarca, TMPCMP->CRECNO, TMPCMP->FILIAL, TMPCMP->PREFIXO, TMPCMP->NUM, TMPCMP->PARCELA, TMPCMP->TIPO, aAux[1], aAux[2], aAux[3], aAux[6], aAux[4], aAux[5] })
			nTotPagPri += aAux[1]
		EndIf
		FwFreeArray(aAux)
	Else
		aAux := {}
		aAux := Fa317Repl("TMPCMP", TMPCMP->ALIAS)
		If TMPCMP->ALIAS  == "SE1"
			aAdd(aRecSec,{cMarca, TMPCMP->CRECNO, TMPCMP->FILIAL, TMPCMP->PREFIXO, TMPCMP->NUM, TMPCMP->PARCELA, TMPCMP->TIPO, aAux[1], aAux[2], aAux[3], aAux[6], aAux[4], aAux[5] })
			nTotRecSec += aAux[1]
		Else
			aADD(aPagSec,{cMarca, TMPCMP->CRECNO, TMPCMP->FILIAL, TMPCMP->PREFIXO, TMPCMP->NUM, TMPCMP->PARCELA, TMPCMP->TIPO, aAux[1], aAux[2], aAux[3], aAux[6], aAux[4], aAux[5] })
			nTotPagSec += aAux[1]
		EndIf
		FwFreeArray(aAux)
	EndIf
	TMPCMP->(DbSkip())
EndDo
IncProc()//COMPENSA��O

If nTotRecPri <> nTotPagSec .Or. nTotRecSec <> nTotPagPri
	If ( nTotRecPri + nTotRecSec ) == 0 .Or. ( nTotPagPri + nTotPagSec ) == 0
		MsgStop("Uma das carteiras n�o possue t�tulos, o que impossibilita a compensa��o.", "Aten��o!")
		DbSelectArea("TMPCMP")
		DbCloseArea()
		Return .F.
	EndIf
	MsgAlert(STR0020, STR0008)                          ////"Totais n�o conferem entre as empresas/filiais! "      "Aten��o"
EndIf

Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1")})
For nA	:=	2	To MoedFin()
	cMoedaTx	:=	Str(nA,IIf(nA <= 9,1,2))
	If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
		Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),RecMoeda(dDataBase,nA),PesqPict("SM2","M2_MOEDA"+cMoedaTx) })
	Else
		Exit
	EndIf
Next

cNumComp	:= GetMaxId(cFilAnt,GetMv("MV_NUMCOMP"))
cNumComp	:= Soma1(cNumComp,6)

While !MayIUseCode("IDENTEE"+xFilial("SE1")+cNumComp)  	
	cNumComp := Soma1(cNumComp)							
EndDo

//Seta empresa e filial
cFilAnt := 	cEmpPri		//IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

If nTotRecPri + nTotRecSec > nTotPagPri + nTotPagSec
	nValMax := nTotPagPri + nTotPagSec
Else
	nValMax := nTotRecPri + nTotRecSec
EndIf
			
nValMaxR := nValMaxP := nValMax

Begin Transaction

For ni:=1 to Len(aRecPri)
	lBaixou := .F.

	//�����������������������������������Ŀ
	//� Registro do Contas a Receber 	  �
	//�������������������������������������
	If aRecPri[ni][1] == cMarca
		nValRec	:= 0
		nVa		:= 0

		//����������������������������������������������������������Ŀ
		//� Procura registro no SE1											 �
		//������������������������������������������������������������
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbGoTo(aRecPri[ni][2])
		//����������������������������������������������������������Ŀ
		//� Inicializa variaveis para baixa 								 �
		//������������������������������������������������������������
		dBaixa		:= dDataBase
		cBanco		:= cAgencia := cConta := cBenef :=	cCheque	:= " "
		cPortado 	:= cNumBor		:= " "
		cLoteFin 	:= " "
		nDescont 	:= nAbatim := nJuros := nMulta := nCm := 0
		cMotBX		:= "CEC"             // Compensacao Entre Carteiras
		lDesconto	:= .F.
		StrLctPad   := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		//����������������������������������������������������������Ŀ
		//� Calcula valor a ser baixado										 �
		//������������������������������������������������������������

		dbSelectArea("SE1")

		//TRB->CHAVE 	= SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
		SE1->(dbGoto(aRecPri[ni][2]))

		nValRec		:= aRecPri[ni][8]
		If nValRec > nValMaxR
			nValRec 	:= nValMaxR
			nTotAbat	:= 0
		Else
			nTotAbat	:= aRecPri[ni][9]
		EndIf
		nValMaxR	-= nValRec
		nJuros		:= aRecPri[ni][10]
		nDescont	:= aRecPri[ni][11]
		nMulta		:= aRecPri[ni][12]
		nVa			:= aRecPri[ni][13]
							
		nValEstrang := nValRec
		nAcresc		:= SE1->E1_SDACRES
		nDecresc	:= SE1->E1_SDDECRE
		nTxMoeda	:= SE1->E1_TXMOEDA
		// Converte para poder baixar
		If cPaisLoc == "BRA"
		   nValRec		:= xMoeda(nValRec,nMoeda,1,dDataBase)
		   FA070CORR(nValEstrang,0)
		Else
		   nValDia		:= Round(xMoeda(nValRec,nMoeda,1,dDataBase,nDecs1+1,nTxMoeda),nDecs1)
		   nValRec		:= Round(xMoeda(nValRec,nMoeda,1,dDataBase,nDecs1+1,aTxMoedas[nMoeda][2]),nDecs1)
		   nDifCambio	:= nValRec - nValDia
		   nCM			:=	nDifCambio
		EndIf
		SE1->(dbGoto(aRecPri[ni][2]))
		cHist070 	:= STR0021				//////"Valor recebido por compensacao" //"Valor recebido por compensacao"
		//����������������������������������������������������������Ŀ
		//� Efetua a baixa														 �
		//������������������������������������������������������������
		If nValRec > 0

			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE1 							 �
			//������������������������������������������������������������
			RecLock("SE1")
				Replace E1_IDENTEE	With cNumComp
			MsUnLock()

			lBaixou		:= FA070Grv(lPadrao,lDesconto,.F.,;
								Nil,.F.,dDataBase,.F.,Nil)		//Nil=Arquivo Cnab
			If lBaixou
				nValDif := nValDif + nValRec
			Else
				Help( ,,'HELP', STR0022, STR0023+cEmpPri, 1, 0)	////STR0022"ERRO", STR0023"Problemas na Baixa por Compensa��o dos titulos da filial "+cEmpPri, 1, 0)
				DbSelectArea("TMPCMP")
				DbCloseArea()
				DisarmTransaction()
				Return
			EndIf
			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE5 						 �
			//������������������������������������������������������������
			RecLock("SE5")
				Replace E5_IDENTEE	With cNumComp
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
				Else
					Replace E5_LA			With "S"
				EndIf
			MsUnLock()
			FK1->(DbSetOrder(1))
			If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))	
				Reclock("FK1", .F.)
				FK1_IDPROC := cNumComp
				If !lUsaFlag 
					FK1_LA := 'S' 
				Else
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->(Recno() ), 0, 0, 0} )
				EndIf
				MsUnlock()
			EndIf
			
			AAdd(aSE5Recs,{"R",SE5->(Recno())})

			//Gravar o numero da compensacao nos titulos de juros, multa e desconto
			//para permitir que os mesmos sejam cancelados quando do cancelamento da
			//compensacao
			dbSelectArea("SE5")
			nRecAtu := SE5->(Recno())
			nOrdAtu := SE5->(IndexOrd())
			dbSetOrder(2)
			cChaveSe5 := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(dDatabase)+E5_CLIFOR+E5_LOJA+E5_SEQ)
			aTipodoc := {"DC","MT","JR","CM"}
			For nX := 1 to Len(aTipodoc)
   				If dbSeek(xFilial("SE5")+aTipoDoc[nX]+cChaveSE5)
					RecLock("SE5")
						Replace E5_IDENTEE	With cNumComp

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
						Else
							Replace E5_LA			With "S"
						EndIf
					MsUnLock()
               	EndIf
      		Next

			SE5->(dbSetOrder(nOrdAtu))
			SE5->(dbGoto(nRecAtu))

			//����������������������������������������������������������Ŀ
			//� Inicializa variaveis para contabilizacao 					 �
			//������������������������������������������������������������
			VALOR := nValRec
			VLRINSTR := VALOR
			If nMoeda <= 5 .And. nMoeda > 1
				cVal := Str(nMoeda,1)
				VALOR&cVal := nValEstrang
			EndIf

			//����������������������������������������������������������Ŀ
			//� Posiciona SA1 para contabiliza��o        					 �
			//������������������������������������������������������������
			dbSelectArea("SA1")
			dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)

			dbSelectArea("SE2")
			dbGobottom()
			dbSkip()

			//����������������������������������������������������������Ŀ
			//� Contabiliza															 �
			//������������������������������������������������������������
			If !lCabec .and. lPadrao
				nHdlPrv := HeadProva( cLote,;
			                      "FINA450",;
			                      Substr( cUsuario, 7, 6 ),;
			                      @cArquivo )

				lCabec := .t.
			End
			If lCabec .and. lPadrao .and. lBaixou .and. (VALOR+VALOR2+VALOR3+VALOR4+VALOR5) > 0
				nTotal += DetProva( nHdlPrv,;
				                    cPadrao,;
				                    "FINA450",;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    /*lPosiciona*/,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )

			End
			//�����������������������������������������������������Ŀ
			//�Integracao com o SIGAPCO para lancamento via processo�
			//�PCODetLan("000018","01","FINA450",.T.)               �
			//�������������������������������������������������������
			PcoDetLan("000018","01","FINA450",.F.)
		End
	EndIf
Next

IncProc()//COMPENSA��O

For ni:=1 to Len(aPagPri)
	lBaixou := .F.

	//�����������������������������������Ŀ
	//� Registro do Contas a Receber 	  �
	//�������������������������������������
	If aPagPri[ni][1] == cMarca
		nValPgto 	:= 0
		nVa			:= 0

		//����������������������������������������������������������Ŀ
		//� Procura registro no SE2											 �
		//������������������������������������������������������������
		dbSelectArea("SE2")
		dbSetOrder(1)
		dbGoTo(aPagPri[ni][2])

		//����������������������������������������������������������Ŀ
		//� Inicializa variaveis para baixa 								 �
		//������������������������������������������������������������
		dBaixa		:= dDataBase
		cBanco		:= cAgencia := cConta := cBenef := cLoteFin := " "
		cCheque		:= cPortado := cNumBor := " "
		nDespes		:= nDescont := nAbatim := nJuros := nMulta := 0
		nValCc		:= nCm := 0
		lDesconto	:= .F.
		cMotBx		:= "CEC"
		StrLctPad   := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		//����������������������������������������������������������Ŀ
		//� Calcula Abatimentos 												 �
		//������������������������������������������������������������
		dbSelectArea("SE2")

		nTotAbat 	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,cFornPri,nMoeda,"S",dDataBase,SE2->E2_LOJA)

		cHist070 	:= STR0024				//////"Valor Pago por compensacao" //"Valor Pago por compensacao"
		SE2->(dbGoto(aPagPri[ni][2]))

		nValPgto 	:= aPagPri[ni][8]
		If nValPgto > nValMaxP
			nValPgto	:= nValMaxP
			nTotAbat	:= 0
		Else
			nTotAbat	:= aRecPri[ni][9]
		EndIf
		nValMaxP 	-= nValPgto
		nJuros		:= aRecPri[ni][10]
		nMulta		:= aRecPri[ni][12]
		nVa			:= aRecPri[ni][13]
		
		nValEstrang := nValPgto
		nAcresc		:= SE2->E2_SDACRES
		nDecresc	:= SE2->E2_SDDECRE
		nTxMoeda	:= SE2->E2_TXMOEDA

		// Converte para poder baixar
		If cPaisLoc == "BRA"
		   nValPgto 	:= xMoeda(nValPgto,nMoeda,1,dDataBase)
		   FA080CORR(nValEstrang,0)
		Else
		   nValDia		:= Round(xMoeda(nValPgto,nMoeda,1,dDataBase,nDecs1+1,nTxMoeda),nDecs1)
           nValPgto 	:= Round(xMoeda(nValPgto,nMoeda,1,dDataBase,nDecs1+1,aTxMoedas[nMoeda][2]),nDecs1)
		   nDifCambio   := nValPgto - nValDia
		EndIf

		//����������������������������������������������������������Ŀ
		//� Efetua a baixa														 �
		//������������������������������������������������������������
		If nValPgto > 0
			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE2 							 �
			//������������������������������������������������������������
			RecLock("SE2")
				Replace E2_IDENTEE	With cNumComp
			MsUnLock()

			// analisar a gravacao do SE2 - filial destino
			cLanca		:= "S"
			lBaixou		:= fA080Grv(lPadrao,.F.,.F.,cLanca,,IIf(cPaisLoc=="BRA",Nil,aTxMoedas[nMoeda][2]))
			If lBaixou
				nValDif := nValDif - nValPgto
			Else
				Help( ,,'HELP', STR0022, STR0023+cEmpPri, 1, 0)	               ////"ERRO"    "Problemas na Baixa por Compensa��o dos titulos da filial "
				DbSelectArea("TMPCMP")
				DbCloseArea()
				DisarmTransaction()
				Return
			EndIf
			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE5 							 �
			//������������������������������������������������������������
			RecLock("SE5")
				Replace E5_IDENTEE	With cNumComp

				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
				Else
					Replace E5_LA			With "S"
				EndIf
			MsUnLock()

			FK2->(DbSetOrder(1))
			If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))	
				Reclock("FK2", .F.)
				FK2_IDPROC := cNumComp
				If !lUsaFlag 
					FK2_LA := 'S' 
				Else
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->(Recno() ), 0, 0, 0} )
				EndIf
				MsUnlock()
			EndIf

			AAdd(aSE5Recs,{"P",SE5->(Recno())})

			//Gravar o numero da compensacao nos titulos de juros, multa e desconto
			//para permitir que os mesmos sejam cancelados quando do cancelamento da
			//compensacao
			dbSelectArea("SE5")
			nRecAtu := SE5->(Recno())
			nOrdAtu := SE5->(IndexOrd())
			dbSetOrder(2)
			cChaveSe5 	:= SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(dDatabase)+E5_CLIFOR+E5_LOJA+E5_SEQ)
			aTipodoc 	:= {"DC","MT","JR","CM"}
			For nX := 1 to Len(aTipodoc)
				If dbSeek(xFilial("SE5")+aTipoDoc[nX]+cChaveSE5)
					RecLock("SE5")
						Replace E5_IDENTEE	With cNumComp
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
						Else
							Replace E5_LA			With "S"
						EndIf
					MsUnLock()
				EndIf
			Next

			SE5->(dbSetOrder(nOrdAtu))
			SE5->(dbGoto(nRecAtu))

			//����������������������������������������������������������Ŀ
			//� Inicializa variaveis para contabilizacao 					 �
			//������������������������������������������������������������
			VALOR := nValPgto
			VLRINSTR := VALOR
			If nMoeda <= 5 .And. nMoeda > 1
				cVal := Str(nMoeda,1)
				VALOR&cVal := nValEstrang
			EndIf
			//����������������������������������������������������������Ŀ
			//� Posiciona SA2 para contabiliza��o        					 �
			//������������������������������������������������������������

			dbSelectArea("SA2")
			dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)

			dbSelectArea("SE1")
			dbGobottom()
			dbSkip()

			//����������������������������������������������������������Ŀ
			//� Contabiliza															 �
			//������������������������������������������������������������
			If !lCabec .and. lPadrao
				nHdlPrv := HeadProva( cLote,;
			                      "FINA450",;
			                      Substr( cUsuario, 7, 6 ),;
			                      @cArquivo )

				lCabec := .t.
			End
			If lCabec .and. lPadrao .and. lBaixou .and. (VALOR+VALOR2+VALOR3+VALOR4+VALOR5) > 0
				nTotal += DetProva( nHdlPrv,;
				                    cPadrao,;
				                    "FINA450",;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    /*lPosiciona*/,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )

			End
			//�����������������������������������������������������Ŀ
			//�Integracao com o SIGAPCO para lancamento via processo�
			//�PCODetLan("000018","01","FINA450",.T.)               �
			//�������������������������������������������������������
			PcoDetLan("000018","01","FINA450",.F.)
		End
	EndIf
Next

IncProc()//COMPENSA��O

If nValDif == (nTotRecPri - nTotPagPri)
	IF !IncTit(nValDif,1,cNumComp)
		Help( ,,'HELP', STR0022, STR0026+cEmpPri, 1, 0)	  ///STR0022"ERRO", STR0026"Problemas na Inclusao Titulo Compensa��o dos titulos da filial "+cEmpPri, 1, 0)
		DbSelectArea("TMPCMP")
		DbCloseArea()
		DisarmTransaction()
		Return
	EndIf
EndIf

If	lProcessou

	If lPadrao .and. lCabec
		//�����������������������������������������������������Ŀ
		//� Envia para Lancamento Contabil							  �
		//�������������������������������������������������������
		lDigita:=IIF(nAFI45001 == 1,.T.,.F.)
		lAglut :=IIF(nAFI45002 == 1,.T.,.F.)
		cA100Incl( cArquivo,;
		           nHdlPrv,;
		           3,;
		           cLote,;
		           lDigita,;
		           lAglut,;
		           /*cOnLine*/,;
		           /*dData*/,;
		           /*dReproc*/,;
		           @aFlagCTB,;
		           /*aDadosProva*/,;
		           /*aDiario*/ )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	EndIf

EndIf

// Segunda empresa /filial

//Seta empresa e filial
cFilAnt := 	cEmpSec		//IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
nValDif := 0

For ni:=1 to Len(aRecSec)
	lBaixou := .F.

	//�����������������������������������Ŀ
	//� Registro do Contas a Receber 	  �
	//�������������������������������������
	If aRecSec[ni][1] == cMarca
		nValRec	:= 0
		nVa		:= 0

		//����������������������������������������������������������Ŀ
		//� Procura registro no SE1											 �
		//������������������������������������������������������������
		dbSelectArea("SE1")
		dbSetOrder(1)
		dbGoTo(aRecSec[ni][2])
		//����������������������������������������������������������Ŀ
		//� Inicializa variaveis para baixa 								 �
		//������������������������������������������������������������
		dBaixa		:= dDataBase
		cBanco		:= cAgencia := cConta := cBenef :=	cCheque	:= " "
		cPortado 	:= cNumBor		:= " "
		cLoteFin 	:= " "
		nDescont 	:= nAbatim := nJuros := nMulta := nCm := 0
		cMotBX		:= "CEC"             // Compensacao Entre Carteiras
		lDesconto	:= .F.
		StrLctPad   := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		//����������������������������������������������������������Ŀ
		//� Calcula valor a ser baixado										 �
		//������������������������������������������������������������

		dbSelectArea("SE1")

		nTotAbat 	:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,nMoeda,"S",dDataBase)

		SE1->(dbGoto(aRecSec[ni][2]))
		
		nValRec 	:= aRecSec[ni][8]
		If nValRec > nValMaxR
			nValRec 	:= nValMaxR
			nTotAbat	:= 0
		Else
			nTotAbat	:= aRecPri[ni][9]
		EndIf	
		nValMaxR	-= nValRec
		nJuros		:= aRecPri[ni][10]
		nDescont	:= aRecPri[ni][11]
		nMulta		:= aRecPri[ni][12]
		nVA			:= aRecPri[ni][13]
		
		nValEstrang := nValRec
		nAcresc		:= SE1->E1_SDACRES
		nDecresc	:= SE1->E1_SDDECRE
		nTxMoeda	:= SE1->E1_TXMOEDA
		// Converte para poder baixar
		If cPaisLoc == "BRA"
		   nValRec		:= xMoeda(nValRec,nMoeda,1,dDataBase)
		   FA070CORR(nValEstrang,0)
		Else
		   nValDia		:= Round(xMoeda(nValRec,nMoeda,1,dDataBase,nDecs1+1,nTxMoeda),nDecs1)
		   nValRec		:= Round(xMoeda(nValRec,nMoeda,1,dDataBase,nDecs1+1,aTxMoedas[nMoeda][2]),nDecs1)
		   nDifCambio	:= nValRec - nValDia
		   nCM			:=	nDifCambio
		EndIf
		SE1->(dbGoto(aRecSec[ni][2]))
		cHist070 	:= STR0021						/////////"Valor recebido por compensacao" //"Valor recebido por compensacao"
		//����������������������������������������������������������Ŀ
		//� Efetua a baixa														 �
		//������������������������������������������������������������
		If nValRec > 0

			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE1 							 �
			//������������������������������������������������������������
			RecLock("SE1")
				Replace E1_IDENTEE	With cNumComp
			MsUnLock()

			lBaixou		:= FA070Grv(lPadrao,lDesconto,.F.,;
								Nil,.F.,dDataBase,.F.,Nil)		//Nil=Arquivo Cnab
			If lBaixou
				nValDif := nValDif + nValRec
			Else
				Help( ,,'HELP', STR0022, STR0023+cEmpSec, 1, 0)	    /////"ERRO"    "Problemas na Baixa por Compensa��o dos titulos da filial "
				DbSelectArea("TMPCMP")
				DbCloseArea()
				DisarmTransaction()
				Return
			EndIf
			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE5 						 �
			//������������������������������������������������������������
			RecLock("SE5")
				Replace E5_IDENTEE	With cNumComp
				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
				Else
					Replace E5_LA			With "S"
				EndIf
			MsUnLock()

			FK1->(DbSetOrder(1))
			If FK1->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))	
				Reclock("FK1", .F.)
				FK1_IDPROC := cNumComp
				If !lUsaFlag 
					FK1_LA := 'S' 
				Else
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->(Recno() ), 0, 0, 0} )
				EndIf
				MsUnlock()
			EndIf
			AAdd(aSE5Recs,{"R",SE5->(Recno())})

			//Gravar o numero da compensacao nos titulos de juros, multa e desconto
			//para permitir que os mesmos sejam cancelados quando do cancelamento da
			//compensacao
			dbSelectArea("SE5")
			nRecAtu := SE5->(Recno())
			nOrdAtu := SE5->(IndexOrd())
			dbSetOrder(2)
			cChaveSe5 := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(dDatabase)+E5_CLIFOR+E5_LOJA+E5_SEQ)
			aTipodoc := {"DC","MT","JR","CM"}
			For nX := 1 to Len(aTipodoc)
				If dbSeek(xFilial("SE5")+aTipoDoc[nX]+cChaveSE5)
					RecLock("SE5")
						Replace E5_IDENTEE	With cNumComp

						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
						Else
							Replace E5_LA			With "S"
						EndIf
					MsUnLock()
               	EndIf
      		Next

			SE5->(dbSetOrder(nOrdAtu))
			SE5->(dbGoto(nRecAtu))

			//����������������������������������������������������������Ŀ
			//� Inicializa variaveis para contabilizacao 					 �
			//������������������������������������������������������������
			VALOR := nValRec
			VLRINSTR := VALOR
			If nMoeda <= 5 .And. nMoeda > 1
				cVal := Str(nMoeda,1)
				VALOR&cVal := nValEstrang
			EndIf

			//����������������������������������������������������������Ŀ
			//� Posiciona SA1 para contabiliza��o        					 �
			//������������������������������������������������������������
			dbSelectArea("SA1")
			dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)

			dbSelectArea("SE2")
			dbGobottom()
			dbSkip()

			//����������������������������������������������������������Ŀ
			//� Contabiliza															 �
			//������������������������������������������������������������
			If !lCabec .and. lPadrao
				nHdlPrv := HeadProva( cLote,;
			                      "FINA450",;
			                      Substr( cUsuario, 7, 6 ),;
			                      @cArquivo )

				lCabec := .t.
			End
			If lCabec .and. lPadrao .and. lBaixou .and. (VALOR+VALOR2+VALOR3+VALOR4+VALOR5) > 0
				nTotal += DetProva( nHdlPrv,;
				                    cPadrao,;
				                    "FINA450",;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    /*lPosiciona*/,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )

			End
			//�����������������������������������������������������Ŀ
			//�Integracao com o SIGAPCO para lancamento via processo�
			//�PCODetLan("000018","01","FINA450",.T.)               �
			//�������������������������������������������������������
			PcoDetLan("000018","01","FINA450",.F.)
		End
	EndIf
Next

IncProc()//COMPENSA��O

For ni:=1 to Len(aPagSec)
	lBaixou := .F.

	//�����������������������������������Ŀ
	//� Registro do Contas a Receber 	  �
	//�������������������������������������
	If aPagSec[ni][1] == cMarca
		nValPgto := 0

		//����������������������������������������������������������Ŀ
		//� Procura registro no SE2											 �
		//������������������������������������������������������������
		dbSelectArea("SE2")
		dbSetOrder(1)
		dbGoTo(aPagSec[ni][2])

		//����������������������������������������������������������Ŀ
		//� Inicializa variaveis para baixa 								 �
		//������������������������������������������������������������
		dBaixa		:= dDataBase
		cBanco		:= cAgencia := cConta := cBenef := cLoteFin := " "
		cCheque		:= cPortado := cNumBor := " "
		nDespes		:= nDescont := nAbatim := nJuros := nMulta := 0
		nValCc		:= nCm := 0
		lDesconto	:= .F.
		cMotBx		:= "CEC"
		StrLctPad   := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
		//����������������������������������������������������������Ŀ
		//� Calcula Abatimentos 												 �
		//������������������������������������������������������������
		dbSelectArea("SE2")

		nTotAbat 	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,cFornSec,nMoeda,"S",dDataBase,SE2->E2_LOJA)

		cHist070 	:= STR0024				//////"Valor Pago por compensacao" //"Valor Pago por compensacao"
		SE2->(dbGoto(aPagSec[ni][2]))

		//--------------------------------------------------------------------------
		//C�lculo de Valores Acessorios
		//-----------------------------------------------------------------------------
		If lExistVa
			nVa	:= FValAcess(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NATUREZ, /*lBaixados*/,/*cCodVa*/,"P",dDatabase)	
			//Converto para a moeda do titulo para compor o valor da baixa corretamente
			If SE2->E2_MOEDA > 1
				nVa := xMoeda(nVa,1,SE2->E2_MOEDA,dDataBase,3,,SE2->E2_TXMOEDA)
			EndIf
		EndIf
		
		//����������������������������������������������������������Ŀ
		//� Calcula valor a ser baixado								 �
		//������������������������������������������������������������
		nValPgto 	:= aPagSec[ni][8]
		If nValPgto > nValMaxP
			nValPgto	:= nValMaxP
			nTotAbat	:= 0
		Else
			nTotAbat	:= aRecPri[ni][9]
		EndIf
		nValMaxP 	-= nValPgto
		nJuros		:= aRecPri[ni][10]
		nMulta		:= aRecPri[ni][12]
		nVa			:= aRecPri[ni][13]
		
		nValEstrang := nValPgto
		nAcresc		:= SE2->E2_SDACRES
		nDecresc	:= SE2->E2_SDDECRE
		nTxMoeda	:= SE2->E2_TXMOEDA

		// Converte para poder baixar
		If cPaisLoc == "BRA"
		   nValPgto 	:= xMoeda(nValPgto,nMoeda,1,dDataBase)
		   FA080CORR(nValEstrang,0)
		Else
		   nValDia		:= Round(xMoeda(nValPgto,nMoeda,1,dDataBase,nDecs1+1,nTxMoeda),nDecs1)
           nValPgto 	:= Round(xMoeda(nValPgto,nMoeda,1,dDataBase,nDecs1+1,aTxMoedas[nMoeda][2]),nDecs1)
		   nDifCambio   := nValPgto - nValDia
		EndIf

		//����������������������������������������������������������Ŀ
		//� Efetua a baixa														 �
		//������������������������������������������������������������
		If nValPgto > 0
			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE2 							 �
			//������������������������������������������������������������
			RecLock("SE2")
				Replace E2_IDENTEE	With cNumComp
			MsUnLock()

			// analisar a gravacao do SE2 - filial destino
			cLanca		:= "S"
			lBaixou		:= fA080Grv(lPadrao,.F.,.F.,cLanca,,IIf(cPaisLoc=="BRA",Nil,aTxMoedas[nMoeda][2]))
			If lBaixou
				nValDif := nValDif - nValPgto
			Else
				Help( ,,'HELP', STR0022, STR0023+cEmpSec, 1, 0)	    /////"ERRO"    "Problemas na Baixa por Compensa��o dos titulos da filial "
				DbSelectArea("TMPCMP")
				DbCloseArea()
				DisarmTransaction()
				Return
			EndIf
			//����������������������������������������������������������Ŀ
			//� Grava numero da compensacao no SE5 							 �
			//������������������������������������������������������������
			RecLock("SE5")
				Replace E5_IDENTEE	With cNumComp

				If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
				Else
					Replace E5_LA			With "S"
				EndIf
			MsUnLock()

			FK2->(DbSetOrder(1))
			If FK2->(dbseek(SE5->E5_FILIAL+SE5->E5_IDORIG))	
				Reclock("FK2", .F.)
				FK2_IDPROC := cNumComp
				If !lUsaFlag 
					FK2_LA := 'S' 
				Else
					aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->(Recno() ), 0, 0, 0} )
				EndIf
				MsUnlock()
			EndIf
											
			AAdd(aSE5Recs,{"P",SE5->(Recno())})

			//Gravar o numero da compensacao nos titulos de juros, multa e desconto
			//para permitir que os mesmos sejam cancelados quando do cancelamento da
			//compensacao
			dbSelectArea("SE5")
			nRecAtu := SE5->(Recno())
			nOrdAtu := SE5->(IndexOrd())
			dbSetOrder(2)
			cChaveSe5 := SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(dDatabase)+E5_CLIFOR+E5_LOJA+E5_SEQ)
			aTipodoc := {"DC","MT","JR","CM"}
			For nX := 1 to Len(aTipodoc)
				If dbSeek(xFilial("SE5")+aTipoDoc[nX]+cChaveSE5)
					RecLock("SE5")
						Replace E5_IDENTEE	With cNumComp
						If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->( Recno() ), 0, 0, 0} )
						Else
							Replace E5_LA			With "S"
						EndIf
					MsUnLock()
				EndIf
			Next

			SE5->(dbSetOrder(nOrdAtu))
			SE5->(dbGoto(nRecAtu))

			//����������������������������������������������������������Ŀ
			//� Inicializa variaveis para contabilizacao 					 �
			//������������������������������������������������������������
			VALOR := nValPgto
			VLRINSTR := VALOR
			If nMoeda <= 5 .And. nMoeda > 1
				cVal := Str(nMoeda,1)
				VALOR&cVal := nValEstrang
			EndIf
			//����������������������������������������������������������Ŀ
			//� Posiciona SA2 para contabiliza��o        					 �
			//������������������������������������������������������������

			dbSelectArea("SA2")
			dbSeek(xFilial("SA2")+SE2->E2_FORNECE+SE2->E2_LOJA)

			dbSelectArea("SE1")
			dbGobottom()
			dbSkip()

			//����������������������������������������������������������Ŀ
			//� Contabiliza															 �
			//������������������������������������������������������������
			If !lCabec .and. lPadrao
				nHdlPrv := HeadProva( cLote,;
			                      "FINA450",;
			                      Substr( cUsuario, 7, 6 ),;
			                      @cArquivo )

				lCabec := .t.
			End
			If lCabec .and. lPadrao .and. lBaixou .and. (VALOR+VALOR2+VALOR3+VALOR4+VALOR5) > 0
				nTotal += DetProva( nHdlPrv,;
				                    cPadrao,;
				                    "FINA450",;
				                    cLote,;
				                    /*nLinha*/,;
				                    /*lExecuta*/,;
				                    /*cCriterio*/,;
				                    /*lRateio*/,;
				                    /*cChaveBusca*/,;
				                    /*aCT5*/,;
				                    /*lPosiciona*/,;
				                    @aFlagCTB,;
				                    /*aTabRecOri*/,;
				                    /*aDadosProva*/ )

			End
			//�����������������������������������������������������Ŀ
			//�Integracao com o SIGAPCO para lancamento via processo�
			//�PCODetLan("000018","01","FINA450",.T.)               �
			//�������������������������������������������������������
			PcoDetLan("000018","01","FINA450",.F.)
		End
	EndIf
Next

IncProc()//COMPENSA��O

If nValDif == (nTotRecSec - nTotPagSec)
	If !IncTit(nValDif,2,cNumComp)
		Help( ,,'HELP', STR0022, STR0026+cEmpSec, 1, 0)
		DbSelectArea("TMPCMP")
		DbCloseArea()
		DisarmTransaction()
		Return
	EndIf
Else
	Help( ,,'HELP', STR0022, STR0027+cEmpSec, 1, 0)
	DbSelectArea("TMPCMP")
	DbCloseArea()
	DisarmTransaction()
	Return
EndIf

If	lProcessou

	If lPadrao .and. lCabec
		//�����������������������������������������������������Ŀ
		//� Envia para Lancamento Contabil							  �
		//�������������������������������������������������������
		lDigita:=IIF(nAFI45001 == 1,.T.,.F.)
		lAglut :=IIF(nAFI45002 == 1,.T.,.F.)
		cA100Incl( cArquivo,;
		           nHdlPrv,;
		           3,;
		           cLote,;
		           lDigita,;
		           lAglut,;
		           /*cOnLine*/,;
		           /*dData*/,;
		           /*dReproc*/,;
		           @aFlagCTB,;
		           /*aDadosProva*/,;
		           /*aDiario*/ )
		aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento
	EndIf

EndIf

End Transaction

cFilAnt := cFilOld

//�������������������������������������������������������Ŀ
//� Grava o numero da compensacao no.                     �
//���������������������������������������������������������
	PutMv("MV_NUMCOMP",cNumComp)
//Relatorio

DbSelectArea("TMPCMP")
DbCloseArea()

//���������������������������������������������������������������Ŀ
//�Rotina para apresentar os titulos compensados. Pagar e Receber.�
//�����������������������������������������������������������������

u_CNIRL317(cNumComp)

Return

Static Function IncTit(nValDif,nOper,cNumComp) As Logical

Local lRet := .T.

If nValDif > 0
	lMsErroAuto := .F. // variavel interna da rotina automatica
	aTit := {}
	AADD(aTit,  { 	"E1_FILIAL"		,xFilial("SE1")		, NIL } )
	AADD(aTit,  { 	"E1_PREFIXO"	,"DME"				, NIL } )
	AADD(aTit,  { 	"E1_NUM"		,cNumComp			, NIL } )
	AADD(aTit,  { 	"E1_PARCELA"	,' '				, NIL } )
	AADD(aTit,  { 	"E1_TIPO"		,MV_PAR14			, NIL } )
	AADD(aTit,  { 	"E1_NATUREZ"	,MV_PAR15			, NIL } )
	AADD(aTit,  { 	"E1_CLIENTE"	,If(nOper==1,cCliePri,cClieSec)		, NIL } )
	AADD(aTit,  { 	"E1_LOJA"		,If(nOper==1,cLojCliPri,cLojCliSec)	, NIL } )
	AADD(aTit,  { 	"E1_EMISSAO"	,dDataBase			, NIL } )
	AADD(aTit,  { 	"E1_VENCTO"		,dDataBase			, NIL } )
	AADD(aTit,  { 	"E1_VALOR"		,nValDif			, NIL } )

	MSExecAuto({|x, y| FINA040(x, y)}, aTit, 3)

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lREt := .f.
	EndIf
ElseIf nValDif < 0
	lMsErroAuto := .F. // variavel interna da rotina automatica
	aTit := {}
	AADD(aTit,  { 	"E2_FILIAL"		,xFilial("SE2")		, NIL } )
	AADD(aTit,  { 	"E2_PREFIXO"	,"DME"				, NIL } )
	AADD(aTit,  { 	"E2_NUM"		,cNumComp			, NIL } )
	AADD(aTit,  { 	"E2_PARCELA"	,' '				, NIL } )
	AADD(aTit,  { 	"E2_TIPO"		,MV_PAR16			, NIL } )
	AADD(aTit,  { 	"E2_NATUREZ"	,MV_PAR17			, NIL } )
	AADD(aTit,  { 	"E2_FORNECE"	,If(nOper==1,cFornPri,cFornSec)		, NIL } )
	AADD(aTit,  { 	"E2_LOJA"		,If(nOper==1,cLojForPri	,cLojForSec), NIL } )
	AADD(aTit,  { 	"E2_EMISSAO"	,dDataBase			, NIL } )
	AADD(aTit,  { 	"E2_VENCTO"		,dDataBase			, NIL } )
	AADD(aTit,  { 	"E2_VALOR"		,(nValDif*-1)		, NIL } )

	MSExecAuto({|x, y, z| FINA050(x, y, z)}, aTit, 3,3)

	If lMsErroAuto
		MostraErro()
		DisarmTransaction()
		lREt := .f.
	EndIf
EndIf

Return(lRet)

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 �CNI317CalCn � Autor � Oswaldo Leite         � Data � 09/08/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula Parcelas, Nro.Titulos e valor da Liquida. a cancelar ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Cni317													    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CNI317CalCn(cCompCan,cIndex) As Logical

Local cChave
Local nIndex

//�����������������������������������������������������������������Ŀ
//� Cria indice condicional separando os titulos que deram origem a �
//� liquidacao e os titulos que foram gerados							  �
//�������������������������������������������������������������������
dbSelectArea("SE5")
cIndex := CriaTrab(nil,.f.)
cChave := IndexKey()
IndRegua("SE5",cIndex,cChave,,CNI317FCAN(),STR0005)                        ////'Selecionando Registros'"Selecionando Registros...")

nIndex := RetIndex("SE5")
dbSelectArea("SE5")

#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

//���������������������������������������������������������������������Ŀ
//� Certifica se foram encontrados registros na condi��o selecionada		�
//�����������������������������������������������������������������������
If  BOF() .and. EOF()
	Help(" ",1,"RECNO")
	//������������������������������������������������������������������Ŀ
	//� Restaura os indices do SE5 e deleta o arquivo de trabalho			�
	//��������������������������������������������������������������������
	dbSelectArea("SE5")
	Set Filter to
	RetIndex("SE5")
	fErase(cIndex+OrdBagExt())
	cIndex := ""
	dbSetOrder(1)
	Return .F.
EndIf

dbSelectArea("SE5")

Return .T.

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � CNI317FCan � Autor � Oswaldo Leite         � Data � 02/02/98 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Sele��o para a cria��o do indice condicional no CANCELAMENTO ���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � cni317														���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CNI317FCan() As Character
//���������������������������������������������������������������������������Ŀ
//� Devera selecionar todos os registros que atendam a seguinte condi��o :   �
//���������������������������������������������������������������������������Ĵ
//� 2. Ou titulos que tenham originado a liquidacao selecionada 			 �
//�����������������������������������������������������������������������������
Local cFiltro

cFiltro := 'E5_IDENTEE=="'+cCompCan+'".And.'
cFiltro += 'Dtos(E5_DATA)<="'+Dtos(dDataBase)+'".And.'
cFiltro += 'E5_TIPODOC<>"ES".And.'
cFiltro += 'E5_SITUACA<>"C".And.'
cFiltro += 'E5_SITUACA<>"X"'

If ExistBlock("F450FCA")
	cFiltro += '.And.'
	cFiltro += ExecBlock("F450FCA",.F.,.F.)
EndIf

Return cFiltro

/*/
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � CNI317VrfFilial  Autor  Oswaldo            � Data � 10/08/11 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Identifica Formato da Empresa/Unidade/Filial usada na Base   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CNI317VrfFilial												���
���          |	cParam1 - conteudo do campo filial da tabela-1				���
���          |	cParam2 - conteudo do campo filial da tabela-2				���
���          |	cLayOut - layout CFGX032									���
���������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												    ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function CNI317VrfFilial(cParam1, cParam2, cLayOut) As Character

Local nE 				:= 0
Local nU 				:= 0
Local nF 				:= 0
Local nCont				:= 0
Local cRet 				:= ""
Local nTamFixoDoCampo 	:= Len(cParam1)
Local nTamFil			:= Len(AllTrim(cParam1))

For nCont := 1 to Len(cLayOut)

	If substr(cLayout,nCont,1) == 'E'
		nE++
	ElseIf substr(cLayout,nCont,1) == 'U'
		nU++
	ElseIf substr(cLayout,nCont,1) == 'F'//o sistema exige ao menos 2 digitos de filial
		nF++
	EndIf

Next nCont

If Empty(AllTrim(cParam1))
    cRet := cParam1
Else
    //Baseado totalmente do layout definido para o c�digo da empresa: EEUUFF, EUF ... etc
	If nE > 0
		cRet := cRet + substr(cParam2,01, nE)
	EndIf

	If nU > 0 .And. ( nE < nTamFil )
		cRet := cRet + substr(cParam2,nE+1, nU)
	EndIf

	If nF > 0 .And. ( ( nE + nU ) < nTamFil )
		cRet := cRet + substr(cParam2,nE+nU+1, nF)
	EndIf

   	cRet := cRet + space(nTamFixoDoCampo - Len(cRet))
EndIf

Return (cRet)

//-------------------------------------------------------------------------
/*/{Protheus.doc} GetMaxId
Obt�m o maior identificador da compensa��o entre carteiras

@author Rodrigo Oliveira
@since  28/09/2020
@version 12
/*/
//-------------------------------------------------------------------------
Static Function GetMaxId(cFil as Character, cIdent as Character) as Character
	Local cRetIdent as Character
	Local aArea as Array
	Local cTabTmp as Character

	cRetIdent := ""
	aArea := GetArea()
	cTabTmp	:= "TMPSE5"

	BeginSql Alias cTabTmp
		SELECT MAX(SE5.E5_IDENTEE) AS IDENTEE
			FROM %Table:SE5% SE5
			WHERE SE5.E5_FILIAL = %Exp:cFil%
				AND SE5.%NotDel%
	EndSql

	If (cTabTmp)->IDENTEE > cIdent
		cRetIdent := (cTabTmp)->IDENTEE
	Else
		cRetIdent := cIdent
	EndIf
	(cTabTmp)->(dbCloseArea())      
	RestArea(aArea)

Return cRetIdent

//-------------------------------------------------------------------
/*{Protheus.doc} Fa317Repl
Grava registros no arquivo temporario	

@author Rodrigo Oliveira
@since   02/10/2020
*/
//-------------------------------------------------------------------
Function Fa317Repl( TRB, cAlias )
	Local nAbat			:= 0
	Local nJuros		:= 0
	Local nVa			:= 0
	Local nDescont		:= 0   
	Local nMulta		:= 0                             //Valor da Multa
	Local cMVJurTipo 	:= SuperGetMV("MV_JURTIPO",,"") //Tipo de calculo dos Juros
	Local lLojxRMul  	:= .T.  //Calculo de Juros e Multas: SIGALOJA x SIGAFIN 
	Local lMvLjIntFS 	:= SuperGetMV("MV_LJINTFS", , .F.) //Integra��o com o Financial Services Habilitada?
	Local aRet			:= {}

	If cAlias == "SE1"
		dbSelectArea("SE1")
	
		SE1->(DbGoTo((TRB)->CRECNO))
					
		If lExistVA
			nVa		:= FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NATUREZ, /*lBaixados*/,/*cCodVa*/,"R",dDatabase)
			//Converto para a moeda do titulo para compor o valor da baixa corretamente
			If SE1->E1_MOEDA > 1
				nVa := xMoeda(nVa,1,SE1->E1_MOEDA,dDataBase,3,,SE1->E1_TXMOEDA)
			EndIf
		EndIf
		
		nAbat		:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDataBase,,,,,,,SE1->E1_FILORIG)
		nJuros		:= xMoeda(SE1->E1_JUROS,nMoeda,1,dDataBase)
		nDescont 	:= xMoeda(SE1->E1_DESCONT,nMoeda,1,dDataBase)
		
		//---------------------------------------------------------
		// Calcula a multa, conforme a regra do controle de lojas
		//---------------------------------------------------------
		nMulta := 0
		
		If (cMvJurTipo == "L" .OR. lMvLjIntFS) .and. lLojxRMul  .and. SE1->E1_SALDO > 0 .And. !(SE1->E1_TIPO $ MVRECANT + "|" + MV_CRNEG) 

			//------------------------------------------------------------------
			// Calcula o valor da Multa  :funcao LojxRMul :fonte Lojxrec  
			//------------------------------------------------------------------
			nMulta := LojxRMul( , , ,SE1->E1_SALDO, SE1->E1_ACRESC, SE1->E1_VENCREA,, , SE1->E1_MULTA, ,;
								SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, "SE1",.T. )   	

		EndIf
		//Calculo de Juros e Multas: SIGALOJA x SIGAFIN  - Final	
		
		aRet := { SE1->E1_SALDO - nAbat + SE1->E1_SDACRES - SE1->E1_SDDECRE + nJuros - nDescont + nMulta + nVA ,;
			nAbat,;
			nJuros,;
			nMulta,;
			nVA,;
			nDescont }
	Else

		DbSelectArea("SE2")
		SE2->(DbGoTo((TRB)->CRECNO))	
		
		nAbat	:= SumAbatPag(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_FORNECE,SE2->E2_MOEDA,"V",dDataBase,SE2->E2_LOJA,,,,,SE2->E2_TIPO)
		nJuros	:= xMoeda(SE2->E2_JUROS,nMoeda,1,dDataBase)
		nMulta	:= 0
		
		//--------------------------------------------------------------------------
		//C�lculo de Valores Acessorios
		//-----------------------------------------------------------------------------
		If lExistVa
			nVa	:= FValAcess(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NATUREZ, /*lBaixados*/,/*cCodVa*/,"P",dDatabase)	
			//Converto para a moeda do titulo para compor o valor da baixa corretamente
			If SE2->E2_MOEDA > 1
				nVa := xMoeda(nVa,1,SE2->E2_MOEDA,dDataBase,3,,SE2->E2_TXMOEDA)
			EndIf
		EndIf

		aRet := { SE2->E2_SALDO - nAbat + SE2->E2_SDACRES - SE2->E2_SDDECRE + nJuros + nVA + nMulta,;
			nAbat ,;
			nJuros,;
			nMulta,;
			nVA,;
			0 }
		
	EndIf

Return aRet
