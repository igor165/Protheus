#Include "Ctbr220.Ch"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � Ctbr220	� Autor � Simone Mie Sato   	� Data � 21.09.01 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Item/Cl.Valor                 		 	 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctbr220      											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 		 � SIGACTB      											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctbr220()           
PRIVATE titulo		:= "" 
Private nomeprog	:= "CTBR220"

CTBR220R4()

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR220R4 � Autor� Daniel Sakavicius		� Data � 01/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Item/Cl.Valor - R4           	 				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR100R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR220R4()
Local cArqTmp := ""
 
Private cSayItem		:= CtbSayApro("CTD")
Private cSayClVl		:= CtbSayApro("CTH")
//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef( @cArqTmp )      

If ValType( oReport ) == 'O'
	If !Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	
	
	oReport :PrintDialog()      

Endif

oReport := nil

If Select("cArqTmp") > 0
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea() 

	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIf
EndIf

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 01/09/06 ���
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
Static Function ReportDef( cArqTmp )   
local aArea	   		:= GetArea()   
Local cReport		:= "CTBR220"
Local cTitulo		:= OemToAnsi(STR0003)+Alltrim(Upper(cSayItem))+" / " +Alltrim(Upper(cSayClVl)) 	//"Balancete de Verificacao"
Local cDesc			:= OemToAnsi(STR0001)+ Alltrim(Upper(cSayItem))+" / "+ Alltrim(Upper(cSayClVl))	//"Este programa ira imprimir o Balancete de  "
Local cPerg	   		:= "CTR220"			       
Local aTamItem		:= TAMSX3("CTD_ITEM")    
Local aTamConta		:= TAMSX3("CTH_CLVL")    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= TAMSX3("CTH_DESC01")
Local nDecimais

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
oReport	:= TReport():New( cReport, cTitulo, cPerg, { |oReport|  ReportPrint(oReport, @cArqTmp) }, cDesc ) 

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

oSection0  := TRSection():New( oReport, cSayItem, {"cArqTmp","CTD"},, .F., .F. )        
TRCell():New( oSection0, "ITEM"	 		, ,STR0026 + "  [" + Alltrim(Upper(cSayItem))+ "]  "/*Titulo*/,/*Picture*/,aTamItem[1]/*Tamanho*/,/*lPixel*/,{ || EntidadeCTB(cArqTMp->ITEM ,0,0,20,.F.,cMascItem,,,,,,.F.) }/*CodeBlock*/)  //"CODIGO"

oSection0:SetNoFilter({"cArqTmp"})
oSection0:SetLineStyle()


oSection1  := TRSection():New( oSection0, cSayClVl, {"cArqTmp"},, .F., .F. )        
TRCell():New( oSection1, "CLVL"	 		, ,STR0026/*Titulo*/,/*Picture*/,aTamConta[1]/*Tamanho*/,/*lPixel*/,{|| IIF(cArqTmp->TIPOCONTA=="2","  ","")+EntidadeCTB(cArqTmp->CLVL ,0,0,70,.F.,cMascClVl,,,,,,.F.) }/*CodeBlock*/)  //"CODIGO"
TRCell():New( oSection1, "DESCCLVL"  	, ,STR0027/*Titulo*/,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,{ || (cArqTMp->DESCCLVL) }/*CodeBlock*/)  //"DESCRICAO"
TRCell():New( oSection1, "SALDOANT" 	, ,STR0028/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,,"RIGHT")  //"SALDO ANTERIOR"
TRCell():New( oSection1, "SALDODEB" 	, ,STR0029/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,,"RIGHT")   //"DEBITO"
TRCell():New( oSection1, "SALDOCRD" 	, ,STR0030/*Titulo*/,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,,"RIGHT")   //"CREDITO"
TRCell():New( oSection1, "MOVIMENTO"	, ,STR0031/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,,"RIGHT") //"MOVIMENTO DO PERIODO"
TRCell():New( oSection1, "SALDOATU" 	, ,STR0032/*Titulo*/,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,,,"RIGHT")   //"SALDO ATUAL"

oSection1:SetNoFilter({"cArqTmp"})

oSection1:SetLinesBefore(0)

Return(oReport)

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
Static Function ReportPrint( oReport, cArqTmp )  

Local oSection0 	:= oReport:Section(1)    
Local oSection1 	:= oReport:Section(1):Section(1)
Local aSetOfBook
Local aCtbMoeda		:= {}
Local cDescMoeda
Local lFirstPage	:= .T.
Local nDecimais  	
Local cItemAnt		:= ""
Local cItResAnt		:= ""
Local l132			:= .F.
Local nTamConta		:= Len(CriaVar("CT1_CONTA"))
Local nTamCC		:= Len(CriaVar("CTT_CUSTO"))
Local nTamVal		:= TamSX3("CT2_VALOR")[1]
Local cConta		:= Space(nTamConta)
Local cCusto  		:= Space(nTamCC)
Local cSepara1		:= ""
Local cSepara2		:= ""
Local nDigitAte		:= 0
Local nDivide		:= 0
Local cSegAte 	    := mv_par13
Local lPula			:= Iif(mv_par22==1,.T.,.F.) 
Local lPrintZero	:= Iif(mv_par23==1,.T.,.F.)
Local lImpAntLP		:= Iif(mv_par25 == 1,.T.,.F.)
Local lNormal		:= Iif(mv_par21==1,.T.,.F.)
Local dDataLP  		:= mv_par26
Local dDataFim 		:= mv_par02
Local lJaPulou		:= .F.
Local lVlrZerado	:= Iif(mv_par09==1,.T.,.F.) 
Local nCont			:= 0
Local cTipo         := ""
Local lAtSlComp		:= Iif(GETMV("MV_SLDCOMP") == "S",.T.,.F.)    
Local cFilter		:= ""
Local cTipoAnt		:= ""     
Local cMensagem		:= ""
Local nTotCrd		:= 0
Local nTotDeb		:= 0                          
Local nTotGerCrd	:= 0
Local nTotGerDeb	:= 0                          
Local oTotDeb		
Local oTotCrd
Local oTotGerDeb		
Local oTotGerCrd
Local cPicture
Local cPerg	   		:= "CTR220"			       
Local cTitulo
Local lColDbCr 		:= If(cPaisLoc $ "RUS",.T.,.F.) // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Local lRedStorn		:= If(cPaisLoc $ "RUS",SuperGetMV("MV_REDSTOR",.F.,.F.),.F.) // CAZARINI - 20/06/2017 - Parameter to activate Red Storn

Pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Mostra tela de aviso - atualizacao de saldos				 �
//����������������������������������������������������������������
cMensagem := OemToAnsi(STR0021)+chr(13)  		//"Caso nao atualize os saldos compostos na"
cMensagem += OemToAnsi(STR0022)+chr(13)  		//"emissao dos relatorios(MV_SLDCOMP ='N'),"
cMensagem += OemToAnsi(STR0023)+chr(13)  		//"rodar a rotina de atualizacao de saldos "

IF !lAtSlComp
	If !MsgYesNo(cMensagem,OemToAnsi(STR0024))	//"ATEN��O"
		oReport:CancelPrint()
		Return .F.
	EndIf
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			     �
//����������������������������������������������������������������
If !ct040Valid(mv_par08)
	oReport:CancelPrint()
	Return .F.
Else
   aSetOfBook := CTBSetOf(mv_par08)
Endif
                                                                         
If mv_par24 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par24 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par24 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	

aCtbMoeda  	:= CtbMoeda(mv_par10,nDivide)
If Empty(aCtbMoeda[1])
	Help(" ",1,"NOMOEDA")
	oReport:CancelPrint()
	Return(.F.)
Endif

cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par10)

// Mascara do Item Contabil
If Empty(aSetOfBook[7])
	cMascItem := ""
Else
	cMascItem := RetMasCtb(aSetOfBook[7],@cSepara1)
EndIf

//Mascara da Classe de Valor
If Empty(aSetOfBook[8])
	cMascClVl :=  ""
Else
	cMascClVl := RetMasCtb(aSetOfBook[8],@cSepara2)
EndIf

cPicture := aSetOfBook[4]

//��������������������������������������������������������������Ŀ
//� Carrega titulo do relatorio: Analitico / Sintetico			 �
//����������������������������������������������������������������
IF mv_par07 == 1
	cTitulo:=	OemToAnsi(STR0007)+ Alltrim(Upper(cSayItem)) + " / "+ Alltrim(Upper(cSayClvl)) 	//"BALANCETE ANALITICO DE  "
ElseIf mv_par07 == 2
	cTitulo:=	OemToAnsi(STR0006) + Alltrim(Upper(cSayItem)) + " / " + Alltrim(Upper(cSayclvl))	//"BALANCETE SINTETICO DE  "
ElseIf mv_par07 == 3
	cTitulo:=	OemToAnsi(STR0008) + Alltrim(Upper(cSayItem)) + " / "+ Alltrim(Upper(cSayClVl))	//"BALANCETE DE  "
EndIf

cTitulo += 	OemToAnsi(STR0009) + DTOC(mv_par01) + OemToAnsi(STR0010) + Dtoc(mv_par02) + ;
				OemToAnsi(STR0011) + cDescMoeda

If mv_par12 > "1"			
	cTitulo += " (" + Tabela("SL", mv_par12, .F.) + ")"
Endif

oReport:SetPageNumber( mv_par11 )
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,cTitulo,,,,,oReport) } )
//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao							  �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CTX","",cConta,cConta,cCusto,cCusto,mv_par03,mv_par04,;
				mv_par05,mv_par06,mv_par10,mv_par12,aSetOfBook,mv_par14,;
				mv_par15,mv_par16,mv_par17,l132,.F.,2,"CTD",lImpAntLP,dDataLP,nDivide,lVlrZerado)},;				
				OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor�rio..."
				OemToAnsi(STR0003)+Alltrim(Upper(cSayItem)) + " / " + Alltrim(Upper(cSayClVl)))     //"Balancete Verificacao "

If Select("cArqTmp") <= 0
	DbCloseArea()
	oReport:Cancel()

	Return .F.
Endif

dbSelectArea("cArqTmp")
dbSetOrder(1)
dbGoTop()        

If RecCount() == 0 .Or. !Empty(aSetOfBook[5])
	If Empty(aSetOfBook[5]) 
		// ATENCAO ### "Nao existem dados para os par�metros especificados."
		Aviso(STR0024,STR0025,{"Ok"})
	EndIf
	
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase("cArqInd"+OrdBagExt()) 
	
	oReport:cancel()
	Return
Endif

//��������������������������������������������������������������Ŀ
//�Davi Torchio - 10/07/2007                                     �
//�Controle de numera��o de pagina para o relatorio personalizado�
//����������������������������������������������������������������
Private nPagIni		:= MV_PAR11 // parametro da pagina inicial
Private nPagFim		:= 999999 	// parametro da pagina final
Private nReinicia	:= MV_PAR11	// parametro de reinicio de pagina
Private l1StQb		:= .T.		// primeira quebra
Private lNewVars	:= .T.		// inicializa as variaveis
Private m_pag		:= MV_PAR11 // controle de numera��o de pagina
Private nBloco      := 1		// controle do bloco a ser impresso
Private nBlCount	:= 0		// contador do bloco impress


oReport:SetMeter(RecCount())

// Verifica Se existe filtragem Ate o Segmento
If !Empty(cSegAte)
	For nCont := 1 to Val(cSegAte)
		nDigitAte += Val(Subs(cMascClVl,nCont,1))	
	Next
EndIf		

If mv_par07 == 1					// So imprime Sinteticas
	cFilter := "cArqTmp->TIPOCLVL <>  '2'  "
ElseIf mv_par07 == 2				// So imprime Analiticas
	cFilter := "cArqTmp->TIPOCLVL <>  '1'  "
EndIf

oSection0:SetRelation({|| xFilial("CTD")+cArqTmp->ITEM },"CTD",1,.T.)


// Salta pagina por item
If mv_par19 == 1
	oSection0:SetPageBreak(.T.)
EndIf

oSection0:SetLineCondition( {||( cItemAnt := cArqTmp->ITEM, .T.) } )
oSection1:SetFilter( cFilter )                                                
oSection1:SetParentFilter({|cParam| cArqTmp->ITEM == cParam  },{|| cArqTmp->ITEM }) 														

If mv_par20 == 2
	oSection0:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTMp->ITEMRES,0,0,20,.F.,cMascItem,,,,,,.F.) } )
Endif			

If mv_par21 == 2 
	oSection1:Cell("CLVL"):SetBlock( { || IIF(cArqTmp->TIPOCONTA=="2","  ","")+EntidadeCTB(cArqTmp->CLVLRES,0,0,20,.F.,cMascClVl,,,,,,.F.) } )		
EndIf	

oSection1:Cell("SALDOANT"):SetBlock( {|| ValorCTB(cArqTmp->SALDOANT,,,nTamVal,nDecimais,.T.,cPicture,Iif(lRedStorn,cArqTmp->CLNORMAL,"2"),,,,,,lPrintZero,.F.) } )
oSection1:Cell("SALDODEB"):SetBlock( {|| ValorCTB(cArqTmp->SALDODEB,,,nTamVal,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) } )
oSection1:Cell("SALDOCRD"):SetBlock( {|| ValorCTB(cArqTmp->SALDOCRD,,,nTamVal,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) } )

//Imprime Movimento (1=Sim;2=Nao)
If mv_par18 = 1
	oSection1:Cell("MOVIMENTO"):SetBlock( {|| ValorCTB(cArqTmp->MOVIMENTO,,,nTamVal,nDecimais,.T.,cPicture,Iif(lRedStorn,cArqTmp->CLNORMAL,"2"),,,,,, lPrintZero,.F.)})
Else
	oSection1:Cell("MOVIMENTO"):Disable()
Endif

oSection1:Cell("SALDOATU"):SetBlock( {|| ValorCTB(cArqTmp->SALDOATU,,,nTamVal,nDecimais,.T.,cPicture,Iif(lRedStorn,cArqTmp->CLNORMAL,"2"),,,,,,lPrintZero,.F.)})
oSection1:Cell("SALDOATU"):SetCellBreak()

oBreak := TRBreak():New(oSection1, {|| cArqTMP->ITEM },{||	STR0020+ "[" + Alltrim(Upper(cSayItem))+ "] : " + cItemAnt })	//	" T O T A I S "

//Totais
oTotDeb :=	TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM", oBreak /*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || Iif(cArqTMP->TIPOCLVL="1" .And. mv_par07==3,0,cArqTMP->SALDODEB) },.F.,.F.,.F.,oSection1)

TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT", oBreak/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || (nTotDeb := oTotDeb:GetValue(),;
	ValorCTB(nTotDeb,,,nTamVal,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.F.,.F.,oSection1)

oTotCrd :=	TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM", oBreak /*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || Iif(cArqTMP->TIPOCLVL="1" .And. mv_par07==3,0,cArqTMP->SALDOCRD) },.F.,.F.,.F.,oSection1)

TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT", oBreak/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || (nTotCrd := oTotCrd:GetValue(),;
	ValorCTB(nTotCrd,,,nTamVal,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.F.,.F.,oSection1)
                                                                
oTotDeb:Disable()
oTotCrd:Disable()

//Total Geral
oBreakGer := TRBreak():New(oSection1, {|| .T. },{||STR0018 })	//	"T O T A I S  D O  P E R I O D O: "

oTotGerDeb :=	TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM", /*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || Iif(cArqTMP->TIPOCLVL="1" .And. mv_par07==3,0,cArqTMP->SALDODEB) },.F.,.T.,.F.,oSection1)

TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT", /*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || (nTotGerDeb := oTotGerDeb:GetValue(),;
	ValorCTB(nTotGerDeb,,,nTamVal,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.T.,.F.,oSection1)

oTotGerCrd :=	TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM", /*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || Iif(cArqTMP->TIPOCLVL="1".And. mv_par07==3,0,cArqTMP->SALDOCRD) },.F.,.T.,.F.,oSection1)

TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT", /*oBreak*/,/*Titulo*/,/*cPicture*/,;
	{ || (nTotGerCrd := oTotGerCrd:GetValue(),;
	ValorCTB(nTotGerCrd,,,nTamVal,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.T.,.F.,oSection1)

oTotGerDeb:Disable()
oTotGerCrd:Disable()

oReport:SetTotalInLine(.F.)	
oReport:SetTotalText(STR0018)

oSection1:SetTotalInLine(.F.)          
oSection1:SetTotalText(STR0020+" "+UPPER(cSayItem)) //Total 

oSection1:OnPrintLine( {|| ( IIf( lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCLVL == "1" .And. cTipoAnt == "2")), oReport:skipLine(),NIL),;
								 cTipoAnt := cArqTmp->TIPOCLVL)})

oSection0:Print() 

Return .T.