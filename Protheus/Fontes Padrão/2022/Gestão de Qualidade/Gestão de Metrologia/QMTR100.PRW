#INCLUDE "QMTR100.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMTR100   �Autor  �Leandro Sabino      � Data �  09/08/06   ���
�������������������������������������������������������������������������͹��
���Desc.     �Referencia cruzada. Padrao Secundario por instrumento       ���
�������������������������������������������������������������������������͹��
���Uso       � SIGAQMT                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QMTR100()
Local oReport

If !TRepInUse()
	Return QMTR100R3()	// Executa vers�o anterior do fonte
Else                 
	Pergunte("QMR100",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
EndIF   

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 09/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local ctitulo := OemToAnsi(STR0003) // "Ref. Cruzada: Padrao Secundario x Instrumento"
Local cDesc1  := OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2  := OemToAnsi(STR0002) // "cruzada entre padr�es secund�rios e instrumentos. "

Local oSection1 

DEFINE REPORT oReport NAME "QMTR100" TITLE cTitulo PARAMETER "QMR100" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "QMS","QM2" Title OemToAnsi(STR0010) //"Padrao Secundario x Instrumentos"    

DEFINE CELL NAME "cPADSEC" OF oSection1 ALIAS "" TITLE TITSX3("QMS_PADSEC")[1]	SIZE TamSx3("QMS_PADSEC")[1]
DEFINE CELL NAME "cESCALA" OF oSection1 ALIAS "" TITLE TITSX3("QMS_ESCALA")[1]	SIZE TamSx3("QMS_ESCALA")[1]
DEFINE CELL NAME "cPONTO"  OF oSection1 ALIAS "" TITLE TITSX3("QMS_PONTO")[1] 	SIZE TamSx3("QMS_PONTO")[1]
DEFINE CELL NAME "cTIPPS" OF oSection1 ALIAS "" TITLE OemToAnsi(STR0009)     	SIZE TamSx3("QM2_TIPO")[1]	//"Familia Pad. Sec."
DEFINE CELL NAME "cINSTR"  OF oSection1 ALIAS "" TITLE TITSX3("QM2_INSTR")[1] 	SIZE TamSx3("QM2_INSTR")[1]
DEFINE CELL NAME "cREVINS" OF oSection1 ALIAS "" TITLE TITSX3("QM2_REVINS")[1]	SIZE TamSx3("QM2_REVINS")[1]
DEFINE CELL NAME "cTIPQM2" OF oSection1 ALIAS "" TITLE TITSX3("QM2_TIPO")[1]  	SIZE TamSx3("QM2_TIPO")[1]
DEFINE CELL NAME "cDEPQM2" OF oSection1 ALIAS "" TITLE TITSX3("QM2_DEPTO")[1] 	SIZE TamSx3("QM2_DEPTO")[1]
DEFINE CELL NAME "cRESQM2" OF oSection1 ALIAS "" TITLE TITSX3("QM2_RESP")[1]  	SIZE TamSx3("QM2_RESP")[1]

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 09/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Referencia cruzada. Instr.Utiizado(s) x Instrumento(s)   	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR100                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oSection1   := oReport:Section(1) 
Local cStrAnt     := ""
Local cStrEscAnt  := ""	
Local TRB_INSTR	
Local TRB_REVINS
Local TRB_PADSEC
Local TRB_ESCALA
Local TRB_PONTO	
Local TRB_FILQM2
Local TRB_REVQM2
Local TRB_DEPQM2
Local TRB_RESQM2
Local TRB_TIPQM2
Local TRB_DATA  
Local lFirst := .T.

dbSelectArea("QMS")
dbSetOrder(1)

MakeSqlExpr(oReport:uParam)
	
oSection1:BeginQuery()
BeginSQL alias  "TRB"


	SELECT QMS.QMS_FILIAL,QMS.QMS_PADSEC,QMS.QMS_INSTR,QMS.QMS_REVINS,QMS.QMS_DATA,QMS.QMS_ESCALA,QMS.QMS_PONTO,
	       QM2.QM2_FILIAL,QM2.QM2_INSTR,QM2.QM2_REVINS,QM2.QM2_RESP,QM2.QM2_DEPTO,QM2.QM2_TIPO,QM2.QM2_FABR 
	FROM %table:QMS% QMS, %table:QM2% QM2
	WHERE 
		QMS.QMS_FILIAL = %xFilial:QMS%  AND 
		QM2.QM2_FILIAL = QMS.QMS_FILIAL AND 
		QM2.QM2_INSTR  = QMS.QMS_PADSEC AND 
		QMS.QMS_PADSEC BetWeen %Exp:mv_par01% AND  %Exp:mv_par02% AND  
		QMS.QMS_DATA   BetWeen %Exp:Dtos(mv_par03)% AND %Exp:Dtos(mv_par04)% AND  
		QM2.QM2_DEPTO  BetWeen %Exp:mv_par05% AND %Exp:mv_par06% AND  				
		QM2.QM2_TIPO   BetWeen %Exp:mv_par12% AND %Exp:mv_par13% AND  
		QM2.QM2_RESP   BetWeen %Exp:mv_par14% AND %Exp:mv_par15% AND  
		QM2.QM2_FABR   BetWeen %Exp:mv_par16% AND %Exp:mv_par17% AND  
		QMS.%notDel% AND 
		QM2.%notDel% 
	ORDER BY QMS_FILIAL,QMS_PADSEC,QMS_REVINS,QMS_ESCALA,QMS_PONTO		
EndSql	
oSection1:EndQuery()

While ! Eof() 

	TRB_INSTR	:= TRB->QMS_INSTR
	TRB_REVINS	:= TRB->QMS_REVINS
	TRB_PADSEC	:= TRB->QMS_PADSEC
	TRB_ESCALA	:= TRB->QMS_ESCALA
	TRB_PONTO	:= TRB->QMS_PONTO
	TRB_FILQM2	:= TRB->QM2_FILIAL
	TRB_INSQM2	:= TRB->QM2_INSTR
	TRB_REVQM2	:= TRB->QM2_REVINS
	TRB_DEPQM2	:= TRB->QM2_DEPTO
	TRB_RESQM2	:= TRB->QM2_RESP
	TRB_TIPQM2	:= TRB->QM2_TIPO  
	TRB_DATA	:= DtoS(TRB->QMS_DATA)
	
	// Encontro o padrao secundario
	
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_PADSEC,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf

	If mv_par07 == 2
	//Verifico orgao calibrador interno
		If ! Calibrador(1,mv_par08,mv_par09,,,TRB_PADSEC,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf

	If mv_par07 == 3
	//	Verifico orgao calibrador externo
		If ! Calibrador(2,,,mv_par10,mv_par11,TRB_PADSEC,TRB_REVQM2)
			dbSkip()
			Loop
		EndIf
	EndIf

	If cStrAnt != TRB_PADSEC
        If !lFirst
			oReport:ThinLine()
	    Else
	        oSection1:Init()
	    EndIf
		
		cStrAnt := TRB_PADSEC
		oSection1:Cell("cPADSEC"):SetValue(cStrAnt)
	Else                                   
		oSection1:Cell("cPADSEC"):SetValue(" ")
	EndIf

	If cStrEscAnt != TRB_PADSEC+TRB_INSTR+TRB_ESCALA+TRB_PONTO
		lFirst := .F.
			        
		cStrEscAnt := TRB_PADSEC+TRB_INSTR+TRB_ESCALA+TRB_PONTO
		
		oSection1:Cell("cESCALA"):SetValue(TRB_ESCALA)
		oSection1:Cell("cPONTO"):SetValue(TRB_PONTO)
		oSection1:Cell("cTIPPS"):SetValue(TRB_TIPQM2)
		
		// Encontro o instrumento que est� utilizando o padrao secundario
	    
		oSection1:Cell("cINSTR"):SetValue(TRB_INSTR)
		oSection1:Cell("cREVINS"):SetValue(TRB_REVINS)
		oSection1:Cell("cTIPQM2"):SetValue(TRB_TIPQM2)
		oSection1:Cell("cDEPQM2"):SetValue(TRB_DEPQM2)
		oSection1:Cell("cRESQM2"):SetValue(TRB_RESQM2)
   		oSection1:PrintLine()
	EndIf
	
	dbSelectArea("TRB")	
  
	dbSkip()
	
EndDo

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTR100R3� Autor � Alessandro B. Freire  � Data � 01.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Referencia cruzada. Padrao Secundario por instrumento      ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTR100(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR100R3()                       
//��������������������������������������������������������������Ŀ
//� Define Variaveis 										     �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2		:= OemToAnsi(STR0002) // "cruzada entre padr�es secund�rios e instrumentos. "
Local cDesc3		:= ""
Local cString		:="QMS"
Local wnrel

Private titulo    := OemToAnsi(STR0003) // "Ref. Cruzada: Padrao Secundario x Instrumento"
Private cabec1 	:= OemToAnsi(STR0004) // "Padrao Secundario Escala           Ponto            Famila Pad. Sec. Instrumento      Rev Familia          Depto.    Resp.    "
Private cabec2    := ""

Private aReturn	:= {OemToAnsi(STR0005),1,OemToAnsi(STR0006),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog	:= "QMTR100"
Private nLastKey	:= 0
Private cPerg		:= "QMR100"
Private cTamanho := "G"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 							 �
//����������������������������������������������������������������
pergunte("QMR100",.F.)

//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros						      �
//� mv_par01				// Padrao Secundario Inicial			  �
//� mv_par02				// Padrao Secundario Final                �
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
wnrel:="QMTR100"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR100Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTR100IMP� Autor � Alessandro B.Freire   � Data � 29.08.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime REFERENCIA CRUZADA: PADR. SECUNDARIO x INSTRUMENTO ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTR100IMP(lEnd,wnRel,cString) 							  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd	  - A��o do Codeblock								  ���
���			 � wnRel   - T�tulo do relat�rio 							  ���
���			 � cString - Mensagem										  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTR100Imp(lEnd,wnRel,cString)

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
Local TRB_PADSEC
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
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("QMS")
dbSetOrder(2)

cChave	:= "QMS_FILIAL+QMS_PADSEC+QMS_REVINS+QMS_ESCALA+QMS_PONTO"
cQuery := "SELECT QMS_FILIAL,QMS_PADSEC,QMS_INSTR,QMS_REVINS,QMS_DATA,QMS_ESCALA,QMS_PONTO,"
cQuery += "QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_RESP,QM2_DEPTO,QM2_TIPO,QM2_FABR "
cQuery += "FROM "+RetSqlName("QMS")+" QMS, "
cQuery += RetSqlName("QM2")+" QM2 "
cQuery += "WHERE "
cQuery += "QMS.QMS_FILIAL = '"					+ xFilial("QMS")+		"' AND "
cQuery += "QMS.QMS_PADSEC  >= '"				+ mv_par01 +			"' AND " 
cQuery += "QMS.QMS_PADSEC  <= '"				+ mv_par02 +			"' AND " 
cQuery += "QMS.QMS_DATA BetWeen '"				+ Dtos(mv_par03) +		"' AND '" + Dtos(mv_par04) + 			"' AND " 
cQuery += "QM2.QM2_FILIAL = QMS.QMS_FILIAL "	+ " AND " 
cQuery += "QM2.QM2_INSTR  = QMS.QMS_PADSEC "	+ " AND "
cQuery += "QM2.QM2_DEPTO BetWeen '"				+ mv_par05 +			"' AND '" + mv_par06 + 			"' AND " 				
cQuery += "QM2.QM2_TIPO BetWeen '"				+ mv_par12 +			"' AND '" + mv_par13 + 			"' AND " 
cQuery += "QM2.QM2_RESP BetWeen '"				+ mv_par14 +			"' AND '" + mv_par15 + 			"' AND " 
cQuery += "QM2.QM2_FABR BetWeen '"				+ mv_par16 +			"' AND '" + mv_par17 + 			"' AND " 
cQuery += "QMS.D_E_L_E_T_= ' ' "				+ " AND "  +			"QM2.D_E_L_E_T_= ' ' "
cQuery += " ORDER BY " + SqlOrder(cChave)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
TcSetField("TRB","QMS_DATA","D",8,0)
dbSelectArea( "TRB" )

SetRegua(RecCount())

While ! Eof() 

	TRB_INSTR	:= TRB->QMS_INSTR
	TRB_REVINS	:= TRB->QMS_REVINS
	TRB_PADSEC	:= TRB->QMS_PADSEC
	TRB_ESCALA	:= TRB->QMS_ESCALA
	TRB_PONTO	:= TRB->QMS_PONTO
	TRB_FILQM2	:= TRB->QM2_FILIAL
	TRB_INSQM2	:= TRB->QM2_INSTR
	TRB_REVQM2	:= TRB->QM2_REVINS
	TRB_DEPQM2	:= TRB->QM2_DEPTO
	TRB_RESQM2	:= TRB->QM2_RESP
	TRB_FABQM2	:= TRB->QM2_FABR
	TRB_TIPQM2	:= TRB->QM2_TIPO  
	TRB_DATA	:= DtoS(TRB->QMS_DATA)
	
	IncRegua()
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0007) // "CANCELADO PELO OPERADOR"
		Exit
	ENDIF
	
		If mv_par07 == 1
			If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_PADSEC,TRB_REVQM2)
				dbSkip()
				Loop
			EndIf
		EndIf
	
		If mv_par07 == 2
		//Verifico orgao calibrador interno
			If ! Calibrador(1,mv_par08,mv_par09,,,TRB_PADSEC,TRB_REVQM2)
				dbSkip()
				Loop
			EndIf
		EndIf
	
		If mv_par07 == 3
		//	Verifico orgao calibrador externo
			If ! Calibrador(2,,,mv_par10,mv_par11,TRB_PADSEC,TRB_REVQM2)
				dbSkip()
				Loop
			EndIf
		EndIf
	
	/*
	          1 		2		  3			4 		  5			6		  7 	    8	   	  9		    0 		  1			2		  3 		4		  5		    6 		  7			8		  9 	    0			1
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Padrao Secundario           Escala                   Ponto                    Famila Pad. Sec.          Instrumento           Rev         Familia                  Departamento                Responsavel
	xxxxxxxxxxxxxxxx            xxxxxxxxxxxxxxxx         xxxxxxxxxxxxxxxx         xxxxxxxxxxxxxxxx          xxxxxxxxxxxxxxxx      xx          xxxxxxxxxxxxxxxx         xxxxxxxxxxxxx               xxxxxxxxxx
	*/
	
	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,ctamanho,IIF(aReturn[4]==1,15,18))
		lImpLinha := .F.
	EndIf
	
	If cStrAnt != TRB_PADSEC
		
		cStrAnt := TRB_PADSEC
		
		If lImpLinha
			@li,000 PSAY Repl("-",230)
			li++
		EndIf
		
		@li,000 PSAY TRB_PADSEC
		lImpLinha := .T.
	EndIf

	If cStrEscAnt != TRB_PADSEC+TRB_INSTR+TRB_ESCALA+TRB_PONTO
		
		cStrEscAnt := TRB_PADSEC+TRB_INSTR+TRB_ESCALA+TRB_PONTO
		
		@li,028 PSAY TRB_ESCALA
		@li,053 PSAY TRB_PONTO
		@li,078 PSAY TRB_TIPQM2
		
		@li,104 PSAY TRB_INSTR
		@li,126 PSAY TRB_REVINS
		@li,138 PSAY TRB_TIPQM2
		@li,163 PSAY TRB_DEPQM2
		@li,191 PSAY TRB_RESQM2
	
		li++

	EndIf
	
	dbSelectArea("TRB")	
	dbSkip()
	
EndDo

Roda( cbCont, cbTxt, ctamanho )

Set Device To Screen
If File(cIndex+OrdBagExt())
	Set Filter To
	RetIndex("QMS")
	dbClearInd()
	FErase(cIndex+OrdBagExt())
	dbCloseArea()
Else	
	dbSelectArea("TRB")
	dbCloseArea()
	dbSelectArea("QMS")
	dbSetOrder(1)
EndIf

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End

MS_FLUSH()