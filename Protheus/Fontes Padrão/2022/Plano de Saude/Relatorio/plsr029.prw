
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR029 � Autor � Alexander Santos       � Data � 18.03.05 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Monitorar dependentes                                      ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR029                                                    ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
���			 �      �  			  � 						              ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/

Function PLSR029(lauto)

Default lauto := .F.
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE nQtdLin     := 58
PRIVATE nLimite     := 132     
PRIVATE cTamanho    := "M"     
PRIVATE cTitulo     := "Relacao de dependentes que irao atingir maioridade"
PRIVATE cDesc1      := "Este relatorio ira listar os dependentes que irao atingir"
PRIVATE cDesc2      := "maioridade, conforme parametros informados."
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA1"
PRIVATE cPerg       := "PLR029"
PRIVATE cRel        := "PLSR029"
PRIVATE nli         := 99
PRIVATE m_pag       := 1    
PRIVATE lCompres    := .F. 
PRIVATE lDicion     := .F. 
PRIVATE lFiltro     := .T. 
PRIVATE lCrystal    := .F. 
PRIVATE aOrderns    := {} 
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 } 
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "  Matricula            Nome                                              Dt. Nascimento  Idade  Universit�rio   Tp. Dependente"
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 01 
PRIVATE aLinha      := {}
//��������������������������������������������������������������������������Ŀ
//� Dados do parametro...                                                    �
//����������������������������������������������������������������������������
Private cOper    
Private cEmpDe   
Private cEmpAte  
Private cConDe	 
Private cConAte	 
Private cSubDe	 
Private cSubAte	 
Private cMatDe   
Private cMatAte  
Private dDatDe	 
Private dDatAte	 
Private nIdadeN 
Private nIdadeU  

lAutoSt := lauto
//��������������������������������������������������������������������������Ŀ
//� Testa ambiente do relatorio somente top...                               �
//����������������������������������������������������������������������������
If  ! PLSRelTop()
    Return
Endif    

//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint (padrao)                                                  �
//����������������������������������������������������������������������������
if !lauto
    cRel := SetPrint(cAlias,cRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao (padrao)                            �
//����������������������������������������������������������������������������
If !lauto .AND. nLastKey  == 27 
    Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
if !lauto
    Pergunte(cPerg,.T.)      
else
    Pergunte(cPerg,.F.)      
endif
cOper    := Mv_Par01
cEmpDe   := Mv_Par02
cEmpAte  := Mv_Par03
cConDe	 := Mv_Par04
cConAte	 := Mv_Par05
cSubDe	 := Mv_Par06
cSubAte	 := Mv_Par07
cMatDe   := Mv_Par08
cMatAte  := Mv_Par09
dDatDe	 := Mv_Par10
dDatAte	 := Mv_Par11
nIdadeN  := Mv_Par12
nIdadeU  := Mv_Par13
//��������������������������������������������������������������������������Ŀ
//� Configura impressora (padrao)                                            �
//����������������������������������������������������������������������������
if !lauto
    SetDefault(aReturn,cAlias) 
endif
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
if !lauto
    MsAguarde({|| R029Imp() }, cTitulo, "", .T.)
else
    R029Imp()
endif
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R029Imp  � Autor � Alexander Santos      � Data � 04.11.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime detalhe do relatorio...                            ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/

Static Function R029Imp()

//��������������������������������������������������������������������������Ŀ
//� Define variaveis...                                                      �
//����������������������������������������������������������������������������
LOCAL cSQL
LOCAL cCodEmp  := ''
LOCAL cCodCont := ''
LOCAL cCodSCont:= ''
Local cIdade
Local dDat
Local nAno
Local nMes
Local nDia
Local cDatIniN
Local cDatFimN
Local cDatIniU
Local cDatFimU
Local cMvPLCDTGP := GETMV("MV_PLCDTGP")
Local cMvCOMP    := GetMv("MV_COMP")
Local cMvNORM    := GetMv("MV_NORM")
//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
if !lAutoSt
    MsProcTxt(PLSTR0001) 
else
    nIdadeN := 0
    nIdadeU := 0
endif
//��������������������������������������������������������������������������Ŀ
//� Verifica data inicial de nascimento                                      �
//����������������������������������������������������������������������������
dDat := dDatDe
nAno := year(dDat) - nIdadeN
If !lAutoSt .AND. nAno < 0
    msgalert("Parametros incompativeis: Data De x Idade")
    Return
Endif    
nMes := month(dDat)
nDia := day(dDat)
If  nDia > 28 .and. nMes == 2
    nDia := 28
Endif    
cDatIniN := strzero(nAno,4) + strzero(nMes,2) + strzero(nDia,2)
//��������������������������������������������������������������������������Ŀ
//� Verifica data final de nascimento                                        �
//����������������������������������������������������������������������������
dDat := dDatAte
nAno := year(dDat) - nIdadeN
If !lAutoSt .AND. nAno < 0
    msgalert("Parametros incompativeis: Data Ate x Idade")
    Return
Endif    
nMes := month(dDat)
nDia := day(dDat)
If  nDia > 28 .and. nMes == 2
    nDia := 28
Endif    
cDatFimN := strzero(nAno,4) + strzero(nMes,2) + strzero(nDia,2)
//��������������������������������������������������������������������������Ŀ
//� Verifica data inicial de nascimento - universitario                      �
//����������������������������������������������������������������������������
dDat := dDatDe
nAno := year(dDat) - nIdadeU
If !lAutoSt .AND. nAno < 0
    msgalert("Parametros incompativeis: Data De x Idade")
    Return
Endif    
nMes := month(dDat)
nDia := day(dDat)
If  nDia > 28 .and. nMes == 2
    nDia := 28
Endif    
cDatIniU := strzero(nAno,4) + strzero(nMes,2) + strzero(nDia,2)
//��������������������������������������������������������������������������Ŀ
//� Verifica data final de nascimento - universitario                        �
//����������������������������������������������������������������������������
dDat := dDatAte
nAno := year(dDat) - nIdadeU
If !lAutoSt .AND. nAno < 0
    msgalert("Parametros incompativeis: Data Ate x Idade")
    Return
Endif    
nMes := month(dDat)
nDia := day(dDat)
If  nDia > 28 .and. nMes == 2
    nDia := 28
Endif    
cDatFimU := strzero(nAno,4) + strzero(nMes,2) + strzero(nDia,2)
//��������������������������������������������������������������������������Ŀ
//� Faz filtro no arquivo...                                                 �
//����������������������������������������������������������������������������
cSQL := "SELECT BA1.BA1_CODINT, BA1.BA1_CODEMP, BA1.BA1_MATRIC, BA1.BA1_TIPREG, BA1.BA1_CONEMP, BA1.BA1_VERCON, "
cSQL += "       BA1.BA1_NOMUSR, BA1.BA1_SUBCON, BA1.BA1_VERSUB, BA1.BA1_DATNAS, BA1.BA1_UNIVER, BRP.BRP_DESCRI  "
cSQL += "FROM " + RetSQLName("BA1") + " BA1, " + RetSQLName("BRP") + " BRP "
cSQL += "WHERE BA1.BA1_CODINT =  '" + cOper   + "' AND "
cSQL += "      BA1.BA1_CODEMP >= '" + cEmpDe  + "' AND BA1.BA1_CODEMP <= '" + cEmpAte + "' AND "
cSQL += "      BA1.BA1_CONEMP >= '" + cConDe  + "' AND BA1.BA1_CONEMP <= '" + cConAte + "' AND "
cSQL += "      BA1.BA1_SUBCON >= '" + cSubDe  + "' AND BA1.BA1_SUBCON <= '" + cSubAte + "' AND "
cSQL += "      BA1.BA1_MATRIC >= '" + cMatDe  + "' AND BA1.BA1_MATRIC <= '" + cMatAte + "' AND "
cSQL += "    ((BA1_UNIVER =  '1' AND BA1.BA1_DATNAS >= '" + cDatIniU + "' AND BA1.BA1_DATNAS <= '" + cDatFimU + "') OR "
cSQL += "     (BA1_UNIVER <> '1' AND BA1.BA1_DATNAS >= '" + cDatIniN + "' AND BA1.BA1_DATNAS <= '" + cDatFimN + "')) AND "
cSQL += "      BA1.BA1_TIPUSU = 'D' AND "
cSQL += "      BRP.BRP_CODIGO = BA1.BA1_GRAUPA AND "
cSQL += "      BA1.D_E_L_E_T_ = ' ' AND "
cSQL += "      BRP.D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BA1.BA1_CODINT,BA1.BA1_CODEMP,BA1.BA1_MATRIC,BA1.BA1_NOMUSR"

PLSQuery(cSQL,"BA1TRB")
BA1TRB->(DbGotop())
//��������������������������������������������������������������������������Ŀ
//� Inicio da impressao dos detalhes...                                      �
//����������������������������������������������������������������������������
While ! BA1TRB->(Eof())
   //�����������Ŀ
   //�para checar�
   //�������������
   cFamilia   := BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
   cGrupEmpr  := BA1TRB->(BA1_CODINT+BA1_CODEMP)
   cContrato  := BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON)
   cSubContr  := BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)
   //��������������������������������������������������������������������Ŀ
   //� Exibe mensagem...                                                  �
   //����������������������������������������������������������������������
   if !lAutoSt
       MsProcTXT("Imprimindo "+BA1TRB->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC)+"...")
   endif
   //��������������������������������������������������������������������Ŀ
   //� Verifica se foi abortada a impressao...                            �
   //����������������������������������������������������������������������
   If !lAutoSt .AND. Interrupcao(lAbortPrint)
       nLi ++
       @ nLi, nColuna pSay PLSTR0002
       Exit
   Endif                       
   //��������������������������������������������������������������������������Ŀ
   //� Posiciono no Titular...                                                  �
   //����������������������������������������������������������������������������
   BA1->(DbSetOrder(2))// cFamilia
   BA1->(DbSeek(xFilial("BA1")+cFamilia+cMvPLCDTGP))
     
   //��������������������������������������������������������������������������Ŀ
   //� Posiciono no Grupo-Empresa...                                            �
   //����������������������������������������������������������������������������
   BG9->(DbSetOrder(1))// BG9_CODINT + BG9_CODIGO + BG9_TIPO
   BG9->(DbSeek(xFilial("BG9")+cGrupEmpr))
   //��������������������������������������������������������������������������Ŀ
   //� Pessoa juridica                                                          �
   //����������������������������������������������������������������������������
   If  BG9->BG9_TIPO == "2"
       //��������������������������������������������������������������������������Ŀ
       //� Posiciono no Contrato...                                                 �
       //����������������������������������������������������������������������������
       BT5->(DbSetOrder(1))// BT5_CODINT + BT5_CODIGO + BT5_NUMCON + BT5_VERSAO
       BT5->(DbSeek(xFilial("BT5")+cContrato))
       //��������������������������������������������������������������������������Ŀ
       //� Posiciono no Sub-Contrato...                                             �
       //����������������������������������������������������������������������������
       BQC->(DbSetOrder(1))// BQC_CODIGO + BQC_NUMCON + BQC_VERCON + BQC_SUBCON + BQC_VERSUB
       BQC->(DbSeek(xFilial("BQC")+cSubContr))
   Endif
   //��������������������������������������������������������������������Ŀ
   //� Imprime grupo...                                                   �
   //����������������������������������������������������������������������
   If  nLi > nQtdLin - 5
       nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
   Endif                  
   If  (cCodEmp <> BA1TRB->BA1_CODEMP) .or. (cCodCont <> BA1TRB->BA1_CONEMP) .or. (cCodSCont <> BA1TRB->BA1_SUBCON)
       @ ++nLi, nColuna pSay "Grup/Empresa: "+BA1TRB->BA1_CODEMP+"-"+Substr(BG9->BG9_DESCRI,1,30)
       If  BG9->BG9_TIPO == "2"
           @ ++nLi, nColuna pSay "Contrato    : "+BA1TRB->BA1_CONEMP+" - Versao: "+BA1TRB->BA1_VERCON+" - "+;
                                 Posicione("BII",1,xFilial("BII")+BT5->BT5_TIPCON,"BII_DESCRI")
           @ ++nLi, nColuna pSay "Sub-Contrato: "+BA1TRB->BA1_SUBCON+"    - Versao: "+BA1TRB->BA1_VERSUB+" - "+BQC->BQC_DESCRI
       Endif
       ++nLi
       cCodEmp   := BA1TRB->BA1_CODEMP
       cCodCont  := BA1TRB->BA1_CONEMP
       cCodSCont := BA1TRB->BA1_SUBCON
   Endif    
   @ ++nLi,   nColuna pSay "Titular: "+BA1->BA1_CODINT+"."+BA1->BA1_CODEMP+"."+BA1->BA1_MATRIC+"-"+BA1->BA1_TIPREG + ' -  '+ Substr(BA1->BA1_NOMUSR,1,38)
   While cFamilia == BA1TRB->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
      //��������������������������������������������������������������������Ŀ
      //� verifica proxima pagina...                                         �
      //����������������������������������������������������������������������
      If !lAutoSt .AND. nLi > nQtdLin
          nLi := Cabec(cTitulo,cCabec1,cCabec2,cRel,cTamanho,IIF(aReturn[4]==1,cMvCOMP,cMvNORM))
      Endif                  
      //��������������������������������������������������������������������Ŀ
      //� Calcula a idade    										         �
      //����������������������������������������������������������������������
      cIdade := str(year(dDataBase) - year(BA1TRB->BA1_DATNAS),2)
      //��������������������������������������������������������������������Ŀ
      //� Imprime Dependentes										         �
      //����������������������������������������������������������������������
      @ ++nLi, nColuna pSay BA1TRB->(BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG)+Space(2)+;
      						Substr(BA1TRB->BA1_NOMUSR,1,49)+Space(2)+;
      						dtoc(BA1TRB->BA1_DATNAS)+Space(9)+;
      						cIdade+Space(6)+;
      						iif(BA1TRB->BA1_UNIVER=='1','Sim','Nao')+Space(10)+;
      						BA1TRB->BRP_DESCRI 
      //��������������������������������������������������������������������Ŀ
      //� Acessa proximo registro...                                         �
      //����������������������������������������������������������������������
      BA1TRB->(DbSkip())
  Enddo    
  nLi := nLi + 2
Enddo
//��������������������������������������������������������������������Ŀ
//� Imprime rodape do relatorio...                                     �
//����������������������������������������������������������������������
if !lAutoSt
    Roda(0,space(10),cTamanho)
endif
//��������������������������������������������������������������������Ŀ
//� Fecha arquivo...                                                   �
//����������������������������������������������������������������������
BA1TRB->(DbCloseArea())
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If !lAutoSt .AND. aReturn[5] == 1 
    Set Printer To
    Ourspool(cRel)
Endif
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return

