#INCLUDE "QMTR180.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMTR180   �Autor  �Leandro Sabino      � Data �  07/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Referencia cruzada. Instr.Utilizado(s) x Instrumento(s)     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAQMT                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QMTR180()
Local oReport

If !TRepInUse()
	Return QMTR180R3()	// Executa vers�o anterior do fonte
Else                 
	//�������������������������������������������������������������������Ŀ
	//� Variaveis utilizadas para parametros						      �
	//� mv_par01			// Instrumento Utilizado Inicial			  �
	//� mv_par02			// Instrumento Utilizado Final                �
	//� mv_par03            // Per�odo Inicial                            �
	//� mv_par04            // Per�odo Final                              �
	//� mv_par05            // Departamento Inicial                       �
	//� mv_par06            // Departamento Final                         �
	//� mv_par07            // Orgao Calibrador Todos/Interno/Externo     �
	//� mv_par08            // Org. Calibr. Interno Inicial               �
	//� mv_par09            // Org. Calibr. Interno Final                 �
	//� mv_par10            // Org. Calibr. Externo Inicial               �
	//� mv_par11            // Org. Calibr. Externo Final                 �
	//� mv_par12            // Familia Inicial                            �
	//� mv_par13            // Familia Final                              �
	//� mv_par14            // Usu�rio Inicial                            �
	//� mv_par15            // Usu�rio Final                              �
	//� mv_par16            // Fabricante Inicial                         �
	//� mv_par17            // Fabricante Final                           �
	//���������������������������������������������������������������������
	Pergunte("QMR180",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
EndIF    

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 07/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local ctitulo    := OemToAnsi(STR0003) // "Ref. Cruzada: Instrumento Utilizado x Instrumento"
Local cDesc1  	 := OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2	 := OemToAnsi(STR0002) // "cruzada entre instrumentos utilizados e instrumentos. "

Local oSection1 

DEFINE REPORT oReport NAME "QMTR180" TITLE cTitulo PARAMETER "QMR180" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "QMI","QM2" Title SubStr(STR0003,At(":",STR0003)+2,Len(STR0003))
DEFINE CELL NAME "cINSTUT" OF oSection1 ALIAS "" TITLE OemToAnsi(STR0026)       SIZE TamSx3("QMI_INSTR")[1]//"Inst. Utilizado"
DEFINE CELL NAME "cCSEQ"   OF oSection1 ALIAS "" TITLE TITSX3("QMI_CSEQ")[1]    SIZE TamSx3("QMI_CSEQ")[1]
DEFINE CELL NAME "cESCALA" OF oSection1 ALIAS "" TITLE TITSX3("QMI_ESCALA")[1]  SIZE TamSx3("QMI_ESCALA")[1]
DEFINE CELL NAME "cPONTO"  OF oSection1 ALIAS "" TITLE TITSX3("QMI_PONTO")[1]   SIZE TamSx3("QMI_PONTO")[1]
DEFINE CELL NAME "cTIPQM1" OF oSection1 ALIAS "" TITLE OemToAnsi(STR0027)       SIZE TamSx3("QM2_TIPO")[1]//"Familia Instr.Util."
DEFINE CELL NAME "cINSTR"  OF oSection1 ALIAS "" TITLE TITSX3("QMI_INSTR")[1]   Auto SIZE 
DEFINE CELL NAME "cREVINS" OF oSection1 ALIAS "" TITLE TITSX3("QMI_REVINS")[1]  SIZE TamSx3("QMI_REVINS")[1]
DEFINE CELL NAME "cTIPQM2" OF oSection1 ALIAS "" TITLE TITSX3("QM2_TIPO")[1]    SIZE TamSx3("QM2_TIPO")[1]
DEFINE CELL NAME "cDEPQM2" OF oSection1 ALIAS "" TITLE TITSX3("QF3_DEPTO")[1]   Auto SIZE 
DEFINE CELL NAME "cRESQM2" OF oSection1 ALIAS "" TITLE TITSX3("QE5_RESPON")[1]  Auto SIZE 

Return oReport


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 07/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Referencia cruzada. Instr.Utiizado(s) x Instrumento(s)   	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR180                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oSection1   := oReport:Section(1) 
Local cStrAnt     := ""
Local cStrEscAnt  := ""	
Local TRB_INSTR	:= ""	
Local TRB_REVINS:= ""	
Local TRB_INSTUT:= ""	
Local TRB_ESCALA:= ""	
Local TRB_PONTO	:= ""	
Local TRB_FILQM2:= ""	
Local TRB_INSQM2:= ""	
Local TRB_REVQM2:= ""	
Local TRB_DEPQM2:= ""	
Local TRB_RESQM2:= ""	
Local TRB_FABQM2:= ""	
Local TRB_TIPQM2:= ""	
Local TRB_DATA  := ""	
Local TRB_CSEQ  := ""	

dbSelectArea("QMI")
dbSetOrder(1)

	MakeSqlExpr(oReport:uParam)

	oSection1:BeginQuery()


    	BeginSQL alias  "TRB"

			SELECT QMI.QMI_FILIAL,QMI.QMI_INSUT,QMI.QMI_INSTR,QMI.QMI_REVINS,QMI.QMI_DATA,QMI.QMI_ESCALA,QMI.QMI_PONTO,QMI.QMI_CSEQ,
			       QM2.QM2_FILIAL,QM2.QM2_INSTR,QM2.QM2_REVINS,QM2.QM2_RESP,QM2.QM2_DEPTO,QM2.QM2_TIPO,QM2.QM2_FABR 
			FROM %table:QMI% QMI, %table:QM2% QM2
			WHERE 
				QMI.QMI_FILIAL   = %xFilial:QMI%	AND 
				QMI.QMI_INSTR   >= %Exp:mv_par01%  AND  
				QMI.QMI_INSTR   <= %Exp:mv_par02%  AND  
				QMI.QMI_DATA BetWeen %Exp:Dtos(mv_par03)% AND %Exp:Dtos(mv_par04)% AND  
				QM2.QM2_FILIAL = QMI.QMI_FILIAL  AND  
				QM2.QM2_INSTR  = QMI.QMI_INSUT   AND 
				QM2.QM2_DEPTO BetWeen %Exp:mv_par05% AND %Exp:mv_par06% AND  				
				QM2.QM2_TIPO BetWeen  %Exp:mv_par12% AND %Exp:mv_par13% AND  
				QM2.QM2_RESP BetWeen  %Exp:mv_par14% AND %Exp:mv_par15% AND  
				QM2.QM2_FABR BetWeen  %Exp:mv_par16% AND %Exp:mv_par17% AND  
				QMI.%notDel%  AND QM2.%notDel% 
			ORDER BY QMI_FILIAL,QMI_INSUT
		EndSql	
	

	oSection1:EndQuery()

dbGoTop()
	
While !oReport:Cancel() .And. !Eof()

			If !Empty(AllTrim(oReport:Section(1):GetSqlExp("QM2")))
				If !(&(oReport:Section(1):GetSqlExp("QM2")))
					dbSkip()
					Loop
				Endif
			EndIf 

			If !Empty(AllTrim(oReport:Section(1):GetSqlExp("QMI")))
				If !(&(oReport:Section(1):GetSqlExp("QMI")))
					dbSkip()
					Loop
				Endif
			EndIf 

			TRB_INSTR	:= TRB->QMI_INSTR
			TRB_REVINS	:= TRB->QMI_REVINS
			TRB_INSTUT	:= TRB->QMI_INSUT 
			TRB_ESCALA	:= TRB->QMI_ESCALA
			TRB_PONTO	:= TRB->QMI_PONTO
			TRB_DATA	:= DtoS(TRB->QMI_DATA)
			TRB_CSEQ	:= TRB->QMI_CSEQ
			TRB_FILQM2	:= TRB->QM2_FILIAL
			TRB_INSQM2	:= TRB->QM2_INSTR
			TRB_REVQM2	:= TRB->QM2_REVINS
			TRB_DEPQM2	:= TRB->QM2_DEPTO
			TRB_RESQM2	:= TRB->QM2_RESP
			TRB_FABQM2	:= TRB->QM2_FABR
			TRB_TIPQM2	:= TRB->QM2_TIPO  
		
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_INSQM2,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf

	If mv_par07 == 2
	//Verifico orgao calibrador interno
		If ! Calibrador(1,mv_par08,mv_par09,,,TRB_INSQM2,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf

	If mv_par07 == 3
	//	Verifico orgao calibrador externo
		If ! Calibrador(2,,,mv_par10,mv_par11,TRB_INSQM2,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf

	If cStrAnt != TRB_INSTUT
		oReport:SkipLine(1) 
		oReport:ThinLine()
		oSection1:Init()
		cStrAnt := TRB_INSTUT		
		oSection1:Cell("cINSTUT"):Show()
		oSection1:Cell("cINSTUT"):SetValue(cStrAnt)
	Else
		oSection1:Cell("cINSTUT"):Hide()
	EndIf
               
	If cStrEscAnt != (TRB_INSTUT+TRB_INSTR+TRB_ESCALA+TRB_PONTO)
		
		cStrEscAnt := TRB_INSTUT+TRB_INSTR+TRB_ESCALA+TRB_PONTO

		oSection1:Cell("cCSEQ"):SetValue(TRB_CSEQ)
		oSection1:Cell("cESCALA"):SetValue(TRB_ESCALA)
		oSection1:Cell("cPONTO"):SetValue(TRB_PONTO)
		oSection1:Cell("cTIPQM1"):SetValue(TRB_TIPQM2)
		
		oSection1:Cell("cINSTR"):SetValue(TRB_INSTR)
		oSection1:Cell("cREVINS"):SetValue(TRB_REVINS)
		oSection1:Cell("cTIPQM2"):SetValue(TRB_TIPQM2)
		
		//Localiza nome do departamento...
		dbSelectArea("QAD")
		dbSetOrder(1)
		If dbSeek(xFilial("QAD")+TRB_DEPQM2)	
			oSection1:Cell("cDEPQM2"):Show()
			oSection1:Cell("cDEPQM2"):SetValue(QAD->QAD_DESC)
		Else
			oSection1:Cell("cDEPQM2"):Hide()
		Endif

		//Localiza o nome do usuario...
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(xFilial("QAA")+TRB_RESQM2)
			oSection1:Cell("cRESQM2"):SetValue( QAA->QAA_NOME)
		Else
			oSection1:Cell("cRESQM2"):Hide()
		Endif	
		oSection1:PrintLine()
	EndIf                                                     
	
	dbSelectArea("TRB")	
		
	dbSkip()
	
EndDo

Return NIL


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTR180R3� Autor � Denis Martins         � Data � 28.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Referencia cruzada. Instr.Utiizado(s) x Instrumento(s)     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTR180(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR180R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 										     �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2		:= OemToAnsi(STR0002) // "cruzada entre instrumentos utilizados e instrumentos. "
Local cDesc3		:= ""
Local cString		:="QMI"
Local wnrel

Private titulo    := OemToAnsi(STR0003) // "Ref. Cruzada: Instrumento Utilizado x Instrumento"
Private cabec1	  := OemToAnsi(STR0004) 
Private cabec2    := ""

Private aReturn	:= {OemToAnsi(STR0005),1,OemToAnsi(STR0006),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog	:= "QMTR180"
Private nLastKey	:= 0
Private cPerg		:= "QMR180"
Private cTamanho := "G"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 							 �
//����������������������������������������������������������������

pergunte("QMR180",.F.)

//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros						      �
//� mv_par01			// Instrumento Utilizado Inicial			  �
//� mv_par02			// Instrumento Utilizado Final                �
//� mv_par03            // Per�odo Inicial                            �
//� mv_par04            // Per�odo Final                              �
//� mv_par05            // Departamento Inicial                       �
//� mv_par06            // Departamento Final                         �
//� mv_par07            // Orgao Calibrador Todos/Interno/Externo     �
//� mv_par08            // Org. Calibr. Interno Inicial               �
//� mv_par09            // Org. Calibr. Interno Final                 �
//� mv_par10            // Org. Calibr. Externo Inicial               �
//� mv_par11            // Org. Calibr. Externo Final                 �
//� mv_par12            // Familia Inicial                            �
//� mv_par13            // Familia Final                              �
//� mv_par14            // Usu�rio Inicial                            �
//� mv_par15            // Usu�rio Final                              �
//� mv_par16            // Fabricante Inicial                         �
//� mv_par17            // Fabricante Final                           �
//���������������������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT 						 �
//����������������������������������������������������������������
wnrel:="QMTR180"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR180Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTR180IMP� Autor � Denis Martins         � Data � 28.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime Referencia Cruzada: Inst.Utilizadox Instrumento    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTR180IMP(lEnd,wnRel,cString) 							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd	  - A�ao do Codeblock								  ���
���			 � wnRel   - T�tulo do relat�rio 							  ���
���			 � cString - Mensagem										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTR180Imp(lEnd,wnRel,cString)

Local CbCont
Local CbTxt
Local cStrAnt     := ""
Local cStrEscAnt  := ""	
Local lImpLinha   := .T.
Local cIndex := ""
Local cQuery
Local cChave

Local TRB_INSTR	
Local TRB_REVINS
Local TRB_INSTUT
Local TRB_ESCALA
Local TRB_PONTO	
Local TRB_FILQM2
Local TRB_INSQM2
Local TRB_REVQM2
Local TRB_DEPQM2
Local TRB_RESQM2
Local TRB_FABQM2
Local TRB_TIPQM2
Local TRB_DATA
Local TRB_CSEQ
Local lImps		:= .F.
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("QMI")
dbSetOrder(1)

cChave	:= "QMI_FILIAL+QMI_INSUT"
cQuery := "SELECT QMI_FILIAL,QMI_INSUT,QMI_INSTR,QMI_REVINS,QMI_DATA,QMI_ESCALA,QMI_PONTO,QMI_CSEQ,"
cQuery += "QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_RESP,QM2_DEPTO,QM2_TIPO,QM2_FABR "
cQuery += "FROM "+RetSqlName("QMI")+" QMI, "
cQuery += RetSqlName("QM2")+" QM2 "
cQuery += "WHERE "
cQuery += "QMI.QMI_FILIAL = '"					+ xFilial("QMI")+		"' AND "
cQuery += "QMI.QMI_INSTR   >= '"				+ mv_par01 +			"' AND " 
cQuery += "QMI.QMI_INSTR   <= '"				+ mv_par02 +			"' AND " 
cQuery += "QMI.QMI_DATA BetWeen '"				+ Dtos(mv_par03) +		"' AND '" + Dtos(mv_par04) + 			"' AND " 
cQuery += "QM2.QM2_FILIAL = QMI.QMI_FILIAL "	+ " AND " 
cQuery += "QM2.QM2_INSTR  = QMI.QMI_INSUT  "	+ " AND "
cQuery += "QM2.QM2_DEPTO BetWeen '"				+ mv_par05 +			"' AND '" + mv_par06 + 			"' AND " 				
cQuery += "QM2.QM2_TIPO BetWeen '"				+ mv_par12 +			"' AND '" + mv_par13 + 			"' AND " 
cQuery += "QM2.QM2_RESP BetWeen '"				+ mv_par14 +			"' AND '" + mv_par15 + 			"' AND " 
cQuery += "QM2.QM2_FABR BetWeen '"				+ mv_par16 +			"' AND '" + mv_par17 + 			"' AND " 
cQuery += "QMI.D_E_L_E_T_= ' ' "				+ " AND "  +			"QM2.D_E_L_E_T_= ' ' "
cQuery += " ORDER BY " + SqlOrder(cChave)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
TcSetField("TRB","QMI_DATA","D",8,0)
dbSelectArea( "TRB" )

SetRegua(RecCount())

While ! Eof() 

	TRB_INSTR	:= TRB->QMI_INSTR
	TRB_REVINS	:= TRB->QMI_REVINS
	TRB_INSTUT	:= TRB->QMI_INSUT 
	TRB_ESCALA	:= TRB->QMI_ESCALA
	TRB_PONTO	:= TRB->QMI_PONTO
	TRB_DATA	:= DtoS(TRB->QMI_DATA)
	TRB_CSEQ	:= TRB->QMI_CSEQ
	TRB_FILQM2	:= TRB->QM2_FILIAL
	TRB_INSQM2	:= TRB->QM2_INSTR
	TRB_REVQM2	:= TRB->QM2_REVINS
	TRB_DEPQM2	:= TRB->QM2_DEPTO
	TRB_RESQM2	:= TRB->QM2_RESP
	TRB_FABQM2	:= TRB->QM2_FABR
	TRB_TIPQM2	:= TRB->QM2_TIPO  
	
	IncRegua()
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0007) // "CANCELADO PELO OPERADOR"
		Exit
	ENDIF
	
		
		If mv_par07 == 1
			If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_INSQM2,TRB_REVQM2)
				dbSkip()
				Loop
			EndIf
		EndIf
	
		If mv_par07 == 2
		//Verifico orgao calibrador interno
			If ! Calibrador(1,mv_par08,mv_par09,,,TRB_INSQM2,TRB_REVQM2)
				dbSkip()
				Loop
			EndIf
		EndIf
	
		If mv_par07 == 3
		//	Verifico orgao calibrador externo
			If ! Calibrador(2,,,mv_par10,mv_par11,TRB_INSQM2,TRB_REVQM2)
				dbSkip()
				Loop
			EndIf
		EndIf
	
	/*
	          1 		2		  3			4 		  5			6		  7 	    8	   	  9		    0 		  1			2		  3 		4		  5		    6 		  7			8		  9 	    0			1
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Inst.Utilizado   Sequencia   Escala                   Ponto                    Famila Inst.Util          Instrumento           Rev         Familia                  Departamento                Responsavel
	xxxxxxxxxxxxxxxx     xx     xxxxxxxxxxxxxxxx         xxxxxxxxxxxxxxxx         xxxxxxxxxxxxxxxx          xxxxxxxxxxxxxxxx      xx          xxxxxxxxxxxxxxxx         xxxxxxxxxxxxxxxxxxxxxxxxx   xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
	*/
	lImps := .t.
		
	If li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,ctamanho,IIF(aReturn[4]==1,15,18))
		lImpLinha := .F.
	EndIf
	
	If cStrAnt != TRB_INSTUT
		
		cStrAnt := TRB_INSTUT
		
		If lImpLinha
			@li,000 PSAY __PrtThinLine()
			li++
		EndIf
		
		@li,000 PSAY TRB_INSTUT
		lImpLinha := .T.
	EndIf

	If cStrEscAnt != TRB_INSTUT+TRB_INSTR+TRB_ESCALA+TRB_PONTO
		
		cStrEscAnt := TRB_INSTUT+TRB_INSTR+TRB_ESCALA+TRB_PONTO
		
		@li,021 PSAY TRB_CSEQ
		@li,028 PSAY TRB_ESCALA
		@li,053 PSAY TRB_PONTO
		@li,078 PSAY TRB_TIPQM2
		
		@li,104 PSAY TRB_INSTR
		@li,126 PSAY TRB_REVINS
		@li,138 PSAY TRB_TIPQM2
	
		//Localiza nome do departamento...

		dbSelectArea("QAD")
		dbSetOrder(1)
		If dbSeek(xFilial("QAD")+TRB_DEPQM2)	
			TRB_DEPQM2 := QAD->QAD_DESC
			@li,163 PSAY TRB_DEPQM2
		Endif

		//Localiza o nome do usuario...
		dbSelectArea("QAA")
		dbSetOrder(1)
		If dbSeek(xFilial("QAA")+TRB_RESQM2)
			TRB_RESQM2 := QAA->QAA_NOME
			@li,191 PSAY TRB_RESQM2
		Endif	
	
		li++

	EndIf
	
	dbSelectArea("TRB")	
	dbSkip()
	
EndDo

If lImps
	li++
	@li,00 PSAY __PrtThinLine()
Endif	

Roda( cbCont, cbTxt, ctamanho )

Set Device To Screen
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

Return Nil
