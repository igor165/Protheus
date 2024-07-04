#Include "PROTHEUS.CH"
#Include "VEIXX002.CH"

#DEFINE lDebug .f.

Static cPrefVEI := GetNewPar("MV_PREFVEI","VEI") // Modulo de Veiculos - Prefixo de Origem ( F2_PREFORI / E1_PREFORI )
Static lIntLoja := ( Substr(GetNewPar("MV_LOJAVEI","NNN"),3,1) == "S" )
Static cTitAten := IIf(lIntLoja,"2",left(GetNewPar("MV_TITATEN","0"),1)) // Momento da Geracao de Titulos (0=Finalizacao/1=Pre-Aprovacao/2=Aprovacao)
Static nVerAten := IIf( GetNewPar("MV_AVEIMAX",1) > 1 , 3 , 2 )	// Versao do Atendimento
Static nAVEIMAX := GetNewPar("MV_AVEIMAX",1)	// Quantidade Maxima de veiculos no atendimento
Static lLayoutFolder := (nVerAten > 2 .and. (GetNewPar("MV_MILVERA",.f.) == .t.))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VEIXX002 º Autor ³ Andre Luis / Rubens º Data ³ 31/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atendimento de Veiculos Modelo 2 - Novo                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIXX002(xAutoCab,xAutoItens,xAutoCP,nOpc,aRecInter,xAutoVV9,xOpcCanc,xMotCanc,xAutoAvanca, xFaseInter, xSerieNF, xAutoVS9)

Local lRet

Default xOpcCanc := 2  // Cancela atendimento
Default xMotCanc := {} // Motivo de cancelamento
Default xFaseInter := ""
Default xSerieNF := ""
Default xAutoVS9 := {}

Private lXX002Auto := (xAutoCab <> NIL .and. xAutoItens <> NIL)

Private N           := 1 			// Variavel necessaria ao MAFISREF
Private bRefresh    := { || .t. } 	// Variavel necessaria ao MAFISREF
Private aHeader     := {} 			// Variavel necessaria ao MAFISREF
Private aCols       := {} 			// Variavel necessaria ao MAFISREF
Private cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
Private aMemos      := {{"VV0_OBSMEM","VV0_OBSERV"}}
Private cValPict    := GetSX3Cache("VS9_VALPAG","X3_PICTURE")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Matrizes de Parametros utilizadas nas chamadas dos VEIX's auxiliares ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aParFin		:= {0,"","","","","","","","","","","",0,0,{}}		// Financiamento FI / Leasing
Private aParFna		:= {"","","","","","",0,ctod(""),0,ctod("")}		// Finame
Private aParPro		:= {"",0,ctod(""),0,0,0,"0",0,0,"1111111111111"}	// Financiamento Proprio
Private aParVZ7		:= {}												// Acao de Vendas (VZ7)
Private aStruVZ7	:= {"","","","","","","","","",""}					// Acao de Vendas (VZ7)
Private aSimFinanc	:= {"",0,0,0,0}										// ListBox Taxa do Dia
Private aParCon		:= {""}												// Consorcio
Private aParUsa		:= {""}												// Veiculos Usados para Troca
Private aParEnt		:= {"",0}											// Entradas
Private aParOpc		:= {"","",""}										// Opcionais do Veiculo
Private aMinCom		:= {}												// Minimo Comercial do Veiculo
Private aStruMCom	:= {"","","","","",0,0,0,0,0}						// Estrutura do Array de Minimo Comercial
Private aEntrVei	:= {"","","","",ctod(""),ctod(""),"",0,0,"","","",""}	// Dt.Entrega do Veiculo

// Variaveis de integracao
Private aAutoCab    := IIf( lXX002Auto , xAutoCab   , {} ) // Cabecalho da NF (VV0)
Private aAutoItens  := IIf( lXX002Auto , xAutoItens , {} ) // Itens da NF (VVA)
Private aAutoVV9    := IIf( lXX002Auto , xAutoVV9   , {} )
Private aAutoAux    := {} // Auxiliar (para retornos de remessa/consignado)
Private nOpcCanc    := IIf( lXX002Auto , xOpcCanc   , 0 )
Private aMotCanc    := IIf( lXX002Auto , xMotCanc   , {} )
Private lAutoAvanca := IIf( lXX002Auto , xAutoAvanca, .f. )
Private cFaseInter  := IIf( lXX002Auto , xFaseInter , "" )
Private cSerieNFAuto:= IIf( lXX002Auto , xSerieNF , "" )
Private aAutoVS9    := IIf( lXX002Auto , xAutoVS9 , {} )

Private cVV9Status  := ""

Private lAtuFiscal := .f. // Variavel necessária pois é utilizada no VEIXX001...
Private cOpeMov := "0"    // Variavel necessária pois é utilizada no VEIXX001...

Private nVVARECNO   := 0 // Coluna da aCols referente ao RECNO do VVA

Private lVVASEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )

// Na integracao as variaveis abaixo nao existirao, por isso precisamos carrega-las manualmente //
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Parametros da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("VXA018",.f.)
Private cTpOperNov := MV_PAR01 // Tipo de Operacao para Veiculos Novos
Private cTpOperUsa := MV_PAR02 // Tipo de Operacao para Veiculos Usados
Private cCliPadrao := MV_PAR03 // Cliente Padrao
Private cLojPadrao := MV_PAR04 // Loja do Cliente Padrao
Private cVenVdaDir := PadR(GetNewPar("MV_MIL0050",""),TamSX3("A3_COD")[1]," ") // Codigo do Vendedor que sera enviado na integracao com o Venda Direta
Private cTESDefNov := MV_PAR09 // TES default para Veiculos Novos quando nao existir a regra no TES inteligente.
Private cTESDefUsa := MV_PAR10 // TES default para Veiculos Usados quando nao existir a regra no TES inteligente.
Private nVerParFat := MV_PAR11 // Mostrar Parametros do Faturamento no momento da geracao da NF

Default aRecInter  := {} // RecNo's dos Interesses da Oportunidade de Vendas

If Empty(cVenVdaDir)
	cVenVdaDir := MV_PAR08 // Codigo do Vendedor que sera enviado na integracao com o Venda Direta
EndIf

if empty(cValPict)
	cValPict := "@E 99,999,999.99"
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida se a empresa tem autorizacao para utilizar os modulos de Veiculos   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//////////////////////////////////////////////////////////////////////////////
//If !FMX_AMIIN({"VEIXA018","VEIXA019","VEIXA030","VEIXA040","VEIVA620","VEICC500","VEIVC080","VEIVC110","VEIVC140","VEIVC170","VEIVC200","VEIVC210","VEIVC220","VEIVM130","VEIXC002","VEIXC008","VEICC610","VEIVC250","OFIOC500","VEICM680","VEICC680","VEIVM190"})
//	Return
//EndIf

If lXX002Auto .and. nOpc <> 3
	nPosVV9NUMATE := aScan(aAutoVV9 , { |x| x[1] == "VV9_NUMATE" })
	If nPosVV9NUMATE == 0
		VX002ExibeHelp("VX002ERR008","Parâmetros incorretos na chamada da rotina de atendimento.","Enviar parâmetro do número do atendimento. (VV9_NUMATE)")
		Return .f.
	EndIf

	dbSelectArea("VV9")
	dbSetOrder(1)
	If ! VV9->(dbSeek( xFilial("VV9") + aAutoVV9[nPosVV9NUMATE, 2] ))
		HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VV9_NUMATE")) + ": " + aAutoVV9[nPosVV9NUMATE, 2],4,1)
		Return .f.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e' Faturamento Direto para visualizar pela rotina VEIXA030     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 2 // Visualizar
	VV0->(dbSetOrder(1))
	If VV0->(dbSeek(xFilial("VV0") + VV9->VV9_NUMATE))
		If VV0->VV0_TIPFAT == "2" // Faturamento Direto
			VXA030("VV9",VV9->(RecNo()),nOpc)
			Return
		EndIf
	EndIf
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se e' possivel ALTERAR/CANCELAR Atendimento atraves do VV9_STATUS ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 4 // Alteracao
	If VV9->VV9_STATUS == "F"
		VX002ExibeHelp("VX002ERR001",STR0012) // Impossivel ALTERAR Atendimento Finalizado! / Atencao
		Return
	ElseIf VV9->VV9_STATUS == "C"
		VX002ExibeHelp("VX002ERR002",STR0013) // Impossivel ALTERAR Atendimento Cancelado! / Atencao
		Return
	EndIf
ElseIf nOpc == 5 // Cancelar
	If VV9->VV9_STATUS == "C"
		VX002ExibeHelp("VX002ERR003",STR0015) // Impossivel CANCELAR Atendimento Cancelado! / Atencao
		Return
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada Inicial, executado antes da TELA do Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VX002INI")
	lRet := ExecBlock("VX002INI",.f.,.f.,{nOpc})
	If !lRet
		Return
	EndIf
EndIf

VX002CONOUT("")
VX002CONOUT("VEIXX002","nAVEIMAX - " + cValToChar(nAVEIMAX))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama a tela contendo os dados do veiculo                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DBSelectArea("VV9")
lRet := VX002EXEC(alias(),Recno(),nOpc,aRecInter)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada Final, executado apos a TELA do Atendimento     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VX002FIN")
	ExecBlock("VX002FIN",.f.,.f.,{nOpc})
EndIf

VX002CONOUT("VEIXX002",lRet)
VX002CONOUT("")

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002EXEC º Autor ³ Andre Luis / Rubens º Data ³ 31/03/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atendimento de Veiculos Modelo Novo                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002EXEC(cAlias,nReg,nOpc,aRecInter)
//
Local aObjects		:= {} // Objetos Principal da Tela
Local aObjEnchoice	:= {} // Objetos Enchoices (VV9 e VV0)

Local aObjFinanc	:= {} // Objetos do Resumo Financeiro / Composicao das Parcelas
Local aObjLBoxVZ7	:= {} // Objetos Listbox do VZ7 - Troco, Venda Agregada, Cortesia e Redutor
Local aObjVlrNeg 	:= {} // Objetos Valores de Negociacao
Local aObjVlrTNeg   := {} // Objetos Totais de Negociacao
Local aObjSimul     := {} // Objetos Simulacao
Local aObjFolder		:= {} // Objetos da Folder de Negociacao - Versao 4

Local aPOPri	:= {} // Divisao Principal da Tela
Local aPOEnc	:= {} // Parte da tela onde ficarao os Enchoices (VV9 e VV0)
Local aPOGetDad	:= {} // Parte da tela onde ficarao GetDados (VVA)
Local aPOFinanc := {} // Parte da tela onde ficarao Resumo Financeiro / Composicao das Parcelas
Local aPOVZ7	:= {} // Parte da tela onde ficarao os Listbox do VZ7 - Troco, Venda Agregada, Cortesia e Redutor
Local aPOVlrNeg	:= {} // Parte da tela onde ficarao os Objetos Valores de Negociacao
Local aPOSimul	:= {} // Parte da tela onde ficarao os Objetos da Simulacao / Taxa do Dia

Local aSizeAut	:= MsAdvSize(.t.)

Local nAuxLinha := 0
Local nCntFor   := 0
Local nAuxPos   := 0
Local nColBut   := 2  // Coluna para Criacao dos Botoes no Scroll de Valores de Negociacao
Local nColMSGet := 74 // Coluna para Criacao dos Get's no Scroll de Valores de Negociacao
Local nAuxCol
Local nAuxLin
Local nAuxPosSX3

Local aVS9     := {{},{}}
Local aVSE     := {{},{}}
Local aVZ7     := {{},{}}

Local nOpcBkp  := nOpc // Salvar nOpc para ser utilizado apos VEIXC002
Local nOpcVV9  := nOpc // Controla nOpc para Enchoice da VV9
Local nOpcVV0  := nOpc // Controla nOpc para Enchoice da VV0

Local cLinOkVVA
Local cTudOkVVA
Local cFldOkVVA

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nModelo   := 3
Local cTudoOk   := ".t."
Local lF3       := .f.
Local lMemoria  := .t.
Local lColumn   := .f.
Local cATela    := ""
Local lProperty := .f.
//
Local aChaInts  := {}
//
Local aRetMapa  := {0,0,{}}
Local nPos      := 0
//
Local cBotAtF7  := "1" // Imagem do Botao <F7> - Veiculos
Local cDirFotos := GetNewPar("MV_DIRFTGC","")
Local aLogo     := {}
//
Local cBotAten  := GetNewPar("MV_BOTATEN","111111") // Habilitar Botoes Padroes de Valores de Negociacao do Atendimento
Local cVAI_VZ7  := ""
//
Local aTotVZ7 // Valores de Acoes de Venda - VZ7
//
Local lCPagPad  := ( GetNewPar("MV_MIL0016","0") == "1" ) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim) - Chamado CI 001985
Local lVV0FPGPAD  := (VV0->(ColumnPos("VV0_FPGPAD")) > 0) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim)
//
Local lVAI_AAPPRE := (VAI->(ColumnPos("VAI_AAPPRE")) > 0)
Local lVV9_APRPUS := (VV9->(ColumnPos("VV9_APRPUS")) > 0)
Local nOpcAviso   := 0
//
Private aInfCliente := {.f.,"","","","",{}}
Private cCadastro := STR0001 // Atendimento
//
Default aRecInter   := {} // RecNo's dos Interesses da Oportunidade de Vendas
//
If INCLUI

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ VEIXC002 - Tela Inicial com informacoes do Cliente                ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³ aInfCliente[1] = Logico indicando se confirmado novo atendimento  ³
	//³ aInfCliente[2] = Codigo do Cliente                                ³
	//³ aInfCliente[3] = Loja do Cliente                                  ³
	//³ aInfCliente[4] = Nome do Cliente                                  ³
	//³ aInfCliente[5] = Telefone do Cliente                              ³
	//³ aInfCliente[6] = Vetor com Interesses do Cliente (Oportunidade)   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcBkp     := nOpc // Salvar nOpc para ser utilizado apos VEIXC002

	If ! lXX002Auto
		aInfCliente := VEIXC002(aRecInter)
		If !aInfCliente[1] // Indica se foi confirmado novo atendimento
			Return .t.
		EndIf
	EndIf

	cVV9Status  := "A" // Inclusao - Status Aberto (Digitacao)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Voltar nOpc e variaveis que podem ser disposicionadas no VEIXC002 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpc      := nOpcBkp
	VISUALIZA := ( nOpc == 2 )
	INCLUI 	  := ( nOpc == 3 )
	ALTERA 	  := ( nOpc == 4 )
	EXCLUI 	  := ( nOpc == 5 )

Else

	// STATUS do Atendimento //
	cVV9Status := VV9->VV9_STATUS

	If ! lXX002Auto .and. ALTERA
		If cVV9Status == "A" .and. lVV9_APRPUS .and. !Empty(VV9->VV9_APRPUS)
			VAI->(dbSetOrder(4))
			VAI->(MsSeek(xFilial("VAI")+__cUserID))
			If lVAI_AAPPRE .and. VAI->VAI_AAPPRE == "1" // Usuario pode Alterar mesmo com Aprovacao Previa?
				nOpcAviso := Aviso(STR0171,STR0176,{STR0177,STR0178,STR0175},2) // O Atendimento ja possui Aprovacao Previa. / Deseja Alterar/Avançar o Atendimento mantendo a Aprovação Prévia ou perdendo a Aprovação Prévia? / Perder Aprovação / Manter Aprovação / Fechar
			Else
				nOpcAviso := Aviso(STR0171,STR0172+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0173,{STR0009,STR0174,STR0175},2) // O Atendimento ja possui Aprovacao Previa. / Deseja Avancar o Atendimento ou Altera-lo? / Obs.: A Alteracao do Atendimento implicara na perda da Aprovacao Previa. / Alterar / Avancar / Fechar
			EndIf
			Do Case
				Case nOpcAviso == 1 // Alterar perdendo a Aprovacao Previa
					VX0020041_LimpaAprovacaoPrevia() // Limpar a Aprovacao Previa
					VX0020051_LimpaPedido() // Limpa Ligação do VVA com o VQ0
				Case nOpcAviso == 2
					If lVAI_AAPPRE .and. VAI->VAI_AAPPRE == "1" // Usuario pode Alterar mesmo com Aprovacao Previa?
						VX0020051_LimpaPedido() // Limpa Ligação do VVA com o VQ0, porem sera refeita quando avancar o Atendimento que esta com Aprovacao Previa
					Else
						cVV9Status := "L" // Manipular Status do Atendimento para NAO permitir alteracao - Como se estivesse Aprovado - Apenas AVANCA
					EndIf
				Otherwise // Fechar TELA do Atendimento
					Return
			EndCase
		EndIf
	EndIf

EndIf

Private nRegVV0
Private aVSETotal   := {{},{}} // Vetor com todos os VSE correspondentes ao Atendimento, vetor utilizado nos VEIXX...

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis para Criacao/Controle das Enchoices ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cVV9NEdit	:= ""	// Campos NAO Editaveis
Private cVV9NMostra	:= ""	// Campos a NAO serem exibidos
Private aCpoVV9  	:= {} 	// ARRAY DE CAMPOS DA ENCHOICE
Private aCpoVV9Alt  := {} 	// ARRAY DE CAMPOS DA ENCHOICE EDITAVEIS

Private cVV0NEdit	:= ""	// Campos NAO Editaveis
Private cVV0NMostra	:= ""	// Campos a NAO serem exibidos
Private aCpoVV0  	:= {} 	// ARRAY DE CAMPOS DA ENCHOICE
Private aCpoVV0Alt  := {} 	// ARRAY DE CAMPOS DA ENCHOICE EDITAVEIS
Private cCpoVV0Alt  := ""  	// Campos VV0 Editaveis quando Atendimento esta com o STATUS ( Pendente Aprovacao, Pre-Aprovado ou Aprovado )
Private aFisVV0     := MaFisRelImp("VEIXX002",{"VV0"})

Private cVVANEdit	:= ""	// Campos NAO Editaveis
Private cVVANMostra	:= ""	// Campos a NAO serem exibidos
Private aCpoVVA  	:= {} 	// ARRAY DE CAMPOS DA ENCHOICE/GetDados
Private aCpoVVAAlt  := {} 	// ARRAY DE CAMPOS DA ENCHOICE/GetDados EDITAVEIS
Private aHeaderVVA	:= {}
Private aColsVVA	:= {}
Private aFisVVA     := MaFisRelImp("VEIXX002",{"VVA"})

Private oDlgAtend 	// Dialog Principal
Private oEnchVV9	// Enchoice VV9
Private oEnchVV0	// Enchoice VV0
Private oGetDadVVA  := DMS_GetDAuto():Create()	// GetDados de Veiculos

Private oVlVeicu , nVlVeicu := 0 				// Get e Valor do Veiculo
Private oVlAtend , nVlAtend := 0 				// Get e Valor do Atendimento
Private oVlNegoc , nVlNegoc := 0 				// Get e Valor do Total Negociado
Private oVlDevol , oTitDevol , nVlDevol := 0 	// Get e Valor da Devolucao
Private oVlSaldo , oTitSaldo , nVlSaldo := 0 	// Get e Valor do Saldo Restante
Private oFlVlFinanc, nFlVlFinanc := 0			// Get e Valor da Simulacao de Financiamento - Taxa do Dia

Private oMapaBom	// Botao com Mapa de Avaliacao - VERDE
Private oMapaMed	// Botao com Mapa de Avaliacao - AMARELO
Private oMapaRui	// Botao com Mapa de Avaliacao - VERMELHO

Private oLboxCParc 		// Listbox da Composicao das Parcelas

Private oLboxSimFina	// Listbox da Simulacao de Financiamento - Taxa do Dia

Private oLboxTroco		// Listbox do Troco
Private oLboxVAgreg		// Listbox das Vendas Agregadas
Private oLboxCortesia	// Listbox da Cortesia
Private oLboxRedutor	// Listbox do Redutor

Private aBotEncAte := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Botoes e Get's de Valores de Negociacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aObjValNeg := {}

If !lCPagPad // Padrão Veículos

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Financiamento/Leasing   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjValNeg, {'oBtnFinLea' , STR0002 , 'VX002BTVLN("1",nOpc,@aParFin,@aVS9,@aVSE)' , 71 , 11 , 'oVlFinanc' , 'nVlFinanc' , cValPict , 50 , 1 , '+' , ( substr(cBotAten,1,1) == "1" ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finame                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjValNeg, {'oBtnFiname' , STR0003 , 'VX002BTVLN("2",nOpc,@aParFna,@aVS9)'       , 71 , 11 , 'oVlFiname' , 'nVlFiname' , cValPict , 50 , 1 , '+' , ( substr(cBotAten,2,1) == "1" ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Financiamento Proprio   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjValNeg, {'oBtnFinPro' , STR0004 , 'VX002BTVLN("3",nOpc,@aParPro,@aVS9)'       , 71 , 11 , 'oVlFinPro' , 'nVlFinPro' , cValPict , 50 , 1 , '+' , ( substr(cBotAten,3,1) == "1" ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consorcio               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjValNeg, {'oBtnConsor' , STR0005 , 'VX002BTVLN("4",nOpc,@aParCon,@aVS9,@aVSE)' , 71 , 11 , 'oVlConsor' , 'nVlConsor' , cValPict , 50 , 1 , '+' , ( substr(cBotAten,4,1) == "1" ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Veiculo Usado           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjValNeg, {'oBtnVeiUsa' , STR0006 , 'VX002BTVLN("5",nOpc,@aParUsa,@aVS9)'       , 71 , 11 , 'oVlVeicUs' , 'nVlVeicUs' , cValPict , 50 , 1 , '+' , ( substr(cBotAten,5,1) == "1" ) } )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Entradas                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjValNeg, {'oBtnEntrad' , STR0007 , 'VX002BTVLN("6",nOpc,@aParEnt,@aVS9,@aVSE)' , 71 , 11 , 'oVlEntrad' , 'nVlEntrad' , cValPict , 50 , 1 , '+' , ( substr(cBotAten,6,1) == "1" ) } )
Else
	nVlFinanc := 0
	nVlFinPro := 0
	nVlFiname := 0
	nVlConsor := 0
	nVlVeicUs := 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Entradas                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AADD(aObjValNeg, {'oBtnEntrad' , STR0007 , 'VX002BTVLN("6",nOpc,@aParEnt,@aVS9,@aVSE)' , 71 , 11 , 'oVlEntrad' , 'nVlEntrad' , cValPict , 50 , 1 , '+' , ( substr(cBotAten,6,1) == "1" ) } )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria e Inicializa Var. Private dos Botoes ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntFor := 1 to Len(aObjValNeg)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Get's de valores de negociacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aObjValNeg[nCntFor,6])
		SetPrvt(AllTrim(aObjValNeg[nCntFor,6]))
		SetPrvt(AllTrim(aObjValNeg[nCntFor,7]))
		&(AllTrim(aObjValNeg[nCntFor,7]) + ' := 0')
	EndIf
Next nCntFor

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Log de Alteracoes ...                                      ³
//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
//³ aLogAlter[01,NN] - Campos da Tabela VV0                    ³
//³ aLogAlter[02,NN] - Campos da Tabela VVA                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aLogAlter := {{},{}}
Private aVLogAlter := {{},{}} // Controla os valores dos campos que geram log
Private lLogAlter := (GetNewPar("MV_LOGALTV","N") == "S")
Private cVVAChvLog := ""

If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )
	cVVAChvLog := "VVA_ITETRA"
Else
	cVVAChvLog := "RecNo()"
EndIf

AADD(aLogAlter[1],"VV0_VALMOV")
AADD(aLogAlter[1],"VV0_VALTOT")
AADD(aLogAlter[2],"VVA_CHASSI")
AADD(aLogAlter[2],"VVA_VALTAB")
AADD(aLogAlter[2],"VVA_VALMOV")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera qualquer montagem previa do fiscal     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MaFisEnd()

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Variavel interna para funcionamento correto dos campos MEMOS na Visualizacao por outras Rotinas              //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
If nOpc == 2 .and. !( FunName() $ "VEIXA018/VEIXA019" ) // Necessario utilizar a funcao FUNNAME (chamada no MENU)
	SetStartMod(.t.)
Endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

RegToMemory("VV9",.f.)
RegToMemory("VV0",.f.)
RegToMemory("VVA",.f.)

VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ VZ7 - Acoes de Venda                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cVAI_VZ7 := ""
If lIntLoja .and. nAVEIMAX > 1	// NAO UTILIZAR TROCO e VENDA AGREGADA quando Integrado com o LOJA e Qtde de veiculos maior que 1.
	cVAI_VZ7 += "0" // Visualiza/Inclui/Altera ( Troco )
	cVAI_VZ7 += "0" // Visualiza/Inclui/Altera ( Venda Agregadas )
Else
	cVAI_VZ7 += VAI->VAI_VZ7TRO // Visualiza/Inclui/Altera ( Troco )
	cVAI_VZ7 += VAI->VAI_VZ7VDA // Visualiza/Inclui/Altera ( Venda Agregadas )
EndIf
cVAI_VZ7 += VAI->VAI_VZ7COR // Visualiza/Inclui/Altera ( Cortesias )
cVAI_VZ7 += VAI->VAI_VZ7RED // Visualiza/Inclui/Altera ( Redutores )

// Carrega as var. que controlam os campos que serão exibidos e poderão ser alterados
VX002FCPO("VV9",@cVV9NEdit,@cVV9NMostra,)
VX002FCPO("VV0",@cVV0NEdit,@cVV0NMostra,@cCpoVV0Alt)
VX002FCPO("VVA",@cVVANEdit,@cVVANMostra,)
M->VVA_VALTAB := 0
If VVA->(ColumnPos("VVA_ITETRA")) <= 0
	M->VVA_ITETRA := ""
EndIf
//

// Carrega Dicionario das tabelas VV9, VV0 e VVA
VX002DIC(nOpc)
//
If INCLUI .and. aInfCliente[1] .and. ! lXX002Auto
	M->VV9_CODCLI := aInfCliente[2] // Codigo do Cliente
	M->VV9_LOJA   := aInfCliente[3] // Loja do Cliente
	M->VV9_NOMVIS := aInfCliente[4] // Nome do Cliente
	M->VV9_TELVIS := aInfCliente[5] // Telefone do Cliente
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega Matrizes com Tabelas Acessorias ao Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VX002X3LOAD( "VS9" , .t. , @aVS9 , 1 , "VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE", xFilial("VS9")+PadR(M->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"V")
VX002X3LOAD( "VSE" , .t. , @aVSE )
VX002X3LOAD( "VSE" , .t. , @aVSETotal , 1 , "VSE_FILIAL+VSE_NUMIDE+VSE_TIPOPE" , xFilial("VSE")+PadR(M->VV9_NUMATE,TamSX3("VSE_NUMIDE")[1]," ")+"V" )
VX002X3LOAD( "VZ7" , .t. , @aVZ7 )
//

If nVerAten == 2 .or. lXX002Auto // Versao 2
	oGetDadVVA:aHeader := aClone(aHeaderVVA)
	oGetDadVVA:aCols := aClone(aColsVVA)
	oGetDadVVA:nAt := 1
	If Len(aColsVVA) > 1
		VX002ExibeHelp("VX002ERR006", STR0142) // Atendimento com mais de um veiculo, verificar o parametro MV_AVEIMAX. / Atencao
		Return
	EndIf
EndIf


////////////////////////////////////

	VISUALIZA := ( nOpc == 2 )
	INCLUI 	  := ( nOpc == 3 )
	ALTERA 	  := ( nOpc == 4 )
	EXCLUI 	  := ( nOpc == 5 )

////////////////////////////////////

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Variaveis para Configuracao da Janela Principal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lXX002Auto
	If lLayoutFolder
		AADD( aObjects, { 100, 070, .T., .F. } ) // Enchoices (VV9 e VV0)
		AADD( aObjects, { 100, 100, .T., .T. } ) // Objeto Folder

		//AADD( aObjFolder, { 000, 000, .T., .F. } ) // GetDados (VVA) // Adiciona linha sem dimensao
		AADD( aObjFolder, { 100, 100, .T., .T. } ) // Botoes / Resumo Financeiro e Composicao de Parcelas
		If substr(cVAI_VZ7,1,4) <> "0000" // Troco / Vendas Agregadas / Cortesias / Redutores
			AADD( aObjFolder, { 100, 052, .T., .F. } ) // ListBox VZ7
		Else
			AADD( aObjFolder, { 000,  000, .T., .F. } ) // ListBox VZ7 ( NAO mostrar )
		EndIf

	Else
		If nVerAten == 2 // Versao 2
			AADD( aObjects, { 100, 070, .T., .F. } ) // Enchoices (VV9 e VV0)
			AADD( aObjects, { 000, 000, .T., .F. } ) // GetDados (VVA) // Adiciona linha sem dimensao
		Else
			AADD( aObjects, { 100, 067, .T., .F. } ) // Enchoices (VV9 e VV0)
			If nAVEIMAX == 1
				AADD( aObjects, { 100, 032, .T., .F. } ) // GetDados (VVA)
			ElseIf nAVEIMAX == 2
				AADD( aObjects, { 100, 040, .T., .F. } ) // GetDados (VVA)
			Else
				AADD( aObjects, { 100, 048, .T., .F. } ) // GetDados (VVA)
			EndIf
		EndIf
		AADD( aObjects, { 100,  100, .T., .T. } ) // Botoes / Resumo Financeiro e Composicao de Parcelas
		If substr(cVAI_VZ7,1,4) <> "0000" // Troco / Vendas Agregadas / Cortesias / Redutores
			If nVerAten == 2 // Versao 2
				AADD( aObjects, { 100, 078, .T., .F. } ) // ListBox VZ7
			Else
				AADD( aObjects, { 100, 052, .T., .F. } ) // ListBox VZ7
			EndIf
		Else
			AADD( aObjects, { 000,  000, .T., .F. } ) // ListBox VZ7 ( NAO mostrar )
		EndIf
	EndIf

	AADD( aObjEnchoice, { 40, 100, .T., .T. } ) // Enchoice - VV9
	AADD( aObjEnchoice, { 50, 100, .T., .T. } ) // Enchoice - VV0

	AADD( aObjFinanc, { 140, 010, .F., .T. } ) // Valores da Negociacao
	AADD( aObjFinanc, { 035, 010, .T., .T. } ) // Composicao das Parcelas
	AADD( aObjFinanc, { 105, 010, .F., .T. } ) // Taxa do Dia

	If substr(cVAI_VZ7,1,1) <> "0"
		AADD( aObjLBoxVZ7, { 025, 100, .T., .T. } ) // Listbox (VZ7) - Troco
	Else
		AADD( aObjLBoxVZ7, { 000, 000, .T., .F. } ) // ListBox VZ7 - Troco ( NAO mostrar )
	EndIf
	If substr(cVAI_VZ7,2,1) <> "0"
		AADD( aObjLBoxVZ7, { 038, 100, .T., .T. } ) // Listbox (VZ7) - Vendas Agregadas
	Else
		AADD( aObjLBoxVZ7, { 000, 000, .T., .F. } ) // ListBox VZ7 - Vendas Agregadas ( NAO mostrar )
	EndIf
	If substr(cVAI_VZ7,3,1) <> "0"
		AADD( aObjLBoxVZ7, { 025, 100, .T., .T. } ) // Listbox (VZ7) - Cortesia
	Else
		AADD( aObjLBoxVZ7, { 000, 000, .T., .F. } ) // ListBox VZ7 - Cortesia ( NAO mostrar )
	EndIf
	If substr(cVAI_VZ7,4,1) <> "0"
		AADD( aObjLBoxVZ7, { 025, 100, .T., .T. } ) // Listbox (VZ7) - Redutor
	Else
		AADD( aObjLBoxVZ7, { 000, 000, .T., .F. } ) // ListBox VZ7 - Redutor ( NAO mostrar )
	EndIf

	AADD( aObjVlrNeg, { 010, 019, .T., .F. } ) // Valor da Venda
	AADD( aObjVlrNeg, { 010, 010, .T., .T. } ) // Scroll com Botao de Opcoes
	AADD( aObjVlrNeg, { 010, 019, .T., .F. } ) // Valor Total das Entradas / Saldo Restante ou Devolucao ou Troco

	AADD( aObjVlrTNeg , { 010, 010, .T., .T. } )
	AADD( aObjVlrTNeg , { 056, 010, .F., .T. } )

	AADD( aObjSimul, { 010, 014, .T., .F. } ) // Valor da Simulacao
	AADD( aObjSimul, { 010, 010, .T., .T. } ) // Listbox com Taxas
	AADD( aObjSimul, { 010, 012, .T., .F. } ) // Botoes TX Padrao e Utilizar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Divisao principal da Tela                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAuxPOPri := MsObjSize( { aSizeAut[ 1 ] , aSizeAut[ 2 ] ,aSizeAut[ 3 ] , aSizeAut[ 4 ] , 1 , 1 } , aObjects , .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a TELA do Atendimento                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlgAtend := MSDIALOG():New(aSizeAut[7],0,aSizeAut[6],aSizeAut[5],cCadastro,,,,128,,,,,.t.)
	oDlgAtend:lEscClose := .F.

	If lLayoutFolder
		oFolXX2 := TFolder():New(aAuxPOPri[2,1], aAuxPOPri[2,2], { "Veículos" , "Negociação" }, , oDlgAtend, , , , .t. , , aAuxPOPri[2,4], aAuxPOPri[2,3]-aAuxPOPri[2,1] )
		aPOFolder := MsObjSize( { 2 , 2 , (oFolXX2:nClientWidth / 2 ) - 4 , ( oFolXX2:nClientHeight / 2 ) - 15 , 0, 2 } , aObjFolder , .T. )
		aPOPri := {}
		AADD( aPOPri , aClone(aAuxPOPri[1]) )
		AADD( aPOPri , { 2 , 2 , 10 , 10 } ) // GetDados VVA - Definido somente para dar erro...
		aEval( aPOFolder, { |aPos| AADD( aPOPri , aClone(aPos) ) } )
	//	aEval( aPOFolder, { |aPos| AADD( aPOPri , aClone(aPos) ) } )
	Else
		aPOPri := aClone(aAuxPOPri)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicao das Enchoices                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPOEnc := MsObjSize( { aPOPri[1,2] , aPOPri[1,1] , aPOPri[1,4] , aPOPri[1,3] , 1, 1 } , aObjEnchoice , .T. , .T. )

	If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )
		// Posicao da GetDados
		aPOGetDad := MsObjSize( { aPOPri[2,2] , aPOPri[2,1] , aPOPri[2,4] , aPOPri[2,3] , 1, 1 } , {{ 10 , 10 , .T. , .T. }} , .T. , .T. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicao: Valores de Negociacao, Resumo Financeiro e Taxa do Dia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPOFinanc := MsObjSize( { aPOPri[3,2] , aPOPri[3,1] , aPOPri[3,4] , aPOPri[3,3] , 1, 1 } , aObjFinanc , .T. , .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicao das Listbox (VZ7)                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPOVZ7 := MsObjSize( { aPOPri[4,2] , aPOPri[4,1] , aPOPri[4,4] , aPOPri[4,3] , 1, 1 } , aObjLBoxVZ7 , .T. , .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicao dos Objetos dentro de Valores de Negociacao             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPOVlrNeg := MsObjSize( { aPOFinanc[1,2]+2 , aPOFinanc[1,1]+5 , aPOFinanc[1,4]-2 , aPOFinanc[1,3] , 1, 1 } , aObjVlrNeg , .T. )

	aPOVlrTVal := MsObjSize( { aPOVlrNeg[1,2]+2 , aPOVlrNeg[1,1] , aPOVlrNeg[1,4]-2 , aPOVlrNeg[1,3] , 1, 1 } , aObjVlrTNeg , .T. , .T. )
	aPOVlrTNeg := MsObjSize( { aPOVlrNeg[3,2]+2 , aPOVlrNeg[3,1] , aPOVlrNeg[3,4]-2 , aPOVlrNeg[3,3] , 1, 1 } , aObjVlrTNeg , .T. , .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posicao dos Objetos dentro da Simulacao / Taxa do Dia           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aPOSimul  := MsObjSize( { aPOFinanc[3,2]+2 , aPOFinanc[3,1]+5 , aPOFinanc[3,4]-2 , aPOFinanc[3,3] , 1, 1 } , aObjSimul , .T. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Enchoice da VV9                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcVV9 := nOpc
	If cVV9Status $ "P,O,L,F,C" .or. VX0020013_AtendimentoDePedidoVenda(INCLUI , M->VV9_NUMATE) // Pendente Aprovacao, Pre-Aprovado, Aprovado, Finalizado ou Cancelado
		nOpcVV9 := 2 // Visualizar
	EndIf
	oTPanelVV9 := TPanel():New(aPOEnc[1,1] ,aPOEnc[1,2],"",oDlgAtend,NIL,.T.,.F.,NIL,NIL,aPOEnc[1,4]-aPOEnc[1,2],aPOEnc[1,3]-aPOEnc[1,1],.T.,.F.)
	oEnchVV9 := MSMGet():New( "VV9" , nReg , nOpcVV9 ,;
		/* aCRA */, /* cLetra */, /* cTexto */, aCpoVV9, aPOEnc[1], aCpoVV9Alt, nModelo,;
		/* nColMens */, /* cMensagem */, cTudoOk, oTPanelVV9, lF3, lMemoria, .t. /* lColumn */ ,;
		caTela, .t. /* lNoFolder */, lProperty)
	oEnchVV9:oBox:Align := CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Enchoice da VV0                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpcVV0 := nOpc
	If cVV9Status $ "F,C" .or. VX0020013_AtendimentoDePedidoVenda(INCLUI , M->VV9_NUMATE)  // Finalizado ou Cancelado
		nOpcVV0 := 2 // Visualizar
	EndIf
	oEnchVV0 := MSMGet():New( "VV0", nRegVV0 , nOpcVV0 ,;
		/* aCRA */, /* cLetra */, /* cTexto */, aCpoVV0, aPOEnc[2], aCpoVV0Alt, nModelo,;
		/* nColMens */, /* cMensagem */, cTudoOk, oDlgAtend, lF3, lMemoria, .t. /* lColumn */ ,;
		caTela, .f. /* lNoFolder */, lProperty)

	////////////////////////////////////

		VISUALIZA := ( nOpc == 2 )
		INCLUI 	  := ( nOpc == 3 )
		ALTERA 	  := ( nOpc == 4 )
		EXCLUI 	  := ( nOpc == 5 )

	////////////////////////////////////
	If lLayoutFolder
		oWinObjVVA := oFolXX2:aDialogs[1]
		oWinObjNeg := oFolXX2:aDialogs[2]
	Else
		oWinObjVVA := oWinObjNeg := oDlgAtend
	EndIf

	If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )

		// Monta Enchoice da VVA
		cLinOkVVA := "AlwaysTrue()"
		cTudOkVVA := "AlwaysTrue()"
		cFldOkVVA := "VX002FOK("+AllTrim(Str(nOpc))+")"
		cDelOkVVA := "VX002DELAC("+AllTrim(Str(nOpc))+",.t.,.t.)"
		oGetDadVVA := MsNewGetDados():New(aPOGetDad[1,1],aPOGetDad[1,2],aPOGetDad[1,3],aPOGetDad[1,4],;
			IIf( VISUALIZA .or. nOpcVV9 == 2 , 0 , GD_DELETE + GD_UPDATE ) ,; // Somente Alteração
			cLinOkVVA,;
			cTudOkVVA,;
			,;
			aCpoVVAAlt ,; 	// Campos alteraveis da GetDados
			/* nFreeze */,;	// Campos estaticos da GetDados
			999 ,;
			cFldOkVVA,;
			/* cSuperDel */,; 	// Funcao executada quando pressionado <Ctrl>+<Del>
			cDelOkVVA,; 		// Funcao executada para validar a exclusao de uma linha
			oWinObjVVA,;
			aHeaderVVA ,;
			aColsVVA)
		If lLayoutFolder
			oGetDadVVA:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
		EndIf
		oGetDadVVA:oBrowse:bChange   := { || VX002CHANG() }
		oGetDadVVA:oBrowse:bGotFocus := { || VX002CHANG() }

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Configura Valores de Negociacao                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOFinanc[1,1],aPOFinanc[1,2] TO aPOFinanc[1,3],aPOFinanc[1,4] LABEL STR0016 OF oWinObjNeg PIXEL // Valores da Negociacao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Botoes utilizados na Enchoice                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBotAtF7 := GetNewPar("MV_BOTATF7","1")
	Do Case
		Case cBotAtF7 == "1" // Perua
			cBotAtF7 := "CARGA"
		Case cBotAtF7 == "2" // 2 Carros
			cBotAtF7 := "PAPIMG32.PNG"
		Case cBotAtF7 == "3" // Carro e Caminhao
			cBotAtF7 := "VEIIMG32.PNG"
		Case cBotAtF7 == "4" // Caminhao
			cBotAtF7 := "TMSIMG32.PNG"
		Case cBotAtF7 == "5" // Trator
			cBotAtF7 := "AGRIMG32.PNG"
		Case cBotAtF7 == "6" // Ambulancia
			cBotAtF7 := "HSPIMG32.PNG"
		Case cBotAtF7 == "7" // Empilhadeira
			cBotAtF7 := "EMPILHADEIRA"
		Case cBotAtF7 == "8" // Chave
			cBotAtF7 := "CHAVE2"
	EndCase
	If FindFunction("IsHtml")
		If !IsHtml() // Nao esta utilizando SmartClient HTML
			aLogo := Directory(cDirFotos+"VLOGOATEND.png","S") // 36pix X 36pix
			If len(aLogo) <= 0
				aLogo := Directory(cDirFotos+"VLOGOATEND.jpg","S") // 36pix X 36pix
			EndIf
		EndIf
	EndIf
	If len(aLogo) > 0
		oBitMapVei := TBtnBmp2():New((aPOVlrTVal[1,1]+1)*2,(aPOVlrTVal[1,2]-1)*2,36,36,"XXX",,,,{|| VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,,.t.,0) },oWinObjNeg,"<F7> "+STR0042,,.T.) // Veiculos
		oBitMapAux := TBitmap():New((aPOVlrTVal[1,1]+1),(aPOVlrTVal[1,2]-1),18,18,,cDirFotos+aLogo[1,1],.T.,oWinObjNeg,,,.F.,.F.,,,.F.,,.T.,,.F.)
	Else
		oBitMapVei := TBtnBmp2():New((aPOVlrTVal[1,1]+1)*2,(aPOVlrTVal[1,2]-1)*2,36,36,cBotAtF7,,,,{|| VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,,.t.,0) },oWinObjNeg,"<F7> "+STR0042,,.T.) // Veiculos
	EndIf
	@ aPOVlrTVal[1,1]     , aPOVlrTVal[1,2]+20 SAY (STR0017+": ") OF oWinObjNeg PIXEL COLOR CLR_HBLUE // Vlr.Veiculo(s)
	@ aPOVlrTVal[1,1] + 7 , aPOVlrTVal[1,2]+20 MSGET oVlVeicu VAR nVlVeicu PICTURE cValPict SIZE 50,1 OF oWinObjNeg VALID VX002VALVEI(nOpc,.t.) PIXEL HASBUTTON ;
			WHEN ( !cVV9Status $ "F/P/O/L/C" .and. (nOpc == 3 .or. nOpc == 4) .and. nVerAten == 2 ) // Nao Habilitar campo quando Atendimento estiver Finalizado / Pendente Aprovacao / Pre-Aprvado / Aprovado / Cancelado
	@ aPOVlrTVal[2,1]     , aPOVlrTVal[2,2] SAY (STR0018+": ") OF oWinObjNeg PIXEL COLOR CLR_HBLUE // Vlr.Atendimento
	@ aPOVlrTVal[2,1] + 7 , aPOVlrTVal[2,2] MSGET oVlAtend VAR nVlAtend PICTURE cValPict SIZE 50,1 OF oWinObjNeg PIXEL HASBUTTON WHEN .F.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Botoes de Visualizacao de Mapa de Avaliacao                    ³
	//³ Visualizar MAPA somente se usuario tiver permissao             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If FGX_USERVL( xFilial("VAI"),__cUserID, "VAI_MAPVEI", "==" ,"1") // Usuario ver Mapa de Avaliacao
		oMapaBom := TBtnBmp2():New( (aPOVlrTVal[1,1]+7) * 2 ,(aPOVlrTVal[2,2]+50) * 2,20,20,'BR_VERDE',,,,{|| FM_MAPAVAL(1,,M->VV9_NUMATE,.t.,80,,) },oWinObjNeg,STR0019,,.T.) // qmt_ok // Visualiza o Mapa de Avaliacao de Resultado
		oMapaMed := TBtnBmp2():New( (aPOVlrTVal[1,1]+7) * 2 ,(aPOVlrTVal[2,2]+50) * 2,20,20,'BR_AMARELO',,,,{|| FM_MAPAVAL(1,,M->VV9_NUMATE,.t.,80,,) },oWinObjNeg,STR0019,,.T.) // qmt_cond // Visualiza o Mapa de Avaliacao de Resultado
		oMapaRui := TBtnBmp2():New( (aPOVlrTVal[1,1]+7) * 2 ,(aPOVlrTVal[2,2]+50) * 2,20,20,'BR_VERMELHO',,,,{|| FM_MAPAVAL(1,,M->VV9_NUMATE,.t.,80,,) },oWinObjNeg,STR0019,,.T.) // qmt_no // Visualiza o Mapa de Avaliacao de Resultado
	Else
		oMapaBom := TBtnBmp2():New( (aPOVlrTVal[1,1]+7) * 2 ,(aPOVlrTVal[2,2]+50) * 2,20,20,'BR_VERDE',,,,{|| MsgStop(STR0020,STR0011) },oWinObjNeg,STR0019,,.T.) // qmt_ok // Usuario sem permissao! / Atencao / Visualiza o Mapa de Avaliacao de Resultado
		oMapaMed := TBtnBmp2():New( (aPOVlrTVal[1,1]+7) * 2 ,(aPOVlrTVal[2,2]+50) * 2,20,20,'BR_AMARELO',,,,{|| MsgStop(STR0020,STR0011) },oWinObjNeg,STR0019,,.T.) // qmt_cond // Usuario sem permissao! / Atencao / Visualiza o Mapa de Avaliacao de Resultado
		oMapaRui := TBtnBmp2():New( (aPOVlrTVal[1,1]+7) * 2 ,(aPOVlrTVal[2,2]+50) * 2,20,20,'BR_VERMELHO',,,,{|| MsgStop(STR0020,STR0011) },oWinObjNeg,STR0019,,.T.) // qmt_no // Usuario sem permissao! / Atencao / Visualiza o Mapa de Avaliacao de Resultado
	EndIf
EndIf // lXX002Auto


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Roda o Mapa para ver a caretinha atual... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !INCLUI
	VX002MAPAV()
EndIf

If ! lXX002Auto

	oScrollVlNeg := TScrollBox():New( oWinObjNeg , aPOVlrNeg[2,1] , aPOVlrNeg[2,2] , aPOVlrNeg[2,3] - aPOVlrNeg[2,1] ,aPOVlrNeg[2,4] - aPOVlrNeg[2,2] , .t. , , .t. )

	nAuxLinha += 1
	For nCntFor := 1 to Len(aObjValNeg)

		If aObjValNeg[nCntFor,12] // Habilita Botoes do Atendimento //

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Botoes de valores de negociacao ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aObjValNeg[nCntFor,1])
				&(aObjValNeg[nCntFor,1]) := TButton():New( nAuxLinha /* <nRow> */, nColBut /* <nCol> */, aObjValNeg[nCntFor,2] /* <cCaption> */, oScrollVlNeg /* <oWnd> */,;
					&('{ || ' + aObjValNeg[nCntFor,3] + ' }')	/* <{uAction}> */, aObjValNeg[nCntFor,4] /* <nWidth> */, aObjValNeg[nCntFor,5] /* <nHeight> */, /* <nHelpId> */, /* <oFont> */, /* <.default.> */,;
					.t.	/* <.pixel.> */, /* <.design.> */, /* <cMsg> */, /* <.update.> */, /* <{WhenFunc}> */,;
					/* <{uValid}> */, /* <.lCancel.> */	)
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Get's de valores de negociacao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !Empty(aObjValNeg[nCntFor,6])
				&(aObjValNeg[nCntFor,6]) := TGet():New( nAuxLinha /* <nRow> */, nColMSGet /* <nCol> */, ;
					&('{ | U | IF( PCOUNT() == 0,'+aObjValNeg[nCntFor,7]+','+aObjValNeg[nCntFor,7]+' := U ) }') /* bSETGET(<uVar>) */,;
					oScrollVlNeg /* [<oWnd>] */, aObjValNeg[nCntFor,9] /* <nWidth> */, aObjValNeg[nCntFor,10]/* <nHeight> */, aObjValNeg[nCntFor,8]/* <cPict> */, /* <{ValidFunc}> */,;
					/* <nClrFore> */, /* <nClrBack> */, /* <oFont> */, /* <.design.> */,;
					/* <oCursor> */, .t. /* <.pixel.> */, /* <cMsg> */, /* <.update.> */, { || .f. } /* <{uWhen}> */,;
					/* <.lCenter.> */, /* <.lRight.> */,;
					/* [\{|nKey, nFlags, Self| <uChange>\}] */, /* <.readonly.> */,;
					/* <.pass.> */ ,/* <cAlias> */,/* <(uVar)> */,,/* [<.lNoBorder.>] */, /* [<nHelpId>] */, .t. /* [<.lHasButton.>] */ )
			EndIf

			nAuxLinha += 12

		EndIf

	Next nCntFor

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Total Valor Negociado  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVlrTNeg[2,1]  , aPOVlrTNeg[2,2] SAY (STR0021+": ") OF oWinObjNeg PIXEL COLOR CLR_HBLUE // Total Pagtos
	@ aPOVlrTNeg[2,1]+7, aPOVlrTNeg[2,2] MSGET oVlNegoc VAR nVlNegoc PICTURE cValPict SIZE 50,1 OF oWinObjNeg WHEN .f. PIXEL HASBUTTON

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Total Devolucao        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVlrTNeg[1,1]  , aPOVlrTNeg[1,2] SAY oTitDevol VAR (STR0022+": ") SIZE 50,10 OF oWinObjNeg PIXEL COLOR CLR_HBLUE // Devolucao
	@ aPOVlrTNeg[1,1]+7, aPOVlrTNeg[1,2] MSGET oVlDevol VAR nVlDevol PICTURE cValPict SIZE 50,1 OF oWinObjNeg WHEN .f. PIXEL HASBUTTON
	oVlDevol:lVisible := .f.
	oTitDevol:lVisible := .f.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Total Saldo            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVlrTNeg[1,1]  , aPOVlrTNeg[1,2] SAY oTitSaldo VAR (STR0023+": ") SIZE 50,10 OF oWinObjNeg PIXEL COLOR CLR_HRED // Saldo Restante
	@ aPOVlrTNeg[1,1]+7, aPOVlrTNeg[1,2] MSGET oVlSaldo VAR nVlSaldo PICTURE cValPict SIZE 50,1 OF oWinObjNeg WHEN .f. PIXEL HASBUTTON
	oVlSaldo:lVisible := .f.
	oTitSaldo:lVisible := .f.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Composicao de Parcelas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOFinanc[2,1],aPOFinanc[2,2] TO aPOFinanc[2,3],aPOFinanc[2,4] LABEL STR0025 OF oWinObjNeg PIXEL // Composicao das Parcelas
	@ aPOFinanc[2,1]+8,aPOFinanc[2,2]+2 LISTBOX oLboxCParc FIELDS HEADER STR0024,STR0026,STR0027,STR0028 COLSIZES 25,35,80,160 SIZE aPOFinanc[2,4] - aPOFinanc[2,2] - 4 , aPOFinanc[2,3] - aPOFinanc[2,1] - 10  OF oWinObjNeg PIXEL ; // Data / Valor / Tipo / Observacao
		ON DBLCLICK VX002DTVS9(nOpc,M->VV9_NUMATE,@aVS9,oLboxCParc:aArray[oLboxCParc:nAt,5],oLboxCParc:aArray[oLboxCParc:nAt,3],oLboxCParc:aArray[oLboxCParc:nAt,4]) // ( nOPC , Nro.Atendimento , @aVS9 , RECNO VS9 , Titulo da Janela Parambox , Observacoes do Titulo )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Config. da Taxa do Dia ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOFinanc[3,1],aPOFinanc[3,2] TO aPOFinanc[3,3],aPOFinanc[3,4] LABEL STR0029 OF oWinObjNeg PIXEL // Taxa do Dia
	@ aPOSimul[1,1] + 3,aPOSimul[1,2] SAY STR0026 OF oWinObjNeg PIXEL COLOR CLR_HBLUE // Valor
	@ aPOSimul[1,1] + 2,aPOSimul[1,2] + 20 MSGET oFlVlFinanc VAR nFlVlFinanc PICTURE cValPict SIZE (aPOSimul[1,4] - aPOSimul[1,2] - 20),1 OF oWinObjNeg PIXEL HASBUTTON WHEN .f.
	@ aPOSimul[2,1] , aPOSimul[2,2] LISTBOX oLboxSimFina FIELDS HEADER STR0027,"  X",STR0030 COLSIZES 40,15,20 ; // Tipo / Vlr.Parcelas
		SIZE aPOSimul[2,4] - aPOSimul[2,2], aPOSimul[2,3] - aPOSimul[2,1] OF oWinObjNeg PIXEL

	nTamBot := (aPOSimul[3,4] - aPOSimul[3,2]) / 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Volta Taxa Padrao / Utiliza Financiamento selecionado ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOSimul[3,1],aPOSimul[3,2] BUTTON oBtnTxVolt PROMPT STR0031 OF oWinObjNeg SIZE nTamBot,10 PIXEL ACTION ( VX005TXPAD(@aParFin,@aSimFinanc) , VX002ATTELA(M->VV9_NUMATE) ) WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. !( cVV9Status $ "PLOFC" ) ) // Taxa Padrao
	@ aPOSimul[3,1],aPOSimul[3,2]+nTamBot+1 BUTTON oBtnTxUtil PROMPT STR0032 OF oWinObjNeg SIZE nTamBot,10 PIXEL ACTION IIf( VX005TXUTIL(@aParFin, @aVS9, @aVSE, @aSimFinanc, oLBoxSimFina:nAT) , ( VX002RPGRV("1",@aParFin,@aVS9,@aVSE) , VX002GRV(nOpc,.f.,"VS9/VSE",@aVS9,@aVSE) ) , .t. ) WHEN ( ( nOpc == 3 .or. nOpc == 4 ) .and. !( cVV9Status $ "PLOFC" ) ) // Utilizar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Box dos Listbox Acao de Vendas  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVZ7[1,1],aPOVZ7[1,2] TO aPOVZ7[Len(aPOVZ7),3],aPOVZ7[len(aPOVZ7),4] OF oWinObjNeg PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Listbox de TROCO                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVZ7[1,1] + 2,aPOVZ7[1,2] + 2 LISTBOX oLboxTroco FIELDS ;
		HEADER IIf( nVerAten == 2 , "" , STR0143), STR0038,STR0026 ;
		COLSIZES IIf( nVerAten == 2 , 0 , 15 ) , ( aPOVZ7[1,4] - aPOVZ7[1,2] - 60 ),35 SIZE aPOVZ7[1,4] - aPOVZ7[1,2] - 2 , aPOVZ7[1,3] - aPOVZ7[1,1] - 4 OF oWinObjNeg PIXEL ; // Troco / Valor
		ON DBLCLICK IIf( VX002VLVEID(nOpc,.t.) , IIf(substr(cVAI_VZ7,1,1)=="2" , ;
						IIf( VEIXX003(nOpcVV9,.t.,@aParVZ7,"0",@aVZ7,M->VVA_ITETRA) , ;
							( VX002GRV(nOpc,.f.,"VZ7",,,@aVZ7) , IIF( nVerAten == 3 , oGetDadVVA:Refresh() , .t. ) ) ,;
							.t. ),MsgStop(STR0034,STR0011)) , .t. ) // 0=Troco // Usuario sem permissao para Incluir/Alterar/Excluir Troco! / Atencao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Listbox de VENDAS AGREGADAS     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVZ7[2,1] + 2,aPOVZ7[2,2] LISTBOX oLboxVAgreg FIELDS ;
		HEADER IIf( nVerAten == 2 , "" , STR0143),STR0039,STR0026,STR0033,STR0066 ;
		COLSIZES IIf( nVerAten == 2 , 0 , 15 ) , ( aPOVZ7[2,4] - aPOVZ7[2,2] - 130 ),35,40,35 SIZE aPOVZ7[2,4] - aPOVZ7[2,2] , aPOVZ7[2,3] - aPOVZ7[2,1] - 4 OF oWinObjNeg PIXEL ; // Vendas Agregadas / Valor / Como Pagar / Tipo Titulo
		ON DBLCLICK IIf( VX002VLVEID(nOpc,.t.) , IIf(substr(cVAI_VZ7,2,1)=="2" , ;
						IIf( VEIXX003(nOpcVV9,.t.,@aParVZ7,"3",@aVZ7,M->VVA_ITETRA) ,;
							( VX002GRV(nOpc,.f.,"VZ7",,,@aVZ7) , IIF( nVerAten == 3 , oGetDadVVA:Refresh() , .t. ) ) ,;
							.t. ),MsgStop(STR0035,STR0011)) , .t. ) // 3=Venda Agregada // Usuario sem permissao para Incluir/Alterar/Excluir Venda Agregada! / Atencao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Listbox de CORTESIA             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVZ7[3,1] + 2,aPOVZ7[3,2] LISTBOX oLboxCortesia FIELDS ;
		HEADER IIf( nVerAten == 2 , "" , STR0143),STR0040,STR0026 ;
		COLSIZES IIf( nVerAten == 2 , 0 , 15 ) , ( aPOVZ7[3,4] - aPOVZ7[3,2] - 60 ),35 SIZE aPOVZ7[3,4] - aPOVZ7[3,2] , aPOVZ7[3,3] - aPOVZ7[3,1] - 4 OF oWinObjNeg PIXEL ; // Cortesia / Valor
		ON DBLCLICK IIf( VX002VLVEID(nOpc,.t.) , IIf(substr(cVAI_VZ7,3,1)=="2" , ;
						IIf( VEIXX003(nOpcVV9,.t.,@aParVZ7,"1",@aVZ7,M->VVA_ITETRA) , ;
							( VX002GRV(nOpc,.f.,"VZ7",,,@aVZ7) , IIF( nVerAten == 3 , oGetDadVVA:Refresh() , .t. ) ) ,;
							.t. ),MsgStop(STR0036,STR0011)) , .t. ) // 1=Cortesia // Usuario sem permissao para Incluir/Alterar/Excluir Cortesia! / Atencao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Listbox de REDUTOR              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ aPOVZ7[4,1] + 2,aPOVZ7[4,2] LISTBOX oLboxRedutor FIELDS ;
		HEADER IIf( nVerAten == 2 , "" , STR0143),STR0041,STR0026 ;
		COLSIZES IIf( nVerAten == 2 , 0 , 15 ) ,( aPOVZ7[4,4] - aPOVZ7[4,2] - 60 ),35 SIZE aPOVZ7[4,4] - aPOVZ7[4,2] - 2 , aPOVZ7[4,3] - aPOVZ7[4,1] - 4 OF oWinObjNeg PIXEL ; // / Valor
		ON DBLCLICK IIf( VX002VLVEID(nOpc,.t.) , IIf(substr(cVAI_VZ7,4,1)=="2" , ;
						IIf( VEIXX003(nOpcVV9,.t.,@aParVZ7,"2",@aVZ7,M->VVA_ITETRA) , ;
						( VX002GRV(nOpc,.f.,"VZ7",,,@aVZ7) , IIF( nVerAten == 3 , oGetDadVVA:Refresh() , .t. ) ) ,;
						.t. ),MsgStop(STR0037,STR0011)) , .t. ) // 2=Redutor // Usuario sem permissao para Incluir/Alterar/Excluir Redutor! / Atencao

	VX002HABIL(!INCLUI)
EndIf

If INCLUI
	If !Empty(aInfCliente[2]) // Codigo do Cliente

		If !VX002VISIT(nOpc)
			return .f.
		EndIf

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregando Vendedor ... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VAI->(dbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID))
	SA3->(dbSetOrder(1))
	SA3->(MsSeek(xFilial("SA3")+VAI->VAI_CODVEN))
	M->VV0_CODVEN := VAI->VAI_CODVEN
	M->VV0_NOMVEN := SA3->A3_NOME
	M->VV0_VENVDI := cVenVdaDir // Vendedor utilizado na integracao com o Venda Direta

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Aba de Impostos                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VX002ATFIS(.t.,.f.,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Valores de ListBox              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VX002ATTELA(M->VV9_NUMATE)

If ! lXX002Auto
	AADD(aBotEncAte, {"MAQFOTO",{|| VX002FOTO(nOpc) },("<F4> " + STR0141 )} ) // Foto(s)/Video(s) do Veiculo
	AADD(aBotEncAte, {cBotAtF7,{|| VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,,.t.,0) },("<F7> " + STR0042 )} ) // Veiculo(s)
	AADD(aBotEncAte, {"E5"    ,{|| VX002OPCOES(nOpc) },("<F10> " + STR0043 )} ) // Opcoes
	FM_NEWBOT("PVM011BTEN","aBotEncAte") // Ponto de Entrada para Manutencao do aBotEncAte - Definicao de Botoes na EnchoiceBar

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ SetKey das teclas <F4> <F7> <F10>        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SetKey(VK_F4,{|| VX002FOTO(nOpc) })
	SetKey(VK_F7,{|| VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,,.t.,0) })
	SetKey(VK_F10,{|| VX002OPCOES(nOpc) })

	If ALTERA .and. VV0->VV0_TIPFAT == "0" .and. FindFunction("VEIC130") // Alteracao de Atendimento para Veiculos Novos
		For nCntFor := 1 to len(aColsVVA)
			aAdd(aChaInts, aColsVVA[nCntFor,FG_POSVAR("VVA_CHAINT","aHeaderVVA")] )
		Next
		If Len(aChaInts) > 0
			VEIC130( aChaInts ) // Visualizar Bonus disponiveis para todos os Veiculos do Atendimento
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ACTIVATE MSDIALOG oDlgAtend ON INIT ...  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlgAtend:bInit := { || (EnchoiceBar(oDlgAtend,{|| IIf( VX002FAT(nOpc,aVS9) , oDlgAtend:End() , .f. ) }, {|| IIf( VX002SAIR(nOpc) , oDlgAtend:End() , .f. ) },,aBotEncAte) , IIf(INCLUI,VX002CONSV(.T.,nOpc,.f.,,.t.,0), .T. )) }
	oDlgAtend:Activate()
Else

//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// proc execauto
//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

	VX002CONOUT("VX002EXEC")

	If INCLUI .or. ALTERA

		If nAVEIMAX == 1
			If Len(aAutoItens) > 1
				VX002ExibeHelp("VX002ERR026","Quantidade de itens maior que a quantidade de itens permitido no atendimento.")
				lMsErroAuto := .t.
				Return .f.
			EndIf
		Else
			nAuxQtd := Len(oGetDadVVA:aCols)
			For nAuxLin := 1 to Len(aAutoItens)
				If aScan(aAutoItens[nAuxLin] , { |x| AllTrim(x[1]) == "AUTDELETA" }) <> 0
					nAuxQtd--
					Loop
				EndIf
				If aScan(aAutoItens[nAuxLin] , { |x| AllTrim(x[1]) == "LINPOS" }) <> 0
					Loop
				EndIf
				nAuxQtd++
			Next nAuxLin
			If nAuxQtd > nAVEIMAX
				VX002ExibeHelp("VX002ERR027","Quantidade de itens maior que a quantidade de itens permitido no atendimento.")
				lMsErroAuto := .t.
				Return .f.
			EndIf
		EndIf


		// ---------------------------------------------------- //
		// Ajusta Validacao dos campos da VVA                   //
		// ---------------------------------------------------- //
		cCpoAutoItens := ""
		For nAuxLin := 1 to Len(aAutoItens)
			For nAuxCol := 1 to Len(aAutoItens[nAuxLin])
				If ! cCpoAutoItens $ aAutoItens[nAuxLin,nAuxCol,1]
					cCpoAutoItens += aAutoItens[nAuxLin,nAuxCol,1] + "/"
				EndIf
			Next nAuxCol
		Next nAuxLin

		aSX3VVa := FWFormStruct(3,'VVA', { |cCampo| AllTrim(cCampo) $ cCpoAutoItens })[1]
		For nAuxLin := 1 to Len(aAutoItens)

			lExistSEGMOD := (aScan(aAutoItens[nAuxLin] , { |x| x[1] == "VVA_SEGMOD" }) <> 0 )
			lExistCHASSI := (aScan(aAutoItens[nAuxLin] , { |x| AllTrim(x[1]) $ "VVA_CHASSI/VVA_CHAINT" }) <> 0 )

			For nAuxCol := 1 to Len(aAutoItens[nAuxLin])

				cAuxValid := ""

				If AllTrim(aAutoItens[nAuxLin,nAuxCol,1]) $ "LINPOS/AUTDELETA"
					Loop
				EndIf

				// Ajusta VALID dos campos ...
				nAuxPos := AScan( aHeaderVVA , { |x| x[2] == aAutoItens[nAuxLin,nAuxCol,1] } )
				If nAuxPos > 0
					nAuxPosSX3 := aScan( aSX3VVa , { |x| x[3] == aHeaderVVA[nAuxPos, 2] } )
					If nAuxPosSX3 > 0
						cAuxValid := AllTrim( aSX3VVA [ nAuxPosSX3 ,15 ] ) // VALID do Dicionario de Dados
					EndIf
				EndIf
				//

				cAuxValid += IIf( !Empty(cAuxValid) , " .AND. " , "" ) + "VX002FOK("+AllTrim(Str(nOpc))+")"

				Do Case
				Case aAutoItens[nAuxLin,nAuxCol,1] == "VVA_MODVEI"
					If ! lExistSEGMOD .AND. ! lExistCHASSI
						cAuxValid += " .AND. VX002VeicExecAuto(," + cValToChar(nOpc) + ")"
					EndIf
					cAuxValid += " .AND. VX002ACOLS('" + aAutoItens[nAuxLin,nAuxCol,1] + "')"

				Case aAutoItens[nAuxLin,nAuxCol,1] $ "VVA_CHASSI/VVA_CHAINT"
					cAuxValid += " .AND. VX002ACOLS('" + aAutoItens[nAuxLin,nAuxCol,1] + "')"
					cAuxValid += " .AND. VX002VeicExecAuto(," + cValToChar(nOpc) + ")"

				Case lVVASEGMOD .and. aAutoItens[nAuxLin,nAuxCol,1] $ "VVA_SEGMOD"
					cAuxValid := "VX002VeicExecAuto(," + cValToChar(nOpc) + ")"

				Otherwise
					cAuxValid += " .AND. VX002ACOLS('" + aAutoItens[nAuxLin,nAuxCol,1] + "')"

				EndCase

				If ! Empty(cAuxValid)
					aAutoItens[nAuxLin,nAuxCol,3] := cAuxValid
				EndIf

				VX002Conout( "VALID",aAutoItens[nAuxLin,nAuxCol,1] + " - " + cAuxValid )

			Next nAuxCol
		Next nAuxLin

		// ---------------------------------------------------- //
		If INCLUI .or. (ALTERA .and. ! lAutoAvanca)

			If ! EnchAuto("VV9", aAutoVV9, { || .t. }, nOpc)
				lMsErroAuto := .t.
			EndIf

			If ! lMsErroAuto .and. ! EnchAuto("VV0", aAutoCab, { || .t. }, nOpc)
				lMsErroAuto := .t.
			EndIf

			aHeader := aClone(oGetDadVVA:aHeader)
			aCols := aClone(oGetDadVVA:aCols)
			N := 1
			If ! lMsErroAuto .and. ! MsGetDAuto( aAutoItens , "AlwaysTrue()", "AlwaysTrue()" , aAutoCab , nOpc , .t. )
				lMsErroAuto := .t.
				Return .f.
			EndIf

			If ! lMsErroAuto
				If (lCPagPad .or. (lVV0FPGPAD .and. M->VV0_FPGPAD == "1" )) .and. ! Empty(M->VV0_FORPAG)
					aParEnt[02] := nVlAtend
					SE4->(dbSetOrder(1))
					If SE4->(MsSeek(xFilial("SE4") + M->VV0_FORPAG))
						VX002Conout("VEIXX011","Condicao padrao")
						If ! VEIXX011(nOpc, @aParEnt, @aVS9, @aVSE, .t.)
							lMsErroAuto := .t.
							Return .f.
						EndIf
					EndIf
				ElseIf Len(aAutoVS9) > 0

					For nAuxLin := 1 to Len(aAutoVS9)
						If aAutoVS9[nAuxLin,1] == "6" .and. Len(aAutoVS9[nAuxLin,2]) > 0 // Entradas
							VX002Conout("VEIXX011","Entradas negociadas")
							If ! VEIXX011(nOpc, @aParEnt, @aVS9, @aVSE, .t., aAutoVS9[nAuxLin,2] )
								lMsErroAuto := .t.
								Return .f.
							EndIf
						EndIf
					Next nAuxLin

					VX002Conout("Saldo",cValToChar(nVlSaldo))
				EndIf
			EndIf

			// Se existir alguma linha deletada na GetDados, deve executar a funcao relacionada
			// a exclusao de item na getdados
			For nAuxLin := 1 to Len(aCols)
				If aCols[nAuxLin, Len(aCols[nAuxLin])]
					oGetDadVVA:nAt := nAuxLin
					n := nAuxLin
					VX002DELAC(nOpc,.f.,.t., .t.)
				EndIf
			Next nAuxLin

		ElseIf ALTERA .and. lAutoAvanca
			lMsErroAuto := .f.
		Else
			lMsErroAuto := .t.
		EndIf

		If ! lMsErroAuto
			If ALTERA .and. lAutoAvanca
				If ! VX002FAT(nOpc, aVS9)
					VX002Conout("AutoAvanca","ExecAuto VEIXX002 - Erro na gravacao")
					Return .f.
				EndIf
			Else
				If ! VX002TUDOK(nOpc,.f.)
					VX002Conout("AutoAvanca","ExecAuto VEIXX002 - Erro na gravacao")
					Return .f.
				EndIf
				If ! VX002GRV(nOpc,.f.,,aVS9,aVSE)
					VX002Conout("AutoAvanca","ExecAuto VEIXX002 - Erro na gravacao")
					Return .f.
				EndIf
				If aScan(aAutoCab, { |x| x[1] == "VV0_OBSENF"}) <> 0
					MSMM(VV0->VV0_OBSMNF,TamSx3("VV0_OBSENF")[1],,M->VV0_OBSENF,1,,,"VV0","VV0_OBSMNF")
					M->VV0_OBSMNF := VV0->VV0_OBSMNF
				EndIf
			EndIf
		EndIf

	ElseIf EXCLUI

		VX002CONOUT("Cancelando -> " + VV9->VV9_NUMATE)

		lMsErroAuto := .f.
		If ! VX002FAT(nOpc,aVS9, nOpcCanc, aMotCanc)
			VX002Conout("EXCLUSAO","ExecAuto VEIXX002 - Erro na gravacao")
			Return .f.
		EndIf

	EndIf


Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao do CEV ( Perseguicao )           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
	If !(M->VV9_STATUS $ "C/F")
		VX002CEV("A",M->VV9_NUMATE)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se houve alteracao que gera Log ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lLogAlter .and. !Empty(M->VV9_NUMATE)
	VX002LOG()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retira SetKey das teclas <F4> <F7> <F10> ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lXX002Auto
	SetKey(VK_F4, Nil )
	SetKey(VK_F7, Nil )
	SetKey(VK_F10, Nil )
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³ VX002HABIL º Autor ³ Rubens           º Data ³  04/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Habilita ou Nao Controles para Digitacao do Atendimento    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002HABIL(lHabilita)

If lXX002Auto
	Return
EndIf

If lHabilita
	oEnchVV0:Enable()
	oScrollVlNeg:Enable()
	oLboxTroco:Enable()
	oLboxVAgreg:Enable()
	oLboxCortesia:Enable()
	If type("oLboxRedutor") <> "U"
		oLboxRedutor:Enable()
	EndIf
	If type("oBtnFinLea") <> "U"
		oBtnTxVolt:Enable()
		oBtnTxUtil:Enable()
	EndIf
	oGetDadVVA:Enable()
Else
	oEnchVV0:Disable()
	oScrollVlNeg:Disable()
	oLboxTroco:Disable()
	oLboxVAgreg:Disable()
	oLboxCortesia:Disable()
	If type("oLboxRedutor") <> "U"
		oLboxRedutor:Disable()
	EndIf
	If type("oBtnFinLea") <> "U"
		oBtnTxVolt:Disable()
		oBtnTxUtil:Disable()
	EndIf
	oGetDadVVA:Disable()
EndIf
oEnchVV0:Refresh()
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³VX002VISITºAutor  ³ Rubens             º Data ³  04/01/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Seleciona o cliente e mostra os campos na tela             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002VISIT(nOpc)
Local lIniFiscal := .f.
Local nCntFor
Local oCliente   := DMS_Cliente():New()
dbSelectarea("SA1")
dbSetOrder(2)
If INCLUI .and. Empty(M->VV9_CODCLI+M->VV9_LOJA) .and. dbSeek(xFilial("SA1")+M->VV9_NOMVIS) .and. !ReadVar() $ "M->VV9_CODCLI/M->VV9_LOJA"
	If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
		Return .f.
	EndIf
	M->VV9_CODCLI := SA1->A1_COD
	M->VV9_LOJA   := SA1->A1_LOJA
	If Empty(M->VV9_TELVIS)
		M->VV9_TELVIS := SA1->A1_TEL
	EndIf
	M->VV9_TIPMID := "8" //Ja e' cliente
	If ReadVar() == "M->VV9_NOMVIS"
		M->VV0_TIPOCL := SA1->A1_TIPO
	EndIf
	lIniFiscal := .t.
Else
	dbSetOrder(1)
	If !Empty(M->VV9_CODCLI) .and. !Empty(M->VV9_LOJA)
		If dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA)
			If oCliente:Bloqueado( SA1->A1_COD , SA1->A1_LOJA , .T. ) // Cliente Bloqueado ?
				Return .f.
			EndIf
			If Empty(M->VV9_TELVIS) .or. !Empty(SA1->A1_TEL)
				M->VV9_TELVIS := SA1->A1_TEL
			EndIf
			M->VV9_NOMVIS := SA1->A1_NOME
			M->VV9_CODCLI := SA1->A1_COD
			M->VV9_LOJA   := SA1->A1_LOJA
			M->VV9_TIPMID := "8" //Ja e' cliente
			If ReadVar() $ "M->VV9_CODCLI/M->VV9_LOJA"
				M->VV0_TIPOCL := SA1->A1_TIPO
				If VV0->(ColumnPos("VV0_CLIENT")) <> 0
					M->VV0_CLIENT := SA1->A1_COD
					M->VV0_LOJENT := SA1->A1_LOJA
				EndIf
			EndIf
			lIniFiscal := .t.
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Credito do Cliente (RA/NCC/NCF)   ³
//³    RA  - Recebimento Antecipado (SE1)      ³
//³    NCC - Nota Credito Cliente (SE1)        ³
//³    NCF - Nota Credito Fornecedor (SE2)     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(M->VV9_CODCLI) .and. !Empty(M->VV9_LOJA) .and. ! lXX002Auto
	FM_CREDCLI(M->VV9_CODCLI,M->VV9_LOJA,"1")
EndIf

If INCLUI .or. ALTERA
	If lIniFiscal
		VX002INIFIS(SA1->A1_COD,SA1->A1_LOJA)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Valida se todos os campos OBRIGATORIOS da VV9 foram     ³
		//³ digitados, se sim e o cliente nao for cadastradao (SA1) ³
		//³ inicializa o fiscal pelo cliente padrao                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lIniFiscal := .t.
		For nCntFor:=1 to Len(aCpoVV9)
			If X3Obrigat(aCpoVV9[nCntFor]) .and. Empty(&("M->"+aCpoVV9[nCntFor]))
				lIniFiscal := .f.
				Exit
			EndIf
		Next
		If lIniFiscal
			VX002INIFIS(cCliPadrao,cLojPadrao)
		EndIf
	EndIf
	If lIniFiscal
		VX002HABIL(.T.)
		VX002ATFIS()
		VX002ATTELA(M->VV9_NUMATE)
	EndIf
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ VX002ATTELA º Autor ³ Rubens / Andre Luis º Data ³ 04/01/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao³ Atualiza objetos da Dialog                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002ATTELA(cNumAte)
Local cTpVTroca  := left(FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='4' AND VSA.D_E_L_E_T_=' '")+Repl("_",6),6) // VSA_TIPO='4' ( Veiculos Usados )
Local cQuery     := ""
Local nCntFor
Local cSQLAlias  := "SQLALIAS"
Local cSQLAux    := "SQLAUX"
Local cDescObs   := "" // Descricao da Observacao na Composicao das Parcelas
Local cObsUsr    := "" // Observacao do Usuario
Local aMostraTro := {} // ListBox do Troco
Local aMostraCor := {} // ListBox da Cortesia
Local aMostraRed := {} // ListBox do Redutor
Local aMostraAgr := {} // ListBox das Vendas Agregadas
Local aComposPar := {} // ListBox da Composicao das Parcelas
Local lTIPTIT    := ( VZ7->(ColumnPos("VZ7_TIPTIT")) > 0 )
Local lVZ7ITETRA := ( VZ7->(ColumnPos("VZ7_ITETRA")) > 0 )
Local lVS9OBSPAR := ( VS9->(ColumnPos("VS9_OBSPAR")) > 0 )
Local aArea
Default cNumAte  := ""

aadd(aMostraTro,{ STR0044 , 0 , "   " } )				// Total Geral - ListBox do Troco
aadd(aMostraCor,{ STR0044 , 0 , "   " } )				// Total Geral - ListBox da Cortesia
aadd(aMostraRed,{ STR0044 , 0 , "   " } )				// Total Geral - ListBox do Redutor
aadd(aMostraAgr,{ STR0044 , 0 , "" , "" , "   " } )	// Total Geral - ListBox das Vendas Agregadas

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Zera Variaveis de Valores de Negociacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlFinanc := 0
nVlFinPro := M->VV0_VALFPR // Financiamento Proprio - Utilizar Valor Total (VV0_VALFPR), pois o VS9 esta com o Juros embutido no Valor
nVlFiname := 0
nVlConsor := 0
nVlVeicUs := 0
nVlEntrad := 0

// Se tiver vazio o num atendimento, a tela vai ser inicializada em branco
If !Empty(cNumAte)
	aArea := GetArea()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta vetores VZ7 ( Troco / Cortesia / Redutor / Venda Agregada ) ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT VZ7.VZ7_AGRVLR , VZ7.VZ7_COMPAG , VZ7.VZ7_ITECAM , VZ7.VZ7_VALITE , VZX.VZX_DESCAM "
	If lTIPTIT
		cQuery += ", VZ7.VZ7_TIPTIT "
	EndIf
	If lVZ7ITETRA
		cQuery += ", VZ7.VZ7_ITETRA "
	EndIf
	cQuery += "FROM "+RetSQLName("VZ7")+" VZ7 "
	cQuery += "LEFT JOIN "+RetSQLName("VZX")+" VZX ON VZX.VZX_FILIAL='"+xFilial("VZX")+"' AND VZX.VZX_ITECAM=VZ7.VZ7_ITECAM AND VZX.D_E_L_E_T_=' ' "
	cQuery += "WHERE VZ7.VZ7_FILIAL='"+xFilial("VZ7")+"' AND VZ7.VZ7_NUMTRA='"+cNumAte+ "' AND VZ7.D_E_L_E_T_ = ' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
	While !(cSQLAlias)->(Eof())
		Do Case
			Case (cSQLAlias)->VZ7_AGRVLR == "0" // ListBox do Troco
				aadd(aMostraTro,{ (cSQLAlias)->VZ7_ITECAM + "-" + AllTrim((cSQLAlias)->VZX_DESCAM) , (cSQLAlias)->VZ7_VALITE , "" } )
				If lVZ7ITETRA .and. nVerAten == 3 // Versao 3 ( Atendimento N veiculos )
					aMostraTro[ Len(aMostraTro) , 3 ] := (cSQLAlias)->VZ7_ITETRA
				EndIf
				aMostraTro[1,2] += (cSQLAlias)->VZ7_VALITE // Total Geral

			Case (cSQLAlias)->VZ7_AGRVLR == "1" // ListBox do Cortesia
				aadd(aMostraCor,{ (cSQLAlias)->VZ7_ITECAM + "-" + AllTrim((cSQLAlias)->VZX_DESCAM) , (cSQLAlias)->VZ7_VALITE , "" } )
				If lVZ7ITETRA
					aMostraCor[ Len(aMostraCor) , 3 ] := (cSQLAlias)->VZ7_ITETRA
				EndIf
				aMostraCor[1,2] += (cSQLAlias)->VZ7_VALITE // Total Geral

			Case (cSQLAlias)->VZ7_AGRVLR == "2" // ListBox do Redutor
				If (cSQLAlias)->VZ7_ITECAM == cTpVTroca // Redutor de Veiculo Usado
					aadd(aMostraRed,{ (cSQLAlias)->VZ7_ITECAM + "-" + STR0045 , (cSQLAlias)->VZ7_VALITE , "" } ) // Ajuste de Usado
				Else
					aadd(aMostraRed,{ (cSQLAlias)->VZ7_ITECAM + "-" + AllTrim((cSQLAlias)->VZX_DESCAM) , (cSQLAlias)->VZ7_VALITE , "" } )
				EndIf
				If lVZ7ITETRA
					aMostraRed[ Len(aMostraRed) , 3 ] := (cSQLAlias)->VZ7_ITETRA
				EndIf
				aMostraRed[1,2] += (cSQLAlias)->VZ7_VALITE // Total Geral

			Case (cSQLAlias)->VZ7_AGRVLR == "3" // ListBox das Venda Agregada
				aadd(aMostraAgr,{ (cSQLAlias)->VZ7_ITECAM + "-" + AllTrim((cSQLAlias)->VZX_DESCAM) , (cSQLAlias)->VZ7_VALITE , X3CBOXDESC("VZ7_COMPAG",(cSQLAlias)->VZ7_COMPAG) , IIf(lTIPTIT,(cSQLAlias)->VZ7_TIPTIT,"") , "" } )
				If lVZ7ITETRA
					aMostraAgr[ Len(aMostraAgr) , 5 ] := (cSQLAlias)->VZ7_ITETRA
				EndIf
				aMostraAgr[1,2] += (cSQLAlias)->VZ7_VALITE // Total Geral

				If (cSQLAlias)->VZ7_COMPAG == "2" // Inserir como Redutor quando Inclui no Atendimento
					aadd(aMostraRed,{ (cSQLAlias)->VZ7_ITECAM + "-" + AllTrim((cSQLAlias)->VZX_DESCAM), (cSQLAlias)->VZ7_VALITE , "" } )
					If lVZ7ITETRA
						aMostraRed[ Len(aMostraRed) , 3 ] := (cSQLAlias)->VZ7_ITETRA
					EndIf
					aMostraRed[1,2] += (cSQLAlias)->VZ7_VALITE // Total Geral
				EndIf

		EndCase
		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta vetor VS9 ( Composicao de Parcelas )            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT VS9.R_E_C_N_O_ AS RECVS9 , VS9.VS9_TIPPAG , VS9.VS9_DATPAG , VS9.VS9_VALPAG , VS9.VS9_REFPAG , VS9.VS9_SEQUEN , VSA.VSA_DESPAG , VSA.VSA_TIPO FROM "+RetSQLName("VS9")+" VS9 "
	cQuery += "INNER JOIN "+RetSQLName("VSA")+" VSA ON ( VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.D_E_L_E_T_=' ' ) "
	cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+cNumAte+"' AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias , .F. , .T. )
	While !(cSQLAlias)->(Eof())

		If (cSQLAlias)->( VSA_TIPO ) == "2" // Financiamento Proprio

			cDescObs := (cSQLAlias)->( VS9_REFPAG )  // 001/100

		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monta Observacao para ser exibida no Listbox ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescObs := VX002OVS9( cNumAte, (cSQLAlias)->( VS9_TIPPAG ), (cSQLAlias)->( VSA_TIPO ) , (cSQLAlias)->( VS9_REFPAG ), (cSQLAlias)->( VS9_SEQUEN ), M->VV0_CLFINA, M->VV0_LJFINA, M->VV0_CFINAM, M->VV0_NFINAM )

			Do Case
				Case (cSQLAlias)->( VSA_TIPO ) == "1" // Financiamento / Leasing
					nVlFinanc += (cSQLAlias)->VS9_VALPAG

				Case (cSQLAlias)->( VSA_TIPO ) == "3" // Consorcio
					nVlConsor += (cSQLAlias)->VS9_VALPAG

				Case (cSQLAlias)->( VSA_TIPO ) == "4" // Veiculo Usado (Avaliacoes)
					nVlVeicUs += (cSQLAlias)->VS9_VALPAG

				Case (cSQLAlias)->( VSA_TIPO ) == "5" // Entradas
					nVlEntrad += (cSQLAlias)->VS9_VALPAG

				Case (cSQLAlias)->( VSA_TIPO ) == "6" // Finame
					nVlFiname += (cSQLAlias)->VS9_VALPAG

			EndCase

		EndIf

		cObsUsr := ""
		If lVS9OBSPAR
			VS9->(DbGoto((cSQLAlias)->( RECVS9 ))) // Campo do tipo MEMO é necessário posicionar na TABELA
			If !Empty(VS9->VS9_OBSPAR)
				If !Empty(cDescObs)
					cObsUsr += " - "
				EndIf
				cObsUsr += VS9->VS9_OBSPAR
			EndIf
		EndIf

		aadd(aComposPar,{ stod((cSQLAlias)->( VS9_DATPAG )) ,;
						 (cSQLAlias)->( VS9_VALPAG ) ,;
						 (cSQLAlias)->( VS9_TIPPAG )+" - "+(cSQLAlias)->( VSA_DESPAG ) ,;
						 cDescObs ,;
						 (cSQLAlias)->( RECVS9 ) ,;
						 cObsUsr })

		(cSQLAlias)->(dbSkip())
	EndDo
	(cSQLAlias)->(dbCloseArea())
	RestArea( aArea )
EndIf
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Refresh no Valor do Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lXX002Auto
	oVlVeicu:Refresh()
	oVlAtend:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Total de Entradas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlNegoc := 0
For nCntFor := 1 to Len(aObjValNeg)
	If aObjValNeg[nCntFor,12]
		nVlNegoc += round(( &(aObjValNeg[nCntFor,7]) * &(aObjValNeg[nCntFor,11]+'1') ),2) // Somar VALOR com 2 decimais

		If ! lXX002Auto
			&(aObjValNeg[nCntFor,6]+":Refresh()")
		EndIf
	EndIf
Next nCntFor

If ! lXX002Auto
	oVlNegoc:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza SALDO / DEVOLUCAO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nVlDevol := 0
nVlSaldo := 0
If ! lXX002Auto
	oVlDevol:lVisible  := .f.
	oVlSaldo:lVisible  := .f.
	oTitDevol:lVisible := .f.
	oTitSaldo:lVisible := .f.
EndIf
If nVlAtend < nVlNegoc
	nVlDevol := nVlNegoc - nVlAtend
	If ! lXX002Auto
		oTitDevol:lVisible := .t.
		oVlDevol:lVisible  := .t.
		oVlDevol:Refresh()
	EndIf
ElseIf nVlAtend > nVlNegoc
	nVlSaldo := nVlAtend - nVlNegoc
	If ! lXX002Auto
		oTitSaldo:lVisible := .t.
		oVlSaldo:lVisible  := .t.
		oVlSaldo:Refresh()
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa Vetores se nao for encontrado nenhum valor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMostraTro) == 0
	aMostraTro := {{"",0,""}}
EndIf
If Len(aMostraCor) == 0
	aMostraCor := {{"",0,""}}
EndIf
If Len(aMostraRed) == 0
	aMostraRed := {{"",0,""}}
EndIf
If Len(aMostraAgr) == 0
	aMostraAgr := {{"",0,"","",""}}
EndIf
If Len(aComposPar) == 0
	aComposPar := {{ctod(""),0,"","",0,""}}
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza os Listbox da TELA                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lXX002Auto
	oLboxTroco:nAt := 1
	oLboxTroco:SetArray(aMostraTro)
	oLboxTroco:bLine := { || { aMostraTro[oLboxTroco:nAt,3] , aMostraTro[oLboxTroco:nAt,1] , FG_AlinVlrs(Transform(aMostraTro[oLboxTroco:nAt,2],"@E 999,999.99")) }}
	oLboxTroco:Refresh()

	oLboxVAgreg:nAt := 1
	oLboxVAgreg:SetArray(aMostraAgr)
	oLboxVAgreg:bLine := { || { aMostraAgr[oLboxVAgreg:nAt,5] , aMostraAgr[oLboxVAgreg:nAt,1] , FG_AlinVlrs(Transform(aMostraAgr[oLboxVAgreg:nAt,2],"@E 999,999.99")) , aMostraAgr[oLboxVAgreg:nAt,3] , aMostraAgr[oLboxVAgreg:nAt,4] }}
	oLboxVAgreg:Refresh()

	oLboxCortesia:nAt := 1
	oLboxCortesia:SetArray(aMostraCor)
	oLboxCortesia:bLine := { || { aMostraCor[oLboxCortesia:nAt,3] , aMostraCor[oLboxCortesia:nAt,1] , FG_AlinVlrs(Transform(aMostraCor[oLboxCortesia:nAt,2],"@E 999,999.99")) }}
	oLboxCortesia:Refresh()

	If type("oLboxRedutor") <> "U"
		oLboxRedutor:nAt := 1
		oLboxRedutor:SetArray(aMostraRed)
		oLboxRedutor:bLine := { || { aMostraRed[oLboxRedutor:nAt,3] , aMostraRed[oLboxRedutor:nAt,1] , FG_AlinVlrs(Transform(aMostraRed[oLboxRedutor:nAt,2],"@E 999,999.99")) }}
		oLboxRedutor:Refresh()
	EndIf
EndIf

aSort(aComposPar,1,,{|x,y| dtos(x[1])+x[3]+strzero(x[5],10) < dtos(y[1])+y[3]+strzero(y[5],10) }) // Ordem: Data do Titulo + Tipo de Titulo + RecNo(VS9)
If ! lXX002Auto
	oLboxCParc:nAt := 1
	oLboxCParc:SetArray(aComposPar)
	oLboxCParc:bLine := { || { Transform(aComposPar[oLboxCParc:nAt,1],"@D") , FG_AlinVlrs(Transform(aComposPar[oLboxCParc:nAt,2],cValPict)) , aComposPar[oLboxCParc:nAt,3] , Alltrim(aComposPar[oLboxCParc:nAt,4])+aComposPar[oLboxCParc:nAt,6] }}
	oLboxCParc:Refresh()

	oEnchVV0:Refresh()
	oEnchVV9:Refresh()
EndIf

If nVlAtend - nVlNegoc > 0 // Não Gerou troco
	nFlVlFinanc := nVlAtend - nVlNegoc + nVlFinanc
	aParFin[01] := nVlAtend - nVlNegoc + nVlFinanc
	If nVlFinPro == 0
		aParPro[02] := nVlAtend - nVlNegoc
	Else
		aParPro[02] := nVlFinPro
	EndIf
	aParEnt[02] := ( nVlAtend - nVlNegoc )
Else
	nFlVlFinanc := nVlFinanc
	aParFin[01] := nVlFinanc
	aParPro[02] := nVlFinPro
	aParEnt[02] := 0
EndIf

If ! lXX002Auto
	oFlVlFinanc:Refresh()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TAXA do DIA                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VX005TXDIA(@aParFin,@aSimFinanc)
	oLboxSimFina:nAt := 1
	oLboxSimFina:SetArray(aSimFinanc)
	oLboxSimFina:bLine 	:= { || { aSimFinanc[oLboxSimFina:nAt,1], FG_AlinVlrs(Transform(aSimFinanc[oLboxSimFina:nAt,2],"@E 9999")) , FG_AlinVlrs(Transform(aSimFinanc[oLboxSimFina:nAt,3],"@E 999,999.99")) }}
	oLboxSimFina:Refresh()
EndIf

dbSelectArea("VV9")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002TUDOKº Autor ³ Rubens Takahashi    º Data ³ 21/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Validacao para Gravacao do Atendimento                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002TUDOK(nOpc,lGravar)

Local nCntFor
Local nPosaCols

Default lGravar := .t.

If nOpc == 5 .or. nOpc == 2
	Return .t.
EndIf

VX002CONOUT("VX002TUDOK")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Replica informacoes da VV0 para a VVA para gravar corretamente ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VX002RPGRV()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos Campos obrigatorios da VV9 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV9")
For nCntFor:=1 to Len(aCpoVV9)
	If X3Obrigat(aCpoVV9[nCntFor]) .and. Empty(&("M->"+aCpoVV9[nCntFor]))
		Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCpoVV9[nCntFor])) + " (" + aCpoVV9[nCntFor] + ")" ,4,1)
		Return .f.
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos Campos obrigatorios da VV0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VV0")
For nCntFor:=1 to Len(aCpoVV0)
	If X3Obrigat(aCpoVV0[nCntFor]) .and. Empty(&("M->"+aCpoVV0[nCntFor])) .and. !(aCpoVV0[nCntFor] $ "VV0_CHASSI")
		Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCpoVV0[nCntFor])) + " ("+ aCpoVV0[nCntFor] + ")" ,4,1)
		Return .f.
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validacao dos Campos obrigatorios da VVA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VVA")
For nPosaCols := 1 to Len(oGetDadVVA:aCols)
	// Linha deletada
	If oGetDadVVA:aCols[nPosaCols,Len(oGetDadVVA:aCols[nPosaCols])]
		Loop
	EndIf
	For nCntFor:=1 to Len(oGetDadVVA:aHeader)
		If X3Obrigat(oGetDadVVA:aHeader[nCntFor,2]) .and. Empty(oGetDadVVA:aCols[nPosaCols,nCntFor]) .and. !(oGetDadVVA:aHeader[nCntFor,2] $ "VVA_CHASSI")
			Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(oGetDadVVA:aHeader[nCntFor,2]))+ " (" + aCpoVVA[nCntFor] + ")",4,1)
			Return .f.
		EndIf
	Next nCntFor
Next nPosaCols

If lGravar
	If ! lXX002Auto
		If ! MsgYesNo(STR0046,STR0011) // Confirma gravacao do Atendimento? / Atencao
			Return .t.
		EndIf
	EndIf
	VX002GRV(nOpc,.t.)
EndIf
//
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002GRV º Autor ³ Rubens Takahashi    º Data ³ 22/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravacao do Atendimento                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc                                                       º±±
±±º          ³ lMsgSalva = Exibe mensagem que o atendimento foi salvo     º±±
±±º          ³ cAuxAlias = String Contendo as tabelas auxiliares que devemº±±
±±º          ³             ser gravadas (ex: "VSE/VS9"                    º±±
±±º          ³ aVS9 = Array com aHeader e aCols da VS9                    º±±
±±º          ³ aVSE = Array com aHeader e aCols da VSE                    º±±
±±º          ³ aVZ7 = Array com aHeader e aCols da VZ7                    º±±
±±º          ³ aVJ1 = Array com Codigo do Progresso do Veiculo            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Veiculos -> Novo Atendimento                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002GRV(nOpc,lMsgSalva,cAuxAlias,aVS9,aVSE,aVZ7,aVJ1)
Local lCriaVV9   := .f.
Local lRet       := .f.
Local cTpVTroca  := left(FM_SQL("SELECT VSA.VSA_TIPPAG FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPO='4' AND VSA.D_E_L_E_T_=' '")+Repl("_",6),6) // VSA_TIPO='4' ( Veiculos Usados )

Local nPosNUMIDE
Local nPosTIPOPE
Local nPosTIPPAG
Local nPosSEQUEN
Local nPosNUMTRA
Local nPosCODACV
Local nPosITECAM
Local nPosITETRA

Local aValCom := {} // Valor Comissao
Local aVetTra := {} // Vendedor utilizado no Levantamento da Comissao

Local nRecVZ7 := 0  // RecNo do VZ7

Local nCntLinha
Local nCntCampo
Local cString
Local aTotVZ7       // Valores de Acoes de Venda - VZ7
Local nIniFor       // Inicio do For no VZ7
Local nCntFor
Local nBkpGetD   := 0
Local lVZ7ITETRA := ( VZ7->(ColumnPos("VZ7_ITETRA")) > 0 )
Local nTotValTab := 0
Local nBkpN      := N
Local aUltMov    := {}
Local ni         := 0

Local lTIPMOV     := ( VV0->(ColumnPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lVV0_TIPDOC := ( VV0->(ColumnPos("VV0_TIPDOC")) > 0 ) // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
Local lVVA_DIFAL  := ( VV0->(ColumnPos("VVA_DIFAL"))  > 0 )

Private aAuxHeader

Default lMsgSalva := .t.
Default cAuxAlias := ""
Default aVS9 := {{},{}}
Default aVSE := {{},{}}
Default aVZ7 := {{},{}}
Default aVJ1 := {{},{}}

//
lMsErroAuto := .f.
//

// Se for INCLUSAO ou ALTERACAO ...
If nOpc == 3 .or. nOpc == 4

	VX002CONOUT("VX002GRV")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se é possível alterar o atendimento ... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(M->VV9_NUMATE)
		VV9->(dbSetOrder(1))
		If VV9->(dbSeek(xFilial("VV9") + M->VV9_NUMATE))
			If VV9->VV9_STATUS == "F"
				VX002ExibeHelp("VX002ERR005",STR0047+chr(13)+chr(10)+chr(13)+chr(10)+STR0048+" (VV9): " + VV9->VV9_STATUS,) // Impossivel ALTERAR o atendimento / Status / Atencao
				Return .f.
			EndIf
		EndIf
		VV0->(dbSetOrder(1))
		VV0->(dbSeek(xFilial("VV0") + M->VV9_NUMATE))
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravando Registro de Atendimento - VV9 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VV9")
	If nOpc == 3 .and. Empty(M->VV9_NUMATE) // Inclusao e nao gerou um numero de atendimento ...
		M->VV9_NUMATE := GetSXENum("VV0","VV0_NUMTRA")
//		// Quando chamado de ExecAuto
//		If ! lXX002Auto
			ConfirmSX8()
//		EndIf
		lCriaVV9 := .t.
	EndIf

	///////////////////////////////
	M->VV0_NUMTRA := M->VV9_NUMATE
	M->VVA_NUMTRA := M->VV9_NUMATE
	M->VV9_VEND1  := M->VV0_CODVEN
	///////////////////////////////

	Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravando Registro de Atendimento - VV9 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VV9")
	If lCriaVV9 // Inclusao e nao gerou um numero de atendimento ...
		RecLock("VV9",.t.)
	Else
		VV9->(dbSetOrder(1))
		VV9->(dbSeek(xFilial("VV9") + M->VV9_NUMATE))
		RecLock("VV9",.f.)
	EndIf

	FG_GRAVAR("VV9")
	VV9->VV9_FILIAL := xFilial("VV9")
	If Empty(VV9->VV9_STATUS)
		M->VV9_STATUS := VV9->VV9_STATUS := "A"
	EndIf
	MSMM(VV9->VV9_OBSMEM,TamSx3("VV9_OBSERV")[1],,M->VV9_OBSERV,1,,,"VV9","VV9_OBSMEM")
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desposicionar, para considerar em SELECT no meio da transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VV9->(dbGoTo(VV9->(Recno())))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tipos de Entradas - VS9          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("VS9" $ cAuxAlias .or. lXX002Auto) .and. len(aVS9[2]) > 0
		//
		VX0020021_GravaVS9( @aVS9 )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VS9->(dbGoTo(VS9->(Recno())))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Levanta novamente todos os VS9 correspondentes ao Atendimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX002X3LOAD( "VS9" , .t. , @aVS9 , 1 , "VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE", xFilial("VS9")+PadR(M->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"V")
		//
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dados Parcelamento da Entrada - VSE ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("VSE" $ cAuxAlias .or. lXX002Auto) .and. len(aVSE[2]) > 0
		//
		VX0020031_GravaVSE( @aVSE )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VSE->(dbGoTo(VSE->(Recno())))
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Levanta novamente todos os VSE correspondentes ao Atendimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX002X3LOAD( "VSE" , .t. , @aVSETotal , 1 , "VSE_FILIAL+VSE_NUMIDE+VSE_TIPOPE" , xFilial("VSE")+PadR(M->VV9_NUMATE,TamSX3("VSE_NUMIDE")[1]," ")+"V" )
		//
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Acao de Vendas VZ7 (Troco/Cortesia/Redutor/Vda.Agregada)³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("VZ7" $ cAuxAlias .or. lXX002Auto) .and. len(aVZ7[2]) > 0
		nUsado := Len(aVZ7[2,1])
		nIniFor := 1

		aAuxHeader := aClone(aVZ7[1]) // Compatibilizacao com FG_POSVAR

		nPosNUMTRA := FG_POSVAR("VZ7_NUMTRA","aAuxHeader")
		nPosCODACV := FG_POSVAR("VZ7_CODACV","aAuxHeader")
		nPosITECAM := FG_POSVAR("VZ7_ITECAM","aAuxHeader")
		If lVZ7ITETRA
			nPosITETRA := FG_POSVAR("VZ7_ITETRA","aAuxHeader")
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Apagar todas as Acoes de Vendas relacionadas ao Atendimento ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aVZ7[2,1,nUsado] .and. aVZ7[2,1,1] == "DELALL"
			cString := "DELETE FROM "+RetSqlName("VZ7")+ " WHERE VZ7_FILIAL = '" + xFilial("VZ7") + "' AND VZ7_NUMTRA = '" + M->VV9_NUMATE + "' AND ( VZ7_ITECAM<>'"+cTpVTroca+"' OR VZ7_AGRVLR<>'2' )"
			If lVZ7ITETRA
				cString += " AND VZ7_ITETRA = '" + aVZ7[2,1,nPosITETRA] + "'"
			EndIf
			TCSqlExec(cString)
			nIniFor := 2
		EndIf

		DbSelectArea("VZ7")
		VZ7->(dbSetOrder(1)) // VZ7_FILIAL+VZ7_NUMTRA+VZ7_CODACV+VZ7_ITECAM

		For nCntLinha := nIniFor to Len(aVZ7[2])

			// Verifica se a linhas esta vazia ...
			If Empty( aVZ7[2,nCntLinha,nPosNUMTRA] + aVZ7[2,nCntLinha,nPosCODACV] + aVZ7[2,nCntLinha,nPosITECAM] )
				Loop
			EndIf

			// Se estiver VAZIO, e' pq acabou de incluir o VV9/VV0/VVA, colocar o nro do Atendimento
			If INCLUI .and. Empty(aVZ7[2,nCntLinha,nPosNUMTRA])
				aVZ7[2,nCntLinha,nPosNUMTRA] := M->VV9_NUMATE
			EndIf

			// Posicinar no Registro do VZ7 //
			cString := "SELECT VZ7.R_E_C_N_O_ AS RECVZ7 FROM " + RetSQLname("VZ7") + " VZ7 WHERE VZ7.VZ7_FILIAL='"+xFilial("VZ7")+"' AND VZ7.VZ7_NUMTRA='"+aVZ7[2,nCntLinha,nPosNUMTRA]+"' AND VZ7.VZ7_ITECAM='"+aVZ7[2,nCntLinha,nPosITECAM]+"' AND VZ7.D_E_L_E_T_ = ' '"
			If lVZ7ITETRA
				cString += " AND VZ7_ITETRA = '" + aVZ7[2,nCntLinha,nPosITETRA] + "'"
			EndIf
			nRecVZ7 := FM_SQL(cString)

			If ( nRecVZ7 > 0 ) .or. !Empty(aVZ7[2,nCntLinha,nPosCODACV] + aVZ7[2,nCntLinha,nPosITECAM])

				// Se nao tiver excluido
				If !aVZ7[2,nCntLinha,nUsado]

					DbSelectArea("VZ7")
					If ( nRecVZ7 <= 0 )
						RecLock("VZ7",.T.)
						VZ7->VZ7_FILIAL := xFilial("VZ7")
						aVZ7[2,nCntLinha,nPosNUMTRA] := M->VV9_NUMATE
					Else
						DbGoto(nRecVZ7)
						RecLock("VZ7",.F.)
					EndIf

					For nCntCampo := 1 to (nUsado - 1)

						// Campo de Visualizacao
						If aVZ7[1,nCntCampo,10] <> "V"
							If aVZ7[2,nCntLinha,nCntCampo] == NIL
								&("VZ7->" + aVZ7[1,nCntCampo,2]) := CriaVar(aVZ7[1,nCntCampo,2])
							Else
								&("VZ7->" + aVZ7[1,nCntCampo,2]) := aVZ7[2,nCntLinha,nCntCampo]
							EndIf
						EndIf
					Next nCntCampo
					MsUnLock()

				// Exclui o Registro
				Else

					If ( nRecVZ7 > 0 )
						DbSelectArea("VZ7")
						DbGoto(nRecVZ7)
						RecLock("VZ7",.F.,.T.)
						VZ7->(dbDelete())
						MsUnLock()
					EndIf

				EndIf

			EndIf

		Next nCntLinha

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VZ7->(dbGoTo(VZ7->(Recno())))

	EndIf


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Progresso de Veiculos                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ("VJ1" $ cAuxAlias .or. lXX002Auto)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limpar o Progresso de Veiculo relacionado ao Atendimento    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cString := "UPDATE "+RetSqlName("VJ1")+ " SET VJ1_NUMTRA='"+space(TamSx3("VJ1_NUMTRA")[1])+"' WHERE VJ1_FILIAL = '" + xFilial("VJ1") + "' AND VJ1_NUMTRA = '" + M->VV9_NUMATE + "' AND VJ1_CHAINT<>'"+M->VVA_CHAINT+"' AND D_E_L_E_T_ = ' '"
		TCSqlExec(cString)
		If !Empty(aVJ1[2])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Relacionar o Atendimento ao Progresso de Veiculo            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DbSelectArea("VJ1")
			dbSetOrder(1) // VJ1_FILIAL+VJ1_CODMAR+VJ1_CODPED
			If DbSeek(xFilial("VJ1")+aVJ1[1]+aVJ1[2])
				RecLock("VJ1",.f.)
				VJ1->VJ1_NUMTRA := M->VV9_NUMATE
				MsUnLock()
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VJ1->(dbGoTo(VJ1->(Recno())))

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregar vetores auxiliares de parametros               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParFin[05] := M->VVA_CHAINT
	aParFin[12] := M->VV9_NUMATE

	aParPro[01] := M->VV9_NUMATE
	aParPro[02] := M->VV0_VALFPR
	aParPro[03] := M->VV0_DTIFPR
	aParPro[04] := M->VV0_D1PFPR
	aParPro[05] := M->VV0_PARFPR
	aParPro[06] := M->VV0_INTFPR
	aParPro[07] := M->VV0_FIXFPR
	aParPro[08] := M->VV0_DIAFPR
	aParPro[09] := M->VV0_JURFPR
	If ( VV0->(ColumnPos("VV0_MESFPR")) > 0 )
		aParPro[10] := M->VV0_MESFPR
	EndIf

	aParFna[01] := M->VV9_NUMATE

	aParUsa[01] := M->VV9_NUMATE

	aParCon[01] := M->VV9_NUMATE

	aParEnt[01] := M->VV9_NUMATE

	aEval( aParVZ7 , { |x| x[1] := M->VV9_NUMATE } )

	aEntrVei[01] := M->VV9_NUMATE

	aAdd(aVetTra,{M->VV0_CODVEN,1})

	nBkpGetD := oGetDadVVA:nAt	// Salva posicao atual da GetDados

	For nCntFor := 1 to Len(oGetDadVVA:aCols)

		dbSelectArea("VVA")

		// Linha deletada
		If oGetDadVVA:aCols[nCntFor,Len(oGetDadVVA:aCols[nCntFor])]
			If oGetDadVVA:aCols[nCntFor,nVVARECNO] <> 0
				dbSelectArea("VVA")
				dbGoTo(oGetDadVVA:aCols[nCntFor,nVVARECNO])
				RecLock("VVA",.F.,.T.)
				dbDelete()
				MsUnLock()
				VVA->(dbGoTo(VVA->(Recno())))
			EndIf
			Loop
		EndIf
		//

		FG_MEMVAR(oGetDadVVA:aHeader, oGetDadVVA:aCols, nCntFor )
		nTotValTab += M->VVA_VALTAB

		VV1->(dbSetOrder(1))
		VV1->(DbSeek( xFilial("VV1") + M->VVA_CHAINT ))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula valores de Acoes de Venda    ³
		//³ Para somar no valor da mercadoria    ³
		//³ [1] - SOMA NO TOTAL DO ATENDIMENTO   ³
		//³ [2] - TROCO                          ³
		//³ [3] - CORTESIA                       ³
		//³ [4] - REDUTOR                        ³
		//³ [5] - VENDA AGREGADA                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTotVZ7	:= VX003TOTAL(M->VV9_NUMATE,M->VVA_ITETRA)
		M->VVA_AGREGA := aTotVZ7[5] // Utilizacao das Vendas Agregadas
		M->VVA_REDVDA := aTotVZ7[4] // Utilizacao dos Redutores
		M->VVA_DESCLI := aTotVZ7[3] // Utilizacao das Cortesias
		M->VVA_UTROCO := aTotVZ7[2] // Utilizacao do Troco
		VX002ACOLS("VVA_AGREGA",nCntFor)
		VX002ACOLS("VVA_REDVDA",nCntFor)
		VX002ACOLS("VVA_DESCLI",nCntFor)
		VX002ACOLS("VVA_UTROCO",nCntFor)

		N := nCntFor
		If MaFisRet(N,"IT_VALMERC") <> M->VVA_VALTAB+aTotVZ7[1]
			MaFisRef("IT_PRCUNI","VX001",M->VVA_VALTAB)
			MaFisRef("IT_VALMERC","VX001",M->VVA_VALTAB+aTotVZ7[1])
		EndIf
		If M->VV0_TIPFAT == "1" // Veiculo Usado
			aUltMov := FM_VEIMOVS( oGetDadVVA:aCols[ nCntFor , FG_POSVAR("VVA_CHASSI","oGetDadVVA:aHeader") ] , "E"  )
			For ni := 1 to Len(aUltMov)
				If aUltMov[ni,5] == "0" // Entrada por Compra
					VVF->(DbSetOrder(1))
					If VVF->(MsSeek(aUltMov[ni,2]+aUltMov[ni,3]))
						SD1->(DbSetOrder(1))
						cProdSB1 := MaFisRet(n,"IT_PRODUTO")
						If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+cProdSB1))
							MaFisRef("IT_NFORI","VX001",SD1->D1_DOC)
							MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
							MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
							Endif
					EndIf

					Exit
				Endif
			Next
		Endif
		VX002ATFIS(.t.,.f.,nCntFor) // Atualiza M-> que possuem relacao com o FISCAL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Replica informacoes de campo VIRTUAL ... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX002RPGRV("",,,,,,nCntFor)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Levantamento da Comissao ( Gravar M->VVA )                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("FS_COMVEI")
			ExecBlock("FS_COMVEI",.f.,.f.)
		Else
			aValCom := FG_COMISS("V",aVetTra,M->VV0_DATMOV,M->VV0_TIPFAT,M->VVA_VALMOV,"T")
			M->VVA_COMVDE := aValCom[1]
			VX002ACOLS("VVA_COMVDE",nCntFor)
			M->VVA_COMGER := aValCom[2]
			VX002ACOLS("VVA_COMGER",nCntFor)
		EndIf

		If Empty(M->VVA_CODMAR)
			FGX_VV2(M->VVA_CODMAR, M->VVA_MODVEI, IIf( lVVASEGMOD , M->VVA_SEGMOD , "" ) )
		Else
			FGX_VV2(M->VV0_CODMAR, M->VV0_MODVEI, IIF( lVVASEGMOD , M->VV0_SEGMOD , "" ) )
		EndIf



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Custo do Veiculo e Juros de Estoque ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX002CUSJUR(nCntFor)

		M->VVA_TOTDES := M->VVA_DESVEI+M->VVA_DESCLI+M->VVA_SEGVIA+M->VVA_VALASS+M->VVA_VALREV+M->VVA_ASSIMP+M->VVA_DESFIX
		M->VVA_FATTOT := M->VVA_VALMOV+M->VVA_COMCOT+M->VVA_COMCTP+M->VVA_RECTEC+M->VVA_BONFAB
		M->VVA_TOTCUS := FG_FORMULA(GetNewPar("MV_TOTCUFN","M->VVA_VCAVEI-M->VVA_REDCUS+M->VVA_JUREST+M->VVA_ACESSO+M->VVA_VDESCO+M->VVA_PISENT+M->VVA_COFENT"))
		M->VVA_TOTIMP := M->VVA_ICMVEN+M->VVA_ISSCVD+M->VVA_PISVEN+M->VVA_COFVEN+M->VVA_ISSRTE+M->VVA_PISRTE+M->VVA_ISSBFB+M->VVA_PISBFB
		If lVVA_DIFAL
			M->VVA_TOTIMP += M->VVA_VALCMP+M->VVA_DIFAL
		Endif
		M->VVA_LUCBRU := M->VVA_FATTOT-M->VVA_TOTIMP-M->VVA_VCAVEI
		M->VVA_LUCLQ1 := M->VVA_LUCBRU-M->VVA_JUREST-M->VVA_ACESSO-M->VVA_VDESCO-M->VVA_DESCLI-M->VVA_SEGVIA-M->VVA_VALASS-M->VVA_VALREV-M->VVA_DESVEI-M->VVA_ASSIMP-M->VVA_COMVDE-M->VVA_COMGER-M->VVA_COMPAT //LUCRO MARGINAL
		M->VVA_LUCLQ2 := M->VVA_LUCLQ1-M->VVA_DESFIX+(M->VVA_REDCUS+M->VVA_RECVEI-M->VVA_DSPFIN) //LAIR

		VX002ACOLS("VVA_TOTDES",nCntFor)
		VX002ACOLS("VVA_FATTOT",nCntFor)
		VX002ACOLS("VVA_TOTCUS",nCntFor)
		VX002ACOLS("VVA_TOTIMP",nCntFor)
		VX002ACOLS("VVA_LUCBRU",nCntFor)
		VX002ACOLS("VVA_LUCLQ1",nCntFor)
		VX002ACOLS("VVA_LUCLQ2",nCntFor)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula Valores da Moeda Forte ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX002MFORTE(M->VVA_CHAINT)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Altera o VVA_FILENT e VVA_TRACPA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		M->VVA_FILENT := VV1->VV1_FILENT
		M->VVA_TRACPA := VV1->VV1_TRACPA
		VX002ACOLS("VVA_FILENT",nCntFor)
		VX002ACOLS("VVA_TRACPA",nCntFor)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acerta CHASSI para veiculos EM PEDIDO ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !Empty(M->VVA_CHAINT) .and. ( M->VVA_CHAINT==VV1->VV1_CHAINT ) .and. !Empty(VV1->VV1_CHASSI)
			M->VVA_CHASSI := VV1->VV1_CHASSI
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Itens da Saida de Veiculos - VVA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("VVA")
		SET DELETED OFF
		VVA->(dbSetOrder(4))
		If VVA->(dbSeek(xFilial("VVA") + M->VV9_NUMATE + M->VVA_ITETRA))
			RecLock("VVA",.f.)
			If VVA->(Deleted())
				VVA->(DBRecall())
			EndIf
		Else
			RecLock("VVA",.t.)
		EndIf
		SET DELETED ON
		FG_GRAVAR("VVA")
		VVA->VVA_FILIAL := xFilial("VVA")
		MsUnlock()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acerta Custo do Veiculo ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VEIXX017( M->VV9_NUMATE , nOpc , .f. , M->VVA_VALVDA , M->VVA_CHAINT , M->VVA_ITETRA )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Desposicionar, para considerar em SELECT no meio da transacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VVA->(dbGoTo(VVA->(Recno())))

		If oGetDadVVA:aCols[nCntFor,nVVARECNO] == 0
			oGetDadVVA:aCols[nCntFor,nVVARECNO] := VVA->(Recno())
		EndIf

		If nCntFor > Len(aMinCom)
			AADD( aMinCom , aClone(aStruMCom) )
		EndIf
		aMinCom[nCntFor,01] := M->VVA_CHAINT
		If !Empty(M->VVA_CODMAR)
			aMinCom[nCntFor,02] := M->VVA_CODMAR	// Marca do Veiculo
			aMinCom[nCntFor,03] := M->VVA_MODVEI	// Modelo do Veiculo
			aMinCom[nCntFor,04] := VV2->VV2_SEGMOD	// Segmento do Modelo
			aMinCom[nCntFor,05] := M->VVA_CORVEI	// Cor do Veiculo
		Else
			aMinCom[nCntFor,02] := M->VV0_CODMAR	// Marca do Veiculo
			aMinCom[nCntFor,03] := M->VV0_MODVEI	// Modelo do Veiculo
			aMinCom[nCntFor,04] := VV2->VV2_SEGMOD	// Segmento do Modelo
			aMinCom[nCntFor,05] := M->VV0_CORVEI	// Cor do Veiculo
		EndIf
		aMinCom[nCntFor,06] := M->VVA_VALTAB	// Valor da Negociacao do Veiculo

	Next nCntFor

	// Volta posicao da GetDados
	oGetDadVVA:nAt := IIf( nBkpGetD > 0 .and. nBkpGetD <= Len(oGetDadVVA:aCols) , nBkpGetD , 1 )
	N := oGetDadVVA:nAt
	FG_MEMVAR(oGetDadVVA:aHeader, oGetDadVVA:aCols, oGetDadVVA:nAt )
	//

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cabecalho da Saida de Veiculos - VV0 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VV0")
	VV0->(dbSetOrder(1))
	If !VV0->(dbSeek(xFilial("VV0") + M->VV9_NUMATE))
		RecLock("VV0",.t.)
	Else
		RecLock("VV0",.f.)
	EndIf
	FG_GRAVAR("VV0")
	VV0->VV0_FILIAL := xFilial("VV0")
	VV0->VV0_VALTAB := nTotValTab
	If lTIPMOV
		VV0->VV0_TIPMOV := "0" // 0 = Normal
	EndIf
	If lVV0_TIPDOC
		VV0->VV0_TIPDOC := "1" // Gerar ? ( 1=NF / 2=SD3 (Mov.Internas) )
	EndIf
	MsUnlock()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desposicionar, para considerar em SELECT no meio da transacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VV0->(dbGoTo(VV0->(Recno())))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fila do Vendedor no Atendimento - Alterar/Criar registro ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(RetSQLName("VDG"))
		DbSelectArea("VDG")
		DbSetOrder(3) // VDG_FILIAL + VDG_NUMATE
		If DbSeek( xFilial("VDG") + VV9->VV9_NUMATE )
			RecLock("VDG",.f.)
				VDG->VDG_CODVEN := VV0->VV0_CODVEN
			MsUnLock()
		Else
			RecLock("VDG",.t.)
				VDG->VDG_FILIAL := xFilial("VDG")
				VDG->VDG_CODVEN := VV0->VV0_CODVEN
				VDG->VDG_DATDIS := dDataBase
				VDG->VDG_HORDIS := val(substr(time(),1,2)+substr(time(),4,2))
				VDG->VDG_DATLIM := VDG->VDG_DATDIS
				VDG->VDG_HORLIM := VDG->VDG_HORDIS
				VDG->VDG_NUMATE := VV9->VV9_NUMATE
			MsUnLock()
		EndIf
		DbSelectArea("VDG")
		DbSetOrder(2) // VDG_FILIAL + VDG_CODVEN + VDG_NUMATE
		If DbSeek( xFilial("VDG") + VV0->VV0_CODVEN + space(len(VV9->VV9_NUMATE)) )
			RecLock("VDG",.f.,.t.)
			DbDelete()
			MsUnlock()
		EndIf
	EndIf

	End Transaction

	lRet := .t.

	If VV9->VV9_STATUS == "A" .and. FindFunction("VXI010021_FaseAutomaticaInteresse")
		VXI010021_FaseAutomaticaInteresse( VV9->VV9_FILIAL , VV9->VV9_NUMATE , "A" )
	EndIf

	VX002ATTELA(VV9->VV9_NUMATE)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deve ser gravado neste ponto, pois a variavel nVlDevol (Devolucao/Troco) e' atualizada na funcao VX002ATTELA. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("VV0")
	VV0->(dbSetOrder(1))
	If VV0->(dbSeek(xFilial("VV0") + VV9->VV9_NUMATE))
		If nVlDevol	<> VV0->VV0_VALTRO
			M->VV0_VALTRO := nVlDevol // Valor de Devolucao/Troco para o Cliente
			RecLock("VV0",.f.)
			VV0->VV0_VALTRO := nVlDevol // Valor de Devolucao/Troco para o Cliente
			MsUnlock()
		EndIf
	EndIf

	If lMsgSalva .and. !lXX002Auto
		MsgInfo(STR0049+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV9->VV9_NUMATE,STR0011) // Atendimento gravado com sucesso! / Atencao
	EndIf

EndIf

N := nBkpN

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002GRVOPOº Autor ³ Andre Luis/Rubens  º Data ³ 08/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gravar Filial e Nro do Atendimento no Interesse do Cliente º±±
±±º          ³ na Oportunidade de Negocio                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002GRVOPO(aAux,aIteTra,aPOSIteTra,nLinVVA)
Local nCntFor     := 0
Local aObjects    := {} , aPos := {} , aInfo := {}
Local aSizeHalf   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local cFasFim     := ""
Local nQtdFas     := 0
Local nOpcao      := 0
Local nRecVDM     := 0
Local cQuery      := ""
Local cQAlias     := "SQLALIAS"
Local lVAI_VABAON := ( VAI->(ColumnPos("VAI_VABAON")) > 0 )
Local lVDMSEGMOD  := ( VDM->(ColumnPos("VDM_SEGMOD")) > 0 )
Local lJaRelac    := .f. // Ja Relacionou o Interesse no Item do Atendimento ?
Private aVerOport := {}
Private cCombVend := ""
Private aCombVend := {}
Private oOkTik    := LoadBitmap( GetResources() , "LBTIK" )
Private oNoTik    := LoadBitmap( GetResources() , "LBNO" )
Private oCor0     := LoadBitmap( GetResources() , "BR_BRANCO" )   // 0 - Interesse nao selecionado anteriormente
Private oCor1     := LoadBitmap( GetResources() , "BR_VERDE" )    // 1 - Interesse selecionado anteriormente relacionado com veiculo/maquina
Private oCor2     := LoadBitmap( GetResources() , "BR_VERMELHO" ) // 2 - Interesse selecionado anteriormente nao foi relacionado com veiculo/maquina
Default nLinVVA   := 0
If nLinVVA > 0 // Esta relacionando VVA especifico
	cQuery := "SELECT R_E_C_N_O_ "
	cQuery += "FROM "+RetSqlName("VDM")+" WHERE "
	cQuery += " VDM_FILIAL='"+xFilial("VDM")+"' AND "
	cQuery += " VDM_FILATE='"+xFilial("VV9")+"' AND "
	cQuery += " VDM_NUMATE='"+M->VV9_NUMATE +"' AND "
	cQuery += " VDM_ITETRA='"+M->VVA_ITETRA+"' AND "
	cQuery += "D_E_L_E_T_=' '"
	nRecVDM := FM_SQL(cQuery)
	If nRecVDM > 0
		If MsgYesNo(STR0166,STR0011) // Ja existe Interesse relacionado a este Veiculo/Maquina. Deseja relacionar novamente? / Atencao
			VXX002CAMPAN( .f. , xFilial("VV9") , M->VV9_NUMATE , M->VVA_ITETRA , nRecVDM , , 0 ) // Limpar conteudo do campo VVA_CAMPAN/VV0_CAMPAN - Campanha do Interesse
			While nRecVDM > 0
				DbSelectArea("VDM")
				DbGoTo(nRecVDM)
				RecLock("VDM",.f.)
					VDM->VDM_FILATE := ""
					VDM->VDM_NUMATE := ""
					VDM->VDM_ITETRA := ""
				MsUnLock()
				nRecVDM := FM_SQL(cQuery)
			EndDo
		Else
			Return
		EndIf
	EndIf
EndIf
aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } ) // Interesses
If nLinVVA == 0 // Esta relacionando varios VVA
	AAdd( aObjects, { 0, 30, .T. , .F. } ) // Legendas
EndIf
aPos := MsObjSize( aInfo, aObjects )
VAI->(DbSetOrder(4))
VAI->(DbSeek(xFilial("VAI")+__cUserID))
cQuery := "SELECT DISTINCT VDK.VDK_CODFAS FROM "+RetSqlName("VDK")+" VDK WHERE VDK.VDK_FILIAL='"+xFilial("VDK")+"' AND VDK.VDK_FIMFAS='1' AND VDK.D_E_L_E_T_=' '"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
Do While !( cQAlias )->( Eof() )
	cFasFim += "'"+( cQAlias )->( VDK_CODFAS )+"',"
	nQtdFas++
	( cQAlias )->( DbSkip() )
EndDo
( cQAlias )->( dbCloseArea() )
If !Empty(cFasFim)
	cFasFim := left(cFasFim,len(cFasFim)-1)
	cQuery := "SELECT VDM.R_E_C_N_O_ AS RECVDM ,"
	cQuery += "       VDM.VDM_CAMPOP , VX5.VX5_DESCRI ,"
	cQuery += "       VDM.VDM_CODMAR , VDM.VDM_MODVEI ,"
	If lVDMSEGMOD
		cQuery += "   VDM.VDM_SEGMOD ,"
	EndIf
	cQuery += "       VDM.VDM_CORVEI , VVC.VVC_DESCRI ,"
	cQuery += "       VDM.VDM_QTDINT , VDM.VDM_DATINT , VDM.VDM_DATLIM ,"
	cQuery += "       VDM.VDM_CODVEN , VDM.VDM_OPCFAB , VDM.VDM_ITETRA ,"
	cQuery += "       VDM.VDM_VLRNEG "
	cQuery += "FROM "+RetSqlName("VDM")+" VDM "
	cQuery += "JOIN "+RetSqlName("VDL")+" VDL ON ( VDL.VDL_FILIAL=VDM.VDM_FILIAL AND VDL.VDL_CODOPO=VDM.VDM_CODOPO AND VDL.D_E_L_E_T_=' ' ) "
	cQuery += "JOIN "+RetSqlName("VVC")+" VVC ON ( VVC.VVC_FILIAL='"+xFilial("VVC")+"' AND VVC.VVC_CODMAR=VDM.VDM_CODMAR AND VVC.VVC_CORVEI=VDM.VDM_CORVEI AND VVC.D_E_L_E_T_=' ' ) "
	cQuery += "LEFT JOIN "+RetSqlName("VX5")+" VX5 ON ( VX5.VX5_FILIAL='"+xFilial("VX5")+"' AND VX5.VX5_CHAVE='026' AND VX5.VX5_CODIGO=VDM.VDM_CAMPOP AND VX5.D_E_L_E_T_ = ' ' ) "
	cQuery += "WHERE VDM.VDM_FILIAL='"+xFilial("VDM")+"' AND "
	cQuery += "VDL.VDL_CODCLI='"+M->VV9_CODCLI+"' AND "
	If len(aAux) > 0 .and. !aAux[1,6] // Verifica se o usuario selecionou todas as LOJAS do cliente ou apenas uma
		cQuery += "VDL.VDL_LOJCLI='"+M->VV9_LOJA+"' AND "
	EndIf
	If nQtdFas == 1
		cQuery += "VDM.VDM_CODFAS="+cFasFim+" AND "
	Else
		cQuery += "VDM.VDM_CODFAS IN ("+cFasFim+") AND "
	EndIf
	cQuery += "VDM.VDM_MOTCAN=' ' AND VDM.VDM_FILATE=' ' AND VDM.VDM_NUMATE=' ' AND "
	If lVAI_VABAON
		If VAI->VAI_VABAON == "1" // 1=Somente do Vendedor
			cQuery += "VDM.VDM_CODVEN='"+VAI->VAI_CODVEN+"' AND "
		EndIf
	Else
		cQuery += "( VDM.VDM_CODVEN=' ' OR VDM.VDM_CODVEN='"+VAI->VAI_CODVEN+"' ) AND "
	EndIf
	cQuery += "VDM.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias, .F., .T. )
	Do While !( cQAlias )->( Eof() )
		VV2->(dbSetOrder(1))
		If !lVDMSEGMOD .or. !VV2->(MsSeek(xFilial("VV2")+( cQAlias )->( VDM_CODMAR )+( cQAlias )->( VDM_MODVEI )+( cQAlias )->( VDM_SEGMOD )))
			VV2->(MsSeek(xFilial("VV2")+( cQAlias )->( VDM_CODMAR )+( cQAlias )->( VDM_MODVEI )))
		EndIf
		aAdd(aVerOport,{ 	( aScan(aAux, {|x| x[5] == ( cQAlias )->( RECVDM ) }) > 0 ) ,;
							Alltrim(( cQAlias )->( VDM_CAMPOP ))+" - "+Alltrim(( cQAlias )->( VX5_DESCRI )),;
							( cQAlias )->( VDM_CODMAR ) ,;
							Alltrim(( cQAlias )->( VDM_MODVEI ))+" - "+Alltrim(VV2->VV2_DESMOD) ,;
							Alltrim(( cQAlias )->( VDM_CORVEI ))+" - "+Alltrim(( cQAlias )->( VVC_DESCRI )) ,;
							( cQAlias )->( VDM_QTDINT ) ,;
							stod(( cQAlias )->( VDM_DATINT )) ,;
							stod(( cQAlias )->( VDM_DATLIM )) ,;
							( cQAlias )->( RECVDM ) ,;
							( cQAlias )->( VDM_OPCFAB ) ,;
							( cQAlias )->( VDM_CODVEN ) ,;
							( cQAlias )->( VDM_ITETRA ) ,;
							"0" ,;
							( cQAlias )->( VDM_VLRNEG ) })
		If aVerOport[len(aVerOport),01]
			aVerOport[len(aVerOport),13] := "2" // Interesse selecionado sem relacionamento com o veiculo/maquina
			If Empty(aVerOport[len(aVerOport),12])
				If len(aPOSIteTra) > 0
					nCntFor := 0
					For nCntFor := 1 to len(aPOSIteTra) // Achar a posicao do ITETRA com Marca+Modelo+Cor
						If ( ( cQAlias )->( VDM_CODMAR )+( cQAlias )->( VDM_MODVEI )+( cQAlias )->( VDM_CORVEI ) ) $ aPOSIteTra[nCntFor]
							aPOSIteTra[nCntFor] := "   "
							Exit
						EndIf
					Next
					If nCntFor > len(aIteTra)
						For nCntFor := 1 to len(aPOSIteTra) // Achar a posicao do ITETRA com Marca+Modelo
							If ( ( cQAlias )->( VDM_CODMAR )+( cQAlias )->( VDM_MODVEI ) ) $ aPOSIteTra[nCntFor]
								aPOSIteTra[nCntFor] := "   "
								Exit
							EndIf
						Next
					EndIf
					If nCntFor > 0 .and. nCntFor <= len(aIteTra)
						aVerOport[len(aVerOport),12] := left(aIteTra[nCntFor],TamSX3("VVA_ITETRA")[1])
						aVerOport[len(aVerOport),13] := "1" // Interesse selecionado com relacionamento com o(a) veiculo/maquina
					Else
						aVerOport[len(aVerOport),01] := .f.
						aVerOport[len(aVerOport),12] := space(TamSX3("VVA_ITETRA")[1])
					EndIf
				EndIf
			EndIf
		EndIf
		( cQAlias )->( DbSkip() )
	EndDo
	( cQAlias )->( dbCloseArea() )
EndIf
DbSelectArea("VV9")
If len(aVerOport) <= 0
	If nLinVVA > 0 // Esta relacionando VVA especifico
		MsgAlert(STR0168,STR0011) // Nenhum Interesse foi encontrado para o Cliente! / Atencao
	EndIf
	Return
EndIf
If nLinVVA == 0 // Esta relacionando varios VVA
	For nCntFor := 1 to len(aPOSIteTra)
		If !Empty(Alltrim(aPOSIteTra[nCntFor]))
			MsgAlert(STR0156,STR0011) // Foram selecionados mais veiculos/maquinas do que Interesses ou nao foi possivel relacionar automaticamente os Interesses com as Marcas/Modelos selecionados. / Atencao
			Exit
		EndIf
	Next
EndIf
FS_COMBVEND(.f.)
DEFINE MSDIALOG oTelaOpo TITLE STR0106 FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Selecione quais interesses do Cliente foram atendidos neste Atendimento.
	oTelaOpo:lEscClose := .F.
	oLbVerOpo := TWBrowse():New( aPos[1,1],aPos[1,2] , aPos[1,4] , aPos[1,3]-aPos[1,1],,,,oTelaOpo,,,,,{ || FS_ITETRA(aIteTra) },,,,,,,.F.,,.T.,,.F.,,,)
	oLbVerOpo:addColumn( TCColumn():New( ""      , { || IIf(aVerOport[oLbVerOpo:nAt,01],oOkTik,oNoTik) }      ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // selecionar
	If nLinVVA == 0 // Esta relacionando varios VVA
		oLbVerOpo:addColumn( TCColumn():New( ""  , { || &("oCor"+aVerOport[oLbVerOpo:nAt,13]) }               ,,,, "LEFT" , 08 ,.T.,.F.,,,,.F.,) ) // cor
	EndIf
	oLbVerOpo:addColumn( TCColumn():new( STR0107 , { || aVerOport[oLbVerOpo:nAt,02] }                         ,,,, "LEFT" ,100 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0147 , { || aVerOport[oLbVerOpo:nAt,03] }                         ,,,, "LEFT" , 25 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0148 , { || aVerOport[oLbVerOpo:nAt,04] }                         ,,,, "LEFT" ,100 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0108 , { || aVerOport[oLbVerOpo:nAt,05] }                         ,,,, "LEFT" , 65 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0070 , { || aVerOport[oLbVerOpo:nAt,10] }                         ,,,, "LEFT" , 70 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0109 , { || Transform(aVerOport[oLbVerOpo:nAt,06],"@E 999,999") } ,,,, "RIGHT", 30 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( RetTitle("VDM_VLRNEG") , { || Transform(aVerOport[oLbVerOpo:nAt,14],"@E 999,999,999.99") } ,,,, "RIGHT" , 50 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0104 , { || Transform(aVerOport[oLbVerOpo:nAt,07],"@D") }         ,,,, "LEFT" , 43 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0105 , { || Transform(aVerOport[oLbVerOpo:nAt,08],"@D") }         ,,,, "LEFT" , 43 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:addColumn( TCColumn():new( STR0081 , { || IIf(!Empty(aVerOport[oLbVerOpo:nAt,12]),aIteTra[ascan(aIteTra,aVerOport[oLbVerOpo:nAt,12])],"") } ,,,, "LEFT" ,250 ,.F.,.F.,,,,.F.,) )
	oLbVerOpo:setArray( aVerOport )
	If nLinVVA == 0 // Esta relacionando varios VVA
		@ aPos[2,1],aPos[2,4]-118 SAY (STR0064+": ") OF oTelaOpo PIXEL COLOR CLR_HBLUE // Vendedor a ser utilizado no Atendimento
		oCombVend := TComboBox():New(aPos[2,1]+10,aPos[2,4]-118,{|u|if(PCount()>0,cCombVend:=u,cCombVend)},aCombVend,120,10,oTelaOpo,,{||.t.},,,,.T.,,,,,,,,,'cCombVend')
		@ aPos[2,1]+000,aPos[2,2]+005 BITMAP oxBran RESOURCE "BR_BRANCO" OF oTelaOpo NOBORDER SIZE 10,10 when .f. PIXEL
		@ aPos[2,1]+000,aPos[2,2]+015 SAY STR0157 SIZE 250,8 OF oTelaOpo PIXEL COLOR CLR_BLUE // Interesse nao selecionado anteriormente
		@ aPos[2,1]+009,aPos[2,2]+005 BITMAP oxVerd RESOURCE "BR_VERDE" OF oTelaOpo NOBORDER SIZE 10,10 when .f. PIXEL
		@ aPos[2,1]+009,aPos[2,2]+015 SAY STR0158 SIZE 250,8 OF oTelaOpo PIXEL COLOR CLR_BLUE // Interesse selecionado anteriormente relacionado com veiculo/maquina
		@ aPos[2,1]+018,aPos[2,2]+005 BITMAP oxVerm RESOURCE "BR_VERMELHO" OF oTelaOpo NOBORDER SIZE 10,10 when .f. PIXEL
		@ aPos[2,1]+018,aPos[2,2]+015 SAY STR0159 SIZE 250,8 OF oTelaOpo PIXEL COLOR CLR_BLUE // Interesse selecionado anteriormente nao foi relacionado com veiculo/maquina
	EndIf
ACTIVATE MSDIALOG oTelaOpo ON INIT (EnchoiceBar(oTelaOpo,{|| IIf(VX0020011_ValidaRelacionamentoInteresse(aVerOport),(nOpcao:=1 , oTelaOpo:End()),.t.) },{ || oTelaOpo:End()},,))
If nOpcao == 1 // OK Tela
	M->VV0_CODVEN := left(cCombVend,TamSX3("VV0_CODVEN")[1]) // Vendedor selecionado na TELA
	DbSelectArea("VDM")
	For nCntFor := 1 to len(aVerOport)
		If aVerOport[nCntFor,1]
			DbGoTo(aVerOport[nCntFor,9])
			RecLock("VDM",.f.)
				VDM->VDM_FILATE := xFilial("VV9")
				VDM->VDM_NUMATE := M->VV9_NUMATE
				VDM->VDM_ITETRA := aVerOport[nCntFor,12]
			MsUnLock()
			If !lJaRelac
				lJaRelac := .t.
				VXX002CAMPAN( .t. , xFilial("VV9") , M->VV9_NUMATE , aVerOport[nCntFor,12] , aVerOport[nCntFor,9] , , aVerOport[nCntFor,14] ) // Trazer conteudo no campo VVA_CAMPAN/VV0_CAMPAN - Campanha do Interesse
			EndIf
		EndIf
	Next nCntFor
	If ExistBlock("VX002OPO")
		ExecBlock("VX002OPO",.f.,.f.,{ M->VV9_FILIAL ,M->VV9_NUMATE })
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_ITETRA º Autor ³ Andre Luis Almeida º Data ³ 12/06/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Selecao do VVA_ITETRA em relacao ao Interesse do Cliente   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ITETRA(aIteTra)
Local lOkTela  := .f.
Local cDescOpo := aVerOport[oLbVerOpo:nAt,03]+" "+aVerOport[oLbVerOpo:nAt,04]+" "+aVerOport[oLbVerOpo:nAt,05] // Interesse: Marca / Modelo / Cor
Local cIteTra  := ""
Local aIteTraN := {}
Local aIteTraS := {}
Local cTpComb  := "2"
Local aTpComb  := {}
Local ni       := 0
//
For ni := 1 to len(aIteTra)
	If aScan(aVerOport, { |x| x[12] == left(aIteTra[ni],TamSX3("VVA_ITETRA")[1]) } ) == 0
		aAdd(aIteTraN,aIteTra[ni]) // nao relacionado
	Else
		aAdd(aIteTraS,aIteTra[ni]) // ja relacionado
	EndIf
Next
If len(aIteTraN) > 0
	aAdd(aTpComb,"0="+STR0163) // nao relacionado
	cTpComb := "0"
EndIf
If len(aIteTraS) > 0
	aAdd(aTpComb,"1="+STR0164) // ja relacionado
	If cTpComb == "2"
		cTpComb := "1"
	EndIf
EndIf
If len(aIteTraN) > 0 .and. len(aIteTraS) > 0
	aAdd(aTpComb,"2="+STR0165) // todos
EndIf
//
aVerOport[oLbVerOpo:nAt,01] := !aVerOport[oLbVerOpo:nAt,01]
If aVerOport[oLbVerOpo:nAt,01]
	If len(aIteTra) == 1
		aVerOport[oLbVerOpo:nAt,12] := left(aIteTra[1],TamSX3("VVA_ITETRA")[1])
	ElseIf len(aIteTra) > 1
		DEFINE MSDIALOG oITETRA TITLE STR0160 FROM 0,0 TO 170,455 OF oMainWnd PIXEL // Relacionar Interesse com Marcas/Modelos selecionados
			@ 005,005 SAY STR0161 SIZE 120,8 OF oITETRA PIXEL COLOR CLR_BLUE // Interesse selecionado
			@ 016,005 MSGET oDescOpo VAR cDescOpo PICTURE "@!" SIZE 220,08 OF oITETRA PIXEL COLOR CLR_RED WHEN .f.
			@ 035,005 SAY STR0081 SIZE 120,8 OF oITETRA PIXEL COLOR CLR_BLUE
			@ 046,005 MSCOMBOBOX oIteTraN VAR cIteTra SIZE 220,08 ITEMS aIteTraN OF oITETRA PIXEL COLOR CLR_BLACK
			@ 046,005 MSCOMBOBOX oIteTraS VAR cIteTra SIZE 220,08 ITEMS aIteTraS OF oITETRA PIXEL COLOR CLR_BLACK
			@ 046,005 MSCOMBOBOX oIteTraT VAR cIteTra SIZE 220,08 ITEMS aIteTra  OF oITETRA PIXEL COLOR CLR_BLACK
			oIteTraN:lVisible := .f.
			oIteTraS:lVisible := .f.
			oIteTraT:lVisible := .f.
			If len(aIteTraN) > 0
				oIteTraN:lVisible := .t.
				cIteTra := left(aIteTraN[1],TamSX3("VVA_ITETRA")[1])
			ElseIf len(aIteTraS) > 0
				oIteTraS:lVisible := .t.
				cIteTra := left(aIteTraS[1],TamSX3("VVA_ITETRA")[1])
			EndIf
			@ 065,135 BUTTON oConf PROMPT STR0162 OF oITETRA SIZE 40,12 PIXEL ACTION ( lOkTela := .t. , oITETRA:End() ) // Confirmar
			@ 065,180 BUTTON oCanc PROMPT STR0010 OF oITETRA SIZE 40,12 PIXEL ACTION ( oITETRA:End() ) // Cancelar
			@ 032,060 MSCOMBOBOX oTpComb VAR cTpComb SIZE 070,08 ITEMS aTpComb OF oITETRA PIXEL COLOR CLR_BLACK ON CHANGE FS_COMBOINT(cTpComb,@cIteTra,aIteTraN,aIteTraS,aIteTra) WHEN ( len(aTpComb) > 1 )
		ACTIVATE MSDIALOG oITETRA CENTER
		If lOkTela
			aVerOport[oLbVerOpo:nAt,12] := cIteTra
		Else
			aVerOport[oLbVerOpo:nAt,01] := .f.
		EndIf
	EndIf
Else
	aVerOport[oLbVerOpo:nAt,12] := space(TamSX3("VVA_ITETRA")[1])
EndIf
oLbVerOpo:Refresh()
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_COMBOINT º Autor ³ Andre Luis Almeida º Data ³ 26/05/17 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visable dos combos de relacionamento do Interesse com VVA  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COMBOINT(cTpComb,cIteTra,aIteTraN,aIteTraS,aIteTra)
oIteTraN:lVisible := .f.
oIteTraS:lVisible := .f.
oIteTraT:lVisible := .f.
Do Case
	Case cTpComb == "0" // nao relacionado
		cIteTra := left(aIteTraN[1],TamSX3("VVA_ITETRA")[1])
		oIteTraN:lVisible := .t.
		oIteTraN:SetFocus()
	Case cTpComb == "1" // ja relacionado
		cIteTra := left(aIteTraS[1],TamSX3("VVA_ITETRA")[1])
		oIteTraS:lVisible := .t.
		oIteTraS:SetFocus()
	Case cTpComb == "2" /// todos
		cIteTra := left(aIteTra[1],TamSX3("VVA_ITETRA")[1])
		oIteTraT:lVisible := .t.
		oIteTraT:SetFocus()
EndCase
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_COMBVEND º Autor ³ Andre Luis Almeida º Data ³ 08/04/15 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montar Combo com os Vendedores dos Interesses selecionados º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_COMBVEND(lAtuCombo)
Local ni   := 0
Local cAux := ""
aCombVend := {}
VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
///////////////////////////////
// Vendedores dos Interesses //
///////////////////////////////
If VAI->VAI_ATEOUT == "2" // Usuario pode Incluir/Alterar Atendimento de Outros Vendedores
	For ni := 1 to len(aVerOport)
		If aVerOport[ni,1] .and. !Empty(aVerOport[ni,11])
			cAux := aVerOport[ni,11]+"="+FM_SQL("SELECT A3_NOME FROM "+RetSQLName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+aVerOport[ni,11]+"' AND D_E_L_E_T_=' '")
			If ascan(aCombVend,cAux) <= 0
				aAdd(aCombVend,cAux)
			EndIf
		EndIf
	Next
EndIf
///////////////////////////////
// Vendedor Logado           //
///////////////////////////////
cAux := VAI->VAI_CODVEN+"="+FM_SQL("SELECT A3_NOME FROM "+RetSQLName("SA3")+" WHERE A3_FILIAL='"+xFilial("SA3")+"' AND A3_COD='"+VAI->VAI_CODVEN+"' AND D_E_L_E_T_=' '")
If ascan(aCombVend,cAux) <= 0
	aAdd(aCombVend,cAux)
EndIf
///////////////////////////////
// Atualiza ComboBox         //
///////////////////////////////
If lAtuCombo
	oCombVend:SetItems( aCombVend )
	oCombVend:Select( 1 )
	cCombVend := aCombVend[1]
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002FAT º Autor ³ Andre Luis/Rubens  º Data ³  08/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faturamento do Atendimento                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002FAT(nOpc,aVS9, nOpcCancAuto, aMotCancAuto )

Local lRetorno

Default nOpcCancAuto := 0
Default aMotCancAuto := {}

If nOpc == 5 // Cancelar
	lRetorno := VEIXI001(VV9->VV9_NUMATE,nOpc, lXX002Auto, nOpcCancAuto, aMotCancAuto)
	Return lRetorno
ElseIf nOpc <> 3 .and. nOpc <> 4 // Diferente de Incluir e Alterar
	Return .t.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se todos os campos foram digitados ... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !VX002TUDOK(nOpc,.F.)
	Return .f.
EndIf

// Se for atendimento com N veiculos, verifica se existe pelo menos um veiculo
If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )
	If aScan(oGetDadVVA:aCols, { |x| !x[Len(x)] } ) == 0
		VX002ExibeHelp("VX002ERR025", STR0123) // Atendimento deve possuir pelo menos um veiculo! / Atencao
		Return .f.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !VX002GRV(nOpc,.f.)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Simulacao - NAO AVANCA FASE ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If VV0->VV0_OPEMOV == "1"
	VX002ExibeHelp("VX002ERR021", STR0051) // Este Atendimento e' uma Simulacao, impossivel avancar a fase! / Atencao
	Return .t.
EndIf

If Empty(VV9->VV9_CODCLI+VV9->VV9_LOJA)
	VX002ExibeHelp("VX002ERR024", STR0052) // Necessario informar um Cod.Cliente/Loja! / Atencao
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validar divergencia TES ( Gera Duplicata / Nao Gera Duplicata ) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !VXX002DUPL(1) // Verifica divergencias nos TES utilizados ( geram ou nao duplicatas )
	Return .f.
EndIf

If VXX002DUPL(2) // Verifica se os TES utilizados geram ou nao duplicatas  ( .t. = Gerar Duplicatas )
	If nVlSaldo > 0 // Validar SALDO RESTANTE
		VX002ExibeHelp("VX002ERR007",STR0053) // Favor compor as parcelas de pagamento! / Atencao
		Return .f.
	EndIf
Else
	If !MsgNoYes(STR0154,STR0011) // Este atendimento esta utilizando TES que nao gera duplicata. Ao avancar o atendimento, as duplicatas nao serao geradas. Deseja continuar? / Atencao
		Return .f.
	EndIf
EndIf

if VV0->VV0_VALTRO > 0 .and. left(GetNewPar("MV_MIL0057","2"),1) == "0"
	VX002ExibeHelp("VX002ERR012", STR0169+CHR(13)+CHR(10)+STR0170)//"Não é permitido a utilização de devolução/troco.Favor verificar a composição das parcelas!"
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Validar o % / Vlr de Entrada em relacao ao Total do Atendimento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nVlFinanc > 0
	If !VX005VLENT(VV9->VV9_NUMATE,aParFin[13],aVS9) // Nro do Atendimento / VAS->(RecNo())
		Return .f.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ A V A N C A    F A S E    D O    A T E N D I M E N T O ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lXX002Auto .or. MsgYesNo(STR0054,STR0011) // Avanca fase do atendimento? / Atencao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se houve alteracao que gera Log ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLogAlter
		VX002LOG()
	EndIf
	cFaseIni := VV9->VV9_STATUS
	lRetorno := VEIXI001(VV9->VV9_NUMATE,nOpc, lXX002Auto, , ,cFaseInter, cSerieNFAuto, nVlDevol )
	Return lRetorno
Else
	Return .f.
EndIf
//

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002SAIR ºAutor  ³ Andre Luis/Rubens  º Data ³  01/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Salvar o atendimento quando usuario clicar em cancelar na  º±±
±±º          ³ janela principal (SAIR)                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002SAIR(nOpc)
Local nCntHeader := 0
Local cVldUser := ""
Local cVldSyst := ""
Local cCpoRVar := ""
Local cTabRVar := ""
Local cReadVar := ""

If nOpc <> 3 .and. nOpc <> 4 // Diferente de Incluir e Alterar
	Return .t.
endif

If Empty( M->VV9_NUMATE ) // Nao foi gerado atendimento ...
	Return .t.
EndIf

/* Alex - Executar Valid e Campo Obrigatório quando usuário clicar em Cancelar, pois o protheus não dispara o Valid quando ocorre o cancelamento,
e a rotina salva as informações independente de qualquer operação. */
cCpoRVar := Subs(ReadVar(), 4)
cTabRVar := Left(cCpoRVar, 3)
If cTabRVar == "VV9" .OR. cTabRVar == "VV0"
	cVldSyst := GetSX3Cache(cCpoRVar, "X3_VALID")
	If !(Empty(cVldSyst))
		If !(&(cVldSyst))
			Return .F.
		Endif
	Endif 
	cVldUser := GetSX3Cache(cCpoRVar, "X3_VLDUSER")
	If !(Empty(cVldUser))
		If !(&(cVldUser))
			Return .F.
		Endif
	Endif 
	cReadVar := M->&(cCpoRVar)
	If X3Obrigat(cCpoRVar) .AND. Empty(cReadVar)
		Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(cCpoRVar)) + " (" + cCpoRVar + ")" ,4,1)
		Return .F.
	Endif
Endif

// Se for atendimento com N veiculos, verifica se existe pelo menos um veiculo
If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )
	If aScan(oGetDadVVA:aCols, { |x| !x[Len(x)] } ) == 0
		DbSelectArea("VVA")
		RegToMemory("VVA",.t.,.t.,.t.)
		RecLock("VVA",.f.)
			FG_GRAVAR("VVA")
			VVA->VVA_FILIAL := xFilial("VVA")
			VVA->VVA_NUMTRA := VV9->VV9_NUMATE
			If VVA->(ColumnPos("VVA_ITETRA")) > 0 // Atendimento N veiculos
				VVA->VVA_ITETRA := ""
			EndIf
		MsUnLock()
		oGetDadVVA:nAt := 1
		For nCntHeader := 1 to Len(oGetDadVVA:aHeader)
			If IsHeadRec(oGetDadVVA:aHeader[nCntHeader,2])
				oGetDadVVA:aCols[oGetDadVVA:nAt,nCntHeader] := 0
			ElseIf IsHeadAlias(oGetDadVVA:aHeader[nCntHeader,2])
				oGetDadVVA:aCols[oGetDadVVA:nAt,nCntHeader] := "VVA"
			Else
				oGetDadVVA:aCols[oGetDadVVA:nAt,nCntHeader] := CriaVar(oGetDadVVA:aHeader[nCntHeader,2],.t.)
			EndIf
		Next
	EndIf
EndIf
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o Atendimento      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !VX002GRV(nOpc,.f.)
	Return .f.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Solicita Tarefa Gravacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VEIVM130TAR(VV9->VV9_NUMATE,"1","1",VV9->VV9_FILIAL) // Tarefas: 1-Gravacao / 1-Atendimento

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002BTVLN  º Autor ³Andre Luis / Rubens º Data ³ 04/01/10 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Opcoes do Botao de Valores da Negociacao                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002BTVLN(cTp,nOpc,aPar1,aPar2,aPar3,aPar4,aPar5)
Local nSlvOpc := nOpc
Local lGravou := .f.

Default aPar1 := {}
Default aPar2 := {}
Default aPar3 := {}
Default aPar4 := {}
Default aPar5 := {}

If !VX002TUDOK(nOpc,.f.)
	Return
EndIf

If cVV9Status $ "POLFC"
	nOpc := 2
EndIf

VX002X3LOAD( "VS9" , .t. , @aPar2 , 1 , "VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE", xFilial("VS9")+PadR(M->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"V")
DbSelectArea("VS9")

Do Case
	Case cTp == "1" // Financiamento FI / Leasing
		If nOpc == 3 .or. nOpc == 4
			If ( M->VV9_CODCLI + M->VV9_LOJA ) == ( cCliPadrao + cLojPadrao )
				MsgAlert(STR0055,STR0011) // Para utilizar corretamente o Financiamento/Leasing, o Cliente/Loja informado no Atendimento deve ser diferente do Cliente/Loja Padrao informado nos Parametros da Rotina. / Atencao
			EndIf
		EndIf

		If VEIXX005(nOpc,@aPar1,@aPar2,@aPar3,.f.)	 	// ( nOpc / aParFin / aVS9 / aVSE / lZerar )
			VX002RPGRV(cTp,@aPar1,@aPar2,@aPar3)		// Preenche M-> para Financiamento FI / Leasing
			VX002GRV(nOpc,.f.,"VS9/VSE",@aPar2,@aPar3)	// nOpc / Tabelas a Serem Alteradas / aVS9 / aVSE
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ LEASING -> Fiscal para Cliente: Banco ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If M->VV0_CATVEN == "7" .and. !Empty(M->VV0_CLIALI+M->VV0_LOJALI)
				VX002GRV(nOpc,.f.,"",,) // Gravar M-> que possuem relacao com o FISCAL ( Cliente: Banco )
			EndIf

			lGravou := .t.
		EndIf

	Case cTp == "2" // Finame
		If VEIXX015(nOpc,@aPar1,@aPar2)					// ( nOpc / aParFna / aVS9 )
			VX002RPGRV(cTp,@aPar1,@aPar2)				// Preenche M-> para Finame
			VX002GRV(nOpc,.f.,"VS9",@aPar2)		 	// nOpc / Tabelas a Serem Alteradas / aVS9

			lGravou := .t.
		EndIf

	Case cTp == "3" // Financiamento Proprio
		If VEIXX009(nOpc,@aPar1,@aPar2)					// ( nOpc / aParPro / aVS9 )
			VX002RPGRV(cTp,@aPar1,@aPar2)				// Preenche M-> para Financiamento Proprio
			VX002GRV(nOpc,.f.,"VS9",@aPar2)			// nOpc / Tabelas a Serem Alteradas / aVS9

			lGravou := .t.
		EndIf

	Case cTp == "4" // Consorcio
		If VEIXX010(nOpc,@aPar1,@aPar2,@aPar3)			// ( nOpc / aParCon / aVS9 / aVSE )
			VX002GRV(nOpc,.f.,"VS9/VSE",@aPar2,@aPar3)	// nOpc / Tabelas a Serem Alteradas / aVS9 / aVSE

			lGravou := .t.
		EndIf

	Case cTp == "5" // Veiculo Usado
		If VEIXX008(nOpc,@aPar1,@aPar2)					// ( nOpc / aParUsa / aVS9 )
			VX002GRV(nOpc,.f.,"VS9",@aPar2)			// nOpc / Tabelas a Serem Alteradas / aVS9

			lGravou := .t.
		EndIf

	Case cTp == "6" // Entrada
		If VEIXX011(nOpc,@aPar1,@aPar2,@aPar3)			// ( nOpc / aParEnt / aVS9 / aVSE )
			VX002GRV(nOpc,.f.,"VS9/VSE",@aPar2,@aPar3)	// nOpc / Tabelas a Serem Alteradas / aVS9 / aVSE

			lGravou := .t.
		EndIf
EndCase

If lGravou
	If ExistBlock("VX002TABG") // Ponto de Entrada para gravar as informações em tabelas customizadas
		ExecBlock("VX002TABG", .f., .f., {cTp, nOpc})
	EndIf
EndIf

nOpc := nSlvOpc
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002X3LOADºAutor  ³ Andre Luis / Rubens º Data ³ 16/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega Matriz com aHeader e aCols                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAlias = Alias do Arquivo                                  º±±
±±º          ³ lLevSX3 = Levanta SX3 ?                                    º±±
±±º          ³ aVetor = Vetor que recebera aHeader e aCols (devera ser    º±±
±±º          ³          passado por referencia)                           º±±
±±º          ³ nIndice = Indice utilizado para montagem da aCols          º±±
±±º          ³ cCondicao = Campos utilizados na pesquisa da Tabela        º±±
±±º          ³ cVLCondicao = Valores utilizados na pesquisa da Tabela     º±±
±±º          ³ cCpoNView = Lista de campos que nao serao carregados       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002X3LOAD( cAlias , lLevSX3 , aVetor , nIndice , cCondicao , cVLCondicao , cCpoNView )

Local nCntFor, nUsado := 0
Local IncSalva

Default lLevSX3 := .t.
Default nIndice := 0 // Nao procura na Tabela
Default cCpoNView := ""

If lLevSX3

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa Vetor - [1] = aHeader ³
	//³                    [2] = aCols   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aVetor := { {} , {} }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Adiciona FILIAL para nao adicionar na aHeader ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCpoNView := AllTrim(cAlias)+"_FILIAL," + cCpoNView

	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cAlias)
	While !Eof() .And. (sx3->x3_arquivo==cAlias)
		If !(AllTrim(SX3->X3_CAMPO) $ cCpoNView)
			nUsado++
			Aadd(aVetor[1],{AllTrim(X3Titulo()),SX3->X3_CAMPO,		SX3->X3_PICTURE, 	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,     SX3->X3_VALID,		SX3->X3_USADO, 		SX3->X3_TIPO,;
							SX3->X3_F3,			 SX3->X3_CONTEXT,	X3CBOX(), 			SX3->X3_RELACAO })
		EndIf
		SX3->(dbSkip())
	End

Else

	aVetor[2] := {}

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega valores da Tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nIndice <> 0
	dbSelectArea(cAlias)
	dbSetOrder(nIndice)
	If DbSeek(cVLCondicao)
		IncSalva := Inclui
		Inclui := .f.
		While !(cAlias)->(Eof()) .and. &(cCondicao) == cVLCondicao
			AADD(aVetor[2],Array( nUsado + 1 ))
			For nCntFor:=1 to Len(aVetor[1])
				// Contexto do Campo Virtual
				If aVetor[1,nCntFor,10] == "V"
					aVetor[2,Len(aVetor[2]),nCntFor] := &(aVetor[1,nCntFor,12])
				Else
					aVetor[2,Len(aVetor[2]),nCntFor] := FieldGet(ColumnPos(aVetor[1,nCntFor,2]))
				EndIf
			Next
			aVetor[2,Len(aVetor[2]),nUsado+1] := .F. // Marca como registro NAO DELETADO
			dbSkip()
		Enddo
		Inclui := IncSalva
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao conseguiu carregar registros, cria uma linha em branco na aCols ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aVetor[2]) == 0

	aVetor[2] := { Array(nUsado + 1) }
	aVetor[2,1,nUsado+1] := .F.
	For nCntFor := 1 to nUsado
		aVetor[2,1,nCntFor] := CriaVar(aVetor[1,nCntFor,2])
	Next

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002INIFISºAutor  ³ Rubens             º Data ³  19/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inicializa Fiscal                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCodigo = Codigo do Cliente                                º±±
±±º          ³ cLoja = Loja do Cliente                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002INIFIS(cCodigo , cLoja, lAtuAParFin)

Default lAtuAParFin := .t.

SA1->(dbSetOrder(1))
If !SA1->(dbSeek(xFilial("SA1") + cCodigo + cLoja))
	Return
EndIf

If !MaFisFound('NF')
	MaFisIni(cCodigo,cLoja,'C','N',,MaFisRelImp("VEIXX002",{"VV0","VVA"}))
Else
	MaFisRef("NF_CODCLIFOR","VX001",cCodigo)
	MaFisRef("NF_LOJA","VX001",cLoja)
EndIf

If lAtuAParFin
	If ( cCliPadrao + cLojPadrao ) <> ( cCodigo + cLoja ) .and. !Empty( cCodigo + cLoja )
		aParFin[02] := SA1->A1_COD
		aParFin[03] := SA1->A1_LOJA
		aParFin[04] := SA1->A1_PESSOA
	EndIf
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002CONSV º Autor ³ Rubens             º Data ³ 19/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a Consulta Avancada de Veiculo                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002CONSV(lRetorno,nOpc,lMsg,aPRetFiltro,lVldStat,nLinVVA, lExecAuto)

Local aRetFiltro    := { VX002ADDRETFILTRO() }
Local cAuxTES       := ""
Local aVS9          := {{},{}}
Local aVSE          := {{},{}}
Local aVZ7          := {{},{}}
Local nCntFor       := 0
Local nCntHeader    := 0
Local nAuxValVei    := 0 // Valor do veiculo retornado da consulta
Local cNovoUsado    := ""
Local nProxFisc     := 0
Local lRestaura     := .f. // Controla se a linha da getdados esta sendo restaurada
Local nBkpN         := N
Local aIteTra       := {}
Local aPOSIteTra    := {} // Posicao do IteTra - utilizado para achar a Marca/Modelo/Cor da Oportunidade
Local cQuery        := ""
Local lAddFiscal
Default lMsg        := .f.
Default aPRetFiltro := {}
Default lVldStat    := .t.
Default nLinVVA     := 0
Default lExecAuto   := .f.

If ! lXX002Auto

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for inclusao ou alteração, deve ser informado o cliente ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRetorno .and. !VX002LIBDIG(nOpc,lMsg) //  .and. ( Empty(Alltrim(M->VV9_CODCLI+M->VV9_LOJA+M->VV9_NOMVIS)) .or. Empty(M->VV9_TELVIS) )
		return .f.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Nao chamar Consulta F7 quando Atendimento ja     ³
	//³ Aprovado / Finalizado ou nao for incluir/alterar ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( lVldStat .and. cVV9Status $ "L/F" ) .or. ( nOpc <> 3 .and. nOpc <> 4 )
		return .f.
	EndIf

	SetKey(VK_F4, Nil )
	SetKey(VK_F7, Nil )
	SetKey(VK_F10, Nil )
EndIf

// Verifica se o atendimento possui veiculo novo ou usado
cNovoUsado := " "

For nCntFor := 1 to Len(oGetDadVVA:aCols)

	If oGetDadVVA:aCols[nCntFor,Len(oGetDadVVA:aCols[nCntFor])]
		Loop
	EndIf

	// Linha em branco ...
	If Empty(oGetDadVVA:aCols[nCntFor,FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")]) .and. Empty(oGetDadVVA:aCols[nCntFor,FG_POSVAR("VVA_CODMAR","oGetDadVVA:aHeader")])
		cNovoUsado := " "
	Else
		If Empty(oGetDadVVA:aCols[nCntFor,FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")])
			cNovoUsado := "0"
		Else
			VV1->(dbSetOrder(1))
			VV1->(MsSeek(xFilial("VV1") + oGetDadVVA:aCols[nCntFor,FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")]))
			cNovoUsado := VV1->VV1_ESTVEI
		EndIf
	EndIf

	Exit
Next nCntFor
//
nCntFor := 0
aEval( oGetDadVVA:aCols , { |x| IIf( ( !Empty(x[FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")]) .or. !Empty(x[FG_POSVAR("VVA_CODMAR","oGetDadVVA:aHeader")]) ) .and. !x[Len(x)] , nCntFor++ , NIL ) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Consulta Avancada de Veiculos                                           ³
//³-------------------------------------------------------------------------³
//³ aRetFiltro = Retorno o Veiculo / Modelo / Cor /Progresso                ³
//³ [n,01] = Chassi Interno (CHAINT)                                        ³
//³ [n,02] = Estado do Veiculo (Novo/Usado)                                 ³
//³ [n,03] = Marca                                                          ³
//³ [n,04] = Grupo Modelo                                                   ³
//³ [n,05] = Modelo                                                         ³
//³ [n,06] = Cor                                                            ³
//³ [n,07] = Cod.Progresso                                                  ³
//³ [n,08] = Tipo (1-Normal/3-Venda Futura/4-Simulacao)                     ³
//³ [n,09] = Valor do Veiculo                                               ³
//³ [n,10] = Segmento                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aPRetFiltro) == 0
	// Inicializa o VV0_TIPFAT
	If Empty(M->VV9_NUMATE)
		M->VV0_TIPFAT := Space(Len(M->VV0_TIPFAT))
	EndIf
	//
	VEIXC001(lRetorno,@aRetFiltro,M->VV9_NUMATE,IIF(nAVEIMAX==1,0,nCntFor),cNovoUsado,M->VV0_TIPFAT,aInfCliente[6],M->VV9_CODCLI,M->VV9_LOJA)
	//
Else
	aRetFiltro := aClone(aPRetFiltro)
	If lExecAuto // Na Chamada de ExecAuto, deve forcar a criacao de um novo registro
		lRestaura := .f.
	Else
		lRestaura := .t.
	EndIf
EndIf

If ! lXX002Auto
	SetKey(VK_F4,{|| VX002FOTO(nOpc) })
	SetKey(VK_F7,{|| VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,,.t.) })
	SetKey(VK_F10,{|| VX002OPCOES(nOpc) })
EndIf

If lRetorno .and. (!Empty(aRetFiltro[1,01]) .or. !Empty(aRetFiltro[1,05]))

	nVlVeicu := 0
	If nAVEIMAX > 1
		aEval( oGetDadVVA:aCols , { |x| nVlVeicu += IIf( !x[Len(x)] , x[FG_POSVAR("VVA_VALTAB","oGetDadVVA:aHeader")] , 0 ) } )
	EndIf
	nAuxValVei := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o FISCAL, se nao for informado o codigo do cliente, utilizar o CLIENTE PADRAO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !MaFisFound('NF') .and. Empty(M->VV9_CODCLI)
		VX002INIFIS(cCliPadrao,cLojPadrao)
	EndIf
	//

	// Exclui bonus e custo com venda quando é atendimento de UM veiculo
	If nAVEIMAX == 1 .and. !Empty(M->VV9_NUMATE)
		VX002DEL(1, 1, nOpc)
	EndIf
	//

	For nCntFor := 1 to Len(aRetFiltro)

		// Pode adicionar mais de um veiculo no atendimento ...
		// se nao for faturamento direto ...
		If nAVEIMAX <> 1 .and. !lRestaura

			// Valida se o veiculo ja esta no atendimento
			If !Empty(aRetFiltro[nCntFor,01]) .and. aScan(oGetDadVVA:aCols, { |x| !x[Len(x)] .and. x[FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")] == aRetFiltro[nCntFor,1] } ) <> 0
				MsgAlert(STR0144,STR0011) // Veiculo ja esta no Atendimento. / Atencao
				Loop
			EndIf
			//

			lAddLine := .f.
			// Verifica se deve adicionar uma linha nova
			If nCntFor > Len(oGetDadVVA:aCols)
				lAddLine := .t.
			Else
				If lXX002Auto
					If nOpc == 3
						//cAuxReadVar := ReadVar()
						//Do Case
						//Case cAuxReadVar $ "M->VVA_MODVEI/M->VVA_SEGMOD"
						//	lAddLine := ! Empty(oGetDadVVA:aCols[nCntFor, FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")])
						//Case cAuxReadVar == "M->VVA_CHASSI/M->VVA_CHAINT"
						//	lAddLine := ! Empty(oGetDadVVA:aCols[nCntFor, FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")])
						//EndCase
						lAddLine := (Len(aCols) > Len(oGetDadVVA:aCols))
					ElseIf nOpc == 4
						If nAVEIMAX > 1
							//lAddLine := Empty(M->VVA_ITETRA)
							lAddLine := (Len(aCols) > Len(oGetDadVVA:aCols))
						Else
							lAddLine := .f.
						EndIf
					EndIf
				Else
					If ! Empty(oGetDadVVA:aCols[nCntFor, FG_POSVAR("VVA_CODMAR","oGetDadVVA:aHeader")])
						lAddLine := .t.
					EndIf
				EndIf
			EndIf

			// Adiciona registro na acols
			If lAddLine

				AADD( oGetDadVVA:aCols , Array(Len(oGetDadVVA:aHeader)+1) )
				oGetDadVVA:nAt := Len(oGetDadVVA:aCols)
				oGetDadVVA:aCols[ oGetDadVVA:nAt , Len(oGetDadVVA:aHeader)+1] := .F.
				For nCntHeader := 1 to Len(oGetDadVVA:aHeader)
					If IsHeadRec(oGetDadVVA:aHeader[nCntHeader,2])
						oGetDadVVA:aCols[oGetDadVVA:nAt,nCntHeader] := 0
					ElseIf IsHeadAlias(oGetDadVVA:aHeader[nCntHeader,2])
						oGetDadVVA:aCols[oGetDadVVA:nAt,nCntHeader] := "VVA"
					Else
						oGetDadVVA:aCols[oGetDadVVA:nAt,nCntHeader] := CriaVar(oGetDadVVA:aHeader[nCntHeader,2],.t.)
					EndIf
				Next

			EndIf
		EndIf

		If lRestaura
			oGetDadVVA:aCols[oGetDadVVA:nAt,Len(oGetDadVVA:aCols[oGetDadVVA:nAt])] := .f.
		Else
			If ! lXX002Auto
				// Atualiza variaveis de memoria do VVA atual
				oGetDadVVA:nAt := Len(oGetDadVVA:aCols)
				FG_MEMVAR(oGetDadVVA:aHeader, oGetDadVVA:aCols, oGetDadVVA:nAt)
				//
			EndIf
		EndIf
		If oGetDadVVA:nAt > Len(aParVZ7)
			// Acoes de Venda
			AADD( aParVZ7 , aClone( aStruVZ7 ) )
			//
		EndIf

		// Acerta o Numero Item do Atendimento
		If Empty(M->VVA_ITETRA)
			M->VVA_ITETRA := VX002ITEM()
			VX002ACOLS("VVA_ITETRA",oGetDadVVA:nAt)
		ElseIf lXX002Auto
			VX002ACOLS("VVA_ITETRA",oGetDadVVA:nAt)
		EndIf
		//

		aParOpc[01] := aRetFiltro[nCntFor,01]	// Chassi Interno (CHAINT)
		aParOpc[02] := aRetFiltro[nCntFor,03]	// Marca do Veiculo
		aParOpc[03] := aRetFiltro[nCntFor,05]	// Modelo do Veiculo

		aParFin[05] := aRetFiltro[nCntFor,01]	// Chassi Interno (CHAINT)
		aParFin[06] := aRetFiltro[nCntFor,02]	// Estado do Veiculo (0=Novo/1=Usado)
		aParFin[07] := aRetFiltro[nCntFor,04]	// Grupo do Modelo
		aParFin[08] := aRetFiltro[nCntFor,05]	// Modelo do Veiculo
		If oGetDadVVA:nAt > Len(aParFin[15])
			AADD(aParFin[15],{ "" , "" , "" , "" , "" } )
		EndIf
		aParFin[15,oGetDadVVA:nAt,01] := aRetFiltro[nCntFor,01] // Chassi Interno (CHAINT)
		aParFin[15,oGetDadVVA:nAt,02] := aRetFiltro[nCntFor,02] // Estado do Veiculo (0=Novo/1=Usado)
		aParFin[15,oGetDadVVA:nAt,03] := aRetFiltro[nCntFor,04] // Grupo do Modelo
		aParFin[15,oGetDadVVA:nAt,04] := aRetFiltro[nCntFor,05] // Modelo do Veiculo
		aParFin[15,oGetDadVVA:nAt,05] := aRetFiltro[nCntFor,03] // Marca do Veiculo

		// Acoes de Venda
		aParVZ7[oGetDadVVA:nAt,02] := aRetFiltro[nCntFor,01]	// Chassi Interno do Veiculo
		aParVZ7[oGetDadVVA:nAt,03] := aRetFiltro[nCntFor,03]	// Marca
		aParVZ7[oGetDadVVA:nAt,04] := aRetFiltro[nCntFor,05]	// Modelo
		aParVZ7[oGetDadVVA:nAt,05] := aRetFiltro[nCntFor,04]	// Grupo do Modelo
		aParVZ7[oGetDadVVA:nAt,07] := aRetFiltro[nCntFor,02]	// ESTVEI (Novo/Usado)
		aParVZ7[oGetDadVVA:nAt,10] := M->VVA_ITETRA			// Numero do Item no Atendimento
		//

		///////////////////////////////////////////
		// Limpa Variaveis do Faturamento Direto //
		///////////////////////////////////////////
		M->VVA_PERDVD := 0 // % Desconto
		M->VVA_VALDVD := 0 // Valor do Desconto
		M->VVA_PERCVD := 0 // % Comissao
		M->VVA_VALCVD := 0 // Valor de Comissao
		VX002ACOLS("VVA_PERDVD",oGetDadVVA:nAt)
		VX002ACOLS("VVA_VALDVD",oGetDadVVA:nAt)
		VX002ACOLS("VVA_PERCVD",oGetDadVVA:nAt)
		VX002ACOLS("VVA_VALCVD",oGetDadVVA:nAt)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regras para VV0_TIPFAT, VV0_OPEMOV, VV0_VDAFUT e VVA_SIMVDA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX002TIPFAT( .t. , aRetFiltro[1,08] , aRetFiltro[1,02] , oGetDadVVA:nAt )

		M->VVA_VALTAB := aRetFiltro[nCntFor,09] // Valor de Tabela do Veiculo
		M->VVA_VALVDA := aRetFiltro[nCntFor,09] // Valor de Tabela do Veiculo
		VX002ACOLS("VVA_VALTAB",oGetDadVVA:nAt)
		VX002ACOLS("VVA_VALVDA",oGetDadVVA:nAt)

		M->VVA_FILENT := ""
		M->VVA_TRACPA := ""
		VX002ACOLS("VVA_FILENT",oGetDadVVA:nAt)
		VX002ACOLS("VVA_TRACPA",oGetDadVVA:nAt)

		// Atendimento pelo CHAINT
		If !Empty(aRetFiltro[nCntFor,01])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Informacoes de campo VIRTUAL de veiculo      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			VX002VEIC(;
				aRetFiltro[nCntFor,01],; // cChaInt
				aRetFiltro[nCntFor,03],; // cCodMar
				aRetFiltro[nCntFor,04],; // cGruMod
				aRetFiltro[nCntFor,05],; // cModVei
				aRetFiltro[nCntFor,06],; // cCorVei
				,; // oObjEnch
				,; // lAtuaEnc
				aRetFiltro[nCntFor,10]) // cSegMod

			VV1->(dbSetOrder(1))
			If VV1->(MsSeek(xFilial("VV1")+aRetFiltro[nCntFor,01]))
				M->VVA_FILENT := VV1->VV1_FILENT
				M->VVA_TRACPA := VV1->VV1_TRACPA
				VX002ACOLS("VVA_FILENT",oGetDadVVA:nAt)
				VX002ACOLS("VVA_TRACPA",oGetDadVVA:nAt)
			EndIf

		// Atendimento pelo Modelo do Veiculo
		Else

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Informacoes de campo VIRTUAL de veiculo      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			VX002VEIC(;
				,; // cChaInt
				aRetFiltro[nCntFor,03],; // cCodMar
				aRetFiltro[nCntFor,04],; // cGruMod
				aRetFiltro[nCntFor,05],; // cModVei
				aRetFiltro[nCntFor,06],; // cCorVei
 				,;// oObjEnch
 				,;// lAtuaEnc
 				aRetFiltro[nCntFor,10])// cSegMod

		EndIf

		N := oGetDadVVA:nAt

		If MaFisFound("IT", N)
			MaFisRef("IT_PRODUTO","VX001",SB1->B1_COD)
			MaFisRef("IT_QUANT","VX001",1)
			lAddFiscal := .f.
		Else
			lAddFiscal := .t.
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ TES Inteligente ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ! Empty(M->VV0_CODTES) .or. ! Empty(M->VVA_CODTES)
			cAuxTES := IIf ( ! Empty(M->VVA_CODTES), M->VVA_CODTES , M->VVA_CODTES )
		EndIf
		If !Empty(M->VV9_CODCLI)
			If VV1->VV1_ESTVEI == "0" // Novos
				If !Empty(cTpOperNov)
					cAuxTES := MaTesInt(2,cTpOperNov,M->VV9_CODCLI,M->VV9_LOJA,"C",SB1->B1_COD)
				EndIf
			Else // Usados
				If !Empty(cTpOperUsa)
					cAuxTES := MaTesInt(2,cTpOperUsa,M->VV9_CODCLI,M->VV9_LOJA,"C",SB1->B1_COD)
				EndIf
			EndIf
		Else // Cliente Padrao
			If VV1->VV1_ESTVEI == "0" // Novos
				If !Empty(cTpOperNov)
					cAuxTES := MaTesInt(2,cTpOperNov,cCliPadrao,cLojPadrao,"C",SB1->B1_COD)
				EndIf
			Else // Usados
				If !Empty(cTpOperUsa)
					cAuxTES := MaTesInt(2,cTpOperUsa,cCliPadrao,cLojPadrao,"C",SB1->B1_COD)
				EndIf
			EndIf
		EndIf
		If Empty(cAuxTES) // Caso nao exista a regra no TES inteligente
			If VV1->VV1_ESTVEI == "0" // Novos
				cAuxTES := cTESDefNov // TES default para Veiculos Novos
			Else // Usados
				cAuxTES := cTESDefUsa // TES default para Veiculos Usados
			EndIf
		EndIf
		//
		If !Empty(cAuxTES)
			M->VV0_CODTES := cAuxTES
			M->VVA_CODTES := cAuxTES
			VX002ACOLS("VVA_CODTES",oGetDadVVA:nAt)
			If ! lAddFiscal
				MaFisRef("IT_TES","VX001",M->VVA_CODTES)
			EndIf

		EndIf
		//
		If VV1->VV1_ESTVEI == "0" // Novos
			M->VV0_OPER := cTpOperNov
			M->VVA_OPER := cTpOperNov
		Else // Usados
			M->VV0_OPER := cTpOperUsa
			M->VVA_OPER := cTpOperUsa
		EndIf
		VX002ACOLS("VVA_OPER  ",oGetDadVVA:nAt)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza Valores da Negociacao                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nVlVeicu   += aRetFiltro[nCntFor,09]
		nAuxValVei := aRetFiltro[nCntFor,09]

		If lAddFiscal
			VX0020063_FiscalAdProduto( N , nVlVeicu , M->VVA_CODTES , SB1->B1_COD )
		EndIf
		VX002VALVEI(nOpc,.f.,nAuxValVei, ! lXX002Auto )

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Levanta todas Acoes de Venda Automaticamente              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aParVZ7[nCntFor,01] := M->VV9_NUMATE	// Nro do Atendimento
		VX002X3LOAD( "VZ7" , .t. , @aVZ7 )
		If VEIXX003(nOpc,.f.,@aParVZ7,"",@aVZ7,M->VVA_ITETRA, lXX002Auto)
			If ! lXX002Auto
				VX002GRV(nOpc,.f.,"VZ7",,,@aVZ7)
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava Bonus obrigatorios                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VEIXX014( M->VV9_NUMATE , aRetFiltro[nCntFor,03] , aRetFiltro[nCntFor,04] , aRetFiltro[nCntFor,05] , nOpc , .F. , M->VV0_TIPFAT , oGetDadVVA:aCols[oGetDadVVA:nAt,nVVARECNO] )
		//

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Levanta Sugestao da Dt.Entrega do Veiculo/Modelo          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aEntrVei[01] := M->VV9_NUMATE								// Numero do Atendimento
		aEntrVei[02] := aRetFiltro[nCntFor,01]						// Chassi Interno (CHAINT)
		aEntrVei[03] := aRetFiltro[nCntFor,03]						// Marca do Veiculo
		aEntrVei[04] := aRetFiltro[nCntFor,05]						// Modelo do Veiculo
		aEntrVei[08] := oGetDadVVA:aCols[oGetDadVVA:nAt,nVVARECNO]	// Recno da VVA
		aEntrVei[13] := aRetFiltro[nCntFor,10]						// Segmento do Veiculo
		VEIXX006(nOpc,@aEntrVei,.f.)

		// Reservar o veiculo se tiver regra ...
		If M->VV0_OPEMOV == "0" .and. !Empty(VVA->VVA_CHAINT)
			VEIXX004(nOpc,VV9->VV9_NUMATE,VVA->VVA_CHAINT,"1",M->VVA_ITETRA)
		EndIf
		//
		VV2->(dbSetOrder(1))
		VVC->(dbSetOrder(1))
		If !Empty(M->VVA_CODMAR)
			FGX_VV2(M->VVA_CODMAR, M->VVA_MODVEI, IIf( lVVASEGMOD , M->VVA_SEGMOD , "" ) )
			VVC->(MsSeek(xFilial("VVC")+M->VVA_CODMAR+M->VVA_CORVEI))
			aAdd(aIteTra,M->VVA_ITETRA+"="+Alltrim(M->VVA_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)+" - "+Alltrim(VVC->VVC_DESCRI)+" - "+Alltrim(M->VVA_CHASSI))
			aAdd(aPOSIteTra,M->VVA_CODMAR+M->VVA_MODVEI+M->VVA_CORVEI)
		Else
			FGX_VV2(M->VV0_CODMAR, M->VV0_MODVEI, IIF( lVVASEGMOD , M->VV0_SEGMOD , "" ) )
			VVC->(MsSeek(xFilial("VVC")+M->VV0_CODMAR+M->VV0_CORVEI))
			aAdd(aIteTra,M->VVA_ITETRA+"="+Alltrim(M->VV0_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)+" - "+Alltrim(VVC->VVC_DESCRI)+" - "+Alltrim(M->VV0_CHASSI))
			aAdd(aPOSIteTra,M->VV0_CODMAR+M->VV0_MODVEI+M->VV0_CORVEI)
		EndIf
		//
	Next nCntFor

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravar no Interesse do Cliente ( Oportunidade Negocios )      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If nOpc == 3 .or. nOpc == 4
		If len(aRetFiltro) > 0 .and. len(aInfCliente[6]) > 0
			cQuery := "SELECT R_E_C_N_O_ FROM "+RetSQLName("VDM")+" WHERE VDM_FILIAL='"+xFilial("VDM")+"' AND VDM_FILATE='"+xFilial("VV9")+"' AND VDM_NUMATE='"+M->VV9_NUMATE+"' AND VDM_ITETRA='"+M->VVA_ITETRA+"' AND D_E_L_E_T_=' '"
			If FM_SQL(cQuery) == 0 // veiculo ainda nao esta vinculado com alguma Oportunidade/Interesse
				VX002GRVOPO(aInfCliente[6],aIteTra,aPOSIteTra,nLinVVA) // Gravar Filial e Nro do Atendimento no Interesse do Cliente na Oportunidade de Negocio
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Regras para VV0_TIPFAT, VV0_OPEMOV, VV0_VDAFUT e VVA_SIMVDA   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VX002TIPFAT( .F. , , , )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Quando incluir um Veiculo deve ZERAR o Financiamento/Leasing  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VX002X3LOAD( "VS9" , .t. , @aVS9 , 1 , "VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE", xFilial("VS9")+PadR(M->VV9_NUMATE,TamSX3("VS9_NUMIDE")[1]," ")+"V")
	VX002X3LOAD( "VSE" , .t. , @aVSE )
	If VEIXX005(nOpc,@aParFin,@aVS9,@aVSE,.t.)		// ( nOpc / aParFin / aVS9 / aVSE / lZerar )
		If ! lXX002Auto
			VX002RPGRV("1",@aParFin,@aVS9,@aVSE)		// Preenche M-> para Financiamento FI / Leasing
			VX002GRV(nOpc,.f.,"VS9/VSE",@aVS9,@aVSE)	// nOpc / Tabelas a Serem Alteradas / aVS9 / aVSE
		EndIf
	EndIf

	VX002HABIL(.T.)
	If !lXX002Auto
		oVlVeicu:SetFocus()
	EndIf

	//#############################################################################
	//# Ponto de Entrada logo após a seleção do veículo(F7)                       #
	//#############################################################################
	If ExistBlock("VXX02RF7")
		ExecBlock("VXX02RF7",.f.,.f.)
	EndIf
EndIf

If nVerAten == 3 .and. !lXX002Auto// Versao 3 ( Atendimento N veiculos )
	// Reposiciona a GetDados, pois no refresh as variaveis (M->VVA_????) nao estavam sendo atualizadas ...
	oGetDadVVA:GoTo(oGetDadVVA:nAt)
	oGetDadVVA:Refresh()
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002VALVEIºAutor  ³ Rubens             º Data ³ 19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida alteracao e atualiza do valor do Veiculo no FISCAL  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc    = nOpc da rotina                                   º±±
±±º          ³ lVldVlr = Valida valor do veiculo                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002VALVEI(nOpc, lVldVlr, nPVlVeicu, lGravar, nPosGetD)

Local aTotVZ7  := {}
Local lModVlr  := .f. // Modifica valor (VVA_VALMOV) para nao dar erro de OBRIGAT
Local nBkpN := N
Local aUltMov := {}
Local ni      := 0

Default nPVlVeicu := nVlVeicu
Default lGravar := .t.
Default nPosGetD := oGetDadVVA:nAt

If nPVlVeicu <= 0
	If lVldVlr // Valida valor informado?
		VX002ExibeHelp("VX002ERR004",STR0056) // Favor informar um valor maior do que zero! / Atencao)
		Return .f.
	Else
		MsgAlert(STR0056,STR0011) // Favor informar um valor maior do que zero! / Atencao
	EndIf
	lModVlr := .t. // Modifica valor (VVA_VALMOV) para nao dar erro de OBRIGAT
EndIf


VX002CONOUT("VX002VALVEI")

If MaFisFound('NF') .and. nPosGetD > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula valores de Acoes de Venda    ³
	//³ Para somar no valor da mercadoria    ³
	//³ [1] - SOMA NO TOTAL DO ATENDIMENTO   ³
	//³ [2] - TROCO                          ³
	//³ [3] - CORTESIA                       ³
	//³ [4] - REDUTOR                        ³
	//³ [5] - VENDA AGREGADA                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aTotVZ7	:= VX003TOTAL(M->VV9_NUMATE, oGetDadVVA:aCols[ nPosGetD , FG_POSVAR("VVA_ITETRA","oGetDadVVA:aHeader") ] )

	N := nPosGetD
	MaFisRef("IT_PRCUNI","VX001",nPVlVeicu)
	MaFisRef("IT_VALMERC","VX001",nPVlVeicu+aTotVZ7[1])

	If M->VV0_TIPFAT == "1" // Veiculo Usado
		aUltMov := FM_VEIMOVS( oGetDadVVA:aCols[ nPosGetD , FG_POSVAR("VVA_CHASSI","oGetDadVVA:aHeader") ] , "E"  )
		For ni := 1 to Len(aUltMov)
			If aUltMov[ni,5] == "0" // Entrada por Compra
				VVF->(DbSetOrder(1))
				If VVF->(MsSeek(aUltMov[ni,2]+aUltMov[ni,3]))
					SD1->(DbSetOrder(1))
					cProdSB1 := MaFisRet(n,"IT_PRODUTO")
					If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+cProdSB1))
						MaFisRef("IT_NFORI","VX001",SD1->D1_DOC)
						MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
						MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
				    Endif
				EndIf
				Exit
			Endif
		Next
	Endif

EndIf

// Valor de Tabela do Veiculo
M->VVA_VALTAB := nPVlVeicu
VX002ACOLS("VVA_VALTAB",nPosGetD)
M->VVA_VALVDA := nPVlVeicu
VX002ACOLS("VVA_VALVDA",nPosGetD)

VX002ATFIS(.t.,.t.,nPosGetD) // Atualiza M-> que possuem relacao com o FISCAL

If lGravar
	If lModVlr // Modifica valor (VVA_VALMOV) para nao dar erro de OBRIGAT
		M->VVA_VALMOV := 0.01
	EndIf
	If VX002TUDOK(nOpc,.f.)
		If lModVlr // Volta valor modificado (VVA_VALMOV) para nao dar erro de OBRIGAT
			M->VVA_VALMOV := 0
		EndIf
		VX002GRV(nOpc,.f.)
	Else
		If lModVlr // Volta valor modificado (VVA_VALMOV) para nao dar erro de OBRIGAT
			M->VVA_VALMOV := 0
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Roda o Mapa para ver a caretinha atual ... ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	VX002MAPAV()

EndIf

N := nBkpN

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002ATFISºAutor  ³ Rubens             º Data ³  19/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza Campos que possuem relacao com o Fiscal           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ lAtuaVar - Atualiza Var. Totalizadoras do Atendimento      º±±
±±º          ³ lAtuaEnc - Atualiza Enchoice do Atendimento                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002ATFIS(lAtuaVar,lAtuaEnc,nPosGetD)

Local nCntFor
Local lDeletada := .f.
Local nBkpN := N

Default lAtuaVar := .t.
Default lAtuaEnc := .t.
Default nPosGetD := oGetDadVVA:nAt

If !MaFisFound('NF')
	return .f.
EndIf

N := nPosGetD
If !MaFisFound("IT",n)
	N := nBkpN
	return .f.
EndIf

VX002Conout("VX002ATFIS", lAtuaVar)

// Verifica se linha enviada esta excluida
If nPosGetD > 0 .and. Len(oGetDadVVA:aCols) > 0
	lDeletada := oGetDadVVA:aCols[nPosGetD,Len(oGetDadVVA:aCols[nPosGetD])]
EndIf
//

dbSelectArea("VV0")

If !Empty(M->VV0_CLIENT) .AND. !Empty(M->VV0_LOJENT)
	MaFisRef("NF_CODCLIFOR","VX001",M->VV0_CLIENT)
	MaFisRef("NF_LOJA","VX001",M->VV0_LOJENT)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ LEASING -> Fiscal para Cliente: Banco ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If M->VV0_CATVEN == "7" .and. !Empty(M->VV0_CLIALI+M->VV0_LOJALI) .and. !lDeletada
	MaFisRef("NF_CODCLIFOR","VX001",M->VV0_CLIALI)
	MaFisRef("NF_LOJA","VX001",M->VV0_LOJALI)
EndIf


If ( VV0->(ColumnPos("M->VV0_TPFRET")) > 0 )
	MaFisRef("NF_TPFRETE","VX001",M->VV0_TPFRET)
Endif
For nCntFor := 1 to Len(aFisVV0)
	if aFisVV0[nCntFor,2] <> "VV0_TPFRET"
		&('M->' + aFisVV0[nCntFor,2]) := MaFisRet(n,aFisVV0[nCntFor,3])
	Endif
Next nCntFor

For nCntFor := 1 to Len(aFisVVA)
	If !( aFisVVA[nCntFor,2] $ "VVA_DESVEI/VVA_TOTDES/VVA_LUCLQ1/VVA_LUCLQ2" ) // TEMPORARIO

		&('M->' + aFisVVA[nCntFor,2]) := MaFisRet(n,aFisVVA[nCntFor,3])

		// Atualiza aCols
		VX002ACOLS( aFisVVA[nCntFor,2] , nPosGetD)
		//

	EndIf
Next nCntFor

// Acerta o valor do veiculo, pois o VALID esta com referencia do fiscal errada
M->VVA_VALVDA := MaFisRet(n,"IT_PRCUNI")
VX002ACOLS("VVA_VALVDA",nPosGetD)
//

N := nPosGetD
M->VV0_IMPOST := MaFisRet(,"NF_VALIPI")+MaFisRet(,"NF_VALSOL")+MaFisRet(,"NF_VALICM")+MaFisRet(,"NF_VALCMP")+MaFisRet(,"NF_DIFAL")
If nVerAten == 2 // Versao 2
	M->VV0_ALIICM := MaFisRet(n,"IT_ALIQICM")
EndIf

VX002Conout("VX002ATFIS", MaFisRet(,"NF_TOTAL"))
If lAtuaVar
	nVlAtend := MaFisRet(,"NF_TOTAL")
	// Atualiza Valor DEVOLUCAO / SALDO RESTANTE //
	If nVlAtend < nVlNegoc
		nVlDevol := nVlNegoc - nVlAtend
	ElseIf nVlAtend > nVlNegoc
		nVlSaldo := nVlAtend - nVlNegoc
	EndIf
EndIf

If lAtuaEnc .AND. ! lXX002Auto
	oEnchVV0:Refresh()
	oEnchVV9:Refresh()
EndIf

N := nBkpN

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002VEIC ºAutor  ³ Rubens             º Data ³  21/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualizacao dos dados do Veiculo                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002VEIC(cChaInt,cCodMar,cGruMod,cModVei,cCorVei,oObjEnch,lAtuaEnc,cSegMod)

Local lExistSB1  := .f. // Controla se existe SB1
Local nRecVQ0    := 0

Default cChaInt  := ""
Default cCodMar  := ""
Default cGruMod  := ""
Default cModVei  := ""
Default cCorVei  := ""
Default oObjEnch := oEnchVV0
Default lAtuaEnc := .t.
Default cSegMod  := ""

VX002CONOUT("VX002VEIC")

VV1->(dbSetOrder(1))

M->VV0_CHAINT := cChaInt
M->VVA_CHAINT := cChaInt
VX002ACOLS("VVA_CHAINT")

If !Empty(cChaInt) .and. VV1->(MsSeek(xFilial("VV1")+cChaInt))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa Informacoes pelo CHAINT                                              ³
	//³ Se nao encontrar CHAINT no VV1, pode ser tratar de um atendimento por PROGRESSO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nVerAten == 2 // Versao 2

		M->VV9_CODMAR := VV1->VV1_CODMAR
		M->VV9_MODVEI := VV1->VV1_MODVEI
		If lVVASEGMOD
			M->VV9_SEGMOD := VV1->VV1_SEGMOD
		EndIf

		M->VV0_CHASSI := VV1->VV1_CHASSI
		M->VV0_CODMAR := VV1->VV1_CODMAR
		M->VV0_MODVEI := VV1->VV1_MODVEI
		If lVVASEGMOD
			M->VV0_SEGMOD := VV1->VV1_SEGMOD
		EndIf
		M->VV0_FABMOD := VV1->VV1_FABMOD
		M->VV0_CORVEI := VV1->VV1_CORVEI
		M->VV0_PLAVEI := VV1->VV1_PLAVEI

	EndIf

	SB1->(dbSetOrder(7))
	If FGX_VV1SB1("CHAINT", cChaInt , /* cMVMIL0010 */ , cGruVei)
		lExistSB1 := .T.
	EndIf

	FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, IIF( lVVASEGMOD , VV1->VV1_SEGMOD , "" ) )

	M->VVA_CHASSI := VV1->VV1_CHASSI
	M->VVA_CODMAR := cCodMar := VV1->VV1_CODMAR
	M->VVA_GRUMOD := cGruMod := VV2->VV2_GRUMOD
	M->VVA_MODVEI := cModVei := VV1->VV1_MODVEI
	If lVVASEGMOD
		M->VVA_SEGMOD := cSegMod := VV1->VV1_SEGMOD
	EndIf
	M->VVA_CORVEI := cCorVei := VV1->VV1_CORVEI
	VX002ACOLS("VVA_CHASSI")
	VX002ACOLS("VVA_CODMAR")
	VX002ACOLS("VVA_GRUMOD")
	VX002ACOLS("VVA_MODVEI")
	If lVVASEGMOD
		VX002ACOLS("VVA_SEGMOD")
	EndIf
	VX002ACOLS("VVA_CORVEI")

	M->VVA_ESTVEI := VV1->VV1_ESTVEI
	VX002ACOLS("VVA_ESTVEI")

	M->VVA_CENCUS := VV1->VV1_CC
	M->VVA_CONTA  := VV1->VV1_CONTA
	M->VVA_CLVL   := VV1->VV1_CLVL
	M->VVA_ITEMCT := VV1->VV1_ITEMCC
	VX002ACOLS("VVA_CENCUS")
	VX002ACOLS("VVA_CONTA")
	VX002ACOLS("VVA_CLVL")
	VX002ACOLS("VVA_ITEMCT")

	M->VVA_CODPED := "" // Codigo do Pedido Fabrica ( VQ0_CODIGO )
	M->VVA_NUMPED := "" // Numero do Pedido Fabrica ( VQ0_NUMPED )
	If VV1->VV1_ESTVEI == "0" //Novo
		nRecVQ0 := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSQLName("VQ0")+" WHERE VQ0_FILIAL='"+xFilial("VQ0")+"' AND VQ0_CHAINT='"+VV1->VV1_CHAINT+"' AND D_E_L_E_T_=' '")
		If nRecVQ0 > 0
			VQ0->(DbGoTo(nRecVQ0))
			M->VVA_CODPED := VQ0->VQ0_CODIGO
			M->VVA_NUMPED := VQ0->VQ0_NUMPED
		EndIf
	EndIf
	VX002ACOLS("VVA_CODPED")
	VX002ACOLS("VVA_NUMPED")

Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa Informacoes pelo Modelo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If nVerAten == 2 // Versao 2

		M->VV9_CODMAR := cCodMar
		M->VV9_MODVEI := cModVei
		If lVVASEGMOD
			M->VV9_SEGMOD := cSegMod
		EndIf

		M->VV0_CHASSI := Space(TamSX3("VV0_CHASSI")[1])
		M->VV0_CODMAR := cCodMar
		M->VV0_MODVEI := cModVei
		If lVVASEGMOD
			M->VV0_SEGMOD := cSegMod
		EndIf
		M->VV0_FABMOD := Space(TamSX3("VV0_FABMOD")[1])
		M->VV0_CORVEI := cCorVei
		M->VV0_PLAVEI := Space(TamSX3("VV0_PLAVEI")[1])

	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona o SB1 pelo produto cadastrado no GRUPO DE MODELO ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(cGruMod)
		If FGX_VV2(cCodMar, cModVei, IIF( lVVASEGMOD , cSegMod , "" ) )
			cGruMod := VV2->VV2_GRUMOD
		EndIf
	EndIf

	M->VVA_CENCUS := SB1->B1_CC
	M->VVA_CONTA  := SB1->B1_CONTA
	M->VVA_CLVL   := SB1->B1_CLVL
	M->VVA_ITEMCT := SB1->B1_ITEMCC
	VX002ACOLS("VVA_CENCUS")
	VX002ACOLS("VVA_CONTA")
	VX002ACOLS("VVA_CLVL")
	VX002ACOLS("VVA_ITEMCT")

	M->VVA_ESTVEI := "0" // Veiculo Novo
	VX002ACOLS("VVA_ESTVEI")

	M->VVA_CHASSI := Space(TamSX3("VV0_CHASSI")[1])
	M->VVA_CODMAR := cCodMar
	M->VVA_GRUMOD := cGruMod
	M->VVA_MODVEI := cModVei
	If lVVASEGMOD
		M->VVA_SEGMOD := cSegMod
	EndIf
	M->VVA_CORVEI := cCorVei
	M->VVA_CODPED := "" // Codigo do Pedido Fabrica ( VQ0_CODIGO )
	M->VVA_NUMPED := "" // Numero do Pedido Fabrica ( VQ0_NUMPED )
	VX002ACOLS("VVA_CHASSI")
	VX002ACOLS("VVA_CODMAR")
	VX002ACOLS("VVA_GRUMOD")
	VX002ACOLS("VVA_MODVEI")
	If lVVASEGMOD
		VX002ACOLS("VVA_SEGMOD")
	EndIf
	VX002ACOLS("VVA_CORVEI")
	VX002ACOLS("VVA_CODPED")
	VX002ACOLS("VVA_NUMPED")

EndIf

// Marca
VE1->(dbSetOrder(1))
If VE1->(dbSeek(xFilial("VE1")+cCodMar))
	M->VV0_DESMAR := VE1->VE1_DESMAR
	M->VVA_DESMAR := VE1->VE1_DESMAR
Else
	M->VV0_DESMAR := Space(TamSX3("VV0_DESMAR")[1])
	M->VVA_DESMAR := Space(TamSX3("VV0_DESMAR")[1])
EndIf
VX002ACOLS("VVA_DESMAR")

// Modelo
If FGX_VV2(cCodMar, cModVei, IIF( lVVASEGMOD , cSegMod , "" ) )
	M->VV0_GRUMOD := VV2->VV2_GRUMOD
	M->VV0_DESMOD := VV2->VV2_DESMOD
	M->VVA_GRUMOD := VV2->VV2_GRUMOD
	M->VVA_DESMOD := VV2->VV2_DESMOD
Else
	M->VV0_DESMOD := Space(TamSX3("VV0_DESMOD")[1])
	M->VV0_GRUMOD := Space(TamSX3("VV0_GRUMOD")[1])
	M->VVA_DESMOD := Space(TamSX3("VV0_DESMOD")[1])
	M->VVA_GRUMOD := Space(TamSX3("VV0_GRUMOD")[1])
EndIf
VX002ACOLS("VVA_DESMOD")
VX002ACOLS("VVA_GRUMOD")

// Grupo de Modelo
VVR->(dbSetOrder(2))
If VVR->(dbSeek(xFilial("VVR")+cCodMar+VV2->VV2_GRUMOD))
	M->VV0_DESGRU := VVR->VVR_DESCRI
Else
	M->VV0_DESGRU := Space(TamSX3("VV0_DESGRU")[1])
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deve posicionar a SB1 com o Produto 'Veiculo' do Grupo de Modelo (VVR) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lExistSB1
	//
	// ???????????????????????????????
	// Ajustar posicionamento da SB1 ???????????????????
	//
	If VV2->(ColumnPos("VV2_PRODUT")) > 0 .and. !Empty(VV2->VV2_PRODUT)
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+VV2->VV2_PRODUT)) // Produto do Modelo
	Else
		If !VVR->(Found()) .or. Empty(VVR->VVR_PROD)
			MsgAlert(STR0057,STR0011) // Modelo sem produto relacionado, favor verificar o cadastro de Grupos de Modelos / Atencao
		EndIf
		SB1->(dbSetOrder(1))
		SB1->(dbSeek(xFilial("SB1")+VVR->VVR_PROD)) // Produto do Grupo do Modelo
	EndIf
	//
EndIf

// Cores
VVC->(dbSetOrder(1))
If VVC->(MsSeek(xFilial("VVC")+cCodMar+cCorVei))
	M->VV0_DESCOR := VVC->VVC_DESCRI
	M->VVA_DESCOR := VVC->VVC_DESCRI
Else
	M->VV0_DESCOR := Space(TamSX3("VV0_DESCOR")[1])
	M->VVA_DESCOR := Space(TamSX3("VV0_DESCOR")[1])
EndIf
VX002ACOLS("VVA_DESCOR")

If lAtuaEnc .and. ! lXX002Auto
	oObjEnch:Refresh()
EndIf

Return .t. // Retorna .t. pois esta no valid do SX3

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002INFORM  ºAutor  ³ Rubens          º Data ³  21/04/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualizar Informacoes da Tabela VVA                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002INFORM(cAuxAlias)
Local nCntFor
Local aObjects  := {} , aPos := {} , aInfo := {}
Local aSizeHalf := MsAdvSize(.t.)
Local aAuxCpoAlias := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da Enchoice ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nModelo   := 3
Local cTudoOk   := ".t."
Local lF3       := .f.
Local lMemoria  := .t.
Local lColumn   := .f.
Local cATela    := ""
Local lNoFolder := .t.
Local lProperty := .f.
Local nRet      := 0
Local lIncSalva := INCLUI
Local lAltSalva := ALTERA

SX3->(DbSetOrder(1))
SX3->(dbSeek(cAuxAlias))
While !Eof().and.(SX3->x3_arquivo==cAuxAlias)
	If X3USO(SX3->x3_usado).and.cNivel>=SX3->X3_NIVEL
		AADD(aAuxCpoAlias,SX3->x3_campo)
	EndIf
	SX3->(DbSkip())
Enddo
DbSelectArea(cAuxAlias)

aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela

// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 0,  0, .T. , .T. } )
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oTelaInform TITLE ( STR0059+" - "+cAuxAlias ) FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] OF oMainWnd PIXEL // Outras Informacoes

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta Enchoice da VVA³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oEnchInform := MSMGet():New( cAuxAlias, &(cAuxAlias+"->(Recno())"), 2 ,;
/*aCRA*/, /*cLetra*/, /*cTexto*/, aAuxCpoAlias, aPos[1], , nModelo,;
/*nColMens*/, /*cMensagem*/, cTudoOk, oTelaInform, lF3, lMemoria, .F. /*lColumn*/ ,;
caTela, .f., lProperty)

ACTIVATE MSDIALOG oTelaInform ON INIT (EnchoiceBar(oTelaInform, {|| oTelaInform:End()},{ || oTelaInform:End()},,))

INCLUI := lIncSalva // Volta o Inclui pq perde na funcao MSMGet()
ALTERA := lAltSalva // Volta o Altera pq perde na funcao MSMGet()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002RPGRV  º Autor  ³ Rubens         º Data ³  21/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Replica Informacoes da VV0 para a VVA para a gravacao do   º±±
±±º          ³ atendimento, deve ser executado antes de gravar o atend.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002RPGRV(cTp,aPar1,aPar2,aPar3,aPar4,aPar5,nPosGetD)
Local aAux    := {}
Default cTp   := ""
Default aPar1 := {}
Default aPar2 := {}
Default aPar3 := {}
Default aPar4 := {}
Default aPar5 := {}
Default nPosGetD := oGetDadVVA:nAt

VX002CONOUT("VX002RPGRV", cTp)

Do Case
	Case Empty(cTp) // Dados Gerais
		VV1->(dbSetOrder(1))
		If !Empty(M->VVA_CHAINT) .and. VV1->(MsSeek(xFilial("VV1")+M->VVA_CHAINT))
			M->VVA_ESTVEI := VV1->VV1_ESTVEI
			M->VVA_CODORI := VV1->VV1_CODORI
			If Empty(M->VVA_ESTVEI)
				M->VVA_ESTVEI := "0" // Veiculo Novo ...
			EndIf
			If Empty(M->VVA_CODORI)
				M->VVA_CODORI := "0" // Fabrica ...
			EndIf
		Else
			M->VVA_ESTVEI := "0" // Veiculo Novo ...
			M->VVA_CODORI := "0" // Fabrica ...
		EndIf
		VX002CONOUT("VX002RPGRV", "M->VVA_ESTVEI - " + M->VVA_ESTVEI)
		VX002ACOLS("VVA_ESTVEI",nPosGetD)
		VX002ACOLS("VVA_CODORI",nPosGetD)
		M->VV0_TOTENT := FM_SQL("SELECT SUM(VS9.VS9_VALPAG) AS VALOR FROM "+RetSQLName("VS9")+" VS9 , "+RetSQLName("VSA")+" VSA WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+M->VV9_NUMATE+"' AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' ' AND VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='5' AND VSA.D_E_L_E_T_=' '")
		M->VV0_VCARCR := FM_SQL("SELECT SUM(VS9.VS9_VALPAG) AS VALOR FROM "+RetSQLName("VS9")+" VS9 , "+RetSQLName("VSA")+" VSA WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+M->VV9_NUMATE+"' AND VS9.VS9_TIPOPE='V' AND VS9.D_E_L_E_T_=' ' AND VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO='3' AND VSA.D_E_L_E_T_=' '")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza a Categoria, Tipo de Venda e Cliente/Loja Alienacao ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aAux := VX002CATVEN(M->VV9_NUMATE)
		M->VV0_CATVEN := aAux[1] // Categoria de Venda
		M->VV0_TIPVEN := aAux[2] // Tipo de Venda
		M->VV0_CLIALI := aAux[3] // Cliente Alienacao
		M->VV0_LOJALI := aAux[4] // Loja Cliente Alienacao
		M->VV0_TIPO   := "N" // VV0_TIPO = 'N' ( SA1 -> Cliente )
		M->VV0_VALNEG := M->VV0_VALMOV
		M->VV0_CODCLI := M->VV9_CODCLI
		M->VV0_LOJA   := M->VV9_LOJA
		If Empty(M->VV0_DTHEMI)
			M->VV0_DTHEMI := left(Dtoc(dDataBase),6) + right(Dtoc(dDataBase),2) + "/" + Time() // Dia/Mes/Ano(2 posicoes)/Hora:Minuto:Segundo
		EndIf
		M->VV0_VALTRO := nVlDevol // Devolucao para o Cliente
		////////////////////////////////////////////////////////////
		// Campos Customizados ( M->VVA_?????? := M->VV0_?????? ) //
		////////////////////////////////////////////////////////////
		If ExistBlock("VX002RPG")
			ExecBlock("VX002RPG",.f.,.f.)
		EndIf

	Case cTp == "1" // Financiamento FI / Leasing
		M->VV0_VALFIN := aPar1[01] // aParFin - Valor do Financiamento FI / Leasing
		M->VV0_CODBCO := aPar1[09] // aParFin - Banco FI
		M->VV0_TABFAI := aPar1[10] // aParFin - Tabela FI
		M->VV0_DIA1PC := 0
		M->VV0_PARCEL := 0
		M->VV0_INTERV := 0
		M->VV0_COEFIC := 0
		M->VV0_VALTAC := 0
		M->VV0_TACLIQ := 0
		M->VV0_TACFIN := "0"
		M->VV0_TACSUB := "0"
		M->VV0_SUBFIN := 0
		M->VV0_PTXRET := 0
		M->VV0_VTXRET := 0
		M->VV0_PCUSFN := 0
		M->VV0_VCUSFN := 0
		M->VV0_PREBFN := 0
		M->VV0_VALREB := 0
		M->VV0_PCOMFN := 0
		M->VV0_VCOMFN := 0
		If aPar1[13]+aPar1[14] > 0
			VAS->(DbGoTo(aPar1[13])) // aParFin - VAS->RecNo()
			VAR->(DbGoTo(aPar1[14])) // aParFin - VAR->RecNo()
			M->VV0_DIA1PC := val(VAS->VAS_PPARVI)
			M->VV0_PARCEL := val(VAS->VAS_QTDPAR)
			M->VV0_INTERV := val(VAS->VAS_INTERV)
			M->VV0_COEFIC := VAS->VAS_COEFIC
			M->VV0_VALTAC := VAS->VAS_VLRTAC
			M->VV0_TACLIQ := IIf(VAS->VAS_TACLIQ>0,VAS->VAS_TACLIQ,VAS->VAS_VLRTAC)
			M->VV0_TACFIN := VAR->VAR_TACFIN
			M->VV0_TACSUB := VAS->VAS_TACSUB
			M->VV0_SUBFIN := VAS->VAS_SUBFIN
			M->VV0_PTXRET := VAS->VAS_PERRET
			M->VV0_VTXRET := ( M->VV0_VALFIN * ( M->VV0_PTXRET / 100 ) ) // Retorno
			M->VV0_PCOMFN := VAS->VAS_PEPLUS
			M->VV0_VCOMFN := ( M->VV0_VALFIN * ( M->VV0_PCOMFN / 100 ) ) // Plus
			M->VV0_PREBFN := VAS->VAS_PERCTB
			M->VV0_VALREB := ( M->VV0_VALFIN * ( M->VV0_PREBFN / 100 ) ) // Rebate
			M->VV0_PCUSFN := VAS->VAS_CUSREC
			M->VV0_VCUSFN := ( ( M->VV0_VTXRET +  M->VV0_VCOMFN + M->VV0_TACLIQ )  * ( M->VV0_PCUSFN / 100 ) ) // Custo do Financiamento, utilizado para abater o titulo de retorno
			M->VV0_VTXRET := M->VV0_VTXRET * ((100-M->VV0_PCUSFN)/100) // Valor Liquido Retorno
			M->VV0_VCOMFN := M->VV0_VCOMFN * ((100-M->VV0_PCUSFN)/100) // Valor Liquido Plus
			M->VV0_TACLIQ := M->VV0_TACLIQ * ((100-M->VV0_PCUSFN)/100) // Valor Liquido TAC
		EndIf

	Case cTp == "2" // Finame
		M->VV0_CLFINA := aPar1[02] // aParFna - Codigo do Cliente ( Banco )
		M->VV0_LJFINA := aPar1[03] // aParFna - Loja do Cliente ( Banco )
		M->VV0_CFINAM := aPar1[04] // aParFna - Codigo do Finame
		M->VV0_NFINAM := aPar1[05] // aParFna - Nro PAC Finame
		M->VV0_CFFINA := aPar1[06] // aParFna - SE1 para 1=Cliente / 2=Financeira/Banco
		M->VV0_VFFINA := aPar1[07] // aParFna - SE2 Valor Flat para Financeira/Banco
		M->VV0_DFFINA := aPar1[08] // aParFna - SE2 Data Flat para Financeira/Banco
		M->VV0_VRFINA := aPar1[09] // aParFna - SE2 Valor Risco para Financeira/Banco
		M->VV0_DRFINA := aPar1[10] // aParFna - SE2 Data Risco para Financeira/Banco

	Case cTp == "3" // Financiamento Proprio
		M->VV0_VALFPR := aPar1[02] // aParPro - Valor do Financiamento Proprio
		M->VV0_DTIFPR := aPar1[03] // aParPro - Data Inicial
		M->VV0_D1PFPR := aPar1[04] // aParPro - Dias para 1a.Parcela
		M->VV0_PARFPR := aPar1[05] // aParPro - Qtde de Parcelas
		M->VV0_INTFPR := aPar1[06] // aParPro - Intervalo entre as parcelas
		M->VV0_FIXFPR := aPar1[07] // aParPro - Fixa Dia
		M->VV0_DIAFPR := aPar1[08] // aParPro - Dia Fixo
		M->VV0_JURFPR := aPar1[09] // aParPro - Juros Mensal
		If ( VV0->(ColumnPos("VV0_MESFPR")) > 0 )
			M->VV0_MESFPR := aPar1[10]	// aParPro - Meses a considerar
		EndIf

EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002RPLOAD  ºAutor  ³ Rubens         º Data ³  21/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega conteudo dos campos virtuais da VV0 com o conteudo º±±
±±º          ³ da VVA                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002RPLOAD(oObjEnch, lAtuaEnc)

Default oObjEnch := oEnchVV0
Default lAtuaEnc := .t.

M->VV0_CHASSI := M->VVA_CHASSI
M->VV0_CHAINT := M->VVA_CHAINT
M->VV0_CODTES := M->VVA_CODTES
M->VV0_FCICOD := M->VVA_FCICOD
M->VV0_PEDXML := M->VVA_PEDXML
M->VV0_ITEXML := M->VVA_ITEXML

////////////////////////////////////////////////////////////
// Campos Customizados ( M->VV0_?????? := M->VVA_?????? ) //
////////////////////////////////////////////////////////////
If ExistBlock("VX002RPL")
	ExecBlock("VX002RPL",.f.,.f.)
EndIf

If VVA->(ColumnPos("VVA_CODMAR")) > 0 .and. !Empty(M->VVA_CODMAR)
	VX002VEIC(M->VVA_CHAINT,;
			M->VVA_CODMAR,;
			Left(M->VVA_GRUMOD,TamSX3("VVR_GRUMOD")[1]),;
			M->VVA_MODVEI,;
			M->VVA_CORVEI,;
			oObjEnch,;
			lAtuaEnc,;
			IIf( lVVASEGMOD , M->VVA_SEGMOD , "" ))
Else
	VX002VEIC(M->VVA_CHAINT,;
			M->VV0_CODMAR,;
			Left(M->VV0_GRUMOD,TamSX3("VVR_GRUMOD")[1]),;
			M->VV0_MODVEI,;
			M->VV0_CORVEI,;
			oObjEnch,;
			lAtuaEnc,;
			IIf( lVVASEGMOD , M->VV0_SEGMOD , "" ))
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002MFORTE  ºAutor  ³ Rubens         º Data ³  21/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula Valores em Moeda Forte                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002MFORTE(cChaInt)

Local nQtdVei := 1
Local cQuery  := ""

// Posiciona no Veiculo para Procurar a Transacao de Entrada
VV1->(dbSetOrder(1))
VV1->(MsSeek(xFilial("VV1") + cChaInt ))

VVF->(dbSetOrder(1))
If !VVF->(dbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA ))
	nQtdVei := 1
Else
	cQuery := "SELECT COUNT(*) "
	cQuery +=   "FROM " + RetSQLName("SD1") + " SD1 "
	cQuery +=  "WHERE SD1.D1_FILIAL  = '" + VV1->VV1_FILENT + "' "
	cQuery +=    "AND SD1.D1_DOC     = '" + VVF->VVF_NUMNFI + "'"
	cQuery +=    "AND SD1.D1_SERIE   = '" + VVF->VVF_SERNFI + "'"
	cQuery +=    "AND SD1.D1_FORNECE = '" + VVF->VVF_CODFOR + "'"
	cQuery +=    "AND SD1.D1_LOJA    = '" + VVF->VVF_LOJA   + "'"
	cQuery +=    "AND SD1.D_E_L_E_T_ = ' '"
	nQtdVei := FM_SQL(cQuery)
	If nQtdVei == 0
		nQtdVei := 1
	EndIf
EndIf
VVG->(dbSetOrder(1))
VVG->(dbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA + VV1->VV1_CHAINT ))
//
M->VVA_VMFMOV := FG_CalcMF(  {{M->VV0_DATMOV,M->VV0_VALMOV}} )
M->VVA_CMFVDE := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMVDE}} )
M->VVA_CMFGER := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COMGER}} )
M->VVA_VMFVEI := IIf(!Empty(VVG->VVG_CODIND),FG_CalcMF({ { M->VV0_DATMOV,M->VVA_VCAVEI} }),FG_CalcMF(FG_RetVdCp(VVF->VVF_NUMNFI,VVF->VVF_SERNFI,"E"))/nQtdVei)
M->VVA_SMFVIA := FG_CalcMF({ {FG_RtDtCV("SGV",VV1->VV1_CODMAR,M->VV0_DATMOV),M->VVA_SEGVIA} })
M->VVA_VMFASS := FG_CalcMF({ {FG_RtDtCV("ASS",VV1->VV1_CODMAR,M->VV0_DATMOV),M->VVA_VALASS} })
M->VVA_RMFTEC := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_RECTEC}} )
M->VVA_BMFFAB := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_BONFAB}} )
If VVA->(ColumnPos("VVA_BMFREG"))>0 .and. VVA->(ColumnPos("VVA_BONREG"))>0
	M->VVA_BMFREG := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_BONREG}} )
EndIf
If VVA->(ColumnPos("VVA_BMFCON"))>0 .and. VVA->(ColumnPos("VVA_BONCON"))>0
	M->VVA_BMFCON := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_BONCON}} )
EndIf
M->VVA_RMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_RECVEI}} )
M->VVA_IMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ICMVEN}} )
M->VVA_PMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_PISVEN}} )
M->VVA_CMFVEN := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_COFVEN}} )
M->VVA_IMFRTE := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ISSRTE}} )
M->VVA_PMFRTE := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_PISRTE}} )
M->VVA_PMFBFB := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_PISBFB}} )
M->VVA_IMFBFB := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ISSBFB}} )
M->VVA_VMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_VCAVEI}} )
M->VVA_RMFCUS := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_REDCUS}} )
M->VVA_AMFSSO := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_ACESSO}} )
M->VVA_DMFVEI := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_DESVEI}} )
M->VVA_DMFCLI := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_DESCLI}} )
M->VVA_VMFREV := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_VALREV}} )
M->VVA_JMFEST := FG_CalcMF(  {{M->VV0_DATMOV,M->VVA_JUREST}} )
//
M->VVA_FMFTOT := M->VVA_VMFMOV+M->VVA_CMFCOT+M->VVA_CMFCTP+M->VVA_RMFTEC+M->VVA_BMFFAB
M->VVA_TMFCUS := FG_FORMULA(GetNewPar("MV_TMFCUFN","M->VVA_VMFVEI-M->VVA_RMFCUS+M->VVA_JMFEST+M->VVA_AMFSSO+M->VVA_VMFSCO+M->VVA_PMFENT+M->VVA_CMFENT"))
M->VVA_TMFIMP := M->VVA_IMFVEN+M->VVA_IMFCVD+M->VVA_PMFVEN+M->VVA_CMFVEN+M->VVA_IMFRTE+M->VVA_PMFRTE+M->VVA_IMFBFB+M->VVA_PMFBFB
M->VVA_LMFBRU := M->VVA_FMFTOT-M->VVA_TMFIMP-M->VVA_VMFVEI
M->VVA_LMFLQ1 := M->VVA_LMFBRU-M->VVA_JMFEST-M->VVA_AMFSSO-M->VVA_VMFSCO-M->VVA_DMFCLI-M->VVA_SMFVIA-M->VVA_VMFASS-M->VVA_VMFREV-M->VVA_DMFVEI-M->VVA_AMFIMP-M->VVA_CMFVDE-M->VVA_CMFGER-M->VVA_CMFPAT //LUCRO MARGINAL
M->VVA_LMFLQ2 := M->VVA_LMFLQ1-M->VVA_DMFFIX+(M->VVA_RMFCUS+M->VVA_RMFVEI-M->VVA_DMFFIN) //LAIR

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002LIBDIGºAutor³ Rubens              º Data ³  04/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Libera Digitacao do Atendimento (WHEN)                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002LIBDIG(nOpc,lMsg)
Local nCntFor := 0
Default lMsg  := .f.
If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacao dos Campos obrigatorios da VV9 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("VV9")
	For nCntFor:=1 to Len(aCpoVV9)
		If X3Obrigat(aCpoVV9[nCntFor]) .and. Empty(&("M->"+aCpoVV9[nCntFor]))
			If lMsg
				Help(" ",1,"OBRIGAT2",,AllTrim(RetTitle(aCpoVV9[nCntFor])) + " (" + aCpoVV9[nCntFor] + ")" ,4,1)
			EndIf
			Return .f.
		EndIf
	Next
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002BOTOPCºAutor³ Andre Luis Almeida  º Data ³  11/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Clique no Menu de Opcoes da Tela                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002BOTOPC(nBot,nOpc)

Local aRetRelac
Local aVJ1         := {"",""}
Local nSlvOpc      := nOpc
Local lRetVEIXC006 := .F.
Local aAux         := {}
Local aIteTra      := {}
Local aPOSIteTra   := {} // Posicao do IteTra - utilizado para achar a Marca/Modelo/Cor da Oportunidade
Local lVeiBloq     := .f.
Local oVeiculos    := DMS_Veiculo():New()

If cVV9Status $ "POLFC"
	nOpc := 2
EndIf

Do Case

	Case nBot == 1 // Cliente
		If !Empty(M->VV9_CODCLI+M->VV9_LOJA)
			// Salva o Fiscal
			MaFisSave()
			//
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+M->VV9_CODCLI+M->VV9_LOJA))
			FC010CON() // Tela de Consulta -> Posicao do Cliente
			// Restaura o Fiscal
			MaFisRestore()
			//
		Else
			DbSelectArea("SA1")
			If axInclui("SA1") == 1 // OK no Cadastro do Cliente SA1
				M->VV9_CODCLI := SA1->A1_COD
				M->VV9_LOJA   := SA1->A1_LOJA
				M->VV9_NOMVIS := SA1->A1_NOME
				M->VV9_TELVIS := SA1->A1_TEL
				If !VX002VISIT(nOpc)
					Return .f.
				EndIf
			EndIf
		EndIf

	Case nBot == 2 // Veiculos do Cliente
		If !Empty(M->VV9_CODCLI+M->VV9_LOJA)
			VEIVC090(M->VV9_CODCLI,M->VV9_LOJA,.t.)
		Else
			MsgStop(STR0065+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0052,STR0011) // Veiculos do Cliente / Necessario informar um Cod.Cliente/Loja! / Atencao
		EndIf

	Case nBot == 3 // Registro de Abordagem/Reclamacao
		ML500A()

	Case nBot == 4 // Rastreamento do Veiculo
		If !FM_PILHA("VEIVC140")
			If !Empty(M->VVA_CHASSI)
				// Salva o Fiscal
				MaFisSave()
				//
				VEIVC140(M->VVA_CHASSI , M->VVA_CHAINT)
				// Restaura o Fiscal
				MaFisRestore()
			Else
				MsgStop(STR0067+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Rastreamento do Veiculo / Favor selecionar um Veiculo! / Atencao
			EndIf
		EndIf

	Case nBot == 5 // Visualiza Cadastro do Veiculo
		If !Empty(M->VVA_CHAINT)
			VX002VV1(M->VVA_CHAINT)
		Else
			MsgStop(STR0069+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Visualiza Cadastro do Veiculo / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 6 // Opcionais do Veiculo
		// Verifica se ja tem um Chaint ou Modelo do veiculo ...
		If !Empty(aParOpc[01]) .or. !Empty(aParOpc[03])
			VEIXC005(@aParOpc)
		Else
			MsgStop(STR0070+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Opcionais do Veiculo / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 7 // Bonus de Veiculos
		If cVV9Status $ "PO"
			nOpc := nSlvOpc
		EndIf
		If !Empty(M->VV9_NUMATE)
			// CONTROLAR POR SEGMENTO ???
			VEIXX014( M->VV9_NUMATE , M->VVA_CODMAR , M->VVA_GRUMOD , M->VVA_MODVEI , nOpc , .T. , M->VV0_TIPFAT , oGetDadVVA:aCols[oGetDadVVA:nAt,nVVARECNO] )
		Else
			MsgStop(STR0071+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Bonus de Veiculo / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 8 // Despesas/Receitas com o Veiculo
		If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
			If !Empty(M->VVA_CHAINT)
				lVeiBloq := oVeiculos:Bloqueado(M->VVA_CHAINT)
				If lVeiBloq
					VEIVM040(2, M->VVA_CHAINT, M->VVA_NUMTRA, M->VVA_FILENT, M->VVA_TRACPA) // Apenas Visualização
				Else
					VEIVM040(nOpc, M->VVA_CHAINT, M->VVA_NUMTRA, M->VVA_FILENT, M->VVA_TRACPA)
					M->VVA_DESVEI := FGX_DRECVEI(M->VVA_CHAINT, "0",,.t.) // Levanta Despesas do Veiculo VVD
					M->VVA_RECVEI := FGX_DRECVEI(M->VVA_CHAINT, "1",,.t.) // Levanta Receitas do Veiculo VVD
					VX002ACOLS("VVA_DESVEI", oGetDadVVA:nAt)
					VX002ACOLS("VVA_RECVEI", oGetDadVVA:nAt)
				EndIf
			Else
				MsgStop(STR0072+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Despesas/Receitas com o Veiculo / Favor selecionar um Veiculo! / Atencao
			EndIf
		Else
			If !Empty(M->VVA_CHAINT)
				nOpc := 2
				VEIVM040(nOpc,M->VVA_CHAINT,M->VVA_NUMTRA,M->VVA_FILENT,M->VVA_TRACPA)
				nOpc := nSlvOpc
			Else
				MsgStop(STR0072+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Despesas/Receitas com o Veiculo / Favor selecionar um Veiculo! / Atencao
			EndIf
		EndIf

	Case nBot == 9 // Reserva/Cancela Reserva do Veiculo
		If !Empty(M->VV9_NUMATE) .and. !Empty(M->VVA_CHAINT)
			VEIXX004(nOpc,M->VV9_NUMATE,M->VVA_CHAINT,"5",M->VVA_ITETRA)
		Else
			MsgStop(STR0073+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Reserva/Cancela Reserva do Veiculo / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 10 // Prioridade de Venda - Reserva Temporaria
		If !Empty(M->VV9_NUMATE) .and. !Empty(M->VVA_CHAINT)
			VEIXX016(nOpc,"1",M->VV9_NUMATE,M->VVA_CHAINT) // Reserva / Desreserva (Prioridade de Venda)
		Else
			MsgStop(STR0074+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Prioridade de Venda - Reserva Temporaria / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 11 // Previsao de Entrega do Veiculo
		If !Empty(M->VVA_CHAINT) // CHASSI OU PELA MARCA / MODELO ////////////////////////////////////////////////////////////////////////////////
			nOpc := nSlvOpc
			VEIXX006(nOpc,@aEntrVei,.t.)
		Else
			MsgStop(STR0076+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Previsao de Entrega do Veiculo / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 12 // Valor do Minimo Comercial de Venda
		If !VEIXX007(1,@aMinCom,M->VV9_CODCLI,M->VV9_LOJA)
			MsgStop(STR0077+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Valor do Minimo Comercial de Venda / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 13 // Solicitar Tarefa para o Atendimento
		nOpc := nSlvOpc
		If nOpc == 3 .or. nOpc == 4 // Incluir / Alterar
			If !Empty(M->VV9_NUMATE)
				VEIVM130TAR(M->VV9_NUMATE,"3","1",M->VV9_FILIAL) // Tarefas: 3-Pelo usuario / 1-Atendimento
			Else
				MsgStop(STR0078+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Solicitar Tarefas para o Atendimento / Favor selecionar um Veiculo! / Atencao
			EndIf
		Else
			MsgStop(STR0078+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0075,STR0011) // Solicitar Tarefas para o Atendimento / Opcao disponivel apenas na Inclusao ou Alteracao do Atendimento! / Atencao
		EndIf

	Case nBot == 14 // Visualizar Tarefas do Atendimento
		If !Empty(M->VV9_NUMATE)
			If !FM_PILHA("VEIVM130")
				VEIVM130(M->VV9_NUMATE,M->VV9_FILIAL)
			EndIf
		Else
			MsgStop(STR0079+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Visualizar Tarefas do Atendimento / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 16 // Relaciona Chassi a Venda FUTURA
		nOpc := nSlvOpc
		If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
			// Atendimento de Veiculo Novo
			If M->VV0_TIPFAT <> "0"
				MsgStop(STR0080,STR0011) // Atendimento nao e' de um veiculo novo! / Atencao
				Return .t.
			EndIf
			If !Empty(M->VVA_CODMAR)
				lRetVEIXC006 := VEIXC006( @aRetRelac , M->VVA_CODMAR , M->VVA_GRUMOD , M->VVA_MODVEI , M->VVA_CORVEI , M->VV9_NUMATE , M->VVA_ITETRA , cVV9Status , IIf( lVVASEGMOD , M->VVA_SEGMOD , "" ) )
			Else
				lRetVEIXC006 := VEIXC006( @aRetRelac , M->VV0_CODMAR , M->VV0_GRUMOD , M->VV0_MODVEI , M->VV0_CORVEI , M->VV9_NUMATE , ""            , cVV9Status , IIf( lVVASEGMOD , M->VVA_SEGMOD , "" ) )
			EndIf

			If lRetVEIXC006

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Relaciona Chassi de Acordo com o Modelo ³
				//³                                         ³
				//³ aRetRelac[01] = ChaInt                  ³
				//³ aRetRelac[02] = Marca                   ³
				//³ aRetRelac[03] = Grupo do Modelo         ³
				//³ aRetRelac[04] = Modelo                  ³
				//³ aRetRelac[05] = Cor                     ³
				//³ aRetRelac[06] = Progresso               ³
				//³ aRetRelac[07] = Valor do Veiculo        ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->VVA_CHAINT := aRetRelac[01] // Chaint
				M->VVA_CODMAR := aRetRelac[02] // Marca
				M->VVA_GRUMOD := aRetRelac[03] // Grupo do Modelo
				M->VVA_MODVEI := aRetRelac[04] // Modelo
				M->VVA_CORVEI := aRetRelac[05] // Cor
				M->VVA_VALTAB := aRetRelac[07] // Valor do Veiculo
				If lVVASEGMOD
					M->VVA_SEGMOD := aRetRelac[08] // Segmento
				EndIf

				VX002ACOLS("VVA_VALTAB",oGetDadVVA:nAt)
				VX002ACOLS("VVA_VALVDA",oGetDadVVA:nAt)

				If !Empty(aRetRelac[01]) // Atendimento pelo CHAINT

					FGX_VV1SB1("CHAINT", aRetRelac[01] , /* cMVMIL0010 */ , cGruVei )
					N := oGetDadVVA:nAt
					MaFisRef("IT_PRODUTO","VX001",SB1->B1_COD)
					MaFisRef("IT_QUANT","VX001",1)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Informacoes de campo VIRTUAL de veiculo ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					VX002VEIC(aRetRelac[01],aRetRelac[02],aRetRelac[03],aRetRelac[04],aRetRelac[05],,,aRetRelac[08])

					VV1->(dbSetOrder(1))
					If VV1->(MsSeek(xFilial("VV1")+aRetRelac[01]))
						M->VVA_FILENT := VV1->VV1_FILENT
						M->VVA_TRACPA := VV1->VV1_TRACPA
					EndIf

				else // Atendimento pelo Modelo do Veiculo

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Informacoes de campo VIRTUAL de veiculo ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					VX002VEIC(,aRetRelac[02],aRetRelac[03],aRetRelac[04],aRetRelac[05],,,aRetRelac[08])

				endif

				oGetDadVVA:aCols[oGetDadVVA:nAt,Len(oGetDadVVA:aCols[oGetDadVVA:nAt])] := .t. // Deletar para Voltar linha
				VX002DELAC(nOpc,.f.,.f.) // Disparar Fiscal - voltando linha

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Levanta Sugestao da Dt.Entrega do Veiculo/Modelo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				VEIXX006(nOpc,@aEntrVei,.f.)

				Begin Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Selecionado um Progresso de Veiculo ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(aRetRelac[06])
					aVJ1[01] := aRetRelac[02] // Marca do Veiculo
					aVJ1[02] := aRetRelac[06] // Codigo do Progresso do Veiculo
					VX002GRV(nOpc,.f.,"VJ1",,,,@aVJ1)
				Else
					VX002GRV(nOpc,.f.)
				EndIf

				End Transaction

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Roda o Mapa Novamente, pois o Custo do Veiculo pode Ter Alterado ... ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				VX002MAPAV()
				//

				// Fechar F10 automaticamente //
				oDlgOpcoes:End()

			EndIf

		EndIf

	Case nBot == 17 // Custo FIXO com Vendas
		If !Empty(M->VV9_NUMATE) .and. !Empty(M->VVA_CHAINT)
			VEIXX017( M->VV9_NUMATE , nOpc , .t. , 0 , M->VVA_CHAINT , M->VVA_ITETRA )
		Else
			MsgStop(STR0082+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Custo com Vendas / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 18 // Mapa de Avaliacao - Aprovacao
		If !Empty(M->VV9_NUMATE)
			VEIXX013(M->VV9_NUMATE,0)
		Else
			MsgStop(STR0083+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Mapa de Avaliacao - Aprovacao / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 19 // Banco de Conhecimento do Veiculo
		If !Empty(M->VVA_CHAINT)
			dbSelectArea("VV1")
			dbSetOrder(1)
			dbSeek(xFilial("VV1")+M->VVA_CHAINT)
			nReg := VV1->(RecNo())
			FGX_MSDOC("VV1",nReg,4)
		Else
			MsgStop(STR0061+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Banco de Conhecimento do Veiculo / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 20 // Banco de Conhecimento do Atendimento
		If !Empty(M->VV9_NUMATE)
			nReg := VV0->(RecNo())
			FGX_MSDOC("VV0",nReg,4)
		Else
			MsgStop(STR0062+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Banco de Conhecimento do Atendimento / Favor selecionar um Veiculo! / Atencao
		EndIf

	Case nBot == 21 // Configuração
		If !Empty(M->VVA_CHAINT)
			VA380CFGVEI(M->VVA_CHAINT)
		Else
			MsgStop(STR0063+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Configuração // Favor selecionar veiculo!/ atencao
		EndIf

	Case nBot == 22 // Relaciona Interesse
		If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
			aAdd(aAux,{"","","","",0,.f.,""})
			VV2->(dbSetOrder(1))
			VVC->(dbSetOrder(1))
			If !Empty(M->VVA_CODMAR)
				FGX_VV2(M->VVA_CODMAR, M->VVA_MODVEI, IIf( lVVASEGMOD , M->VVA_SEGMOD , "" ) )
				VVC->(MsSeek(xFilial("VVC")+M->VVA_CODMAR+M->VVA_CORVEI))
				aAdd(aIteTra,M->VVA_ITETRA+"="+Alltrim(M->VVA_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)+" - "+Alltrim(VVC->VVC_DESCRI)+" - "+Alltrim(M->VVA_CHASSI))
				aAdd(aPOSIteTra,M->VVA_CODMAR+M->VVA_MODVEI+M->VVA_CORVEI)
			Else
				FGX_VV2(M->VV0_CODMAR, M->VV0_MODVEI, IIF( lVVASEGMOD , M->VV0_SEGMOD , "" ) )
				VVC->(MsSeek(xFilial("VVC")+M->VV0_CODMAR+M->VV0_CORVEI))
				aAdd(aIteTra,M->VVA_ITETRA+"="+Alltrim(M->VV0_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)+" - "+Alltrim(VVC->VVC_DESCRI)+" - "+Alltrim(M->VV0_CHASSI))
				aAdd(aPOSIteTra,M->VV0_CODMAR+M->VV0_MODVEI+M->VV0_CORVEI)
			EndIf
			VX002GRVOPO(aAux,aIteTra,aPOSIteTra,oGetDadVVA:nAt)
		EndIf

EndCase
nOpc := nSlvOpc
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002CATVENºAutor³ Andre Luis Almeida  º Data ³  10/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna a Categoria e o Tipo da Venda do Atendimento       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ aRet[1] = Categoria da Venda                               º±±
±±º          ³ aRet[2] = Tipo da Venda                                    º±±
±±º          ³ aRet[3] = Cliente Alienacao                                º±±
±±º          ³ aRet[4] = Loja do Cliente Alienacao                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002CATVEN(cNumAte)
Local aRet    := {"0","","",""}
Local aCliAli := {}
Local cAdmCon := ""
Local ni      := 0
Local cSequen := "347560" // Sequencia de quem manda (3=Financiamento/4=Finame/7=Leasing/5=ConsorcioNaoQuitado/6=ConsorcioQuitado/0=Outros)
Local cCatVen := "0" // Financiamento Proprio / Veiculo Usado / Entradas
Local cTipVen := GetNewPar("MV_VTIPVEN","") // Relacionamento entre a Categoria de Venda com o Tipo de Venda
Local cQuery  := ""
Local cSQLVS9 := "SQLVS9"
Local aArea := GetArea()
Local lCatVenManual := .f.

VV0->(DbSetOrder(1))
VV0->(DbSeek(xFilial("VV0")+cNumAte))

aAdd(aCliAli,{"0","",""})

If VV0->(ColumnPos("VV0_CATVMA")) > 0 .and. M->VV0_CATVMA == "1"
	aRet[1] := M->VV0_CATVEN
	aRet[3] := M->VV0_CLIALI
	aRet[4] := M->VV0_LOJALI
	lCatVenManual := .t.
EndIf

If lCatVenManual == .f.
	cQuery := "SELECT VS9.VS9_REFPAG , VS9.VS9_TIPPAG , VS9.VS9_SEQUEN , VSA.VSA_TIPO , VSA.VSA_CODCLI , VSA.VSA_LOJA "
	cQuery +=  " FROM "+RetSQLName("VS9")+" VS9 "
	cQuery +=         " INNER JOIN "+RetSQLName("VSA")+" VSA ON VSA.VSA_FILIAL = '" + xFilial("VSA") + "' "
	cQuery +=                                             " AND VSA.VSA_TIPPAG = VS9.VS9_TIPPAG "
	cQuery +=                                             " AND VSA.VSA_TIPO IN ('1','3','6') "
	cQuery +=                                             " AND VSA.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE VS9.VS9_FILIAL = '" + xFilial("VS9") + "'"
	cQuery +=   " AND VS9.VS9_NUMIDE = '" + cNumAte + "'"
	cQuery +=   " AND VS9.VS9_TIPOPE = 'V'"
	cQuery +=   " AND VS9.D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVS9 , .F. , .T. )
	While !(cSQLVS9)->(Eof())
		Do Case
			Case (cSQLVS9)->( VSA_TIPO ) == "1" // Financiamento / Leasing
				If left((cSQLVS9)->( VS9_REFPAG ),1) == "1" // Financiamento
					cCatVen	+= "3" // Financiamento
					aAdd(aCliAli,{"3",(cSQLVS9)->( VSA_CODCLI ),(cSQLVS9)->( VSA_LOJA )})
				Else //If left((cSQLVS9)->( VS9_REFPAG ),1) == "2" // Leasing
					cCatVen	+= "7" // Leasing
					aAdd(aCliAli,{"7",(cSQLVS9)->( VSA_CODCLI ),(cSQLVS9)->( VSA_LOJA )})
				EndIf

			Case (cSQLVS9)->( VSA_TIPO ) == "3" // Consorcio
				If left((cSQLVS9)->( VS9_REFPAG ),1) == "0" // Nao Quitado
					cCatVen	+= "5" // Nao Quitado
					cAdmCon := FM_SQL("SELECT VSE.VSE_VALDIG FROM "+RetSqlName("VSE")+" VSE WHERE VSE.VSE_FILIAL='"+xFilial("VSE")+"' AND VSE.VSE_NUMIDE='"+cNumAte+"' AND VSE.VSE_TIPOPE='V' AND VSE.VSE_TIPPAG='"+(cSQLVS9)->( VS9_TIPPAG )+"' AND VSE.VSE_SEQUEN='"+(cSQLVS9)->( VS9_SEQUEN )+"' AND VSE.D_E_L_E_T_=' ' ORDER BY VSE.VSE_DESCCP")

					VV4->(DbSetOrder(1))
					VV4->(DbSeek(xFilial("VV4")+cAdmCon))
					aAdd(aCliAli,{"5",VV4->VV4_CODCLI,VV4->VV4_LOJCLI})
				Else//If left((cSQLVS9)->( VS9_REFPAG ),1) == "1" // Quitado
					cCatVen	+= "6" // Quitado
					aAdd(aCliAli,{"6","",""})
				EndIf

			Case (cSQLVS9)->( VSA_TIPO ) == "6" // Finame
				cCatVen	+= "4" // Finame
				aAdd(aCliAli,{"4",VV0->VV0_CLFINA,VV0->VV0_LJFINA})
		EndCase
		(cSQLVS9)->(dbSkip())
	EndDo
	(cSQLVS9)->(dbCloseArea())
	For ni := 1 to len(cSequen) // Veifica quem manda pela sequencia (3=Financiamento/4=Finame/7=Leasing/5=ConsorcioNaoQuitado/6=ConsorcioQuitado/0=Outros)
		If At(substr(cSequen,ni,1),cCatVen) > 0
			aRet[1] := substr(cSequen,ni,1) // Categoria da Venda
			Exit
		EndIf
	Next

	ni := ascan(aCliAli,{|x| x[1] == aRet[1] }) // Trazer o Cliente Alienacao
	If ni > 0
		aRet[3] := aCliAli[ni,2] // Cliente Alienacao
		aRet[4] := aCliAli[ni,3] // Loja do Cliente Alienacao
	EndIf
EndIf

If lXX002Auto .and. ! Empty(M->VVA_VRKNUM) .and. ! Empty(M->VV0_TIPVEN)
	aRet[2] := M->VV0_TIPVEN
Else
	If !Empty(cTipVen)
		ni := At(aRet[1]+"=",cTipVen) // Pesquisa pela Categora da Venda
		If ni > 0
			aRet[2] := substr(cTipVen,ni+2,2) // Tipo da Venda
		EndIf
	EndIf
EndIf

If ExistBlock("VX002CAT")
	aRet := ExecBlock("VX002CAT",.f.,.f.,{aRet})
Endif

RestArea( aArea )
Return aClone(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002DTTIT ºAutor³ Andre Luis Almeida  º Data ³  10/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida DATAS dos TITULOS (VS9)                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ lRet  ( .t. = OK  / .f. = Problema )                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002DTTIT(cNumAte)
Local lRet     := .t.
Local cQuery   := ""
Local cSQLVS9  := "SQLVS9"
Local cNumTit  := ""
Local aArea    := GetArea()
Local cPreTit  := &(GetNewPar("MV_PTITVEI","''")) // Prefixo dos Titulos de Veiculos
VV9->(DbSetOrder(1))
VV9->(DbSeek(xFilial("VV9")+cNumAte))
VV0->(DbSetOrder(1))
VV0->(DbSeek(xFilial("VV0")+cNumAte))
cNumTit := "V"+Right(VV9->VV9_NUMATE,TamSx3("E1_NUM")[1]-1)
If cTitAten == "0" // Geracao dos Titulos no momento da geracao da NF
	If !Empty(VV0->VV0_NUMNFI) // Titulos gerados com o Nro da Nota Fiscal
		SF2->(DbSetOrder(1)) // F2_FILIAL + F2_DOC + F2_SERIE
		If SF2->(DbSeek(xFilial("SF2")+VV0->VV0_NUMNFI+VV0->VV0_SERNFI))
			cPreTit := SF2->F2_PREFIXO
		EndIf
	EndIf
EndIf
If left(Alltrim(GetNewPar("MV_VTITVEI","S")),1) $ "S/1" // ( 1 ou S -> Sim / 0 ou N -> Nao )
	//////////////////////////////////////////////
	// Verificar se ainda nao existe SE1 criado //
	//////////////////////////////////////////////
	cQuery := "SELECT COUNT(*) AS QTDSE1 FROM "+RetSQLName("SE1")+" SE1 WHERE SE1.E1_FILIAL='"+xFilial("SE1")+"' AND "
	cQuery += "SE1.E1_PREFIXO='"+cPreTit+"' AND "
	cQuery += "( SE1.E1_NUM='"+cNumTit+"' "
	If !Empty(VV0->VV0_NUMNFI) // Titulos gerados com o Nro da Nota Fiscal
		cQuery += "OR SE1.E1_NUM='"+VV0->VV0_NUMNFI+"'"
	EndIf
	cQuery += " ) AND SE1.E1_PREFORI='"+cPrefVEI+"'"
	cQuery += " AND SE1.E1_FILORIG='"+xFilial("VV9")+"'" // Filial referente ao Titulo
	cQuery += " AND SE1.D_E_L_E_T_=' '"
	If FM_SQL(cQuery) <= 0
		//////////////////////////////////////////////
		// Validar as datas dos Titulos no VS9      //
		//////////////////////////////////////////////
		cQuery := "SELECT VS9.VS9_DATPAG , VSA.VSA_TIPO FROM "+RetSQLName("VS9")+" VS9 "
		cQuery += "INNER JOIN "+RetSQLName("VSA")+" VSA ON ( VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG=VS9.VS9_TIPPAG AND VSA.VSA_TIPO NOT IN ('3','4') AND VSA.D_E_L_E_T_ = ' ' ) "
		cQuery += "WHERE VS9.VS9_FILIAL='"+xFilial("VS9")+"' AND VS9.VS9_NUMIDE='"+cNumAte+"' AND VS9.VS9_TIPOPE = 'V' AND VS9.D_E_L_E_T_ = ' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLVS9 , .F. , .T. )
		While !(cSQLVS9)->(Eof())
			If stod((cSQLVS9)->( VS9_DATPAG )) < dDataBase
				VX002ExibeHelp("VX002ERR014" , STR0084) // Datas de Vencimento dos Titulos menor que a Data atual. Favor altera-las! / Atencao
				lRet := .f.
			EndIf
			(cSQLVS9)->(dbSkip())
		EndDo
		(cSQLVS9)->(dbCloseArea())
	EndIf
EndIf
RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002CEV  ºAutor³ Andre Luis Almeida  º Data ³  10/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ CEV - Perseguidor / Pos-Venda / Cancelamento               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cStatus ( STATUS do Atendimento )                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002CEV(cStatus,cNumAte)
Local lVCM510CEV := FindFunction("VCM510CEV")
Local ni      := 0
Local aCEV    := {}
Local cCEV    := ""
Local cObs    := ""
Local cSQL    := ""
Local nRecVC1 := 0
Local lVVACODMAR := ( VVA->(ColumnPos("VVA_CODMAR")) > 0 )
Local lVVASEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )
VV9->(DbSetOrder(1))
VV9->(DbSeek(xFilial("VV9")+cNumAte))
VV0->(DbSetOrder(1))
VV0->(DbSeek(xFilial("VV0")+cNumAte))
Do Case
	Case cStatus == "A" // Abertura do Atendimento (Perseguicao)
		If lVCM510CEV
			aCEV := VCM510CEV("3",VV0->VV0_TIPFAT,"") // 3 = Perseguidor Veiculo
		Else // Temporario
			cCEV := Alltrim(GetNewPar("MV_GCPVCEV",""))
			If !Empty(cCEV)
				aCEV := {{substr(cCEV,1,1),Val(substr(cCEV,2,3)),substr(cCEV,5,6),Val(substr(cCEV,11,3))}}
			EndIf
		EndIf
		For ni := 1 to len(aCEV)
			If Empty(aCEV[ni,3])
				aCEV[ni,3] := VV0->VV0_CODVEN // Vendedor
			EndIf
			cCEV := "X"
			////////////////////////////////////////////////////////////////////////////////
			// CEV - Verificar se o Tipo de Agenda e' de Veiculos                         //
			////////////////////////////////////////////////////////////////////////////////
			cSQL := "SELECT R_E_C_N_O_ FROM "+RetSQLName("VC5")+" WHERE VC5_FILIAL='"+xFilial("VC5")+"' AND VC5_TIPAGE='"+aCEV[ni,1]+"' AND "
			If VV0->VV0_TIPFAT <> "1" // Veiculo Novo
				cSQL += "VC5_AGEOFI='4' AND "
			Else // Veiculo Usado
				cSQL += "VC5_AGEOFI='5' AND "
			EndIf
			cSQL += "D_E_L_E_T_=' '"
			If FM_SQL(cSQL) <= 0
				cCEV := "" // Nao Gerar Agenda quando o TIPO DE ORIGEM nao for VEICULOS
			Else
				////////////////////////////////////////////////////////////////////////////////
				// CEV - Verificar se ja existe Agenda CEV Perseguidor para este Atendimento  //
				////////////////////////////////////////////////////////////////////////////////
				nRecVC1 := 1
				While nRecVC1 > 0
					cSQL := "SELECT VC1.R_E_C_N_O_ AS RECVC1 FROM "+RetSQLName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
					cSQL += "VC1.VC1_TIPAGE='"+aCEV[ni,1]+"' AND "
					cSQL += "VC1.VC1_CODCLI='"+VV9->VV9_CODCLI+"' AND VC1.VC1_LOJA='"+VV9->VV9_LOJA+"' AND "
					cSQL += "VC1.VC1_CODVEN='"+aCEV[ni,3]+"' AND "
					cSQL += "VC1.VC1_TIPORI='V' AND VC1.VC1_ORIGEM='"+Alltrim(cNumAte)+"' AND VC1.D_E_L_E_T_=' '"
					nRecVC1 := FM_SQL(cSQL)
					If nRecVC1 > 0
						VC1->(DbGoTo(nRecVC1))
						If !Empty(VC1->VC1_DATVIS) // Se existir Agenda/Visita ja abordada
							cCEV := "" // Nao Gerar Agenda na Finalizacao quando ja existe Agenda dentro da qtde minima de dias
						Else // Se existir Agenda/Visita e ainda nao foi abordada, deve excluir o VC1 em aberto para inserir uma nova perseguicao
							TCSqlExec("DELETE FROM "+RetSqlName("VC1")+" WHERE R_E_C_N_O_="+Alltrim(str(nRecVC1)))
						EndIf
					EndIf
				EndDo
			EndIf
			////////////////////////////////////////////////////////////////////////////////
			// CEV - Criar agenda de Perseguicao do Cliente                               //
			////////////////////////////////////////////////////////////////////////////////
			If !Empty(cCEV)
				cSQL := "SELECT SA3.A3_NOME FROM "+RetSQLName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+VV0->VV0_CODVEN+"' AND SA3.D_E_L_E_T_=' '"
				cObs := STR0001+": "+cNumAte+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)+STR0086+" - " // Atendimento / hs
				cObs += STR0085+": "+VV0->VV0_CODVEN+" "+left(FM_SQL(cSQL),20)+" - " // Vendedor
				cObs += STR0087+": "+X3CBOXDESC("VV9_SENNEG",VV9->VV9_SENNEG)+" - "+STR0088+": "+X3CBOXDESC("VV9_TIPMID",VV9->VV9_TIPMID)+CHR(13)+CHR(10) // Sentimento da Negociacao / Tipo de Midia
				cObs += STR0042+": " // Veiculo(s)
				VVA->(DbSetOrder(1))
				VVA->(DbSeek(xFilial("VVA")+cNumAte))
				While !VVA->(Eof()) .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == cNumAte
					If !Empty(VVA->VVA_CHAINT)
						VV1->(DbSetOrder(1))
						VV1->(MsSeek(xFilial("VV1")+VVA->VVA_CHAINT))
						FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, IIF( lVVASEGMOD , VV1->VV1_SEGMOD , "" ) )
						cObs += CHR(13)+CHR(10)+Alltrim(VV1->VV1_CHASSI)+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)
					Else
						VV2->(DbSetOrder(1))
						If lVVACODMAR .and. !Empty(VVA->VVA_CODMAR)
							FGX_VV2(VVA->VVA_CODMAR, VVA->VVA_MODVEI, IIF( lVVASEGMOD , VVA->VVA_SEGMOD , "" ) )
							cObs += CHR(13)+CHR(10)+Alltrim(VVA->VVA_CODMAR)+" "
						Else
							FGX_VV2(VV0->VV0_CODMAR, VV0->VV0_MODVEI, IIF( lVVASEGMOD , VV0->VV0_SEGMOD , "" ) )
							cObs += CHR(13)+CHR(10)+Alltrim(VV0->VV0_CODMAR)+" "
						EndIf
						cObs += Alltrim(VV2->VV2_DESMOD)
					EndIf
					VVA->(DbSkip())
				EndDo
				////////////////////////////////////////////////////////////////////////////////
				// CEV - Geracao de Agenda                                                    //
				////////////////////////////////////////////////////////////////////////////////
				FS_AGENDA( aCEV[ni,1] , ( dDataBase+aCEV[ni,2] ) , aCEV[ni,3] , VV9->VV9_CODCLI , VV9->VV9_LOJA , "" , cNumAte , "" , cObs , "" , "" )
			EndIf
		Next
	Case cStatus == "F" // Finalizacao do Atendimento (Pos-Venda)
		If lVCM510CEV
			aCEV := VCM510CEV("3",VV0->VV0_TIPFAT,"") // 3 = Perseguidor Veiculo
		Else // Temporario
			cCEV := Alltrim(GetNewPar("MV_GCPVCEV",""))
			If !Empty(cCEV)
				aCEV := {{substr(cCEV,1,1),Val(substr(cCEV,2,3)),substr(cCEV,5,6),Val(substr(cCEV,11,3))}}
			EndIf
		EndIf
		For ni := 1 to len(aCEV)
			If Empty(aCEV[ni,3])
				aCEV[ni,3] := VV0->VV0_CODVEN // Vendedor
			EndIf
			////////////////////////////////////////////////////////////////////////////////
			// CEV - Deletar agenda de Perseguicao em Aberto quando Finalizar Atendimento //
			////////////////////////////////////////////////////////////////////////////////
			DbSelectArea("VC1")
			DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
			DbSeek( xFilial("VC1") + aCEV[ni,1] + VV9->VV9_CODCLI + VV9->VV9_LOJA )
			Do While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. VC1->VC1_TIPAGE == aCEV[ni,1] .and. VC1->VC1_CODCLI + VC1->VC1_LOJA == VV9->VV9_CODCLI + VV9->VV9_LOJA
				If VC1->VC1_TIPORI == "V" .and. Alltrim(VC1->VC1_ORIGEM) == Alltrim(cNumAte) .and. Empty(VC1->VC1_DATVIS) .and. VC1->VC1_CODVEN == aCEV[ni,3]
					RecLock("VC1",.f.,.t.)
					DbDelete()
					MsUnlock()
				EndIf
				DbSelectArea("VC1")
				DbSkip()
			EndDo
		Next
		If lVCM510CEV
			aCEV := VCM510CEV("4",VV0->VV0_TIPFAT,"") // 4 = Venda Veiculo
		Else // Temporario
			cCEV := Alltrim(GetNewPar("MV_GCFVCEV",""))
			If !Empty(cCEV)
				aCEV := {{substr(cCEV,1,1),Val(substr(cCEV,2,3)),substr(cCEV,5,6),Val(substr(cCEV,11,3))}}
			EndIf
		EndIf
		For ni := 1 to len(aCEV)
			If Empty(aCEV[ni,3])
				aCEV[ni,3] := VV0->VV0_CODVEN // Vendedor
			EndIf
			cCEV := "X"
			////////////////////////////////////////////////////////////////////////////////
			// CEV - Verificar se o Tipo de Agenda e' de Veiculos                         //
			////////////////////////////////////////////////////////////////////////////////
			cSQL := "SELECT R_E_C_N_O_ FROM "+RetSQLName("VC5")+" WHERE VC5_FILIAL='"+xFilial("VC5")+"' AND VC5_TIPAGE='"+aCEV[ni,1]+"' AND "
			If VV0->VV0_TIPFAT <> "1" // Veiculo Novo
				cSQL += "VC5_AGEOFI='4' AND "
			Else // Veiculo Usado
				cSQL += "VC5_AGEOFI='5' AND "
			EndIf
			cSQL += "D_E_L_E_T_=' '"
			If FM_SQL(cSQL) <= 0
				cCEV := "" // Nao Gerar Agenda quando o TIPO DE ORIGEM nao for VEICULOS
			Else
				/////////////////////////////////////////////////////////////////////////////////////////////////
				// CEV - Verificar se ja existe Agenda CEV para este Atendimento dentro da Qtde minima de dias //
				/////////////////////////////////////////////////////////////////////////////////////////////////
				If aCEV[ni,4] > 0 // Qtde minima de dias necessaria para criar nova Agenda
					cSQL := "SELECT VC1.R_E_C_N_O_ AS RECVC1 FROM "+RetSQLName("VC1")+" VC1 WHERE VC1.VC1_FILIAL='"+xFilial("VC1")+"' AND "
					cSQL += "VC1.VC1_TIPAGE='"+aCEV[ni,1]+"' AND "
					cSQL += "VC1.VC1_CODCLI='"+VV9->VV9_CODCLI+"' AND VC1.VC1_LOJA='"+VV9->VV9_LOJA+"' AND "
					cSQL += "VC1.VC1_CODVEN='"+aCEV[ni,3]+"' AND "
					cSQL += "VC1.VC1_TIPORI='V' AND VC1.VC1_DATAGE>='"+dtos(dDataBase-aCEV[ni,4])+"' AND VC1.D_E_L_E_T_=' '"
					If FM_SQL(cSQL) > 0
						cCEV := "" // Nao Gerar Agenda na Finalizacao quando ja existe Agenda dentro da qtde minima de dias
					EndIf
				EndIf
			EndIf
			If !Empty(cCEV)
				////////////////////////////////////////////////////////////////////////////////
				// CEV - Criar agenda de POS-VENDA - Satisfacao do Cliente                    //
				////////////////////////////////////////////////////////////////////////////////
				cSQL := "SELECT SA3.A3_NOME FROM "+RetSQLName("SA3")+" SA3 WHERE SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD='"+VV0->VV0_CODVEN+"' AND SA3.D_E_L_E_T_=' '"
				cObs := STR0090+": "+cNumAte+" "+Transform(dDataBase,"@D")+" "+substr(time(),1,5)+STR0086+" - " // Atendimento FINALIZADO / hs
				cObs += STR0085+": "+VV0->VV0_CODVEN+" "+left(FM_SQL(cSQL),20)+" - " // Vendedor
				cObs += STR0088+": "+X3CBOXDESC("VV9_TIPMID",VV9->VV9_TIPMID)+CHR(13)+CHR(10) // Tipo de Midia
				cObs += STR0042+": " // Veiculo(s)
				VVA->(DbSetOrder(1))
				VVA->(DbSeek(xFilial("VVA")+cNumAte))
				While !VVA->(Eof()) .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == cNumAte
					If !Empty(VVA->VVA_CHAINT)
						VV1->(DbSetOrder(1))
						VV1->(MsSeek(xFilial("VV1")+VVA->VVA_CHAINT))
						FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, IIF( lVVASEGMOD , VV1->VV1_SEGMOD , "" ) )
						cObs += CHR(13)+CHR(10)+Alltrim(VV1->VV1_CHASSI)+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)
					Else
						VV2->(DbSetOrder(1))
						If Empty(VVA->VVA_CODMAR)
							FGX_VV2(VVA->VVA_CODMAR, VVA->VVA_MODVEI, IIF( lVVASEGMOD , VVA->VVA_SEGMOD , "" ) )
							cObs += CHR(13)+CHR(10)+Alltrim(VVA->VVA_CODMAR)+" "
						Else
							FGX_VV2(VV0->VV0_CODMAR, VV0->VV0_MODVEI, IIF( lVVASEGMOD , VV0->VV0_SEGMOD , "" ) )
							cObs += CHR(13)+CHR(10)+Alltrim(VV0->VV0_CODMAR)+" "
						EndIf
						cObs += Alltrim(VV2->VV2_DESMOD)
					EndIf
					VVA->(DbSkip())
				EndDo
				////////////////////////////////////////////////////////////////////////////////
				// CEV - Geracao de Agenda                                                    //
				////////////////////////////////////////////////////////////////////////////////
				FS_AGENDA( aCEV[ni,1] , ( dDataBase+aCEV[ni,2] ) , aCEV[ni,3] , VV9->VV9_CODCLI , VV9->VV9_LOJA , "" , cNumAte , "" , cObs , "" , "" )
			EndIf
		Next
	Case left(cStatus,1) == "C" // Cancelamento do Atendimento
		If lVCM510CEV
			aCEV := VCM510CEV("3",VV0->VV0_TIPFAT,"") // 3 = Perseguidor Veiculo
		Else // Temporario
			cCEV := Alltrim(GetNewPar("MV_GCPVCEV",""))
			If !Empty(cCEV)
				aCEV := {{substr(cCEV,1,1),Val(substr(cCEV,2,3)),substr(cCEV,5,6),Val(substr(cCEV,11,3))}}
			EndIf
		EndIf
		For ni := 1 to len(aCEV)
			If Empty(aCEV[ni,3])
				aCEV[ni,3] := VV0->VV0_CODVEN // Vendedor
			EndIf
			////////////////////////////////////////////////////////////////////////////////
			// CEV - Deletar agenda de Perseguicao em Aberto quando Cancelar Atendimento  //
			////////////////////////////////////////////////////////////////////////////////
			DbSelectArea("VC1")
			DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
			DbSeek( xFilial("VC1") + aCEV[ni,1] + VV9->VV9_CODCLI + VV9->VV9_LOJA )
			Do While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. VC1->VC1_TIPAGE == aCEV[ni,1] .and. VC1->VC1_CODCLI + VC1->VC1_LOJA == VV9->VV9_CODCLI + VV9->VV9_LOJA
				If VC1->VC1_TIPORI == "V" .and. Alltrim(VC1->VC1_ORIGEM) == Alltrim(cNumAte) .and. Empty(VC1->VC1_DATVIS) .and. VC1->VC1_CODVEN == aCEV[ni,3]
					RecLock("VC1",.f.,.t.)
					DbDelete()
					MsUnlock()
				EndIf
				DbSelectArea("VC1")
				DbSkip()
			EndDo
		Next
		If lVCM510CEV
			aCEV := VCM510CEV("4",VV0->VV0_TIPFAT,"") // 4 = Venda Veiculo
		Else // Temporario
			cCEV := Alltrim(GetNewPar("MV_GCFVCEV",""))
			If !Empty(cCEV)
				aCEV := {{substr(cCEV,1,1),Val(substr(cCEV,2,3)),substr(cCEV,5,6),Val(substr(cCEV,11,3))}}
			EndIf
		EndIf
		For ni := 1 to len(aCEV)
			If Empty(aCEV[ni,3])
				aCEV[ni,3] := VV0->VV0_CODVEN // Vendedor
			EndIf
			////////////////////////////////////////////////////////////////////////////////
			// CEV - Deletar agenda de Pos-Venda em Aberto quando Cancelar Atendimento    //
			////////////////////////////////////////////////////////////////////////////////
			DbSelectArea("VC1")
			DbSetOrder(3) // VC1_FILIAL+VC1_TIPAGE+VC1_CODCLI+VC1_LOJA+DTOS(VC1_DATAGE)
			DbSeek( xFilial("VC1") + aCEV[ni,1] + VV9->VV9_CODCLI + VV9->VV9_LOJA )
			Do While !Eof() .and. xFilial("VC1") == VC1->VC1_FILIAL .and. VC1->VC1_TIPAGE == aCEV[ni,1] .and. VC1->VC1_CODCLI + VC1->VC1_LOJA == VV9->VV9_CODCLI + VV9->VV9_LOJA
				If VC1->VC1_TIPORI == "V" .and. Alltrim(VC1->VC1_ORIGEM) == Alltrim(cNumAte) .and. Empty(VC1->VC1_DATVIS) .and. VC1->VC1_CODVEN == aCEV[ni,3]
					RecLock("VC1",.f.,.t.)
					DbDelete()
					MsUnlock()
				EndIf
				DbSelectArea("VC1")
				DbSkip()
			EndDo
		Next
		If cStatus == "CT" // Cancelamento Total do Atendimento
			VS0->(DbSetOrder(1))
			VS0->(DbSeek(xFilial("VS0")+"000001"+VV9->VV9_MOTIVO))
			If lVCM510CEV
				aCEV := VCM510CEV("5",VV0->VV0_TIPFAT,"") // 5 = Cancelamento Veiculo
			Else // Temporario
				cCEV := Alltrim(GetNewPar("MV_GCCVCEV",""))
				If !Empty(cCEV)
					aCEV := {{substr(cCEV,1,1),Val(substr(cCEV,2,3)),substr(cCEV,5,6),Val(substr(cCEV,11,3))}}
				EndIf
			EndIf
			For ni := 1 to len(aCEV)
				If !Empty(VS0->VS0_USURES)
					aCEV[ni,3] := VS0->VS0_USURES // Vendedor Responsavel
				ElseIf Empty(aCEV[ni,3])
					aCEV[ni,3] := VV0->VV0_CODVEN // Vendedor
				EndIf
				////////////////////////////////////////////////////////////////////////////////
				// CEV - Criar agenda no Cancelamento do Atendimento                          //
				////////////////////////////////////////////////////////////////////////////////
				cObs := STR0091+": "+cNumAte+" "+STR0092+": "+VV9->VV9_FILIAL+" - "+STR0093+": "+Alltrim(VS0->VS0_DESMOT)+CHR(13)+CHR(10) // Atendimento CANCELADO / Filial / Motivo
				cObs += STR0042+": " // Veiculo(s)
				VVA->(DbSetOrder(1))
				VVA->(DbSeek(xFilial("VVA")+cNumAte))
				While !VVA->(Eof()) .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == cNumAte
					If !Empty(VVA->VVA_CHAINT)
						VV1->(DbSetOrder(1))
						VV1->(MsSeek(xFilial("VV1")+VVA->VVA_CHAINT))
						VV2->(DbSetOrder(1))
						FGX_VV2(VV1->VV1_CODMAR, VV1->VV1_MODVEI, IIF( lVVASEGMOD , VV1->VV1_SEGMOD , "" ) )
						cObs += CHR(13)+CHR(10)+Alltrim(VV1->VV1_CHASSI)+" - "+Alltrim(VV1->VV1_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)
					Else
						VV2->(DbSetOrder(1))
						If lVVACODMAR .and. !Empty(VVA->VVA_CODMAR)
							FGX_VV2(VVA->VVA_CODMAR, VVA->VVA_MODVEI, IIF( lVVASEGMOD , VVA->VVA_SEGMOD , "" ) )
						Else
							FGX_VV2(VV0->VV0_CODMAR, VV0->VV0_MODVEI, IIF( lVVASEGMOD , VV0->VV0_SEGMOD , "" ) )
						EndIf
						cObs += CHR(13)+CHR(10)+Alltrim(VV2->VV2_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)
					EndIf
					VVA->(DbSkip())
				EndDo
				////////////////////////////////////////////////////////////////////////////////
				// CEV - Geracao de Agenda                                                    //
				////////////////////////////////////////////////////////////////////////////////
				FS_AGENDA( aCEV[ni,1] , ( dDataBase+aCEV[ni,2] ) , aCEV[ni,3] , VV9->VV9_CODCLI , VV9->VV9_LOJA , "" , cNumAte , "" , cObs , "" , "" )
			Next
		EndIf
EndCase
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002ORC  ºAutor³ Andre Luis Almeida  º Data ³  17/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gerar Orcamento atraves do VZ7 ( Acoes de Venda )          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cNumAte ( Nro do Atendimento )                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002ORC(cNumAte)
Local ni        := 0
Local cQuery    := ""
Local cSQLAlias := "SQLAlias"
Local cCodVen   := ""
Local cTpTpoI   := ""
Local cTpTpoC   := ""
Local cMIL0047   := GetNewPar("MV_MIL0047","")
Local cMIL0048   := GetNewPar("MV_MIL0048","")
Local cMIL0049   := GetNewPar("MV_MIL0049","")
Local cCodCli   := ""
Local cLojCli   := ""
Local cMsg      := ""
Local cAuxIteTra := ""
Local lVZ7ITETRA := ( VZ7->(ColumnPos("VZ7_ITETRA")) > 0 )
Local lVVACODMAR := ( VVA->(ColumnPos("VVA_CODMAR")) > 0 )
Local aArea := GetArea()
VV9->(DbSetOrder(1))
VV9->(DbSeek(xFilial("VV9")+cNumAte))
VV0->(DbSetOrder(1))
VV0->(DbSeek(xFilial("VV0")+cNumAte))
VVA->(DbSetOrder(1))
VVA->(DbSeek(xFilial("VVA")+cNumAte))
// Parametros do Atendimento de Veiculo //
Pergunte("VXA018",.f.)

cCodVen := Iif(!Empty(cMIL0047),cMIL0047,MV_PAR05) // Vendedor para Orcamento
cTpTpoI := Iif(!Empty(cMIL0048),cMIL0048,MV_PAR06) // Tipo de Tempo Interno
cTpTpoC := Iif(!Empty(cMIL0049),cMIL0049,MV_PAR07) // Tipo de Tempo Cliente
///////////////////////
// Orcamento Interno //
///////////////////////
cQuery := "SELECT VZ7.VZ7_ITECAM , VZ7.VZ7_VALITE , VZX.VZX_DESCAM "
If lVZ7ITETRA
	cQuery += " , VZ7.VZ7_ITETRA "
Else
	cQuery += " , '  ' AS VZ7_ITETRA "
EndIf
cQuery += "FROM "+RetSQLName("VZ7")+" VZ7 "
cQuery += "LEFT JOIN "+RetSQLName("VZX")+" VZX ON VZX.VZX_FILIAL='"+xFilial("VZX")+"' AND VZX.VZX_ITECAM=VZ7.VZ7_ITECAM AND VZX.D_E_L_E_T_=' ' "
cQuery += "WHERE VZ7.VZ7_FILIAL='"+xFilial("VZ7")+"'"
cQuery += " AND VZ7.VZ7_NUMTRA='"+VV9->VV9_NUMATE+"'"
cQuery += " AND ( VZ7.VZ7_AGRVLR='0' OR ( VZ7.VZ7_AGRVLR='3' AND VZ7.VZ7_COMPAG='2' ) )"
cQuery += " AND VZ7.VZ7_GERORC='1'"
cQuery += " AND VZ7.D_E_L_E_T_=' '"
If lVZ7ITETRA
	cQuery += " ORDER BY VZ7.VZ7_ITETRA,VZ7.VZ7_ITECAM"
EndIf
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
cAuxIteTra := ""
While !(cSQLAlias)->(Eof())

	cAuxIteTra := (cSQLAlias)->VZ7_ITETRA

	If !Empty(cAuxIteTra)
		VVA->(dbSetOrder(4))
		VVA->(dbSeek(xFilial("VVA") + VV9->VV9_NUMATE + cAuxIteTra))
		VVA->(dbSetOrder(1))
	EndIf

	cMsg := STR0094+CHR(13)+CHR(10) // Foram criados os seguintes Orcamentos:
	cCodCli := VV9->VV9_CODCLI
	cLojCli := VV9->VV9_LOJA
	VOI->(DbSetOrder(1))
	VOI->(DbSeek(xFilial("VOI")+cTpTpoI))
	If VOI->VOI_USAPRO == "1"		// Fabrica
		VE4->(DbSetOrder(1))
		If lVVACODMAR .and. !Empty(VVA->VVA_CODMAR)
			VE4->(DbSeek(xFilial("VE4")+VVA->VVA_CODMAR))
		Else
			VE4->(DbSeek(xFilial("VE4")+VV0->VV0_CODMAR))
		EndIf
		cCodCli := VE4->VE4_CODFAB
		cLojCli := VE4->VE4_LOJA
	ElseIf VOI->VOI_USAPRO == "2"	// Cliente Padrao
		cCodCli := VOI->VOI_CLIFAT
		cLojCli := VOI->VOI_LOJA
	EndIf
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
	DbSelectArea("VS1")
	RecLock("VS1",.t.)
	VS1->VS1_FILIAL := xFilial("VS1")
	VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
	VS1->VS1_TIPORC := "2"
	VS1->VS1_CLIFAT := cCodCli
	VS1->VS1_LOJA   := cLojCli
	VS1->VS1_FORMUL := VOI->VOI_VALPEC
	VS1->VS1_TIPTEM := cTpTpoC
	VS1->VS1_TIPTSV := cTpTpoC
	VS1->VS1_NCLIFT := SA1->A1_NOME
	VS1->VS1_TIPCLI := SA1->A1_TIPO
	VS1->VS1_CODMAR := VV0->VV0_CODMAR
	VS1->VS1_DATORC := CriaVar("VS1_DATORC")
	VS1->VS1_HORORC := CriaVar("VS1_HORORC")
	VS1->VS1_CODVEN := cCodVen
	VS1->VS1_DATVAL := CriaVar("VS1_DATVAL")
	VS1->VS1_CHAINT := VVA->VVA_CHAINT
	VS1->VS1_TIPVEN := "1" // Varejo
	VS1->VS1_STATUS := "0" // Orcamento Digitado
	VS1->VS1_CFNF   := "1" // Gera Nota Fiscal
	VS1->VS1_NUMATE := VV9->VV9_NUMATE
	MsUnLock()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0089+" - "+STR0001+" - "+STR0095 ) // Grava Data/Hora na Mudança de Status do Orçamento / Veiculo / Atendimento / Interno
	EndIf
	If FindFunction("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIf
	ConfirmSx8()
	cMsg += CHR(13)+CHR(10)+STR0095+": "+VS1->VS1_NUMORC // Interno
	ni := 0
	While !(cSQLAlias)->(Eof()) .and. cAuxIteTra == (cSQLAlias)->VZ7_ITETRA
		ni++
		DbSelectArea("VST")
		RecLock("VST",.t.)
		VST->VST_FILIAL := xFilial("VST")
		VST->VST_TIPO   := "1"
		VST->VST_CODIGO := VS1->VS1_NUMORC
		VST->VST_SEQINC := strzero(ni,2)
		VST->VST_DESINC := STR0095+": "+(cSQLAlias)->VZ7_ITECAM+"-"+Alltrim((cSQLAlias)->VZX_DESCAM)+" "+Transform((cSQLAlias)->VZ7_VALITE,"@E 999,999.99") // Interno
		MsUnLock()
		(cSQLAlias)->(dbSkip())
	EndDo
EndDo
(cSQLAlias)->(dbCloseArea())
///////////////////////
// Orcamento Cliente //
///////////////////////
cQuery := "SELECT VZ7.VZ7_ITECAM , VZ7.VZ7_VALITE , VZX.VZX_DESCAM "
If lVZ7ITETRA
	cQuery += " , VZ7.VZ7_ITETRA "
Else
	cQuery += " , '  ' AS VZ7_ITETRA "
EndIf
cQuery += "FROM "+RetSQLName("VZ7")+" VZ7 "
cQuery += "LEFT JOIN "+RetSQLName("VZX")+" VZX ON VZX.VZX_FILIAL='"+xFilial("VZX")+"' AND VZX.VZX_ITECAM=VZ7.VZ7_ITECAM AND VZX.D_E_L_E_T_=' ' "
cQuery += "WHERE VZ7.VZ7_FILIAL='"+xFilial("VZ7")+"'"
cQuery += " AND VZ7.VZ7_NUMTRA='"+VV9->VV9_NUMATE+"'"
cQuery += " AND VZ7.VZ7_AGRVLR='3'"
cQuery += " AND VZ7.VZ7_COMPAG='3'"
cQuery += " AND VZ7.D_E_L_E_T_=' '"
If lVZ7ITETRA
	cQuery += " ORDER BY VZ7.VZ7_ITETRA,VZ7.VZ7_ITECAM"
EndIf
cAuxIteTra := ""
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAlias, .F., .T. )
While !(cSQLAlias)->(Eof())

	cAuxIteTra := (cSQLAlias)->VZ7_ITETRA

	If !Empty(cAuxIteTra)
		VVA->(dbSetOrder(4))
		VVA->(dbSeek(xFilial("VVA") + VV9->VV9_NUMATE + cAuxIteTra))
		VVA->(dbSetOrder(1))
	EndIf

	If Empty(cMsg)
		cMsg := STR0094+CHR(13)+CHR(10) // Foram criados os seguintes Orcamentos:
	EndIf
	cCodCli := VV9->VV9_CODCLI
	cLojCli := VV9->VV9_LOJA
	VOI->(DbSetOrder(1))
	VOI->(DbSeek(xFilial("VOI")+cTpTpoC))
	If VOI->VOI_USAPRO == "1"		// Fabrica
		VE4->(DbSetOrder(1))
		If lVVACODMAR .and. !Empty(VVA->VVA_CODMAR)
			VE4->(DbSeek(xFilial("VE4")+VVA->VVA_CODMAR))
		Else
			VE4->(DbSeek(xFilial("VE4")+VV0->VV0_CODMAR))
		EndIf
		cCodCli := VE4->VE4_CODFAB
		cLojCli := VE4->VE4_LOJA
	ElseIf VOI->VOI_USAPRO == "2"	// Cliente Padrao
		cCodCli := VOI->VOI_CLIFAT
		cLojCli := VOI->VOI_LOJA
	EndIf
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCodCli+cLojCli))
	DbSelectArea("VS1")
	RecLock("VS1",.t.)
	VS1->VS1_FILIAL := xFilial("VS1")
	VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
	VS1->VS1_TIPORC := "2"
	VS1->VS1_CLIFAT := cCodCli
	VS1->VS1_LOJA   := cLojCli
	VS1->VS1_FORMUL := VOI->VOI_VALPEC
	VS1->VS1_TIPTEM := cTpTpoC
	VS1->VS1_TIPTSV := cTpTpoC
	VS1->VS1_NCLIFT := SA1->A1_NOME
	VS1->VS1_TIPCLI := SA1->A1_TIPO
	VS1->VS1_CODMAR := VV0->VV0_CODMAR
	VS1->VS1_DATORC := CriaVar("VS1_DATORC")
	VS1->VS1_HORORC := CriaVar("VS1_HORORC")
	VS1->VS1_CODVEN := cCodVen
	VS1->VS1_DATVAL := CriaVar("VS1_DATVAL")
	VS1->VS1_CHAINT := VVA->VVA_CHAINT
	VS1->VS1_TIPVEN := "1" // Varejo
	VS1->VS1_STATUS := "0" // Orcamento Digitado
	VS1->VS1_CFNF   := "1" // Gera Nota Fiscal
	VS1->VS1_NUMATE := VV9->VV9_NUMATE
	MsUnLock()
	If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
		OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , STR0089+" - "+STR0001+" - "+STR0060 ) // Grava Data/Hora na Mudança de Status do Orçamento / Veiculo / Atendimento / Cliente
	EndIf
	If FindFunction("FM_GerLog")
		//grava log das alteracoes das fases do orcamento
		FM_GerLog("F",VS1->VS1_NUMORC)
	EndIf
	ConfirmSx8()
	cMsg += CHR(13)+CHR(10)+STR0060+": "+VS1->VS1_NUMORC // Cliente
	ni := 0
	While !(cSQLAlias)->(Eof()) .and. cAuxIteTra == (cSQLAlias)->VZ7_ITETRA
		ni++
		DbSelectArea("VST")
		RecLock("VST",.t.)
		VST->VST_FILIAL := xFilial("VST")
		VST->VST_TIPO   := "1"
		VST->VST_CODIGO := VS1->VS1_NUMORC
		VST->VST_SEQINC := strzero(ni,2)
		VST->VST_DESINC := STR0060+": "+(cSQLAlias)->VZ7_ITECAM+"-"+Alltrim((cSQLAlias)->VZX_DESCAM)+" "+Transform((cSQLAlias)->VZ7_VALITE,"@E 999,999.99") // Cliente
		MsUnLock()
		(cSQLAlias)->(dbSkip())
	EndDo
EndDo
(cSQLAlias)->(dbCloseArea())
RestArea( aArea )
If !Empty(cMsg)
	MsgInfo(cMsg,STR0011) // / Atencao
EndIf
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002OPCOESºAutor³ Rubens              º Data ³  18/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Montagem do menu de opcoes                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002OPCOES(nOpc)
Local nQtdeBot1, nQtdeBot2, nQtdeBot3, nQtdeSep, nLinha, nDist, nLargura, nAltura, nBloco, nColuna
Local lMapaAprov := .f. // 1=Pre-Aprova;2=Aprova
Local lDesRecVei := .f. // Despesa/Receita - Visualiza
Local lBonusVeic := .f. // Bonus Veiculo - Visualiza
Local lImprAtend := ExistBlock("ATENDVEI")   // Impressao do Atendimento do Veiculo ( Proposta )
Local lTestDrive := ExistBlock("PEVM011ITD") // Impressao Formulario Test-Drive
Local cVeiculo   := ""
Local lVeicOK    := VX002VLVEID(nOpc,.f.) // Verifica se o veiculo selecionado esta deletado na GetDados.
Local lBotOut    := .f.
Local aBotOut    := {}
Local ni         := 0

If ExistBlock("VX002F10")
	lBotOut := .t.
	aBotOut := ExecBlock("VX002F10",.f.,.f.,{nOpc})
EndIf

VAI->(dbSetOrder(4))
VAI->(MsSeek(xFilial("VAI")+__cUserID))
If VAI->VAI_APROVA $ "1/2/3" // 1=Pre-Aprova / 2=Aprova / 3=Aprovacao Previa
	lMapaAprov := .t.
EndIf
If VAI->VAI_DESREC <> "2" // Despesa/Receita - Visualiza
	lDesRecVei := .t.
EndIf
If VAI->(ColumnPos("VAI_BONUSV")) > 0
	If VAI->VAI_BONUSV <> "2" // Bonus - Visualiza
		lBonusVeic := .t.
	EndIf
Else
	If VAI->VAI_TIPTEC <= "3"  // 1=Diretor;2=Gerente;3=Supervisor
		lBonusVeic := .t.
	EndIf
EndIf

If !Empty(M->VVA_CHASSI)
	cVeiculo += Alltrim(M->VVA_CHASSI)+" - "
EndIf
FGX_VV2(VVA->VVA_CODMAR, VVA->VVA_MODVEI, IIF( lVVASEGMOD , VVA->VVA_SEGMOD , "" ) )
cVeiculo += Alltrim(VV2->VV2_CODMAR)+" "+Alltrim(VV2->VV2_DESMOD)

/////////////////////////////////////////////////////////
nQtdeSep  :=   0 // Qtde de Separacoes entre os blocos //
nQtdeBot1 :=   1 // Qtde de Botoes na altura (bloco 1) //
nQtdeSep++	     // separa 1                           //
nQtdeBot2 :=   5 // Qtde de Botoes na altura (bloco 2) //
nQtdeSep++	     // separa 2                           //
nQtdeBot3 :=   3 // Qtde de Botoes na altura (bloco 3) //
nQtdeBot4 :=   0 // Qtde de Botoes na altura (bloco 4) //
If lBotOut .and. len(aBotOut) > 0                      //
	nQtdeSep++   // separa 3                           //
	nQtdeBot4 := int(( len(aBotOut) / 3 )) + 1        //
EndIf                                                  //
/////////////////////////////////////////////////////////
nDist     :=   2 // Distancia entre os botoes          //
nAltura   :=  12 // Altura de cada botao               //
nBloco    :=  10 // Distancia entre os blocos          //
nLinha    :=   2 // Linha atual para criar o botao     //
nColuna   :=   3 // Coluna para criar o botao          //
nLargura  := 118 // Largura de cada botao              //
/////////////////////////////////////////////////////////

SetKey(VK_F4, Nil )
SetKey(VK_F7, Nil )
SetKey(VK_F10, Nil )

DEFINE MSDIALOG oDlgOpcoes TITLE (STR0043+" - <F10>") From 0,0 TO ( ( nQtdeBot1 + nQtdeBot2 + nQtdeBot3 + nQtdeBot4 + nQtdeSep ) * (nDist+nAltura) * 2 )+2,( ( ( nLargura * 3 ) + 9 ) * 2 )+1 of oDlgAtend PIXEL // Opcoes
oDlgOpcoes:lEscClose := .T.

nLinha += ( nBloco / 1.2 )
nLinha -= 3
//////////////////
// Cliente      //
//////////////////
@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot1 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL STR0060 OF oDlgOpcoes PIXEL // Cliente
nLinha++
tButton():New(nLinha,nColuna,STR0060,oDlgOpcoes, { || VX002BOTOPC(01,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })		// Cliente
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0065,oDlgOpcoes, { || VX002BOTOPC(02,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })		// Veiculos do Cliente
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0126,oDlgOpcoes, { || VX002BOTOPC(03,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })		// Registro de Abordagem/Reclamacao
//
nLinha += nAltura + nDist + ( nBloco / 1.2 )
nColuna := 3
//////////////////
// Veiculo      //
//////////////////
@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot2 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL (STR0089+" "+cVeiculo) OF oDlgOpcoes PIXEL // Veiculo
nLinha++
tButton():New(nLinha,nColuna,STR0067,oDlgOpcoes, { || VX002BOTOPC(04,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })		// Rastreamento do Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0069,oDlgOpcoes, { || VX002BOTOPC(05,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })		// Visualiza Cadastro do Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0141,oDlgOpcoes, { || VX002FOTO(nOpc)      } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })			// Foto(s)/Video(s) do Veiculo
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0070,oDlgOpcoes, { || VX002BOTOPC(06,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Opcionais do Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0071,oDlgOpcoes, { || VX002BOTOPC(07,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK .and. lBonusVeic })	// Bonus de Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0072,oDlgOpcoes, { || VX002BOTOPC(08,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK .and. lDesRecVei })	// Despesas/Receitas com o Veiculo
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0073,oDlgOpcoes, { || VX002BOTOPC(09,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Reserva/Cancela Reserva do Veiculo
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0074,oDlgOpcoes, { || VX002BOTOPC(10,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Prioridade de Venda - Reserva Temporaria
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0076,oDlgOpcoes, { || VX002BOTOPC(11,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Previsao de Entrega do Veiculo
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0082,oDlgOpcoes, { || VX002BOTOPC(17,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Custo com Vendas
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0130,oDlgOpcoes, { || VX002BOTOPC(16,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK .and. ( M->VV0_VDAFUT == "1" )  })	// Venda Futura - Relaciona Chassi
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0061,oDlgOpcoes, { || VX002BOTOPC(19,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Banco de Conhecimento do Veiculo
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0063,oDlgOpcoes, { || VX002BOTOPC(21,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Configuracao de veiculos
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0167,oDlgOpcoes, { || VX002BOTOPC(22,nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || lVeicOK  })	// Relaciona Interesse
nColuna += nLargura + 003
//
nLinha += nAltura + nDist + ( nBloco / 1.2 )
nColuna := 3
//////////////////
// Atendimento  //
//////////////////
@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot3 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL STR0001 OF oDlgOpcoes PIXEL // Atendimento
nLinha++
tButton():New(nLinha,nColuna,STR0078,oDlgOpcoes, { || VX002BOTOPC(13,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })					// Solicitar Tarefas para o Atendimento
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0079,oDlgOpcoes, { || VX002BOTOPC(14,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })					// Visualizar Tarefas do Atendimento
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0127,oDlgOpcoes, { || FM_OBSMEM(STR0127,VV0->VV0_OBSMEM,"VV0_OBSMEM","VV0_OBSERV",.f.,.t.) } , nLargura , nAltura ,,,,.T.,,,,{ || .t. })	// Historico de Manutencao do Atendimento
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0077,oDlgOpcoes, { || VX002BOTOPC(12,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })					// Valor do Minimo Comercial de Venda
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0083,oDlgOpcoes, { || VX002BOTOPC(18,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || lMapaAprov })			// Mapa de Avaliacao - Aprovacao
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0128,oDlgOpcoes, { || VX002MEMO("VV0NF",nOpc) } , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })				// Observacao na Impressao da NF
nLinha += nAltura + nDist
nColuna := 3
tButton():New(nLinha,nColuna,STR0131,oDlgOpcoes, { || ExecBlock("ATENDVEI",.f.,.f.,{ VV9->VV9_FILIAL , VV9->VV9_NUMATE }) } , nLargura , nAltura ,,,,.T.,,,,{ || lImprAtend }) // Impressao do Atendimento ( Proposta )
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0132,oDlgOpcoes, { || ExecBlock("PEVM011ITD",.f.,.f.) } , nLargura , nAltura ,,,,.T.,,,,{ || lTestDrive })	// Impressao Formulario Test-Drive
nColuna += nLargura + 003
tButton():New(nLinha,nColuna,STR0062,oDlgOpcoes, { || VX002BOTOPC(20,nOpc)  } , nLargura , nAltura ,,,,.T.,,,,{ || .t. })					// Banco de Conhecimento do Atendimento
//
//////////////////
// Customizados //
//////////////////
If lBotOut
	nLinha += nAltura + nDist + ( nBloco / 1.2 )
	nColuna := 3
	// Outros
	@ nLinha-( nBloco / 1.4 ),001 TO nLinha+((( nAltura + nDist ) * nQtdeBot4 )+(nBloco/7)),( ( nLargura * 3 ) + 11 ) LABEL STR0101 OF oDlgOpcoes PIXEL // Outros
	nLinha++
	For ni := 1 to len(aBotOut)
		tButton():New(nLinha,nColuna,aBotOut[ni,1],oDlgOpcoes, &("{ || "+aBotOut[ni,2]+" }") , nLargura , nAltura ,,,,.T.,,,,{ || .t.  })
		nColuna += nLargura + 003
		If int( ni / 3 ) == ( ni / 3 )
			nLinha += nAltura + nDist
			nColuna := 3
		EndIf
	Next
EndIf

ACTIVATE MSDIALOG oDlgOpcoes CENTER

SetKey(VK_F4,{|| VX002FOTO(nOpc) })
SetKey(VK_F7,{|| VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,,.t.) })
SetKey(VK_F10,{|| VX002OPCOES(nOpc) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  VX002VV1 ºAutor³ Andre Luis Almeida  º Data ³  26/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualiza Cadastro do Veiculo ( VV1 )                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cChaInt ( Chassi Interno )                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002VV1(cChaInt)
Private cCadastro := STR0133 // Cadastro de Veiculos - Visualizar
Private aMemos:={{"VV1_OBSMEM","VV1_OBSERV"}}
Private aCampos := {}
If !Empty(cChaInt)
	VV1->(DbSetOrder(1))
	If VV1->(MsSeek(xFilial("VV1")+cChaInt))
		VXA010V("VV1",VV1->(RecNo()),2)
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002MEMO ºAutor³ Andre Luis Almeida  º Data ³  22/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Visualiza/Altera MEMO                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cTipo                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002MEMO(cTipo,nOpc)
Local aRetObs := {"","",""}
Local lSlvInc := Inclui
Local lSlvAlt := Altera
Local nSlvOpc := nOpc
Default cTipo := ""
If !Empty(M->VV9_NUMATE)
	DbSelectArea("VV0")
	If cTipo == "VV0NF" // Atualiza Observacao da NF (VV0)
		If nOpc == 3 .or. nOpc == 4 // Incluir ou Alterar
			If nOpc == 3
				Inclui := .f.
				Altera := .t.
				nOpc   := 4
			EndIf
			If VV0->(ColumnPos("VV0_MENNOT")) > 0
				aRetObs := FM_OBSMEM(STR0128,VV0->VV0_OBSMNF,"VV0_OBSMNF","VV0_OBSENF",.t.,.t.,VV0->VV0_MENNOT,VV0->VV0_MENPAD) // Titulo Janela (Observacao na Impressao da NF) , Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.) , Msg NF SC5 , Msg Padrao SC5
				M->VV0_OBSENF := aRetObs[1]
				M->VV0_MENNOT := aRetObs[2]
				M->VV0_MENPAD := aRetObs[3]
				DbSelectArea("VV0")
				RecLock("VV0",.f.)
					VV0->VV0_MENNOT := M->VV0_MENNOT // Msg NF SC5
					VV0->VV0_MENPAD := M->VV0_MENPAD // Msg Padrao SC5
				MsUnLock()
			Else
				M->VV0_OBSENF := FM_OBSMEM(STR0128,VV0->VV0_OBSMNF,"VV0_OBSMNF","VV0_OBSENF",.t.,.t.) // Titulo Janela (Observacao na Impressao da NF), Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.) , Msg NF SC5 , Msg Padrao SC5
			EndIf
			If Empty(M->VV0_OBSENF)
				M->VV0_OBSENF := CHR(13)+CHR(10) // Limpar Observacao da NF
			EndIf
			DbSelectArea("VV0")
			MSMM(VV0->VV0_OBSMNF,TamSx3("VV0_OBSENF")[1],,M->VV0_OBSENF,1,,,"VV0","VV0_OBSMNF")
			M->VV0_OBSMNF := VV0->VV0_OBSMNF
			Inclui := lSlvInc
			Altera := lSlvAlt
			nOpc   := nSlvOpc
		Else
			If VV0->(ColumnPos("VV0_MENNOT")) > 0
				FM_OBSMEM(STR0128,VV0->VV0_OBSMNF,"VV0_OBSMNF","VV0_OBSENF",.f.,.t.,VV0->VV0_MENNOT,VV0->VV0_MENPAD) // Titulo Janela (Observacao na Impressao da NF), Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.) , Msg NF SC5 , Msg Padrao SC5
			Else
				FM_OBSMEM(STR0128,VV0->VV0_OBSMNF,"VV0_OBSMNF","VV0_OBSENF",.f.,.t.) // Titulo Janela (Observacao na Impressao da NF), Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.) , Msg NF SC5 , Msg Padrao SC5
			EndIf
		EndIf
	EndIf
Else
	MsgStop(STR0028+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0068,STR0011) // Observacao / Favor selecionar um Veiculo! / Atencao
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002LOG  ºAutor  ³ Rubens             º Data ³  25/05/10  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera Log de Alteracao                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002LOG()

Local nPos
Local nPosVVA
Local cObsAnt   := ""
Local cObsAlt   := ""
Local cObsAltIt := ""
Local AuxVlrNovo := NIL
Local lAchouVVA
Local aVLogVVA := aClone(aVLogAlter[2])	// Controla alteracao da VVA ...
Local aArea := GetArea()

If !lLogAlter
	Return
endif

dbSelectArea("VV9")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega Valores Atuais das TABELAS NO BD ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
VV9->(dbSetOrder(1))
VV9->(dbSeek(xFilial("VV9") + M->VV9_NUMATE))

VV0->(dbSetOrder(1))
VV0->(dbSeek(xFilial("VV0") + M->VV9_NUMATE))

VVA->(dbSetOrder(1))
VVA->(dbSeek(xFilial("VVA") + M->VV9_NUMATE))

If VV9->(Found()) .and. VV0->(Found()) .and. VVA->(Found())

	cObsAlt := ""

	// Verifica se houve alteração nos campos da VV0
	For nPos := 1 to Len(aVLogAlter[1])

		// Valor Novo
		AuxVlrNovo := &("VV0->"+aLogAlter[1,nPos])

		// Compara com o valor gravado
		If aVLogAlter[1,nPos] <> AuxVlrNovo .and. aVLogAlter[1,nPos] <> NIL
			cObsAlt += AllTrim(UPPER(RetTitle(aLogAlter[1,nPos]))) + " - " + STR0134 + ": " // DE
			If ValType(aVLogAlter[1,nPos]) == "N"
				cObsAlt += Transform(aVLogAlter[1,nPos], x3Picture(aLogAlter[1,nPos]) )+" - "+STR0135+": "+Transform( AuxVlrNovo , x3Picture(aLogAlter[1,nPos]) ) // PARA
			Else
				cObsAlt += AllTrim(aVLogAlter[1,nPos])+" - "+STR0135+": "+AllTrim(AuxVlrNovo) // PARA
			Endif
			cObsAlt += Chr(13)+Chr(10)
		EndIf

		// Atualiza o Valor Atual, para que na proxima
		// chamada da funcao ele compare com o valor atual
		aVLogAlter[1,nPos] := AuxVlrNovo

	Next nPos
	//

	If !Empty(cObsAlt)
		cObsAlt += Chr(13)+Chr(10)
	EndIf

	// Verifica se houve alteração nos campos da VVA
	dbSelectArea("VVA")
	While !VVA->(Eof()) .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == VV0->VV0_NUMTRA

		nPosVVA := aScan(aVLogAlter[2], {|x| x[Len(x)] == &(cVVAChvLog) } )

		If nPosVVA <= 0
			cObsAlt += STR0129 + Chr(13) + Chr(10) // "Veículo adicionado do atendimento:"
			cObsAlt += AllTrim(RetTitle("VVA_CHASSI")) + ": " + AllTrim(VVA->VVA_CHASSI) + Chr(13) + Chr(10)
			If !Empty(VVA->VVA_CODMAR)
				cObsAlt += AllTrim(RetTitle("VVA_CODMAR")) + ": " + AllTrim(VVA->VVA_CODMAR) + Chr(13) + Chr(10)
				cObsAlt += AllTrim(RetTitle("VVA_MODVEI")) + ": " + AllTrim(VVA->VVA_MODVEI) + Chr(13) + Chr(10)
			Else
				cObsAlt += AllTrim(RetTitle("VV0_CODMAR")) + ": " + AllTrim(VV0->VV0_CODMAR) + Chr(13) + Chr(10)
				cObsAlt += AllTrim(RetTitle("VV0_MODVEI")) + ": " + AllTrim(VV0->VV0_MODVEI) + Chr(13) + Chr(10)
			EndIf
			cObsAlt += Chr(13) + Chr(10)

			// Adiciona veiculo novo na matriz de LOG
			AADD( aVLogAlter[2] , Array(Len(aLogAlter[2])+1) )
			aVLogAlter[2,Len(aVLogAlter[2]),(Len(aLogAlter[2])+1)] := &cVVAChvLog
			For nPosVVA := 1 to Len(aLogAlter[2])
				nAuxColuna := FG_POSVAR(aLogAlter[2,nPosVVA],"aHeaderVVA")
				If nAuxColuna <> 0
					aVLogAlter[2,Len(aVLogAlter[2]),nPosVVA] := &(aLogAlter[2,nPosVVA])
				EndIf
			Next nPosVVA

		Else

			cObsAltIt := ""

			// Nao verifica a ultima coluna, pois a ultima coluna é utilizada para
			// posicionamento correto da VVA ...
			For nPos := 1 to (Len(aVLogAlter[2,nPosVVA]) - 1)

				// Valor Novo
				AuxVlrNovo := &("VVA->"+aLogAlter[2,nPos])

				// Compara com o valor gravado
				If aVLogAlter[2,nPosVVA,nPos] <> AuxVlrNovo .and. aVLogAlter[2,nPosVVA,nPos] <> NIL
					cObsAltIt += AllTrim(RetTitle(aLogAlter[2,nPos])) + " - " + STR0134 + ": " // DE
					If ValType(aVLogAlter[2,nPosVVA,nPos]) == "N"
						cObsAltIt += Transform(aVLogAlter[2,nPosVVA,nPos], x3Picture(aLogAlter[2,nPos]) )+" - "+STR0135+": "+;
								   Transform(AuxVlrNovo , x3Picture(aLogAlter[2,nPos]) ) // PARA
					Else
						cObsAltIt += AllTrim(aVLogAlter[2,nPosVVA,nPos])+" - "+STR0135+": "+AllTrim(AuxVlrNovo) // PARA
					Endif
					cObsAltIt += Chr(13)+Chr(10)
				EndIf

				// Atualiza o Valor Atual, para que na proxima
				// chamada da funcao ele compare com o valor atual
				aVLogAlter[2,nPosVVA,nPos] := AuxVlrNovo

			Next nPos

			If !Empty(cObsAltIt)
				cObsAlt += STR0150 + Chr(13) + Chr(10) // "Veículo alterado:"
				If !Empty(VVA->VVA_CHASSI)
					cObsAlt += AllTrim(RetTitle("VVA_CHASSI")) + ": " + AllTrim(VVA->VVA_CHASSI) + Chr(13) + Chr(10)
				Else
					If !Empty(VVA->VVA_CODMAR)
						cObsAlt += AllTrim(RetTitle("VVA_CODMAR")) + ": " + AllTrim(VVA->VVA_CODMAR) + Chr(13) + Chr(10)
						cObsAlt += AllTrim(RetTitle("VVA_MODVEI")) + ": " + AllTrim(VVA->VVA_MODVEI) + Chr(13) + Chr(10)
					Else
						cObsAlt += AllTrim(RetTitle("VV0_CODMAR")) + ": " + AllTrim(VV0->VV0_CODMAR) + Chr(13) + Chr(10)
						cObsAlt += AllTrim(RetTitle("VV0_MODVEI")) + ": " + AllTrim(VV0->VV0_MODVEI) + Chr(13) + Chr(10)
					EndIf
				EndIf
				cObsAlt += cObsAltIt + Chr(13) + Chr(10)
			EndIf

			// Remove linha da aVLogVVA para nao comparar novamente
			nPosVVA := aScan(aVLogVVA, { |x| x[Len(x)] == &(cVVAChvLog) } )
			aDel(aVLogVVA,nPosVVA)
			aSize(aVLogVVA,Len(aVLogVVA)-1)
			//

		EndIf

		VVA->(DbSkip())

	End

	// As linhas que ficaram na matriz aVLogVVA foram excluidas do atendimento ...
	For nPos := 1 to Len(aVLogVVA)
		cObsAlt += STR0151 + Chr(13) + Chr(10) // "Veículo removido do atendimento: "
		cObsAlt += AllTrim(RetTitle("VVA_ITETRA")) + ": " + aVLogVVA[nPos,Len(aVLogVVA[nPos])] + CHR(13) + CHR(10) + CHR(13) + CHR(10)

		nPosVVA := aScan(aVLogAlter[2], { |x| x[Len(x)] == aVLogVVA[nPos,Len(aVLogVVA[nPos])] } )
		If nPosVVA <> 0
			aDel(aVLogAlter[2],nPosVVA)
			aSize(aVLogAlter[2],Len(aVLogAlter[2])-1)
		EndIf
	Next nPos
	//

	If !Empty(cObsAlt)

		// Remove o Ultimo CHR(13) + CHR(10)
		cObsAlt := Left(cObsAlt,Len(cObsAlt)-2)

		cObsAnt := E_MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1])

		if !Empty(cObsAnt)
			cObsAnt += Chr(13)+Chr(10)+Repl("_",TamSx3("VV0_OBSERV")[1])+Chr(13)+Chr(10)
		endif

		cObsAnt += "***  "+left(Alltrim(UsrRetName(__CUSERID)),15)+"  "+Transform(dDataBase,"@D")+" - "+Transform(time(),"@R 99:99")+"  ***"+Chr(13)+Chr(10)

		DbSelectArea("VV0")
		MSMM(VV0->VV0_OBSMEM,TamSx3("VV0_OBSERV")[1],,cObsAnt+cObsAlt,1,,,"VV0","VV0_OBSMEM")

	EndIf

EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002VLDENCº Autor ³ Rubens Takahashi   º Data ³ 22/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de validacao da ENCHOICE                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002VLDENC(cReadVar)

Local nAuxOpc
Local cTESAux := ""
Default cReadVar := ReadVar()

If !FM_PILHA("VEIXX002")
	Return .t.
EndIf
Do Case
	Case INCLUI
		nAuxOpc := 3
	Case ALTERA
		nAuxOpc := 4
	Case EXCLUI
		nAuxOpc := 5
EndCase

Do Case
	Case cReadVar == 'M->VV0_DESACE' // Despesas Acessorias
		VX002ATFIS() // Atualiza M-> que possuem relacao com o FISCAL
		If VX002TUDOK(nAuxOpc,.f.)
			VX002GRV(nAuxOpc,.f.)
		EndIf

	Case cReadVar == 'M->VV0_VALFRE' // Valor do Frente
		VX002ATFIS() // Atualiza M-> que possuem relacao com o FISCAL
		If VX002TUDOK(nAuxOpc,.f.)
			VX002GRV(nAuxOpc,.f.)
		EndIf

	Case cReadVar == 'M->VV0_CODTES' // TES
		If FMX_TESTIP(M->VV0_CODTES) <> "S"
			VX002ExibeHelp("VX002ERR022", STR0136) // Favor selecionar um TES de SAIDA! / Atencao
			Return .f.
		EndIf
		N := 1
		If MaFisFound("IT",n)
			SF4->(dbSetOrder(1))
			If SF4->(dbSeek(xFilial("SF4")+M->VV0_CODTES))
				MaFisRef("IT_TES","VX001",M->VV0_CODTES)
				VX002ATFIS() // Atualiza M-> que possuem relacao com o FISCAL
				If VX002TUDOK(nAuxOpc,.f.)
					VX002GRV(nAuxOpc,.f.)
				EndIf
			EndIf
		EndIf
		// Apagar Tipo de Operacao quando o TES for digitado //
		If ReadVar() == 'M->VV0_CODTES'
			If VV0->(ColumnPos("VV0_OPER")) > 0
				M->VV0_OPER := space(TamSx3("VV0_OPER")[1])
			EndIf
		EndIf

	Case cReadVar == 'M->VV0_OPER' // Tipo de Operacao
		cTESAux := MaTesInt(2,M->VV0_OPER,MaFisRet(,"NF_CODCLIFOR"),MaFisRet(,"NF_LOJA"),"C",SB1->B1_COD)
		If FMX_TESTIP(cTESAux) <> "S"
			VX002ExibeHelp("VX002ERR023", STR0137) // Tipo de Operacao nao esta relacionado a um TES de SAIDA! / Atencao
			Return .f.
		EndIf
		M->VV0_CODTES := cTESAux
		VX002VLDENC("M->VV0_CODTES")

	Case cReadVar == 'M->VV0_FCICOD'
		M->VVA_FCICOD := M->VV0_FCICOD
		VX002ACOLS("VVA_FCICOD",1)
		VX002GRV(nAuxOpc,.f.)

	Case cReadVar == 'M->VV0_PEDXML'
		M->VVA_PEDXML := M->VV0_PEDXML
		VX002ACOLS("VVA_PEDXML",1)
		VX002GRV(nAuxOpc,.f.)

	Case cReadVar == 'M->VV0_ITEXML'
		M->VVA_ITEXML := M->VV0_ITEXML
		VX002ACOLS("VVA_ITEXML",1)
		VX002GRV(nAuxOpc,.f.)

	Case cReadVar == 'M->VV0_CLIENT' // Valor do Frente
		VX002ATFIS() // Atualiza M-> que possuem relacao com o FISCAL
		If VX002TUDOK(nAuxOpc,.f.)
			VX002GRV(nAuxOpc,.f.)
		EndIf
	Case cReadVar == 'M->VV0_LOJENT' // Valor do Frente
		VX002ATFIS() // Atualiza M-> que possuem relacao com o FISCAL
		If VX002TUDOK(nAuxOpc,.f.)
			VX002GRV(nAuxOpc,.f.)
		EndIf		

EndCase

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002DTVS9 º Autor ³ Andre Luis Almeida º Data ³ 12/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Alteracao das Datas do Titulo no VS9                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002DTVS9(nOpc,cNumAte,aVS9,nRecNoVS9,cTitulo,cObsTela)
Local nPosNUMIDE := 0
Local nPosTIPOPE := 0
Local nPosTIPPAG := 0
Local nPosSEQUEN := 0
Local dDtMax   := ( dDataBase + 9999 )
Local lAltDat  := .t. // Alterar DATA
Local lAltObs  := .t. // Alterar OBSERVACAO DO USUARIO
Local nOpcao   := 0
Local ni       := 0
Local dDatTit  := dDataBase
Local cVSATipo := ""
Local cObsPad  := "" // Observacao do Sistema
Local cObsUsr  := "" // Observacao do Usuario
Local lVS9OBSPAR := ( VS9->(ColumnPos("VS9_OBSPAR")) > 0 )
//
VV9->(DbSetOrder(1))
VV9->(DbSeek(xFilial("VV9")+cNumAte))
If nRecNoVS9 > 0
	/////////////////////////////////////
	// Posiciona no VS9 correspondente //
	/////////////////////////////////////
	VS9->(DbGoTo(nRecNoVS9))
Else
	Return
EndIf
If ( nOpc == 3 .or. nOpc == 4 ) // Incluir ou Alterar
	cVSATipo := FM_SQL("SELECT VSA.VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+VS9->VS9_TIPPAG+"' AND VSA.D_E_L_E_T_=' '")
	If cVSATipo == "2" // Financiamento Proprio
		lAltDat := .f.
	Else
		If cTitAten == "1" // Se gera Titulo na Pre-Aprovacao
			If cVV9Status $ "O/L/F/C" // Pre-Aprovado / Aprovado / Finalizado / Cancelado
				lAltDat := .f.
			EndIf
		Else //If cTitAten == "2" // Se gera Titulo na Aprovacao
			If cVV9Status $ "L/F/C" // Aprovado / Finalizado / Cancelado
				lAltDat := .f.
			EndIf
		EndIf
		If cVSATipo <> "5" // Diferente de Entradas
			dDtMax := ( dDataBase + FM_SQL("SELECT VSA.VSA_DIAMAX FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+VS9->VS9_TIPPAG+"' AND VSA.D_E_L_E_T_=' '") )
		EndIf
	EndIf
	If cVV9Status $ "F/C" // Finalizado / Cancelado
		lAltObs := .f.
	EndIf
Else
	lAltDat := .f.
	lAltObs := .f.
EndIf

/////////////////////////////////////////////////////////////////////
// Tela de Alteracao da Data e Visualizacao das Observacoes do VS9 //
/////////////////////////////////////////////////////////////////////
dDatTit := VS9->VS9_DATPAG
cObsPad := IIf(!Empty(cObsTela),cObsTela+CHR(13)+CHR(10)+repl("_",40)+CHR(13)+CHR(10),"")
cObsPad += E_MSMM(VS9->VS9_OBSMEM,TamSx3("VS9_OBSERV")[1])
If lVS9OBSPAR
	cObsUsr := VS9->VS9_OBSPAR
EndIf
DEFINE MSDIALOG oVX002DTVS9 TITLE cTitulo FROM 00,00 TO 370,450 OF oMainWnd PIXEL
@ 007,005 TO 025,220 LABEL "" OF oVX002DTVS9 PIXEL
@ 012,013 SAY STR0024 OF oVX002DTVS9 PIXEL COLOR CLR_HBLUE // Data
@ 011,050 MSGET oDatTit VAR dDatTit PICTURE "@D" SIZE 46,08 OF oVX002DTVS9 VALID ( dDatTit>=dDataBase .and. dDatTit<=dDtMax ) PIXEL HASBUTTON WHEN lAltDat
@ 012,125 SAY STR0026 OF oVX002DTVS9 PIXEL COLOR CLR_BLACK // Valor
@ 011,160 MSGET oValPag VAR VS9->VS9_VALPAG PICTURE "@E 999,999,999.99" SIZE 50,08 OF oVX002DTVS9 PIXEL WHEN .f.
@ 030,005 TO 098,220 LABEL STR0179 OF oVX002DTVS9 PIXEL // Observacoes do Sistema
If lAltDat .or. lAltObs
	DEFINE SBUTTON FROM 172,150 TYPE 1 ACTION (nOpcao:=1,oVX002DTVS9:End()) ENABLE OF oVX002DTVS9
EndIf
DEFINE SBUTTON FROM 172,185 TYPE 2 ACTION (oVX002DTVS9:End()) ENABLE OF oVX002DTVS9
@ 038,009 GET oObserv VAR cObsPad OF oVX002DTVS9 MEMO SIZE 207,055 PIXEL ReadOnly MEMO
@ 100,005 TO 168,220 LABEL STR0180 OF oVX002DTVS9 PIXEL // Observacoes do Usuario
If lAltObs
	@ 108,009 GET oObsUsr VAR cObsUsr OF oVX002DTVS9 MEMO SIZE 207,055 PIXEL
Else
	@ 108,009 GET oObsUsr VAR cObsUsr OF oVX002DTVS9 MEMO SIZE 207,055 PIXEL ReadOnly MEMO
EndIf
ACTIVATE MSDIALOG oVX002DTVS9 CENTER
If nOpcao == 1
	aAuxHeader := aClone(aVS9[1]) // Compatibilizacao com FG_POSVAR
	nPosNUMIDE := FG_POSVAR("VS9_NUMIDE","aAuxHeader")
	nPosTIPOPE := FG_POSVAR("VS9_TIPOPE","aAuxHeader")
	nPosTIPPAG := FG_POSVAR("VS9_TIPPAG","aAuxHeader")
	nPosSEQUEN := FG_POSVAR("VS9_SEQUEN","aAuxHeader")
	ni := ascan(aVS9[2],{|x| x[nPosNUMIDE]+x[nPosTIPOPE]+x[nPosTIPPAG]+x[nPosSEQUEN] == VS9->VS9_NUMIDE+VS9->VS9_TIPOPE+VS9->VS9_TIPPAG+VS9->VS9_SEQUEN })
	If ni > 0
		If lAltDat
			aVS9[2,ni,FG_POSVAR("VS9_DATPAG","aAuxHeader")] := dDatTit // Data do Titulo
		EndIf
		If lAltObs .and. lVS9OBSPAR
			aVS9[2,ni,FG_POSVAR("VS9_OBSPAR","aAuxHeader")] := cObsUsr // Observacao do Usuario
		EndIf
		VX002GRV(nOpc,.f.,"VS9",@aVS9)
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002CUSJURº Autor ³ Rubens Takahashi   º Data ³ 14/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza custo do veiculo e Juros de Estoque               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ nPosGetD = Posicao da GetDados para atualizar as variaveis º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VX002CUSJUR(nPosGetD)
Local cFormCusto := ""
Local nCusVeiPad := 0
Local lVdNormal  := .f.
Local lSE2Baixa  := .f.
Local cFunJEst   := AllTrim(GetNewPar("MV_FUNJEST","")) //Nome da Funcao que Calcula o Juros de Estoque
Default nPosGetD := oGetDadVVA:nAt
Private cGruVei     := PadR(AllTrim(GetMv("MV_GRUVEI")),TamSx3("B1_GRUPO")[1]," ") // Grupo do Veiculo
//
M->VVA_JUREST := 0
M->VVA_VCAVEI := 0
M->VVA_VALREV := VV2->VV2_VALREV
M->VVA_PISENT := 0
M->VVA_COFENT := 0
M->VVA_CODIND := ""
M->VVA_DESVEI := FGX_DRECVEI(VV1->VV1_CHAINT,"0",,.t.) // Levanta Despesas do Veiculo VVD
M->VVA_RECVEI := FGX_DRECVEI(VV1->VV1_CHAINT,"1",,.t.) // Levanta Receitas do Veiculo VVD
//
dbSelectArea("VVA")
// Venda Normal e NAO e' Venda Futura
If M->VV0_OPEMOV == "0" .and. M->VV0_VDAFUT <> "1"
	//
	lVdNormal := .t.
	//
	dbSelectArea("VVF")
	dbSetOrder(1)
	If dbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA )
		//
		RegTomemory("VVF",.f.) // Carregar M-> do VVF
		//
		dbSelectArea("VVG")
		dbSetOrder(1)
		If dbSeek( VV1->VV1_FILENT + VV1->VV1_TRACPA + VV1->VV1_CHAINT )
			//
			RegTomemory("VVG",.f.) // Carregar M-> do VVG
			//
			M->VVA_PISENT := VVG->VVG_PISENT
			M->VVA_COFENT := VVG->VVG_COFENT
			M->VVA_CODIND := VVG->VVG_CODIND
			If VV1->VV1_ESTVEI == "1" // Usado
				M->VVA_VALREV := VVG->VVG_VALREV
			EndIf

			FGX_VV1SB1("CHAINT", VV1->VV1_CHAINT , /* cMVMIL0010 */ , cGruVei )

			DBSelectArea("SB2")
			DBSetOrder(1)
			DBSeek(xFilial("SB2")+SB1->B1_COD+VV1->VV1_LOCPAD)

			nCusVeiPad := ( SB2->B2_CM1 + VVG->VVG_VALFRE )
			//
		EndIf
		//
		If VV1->VV1_ESTVEI == "0" //Novo
			// Modelo do Veiculo
			If !Empty(VV2->VV2_FORCUS)
				cFormCusto := VV2->VV2_FORCUS
			Else
				// Parametros da Montadora do Custo Contabil
				VE4->(dbSetOrder(1))
				If VE4->(dbSeek(xFilial("VE4") + VV1->VV1_CODMAR))
					cFormCusto := VE4->VE4_FORCTB
				EndIf
			EndIf
		Else
			cFormCusto := GetMv("MV_VUCCTB")
		EndIf
		//
		If !Empty(cFormCusto)
			nCusVeiPad := FG_FORMULA(cFormCusto) // executa a formula do custo do veiculo
		EndIf
		nCusVeiPad += VV1->VV1_DESADM // somar no custo as despesas administrativas do veiculo
		//
		dbSelectArea("SE2")
		dbSetOrder(6) // E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		If dbSeek( xFilial("SE2") + VVF->VVF_CODFOR + VVF->VVF_LOJA + VVF->VVF_SERNFI + VVF->VVF_NUMNFI )
			If SE2->E2_BAIXA # ctod("") .and. (dDataBase - SE2->E2_BAIXA) > 0  //baixado
				lSE2Baixa := .t. // SE2 baixado
			EndIf
		EndIf
		If !Empty(cFunJEst) .and. ExistBlock(cFunJEst)   // Se existir este PRW, entao ele sera usado
			M->VVA_JUREST := ExecBlock(cFunJEst,.f.,.f.,{ VV1->VV1_TRACPA , VV1->VV1_CHAINT , IIf(lSE2Baixa,SE2->E2_BAIXA,VVF->VVF_DATEMI) , dDataBase , 'V' })
		Else
			M->VVA_JUREST := FG_JurEst( VV1->VV1_TRACPA , VV1->VV1_CHAINT , IIf(lSE2Baixa,SE2->E2_BAIXA,VVF->VVF_DATEMI) , dDataBase , "V" )
		EndIf
		//
	EndIf
	//
EndIf
//
If !Empty(M->VVA_CODMAR)
	M->VVA_VCAVEI := FGX_CUSVEI( IIf(lVdNormal,M->VVA_CHAINT,"") , M->VVA_CODMAR , M->VVA_MODVEI , VV2->VV2_SEGMOD , M->VVA_CORVEI , dDataBase ) // B2_CM1 + Indice
Else
	M->VVA_VCAVEI := FGX_CUSVEI( IIf(lVdNormal,M->VVA_CHAINT,"") , M->VV0_CODMAR , M->VV0_MODVEI , VV2->VV2_SEGMOD , M->VV0_CORVEI , dDataBase ) // B2_CM1 + Indice
EndIf
If M->VVA_VCAVEI <= 0
	M->VVA_VCAVEI := nCusVeiPad // Utilizar CUSTO padrao
EndIf
//
VX002ACOLS("VVA_JUREST",nPosGetD)
VX002ACOLS("VVA_VCAVEI",nPosGetD)
VX002ACOLS("VVA_VALREV",nPosGetD)
VX002ACOLS("VVA_PISENT",nPosGetD)
VX002ACOLS("VVA_COFENT",nPosGetD)
VX002ACOLS("VVA_CODIND",nPosGetD)
VX002ACOLS("VVA_DESVEI",nPosGetD)
VX002ACOLS("VVA_RECVEI",nPosGetD)
//
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002FCPO º Autor ³ Rubens Takahashi   º Data ³ 04/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relacao dos campos que nao serao mostrados ou editados     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002FCPO( cAuxAlias , cNAOEdit , cNAOMostra , cEdit )
Local aAux    := {}
Local nCntFor := 0

Do Case

	Case cAuxAlias == "VV9"

		// Campos VV9 NAO Editaveis //
		cNAOEdit   := "VV9_NUMATE,"

		// Campos VV9 NAO Mostrar //
		cNAOMostra := "VV9_FILIAL,VV9_CODMAR,VV9_CRMOK,VV9_DATCAN,VV9_DESMAR,VV9_DESMOD,VV9_MODVEI,VV9_MOTIVO,VV9_MOTVIS,VV9_STATUS,VV9_TIPATD,VV9_USUARI,"
		cNAOMostra += "VV9_VEND1,VV9_VEND2,VV9_PEDFAB,VV9_SUBSTA,VV9_DTSUBS,"
		cNAOMostra += "VV9_SEGMOD,"


	Case cAuxAlias == "VV0"

		// Campos VV0 NAO Editaveis //
		cNAOEdit   := "VV0_NUMTRA,VV0_FORPAG,VV0_PLAVEI,VV0_CHASSI,VV0_VALSOL,VV0_IMPOST,VV0_BASSOL,VV0_VBAICM,"
		If VAI->VAI_ATEOUT <> "2" // NAO ALTERA o Vendedor  no Atendimento
			cNAOEdit += "VV0_CODVEN,"
		EndIf

		// Campos VV0 NAO Mostrar //
		cNAOMostra := "VV0_ABCOAA,VV0_ACESSO,VV0_AGEFIN,VV0_AGREGA,VV0_AUTFAT,VV0_BXAFUT,VV0_CARTEI,VV0_CATVEN,VV0_CBCOAA,VV0_CHAINT,VV0_CIDCLI,VV0_CLIALI,"
		cNAOMostra += "VV0_CLICSG,VV0_CODAGE,VV0_CODAVA,VV0_CODBCO,VV0_CODCLI,VV0_CODGRU,VV0_COEFIC,VV0_COMFTD,VV0_CORVEI,VV0_CRECON,VV0_CRMOK1,VV0_CRMOK2,"
		cNAOMostra += "VV0_DATAPR,VV0_DATINI,VV0_DATMOV,VV0_DATUSU,VV0_DESFAI,VV0_DESFPG,VV0_DESGRU,VV0_DESMAR,VV0_DESTVD,VV0_DEVTRA,VV0_DPGGER,VV0_DPGSUP,"
		cNAOMostra += "VV0_DPGVEN,VV0_DTHEMI,VV0_EMPCON,VV0_ENDCLI,VV0_ESTCLI,VV0_EXPVEI,VV0_FILCHA,VV0_FILIAL,VV0_FORPAG,VV0_GRUMOD,VV0_HISPGC,VV0_LOJA,"
		cNAOMostra += "VV0_LOJAAV,VV0_LOJALI,VV0_LOJCSG,VV0_MODVDA,VV0_NNFCOM,VV0_NOMAVA,VV0_NOMCLI,VV0_NOMCON,VV0_NUMCOT,VV0_NUMLIB,VV0_NUMNFI,VV0_NUMOSV,"
		cNAOMostra += "VV0_NUMPED,VV0_NUMTRA,VV0_OPCION,VV0_OPEMOV,VV0_PCOMFN,VV0_PCUSFN,VV0_PERCOM,VV0_PERREP,VV0_PTXRET,VV0_REPFTD,VV0_NATFIN,VV0_SEQVIS,"
		cNAOMostra += "VV0_SERNFI,VV0_SIMULA,VV0_SITNFI,VV0_SNFCOM,VV0_STATUS,VV0_TABFAI,VV0_TIPFAT,VV0_TIPFIN,VV0_TIPVEN,VV0_TOTENT,VV0_TOTICM,VV0_TRADEV,"
		cNAOMostra += "VV0_TXAFIN,VV0_VALCOR,VV0_VALFIN,VV0_VALNEG,VV0_VALPAR,VV0_VALRES,VV0_VALTAB,VV0_VALTAC,VV0_VCARCR,VV0_VCOMFN,VV0_VCUSFN,VV0_VTXRET,"
		cNAOMostra += "VV0_RESERV,VV0_DATVAL,VV0_HORVAL,VV0_DATEMI,VV0_OBSERV,VV0_OBSMEM,VV0_VALTRO,VV0_VALMOV,VV0_PERDES,VV0_VALDES,VV0_VALTOT,VV0_TIPFTD,"
		cNAOMostra += "VV0_SEQFTD,VV0_CLIFTD,VV0_VDAFUT,VV0_OBSENF,VV0_OBSMNF,VV0_CFINAM,VV0_NFINAM,VV0_CLFINA,VV0_LJFINA,VV0_DATENT,VV0_DIA1PC,VV0_DIAFIX,"
		cNAOMostra += "VV0_FPGFTD,VV0_DPGFAB,VV0_FIXDIA,VV0_INTERV,VV0_LOJFTD,VV0_NNFFDI,VV0_PARCEL,VV0_SNFFDI,VV0_DTIFPR,VV0_D1PFPR,VV0_VALFPR,VV0_PARFPR,"
		cNAOMostra += "VV0_INTFPR,VV0_FIXFPR,VV0_DIAFPR,VV0_JURFPR,VV0_MESFPR,VV0_PREBFN,VV0_VALREB,VV0_TACLIQ,VV0_SUBFIN,VV0_TACSUB,VV0_TACFIN,VV0_BONEMP,"
		cNAOMostra += "VV0_NUMEMP,VV0_DATEMP,VV0_TIPO,VV0_SIMVDA,VV0_USRAPR,VV0_TIPMOV,VV0_CFFINA,VV0_VFFINA,VV0_DFFINA,VV0_VRFINA,VV0_DRFINA,VV0_MENNOT,"
		cNAOMostra += "VV0_MENPAD,VV0_CLIFOR,VV0_TIPDOC,VV0_GERFIN,"
		If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )
			cNAOMostra += "VV0_CHASSI,VV0_CODMAR,VV0_MODVEI,VV0_DESMOD,VV0_DESCOR,VV0_FABMOD,VV0_PLAVEI,VV0_CODTES,VV0_OPER,VV0_ALIICM,VV0_FCICOD,VV0_CAMPAN,"
			cNAOMostra += "VV0_SEGMOD,VV0_PEDXML,VV0_ITEXML,"
		EndIf
		If !lIntLoja
			cNAOMostra += "VV0_PESQLJ,"
		EndIf
		cNAOMostra += "VV0_FPGPAD,"
		If ExistBlock("VX015FNM") // NAO mostrar campos Customizados no FINAME (VEIXX015)
			aAux := ExecBlock("VX015FNM",.f.,.f.)
			For nCntFor := 1 to len(aAux)
				cNAOMostra += aAux[nCntFor]+","
			Next
		EndIf

		// Campos VV0 Editaveis quando Atendimento esta com o STATUS ( Pendente Aprovacao, Pre-Aprovado ou Aprovado )
		cEdit := "VV0_CODTRA,VV0_VOLUME,VV0_ESPECI,VV0_VEICUL,"


	Case cAuxAlias == "VVA"

		// Campos VVA NAO Editaveis //
		cNAOEdit   := "VVA_NUMTRA,VVA_ACESSO,VVA_AGREGA,VVA_ALIICM,VVA_ALIIPI,VVA_BASSOL,VVA_BONCON,VVA_BONFAB,VVA_BONREG,VVA_CHAINT,VVA_CHASSI,VVA_CODMAR,"
		cNAOEdit   += "VVA_COFVEN,VVA_CORVEI,VVA_DATBFB,VVA_DATVAL,VVA_DESACE,VVA_DESCOR,VVA_DESMAR,VVA_DESMOD,VVA_ESTVEI,VVA_FATTOT,VVA_GRUMOD,VVA_HORVAL,"
		cNAOEdit   += "VVA_ICMVEN,VVA_ISSCVD,VVA_ITETRA,VVA_MODVEI,VVA_PISVEN,VVA_PLAVEI,VVA_REDVDA,VVA_RESERV,VVA_SEGVIA,VVA_TOTCUS,VVA_USUARI,VVA_UTROCO,"
		cNAOEdit   += "VVA_SEGMOD,"
		cNAOEdit   += "VVA_CODORI,"
		cNAOEdit   += "VVA_VALIRF,VVA_VALMOV,VVA_VALSOL,VVA_VBAICM,VVA_DTEPRV,VVA_HREPRV,VVA_FIEPRV,VVA_BOEPRV,VVA_DTEREA,VVA_DTESUG,VVA_CUSVDA,VVA_VALCMP,"
		cNAOEdit   += "VVA_DIFAL,"

		// Campos VVA NAO Mostrar //
		cNAOMostra := ""
		If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )
			cNAOMostra += "VVA_ALIPIC,VVA_AMFIMP,VVA_AMFSSO,VVA_ASSIMP,VVA_BMFCON,VVA_BMFFAB,VVA_BMFREG,VVA_BONUS,VVA_CMFCOT,VVA_CMFCTP,VVA_CMFENT,VVA_CMFGER,"
			cNAOMostra += "VVA_CMFPAT,VVA_CMFPGC,VVA_CMFVDE,VVA_CMFVEN,VVA_CODIND,VVA_COFENT,VVA_COMCOT,VVA_COMCTP,VVA_COMGER,VVA_COMPAT,VVA_COMPGC,"
			cNAOMostra += "VVA_COMVDE,VVA_CPGGER,VVA_CPGSUP,VVA_CPGVEN,VVA_DATDCL,VVA_DATENT,VVA_DATRCU,VVA_DATRTC,VVA_DESCLI,VVA_DESFIX,VVA_DESVEI,VVA_DMFCLI,"
			cNAOMostra += "VVA_DMFFIN,VVA_DMFFIX,VVA_DMFVEI,VVA_DSPFIN,VVA_DTLIBE,VVA_DTLIBF,VVA_EMINVD,VVA_ENTMEM,VVA_FMFTOT,VVA_HORREA,VVA_ICMCOM,VVA_IMFBFB,"
			cNAOMostra += "VVA_IMFCOM,VVA_IMFCVD,VVA_IMFRTE,VVA_IMFVEN,VVA_INISBF,VVA_INISRT,VVA_INPCBF,VVA_INPCRT,VVA_INPICO,VVA_ISSBFB,VVA_ISSRTE,VVA_JMFEST,"
			cNAOMostra += "VVA_JUREST,VVA_LMFBRU,VVA_LMFLQ1,VVA_LMFLQ2,VVA_LUCBRU,VVA_LUCLQ1,VVA_LUCLQ2,VVA_NUMTRA,VVA_OBSENT,VVA_OBSERV,VVA_OBSMEM,VVA_PERCVD,"
			cNAOMostra += "VVA_PERDES,VVA_PERDVD,VVA_PISBFB,VVA_PISENT,VVA_PISRTE,VVA_PMFBFB,VVA_PMFENT,VVA_PMFRTE,VVA_VALFRE,VVA_PMFVEN,VVA_REBATE,VVA_RECTEC,"
			cNAOMostra += "VVA_RECVEI,VVA_REDCUS,VVA_RMFCUS,VVA_RMFTEC,VVA_RMFVEI,VVA_SMFVIA,VVA_TITBON,VVA_TMFCUS,VVA_TMFDES,VVA_TMFIMP,VVA_TOTDES,VVA_TOTIMP,"
			cNAOMostra += "VVA_FILENT,VVA_TRACPA,VVA_USUREA,VVA_VALASS,VVA_VALCVD,VVA_VALDES,VVA_VALDVD,VVA_VALREV,VVA_VDESCO,VVA_VMFASS,VVA_VMFCVD,VVA_VMFFRE,"
			cNAOMostra += "VVA_VMFIRF,VVA_VMFMOV,VVA_VMFREV,VVA_VMFSCO,VVA_VMFVDA,VVA_VMFVEI,VVA_VRENET,VVA_VCAVEI,VVA_FORMUL,VVA_VENREA,"
		Elseif nVerAten == 2
			cNAOMostra += "VVA_FCICOD,VVA_FORMUL,VVA_CAMPAN,VVA_PEDXML,VVA_ITEXML,"
		EndIf


EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002OVS9 º Autor ³ Rubens Takahashi   º Data ³ 05/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera observacao da composicao de parcela (VS9/VSE/VAZ)     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002OVS9( cNumAte, cTipPag, cTipVSA , cRefPag, cSequen, cCliFiname, cLojFiname, cCodFiname, cPACFiname )

Local cRetorno := ""
Local cQuery   := ""
Local cSQLAux  := GetNextAlias()

Default cTipVSA := ""

// Se nao for passado o Tipo do VSA, deve buscar na base
If Empty(cTipVSA)
	cTipVSA := FM_SQL("SELECT VSA_TIPO FROM "+RetSQLName("VSA")+" VSA WHERE VSA.VSA_FILIAL='"+xFilial("VSA")+"' AND VSA.VSA_TIPPAG='"+cTipPag+"' AND VSA.D_E_L_E_T_=' '")
Endif

Do Case

	Case cTipVSA == "1" // Financiamento / Leasing
		cRetorno := Alltrim(X3CBOXDESC("VAR_TIPTAB",left(cRefPag,1)))+" - "
		cQuery := "SELECT VSE.VSE_DESCCP , VSE.VSE_VALDIG FROM "+RetSqlName("VSE")+" VSE WHERE "
		cQuery += "VSE.VSE_FILIAL='"+xFilial("VSE")+"' AND VSE.VSE_NUMIDE='"+cNumAte+"' AND VSE.VSE_TIPOPE='V' AND VSE.VSE_TIPPAG='"+cTIPPAG+"' AND VSE.VSE_SEQUEN='"+cSEQUEN+"' AND VSE.D_E_L_E_T_=' ' ORDER BY VSE.VSE_DESCCP"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
		While !(cSQLAux)->(Eof())
			cRetorno += Alltrim(substr((cSQLAux)->( VSE_DESCCP ),2))+" "+Alltrim((cSQLAux)->( VSE_VALDIG ))+" "
			If left((cSQLAux)->( VSE_DESCCP ),1) == "4"
				Exit
			EndIf
			(cSQLAux)->(dbSkip())
		EndDo
		(cSQLAux)->(dbCloseArea())

	Case cTipVSA == "2" // Financiamento Proprio
		cRetorno := cRefPag  // 001/100

	Case cTipVSA == "3" // Consorcio
		cRetorno := IIf(left(cRefPag,1)=="1",STR0139,STR0140)+" - " // Quitado / Nao Quitado
		cQuery := "SELECT VSE.VSE_DESCCP , VSE.VSE_VALDIG FROM "+RetSqlName("VSE")+" VSE WHERE "
		cQuery += "VSE.VSE_FILIAL='"+xFilial("VSE")+"' AND VSE.VSE_NUMIDE='"+cNumAte+"' AND VSE.VSE_TIPOPE='V' AND VSE.VSE_TIPPAG='"+cTipPag+"' AND VSE.VSE_SEQUEN='"+cSequen+"' AND VSE.D_E_L_E_T_=' ' ORDER BY VSE.VSE_DESCCP"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
		While !(cSQLAux)->(Eof())
			cRetorno += Alltrim(substr((cSQLAux)->( VSE_DESCCP ),2))+" "+Alltrim((cSQLAux)->( VSE_VALDIG ))+" "
			(cSQLAux)->(dbSkip())
		EndDo
		(cSQLAux)->(dbCloseArea())

	Case cTipVSA == "4" // Veiculo Usado (Avaliacoes)
		cQuery := "SELECT VAZ.VAZ_PLAVEI , VAZ.VAZ_FABMOD , VAZ.VAZ_CODMAR , VV2.VV2_DESMOD FROM "+RetSqlName("VAZ")+" VAZ "
		cQuery += "INNER JOIN "+RetSQLName("VV2")+" VV2 ON ( VV2.VV2_FILIAL='"+xFilial("VV2")+"' AND VV2.VV2_CODMAR=VAZ.VAZ_CODMAR AND VV2.VV2_MODVEI=VAZ.VAZ_MODVEI AND VV2.D_E_L_E_T_ = ' ' ) "
		cQuery += "WHERE VAZ.VAZ_FILIAL='"+xFilial("VAZ")+"' AND VAZ.VAZ_CODIGO='"+cRefPag+"' AND VAZ.D_E_L_E_T_=' ' ORDER BY VAZ.VAZ_REVISA DESC "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
		If !(cSQLAux)->( Eof() )
			cRetorno := Transform((cSQLAux)->( VAZ_PLAVEI ),VV1->(x3Picture("VV1_PLAVEI")))+" - "+Transform((cSQLAux)->( VAZ_FABMOD ),VV1->(x3Picture("VV1_FABMOD")))+" - "+(cSQLAux)->( VAZ_CODMAR )+" "+(cSQLAux)->( VV2_DESMOD )
		EndIf
		(cSQLAux)->( dbCloseArea() )

	Case cTipVSA == "5" // Entradas
		cQuery := "SELECT VSE.VSE_DESCCP , VSE.VSE_VALDIG FROM "+RetSqlName("VSE")+" VSE WHERE "
		cQuery += "VSE.VSE_FILIAL='"+xFilial("VSE")+"' AND VSE.VSE_NUMIDE='"+cNumAte+"' AND VSE.VSE_TIPOPE='V' AND VSE.VSE_TIPPAG='"+cTipPag+"' AND VSE.VSE_SEQUEN='"+cSequen+"' AND VSE.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cSQLAux, .F., .T. )
		While !(cSQLAux)->(Eof())
			cRetorno += Alltrim((cSQLAux)->( VSE_DESCCP ))+": "+Alltrim((cSQLAux)->( VSE_VALDIG ))+", "
			(cSQLAux)->(dbSkip())
		EndDo
		(cSQLAux)->(dbCloseArea())

	Case cTipVSA == "6" // Finame
		cRetorno := cCliFiname+"-"+cLojFiname+" "
		cRetorno += Alltrim(left(FM_SQL("SELECT SA1.A1_NOME FROM "+RetSQLName("SA1")+" SA1 WHERE SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD='"+cCliFiname+"' AND SA1.A1_LOJA='"+cLojFiname+"' AND SA1.D_E_L_E_T_=' '"),20))+" "
		cRetorno += "( "+STR0003+": "+Alltrim(cCodFiname)+" - "+STR0097+": "+Alltrim(cPACFiname)+" )" // Finame / Nro.PAC

EndCase

Return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002VC3  º Autor ³ Andre Luis Almeida º Data ³ 04/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inserir/Excluir registro no VC3 - Frota do Cliente         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002VC3( cTp , cNumAte , cChassi )
If !Empty(cChassi)
	VV9->(DbSetOrder(1)) // VV9_FILIAL+VV9_NUMATE
	VV9->(MsSeek( xFilial("VV9") + cNumAte ))
	VV1->(DbSetOrder(2)) // VV1_FILIAL+VV1_CHASSI
	VV1->(MsSeek( xFilial("VV1") + cChassi ))
	VVA->(DbSetOrder(1)) // VVA_FILIAL+VVA_NUMTRA+VVA_CHASSI
	VVA->(MsSeek( xFilial("VVA") + cNumAte + cChassi ))
	If cTp == "F" // Finalizacao do Atendimento - Inserir VC3
		DbSelectArea("VC3")
		RecLock("VC3",.t.)
		VC3->VC3_FILIAL := xFilial("VC3")
		VC3->VC3_CODCLI := VV9->VV9_CODCLI
		VC3->VC3_LOJA   := VV9->VV9_LOJA
		VC3->VC3_CODMAR := VV1->VV1_CODMAR
		VC3->VC3_MODVEI := VV1->VV1_MODVEI
		VC3->VC3_CHASSI := VV1->VV1_CHASSI
		VC3->VC3_FABMOD := VV1->VV1_FABMOD
		VC3->VC3_QTDFRO := 1
		VC3->VC3_AQUNOS := "1"
		VC3->VC3_DATAQU := dDataBase
		VC3->VC3_PROVEI := strzero(val(VV1->VV1_PROVEI)-1,1)
		VC3->VC3_TIPO   := IIf(VV1->VV1_GRASEV<>"6","1","0") // 1=Veiculo/Maquina / 0=Equipamento/AMS / 2=Outros
		VC3->VC3_VALMER := VVA->VVA_VALMOV
		VC3->VC3_VALAQU := VVA->VVA_VALMOV
		MsUnLock()
	ElseIf cTp == "C" // Cancelamento do Atendimento - Excluir VC3
		DbSelectArea("VC3")
		DbSetOrder(1) // VC3_FILIAL+VC3_CODCLI+VC3_LOJA+VC3_CODMAR+VC3_MODVEI+VC3_CHASSI
		If DbSeek( xFilial("VC3") + VV9->VV9_CODCLI + VV9->VV9_LOJA + VV1->VV1_CODMAR + VV1->VV1_MODVEI + VV1->VV1_CHASSI )
			RecLock("VC3",.f.,.t.)
			dbDelete()
			MsUnLock()
		EndIf
	EndIf
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002ACOLS º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Copia o conteudo da variavel de memoria para aCols         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cCampo = Nome da Variavel de Memória                       º±±
±±º          ³ nPosGetD = Posicao da GetDados                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002ACOLS( cCampo , nPosGetD , lConout)
Local nAuxPos
Default nPosGetD := oGetDadVVA:nAt
Default lConout := lDebug

// Atualiza aCols do Veiculo
nAuxPos := FG_POSVAR(cCampo,"oGetDadVVA:aHeader")
If nAuxPos > 0
	oGetDadVVA:aCols[nPosGetD, nAuxPos] := &('M->' + cCampo)
EndIf

If lConout
	VX002CONOUT("VX002ACOLS" , cCampo + " - " + cValToChar(&('M->' + cCampo)) )
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002DIC   º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Carrega dicionario (SX3) e dados das tabelas               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002DIC(nOpc)

Local nCntFor
Local nPos
Local nAuxValVei
Local aTotVZ7
Local nAuxColuna
Local nBkpN := N
Local aUltMov := {}
Local ni      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria para a VV9 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV9")
dbSetOrder(1)
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV9")
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "VX002NME" parametro "VV9" utilizado para manipular as variaveis: ³
//³ - cVV9NEdit (campos nao editaveis na Enchoice do VV9)             ³
//³ - cVV9NMostra (campos que nao serao mostrados na Enchoice do VV9) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VX002NME")
	ExecBlock("VX002NME",.f.,.f.,{"VV9"})
EndIf
//
While !Eof().and.(SX3->X3_ARQUIVO=="VV9")
	If X3USO(SX3->X3_USADO).and.cNivel>=SX3->X3_NIVEL .and. !(Alltrim(SX3->X3_CAMPO)+"," $ cVV9NMostra)
		AADD(aCpoVV9,SX3->X3_CAMPO)
	EndIf
	If Inclui .and. Alltrim(SX3->X3_CAMPO) != "VV9_NUMATE"
		&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
	Else
		If SX3->X3_CONTEXT == "V"
			&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
		Else
			&("M->"+SX3->X3_CAMPO):= &("VV9->"+SX3->X3_CAMPO)
		EndIf
	EndIf
	If (SX3->X3_CONTEXT != "V") .or. (SX3->X3_CONTEXT == "V" .and. SX3->X3_VISUAL == "A")
		If SX3->X3_PROPRI == "U" .or. (!(Alltrim(SX3->X3_CAMPO)+"," $ cVV9NEdit) .and. !(Alltrim(SX3->X3_CAMPO)+"," $ cVV9NMostra))
			aAdd(aCpoVV9Alt,SX3->X3_CAMPO)
		EndIf
	EndIf
	DbSkip()
Enddo
//
If INCLUI
	M->VV9_NUMATE := ""
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Variaveis de Memoria para a VV0 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VV0")
dbSetOrder(1)
dbSeek(xFilial("VV0")+VV9->VV9_NUMATE)
nRegVV0 := VV0->(Recno())
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VV0")
//
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ "VX002NME" parametro "VV0" utilizado para manipular as variaveis: ³
//³ - cVV0NEdit (campos nao editaveis na Enchoice do VV0)             ³
//³ - cVV0NMostra (campos que nao serao mostrados na Enchoice do VV0) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("VX002NME")
	ExecBlock("VX002NME",.f.,.f.,{"VV0"})
EndIf
//
While !Eof().and.(SX3->X3_ARQUIVO=="VV0")
	If X3USO(SX3->X3_USADO).and.cNivel>=SX3->X3_NIVEL .and. !(Alltrim(SX3->X3_CAMPO)+"," $ cVV0NMostra)
		AADD(aCpoVV0,SX3->X3_CAMPO)
	EndIf
	If Inclui
		// Inicializa a Forma de Pagamento
		Do Case
			Case Alltrim(SX3->X3_CAMPO) == "VV0_FORPAG"
				M->VV0_FORPAG := RetCondVei()
			Case AllTrim(SX3->X3_CAMPO) == "VV0_DESFPG"
				M->VV0_DESFPG := POSICIONE("SE4",1,xFilial("SE4")+M->VV0_FORPAG,"E4_DESCRI")
			Case Alltrim(SX3->X3_CAMPO) != "VV0_NUMTRA"
				&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
			Case Alltrim(SX3->X3_CAMPO) == "VV0_NUMTRA"
				&("M->"+SX3->X3_CAMPO):= Space(SX3->X3_TAMANHO)
		EndCase
	Else
		If SX3->X3_CONTEXT == "V"
			&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
		Else
			&("M->"+SX3->X3_CAMPO):= &("VV0->"+SX3->X3_CAMPO)
		EndIf
	EndIf
	If (SX3->X3_CONTEXT != "V") .or. (SX3->X3_CONTEXT == "V" .and. SX3->X3_VISUAL != "V" )
		If SX3->X3_PROPRI == "U"
			aAdd(aCpoVV0Alt,SX3->X3_CAMPO)
		Else
			If !(Alltrim(SX3->X3_CAMPO)+"," $ cVV0NMostra)
				If cVV9Status $ "P,O,L" // Pendente Aprovacao, Pre-Aprovado ou Aprovado
					If (Alltrim(SX3->X3_CAMPO)+"," $ cCpoVV0Alt)
						aAdd(aCpoVV0Alt,SX3->X3_CAMPO)
					EndIf
				Else
					If !(Alltrim(SX3->X3_CAMPO)+"," $ cVV0NEdit)
						aAdd(aCpoVV0Alt,SX3->X3_CAMPO)
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	DbSkip()
Enddo
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria Variaveis de Memoria para a VVA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VVA")
dbSetOrder(1)
dbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
nRegVVA := VVA->(Recno())
//
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VVA")
//
While !Eof().and.(SX3->X3_ARQUIVO=="VVA")
	If X3USO(SX3->X3_USADO).and.cNivel>=SX3->X3_NIVEL .and. !(Alltrim(SX3->X3_CAMPO)+"," $ cVVANMostra)
		AADD(aCpoVVA,SX3->X3_CAMPO)
		AADD(aHeaderVVA, {	AllTrim(X3Titulo()),	SX3->X3_CAMPO,		SX3->X3_PICTURE,	SX3->X3_TAMANHO,;
							SX3->X3_DECIMAL,		SX3->X3_VALID,		SX3->X3_USADO,		SX3->X3_TIPO,;
							SX3->X3_F3,				SX3->X3_CONTEXT,	X3CBOX(),			SX3->X3_RELACAO })
	EndIf
	If Inclui
		If Alltrim(SX3->X3_CAMPO) != "VVA_NUMTRA"
			&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
		ElseIf Alltrim(SX3->X3_CAMPO) == "VVA_NUMTRA"
			&("M->"+SX3->X3_CAMPO):= Space(SX3->X3_TAMANHO)
		EndIf
	Else
		If SX3->X3_CONTEXT == "V"
			&("M->"+SX3->X3_CAMPO):= CriaVar(SX3->X3_CAMPO)
		Else
			&("M->"+SX3->X3_CAMPO):= &("VVA->"+SX3->X3_CAMPO)
		EndIf
	EndIf
	If (SX3->X3_CONTEXT != "V") .or. (SX3->X3_CONTEXT == "V" .and. SX3->X3_VISUAL == "A")
		If SX3->X3_PROPRI == "U" .or. (!(Alltrim(SX3->X3_CAMPO)+"," $ cVVANEdit) .and. !(Alltrim(SX3->X3_CAMPO)+"," $ cVVANMostra))
			aAdd(aCpoVVAAlt,SX3->X3_CAMPO)
		EndIf
	EndIf
	DbSkip()
Enddo

ADHeadRec("VVA",aHeaderVVA)

dbSelectArea("VVA")
dbSetOrder(1)
dbSeek( xFilial("VVA") + M->VV9_NUMATE )
While !INCLUI .and. !VVA->(Eof()) .And. VVA->VVA_FILIAL == xFilial("VVA") .And. VVA->VVA_NUMTRA == M->VV9_NUMATE
	AADD(aColsVVA,Array(Len(aHeaderVVA)+1))
	For nCntFor := 1 to Len(aHeaderVVA)
		If IsHeadRec(aHeaderVVA[nCntFor,2])
			aColsVVA[Len(aColsVVA),nCntFor] := VVA->(RecNo())
			nVVARECNO := nCntFor
		ElseIf IsHeadAlias(aHeaderVVA[nCntFor,2])
			aColsVVA[Len(aColsVVA),nCntFor] := "VVA"
		Else
			aColsVVA[Len(aColsVVA),nCntFor] := IIf(aHeaderVVA[nCntFor,10] # "V",FieldGet(ColumnPos(aHeaderVVA[nCntFor,2])),CriaVar(aHeaderVVA[nCntFor,2]))
		EndIf
	Next
	aColsVVA[Len(aColsVVA),Len(aHeaderVVA)+1]:=.F.
	dbSelectArea("VVA")
	dbSkip()
EndDo

If Len( aColsVVA ) == 0
	//If ! lXX002Auto
		aColsVVA:={Array(Len(aHeaderVVA)+1)}
		aColsVVA[1,Len(aHeaderVVA)+1]:=.F.
		For nCntFor := 1 to Len(aHeaderVVA)
			If IsHeadRec(aHeaderVVA[nCntFor,2])
				aColsVVA[Len(aColsVVA),nCntFor] := 0
				nVVARECNO := nCntFor
			ElseIf IsHeadAlias(aHeaderVVA[nCntFor,2])
				aColsVVA[Len(aColsVVA),nCntFor] := "VVA"
			Else
				aColsVVA[1,nCntFor]:=CriaVar(aHeaderVVA[nCntFor,2],.t.)
			EndIf
		Next
	//Else
	//	For nCntFor := 1 to Len(aHeaderVVA)
	//		If IsHeadRec(aHeaderVVA[nCntFor,2])
	//			nVVARECNO := nCntFor
	//		EndIf
	//	Next
	//EndIf
EndIf

If nVerAten == 3 .and. ! lXX002Auto // Versao 3 ( Atendimento N veiculos )
	nAuxColuna := FG_POSVAR("VVA_ITETRA","aHeaderVVA")
	aSort( aColsVVA,,,{ |x,y| x[nAuxColuna] < y[nAuxColuna] } )
Endif

// Compatibilizacao com a Versao 2 (sem rodar update do atendimento com N Veiculos )
If !INCLUI .and. VVA->(ColumnPos("VVA_VALTAB")) <= 0
	M->VVA_VALTAB := M->VV0_VALTAB
EndIf
//

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o FISCAL quando NAO é INCLUSAO              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !INCLUI

	If !Empty(M->VV9_CODCLI) .and. !Empty(M->VV9_LOJA)
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1") + M->VV9_CODCLI + M->VV9_LOJA))
		VX002INIFIS(SA1->A1_COD,SA1->A1_LOJA)
	Else
		SA1->(dbSetOrder(1))
		SA1->(dbSeek(xFilial("SA1") + cCliPadrao + cLojPadrao))
		VX002INIFIS(cCliPadrao,cLojPadrao)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Financiamento/Leasing   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aParFin[01]   					// Valor do Financiamento/Leasing
	If ( cCliPadrao + cLojPadrao ) <> ( M->VV9_CODCLI + M->VV9_LOJA ) .and. !Empty( M->VV9_CODCLI + M->VV9_LOJA )
		aParFin[02] := SA1->A1_COD		// Codigo do Cliente
		aParFin[03] := SA1->A1_LOJA		// Loja do Cliente
		aParFin[04] := SA1->A1_PESSOA	// Tipo de Pessoa
	EndIf
	aParFin[05] := M->VVA_CHAINT		// Chassi Interno do Veiculo
	//aParFin[06]   					// Estado do Veiculo (Novo/Usado)
	//aParFin[07]   					// Grupo do Modelo
	//aParFin[08]   					// Modelo do Veiculo
	aParFin[09] := M->VV0_CODBCO		// Taxa do Dia - Banco FI
	aParFin[10] := M->VV0_TABFAI		// Taxa do Dia - Tabela FI
	//aParFin[11]   					// Taxa do Dia - Tipo da Tabela FI
	aParFin[12] := M->VV9_NUMATE		// Nro do Atendimento
	//aParFin[13]   					// VAS->(RecNo())
	//aParFin[14]   					// VAR->(RecNo())

	nAuxValVei := 0

	For nCntFor := 1 to Len(aColsVVA)

		//oGetDadVVA:nAt := nCntFor
		FG_MEMVAR( aHeaderVVA , aColsVVA, nCntFor )

		nAuxValVei += M->VVA_VALVDA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega campos virtuais da VV0 com conteudo da VVA ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		VX002RPLOAD(,.f.)

		N := nCntFor
		VX0020063_FiscalAdProduto( nCntFor , M->VVA_VALTAB , M->VVA_CODTES , SB1->B1_COD )

		For nPos := 1 to Len(aFisVVA)
			If ( nOpc <> 3 .and. nOpc <> 4 ) // Nao eh 'Incluir' e 'Alterar'
				If !(Alltrim(aFisVVA[nPos,3]) $ "IT_PRODUTO.IT_QUANT.IT_TES.IT_PRCUNI.IT_VALMERC.IT_DIFAL") // Campos que precisam ser recalculados, nao utilizar o gravado na base
					MaFisRef(aFisVVA[nPos,3],"VX001",&("M->"+aFisVVA[nPos,2]))
				EndIf
			Else
				If !(Alltrim(aFisVVA[nPos,3]) $ "IT_PRODUTO.IT_QUANT.IT_TES.IT_PRCUNI.IT_VALMERC.IT_BASEICM.IT_ALIQICM.IT_TOTAL.IT_VALICM.IT_VALISS.IT_VALPS3.IT_VALCF3.IT_VALIRR.IT_ALIQIPI.IT_VALSOL.IT_BASESOL.IT_VALPS2.IT_VALCF2.IT_VALCMP.IT_DIFAL") // Campos que precisam ser recalculados, nao utilizar o gravado na base
					MaFisRef(aFisVVA[nPos,3],"VX001",&("M->"+aFisVVA[nPos,2]))
				EndIf
			EndIf
		Next nPos

		// Atualiza valor do veiculo + venda agregada
		aTotVZ7	:= VX003TOTAL(M->VV9_NUMATE, M->VVA_ITETRA )
		If (M->VVA_VALMOV + aTotVZ7[1]) <> MaFisRet(,"IT_VALMERC")
			MaFisRef("IT_PRCUNI","VX001",M->VVA_VALVDA)
			MaFisRef("IT_VALMERC","VX001",M->VVA_VALVDA+aTotVZ7[1])
		EndIf
		If M->VV0_TIPFAT == "1" // Veiculo Usado
			aUltMov := FM_VEIMOVS( aColsVVA[ nCntFor , FG_POSVAR("VVA_CHASSI","aHeaderVVA") ] , "E"  )
			For ni := 1 to Len(aUltMov)
				If aUltMov[ni,5] == "0" // Entrada por Compra
					VVF->(DbSetOrder(1))
				If VVF->(MsSeek(aUltMov[ni,2]+aUltMov[ni,3]))
					SD1->(DbSetOrder(1))
					cProdSB1 := MaFisRet(n,"IT_PRODUTO")
					If SD1->(MsSeek(VVF->VVF_FILIAL+VVF->VVF_NUMNFI+VVF->VVF_SERNFI+VVF->VVF_CODFOR+VVF->VVF_LOJA+cProdSB1))
						MaFisRef("IT_NFORI","VX001",SD1->D1_DOC)
						MaFisRef("IT_SERORI","VX001",SD1->D1_SERIE)
						MaFisRef("IT_BASVEIC","VX001",SD1->D1_TOTAL)
						Endif
				EndIf
						Exit
				Endif
			Next
		Endif
		VX002ATFIS(.t.,.f.,nCntFor) // Atualiza M-> que possuem relacao com o FISCAL

		AADD(aParFin[15],{ "" , "" , "" , "" , "" } )
		aParFin[15,nCntFor,01] := M->VVA_CHAINT // Chassi Interno (CHAINT)
		If !Empty(M->VVA_CODMAR)
			aParFin[15,nCntFor,02] := M->VVA_ESTVEI // Estado do Veiculo (0=Novo/1=Usado)
			aParFin[15,nCntFor,03] := M->VVA_GRUMOD // Grupo do Modelo
			aParFin[15,nCntFor,04] := M->VVA_MODVEI // Modelo do Veiculo
			aParFin[15,nCntFor,05] := M->VVA_CODMAR // Marca do Veiculo
		Else
			aParFin[15,nCntFor,02] := ""            // Estado do Veiculo (0=Novo/1=Usado)
			aParFin[15,nCntFor,03] := M->VV0_GRUMOD // Grupo do Modelo
			aParFin[15,nCntFor,04] := M->VV0_MODVEI // Modelo do Veiculo
			aParFin[15,nCntFor,05] := M->VV0_CODMAR // Marca do Veiculo
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Minimo Comercial        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nCntFor > Len(aMinCom)
			AADD( aMinCom , aClone(aStruMCom) )
		EndIf
		aMinCom[nCntFor,01] := M->VVA_CHAINT	// Chassi Interno do Veiculo
		If !Empty(M->VVA_CODMAR)
			FGX_VV2(M->VVA_CODMAR, M->VVA_MODVEI, IIf( lVVASEGMOD , M->VVA_SEGMOD , "" ) )
			aMinCom[nCntFor,02] := M->VVA_CODMAR	// Marca do Veiculo
			aMinCom[nCntFor,03] := M->VVA_MODVEI	// Modelo do Veiculo
			aMinCom[nCntFor,04] := VV2->VV2_SEGMOD	// Segmento do Modelo
			aMinCom[nCntFor,05] := M->VVA_CORVEI	// Cor do Veiculo
		Else
			FGX_VV2(M->VV0_CODMAR, M->VV0_MODVEI, IIF( lVVASEGMOD , M->VV0_SEGMOD , "" ) )
			aMinCom[nCntFor,02] := M->VV0_CODMAR	// Marca do Veiculo
			aMinCom[nCntFor,03] := M->VV0_MODVEI	// Modelo do Veiculo
			aMinCom[nCntFor,04] := VV2->VV2_SEGMOD	// Segmento do Modelo
			aMinCom[nCntFor,05] := M->VV0_CORVEI	// Cor do Veiculo
		EndIf
		aMinCom[nCntFor,06] := M->VVA_VALTAB	// Valor da Negociacao do Veiculo
		//aMinCom[nCntFor,07] 					// Valor Sugerido Venda
		//aMinCom[nCntFor,08] 					// % de Valor de Venda do Minimo Comercial
		//aMinCom[nCntFor,09] 					// % do Resultado na Negociacao
		//aMinCom[nCntFor,10] 					// % do Resultado Minimo Comercial permitido

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Acoes de Venda          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD( aParVZ7 , aClone( aStruVZ7 ) )
		aParVZ7[nCntFor,01] := M->VV9_NUMATE			// Nro do Atendimento
		aParVZ7[nCntFor,02] := M->VVA_CHAINT			// Chassi Interno do Veiculo
		If Empty(M->VVA_CHAINT)
			If !Empty(M->VVA_CODMAR)
				aParVZ7[nCntFor,03] := M->VVA_CODMAR	// Marca
				aParVZ7[nCntFor,04] := M->VVA_MODVEI	// Modelo
				aParVZ7[nCntFor,05] := M->VVA_GRUMOD	// Grupo do Modelo
			Else
				aParVZ7[nCntFor,03] := M->VV0_CODMAR	// Marca
				aParVZ7[nCntFor,04] := M->VV0_MODVEI	// Modelo
				aParVZ7[nCntFor,05] := M->VV0_GRUMOD	// Grupo do Modelo
			EndIf
			aParVZ7[nCntFor,07] := "0" 					// ESTVEI (Novo/Usado)
		EndIf
		aParVZ7[nCntFor,10] := M->VVA_ITETRA			// Numero do Item no Atendimento

	Next nCntFor

	If Len(aColsVVA) > 1
	    FG_MEMVAR( aHeaderVVA , aColsVVA, 1 ) // Posicionar na 1a.linha
	    VX002RPLOAD(,.f.) // Carregar os M-> correspondente a 1a.linha
	EndIf

	If M->VV0_DESACE <> MaFisRet(,"NF_DESPESA")
		MaFisRef("NF_DESPESA","VX001",M->VV0_DESACE)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula valores de Acoes de Venda    ³
	//³ para subtrair no valor do veiculo    ³
	//³ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
	//³ aTotVZ7[1] SOMA NO TOTAL ATENDIMENTO ³
	//³ aTotVZ7[2] TROCO                     ³
	//³ aTotVZ7[3] CORTESIA                  ³
	//³ aTotVZ7[4] REDUTOR                   ³
	//³ aTotVZ7[5] VENDA AGREGADA            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aTotVZ7	 := VX003TOTAL(M->VV9_NUMATE,"")
	nVlVeicu := ( M->VV0_VALMOV - aTotVZ7[1] )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Valor do Atendimento    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nVlAtend := M->VV0_VALTOT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Financiamento Proprio   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParPro[01] := M->VV9_NUMATE		// Nro do Atendimento
	aParPro[02] := M->VV0_VALFPR		// Valor do Financiamento Proprio
	aParPro[03] := M->VV0_DTIFPR		// Data Inicial
	aParPro[04] := M->VV0_D1PFPR		// Dias para 1a.Parcela
	aParPro[05] := M->VV0_PARFPR		// Qtde de Parcelas
	aParPro[06] := M->VV0_INTFPR		// Intervalo entre as parcelas
	aParPro[07] := M->VV0_FIXFPR		// Fixa Dia
	aParPro[08] := M->VV0_DIAFPR		// Dia Fixo
	aParPro[09] := M->VV0_JURFPR		// Juros Mensal
	If ( VV0->(ColumnPos("VV0_MESFPR")) > 0 )
		aParPro[10] := M->VV0_MESFPR	// Meses a considerar
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Finame                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParFna[01] := M->VV9_NUMATE		// Nro do Atendimento

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Veiculo Usado na Troca  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParUsa[01] := M->VV9_NUMATE		// Nro do Atendimento

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consorcio               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParCon[01] := M->VV9_NUMATE		// Nro do Atendimento

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Entradas                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParEnt[01] := M->VV9_NUMATE		// Nro do Atendimento

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcionais do Veiculo    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aParOpc[01] := M->VVA_CHAINT		// Chassi Interno do Veiculo
	aParOpc[02] := M->VV0_CODMAR		// Marca do Veiculo
	aParOpc[03] := M->VV0_MODVEI		// Modelo do Veiculo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Entrega do Veiculo      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aEntrVei[01] := M->VV9_NUMATE		// Nro do Atendimento
	aEntrVei[02] := M->VVA_CHAINT		// Chassi Interno do Veiculo
	aEntrVei[05] := M->VVA_DTESUG		// Data de Entrega sugerida pelo Sistema
	aEntrVei[06] := M->VVA_DTEPRV		// Data de Entrega prevista pelo Usuario
	If VVA->(ColumnPos("VVA_HREPRV")) > 0
		aEntrVei[09] := M->VVA_HREPRV	// Hora de Entrega prevista pelo Usuario
		aEntrVei[10] := M->VVA_FIEPRV	// Filial de Entrega prevista pelo Usuario
		aEntrVei[11] := M->VVA_BOEPRV	// Box de Entrega prevista pelo Usuario
		aEntrVei[12] := M->VVA_USEPRV	// Usuario de Entrega prevista pelo Usuario
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega valor atual para gerar Log de Alteracao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lLogAlter
		// Carrega conteudo atual da VV0
		For nPos := 1 to Len(aLogAlter[1])
			AADD( aVLogAlter[1] , &("M->"+aLogAlter[1,nPos]) )
		Next nPos

		// Carrega conteudo atual da VVA
		For nCntFor := 1 to Len(aColsVVA)
			AADD( aVLogAlter[2] , Array(Len(aLogAlter[2])+1) )
			VVA->(dbGoTo(aColsVVA[nCntFor,nVVARECNO]))
			aVLogAlter[2,Len(aVLogAlter[2]),(Len(aLogAlter[2])+1)] := &("VVA->("+cVVAChvLog+")")
			For nPos := 1 to Len(aLogAlter[2])
				nAuxColuna := FG_POSVAR(aLogAlter[2,nPos],"aHeaderVVA")
				If nAuxColuna <> 0
					aVLogAlter[2,Len(aVLogAlter[2]),nPos] := aColsVVA[nCntFor,nAuxColuna]
				EndIf
			Next nPos
		Next nCntFor
	EndIf

EndIf

N := nBkpN

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002FOTO  º Autor ³ Andre Luis Almeira º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Exibe Fotos de um veículo                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nOpc                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002FOTO(nOpc)

SetKey(VK_F4, Nil )
SetKey(VK_F7, Nil )
SetKey(VK_F10, Nil )

If !Empty(M->VVA_CODMAR)
	VEIXC003(M->VVA_CHAINT,M->VVA_CODMAR,M->VVA_MODVEI)
ElseIf !Empty(M->VV0_CODMAR)
	VEIXC003(M->VVA_CHAINT,M->VV0_CODMAR,M->VV0_MODVEI)
EndIf

SetKey(VK_F4,{|| VX002FOTO(nOpc) })
SetKey(VK_F7,{|| VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,,.t.) })
SetKey(VK_F10,{|| VX002OPCOES(nOpc) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002ITEM  º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Gera o proximo numero de item do atendimento               º±±
±±º          ³ Utilizado para atendimento com N veiculos                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002ITEM()

Local cProxSeq := ""
Local nCntFor
Local nPos := FG_POSVAR("VVA_ITETRA","oGetDadVVA:aHeader")

If VVA->(ColumnPos("VVA_ITETRA")) > 0

	cProxSeq := FM_SQL("SELECT MAX(VVA_ITETRA) FROM " + RetSQLName("VVA") + " VVA WHERE VVA_FILIAL = '" + xFilial("VVA") + "' AND VVA_NUMTRA = '" + M->VV9_NUMATE + "'")
	If !Empty(cProxSeq)
		cProxSeq := Soma1(cProxSeq)
	Else
		cProxSeq := StrZero(1,TamSX3("VVA_ITETRA")[1])
	EndIf

	While .t.
		If aScan( oGetDadVVA:aCols , { |x| x[nPos] == cProxSeq } ) <= 0
			Exit
		EndIf
		cProxSeq := Soma1(cProxSeq)
	EndDo
EndIf

Return cProxSeq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002MAPAV º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Roda Mapa de Avaliacao e Atualiza o Semaforo do atendimentoº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002MAPAV()

Local aRetMapa := {2,0,{}}
Local nCntFor  := 0
Local nAuxPos  := 0

aRetMapa := FM_MAPAVAL(1,,M->VV9_NUMATE,.f.,0,,)

If ! lXX002Auto
	oMapaBom:lVisible := ( aRetMapa[1] ==  1 ) // Bom
	oMapaMed:lVisible := ( aRetMapa[1] ==  0 ) // Medio
	oMapaRui:lVisible := ( aRetMapa[1] == -1 ) // Ruim
EndIf

For nCntFor := 1 to Len(aRetMapa[3])
	nAuxPos := aScan(oGetDadVVA:aCols, {|x| x[nVVARECNO] == aRetMapa[3,nCntFor,1] } )
    If nAuxPos > 0
	    aMinCom[nAuxPos,9] := aRetMapa[3,nCntFor,2] // % de Resultado
	EndIf
Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002DEL   º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Deleta registros de tabelas auxiliares referente a um      º±±
±±º          ³ veiculo que foi removido do atendimento                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nPosGetD = Posicao da GetDados                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002DEL(nPosGetD, nTipo, nOpc)

Default nPosGetD := oGetDadVVA:nAt

If nTipo >= 1
	If M->VV0_OPEMOV == "0" .and. !Empty(oGetDadVVA:aCols[nPosGetD,FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")])
		// Cancela reserva de veiculo
		VEIXX004(nOpc,M->VV9_NUMATE,oGetDadVVA:aCols[nPosGetD,FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")],"0",IIf(VVA->(ColumnPos("VVA_ITETRA"))>0,oGetDadVVA:aCols[nPosGetD,FG_POSVAR("VVA_ITETRA","oGetDadVVA:aHeader")],"")) // Reserva ( Cancela Reserva do Veiculo )
	EndIf
	// Delecao do Bonus
	VEIVA640DEL(M->VV9_NUMATE,oGetDadVVA:aCols[nPosGetD,nVVARECNO])
	// Delecao do Custo com Venda
	VEIVA680DEL(M->VV9_NUMATE,oGetDadVVA:aCols[nPosGetD,FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")])
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VX002FOK  º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ FieldOK da GetDados de veiculos quando utilizado atendim.  º±±
±±º          ³ com N veiculos                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cReadVar = ReadVar()                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002FOK( nOpc , cReadVar )
Local lRet := .t.
Local cTES := ""
Default cReadVar := ReadVar()

If cReadVar == "M->VVA_VALTAB"
	__ReadVar := "xxxxxxxxxx"
//	If !VX002VALVEI( nOpc, .t. , M->VVA_VALTAB , .t. , oGetDadVVA:nAt )
	If !VX002VALVEI( nOpc, .t. , M->VVA_VALTAB , ! lXX002Auto , oGetDadVVA:nAt )
		lRet := .f.
	Else
		nVlVeicu := 0
		aEval( oGetDadVVA:aCols , { |x| nVlVeicu += IIf( !x[Len(x)] , x[FG_POSVAR("VVA_VALTAB","oGetDadVVA:aHeader")] , 0 ) } )
		VX002ATTELA(M->VV9_NUMATE)
	EndIf
	__ReadVar := "M->VVA_VALTAB"
EndIf

If cReadVar == "M->VVA_OPER"
	cTES := MaTesInt(2,M->VVA_OPER,M->VV9_CODCLI,M->VV9_LOJA,"C",SB1->B1_COD)
	If !Empty(cTES)
		If FGX_GDVALID("VVA_CODTES",cTES,"oGetDadVVA") // Disparar VALID, VALIDUSER, atualiza M-> e aCols
			VX002FOK( nOpc , "M->VVA_CODTES" )
		Else
			lRet := .f.
		EndIf
	EndIf
EndIf

If cReadVar == "M->VVA_CODTES"
	VX002ATFIS( .T. , .T. , oGetDadVVA:nAt )
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002CHANG º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza variaveis de memoria quando alterada a linha da   º±±
±±º          ³ GetDados de veiculos                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002CHANG()

FG_MEMVAR( oGetDadVVA:aHeader , oGetDadVVA:aCols , oGetDadVVA:nAt)

N := oGetDadVVA:nAt

aParOpc[01]  := M->VVA_CHAINT		// Chassi Interno do Veiculo
aParOpc[02]  := M->VVA_CODMAR		// Marca do Veiculo
aParOpc[03]  := M->VVA_MODVEI		// Modelo do Veiculo

aEntrVei[02] := M->VVA_CHAINT		// Chassi Interno do Veiculo
aEntrVei[03] := M->VVA_CODMAR		// Marca do Veiculo
aEntrVei[04] := M->VVA_MODVEI		// Modelo do Veiculo
aEntrVei[05] := M->VVA_DTESUG		// Data de Entrega sugerida pelo Sistema
aEntrVei[06] := M->VVA_DTEPRV		// Data de Entrega prevista pelo Usuario
aEntrVei[08] := oGetDadVVA:aCols[oGetDadVVA:nAt,nVVARECNO]	// RecNO do VVA
If VVA->(ColumnPos("VVA_HREPRV")) > 0
	aEntrVei[09] := M->VVA_HREPRV	// Hora de Entrega prevista pelo Usuario
	aEntrVei[10] := M->VVA_FIEPRV	// Filial de Entrega prevista pelo Usuario
	aEntrVei[11] := M->VVA_BOEPRV	// Box de Entrega prevista pelo Usuario
	aEntrVei[12] := M->VVA_USEPRV	// Usuario de Entrega prevista pelo Usuario
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002DELAC º Autor ³ Rubens Takahashi   º Data ³ 28/06/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Deleta/Restaura uma linha da GetDados de veiculos          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002DELAC(nOpc,lMsg,lVldStat, lForcaExclusao)

Local cQuery      := ""
Local aVZ7        := {{},{}}
Local cAuxMsg     := ""
Local nQtde       := 0
Local aRetFiltro  := {}
Local nBkpN       := N
Local lItemDeletado := .f.
Local nlinValida  := 0

Default lMsg      := .t.
Default lVldStat  := .t.
Default lForcaExclusao := .f.

If lVldStat .and. cVV9Status <> "A"
	VX002ExibeHelp("VX002ERR015" , STR0145) // So e permitido a exclusão de Veiculo para Atendimento em Aberto. / Atencao
	Return .f.
EndIf

cAuxMsg := STR0143+": " + M->VVA_ITETRA + CHR(13) + CHR(10) + CHR(13) + CHR(10) // Item
If !Empty(M->VVA_CHASSI)
	cAuxMsg += UPPER(STR0119)+": " + AllTrim(M->VVA_CHASSI) + CHR(13) + CHR(10) // CHASSI
ElseIf !Empty(M->VVA_CHAINT)
	cAuxMsg += STR0146+": " + AllTrim(M->VVA_CHAINT) + CHR(13) + CHR(10) // CHAINT
EndIf
cAuxMsg += STR0147+": " + AllTrim(M->VVA_CODMAR) + " - " + AllTrim(oGetDadVVA:aCols[oGetDadVVA:nAt,FG_POSVAR("VVA_DESMAR","oGetDadVVA:aHeader")]) + CHR(13) + CHR(10)
cAuxMsg += STR0148+": " + AllTrim(M->VVA_MODVEI) + " - " + IIF( lVVASEGMOD , AllTrim(M->VVA_SEGMOD) + " - " , "" ) + AllTrim(oGetDadVVA:aCols[oGetDadVVA:nAt,FG_POSVAR("VVA_DESMOD","oGetDadVVA:aHeader")])

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ E X C L U I    O    V E I C U L O    S E L E C I O N A D O ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lItemDeletado := oGetDadVVA:aCols[oGetDadVVA:nAt,Len(oGetDadVVA:aCols[oGetDadVVA:nAt])]
If ! lItemDeletado .or. lForcaExclusao
	// Verificar se o usuário está tentando deletar o último veículo válido do atendimento
	aEval(oGetDadVVA:aCols, { |x| nlinValida += IIf(!x[Len(oGetDadVVA:aHeader) + 1], 1, 0) })

	If nlinValida <= 1
		If lMsg
			VX002ExibeHelp("VX002ERR025", STR0123) // Atendimento deve possuir pelo menos um veiculo!
		EndIf

		Return .f.
	EndIf

	If lMsg .and. !MsgYesNo(STR0149 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cAuxMsg ,STR0011) // Confirma a exclusao do Veiculo do Atendimento? / Atencao
		Return .f.
	EndIf

	//////////////////////////////////////
	// Limpar as Oportunides/Interesses //
	//////////////////////////////////////
	If ! lForcaExclusao
		cQuery := "SELECT R_E_C_N_O_ FROM "+RetSQLName("VDM")+" WHERE VDM_FILIAL='"+xFilial("VDM")+"' AND VDM_FILATE='"+xFilial("VV9")+"' AND VDM_NUMATE='"+M->VV9_NUMATE+"' AND VDM_ITETRA='"+M->VVA_ITETRA+"' AND D_E_L_E_T_=' '"
		nRecVDM := FM_SQL(cQuery)
	    If nRecVDM > 0
			If MsgYesNo(STR0155,STR0011) // Existe(m) Oportunidade(s)/Interesse(s) vinculado(s) com esse Item. Deseja apagar o relacionamento e voltar a(s) Oportunidade(s)/Interesse(s) para utilizacao futura? / Atencao
				While nRecVDM > 0 // Enquanto houver Oportunidade/Interesse vinculado
			        DbSelectArea("VDM")
					DbGoTo(nRecVDM)
					RecLock("VDM",.f.)
						VDM->VDM_FILATE := ""
						VDM->VDM_NUMATE := ""
						VDM->VDM_ITETRA := ""
					MsUnLock()
					nRecVDM := FM_SQL(cQuery) // verificar se existe outro vinculo
				EndDo
			EndIf
		EndIf
	EndIf

	// Levanta Venda Agregada do Veiculo
	VX002X3LOAD( "VZ7" , .t. , @aVZ7 )
	aHeaderVZ7 := aClone(aVZ7[1])
	aVZ7[2,1,1] := "DELALL"
	aVZ7[2,1,FG_POSVAR("VZ7_ITETRA","aHeaderVZ7")] := M->VVA_ITETRA
	aVZ7[2,1,len(aVZ7[1])+1] := .t.

	VX002DEL(oGetDadVVA:nAt, 1, nOpc)

	N := oGetDadVVA:nAt
	MaFisDel(oGetDadVVA:nAt,.t.)

	oGetDadVVA:aCols[oGetDadVVA:nAt,Len(oGetDadVVA:aCols[oGetDadVVA:nAt])] := .T.

	// Verifica como ficou o tipo do atendimento
	VX002TIPFAT( .f. , , , )

	// Limpar linha do vetor de Financiamento referente ao veiculo EXCLUIDO na aCols
	aParFin[15,oGetDadVVA:nAt,01] := "" // Chassi Interno (CHAINT)
	aParFin[15,oGetDadVVA:nAt,02] := "" // Estado do Veiculo (0=Novo/1=Usado)
	aParFin[15,oGetDadVVA:nAt,03] := "" // Grupo do Modelo
	aParFin[15,oGetDadVVA:nAt,04] := "" // Modelo do Veiculo
	aParFin[15,oGetDadVVA:nAt,05] := "" // Marca do Veiculo

	// Limpar linha do vetor de Minimo Comercial referente ao veiculo EXCLUIDO na aCols
	aMinCom[oGetDadVVA:nAt,01] := "" // Chassi Interno do Veiculo
	aMinCom[oGetDadVVA:nAt,02] := "" // Marca do Veiculo
	aMinCom[oGetDadVVA:nAt,03] := "" // Modelo do Veiculo
	aMinCom[oGetDadVVA:nAt,04] := "" // Segmento do Modelo
	aMinCom[oGetDadVVA:nAt,05] := "" // Cor do Veiculo
	aMinCom[oGetDadVVA:nAt,06] := 0  // Valor da Negociacao do Veiculo

	// Grava o Atendimento
	VX002GRV(nOpc,.f.,"VZ7",,,@aVZ7)

	If ! lXX002Auto
		oGetDadVVA:Refresh()
	EndIf

	FG_MEMVAR( oGetDadVVA:aHeader , oGetDadVVA:aCols , oGetDadVVA:nAt)

	nVlVeicu := 0
	aEval( oGetDadVVA:aCols , { |x| nVlVeicu += IIf( !x[Len(x)] , x[FG_POSVAR("VVA_VALTAB","oGetDadVVA:aHeader")] , 0 ) } )

	VX002ATFIS(.t.,.t.,oGetDadVVA:nAt)
	VX002ATTELA(M->VV9_NUMATE)

	// verifica se deve alterar alguma informacao do veiculo ...
	// checar reserva de veiculo na exclusao

	// Ponto de entrada para gravações customizadas do veículo excluído
	If ExistBlock("VXX02VEX")
		ExecBlock("VXX02VEX", .f., .f.)
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ R E S T A U R A    O    V E I C U L O    S E L E C I O N A D O ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else

	If M->VV0_TIPFAT <> "1" // Veiculo Novo
		If M->VVA_ESTVEI == "1"
			VX002ExibeHelp("VX002ERR016" , STR0124) // Impossivel restaurar o Veiculo Usado. Este Atendimento e de Veiculo Novo. / Atencao
			Return .f.
		EndIf
	Else // Veiculo Usado
		If M->VVA_ESTVEI == "0"
			VX002ExibeHelp("VX002ERR017" , STR0125) // Impossivel restaurar o Veiculo Novo. Este Atendimento e de Veiculo Usado. / Atencao
			Return .f.
		EndIf
	EndIf

	// Verificar se o CHAINT ja está no atendimento
	If !Empty(M->VVA_CHAINT) .and. aScan( oGetDadVVA:aCols , { |x| !x[Len(x)] .and. x[FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")] == M->VVA_CHAINT } ) <> 0
		VX002ExibeHelp("VX002ERR018" , STR0144) // Veiculo ja esta no Atendimento! / Atencao
		Return .f.
	EndIf
	//

	If lMsg .and. !MsgYesNo(STR0152 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cAuxMsg ,STR0011) // Deseja restaurar o Veiculo no Atendimento? / Atencao
		Return .f.
	EndIf

	// Validar quantidade maxima de veiculo no atendimento
	aEval( oGetDadVVA:aCols , { |x| nQtde += IIf( !x[Len(x)] , 1 , 0 ) } )
	If nAVEIMAX < ( nQtde + 1 )
		VX002ExibeHelp("VX002ERR019" , STR0153) // Impossivel restaurar o Veiculo selecionado. A quantidade maxima permitida por Atendimento foi atingida! / Atencao
		Return .f.
	Else
		// Validar se é possivel utilizar o veiculo (quanto possui chassi) VEIXX012
		If !Empty(M->VVA_CHASSI)
			If !VEIXX012(1,,M->VVA_CHAINT,,M->VV9_NUMATE) // Validacoes do Chassi
				Return .f.
			EndIf
		EndIf
	EndIf

	aRetFiltro := { VX002ADDRETFILTRO() }
	// Gerar uma matriz aRetFiltro com a mesma estrutura do retorno da funcao VEIXC001
	aRetFiltro[01,01] := M->VVA_CHAINT		// Chaint
	aRetFiltro[01,02] := M->VVA_ESTVEI		// Estado do Veiculo (Novo/Usado)
	aRetFiltro[01,03] := M->VVA_CODMAR		// Marca
	aRetFiltro[01,04] := M->VVA_GRUMOD		// Grupo do Modelo
	aRetFiltro[01,05] := M->VVA_MODVEI		// Modelo
	aRetFiltro[01,06] := M->VVA_CORVEI		// Cor
	aRetFiltro[01,07] := ""					// Codigo Progresso
	aRetFiltro[01,08] := "1" 				// Tipo (1-Normal)
	aRetFiltro[01,09] := M->VVA_VALTAB		// Valor do Veiculo
	If lVVASEGMOD
		aRetFiltro[01,10] := M->VVA_SEGMOD		// Segmento
	EndIf

	// Disparar VX002CONSV passando o aRetFiltro
	VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,aRetFiltro,lVldStat,oGetDadVVA:nAt)
	//

EndIf

N := nBkpN

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002VLVEIDº Autor ³ Andre Luis Almeida º Data ³ 10/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica se o veiculo selecionado esta deletado na GetDadosº±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002VLVEID(nOpc,lMsg)
Local lRet := .t.
If nOpc == 3 .or. nOpc == 4
	If oGetDadVVA:aCols[oGetDadVVA:nAt,Len(oGetDadVVA:aCols[oGetDadVVA:nAt])]
		If lMsg
			VX002ExibeHelp("VX002ERR20" , STR0014) // Veiculo selecionado esta deletado! / Atencao
		EndIf
		lRet := .f.
	EndIf
EndIf
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VX002TIPFATº Autor ³ Rubens Takahashi   º Data ³ 08/08/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Verifica/Acerta o Tipo de Faturamento do Atendimento       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VX002TIPFAT( lSelecao , cTipo , cTipFat , nPosGetD )
Default lSelecao := .f.
Default cTipo    := "0"
Default nPosGetD := oGetDadVVA:nAt

VX002CONOUT("VX002TIPFAT", cValToChar(lSelecao) + " - " + cTipo + " - " + cValToChar(cTipFat) )

If lSelecao // Selecao do Veiculo

	M->VVA_SIMVDA := "V" // V=Venda
	M->VV0_OPEMOV := "0" // 0=Venda
	M->VV0_VDAFUT := "0" // 0=Nao eh Venda Futura
	If cTipo == "1" // Venda Normal
		M->VV0_TIPFAT := cTipFat // 0=Novo / 1=Usado
	ElseIf cTipo == "3" // Venda Futura
		M->VV0_TIPFAT := "0" // 0=Novo
		M->VV0_VDAFUT := "1" // 1=Venda Futura
	Else // Simulacao
		M->VV0_TIPFAT := "0" // 0=Novo
		M->VV0_OPEMOV := "1" // 1=Simulacao
		M->VVA_SIMVDA := "S" // S=Simulacao
	EndIf
	VX002ACOLS("VVA_SIMVDA",nPosGetD)

Else // Verifica/Acerta o Tipo de Faturamento do Atendimento

	If nVerAten == 3 // Versao 3 ( Atendimento N veiculos )

		// Se encontrar um registro de simulacao, configura atendimento como simulacao
		If aScan(oGetDadVVA:aCols, { |x| !x[Len(x)] .and. x[FG_POSVAR("VVA_SIMVDA","oGetDadVVA:aHeader")] == "S" } ) <> 0
			M->VV0_TIPFAT := "0" 	// 0=Novo
			M->VV0_OPEMOV := "1" 	// 1=Simulacao
			M->VV0_SIMVDA := "S"	// S=Simulacao
			M->VV0_VDAFUT := "0"	// 0=Nao e' Venda Futura

		// Se encontrar um registro sem CHAINT configura uma VENDA FUTURA
		ElseIf aScan(oGetDadVVA:aCols, { |x| !x[Len(x)] .and. Empty(x[FG_POSVAR("VVA_CHAINT","oGetDadVVA:aHeader")]) } ) <> 0
			M->VV0_TIPFAT := "0" 	// 0=Novo
			M->VV0_OPEMOV := "0" 	// 0=Venda
			M->VV0_SIMVDA := "V"	// V=Venda
			M->VV0_VDAFUT := "1" 	// 1=Venda Futura

		// Senao configura uma venda normal
		Else
			M->VV0_TIPFAT := " "
			Do Case
				Case aScan(oGetDadVVA:aCols, { |x| !x[Len(x)] .and. x[FG_POSVAR("VVA_ESTVEI","oGetDadVVA:aHeader")] == "0" } ) <> 0
					M->VV0_TIPFAT := "0" 	// 0=Novo
				Case aScan(oGetDadVVA:aCols, { |x| !x[Len(x)] .and. x[FG_POSVAR("VVA_ESTVEI","oGetDadVVA:aHeader")] == "1" } ) <> 0
					M->VV0_TIPFAT := "1" 	// 1=Usado
				Case aScan(oGetDadVVA:aCols, { |x| x[FG_POSVAR("VVA_ESTVEI","oGetDadVVA:aHeader")] == "0" } ) <> 0
					M->VV0_TIPFAT := "0" 	// 0=Novo
				Case aScan(oGetDadVVA:aCols, { |x| x[FG_POSVAR("VVA_ESTVEI","oGetDadVVA:aHeader")] == "1" } ) <> 0
					M->VV0_TIPFAT := "1" 	// 1=Usado
			EndCase
			M->VV0_OPEMOV := "0"	// 0=Venda
			M->VV0_VDAFUT := "0"	// 0=Nao e' Venda Futura
			M->VV0_SIMVDA := "V"	// V=Venda

		EndIf

	EndIf

EndIf

VX002CONOUT("VX002TIPFAT", "M->VV0_TIPFAT" + " - " + M->VV0_TIPFAT )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXX002PRE ³ Autor ³ Andre Luis Almeida               ³ Data ³ 22/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pre Atendimento ( inclusao simplificada do VV9 / VV0 / VVA )           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXX002PRE()
Local aObjects   := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor    := 0
Local cCodVen    := ""
Local nRecVDG    := 0
Local lOk        := .f.
Local lCPagPad   := ( GetNewPar("MV_MIL0016","0") == "1" ) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim) - Chamado CI 001985
Local lVV0FPGPAD  := (VV0->(ColumnPos("VV0_FPGPAD")) > 0) //Utiliza no Atendimento de Veículos, Condição de Pagamento da mesma forma que no Faturamento Padrão do ERP? (0=Não / 1= Sim)
Local lTIPMOV    := ( VV0->(ColumnPos("VV0_TIPMOV")) > 0 ) // Tipo de Movimento ( Normal / Agregacao / Desagregacao )
Local lHORVIS    := ( VV9->(ColumnPos("VV9_HORVIS")) > 0 ) // Hora Visita
//
Private cVV9CCli := space(TamSx3("VV9_CODCLI")[1])
Private cVV9LCli := space(TamSx3("VV9_LOJA")[1])
Private cVV9NCli := space(TamSx3("VV9_NOMVIS")[1])
Private cVV9FCli := space(TamSx3("VV9_TELVIS")[1])
Private aVV9TMid := X3CBOXAVET("VV9_TIPMID","0")
Private cVV9TMid := aVV9TMid[1]
Private o_Azul   := LoadBitmap( GetResources() , "BR_AZUL" )
Private o_Amar   := LoadBitmap( GetResources() , "BR_AMARELO" )
Private o_Verd   := LoadBitmap( GetResources() , "BR_VERDE" )
Private aVerVend := {}
Private IncSalva := Inclui
// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 57, .T. , .F. } )  	//Label Superior
AAdd( aObjects, { 01, 10, .T. , .T. } )  	//list box
// Fator de reducao de 0.8
For nCntFor := 1 to Len(aSizeAut)
	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
Next
aInfo   := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)
/////////////////////////////////////////
// Levantamento Inicial dos Vendedores //
/////////////////////////////////////////
FS_VXX002P(0)
/////////////////////////////////////////
DbSelectArea("VV9")
DEFINE MSDIALOG oPreAtend TITLE STR0110 From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd STATUS PIXEL // Pre Atendimento
	@ aPosObj[1,1]+00,aPosObj[1,2]+01 TO aPosObj[1,3],aPosObj[1,4]-99 LABEL "" OF oPreAtend PIXEL
	@ aPosObj[1,1]+08,aPosObj[1,2]+12 SAY (STR0060+":") SIZE 30,10 OF oPreAtend PIXEL COLOR CLR_BLUE // Cliente
	@ aPosObj[1,1]+05,aPosObj[1,2]+49 MSGET oVV9CCli VAR cVV9CCli VALID FS_VXX002P(2) PICTURE "@!" F3 "SA1" SIZE 37,8 OF oPreAtend PIXEL COLOR CLR_BLUE HASBUTTON
	@ aPosObj[1,1]+05,aPosObj[1,2]+89 MSGET oVV9LCli VAR cVV9LCli VALID FS_VXX002P(3) PICTURE "@!" SIZE 15,8 OF oPreAtend PIXEL COLOR CLR_BLUE
	@ aPosObj[1,1]+20,aPosObj[1,2]+12 SAY (STR0111+":") SIZE 30,10 OF oPreAtend PIXEL COLOR CLR_BLUE // Nome
	@ aPosObj[1,1]+17,aPosObj[1,2]+49 MSGET oVV9NCli VAR cVV9NCli VALID FS_VXX002P(4) PICTURE "@!" SIZE 200,8 OF oPreAtend PIXEL COLOR CLR_BLUE
	@ aPosObj[1,1]+32,aPosObj[1,2]+12 SAY (STR0112+":") SIZE 30,10 OF oPreAtend PIXEL COLOR CLR_BLUE // Telefone
	@ aPosObj[1,1]+29,aPosObj[1,2]+49 MSGET oVV9FCli VAR cVV9FCli PICTURE "@!" SIZE 80,8 OF oPreAtend PIXEL COLOR CLR_BLUE
	@ aPosObj[1,1]+44,aPosObj[1,2]+12 SAY (STR0113+":") SIZE 30,10 OF oPreAtend PIXEL COLOR CLR_BLUE // Tipo Midia
	@ aPosObj[1,1]+41,aPosObj[1,2]+49 MSCOMBOBOX oVV9TMid VAR cVV9TMid SIZE 80,08 ITEMS aVV9TMid OF oPreAtend PIXEL COLOR CLR_BLUE
	@ aPosObj[2,1]+01,aPosObj[2,2]+02 LISTBOX oLbPreAte FIELDS HEADER "",STR0085,STR0114,STR0118,STR0001 COLSIZES 10,130,100,100,40 SIZE aPosObj[2,4]-4,aPosObj[2,3]-aPosObj[1,3]-5 OF oPreAtend PIXEL ON DBLCLICK FS_VXX002P(5)
	oLbPreAte:SetArray(aVerVend)
	oLbPreAte:bLine := { || { IIf(aVerVend[oLbPreAte:nAt,01]==1,o_Amar,IIf(aVerVend[oLbPreAte:nAt,01]==2,o_Azul,o_Verd)),;
	aVerVend[oLbPreAte:nAt,02]+" - "+aVerVend[oLbPreAte:nAt,03],;
	FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,04],"@D"),"E")+" "+FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,05],"@R 99:99")+"h","D"),;
	FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,06],"@D"),"E")+" "+FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,07],"@R 99:99")+"h","D"),;
	aVerVend[oLbPreAte:nAt,08] }}
	@ aPosObj[1,1]+05,aPosObj[1,4]-85 BITMAP oxVerm RESOURCE "BR_VERDE" OF oPreAtend NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[1,1]+05,aPosObj[1,4]-75 SAY STR0120 SIZE 80,10 OF oPreAtend PIXEL COLOR CLR_BLUE // Vendedor disponivel
	@ aPosObj[1,1]+15,aPosObj[1,4]-85 BITMAP oxVerd RESOURCE "BR_AMARELO" OF oPreAtend NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[1,1]+15,aPosObj[1,4]-75 SAY STR0121 SIZE 80,10 OF oPreAtend PIXEL COLOR CLR_BLUE // Vendedor selecionado
	@ aPosObj[1,1]+25,aPosObj[1,4]-85 BITMAP oxAzul RESOURCE "BR_AZUL" OF oPreAtend NOBORDER SIZE 10,10 when .f. PIXEL
	@ aPosObj[1,1]+25,aPosObj[1,4]-75 SAY STR0122 SIZE 80,10 OF oPreAtend PIXEL COLOR CLR_BLUE // Vendedor em Atendimento
	@ aPosObj[1,1]+41,aPosObj[1,4]-90 BUTTON oBotAtual PROMPT STR0115 OF oPreAtend SIZE 85,10 PIXEL ACTION FS_VXX002P(1) // Atualizar Lista de Vendedores
ACTIVATE MSDIALOG oPreAtend CENTER ON INIT EnchoiceBar(oPreAtend,{ || lOk := .t. , oPreAtend:End() }, { || oPreAtend:End() },,)
If lOk
	For nCntFor := 1 to len(aVerVend)
		If aVerVend[nCntFor,1] == 1
			cCodVen := aVerVend[nCntFor,2]
			nRecVDG := aVerVend[nCntFor,9] // RECNO VDG
		EndIf
	Next
	If !Empty(cCodVen) .and. !Empty(cVV9NCli) .and. !Empty(cVV9FCli)
		//
		Inclui := .t. // Utilizado no RELACAO ( RegToMemory ) do VV0 e VVA
        //
		DbSelectArea("VV9")
		RecLock("VV9",.t.)
			VV9->VV9_FILIAL := xFilial("VV9")
			VV9->VV9_NUMATE := GetSXENum("VV0","VV0_NUMTRA")
			VV9->VV9_DATVIS := dDataBase
			If lHORVIS
				VV9->VV9_HORVIS := val(left(time(),2)+substr(time(),4,2)) // Hora Visita
			EndIf
			VV9->VV9_STATUS := "A"
			VV9->VV9_NOMVIS := cVV9NCli
			VV9->VV9_CODCLI := cVV9CCli
			VV9->VV9_LOJA   := cVV9LCli
			VV9->VV9_TIPMID := cVV9TMid
			VV9->VV9_TELVIS := cVV9FCli
			VV9->VV9_VEND1  := cCodVen
			ConfirmSX8()
		MsUnLock()
		//
		DbSelectArea("VV0")
		RegToMemory("VV0",.t.,.t.,.t.)
		RecLock("VV0",.t.)
			FG_GRAVAR("VV0")
			VV0->VV0_FILIAL := xFilial("VV0")
			VV0->VV0_NUMTRA := VV9->VV9_NUMATE
			VV0->VV0_CODCLI := cVV9CCli
			VV0->VV0_LOJA   := cVV9LCli
			VV0->VV0_CODVEN := cCodVen
			If lCPagPad .or. (lVV0FPGPAD .and. VV0->VV0_FPGPAD == "1") // Padrão do ERP
				VV0->VV0_FORPAG := M->VV0_FORPAG
			Else
				VV0->VV0_FORPAG := RetCondVei()
			EndIf
			If lTIPMOV
				VV0->VV0_TIPMOV := "0" // 0 = Normal
			EndIf
		MsUnLock()
		//
		DbSelectArea("VVA")
		RegToMemory("VVA",.t.,.t.,.t.)
		RecLock("VVA",.t.)
			FG_GRAVAR("VVA")
			VVA->VVA_FILIAL := xFilial("VVA")
			VVA->VVA_NUMTRA := VV9->VV9_NUMATE
			If VVA->(ColumnPos("VVA_ITETRA")) > 0 // Atendimento N veiculos
				VVA->VVA_ITETRA := "01"
			EndIf
		MsUnLock()
		//
		Inclui := IncSalva // Volta variavel
		//
		DbSelectArea("VDG")
		If nRecVDG > 0 // Posiciona no VDG
			VDG->(DbGoTo(nRecVDG))
		EndIf
		If nRecVDG > 0 .and. Empty(VDG->VDG_NUMATE) // Verifica se esta preenchido o nro do Atendimento no VDG
			RecLock("VDG",.f.)
				VDG->VDG_NUMATE := VV9->VV9_NUMATE
			MsUnLock()
		Else // Cria registro no VDG
			RecLock("VDG",.t.)
				VDG->VDG_FILIAL := xFilial("VDG")
				VDG->VDG_CODVEN := cCodVen
				VDG->VDG_DATDIS := dDataBase
				VDG->VDG_HORDIS := val(substr(time(),1,2)+substr(time(),4,2))
				VDG->VDG_DATLIM := VDG->VDG_DATDIS
				VDG->VDG_HORLIM := VDG->VDG_HORDIS
				VDG->VDG_NUMATE := VV9->VV9_NUMATE
			MsUnLock()
		EndIf
		MsgInfo(STR0117+CHR(13)+CHR(10)+CHR(13)+CHR(10)+VV9->VV9_NUMATE+" - "+STR0085+": "+cCodVen,STR0011) // Pre Atendimento inserido com sucesso! / Vendedor / Atencao
	Else
		MsgStop(STR0116+CHR(13)+CHR(10)+CHR(13)+CHR(10)+STR0060+" / "+STR0112+" / "+STR0085,STR0011) // Favor preencher corretamente dos dados! / Cliente / Vendedor / Atencao
	EndIf
EndIf
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VXX002P ³ Autor ³ Andre Luis Almeida              ³ Data ³ 22/11/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacao/Levantamento/DuploClik de produtivos para fila do Atendimento³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VXX002P(nTp)
Local ni      := 1
Local cQuery  := ""
Local cQAlVDG := "SQLVDG"
Do Case
	Case nTp <= 1 // Levantamento da Fila de Produtivos
		aVerVend := {}
	    DbSelectArea("VDG")
	    ///////////////////////////////
	    // Vendedores Disponiveis    //
	    ///////////////////////////////
		cQuery := "SELECT VDG.* , VDG.R_E_C_N_O_ AS RECVDG , SA3.A3_NOME FROM "+RetSqlName("VDG")+" VDG , "+RetSqlName("SA3")+" SA3 WHERE VDG.VDG_FILIAL='"+xFilial("VDG")+"' AND "
		cQuery += "( VDG.VDG_DATLIM>'"+dtos(dDataBase)+"' OR ( VDG.VDG_DATLIM='"+dtos(dDataBase)+"' AND VDG.VDG_HORLIM>="+substr(time(),1,2)+substr(time(),4,2)+" ) ) AND VDG.D_E_L_E_T_=' ' AND "
		cQuery += "SA3.A3_FILIAL='"+xFilial("SA3")+"' AND SA3.A3_COD=VDG.VDG_CODVEN AND SA3.D_E_L_E_T_=' ' AND VDG.VDG_NUMATE=' ' "
		cQuery += "ORDER BY VDG.VDG_DATDIS , VDG.VDG_HORDIS "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVDG , .F., .T. )
		While !( cQAlVDG )->( Eof() )
			ni := aScan(aVerVend, { |x| x[2] == ( cQAlVDG )->( VDG_CODVEN ) } )
			If ni == 0
				aAdd(aVerVend,{IIf(Empty(( cQAlVDG )->( VDG_NUMATE )),0,2),( cQAlVDG )->( VDG_CODVEN ),( cQAlVDG )->( A3_NOME ),stod(( cQAlVDG )->( VDG_DATDIS )),( cQAlVDG )->( VDG_HORDIS ),stod(( cQAlVDG )->( VDG_DATLIM )),( cQAlVDG )->( VDG_HORLIM ),( cQAlVDG )->( VDG_NUMATE ),( cQAlVDG )->( RECVDG )})
			EndIf
			( cQAlVDG )->( DbSkip() )
		EndDo
		( cQAlVDG )->( DbCloseArea() )
	    DbSelectArea("VDG")
	    ///////////////////////////////
	    // Vendedores em Atendimento //
	    ///////////////////////////////
		cQuery := "SELECT VDG.* , VDG.R_E_C_N_O_ AS RECVDG , SA3.A3_NOME "
		cQuery +=  " FROM "+RetSqlName("VDG")+" VDG , "+RetSqlName("SA3")+" SA3 "
		cQuery += " WHERE VDG.VDG_FILIAL = '"+xFilial("VDG")+"'"
		cQuery +=   " AND ( VDG.VDG_DATLIM > '"+dtos(dDataBase)+"'"
		cQuery +=         " OR ( VDG.VDG_DATLIM = '"+dtos(dDataBase)+"'"
		cQuery +=              " AND VDG.VDG_HORLIM >= " + substr(time(),1,2) + substr(time(),4,2) + " ) "
		cQuery +=        " ) "
		cQuery +=  " AND VDG.D_E_L_E_T_ = ' '"
		cQuery +=  " AND SA3.A3_FILIAL = '" + xFilial("SA3") + "'"
		cQuery +=  " AND SA3.A3_COD = VDG.VDG_CODVEN"
		cQuery +=  " AND SA3.D_E_L_E_T_ = ' '"
		cQuery +=  " AND ( VDG.VDG_NUMATE <> ' ' OR VDG.VDG_NUMATE <> 'FILAOS' ) "
		cQuery += " ORDER BY VDG.VDG_NUMATE DESC "
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVDG , .F., .T. )
		While !( cQAlVDG )->( Eof() )
			ni := aScan(aVerVend, { |x| x[2] == ( cQAlVDG )->( VDG_CODVEN ) } )
			If ni == 0
				aAdd(aVerVend,{IIf(Empty(( cQAlVDG )->( VDG_NUMATE )),0,2),( cQAlVDG )->( VDG_CODVEN ),( cQAlVDG )->( A3_NOME ),stod(( cQAlVDG )->( VDG_DATDIS )),( cQAlVDG )->( VDG_HORDIS ),stod(( cQAlVDG )->( VDG_DATLIM )),( cQAlVDG )->( VDG_HORLIM ),( cQAlVDG )->( VDG_NUMATE ),( cQAlVDG )->( RECVDG )})
			EndIf
			( cQAlVDG )->( DbSkip() )
		EndDo
		( cQAlVDG )->( DbCloseArea() )
		If len(aVerVend) <= 0
			aAdd(aVerVend,{0,"","",ctod(""),0,ctod(""),0,"",0})
		EndIf
		If nTp == 1
			oLbPreAte:SetArray(aVerVend)
			oLbPreAte:bLine := { || { IIf(aVerVend[oLbPreAte:nAt,01]==1,o_Amar,IIf(aVerVend[oLbPreAte:nAt,01]==2,o_Azul,o_Verd)),;
			aVerVend[oLbPreAte:nAt,02]+" - "+aVerVend[oLbPreAte:nAt,03],;
			FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,04],"@D"),"E")+" "+FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,05],"@R 99:99")+"h","D"),;
			FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,06],"@D"),"E")+" "+FG_AlinVlrs(Transform(aVerVend[oLbPreAte:nAt,07],"@R 99:99")+"h","D"),;
			aVerVend[oLbPreAte:nAt,08] }}
		EndIf
	Case nTp <= 3 // Validacao do Codigo/Loja do Cliente
		If !Empty(cVV9CCli+IIf(nTp==3,cVV9LCli,""))
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+cVV9CCli+IIf(nTp==3,cVV9LCli,"")))
				cVV9CCli := SA1->A1_COD
				cVV9LCli := SA1->A1_LOJA
				cVV9NCli := SA1->A1_NOME
				cVV9FCli := SA1->A1_TEL
			Else
				cVV9CCli := space(TamSx3("VV9_CODCLI")[1])
				cVV9LCli := space(TamSx3("VV9_LOJA")[1])
				cVV9NCli := space(TamSx3("VV9_NOMVIS")[1])
				cVV9FCli := space(TamSx3("VV9_TELVIS")[1])
			EndIf
			oVV9CCli:Refresh()
			oVV9LCli:Refresh()
			oVV9NCli:Refresh()
			oVV9FCli:Refresh()
		EndIf
	Case nTp == 4 // Validacao do Nome do Cliente
		If !Empty(cVV9CCli+cVV9LCli)
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+cVV9CCli+cVV9LCli))
				If cVV9NCli <> SA1->A1_NOME
					cVV9CCli := space(TamSx3("VV9_CODCLI")[1])
					cVV9LCli := space(TamSx3("VV9_LOJA")[1])
					cVV9FCli := space(TamSx3("VV9_TELVIS")[1])
				EndIf
			EndIf
		EndIf
		oVV9CCli:Refresh()
		oVV9LCli:Refresh()
		oVV9FCli:Refresh()
	Case nTp == 5 // Duplo Clik no ListBox dos Produtivos
		If !Empty(aVerVend[oLbPreAte:nAt,02])
			Do Case
				Case aVerVend[oLbPreAte:nAt,01] == 1
					If Empty(aVerVend[oLbPreAte:nAt,08])
						aVerVend[oLbPreAte:nAt,01] := 0
					Else
						aVerVend[oLbPreAte:nAt,01] := 2
					EndIf
				Case aVerVend[oLbPreAte:nAt,01] == 2
					aVerVend[oLbPreAte:nAt,01] := 1
				Case aVerVend[oLbPreAte:nAt,01] == 0
					aVerVend[oLbPreAte:nAt,01] := 1
			EndCase
			For ni := 1 to len(aVerVend)
				If oLbPreAte:nAt <> ni
					If aVerVend[ni,01] == 1
						If Empty(aVerVend[ni,08])
							aVerVend[ni,01] := 0
						Else
							aVerVend[ni,01] := 2
						EndIf
					EndIf
				EndIf
			Next
			oLbPreAte:Refresh()
		EndIf
EndCase
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXX002FILA ³ Autor ³ Andre Luis Almeida              ³ Data ³ 13/12/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inserir Vendedor na Fila de Atendimentos                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VX002FILA()
Local cQuery    := ""
Local cQAlVDG   := "SQLVDG"
Local nRecVDG   := 0
Local aRet      := {}
Local aParamBox := {}
If !Empty(RetSQLName("VDG")) // Existe Fila de Vendedores no Atendimento
	VAI->(dbSetOrder(4))
	VAI->(MsSeek(xFilial("VAI")+__cUserID))
	DbSelectArea("VDG")
	cQuery := "SELECT VDG.R_E_C_N_O_ AS RECVDG FROM "+RetSqlName("VDG")+" VDG WHERE VDG.VDG_FILIAL='"+xFilial("VDG")+"' AND "
	cQuery += "VDG.VDG_NUMATE=' ' AND VDG.VDG_CODVEN='"+VAI->VAI_CODVEN+"' AND "
	cQuery += "( VDG.VDG_DATLIM>'"+dtos(dDataBase)+"' OR ( VDG.VDG_DATLIM='"+dtos(dDataBase)+"' AND VDG.VDG_HORLIM>="+substr(time(),1,2)+substr(time(),4,2)+" ) ) AND "
	cQuery += "VDG.D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVDG , .F., .T. )
	If !( cQAlVDG )->( Eof() )
	   nRecVDG := ( cQAlVDG )->( RECVDG )
	EndIf
	( cQAlVDG )->( DbCloseArea() )
	AADD(aParamBox,{1,STR0085,VAI->VAI_NOMTEC,"@!","","",".F.",120,.f.}) // Vendedor
	AADD(aParamBox,{1,STR0118+" - "+STR0024,dDataBase,"@D","MV_PAR02 >= dDataBase","",".T.",50,.f.}) // Limite - Data
	AADD(aParamBox,{1,STR0118+" - "+STR0119,2359,"@R 99:99","( MV_PAR02 == dDataBase .and. MV_PAR03 >= val(substr(time(),1,2)+substr(time(),4,2)) .and. MV_PAR03 <= 2359 ) .or. ( MV_PAR02 > dDataBase .and. MV_PAR03 >= 0 .and. MV_PAR03 <= 2359 )","",".T.",50,.f.}) // Limite - Hora
	If ParamBox(aParamBox,STR0114,@aRet,,,,,,,,.f.) // Disponibilidade
		DbSelectArea("VDG")
		If nRecVDG > 0
			VDG->(DbGoTo(nRecVDG))
			RecLock("VDG",.f.)
		Else
			RecLock("VDG",.t.)
		EndIf
		VDG->VDG_FILIAL := xFilial("VDG")
		VDG->VDG_CODVEN := VAI->VAI_CODVEN
		VDG->VDG_DATDIS := dDataBase
		VDG->VDG_HORDIS := val(substr(time(),1,2)+substr(time(),4,2))
		VDG->VDG_DATLIM := aRet[2]
		VDG->VDG_HORLIM := aRet[3]
		VDG->VDG_NUMATE := ""
		MsUnLock()
	EndIf
EndIf
DbSelectArea("VV9")
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VXX002DUPL ³ Autor ³ Andre Luis Almeida              ³ Data ³ 29/09/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ 1 - Verifica se os TES divergem ( Gera Duplicata / Nao Gera Duplicata )³±±
±±³          ³ 2 - Retorna se o TES vai Gerar Duplicata ou NAO                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VXX002DUPL(nTp)
Local nDUPLICN := 0 // Qtde F4_DUPLIC == "N"
Local nDUPLICS := 0 // Qtde F4_DUPLIC == "S"
Local lRet     := .t.
SF4->(dbSetOrder(1))
VVA->(dbSetOrder(1))
VVA->(dbSeek(xFilial("VVA")+VV9->VV9_NUMATE))
While !VVA->(Eof()) .AND. VVA->VVA_FILIAL == xFilial("VVA") .AND. VVA->VVA_NUMTRA == VV9->VV9_NUMATE
	If SF4->(MsSeek(xFilial("SF4")+VVA->VVA_CODTES))
		If SF4->F4_DUPLIC $ "N/0" // TES que nao gera Duplicata ( Titulos )
			nDUPLICN++ // F4_DUPLIC == "N"
		Else // TES que gera Duplicata ( Titulos )
			nDUPLICS++ // F4_DUPLIC == "S"
		EndIf
	EndIf
	VVA->(dbSkip())
EndDo
VVA->(dbSeek(xFilial("VVA")+VV9->VV9_NUMATE))
If nTp == 1 // Validar se ha divergencia entre os TES
	If nDUPLICN > 0 .and. nDUPLICS > 0 // NAO GERA DUPLICATA e GERA DUPLICATA
		VX002ExibeHelp("VX002ERR020" , STR0050) // Os TES utilizados neste Atendimento divergem com relacao a Geracao de Duplicatas no Financeiro. Por favor utilize apenas um padrao ( Gera Duplicata / Nao Gera Duplicata ) / Atencao
		lRet := .f.
	EndIf
ElseIf nTp == 2 // Retornar se o TES vai Gerar Duplicata ou NAO
	If nDUPLICN > 0
		lRet := .f. // Nao Gerar Duplicata
	EndIf
EndIf
Return lRet

/*/{Protheus.doc} VXX002CAMPAN()
Preencher ou Limpar o conteudo do campo VVA_CAMPAN/VV0_CAMPAN (Campo Virtual)

@author Andre Luis Almeida
@since 11/07/2018
@version undefined
@param _lPreenc logico, Preencher os dados da Campanha do Interesse?
@param _cFilVVA caracter, Filial do Atendimento
@param _cNumTra caracter, Numero do Atendimento
@param _cIteTra caracter, Item do Atendimento
@param _nRecVDM numerico, RecNo do VDM
@param _nLinVVA numerico, Linha da aCols do VVA
@param _nVlrVDM numerico, Valor Negociado do Interesse
@type function
/*/
Function VXX002CAMPAN( _lPreenc , _cFilVVA , _cNumTra , _cIteTra , _nRecVDM , _nLinVVA , _nVlrVDM )
Local cRetCamp    := "" // Retorno Codigo + Descrição da Campanha
Local cQuery      := ""

Local aArea := GetArea()

Default _lPreenc  := .t.
Default _cFilVVA  := xFilial("VVA")
Default _cNumTra  := VVA->VVA_NUMTRA
Default _cIteTra  := VVA->VVA_ITETRA
Default _nRecVDM  := 0
Default _nLinVVA  := 0
Default _nVlrVDM  := 0
If _nLinVVA == 0 .and. FM_PILHA("VEIXX002")
    _nLinVVA := aScan(oGetDadVVA:aCols, { |x| x[ FG_POSVAR("VVA_ITETRA","oGetDadVVA:aHeader") ] == _cIteTra } ) // Objeto existe somente no Atendimento Modelo 2
EndIf
If _lPreenc // Preencher com conteudo ?
	If _nRecVDM == 0 // Nao passou o RecNo do VDM - Pesquisar registro VDM
		cQuery := "SELECT R_E_C_N_O_ "
		cQuery += "  FROM "+RetSqlName("VDM")
		cQuery += " WHERE VDM_FILIAL = '"+xFilial("VDM")+"'"
		cQuery += "   AND VDM_FILATE = '"+_cFilVVA+"'"
		cQuery += "   AND VDM_NUMATE = '"+_cNumTra+"'"
		cQuery += "   AND VDM_ITETRA = '"+_cIteTra+"'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		_nRecVDM := FM_SQL(cQuery) // RecNo do VDM
	EndIf
	If _nRecVDM > 0 // Achou VDM - Interesse
		DbSelectArea("VDM")
		DbGoTo(_nRecVDM)
		If !Empty(VDM->VDM_CAMPOP)
			cQuery := "SELECT VX5_DESCRI "
			cQuery += "  FROM "+RetSqlName("VX5")
			cQuery += " WHERE VX5_FILIAL = '"+xFilial("VX5")+"'"
			cQuery += "   AND VX5_CHAVE  = '026'"
			cQuery += "   AND VX5_CODIGO = '"+VDM->VDM_CAMPOP+"'"
			cQuery += "   AND D_E_L_E_T_ = ' '"
			cRetCamp := Alltrim(VDM->VDM_CAMPOP)+" - "+FM_SQL(cQuery) // Trazer Codigo e Descrição da Campanha do Interesse
		EndIf
	EndIf
EndIf
If _nLinVVA > 0 // Atualizar a Linha da aCols do VVA
	If nVerAten == 3 // Versao do Atendimento
		M->VVA_CAMPAN := cRetCamp
		VX002ACOLS("VVA_CAMPAN",_nLinVVA)
		If _nVlrVDM > 0
			M->VVA_VALTAB := _nVlrVDM
			M->VVA_VALVDA := _nVlrVDM
			VX002ACOLS("VVA_VALTAB",_nLinVVA)
			VX002ACOLS("VVA_VALVDA",_nLinVVA)
			VX002FOK( 4 , "M->VVA_VALTAB" )
		EndIf
	Else
		M->VV0_CAMPAN := cRetCamp
		If _nVlrVDM > 0
			M->VV0_VALTAB := _nVlrVDM
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return cRetCamp

Function VX002ExibeHelp(cNomeHelp, cTexto, cSolucao)
	Default cSolucao := ""

	Help(;
		NIL, NIL,; // cRotina , nLinha
		cNomeHelp,; // cCampo
		,; // cNome
		cTexto,; // cMensagem
		1,; // nLinha1
		0,; // nColuna
		NIL, NIL, NIL, NIL,; // lPop , hWnd , nHeight , nWidth
		NIL,; // lGravaLog
		{ cSolucao } ) // aSoluc

Return

Function VX002VeicExecAuto(cReadVar, nOpc)

	Local aRetFiltro := {VX002ADDRETFILTRO()}
	Local cTipoVenda := "1"
	Local nValorVda := 0

	Local nPosAItens

	Local lVVASEGMOD := ( VVA->(ColumnPos("VVA_SEGMOD")) > 0 )

	Default cReadVar := ReadVar()

	VX002CONOUT("VX002VeicExecAuto",cReadVar + " - " + cValToChar(nOpc))

	If ! lVVASEGMOD
		M->VVA_SEGMOD := ""
	EndIf

	If cReadVar $ "M->VVA_CHAINT/M->VVA_CHASSI"
		Do Case
		Case cReadVar == "M->VVA_CHAINT"
			VV1->(dbSetOrder(1))
			If ! VV1->(dbSeek(xFilial("VV1") + M->VVA_CHAINT))
				HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VVA_CHAINT")) + ": " + M->VVA_CHAINT ,4,1)
				Return .f.
			EndIf
		Case cReadVar == "M->VVA_CHASSI"
			VV1->(dbSetOrder(2))
			If ! VV1->(dbSeek(xFilial("VV1") + M->VVA_CHASSI))
				HELP(" ",1,"REGNOIS",,AllTrim(RetTitle("VVA_CHASSI")) + ": " + M->VVA_CHASSI ,4,1)
				Return .f.
			EndIf
			M->VVA_CHAINT := VV1->VV1_CHAINT
		EndCase
		FGX_VV2()
		M->VVA_CODMAR := VV1->VV1_CODMAR
		M->VVA_GRUMOD := VV2->VV2_GRUMOD
		M->VVA_MODVEI := VV1->VV1_MODVEI
		M->VVA_CORVEI := VV1->VV1_CORVEI
		M->VVA_SEGMOD := VV1->VV1_SEGMOD
	EndIf

	If Empty(M->VVA_CHAINT)
		cTipoVenda := "3"
	EndIf

	nValorVda := M->VVA_VALTAB
	If (nPosAItens := aScan( aAutoItens[n] , { |x| AllTrim(x[1]) == "VVA_VALTAB" } )) <> 0
		nValorVda := aAutoItens[n, nPosAItens, 2]
	EndIf
	If (nPosAItens := aScan( aAutoItens[n] , { |x| AllTrim(x[1]) == "VVA_CODTES" } )) <> 0
		M->VV0_CODTES := M->VVA_CODTES := aAutoItens[n, nPosAItens, 2]
	EndIf
	If nValorVda == 0
		nValorVda := FGX_VLRSUGV( ;
			M->VVA_CHAINT,;
			M->VVA_CODMAR,;
			M->VVA_MODVEI,;
			M->VVA_SEGMOD,;
			" ",;
			.t.,;
			M->VV0_CODCLI,;
			M->VV0_LOJA )
	EndIf

	// Gerar uma matriz aRetFiltro com a mesma estrutura do retorno da funcao VEIXC001
	aRetFiltro[01,01] := M->VVA_CHAINT		// Chaint
	aRetFiltro[01,02] := M->VVA_ESTVEI		// Estado do Veiculo (Novo/Usado)
	aRetFiltro[01,03] := M->VVA_CODMAR		// Marca
	aRetFiltro[01,04] := M->VVA_GRUMOD		// Grupo do Modelo
	aRetFiltro[01,05] := M->VVA_MODVEI		// Modelo
	aRetFiltro[01,06] := M->VVA_CORVEI		// Cor
	aRetFiltro[01,07] := ""						// Codigo Progresso
	aRetFiltro[01,08] := cTipoVenda 			// Tipo (1-Normal/3-Venda Futura/4-Simulacao)
	aRetFiltro[01,09] := nValorVda			// Valor do Veiculo
	aRetFiltro[01,10] := M->VVA_SEGMOD		// Segmento de Modelo

	oGetDadVVA:nAt := N
	// Disparar VX002CONSV passando o aRetFiltro
	VX002CONSV((INCLUI .or. ALTERA),nOpc,.t.,aRetFiltro,.F.,oGetDadVVA:nAt,.t.)
	//

Return .t.

Function VX002ADDRETFILTRO()
Return {"","","","","","","","1",0,"",""}

Function VX002CONOUT(cTexto,cAuxPar)
	Default cAuxPar := ""
	If lDebug
		If Empty(cTexto)
			Conout("+"  + Replica("-",22) + "+" + " " + ProcName(2) )
		Else
			Conout("| " + PadR(cTexto,20) + " | "     + ProcName(2) + IIf(Empty(cAuxPar) , "", " - " + AllTrim(cValToChar(cAuxPar))) )
		EndIf
	EndIf
Return

Function VX0020013_AtendimentoDePedidoVenda(lINCLUI , cNumAte)
	Local lRetorno := .f.
	If lINCLUI
		Return .f.
	EndIf

//	If TableInDic("VRJ")
//		cSQL := "SELECT COUNT(VRK_NUMTRA) " +;
//			" FROM " + RetSQLName("VRK") + " VRK " + ;
//			" WHERE VRK.VRK_FILIAL = '" + xFilial("VRK") + "'" + ;
//			  " AND VRK.VRK_NUMTRA = '" + cNumAte + "'" + ;
//			  " AND VRK.VRK_CANCEL <> '1'" + ;
//			  " AND VRK.D_E_L_E_T_ = ' '"
//		lRetorno := FM_SQL(cSQL) <> 0
//		If lRetorno
//			MsgInfo("Atendimento de pedido de venda ")
//		EndIf
//	EndIf

Return lRetorno


/*/{Protheus.doc} VX0020011_ValidaRelacionamentoInteresse()
Tudo OK da Tela de Relacionamento do Interesse

@author Andre Luis Almeida
@since 27/12/2018
@version undefined
@param aVetRelac array, vetor dos Interesses relacionados
@type function
/*/
Function VX0020011_ValidaRelacionamentoInteresse(aVetRelac)
Local lRet := .t.
If ExistBlock("VX002VOP")
/*
	aVetRelac[n,01] = Interesse selecionado ( .t. / .f. )
	aVetRelac[n,02] = Campanha
	aVetRelac[n,03] = Marca
	aVetRelac[n,04] = Modelo
	aVetRelac[n,05] = Cor
	aVetRelac[n,06] = Qtde (default: 1)
	aVetRelac[n,07] = Data Interesse
	aVetRelac[n,08] = Data Validade do Interesse
	aVetRelac[n,09] = RecNo do VDM
	aVetRelac[n,10] = Opcionais
	aVetRelac[n,11] = Codigo do Vendedor
	aVetRelac[n,12] = Item do Atendimento ( relacionamento VDM_ITETRA com VVA_ITETRA )
	aVetRelac[n,13] = Cor Legenda
*/
	lRet := ExecBlock("VX002VOP",.f.,.f.,{ M->VV9_FILIAL , M->VV9_NUMATE , aClone(aVetRelac) })
EndIf
Return lRet

/*/{Protheus.doc} VX0020021_GravaVS9()
Gravacao do VS9 ( aVS9 )

@author Andre Luis Almeida
@since 24/01/2020
@version undefined
@param aVS9 array, vetor das Entradas VS9
@type function
/*/
Function VX0020021_GravaVS9( aVS9 )
Local nUsado := Len(aVS9[2,1])
Local nCntLinha := 0
Local nCntCampo := 0
//
DbSelectArea("VS9")
VS9->(dbSetOrder(1)) // VS9_FILIAL+VS9_NUMIDE+VS9_TIPOPE+VS9_TIPPAG+VS9_SEQUEN
//
aAuxHeader := aClone(aVS9[1]) // Compatibilizacao com FG_POSVAR
nPosNUMIDE := FG_POSVAR("VS9_NUMIDE","aAuxHeader")
nPosTIPOPE := FG_POSVAR("VS9_TIPOPE","aAuxHeader")
nPosTIPPAG := FG_POSVAR("VS9_TIPPAG","aAuxHeader")
nPosSEQUEN := FG_POSVAR("VS9_SEQUEN","aAuxHeader")
//
For nCntLinha := 1 to Len(aVS9[2])
	// Verifica se a linhas esta vazia ...
	If Empty( aVS9[2,nCntLinha,nPosNUMIDE] + aVS9[2,nCntLinha,nPosTIPOPE] + aVS9[2,nCntLinha,nPosTIPPAG] + aVS9[2,nCntLinha,nPosSEQUEN] )
		Loop
	EndIf
	// Se estiver VAZIO, e' pq acabou de incluir o VV9/VV0/VVA, colocar o nro do Atendimento
	If INCLUI .and. Empty(aVS9[2,nCntLinha,nPosNUMIDE])
		aVS9[2,nCntLinha,nPosNUMIDE] := PadR(M->VV9_NUMATE,aVS9[1,nPosNUMIDE,4]," ")
	EndIf
	VS9->(dbSeek(xFilial("VS9") + PadR(aVS9[2,nCntLinha,nPosNUMIDE],aVS9[1,nPosNUMIDE,4]," ") + aVS9[2,nCntLinha,nPosTIPOPE] + aVS9[2,nCntLinha,nPosTIPPAG] + aVS9[2,nCntLinha,nPosSEQUEN] ))
	// Se nao tiver excluido
	If !aVS9[2,nCntLinha,nUsado]
		If !VS9->(Found())
			RecLock("VS9",.T.)
			VS9->VS9_FILIAL := xFilial("VS9")
			aVS9[2,nCntLinha,nPosNUMIDE] := PadR(M->VV9_NUMATE,aVS9[1,nPosNUMIDE,4]," ")
		Else
			RecLock("VS9",.F.)
		EndIf
		For nCntCampo := 1 to (nUsado - 1)
			// Campo de Visualizacao
			If aVS9[1,nCntCampo,10] <> "V"
				If aVS9[2,nCntLinha,nCntCampo] == NIL
					&("VS9->" + aVS9[1,nCntCampo,2]) := CriaVar(aVS9[1,nCntCampo,2])
				Else
					&("VS9->" + aVS9[1,nCntCampo,2]) := aVS9[2,nCntLinha,nCntCampo]
				EndIf
			EndIf
		Next nCntCampo
		MsUnLock()
		// Exclui o Registro
	Else
		If VS9->(Found())
			RecLock("VS9",.F.,.T.)
			VS9->(dbDelete())
			MsUnLock()
		EndIf
	EndIf
Next nCntLinha
//
Return

/*/{Protheus.doc} VX0020031_GravaVSE()
Gravacao do VSE ( aVSE )

@author Andre Luis Almeida
@since 24/01/2020
@version undefined
@param aVSE array, vetor das Entradas VSE
@type function
/*/
Function VX0020031_GravaVSE( aVSE )
Local nUsado := Len(aVSE[2,1])
Local nCntLinha := 0
Local nCntCampo := 0
//
DbSelectArea("VSE")
VSE->(dbSetOrder(1)) // VSE_FILIAL+VSE_NUMIDE+VSE_TIPOPE+VSE_TIPPAG+VSE_SEQUEN
//
aAuxHeader := aClone(aVSE[1]) // Compatibilizacao com FG_POSVAR
nPosNUMIDE := FG_POSVAR("VSE_NUMIDE","aAuxHeader")
nPosTIPOPE := FG_POSVAR("VSE_TIPOPE","aAuxHeader")
nPosTIPPAG := FG_POSVAR("VSE_TIPPAG","aAuxHeader")
nPosSEQUEN := FG_POSVAR("VSE_SEQUEN","aAuxHeader")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui todas a VSE marcadas como excluidas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nCntLinha := 1 to Len(aVSE[2])
	If aVSE[2,nCntLinha,nUsado]
		cString := "DELETE FROM "+RetSqlName("VSE")+ " WHERE VSE_FILIAL = '" + xFilial("VSE") + "' AND VSE_NUMIDE = '" + PadR(aVSE[2,nCntLinha,nPosNUMIDE],aVSE[1,nPosNUMIDE,4]," ") + "' AND VSE_TIPOPE = '" + aVSE[2,nCntLinha,nPosTIPOPE] + "' AND VSE_TIPPAG = '" + aVSE[2,nCntLinha,nPosTIPPAG] + "' AND VSE_SEQUEN = '" + aVSE[2,nCntLinha,nPosSEQUEN] + "'"
		TCSqlExec(cString)
	EndIf
Next nCntLinha
For nCntLinha := 1 to Len(aVSE[2])
	// Verifica se a linhas esta vazia ...
	If Empty( aVSE[2,nCntLinha,nPosNUMIDE] + aVSE[2,nCntLinha,nPosTIPOPE] + aVSE[2,nCntLinha,nPosTIPPAG] + aVSE[2,nCntLinha,nPosSEQUEN] )
		Loop
	EndIf
	// Se nao tiver excluido
	If !aVSE[2,nCntLinha,nUsado]
		RecLock("VSE",.T.)
		VSE->VSE_FILIAL := xFilial("VSE")
		aVSE[2,nCntLinha,nPosNUMIDE] := PadR(M->VV9_NUMATE,aVSE[1,nPosNUMIDE,4]," ")
		For nCntCampo := 1 to (nUsado - 1)
			// Campo de Visualizacao
			If aVSE[1,nCntCampo,10] <> "V"
				If aVSE[2,nCntLinha,nCntCampo] == NIL
					&("VSE->" + aVSE[1,nCntCampo,2]) := CriaVar(aVSE[1,nCntCampo,2])
				Else
					&("VSE->" + aVSE[1,nCntCampo,2]) := aVSE[2,nCntLinha,nCntCampo]
				EndIf
			EndIf
		Next nCntCampo
		MsUnLock()
	EndIf
Next nCntLinha
Return

/*/{Protheus.doc} VX0020041_LimpaAprovacaoPrevia
Limpa Aprovacao Previa

@author Andre Luis Almeida
@since 18/02/2020
@version undefined
@type function
/*/
Static Function VX0020041_LimpaAprovacaoPrevia()
dbSelectarea("VV9")
RecLock("VV9",.f.)
	VV9->VV9_APRPUS := ""
	VV9->VV9_APRPDT := ctod("")
	VV9->VV9_APRPHR := 0
MsUnLock()
Return

/*/{Protheus.doc} VX0020051_LimpaPedido
Limpa Pedido

@author Andre Luis Almeida
@since 16/04/2020
@version undefined
@type function
/*/
Static Function VX0020051_LimpaPedido()
Local lVQ0_ITETRA := ( VQ0->(ColumnPos("VQ0_ITETRA")) > 0 )
dbSelectarea("VVA")
dbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
dbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
While !Eof() .and. VVA->VVA_FILIAL == xFilial("VVA") .and. VVA->VVA_NUMTRA == VV9->VV9_NUMATE
	If !Empty(VVA->VVA_CODPED)
		DbSelectArea("VQ0")
		DbSetOrder(1)
		If DbSeek(xFilial("VQ0")+VVA->VVA_CODPED)
			RecLock("VQ0",.f.)
			VQ0->VQ0_FILATE := ""
			VQ0->VQ0_NUMATE := ""
			If lVQ0_ITETRA
				VQ0->VQ0_ITETRA := ""
			EndIf
			MsUnLock()
		EndIf
	EndIf
	DbSelectArea("VVA")
	DbSkip()
EndDo
dbSelectarea("VVA")
dbSetOrder(1) // VVA_FILIAL+VVA_NUMTRA
dbSeek(xFilial("VVA")+VV9->VV9_NUMATE)
Return

Static Function VX0020063_FiscalAdProduto(nItemFiscal, nValorVeic, cTES, cB1Cod, lRecalcFiscal)

	Default cB1Cod := "" // Se nao passar B1_COD, o produto ja deve estar posicionado
	Default lRecalcFiscal := .t.

	SF4->(dbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4") + cTES))

	If ! Empty(cB1Cod)
		SB1->(dbSetOrder(1))
		SB1->(MsSeek(xFilial("SB1") + cB1Cod))
	EndIf

	N := nItemFiscal

	MaFisIniLoad(nItemFiscal,;
		{ SB1->B1_COD,; // IT_PRODUTO
			cTES,; // IT_TES
			Space(TamSX3("D1_CODISS")[1]),; // IT_VALISS - Valor do ISS do item sem aplicar o arredondamento
			1,; // IT_QUANT - Quantidade do Item
			"",;// IT_NFORI - Numero da NF Original
			"",;// IT_SERORI - Serie da NF Original
			SB1->(RecNo()) ,;  // IT_RECNOSB1
			SF4->(RecNo()) ,;  // IT_RECNOSF4
			0 })        //IT_RECORI

	MaFisLoad("IT_PRODUTO"  , SB1->B1_COD , nItemFiscal)
	MaFisLoad("IT_QUANT"    , 1           , nItemFiscal)
	MaFisLoad("IT_TES"      , cTES        , nItemFiscal)
	MaFisLoad("IT_PRCUNI"   , nValorVeic  , nItemFiscal)
	MaFisLoad("IT_VALMERC"  , nValorVeic  , nItemFiscal)

	MaFisRecal("",nItemFiscal)

	// Finaliza a carga dos itens Fiscais
	// 1-(default) Executa o recalculo de todos os itens para efetuar a atualizacao do cabecalho
	// 2-Executa a soma do item para atualizacao do cabecalho
	MaFisEndLoad(nItemFiscal, IIf( lRecalcFiscal , 1, 2 ) )
	//

Return nItemFiscal
