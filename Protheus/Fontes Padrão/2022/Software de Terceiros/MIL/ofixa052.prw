#include "protheus.ch"
#include "OFIXA052.ch"
#include "fileio.ch"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXA052   | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Geração de Arquivos Históricos do DEF (VDB/VDC)              |##
##|          |                                                              |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXA052()
// Variaveis da ParamBox
Local aSay    := {}
Local aButton := {}
Local nOpc    := 0
//
Local cTitulo := STR0001
Local cDesc1  := STR0002
Local cDesc2  := " "
Local cDesc3  := " "
//
Private cPerg 			:= "OXA052"
Private dPARDataFinal
Private cPARCodDef
Private aCCTotal		:= {}
//

//
// Validacao de Licencas DMS
//
If !OFValLicenca():ValidaLicencaDMS()
	Return
EndIf

aAdd( aSay, cDesc1 )
aAdd( aSay, cDesc2 )
aAdd( aSay, cDesc3 )
//
aAdd( aButton, { 5, .T., {|| Pergunte(cPerg,.T. )    }} )
aAdd( aButton, { 1, .T., {|| nOpc := 1, FechaBatch() }} )
aAdd( aButton, { 2, .T., {|| FechaBatch()            }} )
//
// Perguntas 
// 01 - Codigo DEF - C - TamSX3("VD7_CODDEF")[1]
// 02 - Data Final - D 
// 03 - Filial - N - 1  - Combo: 1 - Filial Logada / 2 - Selecionar Filiais / 3 -Todas Filiais
// 04 - Item DEF - C - TamSX3("VD9_CODCON")[1]
// 05 - Campo DEF C 6 
// 06 - Grava Detalhamento DEF ? N - 1  - Combo: 1 - Sim / 2 - Nao 
Pergunte(cPerg,.f.)
//
FormBatch( cTitulo, aSay, aButton )
//
If nOpc <> 1
	Return
Endif
//#############################################################################
//# Chama a rotina de importacao do retorno do aviso de vendas GM             #
//#############################################################################
oProcTTP := MsNewProcess():New({ |lEnd| OX052RunProc() }," ","",.f.)
oProcTTP:Activate()
//
Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | RunProc    | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Geração do Histórico do DEF                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OX052RunProc(lEnd, cPCodDef, cPCodCon, dPFechamento, lGravarDados)
	//
	Local nCntFor
	Local lVisualDados := .f.
	Local cAliasA		:= GetNextAlias()
	Local nCCValTot
	Local aFilAux       := {}
	Local aFilExec      := {}
	Local nFilExec      := 0
	Local cBkpFil       := cFilAnt
	Local lMsgFinal     := .f.
	Local nTamCPODEF
	Local nCondLike
	//
	Default cPCodDef     := MV_PAR01
	Default dPFechamento := MV_PAR02
	Default cPCodCon     := Alltrim(MV_PAR04)
	Default lGravarDados := .t.
	//
	// Quando lGravarDados é FALSO os dados serão guardados em MEMORIA para a Consulta de Log de Calculo (OXA053LogCalculo)
	// A consulta de Log de Calculo é Anterior a funcionalidade de gravacao dos detalhes do calculo 
	Private cPARCpoDEF   := IIf( lGravarDados , MV_PAR05 , "" )
	Private lGrvDetalhes := IIf( lGravarDados , (MV_PAR06 == 1) , .f.) // 1=Sim
	//
	Private oVisualLog
	//
	Private cPARCodDef		:= cPCodDef
	Private dPARDataFinal	:= dPFechamento
	Private dOXA052			:= dPARDataFinal // Legado
	Private cVD7CCESTR
	Private cCpoDEFCt
	//
	Private dDataFim := dPARDataFinal
	Private dDataIni := ctod("01/"+STRZERO(month(dDataFim),2)+"/"+Right(STRZERO(Year(dDataFim),4),2))
	//
	Private lOA052VAL := ExistBlock("OA052VAL")
	Private lOA052CC1 := ExistBlock("OA052CC1")
	//
	Private lVD9CCUSTA := VD9->(FieldPos("VD9_CCUSTA")) > 0
	Private lVDECCUSTO := VDE->(FieldPos("VDE_CCUSTO")) > 0	
	//
	Private nPosIniEstr := 0
	Private nPosFimEstr := 0
	//
	Private aFilVD8 := {}
	//
	Private lCCComoFilial := .f.
	Private lCCComoFilEst := .f.
	//
	Private aFaltantes := {} // armazena os campos DEF que ainda não foram calculados pois dependem de outros cálculos
	Private aFaltInfo  := {} // armazena os campos DEF que ainda não foram calculados pois dependem de outros cálculos
	Private aResolvidos := {} // armazena os campos que foram calculados
	//
	lVisualDados := !lGravarDados

	Do Case
		Case lVisualDados .or. MV_PAR03 == 1 // Filial Logada
			aFilAux := OX0520141_SelecionarFiliais( .f. , cFilAnt , .t. , cPCodDef ) // Parametros: ( Nao Mostra Tela , Filial Logada , Seleciona linhas     , Codigo DEF )
		Case MV_PAR03 == 2 // Selecionar Filiais
			aFilAux := OX0520141_SelecionarFiliais( .t. , ""      , .f. , cPCodDef ) // Parametros: ( Mostra Tela     ,               , Nao Seleciona linhas , Codigo DEF )
		Case MV_PAR03 == 3 // Todas Filiais
			aFilAux := OX0520141_SelecionarFiliais( .f. , ""      , .t. , cPCodDef ) // Parametros: ( Nao Mostra Tela ,               , Seleciona linhas     , Codigo DEF )
	EndCase
	For nFilExec := 1 to Len(aFilAux)
		If aFilAux[nFilExec,1]
			aAdd(aFilExec,aFilAux[nFilExec]) // Monta vetor somente com as Filiais selecionadas
		EndIf
	Next
	If len(aFilExec) == 0
		ShowHelpDlg(;
			STR0032 ,; // "Filial não encontrada"
			{ STR0033 },5,; // "Filial não encontrada no cadastro do DEF"
			{ STR0034 },5) // "Verifique o cadastro do DEF"
		Return .f. // Nenhuma Filial selecionada
	EndIf

	If !Empty(cPCodCon) .and. !Empty(cPARCpoDEF) // Item DEF e Campo DEF preenchidos juntos
		FMX_Help("OX052ERR1",STR0040,STR0041) // Não é possível informar Item DEF e Campo DEF simultaneamente nos parâmetros da geração do DEF! | Informe apenas Item DEF ou apenas Campo DEF.
		Return .f.
	EndIf

	cPARCpoDEF := AllTrim(cPARCpoDEF)
	cCpoDEFCt := AllTrim( StrTran( cPARCpoDEF, "%", "" ) )
	nTamCPODEF := Len(cCpoDEFCt)
	
	Do Case
	Case Left(cPARCpoDEF,1) == "%" .and. Right(cPARCpoDEF,1) == "%"
		nCondLike := 1
	Case Left(cPARCpoDEF,1) == "%"
		nCondLike := 2
	Case Right(cPARCpoDEF,1) == "%"
		nCondLike := 3
	Otherwise
		nCondLike := 0	
	EndCase

/*
	ConOut(Chr(13) + Chr(10))
	ConOut("------------------------------------------------------------------------")
	ConOut(" #######  ######## #### ##     ##    ###      #####   ########  ####### ")
	ConOut("##     ## ##        ##   ##   ##    ## ##    ##   ##  ##       ##     ##")
	ConOut("##     ## ##        ##    ## ##    ##   ##  ##     ## ##              ##")
	ConOut("##     ## ######    ##     ###    ##     ## ##     ## #######   ####### ")
	ConOut("##     ## ##        ##    ## ##   ######### ##     ##       ## ##       ")
	ConOut("##     ## ##        ##   ##   ##  ##     ##  ##   ##  ##    ## ##       ")
	ConOut(" #######  ##       #### ##     ## ##     ##   #####    ######  #########")
	ConOut("------------------------------------------------------------------------")
*/

	// ===========================================================
	// Em caso de reprocessamento deve apagar o histórico anterior
	// ===========================================================
	If lGravarDados
		If !OX052005_DeletaProc( cPARCodDef , dPARDataFinal , cPARCpoDEF , lGrvDetalhes , aFilExec, cPCodCon, nCondLike )
			Return .f.
		EndIf
	EndIf

	If lGravarDados
		oProcTTP:SetRegua1(Len(aFilExec))
	EndIf
	For nFilExec := 1 to Len(aFilExec)

		//If aFilExec[nFilExec,1]
			
			cFilAnt := aFilExec[nFilExec,2]

			lItemCtComoFilial := .f.
			If VD7->(FieldPos("VD7_CALICT")) <> 0
				If VD7->(DBSeek(xFilial("VD7")+cPARCodDef))
					lItemCtComoFilial := (VD7->(VD7_CALICT) == "1")
				EndIf
			EndIf

			aFilVD8 := {}
			If VD7->(FieldPos("VD7_CALCCT")) <> 0
				If VD7->(DBSeek(xFilial("VD7")+cPARCodDef))
					lCCComoFilial	:= (VD7->(VD7_CALCCT) == "1")
					lCCComoFilEst	:= (VD7->(VD7_CALCCT) == "2")
					If lCCComoFilEst
						cVD7CCESTR		:= VD7->(VD7_CCESTR)
						nPosIniEstr		:= At("#",cVD7CCESTR)
						For nCntFor := 1 to Len(Substr(cVD7CCESTR,nPosIniEstr+nCntFor))
							If nPosFimEstr == 0
								nPosFimEstr	:= At("#",Substr(cVD7CCESTR,nPosIniEstr))
							ElseIf At("#",Substr(cVD7CCESTR,nPosIniEstr+nCntFor)) <> 0
								nPosFimEstr := At("#",Substr(cVD7CCESTR,nPosFimEstr))
							Else
								nPosFimEstr += nCntFor
								Exit
							EndIf	
						Next
						cQuery := "SELECT VD8_CODFIL, VD8_CC "
						cQuery += "  FROM "+ RetSQLName("VD8") + " VD8 "
						cQuery += " WHERE VD8_FILIAL='"+ xFilial("VD8")+"'"
						cQuery += "   AND VD8_CODEMP = '" + cEmpAnt + "' "
						cQuery += "   AND VD8_CODFIL = '" + cFilAnt + "' "
						cQuery += "   AND VD8_CODDEF = '" + cPARCodDef + "' "
						cQuery += "   AND VD8_ATIVO  = '1' "
						cQuery += "   AND D_E_L_E_T_ = ' '"
						DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasA, .f., .t.)
						While !(cAliasA)->(EoF())
							AAdd(aFilVD8, {	AllTrim((cAliasA)->VD8_CODFIL),;	// 01
											AllTrim((cAliasA)->VD8_CC)})		// 02
							(cAliasA)->(dbSkip())
						End
						(cAliasA)->(DbCloseArea())
					EndIf
				EndIf
			EndIf

			aRetDEF := {}
			cQuery  := "SELECT VD8_FUNGER FROM "+RetSqlName("VD8")+" WHERE VD8_FILIAL='"+xFilial("VD8")+"' AND VD8_CODEMP='"+cEmpAnt+"' AND VD8_CODFIL='"+ cFilAnt+"' AND VD8_CODDEF='"+ cPARCodDef+"' AND VD8_ATIVO = '1' AND D_E_L_E_T_=' '"
			cFunGer := FM_SQL(cQuery)
			if !Empty(cFunGer)
				cStrMcro = "aRetDEF := U_"+Alltrim(cFunGer)+"('"+Alltrim(cPARCodDef)+"','"+dtos(dPARDataFinal)+"',"+VD7->VD7_FREQUE+")"
				&(cStrMcro)
			endif

			If lGravarDados
				oProcTTP:IncRegua1(STR0016+" - Filial: "+cFilAnt)
				cQuery := "SELECT COUNT(*) "
				cQuery += "  FROM " + RetSqlName("VD9")
				cQuery += " WHERE VD9_FILIAL = '" + xFilial("VD9") + "'"
				cQuery += "   AND VD9_CODDEF = '" + cPARCodDef + "'"
				If !Empty(cPCodCon) // Filtra codcon especifico
					cQuery += " AND VD9_CODCON = '"+cPCodCon+"'"
				EndIf
				If !Empty(cPARCpoDEF) // Filtra campo DEF especifico
					If nCondLike == 0
						cQuery += " AND VD9_CPODEF = '"+cPARCpoDEF+"'"
					Else
						cQuery += " AND VD9_CPODEF LIKE '"+AllTrim(cPARCpoDEF)+"'"
					EndIf
				EndIf
				cQuery += " AND D_E_L_E_T_= ' '"
				oProcTTP:SetRegua2(FM_SQL(cQuery))
			EndIf

			oVisualLog := OFVisualizaDados():New("OX052DETCALC", STR0018) // "Detalhe do Cálculo"
			If lVisualDados
				OX052004_VisCabec()
			EndIf

			nCCount:= 0 // armazena a contagem de campos processados
			//
			DBSelectArea("VD9")
			DBSeek(xFilial("VD9")+cPARCodDef)
			//
			lAbortou := .f.
			aFaltantes := {} // armazena os campos DEF que ainda não foram calculados pois dependem de outros cálculos
			aFaltInfo  := {} // armazena os campos DEF que ainda não foram calculados pois dependem de outros cálculos
			aResolvidos := {} // armazena os campos que foram calculados

			DBSelectArea("VDA")
			DbSetOrder(1)
			DBSelectArea("VDC")
			DBSetOrder(1) // VDC_FILIAL+VDC_CODDEF+DTOS(VDC_DATA)+VDC_CODCON
			DBSelectArea("VDE")
			DBSetOrder(1)
			DBSelectArea("CT1")
			DBSetOrder(1)
			DBSelectArea("CTT")
			DBSetOrder(1)

			lPrim := .t.
			lPrimFora := .t.

			ConOut(Chr(13) + Chr(10))
			ConOut("OFIXA052 - FILIAL: "+aFilExec[nFilExec,2]+" - INICIO DO PROCESSAMENTO: "+ Dtoc(dDataBase) +" - "+Time())

			BEGIN TRANSACTION
				// ======================================================
				// Enquanto a contagem for zero ou ainda existirem campos
				// faltantes executamos outro laço para cálculo
				// ======================================================
				while nCCount == 0 .or. Len(aFaltantes) > 0 .or. lPrimFora

					if !lPrim
						lPrimFora := .f.
					endif

					nFalAntes := Len(aFaltantes) 	// armazena a quantidade de campos faltantes antes do processamento

					VD9->(DBSeek(xFilial("VD9") + cPARCodDef + IIf( lPrim , cPCodCon , "" ) ))

					// =============================
					// Executa laço calculando o DEF
					// =============================
					while !VD9->(eof()) .and. xFilial("VD9") == VD9->VD9_FILIAL .and. cPARCodDef == VD9->VD9_CODDEF

						if (lPrim .and. VD9->VD9_TIPO $ "25") .or. ( !lPrim .and. !(VD9->VD9_TIPO $ "25") )
							VD9->(DBSkip())
							loop
						endif
						// Pula contas inativas pelo cadastro da conta
						if VD9->VD9_ATIVO == "0"
							VD9->(DBSkip())
							loop
						endif
						
						If !Empty(cPARCpoDEF)
							
							If nCondLike == 0
								If cPARCpoDEF <> VD9->VD9_CPODEF
									VD9->(DBSkip())
									loop
								EndIf
							Else
								Do Case
								Case nCondLike == 1 // LIKE '%zzz%'
									If cCpoDEFCt $ VD9->VD9_CPODEF
									Else
										VD9->(dbSkip())
										Loop
									EndIf
								Case nCondLike == 2 // LIKE '%zzz'
									If Right(AllTrim(VD9->VD9_CPODEF),nTamCPODEF) == cCpoDEFCt
									Else
										VD9->(dbSkip())
										Loop
									EndIf
								Case nCondLike == 3 // LIKE 'zzz%'
									If Left(AllTrim(VD9->VD9_CPODEF),nTamCPODEF) == cCpoDEFCt
									Else
										VD9->(dbSkip())
										Loop
									EndIf
								EndCase
							EndIf 
							
						EndIf
						if !lPrim .and. aScan(aResolvidos, {|x| Alltrim(x[1]) == Alltrim(VD9->VD9_CPODEF)}) > 0
							VD9->(DBSkip())
							loop
						endif
						If lPrim .and. !Empty(cPCodCon) .and. cPCodCon <> VD9->VD9_CODCON
							VD9->(DBSkip())
							Exit
						endif

						// verifica se a conta existe para a filial
						if VDA->(DBSeek(xFilial("VDA") + cPARCodDef + VD9->VD9_CODCON + cEmpAnt + cFilAnt ))
							// Pula contas inativas para a filial em questão
							nCCount ++ // Incrementa o contador
							nVal := 0  // Valor da conta
							nCCValTot := 0
							aCCTotal := {}
							//
							Do Case
							Case VD9->VD9_TIPO == "5" // Se a conta representa um acumulado de outra devemos calcular
								If !OX052002_CalculaTipo5()
									VD9->(DBSkip())
									loop
								EndIf

							Case VD9->VD9_TIPO == "2" // Se a conta representa uma expressão devemos calculá-la
								If !OX052003_CalculaTipo2()
									VD9->(DBSkip())
									loop
								EndIf

							Case VD9->VD9_TIPO $ "34" // Se a conta é tipo 3, pega da contabilidade (CT7)
								OX052001_CalculaCCTERP(lVisualDados)
							EndCase

							if !Empty(VD9->VD9_CODFOR) .and. VD9->VD9_TIPO == "1" // se a conta é formula, basta calcular...
								nPos = VAL(VD9->VD9_CODFOR)
								if nPos == 0
									nVal := 0
								elseif nPos > Len(aRetDef)
									MsgInfo(STR0013+" ("+Alltrim(VD9->VD9_CODFOR)+").",STR0014)
								else
									nVal := aRetDef[nPos]
								endif
							endif

							IF VD9->VD9_TIPO=="4"
								if nVal < 0
									nVal := 0
								endif
							endif

							// cria registro com o valor
							If lGravarDados
								If lCCComoFilEst
									For nCntFor := 1 to Len(aCCTotal)
										DBSelectArea("VDC")
										If !DbSeek( aCCTotal[nCntFor,1] +cPARCodDef + dtos(dPARDataFinal) + VD9->VD9_CODCON ) // VDC_FILIAL+VDC_CODDEF+DTOS(VDC_DATA)+VDC_CODCON
											RecLock("VDC",.t.)
											VDC->VDC_FILIAL := aCCTotal[nCntFor,1]
											VDC->VDC_CODDEF := cPARCodDef
											VDC->VDC_CODCON := VD9->VD9_CODCON
											VDC->VDC_DATA   := dPARDataFinal
											VDC->VDC_VALOR  := aCCTotal[nCntFor,2]
											MSUnlock()
											nCCValTot += aCCTotal[nCntFor,2]
										EndIf
									Next
								Else
									DBSelectArea("VDC")
									RecLock("VDC",.t.)
									VDC->VDC_FILIAL := xFilial("VDC")
									VDC->VDC_CODDEF := cPARCodDef
									VDC->VDC_CODCON := VD9->VD9_CODCON
									VDC->VDC_DATA   := dPARDataFinal
									VDC->VDC_VALOR  := nVal
									MSUnlock()
								EndIf
								oProcTTP:IncRegua2()
							EndIf

							// remove a conta dos faltantes e insere nos resolvidos
							nPos := aScan(aFaltantes,VD9->VD9_CPODEF)
							if nPos > 0
								aDel(aFaltantes,nPos)
								aSize(aFaltantes, Len(aFaltantes)-1)
								aDel(aFaltInfo,nPos)
								aSize(aFaltInfo, Len(aFaltInfo)-1)
							endif
							If lCCComoFilEst
								aAdd(aResolvidos,{VD9->VD9_CPODEF, IIF(nCCValTot==NIL,0,nCCValTot) })
							Else
								aAdd(aResolvidos,{VD9->VD9_CPODEF, IIF(nVal==NIL,0,nVal) })
							EndIf
							
						endif

						VD9->(DBSkip())
					enddo
					//
					lPrim := .f.
					// se o processamento foi feito e as contas faltantes permanecem as mesmas,
					// isso só pode indicar referência circular e é impossível calcular tudo
					if nFalAntes > 0 .and. Len(aFaltantes) == nFalAntes
						// mostra a mensagem e aborta
						MsgStop(STR0012 + " : "+STRZERO(Len(aFaltantes),4))
						If lGravarDados
							DisarmTransaction()
						EndIf
						lAbortou := .t.
						IF (nHandle := FCREATE("OXA051DUMP.TXT", FC_NORMAL)) != -1
							for nCntFor = 1 to Len(aFaltInfo)
								FWRITE(nHandle, aFaltInfo[nCntFor]+CHR(13)+CHR(10))
							next
							FCLOSE(nHandle)
						ENDIF
						exit
					endif
					// Se ele rodou e não fez nada, aborta
					if nCCount == 0 .or. Len(aResolvidos) == 0
						nCCount := 0
						exit
					endif
				enddo
				If lGravarDados
					// grava cabeçalho
					If nCCount > 0 .and. !lAbortou
						DBSelectArea("VD7")
						DBSeek(xFilial("VD7")+cPARCodDef)
						
/*						If lCCComoFilEst
							For nCntFor := 1 to Len(aFilVD8)	
								RecLock("VDB",.t.)
								VDB->VDB_FILIAL := aFilVD8[nCntFor,1]
								VDB->VDB_CODDEF := cPARCodDef
								VDB->VDB_DATA   := dPARDataFinal
								VDB->VDB_FREQUE := VD7->VD7_FREQUE
								MSUnlock()
							Next
						Else
*/
							DBSelectArea("VDB")
							If !DbSeek( xFilial("VDB") + cPARCodDef + DTOS(dPARDataFinal) )
								RecLock("VDB",.t.)
								VDB->VDB_FILIAL := xFilial("VDB")
								VDB->VDB_CODDEF := cPARCodDef
								VDB->VDB_DATA   := dPARDataFinal
								VDB->VDB_FREQUE := VD7->VD7_FREQUE
								MSUnlock()
							EndIf
//						EndIf
					Endif
				EndIf

			END TRANSACTION
			
			ConOut(Chr(13) + Chr(10))
			ConOut("OFIXA052 - FILIAL: "+aFilExec[nFilExec,2]+" - FIM DO PROCESSAMENTO: "+ Dtoc(dDataBase) +" - "+Time())

			If lGravarDados
				if nCCount > 0 .and. !lAbortou
					lMsgFinal := .t.
				endif
			Else
				If oVisualLog:HasData()
					oVisualLog:Total( {;
							{ 3 , STR0019 } ; // TOTAL
						})
					oVisualLog:Activate()
				EndIf
			EndIf

		//EndIf
	Next
	If lMsgFinal
		MsgInfo(STR0006)
	EndIf

cFilAnt := cBkpFil

Return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |FMX_CALXPDEF| Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Montagem da Pergunte                                         |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function FMX_CALXPDEF(cCodDEF,cExprDEF,aResolv,nValCon)
Local nCntFor

Local bBlock:=ErrorBlock(), bErro := ErrorBlock( { |e| FS_CheckBug(e,cCodDEF,cExprDEF) } )

// remove espaços em branco de tudo
cExprDEF := Alltrim(cExprDEF)
nPos = AT(" ",cExprDEF)
while nPos > 0
	cExprDEF := STUFF(cExprDEF,nPos,1,"")
	nPos = AT(" ",cExprDEF)
enddo
//
// inicia a analise léxica
//
nPC := 1
cPalavra := ""
aPalavras := {}
//
while nPC <= Len(cExprDEF)
	cLetra := subs(cExprDEF,nPc,1)
	if cLetra $ "()+-*/"
		if Empty(cPalavra)
			aAdd(aPalavras,cLetra)
		else
			if Left(cPalavra,1)=="@"
				cConta := subs(cPalavra,2)
				nPos := aScan(aResolv, {|x| Alltrim(x[1]) == Alltrim(cConta)})
				if nPos == 0
					return STR0015+ Alltrim(cConta)
				endif
			endif
			aAdd(aPalavras,cPalavra)
			aAdd(aPalavras,cLetra)
			cPalavra := ""
		endif
	else
		cPalavra = cPalavra + cLetra
	endif
	nPc++
enddo
if Left(cPalavra,1)=="@"
	cConta := subs(cPalavra,2)
	nPos := aScan(aResolv, {|x| Alltrim(x[1]) == Alltrim(cConta)})
	if nPos == 0
		return STR0015 + Alltrim(cConta)
	endif
endif
aAdd(aPalavras,cPalavra)
//
// Verifica e substitui as contas pelos valores
//
cExpr := ""
for nCntFor := 1 to Len(aPalavras)
	if Left(aPalavras[nCntFor],1)=="@"
		cConta := subs(aPalavras[nCntFor],2)
		nPos := aScan(aResolv, {|x| Alltrim(x[1]) == Alltrim(cConta)})
		aPalavras[nCntFor] := "("+Alltrim(str(aResolv[nPos,2]))+")"
	endif
	cExpr := Alltrim(cExpr + " " + aPalavras[nCntFor])
next
nVal := &(cExpr)
//
ErrorBlock(bBlock)
//
return ""
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OX052VP    | Autor |  Luis Delorme         | Data | 30/04/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Validacao da Pergunte                                        |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OX052VP(nParVP)

if nParVP == 1
	DBSelectArea("VD7")
	if DBSeek(xFilial("VD7")+MV_PAR01) .and. VD7->VD7_ATIVO == "0"
		MsgStop(STR0009)
		return .f.
	endif
	DBSelectArea("VD8")
	if !DBSeek(xFilial("VD8")+MV_PAR01+cEmpAnt+xFilial("VDB"))
		MsgStop(STR0010)
		return .f.
	endif
elseif nParVP == 2
	if Month(MV_PAR02) == Month(MV_PAR02+1)
		MsgStop(STR0011)
		return .f.
	endif
elseif nParVP == 4
	
	If !Empty(MV_PAR04)
		If Empty(MV_PAR05) 
			DBSelectArea("VD9")
			DBSetOrder(1)
			if DBSeek(xFilial("VD9")+MV_PAR01+MV_PAR04) 
				If VD9->VD9_ATIVO == "0"
					MsgStop(STR0035,STR0014) // Item DEF não esta ativo! / Atencao
					return .f.
				EndIf
			Else // Item DEF e Campo DEF preenchidos juntos
				MsgStop(STR0036,STR0014) // Item DEF não encontrado para o DEF selecionado! / Atencao
				return .f.
			endif
		Else
			MsgStop(STR0040,STR0014) // Não é possível informar Item DEF e Campo DEF simultaneamente nos parâmetros da geração do DEF! | Atencao
			Return .f.
		EndIf
	EndIf

elseif nParVP == 5

	If !Empty(MV_PAR05) .and. !Empty(MV_PAR04) // Campo DEF e Item DEF preenchidos juntos
		MsgStop(STR0040,STR0014) // Não é possível informar Item DEF e Campo DEF simultaneamente nos parâmetros da geração do DEF! / Atencao
		Return .f.
	EndIf

endif

return .t.


Function FS_CheckBug(e,cCodFormul,cDesFormul)
Local lRet := .t.
if e:gencode > 0
	Aviso(cCodFormul,cDesFormul+CHR(13)+CHR(10)+e:errorstack,{""},3)
	lRet := .f.
Endif
Return(lRet)


/*/{Protheus.doc} OX052002_CalculaTipo5
Calculo quando campo VD9_TIPO = 5
@author Rubens
@since 02/10/2018
@version 1.0

@type function
/*/
Function OX052002_CalculaTipo5()
	Local nCntFor
	cCodConAc := FM_SQL(;
		"SELECT VD9.VD9_CODCON " + ;
		 " FROM " + RetSQLName("VD9") + " VD9 " +;
		" WHERE VD9.VD9_FILIAL = '" + xFilial("VD9") + "' " +;
		  " AND VD9.VD9_CPODEF = '" + VD9->VD9_ACUMUL + "' " +;
		  " AND VD9.D_E_L_E_T_=' '")

	nPos := aScan(aResolvidos, {|x| Alltrim(x[1]) == Alltrim(VD9->VD9_ACUMUL)})
	if nPos > 0
		nVal += aResolvidos[nPos,2]
		for nCntFor := Month(dPARDataFinal) to 1 step -1
			dDataSeek := ctod("01/"+ STRZERO(nCntFor,2)+"/"+Right(STRZERO(Year(dPARDataFinal),4),2))-1
			if VDC->(DBSeek(xFilial("VDC")+cPARCodDef+dtos(dDataSeek)+Alltrim(cCodConAc)))
				nVal += VDC->VDC_VALOR
			endif
		next
	else
		nPos := aScan(aFaltantes,VD9->VD9_CPODEF) // verifica se essa conta é faltante para cálculo
		// adiciona a conta como faltante
		if nPos == 0
			aAdd(aFaltantes,VD9->VD9_CPODEF)
			aAdd(aFaltInfo,VD9->VD9_CPODEF+STR0017+VD9->VD9_ACUMUL)
		else
			aFaltInfo[nPos] := VD9->VD9_CPODEF+STR0017+VD9->VD9_ACUMUL
		endif
		Return .f.
	endif
Return .t.

/*/{Protheus.doc} OX052003_CalculaTipo2
Calculo quando campo VD9_TIPO = 2
@author Rubens
@since 02/10/2018
@version 1.0

@type function
/*/
Function OX052003_CalculaTipo2()
	// se a função FMX_CALXPDEF retornar uma string, a conta é faltante, caso contrário o resultado está em nVal
	cResFalt := FMX_CALXPDEF(VD9->VD9_CODCON,VD9->VD9_EXPRES,aResolvidos,nVal)
	if !Empty(cResFalt)
		nPos := aScan(aFaltantes,VD9->VD9_CPODEF) // verifica se essa conta é faltante para cálculo
		// adiciona a conta como faltante
		if nPos == 0
			aAdd(aFaltantes,VD9->VD9_CPODEF)
			aAdd(aFaltInfo,VD9->VD9_CPODEF+cResFalt)
		else
			aFaltInfo[nPos] := VD9->VD9_CPODEF+cResFalt
		endif
		Return .f.
	endif

Return .t.

/*/{Protheus.doc} OX052001_CalculaCCTERP
Calculo utilizando valores da Contabilidade Gerencial
@author Rubens
@since 02/10/2018
@version 1.0
@param lVisualDados, logical, descricao
@type function
/*/
Function OX052001_CalculaCCTERP(lVisualDados)
	Local aBkpCenCus

	aCenCus := {}
	If !Empty(VD9->VD9_CCUSTS)
		aCenCus := OX052006_GeraCentroCustoAProcessar()
	EndIf

	// PONTO DE ENTRADA PARA ALTERACAO DO VETOR
	If lOA052CC1
		ExecBlock("OA052CC1",.f.,.f.)
	EndIf
	//

//	If lOA052VAL
//		nVal := ExecBlock("OA052VAL",.f.,.f., { lVisualDados })
//	Else

		VDE->(DBSeek(xFilial("VDE")+VD9->VD9_CODDEF+VD9->VD9_CODCON))
		while !VDE->(eof()) .and. xFilial("VDE") == VDE->VDE_FILIAL .and. VD9->VD9_CODDEF == VDE->VDE_CODDEF .and. VD9->VD9_CODCON == VDE->VDE_CODCON

			//
			if lVDECCUSTO .and. !Empty(VDE->VDE_CCUSTO)
				aBkpCenCus := aClone(aCenCus)
				aCenCus := { VDE->VDE_CCUSTO }
			endif

			OX052012_PercorreCT1( VDE->VDE_CCTERP , lVisualDados , VD9->VD9_CPODEF )

			if lVDECCUSTO .and. !Empty(VDE->VDE_CCUSTO)
				aCenCus := aClone(aBkpCenCus)
			endif

			VDE->(DBSkip())
		enddo
//	endif
Return


/*/{Protheus.doc} OX052004_VisCabec
Adiciona os campos na janela para visualização detalhada do calculo
@author Rubens
@since 02/10/2018
@version 1.0

@type function
/*/
Function OX052004_VisCabec()

	oVisualLog:AddHeaderMGET({;
		{'TIPO'    , "D"             },;
		{'TAMANHO' , 10              },;
		{'CAMPO'   , 'dOXA052Inicio' },;
		{'TITULO'  , STR0020         },; // 'Data Inicial'
		{'VALOR'   , dDataIni        } ;
	})

	oVisualLog:AddHeaderMGET({;
		{'TIPO'    , "D"            },;
		{'TAMANHO' , 10             },;
		{'CAMPO'   , 'dOXA052Final' },;
		{'TITULO'  , STR0021        },; // 'Data Final'
		{'VALOR'   , dDataFim       } ;
	})

	oVisualLog:AddColumn( { { "TITULO" , STR0022                } , { "TAMANHO" , 6 } } ) // "Id Conta"
	oVisualLog:AddColumn( { { "TITULO" , STR0023                } , { "TAMANHO" , 10 } } ) // "Tipo"
	oVisualLog:AddColumn( { { "TITULO" , STR0024                } , { "TAMANHO" , TamSX3("CT1_CONTA")[1] } } ) // "Conta"
	oVisualLog:AddColumn( { { "TITULO" , STR0025                } , { "TAMANHO" , TamSX3("CTT_CUSTO")[1] } } ) // "Centro de Custo"
	oVisualLog:AddColumn( { { "TITULO" , STR0026                } , { "TAMANHO" , TamSX3("CTD_ITEM")[1]  } } ) // "Item Conta"
	oVisualLog:AddColumn( { { "TITULO" , STR0027                } , { "TIPO" , "N" } , { "TAMANHO" , 17 } , { "DECIMAL",2 } , { "PICTURE" , "@Z 99,999,999,999,999.99" } , { "TOTALIZADOR", .t. }} ) // "Saldo"
	oVisualLog:AddColumn( { { "TITULO" , STR0028                } , { "TIPO" , "N" } , { "TAMANHO" , 17 } , { "DECIMAL",2 } , { "PICTURE" , "@Z 99,999,999,999,999.99" } } ) // "Saldo Inicio"
	oVisualLog:AddColumn( { { "TITULO" , STR0029                } , { "TIPO" , "N" } , { "TAMANHO" , 17 } , { "DECIMAL",2 } , { "PICTURE" , "@Z 99,999,999,999,999.99" } } ) // "Saldo Final"
	oVisualLog:AddColumn( { { "TITULO" , RetTitle("CT1_NORMAL") } , { "TAMANHO" , 10 } } )
	oVisualLog:AddColumn( { { "TITULO" , STR0030                } , { "TAMANHO" , 1 } } ) // "Operação"
	oVisualLog:AddColumn( { { "TITULO" , STR0031                } , { "TAMANHO" , 2 } } ) // "Tipo Saldo"

Return


/*/{Protheus.doc} OX052LogCalculo
Executa processamento do calculo para uma determinada linha do DEF para visualizacao detalhada / conferencia do calculo.
@author Rubens
@since 02/10/2018
@version 1.0
@param cCodDef, characters, descricao
@param cCodCon, characters, descricao
@param dDataFechamento, date, descricao
@type function
/*/
Function OX052LogCalculo(cCodDef, cCodCon, dDataFechamento)
	OX052RunProc(, cCodDef, cCodCon, dDataFechamento, .f.)
Return

/*/{Protheus.doc} OX052005_DeletaProc
Deleta processamento gravado na base de dados.
@author Rubens
@since 02/10/2018
@version 1.0
@param cAuxCodDef, characters, descricao
@param dAuxDataFinal, date, descricao
@type function
/*/
Function OX052005_DeletaProc( cAuxCodDef, dAuxDataFinal , cAuxCpoDEF , lDetalhes , aFilExec, cItensDEF, nCondLike )
Local cQuery      	:= ""
Local nCntFor     	:= 0
Local cBkpFil     	:= cFilAnt
Local cAliasC		:= GetNextAlias()
Local cCampoDEF		:= ""
Local nRecVDC
Local lPerg       	:= .t.
Default lDetalhes 	:= .f.
Default aFilExec  	:= {{ .t. , cFilAnt , "" }}
Default cAuxCpoDEF  := ""
Default cItensDEF	:= ""
Default nCondLike	:= 0

Begin Transaction

For nCntFor := 1 to Len(aFilExec)

	cFilAnt := aFilExec[nCntFor,2]

	DBSelectArea("VDB")
	If !DBSeek(xFilial("VDB")+cAuxCodDef+dtos(dAuxDataFinal))
		Loop
	EndIf
	
	If lPerg
		
		If !MsgYesNo(STR0005)
			cFilAnt := cBkpFil // Volta Filial
			Return .f.
		EndIf
		
		lPerg := .f.
	
	EndIf

	reclock("VDB",.f.,.t.)
	dbdelete()
	msunlock()

	// Encontra quais itens DEF correspondem ao Campo DEF informado no parametro
	If !Empty(cAuxCpoDEF)
		
		cQuery := "SELECT VDC.R_E_C_N_O_ RECVDC "
		cQuery += "  FROM " + RetSqlName("VD9") + " VD9 "
		cQuery += "  JOIN " + RetSqlName("VDC") + " VDC ON "
		cQuery += "  VDC.VDC_CODDEF = VD9.VD9_CODDEF "
		cQuery += "  AND VDC.VDC_CODCON = VD9.VD9_CODCON "
		cQuery += "  AND VDC.VDC_FILIAL = '" + xFilial("VDC") + "' "
		cQuery += "  AND VDC.VDC_DATA = '" + dtos(dAuxDataFinal) + "' "
		cQuery += "  AND VDC.D_E_L_E_T_= ' ' "
		cQuery += " WHERE VD9.VD9_FILIAL = '" + xFilial("VD9") + "' "
		cQuery += "   AND VD9.VD9_CODDEF = '" + cAuxCodDef + "' "
		If nCondLike == 0
			cQuery += " AND VD9.VD9_CPODEF = '"+cAuxCpoDEF+"' "
		Else
			cQuery += " AND VD9.VD9_CPODEF LIKE '"+AllTrim(cAuxCpoDEF)+"' "
		EndIf
		cQuery += " AND VD9.D_E_L_E_T_= ' ' "
		DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasC, .f., .t.)
		
		DbSelectArea("VDC")
		While !(cAliasC)->(EoF())
			DBGOTO( (cAliasC)->RECVDC )
			reclock("VDC",.f.,.t.)
			dbdelete()
			msunlock()
			(cAliasC)->(dbSkip())
		End
		(cAliasC)->(DbCloseArea())
	
	ElseIf !Empty(cItensDEF) 
		
		cQuery := "SELECT VDC.R_E_C_N_O_ RECVDC "
		cQuery += "  FROM " + RetSqlName("VDC") + " VDC "
		cQuery += " WHERE VDC.VDC_FILIAL = '" + xFilial("VDC") + "' "
		cQuery += " AND VDC.VDC_CODDEF = '" + cAuxCodDef + "' "
		cQuery += " AND VDC.VDC_CODCON = '"+cItensDEF+"' "
		cQuery += " AND VDC.VDC_DATA = '" + dtos(dAuxDataFinal) + "' "
		cQuery += " AND D_E_L_E_T_= ' ' "
		nRecVDC := FM_SQL( cQuery )

		If nRecVDC > 0
			DbSelectArea("VDC")
			DBGOTO( nRecVDC )
			reclock("VDC",.f.,.t.)
			dbdelete()
			msunlock()
		EndIf

		// Encontra qual Campo DEF corresponde ao Item DEF informado no parametro
		cQuery := "SELECT VD9.VD9_CPODEF "
		cQuery += "  FROM " + RetSqlName("VD9") + " VD9 "
		cQuery += " WHERE VD9.VD9_FILIAL = '" + xFilial("VD9") + "' "
		cQuery += "  AND VD9.VD9_CODDEF = '" + cAuxCodDef + "' "
		cQuery += "  AND VD9.VD9_CODCON = '"+cItensDEF+"' "
		cQuery += "  AND VD9.D_E_L_E_T_= ' ' "
		cCampoDEF := FM_SQL(cQuery)

	Else // Nao foi informado Item DEF ou Campo DEF

		DBSelectArea("VDC")
		DBSetOrder(1)
		DBSeek(xFilial("VDC")+cAuxCodDef+dtos(dAuxDataFinal))
		while !eof() .and. xFilial("VDC") == VDC->VDC_FILIAL .and. cAuxCodDef == VDC->VDC_CODDEF .and. dtos(dAuxDataFinal) == dtos(VDC->VDC_DATA)
			reclock("VDC",.f.,.t.)
			dbdelete()
			msunlock()
			DBSkip()
		enddo

	EndIf

		

	If lDetalhes

		cQuery := "DELETE FROM " + RetSqlName("VCU")
		cQuery += " WHERE VCU_FILIAL='"+xFilial("VCU")+"'"
		cQuery += "   AND VCU_CODDEF='"+cAuxCodDef+"'"
		If !Empty(cCampoDEF)
			cQuery += "   AND VCU_CPODEF = '"+cCampoDEF+"'"
		ElseIf !Empty(cAuxCpoDEF) // Filtra campo DEF especifico
			If nCondLike == 0
				cQuery += "   AND VCU_CPODEF = '"+cAuxCpoDEF+"'"
			Else
				cQuery += "   AND VCU_CPODEF LIKE '"+AllTrim(cAuxCpoDEF)+"'"
			EndIf	
		EndIf
		cQuery += "   AND VCU_DATA='"+DTOS(dAuxDataFinal)+"'"
		TcSqlExec( cQuery ) // Apaga registros para recriar os Historicos Detalhados do DEF

		cQuery := "DELETE FROM "+ RetSqlName("VCV")
		cQuery += " WHERE VCV_FILIAL='"+xFilial("VCV")+"'"
		cQuery += "   AND VCV_CODDEF='"+cAuxCodDef+"'"
		If !Empty(cCampoDEF)
			cQuery += "   AND VCV_CPODEF = '"+cCampoDEF+"'"
		ElseIf !Empty(cAuxCpoDEF) // Filtra campo DEF especifico
			If nCondLike == 0
				cQuery += "   AND VCV_CPODEF = '"+cAuxCpoDEF+"'"
			Else
				cQuery += "   AND VCV_CPODEF LIKE '"+AllTrim(cAuxCpoDEF)+"'"
			EndIf	
		EndIf		
		cQuery += "   AND VCV_DATA='"+DTOS(dAuxDataFinal)+"'"
		TcSqlExec( cQuery ) // Apaga registros para recriar os Historicos Detalhados do DEF ( Analitico )

	EndIf

Next

End Transaction

cFilAnt := cBkpFil // Volta Filial

Return .t.

/*/{Protheus.doc} OX052006_GeraCentroCustoAProcessar
Gera matriz com Centro de Custo utilizado no processamento do DEF
@author Rubens
@since 02/10/2018
@version 1.0
@return aAuxRetorno , Matriz contendo os Centros de Custos utilizados no calculo

@type function
/*/
Static Function OX052006_GeraCentroCustoAProcessar()

	Local aAuxCenCus := {}
	Local aAuxRetorno := {}
//	Local nCntFor
	Local nLenCCusto
	Local nPosCampos
	Local aCampos

	If lVD9CCUSTA
		aCampos := {;
			"VD9->VD9_CCUSTS",;
			"VD9->VD9_CCUSTA",;
			"VD9->VD9_CCUSTB",;
			"VD9->VD9_CCUSTC" }
	Else
		aCampos := {"VD9->VD9_CCUSTS"}
	EndIf

	For nPosCampos := 1 to Len(aCampos)

		aAuxCenCus := OX052007_SeparaTexto(&(aCampos[nPosCampos]))
		If Len(aAuxCenCus) > 0
			nLenCCusto := Len(aAuxRetorno)
			ASIZE( aAuxRetorno , nLenCCusto + Len(aAuxCenCus) )
			ACOPY( aAuxCenCus , aAuxRetorno , , , nLenCCusto + 1 )
		EndIf
	Next nPosCampos

Return aClone(aAuxRetorno)


/*/{Protheus.doc} OX052007_SeparaTexto
Transforma um texto em uma array. Utiliza o separador passado como parametro para quebrar o texto
@author Rubens
@since 02/10/2018
@version 1.0
@return aRetorno, array com os valores que foram separados
@param cTexto, characters, descricao
@param cSeparador, characters, descricao
@type function
/*/
Static Function OX052007_SeparaTexto(cTexto, cSeparador)

	Local aRetorno := {}

	Default cSeparador := ","

	cTexto := AllTrim(cTexto)
	If Empty(cTexto)
		Return {}
	EndIf

	aRetorno := StrTokArr(cTexto,",")

Return aRetorno

/*/{Protheus.doc} OX052008_CalculaCentroCusto
Calculo por Centro de Custo
@author Rubens
@since 02/10/2018
@version 1.0
@return nRetorno, Valor calculado
@param cParConta, characters, Codigo da Conta
@param cParCenCusto, characters, Codigo do Centro de Custo
@param lVisualDados, logical, Indica se esta sendo executada para visualizacao detalhada do calculo
@type function
/*/
Static Function OX052008_CalculaCentroCusto(cParConta, cParCenCusto, lVisualDados)

	Local nTemp := 0
	Local nRetorno := 0
	Local nSaldoIni := 0
	Local nSaldoFim := 0

	CTT->(dbSetOrder(1))
	if CTT->(DBSeek(xFilial("CTT")+ cParCenCusto ))
		if VDE->VDE_TIPSAL == "1"
			nTemp := SaldoCCus(cParConta, cParCenCusto ,dDataFim,"01","1",1)
			nSaldoIni := nTemp
		elseif VDE->VDE_TIPSAL == "2"
			nSaldoFim := SaldoCCus(cParConta, cParCenCusto ,dDataFim,"01","1",1)
			nSaldoIni := SaldoCCus(cParConta, cParCenCusto ,dDataIni - 1,"01","1",1)
			nTemp := nSaldoFim - nSaldoIni
		endif
		if VDE->VDE_OPER == "1"
			nTemp := -nTemp
		endif
		nRetorno += nTemp
		OX052010_GeraDadosVisual(lVisualDados, nTemp , cParConta , cParCenCusto , "" , nSaldoIni , 0, CT1->CT1_NORMAL )
	endif


Return nRetorno


/*/{Protheus.doc} OX052009_CalculaContaContab
//TODO Descrição auto-gerada.
@author Rubens
@since 02/10/2018
@version 1.0
@return nRetorno, Valor calculado
@param cParConta, characters, Codigo da Conta
@param lVisualDados, logical, Indica se esta sendo executada para visualizacao detalhada do calculo
@type function
/*/
Static Function OX052009_CalculaContaContab(cParConta, lVisualDados)
	Local nTemp := 0
	Local nRetorno := 0
	Local nSaldoIni := 0
	Local nSaldoFim := 0

	If VDE->VDE_TIPSAL == "1"
		nTemp := SALDOCONTA(cParConta,dDataFim,"01","1",1)
		nSaldoIni := nTemp
	elseif VDE->VDE_TIPSAL == "2"
		nSaldoIni := SaldoConta(cParConta, dDataIni - 1,"01","1",1)
		nSaldoFim := SaldoConta(cParConta, dDataFim    ,"01","1",1)
		nTemp := nSaldoFim - nSaldoIni
	endif
	if VDE->VDE_OPER == "1"
		nTemp := -nTemp
	endif
	nRetorno := nTemp

	OX052010_GeraDadosVisual(lVisualDados, nTemp, cParConta, "", "", nSaldoIni, 0 , CT1->CT1_NORMAL)

Return nRetorno

/*/{Protheus.doc} OX052010_GeraDadosVisual
Cria uma linha na Grid para visualizacao detalhada do calculo
@author Rubens
@since 02/10/2018
@version 1.0
@param lVisualDados, logical, descricao
@param nAuxVal, numeric, descricao
@param cConta, characters, descricao
@param cCentroCusto, characters, descricao
@param cItemConta, characters, descricao
@param nSaldoIni, numeric, descricao
@param nSaldoFim, numeric, descricao
@param cCT1NORMAL, characters, descricao

@type function
/*/
Function OX052010_GeraDadosVisual(lVisualDados, nAuxVal, cConta, cCentroCusto, cItemConta, nSaldoIni, nSaldoFim, cCT1NORMAL )
	Default cCentroCusto := ""
	Default cItemConta := ""
	Default nSaldoFim := 0

	If !lVisualDados
		Return
	EndIf
	If nAuxVal <> 0
		oVisualLog:AddDataRow(;
			{;
				VD9->VD9_CODCON ,;
				X3CBOXDESC("VD9_TIPO",VD9->VD9_TIPO)   ,;
				cConta         ,;
				cCentroCusto     ,;
				cItemConta          ,;
				nAuxVal,;
				nSaldoIni,;
				IIf( VDE->VDE_TIPSAL == "1" , 0       , nSaldoFim) ,;
				X3CBOXDESC("CT1_NORMAL", cCT1NORMAL ) ,;
				X3CBOXDESC("VDE_OPER", VDE->VDE_OPER  ) ,;
				X3CBOXDESC("VDE_TIPSAL", VDE->VDE_TIPSAL) ;
			};
			)

	Endif
Return


/*/{Protheus.doc} OX052012_PercorreCT1
Percorre tabela de conta para calculo do DEF
@author Rubens
@since 02/10/2018
@version 1.0
@param cContaContabil, characters, Conta contabil (Passar valores com AllTrim, para processar todas as contas que comecam com o valor passado como parametro)
@param lVisualDados, logical, Indica se esta sendo executada para visualizacao detalhada do calculo
@type function
/*/
Static Function OX052012_PercorreCT1(cContaContabil , lVisualDados , cCpoDef )

	Local nCntFor, nNumFor
	Local nTamConta
	Local cVD8ItemConta := ""
	Local nLenCenCus := Len(aCenCus)
	Local aItensConta
	Local lMultICFil
	Local nVlrAux := 0

	If lItemCtComoFilial
		lMultICFil := .f.
		
		VD8->( DBSetorder(1) )
		VD8->( MSSeek( xFilial("VD8") + cPARCodDef + cEmpAnt + cFilAnt ) )
		If At(",",AllTrim(VD8->VD8_ITEMCT)) > 0 .and. Len(AllTrim(VD8->VD8_ITEMCT)) > TamSX3("CTD_ITEM")[1]
			aItensConta := OX052007_SeparaTexto(AllTrim(VD8->VD8_ITEMCT),",")
			lMultICFil := .t.
		Else
			cVD8ItemConta := AllTrim(VD8->VD8_ITEMCT)
		EndIf
	EndIf

	// Monta uma chave de pesquisa utilizando ALLTRIM pois é possivel informar, no cadastro dos Itens do DEF,
	// uma conta Sintetica, e nesses casos iremos processar todas as contas Analiticas
    If OX0520167_ClasseConta(cContaContabil) == "1" //1=Sintetica
        cChaveCT1 := xFilial("CT1") + AllTrim( cContaContabil )
    Else
        cChaveCT1 := xFilial("CT1") + PadR( AllTrim( cContaContabil ) , TamSX3("CT1_CONTA")[1] , " " )
    EndIf
    nTamConta := Len( cChaveCT1 )
	CT1->(DBSeek( cChaveCT1 ))
	While !CT1->(eof()) .and. Left(CT1->CT1_FILIAL + CT1->CT1_CONTA, nTamConta) == cChaveCT1

		nRecCT1 := CT1->(Recno())

		// Centro de Custo Envolvido
		if nLenCenCus > 0
			// Calcula por Conta Contabil + Centro de Custo + Item Contabil
			If lItemCtComoFilial
				for nCntFor := 1 to nLenCenCus
					If lMultICFil
						For nNumFor := 1 to Len(aItensConta)
							nVlrAux := OX052011_CalculaItemContabil(CT1->CT1_CONTA, aCenCus[nCntFor] , aItensConta[nNumFor] , lVisualDados)
							nVal += nVlrAux
							If lGrvDetalhes
								OX0520151_GravarDetalhamentoDEF( cCpoDef , aCenCus[nCntFor] , CT1->CT1_CONTA , aItensConta[nNumFor] , nVlrAux )
							EndIf
						Next
					Else
						nVlrAux := OX052011_CalculaItemContabil(CT1->CT1_CONTA, aCenCus[nCntFor] , cVD8ItemConta , lVisualDados)
						nVal += nVlrAux
						If lGrvDetalhes
							OX0520151_GravarDetalhamentoDEF( cCpoDef , aCenCus[nCntFor] , CT1->CT1_CONTA , cVD8ItemConta , nVlrAux )
						EndIf
					EndIf
				next
			// Calcula por Conta Contabil + Centro de Custo como Filial
			ElseIf lCCComoFilEst
				for nCntFor := 1 to nLenCenCus
					nVlrAux := OX052013_CalculaCCFilial(CT1->CT1_CONTA, aCenCus[nCntFor] , lVisualDados)
					nVal += nVlrAux
					If lGrvDetalhes
						OX0520151_GravarDetalhamentoDEF( cCpoDef , aCenCus[nCntFor] , CT1->CT1_CONTA , "" , nVlrAux )
					EndIf
				next
			// Calcula por Conta Contabil + Centro de Custo
			Else
				for nCntFor := 1 to nLenCenCus
					nVlrAux := OX052008_CalculaCentroCusto(CT1->CT1_CONTA, aCenCus[nCntFor] , lVisualDados)
					nVal += nVlrAux
					If lGrvDetalhes
						OX0520151_GravarDetalhamentoDEF( cCpoDef , aCenCus[nCntFor] , CT1->CT1_CONTA , "" , nVlrAux )
					EndIf
				next
			EndIf
		// Calcula Pela Conta Contabil
		else
			// Calcula Saldo Pela Conta Contabil + Item Contabil
			If lItemCtComoFilial
				If lMultICFil
					For nNumFor := 1 to Len(aItensConta)
						nVlrAux := OX052011_CalculaItemContabil(CT1->CT1_CONTA, "" , aItensConta[nNumFor] , lVisualDados)
						nVal += nVlrAux
						If lGrvDetalhes
							OX0520151_GravarDetalhamentoDEF( cCpoDef , "" , CT1->CT1_CONTA , aItensConta[nNumFor] , nVlrAux )
						EndIf
					Next
				Else
					nVlrAux := OX052011_CalculaItemContabil(CT1->CT1_CONTA, "" , cVD8ItemConta , lVisualDados)
					nVal += nVlrAux
					If lGrvDetalhes
						OX0520151_GravarDetalhamentoDEF( cCpoDef , "" , CT1->CT1_CONTA , cVD8ItemConta , nVlrAux )
					EndIf
				EndIf
			// Calcula Saldo somente pela Conta Contabil
			Else
				nVlrAux := OX052009_CalculaContaContab(CT1->CT1_CONTA, lVisualDados)
				nVal += nVlrAux
				If lGrvDetalhes
					OX0520151_GravarDetalhamentoDEF( cCpoDef , "" , CT1->CT1_CONTA , "" , nVlrAux )
				EndIf
			EndIf
		endif

		CT1->(DBGoto(nRecCT1))
		CT1->(DBSkip())
	enddo
	//

Return

/*/{Protheus.doc} OX052011_CalculaItemContabil
Calculo por Item Contabil
@author Rubens
@since 02/10/2018
@version 1.0
@return nRetorno, Valor calculado
@param cParConta, characters, Codigo da Conta
@param cParCenCusto, characters, Codigo do Centro de Custo
@param cParItemContabil, characters, Codigo do Item Contabil
@param lVisualDados, logical, Indica se esta sendo executada para visualizacao detalhada do calculo
@type function
/*/
Static Function OX052011_CalculaItemContabil( cParConta, cParCenCusto, cParItemContabil, lVisualDados)

	Local nTemp := 0
	Local nRetorno := 0
	Local nSaldoIni := 0
	Local nSaldoFim := 0

	nTemp := 0
	If VDE->VDE_TIPSAL == "1"
		nSaldoIni := SaldoItem( cParConta , cParCenCusto , cParItemContabil , dDataFim    , "01" , "1", 1)
		nTemp := nSaldoIni
	ElseIf VDE->VDE_TIPSAL == "2"

		nSaldoIni := SaldoItem( cParConta , cParCenCusto , cParItemContabil , dDataIni - 1, "01" , "1" , 1)
		nSaldoFim := SaldoItem( cParConta , cParCenCusto , cParItemContabil , dDataFim    , "01" , "1" , 1)

		nTemp := nSaldoFim
		nTemp := nTemp - nSaldoIni
	EndIf

	If VDE->VDE_OPER == "1"
		nTemp := -nTemp
	EndIf

	nRetorno += nTemp

	OX052010_GeraDadosVisual(;
		lVisualDados,;
		nTemp		,;
		cParConta,;
		cParCenCusto	,;
		cParItemContabil		,;
		nSaldoIni	,;
		nSaldoFim	,;
		CT1->CT1_NORMAL )

Return nRetorno

/*/{Protheus.doc} OX052013_CalculaCCFilial
Calculo por Centro de Custo Como Filial
@author Otávio Favarelli
@since 14/10/2019
@version 1.0
@return nRetorno, Valor calculado
@param cParConta, characters, Codigo da Conta
@param cParCenCusto, characters, Codigo do Centro de Custo
@param lVisualDados, logical, Indica se esta sendo executada para visualizacao detalhada do calculo
@type function
/*/
Static Function OX052013_CalculaCCFilial(cParConta, cParCenCusto, lVisualDados)

Local nTemp := 0
Local nRetorno := 0
Local nSaldoIni := 0
Local nSaldoFim := 0
Local nCntA, nCntB, nCntC, nCntD, nCntE
Local nPos		:= 0
Local nTamCCFil	:= (nPosFimEstr-nPosIniEstr)+1
Local aCCFilEst := {}
Local cAliasB	:= GetNextAlias()
Local cFilCC
Local lCCFilEst	:= .f.

If At("#",cParCenCusto) > 0 // Estruturado - Será necessário substituir # pelo código de todas as filiais
	For nCntA := 1 to Len(aFilVD8)
		AAdd(aCCFilEst, {	aFilVD8[nCntA,1],; 													// 01 - Filial
							Stuff(cParCenCusto, nPosIniEstr, nTamCCFil, aFilVD8[nCntA,2]),;	// 02 - Centro de Custo com substituição realizada
							{},;																// 03 - Vetor com os centros de custo analíticos caso houver
							0})																	// 04 - Valor Total por filial para este centro de custo															
	Next
	lCCFilEst := .t.
Else
	cFilCC := Substr(cParCenCusto, nPosIniEstr, nTamCCFil)
EndIf

If lCCFilEst
	For nCntB := 1 to Len(aCCFilEst) 
		cQuery := "SELECT "
		cQuery +=   " CTT_CLASSE "
		cQuery += "FROM "
		cQuery +=   RetSQLName("CTT") + " CTT "
		cQuery += "WHERE "
		cQuery +=   "D_E_L_E_T_ = ' ' "
		cQuery +=   " AND CTT_CUSTO = '" + aCCFilEst[nCntB,2] + "' "				
		If FM_SQL(cQuery) == '1'	// 1=Sintético
			//Vamos levantar todos os centros de custo analíticos deste centro de custo sintético
			cCustoAn := ""
			cQuery := "SELECT "
			cQuery +=   " CTT_CUSTO "
			cQuery += "FROM "
			cQuery +=   RetSQLName("CTT") + " CTT "
			cQuery += "WHERE "
			cQuery +=   "D_E_L_E_T_ = ' ' "
			cQuery +=   " AND CTT_CCSUP LIKE '" + aCCFilEst[nCntB,2] + "%' "	
			cQuery +=   " AND CTT_CLASSE = '2' "	
			cQuery += "ORDER BY "	
			cQuery +=   " CTT_CUSTO "	
			DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cAliasB, .f., .t.)
			While !(cAliasB)->(EoF())
				AAdd(aCCFilEst[nCntB,3], AllTrim((cAliasB)-> CTT_CUSTO) )
				(cAliasB)->(dbSkip())
			End
			(cAliasB)->(DbCloseArea())
		EndIf
	Next
EndIf

// Armazenar em um vetor os centros de custo e suas filials a serem gravadas na VDB e VDC

CTT->(dbSetOrder(1))

If lCCFilEst
	For nCntC := 1 to Len(aCCFilEst)
		If Len(aCCFilEst[nCntC,3]) > 0
			For nCntD := 1 to Len(aCCFilEst[nCntC,3])
				If CTT->(DBSeek(xFilial("CTT")+ aCCFilEst[nCntC,3,nCntD] ))
					If VDE->VDE_TIPSAL == "1"	// 1=Saldo Atual
						nTemp := SaldoCCus(cParConta, aCCFilEst[nCntC,3,nCntD] ,dDataFim,"01","1",1)
						nSaldoIni := nTemp
					ElseIf VDE->VDE_TIPSAL == "2"	// 2=Débito da Data
						nSaldoFim := SaldoCCus(cParConta, aCCFilEst[nCntC,3,nCntD] ,dDataFim,"01","1",1)
						nSaldoIni := SaldoCCus(cParConta, aCCFilEst[nCntC,3,nCntD] ,dDataIni - 1,"01","1",1)
						nTemp := nSaldoFim - nSaldoIni
					Endif
					If VDE->VDE_OPER == "1"	// 1=Operação de Soma
						nTemp := -nTemp
					Endif
					aCCFilEst[nCntC,4] += nTemp
					OX052010_GeraDadosVisual(lVisualDados, nTemp , cParConta , aCCFilEst[nCntC,3,nCntD] , "" , nSaldoIni , 0, CT1->CT1_NORMAL )
				Endif
			Next
		Else
			If CTT->(DBSeek(xFilial("CTT")+ aCCFilEst[nCntC,2] ))
				If VDE->VDE_TIPSAL == "1"	// 1=Saldo Atual
					nTemp := SaldoCCus(cParConta, aCCFilEst[nCntC,2] ,dDataFim,"01","1",1)
					nSaldoIni := nTemp
				ElseIf VDE->VDE_TIPSAL == "2"	// 2=Débito da Data
					nSaldoFim := SaldoCCus(cParConta, aCCFilEst[nCntC,2] ,dDataFim,"01","1",1)
					nSaldoIni := SaldoCCus(cParConta, aCCFilEst[nCntC,2] ,dDataIni - 1,"01","1",1)
					nTemp := nSaldoFim - nSaldoIni
				Endif
				If VDE->VDE_OPER == "1"	// 1=Operação de Soma
					nTemp := -nTemp
				Endif
				aCCFilEst[nCntC,4] += nTemp
				OX052010_GeraDadosVisual(lVisualDados, nTemp , cParConta , aCCFilEst[nCntC,2] , "" , nSaldoIni , 0, CT1->CT1_NORMAL )
			Endif		
		EndIf
	Next
Else
	If CTT->(DBSeek(xFilial("CTT")+ cParCenCusto ))
		If VDE->VDE_TIPSAL == "1"	// 1=Saldo Atual
			nTemp := SaldoCCus(cParConta, cParCenCusto ,dDataFim,"01","1",1)
			nSaldoIni := nTemp
		ElseIf VDE->VDE_TIPSAL == "2"	// 2=Débito da Data
			nSaldoFim := SaldoCCus(cParConta, cParCenCusto ,dDataFim,"01","1",1)
			nSaldoIni := SaldoCCus(cParConta, cParCenCusto ,dDataIni - 1,"01","1",1)
			nTemp := nSaldoFim - nSaldoIni
		Endif
		If VDE->VDE_OPER == "1"	// 1=Operação de Soma
			nTemp := -nTemp
		Endif
		nRetorno += nTemp
		OX052010_GeraDadosVisual(lVisualDados, nTemp , cParConta , cParCenCusto , "" , nSaldoIni , 0, CT1->CT1_NORMAL )
	Endif
EndIf

If lCCFilEst // Processou centro de custo de forma estruturada
	// Vamos adicionar o vetor temporário no vetor principal que futuramente será utilizado na gravação da VDC
	For nCntE := 1 to Len(aCCFilEst)
		nPos := AScan(aCCTotal,{|x|x[1] == aCCFilEst[nCntE,1] })
		If nPos == 0
			AAdd(aCCTotal, {aCCFilEst[nCntE,1],;        // 01
							aCCFilEst[nCntE,4]})   		// 02
		Else
			aCCTotal[nPos,2] += aCCFilEst[nCntE,4]
		EndIf
	Next
Else
	// Vamos adicionar seu valor no vetor por filial
	nPos := AScan(aCCTotal,{|x|x[1] == cFilCC}) // Procura pela filial para inserir valores nela 
	If nPos == 0
		AAdd(aCCTotal, {cFilCC,;        // 01
						nRetorno})   	// 02
	Else
		aCCTotal[nPos,2] += nRetorno
	EndIf
EndIf

Return nRetorno

/*/{Protheus.doc} OX0520141_SelecionarFiliais
Seleciona Filiais possiveis ( VD8 )
@author Andre Luis Almeida
@since 03/03/2021
@version 1.0
@return aRet, Retorna as Filiais possiveis
@param lMostraTela, logical, Mostra tela para selecionar as Filiais possiveis (VD8)
@param cFilFiltrar, caracter, Filial desejada para filtrar
@param lDefMarcar, logical, selecionar automaticamente os registros do vetor ?
@type function
/*/
Function OX0520141_SelecionarFiliais( lMostraTela , cFilFiltrar , lDefMarcar , cCodDef )
Local aRetFil  := {}
Local cQAlFil  := GetNextAlias()
Local lLbMar   := lDefMarcar
Private oOkTik := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik := LoadBitmap( GetResources() , "LBNO" )
cQuery := "SELECT DISTINCT VD8_CODFIL "
cQuery += "  FROM " + RetSQLName("VD8") + " VD8"
cQuery += " WHERE VD8_FILIAL = '" + xFilial("VD8") + "'"
cQuery += "   AND VD8_CODEMP = '" + cEmpAnt + "'"
If !Empty(cFilFiltrar)
	cQuery += "   AND VD8_CODFIL = '" + cFilFiltrar + "'"
EndIf
cQuery += "   AND VD8_CODDEF = '" + cCodDef + "'"
cQuery += "   AND VD8_ATIVO  = '1'"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY VD8_CODFIL"
DbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), cQAlFil, .f., .t.)
While !(cQAlFil)->(EoF())
	aAdd(aRetFil, { lDefMarcar , (cQAlFil)->VD8_CODFIL , FWFilialName( cEmpAnt , (cQAlFil)->VD8_CODFIL ) } )
	(cQAlFil)->(dbSkip())
EndDo
(cQAlFil)->(DbCloseArea())
DbSelectArea("VD8")
If lMostraTela .and. len(aRetFil) > 0
	oDlgFilSel := MSDIALOG():New(0,0,300,400,STR0037,,,,,,,,,.t.) // Selecionar Filiais DEF
	oLbFil := TWBrowse():New(0,0,100,100,,,,oDlgFilSel,,,,,{ || aRetFil[oLbFil:nAt,01] := !aRetFil[oLbFil:nAt,01] },,,,,,,.F.,,.T.,,.F.,,,)
	oLbFil:addColumn( TCColumn():New( "", { || IIf(aRetFil[oLbFil:nAt,01],oOkTik,oNoTik) } ,,,,"LEFT" ,05,.T.,.F.,,,,.F.,) ) // Tik
	oLbFil:AddColumn( TCColumn():New( STR0038 , { || aRetFil[oLbFil:nAT,02] } ,,,,"LEFT" ,50,.F.,.F.,,,,.F.,) ) // Filial
	oLbFil:AddColumn( TCColumn():New( STR0039 , { || aRetFil[oLbFil:nAT,03] } ,,,,"LEFT" ,80,.F.,.F.,,,,.F.,) ) // Nome
	oLbFil:nAT := 1
	oLbFil:SetArray(aRetFil)
	oLbFil:bHeaderClick := {|oObj,nCol| IIf( nCol==1 , ( lLbMar := !lLbMar , aEval( aRetFil , { |x| x[01] := lLbMar } ) ) , .t. ) , oLbFil:Refresh() }
	oLbFil:Align := CONTROL_ALIGN_ALLCLIENT
	oDlgFilSel:bInit := { || EnchoiceBar(oDlgFilSel, { || oDlgFilSel:End() } , { || aRetFil := {} , oDlgFilSel:End() },, ) }
	oDlgFilSel:lCentered := .T.
	oDlgFilSel:Activate()
EndIf
Return aClone(aRetFil)

/*/{Protheus.doc} OX0520151_GravarDetalhamentoDEF
Grava Detalhamento DEF - Historicos por Campo DEF, Centro de Custo, Conta e Item Contabil
@author Andre Luis Almeida
@since 08/03/2021
@version 1.0
@param cCpoDef, caracter, Campo DEF
@param cCenCus, caracter, Centro de Custo
@param cCtaContab, caracter, Conta Contabil
@param cIteContab, caracter, Item da Conta Contabil
@param nVlr, numerico, Valor
@type function
/*/
Static Function OX0520151_GravarDetalhamentoDEF( cCpoDef , cCenCus , cCtaContab , cIteContab , nVlr )
Local cQuery  := ""
Local nRecVCU := 0
Local nRecVCV := 0
Local cFilVCU := xFilial("VCU")
Local cFilVCV := xFilial("VCV")

// Historico Detalhado - Totalizador por Campo DEF
cQuery := "SELECT R_E_C_N_O_ "
cQuery += "  FROM "+RetSQLName("VCU")
cQuery += " WHERE VCU_FILIAL='"+cFilVCU+"'"
cQuery += "   AND VCU_CODDEF='"+cPARCodDef+"'"
cQuery += "   AND VCU_CPODEF='"+cCpoDef+"'"
cQuery += "   AND VCU_DATA='"+dtos(dPARDataFinal)+"'"
cQuery += "   AND D_E_L_E_T_=' '"
nRecVCU := FM_SQL(cQuery)
If nRecVCU == 0
	RecLock("VCU",.t.)
		VCU->VCU_FILIAL := cFilVCU
		VCU->VCU_CODDEF := cPARCodDef 
		VCU->VCU_CPODEF := cCpoDef
		VCU->VCU_DATA   := dPARDataFinal 
		VCU->VCU_VALOR  := nVlr
	MsUnLock()
Else
	VCU->(DbGoTo(nRecVCU))
	RecLock("VCU",.f.)
		VCU->VCU_VALOR  += nVlr
	MsUnLock()
EndIf

// Historico Detalhado - Analitico por Campo DEF, Centro de Custo, Conta e Item Contabil
cQuery := "SELECT R_E_C_N_O_"
cQuery += "  FROM "+RetSQLName("VCV")
cQuery += " WHERE VCV_FILIAL='"+cFilVCV+"'"
cQuery += "   AND VCV_CODDEF='"+cPARCodDef+"'"
cQuery += "   AND VCV_CPODEF='"+cCpoDef+"'"
cQuery += "   AND VCV_DATA='"+dtos(dPARDataFinal)+"'"
cQuery += "   AND VCV_CCUSTO='"+cCenCus+"'"
cQuery += "   AND VCV_CCTCTB='"+cCtaContab+"'"
cQuery += "   AND VCV_ITEMCT='"+cIteContab+"'"
cQuery += "   AND D_E_L_E_T_=' '"
nRecVCV := FM_SQL(cQuery)
If nRecVCV == 0
	RecLock("VCV",.t.)
		VCV->VCV_FILIAL := cFilVCV
		VCV->VCV_CODDEF := cPARCodDef 
		VCV->VCV_CPODEF := cCpoDef
		VCV->VCV_DATA   := dPARDataFinal 
		VCV->VCV_CCUSTO := cCenCus
		VCV->VCV_CCTCTB := cCtaContab
		VCV->VCV_ITEMCT := cIteContab
		VCV->VCV_VALOR  := nVlr
	MsUnLock()
Else
	VCV->(DbGoTo(nRecVCV))
	RecLock("VCV",.f.)
		VCV->VCV_VALOR  += nVlr
	MsUnLock()
EndIf

Return

/*/
{Protheus.doc} OX0520167_ClasseConta
Funcao estatica que retorna a classe da conta contabil.
@type   Static Function
@author Otavio Favarelli
@since  19/11/2021
@param  cConta,		Caractere, Codigo da Conta Contabil a ser verificada.
@return cClassCta,	Caractere, Classe da Conta Contabil.
/*/
Static Function OX0520167_ClasseConta(cConta)
Local aArea		:= GetArea()
Local aAreaCT1	:= CT1->(GetArea())
Local cClassCta	:= ""

Default cConta := ""

If !Empty(cConta)

    DbSelectArea("CT1")
    CT1->(dbSetOrder(1)) // CT1_FILIAL + CT1_CONTA

    If CT1->(MsSeek(xFilial("CT1") + cConta))
    	cClassCta := CT1->CT1_CLASSE // 1=Sintetica;2=Analitica
    EndIf

EndIf


Return cClassCta
