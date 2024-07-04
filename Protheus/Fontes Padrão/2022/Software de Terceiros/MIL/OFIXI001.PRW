// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 47     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#include "OFIXI001.ch"

STATIC ControleImpressao := FindFunction("OX001REGIMP")

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OFIXI001   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Fases do Orcamento                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXI001(cNumOrc,_lSeparado)
Local nCntFor, nCntFor2, nCntFor3
Local lCtrlLote   := GetNewPar("MV_RASTRO","N") == "S"    
Local lTransf     := .f.
Local lReser      := .f.
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local lVS7DIVERG  := VS7->(FieldPos("VS7_DIVERG")) > 0
Local lVS7SemProb := AllTrim(GetNewPar("MV_MIL0131", "0")) == "1" // Cria/Mostra VS7 de todos os Itens se pelo menos 1 tiver problema de Margem ou Desconto
Local cNroConf    := ""
Local cVS1_STATUS := ""
Local lExecPE     := .f.
Private nDesPer := 0
Private lSeparado

Default _lSeparado := .f.

lSeparado := _lSeparado

DBSelectArea("VS1")
DBSetOrder(1)
if !DBSeek(xFilial("VS1")+cNumOrc)
	return {STR0001+cNumOrc,.f.,.f.,.f.} // Orçamento por Fases
endif
//
if VS1->VS1_TIPORC == '3'    
	OI001ATU(cNumOrc,cFaseConfer)
	RecLock("VS1",.f.)
	VS1->VS1_STATUS := cFaseConfer
	MsUnlock()
	If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
		OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , cNumOrc ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
	EndIf
	return {"" ,.f.,.f.,.f.}
EndIf

if VS1->VS1_TIPORC = '2'  // SERVICO NÃO TEM FASE
	MsgInfo(STR0020,STR0019)
	OI001ATU(cNumOrc,"F")
	return {"" ,.f.,.f.,.f.}
endif
//
cVS1_STATUS := IIf(VS1->VS1_STATUS=="G","F",VS1->VS1_STATUS) // Status G não tem tratamento especifico, é para trabalhar como se fosse a Fase F - Liberado para Faturamento
//
// Inicio da Validacao das Fases do Orcamento
cFaseOrc := OI001GETFASE(cNumOrc)
cFaseAtu := cVS1_STATUS
cFaseIni := cVS1_STATUS
cTipPag  := VS1->VS1_FORPAG
nPos := At(cVS1_STATUS,cFaseOrc)
if nPos < 1
	nPos := 1
Else
	If nPos <> 1
		cFaseIni := subs(cFaseorc,At(cVS1_STATUS,cFaseOrc)-1,1)
	Endif
endif
if Len(cFaseOrc) == 0
	cFaseAtu := "F"
endif
for nCntFor := nPos to Len(cFaseOrc)
	cFaseAtu := Subs(cFaseOrc,nCntFor,1)
	//#########################################################################################
	if cFaseAtu == "X" // ORCAMENTO FECHADO
		//#########################################################################################
		OI001ATU(cNumOrc,cFaseAtu)
		return {STR0002,.f.,.f.,.f.}
		//#########################################################################################
	elseif cFaseAtu == "C" // ORCAMENTO CANCELADO
		//#########################################################################################
		OI001ATU(cNumOrc,cFaseAtu)
		return {STR0003,.f.,.f.,.f.}
		//#########################################################################################
	elseif cFaseAtu == "2" // MARGEM DE LUCRO
		//#########################################################################################
		if VS1->VS1_TIPORC # "3"
			if !Empty(VS1->VS1_NUMLIB)
				If FM_SQL("SELECT COUNT(VS6.R_E_C_N_O_) RECVS6 FROM "+RetSQLName("VS6")+" VS6 WHERE VS6.VS6_FILIAL='"+xFilial("VS6")+"' AND VS6.VS6_DATAUT='        '  AND VS6.D_E_L_E_T_ = ' ' AND VS6.VS6_NUMORC='"+cNumOrc+"'") > 0
					OI001ATU(cNumOrc,cFaseAtu)
					return { STR0004,.f.,.f.,.f.}
				Else
					MsgInfo(STR0005,STR0006)
				EndIf
			else
				DBSelectArea("VS3")
				DBSetOrder(1)
				DBSeek(xFilial("VS3")+cNumOrc)
				aIDescont := {}
				lProbDes := .f.
				lMostraHlp := .t.
				lFazPergunta := .t.
				// #########################################################
				// # PONTO DE ENTRADA PARA CUSTOMIZACAO DA MARGEM DE LUCRO #
				// #########################################################
				if ExistBlock("OXA012LP")
					aIDescont :=  ExecBlock("OXA012LP",.f.,.f.,{cNumOrc})
					for nCntFor2 := 1 to Len(aIDescont)
						if !aIDescont[nCntFor2]
							lProbDes := .t.
						endif
					next
				else
					while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+ VS3->VS3_NUMORC
						DBSelectArea("SF4")
						DBSetOrder(1)
						dbSeek(xFilial("SF4")+VS3->VS3_CODTES)
						DBSelectArea("SB1")
						DBSetOrder(7)
						DBSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE)
						DBSelectArea("SBM")
						DBSetOrder(1)
						DBSeek(xFilial("SBM")+SB1->B1_GRUPO)
						
						dbSelectArea("SX3")
						DBSetOrder(1)
						DBSeek("VS3")
						While !Eof().And.(x3_arquivo=="VS3")
							If x3_context != "V"
								&("M->"+x3_campo +":= VS3->"+x3_campo)
							endif
							DBSkip()
						enddo
						//lRetDes := 	FG_PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,"P",VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,,)
						if SF4->F4_OPEMOV != "05"
							lRetDes := .t.
						else
							if lProbDes .and. lMostraHlp .and. lFazPergunta
								lFazPergunta := .f.
								if !MsgYesNo(STR0024,STR0006)
									lMostraHlp := .f.
								endif
							endif
							if VS1->VS1_TIPORC == "2"
								lRetDes := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,lMostraHlp,VS1->VS1_CLIFAT,VS1->VS1_LOJA,"3",VS3->VS3_VALTOT/VS3->VS3_QTDITE,,VS1->VS1_FORPAG)
							else
								lRetDes := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,lMostraHlp,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VS1->VS1_TIPVEN,VS3->VS3_VALTOT/VS3->VS3_QTDITE,,VS1->VS1_FORPAG)
							endif
						endif
						aAdd(aIDescont,lRetDes)
						if !lRetDes // .and. VS3->VS3_VALDES != 0
							lProbDes := .t.
						endif
						if ExistBlock("OI001RDE")
							ExecBlock("OI001RDE",.f.,.f.)
						endif
						DBSelectArea("VS3")
						DBSkip()
					enddo
				endif
				if lProbDes
					if Funname() == "OFIXA011"
						//				if MsgYesNo("Existem itens com margem/descontos nao permitidas. Deseja voltar ao orcamento?","Atencao")
						n_Opcao := Aviso(STR0006,STR0007,{STR0008,STR0009},2)
						if n_Opcao == 1
							OI001ATU(cNumOrc,cFaseAtu)
							return {STR0010,.t.,.t.,.f.}
						endif
					else
						MsgInfo(STR0021,STR0006)
					endif
				endif
				if lProbDes
					if Funname() == "OFIXA011"
						aMemos2  	:= {{"VS6_OBSMEM","VS6_OBSERV"}}
						oFonteVS6  	:= TFont():New( "Arial", 8,14 )
						cObservVS6 	:= space(TamSx3("VS6_OBSERV")[1])
						//cObservVS6 	:= MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1])
						DEFINE MSDIALOG oDlgVS6 TITLE OemtoAnsi(STR0011) FROM  02,04 TO 14,56 OF oMainWnd
						DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlgVS6:End()) ENABLE OF oDlgVS6
						DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlgVS6:End()) ENABLE OF oDlgVS6
						@ 01,011 GET oObserv VAR cObservVS6 OF oDlgVS6 MEMO SIZE 182,67 PIXEL
						oObserv:oFont := oFonteVS6
						oObserv:bRClicked := {|| AllwaysTrue() }
						oObserv:SetFocus()
						ACTIVATE MSDIALOG oDlgVS6 CENTER
					endif
					lTemML := .f.
					lTemDesc := .f.
					for nCntFor3 := 1 to 2
						if (GetNewPar("MV_SEPDML","N") == "N" .and. nCntFor3 == 2) .OR. (nCntFor3 == 2 .and. !lTemML)
							loop
						endif
						dbSelectArea("VS6")
						cNumVS6 := GetSxENum("VS6","VS6_NUMIDE")
						RecLock("VS6",.t.)
						VS6->VS6_FILIAL := xFilial("VS6")
						VS6->VS6_NUMIDE := cNumVS6
						VS6->(ConfirmSx8())
						VS6->VS6_TIPAUT := "1"
						VS6->VS6_CODCLI := VS1->VS1_CLIFAT
						VS6->VS6_LOJA   := VS1->VS1_LOJA
						VS6->VS6_DATOCO := dDataBase
						VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
						VS6->VS6_NUMORC := VS1->VS1_NUMORC
						VS6->VS6_TIPOCO := IIF(nCntFor3==1,"000008","000009")
						VS6->VS6_DESOCO := IIF(GetNewPar("MV_SEPDML","N")=="N",STR0012,IIF(nCntFor3==1,"DESCONTOS","MARGEM LUCRO"))
						VS6->VS6_USUARI := substr(cUsuario,7,15)
						VS6->VS6_FORPAG := VS1->VS1_FORPAG
						if Funname() == "OFIXA011"
							MSMM(,TamSx3("VS6_OBSERV")[1],,cObservVS6,1,,,"VS6","VS6_OBSMEM")
						else
							MSMM(,TamSx3("VS6_OBSERV")[1],,STR0022,1,,,"VS6","VS6_OBSMEM")
						endif
						MsUnlock()
						//
						DBSelectArea("VS3")
						DBSetOrder(1)
						DBSeek(xFilial("VS3")+cNumOrc)
						nItVS7  := 0
						while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+ VS3->VS3_NUMORC
							nItVS7 ++
							if !(aIDescont[nItVS7]) .or. lVS7SemProb 
								//Atribui a variavel "nDesPer" o Desconto Permitido
								SBM->(dbSetOrder(1))
								SBM->(dbSeek(xFilial("SBM")+VS3->VS3_GRUITE))
								if VS1->VS1_TIPORC == "2"								
									aRetDes := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,.t.,VS1->VS1_CLIFAT,VS1->VS1_LOJA,"3",VS3->VS3_VALTOT/VS3->VS3_QTDITE,3,VS1->VS1_FORPAG)
								else
									aRetDes := OX005PERDES(SBM->BM_CODMAR,VS1->VS1_CENCUS,VS3->VS3_GRUITE,VS3->VS3_CODITE,VS3->VS3_QTDITE,VS3->VS3_PERDES,.t.,VS1->VS1_CLIFAT,VS1->VS1_LOJA,VS1->VS1_TIPVEN,VS3->VS3_VALTOT/VS3->VS3_QTDITE,3,VS1->VS1_FORPAG)
								endif
								nPercMin := aRetDes[3]
								nValPerc = 	FG_FORMULA(GetNewPar("MV_FORMALI","")) // valor minimo de venda considerando a margem de lucro minima
								nValDesc = (1- aRetDes[2]/100) * VS3->VS3_VALPEC // valor minimo de venda da peca considerando desconto maximo
								if nValPerc > nValDesc
									nValPerm := nValPerc
								else
									nValPerm := nValDesc
								endif
								if aRetDes[1] != 0
									nValPerm := aRetDes[1]
								endif
								if VS3->VS3_PERDES > aRetDes[2]
									lTemDesc := .t.
								endif
								if  VS3->VS3_MARLUC < aRetDes[3]
									lTemML := .t.
								endif
								if GetNewPar("MV_SEPDML","N") == "S"
									if VS3->VS3_PERDES <= aRetDes[2] .and. nCntFor3 == 1
										DBSelectArea("VS3")
										DBSkip()
										loop
									endif
									if VS3->VS3_MARLUC >= aRetDes[3]  .and. nCntFor3 == 2
										DBSelectArea("VS3")
										DBSkip()
										loop
									endif
								endif
								dbSelectArea("VS7")
								RecLock("VS7",.t.)
								VS7->VS7_FILIAL := xFilial("VS7")
								VS7->VS7_NUMIDE := cNumVS6
								VS7->VS7_SEQUEN := Strzero(nItVS7,4)
								VS7->VS7_TIPAUT := "1"
								VS7->VS7_GRUITE := VS3->VS3_GRUITE
								VS7->VS7_CODITE := VS3->VS3_CODITE
								VS7->VS7_DESPER := aRetDes[2]
								VS7->VS7_DESDES := VS3->VS3_PERDES
								VS7->VS7_VALORI := VS3->VS3_VALPEC
								VS7->VS7_VALPER := nValPerm
								VS7->VS7_VALDES := VS3->VS3_VALPEC - (VS3->VS3_VALDES/VS3->VS3_QTDITE)
								VS7->VS7_MARPER := aRetDes[3]
								VS7->VS7_MARLUC := VS3->VS3_MARLUC
								VS7->VS7_QTDITE := VS3->VS3_QTDITE
								If lVS7DIVERG
									VS7->VS7_DIVERG := IIf(aIDescont[nItVS7],"0","1") // Se o elemento do Array estiver com .T. é porque não houve Divergencia de Desconto ou Margem
								Endif
								MsUnlock()
								if ExistBlock("OXVS7DGR")
									ExecBlock("OXVS7DGR",.f.,.f.) // Ponto de Entrada Depois da Gravacao de cada VS7
								Endif
								lExecPE := .t.
							Endif
							DBSelectArea("VS3")
							DBSkip()
						enddo
						if !lTemDesc .AND. nCntFor3 == 1 .AND. GetNewPar("MV_SEPDML","N")=="S"
							reclock("VS6",.f.,.t.)
							dbdelete()
							msunlock()
						endif
					next
					//
					dbSelectArea("VS1")
					RecLock("VS1",.f.)
					cNumLib := VS6->VS6_NUMIDE
					VS1->VS1_NUMLIB := cNumLib
					MsUnlock()
					//
					OI001ATU(cNumOrc,cFaseAtu)
					//
					If lExecPE .and. ExistBlock("OXVS7DGT")
						ExecBlock("OXVS7DGT",.f.,.f.) // Ponto de Entrada Depois da Gravacao Total do VS7
					EndIf
					//
					return {STR0013,.f.,.f.,.f.}
				endif
			endif
			OI001ATU(cNumOrc,cFaseAtu)
		else
			OI001ATU(cNumOrc,cFaseAtu)
		endif
		//#########################################################################################
	elseif cFaseAtu == "3" // LIMITE DE CREDITO
		//#########################################################################################
		if VS1->VS1_TIPORC # "3"
			if Empty(GetNewPar("MV_CPNCLC","")) .or. !alltrim(cTipPag) $ GetMv("MV_CPNCLC") .or. Empty(cTipPag)
				If "B" $ GetMv("MV_CHKCRE")
					DBSelectArea("SA1")
					DBSetOrder(1)
					if GetMv("MV_CREDCLI") == "C"
						DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT)
					else
						DBSeek(xFilial("SA1")+VS1->VS1_CLIFAT + VS1->VS1_LOJA)
					endif
					//
					If !FGX_AVALCRED(SA1->A1_COD,SA1->A1_LOJA,IIf(VS1->VS1_STATUS=="0",VS1->VS1_VTOTNF,0),.t.)
						OI001ATU(cNumOrc,cFaseAtu)  
						if VS1->(FieldPos("VS1_DTHRPL")) > 0
					  		dbSelectArea("VS1")
							RecLock("VS1",.f.)
							VS1->VS1_DTHRPL :=  Dtoc(dDataBase)+"-"+Substr(Time(),1,2)+":"+Substr(Time(),4,2)
							MsUnlock()  
						Endif	
						Return {STR0014,.t.,.f.,.f.}
					EndIf
				EndIf
			Endif
		endif
		//#########################################################################################
	elseif cFaseAtu == cFaseConfer // SEPARACAO E CONFERENCIA
		//#########################################################################################
		If ExistFunc("OA3610011_Tempo_Total_Conferencia_Saida_Orcamento")
			OA3610011_Tempo_Total_Conferencia_Saida_Orcamento( 1 , cNumOrc ) // 1=Iniciar o Tempo Total da Conferencia de Saida caso não exista o registro
		EndIf
		If ExistFunc("OX0020071_ExisteConferencia")
			cNroConf := OX0020071_ExisteConferencia( cNumOrc , .t. )
			If !Empty(cNroConf)
				VAI->(dbSetOrder(4))
				VAI->(MsSeek(xFilial("VAI")+__cUserID)) // Posiciona no VAI do usuario logado
				VM5->( DbSetOrder(1) )
				VM5->( DbSeek( xFilial("VM5") + cNroConf ) )
				If 	( VM5->VM5_STATUS == "4" ) .or. ; // Conferencia esta Aprovada ou
					( VM5->VM5_STATUS == "3" .and. VM5->VM5_DIVERG == "0" ) .or. ; // Conferencia Finalizada nao possuindo divergencias ou
					( VM5->VM5_STATUS == "3" .and. VM5->VM5_DIVERG == "1" .and. VAI->VAI_APRCON == "1" ) // Conferencia Finalizada com Divergencia e Usuario é Aprovador
					lSeparado := .t.
				EndIf
			EndIf
		Else // Versao Antiga - Tem furo se existir um unico item e o mesmo nao tem estoque.
			DBSelectArea("VS3")
			DBSetOrder(1)
			DBSeek(xFilial("VS3")+cNumOrc)
			while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
				if VS3->VS3_QTDCON != 0
					lSeparado := .t.
				endif
				DBSkip()
			enddo            
		EndIf
		// Ponto de entrada para tratativa de conferência. Pode-se manupular os valores do VS3
		// ou a variável lSeparado para pular a fase sem a necessidade de retirar do MV_FASEORC
		If ExistBlock("OI001SCO")
			ExecBlock("OI001SCO",.f.,.f.)
		EndIf
		//
		if !lSeparado
			OI001ATU(cNumOrc,cFaseAtu)
			return {STR0015,.f.,.f.,.f.}
		endif
		//#########################################################################################
	elseif cFaseAtu == "5" // LIBERACAO DE DIVERGENCIA
		//#########################################################################################
		lDivergente := .f.

		cExpressao := "VS3->VS3_QTDCON != VS3->VS3_QTDITE"
		if ExistBlock("OXI01DIV") // retorno da Expressão para determinar Divergência na confereencia de peças
			cExpressao := ExecBlock("OXI01DIV",.f.,.f.,)
		Endif
		
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+cNumOrc)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL+ VS3->VS3_NUMORC
			if &(cExpressao)
				lDivergente := .t.
				Exit
			endif
			DBSkip()
		enddo
		if lDivergente
			OI001ATU(cNumOrc,cFaseAtu)
			return {STR0016,.f.,.f.,.f.}
		endif
		//#########################################################################################
	Elseif cFaseAtu == "E" // ORCAMENTO ENVIO DE EMAIL
		//#########################################################################################
		if ExistBlock("OXIEMAIL")
			ExecBlock("OXIEMAIL",.f.,.f.,)
		Endif
		//#########################################################################################
	elseif  cFaseAtu == "F" // LIBERADO PARA FATURAMENTO
		//#########################################################################################
		OI001ATU(cNumOrc,cFaseAtu)
		return {"",.f.,.f.,.f.}
		//#########################################################################################
	elseif cFaseAtu == "R" // RESERVA O ITEM
		//#########################################################################################
		// Verifica se devemos reservar a peca
		lAguardando := .f.
		lReservado := .f.
		IF VS3->(FieldPos("VS3_QTDAGU")) > 0
			DBSelectArea("VS3")
			DBSetOrder(1)
			DBSeek(xFilial("VS3")+cNumOrc)
			while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
				if VS3->VS3_QTDRES > 0 
					if At("T",cFaseOrc) > 0 
						DbSelectArea("VDD")
						DBSetOrder(4)
						if DBSeek(xFilial("VDD")+VS3->VS3_FILIAL+VS3->VS3_NUMORC+VS3->VS3_GRUITE+VS3->VS3_CODITE)
							lReservado := .t.
						Endif	
					Else
						lReservado := .t.
					Endif	
				endif
				if VS3->VS3_QTDAGU > 0 
					lAguardando := .t.
				endif  
				DBSelectArea("VS3")
				DBSkip()
			enddo
			if lAguardando
				OI001ATU(cNumOrc,cFaseAtu)
			endif
		endif
        if !lReservado
			Begin Transaction
				cDocto := OX001RESITE(cNumOrc,.t.)
			End Transaction
			if cDocto == ""
				//
				If FindFunction("FM_GerLog")
					//grava log das alteracoes das fases do orcamento
					FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cFaseIni)
				EndIF
				//
				If lCtrlLote .and. Funname() <> "OFIXA011"
					return {STR0025,.f.,.f.,.f.} 
				Else
					If Funname() == "OFIXA011"
						return {STR0017 ,.f.,.f.,.f.} // Erro ao reservar o(s) item(s). 
					Else
						return {STR0017 + CRLF + STR0027,.f.,.f.,.f.} // Erro ao reservar o(s) item(s). // Para prosseguir com o faturamento do orçamento, utilize a opção Faturar diretamente pela rotina Orc. por Fases (OFIXA011) ou pela rotina Painel Orçamento (OFIXA018)
					EndIf
				EndIF
				//
			endif
		endif
		if lAguardando
			return {STR0023,.f.,.f.,.f.}
		endif
		//#########################################################################################
	elseif cFaseAtu == "O" // IMPRIME ORDEM DE BUSCA
		//#########################################################################################
		if ExistBlock("ORDBUSCB")
			ExecBlock("ORDBUSCB",.f.,.f.,{"O","AVANCA"})
		Endif
		If ControleImpressao
			OX001REGIMP()
		EndIf
		//#########################################################################################
	elseif cFaseAtu == "B" // GRAVAÇÃO DO VQH (BACKORDER)
		//#########################################################################################
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+cNumOrc)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
			SB1->(DbSetOrder(7))
			SB1->(DbSeek(xFilial("SB1")+VS3->VS3_GRUITE+VS3->VS3_CODITE))
			DBSelectArea("VQH")
			DBSetOrder(1)
			if DBSeek(xFilial("VQH")+VS1->VS1_NUMORC+SB1->B1_COD)
				reclock("VQH",.f.)
				VQH->VQH_QUANT  := VS3->VS3_QTDITE
				msunlock()
			else
				reclock("VQH",.t.)
				VQH->VQH_FILIAL := xFilial("VQH")
				VQH->VQH_NUMORC  := VS3->VS3_NUMORC
				VQH->VQH_PRODUT  := SB1->B1_COD
				VQH->VQH_QUANT  := VS3->VS3_QTDITE
				msunlock()
			endif
			DBSelectArea("VS3")
			DBSkip()
		enddo
		SB1->(DbSetOrder(1))
		//#########################################################################################
	elseif cFaseAtu == "T" // RESERVA O ITEM
		//#########################################################################################
		DBSelectArea("VS3")
		DBSetOrder(1)
		DBSeek(xFilial("VS3")+cNumOrc)
		while !eof() .and. xFilial("VS3")+VS1->VS1_NUMORC == VS3->VS3_FILIAL + VS3->VS3_NUMORC
			if VS3->VS3_QTDTRA > 0
				DbSelectArea("VDD")
				DBSetOrder(4)
				if DBSeek(xFilial("VDD")+VS3->VS3_FILIAL+VS3->VS3_NUMORC+VS3->VS3_GRUITE+VS3->VS3_CODITE)
					while !eof() .and. (xFilial("VDD")+VS3->VS3_FILIAL+VS3->VS3_NUMORC+VS3->VS3_GRUITE+VS3->VS3_CODITE == VDD->VDD_FILIAL + VDD->VDD_FILORC + VDD->VDD_NUMORC + VDD->VDD_GRUPO + VDD->VDD_CODITE)
						lTransf := .t.
						If !Empty(VS3->VS3_DOCSDB)
							lReser := .t.
						EndIf
						if VDD->VDD_STATUS == "R"
//							DBSelectArea("VS3")
//							reclock("VS3",.f.)
//							VS3->VS3_QTDTRA = VS3->VS3_QTDTRA - VDD->VDD_QUANT
//							msunlock()
						elseif VDD->VDD_STATUS == "C" 
							if lCtrlLote
							   if Empty(VS3->VS3_LOTECT)
									DBSelectArea("VS3")
									reclock("VS3",.f.)
									VS3->VS3_QTDTRA = VS3->VS3_QTDTRA - VDD->VDD_QUANT
									VS3->VS3_QTDRES = VS3->VS3_QTDRES + VDD->VDD_QUANT
									msunlock()
								Endif	
							Else			
								DBSelectArea("VS3")
								reclock("VS3",.f.)
								VS3->VS3_QTDTRA = VS3->VS3_QTDTRA - VDD->VDD_QUANT
								VS3->VS3_QTDRES = VS3->VS3_QTDRES + VDD->VDD_QUANT
								msunlock()
							Endif	
						endif
//						DbSelectArea("VDD")
//						if VDD->VDD_STATUS $ "RC"
//							reclock("VDD",.f.)
//							VDD->VDD_PROCES := "1"
//							msunlock()
//						endif
						DBSkip()
					enddo
				endif
			endif
			DBSelectArea("VS3")
			DBSkip()
		enddo
		if lTransf .and. !lReser
			Begin Transaction
				cDocto := OX001RESITE(cNumOrc,.t.,,.f.)
			End Transaction
		EndIf
        if lTransf
	        OI001ATU(cNumOrc,cFaseAtu)
			return {STR0020,.f.,.f.,.f.}
		Endif	
	else
		// CHAMA PTO ENTRADA
		if ExistBlock("OI001FNV")
			aRet := ExecBlock("OI001FNV",.f.,.f.,{cFaseAtu})
			if aRet[1] == .f.
				return aRet[2]
			endif
		Endif
		//
	endif
next
//
return {"",.f.,.f.,.f.}
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OXI001REVF | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Reverte fases do Orcamento                                   |##
##+----------+--------------------------------------------------------------+##
##|Parametros| Numero do Orçamento e Fase a ser alcançada (reverte até a    |##
##|          | fase especificada)                                           |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXI001REVF(cNumOrc, cFaseIni)
Local lResTrf := .f.

DBSelectArea("VS1")
DBSetOrder(1)
if DBSeek(xFilial("VS1")+cNumOrc)
	// verifica se precisa desreservar os itens
	cFaseOrc := OI001GETFASE(cNumOrc)					// Fases do orcamento
	//
	nPosI := At(cFaseIni,cFaseOrc)
	nPosR := At("R",cFaseOrc)
	if Type("aResDel") == "A" .and. Len(aResDel) > 0 
		nPosR := 0
	Endif
	nPosT := At("T",cFaseOrc)
	nPos2 := At("2",cFaseOrc)
	nPosB := At("B",cFaseOrc)
	nPosA := At(VS1->VS1_STATUS,cFaseOrc)
	cDocto := "X"
	if nPosI < nPosT .and. nPosT <= nPosA
		DBSelectArea("VDD")
		DBSetOrder(4)
		DBSeek(xFilial("VDD") + VS1->VS1_FILIAL + VS1->VS1_NUMORC)  
		lResTrf := .f.
		while xFilial("VDD") + VS1->VS1_FILIAL + VS1->VS1_NUMORC == VDD->VDD_FILIAL + VDD->VDD_FILORC + VDD->VDD_NUMORC
			if VDD->VDD_STATUS == "S"
				reclock("VDD",.f.,.t.)
				dbdelete()
				msunlock()
			endif    
			lResTrf := .t.
			DBSkip()
		enddo
	endif
	if nPosI < nPosB .and. nPosB <= nPosA 
		If TCCanOpen(RetSqlName("VQH"))
			cString := "DELETE FROM "+RetSqlName("VQH")+ " WHERE VQH_FILIAL = '"+ xFilial("VQH")+"' AND VQH_NUMORC= '"+VS1->VS1_NUMORC+"'"
			TCSqlExec(cString)
		endif
	endif


	if (nPosI < nPosR .and. nPosR <= nPosA) .or. lResTrf // o .or. é para Desreservar quando houve cancelamento da Transferencia
		Begin Transaction
			cDocto := OX001RESITE(VS1->VS1_NUMORC,.f.)
		End Transaction
	endif
	if cDocto == ""
		MsgInfo(STR0018,STR0019)
		return .f.
	endif
	// verifica se precisa cancelar pedido de liberacao
	if nPosI <= nPos2 .and. nPos2 <= nPosA
		if !Empty(VS1->VS1_NUMLIB)
			If TCCanOpen(RetSqlName("VS7"))
				cString := "DELETE FROM "+RetSqlName("VS7")+ " WHERE VS7_FILIAL = '"+ xFilial("VS7")+"' AND VS7_NUMIDE= '"+VS1->VS1_NUMLIB+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			If TCCanOpen(RetSqlName("VS6"))
				cString := "DELETE FROM "+RetSqlName("VS6")+ " WHERE VS6_FILIAL = '"+ xFilial("VS6")+"' AND VS6_NUMIDE= '"+VS1->VS1_NUMLIB+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			DBSelectArea("VS1")
			reclock("VS1",.f.)
			VS1->VS1_NUMLIB := ""
			msunlock()
		endif
		if ( VS1->(FieldPos("VS1_NUMLIS")) > 0 .and. !Empty(VS1->VS1_NUMLIS))
			If TCCanOpen(RetSqlName("VS7"))
				cString := "DELETE FROM "+RetSqlName("VS7")+ " WHERE VS7_FILIAL = '"+ xFilial("VS7")+"' AND VS7_NUMIDE= '"+VS1->VS1_NUMLIS+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			If TCCanOpen(RetSqlName("VS6"))
				cString := "DELETE FROM "+RetSqlName("VS6")+ " WHERE VS6_FILIAL = '"+ xFilial("VS6")+"' AND VS6_NUMIDE= '"+VS1->VS1_NUMLIS+"'"
				TCSqlExec(cString)
			else
				return .f.
			endif
			DBSelectArea("VS1")
			reclock("VS1",.f.)
			VS1->VS1_NUMLIS := ""
			msunlock()
		endif
	endif
	DBSelectArea("VS1")
	OI001ATU(VS1->VS1_NUMORC,cFaseIni)
endif
//
return .t.
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OI001ATU   | Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Atualiza Status no VS1                                       |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OI001ATU(cNumOrc,cFaseAtu)
//
DBSelectArea("VS1")
DBSetOrder(1)
DBSeek(xFilial("VS1")+cNumOrc)
//
reclock("VS1",.f.)
cVS1StAnt := VS1->VS1_STATUS
VS1->VS1_STATUS := cFaseAtu
msunlock()
If ExistFunc("OA3700011_Grava_DTHR_Status_Orcamento")
	OA3700011_Grava_DTHR_Status_Orcamento( VS1->VS1_NUMORC , VS1->VS1_STATUS , IIF(VS1->VS1_TIPORC=="P",STR0029,STR0028) ) // Grava Data/Hora na Mudança de Status do Orçamento / Pedidos de Venda / Orçamento por Fases
EndIf
If FindFunction("FM_GerLog")
	//grava log das alteracoes das fases do orcamento
	FM_GerLog("F",VS1->VS1_NUMORC,,VS1->VS1_FILIAL,cVS1StAnt)
EndIF
return
/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    |OI001GETFASE| Autor |  Luis Delorme         | Data | 20/05/09 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Retorna as fases do orçamento com base no VAI+parâmetros     |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Veiculos                                                     |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OI001GETFASE(cNumPar,nTipo)
Local cFases := GetNewPar("MV_FASEORC","0FX")
Default nTipo := 1
//
if nTipo == 1
	if VS1->(FieldPos("VS1_MVFASE")) > 0
		if !Empty(VS1->VS1_MVFASE)
			cFases := GetNewPar("MV_FASEOR"+VS1->VS1_MVFASE,"0FX")
		endif
	endif
else
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI") + cNumPar)
	if found()
		if VAI->(FieldPos("VAI_MVFASE")) > 0
			if !Empty(VAI_MVFASE)
				cFases := GetNewPar("MV_FASEOR"+VAI_MVFASE,"0FX")
			endif
		endif
	endif
endif

return cFases
