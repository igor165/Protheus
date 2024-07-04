#INCLUDE "FINA151.CH"
#include "PROTHEUS.ch"

#DEFINE MARCA					1
#DEFINE DATAOCORRENCIA		2
#DEFINE NUMEROBORDERO		3
#DEFINE CODIGOOCORRENCIA	4
#DEFINE DESCOCORRENCIA		5
#DEFINE TIPOTITULO			6
#DEFINE PREFIXOTITULO		7
#DEFINE NUMTITULO				8
#DEFINE PARCELATITULO		9
#DEFINE CHAVESE1			  10
#DEFINE RECNOFI2			  11
#DEFINE FILTITULO			  12

Static lFWCodFil := .T.
Static lTopFin	:= IfDefTopCTB()
Static __lF151Bor := ExistBlock("F151Bor")

// 17/08/2009 - Compilacao para o campo filial de 4 posicoes
// 18/08/2009 - Compilacao para o campo filial de 4 posicoes


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Fina151  � Autor � Bruno Sobieski        � Data � 23/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gera��o do Arquivo de Envio de Ocorrencias ao Banco        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fina151()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fina151(nPosArotina)
Local lPanelFin := IsPanelFin()
LOCAL nRegs		:=0

/* GESTAO - inicio */
Private aSelFil	:= {}

/* GESTAO - fim */

If !IsBlind() .AND. GetHlpLGPD({"A1_NOME","A6_COD"})
	Return .F.
Endif

If lPanelFin
	If !PergInPanel('AFI151',.T.)
		Return
	Endif
ElseIf !Pergunte('AFI151',.T.)
	Return
Endif
//��������������������������������������Ŀ
//� Variaveis utilizadas para parametros �
//� mv_par01		 // Do Bordero 		  �
//� mv_par02		 // Ate o Bordero 	  �
//� mv_par03		 // Arq.Config 		  �
//� mv_par04		 // Arq. Saida    	  �
//� mv_par05		 // Banco     			  �
//� mv_par06		 // Agenciao     		  �
//� mv_par07		 // Conta   			  �
//� mv_par08		 // Sub-Conta  		  �
//� mv_par09		 // Cnab 1 / Cnab 2    �
//� mv_par10		 // Considera Filiais  �
//� mv_par11		 // De Filial   		  �
//� mv_par12		 // Ate Filial         �
//� mv_par13		 // De data ocorrencia �
//� mv_par14		 // Ate Data ocorrencia�
//� mv_par15		 // Mostra ja gerados? �
//����������������������������������������

PRIVATE cBanco,cAgencia,xConteudo
PRIVATE cPerg      := "AFI151"
PRIVATE nHdlBco    := 0
PRIVATE nHdlSaida  := 0
PRIVATE nSeq       := 0
PRIVATE nSomaValor := 0
PRIVATE aRotina := MenuDef()
PRIVATE xBuffer,nLidos := 0
PRIVATE nTotCnab2 := 0 // Contador de Lay-out nao deletar
PRIVATE nLinha := 0 // Contador de Linhas nao deletar
PRIVATE nQtdLinLote	:= 0 // Contador de linhas do detalhe do lote

DEFAULT nPosArotina := 0

SetKey (VK_F12,{|a,b| AcessaPerg("AFI151",.T.)})

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de baixas                         �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0006) //"Geracao de CNAB de ocorrencias"

If nPosArotina > 0 // Sera executada uma opcao diretamento de aRotina, sem passar pela mBrowse
   dbSelectArea("FI2")
   bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
   Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina)
Else
	nReg:=Recno( )
	mBrowse( 6, 1,22,75,"FI2" ,,,,,,Fa151Leg())
	dbGoto( nReg )
Endif

//��������������������������������������������������������������Ŀ
//� Fecha os Arquivos ASC II                                     �
//����������������������������������������������������������������
FCLOSE(nHdlBco)
FCLOSE(nHdlSaida)

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados                             �
//����������������������������������������������������������������
dbSelectArea("FI2")
dbSetOrder(1)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FA151Inclu� Autor � Claudio Donizete      � Data � 05/02/04 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa para inclusao de ocorrencias CNAB 					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FA151Inclu(ExpC1,ExpN1,ExpN2) 							  		  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo									  		  ���
���			 � ExpN1 = Numero do registro 								  		  ���
���			 � ExpN2 = Numero da opcao selecionada 						  	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA151													  				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA151Inclu(cAlias,nReg,nOpc)

Local lPanelFin := IsPanelFin()
Local nOpca

If lPanelFin
	dbSelectArea("SE5")
	RegToMemory("SE5",.T.,,,FunName())
	oPanelDados := FinWindow:GetVisPanel()
	oPanelDados:FreeChildren()
	aDim := DLGinPANEL(oPanelDados)
	Inclui := .T.
	nOpca := AxInclui(cAlias,nReg,nOpc,,,,"Fa151ValOc()",,"Fa151AxInc('"+cAlias+"')",,,,,,,.T.,oPanelDados,aDim,FinWindow)
Else
	nOpca := AxInclui(cAlias,nReg,nOpc,,,,"Fa151ValOc()",,"Fa151AxInc('"+cAlias+"')")
Endif

Return nOpca

Function Fa151ValOc
Local lRet := .T.
Local aAreaFi2 := FI2->(GetArea())


SE1->(DbSetOrder(1))
SE1->(MsSeek(xFilial("SE1")+M->FI2_PREFIX+M->FI2_TITULO+M->FI2_PARCEL+M->FI2_TIPO))
// Se a ocorrencia na existir para o banco portador
If ! SEB->(MsSeek(xFilial("SEB")+SE1->E1_PORTADO+Pad(M->FI2_OCORR,Len(SEB->EB_REFBAN))+'E'))
	lRet := .F.
	Help(" ",1,"FINA15101")
Endif
// Se a ocorrencia existir e ainda nao foi enviada, nao permite a inclusao
If lRet .And. FI2->(MsSeek(xFilial("FI2")+"1"+SE1->(E1_NUMBOR+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)+M->FI2_OCORR+"2"))
	lRet := .F.
	Help(" ",1,"FINA15102")
Endif
// Se o titulo nao estiver em banco
If lRet .And. Empty(SE1->E1_IDCNAB)
	lRet := .F.
	Help(" ",1,"FINA15104")
Endif

FI2->(RestArea(aAreaFI2))
Return lRet

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FA151AxInc� Autor � Claudio Donizete Souza� Data � 30/09/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para complementacao da inclusao de instrucoes de cob���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FA151AxInc(ExpC1) 													  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA151																	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FA151AxInc(cAlias)

SE1->(DbSetOrder(1))
SE1->(MsSeek(xFilial("SE1")+M->FI2_PREFIX+M->FI2_TITULO+M->FI2_PARCEL+M->FI2_TIPO))

Reclock(cAlias, .F.)
Replace FI2_NUMBOR 	WITH SE1->E1_NUMBOR
Replace FI2_PREFIX	WITH SE1->E1_PREFIXO
Replace FI2_TITULO	WITH SE1->E1_NUM
Replace FI2_PARCEL	WITH SE1->E1_PARCELA
Replace FI2_TIPO  	WITH SE1->E1_TIPO
Replace FI2_CODCLI	WITH SE1->E1_CLIENTE
Replace FI2_LOJCLI	WITH SE1->E1_LOJA
Replace FI2_DTOCOR	WITH dDataBase

Replace FI2_CARTEI	WITH "1"
Replace FI2_GERADO  WITH "2"
MsUnlock()

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fA151Dele� Autor � Bruno Sobieski        � Data � 23/03/05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apaga a ocorrencia                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fa151Dele(cAlias)                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FinA151                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa151Dele(cAlias,nRecno,nOpc)
Local lPanelFin := IsPanelFin()

If FI2->FI2_GERADO == "1"
	Help("",1,"FINA15103")
Else
	If lPanelFin  //Chamado pelo Painel Financeiro
		EXCLUI := .T.
		oPanelDados := FinWindow:GetVisPanel()
		oPanelDados:FreeChildren()
		aDim := DLGinPANEL(oPanelDados)
		AxDeleta(cAlias,nRecno,nOpc,,,,,,,,,,,,,.T.,oPanelDados,aDim,FinWindow,.T.)
	Else
		AxDeleta(cAlias,nRecno,nOpc)
	Endif
Endif

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fA151Gera� Autor � Wagner Xavier         � Data � 26/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Comunica��o Banc�ria - Envio                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fA151Gera(cAlias)                                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FinA151                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa151Gera(cAlias)
Processa({|lEnd| fa151Ger(cAlias)})  // Chamada com regua

nSeq		  := 0
nSomaValor := 0

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fA151Ger � Autor � Wagner Xavier         � Data � 26/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Comunica��o Banc�ria - Envio                               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � fA151Ger()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FinA151                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA151Ger(cAlias)
Local lPanelFin := IsPanelFin()
LOCAL nTamArq:=0,lResp:=.t.
LOCAL lHeader:=.F.,lFirst:=.F.,lFirst2:=.F.
LOCAL nTam,nDec,nUltDisco:=0
LOCAL nSavRecno := recno()
LOCAL lFIN151_1  := ExistBlock("FIN151_1")
LOCAL lFIN151_2  := ExistBlock("FIN151_2")
LOCAL lFIN151_3  := ExistBlock("FIN151_3")
LOCAL lFINA151   := ExistBlock("FIN151")
Local lFinCnab2  := ExistBlock("FINCNAB2")
LOCAL oDlg,oBmp,nMeter := 1
LOCAL cTexto := "CNAB"
LOCAL nRegEmp := SM0->(RecNo())
LOCAL cFilDe
LOCAL cFilAte
LOCAL cNumBorAnt := CRIAVAR("E1_NUMBOR",.F.)
Local lF151Exc := ExistBlock("F151EXC")
LOCAL lIdCnab := .T.
Local cArqGerado := ""
Local lF151Sum := ExistBlock("F151SUM")
Local lAtuDsk := .F.
Local lCnabEmail 	:= .F.
Local oEnab 	:= LoadBitmap( GetResources(), "LBOK" )
Local oDisab   := LoadBitmap( GetResources(), "LBNO" )
Local oDlg2,oLBFI2
Local nOpcao	:=	0
Local aItems	:=	{}
Local aButtons	:=	{}
Local nX
Local lGestao	:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .Or. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local cFilTit	:= ""
Local cQuery    := ""
Local cAliasFI2 := ""
Local cPesqBord := ""
/* GESTAO - inicio */
Local nLenSelFil	:= 0

Private aSelFil	:= {}
/* GESTAO - fim */

Aadd( aButtons, {"CHECKED" ,{ || AEval(aItems,{|x,y| aItems[y][MARCA]:=.T.})	},STR0007, "Marcar"} ) //"Marcar todos"
Aadd( aButtons, {"UNCHECKED" ,{ || AEval(aItems,{|x,y| aItems[y][MARCA]:=.F.})	},STR0015, "Desmarcar"} ) //"Desmarcar todos"

ProcRegua(FI2->(RecCount()))

//��������������������������������������������������������Ŀ
//� Verifica se o arquivo est� realmente vazio ou se       �
//� est� posicionado em outra filial.                      �
//����������������������������������������������������������
If FI2->(EOF()) .or. FI2->FI2_FILIAL # xFilial("FI2")
	HELP(" " , 1 , "NORECNO")
	Return Nil
Endif

//��������������������������������������������������������������Ŀ
//� Posiciona no Banco indicado                                  �
//����������������������������������������������������������������
cBanco  := mv_par05
cAgencia:= mv_par06
cConta  := mv_par07
cSubCta := mv_par08

dbSelectArea("SA6")
If !(dbSeek(xFilial()+cBanco+cAgencia+cConta))
	Help(" ",1,"FA150BCO")
	Return .F.
Endif

dbSelectArea("SEE")
SEE->( dbSeek(cFilial+cBanco+cAgencia+cConta+cSubCta) )
If !SEE->( found() )
	Help(" ",1,"PAR150")
	Return .F.
Else
	If Val(EE_FAXFIM)-Val(EE_FAXATU) < 100
		Help(" ",1,"FAIXA150")
	Endif
Endif

/* GESTAO - inicio */
If MV_PAR16 == 1
	aSelFil := AdmGetFil(.F.,.T.,"SE1")
	nLenSelFil := Len(aSelFil)
	If nLenSelFil > 0
		cFilDe := aSelFil[1]
		cFilAte := aSelFil[nLenSelFil]
	Else
		Help(,,"Filiais",,STR0030,1,0)		//"Optou-se pela sele��o de filiais. Deve-se, ent�o, selecionar-se ao menos uma para a gera��o do arquivo de instru��es."
		Return(.F.)
	Endif
Else
	cFilDe := cFilAnt
	cFilAte:= cFilAnt
	aSelFil := {cFilAnt}
	nLenSelFil := 1
Endif

cFilOri	:=	cFilAnt

nX := 0
/* GESTAO - fim */

While nX < nLenSelFil
	/* GESTAO - inicio */
	nX++
	cFilAnt := aSelFil[nX]
	/* GESTAO - fim */
	If lTopFin
		cAliasFI2 := GetNextAlias()
		cQuery := " SELECT FI2_CARTEI , FI2_FILIAL , FI2_GERADO , FI2_DTOCOR , FI2_NUMBOR ,"
		cQuery += " FI2_OCORR , FI2_DESCOC , FI2_TIPO , FI2_PREFIX , FI2_TITULO , FI2_PARCEL, "
		cQuery += " FI2_CODCLI , FI2_LOJCLI , R_E_C_N_O_ RECFI2"
		cQuery += " FROM "+	RetSqlName("FI2") + " FI2"

		cQuery += " WHERE FI2_FILIAL = '" + xFilial("FI2") + "' AND "
		cQuery += " FI2_CARTEI = '1' AND "
		cQuery += " ( FI2_NUMBOR >= '"+mv_par01+"' AND FI2_NUMBOR <= '"+mv_par02+"' ) AND "

		cQuery += " FI2_NUMBOR != ' ' AND "

		If (mv_par15 <> 1)
			cQuery += " FI2_GERADO = '2' AND "
		Endif

		cQuery += " FI2_DTOCOR BETWEEN '" + Dtos(mv_par13) + "' AND '" + Dtos(mv_par14) + "' AND "

		cQuery += " D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery( cQuery )

		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasFI2, .F., .T. )

		//��������������������������������������������������������������Ŀ
		//� Inicia a leitura do arquivo de Titulos                       �
		//����������������������������������������������������������������
		dbSelectArea (cAliasFI2)
		While (cAliasFI2)->( !Eof())
			If __lF151Bor
				cPesqBord:=  "ExecBlock('F151Bor',.F.,.F.)"
			Else
				cPesqBord:= "Fa150PesqBord( (cAliasFI2)->(FI2_NUMBOR), , 'R' /*Carteira*/ )"
			EndIf
			If &cPesqBord
				If SEA->EA_CART == "R"
					If cBanco+cAgencia+cConta != SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)
						//��������������������������������������Ŀ
						//� Bordero pertence a outro Bco/Age/Cta �
						//����������������������������������������
					Else
						AAdd(aItems,{.T.,;
						Stod((cAliasFI2)->(FI2_DTOCOR)),;
						(cAliasFI2)->(FI2_NUMBOR),;
						(cAliasFI2)->(FI2_OCORR),;
						(cAliasFI2)->(FI2_DESCOC),;
						(cAliasFI2)->(FI2_TIPO),;
						(cAliasFI2)->(FI2_PREFIX),;
						(cAliasFI2)->(FI2_TITULO),;
						(cAliasFI2)->(FI2_PARCEL),;
						xFilial("SE1",cFilAnt)+(cAliasFI2)->(FI2_CODCLI+FI2_LOJCLI+FI2_PREFIX+FI2_TITULO+FI2_PARCEL+FI2_TIPO),;
						(cAliasFI2)->RECFI2,;
						xFilial("SE1",cFilAnt) })
				   	Endif
				Endif
			Endif
			(cAliasFI2)->(DbSkip())
		Enddo
		(cAliasFI2)->(DbCloseArea())
	Else
		//��������������������������������������������������������������Ŀ
		//� Inicia a leitura do arquivo de Titulos                       �
		//����������������������������������������������������������������
		dbSelectArea("FI2")
		dbSetOrder(1)
		dbSeek(xFilial("FI2")+"1"+mv_par01,.T.)
		While !FI2->( Eof()) .And. FI2->FI2_CARTEI=="1" .And. FI2->FI2_NUMBOR >= mv_par01 .AND. FI2->FI2_NUMBOR <= mv_par02 .and. xFilial("FI2")==FI2->FI2_FILIAL
			If mv_par15==1 .Or. FI2_GERADO=="2"
				If Fa150PesqBord( FI2->FI2_NUMBOR, , "R" /*Carteira*/ )
					If SEA->EA_CART == "R" .and. FI2->FI2_DTOCOR >= mv_par13 .and. FI2->FI2_DTOCOR <= mv_par14
						If cBanco+cAgencia+cConta != SEA->(EA_PORTADO+EA_AGEDEP+EA_NUMCON)
							//��������������������������������������Ŀ
							//� Bordero pertence a outro Bco/Age/Cta �
							//����������������������������������������
						Else
							If Empty( Iif( lFWCodFil .And. lGestao, FWFilial("SE1"), xFilial("SE1") ) )
								If lFWCodFil .And. lGestao
									cFilTit := FWCompany("SE1") + FWUnitBusiness("SE1") + FWFilial("SE1")
								Else
									cFilTit := xFilial("SE1",cFilAnt)
								EndIf
							Else
								cFilTit := cFilAnt
							EndIf
							AAdd(aItems,{.T.,FI2_DTOCOR,FI2_NUMBOR,FI2_OCORR,FI2_DESCOC,FI2_TIPO,FI2_PREFIX,FI2_TITULO,FI2_PARCEL,;
							xFilial("SE1",cFilAnt)+FI2_CODCLI+FI2_LOJCLI+FI2_PREFIX+FI2_TITULO+FI2_PARCEL+FI2_TIPO,FI2->(Recno()),cFilTit})							
						Endif
					Endif
				Endif
			Endif
			FI2->(DbSkip())
		Enddo
	Endif
Enddo

cFilAnt	:=	cFilOri
dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)

If Len(aItems) > 0
	//����������������������������������Ŀ
	//�Definicao da tela                 �
	//������������������������������������

	aSize := MSADVSIZE()
	DEFINE MSDIALOG oDlg2 TITLE STR0016 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //tela //"Selecao de titulos para enviar"
	oDlg2:lMaximized := .T.
	oPanel := TPanel():New(0,0,'',oDlg2,, .T., .T.,, ,20,20)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

   aCabec	:={" ",	"Filial",;
   						STR0017,; // "Data Ocorrenca"
   						STR0019,; //  "C. Oc."
   						STR0020,; // "Ocorrencia"
   						STR0022,; // "Prefixo"
   						STR0023,; // "Numero"
   						STR0024,; // "Parcela"
   						STR0021,; // "Tipo"
   						STR0018}  // "Bordero"

	aTam		:=	{10,	GetTextWidth(0,Replicate("B",TamSX3('FI2_FILIAL')[1])),;
							GetTextWidth(0,Replicate("B",TamSX3('FI2_DTOCOR')[1])),;
					 		GetTextWidth(0,Replicate("B",TamSX3('FI2_OCORR')[1]+3)),;
					 		GetTextWidth(0,Replicate("B",TamSX3('FI2_DESCOC')[1]-10)),;
					 		GetTextWidth(0,Replicate("B",TamSX3('FI2_PREFIX')[1])),;
					 		GetTextWidth(0,Replicate("B",TamSX3('FI2_TITULO')[1])),;
					 		GetTextWidth(0,Replicate("B",TamSX3('FI2_PARCEL')[1]+2)),;
					 		GetTextWidth(0,Replicate("B",TamSX3('FI2_TIPO')[1])),;
							GetTextWidth(0,Replicate("B",TamSX3('FI2_NUMBOR')[1])) }

	oLBFI2			:= TwBrowse():New(015,003,000,000,,aCabec,aTam,oPanel,,,,,,,,,,,,.F.,,.T.,,.F.,,,)

	oLBFI2:nHeight	:= 410
	oLBFI2:nWidth	:= 892
	oLBFI2:SetArray(aItems)

	oLBFI2:bLine 	:= {|| {	If(aItems[oLBFI2:nAt][MARCA],oEnab,oDisab),;
									aItems[oLBFI2:nAt][FILTITULO],;
									Dtoc(aItems[oLBFI2:nAt][DATAOCORRENCIA]),;
									aItems[oLBFI2:nAt][CODIGOOCORRENCIA],;
									aItems[oLBFI2:nAt][DESCOCORRENCIA],;
									aItems[oLBFI2:nAt][PREFIXOTITULO],;
									aItems[oLBFI2:nAt][NUMTITULO],;
									aItems[oLBFI2:nAt][PARCELATITULO],;
									aItems[oLBFI2:nAt][TIPOTITULO],;
									aItems[oLBFI2:nAt][NUMEROBORDERO]}}

	oLBFI2:bLDblClick 	:= {|| aItems[oLBFI2:nAt][1]:=!aItems[oLBFI2:nAt][MARCA]}
//	oLBFI2:bHeaderClick 	:= {|x,nCol| If(lRunDblClick .And. nCol==1,AEval({|x,y| aItems[y][1]:=!aItems[y][1]},aItems),Nil),lRunDblClick := !lRunDblClick, oLBFI2:Refresh()}
	oLBFI2:Align := CONTROL_ALIGN_ALLCLIENT

	If lPanelFin  //Chamado pelo Painel Financeiro
		ACTIVATE MSDIALOG oDlg2 CENTERED ON INIT FaMyBar(oDlg2,{||nOpcao:=1,oDlg2:End()},{||nOpcao:=2,oDlg2:End()},aButtons)
   Else
		ACTIVATE DIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nOpcao:=1,oDlg2:End()},{||nOpcao:=2,oDlg2:End()},,aButtons)
	Endif

	If nOpcao <> 1
		Return .F.
	Endif

	lResp:=AbrePar(@cArqGerado)	//Abertura Arquivo ASC II

	If !lResp
		Return .F.
	Endif

	nTotCnab2 := 0
	nSeq := 0

	ProcRegua(Len(aItems))

	For nX := 1 To Len(aItems)
		IncProc()
		DbSelectArea('SE1')
		DbSetOrder(2)
		If aItems[nX][MARCA] .And. MsSeek(aItems[nX][CHAVESE1])

			dbSelectArea("SE1")
			//��������������������������������������������������������������Ŀ
		   //� Posiciona no cliente                                         �
			//����������������������������������������������������������������
			dbSelectArea("SA1")

			/* GESTAO - inicio */
			dbSeek(xFilial("SA1",SE1->E1_FILORIG)+SE1->E1_CLIENTE+SE1->E1_LOJA)
			/* GESTAO - fim */

			lCnabEmail := If(cPaisLoc <> "BRA" , A1_BLEMAIL == "1", .F.)
			If lFin151_1
				Execblock("FIN151_1",.F.,.F.)
			Endif
			//��������������������������������������������������������������Ŀ
		   //� Posiciona no Contrato bancario                               �
			//����������������������������������������������������������������
			dbSelectArea("SE9")
			dbSetOrder(1)
			dbSeek(xFilial("SE9",SE1->E1_FILORIG)+SE1->(E1_CONTRAT+E1_PORTADO+E1_AGEDEP))

			dbSelectArea("SE1")

			nSeq++
			If lF151Sum
				nSomaValor += ExecBlock("F151SUM",.F.,.F.)
			Else
				nSomaValor += SE1->E1_SALDO
	   		Endif
			RecLock('SE1',.F.)
			Replace E1_OCORREN With aItems[nX][CODIGOOCORRENCIA]
			MsUnLock()
			If ( MV_PAR09 == 1 )
				//��������������������������������������������������������������Ŀ
				//� Le Arquivo de Parametrizacao                                 �
				//����������������������������������������������������������������
				nLidos:=0
				FSEEK(nHdlBco,0,0)
				nTamArq:=FSEEK(nHdlBco,0,2)
				FSEEK(nHdlBco,0,0)
				lIdCnab := .T.

				While nLidos <= nTamArq

					//��������������������������������������������������������������Ŀ
					//� Verifica o tipo qual registro foi lido                       �
					//����������������������������������������������������������������
					xBuffer:=Space(85)
					FREAD(nHdlBco,@xBuffer,85)

					Do Case
						Case SubStr(xBuffer,1,1) == CHR(1)
							IF lHeader
								nLidos+=85
								Loop
							EndIF
						Case SubStr(xBuffer,1,1) == CHR(2)
							lFirst2 := .F. //Controle do detalhe tipo 5
							IF !lFirst
								lFirst := .T.
								FWRITE(nHdlSaida,CHR(13)+CHR(10))
								If lFina151
									Execblock("FIN151",.F.,.F.)
								Endif
							EndIF
						Case SubStr(xBuffer,1,1) == CHR(4) .and.  lCnabEmail
							IF !lFirst2
								nSeq++
								lFirst2 := .T.
								FWRITE(nHdlSaida,CHR(13)+CHR(10))
							Endif
						Case SubStr(xBuffer,1,1) == CHR(3)
							nLidos+=85
							Loop
						Otherwise
							nLidos+=85
							Loop
					EndCase

					nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
					nDec := Val(SubStr(xBuffer,23,1))
					cConteudo:= SubStr(xBuffer,24,60)
					fA151Grava(nTam,nDec,cConteudo,,lFinCnab2,@lIdCnab)
					dbSelectArea("SE1")
					nLidos+=85
				EndDO
			Else
				FI2->(MsGoTo(aItems[nX][RECNOFI2])) 
				fA151Grava(,,,,lFinCnab2,@lIdCnab)
			EndIf
			lAtuDsk := .T.
			If ( MV_PAR09 == 1 )
				lIdCnab := .T.	// Para obter novo identificador do registro CNAB na rotina
									// FA151GRAVA
	   		fWrite(nHdlSaida,CHR(13)+CHR(10))
				IF !lHeader
					lHeader := .T.
				EndIF
			Endif
			FI2->(MsGoTo(aItems[nX][RECNOFI2]))
			RecLock('FI2',.F.)
			Replace FI2_GERADO WITH "1"
			Replace FI2_DTGER  WITH dDataBase
	      	MsUnLock()

			If lFin151_2
				nSeq++
				If !(Execblock("FIN151_2",.f.,.f.))		// N�o incrementou
					nSeq--
				Endif
			Endif
		Endif
	Next nX

	SM0->(dbgoto(nRegEmp))
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

	If ( mv_par09 == 1 )
		//��������������������������������������������������������������Ŀ
		//� Monta Registro Trailler                              		  �
		//����������������������������������������������������������������
		nSeq++
		nLidos:=0
		FSEEK(nHdlBco,0,0)
		nTamArq:=FSEEK(nHdlBco,0,2)
		FSEEK(nHdlBco,0,0)
		While nLidos <= nTamArq

			//��������������������������������������������������������������Ŀ
			//� Tipo qual registro foi lido                                  �
			//����������������������������������������������������������������
			xBuffer:=Space(85)
			FREAD(nHdlBco,@xBuffer,85)

			IF SubStr(xBuffer,1,1) == CHR(3)
				nTam := 1+(Val(SubStr(xBuffer,20,3))-Val(SubStr(xBuffer,17,3)))
				nDec := Val(SubStr(xBuffer,23,1))
				cConteudo:= SubStr(xBuffer,24,60)
				fA151Grava( nTam,nDec,cConteudo,.T.,lFinCnab2,.F.)
			Endif
			nLidos+=85
		End
	Else
		RodaCnab2(nHdlSaida,MV_PAR03)
	EndIf
	//��������������������������������������������������������������Ŀ
	//� Atualiza Numero do ultimo Disco                              �
	//����������������������������������������������������������������
	dbSelectArea("SEE")
	IF !Eof() .and. lAtuDsk
		Reclock("SEE")
		nUltDisco:=VAL(EE_ULTDSK)+1
	   Replace EE_ULTDSK With StrZero(nUltDisco,TamSx3("EE_ULTDSK")[1])
	   MsUnlock()
	EndIF
	If ( MV_PAR09 == 1 )
		// Se nao existir o campo que determina se deve ou nao saltar
		// a linha na gravacao do trailler do arquivo, ou se existir e
		// estiver como "1-Sim", Grava o final de linha (Chr(13)+Chr(10))
		If SEE->EE_FIMLIN == "1"
			FWRITE(nHdlSaida,CHR(13)+CHR(10))
		Endif
	EndIf

	dbSelectArea( cAlias )
	dbGoTo( nSavRecno )

	//��������������������������������������������������������������Ŀ
	//� Verifica se existe logotipo de um banco qualquer             �
	//� para ser utilizado em qualquer banco                         �
	//����������������������������������������������������������������
	If File("BANCO.BMP")
		If MsgYesNo(Oemtoansi(STR0025+Substr(SA6->A6_NREDUZ,1,8)+ STR0026)) //"Foi detectado a gera��o de um arquivo padr�o "###" , Confirma a Gera��o"
			DEFINE DIALOG oDlg FROM 100,100 TO 365,550 TITLE cTexto PIXEL
			@0,0 BITMAP oBmp FILENAME "BANCO.BMP" PIXEL OF oDlg SIZE 225,125 NOBORDER
			@125,0 METER oMeter VAR nMeter TOTAL 100000 SIZE 224,8 OF oDlg PIXEL
			DEFINE SBUTTON FROM 2000,3000 TYPE 2  ENABLE OF oDlg
			oDlg:bStart := {|| CursorWait(), Fa151Process(oDlg,oMeter) }
			ACTIVATE DIALOG oDlg CENTERED
			RELEASE OBJECTS oBmp
		Endif
	Endif

	//��������������������������������������������������������������Ŀ
	//� Fecha o arquivo gerado.                                      �
	//����������������������������������������������������������������
	FCLOSE(nHdlSaida)
	If lFin151_3
		Execblock("FIN151_3",.F.,.F.)
	Endif

Endif

Return(.T.)
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fA151Grava� Autor � Wagner Xavier         � Data � 26/05/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Rotina de Geracao do Arquivo de Remessa de Comunicacao      ���
���          �Bancaria                                                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ExpL1:=fa151Grava(ExpN1,ExpN2,ExpC1)                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FinA151                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
STATIC Function fA151Grava( nTam,nDec,cConteudo,lTrailler,lFinCnab2,lIdCnab)
Local cIdCnab
Local aGetArea   := GetArea()
Local aOrdSe1    := {}

DEFAULT lIdCnab := .F.

lTrailler := IIF( lTrailler==NIL, .F., lTrailler ) // Para imprimir o trailler
                                                   // caso se deseje abandonar
                                                   // a gera��o do arquivo
                                                   // de envio pela metade

lFinCnab2 := Iif( lFinCnab2 == Nil, .F., lFinCnab2 )

If ( MV_PAR09 == 1 )
	If !lTrailler .and. lIdCnab .And. Empty(SE1->E1_IDCNAB) // So gera outro identificador, caso o titulo
														 // ainda nao o tenha, pois pode ser um re-envio do arquivo
		// Gera identificador do registro CNAB no titulo enviado
		cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,19)
		dbSelectArea("SE1")
		aOrdSE1 := SE1->(GetArea())
		dbSetOrder(16)
		While SE1->(dbSeek(xFilial("SE1")+cIdCnab))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,19)
		EndDo
		SE1->(RestArea(aOrdSE1))
		Reclock("SE1")
		SE1->E1_IDCNAB := cIdCnab
		MsUnlock()
		ConfirmSx8()
		lIdCnab := .F. // Gera o identificacao do registro CNAB apenas uma vez no
							// titulo enviado
	Endif
	//����������������������������������������������������������Ŀ
	//� Analisa conteudo                                         �
	//������������������������������������������������������������
	IF Empty(cConteudo)
		cCampo:=Space(nTam)
	Else
		lConteudo := fa151Orig( cConteudo )
		IF !lConteudo
			RestArea(aGetArea)
			Return nRetorno
		Else
			IF ValType(xConteudo)="D"
				cCampo := GravaData(xConteudo,.F.)
			Elseif ValType(xConteudo)="N"
				cCampo:=Substr(Strzero(xConteudo,nTam,nDec),1,nTam)
			Else
				cCampo:=Substr(xConteudo,1,nTam)
			EndIf
		EndIf
	EndIf
	If Len(cCampo) < nTam  //Preenche campo a ser gravado, caso menor
		cCampo:=cCampo+Space(nTam-Len(cCampo))
	EndIf
	Fwrite( nHdlSaida,cCampo,nTam )
Else
	nTotCnab2++
	DetCnab2(nHdlSaida,MV_PAR03,lIdCnab,"SE1")
	lIdCnab := .T.	// Para obter novo identificador do registro CNAB na rotina
						// DetCnab2
	If lFinCnab2
		nSeq := Execblock("FINCNAB2",.F.,.F.,{nHdlSaida,nSeq,nTotCnab2})
	EndIf
EndIf
RestArea(aGetArea)
Return 1

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Fa151Chav� Autor � Paulo Boschetti       � Data � 10/11/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Fa151Num()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINA130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fa151Chav()
LOCAL lRetorna := .T.
If !Empty(m->ee_codigo) .And. !Empty(m->ee_agencia) .And. !Empty(m->ee_conta) .And. !Empty(m->ee_subcta)
	dbSelectArea("SEE")
	SEE->( dbSeek(cFilial+m->ee_codigo+m->ee_agencia+m->ee_conta+m->ee_subcta) )
	If SEE->( Found() )
		Help(" ",1,"FA150NUM")
		lRetorna := .F.
	EndIf
EndIf
Return lRetorna


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fa151Orig � Autor � Wagner Xavier         � Data � 10/11/92 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Verifica se expressao e' valida para Remessa CNAB.          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �Fina151                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa151Orig( cForm )
Local bBlock:=ErrorBlock(),bErro := ErrorBlock( { |e| ChecErr260(e,cForm) } )
Private lRet := .T.

BEGIN SEQUENCE
	xConteudo := &cForm
END SEQUENCE
ErrorBlock(bBlock)
Return lRet



Static Function Fa151Process(oDlg,oMeter)
Local ni
oMeter:nTotal := 1000
oMeter:Set(0)
For ni:= 1 to 1000
	oMeter:Set(ni)
	SysRefresh()
Next
oDlg:End()
Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �fa151Leg  �Autor  �Bruno Sobieski      � Data �  23/03/05   ���
�������������������������������������������������������������������������͹��
���Desc.     �Legenda da MBrowse da geracao de cnab de ocorrencias        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �fina151                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fa151Leg(nReg)

Local uRetorno := .T.
Local aLegenda	:= {  {"BR_VERDE"   ,	STR0027 	},;	 //"Nao gerado"
						   {"BR_VERMELHO" ,	STR0028 }}  //"Gerado"


If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, {"FI2_GERADO == '2'", aLegenda[1][1]}) // Nao gerado
	Aadd(uRetorno, {"FI2_GERADO == '1'", aLegenda[2][1]})// // Gerado
Else
	BrwLegenda(STR0006,STR0005,aLegenda) //"Geracao de CNAB de ocorrencias"###"Legenda"
Endif

Return uRetorno

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �22/11/06 ���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
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
/*/
Static Function MenuDef()
Local aRotina    := {	{STR0001, "axPesqui" , 0 , 0,,.F.},;  	// "Pesquisar"
                        {STR0002, "AxVisual" , 2 , 0 },;		// "Visualizar"
                        {STR0004, "fA151Gera", 3 , 0 },;  	// "Gerar Arquivo"
                        {STR0029, "Fa151Inclu", 0 , 3 },;  	// "Incluir"
                        {STR0003, "fA151Dele", 0 , 5 },;  	// "Excluir"
                        {STR0005, "fA151LEG" , 0 , 0, ,.F. }}  	// "Legenda"
Return(aRotina)



/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �FinA151T   � Autor � Marcelo Celi Marques � Data � 31.03.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada semi-automatica utilizado pelo gestor financeiro   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � FINC050                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FinA151T(aParam)

	cRotinaExec := "FINA151"
	ReCreateBrow("FI2",FinWindow)
	FinA151(aParam[1])
	ReCreateBrow("FI2",FinWindow)
	dbSelectArea("FI2")

	INCLUI := .F.
	ALTERA := .F.
	EXCLUI := .F.

Return .T.

/*/
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o	 �F151LinLot� Autor � Gustavo Henrique     � Data � 08/08/11 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o total de linhas do detalhe do lote		         ���
���          � Usado na configuracao do CNAB2 Receber   				 ���
������������������������������������������������������������������������Ĵ��
��� Uso		 � Configurador do CNAB2 Receber	 						 ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function F151LinLot()
Return nQtdLinLote+1		// esta variavel armazena o numero de linhas, considerando os segmentos do detalhe do lote
