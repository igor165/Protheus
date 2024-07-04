#INCLUDE "ctba340.ch"
#Include "PROTHEUS.Ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CTBA340  � Autor � Simone Mie Sato       � Data � 13.03.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Translation Effect                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CTBA340()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function CTBA340()

Local nOpca := 0
Local aSays := {}, aButtons := {}

Private cCadastro := STR0001 //"Calculo da Variacao Monetaria"

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01 // Da Data                                          �
//� mv_par02 // Ate a Data    			                         �
//� mv_par03 // Data do Lancamento			                     �
//� mv_par04 // Da Conta           		                         �
//� mv_par05 // Ate a Conta                                      �
//� mv_par06 // Moeda Origem  			                         �
//� mv_par07 // Moeda Destino 			                         �
//� mv_par08 // Tipo de Saldo 				                     �
//� mv_par09 // Data Saldo Anterior		   						 �
//� mv_par10 // Numero do Lote                          		 �
//� mv_par11 // Numero do Sublote                                �
//� mv_par12 // Numero do Documento  		                     �
//� mv_par13 // Codigo do Hist. Padrao		                     �
//����������������������������������������������������������������
Pergunte("CTB340",.T.)

AADD(aSays, STR0002) //"O programa objetiva gerar os lancamentos contabeis de Translation Effect."
AADD(aSays, STR0003) //"Atende os princ�pios cont�beis US GAAP e IAS)

//��������������������������������������������������������������Ŀ
//� Inicializa o log de processamento                            �
//����������������������������������������������������������������
ProcLogIni( aButtons )

AADD(aButtons, { 5,.T., 	{|| (Pergunte("CTB340",.T. ),.T.) } } )
AADD(aButtons, { 1,.T., 	{|| nOpca:= 1, If( ConaOk(),FechaBatch(), nOpca:=0 ) }} )
AADD(aButtons, { 2,.T., 	{|| FechaBatch() }} )

FormBatch( cCadastro, aSays, aButtons ,, 250 , 600 )
	
If nOpca == 1
	//�����������������������������������Ŀ
	//� Atualiza o log de processamento   �
	//�������������������������������������
	ProcLogAtu("INICIO")

	If !CTBSerialI("CTBPROC","OFF")
		Return
	Endif
	Processa({|lEnd| Ct340Proc()})

	CTBSerialF("CTBPROC","OFF")
	//�����������������������������������Ŀ
	//� Atualiza o log de processamento   �
	//�������������������������������������
	ProcLogAtu("FIM")


EndIf
	
Return
	
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Ct340Proc � Autor � Simone Mie Sato       � Data � 13.03.03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calculo para obtencao do valor a ser gerado no lancamento. ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ca340Proc()                                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBA340                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ct340Proc()

Local dDataIni		:= mv_par01
Local dDataFim		:= mv_par02
Local dDataLanc		:= mv_par03
Local cContaIni		:= mv_par04
Local cContaFim		:= mv_par05
Local cMoedConv		:= mv_par07	//Taxa a ser considerada 
Local cTpSaldo		:= mv_par08
Local dDtSldAnt		:= mv_par09
Local cLote			:= mv_par10
Local cSubLote		:= mv_par11
Local cDoc			:= mv_par12
Local cCodHP  		:= mv_par13	

Local aSaldoAnt		:= {} 
Local aSaldoAtu		:= {}           
 
Local nValor		:= 0
Local CTF_LOCK		:= 0
Local nRecCT1		:= 0
Local nRecTotal		:= CT1->(Reccount())
Local nVlrMensal	:= 0

Local lFirst 		:= .T.
Local lPergOk		:= .T.

Local cCtaTrnsEf	:= ""
Local cLinha 		:= "001"
Local cSeqLan  		:= "000"                             
Local cDc			:= ""
Local cHistorico	:= ""
Local cCritConv		:= ""
Local cNumManLin 	:= CtbSoma1Li()		//Conteudo do parametro MV_NUMMAN convertido.

//��������������������������������������������������������������Ŀ
//� ANTES DE INICIAR O PROCESSAMENTO, VERIFICO OS PARAMETROS.	 �
//����������������������������������������������������������������

//Verificar se o calendario da data solicitada esta encerrado
lPergOk	:= CtbValiDt(1,dDataLanc,,cTpSaldo)

If Empty(cCodHP)	
	Help(" ",1,"CTHPVAZIO")

	//���������������������������������������������Ŀ
	//� Atualiza o log de processamento com o erro  �
	//�����������������������������������������������
	ProcLogAtu("ERRO","CTHPVAZIO",Ap5GetHelp("CTHPVAZIO"))

	lPergOk := .F.
Else
	dbSelectArea("CT8")
	dbSetOrder(1)
	If MsSeek(xFilial()+cCodHP)
		cHistorico	:= Subs(CT8->CT8_DESC,1,40)
	Else            
		//Historico Padrao nao existe no cadastro.
		Help(" ",1,"CT210NOHP")

		//���������������������������������������������Ŀ
		//� Atualiza o log de processamento com o erro  �
		//�����������������������������������������������
		ProcLogAtu("ERRO","CT210NOHP",Ap5GetHelp("CT210NOHP"))
	
		lPergOk := .F.
	Endif
Endif                             

//Lote nao preenchido.
If Empty(cLote)
	Help(" ",1,"NOCT210LOT")

	//���������������������������������������������Ŀ
	//� Atualiza o log de processamento com o erro  �
	//�����������������������������������������������
	ProcLogAtu("ERRO","NOCT210LOT",Ap5GetHelp("NOCT210LOT"))

	lPergOk := .F.
Endif
	
//Sub Lote nao preenchido.
If Empty(cSubLote)
	Help(" ",1,"NOCTSUBLOT")

	//���������������������������������������������Ŀ
	//� Atualiza o log de processamento com o erro  �
	//�����������������������������������������������
	ProcLogAtu("ERRO","NOCTSUBLOT",Ap5GetHelp("NOCTSUBLOT"))

	lPergOk := .F.
Endif
	
//Documento nao preenchido.
If Empty(cDoc)
	Help(" ",1,"NOCT210DOC")

	//���������������������������������������������Ŀ
	//� Atualiza o log de processamento com o erro  �
	//�����������������������������������������������
	ProcLogAtu("ERRO","NOCT210DOC",Ap5GetHelp("NOCT210DOC"))

	lPergOk := .F.
Else	//Se o documento estiver preenchido, verifico se existe lancamento com mesmo numero
		//de lote, sublote, documento e data
	dbSelectArea("CT2")
	dbSetOrder(1)
	If MsSeek(xFilial()+dtos(dDataLanc)+cLote+cSubLote+cDoc)	
		lPergOk := .F.		

		MsgAlert(STR0008)//Data+Lote+Sublote+documento ja existe. 		

		//���������������������������������������������Ŀ
		//� Atualiza o log de processamento com o erro  �
		//�����������������������������������������������
		ProcLogAtu("ERRO",STR0008,STR0008)

    Endif
Endif                             

//Conta Inicial e Conta Final nao preenchidos. 	
If Empty(cContaIni) .And. Empty(cContaFim)
	Help(" ",1,"NOCT210CT")

	//���������������������������������������������Ŀ
	//� Atualiza o log de processamento com o erro  �
	//�����������������������������������������������
	ProcLogAtu("ERRO","NOCT210CT",Ap5GetHelp("NOCT210CT"))

	lPergOk := .F.
Endif                                          

//Tipo de saldo nao preenchido
If Empty(cTpSaldo)
	Help(" ",1,"NO210TPSLD")

	//���������������������������������������������Ŀ
	//� Atualiza o log de processamento com o erro  �
	//�����������������������������������������������
	ProcLogAtu("ERRO","NO210TPSLD",Ap5GetHelp("NO210TPSLD"))

	lPergOk := .F.
Endif	                                       

//Moeda de Conversao nao podera ser a 01 (nao existe criterio de conversao).
If cMoedConv == '01'

	MsgAlert(STR0004)//Moeda de Conversao nao podera ser 01

	//���������������������������������������������Ŀ
	//� Atualiza o log de processamento com o erro  �
	//�����������������������������������������������
	ProcLogAtu("ERRO",STR0004,STR0004)


	lPergOk	:= .F.  	
Endif
	

//SE OS PARAMETROS NAO ESTIVEREM DEVIDAMENTE PREENCHIDOS               
If !lPergOk	
	Return
Endif		

dbSelectArea("CT1")
dbSetOrder(1)                              
MsSeek(xFilial()+cContaIni,.T.)

ProcRegua(nRecTotal)

While !Eof() .And. CT1->CT1_CONTA <= cContaFim

	//Se a conta de Translation Effect nao estiver preenchida  pula para a proxima conta.	            		
	If Empty(CT1->CT1_TRNSEF) 
		dbSkip()
		Loop
	EndIf
	
	IncProc()
	
	cCtaTrnsEf	:= CT1->CT1_TRNSEF	                                        
	cCritConv	:= &("CT1->CT1_CVD"+cMoedConv)
	
	//Digito de Controle da Conta de Translation
	nRecCT1	:= Recno()
	If MsSeek(xFilial()+cCtaTrnsEf)
		cDc	:= CT1->CT1_DC
	EndIf
	dbGoto(nRecCT1)
	
	aSaldoAnt := SaldoCT7(CT1->CT1_CONTA,dDataIni,cMoedConv,cTpSaldo,'CTBA340')
	aSaldoAtu := SaldoCT7(CT1->CT1_CONTA,dDataFim,cMoedConv,cTpSaldo,'CTBA340')
		
	nValor := Ctb340Conv(cCritConv,dDataIni,dDataFim,dDtSldAnt,cMoedConv,aSaldoAnt,aSaldoAtu,cTpSaldo,@nVlrMensal)              
	
	//Gravar o lan�amento contabil	
	BEGIN TRANSACTION
		If lFirst .Or. cLinha > cNumManLin
			Do While !ProxDoc(dDataLanc,cLote,cSubLote,@cDoc,@CTF_LOCK)
				//������������������������������������������������������Ŀ
				//� Caso o N� do Doc estourou, incrementa o lote         �
				//��������������������������������������������������������
				cLote := CtbInc_Lot(cLote, cModulo)

			Enddo
			lFirst := .F.
			cLinha 		:= "001"
			cSeqLan  	:= "000"                             			
		Endif
		
		cSeqLan := Soma1(cSeqLan)
		
		If nValor < 0             						
			//Grava lancamento na moeda 01 com valor 0.00
			Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"2",'01',cCodHP,cHistorico,CT1->CT1_CONTA,;
					cCtaTrnsEf,0,cTpSaldo,cSeqLan,CT1->CT1_DC,cDC,cCritConv)		
					
			//Grava lancamento na moeda de conversao 			
			Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"2",cMoedConv,cCodHP,cHistorico,CT1->CT1_CONTA,;
					cCtaTrnsEf,nValor,cTpSaldo,cSeqLan,CT1->CT1_DC,cDC,cCritConv)		
		ElseIf nValor > 0                               
			//Grava lancamento na moeda 01 com valor 0.00		
			Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"1",'01',cCodHP,cHistorico,cCtaTrnsEf,;
					CT1->CT1_CONTA,0,cTpSaldo,cSeqLan,cDC,CT1->CT1_DC,cCritConv)

			//Grava lancamento na moeda de conversao 								
			Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"1",cMoedConv,cCodHP,cHistorico,cCtaTrnsEf,;
					CT1->CT1_CONTA,nValor,cTpSaldo,cSeqLan,cDC,CT1->CT1_DC,cCritConv)
					
		EndIf
		If nValor <> 0
			cSeqLan := CT2->CT2_SEQLAN // Sequencia dp lancamento
//			cLinha 	:= StrZero(Val(cLinha) + 1, 3)
			cLinha	:= Soma1(cLinha)
		EndIf
		
		//A variavel nVlrMensal sera diferente de zero, se for criterio de convers�o mensal.
		If nVlrMensal <> 0 
			If nVlrMensal < 0			                        
				//Grava lancamento na moeda 01 com valor 0.00					
				Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"2",'01',cCodHP,cHistorico,"",CT1->CT1_CONTA,;
						0,cTpSaldo,cSeqLan,"",CT1->CT1_DC,cCritConv)

				//Grava lancamento na moeda de conversao 											
				Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"2",cMoedConv,cCodHP,cHistorico,"",CT1->CT1_CONTA,;
						nVlrMensal,cTpSaldo,cSeqLan,"",CT1->CT1_DC,cCritConv)
			EndIf
			If nVlrMensal > 0                                                   
				//Grava lancamento na moeda 01 com valor 0.00								                                     
				Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"1",'01',cCodHP,cHistorico,CT1->CT1_CONTA,"",;
					0,cTpSaldo,cSeqLan,CT1->CT1_DC,"",cCritConv)					

				//Grava lancamento na moeda de conversao 														
				Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,@cLinha,"1",cMoedConv,cCodHP,cHistorico,CT1->CT1_CONTA,"",;
					nVlrMensal,cTpSaldo,cSeqLan,CT1->CT1_DC,"",cCritConv)					
			EndIf
			cSeqLan := CT2->CT2_SEQLAN // Sequencia dp lancamento
//			cLinha 	:= StrZero(Val(cLinha) + 1, 3)		
			cLinha	:= Soma1(cLinha)
			nVlrMensal	:= 0
		EndIf
		
	END TRANSACTION      
	
	
	dbSelectArea("CT1")
	dbSkip()
End
   
If CTF_LOCK > 0					/// LIBERA O REGISTRO NO CTF COM A NUMERCAO DO DOC FINAL
	dbSelectArea("CTF")
	dbGoTo(CTF_LOCK)
	CtbDestrava(dDataLanc,cLote,cSubLote,cDoc,@CTF_LOCK)			
Endif
	
Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Ctb340Conv� Autor � Simone Mie Sato       � Data � 13/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valor calculado.           								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctb340Conv(cCritConv)									  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ctb340Conv(cCritConv,dDataIni,dDataFim,dDtSldAnt,cMoedConv,;
				aSaldoAnt,aSaldoAtu,cTpSaldo,nVlrMensal)              
	
Local aSaveArea		:= GetArea()                           
Local nSaldoAntD    := 0
Local nSaldoAntC	:= 0
Local nSldAnt		:= 0
Local nSaldoAtuD	:= 0
Local nSaldoAtuC	:= 0
Local nSldAtu		:= 0
Local nSaldoDeb		:= 0
Local nSaldoCrd		:= 0             
Local nMovimento	:= 0
Local nValor		:= 0	
Local nSlAntConv	:= 0
Local aSlAntConv	:= {}
Local nVlrConv		:= 0
	
nSaldoAntD 	:= aSaldoAnt[7]
nSaldoAntC 	:= aSaldoAnt[8]	
nSldAnt		:= nSaldoAntC - nSaldoAntD		

nSaldoAtuD 	:= aSaldoAtu[4]
nSaldoAtuC 	:= aSaldoAtu[5] 
nSldAtu		:= nSaldoAtuC - nSaldoAtuD
	
nSaldoDeb	:= nSaldoAtuD - nSaldoAntD
nSaldoCrd	:= nSaldoAtuC - nSaldoAntC
nMovimento	:= nSaldoCrd-nSaldoDeb
	
IF cCritConv != "A"
	
	If cCritConv $ "1/2/6/7"			//Criterio de Conversao = Diaria/Media
		nValor	:= nMovimento
	ElseIf cCritConv == "3"			//Criterio de Conversao = Mensal
		// Calculo do saldo anterior(Saldo na data de Conversao => mes anterior) dividido pela taxa do mes atual (data final)
		aSlAntConv 	:= SaldoCT7(CT1->CT1_CONTA,dDtSldAnt,'01',cTpSaldo,'CTBA340')
		//	nSlAntConv	:= aSlAntConv[8]-aSlAntConv[7]
		nSlAntConv	:= aSlAntConv[5]-aSlAntConv[4]
		nVlrConv	:= CtbConv(cCritConv,dDataFim,cMoedConv,nSlAntConv)	//Converte valor para taxa Media
		
		nValor		:= nMovimento - nSldAnt + nVlrConv
		
		nVlrMensal	:= nMovimento - nValor
	Endif
EndIf

RestArea(aSaveArea)	
Return(nValor) 
	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �Ctb340Grv � Autor � Simone Mie Sato       � Data � 13/03/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Gravar o lancamento de Translation						  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � Ctb340Grv()         										  ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Ctb340Grv(dDataLanc,cLote,cSubLote,cDoc,cLinha,cTipo,cMoeda,cHistPad,cHistorico,;
				cDebito,cCredito,nValor,cTpSaldo,cSeqLan,cDCD,cDCC,cCritConv)              

Local aSaveArea	:= GetArea()

aTravas := {}

IF !Empty(cDebito)
   AADD(aTravas,cDebito)
Endif
IF !Empty(cCredito)
   AADD(aTravas,cCredito)
Endif

/// VERIFICA SE O SEMAFORO DE CONTAS PERMITE GRAVA��O DOS LAN�AMENTOS/SALDOS
If CtbCanGrv(aTravas,.T.)
	                            
	dbSelectArea("CT2")
	dbSetOrder(1)
	RecLock("CT2",.T.)
	CT2->CT2_FILIAL			:= xFilial()
	CT2->CT2_DATA			:= dDataLanc
	CT2->CT2_LOTE			:= cLote
	CT2->CT2_SBLOTE			:= cSubLote
	CT2->CT2_DOC			:= cDoc
	CT2->CT2_LINHA			:= cLinha
	CT2->CT2_FILORI			:= cFilAnt
	CT2->CT2_EMPORI			:= Substr( cNumEmp, 1, 2 )
	CT2->CT2_DC				:= cTipo
	CT2->CT2_DEBITO			:= cDebito
	CT2->CT2_CREDIT			:= cCredito
	CT2->CT2_MOEDLC			:= cMoeda
	CT2->CT2_VALOR			:= Abs(nValor)
	CT2->CT2_HP				:= cHistPad
	CT2->CT2_HIST			:= cHistorico
	CT2->CT2_SEQHIST		:= "001"
	CT2->CT2_TPSALD			:= cTpSaldo
	CT2->CT2_SEQLAN			:= cLinha
	CT2->CT2_ROTINA			:= "CTBA340"		// Indica qual o programa gerador
	CT2->CT2_MANUAL			:= "1"				// Lancamento manual
	CT2->CT2_AGLUT			:= "2"				// Nao aglutina
	CT2->CT2_DCD			:= cDCD
	CT2->CT2_DCC			:= cDCC             
	CT2->CT2_CRCONV			:= "4"//Adotado criterio de conversao = 4 porque o valor na moeda 01 eh zero
	CT2->CT2_SLBASE			:= "S"
	MsUnlock()
	
	cLinha	:= CT2->CT2_LINHA
	
	//Grava os saldos
	If nValor	<> 	0
		CtbGravSaldo(CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,;
					CT2->CT2_DATA,cTipo,cMoeda,;
					CT2->CT2_DEBITO,CT2->CT2_CREDIT,,,,,,,Abs(nValor),;
					CT2->CT2_TPSALD,3,"","","","","","","","",0," ",;
					" ", "  ", .F.,.F.,.F., 0.00,,,,,,,,,,,,,"+"/*cOperacao*/,;
					,,cHistorico)
	EndIf
EndIf
			
RestArea(aSaveArea)

Return
