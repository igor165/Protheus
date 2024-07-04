#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA920.CH"
#INCLUDE "TBICONN.CH"

#DEFINE VALMERC		1 // Valor total do mercadoria liquido
#DEFINE VALDESC		2 // Valor total do desconto
#DEFINE FRETE		3 // Valor total do Frete
#DEFINE VALDESP		4 // Valor total da despesa
#DEFINE TOTF1		5 // Total de Despesas Folder 1
#DEFINE TOTPED		6 // Total do Pedido
#DEFINE SEGURO		7 // Valor total do seguro
#DEFINE TOTF3		8 // Total utilizado no Folder 3
#DEFINE VALMERCB	9 // Valor total do mercadoria bruto
#DEFINE NTRIB		10// Valor das despesas nao tributadas - Portugal
#DEFINE TARA		11// Valor da Tara - Portugal
#DEFINE TPFRETE     12// Tipo de Frete.

Static lLGPD  		:= FindFunction("FISLGPD") .And. FISLGPD()


/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � Mata920  � Autor � Andreia dos Santos    � Data � 02/02/00   ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � SAIDA de Notas Fiscais de Venda Manual                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���Andre Veiga   �21/01/06�091814�- Alteracao para considerar os titulos    ���
���              �        �      �  gerados atraves do SIGALOJA.            ���
���Raul Ortiz M  |23/10/17�TSSERMI�Modificaci�n para considerar valores de  ���
���              �        �01-193�la lista de precios                       ���
���Raul Ortiz    �19/02/18�DMICNS� Tratamiendo para Execauto al ser misma   ���
���              �        �-1822 �Tes en producto y arreglo                 ���
���Oscar G.      �29/04/19�DMINA-�En Fun. A920Total, se valida que aCols    ���
���              �        �6243  �contenga informaci�n. (COL)               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function Mata920(xAutoCab,xAutoItens,nOpcAuto,lLoteAux)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Define Array contendo os campos do arquivo que sempre deverao�
//� aparecer no browse. (funcao mBrouse)                         �
//� ----------- Elementos contidos por dimensao ---------------- �
//� 1. Titulo do campo (Este nao pode ter mais de 12 caracteres) �
//� 2. Nome do campo a ser editado                               �
//����������������������������������������������������������������
Local lSped := .F.
Local cFiltraSD2 := Nil
Local cRet := ""
LOCAL aFixe:={	{ STR0050,"D2_DOC    " },; //"Numero da NF"
	{ STR0051,"D2_SERIE  " },; //"Serie da NF "
	{ STR0052,"D2_CLIENTE" } } //"Cliente     "

Local aCores    := {	{'D2_TIPO=="N"'		,'DISABLE'   	},;	// NF Normal
						{'D2_TIPO=="P"'		,'BR_AZUL'   	},;	// NF de Compl. IPI
						{'D2_TIPO=="I"'		,'BR_MARROM' 	},;	// NF de Compl. ICMS
						{'D2_TIPO=="C"'		,'BR_PINK'   	},;	// NF de Compl. Preco/Frete
						{'D2_TIPO=="B"'		,'BR_CINZA'  	},;	// NF de Beneficiamento
						{'D2_TIPO=="D"'		,'BR_AMARELO'	} }	// NF de Devolucao

Default nOpcAuto     := 3
Default lLoteAux    := .F.

//����������������������������������������������������������Ŀ
//�Inicializando variaveis para processo de rotina automatica�
//������������������������������������������������������������
PRIVATE l920Auto     := ValType(xAutoCab) == "A" .and. ValType(xAutoItens) == "A"
PRIVATE aAutoItens   := {}
PRIVATE aAutoCab     := {}
PRIVATE aRotina  		:= MenuDef()
PRIVATE lLoteAuto		:= lLoteAux

PRIVATE lGeraNum := .F.
PRIVATE oFisTrbGen

lSped := cPaisLoc == "BRA"
If lSped
	aAdd(aRotina,{ STR0085 ,"a920Compl", 0 , 4 , 0 , NIL}) //"Complementos"
Endif

//��������������������������������������������������������������Ŀ
//� Inicializa variaveis da funcao pergunte                      �
//����������������������������������������������������������������
mv_par01	:=	2
mv_par02	:=	2
mv_par03	:=	2

PRIVATE cCadastro	:= OemToAnsi(STR0053) //"Notas Fiscais de Sa�da"

//Realiza filtro MBrowse
#IFDEF TOP
	If !l920Auto .And. ExistBlock("M920FIL")
		cRet := AllTrim(ExecBlock("M920FIL",.F.,.F.))
		If ( Valtype(cRet) == "C" )
			cFiltraSD2 := cRet
		EndIf
	Endif
#ENDIF

//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//� Obs.: O parametro aFixe nao e' obrigatorio e pode ser omitido�
//����������������������������������������������������������������
If l920Auto
	aAutoCab   := xAutoCab
	aAutoItens := xAutoItens
	DEFAULT nOpcAuto := 3
	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),"SF2")
Else
	MBrowse( 6, 1,22,75,"SD2",aFixe,"D2_TES",,,,aCores,,,,,,,,cFiltraSD2) //Fun��o utilizando SQL
EndIf

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a920NFSAI � Autor � Andreia dos Santos    � Data �02/02/00  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de inclusao de notas fiscai de SAIDA.             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � a920NFSAI(ExpC1,ExpN1,ExpN2)                  	          ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Alias do arquivo                                   ���
���          � ExpN1 = Numero do registro                                 ���
���          � ExpN2 = Numero da opcao selecionada                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
���Mauro Sano    �20/02/06�092271�- Alteracao para mostrar as duplicatas  ���
���              �        �      �  caso a NF utilize as condicoes:       ���
���              �        �      �   CC/CD/FI/VA/CO                       ���
���Marcio Lopes  �19/05/06�095009|- Permite visualizar as duplicataas     ���
���              �        �      �  geradas pelo SIGALOJA, apartir de     ���
���              �        �      �  qualquer modulo. (versao TOP )         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/

Function A920NFSAI(cAlias,nReg,nOpcx)
//����������������������������������������������������������������������Ŀ
//�Define variaveis                                                      �
//������������������������������������������������������������������������
Local lMA920AQISS := IIf(ExistBlock( "MA920AQISS"),ExecBlock("MA920AQISS",.f.,.f.),.F.)
Local aArea		:= GetArea()
Local aAreaSE1	:= SE1->(GetArea())
Local aAuxCombo1:= {"N","D","B","I","P","C"}
Local aPages	:= {"HEADER"}
Local aSizeAut	:= {}
Local aCombo1	:= {STR0041,;	//"Normal"
	STR0042,;	//"Devolu�ao"
	STR0043,;	//"Beneficiamento"
	STR0044,;	//"Compl.  ICMS"
	STR0045,;	//"Compl.  IPI"
	STR0046}	//"Compl. Pre�o"

Local aCombo2	:= { STR0047 }  //"Sim"
Local aTitles	:= {	OemToAnsi(STR0006),; //"Totais"
	OemToAnsi(STR0007),; //"Inf. Cliente"
	OemToAnsi(STR0008),; //"Descontos/Frete/Despesas"
	OemToAnsi(STR0009),; //"Impostos"
	OemToAnsi(STR0010)}  //"Livros Fiscais"
Local aInfclie	:= {"","",CTOD("  /  /  "),CTOD("  /  /  "),"",""}
Local a920Var	:= Iif(cPaisLoc<>"PTG",{0,0,0,0,0,0,0,0,0,0,0,""},{0,0,0,0,0,0,0,0,0,0,0})
Local aUsButtons:= {}
Local aRecSF3	:= {}
Local aRecSE1	:= {}
Local aRecSE2	:= {}
Local aPedidos	:= {}
Local aObj		:= Iif(cPaisLoc <> "PTG",Array(19),Array(22))
Local aObj1		:= Array(10) 
Local aButton   := {{"RELATORIO",{|| oGetDados:oBrowse:lDisablePaint:=.T.,;
	A920Pedido(1,aPedidos,SerieNfId("SF2",2,"F2_SERIE")+"/"+SF2->F2_DOC),;
	oGetDados:oBrowse:lDisablePaint:=.F. },STR0054,STR0072 }} //"Visualiza Pedido" //"Visualiza Pedido"
Local aNFEletr	:= {}
Local aDANFE	:= {}

Local c920Tipo	:= ""
Local cCombo2	:= ""
Local c920SClie

Local nOpc		:= 0

Local dDtDigit  := dDataBase

Local lGravaOk	:= .T.
Local l920Inclui:= .F.
Local l920Deleta:= .F.
Local l920Altera:= .F.
Local lContinua	:= .T.
Local lPyme     := Iif(Type("__lPyme") <> "U",__lPyme,.F.)

Local oDlg
Local oGetDados
Local oc920SClie
Local oc920GClie
Local oc920Loj
Local oCond
Local ocNota
Local ocSerie
Local ocEspec
Local ocModal
Local ocVend
Local ocMoeda
Local ocTxMoeda
Local o920Tipo
Local od920Emis
Local oCombo1
Local oNFIni
Local oNFFim

Local xButton 	:= {}
Local nI		:= 0
Local nNFe		:= 0
Local nObj		:= 0
Local nObjD		:= 0
Local nLancAp	:= 0
Local nDANFE    := 0
Local nHoras    := 0
Local nSpedExc  := GetNewPar("MV_SPEDEXC",24)

Local aHeadCDA	:= {}
Local aColsCDA	:= {}
Local aHeadCDV	:= {}
Local aColsCDV	:= {}
Local aHeadAGH	:= {}
Local aColsAGH  := {}
Local nLinSay   := 0
Local cChave    := ""
Local lVAut920  := GetNewPar("MV_VAUT920", .T.)
Local nPosCpo   := 0
Local cSerId    := ""
Local cPerg		:= "MATA920"
Local nTrbGen	:= 0
Local lTrbGen 	:= IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.)
Local lMATA920	:= IsInCallStack("MATA920")
Local cTpNrNfs	:= SuperGetMv("MV_TPNRNFS",.F., "1")
Local lExistCFF := .F.

Private l920Visual:= .F.

//���������������������������������������������������������Ŀ
//� Define a funcao utilizada ( Incl.,Alt.,Visual.,Exclu.)  �
//�����������������������������������������������������������
Do Case
Case nOpcX == 0
	nOpcX := 2
	PRIVATE aRotina := {{ STR0002 	,"a920NFSAI"	, 0 	, 2,0,NIL},;
						{ STR0002 	,"a920NFSAI"	, 0 	, 2,0,NIL}}
	PRIVATE cCadastro := STR0053 + STR0096 //"Notas Fiscais de Sa�da - VISUALIZAR"
	l920Visual 	:= .T.
Case aRotina[nOpcx][4] == 2
	l920Visual 	:= .T.
Case aRotina[nOpcx][4] == 3
	l920Inclui	:= .T.
Case aRotina[nOpcx][4] == 5
	l920Deleta	:= .T.
	l920Visual	:= .T.
	If cPaisLoc =='BRA'
		ValidPerg(cPerg)
		Pergunte(cPerg,.F.)
		SetKey( VK_F12,{|| Pergunte(cPerg,.T.)})
	EndIf
EndCase
cCadastro := IIf( Type("cCadastro") == "U" , STR0053 , cCadastro )

lInclui := l920Inclui
lLote   := (nOpcx == 5) .Or. ( Type("lLoteAuto") == "L" .AND.  lLoteAuto ) 
//Rotina A920NFSAI chamada diretamente pela rotina MATC090 e n�o � instanciada a vari�vel private lLoteAux

If l920Visual .And. !l920Deleta
	AAdd(aButton,{ "ORDEM", {|| A920Track() }, STR0070, STR0071 } ) //"System Tracker"
EndIf

If l920Visual
	Aadd(aButton , {'S4WB013N' ,{|| a920RatCC(@aHeadAGH,@aColsAGH,N) },STR0089,STR0090} )//"Rateio por Item do pedido de venda"##"Rateio"
EndIf

//��������������������������������������������������������������Ŀ
//� Avalia botoes do usuario                                     �
//����������������������������������������������������������������
If ExistBlock( "MA920BUT" )
	If ValType( aUsButtons := ExecBlock( "MA920BUT", .F., .F. ) ) == "A"
		AEval( aUsButtons, { |x| AAdd( aButton, x ) } ) 	 	
	EndIf
EndIf

PRIVATE aGetCpo := {"D2_COD"    ,"D2_UM"     ,"D2_QUANT"    ,"D2_PRCVEN"    ,;
	                "D2_TOTAL"  ,"D2_VALIPI" ,"D2_VALICM"   ,"D2_TES"       ,;
	                "D2_CF"     ,"D2_PICM"   ,"D2_IPI"      ,"D2_PESO"      ,;
	                "D2_CONTA"  ,"D2_DESC"   ,"D2_NFORI"    ,"D2_SERIORI"   ,;
	                "D2_BASEICM","D2_LOCAL"	 ,"D2_DESCON"   ,"D2_ICMSRET"   ,;
	                "D2_BSFCPST","D2_BRICMS" ,"D2_SEGUM"    ,"D2_QTSEGUM"   ,;
	                "D2_ITEM"   ,"D2_CLASFIS","D2_CODISS"   ,"D2_PRUNIT"    ,;
	                "D2_BASEIPI","D2_PROJPMS","D2_EDTPMS"   ,"D2_TASKPMS"   ,;
	                "D2_CUSTO1" ,"D2_CUSTO2" ,"D2_CUSTO3"   ,"D2_CUSTO4"    ,;
	                "D2_CUSTO5" ,"D2_CCUSTO" ,"D2_ITEMORI"  ,"D2_ITEMCC"    ,;
	                "D2_CLVL"   ,"D2_BASEDES","D2_ICMSCOM"  ,"D2_DIFAL"     ,;
	                "D2_ALFCCMP"   , "D2_VFCPDIF"}

Private bTgRefresh		:= {|| Iif(lTrbGen .And. ValType(oGetDados) == "O",MaFisLinTG(oFisTrbGen,oGetDados:oBrowse:nAt),.T.)}
Private bFolderRefresh	:= {|| (A920FRefresh(aObj))}
Private bGDRefresh
Private bRefresh		:= {|| (A920Refresh(@a920Var,l920Inclui)),(Eval(bFolderRefresh)),Eval(bTgRefresh)}
Private bListRefresh	:= {|| (A920FisToaCols()),Eval(bRefresh),Eval(bGdRefresh)}
Private aRemito			:= {}	//Array com os remitos de cada item do acols

If SD2->(ColumnPos("D2_TPREPAS")) > 0
	aAdd(aGetCpo,"D2_TPREPAS")
EndIf

If lMATA920
	bGDRefresh := If (Type("l920Auto") != "L" .or. !l920Auto,{|| (oGetDados:oBrowse:Refresh()) },{|| nil })
Else
	bGDRefresh := {|| nil }
EndIf 

//���������������������������������������������������Ŀ
//�Verifica se o campo de codigo de lancamento cat 83 �
//�deve estar visivel no acols                        �
//�����������������������������������������������������
If SuperGetMV("MV_CAT8309",,.F.)
	aAdd(aGetCpo,"D2_CODLAN")
EndIf

//���������������������������������������������������Ŀ
//�PE para habilitar D2_ALIQISS na inclusao da NF     �
//�����������������������������������������������������
If l920Inclui .And. lMA920AQISS
	aAdd(aGetCpo,"D2_ALIQISS")
EndIf

//��������������������������������������������������������������Ŀ
//� Verifica parametro MV_DATAFIS pela data de digitacao.        �
//����������������������������������������������������������������
If !aRotina[nOpcx][4] == 2 .And. !FisChkDt(dDatabase)
	Return
EndIf

If Type("l920Auto") != "L" .or. !l920Auto
	dbSelectArea("SF2")
	dbSetOrder(1)
	MsSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA)
Else
	dbSelectArea("SD2")
	dbSetOrder(3)
	MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
Endif

Private	cTipo  		:= If(l920Inclui,CriaVar("F2_TIPO")	,SF2->F2_TIPO)		,;
	    c920Nota 	:= If(l920Inclui,CriaVar("F2_DOC")		,SF2->F2_DOC)		,;
	    c920Serie	:= If(l920Inclui,CriaVar("F2_SERIE")	,SF2->F2_SERIE)	,;
	    d920Emis	:= If(l920Inclui,CriaVar("F2_EMISSAO")	,SF2->F2_EMISSAO)	,;
	    c920Client	:= If(l920Inclui,CriaVar("F2_CLIENTE")	,SF2->F2_CLIENTE)	,;
	    c920Loja	:= If(l920Inclui,CriaVar("F2_LOJA")	,SF2->F2_LOJA)		,;
	    c920Especi	:= If(l920Inclui,CriaVar("F2_ESPECIE")	,SF2->F2_ESPECIE)	,;
	    c920NFIni	:= If(l920Inclui,CriaVar("F2_DOC")		,SF2->F2_DOC)		,;
	    c920Vend	:= If(l920Inclui,CriaVar("F2_VEND1")	,SF2->F2_VEND1)		,;
	    c920DecExp	:= Iif(cPaisLoc=="PTG",If(l920Inclui,CriaVar("F2_DECLEXP")	,SF2->F2_DECLEXP),"")

Private c920Moeda	:= If(l920Inclui,CriaVar("F2_MOEDA"),SF2->F2_MOEDA),; // Jeniffer 19/03 - Moeda
	    c920Taxa	:= If(l920Inclui,CriaVar("F2_TXMOEDA"),SF2->F2_TXMOEDA),; // Jeniffer 19/03 - Taxa Moeda
	    c920Modal	:= If( !(cPaisLoc $ 'BRA|TRI'),If(l920Inclui,CriaVar("F2_NATUREZ"),SF2->F2_NATUREZ),""),; // Jeniffer 19/03 - Modalidade
	    c920NFFim	:= If(l920Inclui,CriaVar("F2_DOC"),SF2->F2_NFORI)

PRIVATE aCols		:= {},;
	    aHeader 	:= {},;
	    N 			:= 1
PRIVATE oLancApICMS
PRIVATE oLancCDV
PRIVATE aColsD2		:=	aCols
PRIVATE aHeadD2		:=	aHeader

//����������������������������������������������������������������������Ŀ
//� Ponto de entrada para manipular a GetDados atrav�s da tecla F11      �
//� Legado SIGALOJA -  LJ920F11											 �
//������������������������������������������������������������������������
If FindFunction("U_MT920F11")
	SetKey(122,{ |x| U_MT920F11( @oGetDados ) } )// F11
Endif

SetKey(VK_F4,{||a920NfOri()})

//������������������������������������������������������������������������
//� Ponto de entrada para manipular as vari�veis de mem�ria do cabe�alho �
//� Legado SIGALOJA -  LJ920PN											 �
//������������������������������������������������������������������������
If ExistBlock("MT920PN")
   If !EXECBLOCK("MT920PN",.F.,.F.,)
      DbSelectArea(cAlias)
      DbSetOrder(1)
      Return
   Endif   
Endif

c920SClie := If(cTipo$"DB",OemToAnsi(STR0035),OemToAnsi(STR0011)) //"Fornecedor"###"Cliente"
dDtdigit  := IIf(!Empty(SF2->F2_DTDIGIT),SF2->F2_DTDIGIT,SF2->F2_EMISSAO)
//�������������������������������������������������Ŀ
//�Verifica valores da Nota Fiscal Eletronica no SF2�
//���������������������������������������������������
If cPaisLoc == "BRA"
	If l920Inclui
		aNFEletr := {CriaVar("F2_NFELETR"),CriaVar("F2_CODNFE"),CriaVar("F2_EMINFE"),CriaVar("F2_HORNFE"),CriaVar("F2_CREDNFE")}
		aDANFE := {CriaVar("F2_CHVNFE")}
	Else 
		aNFEletr := {SF2->F2_NFELETR,SF2->F2_CODNFE,SF2->F2_EMINFE,SF2->F2_HORNFE,SF2->F2_CREDNFE}
		aDANFE := {SF2->F2_CHVNFE}
	Endif
Endif

aAdd(aGetCpo,"D2_VLIMPOR")

If !l920Inclui
	lLote := (SF2->F2_LOTE == "S")
	If l920Deleta
		If !FisChkExc(SD2->D2_SERIE,SD2->D2_DOC,SD2->D2_CLIENTE,SD2->D2_LOJA)
			RestArea(aAreaSE1)
			RestArea(aArea)
			Return(.T.)
		Endif
		If SD2->D2_ORIGLAN != "LF"
			HELP("  ",1,"NAOLIV")
			RestArea(aAreaSE1)
			RestArea(aArea)
			Return .T.
		EndIf
		If AllTrim(c920Especi) == "NFFA" .And. cPaisLoc == "BRA"
			dbSelectArea("CD4")
			CD4->(dbSetOrder(1))
			cChave := xFilial("CD4")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE
			//Avisa para excluir complemento de agua
			If CD4->(dbSeek(cChave))
				MsgAlert(STR0097)
				RestArea(aAreaSE1)
				RestArea(aArea)
				Return .T.
			EndIf
		EndIf
		If AllTrim(c920Especi) == "SPED" .And. (SF2->F2_FIMP$"TS") .And. cPaisLoc == "BRA" ////verificacao apenas da especie como SPED e notas que foram transmitidas ou impressos o DANFE
			nHoras := SubtHoras(IIF(!Empty(SF2->F2_DAUTNFE),SF2->F2_DAUTNFE,dDtdigit),IIF(!Empty(SF2->F2_HAUTNFE),SF2->F2_HAUTNFE,SF2->F2_HORA), dDataBase, substr(Time(),1,2)+":"+substr(Time(),4,2) )
			If nHoras > nSpedExc
			
				Help(" ",1, "HELP",, "N�o foi possivel excluir a(s) nota(s), pois o prazo para o cancelamento da(s) NF-e � de " + Alltrim(STR(nSpedExc)) +" horas", 1, 0 )
				Return .T.
			EndIf
		EndIf

		If cPaisLoc == "BRA"
            dbSelectArea("CFF")
            
			lExistCFF := CFF->(FieldPos('CFF_TIPO')) > 0
			
			If lExistCFF
           		CFF->(dbSetOrder(4))
            	cChave := xFilial("CFF")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA+'S'+SD2->D2_TIPO
			else
				CFF->(dbSetOrder(1))
            	cChave := xFilial("CFF")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
			EndIf                
            
            If CFF->(dbSeek(cChave))
                Help(" ",1,"HELP",, STR0098, 1, 0 )//"Existem informa��es complementares, favor exclui-las antes de efetuar a exclus�o da nota"
                RestArea(aAreaSE1)
                RestArea(aArea) 
                Return .T.
            EndIf
        EndIf

	EndIf
	//��������������������������������������������������������������Ŀ
	//� Inicializa as variaveis utilizadas na exibicao da NF         �
	//����������������������������������������������������������������
	A920Client(SF2->F2_CLIENTE,SF2->F2_LOJA,@aInfClie,cTipo,l920Inclui)
	If Type("l920Auto") != "L" .or. !l920Auto
		If !lLote
			A920CabOk(@oCombo1,@ocNota,@od920Emis,@oc920GClie,@oc920Loj)
		Else
			A920CbLot(@oNFIni,@oNFFim,@od920Emis,@oc920GClie,@oc920Loj)
		EndIf
		c920Tipo	:= If(!Empty(cTipo).And.cTipo!="L",aCombo1[aScan(aAuxCombo1,cTipo)],Space(6))
	EndIf

	//�������������������������������������������������������������������������������������������������������������Ŀ
	//� Inclusao dos campos referente ao desconto para Zona Franca de Manaus apenas na visualizacao da nota fiscal  �
	//���������������������������������������������������������������������������������������������������������������
	Aadd( aGetCpo,"D2_DESCZFR")
	Aadd( aGetCpo,"D2_DESCZFP")
	Aadd( aGetCpo,"D2_DESCZFC")

	//Incentivo a producao e industrializacao do leite
	aAdd(aGetCpo,"D2_PRINCMG")
	aAdd(aGetCpo,"D2_VLINCMG")
EndIf

//�������������������������������������������������������Ŀ
//� Montagem do aHeader e aCols                           �
//���������������������������������������������������������
//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
//� Sintaxe da FillGetDados(nOpcx,cAlias,nOrder,cSeekKey,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry,bCriaVar,lUserFields) |
//��������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
FillGetDados(nOpcx,"SD2",1,/*cSeek*/,/*cWhile*/,/*uSeekFor*/,/*aNoFields*/,aGetCpo,/*lOnlyYes*/,/*cQuery*/,{|| MaCols920(l920Inclui,l920Altera,l920Deleta,@lContinua,@aPedidos,@aRecSE1,@aRecSE2,@aRecSF3,@a920Var,@aTitles) },l920Inclui,/*aHeaderAux*/,/*aColsAux*/,/*bAfterCols*/,/*bbeforeCols*/,/*bAfterHeader*/,/*cAliasQry*/,/*bCriaVar*/,.T.)

//��������������������������Ŀ
//�Carrega os dados do rateio�
//����������������������������
A920FRat(@aHeadAGH,@aColsAGH)


//����������������������������������������������������Ŀ
//�Se for processo de rotina automatica, nao monta tela�
//������������������������������������������������������
If Type("l920Auto") != "L" .or. !l920Auto
	aSizeAut := MsAdvSize(,.F.,345)
	aObjects := {}
	AAdd( aObjects, { 0,    41, .T., .F. } )
	AAdd( aObjects, { 100, 100, .T., .T. } )
	AAdd( aObjects, { 0,    75, .T., .F. } )

	aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }

	aPosObj := MsObjSize( aInfo, aObjects )

	If cPaisLoc == "BRA"
		aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
			{{8,23,78,128,163,200,250,270},;
			{8,32,95,130,170,204,260},;
			{7,32,68,95,135,165,227,250},;
			{8,32,75,200,250},;
			{5,70,160,205,295},;
			{6,34,200,215},;
			{6,34,106,139},;
			{6,34,245,268,220},;
			{5,50,150,190},;
			{277,130,190,293,205}})
	Else
		aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],310,;
			{Iif(cPaisLoc<>"PTG",{6,26,78,112,125,183,205,276,290},{6,26,78,102,115,157,177,226,240,258,286}),;
			Iif(cPaisLoc<>"PTG",{6,38,71,91,140,160,201,220,273,284},{6,36,86,106,140,160,201,220,273,284}),;
			{7,32,68,95,135,165,227,250},;
			{8,32,75,200,290},;
			Iif(cPaisLoc<>"PTG",{5,70,160,205,295},{5,50,120,140,200,245,295}),;
			{6,34,200,215},;
			{6,34,106,139},;
			{6,34,245,268,220},;
			Iif(cPaisLoc<>"PTG",{5,50,150,190},{5,50,115,140,200,245,295}),;
			{277,130,190,293,205}})
	Endif
	If !lLote
		//����������������������������������������������������Ŀ
		//� Define os botoes que serao exibidos ne enchoicebar �
		//������������������������������������������������������
		xButton := If( Empty(aPedidos),If( Empty( aUsButtons ) .Or. ValType( aUsButtons )<> "A", Nil, aUsButtons ), aButton )		

		If l920Visual .And. !l920Deleta //.And. !lPyme   <<== Inibido Serie 3 tem banco do conhecimento

			//����������������������������������������������������Ŀ
			//� Adiciona chamada ao banco de conhecimento          �
			//������������������������������������������������������
			If ValType( xButton ) <> "A"
				xButton := {}
			EndIf
			AAdd(xButton,{ "CLIPS", {|| A920Conhec() }, STR0073, STR0074 } ) // "Banco de Conhecimento", "Conhecim."

		EndIf

		DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro Of oMainWnd PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

		If cPaisloc == "BRA"
			@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] LABEL '' OF oDlg PIXEL

			nLinSay	:=	aPosObj[1][1]+6 

			@ nLinSay  ,aPosget[1,1] SAY OemToAnsi(STR0012) Of oDlg PIXEL SIZE 26 ,9 //'Tipo'
			@ nLinSay-2,aPosget[1,2]  MSCOMBOBOX oCombo1 	VAR 	c920Tipo ITEMS aCombo1 SIZE 50 ,90 ;
													WHEN 	VisualSX3('F1_TIPO').and. !l920Visual ;
													VALID 	A920Combo(@cTipo,aCombo1,c920Tipo,aAuxCombo1).And.;
													A920Tipo(cTipo,@oc920SClie,@c920SClie,@oc920GClie,@c920Client,@c920Loja,@oc920Loj) ;
													OF oDlg PIXEL

			@ nLinSay  ,aPosget[1,3]	SAY OemToAnsi(STR0049) Of oDlg PIXEL SIZE 52 ,9 //'Formulario Proprio'
			@ nLinSay-2,aPosget[1,4] MSCOMBOBOX oCombo2 	VAR cCombo2 ITEMS aCombo2 SIZE 25 ,50 ;
													WHEN .F. OF oDlg PIXEL

			@ nLinSay  ,aPosget[1,5] SAY OemToAnsi(STR0013) Of oDlg PIXEL SIZE 45 ,9 //'Nota Fiscal'
			@ nLinSay-2,aPosget[1,6] MSGET ocNota 	VAR c920Nota Picture PesqPict('SF2','F2_DOC') ;
												When VisualSX3('F2_DOC') .and. !l920Visual .And. !lGeraNum ;
												Valid  A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) .And. A920VldNum(c920Nota);
												OF oDlg PIXEL SIZE IIF(TamSX3("F2_DOC")[1] <= 9 ,34,48) ,9

			@ nLinSay  ,aPosget[1,7] SAY OemToAnsi(STR0014) Of oDlg PIXEL SIZE 23 ,9 //'Serie'
			@ nLinSay-2,aPosget[1,8] MSGET ocSerie 	VAR c920Serie  Picture PesqPict('SF2','F2_SERIE') ;
												When VisualSX3('F2_SERIE').and. !l920Visual .And. !lGeraNum ;
												Valid A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) OF oDlg PIXEL SIZE 18 ,9

			nLinSay	+=	20

			@ nLinSay  ,aPosget[2,1] SAY OemToAnsi(STR0015) Of oDlg PIXEL SIZE 16 ,9 //'Data'
			@ nLinSay-2,aPosget[2,2] MSGET od920Emis VAR d920Emis Picture PesqPict('SF2','F2_EMISSAO') ;
												When VisualSX3('F2_EMISSAO').and. !l920Visual ;
												Valid  A920Emissao(d920Emis) .And. CheckSX3('F2_EMISSAO')  ;
												OF oDlg PIXEL SIZE 49 ,9

			@ nLinSay  ,aPosget[2,3] SAY oc920SClie VAR c920SClie Of oDlg PIXEL SIZE 43 ,9  //Cliente
			@ nLinSay-2,aPosget[2,4] MSGET oc920GClie 	VAR c920Client  Picture PesqPict('SF2','F2_CLIENTE') ;
													F3 CpoRetF3('F2_CLIENTE');
													When VisualSX3('F2_CLIENTE').and. !l920Visual ;
													Valid  A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) .And.;
															CheckSX3('F2_CLIENTE',c920Client);
															.And. A920VFold("NF_CODCLIFOR",c920Client);
													OF oDlg PIXEL SIZE 41 ,9

			@ nLinSay-2,aPosget[2,5] MSGET oc920Loj 	VAR c920Loja  Picture PesqPict('SF2','F2_LOJA') ;
												F3 CpoRetF3('F2_LOJA');	//Filial
												When VisualSX3('F2_LOJA').and. !l920Visual ;
												Valid CheckSX3('F2_LOJA',c920Loja).and. A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) ;
												.And.A920VFold("NF_LOJA",c920Loja) ;
												OF oDlg PIXEL SIZE 15 ,9

			@ nLinSay  ,aPosget[2,6] SAY OemToAnsi(STR0016) Of oDlg PIXEL SIZE 63 ,9 //'Tipo de Documento'
			@ nLinSay-2,aPosget[2,7] MSGET c920Especi  Picture PesqPict('SF2','F2_ESPECIE') ;
													F3 CpoRetF3('F2_ESPECIE');
													When VisualSX3('F2_ESPECIE').and. !l920Visual ;
													Valid CheckSX3('F2_ESPECIE',c920Especi) .And. MaFisRef("NF_ESPECIE","MT100",c920Especi) ;
													OF oDlg PIXEL SIZE 30 ,9

			oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,'A920LinOk','A920TudOk','+D2_ITEM', (!l920Visual) ,,,,9999,'A920FieldOk',,,'A920Del')
			oGetDados:oBrowse:bGotFocus	:= {||A920CabOk(@oCombo1,@ocNota,@od920Emis,@oc920GClie,@oc920Loj) }
		Else

			If cPaisLoc <> "PTG"

				nLinSay	:=	aPosObj[1][1]+6

				@ nLinSay,aPosget[1,1] SAY oc920SClie VAR c920SClie Of oDlg PIXEL SIZE 43 ,9  //Cliente
				@ nLinSay,aPosget[1,2] MSGET oc920GClie VAR c920Client  Picture PesqPict('SF2','F2_CLIENTE') ;
													F3 CpoRetF3('F2_CLIENTE');
													When VisualSX3('F2_CLIENTE').AND. !l920Visual ;
													Valid  A920Client(c920Client,c920Loja,@aInfClie,cTipo).AND.CheckSX3('F2_CLIENTE',c920Client,l920Inclui);
															.AND.A920VFold("NF_CODCLIFOR",c920Client) ;
													OF oDlg PIXEL SIZE 80 ,9

				@ nLinSay,aPosget[1,3] MSGET oc920Loj 	VAR c920Loja  Picture PesqPict('SF2','F2_LOJA') ;
													F3 CpoRetF3('F2_LOJA');	//Filial
													When VisualSX3('F2_LOJA').AND. !l920Visual ;
													Valid CheckSX3('F2_LOJA',c920Loja).AND. A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) ;
															.AND.A920VFold("NF_LOJA",c920Loja) ;
													OF oDlg PIXEL SIZE 15 ,9	

				@ nLinSay,aPosget[1,4] SAY  (STR0015) Of oDlg PIXEL SIZE 16 ,9 //'Data'
				@ nLinSay,aPosget[1,5] MSGET od920Emis 	VAR d920Emis Picture PesqPict('SF2','F2_EMISSAO') ;
													When VisualSX3('F2_EMISSAO').AND. !l920Visual ;
													Valid  A920Emissao(d920Emis) .AND. CheckSX3('F2_EMISSAO') ;
													OF oDlg PIXEL SIZE 49 ,9

				@ nLinSay,aPosget[1,6] SAY  (STR0013) Of oDlg PIXEL SIZE 45 ,9 	//'Factura'
				@ nLinSay,aPosget[1,7] MSGET ocNota VAR c920Nota Picture PesqPict('SF2','F2_DOC') ;
												When VisualSX3('F2_DOC') .AND. !l920Visual ;
												Valid  A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui);
												OF oDlg PIXEL SIZE 65 ,9

				@ nLinSay,aPosget[1,8] SAY  (STR0014) Of oDlg PIXEL SIZE 23 ,9 //'Serie'
				@ nLinSay,aPosget[1,9] MSGET ocSerie 	VAR c920Serie  Picture PesqPict('SF2','F2_SERIE') ;
													When VisualSX3('F2_SERIE').AND. !l920Visual ;
													Valid A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) OF oDlg PIXEL SIZE 18 ,9

				nLinSay	+=	20

				@ nLinSay,aPosget[2,1] SAY  (STR0016) Of oDlg PIXEL SIZE 63 ,9 //'Tipo de Documento'
				@ nLinSay,aPosget[2,2] MSGET c920Especi Picture PesqPict('SF2','F2_ESPECIE') ;
													F3 CpoRetF3('F2_ESPECIE');
													When VisualSX3('F2_ESPECIE').AND. !l920Visual ;
													Valid CheckSX3('F2_ESPECIE',c920Especi) ;
													OF oDlg PIXEL SIZE 10,9

				@ nLinSay,aPosget[2,3] SAY  (STR0058) Of oDlg PIXEL SIZE 63 ,9 //'Modalidad'
				@ nLinSay,aPosget[2,4] MSGET c920Modal Picture PesqPict('SF2','F2_NATUREZ') ;
													When .F. ;
													OF oDlg PIXEL SIZE 30 ,9

				@ nLinSay,aPosget[2,5] SAY  (STR0068) Of oDlg PIXEL SIZE 63 ,9 //'vendedor'
				@ nLinSay,aPosget[2,6] MSGET c920Vend Picture PesqPict('SF2','F2_VEND1') ;
													When .F. ;
													OF oDlg PIXEL SIZE 35 ,9

				@ nLinSay,aPosget[2,7] SAY  (STR0059) Of oDlg PIXEL SIZE 63 ,9 //'Moneda'
				@ nLinSay,aPosget[2,8] MSGET c920Moeda Picture "99" ;
													When .F. ;
													OF oDlg PIXEL SIZE 50 ,9

				@ nLinSay,aPosget[2,9] SAY  (STR0069) Of oDlg PIXEL SIZE 63 ,9 //'Tasa'
				@ nLinSay,aPosget[2,10] MSGET c920Taxa Picture PesqPict('SF2','F2_TXMOEDA') ;
													When .F. ;
													OF oDlg PIXEL SIZE 35,9			
				
			Else

				nLinSay	:=	aPosObj[1][1]+6 

				@ nLinSay,aPosget[1,1] SAY oc920SClie VAR c920SClie Of oDlg PIXEL SIZE 43 ,9  //Cliente
				@ nLinSay,aPosget[1,2] MSGET oc920GClie VAR c920Client  Picture PesqPict('SF2','F2_CLIENTE') ;
													F3 CpoRetF3('F2_CLIENTE');
													When VisualSX3('F2_CLIENTE').and. !l920Visual ;
													Valid  A920Client(c920Client,c920Loja,@aInfClie,cTipo).And.CheckSX3('F2_CLIENTE',c920Client,l920Inclui);
															.And.A920VFold("NF_CODCLIFOR",c920Client) ;
													OF oDlg PIXEL SIZE 80 ,9

				@ nLinSay,aPosget[1,3] MSGET oc920Loj 	VAR c920Loja  Picture PesqPict('SF2','F2_LOJA') ;
													F3 CpoRetF3('F2_LOJA');	//Filial
													When VisualSX3('F2_LOJA').and. !l920Visual ;
													Valid CheckSX3('F2_LOJA',c920Loja).and. A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) ;
															.And.A920VFold("NF_LOJA",c920Loja) ;
													OF oDlg PIXEL SIZE 15 ,9	

				@ nLinSay,aPosget[1,4] SAY OemToAnsi(STR0015) Of oDlg PIXEL SIZE 16 ,9 //'Data'
				@ nLinSay,aPosget[1,5] MSGET od920Emis 	VAR d920Emis Picture PesqPict('SF2','F2_EMISSAO') ;
													When VisualSX3('F2_EMISSAO').and. !l920Visual ;
													Valid  A920Emissao(d920Emis) .And. CheckSX3('F2_EMISSAO') ;
													OF oDlg PIXEL SIZE 49 ,9				

				@ nLinSay,aPosget[1,6] SAY OemToAnsi(STR0013) Of oDlg PIXEL SIZE 45 ,9 	//'Factura'
				@ nLinSay,aPosget[1,7] MSGET ocNota VAR c920Nota Picture PesqPict('SF2','F2_DOC') ;
												When VisualSX3('F2_DOC') .and. !l920Visual ;
												Valid  A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui);
												OF oDlg PIXEL SIZE 65 ,9

				@ nLinSay,aPosget[1,8] SAY OemToAnsi(STR0014) Of oDlg PIXEL SIZE 23 ,9 //'Serie'
				@ nLinSay,aPosget[1,9] MSGET ocSerie 	VAR c920Serie  Picture PesqPict('SF2','F2_SERIE') ;
													When VisualSX3('F2_SERIE').and. !l920Visual ;
													Valid A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) OF oDlg PIXEL SIZE 18 ,9

				@ nLinSay,aPosget[1,10] SAY OemToAnsi(STR0016) Of oDlg PIXEL SIZE 63 ,9 //'Tipo de Documento'
				@ nLinSay,aPosget[1,11] MSGET c920Especi Picture PesqPict('SF2','F2_ESPECIE') ;
													F3 CpoRetF3('F2_ESPECIE');
													When VisualSX3('F2_ESPECIE').and. !l920Visual ;
													Valid CheckSX3('F2_ESPECIE',c920Especi) ;
													OF oDlg PIXEL SIZE 10,9

				nLinSay	+=	20

				If cPaisLoc $ "ANG|EQU|HAI|PTG"
                    @ nLinSay,aPosget[2,1] SAY OemToAnsi(STR0088) Of oDlg PIXEL SIZE 63 ,9 //'Decl. Export.'
                    @ nLinSay,aPosget[2,2] MSGET c920DecExp Picture PesqPict('SF2','F2_DECLEXP') ;
                                                    When .F. ;
                                                    OF oDlg PIXEL SIZE 65 ,9        
              EndIf   	

				@ nLinSay,aPosget[2,3] SAY OemToAnsi(STR0058) Of oDlg PIXEL SIZE 63 ,9 //'Modalidad'
				@ nLinSay,aPosget[2,4] MSGET c920Modal Picture PesqPict('SF2','F2_NATUREZ') ;
													When .F. ;
													OF oDlg PIXEL SIZE 30 ,9			

				@ nLinSay,aPosget[2,5] SAY OemToAnsi(STR0068) Of oDlg PIXEL SIZE 63 ,9 //'vendedor'
				@ nLinSay,aPosget[2,6] MSGET c920Vend Picture PesqPict('SF2','F2_VEND1') ;
													When .F. ;
													OF oDlg PIXEL SIZE 35 ,9

				@ nLinSay,aPosget[2,7] SAY OemToAnsi(STR0059) Of oDlg PIXEL SIZE 63 ,9 //'Moneda'
				@ nLinSay,aPosget[2,8] MSGET c920Moeda Picture "99" ;
													When .F. ;
													OF oDlg PIXEL SIZE 50 ,9

				@ nLinSay,aPosget[2,9] SAY OemToAnsi(STR0069) Of oDlg PIXEL SIZE 63 ,9 //'Tasa'
				@ nLinSay,aPosget[2,10] MSGET c920Taxa Picture PesqPict('SF2','F2_TXMOEDA') ;
													When .F. ;
													OF oDlg PIXEL SIZE 35,9
			Endif

			oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,'A920LinOk','A920TudOk','+D2_ITEM',.T.,,,,300,'A920FieldOk',,,'A920Del')
			oGetDados:oBrowse:bGotFocus	:= {||A920CabOk(@oCombo1,@ocNota,@od920Emis,@oc920GClie,@oc920Loj) }

		Endif
	else
		DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE OemToAnsi(STR0040) Of oMainWnd PIXEL //"Nota de Sa�da em Lote"

		@ aPosObj[1][1],aPosObj[1][2] TO aPosObj[1][3],aPosObj[1][4] LABEL '' OF oDlg PIXEL

		nLinSay	:=	aPosObj[1][1]+6

		@ nLinSay,aPosGet[3,1] SAY OemToAnsi(STR0014)  OF oDlg PIXEL SIZE 23, 9//"S�rie"
		@ nLinSay,aPosGet[3,2] MSGET ocSerie VAR c920Serie PICTURE PesqPict('SF2','F2_SERIE');
			When VisualSX3('F2_SERIE').and. !l920Visual Valid CheckSX3('F2_SERIE');
			OF oDlg PIXEL 	SIZE 18, 9

		@ nLinSay,aPosGet[3,3] SAY OemToAnsi(STR0038)   SIZE 29, 7 OF oDlg PIXEL //"NF.Inicial"
		@ nLinSay,aPosGet[3,4] MSGET oNFIni VAR c920NFIni Picture PesqPict('SF2','F2_DOC');
			When !l920Visual VALID NaoVazio().and.A920VlNfLote(c920Serie,c920NFIni,,c920Especi,d920Emis);
			OF oDlg PIXEL SIZE 25, 10

		@ nLinSay,aPosGet[3,5] SAY OemToAnsi(STR0039)     SIZE 25, 9 OF oDlg PIXEL //"NF.Final"
		@ nLinSay,aPosGet[3,6] MSGET oNFFim VAR c920NFFim  Picture PesqPict('SF2','F2_DOC') ;
			When !l920Visual VALID (Val(c920NFFim)>=Val(c920NFIni).AND.A920VlNfLote(c920Serie,c920NFIni,c920NFFim,c920Especi,d920Emis));
			OF oDlg PIXEL 	SIZE 25, 10

		@ nLinSay,aPosGet[3,7] SAY OemToAnsi(STR0037) OF oDlg PIXEL  SIZE 25, 7  //"Emiss�o"
		@ nLinSay,aPosGet[3,8] MSGET od920Emis VAR d920Emis	Picture PesqPict('SF2','F2_EMISSAO') ;
			When VisualSX3('F2_EMISSAO').and. !l920Visual VALID A920Emissao(d920Emis) .And. CheckSX3('F2_EMISSAO')  ;
			OF oDlg PIXEL	SIZE 43, 10

		nLinSay	+=	20

		@ nLinSay,aPosGet[4,1] SAY OemToAnsi(STR0011)  OF oDlg PIXEL SIZE 20, 7  //"Cliente"
		@ nLinSay,aPosGet[4,2] MSGET oc920GClie VAR c920Client  Picture PesqPict('SF2','F2_CLIENTE') F3 CpoRetF3('F2_CLIENTE');
			When VisualSX3('F2_CLIENTE').and. !l920Visual Valid  A920Client(c920Client,c920Loja,@aInfClie,cTipo).And.CheckSX3('F2_CLIENTE',c920Client,l920Inclui);
			OF oDlg PIXEL	SIZE 30, 10

		@ nLinSay,aPosGet[4,3] MSGET oc920Loj VAR c920Loja  Picture PesqPict('SF2','F2_LOJA') F3 CpoRetF3('F2_LOJA');
			When VisualSX3('F2_LOJA').and. !l920Visual Valid CheckSX3('F2_LOJA',c920Loja).and. A920Client(c920Client,c920Loja,@aInfClie,cTipo,l920Inclui) ;
			OF oDlg PIXEL	SIZE 14, 10

		@ nLinSay,aPosGet[4,4] SAY OemtoAnsi(STR0016) OF oDlg PIXEL SIZE 50,7  //"Tipo de Documento"
		@ nLinSay,aPosGet[4,5] MSGET c920Especi  Picture PesqPict('SF2','F2_ESPECIE') F3 CpoRetF3('F2_ESPECIE');
			When VisualSX3('F2_ESPECIE').and. !l920Visual Valid CheckSX3('F2_ESPECIE',c920Especi) ;
			OF oDlg PIXEL SIZE 17,10

		oGetDados := MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,'A920LinOk','A920TudOk','+D2_ITEM',.T.,,,,9999,'A920FieldOk',,,'A920Del')
		oGetDados:oBrowse:bGotFocus	:= {||A920CbLot(@oNFIni,@oNFFim,@od920Emis,@oc920GClie,@oc920Loj)	 }
	EndIf
	
	//Adiciona bloco de c�digo para atualizar aba de tributos gen�ricos por item na mudan�a de linha do item
	IF lTrbGen
		oGetDados:oBrowse:bChange := {|| Eval(bTgRefresh)}	
	EndIF
	//����������������������������������������������������������������������Ŀ
	//� Nota fiscal em lote nao gera NF-e. Sera sempre um RPS para uma NF-e. �
	//�Na NF em lote, seriam varios RPS para uma mesma NF-e                  �
	//������������������������������������������������������������������������
	If cPaisLoc == "BRA" .And. !lLote
		aAdd(aTitles,STR0082)
		nNFe 	:= 	Len(aTitles)

		aAdd(aTitles,STR0084)	//"Lan�amentos da Apura��o de ICMS"
		nLancAp	:=	Len(aTitles)

		aAdd(aTitles,STR0094)
		nDANFE 	:= 	Len(aTitles)
	Endif

	IF lTrbGen
		aAdd(aTitles,STR0101) //"Tributos Gen�ricos - Por Item"
		nTrbGen	:= Len(aTitles)
	EndIF	

	oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,aPages,oDlg,,,,.T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]*0.29,)
	
	If lTrbGen
		oFolder:bSetOption := {|nDst| Iif(nDst == nTrbGen, Eval(bTgRefresh),.T.)}
	EndIF

	For ni := 1 to Len(oFolder:aDialogs)
		DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[ni]
	Next

	//���������������������������������������������Ŀ
	//� Tela de Totalizadores.  					�
	//�����������������������������������������������
	oFolder:aDialogs[1]:oFont := oDlg:oFont

	If cPaisLoc <> "PTG"
		@ 06,aPosGet[5,1]   SAY OemToAnsi(STR0017) Of oFolder:aDialogs[1] PIXEL SIZE 90,9 // "Valor da Mercadoria (Liquido)"
		@ 05,aPosGet[5,2]   MSGET aObj[19] VAR a920Var[VALMERC] Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 06,aPosGet[5,3] SAY OemToAnsi(STR0018) Of oFolder:aDialogs[1] PIXEL SIZE 49 ,9 // "Descontos"
		@ 05,aPosGet[5,4] MSGET aObj[2] VAR a920Var[VALDESC]  Picture PesqPict('SD2','D2_DESCON') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 20,aPosGet[5,1]   SAY OemToAnsi(STR0076) Of oFolder:aDialogs[1] PIXEL SIZE 90 ,9 // "Valor da Mercadoria (Bruto)"
		@ 19,aPosGet[5,2]   MSGET aObj[1] VAR a920Var[VALMERCB] Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 34,aPosGet[5,1]  SAY OemToAnsi(STR0019) Of oFolder:aDialogs[1] PIXEL SIZE 45 ,9 // "Valor do Frete"
		@ 33,aPosGet[5,2]  MSGET aObj[3] VAR a920Var[FRETE]  Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 20,aPosGet[5,3]  SAY OemToAnsi(STR0020) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9 // "Valor do Seguro"
		@ 19,aPosGet[5,4]  MSGET aObj[4] VAR a920Var[SEGURO]  Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 34,aPosGet[5,3]  SAY OemToAnsi(STR0021) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9  // "Gastos"
		@ 33,aPosGet[5,4]  MSGET aObj[5] VAR a920Var[VALDESP]  Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F.  SIZE 80 ,9

		@ 52,aPosGet[5,3] SAY OemToAnsi(STR0022) Of oFolder:aDialogs[1] PIXEL SIZE 58 ,9 // "Total da Factura"
		@ 50,aPosGet[5,4] MSGET aObj[6] VAR a920Var[TOTPED]  Picture PesqPict('SF2','F2_VALBRUT') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 46,03 TO 48 ,aPosGet[5,5] LABEL '' OF oFolder:aDialogs[1] PIXEL
	Else
		@ 06,aPosGet[5,1]   SAY OemToAnsi(STR0017) Of oFolder:aDialogs[1] PIXEL SIZE 90,9 // "Valor da Mercadoria (Liquido)"
		@ 05,aPosGet[5,2]   MSGET aObj[19] VAR a920Var[VALMERC] Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 06,aPosGet[5,3] SAY OemToAnsi(STR0018) Of oFolder:aDialogs[1] PIXEL SIZE 49 ,9 // "Descontos"
		@ 05,aPosGet[5,4] MSGET aObj[2] VAR a920Var[VALDESC]  Picture PesqPict('SD2','D2_DESCON') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 06,aPosGet[5,5]   SAY OemToAnsi(STR0076) Of oFolder:aDialogs[1] PIXEL SIZE 90 ,9 // "Valor da Mercadoria (Bruto)"
		@ 05,aPosGet[5,6]   MSGET aObj[1] VAR a920Var[VALMERCB] Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 20,aPosGet[5,1]  SAY OemToAnsi(STR0019) Of oFolder:aDialogs[1] PIXEL SIZE 45 ,9 // "Valor do Frete"
		@ 19,aPosGet[5,2]  MSGET aObj[3] VAR a920Var[FRETE]  Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 20,aPosGet[5,3]  SAY OemToAnsi(STR0020) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9 // "Valor do Seguro"
		@ 19,aPosGet[5,4]  MSGET aObj[4] VAR a920Var[SEGURO]  Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 20,aPosGet[5,5]  SAY OemToAnsi(STR0021) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9  // "Gastos"
		@ 19,aPosGet[5,6]  MSGET aObj[5] VAR a920Var[VALDESP]  Picture PesqPict('SD2','D2_TOTAL') OF oFolder:aDialogs[1] PIXEL When .F.  SIZE 80 ,9

		@ 34,aPosGet[5,1]  SAY OemToAnsi(STR0086) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9  // "Desp. nao Tib."
		@ 33,aPosGet[5,2]  MSGET aObj[19] VAR a920Var[NTRIB]  Picture PesqPict('SD2','D2_DESNTRB') OF oFolder:aDialogs[1] PIXEL When .F.  SIZE 80 ,9

		@ 34,aPosGet[5,3]  SAY OemToAnsi(STR0087) Of oFolder:aDialogs[1] PIXEL SIZE 50 ,9  // "Tara"
		@ 33,aPosGet[5,4]  MSGET aObj[20] VAR a920Var[TARA]  Picture PesqPict('SD2','D2_TARA') OF oFolder:aDialogs[1] PIXEL When .F.  SIZE 80 ,9

		@ 51,aPosGet[5,5] SAY OemToAnsi(STR0022) Of oFolder:aDialogs[1] PIXEL SIZE 58 ,9 // "Total da Factura"
		@ 49,aPosGet[5,6] MSGET aObj[6] VAR a920Var[TOTPED]  Picture PesqPict('SF2','F2_VALBRUT') OF oFolder:aDialogs[1] PIXEL When .F. SIZE 80 ,9

		@ 46,03 TO 47 ,aPosGet[5,7] LABEL '' OF oFolder:aDialogs[1] PIXEL
	Endif

	//���������������������������������������������Ŀ
	//� Informacoes do Cliente  			        �
	//�����������������������������������������������

	oFolder:aDialogs[2]:oFont := oDlg:oFont
	@ 6  ,aPosGet[6,1] SAY OemToAnsi(STR0023) Of oFolder:aDialogs[2] PIXEL SIZE 37 ,9 // "Nome"
	@ 5  ,aPosGet[6,2] MSGET aObj[7] VAR aInfClie[1] Picture PesqPict('SA1','A1_NOME');
		When .F. OF oFolder:aDialogs[2] PIXEL SIZE 159,9
		iif(lLGPD,AnonimoLGPD(aObj[7],'A1_NOME'),.F.)

	@ 6  ,aPosGet[6,3] SAY OemToAnsi(STR0024) Of oFolder:aDialogs[2] PIXEL SIZE 23 ,9 // "Tel."
	@ 5  ,aPosGet[6,4] MSGET aObj[8] VAR aInfClie[2] Picture PesqPict('SA1','A1_TEL');
		When .F. OF oFolder:aDialogs[2] PIXEL SIZE 74 ,9
		iif(lLGPD,AnonimoLGPD(aObj[8],'A1_TEL'),.F.)

	@ 43 ,aPosGet[7,1] SAY OemToAnsi(STR0025) Of oFolder:aDialogs[2] PIXEL SIZE 32 ,9 // "1a Compra"
	@ 42 ,aPosGet[7,2] MSGET aObj[9] VAR aInfClie[3] Picture PesqPict('SA1','A1_PRICOM') ;
		When .F. OF oFolder:aDialogs[2] PIXEL SIZE 56 ,9
		iif(lLGPD,AnonimoLGPD(aObj[9],'A1_PRICOM'),.F.)

	@ 43 ,aPosGet[7,3] SAY OemToAnsi(STR0026) Of oFolder:aDialogs[2] PIXEL SIZE 36 ,9 // "Ult. Compra"
	@ 42 ,aPosGet[7,4] MSGET aObj[10] VAR aInfClie[4] Picture PesqPict('SA1','A1_ULTCOM');
		When .F. OF oFolder:aDialogs[2] PIXEL SIZE 56 ,9
		iif(lLGPD,AnonimoLGPD(aObj[10],'A1_ULTCOM'),.F.)

	@ 24 ,aPosGet[8,1]  SAY OemToAnsi(STR0027) Of oFolder:aDialogs[2] PIXEL SIZE 49 ,9 // "Endereco"
	@ 23 ,aPosGet[8,2]  MSGET aObj[11] VAR aInfClie[5]  Picture PesqPict('SA1','A1_END');
		When .F. OF oFolder:aDialogs[2] PIXEL SIZE 205,9
		iif(lLGPD,AnonimoLGPD(aObj[11],'A1_END'),.F.)

	@ 24 ,aPosGet[8,3] SAY OemToAnsi(STR0028) Of oFolder:aDialogs[2] PIXEL SIZE 32 ,9 // "Estado"
	@ 23 ,aPosGet[8,4] MSGET aObj[12] VAR aInfClie[6]  Picture PesqPict('SA1','A1_EST');
		When .F. OF oFolder:aDialogs[2] PIXEL SIZE 21 ,9
		iif(lLGPD,AnonimoLGPD(aObj[12],'A1_EST'),.F.)		

	@42 ,aPosGet[8,5] BUTTON OemToAnsi(STR0029) SIZE 40 ,11  FONT oDlg:oFont ACTION A103ToFC030("S")  OF oFolder:aDialogs[2] PIXEL // "Mais Inf."

	//���������������������������������������������Ŀ
	//� Frete/Despesas/Descontos							�
	//�����������������������������������������������

	oFolder:aDialogs[3]:oFont := oDlg:oFont

	If cPaisLoc <> "PTG"

		@ 9 ,aPosGet[9,1] SAY OemToAnsi(STR0030) Of oFolder:aDialogs[3] PIXEL SIZE 58 ,12 //"Valor do Desconto"
		@ 8 ,aPosGet[9,2] MSGET aObj[13] VAR a920Var[VALDESC]  Picture PesqPict('SD2','D2_DESCON') OF oFolder:aDialogs[3] PIXEL When !l920Visual  VALID a920Var[VALDESC]>= 0 .and. A920VFold("NF_DESCONTO",a920Var[VALDESC]) SIZE 80 ,9

		@ 9,aPosGet[9,3] SAY OemToAnsi(STR0031) Of oFolder:aDialogs[3] PIXEL SIZE 58 ,9 //"Valor do Frete"
		@ 8,aPosGet[9,4] MSGET aObj[14] VAR a920Var[FRETE]  Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID a920Var[FRETE]>= 0 .and. A920VFold("NF_FRETE",a920Var[FRETE]) SIZE 80,9

		@ 26 ,aPosGet[9,1] SAY OemToAnsi(STR0032) Of oFolder:aDialogs[3] PIXEL SIZE 42 ,9 // "Despesas"
		@ 25 ,aPosGet[9,2] MSGET aObj[15] VAR a920Var[VALDESP] Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID a920Var[VALDESP]>= 0 .and. A920VFold("NF_DESPESA",a920Var[VALDESP]) SIZE 80,9

		@ 26 ,aPosGet[9,3] SAY OemToAnsi(STR0033) Of oFolder:aDialogs[3] PIXEL SIZE 35 ,9 // "Seguro"
		@ 25 ,aPosGet[9,4] MSGET aObj[16] VAR a920Var[SEGURO]  Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID a920Var[SEGURO]>= 0 .and. A920VFold("NF_SEGURO",a920Var[SEGURO]) SIZE 80,9

		@ 38 ,05  TO 40 ,aPosGet[10,1] LABEL '' OF oFolder:aDialogs[3] PIXEL

		@ 48 ,aPosGet[10,2] SAY OemToAnsi(STR0034) Of oFolder:aDialogs[3] PIXEL SIZE 90 ,9 // "Total ( Frete+Despesas)"
		@ 47 ,aPosGet[10,3] MSGET a920Var[TOTF3]  Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN .F. SIZE 80,9
	Else
		@ 9 ,aPosGet[9,1] SAY OemToAnsi(STR0030) Of oFolder:aDialogs[3] PIXEL SIZE 58 ,12 //"Valor do Desconto"
		@ 8 ,aPosGet[9,2] MSGET aObj[13] VAR a920Var[VALDESC]  Picture PesqPict('SD2','D2_DESCON') OF oFolder:aDialogs[3] PIXEL When !l920Visual  VALID A920VFold("NF_DESCONTO",a920Var[VALDESC]) SIZE 80 ,9

		@ 9, aPosGet[9,3] SAY OemToAnsi(STR0031) Of oFolder:aDialogs[3] PIXEL SIZE 58 ,9 //"Valor do Frete"
		@ 8, aPosGet[9,4] MSGET aObj[14] VAR a920Var[FRETE]  Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID A920VFold("NF_FRETE",a920Var[FRETE]) SIZE 80,9

		@ 9 ,aPosGet[9,5] SAY OemToAnsi(STR0033) Of oFolder:aDialogs[3] PIXEL SIZE 35 ,9 // "Seguro"
		@ 8 ,aPosGet[9,6] MSGET aObj[16] VAR a920Var[SEGURO]  Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID A920VFold("NF_SEGURO",a920Var[SEGURO]) SIZE 80,9

		@ 26 ,aPosGet[9,1] SAY OemToAnsi(STR0032) Of oFolder:aDialogs[3] PIXEL SIZE 42 ,9 // "Despesas"
		@ 25 ,aPosGet[9,2] MSGET aObj[15] VAR a920Var[VALDESP] Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID A920VFold("NF_DESPESA",a920Var[VALDESP]) SIZE 80,9

		@ 26, aPosGet[9,3] SAY OemToAnsi(STR0086) Of oFolder:aDialogs[3] PIXEL SIZE 58 ,9 //"Desp. n�o Trib."
		@ 25, aPosGet[9,4] MSGET aObj[21] VAR a920Var[NTRIB]  Picture PesqPict('SC7','C7_DESNTRB') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID A920VFold("NF_DESNTRB",a920Var[NTRIB]) SIZE 80,9

		@ 26, aPosGet[9,5] SAY OemToAnsi(STR0087) Of oFolder:aDialogs[3] PIXEL SIZE 35 ,9 //"Tara"
		@ 25, aPosGet[9,6] MSGET aObj[22] VAR a920Var[TARA]  Picture PesqPict('SC7','C7_TARA') OF oFolder:aDialogs[3] PIXEL WHEN !l920Visual VALID A920VFold("NF_TARA",a920Var[TARA]) SIZE 80,9

		@ 38 ,05  TO 38 ,aPosGet[9,7] LABEL '' OF oFolder:aDialogs[3] PIXEL

		@ 48 ,aPosGet[9,5] SAY OemToAnsi(STR0034) Of oFolder:aDialogs[3] PIXEL SIZE 90 ,9 // "Total ( Frete+Despesas)"
		@ 47 ,aPosGet[9,6] MSGET a920Var[TOTF3]  Picture PesqPict('SC7','C7_FRETE') OF oFolder:aDialogs[3] PIXEL WHEN .F. SIZE 80,9
	Endif
	//���������������������Ŀ
	//� Impostos			�
	//�����������������������
	oFolder:aDialogs[4]:oFont := oDlg:oFont

	aObj[17] := MaFisRodape(1,oFolder:aDialogs[4],,{5,3, ( aPosObj[3,4]-aPosObj[3,2]-9 ),53},bListRefresh,l920Visual)

	oFolder:aDialogs[5]:oFont := oDlg:oFont

	aObj[18] := MaFisBrwLivro(oFolder:aDialogs[5],{5,3,( aPosObj[3,4]-aPosObj[3,2]-9 ),53},.T.,aRecSF3,l920Visual)

	If !Empty(aRecSE1) .Or. !Empty(aRecSE2)
		oFolder:aDialogs[6]:oFont := oDlg:oFont
		aAdd(aObj,Nil)
		aObj[19] := A920Financ(SF2->F2_COND,oFolder:aDialogs[6],aRecSE1,aRecSE2,( aPosObj[3,4]-aPosObj[3,2] - 95 ) )
	EndIf

	//����������������������Ŀ
	//�Nota Fiscal Eletronica�
	//������������������������
	If !lLote

		If cPaisLoc == "BRA"
			// Objeto Get, de acordo com a exibicao ou nao do folder financeiro
			aAdd(aObj,Nil)
			nObj := Len(aObj)

			oFolder:aDialogs[nNFe]:oFont := oDlg:oFont

			@ 9 ,aPosGet[9,1] SAY OemToAnsi(STR0077) Of oFolder:aDialogs[nNFe] PIXEL SIZE 48 ,12 //"N�mero"
			@ 8 ,aPosGet[9,2] MSGET aObj[nObj] VAR aNFEletr[01];
			Picture PesqPict('SF2','F2_NFELETR');
			OF oFolder:aDialogs[nNFe] PIXEL;
			When VisualSX3('F2_NFELETR') .And. !l920Visual;
			VALID CheckSX3("F2_NFELETR",aNFEletr[01]);
			SIZE 80 ,9
			aObj[nObj]:cSX1Hlp := "F2_NFELETR"

			@ 9 ,aPosGet[9,3] SAY OemToAnsi(STR0080) Of oFolder:aDialogs[nNFe] PIXEL SIZE 48 ,12 //"C�d. verifica��o"
			@ 8 ,aPosGet[9,4] MSGET aObj[nObj] VAR aNFEletr[02];
			Picture PesqPict('SF2','F2_CODNFE') OF;
			oFolder:aDialogs[nNFe] PIXEL;
			When VisualSX3('F2_CODNFE') .And. !l920Visual;
			VALID CheckSX3("F2_CODNFE",aNFEletr[02]);
			SIZE 80 ,9
			aObj[nObj]:cSX1Hlp := "F2_CODNFE"

			@ 26 ,aPosGet[9,1] SAY OemToAnsi(STR0078) Of oFolder:aDialogs[nNFe] PIXEL SIZE 48 ,12 //"Emiss�o"
			@ 25 ,aPosGet[9,2] MSGET aObj[nObj] VAR aNFEletr[03];
			Picture PesqPict('SF2','F2_EMINFE');
			OF oFolder:aDialogs[nNFe] PIXEL;
			When VisualSX3('F2_EMINFE') .And. !l920Visual;
			VALID A920NFe('EMINFE',aNFEletr) .And. CheckSX3("F2_EMINFE",aNFEletr[03]);
			SIZE 80 ,9
			aObj[nObj]:cSX1Hlp := "F2_EMINFE"

			@ 26 ,aPosGet[9,3] SAY OemToAnsi(STR0079) Of oFolder:aDialogs[nNFe] PIXEL SIZE 48 ,12 //"Hora da emiss�o"
			@ 25 ,aPosGet[9,4] MSGET aObj[nObj] VAR aNFEletr[04];
			Picture PesqPict('SF2','F2_HORNFE');
			OF oFolder:aDialogs[nNFe] PIXEL;
			When VisualSX3('F2_HORNFE') .And. !l920Visual;
			VALID CheckSX3("F2_HORNFE",aNFEletr[04]);
			SIZE 80 ,9
			aObj[nObj]:cSX1Hlp := "F2_HORNFE"

			@ 43 ,aPosGet[9,1] SAY OemToAnsi(STR0081) Of oFolder:aDialogs[nNFe] PIXEL SIZE 48 ,12 //"Valor Cr�dito"
			@ 42 ,aPosGet[9,2] MSGET aObj[nObj] VAR aNFEletr[05];
			Picture PesqPict('SF2','F2_CREDNFE');
			OF oFolder:aDialogs[nNFe] PIXEL;
			When VisualSX3('F2_CREDNFE') .And. !l920Visual;
			VALID A920NFe('CREDNFE',aNFEletr) .And. CheckSX3("F2_CREDNFE",aNFEletr[05]);
			SIZE 80 ,9
			aObj[nObj]:cSX1Hlp := "F2_CREDNFE"

			If nLancAp>0
				oFolder:aDialogs[nLancAp]:oFont := oDlg:oFont				
				If  FindFunction("a017xLAICMS")
					oLancCDV := a017xLAICMS(oFolder:aDialogs[nLancAp],{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},aHeadCDV,aColsCDV,l920Visual,l920Inclui,"SD2","MATA920")						
				Endif
				oLancApICMS := a920LAICMS(oFolder:aDialogs[nLancAp],{5,4,( aPosObj[3,4]-aPosObj[3,2] )-10,53},@aHeadCDA,@aColsCDA,l920Visual,l920Inclui)
			EndIf

			//Informacoes DANFE
			// Objeto Get, de acordo com a exibicao ou nao do folder financeiro
			aAdd(aObj1,Nil)
			nObjD := Len(aObj1)

			oFolder:aDialogs[nDANFE]:oFont := oDlg:oFont

			@ 9 ,aPosGet[9,1] SAY OemToAnsi(STR0095) Of oFolder:aDialogs[nDANFE] PIXEL SIZE 48 ,12 //"Chave NFE"
			@ 8 ,aPosGet[9,2] MSGET aObj1[nObjD] VAR aDANFE[01];
			Picture PesqPict('SF2','F2_CHVNFE');
			OF oFolder:aDialogs[nDANFE] PIXEL;
			When VisualSX3('F2_CHVNFE') .And. !l920Visual;
			VALID CheckSX3("F2_CHVNFE",aDANFE[01]);
			SIZE 150 ,9
			aObj1[nObjD]:cSX1Hlp := "F2_CHVNFE"
			iif(lLGPD,AnonimoLGPD(aObj1[nObjD],'F2_CHVNFE'),.F.)

		Endif
	Endif 
	
	//-------------------------------------------
	//Adiciona aba de tributos gen�ricos por item
	//-------------------------------------------
	If lTrbGen
		oFolder:aDialogs[nTrbGen]:oFont := oDlg:oFont
		oFisTrbGen := MaFisBrwTG(oFolder:aDialogs[nTrbGen],{5,4,( aPosObj[3,4]-aPosObj[3,2] ) - 10,53}, l920Visual)
	EndIF

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetDados:TudoOk() .And. a920LOk() .And. IIf(cPaisLoc == "BRA" .And. If(lMATA920,!l920Auto,.T.) .And. !lLote .And. l920Inclui .And. lGeraNum, a920NextDoc(), .T.),(nOpc:=1,oDlg:End()),nOpc:=0)},{||oDlg:End()},, xButton )
Else

	nOpc := 1

	//���������������������������������������������Ŀ
	//�Somente se for inclusao executa as validacoes�
	//�����������������������������������������������
	If l920Inclui
		aValidGet := {}
		aInfCliAut:= aClone(aInfClie)
		cTipo     := aAutoCab[ProcH("F2_TIPO"),2]
		a920VarAut:= aClone(a920Var)
		aNFeAut   := aClone(aNFEletr)
		aDANAut   := aClone(aDANFE)

		If lLote
			Aadd(aValidGet,{"c920Serie" ,aAutoCab[ProcH("F2_SERIE"),2]  ,"CheckSX3('F2_SERIE')",.t.})
			Aadd(aValidGet,{"c920NFIni" ,aAutoCab[ProcH("F2_DOC") ,2]   ,"A920VlNfLote(c920Serie,c920NFIni,,c920Especi,d920Emis)" ,.f.})
			Aadd(aValidGet,{"c920NFFim" ,aAutoCab[ProcH("F2_NFORI") ,2] ,"A920VlNfLote(c920Serie,c920NFIni,c920NFFim,c920Especi,d920Emis)" ,.f.})
			Aadd(aValidGet,{"d920Emis"  ,aAutoCab[ProcH("F2_EMISSAO"),2],"A920Emissao(d920Emis) .And. CheckSX3('F2_EMISSAO')",.t.})
			Aadd(aValidGet,{"c920Client",aAutoCab[ProcH("F2_CLIENTE"),2],"A920Client(c920Client,c920Loja,@aInfCliAut,cTipo).And.CheckSX3('F2_CLIENTE',c920Client,.T.)",.t.})
			Aadd(aValidGet,{"c920Loja"  ,aAutoCab[ProcH("F2_LOJA"),2]   ,"CheckSX3('F2_LOJA',c920Loja).and. A920Client(c920Client,c920Loja,@aInfCliAut,cTipo,.T.)",.t.})
			Aadd(aValidGet,{"c920Especi",aAutoCab[ProcH("F2_ESPECIE"),2],"CheckSX3('F2_ESPECIE',c920Especi)",.f.})
		Else
			Aadd(aValidGet,{"c920Tipo"  ,aAutoCab[ProcH("F2_TIPO"),2]   ,"A920Tipo(cTipo,,,,@c920Client,@c920Loja,)",.t.})
			Aadd(aValidGet,{"c920Nota"  ,aAutoCab[ProcH("F2_DOC") ,2]   ,"A920Client(c920Client,c920Loja,@aInfCliAut,cTipo,.T.)" ,.f.})
			Aadd(aValidGet,{"c920Serie" ,aAutoCab[ProcH("F2_SERIE"),2]  ,"A920Client(c920Client,c920Loja,@aInfCliAut,cTipo,.T.) .And. A920NOTA(c920Nota,c920Serie)",.t.})
			Aadd(aValidGet,{"d920Emis"  ,aAutoCab[ProcH("F2_EMISSAO"),2],"A920Emissao(d920Emis) .And. CheckSX3('F2_EMISSAO')",.t.})
			Aadd(aValidGet,{"c920Client",aAutoCab[ProcH("F2_CLIENTE"),2],"A920Client(c920Client,c920Loja,@aInfCliAut,cTipo,.T.).And.CheckSX3('F2_CLIENTE',c920Client) .And.A920VFold('NF_CODCLIFOR',c920Client)",.t.})
			Aadd(aValidGet,{"c920Loja"  ,aAutoCab[ProcH("F2_LOJA"),2]   ,"CheckSX3('F2_LOJA',c920Loja).and. A920Client(c920Client,c920Loja,@aInfCliAut,cTipo,.T.)	.And.A920VFold('NF_LOJA',c920Loja)",.t.})
			Aadd(aValidGet,{"c920Especi",aAutoCab[ProcH("F2_ESPECIE"),2],"CheckSX3('F2_ESPECIE',c920Especi)",.f.}) 	 	
		EndIf
		
		If cPaisLoc == "PTG"
			Aadd(aValidGet,{"c920DecExp",aAutoCab[ProcH("F2_DECLEXP"),2],"CheckSX3('F2_DECLEXP',c920DecExp)",.f.}) 	 	
		Endif

		If ! SF2->(MsVldGAuto(aValidGet)) // consiste os gets
			nOpc:= 0
		EndIf
		If !MaFisFound("NF")
			MaFisIni(c920Client,c920Loja,IIf(cTipo$'DB',"F","C"),cTipo, IIf(cTipo$'DB', Nil ,SA1->A1_TIPO ) , MaFisRelImp("MT100",{"SF2","SD2"}),,.T.,,,,,,,,,,,,,,,,,,,,,,,,,IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.))
		EndIf
		aInfClie := aClone(aInfCliAut)
		a920Var  := aClone(a920VarAut)
		If !MsGetDAuto(aAutoItens,"A920LinOk",{|| A920TudOk()},aAutoCab,aRotina[nOpcx][4])
			nOpc := 0
		EndIf
		//�����������������Ŀ
		//�Valida os Folders�
		//�������������������
		aValidGet := {}
		If lVAut920
			Aadd(aValidGet,{"a920VarAut["+str(VALDESC)+"]"  ,aAutoCab[ProcH("F2_DESCONT"),2] ,"A920VFold('NF_DESCONTO',a920VarAut["+str(VALDESC)+"])",.f.})
			Aadd(aValidGet,{"a920VarAut["+str(FRETE  )+"]"  ,aAutoCab[ProcH("F2_FRETE"  ),2] ,"A920VFold('NF_FRETE',a920VarAut["+str(FRETE)+"])",.f.})
			Aadd(aValidGet,{"a920VarAut["+str(VALDESP)+"]"  ,aAutoCab[ProcH("F2_DESPESA"),2] ,"A920VFold('NF_DESPESA',a920VarAut["+str(VALDESP)+"])",.f.})
			Aadd(aValidGet,{"a920VarAut["+str(SEGURO )+"]"  ,aAutoCab[ProcH("F2_SEGURO" ),2] ,"A920VFold('NF_SEGURO',a920VarAut["+str(SEGURO)+"])",.f.})
		Else
			// Se MV_VAUT920 for .F., entao devo validar as posicoes com ProcH. 
			// Se o ProcH for > 0, usar o valor de aAutoCab[]. Caso contrario, o valor ser� zero.

			nPosCpo := ProcH("F2_DESCONT")
			Aadd(aValidGet,{"a920VarAut["+str(VALDESC)+"]",IIf(nPosCpo > 0,aAutoCab[nPosCpo,2],0),"A920VFold('NF_DESCONTO',a920VarAut["+str(VALDESC)+"])",.f.})

			nPosCpo := ProcH("F2_FRETE")
			Aadd(aValidGet,{"a920VarAut["+str(FRETE  )+"]",IIf(nPosCpo > 0,aAutoCab[nPosCpo,2],0),"A920VFold('NF_FRETE',a920VarAut["+str(FRETE)+"])",.f.})

			nPosCpo := ProcH("F2_DESPESA")
			Aadd(aValidGet,{"a920VarAut["+str(VALDESP)+"]",IIf(nPosCpo > 0,aAutoCab[nPosCpo,2],0),"A920VFold('NF_DESPESA',a920VarAut["+str(VALDESP)+"])",.f.})

			nPosCpo := ProcH("F2_SEGURO")
			Aadd(aValidGet,{"a920VarAut["+str(SEGURO )+"]",IIf(nPosCpo > 0,aAutoCab[nPosCpo,2],0),"A920VFold('NF_SEGURO',a920VarAut["+str(SEGURO)+"])",.f.})	
		EndIf

		If cPaisLoc == "PTG"
			Aadd(aValidGet,{"a920VarAut["+str(NTRIB)+"]"  ,aAutoCab[ProcH("F2_NTRIB" ),2] ,"A920VFold('NF_NTRIB',a920VarAut["+str(NTRIB)+"])",.f.}) 	 	
			Aadd(aValidGet,{"a920VarAut["+str(TARA)+"]"  ,aAutoCab[ProcH("F2_TARA" ),2] ,"A920VFold('NF_TARA',a920VarAut["+str(TARA)+"])",.f.}) 	 				
		Endif

		If cPaisLoc == "BRA"
			If ProcH("F2_NFELETR") > 0
				Aadd(aValidGet,{"aNFeAut[01]",aAutoCab[ProcH("F2_NFELETR"),2],"CheckSX3('F2_NFELETR',aNFeAut[01])",.f.}) 	 	
				aNFEletr[01] := aAutoCab[ProcH("F2_NFELETR"),2]
			Endif
			If ProcH("F2_CODNFE") > 0
				Aadd(aValidGet,{"aNFeAut[02]",aAutoCab[ProcH("F2_CODNFE"),2],"CheckSX3('F2_CODNFE',aNFeAut[02])",.f.}) 	 	
				aNFEletr[02] := aAutoCab[ProcH("F2_CODNFE"),2]
			Endif
			If ProcH("F2_EMINFE") > 0
				Aadd(aValidGet,{"aNFeAut[03]",aAutoCab[ProcH("F2_EMINFE"),2],"A920NFe('EMINFE',aNFeAut) .And. CheckSX3('F2_EMINFE',aNFeAut[03])",.f.}) 	 	
				aNFEletr[03] := aAutoCab[ProcH("F2_EMINFE"),2]
			Endif
			If ProcH("F2_HORNFE") > 0
				Aadd(aValidGet,{"aNFeAut[04]",aAutoCab[ProcH("F2_HORNFE"),2],"CheckSX3('F2_HORNFE',aNFeAut[04])",.f.}) 	 	
				aNFEletr[04] := aAutoCab[ProcH("F2_HORNFE"),2]
			Endif
			If ProcH("F2_CREDNFE") > 0
				Aadd(aValidGet,{"aNFeAut[05]",aAutoCab[ProcH("F2_CREDNFE"),2],"A920NFe('CREDNFE',aNFeAut) .And. CheckSX3('F2_CREDNFE',aNFeAut[05])",.f.}) 	 	
				aNFEletr[05] := aAutoCab[ProcH("F2_CREDNFE"),2]
			Endif

			If ProcH("F2_CHVNFE") > 0
				Aadd(aValidGet,{"aDANAut[01]",aAutoCab[ProcH("F2_CHVNFE"),2],"CheckSX3('F2_CHVNFE',aDANAut[01])",.f.}) 	 	
				aDANFE[01] := aAutoCab[ProcH("F2_CHVNFE"),2]
			Endif
			If ProcH("F2_TPFRETE") > 0
				Aadd(aValidGet,{"a920VarAut["+str(TPFRETE)+"]",aAutoCab[ProcH("F2_TPFRETE"),2],"A920VFold('NF_TPFRETE',a920VarAut["+str(TPFRETE)+"])",.f.})
			EndIf
		Endif
		
		If ! SF2->(MsVldGAuto(aValidGet)) // consiste os gets
			nOpc:= 0
		EndIf
		a920Var  := aClone(a920VarAut)
	EndIf
EndIf

If nOpc == 1
	//���������������������������������������������������������Ŀ
	//� Ponto de Entrada na Exclusao.                           �
	//�����������������������������������������������������������
	If l920Deleta .And. ExistBlock("MTA920E")
		ExecBlock("MTA920E",.f.,.f.)
	Endif

	If l920Deleta .And. ExistBlock("MT920TOK")
		l920Deleta := ExecBlock("MT920TOK",.f.,.f.)
	Endif

	Begin Transaction
		//����������������������������������������������������������������Ŀ
		//� Efetua a gravacao da Nota Fiscal (Inclusao/Alteracao/Exclusao  �
		//������������������������������������������������������������������
		If l920Inclui .Or. l920Altera .Or. l920Deleta
			//�����������������������������������������������������������Ŀ
			//� Inicializa a gravacao atraves das funcoes MATXFIS         �
			//�������������������������������������������������������������
			MaFisWrite()

			a103GrvCDA(l920Deleta,"S",c920Especi,"S",c920Nota,c920Serie,c920Client,c920Loja)
			If FindFunction("a017GrvCDV")  
				a017GrvCDV(l920Deleta,"S",c920Especi,"S",c920Nota,c920Serie,c920Client,c920Loja)
			Endif

			If Type("l920Auto") != "L" .or. !l920Auto
				FWMsgRun(,{||A920Grava(l920Deleta,aNFEletr,aDANFE,l920Inclui)},,cCadastro)
			Else
				A920Grava(l920Deleta,aNFEletr,aDANFE,l920Inclui)
			EndIf

			//�����������������������������������������������������������Ŀ
			//� Processa os gatilhos                                      �
			//�������������������������������������������������������������
			EvalTrigger()

		EndIf
	End Transaction	

	// tratamento somente utilizado para numera��o pelo License nas tabelas xe e xf
	If cTpNrNfs == "2"
		While __lSx8
			ConfirmSx8()
		EndDo	
	EndIf

EndIf

If Type("lGeraNum") == "L"
	lGeraNum := .F.
EndIf

//�����������������������������������������������������������Ŀ
//� Destrava os registros na altEracao e exclusao             �
//�������������������������������������������������������������
MsUnlockAll()

//�����������������������������������������������������������Ŀ
//� Finaliza o uso das funcoes MATXFIS                        �
//�������������������������������������������������������������

MaFisEnd()
RestArea(aAreaSE1)
RestArea(aArea)

SetKey(VK_F4,NIL)

Return nOpc
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920FRefre� Autor � Andreia dos Santos    � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Executa o refresh nos objetos do array.                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Array contendo os Objetos                          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA920                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920FRefresh(aObj)
Local nx
If Type("l920Auto") !="L" .or. !l920Auto
	For nx := 1 to Len(aObj)
		aObj[nx]:Refresh()
	Next
EndIf
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920Refresh� Autor � Andreia dos Santos   � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Executa o Refresh do Folder.                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA920                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920Refresh(a920Var,l920Inclui)
Local aArea		:= GetArea()			// Guarda a area do SF2
Local aAreaSD2	:= SD2->(GetArea())	// Guarda a area do SD2
Local aAreaSF4	:= SF4->(GetArea())
Local lLoja		:= .F.					// Indica se a nota fiscal foi gerada no sigaloja
Local lAgregSol := .F.					// Agrega Solidario ao Total da Nota
Local cAliasSD2 := ""
Local nItem := 0
Local nValAcresc := 0					// Valor do Acrescimo

If l920Inclui
	a920Var[VALMERCB]	:= MaFisRet(,"NF_VALMERC") + Iif(l920Inclui,0,MaFisRet(,"NF_DESCONTO"))					// Valor da Mercadoria (Bruto)
	a920Var[VALDESC]	:= MaFisRet(,"NF_DESCONTO") 								// Descontos
	a920Var[TOTPED]		:= MaFisRet(,"NF_TOTAL") 									// Total da Nota
	a920Var[VALMERC]	:= MaFisRet(,"NF_VALMERC") - Iif(l920Inclui,MaFisRet(,"NF_DESCONTO"),0)		// Valor da Mercadoria (Liquido)

	a920Var[FRETE]		:= MaFisRet(,"NF_FRETE")
	a920Var[SEGURO]		:= MaFisRet(,"NF_SEGURO")
	a920Var[VALDESP]	:= MaFisRet(,"NF_DESPESA")

	If cPaisLoc == "PTG"
		a920Var[NTRIB] 		:= MaFisRet(,"NF_DESNTRB")
		a920Var[TARA]		:= MaFisRet(,"NF_TARA")
	Endif

	a920Var[TOTF1]		:= a920Var[VALDESP]	+ a920Var[SEGURO] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)
	a920Var[TOTF3]		:= a920Var[FRETE] + a920Var[SEGURO] + a920Var[VALDESP] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)
Else
	If TcSrvType() <> "AS/400"
		cAliasSD2 := "QRYSD2"
		cQuery := "SELECT D2_ORIGLAN,SD2.D2_TES "
		cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
		cQuery += "WHERE "
		cQuery += "D2_FILIAL = '"+xFilial("SD2")+"' AND "
		cQuery += "D2_CLIENTE = '"+SF2->F2_CLIENTE+"' AND "
		cQuery += "D2_LOJA = '"+SF2->F2_LOJA+"' AND "
		cQuery += "D2_DOC = '"+SF2->F2_DOC+"' AND "
		cQuery += "D2_SERIE = '"+SF2->F2_SERIE+"' AND "
		cQuery += "SD2.D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.F.,.T.)
	EndIf
	While !(cAliasSD2)->(Eof())
		nItem ++
		//���������������������������������������������������������������������������������������������Ŀ
		//� Verifica se a nota/cupom fiscal foi gerado no Sigaloja ou pelo Venda Direta do Faturamento  �
		//�����������������������������������������������������������������������������������������������
		If AllTrim((cAliasSD2)->D2_ORIGLAN) == "LO" .Or. AllTrim((cAliasSD2)->D2_ORIGLAN) == "VD"
			lLoja := .T.
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)
			lAgregSol := (SF4->F4_INCSOL == 'S')
		EndIf

			a920Var[FRETE]		:= MaFisRet(,"NF_FRETE")
			a920Var[SEGURO]		:= MaFisRet(,"NF_SEGURO")
			a920Var[VALDESP]	:= MaFisRet(,"NF_DESPESA")

			If lLoja
				// Grava o valor do acrescimo desconsiderando os valores de frete, seguro e despesa pois j� s�o gravados nos respectivos campos
				nValAcresc := SF2->F2_VALACRS - (a920Var[FRETE] + a920Var[SEGURO] + a920Var[VALDESP])
				// O LOJA grava o valor do acrescimo separado do valor da mercadoria
				// Deve-se somar o acrescimo para a correta exebicao dos totais
				a920Var[VALMERCB]	:= MaFisRet(,"NF_VALMERC") + nValAcresc										// Valor da Mercadoria (Bruto)
				a920Var[VALDESC]	:= MaFisRet(,"NF_DESCONTO")						// Descontos
				//Inclu�do o valor do ICMS Solid�rio, ao Valor Total da Nota
				a920Var[TOTPED]		:= MaFisRet(,"NF_VALMERC") - a920Var[VALDESC] + nValAcresc + MaFisRet(,"NF_VALIPI") // Total da Nota
				If lAgregSol
					a920Var[TOTPED] += MaFisRet(nItem,"IT_VALSOL")	// Total da Nota
				EndIf
				a920Var[VALMERC]	:= MaFisRet(,"NF_VALMERC") - a920Var[VALDESC] + nValAcresc					// Valor da Mercadoria (Liquido)
				a920Var[TOTPED]		:= MaFisRet(,"NF_TOTAL") 									// Total da Nota
			Else
				a920Var[VALMERCB]	:= MaFisRet(,"NF_VALMERC") + Iif(l920Inclui,0,MaFisRet(,"NF_DESCONTO"))					// Valor da Mercadoria (Bruto)
				a920Var[VALDESC]	:= MaFisRet(,"NF_DESCONTO") 								// Descontos
				a920Var[TOTPED]		:= MaFisRet(,"NF_TOTAL") 									// Total da Nota
				a920Var[VALMERC]	:= MaFisRet(,"NF_VALMERC") - Iif(l920Inclui,MaFisRet(,"NF_DESCONTO"),0)		// Valor da Mercadoria (Liquido)
			EndIf

			If cPaisLoc == "PTG"
				a920Var[NTRIB] 		:= MaFisRet(,"NF_DESNTRB")
				a920Var[TARA]		:= MaFisRet(,"NF_TARA")
			Endif

			a920Var[TOTF1]		:= a920Var[VALDESP]	+ a920Var[SEGURO] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)
			a920Var[TOTF3]		:= a920Var[FRETE] + a920Var[SEGURO] + a920Var[VALDESP] + Iif(cPaisLoc=="PTG",a920Var[NTRIB] + a920Var[TARA],0)

			(cAliasSD2)->(DbSkip())
	EndDo
	dbSelectArea(cAliasSD2)
	dbCloseArea()
	RestArea(aAreaSF4)
	RestArea(aAreaSD2)
	RestArea(aArea)
EndIf

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920CabOk � Autor � Andreia dos Santos    � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Executa  as validacoes dos Gets.                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA920                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920CabOk(oTipo,oNota,oEmis,oClie,oLoja)
Local lRet 	:= .F.

Do Case
	Case Empty(cTipo)
		oTipo:SetFocus()
	Case Empty(c920Nota) .And. !lGeraNum
		oNota:SetFocus()
	Case Empty(d920Emis)
		oEmis:SetFocus()
	Case Empty(c920Client)
		oClie:SetFocus()
	Case Empty(c920Loja)
		oLoja:SetFocus()
	OtherWise
		If !MaFisFound("NF")
			MaFisIni(c920Client,c920Loja,If(cTipo$'DB',"F","C"),cTipo,IIf(cTipo$'DB', Nil ,SA1->A1_TIPO ),MaFisRelImp("MT100",{"SF2","SD2"}),,.T.,,,,,,,,,,,,,,,,,d920Emis,,,,,,,,IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.))
			MaFisIniLoad(Len(aCols)) // Carrega aNfItem para tratativa no MATXFIS
		Else
			If !l920Visual
				MaFisAlt("NF_DTEMISS",d920Emis)
			EndIf
		EndIf
		lRet := .T.
EndCase

Return lRet
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920VFold � Autor � Andreia dos Santos    � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Exucuta o calculo de valores para campos Totalizadores.     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Referencia ( vide MATXFIS)                         ���
���          � ExpC2 = Valor da Referencia                                ���
���          � ExpL3 = .T./.F.- Executa o Refresh do folder               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Campos Totalizadores do MATA920                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920VFold(cReferencia,xValor,lRefre)
Local aArea	:= GetArea()

If lRefre==Nil
	lRefre := .T.
EndIf

If MaFisFound("NF").And.!(MaFisRet(,cReferencia)==xValor)
	MaFisAlt(cReferencia,xValor)
	a920FisToaCols()
	If lRefre
		Eval(bRefresh)
		Eval(bGDRefresh)
	EndIf
EndIf

RestArea(aArea)
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920FieldOk �Autor� Andreia dos Santos    � Data �02.02.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validade de campo da GateDados.                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA920                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920FieldOk()
Eval(bRefresh)
Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A920Del  � Autor � Andreia dos Santos    � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Critica a delecao da linha                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Objeto a ser verificado.                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA920                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920Del(o)
Local nPosItD2	:= 	aScan(aHeader,{|aX| aX[2]==PadR("D2_ITEM",Len( GetSx3Cache( "D2_ITEM", "X3_CAMPO" ) ))})
Local nPosCod	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_COD" })
Local nI		:=	0
Local nPosCalc	:=	0
Local nPosIt	:=	0

if !l920Visual .and. !Empty(aCols[n][nPosCod])
	MaFisDel(n,aCols[n][Len(aCols[n])])
	Eval(bRefresh)
	
	If Type("oLancApICMS")<>"U" .And. oLancApICMS<>Nil .And. nPosItD2>0
		nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
		nPosIt	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
		For nI := 1 To Len(oLancApICMS:aCols)
			If aCols[n,nPosItD2]==AllTrim(oLancApICMS:aCols[nI,nPosIt])
				oLancApICMS:aCols[nI,Len(oLancApICMS:aCols[nI])]	:=	aCols[n,Len(aCols[n])]
			EndIf
		Next nI
		oLancApICMS:Refresh()
	EndIf
EndIf

If Type("oLancCDV")<>"U" .And. oLancCDV<>Nil .And. nPosItD2>0
	nPosCalc:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_AUTO"})
	nPosIt	:=	aScan(oLancCDV:aHeader,{|aX|aX[2]=="CDV_NUMITE"})
	For nI := 1 To Len(oLancCDV:aCols)
		If aCols[n,nPosItD2]==oLancCDV:aCols[nI,nPosIt]
			oLancCDV:aCols[nI,Len(oLancCDV:aCols[nI])]	:=	aCols[n,Len(aCols[n])]
		EndIf
	Next nI
	oLancCDV:Refresh()
EndIf

Return .T.
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920LinOk�Autor� Andreia dos Santos       � Data �02.02.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validade da linha da GatDados.                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA920                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920LinOk()
Local lRet 		:= .T.
Local nPosCod	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_COD" })
Local nPosQuant:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_QUANT"})
Local nPosUnit	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_PRCVEN"})
Local nPosTotal:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_TOTAL"})
Local nPosTES	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_TES"})
Local nPosCF	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_CF"})
Local nPosOri	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_NFORI"})
Local lF4VlZero     := SF4->(ColumnPos("F4_VLRZERO")) > 0
Local lF4QTDZERO    := SF4->(ColumnPos("F4_QTDZERO")) > 0	
Local lPermite		:= .F.

IF cPaisLoc == "BRA" .And. lF4VlZero .And. lF4QTDZERO .And. SF4->(MsSeek(xFilial("SF4")+aCols[n][nPosTES]))
	IF SF4->F4_VLRZERO == "1" .And. SF4->F4_QTDZERO == "1"
		lPermite := .T.
	EndIf
EndIf

//�������������������������������������������������������������������Ŀ
//� Verifica se a linha nao esta em branco e os itens nao Deletados   �
//���������������������������������������������������������������������
If CheckCols(n,aCols) .And. !aCols[n][Len(aHeader)+1]
	Do Case
	Case 	Empty(aCols[n][nPosCod]) 	.Or. ;
			(	Empty(aCols[n][nPosQuant]).And. cTipo$"NDB" .And. !lPermite).Or. ;
			(Empty(aCols[n][nPosUnit]) .And. !lPermite) .Or. ;
			(Empty(aCols[n][nPosTotal]) .And. !lPermite).Or. ;
			Empty(aCols[n][nPosCF]) 	.Or. ;
			Empty(aCols[n][nPosTES])
		Help("  ",1,"A100VZ")			 	
		lRet := .F.
	Case cTipo $"CPI" .And. Empty(aCols[n][nPosOri])
		HELP(" ",1,"A910COMPIP")
		lRet := .F.
	Case cTipo=="D" .And.Empty(aCols[n][nPosOri])
		HELP(" ",1,"A910NFORI")
		lRet := .F.
	Case cTipo$'NDB' .And. (aCols[n][nPosTotal]>(aCols[n][nPosUnit]*aCols[n][nPosQuant]+0.09);
			.Or. aCols[n][nPosTotal]<(aCols[n][nPosUnit]*aCols[n][nPosQuant]-0.09))
		Help("  ",1,'A12003')
		lRet := .F.
	EndCase
ElseIf !CheckCols(n,aCols)		
	lRet := .F.
EndIf

//�����������������������������������������������Ŀ
//� Pontos de Entrada 							  �
//�������������������������������������������������
If (ExistBlock("MT920LOK"))
	lRet := ExecBlock("MT920LOK",.F.,.F.,{lRet})
EndIf
            
Return lRet 
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920TudOk�Autor� Andreia dos Santos       � Data �02.02.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validade TudOk da GetDados.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA920                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920Tudok()
Local lRet   := .T.
Local nItens := 0
Local nx     := 0

If Empty(c920Client) .Or. Empty(d920Emis) .Or. If(!lLote, Empty(cTipo),.F.) .Or. (Empty(c920Nota) .And. !lLote .And. !lGeraNum)
	Help(" ",1,"A100FALTA")
	lRet := .F.
EndIf	          
//�����������������������������������������������������Ŀ
//�Impede a inclusao de documentos sem nenhum item ativo�
//�������������������������������������������������������
For nx:=1 to len(aCols)
	If !aCols[nx][Len(aCols[nx])]   
		nItens ++
	Endif
Next

If nItens == 0
	Help("  ",1,"A100VZ")
	lRet := .F.
EndIf

//�������������������������������������������������������������-Ŀ
//� Conforme situacao do parametro abaixo, integra com o SIGAGSP �
//�             MV_SIGAGSP - 0-Nao / 1-Integra                   �
//������������������������������������������������������������-���
If GetNewPar("MV_SIGAGSP","0") == "1" .And. FindFunction('GSPF030')
	lRet:= GSPF030()
EndIf

If nModulo == 72
	lRet := KEXF870(lRet)
EndIf

If (ExistBlock("MT100TOK"))
	lRet := ExecBlock("MT100TOK",.F.,.F.,{lRet})
EndIf

//���������������������������������������Ŀ
//� Verifica se o Registro esta Bloqueado.�
//�����������������������������������������
If lRet
	If cTipo$"DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If MsSeek(xFilial("SA2")+c920Client+c920Loja)
			If !RegistroOk("SA2")
				lRet := .F.
			EndIf
		Endif		
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+c920Client+c920Loja)
			If !RegistroOk("SA1")
				lRet := .F.
			EndIf
		Endif
	Endif
Endif

If lRet .And. !lLote 
	lRet := A920Nota(c920Nota,c920Serie,c920Especi,d920Emis)
EndIf

Return lRet
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a920FisToaCols� Autor � Andreia dos Santos� Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza o aCols com os valores da funcao fiscal.          ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA920                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920FisToaCols()

Local nx
Local ny
Local cValid
Local nPosRef

For ny := 1 to Len(aCols)
	For nx	:= 1 to Len(aHeader)
		cValid	:= AllTrim(UPPER(aHeader[nx][6]))
		If "MAFISREF"$cValid
			nPosRef := 	AT('MAFISREF("',cValid) + 10
			cRefCols:=	Substr(cValid,nPosRef,AT('","MT100",',cValid)-nPosRef )
			If MaFisFound("IT",ny)
				//Se a referencia for da Classifica��o fiscal e a TES estiver em branco, a Classifica��o fiscal n�o ser�
				//Atribuida ao aCols da Nota
				If cRefCols == "IT_CF" .AND. Empty(aCols[nY][GdFieldPos(substr(cValid,26,2)+"_TES")])
					aCols[ny][nx]:= ""
				Else
					aCols[ny][nx]:= MaFisRet(ny,cRefCols)
				Endif
			EndIf
		EndIf
	Next
Next

Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a920Tipo� Autor � Andreia dos Santos      � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Tipo de Nota.                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA920 : Campo F2_TIPO                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920Tipo(cTipo,oSClie,cSClie,oGClie,cCliente,cLoja,oLoja)
Local nPosTES	:= aScan(aHeader,{|x| Alltrim(x[2]) == "D2_TES"})
Local nx
Local nY

If cTipo$'DB'
	If Type("l920Auto") != "L" .or. !l920Auto
		oGClie:cF3 	:= 'FOR'
	EndIf
	cSClie		:= OemToAnsi(STR0035) //Fornecedor
	If MaFisFound("NF").And.MaFisRet(,"NF_TIPONF") != cTipo
		cCliente		:= CriaVar("F2_CLIENTE")
		cLoja			:= CriaVar("F2_LOJA")
	EndIf
Else
	If Type("l920Auto") != "L" .or. !l920Auto
		oGClie:cF3 	:= 'SA1'
	EndIf
	cSClie		:= OemToAnsi(STR0011)     //Cliente
	If MaFisFound("NF").And.MaFisRet(,"NF_TIPONF") != cTipo
		cCliente		:= CriaVar("F2_CLIENTE")
		cLoja			:= CriaVar("F2_LOJA")
	EndIf
EndIf

If MaFisFound("NF") .And. cTipo!= MafisRet(,"NF_TIPONF")
	aCols			:= {}
	aADD(aCols,Array(Len(aHeader)+1))
	For ny := 1 to Len(aHeader)
		If Trim(aHeader[ny][2]) == "D2_ITEM"
			aCols[1][ny] 	:= "01"
		ElseIf ( aHeader[ny][10] != "V")
			aCols[1][ny] := CriaVar(aHeader[ny][2])
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next ny
	MaFisAlt("NF_CLIFOR",If(cTipo$"DB","F","C"))
	MaFisAlt("NF_TIPONF",cTipo)
	MaFisClear()
	If oSClie <> Nil
		oSClie:Refresh()
	EndIf
	If oGClie <> Nil
		oGClie:Refresh()
	EndIf
	If oLoja <> Nil
		oLoja:Refresh()
	EndIf
	Eval(bGDRefresh)
	Eval(bRefresh)
EndIf

Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a920Nota� Autor � Andreia dos Santos      � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida o Numero da Nota Fiscal Digitado                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA920 : Campo F2_DOC                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920Nota(cNota,cSerie,cEspecie,dDataEmis)

Local lRet := .T.
Local cSerId := ""

//�����������������������������������������������Ŀ
//� Id da serie para compor as chaves das funcoes �
//�������������������������������������������������				
If SerieNfId("SF2",3,"F2_SERIE") == "F2_SDOC"
	cSerId := Substr(cSerie,1,3) +  StrZero(Month(dDataEmis),2) + Str(Year(dDataEmis),4) + AllTrim(cEspecie)
Else
	cSerId := Substr(cSerie,1,3)
EndIf

If Empty(cNota) .And. !lGeraNum
	lRet	:= .F.
	HELP("  ",1,"F2_DOC")
EndIf

If lRet
	//������������������������������������������������������������Ŀ
	//� Consiste duplicidade de digitacao de Nota Fiscal           �
	//��������������������������������������������������������������
	If SF2->( MsSeek(xFilial()+cNota+cSerId) )
		lRet := .F.
		HELP(" ",1,"A920EXIST")
	Endif

EndIf

Return lRet
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �a920Emissao� Autor � Andreia dos Santos   � Data � 02.02.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do Tipo de Nota.                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA920 : Campo F2_EMISSAO                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920Emissao(dEmissao)
Local lRet	:= .T.

If dEmissao > dDataBase
	lRet := .F.
	HELP("  ",1,"A100DATAM")
Else
	lRet := FisChkDt(dEmissao)
EndIf

Return lRet
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �A920Client�Autor  �Andreia dos Santos  � Data �  02/02/00   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega os dados do Fornecedor/Cliente                      ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Mata920 Campo: Cliente   		                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A920Client(cCliente,cLoja,aInfClie,cTipo,l920Inclui)
Local lRet   := .T.
Local cAlias := ""

IF !Empty(cCliente)
    cAlias := "SF2"
	If cTipo$"DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		IF !Empty(cLoja)
			lRet := SA2->(MsSeek(xFilial("SA2")+cCliente+cLoja))
			//���������������������������������������������������������Ŀ
			//� Atualiza o array que contem os dados do Fornecedor      �
			//�����������������������������������������������������������
			If lRet
				aInfClie[1]	:= SA2->A2_NOME						// Nome
				aInfClie[2]	:= SA2->A2_TEL 						// Telefone
				aInfClie[3]	:= SA2->A2_PRICOM	    				//Primeira Compra do Cliente
				aInfClie[4]	:= SA2->A2_ULTCOM      				//Ultima Compra do Cliente
				aInfClie[5]	:= SA2->A2_END+" - "+SA2->A2_MUN		//Endereco
				aInfClie[6]	:= SA2->A2_EST         				//Estado			
			EndIf
		Else
			lRet 	:= SA2->(MsSeek(xFilial("SA2")+cCliente))
			If lRet
				c920Loja := SA2->A2_LOJA
			Endif				
		EndIf
	Else
        cAlias := "SF1"
		dbSelectArea("SA1")
		dbSetOrder(1)
		IF !Empty(cLoja)
			lRet := SA1->(MsSeek(xFilial("SA1")+cCliente+cLoja))
			If lRet
				aInfClie[1]	:= SA1->A1_NOME						// Nome
				aInfClie[2]	:= SA1->A1_TEL 						// Telefone
				aInfClie[3]	:= SA1->A1_PRICOM	    				//Primeira Compra
				aInfClie[4]	:= SA1->A1_ULTCOM      				//Ultima Compra
				aInfClie[5]	:= SA1->A1_END+" - "+SA1->A1_MUN //Endereco
				aInfClie[6]	:= SA1->A1_EST         			  //Estado
			EndIf
		Else			
			lRet := SA1->(MsSeek(xFilial("SA1")+cCliente))
			If lRet
				c920Loja := SA1->A1_LOJA
			Endif				
		Endif
	EndIf
    
    //PE para verificar se a NF foi cancelada
    if l920Inclui
       if ExistBlock("MTVALNF") 
          if !ExecBlock("MTVALNF",.F.,.F.,{cAlias,xFilial(cAlias),c920Nota,c920Serie,cCliente,c920Loja})
             lRet := .F.
          endif   
       endif
    endif
   
EndIF

Return lRet
/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    �a920Grava � Autor � Andreia dos Santos       � Data �02.02.00 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a Nota Fiscal                                          ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Mata920                                                      ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function A920Grava(lDeleta,aNFEletr,aDANFE,l920Inclui)
//��������������������������������������������������������������Ŀ
//� Definine variaveis                                           �
//����������������������������������������������������������������
LOCAL nx
LOCAL ny
LOCAL nMaxArray
LOCAL cLocal
LOCAL nVlrTotal	:= 0
LOCAL nUPRC		:= 0
LOCAL aLivro
LOCAL aFixos
LOCAL nDedICMS	:= 0
Local lMvAtuComp:= SuperGetMV("MV_ATUCOMP",,.F.)
Local aHorario	:= {}
Local cHoraRMT	:= SuperGetMv("MV_HORARMT",.F.,"2")	//Hor�rio gravado nos campos F1_HORA/F2_HORA.
													//1=Horario do SmartClient; 2=Horario do servidor;
													//3=Fuso hor�rio da filial corrente;
Local cLancPad	:= '6B8'
Local lLancPad	:= VerPadrao( cLancPad)
Local cAuxCod	:= ""
Local cLoteCtb	:= ''
Local cArqCtb	:= ''
Local nTotalCtb	:= 0
Local aRecOri	:= {}
Local lExibCtb	:= Iif(MV_PAR01 == 1, .T., .F.)
Local nHldPrv	:= 0
Local lTrbGen	:= IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.)
Local lMT920IT	:= ExistBlock("MT920IT")
Local aFlagCTB  := {}

Local cMVARREFAT := SuperGetMv("MV_ARREFAT")

Default aNfEletr := {}
Default aDANFE   := {}
//�������������������������������������������������������������Ŀ
//� Posiciona no fornecedor escolhido                           �
//���������������������������������������������������������������
If cTipo$"DB"
	dbSelectArea("SA2")
	dbSetOrder(1)
	MsSeek(xFilial()+c920Client+c920Loja)
Else
	dbSelectArea("SA1")
	dbSetOrder(1)
	MsSeek(xFilial()+c920Client+c920Loja)
EndIf

If Type("l920Auto") != "L" .or. !l920Auto
	ProcRegua(Len(aCols)+1)
EndIf

If !lDeleta
	//��������������������������������������������������������������Ŀ
	//� Atualiza dados padroes do cabecalho da NF de entrada.        �
	//����������������������������������������������������������������
	dbSelectArea("SF2")
	dbSetOrder(1)
	RecLock("SF2",.T.)
	SF2->F2_TIPO	:= if(lLote,"L",cTipo)
	SF2->F2_DOC		:= if(lLote,c920NfIni,c920Nota)
	SerieNfId("SF2",1,"F2_SERIE",d920Emis,c920Especi,c920Serie)
	SF2->F2_EMISSAO	:= d920Emis
	SF2->F2_LOJA	:= c920Loja
	SF2->F2_CLIENTE	:= c920Client
	SF2->F2_EST		:= IIF(cTipo$"DB",SA2->A2_EST,SA1->A1_EST)
	SF2->F2_DESCONT	:= MaFisRet(,"NF_DESCONTO")
	SF2->F2_VALMERC	:= MaFisRet(,"NF_VALMERC")-MaFisRet(,"NF_DESCONTO")
	SF2->F2_VALICM	:= MaFisRet(,"NF_VALICM")
	SF2->F2_VALIPI	:= MaFisRet(,"NF_VALIPI")
	SF2->F2_VALBRUT	:= MaFisRet(,"NF_TOTAL")
	SF2->F2_FRETE	:= MaFisRet(,"NF_FRETE")
	SF2->F2_BASEIPI	:= MaFisRet(,"NF_BASEIPI")
	SF2->F2_BASEICM	:= MaFisRet(,"NF_BASEICM")
	SF2->F2_DESPESA	:= MaFisRet(,"NF_DESPESA")
	SF2->F2_FILIAL 	:= xFilial("SF2")
	SF2->F2_BRICMS 	:= MaFisRet(,"NF_BASESOL")
	SF2->F2_ICMSRET	:= MaFisRet(,"NF_VALSOL")
	SF2->F2_ESPECIE	:= c920Especi
	SF2->F2_NFORI	:= if(lLote, c920NFFim,"")
	SF2->F2_LOTE	:= if(lLote,"S","")

	If SuperGetMv("MV_HORANFE",.F.,.F.) .And. Empty(SF2->F2_HORA)
		//Parametro MV_HORARMT habilitado pega a hora do smartclient, caso contrario a hora do servidor
		If cHoraRMT == '1' //Horario do SmartClient
			SF2->F2_HORA := GetRmtTime()
		ElseIf cHoraRMT == '2' //Horario do servidor
			SF2->F2_HORA := Time()
		ElseIf cHoraRMT =='3' //Horario de acordo com o estado da filial corrente			
			aHorario := A103HORA()
			If !Empty(aHorario[2])
				SF2->F2_HORA := aHorario[2]
			EndIf
		Endif
	EndIf

	//����������������������Ŀ
	//�Nota Fiscal Eletronica�
	//������������������������
	If cPaisLoc == "BRA"
		SF2->F2_NFELETR	:= aNFEletr[01]
		SF2->F2_CODNFE	:= aNFEletr[02]
		SF2->F2_EMINFE	:= aNFEletr[03]
		SF2->F2_HORNFE	:= aNFEletr[04]
		SF2->F2_CREDNFE	:= aNFEletr[05]
		SF2->F2_CHVNFE	:= aDANFE[01]
	Endif

	If cPaisLoc == "PTG"
		SF2->F2_DECLEXP	:= c920DecExp
		SF2->F2_DESNTRB	:= MaFisRet(,"NF_DESNTRB")
		SF2->F2_TARA	:= MaFisRet(,"NF_TARA")
	Endif

	//����������������������������������������������������������Ŀ
	//� Ponto de entrada para atualizar o cabecalho da NF        �
	//������������������������������������������������������������

	If ExistBlock("MTA920C")
		ExecBlock("MTA920C",.f.,.f.)
	EndIf

	//������������������������������������������������������Ŀ
	//� Efetua a gravacao dos campos referentes ao imposto   �
	//��������������������������������������������������������
	MaFisWrite(2,"SF2",Nil)

	//Grava��o do campo F2_IDNF
	IF SF2->(FieldPos('F2_IDNF')) > 0
		SF2->F2_IDNF := FWUUID("SF2")
	EndIf

	SF2->(FKCommit())

	//��������������������������������������������������������������Ŀ
	//� Atualiza dados padroes dos itens da NF de entrada.           �
	//����������������������������������������������������������������
	dbSelectArea("SD2")
	dbSetOrder(1)
	If Type("l920Auto") != "L" .or. !l920Auto
		IncProc()
	EndIf
	For nx := 1 to Len(aCols)
		If !aCols[nx][Len(aCols[nx])]
			//�������������������������������������������������������������Ŀ
			//� Atualiza dados do corpo da nota selecionados pelo cliente   �
			//���������������������������������������������������������������
			RecLock("SD2",.T.)
			For ny := 1 to Len(aHeader)
				//�����������������������������������������������������������Ŀ
				//� verifica se e' o codigo para dar seek no SB1 e pegar grupo�
				//�������������������������������������������������������������
				If Trim(aHeader[ny][2]) == "D2_COD"
					SB1->(dbSetOrder(1))
					SB1->(MsSeek(xFilial()+aCols[nx][ny]))
					SD2->D2_GRUPO	:= SB1->B1_GRUPO
					SD2->D2_TP		:= SB1->B1_TIPO
				Endif
				If aHeader[ny][10] # "V"
					Var := Trim(aHeader[ny][2])
					Replace &Var. With aCols[nx][ny]
				Endif
			Next ny
			//��������������������������������������������������������������Ŀ
			//� Atualiza dados padroes do corpo da nota fiscal de entrada    �
			//����������������������������������������������������������������
			SD2->D2_LOJA	:= c920Loja
			SD2->D2_CLIENTE	:= c920Client
			SD2->D2_DOC		:= if(lLote,c920NFIni,c920Nota)
			SD2->D2_EMISSAO	:= d920Emis
			SerieNfId("SD2",1,"D2_SERIE",d920Emis,c920Especi,c920Serie)
			SD2->D2_TIPO	:= cTipo
			SD2->D2_FILIAL	:= xFilial("SD2")
			SD2->D2_NUMSEQ	:= ProxNum()
			SD2->D2_VALIPI	:= MaFisRet(nx,"IT_VALIPI")
			SD2->D2_VALICM	:= MaFisRet(nx,"IT_VALICM")
			SD2->D2_PICM	:= MaFisRet(nx,"IT_ALIQICM")
			SD2->D2_ORIGLAN	:= "LF"
			SD2->D2_EST		:= SF2->F2_EST
			SD2->D2_DESCZFR	:= MaFisRet(nX,"IT_DESCZF")

			//����������������������������������������������������������Ŀ
			//� Ponto de entrada para atualizar os itens da NF           �
			//������������������������������������������������������������
			If lMT920IT
				ExecBlock("MT920IT",.f.,.f.)
			ENDIF

			//������������������������������������������������������Ŀ
			//� Efetua a gravacao dos campos referentes ao imposto   �
			//��������������������������������������������������������
			MaFisWrite(2,"SD2",nx)
			If !(cTipo$"CPI")
				SD2->D2_TOTAL	:= SD2->D2_TOTAL - SD2->D2_DESCON

				If GetNewPar ("MV_ARREFAT", "XXX")<>"XXX" .And. ( cMVARREFAT == "S" )
					SD2->D2_PRCVEN	:= Round(((SD2->D2_PRCVEN*SD2->D2_QUANT)/SD2->D2_QUANT)-(SD2->D2_DESCON/SD2->D2_QUANT),TamSX3("D2_PRCVEN")[2])
				Else
					SD2->D2_PRCVEN	:= NoRound(((SD2->D2_PRCVEN*SD2->D2_QUANT)/SD2->D2_QUANT)-(SD2->D2_DESCON/SD2->D2_QUANT),TamSX3("D2_PRCVEN")[2])
				EndIf

			EndIf

			//Faz chamada para grava��o dos tributos gen�ricos na tabela F2D, bem como o ID do tributo na SD2.
			IF lTrbGen
				SD2->D2_IDTRIB	:= MaFisTG(1,"SD2",nX)
			EndIF

		EndIf

		//������������������������������������������������������������������������Ŀ
		//� Desconta o Valor do ICMS DESONERADO do valor do Item D2_PRCVEN         �
		//��������������������������������������������������������������������������
		SF4->(dbSetOrder(1))
		SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))
		If SF4->F4_AGREG$"R"
			nDedICMS += MaFisRet(nX,"IT_DEDICM")
			SD2->D2_TOTAL  -= MaFisRet(nX,"IT_DEDICM")
			SD2->D2_PRCVEN := A410Arred(SD2->D2_TOTAL/IIf(SD2->D2_QUANT==0,1,SD2->D2_QUANT),"D2_PRCVEN")
		EndIf

		If Type("l920Auto") != "L" .or. !l920Auto
			IncProc()
		EndIf

	Next nx

	//������������������������������������������������������������������������Ŀ
	//� Desconta o Valor do ICMS DESONERADO do valor do Item D2_PRCVEN         �
	//��������������������������������������������������������������������������
	If nDedICMS > 0
		SF2->F2_VALMERC -= nDedICMS
	EndIf

	//����������������������������������������������������Ŀ
	//�Atualiza dados dos complementos SPED automaticamente�
	//������������������������������������������������������
	If lMvAtuComp .And. l920Inclui
		AtuComp(c920Nota,SF2->F2_SERIE,c920Especi,c920Client,c920Loja,"S",cTipo)
	EndIf

	//����������������������������������������������������������Ŀ
	//� Grava arquivo de Livros Fiscais (SF3)                    �
	//������������������������������������������������������������
	MaFisAtuSF3(1,"S",SF2->(RecNo()))

	If ExistBlock("MTA920I")
		ExecBlock("MTA920I",.F.,.F.)
	Endif

Else

	// Lan�amento cont�bil paras exclus�o da Nota Fiscalde Saida.
	If ! Empty(SF2->F2_DTLANC) .And. cPaisLoc =='BRA' .And. lLancPad .And. CanProcItvl(SF2->F2_DTLANC, SF2->F2_DTLANC,cFilAnt,cFilAnt,"MATA920")

		//encontra o numero do lote
		If SX5->( DbSeek(xFilial('SX5') + '09' + 'FIS'))
			cLoteCtb	:= StrZero(INT(Val(X5Descri()) + 1), 4)
		Else
			cLoteCtb	:= '0001'
		EndIf

		//Inicializa o arquivo de contabiliza��o
		nHldPrv	:= HeadProva( cLoteCtb, 'MATA920', cUserName, @cArqCtb )
		If nHldPrv <= 0
			Help('', 1, 'SEM_LANC')
		EndIf

		aAdd(aFlagCTB,{"F2_DTLANC",dDatabase,"SF2",SF2->(Recno()),0,0,0})

		//Contabiliza��o do lan�amento de exclus�o da nota
		nTotalCtb += DetProva( nHldPrv, cLancPad, 'MATA920', cLoteCtb,,,,,@cAuxCod, @aRecOri,,@aFlagCTB)

		//Envia a contabiliza��o do lan�amento de exclus�o da nota.
		If nTotalCtb > 0
			RodaProva( nHldPrv, nTotalCtb)
			cA100Incl( cArqCtb, nHldPrv, 1, cLoteCtb, lExibCtb, .F.,,,,aFlagCTB)
		EndIf
		FreeProcItvl("MATA920")
	
	EndIf

	//������������������������������������������������Ŀ
	//� Itens das NF's de Saida.                       �
	//��������������������������������������������������
	dbSelectArea("SD2")
	dbSetOrder(3)
	MsSeek(xFilial()+c920Nota+c920Serie+c920Client+c920Loja)

	While !Eof() .And. D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA == ;
			xFilial()+c920Nota+c920Serie+c920Client+c920Loja
			
		
		//Faz chamada para exclus�o dos tributos gen�ricos.
		IF lTrbGen .AND. !Empty(SD2->D2_IDTRIB)
			MaFisTG(2,,,SD2->D2_IDTRIB)
		EndIF

		RecLock("SD2",.F.,.T.)
		dbDelete()
		dbSkip()
		If Type("l920Auto") != "L" .or. !l920Auto
			IncProc()
		EndIf
	End
	SD2->(FKCommit())

	dbSelectArea("SF2")
	dbSetOrder(1)
	MsSeek(xFilial()+c920Nota+c920Serie+c920Client+c920Loja)

	//����������������������������������������������������������Ŀ
	//� Apaga arquivo de Livros Fiscais (SF3)                    �
	//������������������������������������������������������������
	MaFisAtuSF3(2,"S",SF2->(RecNo()))
	
	//��������������������������������������������������������������Ŀ
	//� Exclui a amarracao com os conhecimentos                      �
	//����������������������������������������������������������������
	MsDocument( "SF2", SF2->( RecNo() ), 2, , 3 )

	//������������������������������������������������Ŀ
	//� Cabecalho das notas de entrada.                �
	//��������������������������������������������������
	dbSelectArea("SF2")
	RecLock("SF2",.F.,.T.)
	dbDelete()

	If Type("l920Auto") != "L" .or. !l920Auto
		IncProc()
	EndIf
EndIf	

Return .T.
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A920VlNfLote � Autor � Andreia dos Santos� Data � 15/02/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida a Digitacao do numero da Nota Fiscal de Lote        ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA920 (Nf Lote)                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
FUNCTION A920VlNfLote(cSerie,cNtIni,cNtFim,cEspecie,dDataEmis)

Local lRet		:=	.t.
Local cSavAlias:=	Alias()
Local nSavOrd	:=	IndexOrd()
Local nSavRec	:=	Recno()
Local cNFiscal	:=	''
Local nNota
Local cNotaSeek
Local cSerId		:= ""

cNfiscal	:=	IIf(Empty(cNtFim),cNtIni,cNtFim)

//�����������������������������������Ŀ
//� Id da serie para compor as chaves �
//�������������������������������������				
If SerieNfID("SF3",3,"F3_SERIE") == "F3_SDOC"
	cSerId := Substr(cSerie,1,3) + StrZero(Month(dDataEmis),2) + Str(Year(dDataEmis),4) + AllTrim(cEspecie)
Else
	cSerId := Substr(cSerie,1,3)
EndIf

dbSelectArea('SF3')
dbSetOrder(5)
Set Filter to substr(F3_CFO,1,1)>='5'
MsSeek(xFilial()+cSerId+cNFiscal,.T.)

While lRet
	If xFilial()+cSerId+cNFiscal==F3_FILIAL+F3_SERIE+F3_NFISCAL .And. Empty(F3_DTCANC)
		HELP(" ",1,"A920NFLOTE")
		lRet:=.f.
		Loop
	Endif
	If F3_TIPO=='L' .and. F3_SERIE==cSerId .and. ;
			Val(F3_NFISCAL)<=Val(cNfiscal) .and. Val(F3_DOCOR)>=Val(cNfiscal)  .And. Empty(F3_DTCANC)
		HELP(" ",1,"A920NFLOTE")		
		lRet:=.f.
		Loop
	Endif
	dbSkip(-1)
	If F3_TIPO=='L' .and. F3_SERIE==cSerId .and. ;
			Val(F3_NFISCAL)<=Val(cNfiscal) .and. Val(F3_DOCOR)>=Val(cNfiscal)  .And. Empty(F3_DTCANC)
		HELP(" ",1,"A920NFLOTE")
		lRet:=.f.
		Loop
	Endif
	If !Empty(cNtFim)
		cNotaSeek:=cNFiscal
		For nNota:=Val(cNtIni) to Val(cNtFim)
			cNotaSeek:=StrTran(cNFiscal,Alltrim(Str(Val(cNFiscal))),Alltrim(Str(nNota)))
			cNotaSeek:=Padr(cNotaSeek,6)
			If MsSeek(xFilial()+cSerId+cNotaSeek,.F.)
				If Empty(F3_DTCANC)
					HELP(" ",1,"A920NFLOTE")
					lRet:=.f.
					Exit
				Endif	
			Endif
		Next
	Endif
	Exit
End

dbClearFilter()
dbSelectArea(cSavAlias)
dbSetOrder(nSavOrd)
dbGoto(nSavRec)

Return (lRet)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA920   �Autor  �Andreia dos Santos  � Data �  15/02/00   ���
�������������������������������������������������������������������������͹��
���Desc.     � Validacao dos gets do cabecalho da nota fiscal em lote     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Mata920                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A920CbLot(oNFIni,oNFFim,oEmis,oClie,oLoja)
Local lRet 	:= .F.

Do Case
Case Empty(c920NFIni)
	oNFIni:SetFocus()
Case Empty(c920NFFim)
	oNFFim:SetFocus()
Case Empty(d920Emis)
	oEmis:SetFocus()
Case Empty(c920Client)
	oClie:SetFocus()
Case Empty(c920Loja)
	oLoja:SetFocus()
OtherWise
	If !MaFisFound("NF")
		MaFisIni(c920Client,c920Loja,"C","N",SA1->A1_TIPO,MaFisRelImp("MT100",{"SF2","SD2"}),,.T.,,,,,,,,,,,,,,,,,,,,,,,,,IIf(FindFunction("ChkTrbGen"), ChkTrbGen("SD2","D2_IDTRIB"), .F.))
	EndIf
	lRet := .T.

EndCase

Return lRet
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o    �A920Total� Autor � Andreia dos Santos    � Data �16.02.2000���
������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do valor total digitado                         ���
������������������������������������������������������������������������Ĵ��
��� Uso      � Dicionario de Dados - Campo:D2_TOTAL                      ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/
Function A920Total(nTotal)

Local aArea		:= GetArea()
Local nQuant	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_QUANT"})]
Local nPreco	:= aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_PRCVEN"})]
Local cTes		:= ""
Local nDesc		:= aScan(aHeader,{|x| AllTrim(x[2]) == "D2_DESC"})
Local lRet 		:= .T.
Local nDif		:= NoRound(nQuant*nPreco,2)-nTotal
Local cReadVar  := ReadVar()
Local nx

If ( Type("lLocxAuto") <> "U" .AND. lLocxAuto ) .And. cPaisLoc == "COL" .And. Empty(aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"})])
	MaFisRef("IT_PRODUTO","MT100",M->D2_COD)
EndIf

cTes := aCols[n][aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TES"})]

If MaTesSel(cTes)	.And.	nQuant == 0
	If nPreco <> nTotal
		Help(" ",1,"A12003")
		lRet := .F.
	Endif
Else
	If nDif < 0
		nDif := -(nDif)
	EndIf
    
	If cPaisLoc=="BRA"
		If cTipo$'NDB' .And.nDif > 0.09
			Help(" ",1,"A12003")
			lRet := .F.
		EndIf
	Else
		If "D2_TOTAL"$cReadVar
			If nTotal <> a410Arred(nQuant*nPreco,"D2_TOTAL")
				Help(" ",1,"TOTAL")
				lRet := .F.
			EndIf			
		EndIf
	Endif 
Endif

If lRet .And. cPaisLoc<>"BRA"
	If nDesc>0
		aCols[n][nDesc]:=0
		MaFisAlt("IT_DESCONTO",0,n)
	Endif
Endif

RestArea(aArea)
Return lRet
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920Combo�Autor� Edson Maricate           � Data �06.01.2000���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida o Combo Box e inicializa a variavel correspondente.  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1	: Variavel a ser atualizada                          ���
���          �ExpA2	: Array contendo as opcoes do Combo                  ���
���          �ExpC3	: Opcao selecionada no Combo                         ���
���          �ExpA4	: Array contendo as referencias das opcoes do combo  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA103                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A920Combo(cVariavel,aCombo,cCombo,aReferencia)

Local nPos	:= aScan(aCombo,cCombo)

If nPos > 0
	cVariavel	:= aReferencia[nPos]
EndIf

Return (nPos>0)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920IniCpo� Autor � Edson Maricate        � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Inicializa campos com informacoes do produto               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA920 : Validacao do Campo D2_COD                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A920IniCpo(lDo)

Local aArea		:= GetArea()
Local nPosCod 		:= aScan(aHeader,{|x| Trim(x[2])=='D2_COD'} )
Local nPosUM		:= aScan(aHeader,{|x| Trim(x[2])=='D2_UM'} )
Local nPosSegUM		:= aScan(aHeader,{|x| Trim(x[2])=='D2_SEGUM'} )
Local nPosQTSegum	:= aScan(aHeader,{|x| Trim(x[2])=='D2_QTSEGUM'} )
Local nPosConta 	:= aScan(aHeader,{|x| Trim(x[2])=='D2_CONTA'} )
Local nPosLocal		:= aScan(aHeader,{|x| Trim(x[2])=='D2_LOCAL'} )
Local nPosTes		:= aScan(aHeader,{|x| Trim(x[2])=='D2_TES'} )
Local nPCodISS		:= aScan(aHeader,{|x| Trim(x[2])=='D2_CODISS'} )
Local nPPrcVen		:= aScan(aHeader,{|x| Trim(x[2])=='D2_PRCVEN' } )
Local nPPrcTab		:= aScan(aHeader,{|x| Trim(x[2])=='D2_PRUNIT' } )
Local nPQtdVen			:= aScan(aHeader,{|x| Trim(x[2])=='D2_QUANT' } )

Default lDo := .T.

If MaFisFound("IT",n)
	If ( cPaisLoc <> "BRA" ) .And. FunName() == "MATA467N" .And. ( !Empty(M->F2_TABELA) )
    	dbSelectArea("SB1")
		dbSetOrder(1)		
		MsSeek(xFilial()+aCols[n][nPosCod])
	
		aCols[n][nPosUM]		:= SB1->B1_UM
		aCols[n][nPosSegUM]		:= SB1->B1_SEGUM
		aCols[n][nPosConta]		:= SB1->B1_CONTA
		aCols[n][nPosLocal]		:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
		If ( nPosQtSegum > 0 )
			aCols[n][nPosQtSegum]	:= 0
		EndIf
		If ( nPosTes > 0 )
			aCols[n][nPosTes]	:= If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),aCols[n][nPosTes])
			MaFisAlt("IT_TES",aCols[n][nPosTes],n)
			Eval(bListRefresh)
		EndIf
		
    	#IFDEF TOP    	
	    	cAliasDA1 := GetNextAlias()
	
	    	dbSelectArea("DA1")
			dbSetOrder(1)
			cQuery    := ""
			cQuery += "SELECT " 
			cQuery += " * "
			cQuery += "FROM "+RetSqlName("DA1")+ " DA1 "
			cQuery += "WHERE "
			cQuery += "( DA1.DA1_DATVIG <= '"+ DtoS(M->F2_EMISSAO) + "' OR DA1.DA1_DATVIG = '"+Dtos(Ctod("//"))+ "' ) "
			cQuery += "AND DA1.DA1_FILIAL = '"+xFilial("DA1")+"' AND "
			cQuery +=     "DA1.DA1_CODTAB = '"+M->F2_TABELA+"' AND "
			cQuery +=     "DA1.DA1_CODPRO = '"+aCols[n][nPosCod]+"' AND "
			cQuery +=     "DA1.DA1_QTDLOT >= "+Str(aCols[n][nPQtdVen],18,8)+" AND "
			cQuery +=     "DA1.DA1_ATIVO = '1' AND  "
			cQuery +=     "DA1.D_E_L_E_T_ = ' ' "
			
			cQuery += "ORDER BY DA1.DA1_QTDLOT DESC ,DA1.DA1_DATVIG DESC ,"+SqlOrder(DA1->(IndexKey()))
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasDA1,.T.,.T.)
			
		   	If ( nPPrcVen > 0 )
				aCols[n][nPPrcVen]	:= xMoeda((cAliasDA1)->DA1_PRCVEN,(cAliasDA1)->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			Endif
			If ( nPPrcTab > 0 )
			  	aCols[n][nPPrcTab]	:= xMoeda((cAliasDA1)->DA1_PRCVEN,(cAliasDA1)->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			  	MaFisAlt("IT_PRCUNI",aCols[n][nPPrcTab],n)
			Endif
		#ELSE			
    	
	    	dbSelectArea("DA1")
			dbSetOrder(1)
			If ( MsSeek(xFilial("DA1")+M->F2_TABELA+aCols[n][nPosCod]) )
		        If ( nPPrcVen > 0 )
					aCols[n][nPPrcVen]	:= xMoeda(DA1->DA1_PRCVEN,DA1->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			    Endif
			    If ( nPPrcTab > 0 )
			    	aCols[n][nPPrcTab]	:= xMoeda(DA1->DA1_PRCVEN,DA1->DA1_MOEDA,M->F2_MOEDA,dDataBase,,,M->F2_TXMOEDA)
			    Endif
			Endif
		#ENDIF
	Else
		dbSelectArea("SB1") 
		
		dbSetOrder(1)
		MsSeek(xFilial()+aCols[n][nPosCod])	
	
		aCols[n][nPosUM]	:= SB1->B1_UM
		
 		If nPosSegUM <> 0
		aCols[n][nPosSegUM]	:= SB1->B1_SEGUM
		EndIF             
		
		If nPosConta <> 0
		aCols[n][nPosConta]	:= SB1->B1_CONTA    
		EndIF           
			
		aCols[n][nPosLocal]	:= RetFldProd(SB1->B1_COD,"B1_LOCPAD")
		If ( nPosQtSegum > 0 )
			aCols[n][nPosQtSegum]	:= 0
		EndIf
		If ( nPPrcTab > 0 )
			aCols[n][nPPrcTab] := SB1->B1_PRV1
		EndIf
		If nPCodISS <> 0
			aCols[n][nPCodISS] :=  MaSBCampo("CODISS") 
			MaFisAlt("IT_CODISS", MaSBCampo("CODISS"),N)
		EndIf
		a100SegUM()

		If nPosTes > 0
			aCols[n][nPosTes]	:= If(!Empty(RetFldProd(SB1->B1_COD,"B1_TS")),RetFldProd(SB1->B1_COD,"B1_TS"),aCols[n][nPosTes])
			If  !(cPaisLoc == "ARG" .and. Type("lLocxAuto") <> "U" .and. lLocxAuto)
				MaFisAlt("IT_TES",aCols[n][nPosTes],n)
				Eval(bListRefresh)
			EndIf
		EndIf
	Endif	
EndIf	

If ( cPaisLoc <> "BRA" )
	If ( Type("oGetDados")<>"U" )
		oGetDados:oBrowse:NAT := N
		oGetDados:oBrowse:Refresh()
	Endif
	if lDo
		MaColsToFis(aHeader,aCols,n,"MT100",.T.,.F.,.T.)
		Eval(bDoRefresh)
	EndIf
Endif

RestArea(aArea)

Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920Financ� Autor �  Edson Maricate       � Data �18.03.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Monta a tela de dados contabeis/financeiros.               ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA920                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A920Financ(cCondicao,oDlg,aRecSE1,aRecSE2,nPosX)

Local aMoeda	 := {}
Local aTemp		 := {{"","","",CTOD("  /  /  "),0}} 
Local cMoeda     := ""
Local cDescri 	 := CriaVar("E4_DESCRI")
Local cNatureza	 := CriaVar("E1_NATUREZ")
Local dDatCont	 := dDataBase
Local nX         := 0
Local nBaseDup   := 0
Local nMoedaCor  := 0
Local oList
Local oMoeda
Local oNatu
Local oDescri
Local oCond
Local lDoVisual	 := .F.
Local A920SE1ADC := ExistBlock("A920SE1ADC") //Ponto de Entrada para incluir campos na consulta de duplicatas
Local aA920SE1ADC    
//������������������������������������������������������Ŀ
//� Monta o array com as duplicatas qdo. for visual      �
//��������������������������������������������������������
dbSelectArea("SE4")
dbSetOrder(1)
If MsSeek(xFilial()+cCondicao)
	cDescri := SE4->E4_DESCRI
EndIf
dbSelectArea("SE1")
If !Empty(aRecSE1)
	aTemp := {}
	For nx := 1 to Len(aRecSE1)
		dbGoto(aRecSE1[nx])          
		//���������������������������������������������������������Ŀ
		//� Considera os titulos tambem quando forem do SIGALOJA:	�
		//� LOJA701 - LOJA010 - FATA701 						 	�
		//�����������������������������������������������������������
		If SE1->E1_TIPO $ MVNOTAFIS .OR. "LOJA" $ E1_ORIGEM .OR. "FATA701" $ E1_ORIGEM .OR. !Empty(SE1->E1_PREFORI)
			cNatureza := SE1->E1_NATUREZ
			nMoedaCor := SE1->E1_MOEDA                                         
            If A920SE1ADC
   			   aA920SE1ADC := AClone(ExecBlock("A920SE1ADC",.F.,.F.,{"SE1"})) 
   			   aAdd(aTemp,aA920SE1ADC[3]) 
   			Else   
  			   aAdd(aTemp,{E1_NUM,E1_PREFIXO,E1_PARCELA,E1_VENCTO,E1_VALOR}) 
            Endif							
		EndIf
	Next nX
	If Empty(aTemp)
		aTemp := {{"","","",CTOD("  /  /  "),0}}
	EndIf
EndIf
dbSelectArea("SE2")
If !Empty(aRecSE2)
	aTemp := {}
	For nx	:= 1 to Len(aRecSE2)
		dbGoto(aRecSE2[nx])          
		//������������������������������������������������������Ŀ
		//� Considera os titulos tambem quando forem do SIGALOJA �
		//��������������������������������������������������������
		If SE2->E2_TIPO $ MV_CPNEG
			cNatureza    := SE2->E2_NATUREZ
			nMoedaCor	:= SE2->E2_MOEDA
			aAdd(aTemp,{E2_NUM,E2_PREFIXO,E2_PARCELA,E2_VENCTO,E2_VALOR})
		EndIf
	Next nX
	If Empty(aTemp)
		aTemp	:= {{"","","",CTOD("  /  /  "),0}}
	EndIf
EndIf
//������������������������������������������������������Ŀ
//� Monta o Array contendo as moedas do sistema          �
//��������������������������������������������������������
For nx := 1 to ContaMoeda()
	aADD(aMoeda,Alltrim(STR(nx,3))+":"+GetMv("MV_MOEDA"+Alltrim(STR(nx,3))))
	If nx == nMoedaCor
		cMoeda	:= aMoeda[nMoedaCor]
	EndIf
Next

@ 5,4     SAY STR0056 Of oDlg PIXEL SIZE 39 ,9 //"Condicao"
@ 4,31    MSGET oCond VAR cCondicao  Picture PesqPict('SF2','F2_COND') When .F.	OF oDlg PIXEL SIZE 22 ,9

@ 19 ,4   SAY STR0057 Of oDlg PIXEL SIZE 19 ,9  //"Descr."
@ 18 ,31  MSGET oDescri VAR cDescri  Picture PesqPict('SE4','E4_DESCRI') When .F. OF oDlg PIXEL SIZE 54 ,9

@ 33 ,4   SAY STR0058 Of oDlg PIXEL SIZE 41 ,9 //"Natureza"
@ 33 ,31  MSGET oNatu VAR cNatureza  Picture PesqPict('SE2','E2_NATUREZ') When .F. OF oDlg PIXEL SIZE 54,9

@ 48 ,4   SAY STR0059 Of oDlg PIXEL SIZE 30 ,9  //"Moeda"
@ 47 ,31  MSCOMBOBOX oMoeda VAR cMoeda ITEMS aMoeda  When .F. SIZE 54 ,50 OF oDlg PIXEL

If A920SE1ADC
   oList:= TWBrowse():New( 5,89,nPosX,53,,aA920SE1ADC[1],aA920SE1ADC[2],oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) 
   oList:SetArray(aTemp)
   oList:bLine := {|| A920Line(oList,aTemp,aA920SE1ADC[4])}
Else
   oList:= TWBrowse():New( 5,89,nPosX,53,,{STR0060,STR0061,STR0062,STR0063,STR0064},{35,35,20,35,60},oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,) //"Numero"###"Prefixo"###"Parc."###"Vencto"###"Valor"
   oList:SetArray(aTemp)
   oList:bLine := {|| A920Line(oList,aTemp,{"E1_NUM","E1_PREFIXO","E1_PARCELA","E1_VENCTO","E1_VALOR"})}
Endif

Return oList

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920Line� Autor �  Edson Maricate         � Data �18.03.1999���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Atualiza a linha de tela de dados Financeiros              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATA920                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A920Line(oList,aTemp,aCpos)
Local i    := 1
Local aRet := {}
for i:=1 to len(aTemp[1])
    aadd(aRet,TransForm(aTemp[oList:nAt][i],PesqPict("SE1",aCpos[i])))
end   
Return aRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �A920Pedido� Autor � Edson Maricate        � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Programa para consulta ao anexos da Nota Fiscal             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e �Void A920Pedido(ExpN1,ExpA2)                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Tipo de Consulta                                   ���
���          �         [1] Pedido de Venda                                ���
���          � ExpA2 = Array com os Pedidos de Venda                      ���
���          � ExpC3 = Texto a ser exibido em tela                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A920Pedido(nTipo,aPedido,cTexto)

Local aArea      := GetArea()
Local aSavHead   := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local aRecNo     := {}
Local nSavN      := N
Local nUsado     := 0
Local nX         := 0
Local nY         := 0
Local oDlg
Local oGetDad
Local oBtn

Local aSX3Fields := {}

Private aHeader := {}
Private aCols   := {}
Private N		:= 1

Do Case
Case ( nTipo == 1 )
	If ( Len(aPedido) > 1 )
		aSX3Fields := FWSX3Util():GetAllFields( "SC5" , .T. )

		For nX := 1 To Len( aSX3Fields )
			If GetSx3Cache( aSX3Fields[nX], "X3_BROWSE" ) == "S"
				Aadd(aHeader,{ AllTrim( FWX3Titulo( aSX3Fields[nX] ) ),;
					aSX3Fields[nX],;
					GetSx3Cache( aSX3Fields[nX], "X3_PICTURE" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_TAMANHO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_DECIMAL" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_VALID" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_USADO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_TIPO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_ARQUIVO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_CONTEXT" ) } )
				nUsado++
			EndIf
		Next

		For nX := 1 To Len(aPedido)
			dbSelectArea("SC5")
			dbSetOrder(1)
			MsSeek(xFilial("SC5")+aPedido[nX])
			aadd(aRecNo,RecNo())
			aadd(aCols,Array(nUsado))
			For nY := 1 To Len(aHeader)
				If ( aHeader[nY][10] != "V" )
					aCols[Len(aCols)][nY] := FieldGet(FieldPos(aHeader[nY][2]))
				Else
					aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2],.T.)
				EndIf
			Next nY
		Next nX
		DEFINE MSDIALOG oDlg FROM	09,0 TO 28,80 TITLE STR0065 OF oMainWnd  //"Pedidos"
		@ 001,002 TO 031,267 OF oDlg	PIXEL
		@ 015,005 SAY STR0066 SIZE 020,009 OF oDlg PIXEL  //"N.Fiscal :"
		@ 015,030 SAY cTexto             SIZE 150,009 OF oDlg PIXEL
		oGetDad := MsGetDados():New(035,002,135,315,2)
		DEFINE SBUTTON 		FROM 005,280 TYPE 1  ENABLE OF oDlg ACTION ( oDlg:End() )
		DEFINE SBUTTON oBtn FROM 020,280 TYPE 15 ENABLE OF oDlg ACTION ( oGetDad:oBrowse:lDisablePaint:=.T.,A920Mostra(1,aRecNo[N]),oGetDad:oBrowse:lDisablePaint:=.F. )
		oBtn:lAutDisable := .F.
		ACTIVATE MSDIALOG oDlg
	Else
		dbSelectArea("SC5")
		dbSetOrder(1)
		MsSeek(xFilial("SC5")+aPedido[1])
		A920Mostra(1,RecNo())
	EndIf
Otherwise
	Alert(STR0067)	 //"Opcao nao disponivel"
EndCase

N       := nSavN
aCols   := aClone(aSavCols)
aHeader := aClone(aSavHead)

RestArea(aArea)
Return(.T.)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A920Mostra� Autor � Edson Maricate       � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de detalhamento da consulta aos anexos da NFS     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Void  A920Mostra(ExpN1)                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Tipo de Consulta                                   ���
���          �         [1] Pedido de Venda                                ���
���          � ExpN2 = Nr do Registro                                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function A920Mostra(nTipo,nRecNo)

Local aArea := GetArea()
Local aSavHead   := aClone(aHeader)
Local aSavCols   := aClone(aCols)
Local nSavN      := N
Private N        := 1
Do Case
Case ( nTipo == 1 )
	dbSelectArea("SC5")
	dbSetOrder(1)
	MsGoto(nRecNo)	
	A410Visual("SC5",nRecNo,2)
EndCase
N       := nSavN
aCols   := aClone(aSavCols)
aHeader := aClone(aSavHead)
RestArea(aArea)
Return(.T.)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A920Track � Autor � Sergio Silveira       � Data �03/01/2002���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Faz o tratamento da chamada do System Tracker              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function A920Track()

Local aEnt     := {}
Local cKey     := c920Nota + c920Serie + c920Client + c920Loja
Local nPosItem := GDFieldPos( "D2_ITEM" )
Local nPosCod  := GDFieldPos( "D2_COD"  )
Local nLoop    := 0

//���������������������������������������������Ŀ
//�Inicializa a funcao fiscal                   �
//�����������������������������������������������
For nLoop := 1 To Len( aCols )
	If !Empty(aRemito[nLoop][1])
		AAdd( aEnt, { "SD2", aRemito[nLoop][1]+aRemito[nLoop][2]+ c920Client + c920Loja + aCols[ nLoop, nPosCod ] + aRemito[ nLoop, 3 ] } )
	Else
		AAdd( aEnt, { "SD2", cKey + aCols[ nLoop, nPosCod ] + aCols[ nLoop, nPosItem ] } )
	Endif
Next nLoop

MaTrkShow( aEnt )

Return( .T. )
/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �MyMata920 � Autor � Eduardo Riera         � Data �17.12.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Rotina de teste da rotina automatica do programa MATA920     ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                       ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo efetuar testes na rotina de    ���
���          �documento de entrada                                         ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
main Function MyMata920()

Local aCabec := {}
Local aItens := {}
Local aLinha := {}
Local nX     := 0
Local nY     := 0
Local cDoc   := ""
Local lOk    := .T.
PRIVATE lMsErroAuto := .F.
//��������������������������������������������������������������Ŀ
//| Abertura do ambiente                                         |
//����������������������������������������������������������������
ConOut(Repl("-",80))
ConOut(PadC("Teste de Inclusao de 10 documentos de entrada com 30 itens cada",80))
PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FIS" TABLES "SF2","SD2","SA1","SA2","SB1","SB2","SF4"
//��������������������������������������������������������������Ŀ
//| Verificacao do ambiente para teste                           |
//����������������������������������������������������������������
dbSelectArea("SB1")
dbSetOrder(1)
If !SB1->(MsSeek(xFilial("SB1")+"PA001"))
	lOk := .F.
	ConOut("Cadastrar produto: PA001")
EndIf
dbSelectArea("SF4")
dbSetOrder(1)
If !SF4->(MsSeek(xFilial("SF4")+"501"))
	lOk := .F.
	ConOut("Cadastrar TES: 501")
EndIf
dbSelectArea("SE4")
dbSetOrder(1)
If !SE4->(MsSeek(xFilial("SE4")+"001"))
	lOk := .F.
	ConOut("Cadastrar condicao de pagamento: 001")
EndIf
dbSelectArea("SA1")
dbSetOrder(1)
If !SA1->(MsSeek(xFilial("SA1")+"CL000101"))
	lOk := .F.
	ConOut("Cadastrar cliente: CL000101")
EndIf
If lOk
	ConOut("Inicio: "+Time())
	//��������������������������������������������������������������Ŀ
	//| Verifica o ultimo documento valido para um fornecedor        |
	//����������������������������������������������������������������
	dbSelectArea("SF2")
	dbSetOrder(2)
	MsSeek(xFilial("SF2")+"CL000101z",.T.)
	dbSkip(-1)
	cDoc := SF2->F2_DOC
	For nY := 1 To 10
		aCabec := {}
		aItens := {}

		If Empty(cDoc)
			cDoc := StrZero(1,Len(SD2->D2_DOC))
		Else
			cDoc := Soma1(cDoc)
		EndIf
		aadd(aCabec,{"F2_TIPO"   ,"N"})
		aadd(aCabec,{"F2_FORMUL" ,"N"})
		aadd(aCabec,{"F2_DOC"    ,(cDoc)})
		aadd(aCabec,{"F2_SERIE"  ,"UNI"})
		aadd(aCabec,{"F2_EMISSAO",dDataBase})
		aadd(aCabec,{"F2_CLIENTE","CL0001"})
		aadd(aCabec,{"F2_LOJA"   ,"01"})
		aadd(aCabec,{"F2_ESPECIE","NF"})
		aadd(aCabec,{"F2_COND","001"})
		aadd(aCabec,{"F2_DESCONT",0})
		aadd(aCabec,{"F2_FRETE",0})
		aadd(aCabec,{"F2_SEGURO",0})
		aadd(aCabec,{"F2_DESPESA",0})
		If cPaisLoc == "PTG"         
			aadd(aCabec,{"F2_DESNTRB",0})
			aadd(aCabec,{"F2_TARA",0})
		Endif
		For nX := 1 To 30
			aLinha := {}
			aadd(aLinha,{"D2_COD"  ,"PA001",Nil})
			aadd(aLinha,{"D2_QUANT",1,Nil})
			aadd(aLinha,{"D2_PRCVEN",100,Nil})
			aadd(aLinha,{"D2_TOTAL",100,Nil})
			aadd(aLinha,{"D2_TES","501",Nil})
			aadd(aItens,aLinha)
		Next nX
		//��������������������������������������������������������������Ŀ
		//| Teste de Inclusao                                            |
		//����������������������������������������������������������������
		MATA920(aCabec,aItens)
		If !lMsErroAuto
			ConOut("Incluido com sucesso! "+cDoc)	
		Else
			ConOut("Erro na inclusao!")
		EndIf
	Next nY
	ConOut("Fim  : "+Time())
	//��������������������������������������������������������������Ŀ
	//| Teste de exclusao                                            |
	//����������������������������������������������������������������
	aCabec := {}
	aItens := {}
	aadd(aCabec,{"F2_TIPO"   ,"N"})
	aadd(aCabec,{"F2_FORMUL" ,"N"})
	aadd(aCabec,{"F2_DOC"    ,(cDoc)})
	aadd(aCabec,{"F2_SERIE"  ,"UNI"})
	aadd(aCabec,{"F2_EMISSAO",dDataBase})
	aadd(aCabec,{"F2_FORNECE","F00001"})
	aadd(aCabec,{"F2_LOJA"   ,"01"})
	aadd(aCabec,{"F2_ESPECIE","NFE"})
	aadd(aCabec,{"F2_DESCONT",0})
	aadd(aCabec,{"F2_FRETE",10})
	aadd(aCabec,{"F2_SEGURO",20})
	aadd(aCabec,{"F2_DESPESA",30})
	If cPaisLoc == "PTG"          
		aadd(aCabec,{"F2_DESNTRB",40})
		aadd(aCabec,{"F2_TARA",50})
	Endif
	For nX := 1 To 30
		aLinha := {}
		aadd(aLinha,{"D2_ITEM",StrZero(nX,Len(SD2->D2_ITEM)),Nil})
		aadd(aLinha,{"D2_COD","PA002",Nil})
		aadd(aLinha,{"D2_QUANT",2,Nil})
		aadd(aLinha,{"D2_PRCVEN",100,Nil})
		aadd(aLinha,{"D2_TOTAL",200,Nil})
		aadd(aItens,aLinha)
	Next nX
	//��������������������������������������������������������������Ŀ
	//| Teste de Exclusao                                            |
	//����������������������������������������������������������������
	ConOut(PadC("Teste de exclusao",80))
	ConOut("Inicio: "+Time())
	MATA920(aCabec,aItens,5)
	If !lMsErroAuto
		ConOut("Exclusao com sucesso! "+cDoc)	
	Else
		ConOut("Erro na exclusao!")
	EndIf
	ConOut("Fim  : "+Time())
	ConOut(Repl("-",80))
EndIf
RESET ENVIRONMENT
Return(.T.)

Static Function ProcH(cCampo)
Return aScan(aAutoCab,{|x|Trim(x[1])== cCampo })  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A920Conhec� Autor �Sergio Silveira        � Data �15/08/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada da visualizacao do banco de conhecimento            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A920Conhec()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function A920Conhec() 

Local aRotBack := AClone( aRotina ) 
Local nBack    := N

Private aRotina := {}

Aadd(aRotina,{STR0073,"MsDocument", 0 , 2,0,NIL}) //"Banco de Conhecimento"

MsDocument( "SF2", SF2->( Recno() ), 1 ) 

aRotina := AClone( aRotBack ) 
N := nBack 

Return( .t. ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A920Docume� Autor �Sergio Silveira        � Data �15/08/2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Chamada da rotina de amarracao do banco de conhecimento     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ExpX1 := A920Docume()                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpX1 -> Retorno da funcao MsDocument                       ���
�������������������������������������������������������������������������Ĵ��
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function A920Docume( cAlias, nRec, nOpc ) 

Local aArea    := GetArea() 
Local xRet   

SD2->( MsGoto( nRec ) ) 

//��������������������������������������������������������������Ŀ
//| Posiciona no SF2 a partir do SD2                             |
//����������������������������������������������������������������
SF2->( dbSetOrder( 1 ) )    

If SF2->( MsSeek( xFilial( "SF2" ) + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA + SD2->D2_FORMUL ) ) 
	xRet := MsDocument( "SF2", SF2->( Recno() ), nOpc ) 
EndIf	             

RestArea( aArea )
	
Return( xRet ) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A920NFe   � Autor �Mary C. Hergert        � Data �29/06/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Valida campos da Nota Fiscal Eletronica de Sao Paulo        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �A920NFe(cExp01,aExp01)                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cExp01: Campo a ser validado                                ���
���          �aExp01: Array com as variaveis de memoria                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A920NFe(cCampo,aNFEletr)

Local lRet := .T.

If cPaisLoc == "BRA"
	If cCampo == "EMINFE"    
		If !Empty(aNFEletr[03]) .And. aNFEletr[03] < d920Emis
			Help("",1,"A100NFEDT")	
			lRet := .F.
		Endif
	ElseIf cCampo == "CREDNFE"
		If aNFEletr[05] < 0
			Help("",1,"A100NFECR")	
			lRet := .F.
		Endif
	Endif
Endif

Return lRet

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
     
Private aRotina := {	{ STR0001	,"AxPesqui"	, 0 , 1 , 0 ,.F.},;		//"Pesquisar"
							{ STR0002 	,"a920NFSAI", 0 , 2 , 0 ,NIL},;	//"Visualizar"
							{ STR0003	,"a920NFSAI", 0 , 3 , 0 ,NIL},;	//"Incluir"
							{ STR0004   ,"a920NFSAI", 0 , 5 , 0 ,NIL},; 	//"Excluir"
							{ STR0036   ,"a920NFSAI", 0 , 3 , 0 ,NIL} }	//"NF Lote"         

Aadd(aRotina,{STR0075,"a920Docume", 0 , 4 , 0 , NIL}) //"Conhecimento" 
	
aAdd(aRotina,{ STR0085 ,"a920Compl", 0 , 4 , 0 , NIL}) //"Complementos"

aAdd(aRotina,{ STR0083 ,"ANFMLegenda", 0 , 2, 0, .F.}) // Legenda

If ExistBlock("MA920MNU")
	ExecBlock("MA920MNU",.F.,.F.)
EndIf

Return(aRotina)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �MaCols920 � Autor � Liber De Esteban      � Data � 22/01/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Montagem do aCols para GetDados.                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �MaCols920()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�-l920Inclui -> Identifica se operacao e inclusao.           ���
���          �-l920Altera -> Identifica se operacao e Alteracao.          ���
���          �-l920Deleta -> Identifica se operacao e delecao.            ���
���          �-lContinua -> Flag que identifica se deve continuar proc.   ���
���          �-aPedidos -> Array com os pedidos relacionados ao doc.      ���
���          �-aRecSE1 -> Array com os Recno's de SE1 relacionados ao doc.���
���          �-aRecSE2 -> Array com os Recno's de SE2 relacionados ao doc.���
���          �-aRecSF3 -> Array com os Recno's de SF3 relacionados ao doc.���
���          �-a920Var -> Array com os valores de impostos                ���
���          �-aTitles -> Array com os titulos das telas                  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � MATA920 - SIGAFIS                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function MaCols920(l920Inclui,l920Altera,l920Deleta,lContinua,aPedidos,aRecSE1,aRecSE2,aRecSF3,a920Var,aTitles)

Local nY, nX, nD2
Local nPosUni := 0
Local nPosDes := 0
Local nPosTot := 0
Local nPosQtd := 0

Local lQuery    := .F.
Local lMA920SD2 := .F.
Local lPE920SD2 := ExistBlock("MA920SD2")

Local cQuery    := ""
Local cRemito   := "SD2"
Local cSerie    := ""
Local cAliasSD2 := "SD2"
Local cAliasSE1 := "SE1"
Local cAliasSE2 := "SE2"
Local cAliasSF3 := "SF3"
Local cFilialTMS:= ""

Local aStruSD2  := {}
Local aAreaSD2  := {}
Local aCpoSD2   := {}
Local cSqlCons  := "" //Consulta dos tipos de t�tulos do loja
Local cAdsCons  := "" //Consulta dos tipos de t�tulos do Loja

Local aSeqNewHdr := {}
Local nPosCpo    := 0
Local aNewHeader := {}

Local lCmpExTot	 := .F.

If cPaisLoc == "BRA"
	//*********************************************************************************
	// Grupo de campos que deverao ser apresentados em ordem especifica (todos juntos)
	// sempre por ultimo no aCols, de forma a facilitar a digitacao do documento.
	//*********************************************************************************
	aSeqNewHdr := ({"D2_NFORI" ,;
				   "D2_SERIORI",;
				   "D2_ITEMORI",;
				   "D2_BASEICM",;
				   "D2_PICM"   ,;
				   "D2_VALICM" ,;
				   "D2_BRICMS" ,;
				   "D2_ICMSRET",;
				   "D2_BSFCPST",;
				   "D2_BASEDES",;
				   "D2_ICMSCOM",;
				   "D2_DIFAL"  ,;
				   "D2_ALFCCMP",;
				   "D2_VFCPDIF",;
				   "D2_BASEIPI",;
				   "D2_IPI"    ,;
				   "D2_VALIPI" ,;
				   "D2_ALI_WT" ,;
				   "D2_REC_WT" })

	If cPaisLoc == "BRA"
		For nX := 1 To Len(aSeqNewHdr)
			nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == aSeqNewHdr[nX]})
			If nPosCpo > 0
				aNewHeader := aClone(aHeader[nPosCpo])
				aDel(aHeader,nPosCpo)
				aSize(aHeader,Len(aHeader) - 1)
				aAdd(aHeader,aClone(aNewHeader))
			EndIf
		Next nX
	EndIf			   
		   
EndIf

If l920Inclui	
	aadd(aCols,Array(Len(aHeader)+1)) // Faz a montagem de uma linha em branco no aCols.
	For nY := 1 To Len(aHeader)
		If Trim(aHeader[nY][2]) == "D2_ITEM"
			aCols[1][nY] := StrZero(1,Len((cAliasSD2)->D2_ITEM))
		Else
			If AllTrim(aHeader[nY,2]) == "D2_ALI_WT"
				aCOLS[Len(aCols)][nY] := "SD2"
			ElseIf AllTrim(aHeader[nY,2]) == "D2_REC_WT"
				aCOLS[Len(aCols)][nY] := 0
			Else
				aCols[1][nY] := CriaVar(aHeader[nY][2])
			EndIf
		EndIf
		aCols[1][Len(aHeader)+1] := .F.
	Next nY
Else	
	If (l920Altera .Or. l920Deleta) .And. !SoftLock("SF2")//Trava os registros na alteracao e  exclusao
		lContinua := .F.
	EndIf
		
	#IFDEF TOP
		If TcSrvType() <> "AS/400" .And. Empty( AScan( aHeader, { |x| x[8] == "M" } ) )
			lQuery  := .T.

			If cPaisLoc <> "BRA"
				cRemito := GetNextAlias()
				ChkFile("SD2",.F.,cRemito)
			EndIf	
			
			aStruSD2 := SD2->(dbStruct())
			cQuery := "SELECT SD2.*,SD2.R_E_C_N_O_ SD2RECNO"
			cQuery += "FROM "+RetSqlName("SD2")+" SD2 "
			cQuery += "WHERE "
			cQuery += "D2_FILIAL  = '"+ xFilial("SD2") +"' AND "
			cQuery += "D2_DOC     = '"+ c920Nota       +"' AND "
			cQuery += "D2_SERIE   = '"+ c920Serie      +"' AND "
			cQuery += "D2_CLIENTE = '"+ c920Client     +"' AND "
			cQuery += "D2_LOJA    = '"+ c920Loja       +"' AND "
			cQuery += "SD2.D_E_L_E_T_ = ' '"
			cQuery += "ORDER BY SD2.R_E_C_N_O_"
			cQuery := ChangeQuery(cQuery)

			SD2->(dbCloseArea())

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.F.,.T.)

			For nX := 1 To Len(aStruSD2)
				If aStruSD2[nX][2] != "C"
					TcSetField(cAliasSD2,aStruSD2[nX][1],aStruSD2[nX][2],aStruSD2[nX][3],aStruSD2[nX][4])
				EndIf
			Next nX
		Else
	#ENDIF
			cAliasSD2 := "SD2"
			dbSelectArea("SD2")
			dbSetOrder(3)
			MsSeek(xFilial("SD2")+c920Nota+c920Serie+c920Client+c920Loja)
	#IFDEF TOP
		Endif
	#ENDIF

	If cPaisLoc != "BRA" .And. GetNewPar('MV_DESCSAI','1') == '2'
		nPosUni		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "D2_PRCVEN"})
		nPosDes		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "D2_DESCON"})
		nPosTot		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "D2_TOTAL" })
		nPosQtd		:= Ascan(aHeader, {|x| Alltrim(x[2]) == "D2_QUANT" })
		lCmpExTot 	:= ((nPosTot * nPosUni * nPosDes * nPosQtd) > 0)
	EndIf	

	While !Eof() .And. ;
		(cAliasSD2)->D2_FILIAL  == xFilial("SD2") .And. ;
		(cAliasSD2)->D2_DOC     == c920Nota       .And. ;
		(cAliasSD2)->D2_SERIE   == c920Serie      .And. ;
		(cAliasSD2)->D2_CLIENTE == c920Client     .And. ;
		(cAliasSD2)->D2_LOJA    == c920Loja

		If !Empty((cAliasSD2)->D2_PEDIDO) .And. (aScan(aPedidos,(cAliasSD2)->D2_PEDIDO)==0)
			Aadd(aPedidos,(cAliasSD2)->D2_PEDIDO)
		ElseIf cPaisLoc <> "BRA"
			If !Empty((cAliasSD2)->D2_REMITO)				
				If !lQuery // Salva Area do SD2 pois cRemito e cAliasSD2 possuem o mesmo Alias SD2.
					aAreaSD2 := SD2->(GetArea())
				EndIf
				dbSelectArea(cRemito)
				dbSetOrder(3)
				If MsSeek(xFilial("SD2")+(cAliasSD2)->D2_REMITO+(cAliasSD2)->D2_SERIREM +(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_ITEMREM)
					If !Empty((cRemito)->D2_PEDIDO) .And. Ascan(aPedidos,(cRemito)->D2_PEDIDO) == 0
						aadd(aPedidos,(cRemito)->D2_PEDIDO)
					EndIf
				EndIf
				If !lQuery
					RestArea(aAreaSD2)
				EndIf
				DbSelectArea(cAliasSD2)
			EndIf
		EndIf

		If lPE920SD2 .And. !lMA920SD2
			aCpoSD2 := ExecBlock("MA920SD2",.F.,.F.)
			For nD2 := 1 To Len(aCpoSD2)
				aadd(aHeader,Aclone(aHeader[len(aHeader)]))
				aHeader[Len(aHeader)][1] := aCpoSD2[nD2][1]
				aHeader[Len(aHeader)][2] := aCpoSD2[nD2][2]
				aHeader[Len(aHeader)][3] := aCpoSD2[nD2][3]
			Next
			lMA920SD2 := .T.
		Endif		

		aadd(aCols,Array(Len(aHeader)+1))
		Aadd(aRemito,{(cAliasSD2)->D2_REMITO,(cAliasSD2)->D2_SERIREM,(cAliasSD2)->D2_ITEMREM})
		For nY := 1 to Len(aHeader) //Faz a montagem do aCols com os dados do SD2
			If (aHeader[ny][10] != "V")
				aCols[Len(aCols)][nY] := FieldGet(FieldPos(aHeader[nY][2]))
			Else
				If AllTrim(aHeader[nY,2]) == "D2_ALI_WT"
					aCols[Len(aCols)][nY] := "SD2"
				ElseIf AllTrim(aHeader[nY,2]) == "D2_REC_WT"
					aCols[Len(aCols)][nY] := If(lQuery,(cAliasSD2)->SD2RECNO,(cAliasSD2)->(RecNo()))
				Else
					If lQuery
						dbSelectArea("SD2")
						SD2->(MsGoto((cAliasSD2)->SD2RECNO))
					EndIf
					aCols[Len(aCols)][nY] := CriaVar(aHeader[nY][2])
				EndIf
			EndIf
		Next nY

		aCols[Len(aCols)][Len(aHeader)+1] := .F.

		If lCmpExTot .And. aCols[Len(aCols)][nPosDes] > 0
			aCols[Len(aCols)][nPosTot] += aCols[Len(aCols)][nPosDes]
			aCols[Len(aCols)][nPosUni] := aCols[Len(aCols)][nPosTot] / aCols[Len(aCols)][nPosQtd]			
		Endif

		dbSelectArea(cAliasSD2)
		dbSkip()
	EndDo

	//Finaliza o arquivo da query e reabre o SD2
	If lQuery
		(cAliasSD2)->(dbCloseArea())
		If cPaisLoc <> "BRA"
			(cRemito)->(dbCloseArea())
			ChkFile("SD2",.F.)
		EndIf	
		dbSelectArea("SD2")
	EndIf

	MaFisIniNF(2,SF2->(RecNo()),,,.F.)	
	MaFisLoad("NF_VALMERC",SF2->F2_VALMERC)

	//Carega o Array contendo as Duplicatas a Receber (SE1)
	cSerie := If(Empty(SF2->F2_PREFIXO),&(GETMV("MV_1DUPREF")),SF2->F2_PREFIXO)
	cSerie := Padr(cSerie, TamSx3("E1_PREFIXO")[1])
	cSqlCons := ""
	cAdsCons := ""
	a920TpLjTit(@cSqlCons, @cAdsCons)
	If !SF2->F2_TIPO $ "DB"
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				lQuery    := .T.
				cAliasSE1 := "QRYSE1"
				cQuery := "SELECT SE1.R_E_C_N_O_ RECSE1,SE1.E1_FILIAL,SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_ORIGEM,SE1.E1_TIPO,SE1.E1_CLIENTE,SE1.E1_LOJA "
				cQuery += "FROM "+RetSqlName("SE1")+" SE1 "
				cQuery += "WHERE "
				cQuery += "E1_FILIAL = '"		+ xFilial("SE1")	+ "' AND "
				cQuery += "E1_PREFIXO = '"		+ cSerie			+ "' AND "
				cQuery += "E1_NUM = '"			+ SF2->F2_DOC		+ "' AND "
				cQuery += "((E1_CLIENTE = '"	+ SF2->F2_CLIENTE	+ "' AND "
				cQuery += "E1_LOJA = '"			+ SF2->F2_LOJA		+ "' AND "
				cQuery += "E1_TIPO = '"+MVNOTAFIS+"' ) OR "
				cQuery += "(E1_ORIGEM Like 'LOJA%' AND E1_TIPO IN ( " + cSqlCons + " )) "
				cQuery += " OR E1_ORIGEM = 'FATA701'"
				cQuery += " OR E1_PREFORI <> '   ')"
				cQuery += " AND "
				cQuery += "SE1.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE1,.F.,.T.)
			Else
		#ENDIF
				cAliasSE1 := "SE1"
				dbSelectArea("SE1")
				//Alterado o indice de busca, pois no SIGALOJA ao utilizar CC/CD/FI/VA/CO o cliente pode ser diferente da NF.
				//A validacao do cliente continua sendo feita atraves do Iif (se nao for SIGALOJA).
				dbSetOrder(1)
				MsSeek(xFilial()+cSerie+SF2->F2_DOC)
		#IFDEF TOP
			Endif
		#ENDIF

		While !Eof() .And. ;
			(lQuery  .Or.  ;
			((cAliasSE1)->E1_FILIAL == xFilial("SE1") .AND. ;
			(cAliasSE1)->E1_PREFIXO == cSerie         .AND. ;
			(cAliasSE1)->E1_NUM     == SF2->F2_DOC))

			If  ( (cAliasSE1)->E1_CLIENTE == SF2->F2_CLIENTE .And. (cAliasSE1)->E1_LOJA == SF2->F2_LOJA) .OR. ; 
				( (SubStr((cAliasSE1)->E1_ORIGEM, 1, 4) == "LOJA" .AND. AllTrim((cAliasSE1)->E1_TIPO) $ cAdsCons ) .OR. ;
				(  SubStr((cAliasSE1)->E1_ORIGEM, 1, 7) == "FATA701" ) )
				
				aAdd(aRecSE1,Iif(lQuery,(cAliasSE1)->RECSE1,SE1->(RecNo())))
			EndIf
			dbSkip()
		EndDo

		If lQuery
			dbSelectArea(cAliasSE1)
			dbCloseArea()
		EndIf

	Else
		#IFDEF TOP
			If TcSrvType() <> "AS/400"
				lQuery    := .T.
				cAliasSE2 := "QRYSE2"
				cQuery := "SELECT SE2.R_E_C_N_O_ RECSE2,SE2.E2_FILIAL,SE2.E2_FORNECE,SE2.E2_LOJA,SE2.E2_PREFIXO,SE2.E2_NUM,SE2.E2_TIPO "
				cQuery += "FROM "+RetSqlName("SE2")+" SE2 "
				cQuery += "WHERE "
				cQuery += "E2_FILIAL = '"	+ xFilial("SE2")	+ "' AND "
				cQuery += "E2_PREFIXO = '"	+ cSerie			+ "' AND "
				cQuery += "E2_NUM = '"		+ SF2->F2_DOC		+ "' AND "
				cQuery += "E2_FORNECE = '"	+ SF2->F2_CLIENTE	+ "' AND "
				cQuery += "E2_LOJA = '"		+ SF2->F2_LOJA		+ "' AND "
				cQuery += "E2_TIPO IN "+Formatin(MV_CPNEG,'|')+" AND "//Formatando a variavel MV_CPNEG para uso em query com IN ao invez de = porque existe um novo registro atribuido a essa variavel, DIC-Diferen�a dos Impostos Compensados, ISSUE DSERFINP-21487
				cQuery += "SE2.D_E_L_E_T_ = ' '"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE2,.F.,.T.)
			Else
		#ENDIF
				cAliasSE2 := "SE2"
				dbSelectArea("SE2")
				dbSetOrder(6)
				MsSeek(xFilial()+SF2->F2_CLIENTE+SF2->F2_LOJA+cSerie+SF2->F2_DOC)
		#IFDEF TOP
			Endif
		#ENDIF

		While !Eof() .And. ;
			(lQuery .Or. ;
			((cAliasSE2)->E2_FILIAL == xFilial("SE2")  .AND. ;
			(cAliasSE2)->E2_FORNECE == SF2->F2_CLIENTE .AND. ;
			(cAliasSE2)->E2_LOJA    == SF2->F2_LOJA    .AND. ;
			(cAliasSE2)->E2_PREFIXO == cSerie          .AND. ;
			 (cAliasSE2)->E2_NUM     == SF2->F2_DOC))

			If (cAliasSE2)->E2_TIPO $ MV_CPNEG
				aAdd(aRecSE2,Iif(lQuery,(cAliasSE2)->RECSE2,SE2->(RecNo())))
			EndIf
			dbSkip()
		EndDo

		If lQuery
			dbSelectArea(cAliasSE2)
			dbCloseArea()
		EndIf

	EndIf
	aAdd(aTitles,STR0055) //"Duplicatas"
	
	If(IsInCallStack("TMSA500") .And. IntTms())//Caso seja TMS trata a FILIAL com a filial da nota de sa�da
		cFilialTMS := SF2->F2_FILIAL
	Else
		cFilialTMS := xFilial("SF3")
	EndIf

	#IFDEF TOP
		If TcSrvType() <> "AS/400"
			cAliasSF3 := "QRYSF3"
			cQuery := "SELECT SF3.R_E_C_N_O_ RECSF3,SF3.F3_FILIAL,SF3.F3_CLIEFOR,SF3.F3_LOJA,SF3.F3_NFISCAL,SF3.F3_SERIE,SF3.F3_CFO,SF3.F3_DTCANC "
			cQuery += "FROM "+RetSqlName("SF3")+" SF3 "
			cQuery += "WHERE "
			cQuery += "F3_FILIAL  = '"+ cFilialTMS      +"' AND "
			cQuery += "F3_CLIEFOR = '"+ SF2->F2_CLIENTE +"' AND "
			cQuery += "F3_LOJA    = '"+ SF2->F2_LOJA    +"' AND "
			cQuery += "F3_NFISCAL = '"+ SF2->F2_DOC     +"' AND "
			cQuery += "F3_SERIE   = '"+ SF2->F2_SERIE   +"' AND "
			cQuery += "F3_DTCANC  = '' AND "
			cQuery += "SF3.D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF3,.F.,.T.)
		Else
	#ENDIF
			cAliasSF3 := "SF3"
			dbSelectArea("SF3")
			dbSetOrder(4)
			MsSeek(xFilial()+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE)
	#IFDEF TOP
		Endif
	#ENDIF

	While !Eof() .And. lContinua .And. ;
			(lQuery .Or. ;
			((cAliasSF3)->F3_FILIAL == cFilialTMS      .And. ;
			(cAliasSF3)->F3_CLIEFOR == SF2->F2_CLIENTE .And. ;
			(cAliasSF3)->F3_LOJA    == SF2->F2_LOJA    .And. ;
			(cAliasSF3)->F3_NFISCAL == SF2->F2_DOC     .And. ;
			(cAliasSF3)->F3_SERIE   == SF2->F2_SERIE))

		If Substr((cAliasSF3)->F3_CFO,1,1) >= "5" .And. Empty((cAliasSF3)->F3_DTCANC)

			aAdd(aRecSF3,Iif(lQuery,(cAliasSF3)->RECSF3,RecNo()))
			
			If lQuery //Se for Top posiciona no registro correspondente
				SF3->(MsGoto((cAliasSF3)->RECSF3))
			Endif

			If l920Deleta .And. !SoftLock("SF3") //Trava os registros do SF3 - exclusao
				lContinua := .F.
			EndIf
		EndIf
		dbSelectArea(cAliasSF3)
		dbSkip()
	EndDo

	If lQuery
		dbSelectArea(cAliasSF3)
		dbCloseArea()
	EndIf

	A920Refresh(@a920Var,l920Inclui) //Executa o Refresh nos valores de impostos.
EndIf

If lQuery
	dbSelectArea("SD2")
	dbSetOrder(1)
Endif

Return
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �a920LAICMS� Autor � Gustavo G. Rueda      � Data �05/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para montagem do GETDADOS do folder de lancamentos   ���
���          � fiscais.                                                   ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �oLancApICMS -> Objeto criado pelo MSNEWGETDADOS             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�oDlg -> Objeto pai onde o GETDADOS serah criado.            ���
���          �aPos -> posicoes de criacao do objeto.                      ���
���          �aHeadCDA -> array com o HEADER da tabela CDA                ���
���          �aColsCDA -> array com o ACOLS da tabela CDA                 ���
���          �lVisual -> Flag de visualizacao                             ���
���          �lInclui -> Flag de inclusao                                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function a920LAICMS(oDlg,aPos,aHeadCDA,aColsCDA,lVisual,lInclui)
Local	oLancApICMS
Local	bCond		:=	{||.T.}
Local	bSkip		:=	{|| CDA->CDA_TPREG == "NA" }
Local	cVisual		:=	Iif(lVisual,"'1'","'2'")
Local lCalcCDV  	:=  Type("oLancCDV")=="O"
Local nbtnCDV		:=  Iif(lCalcCDV, 45,0)
Local aCpCDA 		:=  {"CDA_NUMITE","CDA_CODLAN","CDA_BASE","CDA_ALIQ","CDA_VALOR","CDA_IFCOMP"}

aMHead("CDA","CDA_TPMOVI/CDA_ESPECI/CDA_FORMUL/CDA_NUMERO/CDA_SERIE/CDA_CLIFOR/CDA_LOJA/",@aHeadCDA)

If CDA->(FieldPos("CDA_VLOUTR")) > 0 .And. CDA->(FieldPos("CDA_TXTDSC")) > 0 .And. CDA->(FieldPos("CDA_CODCPL")) > 0 .And. CDA->(FieldPos("CDA_CODMSG")) > 0 .And. CDA->(FieldPos("CDA_AGRLAN")) > 0
	aAdd(aCpCDA,"CDA_VLOUTR")
	aAdd(aCpCDA,"CDA_TXTDSC")
	aAdd(aCpCDA,"CDA_CODCPL")
	aAdd(aCpCDA,"CDA_CODMSG")
	aAdd(aCpCDA,"CDA_AGRLAN")
Endif	

If lVisual
	dbSelectArea("CDA")
	CDA->(dbSetOrder(1))
	CDA->(MsSeek(xFilial("CDA")+"S"+c920Especi+"S"+c920Nota+c920Serie+c920Client+c920Loja))
	bCond	:=	{||xFilial("CDA")+"S"+c920Especi+"S"+c920Nota+c920Serie+c920Client+c920Loja==CDA->(CDA_FILIAL+CDA_TPMOVI+CDA_ESPECI+CDA_FORMUL+CDA_NUMERO+CDA_SERIE+CDA_CLIFOR+CDA_LOJA)}
EndIf

aMAcols(lVisual,"CDA",@aColsCDA,aHeadCDA,bCond,bSkip)

oLancApICMS	:=	MsNewGetDados():New(aPos[1],aPos[2],aPos[4],aPos[3]-nbtnCDV,Iif(lVisual,0,GD_UPDATE+GD_INSERT+GD_DELETE),"a920LOk","a920LOk","+CDA_SEQ",aCpCDA,/*freeze*/,990,/*fieldok*/,/*superdel*/,"a920LDel("+cVisual+")",oDlg,@aHeadCDA,@aColsCDA)
	
If lCalcCDV
	@ aPos[1]+12,aPos[3]-nbtnCDV BUTTON "Val. Declarat�rio" SIZE 45,11 FONT oDlg:oFont ; 
	ACTION MT103CDV(.T.) OF oDlg PIXEL
Endif

Return oLancApICMS
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �aMHead    � Autor � Gustavo G. Rueda      � Data �05/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para montagem do HEADER do GETDADOS                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cAlias -> Alias da tabela base para montagem do HEADER      ���
���          �cNCmps -> Campos que nao serao considerados no HEADER       ���
���          �aH -> array no qual o HEADER serah montado                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function aMHead(cAlias,cNCmps,aH)
Local lRet := .T.
Local aSX3Fields := {}
Local nX := 0
//��������������������������������������������������������������Ŀ
//� Salva a Integridade dos campos de Bancos de Dados            �
//����������������������������������������������������������������
aSX3Fields := FWSX3Util():GetAllFields( cAlias , .T. )

For nX := 1 To Len( aSX3Fields )
	If X3USO( GetSx3Cache( aSX3Fields[nX], "X3_USADO" ) ) .AND. ;
		cNivel >= GetSx3Cache( aSX3Fields[nX], "X3_NIVEL" ) .AND. ;
		!( aSX3Fields[nX] + "/" $ cNCmps )

		AADD(aH,{ Trim( FWX3Titulo( aSX3Fields[nX] ) ), ;
			AllTrim(aSX3Fields[nX]),;
			GetSx3Cache( aSX3Fields[nX], "X3_PICTURE" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_TAMANHO" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_DECIMAL" ),;
			Iif( AllTrim( aSX3Fields[nX] ) == "CDA_NUMITE", "a920LCpIt().And.", "" ) + "a920LCps()",;
			GetSx3Cache( aSX3Fields[nX], "X3_USADO" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_TIPO" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_F3" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_CONTEXT" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_CBOX" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_RELACAO" ),;
			GetSx3Cache( aSX3Fields[nX], "X3_ORDEM")})
	EndIf
Next

aH:= ASort( aH,,, { |x,y| y[13] > x[13] } )

Return lRet
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �aMAcols   � Autor � Gustavo G. Rueda      � Data �05/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para montagem do ACOLS do GETDADOS                  ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T.                                                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�nOpc -> Opcao do AROTINA                                    ���
���          �cAlias -> Alias da tabela base para montagem do HEADER      ���
���          �aC -> array no qual o ACOLS serah montado                   ���
���          �aH -> array no qual o HEADER serah montado                  ���
���          �bCond -> Condicao de loop do while                          ���
���          �bSkip -> Condicao para ignorar um registro isolado          ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function aMAcols(lVisual,cAlias,aC,aH,bCond,bSkip)
Local lRet	:= .T.
Local nI	:= 0

DEFAULT bSkip := {|| .F. }

dbSelectArea(cAlias)
dbSetOrder(1)
If lVisual
	If !Eof()
		//��������������������������������������������������������������Ŀ
		//� Monta o array aCols com os itens                             �
		//����������������������������������������������������������������
		aC := {}
		While !Eof() .And. Eval(bCond)
			IF Eval(bSkip)
				dbSkip()
				Loop
			EndIf
			aAdd(aC,Array(Len(aH)+1))
			For nI := 1 To Len(aH)
				aC[Len(aC),nI] := FieldGet(FieldPos(aH[nI,2]))
			Next
			aC[Len(aC),Len(aH)+1] := .F.
			dbSkip()
		End
	EndIf
Else
	aC := {Array(Len(aH)+1)}
	aC[1,Len(aH)+1] := .F.
	For nI := 1 To Len(aH)
		If aH[nI,10]#"V"
			aC[1,nI] := CriaVar(aH[nI,2])
		EndIf

		If "_SEQ"$aH[nI,2]
			aC[1,nI] := StrZero(1,aH[nI,4])
		EndIf
	Next
EndIf
Return lRet
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �a920LDel  � Autor � Gustavo G. Rueda      � Data �13/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar a delecao do lancamento fiscal do docu- ���
���          � mento criado pelo sistema.                                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T. ou .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�cVisual -> indica se a nota esta sendo visualizada. 1=Sim,  ���
���          � 2=Nao                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a920LDel(cVisual)
Local	lRet	:=	.T.
Local	nPosCalc:=	0
Local	nPosIt	:=	0
Local 	nPosItD2:= 	0
Local	nPos	:=	0

If Type("oLancApICMS")=="O" .And. cVisual=="2"
	nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
	nPosIt	:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
	
	If nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="1"
		//Registros calculados pelo sistema n�o poder�o ser exclu�dos, pois ser�o utilizados como log da rotina.
		//Caso seja necess�rio alterar este c�lculo, basta inserir novos itens nesta op��o de ajuste ou utitlizar a funcionalidade de Gerenciamento dos Lan�amentos Fiscais de ICMS. Vale ressaltar que na Apura��o de ICMS ser� considerada a sequ�ncia maior de cada lan�amento fiscal do documento.
		Help("  ",1,"LAICMSDEL1")	
		lRet	:=	.F.
	
	ElseIf nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="2" .And. Type("aColsD2")=="A" .And. Type("aHeadD2")="A"
		nPosItD2:= 	aScan(aHeadD2,{|aX| aX[2]==PadR("D2_ITEM",Len( GetSx3Cache( "D2_ITEM", "X3_CAMPO" ) ))})

		If nPosItD2>0 .And. nPosIt>0
			nPos	:=	aScan(aColsD2,{|aX|PadR(aX[nPosItD2],TamSx3("CDA_NUMITE")[1])==oLancApICMS:aCols[oLancApICMS:nAT,nPosIt].And.!aX[Len(aColsD2[1])]})
			If nPos==0 .And. !Empty(oLancApICMS:aCols[oLancApICMS:nAT,nPosIt])
				//Este registro n�o pode ser recuperado, pois o mesmo encontra-se exclu�do juntamente com seu respectivo item do documento fiscal.
				//Para se recuperar este registro � necess�rio que se tenha o respectivo item deste documento fiscal ativado.
				Help("  ",1,"LAICMSDEL2")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �a920LCpIt � Autor � Gustavo G. Rueda      � Data �13/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar o item digitado no lancamento fiscal com���
���          � os itens do documento fiscal.                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T. ou .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a920LCpIt()
Local	lRet	:=	.T.
Local	nPosCalc:=	0
Local	nPosItD2:=	0

If Type("oLancApICMS")=="O"

	nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})

	If nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="2" .And. Type("aColsD2")=="A" .And. Type("aHeadD2")="A"
		nPosItD2:= 	aScan(aHeadD2,{|aX| aX[2]==PadR("D2_ITEM",Len( GetSx3Cache( "D2_ITEM", "X3_CAMPO" ) ))})
		If nPosItD2>0
			nPos	:=	aScan(aColsD2,{|aX|aX[nPosItD2]==AllTrim(M->CDA_NUMITE).And.!aX[Len(aColsD2[1])]})
			If nPos==0
				//N�mero do item � inv�lido para este lan�amento fiscal.
				//Deve-se informar um n�mero de item existente no respectivo documento fiscal.
				Help("  ",1,"LAICMSCMP1")
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �a920LCps  � Autor � Gustavo G. Rueda      � Data �13/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar os campos alimentados pelo sistema que  ���
���          � nao poderao ser alterados.                                 ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T. ou .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a920LCps()
Local	lRet	:=	.T.
Local	nPosCalc:=	0

If Type("oLancApICMS")=="O"
	nPosCalc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})
	If nPosCalc>0 .And. oLancApICMS:aCols[oLancApICMS:nAT,nPosCalc]=="1"
		//Registros calculados pelo sistema n�o poder�o ser alterados, pois ser�o utilizados como log da rotina.
		//Caso seja necess�rio alterar este c�lculo, basta inserir novos itens nesta op��o de ajuste ou utitlizar a funcionalidade de Gerenciamento dos Lan�amentos Fiscais de ICMS. Vale ressaltar que na Apura��o de ICMS ser� considerada a sequ�ncia maior de cada lan�amento fiscal do documento.
		Help("  ",1,"LAICMSCMP2")
		lRet	:=	.F.
	EndIf
EndIf

Return lRet
/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �a920LOk   � Autor � Gustavo G. Rueda      � Data �13/12/2007���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao para validar a linha do acols de lancamentos         ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T. ou .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function a920LOk()
Local	lRet	:=	.T.
Local	nPosLanc:=	0
Local	nPosVlr	:=	0
Local	nNumIte	:=	0
Local   nPosClPr := 0

If Type("oLancApICMS")=="O"
	nPosLanc:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CODLAN"})
	nPosVlr:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_VALOR"})
	nNumIte:=	aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_NUMITE"})
	nPosClPr:=  aScan(oLancApICMS:aHeader,{|aX|aX[2]=="CDA_CALPRO"})

	If oLancApICMS:aCols[oLancApICMS:nAT,nPosClPr] <> "1"
		If !oLancApICMS:aCols[oLancApICMS:nAT,Len(oLancApICMS:aCols[oLancApICMS:nAT])] .And.;
			!Empty(oLancApICMS:aCols[oLancApICMS:nAT,nNumIte])

			If nPosLanc>0 .And. Empty(oLancApICMS:aCols[oLancApICMS:nAT,nPosLanc])
				Help(1," ","OBRIGAT",,"CDA_CODLAN"+Space(30),3,0)
				lRet	:=	.F.
			EndIf

			If lRet .And. nPosLanc>0 .And. Empty(oLancApICMS:aCols[oLancApICMS:nAT,nPosVlr])
				Help(1," ","OBRIGAT",,"CDA_VALOR"+Space(30),3,0)
				lRet	:=	.F.
			EndIf
		EndIf
	EndIf
EndIf
Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �a920Compl �Autor  �Mary C. Hergert     � Data �  05/12/07   ���
�������������������������������������������������������������������������͹��
���Desc.     �Executa a rotina de complementos do documento fiscal        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �Mata920                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a920Compl()

//�������������������������������Ŀ
//�Verifica a especie do documento�
//���������������������������������
SF2->(dbSetOrder(1)) 
SF2->(dbSeek(xFilial("SF2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA))

Mata926(SD2->D2_DOC,SD2->D2_SERIE,SF2->F2_ESPECIE,SD2->D2_CLIENTE,SD2->D2_LOJA,"S",SD2->D2_TIPO,SD2->D2_CF,SD2->D2_ITEM)

Return .T. 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �a920RatCC  �Autor  �Microsiga           � Data �  06/18/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function a920RatCC(aHeadAGH,aColsAGH,nAt)

Local aArea       := GetArea()
Local aSavaRotina := aClone(aRotina)
Local aColsCC     := {}
Local aButtons	  := {}
Local aButtonUsr  := {}
Local aHeadSC7    := {}
Local aColsSC7    := {}
Local aNoFields   := {"AGH_CUSTO1","AGH_CUSTO2","AGH_CUSTO3","AGH_CUSTO4","AGH_CUSTO5"}
Local bSavKeyF4   := SetKey(VK_F4 ,Nil)
Local bSavKeyF5   := SetKey(VK_F5 ,Nil)
Local bSavKeyF6   := SetKey(VK_F6 ,Nil)
Local bSavKeyF7   := SetKey(VK_F7 ,Nil)
Local bSavKeyF8   := SetKey(VK_F8 ,Nil)
Local bSavKeyF9   := SetKey(VK_F9 ,Nil)
Local bSavKeyF10  := SetKey(VK_F10,Nil)
Local bSavKeyF11  := SetKey(VK_F11,Nil)
Local nPItemNF	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEM"} )
Local nPCC	      := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CC"} )
Local nPConta	  := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_CONTA"} )
Local nPItemCta   := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_ITEMCTA"} )
Local nPCLVL	  := Ascan(aHeader,{|x| AllTrim(x[2]) == "D2_CLVL"} )
Local nPDECC	  := 0
Local nPDEConta	  := 0
Local nPDEItemCta := 0
Local nPDECLVL	  := 0
Local nColTotal   := aScan(aHeader,{|x| AllTrim(x[2]) == "D2_TOTAL"} )
Local nItem  	   := aScan(aColsAGH,{|x| Alltrim(x[1]) == Alltrim(aCols[n][nPItemNF])})
Local nX          := 0
Local nSavN       := nAT
Local nPPercAGH   := 0
Local nTotPerc    := 0
Local nOpcA       := 0
Local nNewTam     := 0
Local lContinua   := .T.
Local lRet        := .T.
Local oDlg
Local cCampo      := ReadVar()
Local nAviso      := 0
Local ca920Num    := SF2->F2_DOC

Local aSX3Fields := {}

DEFAULT aHeadAGH  := {}
DEFAULT aColsAGH  := {}

Private aOrigHeader := aClone(aHeader)
Private aOrigAcols  := aClone(aCols)
Private oGetMan
Private nOrigN      := nAT
Private nPercRat    := 0
Private nPercARat	:= 100
Private oPercRat
Private oPercARat
Private oGetDad
Private N := nAT

//���������������������������������������������������������������������Ŀ
//� Impede de executar a rotina quando a tecla F3 estiver ativa		   �
//�����������������������������������������������������������������������
If Type("InConPad") == "L" 
	lContinua := !InConPad
EndIf

If nSavN == 0 
	lContinua := .F.
EndIf

If lContinua
	//���������������������������������������������������������������������Ŀ
	//� Montagem do aHeader do AGH                                          �
	//�����������������������������������������������������������������������
	If Empty(aHeadAGH)
		aSX3Fields := FWSX3Util():GetAllFields( "AGH" , .T. )

		For nX := 1 To Len( aSX3Fields )
			If X3USO( GetSx3Cache( aSX3Fields[nX], "X3_USADO" ) ) .AND. ;
				cNivel >= GetSx3Cache( aSX3Fields[nX], "X3_NIVEL" ) .AND. ;
				!( "AGH_CUSTO" $ aSX3Fields[nX] )

				Aadd(aHeadAGH,{ AllTrim( FWX3Titulo( aSX3Fields[nX] ) ),;
					aSX3Fields[nX],;
					GetSx3Cache( aSX3Fields[nX], "X3_PICTURE" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_TAMANHO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_DECIMAL" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_VALID" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_USADO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_TIPO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_F3" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_CONTEXT" ) } )
			EndIf
		Next
	EndIf
	
	//���������������������������������������������������������������������Ŀ
	//� Montagem do aCols do AGH                                            �
	//�����������������������������������������������������������������������
	If nItem > 0
		aColsCC := aClone(aColsAGH[nItem][2])
		
		//�������������������������Ŀ
		//� Totaliza o % ja Rateado �
		//���������������������������
		nPercRat := 0
		For nX   := 1  To  Len(aColsCC)
			nPercRat += aColsCC[nX][aScan(aHeadAGH,{|x| AllTrim(x[2])=="AGH_PERC"})]
		Next nX
		
		nPercARat := 100 - nPercRat
	Else
		//���������������������������������������������������������������������Ŀ
		//� aHeader e aCols do SC7 devem ser salvos pois a FillGetDados destroe �
		//� ambos por serem PRIVATE, independente da construcao do aColsCC.     �
		//�����������������������������������������������������������������������
		aHeadSC7 := aClone(aHeader)
		aColsSC7 := aClone(aCols)
		aHeadAGH := {}
		//����������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������Ŀ
		//� Sintaxe da FillGetDados(nOpcX,Alias,nOrdem,cSeek,bSeekWhile,uSeekFor,aNoFields,aYesFields,lOnlyYes,cQuery,bMontCols,lEmpty,aHeaderAux,aColsAux,bAfterCols,bBeforeCols,bAfterHeader,cAliasQry |
		//������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������������
		FillGetDados(2,"AGH",1,,,,aNoFields,,,,,.T.,aHeadAGH,aColsCC,,,)
		aColsCC[1][aScan(aHeadAGH,{|x| Trim(x[2])=="AGH_ITEM"})] := StrZero(1,Len(AGH->AGH_ITEM))
		
		aHeader := aHeadSC7
		aCols   := aColsSC7
		
	EndIf
	If !(Type('l920Auto') <> 'U' .And. l920Auto)
		aHeadSC7 := aClone(aHeader)
		aColsSC7 := aClone(aCols)
		DEFINE MSDIALOG oDlg FROM 100,100 TO 350,600 TITLE STR0091 Of oMainWnd PIXEL //"Rateio por Centro de Custo"
		@ 018,003 SAY RetTitle("F2_DOC")  OF oDlg PIXEL SIZE 20,09
		@ 018,026 SAY ca920Num            OF oDlg PIXEL SIZE 50,09
		@ 018,096 SAY RetTitle("F2_ITEM") OF oDlg PIXEL SIZE 20,09
		@ 018,120 SAY aCols[N][nPItemNF]  OF oDlg PIXEL SIZE 20,09
		oGetDad := MsNewGetDados():New(030,005,105,245,0 ,"a920RatLOk","a920RatTOk","+AGH_ITEM",,,999,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeadAGH,aColsCC)
		oGetMan := oGetDad
		@ 110,005 Say OemToAnsi(STR0092) FONT oDlg:oFont OF oDlg PIXEL	 // "% Rateada: "
		@ 110,035 Say oPercRat VAR nPercRat Picture PesqPict("AGH","AGH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		@ 110,184 Say OemToAnsi(STR0093) FONT oDlg:oFont OF oDlg PIXEL	 // "% A Ratear: "
		@ 110,217 Say oPercARat VAR nPercARat Picture PesqPict("AGH","AGH_PERC") FONT oDlg:oFont COLOR CLR_HBLUE OF oDlg PIXEL
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||IIF(oGetDad:TudoOk(),(nOpcA:=1,oDlg:End()),(nOpcA:=0))},{||oDlg:End()},,aButtons)

		aHeader := aHeadSC7
		aCols   := aColsSC7
	Else
		nOpcA := 1
	EndIf
	nPPercAGH := aScan(aHeadAGH,{|x| AllTrim(x[2])=="AGH_PERC"})
	nTotPerc := 0
	
	aColsPar :={}
	AEval( aColsCC, { |x| If( !x[ Len(aHeadAGH) + 1], AAdd( aColsPar, x ), ) } )
	aColsCC := aClone( aColsPar )
	
	For nX := 1 To Len(aColsCC)
		nTotPerc += aColsCC[nX][nPPercAGH]
	Next nX
	
EndIf

//���������������������������������������������������������������������Ŀ
//� Restaura a integridade da rotina                                    �
//�����������������������������������������������������������������������
aRotina	:= aClone(aSavaRotina)
N := nSavN
SetKey(VK_F4 ,bSavKeyF4)
SetKey(VK_F5 ,bSavKeyF5)
SetKey(VK_F6 ,bSavKeyF6)
SetKey(VK_F7 ,bSavKeyF7)
SetKey(VK_F8 ,bSavKeyF8)
SetKey(VK_F9 ,bSavKeyF9)
SetKey(VK_F10,bSavKeyF10)
SetKey(VK_F11,bSavKeyF11)
RestArea(aArea)
Return(.T.)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �a920RatLok � Autor � Eduardo Riera         � Data �15.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Validacao da linhaok dos itens do rateio dos itens do documen���
���          �to de entrada                                                ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se a linha esta valida                         ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo validar a linhaok do rateio dos���
���          �itens do documento de entrada                                ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function a920RatLOk()

Local nPPerc    := aScan(aHeader,{|x| AllTrim(x[2]) == "AGH_PERC"} )
Local lRetorno  := .T.
Local nX        := 0

If !aCols[N][Len(aCols[N])]
	If aCols[N][nPPerc] == 0
		Help(" ",1,"A103PERC")
		lRetorno := .F.
	EndIf
EndIf

If lRetorno
	nPercRat := 0
	nPercARat:= 0
	For nX	:= 1 To Len(aCols)
		If !aCols[nX][Len(aCols[nX])]
			nPercRat += aCols[nX][nPPerc]
		EndIf
	Next
	nPercARat := 100 - nPercRat
	If Type("oPercRat")=="O"
		oPercRat:Refresh()
		oPercARat:Refresh()
	Endif
EndIf

Return(lRetorno)

/*/
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Fun��o    �a920RatLok � Autor � Eduardo Riera         � Data �15.10.2002 ���
��������������������������������������������������������������������������Ĵ��
���          �Validacao da TudoOk dos itens do rateio dos itens do documen-���
���          �to de entrada                                                ���
��������������������������������������������������������������������������Ĵ��
���Parametros�                                                             ���
��������������������������������������������������������������������������Ĵ��
���Retorno   �ExpL1: Indica se a todas as linhas estao validas             ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Descri��o �Esta rotina tem como objetivo validar a tudook do rateio dos ���
���          �itens do documento de entrada                                ���
���          �                                                             ���
��������������������������������������������������������������������������Ĵ��
���Uso       � Materiais                                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function a920RatTok()

Local nPPerc   := aScan(aHeader,{|x| AllTrim(x[2]) == "AGH_PERC"} )
Local nTotal   := 0
Local nX       := 0
Local lRetorno := .T.
Local n_SaveLin

For nX	:= 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nX])]
		nTotal += aCols[nX][nPPerc]
	EndIf
Next
If nTotal > 0 .And. nTotal <> 100
	Help(" ",1,"A103TOTRAT")
	lRetorno := .F.
EndIf

Return(lRetorno) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �a920FRat   �Autor  �Microsiga           � Data �  06/23/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Carrega o vetor dos rateios do pedido                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function a920FRat(aHeadAGH,aColsAGH)
Local lQuery    := .F.
Local aStruAGH  := AGH->(dbStruct())
Local cAliasAGH := "AGH" 
Local nX		:= 0
Local nY		:= 0  
Local aBackAGH    := {}
Local cItemAGH  := ""
Local nItemAGH	:= 0

Local aSX3Fields := {}
//������������������������������������������������������Ŀ
//� Monta o Array contendo as registros do AGH           �
//��������������������������������������������������������
DbSelectArea("AGH")
DbSetOrder(1) // AGH_FILIAL+AGH_NUM+AGH_SERIE+AGH_FORNEC+AGH_LOJA+AGH_ITEMPD+AGH_ITEM
cAliasAGH := "AGH"		

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery    := .T.
		aStruAGH  := AGH->(dbStruct())
		cAliasAGH := "A120NFISCAL"
		cQuery    := "SELECT AGH.*,AGH.R_E_C_N_O_ AGHRECNO "
		cQuery    += "FROM "+RetSqlName("AGH")+" AGH "
		cQuery    += "WHERE AGH.AGH_FILIAL='"+xFilial("AGH")+"' AND "
		cQuery    += "AGH.AGH_NUM='"+SF2->F2_DOC+"' AND "
		cQuery    += "AGH.AGH_SERIE='"+SF2->F2_SERIE+"' AND "
		cQuery    += "AGH.AGH_FORNEC='"+SF2->F2_CLIENTE+"' AND "
		cQuery    += "AGH.AGH_LOJA='"+SF2->F2_LOJA+"' AND "
		cQuery    += "AGH.D_E_L_E_T_=' ' "
		cQuery    += "ORDER BY "+SqlOrder(AGH->(IndexKey()))

		cQuery := ChangeQuery(cQuery)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAGH,.T.,.T.)
		For nX := 1 To Len(aStruAGH)
			If aStruAGH[nX,2]<>"C"
				TcSetField(cAliasAGH,aStruAGH[nX,1],aStruAGH[nX,2],aStruAGH[nX,3],aStruAGH[nX,4])
			EndIf
		Next nX
		
	Else
#ENDIF
		MsSeek(xFilial("AGH")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA)
#IFDEF TOP
	EndIf
#ENDIF

dbSelectArea(cAliasAGH)
While ( !Eof() .And. Iif(lQuery,.T.,;
		xFilial('AGH') == (cAliasAGH)->AGH_FILIAL .And.;
		SF2->F2_DOC == (cAliasAGH)->AGH_NUM .And.;
		SF2->F2_SERIE == (cAliasAGH)->AGH_SERIE .And.;
		SF2->F2_CLIENTE == (cAliasAGH)->AGH_FORNEC .And.;
		SF2->F2_LOJA == (cAliasAGH)->AGH_LOJA ))
	If Empty(aBackAGH)
		//��������������������������������������������������������������Ŀ
		//� Montagem do aHeader                                          �
		//����������������������������������������������������������������
		aSX3Fields := FWSX3Util():GetAllFields( "AGH" , .T. )

		For nX := 1 To Len( aSX3Fields )
			If X3USO( GetSx3Cache( aSX3Fields[nX], "X3_USADO" ) ) .AND. ;
				cNivel >= GetSx3Cache( aSX3Fields[nX], "X3_NIVEL" ) .AND. ;
				!( "AGH_CUSTO" $ aSX3Fields[nX] )

				Aadd(aBackAGH,{ AllTrim( FWX3Titulo( aSX3Fields[nX] ) ),;
					aSX3Fields[nX],;
					GetSx3Cache( aSX3Fields[nX], "X3_PICTURE" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_TAMANHO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_DECIMAL" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_VALID" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_USADO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_TIPO" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_F3" ),;
					GetSx3Cache( aSX3Fields[nX], "X3_CONTEXT" ) } )
			EndIf
		Next
	EndIf
	aHeadAGH  := aBackAGH
	//��������������������������������������������������������������Ŀ
	//� Adiciona os campos de Alias e Recno ao aHeader para WalkThru.�
	//����������������������������������������������������������������
	ADHeadRec("AGH",aHeadAGH)

	If	cItemAGH <> (cAliasAGH)->AGH_ITEMPD
		cItemAGH := (cAliasAGH)->AGH_ITEMPD
		aadd(aColsAGH,{cItemAGH,{}})
		nItemAGH++
	EndIf

	aadd(aColsAGH[nItemAGH][2],Array(Len(aHeadAGH)+1))
	For nY := 1 to Len(aHeadAGH)
		If IsHeadRec(aHeadAGH[nY][2])
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := IIf(lQuery , (cAliasAGH)->AGHRECNO , AGH->(Recno())  )
		ElseIf IsHeadAlias(aHeadAGH[nY][2])
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := "AGH"
		ElseIf ( aHeadAGH[nY][10] <> "V")
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := (cAliasAGH)->(FieldGet(FieldPos(aHeadAGH[nY][2])))
		Else
			aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][nY] := (cAliasAGH)->(CriaVar(aHeadAGH[nY][2]))
		EndIf
		aColsAGH[nItemAGH][2][Len(aColsAGH[nItemAGH][2])][Len(aHeadAGH)+1] := .F.
	Next nY

	DbSelectArea(cAliasAGH)
	dbSkip()
EndDo

If lQuery
	DbSelectArea(cAliasAGH)
	dbCloseArea()
	DbSelectArea("AGH")
EndIf

Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �SF3Canc �Autor  �Mauro Gon�alves       � Data �   20.Jul.10 ���
�������������������������������������������������������������������������͹��
���Descricao �Verifica se a NF est� cancelada. Usada no PE MTVALNF        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
/*/
Function SF3Canc(cCodFil,cNroDoc,cSerDoc,cCliFor,cCodLoj)
Local aArea    := GetArea()
local cSF3Canc := "QRYSF3CANC"
local cQuery   := ""    
local lCanc    := ""    

if empty(cCodFil) .or. empty(cNroDoc) .or. empty(cSerDoc) .or. empty(cCliFor) .or. empty(cCodLoj)
   return .f.
endif
   
#IFDEF TOP
	If TcSrvType() <> "AS/400"
		cQuery := "SELECT SF3.* FROM "
		cQuery += RetSqlName("SF3") + " SF3 "
		cQuery += " WHERE "
		cQuery += "F3_FILIAL = '"+cCodFil+"' AND "
		cQuery += "F3_CLIEFOR = '"+cCliFor+"' AND "
		cQuery += "F3_LOJA = '"+cCodLoj+"' AND "
		cQuery += "F3_NFISCAL = '"+cNroDoc+"' AND "
		cQuery += "F3_SERIE = '"+cSerDoc+"' AND "
		cQuery += "F3_DTCANC <> '        '"			
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cSF3Canc,.F.,.T.)
	Else
#ENDIF
 		cSF3Canc := "SF3"
		dbSelectArea("SF3")
		dbSetOrder(4)
		MsSeek(xFilial()+cCliFor+cCodLoj+cNroDoc+cSerDoc)
		#IFDEF TOP
	Endif	
		#ENDIF

lCanc := !(cSF3Canc)->(EOF())
DbSelectArea("QRYSF3CANC")
dbCloseArea()
RestArea(aArea)

return lCanc
/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �a920TpLjTit �Autor  �Varejo            � Data �   30.Dez.16 ���
�������������������������������������������������������������������������͹��
���Descricao �Retorna os tipos dos t�tulos cadastrados na tabela SX5       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
/*/
Static Function a920TpLjTit(cSqlCons, cAdsCons)
Local nTamE1Tipo := SE1->(TamSx3("E1_TIPO")[1]) //Tamanho do campo E1_TIPO
Local aAreaSx5   := SX5->(GetArea()) //WorkArea Sx5
Local cExp       := "" //Express�o do Campo
Local cSimbCorr  := SuperGetMv("MV_SIMB1") //Moeda corrente

Local aSX5Fields := {}
Local nX := 0

Default cSqlCons := "" //Chave de busca SQL
Default cAdsCons := "" //Chave de Busca ADS

//Formas de pagamento Padroes

cAdsCons := AllTrim(cSimbCorr)+"/CC/CD/FI/VA/CO/CH/" 
cSqlCons := "'" + cSimbCorr  + "', 'CC', 'CD', 'FI', 'VA', 'CO', 'CH', "

aSX5Fields := FWGetSX5( "24" )

If Len( aSX5Fields ) > 0
	For nX := 1 To Len( aSX5Fields )
		cExp := Left(AllTrim( aSX5Fields[nX][3] ), nTamE1Tipo)

		If !(cExp $ cAdsCons)
			If !(cExp == "BO" .OR. cExp == "BOL")
				cSqlCons += "'" + cExp  + "', "
				cAdsCons += cExp + "/"
			Else
				cSqlCons += "'BO', 'BOL', "
				cAdsCons += "BO/BOL/"
			EndIf
		EndIf
	Next

	cSqlCons := Left(cSqlCons, Len(cSqlCons)-2)
	cAdsCons := Left(cAdsCons, Len(cAdsCons)-1)
EndIf

RestArea(aAreaSX5)

Return

/*/{Protheus.doc} a920NfOri()
@description
Funcao responsavel por apresentar a Dialog para vinculo da
NF de origem.
@author joao.pellegrini
@since 13/06/2017
@version 11.80
/*/
Function a920NfOri()

Local nPProduto := aScan(aHeader,{|x| AllTrim(x[2])=="D2_COD"})
Local nPNFOri   := aScan(aHeader,{|x| AllTrim(x[2])=="D2_NFORI"})
Local nPSerOri  := aScan(aHeader,{|x| AllTrim(x[2])=="D2_SERIORI"})
Local nRecSD2   := 0

If nPProduto > 0 .And. n <= Len(aCols)
	
	cProduto  := aCols[n][nPProduto]


	If "D2_NFORI" $ ReadVar() .And. cTipo $ "PICD"
	
		If F4Compl(,,,c920Client,c920Loja,cProduto,IIF(cTipo=="D","A910","A920"),@nRecSD2)
			
			If nPNFOri > 0 .And. nPSerOri > 0
				
				MaFisLoad("IT_NFORI",aCols[n][nPNFOri],n)
				MaFisLoad("IT_SERORI",aCols[n][nPSerOri],n)
								
			EndIf   

			If nRecSD2 > 0
				MaFisAlt("IT_RECORI",nRecSD2,n)
			EndIf
				
		EndIf
	
	EndIf
	
EndIf
	
Return .T.

/*/{Protheus.doc} a920NextDoc()
@description
Funcao responsavel por retornar o numero da proxima nota
quando o usuario nao digitar.
@author joao.pellegrini
@since 05/12/2017
@version 11.80
/*/
Static Function a920NextDoc()

Local aArea	   := GetArea()
Local cTipoNf  := SuperGetMv("MV_TPNRNFS")
Local lRet    := .F.
Local cSerie  := ""

Private cNumero := "" // Precisa ser private com este nome - Funcao Sx5NumNota.
Private lMudouNum := .F. // Precisa ser private com este nome - Funcao Sx5NumNota.

lRet := Sx5NumNota(@cSerie, cTipoNf)

If lRet

	// Numeracao via SX5 ou SXE/SXF
	If cTipoNf $ "1|2"
				
		// Apenas via SX5 pois com XE/XF o usuario nao consegue confirmar a selecao da serie se o documento ja existir.
		If cTipoNf == "1"
			SF2->(dbSetOrder(2))
			If SF2->(MsSeek(xFilial("SF2") + c920Client + c920Loja + PADR(cNumero, TamSx3("F2_DOC")[1]) + cSerie))
				MsgAlert("Este n�mero de documento j� foi utilizado." + Chr(13) + Chr(10) + "O documento ser� gerado com o pr�ximo n�mero dispon�vel.")
			EndIf
		EndIf
		
		// lMudouNum sera .T. quando utilizar XE/XF e o usuario alterar a numeracao na tela.
		// Neste caso devo respeitar o numero digitado. No entando a proxima numera��o seguir�
		// a sequencia normal.
		If !lMudouNum
			cNumero := NxtSX5Nota(cSerie, NIL, cTipoNf)
		EndIf
		
		c920Nota  := cNumero
		c920Serie := cSerie
			
	// Numeracao via SD9
	ElseIf cTipoNf == "3" .And. AliasIndic("SD9")
	 
		c920Nota := MA461NumNf(.T., cSerie)
		c920Serie := cSerie
		
	EndIf
	
EndIf

RestArea(aArea)

Return lRet

/*/{Protheus.doc} A920VldNum()
@description
Funcao responsavel por validar se a numeracao automatica deve ou ser gerada.
@author joao.pellegrini
@since 05/12/2017
@version 11.80
/*/
Function A920VldNum(c920Nota)

Local lRet := .T.

If cPaisLoc == "BRA" .And. (Type("l920Auto") != "L" .Or. !l920Auto) .And. !lLote .And. Empty(c920Nota) 

	lRet := lGeraNum := MsgYesNo("Deixar o n�mero do documento em branco indica que ser� solicitada uma s�rie no momento da grava��o e o n�mero ser� sugerido pelo sistema." + Chr(13) + Chr(10) + ;								
								 "Deseja continuar?", "Numera��o Autom�tica")

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidPerg
 
Fun��o que ir� criar O SX1 complementar.
 
@author Eduardo Vicente da Silva
@since 19/06/2018
@version 12.1.17

/*/
//-------------------------------------------------------------------

Static Function ValidPerg(cPerg)

If FindFunction("EngSX1117")
	EngSX1117( cPerg, "01", "Mostra Lancto Cont�bil", "Mostra Lancto Cont�bil", "Mostra Lancto Cont�bil",       "MV_CH1", "C", 1, 0,,"C",,,,,"MV_PAR01","Sim","Sim","Sim",,"N�o","N�o","N�o",,,,,,,,,,{"Informa se deseja mostrar a tela de lan�amento cont�bil."},{},{},)
	EngSX1117( cPerg, "02", "Aglutina Lancto Cont�bil", "Aglutina Lancto Cont�bil", "Aglutina Lancto Cont�bil", "MV_CH2", "C", 1, 0,,"C",,,,,"MV_PAR02","Sim","Sim","Sim",,"N�o","N�o","N�o",,,,,,,,,,{"Informa se deseja aglutinar os lan�amentos cont�beis."},{},{},)
EndIf

Return

/*/{Protheus.doc} a920PSD2()
@description
Funcao responsavel por posicionar a nota fiscal de saida, retornando as informa��es dos registro da tabela SD2
@author Beatriz Santos
@since 26/03/2019
@version 12.1.23
/*/
Function a920PSD2(cDoc, cSerie, cCliente, cLoja, cCodProd, cItem)

Local cQry      := GetNextAlias()
Local cWhere    := ""
Local cTable    := "%" + RetSqlName("SD2") + "%"
Local nRecSD2   := 0

Default cDoc     := ''
Default cSerie   := ''
Default cCliente := ''
Default cLoja    := ''
Default cCodProd := ''
Default cItem    := ''

cWhere := "D_E_L_E_T_ = ' ' "
cWhere += "AND D2_FILIAL  = '"+xFilial('SD2')+"'"
cWhere += "AND D2_DOC     = '"+cDoc+"'"
cWhere += "AND D2_SERIE   = '"+cSerie+"'"
cWhere += "AND D2_CLIENTE = '"+cCliente+"'"
cWhere += "AND D2_LOJA    = '"+cLoja+"'"
cWhere += "AND D2_COD     = '"+cCodProd+"'"
cWhere += "AND D2_ITEM    = '"+cItem+"'"
cWhere := "%" + cWhere + "%"

BEGINSQL ALIAS cQry
    SELECT R_E_C_N_O_ REGSD2
    FROM %Exp:cTable%
    WHERE
        %Exp:cWhere%
ENDSQL                      

If (cQry)->(!Eof())
	nRecSD2 := (cQry)->REGSD2  
Endif
(cQry)->(DbCloseArea())
	
Return nRecSD2

/*/{Protheus.doc} a920ItemOri()
@description
Funcao responsavel por executar a fun��o MaFisAlt
@author Beatriz Santos
@since 26/03/2019
@version 12.1.23
/*/
Function a920ItemOri()
Local cDoc     := ''
Local cSerie   := ''
Local cCliente := ''
Local cLoja    := ''
Local cCodProd := ''
Local cItem    := ''
Local nRecPos  := 0

If cPaisLoc == "BRA" .AND. FunName() == "MATA920"

	cDoc     := aCols[N][GdFieldPos("D2_NFORI"  )]
	cSerie   := aCols[N][GdFieldPos("D2_SERIORI")]
	cCliente := c920Client
	cLoja    := c920Loja
	cCodProd := aCols[N][GdFieldPos("D2_COD"    )]
	cItem    := M->D2_ITEMORI

	nRecPos := a920PSD2(cDoc, cSerie, cCliente, cLoja, cCodProd, cItem)

	If nRecPos > 0
		MaFisAlt("IT_RECORI",nRecPos,n)
	EndIf 

Endif

Return .T.
