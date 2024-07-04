#include "PLSRPRO04.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

//----------------------------------------------R4 - PERSONALIZADO

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ PLRPRO04 º Autor ³ 				    º Data ³  29/06/2014 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ RELATORIO PERSONALIZADO POR BENEFICIARIO                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR.                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSRPRO04(cRegger,cVida)

Local cPerg 		:= PADR("PLRPRO04", Len(SX1->X1_GRUPO))
Private cProIni 	:= ""
Private cProFin 	:= ""
Private cMatvid 	:= BOM->BOM_VIDA
Private cCodPac		:=""
Private oReport
Default cVida 		:= ""
Default cRegger	:= ""


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria as Perguntas aTualizadas				                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraSX1(cPerg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca Vida Pelo Codigo Paciente SIGAHSP			                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If !Empty(cRegger)
	cMatvid :=PLSRTVID(&cRegger)
Endif

If !Empty(cVida)
	cMatvid := cVida
Endif

DbSelectArea("BTS")
DbSetOrder(1) //BTS_FILIAL, BTS_MATVID
DbSeek(xFilial("BTS")+cMatvid)

DbSelectArea("BOM")
DbSetOrder(3) //BOM_FILIAL, BOM_VIDA, BOM_STATUS
DbSeek(xFilial("BOM")+cMatvid)

DbSelectArea("BOA")
DbSetOrder(1) //BOA_FILIAL, BOA_CODPRO
DbSeek(xFilial("BOA")+BOM->BOM_CODPRO)

DbSelectArea("GBH")
DbSetOrder(8) //GBH_FILIAL, GBH_MATVID
DbSeek(xFilial("GBH")+cMatvid)


cCodPac:=GBH->GBH_CODPAC


DbSelectArea("GD4")
DbSetOrder(1) //GD4_FILIAL, GD4_REGGER, GD4_CODPLA
DbSeek(xFilial("GD4")+GBH->GBH_CODPAC)
//cCodPla := "%" + GD4->GD4_CODPLA + "%" //para dado do tipo caracter utilizamos aspas nos %

DbSelectArea("BA1")
DbSetOrder(7) //BA1_FILIAL, BA1_MATVID
DbSeek(xFilial("BA1")+cMatvid)


If FindFunction("TRepInUse") .And. TRepInUse()
	
	Pergunte("PLRPRO04",.T.)
	cProIni := mv_par01
	cProFin := mv_par02
	oReport := ReportDef()
	oReport:PrintDialog()
	
EndIF

Return( Nil )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³REPORTDEF ³ Autor ³ TOTVS                 ³ Data ³ 29/04/14 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()
Local oReport
Local oSection1, oSection2
Local oCell
Local cTitulo := ""

oReport := TReport():New("PLSRPRO04",OemToAnsi(cTitulo),'PLRPRO04',{|oReport| PLSIMPRO04(oReport)},STR0001) ////"Este relatorio tem por objetivo a impressao das Informações dos Pacientes do Programa da Promoção da Saúde."
oReport:SetLandscape()		// Imprimir Relatório em Formato Paisagem
oReport:ParamReadOnly() 	//Desabilitando Botão de parâmetros do Relatório.

Return( oReport )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PLSIMPRO04   ³ Autor ³ 				    ³ Data ³ 29/06/14 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PLSIMPRO04(oReport)
Local oSection1	:= oReport:Section(1)
Local oSection2	:= oReport:Section(2)
Local cMotEleg	:= ""
Local aMotMem		:= {}
Local nObs			:= ""
Local nX			:= ""
Local cCodPer		:= ""
Local lMemo 	:= .F.
local cquery 	:= ""
Local cCodPro 	:= ""
Local cDescPro := ""
Local cResCar	:=Space(TamSx3("GFK_RESCAR")[1])
Local cResNum	:=Space(TamSx3("GFK_RESNUM")[1])
Local cResDat	:=Space(TamSx3("GFK_RESDAT")[1])
Local cRiscoI	:=""
Local cDescRiI:=""
Local ni	:=0

Private cDescEmp := ""
Private cDescPla := ""
Private cResCarI	:= ""
Private cResCarP	:= ""
Private cResCarF	:= ""
Private cResNumI	:= ""
Private cResNumP	:= ""
Private cResNumF	:= ""
Private cResDtP	:= ""
Private cResDtI	:= ""
Private cResDtF	:= ""
Private cResMemoP	:= ""
Private cResMemoI	:= ""
Private cResMemoF	:= ""
Private aResCar	:= {}
Private aResNum	:= {}
Private aResDt	:= {}
Private aResMemo	:= {}
Private nQtdBD6	:= 0
Private nQtdeGM8	:= 0
Private nQtdFal	:= 0
Private nQtdBos	:= 0
Private nQtdAg5	:= 0
Private dDtBase	:= dDataBase-365
Private nVlrPag	:= 0
Private nQtdProcR	:= 0
Private nQtdProcF	:= 0
Private cIniPlan := ""
Private cFinPlan := ""
Private nIdade	:= 0
Private cMemo	:="M"
Private cMedico	:=""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Quantidade de Consultas Realizadas.                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//oSection1:BeginQuery()
BeginSql Alias "QRYCAB"
	//CABEÇALHO DO RELATORIO
	SELECT BOM_NOME, BOM_VIDA, BOM_DTELEG, BA1_CODEMP, BA1_CODPLA, BA3_CODINT, BA3_CODPLA,
	BOM_DTINSC, BOM_DATALT, BOM_MOTALT, BTS_DATNAS, BOM_CODPRO, BOA_DESPRO, BOM_MEDRSP,BA1_CODINT,BA1_CODEMP,BA1_CONEMP,
	BA1_VERCON,BA1_SUBCON,BA1_VERSUB
	FROM %table:BOM% BOM
	JOIN %table:BOA% BOA
	ON BOM.BOM_CODPRO = BOA.BOA_CODPRO
	AND BOA.BOA_FILIAL = %xFilial:BOA%
	AND BOA.%Notdel%
	
	JOIN %table:BTS% BTS
	ON BOM.BOM_VIDA = BTS.BTS_MATVID
	AND BTS.BTS_FILIAL = %xFilial:BTS%
	AND BTS.%Notdel%
	
	JOIN %table:BA1% BA1
	ON BOM.BOM_VIDA = BA1.BA1_MATVID
	AND BA1.BA1_FILIAL = %xFilial:BA1%
	AND BA1.%Notdel%
	
	JOIN %table:BA3% BA3
	ON BA3.BA3_CODINT  = BA1.BA1_CODINT
	AND BA3.BA3_CODEMP = BA1.BA1_CODEMP
	AND BA3.BA3_MATRIC = BA1.BA1_MATRIC
	AND BA3.BA3_FILIAL = %xFilial:BA3%
	AND BA3.%Notdel%
	
	WHERE  BOM.BOM_VIDA = %Exp:cMatvid%
	AND BOM.BOM_FILIAL = %xFilial:BOM%
	AND BOM.BOM_CODPRO >= %Exp:cProIni%
	AND BOM.BOM_CODPRO <= %Exp:cProFin%
	AND BOM.BOM_FILIAL = %xFilial:BOM%
	AND BOM.%NotDel%
	GROUP BY  BOM_NOME, BOM_VIDA, BOM_DTELEG, BA1_CODEMP, BA1_CODPLA, BA3_CODINT, BA3_CODPLA,
	BOM_DTINSC, BOM_DATALT, BOM_MOTALT, BTS_DATNAS, BOM_CODPRO, BOA_DESPRO, BOM_MEDRSP
	,BA1_CODINT,BA1_CODEMP,BA1_CONEMP,BA1_VERCON,BA1_SUBCON,BA1_VERSUB
EndSql


While !QRYCAB->(EOF())
	If cCodPro <> QRYCAB->BOM_CODPRO
		cMedico := QRYCAB->BOM_MEDRSP +"-"+Substr(HS_IniPadr('SRA', 11, QRYCAB->BOM_MEDRSP, 'RA_NOME'),1,15)
		cCodPro := QRYCAB->BOM_CODPRO
		
		If !Empty(QRYCAB->BA1_CODPLA)
			cCodPla := QRYCAB->BA1_CODPLA
		ElseIf !Empty(QRYCAB->BA3_CODPLA)
			cCodPla := QRYCAB->BA3_CODPLA
		EndIf
		
		nIdade := Calc_Idade(dDatabase,STOD(QRYCAB->BTS_DATNAS))
		cDescEmp := Pro04BusEm("QRYCAB")
		
		cDescPla := Posicione("BI3", 1, xFilial("BI3") + QRYCAB->BA3_CODINT + cCodPla, "BI3_DESCRI")
		
		oReport:SkipLine(1)
		oReport:SkipLine(1)
		oReport:PrintText(STR0002, oReport:Row(), 010)//"Vida"
		oReport:PrintText(STR0003, oReport:Row(), 150)//"Nome"
		oReport:PrintText(STR0004, oReport:Row(), 750)//"Idade"
		oReport:PrintText(STR0005, oReport:Row(), 850)//"Dt.Elegibilidade"
		oReport:PrintText(STR0006, oReport:Row(), 1080)//"Dt.Inscrição"
		oReport:PrintText(STR0007, oReport:Row(), 1280)//"Dt.Alta"
		oReport:PrintText(STR0008, oReport:Row(), 1500)//"Motivo Alta"
		oReport:PrintText(STR0009, oReport:Row(), 1930)//"Empresa"
		oReport:PrintText(STR0010, oReport:Row(), 2150)//"Descrição"
		oReport:PrintText(STR0011, oReport:Row(), 2530)//"Plano"
		oReport:PrintText(STR0012, oReport:Row(), 2640)//"Descrição"
		oReport:SkipLine(1)
		
		oReport:Line(oReport:Row(), 000, oReport:Row(),  10000) // imprime uma linha na folha
		
		oReport:SkipLine(1)
		oReport:PrintText(QRYCAB->BOM_VIDA, oReport:Row(), 010)
		oReport:PrintText(QRYCAB->BOM_NOME, oReport:Row(), 150)
		oReport:PrintText(STR(nIdade) + STR0013, oReport:Row(), 550)//" anos"
		oReport:PrintText(DTOC(STOD(QRYCAB->BOM_DTELEG)), oReport:Row(), 850)
		oReport:PrintText(DTOC(STOD(QRYCAB->BOM_DTINSC)), oReport:Row(), 1080)
		oReport:PrintText(DTOC(STOD(QRYCAB->BOM_DATALT)), oReport:Row(), 1280)
		oReport:PrintText(QRYCAB->BOM_MOTALT+"-"+Posicione("GF4",1,xFilial("GF4")+QRYCAB->BOM_MOTALT,"GF4_DSTPAL"), oReport:Row(), 1500)
		oReport:PrintText(QRYCAB->BA1_CODEMP, oReport:Row(), 1930)
		oReport:PrintText(cDescEmp, oReport:Row(), 2150)
		oReport:PrintText(QRYCAB->BA3_CODPLA, oReport:Row(), 2530)
		oReport:PrintText(cDescPla, oReport:Row(), 2640)
		oReport:SkipLine(1)
		
		BeginSql Alias "QRYGM8"
			
			SELECT GM8_STATUS
			FROM %table:GM8% GM8 //Agenda Ambulatorial
			JOIN %table:GBH% GBH
			ON GBH.GBH_CODPAC = GM8.GM8_REGGER
			AND GBH.GBH_FILIAL = %xFilial:GBH% //Dados Adicionais de Pacientes
			AND GBH.%NotDel%
			JOIN  %table:BOM% BOM
			ON BOM.BOM_VIDA = GBH.GBH_MATVID
			AND BOM.BOM_VIDA = %Exp:cMatvid%
			AND BOM.BOM_CODPRO = %Exp:QRYCAB->BOM_CODPRO%
			AND BOM.BOM_FILIAL = %xFilial:BOM% //Elegiveis ao programa
			AND BOM.%NotDel%
			JOIN %table:BOA% BOA
			ON BOM.BOM_CODPRO = BOA.BOA_CODPRO
			AND BOA.BOA_FILIAL = %xFilial:BOA% //Programas de Saude
			AND BOA.%NotDel%
			JOIN  %table:GA7% GA7
			ON GA7.GA7_PROPLS = BOA.BOA_CONPAD
			AND GM8.GM8_CODPRO = GA7.GA7_CODPRO
			AND GA7.GA7_FILIAL = %xFilial:GA7% //Cabecalho de Procedimentos
			AND GA7.%NotDel%
			JOIN  %table:GD4% GD4
			ON GD4.GD4_REGGER = GM8.GM8_REGGER
			AND GD4.GD4_IDPADR = '1'
			AND GD4.GD4_FILIAL = %xFilial:GD4% //Paciente x Plano
			AND GD4.%NotDel%
			JOIN  %table:BTS% BTS
			ON BTS.BTS_MATVID = BOM.BOM_VIDA
			AND BTS.BTS_FILIAL = %xFilial:BTS% //Vidas
			AND BTS.%NotDel%
			WHERE (GM8.GM8_STATUS = '1' //0=liberado;1=Ocupado;2=Bloqueado;3=Atendido;4Ocupado/Bloqueado;5=Confirmado;6=Retorno;7=Conferencia;8=Transferido
			OR GM8.GM8_STATUS = '3')
			AND GM8.GM8_FILIAL = %xFilial:GM8%
			AND GM8.%NotDel%
			AND NOT EXISTS( SELECT 1 FROM %table:BD6% BD6 WHERE BD6.BD6_CODPRO = GA7.GA7_PROPLS AND BD6.BD6_DATPRO = GM8.GM8_DATAGE AND BD6.BD6_FILIAL = %xFilial:BD6% AND BD6.%NotDel%)
		EndSql
		
		While  !QRYGM8->(EOF())
			If QRYGM8->GM8_STATUS == '1'
				nQtdFal ++
			Else
				nQtdeGM8 ++
			EndIf
			QRYGM8->(dbSkip())
		EndDo
		
		QRYGM8->(DbCloseArea())
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Quantidade de Exames Planejados Realizados                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		BeginSql Alias "QRYBOQ"
			SELECT BOQ_PROCED, BOQ_STATUS, BOQ_DATAGE, BOQ_DATSUG
			FROM %table:BOQ% BOQ //Planejamento
			JOIN  %table:BOM% BOM
			ON BOM.BOM_VIDA = BOQ.BOQ_VIDA
			AND BOM.BOM_CODPRO = %Exp:QRYCAB->BOM_CODPRO%
			AND BOM.BOM_VIDA = %Exp:cMatvid%
			AND BOM.BOM_FILIAL = %xFilial:BOM% //Elegiveis ao programa
			AND BOM.%NotDel%
			
			JOIN %table:BOA% BOA
			ON BOQ.BOQ_PROGRA = BOA.BOA_CODPRO
			AND BOA.BOA_FILIAL = %xFilial:BOA% //Programas de Saude
			AND BOA.%NotDel%
			WHERE BOQ.BOQ_FILIAL = %xFilial:BOQ%
			AND BOQ.%NotDel%
			AND BOQ.BOQ_PROGRA = %Exp:QRYCAB->BOM_CODPRO%
		EndSql
		
		If !QRYBOQ->(EOF())
			cIniPlan := QRYBOQ->BOQ_DATSUG
		EndIf
		
		While  !QRYBOQ->(EOF())
			If QRYBOQ->BOQ_STATUS == '3' //0=Incluido;1=Lib Agenda;2=Agendado;3=Realizado;4=Nao Realizado
				nQtdProcR ++
			ElseIf QRYBOQ->BOQ_STATUS == '4'
				nQtdProcF ++
			EndIf
			cFinPlan := QRYBOQ->BOQ_DATSUG
			QRYBOQ->(dbSkip())
		EndDo
		
		QRYBOQ->(DbCloseArea())
		
		DbSelectArea("BOM")
		DbSetOrder(1) //BOM_FILIAL, BOM_CODPRO, BOM_VIDA, BOM_STATUS
		If DbSeek(xFilial("BOM")+QRYCAB->BOM_CODPRO+cMatvid)
			cMotEleg	:= BOM->BOM_MOTELE
			cRiscoI		:= BOM->BOM_GRARIS
			cDescRiI	:= Posicione("BOB", 2, xFilial("BOB") + cRiscoI + BOM->BOM_CODPRO, "BOB_RISCO")
			cRiscoF		:= BOM->BOM_GRARIS
			cDescRiF	:= Posicione("BOB", 2, xFilial("BOB") + cRiscoF + BOM->BOM_CODPRO, "BOB_RISCO")
		EndIf
		
		
		DbSelectArea("BOK")
		DbSetOrder(1) //BOK_FILIAL, BOK_NROSEQ, R_E_C_N_O_, D_E_L_E_T_
		If BOK->(DbSeek(xFilial("BOK")+BOM->BOM_NROSEQ))
			While !BOK->(EOF()) .AND. BOK->BOK_NROSEQ =BOM->BOM_NROSEQ
				If ni<1
					cRiscoI		:= BOK->BOK_GRARII
					cDescRiI	:= Posicione("BOB", 2, xFilial("BOB") + cRiscoI + BOM->BOM_CODPRO, "BOB_RISCO")
				Endif
				ni+=1
				cRiscoF		:= BOK->BOK_GRARIF
				cDescRiF	:= Posicione("BOB", 2, xFilial("BOB") + cRiscoF + BOM->BOM_CODPRO, "BOB_RISCO")
				
				BOK->(dbSkip())
				
			enddo
			
		Endif
		
		
		oReport:SkipLine(1)
		oReport:PrintText(STR0014, oReport:Row(), 010)//"Consulta(s) Realizada(s): "
		oReport:PrintText(STR(nQtdeGM8), oReport:Row(), 280)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0015, oReport:Row(), 010)//"Não Compareceu em Consulta(s): "
		oReport:PrintText(STR(nQtdFal), oReport:Row(), 280)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0016, oReport:Row(), 010)//"Procedimento(s) Realizado(s): "
		oReport:PrintText(STR(nQtdProcR), oReport:Row(), 280)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0017, oReport:Row(), 010)//"Inicio do Planejamento em: "
		oReport:PrintText(DTOC(STOD(cIniPlan)), oReport:Row(), 380)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0018, oReport:Row(), 010)//"Fim do Planejamento em: "
		oReport:PrintText(DTOC(STOD(cFinPlan)), oReport:Row(), 380)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0019, oReport:Row(), 010)//"Grau de Risco Inicial: "
		oReport:PrintText(cRiscoI + " ", oReport:Row(), 380)
		oReport:PrintText(" - " + cDescRiI, oReport:Row(), 395)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0020, oReport:Row(), 010)//"Grau de Risco Final: "
		oReport:PrintText(cRiscoF + " ", oReport:Row(), 380)
		oReport:PrintText(" - " + cDescRiF, oReport:Row(), 395)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0023, oReport:Row(), 010)//"Prof. Resp "
		oReport:PrintText(cMedico + " ", oReport:Row(), 380)
		oReport:SkipLine(1)
		
		oReport:PrintText(STR0021, oReport:Row(), 010)//"Motivo da Elegibilidade: "
		nLinhas := MlCount(cMotEleg,105)
		
		For nX := 1 to nlinhas
			aADD(aMotMem,{MEMOLINE(cMotEleg,105,nX)})
		Next nX
		
		For nObs := 1 To Len(aMotMem)
			oReport:PrintText(aMotMem[nObs,1], oReport:Row(), 365)
			oReport:SkipLine(1)
		Next nObs
		oReport:SkipLine(1)
		
		nQtdeGM8	:= 0
		nQtdFal	:= 0
		nQtdProcR	:= 0
		cIniPlan	:= ""
		cFinPlan	:= ""
		cRisco		:= ""
		cMotEleg	:= ""
		aMotMem	:= {}
		
		cDescPro := QRYCAB->BOA_DESPRO
		
		BeginSql Alias "QRYITE"
			//ITENS DO RELATORIO
			SELECT BOV_CODPER, GFK_RESCAR, 	GFK_RESNUM, GFK_RESDAT, GFK_CDANAM, GFK_CDQUES, GFK_GRPPER
			FROM %table:BOM% BOM
			
			JOIN %table:BA1% BA1
			ON BOM.BOM_VIDA = BA1.BA1_MATVID
			AND BA1.BA1_FILIAL = %xFilial:BA1%
			AND BA1.%Notdel%
			
			JOIN %table:BOV% BOV
			ON BOV.BOV_CODPRO = BOM.BOM_CODPRO
			AND BOV.BOV_FILIAL = %xFilial:BOV%
			AND BOV.%Notdel%
			
			JOIN %table:GCH% GCH
			ON GCH.GCH_CODPER = BOV.BOV_CODPER
			AND GCH.GCH_FILIAL = %xFilial:GCH%
			AND GCH.%Notdel%
			AND GCH_TIPPER <>   %Exp:cMemo%
			
			JOIN %table:GFK% GFK
			ON GFK.GFK_CODPER = GCH.GCH_CODPER
			AND GFK.GFK_FILIAL = %xFilial:GFK%
			AND GFK.%Notdel%
			
			JOIN %table:GFU% GFU
			ON GFU.GFU_CDANAM = GFK.GFK_CDANAM
			AND GFU.GFU_FILIAL = %xFilial:GFU%
			AND GFU.%Notdel%
			AND GFU.GFU_REGGER = %Exp:cCodPac%
			
			WHERE  BOM.BOM_VIDA = %Exp:cMatvid%
			AND BOM.BOM_FILIAL = %xFilial:BOM%
			AND BOM.BOM_CODPRO = %Exp:cCodPro%
			AND BOM.%NotDel%
			
			GROUP BY BOV_CODPER, GFK_CDANAM, GFK_RESCAR, 	GFK_RESNUM, GFK_RESDAT, GFK_CDQUES, GFK_GRPPER
			ORDER BY  BOV_CODPER,GFK_CDANAM
		EndSql
		
		If !QRYITE->(EOF())
			
			oReport:PrintText(STR0022, oReport:Row(), 010)//"Programa"
			oReport:PrintText(cCodPro, oReport:Row(), 150)
			oReport:PrintText(" - " + cDescPro, oReport:Row(), 220)
			oReport:SkipLine(2)
			
			//	oReport:PrintText(STR0023, oReport:Row(), 010)//"Prof.Resp"
			oReport:PrintText(STR0024, oReport:Row(), 210)//"Cod. Pergunta"
			oReport:PrintText(STR0025, oReport:Row(), 500)//"ResCar Inicial"
			oReport:PrintText(STR0026, oReport:Row(), 1400)//"ResCar Final"
			oReport:PrintText(STR0027, oReport:Row(), 2150)//"ResNum Inicial"
			oReport:PrintText(STR0028, oReport:Row(), 2450)//"ResNum Final"
			oReport:PrintText(STR0029, oReport:Row(), 2750)//"ResDt Inicial"
			oReport:PrintText(STR0030, oReport:Row(), 3000)//"ResDt Final"
			oReport:SkipLine(1)
		EndIf
		
		While !QRYITE->(EOF())
			If !Empty(QRYITE->GFK_RESCAR)//RESPOSTA DO TIPO CARACTER
				cCodPer	:= QRYITE->BOV_CODPER
				cResCarP	:= QRYITE->GFK_RESCAR
				cResCarI 	:= QRYITE->GFK_RESCAR
				
				
				While !QRYITE->(EOF()) .And. !Empty(QRYITE->GFK_RESCAR) .And. Alltrim(cCodPer) == Alltrim(QRYITE->BOV_CODPER)
					If cResCarF <> cResCarI
						AADD(aResCar, {cResCarP,cResCarI})
						
						For nX := 1 To Len(aResCar)
							If nX == Len(aResCar) .And. nX > 1
								cResCarF := aResCar[nX][2]
							EndIf
						Next nX
					EndIf
					QRYITE->(dbSkip())
					
					If Alltrim(cCodPer) == Alltrim(QRYITE->BOV_CODPER)
						cResCarI := QRYITE->GFK_RESCAR
					Else
						Exit
					EndIf
				EndDo
				
				cResCarI := cResCarP
				oReport:SkipLine(1)
				//				oReport:PrintText(cMedico, oReport:Row(), 010)
				oReport:PrintText(cCodPer, oReport:Row(), 210)
				oReport:PrintText(cResCarI, oReport:Row(), 500)
				oReport:PrintText(cResCarF, oReport:Row(), 1400)
				oReport:SkipLine(1)
				
			ElseIf !Empty(QRYITE->GFK_RESNUM)//RESPOSTA DO TIPO NUMERO
				cCodPer		:= QRYITE->BOV_CODPER
				cResNumP	:= QRYITE->GFK_RESNUM
				cResNumI	:= QRYITE->GFK_RESNUM
				
				
				While !QRYITE->(EOF()) .And. !Empty(QRYITE->GFK_RESNUM).And. Alltrim(cCodPer) == Alltrim(QRYITE->BOV_CODPER)
					If cResNumF <> cResNumI
						AADD(aResNum, {cResNumP,cResNumI})
						
						For nX := 1 To Len(aResNum)
							If nX == Len(aResNum) .And. nX > 1
								cResNumF := aResNum[nX][2]
							EndIf
						Next nX
					EndIf
					
					QRYITE->(dbSkip())
					
					If Alltrim(cCodPer) == Alltrim(QRYITE->BOV_CODPER)
						cResNumI := QRYITE->GFK_RESNUM
					Else
						Exit
					EndIf
				EndDo
				
				cResNumI := cResNumP
				oReport:SkipLine(1)
				//	oReport:PrintText(cMedico, oReport:Row(), 010)
				oReport:PrintText(cCodPer, oReport:Row(), 210)
				oReport:PrintText(cResNumI, oReport:Row(), 2150)
				oReport:PrintText(cResNumF, oReport:Row(), 2450)
				oReport:SkipLine(1)
				
			ElseIf !Empty(QRYITE->GFK_RESDAT)//RESPOSTA DO TIPO DATA
				cCodPer	:= QRYITE->BOV_CODPER
				cResDtP	:= QRYITE->GFK_RESDAT
				cResDtI	:= QRYITE->GFK_RESDAT
				
				
				While !QRYITE->(EOF()) .And. !Empty(QRYITE->GFK_RESDAT).And. Alltrim(cCodPer) == Alltrim(QRYITE->BOV_CODPER)
					If cResDtF <> cResDtI
						AADD(aResDt, {cResDtP,cResDtI})
						
						For nX := 1 To Len(aResDt)
							If nX == Len(aResDt) .And. nX > 1
								cResDtF := aResDt[nX][2]
							EndIf
						Next nX
					EndIf
					
					QRYITE->(dbSkip())
					
					If Alltrim(cCodPer) == Alltrim(QRYITE->BOV_CODPER)
						cResDtI := QRYITE->GFK_RESDAT
					Else
						Exit
					EndIf
				EndDo
				
				cResDtI := cResDtP
				oReport:SkipLine(1)
				//	oReport:PrintText(cMedico, oReport:Row(), 010)
				oReport:PrintText(cCodPer, oReport:Row(), 210)
				oReport:PrintText(DTOC(STOD(cResDtI)), oReport:Row(), 2750)
				oReport:PrintText(DTOC(STOD(cResDtF)), oReport:Row(), 3000)
				oReport:SkipLine(1)
			EndIf
			
			QRYITE->(dbSkip())
			
		EndDo
		
		QRYITE->(DbCloseArea())
		
		
		BeginSql Alias "QRYMEMO"
			SELECT  BOM_MEDRSP, BOM_CODPRO, BOV_CODPER,GFK_CDANAM, GFK_CDQUES, GFK_GRPPER, BOA_DESPRO
			FROM %table:BOM% BOM
			
			JOIN %table:BOA% BOA
			ON BOM.BOM_CODPRO = BOA.BOA_CODPRO
			AND BOA.BOA_FILIAL = %xFilial:BOA%
			AND BOA.%Notdel%
			
			JOIN %table:BA1% BA1
			ON BOM.BOM_VIDA = BA1.BA1_MATVID
			AND BA1.BA1_FILIAL = %xFilial:BA1%
			AND BA1.%Notdel%
			
			JOIN %table:BOV% BOV
			ON BOV.BOV_CODPRO = BOM.BOM_CODPRO
			AND BOV.BOV_FILIAL = %xFilial:BOV%
			AND BOV.%Notdel%
			
			JOIN %table:GCH% GCH
			ON GCH.GCH_CODPER = BOV.BOV_CODPER
			AND GCH.GCH_FILIAL = %xFilial:GCH%
			AND GCH.%Notdel%
			AND GCH_TIPPER = %Exp:cMemo%
			
			JOIN %table:GFK% GFK
			ON GFK.GFK_CODPER = GCH.GCH_CODPER
			AND GFK.GFK_FILIAL = %xFilial:GFK%
			AND GFK.%Notdel%
			
			JOIN %table:GFU% GFU
			ON GFU.GFU_CDANAM = GFK.GFK_CDANAM
			AND GFU.GFU_FILIAL = %xFilial:GFU%
			AND GFU.%Notdel%
			AND GFU.GFU_REGGER = %Exp:cCodPac%
			
			WHERE  BOM.BOM_VIDA = %Exp:cMatvid%
			AND BOM.BOM_FILIAL = %xFilial:BOM%
			AND BOM.BOM_CODPRO = %Exp:cCodPro%
			AND BOM.%NotDel%
			ORDER BY  BOV_CODPER,GFK_CDANAM
			
		EndSql
		
		If !QRYMEMO->(EOF())
			cCodPer:=QRYMEMO->BOV_CODPER
			
			DbSelectArea("GFK")
			DbSetOrder(1) //GFK_FILIAL, GFK_CDANAM, GFK_CDQUES, GFK_GRPPER, GFK_CODPER
			
			oReport:SkipLine(1)
			oReport:PrintText(STR0031, oReport:Row(), 010)//"Programa"
			oReport:PrintText(cCodPro, oReport:Row(), 150)
			oReport:PrintText(" - " + cDescPro, oReport:Row(), 220)
			oReport:SkipLine(2)
			
			//					oReport:PrintText(STR0032, oReport:Row(), 010)//"Prof.Resp"
			oReport:PrintText(STR0033, oReport:Row(), 210)//"Cod. Pergunta"
			oReport:PrintText(STR0034, oReport:Row(), 500)//"ResMemo Inicial"
			oReport:PrintText(STR0035, oReport:Row(), 1100)//"ResMemo Final"
			oReport:SkipLine(1)
			
			
			While !QRYMEMO->(EOF())
				If cCodPer <> QRYMEMO->BOV_CODPER
					Pro04IMemo(aResMemo,cCodPer)
					aResMemo:={}
					cCodPer:=QRYMEMO->BOV_CODPER
				Endif
				
				If DbSeek(xFilial("GFK")+QRYMEMO->(GFK_CDANAM+GFK_CDQUES+GFK_GRPPER+BOV_CODPER))
					if  Alltrim(cCodPer) == AllTrim(QRYMEMO->BOV_CODPER)
						cResMemoP	:= GFK->GFK_RESMEM
						cResMemoI	:= GFK->GFK_RESMEM
						
						If	!Empty(GFK->GFK_RESMEM)
							
							AADD(aResMemo, {QRYMEMO->BOV_CODPER,GFK->GFK_RESMEM})
							
						EndIf
						
					Else
						
						
						
					EndIf
					
				Endif
				QRYMEMO->(dbSkip())
			EndDo
			
		EndIf
		
		If  len (aResMemo)>0
			Pro04IMemo(aResMemo,cCodPer)
		Endif
		QRYMEMO->(DbCloseArea())
		
	EndIf
	QRYCAB->(dbSkip())
EndDo

QRYCAB->(DbCloseArea())
If oReport:PageBreak()
	oReport:EndPage()
	oReport:PrintHeader()
EndIf

Return( NIL )


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ GeraSX1  ³ Autor ³ Segmento Saude        ³ Data ³ 11.09.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de processamento da gravacao do SX1 - Perguntas       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraSX1(cPerg)
Local aArea 	:= GetArea()
Local aRegs 	:= {}
Local i	  		:= 0
Local j     	:= 0
Local nJ		:=0
Local nI		:=0
Local lInclui	:= .F.
Local aHelpPor	:= {}
Local aHelpSpa	:= {}
Local aHelpEng	:= {}
Local cTexto    := ''
Local aAreaDic := SX1->( GetArea() )

// Cria grupo de perguntas PLRPRO04

aRegs 									:= {}
AADD(aRegs,{cPerg,"01",STR0036,"                              ","                              ","MV_CH1","C",06,00,00,"G"," ","MV_PAR01       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","BOA   "," ","   ","              ","@                                       ","      "})//"Programa de ?                    "
AADD(aRegs,{cPerg,"02",STR0037,"                              ","                              ","MV_CH2","C",06,00,00,"G"," ","MV_PAR02       ","               ","               ","               ","                                                            ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","               "," ","               ","               ","               ","          "," ","BOA   "," ","   ","              ","@                                       ","      "})//"Programa ate?                    "

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

If SX1->( !dbSeek(aRegs[1,1]+Space(Len(SX1->X1_GRUPO)-Len(cPerg))+aRegs[1,2])) // Significa que a pergunta não existe.
	
	// Se a pergunta  não existe é porque o dicionario esta antigo. Então apago todas pra recriar com a nova estrutura.
	If SX1->( dbSeek(aRegs[1,1]+Space(Len(SX1->X1_GRUPO)-Len(cPerg))+aRegs[1,2]))
		While !SX1->( Eof() ) .and. Alltrim(SX1->X1_GRUPO) == cPerg
			SX1->( RecLock("SX1", .F.) )
			SX1->( dbDelete() )
			SX1->(MsUnlock())
			SX1->(dbSkip())
		Enddo
	Endif
	
	For i := 1 To Len(aRegs)
		lInclui := !dbSeek(cPerg + aRegs[i,2])
		RecLock("SX1", lInclui)
		For j := 1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Endif
		Next
		MsUnlock()
		
		aHelpPor := {} ; aHelpSpa := {} ; 	aHelpEng := {}
		IF i == 1
			AADD(aHelpPor,STR0038)//"Informe o Programa Inicial que"
			AADD(aHelpPor,STR0039)//" que será filtrado Geração do Relatorio"
		ELSEIF i==2
			AADD(aHelpPor,STR0040)//"Informe o Programa Final que"
			AADD(aHelpPor,STR0041)//" que será filtrado Geração do Relatorio"
		ENDIF
		PutSX1Help("P."+alltrim(cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)
		
		cTexto += IIf( aRegs[i,1] + aRegs[i,2] $ cTexto, "", aRegs[i,1] + aRegs[i,2] + "\")
		
	Next
	
Endif
RestArea( aAreaDic )
RestArea( aArea )

Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Pro04BusEm ³ Autor ³ Segmento Saude      ³ Data ³ 11.09.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Empresa/Familia							       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function Pro04BusEm(cArqTrab)
Local cEmpresa:=""

cEmpresa:=substr(Posicione("BQC",1,xFilial("BQC")+(cArqTrab)->BA1_CODINT+(cArqTrab)->BA1_CODEMP+(cArqTrab)->BA1_CONEMP+(cArqTrab)->BA1_VERCON+(cArqTrab)->BA1_SUBCON+(cArqTrab)->BA1_VERSUB,"BQC_DESCRI"),1,30)
If Empty(cEmpresa)
	cEmpresa:=substr( Posicione("BG9",1,xFilial("BG9")+(cArqTrab)->(BA1_CODINT)+(cArqTrab)->(BA1_CODEMP),"BG9_DESCRI"),1,30)
Endif
Return(cEmpresa)




/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ Pro04IMemo ³ Autor ³ Segmento Saude      ³ Data ³ 11.09.14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Respostas Memo							       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atualizacao Saúde                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/


Static Function Pro04IMemo(aResMemo,cCodPer)
Local nX:=0
Local nObs:=0
Local cResMemoII    	:=""
Local cResMemoff		:=""
Local oFont1 	:= TFont():New("Times New Roman",9,10 ,.T.,.F.,5,.T.,5,.T.,.F.)
Default aResMemo	:={}
Default cCodPer		:=""

For nX := 1 To Len(aResMemo)
	If nX == Len(aResMemo) .And. nX > 1
		cResMemoI:=aResMemo[1][2]
		cResMemof := aResMemo[nX][2]
	EndIf
Next nX


aResMemo := {}

oReport:SkipLine(1)
oReport:PrintText(cCodPer, oReport:Row(), 210)

If !Empty(cResMemoI)
	nLinhas := MlCount(cResMemoI, , ,)
	
	For nX := 1 to nlinhas
		aADD(aResMemo,{MEMOLINE(cResMemoI,,nX,)})
	Next nX
	
	For nObs := 1 To Len(aResMemo)
		oReport:Say(oReport:Row(),500,  aResMemo[nObs,1], oFont1)
		oReport:SkipLine(1)
	Next nObs
EndIf

aResMemo := {}
If !Empty(cResMemoF)
	
	nLinhas := MlCount(cResMemoF, , ,)
	
	For nX := 1 to nlinhas
		aADD(aResMemo,{MEMOLINE(cResMemoF, ,nX,)})
	Next nX
	
	For nObs := 1 To Len(aResMemo)
		oReport:Say(oReport:Row(),1100,  aResMemo[nObs,1], oFont1)
		oReport:SkipLine(1)
	Next nObs
EndIf

oReport:SkipLine(1)
cCodPer := AllTrim(QRYMEMO->BOV_CODPER)

Return()
