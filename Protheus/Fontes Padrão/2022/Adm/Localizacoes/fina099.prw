#INCLUDE "FINA099.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � FINA099	� Autor � Jos� Lucas	 	    � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � CONTROLE DE PAGAMENTOS POR CART�O DE CREDITO.	    	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function FinA099(aRotAuto, nOpcAuto )

Local nPos
Local bBlock
Local nX 		:= 0
Local aCores :=	{{ 'FRC_STATUS == "01"','BR_AMARELO' },;	//Em Analise
				 { 'FRC_STATUS == "02"','BR_VERDE'	 },;	//Pagamento Aprovado
				 { 'FRC_STATUS == "03"','BR_AZUL'	 },;	//Rejei��o Parcial														//SC com Pedido Colocado Parcial
				 { 'FRC_STATUS == "04"','BR_VERMELHO'}}		//Rejei��o Total

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa 	 �
//� ----------- Elementos contidos por dimensao ------------	 �
//� 1. Nome a aparecer no cabecalho 							 �
//� 2. Nome da Rotina associada									 �
//� 3. Usado pela rotina										 �
//� 4. Tipo de Transa��o a ser efetuada							 �
//�	 1 -Pesquisa e Posiciona em um Banco de Dados				 �
//�	 2 -Simplesmente Mostra os Campos							 �
//�	 3 -Inclui registros no Bancos de Dados						 �
//�	 4 -Altera o registro corrente								 �
//�	 5 -Exclui um registro cadastrado							 �
//����������������������������������������������������������������
PRIVATE aRotina   := MenuDef()
PRIVATE lF099Auto := ( aRotAuto <> NIL )
PRIVATE aDiario    := {}
PRIVATE aFlagCTB   := {}


//��������������������������������������������������������������Ŀ
//� Verifica o numero do Lote 											  �
//����������������������������������������������������������������
PRIVATE cArquivo := ""
PRIVATE cLote := "",lAltera	:=.F.
Private Valor5 := 0
Private Valor6 := 0
Private Valor7 := 0
PRIVATE cModRetPIS := GetNewPar( "MV_RT10925", "1" )
PRIVATE nIndexSE2 := ""
PRIVATE aDadosRef := Array(7)
PRIVATE aDadosRet := Array(7)
PRIVATE aDadosImp := Array(3)
PRIVATE cIndexSE2 := ""
Private cOldNaturez
PRIVATE lAlterNat := .F.
Private nRecnoNdf := 0
Private nDifPcc   := 0
Private nOldValorPg := 0
PRIVATE lAltValor := .F.
PRIVATE aAutoCab  := aRotAuto
PRIVATE aTrocaF3  := {}
PRIVATE mv_par07  := .F.

Private cSE2TpDsd := ""  // vari�vel utilizada pelo PMS
Private cTipoParaAbater := ""

If cPaisLoc $ "ARG|POR|EUA"
	Private cIndice
	Private cIndexArg
Endif

PRIVATE lIntegracao := IF(GetMV("MV_EASY")=="S",.T.,.F.)

//Campo para alimentar o campo E2_EMIS1
PRIVATE dDataEmis1	:= Nil
If !lF099Auto
	SetKey (VK_F12,{|a,b| AcessaPerg("FIN099",.T.)})
Endif
pergunte("FIN099",.F.)

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes					 �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0001  // "Controle de Recebimentos por Cart�o de Cr�dito"

//�����������������������������������������������������Ŀ
//� Ponto de entrada para pre-validar os dados a serem  �
//� exibidos.                                           �
//�������������������������������������������������������
IF ExistBlock("F099BROW")
	ExecBlock("F099BROW",.f.,.f.)
Endif

If lF099Auto
	aValidGet := {}
 	If ! SE2->(MsVldGAuto(aValidGet)) // consiste os gets
	  	Return .f.
   	EndIf
	DEFAULT nOpcAuto := 3
	MBrowseAuto(nOpcAuto,aAutoCab,"FRC")
Else
	If nOpcAuto<>Nil
		//���������������������������������������������������������������������Ŀ
		//� Chamada direta da funcao de Inclusao/Alteracao/Visualizacao/Exclusao�
		//�����������������������������������������������������������������������
		nPos := nOpcAuto
		If ( nPos # 0 )
			bBlock := &( "{ |x,y,z,k| " + aRotina[ nPos,2 ] + "(x,y,z,k) }" )
			dbSelectArea("FRC")
			Eval( bBlock,Alias(),FRC->(Recno()),nPos)
		EndIf
	Else
		//��������������������������������������������������������������Ŀ
		//� Endereca a funcao de BROWSE											  �
		//����������������������������������������������������������������
		mBrowse( 6, 1,22,75,"FRC",,,,,,aCores)
	EndIf
EndIf
//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados									  �
//����������������������������������������������������������������
Set Key VK_F12 To
Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Jose Lucas - SI5910    � Data �25/09/10 ���
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
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados       	  ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}
Local aRotinaNew

AADD( aRotina,	{ STR0002, "AxPesqui" 		, 0 , 1,,.F. }) //"Pesquisar"
AADD( aRotina,	{ STR0003 ,"AxVisual"		, 0 , 2}) 		// "Visualizar"
AADD( aRotina,	{ STR0004 ,"fA099Manut"		, 0 , 4}) 		// "Manuten��o"
AADD( aRotina,	{ STR0019 ,"fA099Cons"		, 0 , 2}) 		// "Consulta"
AADD( aRotina,	{ STR0005 ,"fA099Legenda"	, 0 , 6, ,.F.})	// "Legenda"

//�������������������������������������������������������������Ŀ
//�Ponto de entrada para inclus�o de novos itens no menu aRotina�
//���������������������������������������������������������������
If ExistBlock("fA099ROT")
	aRotinaNew := ExecBlock("fA099ROT",.F.,.F.,aRotina)
	If (ValType(aRotinaNew) == "A")
		aRotina := aClone(aRotinaNew)
	EndIf
EndIf
Return(aRotina)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �fA099Legenda� Autor � Jos� Lucas - SI5910 � Data �10.05.2004 ���
��������������������������������������������������������������������������Ĵ��
���          �Exibe uma janela contendo a legenda da mBrowse.              ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � FINA099                                                     ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function fA099Legenda()

BrwLegenda(cCadastro,STR0005,{	{"BR_AMARELO"	,OemToAnsi(STR0006)},; 		//"Legenda" ### "Em Analise"
								{"BR_VERDE"		,OemToAnsi(STR0007)},;		//"Pagamento Aprovado"
								{"BR_AZUL"		,OemToAnsi(STR0008)},;		//"Rejei��o Parcial"
								{"BR_VERMELHO"	,OemToAnsi(STR0009)	}	})  //"Rejei��o Total"
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Manut� Autor � Jose Lucas - SI5910   � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Obter dados do status ou aceite da Administradora.		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Manut(cAlias,nRecno,nOpcx) 							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA099Manut(cAlias,nRecno,nOpcx)
Local aArea  	 := GetArea()
Local nOpca  	 := 0
Local aSize  	 := MSADVSIZE()
Local cCodStatus := CriaVar("FRC_STATUS")
Local cCodMotivo := CriaVar("FRC_MOTIVO")
Local cDscStatus := CriaVar("FR0_DESC01")
Local cDscMotivo := CriaVar("FR0_DESC01")
Local nValPago  := 0.00
Local cDocCancel := CriaVar("FRC_DOCCAN")
Local dDataCanc  := CriaVar("FRC_DATCAN")
Local cHoraCanc  := CriaVar("FRC_HORCAN")
Local aPicture   := Array(8)
Local oCbxParc
Local oDlg
Local nOpc 		 := 0

aPicture[1] := PesqPict("FRC","FRC_STATUS", TamSX3("FRC_STATUS")[1])
aPicture[2] := PesqPict("FRC","FRC_MOTIVO", TamSX3("FRC_MOTIVO")[1])
aPicture[3] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[4] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[5] := PesqPict("FRC","FRC_VALREC", TamSX3("FRC_VALREC")[1])
aPicture[6] := PesqPict("FRC","FRC_DOCCAN", TamSX3("FRC_DOCCAN")[1])
aPicture[7] := PesqPict("FRC","FRC_DATCAN", TamSX3("FRC_DATCAN")[1])
aPicture[8] := PesqPict("FRC","FRC_HORCAN", TamSX3("FRC_HORCAN")[1])

dbSelectArea("FRC")

cCodStatus := FRC->FRC_STATUS
cDscStatus := fA099DscSta(FRC->FRC_STATUS)

If cCodStatus <> "01"
	MsgAlert(STR0021,STR0020)	//"Mantenimiento ya efectuado!" ### "Atenci�n"
Else
	DEFINE MSDIALOG oDlg TITLE STR0010 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL // "Manuten��o dos T�tulos"

		@ 027,010 SAY STR0011	PIXEL OF oDlg COLOR CLR_HBLUE // "C�digo Status"
		@ 025,070 MSGET cCodStatus  F3 "FR0EQ2" Picture aPicture[1] SIZE 30,08;
				  Valid fA099Status(cCodStatus,@cDscStatus,@nValPago,@dDataCanc,@cHoraCanc) PIXEL OF oDlg

		@ 025,120 MSGET cDscStatus      	 Picture aPicture[2] SIZE 170,08	PIXEL OF oDlg WHEN .F.

		If cCodStatus $ "01|02"
			@ 042,010 SAY STR0012	PIXEL OF oDlg // "Motivo Cancel.
		Else
			@ 042,010 SAY STR0012	PIXEL OF oDlg COLOR CLR_HBLUE // "Motivo Cancel.
		EndIf

		@ 040,070 MSGET cCodMotivo	F3 "FR0EQ3" Picture aPicture[3] SIZE 30,08;
				  Valid fA099Motivo(cCodMotivo,@cDscMotivo,cCodStatus)	PIXEL OF oDlg
		@ 040,120 MSGET cDscMotivo		     Picture aPicture[4] SIZE 170,08	PIXEL OF oDlg WHEN .F.

		@ 057,010 SAY STR0013	PIXEL OF oDlg 					  // "Valor Recebido".
		@ 055,070 MSGET nValPago		     Picture aPicture[5] SIZE 70,08;
	        	  Valid fa099ValRec(nValPago,cCodStatus)		PIXEL OF oDlg

		@ 072,010 SAY STR0014	PIXEL OF oDlg				  // "C�digo Cancel."
		@ 070,070 MSGET cDocCancel			 Picture aPicture[6] SIZE 50,08;
				  Valid fa099Doc(cDocCancel,cCodStatus) WHEN cCodStatus $ "03|04"		PIXEL OF oDlg

		@ 087,010 SAY STR0015	PIXEL OF oDlg				  // "C�digo Cancel."
		@ 085,070 MSGET dDataCanc			 Picture aPicture[7] SIZE 50,08;
			 	  Valid fa099Date(dDataCanc)			WHEN cCodStatus $ "03|04"		PIXEL OF oDlg

		@ 102,010 SAY STR0016	PIXEL OF oDlg				  // "Hora Cancel."
		@ 100,070 MSGET cHoraCanc			 Picture aPicture[8] SIZE 30,08;
				  Valid .T. WHEN cCodStatus $ "03|04"		PIXEL OF oDlg

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(fa099Ok(),(nOpca := 1,oDlg:End()),NIL)},{|| nOpca := 2,oDlg:End()})

	//Gravar titulos em um array para posterior substitui��o.
	If nOpca == 1
		If AllTrim(cCodStatus) == "02"		//Pagamento Aprovado.
			fA099Grv02(cCodStatus,cCodMotivo)
		ElseIf AllTrim(cCodStatus) $ "03" 	//Rejei��o Parcial
			//Estornar a Substitui��o dos T�tulos de forma parcial.
			fA099Grv03(cCodStatus,cCodMotivo,nValPago,cDocCancel,dDataCanc,cHoraCanc)
		ElseIf AllTrim(cCodStatus) $ "04" 	//Rejei��o Total
			//Estornar a Substitui��o dos T�tulos de forma total
			fA099Grv04(cCodStatus,cCodMotivo,nValPago,cDocCancel,dDataCanc,cHoraCanc)
		EndIf
	EndIf
EndIf

RestArea(aArea)
Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Cons � Autor � Jose Lucas - SI5910   � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Apresentar Consulta dos Status e Motivo.					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Cons(cAlias,nRecno,nOpcx) 							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA099Cons(cAlias,nRecno,nOpcx)
Local aArea  	 := GetArea()
Local nOpca  	 := 0
Local aSize  	 := MSADVSIZE()
Local cCodStatus := CriaVar("FRC_STATUS")
Local cCodMotivo := CriaVar("FRC_MOTIVO")
Local cDscStatus := CriaVar("FR0_DESC01")
Local cDscMotivo := CriaVar("FR0_DESC01")
Local nValPago  := 0.00
Local cDocCancel := CriaVar("FRC_DOCCAN")
Local dDataCanc  := CriaVar("FRC_DATCAN")
Local cHoraCanc  := CriaVar("FRC_HORCAN")
Local aPicture   := Array(8)
Local oCbxParc
Local oDlg
Local nOpc 		 := 0

aPicture[1] := PesqPict("FRC","FRC_STATUS", TamSX3("FRC_STATUS")[1])
aPicture[2] := PesqPict("FRC","FRC_MOTIVO", TamSX3("FRC_MOTIVO")[1])
aPicture[3] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[4] := PesqPict("FR0","FR0_DESC01", TamSX3("FR0_DESC01")[1])
aPicture[5] := PesqPict("FRC","FRC_VALREC", TamSX3("FRC_VALREC")[1])
aPicture[6] := PesqPict("FRC","FRC_DOCCAN", TamSX3("FRC_DOCCAN")[1])
aPicture[7] := PesqPict("FRC","FRC_DATCAN", TamSX3("FRC_DATCAN")[1])
aPicture[8] := PesqPict("FRC","FRC_HORCAN", TamSX3("FRC_HORCAN")[1])

dbSelectArea("FRC")

cCodStatus := FRC->FRC_STATUS
cCodMotivo := FRC->FRC_MOTIVO

cDscStatus := fA099DscSta(FRC->FRC_STATUS)
cDscMotivo := fA099DscMot(FRC->FRC_MOTIVO)
nValPago   := FRC->FRC_VALREC
cDocCancel := FRC->FRC_DOCCAN
dDataCanc  := FRC->FRC_DATCAN
cHoraCanc  := FRC->FRC_HORCAN

DEFINE MSDIALOG oDlg TITLE STR0010 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL // "Manuten��o dos T�tulos"

	@ 027,010 SAY STR0011	PIXEL OF oDlg COLOR CLR_HBLUE // "C�digo Status"
	@ 025,070 MSGET cCodStatus  F3 "FR0EQ2" Picture aPicture[1] SIZE 30,08  WHEN .F. PIXEL OF oDlg
	@ 025,120 MSGET cDscStatus      	 	Picture aPicture[2] SIZE 170,08	WHEN .F. PIXEL OF oDlg

	If cCodStatus $ "01|02"
		@ 042,010 SAY STR0012	PIXEL OF oDlg
	Else
		@ 042,010 SAY STR0012	PIXEL OF oDlg COLOR CLR_HBLUE // "Motivo Cancel.
	EndIf

	@ 040,070 MSGET cCodMotivo	F3 "FR0EQ3" Picture aPicture[3] SIZE 30,08  WHEN .F. PIXEL OF oDlg
	@ 040,120 MSGET cDscMotivo		     	Picture aPicture[4] SIZE 170,08	WHEN .F. PIXEL OF oDlg

	@ 057,010 SAY STR0013	PIXEL OF oDlg 					  // "Valor Recebido".
	@ 055,070 MSGET nValPago			    Picture aPicture[5] SIZE 70,08  WHEN .F. PIXEL OF oDlg

	@ 072,010 SAY STR0014	PIXEL OF oDlg				  // "C�digo Cancel."
	@ 070,070 MSGET cDocCancel			 	Picture aPicture[6] SIZE 50,08	WHEN .F. PIXEL OF oDlg

	@ 087,010 SAY STR0015	PIXEL OF oDlg				  // "C�digo Cancel."
	@ 085,070 MSGET dDataCanc			 Picture aPicture[7] 	SIZE 50,08  WHEN .F. PIXEL OF oDlg

	@ 102,010 SAY STR0016	PIXEL OF oDlg				  // "Hora Cancel."
	@ 100,070 MSGET cHoraCanc			 Picture aPicture[8] 	SIZE 30,08  WHEN .F. PIXEL OF oDlg

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(fa099Ok(),(nOpca := 1,oDlg:End()),NIL)},{|| nOpca := 2,oDlg:End()})

RestArea(aArea)
Return

Function fA099dValid()
Return .T.

Function fA099Ok()
Return .T.

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Grv02� Autor � Jose Lucas - SI5910   � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar Status e Motivo de aprova��o.						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Grv02(cCodStatus,cCodMotivo)						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA099Grv02(cCodStatus,cCodMotivo)
Local aArea     := GetArea()
Local lBxCrAuto := If(mv_par06==1,.T.,.F.)	//Baixa Autom�tica do Titulo no Contas a Receber...
Local aDadosTit := {}
Local aBaixa    := {}
Local nValorBX  := 0.00

If lBxCrAuto
   	SE2->(dbSetOrder(1))
   	If SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPCAR))

		// Titulo com saldo zero, j� foi baixa pelo Contas a Receber, Baixa Automatica ou Recibo.
		If SE2->E2_SALDO > 0 .and. Empty(SE2->E2_BAIXA)

			//Guarda dados do titulo principal
			aDadosTit := {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, SE2->E2_FORNECE,;
			SE2->E2_LOJA, SE2->E2_VALOR, SE2->E2_VENCTO, SE2->E2_HIST, SE2->E2_EMISSAO, SE2->E2_NOMFOR }

			//�����������������������������������������������������������������������������������Ŀ
			//� Baixa do titulo tipo "CC"...                                                      �
			//�������������������������������������������������������������������������������������
			IncProc(STR0017+aDadosTit[1]+"/"+aDadosTit[2])
			aBaixa	:=	{}
			nValorBX := SE2->E2_VALOR
			AADD( aBaixa, { "E2_PREFIXO" 	, SE2->E2_PREFIXO		, Nil } )	// 01
			AADD( aBaixa, { "E2_NUM"     	, SE2->E2_NUM		 	, Nil } )	// 02
			AADD( aBaixa, { "E2_PARCELA" 	, SE2->E2_PARCELA		, Nil } )	// 03
			AADD( aBaixa, { "E2_TIPO"    	, SE2->E2_TIPO			, Nil } )	// 04
			AADD( aBaixa, { "E2_FORNECE"	, SE2->E2_FORNECE		, Nil } )	// 05
			AADD( aBaixa, { "E2_LOJA"    	, SE2->E2_LOJA			, Nil } )	// 06
			AADD( aBaixa, { "E2_VALOR"    	, nValorBX				, Nil } )	// 06
			AADD( aBaixa, { "AUTMOTBX"  	, "NOR"					, Nil } )	// 07
			AADD( aBaixa, { "AUTBANCO"  	, ""					, Nil } )	// 08
			AADD( aBaixa, { "AUTAGENCIA"  	, ""					, Nil } )	// 09
			AADD( aBaixa, { "AUTCONTA"  	, ""					, Nil } )	// 10
			AADD( aBaixa, { "AUTDTBAIXA"	, SE2->E2_EMISSAO		, Nil } )	// 11
			AADD( aBaixa, { "AUTHIST"   	, STR0018				, Nil } )	// 12
			AADD( aBaixa, { "AUTDESCONT" 	, 0						, Nil } )	// 13
			AADD( aBaixa, { "AUTMULTA"	 	, 0						, Nil } )	// 14
			AADD( aBaixa, { "AUTJUROS" 		, 0						, Nil } )	// 15
			AADD( aBaixa, { "AUTOUTGAS" 	, 0						, Nil } )	// 16
			AADD( aBaixa, { "AUTVLRPG"  	, 0        				, Nil } )	// 17
			AADD( aBaixa, { "AUTVLRME"  	, 0						, Nil } )	// 18
			AADD( aBaixa, { "AUTCHEQUE"  	, ""					, Nil } )	// 19

			lMsErroAuto := .F.
			MSExecAuto({|x,y| Fina080(x,y)},aBaixa,3)
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			EndIf
		EndIf
    EndIf
EndIf

//�����������������������������������������������������������������������������������Ŀ
//� Atualiza o Status 02-Pagamento Aprovado na tabela de controle - FRC.              �
//�������������������������������������������������������������������������������������
RecLock("FRC",.F.)
FRC_STATUS := cCodStatus
FRC_VALREC := FRC_VALOR
MsUnLock()

RestArea(aArea)
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Grv03� Autor � Jose Lucas - SI5910   � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar Status, Motivo de aprova��o e reverter substituicao.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Grv03(cCodStatus,cCodMotivo,nValPago,cDocCancel,dDataCanc,cHoraCanc)  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA099Grv03(cCodStatus,cCodMotivo,nValPago,cDocCancel,dDataCanc,cHoraCanc)
Local aArea      := GetArea()
Local aDadosTit  := {}
Local aBaixa     := {}
Local nValorBX   := 0.00
Local nValorSE2  := 0.00
Local nReg       := FRC->(Recno())
Local nOpc 		 := 5
Local lSubst	 := .T.
Local lSubsSuces := .F.
Local lEdita     := GetNewPar("MV_EDITCC","1") == "2"
Local nC         := 0
Local aCampos    := {}
Local lAtuSldNat := .T.
Local cPadrao    := "512"
Local cArquivo   := ""
Local nHdlPrv    := 0
Local nTotal     := 0.00
Local lPadrao    := If(mv_par01==1,.T.,.F.)	//Lancamento Contabil on line...
//Local lAglutina  := If(mv_par01==2,.T.,.F.)	//Aglutina lancamentos...
Local lDigita    := If(mv_par02==1,.T.,.F.)	//Mostra lancamentos...
Local lBxCrAuto := If(mv_par06==1,.T.,.F.)	//Baixa Autom�tica do Titulo no Contas a Receber...
Local aAreaFRC 	 := ""
Local cPrefixo   := ""
Local cNum       := ""
Local cTipoCC    := ""
Local cFornece   := ""
Local cLoja      := ""
Local cParcela 	 := GetMV("MV_1DUP")
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lPmsInt	:= IsIntegTop(,.T.)
nValorSE2 := nValPago

If lBxCrAuto
   	SE2->(dbSetOrder(1))
   	If SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPO))

		// Titulo com saldo zero, j� foi baixa pelo Contas a Receber, Baixa Automatica ou Recibo.
		If SE2->E2_SALDO > 0 .and. Empty(SE2->E2_BAIXA)

			//Guarda dados do titulo principal
			aDadosTit := {SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_NATUREZ, SE2->E2_FORNECE,;
			SE2->E2_LOJA, SE2->E2_VALOR, SE2->E2_VENCTO, SE2->E2_HIST, SE2->E2_EMISSAO, SE2->E2_NOMFOR }

			//�����������������������������������������������������������������������������������Ŀ
			//� Baixa do titulo tipo "CC"...                                                      �
			//�������������������������������������������������������������������������������������
			IncProc(STR0017+aDadosTit[1]+"/"+aDadosTit[2])
			aBaixa	:=	{}
			nValorBX := nValPago
			AADD( aBaixa, { "E2_PREFIXO" 	, SE2->E2_PREFIXO		, Nil } )	// 01
			AADD( aBaixa, { "E2_NUM"     	, SE2->E2_NUM		 	, Nil } )	// 02
			AADD( aBaixa, { "E2_PARCELA" 	, SE2->E2_PARCELA		, Nil } )	// 03
			AADD( aBaixa, { "E2_TIPO"    	, SE2->E2_TIPO			, Nil } )	// 04
			AADD( aBaixa, { "E2_FORNECE"	, SE2->E2_FORNECE		, Nil } )	// 05
			AADD( aBaixa, { "E2_LOJA"    	, SE2->E2_LOJA			, Nil } )	// 06
			AADD( aBaixa, { "E2_VALOR"    	, nValorBX				, Nil } )	// 06
			AADD( aBaixa, { "AUTMOTBX"  	, "NOR"					, Nil } )	// 07
			AADD( aBaixa, { "AUTBANCO"  	, ""					, Nil } )	// 08
			AADD( aBaixa, { "AUTAGENCIA"  	, ""					, Nil } )	// 09
			AADD( aBaixa, { "AUTCONTA"  	, ""					, Nil } )	// 10
			AADD( aBaixa, { "AUTDTBAIXA"	, SE2->E2_EMISSAO		, Nil } )	// 11
			AADD( aBaixa, { "AUTHIST"   	, STR0018				, Nil } )	// 12
			AADD( aBaixa, { "AUTDESCONT" 	, 0						, Nil } )	// 13
			AADD( aBaixa, { "AUTMULTA"	 	, 0						, Nil } )	// 14
			AADD( aBaixa, { "AUTJUROS" 		, 0						, Nil } )	// 15
			AADD( aBaixa, { "AUTOUTGAS" 	, 0						, Nil } )	// 16
			AADD( aBaixa, { "AUTVLRPG"  	, 0        				, Nil } )	// 17
			AADD( aBaixa, { "AUTVLRME"  	, 0						, Nil } )	// 18
			AADD( aBaixa, { "AUTCHEQUE"  	, ""					, Nil } )	// 19

			lMsErroAuto := .F.
			MSExecAuto({|x,y| Fina080(x,y)},aBaixa,3)
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			EndIf
		EndIf
    EndIf
EndIf

If (FRC->FRC_VALOR - nValPago) > 0.00
	nValorSe2 := FRC->FRC_VALOR - nValPago
   	SE2->(dbSetOrder(1))
   	If SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPO))

		aCampos := {}
		For nC := 1 To SE2->(FCount())
		   	If SE2->(FieldName(nC)) == "E2_PARCELA"
		    	AADD(aCampos,{SE2->(FieldName(nC)),cParcela})
            ElseIf SE2->(FieldName(nC)) == "E2_TIPO"
			   	AADD(aCampos,{SE2->(FieldName(nC)),FRC->FRC_TIPO})
			Else
		    	AADD(aCampos,{SE2->(FieldName(nC)),SE2->(FieldGet(nC))})
			EndIf
		Next nC

		RecLock("SE2",.T.)
		For nC := 1 To Len(aCampos)
			FieldPut(nC,aCampos[nC,2])
		Next nC
		If cPaisLoc == "EQU"
			E2_PREFIXO  := FRC->FRC_PREORI
    	    E2_NUM		:= FRC->FRC_NUMORI
        	E2_PARCELA  := FRC->FRC_PARORI
			E2_TIPO     := FRC->FRC_TIPORI 	//If(AllTrim(FRC->FRC_TIPO)=="CC","NF",FRC->FRC_TIPO)
		EndIf
		E2_VALOR 	:= nValorSE2
		E2_SALDO 	:= SE2->E2_VALOR
	  	E2_VALLIQ   := SE2->E2_VALOR
	  	E2_BAIXA    := CTOD("  /  /  ")
	  	MsUnLock()

	   	SE2->(dbSetOrder(1))
   		SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPCAR))
	 	nOpc := 5	 		//Exclusao
		lSubsSuces := .T.

	EndIf
	If lSubsSuces

		If ( lPadrao )
			//������������������������������������������������������������������Ŀ
			//� Inicializa Lancamento Contabil                                   �
			//��������������������������������������������������������������������
			nHdlPrv := HeadProva( cLote,;
	       		    		      "FINA040" /*cPrograma*/,;
		       		      		  Substr(cUsuario,7,6),;
	           					  @cArquivo )
		EndIf

		//�����������������������������������������������������������Ŀ
		//� Inicializa a gravacao dos lancamentos do SIGAPCO          �
		//�������������������������������������������������������������
		PcoIniLan("000002")

		If ! lF099Auto .and. ( lPadrao )
			//������������������������������������������������������������������Ŀ
			//� Prepara Lancamento Contabil                                      �
			//��������������������������������������������������������������������
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E2_LA", "S", "SE2", SE2->( Recno() ), 0, 0, 0} )
			Endif
			nTotal += DetProva( nHdlPrv,;
		        	            cPadrao,;
		            	        "FINA040" /*cPrograma*/,;
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

			dbSelectArea("SE2")
			dbSetOrder(1)
			If dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPO)
				//��������������������������������������������Ŀ
				//� Atualizacao dos dados do Modulo SIGAPMS    �
				//����������������������������������������������
				If IntePms().AND. !lPmsInt
					PmsWriteFI(2,"SE2")	//Estorno
					PmsWriteFI(3,"SE2")	//Exclusao
				EndIf

				//�����������������������������������������������������������Ŀ
				//� Chama a integracao com o SIGAPCO antes de apagar o titulo �
				//�������������������������������������������������������������
				PcoDetLan("000002","01","FINA050",.T.)

				If ExistBlock("F099SUBS")
					ExecBlock("F099SUBS",.F.,.F.)
				Endif
   				If lAtuSldNat
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "-")
				Endif
			Endif
		Else
			BEGIN TRANSACTION
			If ( lPadrao )
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA050",cLote)
			EndIf

			//��������������������������������������������������������������Ŀ
			//� Apaga o lacamento gerado para a conta orcamentaria - SIGAPCO �
			//����������������������������������������������������������������
			PcoDetLan("000002","01","FINA050",.T.)

			If lAtuSldNat
				AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "-")
			Endif
			END TRANSACTION
    	EndIf

		If ( lPadrao )
			RodaProva(nHdlPrv,nTotal)
			//�����������������������������������������������������Ŀ
			//� Envia para Lancamento Contabil					    �
			//�������������������������������������������������������
			lDigita:=IIF(mv_par01==1,.T.,.F.)
			If UsaSeqCor()
 				aDiario := {}
				aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
			Else
				aDiario := {}
			EndIf
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,aDiario)
		EndIf
		//Excluir os titulos do Tipo == "CC" gravados na tabela SE2.
		SE2->(dbSetOrder(1))
		If SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM))
   			While !SE2->(Eof()) .and. SE2->E2_FILIAL == xFilial("SE2") .and. SE2->E2_PREFIXO == FRC->FRC_PREFIX .and.;
     			SE2->E2_NUM == FRC->FRC_NUM
    			If AllTrim(SE2->E2_TIPO) == AllTrim(FRC->FRC_TIPCAR) .AND. Empty(SE2->E2_BAIXA)
		   			RecLock("SE2",.F.)
   					DbDelete()
   					MsUnLock()
   				EndIf
   				SE2->(dbSkip())
   			End
		EndIf
		dbSelectArea("FRC")
		aAreaFRC := GetArea()
		cPrefixo := FRC->FRC_PREFIX
		cNum     := FRC->FRC_NUM
		cTipoCC  := FRC->FRC_TIPCAR
		cFornece := FRC->FRC_FORNEC
		cLoja    := FRC->FRC_LOJA

		FRC->(dbSetOrder(1))
   		If FRC->(dbSeek(xFilial("FRC")+cPrefixo+cNum))
   			While !FRC->(Eof()) .and. FRC->FRC_PREFIX == cPrefixo .and. FRC->FRC_NUM == cNum
	        	If FRC->FRC_FORNEC == cFornece .and. FRC->FRC_LOJA == cLoja .and. FRC->FRC_TIPCAR == cTipoCC
					//Alterar o codigo do Status e Motivo Incluir registros na tabela de Controle de T�tulos a pagar por Cart�o de Credito
					RecLock("FRC",.F.)
					FRC_STATUS := cCodStatus
					FRC_MOTIVO := cCodMotivo
					FRC_DOCCAN := cDocCancel
					FRC_DATCAN := dDataCanc
					FRC_HORCAN := cHoraCanc
					FRC_VALREC := nValPago
					MsUnLock()
				EndIf
    			FRC->(dbSkip())
    		End
    	EndIf
    	RestArea(aAreaFRC)
    EndIf
EndIf

RestArea( aArea )
Return


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Grv04� Autor � Jose Lucas - SI5910   � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar Status e Reverter a substiti��o.					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Grv04(cCodStatus,cCodMotivo)						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA099Grv04(cCodStatus,cCodMotivo,nValPago,cDocCancel,dDataCanc,cHoraCanc)
Local aArea 	 := FRC->(GetArea())
Local nValorSE2  := 0.00
Local nOpc 		 := 5
Local lSubsSuces := .F.
Local nC         := 0
Local aCampos    := {}
Local lAtuSldNat := .T.
Local cPadrao    := "512"
Local cArquivo   := ""
Local nHdlPrv    := 0
Local nTotal     := 0.00
Local lPadrao    := If(mv_par01==1,.T.,.F.)	//Lancamento Contabil on line...
//Local lAglutina  := If(mv_par01==2,.T.,.F.)	//Aglutina lancamentos...
Local lDigita    := If(mv_par02==1,.T.,.F.)	//Mostra lancamentos...
Local aAreaFRC 	 := ""
Local cPrefixo   := ""
Local cNum       := ""
Local cTipoCC    := ""
Local cFornece   := ""
Local cLoja      := ""
Local cParcela 	 := GetMV("MV_1DUP")
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lPmsInt	 := IsIntegTop(,.T.)

If (FRC->FRC_VALOR - nValorSe2) > 0.00
	nValorSe2 := FRC->FRC_VALOR - nValorSe2
   	SE2->(dbSetOrder(1))
   	If SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPO))
		aCampos := {}
		For nC := 1 To SE2->(FCount())
		   	If SE2->(FieldName(nC)) == "E2_PARCELA"
		    	AADD(aCampos,{SE2->(FieldName(nC)),cParcela})
            ElseIf SE2->(FieldName(nC)) == "E2_TIPO"
			   	AADD(aCampos,{SE2->(FieldName(nC)),FRC->FRC_TIPO})
			Else
		    	AADD(aCampos,{SE2->(FieldName(nC)),SE2->(FieldGet(nC))})
			EndIf
		Next nC

		RecLock("SE2",.T.)
		For nC := 1 To Len(aCampos)
			FieldPut(nC,aCampos[nC,2])
		Next nC
		If cPaisLoc == "EQU"
			E2_PREFIXO  := FRC->FRC_PREORI
    	    E2_NUM		:= FRC->FRC_NUMORI
        	E2_PARCELA  := FRC->FRC_PARORI
			E2_TIPO     := FRC->FRC_TIPORI 	//If(AllTrim(FRC->FRC_TIPO)=="CC","NF",FRC->FRC_TIPO)
		EndIf
		E2_VALOR 	:= nValorSE2
		E2_SALDO 	:= SE2->E2_VALOR
	  	E2_VALLIQ   := SE2->E2_VALOR
	  	E2_BAIXA    := CTOD("  /  /  ")
	  	E2_HIST		:= ""
	    MsUnLock()

	   	SE2->(dbSetOrder(1))
   		SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPCAR))
	 	nOpc := 5	 		//Exclusao
		lSubsSuces := .T.
	EndIf
	If lSubsSuces

		If ( lPadrao )
			//������������������������������������������������������������������Ŀ
			//� Inicializa Lancamento Contabil                                   �
			//��������������������������������������������������������������������
			nHdlPrv := HeadProva( cLote,;
	       		    		      "FINA050" /*cPrograma*/,;
		       		      		  Substr(cUsuario,7,6),;
	           					  @cArquivo )
		EndIf

		//�����������������������������������������������������������Ŀ
		//� Inicializa a gravacao dos lancamentos do SIGAPCO          �
		//�������������������������������������������������������������
		PcoIniLan("000002")

		If ! lF099Auto .and. ( lPadrao )
			//������������������������������������������������������������������Ŀ
			//� Prepara Lancamento Contabil                                      �
			//��������������������������������������������������������������������
			If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
				aAdd( aFlagCTB, {"E2_LA", "S", "SE2", SE2->( Recno() ), 0, 0, 0} )
			Endif
			nTotal += DetProva( nHdlPrv,;
		        	            cPadrao,;
		            	        "FINA050" /*cPrograma*/,;
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

			dbSelectArea("SE2")
			dbSetOrder(1)
			If dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM+FRC->FRC_PARCEL+FRC->FRC_TIPO)
				//��������������������������������������������Ŀ
				//� Atualizacao dos dados do Modulo SIGAPMS    �
				//����������������������������������������������
				If IntePms().AND. !lPmsInt
					PmsWriteFI(2,"SE2")	//Estorno
					PmsWriteFI(3,"SE2")	//Exclusao
				EndIf

				//�����������������������������������������������������������Ŀ
				//� Chama a integracao com o SIGAPCO antes de apagar o titulo �
				//�������������������������������������������������������������
				PcoDetLan("000002","01","FINA050",.T.)

				If ExistBlock("F099SUBS")
					ExecBlock("F099SUBS",.F.,.F.)
				Endif
   				If lAtuSldNat
					AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "-")
				Endif
			Endif
		Else
			BEGIN TRANSACTION
			If ( lPadrao )
				nTotal+=DetProva(nHdlPrv,cPadrao,"FINA050",cLote)
			EndIf

			//��������������������������������������������������������������Ŀ
			//� Apaga o lacamento gerado para a conta orcamentaria - SIGAPCO �
			//����������������������������������������������������������������
			PcoDetLan("000002","01","FINA050",.T.)

			If lAtuSldNat
				AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ, "-")
			Endif
			END TRANSACTION
    	EndIf

		If ( lPadrao )
			RodaProva(nHdlPrv,nTotal)
			//�����������������������������������������������������Ŀ
			//� Envia para Lancamento Contabil					    �
			//�������������������������������������������������������
			lDigita:=IIF(mv_par01==1,.T.,.F.)
			If UsaSeqCor()
 				aDiario := {}
				aDiario := {{"SE2",SE2->(recno()),SE2->E2_DIACTB,"E2_NODIA","E2_DIACTB"}}
			Else
				aDiario := {}
			EndIf
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,aDiario)
		EndIf
		//Excluir os titulos do Tipo == "CC" gravados na tabela SE2.
		SE2->(dbSetOrder(1))
		If SE2->(dbSeek(xFilial("SE2")+FRC->FRC_PREFIX+FRC->FRC_NUM))
   			While !SE2->(Eof()) .and. SE2->E2_FILIAL == xFilial("SE2") .and. SE2->E2_PREFIXO == FRC->FRC_PREFIX .and.;
     			SE2->E2_NUM == FRC->FRC_NUM
    			If AllTrim(SE2->E2_TIPO) == AllTrim(FRC->FRC_TIPCAR)
		   			RecLock("SE2",.F.)
   					DbDelete()
   					MsUnLock()
   				EndIf
   				SE2->(dbSkip())
   			End
		EndIf
		dbSelectArea("FRC")
		aAreaFRC := GetArea()
		cPrefixo := FRC->FRC_PREFIX
		cNum     := FRC->FRC_NUM
		cTipoCC  := FRC->FRC_TIPCAR
		cFornece := FRC->FRC_FORNEC
		cLoja    := FRC->FRC_LOJA

		FRC->(dbSetOrder(1))
   		If FRC->(dbSeek(xFilial("FRC")+cPrefixo+cNum))
   			While !FRC->(Eof()) .and. FRC->FRC_PREFIX == cPrefixo .and. FRC->FRC_NUM == cNum
	        	If FRC->FRC_FORNECE == cFornece .and. FRC->FRC_LOJA == cLoja .and. FRC->FRC_TIPCAR == cTipoCC
					//Alterar o codigo do Status e Motivo Incluir registros na tabela de Controle de T�tulos a pagar por Cart�o de Credito
					RecLock("FRC",.F.)
					FRC_STATUS := cCodStatus
					FRC_MOTIVO := cCodMotivo
					FRC_DOCCAN := cDocCancel
					FRC_DATCAN := dDataCanc
					FRC_HORCAN := cHoraCanc
					FRC_VALREC := nValPago
					MsUnLock()
				EndIf
    			FRC->(dbSkip())
    		End
    	EndIf
    	RestArea(aAreaFRC)
    EndIf
EndIf

RestArea( aArea )
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Status � Autor � Jose Lucas - SI5910 � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar Status e Reverter a substiti��o.					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Status(cCodStatus,cCodMotivo,,nValPago,dDataCanc,cHoraCanc) ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA099Status(cCodStatus,cDscStatus,nValPago,dDataCanc,cHoraCanc)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ2"+Space(nTamTabela-3)
Local lResult 	 := .T.

cCodStatus := cCodStatus+Space(nTamChave-Len(cCodStatus))

FR0->(dbSetOrder(1))
If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodStatus,1,nTamChave)))

	cDscStatus := FR0->FR0_DESC01

	If AllTrim(cCodStatus) == "02"			//Pago Aprovado...
		nValPago := FRC->FRC_VALOR
	ElseIf AllTrim(cCodStatus) $ "03|04"	//Rejei��o Parcial ou Total...
		nValPago := 0.00
		dDataCanc  := dDataBase
		cHoraCanc  := Subs(Time(),1,5)
	EndIf

Else
   	MsgAlert(STR0022,STR0020)	//"Estatus de pago invalido !","Atenci�n")
   	lResult := .F.
EndIf

RestArea(aArea)
Return( lResult )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Motivo � Autor � Jose Lucas - SI5910 � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar Status e Reverter a substiti��o.					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Motivo(cCodStatus,cCodMotivo,cCodStatus)		 	  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fA099Motivo(cCodMotivo,cDscMotivo,cCodStatus)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ3"+Space(nTamTabela-3)
Local lResult 	 := .T.

If !Empty(cCodMotivo)
	If AllTrim(cCodStatus) $ "01|02"
    	MsgAlert(STR0023,STR0020) // "Ingrese el motivo solamente cuando Status diferente de 01 y 02 !","Atenci�n")
    	lResult := .F.
	EndIf
Else
	If ! AllTrim(cCodStatus) $ "03|04"
       	lResult := .T.
		RestArea(aArea)
		Return( lResult )
	EndIf
EndIf

If lResult

	cCodMotivo := cCodMotivo+Space(nTamChave-Len(cCodMotivo))

	FR0->(dbSetOrder(1))
	If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodMotivo,1,nTamChave)))
   		cDscMotivo := FR0->FR0_DESC01
	Else
   		MsgAlert(STR0024,STR0020)	//"Motivo de rechazo inv�lido !","Atenci�n")
   		lResult := .F.
	EndIf
EndIf

RestArea(aArea)
Return( lResult )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099ValRec � Autor � Jose Lucas - SI5910 � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar Status e Reverter a substiti��o.					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099ValRec(nValPago,cCodStatus)						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa099ValRec(nValPago,cCodStatus)
Local aArea 	 := GetArea()
Local lResult 	 := .T.

If AllTrim(cCodStatus) == "03"
	If nValPago >= FRC->FRC_VALOR	//Pago Parcial
   		MsgAlert(STR0025,STR0020)	//"Valor recebido mayor que el importe del t�tulo !","Atenci�n")
   		lResult := .F.
   	ElseIf nValPago == 0
   		MsgAlert(STR0026,STR0020)	//"Ingrese el valor parcial recibido !","Atenci�n")
   		lResult := .F.
   	EndIf
EndIf

RestArea(aArea)
Return( lResult )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Date � Autor � Jose Lucas - SI5910   � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validar a data de cancelamento...						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Date()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa099Date(dDataCanc)
Local aArea 	 := GetArea()
Local lResult 	 := .T.

If dDataCanc < FRC->FRC_DATTEF
	MsgAlert(STR0027,STR0020)	//"Fecha de anulaci�n menor que fecha del t�tulo !","Atenci�n")
	lResult := .F.
EndIf

RestArea(aArea)
Return( lResult )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099DscSta � Autor � Jose Lucas - SI5910 � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retornar a descri��o da Situa��o de Pagamento.			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � cDscSatus := fA099DscSat(cCodStatus)						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa099DscSta(cCodStatus)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ2"+Space(nTamTabela-3)
Local cDescri    := ""

cCodStatus := cCodStatus+Space(nTamChave-Len(cCodStatus))

FRC->(dbSetOrder(1))
If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodStatus,1,nTamChave)))
	cDescri := FR0->FR0_DESC01
EndIf

RestArea(aArea)
Return( cDescri )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099DscMot � Autor � Jose Lucas - SI5910 � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Retornar a descri��o do Motivo de Rejei��o.				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � cDscMotivo := fA099DscMot(cCodMotivo)					  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa099DscMot(cCodMotivo)
Local aArea 	 := GetArea()
Local nTamTabela := TamSX3("FR0_TABELA")[1]
Local nTamChave  := TamSX3("FR0_CHAVE")[1]
Local cTabela 	 := "EQ3"+Space(nTamTabela-3)
Local cDescri    := ""

cCodMotivo := cCodMotivo+Space(nTamChave-Len(cCodMotivo))

FRC->(dbSetOrder(1))
If FR0->(dbSeek(xFilial("FR0")+Subs(cTabela,1,nTamTabela)+Subs(cCodMotivo,1,nTamChave)))
	cDescri := FR0->FR0_DESC01
EndIf

RestArea(aArea)
Return( cDescri )

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fA099Doc    � Autor � Jose Lucas - SI5910 � Data � 25/09/10 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validar o codigo do documento para rejeicao.				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fA099Doc(cCodStatus)										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA099													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function fa099Doc(cDocCancel,cCodStatus)
Local aArea   := GetArea()
Local lResult := .T.

If AllTrim(cCodStatus) $ "03|04" .and. Empty(cDocCancel)
	MsgAlert(STR0028,STR0020)	//"C�digo de rechazo es obligat�rio !","Atenci�n")
	lResult := .F.
EndIf

RestArea(aArea)
Return( lResult )
