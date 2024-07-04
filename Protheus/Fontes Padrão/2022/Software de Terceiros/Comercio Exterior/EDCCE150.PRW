#INCLUDE "EDCCE150.ch"
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EDCCE150 ³ Autor ³ Thomaz               ³ Data ³ 30.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Relatório de Comprovações Externas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observação³ Uso - Sigaedc                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EDCCE150()

EDCCE150R3(.T.)
Return .t.
*-----------------------*
Function EDCCE150R3(p_R4)
*-----------------------*
Local nOpca := 1, lRet := .F.
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}

Private nCol:= 00, nCol1:= nCol+26, nCol2:= nCol1+16, nCol3:= nCol2+14
Private nCol4:= nCol3+07, nCol5:= nCol4+09, nCol6:= nCol5+14, nCol7:= nCol6+12
Private nCol8:= nCol7+20, nCol9:= nCol8+19, nCol10:= nCol9+17, nCol11:= nCol10+19
Private nCol12:=nCol11+18, nCol24:=nCol12+08, nCol13:= nCol, nCol14:= nCol13+23
Private nCol15:= nCol14+16, nCol16:= nCol15+14, nCol17:= nCol16+10, nCol18:= nCol17+11, nCol19:= nCol18+20
Private nCol20:= nCol19+21, nCol21:= nCol20+21, nCol22:= nCol21+21, nCol23:= nCol22+16
Private nCol25:= nCol23+10, cFileDbf
Private cAlias, cAlias1, cCnpj, lTop, cFilED8 := xFilial("ED8")
Private cFilSA2:= xFilial("SA2"), lAbriuSA2, cFilSA2Aux:=cFilSA2
Private cFilSYT:= xFilial("SYT"), cFilED9 := xFilial("ED9")
Private cEnde:= cCid:= cEst:= cPais:= ""
Private cCabec
Private lR4       := If(p_R4==NIL,.F.,p_R4) .AND. FindFunction("TRepInUse") .And. TRepInUse()
Private cTipo := 1 //ER - 11/12/2006
if lR4
   Private nRecQ1,nRecQ2
endif
If AmIin(50)
   lAbriuSA2 := AbreArqExp("SA2",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))),cFilSA2Aux) // Abre arq. SA2 de outra Empresa/Filial de acordo com os parametros.
   If lAbriuSA2
      cFilSA2Aux   := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
      If(Empty(Alltrim(cFilSA2Aux)),cFilSA2Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
   Endif
Endif

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

While .T.
   DbSelectArea("ED8") //LRL 22/04/04
   If ! Pergunte("EDCCE1",.T.)
      Exit
   EndIf

   cCnpj := mv_par01

   /*
      ER - 11/12/2006
      Não existe mais a opção de "Exportação", apenas "Importação", o filtro deve ser retirado.
   */
   //cTipo := mv_par02

   If nOpca == 1
      MsAguarde({|| lRet := EDCCE150GERA()}, STR0001) //"Aguarde... Lendo Dados do Arquivo..."
   ElseIf nOpca == 0
      Exit
   EndIf

   If ! lRet
      Exit
   Endif

EndDo

If lAbriuSA2
   FechaArqExp("SA2",.T.)
Endif

dbSelectArea(cAlias)

ED8->(dbSetOrder(1))
ED9->(dbSetOrder(1))

Return

*-----------------------------*
Static Function EDCCE150GERA()
*-----------------------------*
Local cDesc1         := STR0002 //"Este programa tem como objetivo imprimir "
Local cDesc2         := STR0003 //"dados de Comprovações Externas"
Local cDesc3         := ""
Private titulo       := STR0004 //"Relatório de Comprovações Externas."
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private cString      := "ED8"
Private CbTxt        := ""
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "EDCCE150"
Private nTipo        := 18
Private aReturn      := {STR0005, 1, STR0006, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "EDCCE150"
Private nPagina      := 0
Private cAlias       := "ED8"
Private cAlias1      := "ED9"
Private lImprime     := .F.

(cAlias)->(dbSetOrder(2))
(cAlias1)->(dbSetOrder(2))
SYT->(dbSetOrder(3))
SA2->(dbSetOrder(3))

If lTop
   (cAlias):= "QD8"
   (cAlias1):="QD9"
   Processa({|| GeraQuery()}, STR0007) //"Aguarde Pesquisando Dados"
Endif

If !lR4
   wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

   If nLastKey = 27
      If Select(cAlias) <> 0
         (cAlias)->(DbCloseArea())
      Endif
      If Select(cAlias1) <> 0
         (cAlias1)->(DbCloseArea())
      Endif
      Return
   Endif

   SetDefault(aReturn,cString)

   nTipo := If(aReturn[4]==1,15,18)
EndIf

CE150CRIAWORK()

If lR4
   //TRP - 31/08/2006 - Relatório Personalizavel - Release 4
   //ReportDef cria os objetos.
   oReport := ReportDef()
EndIf


If Select(cAlias) <> 0 .Or. Select(cAlias1) <> 0
   If lR4
      lImprime := oReport:PrintDialog()
      If(lImprime, EDCCEGERADBF(), )
   Else
      RptStatus({|lEnd| lImprime:= Imprime(wnRel,cString)})
      If(lImprime, EDCCEGERADBF(), )
   EndIf
Else
   Help(" ",1,"AVG0005190") //"Nao ha Dados para Impressao!"
Endif

If lTop
  If Select(cAlias) <> 0
     (cAlias)->(DbCloseArea())
  Endif
  If Select(cAlias1) <> 0
     (cAlias1)->(DbCloseArea())
  Endif
Endif

WORK->(E_EraseArq(cFileDbf))

Return .T.

*--------------------------------------*
STATIC FUNCTION Imprime(wnrel,cString)
*--------------------------------------*
Local cPictAc := AVSX3("ED8_AC",6), cPictDi := AVSX3("ED8_DI_NUM",6)
Local cPictAd := AVSX3("ED8_ADICAO",6), cPictDt:= AVSX3("ED8_DTREG",6)
Local cPictLi := AVSX3("ED8_LI_NUM",6), cPictFob:= AVSX3("ED8_VALEMB",6)
Local cPictTx := AVSX3("ED8_TX_MOE",6), cPictVlM:= AVSX3("ED8_VALORI",6)
Local cPictNF:= AVSX3("ED8_NF",6), cPictSerie:= AVSX3("ED8_SERIE",6)
Local cPictPeso:=AVSX3("ED8_PESO",6)
Local cPictRe:= AVSX3("ED9_RE",6), lImp:= .F.

Private nLin := 99

// Imprime Importacao
If Select(cAlias) <> 0  .And. Str(cTipo,1) $ ("1/3")

   If !lTop
      SYT->(dbSeek(cFilSYT+Left(cCnpj,8)))
      cImp:= SYT->YT_COD_IMP
      bWhile := {|| cFilED8 == (cAlias)->ED8_FILIAL .And. (cAlias)->ED8_IMPORT == cImp}
      (cAlias)->(DbSetOrder(2))
      (cAlias)->(DbSeek(cFilED8+cImp))
   Else
      bWhile:= {|| cFilED8 == (cAlias)->ED8_FILIAL}
   Endif

   Do While (cAlias)->(!EOF()) .And. Eval(bWhile)

      SysRefresh()
	  If nLin >= 55
         EDCCE150CAB()
         @ nLin,nCol Psay STR0008 //"   Nome Importador           Nro D.I.       Ato Conc.   Adição Dt. Reg.   Nro L.I.      Dt L.I.          Peso            Valor FOB         Tx. Moeda        Valor Moeda       Nota Fiscal   Série   Dt. Emissão "
         nLin++
         @ nLin,nCol Psay STR0015 // "========================= =============== ============= ====== ======== ============= ==========  =================== =================  ===============  =================  =============    =====   ============ "
         nLin++
  	  EndIf

  	  lImp := .T.

      @ nLin,nCol   PSAY Substr((cAlias)->YT_NOME,1,24)
      @ nLin,nCol1  PSAY Transf((cAlias)->ED8_DI_NUM, cPictDi)
      @ nLin,nCol2  PSAY Transf((cAlias)->ED8_AC, cPictAc)
      @ nLin,nCol3  PSAY Transf((cAlias)->ED8_ADICAO, cPictAd)
      @ nLin,nCol4  PSAY Transf((cAlias)->ED8_DTREG, cPictDt)
      @ nLin,nCol5  PSAY Transf((cAlias)->ED8_LI_NUM, cPictLi)
      If ED8->( FieldPos("ED8_DTLI") ) > 0
         @ nLin,nCol6  PSAY Transf((cAlias)->ED8_DTLI, cPictDt)
      EndIf
      @ nLin,nCol7  PSAY Transf((cAlias)->ED8_PESO, cPictPeso)
      If ED8->( FieldPos("ED8_VALEMB") ) > 0
         @ nLin,nCol8  PSAY Transf((cAlias)->ED8_VALEMB, cPictFob)
      EndIf
      @ nLin,nCol9  PSAY Transf((cAlias)->ED8_TX_MOE, cPictTx)
      If ED8->( FieldPos("ED8_VALORI") ) > 0
         @ nLin,nCol10 PSAY Transf((cAlias)->ED8_VALORI, cPictVlM)
      EndIF
      @ nLin,nCol11 PSAY Transf((cAlias)->ED8_NF, cPictNF)
      @ nLin,nCol12 PSAY Transf((cAlias)->ED8_SERIE, cPictSerie)
      @ nLin,nCol24 PSAY Transf((cAlias)->ED8_EMISSA, cPictDt)
      nLin++


	  EDCCEGRVDBF("ED8")

	  (cAlias)->(DbSkip())
   Enddo
Endif

// Imprime Exportacao
nLin := nLin+2
If Select(cAlias1) <> 0 .And. Str(cTipo,1) $ ("2/3")

   If !lTop
      SA2->(dbSeek(cFilSA2Aux+Left(cCnpj,8)))
      cExp:= SA2->A2_COD
      bWhile1 := {|| cFilED9 == (cAlias1)->ED9_FILIAL .And. (cAlias1)->ED9_EXPORT == cExp}

      (cAlias1)->(DbSeek(cFilED9+cExp))
   Else
      bWhile1:= {|| cFilED9 == (cAlias1)->ED9_FILIAL}
   Endif

   lCab:=.T.

   Do While (cAlias1)->(!EOF()) .And. Eval(bWhile1)
      If Empty(cCnpj)
         SA2->(dbSeek(cFilSA2Aux+(cAlias1)->ED9_EXPORT+(cAlias1)->ED9_LOJA))
      Endif

      SysRefresh()
      If nLin >= 55
         EDCCE150CAB()
    	 lCab:= .T.
      EndIf

  	  If lCab
  	     @ nLin,nCol Psay STR0009 //"   Nome Exportador        Nro R.E.       Ato Conc.    Dt R.E.   Dt Emb.          Peso             Valor FOB            Tx. Moeda           Valor Moeda        Nota Fiscal    Série    Data Emissão "
         nLin++
         @ nLin,nCol Psay STR0014 //"====================== =============== ============= ========= =========  =================== ==================   ==================   ==================   ============    =====    ================"
         nLin++

         lCab:=.F.
  	  Endif

  	  lImp := .T.

  	  @ nLin,nCol13 PSAY Substr((cAlias1)->A2_NOME,1,20)
      @ nLin,nCol14 PSAY Transf((cAlias1)->ED9_RE, cPictRe)
      @ nLin,nCol15 PSAY Transf((cAlias1)->ED9_AC, cPictAc)
      @ nLin,nCol16 PSAY Transf((cAlias1)->ED9_DTRE, cPictDt)
      @ nLin,nCol17 PSAY Transf((cAlias1)->ED9_DTEMB, cPictDt)
      @ nLin,nCol18 PSAY Transf((cAlias1)->ED9_PESO, cPictPeso)
      @ nLin,nCol19 PSAY Transf((cAlias1)->ED9_VL_FOB, cPictFob)
      @ nLin,nCol20 PSAY Transf((cAlias1)->ED9_TX_MOE, cPictTx)
      @ nLin,nCol21 PSAY Transf((cAlias1)->ED9_VALMOE, cPictVlM)
      @ nLin,nCol22 PSAY Transf((cAlias1)->ED9_NF, cPictNF)
      @ nLin,nCol23 PSAY Transf((cAlias1)->ED9_SERIE, cPictSerie)
      @ nLin,nCol25 PSAY Transf((cAlias1)->ED9_EMISSA, cPictDt)

      nLin++

	  EDCCEGRVDBF("ED9")

	  (cAlias1)->(DbSkip())
   Enddo
Endif


If lImp
   If aReturn[5] = 1
      Set Printer To
      Commit
      Ourspool(wnrel)
   EndIf
Else
   Help(" ",1,"AVG0005190") //"Nao Ha Dados para Impressao !"
Endif


MS_FLUSH()

Return .T.

*-----------------------------------*
STATIC FUNCTION EDCCE150CAB()
*-----------------------------------*
Local TituloRel := Titulo, cModo:= "", cFilSYA:= xFilial("SYA")
nLin := 08

SYA->(dbSetOrder(1))

If cTipo == 1
   cModo := STR0016 //"Importação"
ElseIf cTipo == 2
   cModo := STR0017 //"Exportação"
Else
   cModo := STR0018 //"Ambos"
Endif

If !lTop
   If cTipo == 2
      SYA->(dbSeek(cFilSYA+SA2->A2_PAIS))
      cEnde := SA2->A2_END
      cCid  := SA2->A2_MUN
      cEst  := SA2->A2_EST
   ElseIf cTipo == 1
      SYA->(dbSeek(cFilSYA+SYT->YT_PAIS))
      cEnde := SYT->YT_ENDE
      cCid  := SYT->YT_CIDADE
      cEst  := If(!Empty(SYT->YT_ESTADO), Alltrim(SYT->YT_ESTADO)+STR0021,"")+If(!Empty(SYT->YT_UNIDFED), SYT->YT_UNIDFED, "") //" - "
   Else
      If Select(cAlias) <> 0
         SYA->(dbSeek(cFilSYA+(cAlias)->YT_PAIS))
         cEnde := (cAlias)->YT_ENDE
         cCid  := (cAlias)->YT_CIDADE
         cEst  := If(!Empty((cAlias)->YT_ESTADO), Alltrim((cAlias)->YT_ESTADO)+STR0021,"")+If(!Empty((cAlias)->YT_UNIDFED),(cAlias)->YT_UNIDFED,"") //" - "
      ElseIf Select(cAlias1) <> 0
         SYA->(dbSeek(cFilSYA+(cAlias1)->A2_PAIS))
         cEnde := (cAlias1)->A2_END
         cCid  := (cAlias1)->A2_MUN
         cEst  := (cAlias1)->A2_EST
      Endif
   Endif
Else
   If cTipo == 2
      SYA->(dbSeek(cFilSYA+(cAlias1)->A2_PAIS))
      cEnde := (cAlias1)->A2_END
      cCid  := (cAlias1)->A2_MUN
      cEst  := (cAlias1)->A2_EST
   ElseIf cTipo == 1
      SYA->(dbSeek(cFilSYA+(cAlias)->YT_PAIS))
      cEnde := (cAlias)->YT_ENDE
      cCid  := (cAlias)->YT_CIDADE
      cEst  := If(!Empty((cAlias)->YT_ESTADO),Alltrim((cAlias)->YT_ESTADO)+STR0021,"")+If(!Empty((cAlias)->YT_UNIDFED),(cAlias)->YT_UNIDFED,"") //" - "
   Else
      If Select(cAlias) <> 0 .And. (cAlias)->(!EOF())
         SYA->(dbSeek(cFilSYA+(cAlias)->YT_PAIS))
         cEnde := (cAlias)->YT_ENDE
         cCid  := (cAlias)->YT_CIDADE
         cEst  := If(!Empty((cAlias)->YT_ESTADO),Alltrim((cAlias)->YT_ESTADO)+STR0021,"")+If(!Empty((cAlias)->YT_UNIDFED),(cAlias)->YT_UNIDFED,"") //" - "
      ElseIf Select(cAlias1) <> 0 .And. (cAlias1)->(!EOF())
         SYA->(dbSeek(cFilSYA+(cAlias1)->A2_PAIS))
         cEnde := (cAlias1)->A2_END
         cCid  := (cAlias1)->A2_MUN
         cEst  := (cAlias1)->A2_EST
      Endif
   Endif
Endif

cPais:= SYA->YA_DESCR
Cabec1 := STR0010+cCnpj+Space(160)+STR0019+cModo //"Tipo - "
Cabec2 := If(!Empty(cEnde),STR0011+Alltrim(cEnde),"")+Space(75)+If(!Empty(cCid),STR0012+Alltrim(cCid),"")+Space(15)+If(!Empty(cEst),STR0013+Alltrim(cEst), "")+Space(15)+If(!Empty(cPais),STR0020+cPais,"") //"Endereço - "###" Cidade - "###"Estado - "###"Pais - "

If !lR4
   Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
   nLin ++
EndIf

Return .T.

*-----------------------------*
Static Function GeraQuery()
*-----------------------------*
Local aCondDel :={"AND ED8.D_E_L_E_T_ <> '*' ","AND SYT.D_E_L_E_T_ <> '*' "}
Local aCondDel1:={"AND ED9.D_E_L_E_T_ <> '*' ","AND SA2.D_E_L_E_T_ <> '*' "}
Local cQuery, cQuery1, cCond :="", cCond1:=""
Local cFilED8:=xFilial("ED8"), cFilED9:=xFilial("ED9")

cCond +="ED8.ED8_FILIAL='"+cFilED8+"' "+If(TcSrvType()<>"AS/400",aCondDel[1],"")
cCond +="AND SYT.YT_FILIAL='"+cFilSYT+"'"+If(TcSrvType()<>"AS/400",aCondDel[2],"")
cCond +="AND SYT.YT_IMP_CON = '1' AND SYT.YT_CGC = '"+cCnpj+"' "//AND SYT.YT_CGC = ED8.ED8_IMPORT "

cQuery := " SELECT DISTINCT ED8.ED8_FILIAL, ED8.ED8_IMPORT, ED8.ED8_AC, ED8.ED8_PESO, "
cQuery += " ED8.ED8_DI_NUM, ED8.ED8_ADICAO, ED8.ED8_DTREG, ED8.ED8_LI_NUM, "
cQuery += If( ED8->( FieldPos("ED8_VALORI") ) > 0," ED8.ED8_VALORI,","")+" ED8.ED8_TX_MOE, ED8.ED8_NF, ED8.ED8_SERIE, ED8.ED8_EMISSA, "
cQuery += If( ED8->( FieldPos("ED8_DTLI") ) > 0," ED8.ED8_DTLI,","")+" ED8.ED8_VALEMB, SYT.YT_FILIAL, SYT.YT_NOME, SYT.YT_UNIDFED, "
cQuery += " SYT.YT_CGC, SYT.YT_CIDADE, SYT.YT_ESTADO, SYT.YT_ENDE, SYT.YT_PAIS "
cQuery += " FROM "+RetSqlName("ED8")+" ED8, "+RetSqlName("SYT")+" SYT "
cQuery += " WHERE "+cCond+ " ORDER BY ED8.ED8_IMPORT"

cCond1 +="ED9.ED9_FILIAL='"+cFilED9+"' "+If(TcSrvType()<>"AS/400",aCondDel1[1],"")
cCond1 +="AND SA2.A2_FILIAL='"+cFilSA2+"'"+If(TcSrvType()<>"AS/400",aCondDel1[2],"")
cCond1 +=" AND SA2.A2_CGC = '"+cCnpj+"' "//AND SA2.A2_CGC = ED9.ED9_EXPORT "

cQuery1 := " SELECT DISTINCT ED9.ED9_FILIAL, ED9.ED9_EXPORT, ED9.ED9_AC, ED9.ED9_PESO, "
cQuery1 += " ED9.ED9_RE, ED9.ED9_DTRE, ED9.ED9_DTEMB, ED9.ED9_VL_FOB, ED9.ED9_LOJA, "
cQuery1 += " ED9.ED9_TX_MOE, ED9.ED9_VALMOE, ED9.ED9_NF, ED9.ED9_SERIE, ED9.ED9_EMISSA, SA2.A2_PAIS, "
cQuery1 += " SA2.A2_FILIAL, SA2.A2_NOME, SA2.A2_CGC, SA2.A2_END, SA2.A2_MUN, SA2.A2_EST "
cQuery1 += " FROM "+RetSqlName("ED9")+" ED9, "+RetSqlName("SA2")+" SA2 "
cQuery1 += " WHERE "+cCond1+" ORDER BY ED9.ED9_EXPORT"

cQuery:=ChangeQuery(cQuery)
TcQuery cQuery ALIAS (cAlias) NEW

If Select(cAlias) <> 0
   TCSETFIELD(cAlias,"ED8_DTREG" ,"D")
   If ED8->( FieldPos("ED8_DTLI") ) > 0
      TCSETFIELD(cAlias,"ED8_DTLI","D")
   EndIf
   TCSETFIELD(cAlias,"ED8_EMISSA","D")
Endif
If lR4
   nRecQ1:=CE150TOTREG(cQuery)
ENDIF
cQuery1:=ChangeQuery(cQuery1)
TcQuery cQuery1 ALIAS (cAlias1) NEW

If Select(cAlias1) <> 0
   TCSETFIELD(cAlias1,"ED9_DTRE" ,"D")
   TCSETFIELD(cAlias1,"ED9_DTEMB","D")
   TCSETFIELD(cAlias1,"ED9_EMISSA","D")
Endif
If lR4
   nRecQ2:=CE150TOTREG(cQuery1)
Endif
Return .T.

*-------------------------------*
Static Function CE150CRIAWORK()
*-------------------------------*
Private aWork:={}

aAdd(aWork,{"WKIMPORT","C",AVSX3("YT_NOME",3) ,0})
aAdd(aWork,{"WKDINUM" ,"C",AVSX3("ED8_DI_NUM",3) ,0})
aAdd(aWork,{"WKAC"    ,"C",AVSX3("ED8_AC",3)  ,0})
aAdd(aWork,{"WKADIC"  ,"C",AVSX3("ED8_ADICAO",3) ,0})
aAdd(aWork,{"WKDTREG" ,"D",8 ,0})
aAdd(aWork,{"WKLI"    ,"C",AVSX3("ED8_LI_NUM",3) ,0})

If ED8->( FieldPos("ED8_DTLI") ) > 0
   aAdd(aWork,{"WKDTLI","D",8 ,0})
EndIf

aAdd(aWork,{"WKPESO"  ,"N",AVSX3("ED8_PESO",3),AVSX3("ED8_PESO",4)})
aAdd(aWork,{"WKVL_FOB"  ,AVSX3("ED9_VL_FOB",2),AVSX3("ED9_VL_FOB",3),AVSX3("ED9_VL_FOB",4)})
aAdd(aWork,{"WKVALMOE"  ,AVSX3("ED9_VALMOE",2),AVSX3("ED9_VALMOE",3),AVSX3("ED9_VALMOE",4)})

If ED8->( FieldPos("ED8_VALEMB") ) > 0
   aAdd(aWork,{"WKVALEMB","N",AVSX3("ED8_VALEMB",3),AVSX3("ED8_VALEMB",4)})
EndIf

aAdd(aWork,{"WKTX_MOE","N",AVSX3("ED8_TX_MOE",3),AVSX3("ED8_TX_MOE",4)})

If ED8->( FieldPos("ED8_VALORI") ) > 0
   aAdd(aWork,{"WKVALORI","N",AVSX3("ED8_VALORI",3),AVSX3("ED8_VALORI",4)})
EndIf

aAdd(aWork,{"WK_NF"   ,"C",AVSX3("ED8_NF",3),0})
aAdd(aWork,{"WKSERIE" ,"C",AVSX3("ED8_SERIE",3),0})
aAdd(aWork,{"WKEMISSA","D",8 ,0})
aAdd(aWork,{"WKRE"    ,"C",AVSX3("ED9_RE",3),0})
aAdd(aWork,{"WKDTEMB" ,"D",8 ,0})
aAdd(aWork,{"WKPAIS"  ,"C",AVSX3("YA_DESCR",3),0})
aAdd(aWork,{"WKCIDAD" ,"C",AVSX3("A2_MUN",3),0})
aAdd(aWork,{"WKESTADO","C",AVSX3("A2_EST",3),0})
aAdd(aWork,{"WKENDER" ,"C",AVSX3("A2_END",3),0})
aAdd(aWork,{"WKTIPO"  ,"C",1 ,0})

If Select("Work") > 0    // GFP - 21/09/2012
   Work->(DbCloseArea())
EndIf

DBSelectArea("ED8")
cFileDbf:=E_CriaTrab(,aWork,"Work")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

IndRegua("Work",cFileDbf+TEOrdBagExt(),"WKIMPORT")

Return .T.

*------------------------------*
Static Function EDCCEGERADBF()
*------------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0022; //"Geração de Arquivo DBF/TXT"
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0023 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancel

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1
   TR350ARQUIVO("WORK")
Else
   lRet:= .F.
EndIf

Return lRet

*-----------------------------------*
Static Function EDCCEGRVDBF(cTipo)
*-----------------------------------*
Work->(dbAppend())

Work->WKPAIS   := cPais
Work->WKCIDAD  := cCid
Work->WKESTADO := cEst
Work->WKENDER  := cEnde

If cTipo == "ED8"
   Work->WKIMPORT :=Substr(If(lTop,(cAlias)->YT_NOME,SYT->YT_NOME),1,24)
   Work->WKDINUM  :=(cAlias)->ED8_DI_NUM
   Work->WKAC     :=(cAlias)->ED8_AC
   Work->WKADIC   :=(cAlias)->ED8_ADICAO
   Work->WKDTREG  :=(cAlias)->ED8_DTREG
   Work->WKLI     :=(cAlias)->ED8_LI_NUM

   If ED8->( FieldPos("ED8_DTLI") ) > 0
      Work->WKDTLI :=(cAlias)->ED8_DTLI
   EndIf

   Work->WKPESO   :=(cAlias)->ED8_PESO

   If ED8->( FieldPos("ED8_VALEMB") ) > 0
      Work->WKVALEMB :=(cAlias)->ED8_VALEMB
   EndIf

   Work->WKTX_MOE :=(cAlias)->ED8_TX_MOE

   If ED8->( FieldPos("ED8_VALORI") ) > 0
      Work->WKVALORI :=(cAlias)->ED8_VALORI
   EndIf

   Work->WK_NF    :=(cAlias)->ED8_NF
   Work->WKSERIE  :=(cAlias)->ED8_SERIE
   Work->WKEMISSA :=(cAlias)->ED8_EMISSA
   Work->WKTIPO   :="I"
Else
   Work->WKIMPORT :=Substr(If(lTop,(cAlias1)->A2_NOME,SA2->A2_NOME),1,20)
   Work->WKAC     :=(cAlias1)->ED9_AC
   Work->WKRE     :=(cAlias1)->ED9_RE
   Work->WKDTREG  :=(cAlias1)->ED9_DTRE
   Work->WKDTEMB  :=(cAlias1)->ED9_DTEMB
   Work->WKPESO   :=(cAlias1)->ED9_PESO
   Work->WKVL_FOB :=(cAlias1)->ED9_VL_FOB
   Work->WKTX_MOE :=(cAlias)->ED8_TX_MOE
   Work->WKVALMOE :=(cAlias1)->ED9_VALMOE
   Work->WK_NF    :=(cAlias1)->ED9_NF
   Work->WKSERIE  :=(cAlias1)->ED9_SERIE
   Work->WKEMISSA :=(cAlias1)->ED9_EMISSA
   Work->WKTIPO   :="E"
Endif

Return .T.


//TRP - 31/08/2006 - Definições do relatório personalizável
***************************
Static Function ReportDef()
***************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"ED8","ED9","SYT","SA2"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := { }

//Cria o objeto principal de controle do relatório.
//Parâmetros:            Relatório ,Titulo ,Pergunte ,Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EDCCE150",STR0004,"EDCCE1",{|oReport| ReportPrint(oReport)},STR0002+ "" + STR0003)

oReport:opage:llandscape := .T.  // By JPP - 20/10/2006 - 18:15 - Faz com que sistema traga como default a pagina
oReport:opage:lportrait := .F.   //                               de impressão no formato paisagem

//Define o objeto com a seção do relatório
oSecao2 := TRSection():New(oReport,"Cabeçalho",{""},aOrdem)

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Di´s Externas",aTabelas,aOrdem)

If Str(cTipo,1) $ ("1/3")  // Importaçao
   //Definição das colunas de impressão da seção 1
   TRCell():New(oSecao1,"YT_NOME"             ,cAlias   ,"Nome Importador"      ,/*Picture*/                                  ,40                                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"ED8_DI_NUM"          ,cAlias   ,"Nro D.I."             ,AVSX3("ED8_DI_NUM",6)                        ,12                                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"ED8_AC"              ,cAlias   ,"Ato Conc."            ,AVSX3("ED8_AC",6)                            ,AVSX3("ED8_AC",3)                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"ED8_ADICAO"          ,cAlias   ,"Adicao"               ,AVSX3("ED8_ADICAO",6)                        ,AVSX3("ED8_ADICAO",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"ED8_DTREG"           ,cAlias   ,"Dt.Reg."              ,AVSX3("ED8_DTREG",6)                         ,8                                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"ED8_LI_NUM"          ,cAlias   ,"Nro L.I."             ,AVSX3("ED8_LI_NUM",6)                        ,AVSX3("ED8_LI_NUM",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
   If ED8->( FieldPos("ED8_DTLI") ) > 0
      TRCell():New(oSecao1,"ED8_DTLI"         ,cAlias   ,"Dt L.I."              ,/*Picture*/                                  ,8                                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
   EndIf
   TRCell():New(oSecao1,"ED8_PESO"            ,cAlias   ,"Peso"                 ,AVSX3("ED8_PESO",6)                          ,AVSX3("ED8_PESO",3)                             ,/*lPixel*/,/*{|| code-block de impressao }*/)
   If ED8->( FieldPos("ED8_VALEMB") ) > 0
      TRCell():New(oSecao1,"ED8_VALEMB"       ,cAlias   ,"Valor FOB"            ,AVSX3("ED8_VALEMB",6)                        ,/*Tamanho*/                                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
   Endif
   TRCell():New(oSecao1,"ED8_TX_MOE"          ,cAlias   ,"Tx.Moeda"             ,AVSX3("ED8_TX_MOE",6)                        ,AVSX3("ED8_TX_MOE",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
   If ED8->( FieldPos("ED8_VALORI") ) > 0
      TRCell():New(oSecao1,"ED8_VALORI"       ,cAlias   ,"Valor Moeda"          ,AVSX3("ED8_VALORI",6)                        ,/*Tamanho*/                                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
   Endif
   TRCell():New(oSecao1,"ED8_NF"              ,cAlias   ,"Nota Fiscal"          ,AVSX3("ED8_NF",6)                            ,AVSX3("ED8_NF",3)                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"ED8_SERIE"           ,cAlias   ,"Serie"                ,AVSX3("ED8_SERIE",6)                         ,AVSX3("ED8_SERIE",3)                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
   TRCell():New(oSecao1,"ED8_EMISSA"          ,cAlias   ,"Dt.Emissao"           ,/*Picture*/                                  ,8                                               ,/*lPixel*/,/*{|| code-block de impressao }*/)

   //TRP-30/10/2006
   oReport:Section("Di´s Externas"):Cell("ED8_DI_NUM"   ):SetColSpace(3)
   oReport:Section("Di´s Externas"):Cell("ED8_AC"       ):SetColSpace(3)
   oReport:Section("Di´s Externas"):Cell("ED8_DTREG"    ):SetColSpace(3)
   oReport:Section("Di´s Externas"):Cell("ED8_LI_NUM"   ):SetColSpace(3)
   oReport:Section("Di´s Externas"):Cell("ED8_VALORI"   ):SetColSpace(3)
   oReport:Section("Di´s Externas"):Cell("ED8_NF"       ):SetColSpace(3)
   oReport:Section("Di´s Externas"):Cell("ED8_SERIE"    ):SetColSpace(3)
   oReport:Section("Di´s Externas"):Cell("ED8_ADICAO"   ):SetColSpace(3)
EndIf


/*
   ER - 11/12/2006
   Não existe mais a opção de "Exportação", apenas "Importação".
*/
//If Str(cTipo,1) $ ("2/3")  // Exportaçao
//
//   //Definição das colunas de impressão da seção 1
//   TRCell():New(oSecao1,"A2_NOME"            ,cAlias1   ,"Nome Exportador"      ,/*Picture*/                                  ,AVSX3("YT_NOME",3)                              ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_RE"             ,cAlias1   ,/*Titulo*/             ,AVSX3("ED8_AC",6)                            ,AVSX3("ED8_AC",3)                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_AC"             ,cAlias1   ,"Ato Conc."            ,AVSX3("ED9_RE",6)                            ,AVSX3("ED9_RE",3)                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_DTRE"           ,cAlias1   ,"Dt R.E."              ,AVSX3("ED8_DTREG",6)                         ,8                                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_DTEMB"          ,cAlias1   ,"Dt.Emb."              ,/*Picture*/                                  ,8                                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_PESO"           ,cAlias1   ,"Peso"                 ,AVSX3("ED8_PESO",6)                          ,AVSX3("ED8_PESO",3)                             ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_VL_FOB"         ,cAlias1   ,"Valor FOB"            ,AVSX3("ED8_VALEMB",6)                        ,/*Tamanho*/                                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_TX_MOE"         ,cAlias1   ,"Tx.Moeda"             ,AVSX3("ED8_TX_MOE",6)                        ,AVSX3("ED8_TX_MOE",3)                           ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_VALMOE"         ,cAlias1   ,"Valor Moeda"          ,AVSX3("ED8_VALORI",6)                        ,/*Tamanho*/                                     ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_NF"             ,cAlias1   ,"Nota Fiscal"          ,AVSX3("ED8_NF",6)                            ,AVSX3("ED8_NF",3)                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_SERIE"          ,cAlias1   ,"Serie"                ,AVSX3("ED8_SERIE",6)                         ,AVSX3("ED8_SERIE",3)                            ,/*lPixel*/,/*{|| code-block de impressao }*/)
//   TRCell():New(oSecao1,"ED9_EMISSA"         ,cAlias1   ,"Dt.Emissao"           ,/*Picture*/                                  ,8                                               ,/*lPixel*/,/*{|| code-block de impressao }*/)
//
//Endif

//Definição das colunas de impressão da seção 2
TRCell():New(oSecao2,"Cabecalho"   ,""   , ""                     ,"@!"                               ,250                     ,/*lPixel*/,{||cCabec})

oReport:bOnPageBreak :={||EDCCE150CAB(),cCabec:=Cabec1,oReport:Section("Cabeçalho"):PrintLine(),cCabec:=Cabec2,oReport:Section("Cabeçalho"):PrintLine(),oReport:FatLine()}
oReport:Section("Di´s Externas"):OnPrintLine({||EDCCEGRVDBF("ED8"),EDCCEGRVDBF("ED9")})


//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport

************************************
Static Function ReportPrint(oReport)
************************************
//Cabec1 := STR0010+cCnpj+Space(150)+STR0019+cModo //"Tipo - "
//Cabec2 := If(!Empty(cEnde),STR0011+Alltrim(cEnde),"")+Space(60)+If(!Empty(cCid),STR0012+Alltrim(cCid),"")+Space(15)+If(!Empty(cEst),STR0013+Alltrim(cEst), "")+Space(15)+If(!Empty(cPais),STR0020+cPais,"") //"Endereço - "###" Cidade - "###"Estado - "###"Pais - "
lImprime:=.t.

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
If Empty(cCnpj)
   TRPosition():New(oReport:Section("Di´s Externas"),"SA2",2,{|| cFilSA2Aux+(cAlias1)->ED9_EXPORT+(cAlias1)->ED9_LOJA})
EndIf

If !lTop
   TRPosition():New(oReport:Section("Di´s Externas"),"ED8",2,{||cFilED8 + SYT->YT_COD_IMP })
Else
   TRPosition():New(oReport:Section("Di´s Externas"),"ED8",4,{||cFilED8 + (cAlias)->ED8_DI_NUM + (cAlias)->ED8_ADICAO})
EndIf

If lTop
   oReport:SetMeter(IIF(Str(cTipo,1) $ ("1/3"),nRecQ1,0)+IIF(Str(cTipo,1) $ ("2/3"),nRecQ2,0))
Else
   oReport:SetMeter(IIF(Str(cTipo,1) $ ("1/3"),(cAlias)->(EasyRecCount()),0)+IIF(Str(cTipo,1) $ ("2/3"),(cAlias1)->(EasyRecCount()),0))
EndIf

If Str(cTipo,1) $ ("1/3")  // Importaçao
   (cAlias)->( dbGoTop() )
EndIf

If Str(cTipo,1) $ ("2/3")  // Exportaçao
   (cAlias1)->( dbGoTop() )
EndIf

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Di´s Externas"):Init()

//Inicio da impressão da seção 2. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Cabeçalho"):Init()

//Para desabilitar a impressão da página de parâmetros do pergunte
//oReport:oParamPage:Disable()


If Str(cTipo,1) $ ("1/3")  // Importaçao

   If !lTop
      SYT->(dbSeek(cFilSYT+Left(cCnpj,8)))
      cImp:= SYT->YT_COD_IMP
      bWhile := {|| cFilED8 == (cAlias)->ED8_FILIAL .And. (cAlias)->ED8_IMPORT == cImp}
      (cAlias)->(DbSetOrder(2))
      (cAlias)->(DbSeek(cFilED8+cImp))
   Else
      bWhile:= {|| cFilED8 == (cAlias)->ED8_FILIAL}
   Endif

   //Laço principal
   Do While (cAlias)->(!EoF()) .And. !oReport:Cancel() .And. Eval(bWhile)
      oReport:Section("Di´s Externas"):PrintLine() //Impressão da linha
      oReport:IncMeter()                     //Incrementa a barra de progresso

      (cAlias)->( dbSkip() )
   EndDo
EndIF

If Str(cTipo,1) $ ("2/3")  // Exportaçao

   If !lTop
      SA2->(dbSeek(cFilSA2Aux+Left(cCnpj,8)))
      cExp:= SA2->A2_COD
      bWhile1 := {|| cFilED9 == (cAlias1)->ED9_FILIAL .And. (cAlias1)->ED9_EXPORT == cExp}

      (cAlias1)->(DbSeek(cFilED9+cExp))
   Else
      bWhile1:= {|| cFilED9 == (cAlias1)->ED9_FILIAL}
   Endif


   //Laço principal
   Do While (cAlias1)->(!EoF()) .And. !oReport:Cancel() .And. Eval(bWhile1)
      oReport:Section("Di´s Externas"):PrintLine() //Impressão da linha
      oReport:IncMeter()                     //Incrementa a barra de progresso

      (cAlias1)->( dbSkip() )
   EndDo
EndIF

//Fim da impressão da seção 1
oReport:Section("Di´s Externas"):Finish()

//Fim da impressão da seção 2
oReport:Section("Cabeçalho"):Finish()

Return .T.

/*
Função..: CE150TOTREG
Autor...: Thiago Rinaldi Pinto - TRP
Data....: 01/09/06
Objetivo: Retornar o Numero de Registros em uma Query
*/
Static Function CE150TotReg(cQuery)
Local nTotalReg

If Select("TOTALREG") > 0
   TOTALREG->( dbCloseArea() )
Endif

cQuery := SubStr(cQuery,1,RAt("ORDER BY",cQuery) - 1)

//Total de Registros
cQuery = ChangeQuery("SELECT COUNT(*) AS TOTAL FROM ("+cQuery+") TEMP")
TcQuery cQuery ALIAS "TOTALREG" NEW

nTotalReg:= TOTALREG->TOTAL

TOTALREG->( dbCloseArea() )

Return nTotalReg
