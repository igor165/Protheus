#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR196 ³ Autor ³ Sandro Hoffman Lopes   ³ Data ³ 10.01.06 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Lista Relatorio de Inadimplencia por Periodo               ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR196()                                                  ³±±±
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
*/
Function PLSR196

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de Inadimplencia por Periodo."
Local cDesc3        := ""
Local cPict         := ""
Local titulo        := "RELACAO DE INADIMPLENCIA POR PERIODO"
Local nLin          := 80
Local Cabec1        := "CODIGO DA  COD DA MATRICULA  COD MATR  NOME DO                                          DT VENCTO DA         VALOR DA  NUMERO DO"
Local Cabec2        := " EMPRESA   ANTIGA            ATUAL     USUARIO                                          MENSALIDADE       MENSALIDADE  CARNE"
Local imprime       := .T.
Local aOrd          := { }

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "PLSR196"
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "PLR196"
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "PLSR196"
Private lCompres    := .T.
Private lDicion     := .F.
Private lFiltro     := .F.
Private lCrystal    := .F.
Private cString     := "BA3"
Private nTotVid     := 0

Private cCodInt     := ""
Private cContaDe    := ""
Private cContaAte   := ""
Private cQualMatr   := ""
Private dVenctoDe   := ""
Private dVenctoAte  := ""
Private cCodEmpDe   := ""
Private cCodEmpAte  := ""
Private dDtBloqDe   := ""
Private dDtBloqAte  := ""
Private nLisUsuar   := 0

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=  SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,lDicion,aOrd,lCompres,Tamanho,{},lFiltro,lCrystal)

	aAlias := {"SE1","BA1","BI3"}
	objCENFUNLGP:setAlias(aAlias)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

cCodInt     := mv_par01
cContaDe    := mv_par02
cContaAte   := mv_par03
cQualMatr   := mv_par04
dVenctoDe   := mv_par05
dVenctoAte  := mv_par06
cCodEmpDe   := mv_par07
cCodEmpAte  := mv_par08
dDtBloqDe   := mv_par09
dDtBloqAte  := mv_par10
nLisUsuar   := mv_par11

Titulo      := AllTrim(Titulo) + " - " + DtoC(dDtBloqDe) + " A " + DtoC(dDtBloqAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsAguarde({|| R196Imp(Cabec1,Cabec2,Titulo,nLin) }, Titulo, "", .T.)

Roda(0,"","M")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If aReturn[5]==1
   dbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³R196Imp    ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 10/01/06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime relatorio para conferencia dos valores gerados no   ³±±
±±³          ³arquivo de pagamento da RDA.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R196Imp(Cabec1,Cabec2,Titulo,nLin)
       
   Local cBA1Name := RetSQLName("BA1")
   Local cBA3Name := RetSQLName("BA3")
   Local cBI3Name := RetSQLName("BI3")
   Local cSE1Name := RetSQLName("SE1")
   Local aSaldo   := { 0, 0 }
   Local cDescCta := ""
   Local cConta
   Local cSQL
   Local lPLR196BP := ExistBlock("PLR196BP")

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Exibe mensagem...                                                        ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   MsProcTxt(PLSTR0001)
   ProcessMessages()
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Faz filtro no arquivo...                                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cSQL := " SELECT BI3_CONTA, BA1_CODEMP, BA1_MATRIC, BA1_MATANT, BA1_NOMUSR, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VENCTO, E1_SALDO, " + cSE1Name +  ".R_E_C_N_O_ RECSE1 "
   cSQL += " FROM " + cBA1Name 
   cSQL += " LEFT OUTER JOIN " + cBA3Name
   cSQL += " ON BA3_FILIAL = '" + xFilial("BA3") + "' AND   "
   cSQL += "    BA3_CODINT = BA1_CODINT AND "
   cSQL += "    BA3_CODEMP = BA1_CODEMP AND "
   cSQL += "    BA3_MATRIC = BA1_MATRIC AND "
   cSQL += "    BA3_CONEMP = BA1_CONEMP AND "
   cSQL += "    BA3_VERCON = BA1_VERCON AND "
   cSQL += "    BA3_SUBCON = BA1_SUBCON AND "
   cSQL += "    BA3_VERSUB = BA1_VERSUB AND "
   cSQL += "    BA3_COBNIV = '1' AND "
   cSQL += "    " + cBA3Name + ".D_E_L_E_T_ <> '*' "
   cSQL += " LEFT OUTER JOIN " + cBI3Name
   cSQL += " ON BI3_FILIAL = '" + xFilial("BI3") + "' AND   "
   cSQL += "    BI3_CODINT = BA1_CODINT AND "
   cSQL += "    BI3_CODIGO = CASE BA1_CODPLA WHEN '' THEN BA3_CODPLA ELSE BA1_CODPLA END AND "
   cSQL += "    BI3_VERSAO = CASE BA1_VERSAO WHEN '' THEN BA3_VERSAO ELSE BA1_VERSAO END AND "
   cSQL += "    " + cBI3Name + ".D_E_L_E_T_ <> '*' "
   cSQL += " LEFT OUTER JOIN " + cSE1Name
   cSQL += " ON E1_FILIAL = '" + xFilial("SE1") + "' AND   "
   cSQL += "    E1_CODINT = BA1_CODINT AND "
   cSQL += "    E1_CODEMP = BA1_CODEMP AND "
   cSQL += "    E1_MATRIC = BA1_MATRIC AND "
   cSQL += "    " + cSE1Name + ".D_E_L_E_T_ <> '*' "
   cSQL += " WHERE BA1_FILIAL = '" + xFilial("BA1") + "' AND "
   cSQL += "        BA1_CODINT = '" + cCodInt + "' AND "
   cSQL += "       (BA1_CODEMP >= '" + cCodEmpDe + "' AND BA1_CODEMP <= '" + cCodEmpAte + "') AND "
   If nLisUsuar == 1     // Ativos
      cSQL += "     BA1_DATBLO = '        ' AND "
   ElseIf nLisUsuar == 2 // Bloqueados
      cSQL += "     BA1_DATBLO <> '        ' AND "
      cSQL += "    (BA1_DATBLO >= '" + DtoS(dDtBloqDe) + "' AND BA1_DATBLO <= '" + DtoS(dDtBloqAte) + "') AND "
   ElseIf nLisUsuar == 3 // Ambos
      cSQL += "    (BA1_DATBLO = '        ' OR (BA1_DATBLO <> '        ' AND (BA1_DATBLO >= '" + DtoS(dDtBloqDe) + "' AND BA1_DATBLO <= '" + DtoS(dDtBloqAte) + "'))) AND "
   EndIf
   cSQL += "        BA1_TIPUSU = 'T' AND "
   cSQL += "    " + cBA1Name + ".D_E_L_E_T_ <> '*' AND "
   cSQL += "       (BI3_CONTA >=  '" + cContaDe + "' AND BI3_CONTA <= '" + cContaAte + "') AND "
   cSQL += "        E1_STATUS = 'A' AND "
   cSQL += "       (E1_VENCTO  >= '" + DtoS(dVenctoDe) + "' AND E1_VENCTO  <= '" + DtoS(dVenctoAte) + "') "
   cSQL += " ORDER BY BI3_CONTA, E1_VENCTO, BA1_CODEMP, BA1_NOMUSR"

   PLSQuery(cSQL,"Trb196") // Igual ao TCQuery
   Trb196->(DbGotop()) 
   cConta := Nil
   Do While ! Trb196->(Eof())
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica se foi abortada a impressao...                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If Interrupcao(lAbortPrint)
         @ ++nLin, 00 pSay PLSTR0002
         Exit
      Endif                                                  

	  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	  //³ Ponto de entrada que permite fazer um "by pass" no registro corrente                                 |
	  //| Retorno: .T. (passa) ou .F. (considera) - 24/02/2006 - Sandro                                        |
	  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	  If lPLR196BP
		 If ExecBlock("PLR196BP",.F.,.F.,{ Trb196->RECSE1 })
		    Trb196->(DbSkip())
		    Loop
		 EndIf
	  EndIf

      MsProcTxt(Trb196->BA1_CODEMP + "." + Trb196->BA1_MATRIC)
      ProcessMessages()
      
      If cConta <> Trb196->BI3_CONTA
         If cConta <> Nil          
            fSubTot(@aSaldo, @nLin, Titulo, Cabec1, Cabec2)
            fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
            @ nLin, 0 pSay Replicate("-",132)
         EndIf
         cConta := Trb196->BI3_CONTA
         fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)                                    
         
         cDescCta := Posicione("CT1",1,xFilial("CT1")+Trb196->BI3_CONTA,"CT1_DESC01")
         
         @ nLin, 0 pSay "CONTA CONTABIL: " + objCENFUNLGP:verCamNPR("BI3_CONTA",Trb196->BI3_CONTA) + " - " + cDescCta
         fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
      EndIf
      
      fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
      @ nLin,  2 pSay objCENFUNLGP:verCamNPR("BA1_CODEMP",Trb196->BA1_CODEMP)
      @ nLin, 11 pSay objCENFUNLGP:verCamNPR("BA1_MATANT",Trb196->BA1_MATANT)
      @ nLin, 29 pSay objCENFUNLGP:verCamNPR("BA1_MATRIC",Trb196->BA1_MATRIC)
      @ nLin, 39 pSay objCENFUNLGP:verCamNPR("BA1_NOMUSR",Padr(Trb196->BA1_NOMUSR,50))
      @ nLin, 91 pSay objCENFUNLGP:verCamNPR("E1_VENCTO",DtoC(Trb196->E1_VENCTO))
      @ nLin,103 pSay objCENFUNLGP:verCamNPR("E1_SALDO",Transform(Trb196->E1_SALDO, "@E 999,999,999.99"))
      @ nLin,119 pSay objCENFUNLGP:verCamNPR("E1_PREFIXO",Trb196->E1_PREFIXO) + " " +;
                      objCENFUNLGP:verCamNPR("E1_NUM",Trb196->E1_NUM) + " " +;
                      objCENFUNLGP:verCamNPR("E1_PARCELA",Trb196->E1_PARCELA)
      aSaldo[2] += Trb196->E1_SALDO
      Trb196->(DbSkip())
   EndDo
   
   fSubTot(@aSaldo, @nLin, Titulo, Cabec1, Cabec2)
   fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
   @ nLin, 11 pSay "TOTAL GERAL"
   @ nLin,103 pSay objCENFUNLGP:verCamNPR("E1_SALDO",Transform(aSaldo[1], "@E 999,999,999.99"))
   
   Trb196->(DbCloseArea())
   
Return

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ fSubTot       ³ Autor ³ Sandro Hoffman     ³ Data ³ 11.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Imprime "TOTAL DA CONTA", acumula para o "TOTAL GERAL" e zera  ³±±
±±³           ³ variavel ref "TOTAL DA CONTA"                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSubTot(aSaldo, nLin, Titulo, Cabec1, Cabec2)
   
   fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
   @ nLin, 11 pSay "TOTAL DA CONTA"
   @ nLin,103 pSay objCENFUNLGP:verCamNPR("E1_SALDO",Transform(aSaldo[2], "@E 999,999,999.99"))
   aSaldo[1] += aSaldo[2]
   aSaldo[2] := 0

Return
/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ fSomaLin      ³ Autor ³ Sandro Hoffman     ³ Data ³ 10.01.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o ³ Soma "n" Linhas a variavel "nLin" e verifica limite da pagina  ³±±
±±³           ³ para impressao do cabecalho                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fSomaLin(nLin, Titulo, Cabec1, Cabec2, nLinSom)

   nLin += nLinSom
   If nLin > 58
      nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo) + 1
   EndIf

Return