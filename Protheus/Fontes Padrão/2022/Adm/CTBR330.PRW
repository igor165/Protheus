#Include "Ctbr330.Ch"
#Include "PROTHEUS.Ch"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR330  � Autor � Eduardo Nunes Cirqueira � Data � 14/09/06 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Item/C.Custo                   		 	        ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr330()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/
Function CtbR330()
PRIVATE titulo		:= "" 
Private nomeprog	:= "CTBR330"

CTBR330R4()

//Limpa os arquivos tempor�rios 
CTBGerClean()

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR330R4 � Autor� Eduardo Nunes         � Data � 14/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Item/C.Custo - R4                				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR330R4	          									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                 	                   				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR330R4() 

//Private cPictVal 	:= PesqPict("CT2","CT2_VALOR")
Private cSayItem	:= CtbSayApro("CTD")
Private cSayCC		:= CtbSayApro("CTT")
Private aTamVal	:= TAMSX3("CT2_VALOR")

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
���Fun��o	 � ReportDef � Autor � Eduardo Nunes        � Data � 14/09/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    			  	  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local aArea	  		:= GetArea()
Local cREPORT		:= "CTBR330"
Local cTITULO		:= OemToAnsi(STR0003)+Alltrim(Upper(cSayItem))+" / " +Alltrim(Upper(cSayCC)) 	//"Balancete de Verificacao por "
Local cDESC			:= OemToAnsi(STR0001)+ Alltrim(Upper(cSayItem))+" / "+ Alltrim(Upper(cSayCC))	//"Este programa ira imprimir o Balancete de  "
Local cPerg	  		:= "CTR330"
Local aTamItem		:= TAMSX3("CTD_ITEM")
Local aTamDescIt	:= TAMSX3("CTD_DESC01")
Local aTamConta	:= TAMSX3("CTT_CUSTO")
Local aTamDesc		:= TAMSX3("CTT_DESC01")
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
oReport	:= TReport():New( cReport,cTITULO,cPERG, { |oReport| ReportPrint( oReport ) }, cDESC ) 

oReport:SetTotalInLine(.F.)
oReport:SetTotalText(STR0018)	//"T O T A I S  D O  P E R I O D O: "

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
oSection0  := TRSection():New( oReport, AllTrim(cSayItem), {"cArqTmp","CTT"},, .F., .F. )        
TRCell():New( oSection0, "ITEM",,Upper(cSayItem)/*Titulo*/,/*Picture*/,aTamItem[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection0, "DESC",," "            /*Titulo*/,/*Picture*/,aTamDescIt[1]/*Tamanho*/,/*lPixel*/,{ || cArqTmp->DESCITEM }/*CodeBlock*/)
oSection0:SetLineStyle()

oSection1  := TRSection():New( oSection0, AllTrim(cSayCC), {"cArqTmp"},, .F., .F. )        
TRCell():New( oSection1, "CUSTO"    ,,STR0025,/*Picture*/,aTamConta[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oSection1, "DESCCUSTO",,STR0026,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,{ || (cArqTMp->DESCCC) }/*CodeBlock*/)
TRCell():New( oSection1, "SALDOANT" ,,STR0027,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"RIGHT")
TRCell():New( oSection1, "SALDODEB" ,,STR0028,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"RIGHT")
TRCell():New( oSection1, "SALDOCRD" ,,STR0029,/*Picture*/,aTamVal[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"RIGHT")
TRCell():New( oSection1, "MOVIMENTO",,STR0030,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"RIGHT")
TRCell():New( oSection1, "SALDOATU" ,,STR0031,/*Picture*/,aTamVal[1]+2/*Tamanho*/,/*lPixel*/,/*CodeBlock*/,/*"RIGHT"*/,,"RIGHT")
   
oSection1:Cell("SALDOANT"):lHeaderSize		:= .F.   
oSection1:Cell("SALDODEB"):lHeaderSize		:= .F.   
oSection1:Cell("SALDOCRD"):lHeaderSize		:= .F.   
oSection1:Cell("MOVIMENTO"):lHeaderSize		:= .F.   
oSection1:Cell("SALDOATU"):lHeaderSize		:= .F.   


oSection1:SetTotalInLine(.F.)          
oSection1:SetTotalText(STR0020+" "+UPPER(cSayItem)) //Total 
oSection1:SetHeaderPage(.T.)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � ReportPrint � Autor � Eduardo Nunes      � Data � 14/09/06 ���
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
Local oSection0 		:= oReport:Section(1)    
Local oSection1 		:= oReport:Section(1):Section(1)

Local oBreak
Local oTotDeb, oTotCrd
Local nTotDeb, nTotCrd

Local oBreakGrl
Local oGrlDeb, oGrlCrd
Local nGrlDeb, nGrlCrd

Local aSetOfBook
Local aCtbMoeda		:= {}
Local cDescMoeda
Local cMensagem		:= ""
Local cMascItem		:= ""
Local cMascCC		:= ""
Local cSepara1		:= ""
Local cSepara2		:= ""

Local lFirstPage	:= .T. 
Local lRet			:= .T. 
Local nDecimais
Local cItResAnt		:= ""
Local l132			:= .F.
Local nTamConta		:= Len(CriaVar("CT1_CONTA"))
Local nTamCC		:= Len(CriaVar("CTT_CUSTO"))
Local cCtaIni		:= Space(nTamConta)
Local cCtaFim		:= Repl('Z',nTamConta)
Local cCusto  		:= Space(nTamCC)

Local nDigitAte		:= 0
Local nDivide		:= 0
Local cSegAte 	   	:= mv_par13
Local cArqTmp   	:= ""
Local lPulaPag		:= Iif(mv_par19==1,.T.,.F.) 
Local lPula			:= Iif(mv_par22==1,.T.,.F.) 
Local lPrintZero	:= Iif(mv_par23==1,.T.,.F.)
Local lImpAntLP		:= Iif(mv_par25==1,.T.,.F.)
Local lNormal		:= Iif(mv_par21==1,.T.,.F.)
Local dDataLP  		:= mv_par26
Local dDataFim 		:= mv_par02
Local lJaPulou		:= .F.
Local lVlrZerado	:= Iif(mv_par09==1,.T.,.F.) 
Local nCont			:= 0
Local cTipo			:= ""
Local lAtSlComp		:= Iif(GETMV("MV_SLDCOMP") == "S",.T.,.F.)    
Local cFilter		:= ""
Local cTipoAnt		:= ""
Local cPicture		:= ""
Local cFiltro		:= oSection0:GetAdvplExpr()     

LOCAL CTIT			:=  "."+OemToAnsi(STR0003)+Alltrim(Upper(cSayItem))+" / " +Alltrim(Upper(cSayCC)) 	//"Balancete de Verificacao por "
Local lColDbCr 		:= .T. // Disconsider cTipo in ValorCTB function, setting cTipo to empty

//��������������������������������������������������������������Ŀ
//� Mostra tela de aviso - atualizacao de saldos				 �
//����������������������������������������������������������������
cMensagem := OemToAnsi(STR0021)+chr(13)  		//"Caso nao atualize os saldos compostos na"
cMensagem += OemToAnsi(STR0022)+chr(13)  		//"emissao dos relatorios(MV_SLDCOMP ='N'),"
cMensagem += OemToAnsi(STR0023)+chr(13)  		//"rodar a rotina de atualizacao de saldos "

IF !lAtSlComp
	If !MsgYesNo(cMensagem,OemToAnsi(STR0024))	//"ATEN��O"
		Return
	EndIf
Endif

oReport:SetPageNumber( mv_par11 )
oReport:SetCustomText( {|| CtCGCCabTR(,,,,,mv_par02,cTIT,,,,,oReport ) } )

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			     �
//����������������������������������������������������������������
If !ct040Valid(mv_par08)
	oReport:CancelPrint()
	Return
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
	lRet := .F.
Endif

If !lRet
	dbClearFilter()
	Return
EndIf

cDescMoeda 	:= aCtbMoeda[2]
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par10)

//Mascara do Centro de Custo
If Empty(aSetOfBook[6])
	cMascCC :=  GetMv("MV_MASCCUS")
Else
	cMascCC := RetMasCtb(aSetOfBook[6],@cSepara1)
EndIf

// Mascara do Item Contabil
If Empty(aSetOfBook[7])
	cMascItem := ""
Else
	cMascItem := RetMasCtb(aSetOfBook[7],@cSepara2)
EndIf

cPicture := aSetOfBook[4]
         
#IFNDEF TOP
	If !Empty(cFiltro)
		CTT->( dbSetFilter( { || &cFiltro }, cFiltro ) )
	EndIf
#ENDIF

//��������������������������������������������������������������Ŀ
//� Monta Arquivo Temporario para Impressao							  �
//����������������������������������������������������������������
MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CTV","",cCtaIni,cCtaFim,mv_par05,mv_par06,;
				mv_par03,mv_par04,,,mv_par10,mv_par12,aSetOfBook,mv_par14,;
				mv_par15,mv_par16,mv_par17,l132,.F.,2,"CTD",lImpAntLP,dDataLP,;
				nDivide,lVlrZerado,,,,,,,,,,,,,,,cFiltro)},;
				OemToAnsi(OemToAnsi(STR0014)),;  //"Criando Arquivo Tempor�rio..."
				OemToAnsi(STR0003)+Upper(Alltrim(cSayItem)) +" / " +  Upper(Alltrim(cSayCC)) )     //"Balancete Verificacao ITEM / C.CUSTO
				                                                     
oReport:NoUserFilter()				
	 
// Verifica Se existe filtragem Ate o Segmento
If !Empty(cSegAte)
	For nCont := 1 to Val(cSegAte)
		nDigitAte += Val(Subs(cMascCC,nCont,1))	
	Next
EndIf		

If Select("cArqTmp") <= 0
	oReport:CancelPrint()
	Return
Endif

oReport:SetMeter(cArqTmp->(RecCount()))

If mv_par07 == 1					// So imprime Sinteticos
	cFilter := "cArqTmp->TIPOCC <>  '2'  "
ElseIf mv_par07 == 2				// So imprime Analiticos
	cFilter := "cArqTmp->TIPOCC <>  '1'  "
EndIf

oSection1:SetFilter( cFilter )
oSection1:SetParentFilter({|cParam| cArqTmp->ITEM == cParam  },{|| cArqTmp->ITEM })

// Setando os blocos de codigo para o Codigo do Item e do Centro de Custo
oSection0:Cell("ITEM"):SetBlock( { || EntidadeCTB(cArqTMp->ITEM ,0,0,20,.F.,cMascItem,,,,,,.F.) } )
oSection1:Cell("CUSTO"):SetBlock( {|| EntidadeCTB(cArqTmp->CUSTO,0,0,20,.F.,cMascCC  ,,,,,,.F.) } )

If mv_par20 == 2	//	Item Reduzido
	oSection0:Cell("ITEM"):SetBlock( { || IIF(cArqTmp->TIPOITEM=="2","  ","")+EntidadeCTB(cArqTMp->ITEMRES,0,0,20,.F.,cMascItem,,,,,,.F.) } )
Endif

If mv_par21 == 2	//	Centro de Custo Reduzido
	oSection1:Cell("CUSTO"):SetBlock( { || IIF(cArqTmp->TIPOCC=="2","  ","")+EntidadeCTB(cArqTmp->CUSTO,0,0,20,.F.,cMascCC,,,,,,.F.) } )
EndIf


//Imprime Movimento
If mv_par18 == 1
	If cPaisLoc == "RUS"
		oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->CCNORMAL,,,,,,lPrintZero,.F.) })
	Else
		oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->TIPOCC,,,,,,lPrintZero,.F.) })
	EndIf
Else
	oSection1:Cell("MOVIMENTO"):Disable()
Endif

If cPaisLoc == "RUS"
	oSection1:Cell("SALDOANT"):SetBlock({ || ValorCTB(cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->CCNORMAL,,,,,,lPrintZero,.F.) })
	oSection1:Cell("SALDODEB"):SetBlock({ || ValorCTB(cArqTmp->SALDODEB,,,aTamVal[1],nDecimais,.F.,cPicture,cArqTmp->CCNORMAL,,,,,,lPrintZero,.F.,lColDbCr) })
	oSection1:Cell("SALDOCRD"):SetBlock({ || ValorCTB(cArqTmp->SALDOCRD,,,aTamVal[1],nDecimais,.F.,cPicture,cArqTmp->CCNORMAL,,,,,,lPrintZero,.F.,lColDbCr) })
	oSection1:Cell("SALDOATU"):SetBlock({ || ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->CCNORMAL,,,,,,lPrintZero,.F.) })
Else
	oSection1:Cell("SALDOANT"):SetBlock({ || ValorCTB(cArqTmp->SALDOANT,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->TIPOCC,,,,,,lPrintZero,.F.) })
	oSection1:Cell("SALDODEB"):SetBlock({ || ValorCTB(cArqTmp->SALDODEB,,,aTamVal[1],nDecimais,.F.,cPicture,cArqTmp->TIPOCC,,,,,,lPrintZero,.F.) })
	oSection1:Cell("SALDOCRD"):SetBlock({ || ValorCTB(cArqTmp->SALDOCRD,,,aTamVal[1],nDecimais,.F.,cPicture,cArqTmp->TIPOCC,,,,,,lPrintZero,.F.) })
	oSection1:Cell("SALDOATU"):SetBlock({ || ValorCTB(cArqTmp->SALDOATU,,,aTamVal[1],nDecimais,.T.,cPicture,cArqTmp->TIPOCC,,,,,,lPrintZero,.F.) })
EndIf

If lPulaPag
	oSection0:SetPageBreak(.T.)
EndIf

oBreak := TRBreak():New(oSection1, {|| cArqTMP->ITEM },{||	STR0020+" "+ RTrim( Upper(cSayItem) ) })	//	" T O T A I S  D O "

oTotDeb :=	TRFunction():New(oSection1:Cell("SALDODEB"),nil,"SUM"    ,oBreak,/*Titulo*/,/*cPicture*/,{ || R330ValTot(1,cSegAte)},.F.,.F.,.F.,oSection1)

If cPaisLoc == "RUS"
	TRFunction():New(oSection1:Cell("SALDODEB"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,;
		{ || (nTotDeb := oTotDeb:GetValue(),ValorCTB(nTotDeb,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.F.,.F.,oSection1)
Else
	TRFunction():New(oSection1:Cell("SALDODEB"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,;
		{ || (nTotDeb := oTotDeb:GetValue(),ValorCTB(nTotDeb,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) )},.F.,.F.,.F.,oSection1)
EndIf

oTotCrd :=	TRFunction():New(oSection1:Cell("SALDOCRD"),nil,"SUM"    ,oBreak,/*Titulo*/,/*cPicture*/,{ || R330ValTot(2,cSegAte)},.F.,.F.,.F.,oSection1)
TRFunction():New(oSection1:Cell("SALDOCRD"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,;
	{ || (nTotCrd := oTotCrd:GetValue(),ValorCTB(nTotCrd,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.F.,.F.,oSection1)

oTotDeb:Disable()
oTotCrd:Disable()
                
// Total Geral
oBreakGrl := TRBreak():New(oSection1, {|| .T. },{||	STR0018 })	//	"T O T A I S  D O  P E R I O D O: "

If cPaisLoc == "RUS"
	TRFunction():New(oSection1:Cell("DESCCUSTO"),nil,"ONPRINT",/*oBreakGrl*/,/*Titulo*/,/*cPicture*/,{ || " "},.F.,.T.,.F.,oSection1)
	TRFunction():New(oSection1:Cell("SALDOANT"),nil,"ONPRINT",/*oBreakGrl*/,/*Titulo*/,/*cPicture*/,{ || " "},.F.,.T.,.F.,oSection1)
EndIf

oGrlDeb :=	TRFunction():New(oSection1:Cell("SALDODEB"),nil,"SUM"    ,/*oBreakGrl*/,/*Titulo*/,/*cPicture*/,{ || R330ValTot(1,cSegAte) },.F.,.T.,.F.,oSection1)

If cPaisLoc == "RUS"
	TRFunction():New(oSection1:Cell("SALDODEB"),nil,"ONPRINT",/*oBreakGrl*/,/*Titulo*/,/*cPicture*/,;
		{ || (nGrlDeb := oGrlDeb:GetValue(),ValorCTB(nGrlDeb,,,aTamVal[1],nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.T.,.F.,oSection1)
Else
	TRFunction():New(oSection1:Cell("SALDODEB"),nil,"ONPRINT",/*oBreakGrl*/,/*Titulo*/,/*cPicture*/,;
		{ || (nGrlDeb := oGrlDeb:GetValue(),ValorCTB(nGrlDeb,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) )},.F.,.T.,.F.,oSection1)
EndIf

oGrlCrd :=	TRFunction():New(oSection1:Cell("SALDOCRD"),nil,"SUM"    ,/*oBreakGrl*/,/*Titulo*/,/*cPicture*/,{ || R330ValTot(2,cSegAte) },.F.,.T.,.F.,oSection1)

TRFunction():New(oSection1:Cell("SALDOCRD"),nil,"ONPRINT",/*oBreakGrl*/,/*Titulo*/,/*cPicture*/,;
	{ || (nGrlCrd := oGrlCrd:GetValue(),ValorCTB(nGrlCrd,,,aTamVal[1],nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) )},.F.,.T.,.F.,oSection1)

oGrlDeb:Disable()
oGrlCrd:Disable()

oSection1:OnPrintLine( {||	(	IIf(	lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCC == "1" .And. cTipoAnt == "2")),;
												oReport:skipLine(),;
												NIL	), cTipoAnt := cArqTmp->TIPOCC )})
oSection0:Print()

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	


Return



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �R330ValTot�Autor  � Gustavo Henrique   � Data �  23/10/06   ���
�������������������������������������������������������������������������͹��
���Descricao � Regra para calculo do valor total por item e periodo       ���
�������������������������������������������������������������������������͹��
���Parametros� EXPN1 - 1 - Total Debito                                   ���
���          �         2 - Total Credito                                  ���
���          � EXPC2 - Segmento final                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Relatorio Balancete Item Conta x CC                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function R330ValTot(nTipo,cSegAte)

Local nRet	:= 0
           
If mv_par07 == 1					// So imprime Sinteticas - Soma Sinteticas
	If cArqTmp->TIPOCC == "1"
		If cArqTmp->NIVEL1 
			If nTipo == 1
				nRet := cArqTmp->SALDODEB
			Else	
				nRet := cArqTmp->SALDOCRD
			EndIf	
		EndIf
	EndIf
Else								// Soma Analiticas
	If Empty(cSegAte)				//Se nao tiver filtragem ate o nivel
		If cArqTmp->TIPOCC == "2"
			If nTipo == 1
				nRet := cArqTmp->SALDODEB
			Else
				nRet := cArqTmp->SALDOCRD
			EndIf	
		EndIf
	Else							//Se tiver filtragem, somo somente as sinteticas
		If cArqTmp->TIPOCC == "1"
			If cArqTmp->NIVEL1
				If nTipo == 1
					nRet := cArqTmp->SALDODEB
				Else
					nRet := cArqTmp->SALDOCRD
				EndIf	
			EndIf
		EndIf
   	Endif
EndIf

Return nRet