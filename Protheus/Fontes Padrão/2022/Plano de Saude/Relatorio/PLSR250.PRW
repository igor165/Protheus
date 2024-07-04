
#INCLUDE "Plsr250.ch"
#include "PLSMGER.CH"
#INCLUDE "PROTHEUS.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt := .F.

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбддддддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSR250 Ё Autor Ё Tulio Cesar            Ё Data Ё 27.07.00 Ё╠╠╠
╠╠цддддддддддедддддддддадддддддаддддддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Posicao financeira por contrato.                           Ё╠╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠╠
╠╠ЁSintaxe   Ё PLSR250()                                                  Ё╠╠╠
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
Function PLSR250(lAuto)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define variaveis padroes para todos os relatorios...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Default lAuto := .F.

PRIVATE nQtdLin
PRIVATE cNomeProg   := "PLSR250"
PRIVATE nCaracter   := 15
PRIVATE nLimite     := 132
PRIVATE cTamanho    := "M"
PRIVATE cTitulo     := FunDesc() //"PosiГЦo Financeira de CobranГa"
PRIVATE cDesc1      := STR0002
PRIVATE cDesc2      := "" 
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BA3"
PRIVATE cPerg       := "PLR250"
PRIVATE nRel        := "PLSR250"
PRIVATE nli         := 01
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {STR0003}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0004
PRIVATE cCabec2     := ""
PRIVATE nColuna     := 00
PRIVATE nTipoIm

lAutoSt := lAuto
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama SetPrint                                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
   nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,cTamanho,{},lFiltro,lCrystal)
endif
	aAlias := {"BA3","SE1","BA1","SA1"}
	objCENFUNLGP:setAlias(aAlias)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verifica se foi cancelada a operacao                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND. nLastKey  == 27
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Acessa parametros do relatorio...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Pergunte(cPerg,.F.)

nTipoImp   := mv_par01
cGruDe     := mv_par02
cGruAte    := mv_par03
cMatDe     := mv_par04
cMatAte    := mv_par05
lAberto    := If(mv_par06==1,.T.,.F.)
nConsid    := mv_par07
nQtdPar    := mv_par08
nDias      := mv_par09
cGrpCobDe  := mv_par10
cGrpCobAte := mv_par11
nVenctoDe  := mv_par12
nVenctoAte := mv_par13
cNatureDe  := mv_par14
cNatureAte := mv_par15
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura Limite de linhas                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nTipoImp == 1
   nQtdLin := 55
Else
   nQtdLin := 70
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Configura impressora                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
   SetDefault(aReturn,cAlias)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta o titulo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTitulo := alltrim(cTitulo) + STR0005 + aOrderns[aReturn[8]]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Emite relat╒rio                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAuto
   MsAguarde({|| R250Imp() }, cTitulo, "", .T.)
else
   R250Imp()
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera filtro feito no arquivo BA3...                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(DbClearFilter())
BA3->(RetIndex("BA3"))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da rotina                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R250Imp  Ё Autor Ё Tulio Cesar           Ё Data Ё 27.07.00 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Imprime a listagem financeira por contrato...              Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function R250Imp()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё IndRegua...                                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
LOCAL nOrd    := aReturn[8]
Local nCont
LOCAL cFor
LOCAL cOrdem
LOCAL cInd    := CriaTrab(Nil,.F.)
LOCAL pMoeda  := "@E 99,999.99"
LOCAL nSaldo
LOCAL nQtdCon := 0
LOCAL nSalCon := 0
LOCAL i
LOCAL cMvPLORDE1 := GETMV("MV_PLORDE1")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Exibe mensagem...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
   MsProcTxt(PLSTR0001)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta expressao de filtro para o IndRegua...                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFor := "BA3_FILIAL = '"+xFilial("BA3")+"'"

cFor := cFor + " .And. BA3_CODEMP >= '"+cGruDe+"' .And. BA3_CODEMP <= '"+cGruAte+"'"
cFor := cFor + " .And. BA3_MATRIC >= '"+cMatDe+"' .And. BA3_MATRIC <= '"+cMatAte+"'"
cFor := cFor + " .And. BA3_GRPCOB >= '"+cGrpCobDe+"' .And. BA3_GRPCOB <= '"+cGrpCobAte+"'"
cFor := cFor + " .And. BA3_VENCTO >= "+AllTrim(Str(nVenctoDe))+" .And. BA3_VENCTO <= "+AllTrim(Str(nVenctoAte))
cFor := cFor + " .And. BA3_NATURE >= '"+cNatureDe+"' .And. BA3_NATURE <= '"+cNatureAte+"'"

If ! Empty(aReturn[7])
   cFor := cFor + " .And. "+AllTrim(aReturn[7])
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta ordem de acordo com o parametro...                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If     nOrd == 1
       cOrdem := "BA3_FILIAL+STR(BA3->BA3_VENCTO,3)+BA3_CODINT+BA3_CODEMP+BA3_MATRIC"
Endif      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta filtro de acordo com os grupos informados no parametro...          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
   BA3->(IndRegua("BA3",cInd,cOrdem,nil,cFor,nil,.T.))
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa fim de arquivo...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND. BA3->(Eof())
   Help("",1,"RECNO")
   Return
Endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define Ordens Default...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->(DbSetOrder(1))
SA1->(DbSetOrder(1))
SA3->(DbSetOrder(1))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime cabecalho...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nLi := 100
R250Pag()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da impressao dos detalhes...                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(DbGoTop())

nQueb := 9999

While ! BA3->(Eof())
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Verifica se foi abortada a impressao...                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If !lAutoSt .AND. Interrupcao(lAbortPrint)
         nLi ++
         @ nLi, nColuna pSay PLSTR0002
         Exit
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Testa quebra...                                                    Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If nQueb <> BA3->BA3_VENCTO
         nLi ++
         @ nLi, nColuna pSay alltrim(STR0006) + objCENFUNLGP:verCamNPR("BA3_VENCTO",Str(BA3->BA3_VENCTO,3))
         nLi ++
         nQueb := BA3->BA3_VENCTO
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Posiciona no cliente do contrato...                                Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      IF ! SA1->(DbSeek(xFilial("SA1")+BA3->(BA3_CODCLI+BA3_LOJA)))
         cNomeCli := objCENFUNLGP:verCamNPR("A1_NOME",Space(Len(SA1->A1_NOME)))
      Else                                     
         cNomeCli := objCENFUNLGP:verCamNPR("A1_NOME",SA1->A1_NOME)
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Posiciona no vendedor...                                           Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      IF ! SA3->(DbSeek(xFilial("SA3")+BA3->(BA3_CODVEN)))
         cNomeVen := Space(Len(SA3->A3_NREDUZ))
      Else                                     
         cNomeVen := SA3->A3_NREDUZ
      Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Posiciona no titular...                                            Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BA1->(DbSetOrder(2))
      
      BA1->(DbSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Exibe mensagem...                                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      cValue := "BA3->"+cOrdem
      if !lAutoSt
         cValue := &cValue
      endif
      if !lAutoSt
         MsProcTXT(STR0007+Str(nQueb,3)+"...")
      endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Importante: Neste relatorio os dados sao impressos a partir de     Ё
      //Ё             arrays...                                              Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      nCont  := 0
      nSaldo := 0
      aDados := {}
      aSE1   := {}
      lDados := .F.
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Dados do contrato...                                               Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      aadd(aDados,  objCENFUNLGP:verCamNPR("BA3_CODINT",BA3->BA3_CODINT) + "." +;
                    objCENFUNLGP:verCamNPR("BA3_CODEMP",BA3->BA3_CODEMP) + "-" +;
                    objCENFUNLGP:verCamNPR("BA3_MATRIC",BA3->BA3_MATRIC) + Space(02) +;
                    objCENFUNLGP:verCamNPR("BA3_DATBAS",dtoc(BA3->BA3_DATBAS)) + Space(03) +;
                    cNomeCli + Space(01) +;
                    objCENFUNLGP:verCamNPR("A1_TEL",SA1->A1_TEL) + Space(02) +;
                    objCENFUNLGP:verCamNPR("BA1_NOMUSR",substr(BA1->BA1_NOMUSR,1,32)) + Space(01) +;
                    objCENFUNLGP:verCamNPR("BA1_TELEFO",substr(BA1->BA1_TELEFO,1,12)))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Posiciona no ultimo titulo para este contrato...                   Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      SE1->(DbSetOrder(cMvPLORDE1))
      SE1->(DbSeek(xFilial("SE1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)+"9999",.T.))
      SE1->(DbSkip(-1))
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Cabecalho dos titulos para este contrato...                        Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      aadd(aDados,STR0008)
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Busca os titulos que deverao ser impressos...                      Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      While SE1->( !Eof() .And. E1_FILIAL+E1_CODINT+E1_CODEMP+E1_MATRIC) == xFilial("SE1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
            //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	        //Ё Salta titulos referentes a abatimentos                              Ё
	        //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If  SE1->E1_TIPO $ MVABATIM
                SE1->(DbSkip(-1))
                Loop
            Endif
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Testa parametros...                                                Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If  lAberto .And. (SE1->E1_SALDO == 0 .Or. dtos(dDataBase) < dtos(SE1->E1_VENCTO))
                SE1->(DbSkip(-1))
                Loop
            Endif   
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Monta dados to titulo...                                           Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            aadd(aSE1,SE1->(RecNo()))
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Acumula dados...                                                   Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            nCont  ++
            nSaldo += SE1->E1_SALDO
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se considera numero de parcelas                           Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If  nConsid == 1
                lDados := .T.
                If  nCont == nQtdPar
                    Exit
                Endif
            Endif   
            //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
            //Ё Verifica se considera dias de atraso                               Ё
            //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
            If  nConsid == 2 .and. (dDataBase - SE1->E1_VENCTO) >= nDias
                lDados := .T.
            Endif
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Acessa titulo anterior...                                          Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      SE1->(DbSkip(-1))
      Enddo
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Monta dados to titulo...                                           Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      For i := 1 to len(aSE1)
          SE1->(dbGoTo(aSE1[i]))
          aadd(aDados,  objCENFUNLGP:verCamNPR("E1_MESBASE",SE1->E1_MESBASE)+"/"+;
                        objCENFUNLGP:verCamNPR("E1_ANOBASE",SE1->E1_ANOBASE)+Space(03)+;
                        objCENFUNLGP:verCamNPR("E1_VENCTO",dtoc(SE1->E1_VENCTO))+Space(03)+;
                        objCENFUNLGP:verCamNPR("E1_VALOR",TransForm(SE1->E1_VALOR,pMoeda))+Space(03)+;
                        objCENFUNLGP:verCamNPR("E1_SALDO",TransForm(SE1->E1_SALDO,pMoeda))+Space(04)+;
                        objCENFUNLGP:verCamNPR("E1_NUMBCO",SE1->E1_NUMBCO)+Space(04)+;
                        objCENFUNLGP:verCamNPR("E1_BAIXA",dtoc(SE1->E1_BAIXA))+Space(03)+;
                        objCENFUNLGP:verCamNPR("E1_VALLIQ",TransForm(SE1->E1_VALLIQ,pMoeda)))
      Next
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Testa se deve imprimir dados para este contrato...                 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      If lDados
         nLi ++
         @ nli, nColuna pSay aDados[1] // Cabecalho do Contrato (1)
         nLi ++
         @ nli, nColuna pSay aDados[2] // Cabecalho dos titulos
         nLi ++
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Titulos do Contrato...                                             Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         For nCont := 3 To Len(aDados)
             @ nLi, nColuna pSay aDados[nCont]
             nLi ++
         Next
         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
         //Ё Imprime totais do contrato...                                      Ё
         //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
         nQtdCon ++                                                                
         nSalCon += nSaldo
         @ nLi, nColuna pSay STR0009 + space(20) + TransForm(nSaldo,pMoeda)
         nLi ++
         @ nLi, nColuna pSay Replicate("-",nLimite)
      Endif   
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Controle para salto de paginas...                                  Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      R250Pag()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Acessa proximo registro...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(DbSkip())
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime totais gerais...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nQtdCon > 0
   nLi ++
   @ nLi, nColuna pSay STR0009 + space(15) + TransForm(nSalCon,"@E 999,999,999.99") + space(28) + STR0010 + transform(nQtdCon,"@E 99,999")
Endif   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprime rodade padrao do produto Microsiga                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
if !lAutoSt
   Roda(0,space(10),cTamanho)
endif
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera impressao                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(nRel)
End
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim do Relat╒rio                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠здддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma   Ё R250Pag  Ё Autor Ё   Tulio Cesar         Ё Data Ё 20.01.00 Ё╠╠
╠╠цдддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao  Ё Avanca Pagina caso necessario...                           Ё╠╠
╠╠юдддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
/*/
Static Function R250Pag()

If nLi > nQtdLin
   nLi       := 01
   if !lAutoSt
      nLi       := Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,cTamanho,nCaracter)
   endif
Endif


Return
