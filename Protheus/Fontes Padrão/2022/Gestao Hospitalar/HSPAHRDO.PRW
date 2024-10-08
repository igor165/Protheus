#INCLUDE "HSPAHRDO.ch"
#include "rwmake.ch"
#include "TopConn.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � HSPAHRDO � Autor � Gilson da Silva    � Data �  07/05/05   ���
�������������������������������������������������������������������������͹��
���Descricao � PRONTUARIO SEM ATENDIMENTO.                									       ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR.                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Function HSPAHRDO()

 //���������������������������������������������������������������������Ŀ
 //� Declaracao de Variaveis Locais                                      �
 //�����������������������������������������������������������������������
 Local cDesc1         := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2         := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3         := STR0003 //""PRONTUARIO SEM ATENDIMENTO"
 Local cPict          := ""
 Local cPerg          := "HSPRDO"
 Local aOrd           := {}

 //���������������������������������������������������������������������Ŀ
 //� Declaracao de Variaveis Privadas                                    �
 //����������������������������������������������������������������������� 
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private limite       := 80
 Private tamanho      := "P"
 Private nomeprog     := "HSPAHRDO"
 Private nTipo        := 18
 Private aReturn      := { STR0004, 1, STR0005, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbtext       := ""
 Private cbcont       := 00
 Private wnrel        := "HSPAHRDO"
 Private cString      := ""
 Private titulo       := STR0003 //"OCUPACAO DIARIA - RESUMO"
 Private nLin         := 80
 Private Cabec1       := ""
 Private Cabec2       := "" 
 Private m_pag        := 1

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao
 
 //��������������������������������������������������������������������Ŀ
 //� PARAMETROS                                                         �
 //� MV_PAR01	A partir de ?                                             �
 //| MV_PAR02 Impressora ?                                              |
 //����������������������������������������������������������������������
 
 If !Pergunte(cPerg,.T.)
  return
 EndIf                                                                    

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 //���������������������������������������������������������������������Ŀ
 //� Monta a interface padrao com o usuario...                           �
 //�����������������������������������������������������������������������
 wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3, .F.,aOrd,.T.,Tamanho,,.F.)
 If nLastKey == 27
  Return
 Endif
 SetDefault(aReturn,cString)
 If nLastKey == 27
  Return
 Endif
 nTipo := If(aReturn[4]==1,15,18)

 //���������������������������������������������������������������������Ŀ
 //� Processamento. RPTSTATUS monta janela com a regua de processamento. �
 //�����������������������������������������������������������������������
 RptStatus({|| RunReport() },Titulo)

Return


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � Gilson da Silva    � Data �  07/06/05   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � GESTAO HOSPITALAR                                          ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport()
 //���������������������������������������������������������������������Ŀ
 //� Declaracao de Variaveis Locais                                      �
 //����������������������������������������������������������������������� 
	Local nReg  := 0  
	
 cSql := "SELECT COUNT( GBH.GBH_CODPAC) AS SOMA"
 cSql += " FROM " + RetSQLName("GBH") + " GBH "
 cSql += " WHERE GBH.GBH_CODPAC NOT IN (SELECT GCY.GCY_REGGER FROM " 
 cSql += RetSQLName("GCY") + " GCY WHERE GCY.GCY_DATATE >= '" + DTOS(mv_par01) + "' AND " 
 cSql += "  GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' ) AND"
 cSql += "  GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 TCQUERY cSql NEW ALIAS "QRY"
 nReg:= QRY->SOMA
 dbCloseArea()
 
 
 cSql := "SELECT GBH.GBH_CODPAC, GBH.GBH_NOME "
 cSql += " FROM " + RetSQLName("GBH") + " GBH "
 cSql += " WHERE GBH.GBH_CODPAC NOT IN (SELECT GCY.GCY_REGGER FROM " 
 cSql += RetSQLName("GCY") + " GCY WHERE GCY.GCY_DATATE >= '" + DTOS(mv_par01) + "' AND " 
 cSql += "  GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' ) AND"
 cSql += "  GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*' "
 cSql += " ORDER BY GBH.GBH_NOME "                 
 //���������������������������������������������������������������������Ŀ
 //� Definicao da nova alias.                                            �
 //�����������������������������������������������������������������������
 TCQUERY cSql NEW ALIAS "QRY"
 dbSelectArea("QRY")
 dbGoTop()  
  

 //���������������������������������������������������������������������Ŀ
 //� SETREGUA -> Indica quantos registros serao processados para a regua �
 //�����������������������������������������������������������������������
 SetRegua(nReg)

 //���������������������������������������������������������������������Ŀ
 //� Carrega o vetor aRegistros com todos os dados a serem impressos.    �
 //�����������������������������������������������������������������������
 While !EOF() 
	 IncRegua()  

	 //���������������������������������������������������������������������Ŀ
 	//� Verifica o cancelamento pelo usuario...                             �
  //�����������������������������������������������������������������������
  If lAbortPrint
	  @nLin,000 PSAY STR0008 //"*** CANCELADO PELO OPERADOR ***"
 	 Exit
  Endif
		  
	 If nLin > nMaxLin
 		ImpCabec()
	 Endif       
		 
 	//���������������������������������������������������������������������Ŀ
		//� Impressao do detalhe do relatorio. . .                              �
 	//�����������������������������������������������������������������������
	 @nLin,000 PSAY QRY->GBH_CODPAC
 	@nLin,012 PSAY QRY->GBH_NOME
 	nLin++ // Avanca a linha de impressao  
  DbSelectArea("QRY")
  dbSkip()
 EndDo                      
 If nLin > (nMaxLin - 2)
		ImpCabec()
 Endif       
 @nLin + 2, 000 PSAY STR0009 //"Total Prontuarios sem Atendimento:" 
 @nLin + 2, 034 PSAY Transform(nReg, "@E 999,999")  
 
	//Imprime o Rodap�. 
 roda(cbcont,cbtext,Tamanho)
 
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
 DBCloseArea()
Return


//���������������������������������������������������������������������Ŀ
//� Impressao do cabecalho do relatorio. . .                            �
//�����������������������������������������������������������������������
Static Function ImpCabec()
 Cabec1 := STR0006 //"Prontuario  Nome "
 Cabec2 := ""
 nLin:= Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) 
Return