#INCLUDE "QMTR160.CH"
#INCLUDE "PROTHEUS.CH"
#include "report.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTR160  � Autor � Cicero Cruz           � Data � 23.06.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Referencia cruzada. Instrumento x Instrumento Utilizado    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMTR160(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Obs.     � Manutencao - Leandro Sabino 21/09/06                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR160()
Local oReport        

If TRepInUse()
	// Interface de impressao
	//�������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros				  �
	//� mv_par01 : Instrumento de                             �
	//� mv_par02 : Revisao de                                 �
	//� mv_par03 : Instrumento ate                            �
	//� mv_par04 : Revisao ate                                �
	//� mv_par05 : Periodo Inicial                            �
	//� mv_par06 : Periodo Final                              �
	//� mv_par07 : Departamento de                            �
	//� mv_par08 : Departamento ate                           �
	//� mv_par09 : Orgao Calibrador Todos/Interno/Externo     �
	//� mv_par10 : Org. Calibr. Interno de                    �
	//� mv_par11 : Org. Calibr. Interno ate                   �
	//� mv_par12 : Org. Calibr. Externo de                    �
	//� mv_par13 : Org. Calibr. Externo ate                   �
	//� mv_par14 : Familia de                                 �
	//� mv_par15 : Familia ate                                �
	//� mv_par16 : Usu�rio de                                 �
	//� mv_par17 : Usu�rio ate                                �
	//� mv_par18 : Fabricante de                              �
	//� mv_par19 : Fabricante ate                             �
	//���������������������������������������������������������
	Pergunte("QMR160",.F.)  

	oReport := ReportDef()
 	oReport:PrintDialog()
Else
	QMTR160R3()
EndIf

Return
         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Cicero Cruz           � Data � 23/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QMTR130                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport 
Local oSection

DEFINE REPORT oReport NAME "QMTR160" TITLE STR0003 PARAMETER "QMR160" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION STR0001+STR0002
oReport:SetLandscape(.T.)
DEFINE SECTION oSection OF oReport TITLE STR0005 TABLES "QMI"
DEFINE CELL NAME "QMI_INSTR"  OF oSection ALIAS "" TITLE TitSX3("QMI_INSTR")[1]  AUTO SIZE   
DEFINE CELL NAME "QMI_REVINS" OF oSection ALIAS "" TITLE TitSX3("QMI_REVINS")[1] AUTO SIZE   
DEFINE CELL NAME "QM2_TIPO"   OF oSection ALIAS "" TITLE TitSX3("QM2_TIPO")[1]   AUTO SIZE   
DEFINE CELL NAME "QM2_DEPTO"  OF oSection ALIAS "" TITLE TitSX3("QM2_DEPTO")[1]  AUTO SIZE   
DEFINE CELL NAME "QM2_RESP"   OF oSection ALIAS "" TITLE TitSX3("QM2_RESP")[1]   AUTO SIZE   
DEFINE CELL NAME "QMI_ESCALA" OF oSection ALIAS "" TITLE STR0009
DEFINE CELL NAME "QMI_PONTO"  OF oSection ALIAS "" TITLE STR0010
DEFINE CELL NAME "QMI_INSUT"  OF oSection ALIAS "" TITLE STR0011
DEFINE CELL NAME "F_INSTUT"   OF oSection TITLE STR0012

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �PrintRepor� Autor � Cicero Cruz           � Data � 26.06.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao dos Textos	Reprogramacao R4	 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTr160													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport( oReport )
Local oSection1 := oReport:Section(1)
Local cStrAnt   := ""
Local TRB_INSTR		:= ""
Local TRB_REVINS	:= ""
Local TRB_INSUT		:= ""
Local TRB_ESCALA	:= ""
Local TRB_PONTO		:= ""
Local TRB_FILQM2	:= ""
Local TRB_INSQM2	:= ""
Local TRB_REVQM2	:= ""
Local TRB_DEPQM2	:= ""
Local TRB_RESQM2	:= ""
Local TRB_FABQM2	:= ""
Local TRB_TIPQM2	:= ""

dbSelectArea("QMI")
dbSetOrder(1)
	
//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:uParam) 


//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
oSection1:BeginQuery()	

BeginSql Alias "TRB"                   

	SELECT QMI.QMI_FILIAL,QMI.QMI_INSTR,QMI.QMI_REVINS,QMI.QMI_DATA,QMI.QMI_ESCALA,QMI.QMI_PONTO,QMI.QMI_INSUT,QMI.QMI_ESCPAD,QMI.QMI_INCERT,
		   QM2.QM2_FILIAL,QM2.QM2_INSTR,QM2.QM2_REVINS,QM2.QM2_RESP,QM2.QM2_DEPTO,QM2.QM2_TIPO,QM2.QM2_FABR 
	FROM %table:QMI% QMI,%table:QM2% QM2 
	WHERE 
		QMI.QMI_FILIAL = %xFilial:QMI%	 AND 
		QMI.QMI_INSTR >= %Exp:mv_par01%	 AND  
		QMI.QMI_INSTR <= %Exp:mv_par03%	 AND  
		QMI.QMI_DATA BetWeen %Exp:Dtos(mv_par05)% AND %Exp:Dtos(mv_par06)%   AND  
		QM2.QM2_FILIAL = QMI.QMI_FILIAL  AND  QM2.QM2_INSTR  = QMI.QMI_INSTR AND 
		QM2.QM2_REVINS = QMI.QMI_REVINS  AND 
		QM2.QM2_TIPO BetWeen %Exp:mv_par14% AND %Exp:mv_par15% AND  
		QM2.QM2_RESP BetWeen %Exp:mv_par16% AND %Exp:mv_par17%  AND  
		QM2.QM2_FABR BetWeen %Exp:mv_par18% AND %Exp:mv_par19%  AND  
		QMI.%notDel% AND QM2.%notDel%
	ORDER BY QMI_FILIAL,QMI_INSTR,QMI_REVINS,QMI_DATA

EndSql   
oSection1:EndQuery()

QMI->(DBGotop())

While ! Eof() 

	TRB_INSTR	:= TRB->QMI_INSTR
	TRB_REVINS	:= TRB->QMI_REVINS
	TRB_INSUT	:= TRB->QMI_INSUT
	TRB_ESCALA	:= TRB->QMI_ESCALA
	TRB_PONTO	:= TRB->QMI_PONTO
	TRB_FILQM2	:= TRB->QM2_FILIAL
	TRB_INSQM2	:= TRB->QM2_INSTR
	TRB_REVQM2	:= TRB->QM2_REVINS
	TRB_DEPQM2	:= TRB->QM2_DEPTO
	TRB_RESQM2	:= TRB->QM2_RESP
	TRB_FABQM2	:= TRB->QM2_FABR
	TRB_TIPQM2	:= TRB->QM2_TIPO


	// Encontro o instrumento - Executa tambem em Top para AS/400 e CodeBase
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))

	dbSelectArea("TRB")

	TRB_FILQM2	:= QM2->QM2_FILIAL
	TRB_INSQM2	:= QM2->QM2_INSTR
	TRB_REVQM2	:= QM2->QM2_REVINS
	TRB_DEPQM2	:= QM2->QM2_DEPTO
	TRB_RESQM2	:= QM2->QM2_RESP	
	TRB_FABQM2	:= QM2->QM2_FABR
	TRB_TIPQM2	:= QM2->QM2_TIPO                               


	If ( TRB_DEPQM2 < mv_par07 .or. TRB_DEPQM2 > mv_par08 )
		QMI->(dbSkip())
	EndIf
	
	If (TRB_TIPQM2 < mv_par14 .or. TRB_TIPQM2 > mv_par15 )
		QMI->(dbSkip())
	EndIf
	
	If ( TRB_RESQM2 < mv_par16 .or. TRB_RESQM2 > mv_par17 )
		QMI->(dbSkip())
	EndIf
	
	If ( TRB_FABQM2 < mv_par18 .or. TRB_FABQM2 > mv_par19 )
		QMI->(dbSkip())
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par09 == 1
		If ! Calibrador(0,mv_par10,mv_par11,mv_par12,mv_par13,TRB_INSTR,TRB_REVQM2)
			QMI->(dbSkip())
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par09 == 2
		If ! Calibrador(1,mv_par10,mv_par11,,,TRB_INSTR,TRB_REVQM2)
			QMI->(dbSkip())
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par09 == 3
		If ! Calibrador(2,,,mv_par12,mv_par13,TRB_INSTR,TRB_REVQM2)
			QMI->(dbSkip())
		EndIf
	EndIf

	If cStrAnt != (TRB_INSTR + TRB_REVINS)
		oSection1:Finish()		
		oSection1:Init()		

		oSection1:Cell("QMI_INSTR"):Show()
		oSection1:Cell("QMI_REVINS"):Show()
		oSection1:Cell("QM2_TIPO"):Show()
		oSection1:Cell("QM2_DEPTO"):Show()	
		oSection1:Cell("QM2_RESP"):Show()  
	
		cStrAnt := TRB_INSTR + TRB_REVINS

		oSection1:CELL("QMI_INSTR"):SetValue(TRB_INSTR)
		oSection1:CELL("QMI_REVINS"):SetValue(TRB_REVINS)
		oSection1:CELL("QM2_TIPO"):SetValue(TRB_TIPQM2)

		dbSelectArea("QAD")
		dbSetOrder(1)
		If dbSeek(xFilial("QAD")+TRB_DEPQM2)
			oSection1:CELL("QM2_DEPTO"):SetValue(QAD->QAD_DESC)
		Endif	
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(xFilial("QAA")+TRB_RESQM2)
			oSection1:CELL("QM2_RESP"):SetValue(QAA->QAA_NOME)
		Endif

		oSection1:Cell("QMI_INSTR"):Show()
		oSection1:Cell("QMI_REVINS"):Show()
		oSection1:Cell("QM2_TIPO"):Show()
		oSection1:Cell("QM2_DEPTO"):Show()	
		oSection1:Cell("QM2_RESP"):Show()  

	Else
		oSection1:Cell("QMI_INSTR"):Hide()
		oSection1:Cell("QMI_REVINS"):Hide()
		oSection1:Cell("QM2_TIPO"):Hide()
		oSection1:Cell("QM2_DEPTO"):Hide()	
		oSection1:Cell("QM2_RESP"):Hide()  
	EndIf

		
	// Busca pelo Instrumento Utilizado
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek( TRB_FILQM2 + TRB_INSUT )

	TRB_INSQM2 := QM2->QM2_INSTR            
	TRB_TIPQM2 := QM2->QM2_TIPO

	oSection1:CELL("QMI_ESCALA"):SetValue(TRB_ESCALA)
	oSection1:CELL("QMI_PONTO"):SetValue(TRB_PONTO)
	oSection1:CELL("QMI_INSUT"):SetValue(TRB_INSQM2)
	oSection1:CELL("F_INSTUT"):SetValue(TRB_TIPQM2)

    oSection1:Printline()

	dbSelectArea("TRB")

EndDo


Return 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTR160R3� Autor � Denis Martins			� Data � 15.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Referencia cruzada. Instrumento x Instrumento Utilizado    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTR160R3(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR160R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 											 �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2		:= OemToAnsi(STR0002) // "cruzada entre instrumentos e instrumentos utilizados."
Local cDesc3		:= ""
Local cString		:="QM3"
Local wnrel

Private titulo		:= OemToAnsi(STR0003) // "Ref. Cruzada: Instrumento x Instrumento Utilizado"
Private cabec1		:= 	PadR(STR0013,16) + PadR(STR0014,05) + PadR(STR0015,17) +; 	// "Instrumento"###"Rev"###"Familia"
						PadR(STR0016,31) + PadR(STR0017,25) + PadR(STR0009,19) +; 	// "Depto."###"Resp."###"Faixa Inst. Util."
						PadR(STR0010,19) + PadR(STR0011,19) + PadR(STR0012,19)   	// "Ponto Inst. Util."###"Instrumento Util."###"Familia Inst. Util."

Private cabec2		:= ""

Private aReturn	:= {OemToAnsi(STR0005),1,OemToAnsi(STR0006),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog	:= "QMTR160"
Private nLastKey	:= 0
Private cPerg		:= "QMR160"
Private cTamanho	:= "G"

/*
1 		  2			3			 4 		  5			6			 7 		  8			9			 0 		  1			2			 3 		  4			5			 6 		  7			8			 9 		  0			1
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Instrumento      Rev Familia          Depto.                    Resp.                          Escala Inst.Utl. Ponto Inst.Utl.  Instrum.Utilizado Famila Inst.Utl."
XXXXXXXXXXXXXXXX XX  XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX
*/

//�����������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 						  �
//�������������������������������������������������������������
pergunte("QMR160",.F.)

//�������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros				  �
//� mv_par01 : Instrumento de                             �
//� mv_par02 : Revisao de                                 �
//� mv_par03 : Instrumento ate                            �
//� mv_par04 : Revisao ate                                �
//� mv_par05 : Periodo Inicial                            �
//� mv_par06 : Periodo Final                              �
//� mv_par07 : Departamento de                            �
//� mv_par08 : Departamento ate                           �
//� mv_par09 : Orgao Calibrador Todos/Interno/Externo     �
//� mv_par10 : Org. Calibr. Interno de                    �
//� mv_par11 : Org. Calibr. Interno ate                   �
//� mv_par12 : Org. Calibr. Externo de                    �
//� mv_par13 : Org. Calibr. Externo ate                   �
//� mv_par14 : Familia de                                 �
//� mv_par15 : Familia ate                                �
//� mv_par16 : Usu�rio de                                 �
//� mv_par17 : Usu�rio ate                                �
//� mv_par18 : Fabricante de                              �
//� mv_par19 : Fabricante ate                             �
//���������������������������������������������������������

//�����������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT							�
//�������������������������������������������������������������������
wnrel:="QMTR160"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR160Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTR160IMP� Autor � Denis Martins			� Data � 15.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime REFERENCIA CRUZADA: INSTRUMENTO x INSTR.UTILIZADO  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTR160IMP(lEnd,wnRel,cString)							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd	   - Acao do Codeblock								  ���
���			 � wnRel   - Titulo do relat�rio 							  ���
���			 � cString - Mensagem										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTR160Imp(lEnd,wnRel,cString)

Local CbCont
Local CbTxt
Local cStrAnt     := ""
Local lDivide     := .F.
Local cQuery
Local cChave
Local TRB_INSTR	
Local TRB_REVINS	
Local TRB_INSUT	
Local TRB_ESCALA	
Local TRB_PONTO	
Local TRB_FILQM2	
Local TRB_INSQM2	
Local TRB_REVQM2
Local TRB_DEPQM2
Local TRB_RESQM2
Local TRB_FABQM2
Local TRB_TIPQM2
Local nIndex
Local lImpr := .F.

Private cIndex := ""

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("QMI")

cChave := "QMI_FILIAL+QMI_INSTR+QMI_REVINS+QMI_DATA"
cQuery := "SELECT QMI_FILIAL,QMI_INSTR,QMI_REVINS,QMI_DATA,QMI_ESCALA,QMI_PONTO,QMI_INSUT,QMI_ESCPAD,QMI_INCERT,"
cQuery += "QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_RESP,QM2_DEPTO,QM2_TIPO,QM2_FABR "
cQuery += "FROM "+RetSqlName("QMI")+" QMI, "
cQuery += RetSqlName("QM2")+" QM2 "
cQuery += "WHERE "
cQuery += "QMI.QMI_FILIAL = '"			+xFilial("QMI")+	"' AND "
cQuery += "QMI.QMI_INSTR >= '"			+mv_par01+			"' AND " 
cQuery += "QMI.QMI_INSTR <= '"			+mv_par03+			"' AND " 
cQuery += "QMI.QMI_DATA BetWeen '"		+ Dtos(mv_par05) +			"' AND '" + Dtos(mv_par06) + 			"' AND " 
cQuery += "QM2.QM2_FILIAL = QMI.QMI_FILIAL "	+						" AND " 
cQuery += "QM2.QM2_INSTR  = QMI.QMI_INSTR "		+						" AND "
cQuery += "QM2.QM2_REVINS = QMI.QMI_REVINS "	+						" AND "
cQuery += "QM2.QM2_TIPO BetWeen '"				+ mv_par14 +			"' AND '" + mv_par15 + 			"' AND " 
cQuery += "QM2.QM2_RESP BetWeen '"				+ mv_par16 +			"' AND '" + mv_par17 + 			"' AND " 
cQuery += "QM2.QM2_FABR BetWeen '"				+ mv_par18 +			"' AND '" + mv_par19 + 			"' AND " 
cQuery += "QMI.D_E_L_E_T_= ' ' "				+						" AND " +"QM2.D_E_L_E_T_= ' ' "
cQuery += " ORDER BY " + SqlOrder(cChave)
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
TcSetField("TRB","QMI_DATA","D",8,0)
dbSelectArea( "TRB" )

SetRegua(RecCount())

While ! Eof() 

	TRB_INSTR	:= TRB->QMI_INSTR
	TRB_REVINS	:= TRB->QMI_REVINS
	TRB_INSUT	:= TRB->QMI_INSUT
	TRB_ESCALA	:= TRB->QMI_ESCALA
	TRB_PONTO	:= TRB->QMI_PONTO
	TRB_FILQM2	:= TRB->QM2_FILIAL
	TRB_INSQM2	:= TRB->QM2_INSTR
	TRB_REVQM2	:= TRB->QM2_REVINS
	TRB_DEPQM2	:= TRB->QM2_DEPTO
	TRB_RESQM2	:= TRB->QM2_RESP
	TRB_FABQM2	:= TRB->QM2_FABR
	TRB_TIPQM2	:= TRB->QM2_TIPO

	IncRegua()
	
	If ( TRB_INSTR+TRB_REVINS < mv_par01+mv_par02 ) .or. ( TRB_INSTR+TRB_REVINS > mv_par03+mv_par04 )
		dbSkip()
		Loop
	EndIf
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0007) // "CANCELADO PELO OPERADOR"
		Exit
	ENDIF
	
	// Encontro o instrumento - Executa tambem em Top para AS/400 e CodeBase
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))

	dbSelectArea("TRB")

	TRB_FILQM2	:= QM2->QM2_FILIAL
	TRB_INSQM2	:= QM2->QM2_INSTR
	TRB_REVQM2	:= QM2->QM2_REVINS
	TRB_DEPQM2	:= QM2->QM2_DEPTO
	TRB_RESQM2	:= QM2->QM2_RESP	
	TRB_FABQM2	:= QM2->QM2_FABR
	TRB_TIPQM2	:= QM2->QM2_TIPO
	
	If ( TRB_DEPQM2 < mv_par07 .or. TRB_DEPQM2 > mv_par08 )
		dbSkip()
		Loop
	EndIf
	
	If (TRB_TIPQM2 < mv_par14 .or. TRB_TIPQM2 > mv_par15 )
		dbSkip()
		Loop
	EndIf
	
	If ( TRB_RESQM2 < mv_par16 .or. TRB_RESQM2 > mv_par17 )
		dbSkip()
		Loop
	EndIf
	
	If ( TRB_FABQM2 < mv_par18 .or. TRB_FABQM2 > mv_par19 )
		dbSkip()
		Loop
	EndIf


	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par09 == 1
		If ! Calibrador(0,mv_par10,mv_par11,mv_par12,mv_par13,TRB_INSTR,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par09 == 2
		If ! Calibrador(1,mv_par10,mv_par11,,,TRB_INSTR,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par09 == 3
		If ! Calibrador(2,,,mv_par12,mv_par13,TRB_INSTR,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf
	
	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,ctamanho,IIF(aReturn[4]==1,15,18))
		lDivide := .F.
	EndIf
	
	/*
			  1 		2	      3			4 		  5			6		  7 	    8	   	  9		    0 		  1			2		  3 		4		  5			6 		  7			8		  9 		0		  1
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
    Instrumento      Rev Familia          Depto.                         Resp.                    Escala Inst.Ult. Ponto Inst.Utl.  Instrum.Utiliza.  Famila Inst.Utl.
	XXXXXXXXXXXXXXXX XX  XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxx
	*/
	
	lImpr := .T.	

	If cStrAnt != (TRB_INSTR + TRB_REVINS)
		
		cStrAnt := TRB_INSTR + TRB_REVINS
		If lDivide
			li++
			@li,00 PSAY __PrtThinLine()
			li++
		Endif
		lDivide := .T.
		
		@li,000 PSAY TRB_INSTR
		@li,017 PSAY TRB_REVINS
		@li,021 PSAY TRB_TIPQM2
		dbSelectArea("QAD")
		dbSetOrder(1)
		If dbSeek(xFilial("QAD")+TRB_DEPQM2)
			@li,038 PSAY Alltrim(SubStr(QAD->QAD_DESC,1,30))
		Endif	
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(xFilial("QAA")+TRB_RESQM2)
			@li,069 PSAY Alltrim(SubStr(QAA->QAA_NOME,1,24))
		Endif
	EndIf
	
	// Busca pelo Instrumento Utilizado
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek( TRB_FILQM2 + TRB_INSUT )
	
	TRB_INSQM2 := QM2->QM2_INSTR            
	TRB_TIPQM2 := QM2->QM2_TIPO
	
	@li,094 PSAY TRB_ESCALA
	@li,113 PSAY TRB_PONTO
	@li,132 PSAY TRB_INSQM2
	@li,151 PSAY TRB_TIPQM2
	
	dbSelectArea("TRB")
	dbSkip()
	
	li++
	
EndDo

If lImpr
	li++
	@li,000 PSAY __PrtThinLine()
	li++
	Roda( cbCont, cbTxt, cTamanho )
	Set Device To Screen
Endif

If File(cIndex+OrdBagExt())
	Set Filter To
	RetIndex("QMI") 
	dbClearInd()
	FErase(cIndex+OrdBagExt())
	dbCloseArea()
Else	
	dbSelectArea("TRB")
	dbCloseArea()
	dbSelectArea("QMI")
	dbSetOrder(1)
EndIf

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End

MS_FLUSH()

Return