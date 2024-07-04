#INCLUDE "GPER812ARG.ch"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE 'TOPCONN.CH'    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ºGPER812ARGºAutor  ºLuis Samaniego      ºFecha º  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ºReporte Histórico de Datos del Empleado                     º±±
±±º          º                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       º SIGAGPE                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºProgramador º Data   ºLlamadoº  Motivo da Alteracao                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍÍÍÅÍÍÍÍÍÍÍÍÅÍÍÍÍÍÍÍÅÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º            º        º       º                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GPER812ARG()
Local oReport := nil
Local cPerg := Padr("GPER812ARG",10)

	Pergunte(cPerg,.F.)
	oReport := ReportDef(cPerg)
	oReport:PrintDialog()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ReportDef       ºAutor  ³Luis Samaniego      º Data ³  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Configura encabezado de campos                                   º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(cPerg)
Local oReport := Nil
Local oSection1 := Nil

Private aCampos := {}
	
	ObtCfgCpos() //Obtiene configuracion de campos

	oReport := TReport():New(cPerg,STR0001,cPerg,{|oReport| RepPrint(oReport)},STR0002)
	oReport:SetPortrait
	oReport:SetTotalInLine(.F.)
	
	oSection1:= TRSection():New(oReport,"HEMP" , {"SRA", "SR9"}, , .F.,.T.)
	TRCell():New(oSection1,"R9_MAT",	"TMPHIST", aCampos[1][1], "",	aCampos[1][2])
	TRCell():New(oSection1,"RA_NOME",	"TMPHIST", aCampos[2][1], "@!",	aCampos[2][2])
	TRCell():New(oSection1,"R9_DATA",	"TMPHIST", aCampos[3][1], "",	aCampos[3][2])
	TRCell():New(oSection1,"R9_CAMPO",	"TMPHIST", aCampos[4][1], "@!",	aCampos[4][2])
	TRCell():New(oSection1,"R9_DESC1",	"TMPHIST", STR0005,       "@!",	aCampos[5][2])
	TRCell():New(oSection1,"R9_DESC2",	"TMPHIST", STR0006,       "@!",	aCampos[5][2])
	
	oSection1:SetTotalInLine(.F.)
	oSection1:SetPageBreak(.T.)
	oSection1:SetTotalText(" ")
	
Return(oReport)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RepPrint        ºAutor  ³Luis Samaniego      º Data ³  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida que el periodo informado sea valido                       º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function RepPrint(oReport)
Local oSection1 := oReport:Section(1)
Local cAlias := GetNextAlias()
Local cQuery 	  := ""
Local nI        := 0

Private cTmpSR9 := CriaTrab(Nil, .F.)
Private cTmpMax := CriaTrab(Nil, .F.)
Private dPerIni := ("//")
Private dPerFin := ("//")
Private aMats := {}

	ObtMatEmp(Alltrim(MV_PAR01))
	
	If VldPerHis()
		ObtPerFch()
	Else
		Return .F.
	EndIf
	
	cQuery := " SELECT SR9.R9_MAT,  SRA.RA_NOME, SR9.R9_CAMPO, MIN(SR9.R9_DATA) MIN_DATA, MAX(SR9.R9_DATA) MAX_DATA"
	cQuery += " FROM " + RetSqlName("SR9") + " SR9, " + RetSqlName("SRA") + " SRA"
	cQuery += " WHERE (SR9.R9_FILIAL = SRA.RA_FILIAL)" 
	cQuery += " AND (SR9.R9_MAT = SRA.RA_MAT)"
	cQuery += " AND SR9.R9_DATA BETWEEN '" + DTOS(dPerIni) + "' AND '" + DTOS(dPerFin) + "'"
	
	If Len(aMats) > 0
		cQuery += " AND SR9.R9_MAT IN ("
		For nI := 1 To Len(aMats)
			If nI == Len(aMats)
				cQuery += " '" + aMats[nI] + "'"
			Else
				cQuery += " '" + aMats[nI] + "',"
			EndIf
		Next
		cQuery += ")"
	EndIf
	
	cQuery += " AND SR9.D_E_L_E_T_ <> '*' AND SRA.D_E_L_E_T_ <> '*'"
	cQuery += " GROUP BY SR9.R9_MAT, SR9.R9_CAMPO, SRA.RA_NOME"
	cQuery += " ORDER BY SR9.R9_MAT, SR9.R9_CAMPO, MAX_DATA"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTmpSR9,.T.,.T.)
	TCSetField(cTmpSR9,'MIN_DATA','D',8,0)
	TCSetField(cTmpSR9,'MAX_DATA','D',8,0)
	
	While !((cTmpSR9)->(Eof())) 
		oSection1:Init()
		oReport:IncMeter()
		oSection1:Cell("R9_MAT"):SetValue((cTmpSR9)->R9_MAT)
		oSection1:Cell("RA_NOME"):SetValue(Alltrim((cTmpSR9)->RA_NOME))
		oSection1:Cell("R9_DATA"):SetValue((cTmpSR9)->MAX_DATA)
		oSection1:Cell("R9_CAMPO"):SetValue((cTmpSR9)->R9_CAMPO)
		oSection1:Cell("R9_DESC1"):SetValue(POSICIONE("SR9", 1, xFilial("SR9")+(cTmpSR9)->R9_MAT+(cTmpSR9)->R9_CAMPO+DTOS((cTmpSR9)->MIN_DATA),"R9_DESC"))
		oSection1:Cell("R9_DESC2"):SetValue(POSICIONE("SR9", 1, xFilial("SR9")+(cTmpSR9)->R9_MAT+(cTmpSR9)->R9_CAMPO+DTOS((cTmpSR9)->MAX_DATA),"R9_DESC"))
		oSection1:Printline()
		(cTmpSR9)->(DbSkip())
	Enddo
	
	oSection1:Finish()
	
	GPEDelArea(cTmpSR9)
	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VldPerHis       ºAutor  ³Luis Samaniego      º Data ³  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida que el periodo informado sea valido                       º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VldPerHis()
Local lOk   := .T.
Local cAnio := ""
Local cMes  := ""
Local nI    := 0

	If !Empty(MV_PAR02)
		cAnio := Substr(MV_PAR02, 1, 4)
		cMes  := Substr(MV_PAR02, 5, 2)
		
		If !(cMes $ "01|02|03|04|05|06|07|08|09|10|11|12")
			lOk := .F.	
		EndIf
		
		For nI := 1 To Len(cAnio)
			If !(Substr(cAnio, nI, 1) $ "0|1|2|3|4|5|6|7|8|9")
				lOk := .F.	
				Exit	
			EndIf
		Next Loop	
	Else
		lOk := .F.	
	EndIf
	
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ObtMatEmp       ºAutor  ³Luis Samaniego      º Data ³  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene matriculas de empleados a consultar                      º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtMatEmp(cMats)
Local nLoop := 0
	
	If !Empty(cMats)
		If subStr(cMats,len(cMats),1) != ";"
			cMats += ";"
		EndIf
		
		If cMats != ";"
			For nLoop := 1 To Len(cMats)
				aAdd(aMats, AllTrim(Substr(cMats, 1, At(";", cMats) -1)))
				cMats := Substr(cMats, At(";", cMats) +1, Len(cMats) -At(";", cMats))
				If Len(cMats) == 0
					Exit
				EndIf
			Next nLoop
		EndIf
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ObtPerFch       ºAutor  ³Luis Samaniego      º Data ³  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene fecha de inicio y fecha final                            º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtPerFch()
Local nMes  := 0
Local nAnio := 0

	nAnio := Val(Substr(MV_PAR02, 1, 4))
	nMes  := Val(Substr(MV_PAR02, 5, 2))
	
	Do Case
		Case nMes == 1
			dPerIni := CTOD("01/" + Strzero(12, 2) + "/" + Strzero(nAnio - 1, 4),"DDMMYYYY")
			dPerFin := CTOD("01/" + Strzero(nMes, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
			dPerFin := CTOD(StrZero(Last_day(dPerFin),2) + "/" + Strzero(nMes, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
		Case nMes == 12
			dPerIni := CTOD("01/" + Strzero(nMes - 1, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
			dPerFin := CTOD("01/" + Strzero(nMes, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
			dPerFin := CTOD(StrZero(Last_day(dPerFin),2) + "/" + Strzero(nMes, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
		OtherWise
			dPerIni := CTOD("01/" + Strzero(nMes - 1, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
			dPerFin := CTOD("01/" + Strzero(nMes, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
			dPerFin := CTOD(StrZero(Last_day(dPerFin),2) + "/" + Strzero(nMes, 2) + "/" + Strzero(nAnio, 4),"DDMMYYYY")
	EndCase	
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ObtCfgCpos      ºAutor  ³Luis Samaniego      º Data ³  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obtiene configuracion de campos                                  º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ObtCfgCpos()
	If Len(aCampos) == 0
		AADD(aCampos, {AllTrim(POSICIONE("SX3", 2, "R9_MAT",		"X3_TITSPA")), TamSX3("R9_MAT")[1], 	TamSX3("R9_MAT")[2]})
		AADD(aCampos, {AllTrim(POSICIONE("SX3", 2, "RA_NOME", 	"X3_TITSPA")), TamSX3("RA_NOME")[1], 	TamSX3("RA_NOME")[2]})
		AADD(aCampos, {AllTrim(POSICIONE("SX3", 2, "R9_DATA", 	"X3_TITSPA")), TamSX3("R9_DATA")[1], 	TamSX3("R9_DATA")[2]})
		AADD(aCampos, {AllTrim(POSICIONE("SX3", 2, "R9_CAMPO", 	"X3_TITSPA")), TamSX3("R9_CAMPO")[1], 	TamSX3("R9_CAMPO")[2]})
		AADD(aCampos, {AllTrim(POSICIONE("SX3", 2, "R9_DESC", 	"X3_TITSPA")), TamSX3("R9_DESC")[1], 	TamSX3("R9_DESC")[2]})
	EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GPEDelArea      ºAutor  ³Luis Samaniego      º Data ³  22/10/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Elimina tablas temporales                                        º±±
±±º          ³                                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAGPE                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GPEDelArea(cArchTmp)
	(cArchTmp)->(dbCloseArea())
	FErase(AllTrim(cArchTmp)+GetDBExtension())
Return