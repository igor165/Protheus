#INCLUDE "QMTR250.CH"


#DEFINE ETIQ_TIPO_PEQUENA 1
#DEFINE ETIQ_TIPO_GRANDE  2

#DEFINE DEPTO	 1
#DEFINE DATA    2
#DEFINE VALDATA 3
#DEFINE INSTR	 4

#DEFINE FORMATO_SEMANA 2

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTR250	� Autor � Antonio Aurelio       � Data � 14.12.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Etiqueta de Rastreabilidade            					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � QMTR250(cProg)                                			  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� 															  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGAQMT  												  ���
�������������������������������������������������������������������������Ĵ��
��� STR		 � Ultimo utilizado: 0011                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Function QMTR250()

Local cAlias      := Alias()
Local nOldOrder   := IndexOrd()
Local nRecNo      := RecNo()
Local  cPerg      := "QMR250"
Local cTamanho    := "P"

Private wnrel    := "QMTR250"
Private cString  := "QM2"
Private cDesc1   := STR0001 //"Ser�o impressas as etiquetas para instrumentos. "
Private cDesc2   := STR0002 //" "
Private cDesc3   := ""
Private cTitulo  := STR0003  // "Etiqueta para instrumentos"

//������������������������������������������������Ŀ
//� Vari�veis utilizadas pela fun��o SetDefault    �
//�  e SetPrint                                    �
//��������������������������������������������������
Private  aReturn  := {STR0004, 1,STR0005,  2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
Private  nLastKey := 0 
Private  nLimite  := 80

//���������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros								�
//� mv_par01				// Instrumento Inicial						�
//� mv_par02				// Instrumento Final 						�
//� mv_par03				// Periodo Inicial							�
//� mv_par04				// Periodo Final							�
//� mv_par05				// Departamento Inicial						�
//� mv_par06				// Departamento Final						�
//� mv_par07				// Orgao Calibrador Todos/Interno/Externo   �
//� mv_par08				// Org.Calib.Intr.Inicial					�
//� mv_par09				// Org.Calib.Intr.Final						�
//� mv_par10				// Org.Calib.Extr.Inicial					�
//� mv_par11				// Org.Calib.Extr.Final						�
//� mv_par12				// Familia Inicial                          �
//� mv_par13				// Familia Final							�
//� mv_par14				// Fabricante Inicial						�
//� mv_par15				// Fabricante Final							�
//� mv_par16				// Status de								�
//� mv_par17                // Status ate								�
//� mv_par18				// Usu�rio Inicial							�
//� mv_par19				// Usu�rio Final							�
//� mv_par20				// Tipo de Etiqueta							�
//�����������������������������������������������������������������������
Pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT 						 �
//����������������������������������������������������������������
wnrel := SetPrint(cString,wnrel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",,cTamanho)
// ,"",.F.)

//�������������������������������������Ŀ
//� Verifica se apertou o botao cancela �
//���������������������������������������
If nLastKey == 27
	Return
EndIf
	
SetDefault(aReturn,cString)

If nLastKey == 27
	Return .F.
EndIf

RptStatus({|| A250Imp() },cTitulo)

//�������������������������������������Ŀ
//� Restaura o DBF anterior             �
//���������������������������������������
dbSelectArea(cAlias)
dbSetOrder(nOldOrder)
dbGoto(nRecNo)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � A250Imp  � Autor � Antonio Aurelio       � Data � 04.05.99 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime as Etiquetas dos Produtos da Entrega               ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ��� 
���			 �	wnRel - Usada na funcao OurSpool						  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � 															  ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � QMTR250                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function A250Imp()

Local   nOrdQM2     := QM2->(IndexOrd())
Local   nOrdQM6     := QM6->(IndexOrd())
Local   nItem       := 0
Local   nCol        := 0
Local   cInstr      := ""
Local   cValData    := ""
Local   cData       := ""
Local   lImpPar     := .T.
Local   aInstr      := {}
Local   nIndex

Private cIndex		:= ""
Private nLin        := 80
Private	TRB_FILIAL
Private	TRB_INSTR	
Private	TRB_REVINS	
Private	TRB_VALDAF	
Private	TRB_DEPTO	
Private	TRB_TIPO	
Private	TRB_FABR	
Private	TRB_STATUS	
Private	TRB_RESP	
Private	TRB_USOINI	
lAbortPrint := .F.

QM2->(dbSetOrder(1)) // Instrumento + Revis�o Invertida
QM6->(dbSetOrder(2)) // Instrumento + Revis�o Invertida + Data Invertida

SetRegua(QM2->(RecCount()))

cChave := "QM2_FILIAL+QM2_INSTR+QM2_REVINV"
cQuery := "SELECT QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_REVINV,QM2_VALDAF,"
cQuery += "QM2_DEPTO,QM2_RESP,QM2_TIPO,QM2_FABR,QM2_STATUS,QM2_USOINI "
cQuery += "FROM "+RetSqlName("QM2")+" QM2 "					
cQuery += "WHERE "
cQuery += "QM2.QM2_FILIAL = '"			+xFilial("QM2")+	"' AND "
cQuery += "QM2.QM2_INSTR  BetWeen '"	+ mv_par01 +		"' AND '" + mv_par02 +			"' AND " 
cQuery += "QM2.QM2_VALDAF BetWeen '"	+ Dtos(mv_par03)+	"' AND '" + DtoS(mv_par04) +	"' AND "
cQuery += "QM2.QM2_DEPTO BetWeen '"		+ mv_par05 +		"' AND '" + mv_par06 + 			"' AND " 
cQuery += "QM2.QM2_TIPO BetWeen '"		+ mv_par12 +		"' AND '" + mv_par13 + 			"' AND " 
cQuery += "QM2.QM2_FABR BetWeen '"		+ mv_par14 +		"' AND '" + mv_par15 + 			"' AND " 
cQuery += "QM2.QM2_STATUS BetWeen '"	+ mv_par16 +		"' AND '" + mv_par17 + 			"' AND " 
cQuery += "QM2.QM2_RESP BetWeen '"		+ mv_par18 +		"' AND '" + mv_par19 + 			"' AND " 
cQuery += "QM2.D_E_L_E_T_= ' ' "
cQuery += "ORDER BY " + SqlOrder(cChave)
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRB",.T.,.T.)
TcSetField("TRB","QM2_VALDAF","D",8,0)
TcSetField("TRB","QM2_USOINI","D",8,0)
dbSelectArea( "TRB" )


While !Eof()
	
	cAlias		:= "TRB"
	TRB_FILIAL	:= TRB->QM2_FILIAL
	TRB_INSTR	:= TRB->QM2_INSTR
	TRB_REVINS	:= TRB->QM2_REVINS
	TRB_VALDAF	:= TRB->QM2_VALDAF
	TRB_DEPTO	:= TRB->QM2_DEPTO
	TRB_TIPO	:= TRB->QM2_TIPO
	TRB_FABR	:= TRB->QM2_FABR
	TRB_STATUS	:= TRB->QM2_STATUS
	TRB_RESP	:= TRB->QM2_RESP
	TRB_USOINI	:= TRB->QM2_USOINI

	IncRegua()
	
	If lAbortPrint
		If nLin <> 80
			nLin := nLin + 1
   	   @nLin,001 PSAY STR0007  //"CANCELADO PELO OPERADOR"
		EndIf
		Exit
	EndIf
	
	//��������������������������������������������������������������Ŀ
	//� Pula as revisoes anteriores do mesmo instrumento             �
	//����������������������������������������������������������������
	If TRB_FILIAL+TRB_INSTR == cInstr
		dbSkip()
		Loop 
	EndIf
	cInstr := TRB_FILIAL+TRB_INSTR

   //�����������������������������������������������������������������Ŀ
   //� Verifica se status do instrumento esta ativo                    �
   //�������������������������������������������������������������������
	If !QMTXSTAT(TRB_STATUS)
		dbskip()
		Loop
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par07 == 1 // Todos
		If !Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 2 // Interno
		If !Calibrador(1,mv_par08,mv_par09,,,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf

	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 3 // Externo
		If !Calibrador(2,,,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
			dbSkip()
			Loop
		EndIf
	EndIf

	
	QM6->(dbSeek(xFilial("QM6")+TRB_INSTR+TRB_REVINS))
	
	cValData := "  /  /  "
	cData		:= "  /  /  "	
	If QM6->(Found())
		//�����������������������������������������������������������������Ŀ
		//� A data de validade da calibra��o tem que ser a mesma.           �
		//�������������������������������������������������������������������
		If QM6->QM6_VALDAF == TRB_VALDAF
			cValData := IIf(mv_par21==FORMATO_SEMANA ,RetSem(QM6->QM6_VALDAF),;
																  DtoC(QM6->QM6_VALDAF) )
			cData		:= IIf(mv_par21==FORMATO_SEMANA ,RetSem(QM6->QM6_DATA),;
																	DtoC(QM6->QM6_DATA) )
		Else
			cValData := IIf(mv_par21==FORMATO_SEMANA, RetSem(TRB_VALDAF), ;
																	DtoC(TRB_VALDAF) )
			cData		:= IIf(mv_par21==FORMATO_SEMANA, RetSem(TRB_USOINI), ;
																	DtoC(TRB_VALDAF) )
		EndIf
	Else
		//�����������������������������������������������������������������Ŀ
		//� Se nao ocorreu calibracao � utilizado USOINI COMO DATA.         �
		//�������������������������������������������������������������������
		cValData := IIf(mv_par21==FORMATO_SEMANA, RetSem(TRB_VALDAF), ;
															   DtoC(TRB_VALDAF) )
		cData		:= IIf(mv_par21==FORMATO_SEMANA, RetSem(TRB_USOINI), ;
															   DtoC(TRB_USOINI) )
	EndIf
	
	aAdd(aInstr,{TRB_DEPTO, cData, cValData , TRB_INSTR})
	
	dbSelectArea("TRB")   
	cAlias := "TRB"
	dbSkip()
	
	If Len(aInstr) == 2 .Or. &(cAlias)->(Eof())
	For nItem := 1  To Len(aInstr)
		
		If nLin > 55
			@00,00 PSAY AvalImp(nLimite)
			nLin := -1 // vai para zero...
			nCol := 00
		Else
			nCol := 00
		EndIf
			
		If mv_par20 == ETIQ_TIPO_PEQUENA
			nlin := nlin+1
			@nLin,nCol    PSAY Padr(aInstr[nItem,DEPTO],16)
            If Len(aInstr) > nItem  // ...For�o a impress�o da pr�x. etiqueta...
				@nLin,nCol+36 PSAY Padr(aInstr[nItem+1,DEPTO],16)
            EndIf
			nCol := 0
		EndIf
		
		nlin := nlin+1
		@nLin,nCol    PSAY STR0010+" "+Padr(aInstr[nItem,DATA],16) // AFERIDO:
		
		If Len(aInstr) > nItem
			@nLin,nCol+36 PSAY STR0010+" "+Padr(aInstr[nItem+1,DATA],16)
		EndIf
		
		nlin := nlin+1
		@nLin,00 PSAY STR0011+" "+Padr(aInstr[nItem,VALDATA],16) // PROX.AF:
		
		If Len(aInstr)> nItem
			@nLin,36 PSAY STR0011+" "+Padr(aInstr[nItem+1,VALDATA],16)
		EndIf
		nlin := nlin+1
		@nLin,00 PSAY Padr(aInstr[nItem,INSTR],16)
		
		If Len(aInstr)>nItem
			@nLin,36 PSAY Padr(aInstr[nItem+1,INSTR],16)
		EndIf
		
		nlin := nlin+1
		@nLin,00 PSAY STR0012  // Ass.
		@nLin,36 PSAY STR0012
        nlin ++
		nItem:= nItem+1
	Next

	If mv_par20 == ETIQ_TIPO_GRANDE
		IIF(lImpPar,NIL,(nLin:=nlin+1))
	Else
		IIf(lImpPar,(nLin:=nlin+2),(nLin:=nlin+3))
	EndIf 
	lImpPar := !lImpPar

	aInstr := {}
	EndIf

EndDo

//��������������������������������������Ŀ
//� Caso algum tenha ficado pendente...  �
//����������������������������������������
If Len(aInstr) == 1 
	
	If nLin > 55
		@00,00 PSAY AvalImp(nLimite)
		nLin := -1 // vai para zero...
		nCol := 00
	Else
		nCol := 00
	EndIf
			
	If mv_par20 == ETIQ_TIPO_PEQUENA
		nlin := nlin+1
		@nLin,nCol    PSAY Padr(aInstr[1,DEPTO],16)
	EndIf
	
	nlin := nlin+1
	@nLin,nCol    PSAY STR0010+" "+Padr(aInstr[1,DATA],16) // AFERIDO:
	
	nlin := nlin+1
	@nLin,00 PSAY STR0011+" "+Padr(aInstr[1,VALDATA],16) // PROX.AF:
	
	nlin := nlin+1
	@nLin,00 PSAY Padr(aInstr[1,INSTR],16)
	
	nlin := nlin+1
	@nLin,00 PSAY STR0012  // Ass.
EndIf

Set Device To Screen

dbSelectArea("TRB")
dbCloseArea()
dbSelectArea("QM2")
dbSetOrder(1)		

If aReturn[5] == 1
	Set Printer To
	If nLin <> 80
		Ourspool(wnrel)
	Else
		MsgStop(OemToAnsi(STR0041), cTitulo)  // "N�o foram encontrados dados que atendam os crit�rios pedidos"
	EndIf
EndIf

MS_FLUSH()

QM2->(dbSetOrder(nOrdQM2))
QM6->(dbSetOrder(nOrdQM6))

Return(.T.)
