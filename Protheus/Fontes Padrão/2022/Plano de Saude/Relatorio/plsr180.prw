#INCLUDE "plsr180.ch"
#include "TOPCONN.CH"
#include "PLSMGER.CH"
#include "Protheus.ch"

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � PLSR180 � Autor � Tulio Cesar            � Data � 13.06.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Previsao de pagamentos a credenciados a partir de movimen- ����
���          � tacao de guias ou titulos gerados.                         ����
�������������������������������������������������������������������������Ĵ���
���Sintaxe   � PLSR180()                                                  ����
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
//� Define nome da funcao                                                    �
//����������������������������������������������������������������������������
Function PLSR180(lAutoma)
//��������������������������������������������������������������������������Ŀ
//� Define Variaveis                                                         �
//����������������������������������������������������������������������������
Default lAutoma := .F.

PRIVATE nNumLinhas  := 55
PRIVATE cNomeProg   := "PLSR180"
PRIVATE nCaracter   := 15
PRIVATE nColuna     := 00
PRIVATE nLimite     := 080
PRIVATE cTamanho    := "P"
PRIVATE cTitulo     := FunDesc() //"Previs�o de Pagamentos"
PRIVATE cDesc1      := FunDesc() //"Previs�o de Pagamentos"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cCabec1     := STR0002+"       "+STR0003+"                                                   "+STR0004 //"CODIGO"###"NOME DA RDA"###"VALOR"
PRIVATE cCabec2     := ""
PRIVATE cAlias      := "BAU"
PRIVATE cPerg       := "PLR180"
PRIVATE crel        := "PLSR180"
PRIVATE nLi         := 01
PRIVATE m_pag       := 1
PRIVATE aReturn     := { STR0005, 1,STR0006, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE aOrdens     := {STR0007+" + "+STR0008} //"Grupo"###"Nome do Credenciado"
PRIVATE lAbortPrint := .F.                  
PRIVATE lDicion     := .F.
PRIVATE lCompres    := .F.
PRIVATE lCrystal    := .F.
PRIVATE lFiltro     := .T.
//��������������������������������������������������������������������������Ŀ
//� Variaveis de Controle                                                    �
//����������������������������������������������������������������������������
PRIVATE cInd        := CriaTrab(Nil,.F.)
PRIVATE cAno
PRIVATE cMes
PRIVATE cGrupos
PRIVATE nMovimen
PRIVATE cLinha      := Space(00)
PRIVATE pMoeda      := "@E 99,999,999.99"
PRIVATE aSaldo   
//��������������������������������������������������������������������������Ŀ
//� Controle de quebra por grupo...                                          �
//����������������������������������������������������������������������������
PRIVATE cGrupo
PRIVATE nAcum   := 0
PRIVATE nTotal  := 0
PRIVATE nGeral  := 0
PRIVATE dDatMvIni  	:= ctod("")
PRIVATE dDatMvFin  	:= ctod("")

lAutoSt := lAutoma

//��������������������������������������������������������������������������Ŀ
//� Chama SetPrint                                                           �
//����������������������������������������������������������������������������
If !lAutoSt
   cRel := SetPrint(cAlias,crel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,cTamanho,nil,lFiltro,lCrystal)
EndIf

	aAlias := {"BAU"}
	objCENFUNLGP:setAlias(aAlias)

//��������������������������������������������������������������������������Ŀ
//� Verifica se foi cancelada a operacao                                     �
//����������������������������������������������������������������������������
If !lAutoSt .AND.nLastKey  == 27
   Return
Endif
//��������������������������������������������������������������������������Ŀ
//� Busca parametros...                                                      �
//����������������������������������������������������������������������������
Pergunte(cPerg,.F.)

cCodOpe  := mv_par01
cAno     := mv_par02
cMes     := mv_par03
cGrupos  := AllTrim(mv_par04)
dDatMvIni := mv_par05
dDatMvFin := mv_par06


If lAutoSt
   cCodOpe  := "0001"
   cAno     := "2009"
   cMes     := "06"
   cGrupos  := "MED,LAB,HOS,OPE"
EndIf

cTitulo  := AllTrim(cTitulo)+" - "+PLRETMES(Val(cMes))+"/"+cAno
//��������������������������������������������������������������������������Ŀ
//� Configura Impressora                                                     �
//����������������������������������������������������������������������������
If !lAutoSt
   SetDefault(aReturn,cAlias)
EndIf
//��������������������������������������������������������������������������Ŀ
//� Executa imprensao do relatorio...                                        �
//����������������������������������������������������������������������������
If !lAutoSt
   MsAguarde ( { || RImp180() }, cTitulo, "", .T. )
Else
   RImp180()
EndIf
//��������������������������������������������������������������������������Ŀ
//� Fim da rotina                                                            �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � RImp180 � Autor � Tulio Cesar            � Data � 13.06.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Emissao fisica do relatorio...                             ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Function RImp180()
//��������������������������������������������������������������������������Ŀ
//� Define Expressao do Filtro...                                            �
//����������������������������������������������������������������������������
LOCAL cMVPLSRDAG := GetNewPar("MV_PLSRDAG","999999")
LOCAL cFor := "BAU_FILIAL = '"+xFilial("BAU")+"' .And. BAU_CODIGO <> '"+cMVPLSRDAG+"'"

If ! Empty(cGrupos)
   cFor := cFor + " .And. BAU_TIPPRE $ '"+cGrupos+"'"
Endif   
//��������������������������������������������������������������������������Ŀ
//� Exibe mensagem informativa...                                            �
//����������������������������������������������������������������������������
If !lAutoSt
   MsProcTXT(STR0009+"...") //"Lendo informacoes da base de dados"
EndIf

If ! Empty(aReturn[7])
   cFor := cFor + " .And. "+aReturn[7]
Endif   
//��������������������������������������������������������������������������Ŀ
//� Monta filtro de acordo com os grupos informados no parametro...          �
//����������������������������������������������������������������������������
If !lAutoSt
   BAU->(IndRegua("BAU",cInd,"BAU_FILIAL+BAU_TIPPRE+BAU_NOME",nil,cFor,nil,.T.))
EndIf

#IFNDEF TOP
        nIndexBAU := BAU->(RetIndex("BAU")) 
        BAU->(dbSetIndex(cInd+OrdBagExt()))
        BAU->(dbSetOrder(nIndexBAU+1))
#ENDIF
BAU->(DbSeek(xFilial("BAU")))                     

//��������������������������������������������������������������������������Ŀ
//� Define quebra inicial...                                                 �
//����������������������������������������������������������������������������
cQuebra := BAU->BAU_TIPPRE
//��������������������������������������������������������������������������Ŀ
//� Cabecalho do relatorio...                                                �
//����������������������������������������������������������������������������
R180Cab()
//��������������������������������������������������������������������������Ŀ
//� Inicio da impressao...                                                   �
//����������������������������������������������������������������������������
While ! BAU->(Eof())
      //��������������������������������������������������������������������Ŀ
      //� Verifica se foi abortada a impressao...                            �
      //����������������������������������������������������������������������
      If Interrupcao(lAbortPrint)
         Exit
      Endif

      aSaldo  := PLSLDCRE(BAU->BAU_CODIGO,cAno,cMes,dDatMvIni,dDatMvFin,"","ZZZZ","","ZZZZZZZZZZZZZZZZ","","ZZZZZZZZZZZZZZZZ",;
                          cCodOpe,BAU->BAU_CODSA2,BAU->BAU_LOJSA2)
      If aSaldo[1]
         nTotal := aSaldo[4,1]
      Else
         nTotal := 0
      Endif   
      //��������������������������������������������������������������������Ŀ
      //� Exibe mensagem informativa...                                      �
      //����������������������������������������������������������������������
      If !lAutoSt
         MsProcTXT(STR0010+objCENFUNLGP:verCamNPR("BAU_NOME",AllTrim(BAU->BAU_NOME))+"...") //"Imprimindo "
      EndIf
      //��������������������������������������������������������������������Ŀ
      //� Registro valido. Imprime detalhe...                                �
      //����������������������������������������������������������������������
      cLinha := objCENFUNLGP:verCamNPR("BAU_CODIGO",BAU->BAU_CODIGO)+Space(02)+objCENFUNLGP:verCamNPR("BAU_NOME",Subs(BAU->BAU_NOME,1,27))
      
      cLinha += Space(32)+TransForm(nTotal,pMoeda)
      nLi ++
      @ nLi, nColuna pSay cLinha           
      //��������������������������������������������������������������������������Ŀ
      //� Acumula valores totais por grupo...                                      �
      //����������������������������������������������������������������������������
      nAcum += nTotal
      //��������������������������������������������������������������������������Ŀ
      //� Acumula valores totais gerais...                                         �
      //����������������������������������������������������������������������������
      nGeral += nTotal
//��������������������������������������������������������������������������Ŀ
//� Acessa proximo registro...                                               �
//����������������������������������������������������������������������������
BAU->(DbSkip())         
//��������������������������������������������������������������������������Ŀ
//� Trata a mudanca de pagina                                                �
//����������������������������������������������������������������������������
If nLi > nNumLinhas
   R180Cab()
Endif
//��������������������������������������������������������������������Ŀ
//� Trato quebra...                                                    �
//����������������������������������������������������������������������
If ! BAU->(Eof())
   R180Que()   
Endif   
//��������������������������������������������������������������������Ŀ
//� Fim do laco de repeticao dos detalhes do relatorio...              �
//����������������������������������������������������������������������
Enddo
//��������������������������������������������������������������������������Ŀ
//� Impressao dos totais do ultimo grupo...                                  �
//����������������������������������������������������������������������������
nLi ++
nLi ++
@ nLi, nColuna pSay STR0011+" "+cQuebra+" - "+Subs(PLDESGRU(cQuebra),1,19)+Space(26)+TransForm(nAcum,pMoeda) //"TOTAIS DO GRUPO"
//��������������������������������������������������������������������������Ŀ
//� Impressao dos totais gerais...                                           �
//����������������������������������������������������������������������������
nLi ++
nLi ++
@ nLi, nColuna pSay STR0012+"   "+Space(51)+TransForm(nGeral,pMoeda) //"TOTAIS GERAIS"
//��������������������������������������������������������������������������Ŀ
//� Libera area filtrada...                                                  �
//����������������������������������������������������������������������������
BAU->(DbCloseArea())
//��������������������������������������������������������������������������Ŀ
//� Imprime rodade...                                                        �
//����������������������������������������������������������������������������
Roda(0,"",cTamanho)
//��������������������������������������������������������������������������Ŀ
//� Libera impressao                                                         �
//����������������������������������������������������������������������������
If  aReturn[5] == 1 
    Set Printer To
    Ourspool(crel)
End
//��������������������������������������������������������������������������Ŀ
//� Fim da Rotina de Impressao do relatorio...                               �
//����������������������������������������������������������������������������
Return
/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � R180Cab � Autor � Tulio Cesar            � Data � 13.06.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Cabecalho do Relatorio...                                  ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R180Cab()

nLi ++
nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
nLi ++ 

@ nLi, nColuna pSay STR0013+cQuebra+" - "+PLDESGRU(cQuebra) //"GRUPO:  "
 
nLi ++ 

Return

/*/
������������������������������������������������������������������������������
������������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ���
���Funcao    � R180Que � Autor � Tulio Cesar            � Data � 13.06.00 ����
�������������������������������������������������������������������������Ĵ���
���Descricao � Quebra do relatorio...                                     ����
��������������������������������������������������������������������������ٱ��
������������������������������������������������������������������������������
������������������������������������������������������������������������������
/*/
Static Function R180Que()

If cQuebra <> BAU->BAU_TIPPRE
   nLi ++
   nLi ++
   @ nLi, nColuna pSay STR0014+cQuebra+" - "+Subs(PLDESGRU(cQuebra),1,19)+Space(26)+TransForm(nAcum,pMoeda) //"TOTAIS DO GRUPO "
   nAcum := 0
   
   cQuebra := BAU->BAU_TIPPRE
   If ! BAU->(Eof())
      R180Cab()
   Endif   
Endif   

Return


