
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#include "topconn.CH"
static objCENFUNLGP := CENFUNLGP():New() 
static lautoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR983 � Autor � Thiago Machado Correa  � Data � 27/08/04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de saldo de Auto-Gerados da Rda				  ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR983()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSR983(lAuto)

//��������������������������������������������������������������������������Ŀ
//� Define variaveis...									                     �
//����������������������������������������������������������������������������
Local aOrdens := {}   
Local cAlias  := "BD7"
Local cOperad := ""
Local cMesIni := ""
Local cAnoIni := ""
Local cMesFim := ""
Local cAnoFim := ""
Local cSeqIni := ""
Local cSeqFim := ""
Local cRdaIni := ""
Local cRdaFim := ""     
Local cTmp    := ""
Local cTitOri := ""
Local nTmp    := 0
Local nQtdRel := 0
Local nOpca   := 0

default lauto := .F.

Private wnrel
Private cDesc1      := "Saldo de Auto-Gerados"
Private cDesc2      := ""
Private cDesc3      := ""
Private cTitulo     := "Saldo de Auto-Gerados"
Private cCabec1     := "Usuario                 Nome do Usuario                  Procedimento       Descricao                        Data                Valor"
Private cCabec2     := ""
Private cNomeProg   := "PLSR983"
Private cPerg       := "PLR983"
Private Li          := 01
Private m_pag       := 1
Private aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
Private cTamanho	:= "G"
Private lDicion     := .F.
Private lCompres    := .F.
Private lCrystal    := .F.
Private lFiltro     := .T.
Private lAbortPrint := .F.                                                                       
Private aStru		:= {}
Private nColuna     := 00
Private nLimite     := 220
Private nPagina     := 1

lautoSt := lauto

//-- LGPD ----------
if !lAuto .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif
//------------------

//��������������������������������������������������������������������������Ŀ
//� Ajusta SX1...							                                 �
//����������������������������������������������������������������������������
AjustaSX1()

//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
wnrel := "PLSR983"
If !lAuto
	wnRel := SetPrint(cAlias, wnRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,,cTamanho,,lFiltro, lCrystal)
endIf
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If !lAuto .AND. nLastKey  == 27 
   Return
Endif

//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.f.)
cOperad := mv_par01
cMesIni := mv_par02
cAnoIni := mv_par03
cMesFim := mv_par04
cAnoFim := mv_par05
cSeqIni := mv_par06
cSeqFim := mv_par07
cRdaIni := mv_par08
cRdaFim := mv_par09

If !lAuto
	cOperad := "0001"
	cMesIni := "12"
	cAnoIni := "2020"
	cMesFim := "01"
	cAnoFim := "2021"
	cSeqIni := "000"
	cSeqFim := "001"
	cRdaIni := "      "
	cRdaFim := "ZZZZZZ"
Endif
cTmp := cAnoIni+cMesIni

While cTmp <= cAnoFim+cMesFim

	cTmp := substr(dtos(stod(cTmp+"15")+30),1,6)

	nQtdRel++
EndDo

cTmp := cAnoIni+cMesIni
cTitOri := cTitulo

//��������������������������������������������������������������������������Ŀ
//� Configura impressora                                                     �
//����������������������������������������������������������������������������
if !lAuto  
	SetDefault(aReturn,cAlias)       
endIf
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
For nTmp := 1 to nQtdRel
	if !lAuto 
		RptStatus({|| PLSR983IMP(cOperad,cTmp,cRdaIni,cRdaFim,cTitOri,cSeqIni,cSeqFim) },cDesc1,"Processando... Competencia "+substr(cTmp,5,2)+"/"+substr(cTmp,1,4))
	else
		PLSR983IMP(cOperad,cTmp,cRdaIni,cRdaFim,cTitOri,cSeqIni,cSeqFim)
	endIf
	cTmp := substr(dtos(stod(cTmp+"15")+30),1,6)
Next	

//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If !lAuto .AND.  aReturn[5] == 1 
    Set Printer To
    Ourspool(wnRel)
Endif

//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   �PLSR983IMP� Autor � Thiago Machado Correa � Data � 27/08/04 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime detalhe do relatorio...                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function PLSR983IMP(cOperad,cCompet,cRdaIni,cRdaFim,cTitOri,cSeqIni,cSeqFim)

//��������������������������������������������������������������������������Ŀ
//� Inicializa variaveis                                                     �
//����������������������������������������������������������������������������
Local cSQL     := ""
Local cLinha   := ""
Local cRdaAtu  := ""
Local cEspAtu  := ""
Local cChave   := ""
Local nQtdReg  := 0  
Local nVal     := 0
Local nTotEsp  := 0
Local nTotRda  := 0
Local nTotGer  := 0
Local nQtdLin  := 64
Local cBD7Name := RetSQLName("BD7")
Local cMvNORM  := GetMv("MV_NORM")

cTitulo := alltrim(Upper(cTitOri)) + "   -   Competencia: " + substr(cCompet,5,2) + "/" + substr(cCompet,1,4)

//��������������������������������������������������������������������������Ŀ
//� Seleciona indice                                                         �
//����������������������������������������������������������������������������
BAU->(DbSetOrder(1))
BAQ->(DbSetOrder(1))
BR8->(DbSetOrder(1))
BD7->(DbSetOrder(1))
BA1->(DbSetOrder(2))

//��������������������������������������������������������������������������Ŀ
//� Prepara Query para Regua...                                              �
//����������������������������������������������������������������������������
cSQL := " SELECT COUNT(*) QTD FROM " + cBD7Name
cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_BLQAUG = '1' AND "
cSQL +=       " BD7_CODOPE = '" + cOperad        + "' AND "
cSQL += 	  " BD7_PERBLQ <= '"  + cCompet + "' AND "
cSQL += 	  " ((BD7_PERDES > '"  + cCompet + "' ) OR (BD7_PERDES = '      ' )) AND "
cSQL += 	  " BD7_SEQBLQ >= '" + cSeqIni + "' AND "
cSQL += 	  " BD7_SEQBLQ <= '" + cSeqFim + "' AND "
cSQL += 	  " BD7_CODRDA >= '" + cRdaIni + "' AND "
cSQL += 	  " BD7_CODRDA <= '" + cRdaFim + "' AND "
cSQL += " D_E_L_E_T_ <> '*' "

//��������������������������������������������������������������������������Ŀ
//� Executa a query...								                         �
//����������������������������������������������������������������������������
PLSQuery(cSQL,"TMP")

//��������������������������������������������������������������������������Ŀ
//� Prepara Regua...    			                                         �
//����������������������������������������������������������������������������
nQtdReg := TMP->QTD
if !lAutoSt
	SetRegua(nQtdReg)
endIf
//��������������������������������������������������������������������������Ŀ
//� Seleciona registros                                                      �
//����������������������������������������������������������������������������
cSQL := " SELECT BD7_CODOPE, BD7_CODLDP, BD7_CODPEG, BD7_NUMERO, BD7_ORIMOV, BD7_SEQUEN, BD7_CODPAD, BD7_CODPRO, BD7_SEQBLQ, BD7_PGTBLQ, BD7_SEQDES, BD7_PGTDES, BD7_CODRDA, BD7_VLRPAG, BD7_VLRBLO, BD7_BLOPAG, BD7_CODESP FROM " + cBD7Name
cSQL += " WHERE BD7_FILIAL = '" + xFilial("BD7") + "' AND BD7_BLQAUG = '1' AND "
cSQL +=       " BD7_CODOPE = '" + cOperad        + "' AND "
cSQL += 	  " BD7_PERBLQ <= '"  + cCompet + "' AND "
cSQL += 	  " ((BD7_PERDES > '"  + cCompet + "' ) OR (BD7_PERDES = '      ' )) AND "
cSQL += 	  " BD7_SEQBLQ >= '" + cSeqIni + "' AND "
cSQL += 	  " BD7_SEQBLQ <= '" + cSeqFim + "' AND "
cSQL += 	  " BD7_CODRDA >= '" + cRdaIni + "' AND "
cSQL += 	  " BD7_CODRDA <= '" + cRdaFim + "' AND "
cSQL += " D_E_L_E_T_ <> '*' "
cSQL += " ORDER BY BD7_CODRDA, BD7_CODESP, BD7_OPEUSR, BD7_CODEMP, BD7_MATRIC, BD7_TIPREG "

//��������������������������������������������������������������������������Ŀ
//� Fecha o arquivo TMP, para abri-lo com a query                            �
//����������������������������������������������������������������������������
TMP->(dbCloseArea())
PLSQuery(cSQL,"TMP")

//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho...				                                     �
//����������������������������������������������������������������������������
If !lAutoSt .AND. nQtdReg > 0
	Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,GetMv("MV_NORM"))
Endif

//��������������������������������������������������������������������������Ŀ
//� Processa TMP...					                                         �
//����������������������������������������������������������������������������
While ! TMP->(Eof())

   //�����������������������������������������������������������������������Ŀ
   //� Incrementa Regua...			                                         �
   //�������������������������������������������������������������������������
   	If !lAutoSt
   		IncRegua()
	endIf
   //�����������������������������������������������������������������������Ŀ
   //� Verifica se foi cancelada a impressao                                 �
   //�������������������������������������������������������������������������
   If !lAutoSt .AND. Interrupcao(lAbortPrint)
       Exit
   Endif                       
  	   
   //�����������������������������������������������������������������������Ŀ
   //� Pocisiona Rda...							                             �
   //�������������������������������������������������������������������������
   If ! BAU->(DBSeek(xFilial("BAU")+TMP->BD7_CODRDA))
       TMP->(DBSkip())
       Loop
   Endif    
   
   //��������������������������������������������������������������������������Ŀ
   //� Imprime cabecalho...				                                     	�
   //����������������������������������������������������������������������������
   If !lAutoSt .AND. Li+3 > nQtdLin
	   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
   Endif                                                                        

   @ Li,nColuna pSay "Rede de Atendimento: " + BAU->BAU_CODIGO + " - " + BAU->BAU_NOME
   Li ++ 		
   @ Li,nColuna pSay replicate("-",nLimite)
   Li ++ 		               
   @ Li,nColuna pSay ""
   Li ++ 

   cRdaAtu := TMP->BD7_CODRDA
   	   
   While (TMP->BD7_CODRDA==cRdaAtu) .and. TMP->(!Eof())

	   //�����������������������������������������������������������������������Ŀ
	   //� Pocisiona Especialidade...				                             �
	   //�������������������������������������������������������������������������
	   If ! BAQ->(DBSeek(xFilial("BAQ")+cOperad+TMP->BD7_CODESP))
	       TMP->(DBSkip())
	       Loop
	   Endif    
			   
	   //��������������������������������������������������������������������������Ŀ
	   //� Imprime cabecalho...				                                     	�
	   //����������������������������������������������������������������������������
	   If !lAutoSt .AND.  Li+3 > nQtdLin
		   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
	   Endif                                                                        
	
	   @ Li,nColuna pSay "Especialidade: " + BAQ->BAQ_CODESP + " - " + BAQ->BAQ_DESCRI
	   Li ++ 		
	   @ Li,nColuna pSay replicate("-",nLimite)
	   Li ++ 		               
	   @ Li,nColuna pSay ""
	   Li ++ 

   	   cEspAtu := TMP->BD7_CODESP
   	   
	   While (TMP->BD7_CODRDA==cRdaAtu) .and. (TMP->BD7_CODESP==cEspAtu) .and. TMP->(!Eof())

		   //�����������������������������������������������������������������������Ŀ
		   //� Pocisiona Tabela Padrao...				                             �
		   //�������������������������������������������������������������������������
		   If ! BR8->(DBSeek(xFilial("BR8")+TMP->BD7_CODPAD+TMP->BD7_CODPRO))
		       TMP->(DBSkip())
		       Loop
		   Endif    
		   
		   //�����������������������������������������������������������������������Ŀ
		   //� Posiciona BD7...														 �
           //�������������������������������������������������������������������������
           If ! BD7->(DbSeek(xFilial("BD7")+TMP->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)))
		       TMP->(DBSkip())
		       Loop
		   Endif    
			
		   //�����������������������������������������������������������������������Ŀ
		   //� Posiciona BA1...														 �
           //�������������������������������������������������������������������������
           If ! BA1->(DbSeek(xFilial("BA1")+BD7->(BD7_OPEUSR+BD7_CODEMP+BD7_MATRIC+BD7_TIPREG)))
		       TMP->(DBSkip())
		       Loop
		   Endif    

       	   cLinha := BA1->BA1_CODINT + "." + BA1->BA1_CODEMP + "." + BA1->BA1_MATRIC + "." + BA1->BA1_TIPREG + "-" + BA1->BA1_DIGITO
           cLinha += Space(3)
           cLinha += substr(BA1->BA1_NOMUSR,1,30)
           cLinha += Space(3)
           cLinha += BR8->BR8_CODPSA
           cLinha += Space(3)
           cLinha += substr(BR8->BR8_DESCRI,1,30)
           cLinha += Space(3)
           cLinha += dtoc(BD7->BD7_DATPRO)
           cLinha += Space(3)

		   nVal := 0

		   cChave := TMP->BD7_CODRDA + TMP->BD7_CODESP
		   cChave += TMP->(BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

		   While cChave == (TMP->(BD7_CODRDA+BD7_CODESP+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)) .and. TMP->(!Eof())

			   If TMP->BD7_BLOPAG == "1"
				   nVal += TMP->BD7_VLRBLO
               Else
				   nVal += TMP->BD7_VLRPAG
			   Endif	   

		       TMP->(DBSkip())
           EndDo
                   
		   cLinha += Transform(nVal,"@E 999,999,999.99")

		   //�������������������������������������������������������������������Ŀ
		   //� Imprime cabecalho...			                					 �
		   //���������������������������������������������������������������������
		   If !lAutoSt .AND. Li > nQtdLin
			   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
		   Endif
		   
		   @ Li,nColuna pSay cLinha
		   Li ++ 

		   //�������������������������������������������������������������������Ŀ
		   //� Acumula valores                                                   �
		   //���������������������������������������������������������������������
		   nTotEsp += nVal
       EndDo  
       
	   //�������������������������������������������������������������������Ŀ
	   //� Imprime cabecalho...			                				  	 �
	   //���������������������������������������������������������������������
	   If !lAutoSt .AND. Li+4 > nQtdLin
	       Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
	   Endif  
	   
	   @ Li,nColuna pSay ""
	   Li ++ 
	   @ Li,nColuna pSay "Total da Especialidade: "  + Space(96) + Transform(nTotEsp,"@E 999,999,999.99")
	   Li ++ 
	   @ Li,nColuna pSay replicate("-",nLimite)
	   Li ++
	   @ Li,nColuna pSay ""
	   Li ++

	   //�������������������������������������������������������������������Ŀ
	   //� Acumula valores                                                   �
	   //���������������������������������������������������������������������
	   nTotRda += nTotEsp
	   nTotEsp := 0
       
   EndDo  
       
   //�������������������������������������������������������������������Ŀ
   //� Imprime cabecalho...			                				  	 �
   //���������������������������������������������������������������������
   If !lAutoSt .AND. Li+3 > nQtdLin
       Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
   Endif  
   
   @ Li,nColuna pSay "Total da Rda: "  + Space(106) + Transform(nTotRda,"@E 999,999,999.99")
   Li ++ 
   @ Li,nColuna pSay replicate("-",nLimite)
   Li ++
   @ Li,nColuna pSay ""
   Li ++

   //�������������������������������������������������������������������Ŀ
   //� Acumula valores                                                   �
   //���������������������������������������������������������������������
   nTotGer += nTotRda
   nTotRda := 0       

EndDo

//�������������������������������������������������������������������Ŀ
//� Imprime cabecalho...			                				  �
//���������������������������������������������������������������������
If !lAutoSt .AND. Li+4 > nQtdLin
    Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,cMvNORM)
Endif  

If nTotGer > 0   
	@ Li,nColuna pSay ""
	Li ++ 
	@ Li,nColuna pSay replicate("=",nLimite)
	Li ++ 
	@ Li,nColuna pSay "Total Geral: "  + Space(107) + Transform(nTotGer,"@E 999,999,999.99")
	Li ++ 
	@ Li,nColuna pSay replicate("=",nLimite)
	Li ++
Endif
//��������������������������������������������������������������������������Ŀ
//� Fecha arquivo principal...                                               �
//����������������������������������������������������������������������������
TMP->(dbCloseArea())

//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return

/*
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������ͻ��
���Programa  �AjustaSX1 �Autor  �Thiago Machado Correa� Data �  25/08/04   ���
��������������������������������������������������������������������������͹��
���Desc.     �Cria o pergunte padrao                                       ���
��������������������������������������������������������������������������͹��
���Uso       � AP                                                          ���
��������������������������������������������������������������������������ͼ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
*/
Static Function AjustaSX1()

Local aRegs	:=	{}

aadd(aRegs,{"PLR983","01","Operadora"   ,"","","mv_ch1","C", 4,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","B39",""})
aadd(aRegs,{"PLR983","02","Mes Inicial" ,"","","mv_ch2","C", 2,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR983","03","Ano Inicial" ,"","","mv_ch3","C", 4,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR983","04","Mes Final"   ,"","","mv_ch4","C", 2,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR983","05","Ano Final"   ,"","","mv_ch5","C", 4,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR983","06","Seq. Inicial","","","mv_ch6","C", 2,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR983","07","Seq. Final"  ,"","","mv_ch7","C", 2,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
aadd(aRegs,{"PLR983","08","Rda Inicial" ,"","","mv_ch8","C", 6,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","BAU",""})
aadd(aRegs,{"PLR983","09","Rda Final"   ,"","","mv_ch9","C", 6,0,0,"G","","mv_par09","","","","","","","","","","","","","","","","","","","","","","","","","BAU",""})

PlsVldPerg( aRegs )


Return
