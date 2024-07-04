#INCLUDE "Mata901.ch"
#include "FiveWin.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA901  � Autor � Lucas				     � Data � 15/08/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Acertos de Livros Fiscais para os paises CHI,  ���
���          � PAR,ARG,URU...															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                   ���
�������������������������������������������������������������������������Ĵ��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA901()
LOCAL	aInd := {}
LOCAL	cIndexSF3 := ""
LOCAL nIndexSF3 := 1
LOCAL cKeySF3   := ""
LOCAL cCondicao := ""
LOCAL cCFO := ""

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
PRIVATE aRotina := { { STR0001, "AxPesqui"  , 0 , 1},; //"Pesquisar"
  	                  { STR0002,"AxVisual"  , 0 , 2},; //"Visualizar"
     	               { STR0003,  "A901Acer"  , 0 , 3} } //"Procesar"

If Pergunte("MTA901",.T.)

	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSeek( xFilial("SF4")+AllTrim(mv_par05) )
		
	If !Found()        
		MsgStop( STR0004) //"TES Invalido!"
		Return(.F.)
	Else
		If Empty(SF4->F4_CF)
			MsgStop( STR0004) //"TES Invalido!"
			Return(.F.)
		EndIf
	EndIf	

	cCFO := SF4->F4_CF
		
	//��������������������������������������������������������������Ŀ
	//� Cria Indice Condicional de SF1 para processar entradas.	 	  �
	//����������������������������������������������������������������
	aInd := {}
	cIndexSF3 := CriaTrab(Nil,.F.)
	AADD(aInd,cIndexSF3)
	dbSelectArea("SF3")
	cKeySF3   := "F3_FILIAL+DTOS(F3_ENTRADA)"
		
	If mv_par03 == 1 //Entradas
		cCondicao := 'F3_TIPOMOV=="C".and.F3_CFO=="'+cCFO+'"'
	Else
		cCondicao := 'F3_TIPOMOV=="V".and.F3_CFO=="'+cCFO+'"'
	EndIf
			
	IndRegua("SF3",cIndexSF3,cKeySF3,,cCondicao,STR0005) //"Seleccionando Registros..."
	
	nIndexSF3 := RetIndex("SF3")
	dbSelectArea("SF3")
	
	#IFNDEF TOP
		dbSetIndex(cIndexSF3+OrdBagExt())
		dbSetOrder(nIndexSF3+1)
		dbGoTop()
	#ENDIF
	
	//���������������������������������������������Ŀ
	//� Define o cabecalho da tela de atualizacoes  �
	//�����������������������������������������������
	PRIVATE cCadastro := OemToAnsi(STR0006) //"Acertos Fiscales"
   PRIVATE lInverte  := If( mv_par09==1, .T., .F. )
   PRIVATE cMarca    := GetMark()

	//���������������������������������������������Ŀ
	//� Endereca a funcao de MarkBrowse             � 
	//�����������������������������������������������
   MarkBrow("SF3","F3_OK","F3_AJUSTE",,lInverte,cMarca)
	
	dbSelectArea("SF3")
	RetIndex("SF3")
	FErase( cIndexSF3+OrdBagExt())
EndIf
Return Nil

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A901Acer � Autor � Lucas                 � Data � 15/08/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ajustar as aliquotas de IVA por lote com base nas perguntas���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA901                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A901Acer(cAlias,nReg,nOpc)
LOCAL lRet

PRIVATE lDigita, lAglutina, lGeraLanc
PRIVATE lLanPad730 := .F.
PRIVATE lLanPad740 := .F.
PRIVATE nHdlPrv    := 1, nTotal := 0, nLinha := 2
PRIVATE cLoteFis   := ""
PRIVATE cArquivo   := ""

If FisChkDt(mv_par01) .And. FisChkDt(mv_par02)

	Processa({|lEnd| lRet:= A930Proces(,,,@lInverte)},,OemToAnsi(STR0007)) //"Procesando Registros..."

	//������������������������������������������������������Ŀ
	//� Driblar a aRotina para volte para o MarkBrowse			�
	//��������������������������������������������������������
	aRotina[3][4] := 4
EndIf

dbSelectArea( cAlias )
dbGoTo( nReg )
Return

/*/
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A901Process � Autor � Lucas 		        � Data � 15/08/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ajustar as aliquotas de IVA por lote com base nas perguntas���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA901                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A930Proces()

LOCAL nCountReg := 0
LOCAL aValImp   := { 0.00, 0.00 }
LOCAL aDifImp   := { 0.00, 0.00 }
LOCAL aRecnoSF3 := {}
LOCAL cFornece  := GetMV("MV_MUNIC")
LOCAL nI		:= 0

If Empty(cFornece)
	MsgStop(STR0008) //"Definir Proveedor FISCO en el parametro MV_MUNIC!"
	Return
EndIf

lDigita   := If( mv_par06 == 1,.T.,.F. )
lAglutina := If( mv_par07 == 1,.T.,.F. )
lGeraLanc := If( mv_par08 == 1,.T.,.F. )

If lGeraLanc
	lLanPad730 := VerPadrao("730")
	lLanPad740 := VerPadrao("740")
Else
	lLanPad730 := .F.
	lLanPad740 := .F.
EndIf	

If (lLanPad730 .or. lLanPad740) .and. !__TTSInUse
	//������������������������������������������������������Ŀ
	//� Posiciona numero do lote para lancamentos do Fiscal  �
	//��������������������������������������������������������
   dbSelectArea("SX5")
   dbSeek(cFilial+"09FIS")
   cLoteFis:=IIF(Found(),Trim(X5_DESCRI),"FIS ")
   nHdlPrv :=HeadProva(cLoteFis,"MATA901",cUserName,@cArquivo)
   If nHdlPrv <= 0
      Help(" ",1,"A901NOPRV")
   EndIf
EndIf

//���������������������������������������������������������������������Ŀ
//� Inicio do processo para geracao...												�
//�����������������������������������������������������������������������
dbSelectArea("SF3")
dbGoTop()

nCountReg := SF3->(RecCount())

ProcRegua(nCountReg,21,04)
	
While !Eof()

   IncProc()

   If IsMark("F3_OK", cMarca, lInverte)

		If mv_par04 > 0
		   Replace  F3_ALQIMP1 	With 10.00
			Replace  F3_VALIMP1 	With SF3->F3_BASIMP1 * ( 10/100 )
			aValImp[1] := aValImp[1] + SF3->F3_VALIMP1
			aDifImp[1] := SF3->F3_VALIMP1
			RecLock("SF3",.F.)
			Replace	F3_VALIMP1	With F3_BASIMP1 * (mv_par04/100 )
			Replace	F3_ALQIMP1  With mv_par04
			Replace  F3_AJUSTE   With "S"
			aValImp[2] := aValImp[2] + SF3->F3_VALIMP1
			aDifImp[2] := SF3->F3_VALIMP1
			If aDifImp[1] > aDifImp[2]
				Replace	F3_VALCONT	With F3_VALCONT - (aDifImp[1]-aDifImp[2])
			ElseIf aDifImp[1] < aDifImp[2]
				Replace	F3_VALCONT	With F3_VALCONT + (aDifImp[2]-aDifImp[1])
			EndIf
			MsUnLock()			
		EndIf
		
	EndIf	
	dbSelectArea("SF3")
	dbSkip()
End

//������������������������������������������������������Ŀ
//� Gera Lancamento Contab. para as diferencas do Ajuste �
//��������������������������������������������������������
If aValImp[1] > aValImp[2]

	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2")+cFornece) )
				
	dbSelectArea("SF3")
	RecLock("SF3",.T.)
	Replace F3_FILIAL 	With xFilial("SF3")
	Replace F3_ENTRADA	With dDataBase
	Replace F3_NFISCAL	With "AJUSTES"
	Replace F3_SERIE     With "   "
	Replace F3_CLIEFOR	With cFornece
	Replace F3_LOJA		With "01"
	Replace F3_EMISSAO   With dDataBase
	Replace F3_ESTADO    With SA2->A2_EST
	Replace F3_VALCONT   With aValImp[1]-aValImp[2]
	Replace F3_BASIMP1   With aValImp[1]-aValImp[2]
	Replace F3_VALIMP1	With aValImp[1]-aValImp[2]
	Replace F3_ALQIMP1   With mv_par04
	Replace F3_OBSERV    With "Credito Dif. IVA, DEC 13.424/92 Par 30."
	Replace F3_TIPOMOV   With "A"
	MsUnLock()
	AADD(aRecnoSF3,SF3->(Recno()) )
				
	If lLanPad730
		nTotal+=DetProva(nHdlPrv,"730","MATA901",cLoteFis,@nLinha)
	EndIf
	
ElseIf aValImp[1] < aValImp[2] 	

	SA2->( dbSetOrder(1) )
	SA2->( dbSeek(xFilial("SA2")+cFornece) )

	dbSelectArea("SF3")
	RecLock("SF3",.T.)
	Replace F3_FILIAL 	With xFilial("SF3")
	Replace F3_ENTRADA	With dDataBase
	Replace F3_NFISCAL	With "AJUSTES"
	Replace F3_SERIE     With "   "
	Replace F3_CLIEFOR	With cFornece
	Replace F3_LOJA		With "01"
	Replace F3_EMISSAO   With dDataBase
	Replace F3_ESTADO    With SA2->A2_EST
	Replace F3_VALCONT   With aValImp[2]-aValImp[1]
	Replace F3_BASIMP1   With aValImp[2]-aValImp[1]
	Replace F3_VALIMP1	With aValImp[2]-aValImp[1]
	Replace F3_ALQIMP1   With mv_par04
	Replace F3_OBSERV    With STR0009 //"Debito Dif. IVA, DEC 13.424/92 Par 30."
	Replace F3_TIPOMOV   With "A"
	MsUnLock()
	AADD(aRecnoSF3,SF3->(Recno()) )

	If lLanPad740
		nTotal+=DetProva(nHdlPrv,"740","MATA901",cLoteFis,@nLinha)
	EndIf
EndIf

//�����������������������������������������������������������������Ŀ
//� Envia para Lancamento Contabil, qdo for NF de Cr�dito...        �
//�������������������������������������������������������������������
If nHdlPrv > 0 .and. (lLanPad730 .or. lLanPad740) .and. !__TTSInUse

   RodaProva(nHdlPrv,nTotal)
   //�����������������������������������������������������Ŀ
   //� Envia para Lancamento Contabil, se gerado arquivo   �
   //�������������������������������������������������������
   lLanctOk := cA100Incl(cArquivo,nHdlPrv,3,cLoteFis,lDigita,lAglutina)

   If lLanctOk
		For nI := 1 To Len( aRecnoSF3 )
			dbGoto( aRecnoSF3[nI] )
	      RecLock("SF3",.F.)
   	   Replace F3_DTLANC   With dDataBase
      	MsUnLock()
		Next nI
	EndIf	

EndIf
Return( Nil )

