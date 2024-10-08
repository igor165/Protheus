
#INCLUDE "QMTR120.CH"
#Include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTR120  � Autor � Alessandro B. Freire  � Data � 01.07.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de resumo de calibra�oes                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMTR120(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL. 					  ���
�������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �	MOTIVO DA ALTERACAO					  ���
�������������������������������������������������������������������������Ĵ��
���Denis Martins �12/12/00�005948�Qdo o tipo de escala for calibrador/cali��� 
���              �        �      �brador completo, devera buscar unidade  ���
���              �        �      �de medida do QMG.                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR120()
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �                                                                 �
//����������������������������������������������������������������
Local cDesc1            := OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Resumo de  "
Local cDesc2            := OemToAnsi(STR0002) // "Calibra��es.                                      "
Local cDesc3            := ""
Local cString           :="QM7"
Local wnrel

Private titulo    := OemToAnsi(STR0003) // "Resumo de calibracoes"
Private cabec1  := OemToAnsi(STR0004) // "Instrumento      Rev. Data     Familia          Escala           Padrao           Erro Sistematico Incerteza Permitida Incerteza Encontrada Unidade de Medida Certificado  Laudo"
Private cabec2    := ""

Private aReturn := {OemToAnsi(STR0005),1,OemToAnsi(STR0006),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog        := "QMTR120"
Private nLastKey        := 0
Private cPerg           := "QMR120"
Private cTamanho := "G"

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("QMR120",.F.)

//�������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                              �
//� mv_par01                            // Instrumento Inicial        �
//� mv_par02                            // Instrumento Final          �
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
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:="QMTR120"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR120Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MTR120IMP� Autor � Alessandro B.Freire   � Data � 29.08.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime REFERENCIA CRUZADA: PADR. SECUNDARIO x INSTRUMENTO ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MTR120IMP(lEnd,wnRel,cString)                              ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd       - A��o do Codeblock                             ���
���          � wnRel   - T�tulo do relat�rio                              ���
���          � cString - Mensagem                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MTR120Imp(lEnd,wnRel,cString)

Local cStrAnt	:= ""
Local Tamanho	:= "G"
Local nOrder	:= 0
Local cFiltro	:= "",cUnimed := ""
Local CbCont
Local CbTxt
Local cApro		:=	GetMv("MV_QAPROV")
Local cRepro	:=	GetMv("MV_QREPRO")
Local cCondi	:=	GetMv("MV_QAPCON") 
Local cChave	:= "" 

Private	TRB_FILIAL
Private	TRB_INSTR
Private	TRB_REVINS
Private	TRB_DATA
Private	TRB_ESCALA	
Private	TRB_REVESC	
Private	TRB_PONTO	
Private	TRB_ERSIST	
Private	TRB_INCERT	
Private	TRB_NRCERT	
Private	TRB_DEPTO
Private	TRB_TIPO
Private	TRB_RESP
Private	TRB_FABR
Private	TRB_STATUS
Private TRB_RESULT
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt   := SPACE(10)
cbcont  := 0
li              := 80
m_pag   := 1

dbSelectArea("QM7")
dbSetOrder(1)
nOrder   := IndexOrd()

cChave := "QM7_FILIAL+QM7_INSTR+QM7_REVINS+QM7_DATA+QM7_ESCALA+QM7_REVESC+QM7_PONTO"
cFiltro:= "SELECT QM7_FILIAL,QM7_INSTR,QM7_DATA,QM7_REVINS,QM7_ESCALA,QM7_REVESC,"
cFiltro+= "QM7_PONTO,QM7_ERSIST,QM7_INCERT,QM7_NRCERT,QM7_RESULT,"
cFiltro+= "QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_STATUS,QM2_DEPTO,QM2_TIPO,QM2_FABR,QM2_RESP "		
cFiltro+= "FROM "+RetSqlName("QM7")+" QM7, "
cFiltro+= RetSqlName("QM2")+" QM2 "
cFiltro+= "WHERE "
cFiltro+= "QM7.QM7_FILIAL = '"	+xFilial("QM7")+	"' AND "
cFiltro+= "QM7.QM7_INSTR  >= '"	+ mv_par01 + "' AND " 
cFiltro+= "QM7.QM7_INSTR  <= '"	+ mv_par02 + "' AND " 
cFiltro+= "QM7.QM7_DATA >= '"	+ Dtos(mv_par03)+	"' AND " 
cFiltro+= "QM7.QM7_DATA <= '"	+ Dtos(mv_par04)+	"' AND " 
cFiltro+= "QM2.QM2_FILIAL = QM7.QM7_FILIAL AND "
cFiltro+= "QM2.QM2_INSTR  = QM7.QM7_INSTR  AND " 
cFiltro+= "QM2.QM2_REVINS = QM7.QM7_REVINS AND " 		
cFiltro+= "QM2.QM2_DEPTO >= '"	+ mv_par05 +	"' AND " 
cFiltro+= "QM2.QM2_DEPTO <= '"	+ mv_par06 +	"' AND " 
cFiltro+= "QM2.QM2_TIPO >= '"	+ mv_par12 +	"' AND " 
cFiltro+= "QM2.QM2_TIPO <= '"	+ mv_par13 +	"' AND " 
cFiltro+= "QM2.QM2_RESP >= '"	+ mv_par14 +	"' AND " 
cFiltro+= "QM2.QM2_RESP <= '"	+ mv_par15 +	"' AND " 
cFiltro+= "QM2.QM2_FABR >= '"	+ mv_par16 +	"' AND " 
cFiltro+= "QM2.QM2_FABR <= '"	+ mv_par17 +	"' AND " 
cFiltro+= "QM2.D_E_L_E_T_= ' ' AND QM7.D_E_L_E_T_= ' '"
cFiltro+= "ORDER BY " + SqlOrder(cChave)
		
cFiltro:= ChangeQuery(cFiltro)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB",.T.,.T.)
TcSetField("TRB","QM7_DATA","D",8,0)
dbSelectArea( "TRB" )				

If BOF() .and. EOF()
	Help(" ",1,"RECNO")
End

SetRegua(RecCount())

While ! Eof()

	TRB_FILIAL	:=	TRB->QM7_FILIAL
	TRB_INSTR	:=	TRB->QM7_INSTR
	TRB_REVINS	:=	TRB->QM7_REVINS
	TRB_DATA	:=	TRB->QM7_DATA
	TRB_ESCALA	:=	TRB->QM7_ESCALA
	TRB_REVESC	:=	TRB->QM7_REVESC
	TRB_PONTO	:=	TRB->QM7_PONTO
	TRB_ERSIST	:=	TRB->QM7_ERSIST
	TRB_INCERT	:=	TRB->QM7_INCERT
	TRB_NRCERT	:=	TRB->QM7_NRCERT 
	TRB_RESULT	:=	TRB->QM7_RESULT 

	IncRegua()
	
	If lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0008) // "CANCELADO PELO OPERADOR"
		Exit
	ENDIF
	
	//��������������������������������������������������������������Ŀ
	//� Procura no QM2 o instrumento informado no QM7                �
	//����������������������������������������������������������������
	dbSelectArea("QM2")
	dbSetOrder(1)
	dbSeek(xFilial("QM2")+TRB_INSTR+Inverte(TRB_REVINS))
	
	//��������������������������������������������������������������������������������Ŀ
	//� Procura no QM9 o instrumento informado no QM7
	//����������������������������������������������������������������������������������
	cUnimed := ""
	dbSelectArea("QM9")
	dbSetOrder(1)
	If dbSeek(xFilial("QM9")+TRB_ESCALA+Inverte(TRB_REVESC))
	   If QM9->QM9_TIPAFE $ "4|8" //Para tipos de Calibrador/Calibrador Completo (QMG)
	   	  dbSelectArea("QMG")
	      dbSetOrder(1)
	      dbSeek(xFilial("QMG")+TRB_INSTR+TRB_REVINS+TRB_PONTO)
	      cUnimed := QMG->QMG_UNIMED
	   Else
		  cUnimed := QM9->QM9_UNIMED
	   Endif	   
	Endif

	//��������������������������������������������������������������Ŀ
	//� Procura no QM6 o instrumento informado no QM7                �
	//����������������������������������������������������������������
	dbSelectArea("QM6")
	dbSetOrder(1)
	dbSeek(TRB_FILIAL+TRB_INSTR+TRB_REVINS+DTOS(TRB_DATA))
	
	//��������������������������������������������������������������Ŀ
	//� Procura a Descricao Resumida do Instrumento no SAH           �
	//����������������������������������������������������������������
	dbSelectArea("SAH")
	dbSetOrder(1)
	dbSeek(xFilial("SAH")+cUnimed)
	
	//��������������������������������������������������������������Ŀ
	//� Procura no QMR o instrumento e escala informados no QM7      �
	//����������������������������������������������������������������
	dbSelectArea("QMR")
	dbSetOrder(1)
	dbSeek(xFilial("QMR")+TRB_INSTR+TRB_REVINS+TRB_ESCALA)
	
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
			dbSelectArea("TRB")
			dbSkip()
			Loop
		EndIf
	EndIf
	
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09,,,TRB_INSTR,TRB_REVINS)
			dbSelectArea("TRB")
			dbSkip()
			Loop
		EndIf
	EndIf
	
	If mv_par07 == 3
		//Verifico orgao calibrador externo
		If ! Calibrador(2,,,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
			dbSelectArea("TRB")
			dbSkip()
			Loop
		EndIf
	EndIf
	
	dbSelectArea("TRB")
	TRB_DEPTO	:=	TRB->QM2_DEPTO
	TRB_TIPO	:=	TRB->QM2_TIPO
	TRB_RESP	:=	TRB->QM2_RESP
	TRB_FABR	:=	TRB->QM2_FABR
	TRB_STATUS	:=	TRB->QM2_STATUS

	//�����������������������������������������������������������������Ŀ
	//� Verifica se status do instrumento esta com atualiza ativo       �
	//�������������������������������������������������������������������
	If !QMTXSTAT(TRB_STATUS)
		dbskip()
		loop
	EndIf
	
	/*
	          1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22
	01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	0123456789012345 01   99/99/99   0123456789012345 0123456789012345 0123456789012345 0123456789       01234567            01234567890          012345678         012345678901 1
    Instrumento      Rev. Data       Familia          Escala           Padrao           Erro Sistematico     Incerteza Permitida     Incerteza Encontrada     Unidade de Medida     Certificado  Laudo/Escala    Laudo Final"
	*/
	
	If li > 58
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
	EndIf
	
	If cStrAnt  != TRB_INSTR + TRB_REVINS + DTOS(TRB_DATA)
		cStrAnt  := TRB_INSTR + TRB_REVINS + DTOS(TRB_DATA)
		@li,000 PSAY TRB_INSTR
		@li,017 PSAY TRB_REVINS
		@li,022 PSAY TRB_DATA
	EndIf
	
	@li,033 PSAY Substr(TRB_TIPO,1,16)
	@li,050 PSAY Substr(TRB_ESCALA,1,16)
	@li,067 PSAY Substr(TRB_PONTO,1,16)
	@li,084 PSAY TRB_ERSIST
	@li,105 PSAY QMR->QMR_INPERM
	@li,129 PSAY TRB_INCERT
	@li,154 PSAY SAH->AH_UMRES
	@li,176 PSAY TRB_NRCERT
	
	If TRB_RESULT == "A"
		@li,189 PSAY PADR(cApro,12) //Aprovado
	Else
		@li,189 PSAY PADR(cRepro,12) //Reprovado
	EndIf
	
	dbSelectArea("TRB")
	
	dbSkip()
	
	TRB_INSTR	:= TRB->QM7_INSTR
	TRB_REVINS	:= TRB->QM7_REVINS
	TRB_DATA	:= TRB->QM7_DATA   
	li++	
	
	If cStrAnt != TRB_INSTR + TRB_REVINS + DTOS(TRB_DATA)
		@li,084 PSAY QM6->QM6_ERSIST
		@li,129 PSAY QM6->QM6_INCERT
		Do Case
			Case QM6->QM6_LAUDO == "A"
				@li,205 PSAY PADR(cApro,16) // Aprovado
			Case QM6->QM6_LAUDO == "R"
				@li,205 PSAY PADR(cRepro,16) //Reprovado
			OtherWise
				@li,205 PSAY PADR(cCondi,16) //Condicional
		EndCase
		li++

		@li,000 PSAY __PrtThinLine()

		li++
	EndIf
	
EndDo

Roda( cbCont, cbTxt, Tamanho )

Set Device To Screen

dbSelectArea("TRB")
dbCloseArea()
RetIndex("QM7")
dbSetOrder(nOrder)

If aReturn[5] = 1
	Set Printer To
	dbCommitall()
	ourspool(wnrel)
End

MS_FLUSH()

