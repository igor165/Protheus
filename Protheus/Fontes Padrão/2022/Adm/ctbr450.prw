#Include "CTBR450.Ch"
#Include "PROTHEUS.Ch"

//Tradu��o PTG 20080721

// 17/08/2009 -- Filial com mais de 2 caracteres


/*/                                 
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR450  � Autor � Simone Mie Sato       � Data � 03.05.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emiss�o do Raz�o aglutinado por conta.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBR450()                                                  ���
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
Function CTBR450()

Local aCtbMoeda	:= {}
Local WnRel			:= "CTBR450"

Local cDesc1		:= STR0001	//"Este programa ir�  imprimir o  Raz�o Contabil dos lancamentos"
Local cDesc2		:= STR0002	//"contab. aglutinados por contas de acordo com os parametros "
Local cDesc3		:= STR0003	//"configurados pelo usuario."
Local cString		:= "CT2"

Local titulo		:= STR0006 	//"Emissao do Razao Aglut. por contas"

Local lRet			:= .T.

Local nTamLinha	:= 220

Private aReturn	:= { STR0004, 1,STR0005, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private aLinha		:= {}

Private cPerg		:= "CTR450"

Private nomeprog	:= "CTBR450"
Private nLastKey	:= 0

Private Tamanho 		:= "M"

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If !Pergunte("CTR450", .T. )
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01            // da conta                              �
//� mv_par02            // ate a conta                           �
//� mv_par03            // da data                               �
//� mv_par04            // Ate a data                            �
//� mv_par05            // Moeda			                     �   
//� mv_par06            // Saldos		                         �   
//� mv_par07            // Set Of Books                          �
//� mv_par08            // Imprime conta sem movimento?          �
//� mv_par09            // Imprime Cod (Normal / Reduzida)       �
//� mv_par10            // Salto de pagina                       �
//� mv_par11            // Pagina Inicial                        �
//� mv_par12            // Pagina Final                          �
//� mv_par13            // Numero da Pag p/ Reiniciar            �	   
//� mv_par14            // Imprime Total Geral (Sim/Nao)         �
//� mv_par15            // So Livro/Livro e Termos/So Termos     �
//� mv_par16            // Imprime Valor 0.00						  �
//����������������������������������������������������������������

wnrel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"")

If nLastKey = 27
	dbClearFilter()
	Return
Endif

//��������������������������������������������������������������Ŀ
//� Verifica se usa Set Of Books -> Conf. da Mascara / Valores   �
//����������������������������������������������������������������
If !Ct040Valid(mv_par07)
	lRet := .F.
Else
	aSetOfBook := CTBSetOf(mv_par07)
EndIf

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par05)
   If Empty(aCtbMoeda[1])
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif	

If !lRet	
	dbClearFilter()
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey = 27
 	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| CTR450Imp(@lEnd,wnRel,cString,aSetOfBook,Titulo,nTamlinha,aCtbMoeda)})

Return 

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
��� Fun��o    �CTR450Imp � Autor � Simone Mie Sato       � Data � 03/05/05 ���
��������������������������������������������������������������������������Ĵ��
��� Descri��o � Impressao do Razao                                         ���
��������������������������������������������������������������������������Ĵ��
��� Sintaxe   �Ctr450Imp(lEnd,wnRel,cString,aSetOfBook,Titulo,nTamlinha,   ���
���           �          aCtbMoeda)                                        ���
��������������������������������������������������������������������������Ĵ��
��� Retorno   �Nenhum                                                      ���
��������������������������������������������������������������������������Ĵ��
��� Uso       � SIGACTB                                                    ���
��������������������������������������������������������������������������Ĵ��
���Parametros � lEnd       - A�ao do Codeblock                             ���
���           � wnRel      - Nome do Relatorio                             ���
���           � cString    - Mensagem                                      ���
���           � aSetOfBook - Array de configuracao set of book             ���
���           � Titulo     - Titulo do Relatorio                           ���
���           � nTamLinha  - Tamanho da linha a ser impressa               ��� 
���           � aCtbMoeda  - Moeda                                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function CTR450Imp(lEnd,WnRel,cString,aSetOfBook,Titulo,nTamlinha,aCtbMoeda)

//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local CbTxt
Local cbcont
Local Cabec1		:= ""
Local Cabec2		:= ""

Local aSaldo		:= {}
Local aSaldoAnt		:= {}
Local aColunas 

Local cDescMoeda
Local cMascara
Local cPicture
Local cSepara 		:= ""
Local cSaldo		:= mv_par06
Local cContaIni		:= mv_par01
Local cContaFIm		:= mv_par02
Local cContaAnt		:= ""
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cDescSint		:= ""
Local cMoeda		:= mv_par05
Local cContaSint	:= ""
Local cArqTmp

Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04        
Local dDataAnt		:= CTOD("  /  /  ")

Local lNoMov		:= Iif(mv_par08==1,.T.,.F.)
Local lSalto		:= Iif(mv_par10==1,.T.,.F.)
Local lImpLivro	:= .T.
Local lImpTermos	:= .F.								
Local lPrintZero	:=	Iif(mv_par16 == 1,.T.,.F.)

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nReinicia 	:= mv_par13 
Local nPagFim		:= mv_par12
Local nTamConta		:= Len(CriaVar("CT1_CONTA"))

Local nPagIni		:= mv_par11
Local nBloco		:= 0
Local nBlCount		:= 0
Local nCont			:= 0
Local LIMITE		:= 132
Local nInutLin		:= 1 
m_pag    := 1
CtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

//��������������������������������������������������������������Ŀ
//� Impressao de Termo / Livro                                   �
//����������������������������������������������������������������
Do Case
	Case mv_par15==1 ; lImpLivro:=.t. ; lImpTermos:=.f.
	Case mv_par15==2 ; lImpLivro:=.t. ; lImpTermos:=.t.
	Case mv_par15==3 ; lImpLivro:=.f. ; lImpTermos:=.t.
EndCase		

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara	:= RetMasCtb(aSetOfBook[2],@cSepara)
EndIf               

cPicture 	:= aSetOfBook[4]

//��������������������������������������������������������������������������Ŀ
//�Titulo do Relatorio                                                       �
//����������������������������������������������������������������������������
If Type("NewHead")== "U"
	Titulo	:=	STR0007	//"RAZAO EM "
	Titulo += 	cDescMoeda + STR0008 + DTOC(dDataIni) +;	// "DE"
				STR0009 + DTOC(dDataFim) + CtbTitSaldo(mv_par06)	// "ATE"
Else
	Titulo := NewHead
EndIf

//��������������������������������������������������������������������������Ŀ
//�Cabe�alho                                                                 �
//���������������������������������������������������������������������������� 
// DATA               
// LOTE/SUB/DOC/LINHA     H I S T O R I C O                          DEBITO                    CREDITO                    SALDO ATUAL
// XXXX/XXX/XXXXXX        XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX     99999999999999.99         99999999999999.99          99999999999999.99D"
// 01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
//           1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22

#DEFINE 	COL_NUMERO 			1
#DEFINE 	COL_HISTORICO		2
#DEFINE 	COL_VLR_DEBITO		3
#DEFINE 	COL_VLR_CREDITO		4
#DEFINE 	COL_VLR_SALDO  		5
#DEFINE 	TAMANHO_TM       	6
#DEFINE 	COL_VLR_TRANSPORTE  7

aColunas   := { 000, 023, 064, 086, 108, 021, 176 }

Cabec1 	:= STR0015				// "DATA"
Cabec2	:= STR0010				// "LOTE/SUB/DOC/LINHA     H I S T O R I C O                          DEBITO                    CREDITO                    SALDO ATUAL"
m_pag := mv_par11

If lImpLivro
	//��������������������������������������������������������������Ŀ
	//� Monta Arquivo Temporario para Impressao   					 �
	//����������������������������������������������������������������
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
				CTBR420Raz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,;
				cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,"7")},;
				STR0014,;		// "Criando Arquivo Tempor�rio..."
				STR0006)		// "Emissao do Razao"

	dbSelectArea("cArqTmp")
	SetRegua(RecCount())
	dbGoTop()
Endif

//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial 
//nao esta disponivel e sai da rotina.
If RecCount() == 0 .And. !Empty(aSetOfBook[5])                                       
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())	
	Return
Endif

While lImpLivro .And. !Eof()

	IF lEnd
		@Prow()+1,0 PSAY STR0011  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF                                         

	IncRegua()                                    	

	aSaldoAnt 	:= SaldoCT7(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400")
	aSaldo 		:= SaldoCT7(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo)
	
	If !lNoMov //Se nao imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			dbSelectArea("cArqTmp")
			dbSkip()
			Loop
		Endif	
	Endif             

	If li > 56 .Or. lSalto              
		CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
		CtCGCCabec(.T.,.T.,.T.,Cabec1,Cabec2,dDataFim,Titulo,.F.,"1",Tamanho)
	EndIf

	nSaldoAtu:= 0
	nTotDeb	:= 0
	nTotCrd	:= 0
                              
	// IMPRIME A CONTA	
	
	// Conta Sintetica	
	cContaSint := Ctr400Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes)
	EntidadeCTB(cContaSint,li,001,nTamConta,.F.,cMascara,cSepara) 
	@li,pcol() + 5 PSAY " - " + cDescSint
	li+=2
	
	// Conta Analitica
	@li,011 PSAY STR0012 	//"CONTA - "	

	If mv_par09 == 1							// Imprime Cod Normal
		EntidadeCTB(cArqTmp->CONTA,li,20,nTamConta,.F.,cMascara,cSepara)
	Else
		EntidadeCTB(cCodRes,li,20,nTamConta,.F.,cMascara,cSepara)
	EndIf
	@ li, (22 + nTamConta) PSAY "- " + cDescConta
	
	// Impressao do Saldo Anterior da Conta
	ValorCTB(aSaldoAnt[6],li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
							         .T.,cPicture, , , , , , ,lPrintZero)
		
	nSaldoAtu := aSaldoAnt[6]                                           
	li += 2         
	dbSelectArea("cArqTmp")
	cContaAnt:= cArqTmp->CONTA
	dDataAnt	:= CTOD("  /  /  ")
	While !Eof() .And. cArqTmp->CONTA == cContaAnt


		If li > 56
			li++
			
			@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0017) - 1;
						 PSAY STR0017	//"A TRANSPORTAR : "
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
								   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture, , , , , , ,lPrintZero)
			
			CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
			CtCGCCabec(.T.,.T.,.T.,Cabec1,Cabec2,dDataFim,Titulo,.F.,"1")
			
			@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0018) - 1;
						 PSAY STR0018	//"A TRANSPORTAR : "
			ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
								   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture, , , , , , ,lPrintZero)
			li++
		EndIf
	
		// Imprime os lancamentos para a conta                          		
		If dDataAnt != cArqTmp->DATAL  .And. (cArqTmp->LANCDEB <> 0 .Or. cArqTmp->LANCCRD <> 0) 
			@li,000 PSAY cArqTmp->DATAL
			dDataAnt := cArqTmp->DATAL	
			li++
		EndIf	
		
		@li,aColunas[COL_NUMERO] PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+;
									   cArqTmp->DOC+cArqTmp->LINHA
									   
		@li,aColunas[COL_HISTORICO] PSAY Subs(cArqTmp->HISTORICO,1,40)
		
		
		ValorCTB(cArqTmp->LANCDEB,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],;
				 nDecimais,.F.,cPicture, , , , , , ,lPrintZero)
		ValorCTB(cArqTmp->LANCCRD,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],;
				 nDecimais,.F.,cPicture, , , , , , ,lPrintZero)
		nSaldoAtu	:= nSaldoAtu - cArqTmp->LANCDEB+cArqTmp->LANCCRD
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],;
				 nDecimais,.T.,cPicture, , , , , , ,lPrintZero)
		nTotDeb		+= cArqTmp->LANCDEB
		nTotCrd		+= cArqTmp->LANCCRD
		nTotGerDeb	+= cArqTmp->LANCDEB
		nTotGerCrd	+= cArqTmp->LANCCRD			                                                    
		
		// Procura pelo complemento de historico
		dbSelectArea("CT2")
		dbSetOrder(10)
		If dbSeek(xFilial("CT2")+cArqTMP->(DTOS(DATAL)+LOTE+SUBLOTE+DOC+SEQLAN+EMPORI+FILORI),.F.)
			dbSkip()
			If CT2->CT2_DC == "4"
				While !Eof() .And. CT2->CT2_FILIAL == xFilial() 			.And.;
									CT2->CT2_LOTE == cArqTMP->LOTE 		.And.;
									CT2->CT2_SBLOTE == cArqTMP->SUBLOTE 	.And.;
									CT2->CT2_DOC == cArqTmp->DOC 			.And.;
									CT2->CT2_SEQLAN == cArqTmp->SEQLAN 	.And.;
									CT2->CT2_EMPORI == cArqTmp->EMPORI	.And.;
									CT2->CT2_FILORI == cArqTmp->FILORI	.And.;
									CT2->CT2_DC == "4" 					.And.;
								   DTOS(CT2->CT2_DATA) == DTOS(cArqTmp->DATAL)                        
					li++
					@li,aColunas[COL_NUMERO] 	 PSAY Space(15)+CT2->CT2_LINHA
					@li,aColunas[COL_HISTORICO] PSAY Subs(CT2->CT2_HIST,1,40)
					dbSkip()
				EndDo	
			EndIf	
		EndIf	

		dbSelectArea("cArqTmp")
		dbSkip()
		li++
	EndDo

    li+=2
	If li > 56
		li++
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0017) - 1;
					 PSAY STR0017	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
							   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture, , , , , , ,lPrintZero)
		
		CtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.F. TRATA A QUEBRA/REINICIO
		CtCGCCabec(.T.,.T.,.T.,Cabec1,Cabec2,dDataFim,Titulo,.F.,"1",Tamanho)
		
		@li,aColunas[COL_VLR_TRANSPORTE] - Len(STR0018) - 1;
				 PSAY STR0018	//"A TRANSPORTAR : "
		ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],;
							   aColunas[TAMANHO_TM],nDecimais, .T.,cPicture, , , , , , ,lPrintZero)
		li++
    EndIf
    
	@li,000 PSAY STR0016  //"T o t a i s  d a  C o n t a  ==> " 	    

	ValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture, , , , , , ,lPrintZero)
	ValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,;
			 .F.,cPicture, , , , , , ,lPrintZero)
	ValorCTB(nSaldoAtu,li,aColunas[COL_VLR_SALDO],aColunas[TAMANHO_TM],nDecimais,;
			 .T.,cPicture, , , , , , ,lPrintZero)
    
	li++
	@li, 00 PSAY Replicate("-",nTamLinha)
	li++

EndDo	 
          
If  li != 80 .And. lImpLivro .And. mv_par14 == 1	//Imprime total Geral
    @li, 000 PSAY STR0019  //"T O T A L  G E R A L  ==> " 	        
	ValorCTB(nTotGerDeb,li,aColunas[COL_VLR_DEBITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture, , , , , , ,lPrintZero)
	ValorCTB(nTotGerCrd,li,aColunas[COL_VLR_CREDITO],aColunas[TAMANHO_TM],nDecimais,.F.,cPicture, , , , , , ,lPrintZero)
	li++
	@li, 00 PSAY Replicate("-",nTamLinha)
	li+=2
Endif

nLinAst := GetNewPar("MV_INUTLIN",0)
If li < 56 .and. nLinAst <> 0 .and. !lEnd
	For nInutLin := 1 to nLinAst
		li++
		@li,00 PSAY REPLICATE("*",LIMITE)	
		If li == 56
			Exit
		EndIf
	Next
EndIf

If li <= 56 .and. !lEnd .and. !lImpTermos
	Roda(cbCont,cbTxt,Tamanho)
EndIf

If lImpTermos 							// Impressao dos Termos

	cArqAbert:=GetNewPar("MV_LRAZABE","")
	cArqEncer:=GetNewPar("MV_LRAZENC","")
	
    If Empty(cArqAbert)
		ApMsgAlert(	"Devem ser criados os parametros MV_LRAZABE e MV_LRAZENC. " +;
					"Utilize como base o parametro MV_LDIARAB.")
	Endif
Endif

If lImpTermos .And. ! Empty(cArqAbert)	// Impressao dos Termos

	dbSelectArea("SM0")
	aVariaveis:={}

	For nCont:=1 to FCount()	
		If FieldName(nCont)=="M0_CGC"
			AADD(aVariaveis,{FieldName(nCont),Transform(FieldGet(nCont),"@R 99.999.999/9999-99")})
		Else
            If FieldName(nCont)=="M0_NOME"
                Loop
            EndIf
			AADD(aVariaveis,{FieldName(nCont),FieldGet(nCont)})
		Endif
	Next

	dbSelectArea("SX1")
	dbSeek("CTR400"+"01")

	While SX1->X1_GRUPO=="CTR400"
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
		ImpTerm(cArqAbert,aVariaveis,AvalImp(132))
	Endif

	If cArqEncer#NIL
		ImpTerm(cArqEncer,aVariaveis,AvalImp(132))
	Endif	 
Endif

If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End

If lImpLivro
	dbSelectArea("cArqTmp")
	dbClearFilter()
	dbCloseArea()
	If Select("cArqTmp") == 0
       FErase(cArqTmp+GetDBExtension())
       FErase(cArqTmp+OrdBagExt())
	EndIf	
Endif

dbselectArea("CT2")

MS_FLUSH()

Return

