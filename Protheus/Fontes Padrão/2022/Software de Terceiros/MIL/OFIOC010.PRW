#INCLUDE "OFIOC010.CH"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OFIOC010  ³ Autor ³ Paulo Boschetti       ³ Data ³ 18/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Consulta do Kardex                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Patricia Sal³03/08/00³PROTHE³ Revisao Geral do Programa            .   ³±±
±±³Fernando M. ³23.08.00³xxxxxx³ Mostrar fatura ao classificar guia(Loc.  ³±±
±±³            ³        ³      ³ Chile) e ajuste de tela                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIOC010


PRIVATE cTRBSD1 := CriaTrab(,.f.)
PRIVATE cTRBSD2 := Subs(cTRBSD1,1,7)+"A"
PRIVATE cTRBSD3 := Subs(cTRBSD1,1,7)+"B"
PRIVATE cPictQT := PesqPict("SB2","B2_QATU",15) 
PRIVATE aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utiliza custo unificado por empresa              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE lCusUnif := IIF(GetNewPar("MV_CUSFIL","E")=="E",.t.,.f.) // Identifica qdo utiliza custo por empresa

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta perguntas no SX1 a fim de preparar o relatorio p/     ³
//³ custo unificado por empresa                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCusUnif
	C10MTC030CUnf()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera o desenho padrao de atualizacoes                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCadastro := OemtoAnsi(STR0003)	//"Consulta ao Kardex"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F12 para acessar os parametros                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AADD(aRegistros,{"MTC030","08","Lista Transf Locali?" ,"Lista Transf Locali?" ,"Lista Transf Locali?" ,"mv_ch8","N",1,0,1,"C"," ","mv_par08","Sim","Si","Yes"," "," ","Nao","No","No"})	
SetKey( VK_F12,{ || pergunte("MTC030",.T.) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        // Data inicial                              ³
//³ mv_par02        // Data final                                ³
//³ mv_par03        // Qual Almoxarifado                         ³
//³ mv_par04        // Saldo item a item : Sim / Nao             ³
//³ mv_par05        // Qual Moeda ? 1 2 3 4 5
//³ mv_par06        // Imprime Localizacao: Sim / Nao            ³
//³ mv_par07        // Sequencia Impressao : Digitacao / Calculo ³
//³ mv_par08         // Lista Transf Locali (Sim/Nao)            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !(Pergunte("MTC030",.T.))
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse( 6, 1,22,75,"SB1")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desativa tecla F12                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Set Key VK_F12 To

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Ordem Original do arquivo principal               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SB1")
DbSetOrder(1)
DbSelectArea("SD1")
DbSetOrder(1)
DbSelectArea("SD2")
DbSetOrder(1)
DbSelectArea("SD3")
DbSetOrder(1)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C10Mc030Con ³ Autor ³ Paulo Boschetti       ³ Data ³ 18/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que monta o arquivo de trabalho com as   ³±±
±±³          ³ movimentacoes e mostra-o na tela                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C10Mc030Con

LOCAL aSalTel := {} ,nCusMed := 0 ,aSalIni := {}
PRIVATE aTrbP := {}
PRIVATE aTela := {}
PRIVATE aSalAtu  := { 0,0,0,0,0,0,0 }
PRIVATE cPictTotQT:=PesqPict("SB2","B2_QATU",15)
PRIVATE nTotSda := nTotEnt :=  nTotvSda := nTotvEnt  := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava as movimentacoes no arquivo de trabalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSalTel := C10MC030Monta()

If Len(aTrbP) > 0
	
	If aSalTel[1] > 0 .And. aSalTel[mv_par05+1] > 0
		nCusMed := aSalTel[mv_par05+1]/aSalTel[1]
	ElseIf aSalTel[1] == 0 .And. aSalTel[mv_par05+1] == 0
		nCusMed := 0
	Else
		nCusMed := aSalTel[mv_par05+1]
	Endif
	aAdd(aSalIni,Transf(aSaltel[1],PesqPict("SD1","D1_QUANT",15)))
	aAdd(aSalIni,Transf(nCusMed,PesqPict("SB2","B2_CM1")))
	aAdd(aSalIni,Transf(aSaltel[mv_par05+1],PesqPict("SD1","D1_CUSTO")))
	C10MW030Brows(aSalIni)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga Arquivos Temporarios                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FERASE(cTrbSD1+".dbf")
	FERASE(cTrbSD1+OrdbagExt())
	FERASE(cTrbSD2+".dbf")
	FERASE(cTrbSD2+OrdbagExt())
	FERASE(cTrbSD3+".dbf")
	FERASE(cTrbSD3+OrdbagExt())
Else
	Help("",1,"MC030NOREC")
EndIf
Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C10MC030Monta³ Autor ³ Paulo Boschetti       ³ Data ³ 18/03/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava arquivo de trabalho                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC Function C10MC030Monta
Static lEstornados := NIL
Static lIxbConTes   := NIL

Local dCntData
Local nCusMed  := 0
Local cIdent   := ""
Local aSaldoIni:= {}
Local cDocumento:=""
Local aRetorno := {cPictQT, cPictTotQT}
Local nInd,cCondicao
LOCAL cNumSeqTr := "" , nRegTr := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe ponto de entrada                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL lTesNEst := .F.
LOCAL i := 0
lIxbConTes := IF(lIxbConTes == NIL,ExistBlock("MTAAVLTES"),lIxbConTes)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se considera registros estornados no SD3            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lEstornados := IF(lEstornados == NIL,GetMV("MV_D3ESTOR") == "S",lEstornados)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se utiliza custo unificado por empresa              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lCusUnif:=lCusUnif .And. mv_par03 == "**"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula o Saldo Inicial do Produto             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF lCusUnif
	aArea:=GetArea()
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial()+SB1->B1_COD)
	While !Eof() .And. B2_FILIAL+B2_COD == xFilial()+SB1->B1_COD
		aSalAlmox := CalcEst(SB1->B1_COD,SB2->B2_LOCAL,mv_par01)
		For i:=1 to Len(aSalAtu)
			aSalAtu[i] += aSalAlmox[i]
		Next i
		DbSkip()
	End
	RestArea(aArea)
Else
	aSalAtu  := CalcEst(SB1->B1_COD,mv_par03,mv_par01)
EndIf
aSaldoIni:= ACLONE(aSalAtu)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de entrada para Altera‡„o de Picture.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock('MC030PIC')
	aRetorno := ExecBlock('MC030PIC', .F., .F., aRetorno)
	If ValType(aRetorno) == 'A'
		cPictQT 	  := aRetorno[1]
		cPictTotQT := aRetorno[2]
	EndIf
EndIf
dCntData  := mv_par01
DbSelectArea("SD1")
If mv_par07 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice condicional p/ Custo Unificado                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCusUnif
		DbSelectArea("SD1")
		cIndice:="D1_FILIAL+D1_COD+DTOS(D1_DTDIGIT)+D1_NUMSEQ"
		INDREGUA("SD1",cTrbSD1,cIndice,,DbFilter(),STR0029) // Selecionando Registros
		nInd := RetIndex("SD1")
		#IFNDEF TOP
			dbSetIndex(cTrbSD1+OrdBagExt())
		#ENDIF
		DbSetOrder(nInd+1)
	Else
		DbSetOrder(7)
	EndIf
Else
	If lCusUnif
		cIndice:="D1_FILIAL+D1_COD+D1_SEQCALC+D1_NUMSEQ"
	Else
		cIndice:="D1_FILIAL+D1_COD+D1_LOCAL+D1_SEQCALC+D1_NUMSEQ"
	EndIf
	IndRegua("SD1",cTRBSD1,cIndice,,dbfilter(),STR0029) // Selecionando Registros
	nInd := RetIndex("SD1")
	#IFNDEF TOP
		DbSetIndex(cTRBSD1+OrdBagExt())
	#ENDIF
	DbSetOrder(nInd+1)
Endif

DbSelectArea("SD2")
If mv_par07 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice condicional p/ Custo Unificado                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCusUnif
		DbSelectArea("SD2")
		cIndice:="D2_FILIAL+D2_COD+DTOS(D2_EMISSAO)+D2_NUMSEQ"
		INDREGUA("SD2",cTrbSD2,cIndice,,DBFilter(),STR0029)  // Selecionando Registros
		nInd := RetIndex("SD2")
		#IFNDEF TOP
			DbSetIndex(cTrbSD2+OrdBagExt())
		#ENDIF
		DbSetOrder(nInd+1)
	Else
		DbSetOrder(6)
	EndIf
Else
	If lCusUnif
		cIndice:="D2_FILIAL+D2_COD+D2_SEQCALC+D2_NUMSEQ"
	Else
		cIndice:="D2_FILIAL+D2_COD+D2_LOCAL+D2_SEQCALC+D2_NUMSEQ"
	EndIf
	IndRegua("SD2",cTRBSD2,cIndice,,,STR0029) // Selecionando Registros
	nInd := RetIndex("SD2")
	#IFNDEF TOP
		DbSetIndex(cTRBSD2+OrdBagExt())
	#ENDIF
	DbSetOrder(nInd+1)
Endif

DbSelectArea("SD3")
If mv_par07 ==1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Indice condicional p/ Custo Unificado                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCusUnif
		DbSelectArea("SD3")
		cIndice:="D3_FILIAL+D3_COD+DTOS(D3_EMISSAO)+D3_NUMSEQ"
		INDREGUA("SD3",cTrbSD3,cIndice,,DBFilter(),STR0029)  // Selecionando Registros
		nInd := RetIndex("SD3")
		#IFNDEF TOP
			DbSetIndex(cTrbSD3+OrdBagExt())
		#ENDIF
		DbSetOrder(nInd+1)
	Else
		DbSetOrder(7)
	EndIf
Else
	If lCusUnif
		cIndice:="D3_FILIAL+D3_COD+D3_SEQCALC+D3_NUMSEQ"
	Else
		cIndice:="D3_FILIAL+D3_COD+D3_LOCAL+D3_SEQCALC+D3_NUMSEQ"
	EndIf
	IndRegua("SD3",cTRBSD3,cIndice,,,STR0029) // Selecionando Registros
	nInd := RetIndex("SD3")
	#IFNDEF  TOP
		DbSetIndex(cTRBSD3+OrdBagExt())
	#ENDIF
	dbSetOrder(nInd+1)
Endif

While .t.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para os demais paises que utilizam o Conceito de  ³
	//³ Remitos de Entrada para a Movimentacao de Estoques...        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc != "BRA"
		DbSelectArea("SCM")
		DbSetOrder(6)
		DbSeek(cFilial+SB1->B1_COD+mv_par03+iif(mv_par07==1,dtos(dCntData),""),.t.)
		While !Eof() .and. CM_FILIAL == xFilial("SCM") .and. CM_PRODUTO == SB1->B1_COD .And. CM_LOCAL == mv_par03
			
			IF mv_par07 ==1 .and. CM_EMISSAO <> dCntData
				exit
			EndIf
			
			If mv_par07 ==2 .and. (CM_EMISSAO < mv_par01 .or. CM_EMISSAO > mv_par02)
				DbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSeek(xFilial("SF4")+SCM->CM_TES)
			DbSelectArea("SCM")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa ponto de entrada para verificar se considera TES que ³
			//³ NAO ATUALIZA saldos em estoque.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIxbConTes .And. SF4->F4_ESTOQUE != "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE != "S" .And. !lTesNEst)
				DbSkip()
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Despreza Guias com Faturas(Loc. Chile)                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Iif(cPaisLoc=="CHI",If(!Empty(CM_NFISCAL),.T.,.F.),.F.)
				dbSkip()
				Loop
			EndIf
			
			If CM_TES <= "500"
				aSalAtu[1] += CM_QUANT
				aSalAtu[mv_par05+1] += IIF(mv_par05=1,CM_CUSTO1,&("CM_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] += CM_QTSEGUM
				nTotEnt    += CM_QUANT
				nTotvEnt   += IIF(mv_par05=1,CM_CUSTO1,&("CM_CUSTO"+Str(mv_par05,1,0)))
			Else
				aSalAtu[1] -= CM_QUANT
				aSalAtu[mv_par05+1] -= IIF(mv_par05=1,CM_CUSTO1,&("CM_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] -= CM_QTSEGUM
				nTotSda    += CM_QUANT
				nTotvSda   += IIF(mv_par05=1,CM_CUSTO1,&("CM_CUSTO"+Str(mv_par05,1,0)))
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Custo Medio do Produto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCusmed := C10CalcCMed(aSalAtu)
			
			cIdent := CM_FORNECE
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o pais para verificar o tamanho do documento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc=="ARG"
				cDocumento:=Trans(SCM->CM_REMITO,"@R 9999-99999999")
			Else
				cDocumento:=SCM->CM_REMITO
			EndIf
			aAdd(aTrbP, {SCM->CM_EMISSAO,SCM->CM_TES," REM ",cDocumento," "," ",cIdent,TRANSF(SCM->CM_QUANT,cPictQT),TRANSF((IIF(mv_par05=1,SCM->CM_CUSTO1,&("SCM->CM_CUSTO"+Str(mv_par05,1,0)))/SCM->CM_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(IIF(mv_par05=1,SCM->CM_CUSTO1,&("SCM->CM_CUSTO"+Str(mv_par05,1,0))),PesqPict("SCM","CM_CUSTO1"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Localizacao                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 ==1
				DbSelectArea("SDB")
				DbSeek(cFilial+SCM->CM_PRODUTO+SCM->CM_LOCAL+SCM->CM_NUMSEQ)
				While !Eof() .And. DB_FILIAL == cFilial .And. DB_PRODUTO == SB1->B1_COD .And. DB_LOCAL == mv_par03	.And. DB_NUMSEQ == SCM->CM_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						DbSkip()
						Loop
					EndIf
					aAdd(aTrbP,{" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," "  ,  Space(08) , Space(08), Space(1) , SDB->DB_LOCAL } )
					SDB->(DbSkip())
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Saldo item a item            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If mv_par04 == 1
				aAdd(aTrbP,{STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			EndIf
			
			DbSelectArea("SCM")
			
			DbSkip()
		EndDo
	EndIf
	
	dbSelectArea("SD1")
	dbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",mv_par03)+iif(mv_par07==1,dtos(dCntData),""),.t.)
	While !Eof() .And. D1_FILIAL == cFilial .And. D1_COD == SB1->B1_COD .And. If(lCusUnif,.T.,D1_LOCAL == mv_par03)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If D1_ORIGLAN $ "LF"
			DbSkip()
			Loop
		EndIf
		IF mv_par07 ==1 .and. D1_DTDIGIT <> dCntData
			exit
		EndIf
		If mv_par07 ==2 .and. (D1_DTDIGIT < mv_par01 .or. D1_DTDIGIT > mv_par02)
			DbSkip()
			Loop
		EndIf
		If cPaisLoc == "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSeek(cFilial+SD1->D1_TES)
			DbSelectArea("SD1")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa ponto de entrada para verificar se considera TES que ³
			//³ NAO ATUALIZA saldos em estoque.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIxbConTes .And. SF4->F4_ESTOQUE != "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE != "S" .And. !lTesNEst)
				DbSkip()
				Loop
			EndIf
			If D1_TES <= "500"
				aSalAtu[1] += D1_QUANT
				aSalAtu[mv_par05+1] += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] += D1_QTSEGUM
				nTotEnt    += D1_QUANT
				nTotvEnt   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
			Else
				aSalAtu[1] -= D1_QUANT
				aSalAtu[mv_par05+1] -= IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] -= D1_QTSEGUM
				nTotSda    += D1_QUANT
				nTotvSda   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Custo Medio do Produto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCusmed := C10CalcCMed(aSalAtu)
			cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
			
			aAdd(aTrbP, {SD1->D1_DTDIGIT,SUBS(SD1->D1_TES,1,3),SUBS(SD1->D1_CF,1,3),SD1->D1_DOC," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF((IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0))),PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Localizacao                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 1
				DbSelectArea("SDB")
				DbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
				While !Eof() .And. DB_FILIAL == cFilial .And. DB_PRODUTO == SB1->B1_COD .And. If(lCusUnif,.T.,DB_LOCAL == mv_par03) .And. DB_NUMSEQ == SD1->D1_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						DbSkip()
						Loop
					EndIf   				
					aAdd(aTrbP,{" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," "  , Space(08) , Space(08) , Space(1) , SDB->DB_LOCAL } )
					SDB->(DbSkip())
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Saldo item a item            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			If mv_par04 == 1
				aAdd(aTrbP,{STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Despreza Notas Fiscais com Remitos,com excecao Chile         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Iif(cPaisLoc=="CHI",if(Empty(D1_REMITO),.T.,.F.),if(!Empty(D1_REMITO),.T.,.F.))
				dbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SF4")
			DbSeek(cFilial+SD1->D1_TES)
			DbSelectArea("SD1")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa ponto de entrada para verificar se considera TES que ³
			//³ NAO ATUALIZA saldos em estoque.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIxbConTes .And. SF4->F4_ESTOQUE != "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE != "S" .And. !lTesNEst)
				DbSkip()
				Loop
			EndIf
			
			If D1_TES <= "500"
				aSalAtu[1] += D1_QUANT
				aSalAtu[mv_par05+1] += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] += D1_QTSEGUM
				nTotEnt    += D1_QUANT
				nTotvEnt   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
			Else
				aSalAtu[1] -= D1_QUANT
				aSalAtu[mv_par05+1] -= IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
				aSalAtu[7] -= D1_QTSEGUM
				nTotSda    += D1_QUANT
				nTotvSda   += IIF(mv_par05=1,D1_CUSTO,&("D1_CUSTO"+Str(mv_par05,1,0)))
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Custo Medio do Produto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCusmed := C10CalcCMed(aSalAtu)
			
			cIdent := If(Empty(D1_OP),D1_FORNECE, D1_OP)
			
			If cPaisLoc == "ARG"
				cDocumento:=TRANS(SD1->D1_DOC,"@R 9999-99999999")
			Else
				cDocumento:=SD1->D1_DOC            				
			EndIf
			
			aAdd(aTrbp, {SD1->D1_DTDIGIT,SD1->D1_TES," FAC ",cDocumento," "," ",cIdent,TRANSF(SD1->D1_QUANT,cPictQT),TRANSF((IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0)))/SD1->D1_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(IIF(mv_par05=1,SD1->D1_CUSTO,&("SD1->D1_CUSTO"+Str(mv_par05,1,0))),PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Localizacao                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 1
				DbSelectArea("SDB")
				DbSeek(cFilial+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ)
				While !Eof() .And. DB_FILIAL == cFilial .And. DB_PRODUTO == SB1->B1_COD .And. If(lCusUnif,.T.,DB_LOCAL == mv_par03) .And. DB_NUMSEQ == SD1->D1_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						DbSkip()
						Loop
					EndIf   				
					aAdd(aTrbP,{" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," "  , Space(08) , Space(08) , Space(1) , SDB->DB_LOCAL } )
					SDB->(DbSkip())
				EndDo
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Saldo item a item            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			If mv_par04 == 1
				aAdd(aTrbP,{STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			EndIf
			
		Endif
		
		DbSelectArea("SD1")
		
		DbSkip()
	EndDo
	
	DbSelectArea("SD3")
	DbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",mv_par03)+iif(mv_par07==1,dtos(dCntData),""),.t.)
	While !Eof() .And. D3_FILIAL == cFilial .And. D3_COD == SB1->B1_COD .And. If(lCusUnif,.T.,D3_LOCAL == mv_par03)
		
		If !Empty(D3_ESTORNO) .And. !lEstornados
			DbSkip()
			Loop
		EndIf
		
		IF mv_par07 ==1 .and. D3_EMISSAO <> dCntData
			exit
		EndIf
		
		If mv_par07 ==2 .and. (D3_EMISSAO < mv_par01 .or. D3_EMISSAO > mv_par02)
			DbSkip()
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja uma transferencia de localizacao verifica se lista   ³
		//³ o movimento ou nao                                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2 .And. Substr(D3_CF,3,1) == "4"
			cNumSeqTr := SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_LOCAL
			nRegTr    := Recno()
			dbSkip()
			If SD3->D3_COD+SD3->D3_NUMSEQ+SD3->D3_LOCAL == cNumSeqTr
				dbSkip()
				Loop		
			Else
				dbGoto(nRegTr)
			EndIf
		EndIf
		
		If D3_TM <= "500"
			aSalAtu[1] += D3_QUANT
			aSalAtu[mv_par05+1] += &("D3_CUSTO"+Str(mv_par05,1,0))
			aSalAtu[7] += D3_QTSEGUM
			nTotEnt    += D3_QUANT
			nTotvEnt   += &("D3_CUSTO"+Str(mv_par05,1,0))
		Else
			aSalAtu[1] -= D3_QUANT
			aSalAtu[mv_par05+1] -= &("D3_CUSTO"+Str(mv_par05,1,0))
			aSalAtu[7] -= D3_QTSEGUM
			nTotSda    += D3_QUANT
			nTotvSda   += &("D3_CUSTO"+Str(mv_par05,1,0))
		EndIf
		
		cIdent := If(Empty(D3_OP),D3_CC, D3_OP)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o Custo Medio do Produto               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCusmed := C10CalcCMed(aSalAtu)

		DbSelectArea("VO3")
		DbSetOrder(7)
		DbSeek( xFilial("VO3") + SD3->D3_DOC )

		DbSelectArea("VO2")
		DbSetOrder(2)
		DbSeek( xFilial("VO2") + VO3->VO3_NOSNUM )
		
		aAdd(aTrbP, {SD3->D3_EMISSAO,SUBS(SD3->D3_TM,1,3),SUBS(SD3->D3_CF,1,3),SD3->D3_DOC,SD3->D3_LOCALIZ,SD3->D3_NUMSERI,cIdent,TRANSF(SD3->D3_QUANT,cPictQT),TRANSF((&("SD3->D3_CUSTO"+Str(mv_par05,1,0))/SD3->D3_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD3->D3_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO")) , VO2->VO2_NUMOSV , VO3->VO3_NOSNUM , VO3->VO3_TIPTEM , SD3->D3_LOCAL } )
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se Lista Saldo item a item            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
		If mv_par04 == 1
			aAdd(aTrbP,{STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } ) //"Saldos"
		EndIf
		
		DbSelectArea("SD3")
		
		DbSkip()
		
	EndDo
	
	DbSelectArea("SD2")
	DbSeek(cFilial+SB1->B1_COD+If(lCusUnif,"",mv_par03)+iif(mv_par07==1,dtos(dCntData),""),.t.)
	While !Eof() .And. D2_FILIAL == cFilial .And. D2_COD == SB1->B1_COD .And. If(lCusUnif,.T.,D2_LOCAL == mv_par03)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Despreza Notas Fiscais Lancadas Pelo Modulo do Livro Fiscal  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If D2_ORIGLAN == "LF"
			DbSkip()
			Loop
		EndIf
		IF mv_par07 ==1 .and. D2_EMISSAO <> dCntData
			exit
		EndIf
		If mv_par07 ==2 .and. (D2_EMISSAO < mv_par01 .or. D2_EMISSAO > mv_par02)
			DbSkip()
			Loop
		EndIf
		
		If cPaisLoc == "BRA"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSeek(cFilial+SD2->D2_TES)
			DbSelectArea("SD2")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa ponto de entrada para verificar se considera TES que ³
			//³ NAO ATUALIZA saldos em estoque.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIxbConTes .And. SF4->F4_ESTOQUE != "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE != "S" .And. !lTesNEst)
				DbSkip()
				Loop
			EndIf
			
			If D2_TES <= "500"
				aSalAtu[1] += D2_QUANT
				aSalAtu[mv_par05+1] += &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] += D2_QTSEGUM
				nTotEnt    += D2_QUANT
				nTotvEnt   += &("D2_CUSTO"+Str(mv_par05,1,0))
			Else
				aSalAtu[1] -= D2_QUANT
				aSalAtu[mv_par05+1] -= &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] -= D2_QTSEGUM
				nTotSda    += D2_QUANT
				nTotvSda   += &("D2_CUSTO"+Str(mv_par05,1,0))
			EndIf
			
			cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Custo Medio do Produto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCusmed := C10CalcCMed(aSalAtu)
			
			aAdd(aTrbP,{SD2->D2_EMISSAO,SUBS(SD2->D2_TES,1,3),SUBS(SD2->D2_CF,1,3),SD2->D2_DOC," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF((&("SD2->D2_CUSTO"+Str(mv_par05,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD2->D2_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Localizacao                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 1
				DbSelectArea("SDB")
				DbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
				While !Eof() .And. DB_FILIAL == cFilial .And. DB_PRODUTO == SB1->B1_COD .And. If(lCusUnif,.T.,DB_LOCAL == mv_par03)	.And. DB_NUMSEQ == SD2->D2_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						DbSkip()
						Loop
					EndIf   				
					aAdd(aTrbP,{" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," "  , Space(08) , Space(08) , Space(1) , SDB->DB_LOCAL } )
					SDB->(DbSkip())
				EndDo
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Saldo item a item            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			If mv_par04 == 1
				aAdd(aTrbP,{STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			Endif
			
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Despreza Notas Fiscais com Remitos,com excecao Chile         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Iif(cPaisLoc<>"CHI",if(!Empty(D2_REMITO),.T.,.F.),.F.)
				SCN->(dbSetOrder(1))
				If SCN->(dbSeek(xFilial("SCN")+SD2->D2_REMITO+SD2->D2_ITEMREM)) .AND. SCN->CN_TIPOREM <> "1"
					SD2->(dbSkip())
					Loop
				EndIf
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a NOTA foi gerada em base a uma    ³
			//³  PROFORMA, se foi, o estoque sai s¢ pelo SCN.  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SD2->D2_TIPO == "E".AND.!EMPTY(SD2->D2_PEDIDO)
				SC5->(DbSetOrder(1))
				SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO))
				If SC5->(FOUND()) .And. !Empty(SC5->C5_NUMPROF)
					DbSkip()
					Loop
				Endif
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSeek(cFilial+SD2->D2_TES)
			DbSelectArea("SD2")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa ponto de entrada para verificar se considera TES que ³
			//³ NAO ATUALIZA saldos em estoque.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIxbConTes .And. SF4->F4_ESTOQUE != "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE != "S" .And. !lTesNEst)
				DbSkip()
				Loop
			EndIf
			
			If D2_TES <= "500"
				aSalAtu[1] += D2_QUANT
				aSalAtu[mv_par05+1] += &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] += D2_QTSEGUM
				nTotEnt    += D2_QUANT
				nTotvEnt   += &("D2_CUSTO"+Str(mv_par05,1,0))
			Else
				aSalAtu[1] -= D2_QUANT
				aSalAtu[mv_par05+1] -= &("D2_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] -= D2_QTSEGUM
				nTotSda    += D2_QUANT
				nTotvSda   += &("D2_CUSTO"+Str(mv_par05,1,0))
			EndIf
			
			cIdent := If(Empty(D2_OP),D2_CLIENTE, D2_OP)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Custo Medio do Produto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCusmed := C10CalcCMed(aSalAtu)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o pais para verificar o tamanho do documento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "ARG"
				cDocumento := TRANS(SD2->D2_DOC,"@R 9999-99999999")
			Else
				cDocumento := SD2->D2_DOC				
			EndIf
			
			aAdd(aTrbP, { SD2->D2_EMISSAO,SD2->D2_TES," FAC ",cDocumento," "," ",cIdent,TRANSF(SD2->D2_QUANT,cPictQT),TRANSF((&("SD2->D2_CUSTO"+Str(mv_par05,1,0))/SD2->D2_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SD2->D2_CUSTO"+Str(mv_par05,1,0)),PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Localizacao                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 1
				DbSelectArea("SDB")
				DbSeek(cFilial+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ)
				While !Eof() .And. DB_FILIAL == cFilial .And. DB_PRODUTO == SB1->B1_COD .And. If(lCusUnif,.T.,DB_LOCAL == mv_par03)	.And. DB_NUMSEQ == SD2->D2_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						DbSkip()
						Loop
					EndIf   				
					aAdd(aTrbP,{" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," "  , Space(08) , Space(08) , Space(1) , SDB->DB_LOCAL } )
					SDB->(DbSkip())
				EndDo
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Saldo item a item            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			If mv_par04 == 1
				aAdd(aTrbP,{STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } ) //"Saldos"
			EndIf
			
		Endif
		DbSelectArea("SD2")
		
		DbSkip()
	EndDo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento para os demais paises que utilizam o Conceito de  ³
	//³ Remitos de Sal¡da para a Movimentacao de Estoques...         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc != "BRA"
		DbSelectArea("SCN")
		DbSetOrder(4)
		DbSeek(cFilial+SB1->B1_COD+mv_par03,.t.)
		While !Eof() .and. CN_FILIAL == cFilial  .And. CN_PRODUTO == SB1->B1_COD .And. CN_LOCAL == mv_par03
			
			If mv_par07 ==1  .and. CN_EMISSAO <> dCntData
				DbSkip()
				Loop
			EndIf
			
			If mv_par07 ==2 .and. (CN_EMISSAO < mv_par01 .or. CN_EMISSAO > mv_par02)
				DbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Despreza Guias com Faturas(Loc. Chile)                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			
			If Iif(cPaisLoc=="CHI",If(!Empty(CN_NFISCAL),.T.,.F.),.F.)
				dbSkip()
				Loop
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se o TES atualiza estoque             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("SF4")
			DbSeek(cFilial+SCN->CN_TES)
			DbSelectArea("SCN")
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Executa ponto de entrada para verificar se considera TES que ³
			//³ NAO ATUALIZA saldos em estoque.                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lIxbConTes .And. SF4->F4_ESTOQUE != "S"
				lTesNEst := ExecBlock("MTAAVLTES",.F.,.F.)
				lTesNEst := If(ValType(lTesNEst) # "L",.F.,lTesNEst)
			EndIf
			If (SF4->F4_ESTOQUE != "S" .And. !lTesNEst)
				DbSkip()
				Loop
			EndIf
			
			If CN_TES <= "500"
				aSalAtu[1] += CN_QUANT
				aSalAtu[mv_par05+1] += &("CN_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] += CN_QTSEGUM
				nTotEnt    += CN_QUANT
				nTotvEnt   += &("CN_CUSTO"+Str(mv_par05,1,0))
			Else
				aSalAtu[1] -= CN_QUANT
				aSalAtu[mv_par05+1] -= &("CN_CUSTO"+Str(mv_par05,1,0))
				aSalAtu[7] -= CN_QTSEGUM
				nTotSda    += CN_QUANT
				nTotvSda   += &("CN_CUSTO"+Str(mv_par05,1,0))
			EndIf
			
			cIdent := CN_CLIENTE
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula o Custo Medio do Produto               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nCusmed := C10CalcCMed(aSalAtu)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o pais para verificar o tamanho do documento ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If cPaisLoc == "ARG"
				cDocumento:=Trans(SCN->CN_REMITO,"@R 9999-99999999")
			Else
				cDocumento:=SCN->CN_REMITO      				
			EndIf
			
			aAdd( aTrbP,{SCN->CN_EMISSAO,SCN->CN_TES," REM ",cDocumento," "," ",cIdent,TRANSF(SCN->CN_QUANT,cPictQT),TRANSF((&("SCN->CN_CUSTO"+Str(mv_par05,1,0))/SCN->CN_QUANT),PesqPict("SB2","B2_CM1")),TRANSF(&("SCN->CN_CUSTO"+Str(mv_par05,1,0)),PesqPict("SCN","CN_CUSTO"+Str(mv_par05,1,0)))  , Space(08) , Space(08) , Space(1) , Space(2) } )
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Localizacao                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 1
				DbSelectArea("SDB")
				DbSeek(cFilial+SCN->CN_PRODUTO+SCN->CN_LOCAL+SCN->CN_NUMSEQ)
				While !Eof() .And. DB_FILIAL == cFilial .And. DB_PRODUTO == SB1->B1_COD .And. DB_LOCAL == mv_par03	.And. DB_NUMSEQ == SCN->CN_NUMSEQ
					If SDB->DB_ESTORNO == "S"
						DbSkip()
						Loop
					EndIf   				
					aAdd(aTrbP,{" "," "," "," ",SDB->DB_LOCALIZ,SDB->DB_NUMSERI," ",TRANSF(SDB->DB_QUANT,cPictQT)," "," "  , Space(08) , Space(08) , Space(1) , SDB->DB_LOCAL } )
					SDB->(DbSkip())
				EndDo
			EndIf
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se Lista Saldo item a item            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ						
			If mv_par04 == 1
				aAdd(aTrbP,{STR0004," "," "," "," "," "," ",Transf(aSalAtu[1],cPictQT),Transf(nCusMed,PesqPict("SB2","B2_CM1")),Transf(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO"))  , Space(08) , Space(08) , Space(1) , Space(2) } ) //"Saldos"
			EndIf
			
			dbSelectArea("SCN")
			
			dbSkip()
		End
	EndIf
	dCntData++
	cCondicao:=IIf(mv_par07==1,dCntData > mv_par02,SD1->D1_COD <> SB1->B1_COD .And. SD2->D2_COD <> SB1->B1_COD .And. SD3->D3_COD <> SB1->B1_COD)
	If cCondicao
		Exit
	EndIf
	
EndDo
Return aSaldoIni

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C10CalcCMed ³ Autor ³ Paulo Boschetti       ³ Data ³ 22.03.93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C10CalcCMed(aSalAtu)

Local nCusmed := 0

If QtdComp(aSalAtu[1]) == QtdComp(0)
	nCusMed := 0
Else
	nCusMed := aSalAtu[mv_par05+1]/aSalAtu[1]
Endif

Return nCusmed

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CW030Brow ³ Autor ³ Cristina M. Ogura     ³ Data ³ 07.02.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta o Browse para o Windows                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³OFIOC010                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C10MW030Brows(aSalIni)

Local cCadastro := OemtoAnsi(STR0008+GetMV('MV_MOEDA'+Str(mv_par05,1,0)))	// "Consulta ao Kardex em "
Local oDlg, oQual, nX
Local oFont:=TFont():New( "Mono AS", 6, 15 )

DEFINE MSDIALOG oDlg TITLE cCadastro From 3,02 To 27,100 OF oMainWnd

@ .5, 001   SAY OemtoAnsi(STR0009)		//"Produto:"
If GetMV("MV_VEICULO") == "S"
	@ .5, 004   SAY SB1->B1_CODITE
Else
	@ .5, 004   SAY SB1->B1_COD
EndIf
@ .5, 015   SAY " - "+ SB1->B1_DESC
@ 1.2, 001  SAY OemToAnsi(STR0028) + Left(mv_par03, 2) // 'Almoxarifado: '
@ 1.2, 017  SAY OemtoAnsi(STR0012)	//"Tipo:"
@ 1.2, 019  SAY SB1->B1_TIPO
@ 1.2, 022  SAY OemtoAnsi(STR0013)	//"Unidade:"
@ 1.2, 025  SAY SB1->B1_UM
@ 1.2, 028  SAY OemtoAnsi(STR0014)	//"Grupo:"
@ 1.2, 031  SAY SB1->B1_GRUPO

@ 1.9, 001  SAY OemtoAnsi(STR0010)	//"Saldos Iniciais:"
@ 1.9, 006  SAY OemtoAnsi(STR0011)	//"Quantidade"
@ 1.9, 012  SAY aSalIni[1]
@ 1.9, 017  SAY OemtoAnsi(STR0015)	//"Custo Medio"
@ 1.9, 024  SAY aSalIni[2]
@ 1.9, 030  SAY OemtoAnsi(STR0016)	//"Custo Total"
@ 1.9, 038  SAY aSalIni[3]
@ 10.2,001  SAY STR0005+ "           -> "  + OemtoAnsi(STR0011)+" : " + TRANSF(aSalAtu[1],cPictTotQT) //"Saldos Finais" ### "Quantidade"
@ 10.2,017  SAY OemToAnsi(STR0015) + " : " +IIF(aSalAtu[1] != 0,TRANSF(aSalAtu[mv_par05+1]/aSalAtu[1],PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SB2","B2_CM1"))) //Custo Medio
@ 10.2,030  SAY OemToAnsi(STR0016) + " : " +TRANSF(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO")) //Custo Total
@ 10.9,001  SAY STR0006 + " -> "   +  OemtoAnsi(STR0011)+" : " + TRANSF(nTotEnt,cPictTotQT) //"Totais das Entradas"	### "Quantidade"
@ 10.9,030  SAY OemtoAnsi(STR0016) + " : " + TRANSF(nTotVEnt,PesqPict("SD1","D1_CUSTO")) // Custo Total
@ 11.6,001  SAY STR0007 + "    -> "   + OemtoAnsi(STR0011) + " : " + TRANSF(nTotSda,cPictTotQT)
@ 11.6,030  SAY STR0016 + " :  " + TRANSF(nTotVSda,PesqPict("SD1","D1_CUSTO")) //Custo Total

For nX := 1 to Len(aTrbP)
	aAdd(aTela, {})
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),1])  // Digitacao
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),2])  // Tes
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),3])  // CF
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),4])  // Documento
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³Verifica se Lista Localizacao                          ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//	If mv_par06 ==1
		aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),5])  // Localizacao
		aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),6])  // Num. Serie
//	Endif
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),7])  // Ident
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),8])  // Quant
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),9])  // Custo Medio
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),10]) // Custo Total
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),11]) // Nro Os
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),12]) // Nro Req
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),13]) // Tipo de Tempo
	aAdd(aTela[Len(aTela)], aTrbP[Len(aTela),14]) // Almoxarifado
Next nX

If mv_par06 ==1       // Imprime Localizacao
	@ 2.4, 001  LISTBOX oQual VAR FIELDS HEADER OemtoAnsi(STR0017), OemToAnsi(STR0018),;	//"Data   "###"TES "
		OemtoAnsi(STR0019),OemtoAnsi(STR0020),OemtoAnsi(STR0043),OemtoAnsi(STR0044),OemtoAnsi(STR0045),OemtoAnsi(STR0049),OemtoAnsi(STR0037),OemtoAnsi(STR0038),;	//"CFO "###"Docmto  "###"Localizacao     "###"Serie               "
		OemtoAnsi(STR0030),OemtoAnsi(STR0022),OemtoAnsi(STR0023),OemtoAnsi(STR0024) SIZE 370,090 FONT oFont //"Ident               "###"  Qtdade  "###"   Custo Medio "###"    Custo Total"
Else
	@ 2.4, 001  LISTBOX oQual VAR FIELDS HEADER OemtoAnsi(STR0017), OemToAnsi(STR0018),;	//"  Data   "###"TES "
		OemtoAnsi(STR0019),OemtoAnsi(STR0020),OemtoAnsi(STR0043),OemtoAnsi(STR0044),OemtoAnsi(STR0045),;	//"CFO "###"Docmto
		OemtoAnsi(STR0030),OemtoAnsi(STR0022),OemtoAnsi(STR0023),OemtoAnsi(STR0024) SIZE 370,090 FONT oFont //"Ident               "###"  Qtdade  "###"   Custo Medio "###"    Custo Total"
Endif

oQual:SetArray(aTela)
If mv_par06 ==1
	oQual:bLine := {||     { aTela[oQual:nAT, 1], aTela[oQual:nAT, 2],aTela[oQual:nAT,3], aTela[oQual:nAT, 4] , aTela[oQual:nAT, 11], aTela[oQual:nAT, 12], aTela[oQual:nAT, 13] , aTela[oQual:nAT, 14] , aTela[oQual:nAT, 5], ;
		aTela[oQual:nAT, 6] , aTela[oQual:nAT, 7], aTela[oQual:nAT, 8], aTela[oQual:nAT, 9], aTela[oQual:nAT, 10]  }}
Else
	oQual:bLine := {||     { aTela[oQual:nAT, 1], aTela[oQual:nAT, 2],aTela[oQual:nAT,3], aTela[oQual:nAT, 4] , aTela[oQual:nAT, 11], aTela[oQual:nAT, 12], aTela[oQual:nAT, 5], ;
		aTela[oQual:nAT, 6] , aTela[oQual:nAT, 7], aTela[oQual:nAT, 8]  }}
EndIf

DEFINE SBUTTON FROM 160,320  TYPE 1 ACTION (oDlg:End())	ENABLE OF oDlg
DEFINE SBUTTON FROM 160,350  TYPE 6 ACTION (C10a030Imp(),oDlg:End())	ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTERED
oFont:End()

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C10MsLoadPict³ Autor ³ Ben-Hur M Castilho    ³ Data ³ 03/12/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
Static Function C10MsLoadPict( aFields,nIntS,nDecS )
Local aPatern := { "","" },;
	nCnt01  := 0,;
	nDecPOS := 0,;
	nDecSIZ := 0,;
	aPrefix := {},;
	aPictQT := {}

//-> Separa Parametros da Mascara ( "@E" e "999999" )
For nCnt01 := 1 To Len( aFields )
	aAdd( aPictQT,AllTrim( PesqPict( "S" + Left(aFields[ nCnt01 ],2), aFields[ nCnt01 ],TamSX3( aFields[ nCnt01 ] )[ 1 ] ) ) )
	aAdd( aPrefix,AllTrim( SubStr( aPictQT[ nCnt01 ],1,(At( "9",aPictQT[ nCnt01 ] )-1) ) ) )
	aPictQT[ nCnt01 ] := AllTrim( SubStr( aPictQT[ nCnt01 ],At( "9",aPictQT[ nCnt01 ] ) ) )
Next

//-> Seleciona Maior Parametro e Maior Mascara
For nCnt01 := 1 To 3
	aPatern[ 1 ] := If( (Len(aPrefix[ nCnt01 ]) > Len(aPatern[ 1 ])),aPrefix[ nCnt01 ],aPatern[ 1 ] )
	aPatern[ 2 ] := If( (Len(StrTran(aPictQT[ nCnt01 ],",","")) > Len(StrTran(aPatern[ 2 ],",",""))),aPictQT[ nCnt01 ],aPatern[ 2 ] )
	nDecSIZ      := Max( nDecSIZ,(Len( aPatern[ 2 ] )-At( ".",aPatern[ 2 ] )) )
Next

//-> Se Maior Que nIntS, Retira as ","s Dos Milhares
If (Len( aPatern[ 2 ] ) > nIntS )
	aPatern[ 2 ] := StrTran( aPatern[ 2 ],",","" )
EndIf

If (Len( aPatern[ 2 ] ) > nIntS )
	
	If ((nDecPOS := At( ".",apatern[ 2 ] )) # 0)
		//-> Se Tem Decimais, Ajusta Decimais Para 4 e Corta Pela Esquerda
		If ((Len( aPatern[ 2 ] )-nDecPOS) > nDecS)
			aPatern[ 2 ] := SubStr( aPatern[ 2 ],(nDecPOS+nDecS) )+Left( aPatern[ 2 ],(nDecPOS+nDecS) )
			aPatern[ 2 ] := Right( aPatern[ 2 ],nIntS )
		Else
			//-> Se Decimais Nao Maiores Que 4, Corta Pela Esquerda
			aPatern[ 2 ] := Right( aPatern[ 2 ],nIntS )
		Endif
	Else
		//-> Se Ainda Maior Que nIntS e Nao Tem Decimais, Corta Pela Esquerda
		aPatern[ 2 ] := Right( aPatern[ 2 ],nIntS )
	EndIf
EndIf

Return( aPatern[ 1 ]+" "+aPatern[ 2 ] )
*/

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C10a030Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 18/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao da consulta.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C10a030Imp()

LOCAL cTitulo   := OemToAnsi(STR0036) // "CONSULTA AO KARDEX"
LOCAL cDesc1    := OemToAnsi(STR0031) // "Este programa ira imprimir a Consulta do Produto selecionado"
LOCAL cDesc2    := OemToAnsi(STR0032) // "informando as movimentacoes de estoque com seus respectivos"
LOCAL cDesc3    := OemToAnsi(STR0033) // "custos, saldos iniciais e saldos finais."
LOCAL cString   :="SD1"
LOCAL wnrel     :="OFIOC010"   
LOCAL Tamanho   := If(mv_par06==1,"G","M")
PRIVATE cPerg   :=nil
PRIVATE aReturn := { OemToAnsi(STR0034), 1,OemToAnsi(STR0035), 2, 2, 1, "",1 } // Zebrado "###"  Administracao
PRIVATE nLastKey:=0
                                    
wnRel:= SetPrint(cString,wnrel,cPerg,cTitulo,cDesc1,cDesc2,cDesc3,.F.,"",.f.,Tamanho) 

If nLastKey = 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Return
Endif

RptStatus({|lEnd| C10C030Imp(@lEnd,wnRel,tamanho,ctitulo)},ctitulo)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C10C030Imp  ³ Autor ³ Marcelo Pimentel      ³ Data ³ 19/11/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Envia para funcao que faz a impressao da consulta.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function C10C030Imp(lEnd,wnRel,cTamanho,ctitulo)

Local cCabec1  :=""
Local cCabec2  :=""
Local nTipo     := If(aReturn[4]==1,15,18)
Local cbtxt    := SPACE(10)
Local cbcont   := 0
Local nI, nX                                       
cCabec1:=OemtoAnsi(STR0017)+OemToAnsi(STR0018)	//"Data      "###"TES "
cCabec1+=OemtoAnsi(STR0019)+OemtoAnsi(STR0020)+Space(1)+OemtoAnsi(STR0046)+OemtoAnsi(STR0047)+OemtoAnsi(STR0048)+If(mv_par06 ==1,OemtoAnsi(STR0049)+" "+OemtoAnsi(STR0037)+" "+OemtoAnsi(STR0038),"") + " " //"CFO "###"Docmto "###"Localizacao "###"Serie   "
cCabec1+=OemtoAnsi(STR0030)+" "+OemtoAnsi(STR0022)+" "+OemtoAnsi(STR0023)+" "+OemtoAnsi(STR0024)	//"###"Ident    " Qtdade  "###"   Custo Medio "###"    Custo Total"
li       := 80
m_pag    := 1

Li++
For nI:=1 to Len(aTela)
	
	If li > 58
		cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,nTipo)
		@ li, 00 pSay STR0025 + Left(AllTrim(SB1->B1_COD), 30) + ' - ' + Left(SB1->B1_DESC, 30) // 'Produto: '
		LI++
		@ li, 00 pSay STR0026 + Left(SB1->B1_TIPO, 2) // 'Tipo: '
		@ li, 12 pSay STR0027 + Left(SB1->B1_UM, 2) // 'Unidade: '
		@ li, 27 pSay STR0014 + SB1->B1_GRUPO
		li ++
		@ li, 00 pSay STR0028 + Left(mv_par03, 2) // 'Almoxarifado: '
		li += 3
	EndIf

	@ li,000 PSay aTela[nI,1]                // Digitacao
	@ li,011 PSay Substr(aTela[nI,2],1,3)   // Tes
	@ li,015 PSay Substr(aTela[nI,3],1,3)   // CF
	@ li,019 PSay aTela[nI,4]                // Documento
	@ li,033 PSay aTela[nI,11]                // Nro Os   
	@ li,042 PSay aTela[nI,12]                // Nro Req  
	@ li,060 PSay aTela[nI,13]                // Tipo de tempo
	// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	// ³Verifica se imprime Localizacao                        ³
	// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par06 ==1
		@ li,30+033 PSay aTela[nI,14]    					// Armazem
		@ li,38+033 PSay Substr(aTela[nI,5],1,15)    // Localizacao
		@ li,38+049 PSay Substr(aTela[nI,6],1,20)    // Num. Serie
	EndIf
	nX :=IIf(mv_par06 ==1,7,5)
	@ li,38+IIf(mv_par06 ==1,071,34) PSay aTela[nI,nX++]     // Ident
	@ li,38+IIf(mv_par06 ==1,094,56) PSay aTela[nI,nX++]     // Quant
	@ li,38+IIf(mv_par06 ==1,110,73) PSay aTela[nI,nX++]     // Custo Medio
	@ li,38+IIf(mv_par06 ==1,126,89) PSay aTela[nI,nX++]     // Custo Total
	li+=1
Next nI

li+=4

If li > 58
	cabec(cTitulo,cCabec1,cCabec2,wnRel,cTamanho,nTipo)
	li += 2
EndIf

@ li,00 PSAY STR0005   //Saldos Finais
@ li,38+IIf(mv_par06 ==1,094,56) PSay TRANSF(aSalAtu[1],cPictTotQT)
@ li,38+IIf(mv_par06 ==1,110,73) PSay IIF(aSalAtu[1] != 0,TRANSF(aSalAtu[mv_par05+1]/aSalAtu[1],PesqPict("SB2","B2_CM1")),TRANSF(0,PesqPict("SB2","B2_CM1")))
@ li,38+IIf(mv_par06 ==1,126,89) PSay TRANSF(aSalAtu[mv_par05+1],PesqPict("SD1","D1_CUSTO")) 
li++
@ li,00 PSAY STR0006   //Totais das Entradas
@ li,38+IIf(mv_par06 ==1,094,56) PSay TRANSF(nTotEnt,cPictTotQT)
@ li,38+IIf(mv_par06 ==1,126,89) PSay TRANSF(nTotVEnt,PesqPict("SD1","D1_CUSTO")) 
li++
@ li,00 PSAY STR0007   //Totais das Saidas
@ li,38+IIf(mv_par06 ==1,094,56) PSay TRANSF(nTotSda,cPictTotQT)
@ li,38+IIf(mv_par06 ==1,126,89) PSay TRANSF(nTotVSda,PesqPict("SD1","D1_CUSTO")) 

IF li != 80
	li++
	roda(cbcont,cbtxt,cTamanho)
EndIf

If aReturn[5] = 1
	Set Printer TO
	dbCommitAll()
	ourspool(wnrel)
EndIf

MS_Flush()

Return (.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C10MTC030CUnf ³ Autor ³Rodrigo de A. Sartorio ³ Data ³27/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ajusta grupo de perguntas p/ Custo Unificado                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C10MTC030CUnf()

Local aSvAlias:=GetArea()
dbSelectArea("SX1")
If dbSeek("MTC03003",.F.)
	If !("C10MTC030VAlm" $ X1_VALID)
		RecLock("SX1",.F.)
		If Empty(X1_VALID)
			Replace X1_VALID With "C10MTC030VAlm"
		Else
			Replace X1_VALID With X1_VALID+".And.C10MTC030VAlm"
		EndIf
		MsUnlock()
	EndIf
	If lCusUnif .And. X1_CNT01 != "**"
		RecLock("SX1",.F.)
		Replace X1_CNT01 With "**"
		MsUnlock()
	EndIf
Endif
RestArea(aSvAlias)
Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³C10MTC030VAlm ³ Autor ³Rodrigo de A. Sartorio ³ Data ³27/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Almoxarifado do KARDEX com relacao a custo unificado ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOC010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function C10MTC030VAlm

LOCAL lRet:=.T.
LOCAL cConteudo:=&(ReadVar())
LOCAL nOpc:=2
If lCusUnif .And. cConteudo != "**"
	nOpc := Aviso(STR0039,STR0040,{STR0041,STR0042})	//"Aten‡„o"###"Ao alterar o almoxarifado o custo medio unificado sera desconsiderado."###"Confirma"###"Abandona"
	If nOpc == 2
		lRet:=.F.
	EndIf
EndIf
Return lRet


Static Function MenuDef()
Local aRotina := { {STR0001,"AxPesqui", 0 , 1},;	// "Pesquisar"
						{STR0002,"C10Mc030Con", 0 , 2}}	// "Consulta"
Return aRotina
