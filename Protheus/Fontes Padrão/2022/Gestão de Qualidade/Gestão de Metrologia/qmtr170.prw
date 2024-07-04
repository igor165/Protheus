#INCLUDE "QMTR170.CH"
#INCLUDE "PROTHEUS.CH"


#Include "report.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTR170  � Autor � Cicero Cruz           � Data � 13.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Referencia cruzada  Instrumento x Cliente(s)               ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMTR170(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QMTR170()
Local oReport       
Private cAliasQM2 := "QM2"
  
If TRepInUse()
	// Interface de impressao
	oReport := ReportDef()
 	oReport:PrintDialog()
Else
	QMTR170R3()
EndIf

Return
         
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Cicero Cruz           � Data � 12.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QMTR210                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport 
Local oSection1
Local aOrdem    := {}
Local cPerg		:="QMR170"

/* Criacao do objeto REPORT
DEFINE REPORT oReport NAME <Nome do relatorio> ;
					  TITLE <Titulo> 		   ;
					  PARAMETER <Pergunte>     ;
					  ACTION <Bloco de codigo que sera executado na confirmacao da impressao> ;
					  DESCRIPTION <Descricao>
*/
DEFINE REPORT oReport NAME "QMTR170" TITLE STR0003 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION STR0001+" "+STR0002
oReport:SetPortrait()

aOrdem := {}
/*
Criacao do objeto secao utilizada pelo relatorio                               
DEFINE SECTION  <Nome> OF <Objeto TReport que a secao pertence>  ;
       TITLE  <Descricao da secao>                               ;
       TABLES <Tabelas a ser usadas>                             ;
       ORDERS <Array com as Ordens do relatorio>                 ;
       LOAD CELLS            									 ; // Carrega campos do SX3 como celulas
       TOTAL TEXT //Carrega ordens do Sindex
*/
DEFINE SECTION oSection OF oReport TITLE STR0014 TABLES "QM2" //ORDERS aOrdem

/*
DEFINE CELL NAME <Nome da celula do relatorio>                          ;
            OF <Objeto TSection que a secao pertence>                   ;
            ALIAS <Nome da tabela de referencia da celula>              ;
            TITLE <Titulo da celula>                                    ;
            Picture <Picture>                                           ;
            SIZE <Tamanho> 												;               
            PIXEL 														;//Informe se o tamanho esta em pixel 
            BLOCK <Bloco de codigo para impressao>
*/

DEFINE CELL NAME "QM2_INSTR"  OF oSection ALIAS "QM2" TITLE STR0014
DEFINE CELL NAME "QM2_DESCR"  OF oSection ALIAS "QM2" TITLE STR0015
DEFINE CELL NAME "QM2_FREQAF" OF oSection ALIAS "QM2" TITLE STR0016
DEFINE CELL NAME "QM2_VALDAF" OF oSection ALIAS "QM2" TITLE STR0017
DEFINE CELL NAME "QM2_STATUS" OF oSection ALIAS "QM2"
DEFINE CELL NAME "QM2_CLIE"   OF oSection ALIAS "QM2"
DEFINE CELL NAME "QM2_LOJA"   OF oSection ALIAS "QM2"
DEFINE CELL NAME "DESC"       OF oSection TITLE STR0018 BLOCK {|| Posicione("SA1",1,xFilial("SA1")+&(cAliasQM2+"->QM2_CLIE")+&(cAliasQM2+"->QM2_LOJA"),"A1_NOME") }  SIZE 50

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �PrintRepor� Autor � Cicero Cruz           � Data � 12.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao dos Textos	Reprogramacao R4	 				  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTr210													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport( oReport )
Local oSection1 := oReport:Section(1)  
Local cPerg		:= "QMR170"    
Local cCond     := '"'+Space(6)+'"'

Pergunte(cPerg,.F.)  


//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
   	MakeSqlExpr(oReport:uParam) 

//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
oSection1:BeginQuery()	

cAliasQM2 := GetNextAlias()

cChave := "% QM2_FILIAL, QM2_INSTR %"

BeginSql Alias cAliasQM2

SELECT QM2.QM2_FILIAL, QM2.QM2_INSTR, QM2.QM2_DESCR, QM2.QM2_CLIE, QM2.QM2_LOJA, QM2.QM2_VALDAF, QM2.QM2_FREQAF, QM2.QM2_STATUS
 	FROM %table:QM2% QM2
	WHERE QM2.QM2_FILIAL =  %xFilial:QM2%  AND 
		  QM2.QM2_INSTR     BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
		  QM2.QM2_STATUS    BETWEEN %Exp:mv_par03% AND %Exp:mv_par04% AND    
	      QM2.%notDel%		                
 		ORDER BY %Exp:cChave%	
EndSql     
oSection1:EndQuery()     

oSection1:SetLineCondition({|| ( QmtxStat(&(cAliasQM2+"->QM2_STATUS")) .And. !EMPTY(ALLTRIM(&(cAliasQM2+"->QM2_CLIE"))) )})

oSection1:Print()
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �QMTR170R3 � Autor � Denis Martins			� Data � 24.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Referencia cruzada  Instrumento x Cliente(s) - 17025       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTR170R3(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTR170R3  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR170R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis 											 �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Refer�ncia "
Local cDesc2		:= OemToAnsi(STR0002) // "cruzada entre instrumentos e clientes."
Local cDesc3		:= ""
Local cString		:="QM2"
Local wnrel

Private titulo		:= OemToAnsi(STR0003) // "Ref. Cruzada: Instrumento x Cliente"
Private cabec1		:= OemToAnsi(STR0004)+"                        "+OemToAnsi(STR0010) // "Instrumento       Descricao          			 Codigo  Loja Nome          						"
Private cabec2		:= ""

Private aReturn	:= {OemToAnsi(STR0005),1,OemToAnsi(STR0006),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog	:= "QMTR170"
Private nLastKey	:= 0
Private cPerg		:= "QMR170"
Private cTamanho	:= "M"

/*
1 		  2			3			 4 		  5			6			 7 		  8			9			 0 	
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Instrumento       Descricao          			 Codigo  Loja Nome          						
XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXX   XX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
*/


//�����������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 						  �
//�������������������������������������������������������������
pergunte("QMR170",.F.)

//�������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros				  �
//� mv_par01 : Instrumento de                             �
//� mv_par02 : Instrumento ate                            �
//���������������������������������������������������������

//�����������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT							�
//�������������������������������������������������������������������
wnrel:="QMTR170"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTR170Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTR170IMP� Autor � Denis Martins			� Data � 24.10.02 ���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Imprime REFERENCIA CRUZADA: INSTRUMENTO x CLIENTE          ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTR170IMP(lEnd,wnRel,cString)							  ���
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
Static Function MTR170Imp(lEnd,wnRel,cString)

Local CbCont
Local CbTxt
Local cStrAnt     := ""
Local lDivide     := .F.
Local cQuery
Local cChave
Local TRB_INSTR	
Local TRB_DESCR
Local TRB_CODIGO
Local TRB_LOJA
Local TRB_FREQAF  
Local TRB_VALDAF	
Local TRB_STATUS	

Local nIndex
Local lImpIns := .F.

Private cIndex := ""

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

dbSelectArea("QM2")

cChave := "QM2_FILIAL+QM2_INSTR"
cQuery := "SELECT QM2_FILIAL,QM2_INSTR,QM2_DESCR,QM2_CLIE,QM2_LOJA,QM2_VALDAF,QM2_FREQAF,QM2_STATUS "
cQuery += "FROM "+RetSqlName("QM2")+" QM2 "
cQuery += "WHERE "
cQuery += "QM2.QM2_FILIAL = '"			+xFilial("QM2")+	"' AND "
cQuery += "QM2.QM2_INSTR >= '"			+mv_par01+			"' AND " 
cQuery += "QM2.QM2_INSTR <= '"			+mv_par02+			"' AND " 
cQuery += "QM2.QM2_STATUS >= '"         +mv_par03+			"' AND "
cQuery += "QM2.QM2_STATUS <= '"         +mv_par04+			"' AND " 	
cQuery += "QM2.QM2_CLIE <> '"			+Space(6)+			"' AND "
cQuery += "QM2.D_E_L_E_T_= ' ' "
cQuery += " ORDER BY " + SqlOrder(cChave)

cQuery := ChangeQuery(cQuery) 
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
TcSetField("TRB","QM2_VALDAF","D",8,0)
dbSelectArea( "TRB" )

SetRegua(RecCount())

While ! Eof() 
	lImpIns := .T.

	TRB_INSTR	:= TRB->QM2_INSTR
	TRB_DESCR	:= TRB->QM2_DESCR
	TRB_CODIGO	:= TRB->QM2_CLIE
	TRB_LOJA	:= TRB->QM2_LOJA
	TRB_FREQAF  := TRB->QM2_FREQAF
	TRB_VALDAF	:= TRB->QM2_VALDAF
	TRB_STATUS	:= TRB->QM2_STATUS
	
	IncRegua()
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0007) // "CANCELADO PELO OPERADOR"
		Exit
	ENDIF
	
	//���������������������������������������������������������������
	//�Apresenta somente instrumento com status atualiza igua a SIM.�
	//���������������������������������������������������������������

	If !QmtxStat(TRB_STATUS)
		dbSkip()
		Loop
	Endif

	If li > 54
		cabec(titulo,cabec1,cabec2,nomeprog,ctamanho,IIF(aReturn[4]==1,15,18))
		lDivide := .F.
	EndIf
	
/*
		  1 		2	  	  3		    4 		  5		    6		  7 		8		  9		    0 	      1         2         3
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
Instrumento       Descricao          			   Freq   Val.Calib.  Status. Codigo  Loja  Nome          						
XXXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXX   XX/XX/XXXX    X     XXXXXX   XX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 
*/

	If cStrAnt != TRB_INSTR 
		
		cStrAnt := TRB_INSTR
		If lDivide
			li++
			@li,00 PSAY __PrtThinLine()
			li++
		Endif
		lDivide := .T.
		
		@li,000 PSAY TRB_INSTR
		@li,018 PSAY TRB_DESCR
		@li,051 PSAY TRB_FREQAF
		@li,058 PSAY TRB_VALDAF
		@li,072 PSAY TRB_STATUS
		@li,078 PSAY TRB_CODIGO
		@li,087 PSAY TRB_LOJA

		//�������������������������������������������������Ŀ
		//�Localiza Cliente/Loja e imprime o nome do cliente�
		//���������������������������������������������������

		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+TRB_CODIGO+TRB_LOJA)
			@li,092 PSAY SA1->A1_NOME
		Else
			@li,092 PSAY OemToAnsi(STR0009) //"Cliente/Loja nao encontrado..."
		Endif	
	EndIf
	
	dbSelectArea("TRB")
	dbSkip()
	
	li++
EndDo

If lImpIns //Forca impressao da ultima line (tracos)
	li++
	@li,00 PSAY __PrtThinLine()
Endif	

If File(cIndex+OrdBagExt())
	Set Filter To
	RetIndex("QM2") 
	dbClearInd()
	FErase(cIndex+OrdBagExt())
	dbCloseArea()
Else	
	dbSelectArea("TRB")
	dbCloseArea()
	dbSelectArea("QM2")
	dbSetOrder(1)
EndIf

Roda( cbCont, cbTxt, cTamanho )
Set Device To Screen
If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End

MS_FLUSH()

