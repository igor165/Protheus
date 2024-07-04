#Include "PROTHEUS.Ch"
#Include "CTBR550.Ch"

//Tradu��o PTG 20080721

// 17/08/2009 -- Filial com mais de 2 caracteres

STATIC _oCTBR5501 := Nil
STATIC lBlind	  := IsBlind()

Static lIsRedStor := FindFunction("IsRedStor") .and. IsRedStor() //Used to check if the Red Storn Concept used in russia is active in the system | Usada para verificar se o Conceito Red Storn utilizado na Russia esta ativo no sistema | Se usa para verificar si el concepto de Red Storn utilizado en Rusia esta activo en el sistema

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR550  � Autor � Julio Cesar           � Data � 16.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o do fluxo de contas (flujo de efectivo)             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR550()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR550()

PRIVATE Titulo		:= ""
Private NomeProg	:= "CTBR550"

CTBR550R4()


If _oCTBR5501 <> Nil
	_oCTBR5501:Delete()
	_oCTBR5501 := Nil
Endif

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR550R4 � Autor� Daniel Sakavicius		� Data � 06/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o do fluxo de contas (flujo de efectivo)  - R4  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR190R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR550R4() 

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()      

If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf	

oReport :PrintDialog()      

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 06/09/06 ���
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
local aArea	   		:= GetArea()   
Local CREPORT		:= "CTBR550"
Local CTITULO		:= STR0004
Local CDESC			:= OemToAnsi(STR0001)+OemToAnsi(STR0002)+OemToAnsi(STR0003)//Este programa ir� imprimir o Fluxo de Contas"
Local cPerg	   		:= "CTR550"			       
Local aTamConta		:= TAMSX3("CT1_CONTA")    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= TAMSX3("CT1_DESC01")
Local aTamItem		:= TAMSX3("CTD_ITEM")
Local aTamCC		:= TAMSX3("CTT_CUSTO")
Local aTamCLVL		:= TAMSX3("CTH_CLVL")
Local nDecimais

If lIsRedStor
	aTamVal[1] += 2
Endif


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
oReport	:= TReport():New( cReport,CTITULO,CPERG, { |oReport| ReportPrint( oReport ) }, CDESC )
oReport:SetLandScape(.T.)

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
oSection0  := TRSection():New( oReport, Capital(STR0031), {"cArqTmp"},, .F., .F. )       //"Analitico"
TRCell():New( oSection0, "CONTASINT" , ,STR0026/*Titulo*/,/*Picture*/,aTamConta[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"CONTA"
TRCell():New( oSection0, "DESCSIN"   , ,STR0034/*Titulo*/,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)    //"DESCRICAO"
oSection0:SetHeaderSection(.F.)		//Nao imprime o cabe�alho da secao

oSection1  := TRSection():New( oReport, Capital(STR0032), {"cArqTmp"},, .F., .F. )        //"Sintetico"
TRCell():New( oSection1, "TXTCONTA", ,       /*Titulo*/,/*Picture*/,09          /*Tamanho*/,/*lPixel*/,{|| STR0026+" - "})	//"CONTA"
TRCell():New( oSection1, "CONTAAN" , ,STR0026/*Titulo*/,/*Picture*/,aTamConta[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"CONTA"
TRCell():New( oSection1, "DESCAN"  , ,STR0034/*Titulo*/,/*Picture*/,aTamDesc[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "DESCSALD", ,       /*Titulo*/,/*Picture*/,48          /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "SALDOI"  , ,       /*Titulo*/,/*Picture*/,aTamVal[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
oSection1:SetHeaderSection(.F.)		//Nao imprime o cabe�alho da secao

oSection2  := TRSection():New( oReport, Capital(STR0033), {"cArqTmp"},, .F., .F. )        //"Lancamentos"
TRCell():New( oSection2, "DATAEMI"  , ,STR0035/*Titulo*/,/*Picture*/,12         /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"DATA"
TRCell():New( oSection2, "TITULO"   , ,If(cPaisLoc != "MEX",STR0041,STR0042)/*Titulo*/,/*Picture*/,22/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"LOTE/SUB/DOC/LINHA"
TRCell():New( oSection2, "HISTORICO", ,STR0043/*Titulo*/,/*Picture*/,40         /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"H I S T O R I C O"
TRCell():New( oSection2, "CCUSTO"   , ,STR0036/*Titulo*/,/*Picture*/,aTamCC[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"C CUSTO"
TRCell():New( oSection2, "ITEM"     , ,STR0037/*Titulo*/,/*Picture*/,aTamItem[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"ITEM CONTA"
TRCell():New( oSection2, "CLVL"     , ,STR0038/*Titulo*/,/*Picture*/,aTamCLVL[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"COD CL VAL"
TRCell():New( oSection2, "MOVIMENTO", ,STR0039/*Titulo*/,/*Picture*/,aTamVal[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"MOVIMENTOS"
TRCell():New( oSection2, "SALDO"    , ,STR0040/*Titulo*/,/*Picture*/,aTamVal[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"SALDOS"
oSection2:Cell("SALDO"):SetHeaderAlign("RIGHT")
oSection2:SetHeaderPage()	//Define o cabecalho da secao como padrao

oSection3  := TRSection():New( oReport, Capital(STR0040), {"cArqTmp"},, .F., .F. )		  //"SALDOS"
TRCell():New( oSection3, "DESCSALT", ,/*Titulo*/,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection3, "SALDOT"  , ,/*Titulo*/,/*Picture*/,aTamVal[1] /*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
oSection3:SetHeaderSection(.F.)		//Nao imprime o cabe�alho da secao


Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 06/09/06 ���
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
Local oSection0 	:= oReport:Section(1)    
Local oSection1 	:= oReport:Section(2)
Local oSection2 	:= oReport:Section(3)
Local oSection3 	:= oReport:Section(4)
Local aTamVal		:= TAMSX3("CT2_VALOR")

Local titulo		:= STR0004 //"Emissao do Relatorio de Fluxo de Contas"
Local lCusto		:= .F.
Local lItem			:= .F.
Local lCLVL			:= .F.                         
Local lAnalitico 	:= .T.

Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""
Local aSaldo		:= {}
Local cDescMoeda
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cPicture
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cSaldo		:= mv_par06
Local cContaIni		:= mv_par01
Local cContaFIm		:= mv_par02
Local cCustoIni		:= mv_par13
Local cCustoFim		:= mv_par14
Local cItemIni		:= mv_par16
Local cItemFim		:= mv_par17
Local cCLVLIni		:= mv_par19
Local cCLVLFim		:= mv_par20
Local cContaAnt		:= ""
Local dDataAnt		:= CTOD("  /  /  ")
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint		:= ""
Local cMoeda		:= mv_par05
Local cContaSint	:= ""
Local cArqTmp
Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")
Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04
Local lNoMov		:= Iif(mv_par09==1,.T.,.F.)
Local lJunta		:= Iif(mv_par10==1,.T.,.F.)
Local lSalto		:= Iif(mv_par21==1,.T.,.F.)
Local lSalLin		:= If(mv_par29 ==1 ,.T.,.F.)
Local lSldAntCta	:= Iif(mv_par31 == 1, .T.,.F.)
Local lSldAntCC		:= Iif(mv_par31 == 2, .T.,.F.)
Local lSldAntIt  	:= Iif(mv_par31 == 3, .T.,.F.)
Local lSldAntCv  	:= Iif(mv_par31 == 4, .T.,.F.)
Local nMaxLin   	:= mv_par30

Local nDecimais		:= 2
Local nTotEnt		:= 0
Local nTotSai		:= 0

Local lResetPag		:= .T.
Local m_pag			:= 1 // controle de numera��o de pagina
Local l1StQb		:= .T.  
Local nPagIni		:= mv_par22
Local nPagFim		:= mv_par23
Local nReinicia		:= mv_par24
Local nBloco		:= 0
Local nBlCount		:= 1

Local nTamConta	    := 20
Local aColunas
Local lImpLivro		:= .t.
Local lImpTermos	:= .f.								
Local lImpData	    := .F.
Local lSubTotEnt    := .T.
Local lDispon		:= .T.
Local nPos          := 0
Local i				:= 0
Local nI			:= 0
Local cNormal 		:= ""
Local cArqAbert		:= ""
Local cArqEncer		:= ""

Local bNormal
Local aTamConta		:= TAMSX3("CT1_CONTA")

Private aLinha		:= {}
Private nLastKey	:= 0

If lIsRedStor
	bNormal		:= {|| GetAdvFVal("CT1","CT1_NORMAL",xFilial("CT1")+PADR(cArqTmp->CONTA,aTamConta[1]),1,"") }
	bNormalAnt	:= {|| GetAdvFVal("CT1","CT1_NORMAL",xFilial("CT1")+PADR(cContaAnt,aTamConta[1]),1,"") }	
Endif	


If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf     

cArqAbert:=GetNewPar("MV_LRAZABE","")  // Arquivo do termo de abertura do Livro Razao Contabil
cArqEncer:=GetNewPar("MV_LRAZENC","")	// Arquivo do termo de encerramento do Livro Razao Contabil
lAnalitico	:= Iif(mv_par08 == 1,.T.,.F.)
lCusto 		:= Iif(mv_par12 == 1,.T.,.F.)                           
lItem		:= Iif(mv_par15 == 1,.T.,.F.)
lCLVL		:= Iif(mv_par18 == 1,.T.,.F.)

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books -> Conf. da Mascara / Valores   �
//����������������������������������������������������������������
If !Ct040Valid(mv_par07)
	Return
Else
	aSetOfBook := CTBSetOf(mv_par07)
EndIf

aCtbMoeda  	:= CtbMoeda(mv_par05)
If Empty(aCtbMoeda[1])
	If !lBlind
   		Help(" ",1,"NOMOEDA")
	EndIf
 	Return
Endif


//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par28==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par28==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par28==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase		

cDescMoeda 	:= Alltrim(aCtbMoeda[2])

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1 := RetMasCtb(aSetOfBook[2],@cSepara1)
	nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)
EndIf               


If lCusto .Or. lItem .Or. lCLVL
	// Mascara do Centro de Custo
	If Empty(aSetOfBook[6])
		cMascara2 := GetMv("MV_MASCCUS")
	Else
		cMascara2 := RetMasCtb(aSetOfBook[6],@cSepara2)
	EndIf                                                
	// Mascara do Item Contabil
	If Empty(aSetOfBook[7])
		cMascara3 := ""
	Else
		cMascara3 := RetMasCtb(aSetOfBook[7],@cSepara3)
	EndIf
	// Mascara da Classe de Valor
	If Empty(aSetOfBook[8])
		cMascara4 := ""
	Else
		cMascara4 := RetMasCtb(aSetOfBook[8],@cSepara4)
	EndIf
EndIf	

cPicture := aSetOfBook[4]

#DEFINE 	COL_NUMERO 			1
#DEFINE 	COL_HISTORICO		2
#DEFINE 	COL_CENTRO_CUSTO 	3
#DEFINE 	COL_ITEM_CONTABIL 	4
#DEFINE 	COL_CLASSE_VALOR  	5 
#DEFINE 	COL_VLR_MOVIMENTO   6
#DEFINE 	COL_VLR_SALDO  		7
#DEFINE 	TAMANHO_TM       	8
#DEFINE 	COL_VLR_TRANSPORTE  9

If !lAnalitico
	aColunas := { 000, 022,    ,    ,    , 068, 093, 19, 091 }
Else
	aColunas := { 000, 022, 060, 081, 102, 123, 148, 20 ,178 }
Endif                                                  

IF lAnalitico
	Titulo	:=	STR0007 //"FLUXO DE CONTAS (ANALITICO) DE "
Else
	Titulo	:=	STR0008 //"FLUXO DE CONTAS (SINTETICO) DE "
EndIf
Titulo += 	DTOC(dDataIni) + STR0009 + DTOC(dDataFim) + CtbTitSaldo(mv_par06) //" ATE "

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport,.T.,@lResetPag,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,@l1StQb) } )
If lImpLivro
	//��������������������������������������������������������������Ŀ
	//� Monta Arquivo Temporario para Impressao   					 �
	//����������������������������������������������������������������
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBGerFCon(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,;
				cCustoIni,cCustoFim,cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,;
				dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,lAnalitico)},;
				STR0013,; //"Criando Arquivo Tempor�rio..."
				STR0014)  //"Emissao do Fluxo de Contas"

	dbSelectArea("cArqTmp")
	dbGoTop()
Endif 

//oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport,.T.,,,,,MV_PAR22/*controle do cabe�alho pela rotina*/) } )   

oReport:SetPageNumber( MV_PAR22 )


While lImpLivro .And. !Eof()
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf  

	If lSldAntCC
		aSaldo := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo)
	ElseIf lSldAntIt
		aSaldo := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo)
	ElseIf lSldAntCv
		aSaldo := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo)
	Else 
		aSaldo := SaldoCT7(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo)
	EndIf
	
	If lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCENT ==0 .And. cArqTmp->LANCSAI == 0 
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		Endif	
	Endif             

	nSaldoAtu   := 0
	nTotEnt     := 0
	nTotSai	    := 0
    lImpData	:= .T.
	lSubTotEnt  := .T.
                                           
	oSection0:Init()


	// IMPRIME A CONTA

	// Conta Sintetica	                   
	oSection0:Cell("CONTASINT"):SetBlock( { || EntidadeCTB(cContaSint,0,0,Len(cContaSint),.F.,cMascara1,cSepara1,,,,,.F.) } )
	cContaSint := CTR550Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes)	
	oSection0:Cell("DESCSIN"):SetBlock( { || cDescSint } )	

                                
	oSection0:PrintLine()	
	oSection0:Finish()	
	
	oSection1:Init()


	If mv_par11 == 1 	// Imprime Cod Normal
		oSection1:Cell("CONTAAN"):SetBlock( { || EntidadeCTB(cArqTmp->CONTA,0,0,60,.F.,cMascara1,cSepara1,,,,,.F.) } )		
	Else
		oSection1:Cell("CONTAAN"):SetBlock( { || EntidadeCTB(cCodRes,0,0,60,.F.,cMascara1,cSepara1,,,,,.F.) } )			
	EndIf                                                                                                       

	oSection1:Cell("DESCSALD"):SetBlock( { || STR0017 } )	//"S a l d o   I n i c i a l ==> "
	If lIsRedStor
		oSection1:Cell("SALDOI"):SetBlock( { || ValorCTB(aSaldo[6],,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormal),,,,,,,.F.,.f.) } )	
	Else
		oSection1:Cell("SALDOI"):SetBlock( { || ValorCTB(aSaldo[6],,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.) } )
	Endif


	nSaldoAtu := aSaldo[6]

	oSection1:PrintLine()
	oSection1:Finish()  	

	dbSelectArea("cArqTmp")
	cContaAnt := cArqTmp->CONTA
	dDataAnt  := CTOD("  /  /  ")
	aLanctos  := {}			
	
	oSection2:Init()
	
	
	While cArqTmp->(!Eof()) .And. (cArqTmp->CONTA == cContaAnt)

		oSection3:Init()
		
		If lIsRedStor
			// A TRANSPORTAR :
			oReport:SetPageFooter( 5 , {|| IIF(oSection2:Printing() .Or. oSection3:Printing() ,;
										   oReport:PrintText(STR0018 + ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormal),,,,,,,.F.) ),;
										   nil) } )
			//"DE TRANSPORTE : "
			oReport:OnPageBreak( {|| IIF(oSection2:Printing() .Or. oSection3:Printing() ,;
									 (oReport:PrintText(STR0029 + ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormal),,,,,,,.F.),oReport:Row(),10),oReport:Skipline()),nil) } )
		Else
			// A TRANSPORTAR :  	
			oReport:SetPageFooter( 5 , {|| IIF(oSection2:Printing() .Or. oSection3:Printing() ,;
											   oReport:PrintText(STR0018 + ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.) ),;
											   nil) } )

			//"DE TRANSPORTE : "
			oReport:OnPageBreak( {|| IIF(oSection2:Printing() .Or. oSection3:Printing() ,;
										 (oReport:PrintText(STR0029 + ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.),oReport:Row(),10),oReport:Skipline()),nil) } )
		Endif
		//Armazena o tipo de lancamento...
		lSubTotEnt := (cArqTmp->TIPO="1")

		If lAnalitico		//Se for relatorio analitico
			// Imprime os lancamentos para a conta                          
			oSection2:Cell("DATAEMI"):SetBlock( { || cArqTmp->DATAL } )
		
			nSaldoAtu  := nSaldoAtu + cArqTmp->LANCENT - cArqTmp->LANCSAI
			nTotEnt	   += cArqTmp->LANCENT
			nTotSai	   += cArqTmp->LANCSAI                             

			oSection2:Cell("TITULO"):SetBlock( { || cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA } )	
			oSection2:Cell("HISTORICO"):SetBlock( { || Left(cArqTmp->HISTORICO,33) } )	

			If lCusto
				If mv_par25 == 1 //Imprime Cod. Centro de Custo Normal 	
					oSection2:Cell("CCUSTO"):SetBlock( { || EntidadeCTB(cArqTmp->CCUSTO,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.) } )
				Else 
					dbSelectArea("CTT")
					dbSetOrder(1)
					dbSeek(xFilial()+cArqTmp->CCUSTO)				
					cResCC := CTT->CTT_RES                            						
					oSection2:Cell("CCUSTO"):SetBlock( { || EntidadeCTB(cResCC,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.) } )										
					dbSelectArea("cArqTmp")
				Endif                                                       
			Endif

			If lItem 						//Se imprime item 
				If mv_par25 == 1 //Imprime Codigo Normal Item Contabl	
					oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTmp->ITEM,0,0,20,.F.,cMascara3,cSepara3,,,,,.F.) } )
				Else
					dbSelectArea("CTD")
					dbSetOrder(1)
					dbSeek(xFilial()+cArqTmp->ITEM)				
					cResItem := CTD->CTD_RES                        					
					oSection2:Cell("ITEM"):SetBlock( { || EntidadeCTB(cResItem,0,0,20,.F.,cMascara3,cSepara3,,,,,.F.) } )	
					dbSelectArea("cArqTmp")					
				Endif
			Endif
			
			If lCLVL 			  //Se imprime classe de valor
				If mv_par26 == 1 //Imprime Cod. Normal Classe de Valor
					oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cArqTmp->CLVL,0,0,20,.F.,cMascara3,cSepara3,,,,,.F.) } )
				Else
					dbSelectArea("CTH")
					dbSetOrder(1)
					dbSeek(xFilial()+cArqTmp->CLVL)				
					cResClVl := CTH->CTH_RES						
					oSection2:Cell("CLVL"):SetBlock( { || EntidadeCTB(cResClVl,0,0,20,.F.,cMascara3,cSepara3,,,,,.F.) } )
					dbSelectArea("cArqTmp")					
				Endif			
			Endif
			If lIsRedStor
				If cArqTmp->TIPO == "1"
					oSection2:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->LANCENT,,,aTamVal[1],nDecimais,.F.,cPicture,Eval(bNormal),,,,,,,.F.) } )
				Else
					oSection2:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->LANCSAI,,,aTamVal[1],nDecimais,.F.,cPicture,Eval(bNormal),,,,,,,.F.) } )
				EndIf
				oSection2:Cell("SALDO"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormal),,,,,,,.F.) } )				
			Else
				If cArqTmp->TIPO == "1"
					oSection2:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->LANCENT,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
				Else
					oSection2:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->LANCSAI,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
				EndIf
				oSection2:Cell("SALDO"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.) } )
			Endif
			
			oSection2:PrintLine()
		
			// Procura pelo complemento de historico
			dbSelectArea("CT2")
			dbSetOrder(10)
			If dbSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
				dbSkip()
				If CT2->CT2_DC == "4"
					While !Eof() .And. CT2->CT2_FILIAL == xFilial() 			.And.;
										CT2->CT2_LOTE == cArqTMP->LOTE 		    .And.;
										CT2->CT2_SBLOTE == cArqTMP->SUBLOTE 	.And.;
										CT2->CT2_DOC == cArqTmp->DOC 			.And.;
										CT2->CT2_SEQLAN == cArqTmp->SEQLAN 	    .And.;
										CT2->CT2_EMPORI == cArqTmp->EMPORI	.And.;
										CT2->CT2_FILORI == cArqTmp->FILORI	.And.;
										CT2->CT2_DC == "4" 					    .And.;
								        DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)                        

						oSection2:Cell("HISTORICO"):SetBlock( { || Left(CT2->CT2_HIST,33) } )							
						oSection2:PrintLine()
						oReport:SkipLine()									
						dbSkip()
					EndDo	
				EndIf	
			EndIf			        
			
			dbSelectArea("cArqTmp")
			dbSkip() 	 // proximo lancamento		

			If (cArqTmp->TIPO ="2" .and. lSubTotEnt) .or. ;
  			   cArqTmp->(Eof()) .or. (cArqTmp->CONTA <> cContaAnt)
				If lSubTotEnt
					oSection3:Cell("DESCSALT"):SetBlock( { || STR0021 } )	//	"Total de Entradas ==> "
					If lIsRedStor
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotEnt,,,aTamVal[1],nDecimais,.F.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )					
					Else						
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotEnt,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
					Endif
					
					oSection3:PrintLine()
					oReport:SkipLine()			
					
					If !(cArqTmp->(Eof()) .or. (cArqTmp->CONTA <> cContaAnt))
						oSection3:Cell("DESCSALT"):SetBlock( { || STR0020 } )	//	"D i s p o n i v e l ==> "
						If lIsRedStor
							oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )						
						Else
							oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.) } )
						Endif
						
						oSection3:PrintLine()
						oReport:SkipLine()										
					EndIf
					lSubTotEnt  := .F.
					lImpData	:= .T.
				Else
					oSection3:Cell("DESCSALT"):SetBlock( { || STR0019 } )	//"Total de Saidas ==> "
					If lIsRedStor
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotSai,,,aTamVal[1],nDecimais,.F.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )					
					Else
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotSai,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
					Endif

					oSection3:PrintLine()
					oReport:SkipLine()
				EndIf
			EndIf
		Else		// Se for resumido.
			dbSelectArea("cArqTmp")
			While cArqTmp->TIPO == cArqTmp->TIPO .And. cContaAnt == cArqTmp->CONTA
                If (nPos := aScan(aLanctos,{|x| x[3] == cArqTmp->DATAL})) == 0
					AAdd(aLanctos,{cArqTmp->LANCENT,cArqTmp->LANCSAI,cArqTmp->DATAL})
				Else
					aLanctos[nPos][1] += cArqTmp->LANCENT
					aLanctos[nPos][2] += cArqTmp->LANCSAI
				EndIf
				dbSkip()
			End
   		EndIf
   		
		//"DE TRANSPORTE : "
/*		IF lSalto .AND. ! cArqTmp->CONTA == cContaAnt
			oSection1:SetPageBreak(.T.)
        ENDIF
  */ 		
   		oSection3:Finish()
	EndDo
	
	//"DE TRANSPORTE : "
		IF lSalto .AND. ! cArqTmp->CONTA == cContaAnt
			oSection0:SetPageBreak(.T.)
        ENDIF
	
	
	oSection2:Finish()

	If !lAnalitico

		oSection2:Init()
		oSection3:Init()

		aLanctos := aSort(aLanctos,,,{|x,y| x[3] < y[3]})
		For i := 1 To 2
			dDataAnt := CTOD("  /  /  ")
			For nI := 1 To Len(aLanctos)
				If (dDataAnt <> aLanctos[nI][3]) .And. (aLanctos[nI][i] <> 0	)
					oSection2:Cell("TITULO"):SetBlock( { || aLanctos[nI][3]} )	
				
					If lIsRedStor
						oSection2:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(aLanctos[nI][I],,,aTamVal[1],nDecimais,.F.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )					
					Else
						oSection2:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(aLanctos[nI][I],,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
					Endif
					dDataAnt  := aLanctos[nI][3]
					If i = 1
						nSaldoAtu += aLanctos[nI][I]
						nTotEnt   += aLanctos[nI][I]
					Else
						nSaldoAtu -= aLanctos[nI][I] 
						nTotSai   += aLanctos[nI][I]
					EndIf
					If lIsRedStor
						oSection2:Cell("SALDO"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.F.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )					
					Else
						oSection2:Cell("SALDO"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
					Endif
						
					oSection2:PrintLine()
					oReport:SkipLine()		
				Else
					lDispon := .t.		
				EndIf
			Next nI

			If lSubTotEnt
				If nTotEnt > 0
					oSection3:Cell("DESCSALT"):SetBlock( { || STR0021 } )	// "Total de Entradas ==> "
					If lIsRedStor
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotEnt,,,aTamVal[1],nDecimais,.F.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )					
					Else
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotEnt,,,aTamVal[1],nDecimais,.F.,cPicture,,,,,,,,.F.) } )
					Endif

					oSection3:PrintLine()
					oReport:SkipLine()

					If lDispon
						oSection3:Cell("DESCSALT"):SetBlock( { || STR0020 } )	 //"D i s p o n i v e l ==> "
						If lIsRedStor
							oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )						
						Else
							oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.) } )
						Endif						
						oSection3:PrintLine()
						oReport:SkipLine()							
					EndIf
				EndIf
				lSubTotEnt := .F. 
			Else
				If nTotSai > 0
					oSection3:Cell("DESCSALT"):SetBlock( { || STR0019 } )
					If lIsRedStor
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotSai,,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )					
					Else
						oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nTotSai,,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.) } )
					Endif					
					oSection3:PrintLine()
					oReport:SkipLine()				
				EndIf
			EndIf			
		Next i
		oSection2:Finish()
		oSection3:Finish()
    EndIf

	oSection3:Init()
	oSection3:Cell("DESCSALT"):SetBlock( { || STR0022 } )	//"S a l d o   F i n a l ==> "
	If lIsRedStor
		oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,Eval(bNormalAnt),,,,,,,.F.) } )	
	Else
		oSection3:Cell("SALDOT"):SetBlock( { || ValorCTB(nSaldoAtu,,,aTamVal[1],nDecimais,.T.,cPicture,,,,,,,,.F.) } )
	Endif

	oSection3:PrintLine()
	oSection3:Finish()

	oReport:SkipLine()
	

EndDo

         

oReport:SetTotalText(STR0022)	//"S a l d o   F i n a l ==> "

If lImpLivro
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()
	If Select("cArqTmp") == 0
		FErase("cArqTmp"+GetDBExtension())
		FErase("cArqTmp"+OrdBagExt())
	EndIf		
Endif

If lImpTermos 							// Impressao dos Termos
	oSection2:SetHeaderSection(.F.)
	cArqAbert:=GetNewPar("MV_LRAZABE","")
	cArqEncer:=GetNewPar("MV_LRAZENC","")

    If Empty(cArqAbert)
		ApMsgAlert(	STR0023 +; //"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. "
					STR0024)   //"Utilize como base o parametro MV_LDIARAB."
	Endif
Endif

If lImpTermos .And. ! Empty(cArqAbert)	// Impressao dos Termos
	dbSelectArea("SM0")
	aVariaveis:={}
	For i:=1 to FCount()	
		If FieldName(i)=="M0_CGC"
			AADD(aVariaveis,{FieldName(i),Transform(FieldGet(i),"@R 99.999.999/9999-99")})
		Else
            If FieldName(i)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(i),FieldGet(i)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek(Padr( "CTR550", Len( X1_GRUPO ) , ' ' ) + "01")
	While SX1->X1_GRUPO == Padr( "CTR550", Len( X1_GRUPO ) , ' ' )
		AADD(aVariaveis,{Rtrim(Upper(X1_VAR01)),&(X1_VAR01)})
		dbSkip()
	End

	If !File(cArqAbert)
		aSavSet:=__SetSets()
		cArqAbert:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
		
	Endif

	If !File(cArqEncer)
		aSavSet:=__SetSets()
		cArqEncer:=CFGX024(,"Raz�o") // Editor de Termos de Livros
		__SetSets(aSavSet)
		Set(24,Set(24),.t.)
	Endif

	If cArqAbert#NIL
		oReport:EndPage()		
		ImpTerm2(cArqAbert,aVariaveis,,,,oReport)			
	Endif

	If cArqEncer#NIL                                        
		oReport:EndPage()
		ImpTerm2(cArqEncer,aVariaveis,,,,oReport)			
	Endif	 
Endif

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGerFCon� Autor � Julio Cesar           � Data � 16/10/02 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Cria Arquivo Temporario para imprimir o fluxo de contas     ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   �CtbGerRaz(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim���
���			  �cCustoIni,cCustoFim,cItemIni,cItemFim,cCLVLIni,cCLVLFim,    ���
���			  �cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,   ���
���			  �lAnalit)                                                    ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nome do arquivo temporario                                  ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpO1 = Objeto oMeter                                      ���
���           � ExpO2 = Objeto oText                                       ���
���           � ExpO3 = Objeto oDlg                                        ���
���           � ExpL1 = Acao do Codeblock                                  ���
���           � ExpC1 = Arquivo temporario                                 ���
���           � ExpC2 = Conta Inicial                                      ���
���           � ExpC3 = Conta Final                                        ���
���           � ExpC4 = C.Custo Inicial                                    ���
���           � ExpC5 = C.Custo Final                                      ���
���           � ExpC6 = Item Inicial                                       ���
���           � ExpC7 = Cl.Valor Inicial                                   ���
���           � ExpC8 = Cl.Valor Final                                     ���
���           � ExpC9 = Moeda                                              ���
���           � ExpD1 = Data Inicial                                       ���
���           � ExpD2 = Data Final                                         ���
���           � ExpA1 = Matriz aSetOfBook                                  ���
���           � ExpL2 = Indica se imprime movimento zerado ou nao.         ���
���           � ExpC10= Tipo de Saldo                                      ���
���           � ExpL3 = Indica se junta CC ou nao.                         ���
���           � ExpL4 = Indica se imprime analitico ou sintetico           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CtbGerFCon(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim,;
                    cCustoIni,cCustoFim,cItemIni,cItemFim,cCLVLIni,cCLVLFim,;
                    cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,;
                    lAnalit)

Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:= TAMSX3("CT3_CUSTO")
Local aTamVal	:= TAMSX3("CT2_VALOR")
Local aCtbMoeda	:= {}
Local aSaveArea := GetArea()
Local aCampos
Local cChave

Local nTamHist	:= Len(CriaVar("CT2_HIST"))
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nDecimais	:= 0

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]

aCampos :={	{ "CONTA"		, "C", aTamConta[1], 0 },;  		// Codigo da Conta
			{ "XPARTIDA"   	, "C", aTamConta[1] , 0 },;		// Contra Partida
			{ "TIPO"       	, "C", 01			, 0 },;			// Tipo do Registro (Debito/Credito/Continuacao)
			{ "LANCENT"		, "N", aTamVal[1]+2, nDecimais },; // Debito
			{ "LANCSAI"		, "N", aTamVal[1]+2, nDecimais },; // Credito
			{ "HISTORICO"	, "C", nTamHist   	, 0 },;			// Historico
			{ "CCUSTO"		, "C", aTamCusto[1], 0 },;			// Centro de Custo
			{ "ITEM"		, "C", nTamItem		, 0 },;			// Item Contabil
			{ "CLVL"		, "C", nTamCLVL		, 0 },;			// Classe de Valor
			{ "DATAL"		, "D", 10			, 0 },;			// Data do Lancamento
			{ "LOTE" 		, "C", 06			, 0 },;			// Lote
			{ "SUBLOTE" 	, "C", 03			, 0 },;			// Sub-Lote
			{ "DOC" 		, "C", 06			, 0 },;			// Documento
			{ "LINHA"		, "C", Len(CT2->CT2_LINHA), 0 },;	// Linha  03
			{ "SEQLAN"		, "C", Len(CT2->CT2_SEQLAN), 0 },;			// Sequencia do Lancamento  03
			{ "SEQHIST"		, "C", 03			, 0 },;			// Seq do Historico
			{ "EMPORI"		, "C", 02			, 0 },;			// Empresa Original
			{ "FILORI"		, "C", 02			, 0 },;			// Filial Original
			{ "NOMOV"		, "L", 01			, 0 }}			// Conta Sem Movimento
					
cChave  := "CONTA+TIPO+DATAL+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"
//��������������������������������������������������������������Ŀ
//� Cria Indice Temporario do Arquivo de Trabalho 1.             �
//����������������������������������������������������������������
If _oCTBR5501 <> Nil
	_oCTBR5501:Delete()
	_oCTBR5501 := Nil
Endif
_oCTBR5501 := FWTemporaryTable():New( "cArqTmp" )  
_oCTBR5501:SetFields(aCampos) 
_oCTBR5501:AddIndex("1", Strtokarr2( cChave, "+"))
_oCTBR5501:Create() 

dbSelectArea("cArqTmp")
dbSetOrder(1)

// Monta Arquivo para gerar o Razao
CtbFCon(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
	    cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
		aSetOfBook,lNoMov,cSaldo,lJunta)

RestArea(aSaveArea)

Return cArqTmp

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbFCon   � Autor � Julio Cesar           � Data � 16/10/02 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Realiza a "filtragem" dos registros do Razao                ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,		   ���
���			  �cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,   ���
���			  �cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta)   ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpO1 = Objeto oMeter                                      ���
���           � ExpO2 = Objeto oText                                       ���
���           � ExpO3 = Objeto oDlg                                        ���
���           � ExpL1 = Acao do Codeblock                                  ���
���           � ExpC2 = Conta Inicial                                      ���
���           � ExpC3 = Conta Final                                        ���
���           � ExpC4 = C.Custo Inicial                                    ���
���           � ExpC5 = C.Custo Final                                      ���
���           � ExpC6 = Item Inicial                                       ���
���           � ExpC7 = Cl.Valor Inicial                                   ���
���           � ExpC8 = Cl.Valor Final                                     ���
���           � ExpC9 = Moeda                                              ���
���           � ExpD1 = Data Inicial                                       ���
���           � ExpD2 = Data Final                                         ���
���           � ExpA1 = Matriz aSetOfBook                                  ���
���           � ExpL2 = Indica se imprime movimento zerado ou nao.         ���
���           � ExpC10= Tipo de Saldo                                      ���
���           � ExpL3 = Indica se junta CC ou nao.                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CtbFCon(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				 cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				 aSetOfBook,lNoMov,cSaldo,lJunta)

Local aStru 	:= CT2->(dbStruct())
Local cQuery	:= ""                
	
Local cCpoChave, cTmpChave

Local cValid	:= ""
Local cVldEnt	:= ""
Local cCustoF	:= ""
Local cContaF	:= ""
Local cItemF	:= ""
Local cClVlF	:= ""
Local nTotal	:= 0
Local ni


cCustoF := CCUSTOFIM
cContaF := CCONTAFIM      
cItemF 	:= CITEMFIM
cClVlF 	:= CCLVLFIM

If !IsBlind()
	oMeter:nTotal := CT1->(RecCount())
EndIf

// ������������������Ŀ
// � Obt�m os d�bitos �
// ��������������������
dbSelectArea("CT2")
dbSetOrder(2)
		
cQuery	:= "SELECT * "
cQuery	+= " FROM " + RetSqlName("CT2")
cQuery	+= " WHERE CT2_FILIAL = '" + xFilial("CT2") + "' AND " 
cQuery	+= " CT2_DEBITO BETWEEN  '" + cContaIni + "' AND '" + cContaFim + "' AND "
cQuery	+= " CT2_CCD BETWEEN  '" + cCustoIni + "' AND '" + cCustoFim + "' AND "
cQuery	+= " CT2_ITEMD BETWEEN  '" + cItemIni + "' AND '" + cItemFim + "' AND "
cQuery	+= " CT2_CLVLDB	BETWEEN  '" + cClVlIni + "' AND '"+ cClVlFim + "' AND "
cQuery	+= " CT2_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' AND "
cQuery	+= " CT2_MOEDLC = '" + cMoeda + "' AND "
cQuery	+= " CT2_TPSALD = '" + cSaldo + "' AND "
cQuery	+= " (CT2_DC = '1' OR CT2_DC = '3') AND "
cQuery	+= " D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY CT2_FILIAL, CT2_DEBITO, CT2_DATA"
		
cQuery := ChangeQuery(cQuery)		   		
		
If ( Select ( "CT2") <> 0 )
	dbSelectArea ( "CT2" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'CT2',.T.,.F.)		
  		
For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		TCSetField("CT2", aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])				
	Endif
Next ni
		
dbSelectArea("CT2")
  		
While !Eof()
	CtbGrvFCon(lJunta,cMoeda,cSaldo,"1","CT2")
	dbSelectArea("CT2")
	dbSkip()
EndDo		
		
dbSelectArea("CT2")
dbCloseArea()
ChKFile("CT2")		

// ������������������Ŀ
// � Obt�m os creditos�
// ��������������������
dbSelectArea("CT2")
dbSetOrder(3)

cQuery	:= "SELECT * "
cQuery	+= " FROM " + RetSqlName("CT2")
cQuery	+= " WHERE CT2_FILIAL = '" + xFilial("CT2") + "' AND "

cQuery	+= " CT2_CREDIT BETWEEN  '" + cContaIni + "' AND '" + cContaFim + "' AND "
cQuery	+= " CT2_CCC BETWEEN  '" + cCustoIni + "' AND '" + cCustoFim + "' AND "
cQuery	+= " CT2_ITEMC BETWEEN  '" + cItemIni + "' AND '" + cItemFim + "' AND "
cQuery	+= " CT2_CLVLCR	BETWEEN  '" + cClVlIni + "' AND '"+ cClVlFim + "' AND "
cQuery	+= " CT2_DATA BETWEEN '" + DTOS(dDataIni) + "' AND '"+ DTOS(dDataFim) + "' AND "
cQuery	+= " CT2_MOEDLC = '" + cMoeda + "' AND "
cQuery	+= " CT2_TPSALD = '" + cSaldo + "' AND "
cQuery	+= " (CT2_DC = '2' OR CT2_DC = '3') AND "
cQuery	+= " D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY CT2_FILIAL, CT2_CREDIT, CT2_DATA"
		
cQuery := ChangeQuery(cQuery)		   		
		
If ( Select ( "CT2") <> 0 )
	dbSelectArea ( "CT2" )
	dbCloseArea ()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'CT2',.T.,.F.)		

For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		TCSetField("CT2", aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])				
	Endif
Next ni
  		
dbSelectArea("CT2")
  		
While !Eof()
	CtbGrvFCon(lJunta,cMoeda,cSaldo,"2","CT2")
	dbSelectArea("CT2")
	dbSkip()
EndDo		
		
dbSelectArea("CT2")
dbCloseArea()
ChKFile("CT2")
				
If lNoMov
	dbSelectArea("CT1")
	dbSetOrder(3)
	IndRegua(	Alias(),CriaTrab(nil,.f.),IndexKey(),,;
					"CT1_FILIAL == '" + xFilial() + "' .And. CT1_CONTA <= '" +;
					cContaF + "' .And. CT1_CLASSE = '2'",STR0025) //"Seleccionando registros..."
	cCpoChave := "CT1_CONTA"
	cTmpChave := "CONTA"
	cAlias    := Alias()

	While ! Eof()
		dbSelectArea("cArqTmp")
		If ! DbSeek(&(cAlias + "->" + cCpoChave))
			CtbGrvNoMov(&(cAlias + "->" + cCpoChave),dDataIni,cTmpChave)
		Endif
		DbSelectArea(cAlias)
		DbSkip()
	EndDo

	DbSelectArea(cAlias)
	DbClearFil()
	RetIndex(cAlias)
Endif

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGrvFCon� Autor � Julio Cesar           � Data � 16/10/02 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Grava registros no arq temporario - Fluxo de Contas         ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbGrvFCon(lJunta,cMoeda,cSaldo,cTipo)                      ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpL1 = Se Junta CC ou nao                                 ���
���           � ExpC1 = Moeda                                              ���
���           � ExpC2 = Tipo de saldo                                      ���
��            � ExpC3 = Tipo do lancamento                                 ���
���           � cAliasQry = Alias com o conteudo selecionado do CT2        ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CtbGrvFCon(lJunta,cMoeda,cSaldo,cTipo,cAliasQry)

Local aAreaCT1 := {}
Local cConta
Local cContra
Local cCusto
Local cItem
Local cCLVL
Local cTPConta

If cTipo == "1"
	cConta 	:= CT2->CT2_DEBITO
	cContra	:= CT2->CT2_CREDIT
	cCusto	:= CT2->CT2_CCD
	cItem	:= CT2->CT2_ITEMD
	cCLVL	:= CT2->CT2_CLVLDB
EndIf	
If cTipo == "2"
	cConta 	:= CT2->CT2_CREDIT
	cContra	:= CT2->CT2_DEBITO
	cCusto	:= CT2->CT2_CCC
	cItem	:= CT2->CT2_ITEMC
	cCLVL	:= CT2->CT2_CLVLCR
EndIf		           

dbSelectArea("CT1")
aAreaCT1 := GetArea()
dbSetOrder(1)
MsSeek(xFilial()+cConta)
cTPConta := CT1->CT1_NORMAL
RestArea(aAreaCT1)

dbSelectArea("cArqTmp")
dbSetOrder(1)	

RecLock("cArqTmp",.T.)

//Para a impressao deste relatorio, preciso identificas as entradas e saidas
//Natureza Devedora, Lancto Devedor => Entrada
//Natureza Devedora, Lancto Credor => Saida
//Natureza Credora, Lancto Devedor => Saida
//Natureza Credora, Lancto Credor => Entrada
If (cTipo == "1" .and. cTPConta == "1") .or.;
   (cTipo == "2" .and. cTPConta == "2")
	cTipo := "1"
	Replace LANCENT	With CT2->CT2_VALOR*(If(cTPConta == "1",-1,1))
Else
	cTipo := "2"
	Replace LANCSAI	With CT2->CT2_VALOR*(If(cTPConta == "1",-1,1))
EndIf	    
Replace DATAL		With CT2->CT2_DATA
Replace TIPO		With cTipo
Replace LOTE		With CT2->CT2_LOTE
Replace SUBLOTE	    With CT2->CT2_SBLOTE
Replace DOC			With CT2->CT2_DOC
Replace LINHA		With CT2->CT2_LINHA
Replace CONTA		With cConta
Replace XPARTIDA	With cContra
Replace CCUSTO		With cCusto
Replace ITEM		With cItem
Replace CLVL		With cCLVL
Replace HISTORICO	With CT2->CT2_HIST
Replace EMPORI		With CT2->CT2_EMPORI
Replace FILORI		With CT2->CT2_FILORI
Replace SEQHIST	    With CT2->CT2_SEQHIS
Replace SEQLAN		With CT2->CT2_SEQLAN
Replace NOMOV		With .F.							// Conta com movimento

MsUnlock()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CtbGrvNoMov � Autor � Julio Cesar         � Data � 16/10/02 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Grava registros no arq temporario sem movimento.            ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CtbGrvNoMov(cConta)                                         ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � cConteudo = Conteudo a ser gravado no campo chave de acordo���
���           �             com o razao impresso                           ���
���           � dDataL = Data para verificacao do movimento da conta       ���
���           � cCpoChave = Nome do campo para gravacao no temporario      ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function CtbGrvNoMov(cConteudo,dDataL,cCpoTmp)

dbSelectArea("cArqTmp")
dbSetOrder(1)	

RecLock("cArqTmp",.T.)
Replace &(cCpoTmp)	With cConteudo
If cCpoTmp = STR0026 //"CONTA"
	Replace HISTORICO With STR0027 //"CONTA SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CCUSTO"
	Replace HISTORICO With Upper(AllTrim(CtbSayApro("CTT"))) + " "  + STR0028 //"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "ITEM"
	Replace HISTORICO With Upper(AllTrim(CtbSayApro("CTD"))) + " "  + STR0028 //"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CLVL"
	Replace HISTORICO With Upper(AllTrim(CtbSayApro("CTH"))) + " "  + STR0028 //"SEM MOVIMENTO NO PERIODO"
Endif
Replace DATAL WITH dDataL 
MsUnlock()

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CTR550Sint� Autor � Julio Cesar           � Data � 16/10/02 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o �Imprime conta sintetica da conta do fluxo de contas         ���
��������������������������������������������������������������������������Ĵ��
���Sintaxe    �CTR550Sint(cConta,cDescSint,cMoeda,cDescConta,cCodRes)      ���
��������������������������������������������������������������������������Ĵ��
���Retorno    �Conta Sintetic		                                       ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � ExpC1 = Conta                                              ���
���           � ExpC2 = Descricao da Conta Sintetica                       ���
���           � ExpC3 = Moeda                                              ���
���           � ExpC4 = Descricao da Conta                                 ���
���           � ExpC5 = Codigo reduzido                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CTR550Sint(cConta,cDescSint,cMoeda,cDescConta,cCodRes)

Local aSaveArea := GetArea()

Local nPosCT1					//Guarda a posicao no CT1
Local cContaPai	:= ""
Local cContaSint	:= ""

dbSelectArea("CT1")
dbSetOrder(1)
If dbSeek(xFilial()+cConta)
	nPosCT1 	:= Recno()
	cDescConta  := &("CT1->CT1_DESC"+cMoeda)
	If Empty(cDescConta)
		cDescConta  := CT1->CT1_DESC01
	Endif
	cCodRes		:= CT1->CT1_RES
	cContaPai	:= CT1->CT1_CTASUP
	If dbSeek(xFilial()+cContaPai)
		cContaSint 	:= CT1->CT1_CONTA
		cDescSint	:= &("CT1->CT1_DESC"+cMoeda)
		If Empty(cDescSint)
			cDescSint := CT1->CT1_DESC01
		Endif
	EndIf	
	dbGoto(nPosCT1)
EndIf	

RestArea(aSaveArea)

Return cContaSint
