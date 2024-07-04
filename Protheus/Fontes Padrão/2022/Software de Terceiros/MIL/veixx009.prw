// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 07     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#Include "VEIXX009.CH"

/*/{Protheus.doc} mil_ver()
    Versao do fonte modelo novo

    @author Andre Luis Almeida
    @since  25/10/2017
/*/
Static Function mil_ver()
	If .F.
		mil_ver()
	EndIf
Return "007322_1"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX009 º Autor ³ Andre Luis Almeida º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Financiamento Proprio                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc (2-Visualizar/4-Alterar/3-Incluir)                    º±±
±±º          ³ aParPro (Parametros do Financiamento Proprio)              º±±
±±º			 ³	 aParPro[01] = Nro do Atendimento                         º±±
±±º			 ³	 aParPro[02] = Valor do Financimento                      º±±
±±º			 ³	 aParPro[03] = Data Inicial                               º±±
±±º			 ³	 aParPro[04] = Dias para 1a.Parcela                       º±±
±±º			 ³	 aParPro[05] = Qtde de Parcelas                           º±±
±±º			 ³	 aParPro[06] = Intervalo entre as parcelas                º±±
±±º			 ³	 aParPro[07] = Fixa Dia                                   º±±
±±º			 ³	 aParPro[08] = Dia Fixo                                   º±±
±±º			 ³	 aParPro[09] = Juros Mensal                               º±±
±±º			 ³	 aParPro[10] = Meses a considerar                         º±±
±±º          ³ aVS9 (Pagamentos)                                          º±±
±±º			 ³	 aVS9[1] aHeader VS9                                      º±±
±±º          ³   aVS9[2] aCols VS9                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX009(nOpc,aParPro,aVS9)
Local aObjects    := {} , aPos := {} , aInfo := {} 
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lRet        := .f.
Local nCntFor     := 1
Local nj          := 0
Local ni          := 0
Local nPos        := 0
Local nVlPro      := aParPro[02]
Local dDtIni      := aParPro[03]
Local nDia1P      := aParPro[04]
Local nQtdPc      := aParPro[05]
Local nIntPc      := aParPro[06]
Local cComboFD    := aParPro[07]
Local aComboFD    := X3CBOXAVET("VV0_FIXFPR","")
Local nDiaFx      := aParPro[08]
Local nJuros      := aParPro[09]
Local lParcL      := .f.
Local nOpcao      := 0
Local lDblClick   := .f.
Local cTpFinPro   := FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='2' AND VSA.D_E_L_E_T_=' '") // VSA_TIPO='2' ( Financiamento Proprio )
Local aParcTot    := {}
Private aParcPro  := {}
Private aMeses    := {.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.,.t.}
Private aHeaderVS9:= aClone(aVS9[1])
///// SALVA OS PARAMETROS /////
Private nAVlPro   := aParPro[02]
Private dADtIni   := aParPro[03]
Private nADia1P   := aParPro[04]
Private nAQtdPc   := aParPro[05]
Private nAIntPc   := aParPro[06]
Private cAComboFD := aParPro[07]
Private nADiaFx   := aParPro[08]
Private nAJuros   := aParPro[09]
///////////////////////////////
If len(aParPro) == 9
	aAdd(aParPro,"1111111111111") // aParPro[10] // Meses a considerar
ElseIf Empty(aParPro[10])
	aParPro[10] := "1111111111111"
EndIf
For nj := 1 to 13
	aMeses[nj] := ( substr(aParPro[10],nj,1) == "1" ) // Jan / Fev / Mar / Abr / Mai / Jun / Jul / Ago / Set / Out / Nov / Dez / Todos
Next
If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
	lDblClick := .t.
	If Empty(cTpFinPro)
		MsgStop(STR0005,STR0004) // Impossivel continuar! Nao existe Tipo de Pagamento relacionado a Financiamento Proprio. / Atencao
		Return lRet
	EndIf
EndIf
// Fator de reducao 80%
For nCntFor := 1 to Len(aSizeHalf)
	aSizeHalf[nCntFor] := INT(aSizeHalf[nCntFor] * 0.8)
Next   
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Financiamento Proprio 
aPos := MsObjSize( aInfo, aObjects )
For ni := 1 to len(aVS9[2]) // Selecionar o Financiamento Proprio ja utilizado neste Atendimento
	If !aVS9[2,ni,len(aVS9[2,ni])]
		If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpFinPro
			aAdd(aParcPro,{aVS9[2,ni,FG_POSVAR("VS9_DATPAG","aHeaderVS9")],aVS9[2,ni,FG_POSVAR("VS9_VALPAG","aHeaderVS9")],ni})
			aAdd(aParcTot,ni) // Linhas do aCols do VS9
		EndIf
	EndIf
Next
If len(aParcPro) <= 0
	aAdd(aParcPro,{dDataBase,0,0})
Else
	If aParcPro[1,2] == aParcPro[len(aParcPro),2] // Marcar como Parcela Linear
		lParcL := .t.
	EndIf
EndIf
If nDiaFx == 0
	nDiaFx := day(dDataBase)
EndIf
DEFINE MSDIALOG oTelaFin TITLE STR0001 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Financiamento Proprio
	oTelaFin:lEscClose := .F.
	//
	@ aPos[1,1]+004,aPos[1,2]+143 LISTBOX oLboxPro FIELDS HEADER STR0002,STR0003 COLSIZES 100,80 SIZE aPos[1,4]-145,aPos[1,3]-aPos[1,1]-004 OF oTelaFin PIXEL ON DBLCLICK FS_DBLCLICK(nOpc)
	// Data / Valor Parcela
	oLboxPro:SetArray(aParcPro)
	oLboxPro:bLine := { || { Transform(aParcPro[oLboxPro:nAt,1],"@D")+" - "+FG_CDOW(aParcPro[oLboxPro:nAt,1]) , FG_AlinVlrs(Transform(aParcPro[oLboxPro:nAt,02],"@E 999,999.99")) }}
	@ aPos[1,1]+004,aPos[1,2] TO aPos[1,3]+002,aPos[1,2]+140 LABEL "" OF oTelaFin PIXEL 
	@ aPos[1,1]+010,aPos[1,2]+008 SAY STR0006 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Valor
	@ aPos[1,1]+009,aPos[1,2]+086 MSGET oVlPro VAR nVlPro PICTURE "@E 99,999,999.99" VALID ( nVlPro >= 0 .and. FS_CALCFIN(nVlPro,dDtIni,nDia1P,nQtdPc,nIntPc,cComboFD,nDiaFx,nJuros,lParcL,aMeses)) SIZE 45,8 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
	@ aPos[1,1]+023,aPos[1,2]+008 SAY STR0007 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Data Inicial
	@ aPos[1,1]+022,aPos[1,2]+086 MSGET oDtIni VAR dDtIni PICTURE "@D" VALID !Empty(dDtIni) SIZE 45,8 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
	@ aPos[1,1]+036,aPos[1,2]+008 SAY STR0008 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Qtd. de dias para 1a.Parcela
	@ aPos[1,1]+035,aPos[1,2]+086 MSGET oDia1P VAR nDia1P PICTURE "@E 9999" VALID ( nDia1P >= 0 ) SIZE 45,8 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
	@ aPos[1,1]+049,aPos[1,2]+008 SAY STR0009 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Qtd. de Parcelas
	@ aPos[1,1]+048,aPos[1,2]+086 MSGET oQtdPc VAR nQtdPc PICTURE "@E 9999" VALID ( nQtdPc > 0 ) SIZE 45,8 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
	@ aPos[1,1]+062,aPos[1,2]+008 SAY STR0010 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Intervalo entre as Parcelas
	@ aPos[1,1]+061,aPos[1,2]+086 MSGET oIntPc VAR nIntPc PICTURE "@E 9999" VALID ( nIntPc > 0 .or. ( nIntPc == 0 .and. nQtdPc == 1 ) ) SIZE 45,8 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN ( cComboFD == "0" .and. ( nOpc == 3 .or. nOpc == 4 ) )
	@ aPos[1,1]+075,aPos[1,2]+008 SAY STR0011 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE //Fixa Dia
	@ aPos[1,1]+074,aPos[1,2]+086 MSCOMBOBOX oComboFD VAR cComboFD SIZE 45,08 VALID IIf(cComboFD=="1",(nIntPc:=30),.t.) ITEMS aComboFD OF oTelaFin PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
	@ aPos[1,1]+088,aPos[1,2]+008 SAY STR0012 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE //Dia Fixo
	@ aPos[1,1]+087,aPos[1,2]+086 MSGET oDiaFx VAR nDiaFx PICTURE "@E 99" VALID ( nDiaFx > 0 .and. nDiaFx < 32 ) SIZE 45,8 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN ( cComboFD == "1" .and. ( nOpc == 3 .or. nOpc == 4 ) )
	@ aPos[1,1]+101,aPos[1,2]+008 SAY STR0013 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE //Juros Mensal
	@ aPos[1,1]+100,aPos[1,2]+086 MSGET oJuros VAR nJuros PICTURE "@E 9999.999999" VALID ( nJuros >= 0 ) SIZE 45,8 OF oTelaFin PIXEL COLOR CLR_BLACK WHEN (nOpc == 3 .or. nOpc == 4 )
	//
	@ aPos[1,1]+175,aPos[1,2]+045 BUTTON oCalcular PROMPT STR0015 OF oTelaFin SIZE 50,10 PIXEL ACTION FS_CALCFIN(nVlPro,dDtIni,nDia1P,nQtdPc,nIntPc,cComboFD,nDiaFx,nJuros,lParcL,aMeses) WHEN (nOpc == 3 .or. nOpc == 4 ) // Calcular
	//
	@ aPos[1,1]+115,aPos[1,2]+008 CHECKBOX oCheck VAR lParcL PROMPT STR0014 OF oTelaFin SIZE 145,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 )
    //
	@ aPos[1,1]+130,aPos[1,2]+008 SAY STR0019 SIZE 100,8 OF oTelaFin PIXEL COLOR CLR_BLUE // Meses a considerar
	@ aPos[1,1]+130,aPos[1,2]+062 BUTTON oMeses PROMPT STR0020 OF oTelaFin SIZE 68,08 PIXEL ACTION (aMeses[13]:=!aMeses[13],FS_AMESES(aMeses)) WHEN (nOpc == 3 .or. nOpc == 4 ) // marcar todos meses
	If aMeses[13]
		oMeses:cCaption := STR0021 // desmarcar todos meses
		oMeses:Refresh()
	EndIf
	@ aPos[1,1]+141,aPos[1,2]+008 CHECKBOX oMes01 VAR aMeses[01] PROMPT STR0023 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Jan
	@ aPos[1,1]+150,aPos[1,2]+008 CHECKBOX oMes02 VAR aMeses[02] PROMPT STR0024 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Fev
	@ aPos[1,1]+159,aPos[1,2]+008 CHECKBOX oMes03 VAR aMeses[03] PROMPT STR0025 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Mar
    //
	@ aPos[1,1]+141,aPos[1,2]+039 CHECKBOX oMes04 VAR aMeses[04] PROMPT STR0026 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Abr
	@ aPos[1,1]+150,aPos[1,2]+039 CHECKBOX oMes05 VAR aMeses[05] PROMPT STR0027 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Mai
	@ aPos[1,1]+159,aPos[1,2]+039 CHECKBOX oMes06 VAR aMeses[06] PROMPT STR0028 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Jun
	//
	@ aPos[1,1]+141,aPos[1,2]+070 CHECKBOX oMes07 VAR aMeses[07] PROMPT STR0029 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Jul
	@ aPos[1,1]+150,aPos[1,2]+070 CHECKBOX oMes08 VAR aMeses[08] PROMPT STR0030 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Ago
	@ aPos[1,1]+159,aPos[1,2]+070 CHECKBOX oMes09 VAR aMeses[09] PROMPT STR0031 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Set
    //
	@ aPos[1,1]+141,aPos[1,2]+101 CHECKBOX oMes10 VAR aMeses[10] PROMPT STR0032 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Out
	@ aPos[1,1]+150,aPos[1,2]+101 CHECKBOX oMes11 VAR aMeses[11] PROMPT STR0033 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Nov
	@ aPos[1,1]+159,aPos[1,2]+101 CHECKBOX oMes12 VAR aMeses[12] PROMPT STR0034 OF oTelaFin SIZE 30,08 PIXEL COLOR CLR_BLUE WHEN (nOpc == 3 .or. nOpc == 4 ) // Dez
    //
ACTIVATE MSDIALOG oTelaFin CENTER ON INIT (EnchoiceBar(oTelaFin,{|| IIf(FS_TUDOOK(nOpc),(nOpcao:=1,oTelaFin:End()),.t.)},{ || oTelaFin:End()},,))

If nOpcao == 1 // OK Tela
	If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
		lRet := .t.
		aParPro[02] := 0
		aParPro[03] := ctod("")
		aParPro[04] := 0
		aParPro[05] := 0
		aParPro[06] := 0
		aParPro[07] := "0"
		aParPro[08] := 0
		aParPro[09] := 0
		aParPro[10] := "1111111111111"
		For ni := 1 to len(aParcTot) // Exclui todos os registros da aCols do VS9 ( Financiamento Proprio )
			nPos := aParcTot[ni]
			aVS9[2,nPos,len(aVS9[2,nPos])] := .t.
		Next
		If nVlPro > 0 // Incluir Financiamento se o Valor > 0
			For ni := 1 to len(aParcPro) // Atualiza aCols do VS9
				If aParcPro[ni,2] > 0
					aParPro[02] := nAVlPro   // Valor do Financiamento Proprio
					aParPro[03] := dADtIni   // Data Incial 
					aParPro[04] := nADia1P   // Dia da 1a. Parcela
					aParPro[05] := nAQtdPc   // Qtde de Parcelas
					aParPro[06] := nAIntPc   // Intervalo
					aParPro[07] := cAComboFD // Fixa Dia
					aParPro[08] := nADiaFx   // Dia Fixo
					aParPro[09] := nAJuros   // Juros Mensal
					aParPro[10] := ""        // Meses a considerar
					For nj := 1 to 13
						aParPro[10] += IIf(aMeses[nj],"1","0") // Jan / Fev / Mar / Abr / Mai / Jun / Jul / Ago / Set / Out / Nov / Dez / Todos
					Next
		  			If aParcPro[ni,3] > 0 // Reutiliza registro do VS9
						nPos := aParcPro[ni,3]
		    		Else // Inclui na aCols do VS9
		            	aAdd(aVS9[2],Array(len(aVS9[1])+1)) 
		            	nPos := len(aVS9[2])
		    		EndIf
					aVS9[2,nPos,FG_POSVAR("VS9_NUMIDE","aHeaderVS9")] := PadR(aParPro[1],aVS9[1,FG_POSVAR("VS9_NUMIDE","aHeaderVS9"),4]," ") // Nro do Atendimento
					aVS9[2,nPos,FG_POSVAR("VS9_TIPOPE","aHeaderVS9")] := "V" // Veiculos
					aVS9[2,nPos,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] := cTpFinPro
					aVS9[2,nPos,FG_POSVAR("VS9_DATPAG","aHeaderVS9")] := aParcPro[ni,1]
					aVS9[2,nPos,FG_POSVAR("VS9_VALPAG","aHeaderVS9")] := aParcPro[ni,2]
					aVS9[2,nPos,FG_POSVAR("VS9_REFPAG","aHeaderVS9")] := strzero(ni,4)+" / "+strzero(len(aParcPro),4)
					aVS9[2,nPos,len(aVS9[2,nPos])] := .f.
				EndIf
			Next
			nPos := 0
			For ni := 1 to len(aVS9[2]) // Atualizar na aCols do VS9 o VS9_SEQUEN dos Veiculos (Avaliacoes de Veiculos)
				If !aVS9[2,ni,len(aVS9[2,ni])]
					If aVS9[2,ni,FG_POSVAR("VS9_TIPPAG","aHeaderVS9")] == cTpFinPro
						nPos++
						aVS9[2,ni,FG_POSVAR("VS9_SEQUEN","aHeaderVS9")] := strzero(nPos,2)
					EndIf
				EndIf
			Next
		EndIf
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TUDOOK ³ Autor ³ Andre Luis Almeida   ³ Data ³ 28/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ DuploClick no ListBox das Parcelas do Financiamento Proprio³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DBLCLICK(nOpc)
Local aParcAux := {}
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	If ( ExistBlock("VXX09DLB") )// Altera Parcelas do Financiamento Proprio (aParcPro)
		aParcAux := ExecBlock("VXX09DLB",.F.,.F.,{aParcPro,oLboxPro:nAt}) // { Data Vencimento , Valor Parcela , Posiciao no aCols do VS9 }
		If ( ValType(aParcAux) == "A" )
			aParcPro := aClone(aParcAux)
			If len(aParcPro) <= 0
				aAdd(aParcPro,{dDataBase,0,0})
			EndIf
		EndIf
	EndIf
	If len(aParcPro) < oLboxPro:nAt
		oLboxPro:nAt := 1
	EndIf
	oLboxPro:SetArray(aParcPro)
	oLboxPro:bLine := { || { Transform(aParcPro[oLboxPro:nAt,1],"@D")+" - "+FG_CDOW(aParcPro[oLboxPro:nAt,1]) , FG_AlinVlrs(Transform(aParcPro[oLboxPro:nAt,02],"@E 999,999.99")) }}
	oLboxPro:Refresh()
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TUDOOK ³ Autor ³ Andre Luis Almeida   ³ Data ³ 28/03/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tudo OK da Tela de Financiamento Proprio                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TUDOOK(nOpc)
Local lRet := .t.
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	If ( ExistBlock("VXX09TOK") ) // PE para validar o Tudo OK da Tela de Financiamento Proprio
		lRet := ExecBlock("VXX09TOK",.F.,.F.,{aParcPro})
	EndIf
EndIf
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_AMESES ³ Autor ³ Andre Luis Almeida   ³ Data ³ 06/06/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Seleciona todos o meses a considerar                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AMESES(aMeses)
Local ni := 0
For ni := 1 to 12
	aMeses[ni] := aMeses[13]
Next
If aMeses[13]
	oMeses:cCaption := STR0021 // desmarcar todos meses
Else
	oMeses:cCaption := STR0020 // marcar todos meses
EndIf
oMeses:Refresh()
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_CALCFIN³ Autor³Manoel / Andre Luis Almeida³ Data³06/04/10³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Calcula o Financiamento Proprio                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_CALCFIN(nVlPro,dDtIni,nDia1P,nQtdPc,nIntPc,cComboFD,nDiaFx,nJuros,lParcL,aMeses)
Local ni       := 0
Local cont     := 0
Local cDia     := ""
Local nAno     := 0
Local nMes     := 0
Local cMesAno  := ""
Local nExp     := 0
Local nJurMes  := 0
Local nCoef    := 0
Local nCoefic  := 0
Local nTotal   := 0
Local nTotAnt  := 0
Local dDtAux   := dDtIni+nDia1P
Local nDtVal   := 0
Local dDtVal   := cTod("")
Local aParcAux := aClone(aParcPro)
Local lOk      := .f.
If ( dDtIni+nDia1P ) < dDataBase
	MsgStop(STR0016+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0017+": "+Transform(dDtIni+nDia1P,"@D")+CHR(13)+CHR(10)+STR0018+": "+Transform(dDataBase,"@D"),STR0004) // Impossivel gerar parcela anterior a data atual! / Data 1a.parcela / Data atual / Atencao
	Return(.t.)
EndIf
For cont := 1 to 12
	If aMeses[cont]
    	lOk := .t.
	EndIf
Next
If !lOk
	MsgStop(STR0022,STR0004) // Necessario selecionar os meses a considerar! / Atencao
	Return(.t.)
EndIf
aParcPro := {}
cMesAno  := ""
cDia     := strzero(nDiaFx,2)
nAno     := 0
If cComboFD == "1" // Fixa dia 
	If cDia < strzero(day(dDtAux),2) // dia fixo eh menor que a 1a. parcela
		If Month(dDtAux)+1 > 12
			cMesAno := "01/"+right(strzero(Year(dDtAux)+1,4),2)
		Else
			cMesAno := strzero(Month(dDtAux)+1,2)+"/"+right(strzero(Year(dDtAux),4),2)
		EndIf
		dDtAux := ctod(strzero(day(dDtAux),2)+"/"+cMesAno)
	EndIf
EndIf
cMesAno  := ""
For cont := 1 to nQtdPc
	If aMeses[month(dDtAux)]
		If cComboFD == "1"
			nMes := Month(dDtAux)
			nAno := Year(dDtAux)
			If cMesAno == strzero(nMes,2)+strzero(nAno,4)
				For ni := 1 to 12
					nMes++
					If nMes >= 13
						nMes := 1
						nAno++
					EndIf
					If aMeses[nMes]
						nDtVal := 0
						dDtVal := ctod(cDia+"/"+strzero(nMes,2)+"/"+Substr(Str(nAno,4),3,2))
						While Empty(dDtVal)
							nDtVal++
							dDtVal := ctod(strzero(val(cDia)-nDtVal,2)+"/"+strzero(nMes,2)+"/"+Substr(Str(nAno,4),3,2))
							If nDtVal >= 10
								Exit
							EndIf
						EndDo
						aAdd(aParcPro,{dDtVal,(nVlPro/nQtdPc),0})
						Exit
					EndIf
				Next
			Else
				nDtVal := 0
				dDtVal := ctod(cDia+right(left(Transform(dDtAux,"@D"),6),4)+Substr(Str(Year(dDtAux),4),3,2))
				While Empty(dDtVal)
					nDtVal++
					dDtVal := ctod(strzero(val(cDia)-nDtVal,2)+right(left(Transform(dDtAux,"@D"),6),4)+Substr(Str(Year(dDtAux),4),3,2))
					If nDtVal >= 10
						Exit
					EndIf
				EndDo
				aAdd(aParcPro,{dDtVal,(nVlPro/nQtdPc),0})
			EndIf
			cMesAno := strzero(nMes,2)+strzero(nAno,4)
		Else
			aAdd(aParcPro,{dDtAux,(nVlPro/nQtdPc),0})
		EndIf
	Else
		cont--
	EndIf
	If cComboFD == "1" // Fixa dia 
		If Month(dDtAux)+1 > 12
			dDtAux := ctod("01/01/"+right(strzero(Year(dDtAux)+1,4),2))
		Else
			dDtAux := ctod("01/"+strzero(Month(dDtAux)+1,2)+"/"+right(strzero(Year(dDtAux),4),2))
		EndIf
	Else
		dDtAux += nIntPc
	EndIf
Next
For cont := 1 to Len(aParcPro)
	aParcPro[cont,2] := round( aParcPro[cont,2] , 2 )
Next
If nJuros > 0                  
	If lParcL // Valores das Parcelas Lineares (SIM)
		nCoef    := (nJuros/30)*nIntPc
		nCoefic  := 1+(nCoef/100)
		nParcAnt := aParcPro[1,2]
		nTotal   := 0     
		For cont := 1 to Len(aParcPro)              
			nExp := (aParcPro[cont,1]-dDatabase)/30
			if nExp <= 0
			   nJurMes := 1
			Else
			   nJurMes := nCoefic**nExp
			Endif
			aParcPro[cont,2] := aParcPro[cont,2] * nJurmes
			nTotal += aParcPro[cont,2]
		Next            
		For cont := 1 to Len(aParcPro)              
			aParcPro[cont,2] := ( nTotal / Len(aParcPro) )
		Next            
	Else // Valores das Parcelas Lineares (NAO)
		nCoef    := (nJuros/30)*nIntPc
		nCoefic  := 1+(nCoef/100)
		nParcAnt := aParcPro[1,2]
		For cont := 1 to Len(aParcPro)
			nExp := (aParcPro[cont,1]-dDatabase)/30
			if nExp <= 0
			   nJurMes := 1
			Else
			   nJurMes := nCoefic**nExp
			Endif
			aParcPro[cont,2] := ( aParcPro[cont,2] * nJurMes )
		Next            
	Endif				
Else
	nTotal := 0
	If len(aParcPro) > 0
		For cont := 1 to Len(aParcPro)
			nTotal += aParcPro[cont,2]
		Next
		If nTotal > nVlPro
			aParcPro[len(aParcPro),2] -= ( nTotal - nVlPro )
		ElseIf nTotal < nVlPro
			aParcPro[len(aParcPro),2] += ( nVlPro - nTotal )
		EndIf
	EndIf
EndIf
For cont := 1 to len(aParcPro) // Reutilizar o mesmo VS9
	If len(aParcAux) >= cont
		aParcPro[cont,3] := aParcAux[cont,3] // linha do aCols do VS9
	EndIf
Next
If ( ExistBlock("VM011PFIN") )// Altera Parcelas do Financiamento Proprio (aParcPro)
	aParcAux := ExecBlock("VM011PFIN",.F.,.F.,{aParcPro}) // { Data Vencimento , Valor Parcela , Posiciao no aCols do VS9 }
	If ( ValType(aParcAux) == "A" )
		aParcPro := aClone(aParcAux)
	EndIf
EndIf
If len(aParcPro) <= 0
	aAdd(aParcPro,{dDataBase,0,0})
EndIf
nAVlPro   := nVlPro
dADtIni   := dDtIni
nADia1P   := nDia1P
nAQtdPc   := nQtdPc
nAIntPc   := nIntPc
cAComboFD := cComboFD
nADiaFx   := nDiaFx
nAJuros   := nAJuros
oLboxPro:nAt := 1
oLboxPro:SetArray(aParcPro)
oLboxPro:bLine := { || { Transform(aParcPro[oLboxPro:nAt,1],"@D")+" - "+FG_CDOW(aParcPro[oLboxPro:nAt,1]) , FG_AlinVlrs(Transform(aParcPro[oLboxPro:nAt,02],"@E 999,999.99")) }}
oLboxPro:Refresh()
Return(.t.)