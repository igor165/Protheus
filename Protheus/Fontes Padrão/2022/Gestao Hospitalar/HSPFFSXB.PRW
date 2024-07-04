#INCLUDE "HSPFFSXB.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"

// Funções de filtragem das consultas SXB.
Static __RetGXB 	:= ""  // Var Statica para Retorno
Static __RetGm8 	:= ""  // Var Statica para Retorno
Static __cRetSix := ""
Static __cRetOpc := 0

Function HS_FilGbj()
Local cSqlFil := "@"

cSqlFil += "RA_FILIAL = '" + xFilial("SRA") + "' AND D_E_L_E_T_ <> '*' AND "
cSqlFil += "RA_CODIGO <> '" + Space(Len(SRA->RA_CODIGO)) + "' AND "
cSqlFil += "(RA_CODIGO IN (SELECT GBJ.GBJ_CRM FROM " + RetSqlName("GBJ") + " GBJ "
cSqlFil +=                "WHERE GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ.D_E_L_E_T_ <> '*' AND "
cSqlFil +=                      "GBJ.GBJ_CRM = RA_CODIGO AND GBJ.GBJ_STATUS = '1'"


If Type("cGbjCodEsp") # "U" .And. !Empty(cGbjCodEsp)
	cSqlFil += " AND '" + cGbjCodEsp + "' IN (GBJ.GBJ_ESPEC1, GBJ.GBJ_ESPEC2, GBJ.GBJ_ESPEC3))"
	cSqlFil += " OR RA_CODIGO IN (SELECT GFP.GFP_CODCRM FROM " + RetSqlName("GFP") + " GFP"
	cSqlFil +=                  " WHERE GFP.GFP_FILIAL = '" + xFilial("GFP") + "' AND GFP.D_E_L_E_T_ <> '*' AND GFP.GFP_CODCRM = RA_CODIGO AND"
	cSqlFil +=                        " GFP.GFP_CODESP = '" + cGbjCodEsp + "'"
EndIf

If Type("cGbjTipPro") # "U" .And. !Empty(cGbjTipPro)
	cSqlFil += " AND GBJ.GBJ_TIPPRO IN (" + HS_InSql(cGbjTipPro) + ") "
EndIf

cSqlFil += "))"
Return(cSqlFil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_CENTCUS   ³ Autor ³ José Orfeu       ³ Data ³29/04/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Centro de Custo de acordo com os Parametro         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_CentCus(nModo)
Local cCentCus := "", cConta := ""
Local lRet := .F.

cCentCus := IIF(CtbInUse(), CTT->CTT_CUSTO, SI3->I3_CUSTO)
cConta   := IIF(CtbInUse(),             "", SI3->I3_CONTA) // Verificar qual o campo que define a conta contabil no CTT

If nModo == 1 // Centro de Custo Produtivo
	lRet := SubStr(cCentCus, 1, GetMV("MV_TAMPREF")) == AllTrim(GetMV("MV_PREFCCP")) .And. Empty(cConta)
ElseIf nModo == 2 // Centro de Custo Produtivo e Não Produtivo
	lRet := (SubStr(cCentCus, 1, GetMV("MV_TAMPREF")) == AllTrim(GetMV("MV_PREFCCP")) .Or. ;
			SubStr(cCentCus, 1, GetMV("MV_TAMPREF")) == AllTrim(GetMV("MV_PREFCCN"))) .And. Empty(cConta)
EndIf
Return(lRet)

Function HS_LocPad(cCodPro, cAlmOri)
Local lRet := .F., lRet1 := .F., lRet2 := .F., cAliasOld := Alias()

lRet1 := IIF(M->GAI_REQUIS =='1', SB1->B1_REQUIS $ '13', .T.) .AND. SB1->B1_GRUPO == M->GAJ_CODTES

DbSelectArea("SB2")
DbSetOrder(1)
If cAlmOri == Nil .Or. Empty(cAlmOri)
	lRet2 := DbSeek(xFilial("SB2") + PadR(cCodPro, Len(SB2->B2_COD)))
Else
	lRet2 := DbSeek(xFilial("SB2") + PadR(cCodPro, Len(SB2->B2_COD)) + PadR(cAlmOri, Len(SB2->B2_LOCAL)))
EndIf

lRet := lRet1 .And. lRet2
DbSelectArea(cAliasOld)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FILLOTE   ³ Autor ³                  ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Planos relacionados a um determinado convenio.     ³±±
±±³          ³  Utilizada pela consulta GAT e GAT001                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracao³  Eduardo AlveS:																																												³±±
±±³										|		1)Inclusao do parametro lLotNFat que indica se serao    		³±±
±±³          |  		filtrados somente os lotes nao faturados (.T.).         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilLote(cFunName)
Local cRet     := "@D_E_L_E_T_ <> '*' "

If !(cFunName $ "HSPAHP12/HSPAHM50")
	cRet += " AND GAT_FILIAL = '" + xFilial("GAT") + "' "
Else
	If Type("cFilGuia") <> "U"
		If Empty(cFilGuia)
			If Type("cGATFilial") <> "U" .And. !Empty(cGATFilial)
				If At("@", cGATFilial) == 0
					cRet += " AND GAT_FILIAL IN (" + HS_InSql(cGATFilial, 2) + ") "
				EndIf
			EndIf
		Else
			cRet += " AND GAT_FILIAL = '" + cFilGuia + "' "
		EndIf
	EndIf
EndIf

If Type("lGATLotFat") <> "U" .And. lGATLotFat
	cRet += " AND GAT_DTFTLT <> '" + SPACE(Len(GAT->GAT_DTFTLT))+ "' "
EndIf

If Type("cGATCodCon") <> "U" .And. !Empty(cGATCodCon)
	cRet += " AND GAT_CODCON = '" + cGATCodCon + "' "
EndIf

If Type("cGATCodPla") <> "U" .And. !Empty(cGATCodPla)
	cRet += " AND GAT_CODPLA = '" + cGATCodPla + "' "
EndIf

If Type("cGATNrFatu") <> "U" .And. !Empty(cGATNrFatu)
	cRet += " AND GAT_NRFATU = '" + cGATNrFatu + "' "
EndIf

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FILPLA    ³ Autor ³ José Orfeu       ³ Data ³13/04/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Planos relacionados a um determinado convenio      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilPla()
Local lRet := .T.

If Type("cGcmCodCon") # "U" .AND. IIf(Type("M->GAY_CODCON") == "U", .T., !EMPTY(M->GAY_CODCON))
	If !Empty(cGcmCodcon)
		DbSelectArea("GCM")
		lRet := GCM->GCM_CODCON == cGcmCodcon
	Endif
Endif
If Type("cGcsCodLoc") # "U"
	GM0->(DbSetOrder(1))
	GM0->(lRet := !DbSeek(xFilial("GM0") + cGcsCodLoc + GCM->GCM_CODPLA))
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FILGF3    ³ Autor ³ Paulo César      ³ Data ³23/11/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Sala relacionada a um Médico ou Procedimento       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGF3()
Local	cRetSql := "@GF3_FILIAL = '" + xFilial("GF3") + "' AND D_E_L_E_T_ <> '*' "

If Type("M->GM8_CODCRM") == "U"
	cRetSql += " AND GF3_CODIGO <> ''"
elseif !EMPTY(M->GM8_CODCRM)
	cRetSql += " AND GF3_CODIGO IN (SELECT DISTINCT GNC.GNC_CODSAL "
	cRetSql += "                    FROM "+ RetSQLName("GNC") +" GNC JOIN "+ RetSQLName("GM6") +" GM6 ON GNC.GNC_CODSAL = GM6.GM6_CODSAL AND GM6.D_E_L_E_T_ <> '*'"
	cRetSql += "                    WHERE GM6_CODCRM = '" + M->GM8_CODCRM + "') "
Else
	If !EMPTY(M->GM8_CODPRO)
		cRetSql += " AND GF3_CODIGO IN (SELECT DISTINCT GNC.GNC_CODSAL "
		cRetSql += "                    FROM "+ RetSQLName("GNC") +" GNC "
		cRetSql += "                    WHERE GNC_CODPRO = '" + M->GM8_CODPRO + "')"
	EndIf
EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FILGCM1   ³ Autor ³ Monica Y Miyamoto³ Data ³05/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Planos relacionados a um determinado convenio SQL  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGCM1()
Local	cRetSql := "@GCM_FILIAL = '" + xFilial("GCM") + "' AND D_E_L_E_T_ <> '*' "

cGcmCodCon := M->GAT_CODCON

If Type("cGcmCodCon") # "U"
	cRetSql += "AND GCM_CODCON = '" + cGcmCodCon + "'"
EndIf
Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilPac    ³ Autor ³ Saude            ³ Data ³05/10/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra cadastros de pacientes                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilPac()
Local cRet := ""

Default cGbhDtNasc := IIf(Type(cGbhDtNasc) == "U", CToD(""), cGbhDtNasc)
Default cGbhSexo   := IIf(Type(cGbhSexo  ) == "U", ""      , cGbhSexo  )

If !Empty(cGbhDtNasc) .And. Empty(cGbhSexo)
	cGbhDtNasc := CToD("")
EndIf

If Empty(cGbhDtNasc) .And. Empty(cGbhSexo)
	cRet := xFilial("GBH")
Else
	If Empty(cGbhDtNasc)
		cRet := xFilial("GBH") + cGbhSexo
	Else
		cRet := xFilial("GBH") + cGbhSexo + DTOS(cGbhDtNasc)
	EndIf
EndIf

Return(cRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FilGSB ³ Autor ³ Saude                 ³ Data ³ 01/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Filtra Relac.  Ender x Prontuario do paciente    SAME      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilGSB()
Local	cRetSql := "@GSB_FILIAL = '" + xFilial("GSB") + "' AND D_E_L_E_T_ <> '*' "

If Type("cGsbRegGer") # "U" .And. !Empty(cGsbRegGer)
	cRetSql += "AND GSB_REGGER = '" + cGsbRegGer + "'"
EndIf
If GSB->(FieldPos("GSB_REGATE")) > 0
	If Type("cRegate") # "U" .And. !Empty(cRegate)
		cRetSql += "AND GSB_REGATE = '" + cRegate + "'"
	EndIf
Endif
Return(cRetSql)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FilGSB ³ Autor ³ Saude               ³ Data ³ 01/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Filtra Enderecos SAME                                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilGSD()
Local	cRetSql := "@GSD_FILIAL = '" + xFilial("GSD") + "' AND D_E_L_E_T_ <> '*' AND GSD_EATIVO = '0' AND GSD_STATUS = '0' "

If Type("cGsDCtrl") # "U" .And. !Empty(cGsDCtrl)
	cRetSql += "AND GSD_ENDTIP IN (" + HS_InSql(cGsDCtrl) + ") "
EndIf

If Type("cGsDTipo") # "U" .And. !Empty(cGsDTipo)
	cRetSql += "AND GSD_TIPEND IN (" + HS_InSql(cGsDTipo) + ") "
EndIf

If (Type("cGsDCtrl") # "U" .AND. Len(cGsDCtrl) == 1) .OR. ( Type("cGsDTipo") # "U" .AND. Len(cGsDTipo) == 1)
	cRetSql := ""
	If Type("cGsDCtrl") # "U" .And. !Empty(cGsDCtrl)  .AND. Len(cGsDCtrl) == 1
		cRetSql += " GSD->GSD_ENDTIP == '" + cGsDCtrl + "'"
	EndIf
	If Type("cGsDTipo") # "U" .And. !Empty(cGsDTipo)  .AND. Len(cGsDTipo) == 1
		If Empty(cRetSql)
			cRetSql += " GSD->GSD_TIPEND == '" + cGsDTipo + "'"
		Else
			cRetSql += " .AND. GSD->GSD_TIPEND == '" + cGsDTipo + "'"
		Endif
	EndIf
EndIf


Return(cRetSql)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FilGSB ³ Autor ³ Saude               ³ Data ³ 01/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Filtra relacionamento de usuarios com o setor de atendimento±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
// Filtra relacionamento de usuários com o setor de atendimento
Function HS_FilGcs()

Local lRet		:= .T.
Local lRetGcs	:= .T.
Local lRetGm1	:= .T.
Local cAliasOld	:= Alias()

// lFarmacia indica que vem da rotina de farmácia
If Type("lFarmacia") == "L"
	If readvar() == "MV_PAR01" // Se for a primeira pergunta filtra somente farmácia
		cGcsTipLoc = "A"
	Elseif readvar() == "MV_PAR02" // Se for a segunda pergunta filtra o que não for farmácia
		cGcsTipLoc = "0123456789C"
	Endif
Endif

IF Type("cCirCodLoc") # "U" .And. !Empty(cCirCodLoc) .And. cCirCodLoc == GCS->GCS_CODLOC
	lRet := .T.
Else
	IF Type("cGcsTipLoc") # "U" .And. !Empty(cGcsTipLoc)
		lRetGcs := GCS->GCS_TIPLOC $ cGcsTipLoc
	EndIf
	IF lRetGcs .And. Type("lFilGm1") # "U" .And. lFilGm1
		DbSelectArea("GM1")
		DbSetOrder(1)
		lRetGm1 := DbSeek( xFilial("GM1") + GCS->GCS_CODLOC + cUserName )
		DbSelectArea(cAliasOld)
	EndIf
 	lRet := lRetGcs .And. lRetGm1
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FilGSB ³ Autor ³ Saude               ³ Data ³ 01/05/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³Filtra relacionamento de tipo de guias X planos de conveniosº±±
±±º          ³permitidos para usar esse filtro a variavel cGcsCodLoc      º±±
±±º          ³precisa ser carregadas com o setor selecionado no programa eº±±
±±º          ³a variavel cGcuCodTpg precisa ser carregada com o codigo do º±±
±±º          ³tipo de guia selecionado no programa que foi pressionado F3.º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilGcv()
Local cRetSql := "@GCV_FILIAL = '" + xFilial("GCV") + "' AND D_E_L_E_T_ <> '*' "

// Amarração tipo de guias x planos permitidos para o tipo de guia selecionada
If Type("cGcuCodTpg") # "U" .And. !Empty(cGcuCodTpg)
	cRetSql += " AND GCV_CODTPG = '" + cGcuCodTpg + "' "
EndIf

// Amarração setor x planos não permitidos no setor
If Type("cGcsCodLoc") # "U" .And. !Empty(cGcsCodLoc)
	cRetSql += " AND GCV_CODPLA NOT IN (SELECT GM0.GM0_CODPLA "
	cRetSql += "                        FROM " + RetSqlName("GM0") + " GM0 "
	cRetSql += "                        WHERE GM0.GM0_FILIAL = '" + xFilial("GM0") + "' AND GM0.D_E_L_E_T_ <> '*' "
	cRetSql += "                        AND GM0.GM0_CODLOC = '" + cGcsCodLoc + "') "
EndIf

// Amarração pacientes x planos
If Type("cGcyRegGer") # "U" .And. !Empty(cGcyRegGer)
	cRetSql += " AND (GCV_CODPLA IN (SELECT GD4.GD4_CODPLA "
	cRetSql += "                     FROM " + RetSqlName("GD4") + " GD4 "
	cRetSql += "                     JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON = GD4.GD4_CODCON AND GA9.GA9_TIPCON = '0' AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
	cRetSql += "                     WHERE GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' "
	cRetSql += "                     AND GD4.GD4_REGGER = '" + cGcyRegGer + "' AND GD4.GD4_IDEATI = '1' ) "
	cRetSql += "      OR GCV_CODPLA IN (SELECT GCM.GCM_CODPLA "
	cRetSql += "                        FROM " + RetSqlName("GCM") + " GCM "
	cRetSql += "                        JOIN " + RetSqlName("GA9") + " GA9 ON GA9.GA9_CODCON = GCM.GCM_CODCON AND GA9.GA9_TIPCON = '1' AND GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' "
	cRetSql += "                        WHERE GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
	cRetSql += "                        AND GCM.GCM_STATUS = '1' ) "
	cRetSql += "      )"
Else
	cRetSql += " AND GCV_CODPLA IN (SELECT GCM.GCM_CODPLA "
	cRetSql += "                    FROM " + RetSqlName("GCM") + " GCM "
	cRetSql += "                    WHERE GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' "
	cRetSql += "                    AND GCM.GCM_STATUS = '1') "
EndIf

Return(cRetSql)

Function HS_FilGcx()
Local lRet := .T., lRetGcx := .T., lRetGm2 := .T., lRetCPl := .F.
Local cCodCon := "", cLisTab := "", cAliasOld := Alias()

If Type("cGcuCodTpg") # "U" .And. cGcuCodTpg <> Nil
	// Verifica se o procedimento é permitido na guia selecionada
	If !(lRetGcx := GCX->GCX_CODTPG == cGcuCodTpg)
		Return(lRetGcx)
	EndIf
EndIf

If Type("cGcsCodLoc") # "U" .And. cGcsCodLoc <> Nil
	// Verifica se o procedimento é permitido no setor
	DbSelectArea("GM2")
	DbSetOrder(1)
	If !(lRetGm2 := DbSeek(xFilial("GM2") + cGcsCodLoc + GCX->GCX_CODPRO))
		DbSelectArea(cAliasOld)
		Return(lRetGm2)
	EndIf
EndIf

If Type("cGczCodPla") # "U" .And. cGczCodPla <> Nil
	// Verifica se o procedimento pertence as tabelas configuradas no convenio / plano.
	cCodCon := Posicione("GCM",2, xFilial("GCM") + cGczCodPla, "GCM_CODCON")
	cTabPro := HS_RCfgCP(cCodCon, cGczCodPla, "_TABPRO")
	cLisTab := AllTrim(Posicione("GA7", 1, xFilial("GA7") + GCX->GCX_CODPRO, "GA7_TABPRO"))

	If !(lRetCPl := PadR(cTabPro, Len(GA8->GA8_TABPRO)) + "/" $ cLisTab)
		DbSelectArea("GC6")
		DbSetOrder(1)
		DbSeek(xFilial("GC6") + cCodCon + cGczCodPla)
		While !Eof() .And. GC6->GC6_CODCON == cCodCon .And. GC6->GC6_CODPLA == cGczCodPla
			If (lRetCPl := PadR(GC6->GC6_TABPRO, Len(GA8->GA8_TABPRO)) + "/" $ cLisTab)
				Exit
			EndIf

			DbSkip()
		End
	EndIf
Else
	lRetCPl := .T.
EndIf

lRet := lRetGcx .And. lRetGm2 .And. lRetCPl

DbSelectArea(cAliasOld)
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_FILGCA    º Autor ³ Gilson da Silva º Data ³  06/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filtra a Consulta SXB da Tabela GCA pelo campo GCA_TIPO    º±±
±±º          ³ GCA_TIPO == "0"(Materiais)  GCA_TIPO =="1"(Medicamentos)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FILGCA()
Local lRet := .T.

If ReadVar() == "M->GCM_TABMAT"
	cGcaTipo := '0'
ElseIf ReadVar() == "M->GCM_TABMED"
	cGcaTipo := '1'
EndIf

If Type("cGcaTipo") # "U"
	lRet := GCA->GCA_TIPO == cGcaTipo //Deve-se declaraR a variavel cGcaTipo no fonte de Origem. Exemplo HSPAHA18.PRW.
EndIf

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_FILG1R    º Autor ³ Gilson da Silva º Data ³  07/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Filtra a Consulta SXB da Tabela SB1 pelo campo GBI_TIPO    º±±
±±º          ³ GBI_TIPO == "1"(Materiais)  GBI_TIPO =="2"(Medicamentos)   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FILG1R()
Local	cRetSql := "@B1_FILIAL = '" + xFilial("SB1") + "' AND D_E_L_E_T_ <> '*'"
Local	cGbiTipo := "014"

If Type("cG1RTipo") <> "U"
	cGbiTipo := cG1RTipo //Variavel Private declarada no fonte de origem. Ex. HSPAHA18.PRW.
EndIf



cRetSql += " AND B1_COD IN (SELECT GBI_PRODUT FROM " + RetSqlName("GBI") + " GBI"
cRetSql += " WHERE GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*'"
cRetSql += " AND B1_COD = GBI.GBI_PRODUT"

If Type("cGbiMovEst") <> "U" .AND. !Empty(cGbiMovEst)
	cRetSql += " AND GBI.GBI_MOVEST = '" + cGbiMovEst + "' "
EndIf

If Type("cGBICtrPsc") <> "U" //Variavel para listar medicamentos que controlam psicotropicos
	cRetSql += " AND GBI.GBI_CTRPSC IN (" + HS_InSql(cGBICtrPsc) + ") "
EndIf


If Type("cGbiTipKit") <> "U" .And. "4" $ cGbiTipo
	cRetSql += " AND ((GBI.GBI_TIPO <> '4' AND GBI.GBI_TIPO IN (" + HS_InSql(cGbiTipo) + "))"
	cRetSql += " OR   (GBI.GBI_TIPO =  '4' AND GBI.GBI_TIPKIT = '" + cGbiTipKit + "')))"
Else
	cRetSql += " AND GBI.GBI_TIPO IN (" + HS_InSql(cGbiTipo) + "))"
EndIf

cRetSql += " AND B1_MSBLQL = '2'" //BOPS 134434: apresenta somente os produtos nao bloqueados.

If Type("cGczCodPla") # "U" .And. !EMPTY(cGczCodPla)
 cRetSql += " AND B1_COD IN  (SELECT GCB.GCB_PRODUT " +;
                            " FROM " + RetSqlName("GCB") + " GCB " +;
                            " WHERE GCB.GCB_FILIAL = '" + xFilial("GCB") + "' AND GCB.D_E_L_E_T_ <> '*'	" +;
                            "	AND (GCB.GCB_CODTAB IN (SELECT GD9.GD9_CODMAT " +;
                            "                         FROM " + RetSqlName("GD9") + " GD9 " +;
                            "						               				WHERE GD9.GD9_FILIAL = '" + xFilial("GD9") + "' AND GD9.D_E_L_E_T_ <> '*' " +;
                            "     				             			AND GD9.GD9_CODPLA = '" + cGczCodPla + "') " +;
                            "					 OR " +;
                            "					 GCB.GCB_CODTAB IN (SELECT GDA.GDA_CODMED " +;
                            "                         FROM " + RetSqlName("GDA") + " GDA " +;
                            " 										              WHERE GDA.GDA_FILIAL = '" + xFilial("GDA") + "' AND GDA.D_E_L_E_T_ <> '*' " +;
                            "		               								AND GDA.GDA_CODPLA = '" + cGczCodPla + "')  " +;
                            "					) " +;
                            "	AND GCB.GCB_CODTAB IN (SELECT GCA.GCA_CODTAB " +;
                            "                        FROM " + RetSqlName("GCA") + " GCA " +;
                            "	                       WHERE GCA.GCA_FILIAL = '" + xFilial("GCA") + "' AND GCA.D_E_L_E_T_ <> '*' " +;
                            "                        AND GCA.GCA_TABATV = '1') " +;
                            " ) "
EndIf

If ExistBlock("HSFILG1R")
	cRetSql := ExecBlock("HSFILG1R", .F., .F., {cRetSql})
EndIF

Return(cRetSql)
/*********************************************************************************************************/
Function HS_SqlGav()
Local cTipLei := "", cSqlExists := "", cFiltroSql := ""

If Empty(cGcsCodLoc)
	cGcsCodLoc := M->GCY_CODLOC
EndIf

If Type("cGavTipo") # "U" .And. !Empty(cGavTipo)
	cTipLei := cGavTipo
EndIf

cFiltroSql := "@GAV_FILIAL = '" + xFilial("GAV") + "' AND D_E_L_E_T_ <> '*' AND GAV_CODLOC <> '  ' "

IF Type("cGcyAtendi") # "U" .And. cGcyAtendi == "0" .And. Type("cGcsCodLoc") # "U" .And. Empty(cGcsCodLoc) // 0-Internação
	cSqlExists := 	" AND GAV_CODLOC IN (SELECT GCS_CODLOC FROM " + RetSqlname("GCS") + " GCS " + ;
					"WHERE GCS.GCS_FILIAL = '" + xFilial("GCS") + "' AND GCS.D_E_L_E_T_ <> '*' AND " + ;
					"GCS.GCS_CODLOC = GAV_CODLOC AND GCS.GCS_TIPLOC IN ('3', '4') AND " + ;
					"(GCS.GCS_CTRMOV = '1' AND GAV_TIPO IN ('1', '4', '5') OR " + ;
					"GCS.GCS_CTRMOV = '0' AND GAV_TIPO IN ('1', '2', '4')))"
EndIf

If Type("cGcsCodLoc") # "U" .And. !Empty(cGcsCodLoc)
	cFiltroSql += " AND GAV_CODLOC = '" + cGcsCodLoc + "'"
EndIf

If Type("cGbhSexo") # "U" .And. !Empty(cGbhSexo)
	cFiltroSql += " AND GAV_SEXO IN ('" + cGbhSexo + "', '2')"
EndIf

If Type("cStatusGAV") # "U" .And. !Empty(cStatusGAV)
	cFiltroSql += " AND GAV_STATUS = '" + cStatusGAV + "' "
EndIf

//0=Bercario;1=Posto;2=C.Cirurgico;3=Ambulatorio;4=U.T.I;5=Pre-Operatorio;6=Pos-Operatorio
If !Empty(cTipLei) .And. Empty(cSqlExists)
	cFiltroSql += " AND GAV_TIPO IN (" + HS_InSql(cTipLei) + ")"
ElseIf !Empty(cSqlExists)
	cFiltroSql += cSqlExists
EndIf

Return(cFiltroSql)

Function HS_FilGav()
 Local lRet := .T., cTipLei := ""

 If Type("cGavTipo") # "U" .And. !Empty(cGavTipo)
  cTipLei := cGavTipo
 EndIf

 If !Empty(GAV->GAV_CODLOC)
  lRet := GAV->GAV_STATUS == "0"

  IF lRet .And. Type("cGcyAtendi") # "U" .And. cGcyAtendi == "0" .And. Type("cGcsCodLoc") # "U" .And. Empty(cGcsCodLoc) // 0-Internação
   DbSelectArea("GCS")
   DbSetOrder(1)
   lRet := DbSeek(xFilial("GCS") + GAV->GAV_CODLOC) .And. GCS->GCS_TIPLOC $ "34" // 3-Enfermagem e 4-Centro Cirurgico

   cTipLei := IIf(GCS->GCS_CTRMOV == "1", "145", "124")

   DbSelectArea("GAV")
  EndIf

  If lRet .And. Type("cGcsCodLoc") # "U" .And. !Empty(cGcsCodLoc)
   lRet := GAV->GAV_CODLOC == cGcsCodLoc
  EndIf

  If lRet .And. Type("cGbhSexo") # "U" .And. !Empty(cGbhSexo)
   lRet := (GAV->GAV_SEXO == cGbhSexo .OR. GAV->GAV_SEXO == "2")
  EndIf

  //0=Bercario;1=Posto;2=C.Cirurgico;3=Ambulatorio;4=U.T.I;5=Pre-Operatorio;6=Pos-Operatorio
  If lRet .And. !Empty(cTipLei)
   lRet := GAV->GAV_TIPO $ cTipLei
  EndIf
 Else
  lRet := .F.
 EndIf
Return(lRet)

Function HS_InSql(cInSql, nLenCpo, cChrSep)
 Local cInRet := "", nForIn := 0

 Default nLenCpo := 1
 Default cChrSep := "/"

 If At(cChrSep, cInSql) == 0
  For nForIn := 1 To Len(cInSql) Step nLenCpo
   If Len(cInRet) > 0
    cInRet += ", "
   Endif

   cInRet += "'" + SubStr(cInSql, nForIn, nLenCpo) + "'"

  Next
 Else
  cInRet := "'" + StrTran(cInSql, cChrSep, "', '") + "'"
 EndIf

Return(cInRet)

Function HS_ConPac(nOrdem, lHistorico, cFiltro)

Local lIntegr	:= GetMv("MV_HSPPLS")	// Verifica se existe a integracao dos modulos PLS x GH
Local aRotMB  := {	{STR0006, "lRetCP := .T., oDlgPac:End()"        }, ; // Confirma
					{STR0014, "HS_A58('GBH',              0, 2)"   		}, ; // Visualizar
					{STR0015, "Hs_IntSen()"    												}, ; // Incluir
					{STR0016, "HS_A58('GBH', GBH->(RecNo()), 4)"   		}, ; // Alterar
					{STR0017, "Eval(bFilPad, 'GBH', oDlgPac)"      		}, ; // filtro
					{STR0005, "lRetCP :=HS_PesqGD4(), oDlgPac:End()"	}, ;//CARTEIRINHA
					{STR0018, "lRetCP := .F., oDlgPac:End()"       		}}   // Cancelar

Local oBrwPac

Local cDtNasc := IIf(Type("cGbhDtNasc") <> "U" .and. !Empty(cGbhDtNasc) , cGbhDtNasc, Iif(Type("M->GCY_DTNASC") # "U" .And. !Empty(M->GCY_DTNASC),M->GCY_DTNASC,CToD(" / / ")))
Local cSexo   := IIf(Type("cGbhSexo"  ) <> 'U' .and. !Empty(cGbhSexo), cGbhSexo  , Iif(Type("M->GCY_SEXO") # "U" .And. !Empty(M->GCY_SEXO),M->GCY_SEXO,""))
Local cRG     := IIf(Type("cGbhRG"    ) <> 'U', cGbhRG    , "")
Local cOrgEmi := IIf(Type("cGbhRGOrg" ) <> 'U', cGbhRGOrg, "")
Local cUFEmis := IIf(Type("cGbhUFEmis") <> 'U', cGbhUFEmis, "")
Local lMatvid := HS_EXISDIC({{"C", "GBH_MATVID"}},.F.)
Local lAtuGD4 := .F.

Private bFilPad := {| cAliasFilter, oDlgFilter | HS_DtvFilt(cAliasFilter), HS_AtvFilt(cAliasFilter, @cFiltro, .T., oDlgFilter, .T.)}

Private oDlgPac, lRetCP := .F.

Private aRotina := {	{"", "", 0, 1}, ; //"Pesquisar"
						{"", "", 0, 2}, ; //"Visualizar"
						{"", "", 0, 3}, ; //"Incluir"
						{"", "", 0, 4}, ; //"Alterar"
						{"", "", 0, 5}}   //"Excluir"

Default nOrdem  := 3
Default cFiltro := ""


If GBH->(FieldPos("GBH_USUARI")) == 0 .AND. !SIX->(MsSeek("GBH9"))
	nOrdem  := 3
EndIf

If lHistorico
	aRotMB := {	{STR0006, "lRetCP := .T., oDlgPac:End()"    }, ; // Confirma
				{STR0014, "HS_A58('GBH',              0, 2)"}, ; // Visualizar
				{STR0017, "Eval(bFilPad, 'GBH', oDlgPac)"   }, ; // filtro
				{STR0018, "lRetCP := .F., oDlgPac:End()"    }}   // Cancelar
EndIf

If Empty(cFiltro)
	cFiltro := FS_FilGH1(cSexo, cDtNasc, cRG, cOrgEmi, cUFEmis)
EndIf

DbSelectArea("GBH")
GBH->(DbSetOrder(nOrdem))

HS_AtvFilt("GBH", cFiltro,,, .T.)

Define MsDialog oDlgPac Title OemToAnsi(STR0019) From 000, 000 To 500, 850 Of oMainWnd PIXEL // "Lista de Pacientes"
	oBrwPac := HS_MBrow(oDlgPac, "GBH", {0, 0, 425,220},,,,,,,,,, .T.,,,,, aRotMB,, .F.)
	If lHistorico
		oBrwPac:BLDBLCLICK := {|| lRetCP := .T., oDlgPac:End()}
	Else
		If lIntegr .AND. lMatvid
		   oBrwPac:BLDBLCLICK := {|| lRetCP := .T., IIf( lAtuGD4:=HS_INCLGD4(GBH->GBH_CODPAC,GBH->GBH_MATVID) .AND. HS_EditPac(IIF(lMatvid,2,4)) .And. HS_VAltPac(GBH->GBH_CODPAC), oDlgPac:End(), lRetCP := .F.)}
		Else
			oBrwPac:BLDBLCLICK := {|| lRetCP := .T., IIf( HS_EditPac(IIF(lMatvid,2,4)) .And. HS_VAltPac(GBH->GBH_CODPAC), oDlgPac:End(), lRetCP := .F.)}
		EndIf
	EndIf
Activate MsDialog oDlgPac Centered

If Type("cGbhCodPac") <> "U" .And. lRetCP
	cGbhCodPac := GBH->GBH_CODPAC
EndIf

HS_DtvFilt("GBH")
IF lIntegr .and.  lMatvid .and.  !lAtuGD4
	 HS_INCLGD4(GBH->GBH_CODPAC,GBH->GBH_MATVID)
Endif

Return(lRetCP)

Static Function FS_FilGH1(cSexo, cDtNasc, cRG, cOrgEmi, cUFEmis)
 Local cRet := "@GBH_FILIAL = '" + xFilial("GBH") + "'"

 If !Empty(cSexo)
  cRet += " AND GBH_SEXO = '" + cSexo + "'"
 EndIf

 If !Empty(cDtNasc)
  cRet += " AND GBH_DTNASC = '" + DTOS(cDtNasc) + "'"
 EndIf

 If !Empty(cRG)
  cRet += " AND GBH_RG = '" + cRG + "'"
 EndIf

 If !Empty(cOrgEmi)
  cRet += " AND GBH_ORGEMI = '" + cOrgEmi + "'"
 EndIf

 If !Empty(cUFEmis)
  cRet += " AND GBH_UFEMIS = '" + cUFEmis + "'"
 EndIf
Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_ConGXB ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 02.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria uma consulta padrao do SXB                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_ConGXB( Expc1 )						                              			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expc1 = Variavel do get             						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_ConGXB(uReadVar)

Local aConsPad		:= {}
Local cSavAlias := Alias()
Local cSearch   := Space(55)
Local cCbx
Local oCbx
Local nPos
Local lOk       := .F.
Local aOrd      := {}
Local oDlg
Local oOk
Local oCancel
Local oSearch
Local oBmp
Local cFiltro

cFiltro 	:= "SXB->XB_COLUNA == 'DB'"

CursorWait()

SXB->(DbSetFilter({|| &cFiltro }, cFiltro))
SXB->(DbGoTop())

aAdd(aOrd, STR0001) //"Consulta"
aAdd(aOrd, STR0002) //"Descricao"

aAdd(aConsPad, {"",STR0003,""}) //"Nenhum"

Do While SXB->(!Eof())
	aAdd (aConsPad, { SXB->XB_ALIAS, SXB->(XBDescri()), AllTrim(SXB->XB_CONTEM) })
	SXB->(DbSkip())
Enddo

SXB->(DbClearFilter())

DEFINE MSDIALOG oDlg TITLE STR0004 FROM 000,000 TO 248,445 PIXEL //"Consulta..."

@ 000,000 BITMAP oBmp RESNAME 'PROJETOAP' OF oDlg SIZE 250,309 NOBORDER ADJUST PIXEL

@ 005,005 LISTBOX oList FIELDS HEADER STR0001, STR0002 SIZE 171,80 OF oDlg PIXEL //"Consulta"###"Descricao"
oList:SetArray(aConsPad)

oList:bLine 					:= { |nAt| nAt := oList:nAt, {aConsPad[nAt][1], aConsPad[nAt][2] }}
oList:bLDbLClick := { || lOk := .T., nPos := oList:nAt, oDlg:End() }

DEFINE SBUTTON oOk FROM 005,187 TYPE 1 OF oDlg ONSTOP STR0006; //"Confirmar..."
ENABLE  WHEN .T. ACTION (lOk := .T., nPos := oList:nAt, oDlg:End())

DEFINE SBUTTON oCancel  FROM 020,187 TYPE 2 OF oDlg ONSTOP STR0007; //"Abandonar..."
ENABLE  WHEN .T. ACTION (oDlg:End())

@ 095,020 COMBOBOX oCbx VAR cCbx ITEMS aOrd SIZE 119, 42 OF oDlg PIXEL WHEN .T.

@ 110,020 GET oSearch VAR cSearch SIZE 120, 10 OF oDlg PIXEL;
ON CHANGE ( nPos := aScan(aConsPad,{|x| AllTrim(cSearch) == AllTrim(x[oCbx:nAt]) }),;
												Iif( nPos > 0, (oList:nAt := nPos, oList:Refresh()), ) )

CursorArrow()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT ( nPos := aScan(aConsPad,{|x| &(uReadVar) == x[3] }),;
																																										Iif( nPos > 0,(oList:nAt := nPos, oList:Refresh()), ) )

If lOk
	__RetGXB := aConsPad[nPos][1]
Else
	__RetGXB := ""
Endif

DbSelectArea(cSavAlias)

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_RETGXB ³ Autor ³ Robson Ramiro Oliveira³ Data ³ 02.09.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Somente retorno da consulta padrao do SXB                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_RETGXB()		       				                              			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_RETGXB
Return __RetGXB

// Filtra Motivos de transferencias e cancelamentos.
Function HS_FilGm7()
 Local lRetOC := .T., lRetIB := .T.
 If Type("cGm7OriCan") # "U" .AND. !Empty(cGm7OriCan)
  lRetOC := GM7->GM7_ORICAN $ cGm7OriCan
 EndIf

 If Type("cGm7IdeBlo") # "U" .And. lRetOC
  lRetIB := GM7->GM7_IDEBLO $ cGm7IdeBlo
 EndIf
Return(lRetOC .And. lRetIB)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FILGM2 ³ Autor ³ Cibele Peria        ³ Data ³ 14.02.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da consulta padrao da tabela GM2                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_FILGM2()		                               			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ Gestao Hospitalar 									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGM2()
 Local lRet := .T.
 If Type("cGcsCodLoc") # "U"
  lRet := GM2->GM2_CODLOC $ cGcsCodLoc
 Endif
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HS_FilGm8º Autor ³Microsiga           º Data ³  10/24/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGm8()

Local aHGm8 := {}, aCGm8 := {}, nUGm8 := 0, lRetGm8 := .F.
Local oDlgGm8, cAliasOld := Alias()
Local aSize := {}, aObjects := {}, aInfo := {}, aPObjs := {}
Local nX := 0
Local aCodAge  := {}
Local cIntMar  := 0

Local aAux     := {}
Local lFilLcEsp	:= SuperGetMV("MV_FILLESP", NIL, .F.)
Local cLocGM8	:= SPACE(Tamsx3("GM8_CODLOC")[1])
Local cEspec	:= SPACE(Tamsx3("GFR_CDESPE")[1])
Local cOldTipLoc := cGcsTipLoc
Local lRetGM1	:=.F.

Private aColsGm8 := {}
Private aPHMed := {}, nGm8CodCrm := 0, nGm8DatAge := 0, nGFRCodEsp := 0,  nGm8CodLoc := 0,  nGm8HorAge := 0,  nGm8CodDis := 0, nGm8CodRec := 0, Inclui := .F.
Private lDicCdRec := HS_EXISDIC({{"C", "GM8_CODREC"}},.F.)
Private oGDGm8 := Nil

cGcsTipLoc := "1J"

If Type("cDisCons") <> "U"
	cDisCons := ""
EndIf

cFilAnt := M->GM8_FILAGE

Fs_MtGdGm8(dDataBase, time(), @aHGm8, @aCGm8, @nUGm8)

For nX := 1 to Len(aCGm8)
	If lDicCdRec .AND. !Empty(aCGm8[nX, nGm8CodRec]) .AND. !(aCGm8[nX, nGm8HorAge]== "  :  ")
		If !Empty(M->GM8_DURACA) .AND.  M->GM8_DURACA <> "  :  "
			aAux :=  Fs_VlHrGm8(aCGm8[nX])
		Else
			Hs_MsgInf("Necessário informar a duração do procedimento.","Atenção","Validação Agendamento")
			DbSelectArea(cAliasOld)
			Return(.F.)
		EndIf
	Else
	//*Somente será exibido os Setores da Disponibilidade se caso o usuario estiver configurado no cadastro de setor*/
		DbSelectArea("GM1")
		DbSetOrder(1)
		If (lRetGM1 := DbSeek(xFilial("GM1") + aCGm8[nX, nGm8CodLoc] + cUserName))
			aAux :=  aClone(aCGm8[nX])
		EndIf

	
	EndIf
	If(!Empty(aAux))
		aAdd(aColsGm8, aAux)
	EndIf
Next
If !ExistBlock("HSORDGM8") // Bloco de codigos
	aColsGm8 := aSort(aColsGm8,,, {|x,y| DtoS(x[nGm8DatAge]) + x[nGm8HorAge]  < DtoS(y[nGm8DatAge]) + y[nGm8HorAge] })  // Organiza por data e hora
EndIf
Inclui := .T.
aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 015, .T., .T., .T. } )
AAdd( aObjects, { 100, 090, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

Define MsDialog oDlgGm8 Title OemToAnsi(STR0008) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd PIXEL //"Primeiro horário dos médicos"

oPPesq	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgGm8,,,,,, aPObjs[1, 3], aPObjs[1, 4])
oPPesq:Align := CONTROL_ALIGN_TOP

oGDGm8 := MsNewGetDados():New(aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0,,,,,, Len(aCGm8),,,, oDlgGm8, aHGm8, aColsGm8)
oGDGm8:oBrowse:align := CONTROL_ALIGN_ALLCLIENT
oGDGm8:oBrowse:BlDblClick := {|| lRetGm8 := .T., oDlgGm8:End()}

HS_GDPesqu( , , oGDGm8, oPPesq, 002)

If lFilLcEsp
	@ 5, 260 Say "Local" Of oPPesq Pixel COLOR CLR_BLUE    // "Procedimento"
	@ 15, 260 MsGet oLocal VAR cLocGM8 Size 60, 010 VALID FS_VLDFIL(1, cLocGM8) F3 "GCS   " OF oPPesq Pixel COLOR CLR_BLACK

	@ 5, 330 Say "Especialidade"  Of oPPesq Pixel COLOR CLR_BLUE    // "Procedimento"
	@ 15, 330 MsGet oEspec VAR cEspec Size 60, 010 VALID FS_VLDFIL(2, cEspec) F3 "GFR001" OF oPPesq Pixel COLOR CLR_BLACK

	oBtnFil := tButton():New(15, 395, "Filtrar", oPPesq, {|| Processa({||FS_FILLOC(aColsGm8, cLocGM8, cEspec)})}, 030, 012,,,, .T.)    //"Efetiva"
EndIf

Activate MsDialog oDlgGm8 On Init EnchoiceBar(oDlgGm8, {|| lRetGm8 := .T., oDlgGm8:End()}, {|| lRetGm8 := .F., oDlgGm8:End()})

cGcsTipLoc := cOldTipLoc

If lRetGm8
	If FunName() == "HSPAHMA7" .AND. (Empty(oGDGm8:aCols[oGDGm8:nAt, nGm8CodCrm]) .OR. Empty(oGDGm8:aCols[oGDGm8:nAt, nGm8CodDis]))
		lRetGm8 := .F.
		__RetGm8 := Space(Len(oGDGm8:aCols[oGDGm8:nAt, nGm8CodCrm]))
	Else
		__RetGm8 := oGDGm8:aCols[oGDGm8:nAt, nGm8CodCrm]
		cPriDia  := oGDGm8:aCols[oGDGm8:nAt, nGm8DatAge]
		cPriHor  := oGDGm8:aCols[oGDGm8:nAt, nGm8HorAge]
		cCodDis  := oGDGm8:aCols[oGDGm8:nAt, nGm8CodDis]
		If Type("cDisCons") <> "U"
			cDisCons := oGDGm8:aCols[oGDGm8:nAt, nGm8CodDis]
		EndIf
		If lDicCdRec
			cCodRec  := oGDGm8:aCols[oGDGm8:nAt, nGm8CodRec]
		EndIf
	EndIf
Else
	__RetGm8 := Space(Len(oGDGm8:aCols[oGDGm8:nAt, nGm8CodCrm]))
EndIf

DbSelectArea(cAliasOld)

Return(lRetGm8)

Static Function Fs_VlHrGm8(aCols)

Local aVlCols 	:= {}, aVlHeader := {}, nVlUGm8 := 0
Local cIntMar 	:= ""
Local aCodAge 	:= {}
Local nSoEnc	:= 0
Local dProxDat 	:= CtoD("")
Local cProxHor 	:= ""

cIntMar := Hs_IniPadr("GM6", 1, aCols[nGm8CodDis], "GM6_INTMAR",,.F.)
If HS_HTOM(M->GM8_DURACA) / HS_HTOM(cIntMar) >= 1
	aVlCols := aClone(aCols)
	While !Hs_VldMarc(@aCodAge, aVlCols[nGm8CodDis], aVlCols[nGm8CodRec], aVlCols[nGm8DatAge], aVlCols[nGm8HorAge], cIntMar, M->GM8_DURACA, .F., .F., @dProxDat, @cProxHor)
		aCodAge := {}
		Fs_MtGdGm8(dProxDat, cProxHor , @aVlHeader, @aVlCols, @nVlUGm8, aVlCols[nGm8CodCrm], aVlCols[nGm8CodRec], .F.,aVlCols[nGm8CodDis])
		If (nSoEnc := aScan(aVlCols, {| aVet | aVet[nGm8HorAge] <> "  :  "})) == 0 .AND. !Empty((aVlCols := aClone(aVlCols[1]))[1])//Empty((aVlCols := aClone(aVlCols[1]))[1])
			Exit
		ElseIf	Empty((aVlCols := aClone(aVlCols[1]))[1])
			Exit
		EndIf
	EndDo
EndIF

Return(aVlCols)

Static Function FS_FILLOC(aColsGm8, cCodLoc, cEspec)
Local aColsAux	:= {}
Local nC := 1
If Empty(cCodLoc) .AND. Empty(cEspec)
	oGDGm8:SetArray(aColsGm8)
Else
	For nC := 1 to Len(aColsGm8)
		If  (IIf(!Empty(cCodLoc),aColsGm8[nC, nGM8CodLoc] == cCodLoc, .T.)) .AND. (IIf(!Empty(cEspec),aColsGm8[nC, nGFRCodEsp] == cEspec,.T.))
			aAdd(aColsAux, aColsGm8[nC])
		EndIf
	Next nC
	If Empty(aColsAux)
		HS_MSGINF("Dado não encontrado!", STR0059, "Validação Filtro")
	Else
		oGDGm8:SetArray(aColsAux)
	EndIf
EndIf
oGDGm8:oBrowse:Refresh()
Return()

Static Function FS_VLDFIL(nVld, cCodigo)
Local lRet := .T.
If nVLd == 1 .AND. !Empty(cCodigo)
	DbSelectArea("GCS")
	DbSetORder(1)
	lRet := (Dbseek(xFilial("GCS") + cCodigo) .AND. GCS->GCS_TIPLOC $ "1J")

EndIf
If nVLd == 2 .AND. !Empty(cCodigo)
	DbSelectArea("GFR")
	DbSetORder(1)
	lRet := Dbseek(xFilial("GFR") + cCodigo)
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fs_MtGdGM8º Autor ³Microsiga           º Data ³  10/24/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SigaHSP                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Fs_MtGdGm8(dData, cHora, aHGm8, aCGm8, nUGm8, cCodCrm, cCodRec, lOrdena, cCodDisp, cCodEsp,cCodLoc)

Local cCondGm8 := "", cElimGm8 := ""
Local cCposGrpBy, cGroupBy, aJoin := {}
Local cOrderBY 		:= ""
Local lOrderBY 		:= .F.
Local lFilLcEsp		:= SuperGetMV("MV_FILLESP", NIL, .F.)  // Alta após confirmar o atendimento
Local cCpsGrid		:= ""
Default cCodCrm      := ""
Default cCodRec      := ""
Default lOrdena      := .T.
Default cCodDisp     := ""
Default cCodEsp      := ""
Default cCodLoc 		:= ""
aHGm8 := {}
aCGm8 := {}
nUGm8 := 0
#IFDEF TOP
	cCondGm8 := " GM8.GM8_FILIAL = '"+ xFilial("GM8") +"' AND GM8.D_E_L_E_T_ <> '*' AND GM8.GM8_FILAGE = '" + M->GM8_FILAGE + "' AND GM8.GM8_STATUS IN ('0','8') "
	cCondGm8 += " AND ((GM8.GM8_DATAGE = '" + DToS(dData) + "' "
	cCondGm8 += " AND  (GM8.GM8_HORAGE >= '" + cHora + "' "
	cCondGm8 += " OR   (GM8.GM8_HORAGE = '  :  ')))"
	cCondGm8 += " OR GM8.GM8_DATAGE > '" + DToS(dData) + "')"

	If !Empty(cCodCrm)
		cCondGm8 += " AND GM8.GM8_CODCRM = '" + cCodCrm + "'"
	EndIf

	If !Empty(cCodRec)
		cCondGm8 += " AND GM8.GM8_CODREC = '" + cCodRec + "'"
	EndIf

	If !Empty(cCodLoc)
		cCondGm8 += " AND GM8.GM8_CODLOC = '" + cCodLoc + "'"
	EndIf

	If !Empty(cCodEsp)
		cCondGm8 += " AND GFR.GFR_CDESPE = '" + cCodEsp + "'"
	EndIf

	If !Empty(cCodDisp)
		cCondGm8 += " AND GM8.GM8_CODDIS = '" + cCodDisp + "'"
	EndIf
	cCposGrpBy := " GM8_CODCRM, GM8_CODLOC, " +;
	IIf(lDicCdRec," SUBSTRING(MIN(GM8_DATAGE || GM8_TIPAGE || GM8_HORAGE || GM8_CODDIS || GM8_CODREC), 25, 06) GM8_CODREC, " , "" )+ ;
	" SUBSTRING(MIN(GM8_DATAGE || GM8_TIPAGE || GM8_HORAGE || GM8_CODDIS " + IIf(lDicCdRec,"|| GM8_CODREC ","") + "), 01, 08) GM8_DATAGE, " + ;
	" SUBSTRING(MIN(GM8_DATAGE || GM8_TIPAGE || GM8_HORAGE || GM8_CODDIS " + IIf(lDicCdRec,"|| GM8_CODREC ","") + "), 10, 05) GM8_HORAGE, " + ;
	" SUBSTRING(MIN(GM8_DATAGE || GM8_TIPAGE || GM8_HORAGE || GM8_CODDIS " + IIf(lDicCdRec,"|| GM8_CODREC ","") + "), 15, 10) GM8_CODDIS "

	If lFilLcEsp
		cCposGrpBy += ",GFR_CDESPE,GFR_DSESPE "
	EndIf

	cGroupBy   := "GM8_CODCRM, GM8_CODLOC, GM8_CODDIS" //, GM8_DATAGE, GM8_HORAGE"
	If lFilLcEsp
		cGroupBy += ",GFR_CDESPE,GFR_DSESPE "
	EndIf
	cElimGm8   := "!HSPM29VerDis('TMPGM8')"
	aJoin      := {{" JOIN " + RetSqlName("GM3") + " GM3", "" , "GM3.GM3_FILIAL  = '" + xFilial("GM3") + "' AND GM3.D_E_L_E_T_ <> '*' AND GM3.GM3_CODDIS = GM8.GM8_CODDIS AND GM3.GM3_CODPRO = '" + M->GM8_CODPRO + "'", ""}}
#ELSE
	cCondGm8   := "GM8->GM8_FILAGE == '" + M->GM8_FILAGE + "' .And. GM8->GM8_TIPAGE = '0' .And. GM8->GM8_STATUS == '0' .And. ((DToS(GM8->GM8_DATAGE) == '" + DToS(dDataBase) + "' .And. GM8->GM8_HORAGE >= '" + Time() + "') .Or. (DToS(GM8->GM8_DATAGE) > '" + DToS(dDataBase) + "'))"
	cElimGm8   := "!HSPM29VerDis('GM8')"
#ENDIF

If lFilLcEsp
	AADD(aJoin , {" JOIN " + RetSqlName("GBJ") + " GBJ", "", "GBJ.GBJ_FILIAL = '" + xFilial("GBJ") + "' AND GBJ_CRM = GM8.GM8_CODCRM", ""})
	AADD(aJoin , {" JOIN " + RetSqlName("GFR") + " GFR", "GFR.GFR_CDESPE", "GFR.GFR_FILIAL = '" + xFilial("GFR") + "' AND GFR_CDESPE = GBJ.GBJ_ESPEC1", "GFR.GFR_CDESPE"})
	AADD(aJoin , {"", "GFR.GFR_DSESPE", "", "GFR.GFR_DSESPE"})
	//AADD(aJoin , {"", "GFR.GFR_CDESPE", "", "GFR.GFR_CDESPE"})
	cCpsGrid := "/GFR_CDESPE/GFR_DSESPE"
EndIF

If ExistBlock("HSORDGM8")
	cOrderBY := ExecBlock("HSORDGM8", .F., .F., {})
	lOrderBy := !Empty(cOrderBY)
	If lOrderBy
		lOrdena := .F.
	EndIf
EndIf
//Function HS_BDados(cAlias, aHDados, aCDados, nUDados, nOrd, lFilial, cCond, lStatus, cCpoLeg, cLstCpo, cElimina, cCpoNao, cStaReg, cCpoMar, cMarDef, lLstCpo, aLeg, lEliSql, lOrderBy, cCposGrpBy, cGroupBy, aCposIni, aJoin, aCposCalc, cOrderBy, aCposVis, aCposAlt, cCpoFilial)
HS_BDados("GM8", @aHGm8, @aCGm8, @nUGm8, 7, M->GM8_FILAGE + "00" + DToS(dData), cCondGm8,,, "GM8_CODLOC/GM8_LOCDES/GM8_CODDIS/GM8_CODCRM/GM8_NOMCRM/GM8_DATAGE/GM8_HORAGE" + IIf (lDicCdRec,"/GM8_CODREC","") + cCpsGrid, ,,,,, .T.,, .F., lOrderBY, cCposGrpBy, cGroupBy,, aJoin,,cOrderBy,,,,{"GFR_CDESPE","GFR_DSESPE"})
//HS_BDados("GCY" ,@aHead, @aCols,       , 1,, " GCY.GCY_CODCRM = '" + cCrmLog + "'     '",.T.,"HSP_STAREG","/"                                                                                                           ,         ,,,,},.T.,aLegGCY,,,,,aCpoGcy,aJoinGcy,,,,,)
nGm8CodCrm := aScan(aHGm8, {| aVet | aVet[2] == "GM8_CODCRM"})
nGm8DatAge := aScan(aHGm8, {| aVet | aVet[2] == "GM8_DATAGE"})
nGm8HorAge := aScan(aHGm8, {| aVet | aVet[2] == "GM8_HORAGE"})
nGm8CodDis := aScan(aHGm8, {| aVet | aVet[2] == "GM8_CODDIS"})
nGm8CodLoc := aScan(aHGm8, {| aVet | aVet[2] == "GM8_CODLOC"})
If lFilLcEsp
	nGFRCodEsp := aScan(aHGm8, {| aVet | aVet[2] == "GFR_CDESPE"})
EndIf
If lDicCdRec
	nGm8CodRec := aScan(aHGm8, {| aVet | aVet[2] == "GM8_CODREC"})
Else
	nGm8CodRec := 0
EndIf

If lOrdena
	If lDicCdRec
		aCGm8 := aSort(aCGm8,,, {|x,y| DtoS(x[nGm8DatAge]) + x[nGm8HorAge] + x[nGm8CodRec] < DtoS(y[nGm8DatAge]) + y[nGm8HorAge] + y[nGm8CodRec] })  // Organiza por data e hora
	Else
		aCGm8 := aSort(aCGm8,,, {|x,y| DtoS(x[nGm8DatAge]) + x[nGm8HorAge] + x[nGm8CodRec] < DtoS(y[nGm8DatAge]) + y[nGm8HorAge] })  // Organiza por data e hora
	EndIf
EndIf
Return(nil)



Function HS_IsPHMed(aPHMed, cCodCrm)
 Local lRet := .F.

 If lRet := (aScan(aPHMed, cCodCrm) == 0)
  aAdd(aPHMed, cCodCrm)
 EndIf
Return(lRet)

Function HS_RetGm8()
Return(__RetGm8)

Function HS_FilGcu()
Return(IIf(Type("cGcyAtendi") # "U", (Empty(cGcyAtendi) .Or. GCU->GCU_TPGUIA $ IIf(cGcyAtendi == "0", "06", IIf(cGcyAtendi == "1","01235", IIf(cGcyAtendi == "2","045","012345")))), .T.))

Function HS_FilZVR()
Local cSqlRet := "@GAV_FILIAL = '" + xFilial("GAV") + "' AND D_E_L_E_T_ <> '*' AND GAV_STATUS = '1'"
 Local cFilterRn := ""

 If Type("cGcsCodLoc") # "U" .And. !EMPTY(cGcsCodLoc)
  cSqlRet += " AND GAV_CODLOC = '" + cGcsCodLoc + "' "
 EndIf

 If Type("cGaiFilRn") # "U" .And. !EMPTY(cGaiFilRn)
  cFilterRn := "('"+StrTran(cGaiFilRn,"/","','")+"')"
  cSqlRet   += " AND GAV_RESERV NOT IN " + cFilterRn
 EndIf

Return(cSqlRet)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro da tabela GCZ - Guias de Atendimento ³
//³ Cibele Peria - 08/04/05                     ³
//³ Utilizado nas consultas padrao:             ³
//³ - GCZ - Guias de Atendimento                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function HS_FilGCZ()
 Local lRetNrFatu := .T., lRetStatus := .T., lRetRegAte := .T.

 If Type("cGCZRegAte") # "U" .And. !Empty(cGCZRegAte) .And. !(GCZ->GCZ_RegAte $ cGCZRegAte)
  lRetStatus := .F.
 Endif

 If Type("cGCZNrFatu") # "U" .And. !Empty(cGCZNrFatu) .And. !(GCZ->GCZ_NRFATU $ cGCZNrFatu)
  lRetNrFatu := .F.
 Endif

 If Type("cGCZStatus") # "U" .And. !Empty(cGCZStatus) .And. !(GCZ->GCZ_STATUS $ cGCZStatus)
  lRetStatus := .F.
 Endif

Return(lRetNrFatu .And. lRetStatus .And. lRetRegAte)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro da tabela SE1 - Contas a Receber     ³
//³  Cibele Peria - 08/04/05                    ³
//³  Utilizado nas consultas padrao:            ³
//³  - HCR - Contas a Receber do GH             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function HS_FilSE1()
 Local cSqlRet := "@E1_FILIAL = '" + xFilial("SE1") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cE1Prefixo") # "U" .And. !Empty(cE1Prefixo)
  cSqlRet += " AND E1_PREFIXO IN (" + HS_InSql(cE1Prefixo, 3) + ") "
 Endif

 If Type("cE1Cliente") # "U" .And. !Empty(cE1Cliente)
  cSqlRet += " AND E1_CLIENTE = '" + cE1Cliente + "' "
 Endif

 If Type("cE1Loja") # "U" .And. !Empty(cE1Loja)
  cSqlRet += " AND E1_LOJA = '" + cE1Loja + "' "
 Endif

 If Type("dE1Ven_D") # "U" .And. !Empty(dE1Ven_D)
  cSqlRet += " AND E1_VENCTO > '" + DTOS(dE1Ven_D) + "' "
 Endif

 If Type("dE1Ven_A") # "U" .And. !Empty(dE1Ven_A)
  cSqlRet += " AND E1_VENCTO < '" + DTOS(dE1Ven_A) + "' "
 Endif

 If Type("lE1Saldo") # "U" .And. lE1Saldo
  cSqlRet += " AND E1_SALDO > 0 "
 Endif

Return(cSqlRet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro da tabela SE1 - Contas a Receber     ³
//³  Antonio Carlos - 25/07/06  (Prefixo)       ³
//³  Utilizado na consulta padrao:              ³
//³  - HSP002 - Contas a Receber do GH          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function HS_FilH002()
 Local cSqlRet := "@E1_FILIAL = '" + xFilial("SE1") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cSE1Prefix") # "U" .And. !Empty(cSE1Prefix)
  cSqlRet += " AND E1_PREFIXO IN (" + HS_InSql(cSE1Prefix, 3) + ") "
 Endif

 If Type("cE1Cliente") # "U" .And. !Empty(cE1Cliente)
  cSqlRet += " AND E1_CLIENTE = '" + cE1Cliente + "' "
 Endif

 If Type("lE1Saldo") # "U" .And. lE1Saldo
  cSqlRet += " AND E1_SALDO > 0 "
 Endif

Return(cSqlRet)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro da tabela GE0 - Extrato Convenio     ³
//³  Cibele Peria - 13/04/05                    ³
//³  Utilizado nas consultas padrao:            ³
//³  - GE0 - Extrato Convenio                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function HS_FilGE0()
 Local lRet := .T.

 If Type("cGA9CodCon") # "U" .And. !Empty(cGA9CodCon) .And. !(GE0->GE0_CODCON $ cGA9CodCon)
  lRet := .F.
 Else
  If Type("cGE0NumExt") # "U"
   If cGE0NumExt == SPACE(LEN(GE0->GE0_NUMEXT))
    If Type(cGE0OpeExt) # "U"
     If cGE0OpeExt == "==" .and. cGE0NumExt <> SPACE(LEN(GE0->GEO_NUMEXT))
      lRet := .F.
     ElseIf cGE0OpeExt == "<>" .and. cGE0NumExt == SPACE(LEN(GE0->GEO_NUMEXT))
      lRet := .F.
     Endif
    Else
     If cGE0NumExt <> SPACE(LEN(GE0->GEO_NUMEXT))
      lRet := .F.
     Endif
    Endif
   ElseIf !Empty(cGe0NumExt) .And. !(GE0->GE0_NUMEXT $ cGE0NumExt)
    lRet := .F.
   Endif
  Endif
 Endif

Return(lRet)

Function HS_FilZrb()
Local cSqlRet := "@GAA_FILIAL = '" + xFilial("GAA") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGcsCodLoc") # "U" .And. cGcsCodLoc <> Nil
  cSqlRet += " AND GAA_CODTXD IN (SELECT GMB_CODTXD FROM " + RetSqlName("GMB") + " GMB" + ;
             " WHERE GMB.GMB_FILIAL = '" + xFilial("GMB") + "' AND GMB.D_E_L_E_T_ <> '*' AND GMB.GMB_CODLOC = '" + cGcsCodLoc + "' AND GMB.GMB_CODTXD = GAA_CODTXD)"
 EndIf

 If Type("cGczCodPla") # "U" .And. cGczCodPla <> Nil
  cSqlRet += " AND GAA_CODTXD IN (SELECT GD3.GD3_CODTXD FROM " + RetSqlName("GD3") + " GD3, " + RetSqlName("GD8") + " GD8, " + RetSqlName("GD2") + " GD2 "+ ;
             "WHERE GD3.GD3_FILIAL = '" + xFilial("GD3") + "' AND GD3.D_E_L_E_T_ <> '*' AND " + ;
                   "GD8.GD8_FILIAL = '" + xFilial("GD8") + "' AND GD8.D_E_L_E_T_ <> '*' AND " + ;
                   "GD2.GD2_FILIAL = '" + xFilial("GD2") + "' AND GD2.D_E_L_E_T_ <> '*' AND " + ;
                   "GD3.GD3_CODTAB = GD8.GD8_CODTXD AND GD8.GD8_CODPLA = '" + cGczCodPla + "' AND " + ;
                   "GD3.GD3_CODTAB = GD2.GD2_CODTAB AND GD2.GD2_TABATV = '1')"
 EndIf

Return(cSqlRet)

Function HS_FilGa7()
Local cSqlRet := "@GA7_FILIAL = '" + xFilial("GA7") + "' AND D_E_L_E_T_ <> '*'"

If Type("cGcuCodTpg") # "U" .And. cGcuCodTpg <> Nil
 // Verifica se o procedimento é permitido na guia selecionada
 cSqlRet += " AND GA7_CODPRO IN (SELECT GCX_CODPRO FROM " + RetSqlName("GCX") + " GCX"
 cSqlRet += " WHERE GCX.GCX_CODTPG = '" + cGcuCodTpg + "'"
 cSqlRet += " AND GCX.GCX_CODPRO = GA7_CODPRO"
 cSqlRet += " AND GCX.GCX_FILIAL = '" + xFilial("GCX") + "' AND GCX.D_E_L_E_T_ <> '*')"
Endif

If Type("cGcsCodLoc") # "U" .And. cGcsCodLoc <> Nil
 // Verifica se o procedimento é permitido no setor
 cSqlRet += " AND GA7_CODPRO IN (SELECT GM2_CODPRO FROM " + RetSqlName("GM2") + " GM2"
 cSqlRet += " WHERE GM2.GM2_CODLOC = '" + cGcsCodLoc + "'"
 cSqlRet += " AND GM2.GM2_CODPRO = GA7_CODPRO"
	cSqlRet += " AND GM2.GM2_FILIAL = '" + xFilial("GM2") + "' AND GM2.D_E_L_E_T_ <> '*')"
Endif

If Type("cGczCodPla") # "U" .And. cGczCodPla <> Nil
 // Verifica se o procedimento esta contido nas tabelas do convenio
 cSqlRet += " AND GA7_CODPRO IN (SELECT GA8_CODPRO FROM " + RetSqlName("GA8") + " GA8, " + RetSqlName("GC6") + " GC6"
 cSqlRet += " WHERE GA8.GA8_TABPRO = GC6.GC6_TABPRO"
	cSqlRet += " AND GC6.GC6_CODPLA = '" + cGczCodPla + "'"
 cSqlRet += " AND GC6.GC6_FILIAL = '" + xFilial("GC6") + "' AND GC6.D_E_L_E_T_ <> '*'"
 cSqlRet += " AND GA8.GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8.D_E_L_E_T_ <> '*')"
Endif

If Type("cGa7TipPro") # "U" .And. cGa7TipPro <> Nil
 // filtra o tipo dos procedimentos
 cSqlRet += " AND GA7_TIPPRO NOT IN (" + HS_InSql(cGa7TipPro) + ") "
Endif

If Type("M->GM8_CODSAL") # "U" .And. !Empty(M->GM8_CODSAL)
 // Verifica se o procedimento pode ser realizado na sala
 cSqlRet += " AND GA7_CODPRO IN (SELECT GNC_CODPRO FROM " + RetSqlName("GNC") + " GNC "
 cSqlRet += " WHERE GNC.GNC_CODSAL = '" + M->GM8_CODSAL + "'"
 cSqlRet += "   AND GNC.GNC_FILIAL = '" + xFilial("GNC") + "' AND GNC.D_E_L_E_T_ <> '*')"
Endif

If Type("cSusProIns") # "U" .And. cSusProIns <> Nil
 // Verifica se o procedimento é permitido no setor
 cSqlRet += " AND GA7_CODPRO IN (SELECT GK6_CODPRO "
 cSqlRet += "                      FROM " + RetSqlName("GK6") + " GK6 "
 cSqlRet += "                     WHERE GK6.GK6_CODINR IN (" + HS_InSql(cSusProIns, 2) + ") "
 cSqlRet += "                       AND GK6.GK6_CODPRO = GA7_CODPRO "
	cSqlRet += "                       AND GK6.GK6_FILIAL = '" + xFilial("GK6") + "' "
	cSqlRet += "                       AND GK6.D_E_L_E_T_ <> '*')"
Endif

If Type("cGa7Urgenc") # "U" .And. cGa7Urgenc <> Nil 	// filtra o procedimentos de urgencia

	cSqlRet += " AND GA7_URGENC  = '" + cGa7Urgenc + "' "

Endif


Return(cSqlRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FILGEL ³ Autor ³ JOSE ORFEU            ³ Data ³ 01.05.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Somente retorno DO SITO ESPECIFICO                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_FILGEL() 		       				                              			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION HS_FilGel()

 Local cRetSql := "@"

 cRetSql += "GEL_FILIAL = '" + xFilial("GEL") + "' AND D_E_L_E_T_ <> '*'"

 If Type("cGehSitPri") # "U" .And. !Empty(cGehSitPri)
  cRetSql += " AND GEL_CODGEK = '" + cGehSitPri + "'"
 EndIf

Return(cRetSql)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilGER ³ Autor ³ Luiz Pereira S. Jr    ³ Data ³ 22/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra os Equipamentos a serem escolhidos                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_FilGER                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M39                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FilGER()
 Local aArea      := GetArea()
 Local cSqlRet 		 := "@GER_FILIAL = '" + xFilial("GER") + "' AND D_E_L_E_T_ <> '*' "
 Local nPosCodGrp	:= aScan(oGetGET:aHeader, 	{|x| AllTrim(x[2]) == "GET_CODGRP"})
 Local nPosCodEqp := aScan(oGetGET:aHeader, 	{|x| AllTrim(x[2]) == "GET_CODEQP"})

 Local dDatAge := oCalSala:dDiaAtu
 Local cHorAge	:= M->GMJ_HORAGE
 Local cCodLoc	:= M->GMJ_CODLOC
 Local cHorMax := ""
 Local cInEqpto := ""
 Local nItens := 0

 If !Empty(cHorAge)
  cHorMax := HS_TotHoras(M->GMJ_HORAGE, M->GMJ_TEMPRO)
 EndIf

 If !Empty(cCodLoc)
  GCS->(DbSetOrder(1))
  GCS->(DbSeek(xFilial("GCS") + cCodLoc))
 EndIf

 If !Empty(oGetGET:aCols[oGetGET:nAt, nPosCodGrp])
  cSqlRet += "AND GER_CODGRP	= '" + oGetGET:aCols[oGetGET:nAt, nPosCodGrp] + "' "
 EndIf
 cSqlRet += "AND GER_CODEQP IN "
	cSqlRet += "(SELECT ST9.T9_CODBEM "
	cSqlRet	+= "FROM " + RetSQLName("ST9") + " ST9 "
	cSqlRet	+= "WHERE ST9.T9_SITBEM = 'A' "
	If !Empty(cCodLoc)
 	cSqlRet	+= "AND ST9.T9_CCUSTO = '" + GCS->GCS_CODCCU + "' "
 EndIf
	cSqlRet += "AND ST9.D_E_L_E_T_ <> '*' "
	cSqlRet += "AND ST9.T9_FILIAL = '" 	+ xFilial("ST9") + "') "

	/* A pedido do Wellington e Graciano não é preciso verificar se o equipamento pertence ao grupo de equipamentos
 // amarrados no procedimento. 16/08/2007 - José Orfeu
 cSqlRet += "AND GER_CODEQP NOT IN "
 cSqlRet += "(SELECT GER.GER_CODEQP
 cSqlRet += " FROM " + RetSQLName("GER") + " GER "
 cSqlRet += " JOIN " + RetSQLName("GFA") + " GFA ON GFA.GFA_FILIAL = '" + xFilial("GFA") + "' AND GFA.D_E_L_E_T_ <> '*' "
 cSqlRet +=       " AND GFA.GFA_CODPRO = '" + M->GMJ_CODPRO + "' AND GFA.GFA_CODGRP = GER.GER_CODGRP "
 cSqlRet += " WHERE GER.GER_FILIAL = '" + xFilial("GER") + "' AND GER.D_E_L_E_T_ <> '*') "
 */

 cSqlRet += "AND GER_CODEQP NOT IN "
	cSqlRet += "(SELECT STJ.TJ_CODBEM "
	cSqlRet += "FROM " + RetSQLName("STJ") + " STJ "
	cSqlRet += "WHERE STJ.D_E_L_E_T_ <> '*' "
	cSqlRet += "AND STJ.TJ_FILIAL = '" + xFilial("STJ") + "' "
	cSqlRet += "AND STJ.TJ_SITUACA = 'P' "
	cSqlRet += "AND STJ.TJ_TERMINO = 'N' "
	cSqlRet += "AND STJ.TJ_DTMPINI <= '" + DTOS(dDatAge) + "' "
	cSqlRet += "AND STJ.TJ_HOMPINI < '" + cHorMax + "' "
	cSqlRet += "AND STJ.TJ_DTMPFIM >= '" + DTOS(dDatAge) + "' "
	cSqlRet += "AND STJ.TJ_HOMPFIM > '" + cHorAge + "' "
	cSqlRet +=	"AND STJ.TJ_TIPOOS = 'B') "

 cSqlRet += "AND GER_CODEQP NOT IN "
	cSqlRet += "(SELECT GET.GET_CODEQP "
	cSqlRet += "FROM " + RetSQLName("GET") + " GET "
	cSqlRet += "WHERE GET.D_E_L_E_T_ <> '*' "
	cSqlRet += "AND GET.GET_FILIAL = '" 	+ xFilial("GET") + "' "
	cSqlRet += "AND GET.GET_CODAGE <>	'" + M->GMJ_CODAGE + "' "  // para nao escolher a mesma agenda no caso de alteracao
	cSqlRet += "AND GET.GET_DATAGE = '" 	+ DTOS(dDatAge) + "' "
	cSqlRet += "AND GET.GET_HORAGE < '"	+ cHorMax + "' "
	cSqlRet += "AND GET.GET_HORAFI > '"	+ cHorAge + "' ) "

	If aScan(oGetGET:aCols, {| aVet | aVet[nPosCodGrp] == oGetGET:aCols[oGetGET:nAt, nPosCodGrp]}) > 0
  cInEqpto := HS_RetIn(@nItens, oGetGET:aCols, Len(oGetGET:aHeader), nPosCodEqp, oGetGET:nAt, "Pos")

  If nItens > 1
   cInEqpto := HS_InSql(cInEqpto, Len(GET->GET_CODGRP))
  ElseIf !Empty(cInEqpto)
   cInEqpto :="'" + cInEqpto +"'"
  EndIf
 EndIf

	If !Empty(cInEqpto)
	 cSqlRet += "AND NOT GER_CODEQP IN (" + cInEqpto + ")"
	EndIf

 RestArea(aArea)
Return(cSqlRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilGF9 ³ Autor ³ Luiz Pereira S. Jr    ³ Data ³ 22/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra os Grupos de equipamento a serem escolhidos         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_FilGF9                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M39                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FilGF9()
 Local aArea := GetArea()
 Local cSqlRet 		 := "@GF9_FILIAL = '" + xFilial("GF9") + "' AND D_E_L_E_T_ <> '*' "

 Local dDatAge := oCalSala:dDiaAtu
 Local cHorAge	:= M->GMJ_HORAGE
 Local cCodLoc	:= M->GMJ_CODLOC
 Local cHorMax := ""

 If ReadVar() == "M->GET_CODGRP"

  If !Empty(cHorAge)
   cHorMax := HS_TotHoras(M->GMJ_HORAGE, M->GMJ_TEMPRO)
  EndIf

  If !Empty(cCodLoc)
   GCS->(DbSetOrder(1))
   GCS->(DbSeek(xFilial("GCS") + cCodLoc))
  EndIf

  cSqlRet += "AND GF9_CODGRP IN ( "
  cSqlRet +=   "SELECT GER_CODGRP FROM " + RetSqlName("GER") + " "
  cSqlRet +=   "WHERE GER_FILIAL = '" + xFilial("GER") + "' AND D_E_L_E_T_ <> '*' AND "
  cSqlRet +=         "GER_CODEQP IN (SELECT ST9.T9_CODBEM "
  cSqlRet +=                         "FROM " + RetSqlName("ST9") + " ST9 "
  cSqlRet +=                         "WHERE ST9.T9_SITBEM = 'A' AND ST9.D_E_L_E_T_ <> '*' AND ST9.T9_FILIAL = '" + xFilial("ST9") + "' AND "
  cSqlRet +=                               "ST9.T9_CCUSTO = '" + GCS->GCS_CODCCU + "' ) AND "

  /* A pedido do Wellington e Graciano não é preciso verificar se o equipamento pertence ao grupo de equipamentos
  // amarrados no procedimento. 16/08/2007 - José Orfeu
  cSqlRet +=         "GER_CODEQP NOT IN ( "
  cSqlRet +=               "SELECT GER.GER_CODEQP "
  cSqlRet +=               "FROM " + RetSqlName("GER") + " GER "
  cSqlRet +=                 "JOIN " + RetSqlName("GFA") + " GFA ON GFA.GFA_FILIAL = '" + xFilial("GFA") + "' AND "
  cSqlRet +=                   "GFA.D_E_L_E_T_ <> '*'  AND GFA.GFA_CODPRO = '" + M->GMJ_CODPRO + "' AND GFA.GFA_CODGRP = GER.GER_CODGRP "
  cSqlRet +=               "WHERE GER.GER_FILIAL = '" + xFilial("GER") + "' AND GER.D_E_L_E_T_ <> '*') AND "
  */

  cSqlRet +=         "GER_CODEQP NOT IN ("
  cSqlRet +=               "SELECT STJ.TJ_CODBEM "
  cSqlRet +=               "FROM " + RetSqlName("STJ") + " STJ "
  cSqlRet +=               "WHERE STJ.D_E_L_E_T_ <> '*' AND STJ.TJ_FILIAL = '" + xFilial("GFA") + "' AND STJ.TJ_SITUACA = 'P' AND "
  cSqlRet +=                     "STJ.TJ_TERMINO = 'N' AND STJ.TJ_DTMPINI <= '" + DTOS(dDatAge) + "' AND "
  cSqlRet +=                     "STJ.TJ_HOMPINI <= '" + cHorAge + "' AND STJ.TJ_DTMPFIM >= '" + DTOS(dDatAge) + "' AND "
  cSqlRet +=                     "STJ.TJ_HOMPFIM >= '" + cHorAge + "' AND STJ.TJ_TIPOOS = 'B') AND "
  cSqlRet +=         "GER_CODEQP NOT IN ( "
  cSqlRet +=               "SELECT GET.GET_CODEQP "
  cSqlRet +=               "FROM " + RetSqlName("GET") + " GET "
  cSqlRet +=               "WHERE GET.D_E_L_E_T_ <> '*' AND GET.GET_FILIAL = '" + xFilial("GET") + "' AND "
  cSqlRet +=                     "GET.GET_CODAGE <>	'" + M->GMJ_CODAGE + "' AND GET.GET_DATAGE = '" + DTOS(dDatAge) + "' AND "
  cSqlRet +=                     "GET.GET_HORAGE <= '"	+ cHorAge + "' AND GET.GET_HORAFI >= '"	+ cHorAge + "' )
  cSqlRet +=   "GROUP BY GER_CODGRP ) "

 EndIf

 RestArea(aArea)
Return(cSqlRet)

// Filtra relacionamento de planos por paciente - GD4
Function HS_FilGD4()
 Local lRet := .T.

 If Type("cGD4RegGer") # "U" .And. !Empty(cGD4RegGer)
  lRet := (cGD4RegGer == GD4->GD4_REGGER)
 Endif

Return(lRet)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FoneP  ³ Autor ³ MARCELO JOSE          ³ Data ³ 14.06.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ SOMENTE TELEFONES DO PRONTUARIO EM QUESTAO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_FILGEL() 		       				                              			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION HS_FoneP()

 Local cRetSql := "@"

 cRetSql += "GF1_FILIAL = '" + xFilial("GF1") + "' AND D_E_L_E_T_ <> '*'"

 If !Empty(M->GM8_REGGER)
  cRetSql += " AND GF1_REGGER = '" + M->GM8_REGGER + "'"
 EndIf

Return(cRetSql)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtro da tabela GDM - Motivo de Glosa ³
//³ Data: 23/06/05 - Cibele Peria          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function HS_FilGDM()
 Local lRet := .T.

 IF Type("cGDMTipo") # "U" .And. !Empty(cGDMTipo)
  lRet := (GDM->GDM_TIPO $ cGDMTipo)
 Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilGFD ³ Autor ³ Daniel Peixoto³ Data ³         19.09.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra os Responsaveis de acordo com o paciente que        ³±±
±±³            esta sendo atendido          																															±±³
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ HS_FilGFD                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M24                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FilGFD()

Local cRetSql := "@"

 cRetSql += "GFD_FILIAL = '" + xFilial("GFD") + "' AND D_E_L_E_T_ <> '*'"

 If !Empty(M->GCY_REGGER)
  cRetSql += " AND GFD_REGGER = '" + M->GCY_REGGER + "'"
 EndIf

Return(cRetSql)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilCTT ³ Autor ³ Cibele Peria          ³ Data ³ 20/09/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da tabela CTT                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_FilCTT()
 Local cSqlRet 		:= "@CTT_FILIAL = '" + xFilial("CTT") + "' AND D_E_L_E_T_ <> '*' "

 IF Type("cCTTClasse") # "U" .And. !Empty(cCTTClasse)
  cSQLRet += "AND CTT_CLASSE = '" + cCTTClasse + "' "
 Endif

Return(cSqlRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilGfm ³ Autor ³ Daniel Peixoto        ³ Data ³ 06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da tabela GFM                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SqlGfm()
 Local cFiltroSql := "@GFM_FILIAL = '" + xFilial("GFM") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGcsCodLoc") # "U" .And. !Empty(cGcsCodLoc)
  cFiltroSql += " AND GFM_CODLOC = '" + cGcsCodLoc + "' "
 EndIf

 If Type("cGflRegra") # "U" .And. !Empty(cGflRegra)
  cFiltroSql += " AND GFM_CODREG = '" + cGflRegra + "' "
 EndIf

Return(cFiltroSql)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilGfl ³ Autor ³ Daniel Peixoto        ³ Data ³ 06/12/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da tabela GFL                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SqlGfl()
Local cSqlExists := ""
Local cFiltroSql := "@GFL_FILIAL = '" + xFilial("GFL") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGfmCodLoc") # "U" .And. !Empty(cGfmCodLoc) .And. Type("cGfmQuarto") # "U" .And. !Empty(cGfmQuarto)
  cSqlExists := " AND GFL_CODREG IN (SELECT GFM_CODREG FROM " + RetSqlname("GFM") + " GFM " + ;
                " WHERE GFM.GFM_FILIAL = '" + xFilial("GFM") + "' AND GFM.D_E_L_E_T_ <> '*' AND " + ;
                " GFM.GFM_CODLOC = '" + cGfmCodLoc + "' AND GFM.GFM_QUARTO = '" + cGfmQuarto+ "') "
  cFiltroSql += cSqlExists
 EndIf

Return(cFiltroSql)

Function HS_FilGP0()
Local cFiltroSql := "@GP0_FILIAL = '" + xFilial("GP0") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGP0CodCon") # "U" .And. !Empty(cGP0CodCon)
  cFiltroSql += " AND GP0_CODCON = '" + cGP0CodCon + "' "
 EndIf

 If Type("cGP0CodPro") # "U" .And. !Empty(cGP0CodPro)
  cFiltroSql += " AND GP0_CODPRO = '" + cGP0CodPro + "' "
 EndIf

Return(cFiltroSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³HS_FilRPro()   ³ Autor ³ Cibele Peria     ³ Data ³01/03/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de filtro utilizada pelas tabelas de relacionamento ³±±
±±³          ³ com o cadastro de procedimento:                            ³±±
±±³          ³ -> GHD - Atividade Profissional x Procedimento             ³±±
±±³          ³ -> GHE - Faixa etaria x Procedimento                       ³±±
±±³          ³ -> GHF - Grupo de Atendimento x Procedimento               ³±±
±±³          ³ -> GHG - Tipo de Atendimento x Procedimento                ³±±
±±³          ³ -> GHH - CID x Procedimento                                ³±±
±±³          ³ -> GHI - Material x Procedimento                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilRPro(cAlias) //Filtro dos relacionamentos do procedimento

 If Type("cGA7CodPro") # "U" .And. !Empty(cGA7CodPro)
  If cAlias == "GHH"
   cFiltro := "@ " + PrefixoCpo(cAlias) + "_CODPRO = '" + cGA7CodPro + "'"
  Else
   cFiltro := &(cAlias + "->" + PrefixoCpo(cAlias) + "_CODPRO") $ cGA7CodPro
  EndIf
 Endif

Return(cFiltro)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_PesqGD4ºAutor  ³Saude               º Data ³  19/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Disponibiliza a opcao de pesquisa de pacientes pela cartei- º±±
±±º          ³rinha.                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_PesqGD4()

Local oDlgPesq 	:= Nil
Local nPosIni  	:= 11
Local nUGBH 	:= 0
Local nGbhCodPac:= 0
Local nLin 		:= 0
Local cPict    	:= "@!"
Local aSize    	:= {}
Local aObjects 	:= {}
Local aInfo		:= {}
Local aPobjs	:= {}
Local aHGBH		:= {}
Local aCGBH		:= {}
Local aDadUsr	:= {}					// Traz as informacoes do usuario no modulo PLS
Local lRet     	:= .F.
Local lIntegr	:= GetMv("MV_HSPPLS")	// Verifica se existe a integracao dos modulos PLS x GH
Local n			:= 0

Private oGetGBH, oChvP
Private cChvP  := SPACE(40)//CriaVar("GD4_MATRIC",.F.)

aSize := MsAdvSize(.T.)
aObjects := {}

AAdd( aObjects, { 100, 015, .T., .T. } )
AAdd( aObjects, { 100, 085, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )

HS_BDados("GBH", @aHGBH, @aCGBH,@nUGBH,1,, )
nGbhCodPac := aScan(aHGBH, {|aVet | aVet[2] == "GBH_CODPAC"})

aCGBH :={}

AADD(aCGBH, Array(Len(aHGBH)+1) )
aCGBH[Len(aCGBH), Len(aHGBH)+1 ]:=.F.

DEFINE MSDIALOG oDlgPesq TITLE OemToAnsi(STR0020) From aSize[7],000 To aSize[6],aSize[5] OF GetWndDefault() PIXEL

	@ nPosIni + 016, 004 SAY OemToAnsi(STR0021)    OF oDlgPesq PIXEL COLOR CLR_BLUE //"Carteirinha"
 	//@ nPosIni + 014, 035 MSGet oChvP Var cChvP Valid IIF(ExistBlock("HSM24MAT"), ExecBlock("HSM24MAT", .F., .F., {cChvP}), .T.) Picture cPict Size 120, 010 Of oDlgPesq Pixel Color CLR_BLACK
 	@ nPosIni + 014, 035 MSGet oChvP Var cChvP F3 "BY2PLS" Valid IIF(ExistBlock("HSM24MAT"), ExecBlock("HSM24MAT", .F., .F., {cChvP}), .T.) Picture cPict Size 120, 010 Of oDlgPesq Pixel Color CLR_BLACK

	If lIntegr
		tButton():New(nPosIni, 160, STR0006, oDlgPesq, {|| lRet := Hs_Integr(@cChvP), Iif ( lRet,FS_BuscGD4(@aHGBH, @aCGBH, cChvP),""), nLin := oGetGBH:nAt, oDlgPesq:End()}, 32,,,,, .T.) //Ok
	Else
		tButton():New(nPosIni, 160, STR0006, oDlgPesq, {|| FS_BuscGD4(@aHGBH, @aCGBH, cChvP), nLin := oGetGBH:nAt, oDlgPesq:End()}, 32,,,,, .T.) //Ok
	EndIf

//	tButton():New(nPosIni + 014, 160, STR0006, oDlgPesq, {|| nLin := oGetGBH:nAt, oDlgPesq:End()}, 32,,,,, .T.) //Confirmar..
	tButton():New(nPosIni + 014, 160, STR0018, oDlgPesq, {||oDlgPesq:End()}, 32,,,,, .T.)//Cancelar

	oGetGBH  := MsNewGetDados():New(aPobjs[2, 1], aPobjs[2, 2], aPobjs[2, 3], aPobjs[2, 4], 0,,,,,,,,,,oDlgPesq, aHGBH, aCGBH)
	oGetGBH  :oBrowse:Align      := CONTROL_ALIGN_BOTTOM

ACTIVATE MSDIALOG oDlgPesq CENTERED

If nLin > 0 .And. ValType( oGetGBH:aCols[nLin,nGbhCodPac] )<> "U"
	DbSelectArea("GBH")
	DbSetOrder(1) //GBH_FILIAL+GBH_CODPAC
	DbSeek(xFilial("GBH") + oGetGBH:aCols[nLin,nGbhCodPac])
	lRet := .T.
EndIf

Return(lRet)

Function  FS_BuscGD4(aHGBH, aCGBH, cChvP)
 Local nUGBH := 0
 Local aJoin := {}
 Local cOrderBy := " "

 aHBH  := {}
 aCGBH := {}

 aJoin := {{" JOIN " + RetSqlName("GD4") + " GD4 ", " " , "GD4.GD4_FILIAL = '" + xFilial("GD4") + "' AND GD4.D_E_L_E_T_ <> '*' AND GD4.GD4_MATRIC = '" + cChvP + "' AND GD4.GD4_REGGER = GBH.GBH_CODPAC", " "}}
 cOrderBy := "GBH_NOME"

 If HS_BDados("GBH", @aHGBH, @aCGBH, @nUGBH, 1,, "GBH_FILIAL == '" + xFilial("GBH") + "'",,,,,,,,,,,,.T.,,,, aJoin,,cOrderBy) < 1
  aCGBH := {}
  AADD(aCGBH, Array(Len(aHGBH) + 1 ) )
  aCGBH[Len(aCGBH), Len(aHGBH) + 1 ]:=.F.
 EndIf
 oGetGBH:aCols := aCGBH
 oGetGBH:oBrowse:Refresh()

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Hs_Integr ºAutor  ³Saude               º Data ³  07/17/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para verificacao da carteirinha do GH, indo   º±±
±±º          ³buscar as informacoes no PLS.                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao GH x PLS                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Hs_Integr(cChvP)

Local lIntegr	:= GetMv("MV_HSPPLS")	// Verifica se existe a integracao dos modulos PLS x GH
Local cMSGPLS	:= GetMv("MV_MSGPLS")	// Mensagem padrao para critica no GH
Local cConvPLS	:= GetMv("MV_CONVPLS")	// Verifica qual o convenio da integracao PLS x GH
Local n			:= 0
Local cTexto	:= ""					// Variavel que carrega as descricoes das criticas do PLS, para geracao de log
Local cCodUser	:= ""					// Variavel que carrega o codigo do usuario no GH
Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", " ")	// Pega a empresa de trabalho do PLS
Local cFilTrab	:= PADR(GetNewPar("MV_FILIPLS", " "),FWSizeFilial())	// Pega a filial de trabalho do PLS
Local cQryBA1	:= ""
Local cQryGCM	:= ""
Local cQryGBH	:= ""
Local cQryBA0	:= ""
Local cQryBG9	:= ""
Local aUsers	:= {}					// Vetor utilizado para trazer os pacientes existentes do GH
Local aRetCli	:= {}
Local aArea		:= GetArea()
Local lRet		:= .F.
Local nOpcI		:= 2
Local cFilAtu	:= cFilAnt				// Guarda a filial de origem do GH
Local lChgPla	:= .T.

Local lMark		:= .F.
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local cTitulo	:= "Consulta Pacientes"

Local cMask		:= "Arquivos Texto (*.TXT) |*.txt|"

Local nSaveSx8Len := GetSx8Len()

local lMativd	:=HS_EXISDIC({{"C", "GBH_MATVID"}},.F.)
Local lUsua		:=.F.
cTexto += Replicate("-",128)+CHR(13)+CHR(10)

Hs_TabPLS("A",cFilAtu)	// Abre as tabelas da empresa referente ao PLS

aDadUsr := PLSA090USR(cChvP,dDataBase,nil,nil,.F.,.T.,.F.)

Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

cTexto := "Críticas " + CHR(13) + CHR(10) + cTexto
// Retorna as Criticas do PLS ou a mensagem padrao do parametro MV_MSGPLS

If Valtype(aDadUsr)=="A"
	lUsua:=Len(aDadUsr) > 0
Else
	lUsua:= aDadUsr
Endif

If lUsua
	If !aDadUsr[1]
		If Empty(cMSGPLS)
		    For n := 1 to Len(aDadUsr[2])
		    	If Empty(aDadUsr[2][n][3])
		    		cTexto += aDadUsr[2][n][2] + CHR(13) + CHR(10)
		    	Else
		    		cTexto += aDadUsr[2][n][2] + " " + aDadUsr[2][n][3] + CHR(13) + CHR(10)
		    	EndIf
	     	Next n
	     		__cFileLog	:= MemoWrite(Criatrab(,.f.) + ".LOG", cTexto)

			DEFINE FONT oFont NAME "Mono AS" SIZE 5,12
			DEFINE MSDIALOG oDlg TITLE "Críticas do Módulo PLS" From 3,0 to 340,417 PIXEL
				@ 5,5 GET oMemo  VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
				oMemo:bRClicked := {||AllwaysTrue()}
				oMemo:oFont:=oFont
				DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
				DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
			ACTIVATE MSDIALOG oDlg CENTER
	    Else
			MsgAlert(cMSGPLS)
	    EndIf
	    lRet := .F.
	Else
		Hs_TabPLS("A",cFilAtu)	// Abre as tabelas da empresa referente ao PLS
		// Faz verificacao do usuario dentro do PLS e retorna o nome do mesmo
		cQryBA1 := "SELECT BA1_MATVID,BA1_NOMUSR, BA1_SEXO, BA1_DATNAS, BA1_MAE, BA1_DRGUSR, BA1_ORGEM, BA1_CPFUSR,"
		cQryBA1	+= " BA1_PAI, BA1_ESTCIV, BA1_CEPUSR, BA1_CODMUN, BA1_ESTADO, BA1_ENDERE, BA1_DTVLCR,"
		cQryBA1 += " BA1_NR_END, BA1_BAIRRO, BA1_COMEND, BA1_CORNAT, BA1_ESCOLA, BA1_TELEFO, BA1_SANGUE,"
		cQryBA1 += " BA1_CODEMP, BA1_DATINC, BA1_CODCLI, BA1_LOJA, BA1_CODSET, BA1_LOCATE, BA1_DDD,"
		cQryBA1 += " BA1_CODPLA, BA1_CODINT, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_NOMTIT, BA1_VERSAO,"
		cQryBA1 += " BA3_CODEMP, BA3_CONEMP, BA3_VERCON, BA3_SUBCON, BA3_VERSUB, BA3_TIPOUS, BA3_CODPLA, BA3_VERSAO "
		cQryBA1 += "FROM BA1" + cEmpTrab + "0 BA1, BA3" + cEmpTrab + "0 BA3 "
		cQryBA1 += "WHERE BA1_FILIAL = '" + xFilial("BA1") + "' "
		cQryBA1 += "  AND BA3.BA3_FILIAL = '" + xFilial("BA3") + "' "
		cQryBA1 += "  AND BA1.D_E_L_E_T_ <> '*' "
		cQryBA1 += "  AND BA3.D_E_L_E_T_ <> '*' "
		cQryBA1 += "  AND BA1.BA1_CODINT = BA3.BA3_CODINT "
		cQryBA1 += "  AND BA1.BA1_CODEMP = BA3.BA3_CODEMP "
		cQryBA1 += "  AND BA1.BA1_MATRIC = BA3.BA3_MATRIC "
		cQryBA1 += "  AND BA1_CODINT = '" + SubStr(cChvP,1,4) + "' "
		cQryBA1 += "  AND BA1_CODEMP = '" + SubStr(cChvP,5,4) + "' "
		cQryBA1 += "  AND BA1_MATRIC = '" + SubStr(cChvP,9,6) + "' "
		cQryBA1 += "  AND BA1_TIPREG = '" + SubStr(cChvP,15,2) + "' "
		cQryBA1 += "  AND BA1_DIGITO = '" + SubStr(cChvP,17,1) + "' "
		cQryBA1 += "  OR BA1_MATANT = '" + cChvP + "' "
		cQryBA1 += "ORDER BY BA1_NOMUSR"

		cQryBA1 := ChangeQuery(cQryBA1)
		TCQUERY cQryBA1 NEW ALIAS "BA1USR"

		DbSelectArea("BA1USR")

		Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

		cChvP := ALLTRIM(BA1USR->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO))

		If BA1USR->(!Eof())
			// Retorna todos os possiveis usuarios que possuem o nome que veio do PLS
			cQryGBH := "SELECT GBH_CODPAC, GBH_NOME, GBH_DTNASC, GBH_NOMPAI, GBH_NOMMAE,"
			cQryGBH += " GBH_NOMCJG, GBH_EST, GBH_CEP, GBH_END, GBH_NUM, GBH_TEL,"
			cQryGBH += " GBH_RG, GBH_CPF "
			If lMativd
		   		cQryGBH += ",GBH_MATVID "
			Endif
			cQryGBH += "FROM " + RetSqlName("GBH") + " "
			cQryGBH += "WHERE GBH_FILIAL = '" + xFilial("GBH") + "' "
			cQryGBH += "  AND D_E_L_E_T_ <> '*' "
			cQryGBH += "  AND GBH_NOME LIKE '" + ALLTRIM(BA1USR->BA1_NOMUSR) + " %' "
			cQryGBH += "  AND GBH_DTNASC = '" + BA1USR->BA1_DATNAS + "' "
			cQryGBH += "ORDER BY GBH_NOME"

			cQryGBH := ChangeQuery(cQryGBH)
			TCQUERY cQryGBH NEW ALIAS "GBHUSR"

			DbSelectArea("GBHUSR")

			If GBHUSR->(!Eof())
				GBHUSR->(DbGoTop())
				While GBHUSR->(!Eof())
					Aadd( aUsers, 	{lMark, ;
									GBHUSR->GBH_CODPAC,;
									GBHUSR->GBH_NOME,;
									StoD(GBHUSR->GBH_DTNASC),;
									GBHUSR->GBH_NOMPAI,;
									GBHUSR->GBH_NOMMAE,;
									GBHUSR->GBH_NOMCJG,;
									GBHUSR->GBH_EST,;
									GBHUSR->GBH_CEP,;
									GBHUSR->GBH_END,;
									GBHUSR->GBH_NUM,;
									GBHUSR->GBH_TEL,;
									GBHUSR->GBH_RG,;
									GBHUSR->GBH_CPF})
					GBHUSR->(DbSkip())
				End
				//+-----------------------------------------------+
				//| Monta a tela para usuario visualizar consulta |
				//+-----------------------------------------------+
				If Len( aUsers ) == 0
				   Aviso( cTitulo, "Não existem pacientes a consultar", {"Ok"} )
				   Return(.F.)
				Endif

				DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

				@ 10,10 LISTBOX oLbx FIELDS HEADER ;
				   " ", "Código", "Nome", "Dt Nasc", "Nome Pai", "Nome Mãe", "Nome Conj", "Estado", "CEP", "Endereço", "Número", "Telefone", "RG", "CPF" ;
				   SIZE 230,095 OF oDlg PIXEL ON DblClick(aEval( aUsers,{ |x| x[1] := .F. } ),aUsers[oLbx:nAt,1] := .T. ,oLbx:Refresh() )

				oLbx:SetArray( aUsers )
				oLbx:bLine := {|| {Iif(aUsers[oLbx:nAt,1],oOk,oNo),;
				                       aUsers[oLbx:nAt,2],;
				                       aUsers[oLbx:nAt,3],;
				                       aUsers[oLbx:nAt,4],;
				                       aUsers[oLbx:nAt,5],;
				                       aUsers[oLbx:nAt,6],;
				                       aUsers[oLbx:nAt,7],;
				                       aUsers[oLbx:nAt,8],;
				                       aUsers[oLbx:nAt,9]}}

				DEFINE SBUTTON FROM 107,183 TYPE 1 ACTION {|| cCodUser := Hs_SelUsr(aUsers),nOpcI := 1, oDlg:End()} ENABLE OF oDlg	//Ok
				DEFINE SBUTTON FROM 107,213 TYPE 2 ACTION {|| nOpcI := 2, oDlg:End()} ENABLE OF oDlg								//Cancelar
				ACTIVATE MSDIALOG oDlg CENTER

			 	If nOpcI == 1 //.AND. !eMPTY(cCodUSer)

   					DbSelectArea("GBH")
					GBH->(DbSetOrder(8))
					IF GBH->(DbSeek(xFilial("GBH") + BA1USR->BA1_MATVID))
					If Select("BA1USR") > 0
						DbSelectArea("BA1USR")
						DbCloseArea()
					EndIf
					If Select("GBHUSR") > 0
						DbSelectArea("GBHUSR")
						DbCloseArea()
					EndIf

				   		Return(.T.)
		 		    Endif
					If Select("GBH") > 0
						GBH->(DbCloseArea())
					EndIf
					DbSelectArea("GBH")
					GBH->(DbSetOrder(1))
					GBH->(DbSeek(xFilial("GBH") + cCodUSer))

					GBH->(RecLock("GBH",.F.))
						If BA1USR->BA1_SEXO == "1"
							Replace GBH->GBH_SEXO With "0"		//Masculino
						Else
							Replace GBH->GBH_SEXO With "1"		//Feminino
						EndIf
						Replace GBH->GBH_NOME	With ALLTRIM(BA1USR->BA1_NOMUSR)
						Replace GBH->GBH_DTNASC	With StoD(BA1USR->BA1_DATNAS)
						Replace GBH->GBH_NOMMAE	With ALLTRIM(BA1USR->BA1_MAE)
						Replace GBH->GBH_RG		With BA1USR->BA1_DRGUSR
						Replace GBH->GBH_ORGEMI	With BA1USR->BA1_ORGEM
						Replace GBH->GBH_CPF	With BA1USR->BA1_CPFUSR
						Replace GBH->GBH_NOMPAI	With ALLTRIM(BA1USR->BA1_PAI)
						If BA1USR->BA1_ESTCIV == "C"
							Replace GBH->GBH_ESTCIV	With "0"
						ElseIf BA1USR->BA1_ESTCIV == "S"
							Replace GBH->GBH_ESTCIV	With "1"
						ElseIf BA1USR->BA1_ESTCIV == "M"
							Replace GBH->GBH_ESTCIV	With "3"
						ElseIf BA1USR->BA1_ESTCIV == "V"
							Replace GBH->GBH_ESTCIV	With "4"
						Else
							Replace GBH->GBH_ESTCIV	With "2"
						EndIf
						Replace GBH->GBH_CEP	With BA1USR->BA1_CEPUSR
						Replace GBH->GBH_MUN	With BA1USR->BA1_CODMUN
						Replace GBH->GBH_EST	With BA1USR->BA1_ESTADO
						Replace GBH->GBH_END	With ALLTRIM(BA1USR->BA1_ENDERE)
						Replace GBH->GBH_NUM	With BA1USR->BA1_NR_END
						Replace GBH->GBH_BAIRRO	With ALLTRIM(BA1USR->BA1_BAIRRO)
						Replace GBH->GBH_COMPLE	With BA1USR->BA1_COMEND
						Replace GBH->GBH_CORPEL	With BA1USR->BA1_CORNAT
						Replace GBH->GBH_ESCOLA	With BA1USR->BA1_ESCOLA
						Replace GBH->GBH_TEL	With AllTrim(BA1USR->BA1_DDD) + AllTrim(BA1USR->BA1_TELEFO)
						Replace GBH->GBH_TPSANG	With BA1USR->BA1_SANGUE
						Replace GBH->GBH_DATCAD	With StoD(BA1USR->BA1_DATINC)
					If lMativd
					Replace GBH->GBH_MATVID	With BA1USR->BA1_MATVID
					Endif
						Hs_TabPLS("A",cFilAtu)	// Abre as tabelas referente ao PLS
						cQryBG9 := "SELECT BG9_HSPEMP "
						cQryBG9 += "FROM BG9" + cEmpTrab + "0 "
						cQryBG9 += "WHERE BG9_FILIAL = '" + xFilial("BG9") + "' "
						cQryBG9 += "  AND D_E_L_E_T_ = ' ' "
						cQryBG9 += "  AND BG9_CODIGO = '" + BA1USR->BA1_CODEMP + "' "

						cQryBG9 := ChangeQuery(cQryBG9)
						TCQUERY cQryBG9 NEW ALIAS "BG9USR"

						DbSelectArea("BG9USR")

						Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

						Replace GBH->GBH_CODEMP	With BG9USR->BG9_HSPEMP

				   		Hs_TabPLS("A",cFilAtu)	// Abre as tabelas da empresa referente ao PLS

						aRetCli :=	PLSAVERNIV(Subs(cChvP,1,4),Subs(cChvP,5,4),Subs(cChvP,9,6),BA1USR->BA3_TIPOUS,;
					   				BA1USR->BA3_CONEMP,BA1USR->BA3_VERCON,BA1USR->BA3_SUBCON,BA1USR->BA3_VERSUB,;
					   				nil,Subs(cChvP,15,2),nil,cEmpTrab)

						Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas da empresa referente ao PLS

				   		If Len(aRetCli) > 0
							Replace GBH->GBH_CODCLI	With aRetCli[1][1]
							Replace GBH->GBH_LOJA	With aRetCli[1][2]
						Else
							Replace GBH->GBH_CODCLI	With ""
							Replace GBH->GBH_LOJA	With ""
						EndIf

						Replace GBH->GBH_CODLOC	With BA1USR->BA1_CODSET
						Replace GBH->GBH_IDPATE	With BA1USR->BA1_LOCATE
						Replace GBH->GBH_USRCAD	With cUserName
						Replace GBH->GBH_LOGARQ	With HS_LOGARQ()
					GBH->(MsUnLock())

					Hs_TabPLS("A",cFilAtu)	// Abre as tabelas referente ao PLS

		        	cQryBI3 := "SELECT BI3_HSPPLA, BI3_DESCRI "
					cQryBI3	+= "FROM BI3" + cEmpTrab + "0 "
					cQryBI3 += "WHERE BI3_FILIAL = '" + xFilial("BI3") + "' "
					cQryBI3 += "  AND D_E_L_E_T_ = ' ' "
					cQryBI3 += "  AND BI3_CODINT = '" + BA1USR->BA1_CODINT + "' "
					If !Empty(BA1USR->BA1_CODPLA)
						cQryBI3 += "  AND BI3_CODIGO = '" + BA1USR->BA1_CODPLA + "' "
					Else
						cQryBI3 += "  AND BI3_CODIGO = '" + BA1USR->BA3_CODPLA + "' "
					EndIf

					cQryBI3 := ChangeQuery(cQryBI3)
					TCQUERY cQryBI3 NEW ALIAS "BI3USR"

					DbSelectArea("BI3USR")

					Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

					DbSelectArea("GD4")
					DbSetOrder(1)
					DbSeek(xFilial("GD4") + cCodUSer )
					While GD4->(!Eof()) .AND. GD4->GD4_REGGER == cCodUser
						If Empty(GD4->GD4_CODCON) .OR. GD4->GD4_CODCON == cConvPLS .AND. GD4->GD4_CODPLA == BI3USR->BI3_HSPPLA
							lChgPla := .F.
							GD4->(RecLock("GD4",.F.))
								Replace GD4->GD4_DTVALI	With StoD(BA1USR->BA1_DTVLCR)
								Replace GD4->GD4_MATRIC	With ALLTRIM(BA1USR->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO))
								Replace GD4->GD4_NOMTIT	With ALLTRIM(BA1USR->BA1_NOMTIT)
								Replace GD4->GD4_CODIGO	With BA1USR->BA1_CODEMP
								Replace GD4->GD4_IDPADR	With "1"				// Plano Padrao
								Replace GD4->GD4_CODINT	With BA1USR->BA1_CODINT
								If !Empty(BA1USR->BA1_CODPLA)
							 		Replace GD4->GD4_CODIGO With BA1USR->BA1_CODPLA
							 	Else
							 		Replace GD4->GD4_CODIGO With BA1USR->BA3_CODPLA
							 	EndIf

								Replace GD4->GD4_CODCON With cConvPLS
								If !Empty(BA1USR->BA1_VERSAO)
									Replace GD4->GD4_VERCON With BA1USR->BA1_VERSAO
								Else
									Replace GD4->GD4_VERCON With BA1USR->BA3_VERSAO
								EndIf

								Replace GD4->GD4_CODPLA	With BI3USR->BI3_HSPPLA
								Replace GD4->GD4_DESCRI With BI3USR->BI3_DESCRI
								Replace GD4->GD4_IDEATI	With "1"

								If Select("NOMOPE") > 0
									DbSelectArea("NOMOPE")
									DbCloseArea()
								EndIf

								Hs_TabPLS("A",cFilAtu)	// Abre as tabelas referente ao PLS

								cQryBA0 := "SELECT BA0_NOMINT "
								cQryBA0 += "FROM BA0" + cEmpTrab + "0 "
								cQryBA0 += "WHERE BA0_FILIAL = '" + xFilial("BA0") + "' "
								cQryBA0 += "  AND D_E_L_E_T_ = ' ' "
								cQryBA0 += "  AND BA0_CODIDE = '" + SubStr(BA1USR->BA1_CODINT,1,1) + "' "
								cQryBA0 += "  AND BA0_CODINT = '" + SubStr(BA1USR->BA1_CODINT,2,3) + "' "

								cQryBA0 := ChangeQuery(cQryBA0)
								TCQUERY cQryBA0 NEW ALIAS "NOMOPE"

								DbSelectArea("NOMOPE")

								Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

								Replace GD4->GD4_DESINT With NOMOPE->BA0_NOMINT
						Else
							GD4->(RecLock("GD4",.F.))
								Replace GD4->GD4_IDPADR	With "0"				// Plano Padrao Nao
							GD4->(MsUnLock())
						EndIf
						GD4->(DbSkip())
					End
					IF lChgPla .and. !empty(cCodUSer) // Caso seja alterado o plano insere o novo
						GD4->(RecLock("GD4",.T.))
							GD4->GD4_FILIAL	:= xFilial("GD4")
							GD4->GD4_REGGER	:= cCodUSer
							GD4->GD4_LOGARQ	:= HS_LOGARQ()
							GD4->GD4_DTVALI	:= StoD(BA1USR->BA1_DTVLCR)
							GD4->GD4_MATRIC	:= ALLTRIM(BA1USR->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO))
							GD4->GD4_NOMTIT	:= ALLTRIM(BA1USR->BA1_NOMTIT)
							GD4->GD4_CODIGO	:= BA1USR->BA1_CODEMP
							GD4->GD4_IDPADR	:= "1"				// Plano Padrao
							GD4->GD4_CODINT	:= BA1USR->BA1_CODINT
							If !Empty(BA1USR->BA1_CODPLA)
								GD4->GD4_CODIGO := BA1USR->BA1_CODPLA
							Else
								GD4->GD4_CODIGO := BA1USR->BA3_CODPLA
							EndIf

							GD4->GD4_CODCON := cConvPLS
							If !Empty(BA1USR->BA1_VERSAO)
								GD4->GD4_VERCON := BA1USR->BA1_VERSAO
							Else
								GD4->GD4_VERCON := BA1USR->BA3_VERSAO
							EndIf

							GD4->GD4_CODPLA	:= BI3USR->BI3_HSPPLA
							GD4->GD4_DESCRI := BI3USR->BI3_DESCRI
							GD4->GD4_IDEATI	:= "1"

							If Select("NOMOPE") > 0
								DbSelectArea("NOMOPE")
								DbCloseArea()
							EndIf

							Hs_TabPLS("A",cFilAtu)	// Abre as tabelas referente ao PLS

							cQryBA0 := "SELECT BA0_NOMINT "
							cQryBA0 += "FROM BA0" + cEmpTrab + "0 "
							cQryBA0 += "WHERE BA0_FILIAL = '" + xFilial("BA0") + "' "
							cQryBA0 += "  AND D_E_L_E_T_ = ' ' "
							cQryBA0 += "  AND BA0_CODIDE = '" + SubStr(BA1USR->BA1_CODINT,1,1) + "' "
							cQryBA0 += "  AND BA0_CODINT = '" + SubStr(BA1USR->BA1_CODINT,2,3) + "' "

							cQryBA0 := ChangeQuery(cQryBA0)
							TCQUERY cQryBA0 NEW ALIAS "NOMOPE"

							DbSelectArea("NOMOPE")

							Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

							GD4->GD4_DESINT := NOMOPE->BA0_NOMINT
						GD4->(MsUnLock())

						DbSelectArea("GD4")
						DbSetOrder(1)
						DbSeek(xFilial("GD4") + cCodUSer )
						While GD4->(!Eof()) .AND. GD4->GD4_REGGER == cCodUser
							If GD4->GD4_CODCON == cConvPLS .AND. GD4->GD4_CODPLA <> BI3USR->BI3_HSPPLA
								GD4->(RecLock("GD4",.F.))
								Replace GD4->GD4_IDPADR	With "0"				// Plano Padrao Nao
								Replace GD4->GD4_DTVALI	With dDataBase			// Validade do plano antigo
								GD4->(MsUnLock())
							EndIf
							GD4->(DbSkip())
						End

					EndIf
					If Select("BA1USR") > 0
						DbSelectArea("BA1USR")
						DbCloseArea()
					EndIf
					If Select("GCMUSR") > 0
						DbSelectArea("GCMUSR")
						DbCloseArea()
					EndIf
					If Select("BG9USR") > 0
						DbSelectArea("BG9USR")
						DbCloseArea()
					EndIf
					If Select("GBHUSR") > 0
						DbSelectArea("GBHUSR")
						DbCloseArea()
					EndIf
					If Select("BA0USR") > 0
						DbSelectArea("BA0USR")
						DbCloseArea()
					EndIf
					If Select("BG9USR") > 0
						DbSelectArea("BG9USR")
						DbCloseArea()
					EndIf
					If Select("NOMOPE") > 0
						DbSelectArea("NOMOPE")
						DbCloseArea()
					EndIf
					If Select("BI3USR") > 0
						DbSelectarea("BI3USR")
						DbCloseArea()
					EndIf
					lRet := .T.
				Else
					lRet := .F.
					If Select("BA1USR") > 0
						DbSelectArea("BA1USR")
						DbCloseArea()
					EndIf
					If Select("GBHUSR") > 0
						DbSelectArea("GBHUSR")
						DbCloseArea()
					EndIf
				EndIf
			Else
			   	DbSelectArea("GBH")
				GBH->(DbSetOrder(8))
				IF GBH->(DbSeek(xFilial("GBH") + BA1USR->BA1_MATVID))
					If Select("BA1USR") > 0
						DbSelectArea("BA1USR")
						DbCloseArea()
					EndIf
					If Select("GBHUSR") > 0
						DbSelectArea("GBHUSR")
						DbCloseArea()
					EndIf

				  		Return(.T.)
		 		 Endif
				DbSelectArea("BA1USR")
				GBH->(RecLock("GBH",.T.))
					GBH->GBH_FILIAL	:= xFilial("GBH")
					GBH->GBH_CODPAC	:= getSx8Num("GBH","GBH_CODPAC")
					If BA1USR->BA1_SEXO == "1"
						GBH->GBH_SEXO	:= "0"		//Masculino
					Else
						GBH->GBH_SEXO	:= "1"		//Feminino
					EndIf
					GBH->GBH_NOME	:= ALLTRIM(BA1USR->BA1_NOMUSR)
					GBH->GBH_DTNASC	:= StoD(BA1USR->BA1_DATNAS)
					GBH->GBH_NOMMAE	:= ALLTRIM(BA1USR->BA1_MAE)
					GBH->GBH_RG		:= BA1USR->BA1_DRGUSR
					GBH->GBH_ORGEMI	:= BA1USR->BA1_ORGEM
					GBH->GBH_CPF	:= BA1USR->BA1_CPFUSR
					GBH->GBH_NOMPAI	:= ALLTRIM(BA1USR->BA1_PAI)
					If BA1USR->BA1_ESTCIV == "C"
						GBH->GBH_ESTCIV	:= "0"
					ElseIf BA1USR->BA1_ESTCIV == "S"
						GBH->GBH_ESTCIV	:= "1"
					ElseIf BA1USR->BA1_ESTCIV == "M"
						GBH->GBH_ESTCIV	:= "3"
					ElseIf BA1USR->BA1_ESTCIV == "V"
						GBH->GBH_ESTCIV	:= "4"
					Else
						GBH->GBH_ESTCIV	:= "2"
					EndIf
					GBH->GBH_CEP	:= BA1USR->BA1_CEPUSR
					GBH->GBH_MUN	:= BA1USR->BA1_CODMUN
					GBH->GBH_EST	:= BA1USR->BA1_ESTADO
					GBH->GBH_END	:= ALLTRIM(BA1USR->BA1_ENDERE)
					GBH->GBH_NUM	:= BA1USR->BA1_NR_END
					GBH->GBH_BAIRRO	:= ALLTRIM(BA1USR->BA1_BAIRRO)
					GBH->GBH_COMPLE	:= BA1USR->BA1_COMEND
					GBH->GBH_CORPEL	:= BA1USR->BA1_CORNAT
					GBH->GBH_ESCOLA	:= BA1USR->BA1_ESCOLA
					GBH->GBH_TEL	:= AllTrim(BA1USR->BA1_DDD) + AllTrim(BA1USR->BA1_TELEFO)
					GBH->GBH_TPSANG	:= BA1USR->BA1_SANGUE
					GBH->GBH_DATCAD	:= StoD(BA1USR->BA1_DATINC)
				If lMativd
				GBH->GBH_MATVID	 :=BA1USR->BA1_MATVID				
				Endif
					Hs_TabPLS("A",cFilAtu)	// Abre as tabelas referente ao PLS

					cQryBG9 := "SELECT BG9_HSPEMP "
					cQryBG9 += "FROM BG9" + cEmpTrab + "0 "
					cQryBG9 += "WHERE BG9_FILIAL = '" + xFilial("BG9") + "' "
					cQryBG9 += "  AND D_E_L_E_T_ = ' ' "
					cQryBG9 += "  AND BG9_CODIGO = '" + BA1USR->BA1_CODEMP + "' "

					cQryBG9 := ChangeQuery(cQryBG9)
					TCQUERY cQryBG9 NEW ALIAS "BG9USR"

					DbSelectArea("BG9USR")

					Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

					GBH->GBH_CODEMP	:= BG9USR->BG9_HSPEMP

					Hs_TabPLS("A",cFilAtu)	// Abre as tabelas da empresa referente ao PLS

					aRetCli :=	PLSAVERNIV(subs(cChvP,1,4),Subs(cChvP,5,4),Subs(cChvP,9,6),BA1USR->BA3_TIPOUS,;
				   				BA1USR->BA3_CONEMP,BA1USR->BA3_VERCON,BA1USR->BA3_SUBCON,BA1USR->BA3_VERSUB,;
				   				nil,Subs(cChvP,15,2),nil,cEmpTrab)

					Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas da empresa referente ao PLS

			   		If Len(aRetCli) > 0
						GBH->GBH_CODCLI		:= aRetCli[1][1]
						GBH->GBH_LOJA		:= aRetCli[1][2]
					Else
						GBH->GBH_CODCLI		:= ""
						GBH->GBH_LOJA		:= ""
					EndIf

					GBH->GBH_CODLOC	:= BA1USR->BA1_CODSET
					GBH->GBH_IDPATE	:= BA1USR->BA1_LOCATE
					GBH->GBH_HORCAD	:= TIME()
					GBH->GBH_USRCAD	:= cUserName
					GBH->GBH_LOGARQ	:= HS_LOGARQ()
					While GetSx8Len() > nSaveSx8Len
							GBH->(ConfirmSX8())
					End
				GBH->(MsUnLock())

				GD4->(RecLock("GD4",.T.))
					GD4->GD4_FILIAL	:= xFilial("GD4")
					GD4->GD4_REGGER	:= GBH->GBH_CODPAC
					GD4->GD4_DTVALI	:= StoD(BA1USR->BA1_DTVLCR)
					GD4->GD4_MATRIC	:= ALLTRIM(BA1USR->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC + BA1_TIPREG + BA1_DIGITO))
					GD4->GD4_NOMTIT	:= ALLTRIM(BA1USR->BA1_NOMTIT)
					If !Empty(BA1USR->BA1_CODPLA)
				 		GD4->GD4_CODIGO := BA1USR->BA1_CODPLA
				 	Else
				 		GD4->GD4_CODIGO := BA1USR->BA3_CODPLA
				 	EndIf
					GD4->GD4_CODCON := cConvPLS
					GD4->GD4_IDPADR	:= "1"				// Plano Padrao
					GD4->GD4_CODINT	:= BA1USR->BA1_CODINT
					GD4->GD4_CODIGO	:= BA1USR->BA1_CODEMP
					If !Empty(BA1USR->BA1_VERSAO)
						GD4->GD4_VERCON := BA1USR->BA1_VERSAO
					Else
						GD4->GD4_VERCON := BA1USR->BA3_VERSAO
					EndIf

					Hs_TabPLS("A",cFilAtu)	// Abre as tabelas referente ao PLS

					// Seleciona o codigo do plano no GH referente a operadora, plano e versao do PLS
					cQryBI3 := "SELECT BI3_HSPPLA, BI3_DESCRI "
					cQryBI3	+= "FROM BI3" + cEmpTrab + "0 "
					cQryBI3 += "WHERE BI3_FILIAL = '" + xFilial("BI3") + "' "
					cQryBI3 += "  AND D_E_L_E_T_ <> '*' "
					cQryBI3 += "  AND BI3_CODINT = '" + BA1USR->BA1_CODINT + "' "
					If !Empty(BA1USR->BA1_CODPLA)
						cQryBI3 += "  AND BI3_CODIGO = '" + BA1USR->BA1_CODPLA + "' "
					Else
						cQryBI3 += "  AND BI3_CODIGO = '" + BA1USR->BA3_CODPLA + "' "
					EndIf

					cQryBI3 := ChangeQuery(cQryBI3)
					TCQUERY cQryBI3 NEW ALIAS "BI3USR"

					DbSelectArea("BI3USR")

					Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

					GD4->GD4_CODPLA	:= BI3USR->BI3_HSPPLA
					GD4->GD4_DESCRI := BI3USR->BI3_DESCRI
					GD4->GD4_IDEATI	:= "1"

					If Select("NOMOPE") > 0
						DbSelectArea("NOMOPE")
						DbCloseArea()
					EndIf

					Hs_TabPLS("A",cFilAtu)	// Abre as tabelas referente ao PLS

					cQryBA0 := "SELECT BA0_NOMINT "
					cQryBA0 += "FROM BA0" + cEmpTrab + "0 "
					cQryBA0 += "WHERE BA0_FILIAL = '" + xFilial("BA0") + "' "
					cQryBA0 += "  AND D_E_L_E_T_ = ' ' "
					cQryBA0 += "  AND BA0_CODIDE = '" + SubStr(BA1USR->BA1_CODINT,1,1) + "' "
					cQryBA0 += "  AND BA0_CODINT = '" + SubStr(BA1USR->BA1_CODINT,2,3) + "' "

					cQryBA0 := ChangeQuery(cQryBA0)
					TCQUERY cQryBA0 NEW ALIAS "NOMOPE"

					DbSelectArea("NOMOPE")

					Hs_TabPLS("F",cFilAtu)	// Fecha as tabelas referente ao PLS

					GD4->GD4_DESINT := NOMOPE->BA0_NOMINT

				GD4->(MsUnLock())
				If Select("BA1USR") > 0
					DbSelectArea("BA1USR")
					DbCloseArea()
				EndIf
				If Select("BI3USR") > 0
					DbSelectArea("BI3USR")
					DbCloseArea()
				EndIf
				If Select("GBHUSR") > 0
					DbSelectArea("GBHUSR")
					DbCloseArea()
				EndIf
				If Select("BA0USR") > 0
					DbSelectArea("BA0USR")
					DbCloseArea()
				EndIf
				If Select("BG9USR") > 0
					DbSelectArea("BG9USR")
					DbCloseArea()
				EndIf
				If Select("NOMOPE") > 0
					DbSelectArea("NOMOPE")
					DbCloseArea()
				EndIf
				If Select("BI3USR") > 0
					DbSelectArea("BI3USR")
					DbCloseArea()
				EndIf
				lRet := .T.
			EndIf
		Else
			Help(" ",1,"REGNOIS")
			lRet := .F.
		EndIf
	EndIf
EndIf

If Select("BA1USR") > 0
	DbSelectArea("BA1USR")
	DbCloseArea()
EndIf
If Select("BI3USR") > 0
	DbSelectArea("BI3USR")
	DbCloseArea()
EndIf
If Select("GBHUSR") > 0
	DbSelectArea("GBHUSR")
	DbCloseArea()
EndIf
If Select("BA0USR") > 0
	DbSelectArea("BA0USR")
	DbCloseArea()
EndIf
If Select("BG9USR") > 0
	DbSelectArea("BG9USR")
	DbCloseArea()
EndIf
If Select("NOMOPE") > 0
	DbSelectArea("NOMOPE")
	DbCloseArea()
EndIf
If Select("BI3USR") > 0
	DbSelectArea("BI3USR")
	DbCloseArea()
EndIf

RestArea(aArea)
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Hs_SelUsr ºAutor  ³Saude               º Data ³  07/21/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para selecionar o usuario do GH, que devera   º±±
±±º          ³ser atualizado com os dados do PLS                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao PLS x GH                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Hs_SelUsr(aUsers)
Local i		:= 0
Local cRet	:= ""

Default aUsers := {}

For i := 1 to Len(aUsers)
	If aUsers[i][1] == .T.
		cRet := AllTrim(aUsers[i][2])	// Codigo do Paciente
	EndIf
Next

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Hs_TabPLS ºAutor  ³Saude               º Data ³  29/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para abrir e fechar as empresas referente ao  º±±
±±º          ³modulo PLS                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao PLS x GH                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Hs_TabPLS(cAbre,cFilAtu,lChPls)
Local aTabelas	:= {"BA3","BCT","BA1","BI3","BTS","BX4","BQC","BED","BG9","BHN","BE4","BD5","BD6","BD7","BA0",;
					"BT5","BT6","BF4","BB6","BG2","BGX","BGZ","BHH","BG1","BC3","BQU","BG3","BCA","BAU","BXR", "BR8"}
//Local cFilOri	:= cFilAnt				// Guarda a filial de origem do GH
Local cEmpOri	:= cEmpAnt				// Guarda a empresa de origem do GH
Local cFilTrab	:= PADR(GetNewPar("MV_FILIPLS", " "),FWSizeFilial())	// Pega a filial de trabalho do PLS
Local cEmpTrab	:= GetNewPar("MV_EMPRPLS", " ")	// Pega a empresa de trabalho do PLS
Local nOrder	:= 1
Local nI		:= 0
//Local lEmpDfPls	:= SuperGetMV("MV_EMPDFPL", NIL, .F.)
If Alltrim(GetNewPar("MV_EMPRPLS", " ")) == Alltrim(GetNewPar("MV_EMPRHSP", " "))//Empresas iguais não precisa entrar na rotina //lEmpDfPls
	Return()
EndIf

Default	lChPls	:= .F. // Chamda vinda do PLS
If lChPls
	aTabelas := {"GBH","GCY","GCZ","GFU","GFS","GBJ","GD4","GB2","GFK","GHP","GCH","GM8","GMJ","GHK","GMT",;
				"GCZ","GBY"}
	cFilTrab := PADR(GetNewPar("MV_FILIHSP", " "),FWSizeFilial())
	cEmpTrab := GetNewPar("MV_EMPRHSP", " ")
EndIf

If cAbre == "A"
	cFilAnt := cFilTrab
	For nI := 1 to Len(aTabelas)
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Abre o arquivo da Empresa Destino                           ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		EmpChangeTable( aTabelas[nI] , cEmpTrab , cEmpOri , nOrder )
	Next nI
Else
	For nI := 1 to Len(aTabelas)
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Restaura o arquivo da Empresa Atual                         ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		EmpChangeTable( aTabelas[nI] , cEmpOri , cEmpTrab , nOrder )
	Next nI
	cFilAnt := cFilAtu
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Hs_IntSen ºAutor  ³Saude               º Data ³  07/21/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para validar a senha do usuario, no caso de   º±±
±±º          ³inclusao de paciente na integracao.                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao PLS x GH                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Hs_IntSen()
Local lRet		:= .F.
Local lSenha	:= .F.
Local lIntegr	:= GetMv("MV_HSPPLS")	// Verifica se existe a integracao dos modulos PLS x GH
Local lIntSen   := SuperGetMv("MV_SENINT",,.T.)

If lIntegr .and.  lIntSen
	lSenha := HS_VldSenh()
		If lSenha
			lRet := HS_A58('GBH', GBH->(RecNo()), 3)
		Else
			lRet := .F.
		EndIf
Else
	lRet := HS_A58('GBH', GBH->(RecNo()), 3)
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FILGFV ³ Autor ³ MARIO ARIZONO         ³ Data ³ 03.07.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ RETORNA SEQUENCIA DA CATEGORIA DO PLANO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_FILGFV() 		       				                              			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION HS_FilGFV()

Local cRetSql := "@"

cRetSql += "GFV_FILIAL = '" + xFilial("GFV") + "' AND D_E_L_E_T_ <> '*'"

If Type("cGfvPlano") # "U" .And. !Empty(cGfvPlano)
 cRetSql += " AND GFV_CODPLA = '" + cGfvPlano + "'"
EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FilGsa ³ Autor ³ Eduardo Alves         ³ Data ³ 02.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da consulta padrao GSA002.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	  ³ HS_FilGsa() 		       				                              			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Void                                						                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		    ³ HSP                                         													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGsa()
 Local	cRetSql := "@GSA_FILIAL = '" + xFilial("GSA") + "' AND D_E_L_E_T_ <> '*' AND GSA_OK <> '2'"

	If Type("cGsaRegGer") # "U" .And. !Empty(cGsaRegGer)
 	cRetSql += "AND GSA_REGGER = '" + cGsaRegGer + "'"
	EndIf
Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilGO0    ³ Autor ³ Daniel Peixoto   ³ Data ³28/11/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Orçamentos                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGO0()
 Local	cRetSql := "@GO0_FILIAL = '" + xFilial("GO0") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGO0Status") # "U" .And. !Empty(cGO0Status)
  cRetSql += "AND GO0_STATUS = '" + cGO0Status + "' "
 EndIf

 If Type("cGO0Atendi") # "U" .And. !Empty(cGO0Atendi)
  cRetSql += "AND GO0_ATENDI = '" + cGO0Atendi + "' "
 EndIf

 If Type("cGO0RegGer") # "U" .And. !Empty(cGO0RegGer)
  cRetSql += "AND GO0_REGGER = '" + cGO0RegGer + "' "
 EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilGGA    ³ Autor ³ Daniel Peixoto   ³ Data ³05/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Mat/Med x Apresentacao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGGA()
 Local	cRetSql := "@GGA_FILIAL = '" + xFilial("GGA") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGGACdMedi") # "U" .And. !Empty(cGGACdMedi)
  cRetSql += " AND GGA_CDMEDI = '" + cGGACdMedi + "' "
 EndIf

Return(cRetSql)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilGGB    ³ Autor ³ Daniel Peixoto   ³ Data ³05/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Mat/Med x posologia                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGGB()
 Local	cRetSql := "@GGB_FILIAL = '" + xFilial("GGB") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGGBCdMedi") # "U" .And. !Empty(cGGBCdMedi)
  cRetSql += " AND GGB_CDMEDI = '" + cGGBCdMedi + "' "
 EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilGGD    ³ Autor ³ Daniel Peixoto   ³ Data ³03/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Mat/Med x Diluente                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGGD()
 Local	cRetSql := "@GGD_FILIAL = '" + xFilial("GGD") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGGDCdMedi") # "U" .And. !Empty(cGGDCdMedi)
  cRetSql += " AND GGD_CDMEDI <> '" + cGGDCdMedi + "' "
 EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_FilGG0 ºAutor  ³Luiz Pereira S. Jr. º Data ³  28/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtro para consulta padrão GG0001.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_FilGG0()
 Local cRetSql := "@GG0_FILIAL = '" + xFilial("GG0") + "' AND D_E_L_E_T_ <> '*'"

 If Type("cGG0TipReg") # "U" .And. !Empty(cGG0TipReg)
  cRetSql += "AND GG0_SEGMEN = '" + cGG0TipReg + "'"
 EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_FilSx3 ºAutor  ³Luiz Pereira S. Jr. º Data ³  05/09/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtro para consulta padrão HSPSX3.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_SXBX3()
 Local nUsado  := 0,  nOpcA   := 0, nSX3Campo := 0
 Local aColsX3 := {}, aHeadX3 := {}
 Local oDlgCons, oGetCons
local cRet:=""
local ni:=0

 aColsX3 := {}
 aHeadX3 := {}

	nUsado := 0
//	Aadd(aHeadX3, {STR0023, "@!", 10, 0, ".F." ,"" ,"C", "xxx", "V","" , ""})//"Campo"
	Aadd(aHeadX3, {STR0023, STR0023    , "@!", 10, 0, ".F.", "", "C", "xxx", "V", "", "", "", "V", "", "", ""})//"Campo"
	nUsado++
	nSx3Campo := nUsado

 Aadd(aHeadX3, {STR0024, "cTipo"    , "@!",  1, 0, ".F.", "", "C", "xxx", "V", "", "", "", "V", "", "", ""})//"Tipo"
	nUsado++

	Aadd(aHeadX3, {STR0025,"cTamanho"  ,   "",  3, 0, ".F.", "", "N", "xxx", "V", "", "", "", "V", "", "", ""})//"Tamanho"
	nUsado++

	Aadd(aHeadX3, {STR0026,"cDecimal"  ,   "",  3, 0, ".F.", "", "N", "xxx", "V", "", "", "", "V", "", "", ""})//"Decimal"
	nUsado++

 Aadd(aHeadX3, { STR0027,"cTitulo"  , "@!", 12, 0, ".F.", "", "C", "xxx", "V", "", "", "", "V", "", "", ""})//"Titulo"
	nUsado++

	Aadd(aHeadX3, {STR0028,"cDescricao", "@!", 25, 0, ".F.", "", "C", "xxx", "V", "", "", "", "V", "", "", ""})//"Descricao"
	nUsado++

	If Type("cSx3CodTab") <> "U" .And. !Empty(cSx3CodTab)
	 DbSelectArea("SX3")
	 DbSetOrder(1)
	 DbSeek(cSx3CodTab)
	While !Eof() .And. (Alltrim(SX3->X3_ARQUIVO) = cSx3CodTab)
	  aAdd(aColsX3, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, X3Titulo(), X3Descri(), .F. })
	  SX3->(DbSkip())
	 End
ElseIf Type("aSx3CodTab") <> "U" .And. len(aSx3CodTab)>0
 For ni:=1 to len(aSx3CodTab)
	DbSelectArea("SX3")
	DbSetOrder(1)
	//	 cRet := IIF(At("/", cSx3CodTab) > 0, SubStr(cSx3CodTab, 1, At("/", cSx3CodTab) - 1), cSx3CodTab)
	//	 aAdd(aTabela, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_TITULO, SX3->X3_DESCRIC, .F. })
	//	 cSx3CodTab:=cRet
	DbSeek(aSx3CodTab[ni])
	While !Eof() .And. (SX3->X3_ARQUIVO == aSx3CodTab[ni])
		If FunName() ==  'PLSPRO01' .And. SX3->X3_ARQUIVO == 'BTS' .And. SX3->X3_CAMPO == 'BTS_IDADE '
			aAdd(aColsX3, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, X3Titulo(), X3Descri(), .F. })
		ElseIf  SX3->X3_CONTEXT <> "V"
			aAdd(aColsX3, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, X3Titulo(), X3Descri(), .F. })
		Endif
		SX3->(DbSkip())
	End
	Next
	Else
 	DbSelectArea("SX3")
 	DbSetOrder(1)
 	DbGotop()
 	While !Eof()
 	 aAdd(aColsX3, {SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, X3Titulo(), X3Descri(), .F. })
 	 SX3->(DbSkip())
 	End
 EndIf

 Define MsDialog oDlgCons Title OemToAnsi(STR0057) From 000, 000 To 500, 850 Of oMainWnd PIXEL //

  oGetCons := MsNewGetDados():New(000, 000, 500, 850, 0,,,,,, 99999,,,, oDlgCons, aHeadX3, aColsX3)
  oGetCons:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

 Activate MsDialog oDlgCons Centered ON INIT EnchoiceBar (oDlgCons, {	|| nOpcA := 1, oDlgCons:End()},	{|| oDlgCons:End()} )

 If nOpcA == 1
  cRetSX3 := oGetCons:aCols[oGetCons:nAt, nSx3Campo]
 EndIf

Return(nOpcA == 1)

Function HS_RSXBX3(cCampo)
 If (ReadVar() $ "M->GND_CHAVE/M->GNE_CPOMAC")
  If Trim(cRetSX3) $ &(ReadVar())
   &(cCampo) := &(ReadVar())
  Else
   &(cCampo) := Trim(&(ReadVar()))+IIF(Empty(&(ReadVar())),"",IIF(ReadVar() == "M->GNE_CPOMAC"," +' - '+ ", " + ")) + PADL(SubStr(cRetSX3,1,At("_",cRetSX3)-1),3,"S")+"->"+cRetSX3
  EndIf
  &(cCampo) := PADR(&(cCampo),TAMSX3(SubStr(ReadVar(),4))[1]," ")
 Else
 &(cCampo) := cRetSX3
 EndIf
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_FilSix ºAutor  ³Mario Arizono       º Data ³  13/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtro para consulta padrão HSP004.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_FilSix()
 Local lRet    := .F.
 Local nUsado  := 0,  nOpcA   := 0, nSX3Campo := 0
 Local aColIX := {}, aHeadIX := {}
 Local oDlgCons, oGetCons

 aColsIX := {}
 aHeadIX := {}

	nUsado := 0
	Aadd(aHeadIX, {STR0029           , "cIndice"   , "@!", 003, 0,,, "C",, "V",,,,"V"}) //"Indice"
 Aadd(aHeadIX, {STR0030           , "cOrdem"    , "@!", 001, 0,,, "C",, "V",,,,"V"}) //"Ordem"
 Aadd(aHeadIX, {STR0031           , "cChave"    , "@!", 160, 0,,, "C",, "V",,,,"V"}) //"Chave"
 Aadd(aHeadIX, {STR0028           , "cDescricao", "@!", 070, 0,,, "C",, "V",,,,"V"}) //"Descricao"


	If Type("cTabSix") <> "U" .And. !Empty(cTabSix)
	 DbSelectArea("SIX")
	 DbSeek(cTabSix)
	 While !Eof() .And. (SIX->INDICE == cTabSix)
	  aAdd(aColsIX, {SIX->INDICE, SIX->ORDEM, SIX->CHAVE, SIX->DESCRICAO, .F. })
	  SIX->(DbSkip())
	 End
	EndIf

 Define MsDialog oDlgCons Title OemToAnsi(STR0032) From 000, 000 To 500, 850 Of oMainWnd PIXEL //"Indices"

  oGetCons := MsNewGetDados():New(000, 000, 500, 850, 0,,,,,, 99999,,,, oDlgCons, aHeadIX, aColsIX)
  oGetCons:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

 Activate MsDialog oDlgCons Centered ON INIT EnchoiceBar (oDlgCons, {	|| nOpcA := 1, oDlgCons:End()},	{|| nOpcA := 0, oDlgCons:End()} )

 If nOpcA == 1
  __cRetSix := oGetCons:aCols[oGetCons:nAt, 2]
  lRet := .T.
 EndIf

Return(lRet)

Function HS_SXBSIX()
 &(Readvar()) := __cRetSix
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_SttGui ºAutor  ³HEIMDALL CASTRO     º Data ³  29/05/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtro para consulta padrão HSP007.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_SttGui()
 Local lRet    := .F.
 Local nUsado  := 0,  nOpcA   := 0, nSX3Campo := 0
 Local aColsStt := {}, aHeadStt := {}
 Local oDlgCons, oGetCons

 aColsStt := {}
 aHeadStt := {}

	nUsado := 0
	Aadd(aHeadStt, {"Código"          , "cCodigo"   , "@!", 003, 0,,, "C",, "V",,,,"V"}) //"Indice"
 Aadd(aHeadStt, {STR0028           , "cDescri"    , "@!", 070, 0,,, "C",, "V",,,,"V"}) //"Ordem"

 aAdd(aColsStt, {"0", "Controle de Contas"   , .F. })
 aAdd(aColsStt, {"1", "Faturamento"          , .F. })
 aAdd(aColsStt, {"2", "Faturado"             , .F. })
 aAdd(aColsStt, {"3", "Lote Atrbuido"        , .F. })
 aAdd(aColsStt, {"4", "Gerado Faturas"       , .F. })
 aAdd(aColsStt, {"5", "Associado Extrat Conv", .F. })
 aAdd(aColsStt, {"6", "Liquidado"            , .F. })
 aAdd(aColsStt, {"7", "Quitado"              , .F. })
 aAdd(aColsStt, {"8", "Todos"                , .F. })

 Define MsDialog oDlgCons Title OemToAnsi(STR0032) From 000, 000 To 500, 850 Of oMainWnd PIXEL //"Indices"

  oGetCons := MsNewGetDados():New(000, 000, 500, 850, 0,,,,,, 99999,,,, oDlgCons, aHeadStt, aColsStt)
  oGetCons:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

 Activate MsDialog oDlgCons Centered ON INIT EnchoiceBar (oDlgCons, {	|| nOpcA := 1, oDlgCons:End()},	{|| nOpcA := 0, oDlgCons:End()} )

 If nOpcA == 1
  __cRetStt := oGetCons:aCols[oGetCons:nAt, 1]
  lRet := .T.
 EndIf

Return(lRet)

Function HS_SXBSTT()
 &(Readvar()) := __cRetStt
Return(.T.)

Function HS_PreMed(oObjPre, nPosApre, cCodLoc, nTamCpo, nMedican, nCdItpo, cRegate, nVolDie, nCodVia, nVelInf, nCdMinf, nCdFrqa, nObsreg)
 Local nOpcA  := 0
 Local aJoin  := {}, aOPesq := {}

 Private nVolume := 0, cCodVia := SPACE(LEN(GGD->GGD_CODVIA)), cCdFrqa := SPACE(LEN(GGB->GGB_CDFRQA))
 Private cObserv := SPACE(LEN(GDY->GDY_OBSERV)), cVelInf := SPACE(LEN(GGD->GGD_VELINF)), cCdMinf := SPACE(LEN(GGD->GGD_CDMINF))
 Private cDsMinf := SPACE(LEN(GFY->GFY_DSMINF)), cDsFrqa := SPACE(30), cDesVia := SPACE(LEN(GFW->GFW_DESVIA))
 Private cFreCui := SPACE(LEN(GGB->GGB_CDFRQA)), cDesFre := SPACE(30), cComple := SPACE(200)
 Private oDlgPre, lRetCP := .F.
 Private oPre, oGGA, oGGB, oGGW, oGBI, oGDY, oGNP, oPPesq, oVolume, oVia, oFrequ, oObserv, oVeloc, oInfus, oDsMinf, oDsFrqa, oDesVia, oFreCui, oDesFre, oComple
 Private aHPre := {}, aHGGA := {}, aHGGB := {}, aHGGW := {}, aHGBI := {}, aHGDY := {}, aHGNP := {}
 Private aCPre := {}, aCGGA := {}, aCGGB := {}, aCGGW := {}, aCGBI := {}, aCGDY := {}, aCGNP := {}
 Private nUPre := 0,  nUGGA := 0,  nUGGB := 0, nUGGW := 0, nUGBI := 0, nUGDY := 0, nUGNP := 0
 Private aRetDiet  := {}   // array utilizado para preenchimento da variavel __aItDieta
                         // [01] - Codigo Dieta
                         // [02] - Descricao Dieta
                         // [03] - Tipo item da prescricao
                         // [04] - Cor legenda do item da prescricao
                         // [05] - Volume
                         // [06] - Codigo da via
                         // [07] - Descricao da via
                         // [08] - Velocidade
                         // [09] - Bomba infusora
                         // [10] - Descricao bomba infusora
                         // [11] - Codigo Frequencia
                         // [12] - Descricao da frequencia
                         // [13] - Observacao

 Private aRetCuid  := {}// array utilizado para preenchimento da variavel __aItCuida
                         // [01] - Codigo Cuidado
                         // [02] - Descricao Cuidado
                         // [03] - Tipo item da prescricao
                         // [04] - Cor legenda do item da prescricao
                         // [05] - Codigo frequencia
                         // [06] - Descricao frequencia
                         // [07] - Complemento

 Private aRetPresc := {} // array utilizado para preenchimento da variavel __aItPresc
                         // [01] - Codigo Medicamento
                         // [02] - Descricao Medicamento
                         // [03] - Tipo item da prescricao
                         // [04] - Cor legenda do item da prescricao
                         // [05] - Apresentacao final
                         // [06] - Disparo
                         // [07] - Tipo Regime
                         // [08] - Observacao Regime
                         // [09] - Observacao
                         // [10] - Itens da aba apresentacao
                         // [11] - Itens da aba frequencia
                         // [12] - Itens da aba Und. Consumo
                         // [13] - Itens da aba Medic. Composto
                         // [14] - Qtde Med
 Private nPreCdMedi := 0, nPreIdMark := 0, nPreQtde := 0, nPreAprese := 0, nPreDesMed := 0, nPreIdRegi := 0, nPreObsReg := 0
 Private nGGACdItAp := 0, nGGAIdMark := 0
 Private nGGBIdMark := 0, nGGBCdItpo:= 0
 Private nGGWIdMark := 0, nGGWCdItuc := 0
 Private nGBIIdmark := 0; nGBIProdut := 0; nGBIQtde := 0; nGBIUnicon := 0; nGBIUmdRes := 0
 Private nGDYIdmark := 0; nGDYCoddie := 0; nGDYDesDie := 0
 Private nGNPIdmark := 0; nGNPCodCui := 0; nGNPDesCui := 0
 Private aMemJust	:= {} // Vetor de Justificativas dos medicamentos controlados
 Private aMedCtrl	:= {} // Vetor de Medicamentos controlados
 Private lExDicJust := HS_EXISDIC({{"C", "GHX_JUSTIF"}},.F.)

 Default cCodLoc    := ""
 Default cRegate    := ""

 FS_MntDieta()

 FS_MntMedic(.T., '')


 FS_MntCuida()

 If Empty(aCPre) .And. Empty(aCGDY) .And. Empty(aCGNP)
  HS_MsgInf(STR0058, STR0059, STR0060) //"Nenhum dado encontrado para montagem dos itens."###"Atenção"##"Validação dos itens consultados para prescrição."
  Return(Nil)
 Endif

 aSize := MsAdvSize(.T.)
 aObjects := {}
 AAdd( aObjects, { 100, 013, .T., .T., .T. } )
 AAdd( aObjects, { 100, 047, .T., .T.,.T. } )
 AAdd( aObjects, { 100, 040, .T., .T.,.T. } )

 aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObjs := MsObjSize( aInfo, aObjects, .T. )

 aObjects := {}
 AAdd( aObjects, { 100, 100, .T., .T. } )

 aInfo := { aPObjs[2, 1], aPObjs[2, 2], aPObjs[2, 3], aPObjs[2, 4], 0, 0 }
 aPGDs := MsObjSize( aInfo, aObjects, .T. )

 aAdd(aOPesq, {"oGDY"})
 aAdd(aOPesq, {"oPre"})
 aAdd(aOPesq, {"oGNP"})

 Define MsDialog oDlgPre Title OemToAnsi(STR0033) From aSize[7], 000 To aSize[6], aSize[5] Of oMainWnd PIXEL     //"Itens da Prescrição"

  oPPesq	:=	tPanel():New(aPObjs[1, 1], aPObjs[1, 2],, oDlgPre,,,,,, aPObjs[1, 3], aPObjs[1, 4])
  oPPesq:Align := CONTROL_ALIGN_TOP

  // Monta o Folder
  @ aPObjs[2, 1], aPObjs[2, 2] FOLDER oFolder SIZE aPObjs[2, 3], aPObjs[2, 4] Pixel Of oDlgPre Prompts STR0091, STR0061, STR0069  //"Dieta"##"Medicamento"##"Cuidados"
  oFolder:Align := CONTROL_ALIGN_ALLCLIENT
  oFolder:bChange    := {|| Iif(oFolder:nOption == 1,HS_GDPesqu(,,oGDY,oPPesq,001,.T.,2),Iif(oFolder:nOption == 2,HS_GDPesqu(,,oPre,oPPesq,001,.T.,2),HS_GDPesqu(,,oGNP,oPPesq,001,.T.,2))), IIf(oFolder:nOption == 2, oBtnJust:Enable(),oBtnJust:Disable() )}

  //Dieta
  oGDY := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder:aDialogs[1], aHGDY, aCGDY)
  oGDY:oBrowse:BlDblClick := {|| Fs_FilCDie(oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], nGDYIdMark, nGDYCodDie, .T., oGDY, aRetDiet, .T., oGDY:aCols[oGDY:oBrowse:nAt, nGDYDesDie])}
  oGDY:oBrowse:bchange:= {|| Fs_FilCDie(oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], nGDYIdMark, nGDYCodDie, .F., oGDY, aRetDiet, .T., oGDY:aCols[oGDY:oBrowse:nAt, nGDYDesDie])}
  oGDY:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  //Medicamento
  oPre := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], GD_UPDATE,,,,,,99999,,,,oFolder:aDialogs[2], aHPre, aCPre)
  oPre:oBrowse:BlDblClick := {|| IIF (!(StrZero(oPre:oBrowse:nColPos, 2) $ (StrZero(nPreQtde, 2)+ "/" + StrZero(nPreIdRegi, 2)+ "/" + StrZero(nPreObsReg, 2))), FS_FilMed("PRE", nPreIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi],, nPreAprese, oPre:aCols[oPre:oBrowse:nAt, nPreDesMed], cCodLoc ), oPre:EDITCELL(oPre:OBROWSE, oPre:oBrowse:nAt, oPre:oBrowse:nColPos)) }
  oPre:oBrowse:bchange:= {|| IIF(oPre:aCols[oPre:oBrowse:nAt, nPreIdMark] == "LBTIK", FS_Filmed("PRE", nPreIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi], .T.), IIF(!Empty(oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]), FS_LIMACOL(), Nil))}
  oPre:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  //Cuidados
  oGNP := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder:aDialogs[3], aHGNP, aCGNP)
  oGNP:oBrowse:BlDblClick := {|| Fs_FilCDie(oGNP:aCols[oGNP:oBrowse:nAt, nGNPCodCui], nGNPIdMark, nGNPCodCui, .T., oGNP, aRetCuid, .F., oGNP:aCols[oGNP:oBrowse:nAt, nGNPDesCui])}
  oGNP:oBrowse:bchange:= {|| Fs_FilCDie(oGNP:aCols[oGNP:oBrowse:nAt, nGNPCodCui], nGNPIdMark, nGNPCodCui, .F., oGNP, aRetCuid, .F., oGNP:aCols[oGNP:oBrowse:nAt, nGNPDesCui])}
  oGNP:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT


  oPanDiet	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oFolder:aDialogs[1],,,,,, aPObjs[3, 3], aPObjs[3, 4])
  oPanDiet:Align := CONTROL_ALIGN_BOTTOM


   @ 015, 010 Say OemToAnsi(STR0070) Size 030, 009 OF oPanDiet PIXEL COLOR CLR_BLUE //"Volume"
   @ 014, 045 MSGet oVolume var nVolume VALID FS_VldCod(, , nVolume, , , oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], 5,,aRetDiet) Size 020, 009 OF oPanDiet PICTURE "@E 99999" PIXEL COLOR CLR_BLACK

   @ 015, 085 Say OemToAnsi(STR0071) Size 040, 009 OF oPanDiet PIXEL COLOR CLR_BLUE    //"Frequência"
   @ 014, 120 MSGet oFrequ var cCdFrqa PICTURE "@!" VALID FS_VldCod("GFZ", "GFZ_DSFRQA", cCdFrqa, @cDsFrqa, STR0072, oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], 11, 12, aRetDiet) Size 024, 009 OF oPanDiet PIXEL COLOR CLR_BLACK  F3 "GFZ001"  //"Código de frequência "

   @ 015, 175 Say OemToAnsi(STR0073) Size 040, 009 OF oPanDiet PIXEL COLOR CLR_BLUE    //"Descrição"
   @ 014, 210 MSGet oDsFrqa var cDsFrqa PICTURE "@!" Size 120, 009 OF oPanDiet PIXEL COLOR CLR_BLACK  When .F.

   @ 015, 345 Say OemToAnsi(STR0074) Size 030, 009 OF oPanDiet PIXEL COLOR CLR_BLUE    //"Via"
   @ 014, 375 MSGet oVia var cCodVia PICTURE "@!" VALID FS_VldCod("GFW", "GFW_DESVIA", cCodVia, @cDesVia, STR0075, oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], 6, 7, aRetDiet) Size 24, 009 OF oPanDiet PIXEL COLOR CLR_BLACK  F3 "GFW001" //"Código da Via "

   @ 015, 420 Say OemToAnsi(STR0073) Size 040, 009 OF oPanDiet PIXEL COLOR CLR_BLUE   //"Descrição"
   @ 014, 465 MSGet oDesVia var cDesVia PICTURE "@!" Size 160, 009 OF oPanDiet PIXEL COLOR CLR_BLACK  When .F.

   @ 045, 010 Say OemToAnsi(STR0076) Size 040, 009 OF oPanDiet PIXEL COLOR CLR_BLUE  //"Veloc. Inf."
   @ 044, 045 MSGet oVeloc var cVelInf PICTURE "@!" VALID FS_VldCod(, , cVelInf, , , oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], 8,, aRetDiet) Size 024, 009 OF oPanDiet PIXEL COLOR CLR_BLACK

   @ 045, 085 Say OemToAnsi(STR0077) Size 040, 009 OF oPanDiet PIXEL COLOR CLR_BLUE   //"Bomba Inf."
   @ 044, 120 MSGet oInfus var cCdMinf PICTURE "@!" VALID FS_VldCod("GFY", "GFY_DSMINF", cCdMinf, @cDsMinf, STR0078, oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], 9, 10, aRetDiet) Size 024, 009 OF oPanDiet PIXEL COLOR CLR_BLACK  F3 "GFY001" //"Modo de Infusão "

   @ 045, 175 Say OemToAnsi(STR0073) Size 050, 009 OF oPanDiet PIXEL COLOR CLR_BLUE    //"Descrição"
   @ 044, 210 MSGet oDsMinf var cDsMinf PICTURE "@!" Size 160, 009 OF oPanDiet PIXEL COLOR CLR_BLACK  When .F.

   @ 075, 010 Say OemToAnsi(STR0079) Size 040, 009 OF oPanDiet PIXEL COLOR CLR_BLUE    //"Observação"
   @ 074, 045 MSGet oObserv var cObserv PICTURE "@!" Valid FS_VldCod(, , cObserv, , , oGDY:aCols[oGDY:oBrowse:nAt, nGDYCodDie], 13,, aRetDiet) Size 200, 009 OF oPanDiet PIXEL COLOR CLR_BLACK


  oPanCuid	:=	tPanel():New(aPObjs[3, 1], aPObjs[3, 2],, oFolder:aDialogs[3],,,,,, aPObjs[3, 3], aPObjs[3, 4])
  oPanCuid:Align := CONTROL_ALIGN_BOTTOM

   @ 015, 010 Say OemToAnsi(STR0071) Size 040, 009 OF oPanCuid PIXEL COLOR CLR_BLUE    //"Frequência"
   @ 014, 055 MSGet oFreCui var cFreCui PICTURE "@!" VALID FS_VldCod("GFZ", "GFZ_DSFRQA", cFreCui, @cDesFre, STR0072, oGNP:aCols[oGNP:oBrowse:nAt, nGNPCodCui], 5, 6, aRetCuid) Size 024, 009 OF oPanCuid PIXEL COLOR CLR_BLACK  F3 "GFZ001"  //"Código de frequência "

   @ 015, 100 Say OemToAnsi(STR0073) Size 040, 009 OF oPanCuid PIXEL COLOR CLR_BLUE     //"Descrição"
   @ 014, 145 MSGet oDesFre var cDesFre Size 120, 009 OF oPanCuid PICTURE "@!" PIXEL COLOR CLR_BLACK  When .F.

   @ 045, 010 Say OemToAnsi(STR0080) Size 045, 009 OF oPanCuid PIXEL COLOR CLR_BLUE  //"Complemento"
   @ 044, 055 MSGet oComple  var cComple  VALID FS_VldCod(, , cComple, , , oGNP:aCols[oGNP:oBrowse:nAt, nGNPCodCui], 7,, aRetCuid) Size 350, 009 OF oPanCuid PICTURE "@!" PIXEL COLOR CLR_BLACK

  @ aPObjs[3, 1], aPObjs[3, 2] FOLDER oFolder1 SIZE aPObjs[3, 3], aPObjs[3, 4] Pixel Of oFolder:aDialogs[2] Prompts STR0062, STR0063, STR0064, STR0081 //"Apresentação"##"Frequência"##"Unidade Consumo"##"Medic. Composto"
  oFolder1:Align := CONTROL_ALIGN_BOTTOM

  //Apresentacao
  oGGA := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder1:aDialogs[1], aHGGA, aCGGA)
  oGGA:oBrowse:BlDblClick := {|| FS_FilMed("GGA", nGGAIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]) }
  oGGA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  //Posologia
  oGGB := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder1:aDialogs[2], aHGGB, aCGGB)
  oGGB:oBrowse:BlDblClick := {|| FS_FilMed("GGB", nGGBIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]) }
  oGGB:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  //Unidade COnsumo
  oGGW := MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], 0,,,,,,99999,,,,oFolder1:aDialogs[3], aHGGW, aCGGW)
  oGGW:oBrowse:BlDblClick := {|| FS_FilMed("GGW", nGGWIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]) }
  oGGW:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

   //Composto
  oGBI:= MsNewGetDados():New(aPGDs[1, 1], aPGDs[1, 2], aPGDs[1, 3], aPGDs[1, 4], GD_UPDATE,,,,,,99999,,,,oFolder1:aDialogs[4], aHGBI, aCGBI)
  oGBI:oBrowse:BlDblClick := {|| FS_FilMed("GBI", nGBIIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]) }
//  oGBI:oBrowse:BlDblClick := {|| IIF (!(StrZero(oGBI:oBrowse:nColPos, 2) $ (StrZero(nGbiQtde, 2)+ "/" + StrZero(nGbiUniCon, 2))), FS_FilMed("GBI", nGBIIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]), IIF(oPre:aCols[oPre:oBrowse:nAt, 1] == "LBNO", FS_FilMed("GBI", nGBIIdMark, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]), oGbi:EDITCELL(oGbi:OBROWSE, oGbi:oBrowse:nAt, oGbi:oBrowse:nColPos))) }

  oGBI:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

  oDlgPre:bStart := { || oPre:Refresh(), oGdy:Refresh(), oGnp:Refresh()}

  oBtnJust := tButton():New(001, aPObjs[1, 1] + 260, "Justificativa", oPPesq, {|| FS_EMemo("GHX_JUSTIF","Justificativa", oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi] ,.T.,oPre:aCols[oPre:oBrowse:nAt, nPreIdMark]) }, 050, 012,,,, .T.)   //"Desinstala"
//  oBtn1 := tButton():New(nPosIni, 205, STR0002, oDlgP, {|| IIF(FS_EfeP(cChvP, Val(nCpoS), oGDPesq, cPict, lFiltra, cFiltro), oDlgP:End(), .F.)}, 030, 012,,,, .T.)
  oBtnJust:Disable()
  HS_GDPesqu( , , oGDY, oPPesq, 001,.T., 2)
 ACTIVATE MSDIALOG oDlgPre ON INIT EnchoiceBar(oDlgPre, {|| nOpcA := 1, IIf(IIF(!Empty(aRetPresc), FS_VLDPRES(oPre), .T.), oDlgPre:End(), nOpcA := 0)}, ;
                                                        {|| nOpcA := 0, oDlgPRe:End()})

 If nOpcA == 1
  FS_GRVPRE(oObjPre, nPosApre, nTamCpo, nMedican, nCdItpo, nVolDie, nCodVia, nVelInf, nCdMinf, nCdFrqa, nObsreg)
 Endif


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_EMemo º Autor ³ Rogerio Tabosa     º Data ³  10/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Abre campo memo                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar (Agenda Ambulatorial)             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_EMemo(cCampo, cLabel, cMatMed, lEdit,cMarc)
 Local oDlgM, oTexto, cTexto	:= "", aCpoMem := HS_CfgSx3(cCampo),  cMsg := "" //,aCpoMsg := HS_CfgSx3(SubStr(cCpoMsg, 6))
 Local nPos := 0, nPosCtrl := 0

If cMarc == "LBNO"
	Return(Nil)
ElseIf (nPosCtrl := aScan(aMedCtrl, {| aVet | aVet[1] == cMatMed})) == 0
	Return(Nil)
EndIf

lEdit  := IIf(lEdit  == Nil,           .T., lEdit)
cLabel := IIf(cLabel == Nil,            "", cLabel)

nPos := aScan(aMemJust, {|aVet | aVet[1] == cMatMed})

If nPos == 0
	cTexto := ""
Else
	cTexto := aMemJust[nPos,2]
EndIf

DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,510 TITLE STR0093 PIXEL //"Justificativa Medicamento Controlado"

  @ 015, 004 TO 085, 200 Label cLabel OF oDlgM PIXEL
  @ 025, 010 GET oTexto VAR cTexto MEMO When lEdit SIZE 178.64, 051 OF oDlgM PIXEL

DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (lOkJustif := FS_GMemo(cMatMed,cTexto),IIf(lOkJustif,oDlgM:End(),)) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED VALID IIf(Empty(Alltrim(cTexto)),.F.,.T.)


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_GMemo º Autor ³ Rogerio Tabosa     º Data ³  16/03/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Efetua a gravação do memo no Grid                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Prescricao Medica                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_GMemo(cMatMed,cTexto)
Local nPos := 0 , nPosRetP := 0

If Empty(Alltrim(cTexto))
	HS_MSGINF(STR0094,STR0059,STR0095) //"Informe a justificativa!""Validação Justificativa Medicamento"	"Atencao"
	Return(.F.)
EndIf

nPos := aScan(aMemJust, {|aVet | aVet[1] == cMatMed})
nPosRetP := aScan(aRetPresc, {|aVet | aVet[1] == cMatMed})

If nPos == 0
	AADD(aMemJust,{cMatMed,cTexto,.F.})
	If nPosRetP > 0
		aRetPresc[nPosRetP, 15] := cTexto
	EndIf
Else
	aMemJust[nPos,2] := cTexto
	If nPosRetP > 0
		aRetPresc[nPosRetP, 15] := cTexto
	EndIf
EndIf

Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FilMed ºAutor  ³Mario Arizono       º Data ³  18/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que monta vetor para utilizacao no preenchimento dos º±±
±±º          ³itens da prescricao medica do tipo medicamento.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FilMed(cAlias, nPosMark, cCodPro, lMosItem, nPreAprese, cDesMed, cCodLoc)
Local nForACols  := 0, nPos := 0, nPosItem := 0, nPosCtrl := 0, nPosAntib := 0
Local cCOndSql   := ""
Local aJoin      := {}
Local oObj       := &("o" + cAlias)
Local lJustif	 := .F.
Local lExDicJust := HS_EXISDIC({{"C", "GHX_JUSTIF"}},.F.)
Local n			 := 0

Default lMosItem := .F.
Default cDesMed  := ""

nPos := aScan(aRetPresc, {| aVet | aVet[1] == cCodPro})

If Len(oObj:aCols) == 0
	aAdd(oObj:aCols, Array(Len(oObj:aHeader)+1))
	For n := 1 To Len(oObj:aHeader)
		oObj:aCols[1, n] := Criavar(oObj:aHeader[n, 2])
	Next n
	oObj:aCols[1, n] := .F.
	oObj:oBrowse:nAt := 1
	Return
EndIf

If !lMosItem
	If !Empty(oObj:aCols[oObj:oBrowse:nAt, 1]) .And. !Empty(oObj:aCols[oObj:oBrowse:nAt, 2])
		If oObj:aCols[oObj:oBrowse:nAt, nPosMark] == "LBNO"

			oObj:aCols[oObj:oBrowse:nAt, nPosMark] := "LBTIK"

			If nPos > 0
				If cAlias <> "GBI"
					aRetPresc[nPos,IIF(cAlias == "GGA", 10, IIF(cAlias == "GGB", 11, 12))] := aClone(oObj:aCols[oObj:oBrowse:nAt])
				Else
					aAdd(aRetPresc[nPos][13], aClone(oObj:aCols[oObj:oBrowse:nAt]))
					aAdd(aRetPresc[nPos][13][len(aRetPresc[nPos][13])], "4")
					aAdd(aRetPresc[nPos][13][len(aRetPresc[nPos][13])], "")
				Endif
				HS_MNTAPRE(.T.)
			Endif
			If !(cAlias $ "PRE/GBI")
				For nForACols := 1 to Len(oObj:aCols)
					If oObj:aCols[nForACols, nPosMark] == "LBTIK" .And. nForACols <> oObj:oBrowse:nAt
						oObj:aCols[nForACols, nPosMark] := "LBNO"
						Exit
					Endif
				Next
			Endif
		ElseIf oObj:aCols[oObj:oBrowse:nAt, nPosMark] == "LBTIK" .And. cAlias $ "PRE/GBI"
			oObj:aCols[oObj:oBrowse:nAt, nPosMark] := "LBNO"
			If cAlias == "PRE"
				oObj:aCols[oObj:oBrowse:nAt, nPreAprese] := SPACE(LEN(GGA->GGA_APRESE))
			Endif
			If nPos > 0

				If cAlias == "PRE"
					aDel(aRetPresc, nPos)
					aSize(aRetPresc, Len(aRetPresc) - 1)
				Else
					aDel( aRetPresc[npos, 13], aScan(aRetPresc[nPos, 13], {| aVet | aVet[2] == oObj:aCols[oObj:oBrowse:nAt, 2]}))
					aSize(aRetPresc[npos,13], Len(aRetPresc[npos, 13]) - 1)
				Endif

			Endif
		Endif
	Endif

Endif

If cAlias == "PRE"
	If oObj:aCols[oObj:oBrowse:nAt, nPosMark] == "LBTIK"
		aCGGA := {}
		aCGGB := {}
		aCGGW := {}
		aCGBI := {}

		FS_MntMedic( ,cCodPro, lMosItem, nPos)
		If !lMosItem
			If nPos == 0
				AADD(aRetPresc,{cCodPro, cDesMed, "1","BR_VERDE", "" , 0, "0", , , {}, {}, {},{}, 0,""})
				If !Empty(cCodLoc)
					DbSelectArea("GNL")
					DbSetOrder(2)
					If DbSeek(xFilial("GNL") + cCodPro + cCodLoc)
						aRetPresc[len(aRetPresc), 6] := GNL->GNL_DISPAR
						aRetPresc[len(aRetPresc), 9] := GNL->GNL_OBSERV
					Endif
				Endif
			Endif

			//Apresentacoes
			nPosItem := aScan(oGGA:aCols, {| aVet | aVet[1] == "LBTIK"})

			If nPosItem > 0
				aRetPresc[len(aRetPresc), 10] := aClone(oGGA:aCols[nPosItem])
			Endif

			//Posologias
			nPosItem := aScan(oGGB:aCols, {| aVet | aVet[1] == "LBTIK"})

			If nPosItem > 0
				aRetPresc[len(aRetPresc), 11] := aClone(oGGB:aCols[nPosItem])
			Endif

			//Unid. Consumo
			nPosItem := aScan(oGGW:aCols, {| aVet | aVet[1] == "LBTIK"})

			If nPosItem > 0
				aRetPresc[len(aRetPresc), 12] := aClone(oGGW:aCols[nPosItem])
			Endif

			HS_MNTAPRE(.T.)
		Endif
		If lExDicJust
			nPosCtrl := aScan(aMedCtrl, {| aVet | aVet[1] == cCodPro})
			If nPosCtrl > 0 // Casp o medicamento seja controlado solicita justificativa
				nPosAntib := aScan(aMemJust, {| aVet | aVet[1] == cCodPro})
				lJustif := .T.
				If nPosAntib > 0
					aMemJust[nPosAntib,3] := .F.
				EndIf
			EndIf
		EndIf
	Else
		nPosAntib := aScan(aMemJust, {| aVet | aVet[1] == cCodPro})
		If nPosAntib > 0 // Caso seja desmarcação atribui false para não gravar a justificativa
			aMemJust[nPosAntib,3] := .T.
		EndIf
		FS_LimAcol()
	EndIf
Endif
If oObj:aCols[oObj:oBrowse:nAt, nPosMark] == "LBTIK"
	oGGA:Refresh()
	oGGB:Refresh()
	oGGW:Refresh()
	oGBI:Refresh()
	oPre:Refresh()
Endif
If lJustif .AND. lExDicJust
	FS_EMemo("GHX_JUSTIF","Justificativa", oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi] ,.T.,oPre:aCols[oPre:oBrowse:nAt, nPreIdMark])
EndIf
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_MNTDIETA  ³ Autor ³ Mario Arizono    ³ Data ³16/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Funcao que monta acols da dieta utilizados na funcao      ³±±
±±³          ³  HS_PREMED.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MntDieta()
 Local     aJoin := "" , aCampos := {}
 Local     cSQL := ""
 Local     aArea:= GetArea()


  HS_BDados("SX5",  @aHGDY,  @aCGDY,  @nUGDY,  1, ," SX5.X5_TABELA = 'TE' ", , ,  , , "X5_TABELA /X5_DESCSPA/X5_DESCENG" , , "GDY_IDPADR","'LBNO'",, , , , , ,)
  nGDYIdMark := aScan(aHGDY, {|aVet| AllTrim(aVet[2]) == "GDY_IDPADR"})
  nGDYCodDie := aScan(aHGDY, {|aVet| AllTrim(aVet[2]) == "X5_CHAVE"})
  nGDYDesDie := aScan(aHGDY, {|aVet| AllTrim(aVet[2]) == "X5_DESCRI"})


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FilCDieºAutor  ³Mario Arizono       º Data ³  18/02/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que monta vetor para utilizacao no preenchimento dos º±±
±±º          ³itens da prescricao medica do tipo dieta e cuidados.        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FilCDie(cCodigo, nPosMark, nPosCod, lDbclick, oObj, aRetCpo, lDieta, cDescricao)
Local nForACols  := 0, nPos := 0, nPosItem := 0

 nPos := aScan(aRetCpo, {| aVet | aVet[1] == cCodigo})

 If !Empty(oObj:aCols[oObj:oBrowse:nAt, nPosCod])
  If lDbclick
   If oObj:aCols[oObj:oBrowse:nAt, nPosMark] == "LBNO"

     oObj:aCols[oObj:oBrowse:nAt, nPosMark] := "LBTIK"

     If nPos == 0
     	If lDieta
     	 aAdd(aRetCpo, {cCodigo, cDescricao, "2", "BR_VERDE", nVolume, cCodVia, cDesVia, cVelInf, cCdMinf, cDsMinf, cCdFrqa, cDsFrqa, cObserv})
      Else
       aAdd(aRetCpo, {cCodigo, cDescricao, "3", "BR_VERDE", cFreCui, cDesFre, cComple})
      Endif

      FS_AtuCDie(nPos, .T., oObj:aCols[oObj:oBrowse:nAt, nPosMark], aRetCpo, lDieta)
     Else
      FS_AtuCDie(nPos,, oObj:aCols[oObj:oBrowse:nAt, nPosMark], aRetCpo, lDieta)
     Endif

   Else
    oObj:aCols[oObj:oBrowse:nAt, nPosMark] := "LBNO"
    If nPos > 0
     aDel(aRetCpo, nPos)
     aSize(aRetCpo, Len(aRetCpo) - 1)
    Endif

    FS_AtuCDie(nPos, .T., oObj:aCols[oObj:oBrowse:nAt, nPosMark], aRetCpo, lDieta)

   Endif
  Else
   FS_AtuCDie(nPos, IIF(nPos > 0, .F., .T.), oObj:aCols[oObj:oBrowse:nAt, nPosMark], aRetCpo, lDieta)
  Endif
 Else
  FS_AtuCDie(nPos, .T., oObj:aCols[oObj:oBrowse:nAt, nPosMark], aRetCpo, lDieta)
 Endif

Return(NIL)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_ATUCDIE   ³ Autor ³ Mario Arizono    ³ Data ³16/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Funcao que atualiza campos da dieta.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_AtuCDie(nPos, lLimpa, cMarc, aRetCpo, lDieta)

 Default lLimpa := .F.

 If !lLimpa
  If lDieta
   nVolume := aRetCpo[nPos, 5]
   cCodVia := aRetCpo[nPos, 6]
   cDesVia := aRetCpo[nPos, 7]
   cVelInf := aRetCpo[nPos, 8]
   cCdMinf := aRetCpo[nPos, 9]
   cDsMinf := aRetCpo[nPos, 10]
   cCdFrqa := aRetCpo[nPos, 11]
   cDsFrqa := SUBSTR(aRetCpo[nPos, 12],1,30)
   cObserv := aRetCpo[nPos, 13]
  Else
   cFreCui := aRetCpo[nPos, 5]
   cDesFre := aRetCpo[nPos, 6]
   cComple := aRetCpo[nPos, 7]
  Endif
 Else
  If lDieta
   nVolume := 0
   cCodVia := SPACE(LEN(GGD->GGD_CODVIA))
   cCdFrqa := SPACE(LEN(GGB->GGB_CDFRQA))
   cObserv := SPACE(LEN(GDY->GDY_OBSERV))
   cVelInf := SPACE(LEN(GGD->GGD_VELINF))
   cCdMinf := SPACE(LEN(GGD->GGD_CDMINF))
   cDsMinf := SPACE(LEN(GFY->GFY_DSMINF))
   cDsFrqa := SPACE(30)
   cDesVia := SPACE(LEN(GFW->GFW_DESVIA))
  Else
   cFreCui := SPACE(LEN(GGB->GGB_CDFRQA))
   cDesFre := SPACE(30)
   cComple := SPACE(200)
  Endif
 Endif

 If cMarc == "LBNO"
  If lDieta
   oVolume:Disable()
   oVia:Disable()
   oVeloc:Disable()
   oInfus:Disable()
   oFrequ:Disable()
   oObserv:Disable()
  Else
   oFreCui:Disable()
   oDesFre:Disable()
   oComple:Disable()
  Endif
 Else
  If lDieta
   oVolume:Enable()
   oVia:Enable()
   oVeloc:Enable()
   oInfus:Enable()
   oFrequ:Enable()
   oObserv:Enable()
  Else
   oFreCui:Enable()
   oDesFre:Enable()
   oComple:Enable()
  Endif
 Endif

 If lDieta
  oVolume:Refresh()
  oVia:Refresh()
  oDesVia:Refresh()
  oVeloc:Refresh()
  oInfus:Refresh()
  oDsMinf:Refresh()
  oFrequ:Refresh()
  oDsFrqa:Refresh()
  oObserv:Refresh()
 Else
  oFreCui:Refresh()
  oDesFre:Refresh()
  oComple:Refresh()
 Endif
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_MNTCUIDA  ³ Autor ³ Mario Arizono    ³ Data ³16/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Funcao que monta acols dos cuidados utilizados na func.   ³±±
±±³          ³  HS_PREMED.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MntCuida()
 Local  aArea:= GetArea()

  HS_BDados("GNP",  @aHGNP,  @aCGNP,  @nUGNP,  1, ,"GNP->GNP_TPCUID = '0' AND GNP->GNP_IDEATI = '1'", , , "GNP_CODCUI/GNP_DESCUI", , , , "GNP_IDPADR","'LBNO'",.T., , , , , , ,)
  nGNPIdMark := aScan(aHGNP, {|aVet| AllTrim(aVet[2]) == "GNP_IDPADR"})
  nGNPCodCui := aScan(aHGNP, {|aVet| AllTrim(aVet[2]) == "GNP_CODCUI"})
  nGNPDesCui := aScan(aHGNP, {|aVet| AllTrim(aVet[2]) == "GNP_DESCUI"})

 RestArea(aArea)
Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_VLDCOD    ³ Autor ³ Mario Arizono    ³ Data ³16/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Funcao que valida digitacao do codigo na aba dieta.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_VldCod(cAlias, cCpo, uCodigo, cDescricao, cMsg, cCodPri, nColCod, nColDes, aRetCpo)
 Local lRet := .T.
 Local nPos := 0

 Default cAlias := ""

 nPos := aScan(aRetCpo, {| aVet | aVet[1] == cCodPri})

 If !Empty(uCodigo)
  If !Empty(cAlias)
   cDescricao := HS_INIPADR(cAlias, 1, uCodigo, cCpo,, .F. )
   If Empty(cDescricao)
    Hs_MsgInf(cMsg + STR0082, STR0059, STR0083) //"inválido."##"Validação lançamento itens."
    lRet := .F.
   Endif
   If lRet .And. nPos > 0
    aRetCpo[nPos, nColCod] := uCodigo
    aRetCpo[nPos, nColDes] := IIF(cAlias == "GFZ", SUBSTR(cDescricao, 1, 30), cDescricao)
   Endif
  Else
   If nPos > 0
    aRetCpo[nPos, nColCod] := uCodigo
   Endif
  Endif
 Endif

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_MNTMEDIC  ³ Autor ³ Mario Arizono    ³ Data ³19/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Funcao que monta acols medicamen. na funcao hs_premed.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_MntMedic(lMntMed, cProdut, lMosItem, nPos)
 Local     aJoin := "" , aCampos := {}
 Local     cSQL := ""
 Local     aArea:= GetArea()
 Local     nGBI := 0, nPosGbi:= 0

 If lMntMed
  //Medicamentos

  //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  //³ Montar o aHeader das despesas         ³
  //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

  aCampos := {"GGA_IDPADR","GGI_CDMEDI", "GGI_DESMED", "GGD_QTDILU", "GNL_IDREGI", "GNL_OBSREG", "GGA_APRESE", "GBI_FARMAC", "GA0_DESC"}
  aHPre   := FS_GerHead(aCampos, aHPre, .T.)
  nUPre   := len(aCampos)

  nPreCdMedi := aScan(aHPre, {|aVet| AllTrim(aVet[2]) == "GGI_CDMEDI"})
  nPreDesMed := aScan(aHPre, {|aVet| AllTrim(aVet[2]) == "GGI_DESMED"})
  nPreIdMark := aScan(aHPre, {|aVet| AllTrim(aVet[2]) == "GGA_IDPADR"})
  nPreIdRegi := aScan(aHPre, {|aVet| AllTrim(aVet[2]) == "GNL_IDREGI"})
  nPreObsReg := aScan(aHPre, {|aVet| AllTrim(aVet[2]) == "GNL_OBSREG"})
  nPreQtde   := aScan(aHPre, {|aVet| AllTrim(aVet[2]) == "GGD_QTDILU"})
  nPreAprese := aScan(aHPre, {|aVet| AllTrim(aVet[2]) == "GGA_APRESE"})

  cSQL  := "SELECT GBI_PRODUT, B1_DESC, GBI_FARMAC, GA0_DESC, GBI_CTRPSC "
  cSQL  += " FROM " + RetSQLName("GBI") + " GBI"
  cSQL  += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD  =  GBI.GBI_PRODUT  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
  cSQL  += " JOIN " + RetSqlName("GGA") + " GGA ON GGA.GGA_CDMEDI  =  GBI.GBI_PRODUT  AND GGA.GGA_FILIAL  = '" + xFilial("GGA") + "' AND GGA.D_E_L_E_T_ <> '*' "
  cSQL  += " JOIN " + RetSqlName("GGB") + " GGB ON GGB.GGB_CDMEDI  =  GBI.GBI_PRODUT  AND GGB.GGB_FILIAL  = '" + xFilial("GGB") + "' AND GGB.D_E_L_E_T_ <> '*' "
  cSQL  += " JOIN " + RetSqlName("GGW") + " GGW ON GGW.GGW_CDMEDI  =  GBI.GBI_PRODUT  AND GGW.GGW_FILIAL  = '" + xFilial("GGW") + "' AND GGW.D_E_L_E_T_ <> '*' "
  cSQL  += " LEFT JOIN " + RetSqlName("GA0") + " GA0 ON GA0.GA0_CODFAR  =  GBI.GBI_FARMAC AND GA0.GA0_FILIAL  = '" + xFilial("GA0") + "' AND GA0.D_E_L_E_T_ <> '*' "
  cSQL  += " WHERE GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_PRODES <> '0'"
  cSQL  += "GROUP BY GBI_PRODUT, B1_DESC, GBI_FARMAC, GA0_DESC, GBI_CTRPSC "

  TCQUERY cSQL NEW ALIAS "QRY"


  DbSelectArea("QRY")
  DbGoTop()

  While !Eof()
   aAdd(aCPre, {"LBNO", QRY->GBI_PRODUT, QRY->B1_DESC, 1, "0", SPACE(LEN(GNL->GNL_OBSREG)), "", QRY->GBI_FARMAC, QRY->GA0_DESC, .F.})
	If QRY->GBI_CTRPSC $ "0/1"
		aAdd(aMedCtrl,{QRY->GBI_PRODUT,QRY->GBI_CTRPSC})
	EndIf
   DbSkip()
  End

  dBCloseArea()
  RestArea(aArea)


 Endif

 cFilMarc :=  IIF(!lMntMed, IIF(lMosItem, IIF(!Empty(aRetPresc[nPos, 10]), "IIF(GGA_CDITEM = '" + aRetPresc[nPos, 10, 2] + "', 'LBTIK', 'LBNO')" , "'LBNO'"), "IIF(GGA_IDPADR = '1', 'LBTIK', 'LBNO')"), "'LBNO'")

 //APresentacoes
 aHGGA := {}
 aCGGA := {}
 nUGGA := 0
 aJoin := {{" LEFT JOIN " + RetSqlName("GGD") + " GGD", "GGD_APRESE", "GGD.GGD_FILIAL = '" + xFilial("GGD") + "' AND GGD.D_E_L_E_T_ <> '*' AND GGD.GGD_CDMEDI = GGA_CDDILU AND GGD.GGD_CDITEM = GGA_CDITED", "GGA_APRESD"}}
 aJoin := {{" LEFT JOIN " + RetSqlName("GFW") + " GFW", "GFW_DESVIA", "GFW.GFW_FILIAL = '" + xFilial("GFW") + "' AND GFW.D_E_L_E_T_ <> '*' AND GFW.GFW_CODVIA = GGA_CODVIA "                                , "GGA_DESVIA"}}
 HS_BDados("GGA", @aHGGA, @aCGGA, @nUGGA, 1,,"GGA->GGA_CDMEDI = '"+ cProdut + "'" ,,, "GGA_CDITEM/GGA_APRESE/GGA_APRESD/GGA_CODVIA/GGA_DESVIA",,,, "GGA_IDPADR", cFilMarc, .T.,,, .F., "GGA_CDMEDI, GGA_CDITEM, GGA_APRESE , GGD_APRESE GGA_APRESD, GGA_CODVIA, GFW_DESVIA GGA_DESVIA, GGA_IDPADR", "GGA_CDMEDI, GGA_CDITEM, GGA_APRESE, GGD_APRESE, GGA_CODVIA, GFW_DESVIA, GGA_IDPADR",, aJoin)

 If lMntMed
  nGGAIdMark := aScan(aHGGA, {|aVet| AllTrim(aVet[2]) == "GGA_IDPADR"})
  nGGACdItAp := aScan(aHGGA, {|aVet| AllTrim(aVet[2]) == "GGA_CDITEM"})
 Else
  If Len(aCGGA) == 1 .And. !Empty(aCGGA[1, nGGACdItAp]) .And. aCGGA[1, nGGAIdMark]  == "LBNO"
   aCGGA[1, nGGAIdMark] := "LBTIK"
  Endif
 Endif

 cFilMarc :=  IIF(!lMntMed, IIF(lMosItem, IIF(!Empty(aRetPresc[nPos, 11]), "IIF(GGB_CDITEM = '" + aRetPresc[nPos, 11, 2] + "', 'LBTIK', 'LBNO')", "'LBNO'") , "IIF(GGB_IDPADR = '1', 'LBTIK', 'LBNO')"), "'LBNO'")

 //Posologias
 aHGGB := {}
 aCGGB := {}
 nUGGB := 0
 aJoin := {{" JOIN " + RetSqlName("GFZ") + " GFZ", "GFZ_DSFRQA", "GFZ.GFZ_FILIAL = '" + xFilial("GFZ") + "' AND GFZ.D_E_L_E_T_ <> '*' AND GFZ.GFZ_CDFRQA = GGB.GGB_CDFRQA", "GGB_DSFRQA"}}
 HS_BDados("GGB", @aHGGB, @aCGGB, @nUGGB, 1,, "GGB->GGB_CDMEDI = '"+ cProdut + "'" ,,, "GGB_CDITEM/GGB_CDFRQA/GGB_DSFRQA",,,, "GGB_IDPADR", cFilMarc, .T.,,, .F., "GGB_CDMEDI, GGB_CDITEM, GGB_CDFRQA, GFZ_DSFRQA GGB_DSFRQA, GGB_IDPADR", "GGB_CDMEDI, GGB_CDITEM, GGB_CDFRQA, GFZ_DSFRQA, GGB_IDPADR",, aJoin)

 If lMntMed
  nGGBIdMark := aScan(aHGGB, {|aVet| AllTrim(aVet[2]) == "GGB_IDPADR"})
  nGGBCdItpo := aScan(aHGGB, {|aVet| AllTrim(aVet[2]) == "GGB_CDITEM"})
 Else
  If Len(aCGGB) == 1 .And. !Empty(aCGGB[1, nGGBCdItpo]) .And. aCGGB[1, nGGBIdMark]  == "LBNO"
   aCGGB[1, nGGBIdMark] := "LBTIK"
  Endif
 Endif

 cFilMarc :=  IIF(!lMntMed, IIF(lMosItem, IIF(!Empty(aRetPresc[nPos, 12]), "IIF(GGW_CDITEM = '" + aRetPresc[nPos, 12, 2] + "', 'LBTIK', 'LBNO')", "'LBNO'") , "IIF(GGW_IDPADR = '1', 'LBTIK', 'LBNO')"), "'LBNO'")

 //Unid. Consumo
 aHGGW := {}
 aCGGW := {}
 nUGGW := 0
 HS_BDados("GGW", @aHGGW, @aCGGW, @nUGGW, 1,, "GGW->GGW_CDMEDI = '"+ cProdut + "'" ,,, "GGW_CDITEM/GGW_UNICON/GGW_UMDRES",,,, "GGW_IDPADR",cFilMarc, .T.,,, .F., "GGW_CDMEDI, GGW_CDITEM, GGW_UNICON, GGW_UMDRES, GGW_IDPADR", "GGW_CDMEDI, GGW_CDITEM, GGW_UNICON, GGW_UMDRES, GGW_IDPADR",,)

 If lMntMed
  nGGWIdMark := aScan(aHGGW, {|aVet| AllTrim(aVet[2]) == "GGW_IDPADR"})
  nGGWCdItuc := aScan(aHGGW, {|aVet| AllTrim(aVet[2]) == "GGW_CDITEM"})
 Else
  If Len(aCGGW) == 1 .And. !Empty(aCGGW[1, nGGWCdItuc]) .And. aCGGW[1, nGGWIdMark]  == "LBNO"
   aCGGW[1, nGGWIdMark] := "LBTIK"
  Endif
 Endif

  aCampos := {"GBI_IDPADR","GBI_PRODUT", "GBI_DESC", "GGD_QTDILU", "GGW_UNICON", "GGW_UMDRES"}
  aHGbi   := FS_GerHead(aCampos, aHGbi)
  nUGbi   := len(aCampos)

  cSQL  := "SELECT GBI_PRODUT, B1_DESC "
  cSQL  += " FROM " + RetSQLName("GBI") + " GBI"
  cSQL  += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD  =  GBI.GBI_PRODUT  AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' "
  cSQL  += " WHERE GBI.GBI_FILIAL = '" + xFilial("GBI") + "' AND GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_COMPOS = '1' AND GBI.GBI_PRODUT <> '" + cProdut + "'"

  TCQUERY cSQL NEW ALIAS "QRY"

  DbSelectArea("QRY")
  DbGoTop()

  While !Eof()

   aAdd(aCGbi, {"LBNO", QRY->GBI_PRODUT, QRY->B1_DESC, 1, SPACE(LEN(GGW->GGW_UNICON)), SPACE(LEN(SAH->AH_UMRES)), .F.})

   DbSkip()
  End

  dBCloseArea()
  RestArea(aArea)


 If lMntMed
  nGBIIdMark := aScan(aHGBI, {|aVet| AllTrim(aVet[2]) == "GBI_IDPADR"})
  nGBIProdut := aScan(aHGBI, {|aVet| AllTrim(aVet[2]) == "GBI_PRODUT"})
  nGBIQtde   := aScan(aHGBI, {|aVet| AllTrim(aVet[2]) == "GGD_QTDILU"})
  nGBIUnicon := aScan(aHGBI, {|aVet| AllTrim(aVet[2]) == "GGW_UNICON"})
  nGBIUmdRes := aScan(aHGBI, {|aVet| AllTrim(aVet[2]) == "GGW_UMDRES"})
 Else
  If nPos > 0 .And. !Empty(aRetPresc[nPos, 13])
   For nGBI := 1 to len(aCGBI)

    If (nPosGbi := aScan(aRetPresc[nPos, 13], {| aVet | aVet[2] == aCGBI[nGBI, nGBIProdut]})) > 0
     aCGBI[nGBI, nGBIIdMark] := "LBTIK"
     aCGBI[nGBI, nGBIQtde]   := aRetPresc[nPos, 13, nPosGbi, 4]
     aCGBI[nGBI, nGBIUnicon] := aRetPresc[nPos, 13, nPosGbi, 5]
     aCGBI[nGBI, nGBIUmdRes] := aRetPresc[nPos, 13, nPosGbi, 6]
    Endif

   Next nGBI
  Endif
 Endif

 If !lMntMed
  oGGA:SetArray(aCGGA)
  oGGB:SetArray(aCGGB)
  oGGW:SetArray(aCGGW)
  oGBI:SetArray(aCGBI)
 Endif

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_LIMACOL   ³ Autor ³ Mario Arizono    ³ Data ³20/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Limpa acols dos itens da prescricao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Nil                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIMACOL()

 oGGA:aCols := {}
 oGGB:aCols := {}
 oGGW:aCols := {}
 oGBI:aCols := {}

 oGGA:Refresh()
 oGGB:Refresh()
 oGGW:Refresh()
 oGBI:Refresh()

Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GerHead  º Autor ³ Mario Arizono      º Data ³ 20/02/08    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que monta aHeader                                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GerHead(aCampos, aHeader, lProPri)
 Local nForCampos := 0

 Default lProPri := .F.

 DbSelectArea("SX3")
 DbSetOrder(2) // X3_CAMPO

 For nForCampos := 1 to len(aCampos)
   DbSeek(aCampos[nForCampos])
   aAdd(aHeader, { IIF (!(aCampos[nForCampos] $ "GGA_IDPADR/GBI_IDPADR"),TRIM(X3Titulo())," ")	, ;
                   SX3->X3_CAMPO   	, ;
                   IIF(aCampos[nForCampos] $ "GGA_IDPADR/GBI_IDPADR", "@BMP", SX3->X3_PICTURE) 	, ;
                   SX3->X3_TAMANHO 	, ;
                   SX3->X3_DECIMAL 	, ;
                   IIF(aCampos[nForCampos] == "GGD_QTDILU" .And. lProPri, "HS_MNTAPRE()", IIF(aCampos[nForCampos] $ "GGD_QTDILU/GGW_UNICON", "HS_PRECOMP()", SX3->X3_VALID))   	, ;
                   SX3->X3_USADO   	, ;
          		     SX3->X3_TIPO    	, ;
                   SX3->X3_F3      	, ;
          		     SX3->X3_CONTEXT 	, ;
                   SX3->X3_CBOX    	, ;
   		            SX3->X3_RELACAO 	, ;
                   SX3->X3_WHEN    	, ;
                   IIF(!(aCampos[nForCampos] $ "GBI_IDPADR/GGD_QTDILU/GNL_IDREGI/GNL_OBSREG/GGW_UNICON")	, "V", "A"), ;
                   SX3->X3_VLDUSER 	, ;
                   SX3->X3_PICTVAR 	, ;
                   .F. })

 Next nForCampos

Return(aHeader)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_MNTAPRE   ³ Autor ³ Mario Arizono    ³ Data ³21/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Monta apresentacao do grid principal de itens             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Nil                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_MNTAPRE(lclick)
 Local cGBIApres := "", cApresen := "", cUnidCons := "", cCodFora := "", cCodVia := "", cObservac := ""
 Local nPos := 0, nQtdidade := 0
 Local aArea := GetArea()

 Default lClick := .F.

 If (!lClick  .And. oPre:aCols[oPre:oBrowse:nAt, nPreIdmark] == "LBTIK") .Or. lClick
  cGbiAPres := ALLTRIM(HS_INIPADR("GBI", 1, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi], "GBI_APRES",,.F.))

  nPos := aScan(aRetPresc, {| aVet | aVet[1] == oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]})

  If nPos > 0 .And. !Empty(aRetPresc[nPos, 10])
   If !Empty(cGBIApres)
    If cGbiAPres == SUBSTR(aRetPresc[nPos,10,3],1, len(cGbiApres))
     cGbiAPres := SUBSTR(aRetPresc[nPos,10,3],1, len(cGbiApres)) + " "
    Else
     cGbiAPres := ""
    Endif
   Endif

   nQtdidade := IIF(readvar() == "M->GGD_QTDILU", M->GGD_QTDILU, oPre:aCols[oPre:oBrowse:nAt, nPreQtde])
   cCodVia   := IIF(!Empty(aRetPresc[nPos, 10]), ALLTRIM(HS_INIPADR("GGA", 1, oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi] + aRetPresc[nPos, 10, 2], "GGA_CODVIA",,.F.)) + " ", "")
   cObservac := IIF(!Empty(aRetPresc[nPos, 10]), ALLTRIM(GGA->GGA_OBSERV)+ " ", "")
   cCodFora  := IIF(!Empty(aRetPresc[nPos, 10]), ALLTRIM(GGA->GGA_CDFORA)+ " ", "")
   cUnidCons := IIF(!Empty(aRetPresc[nPos, 12]), ALLTRIM(aRetPresc[nPos, 12,3]) + " ", "")


   cApresen  := cGbiAPres + SUBSTR(ALLTRIM(Transform(nQtdidade, "@E 99999.9999")),1,len(ALLTRIM(STR(nQtdidade)))) + " " + cUnidCons +  cCodVia + cCodFora + cObservac

   oPre:aCols[oPre:oBrowse:nAt, nPreAprese] := cApresen
   aRetPresc[nPos, 5]  := cApresen
   aRetPresc[nPos, 14] := nQtdidade
  Endif
 Endif
 RestArea(aArea)
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_VLDPRES() ³ Autor ³ Mario Arizono    ³ Data ³22/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida campos da consulta que nao estao marcados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLDPRES(oObj)
 Local lRet   := .T.
 Local nPos   := 0, nPosPres := 0
 Local cProdut:= "", cComp := "", cMsgCom := ""

 For nPos := 1 to len(aRetPresc)

  If Empty(aRetPresc[nPos, 10]) .Or. Empty(aRetPresc[nPos, 11]) .Or. Empty(aRetPresc[nPos, 12])
   cProdut += IIF(Empty(cProdut), "", ", ") + ALLTRIM(aRetPresc[nPos, 1])
  Else
   If (nPosPresc := aScan(oObj:aCols, {| aVet | aVet[2] == aRetPresc[nPos,1]})) > 0
    aRetPresc[nPos, 7] := oObj:aCols[nPosPresc, nPreIdRegi]
    aRetPresc[nPos, 8] := oObj:aCols[nPosPresc, nPreObsReg]
   Endif
  Endif
  cComp := Fs_VldComp(aRetPresc[nPos, 13])
  If !Empty(cComp)
   cMsgCom += STR0084 + ALLTRIM(aRetPresc[nPos, 1]) + STR0085 + cComp + STR0086 + CHR(13) + CHR(10)  //"O Medicamento ["##"], possui o(s) medicamento(s) composto(s) ["##"] sem unidade de consumo preenchida(s)."
  Endif
 Next nPos

 If !Empty(cProdut)
  HS_MsgInf(STR0065 + cProdut + STR0066, STR0059, STR0060)//"O(s) medicamento(s) [ "##" ] possuem itens desmarcados em suas respectivas abas. Por favor verifique."##"Atenção"##"Validação dos itens consultados para prescrição."
  lRet := .F.
 ElseIf !Empty(cMsgCom)
  HS_MsgInf(cMsgCom, STR0059, STR0060)
  lRet := .F.
 Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_GRVPRE    ³ Autor ³ Mario Arizono    ³ Data ³22/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Grava itens montados na tabela GHX.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRVPRE(oObjPre, nPosApre, nTamCpo, nMedican, nCdItpo, nVolume, nCodVia, nVelInf, nCdMinf, nCdFrqa, nObsreg)
 Local nPosPres := 0, nPos := 0, nPosDes := 1, nPosCom := 0
 Local cMedican := "", cPosComp := "", cDieta := "", cCuidad := "", cMsg := ""
 Local lAItCompo := Type("__aItCompo") # "U"
  If Type("__aItDieta") # "U" .And. !Empty(aRetDiet)
   For nPos := 1 to len(aRetDiet)
    If (aScan(oObjPre:aCols, {| aVet | aVet[nMedican] == aRetDiet[nPos, 1] .And.  aVet[nVolume] == aRetDiet[nPos, 5] .And. ;
                                        aVet[nCodVia] == aRetDiet[nPos, 6] .And.  aVet[nVelInf] == aRetDiet[nPos, 8] .And. ;
                                        aVet[nCdMinf] == aRetDiet[nPos, 9] .And.  aVet[nCdFrqa] == aRetDiet[nPos, 11] .And. ;
                                        aVet[nObsreg] == aRetDiet[nPos, 13] .And. !aVet[len(aVet)]})) == 0

     If (len(oObjPre:aCols) == 1 .And. !Empty(oObjPre:aCols[1, nMedican])) .Or. len(oObjPre:aCols) > 1
      oObjPre:AddLine(.F., .F.)
      oObjPre:lNewLine := .F.
      nPosDes := Len(oObjPre:aCols)
     EndIf

     oObjPre:nAt := nPosDes

     For nPosPres := 1 To Len(__aItDieta)
	  	  &(__aItDieta[nPosPres, 1]) := HS_RetVal(aRetDiet, StrZero(nPos, 2)+ "," + __aItDieta[nPosPres, 2])
  	  Next

    Else
     cDieta += IIF(Empty(cDieta), "", ", ") + ALLTRIM(aRetDiet[nPos, 1])
    Endif

   Next nPos
  Endif


  If Type("__aItPresc") # "U"
   For nPos := 1 to len(aRetPresc)
    If (aScan(oObjPre:aCols, {| aVet | aVet[nMedican] == aRetPresc[nPos, 1] .And.  aVet[nCdItpo] == aRetPresc[nPos, 11, 2] .And. ;
                                        PADR(aVet[nPosApre], nTamCpo) == PadR(aRetPresc[nPos, 5], nTamCpo) .And. !aVet[len(aVet)]})) == 0
     If (len(oObjPre:aCols) == 1 .And. !Empty(oObjPre:aCols[1, nMedican])) .Or. len(oObjPre:aCols) > 1
      oObjPre:AddLine(.F., .F.)
      oObjPre:lNewLine := .F.
      nPosDes := Len(oObjPre:aCols)
     EndIf

     oObjPre:nAt := nPosDes

     For nPosPres := 1 To Len(__aItPresc)
	  	  &(__aItPresc[nPosPres, 1]) := HS_RetVal(aRetPresc, StrZero(nPos, 2)+ "," + __aItPresc[nPosPres, 2])
  	  Next

     If lAItCompo
      If !Empty(aRetPresc[nPos, 13])
       For nPosCom := 1 to len(aRetPresc[nPos, 13])
        oObjPre:AddLine(.F., .F.)
        oObjPre:lNewLine := .F.
        nPosDes := Len(oObjPre:aCols)

        oObjPre:nAt := nPosDes


        aRetPresc[nPos, 13, nPosCom, 9] := ALLTRIM(STR(aRetPresc[nPos, 13, nPosCom, 4])) + " " + aRetPresc[nPos, 13, nPosCom, 6]

        For nPosPres := 1 To Len(__aItCompo)
         If len(__aItCompo[nPosPres, 2]) > 2
          cPosComp := SUBSTR(__aItCompo[nPosPres, 2],1,2) + "," + StrZero(nPosCom, 2) + "," + SUBSTR(__aItCompo[nPosPres, 2],5,2)
         Endif
	  	     &(__aItCompo[nPosPres, 1]) := HS_RetVal(aRetPresc, StrZero(nPos, 2)+ "," + IIF(Empty(cPosComp), __aItCompo[nPosPres, 2], cPosComp))
  	      cPosComp := ""
  	     Next

       Next nPosCom
      Endif
     Endif
    Else
     cMedican += IIF(Empty(cMedican), "", ", ") + ALLTRIM(aRetPresc[nPos, 1])
    Endif

   Next nPos
  Endif


  If Type("__aItCuida") # "U"  .And. !Empty(aRetCuid)
   For nPos := 1 to len(aRetCuid)
    If (aScan(oObjPre:aCols, {| aVet | aVet[nMedican] == aRetCuid[nPos, 1] .And.  aVet[nCdFrqa] == aRetCuid[nPos, 5] .And. ;
                                        aVet[nObsReg] == aRetCuid[nPos, 7] .And. !aVet[len(aVet)]})) == 0
     If (len(oObjPre:aCols) == 1 .And. !Empty(oObjPre:aCols[1, nMedican])) .Or. len(oObjPre:aCols) > 1
      oObjPre:AddLine(.F., .F.)
      oObjPre:lNewLine := .F.
      nPosDes := Len(oObjPre:aCols)
     EndIf

     oObjPre:nAt := nPosDes

     For nPosPres := 1 To Len(__aItCuida)
	  	  &(__aItCuida[nPosPres, 1]) := HS_RetVal(aRetCuid, StrZero(nPos, 2)+ "," + __aItCuida[nPosPres, 2])
  	  Next

    Else
     cCuidad += IIF(Empty(cCuidad), "", ", ") + ALLTRIM(aRetCuid[nPos, 1])
    Endif

   Next nPos
  Endif

   cMsg := IIF(!Empty(cDieta), STR0087 + cDieta + STR0067 + CHR(13)+CHR(10), "") + IIF(!Empty(cMedican), STR0065 +; //"A(s) dieta(s) ["
               cMedican + STR0067 + CHR(13)+CHR(10), "") + IIF(!Empty(cCuidad), STR0088 + cCuidad + STR0067 + CHR(13)+CHR(10), "") //"O(s) cuidado(s) ["
   If !Empty(cMsg)
    HS_MsgInf(cMsg, STR0059, STR0060)//"O(s) medicamento(s) [ "##" ] já foram lançados na prescrição posicionada."##"Atenção"##"Validação dos itens consultados para prescrição."
   Endif


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_PRECOMP() ³ Autor ³ Mario Arizono    ³ Data ³25/04/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida campos da aba composto e preenche vetor correspond. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  .T. OU .F.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_PRECOMP()
Local lRet   := .T.
Local nPos   := 0, nPosPres := 0
Local cProdut:= ""

nPos     := aScan(aRetPresc, {| aVet | aVet[1] == oPre:aCols[oPre:oBrowse:nAt, nPreCdMedi]})
If nPos > 0
	nPosPres := aScan(aRetPresc[nPos, 13], {| aVet | aVet[2] == oGbi:aCols[oGbi:oBrowse:nAt, nGBIProdut]})
	If nPosPres <= 0
		Return(.F.)
	EndIf
Else
	Return(.F.)
EndIf

If readvar() == "M->GGD_QTDILU"
	aRetPresc[nPos, 13, nPosPres, 4] := M->GGD_QTDILU
Else
	If !HS_SeekRet("SAH", "M->GGW_UNICON", 1, .F., "GGW_UMDRES", "AH_UMRES",,, .T.)
		HS_MsgInf(STR0089, STR0059, STR0090) //"O campo 'Unidade de Consumo' não possui vinculo com a tabela SAH. Utilize F3 para selecionar um valor adequado."##"Validação unidade consumo."
		lRet := .F.
	Else
		If nPosPres > 0
			aRetPresc[nPos, 13, nPosPres, 5] := M->GGW_UNICON
			aRetPresc[nPos, 13, nPosPres, 6] := SAH->AH_UMRES
		Endif
	EndIf
Endif

Return(lRet)

Static Function FS_VldComp(aCols)
 Local nPos := 0
 Local cComp := ""

 For nPos := 1 to len(aCols)
  If aCols[nPos, 1] == "LBTIK" .And. Empty(aCols[nPos, 5])
   cComp += IIF(Empty(cComp), "", ", ") + ALLTRIM(aCols[nPos, 2])
  Endif

 Next nPos

Return(cComp)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_GGD002    ³ Autor ³ Mario Arizono    ³ Data ³31/05/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Mat/Med x Diluente da consulta GGD002.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_GGD002()
 Local	cRetSql := "@GGD_FILIAL = '" + xFilial("GGD") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGGDCdDilu") # "U" .And. !Empty(cGGDCdDilu)
  cRetSql += " AND GGD_CDMEDI = '" + cGGDCdDilu + "' "
 EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FGBJ      ³ Autor ³ Bruno Santos     ³ Data ³25/06/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtro do Tipo Profissional da Consulta padrão GBJ.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FGbj()
 Local cRetSql := "@GBJ_FILIAL = '" + xFilial("GBJ") + "' AND D_E_L_E_T_ <> '*'"

 cRetSql +=" AND   GBJ_STATUS = '1'"
 If Type("cGBJTipPro") # "U" .And. !Empty(cGBJTipPro)
  cRetSql += " AND GBJ_TIPPRO = '" + cGBJTipPro + "'"
 EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_FilAcesºAutor  ³Patricia Queiroz    º Data ³  18/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtro para consulta padrão HSP006. Apresentar somente as fiº±±
±±º          ³liais que o usuario possui acesso.                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Consulta Padrao GAT001                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_FilAces()
 Local lRet := .T.
 Local cFilAces := ""
 Local nForFil  := 0
 Local lFWCodFil := FindFunction("FWCodFil")

 For nForFil := 1 To Len(PSWRET(2)[1][6])
  cFilAces += SubStr(PSWRET(2)[1][6][nForFil], 3,  FWSizeFilial()) + IIF(nForFil < Len(PSWRET(2)[1][6]), "/", "")
 Next

 If At("@", cFilAces) == 0
  lRet := IiF(lFWCodFil ,FWCodFil(), SM0->M0_CODFIL) $ cFilAces
 EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FGBJ      ³ Autor ³ Sueli Santos     ³ Data ³04/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtro do Tipo Profissional da Consulta padrão GBJ.       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilMed()
 Local cRetSql := "@GBJ_FILIAL = '" + xFilial("GBJ") + "' AND D_E_L_E_T_ <> '*'"

 cRetSql +=" AND   GBJ_STATUS = '1'"
 If Type("cGBJTipAut") # "U" .And. !Empty(cGBJTipAut)
  cRetSql += " AND GBJ_TIPPRO = '" + cGBJTipAut + "'"
 EndIf

Return(cRetSql)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ConLoteºAutor  ³Patricia Queiroz    º Data ³  19/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtro para consulta padrão GAT.                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Consulta Padrao GAT001                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_ConLote()
 Local aHGAT := {}, aCGAT := {}
 Local oGAT, oGDPESQ
 Local nGATNUMLOT := 0, nGATFILIAL := 0, nOpcA := 1
 Local cCond := HS_FilLote(FunName())
 cCond := StrTran(cCond, "@D_E_L_E_T_ <> '*'  AND ","")
 cCond := StrTran(cCond, "GAT_", "GAT.GAT_")

 DbSelectArea("GAT")
 DbSetOrder(1) // GAT_FILIAL + GAT_NUMLOT

 HS_BDados("GAT", @aHGAT, @aCGAT,, 1, .F., cCond,,, "GAT_FILIAL")
 nGATNUMLOT := aScan(aHGAT, {| aVet | aVet[2] == "GAT_NUMLOT"})
 nGATFILIAL := aScan(aHGAT, {| aVet | aVet[2] == "GAT_FILIAL"})

 DEFINE MSDIALOG oDlgLot TITLE OemToAnsi(STR0034) From 500, 300 To 900, 710 	PIXEL Of oMainWnd     //"Lotes"


  oGAT := MsNewGetDados():New(200, 300, 200, 300,,,,,,,,,,,, aHGAT, aCGAT)
  oGAT:oBrowse:Align      := CONTROL_ALIGN_ALLCLIENT
  oGAT:oBrowse:BlDblClick := {|| FS_DbClkCL(oGAT:aCols[oGAT:oBrowse:nAt, nGATFILIAL], oGAT:aCols[oGAT:oBrowse:nAt, nGATNUMLOT])}

  oGDPesq	:=	TPanel():New(800, 035,, oDlgLot,,,,,, 800, 035)
  oGDPesq:Align := CONTROL_ALIGN_BOTTOM

  HS_GDPesqu( , , oGAT, oGDPesq, 002)

 ACTIVATE MSDIALOG oDlgLot ON INIT EnchoiceBar(oDlgLot, {|| FS_DbClkCL(oGAT:aCols[oGAT:oBrowse:nAt, nGATFILIAL], oGAT:aCols[oGAT:oBrowse:nAt, nGATNUMLOT])}, ;
                                                        {|| nOpcA := 0, oDlgLot:End()})

Return(nOpcA == 1)

Static Function FS_DbClkCL(cFilLote, cLote)

  DbSeek(cFilLote + cLote)
  oDlgLot:End()

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_SX1M29 ºAutor  ³Mario Arizono       º Data ³  10/07/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta para escolha do filtro para exibir registros       º±±
±±º          ³agendados.                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_SX1M29()
 Local lRet    := .F.
 Local nUsado  := 0,  nOpcA    := 0, nSX3Campo := 0
 Local aColM29 := {}, aHeadM29 := {}
 Local oDlgCons, oGetCons

	nUsado := 0
	Aadd(aHeadM29, {STR0035          , "cOrdem"   , "@!", 003, 0,,, "C",, "V",,,,"V"})  //"Ordem"
 Aadd(aHeadM29, {STR0036          , "cStatus"    , "@!", 020, 0,,, "C",, "V",,,,"V"})//"Status"


	aAdd(aColM29, {"1", STR0037, .F. })//"Agendados"
	aAdd(aColM29, {"2", STR0038, .F. })//"Cancelados"
	aAdd(aColM29, {"3", STR0039, .F. })//"Transferidos"
	aAdd(aColM29, {"4", STR0040, .F. })//"Faltosos"
	aAdd(aColM29, {"5", STR0041, .F. })//"Livres"
	aAdd(aColM29, {"6", STR0042, .F. })//"Bloqueados"
	aAdd(aColM29, {"7", STR0043, .F. })//"Atendidos"
	aAdd(aColM29, {"8", STR0044, .F. })//"Ocupados/Bloqueados"
	aAdd(aColM29, {"9", STR0045, .F. })//"Confirmados"

 Define MsDialog oDlgCons Title OemToAnsi(STR0046) From 000, 000 To 500, 850 Of oMainWnd PIXEL  //"Consulta Horários"

  oGetCons := MsNewGetDados():New(000, 000, 500, 850, 0,,,,,, 99999,,,, oDlgCons, aHeadM29, aColM29)
  oGetCons:oBrowse:align := CONTROL_ALIGN_ALLCLIENT

 Activate MsDialog oDlgCons Centered ON INIT EnchoiceBar (oDlgCons, {	|| nOpcA := 1, oDlgCons:End()},	{|| nOpcA := 0, oDlgCons:End()} )

 If nOpcA == 1
  __cRetOpc := oGetCons:aCols[oGetCons:nAt, 1]
  lRet := .T.
 EndIf

Return(lRet)

Function HS_RETM29()
 &(Readvar()) := __cRetOpc
Return(.T.)

Function HS_SX1M04()
 Local lRet    := .F.
 Local nUsado  := 0,  nOpcA    := 0, nSX3Campo := 0
 Local aColM04 := {}, aHeadM04 := {}
 Local oDlgCons, oGetCons
 Local cFiltro := " GAV_STATUS = '1'"
	Local aCposIni    := {"GAV_REGATE","GAV_NOME","GAV_CODLOC","GAV_QUARTO","GAV_LEITO","GAV_RESERV"}

	HS_BDados("GAV", @aHeadM04, @aColM04, @nUsado, 1,, cFiltro,,,"/",,,,,,.T.,,,,,, aCposIni)


 Define MsDialog oDlgCons Title OemToAnsi(STR0047) From 000, 000 To 500, 660 Of oMainWnd PIXEL  //"Consulta Horários"

  oPPesq	:=	tPanel():New(045, 000,, oDlgCons,,,,,, 045, 600)
  oPPesq:Align := CONTROL_ALIGN_ALLCLIENT    

  oGetCons := MsNewGetDados():New(070, 005, 245, 330, 0,,,,,, 99999,,,, oDlgCons, aHeadM04, aColM04)
  //oGetCons:oBrowse:align := CONTROL_ALIGN_BOTTOM

  HS_GDPesqu( , , oGetCons, oPPesq, 002)

 Activate MsDialog oDlgCons Centered ON INIT EnchoiceBar (oDlgCons, {	|| nOpcA := 1, oDlgCons:End()},	{|| nOpcA := 0, oDlgCons:End()} )

 If nOpcA == 1
  __cRetOpc := oGetCons:aCols[oGetCons:nAt, 1]
  lRet := .T.
  If Type("__cReservGAV") # "U"
   __cReservGAV :=  oGetCons:aCols[oGetCons:nAt, aScan(aHeadM04, {| aVet | aVet[2] == "GAV_RESERV"})]
  EndIf
 EndIf

Return(lRet)

Function HS_RETM04()
 &(Readvar()) := __cRetOpc
Return(.T.)

Function HS_P18TLot()

 Local lRet := .F.
 Local oLbx := Nil
 Local nPos := 1, nOpcA := 0
 Local aLbx := {{STR0048},{STR0049},{STR0050},{STR0051},{STR0052},{STR0053},{STR0054},{STR0068}} //"0=Plano"###"1=Amb.-Consulta Eletiva"###"2=Amb.-Exame Eletivo"###"3=Amb.-Geral"###"4=Pronto Atend."###"5=Amb.+Pronto Atend."###"6=Internacao"###"8=Todos"

 Define MsDialog oDlgCons Title OemToAnsi(STR0055) From 000, 000 To 300, 500 Of oMainWnd PIXEL  //"Tipos de Lote"

  @ 012, 012 LISTBOX oLbx VAR cLbx FIELDS HEADER OemtoAnsi(STR0056)	COLSIZES 200 SIZE 100, 100 OF oDlgCons PIXEL ON DBLCLICK (nOpcA := 1, nPos := oLbx:nAt, oDlgCons:End()) //"Tipo Regra"
  oLbx:Align := CONTROL_ALIGN_ALLCLIENT
  oLbx:SetArray(aLbx)
  oLbx:bLine:={||{aLbx[oLbx:nAt, 1]}}

 Activate MsDialog oDlgCons Centered ON INIT EnchoiceBar (oDlgCons, {	|| nOpcA := 1, nPos := oLbx:nAt, oDlgCons:End()},	{|| nOpcA := 0, oDlgCons:End()} )

 If nOpcA == 1
 	If nPos = 8
 		__cRetOpc := AllTrim(Str(nPos))
 	Else
  		__cRetOpc := AllTrim(Str(nPos - 1))
  	EndIf
  	lRet := .T.
 EndIf

Return(lRet)

Function HS_P18RLot()
 &(Readvar()) := __cRetOpc
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilGGW    ³ Autor ³ Daniel Peixoto   ³ Data ³15/02/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Mat/Med x Unidade Consumo                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Verdadeiro ou Falso                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGGW()
 Local	cRetSql := "@GGW_FILIAL = '" + xFilial("GGW") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cGGWCdMedi") # "U" .And. !Empty(cGGWCdMedi)
  cRetSql += " AND GGW_CDMEDI = '" + cGGWCdMedi + "' "
 EndIf

Return(cRetSql)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	   ³HS_FilGA1 ³ Autor ³ Saude                 ³ Data ³ 01/09/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ºDescricao ³ Filtra Proced. Padrao                                      º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilGA1()
Local	cRetSql := "@GA1_FILIAL = '" + xFilial("GA1") + "' AND D_E_L_E_T_ <> '*' "
Local  nCont := 0, nTab := 0, nPos := 0
Local  aTabs := {"PR", "TD"}
Local  oObj

If Type("cGA1CodPct") # "U"
 cGA1CodPct := SPACE(LEN(GA1->GA1_CODPCT))
	For nTab := 1 To Len(aTabs)
  If ValType(oObj := &("oGD" + aTabs[nTab])) <> "U" .And. (nPos := &("n" + aTabs[nTab] + "CodPct")) > 0
 For nCont := 1 To Len(oObj:aCols)
    If !oObj:aCols[nCont, Len(oObj:aHeader)+1] .And. !Empty(oObj:aCols[nCont, nPos]) .And. AT(oObj:aCols[nCont, nPos], cGA1CodPct) == 0
   cGA1CodPct += IIF(!Empty(cGA1CodPct), "/", "") + oObj:aCols[nCont, nPos]
  EndIf
 Next
  EndIf
 Next

	cRetSql += " AND GA1_CODPCT IN (" + HS_InSql(cGA1CodPct, TamSx3("GD7_CODPCT")[1]) + ") "
EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilGCY    ³ Autor ³ Bruno Santos     ³ Data ³22/08/2008³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Atendimento                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Retorna Filtro GCY                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGCY()
 Local	cRetSql := "@GCY_FILIAL = '" + xFilial("GCY") + "' AND D_E_L_E_T_ <> '*' "

 If Type("__cAtendi") # "U" .And. !Empty(__cAtendi)
  cRetSql += " AND GCY_ATENDI = '" + __cAtendi + "' "
 EndIf

 If Type("__cCodLoc") # "U" .And. !Empty(__cCodLoc)
  cRetSql += " AND GCY_CODLOC = '" + __cCodLoc + "' "
 EndIf

 If Type("__cLocAte") # "U" .And. !Empty(__cLocAte)
  cRetSql += " AND GCY_LOCATE = '" + __cLocAte + "' "
 EndIf

 If Type("__cProntu") # "U" .And. !Empty(__cProntu)
  cRetSql += " AND GCY_REGGER = '" + __cProntu + "' "
 EndIf

 If Type("__cGStatus") # "U" .And. !Empty(__cGStatus)
  cRetSql += " AND GCY_REGATE IN (SELECT GCZ_REGATE "
  cRetSql += "                      FROM "+RetSqlName("GCZ")
  cRetSql += "                     WHERE GCZ_FILIAL = '"+xFilial("GCZ")+"'"
  cRetSql += "                       AND D_E_L_E_T_ <> '*' "
  cRetSql += "                       AND GCZ_STATUS = '"+__cGStatus+"')"
 EndIf

Return(cRetSql)

Function Hs_FilRec(cAlias)
 Local	cRetSql := "@"+cAlias+"_FILIAL = '" + xFilial(cAlias) + "' AND D_E_L_E_T_ <> '*' "

 If Type("__cCodDis") # "U" .And. !Empty(__cCodDis)
  cRetSql += " AND "+cAlias+"_CODDIS = '"+__cCodDis+"'"
 EndIf

 If Type("__cCodSal") # "U" .And. !Empty(__cCodSal)
  cRetSql += " AND "+cAlias+"_CODSAL = '"+__cCodSal+"'"
 EndIf

Return(cRetSql)

Function HS_FilGAS()
 Local	cRetSql := "@GAS_FILIAL = '" + xFilial("GAS") + "' AND D_E_L_E_T_ <> '*' "

 If Type("cCodProSus") # "U" .And. !Empty(cCodProSus)
  cRetSql += " AND GAS_CODIGO IN (SELECT GHH_CODCID "+;
             "                      FROM "+RetSqlName("GHH")+" GHH "+;
             "                     WHERE GHH.GHH_FILIAL = '"+xFilial("GHH")+"' AND GHH.D_E_L_E_T_ <> '*' "+;
             "                       AND GHH.GHH_CODPRO = '"+cCodProSus+"') "
 EndIf

Return(cRetSql)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_F3Ga7  ºAutor  ³Darcio Sporl        º Data ³  09/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao desenvolvida, para criar o F3 de procedimento, no    º±±
±±º          ³agendamento de internacao.                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_F3Ga7()
Local cSqlRet	:= ""
Local aProc		:= {}		// Vetor utilizado para trazer os procedimentos
Local nOpcI		:= 2
Local lMark		:= .F.
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local cTitulo	:= "Consulta Procedimentos"
Local nRecno	:= 0
Local aOrd		:= {'Código', 'Descrição'}
Local cCombo	:= aOrd[1]
Local cCond		:= Space(40)
Local oButton
Local oCombo
Local oCond

cSqlRet := "SELECT GA7.GA7_CODPRO, GA7.GA7_DESC, GA7.R_E_C_N_O_ REGPOS FROM " + RetSqlName("GA7") + " GA7"
cSqlRet += " WHERE GA7_FILIAL = '" + xFilial("GA7") + "' AND D_E_L_E_T_ <> '*'"

If Type("cGcuCodTpg") # "U" .And. cGcuCodTpg <> Nil
	// Verifica se o procedimento é permitido na guia selecionada
	cSqlRet += " AND GA7_CODPRO IN (SELECT GCX_CODPRO FROM " + RetSqlName("GCX") + " GCX"
	cSqlRet += " 					WHERE GCX.GCX_CODTPG = '" + cGcuCodTpg + "'"
	cSqlRet += " 					  AND GCX.GCX_CODPRO = GA7_CODPRO"
	cSqlRet += " 					  AND GCX.GCX_FILIAL = '" + xFilial("GCX") + "' AND GCX.D_E_L_E_T_ <> '*')"
Endif

If Type("cGcsCodLoc") # "U" .And. cGcsCodLoc <> Nil
	// Verifica se o procedimento é permitido no setor
	cSqlRet += " AND GA7_CODPRO IN (SELECT GM2_CODPRO FROM " + RetSqlName("GM2") + " GM2"
	cSqlRet += " 					WHERE GM2.GM2_CODLOC = '" + cGcsCodLoc + "'"
	cSqlRet += " 					  AND GM2.GM2_CODPRO = GA7_CODPRO"
	cSqlRet += " 					  AND GM2.GM2_FILIAL = '" + xFilial("GM2") + "' AND GM2.D_E_L_E_T_ <> '*')"
Endif

If Type("cGczCodPla") # "U" .And. cGczCodPla <> Nil
	// Verifica se o procedimento esta contido nas tabelas do convenio
	cSqlRet += " AND GA7_CODPRO IN (SELECT GA8_CODPRO FROM " + RetSqlName("GA8") + " GA8, " + RetSqlName("GC6") + " GC6"
	cSqlRet += " 					WHERE GA8.GA8_TABPRO = GC6.GC6_TABPRO"
	cSqlRet += " 					  AND GC6.GC6_CODPLA = '" + cGczCodPla + "'"
	cSqlRet += " 					  AND GC6.GC6_FILIAL = '" + xFilial("GC6") + "' AND GC6.D_E_L_E_T_ <> '*'"
	cSqlRet += " 					  AND GA8.GA8_FILIAL = '" + xFilial("GA8") + "' AND GA8.D_E_L_E_T_ <> '*')"
Endif

If Type("cGa7TipPro") # "U" .And. cGa7TipPro <> Nil
	// filtra o tipo dos procedimentos
	cSqlRet += " AND GA7_TIPPRO NOT IN (" + HS_InSql(cGa7TipPro) + ") "
Endif

If Type("M->GM8_CODSAL") # "U" .And. !Empty(M->GM8_CODSAL)
	// Verifica se o procedimento pode ser realizado na sala
	cSqlRet += " AND GA7_CODPRO IN (SELECT GNC_CODPRO FROM " + RetSqlName("GNC") + " GNC "
	cSqlRet += " 					WHERE GNC.GNC_CODSAL = '" + M->GM8_CODSAL + "'"
	cSqlRet += "   					  AND GNC.GNC_FILIAL = '" + xFilial("GNC") + "' AND GNC.D_E_L_E_T_ <> '*')"
Endif

If Type("cSusProIns") # "U" .And. cSusProIns <> Nil
	// Verifica se o procedimento é permitido no setor
	cSqlRet += " AND GA7_CODPRO IN (SELECT GK6_CODPRO "
	cSqlRet += "                      FROM " + RetSqlName("GK6") + " GK6 "
	cSqlRet += "                     WHERE GK6.GK6_CODINR IN (" + HS_InSql(cSusProIns, 2) + ") "
	cSqlRet += "                       AND GK6.GK6_CODPRO = GA7_CODPRO "
	cSqlRet += "                       AND GK6.GK6_FILIAL = '" + xFilial("GK6") + "' "
	cSqlRet += "                       AND GK6.D_E_L_E_T_ <> '*')"
Endif

cSqlRet += " ORDER BY GA7_CODPRO "

cSqlRet := ChangeQuery(cSqlRet)
TCQUERY cSqlRet NEW ALIAS "GA7PRO"

DbSelectArea("GA7PRO")

If GA7PRO->(!Eof())
	GA7PRO->(DbGoTop())
	While GA7PRO->(!Eof())
		Aadd( aProc, 	{lMark, ;
						 GA7PRO->GA7_CODPRO,;
						 GA7PRO->GA7_DESC,;
						 GA7PRO->REGPOS})
		GA7PRO->(DbSkip())
	End
	//+-----------------------------------------------+
	//| Monta a tela para usuario visualizar consulta |
	//+-----------------------------------------------+
	If Len( aProc ) == 0
		Aviso( cTitulo, "Não existem procedimentos a consultar", {"Ok"} )
		Return(.F.)
	Endif

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 320,500 PIXEL

	oCombo 	:= tComboBox():New(10, 10, {|x| If(PCount() > 0, cCombo := x, cCombo)}, aOrd, 100, 20, oDlg, , {|| HS_MudaOrd(cCombo, @aProc, @oLbx)},,,,.T.,,,,,,,,,'cCombo')
	@ 25, 10 MSGET oCond VAR cCond PICTURE "@!" SIZE 180, 10 VALID .T. OF oDlg PIXEL
	oButton := tButton():New(25, 195, 'Pesquisar', oDlg, {|| HS_ProcPro(cCombo, cCond, @aProc, @oLbx)}, 45, 12, , , , .T.)// /*.F. Caracter .T. pixel*/, /*Reservado*/, /*Reservado*/, /*Reservado*/, /*Bloco de Codigo*/, /*Reservado*/, /*Reservado*/)

	@ 40,10 LISTBOX oLbx FIELDS HEADER ;
	" ", "Código", "Descrição" ;
	SIZE 230,095 OF oDlg PIXEL ON DblClick(aEval( aProc,{ |x| x[1] := .F. } ),aProc[oLbx:nAt,1] := .T. ,oLbx:Refresh() )

	oLbx:SetArray( aProc )
	oLbx:bLine := {|| {Iif(aProc[oLbx:nAt,1],oOk,oNo),;
						    aProc[oLbx:nAt,2],;
						    aProc[oLbx:nAt,3]}}

	DEFINE SBUTTON FROM 137,183 TYPE 1 ACTION {|| nRecno := Hs_SelPro(aProc),nOpcI := 1, oDlg:End()} ENABLE OF oDlg	//Ok
	DEFINE SBUTTON FROM 137,213 TYPE 2 ACTION {|| nOpcI := 2, oDlg:End()} ENABLE OF oDlg								//Cancelar

	ACTIVATE MSDIALOG oDlg CENTER

	If nOpcI == 1
		DbSelectArea("GA7")
		GA7->(DbGoto(nRecno))
	EndIf
EndIf

DbSelectArea("GA7PRO")
GA7PRO->(DbCloseArea())

Return(nOpcI == 1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Hs_SelPro ºAutor  ³Darcio Sporl        º Data ³  09/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada para selecionar o procedimento, que devera serº±±
±±º          ³retornado na tela para o usuario.                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Hs_SelPro(aProc)
Local i		:= 0
Local nRet	:= 0

Default aProc := {}

For i := 1 to Len(aProc)
	If aProc[i][1] == .T.
		nRet := aProc[i][4]		// Recno
		Exit
	EndIf
Next

Return(nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_MudaOrdºAutor  ³Darcio Sporl        º Data ³  12/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada, para mudar a ordem da consulta padrao de     º±±
±±º          ³Procedimentos do campo GMJ_CODPRO                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HS_MudaOrd(cCombo, aProc, oLbx)
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO

If cCombo == "Descrição"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena em ordem alfabetica....                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aProc := aSort(aProc,,,{|x,y| x[3] < y[3]})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena em ordem de codigo....                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aProc := aSort(aProc,,,{|x,y| x[2] < y[2]})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLbx:nAt := 1

oLbx:SetArray(aProc)
oLbx:bLine := {|| {Iif(aProc[oLbx:nAt,1],oOk,oNo),;
						aProc[oLbx:nAt,2],;
						aProc[oLbx:nAt,3]}}
oLbx:Refresh()
oLbx:SetFocus()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_ProcProºAutor  ³Darcio Sporl        º Data ³  12/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao criada, para localizar o procedimento, no F3 do campoº±±
±±º          ³GMJ_CODPRO                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GH                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function HS_ProcPro(cCombo, cCond, aProc, oLbx)
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local nPosCond	:= 1
Local cTitulo	:= "Pesquisa Procedimento"

If cCombo == "Descrição"
	nPosCond := aScan(aProc, {|x| SubStr(x[3],1,Len(AllTrim(cCond))) == AllTrim(cCond)})//aScan(aProc, {|x| x[3] $ cCond})
Else
	nPosCond := aScan(aProc, {|x| SubStr(x[2],1,Len(AllTrim(cCond))) == AllTrim(cCond)})
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPosCond > 0
	oLbx:nAt := nPosCond

	oLbx:SetArray(aProc)
	oLbx:bLine := {|| {Iif(aProc[oLbx:nAt,1],oOk,oNo),;
							aProc[oLbx:nAt,2],;
							aProc[oLbx:nAt,3]}}
	oLbx:Refresh()
	oLbx:SetFocus()
Else
	Aviso( cTitulo, "Não existem procedimentos a consultar", {"Ok"} )
	Return
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_F3GCZ  ºAutor  ³Microsiga           º Data ³  09/02/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³CONSULTA GUIAS F3 ATRAVES DO CAMPO "PARA GUIA?"             º±±
±±º          ³ROTINA DE TRANSFERENCIA ENTRE GUIAS NA AUDITORIA DE CONTAS  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HS_F3GCZ()

Local cSqlRet	:= ""
Local aNrguia	:= {}		// Vetor utilizado para trazer As Guias
Local nOpcI		:= 2
Local lMark		:= .F.
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local cTitulo	:= STR0096 //"Consulta de Guias"
Local nRecno	:= 0
Local aOrd		:= {STR0097, STR0098} //"Guia" / ATENDIMENTO
Local cCombo	:= aOrd[1]
Local cCond		:= Space(40)
Local oButton
Local oCombo
Local oCond
Local lRet :=.F.

cSqlRet := "SELECT GCZ.GCZ_NRSEQG ,GCZ.GCZ_REGATE, GCZ.GCZ_REGGER,GCZ.GCZ_NOME ,GCZ.GCZ_CODPLA ,GCZ.GCZ_CODCON,GCZ_NRGUIA,GCZ.R_E_C_N_O_ REGPOS FROM " + RetSqlName("GCZ") + " GCZ"
cSqlRet += " WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND D_E_L_E_T_ <> '*'"
cSqlRet += " AND GCZ.GCZ_REGATE = '" + cGCZRegAte+ "'
cSqlRet += " ORDER BY GCZ_NRGUIA "

cSqlRet := ChangeQuery(cSqlRet)
TCQUERY cSqlRet NEW ALIAS "GCZGUIA"

DbSelectArea("GCZGUIA")

If GCZGUIA->(!Eof())
	GCZGUIA->(DbGoTop())
	While GCZGUIA->(!Eof())
		Aadd( aNrguia, 	{lMark, ;
						 GCZGUIA->GCZ_NRSEQG,;
						 GCZGUIA->GCZ_REGATE,;
						 GCZGUIA->GCZ_REGGER,;
						 GCZGUIA->GCZ_NOME  ,;
						 GCZGUIA->GCZ_CODPLA,;
						 GCZGUIA->GCZ_CODCON,;
						 GCZGUIA->GCZ_NRGUIA,;
						 GCZGUIA->REGPOS})
		GCZGUIA->(DbSkip())
	End
	//+-----------------------------------------------+
	//| Monta a tela para usuario visualizar consulta |
	//+-----------------------------------------------+
	If Len(aNrguia ) == 0
		Aviso( cTitulo, STR0099, {"Ok"} )//"Não existem Guias a consultar"
		Return(.F.)
	Endif

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 320,500 PIXEL

	oCombo 	:= tComboBox():New(10, 10, {|x| If(PCount() > 0, cCombo := x, cCombo)}, aOrd, 100, 20, oDlg, , {|| HS_MudaGui(cCombo, @aNrguia, @oLbx)},,,,.T.,,,,,,,,,'cCombo')
	@ 25, 10 MSGET oCond VAR cCond PICTURE "@!" SIZE 180, 10 VALID .T. OF oDlg PIXEL
	oButton := tButton():New(25, 195, STR0020, oDlg, {|| HS_ProcGui(cCombo, cCond, @aNrguia, @oLbx)}, 45, 12, , , , .T.)// /*.F. Caracter .T. pixel*/, /*Reservado*/, /*Reservado*/, /*Reservado*/, /*Bloco de Codigo*/, /*Reservado*/, /*Reservado*/)   //"Pesquisar"

	@ 40,10 LISTBOX oLbx FIELDS HEADER ;
	" ", STR0097, STR0098, STR0100,STR0101,STR0102,STR0103,STR0104 ; //Guia,Atendimento,Prontuario,Paciente,Cod Plano,Cod Convenio,Nro Guia
	SIZE 230,095 OF oDlg PIXEL ON DblClick(aEval(aNrguia,{ |x| x[1] := .F. } ),aNrguia[oLbx:nAt,1] := .T. ,oLbx:Refresh() )

	oLbx:SetArray(aNrguia )
	oLbx:bLine := {|| {Iif(aNrguia[oLbx:nAt,1],oOk,oNo),;
						   aNrguia[oLbx:nAt,2],;
						   aNrguia[oLbx:nAt,3],;
						   aNrguia[oLbx:nAt,4],;
						   aNrguia[oLbx:nAt,5],;
						   aNrguia[oLbx:nAt,6],;
						   aNrguia[oLbx:nAt,7],;
   						   aNrguia[oLbx:nAt,8],;
						   aNrguia[oLbx:nAt,9]}}

	DEFINE SBUTTON FROM 137,183 TYPE 1 ACTION {|| lRet:=.T.,nRecno := Hs_SelGuia(aNrguia),nOpcI := 1, oDlg:End()} ENABLE OF oDlg	//Ok
	DEFINE SBUTTON FROM 137,213 TYPE 2 ACTION {|| nOpcI := 2, oDlg:End()} ENABLE OF oDlg								//Cancelar
	ACTIVATE MSDIALOG oDlg CENTER



	If nOpcI == 1
		DbSelectArea("GCZ")
		GCZ->(DbGoto(nRecno))
	EndIf
EndIf

DbSelectArea("GCZGUIA")
GCZGUIA->(DbCloseArea())

Return(lRet)

Static Function Hs_SelGuia(aNrguia)
Local i		:= 0
Local nRet	:= 0

Default aNrguia := {}

For i := 1 to Len(aNrguia)
	If aNrguia[i][1] == .T.
		nRet := aNrguia[i][9]		// Recno
		Exit
	EndIf
Next

Return(nRet)


Static Function HS_MudaGui(cCombo, aNrguia, oLbx)
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO

If cCombo == STR0098 //"Atendimento"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena em ordem alfabetica....                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNrguia := aSort(aNrguia,,,{|x,y| x[3] < y[3]})
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ordena em ordem de codigo....                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aNrguia := aSort(aNrguia,,,{|x,y| x[2] < y[2]})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oLbx:nAt := 1

oLbx:SetArray(aNrguia)
oLbx:bLine := {|| {Iif(aNrguia[oLbx:nAt,1],oOk,oNo),;
						aNrguia[oLbx:nAt,2],;
						aNrguia[oLbx:nAt,3],;
						aNrguia[oLbx:nAt,4],;
						aNrguia[oLbx:nAt,5],;
						aNrguia[oLbx:nAt,6],;
						aNrguia[oLbx:nAt,7],;
						aNrguia[oLbx:nAt,8],;
						aNrguia[oLbx:nAt,9]}}
oLbx:Refresh()
oLbx:SetFocus()
Return


Static Function HS_ProcGui(cCombo, cCond, aNrguia, oLbx)
Local oOk		:= LoadBitmap( GetResources(), "CHECKED" )   //CHECKED    //LBOK  //LBTIK
Local oNo		:= LoadBitmap( GetResources(), "UNCHECKED" ) //UNCHECKED  //LBNO
Local nPosCond	:= 1
Local cTitulo	:= STR0105 //"Pesquisa Guias"

If cCombo == STR0098 //"Atendimento"
	nPosCond := aScan(aNrguia, {|x| SubStr(x[3],1,Len(AllTrim(cCond))) == AllTrim(cCond)})//aScan(aProc, {|x| x[3] $ cCond})
Else
	nPosCond := aScan(aNrguia, {|x| SubStr(x[2],1,Len(AllTrim(cCond))) == AllTrim(cCond)})
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nPosCond > 0
	oLbx:nAt := nPosCond

	oLbx:SetArray(aNrguia)
	oLbx:bLine := {|| {Iif(aNrguia[oLbx:nAt,1],oOk,oNo),;
							aNrguia[oLbx:nAt,2],;
							aNrguia[oLbx:nAt,3],;
							aNrguia[oLbx:nAt,4],;
							aNrguia[oLbx:nAt,5],;
							aNrguia[oLbx:nAt,6],;
							aNrguia[oLbx:nAt,7],;
							aNrguia[oLbx:nAt,8],;
							aNrguia[oLbx:nAt,9]}}
	oLbx:Refresh()
	oLbx:SetFocus()
Else
	Aviso( cTitulo, STR0099, {"Ok"} ) //"Não existem Guias a consultar"
	Return
EndIf
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³HS_FilGes ³ Autor ³ Rogerio Tabosa        ³ Data ³ 17/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtro da tabela GES                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HS_SqlGes()

Local cFiltroSql := "@GES_FILIAL = '" + xFilial("GES") + "' AND D_E_L_E_T_ <> '*' "

If Type("cGesTipCan") # "U" .And. !Empty(cGesTipCan)
	cFiltroSql +=  " AND GES_TIPO IN (" + HS_InSql(cGesTipCan) + ") "
Else
	cFiltroSql += " AND GES_TIPO IN('0',' ') "
EndIf

Return(cFiltroSql)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³HS_FilGSAR³ Autor ³ Saude                 ³ Data ³ 22/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra Relac.  ATENDIMENTO x Prontuario do paciente        ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilGSAR()
Local	cRetSql := " "

GCY->(DBCLEARFILTER())

cRetSql := "@GCY_FILIAL = '" + xFilial("GCY") + "' AND D_E_L_E_T_ <> '*' "

If Type("MV_PAR01") # "U" .And. !Empty(MV_PAR01)
	cRetSql += "AND GCY_REGGER = '" + MV_PAR01 + "'"
	cRetSql += "AND GCY_CODLOC = '" + cM24par01 + "'"
EndIf

Return(cRetSql)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³HS_FilGSB3³ Autor ³ Saude                 ³ Data ³ 22/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra   ATENDIMENTO x Prontuario do paciente  GSA         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilGSB3()
Local	cRetSql := " "

cRetSql := "@GCY_FILIAL = '" + xFilial("GCY") + "' AND D_E_L_E_T_ <> '*' "
cRetSql += "AND GCY_REGGER = '" + M->GSB_REGGER + "'"

Return(cRetSql)






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³HS_FilGSA3³ Autor ³ Saude                 ³ Data ³ 22/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra   ATENDIMENTO x Prontuario do paciente  GSA         ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilGSA3()
Local	cRetSql := " "

cRetSql := "@GSB_FILIAL = '" + xFilial("GSB") + "' AND D_E_L_E_T_ <> '*' "
cRetSql += "AND GSB_REGGER = '" + M->GSA_REGGER + "'"
cRetSql += "AND GSB_CODEND = '" + M->GSA_CODEND + "'"

Return(cRetSql)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³HS_FilHB1 ³ Autor ³ Saude                 ³ Data ³ 03/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtra   Cadastro de Produto de Acordo com o tipo          ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function HS_FilHB1()
Local cSqlRet := "@B1_FILIAL = '" + xFilial("SB1") + "' AND D_E_L_E_T_ <> '*'"

If Type("cHsB1TipPro") # "U" .And. cHsB1TipPro <> Nil .AND. !Empty(cHsB1TipPro)
	cSqlRet += " AND B1_TIPO IN (" + cHsB1TipPro + ")"
Endif

Return(cSqlRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³HS_FilB05³ Autor ³ Saude                 ³ Data ³ 30/08/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializador Padrão de Clinicas Dente e Faces do Dente     ³±±
±±³ tabela GD7³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function HS_FilB05(cTipo)
Local cDente:=""
Default cTipo:=""

If cTipo  == "M->GD7_DESREG"
	cDente:=If(!Inclui,HS_INIPADR('B05',2,M->GD7_DENREG,'B05_DESCRI'),'')
ElseIf cTipo == "M->GD7_FACDES"
	cDente:=If(!Inclui,HS_INIPADR('BYL',3,M->GD7_FADENT,'BYL_DESFAC'),'')
Endif

Return(cDente)




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_FilGT9    ³ Autor ³                  ³ Data ³30/9/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Filtra Orçamentos                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_FilGT9()
 Local	cRetSql := "@GT9_FILIAL = '" + xFilial("GT9") + "' AND D_E_L_E_T_ <> '*' "

 If Type("MV_PAR01") # "U" .And. !Empty(MV_PAR01)
  cRetSql += "AND GT9_REGGER = '" + MV_PAR01 + "' "
 EndIf

Return(cRetSql)

// Filtra tabelas de procedimentos - GDB
Function HS_FilGDB()
Local	cRetSql := "@GDB_FILIAL = '" + xFilial("GDB") + "' AND D_E_L_E_T_ <> '*' "

If Type("cGDBCodTab") # "U" .And. !Empty(cGDBCodTab)
	cRetSql += "AND GDB_CHAVE IN (" + HS_InSql(cGDBCodTab,,IIf(At("/",cGDBCodTab)>0,"/","\")) + ") "
Endif


Return(cRetSql)
