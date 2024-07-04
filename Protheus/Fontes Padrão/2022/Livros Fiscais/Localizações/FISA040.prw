#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "FISA040.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FISA040  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 24.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera as apuracoes:                                         ³±±
±±³          ³ 1 - Declaracao 104 IVA                                     ³±±
±±³          ³ 2 - Declaracao 106 ISC                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³ Manutencao Efetuada                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±³ Uso      ³ Fiscal - Costa Rica                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³Data    ³ BOPS     ³ Motivo da Alteracao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jonathan Glz³08/07/15³PCREQ-4256³Se elimina la funcion AjustaSX1() que ³±±
±±³            ³        ³          ³hace modificacion a SX1 por motivo de ³±±
±±³            ³        ³          ³adecuacion a fuentes a nuevas estruc- ³±±
±±³            ³        ³          ³turas SX para Version 12.             ³±±
±±³M.Camargo   ³09.11.15³PCREQ-4262³Merge sistemico v12.1.8		           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FISA040()

	Local   lOk       := .F.
	Local   cApur     := ""
	Local   cPerg     := ""
	Local   aApur     := {}
	Local   aApuAnt   := {}
	Local   aFiliais  := {}
	Local   aTitulos  := {}
	Local   aCombo    := {STR0001,STR0002}//"Declaração 104 IVA"###"Declaração 106 ISC"
	Private nF032Apur := 0
	
	//nF032Apur
	//1 - Declaracao 104 IVA
	//2 - Declaracao 106 ISC

	oDlg01:=MSDialog():New(000,000,130,370,STR0003,,,,,,,,,.T.)//"Selecione a declaração"
	
		oSay01 := tSay():New(020,025,{|| STR0004 },oDlg01,,,,,,.T.,,,100,20)//"Declaração:"
		oCmb01 := tComboBox():New(0030,0025,{|u|if(PCount()>0,cApur:=u,cApur)},aCombo,100,020,oDlg01,,,,,,.T.)
		oBtn01 := sButton():New(0029,135,1,{|| lOk:=.T. ,oDlg01:End() },oDlg01,.T.,,)
	
	oDlg01:Activate(,,,.T.,,,)
	
	If lOk
		nF032Apur := aScan(aCombo,{|x| x == cApur})
		
		//Cria grupo de perguntas
		cPerg := "FISA040"+AllTrim(Str(nF032Apur))
		
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
					aApur := DeclIVA(aFiliais,aApuAnt) //Declaração 104 IVA
				Case nF032Apur == 2
					aApur := DeclISC(aFiliais,aApuAnt) //Declaração 106 ISC
				OtherWise
					MsgAlert(STR0009)//"Selecione uma declaração."
			EndCase	
			
			//Imprime a apuracao
			ImpRel(cApur,aApur)
			
			//Gera titulo da apuracao
			If MV_PAR05 == 1
				MsgRun(STR0010,,{|| IIf(aApur[Len(aApur)][4]>0,aTitulos := GrvTitLoc(aApur[Len(aApur)][4]),Nil) })//"Gerando titulo de apuração..."
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
±±³Funcao    ³ DeclIVA  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 24.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega valores para a apuracao do IVA.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFiliais - Array com as filiais selecionadas.              ³±±
±±³          ³ aApuAnt  - Array com os dados da apuracao anterior.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA040                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DeclIVA(aFiliais,aApuAnt)

	Local nI     := 0
	Local nSinal := 1
	Local cQry   := ""
	Local aApur  := {}
	Local aDados := {}
    
	For nI:=1 To 26	
		aAdd(aDados,0)
	Next nI
	
	//Query
	cQry := " SELECT"
	cQry += "  SF3.F3_TIPOMOV AS MOV"
	cQry += " ,SF3.F3_ESPECIE AS ESPECIE"
	cQry += " ,SF3.F3_ESTADO AS PROV"
	cQry += " ,SFC.FC_CREDIMP AS CREDIMP"
	cQry += " ,SF3.F3_ALQIMP1 AS ALQIMP"
	cQry += " ,SUM(SF3.F3_BASIMP1) AS BASIMP"
	cQry += " ,SUM(SF3.F3_VALIMP1) AS VALIMP"
	cQry += " FROM "+RetSqlName("SF3")+" SF3"
	cQry += " INNER JOIN "+RetSqlName("SFC")+" SFC ON"
	cQry += " ("
	cQry += "  SFC.FC_FILIAL = '" + xFilial("SFC") + "'"
	cQry += "  AND SF3.F3_TES = SFC.FC_TES"
	cQry += "  AND SFC.D_E_L_E_T_ = ' '"
	cQry += "  AND ("
	cQry += "        SFC.FC_IMPOSTO = 'IVA' OR "
	cQry += "        SFC.FC_IMPOSTO = 'IVC'"
	cQry += "      )"
	cQry += " )"
	cQry += " WHERE SF3.D_E_L_E_T_ = ' '"
	cQry += " AND SF3.F3_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"
	cQry += " AND SF3.F3_BASIMP1 > 0"
	cQry += " AND ( SF3.F3_FILIAL = '"+Space(TamSX3("F3_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQry += " OR SF3.F3_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQry += " )"
	cQry += " GROUP BY SF3.F3_TIPOMOV"
	cQry += " ,SF3.F3_ESPECIE"
	cQry += " ,SF3.F3_ESTADO"
	cQry += " ,SFC.FC_CREDIMP"
	cQry += " ,SF3.F3_ALQIMP1"
	
	TcQuery cQry New Alias "QRY"
	
	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		If QRY->ESPECIE $ "NCC|NDE|NDI|NCP"
			nSinal := -1
		Else
			nSinal := 1
		EndIf
		If QRY->MOV == "V"
			If QRY->PROV $ "EX|08"
				aDados[01] += QRY->BASIMP * nSinal
			Else
				If QRY->ALQIMP == 0
					aDados[02] += QRY->BASIMP * nSinal
				Else
					If QRY->ALQIMP == 13
						aDados[04] += QRY->BASIMP * nSinal
					ElseIf QRY->ALQIMP == 10
						aDados[05] += QRY->BASIMP * nSinal
					ElseIf QRY->ALQIMP == 5
						aDados[06] += QRY->BASIMP * nSinal
					EndIf
					aDados[03] += QRY->BASIMP * nSinal
					aDados[13] += QRY->VALIMP * nSinal
				EndIf
			EndIf
		Else
			If QRY->PROV $ "EX|08"
				If QRY->ALQIMP == 0
					aDados[09] += QRY->BASIMP * nSinal
				Else
					aDados[10] += QRY->BASIMP * nSinal
					If QRY->CREDIMP == "1"
						aDados[14] += QRY->VALIMP * nSinal
					EndIf
				EndIf
			Else
				If QRY->ALQIMP == 0
					aDados[11] += QRY->BASIMP * nSinal
				Else
					aDados[12] += QRY->BASIMP * nSinal
					If QRY->CREDIMP == "1"
						aDados[15] += QRY->VALIMP * nSinal
					EndIf
				EndIf
			EndIf
		EndIf
		QRY->(dbSkip())
	EndDo	
	QRY->(dbCloseArea())
	
	aDados[07] := MV_PAR09
	If Len(aApuAnt) > 17
		aDados[19] := aApuAnt[18]
	Else
		aDados[19] := MV_PAR10
	EndIf
	aDados[21] := MV_PAR11
	aDados[23] := MV_PAR12
	aDados[25] := MV_PAR13
	
	aDados[8] := aDados[3] + aDados[7]
	aDados[16] := aDados[14]+ aDados[15]
	If (aDados[13] - aDados[16]) > 0
		aDados[17] := aDados[13] - aDados[16]
	EndIf
	If (aDados[16] - aDados[13]) > 0
		aDados[18] := aDados[16] - aDados[13]
	EndIf
	
	If (aDados[13] - aDados[16] - aDados[19]) > 0
		aDados[20] := aDados[13] - aDados[16] - aDados[19]
	EndIf
	If (aDados[20] - aDados[21]) > 0
		aDados[22] := aDados[20] - aDados[21]
	EndIf
	aDados[24] := aDados[22] + aDados[23]
	If (aDados[24] - aDados[25]) > 0
		aDados[26] := aDados[24] - aDados[25]
	EndIf
	 
	
	aDados[01]:=Round(aDados[01],0)
	aDados[02]:=Round(aDados[02],0)
	aDados[03]:=Round(aDados[03],0)
	aDados[04]:=Round(aDados[04],0)
	aDados[05]:=Round(aDados[05],0)
	aDados[06]:=Round(aDados[06],0)
	aDados[07]:=Round(aDados[07],0)
	aDados[08]:=Round(aDados[08],0)
	aDados[09]:=Round(aDados[09],0)
	aDados[10]:=Round(aDados[10],0)
	aDados[11]:=Round(aDados[11],0)
	aDados[12]:=Round(aDados[12],0)
	aDados[13]:=Round(aDados[13],0) 
	aDados[14]:=Round(aDados[14],0)
	aDados[15]:=Round(aDados[15],0)
	aDados[16]:=Round(aDados[16],0)
	aDados[17]:=Round(aDados[17],0)
	aDados[18]:=Round(aDados[18],0) 
	aDados[19]:=Round(aDados[19],0)
	aDados[20]:=Round(aDados[20],0)
	aDados[21]:=Round(aDados[21],0)
	aDados[22]:=Round(aDados[22],0)
	aDados[23]:=Round(aDados[23],0)
	aDados[24]:=Round(aDados[24],0)	
	aDados[25]:=Round(aDados[25],0)
	aDados[26]:=Round(aDados[26],0)


	aAdd(aApur,{1,STR0012})//I. Vendas do período"
	aAdd(aApur,{0,STR0013,"20",aDados[01]})//"Vendas por exportação","20"
	aAdd(aApur,{0,STR0014,"21",aDados[02]})//"Vendas isentas e autorizadas sem imposto"
	aAdd(aApur,{0,STR0015,"22",aDados[03]})//"Vendas gravadas"
	aAdd(aApur,{0,Space(10)+STR0016,"",aDados[04]})//"Vendas afetadas pela tarifa geral (13%)"
	aAdd(aApur,{0,Space(10)+STR0017,"",aDados[05]})//"Vendas afetadas pela tarifa geral (10%)"
	aAdd(aApur,{0,Space(10)+STR0018,"",aDados[06]})//"Vendas afetadas pela tarifa geral (5%)"
	aAdd(aApur,{0,STR0019,"23",aDados[07]})//"Outros itens a incluir na base tributável"
	aAdd(aApur,{0,STR0020,"24",aDados[08]})//"Base tributável"
	aAdd(aApur,{1,STR0021})//"II. Compras e importações"
	aAdd(aApur,{0,STR0022,"25",aDados[09]})//"Importações isentas e autorizadas sem imposto"
	aAdd(aApur,{0,STR0023,"26",aDados[10]})//"Importações gravadas"
	aAdd(aApur,{0,STR0024,"27",aDados[11]})//"Compras e serviços isentos e autorizados sem impostos (Nacionais)"
	aAdd(aApur,{0,STR0025,"28",aDados[12]})//"Compras e serviços gravados (Nacionais)"
	aAdd(aApur,{1,STR0026})//"III. Determinação do imposto"
	aAdd(aApur,{0,STR0027,"29",aDados[13]})//"Impostos gerados por operações gravadas"
	aAdd(aApur,{0,STR0028,"30",aDados[14]})//"Credito por importações"
	aAdd(aApur,{0,STR0029,"31",aDados[15]})//"Credito por compras e serviços nacionais"
	aAdd(aApur,{0,STR0030,"32",aDados[16]})//"Total de creditos"
	aAdd(aApur,{0,STR0031,"33",aDados[17]})//"Imposto líquido do período"
	aAdd(aApur,{0,STR0032,"34",aDados[18]})//"Saldo a favor deste período"
	aAdd(aApur,{0,STR0033,"35",aDados[19]})//"Saldo a favor de períodos anteriores"
	aAdd(aApur,{0,STR0034,"37",aDados[20]})//"Subtotal do imposto"
	aAdd(aApur,{0,STR0035,"39",aDados[21]})//"Menos retenções pagas a conta"
	aAdd(aApur,{0,STR0036,"40",aDados[22]})//"Imposto do período"
	aAdd(aApur,{1,STR0037})//"IV. Liquidação da dívida fiscal"
	aAdd(aApur,{0,STR0038,"82",aDados[23]})//"Juros."
	aAdd(aApur,{0,STR0039,"83",aDados[24]})//"Total da dívida fiscal"
	aAdd(aApur,{0,STR0040,"84",aDados[25]})//"Solicito compensar com o crédito a meu favor pelo valor de:"
	aAdd(aApur,{1,""})//"Linha de separação"
	aAdd(aApur,{0,STR0041,"85",aDados[26]})//"Total da dívida a pagar"

Return aApur

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ DeclISC  ³ Autor ³ Ivan Haponczuk      ³ Data ³ 27.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega valores para a apuracao do ISC.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aFiliais - Array com as filiais selecionadas.              ³±±
±±³          ³ aApuAnt  - Array com os dados da apuracao anterior.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA040                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function DeclISC(aFiliais,aApuAnt)

	Local nI     := 0
	Local nSinal := 1
	Local cQry   := ""
	Local aApur  := {}
	Local aDados := {}
    
	For nI:=1 To 15
		aAdd(aDados,0)
	Next nI
	
	//Query
	cQry := " SELECT"
	cQry += "  SF3.F3_TIPOMOV AS MOV"
	cQry += " ,SF3.F3_ESPECIE AS ESPECIE"
	cQry += " ,SF3.F3_ESTADO AS PROV"
	cQry += " ,SFC.FC_CREDIMP AS CREDIMP"
	cQry += " ,SF3.F3_ALQIMP4 AS ALQIMP"
	cQry += " ,SUM(SF3.F3_BASIMP4) AS BASIMP"
	cQry += " ,SUM(SF3.F3_VALIMP4) AS VALIMP"
	cQry += " FROM "+RetSqlName("SF3")+" SF3"
	cQry += " INNER JOIN "+RetSqlName("SFC")+" SFC ON"
	cQry += " ("
	cQry += "  SFC.FC_FILIAL = '" + xFilial("SFC") + "'"
	cQry += "  AND SF3.F3_TES = SFC.FC_TES"
	cQry += "  AND SFC.D_E_L_E_T_ = ' '"
	cQry += "  AND SFC.FC_IMPOSTO = 'ISC'"
	cQry += " )"
	cQry += " WHERE SF3.D_E_L_E_T_ = ' '"
	cQry += " AND SF3.F3_EMISSAO LIKE '"+AllTrim(StrZero(MV_PAR02,4))+AllTrim(StrZero(MV_PAR01,2))+"%'"
	cQry += " AND SF3.F3_BASIMP4 > 0"
	cQry += " AND ( SF3.F3_FILIAL = '"+Space(TamSX3("F3_FILIAL")[1])+"'"
	For nI:=1 To Len(aFiliais)
		If aFiliais[nI,1]
			cQry += " OR SF3.F3_FILIAL = '"+aFiliais[nI,2]+"'"
		EndIf
	Next nI
	cQry += " )"
	cQry += " GROUP BY SF3.F3_TIPOMOV"
	cQry += " ,SF3.F3_ESPECIE"
	cQry += " ,SF3.F3_ESTADO"
	cQry += " ,SFC.FC_CREDIMP"
	cQry += " ,SF3.F3_ALQIMP4"
	
	TcQuery cQry New Alias "QRY"
	
	dbSelectArea("QRY")
	Do While QRY->(!EOF())
		If QRY->ESPECIE $ "NCC|NDE|NDI|NCP"
			nSinal := -1
		Else
			nSinal := 1
		EndIf
		If QRY->MOV == "V"
			If QRY->PROV $ "EX|08"
				aDados[01] += QRY->BASIMP * nSinal
			Else
				If QRY->ALQIMP == 0
					aDados[02] += QRY->BASIMP * nSinal
				Else
					aDados[03] += QRY->BASIMP * nSinal
					aDados[04] += QRY->VALIMP * nSinal
				EndIf
			EndIf
		Else
			If QRY->CREDIMP == "1"
				If QRY->PROV $ "EX|08"
					aDados[05] += QRY->VALIMP * nSinal
				Else
					aDados[06] += QRY->VALIMP * nSinal
				EndIf
			EndIf
		EndIf
		QRY->(dbSkip())
	EndDo	
	QRY->(dbCloseArea())
	
	aDados[07] := aDados[05] + aDados[06]
	If (aDados[04] - aDados[07]) > 0
		aDados[08] := aDados[04] - aDados[07]
	EndIf
	If (aDados[07] - aDados[04]) > 0
		aDados[09] := aDados[07] - aDados[04]
	EndIf
	If aDados[09] == 0
		If Len(aApuAnt) > 09
			aDados[10] := aApuAnt[09]
		Else
			aDados[10] := MV_PAR09
		EndIf
	EndIf
	If (aDados[08] - aDados[10]) > 0
		aDados[11] := aDados[08] - aDados[10]
	EndIf
	If aDados[11] >= MV_PAR10
		aDados[12] := MV_PAR10
	EndIf
	aDados[13] := aDados[11] - aDados[12]
	aDados[14] := MV_PAR11
	aDados[15] := aDados[13] + aDados[14]

	aDados[01]:=Round(aDados[01],0)
	aDados[02]:=Round(aDados[02],0)
	aDados[03]:=Round(aDados[03],0)
	aDados[04]:=Round(aDados[04],0)
	aDados[05]:=Round(aDados[05],0)
	aDados[06]:=Round(aDados[06],0)
	aDados[07]:=Round(aDados[07],0)
	aDados[08]:=Round(aDados[08],0)
	aDados[09]:=Round(aDados[09],0)
	aDados[10]:=Round(aDados[10],0)
	aDados[11]:=Round(aDados[11],0)
	aDados[12]:=Round(aDados[12],0)
	aDados[13]:=Round(aDados[13],0) 
	aDados[14]:=Round(aDados[14],0)
	aDados[15]:=Round(aDados[15],0)
	
	aAdd(aApur,{1,STR0042})//"I. Vendas do período"
	aAdd(aApur,{0,STR0043,"20",aDados[01]})//"Vendas por exportação"
	aAdd(aApur,{0,STR0044,"21",aDados[02]})//"Vendas isentas e autorizadas sem imposto"
	aAdd(aApur,{0,STR0045,"22",aDados[03]})//"Vendas gravadas"
	aAdd(aApur,{1,STR0046})//"II. Determinação do imposto"                                                                                  
	
	aAdd(aApur,{0,STR0047,"23",aDados[04]})//"Imposto seletivo ao consumo"
	aAdd(aApur,{0,STR0048,"24",aDados[05]})//"Credito por importações"
	aAdd(aApur,{0,STR0049,"25",aDados[06]})//"Credito por compras e serviços nacionais"
	aAdd(aApur,{0,STR0050,"26",aDados[07]})//"Total creditos"
	aAdd(aApur,{0,STR0051,"27",aDados[08]})//"Imposto líquido para o período"
	aAdd(aApur,{0,STR0052,"28",aDados[09]})//"Saldo a favor deste período"
	aAdd(aApur,{0,STR0053,"29",aDados[10]})//"Saldo a favor de períodos anteriores"
	aAdd(aApur,{0,STR0054,"31",aDados[11]})//"Imposto do período"
	aAdd(aApur,{1,STR0055})//"III. Liquidação dívida tributária"
	aAdd(aApur,{0,STR0056,"78",aDados[12]})//"Valor pendente de aprovação"
	aAdd(aApur,{0,STR0057,"79",aDados[13]})//"Imposto a pagar"
	aAdd(aApur,{0,STR0058,"82",aDados[14]})//"Juros"
	aAdd(aApur,{1,""})//"Linha de separação"
	aAdd(aApur,{0,STR0059,"83",aDados[15]})//"Total da dívida a pagar"

Return aApur

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AjustaSX1³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ajusta as perguntas usadas da SX1.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPerg - Nome do grupo de perguntas.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nulo                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Fiscal - FISA032                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg)
		
	PutSx1(cPerg,"01","Mes Apur. ?","¿Mes Apur ?","Month ?","MV_CH1","N",2,0,0,"G","","","","","MV_PAR01","","","","",;
	       "","","","","","","","","","","","",{"Informe o mes para apuracao"},{"Enter the month for calculation"},{"Introduzca el mes para el calculo"})
	  
	PutSx1(cPerg,"02","Ano Apur. ?","¿Ano Apur ?","Year ?","MV_CH2","N",4,0,0,"G","","","","","MV_PAR02","","","","",;
	       "","","","","","","","","","","","S",{"Informe o ano para apuracao"},{"Enter the year for calculation"},{"Introduzca el ano para el calculo"})
	       
	PutSx1(cPerg,"03","Sel Filiais ?","¿Sel Sucursales?","Sel Branches?","MV_CH3","N",1,0,0,"C","","","","","MV_PAR03","Sim","Si","Yes","",;
	       "Nao","No","No","","","","","","","","","",{"Seleciona filiais para a impressao"},{"Select branches to print"},{"Selecciona sucursales para la impresion"})
	       
	PutSx1(cPerg,"04","Data Titulo ?","¿Fecha del titulo ?","Date Title?","MV_CH4","D",8,0,0,"G","","","","","MV_PAR04","","","","",;
	       "","","","","","","","","","","","",{"Data de vencimento do titulo"},{"The expiration date of title"},{"Fecha de plazo del titulo"})
       
	PutSx1(cPerg,"05","Gera Titulo ?","¿Genera Titulo?","Generates Title?","MV_CH5","N",1,0,0,"C","","","","","MV_PAR05","Sim","Si","Yes","",;
	       "Nao","No","No","","","","","","","","","",{"Informe se deve ser gerado um titulo no financeiro"},{"Generate a title on the financial"},{"Informe si debe generar un titulo","en Financiero"})
	
	PutSx1(cPerg,"06","Diretorio ?","¿Directorio?","Directory?","MV_CH6","G",40,0,0,"G","","","","","MV_PAR06","","","","",;
	       "","","","","","","","","","","","",{"Diretorio dos arquivos de apuracao"},{"Directory files determination"},{"Directorio de los archivos del calculo"})
	       
	PutSx1(cPerg,"07","Arq. Per. Ant. ?","¿Arch. Per. Ant. ?","Arch. Per. Prv. ?","MV_CH7","G",25,0,0,"C","","","","","MV_PAR07","","","","",;
	       "","","","","","","","","","","","",{"Arquivo de apuracao do periodo anterior"},{"File verification of the earlier period"},{"Archivo del calculo del periodo anterior"})
	       
	PutSx1(cPerg,"08","Arq. de destino ?","¿Arch de destino ?","Arch. target?","MV_CH8","G",25,0,0,"C","","","","","MV_PAR08","","","","",;
	       "","","","","","","","","","","","",{"Arquivo destino da apuracao"},{"Determination of the target file"},{"Archivo destino del calculo"})
	       
	If nF032Apur == 1

		PutSx1(cPerg,"09","Incl. Bas. Trib.?","¿Incl. Bas. Imp.?","Incl. Bas. Trib.?","MV_CH9","N",9,0,0,"G","","","","","MV_PAR09","","","","",;
	       "","","","","","","","","","","","",{"Outros itens a incluir na base tributável."},{"Other items to include in the tax base."},{"Otros rubros a incluir em la base","imponible."})
	       
		PutSx1(cPerg,"10","Saldo Ant. Comp ?","¿Saldo Ant. Comp ?","Balance Prev. Comp?","MV_CHA","N",9,0,0,"G","","","","","MV_PAR10","","","","",;
		       "","","","","","","","","","","","",{"Saldo disponível de pagamentos do período anterior a compensar."},{"Balance of payments available to offset the previous period."},{"Saldo disponible de pagos del periodo","anteriror o compensar"})
	       
		PutSx1(cPerg,"11","Ret. Pagas Cont.?","¿Ret. Pago Cuenta?","Ded. Paid acc.?","MV_CHB","N",9,0,0,"G","","","","","MV_PAR11","","","","",;
	       "","","","","","","","","","","","",{"Menos retenções pagas a conta."},{"Less deductions paid the bill."},{"Menos retenciones pago a cuenta."})
	  
		PutSx1(cPerg,"12","Juros.?","¿Intereses?","Interest?","MV_CHC","N",9,0,0,"G","","","","","MV_PAR12","","","","",;
	       "","","","","","","","","","","","",{"Juros."},{"Interest."},{"Intereses."})
	       
		PutSx1(cPerg,"13","Cred. Fav.?","¿Cred. Fav.?","Cred. To.?","MV_CHD","N",9,0,0,"G","","","","","MV_PAR13","","","","",;
	       "","","","","","","","","","","","",{"Valor a compensar com o crédito a meu favor."},{"Value to compensate for the credit in my favor."},{"Valor a compensar con crédito a mi favor."})
       
	Else

		PutSx1(cPerg,"09","Saldo Ant. Comp ?","¿Saldo Ant. Comp ?","Balance Prev. Comp?","MV_CH9","N",9,0,0,"G","","","","","MV_PAR09","","","","",;
		       "","","","","","","","","","","","",{"Saldo disponível de pagamentos do período anterior a compensar."},{"Balance of payments available to offset the previous period."},{"Saldo disponible de pagos del periodo","anteriror o compensar"})
		       
		PutSx1(cPerg,"10","Val. Pen. Apr. ?","¿Monto Pen. Apr.?","Amount pen. app.?","MV_CHA","N",9,0,0,"G","","","","","MV_PAR10","","","","",;
		       "","","","","","","","","","","","",{"Valor pendente de aprovação."},{"Amount pending approval."},{"Monto pendiente de aprobacion."})
		       
		PutSx1(cPerg,"11","Juros ?","¿Intereses ?","Interest?","MV_CHB","N",9,0,0,"G","","","","","MV_PAR11","","","","",;
		       "","","","","","","","","","","","",{"Juros."},{"Interest."},{"Intereses."})

	EndIf
	       
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ImpRel   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 06.10.2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Imprime apuracao.                                          ³±±
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
Static Function ImpRel(cTitulo,aApur)

	Local nI     := 0
	Local nLin   := 0
	Local nTam   := 0
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
	oPrint:Say(nLin,0050,STR0060,oFont1)//"Declaracao Mensal"
	
	oPrint:Box(nLin,1900,0280,2355)
	oPrint:Say(nLin+20,1920,STR0061,oFont1)//"Periodo"
	
	nLin += 80
	oPrint:Box(nLin,0020,nLin+80,0450)
	oPrint:Say(nLin+20,0040,STR0062,oFont1)//"Cédula"
	oPrint:Box(nLin,0450,nLin+80,1900)
	oPrint:Say(nLin+20,0470,STR0063,oFont1)//"Razao social"
	oPrint:Box(nLin,1900,nLin+80,2100)
	oPrint:Say(nLin+20,1920,STR0064,oFont2)//"Mes"
	oPrint:Box(nLin,2100,nLin+80,2355)
	oPrint:Say(nLin+20,2120,STR0065,oFont2)//"Ano"
	          	
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
	
	For nI:=1 To Len(aApur)	
		
		nLin += 80
		nLin := FMudaPag(nLin)
		
		If aApur[nI,1] == 1	
		
			oPrint:Box(nLin,0020,nLin+80,2355)
			oPrint:Say(nLin+20,0040,aApur[nI,2],oFont2)
			
		Else
		
			aTexto := QbrLin(aApur[nI,2],85)
	
			nTam := 80
			If Len(aApur[nI,2]) > 85
				oPrint:Say(nLin+70,0040,aTexto[2],oFont1)
				nTam := 130
			EndIf
		
			oPrint:Box(nLin,0020,nLin+nTam,2355)
			oPrint:Say(nLin+20,0040,aTexto[1],oFont1)
			
			If !Empty(aApur[nI,3])
				oPrint:Box(nLin,1750,nLin+nTam,1900)
				oPrint:Say(nLin+20,1770,aApur[nI,3],oFont1)
			EndIf
			oPrint:Box(nLin,1900,nLin+nTam,2355)
			oPrint:Say(nLin+20,2000,AliDir(aApur[nI,4]),oFont1)
			
			If Len(aApur[nI,2]) > 85
				nLin += 50
			EndIf
			
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
±±³Funcao    ³ AliDir   ³ Autor ³ Ivan Haponczuk      ³ Data ³ 25.10.2011 ³±±
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

	Local cRet  := ""
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
		Alert(STR0066)//"Erro na abertura do arquivo"
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
			cApur := "ISC"
	EndCase
	
	nHdl := fCreate(cDir+cArq)
	If nHdl <= 0
		ApMsgStop(STR0067)//"Ocorreu um erro ao criar o arquivo."
	Endif  
	
	cLinha := cApur
	For nlX := 1 to Len(aDados)
		If Len(aDados[nlX]) > 3
			cLinha += ";"+AllTrim(Str(aDados[nlX,4]))
		EndIf
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
			cApur := "ISC"
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
