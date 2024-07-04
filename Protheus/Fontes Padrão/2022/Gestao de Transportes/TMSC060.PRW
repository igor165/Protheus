#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSC060.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMSC060  ³ Autor ³ Eduardo de Souza      ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta Veiculos/Motoristas                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSC060                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsC060()

Local nTop    := 0
Local nLeft   := 0
Local nBottom := 0
Local nRight  := 0
Local nOpcA	  := 0
Local oDlg
Local oMenu
Local oOpc
Local oFont
Local oPanel
Local aEnch[3]
Local aButtons := { {"CARGA", { || TMC060Viag() }, STR0001 , STR0001 }} // "Viagem"
Local aSizeAut	:= MsAdvSize( .F. )

Private oTree
Private cCadastro	:= STR0002 // "Consulta Posição de Veículo/Motorista"
Private aObj		:= {}  

nTop    := aSizeAut[7]
nLeft   := 01
nBottom := aSizeAut[6]
nRight  := aSizeAut[5]

Inclui := .F.

If Pergunte("TMC060",.T.)
	DEFINE FONT oFont NAME "Arial" SIZE 0, -10
	DEFINE MSDIALOG oDlg TITLE cCadastro OF oMainWnd PIXEL FROM nTop,nLeft TO nBottom,nRight
	
	oPanel := TPanel():New(35,160,'',oDlg, oDlg:oFont, .T., .T.,, ,(nRight-nLeft)/2-160,((nBottom-nTop)/2)-25,.T.,.T. )
	
	oTree := DbTree():New(35, 2,((nBottom-nTop)/2)-5,159,oDlg,,,.T.)
	oTree:LShowHint := .F.
	oTree:oFont := oFont
	oTree:bChange := {|| TMC060MTela(aEnch,@oPanel,{ 0,0,((nBottom-nTop)/2)-24,(nRight-nLeft)/2-160}) }
	
	//-- Veiculos
	RegToMemory("DA3",.F.)
	aEnch[1]:=MsMGet():New("DA3",DA3->(RecNo()),2,,,,,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,.F.)
	aEnch[1]:Hide()
	//-- Motoristas
	RegToMemory("DA4",.F.)
	aEnch[2]:=MsMGet():New("DA4",DA4->(RecNo()),2,,,,,{0,0,((nBottom-nTop)/2)-25,(nRight-nLeft)/2-160},,3,,,,oPanel,,.F.)

	aEnch[2]:Hide()
	//-- Chama a rotina de construcao do Tree
	Processa( { || TMC060Monta() }, , STR0003 ) // "Construindo Estrutura..."
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() }, {|| oDlg:End() },, aButtons ) CENTERED
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMC060Monta³ Autor ³ Eduardo de Souza     ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto Tree                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMC060Monta()

Local aAreaAnt	:= GetArea()

ProcRegua(DA3->(LastRec()))

TMC060MonGr("MAINGR")

RestArea(aAreaAnt)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMC060MonGr³ Autor ³ Eduardo de Souza     ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta o tree                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 																			  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMC060MonGr()

Local aArea      := GetArea()
Local aAreaSM0   := SM0->(GetArea())
Local cAliasQry  := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local cQuery     := ""
Local cBmp       := ""
Local lDTQ       := .F.
Local cFilAtu    := ""
Local lContVei   := SuperGetMv("MV_CONTVEI",,.F.)
Local cFilUsado  := ""
Local cVgeUsado  := ""
Local aViagVei	 := {} //--Viagens do veículo
Local nCountViag := 0
Local nCountMot	 := 0
Local cNomeReduz := ''
Local cFilOriOld := ''
Local cViagemOld := ''

If mv_par05 == 1

	oTree:AddTree(Padr(STR0004,100),.T.,,,"RPMNEW","RPMNEW",Space(15)) // "Veículos"

	cQuery := " SELECT DA3_FILIAL, DA3_COD, DA3_DESC, DA3_PLACA, DA3_FILVGA, DA3_NUMVGA, DA3_FILATU, DA3.R_E_C_N_O_ DA3REC "
	cQuery += "    FROM " + RetSqlName("DA3") + " DA3 "
	cQuery += "    WHERE DA3_FILIAL = '" + xFilial("DA3") + "' "
	cQuery += "      AND DA3_COD BETWEEN '" + mv_par01 + "' AND '" + mv_par02 + "' "
	cQuery += "      AND DA3.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DA3_FILIAL, DA3_COD "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry2, .F., .T.)
	While (cAliasQry2)->(!Eof())
		IncProc()
		//-- Posiciona na viagem para pegar o recno.
		If lContVei
			cFilUsado := (cAliasQry2)->DA3_FILVGA
			cVgeUsado := (cAliasQry2)->DA3_NUMVGA
			lDTQ := !Empty(Posicione("DTQ",2,xFilial("DTQ")+cFilUsado+cVgeUsado,"DTQ_ROTA"))
		Else
			lDTQ := !TMSEmViag(,,(cAliasQry2)->DA3_COD,1,.F.,@cFilUsado,@cVgeUsado)
			If lDTQ
				//Retorna Todas as viagens do veículo já que o mesmo, poderá estar em mais de uma viagem
				aViagVei := TM060ViagV((cAliasQry2)->DA3_COD)				
			EndIf
		EndIf
		If Len(aViagVei) > 0
			For nCountViag := 1 To Len(aViagVei)
				//-- Filtra Motorista
				//-- Veiculo
				cFilAtu := Posicione("SM0",1,cEmpAnt+(cAliasQry2)->DA3_FILATU,"M0_FILIAL")
				If nCountViag == 1
					oTree:AddTree((cAliasQry2)->DA3_COD + " - " + AllTrim((cAliasQry2)->DA3_DESC) + " - " + Alltrim((cAliasQry2)->DA3_PLACA) + STR0029 + cFilAtu,.T.,,,"","","DA3"+StrZero((cAliasQry2)->DA3REC,12),.T.)  // " - Filial: "
				EndIf					

				//-- Viagem
				If lDTQ .And.  (cFilOriOld+cViagemOld) <> aViagVei[nCountViag,1]+aViagVei[nCountViag,2]
					If aViagVei[nCountViag,3] == StrZero(1,Len(DTQ->DTQ_STATUS))
						cBmp := "BR_VERDE"
					ElseIf aViagVei[nCountViag,3] == StrZero(2,Len(DTQ->DTQ_STATUS))
						cBmp := "BR_AMARELO_OCEAN"
					ElseIf aViagVei[nCountViag,3] == StrZero(3,Len(DTQ->DTQ_STATUS))
						cBmp := "BR_AZUL"
					ElseIf aViagVei[nCountViag,3] == StrZero(4,Len(DTQ->DTQ_STATUS))
						cBmp := "BR_LARANJA_OCEAN"
					ElseIf aViagVei[nCountViag,3] == StrZero(5,Len(DTQ->DTQ_STATUS))
						cBmp := "BR_VERMELHO"
					ElseIf aViagVei[nCountViag,3] == StrZero(9,Len(DTQ->DTQ_STATUS))
						cBmp := "BR_PRETO_OCEAN"
					EndIf	
					
					Posicione('DTQ',2,FWxFilial('DTQ')+aViagVei[nCountViag,1]+aViagVei[nCountViag,2],"DTQ_ROTA")					
					oTree:AddTreeItem(STR0005+ aViagVei[nCountViag,1] + " - " + aViagVei[nCountViag,2] ,cBmp,cBmp,"DTQ"+StrZero(DTQ->(Recno()),12)) // "Viagem: "
					cViagemOld := aViagVei[nCountViag,2]
					cFilOriOld := aViagVei[nCountViag,1]
				EndIf

				//-- Motoristas					
				oTree:AddTree(STR0006,.T.,,,"BMPUSER","BMPUSER","DA3"+StrZero(0,12)) // "Motoristas"
				For nCountMot := 1 To Len(aViagVei[nCountViag,4])							
					If (aViagVei[nCountViag,4,nCountMot] >= mv_par03 .And. aViagVei[nCountViag,4,nCountMot] <= mv_par04)
						cNomeReduz := Posicione('DA4',1,FWxFilial('DA4')+aViagVei[nCountViag,4,nCountMot],"DA4_NREDUZ")						
						oTree:AddTreeItem(aViagVei[nCountViag,4,nCountMot] + " - " + cNomeReduz ,"","","DA4"+StrZero(DA4->(RECNO()),12))
					EndIf
				Next nCountMot				
				oTree:EndTree()				
			Next
		EndIf		

		oTree:EndTree()
		(cAliasQry2)->(DbSkip())
	EndDo
Else

	oTree:AddTree(Padr(STR0006,100),.T.,,,"BMPUSER","BMPUSER",Space(15)) // "Motoristas"

	cQuery := " SELECT DA4_FILIAL, DA4_COD, DA4_NREDUZ, DA4.R_E_C_N_O_ DA4REC "
	cQuery += "    FROM " + RetSqlName("DA4") + " DA4 "
	cQuery += "    WHERE DA4_FILIAL = '" + xFilial("DA4") + "' "
	cQuery += "      AND DA4_COD BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' "
	cQuery += "      AND DA4.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY DA4_FILIAL, DA4_COD "
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry2, .F., .T.)
	While (cAliasQry2)->(!Eof())
		IncProc()

		cQuery := " SELECT DA3_FILIAL, DA3_COD, MAX(DA3_DESC) DA3_DESC, MAX(DA3_PLACA) DA3_PLACA, MAX(DA3_FILVGA) DA3_FILVGA, MAX(DA3_NUMVGA) DA3_NUMVGA, MAX(DA3.R_E_C_N_O_) DA3REC "
		cQuery += "    FROM " + RetSqlName("DA3") + " DA3 "
		cQuery += "    JOIN " + RetSqlName("DUP") + " DUP "
		cQuery += "      ON DUP_FILIAL = '" + xFilial("DUP") + "' "
		cQuery += "      AND DUP_FILORI = DA3_FILVGA "
		cQuery += "      AND DUP_VIAGEM = DA3_NUMVGA "
		cQuery += "      AND DUP_CODVEI = DA3_COD "
		cQuery += "      AND DUP_CODMOT = '" + (cAliasQry2)->DA4_COD + "' "
		cQuery += "      AND DUP.D_E_L_E_T_ = ' ' "
		cQuery += "    WHERE DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "      AND DA3.D_E_L_E_T_ = ' ' "
		cQuery += " GROUP BY DA3_FILIAL, DA3_COD "
		cQuery += " ORDER BY DA3_FILIAL, DA3_COD "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		//-- Filtra Motorista
		If (cAliasQry)->(!Eof())
			If !((cAliasQry)->DA3_COD >= mv_par01 .And. (cAliasQry)->DA3_COD <= mv_par02)
				(cAliasQry2)->(DbSkip())
				(cAliasQry)->(DbCloseArea())
				Loop
			EndIf
		EndIf
	
		//-- Posiciona na viagem para pegar o recno.
		If lContVei
			cFilUsado := (cAliasQry)->DA3_FILVGA
			cVgeUsado := (cAliasQry)->DA3_NUMVGA
			lDTQ := !Empty(Posicione("DTQ",2,xFilial("DTQ")+cFilUsado+cVgeUsado,"DTQ_ROTA"))
		Else
			lDTQ := !TMSEmViag(,,(cAliasQry2)->DA4_COD,2,.F.,@cFilUsado,@cVgeUsado)
			If lDTQ
				DTQ->( DbSetOrder(2) )
				DTQ->( DbSeek( xFilial('DTQ') + cFilUsado + cVgeUsado ) ) 
			EndIf
		EndIf

		//-- Motoristas
		aDTOMot := TMSUltDTO((cAliasQry2)->DA4_COD)
		cFilAtu := ""
		If !Empty(aDTOMot)
			cFilAtu := aDTOMot[1,1]
			If ValType(cFilAtu) <> "C"
				cFilAtu := ""
			Else
				cFilAtu := Posicione("SM0",1,cEmpAnt+cFilAtu,"M0_FILIAL")
			EndIf
		EndIf		

		oTree:AddTree((cAliasQry2)->DA4_COD + " - " + (cAliasQry2)->DA4_NREDUZ + STR0029 + cFilAtu,.T.,,,"","","DA4"+StrZero((cAliasQry2)->DA4REC,12)) // " - Filial: "

		//-- Viagem
		If lDTQ
			If DTQ->DTQ_STATUS == StrZero(1,Len(DTQ->DTQ_STATUS))
				cBmp := "BR_VERDE"
			ElseIf DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
				cBmp := "BR_AMARELO_OCEAN"
			ElseIf DTQ->DTQ_STATUS == StrZero(3,Len(DTQ->DTQ_STATUS))
				cBmp := "BR_AZUL"
			ElseIf DTQ->DTQ_STATUS == StrZero(4,Len(DTQ->DTQ_STATUS))
				cBmp := "BR_LARANJA_OCEAN"
			ElseIf DTQ->DTQ_STATUS == StrZero(5,Len(DTQ->DTQ_STATUS))
				cBmp := "BR_VERMELHO"
			ElseIf DTQ->DTQ_STATUS == StrZero(9,Len(DTQ->DTQ_STATUS))
				cBmp := "BR_PRETO_OCEAN"
			EndIf	
			oTree:AddTreeItem(STR0005+ cFilUsado + " - " + cVgeUsado ,cBmp,cBmp,"DTQ"+StrZero(DTQ->(Recno()),12)) // "Viagem: "
		EndIf

		//-- Veiculos
		If (cAliasQry)->(!Eof())	
			oTree:AddTree(STR0004,.T.,,,"RPMNEW","RPMNEW","DA4"+StrZero(0,12)) // "Veiculos"
			While (cAliasQry)->(!Eof())	
				oTree:AddTreeItem((cAliasQry)->DA3_COD + " - " + AllTrim((cAliasQry)->DA3_DESC) + " - " + Alltrim((cAliasQry)->DA3_PLACA),"","","DA3"+StrZero((cAliasQry)->DA3REC,12))
			   (cAliasQry)->(DbSkip())
			EndDo
			oTree:EndTree()
		EndIf
		(cAliasQry)->(DbCloseArea())
		oTree:EndTree()
		(cAliasQry2)->(DbSkip())
	EndDo

EndIf
oTree:EndTree()	

RestArea(aAreaSM0)
RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMC060MTela³ Autor ³ Eduardo de Souza     ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Apresenta Tela                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSC060              												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMC060MTela(aEnch,oPanel,aPos)

Local oScroll
Local cAlias	 := SubStr(oTree:GetCargo(),1,3)
Local nRecView	 := Val(SubStr(oTree:GetCargo(),4,12))
Local nEnc      := 0
Local nCnt      := 0
Local aDados    := {}
Local cAliasQry := ""
Local cQuery    := ""
Local cStatus   := ""
Local aArea     := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

//-- Esconde as enchoices
For nCnt := 1 To Len(aEnch)
	If ValType(aEnch[nCnt]) == "O"
		aEnch[nCnt]:Hide()
	EndIf
Next nCnt

If nRecView <> 0
	dbSelectArea(cAlias)
	MsGoto(nRecView)
	If cAlias == "DTQ"

		cTipTra := DTQ->DTQ_TIPTRA
		cSerTms := DTQ->DTQ_SERTMS

		//-- Esse array contem as descricoes existentes no ComboBox
		aRetBox := RetSx3Box( Posicione('SX3', 2, 'DTQ_STATUS', 'X3CBox()' ),,, Len(DTQ->DTQ_STATUS) )
		cStatus := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == DTQ->DTQ_STATUS } ), 3 ])

		Aadd(aDados,{STR0007,"",{{1,CLR_RED}} }) // "Informações da Viagem"
		Aadd(aDados,{Padr(STR0008,60),AllTrim(DTQ->DTQ_ROTA) + " - " + Posicione("DA8",1,xFilial("DA8")+DTQ->DTQ_ROTA,"DA8_DESC")}) // "Rota: "
		Aadd(aDados,{Padr(STR0009,56),DToC(DTQ->DTQ_DATGER) + " - " + Transform(DTQ->DTQ_HORGER,PesqPict("DTQ","DTQ_HORGER")) }) // "Geração: "
		Aadd(aDados,{Padr(STR0010,50),TMSValField("DTQ->DTQ_SERTMS",.F.,"DC5_DESSER") }) // "Serv. Transporte: " 
		Aadd(aDados,{Padr(STR0011,50),TMSValField("DTQ->DTQ_TIPTRA",.F.,"DC5_DESTPT") }) // "Tipo  Transporte: "

		//-- Totais de Documentos na Viagem
		cAliasQry := GetNextAlias()
		cQuery := " SELECT COUNT(DT6_FILIAL) QTDDOC, SUM(DT6_QTDVOL) QTDVOL, SUM(DT6_PESO) PESO, "
		cQuery += "   		  SUM(DT6_PESOM3) PESOM3, SUM(DT6_VALMER) VALMER "
		cQuery += "   FROM " + RetSqlName("DUD") + " DUD "
		cQuery += "   JOIN " + RetSqlName("DT6") + " DT6 "
		cQuery += "     ON  DT6_FILIAL = '" + xFilial("DT6") + "' "
		cQuery += "     AND DT6_FILDOC = DUD_FILDOC "
		cQuery += "     AND DT6_DOC    = DUD_DOC "
		cQuery += "     AND DT6_SERIE  = DUD_SERIE "
		cQuery += "     AND DT6.D_E_L_E_T_ = ' ' "
		cQuery += "   WHERE DUD_FILIAL = '" + xFilial("DUD") + "' "
		cQuery += "     AND DUD_FILORI = '" + DTQ->DTQ_FILORI + "' "
		cQuery += "     AND DUD_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
		cQuery += "     AND DUD.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			Aadd(aDados,{Padr(STR0012,44),Transform((cAliasQry)->QTDDOC,"@E 9999")}) // "Qtde Documentos: "
			Aadd(aDados,{Padr(STR0013,53),Transform((cAliasQry)->QTDVOL,PesqPict("DT6","DT6_QTDVOL")) }) // "Volumes: "
			Aadd(aDados,{Padr(STR0014,53),Transform((cAliasQry)->PESO  ,PesqPict("DT6","DT6_PESO"  )) }) // "Peso Real: "
			Aadd(aDados,{Padr(STR0015,49),Transform((cAliasQry)->PESOM3,PesqPict("DT6","DT6_PESOM3")) }) // "Peso Cubado: "
			Aadd(aDados,{Padr(STR0016,40),Transform((cAliasQry)->VALMER,PesqPict("DT6","DT6_VALMER")) }) // "Valor Mercadorias: "
		EndIf
		(cAliasQry)->(DbCloseArea())
		Aadd(aDados,{Padr(STR0017,59),cStatus}) // "Status: "

		//-- Veiculos
		Aadd(aDados,{"",""})
		cQuery := " SELECT DTR_CODVEI CODVEI, DA3A.DA3_DESC DESVEI, DA3A.DA3_PLACA PLACAVEI, "
		cQuery += " DTR_CODRB1 CODRB1, DA3B.DA3_DESC DESRB1, DA3B.DA3_PLACA PLACARB1, "
		cQuery += " DTR_CODRB2 CODRB2, DA3C.DA3_DESC DESRB2, DA3C.DA3_PLACA PLACARB2 "
		If lTercRbq
			cQuery += ", DTR_CODRB3 CODRB3, DA3D.DA3_DESC DESRB3, DA3D.DA3_PLACA PLACARB3 "
		EndIf
		cQuery += "   FROM " + RetSqlName("DTR") + " DTR "
		cQuery += "   JOIN " + RetSqlName("DA3") + " DA3A "
		cQuery += "     ON DA3A.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "     AND DA3A.DA3_COD = DTR_CODVEI "
		cQuery += "     AND DA3A.D_E_L_E_T_ = ' ' "
		cQuery += "   LEFT JOIN " + RetSqlName("DA3") + " DA3B "
		cQuery += "     ON DA3B.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "     AND DA3B.DA3_COD = DTR_CODRB1 "
		cQuery += "     AND DA3B.D_E_L_E_T_ = ' ' "
		cQuery += "   LEFT JOIN " + RetSqlName("DA3") + " DA3C "
		cQuery += "     ON DA3C.DA3_FILIAL = '" + xFilial("DA3") + "' "
		cQuery += "     AND DA3C.DA3_COD = DTR_CODRB2 "
		cQuery += "     AND DA3C.D_E_L_E_T_ = ' ' "
		If lTercRbq
			cQuery += "   LEFT JOIN " + RetSqlName("DA3") + " DA3D "
			cQuery += "     ON DA3D.DA3_FILIAL = '" + xFilial("DA3") + "' "
			cQuery += "     AND DA3D.DA3_COD = DTR_CODRB3 "
			cQuery += "     AND DA3D.D_E_L_E_T_ = ' ' "
		EndIf
		cQuery += "   WHERE DTR_FILIAL = '" + xFilial("DTR") + "' "
		cQuery += "     AND DTR_FILORI = '" + DTQ->DTQ_FILORI + "' "
		cQuery += "     AND DTR_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
		cQuery += "     AND DTR.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		If (cAliasQry)->(!Eof())
			Aadd(aDados,{STR0018,"",{{1,CLR_RED}} }) // "Veículos da Viagem"
			While (cAliasQry)->(!Eof())
				Aadd(aDados,{Padr(STR0019,58),(cAliasQry)->CODVEI + " - " + AllTrim((cAliasQry)->DESVEI) + " - " + (cAliasQry)->PLACAVEI }) // "Veículo:"
				If !Empty((cAliasQry)->CODRB1)
					Aadd(aDados,{Padr(STR0020,53),(cAliasQry)->CODRB1 + " - " + AllTrim((cAliasQry)->DESRB1) + " - " + (cAliasQry)->PLACARB1 }) // "1o Reboque:"
				EndIf
				If !Empty((cAliasQry)->CODRB2)
					Aadd(aDados,{Padr(STR0021,53),(cAliasQry)->CODRB2 + " - " + AllTrim((cAliasQry)->DESRB2) + " - " + (cAliasQry)->PLACARB2 }) // "2o Reboque:"
				EndIf
				If lTercRbq
					If !Empty((cAliasQry)->CODRB3)
						Aadd(aDados,{Padr(STR0030,53),(cAliasQry)->CODRB3 + " - " + AllTrim((cAliasQry)->DESRB3) + " - " + (cAliasQry)->PLACARB3 }) // "3o Reboque:"
					EndIf
				EndIf
				(cAliasQry)->(DbSkip())
			EndDo
			Aadd(aDados,{"",""})
		EndIf
		(cAliasQry)->(DbCloseArea())

		//-- Operacoes
		cQuery := " SELECT DTW_FILIAL, DTW_DATINI, DTW_HORINI, DTW_DATPRE, DTW_HORPRE, DTW_DATREA, DTW_HORREA, "
		cQuery += "        DTW_ATIVID, DTW_FILATI, DTW_STATUS "
		cQuery += "   FROM " + RetSqlName("DTW") + " DTW "
		cQuery += "   WHERE DTW_FILIAL = '" + xFilial("DTW") + "' "
		cQuery += "     AND DTW_FILORI = '" + DTQ->DTQ_FILORI + "' "
		cQuery += "     AND DTW_VIAGEM = '" + DTQ->DTQ_VIAGEM + "' "
		cQuery += "     AND DTW.D_E_L_E_T_ = ' ' "
		cQuery += "     ORDER BY DTW_FILIAL, DTW_SEQUEN "
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

		TCSetField(cAliasQry,"DTW_DATINI","D",8,0)
		TCSetField(cAliasQry,"DTW_DATPRE","D",8,0)
		TCSetField(cAliasQry,"DTW_DATREA","D",8,0)

		If (cAliasQry)->(!Eof())
			Aadd(aDados,{STR0022,"",{{1,CLR_RED}} }) // "Operações da Viagem"
			While (cAliasQry)->(!Eof())
				//-- Esse array contem as descricoes existentes no ComboBox
				aRetBox := RetSx3Box( Posicione('SX3', 2, 'DTW_STATUS', 'X3CBox()' ),,, Len(DTQ->DTQ_STATUS) )
				cStatus := AllTrim( aRetBox[ Ascan( aRetBox, { |x| x[ 2 ] == (cAliasQry)->DTW_STATUS } ), 3 ])
				Aadd(aDados,{Padr(STR0023,56),Tabela("L3",(cAliasQry)->DTW_ATIVID,.F.) }) // "Atividade: "
				Aadd(aDados,{Padr(STR0024,56),DToC((cAliasQry)->DTW_DATINI) + " - " + Transform((cAliasQry)->DTW_HORINI,PesqPict("DTW","DTW_HORINI")) }) // "Data Inicio: "
				Aadd(aDados,{Padr(STR0025,52),DToC((cAliasQry)->DTW_DATPRE) + " - " + Transform((cAliasQry)->DTW_HORPRE,PesqPict("DTW","DTW_HORPRE")) }) // "Data Previsão: "
				Aadd(aDados,{Padr(STR0026,52),DToC((cAliasQry)->DTW_DATREA) + " - " + Transform((cAliasQry)->DTW_HORREA,PesqPict("DTW","DTW_HORREA")) }) // "Data Realizada: "
				Aadd(aDados,{Padr(STR0027,54),(cAliasQry)->DTW_FILATI + " - " + Posicione("SM0",1,cEmpAnt+(cAliasQry)->DTW_FILATI,"M0_FILIAL") }) // "Fil. Atividade: "
				Aadd(aDados,{Padr(STR0017,58),cStatus })
				Aadd(aDados,{"",""})
				(cAliasQry)->(DbSkip())
			EndDo
		EndIf
		(cAliasQry)->(DbCloseArea())

		TMC060ScrDisp(aDados,@oScroll,@oPanel,aPos,{{1,CLR_BLUE}})
		aEnch[3]:=oScroll
		aEnch[3]:Show()
	Else
		RegtoMemory(cAlias,.F.)
		If cAlias == "DA3"
			nEnc:= 1
		ElseIf cAlias == "DA4"
			nEnc:= 2
		EndIf
		aEnch[nEnc]:Refresh(.T.)
		aEnch[nEnc]:Show()
	EndIf
EndIf

RestArea( aAreaSM0 )
RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMC060ScrDisp³ Autor ³Eduardo de Souza     ³ Data ³ 14-06-06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta scroll box com texto dinamico                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMC060ScrDisp(ExpA1,ExpO1,ExpO2,ExpA2,ExpA3,ExpA4)      	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 = Array das informacoes		                          ³±±
±±³          ³ ExpO1 = Obj scroll		 			                          ³±±
±±³          ³ ExpO2 = Obj do Painel	 			                          ³±±
±±³          ³ ExpA2 = Array do aPos			                 			     ³±±
±±³          ³ ExpA3 = Array de Cores (Cols) 		        OPC      		  ³±±
±±³          ³ ExpA4 = Array de Cores (Lines)	            OPC  			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMC060ScrDisp(aInfo,oScroll,oPanel,aPos,aCoresCols,aCoresLines)

Local nX,ny,nAchou
Local cCor,cCorDefault:=CLR_BLACK
Local nCols   :=1,nSomaCols:=0
Local nLinAtu := 5
Local nColAtu := 0
Local nColIni := 0
Local oBmp
Default aCoresCols:={}
Default aCoresLines:={}

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

If Len(aInfo) > 0
	oScroll:= TScrollBox():New(oPanel,aPos[1],aPos[2],aPos[3],aPos[4])
	nCols:=2
	For nx := 1 to Len(aInfo)
		For ny := 1 to nCols
			If CalcFieldSize("C",Len(aInfo[nx,ny]),0) > nSomaCols
				nSomaCols:=CalcFieldSize("C",Len(aInfo[nx,ny]),0)
			EndIf	
		Next ny
	Next
	ny := 1
	For nx := 1 to Len(aInfo)
		nAchou  := Ascan(aCoresLines,{|x| x[1]== nx})
		If nAchou > 0
			cCor:=aCoresLines[nAchou,2]			
		Else
			cCor:=cCorDefault			 	
		EndIf
		If Len(aInfo[nx]) > 2
			nAchou  := Ascan(aInfo[nx][3],{|x| x[1]== ny})
			If nAchou > 0
				cCor:=aInfo[nx][3][nAchou,2]
			EndIf
		EndIf
		If nAchou == 0
			nAchou  := Ascan(aCoresCols,{|x| x[1]== ny})
			If nAchou > 0
				cCor:=aCoresCols[nAchou,2]			
			EndIf
		EndIf
		cTextSay:= "{||' "+STRTRAN(aInfo[nx][1] + aInfo[nx][2],"'",'"')+" '}"
		oSay    := TSay():New(nLinAtu,nColAtu,MontaBlock(cTextSay),oScroll,,oFont,,,,.T.,cCor,,,,,,,,)
		nLinAtu += 9
	Next
EndIf

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMC060Viag³ Autor ³ Eduardo de Souza      ³ Data ³ 13/06/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Visualiza Viagem                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMC060Viag                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSC060                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMC060Viag()

//--Variaveis utilizadas na rotina de viagem Modelo 2
Private cFiltro    := ''
Private cSerTms    := ""
Private cTipTra    := ""
Private aIndex     := {}                          
Private bFiltraBrw := {|| }
Private lLocaliz   := GetMv('MV_LOCALIZ') == 'S'  
Private aRotina    := {}

SaveInter()
cCadastro := STR0028 // "Viagem"
aRotina   := { { "",'TmsXPesqui'	,0,1},; //'Pesquisar'
				  { "",'TMSA144Mnt'	,0,2},; //'Visualizar'
				  { "",'TMSA144Mnt'	,0,3},; //'Incluir'
				  { "",'TMSA144Mnt'	,0,4},; //'Alterar'
				  { "",'TMSA144Mnt'	,0,5},; //'Excluir'
				  { "",'TMSA140Leg'	,0,6} } //'Legenda'

If SubStr(oTree:GetCargo(),1,3) == "DTQ"
	TMSA144Mnt( "DTQ", DTQ->(Recno()),2)
EndIf

RestInter()

Return

//-------------------------------------------------------------------
/*TM060ViagV
Retorna as viagens do Veiculo

@author  Leandro Paulino
@since   13/08/2019
@version 1.0
*/
//-------------------------------------------------------------------
Static Function TM060ViagV(cCodVei)

Local cQuery 		:= ''
Local cAliasQry 	:= ''
Local aViagens  	:= {}
Local cFilOriOld	:= ''
Local cViagemOld	:= ''
Local nQtdViagem	:= 0

Local aAreaDTR   := DTR->(GetArea())
Local aAreaDTQ   := DTQ->(GetArea())
Local aAreaDA4   := DA4->(GetArea())
Local aAreaDUP   := DUP->(GetArea())

Default	cCodVei		:= ''

cAliasQry:= GetNextAlias()
cQuery := " SELECT DTR.DTR_FILIAL, DTR.DTR_FILORI, DTR.DTR_VIAGEM, DTR.DTR_CODVEI, DTQ.DTQ_STATUS, DA4.DA4_COD,  "
cQuery += "			DA4.DA4_NREDUZ, DA4.R_E_C_N_O_ "
cQuery += " 	FROM " + RetSqlName('DTR') + " DTR " 
cQuery += "		INNER JOIN " + RetSqlName('DTQ') + " DTQ "  
cQuery += " 		ON 	DTQ.DTQ_FILIAL = '" + FWxFilial('DTQ') + "' "
cQuery += "			AND DTQ.DTQ_FILORI = DTR.DTR_FILORI "
cQuery += "			AND DTQ.DTQ_VIAGEM = DTR.DTR_VIAGEM " 
cQuery += "			AND DTQ.D_E_L_E_T_ = ' ' "
cQuery += "		INNER JOIN " + RetSqlName('DUP') + " DUP "
cQuery += "			ON 	DUP.DUP_FILIAL = '" + FWxFilial('DUP') + "' "
cQuery += "			AND DUP.DUP_FILORI = DTR.DTR_FILORI "
cQuery += "			AND DUP.DUP_VIAGEM = DTR.DTR_VIAGEM "
cQuery += "			AND DUP.D_E_L_E_T_ = ' ' "
cQuery += "		INNER JOIN " + RetSqlName('DA4') + " DA4 "
cQuery += "			ON  DA4.DA4_FILIAL = ' " + FWxFilial('DA4') + "' "
cQuery += "			AND DA4.DA4_COD    = DUP.DUP_CODMOT	"
cQuery += "			AND DA4.D_E_L_E_T_= ' ' "
cQuery += "  		WHERE DTQ.DTQ_STATUS <> '3' "
cQuery += "			AND DTQ.DTQ_STATUS <> '9' " 
cQuery += "			AND (	DTR.DTR_CODVEI = '" + cCodVei + "' "  
cQuery += "				 OR DTR.DTR_CODRB1 = '" + cCodVei + "' "
cQuery += "				 OR DTR.DTR_CODRB2 = '" + cCodVei + "' "
cQuery += "				 OR DTR.DTR_CODRB3 = '" + cCodVei + "')"
cQuery += "			AND DTR.D_E_L_E_T_ = ' ' "
cQuery += "		ORDER BY DTR.DTR_FILORI, DTR.DTR_VIAGEM		   "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())	
	If cFilOriOld + cViagemOld <>  (cAliasQry)->DTR_FILORI+(cAliasQry)->DTR_VIAGEM
		
		AAdd(aViagens,{(cAliasQry)->DTR_FILORI,(cAliasQry)->DTR_VIAGEM, (cAliasQry)->DTQ_STATUS,;
						{ (cAliasQry)->DA4_COD} })

		cFilOriOld:= (cAliasQry)->DTR_FILORI
		cViagemOld:= (cAliasQry)->DTR_VIAGEM
		nQtdViagem += 1
	Else
		AADD(aViagens[nQtdViagem,4],(cAliasQry)->DA4_COD)
	EndIf	
	(cAliasQry)->(DbSkip())	
EndDo
(cAliasQry)->(DbCloseArea())

RestArea(aAreaDTR)
RestArea(aAreaDTQ)
RestArea(aAreaDA4)
RestArea(aAreaDUP)

Return aViagens