
//��������������������������������������������������������������������������Ŀ
//� Associa arquivo de definicoes                                            �
//����������������������������������������������������������������������������
#include "PLSMGER.CH"
#include "PROTHEUS.CH"

Static lAutoSt := .F.

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR035 � Autor � Eduardo Motta          � Data � 20.11.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Notas de Debito                               ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR035()                                                  ����
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
//�������������������������������������������������������������������������Ŀ
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR035(lAuto)
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
default lAuto := .F.

PRIVATE nQtdLin     := 55
PRIVATE cNomeProg   := "PLR035"
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := "Movimentacao de Co-Participacao/Custo Operacional"
PRIVATE cDesc1      := "Movimentacao de Co-Participacao/Custo Operacional"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BDH"
PRIVATE cPerg       := "PLR035"
PRIVATE nRel        := "PLSR035"
PRIVATE nLi         := nQtdLin+1
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "Codigo do Usuario       Nome"
PRIVATE cCabec2     := "                      Dt.Atend    N.Debito  Quant   Codigo AMB  Procedimento                                               V a l o r"
//                       xxxxxxxxxxxxxxxxxxxx 99/99/9999  99999999   9999  99.99.999-9  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 999.999,99


//��������������������������������������������������������������������������Ŀ
//� Parametros do relatorio (SX1)...                                         �
//����������������������������������������������������������������������������
PRIVATE cMes
PRIVATE cAno
PRIVATE cCodInt
PRIVATE cCodEmp
PRIVATE cContrato
Private cVerCon
Private cSubCon
Private cVerSub
Private cMatric
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������

lAutoSt := lAuto

if !lAuto
   nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If !lAuto .AND. nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Acessa parametros do relatorio...                                        �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)

cMes      := mv_par01
cAno      := mv_par02
cCodInt   := mv_par03
cCodEmp   := mv_par04
cContrato := mv_par05
cVerCon   := mv_par06
cSubCon   := mv_par07
cVerSub   := mv_par08
cMatric   := mv_par09

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
   MsAguarde({|| R035Imp() }, cTitulo, "", .T.)
else
   R035Imp()
endif
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R035Imp  � Autor � Eduardo Motta         � Data � 20.11.03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio de Notas de Debito                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R035Imp()
Local cLinha
Local aResp := {}
Local nCont := 0
Local nI    := 0
Local cDesCom
Local cDesPer1
Local cDesPer2
Local aStru := {{"TMP_CODUSR","C",20,0},;
                 {"TMP_DIGITO","C",01,0},;
                 {"TMP_NOMUSR","C",40,0},;
                 {"TMP_DATATE","D",08,0},;
                 {"TMP_NOTDEB","C",08,0},;
                 {"TMP_QUANTI","N",06,0},;
                 {"TMP_CODAMB","C",11,0},;
                 {"TMP_DESPRO","C",60,0},;
                 {"TMP_VALOR" ,"N",12,2}}
Local cArqTmp
Local cIndTmp
Local cUsuAnt
Local dDatAte
Local cNotDeb
Local nUsuBasInss := 0.00
Local nTotBasInss := 0.00
Local nTotal      := 0.00
Local nTotVlrInss := 0.00
Local nBaseInss
Local nValInss
Local nPerInss    := 15
Local oTempTMP

/*
PENDENCIAS DO RELATORIO

1. Gerar informacoes no arquivo temporario

*/

//--< Cria��o do objeto FWTemporaryTable >---
oTempTMP := FWTemporaryTable():New( "TMP" )
oTempTMP:SetFields( aStru )
oTempTMP:AddIndex( "INDTMP",{ "TMP_CODUSR","TMP_DATATE","TMP_NOTDEB","TMP_CODAMB" } )

if( select( "TMP" ) > 0 )
	TMP->( dbCloseArea() )
endIf

oTempTMP:Create()

BA1->(DbSetOrder(2))
BD6->(DbSetOrder(9))
BD6->(DbSeek(xFilial()+cCodInt+cCodEmp+cAno+cMes))
While BD6->(!Eof()) .and. xFilial("BD6")+cCodInt+cCodEmp+cAno+cMes == BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_ANOPAG+BD6_MESPAG)
   If Empty(BD6->BD6_VLRTPF)
      BD6->(DbSkip())
      Loop
   EndIf   
   If !Empty(cContrato) .and. cContrato # BD6->BD6_CONEMP
      BD6->(DbSkip())
      Loop
   EndIf   
   If !Empty(cVerCon) .and. cVerCon # BD6->BD6_VERCON
      BD6->(DbSkip())
      Loop
   EndIf   
   If !Empty(cSubCon) .and. cSubCon # BD6->BD6_SUBCON
      BD6->(DbSkip())
      Loop
   EndIf   
   If !Empty(cVerSub) .and. cVerSub # BD6->BD6_VERSUB
      BD6->(DbSkip())
      Loop
   EndIf   
   If !Empty(cMatric) .and. cMatric # SubStr(BD6->BD6_MATRIC,1,6) 
      BD6->(DbSkip())
      Loop
   EndIf   
   BA1->(DbSeek(xFilial()+BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)))
   TMP->(RecLock("TMP",.T.))
   TMP->TMP_CODUSR := Transform(BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG),__cPictUsr)
   TMP->TMP_DIGITO := BA1->BA1_DIGITO
   TMP->TMP_NOMUSR := BD6->BD6_NOMUSR
   TMP->TMP_DATATE := BD6->BD6_DATPRO
   TMP->TMP_NOTDEB := BD6->BD6_NUMIMP
   TMP->TMP_QUANTI := BD6->BD6_QTDPRO
   TMP->TMP_CODAMB := BD6->BD6_CODPRO
   TMP->TMP_DESPRO := BD6->BD6_DESPRO
   TMP->TMP_VALOR  := BD6->BD6_VLRTPF
   TMP->(MsUnlock())
   BD6->(DbSkip())
EndDo
//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho do relatorio...                                        �
//����������������������������������������������������������������������������
R035Pag(.T.)

TMP->(DbGoTop())
While !TMP->(Eof())
   R035Pag(.F.)
   If cUsuAnt # TMP->TMP_CODUSR
      @ ++nLi, 00 pSay TMP->TMP_CODUSR+"-"+TMP->TMP_DIGITO+" "+TMP->TMP_NOMUSR
      dDatAte := NIL
      cNotDeb := NIL
   EndIf
   If dDatAte # TMP->TMP_DATATE
      @ ++nLi,22 pSay DtoC(TMP->TMP_DATATE)
      cNotDeb := NIL
   Else   
      @ ++nLi,22 pSay Space(10)
   EndIf
   If cNotDeb # TMP->TMP_NOTDEB
      @ nLi,34 pSay TMP->TMP_NOTDEB
   EndIf   
   @ nLi,	46 pSay Str(TMP->TMP_QUANTI,4)+"  "+TMP->TMP_CODAMB+" "+PadR(TMP->TMP_DESPRO,57)+" "+Transform(TMP->TMP_VALOR,"@E 999,999.99")
   cUsuAnt := TMP->TMP_CODUSR
   dDatAte := TMP->TMP_DATATE
   cNotDeb := TMP->TMP_NOTDEB
   nBaseInss := TMP->TMP_VALOR*0.50
   nUsuBasInss += nBaseInss
   nTotBasInss += nBaseInss
   nTotal      += TMP->TMP_VALOR
   
   TMP->(DbSkip())
   If cUsuAnt # TMP->TMP_CODUSR
      nValInss := (nUsuBasInss * nPerInss) / 100
      @ ++nLi,10 pSay "*** BASE DE CALCULO DO INSS PARA O TITULAR "+Transform(nUsuBasInss,"@E 999,999,999.99")+"    VALOR DO INSS DO TITULAR ("+Str(nPerInss,2)+"%) "+Transform(nValInss,"@E 999,999,999.99")+"  ***"
      nLi++
      nTotVlrInss += nValInss
      nUsuBasInss := 0.00
   EndIf
EndDo    
nLi++
@ ++nLi,73 pSay "T O T A L...................................."+Transform(nTotal,"@E 999,999,999.99")
@ ++nLi,73 pSay "BASE DE CALCULO PARA INSS DA EMPRESA........."+Transform(nTotBasInss,"@E 999,999,999.99")
@ ++nLi,73 pSay "VALOR DO INSS ("+Str(nPerInss,2)+"%) SERVICOS RDA�S........."+Transform(nTotVlrInss,"@E 999,999,999.99")

//��������������������������������������������������������������������Ŀ
//� Imprime rodade padrao do produto Microsiga                         �
//����������������������������������������������������������������������
//Roda(0,space(10),cTamanho)
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(nRel)
End
//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������

if( select( "TMP" ) > 0 )
	oTempTMP:delete()
endIf

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R035Pag  � Autor �   Eduardo Motta       � Data � 20.11.03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Avanca pagina caso necessario...                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R035Pag(l1Vez)

If !lAutoSt .AND. nLi > nQtdLin
   nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
Endif   

Return
