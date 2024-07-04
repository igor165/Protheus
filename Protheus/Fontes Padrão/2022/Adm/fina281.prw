#INCLUDE "FINA281.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static _oFina2811
Static _oFina2812
 
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Fina281	� Autor � Paulo Boschetti	     � Data � 27/07/93���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Sele��o de titulos para Fatura a RECEBER 				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Fina281()												  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � NIL                                                        ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
���Comentario�                                                            ���
�������������������������������������������������������������������������Ĵ��
���          Atualizacoes efetuadas desde a codificacao inicial           ���
�������������������������������������������������������������������������Ĵ��
��� Programador  � Data   � BOPS �  Motivo da Alteracao                   ���
�������������������������������������������������������������������������Ĵ��
���Deny Mendonca �29/07/02�xxxxxx� Revisao do Fonte para chamar as funcoes���
���              �        �      � de Baixa e de Fatura a partir do modulo���
���              �        �      � TMS.                                   ���
���Deny Mendonca �29/08/02�xxxxxx� Grava o campo DT6_FATURA no cancelamen-���
���              �        �      � to da Fatura quando o modulo TMS       ���
���              �        �      � estiver ativo.                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fina281(nPosArotina, lAutomato)

PRIVATE aRotina 	:= MenuDef()
PRIVATE cCli		:=	Space(6)
PRIVATE cLoja		:=	Space(2)
PRIVATE cLojaFat	:=	Space(2)
PRIVATE cPrefix		:=	Space(3)
PRIVATE dEmisFat	:=	SuperGetMv("MV_DATAFAT",,dDataBase)
PRIVATE cCliFat		:=	Space(6)
PRIVATE dVencto		:=	Ctod(Space(8))
PRIVATE dDataDe		:=	dDataBase
PRIVATE dDataAte	:=	dDataBase
PRIVATE cNat		:=	Space(10)
PRIVATE nTotAbat	:=	0
PRIVATE nValorFat 	:=	0
PRIVATE nValorF		:=	0
PRIVATE nValor 		:=	0
PRIVATE nVLCruz		:=	0
PRIVATE nVARURV		:=	0
PRIVATE nQtdTit		:=	0
PRIVATE nValtot		:=	0
PRIVATE aVenc,aGets[0]
PRIVATE nMoedFat		:=	1
PRIVATE nVlrAtu 		:= 0 // Utilizada na Fa280Marca
PRIVATE aMark 		:= {}
PRIVATE lUsaBolsa		:= .F.

//variaveis para o ponto de entrada F280SE5 (localizado no FINA280)
PRIVATE lF280SE5      := Existblock("F280SE5")
PRIVATE aRecSe5       := {}

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de baixas								  �
//����������������������������������������������������������������
PRIVATE cCadastro := STR0005 //"Faturas a Receber"

Default nPosArotina 	:= 0
Default lAutomato		:= .F.


dbSelectArea("SE1")

//��������������������������������������������������������������Ŀ
//� ACIONA A FUNCAO PERGUNTE									 �
//����������������������������������������������������������������
SetKey (VK_F12,{|a,b| AcessaPerg("AFI281",.T.)})
Pergunte("AFI281",.F.)
//����������������������������������������Ŀ
//� Variaveis utilizadas para parametros   �
//� mv_par01		 // Considera Loja	   �
//� mv_par02		 // Elimina residuos   �
//������������������������������������������

If nPosArotina > 0
	dbSelectArea('SE1')
	bBlock := &( "{ |a,b,c,d,e| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,lAutomato)
Else
	//��������������������������������������������������������������Ŀ
	//� Endereca a Fun��o de BROWSE									 �
	//����������������������������������������������������������������
	mBrowse( 6, 1,22,75,"SE1",,,,,, Fa281Legenda())
Endif

Set Key VK_F12 to

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados							 �
//����������������������������������������������������������������
dbSelectArea("SE1")
dbSetOrder(1)
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � fA281Aut � Autor � Paulo Boschetti		� Data � 27/07/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Marca��o dos titulos para emiss�o de fatura	    	  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Fa281Aut()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function fA281Aut(cAlias,cCampo,nOpcE, lAutomato)
//��������������������������������������������������������������Ŀ
//� Define Variaveis 											 �
//����������������������������������������������������������������

LOCAL cArquivo
LOCAL nTotal	:= 0
LOCAL nHdlPrv	:= 0
LOCAL cPadrao	:= "595"
LOCAL nW 		:= 1
LOCAL dDatCont	:= dDatabase
LOCAL cCondicao := Space(3)
LOCAL cIndex	:= ""
LOCAL nOpca 	:= 0
LOCAL oDlg, oDlg1,oDlg2
LOCAL oGet
LOCAL oValor	:= 0
LOCAL oQtdTit 	:= 0
LOCAL oValorFat := 0
LOCAL cMarca	:= GetMark()
LOCAL aMoedas	:= {}
LOCAL cVar,nO
LOCAL OCbx, nRegE1
LOCAL lUsado	:= .F.
LOCAL aCampos 	:= {}
LOCAL aTam 		:= {}
LOCAL cAliasSE1 := "SE1"
Local cFilSX6
Local lHead 	:= .F.
Local nValTotal := 0
Local aBut240
Local oTimer
Local nTimeOut  := SuperGetMv("MV_FATOUT",,900)*1000 	// Estabelece 15 minutos para que o usuarios selecione os titulos a faturar
Local nTimeMsg  := SuperGetMv("MV_MSGTIME",,120)*1000 	// Estabelece 02 minutos para exibir a mensagem para o usu�rio
                                                      	// informando que a tela fechar� automaticamente em XX minutos
Local lFa281chk:= Existblock("FA281CHK")
Local aChaveLbn := {}
Local aSize 	:= {}        
Local oPanel
#IFDEF TOP
	Local cQuery
	Local aStru		:= SE1->(DbStruct())
	Local cFilDeb	:= SuperGetMv("MV_FATFIL",,"")
#ENDIF

//Variaveis de uso Automa��o

Local nRegAuto	:= 0
Local nI			:= 0
Local lGetAuto 	:= FindFunction("GetParAuto")

//Rastreamento
Local lRastro		:= FVerRstFin()
Local aRastroOri	:= {}
Local aRastroDes	:= {}
Local nValProces	:= 0
Local	nRecno		:= 0

//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emiss�o(default))
Local lPccBxCr		:= FPccBxCr()
Local aPccBxCr		:= {0,0,0,0}		//Pcc aqui
Local cPccBxCr		:= ""
Local nPropPcc		:= 1
Local nPis			:= 0
Local nCofins		:= 0
Local nCsll			:= 0
Local nTotPis		:= 0
Local nTotCofins	:= 0
Local nTotCsll		:= 0
Local nTotFatura	:= 0
Local cFiltroAbat 	:= ""
Local cChaveSE1	  	:= ""
Local nTotBase		:= 0
Local nBaseImp		:= 0
//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr()
Local aDadosIr 		:= {0,0} //aDadosIR[1] - valor do IRRF  / aDadosIR[2] - Base de calculo do IR
Local cIrBxCr		:= ""
Local nPropIR		:= 1
Local nIrrf			:= 0
Local nTotIr   		:= 0   
Local nTotBaseIr	:= 0
Local lPrefix 		:= .F.

//Situacao de cobranca
Local cLstCart	:= FN022LSTCB(1,"0005")	//Lista das situacoes de cobranca - CARTEIRA
Local cMay			:= ""
Local lBlqFat		:= .F.

PRIVATE aHeader 	:= {}
PRIVATE aCols		:= {}
PRIVATE oValTot
PRIVATE nValTot 	:= 0
PRIVATE nUsado 	:= 0
PRIVATE nValCruz	:= 0
PRIVATE nVarURV 	:= 0
PRIVATE lInverte	:= .F.
PRIVATE cTipo		:= Criavar ("E1_TIPOFAT")
PRIVATE cLote
PRIVATE nOrdSE1	:= 0
PRIVATE aVlrFat	:= {{0, 0}} // Valores a faturar
PRIVATE nVlrAtu 	:= 0 //Utilizada pelo programa FINA280
PUBLIC aVlCruz	:= {} // Deve ficar como public por causa do FINA290(GravaDp)
PRIVATE cFilMsg   := "2" //Filtra movimentos de msg unica 

Default lAutomato		:= .F.

If lFa281chk
	If !(Execblock("FA281CHK",.f.,.f.))
		Return
	Endif
Endif

//��������������������������������������������������������������Ŀ
//� Inicializa array com as moedas existentes.				     �
//����������������������������������������������������������������
aMoedas := FDescMoed()
ASort( aMoedas )
dbSelectArea( cAlias )

//��������������������������������������������������������������Ŀ
//� Verifica se data do movimento n�o � menor que data limite de �
//� movimentacao no financeiro    								 �
//����������������������������������������������������������������
If !DtMovFin(,,"2") 
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se o campo A1_CLIFAT est� em uso   				 �
//����������������������������������������������������������������
dbSelectArea("SX3")
dbSetOrder( 2 )
dbSeek("A1_CLIFAT")
lUsado := x3uso(X3_USADO)

dbGotop()
dbSeek("E1_PREFIXO")
cPictPref := AllTrim(X3_PICTURE)
dbSetOrder(1)

//��������������������������������������������������������������Ŀ
//� Verifica o numero do Lote 									 �
//����������������������������������������������������������������
LoteCont("FIN")

cPrefix		:= PADR(SuperGetMv("MV_FATPREF",,Space(3)),3)
lPrefix		:= Empty(cPrefix)
cNat		:=	Space(10)
dDataDe		:=	dDataBase
dDataAte 	:=	dDataBase
nValorFat	:=	0

aTam		:=	TamSX3("E1_CLIENTE")
cCli		:=	Space(aTam[1])
cCliFat		:=	Space(aTam[1])

aTam		:=	TamSX3("E1_LOJA")
cLoja	 	:=	Space(aTam[1])
cLojaFat	:=	Space(aTam[1])

dbSelectArea(cAlias)
//���������������������������������������������������������������Ŀ
//� PONTO DE ENTRADA F280PRE                                      �
//� Este PE serve para inicializar dados para montagem da fatura  �
//�����������������������������������������������������������������
IF ExistBlock("F280PRE")
	ExecBlock("F280PRE",.F.,.F.)
Endif

//��������������������������������������������������������������Ŀ
//� Recebe dados a serem digitados							     �
//����������������������������������������������������������������
cVar := aMoedas[1]

aTam := TamSx3("E1_NUM")
cFatura	:= Soma1( GetMv("MV_NUMFAT"),  aTam[1])
cFatura	+= Space(aTam[1] - Len(cFatura))
cMay    := "SE1"+xFilial("SE1")+cFatura

SE1->(DbSetOrder(1))
While SE1->(MsSeek(xFilial("SE1")+PadR(cPrefix,3)+cFatura)) .Or. !MayIUseCode(cMay)
	// busca o proximo numero disponivel 
	cFatura := Soma1(cFatura)
	cMay    := "SE1"+xFilial("SE1")+cFatura
EndDo

DEFINE MSDIALOG oDlg FROM	22,9 TO 260,540 TITLE STR0009 PIXEL  // "Faturas a Receber"

aTam := TamSx3("E1_NUM")

@ 020, 014	MSGET cPrefix	Picture cPictPref When lPrefix		SIZE 06, 11 OF oDlg PIXEL
@ 020, 037	MSGET cTipo		F3 "05"	Picture "@!" Valid (!Empty (cTipo) .and. FA280Tipo(@cTipo));
				SIZE 10, 11 OF oDlg PIXEL Hasbutton
@ 020, 068	MSGET cNat		F3 "SED" Valid Fa280Nat()       		SIZE 55, 11 OF oDlg PIXEL Hasbutton
@ 020, 123	COMBOBOX oCbx VAR cVar ITEMS aMoedas 					SIZE 46, 55 OF oDlg PIXEL
@ 020, 172	MSGET dEmisFat	Valid Fa281ValEmis()						SIZE 50, 11 OF oDlg PIXEL Hasbutton

@ 054, 014	MSGET dDataDe	Valid !Empty(dDataDe)					SIZE 50, 11 OF oDlg PIXEL Hasbutton
@ 054, 068	MSGET dDataAte Valid !Empty(dDataAte) .and.  dDataAte >= dDataDe .and. dDataAte <= dDataBase	 ;
				SIZE 50, 11 OF oDlg PIXEL Hasbutton
If cPaisLoc<>"CHI"
	@ 054, 120 MSGET nValorFat Picture "@E 9,999,999,999.99"  SIZE 65, 11 OF oDlg PIXEL Hasbutton
Else
	@ 054, 120 MSGET nValorFat Picture "@E 999,999,999,999"  SIZE 65, 11 OF oDlg PIXEL Hasbutton
Endif
@ 054, 172  MSGET cFatura	Valid !Empty(cFatura) .and. FA280NUM()	when lBlqFat SIZE 43, 11 OF oPanel PIXEL
@ 085, 014	MSGET cCli	F3 "SA1" Valid Fa280Cli(cCli) 				SIZE 65, 11 OF oDlg PIXEL Hasbutton
@ 085, 086	MSGET cLoja	Picture "@!" Valid Fa280Cli(cCli,cLoja)	SIZE 21, 11 OF oDlg PIXEL
If lUsado
	@ 085, 120 MSGET cCliFat F3 "SA1" Valid Fa280Cli(cCliFat)						SIZE 70,11 OF oDlg PIXEL Hasbutton
	@ 085, 192 MSGET cLojaFat	Picture "@!" Valid Fa280Cli(cCliFat,cLojaFat)	SIZE 10, 11 OF oDlg PIXEL
EndIf
@ 010, 014 SAY STR0010	OF oDlg PIXEL //"Pref."
@ 010, 037 SAY STR0054	OF oDlg PIXEL //"Tipo"
@ 010, 068 SAY STR0012	OF oDlg PIXEL //"Natureza"
@ 010, 123 SAY STR0013	OF oDlg PIXEL //"Moeda"
@ 010, 172 SAY STR0058	OF oDlg PIXEL //"Emiss�o da Fatura"

@ 044, 014 SAY STR0014 	OF oDlg PIXEL //"Emiss�o de"
@ 044, 068 SAY STR0015 	OF oDlg PIXEL //"At�"
@ 044, 120 SAY STR0016	OF oDlg PIXEL //"Valor da Fatura"
@ 044, 172 SAY STR0069	OF oDlg PIXEL //"Fatura"
@ 075, 014 SAY STR0017 	OF oDlg PIXEL //"Cliente"
@ 075, 086 SAY STR0018	OF oDlg PIXEL //"Loja"
If lUsado
	@ 075, 120 SAY STR0019 OF oDlg PIXEL //"Cliente a Faturar"
EndIf

@ 004, 007 TO 036, 225 OF oDlg PIXEL
@ 038, 007 TO 070, 225 OF oDlg PIXEL
@ 072, 007 TO 104, 225 OF oDlg PIXEL

If !lAutomato
	DEFINE SBUTTON FROM 07, 230 TYPE 1 ACTION (nOpca:=1,IF(Fa280Ok(oDlg),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 24, 230 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
Else

	If lGetAuto
		aRetAuto 	:= GetParAuto("FINA281TESTCASE")
		cPrefix	:= aRetAuto[1] //Prefixo
		cTipo		:= aRetAuto[2] //tipo
		dEmisFat	:= aRetAuto[3] //Emiss�o fatura
		cNat		:= aRetAuto[4] //Natureza
		cVar		:= aRetAuto[5] //Moeda
		dDataDe	:= aRetAuto[6] //Data de emiss�o de
		dDataAte	:= aRetAuto[7] //Data de emiss�o at�
		nValorFat	:= aRetAuto[8] //Valor da Fatura
		cCliFat	:= aRetAuto[9] //Cliente para sele��o dos t�tulos
		cLojaFat	:= aRetAuto[10] //Loja para sele��o dos t�tulos
		cCli		:= aRetAuto[11]//Cliente para gera��o dos t�tulos
		cLoja		:= aRetAuto[12]//Loja para gera��o dos t�tulos
		nOpca:=1
	EndIf

EndIf

If nOpca == 0
	Return
EndIf

nMoedFat := Val(Substr(cVar,1,2))

#IFDEF TOP
	cAliasSE1 := "QRYSE1"
	cQuery := ""
	aEval(aStru,{|x| cQuery += ","+AllTrim(x[1])})
	cQuery := "SELECT "+SubStr(cQuery,2)
	cQuery +=         ","+"SE1.R_E_C_N_O_ RECNO "
	cQuery	+= "FROM "+RetSqlName("SE1")+ " SE1 "
	cQuery	+= "WHERE "
	If !Empty(cFilDeb)
		cQuery += "E1_FILIAL IN "	+ FormatIN(cFilDeb,"/")
	Else
		cQuery += "E1_FILIAL='"	+ xFilial("SE1") + "'"
	Endif	
	cQuery	+= " AND E1_MOEDA=" + AllTrim(Str(nMoedFat,2,0)) 
	cQuery 	+= " AND E1_CLIENTE='"	+ cCli + "'"
	IF mv_par01==1
		cQuery += "AND E1_LOJA='"+cLoja+"'"
	EndIf
	cQuery	+= " AND E1_EMISSAO>='"+DTOS(dDataDe) + "'"
	cQuery 	+= " AND E1_EMISSAO<='"+DTOS(dDataAte)+ "'"
	cQuery	+= " AND E1_SITUACA='0'"
	cQuery	+= " AND E1_SALDO>0"
	cQuery	+= " AND E1_TIPO NOT IN "+FormatIN(MVRECANT+MVPROVIS,,3)
	cQuery	+= " AND E1_FATURA='"+Space(Len(SE1->E1_FATURA)) +"'"
	// Verifica integracao com PMS e nao permite FATURAR titulos que tenham solicitacoes
	// de transferencias em aberto.
	cQuery 	+= " AND E1_NUMSOL= ' '"
	
	//Condicao para omitir os titulos de abatimento que tenham o titulo principal em bordero
	cQuery += " AND R_E_C_N_O_ NOT IN( "
	cQuery += " SELECT SE1B.R_E_C_N_O_ "  
	cQuery += " FROM "+RetSqlName("SE1")+" SE1A, "+RetSqlName("SE1")+" SE1B "
	cQuery += " WHERE " 
	cQuery += " SE1A.E1_NUM = SE1B.E1_NUM AND "
	cQuery += " SE1A.E1_PREFIXO = SE1B.E1_PREFIXO AND " 
	cQuery += " SE1A.E1_PARCELA = SE1B.E1_PARCELA AND "
	cQuery += " SE1B.E1_TIPO IN "+FormatIN(MVABATIM,"|")+" AND " 	
	cQuery += " SE1A.E1_SITUACA NOT IN "+FormatIN(cLstCart,"|")+" AND "	
	cQuery += " SE1A.D_E_L_E_T_ <> '*' AND "
	cQuery += " SE1B.D_E_L_E_T_ <> '*' )"
	
	IF (ExistBlock("F281FIL"))
		cQuery += ExecBlock("F281FIL",.F.,.F., {cQuery})
	Endif
	cQuery	+= " AND D_E_L_E_T_ <> '*'"
	// Exclui o tipo da ordem para que os titulos sejam exibidos por ordem de 
	// prefixo+num+parcela. O tipo sera exibido conforme cadastrado, para que um titulo
	// de abatimento nao seja exibido antes do titulo principal.
	cQuery   += " ORDER BY " + SqlOrder(SubStr(SE1->(IndexKey(1)),1,At("E1_TIPO",SE1->(IndexKey(1)))-2)+"+RECNO")		
	
	Aadd(aStru, {"RECNO","N",10,0})

	//------------------
	//Cria��o da tabela temporaria 
	//------------------
	If _oFina2811 <> Nil
		_oFina2811:Delete()
		_oFina2811 := Nil
	Endif
	
	_oFina2811 := FWTemporaryTable():New( cAliasSe1 )  
	_oFina2811:SetFields(aStru) 	
	_oFina2811:AddIndex("1", {"E1_FILIAL","E1_CLIENTE","E1_LOJA","E1_PREFIXO","E1_NUM","E1_PARCELA"}) 	
	_oFina2811:AddIndex("2", {"E1_FILIAL","E1_TITPAI"}) 	
	_oFina2811:Create()	

	Processa({||SqlToTrb(cQuery, aStru, cAliasSe1)}) // Cria arquivo temporario
	DbSetOrder(0) // Fica na ordem da query
#ELSE
	//��������������������������������������������������������������Ŀ
	//� Cria indice condicional												  �
	//����������������������������������������������������������������
	DbSelectArea("SE1")
	cIndex := CriaTrab(nil,.f.)
	// Exclui o tipo da ordem para que os titulos sejam exibidos por ordem de 
	// prefixo+num+parcela. O tipo sera exibido conforme cadastrado, para que um titulo
	// de abatimento nao seja exibido antes do titulo principal.
	cChave	:= SubStr(SE1->(IndexKey(1)),1,At("E1_TIPO",SE1->(IndexKey(1)))-2)
	IndRegua("SE1",cIndex,cChave,,Fa280ChecF("FINA281"),STR0020)   //"Selecionando Registros..."
	nIndex := RetIndex(cAlias)
	dbSelectArea(cAlias)
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	
	//Tratamento para omitir os t�tulos de abatimento, cujo o t�tulo principal est� em bordero.                     
	If Select("__SE1") == 0
		ChkFile("SE1",.F.,"__SE1")
	Endif
	
	dbSelectArea("__SE1") 
	__SE1->(dbSetOrder(1))
	__SE1->(dbGoTop())
	
	SE1->(dbGoTop())
	
	While !(SE1->(Eof()))
		If (SE1->E1_TIPO $ MVABATIM)
			cChaveSE1 := xFilial(cAliasSE1)+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)
			If __SE1->(dbSeek(cChaveSE1))
				While !(__SE1->(Eof())) .And. __SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA) == cChaveSE1
					If !(__SE1->E1_TIPO $ MVABATIM) .And. !(__SE1->E1_SITUACA $ cLstCart)	
						If Empty(cFiltroAbat)
							cFiltroAbat += "!(E1_TIPO $ '"+MVABATIM+"' .And. ( E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA = '"+cChaveSE1+"'"
						Else
							cFiltroAbat += " .Or. E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA = '"+cChaveSE1+"'"
						Endif
						Exit	
					Endif
					__SE1->(dbSkip())
				Enddo
			Endif	
		Endif
		SE1->(dbSkip())
	Enddo
	
	If !Empty(cFiltroAbat)
		cFiltroAbat += ") )"
	Endif
	
	__SE1->(dbCloseArea())
	
#ENDIF                                

DbSelectArea(cAliasSE1)
Set Filter to &(cFiltroAbat)
DbGoTop()

If BOF() .and. EOF()
	Help(" ",1,"RECNO")
	RetIndex("SE1")
	Set Filter to
	dbSetOrder(1)
	dbGoTop()
	#IFDEF TOP
		DbSelectArea(cAliasSe1)
		DbCloseArea()
		
		//Deleta tabela tempor�ria no banco de dados
		If _oFina2811 <> Nil
			_oFina2811:Delete()
			_oFina2811 := Nil
		Endif
	#ELSE
		FErase(cIndex+OrdBagExt())
	#ENDIF
	Return
EndIF

nOpcA := 0

//����������������������������������������������������������������Ŀ
//� Monta array com capos a serem mostrados na marcacao de titulos �
//� Utiliza os capos em uso do SE1 mais o E1_SALDO que apesar de   �
//� nao estar em uso deve ser mostrado na tela.                    �
//������������������������������������������������������������������
AADD(aCampos,{"E1_OK","","  ",""})
dbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(MsSeek(cAlias))
While !EOF() .And. (x3_arquivo == cAlias)
	IF ( X3USO(x3_usado) .or. X3_CAMPO == "E1_SALDO  ") .AND. cNivel >= X3_NIVEL .AND. X3_CONTEXT != "V"
		AADD(aCampos,{X3_CAMPO,"",X3Titulo(),X3_PICTURE})
	Endif
	dbSkip()
Enddo
// Adiciona a coluna referente o valor a faturar
AADD(aCampos,{{||	nAscan := Ascan(aVlrFat,{|e| e[1] == (cAliasSe1)->(Recno())}),;
						If(nAscan > 0, aVlrFat[nAscan][2], If((cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT,(cAliasSe1)->E1_VALOR,(cAliasSe1)->E1_SALDO))},;
						"",STR0059, PesqPict("SE1","E1_SALDO")}) //"Valor a faturar"

dbSelectArea(cAliasSe1)

//��������������������������������������������������������������Ŀ
//� Marca os titulos ate o valor informado para a fatura 		 �
//����������������������������������������������������������������
nValor  := 0
nQtDTit := 0

If !lAutomato
	Fa280Marca(cAliasSe1,cMarca,nValorFat,aChaveLbn)
EndIf

nValorF := nValorFat

aBut240 := {{"EDIT",{||If((cAliasSe1)->E1_OK==cMarca,Fa281AltValor(cAliasSe1,oValor),IW_MsgBox(STR0060,STR0061,"STOP"))},STR0062,STR0090}} //"Titulo n�o selecionado. Edi��o n�o permitida."###"Aten��o"###"Edita o valor a faturar" //"Editar"

aSize := MSADVSIZE()	

DEFINE MSDIALOG oDlg1 TITLE STR0021 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //"Fatura a Receber"
oTimer:= TTimer():New((nTimeOut-nTimeMsg),{|| MsgTimer(nTimeMsg,oDlg1) },oDlg1) // Ativa timer
oTimer:Activate()
oDlg1:lMaximized := .T.

oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,40,40,.T.,.T. )
oPanel:Align := CONTROL_ALIGN_TOP

@ 008 , 005	SAY STR0051	+ cPrefix				FONT oDlg1:oFont PIXEL OF oPanel					//"Prefixo: "
@ 008 , 080	SAY STR0023	+ Substr(cNat,1,10) 	FONT oDlg1:oFont PIXEL OF oPanel					//"Natureza: "
@ 017 , 080	SAY STR0024	+ AllTrim(Str(nMoedFat,2,0))	FONT oDlg1:oFont PIXEL OF oPanel		//"Moeda: "

@ 008 , 150	Say STR0025 FONT oDlg1:oFont PIXEL OF oPanel		//"Valor Fatura"
@ 008 , 200	Say STR0094 FONT oDlg1:oFont PIXEL OF oPanel		//"Val. c/ Juros"
@ 008 , 250	Say STR0027 FONT oDlg1:oFont PIXEL OF oPanel		//"T�t. Selec."
If cPaisLoc<>"CHI"
	If nModulo == 43 // Modulo de Transporte (TMS)
		@ 017 , 150	Say oValorFat	VAR nValCruz	Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL OF oPanel		
	Else
		@ 017 , 150	Say oValorFat	VAR nValor		Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL OF oPanel
	EndIf
	@ 017 , 200	Say oValor		VAR nValor		Picture "@E 999,999,999.99" FONT oDlg1:oFont PIXEL OF oPanel
else
	If nModulo == 43 // Modulo de Transporte (TMS)
		@ 017 , 150	Say oValorFat	VAR nValCruz	Picture "@E 99,999,999,999" FONT oDlg1:oFont PIXEL OF oPanel		
	Else
		@ 017 , 150	Say oValorFat	VAR nValorF		Picture "@E 99,999,999,999" FONT oDlg1:oFont PIXEL OF oPanel		
	EndIf
	@ 017 , 200	Say oValor		VAR nValor		Picture "@E 99,999,999,999" FONT oDlg1:oFont PIXEL OF oPanel
endif
@ 017 , 250	Say oQtdTit 	VAR nQtdTit 	Picture "@E 999,999,999"  FONT oDlg1:oFont PIXEL OF oPanel 

@ 0.2 , 00.3 To 2.5,17 OF oPanel
@ 0.2 ,   17 To 2.5,39 OF oPanel

oMark :=MsSelect():New(cAliasSe1,"E1_OK","!E1_SALDO",aCampos,@lInverte,@cMarca,{45,oDlg1:nLeft,oDlg1:nBottom,oDlg1:nRight})
oMark:bMark := {||Fa280Exibe(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor,,,@nValCruz,oValorFat)}
oMark:bAval	:= {||Fa280bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor,,,aChaveLbn,@nValCruz,oValorFat)}
oMark:oBrowse:lhasMark := .t.
oMark:oBrowse:lCanAllmark := .t.
oMark:oBrowse:bAllMark := { || FA280Inverte(cAliasSe1,cMarca,oValor,oQtdTit,.T.,oMark,@nValor,,,,aChaveLbn,,@nValCruz,oValorFat) }
oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
If !lAutomato

	ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar(oDlg1,	{|| nOpca := 1,;
																			 IIF(Fa280ValOK(),IF(Fa280Soma(),oDlg1:End(),;
																			 Iif(Fa281Val(oValorFat),nOpca:=0,nOpca:=0)),nOpca:=0)},;
																		{|| nOpca := 2,oDlg1:End()},,aBut240);
									VALID (oTimer:End(),.T.) CENTERED
Else
	If lGetAuto
	
			nRegAuto := (cAliasSe1)->(Recno())
			(cAliasSe1)->(dbGoTop())
			While (cAliasSe1)->(!Eof())
				For nI := 1 to Len (aRetAuto[14])
					If 	(cAliasSe1)->(E1_FILIAL) 	== Padr(aRetAuto[14,nI,1],Len(SE1->E1_FILIAL))	.AND. ;//FILIAL
						(cAliasSe1)->(E1_PREFIXO) 	== Padr(aRetAuto[14,nI,2],Len(SE1->E1_PREFIXO)) 	.AND. ;//Prefixo
	   					(cAliasSe1)->(E1_NUM) 		== Padr(aRetAuto[14,nI,3],Len(SE1->E1_NUM)) 		.AND. ;//Numero
	   					(cAliasSe1)->(E1_PARCELA) 	== Padr(aRetAuto[14,nI,4],Len(SE1->E1_PARCELA)) 	.AND. ;//Parcela
	   					(cAliasSe1)->(E1_TIPO) 		== Padr(aRetAuto[14,nI,5],Len(SE1->E1_TIPO)) 		.AND. ;//Tipo
	   					(cAliasSe1)->(E1_CLIENTE) 	== Padr(aRetAuto[14,nI,6],Len(SE1->E1_CLIENTE)) 	.AND. ;//Cliente
	   					(cAliasSe1)->(E1_LOJA) 		== Padr(aRetAuto[14,nI,7],Len(SE1->E1_LOJA))				//loja]
	  						
	  						//efetua a Marca��o dos t�tulos   	
	  						Fa280bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor,,,aChaveLbn,@nValCruz,oValorFat,lAutomato)	
							nOpca := 1
					EndIf
				next nI
				(cAliasSe1)->(dbSkip())
			End
			
			(cAliasSe1)->(dbGoto(nRegAuto))
	Endif
Endif

dbSelectArea("SE1")

If nOpcA == 1
	
	cPccBxCr	:= Fa280VerImp(cNat,.T.)	//Impostos PCC com calculo para o Cliente/Natureza

	If !((ExistBlock("F280CON")))
		If lGetAuto .AND. lAutomato
			cCondicao	:= aRetAuto[13]//Condi��o de pagamento para gera��o dos t�tulos
		Else
			cCondicao := Fa281PedCd()				// Monta tela para pedir condicao de pgto
		EndIf
		aVenc := Condicao(nValor,cCondicao,0)
	Else
		aVenc := Execblock("F280CON",.f.,.f.,{nValor,cCondicao})
	Endif
	
	nDup	:= Len(aVenc)
	
	If nModulo == 43 // Modulo de Transporte (TMS)
		aCols :=	GravaDp(nDup,cPrefix,,nValCruz,dDatabase,aVenc,cTipo, "FINA281")		
	Else
		aCols :=	GravaDp(nDup,cPrefix,,nValor,dDatabase,aVenc,cTipo, "FINA281")
	EndIf	
	
	aVlCruz := {}
	aVlCruz := F280VlCruz(nDup,nValCruz)
	
	//������������������������������������������������������Ŀ
	//� Mostra tela com os diversos titulos						�
	//��������������������������������������������������������
	For no:=1 To Len(aCols)
		nValTot += aCols[no][5]
	Next
	
	nOpca := 0 
	aSize := MsAdvSize(,.F.,400)
	DEFINE MSDIALOG oDlg2 TITLE STR0028	From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	@ 1.4 , 00.8	SAY STR0029 //"Data Contabiliza��o : "
	@ 1.4 , 07.4	Say dDatCont FONT oDlg2:oFont
	@ 1.4 , 14		Say STR0030 //"Condi��o de Pagamento : "
	@ 1.4 , 22		Say cCondicao
	@ 1.4 , 27		Say STR0031 //"Valor Total:"
	If cPaisLoc<>"CHI"
		If nModulo == 43 // Modulo de Transporte (TMS)
			@ 1.4 , 32		Say oValTot VAR nValCruz Picture "@E 9,999,999,999.99" FONT oDlg2:oFont
		Else
			@ 1.4 , 32		Say oValTot VAR nValTot Picture "@E 9,999,999,999.99" FONT oDlg2:oFont
		EndIf
	Else
		If nModulo == 43 // Modulo de Transporte (TMS)
			@ 1.4 , 32		Say oValTot VAR nValCruz Picture "@E 999,999,999,999" FONT oDlg2:oFont
		Else 
			@ 1.4 , 32		Say oValTot VAR nValTot Picture "@E 999,999,999,999" FONT oDlg2:oFont		
		EndIf
	Endif	
	oGet := MSGetDados():New(34,5,aSize[4],aSize[3],3,"Fa280LinOk","Fa280TudOk","",.T.,,,,,,"",,"Fa280AtuVl(.F.)")
	
	If !lAutomato
		ACTIVATE MSDIALOG oDlg2 ON INIT EnchoiceBar(oDlg2,{||nOpca:=1,if(oGet:TudoOk(),oDlg2:End(),nOpca := 0)},{||oDlg2:End()})
	Else
		nOpca := 1
	EndIf
	
	If nOpcA == 1
		If Fa280Num(@cFatura) // Se nao existir o mesmo numero de fatura
			Begin Transaction	
				nTotAbat :=0
				dbSelectArea(cAliasSe1)
				nOrdSE1 := IndexOrd()
				dbGotop()
				nRegE1 := Nil
				While (cAliasSe1)->(!EOF()) .and. (cAliasSe1)->E1_EMISSAO >= dDataDe .and. (cAliasSe1)->E1_EMISSAO <= dDataAte
					
					IF !Empty(cFilDeb) .And. !((cAliasSe1)->E1_FILIAL $ cFilDeb)
						(cAliasSe1)->(dbSkip())
						Loop
					Endif
					// Nao considera titulos de abatimentos marcados, pois a rotina de baixa
					// ja os localiza e efetua sua baixa
					If (cAliasSe1)->E1_TIPO $ MVABATIM+"/"+MVINABT+"/"+MVIRABT
						(cAliasSe1)->(dbSkip())
						Loop
					Endif
					
					#IFNDEF TOP
						//Guardo o proximo registro	
						nRegE1	:=	(cAliasSe1)->(Recno())
						dbskip()
						nProxReg := (cAliasSe1)->(Recno())
						dbgoto(nRegE1)
					#ENDIF	

					If (cAliasSe1)->E1_OK == cMarca
						cNumero		:=	(cAliasSe1)->E1_NUM
						cPrefixo	:=	(cAliasSe1)->E1_PREFIXO
						cParcela	:=	(cAliasSe1)->E1_PARCELA
						cTitpai	   	:= SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA
						nRegE1		:=	(cAliasSe1)->(Recno())   

					EndIf
					dbSelectArea(cAliasSe1)
					#IFDEF TOP
						If (cAliasSe1)->(FieldPos("RECNO")) > 0
							DbSelectArea("SE1")
							MsGoto((cAliasSe1)->RECNO)
							DbSelectArea(cAliasSe1)
						Endif	
						SE1->(MsUnlock()) // Destrava registro marcado
						(cAliasSe1)->(dbSkip())
					#ELSE
						(cAliasSe1)->(MsUnlock()) // Destrava registro marcado
						(cAliasSe1)->(dbGoto(nProxReg))
					#ENDIF	
				Enddo
				nValTotal := 0

				//PCC Baixa CR
				//Necessario somar o total da fatura antes da geracao da fatura
				//para proporcionalizar o valor do PCC
				If lPccBxCR .or. lIrPjBxCr
					For nW:=1 To Len(aCols)
						If ! aCols[nW,Len(aHeader)+1] // .F. == Ativo  .T. == Deletado				
							nTotFatura += xMoeda(aCols[nW,5],nMoedFat,1)
						Endif
					Next						
				Endif	
	
				For nW:=1 To Len(aCols)
					If ! aCols[nW,7] // .F. == Ativo  .T. == Deletado
						cPrefix	:= aCols[nW][1]
						cParcela	:= aCols[nW][2]
						cTipo		:= aCols[nW][3]
						cVencmto	:= aCols[nW][4]
						nValDup	:= aCols[nW][5]
						nValCruz	:= xMoeda(aCols[nW,5],nMoedFat,1)
						cBanco	:= aCols[nW][6]
						nRecno	:= 0						

						//Gera fatura atraves da rotina automatica do Fina040 para que faca o recalculo 
						//e gere os abatimentos referente ao valor total titulos que serao selecionados;
						nValTotal	:= 0 
						nLen			:= Len(aCols)            
	
						//PCC Baixa CR
						//Tratamento da proporcionalizacao dos impostos PCC
						//para posterior gravacao na parcela gerada
						If lPccBxCR
							
							nPropPcc		:= nValCruz / nTotFatura
							nPis			:= Round(NoRound(aPccBxCr[1] * nPropPcc,3),2)
							nCofins	   		:= Round(NoRound(aPccBxCr[2] * nPropPcc,3),2)						
							nCsll			:= Round(NoRound(aPccBxCr[3] * nPropPcc,3),2)
							nBaseImp		:= Round(NoRound(aPccBxCr[4] * nPropPcc,3),2)
							nTotPis	   		+= nPis
							nTotCofins		+= nCofins
							nTotCsll		+= nCsll
							nTotBase		+= nBaseImp
							 						
							//Acerto de eventuais problemas de arredondamento
							If aPccBxCr[1] - nTotPis <= 0.01
								nPis		+= aPccBxCr[1] - nTotPis
							Endif
	
							If aPccBxCr[2] - nTotCofins <= 0.01
								nCofins	+= aPccBxCr[2] - nTotCofins
							Endif
	
							If aPccBxCr[3] - nTotCsll <= 0.01
								nCSll		+= aPccBxCr[3] - nTotCsll
							Endif
	
							If aPccBxCr[4] - nTotBase <= 0.01
								nBaseImp	+= aPccBxCr[4] - nTotBase
							Endif

 						Endif	

 					//IR Baixa CR
					//Tratamento da proporcionalizacao dos impostos IR
					//para posterior gravacao na parcela gerada
					If lIrPjBxCr
						nPropIr		:= nValCruz / nTotFatura
						nIrrf		:= Round(NoRound(aDadosIR[1] * nPropIr,3),2)
						nBaseImp	:= Round(NoRound(aDadosIR[2] * nPropIr,3),2)
						nTotIr		+= nIrrf
						nTotBaseIr	+= nBaseImp
						 						
						//Acerto de eventuais problemas de arredondamento
						If aDadosIR[1] - nTotIr <= 0.01
							nIrrf		+= aDadosIR[1] - nTotIr
						Endif      
						If aDadosIR[2] - nTotIr  <= 0.01
							nBaseImp	+= aDadosIR[2] - nTotIr
						Endif
					Endif

						//������������������������������Ŀ
						//� Grava a Fatura no SE1        �
						//��������������������������������
						FA280GrFat(cCliFat,cLojaFat,cCli,cLoja,cFatura,cPrefix,cParcela,cTipo,cVencmto,cNat,;
										cBanco,nValDup,nValCruz,nVARURV,1,nRegE1,cPadrao,@nTotal,@lHead,@cArquivo,;
										@nHdlPrv,,"FINA281",,,,,,@nRecno,nPis,nCofins,nCsll,nBaseImp,nIrrf)	//Pcc aqui)

						//Rastreamento - Gerados
						If lRastro
							//Reposiciono o SE1 pois a rotina FA280GrFat() 
							//nao retorna posicionada no registro incluido
							If	nRecno > 0
								SE1->(dbGoto(nRecno))
							Endif

							aadd(aRastroDes,{	SE1->E1_FILIAL,;
													SE1->E1_PREFIXO,;
													SE1->E1_NUM,;
													SE1->E1_PARCELA,;
													SE1->E1_TIPO,;
													SE1->E1_CLIENTE,;
													SE1->E1_LOJA,;
													SE1->E1_VALOR } )
						Endif			

						nValTotal += xMoeda(nValDup,nMoedFat,1)  // nValCruz
						dbSelectArea("SE1")
					Endif
				Next nW
				If nTotal > 0
					FA280ConFa(nValTotal,cPadrao,cArquivo,nHdlPrv,@nTotal,"FINA281",,lAutomato)
				Endif

				//Gravacao do rastreamento
				If lRastro
					FINRSTGRV(2,"SE1",aRastroOri,aRastroDes,nValProces) 
				Endif

				//-- Grava no SX6 o numero da ultima fatura gerada
				PutMV('MV_NUMFAT',cFatura)
			End Transaction
		Endif
	Else
		// Destrava os registros.
		dbSelectArea("SE1")
		While !EOF() .and. SE1->E1_EMISSAO >= dDataDe .and. SE1->E1_EMISSAO <= dDataAte
			IF SE1->E1_FILIAL != xFilial("SE1")
				dbSkip()
				Loop
			Endif
			#IFDEF TOP
				If (cAliasSe1)->(FieldPos("RECNO")) > 0
					DbSelectArea("SE1")
					MsGoto((cAliasSe1)->RECNO)
					DbSelectArea(cAliasSe1)
				Endif	
			#ENDIF
			SE1->(MsUnlock())
			dbSkip()
		Enddo
	Endif
Endif

If !Empty(aChaveLbn)
	aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) // Libera Lock
Endif

cFatura	:= CriaVar("E1_NUM")
cCli		:= Space(6)
cNat		:= Space(10)
cPrefix		:= Space(3)
cLoja 		:= Space(2)
dDataDe		:= dDatabase
dDataAte	:= dDataBase
nValorF		:= 0
nValorFat	:= 0
nValCruz 	:= 0
nVarURV		:= 0 
nVlrAtu  	:= 0
aVlCruz		:= {}

#IFDEF TOP
	DbSelectArea(cAliasSe1)
	DbCloseArea()

	//Deleta tabela tempor�ria no banco de dados
	If _oFina2811 <> Nil
		_oFina2811:Delete()
		_oFina2811 := Nil
	Endif
#ELSE
	RetIndex("SE1")
	If !Empty(cIndex)
		fErase(cIndex+OrdBagExt())
	Endif	
#ENDIF

//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados				    		 �
//����������������������������������������������������������������
dbSelectArea("SE1")
Set Filter to
dbSetOrder( 1 )
dbSeek(xFilial())
Return .T.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �fa281Val	� Autor � Pilar S. Albaladejo   � Data � 27/11/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pede que se digite o valor correto da fatura 			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � fa281Val(ExpO1)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA281													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fa281Val(oValorFat)

LOCAL oDlg
LOCAL nOpca := 0

DEFINE MSDIALOG oDlg FROM 10, 5 TO 17, 33 TITLE STR0052 //"Informe valor correto da Fatura"
@	.3,1 TO 2.3,12 OF oDlg
@	1.0,2 	Say STR0047 //"Valor : "
@	1.0,4.5	MSGET nValorF Picture "@E 999,999,999.99"
DEFINE SBUTTON FROM 034,042	TYPE 1 ACTION (nOpca := 1,If(!Empty(nValorF),oDlg:End(),nOpca:=0)) ENABLE OF oDlg
DEFINE SBUTTON FROM 034,069.1	TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg
oValorFat:Refresh()

Return .F.

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fa281PedCd� Autor � Pilar S. Albaladejo   � Data � 27/11/95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pede que se digite a condicao de pagamento				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Fa281PedCd(ExpO1) 										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA281													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fa281PedCd()

LOCAL oDlg
LOCAL nOpca := 0
LOCAL cCond := Space(3)

DEFINE MSDIALOG oDlg FROM 10, 5 TO 17, 33 TITLE STR0049 //"Informe Condi��o de Pagamento"
@	1.0,2 	Say STR0050 //"Condi��o: "
@	1.0,5.5	MSGET cCond F3 "SE4" Picture "!!!" Valid ExistCpo("SE4",cCond) .And.;
																	  Fa290Cond(cCond) Hasbutton
@	.3,1 TO 2.3,11.9 OF oDlg

DEFINE SBUTTON FROM 034,069.1	TYPE 1 ACTION (nOpca := 1,If(	!Empty(cCond)	.And. ;
															ExistCpo("SE4",cCond) 			.And. ;
															Fa290Cond(cCond),oDlg:End(),nOpca:=0)) ;
												 ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED

Return If(nOpca=0,"   ",cCond)

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �FA281ValEmi� Autor � Claudio D. de Souza  � Data � 23/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida data de emissao da fatura 						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � FA281ValEmis()											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1 = Valor Total do Lancamento                          ���
���          � ExpC2 = Codigo do lancamento Padronizado                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA281													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fa281ValEmis()
Local lRet := .T.

If Empty(dEmisFat) 
	NaoVazio(dEmisFat)
 	lRet := .F.
Endif

If lRet .and. CtbInUse()
	// Valida a Emissao da fatura para nao ser menor que o fechamento contabil	
	If !CtbValiDt(1,dEmisFat)
		lRet := .F.
	Endif
Endif

If lRet .and. dEmisFat > dDataBase
	IW_MsgBox(STR0064,STR0061,"STOP") //"Emiss�o da fatura n�o pode ser superior a data base do sistema"###"Aten��o"
	lRet := .F.
Endif

Return lRet

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fa281AltVa� Autor � Claudio D. de Souza   � Data � 24/10/02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Permite alterar o valor a ser faturado    				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Fa281AltValor() 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA281													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Fa281AltValor(cAliasSe1,oValor)

Local oDlg
Local nOpca 	:= 0
Local nValorFat := 0
Local nAscan

// Se nao existir o PE para permitir a alteracao do valor, ou se existir e retornar
// .T., abre a tela para que o usuario altere o valor.
If !ExistBlock("FA281VLR") .Or.;
	ExecBlock("FA281VLR",.F.,.F.)

	nAscan := Ascan(aVlrFat,{|e| e[1] == (cAliasSe1)->(Recno())})
	
	If nAscan > 0
		nValorFat := aVlrFat[nAscan][2]
	Else
		nValorFat := If((cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT,(cAliasSe1)->E1_VALOR,(cAliasSe1)->E1_SALDO)
	Endif
	
	DEFINE MSDIALOG oDlg FROM 10, 5 TO 17, 40 TITLE STR0065 //"Informe valor a faturar"
	@	1.0,1.5 	Say STR0059 //"Valor a Faturar"
	@	1.0,6.5	MSGET nValorFat Picture PesqPict("SE1","E1_SALDO") ;
					Valid Positivo() .And. nValorFat <= (cAliasSe1)->E1_SALDO
	@	.3,1 TO 2.3,16.3 OF oDlg
	
	DEFINE SBUTTON FROM 034,064.1	TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 034,099.2	TYPE 2 ACTION (nOpca := 2,oDlg:End()) ENABLE OF oDlg
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpca == 1
		// Atualiza o valor a faturar
		If nAscan > 0
			nValor -= aVlrFat[nAscan][2]
			aVlrFat[nAscan][2] := nValorFat
		Else
			nValor -= If((cAliasSe1)->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT,(cAliasSe1)->E1_VALOR,(cAliasSe1)->E1_SALDO)
			Aadd(aVlrFat, { (cAliasSe1)->(Recno()), nValorFat } )
		Endif
		nValor += nValorFat
		oValor:Refresh()
	Endif
Endif

Return Nil
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fa281Visua� Autor � Claudio D. De Souza   � Data � 10/04/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizacao dos titulos que montam uma fatura			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA281	 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fa281Visua(cAlias,cCampo,nOpcE)
LOCAL oDlg
LOCAL nOpca 	:= 0
Local cFiltro
Local cIndex	:=	""
Local cChave
Local cPrefFat	:= SE1->E1_PREFIXO
Local cFatura	:= SE1->E1_NUM
Local cTipoFat	:= SE1->E1_TIPO
Local aAreaSe1	:= SE1->(GetArea())
Local nValor	:= 0
Local nTitulos	:= 0
Local oBrw    
Local cFilDeb   := SuperGetMv ("MV_FATFIL",,"")
Local aBut240 	:=	{	{"PESQUISA"	,{||Fa281Pesq(oBrw,cAlias,cFiltro)},STR0066,STR0091},; //"Pesquisa Titulo" //"Pesquisa"
 						{"BMPVISUAL",{||Fa280Visual("SE1",SE1->(Recno()),1)},STR0067,STR0092},; //"Visualiza"
						{"EXCLUIR"	,{||Fa281CExcl()},STR0078,STR0093 }} // "Consulta Exclus�es" //"Consulta"

   If Empty (cFilDeb)
      cFiltro := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
      cFiltro += '(E1_FATURA=="'+Pad(cFatura,Len(E1_FATURA))+'".And.'
      cFiltro += 'E1_FATPREF=="'+cPrefFat+'".And.'
      cFiltro += 'E1_TIPOFAT=="'+cTipoFat+'")'    
     Else
      cFiltro := 'E1_FILIAL$"('+cFilDeb+')".And.'
      cFiltro += '(E1_FATURA=="'+Pad(cFatura,Len(E1_FATURA))+'".And.'
      cFiltro += 'E1_FATPREF=="'+cPrefFat+'".And.'
      cFiltro += 'E1_TIPOFAT=="'+cTipoFat+'")'    
   EndIf

// Abre o SE1 com outro alias para que em ambientes TOP o sistema tenha condicoes
// de localizar o titulo original para exibir na consulta de titulos excluidos,
// pois nestes ambientes o filtro atua sobre todas as ordens do arquivo em questao
ChkFile("SE1",.f.,"NEWSE1") 
If SE1->E1_STATUS == "C" // Fatura Cancelada, exibe a tela de titulos cancelados
	Fa281CExcl(cPrefFat,cFatura,cTipoFat)
Else
	//������������������������������������������������������������������������Ŀ
	//� Cria indice condicional separando os titulos que deram origem a fatura �
	//� e as respectivas faturas que foram geradas							   �
	//��������������������������������������������������������������������������
	cIndex := CriaTrab(nil,.f.)
	cChave := IndexKey()
	DbSelectArea("SE1")
	IndRegua("SE1",cIndex,cChave,,cFiltro,STR0020)  //"Selecionando Registros..."
	nIndex := RetIndex(cAlias)
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	dbGoTop()
	//������������������������������������������������������������������������Ŀ
	//� Certifica se foram encontrados registros na condi��o selecionada 	   �
	//��������������������������������������������������������������������������
	If EOF()
		Help(" ",1,"REGNOIS",, CHR(13) + STR0079+CHR(13)+; //"Titulo n�o � uma fatura. Posicione sobre"
													 STR0080+CHR(13),5,1) //"o t�tulo de fatura para visualiza-la."
	Else	
		dbSelectArea("SE1")
		nValor	 :=  0
		While !Eof()
		
			If	!(	SE1->E1_NUM = cFatura .And. Day(SE1->E1_BAIXA) > 0 .AND. ;
					SE1->E1_PREFIXO == cPrefFat .and. SE1->E1_TIPO == cTipoFat)
				// Verifica o total faturado
				dbSelectArea("SE5")
				dbSetOrder(7)
				If dbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
					While !Eof() .And. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == ;
											  SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
						If SE5->E5_MOTBX== "FAT" .And. SE5->E5_RECPAG == "R" .And.;
							SE5->E5_SITUACA != "C" .And. SE5->E5_FATURA == cFatura 	.And.;
							SE5->E5_FATPREF == cPrefFat .And. SE5->E5_TIPODOC $ "BA#VL"
							nValor += SE5->E5_VALOR
						Endif
						dbSkip()
					Enddo
				Endif
				dbSelectArea("SE1")
				nTitulos+= IIF(!Empty(SE1->E1_TIPOFAT), 1, 0)
				/*
				If !Empty(NEWE1_TIPOFAT) .And. SE1->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT
					nValor -= SE1->E1_VALOR
				Endif
				*/
			Endif
			dbSkip()
		Enddo
		
		DEFINE MSDIALOG oDlg FROM	09,0 TO 36,80 TITLE STR0068 OF oMainWnd //"Consulta de fatura a Receber"
		@ 35, 02 SAY STR0039	OF oDlg PIXEL //"Prefixo"
		@ 35, 70 SAY STR0054	OF oDlg PIXEL //"Tipo"
		@ 35,120 SAY STR0069 	OF oDlg PIXEL //"Fatura Numero"
		@ 55, 02 SAY STR0070	OF oDlg PIXEL //"Total Titulos"
		@ 55, 70 SAY STR0016	OF oDlg PIXEL //"Valor da Fatura"
				
		@ 35, 35 MSGET cPrefFat 	When .F.	OF oDlg PIXEL
		@ 35, 85 MSGET cTipoFat		When .F.	OF oDlg PIXEL
		@ 35,160 MSGET cFatura 		When .F.	OF oDlg PIXEL
		@ 55, 35 MSGET nTitulos 	When .F. SIZE 28, 08 OF oDlg PIXEL
		@ 55,110 MSGET nValor	 	When .F. Picture "@E 9,999,999,999.99" SIZE 63, 08 OF oDlg PIXEL
		
		oBrw := TCBrowse():New(72,3,310,127,,,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
		dbSelectArea("SX3")
		DbSetOrder(1)
		dbSeek("SE1")
		While !EOF() .And. (x3_arquivo == "SE1")
			If ( X3USO(x3_usado) .or. X3_CAMPO == "E1_SALDO  ") .AND. cNivel >= X3_NIVEL .AND. X3_CONTEXT != "V"
				If X3_TIPO != "N"
					oCol := TCColumn():New(x3Titulo(),If( ValType(FieldWBlock(X3_CAMPO,Select("SE1")))=="B", FieldWBlock(X3_CAMPO,Select("SE1")), {|| FieldWBlock(X3_CAMPO,Select("SE1"))} ),,,, "LEFT",,.F.,.F.,,,,.F.)
				Else	
					oCol := TCColumn():New(x3Titulo(),If( ValType(FieldWBlock(X3_CAMPO,Select("SE1")))=="B", FieldWBlock(X3_CAMPO,Select("SE1")), {|| FieldWBlock(X3_CAMPO,Select("SE1"))} ),X3_PICTURE,,,Upper("RIGHT"),,.F.,.F.,,,,.F.)
				Endif
				oBrw:ADDCOLUMN(oCol)
			Endif		
			dbSkip()
		Enddo
		dbSelectArea("SE1")
		dbGotop()
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()},,aBut240) CENTERED
	Endif
	//��������������������������������������������������������������Ŀ
	//� Recupera a Integridade dos dados						     �
	//����������������������������������������������������������������
	dbSelectArea(cAlias)
	Set Filter to
	RetIndex(cAlias)
	If !Empty(cIndex)
		fErase(cIndex+OrdBagExt())
		cIndex := ""
	Endif
Endif	

NEWSE1->(DbCloseArea())
SE1->(RestArea(aAreaSe1))

Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fa240Pesq � Autor � Claudio D. De Souza   � Data �08.02.01  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � tela de pesquisa - WINDOWS 								  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Fa281Pesq(oObj,cAlias,cFiltro)
Local cAliasAnt := Alias()		,;
		nOrderAnt := IndexOrd()	,;
		nRecno		

DbSelectArea(cAlias)
nRecno := Recno()
AxPesqui()

// Se o que foi digitado para pesquisa nao estiver dentro do filtro
// Continua no mesmo registro que estava antes de selecionar CTRL-P
If !&(cFiltro)
	dbGoto(nRecNo)
Endif

oObj:Refresh(.T.)

DbSelectArea(cAliasAnt)
DbSetOrder(nOrderAnt)

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fa281Exclu� Autor � Claudio D. De Souza   � Data � 10/04/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Excluir titulos de uma fatura							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA281	 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Fa281Exclui(cAlias,cCampo,nOpcE, lAutomato)
LOCAL oDlg
LOCAL nOpca 	:= 0
Local cFiltro
Local cIndex	:=	""
Local cChave
Local cPrefFat	:= SE1->E1_PREFIXO
Local cFatura	:= SE1->E1_NUM
Local cTipoFat	:= SE1->E1_TIPO
Local aAreaSe1	:= SE1->(GetArea())
Local nValor	:= 0
Local nTotFat	:= 0
Local nTitulos	:= 0
Local nTotExcluido := 0
Local nDiminui	:= 1
Local cMarca	:= GetMark()
Local aCampos	:= {}
Local lInverte	:= .F.
Local oValor	:= 0
Local oQtdTit 	:= 0
Local oMark
Local aBut240 	:=	{	{"PESQUISA"	,{||Fa281Pesq(oMark:oBrowse,cAlias,cFiltro)},STR0066,STR0091},; //"Pesquisa Titulo" //"Pesquisa"
							{"BMPVISUAL",{||Fa280Visual("SE1",SE1->(Recno()),1)},STR0067,STR0092},; //"Visualiza"
							{"EXCLUIR"	,{||Fa281CExcl()},STR0078,STR0093 }} // //"Consulta Exclus�es" //"Consulta"
Local nUltima
Local lSigaTms  := .F.
Local aTmsTit   := {}
Local aChaveLbn := {}

Local lRastro	:= FVerRstFin()
Local cChaveSE1 := ""
/*
 * Vari�veis Necess�rias para Grava��o dos Movimentos Banc�rios
 */
Local aAreaAnt		:= {}
Local oModelMov		:= Nil 
Local cLog			:= ""
Local lRet			:= .T.

//Variaveis de uso Automa��o

Local nRegAuto	:= 0
Local nI			:= 0
Local lGetAuto 	:= FindFunction("GetParAuto")
Local cAliasSe1	:= "SE1"


#IFDEF TOP
	Local cFilDeb	:= SuperGetMv("MV_FATFIL",,"")
#ENDIF
PRIVATE nValCruz:= 0
PRIVATE nVarURV := 0     
PRIVATE aVlrFat := {{0, 0}} // Valores a faturar
PRIVATE nVlrAtu := 0 //Utilizada pelo programa FINA280
PRIVATE cLote

Default lAutomato:= .F.

//-- Verifica se a fatura foi gerada pelo modulo SIGATMS.
If AllTrim(SE1->E1_ORIGEM) == "TMSA490"
	lSigatms := .T.
EndIf

If SE1->E1_LA = "S"
	IW_MsgBox(STR0081,STR0061,"STOP") //"Esta fatura j� foi contabilizada, n�o pode ser modificada"
	Return
Endif

If SE1->E1_STATUS = "C"
	IW_MsgBox(STR0082,STR0061,"STOP") //"Esta fatura j� foi cancelada"
	Return
Endif

//Fun��o de bloqueio pelo calendario
If !CtbValiDt(,dDatabase,,,,{"FIN002"},)
	Return
EndIf

#IFDEF TOP
	If Empty (cFilDeb)
     cFiltro := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
     cFiltro += '(E1_FATURA=="'+Pad(cFatura,Len(E1_FATURA))+'".And.'    
	Else
     cFiltro := 'E1_FILIAL$"('+cFilDeb+')".And.'
     cFiltro += '(E1_FATURA=="'+Pad(cFatura,Len(E1_FATURA))+'".And.'   
	EndIf
#ELSE
	cFiltro := '(E1_FATURA=="'+Pad(cFatura,Len(E1_FATURA))+'".And.'
#ENDIF
cFiltro += 'E1_FATPREF=="'+cPrefFat+'".And.'
cFiltro += 'E1_TIPOFAT=="'+cTipoFat+'")'

//������������������������������������������������������������������������Ŀ
//� Cria indice condicional separando os titulos que deram origem a fatura �
//� e as respectivas faturas que foram geradas							   �
//��������������������������������������������������������������������������
cIndex := CriaTrab(nil,.f.)
cChave := "E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA"
// Abre o SE1 com outro alias para que em ambientes TOP o sistema tenha condicoes
// de localizar o titulo original para exibir na consulta de titulos excluidos,
// pois nestes ambientes o filtro atua sobre todas as ordens do arquivo em questao
ChkFile("SE1",.f.,"NEWSE1") 
dbSelectArea(cAlias)
IndRegua("SE1",cIndex,cChave,,cFiltro,STR0020)  //"Selecionando Registros..."
nIndex := RetIndex(cAlias)
#IFNDEF TOP
	dbSetIndex(cIndex+OrdBagExt())
#ENDIF
dbSetOrder(nIndex+1)
dbGoTop()

//������������������������������������������������������������������������Ŀ
//� Certifica se foram encontrados registros na condi��o selecionada 	   �
//��������������������������������������������������������������������������
If EOF()                                                                                       
	Help(" ",1,"REGNOIS",, CHR(13) + STR0079+CHR(13)+; //"Titulo n�o � uma fatura. Posicione sobre"
												 STR0083+CHR(13),5,1) //"o t�tulo de fatura para cancela-la."
Else	
	//����������������������������������������������������������������Ŀ
	//� Monta array com capos a serem mostrados na marcacao de titulos �
	//� Utiliza os capos em uso do SE1 mais o E1_SALDO que apesar de   �
	//� nao estar em uso deve ser mostrado na tela.                    �
	//������������������������������������������������������������������
	AADD(aCampos,{"E1_OK","","  ",""})
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !EOF() .And. (x3_arquivo == cAlias)
		IF ( X3USO(x3_usado) .or. X3_CAMPO == "E1_SALDO  ") .AND. cNivel >= X3_NIVEL .AND. X3_CONTEXT != "V"
			AADD(aCampos,{X3_CAMPO,"",X3Titulo(),X3_PICTURE})
		Endif
		dbSkip()
	Enddo

	dbSelectArea("SE1")
	nValor	 :=  0
	While !Eof()
	
		If	!(	SE1->E1_NUM == cFatura .And. Day(SE1->E1_BAIXA) > 0 .AND. ;
				SE1->E1_PREFIXO == cPrefFat .and. E1_TIPO == cTipoFat)
			// Verifica o total faturado
			dbSelectArea("SE5")
			dbSetOrder(7)
			If dbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA))
				While !Eof() .And. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == ;
										  SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
					If SE5->E5_MOTBX== "FAT" .And. SE5->E5_RECPAG == "R" .And.;
						SE5->E5_SITUACA != "C" .And. SE5->E5_FATURA == cFatura 	.And.;
						SE5->E5_FATPREF == cPrefFat .And. SE5->E5_TIPODOC $ "BA,VL" 
						nValor += SE5->E5_VALOR
						nAscan := Ascan(aVlrFat,{|e| e[1] == SE1->(Recno())})
						If nAscan > 0
							aVlrFat[nAscan][2] += SE5->E5_VALOR
						Else
							Aadd(aVlrFat,{SE1->(Recno()),SE5->E5_VALOR})
						Endif
					Endif
					dbSkip()
				Enddo
			Endif
			dbSelectArea("SE1")
			nTitulos+= IIF(!Empty(E1_TIPOFAT), 1, 0)
			If !Empty(E1_TIPOFAT) .And. SE1->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT
				//nValor -= SE1->E1_VALOR
				nAscan := Ascan(aVlrFat,{|e| e[1] == SE1->(Recno())})
				If nAscan > 0
					aVlrFat[nAscan][2] += SE1->E1_VALOR
				Else
					Aadd(aVlrFat,{SE1->(Recno()),SE1->E1_VALOR})
				Endif
			Endif
		Endif
		dbSkip()
	Enddo
	nTotFat	:= nValor // Total da Fatura
	DEFINE MSDIALOG oDlg FROM	09,0 TO 34,80 TITLE STR0068 OF oMainWnd //"Consulta de fatura a Receber"
	@ 45, 02 SAY STR0039	OF oDlg PIXEL //"Prefixo"
	@ 45, 70 SAY STR0054	OF oDlg PIXEL //"Tipo"
	@ 45,120 SAY STR0069 	OF oDlg PIXEL //"Fatura Numero"
	@ 65, 02 SAY STR0070	OF oDlg PIXEL //"Total Titulos"
	@ 65, 70 SAY STR0016	OF oDlg PIXEL //"Valor da Fatura"
			
	@ 45, 35 MSGET cPrefFat 	When .F.	OF oDlg PIXEL
	@ 45, 85 MSGET cTipoFat		When .F.	OF oDlg PIXEL
	@ 45,160 MSGET cFatura 		When .F.	OF oDlg PIXEL
	@ 65, 35 MSGET oQtdTit 	VAR nTitulos 	When .F. SIZE 28, 08 OF oDlg PIXEL
	@ 65,110 MSGET oValor	VAR nValor	 	When .F. Picture "@E 9,999,999,999.99" SIZE 63, 08 OF oDlg PIXEL
	nTotFat	:= nValor
	oMark :=MsSelect():New("SE1","E1_OK","!E1_VALOR",aCampos,@lInverte,@cMarca,{82,3,165,313},"cTopFun281()","cBotFun281()")
	oMark:bMark := {||Fa280Exibe("SE1",cMarca,oValor,oQtdTit,oMark,@nValor,@nTotExcluido,.T.)}
	oMark:bAval	:= {||Fa280bAval("SE1",cMarca,oValor,oQtdTit,oMark,@nValor,@nTotExcluido,.T.,aChaveLbn)}
	oMark:oBrowse:lhasMark := .t.
	oMark:oBrowse:lCanAllmark := .t.
	oMark:oBrowse:bAllMark := { || FA280Inverte("SE1",cMarca,oValor,oQtdTit,.T.,oMark,@nValor,@nTotExcluido,.T.,,aChaveLbn)}
	dbSelectArea("SE1")
	dbGotop()
	If !lAutomato
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()},,aBut240) CENTERED
	Else
		If lGetAuto
				aRetAuto 	:= GetParAuto("FINA281TESTCASE")
				nRegAuto := (cAliasSe1)->(Recno())
				(cAliasSe1)->(dbGoTop())
				While (cAliasSe1)->(!Eof())
					For nI := 1 to Len (aRetAuto[1])
						If 	(cAliasSe1)->(E1_FILIAL) 	== Padr(aRetAuto[1,nI,1],Len(SE1->E1_FILIAL))	.AND. ;//FILIAL
							(cAliasSe1)->(E1_PREFIXO) 	== Padr(aRetAuto[1,nI,2],Len(SE1->E1_PREFIXO)) 	.AND. ;//Prefixo
		   					(cAliasSe1)->(E1_NUM) 		== Padr(aRetAuto[1,nI,3],Len(SE1->E1_NUM)) 		.AND. ;//Numero
		   					(cAliasSe1)->(E1_PARCELA) 	== Padr(aRetAuto[1,nI,4],Len(SE1->E1_PARCELA)) 	.AND. ;//Parcela
		   					(cAliasSe1)->(E1_TIPO) 		== Padr(aRetAuto[1,nI,5],Len(SE1->E1_TIPO)) 		.AND. ;//Tipo
		   					(cAliasSe1)->(E1_CLIENTE) 	== Padr(aRetAuto[1,nI,6],Len(SE1->E1_CLIENTE)) 	.AND. ;//Cliente
		   					(cAliasSe1)->(E1_LOJA) 		== Padr(aRetAuto[1,nI,7],Len(SE1->E1_LOJA))				//loja]
		  						
		  						//efetua a Marca��o dos t�tulos   		
		  						Fa280bAval(cAliasSe1,cMarca,oValor,oQtdTit,oMark,@nValor,@nTotExcluido,.T.,aChaveLbn,,,lAutomato)
								nOpca := 1
						EndIf
					next nI
					(cAliasSe1)->(dbSkip())
				End
				
				(cAliasSe1)->(dbGoto(nRegAuto))
		Endif
	Endif
Endif

If nOpcA == 1
	DbSelectArea("SE1")
#IFDEF TOP
	If Empty (cFilDeb)
     cFiltro := 'E1_FILIAL=="'+xFilial("SE1")+'".And.'
     cFiltro += '!Empty(E1_FATURA).And.'
   Else    
	  cFiltro := 'E1_FILIAL$"('+cFilDeb+')".And.'
	  cFiltro += '!Empty(E1_FATURA).And.'
	Endif
#ELSE
	cFiltro := '!Empty(E1_FATURA).And.'
#ENDIF
	cFiltro += '((E1_NUM=="'+Pad(cFatura,Len(E1_NUM))+'".And.'
	cFiltro += 'E1_PREFIXO=="'+cPrefFat+'".And.'
	cFiltro += 'E1_FATURA=="'+ Pad("NOTFAT",Len(E1_FATURA)) + '" .and.'
	cFiltro += 'E1_TIPO=="'+cTipoFat+'").Or.'
	cFiltro += '(E1_FATURA=="'+Pad(cFatura,Len(E1_FATURA))+'".And.'
	cFiltro += 'E1_FATPREF=="'+cPrefFat+'".And.'
	cFiltro += 'E1_TIPOFAT=="'+cTipoFat+'"))'
	//������������������������������������������������������������������������Ŀ
	//� Cria indice condicional separando os titulos que deram origem a fatura �
	//� e as respectivas faturas que foram geradas								      �
	//��������������������������������������������������������������������������
	cIndex := CriaTrab(nil,.f.)
	cChave := IndexKey()
	IndRegua("SE1",cIndex,cChave,,cFiltro,STR0020)  //"Selecionando Registros..."
	nIndex := RetIndex(cAlias)
	dbSelectArea(cAlias)
	#IFNDEF TOP
		dbSetIndex(cIndex+OrdBagExt())
	#ENDIF
	dbSetOrder(nIndex+1)
	nDiminui := nTotExcluido / nTotFat // Total a diminuir de cada titulo
	nTotal	:= 0
	nRegs		:= 0
	nUltima	:= 0
	DbGoTop()
	While !Eof()
		If	!(	SE1->E1_NUM = cFatura .And. Day(SE1->E1_BAIXA) > 0 .AND. ;
				SE1->E1_PREFIXO == cPrefFat .and. E1_TIPO == cTipoFat)
			If SE1->E1_OK == cMarca // Esta marcado para excluir 

				// Cancelamento do rastreamento(FI7/FI8)
				cChaveSe1:= SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
				If lRastro
					FINRSTDEL("SE1",cChaveSe1)
				Endif

				// Limpa a fatura
				nAscan := Ascan(aVlrFat,{|e| e[1] == SE1->(Recno())})
				// Sera utilizada no lancamento padrao 592
				ABATIMENTO := 0
				If nAscan > 0
					If ! SE1->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT
						ABATIMENTO := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,dDataBase,SE1->E1_CLIENTE,SE1->E1_LOJA)
					Endif
					SE5->(DbSetOrder(2))
					FA280Movim("SE1",xFilial("SE1"),SE1->E1_NUM,dDataBase,"P","BA",STR0063 + SE1->E1_FATURA,"BCF",cFatura,cPrefFat,SE1->E1_SDACRES,SE1->E1_SDDECRE) //"Bx.p/Canc.Fat."
					RecLock("SE1")
					SE1->E1_SALDO		+= If(SE1->E1_TIPO$MVABATIM+"/"+MVINABT+"/"+MVIRABT,SE1->E1_VALOR, SE1->E1_VALLIQ) - SE1->E1_JUROS + SE1->E1_DESCONT + ABATIMENTO
					SE1->E1_VALLIQ		:= 0			 			  // Tira o valor faturado
					SE1->E1_MOVIMEN	:= dDataBase
					SE1->E1_FATURA 	:= " "
					SE1->E1_FATPREF	:= " "
					SE1->E1_TIPOFAT	:= " "
					SE1->E1_DTFATUR	:= CtoD("  /  /  ")
					SE1->E1_STATUS 	:= Iif(SE1->E1_SALDO>0.01,"A","B")
					If SE1->E1_SALDO == SE1->E1_VALOR
						SE1->E1_BAIXA		:= CtoD("  /  /  ")
					Endif
					SE1->E1_FLAGFAT   := Space(Len(SE1->E1_FLAGFAT))
					MsUnlock()
				Endif
				
				DbSelectArea("SE5")
				SE5->(DbSetOrder(7)) // Filial + Prefixo + N�mero + Parcela + Tipo + Cliente/Fornecedor + Loja + Sequ�ncia				
				If SE5->(dbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
					While SE5->(!Eof()) .AND. SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == ;
											  SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)
						If SE5->E5_MOTBX$"FAT#BCF" .AND. SE5->E5_RECPAG == "R" .AND. SE5->E5_SITUACA != "C"
						
							/*
							 * Atualiza��o da tabela de movimentos banc�rios e gera��o das novas tabelas de movimentos banc�rios.
							 * Cancelamento de Baixa
							 */
							oModelMov		:= FWLoadModel("FINM010")
							If AllTrim( SE5->E5_TABORI ) == "FK1"
								aAreaAnt := GetArea()
								dbSelectArea( "FK1" )
								FK1->( DbSetOrder( 1 ) )
								If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
									oModelMov:SetOperation( 4 ) //Altera��o
									oModelMov:Activate()
									oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita grava��o SE5
									//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
									//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK5
									//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK5
									oModelMov:SetValue( "MASTER", "E5_OPERACAO", 1 ) //E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK5
									
									If oModelMov:VldData()
								       	oModelMov:CommitData()
									Else
										lRet := .F.
									    cLog := cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
									    cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
									    cLog += cValToChar(oModelMov:GetErrorMessage()[MODEL_MSGERR_MESSAGE])        	
									Endif								
								Endif
								RestArea(aAreaAnt)
							EndIf
							oModelMov:DeActivate()
							oModelMov:Destroy()
							oModelMov := Nil
						EndIf
						SE5->(dbSkip())
					EndDo
					
					If !lRet
						Help( ,,"M030VALID",,cLog, 1, 0 )
					EndIf						
				EndIf
				
				DbSelectArea("SE1")
				//-- Armazena os titulos cancelados, utilizado pelo modulo SIGATMS
				If lSigaTms
					Aadd(aTmsTit, { SE1->E1_NUM, SE1->E1_PREFIXO }  )
				EndIf
			Else
				If Empty(E1_TIPOFAT)
					RecLock("SE1")
					nUltima := RECNO()
					// Altera o valor dos titulos, de acordo com o novo valor da fatura
					SE1->E1_VALOR -= SE1->E1_VALOR * nDiminui
					nTotal += SE1->E1_VALOR
					nRegs++
					SE1->E1_SALDO := SE1->E1_VALOR
					If nValor == 0
						SE1->E1_STATUS := "C" // Indica fatura cancelada
					Endif
					MsUnlock()
				Endif
			Endif
		Endif
		dbSkip()
	Enddo
	If nUltima > 0 .And. nTotal != nValor .And. nValor > 0 .And. nTotal > 0
		// Acerta o total na ultima parcela
		DbGoto(nUltima)
		RecLock("SE1")
		SE1->E1_VALOR += (nValor - nTotal) 
		SE1->E1_SALDO := SE1->E1_VALOR
		MsUnlock()
	Endif	
Endif
//��������������������������������������������������������������Ŀ
//� Recupera a Integridade dos dados							 �
//����������������������������������������������������������������
dbSelectArea(cAlias)
Set Filter to
RetIndex(cAlias)
If !Empty(cIndex)
	fErase(cIndex+OrdBagExt())
	cIndex := ""
Endif
NEWSE1->(DbCloseArea())
SE1->(RestArea(aAreaSe1))

If !Empty(aChaveLbn)
	aEval(aChaveLbn, {|e| UnLockByName(e,.T.,.F.) } ) // Libera Lock
Endif

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Fa281CExcl� Autor � Claudio D. De Souza   � Data � 10/04/93 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Visualizacao dos titulos que foram excluidos de uma fatura ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � FINA281	 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Fa281CExcl(cPrefFat,cFatura,cTipoFat)
LOCAL oDlg
LOCAL nOpca 	:= 0
Local cFiltro	:= ""
Local aAreaSe5	:= SE5->(GetArea())
Local aAreaSe1	:= SE1->(GetArea())
Local aArea		:= GetArea()
Local aCampos	:= {}
Local oCol
Local oBrw
Local nAlias
Local cAliasSe5

Local aBut240 	:=	{	{"BMPVISUAL",{||	NEWSE1->(DbSetOrder(1)),;
													NEWSE1->(MsSeek(xFilial("SE1")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO))),;
													SE1->(DbGoto(NEWSE1->(Recno()))),;
													Fa280Visual("SE1",SE1->(Recno()),1),;
													SE1->(RestArea(aAreaSe1))},STR0067,STR0092}}  //"Visualiza"


#IFDEF TOP
	Local cArqTrab
	Local aStru
	Local nX := 0
#ELSE
	Local cIndex	:=	""
	Local cChave
#ENDIF

DEFAULT cPrefFat	:= E1_FATPREF
DEFAULT cFatura		:= E1_FATURA
DEFAULT cTipoFat	:= E1_TIPO

	
aCampos :=	{	"E5_DATA", "E5_TIPO", "E5_PREFIXO", "E5_NUMERO" , ;
				 	"E5_PARCELA", "E5_VALOR" }

#IFDEF TOP
	aEval(aCampos, {|e| cFiltro += "," + e })
	aStru := SE5->(DbStruct())
	// Elimina da estrutura os campos nao necessarios
	For nX := Len(aStru) To 1 Step -1
		If Ascan(aCampos, aStru[nx,1]) = 0
			aDel(aStru,nx)
			aSize(aStru, Len(aStru)-1)
		Endif
	Next		
	aEval(aStru, {|e,nx| If(Ascan(aCampos, aStru[nx,1]) > 0, Nil, (aDel(aStru,nx), aSize(aStru, Len(aStru)-1)))})
	cFiltro := "SELECT " + SubStr(cFiltro,2)
	cFiltro += "FROM "+RetSqlName("SE5")+ " SE5 "
	cFiltro += "WHERE "
	cFiltro += "E5_FILIAL = '"+xFilial("SE5") +"' AND "
	cFiltro += "E5_FATURA = '"+cFatura+"' AND "
	cFiltro += "E5_FATPREF ='"+cPrefFat+"' AND "
	cFiltro += "E5_MOTBX ='BCF' AND "
	cFiltro += "D_E_L_E_T_=' ' "
	
	cFiltro := ChangeQuery(cFiltro)
	DbSelectArea("SE5")
	DbCloseArea()

	//------------------
	//Cria��o da tabela temporaria 
	//------------------
	If _oFina2812 <> Nil
		_oFina2812:Delete()
		_oFina2812 := Nil
	Endif
	
	_oFina2812 := FWTemporaryTable():New( "SE5" )  
	_oFina2812:SetFields(aStru) 	
	_oFina2812:AddIndex("1", {"E5_DATA","E5_TIPO","E5_NUMERO","E5_PARCELA","E5_VALOR"}) 	
	_oFina2812:Create()	

	Processa({||SqlToTrb(cFiltro, aStru, "SE5")}) // Cria arquivo temporario
#ELSE
	cFiltro := "E5_FILIAL=='"+xFilial("SE5")+"' .And. "
	cFiltro += "E5_FATURA=='"+cFatura+"' .And. "
	cFiltro += "E5_FATPREF=='"+cPrefFat+"' .And. "
	cFiltro += "E5_MOTBX=='BCF'"
	//������������������������������������������������������������������������Ŀ
	//� Cria indice condicional separando os titulos que deram origem a fatura �
	//� e as respectivas faturas que foram geradas								      �
	//��������������������������������������������������������������������������
	cIndex := CriaTrab(nil,.f.)
	cChave := SE5->(IndexKey(7))
	IndRegua("SE5",cIndex,cChave,,cFiltro,STR0020)  //"Selecionando Registros..."
	nIndex := RetIndex("SE5")
	dbSetIndex(cIndex+OrdBagExt())
	dbSetOrder(nIndex+1)
	dbSelectArea("SE5")
#ENDIF
cAliasSe5 := Alias()
nAlias	 := Select()
dbGoTop()
//������������������������������������������������������������������������Ŀ
//� Certifica se foram encontrados registros na condi��o selecionada 		�
//��������������������������������������������������������������������������
If EOF()
	Help(" ",1,"REGNOIS",,CHR(13)+STR0084,5,1) //"N�o existem titulos exclu�dos da fatura"
Else	
	
	DEFINE MSDIALOG oDlg FROM	9,0 TO 30,85 TITLE STR0085 OF oMainWnd  //"Consulta de titulos excluidos da fatura"
	@ 20, 02 SAY STR0039	OF oDlg PIXEL //"Prefixo"
	@ 20, 70 SAY STR0054	OF oDlg PIXEL //"Tipo"
	@ 20,120 SAY STR0069 	OF oDlg PIXEL //"Fatura Numero"
	dbGoTop()		
	@ 20, 35 MSGET cPrefFat 	When .F.	OF oDlg PIXEL
	@ 20, 85 MSGET cTipoFat		When .F.	OF oDlg PIXEL
	@ 20,160 MSGET cFatura 		When .F.	OF oDlg PIXEL
	
	oBrw 	  := TCBrowse():New( 37,  3, 330,117 , , , , oDlg, ,,,,,,,,,,, .F.,cAliasSe5,.T.,,.F.)
	dbSelectArea("SX3")
	dbSeek("SE5")
	While !EOF() .And. (x3_arquivo == "SE5")
		If aScan(aCampos,Alltrim(X3_CAMPO)) > 0
			If X3_TIPO != "N"
				oCol := TCColumn():New(Trim(x3_titulo),If( ValType(FieldWBlock(X3_CAMPO,nAlias))=="B", FieldWBlock(X3_CAMPO,nAlias), {|| FieldWBlock(X3_CAMPO,nAlias)} ),,,, "LEFT",,.F.,.F.,,,,.F.)
			Else	
				oCol := TCColumn():New(Trim(x3_titulo),If( ValType(FieldWBlock(X3_CAMPO,nAlias))=="B", FieldWBlock(X3_CAMPO,nAlias), {|| FieldWBlock(X3_CAMPO,nAlias)} ),X3_PICTURE,,,Upper("RIGHT"),,.F.,.F.,,,,.F.)
			Endif
			oBrw:ADDCOLUMN(oCol)
		Endif		
		dbSkip()
	Enddo
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,oDlg:End()},{||oDlg:End()},,aBut240) 
Endif

#IFDEF TOP
	dbSelectArea("SE5")
	dbCloseArea()
	ChkFile("SE5")

	//Deleta tabela tempor�ria no banco de dados
	If _oFina2812 <> Nil
		_oFina2812:Delete()
		_oFina2812 := Nil
	Endif
#ELSE
	dbSelectArea("SE5")
	dbClearFil()
	RetIndex("SE5")
	If !Empty(cIndex)
		FErase (cIndex+OrdBagExt())
		cIndex := ""
	Endif
	dbSetOrder(1)
#ENDIF
SE5->(RestArea(aAreaSe5))
SE1->(RestArea(aAreaSe1))
RestArea(aArea)
Return Nil


/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Fa281Legenda� Autor � Wagner Mobile Costa � Data � 22.10.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Cria uma janela contendo a legenda da mBrowse ou retorna a ���
���          � para o BROWSE                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Fina281 e TMAS460                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Fa281Legenda(nReg)

Local cAlias := "SE1"
Local aLegenda := { 	{"BR_VERDE", STR0086 },;	 //"Titulo em aberto"
							{"BR_AZUL", STR0087 },;		 //"Baixado parcialmente"
							{"BR_VERMELHO", STR0088 },; //"Titulo Baixado"
							{"BR_PRETO",STR0089} } //"Fatura Cancelada"
Local uRetorno := .T.
   
If ExistBlock("FINALEG")  
	uRetorno := ExecBlock("FINALEG",.F.,.F.,{nReg,cAlias})
Else

	If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
		uRetorno := {}
		Aadd(uRetorno, { 'E1_STATUS="C"', aLegenda[4][1] } )
		Aadd(uRetorno, { 'ROUND(E1_SALDO,2) = 0', aLegenda[3][1] } )
		Aadd(uRetorno, { 'ROUND(E1_SALDO,2) # ROUND(E1_VALOR,2)', aLegenda[2][1] } )
		Aadd(uRetorno, { '.T.', aLegenda[1][1] } )
	Else
		BrwLegenda(cCadastro, STR0072, aLegenda) //"Legenda"
	Endif
Endif

Return uRetorno

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �23/11/06 ���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     	  ���
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
Local aRotina	:=	{	{ STR0001,"AxPesqui"  , 0 , 1 },; //"Pesquisar"
								{ STR0002,"FA281Visua", 0 , 2 },; //"Visualizar"
								{ STR0003,"fA281Aut"  , 0 , 3 },; //"Selecionar"
								{ STR0004,"fA281Exclui"  , 0 , 6 },; //"Cancelar"
								{ STR0072,"Fa281Legenda", 0 , 6, ,.F.}}	//"Legenda"
Return(aRotina)

Function cTopFun281()

Return "  "

Function cBotFun281()

Return "ZZ"
