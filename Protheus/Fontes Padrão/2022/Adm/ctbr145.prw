#Include "Ctbr145.Ch"
#Include "PROTHEUS.Ch"

#DEFINE TAM_VALOR	18


// 17/08/2009 -- Filial com mais de 2 caracteres

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR145  � Autor � Cicero J. Silva   	� Data � 04.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Balancete Conta/C.Custo                 			 		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctbr145      											  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � Nenhum       											  ���
�������������������������������������������������������������������������Ĵ��
���Uso 		 � SIGACTB      											  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBR145()

Local aArea := GetArea()
Local oReport          

Local lOk := .T.
Local aCtbMoeda		:= {}
Local nDivide		:= 1

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "CTR145"
PRIVATE nomeProg  	:= "CTBR145"  
PRIVATE oTRF1
PRIVATE oTRF2
PRIVATE oTRF3
PRIVATE oTRF4
PRIVATE nTotMov	:= 0
PRIVATE nTotdbt		:= 0
PRIVATE nTotcrt		:= 0
PRIVATE titulo
PRIVATE aSelFil		:= {}
PRIVATE lTodasFil		:= .F.

//Ajusta Help
F145Help()
	
Pergunte(cPerg,.T.) // Precisa ativar as perguntas antes das definicoes.

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	lOk := .F.
EndIf


//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano�
//� Gerencial -> montagem especifica para impressao)			 �
//����������������������������������������������������������������
If !ct040Valid(mv_par08) // Set Of Books
	lOk := .F.
EndIf 

If mv_par24 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par24 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par24 == 4		// Divide por milhao
	nDivide := 1000000
EndIf

If lOk
	aCtbMoeda  	:= CtbMoeda(mv_par10) // Moeda?
	If Empty(aCtbMoeda[1])
		Help(" ",1,"NOMOEDA")
		lOk := .F.
	Endif
Endif

If lOk .And. mv_par29 == 1 .And. Len( aSelFil ) <= 0
	aSelFil := AdmGetFil(@lTodasFil)
	If Len( aSelFil ) <= 0
		lOk := .F.
	EndIf
EndIf  

If lOk
	oReport := ReportDef(aCtbMoeda,nDivide)
	oReport:PrintDialog()
EndIf

//Limpa os arquivos tempor�rios 
CTBGerClean()
	
RestArea(aArea)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef � Autor � Cicero J. Silva    � Data �  01/08/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� aCtbMoeda  - Matriz ref. a moeda                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportDef(aCtbMoeda,nDivide)

Local oReport
Local oSection1
Local oSection2 
Local oBreak

Local cSayCusto		:= CtbSayApro("CTT")

LOCAL cDesc1 		:= STR0001+ Upper(cSayCusto)	//"Este programa ira imprimir o Balancete de Conta / "
LOCAL cDesc2 		:= STR0002				  //"de acordo com os parametros solicitados pelo Usuario"

Local aTamCC    	:= TAMSX3("CTT_CUSTO")
Local aTamCCRes 	:= TAMSX3("CTT_RES")
Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCtaRes	:= TAMSX3("CT1_RES")
                                            
Local nTamCC  		:= Len(CriaVar("CTT->CTT_DESC"+mv_par10))
Local nTamCta 		:= Len(CriaVar("CT1->CT1_DESC"+mv_par10))

Local lPulaPag		:= Iif(mv_par20==1,.T.,.F.)
Local lPula			:= Iif(mv_par21==1,.T.,.F.)
Local lCCNormal		:= Iif(mv_par23==1,.T.,.F.)
Local lPrintZero	:= Iif(mv_par22==1,.T.,.F.)
Local lCNormal		:= Iif(mv_par25==1,.T.,.F.)

Local cSegAte 	   	:= mv_par13 // Imprimir ate o Segmento?
Local cSegmento		:= mv_par14
Local cSegIni		:= mv_par15
Local cSegFim		:= mv_par16
Local cFiltSegm		:= mv_par17
Local nDigitAte		:= 0
Local nPos			:= 0
Local nDigitos		:= 0
Local lMov			:= IIF(mv_par18 == 1,.T.,.F.) // Imprime movimento ?

Local cSepara1		:= ""
Local cSepara2		:= ""
Local aSetOfBook 	:= CTBSetOf(mv_par08)	
	
Local cMascara1		:= IIF (Empty(aSetOfBook[6]),GetMv("MV_MASCCUS"),RetMasCtb(aSetOfBook[6],@cSepara1))//Mascara do Centro de Custo
Local cMascara2		:= IIF (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara2))//Mascara da Conta

Local cPicture 		:= aSetOfBook[4]
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par10)
Local cDescMoeda 	:= aCtbMoeda[2]

Local bCdCUSTO		:= {|| EntidadeCTB(cArqTmp->CUSTO,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.) }
Local bCdCCRES		:= {|| EntidadeCTB(cArqTmp->CCRES,0,0,20,.F.,cMascara1,cSepara1,,,,,.F.) }
Local bCdCONTA		:= {|| EntidadeCTB(cArqTmp->CONTA,0,0,25 ,.F.,cMascara2,cSepara2,,,,,.F.)}
Local bCdCTRES		:= {|| EntidadeCTB(cArqTmp->CTARES,0,0,20,.F.,cMascara2,cSepara2,,,,,.F.)}

Local lColDbCr 		:= IIf(cPaisLoc $ "RUS",.T.,.F.) // Disconsider cTipo in ValorCTB function, setting cTipo to empty
Local lRedStorn		:= IIf(cPaisLoc $ "RUS",SuperGetMV("MV_REDSTOR",.F.,.F.),.F.) // Parameter to activate Red Storn
Local cPerg	 	    := "CTR145"


titulo	:= STR0003+ Upper(cSayCusto) 	//"Balancete de Verificacao Conta / "

//Soma a mascara do custo ao tamanho do campo
If Len( cMascara1 ) > 0 .And. Len( aTamCC ) > 0
	aTamCC[1] += Len( cMascara1 ) - 1
EndIf
//Soma a mascara da conta ao tamanho do campo
If Len( cMascara2 ) > 0 .And. Len( aTamConta ) > 0
	aTamConta[1] += Len( cMascara2 ) - 1
EndIf

oReport := TReport():New(nomeProg,titulo,cPerg,{|oReport| ReportPrint(oReport,aSetOfBook,cDescMoeda,cSayCusto,nDivide)},cDesc1+cDesc2)
oReport:SetLandScape(.T.)

// Sessao 1
oSection1 := TRSection():New(oReport,STR0025+" x "+cSayCusto ,{"cArqTmp",'CT1'},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/) //"Conta "
oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)          


//Somente sera impresso centro de custo analitico	
TRCell():New(oSection1,"CONTA"	,"cArqTmp",STR0026	,/*Picture*/,aTamConta[1]	,/*lPixel*/, bCdCONTA )// Codigo da Conta
TRCell():New(oSection1,"CTARES"	,"cArqTmp",STR0027	,/*Picture*/,aTamCtaRes[1]	,/*lPixel*/, bCdCTRES )// Codigo Reduzido da Conta
TRCell():New(oSection1,"DESCCTA"	,"cArqTmp",STR0028	,/*Picture*/,nTamCta		,/*lPixel*/,/*{|| }*/ )// Descricao da Conta

TRPosition():New( oSection1, "CT1", 1, {|| xFilial("CT1") + cArqTMP->CONTA })

If lCNormal
	oSection1:Cell("CTARES"):Disable()
Else
	oSection1:Cell("CONTA"	):Disable() 
EndIf

If lPulaPag
	oSection1:SetPageBreak(.T.)
EndIf

oSection1:SetLineCondition({|| IIF(cArqTmp->TIPOCONTA == "1",.F.,.T.) })

// Sessao 2
oSection2 := TRSection():New(oSection1,cSayCusto,{"cArqTmp","CTT"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)
oSection2:SetTotalInLine(.F.)
oSection2:SetColSpace(5)
oSection2:SetHeaderPage()

	TRCell():New(oSection2,"CUSTO"	,"cArqTmp",cSayCusto,/*Picture*/,aTamCC[1]+LEN(cMascara1)		,/*lPixel*/,bCdCUSTO)
	TRCell():New(oSection2,"CCRES"	,"cArqTmp",STR0027	,/*Picture*/,aTamCCRes[1]+LEN(cMascara1)	,/*lPixel*/,bCdCCRES)
	TRCell():New(oSection2,"DESCCC"	,"cArqTmp",STR0028	,/*Picture*/,nTamCC		,/*lPixel*/,/*{|| }*/)
	TRCell():New(oSection2,"SALDOANT","cArqTmp",STR0029 ,/*Picture*/,TAM_VALOR	,/*lPixel*/,{|| RZValorCtb(cArqTmp->SALDOANT,,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(lRedStorn .or. CTT->CTT_NORMAL == "0" .or. Empty(CTT->CTT_NORMAL) ,CT1->CT1_NORMAL,CTT->CTT_NORMAL),,,,,,lPrintZero,.F.)},"RIGHT",,"RIGHT")// Saldo Anterior
	TRCell():New(oSection2,"SALDODEB","cArqTmp",STR0030	,/*Picture*/,TAM_VALOR	,/*lPixel*/,{|| RZValorCtb(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,If(lRedStorn,CT1->CT1_NORMAL,CTT->CTT_NORMAL),,,,,,lPrintZero,.F.,lColDbCr)},"RIGHT",,"RIGHT")// Debito
	TRCell():New(oSection2,"SALDOCRD","cArqTmp",STR0031	,/*Picture*/,TAM_VALOR	,/*lPixel*/,{|| RZValorCtb(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,If(CTT->CTT_NORMAL == "0" .or. lRedStorn .or. Empty(CTT->CTT_NORMAL),CT1->CT1_NORMAL,CTT->CTT_NORMAL),,,,,,lPrintZero,.F.,lColDbCr)},"RIGHT",,"RIGHT")// Credito
																							  
	If lMov //Imprime Coluna Movimento!!
		TRCell():New(oSection2,"MOVIMENTO","cArqTmp",STR0032 ,/*Picture*/,TAM_VALOR	,/*lPixel*/,{|| RZValorCtb(cArqTmp->MOVIMENTO,,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(CTT->CTT_NORMAL == "0" .or. lRedStorn .or. Empty(CTT->CTT_NORMAL) ,CT1->CT1_NORMAL,CTT->CTT_NORMAL),,,,,,lPrintZero,.F.)},"RIGHT",,"RIGHT")// Movimento do Periodo
	EndIf

	TRCell():New(oSection2,"SALDOATU"	,"cArqTmp",STR0033 			,/*Picture*/,TAM_VALOR	,/*lPixel*/,{|| RZValorCtb(cArqTmp->SALDOATU ,,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(CTT->CTT_NORMAL == "0" .or. lRedStorn .or. Empty(CTT->CTT_NORMAL),CT1->CT1_NORMAL,CTT->CTT_NORMAL),,,,,,lPrintZero,.F.)},"RIGHT",,"RIGHT")// Saldo Atual
	TRCell():New(oSection2,"TIPOCC"		,"cArqTmp",STR0034 	+" "+cSayCusto	,/*Picture*/,01			,/*lPixel*/,/*{|| }*/)// Centro Custo / Sintetica           
 	TRCell():New(oSection2,"TIPOCONTA"	,"cArqTmp",STR0034	+" "+STR0025	,/*Picture*/,01			,/*lPixel*/,/*{|| }*/)// Conta Analitica / Sintetica           
 	TRCell():New(oSection2,"NIVEL1"		,"cArqTmp",STR0035 					,/*Picture*/,01			,/*lPixel*/,/*{|| }*/)// Logico para identificar se 

// oSection2:SetNoFilter({'CTT'})

	TRPosition():New( oSection2, "CTT", 1, {|| xFilial("CTT") + cArqTMP->CUSTO })
	
	oSection2:Cell("TIPOCC" 	):Disable()
	oSection2:Cell("TIPOCONTA"	):Disable()
	oSection2:Cell("NIVEL1"  	):Disable()
	
	If lCCNormal                                                                          
		oSection2:Cell("CCRES"	):Disable()
	Else
		oSection2:Cell("CUSTO"	):Disable() 
	EndIf
	
	oSection2:OnPrintLine( {|| ( IIf( lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCC == "1" .And. cTipoAnt == "2")), oReport:SkipLine(),NIL),;
									 cTipoAnt := cArqTmp->TIPOCC;
								)  })
	
	oSection2:SetLineCondition({|| f145Fil(cSegAte,cSegmento,nDigitAte,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,cMascara1) })

// Totais das sessoes	
	oBreak:= TRBreak():New(oSection2,{ || cArqTmp->CONTA },STR0020,.F.)
	
 	oBreak:OnBreak({ || nTotdbt := oTRF1:GetValue(),nTotcrt := oTRF2:GetValue() })   

 	oTRF1 := TRFunction():New(oSection2:Cell("SALDODEB"),nil,"SUM",oBreak,/*Titulo*/,/*cPicture*/,{ || f145Soma("D",cSegAte) },.F.,.F.,.F.,oSection2)
 	oTRF1:disable()
 	 		 TRFunction():New(oSection2:Cell("SALDODEB"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || RZValorCtb(nTotdbt,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection2)
			   																							 																				
	oTRF2 := TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"SUM",oBreak,/*Titulo*/,/*cPicture*/,{ || f145Soma("C",cSegAte) },.F.,.F.,.F.,oSection2)
	oTRF2:disable()
		 	 TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || RZValorCtb(nTotcrt,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.F.,.F.,oSection2)
																										 
  	If lMov
		If lRedStorn
			//TRFunction():New(oSection2:Cell("MOVIMENTO"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ( RedStorTt(nTotDbt,nTotCrt,,,"T"),;
			//ValorCTB(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture,CT1->CT1_NORMAL,,,,,,lPrintZero,.F.,lColDbCr)  )},.F.,.F.,.F.,oSection2)
			TRFunction():New(oSection2:Cell("MOVIMENTO"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ( (nTotMov := nTotCrt-nTotDbt),;
			RZValorCtb(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture,CT1->CT1_NORMAL,,,,,,lPrintZero,.F.,/*lColDbCr*/)  )},.F.,.F.,.F.,oSection2)
		Else
			TRFunction():New(oSection2:Cell("MOVIMENTO"),nil,"ONPRINT",oBreak,/*Titulo*/,/*cPicture*/,{ || ( (nTotMov := nTotCrt-nTotDbt),;
			RZValorCtb(nTotMov,,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(CTT->CTT_NORMAL == "0" .or. Empty(CTT->CTT_NORMAL),CT1->CT1_NORMAL,CTT->CTT_NORMAL),,,,,,lPrintZero,.F.))},.F.,.F.,.F.,oSection2)
		Endif	
	EndIf


// Total geral

	oTRF3 := TRFunction():New(oSection2:Cell("SALDODEB"),nil,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || f145Soma("D",cSegAte) },.F.,.F.,.F.,oSection2)
	oTRF3:disable()
			 TRFunction():New(oSection2:Cell("SALDODEB"),nil,"ONPRINT",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || RZValorCtb(oTRF3:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.T.,.F.,oSection2)
	oTRF4 := TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || f145Soma("C",cSegAte) },.F.,.F.,.F.,oSection2)
	oTRF4:disable()
			 TRFunction():New(oSection2:Cell("SALDOCRD"),nil,"ONPRINT",/*oBreak*/,/*Titulo*/,/*cPicture*/,{ || RZValorCtb(oTRF4:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.,lColDbCr) },.F.,.T.,.F.,oSection2)
	oSection1:SetLineCondition({|| ValidSec1() })
	oSection2:SetLineCondition({|| ValidSec2(cSegAte,cSegmento,nDigitAte,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,cMascara1) })
	
Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ReportPrint� Autor � Cicero J. Silva    � Data �  14/07/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros�                                                            ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,aSetOfBook,cDescMoeda,cSayCusto,nDivide)

Local oSection1 	:= oReport:Section(1)
Local oSection2		:= oReport:Section(1):Section(1)

Local cArqTmp		:= ""
Local cFiltro	:= oSection1:GetAdvplExp('CT1')

Local dDataLP		:= mv_par27
Local dDataFim		:= mv_par02
Local cMascCC		:= IIF (Empty(aSetOfBook[6]),"",aSetOfBook[6])//Mascara do Centro de Custo
Local cMascCta		:= IIF (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),aSetOfBook[2])//Mascara da Conta
Local lImpSint		:= Iif(mv_par07==1 .Or. mv_par07 ==3,.T.,.F.)
Local lVlrZerado	:= Iif(mv_par09==1,.T.,.F.)
Local lImpMov		:= Iif(mv_par18==1,.T.,.F.)
Local lPrintZero	:= Iif(mv_par22==1,.T.,.F.)
Local lImpAntLP		:= Iif(mv_par26==1,.T.,.F.)
Local lCompEnt		:= Iif(mv_par28==1,.T.,.F.)
Local cSegmento		:= mv_par14
Local nDigitAte		:= 0
Local nPos			:= 0
Local nDigitos		:= 0
                        
If lImpAntLP .AND. Empty(mv_par27)
	//Help(" ",1,"NODATALP",,"Parametro Data Lucros/Perdas n�o informado",1,0)
	Help(" ",1,"NODATALP",,,1,0)
	Return .F.
EndIf

	//��������������������������������������������������������������Ŀ
	//� Carrega titulo do relatorio: Analitico / Sintetico			 �
	//����������������������������������������������������������������
	IF mv_par07 == 1
		Titulo:=	STR0007 + Upper(cSayCusto)	//"BALANCETE ANALITICO DE CONTA / "
	ElseIf mv_par07 == 2
		Titulo:=	STR0006 + Upper(cSayCusto)	//"BALANCETE SINTETICO DE CONTA / "
	ElseIf mv_par07 == 3
		Titulo:=	STR0008 + Upper(cSayCusto)	//"BALANCETE DE CONTA / "
	EndIf

	Titulo += 	STR0009 + DTOC(mv_par01) + STR0010 + Dtoc(mv_par02) + STR0011 + cDescMoeda
	
	If mv_par12 > "1"
		Titulo += " (" + Tabela("SL", mv_par12, .F.) + ")"
	EndIf
	
	If nDivide > 1			
		Titulo += " (" + STR0022 + Alltrim(Str(nDivide)) + ")"
	EndIf	
	
	oReport:SetPageNumber(mv_par11) //mv_par14	-	Pagina Inicial
	oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport) } )

	//��������������������������������������������������������������Ŀ
	//� Monta Arquivo Temporario para Impressao						 �
	//����������������������������������������������������������������
	 MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
			 CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
			  mv_par01,mv_par02,"CT3","",mv_par03,mv_par04,mv_par05,mv_par06,,,,,mv_par10,;
			   mv_par12,aSetOfBook,mv_par14,mv_par15,mv_par16,mv_par17, !lImpMov,.T.,,"CT1",;
				lImpAntLP,dDataLP, nDivide,lVlrZerado,,,,,,,,,,,,,lImpMov,lImpSint,cFiltro,,,,,,,,,,,,aSelFil,,,,lCompEnt,,,,,lTodasFil)},;
				 (STR0014),;  //"Criando Arquivo Tempor�rio..."
				   STR0003+cSayCusto)    //"Balancete Verificacao Conta /"

	If !Empty(cSegmento)
		dbSelectArea("CTM")
		dbSetOrder(1)
		If MsSeek(xFilial()+cMascCC)  
			While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascCC
				nPos += Val(CTM->CTM_DIGITO)
				If CTM->CTM_SEGMEN == cSegmento
					nPos -= Val(CTM->CTM_DIGITO)
					nPos ++
					nDigitos := Val(CTM->CTM_DIGITO)      
					Exit
				EndIf	
				dbSkip()
			EndDo	
		EndIf	
	EndIf	

	//�������������������������������������������������������������������������������Ŀ
	//� Inicia a impressao do relatorio                                               �
	//���������������������������������������������������������������������������������
	dbSelectArea("cArqTmp")
	dbGotop()
	//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
	//nao esta disponivel e sai da rotina.
	If !( RecCount() == 0 .And. !Empty(aSetOfBook[5]) )
		
		oSection2:SetParentFilter( { |cParam| cArqTmp->CONTA == cParam },{ || cArqTmp->CONTA })// SERVE PARA IMPRIMIR O TITULO DA SECAO PAI

		oSection1:Print()
		
	EndIf
	
dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
//	Ferase(cArqTmp+GetDBExtension())
//	FErase("cArqInd"+OrdBagExt())
EndIf	
dbselectArea("CT2")


Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f145Soma  �Autor  �Cicero J. Silva     � Data �  24/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR145                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function f145Soma(cTipo,cSegAte)
Local nRetValor		:= 0
Local tpCCusto       := "" 
                 
If Empty(cArqTmp->TIPOCC)
	tpCCusto := cArqTmp->TIPOCONTA
Else
	tpCCusto := cArqTmp->TIPOCC
Endif

	If mv_par07 != 1					// Imprime Analiticas ou Ambas
	 	If tpCCusto == "2"		
			If cArqTmp->TIPOCONTA== "2" 
				If cTipo == "D"
					nRetValor := cArqTmp->SALDODEB
				ElseIf cTipo == "C"
					nRetValor := cArqTmp->SALDOCRD
				EndIf
			EndIf	
			If cTipo == "D"
				nRetValor := cArqTmp->SALDODEB
			ElseIf cTipo == "C"
				nRetValor := cArqTmp->SALDOCRD
			EndIf
		Endif
	Else
		If tpCCusto == "1" .And. cArqTmp->NIVEL1    		
			If cTipo == "D"
				nRetValor := cArqTmp->SALDODEB
			ElseIf cTipo == "C"
				nRetValor := cArqTmp->SALDOCRD
			EndIf
		Endif
		If tpCCusto == "1" .And. Empty(cArqTmp->CCSUP)
			If cTipo == "D"
				nRetValor := cArqTmp->SALDODEB
			ElseIf cTipo == "C"
				nRetValor := cArqTmp->SALDOCRD
			EndIf
		Endif
	Endif	
	
Return nRetValor                                                                         

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �f145Fil   �Autor  �Cicero J. Silva     � Data �  24/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � CTBR145                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function f145Fil(cSegAte,cSegmento,nDigitAte,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,cMascara1)

Local lDeixa	:= .T.

Default cMascara1 := ""

	If mv_par07 == 1					// So imprime Sinteticas
		If cArqTmp->TIPOCC == "2"
			lDeixa := .F.
		EndIf
	ElseIf mv_par07 == 2				// So imprime Analiticas
		If cArqTmp->TIPOCC == "1"
			lDeixa := .F.
		EndIf
	EndIf

	// Verifica Se existe filtragem Ate o Segmento
	If !Empty(cSegAte)
		nDigitAte := CtbRelDig( cSegAte, cMascara1 )
	EndIf		

	//Filtragem ate o Segmento do centro de custo(antigo nivel do SIGACON)		
	If !Empty(cSegAte)
		If Len(Alltrim(CUSTO)) > nDigitAte
			lDeixa := .F.
		Endif
	EndIf

dbSelectArea("cArqTmp")

Return (lDeixa)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �F145Help  � Autor �Felipe Cunha           � Data �18/12/2015���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Funcao ajusta Help			                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function F145Help()
Local aHlpPor := {}
Local aHlpIng := {}
Local aHlpEsp := {}

//Ajuste de Helps
aHlpPor := {}
aHlpIng := {}
aHlpEsp := {}
aHlpPor  := {"Parametro Data Lucros/Perdas" , " n�o informado"}
aHlpIng  := {"Parameter Date Profit/Loss"   , " not set"}
aHlpEsp  := {"Par�metro Fecha Profit/Loss"  , " no configurado"}
PutHelp("PNODATALP",aHlpPor,aHlpIng,aHlpEsp,.F.)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ValidSec1 � Autor �Daniel Fonseca Lira    � Data �18/05/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao de impressao de linha de sessao1                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T. - Imprime                                               ���
���          �.F. - Nao Imprime                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidSec1()
Local lRet := .T.

If cArqTmp->TIPOCONTA == "1" .And. MV_PAR19 == 2
	// conta eh sintetica e parametro fala p nao imprimir
	lRet := .F.
EndIf

Return lRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �ValidSec2 � Autor �Daniel Fonseca Lira    � Data �18/05/2017���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Validacao de impressao de linha de sessao2                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �.T. - Imprime                                               ���
���          �.F. - Nao Imprime                                           ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cSegAte    - parametro para a funcao f145Fil               ���
���          � cSegmento  - parametro para a funcao f145Fil               ���
���          � nDigitAte  - parametro para a funcao f145Fil               ���
���          � cSegIni    - parametro para a funcao f145Fil               ���
���          � cSegFim    - parametro para a funcao f145Fil               ���
���          � cFiltSegm  - parametro para a funcao f145Fil               ���
���          � nPos       - parametro para a funcao f145Fil               ���
���          � nDigitos   - parametro para a funcao f145Fil               ���
���          � cMascara1  - parametro para a funcao f145Fil               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ValidSec2(cSegAte,cSegmento,nDigitAte,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,cMascara1)
Local lRet := .T.

If !f145Fil(cSegAte,cSegmento,nDigitAte,cSegIni,cSegFim,cFiltSegm,nPos,nDigitos,cMascara1)
	lRet := .F.
EndIf

Return lRet
