#INCLUDE "QADR150.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QADR150   �Autor  �Leandro Sabino      � Data �  21/06/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Listagem Agenda de Auditorias   				              ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QADR150()
Local oReport

If TRepInUse()
	Pergunte("QAR150",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
	QADR150R3()	// Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 13/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local cTitulo    := STR0003 //"Listagem de Agendas de Auditorias"
Local cDesc1     := STR0001 //"Este relatorio tem o objetivo de imprimir a lista de "
Local cDesc2     := STR0002 //"Agendas de Auditorias"
Local oSection1 
Local oSection2 
															
DEFINE REPORT oReport NAME "QADR150" TITLE cTitulo PARAMETER "QAR150" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)

DEFINE SECTION oSection1 OF oReport TABLES "QUA" TITLE OemToAnsi(STR0008)	 
DEFINE CELL NAME "QUA_NUMAUD" OF oSection1 ALIAS "QUA"
DEFINE CELL NAME "QUA_DESCRI" OF oSection1 ALIAS "QUA"
DEFINE CELL NAME "QUA_ALOC"   OF oSection1 ALIAS "QUA" 
DEFINE CELL NAME "QUA_ALOCFI" OF oSection1 ALIAS "QUA"
DEFINE CELL NAME "QUA_FILMAT" OF oSection1 ALIAS "QUA"
DEFINE CELL NAME "QUA_MAT" 	  OF oSection1 ALIAS "QUA"
DEFINE CELL NAME "cNomAudLid" OF oSection1 ALIAS "QUA"  TITLE TitSX3("QUB_AUDLID")[1] SIZE 25 BLOCK {||QA_NUSR(QUA->QUA_FILMAT,QUA->QUA_MAT,.F.) }

DEFINE SECTION oSection2 OF oSection1 TABLES "QUM" TITLE OemToAnsi(STR0009)
DEFINE CELL NAME "QUM_CCUSTO" OF oSection2 ALIAS "QUM"
DEFINE CELL NAME "QUM_DESTIN" OF oSection2 ALIAS "QUM"
DEFINE CELL NAME "QUM_FILMAT" OF oSection2 ALIAS "QUM" 
DEFINE CELL NAME "QUM_CODAUD" OF oSection2 ALIAS "QUM" 
DEFINE CELL NAME "cNomeAud"   OF oSection2 ALIAS "QUM"  TITLE TitSX3("QUM_NOMAUD")[1] SIZE 25 BLOCK {||QA_NUSR(QUM->QUM_FILMAT,QUM->QUM_CODAUD,.F.)}		
 
DEFINE CELL NAME "QUM_DTIN"   OF oSection2 ALIAS "QUM" 
DEFINE CELL NAME "QUM_HRIN"   OF oSection2 ALIAS "QUM" 
DEFINE CELL NAME "QUM_DTFI"   OF oSection2 ALIAS "QUM" 
DEFINE CELL NAME "QUM_HRFI"   OF oSection2 ALIAS "QUM" 

		
Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 13/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Imprimir os campos do relatorio                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1)
Local lImpAug   := .T.

MakeAdvplExpr(oReport:uParam)

DbSelectarea("QUA")
QUA->(dbSetOrder(1))
QUA->(dbSeek(xFilial("QUA")+DTOS(mv_par01),.T.))

While QUA->(!Eof()) .And.(QUA->QUA_FILIAL+DTOS(QUA->QUA_ALOC)) >= (xFilial("QUA")+DTOS(mv_par01)) .And.;
	(QUA->QUA_FILIAL+DTOS(QUA->QUA_ALOC)) <= (xFilial("QUA")+DTOS(mv_par02))
	
	IF (mv_par03 > QUA->QUA_NUMAUD .OR. mv_par04 < QUA->QUA_NUMAUD)
		QUA->(DbSkip())
		Loop
	Endif
	
	IF  (mv_par05 > QUA->QUA_MAT .OR. mv_par06 < QUA->QUA_MAT)
		QUA->(DbSkip())
		Loop
	Endif
	
	If mv_par09 <> 1	// Ambas
		If mv_par09 == 2   .AND.  QUA->QUA_STATUS != '1'     	// Agendada
			QUA->(DbSkip())
			Loop
		ElseIF mv_par09 == 3 .AND. QUA->QUA_STATUS != '2'  	// Efetivada
			QUA->(DbSkip())
			Loop
		Endif
	Endif
	lImpAug:=.T.
	QUM->(dbSetOrder(1))
	QUM->(dbSeek(xFilial("QUM")+QUA->QUA_NUMAUD))
	While QUM->(!Eof()) .And. QUM->(QUM_FILIAL+QUM_NUMAUD) ==	xFilial("QUA")+QUA->QUA_NUMAUD
		
		IF  (mv_par07 > QUM->QUM_CODAUD .OR. mv_par08 < QUM->QUM_CODAUD)
			QUM->(DbSkip())
			Loop
		Endif

		IF lImpAug
			lImpAug:=.F.
			oReport:SkipLine(1)	
			oSection1:Finish()
			oSection1:Init()
			oSection1:PrintLine()
			oSection2:Init()
        Endif			
			
	    oSection2:PrintLine()	
		QUM->(dbSkip())
	EndDo
	
	QUA->(dbSkip())
	
	oSection2:Finish()
EndDo

		
Return NIL
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �QADR150R3 � Autor � Telso Carneiro		� Data � 04/12/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Listagem Agenda de Auditorias    						  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAQAD                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QADR150R3()

//��������������������������������������������������������������Ŀ
//� Define Variaveis Locais                                      �
//����������������������������������������������������������������
Local cDesc1     := STR0001 //"Este relatorio tem o objetivo de imprimir a lista de "
Local cDesc2     := STR0002 //"Agendas de Auditorias"
Local cDesc3     := ''
Local cString    := 'QUA'
Local lEnd       := .F.
Local Titulo     := STR0003 //"Listagem de Agendas de Auditorias"
Local wnRel      := 'QADR150'

Private cTamanho := 'M'
Private aReturn  := {STR0004, 1, STR0005, 1, 2, 1, '', 1} //"Zebrado"###"Administracao"
Private cPerg    := 'QAR150'

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
Pergunte(cPerg, .F.)

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho,"",.F.)

If nLastKey == 27
	Set Filter To
	Return Nil
Endif

SetDefault(aReturn, cString)

If nLastKey == 27
	Set Filter To
	Return Nil
Endif

RptStatus({|lEnd| Qad150Imp(@lEnd,wnRel,cString,Titulo)},Titulo)

Set Filter To

Return(NIL)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Qad110Imp � Autor � Telso Carneiro		� Data �04/12/03  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Agenda da Auditoria					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Qad150Imp(lEnd, wnRel, cTamanho, Titulo)					  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QADR150                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function Qad150Imp(lEnd,wnRel,cString,Titulo)

//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape         �
//���������������������������������������������������������������������
Local lImpAug :=.T.
Local cTxtFoot := Space(10)
Local cNomAudLid
Local cNomeAud

Private nLin :=80
Private m_pag   := 1
Private cCabec1 := STR0006 //"COD.AGENDA          DESCRICAO                     ALOCACAO  FIM ALOCACAO  FIL.AUD.  AUDITOR LIDER"
Private cCabec2 := ""
 
cCabec2 := STR0010 //"DEPTO         DEST.AUDITORIA                     FIL.AUD. AUDITOR                                   INICIO EM      FINAL EM"

//������������������������������������������������������������������������������Ŀ
//� Parametros utilizados                                                        �
//� mv_par01 - Data Alocacao de													 �
//� mv_par02 - Data Alocacao ate                                                 �
//� mv_par03 - Agenda de                                                         �                                                  �
//� mv_par04 - Agenda ate                                                        �
//� mv_par05 - Auditor Lider De                                                  �
//� mv_par06 - Auditor Lider ate                                                 �
//� mv_par07 - Auditor De                                                        �
//� mv_par08 - Auditor ate                                                       �
//� mv_par09 - Status da Agenda                                                  �
//��������������������������������������������������������������������������������

SetRegua(QUA->(LastRec()))
QUA->(dbSetOrder(1))
QUA->(dbSeek(xFilial("QUA")+DTOS(mv_par01),.T.))

While QUA->(!Eof()) .And. QUA->(QUA_FILIAL+DTOS(QUA_ALOC)) >= (xFilial("QUA")+DTOS(mv_par01)) .And.;
	QUA->(QUA_FILIAL+DTOS(QUA_ALOC)) <= (xFilial("QUA")+DTOS(mv_par02))
	
	IF (mv_par03 > QUA->QUA_NUMAUD .OR. mv_par04 < QUA->QUA_NUMAUD)
		QUA->(DbSkip())
		Loop
	Endif
	
	IF  (mv_par05 > QUA->QUA_MAT .OR. mv_par06 < QUA->QUA_MAT)
		QUA->(DbSkip())
		Loop
	Endif
	
	If mv_par09 <> 1	// Ambas
		If mv_par09 == 2   .AND.  QUA->QUA_STATUS != '1'     	// Agendada
			QUA->(DbSkip())
			Loop
		ElseIF mv_par09 == 3 .AND. QUA->QUA_STATUS != '2'  	// Efetivada
			QUA->(DbSkip())
			Loop
		Endif
	Endif
	
	IncRegua()
	lImpAug:=.T.
	
	QUM->(dbSetOrder(1))
	QUM->(dbSeek(xFilial("QUM")+QUA->QUA_NUMAUD))
	While QUM->(!Eof()) .And. QUM->(QUM_FILIAL+QUM_NUMAUD) ==	xFilial("QUA")+QUA->QUA_NUMAUD
		
		IF  (mv_par07 > QUM->QUM_CODAUD .OR. mv_par08 < QUM->QUM_CODAUD)
			QUM->(DbSkip())
			Loop
		Endif
		
		IF lImpAug
			If nLin > 55
				Cabec(titulo,cCabec1,cCabec2,wnRel,ctamanho)
				nLin   := 9
			Else
				@ nLin, 00 pSay __prtfatline()
				nLin++
			Endif
			
			lImpAug:=.F.
			
			//"COD.AGENDA          DESCRICAO                       ALOCACAO  FIM ALOCACAO  FIL.AUD.  AUDITOR LIDER"
			//"DEPTO   DEST.AUDITORIA                     FILIAL AUD.  AUDITOR "
			
			cNomAudLid := QA_NUSR(QUA->QUA_FILMAT,QUA->QUA_MAT,.F.)
			
			@ nLin, 00 pSay QUA->QUA_NUMAUD
			@ nLin, 09 pSay QUA->QUA_DESCRI
			@ nLin, 52 pSay QUA->QUA_ALOC
			@ nLin, 65 pSay QUA->QUA_ALOCFI
			@ nLin, 80 pSay QUA->QUA_FILMAT
			@ nLin, 86 pSay QUA->QUA_MAT
			@ nLin, 98 pSay cNomAudLid
			nLin++
			@ nLin, 00 pSay __prtthinline()
			nLin++
		Endif
		
		cNomeAud := QA_NUSR(QUM->QUM_FILMAT,QUM->QUM_CODAUD,.F.)
		
		@ nLin, 00 pSay QUM->QUM_CCUSTO
		@ nLin, 14 pSay Alltrim(QUM->QUM_DESTIN)
		@ nLin, 55 pSay QUM->QUM_FILMAT
		@ nLin, 58 pSay QUM->QUM_CODAUD
		@ nLin, 69 pSay cNomeAud
		 
		@ nLin,101 pSay QUM->QUM_DTIN
		@ nLin,110 pSay QUM->QUM_HRIN
		@ nLin,116 pSay QUM->QUM_DTFI
		@ nLin,125 pSay QUM->QUM_HRFI

		nLin++
		
		QUM->(dbSkip())
	EndDo
	
	QUA->(dbSkip())
EndDo

If nLin # 80
	Roda(0,cTxtFoot,cTamanho)
EndIf

//�������������������������������������������������������������������Ŀ
//� Devolve a condicao original do arquivo principal                  �
//���������������������������������������������������������������������
Set device to Screen

If aReturn[5] == 1
	Set Printer To  2
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return(NIL)
