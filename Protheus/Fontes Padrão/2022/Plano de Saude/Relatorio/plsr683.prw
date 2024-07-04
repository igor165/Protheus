
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR683 � Autor � Angelo Sperandio       � Data � 22.11.04 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Extrato de Utilizacao PJ                                   ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR683()                                                  ����
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
//� Associa arquivo de definicoes                                            �
//����������������������������������������������������������������������������
#include "PROTHEUS.CH"
#include "PLSR683.CH"
#include "PLSMGER.CH"
//��������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR683(lGerTxt1,cCodUsr)
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
DEFAULT lGerTxt1  := .F.
DEFAULT cCodUsr   := ""

PRIVATE lGerTxt   := lGerTxt1
Private cRelDir   :=GetMv("MV_RELT") 
PRIVATE nQtdLin
PRIVATE cNomeProg   := "PLSR683"
PRIVATE nCaracter   := 15
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := STR0001
PRIVATE cTitDem     := STR0036
PRIVATE cTpPrest    := ""
PRIVATE cDesc1      := STR0002
PRIVATE cDesc2      := STR0003
PRIVATE cDesc3      := STR0004
PRIVATE cAlias      := "BD7"
PRIVATE cPerg       := "PLR683"
PRIVATE nRel        := "PLSR683"
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { STR0005, 1,STR0006, 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0033
PRIVATE cCabec2     := STR0034
PRIVATE nColuna     := 00
PRIVATE nLi         := 0
//��������������������������������������������������������������������������Ŀ
//� Parametros do relatorio (SX1)...                                         �
//����������������������������������������������������������������������������
PRIVATE nTipoIm
PRIVATE cCodOpe
PRIVATE cCodCreDe
PRIVATE cCodCreAte
PRIVATE cAno   
PRIVATE cMes    
PRIVATE nTipoImpN
PRIVATE __pMoeda    := "@E 999,999.99"

PRIVATE cQuebLDP
PRIVATE cQuebPEG
PRIVATE cQuebTP
PRIVATE nImpBlq
//��������������������������������������������������������������������������Ŀ
//� Variaveis de mascara (picture)                                           �
//����������������������������������������������������������������������������
PRIVATE pMoeda      := "@E 99,999,999.99"
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal,,lGerTXT)
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)
nTipoImp  := mv_par01
cCpfCgc   := mv_par02
cAno      := mv_par03
//��������������������������������������������������������������������������Ŀ
//� Verifica se usuario tem acesso aos parametros informados                 �
//����������������������������������������������������������������������������


//��������������������������������������������������������������������������Ŀ
//� Configura Limite de linhas                                               �
//����������������������������������������������������������������������������
If nTipoImp == 1
   nQtdLin := 48
Else
   nQtdLin := 70
Endif
//��������������������������������������������������������������������������Ŀ
//� Configura impressora                                                     �
//����������������������������������������������������������������������������
If  lGerTXT
	SetPrintFile(nrel)
EndIF
SetDefault(aReturn,cAlias)
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
If  lGerTxt
    R683Imp()
Else
    MsAguarde({|| R683Imp() }, cTitulo, "", .T.)
Endif    
//��������������������������������������������������������������������������Ŀ
//� Libera filtro feito no arquivo BD7...                                    �
//����������������������������������������������������������������������������
BD7->(DbClearFilter())
BD7->(RetIndex("BD7"))
ms_flush()
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
//If  lGerTXT
//	RmvToken(cRelDir+nrel+".##R",aDados[7])
//EndIF
Return({.T.,""})
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R683Imp  � Autor � Angelo Sperandio      � Data � 22.11.04 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Imprime o extrato de utilizacao para PJ                    ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
/*/
Static Function R683Imp()
//��������������������������������������������������������������������������Ŀ
//� IndRegua...                                                              �
//����������������������������������������������������������������������������
Local   cbcont,cbtxt
//��������������������������������������������������������������������������Ŀ
//� Imprime                                                                  �
//����������������������������������������������������������������������������
nLi := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
nLi ++
@ nLi, nColuna pSay " teste linha 1"
nLi ++
@ nLi, nColuna pSay " teste linha 2"
nLi ++
@ nLi, nColuna pSay " teste linha 3"
nLi ++
@ nLi, nColuna pSay " teste linha 4"
nLi ++
@ nLi, nColuna pSay " teste linha 5"
nLi ++
@ nLi, nColuna pSay " teste linha 6"
roda(cbcont,cbtxt,ctamanho)
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  aReturn[5] == 1
    Set Printer To
	IIF(!lGerTxt,OurSpool(nrel),.t.)
End
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������

Return
