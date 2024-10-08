#INCLUDE "HSPAHR28.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �HSPAHR28  � Autor � Antonio C. Damaceno   � Data � 09.07.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Faturados por Convenio                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   �BOPS  �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Antonio C.  �09/07/07�118003�Implementar                               ���
���Damaceno    �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HSPAHR28()

//���������������������������������������������������������������������Ŀ
//� Declaracao de Variaveis                                             �
//�����������������������������������������������������������������������

Local cDesc1        := STR0001 //"Este programa tem como objetivo imprimir relat�rio "
Local cDesc2        := STR0002 //"de acordo com os par�metros informados pelo usu�rio."
Local cDesc3        := ""
Local Titulo	      	:= STR0003 //"Relat�rio de Faturados por Conv�nio"
Local nMaxLin       := 55
Local Cabec1        := ""
Local Cabec2        := ""
Local aOrd          := {}
Local imprime       := .T.

Private lAbortPrint := .F.
Private lEnd        := .F.
Private limite      := 200
Private tamanho     := "M"
Private nomeprog    := "HSPAHR28"
Private nTipo       := 15
Private aReturn     := { STR0004, 1, STR0005, 1, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey    := 0
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 1
Private wnrel       := "HSPAHR28"
Private cString     := "GCZ"
Private cPerg       := PADR("HSPR28", Len(SX1->X1_GRUPO)) 
Private aQbConv		:= {}   
Private cQbConv		:= "" //quebra do convenio  
Private nTotQtdG :=0  
Private nTotTotG :=0

Pergunte(cPerg, .T.)

//���������������������������������������������������������������������Ŀ
//� Monta a interface padrao com o usuario...                           �
//�����������������������������������������������������������������������
cTitulo  := IIf(MV_PAR04==1,STR0006 + STR0007 + MV_PAR01,IIF(MV_PAR04==2, STR0008 + STR0007 + MV_PAR01, STR0009 + STR0007 + MV_PAR01))  //"GRUPO DE DESPESAS X TIPO DE ATENDIMENTO"###" Mes Ref.: "###"GRUPO DE DESPESAS X UNIDADE DE CONSUMO"###" UNIDADE DE CONSUMO X GRUPO DE DESPESAS"###" Mes Ref.: "
Titulo   := cTitulo

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

//�������������������������������������Ŀ
//� Perguntas                           �
//���������������������������������������

cReferenc := mv_par01     // Mes/Ano Referencia
cConveDe  := mv_par02     // Convenio De
cConveAte := mv_par03     // Convenio Ate
cTipo     := mv_par04     // Tipo Relatorio  (1-Grupo X Tipo Atdimto / 2-Grupo X Und Consumo / 3- Und Consumo X Grupo Despesas)
cRelaAS   := mv_par05     // Sintetico/Analitico
cGrafico  := mv_par06     // Grafico S/N

If cTipo==1
 //                          1         2         3         4         5         6         7         8         9         10        11        12        13        14        15
 //                0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
 Cabec1        := STR0010 //"GRUPO DE DESPESAS                               TIPO DE ATENDIMENTO                  QTDE               TOTAL              %"
ElseIf cTipo==2
 Cabec1        := STR0011 //"GRUPO DE DESPESAS                       UNIDADE DE CONSUMO                           QTDE               TOTAL              %"
Else
 Cabec1        := STR0012 //"UNIDADE DE CONSUMO                              GRUPO DE DESPESAS                    QTDE               TOTAL              %"
EndIf
 
Cabec2        := STR0025  //"CONVENIOS                                                                            QTDE               TOTAL              %"

//���������������������������������������������������������������������Ŀ
//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
//�����������������������������������������������������������������������


RptStatus({|| IIf(cTipo==1, FS_ImpGxT(Cabec1,Cabec2,Titulo,nMaxLin) , FS_ImGxUxG(Cabec1,Cabec2,Titulo,nMaxLin) ) },Titulo)  

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FS_ImpGxT� Autor �Antonio Carlos Damaceno� Data � 09/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para Impressao do Relatorio                         ���
���          � GRUPO DE DESPESAS X TIPO DE ATENDIMENTO                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gestao Hospitalar                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ImpGxT(Cabec1,Cabec2,Titulo,nMaxLin)

//Para montar o vetor inicial
Local aVal1   := {}
Local cCodCon := ""
Local nValCon := 0
Local nVal2   := 0
Local nVal3   := 0
Local cCod1   := ""
Local nValQtd := 0
Local nValVal := 0
Local nFqb	  := 1 
Local nLinA	  := 61
  
//Para mv_par04 == 1 - GRUPO DE DESPESAS X TIPO DE ATENDIMENTO             
cSQL := " SELECT GCZ.GCZ_CODCON CODCON, "
cSQL += " GBI.GBI_CODGDE COD1, "
cSQL += " GCY.GCY_ATENDI COD2, "
cSQL += " CASE WHEN GCY.GCY_ATENDI = '0' THEN 'Hospitalar' ELSE CASE WHEN GCY.GCY_ATENDI = '1' THEN 'Ambulatorio' ELSE 'Pronto Atendimento' END END DES2, "
cSQL += " GE5.GE5_QTDDES QTDDES, " + HS_FValDes("GE5") + " VLRDES "
cSQL += " FROM " + RetSqlName("GE5") + " GE5 "
cSQL += " JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = GE5.GE5_CODDES "
cSQL += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG AND GCZ.GCZ_STATUS > '3' AND GCZ.GCZ_CODCON BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
cSQL += " JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT            AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_MESREF = '" + mv_par01 + "' "
cSQL += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_TPALTA <> '99' "
cSQL += " WHERE GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "

cSQL += " UNION ALL "
cSQL += " SELECT GCZ.GCZ_CODCON CODCON, "
cSQL += " GAA.GAA_CODGDE COD1, "
cSQL += " GCY.GCY_ATENDI COD2, "
cSQL += " CASE WHEN GCY.GCY_ATENDI = '0' THEN 'Hospitalar' ELSE CASE WHEN GCY.GCY_ATENDI = '1' THEN 'Ambulatorio' ELSE 'Pronto Atendimento' END END DES2, "
cSQL += " GE6.GE6_QTDDES QTDDES, " + HS_FValDes("GE6") + " VLRDES "
cSQL += " FROM " + RetSqlName("GE6") + " GE6 "
cSQL += " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = GE6.GE6_CODDES "
cSQL += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG AND GCZ.GCZ_STATUS > '3' AND GCZ.GCZ_CODCON BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
cSQL += " JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT           AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_MESREF = '" + mv_par01 + "' "
cSQL += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_TPALTA <> '99' "
cSQL += " WHERE GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "

cSQL += " UNION ALL "
cSQL += "SELECT GCZ.GCZ_CODCON CODCON, "
cSQL += "GA7.GA7_CODGDE COD1, "
cSQL += "GCY.GCY_ATENDI COD2, "
cSQL += "CASE WHEN GCY.GCY_ATENDI = '0' THEN 'Hospitalar' ELSE CASE WHEN GCY.GCY_ATENDI = '1' THEN 'Ambulatorio' ELSE 'Pronto Atendimento' END END DES2, "
cSQL += "GE7.GE7_QTDDES QTDDES, " + HS_FValDes("GE7") + " VLRDES"
cSQL += " FROM " + RetSqlName("GE7") + " GE7 "
cSQL += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GE7.GE7_CODDES "
cSQL += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_STATUS > '3' AND GCZ.GCZ_CODCON BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
cSQL += " JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT           AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_MESREF = '" + mv_par01 + "' "
cSQL += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_TPALTA <> '99' "
cSQL += " WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
cSQL += "ORDER BY CODCON, COD2, COD1"

cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRY"

DbSelectArea("QRY")

If Eof()
	HS_MsgInf("Nao h� dados a serem impressos para a sele��o efetuada!","Aten��o","Verifique os par�metros") 
	dBCloseArea()
	Return(Nil)
EndIf

cQbConv := ""

While !Eof() 
  If QRY->CODCON <> cQbConv
   AADD(aQbConv,QRY->CODCON)
  EndIf 
  cQbConv := QRY->CODCON
  DbSkip()
End

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

For nFqb := 1 to Len(aQbConv)
	QRY->(DbGoTop())
	aVal1 := {}
	nValQtd := 0
	nValVal := 0
	
	While !Eof()
	    
		If QRY->CODCON == aQbConv[nFqb]
			 cCodCon := QRY->CODCON
			 cDes2   := QRY->DES2
			
			 While !Eof()
			  
			  If QRY->CODCON <> cCodCon
			   Exit
			  EndIf
			
			  If QRY->COD1 <> cCod1
			   aAdd(aVal1, {cCodCon,cCOD1,cDes2,nVal2,nVal3,0})//cCodCon
			   cCod1 := QRY->COD1
			   cDes2 := QRY->DES2
			   nVal2 := 0
			   nVal3 := 0
			  EndIf
			
			  nVal2   += QRY->QTDDES
			  nVal3   += QRY->VLRDES
			  nValCon += QRY->VLRDES
			
			  nValQtd += QRY->QTDDES
			  nValVal += QRY->VLRDES
			
			  DbSkip()
			
			 End
			 	nTotQtdG += nValQtd
			  nTotTotG += nValVal	
			 
			 aAdd(aVal1, {cCodCon,cCOD1,cDes2,nVal2,nVal3,0})
			  
			 FS_Percent(aVal1,nValCon)
			
			 If cRelaAS == 2
			  nLinA := FS_Imprime(aVal1, Cabec1, Cabec2, Titulo, nMaxLin, nValQtd, nValVal,nLinA)
			 Else
			  FS_ImpTot( nValQtd , nValVal , aVal1, Cabec1, Cabec2, Titulo, nMaxLin)
			 EndIf
			 
			 nValCon := 0
			 nPos    := 1
			 nVal2   := 0
			 nVal3   := 0
			 nTotQtd := 0
			 nTotTot := 0
			 aVal1   := {}
			
		EndIf 
		If !Eof()
			DbSkip()
		EndIf
	End
Next nFqb 
	FS_Ger(Cabec1, Cabec2, Titulo, nMaxLin, nValQtd, nValVal,nLinA,NomeProg)

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

dBCloseArea()

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_Percent� Autor �Antonio Carlos Damaceno� Data � 09/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao P/Calcular Percentual em Relacao ao Total Convenio  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gestao Hospitalar                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_Percent(aVal1, nValCon)
Local nFor1   := 0

For nFor1 := 1 to Len(aVal1)

  aVal1[nFor1][6] := (aVal1[nFor1][5] / nValCon) * 100

Next nFor1

Return()


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_ImGxUxG� Autor �Antonio Carlos Damaceno� Data � 23/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para Impressao do Relatorio                         ���
���          � GRUPO DE DESPESAS  X UNIDADE DE CONSUMO E                  ���
���          � UNIDADE DE CONSUMO X GRUPO DE DESPESAS                     ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gestao Hospitalar                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_ImGxUxG(Cabec1,Cabec2,Titulo,nMaxLin)

//Para montar o vetor inicial
Local aVal1   := {}
Local cCodCon := ""
Local nValCon := 0
Local nVal2   := 0
Local nVal3   := 0
Local cCod1   := ""
Local cCod2   := ""
Local nValQtd  := 0
Local nValVal  := 0
Local nFqb	  := 1 
Local nLinA	  := 61

//Para mv_par04 == 2/3 - GRUPO DE DESPESAS X UNIDADE DE CONSUMO   E   UNIDADE DE CONSUMO X GRUPO DE DESPESAS          
cSQL := " SELECT GCZ.GCZ_CODCON CODCON, "
cSQL += " GBI.GBI_CODGDE COD1, "
cSQL += " GCS.GCS_CODUNC COD2, "
cSQL += " GE5.GE5_QTDDES QTDDES, " + HS_FValDes("GE5") + " VLRDES "
cSQL += " FROM " + RetSqlName("GE5") + " GE5 "
cSQL += " JOIN " + RetSqlName("GBI") + " GBI ON GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODUT = GE5.GE5_CODDES "
cSQL += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE5.GE5_NRSEQG AND GCZ.GCZ_STATUS > '3' AND GCZ.GCZ_CODCON BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
cSQL += " JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT            AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_MESREF = '" + mv_par01 + "' "
cSQL += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_TPALTA <> '99' "
cSQL += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GCY.GCY_CODLOC "
cSQL += " WHERE GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' "

cSQL += " UNION ALL "
cSQL += " SELECT GCZ.GCZ_CODCON CODCON, "
cSQL += " GAA.GAA_CODGDE COD1, "
cSQL += " GCS.GCS_CODUNC COD2, "
cSQL += " GE6.GE6_QTDDES QTDDES, " + HS_FValDes("GE6") + " VLRDES "
cSQL += " FROM " + RetSqlName("GE6") + " GE6 "
cSQL += " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD = GE6.GE6_CODDES "
cSQL += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE6.GE6_NRSEQG AND GCZ.GCZ_STATUS > '3' AND GCZ.GCZ_CODCON BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
cSQL += " JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT           AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_MESREF = '" + mv_par01 + "' "
cSQL += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_TPALTA <> '99' "
cSQL += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GCY.GCY_CODLOC "
cSQL += " WHERE GE6.GE6_FILIAL = '" + xFilial("GE6") + "' AND GE6.D_E_L_E_T_ <> '*' "

cSQL += " UNION ALL "
cSQL += " SELECT GCZ.GCZ_CODCON CODCON, "
cSQL += " GA7.GA7_CODGDE COD1, "
cSQL += " GCS.GCS_CODUNC COD2, "
cSQL += " GE7.GE7_QTDDES QTDDES, " + HS_FValDes("GE7") + " VLRDES"
cSQL += " FROM " + RetSqlName("GE7") + " GE7 "
cSQL += " JOIN " + RetSqlName("GA7") + " GA7 ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = GE7.GE7_CODDES "
cSQL += " JOIN " + RetSqlName("GCZ") + " GCZ ON GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_NRSEQG = GE7.GE7_NRSEQG AND GCZ.GCZ_STATUS > '3' AND GCZ.GCZ_CODCON BETWEEN '" + mv_par02 + "' AND '" + mv_par03 + "' "
cSQL += " JOIN " + RetSqlName("GAT") + " GAT ON GAT.GAT_FILIAL = GCZ.GCZ_FILFAT           AND GAT.D_E_L_E_T_ <> '*' AND GAT.GAT_NUMLOT = GCZ.GCZ_NRLOTE AND GAT.GAT_MESREF = '" + mv_par01 + "' "
cSQL += " JOIN " + RetSqlName("GCY") + " GCY ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE AND GCY.GCY_TPALTA <> '99' "
cSQL += " JOIN " + RetSqlName("GCS") + " GCS ON GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_CODLOC = GCY.GCY_CODLOC "
cSQL += " WHERE GE7.GE7_FILIAL = '" + xFilial("GE7") + "' AND GE7.D_E_L_E_T_ <> '*' "
If cTipo == 2                             // GRUPO DE DESPESAS X UNIDADE DE CONSUMO
 cSQL += "ORDER BY CODCON, COD1, COD2"    
ElseIf cTipo == 3                         // UNIDADE DE CONSUMO X GRUPO DE DESPESAS
 cSQL += "ORDER BY CODCON, COD2, COD1"
EndIf
cSql := ChangeQuery(cSql)
TCQUERY cSql NEW ALIAS "QRY"

DbSelectArea("QRY")

If Eof()
	HS_MsgInf("Nao h� dados a serem impressos para a sele��o efetuada!","Aten��o","Verifique os par�metros") 
	dBCloseArea()
	Return(Nil)
EndIf

cQbConv := ""

While !Eof() 
	If QRY->CODCON <> cQbConv
		AADD(aQbConv,QRY->CODCON)
	EndIf 
	cQbConv := QRY->CODCON
	DbSkip()
End

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

SetRegua(RecCount())

For nFqb := 1 to Len(aQbConv)
	QRY->(DbGoTop())
	aVal1 := {}
	nValQtd := 0
	nValVal := 0

	While !Eof()

		If QRY->CODCON == aQbConv[nFqb]
			cCodCon := QRY->CODCON
			cCOD2   := QRY->COD2
			cCOD1   := QRY->COD1
 
			 While !Eof()
			  
			  If QRY->CODCON <> cCodCon
			   Exit
			  EndIf
			
			  If cTipo == 2                             // GRUPO DE DESPESAS X UNIDADE DE CONSUMO
			   If QRY->COD1+QRY->COD2 <> cCod1+cCod2
			    aAdd(aVal1, {QRY->CODCON,cCOD1,cCOD2,nVal2,nVal3,0})
			    cCod1 := QRY->COD1
			    cCod2 := QRY->Cod2
			    nVal2 := 0
			    nVal3 := 0
			   EndIf
			  ElseIf cTipo == 3                         // UNIDADE DE CONSUMO X GRUPO DE DESPESAS
			   If QRY->COD2+QRY->COD1 <> cCod2+cCod1
			    aAdd(aVal1, {QRY->CODCON,cCOD2,cCOD1,nVal2,nVal3,0})
			    cCod1 := QRY->COD1
			    cCod2 := QRY->Cod2
			    nVal2 := 0
			    nVal3 := 0
			   EndIf
			  EndIf
			  
			  nVal2   += QRY->QTDDES
			  nVal3   += QRY->VLRDES
			  nValCon += QRY->VLRDES
			
			  nValQtd += QRY->QTDDES
			  nValVal += QRY->VLRDES
			  
			  DbSkip()
			
			 End
	    nTotQtdG   += nValQtd
     nTotTotG   += nValVal			 
 
		 If cTipo == 2                             // GRUPO DE DESPESAS X UNIDADE DE CONSUMO
		   aAdd(aVal1, {cCodCon,cCOD1,cCOD2,nVal2,nVal3,0})
		   //nValCon  += QRY->VLRDES
		 ElseIf cTipo == 3                         // UNIDADE DE CONSUMO X GRUPO DE DESPESAS
		   aAdd(aVal1, {cCodCon,cCOD2,cCOD1,nVal2,nVal3,0})
		   //nValCon  += QRY->VLRDES
		 EndIf
		
		 FS_Percent(aVal1,nValCon)
		 
		 If cRelaAS == 2
		  nLinA := FS_Imprime(aVal1, Cabec1, Cabec2, Titulo, nMaxLin, nValQtd, nValVal,nLinA)
		 Else
		  FS_ImpTot( nValQtd , nValVal , aVal1, Cabec1, Cabec2, Titulo, nMaxLin)
		 EndIf
		 
		 nValCon := 0
		 nPos    := 1
		 nVal2   := 0
		 nVal3   := 0
		 nTotQtd := 0
		 nTotTot := 0
		 aVal1   := {}
		   
		EndiF 
		If !Eof()
			DbSkip()
		EndIf		
	End
Next nFqb 
FS_Ger(Cabec1, Cabec2, Titulo, nMaxLin, nValQtd, nValVal,nLinA,NomeProg)

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

dBCloseArea()

Return()           
       



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �FS_Imprime� Autor �Antonio Carlos Damaceno� Data � 09/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao P/Imprimir o Relatorio os 3 Tipos                   ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gestao Hospitalar                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function FS_Imprime(aVal1, Cabec1, Cabec2, Titulo, nMaxLin, nValQtd, nValVal,nLin  )

Local nFor1     := 1
//Local nForQb    := 1
Local nTotQtd   := 0
Local nTotTot   := 0
Local nTotQtdTA := 0
Local nTotTotTA := 0
Local nTotQtdGD := 0
Local nTotTotGD := 0
Local nTotQtdUC := 0
Local nTotTotUC := 0
Local cCOD1     := " "
Local cCOD2     := " "
Local cTipoAten := " "
Local cTitGra   := " "
Local aGrafico  := {}  
         
Default nLin      := 61

 //������������������������������������������������������������������Ŀ
 //� Emissao do grafico                                               �
 //��������������������������������������������������������������������
 If cGrafico == 1
  If cTipo == 1
   cTitGra := STR0006 //"GRUPO DE DESPESAS X TIPO DE ATENDIMENTO"
  ElseIf cTipo == 2
   cTitGra := STR0008 //"GRUPO DE DESPESAS X UNIDADE DE CONSUMO"
  Else
   cTitGra := STR0013 //"UNIDADE DE CONSUMO X GRUPO DE DESPESAS"
  Endif 
  aAdd(aGrafico, {nValQtd, nValVal, 100} ) 
  oGraf := HsGRAF():NEW( cTitGra , STR0014, STR0015 , cTitGra , "", "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20) //"Qtde x Valor"###"Qtde"
 EndIf  

	For nFor1 := 1 to Len(aVal1)
		
			IF lAbortPrint
				@ nLin,01 PSAY STR0016 //"*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			
			//If nLin > nMaxLin // Salto de P�gina. Neste caso o formulario tem 55 linhas...
				If nFor1 <= 1 
					Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
					nLin := 9
					@nLin, 000 PSAY STR0017 //"CONVENIO :"
					@nLin, 012 PSAY aVal1[nFor1][1] + " " + HS_IniPadr("GA9", 1, aVal1[nFor1][1], "GA9_NOME" ,, .F. )
					nLin += 2				
				EndIf				
		
		  If cTipo == 1                       // GRUPO DE DESPESAS X TIPO DE ATENDIMENTO
		
		   If aVal1[nFor1][3] <> cTipoAten
		    If nTotQtdTA > 0
		     nLin += 1
		     @nLin, 005 PSAY STR0018 //"TOTAL TIPO DE ATENDIMENTO....."
		     @nLin, 083 PSAY Transform(nTotQtdTA,"@E 99999")
		     @nLin, 098 PSAY Transform(nTotTotTA,"@E 99,999,999.99")
		     nTotQtdTA:=0
		     nTotTotTA:=0
		     nLin += 1
		    EndIf
		    @nLin, 048 PSAY aVal1[nFor1][3]            //Descricao do Tipo de Atendimento
		    cTipoAten := aVal1[nFor1][3]
		    nLin += 1
		   EndIf
		  
		   If aVal1[nFor1][4] > 0
		    @nLin, 000 PSAY aVal1[nFor1][2] + " " + SUBSTR(HS_IniPadr("GAW", 1, aVal1[nFor1][2], "GAW_DESC" ,, .F. ),1,25) //Codigo Grupo Despesas/Descricao
		    @nLin, 083 PSAY Transform(aVal1[nFor1][4],"@E 99999")                          //Quantidade (fazer o TRANSFORM)
		    @nLin, 098 PSAY Transform(aVal1[nFor1][5],"@E 99,999,999.99")               //Total (fazer o TRANSFORM)
		    @nLin, 120 PSAY Transform(aVal1[nFor1][6],"@E 999.99")                      //Percentual (fazer o TRANSFORM)
		                
		    nTotQtd+=aVal1[nFor1][4]
		    nTotTot+=aVal1[nFor1][5]
		
		    nTotQtdTA+=aVal1[nFor1][4]
		    nTotTotTA+=aVal1[nFor1][5]
		
		    nLin += 1
		   Endif  
		
		  ElseIf cTipo == 2                    // GRUPO DE DESPESAS X UNIDADE DE CONSUMO
		
		   If aVal1[nFor1][2] <> cCod1
		    If nTotQtdGD > 0
		     nLin += 1
		     @nLin, 005 PSAY STR0019 //"TOTAL GRUPO DE DESPESA....."
		     @nLin, 083 PSAY Transform(nTotQtdGD,"@E 99999")
		     @nLin, 098 PSAY Transform(nTotTotGD,"@E 99,999,999.99")
		     nTotQtdGD:=0
		     nTotTotGD:=0
		     nLin += 2
		    EndIf
		
		    If aVal1[nFor1][4] > 0
		     @nLin, 000 PSAY aVal1[nFor1][2] + " " + SUBSTR(HS_IniPadr("GAW", 1, aVal1[nFor1][2], "GAW_DESC" ,, .F. ),1,25) // Codigo Grupo Despesas /Descricao
		     cCod1 := aVal1[nFor1][2]
		    EndIf
		   EndIf
		
		   If aVal1[nFor1][4] > 0
		    @nLin, 040 PSAY aVal1[nFor1][3] + " " + SUBSTR(HS_IniPadr("GCT", 1, aVal1[nFor1][3], "GCT_DESUNC" ,, .F.),1,25) // Cod. Tipo Atendimento/Descricao
		    @nLin, 083 PSAY Transform(aVal1[nFor1][4],"@E 99999")                   				                      // Quantidade (fazer o TRANSFORM)
		    @nLin, 098 PSAY Transform(aVal1[nFor1][5],"@E 99,999,999.99")     				                         // Total (fazer o TRANSFORM)
		    @nLin, 120 PSAY Transform(aVal1[nFor1][6],"@E 999.99")         				                            // Percentual (fazer o TRANSFORM)
		    nLin += 1
		   Endif  
		                               
		   nTotQtd+=aVal1[nFor1][4]
		   nTotTot+=aVal1[nFor1][5]
		   nTotQtdGD+=aVal1[nFor1][4]
		   nTotTotGD+=aVal1[nFor1][5]
		 
		  ElseIf cTipo == 3                    // UNIDADE DE CONSUMO X GRUPO DE DESPESAS
		   If aVal1[nFor1][2] <> cCod2
		    If nTotQtdUC > 0
		     nLin += 1
		     @nLin, 005 PSAY STR0020 //"TOTAL UNIDADE DE CONSUMO....."
		     @nLin, 083 PSAY Transform(nTotQtdUC,"@E 99999")
		     @nLin, 098 PSAY Transform(nTotTotUC,"@E 99,999,999.99")
		     nTotQtdUC:=0
		     nTotTotUC:=0
		     nLin += 2
		    EndIf
		
		    If aVal1[nFor1][4] > 0
		     @nLin, 000 PSAY aVal1[nFor1][2] + " " + SUBSTR(HS_IniPadr("GCT", 1, aVal1[nFor1][2], "GCT_DESUNC" ,, .F. ),1,25) // Cod Unidade Consumo/Descricao
		     cCod2 := aVal1[nFor1][2]
		    EndIf
		
		   EndIf
		  
		   If aVal1[nFor1][4] > 0
		    @nLin, 048 PSAY aVal1[nFor1][3] + " " + SUBSTR(HS_IniPadr("GAW", 1, aVal1[nFor1][3], "GAW_DESC" ,, .F. ),1,25) // Cod Grupo Despesas/Descricao
		    @nLin, 083 PSAY Transform(aVal1[nFor1][4],"@E 99999")                          // Quantidade (fazer o TRANSFORM)
		    @nLin, 098 PSAY Transform(aVal1[nFor1][5],"@E 99,999,999.99")                  // Total (fazer o TRANSFORM)
		    @nLin, 120 PSAY Transform(aVal1[nFor1][6],"@E 999.99")                         // Percentual (fazer o TRANSFORM)
		                
		    nTotQtd+=aVal1[nFor1][4]
		    nTotTot+=aVal1[nFor1][5]
		    nTotQtdUC+=aVal1[nFor1][4]
		    nTotTotUC+=aVal1[nFor1][5]
		
		    nLin += 1
		   Endif  
		   
		  EndIf
	  //EndIf
	Next nFor1

	If cTipo == 1                    // GRUPO DE DESPESAS X TIPO DE ATENDIMENTO
	 If nTotQtdTA > 0
	    nLin += 1
	    @nLin, 005 PSAY STR0018 //"TOTAL TIPO DE ATENDIMENTO....."
	    @nLin, 083 PSAY Transform(nTotQtdTA,"@E 99999")
	    @nLin, 098 PSAY Transform(nTotTotTA,"@E 99,999,999.99")
	    nTotQtdTA:=0
	    nTotTotTA:=0
	    nLin += 2
	 EndIf      
	ElseIf cTipo == 2                    // GRUPO DE DESPESAS X UNIDADE DE CONSUMO
	 If nTotQtdGD > 0
	    nLin += 1
	    @nLin, 005 PSAY STR0021 //"TOTAL GRUPO DE DESPESAS....."
	    @nLin, 083 PSAY Transform(nTotQtdGD,"@E 99999")
	    @nLin, 098 PSAY Transform(nTotTotGD,"@E 99,999,999.99")
	    nTotQtdGD:=0
	    nTotTotGD:=0
	    nLin += 2
	 EndIf                                                                
	ElseIf cTipo == 3                    // UNIDADE DE CONSUMO X GRUPO DE DESPESAS
	 If nTotQtdUC > 0
	    nLin += 1
	    @nLin, 005 PSAY STR0020 //"TOTAL UNIDADE DE CONSUMO....."
	    @nLin, 083 PSAY Transform(nTotQtdUC,"@E 99999")
	    @nLin, 098 PSAY Transform(nTotTotUC,"@E 99,999,999.99")
	    nTotQtdUC:=0
	    nTotTotUC:=0
	    nLin += 2
	 EndIf
	EndIf
	  
	If nTotQtd > 0
	   @ nLin,000 PSAY __PrtFatLine()
	   nLin += 1
	   @nLin, 005 PSAY STR0022 //"TOTAL CONVENIO .............."
	   @nLin, 083 PSAY Transform(nTotQtd,"@E 99999")
	   @nLin, 098 PSAY Transform(nTotTot,"@E 99,999,999.99")
	   nLin += 1
	   @ nLin,000 PSAY __PrtFatLine()
	   nLin += 1
	EndIf
	
	


Return(nLin)


  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � FS_ImpTot� Autor �Antonio Carlos Damaceno� Data � 24/07/07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao P/Imprimir Total do Relatorio 3 Tipos e R.Sintetico ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Gestao Hospitalar                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function FS_ImpTot( nValQtd, nValVal, aVal1, Cabec1, Cabec2, Titulo, nMaxLin  )

Local nLin     := 61
Local nFor1    := 1
Local aGrafico := {}

//������������������������������������������������������������������Ŀ
//� Emissao do grafico                                               �
//��������������������������������������������������������������������
If cGrafico == 1
 If cTipo == 1
  cTitGra := STR0006 //"GRUPO DE DESPESAS X TIPO DE ATENDIMENTO"
 ElseIf cTipo == 2
  cTitGra := STR0008 //"GRUPO DE DESPESAS X UNIDADE DE CONSUMO"
 Else
  cTitGra := STR0013 //"UNIDADE DE CONSUMO X GRUPO DE DESPESAS"
 Endif 
 aAdd(aGrafico, {nValQtd, nValVal, 100} ) 
 oGraf := HsGRAF():NEW( cTitGra , STR0014, STR0015, cTitGra , "", "", aGrafico, 1, 1, 0, 0, 2, 17, 6, 6, 25, 20) //"Qtde x Valor"###"Qtde"
EndIf  

//���������������������������������������������������������������������Ŀ
//� SETREGUA -> Indica quantos registros serao processados para a regua �
//�����������������������������������������������������������������������

//SetRegua(RecCount())

IF lAbortPrint
	@ nLin,01 PSAY STR0016 //"*** CANCELADO PELO OPERADOR ***"
 Return
Endif

If nLin > nMaxLin // Salto de P�gina. Neste caso o formulario tem 55 linhas...
 Cabec(Titulo,Cabec2,"",NomeProg,Tamanho,nTipo)
 nLin := 9
 If	cRelaAS == 1
  @nLin, 000 PSAY STR0017 //"CONVENIO :"
  @nLin, 012 PSAY aVal1[nFor1][1] + " " + HS_IniPadr("GA9", 1, aVal1[nFor1][1], "GA9_NOME" ,, .F. )
  nFor1++
  nLin += 2
 Endif
Endif

//cTipo == 1                    // GRUPO DE DESPESAS X TIPO DE ATENDIMENTO
//cTipo == 2                    // GRUPO DE DESPESAS X UNIDADE DE CONSUMO
//cTipo == 3                    // UNIDADE DE CONSUMO X GRUPO DE DESPESAS

If nValQtd > 0
   @ nLin,000 PSAY __PrtFatLine()
   nLin += 1
   @nLin, 005 PSAY STR0024 //"TOTAL GERAL .............."
   @nLin, 083 PSAY Transform(nValQtd,"@E 99999")
   @nLin, 098 PSAY Transform(nValVal,"@E 99,999,999.99")
   @nLin, 120 PSAY Transform(100,"@E 999.99")
   nLin += 1
   @ nLin,000 PSAY __PrtFatLine()
   nLin += 1
EndIf

//���������������������������������������������������������������������Ŀ
//� Finaliza a execucao do relatorio...                                 �
//�����������������������������������������������������������������������

//SET DEVICE TO SCREEN

//���������������������������������������������������������������������Ŀ
//� Se impressao em disco, chama o gerenciador de impressao...          �
//�����������������������������������������������������������������������

/*If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
                                                            
MS_FLUSH()*/

Return(Nil) 




/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HS_VldMA � Autor � Antonio Carlos     � Data �  21/05/07   ���
�������������������������������������������������������������������������͹��
���Descricao � Validar Mes e Ano de referencia                            ���
�������������������������������������������������������������������������͹��
���Uso       � Gestao Hospitalar                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function HS_VldMA()
Local lRet     	:= .T.
Local xConteudo := MV_PAR01
Local nMes := 0

If len(alltrim(xConteudo))<5
	HS_MsgInf(STR0029, STR0027,STR0030) //"Informe o M�s e o Ano corretamente! Ex.: 05/07"###"Aten��o"###"Valida��o do M�s/Ano Refer�ncia"
	lRet := .F.
EndIf                      
	
If lRet .AND. ( !substr(xConteudo,1,1)$"0123456789" .OR. !substr(xConteudo,2,1)$"0123456789" .OR. !substr(xConteudo,4,1)$"0123456789" .OR. !substr(xConteudo,5,1)$"0123456789" )
	HS_MsgInf(STR0031, STR0027,STR0030) //"Utilize apenas n�meros"###"Aten��o"###"Valida��o do M�s/Ano Refer�ncia"
	lRet := .F.	
EndIf

If lRet .AND. substr(xConteudo,3,1) <> "/"
	HS_MsgInf(STR0032, STR0027,STR0030) //"Utilize a barra '/' como separador do M�s/Ano"###"Aten��o"###"Valida��o do M�s/Ano Refer�ncia"
	lRet := .F.	
EndIf                      	
	
nMes := (val(subs(xConteudo,1,2)))
If lRet .AND. (nMes>12 .OR. nMes<1)
	HS_MsgInf(STR0033, STR0027,STR0030) //"Informe o M�s de 01 a 12!"###"Aten��o"###"Valida��o do M�s/Ano Refer�ncia"
	lRet := .F.	
EndIf                      		
	
Return(lRet)

Function FS_Ger(Cabec1, Cabec2, Titulo, nMaxLin, nValQtd, nValVal,nLinA,NomeProg)
Local nLin      := 61
		Cabec(Titulo,Cabec1,"",NomeProg,Tamanho,nTipo)
	   nLin := 9
	   @ nLin,000 PSAY __PrtFatLine()
	   nLin += 2
	   @nLin, 005 PSAY STR0024 //"TOTAL GERAL DO CONVENIO .............."
	   @nLin, 083 PSAY Transform(nTotQtdG,"@E 99999")
	   @nLin, 098 PSAY Transform(nTotTotG,"@E 99,999,999.99")
	   @nLin, 120 PSAY Transform(100,"@E 999.99")
	
	   nLin += 1
	   @ nLin,000 PSAY __PrtFatLine()
	   nLin += 1

	
Return(nil)  










