#INCLUDE "MATA295.ch"
#INCLUDE "PROTHEUS.ch"

#DEFINE nMesAval     MV_PAR01
#DEFINE nEstabilid   MV_PAR02 
#DEFINE nMedias      MV_PAR03 
#DEFINE nTendencia   MV_PAR04 
#DEFINE nSazonalid   MV_PAR05 
#DEFINE cCodFormu    MV_PAR06 
#DEFINE nClAVenda    MV_PAR07 
#DEFINE nClBVenda    MV_PAR08 
#DEFINE nClACusto    MV_PAR09 
#DEFINE nClBCusto    MV_PAR10 
#DEFINE ClCustMDe    MV_PAR11 
#DEFINE ClCustMAte   MV_PAR12 
#DEFINE nTipVenda    MV_PAR13 
#DEFINE cTipInclu    MV_PAR14 
#DEFINE cTipExcet    MV_PAR15 

Static cAnoMes 

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA        �Programa    MATA295.PRW ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data                            ���
�������������������������������������������������������������������������Ĵ��
���      01  �                          �                                 ���
���      02  � Ricardo Berti            � 15/12/05                        ���
���      03  �                          �                                 ���
���      04  � Ricardo Berti            � 15/12/05                        ���
���      05  �                          �                                 ���
���      06  �                          �                                 ���
���      07  �                          �                                 ���
���      08  �                          �                                 ���
���      09  �                          �                                 ���
���      10  � Ricardo Berti            � 15/12/05                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA295  � Autor � Alex Sandro Valario   � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Acumulado para sugestao de compras                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � MATA295(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Function Mata295()     

/*
�������������������������������������������������Ŀ
� Perguntas                                       �
���������������������������������������������������
MV_PAR01	N	2 		Meses para avaliacao da melhor sugestao
MV_PAR02 N	1 		Se utiliza a Formula de Estabilidade 1-Sim 2-Nao
MV_PAR03 N	1 		Se utiliza a Formula de Medias 1-Sim 2-Nao
MV_PAR04	N	1 		Se utiliza a Formula de Tendencia 1-Sim 2-Nao
MV_PAR05	N	1 		Se utiliza a Formula de Sazonalidade 1-Sim 2-Nao
MV_PAR06	C  30 		String contendo as os codigo da formulas que poderam estar cadastrada no SM4
MV_PAR07	N	2 		% da Classificacao A ref a Vendas
MV_PAR08	N	2 		% da Classificacao B ref a Vendas
MV_PAR09	N	2 		% da Classificacao A ref a Custos
MV_PAR10	N	2 		% da Classificacao B ref a Custos
MV_PAR11	N  15	2   Valor Classificacao Custo Medio de
MV_PAR12	N  15	2   Valor Classificacao Custo Medio ate
MV_PAR13	N   1 		Somente Vendas 1-Venda 2-Todos
MV_PAR14	C  40 	Tipo de Materiais
MV_PAR15	C  40 	Excessao de Tipo de Materiais
MV_PAR16	N   1 	Considerar TES que 1-Gera Duplicata 2-Nao gera Duplicata 3-Ambos
MV_PAR17	N   1 	Qto ao Estoque TES 1-Movimenta      2-Nao Movimenta      3-Ambos
*/

Local lContinua := .T.  

If Pergunte("MTA295")

	//������������������������������������������������������������������������Ŀ
	//� Monta o mes de trabalho do calculo das demandas                        �
	//��������������������������������������������������������������������������
	IF Month(dDataBase)==1 
		cAnoMes := StrZero(Year(dDataBase)-1,4)+"12" 
	Else
		cAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase)-1,2) 
	EndIf   

	//������������������������������������������������������������������������Ŀ
	//� Verifica se nao existe SBL para reprocessar                            �
	//��������������������������������������������������������������������������
	DbSelectArea("SBL")
	DBSetOrder(2)  //SBL Acum.Sugest.Compra	->BL_FILIAL+BL_ANO+BL_MES
	If MsSeek(xFilial("SBL")+cAnoMes)  
		lContinua := MsgYesNo(STR0008,STR0009)// Confirma geracao
	Endif
	//������������������������������������������������������������������������Ŀ
	//� Processa das demandas                                                  �
	//��������������������������������������������������������������������������
    If lContinua
		Processa({ || Mt295Acum() })
	EndIf
Endif

Return (Nil)
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295Acum � Autor � Henry Fila            � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Acumulado para sugestao de compras                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Mt295Acum()                                                ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao principal para gerar os acumulados do SBL           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA297()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           

Function Mt295Acum() 

Local lVeic := GetMV("MV_VEICULO") == "S"
Local lReq  := GetMV("MV_USAREQ")  == "S" 

ProcRegua(if(nTipVenda <> 3,if(lReq,7,6),if(lReq,9,8))) // MV_PAR13 Somente Venda 1- Venda 2-Todos

//������������������������������������������������������������������������Ŀ
//� Gera registros do SBL em branco para processamento                     �
//��������������������������������������������������������������������������
GeraSBL()       

//������������������������������������������������������������������������Ŀ
//� Verifica os movimentos de entrada                                      �
//��������������������������������������������������������������������������
If nTipVenda <> 1
	Mt295Sd1()
Endif	

//������������������������������������������������������������������������Ŀ
//� Verifica os movimentos de saida                                        �
//��������������������������������������������������������������������������
Mt295Sd2()

//������������������������������������������������������������������������Ŀ
//� Verifica movimentos internos                                           �
//��������������������������������������������������������������������������
Mt295Sd3() 

//������������������������������������������������������������������������Ŀ
//� Vwrifica resgistro caso esteja integrado com modulo de veiculos        �
//��������������������������������������������������������������������������
If lVeic .and. lReq
	AcumulaVO2() //Requisicoes
EndIF
If lVeic
	AcumulaVE6() //Vendas Perdidas
EndIF

//������������������������������������������������������������������������Ŀ
//�PE "M295ACUM" executado ANTES do calculo da curva ABC das demandas.     �
//��������������������������������������������������������������������������
If ExistBlock("M295ACUM")
	ExecBlock("M295ACUM",.F.,.F.)
EndIf

//������������������������������������������������������������������������Ŀ
//� Calcula a curva ABC das demandas                                       �
//��������������������������������������������������������������������������
Mt295Dem()   

//������������������������������������������������������������������������Ŀ
//� Calcula a curva ABC do custo                                           �
//��������������������������������������������������������������������������
Mt295ABCCt()   

Mt295GrvFor()  

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � GERASBL  � Autor � Alex Sandro Valario   � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Acumulado os Produtos de arqco c/ as pergutas              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � GERASBL()                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function GeraSBL()                        
Local nX
Local nTamTip
Local nStandard 
Local lProcessa := .T.
Local lM295SBL := ExistBlock("M295SBL")
Static cAliasSB1 
Static cQuery
Static lQuery := .F.

//Pega o tamanho do campo B1_TIPO

nTamTip:=TamSX3("B1_TIPO")[1]

IncProc(STR0001) //"Processo: Inicializando"

DbSelectArea("SBL")
DBSetOrder(1)  //SBL Acum.Sugest.Compra	->BL_FILIAL+BL_PRODUTO+BL_ANO+BL_MES


#IFDEF TOP
	If ( TcSrvType()<>"AS/400")
		cAliasSB1 := GetNextAlias()
		lQuery  := .T.
		cQuery  := "SELECT SB1.B1_FILIAL, SB1.B1_COD, SB1.B1_FLAGSUG, SB1.B1_TIPO, SB1.B1_CLASSVE, SB1.B1_CUSTD, SB1.B1_MCUSTD FROM "+RetSqlName("SB1")+" SB1 "
		cQuery  += " WHERE SB1.B1_FILIAL='"+xFilial("SB1")+"' AND "
		cQuery  += " SB1.B1_FLAGSUG = '1' AND SB1.B1_CLASSVE = '1' AND "
		cQuery  += " SB1.D_E_L_E_T_=' ' AND "
		cQuery  += " NOT EXISTS (SELECT 1 FROM "+RetSqlName("SG1")+ " SG1 WHERE SG1.G1_FILIAL = '"+xFilial("SG1")+"' "
		cQuery  += " AND SG1.G1_COD = SB1.B1_COD AND SG1.D_E_L_E_T_=' ' )
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), cAliasSB1, .F., .T. )
		TcSetField(cAliasSB1,"B1_CUSTD","N",TamSX3('B1_CUSTD')[1],TamSX3('B1_CUSTD')[2])
	Else
#ENDIF 
	cAliasSB1:='SB1'
	DbSelectArea("SB1")
	DbSetOrder(1)   //SB1 Produtos		    ->B1_FILIAL+B1_COD
	DbSeek(xFilial("SB1")) 
	#IFDEF TOP
		EndIf
	#ENDIF

While (cAliasSB1)->(!Eof()) .And. IIf(lQuery,.T.,xFilial("SB1") == (cAliasSB1)->B1_FILIAL )

   If (cAliasSB1)->B1_FLAGSUG == "1" .And. (cAliasSB1)->B1_CLASSVE == "1"       	
      lProcessa := .T.
      //Processa os tipos de produtos de acordo com os parametros para fazer
      //parte ou nao do processo	

      If !Empty(cTipInclu)
         For nX:=1 to Len(AllTrim(cTipInclu)) Step nTamTip
            IF (cAliasSB1)->B1_TIPO # SubStr(cTipInclu,nX,nTamTip)
               lProcessa := .F.
            EndIF
         Next
      EndIf

      IF !Empty(cTipExcet)
         For nX:=1 to Len(AllTrim(cTipExcet)) Step nTamTip
            IF (cAliasSB1)->B1_TIPO == SubStr(cTipExcet,nX,nTamTip)
               lProcessa := .F.
            EndIF
         Next
      EndIf

	  If !lQuery
	      SG1->(DbSetOrder(1))
	      If  SG1->(MsSeek(xFilial("SG1")+(cAliasSB1)->B1_COD))
	         lProcessa := .F.
	      EndIf   
	  EndIf

      If lProcessa	

         //Calcula o custo standard do produto
         nStandard := Mt295Custo((cAliasSB1)->B1_COD)
   
         DbSelectArea("SBL")
         If ! MsSeek(xFilial("SBL")+(cAliasSB1)->B1_COD+cAnoMes)  
            RecLock("SBL",.T.)
            SBL->BL_FILIAL  := xFilial("SBL") 
            SBL->BL_PRODUTO := (cAliasSB1)->B1_COD
            SBL->BL_ANO     := Left(cAnoMes,4)
            SBL->BL_MES     := Right(cAnoMes,2)
         Else
            RecLock("SBL",.F.)
         EndIf       

         SBL->BL_DEMANDA := 0
         SBL->BL_TOTDEM  := 0
         SBL->BL_TOTCUST := nStandard
         SBL->BL_FREQUEN := 0
         SBL->BL_ABCVEND := "C"
         SBL->BL_ABCCUST := "C"
         SBL->BL_VENDPER := 0 
         SBL->BL_CODFORM := ""
         SBL->BL_PORFOR1 := 0
         SBL->BL_QTDFOR1 := 0
         SBL->BL_CODFOR2 := ""
         SBL->BL_PORFOR2 := 0
         SBL->BL_QTDFOR2 := 0
         SBL->BL_CODFOR3 := ""
         SBL->BL_PORFOR3 := 0
         SBL->BL_QTDFOR3 := 0
         SBL->BL_CODFOR4 := ""
         SBL->BL_PORFOR4 := 0
         SBL->BL_QTDFOR4 := 0    
 
   		 If xMoeda((cAliasSB1)->B1_CUSTD,Val((cAliasSB1)->B1_MCUSTD),1,dDataBase) < ClCustMDe            
            SBL->BL_TIPCUST := "3"
 		 ElseIf xMoeda((cAliasSB1)->B1_CUSTD,Val((cAliasSB1)->B1_MCUSTD),1,dDataBase) > ClCustMAte 
            SBL->BL_TIPCUST := "1"
         Else   
            SBL->BL_TIPCUST := "2"      
         EndIf   

         MsUnlock()

         If lM295SBL
            Execblock("M295SBL",.f.,.f.)
         EndIf

      Endif   

   Endif
   If !lQuery
	   DbSelectArea("SB1")
	   DbSkip()
   Else
       (cAliasSB1)->(DbSkip())
   EndIf
EndDo
#IFDEF TOP
	Dbclosearea(cAliasSB1)
#ENDIF
Return                             


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Mt295Custo� Autor � Henry Fila            � Data � 14/04/00���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o custo do produto                                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe e � Mt295Custo()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Codigo do Produto                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATA295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           

Static Function Mt295Custo(cCod)

Local cAlias := GetArea()
Local nValor :=0

DbSelectArea("SB2")
DBSetOrder(1)
MsSeek(xFilial("SB2")+cCod)

While (! eof() .and. SB2->B2_FILIAL == xFilial("SB2") .and. B2_COD == cCod)
   nValor  += B2_QATU*xMoeda((cAliasSB1)->B1_CUSTD,Val((cAliasSB1)->B1_MCUSTD),1,dDataBase)  
   DbSkip()
End
RestArea(cAlias)

Return nValor

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295SD1� Autor � Henry Fila              � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa o arquivo SD1 -> Itens das notas fiscais de entrda���
���          � verificando as devolucoes dos produtos                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295SD1()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function Mt295SD1()

Local lProcessa := .T.
Local lRemito	  := .F.


IncProc(STR0002) //"Processo: Entradas"

DbSelectArea("SB1")
SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD

DbSelectArea("SD1")
SD1->(DbSetOrder(6))  //SD1 Itens de Entrada  	->D1_FILIAL+DTOS(D1_DTDIGIT)+D1_NUMSEQ

MsSeek(xFilial("SD1")+cAnoMes)


While ! SD1->(eof()) .and. SD1->D1_FILIAL == xFilial("SD1") .and. Left(DToS(SD1->D1_DTDIGIT),6) == cAnoMes
	
	lProcessa := .T.
			
	SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES))
	If (mv_par17 == 1 .And. SF4->F4_ESTOQUE <> "S");
		.or. (mv_par17 == 2 .And. SF4->F4_ESTOQUE <> "N");
		.or. (mv_par16 == 1 .And. SF4->F4_DUPLIC <> "S");
		.or. (mv_par16 == 2 .And. SF4->F4_DUPLIC <> "N")
		lProcessa := .F.
	EndIf

	If lProcessa .And. ExistBlock("M295SD1")
		lProcessa := ExecBlock("M295SD1",.F.,.F.)
		If ValType(lProcessa) # 'L'
			lProcessa := .F.
		Endif
	EndIf
		
	// Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal
	If SD1->D1_ORIGLAN <> "LF" .And. SD1->D1_TIPO == 'D'.And. lProcessa .And. ;
		Iif(lRemito,Empty(SD1->D1_REMITO),.T.) // Nao considerar faturas que possuam remito, para nao gerar duplicidade de demanda
		
		dbSelectArea("SBL")
		
		If MsSeek(xFilial("SBL")+SD1->D1_COD+cAnoMes)
			RecLock("SBL",.F.)
			SBL->BL_DEMANDA -=SD1->D1_QUANT
			SBL->BL_TOTDEM  -=SD1->D1_TOTAL
			SBL->(MsUnlock())
		Endif
		
	Endif
	dbSelectArea("SD1")
	dbSkip()
EndDo


Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295Sd2  � Autor � Henry Fila            � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa o arquivo SD2 -> Itens das notas fiscais de Saida ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295Sd2()                                                 ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function Mt295Sd2()

Local lVeic     := GetMV("MV_VEICULO") == "S"
Local lReq      := GetMV("MV_USAREQ")  == "S"
Local lProcessa := .T.
Local lRemito	  := .F.

IncProc(STR0003) //"Processo: Saidas"

If lVeic .And. lReq
	If !("VOO"$cFopened)
		ChkFile("VOO",.F.)
	EndIf
	VOO->(dbSetOrder(4))
EndIF


DbSelectArea("SB1")
SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD

DbSelectArea("SD2")
DbSetOrder(5) //SD2 Itens de Saida    	->D2_FILIAL+DTOS(D2_EMISSAO)+D2_NUMSEQ
MsSeek(xFilial("SD2")+cAnoMes)


While ! SD2->(eof()) .and. SD2->D2_FILIAL == xFilial("SD2") .and. Left(DtoS(SD2->D2_EMISSAO),6) == cAnoMes
	
	lProcessa := .T.
	// Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal
	If SD2->D2_ORIGLAN == "LF" .or. SD2->D2_TIPO $ "DB"
		lProcessa := .F.
	EndIf
	
	If lVeic .And. lReq
		IF VOO->(MsSeek(xFilial("VOO")+SD2->D2_DOC+SD2->D2_SERIE))
			lProcessa := .F.
		EndIF
	EndIf
	
	SF4->(MsSeek(xFilial("SF4")+SD2->D2_TES))
	If (SF4->F4_ISS == "S") .or. (mv_par17 == 1 .And. SF4->F4_ESTOQUE # "S");
		.or. (mv_par17 == 2 .And. SF4->F4_ESTOQUE # "N");
		.or. (mv_par16 == 1 .And. SF4->F4_DUPLIC # "S");
		.or. (mv_par16 == 2 .And. SF4->F4_DUPLIC # "N")
		lProcessa := .F.
	EndIf

	If lProcessa .And. ExistBlock("M295SD2")
		lProcessa := ExecBlock("M295SD2",.F.,.F.)
		If ValType(lProcessa) # 'L'
			lProcessa := .F.
		Endif
	EndIf
		
	If lProcessa .And. ;
	Iif(lRemito,Empty(SD2->D2_REMITO),.T.) // Nao considerar facturas que possuam remito, para nao gerar duplicidade de demanda
		
		dbSelectArea("SBL")
		If MsSeek(xFilial("SBL")+SD2->D2_COD+cAnoMes)
			RecLock("SBL",.F.)
			SBL->BL_DEMANDA +=SD2->D2_QUANT
			SBL->BL_TOTDEM  +=SD2->D2_CUSTO1
			SBL->BL_FREQUEN ++
			SBL->(MsUnlock())
		Endif
		dbSelectArea("SD2")
		
	Endif
	
	SD2->(DbSkip())
	
EndDo

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295Sd3  � Autor � Henry Fila            � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa o arquivo movimentos internos       	  		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295Sd3                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function Mt295Sd3()

Local lProcessa := .T.

IF nTipVenda == 3
	IncProc(STR0010)  //"Processo: Movimentos Internos"
	
	dbSelectArea("SB1")
	SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD
	
	dbSelectArea("SD3")
	SD3->(DbSetorder(6))  //SD3 Moviment.Internas 	->D3_FILIAL+DTOS(D3_EMISSAO)+D3_NUMSEQ+D3_CHAVE+D3_COD
	MsSeek(xFilial("SD3")+cAnoMes)
	
	While ! SD3->(eof()) .and. SD3->D3_FILIAL == xFilial("SD3") .and. Left(DToS(SD3->D3_EMISSAO),6) == cAnoMes

        lProcessa := .T.
        
		If ExistBlock("M295SD3")
			lProcessa := ExecBlock("M295SD3",.F.,.F.)
			If ValType(lProcessa) # 'L'
				lProcessa := .F.
			Endif
		EndIf
		
		If Subs(SD3->D3_CF,2,1) == "E" .And. !(Substr(D3_CF,3,1) $ "347") .And. lProcessa
			dbSelectArea("SBL")
			If MsSeek(xFilial("SBL")+SD3->D3_COD+cAnoMes)
				RecLock("SBL",.F.)
				If SD3->D3_TM <= "500"
					SBL->BL_DEMANDA -=SD3->D3_QUANT
					SBL->BL_TOTDEM  -=SD3->D3_CUSTO1
				Else
					SBL->BL_DEMANDA +=SD3->D3_QUANT
					SBL->BL_TOTDEM  +=SD3->D3_CUSTO1
				EndIf
				MsUnlock()
			Endif
		Endif
		
		dbSelectArea("SD3")
		dbSkip()
	EndDo
	
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AcumulaVO2� Autor � Valdir F. Silca       � Data � 22/08/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa o arquivo de Requisicoes						  		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AcumulaVO2()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function AcumulaVO2()                        

IncProc(STR0004) //"Processo: Requisicoes"
If !("VO2"$cFopened)
  	ChkFile("VO2",.F.)
EndIf
If !("VO3"$cFopened)
   ChkFile("VO3",.F.)
EndIf

SB1->(DbSetOrder(1))  
VO2->(DbSetorder(3))  
VO2->(MsSeek(xFilial("VO2")+cAnoMes))
VO3->(DbSetorder(1))
While ! VO2->(eof()) .and. VO2->VO2_FILIAL == xFilial("VO2") .and. Left(DToS(VO2->VO2_DATREQ),6) == cAnoMes
   //Posiciona os Itens 
   VO3->(MsSeek(xFilial("VO3")+VO2->VO2_NOSNUM))
   While ! VO3->(eof()) .and. VO3->VO3_FILIAL == xFilial("VO3") .and. VO3->VO3_NOSNUM == VO2->VO2_NOSNUM
   	//Verifica se a OS esta Cancelada
	  If VO3->VO3_DATCAN # CTOD("  /  /  ","ddmmyy")
      	VO3->(dbSkip())
      	Loop	
   	EndIf                             
   	//Verifica se a OS esta fechada
		If VO3->VO3_DATFEC # CTOD("  /  /  ","ddmmyy")
      	VO3->(dbSkip())
      	Loop	
   	EndIf                             

   	If SBL->(MsSeek(xFilial("SBL")+VO3->VO3_PECINT+cAnoMes))      
	   	RecLock("SBL",.F.)
	     	//Verifica se e 1=Requisicao ou 0=devolucao
	     	If VO2->VO2_DEVOLU == "1"
   	  		SBL->BL_DEMANDA +=VO3->VO3_QTDREQ
    			SBL->BL_TOTDEM  +=(VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
	      	SBL->BL_FREQUEN ++
   	   Else
	     		SBL->BL_DEMANDA -=VO3->VO3_QTDREQ
   	 		SBL->BL_TOTDEM  -=(VO3->VO3_VALPEC*VO3->VO3_QTDREQ)
      		SBL->BL_FREQUEN --  
	      EndIf
   		SBL->(MsUnlock())    	  	
   	EndIf
   	VO3->(dbSkip())
   EndDo
   VO2->(DbSkip())
EndDo      

Return    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �AcumulaVE6� Autor � Valdir F. Silca       � Data � 22/08/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processa o arquivo de Requisicoes						  		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � AcumulaVE6()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function AcumulaVE6()                        
Local nRecSB1 := SB1->(Recno())
Local nOrdSB1 := SB1->(IndexOrd())
IncProc(STR0011) //"Processo: Vendas Perdidas"
If !("VE6"$cFopened)
  	ChkFile("VE6",.F.)
EndIf
If !("VE7"$cFopened)
   ChkFile("VE7",.F.)
EndIf
SB1->(DbSetOrder(7))
VE6->(dbsetorder(1))
VE7->(dbsetorder(1))
VE6->(MsSeek(xFilial("VE6")+"1"+cAnoMes))
While VE6->(!eof()) .and. VE6->VE6_FILIAL == xFilial("VE6") .and.;
      VE6->VE6_INDREG == "1" .and. Left(DTOS(VE6->(VE6_DATREG)),6) == cAnoMes 
	VE7->(MsSeek(xFilial("VE7")+VE6->VE6_INDREG))
	If VE7->VE7_INDMOT == "1"
		If SB1->(MsSeek(xFilial("SB1")+VE6->VE6_GRUITE+VE6->VE6_CODITE))
			If SBL->(DbSeek(xFilial("SBL")+SB1->B1_COD))
				RecLock("SBL",.F.)
				SBL->BL_DEMANDA +=VE6->VE6_QTDITE
				SBL->BL_TOTDEM  +=(VE6->VE6_VALPEC*VE6->VE6_QTDITE)
				SBL->BL_FREQUEN ++ 
				MsUnlock()   
			EndIf
		EndIf
	EndIF
	VE6->(dbSkip())
EndDo
SB1->(Dbgoto(nRecSB1))
SB1->(DbSetOrder(nOrdSB1))
Return    

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295Dem  � Autor � Henry Fila            � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Classificacao ABC de Venda								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295Dem                                                   ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function Mt295Dem()

Local cPAnoMes
Local nTotal :=0
Local nTotA  :=0
Local nTotB  :=0
Local nTotC  :=0                      
Local nPorC  := 100-(nClAVenda+nClBVenda)

IncProc(STR0005) //"Processo: Classificacao ABC Vendas"

//������������������������������������������������������������������������Ŀ
//� Calcula o ano e mes final para verficar a curva ABC                    �
//��������������������������������������������������������������������������
IF Month(dDataBase)==12
   cPAnoMes := StrZero(Year(dDataBase)+1,4)+"01"
Else
   cPAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase),2)
EndIf   

DbSelectArea("SB1")
SB1->(DbSetOrder(1))  //SB1 Produtos		    ->B1_FILIAL+B1_COD
//������������������������������������������������������������������������Ŀ
//� Calcula a demanda total posicionando no mes subsequente e calculando   �
//� de tras pra frente                                                     �
//��������������������������������������������������������������������������
DbSelectArea("SBL")                                              
DbSetOrder(3)  //SBL Sugestao compras   ->BL_FILIAL+STR(BL_TOTDEM,15,2)
MsSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL  .and. SBL->(BL_ANO+BL_MES) == cAnoMes )
   nTotal += SBL->BL_TOTDEM
   SBL->(DbSkip(-1))
EndDo                         

//������������������������������������������������������������������������Ŀ
//� Calcula a faixa ABC para demanda                                       �
//��������������������������������������������������������������������������
nTotA   :=  nClAVenda * nTotal / 100
nTotB   := (nClBVenda * nTotal / 100) + nTotA
nTotC   := (nPorC     * nTotal / 100) + nTotB
nTotal  := 0

//������������������������������������������������������������������������Ŀ
//� Separa as demandas pelas faixas pela ordem inversa de valor            �
//��������������������������������������������������������������������������
dbSelectArea("SBL")
DbSetOrder(3)  //SBL Sugestao compras   ->BL_FILIAL+STR(BL_TOTDEM,15,2)
DbSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes)
   nTotal += SBL->BL_TOTDEM   
   If nTotal < nTotA
      cClasse := "A"
   ElseIf nTotal < nTotB
      cClasse := "B"
   Else
      cClasse := "C"
   Endif                                               

	//������������������������������������������������������������������������Ŀ
	//� Grava a classe                                                         �
	//��������������������������������������������������������������������������
   SBL->(RecLock("SBL",.F.))
   SBL->BL_ABCVEND := cClasse
   SBL->(MsUnlock())
   SBL->(DbSkip(-1))      
EndDo

SBL->(DbSetOrder(1))

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295ABCCt� Autor � Alex Sandro Valario   � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Classificacao ABC de Venda								  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295Custo()                                               ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Static Function Mt295ABCCt()

Local cPAnoMes := ""
Local nTotal   := 0
Local nTotA    := 0
Local nTotB    := 0
Local nTotC    := 0                      
Local nPorC    := 100-(nClACusto+nClBCusto)

IncProc(STR0006) //"Processo: Classificacao ABC Custo"

//������������������������������������������������������������������������Ŀ
//� Calcula o ano e mes final para verficar a curva ABC                    �
//��������������������������������������������������������������������������
IF Month(dDataBase)==12
   cPAnoMes := StrZero(Year(dDataBase)+1,4)+"01"
Else
   cPAnoMes := StrZero(Year(dDataBase),4)+StrZero(Month(dDataBase),2)
EndIf   

DbSelectArea("SB1")
DbSetOrder(1)

//������������������������������������������������������������������������Ŀ
//� Calcula o custo total                                                  �
//��������������������������������������������������������������������������
DbSelectArea("SBL")                                              
DbSetOrder(4)
MsSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)                         

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes) 
   nTotal += SBL->BL_TOTCUST
   DbSkip(-1)
EndDo                         

//������������������������������������������������������������������������Ŀ
//� Calcula a faixa ABC para e custo                                       �
//��������������������������������������������������������������������������
nTotA   :=  nClACusto * nTotal / 100
nTotB   := (nClBCusto * nTotal / 100) + nTotA
nTotC   := (nPorC     * nTotal / 100) + nTotB
nTotal  := 0

//������������������������������������������������������������������������Ŀ
//� Separa os custoss pelas faixas pela ordem inversa de valor             �
//��������������������������������������������������������������������������
DbSelectArea("SBL")
DbSetOrder(4)  
MsSeek(xFilial("SBL")+cPAnoMes,.t.)
DbSkip(-1)

While (! SBL->(BOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes)
   nTotal += SBL->BL_TOTCUST
   If nTotal < nTotA
      cClasse := "A"
   ElseIf nTotal < nTotB
      cClasse := "B"
   Else
      cClasse := "C"
   Endif                                               
   
	//������������������������������������������������������������������������Ŀ
	//� Grava as classes                                                       �
	//��������������������������������������������������������������������������
   RecLock("SBL",.F.)
   SBL->BL_ABCCUST := cClasse
   MsUnlock()
	DbSkip(-1)
EndDo                         

DbSetOrder(1)

Return

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295GrvFor  � Autor � Alex Sandro Valario   � Data � 14/04/00 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Grava a formula eleita                                        ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295GrvFor                                                   ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                         	           ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/           
Static Function Mt295GrvFor()

Local aFormula := 0

IncProc(STR0007) //"Processo: Classificacao Formula"

DbSelectArea("SB1")
DbSetOrder(1)  

DbSelectArea("SBL")                                              
DbSetOrder(2) 
MsSeek(xFilial("SBL")+cAnoMes)

While (! SBL->(EOF()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->(BL_ANO+BL_MES) == cAnoMes)

   aFormula := Mt295Form(SBL->BL_PRODUTO)                                             
   
   IF Len(aFormula) > 0
	   SBL->(RecLock("SBL",.F.))
	   SBL->BL_CODFORM := aFormula[1,4]
	   SBL->BL_PORFOR1 := If(aFormula[1,2] > 999.99, 999.99, aFormula[1,2])
	   SBL->BL_QTDFOR1 := aFormula[1,3]
	   SBL->BL_CODFOR2 := aFormula[2,4]
	   SBL->BL_PORFOR2 := If(aFormula[2,2] > 999.99, 999.99, aFormula[2,2])
	   SBL->BL_QTDFOR2 := aFormula[2,3]
	   SBL->BL_CODFOR3 := aFormula[3,4]
	   SBL->BL_PORFOR3 := If(aFormula[3,2] > 999.99, 999.99, aFormula[3,2])
	   SBL->BL_QTDFOR3 := aFormula[3,3]
	   SBL->BL_CODFOR4 := aFormula[4,4]
	   SBL->BL_PORFOR4 := If(aFormula[4,2] > 999.99, 999.99, aFormula[4,2])
	   SBL->BL_QTDFOR4 := aFormula[4,3]
	   SBL->(MsUnlock())
   EndIf	   
   SBL->(DbSkip())             
EndDo                         
Return 
/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295Form    � Autor � Alex Sandro Valario   � Data � 14/04/00 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Sugere a melhor formula                                       ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295Form()                                                   ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                       	                             ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/           
Static Function Mt295Form(cCodProd)

Local aFormulas :={}
Local nX:=0
Local nY:=0
Local cMacroF1 := ""
Local cMacroF2 := ""
Local cMacroF3 := ""
Local cMacroF4 := ""

Private aConsumo :={}
Private nAtual                         

//������������������������������������������������������������������������Ŀ
//� Carrega formulas                                                       �
//��������������������������������������������������������������������������

If nEstabilid == 1
   Aadd(aFormulas,{"aConsumo[nAtual-1]",0,"PES"})
Else
   Aadd(aFormulas,{"0",0,"PES"})
endif   

If nMedias == 1                       
   Aadd(aFormulas,{"(aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/3",0,"PME"})
Else
   Aadd(aFormulas,{"0",0,"PME"})
endif   

If nTendencia == 1                                                               
   Aadd(aFormulas,{"aConsumo[nAtual-1]+(aConsumo[nAtual-1]-aConsumo[nAtual-2])",0,"PTE"})
Else
   Aadd(aFormulas,{"0",0,"PTE"})
endif   

If nSazonalid == 1 
   Aadd(aFormulas,{"aConsumo[nAtual-12]*((aConsumo[nAtual-1]+aConsumo[nAtual-2]+aConsumo[nAtual-3])/(aConsumo[nAtual-13]+aConsumo[nAtual-14]+aConsumo[nAtual-15]))",0,"PSA"})
Else
   Aadd(aFormulas,{"0",0,"PSA"})
EndIf             

//������������������������������������������������������������������������Ŀ
//� Carrega Formula customizada do usuario                                 �
//��������������������������������������������������������������������������

If ! Empty(cCodFormu)  

   SB1->(MsSeek(xFilial("SB1")+SBL->BL_PRODUTO)) // Caso exista referencia � SB1 na formula
    
   For nX := 1 To Len(cCodFormu) Step 4
      IF Empty(Subs(cCodFormu,nX,3))
         Exit
      EndIf   
      SM4->(DbSetOrder(1)) //M4_FILIAL+M4_CODIGO
      IF SM4->(MsSeek(xFilial("SM4")+Subs(cCodFormu,nX,3)))
         Aadd(aFormulas,{&(SM4->M4_FORMULA),0,Subs(cCodFormu,nX,3)})
      EndIf
   Next
Endif 
//������������������������������������������������������������������������Ŀ
//� Carrega consumo                                                        �
//��������������������������������������������������������������������������
aConsumo := Mt295Cons(cAnoMes,cCodProd)

nAtual    :=len(aConsumo)
For nX := 1 to nMesAval
   For nY := 1 to Len(aFormulas)
		cFormula :=aFormulas[nY,1] 
		nValor := &cFormula // valor sugerido 
		aFormulas[nY,2] += ((nValor-aConsumo[nAtual])/aConsumo[nAtual])*100
   Next
   nAtual--                                 
Next              

For nX := 1 to  Len(aFormulas)
   aFormulas[nx,2] := Abs(aFormulas[nx,2])
Next

nAtual    :=len(aConsumo)
If nAtual > 0
	aFormulas := aSort(aFormulas,,,{|x,y| x[2] < y[2]})
	cMacroF1 :=aFormulas[1,1]
	cMacroF2 :=aFormulas[2,1]
	cMacroF3 :=aFormulas[3,1]
	cMacroF4 :=aFormulas[4,1]
Endif	

Return { { aFormulas[1,1],aFormulas[1,2],&cMacroF1,aFormulas[1,3] },;
      	{ aFormulas[2,1],aFormulas[2,2],&cMacroF2,aFormulas[2,3] },;
   		{ aFormulas[3,1],aFormulas[3,2],&cMacroF3,aFormulas[3,3] },;
   		{ aFormulas[4,1],aFormulas[4,2],&cMacroF4,aFormulas[4,3] } }

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Mt295Cons � Autor � Alex Sandro Valario   � Data � 14/04/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Acumula no Array aConsumo a demanda dos produtos			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Mt295Cons			 									  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Mata295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/           
Function Mt295Cons(cAnoMes,cCodProd)

Local nX        := 0
Local nLen      := 0
Local nRecnoSBL := SBL->(Recno())
Local nOrdemSBL := SBL->(IndexOrd())
Local cPAnoMes  := ""
Local aConsumo  := {}            
Static nMeses	:= 0 
Static nAnoIni  := 0
Static nMesIni  := 0  

SBL->(DBSetOrder(1))
SBL->(MsSeek(xFilial("SBL")+cCodProd))

While (! SBL->(Eof()) .and. xFilial("SBL")==SBL->BL_FILIAL .and. SBL->BL_PRODUTO ==cCodProd);
	.And. SBL->BL_ANO+SBL->BL_MES <= cAnoMes

	//������������������������������������������������������������������������Ŀ
	//� Adiciona no array a demanda do produto                                 �
	//��������������������������������������������������������������������������
	Aadd(aConsumo,SBL->BL_DEMANDA)
	cPAnoMes := SBL->BL_ANO+SBL->BL_MES

	//������������������������������������������������������������������������Ŀ
	//� Passa para o proximo registro e verfica o produto                      �
	//��������������������������������������������������������������������������
	SBL->(DbSkip())              
	If ! SBL->(Eof()) .and. SBL->BL_PRODUTO ==cCodProd
	
		IF Right(cPAnoMes,2)=="12"
			cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
		Else
			cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
		Endif
		
		While cPAnoMes < SBL->BL_ANO+SBL->BL_MES
			Aadd(aConsumo,0 )      
			IF Right(cPAnoMes,2)=="12"
				cPAnoMes := Str(Val(Left(cPAnoMes,4))+1,4)+"01"
			Else
				cPAnoMes := Left(cPAnoMes,4)+StrZero(Val(Right(cPAnoMes,2))+1,2)
			EndIf   
		EndDo
		
	EndIf
	
EndDo			              

SBL->(DbSetOrder(nOrdemSBL))        
SBL->(DbGoto(nRecnoSBL))

nLen :=len(aConsumo)

If Len(aConsumo) < 120
   For nX := 1 to 120-nLen
      aadd(aConsumo,0)
      aIns(aConsumo,1)
      aConsumo[1] := 0
   Next   
EndIf

Return aConsumo

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � A295Tipo � Autor � Aline Sebrian         � Data � 25/09/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica a existencia do Tipo na Tabela de Parametros.     ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A295Tipo()                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � .T. / .F.                                                  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MatA295                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function A295Tipo()

Local cVar      := &(ReadVar())
Local aArea		:= GetArea()
Local lRet      := .T.

dbSelectArea("SX5")
MsSeek(xFilial("SX5")+"02"+cVar)
If !Found()
	Help(" ",1,"MA01002")
	lRet := .F.
EndIf
RestArea( aArea )
Return(lRet)
