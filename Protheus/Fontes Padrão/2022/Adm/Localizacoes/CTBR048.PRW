#Include "Ctbr040.Ch"
#Include "PROTHEUS.Ch"

#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_SALDO_ANT    	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_VLR_DEBITO   	8
#DEFINE 	COL_SEPARA5			9
#DEFINE 	COL_VLR_CREDITO  	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_MOVIMENTO 		12
#DEFINE 	COL_SEPARA7			13
#DEFINE 	COL_SALDO_ATU 		14
#DEFINE 	COL_SEPARA8			15

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr048	� Autor � Acacio Egas       	� Data � 01/12/09 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Analitico localizado.       			 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr048()                               			 		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso    	 � Generico     											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctbr048()

Private titulo		:= ""
Private nomeprog	:= "CTBR048"
Private oReport		:= Nil
Private cPlano		:= GetAdvFval("CT0","CT0_ENTIDA",xFilial("CT0")+"05",1,"01") // Usado pela consulta padrao CV01
Private cCodigo		:= ""   // Usado pela consulta padrao CV01

CTBR048R4()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR048R4 � Autor� Daniel Sakavicius		� Data � 01/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Analitico Sintetico Modelo 1 - R4                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR048R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR048R4()

CtbCarTxt()

oReport := ReportDef()

If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		//Pergunte( oReport:uParam, .F. )
	EndIf

	oReport:PrintDialog()
Endif

oReport := Nil

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 28/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local CREPORT		:= "CTBR048"
Local CTITULO		:= STR0006				   			// "Emissao do Relat. Conf. Dig. "
Local CDESC			:= OemToAnsi(STR0001)+OemToAnsi(STR0002)+OemToAnsi(STR0003)			// "Este programa ira imprimir o Relatorio para Conferencia"
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= TAMSX3("CT1_CONTA")
Local cMascara		:= ""
Local cSeparador	:= ""
Local nTamConta		:= TAMSX3("CT1_CONTA")[1]
Local nTamEC05		:= TAMSX3("CV0_CODIGO")[1]
Local aSetOfBook
Local cPerg	   		:= "CTR048"

Pergunte(cPerg,.T.)

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)	    	  �
//����������������������������������������������������������������
aSetOfBook := CTBSetOf( "" )
cMascara := RetMasCtb( aSetOfBook[2], @cSeparador )

If ! Empty( cMascara )
	nTamConta := aTamConta[1] + ( Len( Alltrim( cMascara ) ) / 2 )
Else
	nTamConta := aTamConta[1]
EndIf

cPicture := aSetOfBook[4]

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport	:= TReport():New( cReport,Capital(CTITULO),CPERG, { |oReport| /*Pergunte(cPerg , .F. ),*/ If(! ReportPrint( oReport ), oReport:CancelPrint(), .T. ) }, CDESC )
oReport:SetEdit(.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
oSection1  := TRSection():New( oReport, STR0027, {"cArqTmp","CT1"},, .F., .F. ) //"Plano de contas"

// Conta
TRCell():New( oSection1, "ECX"	,,STR0028/*Titulo*/	,/*Picture*/, nTamConta /*Tamanho*/, /*lPixel*/, /*CodeBlock*/  )
TRCell():New( oSection1, "ECXDESC"  ,,STR0029/*Titulo*/	,/*Picture*/, aTamDesc[1]/*Tamanho*/, /*lPixel*/, /*CodeBlock*/  )
// Entidade 05
TRCell():New( oSection1, "ECY"	,,STR0056/*Titulo*/	,/*Picture*/, nTamEC05 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/  )
TRCell():New( oSection1, "ECYDESC"  ,,STR0029/*Titulo*/	,/*Picture*/, 20/*Tamanho*/, /*lPixel*/, /*CodeBlock*/  )
TRCell():New( oSection1, "SALDOANT" ,,STR0030/*Titulo*/	,/*Picture*/, aTamVal[1] + 2/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"RIGHT")
TRCell():New( oSection1, "SALDODEB" ,,STR0031/*Titulo*/	,/*Picture*/, aTamVal[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"RIGHT")
TRCell():New( oSection1, "SALDOCRD" ,,STR0032/*Titulo*/	,/*Picture*/, aTamVal[1] /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"RIGHT")
TRCell():New( oSection1, "MOVIMENTO",,STR0033/*Titulo*/	,/*Picture*/, aTamVal[1] + 2/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"RIGHT")
TRCell():New( oSection1, "SALDOATU" ,,STR0034/*Titulo*/	,/*Picture*/, aTamVal[1] + 2/*Tamanho*/, /*lPixel*/, /*CodeBlock*/, "RIGHT",,"RIGHT")

TRPosition():New( oSection1, "CT1", 1, {|| xFilial( "CT1" ) + cArqTMP->ECX })

oSection1:SetTotalInLine(.F.)
oSection1:SetTotalText('') //STR0011) //"T O T A I S  D O  P E R I O D O: "

Return( oReport )


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 28/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )

Local oSection1 	:= oReport:Section(1)
Local lExterno		:= .F.
Local aSetOfBook
Local dDataFim 		:= MV_PAR02
Local lRet			:= .T.
Local lPrintZero	:=  IIF(MV_PAR10==1,.T.,.F.)
Local lPula			:=  IIF(MV_PAR09==1,.T.,.F.)
Local lNormal		:= .T.
Local lVlrZerado	:=  IIF(MV_PAR05==1,.T.,.F.)
Local lQbConta		:= .T.
Local nDecimais
Local nDivide		:= 1
Local lImpSint		:= .T.
Local lImpMov		:= IIF(MV_PAR08==1,.T.,.F.)
Local oMeter
Local oText
Local oDlg
Local nMaxLin   	:=  MV_PAR11
Local cMoedaDsc		:=  MV_PAR12
Local aCtbMoeda		:= {}
Local aCtbMoedadsc	:= {}
Local cTipoAnt		:= ""
Local cArqTmp		:= ""
Local cSeparador	:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local oTotGerDeb
Local oTotGerCrd
Local cPicture
Local nCont			:= 0
Local cFilUser		:= ""
Local cRngFil		:= ""

Private nLinReport    := 9

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)	    	  �
//����������������������������������������������������������������
aSetOfBook := CTBSetOf( "" )

If lRet
	aCtbMoeda := CtbMoeda(  MV_PAR06 , nDivide )

	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lRet := .F.
		Return lRet
	Endif

    // valida��o da descri��o da moeda
	if lRet .And. ! Empty(  MV_PAR12 ) .and.  MV_PAR12 <> nil
		aCtbMoedadsc := CtbMoeda(  MV_PAR12 , nDivide )

		If Empty( aCtbMoedadsc[1] )
    		Help( " " , 1 , "NOMOEDA")
	        lRet := .F.
    	    Return lRet
	    Endif
	Endif
Endif

aCtbMoeda  	:= CtbMoeda( MV_PAR06,nDivide)
cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,MV_PAR06)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf

cPicture	:= aSetOfBook[4]
lPrintZero	:= Iif( MV_PAR10==1,.T.,.F.)
Titulo		:= OemToAnsi(STR0017)	//"BALANCETE DE VERIFICACAO DE "
Titulo		+= DTOC(MV_PAR01) + OemToAnsi(STR0007) + Dtoc(MV_PAR02) + ;
			   OemToAnsi(STR0008) + cDescMoeda + CtbTitSaldo(MV_PAR07)

oReport:SetCustomText( {|| nCtCGCCabTR(dDataFim, MV_PAR01,titulo,oReport)})

cFilUser := oSection1:GetAdvplExpr("CT1")
If Empty(cFilUser)
	cFilUser := ".T."
EndIf

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao			  		     �
//����������������������������������������������������������������

If lExterno
	CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				 MV_PAR01, MV_PAR02,"CVY","", MV_PAR03, MV_PAR04, MV_PAR13, MV_PAR14,,,,, MV_PAR06,;
				 MV_PAR07,aSetOfBook,,,,,;
				.F.,.F.,,.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,,;
				,,,,,,,,cMoedaDsc,,cRngFil)
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					 MV_PAR01, MV_PAR02,"CVY","", MV_PAR03, MV_PAR04, MV_PAR13, MV_PAR14,,,,, MV_PAR06,;
					MV_PAR07,aSetOfBook,,,,,;
					.F.,.F.,,,.F.,,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,,;
					,,,,,,,,cMoedaDsc,,cRngFil)},;
					OemToAnsi(OemToAnsi(STR0015)),;  //"Criando Arquivo Tempor�rio..."
					OemToAnsi(STR0003))  				//"Balancete Verificacao"
EndIf

nCount := cArqTmp->(RecCount())

oReport:SetMeter(nCont)

lRet := !(nCount == 0 .And. !Empty(aSetOfBook[5]))

If lRet

	// Verifica Se existe filtragem Ate o Segmento
	/*If ! Empty( cSegAte )

		//Efetua tratamento da mascara para consegui efetuar o controle do segmento
		For nMasc := 1 to Len( cMascara )

			cMasc += "0"+SubStr( cMascara,nMasc,1 )

		Next nMasc


		nDigitAte := CtbRelDig( cSegAte, cMasc )

		oSection1:SetFilter( 'Len(Alltrim(cArqTmp->CONTA)) <= ' + alltrim( Str( nDigitAte )) )
	EndIf	*/

	cArqTmp->(dbGoTop())

	If lNormal
		oSection1:Cell("ECX"):SetBlock( {|| EntidadeCTB(cArqTmp->ECX,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.)} )
	Else
		oSection1:Cell("ECX"):SetBlock( {|| cArqTmp->ECXRES } )
	EndIf

	oSection1:Cell("ECXDESC"):SetBlock( { || cArqTMp->ECXDESC } )
	oSection1:Cell("ECY"):SetBlock( {|| cArqTmp->ECY } )
	oSection1:Cell("ECYDESC"):SetBlock( { || cArqTMp->ECYDESC } )
	oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB(cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->ECXNORMAL,,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDODEB"):SetBlock( { || ValorCTB(cArqTmp->SALDODEB,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOCRD"):SetBlock( { || ValorCTB(cArqTmp->SALDOCRD,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
	oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->ECXNORMAL,,,,,,lPrintZero,.F.) } )

	// Imprime Movimento
	If !lImpMov
		oSection1:Cell("MOVIMENTO"):Disable()
	Else
		oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->ECXNORMAL,,,,,, lPrintZero,.F.) } )
	EndIf

	//******************************
	// Total Geral do relatorio    *
	//******************************
	oBrkGeral := TRBreak():New(oSection1, { || cArqTmp->(!Eof()) },{|| STR0011 },,,.F.)	//	" T O T A I S "

	// Totaliza
	oTotGerDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOECX="1",0,cArqTmp->SALDODEB) },.F.,.F.,.F.,oSection1)
	oTotGerDeb:Disable()

	oTotGerCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOECX="1",0,cArqTmp->SALDOCRD) },.F.,.F.,.F.,oSection1)
	oTotGerCrd:Disable()

	TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || ValorCTB(oTotGerDeb:GetValue(),,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection1 )

	// Imprime
	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || ValorCTB(oTotGerCrd:GetValue(),,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection1 )

	oSection1:OnPrintLine( {|| 	CTR048OnPrint( lPula, lQbConta, nMaxLin, @cTipoAnt, @nLinReport ) } )
	oSection1:Print()

EndIf

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()

If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF

Return .T.


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTR048OnPrint �Autor � Gustavo Henrique � Data � 07/02/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Executa acoes especificadas nos parametros do relatorio,   ���
���          � antes de imprimir cada linha.                              ���
�������������������������������������������������������������������������͹��
���Parametros� EXPL1 - Indicar se deve saltar linha entre conta sintetica ���
���          � EXPL2 - Indicar se deve quebrar pagina por conta           ���
���          � EXPN3 - Informar o total de linhas por pagina do balancete ���
���          � EXPC4 - Guardar o tipo da conta impressa (sint./analitica) ���
���          � EXPN5 - Guardar linha atual do relatorio para validacao    ���
���          �         com o valor do parametro EXPN3.                    ���
�������������������������������������������������������������������������͹��
���Retorno   � EXPL1 - Indicar se deve imprimir a linha (.T.)             ���
�������������������������������������������������������������������������͹��
���Uso       � Contabilidade Gerencial                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTR048OnPrint( lPula, lQbConta, nMaxLin, cTipoAnt, nLinReport )

Local lRet := .T.

// Verifica salto de linha para conta sintetica (MV_PAR09)
If lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOECX == "1" .And. cTipoAnt == "2"))
	oReport:SkipLine()
EndIf

// Verifica quebra de pagina por conta (mv_par11)
If lQbConta .And. cArqTmp->NIVEL1
	oReport:EndPage()
	nLinReport := 9
	Return
EndIf

// Verifica numero maximo de linhas por pagina (MV_PAR11)
If ! Empty(nMaxLin)
	CTR048MaxL(nMaxLin,@nLinReport)
EndIf

cTipoAnt := cArqTmp->TIPOECX

//If mv_par05 == 1		// Apenas sinteticas
//	lRet := (cArqTmp->TIPOECX == "1")
//ElseIf mv_par05 == 2	// Apenas analiticas
//	lRet := (cArqTmp->TIPOECX == "2")
//EndIf

Return lRet


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �CT048Valid� Autor � Pilar S. Albaladejo   � Data � 24.07.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Perguntas                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �Ct048Valid(cSetOfBook)                                      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T./.F.                                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 = Codigo da Config. Relatorio                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ct048Valid(cSetOfBook)

Local aSaveArea:= GetArea()
Local lRet		:= .T.

If !Empty(cSetOfBook)
	dbSelectArea("CTN")
	dbSetOrder(1)
	If !dbSeek(xfilial()+cSetOfBook)
		aSetOfBook := ("","",0,"","")
		Help(" ",1,"NOSETOF")
		lRet := .F.
	EndIf
EndIf

RestArea(aSaveArea)

Return lRet


/*
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������ͻ��
���Programa  � CTR048MAXL �Autor � Eduardo Nunes Cirqueira � Data �  31/01/07 ���
�����������������������������������������������������������������������������͹��
���Desc.     � Baseado no parametro MV_PAR11 ("Num.linhas p/ o Balancete      ���
���          � Modelo 1"), cujo conteudo esta na variavel "nMaxLin", controla ���
���          � a quebra de pagina no TReport                                  ���
�����������������������������������������������������������������������������͹��
���Uso       � AP                                                             ���
�����������������������������������������������������������������������������ͼ��
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
*/
Static Function CTR048MaxL(nMaxLin,nLinReport)

nLinReport++

If nLinReport > nMaxLin
	oReport:EndPage()
	nLinReport := 10
EndIf

Return Nil


/*
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������ͻ��
���Programa  � nCtCGCCabTR  � Autor � Fabio Jadao Caires      � Data � 31/01/07���
������������������������������������������������������������������������������͹��
���Desc.     � Chama a funcao padrao CtCGCCabTR reiniciando o contador de      ���
���          � linhas para o controle do relatorio.                            ���
���          �                                                                 ���
������������������������������������������������������������������������������͹��
���Uso       � AP                                                              ���
������������������������������������������������������������������������������ͼ��
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
STATIC FUNCTION nCtCGCCabTR(dDataFim,dDataIni,titulo,oReport)

nLinReport := 10

RETURN CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport,,,,,,,,,,dDataIni)
