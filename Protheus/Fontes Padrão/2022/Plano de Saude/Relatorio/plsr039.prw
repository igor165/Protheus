#INCLUDE "PROTHEUS.CH"
#include "PLSMGER.CH"
#Define PLSVALOR "@E 99,999,999,999.99"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR039 � Autor � Eduardo Motta          � Data � 12.05.04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Movimentacao Familia                          ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR039()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��� 31.01.05 � BOPS � Tulio Cesar � Melhorias no relatorio.               ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSR039(lAuto)

Default lAuto := .F.
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE nQtdLin     := 55
PRIVATE cNomeProg   := "PLR039"
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := "Movimentacao da Familia"
PRIVATE cDesc1      := "Movimentacao da Familia"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BDH"
PRIVATE nRel        := "PLSR039"
PRIVATE nLi         := 999
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .F.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {"Por Familia","Por Familia - Mat Ant","Por Subcontrato"}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "Codigo do Usuario     Nome                                              Matricula da Empresa/Origem"
PRIVATE cCabec2     := "                      Dt.Atend    N.Debito   Quant Codigo AMB       Procedimento                                      Vlr.Cop/CO"
PRIVATE nColuna     := 03 // Numero da coluna que sera impresso as colunas
PRIVATE nCaracter   := 15
PRIVATE cPerg       := "PLR039"
PRIVATE nUsrVlr     := 0
PRIVATE nFamVlr     := 0
PRIVATE nFamBas     := 0
PRIVATE nFamIns     := 0
PRIVATE nSubVlr     := 0
PRIVATE nSubBas     := 0
PRIVATE nSubIns     := 0
PRIVATE nConVlr     := 0
PRIVATE nConBas     := 0
PRIVATE nConIns     := 0
PRIVATE nEmpVlr     := 0
PRIVATE nEmpBas     := 0
PRIVATE nEmpIns     := 0
//��������������������������������������������������������������������������Ŀ
//� Atualiza SX1                                                             �
//����������������������������������������������������������������������������

lAutoSt := lAuto

CriaSX1()
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
if !lAuto
    nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
	aAlias := {"SE1","BD6","BG9","SA1","BDH","BA1","BAU","BD7","BWT"}
	objCENFUNLGP:setAlias(aAlias)

//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If !lAuto .AND. nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Configura impressora                                                     �
//����������������������������������������������������������������������������
if !lAuto
    SetDefault(aReturn,cAlias)
endif
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
if !lAuto
    MsAguarde({|| R039Imp() }, cTitulo, "", .T.)
else
    R039Imp()
endif
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina Principal...                                               �
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R039Imp  � Autor � Eduardo Motta         � Data � 20.11.03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio de Notas de Debito                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Static Function R039Imp()

//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL cSQL ,i
LOCAL nOrdSel    := aReturn[8] // Ordem selecionada...
LOCAL lRelGerado := .F.
LOCAL cChaAnt 
LOCAL cCodEmpAnt 
LOCAL cCliAnt 
LOCAL cConAnt 
LOCAL cSubAnt 
LOCAL cFamAnt 
LOCAL cUsrAnt 
LOCAL cRdaAnt 
LOCAL cGuiAnt 
//��������������������������������������������������������������������������Ŀ
//� Variaveis de Parametros do relatorio (SX1)...                            �
//����������������������������������������������������������������������������
LOCAL cMes      
LOCAL cAno      
LOCAL cOpeDe    
LOCAL cOpeAte   
LOCAL cEmpDe    
LOCAL cEmpAte   
LOCAL cConDe    
LOCAL cConAte   
LOCAL cVerDe    
LOCAL cVerAte   
LOCAL cSubDe    
LOCAL cSubAte   
LOCAL cVesDe    
LOCAL cVesAte   
LOCAL cMatDe    
LOCAL cMatAte   
LOCAL cTipPre
LOCAL nPerIns
LOCAL nLisCid   
LOCAL cCliente
LOCAL cLoja
LOCAL lInterc := .F.
LOCAL cMvPLCDTGP := GETMV("MV_PLCDTGP")
PRIVATE nLinPag
PRIVATE lLisCid
PRIVATE cCid
PRIVATE cGuia
//��������������������������������������������������������������������������Ŀ
//� Busca os parametros...                                                   �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)                
cMes      := mv_par01
cAno      := mv_par02
cOpeDe    := mv_par03
cOpeAte   := mv_par04
cEmpDe    := mv_par05
cEmpAte   := mv_par06
cConDe    := mv_par07
cConAte   := mv_par08
cVerDe    := mv_par09
cVerAte   := mv_par10
cSubDe    := mv_par11
cSubAte   := mv_par12
cVesDe    := mv_par13
cVesAte   := mv_par14
cMatDe    := mv_par15
cMatAte   := mv_par16
cTipPre   := mv_par17
nPerIns   := mv_par18
nLinPag   := mv_par19
nLisCid   := mv_par20
cCliente  := mv_par21
cLoja     := mv_par22
dEmiDe    := mv_par23
dEmiAte   := mv_par24
nLisCom   := mv_par25

If  nLinPag == 0
    nLinPag := nQtdLin
Endif    
If  nLisCid == 1
    lLisCid := .T.
    cCabec2     := "    CID        Dt.Atend       N.Debito   Quant Codigo AMB       Procedimento                                           Vlr.Cop/CO"
Else
    lLisCid := .F.
Endif        

If  nOrdSel == 1 .or. ;
    nOrdSel == 2
    cTitulo := alltrim(cTitulo) + " - Ref: " + cMes + "/" + cAno
    cCabec1 := ""
    cCabec2 := ""
Else
    cTitulo := "Movimentacao por Familia - Ref: " + cMes + "/" + cAno
Endif    
//��������������������������������������������������������������������������Ŀ
//� Define query de acesso...                                                �
//����������������������������������������������������������������������������
cSQL := "SELECT "
cSQL += "BD6_CODOPE,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_CODPRO,BD6_VLRTPF,BD6_OPEUSR,BD6_CODEMP,BD6_MATRIC,"
cSQL += "BD6_TIPREG,BD6_DIGITO,BD6_DATPRO,BD6_QTDPRO,BD6_NUMIMP,BD6_CODRDA,BD6_DESPRO,BD6_NOMRDA,BD6_NOMUSR, "
cSQL += "BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_CID   ,BD6_SEQUEN,E1_CLIENTE,E1_LOJA   ,BD6_TIPGUI "
cSQL += "FROM " + RetSQLName("SE1") + "," + RetSQLName("BD6") + "," + RetSQLName("BDH") + " WHERE "
cSQL += "E1_CODINT >= '" + cOpeDe + "' AND E1_CODINT <=  '" + cOpeAte + "' AND "
cSQL += "E1_CODEMP >= '" + cEmpDe + "' AND E1_CODEMP <=  '" + cEmpAte + "' AND "
If  ! empty(cCliente+cLoja)
    cSQL += "E1_CLIENTE = '" + cCliente + "' AND E1_LOJA <=  '" + cLoja + "' AND "
Else
    cSQL += "E1_CONEMP >= '" + cConDe + "' AND E1_CONEMP <=  '" + cConAte + "' AND "
    cSQL += "E1_VERCON >= '" + cVerDe + "' AND E1_VERCON <=  '" + cVerAte + "' AND "
    cSQL += "E1_SUBCON >= '" + cSubDe + "' AND E1_SUBCON <=  '" + cSubAte + "' AND "
    cSQL += "E1_VERSUB >= '" + cVesDe + "' AND E1_VERSUB <=  '" + cVesAte + "' AND "
    cSQL += "E1_MATRIC >= '" + cMatDe + "' AND E1_MATRIC <=  '" + cMatAte + "' AND "
Endif    
cSQL += "E1_MESBASE  = '" + cMes   + "' AND "
cSQL += "E1_ANOBASE  = '" + cAno   + "' AND "
cSQL += "E1_EMISSAO >= '" + dtos(dEmiDe)  + "' AND "
cSQL += "E1_EMISSAO <= '" + dtos(dEmiAte) + "' AND "
cSQL += "BDH_PREFIX = E1_PREFIXO AND "
cSQL += "BDH_NUMTIT = E1_NUM     AND " 
cSQL += "BDH_PARCEL = E1_PARCELA AND "
cSQL += "BDH_TIPTIT = E1_TIPO    AND "
cSQL += "BD6_OPEUSR = BDH_CODINT AND "
cSQL += "BD6_CODEMP = BDH_CODEMP AND "
cSQL += "BD6_MATRIC = BDH_MATRIC AND "
cSQL += "BD6_TIPREG = BDH_TIPREG AND "
cSQL += "BD6_SEQPF  = BDH_SEQPF  AND "
cSQL += "BD6_ANOPAG = BDH_ANOFT  AND "
cSQL += "BD6_MESPAG = BDH_MESFT  AND "
cSQL += RetSQLName("SE1") + ".D_E_L_E_T_ = '' AND "
cSQL += RetSQLName("BD6") + ".D_E_L_E_T_ = '' AND "
cSQL += RetSQLName("BDH") + ".D_E_L_E_T_ = '' "
If  cEmpDe == GetNewPar("MV_PLSGEIN","0050") // verifica se eh intercambio
    lInterc := .T.
    If  nOrdSel == 2 // matricula antiga
        cSQL += "ORDER BY BD6_FILIAL,E1_CLIENTE,E1_LOJA,BD6_OPEUSR,BD6_CODEMP,BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_MATANT,BD6_DATPRO,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN"
    Else        
        cSQL += "ORDER BY BD6_FILIAL,E1_CLIENTE,E1_LOJA,BD6_OPEUSR,BD6_CODEMP,BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_MATRIC,BD6_TIPREG,BD6_DIGITO,BD6_DATPRO,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN"
    Endif
Else
    If  nOrdSel == 2 // matricula antiga
        cSQL += "ORDER BY BD6_FILIAL,BD6_OPEORI,BD6_CODEMP,BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_MATANT,BD6_DATPRO,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN"
    Else
        cSQL += "ORDER BY BD6_FILIAL,BD6_OPEORI,BD6_CODEMP,BD6_CONEMP,BD6_VERCON,BD6_SUBCON,BD6_VERSUB,BD6_MATRIC,BD6_TIPREG,BD6_DIGITO,BD6_DATPRO,BD6_CODLDP,BD6_CODPEG,BD6_NUMERO,BD6_ORIMOV,BD6_SEQUEN"
    Endif        
Endif    

PLSQuery(cSQL,"Trb")                                                                         

If Trb->(Eof())
   Trb->(DbCloseArea())
   Help("",1,"REGNOIS")
   Return
Endif   
BA3->(dbSetOrder(1))
BA1->(dbSetOrder(2))
BAU->(dbSetOrder(1))
BD7->(DBSetOrder(1))
BWT->(DBSetOrder(1))
//��������������������������������������������������������������������������Ŀ
//� Processa arquivo de trabalho                                             �
//����������������������������������������������������������������������������
While ! Trb->(Eof())

   //��������������������������������������������������������������������������Ŀ
   //� Imprime dados da empresa                                                 �
   //����������������������������������������������������������������������������
   lRelGerado := .T.

   //��������������������������������������������������������������������������Ŀ
   //� Imprime cabecalho da empresa                                             �
   //����������������������������������������������������������������������������
   nli := 999
   cCliAnt := objCENFUNLGP:verCamNPR("E1_CLIENTE",Trb->E1_CLIENTE)+objCENFUNLGP:verCamNPR("E1_LOJA",Trb->E1_LOJA)
   cCodEmpAnt := Trb->(BD6_CODOPE+BD6_CODEMP)
   If  lInterc
       cChaAnt := Trb->(E1_CLIENTE+E1_LOJA)
   Else
       cChaAnt := Trb->(BD6_CODOPE+BD6_CODEMP)
   Endif
   nEmpVlr := 0
   nEmpBas := 0
   nEmpIns := 0
   If  nOrdSel <> 1 .and. ;
       nOrdSel <> 2
       cLinha := "Empresa: " +  objCENFUNLGP:verCamNPR("BD6_CODOPE",objCENFUNLGP:verCamNPR("BD6_CODEMP",substr(cCodEmpAnt,5,4))) + " - " + ;
                                objCENFUNLGP:verCamNPR("BG9_DESCRI",alltrim(posicione("BG9",1,xFilial("BG9")+cCodEmpAnt,"BG9_DESCRI"))) + ;
               "   Cliente: " + objCENFUNLGP:verCamNPR("E1_CLIENTE",Trb->E1_CLIENTE) + "-" +;
                                objCENFUNLGP:verCamNPR("E1_LOJA",Trb->E1_LOJA) + " " +;
                                objCENFUNLGP:verCamNPR("A1_NOME",alltrim(posicione("SA1",1,xFilial("SA1")+Trb->(E1_CLIENTE+E1_LOJA),"A1_NOME")))
       R039Linha(cLinha,1,0)
   Endif
   //��������������������������������������������������������������������������Ŀ
   //� Processa todos os contratos                                              �
   //����������������������������������������������������������������������������
   While ! Trb->(Eof()) .And. if(lInterc,cChaAnt == Trb->(E1_CLIENTE+E1_LOJA),cChaAnt == Trb->(BD6_CODOPE+BD6_CODEMP))
      //��������������������������������������������������������������������������Ŀ
      //� Imprime cabecalho do contrato                                            �
      //����������������������������������������������������������������������������
      cConAnt := Trb->(BD6_CONEMP+BD6_VERCON)
      nConVlr := 0
      nConBas := 0
      nConIns := 0
      If  nOrdSel <> 1 .and. ;
          nOrdSel <> 2
          cLinha := "Contrato/Versao: " + objCENFUNLGP:verCamNPR("BD6_CONEMP",objCENFUNLGP:verCamNPR("BD6_VERCON",cConAnt))
          R039Linha(cLinha,2,0)
      Endif
      //��������������������������������������������������������������������������Ŀ
      //� Processa todos os subcontratos                                           �
      //����������������������������������������������������������������������������
      While ! Trb->(Eof()) .And. if(lInterc,cChaAnt == Trb->(E1_CLIENTE+E1_LOJA),cChaAnt == Trb->(BD6_CODOPE+BD6_CODEMP)) ;
                            .And. cConAnt == Trb->(BD6_CONEMP+BD6_VERCON)
         //��������������������������������������������������������������������������Ŀ
         //� Imprime cabecalho do subcontrato                                         �
         //����������������������������������������������������������������������������
         cSubAnt := Trb->(BD6_SUBCON+BD6_VERSUB)
         nSubVlr := 0
         nSubBas := 0
         nSubIns := 0
         If  nOrdSel <> 1 .and. ;
             nOrdSel <> 2
             cLinha := "Subcontrato/Versao: " + objCENFUNLGP:verCamNPR("BD6_SUBCON",objCENFUNLGP:verCamNPR("BD6_VERSUB",cSubAnt))
             R039Linha(cLinha,2,0)
         Endif
         //��������������������������������������������������������������������������Ŀ
         //� Processa todos as familias do subcontrato                                �
         //����������������������������������������������������������������������������
         While ! Trb->(Eof()) .And. if(lInterc,cChaAnt == Trb->(E1_CLIENTE+E1_LOJA),cChaAnt == Trb->(BD6_CODOPE+BD6_CODEMP)) ;
                               .And. cConAnt == Trb->(BD6_CONEMP+BD6_VERCON) ;
                               .And. cSubAnt == Trb->(BD6_SUBCON+BD6_VERSUB)
            //��������������������������������������������������������������������������Ŀ
            //� Imprime dados da familia                                                 �
            //����������������������������������������������������������������������������
            If !lAutoSt .AND. ! BA1->(dbSeek(xFilial("BA1")+Trb->(BD6_CODOPE+BD6_CODEMP+BD6_MATRIC)))
                msgalert("Titular nao encontrado no BA1: " + ;
                                                objCENFUNLGP:verCamNPR("BD6_CODOPE",Trb->BD6_CODOPE)+;
                                                objCENFUNLGP:verCamNPR("BD6_CODEMP",Trb->BD6_CODEMP)+;
                                                objCENFUNLGP:verCamNPR("BD6_MATRIC",Trb->BD6_MATRIC))
            Endif

            If  nOrdSel == 1 .or. ;
                nOrdSel == 2
                nli := 999
                cLinha := "Empresa: " + objCENFUNLGP:verCamNPR("BD6_CODEMP",Trb->BD6_CODEMP) + " - " + ;
                                        objCENFUNLGP:verCamNPR("BG9_DESCRI",alltrim(posicione("BG9",1,xFilial("BG9")+Trb->(BD6_CODOPE+BD6_CODEMP),"BG9_DESCRI"))) + ;
                       "   Cliente: " + objCENFUNLGP:verCamNPR("E1_CLIENTE",Trb->E1_CLIENTE) + "-" +;
                                        objCENFUNLGP:verCamNPR("E1_LOJA",Trb->E1_LOJA) + " " +;
                                        objCENFUNLGP:verCamNPR("A1_NOME",alltrim(posicione("SA1",1,xFilial("SA1")+Trb->(E1_CLIENTE+E1_LOJA),"A1_NOME")))
                R039Linha(cLinha,1,0)
            Endif
            
            cLinha := "Titular da Familia: " + TransForm(objCENFUNLGP:verCamNPR("BD6_CODOPE",Trb->BD6_CODOPE)+;
                                                        objCENFUNLGP:verCamNPR("BD6_CODEMP",Trb->BD6_CODEMP)+;
                                                        objCENFUNLGP:verCamNPR("BD6_MATRIC",Trb->BD6_MATRIC)+;
                                                        cMvPLCDTGP,__cPictUsr) + Space(02) + ;
                                            objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR)
            R039Linha(cLinha,2,0)

            cLinha := replicate("-",132)
            R039Linha(cLinha,2,0)

            If  nOrdSel == 1 .or. ;
                nOrdSel == 2
                cLinha := "Codigo do Usuario     Nome                                              Matricula da Empresa/Origem"
                R039Linha(cLinha,1,0)

                If  lLisCid
                    cLinha := "    CID        Dt.Atend       N.Debito   Quant Codigo AMB       Procedimento                                           Vlr.Cop/CO"
                Else
                    cLinha := "               Dt.Atend       N.Debito   Quant Codigo AMB       Procedimento                                           Vlr.Cop/CO"
                Endif
                R039Linha(cLinha,1,0)

                cLinha := replicate("-",132)
                R039Linha(cLinha,1,0)
            Endif

            cFamAnt := Trb->BD6_MATRIC

            nFamVlr := 0
            nFamBas := 0
            nFamIns := 0

            //��������������������������������������������������������������������������Ŀ
            //� Processa todos usuarios da familia                                       �
            //����������������������������������������������������������������������������
            While ! Trb->(Eof()) .And. if(lInterc,cChaAnt == Trb->(E1_CLIENTE+E1_LOJA),cChaAnt == Trb->(BD6_CODOPE+BD6_CODEMP)) ;
                                  .And. cConAnt == Trb->(BD6_CONEMP+BD6_VERCON) ;
                                  .And. cSubAnt == Trb->(BD6_SUBCON+BD6_VERSUB) ;
                                  .And. cFamAnt == Trb->BD6_MATRIC

               //��������������������������������������������������������������������������Ŀ
               //� Imprime dados do usuario                                                 �
               //����������������������������������������������������������������������������
               cUsrAnt := Trb->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)

               If !lAutoSt .AND. ! BA1->(dbSeek(xFilial("BA1")+cUsrAnt))
                   msgalert("Usuario nao encontrado no BA1: " + ;
                                                        objCENFUNLGP:verCamNPR("BD6_OPEUSR",Trb->BD6_OPEUSR)+;
                                                        objCENFUNLGP:verCamNPR("BD6_CODEMP",Trb->BD6_CODEMP)+;
                                                        objCENFUNLGP:verCamNPR("BD6_MATRIC",Trb->BD6_MATRIC)+;
                                                        objCENFUNLGP:verCamNPR("BD6_TIPREG",Trb->BD6_TIPREG))
               Endif

               cLinha := TransForm(objCENFUNLGP:verCamNPR("BD6_OPEUSR",Trb->BD6_OPEUSR)+;
                                    objCENFUNLGP:verCamNPR("BD6_CODEMP",Trb->BD6_CODEMP)+;
                                    objCENFUNLGP:verCamNPR("BD6_MATRIC",Trb->BD6_MATRIC)+;
                                    objCENFUNLGP:verCamNPR("BD6_TIPREG",Trb->BD6_TIPREG),__cPictUsr) + Space(02) + ;
                        objCENFUNLGP:verCamNPR("BA1_NOMUSR",BA1->BA1_NOMUSR) +;
                        IIF(lInterc,objCENFUNLGP:verCamNPR("BA1_MATANT",BA1->BA1_MATANT),objCENFUNLGP:verCamNPR("BA1_MATEMP",BA1->BA1_MATEMP))
               R039Linha(cLinha,2,0)

               nUsrVlr := 0

               //��������������������������������������������������������������������������Ŀ
               //� Processa todos usuarios da familia                                       �
               //����������������������������������������������������������������������������
               While ! Trb->(Eof()) .And. if(lInterc,cChaAnt == Trb->(E1_CLIENTE+E1_LOJA),cChaAnt == Trb->(BD6_CODOPE+BD6_CODEMP)) ;
                                     .And. cConAnt == Trb->(BD6_CONEMP+BD6_VERCON) ;
                                     .And. cSubAnt == Trb->(BD6_SUBCON+BD6_VERSUB) ;
                                     .And. cFamAnt == Trb->BD6_MATRIC ;
                                     .And. cUsrAnt == Trb->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)

                  //��������������������������������������������������������������������������Ŀ
                  //� Imprime dados da rda                                                     �
                  //����������������������������������������������������������������������������
                  cRdaAnt := Trb->BD6_CODRDA

                  If !lAutoSt .AND. ! BAU->(dbSeek(xFilial("BAU")+cRdaAnt))
                      msgalert("RDA nao encontrado no BAU: " + objCENFUNLGP:verCamNPR("BD6_CODRDA",cRdaAnt))
                  Endif

                  cLinha := space(12) + "Prestador do Servico: " + objCENFUNLGP:verCamNPR("BAU_NOME",BAU->BAU_NOME)
                  R039Linha(cLinha,1,0)
            
                  //��������������������������������������������������������������������������Ŀ
                  //� Processa todos prestadores que atenderam o usuario                       �
                  //����������������������������������������������������������������������������
                  While ! Trb->(Eof()) .And. if(lInterc,cChaAnt == Trb->(E1_CLIENTE+E1_LOJA),cChaAnt == Trb->(BD6_CODOPE+BD6_CODEMP)) ;
                                        .And. cConAnt == Trb->(BD6_CONEMP+BD6_VERCON) ;
                                        .And. cSubAnt == Trb->(BD6_SUBCON+BD6_VERSUB) ;
                                        .And. cFamAnt == Trb->BD6_MATRIC ;
                                        .And. cUsrAnt == Trb->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG) ;
                                        .And. cRdaAnt ==  Trb->BD6_CODRDA

                     //��������������������������������������������������������������������������Ŀ
                     //� Monta dados da guia                                                      �
                     //����������������������������������������������������������������������������
                     cGuiAnt := Trb->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)

                     If  lLisCid
                         cCid := space(4) + Trb->BD6_CID + space(2)
                     Else
                         cCid := space(14)
                     Endif
                     cGuia := dtoc(Trb->BD6_DATPRO) + Space(01) + Trb->BD6_NUMIMP + Space(01)
                  
                     //��������������������������������������������������������������������������Ŀ
                     //� Processa todos os procedimentos da guia                                  �
                     //����������������������������������������������������������������������������
                     While ! Trb->(Eof()) .And. if(lInterc,cChaAnt == Trb->(E1_CLIENTE+E1_LOJA),cChaAnt == Trb->(BD6_CODOPE+BD6_CODEMP)) ;
                                           .And. cConAnt == Trb->(BD6_CONEMP+BD6_VERCON) ;
                                           .And. cSubAnt == Trb->(BD6_SUBCON+BD6_VERSUB) ;
                                           .And. cFamAnt == Trb->BD6_MATRIC ;
                                           .And. cUsrAnt == Trb->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG) ;
                                           .And. cRdaAnt ==  Trb->BD6_CODRDA ;
                                           .And. cGuiAnt == Trb->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)
                  
                        //��������������������������������������������������������������������Ŀ
                        //� Mensagem de processamento                                          �
                        //����������������������������������������������������������������������
                        if !lAutoSt
                            MsProcTXT("Processando ... " + ;
                                            objCENFUNLGP:verCamNPR("BD6_CODOPE",Trb->BD6_CODOPE)+"."+;
                                            objCENFUNLGP:verCamNPR("BD6_CODEMP",Trb->BD6_CODEMP)+"."+;
                                            objCENFUNLGP:verCamNPR("BD6_MATRIC",Trb->BD6_MATRIC)+"."+;
                                            objCENFUNLGP:verCamNPR("BD6_TIPREG",Trb->BD6_TIPREG)+" "+;
                                            objCENFUNLGP:verCamNPR("BD6_CODPRO",Trb->BD6_CODPRO))
                        endif
                        //��������������������������������������������������������������������������Ŀ
                        //� Imprime procedimento                                                     �
                        //����������������������������������������������������������������������������
                        cLinha :=   objCENFUNLGP:verCamNPR("BD6_CID",cCid) +;
                                    objCENFUNLGP:verCamNPR("BD6_DATPRO",objCENFUNLGP:verCamNPR("BD6_NUMIMP",cGuia)) + ;
                                    objCENFUNLGP:verCamNPR("BD6_QTDPRO",Str(Trb->BD6_QTDPRO,2))    + Space(01) + ;
                                    objCENFUNLGP:verCamNPR("BD6_CODPRO",Trb->BD6_CODPRO) + Space(01) + ;
                                    objCENFUNLGP:verCamNPR("BD6_DESPRO",Subs(Trb->BD6_DESPRO,1,50)) + Space(01) + ;
                                    objCENFUNLGP:verCamNPR("BD6_VLRTPF",transform(Trb->BD6_VLRTPF,PLSVALOR))
                        R039Linha(cLinha,1,0)
                        cGuia := space(30)          
                        //��������������������������������������������������������������������������Ŀ
                        //� Acumula valores                                                          �
                        //����������������������������������������������������������������������������
                        nUsrVlr += Trb->BD6_VLRTPF
                        nFamVlr += Trb->BD6_VLRTPF
                        nSubVlr += Trb->BD6_VLRTPF
                        nConVlr += Trb->BD6_VLRTPF
                        nEmpVlr += Trb->BD6_VLRTPF
                        If  BAU->BAU_TIPPRE $ cTipPre
                            nFamBas += Trb->BD6_VLRTPF
                            nSubBas += Trb->BD6_VLRTPF
                            nConBas += Trb->BD6_VLRTPF
                            nEmpBas += Trb->BD6_VLRTPF
                        Endif
                        //��������������������������������������������������������������������������Ŀ
                        //� Processa a composicao do procedimento                                    �
                        //����������������������������������������������������������������������������
                        If  nLisCom == 1 .and. TRB->BD6_TIPGUI == "03"
                            aBD7 := {}
                            BD7->(msSeek(xFilial("BD7")+Trb->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)))
                            While ! BD7->(eof()) .and. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN) == ;
                                                        xFilial("BD7")+Trb->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN)
                               If  BD7->BD7_VLRTPF > 0
    		                       cNomPre := BAU->BAU_NOME
	    		                   If  BD7->BD7_CODRDA <> BAU->BAU_CODIGO
		    	                       nPosBAU := BAU->(RecNo())
			                           BAU->(DbSeek( xFilial("BAU")+BD7->BD7_CODRDA ))
			                           cNomPre := BAU->BAU_NOME
			                           BAU->(dbGoTo(nPosBAU))
                                   Endif			                  
                                   BWT->(msSeek(xFilial("BWT")+BD7->BD7_CODOPE+BD7->BD7_CODTPA))
                                   aadd(aBD7,{BD7->BD7_CODUNM,substr(BWT->BWT_DESCRI,1,12),cNomPre,BD7->BD7_VLRTPF})
                               Endif
                               BD7->(dbSkip())
                            Enddo                                                        
                            If  len(aBD7) > 1
                                For i := 1 to len(aBD7)
                                    cLinha := space(30) + ;
                                              objCENFUNLGP:verCamNPR("BD7_CODUNM",aBD7[i,1]) + space(1) + ;
                                              objCENFUNLGP:verCamNPR("BWT_DESCRI",aBD7[i,2]) + space(1) + ;
                                              objCENFUNLGP:verCamNPR("BAU_NOME",aBD7[i,3]) + space(1) + ;
                                              objCENFUNLGP:verCamNPR("BD7_VLRTPF",transform(aBD7[i,4],PLSVALOR))
                                    R039Linha(cLinha,1,0)
                                Next
                            Endif
                        Endif
                        //��������������������������������������������������������������������������Ŀ
                        //� Acessa proximo registro                                                  �
                        //����������������������������������������������������������������������������
                        Trb->(DbSkip())
            
                     Enddo
            
                  nLi ++                        
            
                  Enddo      
         
               Enddo
      
               //��������������������������������������������������������������������������Ŀ
               //� Imprime totais do usuario                                                �
               //����������������������������������������������������������������������������
               cLinha := space(65) + "Total do usuario ............................. R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nUsrVlr,PLSVALOR))
               R039Linha(cLinha,1,1)
      
            Enddo

            //��������������������������������������������������������������������������Ŀ
            //� Calcula inss                                                             �
            //����������������������������������������������������������������������������
            nFamIns := noround(nFamBas * nPerIns / 100,2)
            //��������������������������������������������������������������������������Ŀ
            //� Imprime totais da familia                                                �
            //����������������������������������������������������������������������������
            cLinha := replicate("-",132)
            R039Linha(cLinha,1,0)

            cLinha := space(65) + "TOTAL GERAL DA FAMILIA ....................... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nFamVlr,PLSVALOR))
            R039Linha(cLinha,2,0)

            cLinha := space(65) + "BASE DE CALCULO DO INSS DA FAMILIA ........... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nFamBas,PLSVALOR))
            R039Linha(cLinha,1,0)

            cLinha := space(65) + "VALOR DO INSS DA FAMILIA (15%) ............... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nFamIns,PLSVALOR))
            R039Linha(cLinha,1,0)                                            

            If  nOrdSel == 1 
                cLinha := replicate("=",132)
                R039Linha(cLinha,2,0)
            Else
                cLinha := replicate("-",132)
                R039Linha(cLinha,2,0)
            Endif
            //��������������������������������������������������������������������������Ŀ
            //� Acumula valores                                                          �
            //����������������������������������������������������������������������������
            nSubIns += nFamIns
            nConIns += nFamIns
            nEmpIns += nFamIns

         Enddo
         //��������������������������������������������������������������������������Ŀ
         //� Imprime totais do subcontrato                                            �
         //����������������������������������������������������������������������������
         If  nOrdSel <> 1 .and. ;
             nOrdSel <> 2
             cLinha := "Subcontrato/Versao: " + objCENFUNLGP:verCamNPR("BD6_SUBCON",objCENFUNLGP:verCamNPR("BD6_VERSUB",cSubAnt)) + ;
                       space(33) + "TOTAL GERAL .................................. R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nSubVlr,PLSVALOR))
             R039Linha(cLinha,2,0)

             cLinha := space(65) + "BASE DE CALCULO DO INSS ...................... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nSubBas,PLSVALOR))
             R039Linha(cLinha,1,0)

             cLinha := space(65) + "VALOR DO INSS (15%) .......................... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nSubIns,PLSVALOR))
             R039Linha(cLinha,1,0)                                            
         Endif

      Enddo
      //��������������������������������������������������������������������������Ŀ
      //� Imprime totais do contrato                                               �
      //����������������������������������������������������������������������������
      If  nOrdSel <> 1 .and. ;
          nOrdSel <> 2
          cLinha := replicate("-",132)
          R039Linha(cLinha,2,0)

          cLinha := "Contrato/Versao: " + objCENFUNLGP:verCamNPR("BD6_CONEMP",objCENFUNLGP:verCamNPR("BD6_VERCON",cConAnt)) + ;
                    space(33) + "TOTAL GERAL .................................. R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nConVlr,PLSVALOR))
          R039Linha(cLinha,2,0)

          cLinha := space(65) + "BASE DE CALCULO DO INSS ...................... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nConBas,PLSVALOR))
          R039Linha(cLinha,1,0)

          cLinha := space(65) + "VALOR DO INSS (15%) .......................... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nConIns,PLSVALOR))
          R039Linha(cLinha,1,0)                                            
      Endif

   Enddo
   //��������������������������������������������������������������������������Ŀ
   //� Imprime totais da empresa                                                �
   //����������������������������������������������������������������������������
   If  nOrdSel <> 1 .and. ;
       nOrdSel <> 2
       cLinha := replicate("-",132)
       R039Linha(cLinha,2,0)

       cLinha := "Empresa: " + objCENFUNLGP:verCamNPR("BD6_CODOPE",objCENFUNLGP:verCamNPR("BD6_CODEMP",substr(cCodEmpAnt,5,4))) + " - " + ;
                 objCENFUNLGP:verCamNPR("BG9_DESCRI",substring(posicione("BG9",1,xFilial("BG9")+cCodEmpAnt,"BG9_DESCRI"),1,47)) + ;
                 space(2) + "TOTAL GERAL .................................. R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nEmpVlr,PLSVALOR))
       R039Linha(cLinha,2,0)

       If  lInterc
           cLinha := "Cliente: " +  substr(cCliAnt,1,6) + "-" +;
                                    substr(cCliAnt,7,2) + " " +;
                                    objCENFUNLGP:verCamNPR("A1_NOME",posicione("SA1",1,xFilial("SA1")+Trb->(E1_CLIENTE+E1_LOJA),"A1_NOME")) +;
                                    space(9)
       Else
           cLinha := space(65)
       Endif           
       cLinha += "BASE DE CALCULO DO INSS ...................... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nEmpBas,PLSVALOR))
       R039Linha(cLinha,1,0)

       cLinha := space(65) + "VALOR DO INSS (15%) .......................... R$ "+objCENFUNLGP:verCamNPR("BD6_VLRTPF",TransForm(nEmpIns,PLSVALOR))
       R039Linha(cLinha,1,0)                                            

       cLinha := replicate("=",132)
       R039Linha(cLinha,2,0)
   Endif

Enddo
//��������������������������������������������������������������������������Ŀ
//� Fecha arquivo de trabalho                                                �
//����������������������������������������������������������������������������
Trb->(DbCloseArea())
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If !lAutoSt .AND. lRelGerado .And. aReturn[5] == 1
    Set Printer To
    Ourspool(nRel)
End
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R039Linha � Autor � Angelo Sperandio     � Data � 23.01.05 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime linha de detalhe                                   ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function R039Linha(cLinha,nAntes,nApos)

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
If  nli > nLinPag
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

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � CriaSX1  � Autor � Angelo Sperandio      � Data � 05/02/05 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Atualiza perguntas                                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CriaSX1()                                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function CriaSX1()

//��������������������������������������������������������������������������Ŀ
//� Iniciliza variaveis                                                      �
//����������������������������������������������������������������������������
Local aRegs	:=	{}
aadd(aRegs,{cPerg,"20","Lista CID"      ,"","","mv_chk","N",1,0,0,"C","","mv_par20","Sim" ,"","","","","Nao","","","","","","","","","","","","","","","","","","",""   ,""})
aadd(aRegs,{cPerg,"21","Cliente"        ,"","","mv_chl","C",6,0,0,"G","","mv_par21",""    ,"","","","",""   ,"","","","","","","","","","","","","","","","","","","SA1",""})
aadd(aRegs,{cPerg,"22","Loja"           ,"","","mv_chm","C",2,0,0,"G","","mv_par22",""    ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
aadd(aRegs,{cPerg,"23","Emissao Tit De" ,"","","mv_chn","D",8,0,0,"G","","mv_par23",""    ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
aadd(aRegs,{cPerg,"24","Emissao Tit Ate","","","mv_cho","D",8,0,0,"G","","mv_par24",""    ,"","","","",""   ,"","","","","","","","","","","","","","","","","","",""   ,""})
aadd(aRegs,{cPerg,"25","Lista Comp Proc","","","mv_chp","N",1,0,0,"C","","mv_par25","Sim" ,"","","","","Nao","","","","","","","","","","","","","","","","","","",""   ,""})
//��������������������������������������������������������������������������Ŀ
//� Atualiza SX1                                                             �
//����������������������������������������������������������������������������
PlsVldPerg(aRegs)
//��������������������������������������������������������������������������Ŀ
//� Fim da funcao                                                            �
//����������������������������������������������������������������������������
Return

