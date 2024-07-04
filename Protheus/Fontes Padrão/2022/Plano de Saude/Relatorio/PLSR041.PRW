#INCLUDE "PLSR041.ch"
#include "PROTHEUS.CH"

#define __cPictEsp "999999"
#define __cPictTot "9999999999"

Static lAutoSt := .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR041 ³ Autor ³ Tulio Cesar/Wagner Xavier ³ Data ³010604 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Relatorio de Metas de Vendas                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR041()                                                  ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Uso      ³ Advanced Protheus                                          ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Alteracoes desde sua construcao inicial                               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³ Data     ³ BOPS ³ Programador ³ Breve Descricao                       ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define nome da funcao                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function PLSR041(lAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lauto := lAutoSt

PRIVATE nQtdLin     := 58
PRIVATE cNomeProg   := "PLSR041"
PRIVATE Limite     := 220
PRIVATE Tamanho    := "G"
PRIVATE cTitulo     := STR0001 //"Relatorio de Metas de Vendas"
PRIVATE cDesc1      := STR0001 //"Relatorio de Metas de Vendas"
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "BXN"
PRIVATE cPerg       := "PLR041"
PRIVATE nRel        := "PLSR041"
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { STR0002, 1,STR0003, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE lAbortPrint := .F.
PRIVATE cCabec1     := STR0004+" "+STR0005+"/"+STR0006+" "+STR0007+"  "+STR0005+"/"+STR0008+" "+STR0009+"        "+STR0010+" "+STR0011+" "+STR0005+"/"+STR0012+"              "+STR0013+"     "+STR0014+"    "+STR0015+"    "+STR0016+"    "+STR0017+"    "+STR0018+"    "+STR0019+"    "+STR0020+"    "+STR0021+"    "+STR0022+"    "+STR0023+"    "+STR0024+"        "+STR0025+"        "+STR0026 //"Ope."###"Codigo"###"Descricao"###"Equipe"###"Codigo"###"Nome"###"Vendedor"###"Tipo de Plano"###"Tipo Incl."###"Codigo"###"Produto"###"Jan"###"Fev"###"Mar"###"Abr"###"Mai"###"Jun"###"Jul"###"Ago"###"Set"###"Out"###"Nov"###"Dez"###"Acu"###"Ano"
PRIVATE cCabec2     := ""
PRIVATE li          := 0

lAutoSt := lAuto
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lauto
   nRel := SetPrint(cAlias,nRel,cPerg,@cTitulo,cDesc1,cDesc2,cDesc3,lDicion,aOrderns,lCompres,Tamanho,{},lFiltro,lCrystal)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lauto .AND. nLastKey  == 27
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lauto
   SetDefault(aReturn,cAlias)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if !lauto
   MsAguarde({|| R041Imp() }, cTitulo, "", .T.)
else
   R041Imp()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina principal...                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R041Imp  ³ Autor ³ Tulio Cesar           ³ Data ³ 01.06.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Relatorio de Metas de Vendas....                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Static Function R041Imp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cPerg       := "PLR041"
LOCAL cSQL
LOCAL cLinha
LOCAL nQAcuAno    := 0
LOCAL nQAcuPer    := 0
LOCAL nRAcuAno    := 0
LOCAL nRAcuPer    := 0
LOCAL nPos
LOCAL nColuna     := 0

LOCAL aTotOpe     := {}
LOCAL aTotEquipe  := {}
LOCAL aTotVen     := {}
LOCAL aTotTP      := {}
LOCAL aTotTI      := {}
LOCAL aTotProd    := {}

LOCAL aEquipes    := {}
LOCAL aVends      := {}
LOCAL aProds      := {}
LOCAL aTipPla     := {}
LOCAL aTipInc     := {}

LOCAL cNomEquipe 
LOCAL cNomVend
LOCAL cNomProd
LOCAL cNomTipPla
LOCAL cNomTipInc

LOCAL cQuebOpe         
LOCAL nPosOpe
LOCAL cQuebEqu
LOCAL nPosEqu
LOCAL cQuebVen
LOCAL nPosVen
LOCAL cQuebTP
LOCAL nPosTP
LOCAL cQuebTI
LOCAL nPosTI
LOCAL cQuebPROD
LOCAL nPosPROD

LOCAL nFor

LOCAL cCodOpe
LOCAL cAno
LOCAL cEquiDe
LOCAL cEquiAte
LOCAL cCodVenDe
LOCAL cCodVenAte
LOCAL nTipPla
LOCAL cGruCDe
LOCAL cGruCAte
LOCAL cProdDe
LOCAL cProdAte
LOCAL cMesBase     
LOCAL lRealizado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca perguntas....                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)

cCodOpe    := mv_par01
cAno       := mv_par02
cEquiDe    := mv_par03
cEquiAte   := mv_par04
cCodVenDe  := mv_par05
cCodVenAte := mv_par06
nTipPla    := mv_par07
cProdDe    := mv_par08
cProdAte   := mv_par09
cMesBase   := mv_par10
lRealizado := (mv_par11 == 1)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query para acesso ao banco de dados...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT * FROM "+RetSQLName("BXN")+" WHERE "
cSQL += "BXN_FILIAL = '"+xFilial("BXN")+"' AND "
cSQL += "BXN_CODINT = '"+cCodOpe+"' AND "
cSQL += "BXN_ANO    = '"+cAno+"' AND "
cSQL += "( BXN_CODEQU >= '"+cEquiDe+"' AND BXN_CODEQU <= '"+cEquiaTE+"' ) AND "
cSQL += "( BXN_CODVEN >= '"+cCodVenDe+"' AND BXN_CODVEN <= '"+cCodVenAte+"' ) AND "

If     nTipPla == 1 //Somente PF
       cSQL += "BXN_TIPPLA = '1' AND "
ElseIf nTipPla == 2 //Somente PJ
       cSQL += "BXN_TIPPLA = '2' AND "   
Else
       //ambos, nao precisa filtar...
Endif       

cSQL += "( BXN_CODPRO >= '"+cProdDe+"' AND BXN_CODPRO <= '"+cProdAte+"' ) AND "
cSQL += "BXN_TIPO <> '2' AND "
cSQL += "D_E_L_E_T_ = ' '"
cSQL += "ORDER BY BXN_FILIAL,BXN_CODINT,BXN_CODEQU,BXN_CODVEN,BXN_TIPPLA,BXN_TIPINC,BXN_CODPRO"

PLSQuery(cSQL,"Trb041")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Veririca se houve registros selecionados...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. Trb041->(Eof())
   Trb041->(DbCloseArea())
   Help("",1,"RECNO")
   Return
Endif         

cQuebOpe := Trb041->BXN_CODINT
cQuebEqu := Trb041->BXN_CODEQU
cQuebVen := Trb041->BXN_CODVEN
cQuebTP  := Trb041->BXN_TIPPLA
cQuebTI  := Trb041->BXN_TIPINC
cQuebPROD:= Trb041->BXN_CODPRO

if !lAutoSt
   Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,Tamanho)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da leitura dos dados selecionados...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
While ! Trb041->(Eof())
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Zera variaveis de totais por ano e no periodo (qtd e realizado)...       ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nQAcuAno := 0
      nQAcuPer := 0
      nRAcuAno := 0
      nRAcuPer := 0
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula os valores no periodo...                                         ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      For nFor := 1 To Val(cMesBase)
          nQAcuPer += &("Trb041->BXN_Q"+StrZero(nFor,2))
          nRAcuPer += &("Trb041->BXN_R"+StrZero(nFor,2))
      Next
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula os valores totais do ano...                                      ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nQAcuAno := nQAcuPer
      nRAcuAno := nRAcuPer
      
      For nFor := Val(cMesBase) To 12    
          nQAcuAno += &("Trb041->BXN_Q"+StrZero(nFor,2))
          nRAcuAno += &("Trb041->BXN_R"+StrZero(nFor,2))
      Next
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Monta a descricao da equipe...                                           ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPos := Ascan(aEquipes,Trb041->BXN_CODEQU)
      
      If nPos == 0
         BXL->(DbSetOrder(1))
         If BXL->(DbSeek(xFilial("BXL")+Trb041->BXN_CODEQU))
            cNomEquipe := Subs(BXL->BXL_DESEQU,1,20)
         Else
            cNomEquipe := Space(20)
         Endif
         aadd(aEquipes,cNomEquipe)    
      Else
         cNomEquipe := aEquipes[nPos]
      Endif         
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Monta a descricao do vendedor...                                         ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPos := Ascan(aVends,Trb041->BXN_CODVEN)
      
      If nPos == 0
         SA3->(DbSetOrder(1))
         If SA3->(DbSeek(xFilial("SA3")+Trb041->BXN_CODVEN))
            cNomVend := Subs(SA3->A3_NOME,1,20)
         Else
            cNomVend := Space(20)
         Endif
         aadd(aVends,cNomVend)    
      Else
         cNomVend := aVends[nPos]
      Endif         
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Monta a descricao do produto...                                          ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPos := Ascan(aProds,Trb041->BXN_CODPRO)
      
      If nPos == 0
         BI3->(DbSetOrder(1))
         If BI3->(DbSeek(xFilial("BI3")+Trb041->(BXN_CODINT+BXN_CODPRO)))
            cNomProd := Subs(BI3->BI3_DESCRI,1,20)
         Else
            cNomProd := Space(20)
         Endif
         aadd(aProds,cNomProd)    
      Else
         cNomProd := aProds[nPos]
      Endif         
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Monta a descricao do tipo de plano...                                    ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPos := Ascan(aTipPla,{ |x| x[1] == Trb041->BXN_TIPPLA} )
      
      If nPos == 0
         cNomTipPla := If(Trb041->BXN_TIPPLA=="1",STR0027,STR0028) //"Pessoa Fisica"###"Pessoa Jurid."
         aadd(aTipPla,{Trb041->BXN_TIPPLA,cNomTipPla})    
      Else
         cNomTipPla := aTipPla[nPos,2]
      Endif         
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Monta a descricao do tipo de inclusao...                                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPos := Ascan(aTipInc,{ |x| x[1] == Trb041->BXN_TIPINC} )
      
      If nPos == 0
         If     Trb041->BXN_TIPINC == "1"
                cNomTipInc := STR0029 //"Plano Novo"
         ElseIf Trb041->BXN_TIPINC == "2"
                cNomTipInc := STR0030+"    " //"Adesao"
         ElseIf Trb041->BXN_TIPINC == "3"
                cNomTipInc := STR0031 //"Dependente"
         ElseIf Trb041->BXN_TIPINC == "4"
                cNomTipInc := STR0032+" " //"Transfer."
         ElseIf Trb041->BXN_TIPINC == "5"
                cNomTipInc := STR0033+" " //"Adequacao"
         Else
                cNomTipInc := "          "
         Endif       
         aadd(aTipInc,{Trb041->BXN_TIPINC,cNomTipInc})    
      Else
         cNomTipInc := aTipInc[nPos,2]
      Endif         
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Adiciona no aLinha os dados do relatorio...                              ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      cLinha := Trb041->BXN_CODINT+Space(01)+;
                   Trb041->BXN_CODEQU+Space(01)+;
                   cNomEquipe+Space(01)+;
                   Trb041->BXN_CODVEN+Space(01)+;
                   cNomVend+Space(01)+;
                   cNomTipPla+Space(01)+;
                   cNomTipInc+Space(01)+;
                   Trb041->BXN_CODPRO+Space(01)+;
                   cNomProd+Space(01)+;
                   TransForm(Trb041->BXN_Q01,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q02,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q03,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q04,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q05,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q06,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q07,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q08,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q09,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q10,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q11,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_Q12,__cPictEsp)+Space(01)+;
                   TransForm(nQAcuPer,__cPictTot)+Space(01)+;
                   TransForm(nQAcuAno,__cPictTot)+Space(01)+" (M)"
                   
      @ Li++, nColuna pSay cLinha

      If lRealizado
         cLinha := Space(Len(Trb041->BXN_CODINT))+Space(01)+;
                   Space(Len(Trb041->BXN_CODEQU))+Space(01)+;
                   Space(Len(cNomEquipe))+Space(01)+;
                   Space(Len(Trb041->BXN_CODVEN))+Space(01)+;
                   Space(Len(cNomVend))+Space(01)+;
                   Space(Len(cNomTipPla))+Space(01)+;
                   Space(Len(cNomTipInc))+Space(01)+;
                   Space(Len(Trb041->BXN_CODPRO))+Space(01)+;
                   Space(Len(cNomProd))+Space(01)+;
                   TransForm(Trb041->BXN_R01,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R02,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R03,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R04,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R05,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R06,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R07,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R08,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R09,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R10,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R11,__cPictEsp)+Space(01)+;
                   TransForm(Trb041->BXN_R12,__cPictEsp)+Space(01)+;
                   TransForm(nRAcuPer,__cPictTot)+Space(01)+;
                   TransForm(nRAcuAno,__cPictTot)+Space(01)+" (R)"
                   
         @ Li++, nColuna pSay cLinha
      Endif   
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula totais da quebra por operadora...                                ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPosOpe := Ascan(aTotOpe,{|x| x[1] == Trb041->BXN_CODINT})
      
      If nPosOpe == 0
         aadd(aTotOpe,{Trb041->BXN_CODINT,;
                        Trb041->BXN_Q01,;
                        Trb041->BXN_Q02,;
                        Trb041->BXN_Q03,;
                        Trb041->BXN_Q04,;
                        Trb041->BXN_Q05,;
                        Trb041->BXN_Q06,;
                        Trb041->BXN_Q07,;
                        Trb041->BXN_Q08,;
                        Trb041->BXN_Q09,;
                        Trb041->BXN_Q10,;
                        Trb041->BXN_Q11,;
                        Trb041->BXN_Q12,;
                        nQAcuPer,;
                        nQAcuAno,;
                        Trb041->BXN_R01,;
                        Trb041->BXN_R02,;
                        Trb041->BXN_R03,;
                        Trb041->BXN_R04,;
                        Trb041->BXN_R05,;
                        Trb041->BXN_R06,;
                        Trb041->BXN_R07,;
                        Trb041->BXN_R08,;
                        Trb041->BXN_R09,;
                        Trb041->BXN_R10,;
                        Trb041->BXN_R11,;
                        Trb041->BXN_R12,;
                        nRAcuPer,;
                        nRAcuAno})
         nPosOpe := Len(aTotOpe)               
      Else            
         aTotOpe[nPosOpe,2]  += Trb041->BXN_Q01
         aTotOpe[nPosOpe,3]  += Trb041->BXN_Q02
         aTotOpe[nPosOpe,4]  += Trb041->BXN_Q03
         aTotOpe[nPosOpe,5]  += Trb041->BXN_Q04
         aTotOpe[nPosOpe,6]  += Trb041->BXN_Q05
         aTotOpe[nPosOpe,7]  += Trb041->BXN_Q06
         aTotOpe[nPosOpe,8]  += Trb041->BXN_Q07
         aTotOpe[nPosOpe,9]  += Trb041->BXN_Q08
         aTotOpe[nPosOpe,10] += Trb041->BXN_Q09
         aTotOpe[nPosOpe,11] += Trb041->BXN_Q10
         aTotOpe[nPosOpe,12] += Trb041->BXN_Q11
         aTotOpe[nPosOpe,13] += Trb041->BXN_Q12
         aTotOpe[nPosOpe,14] += nQAcuPer
         aTotOpe[nPosOpe,15] += nQAcuAno
         aTotOpe[nPosOpe,16] += Trb041->BXN_R01
         aTotOpe[nPosOpe,17] += Trb041->BXN_R02
         aTotOpe[nPosOpe,18] += Trb041->BXN_R03
         aTotOpe[nPosOpe,19] += Trb041->BXN_R04
         aTotOpe[nPosOpe,20] += Trb041->BXN_R05
         aTotOpe[nPosOpe,21] += Trb041->BXN_R06
         aTotOpe[nPosOpe,22] += Trb041->BXN_R07
         aTotOpe[nPosOpe,23] += Trb041->BXN_R08
         aTotOpe[nPosOpe,24] += Trb041->BXN_R09
         aTotOpe[nPosOpe,25] += Trb041->BXN_R10
         aTotOpe[nPosOpe,26] += Trb041->BXN_R11
         aTotOpe[nPosOpe,27] += Trb041->BXN_R12
         aTotOpe[nPosOpe,28] += nRAcuPer
         aTotOpe[nPosOpe,29] += nRAcuAno
     Endif    
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula totais da quebra por equipe...                                   ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPosEqu := Ascan(aTotEquipe,{|x| x[1] == Trb041->BXN_CODEQU})
      
      If nPosEqu == 0
         aadd(aTotEquipe,{Trb041->BXN_CODEQU,;
                          Trb041->BXN_Q01,;
                          Trb041->BXN_Q02,;
                          Trb041->BXN_Q03,;
                          Trb041->BXN_Q04,;
                          Trb041->BXN_Q05,;
                          Trb041->BXN_Q06,;
                          Trb041->BXN_Q07,;
                          Trb041->BXN_Q08,;
                          Trb041->BXN_Q09,;
                          Trb041->BXN_Q10,;
                          Trb041->BXN_Q11,;
                          Trb041->BXN_Q12,;
                          nQAcuPer,;
                          nQAcuAno,;
                          Trb041->BXN_R01,;
                          Trb041->BXN_R02,;
                          Trb041->BXN_R03,;
                          Trb041->BXN_R04,;
                          Trb041->BXN_R05,;
                          Trb041->BXN_R06,;
                          Trb041->BXN_R07,;
                          Trb041->BXN_R08,;
                          Trb041->BXN_R09,;
                          Trb041->BXN_R10,;
                          Trb041->BXN_R11,;
                          Trb041->BXN_R12,;
                          nRAcuPer,;
                          nRAcuAno})
         nPosEqu := Len(aTotEquipe)                               
      Else            
         aTotEquipe[nPosEqu,2]  += Trb041->BXN_Q01
         aTotEquipe[nPosEqu,3]  += Trb041->BXN_Q02
         aTotEquipe[nPosEqu,4]  += Trb041->BXN_Q03
         aTotEquipe[nPosEqu,5]  += Trb041->BXN_Q04
         aTotEquipe[nPosEqu,6]  += Trb041->BXN_Q05
         aTotEquipe[nPosEqu,7]  += Trb041->BXN_Q06
         aTotEquipe[nPosEqu,8]  += Trb041->BXN_Q07
         aTotEquipe[nPosEqu,9]  += Trb041->BXN_Q08
         aTotEquipe[nPosEqu,10] += Trb041->BXN_Q09
         aTotEquipe[nPosEqu,11] += Trb041->BXN_Q10
         aTotEquipe[nPosEqu,12] += Trb041->BXN_Q11
         aTotEquipe[nPosEqu,13] += Trb041->BXN_Q12
         aTotEquipe[nPosEqu,14] += nQAcuPer
         aTotEquipe[nPosEqu,15] += nQAcuAno
         aTotEquipe[nPosEqu,16] += Trb041->BXN_R01
         aTotEquipe[nPosEqu,17] += Trb041->BXN_R02
         aTotEquipe[nPosEqu,18] += Trb041->BXN_R03
         aTotEquipe[nPosEqu,19] += Trb041->BXN_R04
         aTotEquipe[nPosEqu,20] += Trb041->BXN_R05
         aTotEquipe[nPosEqu,21] += Trb041->BXN_R06
         aTotEquipe[nPosEqu,22] += Trb041->BXN_R07
         aTotEquipe[nPosEqu,23] += Trb041->BXN_R08
         aTotEquipe[nPosEqu,24] += Trb041->BXN_R09
         aTotEquipe[nPosEqu,25] += Trb041->BXN_R10
         aTotEquipe[nPosEqu,26] += Trb041->BXN_R11
         aTotEquipe[nPosEqu,27] += Trb041->BXN_R12
         aTotEquipe[nPosEqu,28] += nRAcuPer
         aTotEquipe[nPosEqu,29] += nRAcuAno
     Endif    
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula totais da quebra por vendedor...                                 ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPosVen := Ascan(aTotVen,{|x| x[1] == Trb041->BXN_CODVEN})
      
      If nPosVen == 0
         aadd(aTotVen,{Trb041->BXN_CODVEN,;
                          Trb041->BXN_Q01,;
                          Trb041->BXN_Q02,;
                          Trb041->BXN_Q03,;
                          Trb041->BXN_Q04,;
                          Trb041->BXN_Q05,;
                          Trb041->BXN_Q06,;
                          Trb041->BXN_Q07,;
                          Trb041->BXN_Q08,;
                          Trb041->BXN_Q09,;
                          Trb041->BXN_Q10,;
                          Trb041->BXN_Q11,;
                          Trb041->BXN_Q12,;
                          nQAcuPer,;
                          nQAcuAno,;
                          Trb041->BXN_R01,;
                          Trb041->BXN_R02,;
                          Trb041->BXN_R03,;
                          Trb041->BXN_R04,;
                          Trb041->BXN_R05,;
                          Trb041->BXN_R06,;
                          Trb041->BXN_R07,;
                          Trb041->BXN_R08,;
                          Trb041->BXN_R09,;
                          Trb041->BXN_R10,;
                          Trb041->BXN_R11,;
                          Trb041->BXN_R12,;
                          nRAcuPer,;
                          nRAcuAno})
         nPosVen := Len(aTotVen)                               
      Else            
         aTotVen[nPosVen,2]  += Trb041->BXN_Q01
         aTotVen[nPosVen,3]  += Trb041->BXN_Q02
         aTotVen[nPosVen,4]  += Trb041->BXN_Q03
         aTotVen[nPosVen,5]  += Trb041->BXN_Q04
         aTotVen[nPosVen,6]  += Trb041->BXN_Q05
         aTotVen[nPosVen,7]  += Trb041->BXN_Q06
         aTotVen[nPosVen,8]  += Trb041->BXN_Q07
         aTotVen[nPosVen,9]  += Trb041->BXN_Q08
         aTotVen[nPosVen,10] += Trb041->BXN_Q09
         aTotVen[nPosVen,11] += Trb041->BXN_Q10
         aTotVen[nPosVen,12] += Trb041->BXN_Q11
         aTotVen[nPosVen,13] += Trb041->BXN_Q12
         aTotVen[nPosVen,14] += nQAcuPer
         aTotVen[nPosVen,15] += nQAcuAno
         aTotVen[nPosVen,16] += Trb041->BXN_R01
         aTotVen[nPosVen,17] += Trb041->BXN_R02
         aTotVen[nPosVen,18] += Trb041->BXN_R03
         aTotVen[nPosVen,19] += Trb041->BXN_R04
         aTotVen[nPosVen,20] += Trb041->BXN_R05
         aTotVen[nPosVen,21] += Trb041->BXN_R06
         aTotVen[nPosVen,22] += Trb041->BXN_R07
         aTotVen[nPosVen,23] += Trb041->BXN_R08
         aTotVen[nPosVen,24] += Trb041->BXN_R09
         aTotVen[nPosVen,25] += Trb041->BXN_R10
         aTotVen[nPosVen,26] += Trb041->BXN_R11
         aTotVen[nPosVen,27] += Trb041->BXN_R12
         aTotVen[nPosVen,28] += nRAcuPer
         aTotVen[nPosVen,29] += nRAcuAno
     Endif    
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula totais da quebra por TIPO DE PLANO...                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPosTP := Ascan(aTotTP,{|x| x[1] == Trb041->BXN_TIPPLA})
      
      If nPosTP == 0
         aadd(aTotTP,{Trb041->BXN_TIPPLA,;
                      Trb041->BXN_Q01,;
                      Trb041->BXN_Q02,;
                      Trb041->BXN_Q03,;
                      Trb041->BXN_Q04,;
                      Trb041->BXN_Q05,;
                      Trb041->BXN_Q06,;
                      Trb041->BXN_Q07,;
                      Trb041->BXN_Q08,;
                      Trb041->BXN_Q09,;
                      Trb041->BXN_Q10,;
                      Trb041->BXN_Q11,;
                      Trb041->BXN_Q12,;
                      nQAcuPer,;
                      nQAcuAno,;
                      Trb041->BXN_R01,;
                      Trb041->BXN_R02,;
                      Trb041->BXN_R03,;
                      Trb041->BXN_R04,;
                      Trb041->BXN_R05,;
                      Trb041->BXN_R06,;
                      Trb041->BXN_R07,;
                      Trb041->BXN_R08,;
                      Trb041->BXN_R09,;
                      Trb041->BXN_R10,;
                      Trb041->BXN_R11,;
                      Trb041->BXN_R12,;
                      nRAcuPer,;
                      nRAcuAno})
         nPosTP := Len(aTotTP)                               
      Else            
         aTotTP[nPosTP,2]  += Trb041->BXN_Q01
         aTotTP[nPosTP,3]  += Trb041->BXN_Q02
         aTotTP[nPosTP,4]  += Trb041->BXN_Q03
         aTotTP[nPosTP,5]  += Trb041->BXN_Q04
         aTotTP[nPosTP,6]  += Trb041->BXN_Q05
         aTotTP[nPosTP,7]  += Trb041->BXN_Q06
         aTotTP[nPosTP,8]  += Trb041->BXN_Q07
         aTotTP[nPosTP,9]  += Trb041->BXN_Q08
         aTotTP[nPosTP,10] += Trb041->BXN_Q09
         aTotTP[nPosTP,11] += Trb041->BXN_Q10
         aTotTP[nPosTP,12] += Trb041->BXN_Q11
         aTotTP[nPosTP,13] += Trb041->BXN_Q12
         aTotTP[nPosTP,14] += nQAcuPer
         aTotTP[nPosTP,15] += nQAcuAno
         aTotTP[nPosTP,16] += Trb041->BXN_R01
         aTotTP[nPosTP,17] += Trb041->BXN_R02
         aTotTP[nPosTP,18] += Trb041->BXN_R03
         aTotTP[nPosTP,19] += Trb041->BXN_R04
         aTotTP[nPosTP,20] += Trb041->BXN_R05
         aTotTP[nPosTP,21] += Trb041->BXN_R06
         aTotTP[nPosTP,22] += Trb041->BXN_R07
         aTotTP[nPosTP,23] += Trb041->BXN_R08
         aTotTP[nPosTP,24] += Trb041->BXN_R09
         aTotTP[nPosTP,25] += Trb041->BXN_R10
         aTotTP[nPosTP,26] += Trb041->BXN_R11
         aTotVen[nPosTP,27] += Trb041->BXN_R12
         aTotVen[nPosTP,28] += nRAcuPer
         aTotVen[nPosTP,29] += nRAcuAno
     Endif    
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula totais da quebra por TIPO DE INCLUSAO..                          ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPosTI := Ascan(aTotTI,{|x| x[1] == Trb041->BXN_TIPINC})
      
      If nPosTI == 0
         aadd(aTotTI,{Trb041->BXN_TIPINC,;
                      Trb041->BXN_Q01,;
                      Trb041->BXN_Q02,;
                      Trb041->BXN_Q03,;
                      Trb041->BXN_Q04,;
                      Trb041->BXN_Q05,;
                      Trb041->BXN_Q06,;
                      Trb041->BXN_Q07,;
                      Trb041->BXN_Q08,;
                      Trb041->BXN_Q09,;
                      Trb041->BXN_Q10,;
                      Trb041->BXN_Q11,;
                      Trb041->BXN_Q12,;
                      nQAcuPer,;
                      nQAcuAno,;
                      Trb041->BXN_R01,;
                      Trb041->BXN_R02,;
                      Trb041->BXN_R03,;
                      Trb041->BXN_R04,;
                      Trb041->BXN_R05,;
                      Trb041->BXN_R06,;
                      Trb041->BXN_R07,;
                      Trb041->BXN_R08,;
                      Trb041->BXN_R09,;
                      Trb041->BXN_R10,;
                      Trb041->BXN_R11,;
                      Trb041->BXN_R12,;
                      nRAcuPer,;
                      nRAcuAno})
         nPosTI := Len(aTotTI)             
      Else            
         aTotTI[nPosTI,2]  += Trb041->BXN_Q01
         aTotTI[nPosTI,3]  += Trb041->BXN_Q02
         aTotTI[nPosTI,4]  += Trb041->BXN_Q03
         aTotTI[nPosTI,5]  += Trb041->BXN_Q04
         aTotTI[nPosTI,6]  += Trb041->BXN_Q05
         aTotTI[nPosTI,7]  += Trb041->BXN_Q06
         aTotTI[nPosTI,8]  += Trb041->BXN_Q07
         aTotTI[nPosTI,9]  += Trb041->BXN_Q08
         aTotTI[nPosTI,10] += Trb041->BXN_Q09
         aTotTI[nPosTI,11] += Trb041->BXN_Q10
         aTotTI[nPosTI,12] += Trb041->BXN_Q11
         aTotTI[nPosTI,13] += Trb041->BXN_Q12
         aTotTI[nPosTI,14] += nQAcuPer
         aTotTI[nPosTI,15] += nQAcuAno
         aTotTI[nPosTI,16] += Trb041->BXN_R01
         aTotTI[nPosTI,17] += Trb041->BXN_R02
         aTotTI[nPosTI,18] += Trb041->BXN_R03
         aTotTI[nPosTI,19] += Trb041->BXN_R04
         aTotTI[nPosTI,20] += Trb041->BXN_R05
         aTotTI[nPosTI,21] += Trb041->BXN_R06
         aTotTI[nPosTI,22] += Trb041->BXN_R07
         aTotTI[nPosTI,23] += Trb041->BXN_R08
         aTotTI[nPosTI,24] += Trb041->BXN_R09
         aTotTI[nPosTI,25] += Trb041->BXN_R10
         aTotTI[nPosTI,26] += Trb041->BXN_R11
         aTotTI[nPosTI,27] += Trb041->BXN_R12
         aTotTI[nPosTI,28] += nRAcuPer
         aTotTI[nPosTI,29] += nRAcuAno
     Endif    
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Acumula totais da quebra por PRODUTO...                                  ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      nPosProd := Ascan(aTotProd,{|x| x[1] == Trb041->BXN_CODPRO})
      
      If nPosProd == 0
         aadd(aTotProd,{Trb041->BXN_CODPRO,;
                      Trb041->BXN_Q01,;
                      Trb041->BXN_Q02,;
                      Trb041->BXN_Q03,;
                      Trb041->BXN_Q04,;
                      Trb041->BXN_Q05,;
                      Trb041->BXN_Q06,;
                      Trb041->BXN_Q07,;
                      Trb041->BXN_Q08,;
                      Trb041->BXN_Q09,;
                      Trb041->BXN_Q10,;
                      Trb041->BXN_Q11,;
                      Trb041->BXN_Q12,;
                      nQAcuPer,;
                      nQAcuAno,;
                      Trb041->BXN_R01,;
                      Trb041->BXN_R02,;
                      Trb041->BXN_R03,;
                      Trb041->BXN_R04,;
                      Trb041->BXN_R05,;
                      Trb041->BXN_R06,;
                      Trb041->BXN_R07,;
                      Trb041->BXN_R08,;
                      Trb041->BXN_R09,;
                      Trb041->BXN_R10,;
                      Trb041->BXN_R11,;
                      Trb041->BXN_R12,;
                      nRAcuPer,;
                      nRAcuAno})
         nPosProd := Len(aTotProd)             
      Else            
         aTotProd[nPosProd,2]  += Trb041->BXN_Q01
         aTotProd[nPosProd,3]  += Trb041->BXN_Q02
         aTotProd[nPosProd,4]  += Trb041->BXN_Q03
         aTotProd[nPosProd,5]  += Trb041->BXN_Q04
         aTotProd[nPosProd,6]  += Trb041->BXN_Q05
         aTotProd[nPosProd,7]  += Trb041->BXN_Q06
         aTotProd[nPosProd,8]  += Trb041->BXN_Q07
         aTotProd[nPosProd,9]  += Trb041->BXN_Q08
         aTotProd[nPosProd,10] += Trb041->BXN_Q09
         aTotProd[nPosProd,11] += Trb041->BXN_Q10
         aTotProd[nPosProd,12] += Trb041->BXN_Q11
         aTotProd[nPosProd,13] += Trb041->BXN_Q12
         aTotProd[nPosProd,14] += nQAcuPer
         aTotProd[nPosProd,15] += nQAcuAno
         aTotProd[nPosProd,16] += Trb041->BXN_R01
         aTotProd[nPosProd,17] += Trb041->BXN_R02
         aTotProd[nPosProd,18] += Trb041->BXN_R03
         aTotProd[nPosProd,19] += Trb041->BXN_R04
         aTotProd[nPosProd,20] += Trb041->BXN_R05
         aTotProd[nPosProd,21] += Trb041->BXN_R06
         aTotProd[nPosProd,22] += Trb041->BXN_R07
         aTotProd[nPosProd,23] += Trb041->BXN_R08
         aTotProd[nPosProd,24] += Trb041->BXN_R09
         aTotProd[nPosProd,25] += Trb041->BXN_R10
         aTotProd[nPosProd,26] += Trb041->BXN_R11
         aTotProd[nPosProd,27] += Trb041->BXN_R12
         aTotProd[nPosProd,28] += nRAcuPer
         aTotProd[nPosProd,29] += nRAcuAno
     Endif    
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ Acessa proximo registro...                                               ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Trb041->(DbSkip())
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ lista totais da quebra por PRODUTO...                                    ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If cQuebProd <> Trb041->BXN_CODPRO
        cQuebProd := Trb041->BXN_CODPRO
        cLinha := Space(83)+STR0034+" "+Space(12)+; //"Total Produto"
                     TransForm(aTotProd[nPosProd,2],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,3],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,4],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,5],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,6],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,7],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,8],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,9],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,10],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,11],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,12],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,13],__cPictEsp)+Space(01)+;
                     TransForm(aTotProd[nPosProd,14],__cPictTot)+Space(01)+;
                     TransForm(aTotProd[nPosProd,15],__cPictTot)+Space(01)+" (M)"
        @ Li ++, nColuna pSay cLinha             

        If lRealizado
           cLinha :=         Space(83)+"              "+Space(12)+;
                        TransForm(aTotProd[nPosProd,16],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,17],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,18],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,19],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,20],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,21],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,22],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,23],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,24],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,25],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,26],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,27],__cPictEsp)+Space(01)+;
                        TransForm(aTotProd[nPosProd,28],__cPictTot)+Space(01)+;
                        TransForm(aTotProd[nPosProd,29],__cPictTot)+Space(01)+" (R)"
           @ Li++, nColuna pSay cLinha             
        Endif   
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ lista totais da quebra por tipo de INCLUSAO...                           ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If cQuebTI <> Trb041->BXN_TIPINC
        cQuebTI := Trb041->BXN_TIPINC
        cLinha :=         Space(72)+STR0035+"      "+Space(23)+; //"Total TI"
                     TransForm(aTotTI[nPosTI,2],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,3],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,4],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,5],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,6],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,7],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,8],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,9],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,10],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,11],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,12],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,13],__cPictEsp)+Space(01)+;
                     TransForm(aTotTI[nPosTI,14],__cPictTot)+Space(01)+;
                     TransForm(aTotTI[nPosTI,15],__cPictTot)+Space(01)+" (M)"
         @ Li++, nColuna pSay cLinha            
         
         If lRealizado
            cLinha := Space(72)+"              "+Space(23)+;
                        TransForm(aTotTI[nPosTI,16],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,17],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,18],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,19],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,20],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,21],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,22],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,23],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,24],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,25],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,26],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,27],__cPictEsp)+Space(01)+;
                        TransForm(aTotTI[nPosTI,28],__cPictTot)+Space(01)+;
                        TransForm(aTotTI[nPosTI,29],__cPictTot)+Space(01)+" (R)"
             @ Li++, nColuna pSay cLinha           
          Endif   
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ lista totais da quebra por tipo de plano...                              ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If cQuebTP <> Trb041->BXN_TIPPLA 
        cQuebTP := Trb041->BXN_TIPPLA
        cLinha := Space(58)+STR0036+Space(37)+; //"Total Tp Plano"
                     TransForm(aTotTP[nPosTP,2],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,3],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,4],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,5],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,6],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,7],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,8],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,9],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,10],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,11],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,12],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,13],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,14],__cPictTot)+Space(01)+;
                     TransForm(aTotTP[nPosTP,15],__cPictTot)+Space(01)+" (M)"
        @ Li++, nColuna pSay cLinha

        If lRealizado
           cLinha := Space(58)+"              "+Space(37)+;
                     TransForm(aTotTP[nPosTP,16],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,17],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,18],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,19],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,20],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,21],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,22],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,23],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,24],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,25],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,26],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,27],__cPictEsp)+Space(01)+;
                     TransForm(aTotTP[nPosTP,28],__cPictTot)+Space(01)+;
                     TransForm(aTotTP[nPosTP,29],__cPictTot)+Space(01)+" (R)"
          @ Li++, nColuna  pSay cLinha            
       Endif   
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ lista totais da quebra por Vendedor                                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If cQuebVen <> Trb041->BXN_CODVEN 
        cQuebVen := Trb041->BXN_CODVEN
        cLinha := Space(30)+STR0037+Space(65)+; //"Total Vendedor"
                     TransForm(aTotVen[nPosVen,2],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,3],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,4],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,5],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,6],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,7],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,8],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,9],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,10],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,11],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,12],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,13],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,14],__cPictTot)+Space(01)+;
                     TransForm(aTotVen[nPosVen,15],__cPictTot)+Space(01)+" (M)"
        @ Li++, nColuna pSay cLinha             
        
        If lRealizado
           cLinha := Space(30)+"              "+Space(65)+;
                     TransForm(aTotVen[nPosVen,16],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,17],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,18],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,19],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,20],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,21],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,22],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,23],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,24],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,25],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,26],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,27],__cPictEsp)+Space(01)+;
                     TransForm(aTotVen[nPosVen,28],__cPictTot)+Space(01)+;
                     TransForm(aTotVen[nPosVen,29],__cPictTot)+Space(01)+" (R)"
            @ Li++, nColuna pSay cLinha            
        Endif    
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ lista totais da quebra por equipe...                                     ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If cQuebEqu <> Trb041->BXN_CODEQU 
        cQuebEqu := Trb041->BXN_CODEQU
        cLinha := Space(05)+STR0038+"  "+Space(90)+; //"Total Equipe"
                     TransForm(aTotEquipe[nPosEqu,2],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,3],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,4],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,5],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,6],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,7],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,8],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,9],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,10],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,11],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,12],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,13],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,14],__cPictTot)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,15],__cPictTot)+Space(01)+" (M)"
        @ Li++, nColuna pSay cLinha             

        If lRealizado
           cLinha := Space(05)+"              "+Space(90)+;
                     TransForm(aTotEquipe[nPosEqu,16],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,17],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,18],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,19],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,20],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,21],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,22],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,23],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,24],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,25],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,26],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,27],__cPictEsp)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,28],__cPictTot)+Space(01)+;
                     TransForm(aTotEquipe[nPosEqu,29],__cPictTot)+Space(01)+" (R)"
           @ Li++, nColuna pSay cLinha             
        Endif   
     Endif
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³ lista totais da quebra por operadora...                                  ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     If cQuebOpe <> Trb041->BXN_CODINT 
        cQuebOpe := Trb041->BXN_CODINT
        cLinha := STR0039+Space(94)+; //"Total Operadora"
                     TransForm(aTotOpe[nPosOpe,2],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,3],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,4],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,5],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,6],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,7],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,8],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,9],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,10],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,11],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,12],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,13],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,14],__cPictTot)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,15],__cPictTot)+Space(01)+" (M)"
        @ Li++, nColuna pSay cLinha             

        If lRealizado
           cLinha := "               "+Space(94)+;
                     TransForm(aTotOpe[nPosOpe,16],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,17],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,18],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,19],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,20],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,21],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,22],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,23],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,24],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,25],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,26],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,27],__cPictEsp)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,28],__cPictTot)+Space(01)+;
                     TransForm(aTotOpe[nPosOpe,29],__cPictTot)+Space(01)+" (R)"
           @ Li++, nColuna pSay cLinha            
        Endif   
     Endif

	If !lAutoSt .AND. Li > nQtdLin
		Cabec(cTitulo,cCabec1,cCabec2,cNomeProg,Tamanho)
	Endif

Enddo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha area de trabalho...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Trb041->(DbCloseArea())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama spoll...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. aReturn[5] == 1
    Set Printer To
    Ourspool(nRel)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim do Relat¢rio                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Return
