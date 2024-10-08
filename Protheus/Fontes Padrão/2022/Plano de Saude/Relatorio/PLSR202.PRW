#INCLUDE "plsr202.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"
static lAutoSt := .F.
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR202 � Autor � Michele Tatagiba       � Data � 03.07.02 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Classe do Procedimento                                     ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR202()                                                  ����
�������������������������������������������������������������������������Ĵ���
��� Uso      � Advanced Protheus                                          ����
�������������������������������������������������������������������������Ĵ���
��� Alteracoes desde sua construcao inicial                               ����
�������������������������������������������������������������������������Ĵ���
��� Data     � BOPS � Programador � Breve Descricao                       ����
�������������������������������������������������������������������������Ĵ���
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao...                                                 �
//����������������������������������������������������������������������������
Function PLSR202(lAuto)
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
Default lAuto := .F.

PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR202"
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := STR0001 //"Classe de Procedimento"
PRIVATE cDesc1      := STR0001 //"Classe de Procedimento"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BJE"
PRIVATE cPerg       := "PLR202"
PRIVATE nRel        := "PLSR202"
PRIVATE nLi         := nQtdLin+1
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {STR0002,STR0003} //"Codigo da Classe"###"Descricao"
PRIVATE aReturn     := { STR0004, 1,STR0005, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0006 //"Operadora  Codigo    Descricao "
PRIVATE cCabec2     := ""
//��������������������������������������������������������������������������Ŀ
//� Parametros do relatorio (SX1)...                                         �
//����������������������������������������������������������������������������
PRIVATE cIntde
PRIVATE cIntAte
Private cClasDe
Private cClasAte

lAutoSt := lAuto

//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
If !lAutoSt
   nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
EndIf
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If !lAutoSt .AND. nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)

cIntDe  := mv_par01
cIntAte := mv_par02
cClasDe := mv_par03
cClasAte := mv_par04

If lAutoSt
   cIntDe   := "0001" 
   cIntAte  := "0001" 
   cClasDe  := "      "
   cClasAte := "ZZZZZZ"
EndIf
//��������������������������������������������������������������������������Ŀ
//� Configura impressora                                                     �
//����������������������������������������������������������������������������
If !lAutoSt
   SetDefault(aReturn,cAlias)
EndIf
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
If !lAutoSt
   MsAguarde({|| R202Imp() }, cTitulo, "", .T.)
Else
   R202Imp()
EndIf
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R202Imp  � Autor � Michele Tatagiba      � Data � 03.07.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relacao de Classes de Procedimentos ...              ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R202Imp()
LOCAL nOrdSel   := aReturn[8] // Ordem selecionada...
LOCAL nQtdPar   := 0
LOCAL cSQL
LOCAL cBJEName  := RetSQLName("BJE")
//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem...                                                        �
//����������������������������������������������������������������������������
If !lAutoSt
   MsProcTxt(PLSTR0001)
EndIf
//��������������������������������������������������������������������������Ŀ
//� Faz filtro no arquivo...                                                 �
//����������������������������������������������������������������������������
cSQL := " SELECT * "
cSQL += " FROM "+cBJEName+" "
cSQL += " WHERE "+cBJEName+".D_E_L_E_T_ = '' AND "
cSQL += " BJE_FILIAL = '"+xFilial("BJE")+"' AND "
cSQL += " BJE_CODINT >= '"+cIntde+"' AND BJE_CODINT <= '"+cIntAte+"' AND "
cSQL += " BJE_CODIGO >= '"+cClasDe+"' AND BJE_CODIGO <= '"+cClasAte+"' "
//��������������������������������������������������������������������������Ŀ
//� Se houver filtro executa parse para converter expressoes adv para SQL    �
//����������������������������������������������������������������������������
If ! Empty(aReturn[7])
   cSQL += " AND " + PLSParSQL(aReturn[7])
Endif
//��������������������������������������������������������������������������Ŀ
//� Monta ordem...                                                           �
//����������������������������������������������������������������������������
If nOrdSel == 1
   cSQL += "ORDER BY BJE_FILIAL,BJE_CODIGO"
Else
   cSQL += "ORDER BY BJE_FILIAL,BJE_DESCRI"
Endif

cSQL := 	ChangeQuery(cSQL)
	
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"Trb202",.F.,.T.)
	
Trb202->(DbGotop())
//��������������������������������������������������������������������������Ŀ
//� Posicione no primeiro registro no arquivo de usuarios...                 �
//����������������������������������������������������������������������������
nLi  := 100
R202Pag()
While ! Trb202->(Eof())
      //��������������������������������������������������������������������Ŀ
      //� Verifica se foi abortada a impressao...                            �
      //����������������������������������������������������������������������
      If lAbortPrint
   	   @nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
      	Exit
	   Endif
      
      nQtdPar ++
      If !lAutoSt
         MsPROCTxt(STR0007+Trb202->BJE_CODIGO) //"Codigo da Classe "
      EndIf     
      @ ++nLi, 00 pSay Transform(Trb202->BJE_CODINT,"@R !.!!!")+Space(06)+Trb202->BJE_CODIGO+;
                        Space(04)+Trb202->BJE_DESCRI

      Trb202->(DbSkip())
      R202Pag()
Enddo
          
nLi ++
nLi ++
R202Pag()
@ nLi, 00 pSay Replicate("*",nLimite) 
nLi ++
nLi ++ 
R202Pag()
@ nLi, 00 pSay STR0008+AllTrim(Transform(nQtdPar,"@R 99999")) //"TOTAL DE REGISTROS "
nLi ++
nLi ++
//��������������������������������������������������������������������Ŀ
//� Imprime rodade padrao do produto Microsiga                         �
//����������������������������������������������������������������������
Roda(0,space(10),cTamanho)

Trb202->(DbCloseArea())   

SET DEVICE TO SCREEN
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(nrel)
Endif

MS_FLUSH()

//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R202Pag  � Autor � Michele Tatagiba      � Data � 03.07.02 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Avanca pagina caso necessario...                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R202Pag()

If nLi > nQtdLin
   nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
Endif
Return

