
//��������������������������������������������������������������������������Ŀ
//� Associa arquivo de definicoes                                            �
//����������������������������������������������������������������������������
#include "PLSMGER.CH"

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR036 � Autor � Eduardo Motta          � Data � 21.11.03 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Relatorio de Notas de Debito                               ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR036()                                                  ����
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
Function PLSR036()
//��������������������������������������������������������������������������Ŀ
//� Define variaveis padroes para todos os relatorios...                     �
//����������������������������������������������������������������������������
PRIVATE nQtdLin     := 55
PRIVATE cNomeProg   := "PLSR036"
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := "Relacao de Utilizacao de Servicos RDA�s por Familia"
PRIVATE cDesc1      := "Relacao de Utilizacao de Servicos RDA�s por Familia"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BDH"
PRIVATE cPerg       := "PLR036"
PRIVATE nRel        := "PLSR036"
PRIVATE nLi         := nQtdLin+1
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "Zebrado", 1,"Administracao", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := "Codigo do Usuario     Nome"
PRIVATE cCabec2     := "                      Dt.Atend     N.Debito Quant   Codigo AMB  Procedimento                                               V a l o r"
//                       xxxxxxxxxxxxxxxxxxxx  99/99/9999  99999999  9999  99.99.999-9  xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 999.999,99

//��������������������������������������������������������������������������Ŀ
//� Parametros do relatorio (SX1)...                                         �
//����������������������������������������������������������������������������
PRIVATE cMes
PRIVATE cAno
PRIVATE cCodInt
PRIVATE cCodEmp
PRIVATE lImpMaA
//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
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

cMes := mv_par01
cAno := mv_par02
cCodInt := mv_par03
cCodEmp := mv_par04
lImpMaA := If(mv_par05==1,.t.,.f.)
//��������������������������������������������������������������������������Ŀ
//� Configura impressora                                                     �
//����������������������������������������������������������������������������
SetDefault(aReturn,cAlias)
//��������������������������������������������������������������������������Ŀ
//� Emite relat�rio                                                          �
//����������������������������������������������������������������������������
MsAguarde({|| R036Imp() }, cTitulo, "", .T.)

Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R036Imp  � Autor � Eduardo Motta         � Data � 21.11.03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Emite relatorio de Notas de Debito                         ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R036Imp()
Local cLinha
Local aResp := {}
Local nCont := 0
Local nI    := 0
Local cDesCom
Local cDesPer1
Local cDesPer2
Local aStru := {{"TMP_CODUSR","C",20,0},;
                 {"TMP_NOMUSR","C",40,0},;
                 {"TMP_CODRDA","C",06,0},;
                 {"TMP_NOMRDA","C",40,0},;
                 {"TMP_DATATE","D",08,0},;
                 {"TMP_NOTDEB","C",08,0},;
                 {"TMP_QUANTI","N",06,0},;
                 {"TMP_CODAMB","C",11,0},;
                 {"TMP_DESPRO","C",60,0},;
                 {"TMP_VALOR" ,"N",12,2}}
Local cArqTmp
Local cIndTmp
Local cUsuAnt := ""
Local dDatAte
Local cNotDeb
Local cCodRda
Local nTotal      := 0.00
Local oTempTMP

/*
PENDENCIAS DO RELATORIO

1. Gerar informacoes no arquivo temporario

*/

//--< Cria��o do objeto FWTemporaryTable >---
oTempTMP := FWTemporaryTable():New( "TMP" )
oTempTMP:SetFields( aStru )
oTempTMP:AddIndex( "INDTMP",{ "TMP_CODUSR","TMP_CODRDA","TMP_DATATE","TMP_NOTDEB","TMP_CODAMB" } )

if( select( "TMP" ) > 0 )
	TMP->( dbCloseArea() )
endIf

oTempTMP:Create()

BD6->(DbSetOrder(9))
BD6->(DbSeek(xFilial()+cCodInt+cCodEmp+cAno+cMes))
While BD6->(!Eof()) .and. xFilial("BD6")+cCodInt+cCodEmp+cAno+cMes == BD6->(BD6_FILIAL+BD6_OPEUSR+BD6_CODEMP+BD6_ANOPAG+BD6_MESPAG)
   TMP->(RecLock("TMP",.T.))
   TMP->TMP_CODRDA := BD6->BD6_CODRDA
   TMP->TMP_NOMRDA := Posicione("BAU",1,xFilial("BAU")+BD6->BD6_CODRDA,"BAU_NOME")  
   If !lImpMaA
   		TMP->TMP_CODUSR := BD6->(BD6_OPEUSR+BD6_CODEMP+BD6_MATRIC+BD6_TIPREG)
   Else
   		TMP->TMP_CODUSR := BD6->(BD6_MATANT)
   Endif
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



/*
// gera informacoes para testar o relatorio, eliminar este FOR apos finalizar relatorio - EDUARDO MOTTA - 20/11/2003
For nI := 1 to 80
   TMP->(RecLock("TMP",.T.))
   If nI <= 40
      TMP->TMP_CODUSR := "024.0027.001491.00.5"
      TMP->TMP_NOMUSR := "JOAO ROBERTO NOVAES"
   Else
      TMP->TMP_CODUSR := "024.0027.003527.01.5"
      TMP->TMP_NOMUSR := "ADEMAR ZAPONI"
   EndIf   
   If nI <= 20
      TMP->TMP_CODRDA := "000001"
      TMP->TMP_NOMRDA := "CENTRO LAB ANAL CLIN S/C LTDA."
   ElseIf nI <= 40
      TMP->TMP_CODRDA := "000002"
      TMP->TMP_NOMRDA := "ENDOSCOPIA CENTRO PAULISTA LTDA."
   ElseIf nI <= 60
      TMP->TMP_CODRDA := "000001"
      TMP->TMP_NOMRDA := "CENTRO LAB ANAL CLIN S/C LTDA."
   Else
      TMP->TMP_CODRDA := "000002"
      TMP->TMP_NOMRDA := "ENDOSCOPIA CENTRO PAULISTA LTDA."
   EndIf   
   TMP->TMP_DATATE := CTOD("22/09/2003")+Int(nI/3)
   TMP->TMP_NOTDEB := "02582661"
   TMP->TMP_QUANTI := nI
   TMP->TMP_CODAMB := "28.01.029-9"
   TMP->TMP_DESPRO := "Bilirrubina total e fracoes"
   TMP->TMP_VALOR  := nI*130.55
   TMP->(MsUnlock())
Next
*/

//��������������������������������������������������������������������������Ŀ
//� Imprime cabecalho do relatorio...                                        �
//����������������������������������������������������������������������������
R036Pag(.T.)

TMP->(DbGoTop())
While !TMP->(Eof())
   R036Pag(.F.)
   If cUsuAnt # TMP->TMP_CODUSR
      nLi++
      @ ++nLi, 00 pSay TMP->TMP_CODUSR+"  "+TMP->TMP_NOMUSR
      dDatAte := NIL
      cNotDeb := NIL
      cCodRda := NIL
   EndIf
   If cCodRda # TMP->TMP_CODRDA
      nLi++
      @ ++nLi, 10 pSay "Prestador : "+TMP->TMP_CODRDA+" "+TMP->TMP_NOMRDA
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
   cCodRda := TMP->TMP_CODRDA
   dDatAte := TMP->TMP_DATATE
   cNotDeb := TMP->TMP_NOTDEB
   nTotal  += TMP->TMP_VALOR
   TMP->(DbSkip())
EndDo    
nLi++
@ ++nLi,73 pSay "T O T A L...................................."+Transform(nTotal,"@E 999,999,999.99")

//��������������������������������������������������������������������Ŀ
//� Imprime rodade padrao do produto Microsiga                         �
//����������������������������������������������������������������������
Roda(0,space(10),cTamanho)
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  aReturn[5] == 1
    Set Printer To
    Ourspool(nRel)
End

if( select( "TMP" ) > 0 )
	oTempTMP:delete()
endIf

//��������������������������������������������������������������������������Ŀ
//� Fim do Relat�rio                                                         �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
��������������������������������������������������������������������������Ŀ��
���Programa   � R036Pag  � Autor �   Eduardo Motta       � Data � 21.11.03 ���
��������������������������������������������������������������������������Ĵ��
���Descricao  � Avanca pagina caso necessario...                           ���
���������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R036Pag(l1Vez)

If nLi > nQtdLin
   nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
Endif   

Return