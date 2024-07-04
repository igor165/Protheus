
#INCLUDE "PROTHEUS.CH"
#IFDEF TOP
   #INCLUDE "TOPCONN.CH"
#ENDIF   
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR016 � Autor � Tulio Cesar            � Data � 21.01.05 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de internacao                                    ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR016()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
���          �      �             �                                       ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Associa arquivo de definicoes                                            �
//����������������������������������������������������������������������������
#include "PLSMGER.CH"
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR016()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE nQtdLin     := 58       
PRIVATE cNomeProg   := "PLSR016"
PRIVATE nCaracter   := 15
PRIVATE nLimite     := 220
PRIVATE cTamanho    := "G"      
PRIVATE cTitulo     := "Relatorio de Internacoes Realizadas" 
PRIVATE cDesc1      := "Relatorio de Internacoes Realizadas" 
PRIVATE cDesc2      := "" 
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BE4" 
PRIVATE cPerg       := "PLR016"
PRIVATE cRel        := "PLSR016"
PRIVATE nli         := 999
PRIVATE nQtdini     := nli 
PRIVATE m_pag       := 1   
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .F. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {"Numero da Internacao","Numero do Impresso","Matricula Microsiga","Matricula Antiga"} 
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "Seq   Procedimento   Descricao                                                 Qtd   CID         % Via   RDA                                        Participacao                     Dt Atend  Fator    Vlr Pago   Vlr Glosa" 
PRIVATE cCabec2     := "" 
PRIVATE nColuna     := 03 
PRIVATE cOpeDe  
PRIVATE cOpeAte 
PRIVATE cRdaDe  
PRIVATE cRdaAte 
PRIVATE dDatDe  
PRIVATE dDatAte 
PRIVATE nLisBlo 
PRIVATE nSomInt 
PRIVATE cFase   
PRIVATE lLisBlo 
PRIVATE lSomInt

Pergunte(cPerg,.F.) 

M->BE4_OPERDA := PLSINTPAD()   // PARA XB FUNCIONAR (BQW) - 08/11/2005 - Sandro

//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint (padrao)                                                  �
//����������������������������������������������������������������������������
cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao (padrao)                                    �
//����������������������������������������������������������������������������
If  nLastKey  == 27
    Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
//Pergunte(cPerg,.F.) 
cOpeDe  := mv_par01
cOpeAte := mv_par02
cRdaDe  := mv_par03
cRdaAte := mv_par04
dDatDe  := mv_par05
dDatAte := mv_par06
nLisBlo := mv_par07
nSomInt := mv_par08
cFase   := mv_par09
If  nLisBlo == 1
    lLisBlo := .T.
Else
    lLisBlo := .F.
Endif        
If  nSomInt == 1
    lSomInt := .T.
Else
    lSomInt := .F.
Endif        
//��������������������������������������������������������������������������Ŀ
//� Configura impressora (padrao)                                            �
//����������������������������������������������������������������������������
SetDefault(aReturn,cAlias) 
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
MsAguarde({|| R016Imp() }, cTitulo, "", .T.)
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R016Imp  � Autor � Tulio Cesar           � Data � 21.01.05 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Relatorio de internacao                                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function R016Imp()

//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL cSQL
LOCAL nOrdSel := aReturn[8] 
LOCAL cLinha
LOCAL cRdaAnt
LOCAL cMatric
//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
MsProcTxt(PLSTR0001)
//��������������������������������������������������������������������������Ŀ
//� Monta query...                                                           �
//����������������������������������������������������������������������������
cSQL := "SELECT BE4_CODOPE, BE4_CODRDA, BE4_DATPRO, BE4_DTALTA, BE4_ANOINT, BE4_MESINT, BE4_NUMINT, "
cSQL += "       BE4_SENHA,  BE4_OPEUSR, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO, BE4_NOMUSR, "
cSQL += "       BE4_GRPINT, BE4_TIPINT, BE4_PADCON, BE4_NUMIMP, BE4_OPERDA, BE4_CODLDP, BE4_CODPEG, "
cSQL += "       BE4_NUMERO, BE4_ORIMOV, BE4_MATANT "
cSQL += "FROM " + RetSQLName("BE4")
cSQL += " WHERE BE4_FILIAL  = '" + xFilial("BE4") + "' " 
cSQL +=   " AND BE4_DATPRO <> '' "
cSQL +=   " AND BE4_CODOPE >= '" + cOpeDe         + "' AND BE4_CODOPE <= '" + cOpeAte       + "' "
cSQL +=   " AND BE4_CODRDA >= '" + cRdaDe         + "' AND BE4_CODRDA <= '" + cRdaAte       + "' "
cSQL +=   " AND BE4_DATPRO >= '" + dtos(dDatDe)   + "' AND BE4_DATPRO <= '" + dtos(dDatAte) + "' "
Do Case
   Case nOrdSel == 1
        cSQL += " ORDER BY BE4_CODOPE, BE4_CODRDA, BE4_ANOINT, BE4_MESINT, BE4_NUMINT"
   Case nOrdSel == 2
        cSQL += " ORDER BY BE4_CODOPE, BE4_CODRDA, BE4_NUMIMP"
   Case nOrdSel == 3
        cSQL += " ORDER BY BE4_CODOPE, BE4_CODRDA, BE4_CODEMP, BE4_MATRIC, BE4_TIPREG, BE4_DIGITO"
   Case nOrdSel == 4
        cSQL += " ORDER BY BE4_CODOPE, BE4_CODRDA, BE4_MATANT"
EndCase
//��������������������������������������������������������������������������Ŀ
//� Executa query...                                                         �
//����������������������������������������������������������������������������
PLSQuery(cSQL,"Trb")
//��������������������������������������������������������������������������Ŀ
//� Seleciona indices                                                        �
//����������������������������������������������������������������������������
BA1->(dbSetOrder(2))
BQR->(dbSetOrder(1))
BD7->(dbSetOrder(1))
//��������������������������������������������������������������������������Ŀ
//� Navega pelos registros selecionados...                                   �
//����������������������������������������������������������������������������
While ! Trb->(Eof())
   //��������������������������������������������������������������������Ŀ
   //� Exibe mensagem...                                                  �
   //����������������������������������������������������������������������
   MsProcTXT("Imprimindo GIH "+Trb->(BE4_ANOINT+"."+BE4_MESINT+"-"+BE4_NUMINT)+"...")
   //��������������������������������������������������������������������Ŀ
   //� Verifica se foi abortada a impressao...                            �
   //����������������������������������������������������������������������
   If  Interrupcao(lAbortPrint)
       nLi ++
       @ nLi, nColuna pSay PLSTR0002
       Exit
   Endif                       
   //��������������������������������������������������������������������Ŀ
   //� Imprime nome da RDA                                                �
   //����������������������������������������������������������������������
   nli := 999
   cLinha  := "RDA: " + Trb->BE4_CODRDA + " " + posicione("BAU",1,xFilial("BAU")+Trb->BE4_CODRDA,"BAU_NOME")
   R016Linha(cLinha,1,0)
   //��������������������������������������������������������������������Ŀ
   //� Inicializa campos da RDA                                           �
   //����������������������������������������������������������������������
   cRdaAnt := Trb->BE4_CODRDA
   //��������������������������������������������������������������������Ŀ
   //� Processa todas as internacoes desta RDA                            �
   //����������������������������������������������������������������������
   While ! Trb->(eof()) .and. Trb->BE4_CODRDA == cRdaAnt
      //��������������������������������������������������������������������Ŀ
      //� Inicializ variaveis                                                �
      //����������������������������������������������������������������������
      cMatric := Trb->BE4_OPEUSR + Trb->BE4_CODEMP + Trb->BE4_MATRIC + Trb->BE4_TIPREG + Trb->BE4_DIGITO
      //��������������������������������������������������������������������Ŀ
      //� Posiciona tabelas                                                  �
      //����������������������������������������������������������������������
      BA1->(dbSeek(xFilial("BA1")+cMatric))
      BQR->(dbSeek(xFilial("BQR")+Trb->BE4_GRPINT+Trb->BE4_TIPINT))
      BN5->(dbSeek(xFilial("BN5")+Trb->BE4_CODOPE+Trb->BE4_PADCON))
      //��������������������������������������������������������������������Ŀ
      //� Imprime dados do usuario                                           �
      //����������������������������������������������������������������������
      cLinha  := "Usuario: " + transform(cMatric,"@R XXXX.XXXX.XXXXXX.XX-X") + space(1) + ;
                 substr(BA1->BA1_NOMUSR,1,40) + space(1) + ;
                 "Dt Intern: " + dtoc(Trb->BE4_DATPRO) + space(2) + ;
                 "Tipo: " + substr(BQR->BQR_DESTIP,1,15) + space(1) + ;
                 "Impresso: " + Trb->BE4_NUMIMP + space(2) + ;
                 "Autoriz: " + transform(Trb->(BE4_OPERDA+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),"@R XXXX.XXXX.XX.XXXXXXXX") + space(2) + ;
                 "Pad Conforto: " + transform(BN5->BN5_FATMUL,"@E 9.99") + space(1) + ;
                 "Mat Ant: " + Trb->BE4_MATANT
      R016Linha(cLinha,2,0)
      //��������������������������������������������������������������������������Ŀ
      //� Monta query...                                                           �
      //����������������������������������������������������������������������������
      cSQL := "SELECT BD6_CODOPE, BD6_CODLDP, BD6_CODPEG, BD6_NUMERO, BD6_NUMIMP, BD6_CODPAD, BD6_CODPRO, "
      cSQL += "       BD6_QTDPRO, BD6_CID,    BD6_PERVIA, BD6_ORIMOV, BD6_SEQUEN "
      cSQL += " FROM " + RetSQLName("BD6")
      If  lSomInt
          cSQL += " WHERE BD6_FILIAL  = '" + xFilial("BD6")        + "' " 
          cSQL +=   " AND BD6_CODOPE  = '" + Trb->BE4_CODOPE       + "' "
          cSQL +=   " AND BD6_CODLDP  = '" + Trb->BE4_CODLDP       + "' "
          cSQL +=   " AND BD6_CODPEG  = '" + Trb->BE4_CODPEG       + "' "
          cSQL +=   " AND BD6_NUMERO  = '" + Trb->BE4_NUMERO       + "' "
          cSQL +=   " AND BD6_ORIMOV  = '" + Trb->BE4_ORIMOV       + "' "
      Else
          cSQL += " WHERE BD6_FILIAL  = '" + xFilial("BD6")        + "' " 
          cSQL +=   " AND BD6_OPEUSR  = '" + Trb->BE4_OPEUSR       + "' "
          cSQL +=   " AND BD6_CODEMP  = '" + Trb->BE4_CODEMP       + "' "
          cSQL +=   " AND BD6_MATRIC  = '" + Trb->BE4_MATRIC       + "' "
          cSQL +=   " AND BD6_TIPREG  = '" + Trb->BE4_TIPREG       + "' "
          cSQL +=   " AND BD6_DIGITO  = '" + Trb->BE4_DIGITO       + "' "
          cSQL +=   " AND BD6_DATPRO >= '" + dtos(Trb->BE4_DATPRO) + "' "
          If  ! empty(Trb->BE4_DTALTA)
              cSQL += " AND BD6_DATPRO <= '" + dtos(Trb->BE4_DTALTA) + "' "
          Endif
      Endif
      If  ! empty(cFase)
          cSQL +=   " AND BD6_FASE IN (" + cFase + ") "
      Endif          
      cSQL +=   " AND (BD6_SITUAC = '1' OR (BD6_SITUAC = '3' AND BD6_LIBERA = '1')) " // 1-ATIVO 3-BLOQ  
      cSQL += " ORDER BY BD6_CODLDP, BD6_CODPEG, BD6_NUMERO"
      //��������������������������������������������������������������������������Ŀ
      //� Executa query...                                                         �
      //����������������������������������������������������������������������������
      PLSQuery(cSQL,"TrbBD6")
      //��������������������������������������������������������������������Ŀ
      //� Processa todas as guias deste usuario                              �
      //����������������������������������������������������������������������
      While ! TrbBD6->(eof())
         //��������������������������������������������������������������������Ŀ
         //� Imprime identificaco da guia                                       �
         //����������������������������������������������������������������������
         cLinha  := "Guia: " + transform(TrbBD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV),"@R XXXX.XXXXXXXX.XXXXXXXX") + ;
                    "   Impresso: " + TrbBD6->BD6_NUMIMP
         R016Linha(cLinha,2,1)
         //��������������������������������������������������������������������Ŀ
         //� Imprime todas os prodedimentos desta guia                          �
         //����������������������������������������������������������������������
         cGuiAnt := TrbBD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
         While ! TrbBD6->(eof()) .and. TrbBD6->(BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV) == cGuiAnt
            //��������������������������������������������������������������������Ŀ
            //� Monta dados da guia                                                �
            //����������������������������������������������������������������������
            cGuia := TrbBD6->BD6_SEQUEN + space(3) + ;
                     TrbBD6->BD6_CODPAD + space(1) + ;
                     transform(TrbBD6->BD6_CODPRO,"@R XX.XX.XXX-X") + space(1) + ;
                     substr(posicione("BR8",1,xFilial("BR8")+TrbBD6->(BD6_CODPAD+BD6_CODPRO),"BR8_DESCRI"),1,56) + space(3) + ;
                     transform(TrbBD6->BD6_QTDPRO,"@E 99") + space(3) + ;
                     TrbBD6->BD6_CID + space(3) + ;
                     transform(TrbBD6->BD6_PERVIA,"@E 999.99") + space(3) 
            //R016Linha(" ",1,0)
            //��������������������������������������������������������������������Ŀ
            //� Posiciona BD7-Composicao do Procedimento                           �
            //����������������������������������������������������������������������
            BD7->(dbSeek(xFilial("BD7")+TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
            While ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
                                        xFilial("BD7")+TrbBD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
               //��������������������������������������������������������������������Ŀ
               //� Salta itens bloqueados                                             �
               //����������������������������������������������������������������������
               If  ! lLisBlo .and. ;
                   BD7->BD7_BLOPAG == "1"
                   BD7->(dbSkip())
                   Loop
               Endif                    
               //��������������������������������������������������������������������Ŀ
               //� Imprime composicao do procedimento                                 �
               //����������������������������������������������������������������������
               cLinha := cGuia + ;
                         posicione("BAU",1,xFilial("BAU")+BD7->BD7_CODRDA,"BAU_NOME") + space(3) + ;
                         substring(posicione("BWT",1,xFilial("BWT")+BD7->(BD7_CODOPE+BD7_CODTPA),"BWT_DESCRI"),1,30) + space(3) + ;
                         dtoc(BD7->BD7_DATPRO) + space(3) + ;
                         transform(BD7->BD7_FATMUL,"@E 9.99") + space(3) + ;
                         transform(BD7->BD7_VLRPAG,"@E 99,999.99") + space(3) + ;
                         transform(BD7->BD7_VLRGLO,"@E 99,999.99")      
               R016Linha(cLinha,1,0)
               cGuia := space(105)
               //��������������������������������������������������������������������Ŀ
               //� Acessa proximo registro                                            �
               //����������������������������������������������������������������������
               BD7->(dbSkip())
            Enddo
            //��������������������������������������������������������������������Ŀ
            //� Acessa proximo registro                                            �
            //����������������������������������������������������������������������
            TrbBD6->(dbSkip())
         Enddo
      Enddo
      //��������������������������������������������������������������������Ŀ
      //� Fecha arquivo de trabalho                                          �
      //����������������������������������������������������������������������
      TrbBD6->(DbCloseArea())
      //��������������������������������������������������������������������Ŀ
      //� Imprime separador de linhas                                        �
      //����������������������������������������������������������������������
      R016Linha(replicate("-",220),2,0)
      //��������������������������������������������������������������������Ŀ
      //� Acessa proximo registro...                                         �
      //����������������������������������������������������������������������
      Trb->(DbSkip())
   Enddo
Enddo   
//��������������������������������������������������������������������Ŀ
//� Fecha arquivo...                                                   �
//����������������������������������������������������������������������
Trb->(DbCloseArea())
//��������������������������������������������������������������������������Ŀ
//� Rodape                                                                   �
//����������������������������������������������������������������������������
Roda(0,space(10),cTamanho)
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  aReturn[5] == 1 
    Set Printer To
    Ourspool(cRel)
Endif
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R016Linha � Autor � Angelo Sperandio     � Data � 23.01.05 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime linha de detalhe                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function R016Linha(cLinha,nAntes,nApos)

//��������������������������������������������������������������������������Ŀ
//� Declara variaveis                                                        �
//����������������������������������������������������������������������������
LOCAL i 
//��������������������������������������������������������������������������Ŀ
//� Salta linhas antes                                                       �
//����������������������������������������������������������������������������
For i := 1 to nAntes
    nli++
Next    
//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho                                                        �
//����������������������������������������������������������������������������
If  nli > nQtdLin
    nli := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
    nli++
Endif    
//��������������������������������������������������������������������������Ŀ
//� Imprime linha de detalhe                                                 �
//����������������������������������������������������������������������������
@ nLi, 0 pSay cLinha
//��������������������������������������������������������������������������Ŀ
//� Salta linhas apos                                                        �
//����������������������������������������������������������������������������
For i := 1 to nApos
    nli++
Next    
//��������������������������������������������������������������������������Ŀ
//� Fim da funcao                                                            �
//����������������������������������������������������������������������������
Return()

