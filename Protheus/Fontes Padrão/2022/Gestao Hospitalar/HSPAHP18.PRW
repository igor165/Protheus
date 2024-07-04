#INCLUDE "HSPAHP18.ch"
#include "protheus.CH"
#include "topconn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP18  º Autor ³ José Orfeu         º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao de Fatura / Remessa Convenio                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP18()
 
Private cCadastro  := STR0001 //"Geração de Faturas"
Private __cFilLote := "GAT->GAT_NRFATU == '"+Space(Len(GAT->GAT_NRFATU))+"' .AND. GAT->GAT_CODCON == mv_par01 "
Private cGcmCodCon := ""
Private aRotina   := MenuDef()
 
cFilP18 := "GAT_NRFATU <> ' '"
DbSelectArea("GR0")
DbSetOrder(1)
DbSelectArea("GAT")
DbSetOrder(1)
mBrowse(06, 01, 22, 75, "GAT",,,,,,,,,,,,,, cFilP18)

Return()                 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_P18Ger ºAutor  ³Jose Orfeu          º Data ³  05/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de geracao da fatura                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_P18Ger()
Local oDlgGF
Local cConRF	:= Space(1)
Local cModGF	:= Space(1)
Local cLote		:= ""
Local aCntGF	:= {}
Local aItensNF	:= {}
Local nLoop		:= 0
Local aSize		:= {}
Local aObjects	:= {}
Local aInfo		:= {}
Local aPObj		:= {}
Local aHGAT		:= {}
Local aCGAT		:= {}
Local cMarca	:= "'LBTIK'" 
Local nUDadGat	:= 0
Local nOpcA		:= 0
Local cFiltro	:= ""
Local cFiltra	:= ""
Local nContGuia	:= 0
Local nDespGuia	:= 0
Local cAliasOld	:= Alias()
Local oGDGAT
Local aGerNF	:= {}
Local cPrfTit	:= GetMv("MV_PREFCRH")
Local lPerg		:= .T.
Local nForAux	:= 0
Local nAgrupa	:= 0
Local aVetAux	:= {}
Local nPosVet	:= 0
Local nGATNUMLOT:= 0, nGATIDMARC := 0
Local cTesNfs	:= AllTrim(GetMv("MV_TESNFS"))
Local lSurenN5 	:= GetNewPar("MV_SURENN5",.F.)

Private cCodConFil	:= ""
Private cCodPla		:= ""
Private cTipoLote	:= ""
Private cLoteIni	:= ""
Private cLoteFim	:= ""
Private nSelLote	:= ""
Private cProcesso	:= ""
Private cMesRef		:= ""
Private nObjetivo	:= ""
Private nModo		:= ""
Private cNroFatura	:= ""
Private cSb1Proc	:= AllTrim(GetMV("MV_SB1PROC"))
Private cSb1DescPr	:= ""
Private cSb1Imag	:= AllTrim(GetMV("MV_SB1IMAG"))
Private cSb1DescIm	:= ""
Private cSb1TaxD	:= AllTrim(GetMV("MV_SB1TAXD"))
Private cSb1DescTD	:= ""
Private cSb1MatM	:= AllTrim(GetMV("MV_SB1MATM"))
Private cSb1DescMM	:= ""
Private cSb1SExt	:= AllTrim(GetMV("MV_SB1SEXT"))
Private cSb1DescSE	:= ""
Private cTesSExt	:= ""
Private cStatus		:= "3"
Private Inclui		:= .T.
Private cE1Cliente := "", cE1Loja := "" // Variaveis usadas no filtro da consulta padrão HCR-Titulos a receber

 
If !Empty(cTesNfs)
	DbSelectArea("SF4")
	DbSetOrder(1)
	If DbSeek(xFilial("SF4") + cTesNfs)
		If SF4->F4_DUPLIC == 'N'
			Aviso(STR0112,STR0113,{STR0114},2,STR0115)	//"Geração Fatura"###"O TES informado no parâmetro MV_TESNFS, não gera duplicata."###"MV_TESNFS"
			If !MsgNoYes(STR0116,STR0117)	//"Deseja continuar assim mesmo?"###"Atenção"
				Return
			EndIf
		EndIf
	EndIf
EndIf

DbSelectArea("SB1")
DbSetOrder(1)
If !DbSeek(xFilial("SB1") + PadR(cSb1Proc, Len(SB1->B1_COD)))
	MsgStop(cSb1Proc + STR0007, STR0008) //", Código do Procedimento definido no parametro MV_SB1PROC não existe no SB1"###"Atenção"
	Return(.F.)                             
Else
	cSb1DescPr := SB1->B1_DESC
EndIf

If lSurenN5 .AND. !DbSeek(xFilial("SB1") + PadR(cSb1Imag, Len(SB1->B1_COD)))
	MsgStop(cSb1Imag + ", Código do Procedimento definido no parametro MV_SB1IMAG não existe no SB1", STR0008) //", Código do Procedimento definido no parametro MV_SB1IMAG não existe no SB1"###"Atenção"
	Return(.F.)                             
ElseIf lSurenN5
	cSb1DescIm := SB1->B1_DESC
EndIf

If !DbSeek(xFilial("SB1") + PadR(cSb1TaxD, Len(SB1->B1_COD)))
	MsgStop(cSb1TaxD + STR0009, STR0008) //", Código da Taxa/Diaria definida no parametro MV_SB1TAXD não existe no SB1"###"Atenção"
	Return(.F.)
Else
	cSb1DescTD := SB1->B1_DESC
EndIf

If !DbSeek(xFilial("SB1") + PadR(cSb1MatM, Len(SB1->B1_COD)))
	MsgStop(cSb1MatM + STR0010, STR0008) //", Código do Mat/Med definido no parametro MV_SB1MATM não existe no SB1"###"Atenção"
	Return(.F.)
Else
	cSb1DescMM := SB1->B1_DESC
EndIf

If !DbSeek(xFilial("SB1") + PadR(cSb1SExt, Len(SB1->B1_COD)))
	MsgStop(cSb1SExt + STR0011, STR0008) //", Código do Serviço Externo definido no parametro MV_SB1SEXT não existe no SB1"###"Atenção"
	Return(.F.)
Else
	cSb1DescSE := SB1->B1_DESC
EndIf              
 
// Limpa conteudo inicial do parametro 10 para evitar erro na geracao da remessa.
HS_PosSX1({{"HSPP18", "11", Nil}})
 
If Pergunte("HSPP18",.T.)
		HS_VSUSCP(MV_PAR01, MV_PAR02)
	 		
		If Empty(MV_PAR03)
			HS_MsgInf(STR0107, STR0008, STR0108) //"O Tipo de lote é obrigatório"### ###"Validação de parâmetros"
			lPerg := .F.
		ElseIf MV_PAR03 == "7" //Retorno Inválido
			HS_MsgInf(STR0109, STR0008, STR0108) //"Lote do tipo Retorno não é permitido para Geração da Fatura"### ###"Validação de parâmetros"
			lPerg := .F.
		ElseIf MV_PAR03 > "8" 	 	                                       
			HS_MsgInf(STR0110, STR0008, STR0108) //"Tipo de lote inválido"### ###"Validação de parâmetros"
			lPerg := .F.
		EndIf
	If lPerg

		cCodConFil	:= mv_par01 /* Codigo do convenio */
		cCodPla		:= mv_par02 /* Codido do Plano de Saude */
		cTipoLote	:= mv_par03 /* Tipo de Lote - 1=Intern. 2=Amb. 3=P.Atend. 4=Amb.+P.Atend 5=Todos */
		cLoteIni	:= mv_par04 /* Lote Final */
		cLoteFim	:= mv_par05 /* Lote Inicial */
		nSelLote	:= mv_par06 /* Seleciona lotes? 1=Sim, 2=Nao */
		cProcesso	:= mv_par07 /* Numero do processo */
		cMesRef		:= mv_par08 /* Mes e ano de referencia */
		nObjetivo	:= mv_par09 /* 1=Faturamento 2=Remessa */
		nModo		:= mv_par10 /* Faturamento: 1=sintetico, 2=analitico, 3=Grupo de despesas */
		cNroFatura	:= mv_par11 /* Numero da fatura, caso esse parametor tenha sido informado, todos os outros parametros serão desconsiderados */
		cModGF		:= StrZero(nModo-1,1)      /* Deve subtrair 1 de nmodo para nao ter de mexer nas outras rotinas*/
		cConRF		:= StrZero(nObjetivo-1, 1) /* Deve subtrair 1 de nobjetivo para nao ter de mexer nas outras rotinas*/
			
		If !Empty(cNroFatura) .Or. cConRF == "1" // Para remessa bloquear o uso por mais de um usuário ao mesmo tempo
			If !LockByName("P18REMESSA", .T., .T., .F.)
				HS_MsgInf(STR0088, STR0008, STR0089) //"Já existe outro usuário gerando remessa, tente novamente mais tarde"###"Atenção"###"Remessa"
				Return(.F.)
			EndIf	  
		EndIf
		
		DbSelectArea("GA9")
		DbSetOrder(1)
		DbSeek(xFilial("GA9") + cCodConFil)
		
		If Empty(cNroFatura)

			If Empty(cLoteFim)
				MsgInfo(STR0012) //"O lote final não pode ficar vazio"
				Return(.f.)
			EndIf
		
			If cLoteFim < cLoteIni
				MsgInfo(STR0013) //"O lote final não pode ser menor do que o lote inicial"
				Return(.f.)
			EndIf
		
			If Empty(cMesRef)
				MsgInfo(STR0014) //"Mês/Ano de Referência nao deve ficar vazio"
				Return(.f.)
			EndIf
		
			If Empty(Subs(cMesRef,1,2)) .or. Subs(cMesRef,1,2) < "01" .or. ;
			Subs(cMesRef,1,2) > "12" .or. Subs(cMesRef,3,1) != "/" .or. ;
			Empty(Subs(cMesRef,4,2)) .or. Subs(cMesRef,4,2) < "01" .or. Subs(cMesRef,4,2) > "99"
				MsgInfo(STR0015) //"O Mês/Ano de referência não é válido"
				Return(.f.)
			EndIf
		
			cFiltro := "GAT->GAT_CODCON == '" + cCodConFil        	+ "' .AND. "
			cFiltro += IIf(!Empty(cCodPla), "GAT->GAT_CODPLA == '" + cCodPla + "' .AND. ", "")
			If cTipoLote == "8"
				cFiltro += "GAT->GAT_TIPATE BETWEEN '' .AND. 'Z' .AND. "
			Else
				cFiltro += "GAT->GAT_TIPATE == '" + cTipoLote + "' .AND. "
			EndIf
			cFiltro += "GAT->GAT_NUMLOT >= '" + cLoteIni          + "' .AND. "
			cFiltro += "GAT->GAT_NUMLOT <= '" + cLoteFim          + "' .AND. "
			cFiltro += "GAT->GAT_NRFATU == '" +Space(Len(GAT->GAT_NRFATU))+"' "
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Ponto de entrada - Altera o Filtro da Rotina de Geracao de Fatura ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ExistBlock("HSP18FAT")
				cFiltro := ExecBlock("HSP18FAT", .F., .F.,{cFiltro,cMesRef})
			EndIf
		
			nQtGAT := HS_BDados("GAT", @aHGAT, @aCGAT, @nUDadGAT, 1,, cFiltro,,,,,, .T., "GAT_IDMARC", cMarca ,,, .F.)
			If nQtGAT == 0
				MsgInfo(STR0016) //"Não há lotes dentro dos parâmetros informados"
				Return(.f.)
			EndIf
			nGATNUMLOT := aScan( aHGAT, {|x| x[2] == "GAT_NUMLOT"} )
			nGATIDMARC := aScan( aHGAT, {|x| x[2] == "GAT_IDMARC"} )

			If nGATNUMLOT == 0
				MsgInfo(STR0017+X3Titulo("GAT_NUMLOT")+STR0018) //"O campo GAT_NUMLOT ("###") deve estar em uso. Acione o administrador do sistema."
				Return(.F.)
			EndIf

			If nSelLote == 1 /* Seleciona Lotes*/
				aSize    := MsAdvSize(.T.) 
				aObjects := {}
				AAdd( aObjects, { 100, 100, .T., .T. } )
				aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
				aPObj    := MsObjSize( aInfo, aObjects, .T. )
		
				Define MsDialog oDlg From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel
		
				oGDGAT := MsNewGetDados():New(aPObj[1,1]+5, aPObj[1,2], aPObj[1,3], aPObj[1,4], 0,,,,,, 99999,,,,, aHGAT, aCGAT)
				oGDGAT:oBrowse:BlDblClick := {|| FS_DblClk( oGDGAT, nGATIDMARC ) }                              
				oGDGAT:oBrowse:align      := CONTROL_ALIGN_ALLCLIENT
			
				Activate Dialog oDlg on init EnchoiceBar(oDlg, {|| nOpcA := 1, oDlg:End()},{|| nOpcA := 0, oDlg:End()} )
		
				If nOpcA == 0
					Return(.f.)
				EndIf                 
		
				aCGAT := aClone(oGDGAT:aCols)
			EndIf

			aItensNF := {}
			aCntGF   := {}

			For nLoop := 1 to Len( aCGAT )

				If aCGAT[nLoop, nGATIDMARC] == "LBNO"
					Loop
				EndIf

				cLote    := aCGAT[nLoop, nGATNUMLOT]
			
				Processa({|| FS_Despesa(@aItensNF, @aCntGF, cConRF, cModGF, nil, nil, cLote, @nContGuia, @nDespGuia)})

			Next nLoop

		Else // Gera Remessa a partir da fatura digitada
			cConRF := "1"
			Processa({|| FS_Despesa(@aItensNF, @aCntGF, cConRF, cModGF, nil, nil, cLote, @nContGuia, @nDespGuia, cNroFatura)})
		EndIf

		If cConRF == "0" .And. cModGF == "0" /*  0=Fatura e  0=Sintetico */
			For nAgrupa := 1 To Len(aItensNF)
				For nForAux := 1 To Len(aItensNF[nAgrupa])
					nPosVet := aScan(aVetAux, {| aVet | aVet[1] + aVet[8] + aVet[9] == aItensNF[nAgrupa][nForAux][1] + aItensNF[nAgrupa][nForAux][8] + aItensNF[nAgrupa][nForAux][9]})
					If nPosVet == 0
						aAdd(aVetAux, aItensNF[nAgrupa][nForAux])
					Else
						aVetAux[nPosVet][2] += aItensNF[nAgrupa][nForAux][2]
						aVetAux[nPosVet][3] += aItensNF[nAgrupa][nForAux][3]
						aVetAux[nPosVet][4] += aItensNF[nAgrupa][nForAux][4]
						aVetAux[nPosVet][5] += aItensNF[nAgrupa][nForAux][5]
					EndIf
				Next
			Next
			
			aItensNF := {}
			
			For nForAux := 1 To Len(aVetAux)
				nPosVet := FS_ComVet(aItensNF, 8, aVetAux[nForAux][8])
				If nPosVet == 0
					aAdd(aItensNF, {aVetAux[nForAux]})
				Else
					aAdd(aItensNF[nPosVet], aVetAux[nForAux])
				EndIf
			Next
		ElseIf cConRF == "1" .And. cModGF == "0" // 1-Remessa e 0-Sintetico
		
			For nAgrupa := 1 To Len(aItensNF) 
			
				If aItensNF[nAgrupa][07] $ "MT" //Materiais e Medicamentos ou Taxas e Diarias
		
					nPosVet := aScan(aVetAux, {| aVet | aVet[01] == aItensNF[nAgrupa][01] .And. aVet[02] == aItensNF[nAgrupa][02] .And. ;
												aVet[03] == aItensNF[nAgrupa][03] .And. aVet[06] == aItensNF[nAgrupa][06] .And. ;
												aVet[07] == aItensNF[nAgrupa][07] .And. aVet[11] == aItensNF[nAgrupa][11]})
			
				ElseIf aItensNF[nAgrupa][07] $ "PF" //Procedimentos e Filmes

					nPosVet := aScan(aVetAux, {| aVet | aVet[01] == aItensNF[nAgrupa][01] .And. aVet[02] == aItensNF[nAgrupa][02] .And. ;
												aVet[03] == aItensNF[nAgrupa][03] .And. aVet[06] == aItensNF[nAgrupa][06] .And. ;
												aVet[07] == aItensNF[nAgrupa][07] .And. aVet[11] == aItensNF[nAgrupa][11] .And. ;
												aVet[14] == aItensNF[nAgrupa][14]})

				EndIf
		
				If nPosVet == 0
					aAdd(aVetAux, aItensNF[nAgrupa])
				Else
					aVetAux[nPosVet][10] += aItensNF[nAgrupa][10]
					aVetAux[nPosVet][19] += Round(aItensNF[nAgrupa][10] * aItensNF[nAgrupa][11], 2)
				EndIf   
		
			Next                                                              
		
			aItensNF := aClone(aVetAux)
		
		EndIf

		If nContGuia == 0
			MsgStop(STR0019 ) //"Nao encontrou Guia Liberada para faturar"
			Return(.f.)
		EndIF

		If nDespGuia == 0
			MsgStop(STR0020 ) //" Despesas não encontradas"
			Return(.f.)
		EndIf 

		aGerNF := FS_ItensNF(aItensNF, aCntGF, cConRF, cModGF)
		If aGerNF[1]
			If cConRF == "1" .And. (Empty(GA9->GA9_SEQREM) .Or. MsgYesNo(STR0075 + Soma1(GA9->GA9_SEQREM) + "]")) //"Grava o novo numero de remessa no convenio ["
				DbSelectArea("GA9")
				RecLock("GA9", .F.)
					GA9->GA9_SEQREM := Soma1(GA9->GA9_SEQREM)
				MsUnLock()
			EndIf 
		
			If !Empty(aGerNF[2]) .And. MsgYesNo(STR0076) //"Deseja imprimir o protocolo de envio de remessa?"
				HSPAHRDX(aGerNF[2], aGerNF[3])
			EndIf 
		
			DbSelectArea(cAliasOld)
		EndIf
		
		If !Empty(cCodPla)
			HS_P18EDI(cCodPla)
		EndIf
												
		If cConRF == "1"  // Para remessa desbloquear o uso para que outro usuário possa utilizar a rotina
			UnLockByName("P18REMESSA", .T., .T., .F.)
		EndIf 
	EndIf
EndIf  
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_P18EDI ºAutor  ³Luiz Pereira S. Jr. º Data ³  12/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Faz a chamada do EDI.                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Function HS_P18EDI(cPlano)

 Local aArea := GetArea()
 Local cCodLayOut := ""


 cCodLayOut := HS_IniPadr("GCM", 2, cPlano, "GCM_LAYOUT",,.F.)
 If !Empty(cCodLayOut)
  DbSelectArea("GG2")
  DbSetOrder(1)
  DbSeek(xFilial("GG2") + cCodLayOut)

  HS_PEDIExp("GG2", GG2->(Recno()), 6)
 Else
  HS_MsgInf(STR0090, STR0008, STR0089) //"Layout do plano não foi encontrado"###"Atenção"###"Remessa"
  RestArea(aArea)
  Return(.F.)
 EndIf
  
 RestArea(aArea)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_Despesaº Autor ³                    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Despesa(aItensNF, aCntGF, cConRF, cModGF, dIniFat, dFinFat, cLote, nContGuia, nDespGuia, cNroFatura )

Local nTCntDir   := 0
Local nTotCnt    := 0
Local nTCntHsp   := 0
Local nTCntRep   := 0
Local nTotDes    := 0
Local nTotFil    := 0
Local nUCntDir   := 0
Local nUniCnt    := 0
Local nUCntHsp   := 0
Local nUCntRep   := 0
Local nPosVet    := 0
Local nAgrupa    := 0
Local cUnidade   := ""
Local aVetAux    := {}
Local nForAux    := 0
Local aArea      := HS_SavArea({{"GAT", 0, 0}, {"GCZ", 0, 0}, {"GA9", 0, 0}, {"GCS", 0, 0}})
Local cAliasOld  := Alias()
Local nTamDesc   := TamSx3("C6_DESCRI")[1]
Local lHSPROP18  := ExistBlock("HSPROP18")
Local cTesMV     := GetMV("MV_TESNFS")
Local cTesItem   := ""
Local cTesProc   := ""
Local cTesImag   := ""
Local cTesTaxD   := ""
Local cTesMatM   := ""
Local cAtendi    := "0"
Local nHdlGF     := 0
Local cLinha     := ""
Local nInd       := IIf(!Empty(cNroFatura), 22, 23)
Local cPrfTit    := GetMv("MV_PREFCRH")
Local cCodPan    := ""
Local aTabPre    := {}
Local cGr0TipCir := "000"
Local cSqlDesp   := "", cSqlWhere := "", nCntDesp := 0, nSql := 0
Local cRegAte    := Space(Len(GCZ->GCZ_REGATE))
Local cNrSeqG    := Space(Len(GCZ->GCZ_NRSEQG))
Local cNome      := ""
Local cFil       := SPACE(2)
Local lSurenN5   := GetNewPar("MV_SURENN5",.F.)
Local cGrpImag   := GetNewPar("MV_HSPGDIM","")
Local nPosProc   := 0
 
cHoraIni := Time()
  
DbSelectArea("GCZ")
DbSetOrder(nInd)
If !Empty(cNroFatura)
	DbSeek(cFilAnt + cNroFatura + cPrfTit)
Else
	DbSeek(cFilAnt + cStatus + cLote)
EndIf

If !Found()
Return(.F.)
EndIf
 
If GCZ->GCZ_FILATE <> cFilAnt .And. (!Empty(xFilial("GA9")) .Or. !Empty(xFilial("GCM")))
	HS_MsgInf(STR0101) //"Não é possível gerar fatura pois existe guias de outras filiais atreladas ao lote e as tabelas de Convênio e Plano não estão compartilhadas"
Return(.F.)
EndIf
 
If Empty(cNroFatura)
	cCodConFil := GCZ->GCZ_CODCON

	DbSelectArea("GAT")
	DbSetOrder(2)
	DbSeek(xFilial("GAT") + cCodConFil + cLote)
EndIf

cSb1Proc := IIf(Empty(GA9->GA9_B1PROC), cSb1Proc, GA9->GA9_B1PROC)
cSb1TaxD := IIf(Empty(GA9->GA9_B1TAXD), cSb1TaxD, GA9->GA9_B1TAXD)
cSb1MatM := IIf(Empty(GA9->GA9_B1MATM), cSb1MatM, GA9->GA9_B1MATM)
cSb1SExt := IIf(Empty(GA9->GA9_B1SEXT), cSb1SExt, GA9->GA9_B1SEXT)

cTesProc   := Posicione("SB1", 1, xFilial("SB1") + cSb1Proc, "B1_TS")
cTesProc   := IIf(Empty(cTesProc), cTesMV, cTesProc)
cSb1DescPR := SB1->B1_DESC

If lSurenN5
	cTesImag   := Posicione("SB1", 1, xFilial("SB1") + cSb1Imag, "B1_TS")
	cTesImag   := IIf(Empty(cTesImag), cTesMV, cTesImag)
	cSb1DescIm := SB1->B1_DESC
EndIf
 
cTesTaxD   := Posicione("SB1", 1, xFilial("SB1") + cSb1TaxD, "B1_TS")
cTesTaxD   := IIf(Empty(cTesTaxD), cTesMV, cTesTaxD)
cSb1DescTD := SB1->B1_DESC

cTesMatM   := Posicione("SB1", 1, xFilial("SB1") + cSb1MatM, "B1_TS")
cTesMatM   := IIf(Empty(cTesMatM), cTesMV, cTesMatM)
cSb1DescMM := SB1->B1_DESC

cTesSExt   := Posicione("SB1", 1, xFilial("SB1") + cSb1SExt, "B1_TS")
cTesSExt   := IIf(Empty(cTesSExt), cTesMV, cTesSExt)
cSb1DescSE := SB1->B1_DESC

If cConRF == "0"
	/*posicão 1 do vetor aItensNF -- Procedimentos*/
	/*posicão 2 do vetor aItensNF -- Taxas e Diarias*/
	/*posicão 3 do vetor aItensNF -- Materiais e Medicamentos*/
	/*posicão 4 do vetor aItensNF -- Serviços Externos*/
	/*aItensNF[1][1] Código do Item*/
	/*aItensNF[1][2] Total do hospital*/
	/*aItensNF[1][3] Total a repassar aos médicos*/
	/*aItensNF[1][4] Total do repasse pago direto pelo convenio*/
	/*aItensNF[1][5] Total a receber = nTotCnt + nTCntHsp + nTCntRep - nTCntDir*/
	/*aItensNF[1][6] Descrição do Item*/
	/*aItensNF[1][7] Origem do Produto*/
	If cModGF == "0" /* 0=Sintetico*/
		If GA9->GA9_TGERNF $ " 0" /* 0-Agrupados Internação, Ambulatorial e Pronto Atendimento*/
			aAdd(aItensNF, {{cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + GAT->GAT_DESCOM, nTamDesc), "1", "0", cTesProc}})
			aAdd(aItensNF, {{cSb1TaxD, 0, 0, 0, 0, PadR(AllTrim(cSb1DescTD) + " - " + GAT->GAT_DESCOM, nTamDesc), "2", "0", cTesTaxD}})
			aAdd(aItensNF, {{cSb1MatM, 0, 0, 0, 0, PadR(AllTrim(cSb1DescMM) + " - " + GAT->GAT_DESCOM, nTamDesc), "0", "0", cTesMatM}})
			If lSurenN5
				aAdd(aItensNF, {{cSb1Imag, 0, 0, 0, 0, PadR(AllTrim(cSb1DescIm) + " - " + GAT->GAT_DESCOM, nTamDesc), "3", "0", cTesImag}})
			EndIf
		ElseIf GA9->GA9_TGERNF == "1" /* 1-Separados Internação, Ambulatorial e Pronto Atendimento*/
			aAdd(aItensNF, {{cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "1", "0", cTesProc}, ;
				{cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "1", "1", cTesProc}, ;
				{cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + HS_RDescrB("GCS_TIPLOC", "2") + " - " + GAT->GAT_DESCOM, nTamDesc), "1", "2", cTesProc}})
			aAdd(aItensNF, {{cSb1TaxD, 0, 0, 0, 0, PadR(AllTrim(cSb1DescTD) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "2", "0", cTesTaxD}, ;
				{cSb1TaxD, 0, 0, 0, 0, PadR(AllTrim(cSb1DescTD) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "2", "1", cTesTaxD}, ;
				{cSb1TaxD, 0, 0, 0, 0, PadR(AllTrim(cSb1DescTD) + " - " + HS_RDescrB("GCS_TIPLOC", "2") + " - " + GAT->GAT_DESCOM, nTamDesc), "2", "2", cTesTaxD}})
			aAdd(aItensNF, {{cSb1MatM, 0, 0, 0, 0, PadR(AllTrim(cSb1DescMM) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "0", "0", cTesMatM}, ;
				{cSb1MatM, 0, 0, 0, 0, PadR(AllTrim(cSb1DescMM) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "0", "1", cTesMatM}, ;
				{cSb1MatM, 0, 0, 0, 0, PadR(AllTrim(cSb1DescMM) + " - " + HS_RDescrB("GCS_TIPLOC", "2") + " - " + GAT->GAT_DESCOM, nTamDesc), "0", "2", cTesMatM}})
			If lSurenN5
				aAdd(aItensNF, {{cSb1Imag, 0, 0, 0, 0, PadR(AllTrim(cSb1DescIm) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "3", "0", cTesImag}, ;
					{cSb1Imag, 0, 0, 0, 0, PadR(AllTrim(cSb1DescIm) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "3", "1", cTesImag}, ;
					{cSb1Imag, 0, 0, 0, 0, PadR(AllTrim(cSb1DescIm) + " - " + HS_RDescrB("GCS_TIPLOC", "2") + " - " + GAT->GAT_DESCOM, nTamDesc), "3", "2", cTesImag}})
			EndIf
		ElseIf GA9->GA9_TGERNF == "2" /* 2-Inter.+Amb Internação e Ambulatorial + Pronto Atendimento*/
			aAdd(aItensNF, {{cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "1", "0", cTesProc}, ;
				{cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "1", "1", cTesProc}})
			aAdd(aItensNF, {{cSb1TaxD, 0, 0, 0, 0, PadR(AllTrim(cSb1DescTD) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "2", "0", cTesTaxD}, ;
				{cSb1TaxD, 0, 0, 0, 0, PadR(AllTrim(cSb1DescTD) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "2", "1", cTesTaxD}})
			aAdd(aItensNF, {{cSb1MatM, 0, 0, 0, 0, PadR(AllTrim(cSb1DescMM) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "0", "0", cTesMatM}, ;
				{cSb1MatM, 0, 0, 0, 0, PadR(AllTrim(cSb1DescMM) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "0", "1", cTesMatM}})
			If lSurenN5
				aAdd(aItensNF, {{cSb1Imag, 0, 0, 0, 0, PadR(AllTrim(cSb1DescIm) + " - " + HS_RDescrB("GCS_TIPLOC", "0") + " - " + GAT->GAT_DESCOM, nTamDesc), "3", "0", cTesImag}, ;
					{cSb1Imag, 0, 0, 0, 0, PadR(AllTrim(cSb1DescIm) + " - " + HS_RDescrB("GCS_TIPLOC", "1") + " - " + GAT->GAT_DESCOM, nTamDesc), "3", "1", cTesImag}})
			EndIf
		EndIf
		aAdd(aItensNF, {{cSb1SExt, 0, 0, 0, 0, PadR(cSb1DescSE, nTamDesc), "X", "0", cTesSExt}})
	EndIf
	
	nHdlGF := fCreate("HSPAHP18.LOG", 0)
	
	cLinha := PadR(STR0021, Len(GCZ->GCZ_REGATE)) + " " + PadR(STR0022, Len(GCZ->GCZ_NOME)) + STR0023 + Chr(13) + Chr(10) //"Reg.Ate"###"Nome"###" Total Hospital  Total Repasse   Total Direto Total da Conta"
	fWrite(nHdlGF, cLinha, Len(cLinha))
EndIf
              
If !Empty(cNroFatura)
	cSqlWhere := " AND GCZ.GCZ_NRNOTA = '" + cNroFatura + "' AND GCZ.GCZ_SERIE = '" + cPrfTit + "' "
Else
	cSqlWhere := " AND GCZ.GCZ_STATUS = '" + cStatus + "' AND GCZ.GCZ_CODCON = '" + cCodConFil + "' AND GCZ.GCZ_NRLOTE = '" + cLote + "' "
EndIf
                                                      
For nSql := 1 To 2
	If nSql == 1
		cSqlDesp := "SELECT COUNT(*) NCNTDESP "
	Else
		cSqlDesp := "SELECT 'GE5' TABELA, GCZ.GCZ_FILIAL FILIAL, GCZ.GCZ_REGATE REGATE, GCZ.GCZ_NRSEQG NRSEQG, GCZ.GCZ_CODPLA CODPLA, GCZ.GCZ_NOME NOME, GCZ.GCZ_ATENDI ATENDI, " + ;
			"GCS.GCS_TIPLOC TIPLOC, " + ;
			"GE5.GE5_CODDES CODDES, GE5.GE5_SEQDES SEQDES, GE5.GE5_DATDES DATDES, GE5.GE5_HORDES HORDES, GE5.GE5_QTDDES QTDDES, " + HS_FValDes("GE5",,, cConRF == "1",,cConRF == "1") + " VALDES, " + ;
			"GE5.GE5_CODLOC CODLOC, GE5.GE5_CODPRO CDCONV, GE5.GE5_DESPRO DDCONV, " + ;
			"GBI.GBI_CODGDE CODGDE, GBI.GBI_TIPO TIPDES, " + ;
			"SB1.B1_DESC DDESPE, SB1.B1_UM UMDESP, SAH.AH_UMRES DESCUM, " + ;
			"GAW.GAW_DESC GDESPE, " + ;
			"0 VFILME, '" + Space(HS_CfgSx3("GA7_HONORA", {"X3_TAMANHO"})[1]) + "' HONORA, " + ;
			"'" + Space(HS_CfgSx3("GE7_PGTMED", {"X3_TAMANHO"})[1]) + "' PGTMED, 0 VALREP, " + ;
			"'" + Space(HS_CfgSx3("GE7_CODVIA", {"X3_TAMANHO"})[1]) + "' CODVIA, 0 COEDES, " + ;
			"'" + Space(HS_CfgSx3("GE7_CODATO", {"X3_TAMANHO"})[1]) + "' CODATO, " + ;
			"'" + Space(HS_CfgSx3("GE7_URGDES", {"X3_TAMANHO"})[1]) + "' URGDES, " + ;
			"'" + Space(HS_CfgSx3("GE7_CODCRM", {"X3_TAMANHO"})[1]) + "' CODCRM "
	EndIf
	                     
	cSqlDesp += "FROM " + RetSqlName("GCZ") + " GCZ " + ;
		"INNER JOIN " + RetSqlName("GCS") + " GCS ON GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_FILIAL = " + HS_xFilFat("GCS") + " AND GCS.GCS_CODLOC = GCZ.GCZ_LOCATE " + ;
		"INNER JOIN " + RetSqlName("GE5") + " GE5 ON GE5.D_E_L_E_T_ <> '*' AND GE5.GE5_FILIAL = " + HS_xFilFat("GE5") + " AND GE5.GE5_GLODES = '0' AND GE5.GE5_REGATE = GCZ.GCZ_REGATE AND GE5.GE5_NRSEQG = GCZ.GCZ_NRSEQG " + ;
		"INNER JOIN " + RetSqlName("GBI") + " GBI ON GBI.D_E_L_E_T_ <> '*' AND GBI.GBI_FILIAL = " + HS_xFilFat("GBI") + " AND GBI.GBI_PRODUT = GE5.GE5_CODDES " + ;
		"INNER JOIN " + RetSqlName("GAW") + " GAW ON GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_FILIAL = " + HS_xFilFat("GAW") + " AND GAW.GAW_CODGDE = GBI.GBI_CODGDE " + ;
		"INNER JOIN " + RetSqlName("SB1") + " SB1 ON SB1.D_E_L_E_T_ <> '*' AND SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.B1_COD     = GE5.GE5_CODDES	" + ;
		"INNER JOIN " + RetSqlName("SAH") + " SAH ON SAH.D_E_L_E_T_ <> '*' AND SAH.AH_FILIAL  = '" + xFilial("SAH") + "' AND SAH.AH_UNIMED  = SB1.B1_UM	" + ;
		"WHERE GCZ.GCZ_FILFAT = '" + cFilAnt + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_CANCEL <> '1'" + cSqlWhere + ;
		"UNION ALL "
  
	If nSql == 1
		cSqlDesp += "SELECT COUNT(*) NCNTDESP "
	Else
		cSqlDesp += "SELECT 'GE6' TABELA, GCZ.GCZ_FILIAL FILIAL, GCZ.GCZ_REGATE REGATE, GCZ.GCZ_NRSEQG NRSEQG, GCZ.GCZ_CODPLA CODPLA, GCZ.GCZ_NOME NOME, GCZ.GCZ_ATENDI ATENDI, " + ;
			"GCS.GCS_TIPLOC TIPLOC, " + ;
			"GE6.GE6_CODDES CODDES, GE6.GE6_SEQDES SEQDES, GE6.GE6_DATDES DATDES, GE6.GE6_HORDES HORDES, GE6.GE6_QTDDES QTDDES, " + HS_FValDes("GE6",,, cConRF == "1",,cConRF == "1") + " VALDES, " + ;
			"GE6.GE6_CODLOC CODLOC, GE6.GE6_CODTXC CDCONV, GE6.GE6_DESTXC DDCONV, " + ;
			"GAA.GAA_CODGDE CODGDE, GAA.GAA_TIPDES TIPDES, GAA.GAA_DESC DDESPE, " + ;
			"'" + Space(HS_CfgSx3("B1_UM", {"X3_TAMANHO"})[1]) + "' UMDESP, " + ;
			"'" + Space(HS_CfgSx3("AH_UMRES", {"X3_TAMANHO"})[1]) + "' DESCUM, " + ;
			"GAW.GAW_DESC GDESPE, " + ;
			"0 VFILME, '" + Space(HS_CfgSx3("GA7_HONORA", {"X3_TAMANHO"})[1]) + "' HONORA, " + ;
			"'" + Space(HS_CfgSx3("GE7_PGTMED", {"X3_TAMANHO"})[1]) + "' PGTMED, 0 VALREP, " + ;
			"'" + Space(HS_CfgSx3("GE7_CODVIA", {"X3_TAMANHO"})[1]) + "' CODVIA, 0 COEDES, " + ;
			"'" + Space(HS_CfgSx3("GE7_CODATO", {"X3_TAMANHO"})[1]) + "' CODATO, " + ;
			"'" + Space(HS_CfgSx3("GE7_URGDES", {"X3_TAMANHO"})[1]) + "' URGDES, " + ;
			"'" + Space(HS_CfgSx3("GE7_CODCRM", {"X3_TAMANHO"})[1]) + "' CODCRM "
	EndIf
  
	cSqlDesp += "FROM " + RetSqlName("GCZ") + " GCZ " + ;
		"INNER JOIN " + RetSqlName("GCS") + " GCS ON GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_FILIAL = " + HS_xFilFat("GCS") + " AND GCS.GCS_CODLOC = GCZ.GCZ_LOCATE " + ;
		"INNER JOIN " + RetSqlName("GE6") + " GE6 ON GE6.D_E_L_E_T_ <> '*' AND GE6.GE6_FILIAL = " + HS_xFilFat("GE6") + " AND GE6.GE6_GLODES = '0' AND GE6.GE6_REGATE = GCZ.GCZ_REGATE AND GE6.GE6_NRSEQG = GCZ.GCZ_NRSEQG " + ;
		"INNER JOIN " + RetSqlName("GAA") + " GAA ON GAA.D_E_L_E_T_ <> '*' AND GAA.GAA_FILIAL = " + HS_xFilFat("GAA") + " AND GAA.GAA_CODTXD = GE6.GE6_CODDES " + ;
		"INNER JOIN " + RetSqlName("GAW") + " GAW ON GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_FILIAL = " + HS_xFilFat("GAW") + " AND GAW.GAW_CODGDE = GAA.GAA_CODGDE " + ;
		"WHERE GCZ.GCZ_FILFAT = '" + cFilAnt + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_CANCEL <> '1'" + cSqlWhere + ;
		"UNION ALL "
             
	If nSql == 1
		cSqlDesp += "SELECT COUNT(*) NCNTDESP "
	Else
		cSqlDesp += "SELECT 'GE7' TABELA, GCZ.GCZ_FILIAL FILIAL, GCZ.GCZ_REGATE REGATE, GCZ.GCZ_NRSEQG NRSEQG, GCZ.GCZ_CODPLA CODPLA, GCZ.GCZ_NOME NOME, GCZ.GCZ_ATENDI ATENDI, " + ;
			"GCS.GCS_TIPLOC TIPLOC, " + ;
			"GE7.GE7_CODDES CODDES, GE7.GE7_SEQDES SEQDES, GE7.GE7_DATDES DATDES, GE7.GE7_HORDES HORDES, GE7.GE7_QTDDES QTDDES, " + HS_FValDes("GE7",, .F., cConRF == "1",,cConRF == "1") + " VALDES, " + ;
			"GE7.GE7_CODLOC CODLOC, GE7.GE7_CODPRT CDCONV, GE7.GE7_DESPRT DDCONV, " + ;
			"GA7.GA7_CODGDE CODGDE, GA7.GA7_TIPPRO TIPDES, GA7.GA7_DESC DDESPE, " + ;
			"'" + Space(HS_CfgSx3("B1_UM", {"X3_TAMANHO"})[1]) + "' UMDESP, " + ;
			"'" + Space(HS_CfgSx3("AH_UMRES", {"X3_TAMANHO"})[1]) + "' DESCUM, " + ;
			"GAW.GAW_DESC GDESPE, " + ;
			"GE7.GE7_VFILME VFILME, GA7.GA7_HONORA HONORA, GE7.GE7_PGTMED PGTMED, GE7.GE7_VALREP VALREP, GE7.GE7_CODVIA CODVIA, GE7.GE7_COEDES COEDES, GE7.GE7_CODATO CODATO, GE7.GE7_URGDES URGDES, GE7.GE7_CODCRM CODCRM "
	EndIf
   	                     
	cSqlDesp += "FROM " + RetSqlName("GCZ") + " GCZ " + ;
		"INNER JOIN " + RetSqlName("GCS") + " GCS ON GCS.D_E_L_E_T_ <> '*' AND GCS.GCS_FILIAL = " + HS_xFilFat("GCS") + " AND GCS.GCS_CODLOC = GCZ.GCZ_LOCATE " + ;
		"INNER JOIN " + RetSqlName("GE7") + " GE7 ON GE7.D_E_L_E_T_ <> '*' AND GE7.GE7_FILIAL = " + HS_xFilFat("GE7") + " AND GE7.GE7_GLODES = '0' AND GE7.GE7_PGTMED <> '0' AND GE7.GE7_REGATE = GCZ.GCZ_REGATE AND GE7.GE7_NRSEQG = GCZ.GCZ_NRSEQG " + ;
		"INNER JOIN " + RetSqlName("GA7") + " GA7 ON GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_FILIAL = " + HS_xFilFat("GA7") + " AND GA7.GA7_CODPRO = GE7.GE7_CODDES " + ;
		"INNER JOIN " + RetSqlName("GAW") + " GAW ON GAW.D_E_L_E_T_ <> '*' AND GAW.GAW_FILIAL = " + HS_xFilFat("GAW") + " AND GAW.GAW_CODGDE = GA7.GA7_CODGDE " + ;
		"WHERE GCZ.GCZ_FILFAT = '" + cFilAnt + "' AND GCZ.D_E_L_E_T_ <> '*' AND GCZ.GCZ_CANCEL <> '1'" + cSqlWhere + " "
              
	If nSql == 2
		cSqlDesp += "ORDER BY FILIAL, REGATE, NRSEQG, TABELA"
	EndIf
  
	cSqlDesp := ChangeQuery(cSqlDesp)
                  
	TCQuery cSqlDesp New Alias "TMPP18"
	 	 
	If nSql == 1
		While !Eof()
			nCntDesp += TMPP18->NCNTDESP
	   
			DbSkip()
		End
	  
		DbCloseArea()
		DbSelectArea("GAT")
	EndIf
	 
Next
	  							  	   
nContGuia := 0
 
ProcRegua(nCntDesp)
 
While !Eof()

	IncProc(STR0024) //"Aguarde, processando despesas"
   
	If TMPP18->TABELA == "GE7" // Procedimentos e Imagens
	 
		nUCntHsp := 0
		nUCntRep := 0
		nUCntDir := 0
		nUniCnt  := 0
		nDespGuia ++
		
		nTotDes := TMPP18->VALDES
   
		If cConRF == "0"
			nTotFil := TMPP18->QTDDES * TMPP18->VFILME
		Else
			nTotFil := TMPP18->VFILME
		EndIf
   		// MMM
		If cConRF == "0" /* 0-Faturas*/
			If TMPP18->HONORA == "1"
				If TMPP18->PGTMED <> "0" /* Se For Repasse soma no total da conta*/
					nTCntRep += NoRound(TMPP18->VALREP, 2)
					nUCntRep := NoRound(TMPP18->VALREP, 2)
					
					nTotCnt  += (nTotDes + nTotFil)
					nUniCnt  := (nTotDes + nTotFil)
				Else
					nTCntDir += NoRound(TMPP18->VALREP, 2)
					nUCntDir := NoRound(TMPP18->VALREP, 2)
				
					nTotCnt  += (nTotDes + nTotFil) - nUCntDir
					nUniCnt  := (nTotDes + nTotFil) - nUCntDir
				EndIf
			
				nTCntHsp += (nTotDes + nTotFil) - IIF(TMPP18->PGTMED <> "0", nUCntRep, nUCntDir)
				nUCntHsp := (nTotDes + nTotFil) - IIF(TMPP18->PGTMED <> "0", nUCntRep, nUCntDir)
			Else
				nTCntHsp += (nTotDes + nTotFil)
				nUCntHsp := (nTotDes + nTotFil)
 				
				nTotCnt  += (nTotDes + nTotFil)
				nUniCnt  := (nTotDes + nTotFil)
			EndIf
		
			If cModGF == "0"
				If GA9->GA9_TGERNF $ " 0" /* 0-Agrupados*/
					cAtendi := "0" /* Internações*/
				ElseIf GA9->GA9_TGERNF == "1" /* 1-Separados*/
					cAtendi := IIf(TMPP18->ATENDI $ " /0", "0", IIf(TMPP18->TIPLOC # "2", "1", "2"))
				ElseIf GA9->GA9_TGERNF == "2" /* 2-Inter.+Amb*/
					cAtendi := IIf(TMPP18->ATENDI $ " /0", "0", "1")
				EndIf
			Else
				cAtendi := "@"
			EndIf
			
			nPosProc := IIF(lSurenN5 .AND. AllTrim(TMPP18->CODGDE) $ cGrpImag,4,1) /*Se o grupo de despesa for de Imagens, assume posição 4*/
			If lHSPROP18
				cTesItem := Execblock("HSPROP18", .F., .F., cTesProc)
			Else
				cTesItem := IIf (nPosProc == 1, cTesProc, cTesImag)
			EndIf
		
			If cModGF == "0" /* 0=Sintetico*/
				If nPosProc == 1
					nPosVet  := aScan(aItensNF[nPosProc], {| aVet | aVet[1] == cSb1Proc .And. aVet[8] == cAtendi .And. aVet[9] == cTesItem})
				Else
					nPosVet  := aScan(aItensNF[nPosProc], {| aVet | aVet[1] == cSb1Imag .And. aVet[8] == cAtendi .And. aVet[9] == cTesItem})
				EndIf
				If nPosVet == 0
					If GA9->GA9_TGERNF $ " 0"
						aAdd(aItensNF[nPosProc], {cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + GAT->GAT_DESCOM, nTamDesc), "1", cAtendi, cTesItem})
					Else
						aAdd(aItensNF[nPosProc], {cSb1Proc, 0, 0, 0, 0, PadR(AllTrim(cSb1DescPr) + " - " + HS_RDescrB("GCS_TIPLOC", TMPP18->TIPLOC) + " - " + GAT->GAT_DESCOM, nTamDesc), "1", cAtendi, cTesItem})
					EndIf
					nPosVet := Len(aItensNF[nPosProc])
				EndIf
			
				aItensNF[nPosProc][nPosVet][2] += nUCntHsp
				aItensNF[nPosProc][nPosVet][3] += nUCntRep
				aItensNF[nPosProc][nPosVet][4] += nUCntDir
				aItensNF[nPosProc][nPosVet][5] += nUniCnt
			ElseIf cModGF $ "12" /* 1=Analitico ou 2-Grupo de Despesas*/
				nPosVet := aScan(aItensNF, {| aVet | aVet[1] == IIf(cModGF == "1", TMPP18->CODDES, TMPP18->CODGDE) .And. aVet[9] == cTesItem})
				If nPosVet == 0
					aAdd(aItensNF, {IIf(cModGF == "1", TMPP18->CODDES, TMPP18->CODGDE), 0, 0, 0, 0, IIf(cModGF == "1", TMPP18->DDESPE, TMPP18->GDESPE), "1", cAtendi, cTesItem})
					nPosVet := Len(aItensNF)
				EndIf
				aItensNF[nPosVet][2] += nUCntHsp
				aItensNF[nPosVet][3] += nUCntRep
				aItensNF[nPosVet][4] += nUCntDir
				aItensNF[nPosVet][5] += nUniCnt
			EndIf
		Else /* 1-Remessa*/
			aTabPre := HS_RTabPre("GC6", TMPP18->CODPLA, TMPP18->CODDES, SToD(TMPP18->DATDES)) // Tabela de preço
			If Len(aTabPre) == 0
				HS_MsgInf(STR0091 + TMPP18->CODPLA + STR0092 + TMPP18->NRSEQG + STR0093 + TMPP18->CODDES + "]", STR0008, STR0089) //"Não foi possivel encontrar a tabela de preços do plano ["###"] da guia ["###"] para o procedimento ["###"Atenção"###"Remessa"
				nContGuia := 0
				Return(Nil)
			Else
				cCodPan := HS_CodPan(TMPP18->CODDES, aTabPre[1], SToD(TMPP18->DATDES)) // Codigo do Porte Anestesico
			EndIf
   
			If Empty(cCodPan)
				cGr0TipCir := StrZero(0, Len(GR0->GR0_TIPCIR))
			ElseIf Empty(TMPP18->CODVIA)
				cGr0TipCir := StrZero(1, Len(GR0->GR0_TIPCIR))
			ElseIf TMPP18->COEDES == (HS_RPerVA(TMPP18->CODDES, ">") / 100)
				cGr0TipCir := StrZero(1, Len(GR0->GR0_TIPCIR))
			ElseIf TMPP18->COEDES == (HS_RPerVA(TMPP18->CODDES, "=") / 100)
				cGr0TipCir := StrZero(2, Len(GR0->GR0_TIPCIR))
			ElseIf TMPP18->COEDES == (HS_RPerVA(TMPP18->CODDES, "#") / 100)
				cGr0TipCir := StrZero(3, Len(GR0->GR0_TIPCIR))
			EndIf
       
			If TMPP18->HONORA == "1" .And. TMPP18->PGTMED == "0" /* Pagamento direto retirado do valor da despesa*/
				nTotDes -= NoRound(TMPP18->VALREP, 2)
			EndIf
			
			If nTotDes > 0
				aAdd(aItensNF, {TMPP18->REGATE, TMPP18->NRSEQG, SToD(TMPP18->DATDES), TMPP18->HORDES, IIf(TMPP18->URGDES == "1", "S", "N"), TMPP18->CODDES, ;
					"P", TMPP18->DDESPE, STR0025, TMPP18->QTDDES, nTotDes, TMPP18->TIPDES, TMPP18->CODLOC, TMPP18->CODATO, ;
					TMPP18->CDCONV, TMPP18->DDCONV, TMPP18->CODCRM, cGr0TipCir, Round(TMPP18->QTDDES * nTotDes, 2)}) //"Unidade "
			EndIf
			
			If nTotFil > 0
				aAdd(aItensNF, {TMPP18->REGATE, TMPP18->NRSEQG, SToD(TMPP18->DATDES), TMPP18->HORDES, IIf(TMPP18->URGDES == "1", "S", "N"), TMPP18->CODDES, ;
					"F", TMPP18->DDESPE, STR0026, TMPP18->QTDDES, nTotFil, TMPP18->TIPDES, TMPP18->CODLOC, TMPP18->CODATO, ;
					TMPP18->CDCONV, TMPP18->DDCONV, TMPP18->CODCRM, cGr0TipCir, Round(TMPP18->QTDDES * nTotFil, 2)}) //"Unidade "
			EndIf
		EndIf
	
	ElseIf TMPP18->TABELA == "GE6" // Taxas e Diarias
	
		nDespGuia ++
		 
		If cConRF == "0"
			nUCntHsp := TMPP18->VALDES
			nTCntHsp += nUCntHsp
			
			nTotCnt  += nUCntHsp
			nUniCnt  := nUCntHsp
			
			If cModGF == "0" /* 0=Sintetico*/
				If GA9->GA9_TGERNF $ " 0" /* 0-Agrupados*/
					aItensNF[2][1][2] += nUCntHsp
					aItensNF[2][1][5] += nUniCnt
				ElseIf GA9->GA9_TGERNF == "1" /* 1-Separados*/
					If TMPP18->ATENDI == "0" /* 0-Internação*/
						aItensNF[2][1][2] += nUCntHsp
						aItensNF[2][1][5] += nUniCnt
					Else
						If TMPP18->TIPLOC # "2" /* 2-Pronto Atendimento*/
							aItensNF[2][2][2] += nUCntHsp
							aItensNF[2][2][5] += nUniCnt
						Else
							aItensNF[2][3][2] += nUCntHsp
							aItensNF[2][3][5] += nUniCnt
						EndIf
					EndIf
				ElseIf GA9->GA9_TGERNF == "2" /* 2-Intern.+Amb*/
					If TMPP18->ATENDI == "0" /* 0-Internação*/
						aItensNF[2][1][2] += nUCntHsp
						aItensNF[2][1][5] += nUniCnt
					Else
						aItensNF[2][2][2] += nUCntHsp
						aItensNF[2][2][5] += nUniCnt
					EndIf
				EndIf
    
			ElseIf cModGF $ "12" /* 1=Analitico ou 2=Grupo de Despesas*/
				nPosVet := aScan(aItensNF, {| aVet | aVet[1] == IIf(cModGF == "1", TMPP18->CODDES, TMPP18->CODGDE)})
				If nPosVet == 0
					aAdd(aItensNF, {IIf(cModGF == "1", TMPP18->CODDES, TMPP18->CODGDE), 0, 0, 0, 0, IIf(cModGF == "1", TMPP18->DDESPE, TMPP18->GDESPE), "2", "@", cTesTaxD})
					nPosVet := Len(aItensNF)
				EndIf
				aItensNF[nPosVet][2] += nUCntHsp
				aItensNF[nPosVet][5] += nUniCnt
			Endif
		Else
			aAdd(aItensNF, {TMPP18->REGATE, TMPP18->NRSEQG, SToD(TMPP18->DATDES), TMPP18->HORDES, "N", TMPP18->CODDES, "T", TMPP18->DDESPE, STR0102, ; //"Unidade "
			TMPP18->QTDDES, TMPP18->VALDES, TMPP18->TIPDES, TMPP18->CODLOC, "", TMPP18->CDCONV, TMPP18->DDCONV, "", "000", Round(TMPP18->QTDDES * TMPP18->VALDES, 2)})
		EndIf
		
	ElseIf TMPP18->TABELA == "GE5" // Materiais e Medicamentos
   
		nDespGuia ++
   
		If cConRF == "0"
			nUCntHsp := TMPP18->VALDES
			nTCntHsp += nUCntHsp
 			
			nTotCnt  += nUCntHsp
			nUniCnt  := nUCntHsp
			
			If cModGF == "0" /* 0=Sintetico */
				If GA9->GA9_TGERNF $ " 0" /* 0-Agrupados */
					aItensNF[3][1][2] += nUCntHsp
					aItensNF[3][1][5] += nUniCnt
				ElseIf GA9->GA9_TGERNF == "1" /* 1-Separados */
					If TMPP18->ATENDI == "0" /* 0-Internação */
						aItensNF[3][1][2] += nUCntHsp
						aItensNF[3][1][5] += nUniCnt
					Else
						If TMPP18->TIPLOC # "2" /* 2-Pronto Atendimento */
							aItensNF[3][2][2] += nUCntHsp
							aItensNF[3][2][5] += nUniCnt
						Else
							aItensNF[3][3][2] += nUCntHsp
							aItensNF[3][3][5] += nUniCnt
						EndIf
					EndIf
				ElseIf GA9->GA9_TGERNF == "2" /* 2-Intern.+Amb */
					If TMPP18->ATENDI == "0" /* 0-Internação */
						aItensNF[3][1][2] += nUCntHsp
						aItensNF[3][1][5] += nUniCnt
					Else
						aItensNF[3][2][2] += nUCntHsp
						aItensNF[3][2][5] += nUniCnt
					EndIf
				EndIf
			ElseIf cModGF $ "12" /* 1=Analitico ou 2-Grupo de Despesas */
				nPosVet := aScan(aItensNF, {| aVet | aVet[1] == IIf(cModGF == "1", TMPP18->CODDES, TMPP18->CODGDE)})
				If nPosVet == 0
					aAdd(aItensNF, {IIf(cModGF == "1", TMPP18->CODDES, TMPP18->CODGDE), 0, 0, 0, 0, IIf(cModGF == "1", TMPP18->DDESPE, TMPP18->GDESPE), "0", "@", cTesMatM})
					nPosVet := Len(aItensNF)
				EndIf
				aItensNF[nPosVet][2] += nUCntHsp
				aItensNF[nPosVet][5] += nUniCnt
			Endif
		Else
			cUnidade := TMPP18->DESCUM
			aAdd(aItensNF, {TMPP18->REGATE, TMPP18->NRSEQG, SToD(TMPP18->DATDES), TMPP18->HORDES, "N", TMPP18->CODDES, "M", TMPP18->DDESPE, cUnidade, ;
				TMPP18->QTDDES, TMPP18->VALDES, TMPP18->TIPDES, TMPP18->CODLOC, "", TMPP18->CDCONV, TMPP18->DDCONV, "", "000", Round(TMPP18->QTDDES * TMPP18->VALDES, 2)})
		EndIf
	
	EndIf
  
	cNome   := TMPP18->NOME
	cRegAte := TMPP18->REGATE
	cNrSeqG := TMPP18->NRSEQG
	cFil    := TMPP18->FILIAL
	
	DbSelectArea("TMPP18")
	DbSkip()
  
	If (cFil <> TMPP18->FILIAL .Or. cRegAte <> TMPP18->REGATE .Or. cNrSeqG <> TMPP18->NRSEQG)
  
		nContGuia++
   
	EndIf
    
	If cConRF == "0" .And. (cFil <> TMPP18->FILIAL .Or. cRegAte <> TMPP18->REGATE .Or. cNrSeqG <> TMPP18->NRSEQG)
   
		/* aCntGF[n][1] Registro de atendimento */
		/* aCntGF[n][2] Numero sequencial da guia */
		/* aCntGF[n][3] Total do hospital*/
		/* aCntGF[n][4] Total a repassar aos médicos */
		/* aCntGF[n][5] Total do repasse pago direto pelo convenio */
		/* aCntGF[n][6] Total a receber = nTotCnt + nTCntHsp + nTCntRep - nTCntDir */
		/* aCntGF[n][7] Numero do Lote */
		/* aCntGF[n][8] Filial da guia */
			
		aAdd(aCntGF, {cRegAte, cNrSeqG, nTCntHsp, nTCntRep, nTCntDir, nTotCnt, cLote, cFil})
	   
		cLinha := cFil + " " + cRegAte + " " + cNome + " " + cNrSeqG + " " + ;
			Transform(nTCntHsp, "@E 999,999,999.99") + " " + ;
			Transform(nTCntRep, "@E 999,999,999.99") + " " + ;
			Transform(nTCntDir, "@E 999,999,999.99") + " " + ;
			Transform(nTotCnt , "@E 999,999,999.99") + Chr(13) + Chr(10)
			
		fWrite(nHdlGF, cLinha, Len(cLinha))
	                                                  
		nTCntHsp := 0
		nTCntRep := 0
		nTCntDir := 0
		nTotCnt  := 0
	EndIf
  
End
                             
If cConRF == "0"
	fClose(nHdlGF)
EndIf

 //Desbloquear somente para testar tempo de processamento da rotina
 //HS_MsgInf("Hora Inicial [" + cHoraIni + "] Hora Final [" + Time() + "] Tempo gasto [" + HS_TotHoras(cHoraIni, Time(), "-", .T., .F.) + "]", "Atenção", "Despesas")

DbSelectArea("TMPP18")
DbCloseArea()
 
HS_ResArea(aArea)
DbSelectArea(cAliasOld)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_ItensNFº Autor ³                    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ItensNF(aItensNF, aCntGF, cConRF, cModGF)
 Local bCampo        := {|nCPO| Field(nCPO)}
 Local oGetDados     := nil
 Local oDlg          := nil
 Local nTotal        := 0
 Local nUsado        := 0
 Local nOpcA         := 0
 Local nItem         := 0
 Local nForAux       := 0
 Local cTitulo       := OemToAnsi(STR0094) //"Lote"
 Local cDescr        := ""
 Local aRetGF        := {.F., "", ""}
 Local nCntGF        := 0
 Local oNTotal       := nil
 Local oCPagHsp      := nil
 Local nTamDesc      := TamSx3("C6_DESCRI")[1]
 Local aVetAux       := {}
 Local nCDecTot      := 2
 
 Local nGR0_REGATE   := 0
 Local nGR0_NRSEQG   := 0
 Local nGR0_DATSER   := 0
 Local nGR0_HORDES   := 0
 Local nGR0_URGDES   := 0
 Local nGR0_CODSER   := 0
 Local nGR0_TIPSER   := 0
 Local nGR0_DESSER   := 0
 Local nGR0_UMDESC   := 0
 Local nGR0_QTDSER   := 0
 Local nGR0_VALSER   := 0
 Local nGR0_VALTOT   := 0
 Local nGR0_TIPPRO   := 0
 Local nGR0_CODLOC   := 0
 Local nGR0_CODATO   := 0
 Local nGR0_CPPLAN   := 0
 Local nGR0_DPPLAN   := 0
 Local nGR0_CODCRM   := 0
 Local nGR0_TIPCIR   := 0

 Local oCpoDescVlr   := nil
 Local iCpoDesVlr    := 0
 Local oCpoDescPerc  := nil
 Local iCpoDesPerc   := 0
 Local oCpoDescDescr := nil
 Local oCpoNature    := nil

 Local cCpoDescDescr := SPACE(40)
 Local aHNF          := {}
 Local aCNF          := {}
 Local cNatura       := SPACE( TamSx3("A1_NATUREZ")[1] )
 Local lRetGF        := .F.
 Local nValPiso      := IIF(HS_ExisDic({{"C", "GA9_VLPISO"}}, .F.), GA9->GA9_VLPISO, 0)
 Local nValDif       := 0
 Local cCndPag       := IIF(HS_ExisDic({{"C", "GA9_CNDPAG"}}, .F.), GA9->GA9_CNDPAG, "")
  
 Local cCodSExt      := "", cDesSExt := ""
 Local nPos          := 0,  nPosGrp  := 0
 Local lOkNF         := .F. 
 Local cSerie        := GetMV("MV_HSPSERI")
 Local lNfsTela		 := SuperGetMV("MV_NFSTELA", .F., .F.)
 Local nTamSer		 := TamSX3("E1_SERIE")[1]
 Local nTamPre		 := TamSX3("E1_PREFIXO")[1]
 Local nTamTot		 := nTamSer + nTamPre + 1
 Local lReturn       := .F.
 
 Private cPagHsp     := IIF(!Empty(cCndPag), cCndPag, PadR(GetMV("MV_CPAGHSP"), TamSx3("E4_CODIGO")[1]))    /* Condicao de pgto padrao netre GHSP/LOJA BALCAO E FATURAMENTO*/
 Private Inclui      := .F.
 Private Altera      := .T.
 Private cCtrlNota   := SuperGetMV("MV_TPNRNFS")
 
 If Len(aItensNF) == 0
  MsgStop(STR0078) //"Despesas nao encontradas"
  Return({.F., "", ""})
 EndIf

 If cConRF == "0"
  aAdd(aHNF, {STR0079, "nValHsp", "@E 999,999,999.99",       12, nCDecTot, ".F.", "", "N", "xxx", "V", "", ""})  //"Hospital"
  aAdd(aHNF, {STR0080, "nValRep", "@E 999,999,999.99",       12, nCDecTot, ".F.", "", "N", "xxx", "V", "", ""})  //"Repasse"
  aAdd(aHNF, {STR0081, "nValDir", "@E 999,999,999.99",       12, nCDecTot, ".F.", "", "N", "xxx", "V", "", ""})  //"Direto"
  aAdd(aHNF, {STR0082, "nValTot", "@E 999,999,999.99",       12, nCDecTot, ".F.", "", "N", "xxx", "V", "", ""})  //"Total"
  aAdd(aHNF, {STR0083, "cDesIte", "@!"               , nTamDesc,        0, ".T.", "", "C", "xxx", "V", "", ""})  //"Descricao"
  aAdd(aHNF, {STR0103 , "cCodIte", "@!"               ,       15,        0, ".F.", "", "C", "xxx", "V", "", ""})  //"Item"
  aAdd(aHNF, {STR0104  , "cCodTes", "@!"               ,       03,        0, ".T.", "", "C", "xxx", "V", "", ""})  //"TES"
 Else
  HS_BDados("GR0", @aHNF, @aCNF, @nUsado, 1)
  
  nGR0_REGATE := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_REGATE"})
  nGR0_NRSEQG := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_NRSEQG"})
  nGR0_DATSER := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_DATSER"})
  nGR0_HORDES := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_HORDES"})
  nGR0_URGDES := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_URGDES"})
  nGR0_CODSER := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_CODSER"})
  nGR0_TIPSER := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_TIPSER"})
  nGR0_DESSER := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_DESSER"})
  nGR0_UMDESC := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_UMDESC"})
  nGR0_QTDSER := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_QTDSER"})
  nGR0_VALSER := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_VALSER"})
  nGR0_VALTOT := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_VALTOT"})
  nGR0_TIPPRO := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_TIPPRO"})
  nGR0_CODLOC := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_CODCCU"})
  nGR0_CODATO := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_CODATO"})
  nGR0_CPPLAN := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_CPPLAN"})
  nGR0_DPPLAN := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_DPPLAN"})
  nGR0_CODCRM := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_CODCRM"})
  nGR0_TIPCIR := aScan(aHNF, {| aVet | AllTrim(Upper(aVet[2])) == "GR0_TIPCIR"})
 EndIf

 nUsado := Len(aHNF)
 nTotal := 0
 aCNF  := {}
 If cConRF == "0"
  For nItem := 1 To Len(aItensNF)
   If cModGF == "0" /*  0=Sintetico*/
    For nForAux := 1 To Len(aItensNF[nItem])
     aAdd(aCNF, {aItensNF[nItem][nForAux][2], aItensNF[nItem][nForAux][3], aItensNF[nItem][nForAux][4], aItensNF[nItem][nForAux][5], aItensNF[nItem][nForAux][6], aItensNF[nItem][nForAux][1], aItensNF[nItem][nForAux][9], .F.})
     nTotal += Round(aItensNF[nItem][nForAux][5], nCDecTot)
     aAdd(aVetAux, aItensNF[nItem][nForAux])
    Next
   Else
    aAdd(aCNF, {aItensNF[nItem][2], aItensNF[nItem][3], aItensNF[nItem][4], aItensNF[nItem][5], aItensNF[nItem][6], aItensNF[nItem][1], aItensNF[nItem][9], .F.})
    nTotal += Round(aItensNF[nItem][5], nCDecTot)
    aAdd(aVetAux, aItensNF[nItem])
   EndIf
   
  Next

  //Registra o valor total a ser cobrado de acordo com o piso
  If nTotal < nValPiso
   nValDif := nValPiso - nTotal
     nTotal := nValPiso 
   If cModGF == "0" //0=Sintetico
    If (nPos := aScan(aCNF, {|aVet| aVet[6] == cSb1SExt .And. aVet[7] == cTesSExt})) == 0
     nPos := Len(aCNF)
    EndIf 
    aCNF[nPos, 1] += nValDif
    aCNF[nPos, 4] += nValDif
    aVetAux[nPos, 2] += nValDif
    aVetAux[nPos, 5] += nValDif    
   ElseIf cModGF $ "12" //1=Analitico 2=Grp desp.
    cCodSExt := IIf(cModGF == "1", cSb1SExt, HS_IniPadR("GBI", 1, cSb1SExt, "GBI_CODGDE")) 
    cDesSExt := IIf(cModGF == "1", cSb1DescSE, HS_IniPadR("GAW", 1, cCodSExt, "GAW_DESC"))
    
    If cModGF == "2" .And. GA9->GA9_TGERNF $ " 0" .And. (nPosGrp := aScan(aCNF, {|aVet| aVet[6] == cCodSExt .And. aVet[7] == cTesSExt})) > 0//Grp Despes e Agrupados
     aCNF[nPosGrp, 1] += nValDif
     aCNF[nPosGrp, 4] += nValDif
     aVetAux[nPosGrp, 2] += nValDif
     aVetAux[nPosGrp, 5] += nValDif
    Else
     aAdd(aCNF, {nValDif, 0, 0, nValDif, PadR(cDesSExt, nTamDesc), cCodSExt, cTesSExt, .F.})
     aAdd(aVetAux, {cCodSExt, nValDif, 0, 0, nValDif, PadR(cDesSExt, nTamDesc), "X", "0", cTesSExt})
    EndIf 
   EndIf
  EndIf
   
  aItensNF := aVetAux
 Else
   
  For nItem := 1 To Len(aItensNF)
     
   aAdd(aCNF, Array(nUsado + 1))
   aCNF[nItem][nGR0_REGATE] := aItensNF[nItem][01]
   aCNF[nItem][nGR0_NRSEQG] := aItensNF[nItem][02]
   aCNF[nItem][nGR0_DATSER] := aItensNF[nItem][03]
   aCNF[nItem][nGR0_HORDES] := aItensNF[nItem][04]
   aCNF[nItem][nGR0_URGDES] := aItensNF[nItem][05]
   aCNF[nItem][nGR0_CODSER] := aItensNF[nItem][06]
   aCNF[nItem][nGR0_TIPSER] := aItensNF[nItem][07]
   aCNF[nItem][nGR0_DESSER] := aItensNF[nItem][08]
   aCNF[nItem][nGR0_UMDESC] := aItensNF[nItem][09]
   aCNF[nItem][nGR0_QTDSER] := aItensNF[nItem][10]
   aCNF[nItem][nGR0_VALSER] := aItensNF[nItem][11]
   aCNF[nItem][nGR0_TIPPRO] := aItensNF[nItem][12]
   aCNF[nItem][nGR0_CODLOC] := aItensNF[nItem][13]
   aCNF[nItem][nGR0_CODATO] := aItensNF[nItem][14]
   aCNF[nItem][nGR0_CPPLAN] := aItensNF[nItem][15]
   aCNF[nItem][nGR0_DPPLAN] := aItensNF[nItem][16]
   aCNF[nItem][nGR0_CODCRM] := aItensNF[nItem][17]
   aCNF[nItem][nGR0_TIPCIR] := aItensNF[nItem][18]
   aCNF[nItem][nGR0_VALTOT] := aItensNF[nItem][19]
   aCNF[nItem][nUsado + 1 ] := .F.
		                                                                       
		 //Verificar,,,,,com este calculo da diferenca de centavos
   nTotal += Round(aItensNF[nItem][19], nCDecTot)
   
  Next
         
 EndIf

 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("SC5")
 While !Eof() .And. SX3->X3_ARQUIVO == "SC5"
  &("M->" + SX3->X3_CAMPO) := CriaVar(SX3->X3_CAMPO)
  DbSkip()
 Enddo

 aSize    := MsAdvSize(.T.) 
 aObjects := {}
 AAdd( aObjects, { 100, 50, .T., .T. } ) /*  GETDADOS*/
 AAdd( aObjects, { 100, 10, .T., .T. } ) /*  ESPACO ENTRE GETDADOS E SAY*/
 AAdd( aObjects, { 100, 10, .T., .T. } ) /*  SAY*/
 AAdd( aObjects, { 100, 10, .T., .T. } ) /*  SAY*/
 AAdd( aObjects, { 100, 10, .T., .T. } ) /*  SAY*/ 
 AAdd( aObjects, { 100, 10, .T., .T. } ) /*  SAY*/  
 aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
 aPObj    := MsObjSize( aInfo, aObjects, .T. )

 cNatura := HS_IniPadr("SA1", 1, GA9->GA9_CODCLI + GA9->GA9_LOJA, "A1_NATUREZ",, .F.)
 
 DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel

 oGetDados := MsNewGetDados():New(aPObj[1,1]+5,aPObj[1,2],aPObj[1,3],aPObj[1,4], GD_UPDATE,,,,,, Len(aCNF),,,, oDlg, aHNF, aCNF)

 @ aPobj[3,1], 005 Say OemToAnsi(STR0027 ) OF oDlg PIXEL COLOR CLR_BLUE //"TOTAL DA FATURA / REMESSA"
 @ aPobj[3,1], 090 MSGet oNTotal var nTotal Picture "@E 9,999,999.99" OF oDlg PIXEL When .F.
 
 If cConRF == "0"
  @ aPobj[3,1], 160 Say OemToAnsi(STR0028) OF oDlg PIXEL COLOR CLR_BLUE //"Condicao de pagamento"
  @ aPobj[3,1], 230 MSGet oCPagHsp var cPagHsp Picture "@!" F3 "SE4" Valid FS_DataT9(nTotal) OF oDlg PIXEL COLOR CLR_BLACK
 EndIf

 @ aPobj[4,1], 005 Say OemToAnsi(STR0029) OF oDlg PIXEL  COLOR CLR_BLUE //"Valor Desconto"
 @ aPobj[4,1], 090 MSGet oCpoDescVlr var iCpoDesVlr Picture "@E 9,999,999.99" OF oDlg PIXEL

 @ aPobj[4,1], 160 Say OemToAnsi(STR0030) OF oDlg PIXEL  COLOR CLR_BLUE //"Percent. Desconto"
 @ aPobj[4,1], 230 MSGet oCpoDescPerc var iCpoDesPerc Picture "@E 999.99" OF oDlg PIXEL

 @ aPobj[5,1], 005 Say OemToAnsi(STR0031) OF oDlg PIXEL  COLOR CLR_BLUE //"Descricao Desconto"
 @ aPobj[5,1], 090 MSGet oCpoDescDescr var cCpoDescDescr Size 210, 10 OF oDlg PIXEL

 @ aPobj[6,1], 005 Say OemToAnsi(STR0105) OF oDlg PIXEL  COLOR CLR_BLUE   //"Natureza"
 @ aPobj[6,1], 090 MSGet oCpoNature var cNatura Picture "@!" F3 "SED" OF oDlg PIXEL

 ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpcA := 1, IIF(FS_VldNat(cNatura) .And. FS_DataT9(nTotal), oDlg:End(),nOpcA := 0)}, ;
 																																																 {|| nOpcA := 0, oDlg:End()})

 If nOpcA == 1
 	If lNfsTela
		If cConRF == "0" .And. GA9->GA9_GERANF == "0" .And. Sx5NumNota(@cSerie, cCtrlNota)
			lOkNF := .T.
		EndIf
	ElseIf Len(cSerie) <= nTamSer
		If cConRF == "0" .And. GA9->GA9_GERANF == "0"
			lOkNF := .T.
		EndIf
	Else
		MsgStop('Informe apenas uma série no parâmetro MV_HSPSERI')
		lOkNF := .F.
	EndIf
  Begin Transaction
  
   If cConRF == "0" /*  Fatura*/
    
    If GA9->GA9_GERANF == "0" .And. !lOkNF
     DisarmTransaction()
	 lReturn := .T.
    EndIf

   If !lReturn    
    Processa({|| aRetGF := FS_GeraNF(aItensNF,iCpoDesVlr,iCpoDesPerc,cCpoDescDescr,cNatura, cSerie)})
 
    If (lRetGF := aRetGF[1])
     /*  Grava Status e Dados das Faturas no GCZ (Guias  de Atendimento)*/
     cLote := ""
     For nCntGF := 1 to Len(aCntGF)
      DBSelectArea("GCZ")
      DbSetorder(1)
      If DbSeek(aCntGF[nCntGF, 8] + aCntGF[nCntGF, 2])
  
       RecLock("GCZ", .F.)
       GCZ->GCZ_STATUS := "4"
       GCZ->GCZ_DATSTA := dDatabase
       GCZ->GCZ_DATFAT := dDatabase
       GCZ->GCZ_HORFAT := Time()
       GCZ->GCZ_NRFATU := aRetGF[2]
       GCZ->GCZ_NRNOTA := aRetGF[2]
       GCZ->GCZ_SERIE  := aRetGF[3]
       If FieldPos("GCZ_TPNOTA") > 0
        GCZ->GCZ_TPNOTA := aRetGF[4]
       EndIf 
       GCZ->GCZ_VLGUIA := aCntGF[nCntGF, 6]
       MsUnlock()
	 				
       /*  Grava o numero do processo no GAT*/
       If cLote != GCZ->GCZ_NRLOTE
        cLote := GCZ->GCZ_NRLOTE
        DbSelectArea("GAT")
        DbSetOrder(2)
       
        If DbSeek(xFilial("GAT") + GCZ->GCZ_CODCON + GCZ->GCZ_NRLOTE)
         RecLock("GAT",.F.)
          GAT->GAT_NUMPRO := cProcesso
          GAT->GAT_NRFATU := aRetGF[2]
          GAT->GAT_SERIE  := aRetGF[3]
          GAT->GAT_MESREF := cMesRef
          GAT->GAT_DTFTLT := dDataBase
         MsUnlock()
        EndIf
       EndIf
      EndIf
     Next
  
    Else
     DisarmTransaction()
    EndIf
  
   Else
  
   Processa({|| aRetGF := FS_GeraRe(nUsado, oGetDados)})

  
   EndIf
  EndIf
  End Transaction
  
  If lRetGF
  
   If GA9->GA9_GERANF == '0' /*  0-titulo e nota fiscal*/
    MsgStop(STR0032 + aRetGF[2] + STR0033 + aRetGF[3], STR0008) //"Nota Gerada: "###" Série "###"Atenção"
   Else
    MsgStop(STR0034 + aRetGF[2] + STR0035 + aRetGF[3], STR0008) //"Título Gerado: "###" Prefixo "###"Atenção"
   EndIf
  
  EndIf

 Else

  aRetGF := {.F., "", ""}

 EndIf

Return(aRetGF)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_gerare º Autor ³                    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GeraRe(nUsado, oGetDados)
 Local cSql := "", nItens := 0, cAliasOld := Alias()

 DbSelectArea("GR0")    /*  Tabela de Remessa para Convenio*/
 /*  Remove movimentação anterior*/
 ProcRegua(Len(oGetDados:aCols) + 1)
 
 IncProc(STR0036) //"Removendo movimentacao de remessa anterior"
 
 cSql := "DELETE FROM " + RetSqlName("GR0") + " WHERE GR0_FILIAL = '" + xFilial("GR0") + "'"
 TCSqlExec(cSql)
  
 For nItens := 1 To Len(oGetDados:aCols)
  IncProc(STR0037) //"Adicionando movimentacao da nova remessa"
  If !oGetDados:aCols[nItens, nUsado + 1]
   RecLock("GR0", .T.)
    GR0->GR0_FILIAL := xFilial("GR0")
   HS_GrvCpo("GR0", oGetDados:aCols, oGetDados:aHeader, nItens)
   MsUnLock()
  EndIf
 Next

 DbSelectArea(cAliasOld)
Return({.T., "", ""})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GeraNf º Autor ³                    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_GeraNF(aItensNF,iCpoDesVlr,iCpoDesPerc,cCpoDescDescr,cNatura, cSerie)
Local nMVNumParc := GetMV("MV_NUMPARC")
Local nParcAtu   := 0
Local cParcela   := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local lGravou    := .F.
Local cNumPed    := ""
Local cNumNFs    := ""
Local cAliasOld  := Alias()
Local cCodVend   := AllTrim(GetMV("MV_VENDHSP"))
Local cTes       := ""
Local cTesMV     := AllTrim(GetMV("MV_TESNFS"))
Local aCabPV     := {}
Local aItensPV   := {}
Local aItensPV1  := {}
Local cItem      := Replicate("0", Len(SC6->C6_ITEM))
Local nItem      := 0
Local cCodPro    := ""
Local aPvlNfs    := {}
Local cChavSC9   := ""
Local aParcelas  := {}
Local aTit       := {}
Local nValTot    := 0
Local nI         := 0
Local cNumTit    := ""
Local cPrfTit    := ""
Local cTipoTit   := ""
Local cCliTit    := ""
Local cLojaTit   := ""
Local cNatTit    := ""
Local cHisTit    := ""
Local cParcTit   := SPACE(TAMSX3("E1_PARCELA")[1])
Local nValDesc   := 0
Local lTitOk     := .f.
Local bAtuSE1    := {|nRecNo| dbSelectArea("SE1"), MsGoto(nRecNo), RecLock("SE1", .F.), SE1->E1_ORIGEM := 'HSPAHP18', SE1->E1_HIST := cHisTit, SE1->E1_NATUREZ := cNatura, MsUnLock()}
Local dMvUlmes   := GETMV("MV_ULMES")
Local lSurenN5 	:= GetNewPar("MV_SURENN5",.F.)

Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

/*  Registra o valor total a ser cobrado*/
For nI := 1 to Len( aItensNF )
	nValTot += aItensNF[nI,5]
Next

If Empty(GA9->GA9_CODCLI)
	MsgStop(STR0038 + AllTrim(GA9->GA9_CODCON) + "-" + AllTrim(GA9->GA9_NREDUZ) + STR0039, STR0008) //"Código do cliente no cadastro do Convenio "###" está em branco"###"Atenção"
	DbSelectArea(cAliasOld)
	Return({.F., "", "", ""})
EndIf

If !Empty(dMvUlmes) .AND. (dDatabase <= dMvUlmes)
	HS_MsgInf(STR0111,STR0001,STR0057) //"Data de emissão nao pode ser igual ou menor que a data de fechamento do estoque"###"Geração de Faturas"###"Gerando nota fiscal de venda"
	DbSelectArea(cAliasOld)
	Return({.F., "", "", ""})
EndIf
DbSelectArea("SA1")
DbSetOrder(1)
If !DbSeek(xFilial("SA1") + PadR(AllTrim(GA9->GA9_CODCLI), Len(SA1->A1_COD)) + PadR(AllTrim(GA9->GA9_LOJA), Len(SA1->A1_LOJA)))
	MsgStop(STR0040 + GA9->GA9_CODCLI + STR0041 + GA9->GA9_LOJA + STR0042, STR0008) //"Codigo do convenio como cliente"###"Loja"###"Não encontrado no cadastro de clientes"###"Atenção"
	DbSelectArea(cAliasOld)
	Return({.F., "", "", ""})
EndIf

DbSelectArea("SF4")
DbSetOrder(1)
If !DbSeek(xFilial("SF4") + PadR(cTesMV, Len(SF4->F4_CODIGO)))
	MsgStop(STR0046 + cTesMV + STR0047, STR0008 ) //"TES "###" definido no parametro MV_TESNFS não encontrado"###"Atenção"
	DbSelectArea(cAliasOld)
	Return({.F., "", "", ""})
EndIf

DbSelectArea("SE4")
DbSetOrder(1)
If !DbSeek(xFilial("SE4") + PadR(cPagHsp, Len(SE4->E4_CODIGO)))
	MsgStop(STR0048 + cPagHsp + STR0049, STR0008) //"Condição de Pagamento "###" definido no parametro MV_CPAGHSP não encontrada"###"Atenção"
	DbSelectArea(cAliasOld)
	Return({.F., "", "", ""})
EndIf

DbSelectArea("SA3")
DbSetOrder(1)
If !DbSeek(xFilial("SA3") + PadR(cCodVend, Len(SA3->A3_COD)))
	MsgStop(STR0050 + cCodVend + STR0051, STR0008) //"Vendedor "###" definido no parametro MV_VENDHSP não encontrado"###"Atenção"
	DbSelectArea(cAliasOld)
	Return({.F., "", "", ""})
EndIf

/*  Gera somente titulo*/
If GA9->GA9_GERANF == "1" /*  1-somente titulo*/
	
	/*  calcula o desconto*/
	If iCpoDesPerc > 0
		nValDesc := nValTot - ( ( nValTot / 100 ) * iCpoDesPerc )
	EndIf
	
	/*  O valor do desconto tem prioridade sobre o percentual de desconto*/
	If iCpoDesVlr > 0
		nValDesc := iCpoDesVlr
	EndIf
	
	nValTot   := nValTot - nValDesc
	
	aParcelas := Condicao(nValTot, cPagHsp,0)
	cPrfTit   := GetMv("MV_PREFCRH")
	cNumTit   :=  HS_E1Num(cPrfTit)
	cTipoTit  := "DP "
	cCliTit   := SA1->A1_COD
	cLojaTit  := SA1->A1_LOJA
	cNatTit   := cNatura   /*SA1->A1_NATUREZ*/
	cHisTit   := STR0052 + StrZero(Month(dDataBase),2) + "/" + SubStr(StrZero(Year(dDataBase),4),3,2) //"Fatura HSP "
	
	/*  Abre dialog para se inserir o histórico do titulo*/
	FS_Hist( @cHisTit )
	
	For ni := 1 to Len( aParcelas )
		
		cParcTit := Soma1(StrZero(ni-1, TAMSX3("E1_PARCELA")[1]))
		nValTit  := aParcelas[nI,2]
		dVencTit := aParcelas[nI,1]
		
		/*  CRIA O TITULO NO CONTAS A RECEBER*/
		lTitOk := HS_MkTitCr( cPrfTit, cNumTit, cParcTit, cTipoTit, cNatTit, cCliTit, cLojaTit, nValTit, dVencTit, cHisTit, "HSPAHP18" )
		
	Next ni
	
	If lTitOk
		Return({.T., cNumTit, cPrfTit, cTipoTit})
	Else
		Return({.F., cNumTit, cPrfTit, cTipoTit})
	EndIf
EndIf

DbSelectArea("SC5")
DbSetOrder(1)

ProcRegua(3 + (Len(aItensNF) * 2))

cNumPed := CRIAVAR("C5_NUM")

IncProc(STR0053 + ' ' + cNumPed)  //"Gerando pedido de venda "

If iCpoDesVlr == 0 .And. iCpoDesPerc == 0
	aCabPV := { {"C5_FILIAL" , xFilial("SC5")  , Nil}, ;
	{"C5_NUM"    , cNumPed         , Nil}, ;
	{"C5_TIPO"   , "N"             , Nil}, ;
	{"C5_CLIENTE", SA1->A1_COD     , Nil}, ;
	{"C5_LOJAENT", SA1->A1_LOJA    , Nil}, ;
	{"C5_LOJACLI", SA1->A1_LOJA    , Nil}, ;
	{"C5_NATUREZ", SA1->A1_NATUREZ , Nil}, ;
	{"C5_TIPOCLI", SA1->A1_TIPO    , Nil}, ;
	{"C5_CONDPAG", cPagHsp         , Nil}, ;
	{"C5_INCISS" , "S"             , Nil}, ;
	{"C5_TIPLIB" , "1"             , Nil}, ;
	{"C5_TPCARGA", "2"             , Nil}, ;
	{"C5_EMISSAO", dDataBase       , Nil}, ;
	{"C5_DESC1"  , 0               , Nil}, ;
	{"C5_MOEDA"  , 1               , Nil}, ;
	{"C5_LIBEROK", "S"             , Nil}}
Else
	aCabPV := { {"C5_FILIAL" , xFilial("SC5")  , Nil}, ;
	{"C5_NUM"    , cNumPed         , Nil}, ;
	{"C5_TIPO"   , "N"             , Nil}, ;
	{"C5_CLIENTE", SA1->A1_COD     , Nil}, ;
	{"C5_LOJAENT", SA1->A1_LOJA    , Nil}, ;
	{"C5_LOJACLI", SA1->A1_LOJA    , Nil}, ;
	{"C5_NATUREZ", SA1->A1_NATUREZ , Nil}, ;
	{"C5_TIPOCLI", SA1->A1_TIPO    , Nil}, ;
	{"C5_CONDPAG", cPagHsp         , Nil}, ;
	{"C5_INCISS" , "S"             , Nil}, ;
	{"C5_TIPLIB" , "1"             , Nil}, ;
	{"C5_TPCARGA", "2"             , Nil}, ;
	{"C5_EMISSAO", dDataBase       , Nil}, ;
	{"C5_DESC1"  , 0               , Nil}, ;
	{"C5_MOEDA"  , 1               , Nil}, ;
	{"C5_LIBEROK", "S"             , Nil}, ;
	{IIf(iCpoDesVlr !=0,"C5_DESCONT","C5_PDESCAB"), ;
	IIf(iCpoDesVlr !=0,iCpoDesVlr ,iCpoDesPerc), Nil}, ;
	{"C5_MENNOTA", cCpoDescDescr   , Nil} }
EndIf

For nParcAtu := 1 to nMVNumParc
	aAdd(aCabPV, {"C5_DATA" + SubStr(cParcela, nParcAtu, 1), &("M->C5_DATA" + SubStr(cParcela, nParcAtu, 1)), Nil})
	aAdd(aCabPV, {"C5_PARC" + SubStr(cParcela, nParcAtu, 1), &("M->C5_PARC" + SubStr(cParcela, nParcAtu, 1)), Nil})
Next

aItemPV  := {}

aSort(aItensNF,,,{| X, Y | X[1] < Y[1]})

For nItem := 1 To Len(aItensNF)
	IncProc(STR0054 + ' ' + cNumPed) //"Gerando pedido de venda"
	
	If aItensNF[nItem][5] > 0
		aItemPV1 := {}
		
		If lSurenN5
			cCodPro := IIf(aItensNF[nItem, 7] == "0", cSb1MatM, ;
							IIf(aItensNF[nItem, 7] == "1", cSb1Proc, ;
								IIf(aItensNF[nItem, 7] == "2", cSb1TaxD, ;
									IIf(aItensNF[nItem, 7] == "3", cSb1Imag, cSb1SExt))))
		Else
			cCodPro := IIf(aItensNF[nItem, 7]=="0", cSb1MatM, IIf(aItensNF[nItem, 7]=="1", cSb1Proc, IIf(aItensNF[nItem, 7] == "2", cSb1TaxD, cSb1SExt)))
		EndIF
		
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1") + PadR(cCodPro, Len(SB1->B1_COD)))
		
		If !Empty(aItensNF[nItem, 9])
			cTes := aItensNF[nItem, 9]
		Else
			If !Empty(SB1->B1_TS)
				cTes := SB1->B1_TS
			Else
				cTes := cTesMV
			EndIf
		EndIf
		
		cItem := Soma1(cItem, Len(SC6->C6_ITEM))
		
		/* Itens*/
		aAdd(aItemPV1, {"C6_NUM"    , cNumPed                     , Nil}) /*  Numero do Pedido*/
		aAdd(aItemPV1, {"C6_ITEM"   , cItem                       , Nil}) /*  Numero do Item no Pedido*/
		aAdd(aItemPV1, {"C6_PRODUTO", SB1->B1_COD                 , Nil}) /*  Codigo do Produto*/
		aAdd(aItemPV1, {"C6_DESCRI" , aItensNF[nItem, 6]          , Nil}) /*  Descricao produto*/
		aAdd(aItemPV1, {"C6_QTDVEN" , 1                           , Nil}) /*  Quantidade Vendida*/
		aAdd(aItemPV1, {"C6_PRUNIT" , Round(aItensNF[nItem, 5], 2), Nil}) /*  PRECO DE LISTA*/
		aAdd(aItemPV1, {"C6_PRCVEN" , Round(aItensNF[nItem, 5], 2), Nil}) /*  Preco Unitario Liquido*/
		aAdd(aItemPV1, {"C6_VALOR"  , Round(aItensNF[nItem, 5], 2), Nil}) /*  Valor Total do Item*/
		aAdd(aItemPV1, {"C6_ENTREG" , dDataBase                   , Nil}) /*  Data da Entrega*/
		aAdd(aItemPV1, {"C6_UM"     , SB1->B1_UM                  , Nil}) /*  Unidade de Medida Primar.*/
		aAdd(aItemPV1, {"C6_TES"    , cTes                        , Nil}) /*  Tipo de Entrada/Saida do Item*/
		aAdd(aItemPV1, {"C6_LOCAL"  , SB1->B1_LOCPAD              , Nil}) /*  Armazem*/
		aAdd(aItemPV1, {"C6_DESCONT", 0                           , Nil}) /*  Percentual de Desconto*/
		aAdd(aItemPV1, {"C6_COMIS1" , 0                           , Nil}) /*  Comissao Vendedor*/
		aAdd(aItemPV1, {"C6_CLI"    , SA1->A1_COD                 , Nil}) /*  Cliente*/
		aAdd(aItemPV1, {"C6_LOJA"   , SA1->A1_LOJA                , Nil}) /*  Loja do Cliente*/
		aAdd(aItemPV1, {"C6_QTDEMP" , 1                           , Nil}) /*  Quantidade Empenhada VERIFICAR*/
		aAdd(aItemPV1, {"C6_QTDLIB" , 1                           , Nil}) /*  Quantidade Liberada VERIFICAR*/
		
		aAdd(aItemPV, AClone(aItemPV1))
	EndIf
Next

If Len(aCabPV) > 0 .And. Len(aItemPV) > 0
	FG_X3ORD("C",, aCabPv )
	FG_X3ORD("I",, aItemPv)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	MSExecAuto({| X, Y, Z | Mata410(X, Y, Z)}, aCabPv, aItemPV, 3) /* Faz Liberacao do Pedido se LiberOk = "S" e QtdLib = QtdEmp*/
	
	If lMsErroAuto
		MostraErro()
		DbSelectArea(cAliasOld)
		Return({.F., "", "", ""})
	Endif
Endif

IncProc( STR0055 + ' ' + cNumPed)  //"Liberando pedido de venda "
/*  Liberacao do Pedido*/
aPvlNfs  := {}
cChavSC9 := cNumPed + "01"
DbSelectArea("SC9")
DbSetOrder(1)
DbSeek(xFilial("SC9") + cChavSC9)

While !Eof() .And. SC9->C9_PEDIDO == cNumPed .And. SC9->C9_FILIAL == xFilial("SC9")
	IncProc(STR0055 + ' ' + cNumPed)  //"Liberando pedido de venda "
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(xFilial("SC6") + SC9->C9_PEDIDO + SC9->C9_ITEM)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + SC9->C9_PRODUTO)
	
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4") + SC6->C6_TES)
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial("SB2") + SC9->C9_PRODUTO)
	
	DbSelectArea("SC9")
	aAdd(aPvlNfs, {SC9->C9_PEDIDO, SC9->C9_ITEM, SC9->C9_SEQUEN, SC9->C9_QTDLIB, ;
	SC9->C9_PRCVEN, SC9->C9_PRODUTO, SF4->F4_ISS == "S", SC9->(RecNo()), ;
	SC5->(RecNo()), SC6->(RecNo()), SE4->(RecNo()), SB1->(RecNo()), ;
	SB2->(RecNo()), SF4->(RecNo())})
	DbSkip()
Enddo

If Len(aPvlNfs) == 0
	MsgStop(STR0056,STR0008) //"Problema com a liberacao para venda..."###"Atenção"
	DbSelectArea(cAliasOld)
	Return({.F., "", "", ""})
Endif

IncProc(STR0057) //"Gerando nota fiscal de venda"

/*  Abre dialog para inserir o histórico do titulo*/
cHisTit := STR0052 + StrZero(Month(dDataBase),2) + "/" + SubStr(StrZero(Year(dDataBase),4),3,2) //"Fatura HSP "
FS_Hist( @cHisTit )

//cNumNFS   := NxtSX5Nota(cSerie,, cCtrlNota, .T.)
cNumNFs   := MaPvlNfs(aPvlNfs, cSerie, .F., .F., .T., .T., .F., 0, 0, .T., .F.,, bAtuSE1)

If ExistBlock("HSP18APNF")
	ExecBlock("HSP18APNF",.F.,.F.,{cNumNFs, cSerie})
EndIf

Return({.T., cNumNFs, cSerie, MVNOTAFIS})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_comvet º Autor ³                    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_ComVet(aItensNF, nPosCom, cPosCom)
Return(aScan(aItensNF, {| aVet1 | aScan(aVet1, {| aVet2 | aVet2[nPosCom] == cPosCom}) > 0}))

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_datat9 º Autor ³                    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_DataT9(nTotal)
 Local lRet := .T., cAliasOld := Alias(), aArea := HS_SavArea({{"SX3", 0, 0}, {"SC5", 0, 0}}) 
 Local nMVNumParc := GetMV("MV_NUMPARC"), aCpoEnc := {}, nOpcA := 0
 Local cTitulo := "", nForAux := 1
 Local cParcela   := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
 Private lRefresh := .T.

 DbSelectArea("SE4")
 DbSetOrder(1)
 If !DbSeek(xFilial("SE4") + PadR(cPagHsp, Len(SE4->E4_CODIGO)))
  HS_MsgInf(STR0058 + cPagHsp + STR0059, STR0008, STR0097) //"Condição de Pagamento "###" não encontrada"###"Atenção"###"Validação da Condição de Pagamento"
  HS_ResArea(aArea)
  DbSelectArea(cAliasOld)
  Return(.F.)
 EndIf

 If Len(Condicao(nTotal, cPagHsp, 0)) > 1
  HS_MsgInf(STR0058 + cPagHsp + STR0098, STR0008, STR0097) //"Condição de Pagamento "###" não permitida pois refere-se a mais de uma parcela."###"Atenção"###"Validação da Condição de Pagamento"
  HS_ResArea(aArea)
  DbSelectArea(cAliasOld)
  Return(.F.)
 EndIf
 
 &("M->" + "C5_CONDPAG") := cPagHsp
 &("M->" + "C5_EMISSAO") := dDataBase

 If SE4->E4_TIPO == "9"
  cTitulo := STR0060 + IIf(AllTrim(SE4->E4_COND) == '%', STR0061, STR0062) + STR0063 //"Digite as datas e os "###"percentuais"###"valores"###" dos titulos"
	
  DEFINE MSDIALOG oDlg TITLE cTitulo From 09, 0 To 18, 67	Of oMainWnd
  DbSelectArea("SX3")
  DbSetOrder(2)
  For nForAux := 1 To nMVNumParc
   DbSeek("C5_DATA" + SubStr(cParcela, nForAux, 1))
   aAdd(aCpoEnc, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE, ;
   &("{|| " + SX3->X3_VALID + "}"), !Empty(SX3->X3_OBRIGAT), SX3->X3_NIVEL, SX3->X3_RELACAO, ;
   SX3->X3_F3, &("{|| " + SX3->X3_WHEN + "}"), SX3->X3_VISUAL == "V", .F., SX3->X3_CBOX, ;
   SX3->X3_FOLDER, .F., SX3->X3_PICTVAR})
		
   DbSeek("C5_PARC" + SubStr(cParcela, nForAux, 1))
   aAdd(aCpoEnc, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE, ;
   &("{|| " + SX3->X3_VALID + "}"), !Empty(SX3->X3_OBRIGAT), SX3->X3_NIVEL, SX3->X3_RELACAO, ;
   SX3->X3_F3, &("{|| " + SX3->X3_WHEN + "}"), SX3->X3_VISUAL == "V", .F., SX3->X3_CBOX,;
   SX3->X3_FOLDER, .F., SX3->X3_PICTVAR})
  Next
  DbSetOrder(1)
	
  MsMGet():New("SC5", Recno(), 4,,,,, {015, 001, 068, 265},,,,,, oDlg,,, .F.,,,, aCpoEnc,, .T.)
  ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, {|| IIf(FS_VldDT9(@nOpcA, nMVNumParc, nTotal, SE4->E4_COND), oDlg:End(), .F.)}, {|| nOpcA := 0, oDlg:End()})
  If nOpcA == 0
   lRet := .T.
  EndIf
 EndIf

 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fs_vldt9  º Autor ³                    º Data ³ 26/01/2004  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_VldDT9(nOpcA, nParcelas, nTotal, cE4Cond)

Local lRet      := .T.
Local cParcela  := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local cMv1Dup   := GetMV("MV_1DUP")
Local nTotDig   := 0
Local nMaxTipo9 := 26
Local nParcAtu  := 0
Local dDataDig  := CToD(" ")
Local nParcDig  := 0
Local nDataDig  := 0
 
 /*
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Verifica se pode estender a tipo 9 ate 36 parcelas                     ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ */
If Len(cMv1Dup) > 1 .And. Len(cMv1Dup) == Len(SE1->E1_PARCELA) .And. cMv1Dup == (Replicate("0", Len(SE1->E1_PARCELA) - 1) + "1")
	nMaxTipo9 := 36
EndIf

 /* 
 ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 ³ Limita o numero de parcelas do parametro                               ³
 ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If nParcelas > nMaxTipo9
	nParcelas := nMaxTipo9
EndIf

For nParcAtu := 1 to nParcelas
	dDataDig := &("M->C5_DATA" + SubStr(cParcela, nParcAtu, 1))
	nParcDig := &("M->C5_PARC" + SubStr(cParcela, nParcAtu, 1))
	If !Empty(dDataDig)
		nDataDig++
		If Empty(nParcDig)
			MsgStop(STR0064 + SubStr(cParcela, nParcAtu, 1) + STR0065, STR0008)  //"O valor da parcela "###" não foi informado"###"Atenção"
			nOpcA := 0
			Return(.F.)
		EndIf
	ElseIf !Empty(nParcDig)
		If Empty(dDataDig)
			MsgStop(STR0066 + SubStr(cParcela, nParcAtu, 1) + STR0067, STR0008) //"A parcela "###" possui valor informado mas não tem a data da parcela"###"Atenção"
			nOpcA := 0
			Return(.F.)
		EndIf
	EndIf
Next

If nDataDig == 0
	MsgStop(STR0068) //"Nenhuma data foi informada para as parcelas"
	lRet := .F.
Else
	For nParcAtu := 1 to nParcelas
		nTotDig += &("M->C5_PARC" + SubStr(cParcela, nParcAtu, 1))
	Next
	
	If AllTrim(cE4Cond) == "0" .And. NoRound(nTotal, 2) # NoRound(nTotDig, 2)
		Help(" ",1,"A410TIPO9")
		lRet := .F.
	ElseIf AllTrim(cE4Cond) == "%" .And. nTotDig # 100
		Help(" ",1,"A410TIPO9P")
		lRet := .F.
	ElseIf AllTrim(cE4Cond) # "%" .And. AllTrim(cE4Cond) # "0"
		MsgStop(STR0069 + X3Titulo("E4_COND") + STR0070 + SE4->E4_CODIGO + STR0071 + ; //"Campo "###" Código "###" com erro de definição. "
		STR0072 + X3Titulo("E4_COND")) //"neste tipo de condição de pagamento só é aceito 0 ou % no campo "
		lRet := .F.
	EndIf
EndIf
nOpcA := IIf(lRet, 1, 0)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_E1NUM  ºAutor  ³Alessandro Freire   º Data ³  05/04/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna o proximo título livre                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_E1Num(cMV_PrefCRH)
 Local cE1_Num := Space(Len(SE1->E1_NUM)), cAliasOld := Alias(), aArea := HS_SavArea({{"SE1", 0, 0}})
 Local cSql    := ""
  
 cSql := "SELECT MAX(SE1.E1_NUM) MAXNUM FROM " + RetSqlName("SE1") + " SE1" 
 cSQL += " WHERE"
 cSQL += " SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.D_E_L_E_T_ <> '*' " 
 cSQL += " AND SE1.E1_PREFIXO = '" + cMV_PrefCRH + "' "  
 
 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRYSE1"
 
 cE1_Num := Soma1(QRYSE1->MAXNUM , Len(SE1->E1_NUM))

 DbCloseArea()       
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(cE1_Num)

**************************************************************************************************************
* Cria o titulo no contas a receber
**************************************************************************************************************
FUNCTION HS_MkTitCr( cPrfTit, cNumTit, cParcTit, cTipoTit, cNatTit, cCliTit, cLojaTit, nValTit, dVencTit, cHisTit, cOrigem, nOpcAuto, dDatEmis, cVldNat)

 Local aTit    := {}
 Local lMsErro := .t.
 Local lMsHelp := .t.
 Local lOk     := .t.      

 Default nOpcAuto := 3
 Default dDatEmis := DDATABASE
 Default cVldNat  := ""

 Private lMsErroAuto := .f.
 Private lMsHelpAuto := .t.

 AADD(aTit , {"E1_NUM"    ,cNumTit                  , NIL})
 AADD(aTit , {"E1_PREFIXO",cPrfTit                  , NIL})
 AADD(aTit , {"E1_PARCELA",cParcTit                 , NIL})
 AADD(aTit , {"E1_TIPO"   ,cTipoTit                 , NIL})
 AADD(aTit , {"E1_VALOR"  ,nValTit                  , NIL})
 AADD(aTit , {"E1_VLCRUZ" ,nValTit                  , NIL})
 AADD(aTit , {"E1_CLIENTE",cCliTit                  , NIL})
 AADD(aTit , {"E1_LOJA"   ,cLojaTit                 , NIL})
 AADD(aTit , {"E1_NATUREZ",cNatTit                  , IIF(!EMPTY(cVldNat), cVldNat, NIL)})
 AADD(aTit , {"E1_EMISSAO",dDatEmis                 , NIL})
 AADD(aTit , {"E1_VENCTO" ,dVencTit                 , NIL})
 AADD(aTit , {"E1_VENCREA",DataValida(dVencTit,.t.) , NIL})
 AADD(aTit , {"E1_VENCORI",DataValida(dVencTit,.t.) , NIL})
 AADD(aTit , {"E1_EMIS1"  ,dDataBase                , NIL})
 AADD(aTit , {"E1_MOEDA"  ,1                        , NIL})
 If cHisTit != nil
  AADD(aTit , {"E1_HIST",cHisTit                  , NIL})                                                          
 EndIf
 If cOrigem != nil
  AADD(aTit, {"E1_ORIGEM",cOrigem                 , NIL})
 EndIf

 MSExecAuto({|x, y| FINA040(x, y)}, aTit, nOpcAuto)

 If lMsErroAuto
  lOk := .f.
  MOSTRAERRO()
 EndIf

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_HISTIT ºAutor  ³Alessandro Freire   º Data ³  04/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Abre dialog para que seja possivel alterar o historico      º±±
±±º          ³do titulo                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_Hist( cHistorico )
 Local oDlg,oSay1,oGetHist,oSBtn3

 DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0073) FROM  00, 00 TO 00, 00 OF oMainWnd  //"Histórico Financeiro"
 oDlg:nLeft := 0
 oDlg:nTop := 0
 oDlg:nWidth := 388
 oDlg:nHeight := 105

 @ 0,0 SAY oSay1 VAR STR0074 //"Digite o historico do título a ser gerado no financeiro"
 oSay1:nLeft := 6
 oSay1:nTop := 8
 oSay1:nWidth := 261
 oSay1:nHeight := 17
 oSay1:lTransparent := .T.

 @ 0,0 MSGET oGetHist VAR cHistorico
 oGetHist:nLeft := 6
 oGetHist:nTop := 28
 oGetHist:nWidth := 370
 oGetHist:nHeight := 21

 oSBtn3 := SBUTTON():Create(oDlg)
 oSBtn3:cName := "oSBtn3"
 oSBtn3:cCaption := "OK"
 oSBtn3:nLeft := 324
 oSBtn3:nTop := 53
 oSBtn3:nWidth := 52
 oSBtn3:nHeight := 22
 oSBtn3:lShowHint := .F.
 oSBtn3:lReadOnly := .F.
 oSBtn3:Align := 0
 oSBtn3:lVisibleControl := .T.
 oSBtn3:nType := 1
 oSBtn3:bAction := {|| oDlg:End() }

 ACTIVATE DIALOG oDlg CENTERED

Return(NIL)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_TemTit ºAutor  ³ Alessandro Freire  º Data ³  05/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Funcao auxiliar no filtro dos lotes                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_TemTit()
 Local lRet  := .f.
 Local aArea := GetArea()

 /*  Somente retorna true se o lote ainda não tiver titulos */
 DbSelectArea("GCZ")
 DbSetOrder(23) //FILFAT + STATUS + NRLOTE
 If DbSeek(xFilial("GCZ") + cStatus + GAT->GAT_NUMLOT)
  lRet := Empty(GCZ->GCZ_NRFATU)
 EndIf

 RestArea( aArea )
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DblClk º Autor ³Alessandro Freire   º Data ³  05/05/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Marca/Desmarca                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_DblClk(oNewGetD, nCpoPosi)
 Local lRet := .T.

 If oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] == "LBNO"
  oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBTIK"
 Else
  oNewGetD:aCols[oNewGetD:oBrowse:nAt,nCpoPosi] := "LBNO"
 Endif

 oNewGetD:oBrowse:Refresh()

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HS_P18Alt ºAutor  ³Microsiga           º Data ³  05/06/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_P18Man(nOpcx)
Local aArea      := GetArea()
Local cLote      := ""
Local cTit       := ""
Local cProc      := GAT->GAT_NUMPRO
Local cMesRef    := GAT->GAT_MESREF
Local cSerie     := ""
Local cNrFatu    := ""
Local nRecNoSE1  := 0
Local nQtGat     := 0
Local aHGAT      := {}
Local aCGAT      := {}
Local nUGAT      := 0
Local aSize      := MsAdvSize(.T.)
Local aObjects   := {}
Local cCliente   := ""
Local nValor     := 0

Local nOpc       := 0
Local oDlg       := nil
Local oGdGAT     := nil
Local oFolder    := nil
Local nLoop      := 0
Local nGATNUMPRO := 0

If FunName() <> "HSPAHP45"
	// Posiciona em uma guia que seja deste lote para saber o numero do titulo
	DbSelectArea("GCZ")
	DbSetOrder(21) //FILFAT + NRLOTE
	DbSeek(cFilAnt + GAT->GAT_NUMLOT)
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	DbSeek(xFilial("SE1") + GCZ->GCZ_SERIE + GCZ->GCZ_NRFATU)
EndIf
cSerie  := SE1->E1_PREFIXO
cNrFatu := SE1->E1_NUM

nRecNoSE1 := SE1->(RecNo())

cCliente := Posicione("SA1", 1, xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA, "A1_NOME")
nValor   := 0

While ! Eof() .and. xFilial("SE1") == SE1->E1_FILIAL .and. SE1->E1_PREFIXO == cSerie .and. SE1->E1_NUM == cNrFatu
	nValor += SE1->E1_VALOR
	DbSkip()
Enddo

DBGoto(nRecNoSE1)

nQtGAT := HS_BDados("GAT" , @aHGAT, @aCGAT, @nUGAT, 3,, "GAT->GAT_SERIE == '" + cSerie + "' .and. GAT->GAT_NRFATU == '" + cNrFatu + "'" )

nGATNUMLOT := aScan( aHGAT, {|x|x[2] == "GAT_NUMLOT"} )
nGATSERIE  := aScan( aHGAT, {|x|x[2] == "GAT_SERIE "} )

AAdd( aObjects, { 100, 10, .t., .t. } ) /* Protocolo */
AAdd( aObjects, { 100, 40, .t., .t. } ) /*EnchoiceBar*/
AAdd( aObjects, { 100, 50, .t., .t., .t. }) /* Folder */

aInfo    := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObj    := MsObjSize( aInfo, aObjects, .T. )

aObjects := {}
AAdd( aObjects, { 100, 100, .t., .t. } ) /* Getdados dentro do Folder */
aInfo    := { 0, 0, aPObj[3,3], aPObj[3,4],0,0 }
aPFol    := MsObjSize( aInfo, aObjects )

Define MsDialog oDlg From aSize[7], 000 To aSize[6], aSize[5]	Of oMainWnd Pixel

@ aPObj[1,1]+10,005 SAY STR0099 PIXEL //"Protocolo"
@ aPObj[1,1]+10,060 MSGET cProc WHEN nOpcx == 4 PIXEL

@ aPObj[1,1]+10,200 SAY STR0100 PIXEL //"Mês/Ano Ref."
@ aPObj[1,1]+10,260 MSGET cMesRef WHEN nOpcx == 4 PIXEL

Enchoice("SE1", nRecNoSE1, 1,,,,, {aPObj[2,1], aPObj[2,2], aPObj[2,3], aPObj[2,4]})

@ aPObj[3,1],aPObj[3,2] Folder oFolder Size aPObj[3,3], aPObj[3,4]+15 Of oDlg PROMPTS STR0106 Pixel  //"Lotes"
oGDGAT := MsNewGetDados():New(aPFol[1,1], ;
aPFol[1,2], ;
aPFol[1,3], ;
aPFol[1,4], ;
0,,,,,,,,,, oFolder:aDialogs[1],aHGAT, aCGAT)

Activate Dialog oDlg on init EnchoiceBar(oDlg, {|| nOpc := 1, oDlg:End()},{|| nOpc := 0, oDlg:End()} )

If nOpc == 0 .or. nOpcx == 2 // visualizar
	Return(.f.)
EndIf

DbSelectArea("GAT")
DbSetOrder(1)

If nOpcX == 5 .And. ExistBlock("HSP18EXC")
	lRet := ExecBlock("HSP18EXC", .F., .F., Nil)
	If !lRet
		Return(Nil)
	EndIf
EndIf

Begin Transaction
For nLoop := 1 to Len(oGDGAT:aCols)
	If dbSeek( xFilial("GAT")+oGDGAT:aCols[nLoop][nGATNUMLOT] )
		If nOpcX == 4 // alterar
			RecLock("GAT",.F.)
			GAT->GAT_NUMPRO := cProc
			GAT->GAT_MESREF := cMesRef
			MsUnlock()
		ElseIf nOpcX == 5 // excluir
		
			If CheckSA2Bx()
				
				MsgInfo(STR0118, STR0008) //"Não é permitido excluir Fatura cujo Extrato Médico possua um título baixado!"###"Atenção"
				DisarmTransaction()
				Exit
				
			EndIf
		
			If HS_ExcTitu(GAT->GAT_SERIE, GAT->GAT_NRFATU, GAT->GAT_CODCON)
				
				DbSelectArea("GCZ")
				DbSetOrder(21) //FILFAT + NRLOTE
				DbSeek(cFilAnt + GAT->GAT_NUMLOT)
				
				While ! Eof() .and. cFilAnt == GCZ->GCZ_FILFAT .and. GCZ->GCZ_NRLOTE == GAT->GAT_NUMLOT
					RecLock("GCZ",.F.)
					GCZ->GCZ_STATUS := "3"
					GCZ->GCZ_DATSTA := dDatabase
					GCZ->GCZ_DATFAT := CtoD("")
					GCZ->GCZ_HORFAT := " "
					GCZ->GCZ_NRFATU := " "
					GCZ->GCZ_NRNOTA := " "
					GCZ->GCZ_SERIE  := " "
					GCZ->GCZ_VLGUIA := 0
					MsUnlock()
					DbSkip()
				Enddo
				
				HSA18EXC6(SC6->C6_NUM)
				
				RecLock("GAT",.F.)
				GAT->GAT_NUMPRO := " "
				GAT->GAT_SERIE  := " "
				GAT->GAT_NRFATU := " "
				GAT->GAT_DTFTLT := CToD("")
				MsUnlock()
			EndIf
		EndIf
	EndIf
Next nLoop
End Transaction

RestArea( aArea )

Return(nil)

Function HS_ExcTitu(cSerie, cNrFatu, cCodCon)
Local nParcelas	:= 0, aParcelas := {}, lRet := .T., aArea := GetArea()
Local aRegSD2	:= {}, aRegSE1 := {}, aRegSE2 := {}	
Local nTit		:= 0

DbSelectArea("GA9")
DbSetOrder(1)
DbSeek(xFilial("GA9") + cCodCon)
            
If GA9->GA9_GERANF == "1" //1-somente titulo
	DbSelectArea("SE1")
	DbSetOrder(1)
	If DbSeek(xFilial("SE1") + cSerie + cNrFatu)
		While !Eof() .and. SE1->E1_FILIAL == xFilial("SE1") .and. SE1->E1_NUM == cNrFatu .and. SE1->E1_PREFIXO == cSerie
			nTit++
			If nTit = 1
				aAdd(aParcelas, {	SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_NATUREZ, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_VALOR, ;
									SE1->E1_VENCTO, SE1->E1_HIST})
			EndIf
			DbSkip()
		End       
                       
		For nParcelas := 1 To Len(aParcelas)
			If !(lRet := HS_MkTitCr(	aParcelas[nParcelas][01], aParcelas[nParcelas][02], aParcelas[nParcelas][03], aParcelas[nParcelas][04], ;
										aParcelas[nParcelas][05], aParcelas[nParcelas][06], aParcelas[nParcelas][07], aParcelas[nParcelas][08], ;
										aParcelas[nParcelas][09], aParcelas[nParcelas][10], "HSPAHP18", 5))
				Exit
			EndIf  
		Next nParcelas
	EndIf
Else                                     
	DbSelectArea("SF2")
	DbSetOrder(1)
	If DbSeek(xFilial("SF2") + cNrFatu + cSerie)
 
		If (lRet := MaCanDelF2("SF2", RecNo(), @aRegSD2, @aRegSE1, @aRegSE2, 'HSPAHP18'))
		 	
			//³ Estorna o documento de saida
			MaDelNFS(aRegSD2, aRegSE1, aRegSE2, .F., .F., .F., .T.)
			MsUnLockAll()
		 			 	
		EndIf
		 
	EndIf 
EndIf 
 
RestArea(aArea)
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSA18EXC6 º Autor ³ Microsiga          º Data ³ 27/05/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao utilizada para zerar o campo 'C6_QTDEMP' para que   º±±
±±º          ³ seja possivel realizar a exclusao de um pedido de venda em º±±
±±º          ³ aberto ao excluir uma fatura gerada pelo HSP.              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSA18EXC6(cNumSC6)
Local aArea := GetArea()

DbSelectArea("SC6")
SC6->(DbSetOrder(1))//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

SC6->(MsSeek(xFilial("SC6")+cNumSC6))

While !SC6->(Eof()) .and. SC6->C6_NUM == cNumSC6
	RecLock("SC6",.F.)
	SC6->C6_QTDEMP := 0
	MsUnlock()
	SC6->(DbSkip())
Enddo

RestArea(aArea)
Return

Function HS_VldP18()
 Local lRet := .T., cPrfTit := GetMv("MV_PREFCRH")

 If     ReadVar() == "MV_PAR01" .And. Empty(MV_PAR01) // Valida Codigo do convenio vazio
  
  MsgStop(STR0084, STR0008) // "Atenção" //"O codigo do convenio é obrigatorio"
  lRet := .F.
 
 ElseIf ReadVar() == "MV_PAR01" // Valida Codigo do convenio
 	cGcmCodCon	:= MV_PAR01
  DbSelectArea("GA9")
  DbSetOrder(1)
  If !(lRet := DbSeek(xFilial("GA9") + MV_PAR01))
   MsgStop(STR0085, STR0008) // "Atenção" //"Codigo do convenio invalido"
  EndIf
   
  If Type("cE1Cliente") <> "U"
   cE1Cliente := GA9->GA9_CODCLI  
  EndIf
   
  If Type("cE1Loja") <> "U"
   cE1Loja := GA9->GA9_LOJA
  EndIf
 
 ElseIf ReadVar() == "MV_PAR02"
 
 	lRet := HS_VSUSCP(AllTrim(MV_PAR01), MV_PAR02)
 
 ElseIf ReadVar() == "MV_PAR11" .And. !Empty(MV_PAR11)           
         
  If Type("cE1Cliente") <> "U" .And. Type("cE1Loja") <> "U"
   DbSelectArea("SE1")
   DbSetOrder(2)
   lRet := DbSeek(xFilial("SE1") + cE1Cliente + cE1Loja + cPrfTit + MV_PAR11)
  Else 
   DbSelectArea("SE1")
   DbSetOrder(1)
   lRet := DbSeek(xFilial("SE1") + cPrfTit + MV_PAR11)
  EndIf 
  
  If !lRet
   MsgStop(STR0086, STR0008) // "Atenção" //"Fatura não encontrada ou não pertence ao convenio informado"
  EndIf
 
 EndIf
 
Return(lRet)

Static Function FS_VldNat(cNat)
  
  If EMPTY(cNat)
   HS_MsgInf(STR0087, STR0008, STR0095)  //"Natureza do cliente é campo obrigatório para geração da nota fiscal" //"Validação da Natureza"
   Return(.F.)
  Else 
   DBSelectArea("SED")
   DBSetOrder(1)
   If !DbSeek(xFilial("SED") + cNat)
    HS_MsgInf(STR0096, STR0008, STR0095)   //"Natureza não encontrada."###"Validação da Natureza"
    Return(.F.)    
   EndIf
  EndIf 

Return(.T.)

***************************************************************************************************
Function HS_xFilFat(cArq)
*****************************

Local cRet := "'"+Space(TamSx3("GCZ_FILATE")[1])+"'"
LOCAL cFil := ALLTRIM(XFILIAL(cArq))
 
IF LEN(cFil) <> LEN(XFILIAL("GCZ"))	//	Verifica se está compartilhado
	cRet := "'" + XFILIAL(cArq) + "'"
ELSEIF !EMPTY(xFilial(cArq))
  cRet := "GCZ.GCZ_FILATE"
EndIf

Return(cRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MenuDef  ³ Autor ³ Tiago Bandeira        ³ Data ³ 10/06/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Definição do aRotina (Menu funcional)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ MenuDef()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
 Local aRotAdic := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Array contendo as Rotinas a executar do programa      ³
//³ ----------- Elementos contidos por dimensao ------------     ³
//³ 1. Nome a aparecer no cabecalho                              ³
//³ 2. Nome da Rotina associada                                  ³
//³ 3. Usado pela rotina                                         ³
//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
//³    2 - Simplesmente Mostra os Campos                         ³
//³    3 - Gera arquivo TXT para exportacao                      ³
//³    4 - Recebe arquivo TXT                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aRotina :=	{{STR0002, "AxPesqui"                  , 0, 1, 0, nil},; //"Pesquisar "
                     {STR0003, "HS_P18Man(2)"              , 0, 2, 0, nil},; //"Visualizar"
                     {STR0004, "HS_P18Ger"                 , 0, 3, 0, nil},; //"Gerar     "
                     {STR0005, "HS_P18Man(4)"              , 0, 4, 0, nil},; //"Alterar   "
                     {STR0006, "HS_P18Man(5)"              , 0, 5, 0, nil},; //"Excluir   "
                     {"EDI"  , "HS_P18EDI(GAT->GAT_CODPLA)", 0, 4, 0, nil}}
                     
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Ponto de entrada - Adiciona rotinas ao aRotina       ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 If ExistBlock("HSP18ROT")
 	aRotAdic := ExecBlock("HSP18ROT", .F., .F.)
	 If ValType(aRotAdic) == "A"
	 	AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	 EndIf
 EndIf	

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CheckSA2Bx ³ Autor ³ Totvs		          ³ Data ³ 21/09/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Procura por um Repasse realizado ao Medico                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CheckSA2Bx()                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CheckSA2Bx

Local lAchou := .F.
Local cNivGF := ""

GE7->(DbSetOrder(2))

If GE7->(DbSeek(xFilial("GE7")+GCZ->(GCZ_NRSEQG)))
	cNivGF	:= "GE7"
Else
	GE6->(DbSetOrder(2))
	If GE6->(DbSeek(xFilial("GE6")+GCZ->(GCZ_NRSEQG)))
		cNivGF := "GE6"
	Else
		GE5->(DbSetOrder(2))
		If GE5->(DbSeek(xFilial("GE5")+GCZ->(GCZ_NRSEQG)))
			cNivGF := "GE5"
		EndIf
	EndIf
EndIf

If ! Empty(cNivGF)
	GDX->(DbSetOrder(1))
	If(GDX->(DbSeek(xFilial("GDX")+&(cNivGF+"->"+cNivGF+"_NREXTM"))))
		SE2->(DbSetOrder(1))
		If(SE2->(DbSeek(xFilial("SE2")+"HSP" + GDX->GDX_CODCPG)))
			If ! Empty(DToS(SE2->E2_BAIXA))
				lAchou := .T.
			EndIf
		EndIf
	EndIf
EndIf

Return lAchou