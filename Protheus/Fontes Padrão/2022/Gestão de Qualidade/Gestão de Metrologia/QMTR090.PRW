#INCLUDE "QMTR090.CH"
#INCLUDE "Protheus.CH"
#INCLUDE "Report.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �QMTR090   �Autor  �Leandro Sabino      � Data �  26/07/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Referencia cruzada. Instrumento x Padrao secundario        ���
���          � (Versao Relatorio Personalizavel)                          ���
�������������������������������������������������������������������������͹��
���Uso       � Generico                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                                            
Function QMTR090()
Local oReport

If TRepInUse()
	Pergunte("QMR090",.F.) 
    oReport := ReportDef()
    oReport:PrintDialog()
Else
    QMTR090R3()	// Executa vers�o anterior do fonte
EndIf

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � ReportDef()   � Autor � Leandro Sabino   � Data � 26/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montar a secao				                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportDef()				                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR090                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local ctitulo       := OemToAnsi(STR0003) // "Ref. Cruzada: Instrumento x Padrao Secundario"
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2		:= OemToAnsi(STR0002) // "cruzada entre instrumentos e pradr�es secund�rios."
Local oSection1  

DEFINE REPORT oReport NAME "QMTR090" TITLE cTitulo PARAMETER "QMR090" ACTION {|oReport| PrintReport(oReport)} DESCRIPTION (cDesc1+cDesc2)
oReport:SetLandscape(.T.)

DEFINE SECTION oSection1 OF oReport TABLES "QMS","QM2" Title OemToAnsi(STR0015) // Padrao Secundario
DEFINE CELL NAME "cSequencia"  OF oSection1 ALIAS "" TITLE SUBSTR(STR0017,1,AT(".",STR0017)-1) SIZE TamSx3("QM6_CSEQ")[1]
DEFINE CELL NAME "cINSTR"   OF oSection1 ALIAS "" TITLE STR0008 SIZE TamSx3("QMS_INSTR")[1] //"Instrumento"
DEFINE CELL NAME "cREVINS"  OF oSection1 ALIAS "" TITLE STR0009 SIZE TamSx3("QMS_REVINS")[1]//"Rev"
DEFINE CELL NAME "cTIPQM2"  OF oSection1 ALIAS "" TITLE STR0010 SIZE TamSx3("QM2_TIPO")[1]  //"Familia"
DEFINE CELL NAME "cDEPQM2"  OF oSection1 ALIAS "" TITLE STR0011 SIZE TamSx3("QM2_DEPTO")[1] //"Depto."
DEFINE CELL NAME "cRESQM2"  OF oSection1 ALIAS "" TITLE STR0012 SIZE TamSx3("QM2_RESP")[1]  //"Resp."
DEFINE CELL NAME "cTIPQMS"  OF oSection1 ALIAS "" TITLE STR0013 SIZE TamSx3("QM2_TIPO")[1]  //"Escala Pad.Sec."
DEFINE CELL NAME "cINSQM2"  OF oSection1 ALIAS "" TITLE STR0014 SIZE TamSx3("QM2_INSTR")[1] //"Ponto Pad. Sec."
DEFINE CELL NAME "cPONTO"   OF oSection1 ALIAS "" TITLE STR0015 SIZE TamSx3("QMS_PONTO")[1] //"Padrao Secundario"
DEFINE CELL NAME "cESCALA"  OF oSection1 ALIAS "" TITLE STR0016 SIZE TamSx3("QMS_ESCALA")[1]//"Famila Pad. Sec."

Return oReport

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � PrintReport   � Autor � Leandro Sabino   � Data � 19/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Rela�ao de Padroes a Calibrar 							  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � PrintReport(ExpO1)  	     	                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpO1 = Objeto oPrint                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � QMTR060                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                  
Static Function PrintReport(oReport) 
Local oSection1 := oReport:Section(1)
Local cStrAnt   := ""
Local cIndex
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
Local TRB_SEQU
Local TRB_ESKPAD
Local cAliasQry  := GetNextAlias()
Local cAliasQ11 := GetNextAlias()

cIndex	:= ""
cQuery  := ""
cChave  := ""

dbSelectArea("QMS")

MakeSqlExpr(oReport:uParam)
	

BeginSQL alias cAliasQ11 //"TRB"		

	SELECT   Q22.QM2_INSTR,Q22.QM2_TIPO
		FROM  %table:QMS% Q11,
	         %table:QM2% Q22
		WHERE Q22.QM2_INSTR = Q11.QMS_PADSEC
		ORDER BY QM2_FILIAL,QM2_INSTR
EndSql

BeginSQL alias cAliasQry//"TRB"		
	SELECT   QMS.QMS_FILIAL, QMS.QMS_INSTR , QMS.QMS_REVINS, QMS.QMS_DATA  , QMS.QMS_PADSEC, QMS.QMS_ESCALA, QMS.QMS_PONTO,
	         QMS.QMS_ESCPAD, QMS.QMS_CSEQ  , QM2.QM2_FILIAL, QM2.QM2_INSTR , QM2.QM2_REVINS, QM2.QM2_RESP  , QM2.QM2_DEPTO, 
	         QM2.QM2_TIPO  , QM2.QM2_FABR
	   FROM  %table:QMS% QMS,
	         %table:QM2% QM2
	   WHERE QMS.QMS_FILIAL = %xFilial:QMS% AND  
		     QM2.QM2_FILIAL = QMS.QMS_FILIAL AND  
		     QM2.QM2_INSTR  = QMS.QMS_INSTR  AND 
		     QM2.QM2_REVINS = QMS.QMS_REVINS AND   
		     QMS.QMS_INSTR BetWeen %Exp:mv_par01% AND %Exp:mv_par03% AND  
		     QMS.QMS_REVINS BetWeen %Exp:mv_par02% AND  %Exp:mv_par04% AND  
		     QMS.QMS_DATA BetWeen %Exp:Dtos(mv_par05)% AND %Exp:Dtos(mv_par06)% AND  
		     QM2.QM2_TIPO BetWeen %Exp:mv_par14% AND %Exp:mv_par15% AND  
		     QM2.QM2_RESP BetWeen %Exp:mv_par16% AND %Exp:mv_par17% AND  
		     QM2.QM2_FABR BetWeen %Exp:mv_par18% AND %Exp:mv_par19% AND  
		     QMS.%notDel% AND QM2.%notDel%

	   ORDER BY QMS_FILIAL,QMS_INSTR,QMS_REVINS,QMS_DATA,QMS_CSEQ

   	EndSql	
	
While !oReport:Cancel() .And. (!Eof())
If !Empty(AllTrim(oReport:Section(1):GetSqlExp("QM2")))
	If !(&(oReport:Section(1):GetSqlExp("QM2")))
		dbSkip()
		Loop
	Endif
EndIf 

If !Empty(AllTrim(oReport:Section(1):GetSqlExp("QMS")))
	If !(&(oReport:Section(1):GetSqlExp("QMS")))
		dbSkip()
		Loop
	Endif
EndIf 

TRB_INSTR	:= (cAliasQry)->QMS_INSTR
TRB_REVINS	:= (cAliasQry)->QMS_REVINS
TRB_PADSEC	:= (cAliasQry)->QMS_PADSEC
TRB_ESCALA	:= (cAliasQry)->QMS_ESCALA
TRB_PONTO	:= (cAliasQry)->QMS_PONTO
TRB_FILQM2	:= (cAliasQry)->QM2_FILIAL
TRB_INSQM2	:= (cAliasQry)->QM2_INSTR
TRB_REVQM2	:= (cAliasQry)->QM2_REVINS
TRB_DEPQM2	:= (cAliasQry)->QM2_DEPTO
TRB_RESQM2	:= (cAliasQry)->QM2_RESP
TRB_FABQM2	:= (cAliasQry)->QM2_FABR
TRB_TIPQM2	:= (cAliasQry)->QM2_TIPO
TRB_SEQU	:= (cAliasQry)->QMS_CSEQ 
TRB_ESKPAD	:= (cAliasQry)->QMS_ESCPAD


	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))
	dbSelectArea("QMS")   
	
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

    oSection1:Init()	

	If cStrAnt != (TRB_INSTR + TRB_REVINS + TRB_SEQU)
		
		cStrAnt := TRB_INSTR + TRB_REVINS + TRB_SEQU
		oSection1:Cell("cSequencia"):SetValue(TRB_SEQU)
		
		oSection1:Cell("cINSTR"):SetValue(TRB_INSTR)
		oSection1:Cell("cREVINS"):SetValue(TRB_REVINS)
		oSection1:Cell("cTIPQM2"):SetValue(TRB_TIPQM2)
		oSection1:Cell("cDEPQM2"):SetValue(TRB_DEPQM2)
		oSection1:Cell("cRESQM2"):SetValue(TRB_RESQM2) 			

		oSection1:Cell("cSequencia"):Show()
		oSection1:Cell("cINSTR"):Show()
		oSection1:Cell("cREVINS"):Show()
		oSection1:Cell("cTIPQM2"):Show()
		oSection1:Cell("cDEPQM2"):Show()
		oSection1:Cell("cRESQM2"):Show()
	Else
		oSection1:Cell("cSequencia"):Hide()
		oSection1:Cell("cINSTR"):Hide()
		oSection1:Cell("cREVINS"):Hide()
		oSection1:Cell("cTIPQM2"):Hide()
		oSection1:Cell("cDEPQM2"):Hide()
		oSection1:Cell("cRESQM2"):Hide()	
	EndIf
	

	// Encontro o padrao secundario
	dbSelectArea(cAliasQ11)
	While !Eof() 
		If TRB_PADSEC == (cAliasQ11)->QM2_INSTR
			TRB_TIPQM2 := (cAliasQ11)->QM2_TIPO					
			Exit
		Endif
		dbSkip()	
	Enddo           

	TRB_INSQM2 := TRB_PADSEC 

	oSection1:Cell("cTIPQMS"):SetValue(TRB_ESKPAD)
	oSection1:Cell("cINSQM2"):SetValue(TRB_PONTO)
	oSection1:Cell("cPONTO"):SetValue(TRB_INSQM2)
	oSection1:Cell("cESCALA"):SetValue(TRB_TIPQM2)
	
	oSection1:PrintLine()
	
	dbSelectArea(cAliasQry)

	dbSkip()
Enddo

oSection1:Finish()
                                              
(cAliasQry)->(DbCloseArea())
(cAliasQ11)->(DbCloseArea())


Return Nil 


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTR090r3� Autor � Alessandro B. Freire  � Data � 01.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Referencia cruzada. Instrumento x Padrao secundario        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTR090(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR090R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 											 �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2		:= OemToAnsi(STR0002) // "cruzada entre instrumentos e pradr�es secund�rios."
Local cDesc3		:= ""
Local cString		:="QM3"
Local wnrel

Private titulo    := OemToAnsi(STR0003) // "Ref. Cruzada: Instrumento x Padrao Secundario"
Private cabec1 	  := OemToAnsi(STR0004) // "Instrumento      Rev Familia          Depto.    Resp.    Escala Pad.Sec.  Ponto Pad. Sec.  Padrao Secundario Famila Pad. Sec."
Private cabec2    := ""

Private aReturn	:= {OemToAnsi(STR0005),1,OemToAnsi(STR0006),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog	:= "QMTR090"
Private nLastKey	:= 0
Private cPerg		:= "QMR090"
Private cTamanho := "M"

/*
1 		  2			3			 4 		  5			6			 7 		  8			9			 0 		  1			2			 3 		  4			5			 6 		  7			8			 9 		  0			1
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Instrumento      Rev Familia          Depto.    Resp.    Escala Pad.Sec.  Ponto Pad. Sec.  Padrao Secundario Famila Pad. Sec.
XXXXXXXXXXXXXXXX XX  XXXXXXXXXXXXXXXX XXXXXXXXX XXXXXXXX XXXXXXXXXXXXXXXX xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxx
*/

//�����������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 						  �
//�������������������������������������������������������������
pergunte("QMR090",.F.)

//�������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros				  �
//� mv_par01 : Instrumento de                             �
//� mv_par02 : Revisao de                                 �
//� mv_par03 : Instrumento ate                            �
//� mv_par04 : Revisao ate                                �
//� mv_par05 : Per�odo Inicial                            �
//� mv_par06 : Per�odo Final                              �
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
wnrel:="QMTR090"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR090Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTR090IMP� Autor � Alessandro B.Freire   � Data � 29.08.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime REFERENCIA CRUZADA: INSTRUMENTO x PADR. SECUNDARIO ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTR090IMP(lEnd,wnRel,cString)							  ���
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
Static Function MTR090Imp(lEnd,wnRel,cString)

Local CbCont
Local CbTxt
Local cStrAnt     := ""
Local lDivide     := .F.
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
Local TRB_SEQU
Local lImpr		:= .F.
Private cIndex	:= ""

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("QMS")

cChave	:= "QMS_FILIAL+QMS_INSTR+QMS_REVINS+QMS_DATA+QMS_CSEQ"
cQuery := "SELECT QMS_FILIAL,QMS_INSTR,QMS_REVINS,QMS_DATA,QMS_PADSEC,QMS_ESCALA,QMS_PONTO,QMS_CSEQ,"
cQuery += "QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_RESP,QM2_DEPTO,QM2_TIPO,QM2_FABR "
cQuery += "FROM "+RetSqlName("QMS")+" QMS, "
cQuery += RetSqlName("QM2")+" QM2 "
cQuery += "WHERE "
cQuery += "QMS.QMS_FILIAL = '"	+xFilial("QMS") +					"' AND "    
cQuery += "QMS.QMS_INSTR||QMS.QMS_REVINS  >= '"	+mv_par01+mv_par02+	"' AND " 
cQuery += "QMS.QMS_INSTR||QMS.QMS_REVINS  <= '"	+mv_par03+mv_par04+	"' AND " 
cQuery += "QMS.QMS_DATA BetWeen '"				+Dtos(mv_par05)   +	"' AND '" + Dtos(mv_par06) + "' AND " 
cQuery += "QM2.QM2_FILIAL = QMS.QMS_FILIAL "	+					" AND " 
cQuery += "QM2.QM2_INSTR  = QMS.QMS_INSTR "		+					" AND "
cQuery += "QM2.QM2_REVINS = QMS.QMS_REVINS "	+					" AND "
cQuery += "QM2.QM2_TIPO BetWeen '"				+ mv_par14 +		"' AND '" + mv_par15 + 			"' AND " 
cQuery += "QM2.QM2_RESP BetWeen '"				+ mv_par16 +		"' AND '" + mv_par17 + 			"' AND " 
cQuery += "QM2.QM2_FABR BetWeen '"				+ mv_par18 +		"' AND '" + mv_par19 + 			"' AND " 
cQuery += "QMS.D_E_L_E_T_= ' ' "				+					" AND "	  +"QM2.D_E_L_E_T_= ' ' "
cQuery += " ORDER BY " + SqlOrder(cChave)
cQuery := msparse(cQuery,Alltrim(TcGetDb()),.t.)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
TcSetField("TRB","QMS_DATA","D",8,0)
dbSelectArea( "TRB" )

SetRegua(RecCount())

While ! Eof()
	lImpr := .T. 

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
	TRB_SEQU	:= TRB->QMS_CSEQ

	IncRegua()
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0007) // "CANCELADO PELO OPERADOR"
		Exit
	ENDIF
	
	// Encontro o instrumento - Executa tambem em Top para AS/400 e CodeBase
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))
	dbSelectArea("QMS")
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
	          1 		2		  3			4 		  5			6		  7 		8		  9		    0 		  1			2		  3 	    4		  5		    6 		  7			8		  9 	    0		  1
	0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	Instrumento      Rev Familia          Depto.        Resp.      Escala Pad.Sec.  Ponto Pad. Sec.  Padrao Secundario Famila Pad. Sec.
	XXXXXXXXXXXXXXXX XX  XXXXXXXXXXXXXXXX XXXXXXXXXXXXX XXXXXXXXXX XXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXX xxxxxxxxxxxxxxxx  xxxxxxxxxxxxxxxx
	*/
	
	If cStrAnt != (TRB_INSTR + TRB_REVINS + TRB_SEQU)
		
		cStrAnt := TRB_INSTR + TRB_REVINS + TRB_SEQU
		If lDivide
			li++
			@li,00 PSAY Repl("-",132)
			li++
		Endif
		lDivide := .T.

		li++
	
		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,ctamanho,IIF(aReturn[4]==1,15,18))
			lDivide := .F.
		EndIf
		
		@li,000 PSAY "Sequencia..: "+TRB_SEQU
		li++
		li++		
		If li > 58
			cabec(titulo,cabec1,cabec2,nomeprog,ctamanho,IIF(aReturn[4]==1,15,18))
			lDivide := .F.
		EndIf
			                      
		@li,000 PSAY TRB_INSTR
		@li,017 PSAY TRB_REVINS
		@li,021 PSAY TRB_TIPQM2
		@li,038 PSAY TRB_DEPQM2
		@li,052 PSAY TRB_RESQM2
		
	EndIf
	
	// Encontro o padrao secundario
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek( TRB_FILQM2 + TRB_PADSEC )
	
	TRB_INSQM2 := QM2->QM2_INSTR            
	TRB_TIPQM2 := QM2->QM2_TIPO
	
	@li,063 PSAY TRB_ESCALA
	@li,080 PSAY TRB_PONTO
	@li,097 PSAY TRB_INSQM2
	@li,115 PSAY TRB_TIPQM2
	
	dbSelectArea("TRB")

	dbSkip()
	
	li++
	
EndDo

If lImpr
	@li,000 PSAY Repl("-",132)
	li++
	Roda( cbCont, cbTxt, cTamanho )
Endif	

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