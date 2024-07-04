#INCLUDE "plsr180.ch"
#include "TOPCONN.CH"
#include "PLSMGER.CH"
#include "Protheus.ch"

Static objCENFUNLGP := CENFUNLGP():New()
static lAutoSt := .F.
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR180 Ё Autor Ё Tulio Cesar            Ё Data Ё 13.06.00 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Previsao de pagamentos a credenciados a partir de movimen- Ё╠╠╠
╠╠Ё          Ё tacao de guias ou titulos gerados.                         Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR180()                                                  Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Uso      Ё Advanced Protheus                                          Ё╠╠╠
╠╠цддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Alteracoes desde sua construcao inicial                               Ё╠╠╠
╠╠цддддддддддбддддддбдддддддддддддбддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠Ё Data     Ё BOPS Ё Programador Ё Breve Descricao                       Ё╠╠╠
╠╠цддддддддддеддддддедддддддддддддеддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠юддддддддддаддддддадддддддддддддаддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define nome da funcao                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Function PLSR180(lAutoma)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Variaveis                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Default lAutoma := .F.

PRIVATE nNumLinhas  := 55
PRIVATE cNomeProg   := "PLSR180"
PRIVATE nCaracter   := 15
PRIVATE nColuna     := 00
PRIVATE nLimite     := 080
PRIVATE cTamanho    := "P"
PRIVATE cTitulo     := FunDesc() //"PrevisЦo de Pagamentos"
PRIVATE cDesc1      := FunDesc() //"PrevisЦo de Pagamentos"
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
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Variaveis de Controle                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cInd        := CriaTrab(Nil,.F.)
PRIVATE cAno
PRIVATE cMes
PRIVATE cGrupos
PRIVATE nMovimen
PRIVATE cLinha      := Space(00)
PRIVATE pMoeda      := "@E 99,999,999.99"
PRIVATE aSaldo   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de quebra por grupo...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PRIVATE cGrupo
PRIVATE nAcum   := 0
PRIVATE nTotal  := 0
PRIVATE nGeral  := 0
PRIVATE dDatMvIni  	:= ctod("")
PRIVATE dDatMvFin  	:= ctod("")

lAutoSt := lAutoma

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt
   cRel := SetPrint(cAlias,crel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrdens,lCompres,cTamanho,nil,lFiltro,lCrystal)
EndIf

	aAlias := {"BAU"}
	objCENFUNLGP:setAlias(aAlias)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND.nLastKey  == 27
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca parametros...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura Impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt
   SetDefault(aReturn,cAlias)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Executa imprensao do relatorio...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt
   MsAguarde ( { || RImp180() }, cTitulo, "", .T. )
Else
   RImp180()
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё RImp180 Ё Autor Ё Tulio Cesar            Ё Data Ё 13.06.00 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Emissao fisica do relatorio...                             Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function RImp180()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Expressao do Filtro...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL cMVPLSRDAG := GetNewPar("MV_PLSRDAG","999999")
LOCAL cFor := "BAU_FILIAL = '"+xFilial("BAU")+"' .And. BAU_CODIGO <> '"+cMVPLSRDAG+"'"

If ! Empty(cGrupos)
   cFor := cFor + " .And. BAU_TIPPRE $ '"+cGrupos+"'"
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe mensagem informativa...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt
   MsProcTXT(STR0009+"...") //"Lendo informacoes da base de dados"
EndIf

If ! Empty(aReturn[7])
   cFor := cFor + " .And. "+aReturn[7]
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta filtro de acordo com os grupos informados no parametro...          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt
   BAU->(IndRegua("BAU",cInd,"BAU_FILIAL+BAU_TIPPRE+BAU_NOME",nil,cFor,nil,.T.))
EndIf

#IFNDEF TOP
        nIndexBAU := BAU->(RetIndex("BAU")) 
        BAU->(dbSetIndex(cInd+OrdBagExt()))
        BAU->(dbSetOrder(nIndexBAU+1))
#ENDIF
BAU->(DbSeek(xFilial("BAU")))                     

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define quebra inicial...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cQuebra := BAU->BAU_TIPPRE
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cabecalho do relatorio...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
R180Cab()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da impressao...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! BAU->(Eof())
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Verifica se foi abortada a impressao...                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
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
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Exibe mensagem informativa...                                      Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If !lAutoSt
         MsProcTXT(STR0010+objCENFUNLGP:verCamNPR("BAU_NOME",AllTrim(BAU->BAU_NOME))+"...") //"Imprimindo "
      EndIf
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Registro valido. Imprime detalhe...                                Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      cLinha := objCENFUNLGP:verCamNPR("BAU_CODIGO",BAU->BAU_CODIGO)+Space(02)+objCENFUNLGP:verCamNPR("BAU_NOME",Subs(BAU->BAU_NOME,1,27))
      
      cLinha += Space(32)+TransForm(nTotal,pMoeda)
      nLi ++
      @ nLi, nColuna pSay cLinha           
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acumula valores totais por grupo...                                      Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      nAcum += nTotal
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acumula valores totais gerais...                                         Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      nGeral += nTotal
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Acessa proximo registro...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->(DbSkip())         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trata a mudanca de pagina                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLi > nNumLinhas
   R180Cab()
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trato quebra...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! BAU->(Eof())
   R180Que()   
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do laco de repeticao dos detalhes do relatorio...              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Impressao dos totais do ultimo grupo...                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLi ++
nLi ++
@ nLi, nColuna pSay STR0011+" "+cQuebra+" - "+Subs(PLDESGRU(cQuebra),1,19)+Space(26)+TransForm(nAcum,pMoeda) //"TOTAIS DO GRUPO"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Impressao dos totais gerais...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLi ++
nLi ++
@ nLi, nColuna pSay STR0012+"   "+Space(51)+TransForm(nGeral,pMoeda) //"TOTAIS GERAIS"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera area filtrada...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->(DbCloseArea())
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime rodade...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Roda(0,"",cTamanho)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If  aReturn[5] == 1 
    Set Printer To
    Ourspool(crel)
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina de Impressao do relatorio...                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё R180Cab Ё Autor Ё Tulio Cesar            Ё Data Ё 13.06.00 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Cabecalho do Relatorio...                                  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function R180Cab()

nLi ++
nLi := cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,IIF(aReturn[4]==1,GetMv("MV_COMP"),GetMv("MV_NORM")))
nLi ++ 

@ nLi, nColuna pSay STR0013+cQuebra+" - "+PLDESGRU(cQuebra) //"GRUPO:  "
 
nLi ++ 

Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё R180Que Ё Autor Ё Tulio Cesar            Ё Data Ё 13.06.00 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Quebra do relatorio...                                     Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
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


