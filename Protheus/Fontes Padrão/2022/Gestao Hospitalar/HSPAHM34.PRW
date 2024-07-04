#INCLUDE "HSPAHM34.ch"
#include "protheus.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPAHM34  บ Autor ณ Cibele Peria       บ Data ณ  26/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ EXTRATO DO PROFISSIONAL                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPAHM34()
 Local nTamSer	:= TamSX3("E1_SERIE")[1]
 Local nTamPre	:= TamSX3("E1_PREFIXO")[1]
 Local nTamTot  := nTamSer + nTamPre + 1
 Local lNfsTela	:= SuperGetMV("MV_NFSTELA", .F., .F.)
 Local cHspSeri := GetMV("MV_HSPSERI")
 Local cPrefCrh := GetMV("MV_PREFCRH")

 Private nAcerto     := 0.0166667 // Acerto de Hora (06:00 - 17:59) soma um minuto em decimal
 Private cCadastro   := OemtoAnsi(STR0001) //"Extrato Medico"
 Private cGA9CodCon  := ""
 Private cE1Prefixo  := ""
 Private cGE0NumExt  := ""
 Private cGE0OpeExt  := ""
 Private cMV_PrefCPH := AllTrim(GetMV("MV_PREFCPH"))
 Private aRotina     := { {OemtoAnsi(STR0002), "axPesqui"  , 0, 1}, ; //"Pesquisar"
                   	      {OemtoAnsi(STR0003), "HS_GerM34" , 0, 3}, ; //"Gerar"
                   	      {OemtoAnsi(STR0004), "HS_AvuM34" , 0, 3}, ; //"Avulso"
                   	      {OemtoAnsi(STR0101), "HS_AvuM34" , 0, 4}, ; //"Alterar"
                   	      {OemtoAnsi(STR0086), "HS_PlaM34" , 0, 3}, ; //"Plantao"
                   	      {OemtoAnsi(STR0005), "HS_DetM34" , 0, 2}, ; //"Detalhar"
                   	      {OemtoAnsi(STR0006), "HS_CPgM34" , 0, 2}, ; //"Contas Pagar"
                   	      {OemtoAnsi(STR0007), "HS_PMiM34" , 0, 3}, ; //"Pagto Minimo/Teto"
                   	      {OemtoAnsi(STR0008), "HS_ExtM34" , 0, 2}, ; //"Extrato"
                   	      {OemtoAnsi(STR0009), "HS_ExcM34" , 0, 5}} //"Excluir"

 cE1Prefixo := IIF(Len(cHSPSERI) >= Len(SE1->E1_SERIE), cHSPSERI, PadR(cHSPSERI, Len(SE1->E1_SERIE))) + "/" + IIF(Len(cPREFCRH) >= Len(SE1->E1_PREFIXO), cPREFCRH, PadR(cPREFCRH, Len(SE1->E1_PREFIXO)))

 If !lNfsTela
 	If Len(cE1Prefixo) > nTamTot
 		MsgStop('Informe apenas uma s้rie e um prefixo nos parโmetros MV_HSPSERI e MV_PREFCRH')
 		Return()
 	EndIf
 EndIf

 DBSelectArea("GDX")
 DbSetOrder(3)
 mBrowse(06, 01, 22, 75, "GDX")

Return(Nil)

//////////////////////////////////////////////////////////////////////////////////
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | HS_GerM34บ Autor ณ Cibele Peria       บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera Extratos                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_GerM34(cAlias, nReg, nOpc)
 Local   aSize  := {}, aObjects := {}, aInfo := {}, aPObjs := {}, aPGDs := {}
 Local oCabec
 Local aCampos   := {}
 Local cSQL      := ""
 Local cSelect   := "", cSelIni := "", cOrderBy := ""
 Local cFrom     := ""
 Local cWhere    := ""
 Local aValMin   := FS_ValMin(), aCondSql := {}
 Local cCondGF   := ""
 Local cCondGcz  := "" , cJoinDes := "", cJoinPct := ""
 Local cHspSeri  := GetMV("MV_HSPSERI")
 Local cPrefCrh  := GetMV("MV_PREFCRH")
 Local lValRep := .F.
 Local aRecNoGE5   := {},  aRecNoGE6   := {},  aRecNoGE7   := {}

 Private cCodCon_De  := ""
 Private cCodCon_Ate := ""
 Private dDatAte_De  := ""
 Private dDatAte_Ate := ""
 Private cCodPre_De  := ""
 Private cCodPre_Ate := ""
 Private cCodCRM_De  := ""
 Private cCodCRM_Ate := ""
 Private cCodLoc_De  := ""
 Private cCodLoc_Ate := ""
 Private cRegGer     := ""
 Private cCodCRM     := ""
 Private cNrExtM_De  := ""
 Private cNrExtM_Ate := ""
 Private oValCre, oValDeb
 Private nValCre     := 0
 Private nValDeb     := 0
 Private lCbG        := .F.
 Private nGE5_CODCRM := 0
 Private nGE5_IDMARC := 0
 Private nGE5_SEQDES := 0
 Private nGE5_VALOR  := 0
 Private nGE5_Tipo   := 0
 Private nGE6_CODCRM := 0
 Private nGE6_IDMARC := 0
 Private nGE6_SEQDES := 0
 Private nGE6_VALOR  := 0
 Private nGE6_Tipo   := 0
 Private nGE7_CODCRM := 0
 Private nGE7_IDMARC := 0
 Private nGE7_SEQDES := 0
 Private nGE7_VALOR  := 0
 Private nGE7_Tipo   := 0
 Private oGE5G, oGE6G, oGE7G, oFolder
 Private aHeadGe5    := {}
 Private aColGe5     := {}
 Private nUGe5       := 0
 Private aHeadGe6    := {}
 Private aColGe6     := {}
 Private nUGe6       := 0
 Private aHeadGe7    := {}
 Private aColGe7     := {}
 Private nUGe7       := 0
 Private aTela       := {}
 Private aGets       := {}
 Private aGuiasGA9   := ""
 Private aRecno      := {}

 cE1Prefixo := IIF(Len(cHSPSERI) >= Len(SE1->E1_SERIE), cHSPSERI, PadR(cHSPSERI, Len(SE1->E1_SERIE))) + "/" + IIF(Len(cPREFCRH) >= Len(SE1->E1_PREFIXO), cPREFCRH, PadR(cPREFCRH, Len(SE1->E1_PREFIXO)))
 cGE0NumExt := SPACE(LEN(GE0->GE0_NUMEXT))
 cGE0OpeExt := "<>"

 If !Pergunte("HSM34G",.T.)
   Return()
 EndIf

 cCodCon_De  := mv_par01
 cCodCon_Ate := mv_par02
 dDatAte_De  := mv_par03
 dDatAte_Ate := mv_par04
 cCodPre_De  := mv_par05
 cCodPre_Ate := mv_par06
 cCodCRM_De  := mv_par07
 cCodCRM_Ate := mv_par08
 cNrExtC_De  := mv_par09
 cNrExtC_Ate := mv_par10
 cRegGer     := mv_par11
 cNrFatu     := mv_par12
 cCodLoc_De  := mv_par13 //CIBELE CRIEI A PERGUNTA NO DICIONARIO
 cCodLoc_Ate := mv_par14

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Montar o aHeader das despesas         ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 aCampos  := {"GE5_IDMARC", "GE5_VALDES", "GCZ_NRFATU", "GE5_DATDES", "GBH_NOME", "GE5_CODDES", "B1_DESC", "GE5_CODLOC", "GE5_CODCRM", "RA_NOME", "GCZ_REGATE", "GCZ_NRSEQG", "GCZ_NRGUIA", "GE5_SEQDES"}
 aHeadGe5 := FS_GerHead(aCampos, aHeadGe5)
 nUGe5    := len(aCampos)

 aCampos  := {"GE6_IDMARC", "GE6_VALDES", "GCZ_NRFATU", "GE6_DATDES", "GBH_NOME", "GE6_CODDES", "GAA_DESC", "GE6_CODLOC", "GE6_CODCRM", "RA_NOME", "GCZ_REGATE", "GCZ_NRSEQG", "GCZ_NRGUIA", "GE6_SEQDES"}
 aHeadGe6 := FS_GerHead(aCampos, aHeadGe6)
 nUGe6    := len(aCampos)

 aCampos  := {"GE7_IDMARC", "GE7_VALDES", "GCZ_NRFATU", "GE7_DATDES", "GBH_NOME", "GE7_CODDES", "GA7_DESC", "GE7_CODLOC", "GE7_CODCRM", "RA_NOME", "GCZ_REGATE", "GCZ_NRSEQG", "GCZ_NRGUIA", "GE7_SEQDES"}
 aHeadGe7 := FS_GerHead(aCampos, aHeadGe7)
 nUGe7    := len(aCampos)

 nGE5_CODCRM := aScan(aHeadGe5, {| aVet | AllTrim(aVet[2]) == "GE5_CODCRM"})
 nGE5_CODLOC := aScan(aHeadGe5, {| aVet | AllTrim(aVet[2]) == "GE5_CODLOC"})
 nGE5_IDMARC := aScan(aHeadGe5, {| aVet | AllTrim(aVet[2]) == "GE5_IDMARC"})
 nGE5_SEQDES := aScan(aHeadGe5, {| aVet | AllTrim(aVet[2]) == "GE5_SEQDES"})
 nGE5_TIPO   := aScan(aHeadGe5, {| aVet | AllTrim(aVet[2]) == "TIPO"})
 nGE5_VALOR  := aScan(aHeadGe5, {| aVet | AllTrim(aVet[2]) == "GE5_VALDES"})

 nGE6_CODCRM := aScan(aHeadGe6, {| aVet | AllTrim(aVet[2]) == "GE6_CODCRM"})
 nGE6_CODLOC := aScan(aHeadGe6, {| aVet | AllTrim(aVet[2]) == "GE6_CODLOC"})
 nGE6_IDMARC := aScan(aHeadGe6, {| aVet | AllTrim(aVet[2]) == "GE6_IDMARC"})
 nGE6_SEQDES := aScan(aHeadGe6, {| aVet | AllTrim(aVet[2]) == "GE6_SEQDES"})
 nGE6_TIPO   := aScan(aHeadGe6, {| aVet | AllTrim(aVet[2]) == "TIPO"})
 nGE6_VALOR  := aScan(aHeadGe6, {| aVet | AllTrim(aVet[2]) == "GE6_VALDES"})

 nGE7_CODCRM := aScan(aHeadGe7, {| aVet | AllTrim(aVet[2]) == "GE7_CODCRM"})
 nGE7_CODLOC := aScan(aHeadGe7, {| aVet | AllTrim(aVet[2]) == "GE7_CODLOC"})
 nGE7_IDMARC := aScan(aHeadGe7, {| aVet | AllTrim(aVet[2]) == "GE7_IDMARC"})
 nGE7_SEQDES := aScan(aHeadGe7, {| aVet | AllTrim(aVet[2]) == "GE7_SEQDES"})
 nGE7_TIPO   := aScan(aHeadGe7, {| aVet | AllTrim(aVet[2]) == "TIPO"})
 nGE7_VALOR  := aScan(aHeadGe7, {| aVet | AllTrim(aVet[2]) == "GE7_VALDES"})

 aHeadGe5[nGe5_VALOR, 1] := STR0078 //"Valor"
 aHeadGe6[nGe6_VALOR, 1] := STR0078 //"Valor"
 aHeadGe7[nGe7_VALOR, 1] := STR0078 //"Valor"

 cSelIni := "GE5.GE5_CODLOC QRY_CODLOC, GE5.GE5_SEQDES QRY_SEQDES, GE5.GE5_DATDES QRY_DATDES, "
 cSelIni += "GCZ.GCZ_NOME, GE5.GE5_CODDES QRY_CODDES, GE5.GE5_CODCRM QRY_CODCRM, SRA.RA_NOME, GCZ.GCZ_REGATE, GCZ.GCZ_NRSEQG,  "
 cSelIni += "GCZ.GCZ_NRGUIA, GE5.GE5_CODPRE QRY_CODPRE, GE5.GE5_NREXTM NREXTMGE,"

 If !Empty(dDatAte_De) .and. !Empty(dDatAte_Ate)
  cCondGCZ += " AND GCZ.GCZ_DATATE BETWEEN '" + DTOS(dDatAte_De) + "' AND '" + DTOS(dDatAte_Ate) + "' "
 ElseIf !Empty(dDatAte_De) .and. Empty(dDatAte_Ate)
  cCondGCZ += " AND GCZ.GCZ_DATATE >= '" + DTOS(dDatAte_De) + "' "
 ElseIf Empty(dDatAte_De) .and. !Empty(dDatAte_Ate)
  cCondGCZ += " AND GCZ.GCZ_DATATE <= '" + DTOS(dDatAte_Ate) + "' "
 EndIf
 If !Empty(cCodCon_De) .and. !Empty(cCodCon_Ate)
  cCondGCZ += " AND GCZ.GCZ_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "
 Endif
 If !Empty(cRegGer)
  cCondGCZ += " AND GCZ.GCZ_REGGER = '" + cRegGer + "'"
 Endif
 If !Empty(cNrFatu)
  cCondGCZ += " AND GCZ.GCZ_NRFATU = '" + cNrFatu + "'"
 Endif

 AADD(aCondSql, {"GCZ", cCondGCZ})

 cCondGF += "      AND GF5.GF5_NREXTC BETWEEN '" + cNrExtC_De + "' AND '" + cNrExtC_Ate + "' "
 cCondGF += "      AND GF5.GF5_NREXTM = '" + SPACE(LEN(GDX->GDX_NREXTM)) + "' "
 cCondGF += "      AND GF5.GF5_CODCON BETWEEN '" + cCodCon_De + "' AND '" + cCodCon_Ate + "' "

 AADD(aCondSql, {"GF5", cCondGF})

 cWhere := " WHERE GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' " + ;
           " AND GE5.GE5_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' " + ;
           " AND GE5.GE5_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " + ;
           " AND GE5.GE5_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' " + ;
           " AND ((GE5.GE5_PGTMED = '2' AND GE0.GE0_STATUS IN ('2', '3')) OR (GE5.GE5_PGTMED = '3' AND GE0.GE0_STATUS = '3') " + ;
           "       OR (GE5.GE5_PGTMED = '1')) "

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฤฤฟ
//ณ Ponto de Entrada HSP34WHR para manipula็ใo do Where para verificar o itens  ณ
//ณ repassados - DENNIS - Chamado TPHXBQ                            			   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฤฤู
If Existblock("HSP34WHR")
	cWhere += ExecBlock("HSP34WHR",.F.,.F.,{cWhere})
Endif
 cJoinDes := " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD  =  GE5.GE5_CODDES "
 cJoinPct := " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD  =  GG5.GG5_CODDES "
 cSelect  := cSelIni + " GE5.GE5_IDMARC QRY_MARLAN, SB1.B1_DESC DESCRI "
 cOrderBy := " ORDER BY DESCRI, QRY_MARLAN, GCZ_NOME "
 FS_RetSQL("GE5", cSelect, aCondSql, cJoinDes, cJoinPct, cWhere, cOrderBy, aValMin, @aColGe5, .T.)
 If !Empty(aRecno)
  aRecnoGe5 := aClone(aRecno)
  aRecno := {}
 Endif
 cJoinDes := " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD =  GE6.GE6_CODDES "
 cJoinPct := " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL  = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD  =  GG6.GG6_CODDES "
 cSelect  := STRTRAN(cSelIni, "GE5", "GE6")
 cSelect  += " GE6.GE6_IDMARC QRY_MARLAN, GAA.GAA_DESC DESCRI "
 cCondGF  := STRTRAN(cCondGF, "GF5", "GF6")
 aCondSql := {}
 AADD(aCondSql, {"GCZ", cCondGCZ})
 AADD(aCondSql, {"GF6", cCondGF})
 cWhere   := STRTRAN(cWhere , "GE5", "GE6")
 cOrderBy := " ORDER BY DESCRI, QRY_MARLAN, GCZ_NOME "
 FS_RetSQL("GE6", cSelect, aCondSql, cJoinDes, cJoinPct, cWhere, cOrderBy, aValMin, @aColGe6, .T.)
 If !Empty(aRecno)
  aRecnoGe6 := aClone(aRecno)
  aRecno := {}
 Endif
 cJoinDes := " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_TIPPRO <> '9' "
 cJoinPct := " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GG7.GG7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSelect  := STRTRAN(cSelIni, "GE5", "GE7")
 cSelect  += " GE7.GE7_IDMARC QRY_MARLAN, GA7.GA7_DESC DESCRI "
 cCondGF  := STRTRAN(cCondGF, "GF6", "GF7")
 aCondSql := {}
 AADD(aCondSql, {"GCZ", cCondGCZ})
 AADD(aCondSql, {"GF7", cCondGF})
 cWhere   := STRTRAN(cWhere , "GE6", "GE7")
 cOrderBy := " ORDER BY DESCRI,  QRY_MARLAN, GCZ_NOME "
 FS_RetSQL("GE7", cSelect, aCondSql, cJoinDes, cJoinPct, cWhere, cOrderBy, aValMin, @aColGe7, .T.)
 If !Empty(aRecno)
  aRecnoGe7 := aClone(aRecno)
  aRecno := {}
 Endif

 If len(aColGe5) == 0 .And. len(aColGe6) == 0 .And. len(aColGe7) == 0
  HS_MsgInf(STR0012,STR0082,STR0013) //"Tabela de repasse vazia ou nenhum lancamento gerado para a selecao efetuada. Verifique!","Atencao","Extratos"
  DbSelectArea("QRY")
  DbCloseArea()
  Return()
 Endif
  aSize := MsAdvSize(.T.)
  aObjects := {}

  AAdd( aObjects, { 100, 030, .T., .T., .T. } )
  AAdd( aObjects, { 100, 070, .T., .T., .T. } )

  aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
  aPObjs := MsObjSize( aInfo, aObjects, .T. )

  aObjects := {}
  AAdd( aObjects, { 100, 100, .T., .T. } )

  aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
  aPGDs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0

  DEFINE MSDIALOG oDlgG TITLE OemToAnsi(STR0013) From aSize[7], 000 To aSize[6], aSize[5]	of oMainWnd PIXEL   //"Gerar Extrato"

  oCabec	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgG,,,,,, aPObjs[1, 3], aPObjs[1, 4])
  oCabec:Align := CONTROL_ALIGN_TOP

  @ 15,210 CheckBox oCbG Var lCbG Prompt STR0014 SIZE 50, 10 OF oCabec PIXEL On Click (FS_GMarcaT(lCbG)) //"Marca todos"

  @ 15,004 SAY OemToAnsi(STR0015) OF oCabec PIXEL COLOR CLR_BLUE //"Credito"
  @ 15,034 MSGET oValCre VAR nValCre PICTURE "@E 999,999,999.99" SIZE 60,10 OF oCabec PIXEL COLOR CLR_BLUE WHEN .F.

  @ 30,004 SAY OemToAnsi(STR0016) OF oCabec PIXEL COLOR CLR_RED //"Debito"
  @ 30,034 MSGET oValDeb VAR nValDeb PICTURE "@E 999,999,999.99" SIZE 60,10 OF oCabec PIXEL COLOR CLR_RED WHEN .F.

  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4]	 OF oDlgG PROMPTS STR0140, STR0141, STR0142 PIXEL
  oFolder:Align := CONTROL_ALIGN_ALLCLIENT


  oGE7G := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4],0 /*nOpc*/, , , ,"GE7_IDMARC", ,len(aColGe7), , , ,oFolder:aDialogs[1], aHeadGe7, aColGe7)
  oGE7G:oBrowse:BlDblClick := {|| FS_GMarca(oGE7G:oBrowse:nAt, nGE7_IDMARC, nGE7_TIPO, nGE7_VALOR, oGE7G)}
  oGe7G:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  oGE5G := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4],0 /*nOpc*/, , , ,"GE5_IDMARC", ,len(aColGe5), , , ,oFolder:aDialogs[2], aHeadGe5, aColGe5)
  oGE5G:oBrowse:BlDblClick := {|| FS_GMarca(oGE5G:oBrowse:nAt, nGE5_IDMARC, nGE5_TIPO, nGE5_VALOR, oGE5G)}
  oGe5G:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  oGE6G := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4],0 /*nOpc*/, , , ,"GE6_IDMARC", ,len(aColGe6), , , ,oFolder:aDialogs[3], aHeadGe6, aColGe6)
  oGE6G:oBrowse:BlDblClick := {|| FS_GMarca(oGE6G:oBrowse:nAt, nGE6_IDMARC, nGE6_TIPO, nGE6_VALOR, oGE6G)}
  oGe6G:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 ACTIVATE MSDIALOG oDlgG CENTERED ON INIT EnchoiceBar(oDlgG, {|| nOpcA := 1, oDlgG:End()}, {|| nOpcA := 0, oDlgG:End()})


 
 If nOpcA == 1
 
  If len(aRecnoGe5) == 0 .And. len(aRecnoGe6) == 0 .And. len(aRecnoGe7) == 0 
  	HS_MsgInf(STR0012,STR0082,STR0013) //"Tabela de repasse vazia ou nenhum lancamento gerado para a selecao efetuada. Verifique!","Atencao","Extratos"
  	Return()
  Endif
 
  FS_GerExt("GE5", oGE5G:aCols, aRecnoGe5, "4")
  FS_GerExt("GE6", oGE6G:aCols, aRecnoGe6, "5")
  FS_GerExt("GE7", oGE7G:aCols, aRecnoGe7, "0")
  While __lSx8
   ConfirmSx8()
  End
 Else
  While __lSx8
   RollBackSxe()
  End
 Endif
 nOpcA := 0

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GMarcaบ Autor ณ Cibele Peria       บ Data ณ  01/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca lancamento do faturamento                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GMarca(nMar, nIdMarc, nTipo, nValor, oObj)

 oObj:aCols[nMar,nIdMarc] := IIf(oObj:aCols[nMar,nIdMarc] == "LBNO","LBTIK","LBNO")
 If oObj:aCols[nMar,nIdMarc] == "LBNO"
  If ALLTRIM(oObj:aCols[nMar, nTipo]) == "CONTA"
   nValCre := nValCre - oObj:aCols[nMar, nValor]
  ElseIf ALLTRIM(oObj:aCols[nMar, nTipo]) == "GLOSA"
   nValDeb := nValDeb - oObj:aCols[nMar, nValor]
  Else
   nValCre := nValCre - oObj:aCols[nMar, nValor]
  Endif
  lCbG := .F.
  oCbG:Refresh()
 Else
  If ALLTRIM(oObj:aCols[nMar, nTipo]) = "CONTA"
   nValCre := nValCre + oObj:aCols[nMar, nValor]
  ElseIf ALLTRIM(oObj:aCols[nMar, nTipo]) == "GLOSA"
   nValDeb := nValDeb + oObj:aCols[nMar, nValor]
  Else
   nValCre := nValCre + oObj:aCols[nMar, nValor]
  Endif
 Endif
 oValCre:Refresh()
 oValDeb:Refresh()
 oObj:oBrowse:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GMarcaบ Autor ณ Cibele Peria       บ Data ณ  01/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca todos os repasses do browse                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GMarcaT(lMar)
 Local cVal := IIF(lMar, "LBTIK", "LBNO"), nForaCols := 0

 nValCre := 0
 nValDeb := 0

 For nForACols := 1 to len(oGe5G:aCols)
  If !Empty(oGe5G:aCols[nForACols,nGE5_Tipo])
   oGe5G:aCols[nForACols,nGE5_IDMARC] := cVal
   If lMar
    If ALLTRIM(oGe5G:aCols[nForACols,nGE5_Tipo]) == "CONTA"
     nValCre := nValCre + oGe5G:aCols[nForACols, nGE5_VALOR]
    ElseIf ALLTRIM(oGe5G:aCols[nForACols,nGE5_Tipo]) == "GLOSA"
     nValDeb := nValDeb + oGe5G:aCols[nForACols, nGE5_VALOR]
    Else
     nValCre := nValCre + oGe5G:aCols[nForACols, nGE5_VALOR]
    Endif
   Endif
  Endif
 Next

 For nForACols := 1 to len(oGe6G:aCols)
  If !Empty(oGe6G:aCols[nForACols,nGE6_Tipo])
   oGe6G:aCols[nForACols,nGE6_IDMARC] := cVal
  If lMar
    If ALLTRIM(oGe6G:aCols[nForACols,nGE6_Tipo]) == "CONTA"
     nValCre := nValCre + oGe6G:aCols[nForACols, nGE6_VALOR]
    ElseIf ALLTRIM(oGe6G:aCols[nForACols,nGE6_Tipo]) == "GLOSA"
     nValDeb := nValDeb + oGe6G:aCols[nForACols, nGE6_VALOR]
   Else
     nValCre := nValCre + oGe6G:aCols[nForACols, nGE6_VALOR]
    Endif
   Endif
  Endif
 Next

 For nForACols := 1 to len(oGe7G:aCols)
  If !Empty(oGe7G:aCols[nForACols,nGE7_Tipo])
   oGe7G:aCols[nForACols,nGE7_IDMARC] := cVal
  If lMar
    If ALLTRIM(oGe7G:aCols[nForACols,nGE7_Tipo]) == "CONTA"
     nValCre := nValCre + oGe7G:aCols[nForACols, nGE7_VALOR]
    ElseIf ALLTRIM(oGe7G:aCols[nForACols,nGE7_Tipo]) == "GLOSA"
     nValDeb := nValDeb + oGe7G:aCols[nForACols, nGE7_VALOR]
   Else
     nValCre := nValCre + oGe7G:aCols[nForACols, nGE7_VALOR]
    Endif
   Endif
  Endif
 Next

 oValCre:Refresh()
 oValDeb:Refresh()
 oGE7G:oBrowse:Refresh()
 oGE6G:oBrowse:Refresh()
 oGE5G:oBrowse:Refresh()
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_GerExtบ Autor ณ Cibele Peria       บ Data ณ  01/02/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava o extrato                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerExt(cAlias, aCols, aRecDes, nTipMov)
 Local nFor1 := 0, nFor2 := 0, aCodCRM := {}, aAtualiza := {}, nPosCRM := 0
 Local cExtCre := "", cExtDeb := "", cAliasGF := "GF" + SUBSTR(cAlias, 3,1), cAliasGG := "GG" + SUBSTR(cAlias, 3,1)


 For nFor1 := 1 to len(aCols)
  If aCols[nFor1,&("n" + cAlias + "_IdMarc")] == "LBTIK"
   nPosCRM := aScan(aCodCRM, {| aVet | aVet[1] == aCols[nFor1, &("n" + cAlias + "_CodCrm")] .AND. aVet[2] == aCols[nFor1, &("n" + cAlias + "_CodLoc")]})
   If nPosCRM == 0
    aADD(aCodCRM, {aCols[nFor1,&("n" + cAlias + "_CodCrm")], aCols[nFor1,&("n" + cAlias + "_CodLoc")], 0, 0 })
    aAdd(aAtualiza, {})
    nPosCRM := len(aCodCRM)
   Endif
   If ALLTRIM(aCols[nFor1, &("n" + cAlias + "_Tipo")]) == "GLOSA"
    aCodCRM[nPosCRM, 4] += aCols[nFor1, &("n" + cAlias + "_Valor")]
   Else
    aCodCRM[nPosCRM, 3] += aCols[nFor1, &("n" + cAlias + "_Valor")]
   Endif
   aAdd(aAtualiza[nPosCRM], {aRecDes[nFor1], aCols[nFor1, &("n" + cAlias + "_Tipo")]})
  Endif
 Next

 If len(aCodCRM) == 0 .And. SUBSTR(cAlias,3,1) == "7"
  HS_MsgInf(STR0017,STR0082,STR0013) //"Pelo menos um lancamento de repasse deve ser selecionado para a geracao do extrato","Atencao","Extratos"
  Return()
 Endif

 ProcRegua(len(aCodCRM))
 For nFor1 := 1 to len(aCodCRM)
  IncProc(STR0018 + aCodCRM[nFor1,1] + STR0019) //"Gerando lancamento de extrato "###". Aguarde..."

  cExtCre := ""
  cExtDeb := ""

  DbSelectArea("GDX")
  Begin Transaction
   If aCodCRM[nFor1,3] > 0 //Credito
    M->GDX_NREXTM := HS_VSxeNum("GDX", "M->GDX_NREXTM", 1)
    cExtCre       := M->GDX_NREXTM

    RecLock("GDX", .T.)
     GDX->GDX_FILIAL := xFilial("GDX")
     GDX->GDX_NREXTM := cExtCre
     GDX->GDX_CODCRM := aCodCRM[nFor1, 1]
     GDX->GDX_CODLOC := aCodCRM[nFor1, 2]
     GDX->GDX_CODPRE := HS_RPreMed(aCodCRM[nFor1, 1],  aCodCRM[nFor1, 2])
     GDX->GDX_DATLAN := dDataBase
     GDX->GDX_TIPLAN := "1"    //Credito
     GDX->GDX_TIPMOV := nTipMov  //Producao
     GDX->GDX_VALLAO := aCodCRM[nFor1, 3]
     GDX->GDX_VALLAN := aCodCRM[nFor1, 3]
     GDX->GDX_HISLAN := FS_HisLan("P", cNrFatu, IIF(cNrExtC_De==cNrExtC_Ate, cNrExtC_De, ""))
     GDX->GDX_LOGARQ := HS_LogArq()
    MsUnlock()
   EndIf

   If aCodCRM[nFor1,4] > 0  //Debito
    M->GDX_NREXTM := HS_VSxeNum("GDX", "M->GDX_NREXTM", 1)
    cExtDeb       := M->GDX_NREXTM

    RecLock("GDX", .T.)
     GDX->GDX_FILIAL := xFilial("GDX")
     GDX->GDX_NREXTM := cExtDeb
     GDX->GDX_CODCRM := aCodCRM[nFor1, 1]
     GDX->GDX_CODLOC := aCodCRM[nFor1, 2]
     GDX->GDX_CODPRE := HS_RPreMed(aCodCRM[nFor1, 1],  aCodCRM[nFor1, 2])
     GDX->GDX_DATLAN := dDataBase
     GDX->GDX_TIPLAN := "0"    //Debito
     GDX->GDX_TIPMOV := nTipMov  //Producao
     GDX->GDX_VALLAO := aCodCRM[nFor1, 4]
     GDX->GDX_VALLAN := aCodCRM[nFor1, 4]
     GDX->GDX_HISLAN := FS_HisLan("P", cNrFatu, IIF(cNrExtC_De==cNrExtC_Ate, cNrExtC_De, ""))
     GDX->GDX_LOGARQ := HS_LogArq()
    MsUnlock()
   Endif

   For nFor2 := 1 to len(aAtualiza[nFor1])
    If ALLTRIM(aAtualiza[nFor1, nFor2, 2]) == "CONTA"
     DbSelectArea(cAlias)//GE7
     DbSetOrder(1)
     DbGoTo(aAtualiza[nFor1, nFor2, 1])
     RecLock(cAlias, .F.)
      &(cAlias + "->" + cAlias + "_NREXTM") := cExtCre
     MsUnLock()
    ElseIf ALLTRIM(aAtualiza[nFor1, nFor2, 2]) $ "GLOSA/RECURSO"
     DbSelectArea(cAliasGF)
     DbSetOrder(1)
     DbGoTo(aAtualiza[nFor1, nFor2, 1])
    	RecLock(cAliasGF, .F.)
      &(cAliasGF + "->" + cAliasGF + "_NREXTM") := IIF(ALLTRIM(aAtualiza[nFor1, nFor2, 2]) == "GLOSA", cExtDeb, cExtCre)
     MsUnlock()
    Else //PACOTE
     DbSelectArea(cAliasGG)
     DbGoTo(aAtualiza[nFor1, nFor2, 1])
 	   RecLock(cAliasGG, .F.)
      &(cAliasGG + "->" + cAliasGG + "_NREXTM") := cExtCre
     MsUnlock()
    Endif

   Next nFor2

   ConfirmSx8()
  End Transaction

 Next nFor1

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_HisLanบ Autor ณ Cibele Peria       บ Data ณ  16/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Monta o historico do lancamento                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_HisLan(cTipHis, cPar01, cPar02)
 Local cAliasOld := Alias()
 Local cHist     := ""

 If cTipHis == "P"   //Producao
  If !Empty(cPar01)
   cHist := STR0109 + cPar01 + STR0020  //"Titulo"###"Pacientes Diversos"
  ElseIf !Empty(cPar02)
   cHist := STR0021 + cPar02 + STR0020  //"Ext.Conv: "###"/ Pacientes Diversos"
  Else
   cHist := STR0022 + Posicione("GBH", 1, xFilial("GBH")+cRegGer, "GBH_NOME") //"Paciente: "
  Endif

 ElseIf cTipHis == "M" //Producao por Pagamento Minimo
  cHist := STR0148 + Substr(cPar01, 5, 2) + "/" + Substr(cPar01, 1, 4) + "-" + Posicione("GCS", 1, xFilial("GCS")+cPar02, "GCS_NOMLOC") //"PRODUCAO "

 ElseIf cTipHis == "PL" //Plantao
  cHist := STR0149 + cPar01 //"PLANTAO "
 Endif

 DbSelectArea(cAliasOld)
Return(cHist)

/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_AvuM34 บ Autor ณ PAULO JOSE         บ Data ณ  20/10/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ DITACAO DE UM LANCAMENTO.                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_AvuM34(cAlias, nReg, nOpc)
 Local lRet    := .T.
 Local aHGDX   := {}
 Local aCGDX   := {}
 Local nUGDX   := 0
 Local aCpoEnchoice  :={}
 Local aCpoEdita     := {}
 Local oEncGcy
 Local nOpcE   := aRotina[nOpc, 4]
 Local lHSAVUM34		:= FindFunction("U_HSAVUM34")		// Verifica a existencia do ponto de entrada
 Local aAreaPE		:= {}
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}

 Private aTela := {}
 Private aGets := {}
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek(cAlias)
 While !Eof() .And. (x3_arquivo == cAlias)

  If cNivel < x3_Nivel
   DbSkip()
   Loop
  Endif

  If (nOpCE == 3 .and. X3USO(x3_usado) .and. x3_campo # "GDX_CODCPG") .or. ;
     (nOpCE == 4 .and. (X3USO(x3_usado) .or. x3_campo $ ("GDX_MOTALT/GDX_USUALT/GDX_DATALT/GDX_HORALT")))
   AADD(aCpoEnchoice, x3_campo)
  Endif

  DbSkip()
 End

 RegToMemory(cAlias, (nOpcE==3))

 DEFINE MSDIALOG oDlgGDX TITLE OemToAnsi(STR0023) From aSize[ 7 ],000 to  ROUND(aSize[ 6 ] / 16,0) , ROUND(aSize[ 5 ]/8,0) of oMainWnd   //"Lancamento"

  oEncGDX := MsMGet():New(cAlias, nReg, nOpcE,,,, aCpoEnchoice, {aPObjs[1,1], aPObjs[1,2], aPObjs[1,3], aPObjs[1,4]}, , 3,,,, oDlgGDX,,, .F.,, .F.)

  nOpcA := 0
 ACTIVATE MSDIALOG oDlgGDX CENTERED ON INIT EnchoiceBar(oDlgGDX, {|| nOpcA := 1, IIf( Obrigatorio(aGets, aTela) .and. HS_VExM34(nOpcE)	, oDlgGDX:End(), nOpcA := 0)}, {|| nOpcA := 0, oDlgGDX:End()})

If nOpca == 1
	DbSelectArea(cAlias)

	If nOpc == 3 //Inclusao
	//   M->GDX_NREXTM := CriaVar("GDX_NREXTM")
		M->GDX_NREXTM := HS_VSxeNum("GDX", "M->GDX_NREXTM", 1)
		RecLock(cAlias, .T.)
		HS_GRVCPO(cAlias)
		GDX->GDX_VALLAO := GDX->GDX_VALLAN
		GDX->GDX_TIPMOV := "1" //"Avulso"
		MsUnlock()

		//Ponto de entrada, executado ap๓s a grava็ใo do lan็amento avulso em Extrato M้dico.

		If lHSAVUM34
			aAreaPE	:= GetArea()
			U_HSAVUM34(M->GDX_NREXTM)
			RestArea(aAreaPE)
		EndIf

		While __lSx8
		ConfirmSx8()
		End

	Else //Alteracao
		If M->GDX_VALLAN <> GDX->GDX_VALLAN
			RecLock(cAlias, .F.)
			GDX->GDX_VALLAN := M->GDX_VALLAN
			GDX->GDX_MOTALT := M->GDX_MOTALT
			GDX->GDX_USUALT := cUserName
			GDX->GDX_DATALT := dDataBase
			GDX->GDX_HORALT := Time()
			GDX->GDX_LOGARQ := HS_LogArq()
			MsUnlock()
		Endif

	Endif

Else
	If nOpc == 3
		While __lSx8
		RollBackSx8()
		End
	Endif

EndIf

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VExM34 บ Autor ณ Cibele Peria       บ Data ณ 07/06/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da inclusao de um lancamento avulso ou da altera บฑฑ
ฑฑบ          ณ cao do valor.                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VExM34(nOpcE)
 Local lRet := .T.

 If M->GDX_VALLAN <= 0
  HS_MsgInf(STR0102,STR0082,STR0026) //"Valor do lancamento invalido para o tipo informado","Atencao","Lancamento Avulso"
  lRet := .F.

 ElseIf Empty(M->GDX_MOTALT) .and. nOpcE == 4 //Somente se for alteracao.
  HS_MsgInf(STR0108,STR0082,STR0026) //"Informe o motivo da alteracao do valor do lancamento","Atencao","Lancamento Avulso"
  lRet := .F.

 Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldM34 บ Autor ณ Cibele Peria       บ Data ณ 30/06/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da digitacao dos campos                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_VldM34()
 Local cAliasOld := Alias()
 Local lRet      := .T.

 If ReadVar() == "M->GDX_CODCRM"
  If Empty(M->GDX_CODCRM)
   HS_MsgInf(STR0036,STR0082,STR0118) //"Informe o codigo do profissional","Atencao" //"Digitacao dos campos"
   lRet := .F.
  Else
   DbSelectArea("GBJ")
   DbSetOrder(1)
   If !DbSeek(xFilial("GBJ") + M->GDX_CODCRM)
    HS_MsgInf(STR0074,STR0082,STR0118) //"Codigo invalido","Atencao" //"Digitacao dos campos"
    lRet := .F.
   Else
    M->GDX_NOMCRM := Posicione("SRA", 11, xFilial("SRA") + M->GDX_CODCRM, "RA_NOME")
    If !Empty(M->GDX_CODLOC)
     M->GDX_CODPRE := HS_RPreMed(M->GDX_CODCRM, M->GDX_CODLOC)
     M->GDX_NOMPRE := Posicione("GAZ", 1, xFilial("GAZ") + M->GDX_CODPRE, "GAZ_FANPRE")
    Endif
   Endif
  EndIf

 ElseIf ReadVar() == "M->GDX_CODLOC"
  If Empty(M->GDX_CODLOC)
   HS_MsgInf(STR0110,STR0082,STR0118) //"Informe o Codigo do Setor","Atencao" //"Digitacao dos campos"
   lRet := .F.
  Else
   DbSelectArea("GCS")
   DbSetOrder(1)
   If !DbSeek(xFilial("GCS") + M->GDX_CODLOC)
    HS_MsgInf(STR0074,STR0082,STR0118) //"Codigo Invalido","Atencao" //"Digitacao dos campos"
    lRet := .F.
   Else
    If !Empty(M->GDX_CODCRM)
     M->GDX_NOMCRM := Posicione("SRA", 11, xFilial("SRA") + M->GDX_CODCRM, "RA_NOME")
     M->GDX_CODPRE := HS_RPreMed(M->GDX_CODCRM, M->GDX_CODLOC)
     M->GDX_NOMPRE := Posicione("GAZ", 1, xFilial("GAZ")+M->GDX_CODPRE, "GAZ_FANPRE")
    Endif
   Endif
  EndIf

 Endif

 DbSelectArea(cAliasOld)
Return(lRet)

//////////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PlaM34 บ Autor ณ Cibele Peria       บ Data ณ 31/05/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Geracao dos lancamentos referentes aos plantoes medicos    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_PlaM34(cAlias, nReg, nOpc)
Local dDatSis     := dDataBase
Local cHorSis     := Time()
Local cRefer      := ""
Local cCodPre_De  := ""
Local cCodPre_Ate := ""
Local cCodCRM_De  := ""
Local cCodCRM_Ate := ""
Local cCodSet_De  := ""
Local cCodSet_Ate := ""
Local cAnoMes     := ""
Local cSQL        := ""
Local cCodPre     := ""
Local cCodSet     := ""
Local cCodCRM     := ""
Local cCtrLoc     := ""
Local nVlrDiu     := 0
Local nVlrNot     := 0
Local nVlrFer     := 0
Local nFatorH     := 0
Local	nFator      := 0
Local lRet        := .T.
Local cMens       := ""
Local dDatRef     := CTOD(SPACE(8)) // Data para fechamento
Local dDatFech    := CTOD(SPACE(8)) // ูltima data de fechamento
Local aCampos     := {}
Local cTabela     := ""
Local cAliasTmp   := ""
Local cIndTmp     := ""
Local aTitulos    := {}
Local aLbTit      := {}
Local aRetTit     := {}
Local cTitulo     := ""
Local nTit        := 0
Local nPosTit     := 0
Local cHist       := ""
Local cVigenc     := ""
Local i           := 0
Local nDiasPlant  := 0
Local aEscalaPl   := {}
Local nValor      := 0 // Valor por prestador
Local nValorPlt   := 0 // Valor por plantใo
Local nVrDiur     := 0
Local nVrNotu     := 0
Local nVrFeri     := 0
Local nAcertado   := 0
Local oTempTable
Local lHsp34Vlr   := ExistBlock("HSP34VLR")
Private nQtHDiur  := 0
Private nQtHNotu  := 0
Private nQtHFeri  := 0

// Verifica o Parโmetro do prefixo do contas a pagar
If 	len(AllTrim(GetMV("MV_PREFCPH"))) > len(SE2->E2_PREFIXO)
	HS_MsgInf(STR0128,STR0082,STR0107) //"Parโmetro do prefixo do contas a pagar ้ invแlido (MV_PREFCPH)","Atencao","Plantao Medico"
	Return()
Endif

// Verifica se os parโmetros do Inicio e Fim do horแrio Diurno estใo corretos
If !HS_VldHA32(Alltrim(GetMV("MV_INIDIA"))) .Or. !HS_VldHA32(Alltrim(GetMV("MV_FIMDIA")))
	HS_MsgInf(STR0129,STR0082,STR0107) //"Os parโmetros de Inํcio/Fim do Horแrio Diurno estใo invแlidos (MV_INIDIA/MV_FIMDIA)","Atencao","Plantao Medico"
	Return()
ElseIf GetMV("MV_INIDIA") > GetMV("MV_FIMDIA")
	HS_MsgInf(STR0130,STR0082,STR0107) //"Os parโmetros de Inํcio/Fim do Horแrio Diurno estใo invแlidos (MV_INIDIA estแ posterior a MV_FIMDIA)","Atencao","Plantao Medico"
	Return()
Endif

If !Pergunte("HSM34P",.T.)
	Return()
EndIf
dDatRef     := mv_par01
cCodPre_De  := mv_par02
cCodPre_Ate := mv_par03
cCodCRM_De  := mv_par04
cCodCRM_Ate := mv_par05
cCodSet_De  := mv_par06
cCodSet_Ate := mv_par07

cHist       := FS_HisLan("PL", DTOC(dDatRef))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Selecao dos plantoes                                                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

// Status GN4: 1-troca 2-falta 3-cancelado
cSQL :="	SELECT  "
cSQL +="		GN3.GN3_CODLOC, "
cSQL +="		GN4.GN4_DATINI, "
cSQL +="		GN4.GN4_HORINI, "
cSQL +="		GN4.GN4_DATFIN, "
cSQL +="		GN4.GN4_HORFIN, "
cSQL +="		GN4.GN4_CODCRM, "
// Guardando os dados para salvar os dados do extrato no GN4
cSQL +="		GN4.GN4_FILIAL, "
cSQL +="		GN4.GN4_NRSEQE, "
cSQL +="		GN4.GN4_NRSEQP, "
//
cSQL +="		GBJ.GBJ_CODPRE, "
cSQL +="		GAZ.GAZ_CTRLOC, "
cSQL +="		GAZ.GAZ_VLRDIU, "
cSQL +="		GAZ.GAZ_VLRNOT, "
cSQL +="		GAZ.GAZ_VLRFER, "
cSQL +="		GAZ.GAZ_FATORH, "
cSQL +="		CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END CODPREST "
cSQL +=" FROM    "
cSQL +="		" + RetSQLName("GN4") + " GN4 "
cSQL +="		INNER JOIN"
cSQL +="			" + RetSQLName("GN3") + " GN3  ON GN3.GN3_NRSEQP = GN4.GN4_NRSEQP "
cSQL +="						AND GN3.GN3_FILIAL = '" + xFilial("GN3") + "' "
cSQL +="						AND GN3.D_E_L_E_T_ <> '*'"
cSQL +="		INNER JOIN"
cSQL +="			" + RetSQLName("SRA") + " SRA  ON GN4.GN4_CODCRM = SRA.RA_CODIGO "
cSQL +="						AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
cSQL +="						AND SRA.D_E_L_E_T_ <> '*'"
cSQL +="		LEFT JOIN"
cSQL +="			" + RetSQLName("GFE") + " GFE  ON GFE.GFE_CODCRM=GN4.GN4_CODCRM  AND GFE.GFE_CODLOC=GN4.GN4_CODLOC"
cSQL +="						AND GFE.GFE_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "'"
cSQL +="						AND GFE.GFE_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "'"
cSQL +="						AND GFE.GFE_FILIAL = '" + xFilial("GFE") + "' "
cSQL +="						AND GFE.D_E_L_E_T_ <> '*'"
cSQL +="		INNER JOIN"
cSQL +="			" + RetSQLName("GBJ") + " GBJ	ON GBJ.GBJ_STATUS = '1' "
cSQL +="						AND GBJ.GBJ_CRM = SRA.RA_CODIGO "
cSQL +="						AND GBJ.GBJ_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "'
cSQL +="						AND GBJ.GBJ_CRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "'"
cSQL +="						AND GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' "
cSQL +="						AND GBJ.D_E_L_E_T_ <> '*'"
cSQL +="		INNER JOIN"
cSQL +="			" + RetSQLName("GAZ") + " GAZ  ON GAZ.GAZ_CODPRE = CASE WHEN GFE.GFE_CODPRE IS NULL THEN GBJ.GBJ_CODPRE ELSE GFE.GFE_CODPRE END "
cSQL +="						AND GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' "
cSQL +="						AND GAZ.D_E_L_E_T_ <> '*'"
cSQL +=""
cSQL +=" WHERE "
cSQL +="		GN4.GN4_FILIAL = '" + xFilial("GN4") + "' "
cSQL +="		AND GN4.D_E_L_E_T_ <> '*'"
cSQL +="		AND GN4.GN4_DATINI <= '" + DTOS(dDatRef) + "'"   // Considera somente a data inicial.
cSQL +="		AND GN4.GN4_NREXTM = ' '"   // Considera somente os que nใo foram lan็ados.
cSQL +="		AND GN3.GN3_CODLOC BETWEEN '" + cCodSet_De + "' AND '" + cCodSet_Ate + "'"
cSQL +="		AND GN4.GN4_STATUS <> '2' "
cSQL +="		AND GN4.GN4_STATUS <> '3' "
If HS_ExisDic({{"C", "GN4_GERVAL"}}, .F.)
	cSQL +="  AND GN4.GN4_GERVAL <> '0' "
EndIf
cSQL +=" ORDER BY GBJ.GBJ_CODPRE, GN3.GN3_CODLOC, GN4.GN4_CODCRM "
//HS_MsgInf(cSQL)

cSQL := ChangeQuery(cSQL)
TCQUERY cSQL NEW ALIAS "TMPQRY"
TCSetField("TMPQRY", "GN4_DATINI" ,"D")
TCSetField("TMPQRY", "GN4_DATFIN" ,"D")
DbSelectArea("TMPQRY")
DbGoTop()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Geracao do arquivo temporario com os lancamentos medicos                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAdd(aCampos, {"CODPRE", "C", LEN(GBJ->GBJ_CODPRE), 0} )
aAdd(aCampos, {"CODLOC", "C", LEN(GCS->GCS_CODLOC), 0} )
aAdd(aCampos, {"CODCRM", "C", LEN(GBJ->GBJ_CRM), 0} )
aAdd(aCampos, {"QTHDIU", "N", 10, 2} )
aAdd(aCampos, {"QTHNOT", "N", 10, 2} )
aAdd(aCampos, {"QTHFER", "N", 10, 2} )
aAdd(aCampos, {"VALOR" , "N", 10, 2} )

//--< Cria็ใo do objeto FWTemporaryTable >---
oTempTable := FWTemporaryTable():New( "LAN" )
oTempTable:SetFields( aCampos )
oTempTable:AddIndex( "INDREC",{ "CODPRE","CODLOC","CODCRM" } )

if( select( "LAN" ) > 0 )
	( "LAN" )->( dbCloseArea() )
endIf

oTempTable:Create()
LAN->( DbSetOrder(1) )

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Processamento dos apontamentos                                               ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("TMPQRY")
While !Eof()
	If TMPQRY->CODPREST <> cCodPre .or. TMPQRY->GN3_CODLOC <> cCodSet
		dDatFech := FS_Max("GEX_DATREF", "GEX", "GEX_CODPRE = '" + HS_RPreMed(TMPQRY->GN4_CODCRM, TMPQRY->GN3_CODLOC) + "' AND GEX_CODLOC = '" +  TMPQRY->GN3_CODLOC + "'")
		If !Empty(dDatFech) .and. dDatFech > DTOS(dDatRef)
			lRet := .F.
			HS_MsgInf(STR0105 + ; //"Os plantoes do Prestador/Setor "
			HS_RPreMed(TMPQRY->GN4_CODCRM, TMPQRY->GN3_CODLOC) + "/" +  TMPQRY->GN3_CODLOC + ;
			STR0106 + ; //" nao serao processados devido ao ultimo fechamento ter ocorrido em "
			Substr(dDatFech, 7, 2) + "/" + Substr(dDatFech, 5, 2)+ "/" + Substr(dDatFech, 3, 2),STR0082,STR0107) //,"Atencao","Plantao Medico"
			DbSelectArea("TMPQRY")
			DbCloseArea()

			if( select( "LAN" ) > 0 )
				oTempTable:delete()
			endIf

			Return()
		Else
			aAdd(aTitulos, {HS_RPreMed(TMPQRY->GN4_CODCRM, TMPQRY->GN3_CODLOC), TMPQRY->GN3_CODLOC, 0})
		Endif

		cCodPre := HS_RPreMed(TMPQRY->GN4_CODCRM, TMPQRY->GN3_CODLOC)
		cCodSet := TMPQRY->GN3_CODLOC

	Endif

	cCodCRM  := TMPQRY->GN4_CODCRM
	cCtrLoc  := TMPQRY->GAZ_CTRLOC
	nVlrDiu  := TMPQRY->GAZ_VLRDIU
	nVlrNot  := TMPQRY->GAZ_VLRNOT
	nVlrFer  := TMPQRY->GAZ_VLRFER
	nFatorH  := TMPQRY->GAZ_FATORH
	nValor   := 0
	DbSelectArea("TMPQRY")
	While !Eof() .and. TMPQRY->CODPREST == cCodPre .and. TMPQRY->GN3_CODLOC == cCodSet .and. TMPQRY->GN4_CODCRM == cCodCRM
		nQtHDiur := 0
		nQtHNotu := 0
		nQtHFeri := 0
		nValorPlt:= 0
		// O plantใo pode ser mais de um dia;
		// Identificar, cada dia, se  ้ feriado e acumular as horas de feriado;
		// Se nใo for feriado: identificar quantas horas diurnas e noturnas

		// Tem que pegar o feriado dentro do plantใo
		nDiasPlant := TMPQRY->GN4_DATFIN - TMPQRY->GN4_DATINI // Calcula quantos dias de plantใo (zero ้ apenas um dia)
		For i = 0 to nDiasPlant
			// Verifica se ้ feriado
			If HS_IsFreeDay(TMPQRY->GN4_DATINI+i)
				nAcertado:= FS_VerHora(TMPQRY->GN4_HORINI,TMPQRY->GN4_HORFIN)
				If nDiasPlant == 0 // Se for apenas um dia de servi็o
					// Fecha o dia
					nQtHFeri += ((HS_TimeStump(TMPQRY->GN4_DATFIN,TMPQRY->GN4_HORFIN)	- HS_TimeStump(TMPQRY->GN4_DATINI,TMPQRY->GN4_HORINI))/60/60)+ nAcertado  //+ nAcerto
				Else // Se for mais de um dia de servi็o
					If i == 0 // Se for o dia inicial
						nQtHFeri += ((HS_TimeStump(TMPQRY->GN4_DATINI,"23:59")	- HS_TimeStump(TMPQRY->GN4_DATINI,TMPQRY->GN4_HORINI))/60/60) + nAcertado //+ nAcerto
					ElseIf i == nDiasPlant // Se for o dia final
						nQtHFeri += ((HS_TimeStump(TMPQRY->GN4_DATFIN,TMPQRY->GN4_HORFIN)-HS_TimeStump(TMPQRY->GN4_DATFIN,"00:00"))	/60/60) + nAcertado //+ nAcerto
					Else // Senใo soma 24 horas
						nQtHFeri += 24
					Endif
				Endif

			Else // Se nใo for feriado

				If nDiasPlant == 0 // Se for apenas um dia de servi็o
					// Fecha o dia
					//nQtHDiur += (HS_TimeStump(TMPQRY->GN4_DATFIN,TMPQRY->GN4_HORFIN)	- HS_TimeStump(TMPQRY->GN4_DATINI,TMPQRY->GN4_HORINI))/60/60
					FS_NotDiu(TMPQRY->GN4_HORINI,TMPQRY->GN4_HORFIN)
				Else // Se for mais de um dia de servi็o
					If i == 0 // Se for o dia inicial
						//nQtHDiur += (HS_TimeStump(TMPQRY->GN4_DATINI,"24:00")	- HS_TimeStump(TMPQRY->GN4_DATINI,TMPQRY->GN4_HORINI))/60/60
						FS_NotDiu(TMPQRY->GN4_HORINI,"23:59")
					ElseIf i == nDiasPlant // Se for o dia final
						//nQtHDiur += (HS_TimeStump(TMPQRY->GN4_DATFIN,TMPQRY->GN4_HORFIN)-HS_TimeStump(TMPQRY->GN4_DATFIN,"00:00"))	/60/60
						FS_NotDiu("00:00",TMPQRY->GN4_HORFIN)
					Else // Senใo soma 24 horas
						//nQtHDiur += 24
						FS_NotDiu("00:00","23:59")
					Endif
				Endif

			Endif
		Next
		// Posiciona nos valores por setor
		If TMPQRY->GAZ_CTRLOC == "1" // Se for controle por setor
			lRet := .T.
			cVigenc := FS_Max("GEU_VIGENC", "GEU", "GEU_CODPRE = '" + TMPQRY->CODPREST + "' AND GEU_CODLOC = '" +  TMPQRY->GN3_CODLOC + "' AND GEU_VIGENC <= '" +  DTOS(TMPQRY->GN4_DATINI)/*DTOS(dDatRef)*/  + "'")
			If Empty(cVigenc)
				HS_MsgInf(STR0103 + ; //"Nao foram cadastrados os valores de plantao para o Prestador/Setor/Vig๊ncia "
				TMPQRY->CODPREST + "/" +  TMPQRY->GN3_CODLOC + ;
				STR0104,STR0082,STR0107) //". Processamento interrompido!","Atencao","Plantao Medico"
				DbSelectArea("TMPQRY")
				DbCloseArea()

				if( select( "LAN" ) > 0 )
					oTempTable:delete()
				endIf

				Return()
			Endif
			DbSelectArea("GEU")
			DbSetOrder(1)
			DbSeek(xFilial("GEU") + TMPQRY->CODPREST + TMPQRY->GN3_CODLOC + cVigenc)
			nValorPlt  +=IIF(nQtHDiur==0, 0, FS_ValPlan(nQtHDiur, GEU->GEU_VLRMAT, GEU->GEU_FATORH))
			nValorPlt  +=IIF(nQtHNotu==0, 0, FS_ValPlan(nQtHNotu, GEU->GEU_VLRNOT, GEU->GEU_FATORH))
			nValorPlt  +=IIF(nQtHFeri==0, 0, FS_ValPlan(nQtHFeri, GEU->GEU_VLRFER, GEU->GEU_FATORH))
			If lHsp34Vlr
				nValorPlt := ExecBlock("HSP34VLR",.F.,.F.,{nValorPlt})
			EndIf
			nVrDiur  := GEU->GEU_VLRMAT
			nVrNotu  := GEU->GEU_VLRNOT
			nVrFeri  := GEU->GEU_VLRFER
			nFator   := GEU->GEU_FATORH
		Else
			nValorPlt  +=IIF(nQtHDiur==0, 0, FS_ValPlan(nQtHDiur, nVlrDiu, nFatorH))
			nValorPlt  +=IIF(nQtHNotu==0, 0, FS_ValPlan(nQtHNotu, nVlrNot, nFatorH))
			nValorPlt  +=IIF(nQtHFeri==0, 0, FS_ValPlan(nQtHFeri, nVlrFer, nFatorH))
			If lHsp34Vlr
				nValorPlt := ExecBlock("HSP34VLR",.F.,.F.,{nValorPlt})
			EndIf
			nVrDiur  := nVlrDiu
			nVrNotu  := nVlrNot
			nVrFeri  := nVlrFer
			nFator   := nFatorH
		Endif
		nValor += nValorPlt
		// Guardando os dados para salvar os dados do extrato no GN4
		aAdd(aEscalaPl,{cCodCRM,TMPQRY->GN4_FILIAL,TMPQRY->GN4_NRSEQP,TMPQRY->GN4_NRSEQE,nVrDiur,nVrNotu,nVrFeri,nFator,nQtHDiur,nQtHNotu,nQtHFeri,dDatRef,nValorPlt,	TMPQRY->CODPREST})
		DbSelectArea("TMPQRY")
		DbSkip()
	End

	If nQtHDiur > 0 .or. nQtHNotu > 0 .or. nQtHFeri > 0
		DbSelectArea("LAN")
		RecLock("LAN", .T.)
		LAN->CODPRE := cCodPre
		LAN->CODLOC := cCodSet
		LAN->CODCRM := cCodCRM
		LAN->QTHDIU := nQtHDiur
		LAN->QTHNOT := nQtHNotu
		LAN->QTHFER := nQTHFeri
		LAN->VALOR  := nValor
		aTitulos[len(aTitulos), 3] += LAN->VALOR
		MsUnlock()
	Endif
	DbSelectArea("TMPQRY")
End

DbSelectArea("TMPQRY")
DbCloseArea()

If len(aTitulos) == 0
	HS_MsgInf(STR0092,STR0082,STR0107) //"Nenhum plantao foi apontado para a selecao efetuada","Atencao","Plantao Medico"
	if( select( "LAN" ) > 0 )
		oTempTable:delete()
	endIf
	Return()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Preparacao dos titulos a serem gerados                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cCodPre := "" //Obriga pegar Prestador e fornecedor
For nTit := 1 to len(aTitulos)

	If cCodPre <> aTitulos[nTit, 1]
		dbSelectArea("GAZ")
		dbSetOrder(1)

		If !dbSeek(xFilial("GAZ") + aTitulos[nTit, 1])
			HS_MsgInf(STR0127+"(Cod: "+cCodPre+")",STR0082,STR0107) //"Prestador nใo foi localizado","Atencao","Plantao Medico"
			if( select( "LAN" ) > 0 )
				oTempTable:delete()
			endIf
			Return()
		Endif


		DbSelectArea("SA2")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA2") + GAZ->GAZ_CODFOR + GAZ->GAZ_LOJA)
			HS_MsgInf(STR0132+cCodPre+STR0133,STR0082,STR0107) //"Fornecedor para este prestador (Cod: ",") nใo foi localizado","Atencao","Plantao Medico"
			if( select( "LAN" ) > 0 )
				oTempTable:delete()
			endIf
			Return()
		Endif

		cCodPre := aTitulos[nTit, 1]
	Endif

	aAdd(aLbTit, {	.T.                                  ,; //1 - .t. marcado .f. desmarcado
					Transform(aTitulos[nTit, 3], "@E 999,999.99") ,; //2 - valor do titulo dever ser caractere
					GAZ->GAZ_FANPRE                                ,; //3 - Nome fantasia do prestador - pode ser qualquer texto
					GAZ->GAZ_CODFOR                                ,; //4 - codigo do fornecedor
					GAZ->GAZ_LOJA                                  ,; //5 - loja do fornecedor
					SA2->A2_NATUREZ                                ,; //6 - natureza
					aTitulos[nTit, 1]                              ,; //7 - Codigo do Prestador - a partir do 7 item nao precisam estar no array
					aTitulos[nTit, 2]                              ,; //8 - Codigo do Setor
					""                                             ,; // nao usado
					""                                             ,; // nao usado
					aTitulos[nTit, 3]})                              // valor do titulo sem formatacao

Next nTit

aRetTit := FS_GTitP( aLbTit, STR0107) //, STR0107, cMV_PrefCPH )
If len(aRetTit) == 0
	if( select( "LAN" ) > 0 )
		oTempTable:delete()
	endIf
	Return()
Endif

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Geracao dos lancamentos medicos a partir dos titulos gerados                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Begin Transaction
For nTit := 1 to len(aLbTit)

	If !aLbTit[nTit, 1]
		Loop
	Endif

	cTitulo := FS_GeraTit(aLbTit[nTit], STR0107, cMV_PrefCPH, aRetTit )
	If Empty(cTitulo)
		DisarmTransaction()
		DbSelectArea("LAN")
		if( select( "LAN" ) > 0 )
			oTempTable:delete()
		endIf
		Return()
	Endif

	cCodPre := aLbTit[nTit, 7]
	cCodSet := aLbTit[nTit, 8]

	DbSelectArea("LAN")
	DbSetOrder(1)
	DbSeek(cCodPre + cCodSet)
	While !Eof() .and. LAN->CODPRE == cCodPre .and. LAN->CODLOC == cCodSet

		// Salvar o Extrato de Profissional
		DbSelectArea("GDX")
		RecLock("GDX", .T.)
		GDX->GDX_FILIAL := xFilial("GDX")
		GDX->GDX_NREXTM := HS_VSxeNum("GDX", "M->GDX_NREXTM", 1)
		GDX->GDX_CODCRM := LAN->CODCRM
		GDX->GDX_CODPRE := Hs_RPreMed(LAN->CODCRM,LAN->CODLOC)
		GDX->GDX_DATLAN := dDatSis
		GDX->GDX_TIPLAN := "1"    //Credito
		GDX->GDX_TIPMOV := "3"    //Plantao
		GDX->GDX_VALLAO := LAN->VALOR
		GDX->GDX_VALLAN := LAN->VALOR
		GDX->GDX_HISLAN := cHist
		GDX->GDX_CODCPG := cTitulo
		GDX->GDX_CODPRE := cCodPre
		GDX->GDX_CODLOC := cCodSet
		GDX->GDX_LOGARQ := HS_LogArq()
		MsUnlock()

		// Registrando o extrato na escala de plantใo
		DbSelectArea("GN4")
		DbSetOrder(1)
		For i := 1 to len(aEscalaPl)
			// Um lan็amento no extrato pode ter vแrios registros na escala de plantใo
			If aEscalaPl[i,1] == LAN->CODCRM //  Todos registros do mesmo profissional serแ do mesmo lan็amento no extrato
				If DbSeek(aEscalaPl[i,2] + aEscalaPl[i,3] + aEscalaPl[i,4])
					RecLock("GN4", .F.)
					GN4->GN4_NREXTM := GDX->GDX_NREXTM
					GN4->GN4_VLRDIU := aEscalaPl[i, 5]
					GN4->GN4_VLRNOT := aEscalaPl[i, 6]
					GN4->GN4_VLRFER := aEscalaPl[i, 7]
					GN4->GN4_FATORH := aEscalaPl[i, 8]
					GN4->GN4_QTDDIU := aEscalaPl[i, 9]
					GN4->GN4_QTDNOT := aEscalaPl[i,10]
					GN4->GN4_QTDFER := aEscalaPl[i,11]
					GN4->GN4_DATREF := aEscalaPl[i,12]
					GN4->GN4_VLRTOT := aEscalaPl[i,13]
					GN4->GN4_CODPRE := aEscalaPl[i,14]

					MsUnlock()
				Endif
			Endif
		Next

		DbSelectArea("LAN")
		DbSkip()
	End

	DbSelectArea("GEX")
	Reclock("GEX", .T.)
	GEX->GEX_FILIAL := xFilial("GEX")
	GEX->GEX_CODPRE := cCodPre
	GEX->GEX_CODLOC := cCodSet
	GEX->GEX_DATREF := dDatRef
	GEX->GEX_DATFEC := dDatSis
	GEX->GEX_HORFEC := cHorSis
	GEX->GEX_USUFEC := cUserName
	MsUnlock()

Next nTit

End Transaction

if( select( "LAN" ) > 0 )
	oTempTable:delete()
endIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Max    บ Autor ณ Cibele Peria       บ Data ณ 08/06/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorno o valor MAX                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
 Function FS_Max(cCampo, cAlias, cWhere, cRet, cGroup, cOrder )
 Local cAliasOld := Alias()
 Local cSQL      := ""
 Local cPref     := PrefixoCpo(cAlias)
 Local xRet
 Default cRet      := " "
 Default cGroup    := " "
 Default cOrder    := " "
 cSQL := "SELECT MAX(" + cCampo + ") AS MAXCPO" + IIf(Empty(cRet),"","," + cRet) + " "
 cSQL += "FROM " + RetSQLName(cAlias) + " "
 cSQL += "WHERE " + cPref + "_FILIAL = '" + xFilial(cAlias) + "' AND D_E_L_E_T_ <> '*' "
 If !Empty(cWhere)
  cSQL += "AND " + cWhere
 Endif
 If !Empty(cGroup)
  cSQL += " GROUP BY " + cGroup
  cSQL += " ORDER BY " + cOrder
 Endif
 cSQL := ChangeQuery(cSQL)
 DbUseArea(.T., "TOPCONN", TcGenQry(,,cSQL), "MAX", .F., .F.)

 DbSelectArea("MAX")
 DbGoTop()

// xRet := IIF(FUNNAME () <> "HSPAHP12", IIF(Eof(), "", MAX->MAXCPO),IIF(Eof(), "", MAX->MAXCOD))
 xRet := IIF(Eof(), "", IIf(!Empty(cRet),&("MAX->" + cRet),MAX->MAXCPO))  // Criada regra para trazer o valor e codigo " maximo "

 DbCloseArea()
 DbSelectArea(cAliasOld)

Return(xRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_MesAnt บ Autor ณ Cibele Peria       บ Data ณ 02/06/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna o mes anterior ao informado (formato AAAAMM)       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_MesAnt(cAnoMes, nFatorH)
 Local nMes    := Val(Substr(cAnoMes, 5, 2)) - 1
 Local nAno    := Val(Substr(cAnoMes, 1, 4))

 If nMes == 0
  nAno := nAno - 1
  nMes := 1
 Endif

Return(Str(nAno, 4) + StrZero(nMes, 2))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ValPlanบ Autor ณ Cibele Peria       บ Data ณ 02/06/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Calcula o valor do plantao, pelo numero de horas           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ValPlan(nHoras, nVlFHor, nFatorH)  // nHoras = quantidade de horas em decimais
																																																						// nVlFHor = Valor
																																																					 // nFatorH = quantidade de horas para o  valor
																																																					 // se nFatorH for zero  nVlFHor serแ por hora.

Return( ROUND(IIF(nFatorH > 0,	nHoras*(nVlFHor/nFatorH),	nHoras*nVlFHor),2))

//////////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_DetM34 บ Autor ณ Cibele Peria       บ Data ณ 03/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Detalhamento do lancamento do extrato para os registros    บฑฑ
ฑฑบ          ณ gerados a partir dos repasses medicos.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_DetM34(cAlias, nReg, nOpc)
 Local cAliasOld := Alias(), cLstCpo := "", nx := 0, nForCampos := 0
 Local cTitDlg, nToDlg
 Local aTabelas  := {}
 Local cAliasQry := ""
 Local aCampos
 Private aHGE7 := {},aHGE6 := {},aHGE5 := {}
 Private aGE5Cols := {}, aGE6Cols := {}, aGE7Cols := {}
 Private oValProc,oValMat,oValTax
 Private nValProc := 0,nValMat := 0,nValTax:= 0
 Private oDlgD, oGE7D, oCodCRM, oNomMed, oGE5D, oGE6D

 If (GDX->GDX_TIPMOV $ '1/3')
  HS_MsgInf(STR0143+HS_RDescrB("GDX_TIPMOV", GDX->GDX_TIPMOV)+STR0144,STR0082,STR0025) //"Atencao","Repasse Medico"
  Return()
 EndIf

 aAdd(aTabelas,{"GE5","GE5.GE5","GF5","GF5.GF5","aGE5Cols"," JOIN " + RetSQLName("SB1") + " SB1 ON SB1.B1_COD = GE5.GE5_CODDES AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*'"      , "GG5", "SB1.B1_DESC", "aHGE5","nValMat"})
 aAdd(aTabelas,{"GE6","GE6.GE6","GF6","GF6.GF6","aGE6Cols"," JOIN " + RetSQLName("GAA") + " GAA ON GAA.GAA_CODTXD = GE6.GE6_CODDES AND GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*'" , "GG6", "GAA.GAA_DESC", "aHGE6","nValTax"})
 aAdd(aTabelas,{"GE7","GE7.GE7","GF7","GF7.GF7","aGE7Cols"," JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*'" , "GG7", "GA7.GA7_DESC", "aHGE7","nValProc"})

 For nx := 1 to len(aTabelas)

  aCampos := {"GCZ_NRFATU", aTabelas[nx][1]+"_DATDES", "GBH_NOME", aTabelas[nx][1]+"_CODDES", SubStr(aTabelas[nx][8],5,Len(aTabelas[nx][8])), aTabelas[nx][1]+"_CODCRM", "RA_NOME", "GCZ_REGATE", "GCZ_NRSEQG", "GCZ_NRGUIA", aTabelas[nx][1]+"_VALDES", aTabelas[nx][1]+"_SEQDES", aTabelas[nx][1]+"_VALREP"}  //, "GF7_VLRGLO", "GF7_VLRREC"}

  &(aTabelas[nx][9]) := FS_GerHead(aCampos, &(aTabelas[nx][9]))

  cSelect := aTabelas[nx][2]+"_SEQDES, "+aTabelas[nx][2]+"_DATDES, GBH_NOME, "+aTabelas[nx][2]+"_CODDES, " + aTabelas[nx][8]+", "
  cSelect += aTabelas[nx][2]+"_CODCRM, SRA.RA_NOME, GCZ.GCZ_REGATE, GCZ.GCZ_NRSEQG, GCZ.GCZ_NRGUIA, "+aTabelas[nx][2]+"_VALDES, "
  cSelect += aTabelas[nx][2]+"_VALREP, "+aTabelas[nx][2]+"_VALDES"

  cFrom := " FROM " + RetSQLName(aTabelas[nx][3]) +" "+aTabelas[nx][3]
  cFrom += " JOIN " + RetSQLName(aTabelas[nx][1]) +" "+aTabelas[nx][1]+" ON "+aTabelas[nx][2]+"_SEQDES = "+aTabelas[nx][4]+"_SEQDES AND "+aTabelas[nx][2]+"_FILIAL = '" + xFilial(aTabelas[nx][1]) + "' AND "+aTabelas[nx][1]+".D_E_L_E_T_ <> '*'"
  cFrom += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = "+aTabelas[nx][4]+"_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'"
 cFrom += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*'"
  cFrom += aTabelas[nx][6] //Join Especifico
  cFrom += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO = "+aTabelas[nx][2]+"_CODCRM  AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'"

 If GDX->GDX_TIPLAN = "0"  //Debito
  cSQL := "SELECT 'GLOSA' AS TIPO, GCZ.GCZ_NRFATU AS FATURA, " + cSelect + ", "+aTabelas[nx][4]+"_VLRGLO AS VALOR"
  cSQL += cFrom
  cSQL += " WHERE "+aTabelas[nx][4]+"_FILIAL = '" + xFilial(aTabelas[nx][3]) + "' AND "+aTabelas[nx][3]+".D_E_L_E_T_ <> '*'"
  cSQL += " AND "+aTabelas[nx][4]+"_NREXTM = '" + GDX->GDX_NREXTM + "'"
  cSQL += " ORDER BY 9, 4, 7"
 Else
  cSQL := "SELECT 'REPASSE' AS TIPO, GCZ.GCZ_NRFATU AS FATURA, " + cSelect + ", "+aTabelas[nx][2]+"_VALREP AS VALOR"
  cSQL += " FROM " + RetSQLName(aTabelas[nx][1]) + " " + aTabelas[nx][1]
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = "+aTabelas[nx][2]+"_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'"
  cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*'"
  cSQL += aTabelas[nx][6]
  cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO = "+aTabelas[nx][2]+"_CODCRM  AND SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'"
  cSQL += " WHERE "+aTabelas[nx][2]+"_FILIAL = '" + xFilial(aTabelas[nx][1]) + "' AND "+aTabelas[nx][1]+".D_E_L_E_T_ <> '*'"
  cSQL += " AND "+aTabelas[nx][2]+"_NREXTM = '" + GDX->GDX_NREXTM + "'"
  cSQL += IIF(aTabelas[nx][1] == "GE7"," AND GA7.GA7_TIPPRO <> '9'","")
  cSQL += " UNION "
  cSQL += "SELECT 'RECUP.' AS TIPO, GF0.GF0_NRFATU AS FATURA, " + cSelect + ", "+aTabelas[nx][4]+"_VLRREC AS VALOR"
  cSQL += cFrom
  cSQL += " JOIN " + RetSQLName("GF0") + " GF0 ON GF0.GF0_NUMREC = "+aTabelas[nx][4]+"_NRRECO AND GF0.GF0_FILIAL = '" + xFilial("GF0") + "' AND GF0.D_E_L_E_T_ <> '*'"
  cSQL += " WHERE "+aTabelas[nx][4]+"_FILIAL = '" + xFilial(aTabelas[nx][3]) + "' AND "+aTabelas[nx][3]+".D_E_L_E_T_ <> '*'"
  cSQL += " AND "+aTabelas[nx][4]+"_NREXTM = '" + GDX->GDX_NREXTM + "'"
  cSQL += IIF(aTabelas[nx][1] == "GE7"," AND GA7.GA7_TIPPRO <> '9'","")
  cSelect         := STRTRAN(cSelect, aTabelas[nx][1], aTabelas[nx][7])
  aTabelas[nx][6] := STRTRAN(aTabelas[nx][6], aTabelas[nx][1], aTabelas[nx][7])
  aTabelas[nx][2] := STRTRAN(aTabelas[nx][2], aTabelas[nx][1], aTabelas[nx][7])
  cSQL += " UNION "
  cSQL += "SELECT 'PACOTE' AS TIPO, GCZ.GCZ_NRFATU AS FATURA, " + cSelect + ", "+ aTabelas[nx][2]+"_VLRREC AS VALOR"
  cSQL += " FROM " + RetSQLName(aTabelas[nx][3]) + " " + aTabelas[nx][3]
  cSQL += " JOIN " + RetSQLName(aTabelas[nx][7]) + " "+ aTabelas[nx][7]+" ON "+ aTabelas[nx][2]+"_SEQDES = "+ aTabelas[nx][4]+"_SEQDES AND "+ aTabelas[nx][2]+"_FILIAL = '" + xFilial(aTabelas[nx][7]) + "' AND "+ aTabelas[nx][7]+".D_E_L_E_T_ <> '*'"
  cSQL += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = "+ aTabelas[nx][2]+"_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*'"
  cSQL += " JOIN " + RetSQLName("GBH") + " GBH ON GBH.GBH_CODPAC = GCZ.GCZ_REGGER AND GBH.GBH_FILIAL = '" + xFilial("GBH") + "' AND GBH.D_E_L_E_T_ <> '*'"
  cSQL += aTabelas[nx][6]
  cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO = "+aTabelas[nx][2]+"_CODCRM  AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*'"
  cSQL += " WHERE "+aTabelas[nx][4]+"_FILIAL = '" + xFilial(aTabelas[nx][3]) + "' AND "+aTabelas[nx][3]+".D_E_L_E_T_ <> '*'"
  cSQL += " AND "+aTabelas[nx][2]+"_NREXTM = '" + GDX->GDX_NREXTM + "'"
  cSQL += " ORDER BY 9, 4, 7"
 Endif
 aTabelas[nx][6] := STRTRAN(aTabelas[nx][6], aTabelas[nx][7], aTabelas[nx][1])
 aTabelas[nx][2] := STRTRAN(aTabelas[nx][2], aTabelas[nx][7], aTabelas[nx][1])

 cSQL :=  ChangeQuery(cSQL)

 TCQUERY cSQL NEW ALIAS "QRY"

 DbSelectArea("QRY")
 DbGoTop()

  cAliasQry := "QRY->"+aTabelas[nx][1]

  While !Eof()
   aAdd(&(aTabelas[nx][5]), {QRY->TIPO, QRY->FATURA, STOD(&(cAliasQry+"_DATDES")), QRY->GBH_NOME, &(cAliasQry+"_CODDES"), &("QRY->"+SubStr(aTabelas[nx][8],5,Len(aTabelas[nx][8]))), &(cAliasQry+"_CODCRM"), QRY->RA_NOME, QRY->GCZ_REGATE, QRY->GCZ_NRSEQG, QRY->GCZ_NRGUIA, &(cAliasQry+"_VALDES"), &(cAliasQry+"_SEQDES"), QRY->VALOR,.F.}) //GE7_VALREP, QRY->GF7_VLRGLO, QRY->GF7_VLRREC})
   &(aTabelas[nx][10]) += QRY->VALOR
   DbSkip()
  End

  DbSelectArea("QRY")
  DbCloseArea()

 Next nx

 If Len(aGE5Cols) == 0 .And. Len(aGE6Cols) == 0 .And. Len(aGE7Cols) == 0
  HS_MsgInf(STR0024,STR0082,STR0025) //"Nenhum lancamento de despesa foi selecionado. Verifique!","Atencao","Repasse Medico"
  Return()
 Endif

 aSize := MsAdvSize(.T.)
 aObjects := {}

 AAdd( aObjects, { 100, 035, .T., .T. } )
 AAdd( aObjects, { 100, 057, .T., .T., .T. } )
 AAdd( aObjects, { 100, 008, .T., .T., .T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 nOpcA := 0
 cTitDlg := IIF(GDX->GDX_TIPMOV == "0", STR0025, STR0026) //"Lancamento de Repasse Medico"###"Lancamento Avulso"
 DEFINE MSDIALOG oDlgD TITLE OemToAnsi(cTitDlg) From aSize[7], 000 To aSize[6], aSize[5]	of oMainWnd PIXEL

 oGDX := MsMGet():New("GDX", GDX->(RecNo()),nOpc,,,,, {aPObjs[1, 1], aPObjs[1, 2], aPObjs[1, 3], aPObjs[1, 4]},,,,,, oDlgD)
 oGDX:oBox:align:= CONTROL_ALIGN_TOP

 @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Of oDlgD PIXEL Prompts STR0140, STR0141, STR0142
 oFolder:Align := CONTROL_ALIGN_ALLCLIENT

 //Procedimentos
 oGE7D := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],,,,,,,,,,, oFolder:aDialogs[1], aHGE7, aGE7Cols)
 oGE7D:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 //Mat/Med
 oGE5D := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],,,,,,,,,,, oFolder:aDialogs[2], aHGE5, aGE5Cols)
 oGE5D:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
 //TaxaDiarias
 oGE6D := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4],,,,,,,,,,, oFolder:aDialogs[3], aHGE6, aGE6Cols)
 oGE6D:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

 oPanel1       :=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oDlgD,,,,,, aPObjs[3, 3], aPObjs[3, 4])
 oPanel1:Align := CONTROL_ALIGN_BOTTOM
 @ 04,002 SAY OemToAnsi(STR0145+STR0140) OF oPanel1 PIXEL COLOR CLR_BLUE //Total###Procedimentos
 @ 03,070 MSGET oValProc VAR nValProc PICTURE "@E 999,999,999.99" SIZE 60,10 OF oPanel1 PIXEL COLOR CLR_BLUE WHEN .F.

 @ 04,202 SAY OemToAnsi(STR0145+STR0141) OF oPanel1 PIXEL COLOR CLR_BLUE//Total###Materiais/Mediccamentos
 @ 03,270 MSGET oValMat VAR nValMat PICTURE "@E 999,999,999.99" SIZE 60,10 OF oPanel1 PIXEL COLOR CLR_BLUE WHEN .F.

 @ 04,402 SAY OemToAnsi(STR0145+STR0142) OF oPanel1 PIXEL COLOR CLR_BLUE //Total###Taxas/Diarias
 @ 03,470 MSGET oValTax VAR nValTax PICTURE "@E 999,999,999.99" SIZE 60,10 OF oPanel1 PIXEL COLOR CLR_BLUE WHEN .F.

 ACTIVATE MSDIALOG oDlgD CENTERED ON INIT EnchoiceBar(oDlgD, {|| nOpcA := 0, oDlgD:End()}, {|| nOpcA := 0, oDlgD:End()})
 DbSelectArea(cAliasOld)

Return()

/////////////////////////////////////////////////////////////////////////////
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_ExcM34 บ Autor ณ Cibele Peria       บ Data ณ 03/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Exclusao de um lancamento do extrato                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_ExcM34(cAlias, nReg, nOpc)
Local cParc      := ""
Local aNrExtM    := {}
Local nCont      := 0, nOpcA := 0
Local aHGDX      := {}, aCGDX := {}, nUGDX := 0
Local nGDXNREXTM := 0
Local oGDX, oEncSE2
Local aAreaOld   := GetArea()
Local cImpostos	 := MVTAXA + "|" + MVTXA + "|" + MVIRF + "|" + MVINSS + "|" + MVCOFINS + "|" + MVPIS + "|" + MVCS + "|" + MVISS + "|" + MVABATIM
Local dData		   := CtoD("  /  /  ")
Local lTudoOk    := .F.
Local lOk        := .T. 
If GDX->GDX_TIPMOV == "0" .and. GDX->GDX_TIPLAN = "0"
	HS_MsgInf(STR0028,STR0082,STR0119) //"Lancamento de debito de glosa nao pode ser excluido isoladamente. Verifique!","Atencao" //"Exclusao de um lancamento do extrato"
	Return()
Endif
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฤฤฟ
//ณ Ponto de Entrada HSP34VXM Validar se o registro selecionado pode ser excluํdo.
// O retorno do Ponto de Entrada serแ T = True ou F = False. //Chamado TPWONM
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฤฤู
If Existblock("HSP34VXM")
	 lTudoOk := ExecBlock("HSP34VXM",.F.,.F.)
	If !lTudoOk
        Return()
	Endif
Endif

If Empty(GDX->GDX_CODCPG)
	AADD(aNrExtM, GDX->GDX_NREXTM)

Else //Ja possui titulo gerado no financeiro
	cParc := FS_Ret1Prc(cMV_PrefCPH, GDX->GDX_CODCPG)

	DbSelectArea("SE2")
	DbSetOrder(1) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	If !DbSeek(xFilial("SE2") + cMV_PrefCPH + GDX->GDX_CODCPG + cParc)
		HS_MsgInf(STR0152 + GDX->GDX_CODCPG + STR0153, STR0082, STR0048) //"Tํtulo ["###"] nใo encontrado no Contas a Pagar"###"Aten็ใo"###"Titulos Contas a Pagar"
		Return()

	ElseIf ROUND(SE2->E2_SALDO,2) + ROUND(SE2->E2_SDACRES,2)  == 0
		HS_MsgInf(STR0152 + GDX->GDX_CODCPG + STR0154, STR0082, STR0048)//"Tํtulo ["###"] jแ baixado no Contas a Pagar"###"Aten็ใo"###"Titulos Contas a Pagar"
		Return()

	Else//monta tela com os dados do titulo e os extrato associados
		While !SE2->(Eof()) .And. SE2->E2_FILIAL == xFilial("SE2") .And. SE2->E2_PREFIXO == cMV_PrefCPH .And. SE2->E2_NUM == GDX->GDX_CODCPG .And. SE2->E2_PARCELA == cParc
			If SE2->E2_TIPO $ cImpostos
				SE2->(DbSkip())
			Else
				Exit
			EndIf
		End
		HS_BDados("GDX" , @aHGDX, @aCGDX, @nUGDX, 1,, "GDX->GDX_CODCPG == '" + SE2->E2_NUM + "' ")
		nGDXNREXTM := aScan( aHGDX, {|x|x[2] == "GDX_NREXTM"} )

		aObjects  := {}
		aSize := MsAdvSize(.T.)
		AAdd( aObjects, { 100, 50, .t., .t. } ) /*EnchoiceBar*/
		AAdd( aObjects, { 100, 50, .t., .t., .t. }) /* Folder */

		aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
		aPObj    := MsObjSize( aInfo, aObjects, .T. )

		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } ) /* Getdados dentro do Folder */
		aInfo    := { 0, 0, aPObj[2,3], aPObj[2,4],0,0 }
		aPFol    := MsObjSize( aInfo, aObjects )

		Define MsDialog oDlg From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel

			oEncSE2 := MsMGet():New("SE2", SE2->(RecNo()), 1,,,,, aPObj[1],, 2,,,, oDlg)
			oEncSE2:oBox:align:= CONTROL_ALIGN_ALLCLIENT

			@ aPObj[2,1],aPObj[2,2] Folder oFolder Size aPObj[2,3], aPObj[2,4] Of oDlg PROMPTS "Extratos" Pixel
			oFolder:Align := CONTROL_ALIGN_BOTTOM

			oGDX := MsNewGetDados():New(aPFol[1,1], aPFol[1,2], aPFol[1,3], aPFol[1,4], 0,,,,,,,,,, oFolder:aDialogs[1], aHGDX, aCGDX)
			oGDX:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

		Activate Dialog oDlg on init EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()},{|| nOpcA := 0, oDlg:End()} )

		If nOpcA == 0
			Return()
		EndIf

		For nCont := 1 To Len(oGDX:aCols)
			AADD(aNrExtM, oGDX:aCols[nCont, nGDXNREXTM])
		Next

	EndIf

Endif

Begin Transaction

	If Empty(GDX->GDX_CODCPG)
		axDeleta(cAlias, nReg, nOpc, "HS_LibRep(GDX->GDX_NREXTM)")
	Else
		If nOpcA == 1 .And. !FS_ExclTit(SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_TIPO)
			DisarmTransaction()
			lOk := .F.
		EndIf
    If lOk
      If ExistBlock("HSPHM34EX")
        ExecBlock("HSPHM34EX",.F.,.F.)
      EndIf

      For nCont := 1 To Len(aNrExtM)
        DbSelectArea("GDX")
        DbSetOrder(1) //GDX_FILIAL+GDX_NREXTM
        If DbSeek(xFilial("GDX") + aNrExtM[nCont])
          HS_LibRep(GDX->GDX_NREXTM)

          If HS_ChkInd("GN4", 3)
            dData := FS_DelReg(GDX->GDX_NREXTM)

            FS_DelGEX(GDX->GDX_CODPRE, GDX->GDX_CODLOC, dData)
          EndIf

          RecLock("GDX", .F., .T.)
            DbDelete()
          MsUnlock()
        EndIf
      Next
      HS_MsgInf(STR0156,STR0082,STR0001) //"Extrato e tํtulo excluํdos com sucesso!","Atencao","Extrato Medico"
    EndIf
	EndIf
End Transaction

RestArea(aAreaOld)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_LibRep บ Autor ณ Cibele Peria       บ Data ณ 03/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Libera os registro de repasse relacionados ao lancamento   บฑฑ
ฑฑบ          ณ do extrato excluido                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_LibRep(cNrExtM)
Local aAreaOld	:= GetArea(),  nForGG := 0, nRecNo := 0
Local aVet		:= {{"GE5", 6,"GF5", 7, "GG5"},{"GE6", 6,"GF6", 7, "GG6"},{"GE7", 5,"GF7", 5, "GG7"}}
Local nx 		:= 0
Local cPrefGE	:= ""
Local cPrefGF	:= ""
Local cPrefGG	:= ""
Local lControl	:= .F.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Vai pesquisar todas as contas relacionadas ao extrato, liberar estas contas, ณ
//ณ identificar os lancamentos do extrato de glosa de cada conta e liberar estes ณ
//ณ tambem.                                                                      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

For nx := 1 to Len(aVet)
	cPrefGE := aVet[nx][1]+"->"+aVet[nx][1]
	cPrefGF := aVet[nx][3]+"->"+aVet[nx][3]
	cPrefGG := aVet[nx][5]+"->"+aVet[nx][5]

	DbSelectArea(aVet[nx][1])
	DbSetOrder(aVet[nx][2])
	DbSeek(xFilial(aVet[nx][1]) + cNrExtM)
	ProcRegua(10)
	lControl := .F.
	While !Eof()// .and. &(cPrefGE+"_NREXTM") == cNrExtM
		If lControl
			DbGoTop()
			DbSeek(xFilial(aVet[nx][1]) + cNrExtM)
		EndIf
		If !Eof() .and. &(cPrefGE+"_NREXTM") == cNrExtM
			RecLock(aVet[nx][1], .F.)
				&(cPrefGE+"_NREXTM") := SPACE(LEN(&(cPrefGE+"_NREXTM")))
			MsUnlock()
			lControl	:= .T.
		EndIf
		&(aVet[nx][1])->(DbSkip())
	End//While GE

	DbSelectArea(aVet[nx][3])
	DbSetOrder(aVet[nx][4])
	DbSeek(xFilial(aVet[nx][3]) + cNrExtM)
	ProcRegua(10)
	lControl := .F.
	While !Eof()// .and. &(cPrefGF+"_NREXTM") == cNrExtM
		If lControl
			DbGoTop()
			DbSeek(xFilial(aVet[nx][3]) + cNrExtM)
		EndIf
		If !Eof() .and. &(cPrefGF+"_NREXTM") == cNrExtM
			RecLock(aVet[nx][3], .F.)
				&(cPrefGF+"_NREXTM") := SPACE(LEN(&(cPrefGF+"_NREXTM")))
			MsUnlock()
			lControl := .T.
		EndIf
		&(aVet[nx][3])->(DbSkip())
	End//While GF

	DbSelectArea(aVet[nx][5])
	DbSetOrder(5)
	DbSeek(xFilial(aVet[nx][5]) + cNrExtM)
	ProcRegua(10)
	lControl := .F.
	While !Eof()// .and. &(cPrefGG+"_NREXTM") == cNrExtM
		If lControl
			DbGoTop()
			DbSeek(xFilial(aVet[nx][5]) + cNrExtM)
		EndIf
		If !Eof() .AND. &(cPrefGG+"_NREXTM") == cNrExtM
			RecLock(aVet[nx][5], .F.)
				&(cPrefGG+"_NREXTM") := SPACE(LEN(&(cPrefGG+"_NREXTM")))
			MsUnlock()
			lControl := .T.
		EndIf
		&(aVet[nx][5])->(DbSkip())
	End//While GG
Next nx

RestArea(aAreaOld)
Return()

/////////////////////////////////////////////////////////////////////////////

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  | HS_ExtM34บ Autor ณ Gilson da Silva    บ Data ณ 03/02/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera Extratos                                              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar  (Agenda Ambulatorial)                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_ExtM34(cAlias, nReg, nOpc)
 Local cCodCRM  := ""
 Local cDatDeD
 Local cDatDeA
 Local nTitulo  := 0
 Local cNomMed  := ""
 Local cChave   := ""
 Local cCond    := ""
 Local cLstCpo  := ""
 Local aArea    := GetArea()
 Local nValLan  := 0
 Local nTotCred := 0
 Local nTotDeb  := 0
 Local nSaldo   := 0
 Local nCont    := 0
 Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}

 Private aHeader      := {}
 Private aCols        := {}
 Private nUsado       := 0
 Private nGDX_NREXTM  := 0
 Private nGDX_TIPLAN  := 0
 Private nGDX_VALLAN  := 0
 Private oGDXG
 Private oDlGdx
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

 If !Pergunte("HSM34H",.T.)
   Return()
  EndIf

 cCodCRM	:= GDX->GDX_CODCRM
 cDatDeD := DTOS(mv_par01)
 cDatDeA := DTOS(mv_par02)
 nTitulo := mv_par03

// If !lCtrGera
  If Empty(cDatDeD)
   HS_MsgInf(STR0034,STR0082,STR0013) //"Informe a data inicial do periodo desejado","Atencao"
   Return()
  Endif
  If Empty(cDatDeA)
   HS_MsgInf(STR0035,STR0082,STR0013) //"Informe a data final do periodo desejado","Atencao"
   Return()
  Endif

  If Empty(cCodCRM)
   HS_MsgInf(STR0036,STR0082,STR0013) //"Informe o codigo do medico","Atencao"
  Endif
// Endif

 cNomMed := Posicione("SRA", 11, xFilial("SRA") + GDX->GDX_CODCRM, "RA_NOME")

 cChave := GDX->GDX_CODCRM

 #IFDEF TOP
 	cCond  := "GDX->GDX_DATLAN >= '" + cDatDeD + "'"
  cCond  += " .and. GDX->GDX_DATLAN <= '" + cDatDeA + "'"
 #ELSE
 	cCond  := "DTOS(GDX->GDX_DATLAN) >= '" + cDatDeD + "'"
  cCond  += " .and. DTOS(GDX->GDX_DATLAN) <= '" + cDatDeA + "'"
 #ENDIF
 cCond  += " .and. GDX->GDX_CODCRM == '" + cCodCRM + "'"

 If nTitulo == 1
	 cCond  += " .and. GDX->GDX_CODCPG <> '" + Space(Len(GDX->GDX_CODCPG)) + "'"
	ElseIf nTitulo == 2
	 cCond  += " .and. GDX->GDX_CODCPG == '" + Space(Len(GDX->GDX_CODCPG)) + "'"
	EndIf

 If nTitulo == 2
  cCpoNao  := "GDX_CODCRM/GDX_NOMCRM/GDX_TIPMOV/GDX_HISLAN/GDX_CODCPG"
 Else
  cCpoNao  := "GDX_CODCRM/GDX_NOMCRM/GDX_TIPMOV/GDX_HISLAN"
 EndIf

 HS_BDados("GDX", @aHeader, @aCols, @nUsado, 2, cChave, cCond,,,,, cCpoNao)
 nGDX_NREXTM := aScan(aHeader, {| aVet | aVet[2] == "GDX_NREXTM"})
 nGDX_TIPLAN := aScan(aHeader, {| aVet | aVet[2] == "GDX_TIPLAN"})
 nGDX_VALLAN := aScan(aHeader, {| aVet | aVet[2] == "GDX_VALLAN"})

 If len(aCols) == 0 .or. (len(aCols) == 1 .and. Empty(aCols[1,nGDX_NREXTM]))
//  If !lCtrGera
   HS_MsgInf(STR0037,STR0082,STR0013) //"Nenhum lancamento gerado para a selecao efetuada. Verifique!","Atencao"
//  Endif
  Return()
 Endif

 For nCont:= 1  To Len(aCols)
  If aCols[nCont, nGDX_TipLan] == "1"  //Credito
   nTotCred += aCols[nCont, nGDX_ValLan]
  Else
   nTotDeb  += aCols[nCont, nGDX_ValLan]
  EndIf
 Next
 nSaldo :=  nTotCred - nTotDeb

 nOpcA := 0
 DEFINE MSDIALOG oDlGdx TITLE OemToAnsi(STR0038) From aSize[ 7 ],000 to  aSize[ 6 ]/1.2  , aSize[ 5 ]/1.2	of oMainWnd pixel   //"Extrato do Medico"

  @ aPObjs[1,1],004 SAY OemToAnsi(STR0039) OF oDlGdx PIXEL COLOR CLR_BLUE //"Medico"
  @ aPObjs[1,1],064 MSGET oCodCrm VAR GDX->GDX_CODCRM PICTURE "@!" SIZE 30,10 OF oDlGdx PIXEL COLOR CLR_BLUE WHEN .F.
  @ aPObjs[1,1],100 MSGET oNomMed VAR cNomMed PICTURE "@!" SIZE 140,10 OF oDlGdx PIXEL COLOR CLR_BLUE WHEN .F.
  @ aPObjs[1,3]-85,004 SAY OemToAnsi(STR0040) OF oDlGdx PIXEL COLOR CLR_BLUE    //"Total Creditos"
  @ aPObjs[1,3]-85,044 MSGET oValCred VAR nTotCred PICTURE "@E 999,999.9999" SIZE 60,10 OF oDlGdx PIXEL COLOR CLR_BLUE WHEN .F.
  @ aPObjs[1,3]-85,120 SAY OemToAnsi(STR0041) OF oDlGdx PIXEL COLOR CLR_BLUE    //"Total Debitos"
  @ aPObjs[1,3]-85,160 MSGET oValDeb VAR nTotDeb PICTURE "@E 999,999.9999" SIZE 60,10 OF oDlGdx PIXEL COLOR CLR_BLUE WHEN .F.
  @ aPObjs[1,3]-85,240 SAY OemToAnsi(STR0042) OF oDlGdx PIXEL COLOR CLR_BLUE    //"Saldo"
  @ aPObjs[1,3]-85,264 MSGET oSaldo VAR nSaldo PICTURE "@E 999,999.9999" SIZE 60,10 OF oDlGdx PIXEL COLOR CLR_BLUE WHEN .F.

  oGDXG := MsGetDados():New(aPObjs[1,1]+15, aPObjs[1,2], aPObjs[1,3]-100, aPObjs[1,4]-100, nOpc, , ,"",.F.,,,,len(aCols))

 ACTIVATE MSDIALOG oDlGdx CENTERED ON INIT EnchoiceBar(oDlGdx, {|| nOpcA := 0, oDlGdx:End()}, {|| nOpcA := 0, oDlGdx:End()})
 nOpcA := 0
 RestArea(aArea)
Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CPgM34 บ Autor ณ PAULO JOSE         บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ FUNCAO QUE MONTA A TELA PARA ESCOLHER QUAIS EXTRATOS       บฑฑ
ฑฑบ          ณ PARA CRIAR OS TITULOS NO CONTAS A PAGAR                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_CPgM34(cAlias, nReg, nOpc)
Local lFica       := .T.
Local lSel        := .F.
Local aHGDX       := {}
Local aCGDX       := {}
Local nUGDX       := 0
Local nGDX_OK     := 0
Local cFiltro     := " "
Local cMarca      := "IIf(EMPTY(GDX->GDX_OK),'LBTIK','LBNO')"
Local cCond       := ""
Local cCodPre_De  := ""
Local cCodPre_Ate := ""
Local dDatLan_De  := ""
Local dDatLan_Ate := ""
Local cCodCRM     := ""
Local cIdApre     := ""
Local nLenGDX     := 0
Local nForM34     := 0
Local aColsGD     := aClone(aCGDX)  //, aColsCod := {}
//Variaveis utilizadas para posicionamento e dimensao dos objetos da Enchoice
Local aSize  := {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}
Local lEnchBar := .T.
Local lPadrao := .F.

Private oDlgGDX, oCBMar, lCBMar, oTotLan, oTotLanMar := .T.
Private aArea   := GetArea()
Private nTotLan :=0
Private nTotLanMar :=0
Private nGDXValLan  := 0

aSize := MsAdvSize(lEnchBar, lPadrao)

aObjects := {}

aAdd( aObjects, { 10, 10, .T., .F. } ) // CheckBox "Marca Todos"
aAdd( aObjects, { 10 , aSize [4] , .T., .T. } ) //MsNewGetDados da Tabela GDX
aAdd( aObjects, { 10, 10, .T., .F. } ) // Say "Total de registros:"
aAdd( aObjects, { 100, 10, .F., .F., .T. } ) // Get "Total de registros"
aAdd( aObjects, { 10, 10, .T., .F. } ) // Say "Total de registros marcados:"
aAdd( aObjects, { 100, 10, .F., .F., .T. } ) // Get "Total de registros marcados:"

aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

aPObjs := MsObjSize( aInfo, aObjects, .F.)
lFica := Pergunte("HSM34C")
While lFica
	lFica := .F.
	lSel  := .F.
  cCodPre_De  := mv_par01
  cCodPre_Ate := mv_par02
  dDatLan_De  := mv_par03
  dDatLan_Ate := mv_par04
  cCodCRM     := mv_par05
  cIdApre     := mv_par06

  If Empty(cCodPre_De) .and. Empty(cCodPre_Ate) .and. Empty(cCodCRM)
    HS_MsgInf(STR0043,STR0082,STR0120) //"Informe o intervalo do codigo do prestador ou o codigo do medico","Atencao" //"CRIAR OS TITULOS NO CONTAS A PAGAR"
    lFica := .T.
  ElseIf Empty(cCodPre_Ate) .and. Empty(cCodCRM)
    HS_MsgInf(STR0044,STR0082,STR0120) //"Informe o codigo final do intervalo de prestador","Atencao" //"CRIAR OS TITULOS NO CONTAS A PAGAR"
    lFica := .T.
  ElseIf Empty(dDatLan_De) .and. Empty(dDatLan_Ate)
    HS_MsgInf(STR0045,STR0082,STR0120) //"Informe o periodo da data de lancamento dos extratos","Atencao" //"CRIAR OS TITULOS NO CONTAS A PAGAR"
    lFica := .T.
  Else
    lSel := .T.
  Endif
End

If !lSel
	Return()
Endif

cCond := "GDX_NREXTM IN (SELECT GDX_NREXTM "
cCond += "FROM " + RetSQLName("GDX") + " "
cCond += "WHERE GDX_FILIAL = '" + xFilial("GDX") + "' AND D_E_L_E_T_ <> '*' "
cCond += "AND GDX_CODCPG = '" + SPACE(LEN(GDX->GDX_CODCPG)) + "' "
If !Empty(cCodCRM)
	cCond += " AND GDX_CODCRM = '" + cCodCRM + "' "
ElseIf !Empty(cCodPre_Ate)
	cCond += " AND GDX_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' "
Endif
If !Empty(dDatLan_De) .and. !Empty(dDatLan_Ate)
	cCond += " AND GDX_DATLAN BETWEEN '" + DTOS(dDatLan_De) + "' AND '" + DTOS(dDatLan_Ate) + "') "
ElseIf !Empty(dDatLan_De)
	cCond += " AND GDX_DATLAN >= '" + DTOS(dDatLan_De) + "') "
Else
	cCond += " AND GDX_DATLAN <= '" + DTOS(dDatLan_Ate) + "') "
Endif

nLenGDX := HS_BDados("GDX", @aHGDX, @aCGDX, @nUGDX, 1,, cCond ,,, + ;
"GDX_CODPRE/GDX_NOMPRE/GDX_CODLOC/GDX_NOMLOC/GDX_CODCRM/GDX_NOMCRM/GDX_VALLAN/GDX_DATLAN/GDX_TIPLAN/GDX_TIPMOV/GDX_NREXTM" ,,,,"GDX_OK", cMarca, .T.  )
nGDX_OK := aScan(aHGDX, {| aVet | aVet[2] == "GDX_OK    "})
nGDXValLan := aScan(aHGDX, {| aVet | aVet[2] == "GDX_VALLAN"})
nGDX_TIPLAN := aScan(aHGDX, {| aVet | aVet[2] == "GDX_TIPLAN"})

If nLenGDX == 0
	HS_MsgInf(STR0047,STR0082,STR0120) //"Nenhum lancamento de extrato foi encontrado para a selecao efetuada. Verifique!","Atencao" //"CRIAR OS TITULOS NO CONTAS A PAGAR"
	Return()
Endif

If cIdApre == 1
	DEFINE MSDIALOG oDlgGDX TITLE STR0001 From aSize[ 7 ],000 to  aSize[ 6 ] , aSize[ 5 ]	of oMainWnd  Pixel  //"Extrato medico"

	@ aPObjs[1,1] + 2 ,aPObjs[1,2] CheckBox oCBMar Var lCBMar Prompt STR0014 SIZE aPObjs[1,4], aPObjs[1,3] OF oDlgGDX PIXEL ; //"Marca todos"
	On Click (FS_CPMar(lCBMar, nGDX_OK))

	oGDGDX := MsNewGetDados():New( aPObjs[2,1], aPObjs[2,2], aPObjs[2,3], aPObjs[2,4], 1, , , , , , , , , , oDlgGDX , aHGDX, aCGDX )
	oGDGDX:oBrowse:BlDblClick := {|| FS_DblClk( oGDGDX, nGDX_OK,@aHGDX  ) }

	For nForM34:=1 to nLenGDX
		nTotLan+= oGDGDX:aCols[nForM34, nGDXVALLAN]
	Next

	For nForM34:=1 to nLenGDX
   		If oGDGDX:aCols[nForM34, nGDX_TIPLAN] == "1"//Credito
   			nTotLanMar := nTotLanMar + oGDGDX:aCols[nForM34, nGDXVALLAN]
   		ElseIf oGDGDX:aCols[nForM34, nGDX_TIPLAN] == "0"    //Debito
    		nTotLanMar := nTotLanMar - oGDGDX:aCols[nForM34, nGDXVALLAN]
   		Endif
	Next



	@ aPObjs[3,1]		,aPObjs[3,2] SAY OemToAnsi(STR0146) 										Size aPObjs[3,4],aPObjs[3,3] PIXEL COLOR CLR_BLACK OF oDlgGDX //Total de registros:
	@ aPObjs[4,1] -2	,aPObjs[4,2] MSGet oTotLan var nTotLan Picture "@E 9999,999,999.99" 		Size aPObjs[4,3],aPObjs[4,4] PIXEL COLOR CLR_BLACK OF oDlgGDX WHEN .F.
	@ aPObjs[5,1]   	,aPObjs[5,2] SAY OemToAnsi(STR0147) 										Size aPObjs[5,4],aPObjs[5,3] PIXEL COLOR CLR_BLACK OF oDlgGDX //Total de registros marcados:
	@ aPObjs[6,1] -2	,aPObjs[6,2] MSGet oTotLanMar var nTotLanMar Picture "@E 9999,999,999.99" 	Size aPObjs[6,3],aPObjs[6,4] PIXEL COLOR CLR_BLACK OF oDlgGDX WHEN .F.

	oTotLanMar:Refresh()

	nOpcA := 0

	ACTIVATE MSDIALOG oDlgGDX CENTERED ON INIT EnchoiceBar(oDlgGDX, {|| nOpcA := 1, oDlgGDX:End()}, {|| nOpcA := 0, oDlgGDX:End()} )
	If nOpca == 1
		FS_GrCPM34( oGDGDX:aCols, aHGDX )
	EndIf

Else
	FS_GrCPM34( aCGDX, aHGDX )
Endif

RestArea(aArea)

Return()

Static Function FS_CPMar(lMark, nPos)
Local cVal := IIF(lMark, "LBTIK", "LBNO"), nForACols := 0

nTotLanMar:=0

For nForACols := 1 to len(oGDGDX:aCols)
	oGDGDX:aCols[nForACols,nPos] := cVal
Next

If cVal="LBTIK"
	For nForACols:=1 to len(oGDGDX:aCols)
   		If oGDGDX:aCols[nForACols, nGDX_TIPLAN] == "1"//Credito
   			nTotLanMar := nTotLanMar + oGDGDX:aCols[nForACols, nGDXVALLAN]
   		ElseIf oGDGDX:aCols[nForACols, nGDX_TIPLAN] == "0"    //Debito
    		nTotLanMar := nTotLanMar - oGDGDX:aCols[nForACols, nGDXVALLAN]
   		Endif
	Next
Else
	nTotLanMar:=0
Endif

oTotLanMar:Refresh()
oGDGDX:oBrowse:Refresh()

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GrCPM34บ Autor ณ PAULO JOSE         บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_GrCPM34( aCGDX, aHGDX)
Local lRet       := .T.
//Local oDlgGDX
Local oLbx
Local cLbx       := " "
Local aLbTit     := {}
Local oTik       := LoadBitmap(GetResources(), "LBTIK")
Local oNo        := LoadBitmap(GetResources(), "LBNO")
Local nContFor   := 0
Local oVctoTit
Local oTipoTit
Local dVctoTit   := dDataBase
Local cTipoTit   := Space(Len(SE2->E2_TIPO))
Local cCod       := Space(Len(GAZ->GAZ_CODPRE))
Local aRetTit    := {}
Local cTitulo    := ""
Local lHspm34Tit := lHspm34Tit
Private aTotRM   := {}, aPrest := {}
Private aLanUsa  := {}  //Guarda os Lancamentos selecionados para geracao do titulo

Define FONT oFont NAME "Arial" //BOLD

aTotRM := {}
FS_TotRM( aCGDX, AHGDX )

If len(aTotRM) == 0
 Return(lRet)
Endif

 For nContFor := 1 To Len(aTotRM)

  aAdd(aLbTit, {IIf(aTotRM[nContFor][1]#0,.T.,.F.), ;
   					        TransForm(aTotRM[nContFor][1], "@E 999,999.99"), ;
                 aTotRM[nContFor][2]            , ; //3-Nome do prestador
                 aTotRM[nContFor][4]            , ; //4-Codigo do fornecedor
                 aTotRM[nContFor][5]            , ; //5-Loja
                 aTotRM[nContFor][6]            , ; //6-Natureza
                 aTotRM[nContFor][3]            , ; //7-Codigo do prestador
                 ""                             , ;
                 ""                             , ;
                 ""                             , ;
                 aTotRM[nContFor][1]	})
 Next
 aSort(aLbTit,,, {|X, Y| X[3] < Y[3]})

 aRetTit := FS_GTitP( aLbTit, STR0048)  //"Titulos no Contas a Pagar"

If EXISTBLOCK("HSP34NAT")
	aLbTit := ExecBlock("HSP34NAT",.F.,.F.,{aLbTit})
	If Valtype(aLbTit) <> "A"
		Return(.F.)
	Endif
Endif
 If Len(aRetTit) > 0
  Begin Transaction
  For nContFor := 1 to Len(aLbTit)

   cTitulo := FS_GeraTit(aLbTit[nContFor], STR0049, cMV_PrefCPH, aRetTit)
   If Empty(cTitulo)
    DisarmTransaction()
    Exit
   Endif

   DbSelectArea("GDX")
   DbSetOrder(1)
   nPos := aScan(aLanUsa, {| aVet | aVet[1] == aLbTit[nContFor,7] })
   if nPos > 0

    While ( nPos <= Len(aLanUsa) ) .And. ( aLanUsa[nPos,1] == aLbTit[nContFor,7] )

     If DbSeek(xFilial("GDX") + aLanUsa[nPos,2] )
      RecLock("GDX", .F.)
      GDX->GDX_CODCPG := cTitulo
      MsUnlock()
					If lHspm34Tit
						lRetorno := ExecBlock("HSPM34TIT",.F.,.F.,{cTitulo, GDX->GDX_NREXTM})
						If !lRetorno
							DisarmTransaction()
							Exit
						EndIf
					EndIf
      nPos++
     EndIf

    EndDo

   EndIf

  Next
  End Transaction
 Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Marc   บ Autor ณ PAULO JOSE         บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca desmarca o listbox                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Marc(oLbx, aLbx)
 If Val(aLbx[oLbx:nAt, 2]) > 0
  aLbx[oLbx:nAt, 1] := !aLbx[oLbx:nAt, 1]
  oLbx:Refresh()
 Else
  HS_MsgInf(STR0050,STR0051,STR0121) //"Valor do repasse menor ou igual a zero"###"Atencao" //"Marca desmarca o listbox"
 EndIf
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TotRM  บ Autor ณ PAULO JOSE         บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Totaliza os valores de repasse do medico                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_TotRM( aCGDX, aHGDX )
 Local cCOD        := Space(Len(GDX->GDX_CODLOC)) + Space(Len(GDX->GDX_CODCRM))
 Local cNomPre := ""
 Local nTotalRM    := 0, nContFor := 0
 Local nGDX_OK     := aScan(aHGDX, {| aVet | aVet[2] == "GDX_OK    "})
 Local nGDX_NREXTM := aScan(aHGDX, {| aVet | aVet[2] == "GDX_NREXTM"})
 Local nGDX_CODCRM := aScan(aHGDX, {| aVet | aVet[2] == "GDX_CODCRM"})
 Local nGDX_CODLOC := aScan(aHGDX, {| aVet | aVet[2] == "GDX_CODLOC"})
 Local nGDX_CODPRE := aScan(aHGDX, {| aVet | aVet[2] == "GDX_CODPRE"})
 Local nGDX_NOMPRE := aScan(aHGDX, {| aVet | aVet[2] == "GDX_NOMPRE"})
 Local nGDX_TIPLAN := aScan(aHGDX, {| aVet | aVet[2] == "GDX_TIPLAN"})
 Local nGDX_VALLAN := aScan(aHGDX, {| aVet | aVet[2] == "GDX_VALLAN"})
 Local n_CodPre    := 0
 Local aColsGD     := aClone(aCGDX)  //, aColsCod := {}
 Local aRetFor     := {}
 Local aArea       := GetArea()

 DBSelectArea("GDX")
 DbSetOrder(2)

 aSort(aColsGD,,, {|X, Y| X[nGDX_CODPRE] < Y[nGDX_CODPRE]})
 nContFor := 1
 While nContFor <= len(aColsGD)
  cCOD     := aColsGD[nContFor, nGDX_CODPRE]
  cNomPre  := aColsGD[nContFor, nGDX_NOMPRE]
  nTotalRM := 0

  While nContFor <= len(aColsGD) .And. aColsGD[nContFor, nGDX_CODPRE] == cCod
   If aColsGD[nContFor, nGDX_OK] == "LBTIK"
    If aColsGD[nContFor,nGDX_TIPLAN] == "1"        //Credito
     nTotalRM := nTotalRM + aColsGD[nContFor,nGDX_VALLAN]
    ElseIf aColsGD[nContFor,nGDX_TIPLAN] == "0"    //Debito
     nTotalRM := nTotalRM - aColsGD[nContFor, nGDX_VALLAN]
    Endif
    aAdd(aLanUsa, { cCOD, aColsGD[nContFor][nGDX_NREXTM]} )   //Guarda os Lancamentos utilizados
   Endif
   nContFor += 1
  End

  If nTotalRM > 0
   aRetFor := FS_GeraFor(cCod) // Se nao existe fornecedor para o prestador, vai criar.
   If !aRetFor[1]
    RestArea(aArea)
    Return(.F.)
   EndIf
   aAdd(aTotRM, { nTotalRM, cNomPre, cCOD, aRetFor[2], aRetFor[3], aRetFor[4]})
  Endif
 End

RestArea(aArea)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DblClk บ Autor ณPaulo jose          บ Data ณ  31/01/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Marca/Desmarca estrato                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_DblClk(oNewGetD, nCpoPosi)
Local lRet := .T.

 If oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] == "LBNO"
  oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBTIK"  //CONTA
  If oGDGDX:aCols[oGDGDX:oBrowse:nAt, nGDX_TIPLAN] == "0"//Debito
  	nTotLanMar-= oGDGDX:aCols[oGDGDX:oBrowse:nAt, nGDXVALLAN]
  Else
  	nTotLanMar+= oGDGDX:aCols[oGDGDX:oBrowse:nAt, nGDXVALLAN]
  Endif
 Else
  oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBNO"
  If oGDGDX:aCols[oGDGDX:oBrowse:nAt, nGDX_TIPLAN] == "0"//Debito
 	nTotLanMar+= oGDGDX:aCols[oGDGDX:oBrowse:nAt, nGDXVALLAN]
  Else
   nTotLanMar-= oGDGDX:aCols[oGDGDX:oBrowse:nAt, nGDXVALLAN]
  Endif
 Endif
 oTotLanMar:Refresh()
 oNewGetD:oBrowse:Refresh()

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GeraForบ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera o fornecedor                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function FS_GeraFor(cCodPre)
 Local aFornec := {}, cAliasOld := Alias(), nOpc := 3
 Local cCodFor := "", cLoja := "", cNaturez := GetMV("MV_NATFORN")
 Local aArea := HS_SavArea({{"SRA", 0, 0}, {"GBJ", 0, 0}, {"SA2", 0, 0}})

 Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
 Private lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e'que deu erro

 DbSelectArea("GAZ")
 DbSetOrder(1)
 DbSeek(xFilial("GAZ") + cCodPre)

 If Empty(GAZ->GAZ_CODFOR)
  nOpc := 3
  cCodFor  := GetSxeNum("SA2", "A2_COD",, 1)
  cLoja    := "01"
 Else
  cCodFor  := GAZ->GAZ_CODFOR
  cLoja    := GAZ->GAZ_LOJA

  DbSelectArea("SA2")
  DbSetOrder(1)
  If DbSeek(xFilial("SA2") + GAZ->GAZ_CODFOR + GAZ->GAZ_LOJA)
   If !Empty(SA2->A2_NATUREZ)
    cNaturez := SA2->A2_NATUREZ
    HS_ResArea(aArea)
    Return({.T., cCodFor, cLoja, cNaturez})
   Else
    nOpc := 4
   EndIf
  Else
   nOpc := 3
  EndIf
 Endif

aFornec :=	{	{"A2_FILIAL" , xFilial("SA2")     , Nil}, ;
             	{"A2_COD"    , cCodFor            , Nil}, ;
             	{"A2_LOJA"   , cLoja              , Nil}, ;
				{"A2_NOME"   , GAZ->GAZ_FANPRE    , Nil}, ;
				{"A2_NREDUZ" , GAZ->GAZ_FANPRE    , Nil}, ;
				{"A2_END"    , GAZ->GAZ_ENDPRE    , Nil}, ;
         		{"A2_EST"    , GAZ->GAZ_ESTPRE    , Nil}, ;
         		{"A2_MUN"    , GAZ->GAZ_CIDPRE    , Nil}, ;
         		{"A2_BAIRRO" , GAZ->GAZ_BAIPRE    , Nil}, ;
         		{"A2_CEP"    , GAZ->GAZ_CEPPRE    , Nil}, ;
   	      		{"A2_TIPO"   , GAZ->GAZ_TIPPRE    , Nil}, ;
   		      	{"A2_CGC"    , GAZ->GAZ_CGCPRE    , Nil}, ;
   	      		{"A2_NATUREZ", cNaturez           , Nil}, ;
   	      		{"A2_ID_REPR", "2"                , Nil}}

 MSExecAuto({|x, y| Mata020(x, y)}, aFornec, nOpc)
 If lMSErroAuto
  MostraErro()
  DbSelectArea("SA2")
  RollBackSx8()
  Return({.F.})
 Endif

 RecLock("GAZ", .F.)
  GAZ->GAZ_CODFOR := cCodFor
  GAZ->GAZ_LOJA   := cLoja
 MsUnLock()
 ConfirmSx8()

 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)

Return({.T., cCodFor, cLoja, cNaturez})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GerHead  บ Autor ณ Cibele Peria       บ Data ณ 28/01/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao que gera perguntas do SX1                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GerHead(aCampos, aHeader)
 Local nForCampos := 0

 If SUBSTR(aCampos[1],5,7) == "IDMARC"
  aAdd(aHeader, { " ", aCampos[1], "@BMP", 1, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", ""})
 Endif
 aAdd(aHeader, { STR0073, STR0083, "@!", 7, 0, .F., "", "C", "", "V", "", "", "", "V", "", "", ""})      //"Tipo"###"TIPO"

 DbSelectArea("SX3")
 DbSetOrder(2)

 For nForCampos := 1 to len(aCampos)
  If SUBSTR(aCampos[nForCampos],5,7) <> "IDMARC"
   DbSeek(aCampos[nForCampos])
   aAdd(aHeader, { TRIM(X3Titulo())	, ;
                   SX3->X3_CAMPO   	, ;
                   SX3->X3_PICTURE 	, ;
                   SX3->X3_TAMANHO 	, ;
                   SX3->X3_DECIMAL 	, ;
                   SX3->X3_VALID   	, ;
                   SX3->X3_USADO   	, ;
          		       SX3->X3_TIPO    	, ;
                   SX3->X3_F3      	, ;
          		       SX3->X3_CONTEXT 	, ;
                   SX3->X3_CBOX    	, ;
   		              SX3->X3_RELACAO 	, ;
                   SX3->X3_WHEN    	, ;
                   SX3->X3_VISUAL  	, ;
                   SX3->X3_VLDUSER 	, ;
                   SX3->X3_PICTVAR 	, ;
                   X3Obrigat(SX3->X3_CAMPO) })
  Endif
 Next nForCampos

Return(aHeader)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VldFM34บ Autor ณ Cibele Peria       บ Data ณ 13/04/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao das Perguntas                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
/*Function HS_VldFM34(cTab, cConteudo)
 Local cAliasOld := Alias(), lRet := .T.

 If cTab == "GA9"
  cGA9CodCon := cConteudo
  If Empty(cConteudo)
   HS_MsgInf(STR0010) //"Informe o codigo do convenio"
   lRet := .F.
  Else
   DbSelectArea("GA9")
   DbSetOrder(1)
   If !DbSeek(xFilial("GA9") + cConteudo)
    HS_MsgInf(STR0074) //"Codigo invalido"
    lRet := .F.
   Endif
  Endif
 Endif

 DbSelectArea(cAliasOld)
Return(lRet)
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PMiM34 บ Autor ณAlessandro Freire   บ Data ณ  16/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAbre janela para gera็ใo dos titulos a pagar do teto minimo บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_PMiM34()
 Local cAliasOld := Alias()
 Local dDatSis     := dDataBase
 Local cHorSis     := Time()
 Local cRefer      := ""
 Local cCodPre_De  := ""
 Local cCodPre_Ate := ""
 Local cCodCRM_De  := ""
 Local cCodCRM_Ate := ""
 Local cCodLoc_De  := ""
 Local cCodLoc_Ate := ""
 Local cAnoMes     := ""
 Local cMesFech    := ""
 Local cSelect     := "", cJoinDes := "", cJoinPct := "", cWhere := "", cOrderBy := "", cConGlo := "", cConRec := ""
 Local aCondSql    := {}
 Local nPos        := 0
 Local nPosPre     := 0
 Local nPosTit     := 0
 Local nPosMed     := 0
	Local nQtTit      := 0
 Local aPosMed     := {}
 Local nValMin     := 0
 Local nValMax     := 0
 Local nValPro     := 0
 Local nValTit     := 0
 Local cTitulo     := ""
 Local dDatVig     := ""
 Local cCodPre     := ""
 Local cCodLoc     := ""
 Local nRecNo      := 0
 Local aLbTit      := {}
 Local aRetTit     := {}
 Local aPos        := {}
 Local aExclui     := {} // Cont้m os elementos para serem excluํdos de aLanPre
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ As variaveis nP_ referem-se as posicoes dos campos no array aLanPre  a  ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local nP_CodPre   := 1					// 1-Codigo do Prestador
 Local nP_CodLoc   := 2					// 2-Codigo do Setor
 Local nP_DatVig   := 3					// 3-Data de vigencia
	Local nP_ValMin   := 4     // 4-Valor Mํnimo
	Local nP_VLMinD   := 5     // 5-Valor Mํnimo Diแrio
 Local nP_VALMAX   := 6     // 6-Valor Mแximo
 Local nP_VLMaxD   := 7     // 7-Valor Mแximo Diแrio
 Local nP_VlMinM   := 8					// 8-Valor Minimo do Mes de referencia (vai ser calculado com base nos itens 4 e 5 e o mes de referencia)
 Local nP_VlMaxM   := 9					// 9-Valor Mแximo do Mes de referencia (vai ser calculado com base nos itens 6 e 7 e o mes de referencia)
 Local nP_ValPro   := 10				//10-Valor da Producao do Mes de referencia
 Local nP_ValTit   := 11 			//11-Valor do Titulo
 Local nP_Recno    := 12 			//12-Numero do REcno do registro GEG correspondente
 Local nP_Titulo   := 13				//13-Numero do titulo do pagamento minimo, se houver
 Local nP_OcoMed   := 14				//14-Array contendo as ocorrencias da array que contem os lancamentos por medico
 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ As variaveis nM_ referem-se as posicoes dos campos no array aLanMed     ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Local nM_CodPre   := 1
 Local nM_CodLoc   := 2
 Local nM_CodCRM   := 3
 Local nM_ValLan   := 4
 Local nM_OcoDes   := 5
 Local nM_Alias    := 6
 Local nQtExtM     := 0

 Private aLanPre   := {} // Array com lan็amentos mํnimos
 Private aLanMed   := {} // Array com lan็amentos de movimento m้dico

	// Verifica o Parโmetro do prefixo do contas a pagar
	If 	len(AllTrim(GetMV("MV_PREFCPH"))) > len(SE2->E2_PREFIXO)
	 HS_MsgInf(STR0134,STR0082,STR0107) //"Parโmetro do prefixo do contas a pagar ้ invแlido (MV_PREFCPH)","Atencao","Plantao Medico"
  Return()
	Endif

 If ! Pergunte("HSM34M", .T.)
  Return(nil)
 EndIf
 cRefer      := mv_par01
 cCodPre_De  := mv_par02
 cCodPre_Ate := mv_par03
 cCodCRM_De  := mv_par04
 cCodCRM_Ate := mv_par05
 cCodLoc_De  := mv_par06
 cCodLoc_Ate := mv_par07
 cAnoMes := Substr(cRefer, 4)+Substr(cRefer, 1, 2)

 // Verifica se referencia ้ vแlida
 If (Val(Substr(cRefer, 4)) >  Year(dDataBase)) .Or. (Val(Substr(cRefer, 4)) ==  Year(dDataBase) .And. Val(Substr(cRefer, 1, 2)) >=  Month(dDataBase))
	    HS_MsgInf(STR0135,STR0082,STR0075) //"A refer๊ncia tem que ser anterior ao m๊s atual","Atencao"###"Pagamento Mํnimo"
	    Return()
 Endif

 // Preenche array com os prestadores com direito a pagamento minimo/maximo
 aLanPre := FS_ValMin(cAnoMes, cCodPre_De, cCodPre_Ate, cCodCRM_De, cCodCRM_Ate, cCodLoc_De, cCodLoc_Ate)

 // Verifica se Prestador/Setor jah foi fechado para o m๊s de refer๊ncia
 For nPosPre := 1 to len(aLanPre)
  cMesFech := FS_Max("GEG_ANOMES", "GEG", "GEG_CODPRE = '" + aLanPre[nPosPre, nP_CodPre] + "' AND GEG_CODLOC = '" +  aLanPre[nPosPre, nP_CodLoc] + "'")
  If !Empty(cMesFech) .and. Val(cMesFech) <> Val(FS_MesAnt(cAnoMes)) // verifica se a referencia eh um m๊s ap๓s o ๚ltimo fechamento
   aAdd(aExclui, nPosPre )
   HS_MsgInf(STR0105 + ; //"Os plantoes do Prestador/Setor "
           aLanPre[nPosPre, nP_CodPre] + "/" +  aLanPre[nPosPre, nP_CodLoc] + ;
           STR0106 + ; //" nao serao processados devido ao ultimo fechamento ter ocorrido em "
           Substr(cMesFech, 5, 2) + "/" + Substr(cMesFech, 1, 4),STR0082,STR0075) //,"Atencao","Pagamento Minimo"
			Loop
 	Endif
	Next

	// Atualiza aLanPre excluindo os prestadores que jแ foram processados anteriormente no mesmo perํodo
	For nPosPre := 1 to len(aExclui)
		aDel(aLanPre,aExclui[nPosPre])	// Exclui de aLanPre o prestador que jah foi processado
	Next

	// Atualiza tamanho de aLanPre
	aSize(aLanPre, len(aLanPre) - len(aExclui))

 // Retorna se nใo tiver nenhum lan็amento a ser efetuado
 If Len(aLanPre) == 0
   HS_MsgInf(STR0136,STR0082,STR0075) //"Nenhum lan็amento efetuado","Atencao","Pagamento Minimo"
   Return()
 Endif

 cSelect := " GE5.GE5_CODPRE CODPRE, GE5.GE5_CODLOC CODLOC, GE5.GE5_CODCRM CODCRM "

 cConGlo := "      AND GF5.GF5_NREXTM = '" + SPACE(LEN(GDX->GDX_NREXTM)) + "' "
 cConGlo += "      AND GF5.GF5_VALGLO > 0 AND GF5.GF5_VALREC = 0 AND GF5.GF5_VALPER = 0 "

 AADD(aCondSql, {"GF5GLO", cConGlo})

 cConRec := "      AND GF5.GF5_NREXTM = '" + SPACE(LEN(GDX->GDX_NREXTM)) + "' "
 cConRec += "      AND GF5.GF5_VALGLO > 0 AND GF5.GF5_VALREC <> 0"

 AADD(aCondSql, {"GF5REC", cConRec})


 cWhere := " WHERE GE5.GE5_FILIAL = '" + xFilial("GE5") + "' AND GE5.D_E_L_E_T_ <> '*' " + ;
           " AND GE5.GE5_CODPRE BETWEEN '" + cCodPre_De + "' AND '" + cCodPre_Ate + "' " + ;
           " AND GE5.GE5_CODCRM BETWEEN '" + cCodCRM_De + "' AND '" + cCodCRM_Ate + "' " + ;
           " AND GE5.GE5_CODLOC BETWEEN '" + cCodLoc_De + "' AND '" + cCodLoc_Ate + "' " + ;
           " AND ((GE5.GE5_PGTMED = '2' AND GE0.GE0_STATUS IN ('2', '3')) OR (GE5.GE5_PGTMED = '3' AND GE0.GE0_STATUS = '3') " + ;
           "       OR (GE5.GE5_PGTMED = '1')) " + ;
           " AND  "+Iif(TcGetDb() == "MSSQL", "SUBSTRING","SUBSTR")+"(GE5.GE5_DATDES,1,6) <= '" + cAnoMes +  "'"


 cJoinDes := " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD  =  GE5.GE5_CODDES "
 cJoinPct := " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD  =  GG5.GG5_CODDES "
 cOrderBy := " ORDER BY CODPRE, CODLOC, CODCRM"
 FS_RetSQL("GE5", cSelect, aCondSql, cJoinDes, cJoinPct, cWhere, cOrderBy, aLanPre, @aLanMed)

 cJoinDes := " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD =  GE6.GE6_CODDES "
 cJoinPct := " JOIN " + RetSqlName("GAA") + " GAA ON GAA.GAA_FILIAL = '" + xFilial("GAA") + "' AND GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_CODTXD =  GG6.GG6_CODDES "
 cSelect  := STRTRAN(cSelect, "GE5", "GE6")
 cConGlo  := STRTRAN(cConGlo, "GF5", "GF6")
 cConRec  := STRTRAN(cConRec, "GF5", "GF6")
 aCondSql := {}
 AADD(aCondSql, {"GF6GLO", cConGlo})
 AADD(aCondSql, {"GF6REC", cConRec})
 cWhere   := STRTRAN(cWhere , "GE5", "GE6")
 cOrderBy := " ORDER BY CODPRE, CODLOC, CODCRM"
 FS_RetSQL("GE6", cSelect, aCondSql, cJoinDes, cJoinPct, cWhere, cOrderBy, aLanPre, @aLanMed)

 cJoinDes := " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GE7.GE7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_TIPPRO <> '9' "
 cJoinPct := " JOIN " + RetSQLName("GA7") + " GA7 ON GA7.GA7_CODPRO = GG7.GG7_CODDES AND GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' "
 cSelect  := STRTRAN(cSelect, "GE6", "GE7")
 cConGlo  := STRTRAN(cConGlo, "GF6", "GF7")
 cConRec  := STRTRAN(cConRec, "GF6", "GF7")
 aCondSql := {}
 AADD(aCondSql, {"GF7GLO", cConGlo})
 AADD(aCondSql, {"GF7REC", cConRec})
 cWhere   := STRTRAN(cWhere , "GE6", "GE7")
 cOrderBy := " ORDER BY CODPRE, CODLOC, CODCRM"
 FS_RetSQL("GE7", cSelect, aCondSql, cJoinDes, cJoinPct, cWhere, cOrderBy, aLanPre, @aLanMed)

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Acumula a producao de cada Setor/medico por Prestador/Setor             ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 aSort(aLanMed,,,{|x,y| x[1] + X[2] + X[3] < y[1] + Y[2] + Y[3]})
 cCodPre := ""
 cCodLoc := ""
 nValLan := 0
 aPosMed := {}
 For nPosMed := 1 to len(aLanMed)
  If aLanMed[nPosMed, nM_CodPre] <> cCodPre .or. (IIF(nPos > 0, IIF(!Empty(aLanPre[nPos, nP_CodLoc]), aLanMed[nPosMed, nM_CodLoc] <> cCodLoc, .F.), .F.))
   If nPosMed > 1
    aLanPre[nPos, nP_ValPro] := nValLan
    aLanPre[nPos, nP_OcoMed] := aPosMed //array contendo as ocorrencias aLanMed correspondentes (para futura atualizacao)
    nValLan := 0
    aPosMed := {}
   Endif
   nPos := aScan(aLanPre, {| aVet | aVet[nP_CodPre]+aVet[nP_CodLoc] == aLanMed[nPosMed, nM_CodPre]+aLanMed[nPosMed, nM_CodLoc] })
   If nPos == 0
    nPos := aScan(aLanPre, {| aVet | aVet[nP_CodPre]+aVet[nP_CodLoc] == aLanMed[nPosMed, nM_CodPre]+Space(Len(GCS->GCS_CODLOC)) })
   Endif
  Endif

  nValLan += aLanMed[nPosMed, nM_ValLan]
  aAdd(aPosMed, nPosMed)

  If nPosMed == len(aLanMed)
   aLanPre[nPos, nP_ValPro] := nValLan
   aLanPre[nPos, nP_OcoMed] := aClone(aPosMed) //array contendo as ocorrencias aLanMed correspondentes (para futura atualizacao)
  Endif

   cCodPre := aLanMed[nPosMed, nM_CodPre]
   cCodLoc := aLanMed[nPosMed, nM_CodLoc]

 Next nPosMed

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Depois de obter os valores de producao por Prestador/Setor, verifica a  ณ
 //ณ geracao da producao ou do pagamento minimo/teto.                        ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nPos := 1 to len(aLanPre)
  cCodPre := aLanPre[nPos, nP_CodPre]
  cCodLoc := aLanPre[nPos, nP_CodLoc]
  nValMin := aLanPre[nPos, nP_VlMinM]
  nValMax := aLanPre[nPos, nP_VlMaxM]
  nValPro := aLanPre[nPos, nP_ValPro]
  nValTit := 0

  DbSelectArea("GEG")
  DbSetOrder(1)
  If nValPro == 0
   nValTit := nValMin
  ElseIf nValPro < nValMin
   nValTit := nValMin
  ElseIf nValPro > nValMax
   nValTit := nValMax
  Else
   nValTit := nValPro
  Endif

  aLanPre[nPos, nP_ValTit] := nValTit

 Next nPos

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Prepara os titulos para apresentacao na tela                            ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 For nPos := 1 to len(aLanPre)
  cCodPre := aLanPre[nPos, nP_CodPre]
  cCodLoc := aLanPre[nPos, nP_CodLoc]
  dDatVig := aLanPre[nPos, nP_DatVig]
  nValMin := aLanPre[nPos, nP_VlMinM]
  nValMax := aLanPre[nPos, nP_VlMaxM]
  nValPro := aLanPre[nPos, nP_ValPro]
  nValTit := aLanPre[nPos, nP_ValTit]
  cTitulo := aLanPre[nPos, nP_Titulo]

  If nValTit == 0
   Loop
  Endif

  dbSelectArea("GAZ")
  dbSetOrder(1)
		If !dbSeek(xFilial("GAZ")+cCodPre)
		 HS_MsgInf(STR0127+"(Cod: "+cCodPre+")",STR0082,STR0075) //"Prestador nใo foi localizado","Atencao","Pagamento Minimo"
		 Return()
  Endif

  DbSelectArea("SA2")
  DbSetOrder(1)
  If !DbSeek(xFilial("SA2") + GAZ->GAZ_CODFOR + GAZ->GAZ_LOJA)
		 HS_MsgInf(STR0132+cCodPre+STR0133,STR0082,STR0075) //"Fornecedor para este prestador (Cod: ",") nใo foi localizado","Atencao","Pagamento minimo"
		 Return()
  Endif

  If !Empty(cCodLoc)
   DbSelectArea("GCS")
   DbSetOrder(1)
   DbSeek(xFilial("GCS") + cCodLoc)
  Endif

  aAdd(aLbTit, {.T.                 ,;       //1 - .t. marcado .f. desmarcado
       Transform(nValTit, "@E 999,999.99"),; //2 - valor do titulo dever ser caractere
       GAZ->GAZ_FANPRE + IIf(Empty(cCodLoc), "", " - " + GCS->GCS_NOMLOC)    ,;     //3 - Nome fantasia do prestador - pode ser qualquer texto
       GAZ->GAZ_CODFOR                   ,;  //4 - codigo do fornecedor
       GAZ->GAZ_LOJA                     ,;  //5 - loja do fornecedor
       SA2->A2_NATUREZ                   ,;  //6 - natureza
       cCodPre                           ,;  //7 a partir do 7 item nao precisam estar no array
       cCodLoc                           ,;  //8
       dDatVig                           ,;  //9
       nPos                              ,;  //10-Posicao do vetor aLanPre
       nValTit                           })  // passa o valor do titulo sem formatar

 Next nPos

 aRetTit := FS_GTitP( aLbTit, STR0075) //"Pagamento Mํnimo"###"Pag.Minimo"
 If len(aRetTit) == 0
  Return()
 Endif

 //ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
 //ณ Atualiza as despesas referentes aos titulos gerados                     ณ
 //ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
 Begin Transaction
 For nPosPre := 1 to len(aLanPre)
  cCodPre := aLanPre[nPosPre, nP_CodPre]
  cCodLoc := aLanPre[nPosPre, nP_CodLoc]
  nValMin := aLanPre[nPosPre, nP_VlMinM]
	 nValMax := aLanPre[nPosPre, nP_VlMaxM]
  nValPro := aLanPre[nPosPre, nP_ValPro]
  nValTit := aLanPre[nPosPre, nP_ValTit]

  If nValTit == 0 .and. nValPro == 0
   Loop
  Endif

  If (nPosTit := aScan(aLbTit, {| aVet | aVet[7]+aVet[8] == cCodPre+cCodLoc })) > 0
   If !aLbTit[nPosTit, 1]
    Loop
   Endif
  Endif

  If nValTit == 0
   cTitulo := aLanPre[nPosPre, nP_Titulo]
  Else
   cTitulo := FS_GeraTit(aLbTit[nPosTit], STR0076, cMV_PrefCPH, aRetTit)
   nQtTit ++
  Endif

  If nValPro > 0

   For nPos := 1 to len(aLanPre[nPosPre, nP_OcoMed]) //Gera lancamento medico a medico
    nQtExtM += 1
    nPosMed := aLanPre[nPosPre, nP_OcoMed, nPos]
    FS_AtuMin(aLanMed[nPosMed, nM_CodLoc], aLanMed[nPosMed, nM_CodCRM], aLanMed[nPosMed, nM_ValLan], cTitulo, aClone(aLanMed[nPosMed, nM_OcoDes]), cAnoMes, aLanMed[nPosMed, nM_Alias])
   Next nPos

  Endif

  DbSelectArea("GEG")
	  Reclock("GEG", .T.)
    GEG->GEG_FILIAL := xFilial("GEG")
    GEG->GEG_CODPRE := cCodPre
    GEG->GEG_CODLOC := cCodLoc
    GEG->GEG_ANOMES := cAnoMes
    GEG->GEG_VALMIN := nValMin
	   GEG->GEG_VALMAX := nValMax
    GEG->GEG_VALPRO := nValPro
    GEG->GEG_VALPAG := nValTit
    GEG->GEG_TITULO := cTitulo
	   GEG->GEG_DATFEC := dDatSis
	   GEG->GEG_HORFEC := cHorSis
	   GEG->GEG_USUFEC := cUserName
  MsUnlock()

 Next nPosPre
 End Transaction
 //"Janela para gera็ใo dos titulos a pagar do teto minimo"
 HS_MsgInf(STR0098 + STR0137 + TRANSFORM(nQtExtM, "999,999") + STR0138 + TRANSFORM(nQtTit, "999,999") + STR0139,STR0082,STR0122) //"Processamento finalizado com sucesso! "###"Foram gerados "###" lan็amentos m้dicos e "###" tํtulos a pagar"

Return(nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_AtuMin บ Autor ณCibele Peria        บ Data ณ  01/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAtualizacao das despesas no extrato do convenio e dos gera- บฑฑ
ฑฑบ          ณcao dos lancamentos no extrato medico                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_AtuMin(cCodLoc, cCodCRM, nValLan, cTitulo, aOcoDes, cAnoMes, cAlias)
 Local nPosDes := 0
 Local cTipMov := IIF(SUBSTR(cAlias,3,1) == "5", "6", IIF(SUBSTR(cAlias,3,1) == "6", "7", "2"))
 Local cAliasGF := "GF" + SUBSTR(cAlias, 3,1), cAliasGG := "GG" + SUBSTR(cAlias, 3,1)
 //Esta funcao deve atualizar gerar os lancamentos medicos utilizados no titulo e atualizar a GE7/GF7 de cada lancamento

 cNrExtM := HS_VSxeNum("GDX", "M->GDX_NREXTM", 1)
 For nPosDes := 1 to len(aOcoDes) //Cada ocorrencia de aOcorr refere-se a um lancamento medico

  //Atualizar todas as despesas do extrato do convenio, referente ao lancamento do medico
  If aOcoDes[nPosDes, 1] == "CONTA"
   DbSelectArea(cAlias)
   DbSetOrder(1)
   DbGoTo(aOcoDes[nPosDes, 2])
   Reclock(cAlias, .F.)
    &(cAlias + "->" + cAlias + "_NREXTM") := cNrExtM
   MsUnlock()
  ElseIf aOcoDes[nPosDes, 1] == "PACOTE"
   DbSelectArea(cAliasGG)
   DbSetOrder(1)
   DbGoTo(aOcoDes[nPosDes, 2])
   Reclock(cAliasGG, .F.)
    &(cAliasGG + "->" + cAliasGG + "_NREXTM") := cNrExtM
   MsUnlock()
  Else
   DbSelectArea(cAliasGF)
   DbSetOrder(1)
   DbGoTo(aOcoDes[nPosDes, 2])
   Reclock(cAliasGF, .F.)
    &(cAliasGF + "->" + cAliasGF + "_NREXTM") := cNrExtM
   MsUnlock()
  Endif

 Next nPosDes

 //Gera lancamento para o medico
 RecLock("GDX", .T.)
  GDX->GDX_FILIAL := xFilial("GDX")
  GDX->GDX_NREXTM := cNrExtM
  GDX->GDX_CODCRM := cCodCRM
  GDX->GDX_CODLOC := cCodLoc
  GDX->GDX_CODPRE := HS_RPreMed(cCodCRM, cCodLoc)
  GDX->GDX_DATLAN := dDataBase
  GDX->GDX_TIPLAN := IIF(nValLan>0, "1", "0")
  GDX->GDX_TIPMOV := cTipMov    //Prod. Min/Teto
  GDX->GDX_VALLAN := nValLan
  GDX->GDX_HISLAN := FS_HisLan("M", cAnoMes, cCodLoc)
  GDX->GDX_CODCPG := cTitulo
  GDX->GDX_LOGARQ := HS_LogArq()
 MsUnlock()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GTitP  บ Autor ณAlessandro Freire   บ Data ณ  16/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณAbre janela para gera็ใo dos titulos a pagar do teto minimo บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GTitP( aLbTit, cTitulo)
Local oDlgGDX
Local oLbx
Local oCondTit
Local oVctoTit
Local oTipoTit
Local nI, nX
Local oTik        	:= LoadBitmap(GetResources(), "LBTIK")
Local oNo         	:= LoadBitmap(GetResources(), "LBNO")
Local cLbx        	:= " "
Local aTitulo     	:= {}
Local nContFor    	:= 0
Local cCondTit    	:= Space(Len(SE4->E4_CODIGO))
Local dVctoTit    	:= dDataBase
Local cTipoTit    	:= Space(Len(SE2->E2_TIPO))
Local cQuery      	:= ""
Local nValor      	:= 0
Local nOpcA    		:= 0
Local cE2_Num     	:= ""
Local cValtit     	:= ""
Local lTit        	:= .T.

//Variaveis utilizadas para posicionamento e dimensao dos objetos da Enchoice
Local aSize  		:= {}, aObjects  := {}, aInfo   := {}, aPObjs   := {}
Local lEnchBar 		:= .T.
Local lPadrao 		:= .F.
Local nCenterX		:= 0

Private lMSHelpAuto := .T. // Para nao mostrar os erro na tela
Private lMSErroAuto := .F. // Inicializa como falso, se voltar verdadeiro deu erro

aSize 		:= MsAdvSize(lEnchBar, lPadrao)
nCenterX	:= aSize[3]/2

aObjects := {}

aAdd( aObjects, { aSize[3], aSize[4], .T., .T. } ) // List Box
aAdd( aObjects, { 10, 10, .T., .F. } ) // Say "Referencia"
aAdd( aObjects, { 100, 10, .F., .F., .T. } ) // Get "Referencia"
aAdd( aObjects, { 10, 10, .T., .F. } ) // Say "Cond.Pagto"
aAdd( aObjects, { 100, 10, .F., .F., .T. } ) // Get "Cond.Pagto"
aAdd( aObjects, { 10, 10, .T., .F. } ) // Say "Tipo"
aAdd( aObjects, { 10 , 10 , .T., .F., .T. } ) // Get "Tipo"

aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0 }

aPObjs := MsObjSize( aInfo, aObjects, .F.)

If Empty(aLbTit)
	HS_MsgInf(STR0077,STR0082, STR0123) //"Nใo hแ informa็๕es para gerar os titulos","Atencao" //"Janela para gera็ใo dos titulos a pagar teto minimo"
	Return({})
EndIf

aSort(aLbTit,,, {|X, Y| X[3] < Y[3]})

DEFINE MSDIALOG oDlgGDX TITLE cTitulo From aSize[ 7 ],000 to  aSize[ 6 ] , aSize[ 5 ] of oMainWnd pixel

@ 	aPObjs[1,1], aPObjs[1,2] LISTBOX oLbx VAR cLbx FIELDS HEADER " ", STR0078, STR0079, STR0150, STR0151 ; //"Valor"###"Prestador"###"Setor"###"Descri็ใo"
	SIZE aPObjs[1,4] , aPObjs[1,3] - 15 OF oDlgGDX PIXEL ON DBLCLICK(FS_Marc(oLbx, aLbTit))

oLbx:SetArray(aLbTit)
oLbx:bLine:= {||{IIf(!aLbTit[oLbx:nAt, 1], oNo, oTik), aLbTit[oLbx:nAt, 2],aLbTit[oLbx:nAt, 3], aLbTit[oLbx:nAt, 8], HS_IniPadR("GCS", 1, aLbTit[oLbx:nAt, 8], "GCS_NOMLOC",, .F.)}}

@ aPObjs[4,1],nCenterX - 70 	Say STR0080 OF oDlgGDX PIXEL COLOR CLR_BLUE //"Referencia"
@ aPObjs[5,1],nCenterX - 70 	MsGet oVctoTit Var dVctoTit OF oDlgGDX PIXEL COLOR CLR_BLACK

@ aPObjs[4,1],nCenterX  		Say STR0111 OF oDlgGDX PIXEL COLOR CLR_BLUE //"Cond.Pagto"
@ aPObjs[5,1],nCenterX  		MsGet oCondTit Var cCondTit F3 "SE4" OF oDlgGDX Valid FS_CPgTit(cCondTit) PIXEL COLOR CLR_BLACK

@ aPObjs[4,1],nCenterX + 70 	Say STR0073 OF oDlgGDX PIXEL COLOR CLR_BLUE //"Tipo"
@ aPObjs[5,1],nCenterX + 70 	MsGet oTipoTit Var cTipoTit F3 "05"  OF oDlgGDX Valid FS_TipTit(cTipoTit) PIXEL COLOR CLR_BLACK

nOpcA := 0
ACTIVATE MSDIALOG oDlgGDX CENTERED ON INIT EnchoiceBar(oDlgGDX, {|| nOpcA :=1, IIF(FS_VldTit(dVctoTit, cCondTit, cTipoTit), oDlgGDX:End(), nOpcA := 0)}, ;
{||nOpcA := 0, oDlgGDX:End()} )

If nOpcA == 0
	Return({})
EndIf

Return({cTipoTit, dVctoTit, cCondTit})
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GeraTitบ Autor ณCibele Peria        บ Data ณ  09/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGera o titulo no contas a pagar                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_GeraTit(aLbTit, cHist, cPref, aRetTit)
 Local cTipoTit  := aRetTit[1]
 Local dVctoTit  := aRetTit[2]
 Local cCondPag  := aRetTit[3]
 Local cE2_Num   := ""
 Local aTitulo   := {}
 Local aParcelas := Condicao(aLbTit[11], cCondPag, 0, dVctoTit)
 Local nPar      := 0
 Local lRet      := .T., lLanCont := .F.
 Local cValTit   := 0
 Local cMultNat  := "2" //Nao
 Local cMV_HSPF12 := ALLTRIM(UPPER(GetMv("MV_HSPF12",, "N")))

 Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
 Private lMSErroAuto := .F. // inicializa como falso, se voltar verdadeiro e' que deu erro

 Private cBancoAdt	  :=CriaVar("A6_COD")
 Private cAgenciaAdt	:= CriaVar("A6_AGENCIA")
 Private cNumCon	 	  := CriaVar("A6_NUMCON")
 Private cChequeAdt	 := CriaVar("EF_NUM")
 Private cHistor		   := CriaVar("EF_HIST")
 Private cBenef		    := CriaVar("EF_BENEF")
 Private cPictHist

 If aLbTit[11] == 0
  Return()
 Endif

 If GETMV("MV_MULNATP") //Multiplas Naturezas
  aColsSev	 	:= {} //Arrays privates utilizados pelo FINA050
  aHeaderSev	:= {}
  cMultNat   := "1" //Sim
  cValTit    := StrTran(aLbTit[2],".","")
  lRet       := HS_MntGEV(VAL(StrTran(cValTit,",","."))) //Monta aCols e aHeader utilizado na multipla natureza
 EndIf

 If lRet
  cE2_Num      := FS_E2Num(cPref)
 	If cMV_HSPF12 == "S"  //"Mostra Lan็amento Contแbil ?"
   lLanCont := .T.
  Endif

  For nPar := 1 to len(aParcelas)
   //Tela com os dados bancarios caso seja Paga/o Antecipado
   If cTipoTit $ MVPAGANT
    MV_PAR05 := 1
    Fa050DigPa()
   Endif

   aTitulo      :={{"E2_FILIAL" , xFilial("SE2")                        , Nil}, ;
                   {"E2_PREFIXO" , cPref                                  , Nil}, ;
                   {"E2_NUM"    , cE2_Num                                , Nil}, ;
                   {"E2_PARCELA" , StrZero(nPar, TAMSX3("E2_PARCELA")[1]), Nil}, ;
                   {"E2_TIPO"   , cTipoTit                               , Nil}, ;
                   {"E2_NATUREZ" , aLbTit[6]                              , Nil}, ;
                   {"E2_FORNECE" , aLbTit[4]                              , Nil}, ;
                   {"E2_LOJA"   , aLbTit[5]                              , Nil}, ;
                   {"E2_EMISSAO" , dDataBase            	                 , Nil}, ;
                   {"E2_VENCTO" , aParcelas[nPar, 1]                    , Nil}, ;
                   {"E2_VENCREA" , DataValida(aParcelas[nPar, 1])        , Nil}, ;
                   {"E2_VALOR"  , aParcelas[nPar, 2]                    , Nil}, ;
                   {"E2_VLCRUZ" , aParcelas[nPar, 2]                    , Nil}, ;
                   {"E2_ORIGEM" , "HSPAHM34"                            , Nil}, ;
                   {"E2_HIST"   , cHist                                 , Nil}, ;
                   {"E2_MULTNAT" , cMultNat                              , Nil}, ;
                   {"AUTBANCO"   , cBancoAdt                             , Nil}, ;
                   {"AUTAGENCIA" , cAgenciaAdt                           , Nil}, ;
                   {"AUTCONTA"   , cNumCon                               , Nil}, ;
                   {"AUTCHEQUE"  , cChequeAdt                            , Nil}}

   MSExecAuto({|t,u,v,x,y,z| FINA050(t,u,v,x,y,z)}, aTitulo,, 3,,,lLanCont)
   If lMSErroAuto
    MostraErro()
    Return()
   EndIf

  Next nPar
  MsgStop(STR0154 + cE2_Num + STR0155 + cPref, STR0082)//"Tํtulo Gerado: "###" Prefixo "###"Aten็ใo"
 Else
  HS_MsgInf(STR0124, STR0082, STR0125) //"Gera็ใo do Contas a Pagar cancelada, dados necessarios para Multiplas Naturezas nao informados"###"Aten็ใo"###"Verifique os dados"
 EndIf

Return(cE2_Num)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_tiptit บAutor  ณalessandro freire   บ Data ณ  17/04/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a valida็ใo do tipo do titulo                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
STATIC FUNCTION FS_TipTit(cTipoTit)
 Local aArea := GetArea(), lRet := .T.

 DbSelectArea("SX5")
 If !(dbSeek(cFilial+"05"+cTipoTit)) .Or. !NewTipCart(cTipoTit,"2")
  HS_MsgInf(STR0081, STR0082 + " " + STR0048, STR0001) //"Tipo de tํtulo nใo encontrado"###"Titulos no Contas a Pagar"###"Extrato Medico"
  lRetorna := .F.
 Endif

 RestArea(aArea)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_CPgTit บAutor  ณ Cibele Peria       บ Data ณ  20/01/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณConsistencia da condicao de pagamento selecionada na gera - บฑฑ
ฑฑบ          ณcao dos titulos no contas a pagar.                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_CPgTit(cCondTit)
 Local aArea := GetArea(), lRet := .T.

 If !(lRet := !Empty(cCondTit))
  HS_MsgInf(STR0114, STR0082 + " " + STR0048, STR0001) //"Por favor, informe a condicao de pagamento do titulo"###"Titulos no Contas a Pagar"###"Extrato Medico"
 Else
  DbSelectArea("SE4")
  DbSetOrder(1)
  If !(lRet := DbSeek(xFilial("SE4") + cCondTit))
   HS_MsgInf(STR0112, STR0082 + " " + STR0048, STR0001) //"Condicao de pagamento nao cadastrada"###"Titulos no Contas a Pagar"###"Extrato Medico"
  ElseIf !(lRet := (SE4->E4_TIPO <> "9"))
   HS_MsgInf(STR0113, STR0048, STR0001) //"Condicao de pagamento invalida (tipo = 9)"###"Titulos no Contas a Pagar"###"Extrato Medico"
  Endif
 Endif
 RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_E2Num  บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera o codigo do Titulo                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_E2Num(cMV_PrefCPH)
Local cE2_Num := Space(Len(SE2->E2_NUM)), cAliasOld := Alias(), aArea :=HS_SavArea({{"SE2", 0, 0}})
Local cSql    := ""

 cSql := "SELECT MAX(SE2.E2_NUM) MAXNUM FROM " + RetSqlName("SE2") + " SE2"
 cSQL += " WHERE"
 cSQL += " SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND SE2.D_E_L_E_T_ <> '*' "
 cSQL += " AND SE2.E2_PREFIXO = '" + cMV_PrefCPH + "' "

 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRYSE2"

 cE2_Num := Soma1(QRYSE2->MAXNUM , TAMSX3("E2_NUM")[1])

 DbCloseArea()
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(cE2_Num)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ValMin บ Autor ณ Cibele Peria       บ Data ณ 01/06/05    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Obtem os Prestadores/Setor que trabalham com pagamento     บฑฑ
ฑฑบ          ณ minimo e retorna vetor com os valores correspondentes      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ValMin(cAnoMes, cCodPre_De, cCodPre_Ate, cCodCRM_De, cCodCRM_Ate, cCodLoc_De, cCodLoc_Ate)
 Local cAliasOld := Alias()
 Local cSQL      := ""
 Local nVlMinM   := 0
 Local nVlMaxM   := 0
 Local aRet      := {}

 cSQL := "SELECT GEF1.GEF_CODPRE CODPRE, GEF1.GEF_CODLOC CODLOC, GEF1.GEF_DATVIG DATVIG, GEF1.GEF_VALMIN VALMIN, GEF1.GEF_VLMIND VLMIND, GEF1.GEF_VALMAX VALMAX, GEF1.GEF_VLMAXD VLMAXD "
 cSQL += "FROM " + RetSQLName("GEF") + " GEF1 "
 cSQL += "JOIN " + RetSQLName("GAZ") + " GAZ ON GAZ.GAZ_CODPRE = GEF1.GEF_CODPRE AND GAZ_CTLOCM = '1' "
 cSQL += "WHERE GEF1.GEF_FILIAL = '" + xFilial("GEF") + "' AND GEF1.D_E_L_E_T_ <> '*' "
 If !Empty(cCodPre_De)
  cSQL += "AND GEF1.GEF_CODPRE >= '" + cCodPre_De + "' "
 Endif
 If !Empty(cCodPre_Ate)
  cSQL += "AND GEF1.GEF_CODPRE <= '" + cCodPre_Ate + "' "
 Endif
 If !Empty(cCodLoc_De)
  cSQL += "AND GEF1.GEF_CODLOC >= '" + cCodLoc_De + "' "
 Endif
 If !Empty(cCodLoc_Ate)
  cSQL += "AND GEF1.GEF_CODLOC <= '" + cCodLoc_Ate + "' "
 Endif

 cSQL += "AND GEF1.GEF_DATVIG = (SELECT MAX(GEF2.GEF_DATVIG) "
 cSQL += "FROM " + RetSQLName("GEF") + " GEF2 "
 cSQL += "WHERE GEF2.GEF_FILIAL = '" + xFilial("GEF") + "' AND GEF2.D_E_L_E_T_ <> '*' "
 If !Empty(cAnoMes)
  cSQL += "AND "+Iif(TcGetDb() == "MSSQL", "SUBSTRING","SUBSTR")+"(GEF2.GEF_DATVIG, 1, 6) <= '" + cAnoMes + "' "
 Endif
 cSQL += "AND GEF2.GEF_CODPRE = GEF1.GEF_CODPRE "
 cSQL += "AND GEF2.GEF_CODLOC = GEF1.GEF_CODLOC" + ") "
 cSQL += "UNION "
 cSQL += "SELECT GAZ.GAZ_CODPRE  CODPRE, ' ' CODLOC, '"+IIF(!Empty(cAnoMes),cAnoMes,"197001")+"01"+"' DATVIG, GAZ.GAZ_VALMIN  VALMIN, GAZ.GAZ_VLMIND  VLMIND, GAZ.GAZ_VALMAX  VALMAX, GAZ.GAZ_VLMAXD  VLMAXD "
 cSQL += "FROM " + RetSQLName("GAZ") + " GAZ "
 cSQL += "WHERE GAZ_CTLOCM = '0' AND GAZ.GAZ_FILIAL = '" + xFilial("GAZ") + "' AND GAZ.D_E_L_E_T_ <> '*'
 cSQL += "ORDER BY CODPRE, CODLOC "
 cSQL := ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "MIN"
 DbSelectArea("MIN")
 DbGoTop()

 While !Eof()

  If Empty(cAnoMes)
   nVlMinM := 0
  ElseIf MIN->VALMIN > 0
   nVlMinM := MIN->VALMIN
  Else
   nVlMinM := MIN->VLMIND * F_UltDia(STOD(cAnoMes+"01"))
  Endif

  If Empty(cAnoMes)
   nVlMaxM := 0
  ElseIf MIN->VALMAX > 0
   nVlMaxM := MIN->VALMAX
  Else
   nVlMaxM := MIN->VLMAXD * F_UltDia(STOD(cAnoMes+"01"))
  Endif

  aAdd(aRet, {MIN->CODPRE, ;     // 1-Codigo do Prestador
              MIN->CODLOC, ;     // 2-Codigo do Setor
              MIN->DATVIG, ;     // 3-Data de vigencia
              MIN->VALMIN, ;     // 4-Valor Mํnimo
              MIN->VLMIND, ;     // 5-Valor Mํnimo Diแrio
              MIN->VALMAX, ;     // 6-Valor Mแximo
              MIN->VLMAXD, ;     // 7-Valor Mแximo Diแrio
              nVlMinM,         ;     // 8-Valor Minimo do Mes de referencia (vai ser calculado com base nos itens 4 e 5 e o mes de referencia)
              nVlMaxM,         ;     // 9-Valor Minimo do Mes de referencia (vai ser calculado com base nos itens 6 e 7 e o mes de referencia)
              0, ;                   //10-Valor da Producao do Mes de referencia
              0, ;                   //11-Valor do Titulo
              0, ;                   //12-Numero do Recno do registro GEG correspondente
              "", ;                  //13-Numero do titulo do pagamento minimo, se houver
              {}})                   //14-Array contendo as ocorrencias da array que contem os lancamentos por medico

  DbSkip()
 End

 DbCloseArea()
 DbSelectArea(cAliasOld)

Return(aRet)

Static Function FS_VldTit(dVctoTit, cCondTit, cTipoTit)
 Local lRet := .F.

 If Empty(dVctoTit)
  HS_MsgInf(STR0114, STR0082 + " " + STR0048, STR0001) //"Por favor, informe a data de vencimento do titulo"###"Titulos no Contas a Pagar"###"Extrato Medico"
 ElseIf dVctoTit < dDataBase
  HS_MsgInf(STR0115, STR0082 + " " + STR0048, STR0001) //"Data de vencimento do titulo invalida"###"Titulos no Contas a Pagar"###"Extrato Medico"
 ElseIf Empty(cCondTit)
	  HS_MsgInf(STR0116, STR0082 + " " + STR0048, STR0001) //"Por favor, informe a condicao de pagamento do titulo"###"Titulos no Contas a Pagar"###"Extrato Medico"
	 ElseIf Empty(cTipoTit)
  HS_MsgInf(STR0117, STR0082 + " " + STR0048, STR0001) //"Por favor, informe o tipo do titulo"###"Titulos no Contas a Pagar"###"Extrato Medico"
 Else
  lRet := .T.
 Endif

Return(lRet)
// Converter data (dd/mm/aaaa) e hora (hh:mm:ss)ou(hh:mm) para timestump (quantidade em segundos de 01/01/1970)
Function HS_TimeStump(dData,cHora)
	Local nTimeStump, nHoras, nMinutos, nSegundos
	nHoras     := Val(Substr(cHora,1,2))
	nMinutos   := Val(Substr(cHora,4,2))
	If Len(cHora) == 8
		nSegundos  := Val(Substr(cHora,7,2))
	Else
		nSegundos  := 0
	Endif
	nTimeStump := round(((dData - CTOD("01/01/1970")) * 24 * 60 * 60)+(nHoras*60*60)+(nMinutos*60)+(nSegundos),0)
Return(nTimeStump)

// Acumula a quantidade de horas noturnas e diurnas de um perํodo entre hora inicial e hora final
Static Function FS_NotDiu(cHoraIni,cHoraFim)
 Local cIniDia     := AllTrim(GetMV("MV_INIDIA")) + ":00"
 Local cFimDia     := AllTrim(GetMV("MV_FIMDIA")) + ":00"
 Local nAcertHor  := 0
 cHoraIni := cHoraIni+":00"
 cHoraFim := cHoraFim+":00"
 nAcertHor:= FS_VerHora(cHoraIni,cHoraFim)  //Chamada para Verificar se Hora/Min Nao e Cheia Ex: 23:59
 While .t. // Loop para retornar se o perํodo abrange noturo-diurno-noturno
		If cHoraIni >= cIniDia .AND. cHoraIni <= cFimDia // Verifica se hora inicial estแ no diurno
			If cHoraFim >= cIniDia .AND. cHoraFim <= cFimDia // Verifica se hora final estแ no diurno
				nQtHDiur += Round(HS_Hor2Dec(ElapTime(cHoraIni,cHoraFim))+ nAcertHor,2)//+ nAcerto,2) // Se hora inicial e final estiverem no diurno, calcula diurno e fim
			Else // Se a hora final nใo estiver no diurno
				nQtHDiur += Round(HS_Hor2Dec(ElapTime(cHoraIni,cFimDia))+ nAcertHor,2)//+ nAcerto,2)	// Calcula diurno e
				nQtHNotu += HS_Hor2Dec(ElapTime(cFimDia,cHoraFim))+ nAcertHor//	+ nAcerto // noturno e fim
			Endif
		Else // Se a hora inicial nใo estiver no diurno
			If cHoraIni < cIniDia // verifica se a hora inicial estแ no primeiro horแrio do noturno (antes do inicio do diurno)
				If cHoraFim < cIniDia // verifica se a hora final estแ no primeiro horแrio do noturno (antes do inicio do diurno)
					nQtHNotu += Round(HS_Hor2Dec(ElapTime(cHoraIni,cHoraFim))+ nAcertHor,2)// + nAcerto,2)	// Se tanto hora inicial quanto hora final estiverem no primeiro horแrio do noturno, calcula e fim

				Else // Se a hora final estiver fora do primeiro noturno
					nQtHNotu += HS_Hor2Dec(ElapTime(cHoraIni,cIniDia))+ nAcertHor// + nAcerto	 // Acumula noturno
					cHoraIni := cIniDia // E acerta hora inicial para continuar os cแlculos
					loop // Volta para continuar acumulando horas
				Endif
			Else // Se a hora inicial nใo estiver no primeiro horario do noturno, entใo tanto a hora inicial quanto hora final estใo no segundo perํodo do noturno
				nQtHNotu += Round(HS_Hor2Dec(ElapTime(cHoraIni,cHoraFim))+ nAcertHor,2)// + nAcerto,2) // Calcula noturno e fim
			Endif
		Endif
		Exit // For็a saํda do loop
 End
Return()

// Converte uma hh:mm para hora decimal
Function HS_Hor2Dec(cHora)
Return(Val(Substr(cHora,1,2))+round(Val(Substr(cHora,4,2))/60,2))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_RetSQL บ Autor ณ Mario Arizono      บ Data ณ 29/10/07    บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna dados da SQL para extrato medico                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar.                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_RetSQL(cAlias, cSelect, aCond, cJoinDes, cJoinPct, cWhere, cOrderBy, aVetFil, aCols, lGerExt)
 Local cAliasOld  := Alias()
 Local cSQL       := ""
 Local cAliasGF   := "GF" + SUBSTR(cAlias,3,1), cAliasGG := "GG" + SUBSTR(cAlias,3,1)
 Local cPrefGe    := cAlias + "." + cAlias, cPrefGf := "GF" + SUBSTR(cAlias,3,1) + "." + "GF" + SUBSTR(cAlias,3,1)
 Local cPrefGg    := "GG" + SUBSTR(cAlias,3,1) + "." + "GG" + SUBSTR(cAlias,3,1)
 Local cSelectPct := STRTRAN(cSelect, cAlias, cAliasGG)
 Local cWherePct  := STRTRAN(cWhere, cAlias, cAliasGG)
 Local nPosGcz := 0, nPosGf := 0, nPosGlo := 0, nPosRec := 0
 Local nPos       := 0

 Default lGerExt  := .F.
 Default aVetFil  := {}
 Default aCols    := {}

 nPosGcz := aScan(aCond, {| aVet | aVet[1] == "GCZ"})
 nPosGf :=  aScan(aCond, {| aVet | aVet[1] == cAliasGF})

 cSql := "SELECT 'CONTA' AS TIPO, GCZ.GCZ_NRFATU AS FATURA, " + cSelect + ", " + cPrefGe + "_VALREP AS VALOR, '' QRY_NREXTMGF, "
 cSql += "" + cAlias +".R_E_C_N_O_ "
 cSql += " FROM " + RetSqlName(cAlias) + " " + cAlias
 cSql += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = " + cPrefGe + "_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = " + cPrefGe + "_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_STATUS >= '4' "
 If nPosGcz > 0
  cSql += aCond[nPosGcz,2]
 Endif
 cSql += " LEFT JOIN " + RetSQLName("GE0") + " GE0 ON GE0.GE0_NUMEXT = " + cPrefGe + "_NREXTC AND GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.D_E_L_E_T_ <> '*' "
 cSql += cJoinDes
 cSql += cWhere
 cSql += " AND " + cPrefGe + "_NREXTM = '" + SPACE(LEN(GDX->GDX_NREXTM)) + "' "

 cSQL += " UNION ALL "
 cSql += "SELECT 'GLOSA' AS TIPO, GCZ.GCZ_NRFATU AS FATURA, " + cSelect + ", " + cPrefGf + "_VLRGLO AS VALOR, " + cPrefGf + "_NREXTM QRY_NREXTMGF, "
 cSql += "" + cAliasGF + ".R_E_C_N_O_ "
 cSql += " FROM " + RetSqlName(cAlias) + " " + cAlias
 cSql += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = " + cPrefGe + "_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql += " JOIN " + RetSQLName(cAliasGF) + " " + cAliasGF + " ON " + cPrefGf + "_SEQDES = " + cPrefGe + "_SEQDES AND " + cPrefGf + "_FILIAL = '" + xFilial(cAliasGF) + "' AND " + cAliasGF + ".D_E_L_E_T_ <> '*' " + " AND " + cPrefGf + "_NRRECO = '" + SPACE(LEN(&(cAliasGF + "->" + cAliasGF + "_NRRECO"))) + "' "
 If nPosGf > 0
  cSql += aCond[nPosGf,2]
 ElseIf (nPosGlo := aScan(aCond, {| aVet | aVet[1] == cAliasGF+"GLO"})) > 0
  cSql += aCond[nPosGlo,2]
 Endif
 cSql += " JOIN " + RetSQLName("GE0") + " GE0 ON GE0.GE0_NUMEXT = " + cPrefGf + "_NREXTC AND GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.D_E_L_E_T_ <> '*' "
 cSql += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = " + cPrefGe + "_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_STATUS >= '4' "
 If nPosGcz > 0
  cSql += aCond[nPosGcz,2]
 Endif
 cSql += cJoinDes
 cSql += cWhere

 cSQL += " UNION ALL "
 cSQL += "SELECT 'PACOTE' AS TIPO, GCZ.GCZ_NRFATU AS FATURA, " + cSelectPct + ", " + cPrefGg + "_VALREP AS VALOR, '' QRY_NREXTMGF, "
 cSql += "" + cAliasGG + ".R_E_C_N_O_ "
 cSQL += " FROM " + RetSQLName(cAliasGG) + " " + cAliasGG
 cSQL += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = " + cPrefGg + "_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql += " LEFT JOIN " + RetSQLName("GE0") + " GE0 ON GE0.GE0_NUMEXT = " + cPrefGg + "_NREXTC AND GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.D_E_L_E_T_ <> '*' "
 cSql += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = " + cPrefGg + "_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_STATUS >= '4' "
 If nPosGcz > 0
  cSql += STRTRAN(aCond[nPosGcz,2], cAlias, cAliasGG)
 Endif
 cSql += cJoinPct
 cSql += cWherePct
 cSql += " AND " + cPrefGg + "_NREXTM = '" + SPACE(LEN(GDX->GDX_NREXTM)) + "' "
 cSQL += " UNION ALL "
 cSQL += "SELECT  'RECURSO' AS TIPO, GF0.GF0_NRFATU AS FATURA, " + cSelect + ", " + cPrefGf + "_VLRREC AS VALOR, " + cPrefGf + "_NREXTM QRY_NREXTMGF, "
 cSql += "" + cAliasGF + ".R_E_C_N_O_ "
 cSql += " FROM " + RetSqlName(cAlias) + " " + cAlias
 cSql += " JOIN " + RetSQLName("SRA") + " SRA ON SRA.RA_CODIGO  = " + cPrefGe + "_CODCRM AND SRA.RA_FILIAL  = '" + xFilial("SRA") + "' AND SRA.D_E_L_E_T_ <> '*' "
 cSql += " JOIN " + RetSQLName("GCZ") + " GCZ ON GCZ.GCZ_NRSEQG = " + cPrefGe + "_NRSEQG AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_STATUS >= '4' "
 If nPosGcz > 0
  cSql += aCond[nPosGcz,2]
 Endif
 cSql += " JOIN " + RetSQLName(cAliasGF) + " " + cAliasGF + " ON " + cPrefGf + "_SEQDES = " + cPrefGe + "_SEQDES AND " + cPrefGf + "_FILIAL = '" + xFilial(cAliasGF) + "' AND " + cAliasGF + ".D_E_L_E_T_ <> '*' "
 If nPosGf > 0
  cSql += aCond[nPosGf,2]
 ElseIf (nPosRec := aScan(aCond, {| aVet | aVet[1] == cAliasGF+"REC"})) > 0
  cSql += aCond[nPosRec,2]
 Endif
 cSql += " JOIN " + RetSQLName("GE0") + " GE0 ON GE0.GE0_NUMEXT = " + cPrefGf + "_NREXTC AND GE0.GE0_FILIAL = '" + xFilial("GE0") + "' AND GE0.D_E_L_E_T_ <> '*' "
 cSQL += " JOIN " + RetSQLName("GF0") + " GF0 ON GF0.GF0_FILIAL = '" + xFilial("GF0") + "' AND GF0.GF0_NUMREC = " + cPrefGf + "_NRRECO AND GF0.D_E_L_E_T_ <> '*' "
 cSql += cJoinDes
 cSQL += cWhere

 cSQL += cOrderBy

 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRY"
 DbSelectArea("QRY")
 DbGoTop()

 While !Eof()
  If lGerExt
   If aScan(aVetFil, {| aVet | aVet[1]+aVet[2] == QRY->QRY_CODPRE+QRY->QRY_CODLOC }) > 0
    DbSkip()
    Loop
   Endif

   If QRY->VALOR > 0
    aAdd(aCols, {"LBNO", QRY->TIPO, QRY->VALOR, QRY->FATURA, SUBSTR(QRY->QRY_DATDES,7,2)+"/"+SUBSTR(QRY->QRY_DATDES,5,2)+"/"+SUBSTR(QRY->QRY_DATDES,1,4), QRY->GCZ_NOME, QRY->QRY_CODDES, QRY->DESCRI, QRY->QRY_CODLOC, QRY->QRY_CODCRM, QRY->RA_NOME, QRY->GCZ_REGATE, QRY->GCZ_NRSEQG, QRY->GCZ_NRGUIA, QRY->QRY_SEQDES, .F.})
    aAdd(aRecNo, QRY->R_E_C_N_O_)
   EndIf

  Else
   If aScan(aVetFil, {| aVet | aVet[1]+aVet[2] == QRY->CODPRE+QRY->CODLOC}) == 0
    If aScan(aVetFil, {| aVet | aVet[1]+aVet[2] == QRY->CODPRE+Space(Len(GCS->GCS_CODLOC))}) == 0
    	DbSkip()
   	 Loop
  	 Endif
   Endif

   If nPos == 0 .Or. QRY->CODPRE <> aCols[nPos, 1] .Or. ;
                     QRY->CODLOC <> aCols[nPos, 2] .Or. ;
                     QRY->CODCRM <> aCols[nPos, 3]
    aAdd(aCols, {QRY->CODPRE, QRY->CODLOC, QRY->CODCRM, 0, {}, cAlias } )
    nPos := len(aCols)
   Endif

   If ALLTRIM(QRY->TIPO) $ ("CONTA/RECURSO/PACOTE") //Valor de repasse ou valor recuperado
    aCols[nPos, 4] := aCols[nPos, 4] + QRY->VALOR
   Else
    aCols[nPos, 4] := aCols[nPos, 4] - QRY->VALOR
   Endif
   aAdd(aCols[nPos, 5], {ALLTRIM(QRY->TIPO), QRY->R_E_C_N_O_})
  Endif

  DbSkip()
 End

 If Empty(aCols) .And. lGerExt
  aAdd(aCols, {"LBNO", "", 0, "", CTOD("  /  /  "), "", "", "", "", "", "", "", "", "", "", .F.})
 Endif

 DbCloseArea()
 DbSelectArea(cAliasOld)

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_Ret1Prcบ Autor ณSaude               บ Data ณ01/10/08     บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna dados do Titulo Principal                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_Ret1Prc(cPrefixo, cNum)
Local aAreaOld := GetArea()
Local c1Parc   := "", cSql := ""

cSql := "SELECT MIN(E2_PARCELA) PARCELA "
cSql += " FROM " + RetSqlName("SE2") + " SE2 "
cSql += " WHERE SE2.D_E_L_E_T_ <> '*' AND SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
cSql += " AND SE2.E2_PREFIXO = '" + cPrefixo + "' "
cSql += " AND SE2.E2_NUM     = '" + cNum     + "' "

cSql := ChangeQuery(cSql)

TCQuery cSql New Alias "QRY"
DbSelectArea("QRY")

c1Parc := PADR(QRY->PARCELA, TAMSX3("E2_PARCELA")[1])

DbCloseArea()

RestArea(aAreaOld)

Return(c1Parc)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_ExclTitบ Autor ณSaude               บ Data ณ  09/06/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณExclui titulo no contas a pagar                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_ExclTit(cPref, cE2Num, cTipo)
Local lRet     := .T.
Local aTitulo  := {}
Local aAreaOld := GetArea()
Local cSql     := ""
Local cImpostos	:= MVTAXA + "|" + MVTXA + "|" + MVIRF + "|" + MVINSS + "|" + MVCOFINS + "|" + MVPIS + "|" + MVCS + "|" + MVISS + "|" + MVABATIM

cImpostos := StrTran(cImpostos,"|","','")

Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
Private lMSErroAuto := .F. // inicializa como falso, se voltar verdadeiro e' que deu erro

cSql := "SELECT E2_PREFIXO, E2_NUM, E2_TIPO, E2_PARCELA "
cSql += " FROM " + RetSqlName("SE2") + " SE2 "
cSql += " WHERE SE2.D_E_L_E_T_ <> '*' AND SE2.E2_FILIAL = '" + xFilial("SE2") + "'"
cSql += " AND SE2.E2_PREFIXO = '" + cPref + "' "
cSql += " AND SE2.E2_NUM     = '" + cE2Num + "' "
cSql += " AND SE2.E2_TIPO    NOT IN ('" + cImpostos + "') "
cSql += " ORDER BY E2_PARCELA "

cSql := ChangeQuery(cSql)

TCQuery cSql New Alias "QRY"

DbSelectArea("QRY")
While !EOF() .And. lRet

	aTitulo      :={	{"E2_FILIAL"  , xFilial("SE2")	, Nil}, ;
						{"E2_PREFIXO" , QRY->E2_PREFIXO	, Nil}, ;
						{"E2_NUM"     , QRY->E2_NUM		, Nil}, ;
						{"E2_TIPO"    , QRY->E2_TIPO	, Nil}, ;
						{"E2_PARCELA" , QRY->E2_PARCELA	, Nil}, ;
						{"E2_ORIGEM"  , "HSPAHM34"		, Nil}}

	MSExecAuto({|t,u,v| FINA050(t,u,v)}, aTitulo,, 5)

	If lMSErroAuto
		lRet := .F.
		MostraErro()
	EndIf

	DbSelectArea("QRY")
	DbSkip()
EndDo

DbCloseArea()
RestArea(aAreaOld)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_VerHoraบAutor  ณMicrosiga           บ Data ณ  03/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se a Hora Incial e Final devera sofrer Aumento     บฑฑ
ฑฑบ          ณna da Diferen็a de Minutos qdo Informado ณhhhh\mm           บฑฑ
ฑฑบ          ณnao cheios nos parametros e no Apontamento do Plantao       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestใo Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function FS_VerHora(cHoraI,cHoraF)
Local nAcertam:=0

If SUBSTR(cHoraI,4,2)=="00" .and. SUBSTR(cHoraF,4,2)=="59"
	nAcertam:=nAcerto   //Incrementa a Diferenca da Hora
ElseIf 	SUBSTR(cHoraI,4,2)=="59" .and. SUBSTR(cHoraF,4,2)=="00"
	nAcertam:= (-1 * nAcerto) //decrementa a Diferenca da Hora
Else
	nAcertam:=0
Endif

Return (nAcertam)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DelReg บAutor  ณDarcio Ribeiro Sporlบ Data ณ  31/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para atualizar os registros na exclusao do    บฑฑ
ฑฑบ          ณExtrato Medico, para que o mesmo possa ser gerado novamente.บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DelReg(cNREXTM)
LOCAL aArea := GetArea()
LOCAL dData := CtoD("  /  /  ")
LOCAL cQry	:= ""

cQry := "SELECT R_E_C_N_O_ RECDEL, GN4_DATINI DATINI"
cQry += "FROM " + RetSqlName("GN4") + " "
cQry += "WHERE GN4_FILIAL = '" + xFilial("GN4") + "' "
cQry += "  AND GN4_NREXTM = '" + cNREXTM + "' "
cQry += "  AND D_E_L_E_T_ = ' ' "

cQry := ChangeQuery(cQry)
TCQUERY cQry NEW ALIAS "TMPGN4"

dData := TMPGN4->DATINI
While TMPGN4->(!Eof())
	DbSelectArea("GN4")
	DbGoTo(TMPGN4->RECDEL)
		RecLock("GN4", .F.)
			GN4->GN4_NREXTM := ""
			GN4->GN4_VLRDIU := 0
			GN4->GN4_VLRNOT := 0
			GN4->GN4_VLRFER := 0
			GN4->GN4_FATORH := 0
			GN4->GN4_QTDDIU := 0
			GN4->GN4_QTDNOT := 0
			GN4->GN4_QTDFER := 0
			GN4->GN4_DATREF := StoD("")
			GN4->GN4_VLRTOT := 0
			GN4->GN4_CODPRE := ""
		MsUnLock()
	TMPGN4->(DbSkip())
End

DbSelectArea("TMPGN4")
DbCloseArea()

RestArea(aArea)
Return(dData)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DelGEX บAutor  ณDarcio Ribeiro Sporlบ Data ณ  31/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para deletar o registro da tabela GEX, caso   บฑฑ
ฑฑบ          ณo extrato medico tenha sido excluido.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_DelGEX(cCODPRE, cCODLOC, dData)
LOCAL aArea := GetArea()

DbSelectArea("GEX")
DbSetOrder(1)
If DbSeek(xFilial("GEX") + cCODPRE + cCODLOC + dData)
	RecLock("GEX", .F.)
		DbDelete()
	MsUnLock()
EndIf

RestArea(aArea)
Return
