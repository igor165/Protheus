#Include "TMSA253.CH"
#Include "Protheus.ch"

Static lTMA253Val := ExistBlock("TMA253Val")	//-- Permite manipular o valor do custo da viagem

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa253Doc ³ Autor ³ Valdemar Roberto  ³ Data ³ 27.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Busca os documentos de uma viagem para cálculo do rateio a ³±±
±±³          ³ pagar                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa253Doc(cExp01,lExp01)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 := Número da viagem                                 ³±±
±±³          ³ lExp01 := Indica se exibe help                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa253Doc(cViagem,lExbHlp)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local cQuery    := ""
Local cAliasDUD := ""

DEFAULT cViagem := ""
DEFAULT lExbHlp := .T.

If !Empty(cViagem)
	cAliasDUD := GetNextAlias()
	cQuery := "SELECT DUD_FILDOC,DUD_DOC,DUD_SERIE "
	cQuery += "  FROM " + RetSqlName("DUD") + " DUD "
	cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DUD_FILDOC,DUD_DOC,DUD_SERIE"
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)
	
	While (cAliasDUD)->(!Eof())
		Aadd(aRet,{(cAliasDUD)->DUD_FILDOC,(cAliasDUD)->DUD_DOC,(cAliasDUD)->DUD_SERIE})
		(cAliasDUD)->(DbSkip())
	EndDo
	
	(cAliasDUD)->(DbCloseArea())
EndIf

If lExbHlp .And. Empty(aRet)
	Help("",1,"TMSA25301") //-- "Não foram encontrados registros para a seleção. Verifique os dados dos documentos da viagem
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return Aclone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa253Via ³ Autor ³ Valdemar Roberto  ³ Data ³ 27.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apuração da receita da viagem                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa253Via(cExp01,lExp01)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 := Número da viagem                                 ³±±
±±³          ³ lExp01 := Indica se exibe help                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa253Via(cViagem,lExbHlp)
Local aAreas    := {GetArea()}
Local nRet      := 0
Local cQuery    := ""
Local cAliasDT8 := ""

DEFAULT cViagem := ""
DEFAULT lExbHlp := .T.

DTQ->( dbSetOrder( 1 ) )
If DTQ->( MsSeek( xFilial("DTQ") + cViagem ))
	If !Empty(cViagem)
		cAliasDT8 := GetNextAlias()
		cQuery := "SELECT SUM(DT8_VALPAS) TOTAL "
		cQuery += "  FROM " + RetSqlName("DUD") + " DUD "
		cQuery += "  JOIN " + RetSqlName("DT8") + " DT8 "
		cQuery += "    ON DT8_FILIAL = '" + xFilial("DT8") + "' "
		cQuery += "   AND DT8_FILDOC = DUD_FILDOC "
		cQuery += "   AND DT8_DOC    = DUD_DOC "
		cQuery += "   AND DT8_SERIE  = DUD_SERIE "
		cQuery += "   AND DT8_CODPAS <> 'TF' "
		cQuery += "   AND DT8.D_E_L_E_T_ = ' ' "
		cQuery += "  JOIN " + RetSqlName("DT3") + " DT3 "
		cQuery += "    ON DT3_FILIAL = '" + xFilial("DT3") + "' "
		cQuery += "   AND DT3_CODPAS = DT8_CODPAS "
		cQuery += "   AND DT3_RECEIT = '1' "
		cQuery += "   AND DT3.D_E_L_E_T_ = ' ' "
		cQuery += " WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUD_VIAGEM = '" + cViagem + "' "
		cQuery += "   AND DUD.D_E_L_E_T_ = ' '"
		
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT8,.T.,.T.)
	
		TcSetField(cAliasDT8,"TOTAL","N",TamSX3("DT8_VALPAS")[1],TamSX3("DT8_VALPAS")[2])
			
		If (cAliasDT8)->(!Eof())
			nRet := (cAliasDT8)->TOTAL
		EndIf
		
		(cAliasDT8)->(DbCloseArea())
	EndIf
EndIf 
If lExbHlp .And. nRet == 0 .And. DTQ->DTQ_SERTMS != "1"
	  Help("",1,"TMSA253REC",STR0001,1,4)                     //-- “Não foi encontrada nenhuma Receita para esta Despesa.”             
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return nRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa253RDc ³ Autor ³ Valdemar Roberto  ³ Data ³ 27.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apuração da receita do documento                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa253RDc(cExp01,cExp02,cExp03,cExp04,lExp01)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 := Filial origem do documento                       ³±±
±±³          ³ cExp02 := Número do documento                              ³±±
±±³          ³ cExp03 := Série do documento                               ³±±
±±³          ³ cExp04 := Número da viagem                                 ³±±
±±³          ³ lExp01 := Indica se exibe help                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa253RDc(cFilDoc,cDoc,cSerie,cViagem,lExbHlp)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local cQuery    := ""
Local cAliasDT8 := ""
Local cDocAnt   := ""
Local nValor    := 0

DEFAULT cFilDoc := ""
DEFAULT cDoc    := ""
DEFAULT cSerie  := ""
DEFAULT cViagem := ""
DEFAULT lExbHlp := .T.

cAliasDT8 := GetNextAlias()
cQuery := " SELECT DT8.DT8_FILDOC,DT8.DT8_DOC,DT8.DT8_SERIE,DT8.DT8_VALPAS "
cQuery += "  FROM " + RetSqlName("DUD") + " DUD "

cQuery += "  LEFT JOIN " + RetSqlName("DTC") + " DTC " 
cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
cQuery += "   AND DTC_FILORI = DUD.DUD_FILDOC "
cQuery += "   AND DTC_NUMSOL = DUD.DUD_DOC "
cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "

cQuery += "  LEFT JOIN " + RetSqlName("DUD") + " DUDENT " 
cQuery += "    ON DUDENT.DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "   AND DUDENT.DUD_FILDOC = DTC.DTC_FILDOC "
cQuery += "   AND DUDENT.DUD_DOC = DTC.DTC_DOC "
cQuery += "   AND DUDENT.DUD_SERIE = DTC.DTC_SERIE "
cQuery += "   AND DUDENT.D_E_L_E_T_ = ' ' "

cQuery += "  INNER JOIN " + RetSqlName("DT8") + " DT8 "
cQuery += "    ON DT8_FILIAL = '" + xFilial("DT8") + "' "
cQuery += "   AND DT8_FILDOC = CASE WHEN DUDENT.DUD_FILDOC IS NULL THEN DUD.DUD_FILDOC ELSE  DUDENT.DUD_FILDOC END "
cQuery += "   AND DT8_DOC    = CASE WHEN DUDENT.DUD_DOC IS NULL THEN DUD.DUD_DOC ELSE  DUDENT.DUD_DOC END  "
cQuery += "   AND DT8_SERIE  = CASE WHEN DUDENT.DUD_SERIE IS NULL THEN DUD.DUD_SERIE ELSE  DUDENT.DUD_SERIE END "
cQuery += "   AND DT8_CODPAS <> 'TF' "
cQuery += "   AND DT8.D_E_L_E_T_ = ' ' "

cQuery += "  INNER JOIN " + RetSqlName("DT3") + " DT3 "
cQuery += "    ON DT3.DT3_FILIAL = '" + xFilial("DT3") + "' "
cQuery += "   AND DT3.DT3_CODPAS = DT8.DT8_CODPAS "
cQuery += "   AND DT3.DT3_RECEIT = '1' "
cQuery += "   AND DT3.D_E_L_E_T_ = ' ' "


cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
If !Empty(cViagem)
	cQuery += "   AND DUD.DUD_VIAGEM = '" + cViagem + "' "
Else
	cQuery += "   AND DUD.DUD_FILDOC = '" + cFilDoc + "' "
	cQuery += "   AND DUD.DUD_DOC    = '" + cDoc + "' "
	cQuery += "   AND DUD.DUD_SERIE  = '" + cSerie + "' "
EndIf
cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY DT8.DT8_FILDOC,DT8.DT8_DOC,DT8.DT8_SERIE,DT8.DT8_VALPAS"
cQuery += " ORDER BY DT8.DT8_FILDOC,DT8.DT8_DOC,DT8.DT8_SERIE"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDT8,.T.,.T.)

TcSetField(cAliasDT8,"DT8_VALPAS","N",TamSX3("DT8_VALPAS")[1],TamSX3("DT8_VALPAS")[2])

While (cAliasDT8)->(!Eof())
	cDocAnt := (cAliasDT8)->DT8_FILDOC + (cAliasDT8)->DT8_DOC + (cAliasDT8)->DT8_SERIE
	Aadd(aRet,{(cAliasDT8)->DT8_FILDOC,(cAliasDT8)->DT8_DOC,(cAliasDT8)->DT8_SERIE,0})
	nValor := 0
	While (cAliasDT8)->(!Eof()) .And. (cAliasDT8)->(DT8_FILDOC + DT8_DOC + DT8_SERIE) == cDocAnt
		nValor += (cAliasDT8)->DT8_VALPAS
		(cAliasDT8)->(DbSkip())
    EndDo
    aRet[Len(aRet),4] := nValor
EndDo

(cAliasDT8)->(DbCloseArea())

DTQ->( dbSetOrder( 1 ) )
DTQ->( MsSeek( xFilial("DTQ") + cViagem ))

If lExbHlp .And. Empty(aRet) .And. DTQ->DTQ_SERTMS != "1"
	Help("",1,"TMSA25302") //-- Não foram encontrados registros para seleção. Verifique se os componentes de frete dos doc.estão marcados como receita igual a SIM.
EndIf
 

AEval(aAreas,{|x,y| RestArea(x) })

Return Aclone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa253Cus ³ Autor ³ Valdemar Roberto  ³ Data ³ 27.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apuração do custo da viagem                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa253Cus(cExp01,cExp02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 := Número da viagem                                 ³±±
±±³          ³ cExp02 := Servico do TMS (1=Coleta / 2=Transf / 3=Entrega) ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa253Cus(cViagem,cSerTms,lMemoria)
Local aAreas    := {GetArea()}
Local aRet      := {}
Local aVetWrk   := {}
Local cQuery    := ""
Local cAliasDUD := ""
Local cFilDoc   := ""
Local cDoc      := ""
Local cSerie    := ""
Local nValor    := 0
Local nValTot   := 0
Local nValVia   := 0
Local nValPE    := 0
Local cAliasDTY := ""

DEFAULT cViagem  := ""
DEFAULT cSerTMS  := ""
DEFAULT lMemoria := .T.

cAliasDUD := GetNextAlias()
cQuery := "SELECT * FROM (SELECT DUD_FILDOC,DUD_DOC,DUD_SERIE,' ' DTC_FILCFS, ' ' DTC_NUMSOL,DJC_VLRCST "
cQuery += "                 FROM " + RetSqlName("DUD") + " DUD "
cQuery += "                 JOIN " + RetSqlName("DJC") + " DJC "
cQuery += "                   ON DJC_FILIAL = '" + xFilial("DJC") + "' "
cQuery += "                  AND DJC_FILDOC = DUD_FILDOC "
cQuery += "                  AND DJC_DOC    = DUD_DOC "
cQuery += "                  AND DJC_SERIE  = DUD_SERIE "
cQuery += "                  AND DJC.D_E_L_E_T_ = ' ' "
cQuery += "                WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
cQuery += "                  AND DUD_VIAGEM = '" + cViagem + "' "
cQuery += "                  AND DUD.D_E_L_E_T_ = ' ' "
If cSerTMS $ "23"
	cQuery += "           UNION "
	cQuery += "          SELECT DISTINCT DUD_FILDOC,DUD_DOC,DUD_SERIE,DTC_FILCFS,DTC_NUMSOL,DJC_VLRCST "
	cQuery += "            FROM " + RetSqlName("DUD") + " DUD "
	cQuery += "            JOIN " + RetSqlName("DTC") + " DTC "
	cQuery += "              ON DTC_FILIAL = '" + xFilial("DTC") + "' "
	cQuery += "             AND DTC_FILDOC = DUD_FILDOC "
	cQuery += "             AND DTC_DOC    = DUD_DOC "
	cQuery += "             AND DTC_SERIE  = DUD_SERIE "
	cQuery += "             AND DTC.D_E_L_E_T_ = ' ' "
	cQuery += "            JOIN " + RetSqlName("DJC") + " DJC "
	cQuery += "              ON DJC_FILIAL = '" + xFilial("DJC") + "' "
	cQuery += "             AND DJC_FILDOC = DTC_FILCFS "
	cQuery += "             AND DJC_DOC    = DTC_NUMSOL "
	cQuery += "             AND DJC_SERIE  = 'COL' "
	cQuery += "             AND DJC.D_E_L_E_T_ = ' ' "
	cQuery += "           WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
	cQuery += "             AND DUD_VIAGEM = '" + cViagem + "' "
	cQuery += "             AND DUD.D_E_L_E_T_ = ' ' "
EndIf
cQuery += "               ) cAliasDUD "
cQuery += " ORDER BY DUD_FILDOC,DUD_DOC,DUD_SERIE"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)

TcSetField(cAliasDUD,"DJC_VLRCST","N",TamSX3("DJC_VLRCST")[1],TamSX3("DJC_VLRCST")[2])

While (cAliasDUD)->(!Eof())
	cFilDoc := (cAliasDUD)->DUD_FILDOC
	cDoc    := (cAliasDUD)->DUD_DOC
	cSerie  := (cAliasDUD)->DUD_SERIE
	nValor  := 0
	While (cAliasDUD)->(!Eof()) .And. (cAliasDUD)->(DUD_FILDOC + DUD_DOC + DUD_SERIE) == cFilDoc + cDoc + cSerie
		nValor  += (cAliasDUD)->DJC_VLRCST
		nValTot += (cAliasDUD)->DJC_VLRCST

		(cAliasDUD)->(DbSkip())
    EndDo
	If nValor > 0
		Aadd(aVetWrk,{cFilDoc,cDoc,cSerie,nValor})
	EndIf
EndDo

(cAliasDUD)->(DbCloseArea())

//+-----------------------------------------------------------------------------
//-- Verifica se existe viagens de coletas que compartilham a mesma receita
//-- e havendo busca o custo dessas viagens.
//+-----------------------------------------------------------------------------
If cSerTms == "1"
		cQuery := " Select DJC.DJC_FILDOC, DJC.DJC_DOC, DJC.DJC_VLRCST From " + RetSqlName("DUD") + " DUD "
		
		cQuery += "  LEFT JOIN " + RetSqlName("DTC") + " DTC " 
		cQuery += "    ON DTC_FILIAL = '" + xFilial("DTC") + "' "
		cQuery += "   AND DTC_FILCFS = DUD.DUD_FILDOC "
		cQuery += "   AND DTC_NUMSOL = DUD.DUD_DOC "
		cQuery += "   AND DTC.D_E_L_E_T_ = ' ' "
        cQuery += "   AND DTC.DTC_DOC <>  ' ' "

        cQuery += " LEFT JOIN " + RetSqlName("DJC") + " DJC ON "
		cQuery += "     DJC.DJC_FILIAL = '" + xFilial("DJC") + "' "
		cQuery += " AND DJC.DJC_FILDOC = DTC.DTC_FILDOC "  
		cQuery += " AND DJC.DJC_DOC    = DTC.DTC_DOC "
		cQuery += " AND DJC.DJC_SERIE  = DTC.DTC_SERIE "
		If !IsInCallStack("TMSA250COM") //-- Quando CTC complementar deve considerar a viagem posicionada no custo.
		   cQuery += " AND DJC.DJC_VIAGEM <> '" + cViagem + "' "
		EndIf
		cQuery += " AND DJC.D_E_L_E_T_ = ' ' "

		cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "   AND DUD.DUD_VIAGEM = '" + cViagem + "' "
		cQuery += "   AND DUD.D_E_L_E_T_ = ' ' "
		cQuery += "   AND DTC.DTC_DOC <>  ' ' "

		cQuery += " GROUP BY DJC.DJC_FILDOC, DJC.DJC_DOC, DJC.DJC_VLRCST "

		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUD,.T.,.T.)

		TcSetField(cAliasDUD,"DJC_VLRCST","N",TamSX3("DJC_VLRCST")[1],TamSX3("DJC_VLRCST")[2])

		While (cAliasDUD)->(!EOF())
				nValor  += (cAliasDUD)->DJC_VLRCST
				nValTot += (cAliasDUD)->DJC_VLRCST

				(cAliasDUD)->(DbSkip())
		EndDo

		//--Se existir Contrato Carreteiro considera o custo
		If nValTot == 0
			nValTot += CustoCTC(cViagem)
		EndIf

EndIf //-- FIM If cSerTms == "1"

// Verifica se busca da variavel de memoria ou da tabela
If lMemoria
	cAliasDTY := "M"
Else
	cAliasDTY := "DTY"
EndIf

If ValType( &(cAliasDTY+"->DTY_VALFRE") ) == "N" .And. ValType( &(cAliasDTY+"->DTY_VALPDG") ) == "N"
	nValVia :=  &(cAliasDTY+"->DTY_VALFRE") + &(cAliasDTY+"->DTY_VALPDG")
EndIf

//-- Permite manipular o valor do custo da viagem
If lTMA253Val
	nValPE := ExecBlock("TMA253Val",.F.,.F.,{nValVia})
	If ValType(nValPE) != "N"
		nValPE := nValVia
	Endif
	nValVia := nValPE
EndIf

Aadd(aRet,{nValVia,nValTot,Aclone(aVetWrk)})

AEval(aAreas,{|x,y| RestArea(x) })

Return Aclone(aRet)
//========================================================================================================
/*/{Protheus.doc} CustoCTC
	(long_description)
	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return returno,return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function CustoCTC(cViagem)
Local nResult   := 0
Local cQuery    := ""
Local cDTCAlias := GetNextAlias()
Local cLote     := ""
Local cFilOri   := ""
Local nQtdeLote := 0

		cQuery := "SELECT DTC.DTC_FILORI,DTC.DTC_LOTNFC "
		cQuery += " FROM " + RetSqlName("DUD") + " DUD "

		cQuery += " LEFT JOIN " + RetSqlName("DTC") + " DTC ON "
		cQuery += " DTC.D_E_L_E_T_ = ' ' "
		cQuery += " AND DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
		cQuery += " AND DTC.DTC_FILCFS = DUD.DUD_FILDOC "
		cQuery += " AND DTC.DTC_NUMSOL = DUD.DUD_DOC "
		cQuery += " AND DTC.DTC_DOC  <> ' ' "

		cQuery += " WHERE DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += " AND DUD.DUD_VIAGEM = '" + cViagem + "' "
		cQuery += " AND DUD.DUD_SERTMS = '1' "
		cQuery += " AND DUD.D_E_L_E_T_ = ' ' "

		cQuery += " GROUP BY DTC.DTC_FILORI,DTC.DTC_LOTNFC "

        DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cDTCAlias,.T.,.F.)
        
		If (cDTCAlias)->(!EOF())
           (cDTCAlias)->(DbEval({|| nQtdeLote++,cFilori := DTC_FILORI,cLote := DTC_LOTNFC })) //-- Verifica se  há mais de 1 lote vinculados da viagem de coleta
	    EndIf
		(cDTCAlias)->(DbCloseArea())

        //-- Verifica se há outras viagens de coleta vinculadas ao lote aglutinado.
		If nQtdeLote == 1
			
			cQuery := "SELECT DUD.DUD_FILORI,DUD_VIAGEM "
			cQuery += "FROM " + RetSqlName("DTC") + " DTC "

			cQuery += "INNER JOIN " + RetSqlName("DUD") + " DUD ON "
			cQuery += "    DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
			cQuery += "AND DUD.D_E_L_E_T_ = ' ' "
			cQuery += "AND DUD.DUD_FILDOC = DTC.DTC_FILCFS "
			cQuery += "AND DUD.DUD_DOC    = DTC.DTC_NUMSOL "
			cQuery += "AND DUD.DUD_SERIE  = 'COL' "
			cQuery += "AND DUD.DUD_VIAGEM <> '" + cViagem + "' "

			cQuery += "WHERE DTC.DTC_FILIAL = '" + xFilial("DTC") + "' "
			cQuery += "AND DTC.D_E_L_E_T_ = ' ' "
			cQuery += "AND DTC.DTC_FILORI = '" + cFilOri + "' "
			cQuery += "AND DTC.DTC_LOTNFC = '" + cLote   + "' "
			cQuery += "AND DTC.DTC_DOC <> ' ' "
            cQuery += " GROUP BY DUD.DUD_FILORI,DUD.DUD_VIAGEM "

            cQuery := ChangeQuery(cQuery)

			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cDTCAlias,.T.,.F.)

			While (cDTCAlias)->(!EOF())
				
				DTY->(DbSetOrder(2))
				If DTY->(MsSeek(xFilial("DTY") + (cDTCAlias)->(DUD_FILORI+DUD_VIAGEM)))
					nResult += DTY->DTY_VALFRE + DTY->DTY_VALPDG
				EndIf
				(cDTCAlias)->(DbSkip())
			EndDo
			(cDTCAlias)->(DbCloseArea())

		EndIf

Return nResult


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa253Grv ³ Autor ³ Valdemar Roberto  ³ Data ³ 31.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gravação do rateio do frete a pagar                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa253Grv(nExp01,nExp02,aExp01,cExp01,cExp02,cExp03)      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄaResultÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp01 := Receita da viagem                                ³±±
±±³          ³ nExp02 := Custo da viagem                                  ³±±
±±³          ³ aExp01 := Vetor com os documentos da viagem                ³±±
±±³          ³ cExp01 := Filial de origem da viagem                       ³±±
±±³          ³ cExp02 := Numero da viagem                                 ³±±
±±³          ³ cExp03 := Numero do contrato carreteiro                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa253Grv(nRecVia,nCusVia,aVetDoc,cFilOri,cViagem,cNumCtc)
Local aAreas   := {DJC->(GetArea()),GetArea()}
Local nValRat  := 0
Local nPerRat  := 0
Local nTotRat  := 0
Local nTotPer  := 0
Local nCntFor1 := 0

DEFAULT nRecVia := 0
DEFAULT nCusVia := 0
DEFAULT aVetDoc := {}
DEFAULT cFilOri := ""
DEFAULT cViagem := ""
DEFAULT cNumCtc := ""

If nRecVia > 0 .And. nCusVia > 0 .And. !Empty(aVetDoc)
	For nCntFor1 := 1 To Len(aVetDoc)
		If nCntFor1 == Len(aVetDoc)
			nPerRat := 100 - nTotPer
			nValRat := nCusVia - nTotRat
		Else
			nPerRat := Round((aVetDoc[nCntFor1,4] * 100) / nRecVia,2)
			nTotPer += nPerRat
			nValRat := Round((nPerRat * nCusVia) / 100,2)
			nTotRat += nValRat
		EndIf
		If nValRat > 0
			RecLock("DJC",.T.)
			DJC->DJC_FILIAL := xFilial("DJC")
			DJC->DJC_FILDOC := aVetDoc[nCntFor1,1]
			DJC->DJC_DOC    := aVetDoc[nCntFor1,2]
			DJC->DJC_SERIE  := aVetDoc[nCntFor1,3]
			DJC->DJC_FILORI := cFilOri
			DJC->DJC_VIAGEM := cViagem
			DJC->DJC_VLRCST := nValRat
			DJC->DJC_PERRAT := nPerRat
			DJC->DJC_NUMCTC := cNumCtc			
			If DJC->(ColumnPos("DJC_VLRRCT")) > 0 
				DJC->DJC_VLRRCT	:= aVetDoc[nCntFor1,4]
			EndIf			
			DJC->(MsUnlock())
		EndIf
	Next nCntFor1
EndIf

AEval(aAreas,{|x,y| RestArea(x) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Tmsa253Exc ³ Autor ³ Valdemar Roberto  ³ Data ³ 31.03.2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exclusão do rateio do frete a pagar                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tmsa253Exc(cExp01,cExp02,cExp03)                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp01 := Numero do contrato carreteiro                    ³±±
±±³          ³ cExp02 := Filial de origem da viagem                       ³±±
±±³          ³ cExp03 := Numero da viagem                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Tmsa253Exc(cNumCtc,cFilOri,cViagem)
Local aAreas    := {DJC->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasDJC := ""

DEFAULT cNumCtc := ""
DEFAULT cFilOri := ""
DEFAULT cViagem := ""

cAliasDJC := GetNextAlias()
cQuery := "SELECT DJC.R_E_C_N_O_ REGISTRO "
cQuery += "  FROM " + RetSqlName("DJC") + " DJC "
cQuery += " WHERE DJC_FILIAL = '" + xFilial("DJC") + "' "
cQuery += "   AND DJC_NUMCTC = '" + cNumCtc + "' "
cQuery += "   AND DJC_FILORI = '" + cFilOri + "' "
cQuery += "   AND DJC_VIAGEM = '" + cViagem + "' "
cQuery += "   AND DJC.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDJC,.T.,.T.)

While (cAliasDJC)->(!Eof())
	DJC->(DbGoTo((cAliasDJC)->REGISTRO))
	RecLock("DJC",.F.)
	DJC->(DbDelete())
	DJC->(MsUnlock())
	(cAliasDJC)->(DbSkip())
EndDo

(cAliasDJC)->(DbCloseArea())

AEval(aAreas,{|x,y| RestArea(x) })

Return

