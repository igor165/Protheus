#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "FISA032.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA032  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera as apuracoes:                                         ³±±
±±³          ³ 1 - Apuracao IVA - Formulario 200                          ³±±
±±³          ³ 2 - Apuracao IT - Formulario 400                           ³±±
±±³          ³ 3 - Apuracao IT Retencoes  - Formulario 410                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³ Manutencao Efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - Bolivia                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³06/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() la  ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA032()

	Local   nValTit   := 0
	Local   lOk       := .F.
	Local   cApur     := ""
	Local   cPerg     := ""
	Local   aApur     := {}
	Local   aApuAnt   := {}
	Local   aFiliais  := {}
	Local   aTitulos  := {}
	Local   aCombo    := {STR0001,STR0002,STR0048}//"IVA - Formulário 200"###"IT - Formulário 400"###"IT Retenções - Formulário 410"
	Private nF032Apur := 0
	
	//nF032Apur
	//1 - Apuracao IVA 200
	//2 - Apuracao IT 400
	//3 - Apuracao IT Retencoes 410

	oDlg01:=MSDialog():New(000,000,130,370,STR0003,,,,,,,,,.T.)//"Selecione a apuração"
	
		oSay01 := tSay():New(020,025,{|| STR0004 },oDlg01,,,,,,.T.,,,100,20)//"Apuração:"
		oCmb01 := tComboBox():New(0030,0025,{|u|if(PCount()>0,cApur:=u,cApur)},aCombo,100,020,oDlg01,,,,,,.T.)
		oBtn01:=sButton():New(0029,135,1,{|| lOk:=.T. ,oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)
	
	If lOk
		nF032Apur := aScan(aCombo,{|x| x == cApur})
		
		If nF032Apur == 3
			cPerg := "FISA032" 
		ElseIf nF032Apur == 2
			cPerg := "FISA032A" 
		Else
			cPerg := "FISA032B" 
		endif
		
		If Pergunte(cPerg,.T.)
		
			//Valida data de vencimento do titulo
			If MV_PAR05 == 1 .and. dDataBase > MV_PAR04
				MsgAlert(STR0005)//"A data de vencimento deve ser maior ou igual a data do sistema."
				Return Nil
			EndIf
			
			//Verifica se ha uma apuracao anterior
			If File(AllTrim(MV_PAR06)+AllTrim(MV_PAR08))
				If MsgYesNo(STR0006)//"Está apuração já foi gravada, deseja refazer?"
					If !DelTitApur(AllTrim(MV_PAR06)+AllTrim(MV_PAR08))
						MsgStop(STR0007,STR0008)//"O titulo já foi baixado."###"Apenas será possível excluir o título gerado e baixado anteriormente se for estornado."
						Return Nil
					Endif
				Else
					Return Nil
				EndIf
			EndIf
			
			//Seleciona Filiais
			aFiliais := MatFilCalc(MV_PAR03 == 1)
			
			//Carrega arquivo da apuracao anterior
			aApuAnt := FMApur(AllTrim(MV_PAR06),AllTrim(MV_PAR07))
			
			//Busca dados da apuracao
			Do Case
				Case nF032Apur == 1
					aApur := ApurIVA(aFiliais,aApuAnt) //Apuracao do IVA 200
					ImpRel200(cApur,aApur) //Imprime a apuracao
				Case nF032Apur == 2
					aApur := ApurIT(aFiliais,aApuAnt) //Apuracao do IT 400
					ImpRel400(cApur,aApur) //Imprime a apuracao
				Case nF032Apur == 3
					aApur := ApurITR(aFiliais,aApuAnt) //Apuracao do IT Retencoes 410
					ImpRel410(cApur,aApur) //Imprime a apuracao
				OtherWise
					MsgAlert(STR0009)//"Selecione uma apuração."
			EndCase	
			
			//Gera titulo da apuracao
			If MV_PAR05 == 1
				nValTit := Round(aApur[Len(aApur)][4],0)
				MsgRun(STR0010,,{|| IIf(nValTit>0,aTitulos := GrvTitLoc(nValTit),Nil) })//"Gerando titulo de apuração..."
			Endif

			//Gera arquivo da apuracao
			MsgRun(STR0011,,{|| CriarArq(AllTrim(MV_PAR06),AllTrim(MV_PAR08),aApur,aTitulos) })//"Gerando Arquivo apuração de imposto..."
			
		EndIf
	EndIf

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ApurITR  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 11.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega valores para a apuracao do IT Retencoes.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFiliais - Array com as filiais selecionadas.              ³±±
±±³          ³ aApuAnt  - Array com os dados da apuracao anterior.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aApur - Vetor com os valores da apuracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ApurITR(aFiliais,aApuAnt)

	Local nI       := 0
	Local cQry     := ""
	Local aApur    := {}
	Local aDados   := {}

	For nI:=1 To 11	
		aAdd(aDados,0)
	Next nI
	
	cQry := " SELECT"
	cQry += " SUM(SF3.F3_VALIMP2) AS VALIMP"
	cQry += " FROM "+RetSqlName("SF3")+" SF3"
	cQry += " WHERE SF3.D_E_L_E_T_ = ' '"
	cQry += " AND ( SF3.F3_FILIAL = '"+Space(TamSX3("F3_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQry += " OR SF3.F3_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQry += " )"
	cQry += " AND SF3.F3_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"
	cQry += " AND SF3.F3_TIPOMOV = 'C'"
	
	TcQuery cQry New Alias "QRY"
	
	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		aDados[1] += QRY->VALIMP
		QRY->(dbSkip())
	EndDo	
	QRY->(dbCloseArea())
	
	aDados[03] := MV_PAR09
	If Len(aApuAnt) > 3
		aDados[4] := aApuAnt[5]		
	Else
		aDados[4] := MV_PAR10
	EndIf
	aDados[07] := MV_PAR11
	
	aDados[2] := aDados[1]

	If (aDados[3] + aDados[4] - aDados[2]) > 0
		aDados[5] := aDados[3] + aDados[4] - aDados[2]
	EndIf
	
	If (aDados[2] - aDados[3] - aDados[4]) > 0
		aDados[6] := aDados[2] - aDados[3] - aDados[4]
	EndIf
	
	If (aDados[6] - aDados[7]) > 0
		aDados[8] := aDados[6] - aDados[7]
	EndIf
		
	aAdd(aApur,{1,STR0049,"013",aDados[01]})//"Imposto retido"
	aAdd(aApur,{2,STR0050,"909",aDados[02]})//"Imposto determinado (Importado do campo C013)"
	aAdd(aApur,{2,STR0051,"622",aDados[03]})//"Pagos a conte realizados em DDJJ anterior e/ou em boletos de pagamento."
	aAdd(aApur,{2,STR0052,"640",aDados[04]})//"Saldo disponível de pagamentos do período anterior a compensar."
	aAdd(aApur,{2,STR0053,"747",aDados[05]})//"Diferença a favor do contribuinte para o seguinte período (C622 + C640 - C909;Si > 0)"
	aAdd(aApur,{2,STR0054,"996",aDados[06]})//"Saldo definitivo a favor do Fisco (C909 - C622 - C640;Si > 0)"
	aAdd(aApur,{2,STR0055,"677",aDados[07]})//"Inclusão de credito nos valores (Sujeito a verificacao e confirmacao por parte da S.I.N.)."
	aAdd(aApur,{2,STR0056,"576",aDados[08]})//"Pagamento de imposto em especies (C996-C677; Se > 0), (Se a prestação é fora do término, deve realizar o pagamento no boleto F.1000)."

Return aApur

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ApurIVA  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega valores para a apuracao do IVA.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFiliais - Array com as filiais selecionadas.              ³±±
±±³          ³ aApuAnt  - Array com os dados da apuracao anterior.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ApurIVA(aFiliais,aApuAnt)

	Local nI     := 0
	Local cQryV   := ""
	Local cQryC   := ""
	Local aApur  := {}
	Local aDados := {}
	    
	For nI:=1 To 40
		aAdd(aDados,0)
	Next nI
	
	//Query Vendas
	cQryV := " SELECT"
	cQryV += " SA1.A1_TIPO AS TIPO"
	cQryV += " ,SF2.F2_MOEDA AS MOEDA"
	cQryV += " ,SF2.F2_BASIMP1 AS BASIMP"
	cQryV += " ,SF2.F2_VALIMP1 AS VALIMP"
	cQryV += " ,SF2.F2_ESPECIE AS ESPECIE"
	cQryV += " FROM "+RetSqlName("SF2")+" SF2"
	cQryV += " INNER JOIN "+RetSqlName("SA1")+" SA1"
	cQryV += " ON SF2.F2_CLIENTE = SA1.A1_COD"
	cQryV += " AND SF2.F2_LOJA = SA1.A1_LOJA"
	cQryV += " WHERE SF2.D_E_L_E_T_ = ' '"
	cQryV += " AND SA1.D_E_L_E_T_ = ' '"
	cQryV += " AND ( SF2.F2_FILIAL = '"+Space(TamSX3("F2_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryV += " OR SF2.F2_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryV += " )"
	cQryV += " AND ( SA1.A1_FILIAL = '"+Space(TamSX3("A1_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryV += " OR SA1.A1_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryV += " )"
	cQryV += " AND SF2.F2_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"
	cQryV += " UNION ALL"
	cQryV += " SELECT"
	cQryV += " SA1.A1_TIPO AS TIPO"
	cQryV += " ,SF1.F1_MOEDA AS MOEDA"
	cQryV += " ,SF1.F1_BASIMP1 AS BASIMP"
	cQryV += " ,SF1.F1_VALIMP1 AS VALIMP"
	cQryV += " ,SF1.F1_ESPECIE AS ESPECIE"
	cQryV += " FROM "+RetSqlName("SF1")+" SF1"
	cQryV += " INNER JOIN "+RetSqlName("SA1")+" SA1"
	cQryV += " ON SF1.F1_FORNECE = SA1.A1_COD"
	cQryV += " AND SF1.F1_LOJA = SA1.A1_LOJA"
	cQryV += " WHERE SF1.D_E_L_E_T_ = ' '"
	cQryV += " AND SA1.D_E_L_E_T_ = ' '"
	cQryV += " AND ( SF1.F1_FILIAL = '"+Space(TamSX3("F1_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryV += " OR SF1.F1_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryV += " )"
	cQryV += " AND ( SA1.A1_FILIAL = '"+Space(TamSX3("A1_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryV += " OR SA1.A1_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryV += " )"
	cQryV += " AND SF1.F1_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"

	TcQuery cQryV New Alias "QRV"
	
	dbSelectArea("QRV")
	Do While QRV->(!EOF())
		If AllTrim(QRV->ESPECIE) == "NF" .OR. AllTrim(QRV->ESPECIE) == "NDC"
			aDados[1] += QRV->BASIMP // 013
		EndIf	
		
		IF QRV->TIPO == '3'
			aDados[2] += QRV->BASIMP // 014
		Endif

		If QRV->BASIMP == 0
			aDados[3] += QRV->BASIMP //015
		Endif
			
		If QRV->BASIMP == 0 
			aDados[4] += QRV->BASIMP // 505
		Endif

		If 	AllTrim(QRV->ESPECIE) == "NCC"
			aDados[6] += QRV->BASIMP // 017
		Endif
		
		If 	SF2->F2_DESCONT != 0 .OR. SF1->F1_DESCONT != 0
			If QRV->MOEDA != 1
				aDados[7] += xMoeda(QRV->BASIMP, QRV->MOEDA, M->F2_MOEDA, SF2->F2_EMISSAO, 2,SF2->F2_TXMOEDA, M->F2_TXMOEDA)  // 018
			Else
				aDados[7] += QRV->BASIMP // 018
			Endif
		Endif

		QRV->(dbSkip())
	EndDo	
	QRV->(dbCloseArea())

	//Processo em analise 
	aDados[5] := 0 // 016

	aDados[8] := (aDados[1] + aDados[5] + aDados[6] + aDados[7]) * 0.13  // 039

	aDados[9] := 0 // 055 - sem uso

	aDados[10] := aDados[8] + aDados[9] //1002

	//Query Compras
	cQryC := " SELECT"
	cQryC += " SA2.A2_TIPO AS TIPOC"
	cQryC += " ,SF1.F1_MOEDA AS MOEDAC"
	cQryC += " ,SF1.F1_BASIMP1 AS BASIMPC"
	cQryC += " ,SF1.F1_VALIMP1 AS VALIMPC"
	cQryC += " ,SF1.F1_ESPECIE AS ESPECIEC"
	cQryC += " FROM "+RetSqlName("SF1")+" SF1"
	cQryC += " INNER JOIN "+RetSqlName("SA2")+" SA2"
	cQryC += " ON SF1.F1_FORNECE = SA2.A2_COD"
	cQryC += " AND SF1.F1_LOJA = SA2.A2_LOJA"
	cQryC += " WHERE SF1.D_E_L_E_T_ = ' '"
	cQryC += " AND SA2.D_E_L_E_T_ = ' '"
	cQryC += " AND ( SF1.F1_FILIAL = '"+Space(TamSX3("F1_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryC += " OR SF1.F1_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryC += " )"
	cQryC += " AND ( SA2.A2_FILIAL = '"+Space(TamSX3("A2_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryC += " OR SA2.A2_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryC += " )"
	cQryC += " AND SF1.F1_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"
	cQryC += " UNION ALL"
	cQryC += " SELECT"
	cQryC += " SA2.A2_TIPO AS TIPOC"
	cQryC += " ,SF2.F2_MOEDA AS MOEDAC"
	cQryC += " ,SF2.F2_BASIMP1 AS BASIMPC"
	cQryC += " ,SF2.F2_VALIMP1 AS VALIMPC"
	cQryC += " ,SF2.F2_ESPECIE AS ESPECIEC"
	cQryC += " FROM "+RetSqlName("SF2")+" SF2"
	cQryC += " INNER JOIN "+RetSqlName("SA2")+" SA2"
	cQryC += " ON SF2.F2_CLIENTE = SA2.A2_COD"
	cQryC += " AND SF2.F2_LOJA = SA2.A2_LOJA"
	cQryC += " WHERE SF2.D_E_L_E_T_ = ' '"
	cQryC += " AND SA2.D_E_L_E_T_ = ' '"
	cQryC += " AND ( SF2.F2_FILIAL = '"+Space(TamSX3("F2_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryC += " OR SF2.F2_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryC += " )"
	cQryC += " AND ( SA2.A2_FILIAL = '"+Space(TamSX3("A2_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQryC += " OR SA2.A2_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQryC += " )"
	cQryC += " AND SF2.F2_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"

	TcQuery cQryC New Alias "QRC"
	
	dbSelectArea("QRC")
	Do While QRC->(!EOF())
		If AllTrim(QRC->ESPECIEC) == "NF" .OR. AllTrim(QRC->ESPECIEC) == "NDP"
			aDados[11] += QRC->BASIMPC // 011
		EndIf	
		
		If QRC->BASIMPC != 0
			aDados[12] += QRC->BASIMPC // 026
		Endif

		If AllTrim(QRC->ESPECIEC) == "NCP" 
			aDados[14] += QRC->BASIMPC // 027
		Endif
		
		If 	SF1->F1_DESCONT != 0 .OR. SF2->F2_DESCONT != 0
			If QRC->MOEDAC != 1
				aDados[15] += xMoeda(QRC->BASIMPC, QRC->MOEDAC, M->F1_MOEDA, SF1->F1_EMISSAO, 2,SF1->F1_TXMOEDA, M->F1_TXMOEDA)  // 028
			Else
				aDados[15] += QRC->BASIMPC // 028
			Endif
		Endif

		QRC->(dbSkip())
	EndDo	
	QRC->(dbCloseArea())

	aDados[13] := 0 // 031 Sem uso

	aDados[16] := (aDados[12] + aDados[14] + aDados[15]) * 0.13 //114

	aDados[17] := (aDados[13] * (aDados[1] + aDados[2]) / (aDados[1] + aDados[2] + aDados[3] + aDados[4])) * 0.13 //1003

	aDados[18] := aDados[16] + aDados[17] // 1004

	If (aDados[18] - aDados[10]) > 0
		aDados[19] := aDados[18] - aDados[10] // 693
	Endif

	If aDados[10] - aDados[18] > 0
		aDados[20] := aDados[10] - aDados[18] //909
	Endif

	aDados[21] := MV_PAR09 //635
	aDados[22] := MV_PAR10 //648

	If ((aDados[20] - aDados[21]) - aDados[22]) > 0
		aDados[23] :=  (aDados[20] - aDados[21]) - aDados[22]   // 1001
	Endif

	aDados[24] := MV_PAR11 //622
	aDados[25] := MV_PAR12 //640
	
	If ((aDados[24] + aDados[25]) - aDados[23]) > 0
		aDados[26] := (aDados[24] + aDados[25]) - aDados[23] //643
	Endif 

	If ((aDados[23] - aDados[24]) - aDados[25]) > 0
		aDados[27] := (aDados[23] - aDados[24]) - aDados[25] //996
	Endif

	aDados[28] := MV_PAR14 //924
	aDados[29] := MV_PAR15 //925
	aDados[30] := MV_PAR16 //938
	aDados[31] := MV_PAR17 //954
	aDados[32] := MV_PAR18 //967
	aDados[33] := aDados[28] + aDados[29] + aDados[30] +aDados[31] + aDados[32] //955

	If (((aDados[19] + aDados[21]) + aDados[22]) - aDados[20]) > 0
		aDados[34] := (((aDados[19] + aDados[21]) + aDados[22]) - aDados[20]) //592
	Endif
	
	If (aDados[26] - aDados[33]) > 0
		aDados[35] := aDados[26] - aDados[33] //747
	Endif
	
	If (aDados[27] > 0 ) .OR. (aDados[33] - aDados[26]) > 0
		aDados[36] := aDados[33] - aDados[26] //646
	Endif
	
	aDados[37] := MV_PAR19/677
	
	If (aDados[36] - aDados[37]) > 0
		aDados[38] := aDados[36] - aDados[37] //576
	Endif
	
	aDados[39] := MV_PAR20 //580
	aDados[40] := MV_PAR21 //581

	aAdd(aApur,{1,STR0111, STR0175,aDados[01]}) //"Ventas de bienes y / o servicios tributados en el mercado interno, excepto ventas tributadas con Tasa cero"
	aAdd(aApur,{2,STR0112, STR0196,aDados[02]}) //"Exportación de bienes y operaciones exentas"
	aAdd(aApur,{2,STR0113, STR0197,aDados[03]}) //"Ventas tributadas con tasa cero"
	aAdd(aApur,{2,STR0114, STR0199,aDados[04]}) //"Ventas y operaciones no tributadas que no están sujetas a IVA"
	aAdd(aApur,{2,STR0115, STR0198,aDados[05]}) //"Valor atribuido a bienes y / o servicios retirados y consumo privado"
	aAdd(aApur,{2,STR0116, STR0176,aDados[06]}) //"Devoluciones y rescisiones efectuadas durante el período"
	aAdd(aApur,{2,STR0117, STR0177,aDados[07]}) //"Descuentos, bonos y descuentos obtenidos durante el período"
	aAdd(aApur,{2,STR0118, STR0178,aDados[08]}) //"Débito fiscal correspondiente a: [(C13 + C16 + C17 + C18) * 13%]"
	aAdd(aApur,{2,STR0119, STR0179,aDados[09]}) //"Débito fiscal actualizado correspondiente a reembolsos"
	aAdd(aApur,{2,STR0120, STR0180,aDados[10]}) //"Débito fiscal total en el período (C39 + C55)"
	aAdd(aApur,{2,STR0121, STR0181,aDados[11]}) //"Total de compras correspondientes a actividades tributadas y / o no tributadas"
	aAdd(aApur,{1,STR0122, STR0182,aDados[12]}) //"Compras directamente vinculadas a actividades tributadas"
	aAdd(aApur,{2,STR0123, STR0183,aDados[13]}) //"Compras donde no es posible detallar su relación con actividades tributadas y no tributadas"
	aAdd(aApur,{2,STR0124, STR0184,aDados[14]}) //"Devoluciones y rescisiones cobradas durante el período"
	aAdd(aApur,{2,STR0125, STR0185,aDados[15]}) //"Descuentos, bonos y descuentos concedidos durante el período"
	aAdd(aApur,{2,STR0126, STR0186,aDados[16]}) //"Crédito fiscal correspondiente a: [(C26 + C27 + C28) * 13%]"
	aAdd(aApur,{2,STR0127, STR0187,aDados[17]}) //"Crédito fiscal proporcional correspondiente a la actividad tributada [C31 * (C13 + C14) / (C13 + C14 + C15 + C505)] * 13%"
	aAdd(aApur,{2,STR0128, STR0188,aDados[18]}) //"Crédito fiscal total para el período (C114 + C1003)"
	aAdd(aApur,{1,STR0129, STR0189,aDados[19]}) //"Diferencia a favor del contribuyente (C1004-C1002; Si > 0)"
	aAdd(aApur,{1,STR0130, STR0157,aDados[20]}) //"Diferencia a favor del Tesoro o Impuesto determinado (C1002-C1004; Si> 0)"
	aAdd(aApur,{2,STR0131, STR0190,aDados[21]}) //"Saldo del crédito fiscal del período anterior por compensarse (C592 del formulario del período anterior)"
	aAdd(aApur,{2,STR0132, STR0191,aDados[22]}) //"Actualización de valor en el saldo del crédito fiscal del período anterior"
	aAdd(aApur,{2,STR0133, STR0159,aDados[23]}) //"Saldo tributario determinado a favor del Tesoro (C909-C635-C648; Si > 0)"
	aAdd(aApur,{2,STR0134, STR0160,aDados[24]}) //"Pagos a cuenta realizados en DD.JJ. y / o Billetes de pago correspondientes al período declarado"
	aAdd(aApur,{2,STR0135, STR0161,aDados[25]}) //"Saldo de pagos a cuenta del período anterior por compensarse (C747 del formulario del período anterior)"
	aAdd(aApur,{2,STR0136, STR0162,aDados[26]}) //"Saldo de pagos a cuenta, a favor del contribuyente (C622 + C640-C1001; Si > 0)"
	aAdd(aApur,{2,STR0137, STR0163,aDados[27]}) //"Saldo a favor del Tesoro (C1001-C622-C640; Si > 0)"
	aAdd(aApur,{2,STR0138, STR0164,aDados[28]}) //"Tributo omitido (C996)"
	aAdd(aApur,{2,STR0139, STR0165,aDados[29]}) //"Actualización del valor del tributo omitido"
	aAdd(aApur,{2,STR0140, STR0166,aDados[30]}) //"Intereses sobre el tributo omitido actualizados"
	aAdd(aApur,{2,STR0141, STR0167,aDados[31]}) //"Multa por violación de deber formal (IDF) por envío fuera del plazo"
	aAdd(aApur,{2,STR0142, STR0168,aDados[32]}) //"Multa de la IDF por aumento del impuesto determinado en DD.JJ. Retirada enviada después del plazo"
	aAdd(aApur,{2,STR0143, STR0169,aDados[33]}) //"Deuda fiscal total (C924 + C925 + C938 + C954 + C967)"
    aAdd(aApur,{2,STR0144, STR0192,aDados[34]}) //"Saldo final del crédito tributario a favor del contribuyente por el período siguiente (C693 + C635 + C648-C909; Si> 0)"
    aAdd(aApur,{2,STR0145, STR0171,aDados[35]}) //"Saldo final de pagos a cuenta, a favor del contribuyente para el período siguiente (C643-C955; Si > 0)"
	aAdd(aApur,{2,STR0146, STR0172,aDados[36]}) //"Saldo final a favor del Tesoro (C 996 o (C955-C643), según corresponda; Si > 0"
	aAdd(aApur,{2,STR0147, STR0173,aDados[37]}) //"Pago en valores (sujeto a verificación y confirmación por el SIN)"
	aAdd(aApur,{2,STR0148, STR0174,aDados[38]}) //"Pago en dinero (C646-C677; Si > 0)"
	aAdd(aApur,{2,STR0149, STR0193,aDados[39]}) //"Canje en la venta de bienes y / o servicios"
	aAdd(aApur,{2,STR0150, STR0194,aDados[40]}) //"Canje en la compra de bienes y / o servicios"

Return aApur

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ApurIT   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega valores para a apuracao do IT.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFiliais - Array com as filiais selecionadas.              ³±±
±±³          ³ aApuAnt  - Array com os dados da apuracao anterior.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aApur - Vetor com os valores da apuracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ApurIT(aFiliais,aApuAnt)

	Local nI       := 0
	Local cQry     := ""
	Local aApur    := {}
	Local aDados   := {}

	For nI:=1 To 19	
		aAdd(aDados,0)
	Next nI
	
	//Query
	cQry := " SELECT"
	cQry += " SUM(SF3.F3_BASIMP2) AS BASIMP , "
	cQry += " SUM(SF3.F3_EXENTAS) AS EXENTO"
	cQry += " FROM "+RetSqlName("SF3")+" SF3"
	cQry += " WHERE SF3.D_E_L_E_T_ = ' '"
	cQry += " AND ( SF3.F3_FILIAL = '"+Space(TamSX3("F3_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQry += " OR SF3.F3_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQry += " )"
	cQry += " AND SF3.F3_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"
	cQry += " AND SF3.F3_TIPOMOV = 'V'"
	
	TcQuery cQry New Alias "QRY"
	
	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		aDados[1]  += QRY->BASIMP
		aDados[15] += QRY->EXENTO
		QRY->(dbSkip())
	EndDo	
	QRY->(dbCloseArea())
	
	If Len(aApuAnt) > 2
		aDados[3] := aApuAnt[4]		
	Else
		aDados[3] := MV_PAR09
	EndIf
	aDados[06] := MV_PAR10
	If Len(aApuAnt) > 6
		aDados[7] := aApuAnt[8]		
	Else
		aDados[7] := MV_PAR11
	EndIf
	aDados[10] := MV_PAR12
	
	aDados[12] :=  aDados[01] - aDados[15] // descobrir o que são os isentos.

	aDados[2] := aDados[12] * 0.03 // criar uma pergunta

	If (aDados[3] - aDados[2]) > 0
		aDados[4] := aDados[3] - aDados[2]
	EndIf
	
	If (aDados[2] - aDados[3]) > 0
		aDados[5] := aDados[2] - aDados[3]
	EndIf
	
	If (aDados[6] + aDados[7] - aDados[5]) > 0
		aDados[8] := aDados[6] + aDados[7] - aDados[5]
	EndIf
	
	If (aDados[5] - aDados[6] - aDados[7]) > 0
		aDados[9] := aDados[5] - aDados[6] - aDados[7]
	EndIf
	
	If (aDados[19] - aDados[10]) > 0
		aDados[11] := aDados[19] - aDados[10]
	EndIf

	IF ((aDados[06]+aDados[07])-aDados[05]) > 0
		aDados[13] := (aDados[06]+aDados[07])-aDados[05]
	EndIf

	aDados[14] := aDados[5] - aDados[6] - aDados[7]

	aDados[16] := aDados[14] + (MV_PAR18 + MV_PAR19 + MV_PAR20 + MV_PAR21)

	IF (aDados[07] - aDados[02]) >0 
		aDados[17] := aDados[07] - aDados[02]
	EndIF

	IF (aDados[13] - aDados[16]) > 0 
		aDados[18] := aDados[13] - aDados[16]
	ENdIf

	If aDados[09] > 0 
		aDados[19] := aDados[09]
	ElseIf (aDados[16] - aDados[13]) > 0 
		aDados[19] := aDados[16] - aDados[13]
	EndIf


	aAdd(aApur,{1,STR0058, STR0175,aDados[01]})//"Total Ingressos brutos devengados y/o percebidos en especie (incluye ingresos exentos)"  //013
	aAdd(aApur,{1,STR0059, STR0155,aDados[15]})//"Ingresos exentos"  //032
	aAdd(aApur,{1,STR0060, STR0156,aDados[12]})//"Base imponible (C13 - C32)"  //024
	aAdd(aApur,{1,STR0061, STR0157,aDados[02]})//"Impuesto liquidado (3% de C024)" //909
	
	aAdd(aApur,{2,STR0062, STR0158,aDados[03]})//"Pago a conta IUE a compensar (1ra. instancia ou saldo do periodo anterior (C619 do Form. Anterior))" //664
	aAdd(aApur,{2,STR0063,STR0159,aDados[05]})//"Saldo a favor da Fisco (C909 - C664; Si > 0)" //1001
	aAdd(aApur,{2,STR0064, STR0160,aDados[06]})//"Pagamentos a conta realizados na DDJJ anterior e/ou em boletos de pagamento" //622
	aAdd(aApur,{2,STR0065, STR0161,aDados[07]})//"Saldo disponivel de pagamentos do periodo anterior a compensar" //640
	aAdd(aApur,{2,STR0066, STR0162,aDados[13]})//"Saldo por Pagos a Cuenta a favor del Contribuyente (C622+C640-C1001;Si > 0)" //643
	aAdd(aApur,{2,STR0067, STR0163,aDados[09]})//"Saldo definitivo a favor da fisco (C1001 - C622 - C640; Si > 0)" // 996

	aAdd(aApur,{2,STR0068 , STR0164,aDados[14]})//"Tributo Omitido (C996)" //924
	aAdd(aApur,{2,STR0069 , STR0165,MV_PAR18})//"Actualizacion de valor sobre Tributo Omitido."" //925
	aAdd(aApur,{2,STR0070 , STR0166,MV_PAR19})//"Interesse sobre Tributo Omitido Actualizado" //938
	aAdd(aApur,{2,STR0071 , STR0167,MV_PAR20})//"Multa por Incumplimiento al Deber Formal (IDF) por presentacion fuera de plazo." // 954
	aAdd(aApur,{2,STR0072 , STR0168,MV_PAR21})//"Multa por IDF por Incremento del Impuesto Determinado en DD.JJ. Rectificatoria presentada fuera de plazo" //967
	aAdd(aApur,{2,STR0073 , STR0169,aDados[16]})//"Total Deuda Tributaria" //955

	aAdd(aApur,{2,STR0074 , STR0170,aDados[17]})//"Saldo definitivo de IUE a compensar para el siguiente periodo (C664 - C909; Si > 0)" //619
	aAdd(aApur,{2,STR0075 , STR0171,aDados[18]})//"Saldo denitivo por Pagos a Cuenta a favor del Contribuyente para el siguiente período (C643-C955; Si >0)" //747
	aAdd(aApur,{2,STR0076 , STR0172,aDados[19]})//"Saldo definitivo a favor da fisco (C996 o (C955-C643) segun corresponda; Si > 0)" // 646

	aAdd(aApur,{2,STR0077 , STR0173,aDados[10]})//"Inclusão de credito nos valores (Sujeito a verificacao e confirmacao por parte da S.I.N.)." //677
	aAdd(aApur,{2,STR0078 , STR0174,aDados[11]})//"Pago en efectivo (C646-C677; Si > 0)" //576

 
Return aApur


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpRel200³ Autor ³ Leandro S Santos    ³ Data ³ 14.02.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime apuracao formulario 200                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTitulo - Titulo do relatorio.                             ³±±
±±³          ³ aApur   - Array com os dados da apuracao.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRel200(cTitulo,aApur)

	Local nI     := 0
	Local nLin   := 0
	Local nTam   := 0
	Local lCabLF := .F.
	Local aTexto := {}
		
	Private oFont1 := TFont():New("Verdana",,10,,.F.,,,,,.F.)
	Private oFont2 := TFont():New("Verdana",,10,,.T.,,,,,.F.)
	Private oFont3 := TFont():New("Verdana",,15,,.T.,,,,,.F.)
	Private oFont4 := TFont():New("Verdana",,08,,.T.,,,,,.F.)
	
	oPrint := TmsPrinter():New(cTitulo)
	oPrint:SetPaperSize(9)
	oPrint:SetPortrait()
	oPrint:StartPage()

	nLin := 50
	oPrint:Say(nLin,0050,cTitulo,oFont3)
	nLin += 100
	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0050,STR0079,oFont1) // "Nombre(s) y apellido(s) o nombre comercial del contribuyente"
	oPrint:Box(nLin,1750,nLin+80,2355)
	oPrint:Say(nLin+20,1770,STR0080,oFont2)  // "Nº Orden"
	
	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0040,SM0->M0_NOMECOM,oFont2)
	oPrint:Box(nLin,1750,nLin+80,2355)
	oPrint:Say(nLin+20,1770,CValtoChar(MV_PAR13),oFont1)
	
	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,1145)
	oPrint:Say(nLin+20,0040,STR0038,oFont1)//"NIT"
	oPrint:Box(nLin,1145,nLin+80,1750)
	oPrint:Say(nLin+20,1165,STR0037,oFont1)//"Periodo"
	oPrint:Box(nLin,1750,nLin+80,2030)
	oPrint:Say(nLin+20,1770,STR0081,oFont1)//"DD.JJ.ORIGINAL"
	oPrint:Box(nLin,2030,nLin+80,2355)
	oPrint:Say(nLin+20,2050,STR0082,oFont1)//"FOLIO"
		
	nLin += 80

	dbSelectArea("SA1")
	oPrint:Box(nLin,0020,nLin+80,1145)
	oPrint:Say(nLin+20,0040,Transform(SM0->M0_CGC,X3Picture("A1_CGC")),oFont2) // NIT
	oPrint:Box(nLin,1145,nLin+80,1295)
	oPrint:Say(nLin+20,1165,STR0083,oFont2) //"Mes"
	oPrint:Box(nLin,1295,nLin+80,1445)
	oPrint:Say(nLin+20,1315,AllTrim(Str(MV_PAR01)),oFont1) 
	oPrint:Box(nLin,1445,nLin+80,1595)
	oPrint:Say(nLin+20,1465,STR0084,oFont2) // "Ano"
	oPrint:Box(nLin,1595,nLin+80,1750)
	oPrint:Say(nLin+20,1615,AllTrim(Str(MV_PAR02)),oFont1)
	oPrint:Box(nLin,1750,nLin+80,1885)
	oPrint:Say(nLin+20,1770,STR0085,oFont2) // 534
	oPrint:Box(nLin,1885,nLin+80,2030)
	oPrint:Say(nLin+20,1905,AllTrim(Str(MV_PAR22)),oFont1)
	oPrint:Box(nLin,2030,nLin+80,2355)
	oPrint:Say(nLin+20,2050,STR0086,oFont4) //"Ent. Financiera"


	nLin += 100

	oPrint:Box(nLin,0020,nLin+80,2355)
	oPrint:Say(nLin+20,0040,STR0087,oFont2) //"Datos básicos de la declaración jurada que rectifica"

	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,0175)
	oPrint:Say(nLin+20,0040,STR0088,oFont2) // 518
	oPrint:Box(nLin,0175,nLin+80,0990)
	oPrint:Say(nLin+20,0195,CValtoChar(MV_PAR32),oFont1)
	oPrint:Box(nLin,0990,nLin+80,1145)
	oPrint:Say(nLin+20,1010,STR0089,oFont2) // 537
	oPrint:Box(nLin,1145,nLin+80,1445)
    oPrint:Say(nLin+20,1165,CValtoChar(MV_PAR23),oFont1)
    oPrint:Box(nLin,1445,nLin+80,1595)
    oPrint:Say(nLin+20,1465,CValtoChar(MV_PAR24),oFont1)
	oPrint:Box(nLin,1595,nLin+80,1750)
	oPrint:Say(nLin+20,1615,STR0090,oFont2) // 521
	oPrint:Box(nLin,1750,nLin+80,2355)
	oPrint:Say(nLin+20,1770,AllTrim(MV_PAR25),oFont1) 

	nLin += 100

	oPrint:Box(nLin,0020,nLin+80,2355)
	oPrint:Say(nLin+20,0040,STR0091,oFont2) //"Determinación del saldo final a favor del tesoro o del contribuyente"
	
	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0040,STR0151,oFont2) // "RUBRO 1: determinación del débito fiscal"
	oPrint:Box(nLin,1750,nLin+80,1900)
	oPrint:Say(nLin+20,1770,STR0093,oFont2) // Cod
	oPrint:Box(nLin,1900,nLin+80,2355)
	oPrint:Say(nLin+20,1920,STR0094,oFont4) // "Bolivianos sin centavos"
	
	For nI:=1 To Len(aApur)	
		
		nLin += 80
		nLin := FMudaPag(nLin)
		
		If nI == 11		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0152,oFont2) //"RUBRO 2: determinación del crédito tributario"
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2) // Cod
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4) //"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf

		If nI == 19		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0153,oFont2) // "RUBRO 3: determinación de la diferencia"
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2) // Cod
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4) //"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf

		If nI == 28		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0200,oFont2) //"RUBRO 4: Determinación de La Deuda Tributaria"                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2) // Cod
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4) //"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf
		
		If nI == 34		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0201,oFont2) //"RUBRO 5: Saldo Definitivo"  
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2) // Cod
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4) //"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf

		
		If nI == 37		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0202,oFont2) //"RUBRO 6: Importe de Pago"  
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2) // Cod
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4) //"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf

		If nI == 39		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0154,oFont2) //"RUBRO 7: datos informativos"
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2) // Cod
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4)  //"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf


		aTexto := QbrLin(aApur[nI,2],85)

		nTam := 80
		If Len(aApur[nI,2]) > 85
			oPrint:Say(nLin+70,0040,aTexto[2],oFont1)
			nTam := 130
		EndIf
	
		oPrint:Box(nLin,0020,nLin+nTam,1750)
		oPrint:Say(nLin+20,0040,aTexto[1],oFont1)
		
		oPrint:Box(nLin,1750,nLin+nTam,1900)
		oPrint:Say(nLin+20,1770,aApur[nI,3],oFont1)
		oPrint:Box(nLin,1900,nLin+nTam,2355)
		oPrint:Say(nLin+20,2000,AliDir(aApur[nI,4]),oFont1)
		
		If Len(aApur[nI,2]) > 85
			nLin += 50
		EndIf
		
	Next nI

	nLin += 80
	nLin := FMudaPag(nLin)

	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0040,STR0195,oFont2)
	oPrint:Box(nLin,1750,nLin+80,1900)
	oPrint:Say(nLin+20,1770,STR0043,oFont2)
	oPrint:Box(nLin,1900,nLin+80,2355)
	oPrint:Say(nLin+20,1920,STR0094,oFont4)
	nLin += 80
	nLin := FMudaPag(nLin)

	oPrint:Box(nLin,0020,nLin+80,00495)
	oPrint:Say(nLin+20,0040,STR0100,oFont2)
	oPrint:Box(nLin,00495,nLin+80,0970)
	oPrint:Say(nLin+20,0515,STR0101,oFont2)
	oPrint:Box(nLin,0970,nLin+80,1445)
	oPrint:Say(nLin+20,0990,STR0102,oFont2)
	oPrint:Box(nLin,1445,nLin+160,1750)
	oPrint:Say(nLin+20,1465,STR0103,oFont2)
	oPrint:Box(nLin,1750,nLin+160,1900)
	oPrint:Say(nLin+20,1770,STR0104,oFont2)
	oPrint:Box(nLin,1900,nLin+160,2355)
	oPrint:Say(nLin+20,1920,CValtoChar(MV_PAR29),oFont1)

	nLin += 80
	nLin := FMudaPag(nLin)

	oPrint:Box(nLin,0020,nLin+80,00170)
	oPrint:Say(nLin+20,0040,STR0105,oFont2) // "8880"
	oPrint:Box(nLin,0170,nLin+80,0495)
	oPrint:Say(nLin+20,0190,CValtoChar(MV_PAR26),oFont1)
	oPrint:Box(nLin,0495,nLin+80,0645)
	oPrint:Say(nLin+20,0515,STR0106,oFont2) // "8882"
	oPrint:Box(nLin,0645,nLin+80,0970)
	oPrint:Say(nLin+20,0665,CValtoChar(MV_PAR27),oFont1)
	oPrint:Box(nLin,0970,nLin+80,1120)
	oPrint:Say(nLin+20,0990,STR0107,oFont2) //"8881"
	oPrint:Box(nLin,1120,nLin+80,1445)
	oPrint:Say(nLin+20,1140,CValtoChar(MV_PAR28),oFont1)

	nLin += 80
	nLin := FMudaPag(nLin)
	
	oPrint:Box(nLin,0020,nLin+200,1445)
	oPrint:Say(nLin+20,0040,STR0108,oFont1) //"Yo juro por la exactitud de esta declaración"
	oPrint:Line(nLin+150,0060,nLin+150,1300) 
	oPrint:Box(nLin,1445,nLin+110,2355)
	oPrint:Say(nLin+20,1465,STR0109,oFont1) // "Aclaración de firma"
	oPrint:Say(nLin+70,1510,CValtoChar(MV_PAR30),oFont1)
	
	nLin += 110
	
	oPrint:Box(nLin,1445,nLin+090,2355)
	oPrint:Say(nLin+20,1465,STR0110,oFont1) // "C.I."
	oPrint:Say(nLin+20,1550,CValtoChar(MV_PAR31),oFont1)
	
	oPrint:EndPage()
	oPrint:Preview()
	oPrint:End()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpRel400³ Autor ³ Leandro S Santos    ³ Data ³ 14.02.2020 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime apuracao formulario 400.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTitulo - Titulo do relatorio.                             ³±±
±±³          ³ aApur   - Array com os dados da apuracao.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRel400(cTitulo,aApur)

	Local nI     := 0
	Local nLin   := 0
	Local nTam   := 0
	Local lCabLF := .F.
	Local aTexto := {}
	Local cDtPago := dToS(MV_PAR24)

	cDtPago := Substr(cDtPago,7,2) + "/" + Substr(cDtPago,5,2) + "/" +  Substr(cDtPago,1,4)
		
	Private oFont1 := TFont():New("Verdana",,10,,.F.,,,,,.F.)
	Private oFont2 := TFont():New("Verdana",,10,,.T.,,,,,.F.)
	Private oFont3 := TFont():New("Verdana",,15,,.T.,,,,,.F.)
	Private oFont4 := TFont():New("Verdana",,08,,.T.,,,,,.F.)
	
	oPrint := TmsPrinter():New(cTitulo)
	oPrint:SetPaperSize(9)
	oPrint:SetPortrait()
	oPrint:StartPage()

	nLin := 50
	oPrint:Say(nLin,0050,cTitulo,oFont3)
	nLin += 100
	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0050,STR0079,oFont1) //"Nombre(s) y apellido(s) o razon social del contribuyente"
	oPrint:Box(nLin,1750,nLin+80,2355)
	oPrint:Say(nLin+20,1770,STR0080,oFont1) //"N.Orden"
	
	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0040,SM0->M0_NOMECOM,oFont2)
	oPrint:Box(nLin,1750,nLin+80,2355)
	oPrint:Say(nLin+20,1770,MV_PAR13,oFont2) 
	
	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,1145)
	oPrint:Say(nLin+20,0040,STR0038,oFont1)//"NIT"
	oPrint:Box(nLin,1145,nLin+80,1750)
	oPrint:Say(nLin+20,1165,STR0037,oFont1)//"Periodo"
	oPrint:Box(nLin,1750,nLin+80,2030)
	oPrint:Say(nLin+20,1770,STR0081,oFont1)//"DD.JJ.ORIGINAL"
	oPrint:Box(nLin,2030,nLin+80,2355)
	oPrint:Say(nLin+20,2050,STR0082,oFont1)//"FOLIO"
		
	nLin += 80

	dbSelectArea("SA1")
	oPrint:Box(nLin,0020,nLin+80,1145)
	oPrint:Say(nLin+20,0040,Transform(SM0->M0_CGC,X3Picture("A1_CGC")),oFont2) // NIT
	oPrint:Box(nLin,1145,nLin+80,1295)
	oPrint:Say(nLin+20,1165,STR0083,oFont1)//"Mes"
	oPrint:Box(nLin,1295,nLin+80,1445)
	oPrint:Say(nLin+20,1315,AllTrim(Str(MV_PAR01)),oFont2)
	oPrint:Box(nLin,1445,nLin+80,1595)
	oPrint:Say(nLin+20,1465,STR0084,oFont1)//"Ano"
	oPrint:Box(nLin,1595,nLin+80,1750)
	oPrint:Say(nLin+20,1615,AllTrim(Str(MV_PAR02)),oFont2)
	oPrint:Box(nLin,1750,nLin+80,1885)
	oPrint:Say(nLin+20,1770,STR0085,oFont1) //"534"
	oPrint:Box(nLin,1885,nLin+80,2030)
	oPrint:Say(nLin+20,1905,"   ",oFont2)
	oPrint:Box(nLin,2030,nLin+80,2355)
	oPrint:Say(nLin+20,2050,STR0086,oFont4)//"Ent. financeira"


	nLin += 100

	oPrint:Box(nLin,0020,nLin+80,2355)
	oPrint:Say(nLin+20,0040,STR0087,oFont2)//"Datos basicos de la declaracion jurada que rectifica"

	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,0175)
	oPrint:Say(nLin+20,0040,STR0088,oFont2) //"518"
	oPrint:Box(nLin,0175,nLin+80,0990)
	oPrint:Say(nLin+20,0195,MV_PAR14,oFont1)
	oPrint:Box(nLin,0990,nLin+80,1145)
	oPrint:Say(nLin+20,1010,STR0089,oFont2)//"537"
	oPrint:Box(nLin,1145,nLin+80,1445)
	oPrint:Say(nLin+20,1165,MV_PAR15,oFont1)
	oPrint:Box(nLin,1445,nLin+80,1595)
	oPrint:Say(nLin+20,1465,MV_PAR16,oFont1)
	oPrint:Box(nLin,1595,nLin+80,1750)
	oPrint:Say(nLin+20,1615,STR0090,oFont2)//"521"
	oPrint:Box(nLin,1750,nLin+80,2355)
	oPrint:Say(nLin+20,1770,MV_PAR17,oFont1) 

	nLin += 100

	oPrint:Box(nLin,0020,nLin+80,2355)
	oPrint:Say(nLin+20,0040,STR0091,oFont2)//"Determinacion del saldo definitivo a favor del fisco o del contribuyente"
	
	nLin += 80

	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0040,STR0092,oFont2)//"RUBRO 1: Determinacion de la base imponible e impuesto"
	oPrint:Box(nLin,1750,nLin+80,1900)
	oPrint:Say(nLin+20,1770,STR0093,oFont2)//"Cod"
	oPrint:Box(nLin,1900,nLin+80,2355)
	oPrint:Say(nLin+20,1920,STR0094,oFont4)//"Bolivianos sin centavos"
	          	
	For nI:=1 To Len(aApur)	
		
		nLin += 80
		nLin := FMudaPag(nLin)
		
		If nI == 5		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0095,oFont2)//"RUBRO 2: Determinacion del saldo"
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2)//"Cod"
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4)//"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf
		
		If nI == 11		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0096,oFont2)//"RUBRO 3: Determinacion de la deuda tributaria"
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2) //"Cod"
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4)//"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf

		If nI == 17		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0097,oFont2)//"RUBRO 4: Saldo definitivo"
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2)//"Cod"
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4)//"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf
		
		If nI == 20		
			oPrint:Box(nLin,0020,nLin+80,1750)
			oPrint:Say(nLin+20,0040,STR0098,oFont2)//"RUBRO 5: Importe pago"
			oPrint:Box(nLin,1750,nLin+80,1900)
			oPrint:Say(nLin+20,1770,STR0093,oFont2)//"Cod"
			oPrint:Box(nLin,1900,nLin+80,2355)
			oPrint:Say(nLin+20,1920,STR0094,oFont4)//"Bolivianos sin centavos"
			nLin += 80
			nLin := FMudaPag(nLin)
		EndIf


		aTexto := QbrLin(aApur[nI,2],90)

		nTam := 80
		If Len(aApur[nI,2]) > 90
			oPrint:Say(nLin+70,0040,aTexto[2],oFont1)
			nTam := 130
		EndIf
	
		oPrint:Box(nLin,0020,nLin+nTam,1750)
		oPrint:Say(nLin+20,0040,aTexto[1],oFont1)
		
		oPrint:Box(nLin,1750,nLin+nTam,1900)
		oPrint:Say(nLin+20,1770,aApur[nI,3],oFont1)
		oPrint:Box(nLin,1900,nLin+nTam,2355)
		oPrint:Say(nLin+20,2000,AliDir(aApur[nI,4]),oFont1)
		
		If Len(aApur[nI,2]) > 90
			nLin += 50
		EndIf
		
	Next nI

	nLin += 80
	nLin := FMudaPag(nLin)

	oPrint:Box(nLin,0020,nLin+80,1750)
	oPrint:Say(nLin+20,0040,STR0099,oFont2)//"RUBRO 6: Datos pago sigma"
	oPrint:Box(nLin,1750,nLin+80,1900)
	oPrint:Say(nLin+20,1770,STR0093,oFont2)//"Cod"
	oPrint:Box(nLin,1900,nLin+80,2355)
	oPrint:Say(nLin+20,1920,STR0094,oFont4)//"Bolivianos sin centavos"
	nLin += 80
	nLin := FMudaPag(nLin)

	oPrint:Box(nLin,0020,nLin+80,00495)
	oPrint:Say(nLin+20,0040,STR0100,oFont2)//"N° C-31:"
	oPrint:Box(nLin,00495,nLin+80,0970)
	oPrint:Say(nLin+20,0515,STR0101,oFont2)//"N° de pago: "
	oPrint:Box(nLin,0970,nLin+80,1445)
	oPrint:Say(nLin+20,0990,STR0102,oFont2)//"Confirm.Pago:"
	oPrint:Box(nLin,1445,nLin+160,1750)
	oPrint:Say(nLin+20,1465,STR0103,oFont2)//"Imp.Pag.SIGMA"
	oPrint:Box(nLin,1750,nLin+160,1900)
	oPrint:Say(nLin+20,1770,STR0104,oFont2)//"8883"
	oPrint:Box(nLin,1900,nLin+160,2355)
	oPrint:Say(nLin+20,1920,cValtoChar(MV_PAR25),oFont1)

	nLin += 80
	nLin := FMudaPag(nLin)

	oPrint:Box(nLin,0020,nLin+80,00170)
	oPrint:Say(nLin+20,0040,STR0105,oFont2)//"8880"
	oPrint:Box(nLin,0170,nLin+80,0495)
	oPrint:Say(nLin+20,0190,MV_PAR22,oFont1)
	oPrint:Box(nLin,0495,nLin+80,0645)
	oPrint:Say(nLin+20,0515,STR0106,oFont2)//"8882"
	oPrint:Box(nLin,0645,nLin+80,0970)
	oPrint:Say(nLin+20,0665,MV_PAR23,oFont1)
	oPrint:Box(nLin,0970,nLin+80,1120)
	oPrint:Say(nLin+20,0990,STR0107,oFont2)//"8881"
	oPrint:Box(nLin,1120,nLin+80,1445)
	oPrint:Say(nLin+20,1140,cDtPago,oFont1)

	nLin += 80
	nLin := FMudaPag(nLin)
	
	oPrint:Box(nLin,0020,nLin+200,1445)
	oPrint:Say(nLin+20,0040,STR0108,oFont1)//"Juro la exactitud de la presente declaracion"
	oPrint:Line(nLin+150,0060,nLin+150,1300) 
	oPrint:Box(nLin,1445,nLin+110,2355)
	oPrint:Say(nLin+20,1465,STR0109,oFont1)//"Aclaracion de Firma"
	oPrint:Say(nLin+70,1510,MV_PAR26,oFont1)
	
	nLin += 110
	
	oPrint:Box(nLin,1445,nLin+090,2355)
	oPrint:Say(nLin+20,1465,STR0110,oFont1)//"C.I."
	oPrint:Say(nLin+20,1550,MV_PAR27,oFont1)


	oPrint:EndPage()
	oPrint:Preview()
	oPrint:End()

Return Nil


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpRel410³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime apuracao formulario 410.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTitulo - Titulo do relatorio.                             ³±±
±±³          ³ aApur   - Array com os dados da apuracao.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpRel410(cTitulo,aApur)

Local nI     := 0
Local nLin   := 0
Local nTam   := 0
Local lCabLF := .F.
Local aTexto := {}
	
Private oFont1 := TFont():New("Verdana",,10,,.F.,,,,,.F.)
Private oFont2 := TFont():New("Verdana",,10,,.T.,,,,,.F.)
Private oFont3 := TFont():New("Verdana",,15,,.T.,,,,,.F.)

oPrint := TmsPrinter():New(cTitulo)
oPrint:SetPaperSize(9)
oPrint:SetPortrait()
oPrint:StartPage()

nLin := 50
oPrint:Say(nLin,0050,cTitulo,oFont3)
nLin += 70
oPrint:Say(nLin,0050,STR0036,oFont1)//"Declaracao Jurada Mensal"

oPrint:Box(nLin,1900,0280,2355)
oPrint:Say(nLin+20,1920,STR0037,oFont1)//"Periodo"

nLin += 80
oPrint:Box(nLin,0020,nLin+80,0450)
oPrint:Say(nLin+20,0040,STR0038,oFont1)//"NIT"
oPrint:Box(nLin,0450,nLin+80,1900)
oPrint:Say(nLin+20,0470,STR0039,oFont1)//"Razao social"
oPrint:Box(nLin,1900,nLin+80,2100)
oPrint:Say(nLin+20,1920,STR0040,oFont2)//"Mes"
oPrint:Box(nLin,2100,nLin+80,2355)
oPrint:Say(nLin+20,2120,STR0041,oFont2)//"Ano"
			
nLin += 80
dbSelectArea("SA1")
oPrint:Box(nLin,0020,nLin+80,0450)
oPrint:Say(nLin+20,0040,Transform(SM0->M0_CGC,X3Picture("A1_CGC")),oFont1)
oPrint:Box(nLin,0450,nLin+80,1900)
oPrint:Say(nLin+20,0470,SM0->M0_NOMECOM,oFont1)
oPrint:Box(nLin,1900,nLin+80,2100)
oPrint:Say(nLin+20,1920,AllTrim(Str(MV_PAR01)),oFont2)
oPrint:Box(nLin,2100,nLin+80,2355)
oPrint:Say(nLin+20,2120,AllTrim(Str(MV_PAR02)),oFont2)

nLin += 100
oPrint:Box(nLin,0020,nLin+80,1750)
oPrint:Say(nLin+20,0040,STR0042,oFont2)//"Dados basicos da declaração jurada a favor da FISCO ou do contribuinte."
oPrint:Box(nLin,1750,nLin+80,1900)
oPrint:Say(nLin+20,1770,STR0043,oFont2)//"Cód"
oPrint:Box(nLin,1900,nLin+80,2355)
oPrint:Say(nLin+20,1920,STR0044,oFont2)//"Importe"

For nI:=1 To Len(aApur)	
	
	nLin += 80
	nLin := FMudaPag(nLin)
	
	If !lCabLF .and. aApur[nI,1] == 2		
		oPrint:Box(nLin,0020,nLin+80,2355)
		oPrint:Say(nLin+20,0040,STR0045,oFont2)//"Liquidação do imposto"
		nLin += 80
		nLin := FMudaPag(nLin)
		lCabLF := .T.			
	EndIf
	
	aTexto := QbrLin(aApur[nI,2],85)

	nTam := 80
	If Len(aApur[nI,2]) > 85
		oPrint:Say(nLin+70,0040,aTexto[2],oFont1)
		nTam := 130
	EndIf

	oPrint:Box(nLin,0020,nLin+nTam,1750)
	oPrint:Say(nLin+20,0040,aTexto[1],oFont1)
	
	oPrint:Box(nLin,1750,nLin+nTam,1900)
	oPrint:Say(nLin+20,1770,aApur[nI,3],oFont1)
	oPrint:Box(nLin,1900,nLin+nTam,2355)
	oPrint:Say(nLin+20,2000,AliDir(aApur[nI,4]),oFont1)
	
	If Len(aApur[nI,2]) > 85
		nLin += 50
	EndIf
	
Next nI

oPrint:EndPage()
oPrint:Preview()
oPrint:End()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ QbrLin   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 24.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a qubra do texto de acordo com o tamanho passado pelo  ³±±
±±³          ³ parametro.                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTxt - Texto a ser feito a quebra.                         ³±±
±±³          ³ nLen - Tamanho do texto para a quebra.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aTxt - Array com as linhas de texto.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Static Function QbrLin(cTxt,nLen)

	Local nI   := 1
	Local aTxt := {}
	
	If Len(cTxt) > nLen
		For nI:=nLen To 1 Step -1
			If SubStr(cTxt,nI,1) == " "
				Exit
			EndIf
		Next nI
		aAdd(aTxt,SubStr(cTxt,1,nI))
		aAdd(aTxt,SubStr(cTxt,nI+1,Len(cTxt)))
	Else
		aAdd(aTxt,cTxt)
	EndIf

Return aTxt

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FMudaPag ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz a mudanca de pagina se nescesario.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nLin - Linha atual da impressao.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aApur - Vetor com os valores da apuracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/	
Static Function FMudaPag(nLin)

	If (nLin+80) >= 3350
		nLin := 50
		oPrint:EndPage()
		oPrint:StartPage()
	EndIf
		
Return nLin

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AliDir   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Faz alinhamento do valor a direita.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nVal - Valor a ser alinhado.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cRet - Valor alinhado.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AliDir(nVal)

	Local cRet     := ""
	Local cPict := "@E 999,999,999"
	
	If Len(Alltrim(Str(Int(nVal))))==9                    
		cRet:=PADL(" ",1," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==8                    
		cRet:=PADL(" ",3," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==7                    
		cRet:=PADL(" ",5," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==6                    
		cRet:=PADL(" ",8," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==5                     
		cRet:=PADL(" ",10," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==4                       
		cRet:=PADL(" ",12," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==3                    
		cRet:=PADL(" ",15," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==2               
		cRet:=PADL(" ",17," ")+alltrim(Transform(nVal,cPict))
	ElseIf Len(Alltrim(Str(Int(nVal))))==1         
		cRet:=PADL(" ",19," ")+alltrim(Transform(nVal,cPict))
	EndIf

Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DelTitApur³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Deleta o titulo da apuracao.                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNomeArq - Arquivo da apuracao com os dados do titulo a    ³±±
±±³          ³            ser excluido.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ lRet - Indica se o titulo foi ou nao deletado.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/        
Static Function DelTitApur(cNomArq)

	Local   lRet        := .T.
	Local   cBuffer     := ""
	Local   aLin        := {}
	Local   aDadosSE2   := {}
	Private lMsErroAuto := .F.
	
	If FT_FUSE(cNomArq) <> -1
		FT_FGOTOP()
		Do While !FT_FEOF()
			cBuffer := FT_FREADLN()
			If Substr(cBuffer,1,3) == "TIT"
				aLin := Separa(cBuffer,";")
				dbSelectArea("SE2")
				SE2->(dbGoTop())
				SE2->(dbSetOrder(1))
				If SE2->(dbSeek(xFilial("SE2")+aLin[2]+aLin[3]))
					If SE2->E2_VALOR <> SE2->E2_SALDO //Já foi dado Baixa no Título				
						lRet := .F.
					Else	
						aAdd(aDadosSE2,{"E2_FILIAL" ,xFilial("SE2"),nil})
						aAdd(aDadosSE2,{"E2_PREFIXO",SE2->E2_PREFIXO,nil})
						aAdd(aDadosSE2,{"E2_NUM"    ,SE2->E2_NUM,nil})
						aAdd(aDadosSE2,{"E2_PARCELA",SE2->E2_PARCELA,nil})
						aAdd(aDadosSE2,{"E2_TIPO"   ,SE2->E2_TIPO,nil})
						aAdd(aDadosSE2,{"E2_FORNECE",SE2->E2_FORNECE,nil})
						aAdd(aDadosSE2,{"E2_LOJA"   ,SE2->E2_LOJA,nil})
						     
						MsExecAuto({|x,y,z| FINA050(x,y,z)},aDadosSE2,,5)
						If lMsErroAuto
			       			MostraErro()
			       			lRet := .F.
				  		EndIf
					EndIf
				Endif
			EndIF
			FT_FSKIP()
		EndDo
	Else
		Alert(STR0046)//"Erro na abertura do arquivo"
		Return Nil	
	EndIF
	FT_FUSE()
	
	If lRet
		fErase(cNomArq)
	Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriarArq ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cria arquivo da apuracao.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDir     - Diretorio do arquivo a ser gerado.              ³±±
±±³          ³ cArq     - Nome do arquivo a ser gerado.                   ³±±
±±³          ³ aDados   - Dados do arquivo a ser gerdado.                 ³±±
±±³          ³ aTitulos - Array com os dados do titulo gerado.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aApur - Vetor com os valores da apuracao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriarArq(cDir,cArq,aDados,aTitulos)

	Local nHdl   := 0
	Local nlX    := 0
	Local cLinha := ""
	Local cApur  := ""
	
	Do Case
		Case nF032Apur == 1
			cApur := "IVA"
		Case nF032Apur == 2
			cApur := "ITR"
		Case nF032Apur == 3
			cApur := "ITC"
	EndCase
	
	nHdl := fCreate(cDir+cArq)
	If nHdl <= 0
		ApMsgStop(STR0057)//"Ocorreu um erro ao criar o arquivo."
	Endif  
	
	cLinha := cApur
	For nlX := 1 to Len(aDados)
		cLinha += ";"+AllTrim(Str(aDados[nlX,4]))
	Next nlX
	cLinha += chr(13)+chr(10)
	fWrite(nHdl,cLinha)
	
	If Len(aTitulos) > 0
		cLinha := "TIT"
		For nlX := 1 to Len(aTitulos)
			cLinha += ";"
			If ValType(aTitulos[nlX]) == "N"
				cLinha += AllTrim(Str(aTitulos[nlX]))
			Else
				cLinha += AllTrim(aTitulos[nlX])
			EndIf
		Next nlX
		cLinha += chr(13)+chr(10)
		fWrite(nHdl,cLinha)
	EndIf
	
	If nHdl > 0
		fClose(nHdl)
	Endif
	
Return nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FMApur   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os valores de um arquivo de apuracao               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cDir     - Diretorio do arquivo a ser importado.           ³±±
±±³          ³ cArq     - Nome do arquivo a ser importado.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aDados - Dados do arquivo importado.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FMApur(cDir,cNomArq)
 
 	Local nlI    := 0
 	Local cLinha := ""
 	Local cApur  := ""
	Local aAux   := {}
	Local aDados := {}
	
	Do Case
		Case nF032Apur == 1
			cApur := "IVA"
		Case nF032Apur == 2
			cApur := "ITR"
		Case nF032Apur == 3
			cApur := "ITC"
	EndCase

	IF FT_FUSE(cDir+cNomArq) <> -1
		FT_FGOTOP()
		Do While !FT_FEOF()
			cLinha := FT_FREADLN()
			If SubStr(cLinha,1,4) == cApur+";"
				cLinha := SubStr(cLinha,5,Len(cLinha))
				aAux := Separa(cLinha,";")
			EndIf
			FT_FSKIP()
		EndDo
		FT_FUSE()
	EndIf
	
	For nlI:=1 To Len(aAux)
		aAdd(aDados,Val(aAux[nlI]))
	Next nlI
	
Return aDados
