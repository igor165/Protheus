#INCLUDE "QMTR070.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "REPORT.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � QMTR070  � Autor � Cicero Cruz           � Data � 28.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio Calibracoes Previstas e Nao-Realizadas           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � QMTR070(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function QMTR070()
Local oReport    
Private aInstr    := {}    
Private cAliasQM2 := "QM2" 
Private nTotPrev  := 0
Private nTotMes   := 0
Private nTotReal  := 0
Private nTm 	  := 1

If TRepInUse()
	// Interface de impressao
	oReport := ReportDef()
 	oReport:PrintDialog()
Else
	QMTR070R3()
EndIf    

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Cicero Cruz           � Data � 28.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � QMTR070                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()
Local oReport 
Local oSection1
Local aOrdem    := {}
Local cPerg		:="QMR070"      

DEFINE REPORT oReport NAME "QMTR070" TITLE STR0004 PARAMETER cPerg ACTION {|oReport| PrintReport(oReport)} DESCRIPTION STR0001+ " " + STR0002+ " " + STR0003 // "Relatorio de Instrumentos a Calibrar" ### "Este programa ir� emitir a rela��o de" ### "instrumentos a calibrar."
	   
aOrdem := {	STR0009,; 	// "Departamento"
		    STR0008}  	// "Instrumento"

DEFINE SECTION oSection1 OF oReport   TITLE OemToAnsi(STR0024) TABLES "QM2" ORDERS aOrdem

DEFINE CELL NAME "QM2_INSTR"   	OF oSection1 ALIAS "QM2"
DEFINE CELL NAME "QM2_REVINS"  	OF oSection1 ALIAS "QM2"
DEFINE CELL NAME "QM2_TIPO"    	OF oSection1 ALIAS "QM2"
DEFINE CELL NAME "QM2_DEPTO"   	OF oSection1 ALIAS "QM2"
DEFINE CELL NAME "QM2_RESP"    	OF oSection1 ALIAS "QM2"	SIZE  30								BLOCK {|| Posicione("QAA",1,xFilial("QAA")+QM2_RESP,"QAA_NOME")}
DEFINE CELL NAME "QM2_FREQAF"  	OF oSection1 ALIAS "QM2" 	SIZE   3 TITLE STR0016+CRLF+STR0017  // "Freq" ### "Dias" 
DEFINE CELL NAME "QM2_FABR"    	OF oSection1 ALIAS "QM2"
DEFINE CELL NAME "ORGCAL"      	OF oSection1             	SIZE  15 TITLE STR0018+CRLF+STR0019    	BLOCK {|| Iif ( mv_par07 == 3 .OR. ( mv_par07 == 1 .AND. QM9->QM9_ORGAFE == "E" ),;
																										QM9->QM9_LABOR,;
	     																							   	Iif ( mv_par07 == 2 .OR. ( mv_par07 == 1 .AND. QM9->QM9_ORGAFE == "I" ),QM9->QM9_DEPTO, "")) } //"Orgao" ### "Calibrador"
DEFINE CELL NAME "QM2_VALDAF"  	OF oSection1 ALIAS "QM2"

DEFINE SECTION oSection2 OF oReport   TITLE OemToAnsi(STR0025) LINE STYLE 

DEFINE CELL NAME "TOT1"  		OF oSection2             	SIZE  55 TITLE STR0020 CELL BREAK  BLOCK {|| Str( nTotPrev,4 )}    // "Total Previsto no Periodo   "
DEFINE CELL NAME "TOT2"  		OF oSection2         	  	SIZE  55 TITLE STR0021 CELL BREAK  BLOCK {|| Str( nTotReal,4 )}    // "Total Realizado no Periodo  " 
DEFINE CELL NAME "TOT3"  		OF oSection2           		SIZE  55 TITLE STR0022 CELL BREAK  BLOCK {|| Str((100*nTotPrev)/(nTotPrev+nTotReal),6,2) + "%"} // "Previstas e nao Realizadas  "
DEFINE CELL NAME "TOT4"  		OF oSection2          	  	SIZE  55 TITLE STR0023 CELL BREAK  BLOCK {|| Str( nTotMes,4 )}    // "Total Previsto no Mes Final "

Return oReport

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao	 �PrintRepor� Autor � Cicero Cruz           � Data � 12.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao R4	 		                            		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QMTR070													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PrintReport( oReport )
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local cPerg		:= "QMR070"    
Local cOrdem    := ""

Pergunte(cPerg,.F.)           


//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
   	MakeSqlExpr(oReport:uParam) 

//������������������������������������������������������������������������Ŀ
//�Query do relatorio da secao 1                                           �
//��������������������������������������������������������������������������

BEGIN REPORT QUERY oSection1

cAliasQM2 := GetNextAlias()

Do Case
	Case oSection1:GetOrder() == 1
		cOrdem := '%1, 11, 2, 4%'
   	Case oSection1:GetOrder() == 2                          
   		cOrdem := '%1, 2, 4%'
EndCase 

BeginSql Alias cAliasQM2

SELECT QM2.QM2_FILIAL, QM2.QM2_INSTR , QM2.QM2_REVINS, QM2.QM2_REVINV, QM2.QM2_STATUS, 
       QM2.QM2_VALDAF, QM2.QM2_FREQAF, QM2.QM2_RESP  , QM2.QM2_FABR  , QM2.QM2_LAUDO ,   
       QM2.QM2_DEPTO , QM2.QM2_TIPO  , QM2.QM2_LOCAL 
 	FROM %table:QM2% QM2 	
	WHERE QM2.QM2_FILIAL = %xFilial:QM2% AND 
		  QM2.QM2_INSTR  	BETWEEN %Exp:mv_par01% AND %Exp:mv_par02% AND
	      QM2.QM2_DEPTO  	BETWEEN %Exp:mv_par05% AND %Exp:mv_par06% AND         
	      QM2.QM2_TIPO   	BETWEEN %Exp:mv_par20% AND %Exp:mv_par21% AND
	      QM2.QM2_FABR   	BETWEEN %Exp:mv_par14% AND %Exp:mv_par15% AND
	      QM2.QM2_STATUS 	BETWEEN %Exp:mv_par16% AND %Exp:mv_par17% AND
	      QM2.QM2_RESP  	BETWEEN %Exp:mv_par12% AND %Exp:mv_par13% AND   
	      QM2.QM2_FLAG  	= '1' 	AND 
	      QM2.%notDel%  		 
	ORDER BY %Exp:cOrdem%  
 			
EndSql   
END REPORT QUERY oSection1

dbGoTop()

While !oReport:Cancel() .And. (cAliasQM2)->(!Eof())
	If !Empty(aInstr)
		If Ascan(aInstr, {|x| x[1] == &(cAliasQM2+"->QM2_FILIAL")+&(cAliasQM2+"->QM2_INSTR")}) > 0
			lRet := .F.
		Else	
			Aadd(aInstr,{	&(cAliasQM2+"->QM2_FILIAL"),&(cAliasQM2+"->QM2_INSTR") ,&(cAliasQM2+"->QM2_REVINS"),&(cAliasQM2+"->QM2_REVINV"),&(cAliasQM2+"->QM2_STATUS"),;
			             	&(cAliasQM2+"->QM2_FREQAF"),&(cAliasQM2+"->QM2_RESP")  ,&(cAliasQM2+"->QM2_FABR")  ,&(cAliasQM2+"->QM2_LAUDO") ,&(cAliasQM2+"->QM2_DEPTO") ,;
		                    &(cAliasQM2+"->QM2_TIPO")  ,&(cAliasQM2+"->QM2_VALDAF"),&(cAliasQM2+"->QM2_LOCAL")  })
		EndIf
	Else 
		Aadd(aInstr,{	&(cAliasQM2+"->QM2_FILIAL"),&(cAliasQM2+"->QM2_INSTR") ,&(cAliasQM2+"->QM2_REVINS"),&(cAliasQM2+"->QM2_REVINV"),&(cAliasQM2+"->QM2_STATUS"),;
		             	&(cAliasQM2+"->QM2_FREQAF"),&(cAliasQM2+"->QM2_RESP")  ,&(cAliasQM2+"->QM2_FABR")  ,&(cAliasQM2+"->QM2_LAUDO") ,&(cAliasQM2+"->QM2_DEPTO") ,;
	                    &(cAliasQM2+"->QM2_TIPO")  ,&(cAliasQM2+"->QM2_VALDAF"),&(cAliasQM2+"->QM2_LOCAL")  })
	Endif	
	(cAliasQM2)->(dbSkip())
Enddo

oSection1:SetLineCondition({|| MTR070_CS1(oReport)})  
oSection1:Print() 
oSection2:Init()
If mv_par18 <> 1
	oSection2:Cell("TOT4"):Hide()
EndIf
MTR070_CS2(oReport)
oSection2:PrintLine()
oSection2:Finish()
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �MTR070_CS1� Autor � Cicero Cruz			� Data � 25.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Condicao de impress�o da Linha                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTR070_CS1(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MTR070_CS1(oReport)
Local oSection2 := oReport:Section(2)
Local lRet := .T.    
Local lOk := .F.

//������������������������������������������������������������Ŀ
//�Caso o instrumento seja o mesmo que o anterior nao impri-lo.�
//��������������������������������������������������������������
/*
While !Eof()
	If !Empty(aInstr)
		If Ascan(aInstr, {|x| x[1] == &(cAliasQM2+"->QM2_FILIAL")+&(cAliasQM2+"->QM2_INSTR")}) > 0
			lRet := .F.
		Else	
			Aadd(aInstr,{	&(cAliasQM2+"->QM2_FILIAL"),&(cAliasQM2+"->QM2_INSTR") ,&(cAliasQM2+"->QM2_REVINS"),&(cAliasQM2+"->QM2_REVINV"),&(cAliasQM2+"->QM2_STATUS"),;
			             	&(cAliasQM2+"->QM2_FREQAF"),&(cAliasQM2+"->QM2_RESP")  ,&(cAliasQM2+"->QM2_FABR")  ,&(cAliasQM2+"->QM2_LAUDO") ,&(cAliasQM2+"->QM2_DEPTO") ,;
		                    &(cAliasQM2+"->QM2_TIPO")  ,&(cAliasQM2+"->QM2_VALDAF"),&(cAliasQM2+"->QM2_LOCAL")  })
		EndIf
	Else 
		Aadd(aInstr,{	&(cAliasQM2+"->QM2_FILIAL"),&(cAliasQM2+"->QM2_INSTR") ,&(cAliasQM2+"->QM2_REVINS"),&(cAliasQM2+"->QM2_REVINV"),&(cAliasQM2+"->QM2_STATUS"),;
		             	&(cAliasQM2+"->QM2_FREQAF"),&(cAliasQM2+"->QM2_RESP")  ,&(cAliasQM2+"->QM2_FABR")  ,&(cAliasQM2+"->QM2_LAUDO") ,&(cAliasQM2+"->QM2_DEPTO") ,;
	                    &(cAliasQM2+"->QM2_TIPO")  ,&(cAliasQM2+"->QM2_VALDAF"),&(cAliasQM2+"->QM2_LOCAL")  })
	Endif	
	dbSkip()
Enddo
*/
//�����������������������������������������������������������������Ŀ
//� Verifica se status do instrumento esta ativo                    �
//�������������������������������������������������������������������
If !QMTXSTAT(&(cAliasQM2+"->QM2_STATUS")) .AND. lRet
	lRet := .F.
EndIf

If DTOS(&(cAliasQM2+"->QM2_VALDAF")) < DTOS(MV_PAR03) .OR. DTOS(&(cAliasQM2+"->QM2_VALDAF")) > DTOS(MV_PAR04)	 .AND. lRet			
	lRet := .F.
Endif	

//�����������������������������������������������������������������Ŀ
//� Verifico O.C. interno e externo                                 �
//�������������������������������������������������������������������
If mv_par07 == 1 .AND. lRet
	If !Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
	   lRet := .F.
	EndIf
EndIf

//�����������������������������������������������������������������Ŀ
//� Verifico O.C. interno                                           �
//�������������������������������������������������������������������
If mv_par07 == 2 .AND. lRet
	If !Calibrador(1,mv_par08,mv_par09,,,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS")) .AND. lRet
	   lRet := .F.
	Endif
EndIf

//�����������������������������������������������������������������Ŀ
//� Verifico O.C. externo                                           �
//�������������������������������������������������������������������
If mv_par07 == 3 .AND. lRet
	If ! Calibrador(2,,,mv_par10,mv_par11,&(cAliasQM2+"->QM2_INSTR"),&(cAliasQM2+"->QM2_REVINS"))
	   lRet := .F.
	EndIf
EndIf

Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 �MTR070_CS2� Autor � Cicero Cruz			� Data � 25.07.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Condicao de impress�o da Linha                             ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTR070_CS2(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MTR070_CS2(oReport)
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(2)
Local lRet := .T.
Local lOk := .F.
Local cInstrQM6 := ""
Local cStrAnt   := ""
Local cIndiceQM6	:= CriaTrab(NIL,.F.)
Local nIndiceQM6	:= 0
Local cChaveQM6		:= "QM6_FILIAL+QM6_INSTR+QM6_DATINV"
Local cFiltroQM6	:= ""

If oSection1:GetOrder() == 2
	aSort(aInstr,,,{|x,y| x[10] < y[10]}) 				// Sort de Departamento
Else
	aSort(aInstr,,,{|x,y| x[2]+x[3] < y[2]+y[3]})  	// Sort de Instrumento
Endif

dbSelectArea("QM6")

cFiltroQM6 := 'QM6_FILIAL=="'+xFilial("QM6")+'".AND.DtoS(QM6_DTPREV) >= "'+DtoS(MV_PAR03)+'".AND.DtoS(QM6_DTPREV) <= "'+DtoS(MV_PAR04)+'"'
cFiltroQM6 += '.AND.QM6_INSTR >= "'+MV_PAR01+'".AND.QM6_INSTR <= "'+MV_PAR02+'"'
cFiltroQM6 += '.AND.DtoS(QM6_DATA) >= "'+DtoS(MV_PAR03)+'".AND.DtoS(QM6_DATA) <= "'+DtoS(MV_PAR04)+'"'
IndRegua("QM6",cIndiceQM6,cChaveQM6,,cFiltroQM6,OemToAnsi(STR0010)) // Selecionando Registros. . .
nIndiceQM6 := RetIndex("QM6")

dbSetOrder(nIndiceQM6+1)
dbGoTop()

cInstrQM6 := ""
//Deve-se considerar o instrumento apenas uma unica vez...
While QM6->(!Eof())
	If QM6->QM6_FILIAL+QM6->QM6_INSTR <> cInstrQM6
		nTotReal ++
	Endif
	cInstrQM6 := QM6->QM6_FILIAL+QM6->QM6_INSTR
	QM6->(dbSkip())
Enddo

dbSelectArea("QM6")
dbSetOrder(1)
dbGoTop()

cFiltroQM6 := 'QM6_FILIAL=="'+xFilial("QM6")+'".AND.QM6_INSTR >= "'+MV_PAR01+'".AND.QM6_INSTR <= "'+MV_PAR02+'"'
cFiltroQM6 += '.AND.DtoS(QM6_DATA) >= "'+DtoS(MV_PAR03)+'".AND.DtoS(QM6_DATA) <= "'+DtoS(MV_PAR04)+'"'
IndRegua("QM6",cIndiceQM6,cChaveQM6,,cFiltroQM6,OemToAnsi(STR0010)) // Selecionando Registros. . .
nIndiceQM6 := RetIndex("QM6")

dbSetOrder(nIndiceQM6+1)
dbGoTop()

While nTm <= Len(aInstr) .AND. !EMPTY(aInstr)
	
	//������������������������������������������������������������Ŀ
	//�Caso o instrumento seja o mesmo que o anterior nao impri-lo.�
	//��������������������������������������������������������������
	
	If Alltrim(aInstr[nTm][2]) == Alltrim(cStrAnt)
		nTm++
		Loop
	EndIf
	cStrAnt := aInstr[nTm][2]
	
	If DtoS(aInstr[nTm][12]) < DtoS(mv_par03) .or. DtoS(aInstr[nTm][12]) > DtoS(mv_par04)
		nTm++
		Loop
	Endif
	//�����������������������������������������������������������������Ŀ
	//� Verifica se status do instrumento esta ativo                    �
	//�������������������������������������������������������������������
	If !QMTXSTAT(aInstr[nTm][5])
		nTm++
		loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,aInstr[nTm][2],aInstr[nTm][3])
			nTm++
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09,,,aInstr[nTm][2],aInstr[nTm][3])
			nTm++
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 3
		If ! Calibrador(2,,,mv_par10,mv_par11,aInstr[nTm][2],aInstr[nTm][3])
			nTm++
			Loop
		EndIf
	EndIf
	
	// ����������������������������������������������������������������������Ŀ
	// �Verifica validacao mensal:											  �
	// �Para validade de afericao no mesmo mes, a previsao ainda nao venceu   �
	// �portanto, nao deve ser impresso.									  �
	// ������������������������������������������������������������������������
	If mv_par18 == 1
		If SubStr(DtoS(aInstr[nTm][12]),1,6) < SubStr(DtoS(mv_par03),1,6)
			nTm++
			Loop
		EndIf
		
		If SubStr(DtoS(aInstr[nTm][12]),1,6) > SubStr(DtoS(mv_par04),1,6)
			nTm++
			Loop
		EndIf
		
		// Somo aos previstos. Nao somo aos nao realizados porque esta dentro
		// do mesmo mes, mas devo somar aos previstos porque esta dentro do mes
		// de previsao.
		// Somo tambem aos previstos no mes final, pois inclui no linha totalizadora
		
		If SubStr(DtoS(aInstr[nTm][12]),1,6) == SubStr(DtoS(mv_par04),1,6)
			nTotPrev++
			nTotMes++
			nTm++
			Loop
		EndIf
		
		// Somo realizado
		dbSelectArea("QM6")
		dbSetOrder(nIndiceQM6+1)
		If !dbSeek(aInstr[nTm][1]+aInstr[nTm][2]+aInstr[nTm][3])
			nTotPrev++
			lOk := .F.
		Else
			lOk := .F.
			While !Eof() .and. QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS ==;
				aInstr[nTm][1]+aInstr[nTm][2]+aInstr[nTm][3]
				If Year(QM6->QM6_DATA) == Year(aInstr[nTm][12])
					If Month(QM6->QM6_DATA) == Month(aInstr[nTm][12])
						lOk := .F.
						Exit
					Endif
				Else
					If Year(QM6->QM6_DATA) > Year(aInstr[nTm][12]) .or. Year(QM6->QM6_DATA) < Year(aInstr[nTm][12])
						//Nao somo aos realizados pq ja filtrei os realizados no arquivo temporario - vide comentarios no inicio do fonte
						lOk := .T.
						Exit
					Endif
				Endif
				dbSkip()
			Enddo
		Endif
		dbSelectArea(cAliasQM2)

		If lOk
			nTm++
			Loop
		EndIf
	EndIf
	
	// verifica validade por dia
	If mv_par18 == 2
		
		lOk := .F.
		If aInstr[nTm][12] >= mv_par03 .and.;
			aInstr[nTm][12] <= mv_par04
			// Somo a quantidade de dias para verificar se
			// est� dentro do per�odo
			If (aInstr[nTm][12]+mv_par19) < mv_par03
				nTm++
				Loop
			EndIf
			
			// Somo a quantidade de dias para verificar se est� dentro
			// do per�odo
			If aInstr[nTm][12] + mv_par19 > mv_par04
				nTm++
				Loop
			EndIf			
			
			// Verifico se existe realizado
			dbSelectArea("QM6")
			dbSetOrder(nIndiceQM6+1)
			If dbSeek(aInstr[nTm][1]+aInstr[nTm][2]+aInstr[nTm][3])
				lOk := .F.
				While !Eof() .and. QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS ==;
					aInstr[nTm][1]+aInstr[nTm][2]+aInstr[nTm][3]
					If Year(QM6->QM6_DATA) == Year(aInstr[nTm][12])
						If Month(QM6->QM6_DATA) == Month(aInstr[nTm][12])
							lOk := .F.
							Exit
						Endif
					Else
						If Year(QM6->QM6_DATA) > Year(aInstr[nTm][12]) .or. Year(QM6->QM6_DATA) < Year(aInstr[nTm][12])
							//Nao somo aos realizados pq ja filtrei os realizados no arquivo temporario - vide comentarios no inicio do fonte
							lOk := .T.
							Exit
						Endif
					Endif
					dbSkip()
				Enddo
			Else
				lOk := .F.
				nTotPrev ++
			EndIf
		EndIf

		dbSelectArea(cAliasQM2)
		
		If lOk
			nTm++
			lOk := .F.
			Loop
		EndIf
		
	EndIf
	nTm++
Enddo
Return lRet

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � QMTR070R3� Autor � Alessandro B. Freire  � Data � 23.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calibracoes Previstas e nao realizadas 					  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QMTR070R3(void)											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � Generico 												  ���
�������������������������������������������������������������������������Ĵ��
���			ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.			  ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data	� BOPS �  Motivo da Alteracao 					  ���
�������������������������������������������������������������������������Ĵ��
���Antonio     �19/07/99�22057 � Parametro de, ate para Status            ��� 
���Denis       �10/01/01�Melhor� Passar .F. para lOk qdo da impressao do  ��� 
���            �        �      � relatorio diario.                        ���
���Denis       �27/02/02�Melhor� Utilizacao de query's/arquivi temporario ��� 
���            �        �      � para otimizacao do fonte.                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function QMTR070R3()
//��������������������������������������������������������������Ŀ
//� Define Variaveis										     �
//����������������������������������������������������������������
Local cDesc1		:= OemToAnsi(STR0001) // "Este programa ir� emitir o relat�rio de Calibra��es"
Local cDesc2		:= OemToAnsi(STR0002) // "Previstas e n�o relizadas dentro de um determinado"
Local cDesc3		:= OemToAnsi(STR0003) // "per�odo."
Local cString		:="QM2"
Local aOrd			:= {}
Local wnrel

Private titulo 		:= OemToAnsi(STR0004) // "Calibracoes Previstas e Nao Realizadas"
Private cabec1 		:= OemToAnsi(STR0005) // "Instrumento      Rev. Familia          Depto.    Usuario          Dias Fabricante       Orgao Calibrador Validade"
Private cabec2		:= Space(83)+STR0016
Private aReturn		:= {OemToAnsi(STR0006),1,OemToAnsi(STR0007),1,2,1,"",1} // "Zebrado"###"Administra��o"
Private nomeprog	:= "QMTR070"
Private nLastKey	:= 0
Private cPerg		:= "QMR070"
Private cTamanho	:= "M"

/*
1 		  2			3			 4 		  5			6			 7 		  8			9			 0 		  1			2			 3 		  4			5			 6 		  7			8			 9 		  0			1
0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
Freq
Instrumento 	  Rev. Familia 			Depto.	 Usuario 			Dias Fabricante		 Orgao Calibrador Validade
xxxxxxxxxxxxxxxx	xx  xxxxxxxxxxxxxxxx xxxxxxxxx xxxxxxxxxxxxxxxx xxxx xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxx xx/xx/xx
*/

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas 							 �
//����������������������������������������������������������������
pergunte("QMR070",.F.)

//�����������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros				�
//� mv_par01 : Instr. Inicial 							�
//� mv_par02 : Instr. Final								�
//� mv_par03 : Periodo Inicial							�
//� mv_par04 : Periodo Final							�
//� mv_par05 : Depto. Inicial							�
//� mv_par06 : Depto. Final								�
//� mv_par07 : Orgao Calibrador Todos/Interno/Externo   �
//� mv_par08 : Org.Calib.Interno de						�
//� mv_par09 : Org.Calib.Interno ate					�
//� mv_par10 : Org.Calib.Externo de						�
//� mv_par11 : Org.Calib.Externo ate					�
//� mv_par12 : Usuario de								�
//� mv_par13 : Usuario ate								�
//� mv_par14 : Fabricante de							�
//� mv_par15 : Fabricante ate							�
//� mv_par16 : Status de                  				�
//� mv_par17 : Status ate                               �
//� mv_par18 : Plano de Calibr. Mensal / Diario 		�
//� mv_par19 : Dias										�
//� mv_par20 : Familia de								�
//� mv_par21 : Familia ate								�
//�������������������������������������������������������

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT 					     �
//����������������������������������������������������������������
aOrd := {OemToAnsi(STR0008),OemToAnsi(STR0009)} // " Instrumento  "###" Departamento "
wnrel:="QMTR070"
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,cTamanho)

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| MTr070Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MTr070IMP� Autor � Alessandro B.Freire   � Data � 23.03.98 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime PADROES A CALIBRAR 								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MTr070IMP(lEnd,wnRel,cString) 							  ���
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
Static Function MTr070Imp(lEnd,wnRel,cString)

Local CbCont
Local CbTxt
Local tamanho		:= " "
Local cStrAnt		:= ""

Local cIndice		:= CriaTrab(NIL,.F.)
Local nIndice		:= 0
Local cChave		:= ""
Local cFiltro		:= ""

Local nRecno		:= Recno()
Local nOrder		:= IndexOrd()
Local nTotPrev 	:= 0
Local nTotReal 	:= 0
Local lOk			:= .F.
Local cFilialTRB	
Local TRB_FILIAL	
Local TRB_REVINS	
Local TRB_REVINV	
Local TRB_DEPTO	
Local TRB_TIPO	
Local TRB_VALDAF	
Local TRB_FREQAF	
Local TRB_RESP	
Local TRB_FABR	
Local TRB_STATUS	
Local TRB_LAUDO
Local cChaveQM6		:= "QM6_FILIAL+QM6_INSTR+QM6_DATINV"   
Local cFiltroQM6	:= ""
Local cInstrQM6 := ""
Local nTotMes 	:= 0
Private aInstru := {}
Private cInstr := ""
Private nTm := 1
Private cIndiceQM6	:= CriaTrab(NIL,.F.)
Private nIndiceQM6	:= 0
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape	 �
//����������������������������������������������������������������
cbtxt 	:= SPACE(10)
cbcont	:= 0
li 		:= 80
m_pag 	:= 1

//��������������������������������������������������������������Ŀ
//� Monta o indice temporario.									 �
//����������������������������������������������������������������
dbSelectArea("QM2")
dbSetOrder(01)

cChave := "QM2_FILIAL+QM2_INSTR+QM2_REVINV"
cFiltro := "SELECT QM2_FILIAL,QM2_INSTR,QM2_REVINS,QM2_REVINV,QM2_STATUS,"
cFiltro += "QM2_FREQAF,QM2_RESP,QM2_FABR,QM2_LAUDO,QM2_DEPTO,QM2_TIPO,QM2_VALDAF,QM2_LOCAL "
cFiltro += "FROM "+RetSqlName("QM2")+" QM2 "					
cFiltro += "WHERE "
cFiltro += "QM2.QM2_FILIAL = '"+xFilial("QM2")+"' AND "
cFiltro += "QM2.QM2_INSTR  BetWeen '" + mv_par01 + "' AND '" + mv_par02 + "' AND " 
cFiltro += "QM2.QM2_DEPTO  >= '" + mv_par05 + "' AND " 
cFiltro += "QM2.QM2_DEPTO  <= '" + mv_par06 + "' AND " 
cFiltro += "QM2.QM2_TIPO   >= '" + mv_par20 + "' AND " 
cFiltro += "QM2.QM2_TIPO   <= '" + mv_par21 + "' AND " 
cFiltro += "QM2.QM2_FABR   >= '" + mv_par14 + "' AND " 
cFiltro += "QM2.QM2_FABR   <= '" + mv_par15 + "' AND " 
cFiltro += "QM2.QM2_STATUS >= '" + mv_par16 + "' AND " 
cFiltro += "QM2.QM2_STATUS <= '" + mv_par17 + "' AND " 
cFiltro += "QM2.QM2_RESP   >= '" + mv_par12 + "' AND " 
cFiltro += "QM2.QM2_RESP   <= '" + mv_par13 + "' AND "
cFiltro += "QM2.QM2_FLAG  = '1' AND " 
cFiltro += "QM2.D_E_L_E_T_= ' ' "
cFiltro+= "ORDER BY " + SqlOrder(cChave)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cFiltro),"TRB",.T.,.T.)
TcSetField("TRB","QM2_VALDAF","D",8,0)
dbSelectArea("TRB")
cInstr := ""
While TRB->(!Eof())
	If TRB->QM2_FILIAL+TRB->QM2_INSTR <> cInstr
		Aadd(aInstru,{TRB->QM2_FILIAL,TRB->QM2_INSTR,TRB->QM2_REVINS,TRB->QM2_REVINV,TRB->QM2_STATUS,;
						TRB->QM2_FREQAF,TRB->QM2_RESP,TRB->QM2_FABR,TRB->QM2_LAUDO,TRB->QM2_DEPTO,;
						TRB->QM2_TIPO,TRB->QM2_VALDAF,TRB->QM2_LOCAL})
	Endif	
	cInstr := TRB->QM2_FILIAL+TRB->QM2_INSTR
	dbSkip()
Enddo

If BOF() .and. EOF()
	Help(" ",1,"RECNO")
End

If aReturn[8] == 2
	aSort(aInstru,,,{|x,y| x[10] < y[10]}) //Sorte do menor para o maior depto
Endif

//Verifico quais instrumentos estavam previstos dentro dos realizados no periodo em questao
dbSelectArea("QM6") 

cFiltroQM6 := 'QM6_FILIAL=="'+xFilial("QM6")+'".AND.DtoS(QM6_DTPREV) >= "'+DtoS(MV_PAR03)+'".AND.DtoS(QM6_DTPREV) <= "'+DtoS(MV_PAR04)+'"'
cFiltroQM6 += '.AND.QM6_INSTR >= "'+MV_PAR01+'".AND.QM6_INSTR <= "'+MV_PAR02+'"'
cFiltroQM6 += '.AND.DtoS(QM6_DATA) >= "'+DtoS(MV_PAR03)+'".AND.DtoS(QM6_DATA) <= "'+DtoS(MV_PAR04)+'"'
IndRegua("QM6",cIndiceQM6,cChaveQM6,,cFiltroQM6,OemToAnsi(STR0010)) // Selecionando Registros. . .
nIndiceQM6 := RetIndex("QM6")

dbSetOrder(nIndiceQM6+1)
dbGoTop()

cInstrQM6 := ""  

//Deve-se considerar o instrumento apenas uma unica vez...
While QM6->(!Eof())
	If QM6->QM6_FILIAL+QM6->QM6_INSTR <> cInstrQM6
		nTotReal ++
	Endif	
	cInstrQM6 := QM6->QM6_FILIAL+QM6->QM6_INSTR		
	QM6->(dbSkip())
Enddo	

dbSelectArea("QM6")
dbSetOrder(1)
dbGoTop()

cFiltroQM6 := 'QM6_FILIAL=="'+xFilial("QM6")+'".AND.QM6_INSTR >= "'+MV_PAR01+'".AND.QM6_INSTR <= "'+MV_PAR02+'"'
cFiltroQM6 += '.AND.DtoS(QM6_DATA) >= "'+DtoS(MV_PAR03)+'".AND.DtoS(QM6_DATA) <= "'+DtoS(MV_PAR04)+'"'
IndRegua("QM6",cIndiceQM6,cChaveQM6,,cFiltroQM6,OemToAnsi(STR0010)) // Selecionando Registros. . .
nIndiceQM6 := RetIndex("QM6")

dbSetOrder(nIndiceQM6+1)
dbGoTop()
SetRegua(RecCount())

While nTm <= Len(aInstru)

	cFilialTRB	:= aInstru[nTm][1]
	TRB_FILIAL	:= aInstru[nTm][1]
	TRB_INSTR	:= aInstru[nTm][2]
	TRB_REVINS	:= aInstru[nTm][3]
	TRB_REVINV	:= aInstru[nTm][4]
	TRB_STATUS	:= aInstru[nTm][5]
	TRB_FREQAF	:= aInstru[nTm][6]
	TRB_RESP	:= aInstru[nTm][7]
	TRB_FABR	:= aInstru[nTm][8]
	TRB_LAUDO	:= aInstru[nTm][9]		
	TRB_DEPTO	:= aInstru[nTm][10]
	TRB_TIPO	:= aInstru[nTm][11]
	TRB_VALDAF	:= aInstru[nTm][12]
	TRB_LOCAL	:= aInstru[nTm][13]

	IncRegua()
	
	IF lEnd
		@Prow()+1,001 PSAY OemToAnsi(STR0011) // "CANCELADO PELO OPERADOR"
		EXIT
	ENDIF
	        
	//������������������������������������������������������������Ŀ
	//�Caso o instrumento seja o mesmo que o anterior nao impri-lo.�
	//��������������������������������������������������������������

	If Alltrim(TRB_INSTR) == Alltrim(cStrAnt)
		nTm++
		Loop
	EndIf
	cStrAnt := TRB_INSTR
	
	If DtoS(TRB_VALDAF) < DtoS(mv_par03) .or. DtoS(TRB_VALDAF) > DtoS(mv_par04)
		nTm++
		Loop
	Endif		
	//�����������������������������������������������������������������Ŀ
	//� Verifica se status do instrumento esta ativo                    �
	//�������������������������������������������������������������������
	If !QMTXSTAT(TRB_STATUS)
		nTm++		
		loop
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno e externo                                 �
	//�������������������������������������������������������������������
	If mv_par07 == 1
		If ! Calibrador(0,mv_par08,mv_par09,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
			nTm++			
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. interno                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 2
		If ! Calibrador(1,mv_par08,mv_par09,,,TRB_INSTR,TRB_REVINS)
			nTm++			
			Loop
		EndIf
	EndIf
	
	//�����������������������������������������������������������������Ŀ
	//� Verifico O.C. externo                                           �
	//�������������������������������������������������������������������
	If mv_par07 == 3
		If ! Calibrador(2,,,mv_par10,mv_par11,TRB_INSTR,TRB_REVINS)
			nTm++
			Loop
		EndIf
	EndIf
	
	// ����������������������������������������������������������������������Ŀ
	// �Verifica validacao mensal:											  �
	// �Para validade de afericao no mesmo mes, a previsao ainda nao venceu   �
	// �portanto, nao deve ser impresso.									  �
	// ������������������������������������������������������������������������
	If mv_par18 == 1
		If SubStr(DtoS(TRB_VALDAF),1,6) < SubStr(DtoS(mv_par03),1,6)
			nTm++
			Loop
		EndIf
		
		If SubStr(DtoS(TRB_VALDAF),1,6) > SubStr(DtoS(mv_par04),1,6)
			nTm++
			Loop
		EndIf
		
		// Somo aos previstos. Nao somo aos nao realizados porque esta dentro
		// do mesmo mes, mas devo somar aos previstos porque esta dentro do mes
		// de previsao.
		// Somo tambem aos previstos no mes final, pois inclui no linha totalizadora

		If SubStr(DtoS(TRB_VALDAF),1,6) == SubStr(DtoS(mv_par04),1,6)
			nTotPrev++
			nTotMes++
			nTm++
			Loop
		EndIf
		
		// Somo realizado
		dbSelectArea("QM6")
		dbSetOrder(nIndiceQM6+1)
		If !dbSeek(cFilialTRB+TRB_INSTR+TRB_REVINS)
			nTotPrev++
			lOk := .F.
		Else            
			lOk := .F.
			While !Eof() .and. QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS ==;
				cFilialTRB+TRB_INSTR+TRB_REVINS			
				If Year(QM6->QM6_DATA) == Year(TRB_VALDAF)
					If Month(QM6->QM6_DATA) == Month(TRB_VALDAF)
						lOk := .F.					
						Exit
					Endif
				Else
					If Year(QM6->QM6_DATA) > Year(TRB_VALDAF) .or. Year(QM6->QM6_DATA) < Year(TRB_VALDAF)				
						//Nao somo aos realizados pq ja filtrei os realizados no arquivo temporario - vide comentarios no inicio do fonte
						lOk := .T.							
						Exit
					Endif	
				Endif
				dbSkip()
			Enddo	
		Endif		
		
		dbSelectArea("TRB")

		If lOk
			nTm++
			Loop
		EndIf
	EndIf
	
	// verifica validade por dia
	If mv_par18 == 2

		lOk := .F.
		If TRB_VALDAF >= mv_par03 .and.;
			TRB_VALDAF <= mv_par04
			// Somo a quantidade de dias para verificar se
			// est� dentro do per�odo
			If (TRB_VALDAF+mv_par19) < mv_par03
				nTm++
				Loop
			EndIf
		
			// Somo a quantidade de dias para verificar se est� dentro
			// do per�odo
			If TRB_VALDAF + mv_par19 > mv_par04
				nTm++
				Loop	
			EndIf
			
			// Verifico se existe realizado
			dbSelectArea("QM6")
			dbSetOrder(nIndiceQM6+1)
			If dbSeek(cFilialTRB + TRB_INSTR + TRB_REVINS)
				lOk := .F.
		 		While !Eof() .and. QM6->QM6_FILIAL+QM6->QM6_INSTR+QM6->QM6_REVINS ==;
					cFilialTRB+TRB_INSTR+TRB_REVINS			
					If Year(QM6->QM6_DATA) == Year(TRB_VALDAF)
						If Month(QM6->QM6_DATA) == Month(TRB_VALDAF)
							lOk := .F.					
							Exit
						Endif
					Else
						If Year(QM6->QM6_DATA) > Year(TRB_VALDAF) .or. Year(QM6->QM6_DATA) < Year(TRB_VALDAF)				
							//Nao somo aos realizados pq ja filtrei os realizados no arquivo temporario - vide comentarios no inicio do fonte
							lOk := .T.							
							Exit
						Endif	
					Endif
				dbSkip()
			Enddo	
			Else
				lOk := .F.
				nTotPrev ++	
			EndIf
		EndIf
		
		dbSelectArea("TRB")

		If lOk
			nTm++
			lOk := .F.
			Loop
		EndIf
		
	EndIf
	
	IF li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
	End
	
//Instrumento      Rev. Familia          Depto.        Usuario                       Dias Fabricante       Orgao Calibrador Validade
//          1         2         3         4         5         6         7         8         9         10        11        12        13
//0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
//xxxxxxxxxxxxxxxx xx	xxxxxxxxxxxxxxxx xxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxx xxxx xxxxxxxxxxxxxxxx xxxxxxxxxxxxxxxx xxxxxxxxxx
	@li,000 PSAY TRB_INSTR
	@li,017 PSAY TRB_REVINS
	@li,022 PSAY SubsTr(TRB_TIPO,1,TamSx3("QM2_TIPO")[1])
	@li,039 PSAY SubsTr(TRB_DEPTO,1,TamSx3("QM2_DEPTO")[1])
	dbSelectArea("QAA")
	dbSetOrder(1)
	If dbSeek(xFilial("QAA")+TRB_RESP)
		TRB_RESP := SubStr(QAA->QAA_NOME,1,30)
	Endif
	@li,053 PSAY SubsTr(TRB_RESP,1,TamSx3("QAA_NOME")[1]-1)
	@li,083 PSAY STR(TRB_FREQAF,4)
	@li,088 PSAY SubsTr(TRB_FABR,1,16)
	
	// LABORATORIO EXTERNO
	If mv_par07 == 3 .or. ( mv_par07 == 1 .and. QM9->QM9_ORGAFE == "E" )
		@li,105 PSAY SubsTr(QM9->QM9_LABOR,1,16)
		
		// LABORATORIO INTERNO
	ElseIf mv_par07 == 2  .or. ( mv_par07 == 1 .and. QM9->QM9_ORGAFE == "I" )
		@li,105 PSAY SubStr(QM9->QM9_DEPTO,1,16)
		
	EndIf
	
	@li,122 PSAY DTOC(TRB_VALDAF)
	
	li++
	
	nTm++
	Loop
	
EndDo

IF li > 55
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
EndIf
@li,00 PSAY __PrtThinLine() 
li++
IF li > 55
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
EndIf
@li,00 PSAY STR0012 + Str( nTotPrev,4 ) // "Total Previsto no Periodo.....: "
li++
IF li > 55
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
EndIf
@li,00 PSAY STR0013 + Str( nTotReal,4 ) // "Total Realizado no Periodo....: "
li++
IF li > 55
	cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
EndIf

@li,00 PSAY STR0014 + Str((100*nTotPrev)/(nTotPrev+nTotReal),6,2) + "%"
//���������������������������������������������������������������������Ŀ
//�Subtraindo-se o Total Previsto do Total Previsto no Mes Final devera �
//�ser o numero de instrumentos listados previstos e nao realizados		�
//�������������������������������������������������������������Denis�����

If mv_par18 == 1 //Somente para Mensal 
	li++
	IF li > 55
		cabec(titulo,cabec1,cabec2,nomeprog,tamanho,IIF(aReturn[4]==1,15,18))
	EndIf
	@li,00 PSAY OemToAnsi(STR0015) + Str( nTotMes,4 ) // "Total Previsto no Mes Final...: "
	li++ 
Endif	                                                                        

Roda( cbCont, cbTxt, Tamanho )

Set Device To Screen
RetIndex("QM6")
FErase(cIndiceQM6+OrdBagExt())

dbSelectArea("TRB")
dbCloseArea()
dbSelectArea("QM2")
dbSetOrder(1)

If aReturn[5] = 1
	Set Printer TO
	dbCommitall()
	ourspool(wnrel)
End

MS_FLUSH()

Return(Nil)
