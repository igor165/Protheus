#INCLUDE "PMSA400.ch"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PMSA400  ³ Autor ³ Edson Maricate        ³ Data ³ 09-02-2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de recalculo do custo de recursos.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PMSA400()
Local aArea	:= GetArea()
Local cFunction		:= "PMSA400"
Local cPerg			:= "PMA400"
Local cTitle		:= STR0001	//"Recalculo do custo dos recursos"
Local cDescription	:= STR0002	//"Esta rotina tem o objetivo de recalcular o custo dos recursos apontados aos projetos de acordo com o periodo solicitado e a configuracao de calculo selecionada no seu cadastro."
Local bProcess		:= { |oSelf| PMA400Proces(.F.,oSelf) }

If PMSBLKINT()
	Return Nil
EndIf

If ExistBlock("PMS400INI")
	ExecBlock("PMS400INI",.F.,.F.)
EndIf

If IsBlind()
	BatchProcess(STR0001,OemToAnsi(STR0002),cPerg,{ || Processa({|lEnd| PMA400Proces(@lEnd) })})
Else
	TNewProcess():New( cFunction, cTitle, bProcess, cDescription, cPerg )
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PMA400Proces³ Autor ³ Edson Maricate        ³ Data ³19/07/02³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa o recalculo do custo dos recursos.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³PMSA400                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PMA400Proces(lEnd,oSelf)
Local nCstHrs	:= 0
Local nTotHrs	:= 0
Local aArea		:= GetArea()
Local aRecAFU	:= {}
Local lPMS400CAL:= ExistBlock("PMS400CAL")
Local lPMA400CST:= ExistTemplate("PMA400CST") .And. (GetMV("MV_PMSCCT") == "2") 
Local nX		:= 0
Local lContinua := .T.
Local lNotBlind := !IsBlind()
Local cPmsGpe	:= GetMv("MV_PMSGPE",.F.,"0")

If lNotBlind            
	oSelf:SaveLog(STR0003)	//"Processamento iniciado."
	oSelf:SetRegua1(6)
Else
	PmsNewProc()	
EndIf	

//Caso utilize o SIGAGPE o periodo de datas deve estar dentro do mesmo mes e ano.	     
If cPmsGpe == "1" .and. (Subst(Dtoc(mv_par01),4,2) <> Subst(Dtoc(mv_par02),4,2) .or. Subst(Dtoc(mv_par01),7,2) <> Subst(Dtoc(mv_par02),7,2)) 
	If lNotBlind
   		MsgInfo("O sistema utiliza o Módulo Gestão Pessoal portanto o periodo de datas deve ficar no mesmo mês e ano! Verifique o parametro MV_PMSGPE!") 		
	Endif   
	RestArea(aArea)
	Return 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica a existencao do arquivo AFU             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If PMSChkAFU(.T.)
	dbSelectArea("AFU")
	dbSetOrder(3)
	dbSeek(xFilial()+"1"+mv_par03,.T.)
	cRecurso := AFU_RECURS
	While !Eof() .And. xFilial()+"1"==AFU_FILIAL+AFU_CTRRVS .And. AFU_RECURS <= mv_par04
		If lNotBlind
			oSelf:IncRegua1(STR0005+ RTrim(AFU_RECURS))	//"Atualizando custo do recurso: "
		Else
			PmsIncProc(.T.)
		EndIf
		If AFU->AFU_DATA >= mv_par01 .And. AFU->AFU_DATA <= mv_par02
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Totaliza a qtdade. de horas do periodo           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nTotHrs += AFU->AFU_HQUANT
			If AE8->AE8_TPREAL $ "235"
				aAdd(aRecAFU,AFU->(RecNo()))
			EndIf
		EndIf
		dbSelectArea("AFU")
		dbSkip()
		aAuxArea	:= GetArea()
		If cRecurso!=AFU_RECURS .Or. !(!Eof() .And. xFilial()+"1"==AFU_FILIAL+AFU_CTRRVS .And. AFU_RECURS <= mv_par04)
			AE8->(dbSetOrder(1))
			If AE8->(dbSeek(xFilial()+cRecurso))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Calcula o custo/hora do recurso.                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If AE8->AE8_TPREAL=="3" .And. !Empty(AE8->AE8_CODFUN)
					dbSelectArea("SRA")
					If AE8->(FieldPos("AE8_FILFUN")) > 0
						nCstHrs := CalCustoFun(AE8->AE8_FILFUN,AE8->AE8_CODFUN,.T.,.T.,mv_par01,mv_par02,/*cCusto*/,	/*aPIS*/,/*aINSS*/,/*aAcidente*/,/*aLabore*/,/*aAutonomo*/,/*aProvisao*/,/*aVerbas*/,/*aFGTS*/,/*aContSoc*/,mv_par05==1,,,mv_par06)/nTotHrs
					Else
						nCstHrs := CalCustoFun(xFilial("SRA"),AE8->AE8_CODFUN,.T.,.T.,mv_par01,mv_par02,/*cCusto*/,	/*aPIS*/,/*aINSS*/,/*aAcidente*/,/*aLabore*/,/*aAutonomo*/,/*aProvisao*/,/*aVerbas*/,/*aFGTS*/,/*aContSoc*/,mv_par05==1,,,mv_par06)/nTotHrs
					EndIf
				Else
					If AE8->AE8_TPREAL == "5" 
						nCstHrs := AE8->AE8_CUSMEN / nTotHrs
					Else
						nCstHrs := AE8->AE8_CUSFIX
					EndIf
				EndIf
				If lPMS400CAL
					nCstHrs := ExecBlock("PMS400CAL",.F.,.F.,{nCstHrs,nTotHrs})
				EndIf        
				If lNotBlind
					oSelf:SetRegua2(Len(aRecAFU))
				EndIf
				For nx := 1 to Len(aRecAFU)
					If lNotBlind
						oSelf:IncRegua2()
					EndIf
					AFU->(dbGoto(aRecAFU[nx]))
					AF8->(dbSetOrder(1))
					AF8->(MsSeek(xFilial()+AFU->AFU_PROJET))
					lContinua := .T.
					If !Empty(AF8->AF8_ULMES) .And. ;
						AFU->AFU_DATA <= AF8->AF8_ULMES
						lContinua := .F.
					EndIf
					If lContinua
						RecLock("AFU",.F.)
						AFU->AFU_CUSTO1 := AFU->AFU_HQUANT * nCstHrs
						AFU->AFU_CUSTO2 := xMoeda(AFU_CUSTO1,1,2,AFU->AFU_DATA)
						AFU->AFU_CUSTO3 := xMoeda(AFU_CUSTO1,1,3,AFU->AFU_DATA)
						AFU->AFU_CUSTO4 := xMoeda(AFU_CUSTO1,1,4,AFU->AFU_DATA)
						AFU->AFU_CUSTO5 := xMoeda(AFU_CUSTO1,1,5,AFU->AFU_DATA)
						AFU->AFU_TPREAL := AE8->AE8_TPREAL
						MsUnlock()
						If lPMA400CST
							ExecTemplate("PMA400CST",.F.,.F.)
						EndIf
						If (ExistBlock("PMA400CT"))
							ExecBlock("PMA400CT",.F.,.F.)
						EndIf	
					EndIf
				Next
			EndIf
			RestArea(aAuxArea)
			cRecurso := AFU->AFU_RECURS
			nTotHrs	 := 0
			aRecAFU  := {}
		EndIf
	End
EndIf

If lNotBlind
	oSelf:SaveLog(STR0004)	//"Processamento encerrado."
EndIf

RestArea(aArea)
Return
