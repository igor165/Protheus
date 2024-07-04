#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GCZDUPLบ Autor ณ Jos้ Orfeu         บ Data ณ  21/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Elimina duplicidades no arquivo de Guias (GCZ)             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_GczDupl()

If MsgYesNo("Confirma processamento?")
	
	Processa({|| FS_GczDupl()})
	
EndIf

Return(Nil)

Static Function FS_GczDupl()
Local cSql := ""
Local nHandle := fCreate("GczDupl.Log", 0)
Local nUpdt := 0
Local aUpdt := {"GD5", ; // Posto (Mat/Med)
"GD6", ; // Posto (Taxa/Diaria)
"GD7", ; // Posto (Procedimento)
"GE2", ; // Autoriza็ใo de guias (Mat/Med)
"GE3", ; // Autoriza็ใo de guias (Procedimento)
"GE5", ; // Faturamento (Mat/Med)
"GE6", ; // Faturamento (Taxa/Diaria)
"GE7", ; // Faturamento (Procedimento)
"GE8", ; // Prorroga็ใo de guias
"GEZ", ; // Rela็ใo pendencias de faturamento
"GG5", ; // (Mat/Med) Faturados pacote
"GG6", ; // (Taxa/Diaria) Faturados pacote
"GG7"}   // (Procedimentos) Faturados pacote

//GD5010, GD6010, GD7010, GE2010, GE3010, GE5010, GE6010, GE7010, GE8010, GEZ010, GG5010, GG6010, GG7010

ProcRegua(0)

// Inicio --- Verifica se existe atendimentos repetidos com o mesmo numero de atendimento e mesmo numero de guia
If "MSSQL" $ TCGetDb()
	cSql := "SELECT GCZ_REGATE, GCZ_NRSEQG, COUNT(*) FROM " + RetSqlName("GCZ") + " " + ;
	"WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND D_E_L_E_T_ <> '*' " + ;
	"GROUP BY GCZ_REGATE, GCZ_NRSEQG " + ;
	"HAVING COUNT(*) > 1 " + ;
	"ORDER BY GCZ_REGATE, GCZ_NRSEQG"
Else
	cSql := "SELECT GCZ_REGATE, GCZ_NRSEQG, COUNT(*) FROM " + RetSqlName("GCZ") + " " + ;
	"WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND D_E_L_E_T_ <> '*' " + ;
	"HAVING COUNT(*) > 1 " + ;
	"GROUP BY GCZ_REGATE, GCZ_NRSEQG " + ;
	"ORDER BY GCZ_REGATE, GCZ_NRSEQG"
EndIf

TCQuery cSql New Alias "TMPDUPL"

DbSelectArea("TMPDUPL")

If !Eof()
	
	While !Eof()
		IncProc("Excl.Guias Atendimento [" + TMPDUPL->GCZ_REGATE + "] Guia [" + TMPDUPL->GCZ_NRSEQG + "]")
		
		cSql := "SELECT GCZ_REGATE, GCZ_NRSEQG, GCZ_STATUS, R_E_C_N_O_ " + ;
		"FROM " + RetSqlName("GCZ") + " " + ;
		"WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ_REGATE = '" + TMPDUPL->GCZ_REGATE + "' AND GCZ_NRSEQG = '" + TMPDUPL->GCZ_NRSEQG + "' " + ;
		"ORDER BY GCZ_REGATE, GCZ_NRSEQG, GCZ_STATUS DESC"
		
		TCQuery cSql New Alias "TMPDELE"
		DbSelectArea("TMPDELE")
		
		DbSkip() // Pula o primeiro registro para excluir somente a partir do segundo registro e deixar a guia com o maior status
		// ja que a select esta ordenada do maior status para o menor status.
		
		// Isso truva tambem meu,,,da hora
		// DbGoTo(TMPDELE->R_E_C_N_O_)
		Begin Transaction
		
		While !Eof()
			
			cSql := "DELETE FROM " + RetSqlName("GCZ") + " WHERE R_E_C_N_O_ = " + AllTrim(Str(TMPDELE->R_E_C_N_O_))
			
			FS_LogProc(nHandle, "Registro Deletado - RegAte [" + TMPDELE->GCZ_REGATE + "] Guia [" + TMPDELE->GCZ_NRSEQG + "] Status [" + TMPDELE->GCZ_STATUS + "] RecNo [" + AllTrim(Str(TMPDELE->R_E_C_N_O_)) + "]")
			
			TCSqlExec(cSql)
			
			DbSkip()
			
		End
		
		End Transaction
		
		DbCloseArea()
		
		DbSelectArea("TMPDUPL")
		DbSkip()
	End
	
EndIf

DbCloseArea()
// Fim

DbSelectArea("GCZ")
DbSetOrder(1)

FS_LogProc(nHandle, Replicate(" ", 80))
FS_LogProc(nHandle, Replicate("-", 80))
FS_LogProc(nHandle, Replicate(" ", 80))

// Verifica se existe guias com numera็ใo repetida
cSql := "SELECT GCZ_NRSEQG, COUNT(*) FROM " + RetSqlName("GCZ") + " " + ;
"WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND D_E_L_E_T_ <> '*' " + ;
"HAVING COUNT(*) > 1 " + ;
"GROUP BY GCZ_NRSEQG " + ;
"ORDER BY GCZ_NRSEQG"

TCQuery cSql New Alias "TMPDUPL"

DbSelectArea("TMPDUPL")

If !Eof()
	
	While !Eof()
		IncProc("Renumerando guia [" + TMPDUPL->GCZ_NRSEQG + "]")
		
		cSql := "SELECT GCZ_REGATE, GCZ_NRSEQG, R_E_C_N_O_ " + ;
		"FROM " + RetSqlName("GCZ") + " " + ;
		"WHERE GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ_NRSEQG = '" + TMPDUPL->GCZ_NRSEQG + "' " + ;
		"ORDER BY GCZ_NRSEQG"
		
		TCQuery cSql New Alias "TMPUPDT"
		DbSelectArea("TMPUPDT")
		
		DbSkip() // Pula o primeiro registro para renumerar apartir do segundo registro
		
		Begin Transaction
		
		While !Eof()
			
			M->GCZ_NRSEQG := HS_VSxeNum("GCZ", "M->GCZ_NRSEQG", 1)
			ConfirmSx8()
			
			FS_LogProc(nHandle, "Registro alterado - RecNo [" + AllTrim(Str(TMPUPDT->R_E_C_N_O_)) + "] - Guia [" + TMPUPDT->GCZ_NRSEQG + "] para [" + M->GCZ_NRSEQG + "]")
			
			// Renumera GCZ - Guias
			cSql := "UPDATE " + RetSqlName("GCZ") + " SET GCZ_NRSEQG = '" + M->GCZ_NRSEQG + "' WHERE R_E_C_N_O_ = " + AllTrim(Str(TMPUPDT->R_E_C_N_O_))
			TCSqlExec(cSql)
			
			// Renumera arquivos relacionados com o GCZ
			For nUpdt := 1 To Len(aUpdt)
				
				cSql := "UPDATE " + RetSqlName(aUpdt[nUpdt]) + " SET " + aUpdt[nUpdt] + "_NRSEQG = '" + M->GCZ_NRSEQG + "' " + ;
				"WHERE " + aUpdt[nUpdt] + "_FILIAL = '" + xFilial(aUpdt[nUpdt]) + "' AND D_E_L_E_T_ <> '*' "
				
				If aUpdt[nUpdt] <> "GEZ" // Nao tem registro de atendimento
					cSql += "AND " + aUpdt[nUpdt] + "_REGATE = '" + TMPUPDT->GCZ_REGATE + "' "
				EndIf
				
				cSql += "AND " + aUpdt[nUpdt] + "_NRSEQG = '" + TMPUPDT->GCZ_NRSEQG + "'"
				
				TCSqlExec(cSql)
				
			Next
			
			DbSkip()
			
		End
		
		End Transaction
		
		DbCloseArea()
		
		DbSelectArea("TMPDUPL")
		DbSkip()
	End
	
EndIf

DbCloseArea()

fClose(nHandle)

HS_MsgInf("Verifique o arquivo GCZDUPL.LOG no diretorio system para maiores detalhes", "Processamento finalizado", "HS_GCZDUPL")

Return(Nil)

Static Function FS_LogProc(nHandle, cLog)
fWrite(nHandle, cLog + CHR(13) + CHR(10), Len(cLog + CHR(13) + CHR(10)))
Return(Nil)

Function HS_CriaGcz()
If MsgYesNo("Confirma processamento?")
	
	Processa({|| FS_CriaGcz()})
	
EndIf
Return(Nil)

Static Function FS_CriaGcz()
Local cMsgProc := ""
Local aAlias := {"GD5", "GD6", "GD7", "GE5", "GE6", "GE7"}
Local cSql := ""
Local nAlias := 0
Local aRVldVig	:= {{"", "GC1_TPGINT"}, ;
{"", "GC1_TPGAMB"}, ;
{"", "GC1_TPGPAT"}}

ProcRegua(0)

For nAlias := 1 To Len(aAlias)
	cSql := "SELECT " + aAlias[nAlias] + "_REGATE REGATE, " + aAlias[nAlias] + "_NRSEQG NRSEQG, COUNT(*) TOTDESP FROM " + RetSqlName(aAlias[nAlias]) + " " + ;
	"WHERE D_E_L_E_T_ <> '*' AND " + aAlias[nAlias] + "_NRSEQG NOT IN (SELECT GCZ_NRSEQG FROM " + RetSqlName("GCZ") + " WHERE D_E_L_E_T_ <> '*' AND GCZ_NRSEQG = " + aAlias[nAlias] + "_NRSEQG)" + ;
	"GROUP BY " + aAlias[nAlias] + "_REGATE, " + aAlias[nAlias] + "_NRSEQG"
	
	TCQuery cSql New Alias "TMPGUIA"
	
	While !Eof()
		
		IncProc("Processando atendimento [" + TMPGUIA->REGATE + "] Guia [" + TMPGUIA->NRSEQG + "]")
		
		DbSelectArea("GCZ")
		DbSetOrder(1)
		If !DbSeek(xFilial("GCZ") + TMPGUIA->NRSEQG)
			
			DbSelectArea("GCY")
			DbSetOrder(1)
			If DbSeek(xFilial("GCY") + TMPGUIA->REGATE)
				
				DbSelectArea("GD4")
				DbSetOrder(2)
				If DbSeek(xFilial("GD4") + GCY->GCY_REGGER + "1") // pega convenio/plano padrao do paciente
					
					DbSelectArea("GCM")
					DbSetOrder(2)
					If DbSeek(xFilial("GCM") + GD4->GD4_CODPLA)
						
						If HS_VldVig("GC1", "GC1_FILIAL = '" + xFilial("GC1") + "' AND GC1_CODPLA = '" + GD4->GD4_CODPLA + "'", "GC1_DATVIG", @aRVldVig, dDataBase)
							
							DbSelectArea("GCZ")
							RecLock("GCZ", .T.)
							GCZ->GCZ_FILIAL := xFilial("GCZ")
							GCZ->GCZ_REGATE := GCY->GCY_REGATE
							GCZ->GCZ_DATATE := GCY->GCY_DATATE
							GCZ->GCZ_REGGER := GCY->GCY_REGGER
							GCZ->GCZ_CODTPG := IIf(GCY->GCY_ATENDI == "0", aRVldVig[1, 1], IIf(GCY->GCY_ATENDI == "1", aRVldVig[2, 1], aRVldVig[3, 1]))
							GCZ->GCZ_CODCON := GCM->GCM_CODCON
							GCZ->GCZ_CODPLA := GD4->GD4_CODPLA
							GCZ->GCZ_CODCRM := GCY->GCY_CODCRM
							GCZ->GCZ_STATUS := "0"
							GCZ->GCZ_NRSEQG := TMPGUIA->NRSEQG
							GCZ->GCZ_CANCEL := "0"
							GCZ->GCZ_LOGARQ := HS_LogArq()
							GCZ->GCZ_ATENDI := GCY->GCY_ATENDI
							GCZ->GCZ_LOCATE := GCY->GCY_LOCATE
							GCZ->GCZ_NOME   := GCY->GCY_NOME
							If Hs_ExisDic({{"C", "GCZ_FILFAT"}}) 
 							GCZ->GCZ_FILFAT := HS_RetFilF(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, GCZ->GCZ_LOCATE, GCZ->GCZ_CODTPG)
        GCZ->GCZ_FILATE := cFilAnt
       EndIf 
							MsUnLock()
							
							cMsgProc += "Guia [" + TMPGUIA->NRSEQG + "] criada para o paciente [" + GCY->GCY_REGGER + "] do atendimento [" + TMPGUIA->REGATE + "]" + CHR(10)
							
						Else
							
							cMsgProc += "O plano padrใo do paciente [" + GCY->GCY_REGGER + "] do atendimento [" + TMPGUIA->REGATE + "] da guia [" + TMPGUIA->NRSEQG + "] nao possui vigencia cadastrada (GC1)" + CHR(10)
							
						EndIf
					Else
						
						cMsgProc += "O plano padrใo do paciente [" + GCY->GCY_REGGER + "] do atendimento [" + TMPGUIA->REGATE + "] da guia [" + TMPGUIA->NRSEQG + "] nao foi encontrado no cadastro de planos (GCM)" + CHR(10)
						
					EndIf
				Else
					
					cMsgProc += "Nใo encontrei plano padrใo para o paciente [" + GCY->GCY_REGGER + "] do atendimento [" + TMPGUIA->REGATE + "] da guia [" + TMPGUIA->NRSEQG + "]" + CHR(10)
					
				EndIf
			Else
				
				cMsgProc += "Nใo encontrei o atendimento [" + TMPGUIA->REGATE + "] da guia [" + TMPGUIA->NRSEQG + "]" + CHR(10)
				
			EndIf
			
		Else
			
			cMsgProc += "A guia [" + TMPGUIA->NRSEQG + "] nใo foi criada porque ja existe no arquivo (GCZ)" + CHR(10)
			
		EndIf
		
		DbSelectArea("TMPGUIA")
		DbSkip()
	End
	
	DbSelectArea("TMPGUIA")
	DbCloseArea()
Next

cMsgProc := IIf(Empty(cMsgProc), "Nใo foram encontradas despesas (GD's e GE's) sem guia (GCZ)", cMsgProc)

HS_MsgInf(cMsgProc, "Aten็ใo", "Cria็ใo de guias")
Return(Nil)

Function HS_GrvCCon()
Local oDlgP, nOpcP := 0
Local oReproces, cReproces := "0", aReproces := {"0-Nใo", "1-Sim"}
Local oVigencia, cVigencia := "0", aVigencia := {"0-Nใo", "1-Sim"}
Local oMConsole, cMConsole := "0", aMConsole := {"0-Nใo", "1-Sim"}

DEFINE MSDIALOG oDlgP TITLE OemToAnsi("Codigo da despesa no convenio") From 5,14 to 11,76	of oMainWnd

@ 011, 004 SAY OemToAnsi("Reprocessa") OF oDlgP PIXEL
@ 011, 054 MsComboBox oReproces VAR cReproces ITEMS aReproces OF oDlgP PIXEL

@ 024, 004 SAY OemToAnsi("P/Vigencia") OF oDlgP PIXEL
@ 024, 054 MsComboBox oVigencia VAR cVigencia ITEMS aVigencia OF oDlgP PIXEL

@ 011, 104 SAY OemToAnsi("ConsoleLog") OF oDlgP PIXEL
@ 011, 154 MsComboBox oMConsole VAR cMConsole ITEMS aMConsole OF oDlgP PIXEL

DEFINE SBUTTON FROM 011,209 TYPE 1 ACTION (nOpcP := 1, oDlgP:End()) ENABLE OF oDlgP
DEFINE SBUTTON FROM 024,209 TYPE 2 ACTION (nOpcP := 0, oDlgP:End()) ENABLE OF oDlgP

ACTIVATE MSDIALOG oDlgP CENTERED

If nOpcP == 1
	
	Processa({|| FS_GrvCCon(SubStr(cReproces, 1, 1), SubStr(cVigencia, 1, 1), SubStr(cMConsole, 1, 1))})
	
EndIf

Return(Nil)

Static Function FS_GrvCCon(cReproces, cVigencia, cMConsole)
Local sSql  := "", nSql := 0
Local aDesp := {"GD5", "GE5", "GD6", "GE6", "GD7", "GE7"}, nDesp := 0
Local aGrvs := {{"GD5_CODPRO", "GD5_DESPRO"}, ;
{"GE5_CODPRO", "GE5_DESPRO"}, ;
{"GD6_CODTXC", "GD6_DESTXC"}, ;
{"GE6_CODTXC", "GE6_DESTXC"}, ;
{"GD7_CODPRT", "GD7_DESPRT"}, ;
{"GE7_CODPRT", "GE7_DESPRT"}}
Local aRValDes := {}, cCodigo := "", cDescri := ""
Local nRecAtu := 0, nRecTot := 0, cGrpCpos := "", cLstCpos := "", cCondUpd := "", cHoraIni := "", cHoraSql := ""

For nDesp := 1 To Len(aDesp)
	If     nDesp == 1 .Or. nDesp == 2
		cGrpCpos := "GCZ.GCZ_CODPLA || DESP." + aDesp[nDesp] + "_CODDES" + IIf(cVigencia == "1", " || DESP." + aDesp[nDesp] + "_DATDES", "")
		
		cLstCpos := "GCZ.GCZ_CODPLA CODPLA, DESP." + aDesp[nDesp] + "_CODDES CODDES" + IIf(cVigencia == "1", " , DESP." + aDesp[nDesp] + "_DATDES DATDES", "")
	ElseIf nDesp == 3 .Or. nDesp == 4
		cGrpCpos := "GCZ.GCZ_CODPLA || DESP." + aDesp[nDesp] + "_CODDES" + IIf(cVigencia == "1", " || DESP." + aDesp[nDesp] + "_DATDES", "")
		
		cLstCpos := "GCZ.GCZ_CODPLA CODPLA, DESP." + aDesp[nDesp] + "_CODDES CODDES" + IIf(cVigencia == "1", ", DESP." + aDesp[nDesp] + "_DATDES DATDES", "")
	ElseIf nDesp == 5 .Or. nDesp == 6
		cGrpCpos := "GCZ.GCZ_CODPLA || DESP." + aDesp[nDesp] + "_CODDES" + IIf(cVigencia == "1", " || DESP." + aDesp[nDesp] + "_DATDES", "") + ;
		IIf(aDesp[nDesp] $ "GD7/GE7", " || DESP." + aDesp[nDesp] + "_CODLOC || DESP." + aDesp[nDesp] + "_URGDES ", "")
		
		cLstCpos := "GCZ.GCZ_CODPLA CODPLA, DESP." + aDesp[nDesp] + "_CODDES CODDES" + IIf(cVigencia == "1", ", DESP." + aDesp[nDesp] + "_DATDES DATDES", "") + ;
		IIf(aDesp[nDesp] $ "GD7/GE7", ", DESP." + aDesp[nDesp] + "_CODLOC CODLOC, DESP." + aDesp[nDesp] + "_URGDES URGDES", "")
	EndIf
	
	For nSql := 1 To 2
		If nSql == 1
			sSql := "SELECT COUNT(DISTINCT " + cGrpCpos + ") NRECTOT "
		Else
			sSql := "SELECT COUNT(*) NTOTDESP, MAX(DESP.R_E_C_N_O_) NRECNO, " + cLstCpos + " "
		EndIf
		
		sSql += "FROM " + RetSqlName(aDesp[nDesp]) + " DESP " + ;
		"INNER JOIN " + RetSqlName("GCZ") + " GCZ ON (GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = DESP." + aDesp[nDesp] + "_NRSEQG AND GCZ.GCZ_REGATE = DESP." + aDesp[nDesp] + "_REGATE) " + ;
		"WHERE DESP.D_E_L_E_T_ <> '*' AND DESP." + aDesp[nDesp] + "_FILIAL = '" + xFilial(aDesp[nDesp])+ "' "
		
		// Desconsidera codigos ja informados
		If cReproces == "0" // 0-Nใo
			sSql += "AND " + aGrvs[nDesp][1] + " = '" + Space(HS_CfgSx3(aGrvs[nDesp][1], {"X3_TAMANHO"})[1]) + "' "
		EndIf
		
		If nSql == 2
			sSql += "GROUP BY " + StrTran(cGrpCpos, " ||", ", ")
		EndIf
		
		If cMConsole == "1"
			cHoraIni := Time()
		EndIf
		
		sSql := ChangeQuery(sSql)
		
		TCQuery sSql New Alias "TMPRBASE"
		
		If cMConsole == "1"
			cHoraSql := HS_TotHoras(cHoraIni, Time(), "-", .T., .F.)
		EndIf
		
		If nSql == 1
			nRecTot := TMPRBASE->NRECTOT
			DbCloseArea()
		EndIf
	Next
	
	ProcRegua(nRecTot)
	
	DbSelectArea("TMPRBASE")
	
	While !Eof()
		
		nRecAtu++
		
		IncProc("Arq[" + aDesp[nDesp] + "] Desp.[" + AllTrim(TMPRBASE->CODDES) + "] Reg[" + StrZero(nRecAtu, 7) + "/" + StrZero(nRecTot, 7) + "]")
		
		If     aDesp[nDesp] $ "GD5/GE5"
			aRValDes := HS_RValMM(TMPRBASE->CODPLA, TMPRBASE->CODDES,, .F., IIf(cVigencia == "1", SToD(TMPRBASE->DATDES), Nil))
			cCondUpd := "DESP." + aDesp[nDesp] + "_CODDES = '" + TMPRBASE->CODDES + "'" + IIf(cVigencia == "1", " AND DESP." + aDesp[nDesp] + "_DATDES = '" + TMPRBASE->DATDES + "'", "")
			cCodigo  := aRValDes[09]
			cDescri  := aRValDes[10]
		ElseIf aDesp[nDesp] $ "GD6/GE6"
			aRValDes := HS_RValTD(TMPRBASE->CODDES, TMPRBASE->CODPLA,, .F., IIf(cVigencia == "1", SToD(TMPRBASE->DATDES), Nil))
			cCondUpd := "DESP." + aDesp[nDesp] + "_CODDES = '" + TMPRBASE->CODDES + "'" + IIf(cVigencia == "1", " AND DESP." + aDesp[nDesp] + "_DATDES = '" + TMPRBASE->DATDES + "'", "")
			cCodigo  := aRValDes[07]
			cDescri  := aRValDes[08]
		ElseIf aDesp[nDesp] $ "GD7/GE7"
			aRValDes := HS_RValPr(TMPRBASE->CODDES, TMPRBASE->CODPLA, TMPRBASE->CODLOC,, TMPRBASE->URGDES,,,, .F., IIf(cVigencia == "1", SToD(TMPRBASE->DATDES), Nil))
			cCondUpd := "DESP." + aDesp[nDesp] + "_CODDES = '" + TMPRBASE->CODDES + "' AND DESP." + aDesp[nDesp] + "_URGDES = '" + TMPRBASE->URGDES + "'" + IIf(cVigencia == "1", " AND DESP." + aDesp[nDesp] + "_DATDES = '" + TMPRBASE->DATDES + "'", "")
			cCodigo  := aRValDes[02][15]
			cDescri  := aRValDes[02][18]
		EndIf
		
		sSql := "UPDATE " + RetSqlName(aDesp[nDesp]) + " DESP " + ;
		"SET DESP." + aGrvs[nDesp][1] + " = '" + cCodigo + "', DESP." + aGrvs[nDesp][2] + " = '" + cDescri + "' "
		If TMPRBASE->NTOTDESP > 1
			sSql += "WHERE DESP.D_E_L_E_T_ <> '*' AND DESP." + aDesp[nDesp] + "_FILIAL = '" + xFilial(aDesp[nDesp]) + "' AND " + cCondUpd + " AND " + ;
			"DESP." + aDesp[nDesp] + "_NRSEQG IN (SELECT GCZ.GCZ_NRSEQG FROM " + RetSqlName("GCZ") + " GCZ " + ;
			"WHERE GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.GCZ_NRSEQG = DESP." + aDesp[nDesp] + "_NRSEQG AND " + ;
			"GCZ.GCZ_CODPLA = '" + TMPRBASE->CODPLA + "')"
		Else
			sSql += "WHERE DESP.R_E_C_N_O_ = " + AllTrim(Str(TMPRBASE->NRECNO))
		Endif
		
		If cMConsole == "1"
			cHoraIni := Time()
		EndIf
		
		TCSqlExec(sSql)
		
		If cMConsole == "1"
			cHoraSql := HS_TotHoras(cHoraIni, Time(), "-", .T., .F.)
		EndIf
		
		DbSelectArea("TMPRBASE")
		DbSkip()
	End
	
	DbCloseArea()
	
Next

Return(Nil)

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GFRIMP บ Autor ณ Jos้ Orfeu         บ Data ณ  21/02/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Elimina duplicidades no arquivo de Guias (GCZ)             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHSPGFRIMP บ Autor ณ Eduardo Alves      บ Data ณ  24/04/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Programa para importa็ใo dos dados da X5/EM para GFR.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HSPGFRIMP()

If MsgYesNo("Confirma processamento?")
	
	Processa({|| FS_GFRIMP()})
	
EndIf

Return(Nil)

Function HS_GFRIMP()

Local cSql 			:= ""

Local nHandle := fCreate("GFRIMPORT.Log", 0)

//Deleta Registros da GFR para nใo haver duplicidade caso seja rodada a rotina mais de uma vez.
TCSqlExec("DELETE FROM " + RetSqlName("GFR"))

cSql := " SELECT X5_CHAVE CHAVE, X5_DESCRI DESCRI "
cSql += " FROM " + RetSQLName("SX5") + " SX5"
cSql += " WHERE SX5.X5_FILIAL = '" +  xFilial("SX5") + "'"
cSql += "   AND SX5.D_E_L_E_T_ <> '*'"
cSql += "   AND SX5.X5_TABELA = 'EM' "

cSQL :=  ChangeQuery(cSQL)

TCQUERY cSQL NEW ALIAS "QRY"
DbSelectArea("QRY")
DbGoTop()

ProcRegua(0)

FS_LogProc(nHandle, "Registro(s) invแlidos - Especialidade(s) nใo importada(s):")
FS_LogProc(nHandle, Replicate("-", 80))
FS_LogProc(nHandle, Replicate(" ", 80))

Begin Transaction

While !Eof()
	
	IncProc("Importando Especialidade [" + QRY->CHAVE + "] - [" + QRY->DESCRI + "] da X5/EM para GFR.")
	
	If Len(AllTrim(QRY->CHAVE)) <= 2
		
		DbSelectArea("GFR")
		RecLock("GFR", .T.)
		GFR->GFR_FILIAL 	:= xFilial("GFR")
		GFR->GFR_CDESPE		:= AllTrim(QRY->CHAVE)
		GFR->GFR_DSESPE 	:= SUBSTR(X5DESCRI(), 1, 50)
		GFR->GFR_LOGARQ 	:= HS_LogArq()
		MsUnLock()
	Else
		FS_LogProc(nHandle, "Registro nใo importado: [" + QRY->CHAVE + "] - [" + SUBSTR(QRY->DESCRI, 1, 50) + "]")
	Endif
	
	DbSelectArea("QRY")
	DbSkip()
EndDo

End Transaction

DbCloseArea()

fClose(nHandle)

HS_MsgInf("Verifique o arquivo GFRIMPORT.LOG no diretorio system para maiores detalhes", "Processamento finalizado", "HSPGFRIMP")
Return


/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_TCSqRegบ Autor ณ Patricia Queiroz   บ Data ณ  02/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Preenche o campo SEQREG de forma sequencial                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_TCSqReg()
 If MsgYesNo("Confirma processamento?")
	
	 Processa({|| FS_TCSqReg()})
	
 EndIf
Return(Nil)

Static Function FS_TCSqReg
 Local nTot  := 0
 Local cSql  := ""
 Local nCont := 0
 Local aVet  := {"GM9","GMA","GML","GMM"}
 
	Begin Transaction
 	
	For nCont := 1 to Len(aVet)
	
 	cSQL:= "SELECT R_E_C_N_O_ NOREC "  
 	cSQL+= " FROM "+RetSQLName(avet[nCont])+" "+avet[nCont]
 	cSQL+= " WHERE " + avet[nCont] + "_FILIAL = " + xFilial(avet[nCont]) + " AND " + avet[nCont] + ".D_E_L_E_T_ <> '*'"
 	cSQL+= " ORDER BY " + avet[nCont] + "_DATCAN, " + avet[nCont] + "_HORCAN"
	
	 cSQL := ChangeQuery(cSQL)
	 TCQUERY cSQL NEW ALIAS "QRY"
	
	 ProcRegua(&(avet[nCont])->(RecCount()))
	 DbSelectArea("QRY")
	 DbGoTop()
	 nTot := 0
	 While !EOF()
	 	IncProc("Tabela " + aVet[nCont] + " - SEQREG = " + PadL(Alltrim(str(nTot)), 12, "0"))
		 nTot ++
 		cQry := "UPDATE " + RetSqlName(avet[nCont]) + " SET " + avet[nCont] + "_SEQREG ='" + PadL(Alltrim(str(nTot)), 12, "0") + "'"
	 	cQry += " WHERE R_E_C_N_O_ = " + Str(QRY->NOREC) 
	 	TcSqlExec(cQry)
	 	DbSelectArea("QRY")
	 	DbSkip()
	 EndDo
	 DbCloseArea()
 Next nCont

 End Transaction
 MsgStop("Processamento finalizado com sucesso!")
Return(Nil)  

/*   
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GSHAgTCบ Autor ณ Patricia Queiroz   บ Data ณ  05/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Altera os campos GSH_CHAVE e GSH_ORDEM para a chave SEQREG บฑฑ
ฑฑบ          ณ e a ordem 4.                                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_GSHAgTC()

If MsgYesNo("Confirma processamento?")
	
	Processa({|| FS_GSHAgTC()})
	
EndIf
Return(Nil)

Static Function FS_GSHAgTC

Local nCont := 0
Local aVet  := {"GM9", "GMA", "GML", "GMM"}

For nCont := 1 to Len(aVet)
	
	DbSelectArea("GSH")
	DbSetOrder(1)
	DbGoTop()
	
	Begin Transaction
	While !EOF()
		If GSH->GSH_TABELA == aVet[nCont]
			DbSelectArea(aVet[nCont])
			DbSetOrder(val(GSH->GSH_ORDEM))
			If DbSeek(GSH->GSH_CHAVE)
				RecLock("GSH", .F.)
				GSH->GSH_CHAVE := &(aVet[nCont] + "->" + aVet[nCont] + "_SEQREG")
				GSH->GSH_ORDEM := "4"
				MsUnLock()
			EndIf
		EndIf
		DbSelectArea("GSH")
		DbSkip()
	EndDo
	End Transaction
Next nCont

Return (Nil)  


/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GrvGD7 บ Autor ณ Jose Orfeu         บ Data ณ  15/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Grava GD7                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/   

Function HS_GrvGD7()
 Local aCampos := {}
 Local cArqTmp := ""
 Local oTempTRB
 
  If !Pergunte("GRVGD7")
	 Return(Nil)
 EndIf
 
 aCampos := {{"LINHA"  , "C", 006, 0}, ;
            {"CRITICA", "C", 132, 0}}
 
//--< Cria็ใo do objeto FWTemporaryTable >---
oTempTRB := FWTemporaryTable():New( "TGD" )
oTempTRB:SetFields( aCampos )
oTempTRB:AddIndex( "INDTGD",{ "LINHA" } )

if( select( "TGD" ) > 0 )
	TGD->( dbCloseArea() )
endIf

oTempTRB:Create()

 Processa({|| FS_GrvGd7()})

if( select( "TGD" ) > 0 )
	oTempTRB:Delete()
endIf
 
Return(Nil)

Static Function FS_GrvGd7()
 Local cMask    := PadR("Texto (*.txt)",27) + "|*.txt|" + PadR("Todos (*.*)",27)+ "|*.*|" //"Texto (*.txt)"###"Todos (*.*)"
 Local cRegAte  := ""
 Local cCodTpg  := ""
 Local dDatDes  := CTOD("")
 Local cHorDes  := ""
 Local cCodDes  := ""
 Local nQtdDes  := 0
 Local mArquivo := ""
 Local mTexto   := ""
 Local nTotLin  := 0 
 Local nLinAtu  := 0          
 Local cLinha   := ""
 Local cMensRet := ""
 Local aRValDes := {}                       
 
 Local cMV_AteSus := GetMv("MV_ATESUS",, "N")
 Local __cCodBPA  := ""
 Local __cCodPAC  := ""
 Local __cCodAIH  := ""
 Local aVParam    := {}
	
	// Verifica se o parametro MV_ATESUS esta setado para SIM, ou seja, o Hospital atende o Plano SUS
 If cMV_AteSus == "S" 
  aVParam := {{"MV_PCONSUS", ""},{"MV_PSUSBPA", ""},{"MV_PSUSPAC", ""},{"MV_PSUSAIH", ""}}
  If !HS_VMVSUS(@aVParam)
	  Return(Nil)
	 Else
   __cCodBPA := aVparam[2][2]
   __cCodPAC := aVparam[3][2]
   __cCodAIH := aVparam[4][2]
   aVparam := Nil
  EndIf
	EndIf
 
 // TIPO ATENDIMENTO : 0=INTERN 1=AMBUL 2=PRONT ATEN
 If Empty(mArquivo := AllTrim(cGetFile(OemToAnsi(cMask), OemToAnsi("Selecione o Arquivo"), 0,, .F., GETF_ONLYSERVER))) //"Selecione o Arquivo"
 	Return(Nil)
 EndIf
 
 DbSelectArea("GBJ")
 DbSetOrder(1)
 DbSeek(xFilial("GBJ") + MV_PAR01)
 
 mTexto  := MemoRead(mArquivo)
 nTotLin := MLCount(mTexto, 254)
 
 ProcRegua(nTotLin)
 
 Begin Transaction 
 
  For nLinAtu := 1 To nTotLin
 	 cLinha  := MemoLine(mTexto, 254, nLinAtu)
 	 cRegAte := SubStr(cLinha, 4, 6)
 	
 	 If Empty(cRegAte)
	  	Loop
	  EndIf
	 
	  dDatDes := CTOD(SubStr(cLinha, 10, 10))
	  cHorDes := SubStr(cLinha, 20, 2) + ":" + SubStr(cLinha, 22, 2)
	  cCodDes := SubStr(cLinha, 25, 8) + " "
	  nQtdDes := Val(SubStr(cLinha, 33, 2))
	 
	  IncProc("Importando: Linha Nบ." + Str(nLinAtu, 6) + "-Reg. Nบ." + cRegAte)
		
	  DbSelectArea("GCY")
	  DbSetOrder(1)
	 
	  If DbSeek(xFilial("GCY") + cRegAte)
	  
	   If GCY->GCY_TPALTA == "99"
	     DbSelectArea("TGD")
		 	  RecLock("TGD", .T.)
		 	  TGD->LINHA   := StrZero(nLinAtu, 6)
		 	  TGD->CRITICA := "Posicao 001 a 009 - Atendimento Cancelado - " + SubStr(cLinha, 1, 9)
		 	  MSUNLOCK()
		 	 	Loop
	   EndIf
	    
		  If GCY->GCY_ATENDI == "0"
			   cCodTpg := MV_PAR02
		  ElseIf GCY->GCY_ATENDI == "1"
			   cCodTpg := MV_PAR03
		  ElseIf GCY->GCY_ATENDI == "2"
			   cCodTpg := MV_PAR04
		  EndIf
		   
	   DbSelectArea("GD4")
	   DbSetOrder(2)
	   If DbSeek(xFilial("GD4") + GCY->GCY_REGGER + "1")
	     If GD4->GD4_DTVALI < dDataBase
	      DbSelectArea("TGD")
		 	   RecLock("TGD", .T.)
		 	   TGD->LINHA   := StrZero(nLinAtu, 6)
		 	   TGD->CRITICA := "Posicao 001 a 009 - O plano estแ com a validade vencida - " + SubStr(cLinha, 1, 9)
		 	   MSUNLOCK()
		 	 	 Loop
	     EndIf
	   Else
     DbSelectArea("TGD")
		 	 RecLock("TGD", .T.)
		 	 TGD->LINHA   := StrZero(nLinAtu, 6)
		 	 TGD->CRITICA := "Posicao 001 a 009 - Paciente nใo possui plano padrao - " + SubStr(cLinha, 1, 9)
		 	 MSUNLOCK()
		 	 Loop	   
	   EndIf
	  
	   DbSelectArea("GCZ")
	   DbSetOrder(15)
	   If !DbSeek(xFilial("GCZ") + cRegAte + cCodTpg)
		   M->GCZ_NRSEQG := HS_VSxeNum("GCZ", "M->GCZ_NRSEQG", 1)
     ConfirmSx8()
      
		   RecLock("GCZ", .T.)    
		    GCZ->GCZ_FILIAL := xFilial("GCZ")
      GCZ->GCZ_REGATE := cRegAte
      GCZ->GCZ_DATATE := GCY->GCY_DATATE
      GCZ->GCZ_REGGER := GCY->GCY_REGGER
      GCZ->GCZ_CODTPG := cCodTpg
      GCZ->GCZ_CODCON := GD4->GD4_CODCON
      GCZ->GCZ_CODPLA := GD4->GD4_CODPLA
      GCZ->GCZ_CODCRM := GBJ->GBJ_CRM
      GCZ->GCZ_STATUS := "1"
      GCZ->GCZ_DATSTA := dDataBase
      GCZ->GCZ_NRSEQG := M->GCZ_NRSEQG
      GCZ->GCZ_CANCEL := "0"
      GCZ->GCZ_LOGARQ := HS_LogArq()
      GCZ->GCZ_DTGERA := dDataBase
      GCZ->GCZ_HRGERA := Time()
      GCZ->GCZ_USGERA := cUsuario
      GCZ->GCZ_ATENDI := GCY->GCY_ATENDI
      GCZ->GCZ_LOCATE := GCY->GCY_LOCATE 
      If Hs_ExisDic({{"C", "GCZ_FILFAT"}}) 
							GCZ->GCZ_FILFAT := HS_RetFilF(GCZ->GCZ_CODCON, GCZ->GCZ_CODPLA, GCZ->GCZ_LOCATE, GCZ->GCZ_CODTPG)
       GCZ->GCZ_FILATE := cFilAnt
      EndIf 
		   MsUnlock()
		  EndIf 
		 Else
		 	DbSelectArea("TGD")
		 	RecLock("TGD", .T.)
		 	 TGD->LINHA   := StrZero(nLinAtu, 6)
		 	 TGD->CRITICA := "Posicao 001 a 009 - Atendimento/Paciente nใo Encontrado - " + SubStr(cLinha, 1, 9)
		 	MSUNLOCK()
		 	Loop
	  EndIf
	  
	  If GCZ->GCZ_STATUS <= "1"
	  	If GCY->GCY_ATENDI == "2"
	    dDatDes := GCY->GCY_DATATE
	    cHorDes := GCY->GCY_HORATE
	   Endif
	  	DbSelectArea("GD7")
	  	DbSetOrder(7)
	  	If !DbSeek(xFilial("GD7") + GCZ->GCZ_NRSEQG + cCodDes + DTOS(dDatDes) + cHorDes)
	  		aRValDes := HS_RValPr(cCodDes, GCZ->GCZ_CODPLA, GCY->GCY_CODLOC, cHorDes, IIf(GCY->GCY_ATENDI == "2", "1", "0"), GBJ->GBJ_CRM,, {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO}, .F., dDatDes)
	  		        
	  		If aRValDes[1] == 0
		 			M->GD7_SEQDES := HS_VSxeNum("GD7", "M->GD7_SEQDES", 1)
		 			ConfirmSx8()     
		 			
	  	 	RecLock("GD7", .T.)
	  	 	 GD7->GD7_FILIAL := xFilial("GD7")
       GD7->GD7_CODLOC := GCY->GCY_CODLOC
       GD7->GD7_DATDES := dDatDes
       GD7->GD7_HORDES := cHorDes
       GD7->GD7_QTDDES := nQtdDes
       GD7->GD7_CODDES := cCodDes
       GD7->GD7_COEDES := 1
       GD7->GD7_COEFAM := aRValDes[02][01][02]
       GD7->GD7_VALDES := aRValDes[02][01][01]
       GD7->GD7_VFILME := aRValDes[02][03]
       GD7->GD7_VCUSOP := aRValDes[02][02]
       GD7->GD7_PCUDES := aRValDes[03]
       GD7->GD7_URGDES := aRValDes[02][14]
       GD7->GD7_GLODES := IIf(aRValDes[04][01], "2", "0")
       GD7->GD7_COECHP := aRValDes[02][10]
       GD7->GD7_QTDCHP := aRValDes[2][11]
       GD7->GD7_CODCRM := GBJ->GBJ_CRM
       GD7->GD7_CODESP := aRValDes[07]
       GD7->GD7_PGTMED := aRValDes[9][1]
       GD7->GD7_COECHM := aRValDes[9][aRValDes[11]]
       GD7->GD7_REPAMB := aRValDes[9][aRValDes[10]]
       GD7->GD7_CODPRE := aRValDes[14]
       GD7->GD7_CODPRT := aRValDes[2][15]
       GD7->GD7_DESPRT := aRValDes[2][18]
       
       If cMV_AteSus == "S" // Se atende SUS
        If GCZ->GCZ_CODPLA == __cCodBPA // Se atende SUS e o tipo de plano eh BPA
         GD7->GD7_CDGATE := aRValDes[15][2][1]
         GD7->GD7_CDTATE := aRValDes[15][3][1]
        EndIf
       EndIf               
      
       GD7->GD7_VALREP := nQtdDes * aRValDes[9][14]
       GD7->GD7_SEQDES := M->GD7_SEQDES
       GD7->GD7_NRSEQG := GCZ->GCZ_NRSEQG
       GD7->GD7_REGATE := GCY->GCY_REGATE
       GD7->GD7_FATPAR := aRValDes[4][2] 
       GD7->GD7_SLAUDO := "0"
       GD7->GD7_LOGARQ := HS_LogArq()
       GD7->GD7_DOPLER := "0"
       GD7->GD7_VLRCOS := aRValDes[2][24]
				 	MsUnlock()
				 Else
					 DbSelectArea("TGD")
					 		
					 If aRValDes[01] == 4
  				 cMensRet := "Nใo foi possivel encontrar uma tabela de "
  				 RecLock("TGD",.T.)
						  TGD->LINHA   := StrZero(nLinAtu, 6)
						  TGD->CRITICA := "Posicao 001 a 009 - " + cMensRet + " - " + SubStr(cLinha, 1, 9)
						 MsUnLock()
						
						 cMensRet := "procedimento para formula็ใo do pre็o do "
						 RecLock("TGD",.T.)
						  TGD->LINHA   := StrZero(nLinAtu, 6)
						  TGD->CRITICA := "Posicao 001 a 009 - " + cMensRet + " - " + SubStr(cLinha, 1, 9)
						 MsUnLock()
						
						 cMensRet := "procedimento, configure uma ou mais tabelas "
						 RecLock("TGD", .T.)
						 	TGD->LINHA   := StrZero(nLinAtu, 6)
						  TGD->CRITICA := "Posicao 001 a 009 - " + cMensRet + " - " + SubStr(cLinha, 1, 9)
						 MsUnLock()
						   
						 cMensRet := "de procedimentos no cadastro de convenio / planos"
  					RecLock("TGD",.T.)
  						TGD->LINHA   := StrZero(nLinAtu, 6)
						  TGD->CRITICA := "Posicao 001 a 009 - " + cMensRet + " - " + SubStr(cLinha, 1, 9)
						 MsUnLock()       		   				
						Else
						 cMensRet := aRValDes[05]
						 RecLock("TGD", .T.)
						  TGD->LINHA   := StrZero(nLinAtu, 6)
					   TGD->CRITICA := "Posicao 001 a 009 - " + cMensRet + " - " + SubStr(cLinha, 1, 9)
					  MsUnLock()
						EndIf 
					EndIf
 			Else
				 DbSelectArea("TGD")
				 RecLock("TGD",.T.)
				  TGD->LINHA   := StrZero(nLinAtu, 6)
				  TGD->CRITICA := "Posicao 001 a 009 - Paciente ja foi Importado - " + SubStr(cLinha, 1, 9)
				 MSUNLOCK()
			 EndIf
		 Else
		  DbSelectArea("TGD")
		  RecLock("TGD",.T.)
		   TGD->LINHA   := StrZero(nLinAtu, 6)
		   TGD->CRITICA := "Posicao 001 a 009 - Reg. Pac. Bolqueado ou Faturado - " + SubStr(cLinha, 1, 9)
		  MsUnLock()
		 EndIf
		
  Next
 
 End Transaction 
 
 DbSelectArea("TGD")
 DbGoTop()
 If !Empty(TGD->LINHA)
 	FS_LogGd7(mArquivo)
 EndIf
Return(NIl)

Static Function FS_LogGd7(mArquivo)
 Local cDesc1  := "Este programa tem como objetivo imprimir relatorio "
 Local cDesc2  := "de acordo com os parametros informados pelo usuario."
 Local cDesc3  := ""
 Local cPict   := ""
 Local titulo  := "Rela็ใo de Crํticas - Importa็ใo"
 Local nLin    := 80
 Local Cabec1  := "Arquivo: " + mArquivo
 Local Cabec2  := " Linha   Descri็ใo do Erro"
 Local imprime := .T.
 Local aOrd    := {}

 Private lEnd        := .F.
 Private lAbortPrint := .F.
 Private CbTxt       := ""
 Private limite      := 80
 Private tamanho     := "M"
 Private nomeprog    := "ImprGD7" // Coloque aqui o nome do programa para impressao no cabecalho
 Private nTipo       := 15
 Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
 Private nLastKey    := 0
 Private cbcont      := 00
 Private CONTFL      := 01
 Private m_pag       := 01
 Private wnrel       := "ImprGD7" // Coloque aqui o nome do arquivo usado para impressao em disco
 
 wnrel := SetPrint("GD7", NomeProg, "", @titulo, cDesc1, cDesc2, cDesc3, .T., aOrd, .T., Tamanho,, .T.)
 
 If nLastKey == 27
 	Return(Nil)
 EndIf
 
 SetDefault(aReturn, "GD7")

 If nLastKey == 27
 	Return(Nil)
 EndIf

 nTipo := If(aReturn[4] == 1, 15, 18)

 RptStatus({|| RunReport(Cabec1, Cabec2, Titulo, nLin)}, Titulo)
 
 DbSelectArea("GD7")
 DbSetOrder(1)
 
Return(Nil)

Static Function RunReport(Cabec1, Cabec2, Titulo, nLin)

 DbSelectArea("TGD")
 DbSetOrder(1)

 SetRegua(RecCount())
 
 DbGoTop()
 While !EOF()
	 If lAbortPrint
	 	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	 	Exit
	 EndIf
	
	 If nLin > 55
	 	Cabec(Titulo, Cabec1, Cabec2, NomeProg, Tamanho, nTipo)
	 	nLin := 9
	 EndIf
	
	 @ nLin,00 PSAY TGD->LINHA + "   " + TGD->CRITICA
	 
	 nLin++
	 
	 DbSkip()
 End

 If aReturn[5]==1
	 OurSpool(wnrel)
 EndIf

 MS_FLUSH()
Return(Nil)

Function HS_VldPerg()
 Local lRet := .F.
 
 If ReadVar() == "MV_PAR01"
  DbSelectArea("GBJ")
  DbSetOrder(1)
  If !(lRet := DbSeek(xFilial("GBJ") + MV_PAR01))
   MsgInfo("Medico nao encontrado", "Aten็ใo")
  EndIf
 Else                              
  DbSelectArea("GCU")
  DbSetOrder(1)
  If !(lRet := DbSeek(xFilial("GBJ") + &(ReadVar())))
   MsgInfo("Tipo de guia nao encontrado", "Aten็ใo")
  EndIf
 EndIf
 
Return(lRet)                  

/*
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_PRECONVบ Autor ณ Mario Arizono      บ Data ณ  24/05/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Preenche sequencialmente o campo item das tabelas no       บฑฑ
ฑฑบ          ณ diferenciados do convenio.																																	บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_PreConv()

If MsgYesNo("Confirma processamento?")
	
	Processa({|| FS_PreConv()})                              
	
EndIf

Static Function FS_PreConv()

Local aAlias   := {"GC6", "GD8", "GD9", "GDA", "GDF", "GC1"}
Local cSql     := ""
Local cItem    := ""     
Local cCodPla  := ""
Local nAlias   := 0
ProcRegua(0)

For nAlias := 1 To Len(aAlias)
 cSql := "SELECT " + aAlias[nAlias] + "_CODPLA CODPLA, R_E_C_N_O_ RECNO FROM " + RetSqlName(aAlias[nAlias]) + " " + ;
	"WHERE D_E_L_E_T_ <> '*' AND " + aAlias[nAlias] + "_FILIAL = '"+xFilial(aAlias[nAlias])+"' " 
	If aAlias[nAlias] == "GC6"  //Plano X Tabela de Procedimento
	 cSql += "ORDER BY " + aAlias[nAlias] + "_FILIAL, " + aAlias[nAlias] + "_CODPLA, " + aAlias[nAlias] +;
	         "_TABPRO, "+ aAlias[nAlias] + "_DATVIG, " + aAlias[nAlias] + "_PRIORI"
	ElseIf aAlias[nAlias] == "GD8" //Plano X Tabela de pre็o (Tax/Dia)
 	cSql += "ORDER BY " + aAlias[nAlias] + "_FILIAL, " + aAlias[nAlias] + "_CODPLA, " + aAlias[nAlias] +;
	         "_CODTXD, "+ aAlias[nAlias] + "_DATVIG, " + aAlias[nAlias] + "_PRIORI"
	ElseIf aAlias[nAlias] == "GD9" //Plano X Tabela de pre็o (Material)
 	cSql += "ORDER BY " + aAlias[nAlias] + "_FILIAL, " + aAlias[nAlias] + "_CODPLA, " + aAlias[nAlias] +;
	         "_CODMAT, "+ aAlias[nAlias] + "_DATVIG, " + aAlias[nAlias] + "_PRIORI"
	ElseIf aAlias[nAlias] == "GDA" //Plano X Tabela de pre็o (Medicamento)
 	cSql += "ORDER BY " + aAlias[nAlias] + "_FILIAL, " + aAlias[nAlias] + "_CODPLA, " + aAlias[nAlias] +;
	         "_CODMED, "+ aAlias[nAlias] + "_DATVIG, " + aAlias[nAlias] + "_PRIORI"
	ElseIf aAlias[nAlias] == "GDF" //Plano X Tabela de pre็o (Rest/Frig)
 	cSql += "ORDER BY " + aAlias[nAlias] + "_FILIAL, " + aAlias[nAlias] + "_CODPLA, " + aAlias[nAlias] +;
	         "_CODRES, "+ aAlias[nAlias] + "_DATVIG, " + aAlias[nAlias] + "_PRIORI"
	ElseIf aAlias[nAlias] == "GC1" //Vigencia de plano
 	cSql += "ORDER BY " + aAlias[nAlias] + "_FILIAL, " + aAlias[nAlias] + "_CODPLA, " + aAlias[nAlias] +;
	         "_DATVIG"
	Endif
	                                   	         
	TCQuery cSql New Alias "TMPCONV"

	cItem := StrZero(0,len(&(aAlias[nAlias]+"->"+aAlias[nAlias]+"_ITEPLA"))) 	
	While !Eof()  
		
	 IncProc("Processando Tabela [" + aAlias[nAlias] + "] Plano [" + TMPCONV->CODPLA + "] ")
		
		If TMPCONV->CODPLA <> cCodPla .AND. !Empty(cCodPla)
		 cItem := StrZero(0,len(&(aAlias[nAlias]+"->"+aAlias[nAlias]+"_ITEPLA"))) 
  Endif
		 DbSelectArea(aAlias[nAlias])
		 DbGoto(TMPCONV->RECNO)
		 
		 cItem := soma1(cItem)
			Begin Transaction
		
		  RecLock(aAlias[nAlias],.F.)
		 		&(aAlias[nAlias]+"->"+aAlias[nAlias]+"_ITEPLA") := cItem
		 	MsUnLock()
						
		 End Transaction				
		
	 cCodPla := TMPCONV->CODPLA
	 DbCloseArea()
	 DbSelectArea("TMPCONV")
	 DbSkip()   
	End 
	cCodPla := ""
	DbCloseArea()
Next

Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GrvSPlaบAutor  ณDaniel Peixoto      บ Data ณ  09/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o status dos Planos que estao em Branco               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_GrvSPla()
                
 If MsgyesNo("Confirma processamento")
  Processa({|| FS_GrvSPla()})          
 EndIf 
 
Return(Nil)                 

Static Function FS_GrvSPla()

 //Grava valor default(ATIVADO) no campo Status do Plano
 DBSelectArea("GCM")
 DBSetOrder(2)
 DBSeek(xFilial("GCM"))     
 
 ProcRegua(GCM->(RecCount()))

 While !Eof() .And. GCM->GCM_FILIAL == xFilial("GCM")
 
  IncProc("Grava o Status do Plano [" + GCM->GCM_CODPLA + "]") 
 
  If Empty(GCM->GCM_STATUS)
   RecLock("GCM", .F.)
    GCM->GCM_STATUS := "1"
   MsUnLock()
  EndIf 
                                                     
  DBSkip()
 EndDo
 
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GrvAnePบAutor  ณDaniel Peixoto      บ Data ณ  09/06/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o valor default SIM no campo Cobre Anestesia do Pacoteบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_GrvAneP()
                
 If MsgyesNo("Confirma processamento")
  Processa({|| FS_GrvAneP()})          
 EndIf 
 
Return(Nil)                 

Static Function FS_GrvAneP()

 //Grava valor default(SIM) no campo Cobre Anestesia do Pacote
 DBSelectArea("GP0")
 DBSetOrder(1)//CODPRO + CODCON
 DBSeek(xFilial("GP0"))     
 
 ProcRegua(GP0->(RecCount()))

 While !Eof() .And. GP0->GP0_FILIAL == xFilial("GP0")
 
  IncProc("Grava o Campo Anestesia do Pacote [" + GP0->GP0_CODPRO + "]") 
 
  If Empty(GP0->GP0_ANESTE)
   RecLock("GP0", .F.)
    GP0->GP0_ANESTE := "1"
   MsUnLock()
  EndIf 
                                                     
  DBSkip()
 EndDo
 
Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GSBTEndบAutor  ณCibele Peria        บ Data ณ  05/08/06   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInicializar o campo GSB_TIPEND, alterado de virtual para    บฑฑ
ฑฑบ          ณreal, a partir do GSD-TIPEND.                               บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_GSBTEnd()
 DbSelectArea("GSB")
 If MsgYesNo("(Filial " + xFilial("GSB") + " - Confirma processamento?")
	
	 Processa({|| FS_GSBTEnd()})
	
 EndIf
Return() 

Static Function FS_GSBTEnd()
 DbSelectArea("GSB")
 DbSetOrder(1)
 While !Eof() .And. GSB->GSB_FILIAL == xFilial("GSB")
  If Empty(GSB->GSB_TIPEND)
   RecLock("GSB", .F.)
    GSB->GSB_TIPEND := HS_IniPadr("GSD", 1, GSB->GSB_CODEND, "GSD_TIPEND") 
   MsUnLock()
  Endif
  
  DbSelectArea("GSB")
  DbSkip()
 End 
Return() 
