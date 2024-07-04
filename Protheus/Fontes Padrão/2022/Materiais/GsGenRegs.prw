#include 'protheus.ch'
#INCLUDE 'GSGENREGS.ch'
#INCLUDE "FWMVCDEF.CH"

class GsGenRegs

	data oHash AS OBJECT
	data cAutoKey AS CHARACTER
	data aOrcs AS ARRAY

	method new() constructor
	method insert()
	method addAtendente()
	method addOrcamento()
	method addLocal()
	method addRH()
	method addMI()
	method addMC()
	method addTurno()
	method gerarContrt()
	method getRec()
	method getNextKey()
	
endclass

method new() class GsGenRegs
	::oHash := FwHashMap():New()
	::cAutoKey := REPLICATE("0",6)
	::aOrcs := {}
return

method getRec(cKey) class GsGenRegs

Return ::oHash:Get(cKey)

method getNextKey(cTable, cInit) class GsGenRegs
Local lKey := .T.

DbSelectArea(cTable)

While lKey
	cInit := SOMA1(cInit)
	lKey := MsSeek( xFilial(cTable)+ cInit )
EndDo

Return cInit

method insert(cTable, aData) class GsGenRegs
	Local cColName := IIF(LEFT(cTable,1) == 'S', RIGHT(cTable,2), cTable)
	Local nX
	Local cCommand
	Local nRecno := 0
	Default aData := {}
	If ASCAN(aData, {|s| UPPER(s[1]) == cColName + "_FILIAL"}) == 0
		AADD(aData, {cColName + "_FILIAL", xFilial(cTable)})
	EndIf
	Begin Transaction
		Reclock(cTable, .T.)
		For nX := 1 TO LEN(aData)
			cCommand := cTable+"->"+aData[nX][1] + " := "
			Conout("saving " + aData[nX][1])
			If VALTYPE(aData[nX][2]) == 'C'
				cCommand += "'"+aData[nX][2]+"'"
			ElseIf VALTYPE(aData[nX][2]) == 'N'
				cCommand += cValToChar(aData[nX][2])
			ElseIf VALTYPE(aData[nX][2]) == 'D'
				cCommand += "cToD('" + DtoC(aData[nX][2]) + "')"
			ElseIf VALTYPE(aData[nX][2]) == 'L'
				If aData[nX][2]
					cCommand += ".T."
				Else
					cCommand += ".F."
				EndIf
			EndIf
			(&(cCommand))
		Next nX
		MsUnLock()
	End Transaction
	::cAutoKey := cTable + Soma1(RIGHT(::cAutoKey, 6))
	nRecno := (&(cTable+"->(Recno())"))
	::oHash:Put(::cAutoKey,nRecno)

Return ::cAutoKey

method addAtendente(nQtd,lSRA,aFields, lInterm) class GsGenRegs
	Local aKeys 	:= {}
	Local nX
	Local nY
	Local aInsert 	:= {}
	Local cCDFUNC 	:= ""
	Local cCodFunc 	:= ""
	Local cCodCC 	:= ""
	Local lSeek		:= .T.
	Local cAa1Num	:= ""
	Local cSRANum	:= ""
	Local cTurno 	:= ""
	Local cCargo 	:= ""

	Default nQtd 	:= 1
	Default lSRA 	:= .T.
	Default aFields := {}
	Default lInterm := .F.


	DbSelectArea("SRA")
	DbSetOrder(1)

	For nX := 1 To nQtd
		aInsert := {}
		cCDFUNC := ""
		cCodFunc := ""
		cCodCC := ""
		lSeek := .T.
		cNome := RetRdnName()
		If lSRA
			While lSeek
				cSRANum	:= GetSx8Num("SRA","RA_MAT")
				lSeek := SRA->(MsSeek( xFilial('SRA')+ cSRANum ))
				ConfirmSx8()
			EndDo
			AADD(aInsert, {"RA_FILIAL", xFilial("SRA")})
			AADD(aInsert, {"RA_MAT", cSRANum})
			AADD(aInsert, {"RA_NOME", cNome})
			AADD(aInsert, {"RA_NATURAL", "AC"})
			AADD(aInsert, {"RA_NACIONA", "10"})
			AADD(aInsert, {"RA_ESTCIVI", "C"})
			AADD(aInsert, {"RA_SEXO", "M"})
			AADD(aInsert, {"RA_NASC", cToD("04/01/1994")})
			AADD(aInsert, {"RA_GRINRAI", "10"})
			AADD(aInsert, {"RA_CC", GetCC()})
			AADD(aInsert, {"RA_ADMISSA", cToD("04/01/2019")})
			AADD(aInsert, {"RA_OPCAO", cToD("04/01/2019")})
			AADD(aInsert, {"RA_HRSMES", 200})
			AADD(aInsert, {"RA_HRSEMAN", 40})
			AADD(aInsert, {"RA_CODFUNC", GetVldReg('RJ_FUNCAO','SRJ')})
			AADD(aInsert, {"RA_PROCES", GetVldReg('RCJ_CODIGO','RCJ')})
			AADD(aInsert, {"RA_CATFUNC", 'A'})
			AADD(aInsert, {"RA_TIPOPGT", 'M'})
			AADD(aInsert, {"RA_TIPOADM", '1A'})
			AADD(aInsert, {"RA_VIEMRAI", '10'})
			AADD(aInsert, {"RA_NUMCP", '323319 '})
			AADD(aInsert, {"RA_SERCP", '00000'})
			AADD(aInsert, {"RA_TNOTRAB", GetVldReg('R6_TURNO','SR6')})
			If lInterm
				AADD(aInsert, {"RA_TPCONTR", "3"})
			EndIf

			For nY := 1 TO LEN(aFields)
				If "RA_" $ aFields[nY][1]
					If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
						aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
					Else
						AADD(aInsert, aFields[nY])
					EndIf
				EndIf
			Next nY

			If !lInterm .AND. ASCAN(aInsert, {|z| z[1] == "RA_TPCONTR"}) > 0
				lInterm := aInsert[ASCAN(aInsert, {|z| z[1] == "RA_TPCONTR"})][2] == "3"
			EndIf
			If lInterm
				aInsert[ASCAN(aInsert, {|z| z[1] == "RA_CATFUNC"})][2] := "H"
			EndIf

			cCodFunc := aInsert[ASCAN(aInsert, {|z| z[1] == "RA_CODFUNC"})][2]
			cCodCC := aInsert[ASCAN(aInsert, {|z| z[1] == "RA_CC"})][2]
			cCDFUNC := aInsert[ASCAN(aInsert, {|z| z[1] == "RA_MAT"})][2]

			cTurno := aInsert[ASCAN(aInsert, {|z| z[1] == "RA_TNOTRAB"})][2]

			AADD(aKeys, {"SRA",::insert("SRA", aInsert)})
			aInsert := {}
			If lInterm
				cCargo := GetVldReg('Q3_CARGO','SQ3', " AND ( Q3_CC = '" +cCodCC  + "' OR Q3_CC = '" + space(SQ3->(TamSx3("Q3_CC")[1]))+ "') " )
				AADD(aInsert, {"V7_FILIAL", xFilial('SV7')})
				AADD(aInsert, {"V7_MAT", cCDFUNC})
				AADD(aInsert, {"V7_COD", Soma1(space(TAMSX3("V7_COD")[1]))})
				AADD(aInsert, {"V7_CONVC", 'CONVOCACAO SIGATEC'})
				AADD(aInsert, {"V7_DTCON", Date()-3})
				AADD(aInsert, {"V7_ATIVI", 'ATIVIDADE SIGATEC'})
				AADD(aInsert, {"V7_DTINI", Date()})
				AADD(aInsert, {"V7_DTFIM", Date()+365})
				AADD(aInsert, {"V7_FUNC", cCodFunc})
				AADD(aInsert, {"V7_CCUS", cCodCC})
				AADD(aInsert, {"V7_SALAR", 1200.00})
				AADD(aInsert, {"V7_TURNO", cTurno})
				AADD(aInsert, {"V7_CARG", cCargo})
				AADD(aInsert, {"V7_DEPTO",  GetVldReg('QB_DEPTO','SQB')})
				AADD(aInsert, {"V7_TPLOC",  '0'})
				AADD(aInsert, {"V7_HRSDIA",  8})
				AADD(aInsert, {"V7_STAT",  "1"})

				For nY := 1 TO LEN(aFields)
					If "V7_" $ aFields[nY][1]
						If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
							aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
						Else
							AADD(aInsert, aFields[nY])
						EndIf
					EndIf
				Next nY

				AADD(aKeys, {"SV7",::insert("SV7", aInsert)})
				aInsert := {}
			EndIf
			//convocação 3 dias antecedencia
			aInsert := {}
		EndIf
		AADD(aInsert, {"AA1_FILIAL", xFilial("AA1")})

		DbSelectArea("AA1")
		DbSetOrder(1)
		lSeek := .t.
		While lSeek
			cAa1Num	:= GetSx8Num("AA1","AA1_CODTEC")
			lSeek := DbSeek( xFilial('AA1')+ cAa1Num )
			ConfirmSx8()
		EndDo

		AADD(aInsert, {"AA1_CODTEC", cAa1Num})
		AADD(aInsert, {"AA1_NOMTEC", cNome})
		AADD(aInsert, {"AA1_FUNCAO", IIF(!EMPTY(cCodFunc), cCodFunc, GetVldReg('RJ_FUNCAO','SRJ'))})
		AADD(aInsert, {"AA1_CC", IIF(!EMPTY(cCodCC), cCodCC,GetCC())})
		If !EMPTY(cCDFUNC)
			AADD(aInsert, {"AA1_CDFUNC", cCDFUNC})
		EndIf
		AADD(aInsert, {"AA1_VALOR",0})
		AADD(aInsert, {"AA1_CUSTO",0})
		AADD(aInsert, {"AA1_RATE", 0})
		AADD(aInsert, {"AA1_TIPO", '1'})
		AADD(aInsert, {"AA1_CONTRB", '0'})
		AADD(aInsert, {"AA1_ALOCA", '1'})
		AADD(aInsert, {"AA1_VISTOR", "2"})
		AADD(aInsert, {"AA1_VISVLR", "2"})
		AADD(aInsert, {"AA1_VISPRO", "2"})
		AADD(aInsert, {"AA1_IMPPRO", "2"})
		AADD(aInsert, {"AA1_CATEGO", "2"})
		AADD(aInsert, {"AA1_ALTVIS", "2"})
		AADD(aInsert, {"AA1_FTVIST", "2"})
		AADD(aInsert, {"AA1_CRMSIM", "2"})
		AADD(aInsert, {"AA1_MPONTO", "2"})
		AADD(aInsert, {"AA1_RSPMNT", "2"})
		AADD(aInsert, {"AA1_RSPTRA", "2"})
		If lSRA
			AADD(aInsert, {"AA1_FUNFIL", xFilial("SRA")})
		EndIf
		For nY := 1 TO LEN(aFields)
			If "AA1_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY
		AADD(aKeys, {"AA1",::insert("AA1", aInsert)})
		aInsert := {}
	Next nX

Return aKeys

Static Function GetMax(cColumn, cTable, cCondition)
	Local xRet
	Local aArea := GetArea()
	Local cColName := IIF(LEFT(cTable,1) == 'S', RIGHT(cTable,2), cTable)
	Local cSql := " SELECT MAX(" + cColumn + ") C FROM " + RetSqlName( cTable ) + " WHERE D_E_L_E_T_ = ' ' AND " + cColName + "_FILIAL = '" + xFilial(cTable) + "' "
	Local cAliasQry := GetNextAlias()
	Default cCondition := ""
	cSql += cCondition
	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

	xRet := (&("(cAliasQry)->(C)"))
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return xRet

Static Function RetRdnName()
Local cRet := ""
Local aNomes := {}

AADD(aNomes,'Liam')
AADD(aNomes,'Noah')
AADD(aNomes,'William')
AADD(aNomes,'James')
AADD(aNomes,'Logan')
AADD(aNomes,'Benjamin')
AADD(aNomes,'Mason')
AADD(aNomes,'Elijah')
AADD(aNomes,'Oliver')
AADD(aNomes,'Jacob')
AADD(aNomes,'Lucas')
AADD(aNomes,'Michael')
AADD(aNomes,'Alexander')
AADD(aNomes,'Ethan')
AADD(aNomes,'Daniel')
AADD(aNomes,'Matthew')
AADD(aNomes,'Aiden')
AADD(aNomes,'Henry')
AADD(aNomes,'Joseph')
AADD(aNomes,'Jackson')
AADD(aNomes,'Samuel')
AADD(aNomes,'Sebastian')
AADD(aNomes,'David')
AADD(aNomes,'Carter')
AADD(aNomes,'Wyatt')
AADD(aNomes,'Jayden')
AADD(aNomes,'John')
AADD(aNomes,'Owen')
AADD(aNomes,'Dylan')
AADD(aNomes,'Luke')
AADD(aNomes,'Gabriel')
AADD(aNomes,'Anthony')
AADD(aNomes,'Isaac')
AADD(aNomes,'Grayson')
AADD(aNomes,'Jack')
AADD(aNomes,'Julian')
AADD(aNomes,'Levi')
AADD(aNomes,'Christopher')
AADD(aNomes,'Joshua')
AADD(aNomes,'Andrew')
AADD(aNomes,'Lincoln')
AADD(aNomes,'Mateo')
AADD(aNomes,'Ryan')
AADD(aNomes,'Jaxon')
AADD(aNomes,'Nathan')
AADD(aNomes,'Aaron')
AADD(aNomes,'Isaiah')
AADD(aNomes,'Thomas')
AADD(aNomes,'Charles')
AADD(aNomes,'Caleb')
AADD(aNomes,'Josiah')
AADD(aNomes,'Christian')
AADD(aNomes,'Hunter')
AADD(aNomes,'Eli')
AADD(aNomes,'Jonathan')
AADD(aNomes,'Connor')
AADD(aNomes,'Landon')
AADD(aNomes,'Adrian')
AADD(aNomes,'Asher')
AADD(aNomes,'Cameron')
AADD(aNomes,'Leo')
AADD(aNomes,'Theodore')
AADD(aNomes,'Jeremiah')
AADD(aNomes,'Hudson')
AADD(aNomes,'Robert')
AADD(aNomes,'Easton')
AADD(aNomes,'Nolan')
AADD(aNomes,'Nicholas')
AADD(aNomes,'Ezra')
AADD(aNomes,'Colton')
AADD(aNomes,'Angel')
AADD(aNomes,'Brayden')
AADD(aNomes,'Jordan')
AADD(aNomes,'Dominic')
AADD(aNomes,'Austin')
AADD(aNomes,'Ian')
AADD(aNomes,'Adam')
AADD(aNomes,'Elias')
AADD(aNomes,'Jaxson')
AADD(aNomes,'Greyson')
AADD(aNomes,'Jose')
AADD(aNomes,'Ezekiel')
AADD(aNomes,'Carson')
AADD(aNomes,'Evan')
AADD(aNomes,'Maverick')
AADD(aNomes,'Bryson')
AADD(aNomes,'Jace')
AADD(aNomes,'Cooper')
AADD(aNomes,'Xavier')
AADD(aNomes,'Parker')
AADD(aNomes,'Roman')
AADD(aNomes,'Jason')
AADD(aNomes,'Santiago')
AADD(aNomes,'Chase')
AADD(aNomes,'Sawyer')
AADD(aNomes,'Gavin')
AADD(aNomes,'Leonardo')
AADD(aNomes,'Kayden')
AADD(aNomes,'Ayden')
AADD(aNomes,'Jameson')
AADD(aNomes,'Kolton')
AADD(aNomes,'Remy')
AADD(aNomes,'Hank')
AADD(aNomes,'Tate')
AADD(aNomes,'Trenton')
AADD(aNomes,'Kian')
AADD(aNomes,'Drew')
AADD(aNomes,'Mohamed')
AADD(aNomes,'Dax')
AADD(aNomes,'Rocco')
AADD(aNomes,'Bowen')
AADD(aNomes,'Mathias')
AADD(aNomes,'Ronald')
AADD(aNomes,'Francis')
AADD(aNomes,'Matthias')
AADD(aNomes,'Milan')
AADD(aNomes,'Maximilian')
AADD(aNomes,'Royce')
AADD(aNomes,'Skyler')
AADD(aNomes,'Corey')
AADD(aNomes,'Kasen')
AADD(aNomes,'Drake')
AADD(aNomes,'Gerardo')
AADD(aNomes,'Uriah')
AADD(aNomes,'Dennis')

cRet := aNomes[ Randomize( 10, LEN(aNomes) ) ] 

Return cRet

Static Function GetVldReg(cColumn, cTable, cCondition)
	Local xRet
	Local aArea := GetArea()
	Local cColName := IIF(LEFT(cTable,1) == 'S', RIGHT(cTable,2), cTable)
	Local cSql := " SELECT " + cColumn + " C FROM " + RetSqlName( cTable ) + " WHERE D_E_L_E_T_ = ' ' AND " + cColName + "_FILIAL = '" + xFilial(cTable) + "' "
	Local cAliasQry := GetNextAlias()

	Default cCondition := ""
	cSql += cCondition
	cSql := ChangeQuery(cSql)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

	xRet := (&("(cAliasQry)->(C)"))

	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)

Return xRet


Static Function GetCC()
	Local cQry := GetNextAlias()
	Local aArea := GetArea()

	BeginSQL Alias cQry
	SELECT CTT.CTT_CUSTO
	  FROM %Table:CTT% CTT
	 WHERE CTT.CTT_FILIAL = %xFilial:CTT%
	   AND CTT.%NotDel%
	   AND CTT.CTT_CLASSE = '2'
	   AND CTT.CTT_BLOQ = '2'
	EndSQL
	cRet := (cQry)->(CTT_CUSTO)
	(cQry)->(dbCloseArea())
	RestArea(aArea)
Return cRet

method addOrcamento(cID, lAgrupado, aFields) class GsGenRegs
	Local aInsert := {}
	Local cCodProd := ""
	Local cTes := ""
	Local nY
	Local cTfjNum	:= ""
	Local lSeek		:= .T.

	Default aFields := {}
	Default lAgrupado := .T.
	Begin Transaction
		AADD(aInsert, {"TFJ_FILIAL",xFilial('TFJ')})

		DbSelectArea("TFJ")
		DbSetOrder(1)
		While lSeek
			cTfjNum := GetSxeNum("TFJ","TFJ_CODIGO")
			lSeek 	:= DbSeek( xFilial('TFJ')+cTfjNum)
		EndDo

		AADD(aInsert, {"TFJ_CODIGO", cTfjNum})
		AADD(aInsert, {"TFJ_ORCSIM",'1'})
		AADD(aInsert, {"TFJ_ENTIDA",'1'})
		AADD(aInsert, {"TFJ_CODENT", GetVldReg('A1_COD','SA1')})
		AADD(aInsert, {"TFJ_LOJA", GetVldReg('A1_LOJA','SA1')})
		AADD(aInsert, {"TFJ_CONDPG", GetVldReg('E4_CODIGO','SE4')})
		AADD(aInsert, {"TFJ_AGRUP", '1'})
		If lAgrupado
			AADD(aInsert, {"TFJ_GRPRH", (cCodProd := GetVldReg('B1_COD','SB1'))})
			AADD(aInsert, {"TFJ_GRPMI", cCodProd})
			AADD(aInsert, {"TFJ_GRPMC", cCodProd})
			AADD(aInsert, {"TFJ_GRPLE", cCodProd})
			AADD(aInsert, {"TFJ_ITEMRH", '01'})
			AADD(aInsert, {"TFJ_ITEMMI", '01'})
			AADD(aInsert, {"TFJ_ITEMMC", '01'})
			AADD(aInsert, {"TFJ_ITEMLE", '01'})
			AADD(aInsert, {"TFJ_TES", (cTes := GetVldReg('F4_CODIGO','SF4', " AND F4_CODIGO > '500' "))})
			AADD(aInsert, {"TFJ_TESMI", cTes})
			AADD(aInsert, {"TFJ_TESMC", cTes})
			AADD(aInsert, {"TFJ_TESLE", cTes})
		EndIf
		AADD(aInsert, {"TFJ_STATUS", '1'})
		AADD(aInsert, {"TFJ_GESMAT", '1'})
		AADD(aInsert, {"TFJ_CLIPED", '1'})
		AADD(aInsert, {"TFJ_DSGCN", '2'})
		AADD(aInsert, {"TFJ_ANTECI", '2'})
		AADD(aInsert, {"TFJ_CNTREC", '2'})
		AADD(aInsert, {"TFJ_RGMCX", '2'})

		For nY := 1 TO LEN(aFields)
			If "TFJ_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY
		AADD(::aOrcs, {cID, ::insert("TFJ", aInsert) ,lAgrupado, {}})
	End Transaction
return cTfjNum

method addLocal(cIdOrc, cIdLocal, aFields, dDataDe, dDataAte) class GsGenRegs
	Local aInsert := {}
	Local nPosTFJ := ASCAN(::aOrcs, {|a| a[1] == cIdOrc})
	Local nRECTFJ := ::getRec(::aOrcs[nPosTFJ][2])
	Local nY
	Local lSeek		:= .T.
	Local cTflNum	:= ""

	Default aFields := {}
	Default dDataDe	:= DATE()
	Default dDataAte := DATE() + 365

	Begin Transaction
		AADD(aInsert, {"TFL_FILIAL",xFilial('TFL')})

		DbSelectArea("TFL")
		DbSetOrder(1)
		While lSeek
			cTflNum := GetSxeNum('TFL','TFL_CODIGO')
			lSeek	:= DbSeek(xFilial('TFL')+cTflNum)
		EndDo

		AADD(aInsert, {"TFL_CODIGO",cTflNum})
		AADD(aInsert, {"TFL_LOCAL",GetVldReg('ABS_LOCAL','ABS')})
		AADD(aInsert, {"TFL_DTINI", dDataDe})
		AADD(aInsert, {"TFL_DTFIM", dDataAte})
		AADD(aInsert, {"TFL_PEDTIT",'1'})

		TFJ->(DBgoTO(nRECTFJ))
		AADD(aInsert, {"TFL_CODPAI",TFJ->TFJ_CODIGO})

		For nY := 1 TO LEN(aFields)
			If "TFL_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY

		AADD(::aOrcs[nPosTFJ][4], {cIdLocal, ::insert("TFL", aInsert), {}})
	End Transaction
return cTflNum

method addRH(cIdOrc, cIdLocal, cIdRH, aFields, cTurno, cFuncao, cEscala, lPorHora) class GsGenRegs
	Local aInsert := {}
	Local nPosTFJ := ASCAN(::aOrcs, {|a| a[1] == cIdOrc})
	Local nPosTFL := ASCAN(::aOrcs[nPosTFJ][4], {|a| a[1] == cIdLocal})
	Local nRECTFJ := ::getRec(::aOrcs[nPosTFJ][2])
	Local nRECTFL := ::getRec(::aOrcs[nPosTFJ][4][nPosTFL][2])
	Local aABPDados := {}
	Local nY
	Local cCodPai
	Local cCodProd
	Local nTotal
	Local lSeek		:= .T.
	Local cTffNum	:= ""
	Local cCalend   := GetVldReg('AC0_CODIGO','AC0')

	Default aFields := {}
	Default cTurno	:= GetVldReg('R6_TURNO','SR6')
	Default cFuncao	:= GetVldReg('RJ_FUNCAO','SRJ')
	Default cEscala := GetVldReg("TDW_COD","TDW", " AND TDW_STATUS = '1' ")
	Default lPorHora := .F.

	Begin Transaction
		TFL->(DbGoTo(nRECTFL))
		cCodPai := TFL->TFL_CODIGO

		AADD(aInsert, {"TFF_FILIAL",xFilial('TFF')})

		DbSelectArea("TFF")
		DbSetOrder(1)
		While lSeek
			cTffNum	:= GetSxeNum('TFF',"TFF_COD")
			lSeek	:= DbSeek( xFilial('TFF')+cTffNum)
		EndDo

		AADD(aInsert, {"TFF_COD",cTffNum})
		AADD(aInsert, {"TFF_ITEM",Soma1(GetMax("TFF_ITEM","TFF"," AND TFF_CODPAI  = '" + cCodPai + "'"))})
		AADD(aInsert, {"TFF_PRODUT",(cCodProd := GetVldReg("B5_COD","SB5", " AND B5_TPISERV = '4' "))})
		AADD(aInsert, {"TFF_UM", POSICIONE("SB1",1,xFilial("SB1") + cCodProd, "B1_UM")})
		AADD(aInsert, {"TFF_QTDVEN",10})
		AADD(aInsert, {"TFF_PRCVEN",100})

		TFL->(DbGoTo(nRECTFL))

		AADD(aInsert, {"TFF_LOCAL",TFL->TFL_LOCAL})
		AADD(aInsert, {"TFF_PERINI",TFL->TFL_DTINI})
		AADD(aInsert, {"TFF_PERFIM",TFL->TFL_DTFIM})
		AADD(aInsert, {"TFF_CODPAI",TFL->TFL_CODIGO})
		AADD(aInsert, {"TFF_FUNCAO", cFuncao })
		AADD(aInsert, {"TFF_COBCTR",'1'})
		AADD(aInsert, {"TFF_INSALU",'1'})
		AADD(aInsert, {"TFF_GRAUIN",'1'})
		AADD(aInsert, {"TFF_PERICU",'1'})
		If lPorHora
			AADD(aInsert, {"TFF_QTDHRS",'99:99'})
			AADD(aInsert, {"TFF_HRSSAL",'99:99'})
			AADD(aInsert, {"TFF_TURNO",cTurno})
		Else
			AADD(aInsert, {"TFF_ESCALA", cEscala})
			AADD(aInsert, {"TFF_CALEND", cCalend})
		EndIf

		For nY := 1 TO LEN(aFields)
			If "TFF_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY

		nTotal := aInsert[ASCAN(aInsert, {|a| a[1] == "TFF_QTDVEN"})][2] * aInsert[ASCAN(aInsert, {|a| a[1] == "TFF_PRCVEN"})][2]

		TFL->(DbGoTo(nRECTFL))
		RecLock("TFL", .F.)
		TFL->TFL_TOTRH += nTotal
		TFL->(MsUnLock())

		AADD(::aOrcs[nPosTFJ][4][nPosTFL][3], {cIdRH, ::insert("TFF", aInsert), {}, 'RH'})
		
		AADD(aABPDados, {"ABP_FILIAL", xFilial("ABP")} )
		AADD(aABPDados, {"ABP_ITEM", "01"} )
		AADD(aABPDados, {"ABP_BENEFI", "000001"} )
		AADD(aABPDados, {"ABP_VALOR", 24})
		//AADD(aABPDados, {"ABP_VERBA", GetVldReg("RV_COD","SRV", " AND RV_TIPO = 'V' AND RV_PERC = 100 ") })
		AADD(aABPDados, {"ABP_VERBA", "411"})
		AADD(aABPDados, {"ABP_ITRH", cTffNum })

		::insert("ABP", aABPDados)

	End Transaction
return cTffNum

method addMI(cIdOrc, cIdLocal, cIdRH, aFields) class GsGenRegs
	Local aInsert := {}
	Local nPosTFJ := ASCAN(::aOrcs, {|a| a[1] == cIdOrc})
	Local nPosTFL := ASCAN(::aOrcs[nPosTFJ][4], {|a| a[1] == cIdLocal})
	Local nPosTFF := ASCAN(::aOrcs[nPosTFJ][4][nPosTFL][3], {|a| a[1] == cIdRH}) 
	Local nRECTFJ := ::getRec(::aOrcs[nPosTFJ][2])
	Local nRECTFL := ::getRec(::aOrcs[nPosTFJ][4][nPosTFL][2])
	Local nRECTFF := ::getRec(::aOrcs[nPosTFJ][4][nPosTFL][3][nPosTFF][2])
	Local aABPDados := {}
	Local lTabPreco	:= SuperGetMv("MV_ORCPRC",, .F. )
	Local nY
	Local cCodPai
	Local cCodProd
	Local nTotal
	Local lSeek		:= .T.
	Local cTFGNum	:= ""

	Default aFields := {}

	Begin Transaction
		If lTabPreco
			TFL->(DbGoTo(nRECTFL))
			cCodPai := TFL->TFL_CODIGO
		Else
			TFF->(DbGoTo(nRECTFF))
			cCodPai := TFF->TFF_COD
		EndIf
		AADD(aInsert, {"TFG_FILIAL",xFilial('TFG')})

		DbSelectArea("TFG")
		DbSetOrder(1)
		While lSeek
			cTFGNum	:= GetSxeNum('TFG',"TFG_COD")
			lSeek	:= DbSeek( xFilial('TFG')+cTFGNum)
		EndDo

		AADD(aInsert, {"TFG_COD",cTFGNum})
		AADD(aInsert, {"TFG_ITEM",Soma1(GetMax("TFG_ITEM","TFG"," AND TFG_CODPAI  = '" + cCodPai + "'"))})
		AADD(aInsert, {"TFG_PRODUT",(cCodProd := GetVldReg("B5_COD","SB5", " AND B5_TPISERV = '5' AND B5_GSMI= '1'  "))})
		AADD(aInsert, {"TFG_UM", POSICIONE("SB1",1,xFilial("SB1") + cCodProd, "B1_UM")})
		AADD(aInsert, {"TFG_QTDVEN",10})
		AADD(aInsert, {"TFG_PRCVEN",100})

		TFL->(DbGoTo(nRECTFL))

		AADD(aInsert, {"TFG_PERINI",TFL->TFL_DTINI})
		AADD(aInsert, {"TFG_PERFIM",TFL->TFL_DTFIM})
		AADD(aInsert, {"TFG_CODPAI",cCodPai})
		AADD(aInsert, {"TFG_COBCTR",'1'})

		For nY := 1 TO LEN(aFields)
			If "TFG_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY

		nTotal := aInsert[ASCAN(aInsert, {|a| a[1] == "TFG_QTDVEN"})][2] * aInsert[ASCAN(aInsert, {|a| a[1] == "TFG_PRCVEN"})][2]

		TFL->(DbGoTo(nRECTFL))
		RecLock("TFL", .F.)
		TFL->TFL_TOTMI += nTotal
		TFL->(MsUnLock())

	AADD(::aOrcs[nPosTFJ][4][nPosTFL][3][nPosTFF][3], {cIdRH, ::insert("TFG", aInsert), {}, 'MI'})
	End Transaction
return cTFGNum

method addMC(cIdOrc, cIdLocal, cIdRH, aFields) class GsGenRegs
	Local aInsert := {}
	Local nPosTFJ := ASCAN(::aOrcs, {|a| a[1] == cIdOrc})
	Local nPosTFL := ASCAN(::aOrcs[nPosTFJ][4], {|a| a[1] == cIdLocal})
	Local nPosTFF := ASCAN(::aOrcs[nPosTFJ][4][nPosTFL][3], {|a| a[1] == cIdRH}) 
	Local nRECTFJ := ::getRec(::aOrcs[nPosTFJ][2])
	Local nRECTFL := ::getRec(::aOrcs[nPosTFJ][4][nPosTFL][2])
	Local nRECTFF := ::getRec(::aOrcs[nPosTFJ][4][nPosTFL][3][nPosTFF][2])
	Local aABPDados := {}
	Local lTabPreco	:= SuperGetMv("MV_ORCPRC",, .F. )
	Local nY
	Local cCodPai
	Local cCodProd
	Local nTotal
	Local lSeek		:= .T.
	Local cTFHNum	:= ""

	Default aFields := {}

	Begin Transaction
		If lTabPreco
			TFL->(DbGoTo(nRECTFL))
			cCodPai := TFL->TFL_CODIGO
		Else
			TFF->(DbGoTo(nRECTFF))
			cCodPai := TFF->TFF_COD
		EndIf
		AADD(aInsert, {"TFH_FILIAL",xFilial('TFH')})

		DbSelectArea("TFH")
		DbSetOrder(1)
		While lSeek
			cTFHNum	:= GetSxeNum('TFH',"TFH_COD")
			lSeek	:= DbSeek( xFilial('TFH')+cTFHNum)
		EndDo

		AADD(aInsert, {"TFH_COD",cTFHNum})
		AADD(aInsert, {"TFH_ITEM",Soma1(GetMax("TFH_ITEM","TFH"," AND TFH_CODPAI  = '" + cCodPai + "'"))})
		AADD(aInsert, {"TFH_PRODUT",(cCodProd := GetVldReg("B5_COD","SB5", " AND B5_TPISERV = '5' AND B5_GSMC = '1'  "))})
		AADD(aInsert, {"TFH_UM", POSICIONE("SB1",1,xFilial("SB1") + cCodProd, "B1_UM")})
		AADD(aInsert, {"TFH_QTDVEN",10})
		AADD(aInsert, {"TFH_PRCVEN",100})

		TFL->(DbGoTo(nRECTFL))

		AADD(aInsert, {"TFH_PERINI",TFL->TFL_DTINI})
		AADD(aInsert, {"TFH_PERFIM",TFL->TFL_DTFIM})
		AADD(aInsert, {"TFH_CODPAI",cCodPai})
		AADD(aInsert, {"TFH_COBCTR",'1'})

		For nY := 1 TO LEN(aFields)
			If "TFH_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY

		nTotal := aInsert[ASCAN(aInsert, {|a| a[1] == "TFH_QTDVEN"})][2] * aInsert[ASCAN(aInsert, {|a| a[1] == "TFH_PRCVEN"})][2]

		TFL->(DbGoTo(nRECTFL))
		RecLock("TFL", .F.)
		TFL->TFL_TOTMI += nTotal
		TFL->(MsUnLock())

	AADD(::aOrcs[nPosTFJ][4][nPosTFL][3][nPosTFF][3], {cIdRH, ::insert("TFH", aInsert), {}, 'MC'})
	End Transaction
return cTFHNum

method addTurno(aSPJs) class GsGenRegs
Local aKeys := {}
Local aInsert := {}
Local lSeek := .T.
Local cCodTurno := "000"
Local nX
DbSelectArea("SR6")

While lSeek
	cCodTurno := SOMA1(cCodTurno)
	lSeek := SR6->(MsSeek( xFilial('SR6')+ cCodTurno ))
EndDo

AADD(aInsert, {"R6_FILIAL", xFilial("SR6")})
AADD(aInsert, {"R6_TURNO", cCodTurno})
AADD(aInsert, {"R6_DESC", "TURNO " + cCodTurno})
AADD(aInsert, {"R6_HORMENO",	5})
AADD(aInsert, {"R6_HORMAIS",	5})
AADD(aInsert, {"R6_ASFOLGA",	"N"})
AADD(aInsert, {"R6_NONAHOR",	"N"})
AADD(aInsert, {"R6_TPEXT",		"1"})
AADD(aInsert, {"R6_TPEXTN",		"5"})
AADD(aInsert, {"R6_APODFER",	"N"})
AADD(aInsert, {"R6_TPEXFER",	"1"})
AADD(aInsert, {"R6_TPEXFEN",	"5"})
AADD(aInsert, {"R6_INIHNOT",	22})
AADD(aInsert, {"R6_FIMHNOT",	5})
AADD(aInsert, {"R6_MINHNOT",	52.5})
AADD(aInsert, {"R6_ACRENOT",	"N"})
AADD(aInsert, {"R6_EXTNOT",		"S"})
AADD(aInsert, {"R6_HNOTFAL",	"S"})
AADD(aInsert, {"R6_HNOTSAI",	"S"})
AADD(aInsert, {"R6_HNOTATR",	"S"})
AADD(aInsert, {"R6_APTPMAR",	"N"})
AADD(aInsert, {"R6_AUTOSAI",	"CDFN"})
AADD(aInsert, {"R6_HNOTTAB",	"N"})
AADD(aInsert, {"R6_HNOTTBI",	"N"})
AADD(aInsert, {"R6_HEINTER",	"1"})
AADD(aInsert, {"R6_INTERNT",	"SDCFN"})
AADD(aInsert, {"R6_IDACREN",	"N"})
AADD(aInsert, {"R6_AUTOHEF",	"1"})
AADD(aInsert, {"R6_MCIMPJC",	"1"})

AADD(aKeys, {"SR6",::insert("SR6", aInsert)})

For nX := 1 To LEN(aSPJs)
	AADD(aSPJs[nX], {"PJ_TURNO", cCodTurno})
	::insert("SPJ", aSPJs[nX])
Next nX

return aKeys

method gerarContrt(cIdOrc, aFields) class GsGenRegs
	Local aInsert := {}
	Local aInsCNB := {}
	Local aTmpCNC := {}
	Local aTmpCNA := {}
	Local aTmpCNF := {}
	Local aTmpSE1 := {}
	Local aTmpCPD := {}
	Local aTmpCNB := {}
	Local nPosTFJ := ASCAN(::aOrcs, {|a| a[1] == cIdOrc})
	Local nRECTFL := ::getRec(::aOrcs[nPosTFJ][4][1][2]) //primeira TFL do orçamento
	Local nRECTFJ := ::getRec(::aOrcs[nPosTFJ][2])
	Local nRECTFF
	Local dDataMin
	Local dDataMax
	Local cCondPG
	Local nValTotal := 0
	Local cContrato := CN300Num()
	Local aKeys := {}
	Local cCodCli
	Local cLoja
	Local cNumSer
	Local cCodProd
	Local nY
	Local nX
	Local nZ
	Local cCNANum
	Local cCronog

	Default aFields := {}
	Begin Transaction
		TFJ->(DbGoTo(nRECTFJ))
		cCondPG := TFJ->TFJ_CONDPG

		AADD(aInsert, {"AA3_FILIAL",xFilial('AA3')})
		AADD(aInsert, {"AA3_CODCLI",(cCodCli := TFJ->TFJ_CODENT)})
		AADD(aInsert, {"AA3_LOJA",(cLoja := TFJ->TFJ_LOJA)})
		AADD(aInsert, {"AA3_CODPRO",(cCodProd := TFJ->TFJ_GRPRH)})
		AADD(aInsert, {"AA3_NUMSER", (cNumSer := Soma1(GetMax("AA3_NUMSER","AA3")))})
		AADD(aInsert, {"AA3_DTVEND", DATE()})
		AADD(aInsert, {"AA3_DTGAR",DATE() + 120})
		AADD(aInsert, {"AA3_CONTRT", cContrato})
		AADD(aInsert, {"AA3_STATUS", '01'})
		AADD(aInsert, {"AA3_HORDIA", 8})

		TFL->(DbGoTo(nRECTFL))
		AADD(aInsert, {"AA3_CODLOC", TFL->TFL_LOCAL})
		AADD(aInsert, {"AA3_EQALOC", '2'})
		AADD(aInsert, {"AA3_MANPRE", '2'})
		AADD(aInsert, {"AA3_ORIGEM", "CN9"})
		AADD(aInsert, {"AA3_EXIGNF", "1"})
		AADD(aInsert, {"AA3_EQ3", "2"})
		AADD(aInsert, {"AA3_FILORI", cFilant})
		AADD(aInsert, {"AA3_MSBLQL", "2"})
		AADD(aInsert, {"AA3_OSMONT", "2"})
		AADD(aInsert, {"AA3_HMEATV", "2"})
		AADD(aInsert, {"AA3_CONSEP", .F.})
		AADD(aInsert, {"AA3_CONRET", .F.})
		For nY := 1 TO LEN(aFields)
			If "AA3_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY
		AADD(aKeys, {"AA3",::insert("AA3", aInsert)})
		aInsert := {}

		AADD(aInsert, {"AAF_FILIAL",xFilial('AAF')})
		AADD(aInsert, {"AAF_CODCLI",cCodCli })
		AADD(aInsert, {"AAF_LOJA",cLoja })
		AADD(aInsert, {"AAF_CODPRO", cCodProd})
		AADD(aInsert, {"AAF_NUMSER", cNumSer})
		AADD(aInsert, {"AAF_NSERAC", cNumSer})
		AADD(aInsert, {"AAF_DTINI", DATE()})
		AADD(aInsert, {"AAF_PRODAC", cCodProd})
		AADD(aInsert, {"AAF_LOGINI", 'CADASTRO AMARRACAO CLIENTE X EQPTO'})
		For nY := 1 TO LEN(aFields)
			If "AAF_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY
		AADD(aKeys, {"AAF",::insert("AAF", aInsert)})
		aInsert := {}

		AADD(aInsert, {"CN9_FILIAL",xFilial('CN9')})
		AADD(aInsert, {"CN9_NUMERO", cContrato})
		For nY := 1 TO LEN(::aOrcs[nPosTFJ][4])

			nRECTFL := ::getRec(::aOrcs[nPosTFJ][4][nY][2])
			TFL->(DbGoTo(nRECTFL))

			nValTotal += TFL->TFL_TOTRH
			nValTotal += TFL->TFL_TOTMI
			nValTotal += TFL->TFL_TOTMC
			nValTotal += TFL->TFL_TOTLE

			If EMPTY(dDataMin)
				dDataMin := TFL->TFL_DTINI
			EndIf

			If EMPTY(dDataMax)
				dDataMax := TFL->TFL_DTFIM
			EndIf

			If dDataMin > TFL->TFL_DTINI
				dDataMin := TFL->TFL_DTINI
			EndIf

			If dDataMax < TFL->TFL_DTFIM
				dDataMax := TFL->TFL_DTFIM
			EndIf
		Next nY

		AADD(aInsert, {"CN9_DTINIC", dDataMin})
		AADD(aInsert, {"CN9_DTASSI", dDataMin})
		AADD(aInsert, {"CN9_UNVIGE", '1'})
		AADD(aInsert, {"CN9_VIGE", dDataMax - dDataMin + 1})
		AADD(aInsert, {"CN9_DTFIM", dDataMax + 1})
		AADD(aInsert, {"CN9_MOEDA", 1})
		AADD(aInsert, {"CN9_CONDPG", cCondPG})
		AADD(aInsert, {"CN9_TPCTO", GetVldReg('CN1_CODIGO','CN1', " AND CN1_ESPCTR = '2' AND CN1_MEDEVE = '2' AND CN1_CTRFIX = '1' AND CN1_VLRPRV = '1' ")})
		AADD(aInsert, {"CN9_VLINI", nValTotal})
		AADD(aInsert, {"CN9_VLATU", nValTotal})
		AADD(aInsert, {"CN9_FLGREJ", '2'})
		AADD(aInsert, {"CN9_FLGCAU", '2'})
		AADD(aInsert, {"CN9_TPCAUC", '1'})
		AADD(aInsert, {"CN9_SALDO", nValTotal})
		AADD(aInsert, {"CN9_DTPROP", dDataMin})
		AADD(aInsert, {"CN9_SITUAC", '05'})
		AADD(aInsert, {"CN9_VLDCTR", '1'})
		AADD(aInsert, {"CN9_FILORI", cFilAnt})
		AADD(aInsert, {"CN9_ASSINA", dDataMin})
		AADD(aInsert, {"CN9_ESPCTR", '2'})
		AADD(aInsert, {"CN9_FILCTR", xFilial('CN9')})
		For nY := 1 TO LEN(aFields)
			If "CN9_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY
		AADD(aKeys, {"CN9",::insert("CN9", aInsert)})
		aInsert := {}

		TFJ->(DbGoTo(nRECTFJ))
		RecLock("TFJ", .F.)
		TFJ->TFJ_CONTRT := cContrato
		TFJ->(MsUnlock())

		AADD(aInsert, {"CNN_FILIAL",xFilial('CNN')})
		AADD(aInsert, {"CNN_CONTRA", cContrato})
		AADD(aInsert, {"CNN_USRCOD", RetCodUsr()})
		AADD(aInsert, {"CNN_TRACOD", '001'})
		For nY := 1 TO LEN(aFields)
			If "CNN_" $ aFields[nY][1]
				If ASCAN(aInsert, {|a| a[1] == aFields[nY][1]}) > 0
					aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aInsert, aFields[nY])
				EndIf
			EndIf
		Next nY
		AADD(aKeys, {"CNN",::insert("CNN", aInsert)})
		aInsert := {}

		AADD(aTmpCNC, {"CNC_FILIAL",xFilial('CNC')})
		AADD(aTmpCNC, {"CNC_NUMERO", cContrato})
		AADD(aTmpCNC, {"CNC_CLIENT", cCodCli})
		AADD(aTmpCNC, {"CNC_LOJACL", cLoja})

		For nY := 1 TO LEN(aFields)
			If "CNC_" $ aFields[nY][1]
				If ASCAN(aTmpCNC, {|a| a[1] == aFields[nY][1]}) > 0
					aTmpCNC[ASCAN(aTmpCNC, {|a| a[1] == aFields[nY][1]})][2] := aFields[nY][2]
				Else
					AADD(aTmpCNC, aFields[nY])
				EndIf
			EndIf
		Next nY

		AADD(aInsert, ACLONE(aTmpCNC))
		aTmpCNC := {}

		For nY := 1 TO LEN(::aOrcs[nPosTFJ][4])
			nRECTFL := ::getRec(::aOrcs[nPosTFJ][4][nY][2])
			TFL->(dbGoTO(nRECTFL))

			For nX := 1 TO LEN(aInsert)
				If ASCAN(aInsert,{|a| a[3][2] + a[4][2] == POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL, "ABS_CODIGO") +;
						POSICIONE("ABS",1,xFilial("ABS") +	TFL->TFL_LOCAL, "ABS_LOJA")}) == 0
					aTmpCNC := {}
					AADD(aTmpCNC, {"CNC_FILIAL",xFilial('CNC')})
					AADD(aTmpCNC, {"CNC_NUMERO", cContrato})
					AADD(aTmpCNC, {"CNC_CLIENT", POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL, "ABS_CODIGO")})
					AADD(aTmpCNC, {"CNC_LOJACL", POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL, "ABS_LOJA")})
					For nZ := 1 TO LEN(aFields)
						If "CNC_" $ aFields[nZ][1]
							If ASCAN(aTmpCNC, {|a| a[1] == aFields[nZ][1]}) > 0
								aTmpCNC[ASCAN(aTmpCNC, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
							Else
								AADD(aTmpCNC, aFields[nZ])
							EndIf
						EndIf
					Next nZ
					AADD(aInsert, ACLONE(aTmpCNC))
				EndIf
			Next nX
		Next nY

		For nX := 1 To LEN(aInsert)
			AADD(aKeys, {"CNC",::insert("CNC", aInsert[nX])})
		Next nX

		aInsert := {}
		cCNANum := ""
		cCronog := ""
		cSE1Num := ""
		cCNB_ITEM := ""

		For nY := 1 TO LEN(::aOrcs[nPosTFJ][4])
			nRECTFL := ::getRec(::aOrcs[nPosTFJ][4][nY][2])
			TFJ->(DbGoTo(nRECTFJ))
			TFL->(dbGoTO(nRECTFL))
			aTmpCNA := {}
			aTmpCNF := {}
			aTmpSE1 := {}
			aInsCNB := {}
			aTmpCPD := {}

			AADD(aTmpCNA, {"CNA_FILIAL",xFilial('CNA')})
			AADD(aTmpCNA, {"CNA_CONTRA",cContrato})
			If EMPTY(cCNANum)
				AADD(aTmpCNA, {"CNA_NUMERO", (cCNANum := Soma1(GetMax("CNA_NUMERO","CNA"," AND CNA_NUMERO = '" + cContrato + "'"))) })
			Else
				AADD(aTmpCNA, {"CNA_NUMERO", (cCNANum := Soma1(cCNANum)) })
			EndIf
			AADD(aTmpCNA, {"CNA_CLIENT", POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL, "ABS_CODIGO")})
			AADD(aTmpCNA, {"CNA_LOJACL", POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL, "ABS_LOJA") })
			AADD(aTmpCNA, {"CNA_DTINI", TFL->TFL_DTINI})
			AADD(aTmpCNA, {"CNA_VLTOT", TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE })
			AADD(aTmpCNA, {"CNA_SALDO", TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE })
			AADD(aTmpCNA, {"CNA_TIPPLA", GetVldReg('CNL_CODIGO','CNL', " AND CNL_LMTAVS = '0' AND CNL_MEDEVE = '0' AND CNL_MEDAUT = '0' AND CNL_CTRFIX = '0' AND CNL_VLRPRV = '0' AND CNL_CROCTB = '0' AND CNL_CROFIS = '0' ")})
			AADD(aTmpCNA, {"CNA_DTFIM", TFL->TFL_DTFIM})
			If EMPTY(cCronog)
				AADD(aTmpCNA, {"CNA_CRONOG", (cCronog := Soma1(GetMax("CNA_CRONOG","CNA"))) })
			Else
				AADD(aTmpCNA, {"CNA_CRONOG", (cCronog := Soma1(cCronog) )})
			EndIf
			AADD(aTmpCNA, {"CNA_FLREAJ", '2'})
			AADD(aTmpCNA, {"CNA_PRORAT", '2'})
			AADD(aTmpCNA, {"CNA_RPGANT", '2'})

			For nZ := 1 TO LEN(aFields)
				If "CNA_" $ aFields[nZ][1]
					If ASCAN(aTmpCNA, {|a| a[1] == aFields[nZ][1]}) > 0
						aTmpCNA[ASCAN(aTmpCNA, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
					Else
						AADD(aTmpCNA, aFields[nZ])
					EndIf
				EndIf
			Next nZ

			TFL->(dbGoTO(nRECTFL))
			RecLock("TFL",.F.)
			TFL->TFL_PLAN := cCNANum
			TFL->TFL_CONTRT := cContrato
			TFL->TFL_ITPLRH := Soma1(REPLICATE("0", TamSX3("TFL_ITPLRH")[1]))
			TFL->TFL_ITPLMI := Soma1(REPLICATE("0", TamSX3("TFL_ITPLMI")[1]))
			TFL->TFL_ITPLMC := Soma1(REPLICATE("0", TamSX3("TFL_ITPLMC")[1]))
			TFL->TFL_ITPLLE := Soma1(REPLICATE("0", TamSX3("TFL_ITPLLE")[1]))
			TFL->(MsUnlock())

			AADD(aTmpCNF, {"CNF_FILIAL",xFilial('CNF')})
			AADD(aTmpCNF, {"CNF_NUMERO",cCronog})
			AADD(aTmpCNF, {"CNF_CONTRA",cContrato})
			AADD(aTmpCNF, {"CNF_PARCEL",'1'})
			AADD(aTmpCNF, {"CNF_COMPET", STRZERO(MONTH(TFL->TFL_DTINI),2) + '/' + cValToChar(YEAR(TFL->TFL_DTINI))})
			AADD(aTmpCNF, {"CNF_VLPREV", TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE })
			AADD(aTmpCNF, {"CNF_SALDO", TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE })
			AADD(aTmpCNF, {"CNF_PRUMED", TFL->TFL_DTINI})
			AADD(aTmpCNF, {"CNF_DTVENC", TFL->TFL_DTINI})
			AADD(aTmpCNF, {"CNF_MAXPAR", 1})
			AADD(aTmpCNF, {"CNF_TXMOED", 1})
			AADD(aTmpCNF, {"CNF_PERIOD",'1'})
			AADD(aTmpCNF, {"CNF_DIAPAR", 30})
			AADD(aTmpCNF, {"CNF_NUMPLA", cCNANum})

			For nZ := 1 TO LEN(aFields)
				If "CNF_" $ aFields[nZ][1]
					If ASCAN(aTmpCNF, {|a| a[1] == aFields[nZ][1]}) > 0
						aTmpCNF[ASCAN(aTmpCNF, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
					Else
						AADD(aTmpCNF, aFields[nZ])
					EndIf
				EndIf
			Next nZ

			AADD(aTmpSE1, {"E1_FILIAL",xFilial('SE1')})
			AADD(aTmpSE1, {"E1_PREFIXO",'CTR'})
			If EMPTY(cSE1Num)
				AADD(aTmpSE1, {"E1_NUM", (cSE1Num := Soma1(GetMax("E1_NUM","SE1")))})
			Else
				AADD(aTmpSE1, {"E1_NUM", (cSE1Num := Soma1(cSE1Num))})
			EndIf
			AADD(aTmpSE1, {"E1_PARCELA", '1'})
			AADD(aTmpSE1, {"E1_TIPO", 'PR' })
			AADD(aTmpSE1, {"E1_CLIENTE", POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL, "ABS_CODIGO") })
			AADD(aTmpSE1, {"E1_LOJA", POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL, "ABS_LOJA") })
			AADD(aTmpSE1, {"E1_NOMCLI", LEFT(POSICIONE("SA1",1,xFilial("SA1") +;
				POSICIONE("ABS",1,xFilial("ABS") +;
				TFL->TFL_LOCAL, "ABS_CODIGO") +;
				POSICIONE("ABS",1,xFilial("ABS") +;
				TFL->TFL_LOCAL, "ABS_LOJA"), "A1_NOME"),20) })
			AADD(aTmpSE1, {"E1_EMISSAO", TFL->TFL_DTINI})
			AADD(aTmpSE1, {"E1_VENCTO", TFL->TFL_DTINI})
			AADD(aTmpSE1, {"E1_VENCREA", TFL->TFL_DTINI})
			AADD(aTmpSE1, {"E1_VENCORI", TFL->TFL_DTINI})
			AADD(aTmpSE1, {"E1_VALOR",TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE})
			AADD(aTmpSE1, {"E1_SALDO",TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE})
			AADD(aTmpSE1, {"E1_VLCRUZ",TFL->TFL_TOTRH + TFL->TFL_TOTMI + TFL->TFL_TOTMC + TFL->TFL_TOTLE})
			AADD(aTmpSE1, {"E1_EMIS1", TFL->TFL_DTINI})
			AADD(aTmpSE1, {"E1_MOEDA", 1})
			AADD(aTmpSE1, {"E1_STATUS", 'A'})
			AADD(aTmpSE1, {"E1_ORIGEM", 'CNTA100'})
			AADD(aTmpSE1, {"E1_FLUXO", 'S' })
			AADD(aTmpSE1, {"E1_FILORIG",cFilAnt})
			AADD(aTmpSE1, {"E1_MSFIL",cFilAnt})
			AADD(aTmpSE1, {"E1_MSEMP",cEmpAnt})
			AADD(aTmpSE1, {"E1_MDPLANI", cCNANum})
			AADD(aTmpSE1, {"E1_MDCRON", cCronog})
			AADD(aTmpSE1, {"E1_MDCONTR",cContrato})
			AADD(aTmpSE1, {"E1_MDPARCE",'1'})
			AADD(aTmpSE1, {"E1_RELATO",'2'})
			AADD(aTmpSE1, {"E1_TPDESC",'C'})

			For nZ := 1 TO LEN(aFields)
				If "E1_" $ aFields[nZ][1]
					If ASCAN(aTmpSE1, {|a| a[1] == aFields[nZ][1]}) > 0
						aTmpSE1[ASCAN(aTmpSE1, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
					Else
						AADD(aTmpSE1, aFields[nZ])
					EndIf
				EndIf
			Next nZ

			AADD(aTmpCPD, {"CPD_FILIAL",xFilial('CPD')})
			AADD(aTmpCPD, {"CPD_CONTRA",cContrato})
			AADD(aTmpCPD, {"CPD_NUMPLA",cCNANum})
			AADD(aTmpCPD, {"CPD_FILAUT",cFilAnt})

			For nZ := 1 TO LEN(aFields)
				If "CPD_" $ aFields[nZ][1]
					If ASCAN(aTmpCPD, {|a| a[1] == aFields[nZ][1]}) > 0
						aTmpCPD[ASCAN(aTmpCPD, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
					Else
						AADD(aTmpCPD, aFields[nZ])
					EndIf
				EndIf
			Next nZ

			AADD(aTmpCNB, {"CNB_FILIAL",xFilial('CNB')})
			AADD(aTmpCNB, {"CNB_NUMERO",cCNANum})
			AADD(aTmpCNB, {"CNB_ITEM", (cCNB_ITEM := Soma1(GetMax("CNB_ITEM","CNB"," AND CNB_NUMERO = '" + cCNANum + "' AND CNB_CONTRA = '" + cContrato + "' ")))})
			AADD(aTmpCNB, {"CNB_CONTRA",cContrato})
			AADD(aTmpCNB, {"CNB_PRODUT",TFJ->TFJ_GRPRH})
			AADD(aTmpCNB, {"CNB_DESCRI",POSICIONE("SB1",1,xFilial("SB1") + TFJ->TFJ_GRPRH,"B1_DESC")})
			AADD(aTmpCNB, {"CNB_UM",POSICIONE("SB1",1,xFilial("SB1") + TFJ->TFJ_GRPRH,"B1_UM")})
			AADD(aTmpCNB, {"CNB_QUANT",1})
			AADD(aTmpCNB, {"CNB_VLUNIT",TFL->TFL_TOTRH})
			AADD(aTmpCNB, {"CNB_VLTOT",TFL->TFL_TOTRH})
			AADD(aTmpCNB, {"CNB_DTCAD",TFL->TFL_DTINI})
			AADD(aTmpCNB, {"CNB_RATEIO",'2'})
			AADD(aTmpCNB, {"CNB_PRCORI",TFL->TFL_TOTRH})
			AADD(aTmpCNB, {"CNB_QTDORI",1})
			AADD(aTmpCNB, {"CNB_SLDMED",1})
			AADD(aTmpCNB, {"CNB_SLDREC",1})
			AADD(aTmpCNB, {"CNB_FLGCMS",'1'})
			AADD(aTmpCNB, {"CNB_TS",TFJ->TFJ_TES})
			AADD(aTmpCNB, {"CNB_GERBIN",'2'})
			AADD(aTmpCNB, {"CNB_BASINS",'2'})
			AADD(aTmpCNB, {"CNB_FILORI",cFilAnt})
			AADD(aTmpCNB, {"CNB_PEDTIT",'1'})
			AADD(aTmpCNB, {"CNB_CC",POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL,"ABS_CCUSTO")})
			AADD(aTmpCNB, {"CNB_RJRTO",.F.})
			AADD(aTmpCNB, {"CNB_ATIVO",'1'})
			AADD(aTmpCNB, {"CNB_FLREAJ",'2'})

			For nZ := 1 TO LEN(aFields)
				If "CNB_" $ aFields[nZ][1]
					If ASCAN(aTmpCNB, {|a| a[1] == aFields[nZ][1]}) > 0
						aTmpCNB[ASCAN(aTmpCNB, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
					Else
						AADD(aTmpCNB, aFields[nZ])
					EndIf
				EndIf
			Next nZ

			AADD(aInsCNB, ACLONE(aTmpCNB))
			aTmpCNB := {}
			If TFJ->TFJ_GRPMI == aInsCNB[1][5][2]
				aInsCNB[1][9][2] += TFL->TFL_TOTMI
				aInsCNB[1][10][2] += TFL->TFL_TOTMI
				aInsCNB[1][13][2] += TFL->TFL_TOTMI
			Else
				AADD(aTmpCNB, {"CNB_FILIAL",xFilial('CNB')})
				AADD(aTmpCNB, {"CNB_NUMERO",cCNANum})
				AADD(aTmpCNB, {"CNB_ITEM",(cCNB_ITEM := Soma1(cCNB_ITEM))})
				AADD(aTmpCNB, {"CNB_CONTRA",cContrato})
				AADD(aTmpCNB, {"CNB_PRODUT",TFJ->TFJ_GRPMI})
				AADD(aTmpCNB, {"CNB_DESCRI",POSICIONE("SB1",1,xFilial("SB1") + TFJ->TFJ_GRPMI,"B1_DESC")})
				AADD(aTmpCNB, {"CNB_UM",POSICIONE("SB1",1,xFilial("SB1") + TFJ->TFJ_GRPMI,"B1_UM")})
				AADD(aTmpCNB, {"CNB_QUANT",1})
				AADD(aTmpCNB, {"CNB_VLUNIT",TFL->TFL_TOTMI})
				AADD(aTmpCNB, {"CNB_VLTOT",TFL->TFL_TOTMI})
				AADD(aTmpCNB, {"CNB_DTCAD",TFL->TFL_DTINI})
				AADD(aTmpCNB, {"CNB_RATEIO",'2'})
				AADD(aTmpCNB, {"CNB_PRCORI",TFL->TFL_TOTMI})
				AADD(aTmpCNB, {"CNB_QTDORI",1})
				AADD(aTmpCNB, {"CNB_SLDMED",1})
				AADD(aTmpCNB, {"CNB_SLDREC",1})
				AADD(aTmpCNB, {"CNB_FLGCMS",'1'})
				AADD(aTmpCNB, {"CNB_TS",TFJ->TFJ_TESMI})
				AADD(aTmpCNB, {"CNB_GERBIN",'2'})
				AADD(aTmpCNB, {"CNB_BASINS",'2'})
				AADD(aTmpCNB, {"CNB_FILORI",cFilAnt})
				AADD(aTmpCNB, {"CNB_PEDTIT",'1'})
				AADD(aTmpCNB, {"CNB_CC",POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL,"ABS_CCUSTO")})
				AADD(aTmpCNB, {"CNB_RJRTO",'F'})
				AADD(aTmpCNB, {"CNB_ATIVO",'1'})
				AADD(aTmpCNB, {"CNB_FLREAJ",'2'})

				For nZ := 1 TO LEN(aFields)
					If "CNB_" $ aFields[nZ][1]
						If ASCAN(aTmpCNB, {|a| a[1] == aFields[nZ][1]}) > 0
							aTmpCNB[ASCAN(aTmpCNB, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
						Else
							AADD(aTmpCNB, aFields[nZ])
						EndIf
					EndIf
				Next nZ

				AADD(aInsCNB, ACLONE(aTmpCNB))
				aTmpCNB := {}
			EndIf
			For nX := 1 TO LEN(aInsCNB)
				If TFJ->TFJ_GRPMC == aInsCNB[nX][5][2]
					aInsCNB[nX][9][2] += TFL->TFL_TOTMC
					aInsCNB[nX][10][2] += TFL->TFL_TOTMC
					aInsCNB[nX][13][2] += TFL->TFL_TOTMC
				Else
					AADD(aTmpCNB, {"CNB_FILIAL",xFilial('CNB')})
					AADD(aTmpCNB, {"CNB_NUMERO",cCNANum})
					AADD(aTmpCNB, {"CNB_ITEM",(cCNB_ITEM := Soma1(cCNB_ITEM))})
					AADD(aTmpCNB, {"CNB_CONTRA",cContrato})
					AADD(aTmpCNB, {"CNB_PRODUT",TFJ->TFJ_GRPMC})
					AADD(aTmpCNB, {"CNB_DESCRI",POSICIONE("SB1",1,xFilial("SB1") + TFJ->TFJ_GRPMC,"B1_DESC")})
					AADD(aTmpCNB, {"CNB_UM",POSICIONE("SB1",1,xFilial("SB1") + TFJ->TFJ_GRPMC,"B1_UM")})
					AADD(aTmpCNB, {"CNB_QUANT",1})
					AADD(aTmpCNB, {"CNB_VLUNIT",TFL->TFL_TOTMC})
					AADD(aTmpCNB, {"CNB_VLTOT",TFL->TFL_TOTMC})
					AADD(aTmpCNB, {"CNB_DTCAD",TFL->TFL_DTINC})
					AADD(aTmpCNB, {"CNB_RATEIO",'2'})
					AADD(aTmpCNB, {"CNB_PRCORI",TFL->TFL_TOTMC})
					AADD(aTmpCNB, {"CNB_QTDORI",1})
					AADD(aTmpCNB, {"CNB_SLDMED",1})
					AADD(aTmpCNB, {"CNB_SLDREC",1})
					AADD(aTmpCNB, {"CNB_FLGCMS",'1'})
					AADD(aTmpCNB, {"CNB_TS",TFJ->TFJ_TESMC})
					AADD(aTmpCNB, {"CNB_GERBIN",'2'})
					AADD(aTmpCNB, {"CNB_BASINS",'2'})
					AADD(aTmpCNB, {"CNB_FILORI",cFilAnt})
					AADD(aTmpCNB, {"CNB_PEDTIT",'1'})
					AADD(aTmpCNB, {"CNB_CC",POSICIONE("ABS",1,xFilial("ABS") + TFL->TFL_LOCAL,"ABS_CCUSTO")})
					AADD(aTmpCNB, {"CNB_RJRTO",'F'})
					AADD(aTmpCNB, {"CNB_ATIVO",'1'})
					AADD(aTmpCNB, {"CNB_FLREAJ",'2'})

					For nZ := 1 TO LEN(aFields)
						If "CNB_" $ aFields[nZ][1]
							If ASCAN(aTmpCNB, {|a| a[1] == aFields[nZ][1]}) > 0
								aTmpCNB[ASCAN(aTmpCNB, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
							Else
								AADD(aTmpCNB, aFields[nZ])
							EndIf
						EndIf
					Next nZ

					AADD(aInsCNB, ACLONE(aTmpCNB))
					aTmpCNB := {}
				EndIf
			Next nX

			AADD(aKeys, {"CNA",::insert("CNA", aTmpCNA)})
			aTmpCNA := {}

			AADD(aKeys, {"CNF",::insert("CNF", aTmpCNF)})
			aTmpCNF := {}

			AADD(aKeys, {"SE1",::insert("SE1", aTmpSE1)})
			aTmpSE1 := {}

			AADD(aKeys, {"CPD",::insert("CPD", aTmpCPD)})
			aTmpCPD := {}

			For nZ := 1 TO LEN(aInsCNB)
				AADD(aKeys, {"CNB",::insert("CNB", aInsCNB[nZ])})
			Next nZ
			aInsCNB := {}

			For nX := 1 TO LEN(::aOrcs[nPosTFJ][4][nY][3])
				cABQ_ITEM := ""
				If ::aOrcs[nPosTFJ][4][nY][3][nX][4] == 'RH'
					aInsert := {}
					nRECTFF := ::getRec(::aOrcs[nPosTFJ][4][nY][3][nX][2])
					TFF->(DbGoTo(nRECTFF))
					RecLock("TFF", .F.)
					TFF->TFF_CONTRT := cContrato
					TFF->(MsUnlock())
					AADD(aInsert, {"ABQ_FILIAL",xFilial('ABQ')})
					AADD(aInsert, {"ABQ_CONTRT", cContrato})
					If EMPTY(cABQ_ITEM)
						AADD(aInsert, {"ABQ_ITEM", (cABQ_ITEM := Soma1(GetMax("ABQ_ITEM","ABQ"," AND ABQ_CONTRT  = '" + cContrato + "'")))})
					Else
						AADD(aInsert, {"ABQ_ITEM", (cABQ_ITEM := Soma1(cABQ_ITEM))})
					Endif
					cCodProd := TFF->TFF_PRODUT
					AADD(aInsert, {"ABQ_PRODUT", TFF->TFF_PRODUT})
					AADD(aInsert, {"ABQ_TPPROD",'2'})
					AADD(aInsert, {"ABQ_TPREC",'1'})
					AADD(aInsert, {"ABQ_FUNCAO", TFF->TFF_FUNCAO})
					AADD(aInsert, {"ABQ_PERINI", TFF->TFF_PERINI})
					AADD(aInsert, {"ABQ_PERFIM", TFF->TFF_PERFIM})
					AADD(aInsert, {"ABQ_TURNO", TFF->TFF_TURNO})
					AADD(aInsert, {"ABQ_HRSEST",10000}) //no produto ele chama a CriaCalend pra calcular isso
					AADD(aInsert, {"ABQ_FATOR", 10})
					AADD(aInsert, {"ABQ_TOTAL", 100000})
					AADD(aInsert, {"ABQ_SALDO", 100000})
					AADD(aInsert, {"ABQ_ORIGEM", 'CN9'})
					AADD(aInsert, {"ABQ_CODTFF", TFF->TFF_COD})
					AADD(aInsert, {"ABQ_LOCAL", TFF->TFF_LOCAL})
					AADD(aInsert, {"ABQ_FILTFF", TFF->TFF_FILIAL})

					For nZ := 1 TO LEN(aFields)
						If "ABQ_" $ aFields[nZ][1]
							If ASCAN(aInsert, {|a| a[1] == aFields[nZ][1]}) > 0
								aInsert[ASCAN(aInsert, {|a| a[1] == aFields[nZ][1]})][2] := aFields[nZ][2]
							Else
								AADD(aInsert, aFields[nZ])
							EndIf
						EndIf
					Next nZ
					AADD(aKeys, {"ABQ",::insert("ABQ", aInsert)})
					aInsert := {}
					DbSelectArea("SB9")
					DbSetOrder(1)
					If !DbSeek( xFilial('SB9')+cCodProd)
						AADD( aInsert, {"B9_FILIAL", xFilial('SB9')})
						AADD( aInsert, {"B9_LOCAL", "01"})
						AADD( aInsert, {"B9_COD", cCodProd})
						AADD( aInsert, {"B9_QINI", 999})
						AADD( aInsert, {"B9_VINI1", 999})
						::insert("SB9", aInsert)
						aInsert := {}
					EndIf
					DbSelectArea("SB2")
					DbSetOrder(1)
					If !DbSeek( xFilial('SB2')+cCodProd)
						AADD( aInsert, {"B2_FILIAL", xFilial('SB2')})
						AADD( aInsert, {"B2_LOCAL", "01"})
						AADD( aInsert, {"B2_COD", cCodProd})
						AADD( aInsert, {"B2_QFIM", 999})
						AADD( aInsert, {"B2_QATU", 999})
						::insert("SB2", aInsert)
						aInsert := {}
					EndIf
				EndIf
			Next nX

		Next nY

		conout("Done !")

	End Transaction
return cContrato

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecGeraReg

@description Dialog para inserção do atendente, turno e datas para geração
dos registros.
@author	Mateus Boiani
@since	06/08/2020
/*/
//------------------------------------------------------------------------------
Function TecGeraReg(cCodSRA,dGetDtDe,dGetDtAte,cTurno,cGeraManut,lAtendete,lEnvia)
	Local lAutomato		:= isBlind()
	Local lParametros 	:= (SuperGetMV("MV_GSGEROS",.F.,"1") == "2" .AND. TecHasPerg("MV_PAR01","TEC900A"))
	Local lPnmTab		:= (FindFunction("U_PNMSESC") .AND. FindFunction("U_PNMSCAL")) .OR. (FindFunction( "TecExecPNM" ) .AND. TecExecPNM())
	Local oDlgSelect	:= Nil
	Local oGetSRA 		:= nil
	Local oDataDe 		:= nil
	Local oDataAte 		:= nil
	Local oGetTurno 	:= nil
	Local oCombo		:= nil
	Local aOpcs			:= {"2 - Não","1 - Sim"}
	Local aRet			:= {}
	Default cGeraManut := "2"
	Default cCodSRA := SPACE(TamSx3("RA_MAT")[1])
	Default cTurno := SPACE(TamSx3("TDX_TURNO")[1])
	Default dGetDtDe := Date()
	Default dGetDtAte := Date() + 30
	Default lAtendete := .T.
	Default lEnvia := .T.
	If lParametros .AND. lPnmTab
		Begin Transaction
			If !lAutomato
				DEFINE MSDIALOG oDlgSelect FROM 0,0 TO 202,280 PIXEL TITLE "Parâmetros de Geração"
				@ 5, 9 SAY "Funcionário" SIZE 30, 30 PIXEL

				oGetSRA := TGet():New( 015, 009, { | u | If(PCount() > 0, cCodSRA := u, cCodSRA) },oDlgSelect, ;
					060, 010, "!@",{ || .T.}, 0, 16777215,,.F.,,.T.,,.F.,;
					,.F.,.F.,{|| .T.},.F.,.F. ,,"cCodSRA",,,,.T.  )
				oGetSRA:cF3 := 'SRA'

				@ 5, 77 SAY "Turno" SIZE 50, 30 PIXEL

				oGetTurno := TGet():New( 015, 077, { | u | If(PCount() > 0, cTurno := u, cTurno) },oDlgSelect, ;
					020, 010, "!@",{ || .T.}, 0, 16777215,,.F.,,.T.,,.F.,;
					,.F.,.F.,{|| .T.},.F.,.F. ,,"cTurno",,,,.T.  )
				oGetTurno:cF3 := 'SR6'

				@ 30, 9 SAY "Data Inicial" SIZE 50, 30 PIXEL

				oDataDe := TGet():New( 40, 009, { | u | If( PCount() == 0, dGetDtDe, dGetDtDe := u ) },oDlgSelect, ;
					060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtDe",,,,.T.)

				@ 30, 77 SAY "Data Final" SIZE 50, 30 PIXEL

				oDataAte := TGet():New( 40, 077, { | u | If( PCount() == 0, dGetDtAte, dGetDtAte := u ) },oDlgSelect, ;
					060, 010, "@D",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dGetDtAte",,,,.T.)

				@ 64, 9 SAY "Aplica Manutenções?" SIZE 80, 30 PIXEL

				oCombo := TComboBox():New(63,70,{|u|if(PCount()>0,cGeraManut:=u,cGeraManut)},;
        			aOpcs,40,10,oDlgSelect,,,,,,.T.,,,,,,,,,'cGeraManut')

				oRefresh := TButton():New( 84, 010, "Gerar",oDlgSelect,{|| aRet := GeraRegs(cCodSRA,dGetDtDe,dGetDtAte,cTurno,LEFT(cGeraManut,1),.T.,.T.), oDlgSelect:End()}, 50,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Confirma" ## "Realizando manutenção"

				oExit := TButton():New( 84	, 095, "Sair",oDlgSelect,{|| oDlgSelect:End() }, 30,10,,,.F.,.T.,.F.,,.F.,,,.F. ) // "Sair"

				ACTIVATE MSDIALOG oDlgSelect CENTER

				MsgInfo("Processamento concluído !")
			Else
				aRet := GeraRegs(cCodSRA,dGetDtDe,dGetDtAte,cTurno,cGeraManut,lAtendete,lEnvia)
			EndIf
		End Transaction
	Else
		If !lParametros
			Help(,, "TecGeraReg",, STR0001,1, 0) // "Para usar essa ferramenta é necessario modificar o parametro 'MV_GSGEROS' para '2' e fazer a criação dos perguntes 'TEC900A'"
		EndIf
		If !lPnmTab
			Help(,, "TecGeraReg",, STR0002,1, 0) // "Para usar essa ferramenta é necessario fazer a compilação do rdmake padrão 'PNMTABC01' caso o teste tenha alguma modificação, para usar o padrão altere o parametro 'MV_GSPNMTA' para '.T.'. "
		EndIf
	EndIf

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraRegs

@description Criação dos dados para uso do GS da Geração ao Envio de Marcações
@author	Augusto Albuquerque
@since	06/08/2020
/*/
//------------------------------------------------------------------------------
Static Function GeraRegs(cCodSRA,dGetDtDe,dGetDtAte,cTurno,cGeraManut,lAtendete,lEnvia)
	Local cCodTec 	:= ""
	Local cEscala 	:= ""
	Local cFuncao	:= ""
	Local cCodCN9	:= ""
	Local oMdl190d	:= nil
	Local oStrAA1Mdl := nil
	Local oStrDTSMdl := nil
	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},;
			 	   		{.T.,"Fechar"},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	Default lAtendete := .T.
	Default lEnvia := .T.
	If isBlind()
		cCodTec := GeraAtndnt(cCodSRA, @cFuncao)
		cEscala := GeraEscala(cTurno)
		cCodCN9 := GeraContrato(dGetDtDe,dGetDtAte,cTurno, cFuncao, cEscala)
		GeraAgenda(cEscala, cCodCN9, cCodTec, dGetDtDe, dGetDtAte, cTurno)
		If lAtendete
			AtendeABB(cCodTec,dGetDtDe,dGetDtAte)
			If lEnvia
				EnviaABB(cCodTec,dGetDtDe,dGetDtAte)
			EndIf
		EndIF
		GeraABN()
	Else
		FwMsgRun(Nil,{|u| cCodTec := GeraAtndnt(cCodSRA, @cFuncao)}, Nil, "Gerando Atendente...")
		FwMsgRun(Nil,{|u| cEscala := GeraEscala(cTurno)}, Nil, "Gerando Escala...")
		FwMsgRun(Nil,{|u| cCodCN9 := GeraContrato(dGetDtDe,dGetDtAte,cTurno, cFuncao, cEscala)}, Nil, "Gerando Contrato...")
		FwMsgRun(Nil,{|u| GeraAgenda(cEscala, cCodCN9, cCodTec, dGetDtDe, dGetDtAte, cTurno)}, Nil, "Gerando Agendas...")
		If cGeraManut == '1'
			GeraABN()
			oMdl190d := FwLoadModel("TECA190D")
			oMdl190d:SetOperation(MODEL_OPERATION_INSERT)
			oMdl190d:Activate()
			oMdl190d:SetValue("AA1MASTER","AA1_CODTEC",cCodTec)
			oMdl190d:SetValue("DTSMASTER","DTS_DTINI",dGetDtDe)
			oMdl190d:SetValue("DTSMASTER","DTS_DTFIM",dGetDtAte)

			oStrAA1Mdl := oMdl190d:GetModel('AA1MASTER'):GetStruct()
			oStrDTSMdl := oMdl190d:GetModel('DTSMASTER'):GetStruct()
			oStrAA1Mdl:SetProperty( "AA1_CODTEC", MODEL_FIELD_WHEN, { || .F.})
			oStrDTSMdl:SetProperty( "DTS_DTINI", MODEL_FIELD_WHEN,  { || .F. })
			oStrDTSMdl:SetProperty( "DTS_DTFIM", MODEL_FIELD_WHEN,  { || .F. })

			FWExecView("","VIEWDEF.TECA190D", MODEL_OPERATION_INSERT,/*oDlg*/,;
					/*bCloseOnOK*/,/*bOk*/,/*nReduc*/,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oMdl190d)
		EndIf
		FwMsgRun(Nil,{|u| AtendeABB(cCodTec,dGetDtDe,dGetDtAte)}, Nil, "Gerando Atendimento...")
		FwMsgRun(Nil,{|u| EnviaABB(cCodTec,dGetDtDe,dGetDtAte)}, Nil, "Enviando Marcações...")
	EndIf
Return {cCodCN9 , cCodTec}
//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraAtndnt

@description Cadastra / Busca o Atendente conforme Funcionário
@author	Augusto Albuquerque
@since	11/08/2020
/*/
//------------------------------------------------------------------------------
Static Function GeraAtndnt(cCodSRA, cFuncao)
Local cQry := GetNextAlias()
Local cCodTec := ""
Local aInsert := {}
Local lSeek := .T.
Local oGenRg 	:= GsGenRegs():New()
Local cFilAA1 := xFilial("AA1")
Local cFilSRA := xFilial("SRA")

Default cFuncao := ""

BeginSQL Alias cQry
SELECT AA1.AA1_CODTEC, AA1.AA1_FUNCAO
	FROM %Table:AA1% AA1
	WHERE AA1.AA1_FILIAL = %Exp:cFilAA1%
	AND AA1.%NotDel%
	AND AA1.AA1_CDFUNC = %Exp:cCodSRA%
	AND AA1.AA1_FUNFIL = %Exp:cFilSRA%
EndSQL

If (cQry)->(EOF())
	//insere o atendente
	DbSelectArea("SRA")
	DbSetOrder(1)
	DbSeek(cFilSRA+cCodSRA)

	DbSelectArea("AA1")
	DbSetOrder(1)

	cFuncao := SRA->RA_CODFUNC

	lSeek := .T.
	While lSeek
		cCodTec	:= GetSx8Num("AA1","AA1_CODTEC")
		lSeek := DbSeek( xFilial('AA1')+ cCodTec )
		ConfirmSx8()
	EndDo
	AADD(aInsert, {"AA1_FILIAL", cFilAA1})
	AADD(aInsert, {"AA1_CODTEC", cCodTec})
	AADD(aInsert, {"AA1_NOMTEC", SRA->RA_NOME})
	AADD(aInsert, {"AA1_FUNCAO", IIF(!EMPTY(SRA->RA_CODFUNC), SRA->RA_CODFUNC, GetVldReg('RJ_FUNCAO','SRJ'))})
	AADD(aInsert, {"AA1_CC", IIF(!EMPTY(SRA->RA_CC),SRA->RA_CC,GetCC())})
	AADD(aInsert, {"AA1_CDFUNC", cCodSRA})
	AADD(aInsert, {"AA1_VALOR",0})
	AADD(aInsert, {"AA1_CUSTO",0})
	AADD(aInsert, {"AA1_RATE", 0})
	AADD(aInsert, {"AA1_TIPO", '1'})
	AADD(aInsert, {"AA1_CONTRB", '0'})
	AADD(aInsert, {"AA1_ALOCA", '1'})
	AADD(aInsert, {"AA1_VISTOR", "2"})
	AADD(aInsert, {"AA1_VISVLR", "2"})
	AADD(aInsert, {"AA1_VISPRO", "2"})
	AADD(aInsert, {"AA1_IMPPRO", "2"})
	AADD(aInsert, {"AA1_CATEGO", "2"})
	AADD(aInsert, {"AA1_ALTVIS", "2"})
	AADD(aInsert, {"AA1_FTVIST", "2"})
	AADD(aInsert, {"AA1_CRMSIM", "2"})
	AADD(aInsert, {"AA1_MPONTO", "2"})
	AADD(aInsert, {"AA1_RSPMNT", "2"})
	AADD(aInsert, {"AA1_RSPTRA", "2"})
	AADD(aInsert, {"AA1_FUNFIL", cFilSRA})

	oGenRg:insert("AA1", aInsert)
Else
	cCodTec := (cQry)->AA1_CODTEC
	cFuncao := (cQry)->AA1_FUNCAO
EndIf
aInsert := {}
(cQry)->(DbCloseArea())

Return cCodTec
//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraEscala

@description Cadastra / Busca a Escala conforme o Turno informado
@author	Augusto Albuquerque
@since	11/08/2020
/*/
//------------------------------------------------------------------------------
Static Function GeraEscala(cTurno)
Local cEscala := ""
Local cQry := GetNextAlias()
Local cQry2
BeginSQL Alias cQry
SELECT TDX.TDX_CODTDW
	FROM %Table:TDX% TDX
	WHERE TDX.TDX_FILIAL = %xFilial:TDX%
	AND TDX.%NotDel%
	AND TDX.TDX_TURNO = %Exp:cTurno%
EndSQL

If (cQry)->(EOF())
	DbSelectArea("SR6")
	DbSeek(xFilial("SR6")+cTurno)

	//gera a escala
	AT580ImpE({{SR6->R6_FILIAL, SR6->R6_TURNO, SR6->R6_DESC}})

	cQry2 := GetNextAlias()
	BeginSQL Alias cQry2
	SELECT TDX.TDX_CODTDW
		FROM %Table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
		AND TDX.%NotDel%
		AND TDX.TDX_TURNO = %Exp:cTurno%
	EndSQL
	cEscala := (cQry2)->TDX_CODTDW
	(cQry2)->(DbCloseArea())
Else
	cEscala := (cQry)->TDX_CODTDW
EndIf

(cQry)->(DbCloseArea())

Return cEscala
//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraContrato

@description Cadastra um novo contrato conforme parâmetros
@author	Augusto Albuquerque
@since	11/08/2020
/*/
//------------------------------------------------------------------------------
Static Function GeraContrato(dGetDtDe,dGetDtAte,cTurno, cFuncao, cEscala)
Local cCodLocal	:= GetVldReg("NNR_CODIGO","NNR")
Local cCodProd	:= GetVldReg("B5_COD","SB5", " AND B5_TPISERV = '4' ")
Local cCodCli	:= GetVldReg("A1_COD","SA1")
Local cCodLoja	:= GetVldReg("A1_LOJA","SA1", " AND A1_COD = '" + cCodCli + "' ")
Local cCodTes 	:= GetVldReg('F4_CODIGO','SF4', " AND F4_CODIGO > '500' ")
Local cCodPag	:= GetVldReg('E4_CODIGO','SE4')
Local cTpCont	:= GetVldReg('CN1_CODIGO','CN1', " AND CN1_ESPCTR = '2' AND CN1_MEDEVE = '2' AND CN1_CTRFIX = '1' AND CN1_VLRPRV = '1' ")
Local cTipPla	:= GetVldReg('CNL_CODIGO','CNL', " AND CNL_LMTAVS = '0' AND CNL_MEDEVE = '0' AND CNL_MEDAUT = '0' AND CNL_CTRFIX = '0' AND CNL_VLRPRV = '0' AND CNL_CROCTB = '0' AND CNL_CROFIS = '0' ")
Local cCodABS	:= GetVldReg('ABS_LOCAL','ABS')
Local cABSCc	:= GetVldReg('ABS_CCUSTO','ABS')
Local aInsert := {}
Local lSeek
Local oGenRg 	:= GsGenRegs():New()
Local cCodCN9	:= ""

If Empty(cCodLocal)

	aInsert := {}

	DbSelectArea("NNR")
	DbSetOrder(1)
	lSeek := .t.
	While lSeek
		cCodLocal := GetSx8Num("NNR","NNR_CODIGO")
		lSeek := DbSeek( xFilial('NNR')+ cCodLocal )
		ConfirmSx8()
	EndDo
	AADD(aInsert, {"NNR_FILIAL", xFilial("AA1")})
	AADD(aInsert, {"NNR_CODIGO", cCodLocal})
	AADD(aInsert, {"NNR_DESCRI", "PADRÃO"})

	oGenRg:insert("NNR", aInsert)
EndIf

If Empty(cCodProd)
	aInsert := {}
	DbSelectArea("SB1")
	DbSetOrder(1)
	lSeek := .t.
	While lSeek
		cCodProd := GetSx8Num("SB1","B1_COD")
		lSeek := DbSeek( xFilial('SB1')+ cCodProd )
		ConfirmSx8()
	EndDo
	AADD(aInsert, {"B1_FILIAL", xFilial("AA1")})
	AADD(aInsert, {"B1_COD", cCodProd})
	AADD(aInsert, {"B1_DESC", "PRODUTO RH"})
	AADD(aInsert, {"B1_TIPO", "PA"})
	AADD(aInsert, {"B1_UM", "UN"})
	AADD(aInsert, {"B1_LOCPAD", cCodLocal})

	oGenRg:insert("SB1", aInsert)

	aInsert := {}

	AADD(aInsert, {"B5_FILIAL", xFilial("SB5")})
	AADD(aInsert, {"B5_COD", cCodProd})
	AADD(aInsert, {"B5_CEME", "PRODUTO RH"})
	AADD(aInsert, {"B5_ISIDUNI", "1"})
	AADD(aInsert, {"B5_GSLE", "2"})
	AADD(aInsert, {"B5_GSMC", "2"})
	AADD(aInsert, {"B5_GSMI", "2"})
	AADD(aInsert, {"B5_TPISERV", "4"})

	oGenRg:insert("SB5", aInsert)

EndIf

If Empty(cCodCli)

	DbSelectArea("SA1")
	DbSetOrder(1)
	lSeek := .t.
	While lSeek
		cCodCli := GetSx8Num("SA1","A1_COD")
		lSeek := DbSeek( xFilial('SA1')+ cCodCli )
		ConfirmSx8()
	EndDo

	aInsert := {}

	AADD(aInsert, {"A1_FILIAL", xFilial("SA1")})
	AADD(aInsert, {"A1_COD", cCodCli})
	AADD(aInsert, {"A1_LOJA", "10"})
	AADD(aInsert, {"A1_NOME", "LOJA GS"})

	cCodLoja := "10"
	oGenRg:insert("SA1", aInsert)

EndIf

If Empty(cCodTes)
	aInsert := {}

	AADD(aInsert, {"F4_FILIAL", xFilial("SF4")})
	AADD(aInsert, {"F4_TIPO", "S"})
	AADD(aInsert, {"F4_CODIGO", "501"})
	AADD(aInsert, {"F4_ESTOQUE", "N"})
	AADD(aInsert, {"F4_DUPLIC", "N"})

	oGenRg:insert("SF4", aInsert)
EndIf

If Empty(cCodPag)

	DbSelectArea("SE4")
	DbSetOrder(1)
	lSeek := .t.
	While lSeek
		cCodPag := GetSx8Num("SE4","E4_CODIGO")
		lSeek := DbSeek( xFilial('SE4')+ cCodPag )
		ConfirmSx8()
	EndDo

	aInsert := {}

	AADD(aInsert, {"E4_FILIAL", xFilial("SE4")})
	AADD(aInsert, {"E4_CODIGO", cCodPag})
	AADD(aInsert, {"E4_TIPO", "1"})
	AADD(aInsert, {"E4_COND", "0"})
	AADD(aInsert, {"E4_DESCRI", "A VISTA"})

	oGenRg:insert("SE4", aInsert)
EndIf


If Empty(cCodABS) .Or. Empty(cABSCc)
	aInsert := {}

	DbSelectArea("ABS")
	DbSetOrder(1)
	lSeek := .t.
	While lSeek
		cCodABS := GetSx8Num("ABS","ABS_LOCAL")
		lSeek := DbSeek( xFilial('ABS')+ cCodABS )
		ConfirmSx8()
	EndDo

	AADD(aInsert, {"ABS_FILIAL", xFilial("ABS")})
	AADD(aInsert, {"ABS_LOCAL", cCodABS})
	AADD(aInsert, {"ABS_ENTIDA", "1"})
	AADD(aInsert, {"ABS_CODIGO", cCodCli})
	AADD(aInsert, {"ABS_LOJA", cCodLoja})
	AADD(AInsert, {"ABS_CCUSTO", ALLTRIM(GetCC())})

	oGenRg:insert("ABS", aInsert)
EndIf

If Empty(cTpCont)

	aInsert := {}

	DbSelectArea("CN1")
	DbSetOrder(1)
	lSeek := .t.
	While lSeek
		cTpCont := GetSx8Num("CN1","CN1_CODIGO")
		lSeek := DbSeek( xFilial('CN1')+ cTpCont )
		ConfirmSx8()
	EndDo

	AADD(aInsert, {"CN1_FILIAL", xFilial("CN1")})
	AADD(aInsert, {"CN1_CODIGO", cTpCont})
	AADD(aInsert, {"CN1_DESCRI", "PADRÃO"})
	AADD(aInsert, {"CN1_ESPCTR", "2"})
	AADD(aInsert, {"CN1_CTRFIX", "1"})
	AADD(aInsert, {"CN1_VLRPRV", "1"})
	AADD(aInsert, {"CN1_CROFIS", "2"})
	AADD(aInsert, {"CN1_CROCTB", "2"})
	AADD(aInsert, {"CN1_TPMULT", "2"})
	AADD(aInsert, {"CN1_MULMAN", "4"})
	AADD(aInsert, {"CN1_MEDAUT", "2"})
	AADD(aInsert, {"CN1_MEDEVE", "2"})
	AADD(aInsert, {"CN1_TPLMT", "1"})

	oGenRg:insert("CN1", aInsert)

EndIf

If Empty(cTipPla)
	aInsert := {}

	DbSelectArea("CNL")
	DbSetOrder(1)
	lSeek := .t.
	While lSeek
		cTipPla := GetSx8Num("CNL","CNL_CODIGO")
		lSeek := DbSeek( xFilial('CNL')+ cTipPla )
		ConfirmSx8()
	EndDo

	AADD(aInsert, {"CNL_FILIAL", xFilial("CNL")})
	AADD(aInsert, {"CNL_CODIGO", cTipPla})
	AADD(aInsert, {"CNL_DESCRI", "CONFORME CONTRAT"})
	AADD(aInsert, {"CNL_MEDEVE", "0"})
	AADD(aInsert, {"CNL_CTRFIX", "0"})
	AADD(aInsert, {"CNL_TPSFIX", "0"})
	AADD(aInsert, {"CNL_PLSERV", "2"})
	AADD(aInsert, {"CNL_MEDAUT", "0"})
	AADD(aInsert, {"CNL_VLRPRV", "0"})
	AADD(aInsert, {"CNL_CROFIS", "0"})
	AADD(aInsert, {"CNL_CROCTB", "0"})
	AADD(aInsert, {"CNL_TPLMT", "0"})
	AADD(aInsert, {"CNL_LMTMED", 0})
	AADD(aInsert, {"CNL_TPMULT", "0"})
	AADD(aInsert, {"CNL_MULMAN", "0"})
	AADD(aInsert, {"CNL_CRALM", "0"})
	AADD(aInsert, {"CNL_ALCMED", "0"})
	AADD(aInsert, {"CNL_LMTAVS", 0})
	AADD(aInsert, {"CNL_CREAJM", "0"})

	oGenRg:insert("CNL", aInsert)

EndIf

//Geração do Contrato
DbSelectArea("TFJ")
DbSetOrder(1)

oGenRg:addOrcamento('ORCAMENTO GS')
oGenRg:addLocal('ORCAMENTO GS', "Loc01",{{'TFL_LOCAL',cCodABS}}, dGetDtDe,dGetDtAte)
oGenRg:addRH('ORCAMENTO GS', 'Loc01', "RH1", ,cTurno, cFuncao, cEscala)
cCodCN9 := oGenRg:gerarContrt('ORCAMENTO GS')

At690Unit()

Return cCodCN9
//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraAgenda

@description Insere ABBs conforme parâmetros
@author	Augusto Albuquerque
@since	11/08/2020
/*/
//------------------------------------------------------------------------------
Static Function GeraAgenda(cEscala, cCodCN9, cCodTec, dGetDtDe, dGetDtAte, cTurno)
Local oAloc := GsAloc():New()
Local cCodTFF := GetVldReg('TFF_COD','TFF', " AND TFF_CONTRT = '" + cCodCN9 + "' ")
Local nX
Local aArrTGY := {{"",""},{"",""},{"",""},{"",""}}

oAloc:defEscala(cEscala)
oAloc:defPosto(cCodTFF)
oAloc:defTec(cCodTec)
oAloc:defGrupo(1)
oAloc:defConfal(GetVldReg('TDX_COD','TDX', " AND TDX_CODTDW = '" + cEscala + "' "))
oAloc:defDate( dGetDtDe, dGetDtAte)
oAloc:defSeq(GetVldReg('PJ_SEMANA','SPJ', " AND PJ_TURNO = '" + cTurno + "' "))
oAloc:defTpAlo("001")

oAloc:ProjAloc()

If VldEscala(0, cEscala, cCodTFF, .F.)
	For nX := 1 To 4
		If ( At580bHGet(( "PJ_ENTRA" + cValToChar(nX) )) != 0 .OR. At580bHGet(("PJ_SAIDA" + cValToChar(nX))) != 0 )
			aArrTGY[nX][1] := TxValToHor(At580bHGet(("PJ_ENTRA"+ cValToChar(nX))))
			aArrTGY[nX][2] := TxValToHor(At580bHGet(("PJ_SAIDA"+ cValToChar(nX))))
		EndIf
	Next
	oAloc:defGeHor( aArrTGY )
EndIf

oAloc:GravaAloc()
If !isBlind()
	MsgInfo(oAloc:defMessage())
EndIf
oAloc:destroy()

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraAgenda

@description Executa o Atendimento das Agendas (ABBs)
@author	Augusto Albuquerque
@since	11/08/2020
/*/
//------------------------------------------------------------------------------
Static Function AtendeABB(cCodTec,dGetDtDe,dGetDtAte)
Local aParams := {}

AADD( aParams, cCodTec)
AADD( aParams, cCodTec)
AADD( aParams, dGetDtDe)
AADD( aParams, dGetDtAte)
AADD( aParams, "")
AADD( aParams, Replicate("Z", TamSX3("A1_COD")[1]))
AADD( aParams, "")
AADD( aParams, Replicate("Z", TamSX3("A1_COD")[1]))
AADD( aParams, 1)
AADD( aParams, cFilAnt)	

TECA900(.T., aParams)

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} EnviaABB

@description Envia agendas atendidas para o ponto
@author	Augusto Albuquerque
@since	11/08/2020
/*/
//------------------------------------------------------------------------------
Static Function EnviaABB(cCodTec,dGetDtDe,dGetDtAte)

Local aParams := {}

AADD( aParams, {"MV_PAR01", cCodTec})
AADD( aParams, {"MV_PAR02", cCodTec})
AADD( aParams, {"MV_PAR03", dGetDtDe})
AADD( aParams, {"MV_PAR04", dGetDtAte})
AADD( aParams, {"MV_PAR05", 1})
AADD( aParams, {"MV_PAR06", 1})
AADD( aParams, {"MV_PAR07", 0})
AADD( aParams, {"MV_PAR08", cFilAnt})

TECA910(.T., aParams)

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} GeraABN

@description Insere automatcamente as ABNs caso não esteja cadastradas

@author	Mateus Boiani
@since	11/08/2020
/*/
//------------------------------------------------------------------------------
Static Function GeraABN()
Local aInsert := {}
Local lSeek
Local cCodABN
Local aTipos := {{"04","HORA EXTRA NÃO PLANEJADA"},;
				{"01","FALTA"},;
				{"02","ATRASO"},;
				{"03","SAÍDA ANTECIPADA"},;
				{"05","CANCELAMENTO"},;
				{"07","AUSÊNCIA"},;
				{"08","REALOCAÇÃO"},;
				{"09","COMPENSAÇÃO"}}
Local nX
Local oGenRg := GsGenRegs():New()

For nX := 1 To LEN(aTipos)
	If EMPTY( GetVldReg('ABN_CODIGO','ABN'," AND ABN_TIPO = '" + aTipos[nX][1] + "' ") )

		aInsert := {}

		DbSelectArea("ABN")
		DbSetOrder(1)
		lSeek := .t.
		While lSeek
			cCodABN := GetSXENum( "ABN", "ABN_CODIGO" )
			lSeek := DbSeek( xFilial('ABN')+ cCodABN )
			ConfirmSx8()
		EndDo

		AADD(aInsert, {"ABN_FILIAL", xFilial("ABN")})
		AADD(aInsert, {"ABN_CODIGO", cCodABN})
		AADD(aInsert, {"ABN_DESC", aTipos[nX][2]})
		AADD(aInsert, {"ABN_TIPO", aTipos[nX][1]})

		oGenRg:insert("ABN", aInsert)
	EndIf
Next nX

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecGerFer

@description Gera férias conforme parâmetros 

@author	Matheus.Goncalves
@since	09/04/2021
/*/
//------------------------------------------------------------------------------
Function TecGerFer(cCodCal,dData,cHEdia,cHEnoite,cFixo)
Local aInsert := {}
Local oGenRg := GsGenRegs():New()

Default cHEdia   := "4" //Feriado 
Default cHEnoite := "4" //Feriado 
Default cFixo    := "S" //Feriado Fixo
Default cCodCal  := GetVldReg('AC0_CODIGO','AC0')

DbSelectArea("RR0")
RR0->(DbSetOrder(1))

If !(DbSeek(xFIlial("RR0")+DTOS(dData)+cCodCal)) .And. !Empty(cCodCal) .And. !Empty(dData) 

	AADD(aInsert, {"RR0_FILIAL", xFilial("RR0")})
	AADD(aInsert, {"RR0_DATA", dData})
	AADD(aInsert, {"RR0_DESC", "FERIADO GENERICO"})
	AADD(aInsert, {"RR0_TPEXT", cHEdia})
	AADD(aInsert, {"RR0_TPEXTN", cHEdia})
	AADD(aInsert, {"RR0_FIXO", cFixo})
	AADD(aInsert, {"RR0_MESDIA", MesDia(dData)})
	AADD(aInsert, {"RR0_RHEXP", ""})
	AADD(aInsert, {"RR0_CODCAL", cCodCal})

	oGenRg:insert("RR0", aInsert)

EndIf

Return
//------------------------------------------------------------------------------
/*/{Protheus.doc} TecIncRat

@description Inclui programação de Rateio para automação

@author	Matheus.Goncalves
@since	15/04/2021
/*/
//------------------------------------------------------------------------------
Function TecIncRat(cCodMat, cCompet,cFunCc)
Local aInsert := {}
Local oGenRg := GsGenRegs():New()

Default cCompet := ""
Default cFunCc  := ""

DbSelectArea("RHQ")
RHQ->(DbSetOrder(1))

If !(DbSeek(xFIlial("RHQ")+cCodMat+cCompet))

	AADD(aInsert, {"RHQ_FILIAL", xFilial("RHQ")})
	AADD(aInsert, {"RHQ_MAT", cCodMat})
	AADD(aInsert, {"RHQ_DEMES", cCompet})
	AADD(aInsert, {"RHQ_AMES", cCompet})
	AADD(aInsert, {"RHQ_CC", cFunCc})
	AADD(aInsert, {"RHQ_PERC",100})

	oGenRg:insert("RHQ", aInsert)

EndIf

Return

Function TecGenRVld(cColumn, cTable, cCondition)

Return GetVldReg(cColumn, cTable, cCondition)
