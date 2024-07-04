#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSR198 ³ Autor ³ Sandro Hoffman Lopes   ³ Data ³ 29.11.05 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Lista relatorio das Empresas com mais de ?? vidas          ³±±±
±±³          ³ pois as mesmas nao tem carencia para CPT                   ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Sintaxe   ³ PLSR198()                                                  ³±±±
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
Function PLSR198(lAuto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de Vidas por Operadora/Empresa/Contrato/SubContrato."
Local cDesc3        := ""
Local cPict         := ""
Local titulo        := "RELACAO DE VIDAS POR OPERADORA/EMPRESA/CONTRATO/SUBCONTRATO"
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local aOrd          := {}

Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private tamanho     := "M"
Private nomeprog    := "PLSR198"
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cPerg       := "PLR198"
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "PLSR198"
Private lCompres    := .T.
Private lDicion     := .F.
Private lFiltro     := .F.
Private lCrystal    := .F.
Private cString     := "BQC"
Private nTotVid     := 0
Private cCodIntDe   := ""
Private cCodIntAte  := ""
Private cCodEmpDe   := ""
Private cCodEmpAte  := ""
Private cNumConDe   := ""
Private cNumConAte  := ""
Private cVerConDe   := ""
Private cVerConAte  := ""
Private cSubConDe   := ""
Private cSubConAte  := ""
Private cVerSubDe   := ""
Private cVerSubAte  := ""

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=  SetPrint(cString,NomeProg,cPerg,@Titulo,cDesc1,cDesc2,cDesc3,lDicion,aOrd,lCompres,Tamanho,{},lFiltro,lCrystal)

	aAlias := {"BQC","BA1","BA0","BG9"}
	objCENFUNLGP:setAlias(aAlias)

If nLastKey == 27
	Return
Endif

If !lAuto
   SetDefault(aReturn,cString)
Endif   

If nLastKey == 27
   Return
Endif

nTipo := If(aReturn[4]==1,15,18)

nTotVid    := mv_par01
cCodIntDe  := mv_par02
cCodIntAte := mv_par03
cCodEmpDe  := mv_par04
cCodEmpAte := mv_par05
cNumConDe  := mv_par06
cNumConAte := mv_par07
cVerConDe  := mv_par08
cVerConAte := mv_par09
cSubConDe  := mv_par10
cSubConAte := mv_par11
cVerSubDe  := mv_par12
cVerSubAte := mv_par13

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsAguarde({|| R198Imp(Cabec1,Cabec2,Titulo,nLin,lAuto) }, Titulo, "", .T.)

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
±±³Fun‡„o    ³R198Imp    ³ Autor ³ Sandro Hoffman Lopes  ³ Data ³ 24/11/05³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime relatorio para conferencia dos valores gerados no   ³±±
±±³          ³arquivo de pagamento da RDA.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function R198Imp(Cabec1,Cabec2,Titulo,nLin,lAuto)
       
   Local cBA1Name := RetSQLName("BA1")
   Local cBQCName := RetSQLName("BQC")
   Local cChave   := ""
   Local nTotGer   := 0

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Exibe mensagem...                                                        ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If !lAuto
      MsProcTxt(PLSTR0001)
   Endif   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Faz filtro no arquivo...                                                 ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cSQL := " SELECT BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB, BQC_DATCON, BQC_DESCRI, BQC_ANTCON, COUNT(BA1_MATVID) TOTVID "
   cSQL += " FROM " + cBQCName + " BQC " 
   cSQL += " LEFT OUTER JOIN " + cBA1Name + " BA1 "
   cSQL += " ON BA1_FILIAL = BQC_FILIAL AND "
   cSQL += " BA1_CODINT    = BQC_CODINT AND "
   cSQL += " BA1_CODEMP    = BQC_CODEMP AND "
   cSQL += " BA1_CONEMP    = BQC_NUMCON AND "
   cSQL += " BA1_VERCON    = BQC_VERCON AND "
   cSQL += " BA1_SUBCON    = BQC_SUBCON AND "
   cSQL += " BA1_VERSUB    = BQC_VERSUB AND "
   cSQL += " BA1_MOTBLO    = '" + Space(Len(BA1->BA1_MOTBLO)) + "' AND "
   cSQL += " BA1.D_E_L_E_T_ <> '*' "
   cSQL += " WHERE BQC_FILIAL = '" + xFilial("BQC") + "' AND "
   cSQL += " (BQC_CODINT >= '" + cCodIntDe + "' AND "
   cSQL += "  BQC_CODINT <= '" + cCodIntAte + "') AND "
   cSQL += " (BQC_CODEMP >= '" + cCodEmpDe + "' AND "
   cSQL += "  BQC_CODEMP <= '" + cCodEmpAte + "') AND "
   cSQL += " (BQC_NUMCON >= '" + cNumConDe + "' AND " 
   cSQL += "  BQC_NUMCON <= '" + cNumConAte + "') AND " 
   cSQL += " (BQC_VERCON >= '" + cVerConDe + "' AND " 
   cSQL += "  BQC_VERCON <= '" + cVerConAte + "') AND " 
   cSQL += " (BQC_SUBCON >= '" + cSubConDe + "' AND " 
   cSQL += "  BQC_SUBCON <= '" + cSubConAte + "') AND " 
   cSQL += " (BQC_VERSUB >= '" + cVerSubDe + "' AND " 
   cSQL += "  BQC_VERSUB <= '" + cVerSubAte + "') AND " 
   cSQL += " BQC.D_E_L_E_T_ <> '*'"
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Se houver filtro executa parse para converter expressoes adv para SQL    ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   If ! Empty(aReturn[7])
      cSQL += " AND " + PLSParSQL(aReturn[7])
   Endif
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta Grupo...                                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cSQL += " GROUP BY BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB, BQC_DATCON, BQC_DESCRI, BQC_ANTCON "   
   cSQL += " ORDER BY BQC_CODINT, BQC_CODEMP, BQC_NUMCON, BQC_VERCON, BQC_SUBCON, BQC_VERSUB "

   PLSQuery(cSQL,"Trb198") // Igual ao TCQuery
   Trb198->(DbGotop()) 
   Do While ! Trb198->(Eof())
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Verifica se foi abortada a impressao...                            ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      If Interrupcao(lAbortPrint)
         @ ++nLi, 00 pSay PLSTR0002
         Exit
      Endif                                                  

      MsProcTxt(objCENFUNLGP:verCamNPR("BQC_CODINT",Trb198->BQC_CODINT) + "." + objCENFUNLGP:verCamNPR("BQC_CODEMP",Trb198->BQC_CODEMP))
      If StrZero(Trb198->TOTVID, 16, 0) > StrZero(nTotVid, 16, 0)
         If Trb198->(BQC_CODINT+BQC_CODEMP) <> cChave
            If !Empty(cChave)
               
        	   fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
    	       @ nLin, 0 pSay "                                                                                                           Total de Vidas por Empresa"    
	           fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1) 
               @ nLin,125 pSay Transform(nTotger, "@E 999,999")
	           fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2) 
               @ nLin, 0 pSay Replicate("-", Limite)
               fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
            EndIf
            fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
            cChave := Trb198->(BQC_CODINT+BQC_CODEMP) 
            nTotGer:=0
            @ nLin, 0 pSay "Operadora: " + objCENFUNLGP:verCamNPR("BQC_CODINT",Trb198->BQC_CODINT) + " - " +;
                                           objCENFUNLGP:verCamNPR("BA0_NOMINT",Posicione("BA0", 1, xFilial("BA0")+Trb198->BQC_CODINT, "BA0_NOMINT"))
            fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
            @ nLin, 0 pSay "Empresa:   " + objCENFUNLGP:verCamNPR("BQC_CODEMP",Trb198->BQC_CODEMP) + " - " +;
                                           objCENFUNLGP:verCamNPR("BG9_DESCRI",Posicione("BG9", 1, xFilial("BG9")+Trb198->BQC_CODEMP, "BG9_DESCRI"))
            fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
            @ nLin, 0 pSay "Contrato/Versao  SubCon/Versao Data Contrato Descricao                                                   Nr Ant Contr Total de Vidas"
         EndIf
         fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
         @ nLin,  0 pSay objCENFUNLGP:verCamNPR("BQC_NUMCON",Trb198->BQC_NUMCON) + "/" +;
                         objCENFUNLGP:verCamNPR("BQC_VERCON",Trb198->BQC_VERCON)
         @ nLin, 17 pSay objCENFUNLGP:verCamNPR("BQC_SUBCON",Trb198->BQC_SUBCON) + "/" +;
                         objCENFUNLGP:verCamNPR("BQC_VERSUB",Trb198->BQC_VERSUB)
         @ nLin, 31 pSay objCENFUNLGP:verCamNPR("BQC_DATCON",DtoC(Trb198->BQC_DATCON))
         @ nLin, 45 pSay objCENFUNLGP:verCamNPR("BQC_DESCRI",SubStr(Trb198->BQC_DESCRI, 1, 60))
         @ nLin,105 pSay objCENFUNLGP:verCamNPR("BQC_ANTCON",Trb198->BQC_ANTCON)
         @ nLin,125 pSay Transform(Trb198->TOTVID, "@E 999,999") 
         nTotGer+=Trb198->TOTVID
         
      EndIf
      Trb198->(DbSkip())
   EndDo
   If nTotger >0
  	   fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 2)
      @ nLin, 0 pSay "                                                                                                           Total de Vidas por Empresa" 
   	fSomaLin(@nLin, Titulo, Cabec1, Cabec2, 1)
      @ nLin,125 pSay Transform(nTotger, "@E 999,999")

  Endif      
   
   Trb198->(DbCloseArea())
   
Return

/*/  
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Programa  ³ fSomaLin      ³ Autor ³ Sandro Hoffman     ³ Data ³ 28.11.2005 ³±±
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