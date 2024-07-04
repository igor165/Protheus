#Include "Ofiom160.ch"
#Include "Protheus.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM160 ³ Autor ³  Emilton              ³ Data ³ 14/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fechamento de Ordem de Servico                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM160(lFNormal)

Local aCores    := {{ 'VO1->VO1_STATUS == "A"', 'BR_VERDE'     } ,;   // Aberta
{ 'VO1->VO1_STATUS == "D"', 'BR_AZUL'     } ,;  // Liberada
{ 'VO1->VO1_STATUS == "F"', 'BR_VERMELHO' } ,;  // Fechado
{ 'VO1->VO1_STATUS == "C"', 'BR_PRETO'    } }    // Cancelado
Local lVOO := .f.
Local aRegs := {}
Private aVOOAgrup   := {} // Fechamento agrupado utilizado para "Controle de Valor de Garantia por periodo"
Private lA1_IBGE    := SA1->(FieldPos("A1_IBGE")) <> 0 // Verifica se existe o campo SA1->A1_IBGE
Private lVO1_NATURE := VO1->(FieldPos("VO1_NATURE")) <> 0 // Verifica se existe o campo VO1->VO1_NATURE
Private cVO1_NATURE := ""
Private lVO1_NATSRV := VOO->(FieldPos("VOO_NATSRV")) <> 0 // Verifica se existe o campo VOO->VOO_NATSRV
Private cVO1_NATSRV := ""
Private aOS_GRV     := {}
Private oLbParc,oGetCondicao
Private oLbIte
Private oFnt,oFnt1,oFnt2,oFnt3,oFnt4,oFnt5,oFnt6
Private cTipPag := space(03)
Private cTipPag1:= space(03)
Private cDesPag := space(20)
Private oTipPag, oDesPag, oCodCDCI
Private oCodBco, oDesBco, oValorCom
Private cDepVOO := ""
Private cDepto  := "  "
Private cMarca
Private cNumBord  := ""
Private dDatBord  := cTod("")
Private cNumBord2 := ""
Private dDatBord2 := cTod("")
Private lAbortPrint := .f.
Private aIteParc  := {{cTod(""),0}}
Private cCodCDCI  := space(04)
Private cCondic1  := ctod(" ")
Private cCondic2  := space(02)
Private cCondic3  := space(len(SE1->E1_PARCELA))
Private cCondic4  := space(02)
Private cCondic5  := "1"
Private cGruFor   := "06"
Private nValorCom := 0
Private cNumero   := ""
Private cParPro   := ""
Private cContChv  := ""
Private cPartem   := ""
Private nC        := 1
Private n         := 1
Private nIndexPro := 0
Private aColsC    := {}
Private aHeaderC  := {}
Private aGravaEnt := {}
Private aBoqPec   := {}
Private aComCon   := {}
Private cCodBco   := space(03), cDesBco := space(20)
Private nUsadoC   := 1
Private aSegEnc   := {}
Private aVerPad   := {}
Private cLinOk1   := "AllwaysTrue()"
Private cTudoOk1  := "AllwaysTrue()"
Private cFieldOk1 := "FG_DADOSENT(M->VSF_vTOTNF),FG_MEMVAR()" // "FG_DADOSENT(nTotTTp+M->VSF_DESACE),FG_MEMVAR()"
Private lRefresh  := .t.
Private lFlgVet   := .t.
Private lFlgInd   := .t.
Private aColsBKP  := {}
Private cForPeri  := "" // Variavel para cliente periodico
Private aMemos    := {{"VS9_OBSERV","VS9_OBSMEM"}}
Private nTotDesA
Private nTotTTpA
Private nTotPecA
Private nTotSrvA
Private nTotEntr:=0
Private oTotEntr
Private lSalvou   := .t.
Private lDesconto := .f.
Private nIssRet   := 0
Private cTipOpe   := 2
Private nTotalEnt := 0
Private nDesPer   := 0
Private bRefresh  := { || .t. }
Private aErrAva   := {} //Array contendo as formulas nao encontradas p/ avaliacao
Private cSimVda   := "S"
Private nAliPis   := GETMV("MV_TXPIS")  / 100
Private nAliCof   := GETMV("MV_TXCOFIN")/ 100
Private nAliIss   := GETMV("MV_TXISS")  / 100
Private nCheck    := 1
Private cNota     := ""
Private cSerie    := iif(nCheck==1,"",SuperGetMv("MV_SERCUP","CUP"))
Private aVetTTp   := {}
Private aVetTTpa  := {}
Private oVetTTp
Private bFiltraBrw
Private cPrefixo  := GetNewPar("MV_PREFOFI","OFI")
Private lMSHelpAuto := .f.
Private lMsFinalAuto:= .f.
Private lMsErroAuto := .f.
Private lCond1Vez := .t.
Private cPar02Sv := ""
Private cPar03Sv := ""
					
********** Variavel que indica se o Fechamento eh de Pecas / Servicos / Ambos
Private _cPecSrv  := "" // P-Pecas / S-Servicos / A-Ambos

Default lFNormal := .t.
DEFINE FONT oFnt  NAME "Arial" SIZE 15,20 BOLD
DEFINE FONT oFnt1 NAME "Arial" SIZE 09,14
DEFINE FONT oFnt2 NAME "Arial" SIZE 08,12
DEFINE FONT oFnt3 NAME "Ms Sans Serif" ITALIC
DEFINE FONT oFnt4 NAME "Times New Roman" BOLD
DEFINE FONT oFnt5 NAME "Ms Sans Serif" SIZE 08,10
DEFINE FONT oFnt6 NAME "Ms Sans Serif" BOLD SIZE 08,10

*** Define o cabecalho da tela de atualizacoes ********************************

Private cCadastro := OemToAnsi(STR0001)

*** Endereca a funcao de BROWSE ***********************************************

Private Inclui := .f.
Private aRotina := MenuDef()
Private cParam01, cParam02, cParam03, cParam04, cParam05
Private cChassiInt := ""
Private aFilMarkBrow := {}
Private nVerParFat   := 1 // se 1, Não mostra Parametros do Faturamento, se 2, mostra

////////////////////////////////////////////////////////////////////////////////////////////////////
// Valida se a empresa tem autorizacao para utilizar o modulo de Oficina		          //
/////////////////////////////////////////////////////////////////////////////////////////////////////
If !AMIIn(14) .or. !FMX_AMIIn({"OFIOM010","OFIOM030","OFIOM160"})
    Return()
EndIf


dbSelectArea("SIX")
dbSetOrder(1)
If !dbSeek("VS6"+"2")
	If RecLock("SIX",.T.)
		SIX->INDICE    := "VS6"
		SIX->ORDEM     := "2"
		SIX->CHAVE     := "VS6_FILIAL+VS6_DOC"
		SIX->DESCRICAO := "Filial_Documento"
		SIX->PROPRI    := "S"
		MsUnlock()
	EndIf
EndIf

//FS_VALIDPERG() // "OF160A"

///
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pergunte para Configuracao da Rotina ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//AADD(aRegs,{STR0195, "", "", "mv_ch1", "N", 1                              , 0, 1, "C", ''                               , "mv_par01", STR0199, STR0199 , STR0199 , "" , "" , STR0200 , STR0200 , STR0200 , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , {STR0196,STR0197,STR0198},{},{}})

Pergunte("OF160F12",.f.)
nVerParFat := Mv_Par01

/// Zera a pergunte para nao sugerir nada na proxima tela *********************
&& Valida se a empresa tem autorizacao para utiliza o modulo de oficina.
If !AMIIn(11,14,41)
	Return
EndIf

SetKey(VK_F12,{||FSO16F12()})

If lFNormal // Fechamento NORMAL
	HS_POSSX1({{"OF160A","02",space(8)}}) // Altera CONTEUDO do SX1 automaticamente
	while .t.
		If Pergunte("OF160A",.t.)
			cParam01 := MV_PAR01
			If !empty(cParam01) // So passa se tiver conteudo no MV_PAR01
				Exit
			Else
				loop
			EndIf
		Else
			SetKey(VK_F12,Nil)
			Return .t.
		EndIf
	EndDo
Else // Fechamento pela Requisicao de Servico
	cParam01 := MV_PAR01 := 1 // Fechamento Individual
	MV_PAR02 := VO1->VO1_NUMOSV // Nro da OS para Fechamento
EndIf

Do Case

	Case cParam01 == 2

		Private aArrPec := {}

		while .t.

			If Pergunte("OF160B",.t.)
				cParam02 := MV_PAR01
				cParam03 := MV_PAR02
				cParam04 := MV_PAR03
				cParam05 := MV_PAR04
				If !FG_SEEK("SA1","cParam02+cParam03",1,.F.)
					Help(" ",1,"M160CLICAD")   // Cliente NAO cadastrado
					Loop
				EndIf
				DbSelectArea("VOO")
				DbSetOrder(3)
				DbSeek(xFilial('VOO') + cParam02 + cParam04 )
				Do While !Eof() .And. VOO->VOO_FILIAL+VOO->VOO_FATPAR+VOO->VOO_TIPTEM == xFilial('VOO') + cParam02 + cParam04
					If Empty(VOO->VOO_NUMNFI) .AND. Empty(VOO->VOO_PESQLJ)
						DbSelectArea("VO1")
						DbSetOrder(1)
						If ( VO1->( DbSeek(xFilial('VO1')+VOO->VOO_NUMOSV) ) .And. VO1->VO1_TEMLIB == 'S' .And. VO1->VO1_STATUS $ 'A/D' )
							lVOO := .t.
							Exit
						EndIf
					EndIf
					DbSelectArea("VOO")
					DbSkip()
				EndDo
				If !lVOO
					MsgStop( STR0174 +CHR(13)+CHR(10)+CHR(13)+CHR(10)+  STR0146  +": "+cParam02+"-"+cParam03+" "+SA1->A1_NOME+CHR(13)+CHR(10)+ STR0147 +": "+cParam04,STR0133)//Nenhuma OS aberta/disponivel para este Cliente/Tipo de Tempo! # Cliente # Tipo de Tempo #  Atencao!
					Loop
				EndIf
				If Empty(cParam02) .or. Empty(cParam04)
					loop
				Else
					Exit
				EndIf
			Else
				SetKey(VK_F12,Nil)
				return .t.
			EndIf

		EndDo

	Case cParam01 == 3

		while .t.

			If Pergunte("OF160C",.t.)
				If !FG_SEEK("SA1","MV_PAR01+MV_PAR02",1,.F.)
					Help(" ",1,"M160CLICAD")   // Cliente NAO cadastrado
					Loop
				EndIf
				cParam02 := MV_PAR01
				cParam03 := MV_PAR02
				cParam04 := MV_PAR03
				If Empty(cParam02) .or. Empty(cParam04)
					loop
				Else

					FG_SEEK("VOI","cParam04",1,.f.)

					If VOI->VOI_TPOKLM != "1"
						Help(" ",1,"M160TPOKLM")   // Tipo de Tempo de Kilometragem
						Loop
					EndIf

					Exit
				EndIf
			Else
				SetKey(VK_F12,Nil)
				Return .t.
			EndIf

		EndDo

EndCase

If cParam04 != Nil

	FG_SEEK("VOI","cParam04",1,.f.)

	If VOI->VOI_SITTPO == "3"

		cTipPag := VOI->VOI_FORPAG

	EndIf

EndIf

Do Case

	Case cParam01 == 1                 // Fechamento Individual de Ordem de Servico

		aIndVO1 := {}
		cChave  := "VO1_FILIAL+VO1_NUMOSV"
		cCond160:= "VO1_TEMLIB == 'S' .and. VO1_STATUS $ 'A/D'"

		dbSelectArea("SX1")
		dbSetOrder(1)
		if dbSeek(left("OF160A"+space(15),len(SX1->X1_GRUPO))+"02") .and. !Empty(MV_PAR02)
			dbSelectArea("VO1")
			dbSetOrder(1)
			If dbSeek( xFilial("VO1") + strzero(val(MV_PAR02),8) )
				cAlias := "VO1"
				nReg   := VO1->(RecNo())
				nOpc   := 6
				OFIM160I(cAlias, nReg, nOpc) // Chamada direta
			EndIf
		Else
			dbSelectArea("VO1")

			dbSelectArea("VAI")
			dbSetOrder(4)
			dbSeek(xFilial("VAI")+__cUserID)

			if VAI->VAI_TIPTEC == "4"
				DbSelectArea("VO1")
				dbSetOrder(1)

				cCondicao := "VO1->VO1_FUNABE == VAI->VAI_CODTEC"
				FilBrowse('VO1',{},cCondicao) // Filtra Usuario

			Endif

			mBrowse( 6, 1,22,75,"VO1",,,,,,aCores)
			dbClearFilter()


		EndIf

		DbSelectArea("VO1")
		RetIndex()

		#IFNDEF TOP
			If File(cIndVO1+OrdBagExt())
				fErase(cIndVO1+OrdBagExt())
			Endif
		#ENDIF

	Case cParam01 == 2                 // Fechamento Agrupado de Ordem de Servico

		&& Posiciona no primeiro registro valido para o filtro.
		DbSelectArea("VOO")
		DbSetOrder(3)
		DbSeek(xFilial('VOO') + cParam02 + cParam04 )
		Do While !Eof() .And. VOO->VOO_FILIAL+VOO->VOO_FATPAR+VOO->VOO_TIPTEM == xFilial('VOO') + cParam02 + cParam04

			If Empty(VOO->VOO_NUMNFI) .AND. Empty(VOO->VOO_PESQLJ)

				DbSelectArea("VO1")
				DbSetOrder(1)
				If ( VO1->( DbSeek(xFilial('VO1')+VOO->VOO_NUMOSV) ) .And. VO1->VO1_TEMLIB == 'S' .And. VO1->VO1_STATUS $ 'A/D' )
					Exit
				EndIf

			EndIf

			DbSelectArea("VOO")
			DbSkip()

		EndDo

		DbSelectArea("VO1")
		DbSelectArea("VV1")
		cChassiInt := ""
		If !Empty( cParam05 )

			DbSetOrder(2)
			If DbSeek( xFilial("VV1") + cParam05 )
				cChassiInt := VV1->VV1_CHAINT
			Else
				DbSetOrder(6)
				If DbSeek( xFilial("VV1") + cParam05 )
					cChassiInt := VV1->VV1_CHAINT
				Else
					DbSetOrder(9)
					If DbSeek( xFilial("VV1") + cParam05 )
						cChassiInt := VV1->VV1_CHAINT
					Else
						DbSetOrder(1)
						If DbSeek( xFilial("VV1") + cParam05 )
							cChassiInt := VV1->VV1_CHAINT
						Endif
					EndIf
				EndIf
			EndIf

		EndIf

		dbSelectArea("VOO")
		RetIndex()
		dbSetOrder(3)
		aFilMarkBrow := {}
		cCond160 := "FS_O160FILMK()"

		aIndVOO    := {}
		bFiltraBrw := {|| FilBrowse("VOO",@aIndVOO,@cCond160) }
		Eval(bFiltraBrw)

		DbSeek( xFilial("VOO") )
		Do While !VOO->(Eof()) .And. VOO->VOO_FILIAL == xFilial("VOO")

			Aadd( aFilMarkBrow, VOO->(Recno()) )

			dbSelectArea("VOO")
			DbSkip()

		EndDo
		DbSeek( xFilial("VOO") )

		cDelFunc := ".T."
		cMarca := GetMark()

		aCamList := {	{"VOO_OK",   ,"",OemToAnsi(STR0006)},;		//NroOsv
		{"VOO_NUMOSV","",OemToAnsi(STR0006)},;		//NroOsv
		{"VOO_TIPTEM","",OemToAnsi(STR0007)},;		//TipTpo
		{"VOO_FATPAR","",OemToAnsi(STR0008)},;		//CodCli
		{"VOO_NOMCLI","",OemToAnsi(STR0009)},;		//Nome do Cliente
		{"VOO_TOTPEC","",OemToAnsi(STR0010)},;		//Total de Pecas
		{"VOO_HRSPAD","",OemToAnsi(STR0011)},;		//HrsPad
		{"VOO_HRSAPL","",OemToAnsi(STR0012)},;		//HrsApl
		{"VOO_TOTSRV","",OemToAnsi(STR0013)}} 		//Total de Srvcs

		linverte := .F.

		Markbrow("VOO","VOO_OK",,,,cMarca)

		//Retira o Filtro da Ordem de Servicos, selecionando a ordem principal
		dbSelectArea("VOO")
		RetIndex()
		dbClearFilter()
		aEval(aIndVOO,{|x| Ferase(x[1]+OrdBagExt())})
		dbSetOrder(1)


	Case cParam01 == 3                 // Fechamento de Ordem de Servico de Kilometragem

		Private lFlag01 := .t.
		Private lFlag03 := .t.
		Private aPesquisa := { { 'VV1' , 1 , 'VV1->VV1_CHAINT' } }

		dbSelectArea("VF4")
		cIndVF4 := CriaTrab(Nil, .F.)
		cChave  := "VF4_FILIAL+VF4_CHAINT+DTOS(VF4_DATKIL)"
		If empty(cParam02)
			Help(" ",1,"M160FALCLI")   // Falta codigo de cliente
			SetKey(VK_F12,Nil)
			return
		endif
		If empty(cParam04)
			Help(" ",1,"M160FALTTP")   // Falta tipo de tempo
			SetKey(VK_F12,Nil)
			return
		endif
		cCond160 := "cParam02 == VF4->VF4_PROVEI .and. empty(VF4->VF4_NUMOSV)"
		IndRegua("VF4",cIndVF4,cChave,,cCond160,OemToAnsi(STR0014) )
		DbSelectArea("VF4")
		nIndexPro := RetIndex("VF4")
		#IFNDEF TOP
			dbSetIndex(cIndVF4+ordBagExt())
		#ENDIF
		dbSetOrder(nIndexPro+1)
		cDelFunc := ".T."
		cMarca := GetMark()
		aCamList := {{"VF4_OK",    ,"",OemToAnsi(STR0015)},; //"  "
		{"VF4_CHAINT","",OemToAnsi(STR0016)},; //ChaInt
		{"VF4_CHASSI","",OemToAnsi(STR0017)},; //Chassi do Veiculo
		{"VF4_DATKIL","",OemToAnsi(STR0018)},; //Dt Kilmt
		{"VF4_KILROD","",OemToAnsi(STR0019)},; //Kil Rodada
		{"VF4_PLAVEI","",OemToAnsi(STR0020)},; //Placa
		{"VF4_CODFRO","",OemToAnsi(STR0021)},; //Frota
		{"VF4_PROVEI","",OemToAnsi(STR0022)},; //CodCli
		{"VF4_LOJPRO","",OemToAnsi(STR0023)},; //Loja
		{"VF4_NOMPRO","",OemToAnsi(STR0024)}}  //Nome do Cliente
		linverte := .F.
		Markbrow("VF4","VF4_OK",,,.f.,cMarca)
		DbSelectArea("VF4")
		RetIndex()
		#IFNDEF TOP
			If File(cIndVF4+OrdBagExt())
				fErase(cIndVF4+OrdBagExt())
			Endif
		#ENDIF
EndCase

SetKey(VK_F12,Nil)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ OFIOM160I  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Fechamento de Ordem de Servico                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIM160I(cAlias, nReg, nOpc)

//*** Tratar as OS's que serao levantadas ***********************************************************

Local ix1, ix2, oTotTTp, oTotPec, oTotSrv,oTotDes
Local ni,oGetEnchoice
Local oVetOsv, oVetKil, lGetd, oFont, oBar
Local cTitle   := OemToAnsi(STR0025)
Local aTitles  := {OemToAnsi(If(cParam01 == 1,STR0026,If(cParam01 == 2,STR0027,STR0028))),OemToAnsi(STR0029),OemToAnsi(STR0030),OemToAnsi(STR0031)}
Local aPages   := {OemToAnsi(If(cParam01 == 1,STR0032,If(cParam01 == 2,STR0033,STR0034))),OemToAnsi(STR0035),OemToAnsi(STR0036),OemToAnsi(STR0037)}
Local bCampo   := { |nCPO| Field(nCPO) }
Local nRecno   := Recno()
Local nOrdem   := IndexOrd()
Local nControl := 0, nOk:=0
Local cPrimeiro:="", oCondic
Local nQtdReg  := 0
Local nNumReg  := 0
Local nRecOsv  := 0
Local nCntFor  := 0
Local _ni	   := 0
Local nSalvaAbe:= 0
Local cMsgLoja := ""
Local aParamBox := {}
Local aRet := {}

Private cFocus := ""
Private oDlgFechamento
Private cDepto  := "  "

If !(cPaisLoc == "BRA") // Manoel - 13/05/2009
	aTitles  := {OemToAnsi(If(cParam01 == 1,STR0026,If(cParam01 == 2,STR0027,STR0028))),OemToAnsi(STR0029),OemToAnsi(STR0030)}
	aPages   := {OemToAnsi(If(cParam01 == 1,STR0032,If(cParam01 == 2,STR0033,STR0034))),OemToAnsi(STR0035),OemToAnsi(STR0036)}
Endif
lCond1Vez := .t. // SetFocus na Condicao de pagamento no Fachamento de cada OS.

If Type("bFiltraBrw") # "U"
	Eval(bFiltraBrw)
EndIf

//////////////////////////////////////////////////////////////
// RETIRADA DO FILTRO PARA NAO DAR ERRO DE MSRECLOCK DO VO1 //
// ANDRE LUIS ALMEIDA / RUBENS                   02/07/2010 //
//////////////////////////////////////////////////////////////
VO1->(DbClearFilter())                                      //
//////////////////////////////////////////////////////////////

If !(&cCond160)
	//	MsgAlert(cCond160,"Atencao")
	//Help("  ",1,  "SITNAOATE")
	If VO1_STATUS == "C"
		MsgAlert(STR0178,STR0181)//"Impossivel Fechamento, Ordem de Serviço Cancelada
	elseif VO1_STATUS == "F"
		MsgAlert(STR0179,STR0181)//"Impossivel Fechamento, Ordem de Serviço Fechada
	elseif VO1_TEMLIB<>"S"
		MsgAlert(STR0180,STR0181)//"Impossivel Fechamento, Ordem de Serviço não Liberada
	EndIF

	Do Case
		Case cParam01 == 1      // Fechamento Individual de Ordem de Servico
			dbSelectArea("VO1")
		Case cParam01 == 2      // Fechamento Agrupado de Ordem de Servico
			dbSelectArea("VOO")
		Case cParam01 == 3      // Fechamento de Ordem de Servico de Kilometragem
			dbSelectArea("VF4")
	EndCase
	dbSetOrder(nIndexPro+1)
	FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
	Return .t.
EndIf

aRotina := {{"", "",0,1},;
{"", "",0,2},;
{"", "",0,6},;
{"", "",0,6} }


Private oTotSrv02, oTotPec02, oTotDes02, oTotTtp02
Private oTotSrv03, oTotPec03, oTotDes03, oTotTtp03
Private oFolderFEC
Private nOpcao := nOpc
Private lOk:=.F.
Private aVetOsv := {}
Private aVetKil := {}
Private lFlagProc:= .f.
Private cNumLib   := ""

/*

*** Documentacao do Vetor aVetMec que contem a posicao individualizada de
*** cada servico

1-Tipo de Servico
2-Incide Mao de Obra
3-Incide Tempo
4-Codigo do Servico
5-Numero da OS
6-Codigo do Produtivo
7-Tempo Padrao do Servico
8-Tempo Trabalhado deste segmento
9-Tempo Trabalhado do Tipo de Servico
10-Total de Tempo Trabalhado deste Servico
11-% Tempo Trabalhado Servico
12-% Tempo Trabalhado Total
13-Valor Bruto do Tipo de Servico
14-Valor Bruto deste Servico
15-Valor do servico ja rateado p/calculo
16-Valor do servico ja rateado Original
17-Recno() do VO4
18-Tempo Cobrado deste Servico

1-Numero da OS
2-Tipo de Servico
3-Codigo do Servico
4-Codigo do Produtivo
5-Tempo Padrao do Servico
6-Tempo Trabalhado deste segmento
7-Total de Tempo Trabalhado deste Servico
8-Total de Tempo Trabalhado deste Tipo de Servico
9-Total de Tempo Trabalhado desta Ordem de Servico

10-% em Relacao a este Servico
11-% em Relacao a este Tipo de Servico
12-% em Relacao a esta Ordem de Servico

13-Valor Bruto do Servico
14-Valor Rateado do Servico sem Desconto
15-Valor Rateado do Servico com Desconto

16-Valor Bruto Total do Servico
17-Valor Bruto Total do Tipo de Servico
18-Valor Bruto Total da Ordem de Servico

19-Recno() do VO4
20-Tempo Cobrado deste Servico

*/

Private aVetMec    := {}

Private aHeaderFec := {{},{},{},{}}
Private aColsFec   := {{},{},{},{}}
Private nTotTTp    := 0
Private nTotPec    := 0
Private nTotSrv    := 0
Private nTotDes    := 0

Private aHdFec     := {{},{},{},{}}
Private aClFec     := {{},{},{},{}}
Private nTtTTpa    := 0
Private nTtPeca    := 0
Private nTtSrva    := 0
Private nTtDesa    := 0
Private oTtSrv02, oTtPec02, oTtDes02, oTtTtp02
Private oTtSrv03, oTtPec03, oTtDes03, oTtTtp03
Private lFlagVet   := .t.

Private n := 1  // Esta vaviavel esta criada aqui para contornar o problema do MAFISREF que exige a existencia desta variavel com conteudo, uma vez que esse programa nao usa "acols"
Private oGetPecSin  // 01
Private oGetPecAna  // 02
Private oGetSrvSin  // 03
Private oGetSrvAna  // 04
Private nUsado01 := 0
Private nUsado02 := 0
Private nUsado03 := 0
Private nUsado04 := 0
Private lFlag01
Private lFlag03
Private aAlter := {}
Private nBroAtu := 0
Private cKeyAce := ""
Private nTotEntr := 0

nControl++

Private aPos
Private nDesPec := 0,nDesSrv := 0

Private aHeader := {}
Private aCols   := {}
//Private aTELA[0][0], aGETS[0], aHeader[0]

Private aSvAtela := {{},{},{},{}}
Private aSvAGets := {{},{},{},{}}
Private aTela :={}
Private aGets :={}

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private nOpcE := 2     // Visualizar
Private nOpcG := 4     // Alterar
Private cObsNF := " "

If !(&cCond160)
	//Help(" ",1,"M160CLICAD")   // Cliente NAO cadastrado
	FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
	Return .f.
EndIf
nOpc := 4

dbSelectArea("SX3")
dbSeek("VSF")

While x3_arquivo == "VSF" .and. !eof()

	if X3USO(x3_usado) .and. cNivel>=x3_nivel .and. !(X3_CAMPO $ "VSF_NUMOSV/VSF_TIPFEC/VSF_TIPTEM")
		AADD(aSegEnc,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	Private &wVar:= CriaVar(x3_campo)

	DbSkip()

EndDo

Do Case

	Case cParam01 == 1     // Fechamento Individual

		DbSelectArea("VOO")
		DbSetOrder(1)
		DbSelectArea("VO1")
		aVetTTp := {}

		If !FG_SEEK("VOO","VO1->VO1_NUMOSV",1,.F.)

			FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
			return .t.

		Else

			cMsgLoja := ""

			dbSelectArea("VOO")
			While VO1->VO1_NUMOSV == VOO->VOO_NUMOSV .and. VO1->VO1_FILIAL == xFilial("VO1")  .and. !eof()

				FG_SEEK("SA1","VOO->VOO_FATPAR+VOO->VOO_LOJA",1,.f.)
				FG_SEEK("VOI","VOO->VOO_TIPTEM",1,.f.)
				If Empty(VOO->VOO_NUMNFI)
					If !Empty(VOO->VOO_PESQLJ)
						SL1->(DbSetOrder(1))
						If SL1->(DbSeek(xFilial("SL1")+VOO->VOO_PESQLJ))
							cMsgLoja += STR0147 + ": " + VOO->VOO_TIPTEM + "    " + STR0202 + ": " + VOO->VOO_PESQLJ + CHR(13) + CHR(10) // "Tipo de tempo" # "Orçamento Loja"
							VOO->(dbSkip())
							Loop
						EndIf
					Else
						DbSelectArea("VSC")
						DbSetOrder(1)
						If !DbSeek(xFilial("VSC")+VOO->VOO_NUMOSV+VOO->VOO_TIPTEM)
							dbSelectArea("VOO")
							aAdd(aVetTTp,{.f.,VOO_NUMOSV,VOO_TIPTEM,VOO_FATPAR,left(SA1->A1_NOME,30),Transform(VOO_TOTPEC,"@E 9999,999.99"),Transform(VOO_HRSPAD,"@R 999:99"),Transform(VOO_HRSAPL,"@R 999:99"),Transform(VOO_TOTSRV,"@E 9999,999.99"),SA1->A1_LOJA})
						Endif
					Endif
				EndIf

				dbSelectArea("VOO")
				dbSkip()

			EndDo

			If !Empty(cMsgLoja)
				MsgInfo(STR0203 + CHR(13) + CHR(10) + CHR(13) + CHR(10) + cMsgLoja ,STR0133 ) // "Tipo(s) de Tempo com orçamento(s) pendente(s) no Loja"
			EndIf

			If Len(aVetTTp) == 0
				FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
				return .t.
			EndIf

			aVetTTpa := aClone(aVetTTp)

			dbSelectArea("VO1")

		EndIf

		//RegToMemory("VO1",.T.)
		DbSelectArea("VO1")
		For nCntFor := 1 TO FCount()
			&( "M->"+EVAL(bCampo,nCntFor) ) := FieldGet(nCntFor)
		Next

		dbSelectArea("SX3")
		dbSeek("VO1")
		aCpoEnchoice := {}

		While x3_arquivo == "VO1" .and. !eof()

			If X3USO(x3_usado) .and. cNivel>=x3_nivel

				If alltrim(X3_CAMPO) $ "VO1_MOTIVO/VO1_DESMOT/VO1_GETKEY/VO1_FATPAR/VO1_LOJA/VO1_NOMFAT/VO1_TEMCAN/VO1_DATENT/VO1_HORENT/VO1_STATUS/VO1_TEMGAR/VO1_TEMLIB/VO1_MECREQ/VO1_EXPGAR/VO1_SITGAR/VO1_CODMAR/VO1_TEMFEC/VO1_NATURE"
					dbSkip()
					loop
				EndIf

				aAdd(aCpoEnchoice,x3_campo)

				If x3_context == "V"
					&( "M->"+x3_campo ) := CriaVar(x3_campo)
				EndIf

			Endif
			dbSkip()

		EndDo

		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next

		If lVO1_NATURE
			cVO1_NATURE := VO1->VO1_NATURE
		EndIf
		aAdd(aOS_GRV,{VO1->VO1_NUMOSV})

		FG_SEEK("VV1","VO1->VO1_CHAINT",1,.f.)

		M->VO1_DATSAI := VO1->VO1_DATSAI
		M->VO1_HORSAI := VO1->VO1_HORSAI
		M->VO1_NUMOSV := VO1->VO1_NUMOSV
		M->VO1_GETKEY := VV1->VV1_CHASSI
		M->VO1_CHASSI := VV1->VV1_CHASSI
		M->VO1_CHAINT := VV1->VV1_CHAINT
		M->VO1_PLAVEI := VV1->VV1_PLAVEI
		M->VO1_CODFRO := VV1->VV1_CODFRO

		FG_SEEK("SA1","VOO->VOO_FATPAR",1,.f.)
		if lA1_IBGE
			FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
		endif
		M->VO1_NCLIFT := SA1->A1_NREDUZ
		M->VO1_ENDCLI := SA1->A1_END
		if lA1_IBGE
			M->VO1_CIDCLI := VAM->VAM_DESCID
			M->VO1_ESTCLI := VAM->VAM_ESTADO
		else
			M->VO1_CIDCLI := SA1->a1_MUN
			M->VO1_ESTCLI := SA1->A1_EST
		endif
		M->VO1_FONCLI := SA1->A1_TEL

		If FG_SEEK("VV1","VO1->VO1_CHAINT",1,.f.)
			FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
			FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
			FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
			FG_SEEK("SA1","VV1->VV1_PROATU",1,.f.)
			if lA1_IBGE
				FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
			endif

			M->VO1_DESMAR := Alltrim(VE1->VE1_DESMAR)
			M->VO1_DESMOD := VV2->VV2_DESMOD
			M->VO1_CHAINT := VV1->VV1_CHAINT
			M->VO1_CHASSI := VV1->VV1_CHASSI
			M->VO1_PLAVEI := VV1->VV1_PLAVEI
			M->VO1_CODFRO := VV1->VV1_CODFRO
			M->VO1_FABMOD := VV1->VV1_FABMOD
			M->VO1_DESCOR := VVC->VVC_DESCRI
			M->VO1_PROVEI := SA1->A1_COD
			M->VO1_NOMPRO := SA1->A1_NOME
			M->VO1_ENDPRO := SA1->A1_END
			if lA1_IBGE
				M->VO1_CIDPRO := VAM->VAM_DESCID
				M->VO1_ESTPRO := VAM->VAM_ESTADO
			else
				M->VO1_CIDPRO := SA1->A1_MUN
				M->VO1_ESTPRO := SA1->A1_EST
			endif
			M->VO1_FONPRO := SA1->A1_TEL
			M->VO1_NUMBOX := VO1->VO1_NUMBOX
			M->VO1_CODMOT := VO1->VO1_CODMOT
			M->VO1_KILOME := VO1->VO1_KILOME

		EndIf

		aPos := { 001,002,162,315 }
		cAliasGetD := "VO3"
		cLinOk     := "allwaystrue()"
		cTudOOk    := "allwaystrue()"
		cFieldOk   := "allwaystrue()"
		nLinhas    := 99


	Case cParam01 == 2

		dbSelectArea("VOO")
		nNumReg := recno()
		dbSeek(xFilial("VOO"))

		while VOO->VOO_FILIAL == xFilial("VOO") .and. !eof()
			If IsMark("VOO_OK",ThisMark(),ThisInv()) // Se Marcado
				nQtdReg ++
				aAdd(aVOOAgrup,{VOO->VOO_NUMOSV,VOO->VOO_TIPTEM}) // utilizado para "Controle de Valor de Garantia por periodo"

				// Verifica se o TT foi liberado parcialmente ...
				If OM160LIBP( VOO->VOO_NUMOSV,VOO->VOO_TIPTEM )
					MsgStop(STR0201) // Tipo de tempo liberado parcialmente, não será possível continuar através desta rotina
					nQtdReg := 0
					Exit
				EndIf
				//

			EndIf
			dbSkip()
		Enddo

		If nQtdReg == 0
			Help(" ",1,"M160SEMVOO")   // Nao Foi selecionado nenhum registro
			FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
			return .t.
		EndIf
		dbGoTo(nNumReg)

		*** Cria Variaveis M->????? da Enchoice ***************************************

		If !FG_SEEK("SA1","VOO->VOO_FATPAR",1,.F.)
			FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
			return .t.
		EndIf

		DbSelectArea("SA1")
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("SA1")
		aCpoEnchoice := {}

		While x3_arquivo == "SA1" .and. !eof()

			if X3USO(x3_usado).and.cNivel>=x3_nivel
				If Alltrim(x3_campo) $ "A1_COD/A1_LOJA/A1_NOME/A1_END/A1_BAIRRO/A1_MUN/A1_EST/A1_CEP/A1_FONE/A1_CGC/A1_LC/A1_SALDUP/A1_ATR"
					AADD(aCpoEnchoice,x3_campo)
				EndIf
			Endif
			dbSkip()

		EndDo

		dbSelectArea("VOO")
		dbSeek(xFilial("VOO"))

		nTotDes := 0
		nTotPec := 0

		while VOO->VOO_FILIAL == xFilial("VOO") .and. !eof()

			If IsMark("VOO_OK",ThisMark(),ThisInv()) // Se Marcado

				If lVO1_NATURE
					FG_SEEK("VO1","VOO->VOO_NUMOSV",1,.f.)
					//					If !Empty(VO1->VO1_NATURE)
					if lVO1_NATSRV
						cVO1_NATURE := VO1->VO1_NATURE
						cVO1_NATSRV := VOO->VOO_NATSRV
					endif
					//					EndIf
					aAdd(aOS_GRV,{VO1->VO1_NUMOSV})
				EndIf
				aAdd(aVetOSv,{VOO_NUMOSV,VOO_TIPTEM,VOO_FATPAR,SA1->A1_NREDUZ,VOO_TOTPEC,VOO_HRSPAD,VOO_HRSAPL,VOO_TOTSRV,SA1->A1_LOJA} )

			EndIf

			dbSelectArea("VOO")
			dbSkip()

		Enddo

		If ExistBlock("OM160TIK")
			lRetPE := ExecBlock("OM160TIK",.f.,.f.,{cParam01})
			If !lRetPE
				FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
				Return (.f.)
			Endif
		Endif

		aPos := { 001,002,103,312 }
		cAliasGetD := "VO3"
		cLinOk     := "allwaystrue()"
		cTudOOk    := "allwaystrue()"
		cFieldOk   := "allwaystrue()"
		nLinhas    := 99

	Case cParam01 == 3

		dbSelectArea("VF4")
		dbSeek(xFilial("VF4"))
		While VF4->VF4_FILIAL == xFilial("VF4") .and. !eof()
			If IsMark("VF4_OK",ThisMark(),ThisInv()) // Se Marcado
				If !FG_SEEK("SA1","VF4->VF4_PROVEI",1,.F.)
					FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
					return .t.
				EndIf
				nQtdReg ++
			EndIf
			dbSelectArea("VF4")
			dbSkip()
		Enddo

		If nQtdReg == 0
			Help(" ",1,"M160SEMKIL")   // Nao foi selecionado nenhuma kilometragem
			FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
			return .t.
		EndIf


		aAdd(aParamBox,{1,RetTitle("VO1_FATPAR"),cParam02,"","","SA1","",0,.T.}) // Tipo caractere
		aAdd(aParamBox,{1,RetTitle("VO1_LOJA")  ,cParam03,"","",""   ,"",0,.T.}) // Tipo caractere

		While .T.
			If ParamBox(aParamBox,STR0204,@aRet,,,,,,,,.F.)
				SA1->(DbSetOrder(1))
				If SA1->(DbSeek(xFilial("SA1")+aRet[1]+aRet[2]))
					cPar02Sv := cParam02
					cPar03Sv := cParam03
					cParam02 := aRet[1]
					cParam03 := aRet[2]
					MV_PAR01 := aRet[1]
					MV_PAR02 := aRet[2]
					Exit
				EndIf
			Else
				Return
			EndIf
		EndDo 


		*** Cria Variaveis M->????? da Enchoice ***************************************

		DbSelectArea("SA1")
		For nCntFor := 1 TO FCount()
			M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
		Next

		dbSelectArea("SX3")
		dbSetOrder(1)
		dbSeek("SA1")
		aCpoEnchoice := {}

		While x3_arquivo == "SA1" .and. !eof()

			if X3USO(x3_usado).and.cNivel>=x3_nivel
				If Alltrim(x3_campo) $ "A1_COD/A1_LOJA/A1_NOME/A1_END/A1_BAIRRO/A1_MUN/A1_EST/A1_CEP/A1_FONE/A1_CGC/A1_LC/A1_SALDUP/A1_ATR"
					AADD(aCpoEnchoice,x3_campo)
				EndIf
			Endif
			dbSkip()

		EndDo

		dbSelectArea("VF4")
		dbSetOrder(2)
		dbSeek(xFilial("VF4"))

		nTotDes := 0
		nTotPec := 0

		while VF4->VF4_FILIAL == xFilial("VF4") .and. !eof()

			If IsMark("VF4_OK",ThisMark(),ThisInv()) .and.;
				Empty(VF4->VF4_NUMOSV) // Se Marcado
//				cParam02 == VF4->VF4_PROVEI .and.;
//				cParam03 == VF4->VF4_LOJPRO .and.;

				FG_SEEK("VO5","VF4->VF4_CHAINT",1,.f.)
				FG_SEEK("VV1","VF4->VF4_CHAINT",1,.f.)
				FG_SEEK("SA1","VV1->VV1_PROATU+VV1->VV1_LJPATU",1,.f.)
				If lVO1_NATURE
					FG_SEEK("VO1","VF4->VF4_NUMOSV",1,.f.)
					If !Empty(VO1->VO1_NATURE)
						cVO1_NATURE := VO1->VO1_NATURE
					EndIf
					aAdd(aOS_GRV,{VO1->VO1_NUMOSV})
				EndIf
				aAdd(aVetKil,{VF4->VF4_CHAINT,VV1->VV1_CHASSI,VF4->VF4_DATKIL,VF4->VF4_KILROD,VV1->VV1_PLAVEI,VV1->VV1_CODFRO,VV1->VV1_PROATU,VV1->VV1_LJPATU,SA1->A1_NREDUZ,Recno()})

			EndIf

			dbSelectArea("VF4")
			dbSkip()
		Enddo

		dbSetOrder(1)

		//        aSort(aVetKil,1,,{ |x,y| x[1]+dtos(x[3]) < y[1]+dtos(y[3])})

		aPos := { 001,002,103,312 }
		cAliasGetD := "VO3"
		cLinOk     := "allwaystrue()"
		cTudOOk    := "allwaystrue()"
		cFieldOk   := "allwaystrue()"
		nLinhas    := 99

EndCase

// Variavel que controla cliente periodico
Do Case
	Case cParam01 == 1     // Fechamento Individual
		FG_SEEK("SA1","VV1->VV1_PROATU",1,.f.)
	Case cParam01 == 2     // Fechamento Individual
		FG_SEEK("SA1","VOO->VOO_FATPAR",1,.F.)
	Case cParam01 == 3     // Fechamento Individual
		FG_SEEK("SA1","cParam02",1,.F.)
EndCase

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aCols e aHeader da Condicao de Pagamento             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsadoC:=0
DbSelectArea("SX3")
DbSeek("VS9")
aHeaderC:={}
While !Eof().And.(x3_arquivo=="VS9")
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG#VS9_OBSERV#VS9_SEQUEN#VS9_PORTAD#VS9_DESPOR/VS9_TIPTEM#VS9_NATURE#VS9_NATSRV#VS9_CARTEI")
		nUsadoC++
		Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
		x3_tamanho, x3_decimal,x3_valid,;
		x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )

	Endif
	&("M->"+Alltrim(x3_campo)) := CriaVar(x3_campo)
	dbSkip()
EndDo

dbSelectArea("VS9")
dbSetOrder(2)
if dbSeek(xFilial("VS9")+strzero(cParam01,1)+VO1->VO1_NUMOSV)
	aColsC := {}
	nC := 1
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. VS9->VS9_NUMIDE == VO1->VO1_NUMOSV .and. VS9->VS9_TIPFEC == strzero(cParam01,1)

		If VS9->(FieldPos("VS9_TIPTEM")) <> 0
			If VS9->VS9_TIPTEM <> VOO->VOO_TIPTEM
				DbSkip()
				Loop
			Endif
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o aCols da Entrada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		AADD(aColsC,Array(nUsadoC+1))
		For _ni:=1 to nUsadoC
			aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
			aColsC[Len(aColsC),Len(aColsC[Len(aColsC)])] := .f.
		Next
		DbSkip()
	Enddo
	aHeader := aClone(aHeaderC)
	aCols   := aClone(aColsC)
Endif

dbSelectArea("VO1")
dbSetOrder(1)
FS_CRIA_AHEADER('VO3',1,'VO3_GRUITE/VO3_DESGRU/VO3_VALBRU/VO3_PERDES/VO3_VALDES/VO3_VALTOT','VO3_GRUITE/VO3_DESGRU/VO3_CODITE/VO3_DESITE/VO3_QTDREQ/VO3_VALPEC/VO3_VALBRU')
FS_CRIA_AHEADER('VO3',2,'VO3_GRUITE/VO3_CODITE/VO3_DESITE/VO3_QTDREQ/VO3_VALPEC/VO3_OPER/VO3_CODTES/VO3_VALBRU/VO3_PERDES/VO3_VALDES/VO3_VALTOT/VO3_ALQICM/VO3_VALICM/VO3_DEPINT/VO3_DEPGAR/VO3_NUMLOT/VO3_LOTECT/VO3_NUMSER/VO3_FORMUL/VO3_PEDXML/VO3_ITEXML','VO3_GRUITE/VO3_DESGRU/VO3_CODITE/VO3_DESITE/VO3_QTDREQ/VO3_VALPEC/VO3_VALBRU/VO3_ALQICM/VO3_VALICM/VO3_DEPINT/VO3_DEPGAR/VO3_NUMLOT/VO3_LOTECT/VO3_NUMSER/VO3_FORMUL')
If cParam01 < 3
	FS_CRIA_AHEADER('VO4',3,'VO4_TIPSER/VO4_DESTPS/VO4_TEMPAD/VO4_TEMTRA/VO4_OPER/VO4_CODTES/VO4_VALBRU/VO4_PERDES/VO4_VALDES/VO4_VALTOT/VO4_FORMUL','VO4_TIPSER/VO4_DESTPS/VO4_TEMPAD/VO4_TEMTRA/VO4_FORMUL')
	FS_CRIA_AHEADER('VO4',4,'VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_TIPSER/VO4_DESTPS/VO4_KILATU/VO4_KILROD/VO4_VALBRU/VO4_PERDES/VO4_VALDES/VO4_VALTOT/VO4_TEMPAD/VO4_TEMTRA/VO4_TEMCOB/VO4_TEMVEN','VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_TIPSER/VO4_DESTPS/VO4_KILATU/VO4_TEMPAD/VO4_TEMTRA/VO4_TEMCOB/VO4_TEMVEN')
Else
	FS_CRIA_AHEADER('VO4',3,'VO4_TIPSER/VO4_DESTPS/VO4_TEMPAD/VO4_TEMTRA/VO4_OPER/VO4_CODTES/VO4_VALBRU/VO4_PERDES/VO4_VALDES/VO4_VALTOT','VO4_TIPSER/VO4_DESTPS')
	FS_CRIA_AHEADER('VO4',4,'VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_TIPSER/VO4_DESTPS/VO4_KILATU/VO4_KILROD/VO4_VALBRU/VO4_PERDES/VO4_VALDES/VO4_VALTOT/VO4_CHASSI','VO4_GRUSER/VO4_CODSER/VO4_DESSER/VO4_TIPSER/VO4_DESTPS/VO4_KILATU')
EndIf

SETAPILHA()

If lVO1_NATURE
	dbSelectArea("SX3")
	dbSetOrder(2)
	If dbSeek("VO1_NATURE")
		if Empty(cVO1_NATURE)
			cVO1_NATURE := space(SX3->X3_TAMANHO)
		endif
		If !Empty(SX3->X3_RELACAO)
			cVO1_NATURE := left(&(SX3->X3_RELACAO)+space(SX3->X3_TAMANHO),SX3->X3_TAMANHO)
		EndIf
	EndIf
	If dbSeek("VOO_NATSRV")
		if Empty(cVO1_NATSRV)
			cVO1_NATSRV := space(SX3->X3_TAMANHO)
		endif
		If !Empty(SX3->X3_RELACAO)
			cVO1_NATSRV := left(&(SX3->X3_RELACAO)+space(SX3->X3_TAMANHO),SX3->X3_TAMANHO)
		EndIf
	EndIf
	dbSetOrder(1)
	dbSelectArea("VO1")
EndIf


DEFINE MSDIALOG oDlgFechamento FROM 001,000 TO 036,080 TITLE cTitle OF oMainWnd

SetEnch("")
oFolderFEC := TFolder():New(001,000,aTitles,aPages,oDlgFechamento,,,,.F.,.F.,316,252,)
oFolderFEC:bChange := { || Processa( { || FS_TRAABA() }) }

FG_INIFOLDER("oFolderFEC")

Do Case
	Case cParam01 == 1   // Fechamento Individual de Ordem de Servico

		aTela := {}
		aGets := {}
		dbSelectArea("VO1")
		Zero()
		//criado panel pois nao respeitava os tamanhos em MDI - Rafael 09/11
		@ 001,002 MSpanel oPanel1 VAR "" OF oFolderFEC:aDialogs[1] SIZE 313,162 LOWERED
		//
		oGetEnchoice := MsMGet():New("VO1",nReg,nOpcE, , , ,aCpoEnchoice,aPos,,2,,,,oPanel1,,.t.,.f.,"aSvATela[1]")
		oGetEnchoice:oBox:bGotFocus  := {|| FS_Entra(1,"VO1")}
		oGetEnchoice:oBox:bLostFocus := {|| FS_Sai(1)}
		aSvATela[1] := aClone(aTela)
		aSvAGets[1] := aClone(aGets)


		If len(aVetTTp) > 0

			@ 163,001 TO 238,313 LABEL OemToAnsi(STR0038) OF oFolderFEC:aDialogs[1] PIXEL
			@ 170,003 LISTBOX oVetTTp FIELDS HEADER OemToAnsi(STR0039),;
			OemToAnsi(STR0040),;
			OemToAnsi(STR0041),;
			OemToAnsi(STR0042),;
			OemToAnsi(STR0043),;
			OemToAnsi(STR0044),;
			OemToAnsi(STR0045),;
			OemToAnsi(STR0046),;
			OemToAnsi(STR0053);
			COLSIZES 10,30,10,30,70,45,25,25,40;
			SIZE 308,066 OF oFolderFEC:aDialogs[1] ON DBLCLICK(Processa( { || ProcRegua(4),FS_LISTBOX(cParam01),IIf(aVetTTp[oVetTTp:nAt,1],FS_OBSNF(),.t.)}))  PIXEL

			oVetTtp:SetArray(aVetTtp)
			oVetTtp:bLine := { || {  If(aVetTtp[oVetTtp:nAt,1],oOk,oNo) ,;
			aVetTtp[oVetTtp:nAt,2] ,;
			aVetTtp[oVetTtp:nAt,3] ,;
			aVetTtp[oVetTtp:nAt,4]+"-"+aVetTtp[oVetTtp:nAt,10] ,;
			aVetTtp[oVetTtp:nAt,5] ,;
			aVetTtp[oVetTtp:nAt,6] ,;
			aVetTtp[oVetTtp:nAt,7] ,;
			aVetTtp[oVetTtp:nAt,8] ,;
			aVetTtp[oVetTtp:nAt,9]}}

		EndIf

	Case cParam01 == 2   // Fechamento Agrupado de Ordem de Servico

		FS_LISTBOX(cParam01)

		aTela := {}
		aGets := {}
		dbSelectArea("SA1")
		Zero()
		oGetEnchoice := MsMGet():New("SA1",nReg,nOpcE, , , ,aCpoEnchoice,aPos,,2,,,,oFolderFEC:aDialogs[1],,.t.,.f.,"aSvATela[1]",.t.)
		oGetEnchoice:oBox:bGotFocus  := {|| FS_Entra(1,"SA1")}
		oGetEnchoice:oBox:bLostFocus := {|| FS_Sai(1)}
		aSvATela[1] := aClone(aTela)
		aSvAGets[1] := aClone(aGets)

		dbSelectArea("VO1")

		@ 105,001 TO 238,313 LABEL OemToAnsi(STR0048) OF oFolderFEC:aDialogs[1] PIXEL
		@ 110,003 LISTBOX oVetOsv FIELDS HEADER OemToAnsi(STR0049),;
		OemToAnsi(STR0050),;
		OemToAnsi(STR0051),;
		OemToAnsi(STR0052),;
		OemToAnsi(STR0053);
		COLSIZES 35,65,55,55,65 ;
		SIZE 308,126 OF oFolderFEC:aDialogs[1] PIXEL

		oVetOsv:SetArray(aVetOsv)
		oVetOsv:bLine := { || { aVetOsv[oVetOsv:nAt,1] ,;
		Transform(aVetOsv[oVetOsv:nAt,5],"@ez 999,999,999.99") ,;
		Transform(aVetOsv[oVetOsv:nAt,6],"@R 999:99") ,;
		Transform(aVetOsv[oVetOsv:nAt,7],"@R 999:99") ,;
		Transform(aVetOsv[oVetOsv:nAt,8],"@R 999,999,999.99")}}

	Case cParam01 == 3   // Fechamento de OS de Kilometragem (Acordo de Manutencao)
      
		aTela := {}
		aGets := {}
		dbSelectArea("SA1")
		Zero()
		oGetEnchoice := MsMGet():New("SA1",nReg,nOpcE, , , ,aCpoEnchoice,aPos,,2,,,,oFolderFEC:aDialogs[1],,.t.,.f.,"aSvATela[1]",.t.)
		oGetEnchoice:oBox:bGotFocus  := {|| FS_Entra(1,"SA1")}
		oGetEnchoice:oBox:bLostFocus := {|| FS_Sai(1)}
		aSvATela[1] := aClone(aTela)
		aSvAGets[1] := aClone(aGets)

		dbSelectArea("VO1")

		@ 105,001 TO 238,313 LABEL OemToAnsi(STR0054) OF oFolderFEC:aDialogs[1] PIXEL
		@ 110,003 LISTBOX oVetKil FIELDS HEADER OemToAnsi(STR0055),;
		OemToAnsi(STR0056),;
		OemToAnsi(STR0057),;
		OemToAnsi(STR0058),;
		OemToAnsi(STR0059),;
		OemToAnsi(STR0060),;
		OemToAnsi(STR0061),;
		OemToAnsi(STR0062),;
		OemToAnsi();
		COLSIZES 20,55,25,25,30,25,25,15,45 ;
		SIZE 308,126 OF oFolderFEC:aDialogs[1] PIXEL

		oVetKil:SetArray(aVetKil)
		oVetKil:bLine := { || { aVetKil[oVetKil:nAt,1],;
		aVetKil[oVetKil:nAt,2],;
		aVetKil[oVetKil:nAt,3],;
		Transform(aVetKil[oVetKil:nAt,4],"@ez 999,999,999"),;
		aVetKil[oVetKil:nAt,5],;
		aVetKil[oVetKil:nAt,6],;
		aVetKil[oVetKil:nAt,7],;
		aVetKil[oVetKil:nAt,8],;
		aVetKil[oVetKil:nAt,9]}}
		oVetKil:SetFocus()

EndCase

*** GetDados para Pecas Analiticas (02) ***************************************

dbselectarea('VO3')
RegToMemory('VO3')

aHeader  := aClone(aHeaderFEC[2])
aCols    := aClone(FS_CRIA_ACOLS(2))
n        := len(aCols)

If cParam01 > 1  // Reposicionamento no SA1, devido desposicionamento causado pelo regtomemory

	FG_SEEK("SA1","cParam02+cParam03",1,.F.)

EndIf

@ 066,001 TO 221,313 LABEL OemToAnsi(STR0064) OF oFolderFEC:aDialogs[2] PIXEL
oGetPecAna  := MSGetDados():New(073,003,219,311, nOpc,,,If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),.t.,aAlter[2],1,,,"FS_FIELDOK()",,,,oFolderFEC:aDialogs[2])
oGetPecAna:oBrowse:bGotFocus        :={|| FS_ENTFOC(2) }
oGetPecAna:oBrowse:bLostFocus       :={|| FS_SAIFOC(2) }
oGetPecAna:oBrowse:bChange          :={|| FG_MEMVAR()  }
oGetPecAna:oBrowse:Default()
oGetPecAna:oBrowse:Refresh()

*** GetDados para Pecas Sint‚tica (01) ****************************************

aHeader         := aClone(aHeaderFEC[1])
aCols           := aClone(FS_CRIA_ACOLS(1))
n               := len(aCols)

dbSelectArea('VO3')
@ 000,001 TO 066,313 LABEL OemToAnsi(STR0065) OF oFolderFEC:aDialogs[2] PIXEL
oGetPecSin  := MSGetDados():New(006,003,064,311,nOpc,,,"",.t.,aAlter[1],1,,,,,,,oFolderFEC:aDialogs[2])
oGetPecSin:oBrowse:bGotFocus        :={|| FS_ENTFOC(1) }
oGetPecSin:oBrowse:bLostFocus       :={|| FS_SAIFOC(1) }
oGetPecSin:oBrowse:bChange          :={|| FG_MEMVAR()  }
oGetPecSin:oBrowse:Default()  // sua presenca/ausencia para facilitar a 'pintura' quando mudar de browse, no caso de atualizar getdados debaixo
oGetPecSin:oBrowse:Refresh()

*** GetDados para Servicos Analiticos (04) ************************************

aHeader         := aClone(aHeaderFEC[4])
aCols           := aClone(FS_CRIA_ACOLS(4))
n               := len(aCols)

dbselectarea('VO4')
RegToMemory('VO4')

If cParam01 > 1    // Reposicionamento no SA1, devido desposicionamento causado pelo regtomemory

	FG_SEEK("SA1","cParam02+cParam03",1,.F.)

	If cParam01 == 2  .or. cParam01 == 3               // Fechamento Agrupado de Ordem de Servico

		FG_SEEK("VOI","cParam04",1,.f.)

	EndIf

EndIf

@ 066,001 TO 221,313 LABEL OemToAnsi(STR0066) OF oFolderFEC:aDialogs[3] PIXEL
oGetSrvAna  := MSGetDados():New(073,003,219,311,nOpc,,,"",.t.,aAlter[4],1,,,,,,,oFolderFEC:aDialogs[3])
oGetSrvAna:oBrowse:bGotFocus        :={|| FS_ENTFOC(4)}
oGetSrvAna:oBrowse:bLostFocus       :={|| FS_SAIFOC(4)}
oGetSrvAna:oBrowse:bChange          :={|| FG_MEMVAR()}
oGetSrvAna:oBrowse:Default()
oGetSrvAna:oBrowse:Refresh()

*** GetDados para Servicos Sinteticos (03) ************************************

aHeader  := aClone(aHeaderFEC[3])
aCols    := aClone(FS_CRIA_ACOLS(3))
n        := len(aCols)

dbselectarea('VO4')
@ 000,001 TO 066,313 LABEL OemToAnsi(STR0067) OF oFolderFEC:aDialogs[3] PIXEL
oGetSrvSin  := MSGetDados():New(6,3,064,311,nOpc,,,"",.t.,aAlter[3],1,,,"FS_FIELDOK()",,,,oFolderFEC:aDialogs[3])
oGetSrvSin:oBrowse:bGotFocus        :={|| FS_ENTFOC(3)}
oGetSrvSin:oBrowse:bLostFocus       :={|| FS_SAIFOC(3)}
oGetSrvSin:oBrowse:bChange          :={|| FG_MEMVAR()}
oGetSrvSin:oBrowse:Default()
oGetSrvSin:oBrowse:Refresh()

If cParam01 == 2                 // Fechamento Agrupado de Ordem de Servico
	//Traz os descontos gravados anteriormente
	For nSalvaAbe := 1 to Len(aVetOsv)
		VO1->( DbSetOrder(1) )
		VO1->( DbSeek( xFilial("VO1") + aVetOsv[nSalvaAbe,1] ) )
		FS_ABRENEG()
	Next
	FS_DESFRAN()
EndIf

@ 221,001 TO 239,058 LABEL (" "+STR0070+" ") OF oFolderFEC:aDialogs[2] PIXEL
@ 227,005 msget oTotDes02 VAR nTotDes Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.
@ 221,060 TO 239,313 LABEL (" "+STR0148+" ") OF oFolderFEC:aDialogs[2] PIXEL		//Totais Liquidos
@ 228,066 Say OemToAnsi(STR0068) SIZE 40,08 OF oFolderFEC:aDialogs[2] PIXEL COLOR CLR_BLUE
@ 227,085 msget oTotPec02 VAR nTotPec Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.
@ 228,145 Say OemToAnsi(STR0069) SIZE 40,08 OF oFolderFEC:aDialogs[2] PIXEL COLOR CLR_BLUE
@ 227,171 msget oTotSrv02 VAR nTotSrv Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.
@ 228,230 Say OemToAnsi(STR0071) SIZE 50,08 OF oFolderFEC:aDialogs[2] PIXEL COLOR CLR_BLUE
@ 227,260 msget oTotTtp02 VAR nTotTTp Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[2] PIXEL COLOR CLR_BLACK when .f.

@ 221,001 TO 239,058 LABEL (" "+STR0070+" ") OF oFolderFEC:aDialogs[3] PIXEL
@ 227,005 msget oTotDes03 VAR nTotDes Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[3] PIXEL COLOR CLR_BLACK when .f.
@ 221,060 TO 239,313 LABEL (" "+STR0148+" ") OF oFolderFEC:aDialogs[3] PIXEL 		//Totais Liquidos
@ 228,066 Say OemToAnsi(STR0068) SIZE 40,08 OF oFolderFEC:aDialogs[3] PIXEL COLOR CLR_BLUE
@ 227,085 msget oTotPec03 VAR nTotPec Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[3] PIXEL COLOR CLR_BLACK when .f.
@ 228,145 Say OemToAnsi(STR0069) SIZE 40,08 OF oFolderFEC:aDialogs[3] PIXEL COLOR CLR_BLUE
@ 227,171 msget oTotSrv03 VAR nTotSrv Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[3] PIXEL COLOR CLR_BLACK when .f.
@ 228,230 Say OemToAnsi(STR0071) SIZE 50,08 OF oFolderFEC:aDialogs[3] PIXEL COLOR CLR_BLUE
@ 227,260 msget oTotTtp03 VAR nTotTTp Picture "@E 999,999,999.99" SIZE 50,08 OF oFolderFEC:aDialogs[3] PIXEL COLOR CLR_BLACK when .f.

If lFlagVet

	lFlagVet   := .f.
	aHdFec     := aClone(aHeaderFEC)
	aClFec     := aClone(aColsFEC)
	nTtTTpa    := nTotTTp
	nTtPeca    := nTotPec
	nTtSrva    := nTotSrv
	nTtDesa    := nTotDes
	oTtSrv02   := oTotSrv02
	oTtPec02   := oTotPec02
	oTtDes02   := oTotDes02
	oTtTtp02   := oTotTtp02
	oTtSrv03   := oTotSrv03
	oTtPec03   := oTotPec03
	oTtDes03   := oTotDes03
	oTtTtp03   := oTotTtp03
	lFlagVet   := .f.

EndIf

If (cPaisLoc == "BRA")
	DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oFolderFEC:aDialogs[4]

	DEFINE BUTTON RESOURCE "SALVAR"   OF oBar ACTION (lSalvou := .F., FS_SALVA()) TOOLTIP STR0151 //Salva os descontos aplicados e a negociacao de pagamento
	DEFINE BUTTON RESOURCE "AUTOM"    OF oBar ACTION  OFMI900("VE6",0,3,{{"VE6_INDREG","1"}},.t.,.f.)      TOOLTIP STR0072
	DEFINE BUTTON RESOURCE "CHAVE2"   OF oBar ACTION  FS_VLIBVEN() TOOLTIP STR0073
	DEFINE BUTTON RESOURCE "PRECO"    OF oBar ACTION  FS_AVAFEC() TOOLTIP STR0074
	If GetMv("MV_VEICHKE",,"N")=="S"
		DEFINE BUTTON RESOURCE "BUDGETY" OF oBar ACTION  (CM540INC(M->VO1_NUMOSV,"O"),oFolderFEC:nOption:=1)	 TOOLTIP OemToAnsi(STR0150)//Check-List de Entrega do Veiculo
	Endif

	bCancel2:= {|| nOpca := 2 }

	oBar:nGroups += 6

	DEFINE BUTTON RESOURCE "BMPGROUP" OF oBar ACTION (ML500A(),aMemos:={{"VS9_OBSERV","VS9_OBSMEM"}},oFolderFEC:nOption:=1) TOOLTIP STR0149 //Registra Abordagem / Reclamacao  // Andre Luis Almeida - 04/03/2008 - Chamada do Registro de Abordagem CEV / RAIC
	DEFINE BUTTON oBtOk1  RESOURCE OemToAnsi(STR0075) OF oBar GROUP ACTION ( Processa( { || cTudoOk, If(FS_FECHAR16(),(FS_VOLTAR(),oDlgFechamento:End()),.t.) },OemtoAnsi(STR0076),"",.t.) ) TOOLTIP OemToAnsi(STR0077)  // "OK"###"Executar Fechamento - <Ctrl-O>"
	DEFINE BUTTON oBtCan1 RESOURCE OemToAnsi(STR0078) OF oBar ACTION (lSalvou := .F., FS_SALVA(), lLoop:=.f.,Eval(bCancel2), oFolderFEC:nOption := 1,oDlgFechamento:End()) TOOLTIP OemToAnsi(STR0079)  //"CANCEL"###"Cancelar - <Ctrl-X>"

	oFolderFEC:aDialogs[4]:bRClicked := {|| AllwaysTrue()}

	Private aRotina   := {{"", "",0,1},;
	{"", "",0,2},;
	{"", "",0,3},;
	{"", "",0,4} }

	FG_TELACOND(oFolderFEC:aDialogs[4],2)

Endif

ACTIVATE DIALOG oDlgFechamento ON INIT ( FS_CHBAR160(oDlgFechamento, {||.t.},{|| nOk := 0,lSalvou:=.t.,FS_SALVA(),FS_VOLTAR(),oDlgFechamento:End()} ), FS_INITEL(), FS_INICIA(),If(cParam01 == 3,oVetKil:SetFocus(),.t.) ) CENTER
MaFisEnd()
SETAPILHA()
FS_VFILTVO1() // Volta Filtro VO1 pelo Usuario
Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_CRIA_AHEADER  ³  Emilton              ³ Data ³ 14/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao de Aheader                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CRIA_AHEADER(cAlias,nF,cCampos,cNaoAltera)
Local aTmpheader := {}
Local nUsado := 0
Local cVar := ""
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
aAdd(aAlter,{})
While !EOF() .And. (x3_arquivo == cAlias)
	If X3USO(x3_usado) .AND. cNivel >= x3_nivel .and. ( Trim(SX3->X3_CAMPO) $ cCampos )
		nUsado++
		AADD(aTmpHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal, x3_valid,x3_usado, x3_tipo, x3_arquivo, x3_context } )
		cVar := "M->"+x3_campo
		&cVar:= CriaVar(x3_campo)
		If !(X3_CAMPO $ cNaoAltera)
			aAdd(aAlter[nF],X3_campo)
		EndIf
	EndIf
	dbSkip()
EndDo
Do Case
	Case nF == 1
		nUsado01 := nUsado
	Case nF == 2
		nUsado02 := nUsado
	Case nF == 3
		nUsado03 := nUsado
	Case nF == 4
		nUsado04 := nUsado
EndCase
aHeaderFec[nF] := aClone(aTmpHeader)
Return aTmpheader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_CRIA_ACOLS ³  Emilton                 ³ Data ³ 14/02/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Criacao de ACOLS                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CRIA_ACOLS(nF)
Do Case
	Case nF == 1
		If cParam01 == 1 .and. lFlagProc
			IncProc(STR0080)
		EndIf
		FS_TTPECA("NORMAL")
	Case nF == 2
		If cParam01 == 1 .and. lFlagProc
			IncProc(STR0081)
		EndIf
		FS_PECACOLS()
	Case nF == 3
		If cParam01 == 1 .and. lFlagProc
			IncProc(STR0082)
		EndIf
		FS_TTSRVC("NORMAL")
	Case nF == 4
		If cParam01 == 1 .and. lFlagProc
			IncProc(STR0083)
		EndIf
		FS_SRVACOLS()
EndCase
cForPeri := SA1->A1_COND
Return aColsFec[nF]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ FS_PECACOLS      ³  Emilton              ³ Data ³ 23/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Preenchimento de Acols de Pecas                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PECACOLS()

Local nSlv
Local ixx     := 0
Local cSelect := alias()
Local nValPec := 0
Local _ni	  := 0
Local i_x	  := 0
Local lVO3VALLIQ := VO3->(FieldPos("VO3_VALLIQ")) <> 0
Local nValPecLiq := 0

nTotTTp := 0

Do Case
	Case cParam01 == 1   // Fechamento Individual

		If ( ( ixx := Ascan(aVetTTp,{|x| x[1]==.t.}) ) # 0 )

			VOO->(DbSetOrder(1))
			VOO->(DbSeek(xFilial("VOO") + aVetTTp[ixx,2] + aVetTTp[ixx,3] ))
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1") + VOO->VOO_FATPAR + VOO->VOO_LOJA ))
			if lA1_IBGE
				FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
			endif
		EndIf
		
		If !MaFisFound('NF')
			If !Empty(SA1->A1_LOJA)
				FP_IniImp(SA1->A1_COD,SA1->A1_LOJA)
				//      MaFisIni(SA1->A1_COD,SA1->A1_LOJA,'C','N',SA1->A1_TIPO,MAFISRelImp())
			EndIf
		Else
			MaFisReprocess(2)
		EndIf
		
		For ixx := 1 to len(aVetTTp)

			If aVetTTp[ixx,01]

				nTotPec := 0

				dbSelectArea("VO2")
				dBSetOrder(1)
				dbSeek(xFilial("VO2") + VO1->VO1_NUMOSV)
				While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. VO2->VO2_FILIAL == xFilial("VO2") .and. !eof()

					If VO2->VO2_TIPREQ == "P"     // Requisicao de Pecas

						dbSelectArea("VO3")
						dBSetOrder(1)
						If FG_SEEK("VO3","VO2->VO2_NOSNUM",1,.f.)

							While VO2->VO2_NOSNUM == VO3->VO3_NOSNUM .and. VO3->VO3_FILIAL == xFilial("VO3") .and. !eof()

								If aVetTTp[ixx,3] != VO3->VO3_TIPTEM
									dbSkip()
									Loop
								EndIf

								FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)
								FG_SEEK("SA1","VO3->VO3_FATPAR+VO3->VO3_LOJA",1,.f.)
								FG_SEEK("VOI","VO3->VO3_TIPTEM",1,.f.)
								FG_SEEK("SBM","VO3->VO3_GRUITE",1,.f.)

								DbSelectArea("VE4")
								DbSetOrder( 1 )
								DbSeek( xFilial("VE4") + SBM->BM_CODMAR )

								Do Case
									Case VOI->VOI_VLPCAC == "1"
										// Valor da Peca com Desconto
										nValPecLiq := nValPec := VO3->VO3_VALPEC
										IF lVO3VALLIQ .and. VO3->VO3_VALLIQ <> 0
											nValPecLiq := VO3->VO3_VALLIQ
										ENDIF
									Case VOI->VOI_VLPCAC == "2"
										nValPecLiq := nValPec := FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)
								EndCase

								// Devolucao de Pecas
								If VO2->VO2_DEVOLU == "0"   
									ix1 := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == VO3->VO3_GRUITE+VO3->VO3_CODITE } )
									If ix1 > 0
										aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] -= VO3->VO3_QTDREQ

										aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] := NoRound( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] - (VO3->VO3_QTDREQ * nValPec)) / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ,2)
										aColsFEC[2,ix1,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] -= VO3->VO3_QTDREQ * (nValPec - nValPecLiq)
										aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] * aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)]
										aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

										If VO3->(FieldPos("VO3_PEDXML")) <> 0
											aColsFEC[2,ix1,FS_POSVAR("VO3_PEDXML","aHeaderFEC",2)] := VO3->VO3_PEDXML
											aColsFEC[2,ix1,FS_POSVAR("VO3_ITEXML","aHeaderFEC",2)] := VO3->VO3_ITEXML
										Endif

										FS_BOQPEC(VO2->VO2_FUNREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)
										FS_BOQPEC(VO3->VO3_PROREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)
									Endif
									dbSelectArea("VO3")
									dbSkip()
									Loop

								// Requisicao de Pecas
								Else                        

									ix1 := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == VO3->VO3_GRUITE+VO3->VO3_CODITE } )

									If ix1 == 0

										If !empty(aColsFEC[2,1,1])

											aAdd(aColsFEC[2],Array(nUsado02+1))

										EndIf

										aColsFEC[2,len(aColsFEC[2]),nUsado02+1] := .f.

										For _ni:=1 to nUsado02
											aColsFEC[2,len(aColsFEC[2]),_ni] := CriaVar(aHeaderFEC[2,_ni,2])
										Next

										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] := VO3->VO3_GRUITE
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] := VO3->VO3_CODITE
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_DESITE","aHeaderFEC",2)] := SB1->B1_DESC
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] := VO3->VO3_QTDREQ

										FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)
										SF4->(dbSetOrder(1))
										SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
										cOrigB1 := Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB

										If VO3->(FieldPos("VO3_OPER") ) > 0
											aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_OPER","aHeaderFEC",2)]   := VO3->VO3_OPER
											If !Empty(VO3->VO3_OPER)
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := MaTesInt(2,VO3->VO3_OPER,VO3->VO3_FATPAR,VO3->VO3_LOJA,"C",SB1->B1_COD)
											Else
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
											Endif
										Else
											If !Empty(VO3->VO3_CODTES)
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := VO3->VO3_CODTES
											Else
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := FG_TABTRIB(VOI->VOI_CODOPE,cOrigB1,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"))
											EndIf
										Endif

										If VO3->(FieldPos("VO3_PEDXML")) <> 0
											aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_PEDXML","aHeaderFEC",2)] := VO3->VO3_PEDXML
											aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_ITEXML","aHeaderFEC",2)] := VO3->VO3_ITEXML
										Endif

										FS_BOQPEC(VO2->VO2_FUNREQ,aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)
										FS_BOQPEC(VO3->VO3_PROREQ,aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)

										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] := nValPec
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := VO3->VO3_QTDREQ * (nValPec - nValPecLiq)
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := VO3->VO3_QTDREQ * nValPec
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] := VO3->VO3_QTDREQ * nValPec

										n := len(aColsFEC[2])
										FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_DESITE","aHeaderFEC",2)] := SB1->B1_DESC
										SF4->(dbSetOrder(1))
										If Empty(VO3->VO3_CODTES)
											SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
										Else
											SF4->(dbSeek(xFilial("SF4")+VO3->VO3_CODTES))
										Endif

									Else

										aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] += VO3->VO3_QTDREQ
										FS_BOQPEC(VO2->VO2_FUNREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)
										FS_BOQPEC(VO3->VO3_PROREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)


										aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] := NoRound( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] + (VO3->VO3_QTDREQ * nValPec)) / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ,2)

										aColsFEC[2,ix1,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] += VO3->VO3_QTDREQ * (nValPec - nValPecLiq)

										aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]*aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)]

										aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]*aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)]

										n := ix1
										FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)
										aColsFEC[2,ix1,FS_POSVAR("VO3_DESITE","aHeaderFEC",2)] += SB1->B1_DESC
										SF4->(dbSetOrder(1))
										If Empty(VO3->VO3_CODTES)
											SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
										Else
											SF4->(dbSeek(xFilial("SF4")+VO3->VO3_CODTES))
										Endif

									EndIf

								Endif

								dbSelectArea("VO3")
								dbSkip()

							EndDo

						EndIf

					EndIf

					dbSelectArea("VO2")
					dbSkip()

				EndDo

			EndIf

		Next
		nSlv := n
		n := 1

		*** Ordena Vetor **************************************************************

		aSort(aColsFEC[2],1,,{ |x,y| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] < y[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+y[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]})

		If ( ( ixx := Ascan(aVetTTp,{|x| x[1]==.t.}) ) # 0 )

			VOO->(DbSetOrder(1))
			VOO->(DbSeek(xFilial("VOO") + aVetTTp[ixx,2] + aVetTTp[ixx,3] ))
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1") + VOO->VOO_FATPAR + VOO->VOO_LOJA ))

		EndIf
		cCodCli := SA1->A1_COD
		SF4->(dbSetOrder(1))
		MAFISREF("NF_CODCLIFOR","VO300",cCodcli)
		MAFISREF("NF_LOJA","VO300",SA1->A1_LOJA)
		n:= 0
		For i_x := 1 to len(aColsFec[2])
			if Empty(aColsFEC[2,i_x,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]) .and. Empty(aColsFEC[2,i_x,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)])
				Loop
			Endif
			if aColsFEC[2,i_x,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] == 0 .or. aColsFEC[2,i_x,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] == 0
				Loop
			Endif

			cKeyAce := aColsFEC[2,i_x,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,i_x,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			if FG_SEEK("SB1","cKeyAce",7,.f.)
				n := n+1

				SF4->(dbSeek( xFilial("SF4") + aColsFEC[2,i_x,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] ))

				MaFisIniLoad(n,{	SB1->B1_COD,;
					aColsFEC[2,i_x,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)],;
					" "  ,;
					aColsFEC[2,i_x,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],;
					"",;
					"",;
					SB1->(RecNo()),;	//IT_RECNOSB1
					SF4->(RecNo()),;	//IT_RECNOSF4
					0 }) 			//IT_RECORI
				MaFisLoad("IT_PRODUTO",SB1->B1_COD,n)
				MaFisLoad("IT_QUANT",aColsFEC[2,i_x,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],n)
				MaFisLoad("IT_TES",aColsFEC[2,i_x,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)],n)
				MaFisLoad("IT_VALMERC",Round(aColsFEC[2,i_x,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)],2),n)
				MaFisLoad("IT_DESCONTO",aColsFEC[2,i_x,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)],n)
				MaFisRecal("",n)
				MaFisEndLoad(n,1)

				aColsFEC[2,i_x,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)] := MaFisRet(n,"IT_ALIQICM")
				aColsFEC[2,i_x,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] := MaFisRet(n,"IT_VALICM")
			Endif

		Next
		n := nSlv

		aColsFEC[2] := FS_ITEZER()
		nTotTTp += nTotPec

		If len(aColsFEC[2]) == 0

			aColsFEC[2] := {Array(nUsado02+1)}
			aColsFEC[2,1,nUsado02+1] := .F.
			For _ni:=1 to nUsado02
				aColsFEC[2,1,_ni] := If(aHeaderFEC[2,_ni,10] == "V",If( aHeaderFEC[2,_ni,8] == "C" , space(aHeaderFEC[2,_ni,4]), If( aHeaderFEC[2,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[2,_ni,2]))
			Next

		EndIf

		nTotTTp -= nTotDes

	Case cParam01 == 2          // Fechamento Agrupado

		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1") + cParam02 + cParam03 ))

		nTotPec := 0
		If !MaFisFound('NF')
			If !Empty(SA1->A1_LOJA)
				FP_IniImp(SA1->A1_COD,SA1->A1_LOJA)
				//      MaFisIni(SA1->A1_COD,SA1->A1_LOJA,'C','N',SA1->A1_TIPO,MAFISRelImp())
			EndIf
		Else
			MaFisReprocess(2)
		EndIf

		For ixx := 1 to len(aVetOSv)

			dbSelectArea("VO2")
			DbSetOrder(1)

			cKeyAce := aVetOSv[ixx,01]
			FG_SEEK("VO1","cKeyAce",1,.f.)

			If FG_SEEK("VO2","cKeyAce",1,.f.)

				While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. VO2->VO2_FILIAL == xFilial("VO2") .and. !eof()

					If VO2->VO2_TIPREQ == "P"     // Requisicao de Pecas

						dbSelectArea("VO3")
						DbSetOrder(1)

						If FG_SEEK("VO3","VO2->VO2_NOSNUM",1,.f.)

							While VO2->VO2_NOSNUM == VO3->VO3_NOSNUM .and. VO3->VO3_FILIAL == xFilial("VO3") .and. !eof()

								If cParam04 != VO3->VO3_TIPTEM
									dbSkip()
									Loop
								EndIf

								FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)
								FG_SEEK("SA1","VO3->VO3_FATPAR+VO3->VO3_LOJA",1,.f.)
								FG_SEEK("VOI","VO3->VO3_TIPTEM",1,.f.)
								FG_SEEK("SBM","VO3->VO3_GRUITE",1,.f.)
								SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
								cOrigB1 := Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB

								DbSelectArea("VE4")
								DbSetOrder( 1 )
								DbSeek( xFilial("VE4") + SBM->BM_CODMAR )

								If VO2->VO2_DEVOLU != "0"   // Requisicao de Pecas

									Do Case
										Case VOI->VOI_VLPCAC == "1"
											nValPec := VO3->VO3_VALPEC

										Case VOI->VOI_VLPCAC == "2"
											nValPec := FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)

									EndCase

								EndIf

								If VO2->VO2_DEVOLU == "0"   // Devolucao de Pecas

									ix1 := aScan(aArrPec,{ |x| x[01]+x[02]+x[03] == VO1->VO1_NUMOSV+VO3->VO3_GRUITE+VO3->VO3_CODITE } )
									aArrPec[ix1,04] -= VO3->VO3_QTDREQ

									Do Case
										Case VOI->VOI_VLPCAC == "1"
											nValPec := VO3->VO3_VALPEC

										Case VOI->VOI_VLPCAC == "2"
											nValPec := FG_VALPEC(VO3->VO3_TIPTEM,"VO3->VO3_FORMUL",VO3->VO3_GRUITE,VO3->VO3_CODITE,,.f.,.t.)

									EndCase

									ix1 := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == VO3->VO3_GRUITE+VO3->VO3_CODITE } )

									aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] -= VO3->VO3_QTDREQ

									aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] := NoRound( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] - (VO3->VO3_QTDREQ * nValPec)) / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ,2)

									aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] * aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]

									aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
									If VO3->(FieldPos("VO3_OPER") ) > 0
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_OPER","aHeaderFEC",2)]      := VO3->VO3_OPER
										If !Empty(VO3->VO3_OPER)
											aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := MaTesInt(2,VO3->VO3_OPER,VO3->VO3_FATPAR,VO3->VO3_LOJA,"C",SB1->B1_COD)
										Else
											aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
										Endif
									Else
										If !Empty(VO3->VO3_CODTES)
											aColsFEC[2,ix1,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := VO3->VO3_CODTES
										Else
											aColsFEC[2,ix1,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := FG_TABTRIB(VOI->VOI_CODOPE,cOrigB1,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"))
										EndIf
									EndIf

									aColsFEC[2,ix1,FS_POSVAR("VO3_DESITE","aHeaderFEC",2)] := SB1->B1_DESC

									If VO3->(FieldPos("VO3_PEDXML")) <> 0
										aColsFEC[2,ix1,FS_POSVAR("VO3_PEDXML","aHeaderFEC",2)] := VO3->VO3_PEDXML
										aColsFEC[2,ix1,FS_POSVAR("VO3_ITEXML","aHeaderFEC",2)] := VO3->VO3_ITEXML
									Endif

									FS_BOQPEC(VO2->VO2_FUNREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)
									FS_BOQPEC(VO3->VO3_PROREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)

									dbSelectArea("VO3")
									dbSkip()
									Loop

								Else                        // Requisicao de Pecas

									ix1 := aScan(aArrPec,{ |x| x[01]+x[02]+x[03] == VO1->VO1_NUMOSV+VO3->VO3_GRUITE+VO3->VO3_CODITE } )

									If ix1 == 0

										aAdd(aArrPec,{ VO1->VO1_NUMOSV,VO3->VO3_GRUITE,VO3->VO3_CODITE,VO3->VO3_QTDREQ })

									Else

										aArrPec[ix1,04] += VO3->VO3_QTDREQ

									EndIf

									ix1 := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == VO3->VO3_GRUITE+VO3->VO3_CODITE } )

									If ix1 == 0

										aAdd(aColsFEC[2],Array(nUsado02+1))
										aColsFEC[2,len(aColsFEC[2]),nUsado02+1] := .F.

										For _ni:=1 to nUsado02
											aColsFEC[2,len(aColsFEC[2]),_ni] := CriaVar(aHeaderFEC[2,_ni,2])
										Next

										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] := VO3->VO3_GRUITE
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] := VO3->VO3_CODITE
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] := VO3->VO3_QTDREQ

										If VO3->(FieldPos("VO3_OPER") ) > 0
											aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_OPER","aHeaderFEC",2)]      := VO3->VO3_OPER
											If !Empty(VO3->VO3_OPER)
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := MaTesInt(2,VO3->VO3_OPER,VO3->VO3_FATPAR,VO3->VO3_LOJA,"C",SB1->B1_COD)
											Else
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
											Endif
										Else
											If !Empty(VO3->VO3_CODTES)
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := VO3->VO3_CODTES
											Else
												aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := FG_TABTRIB(VOI->VOI_CODOPE,cOrigB1,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"))
											EndIf
										EndIf

										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_DESITE","aHeaderFEC",2)] := SB1->B1_DESC

										FS_BOQPEC(VO2->VO2_FUNREQ,aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)
										FS_BOQPEC(VO3->VO3_PROREQ,aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)

										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] := nValPec
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := VO3->VO3_QTDREQ * nValPec
										aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] := VO3->VO3_QTDREQ * nValPec

										If VO3->(FieldPos("VO3_PEDXML")) <> 0
											aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_PEDXML","aHeaderFEC",2)] := VO3->VO3_PEDXML
									 		aColsFEC[2,len(aColsFEC[2]),FS_POSVAR("VO3_ITEXML","aHeaderFEC",2)] := VO3->VO3_ITEXML
										Endif

									Else

										aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] += VO3->VO3_QTDREQ
										FS_BOQPEC(VO2->VO2_FUNREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)
										FS_BOQPEC(VO3->VO3_PROREQ,aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],VO2->VO2_DEVOLU)

										aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] := NoRound( ( aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] + (VO3->VO3_QTDREQ * nValPec)) / aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ,2)
										aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] * aColsFEC[2,ix1,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)]
										aColsFEC[2,ix1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] := aColsFEC[2,ix1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

										If VO3->(FieldPos("VO3_PEDXML")) <> 0
											aColsFEC[2,ix1,FS_POSVAR("VO3_PEDXML","aHeaderFEC",2)] := VO3->VO3_PEDXML
									 		aColsFEC[2,ix1,FS_POSVAR("VO3_ITEXML","aHeaderFEC",2)] := VO3->VO3_ITEXML
									 	Endif

									EndIf

								Endif

								dbSelectArea("VO3")
								dbSkip()

							EndDo

						EndIf

					EndIf

					dbSelectArea("VO2")
					dbSkip()

				EndDo

			EndIf

		Next

		n := 0
		cCodCli := SA1->A1_COD
		//If (SA1->A1_PESSOA == "J" .or. SA1->A1_PESSOA == "F" ) .and. !Empty(SA1->A1_INSCR) .and. VAM->VAM_ESTADO <> GETMV("MV_ESTADO")
		//	cCodCli := GetMv("MV_CLIPAD")
		//	cLoja := GetMv("MV_LOJAPAD")
		//Endif
		MAFISREF("NF_CODCLIFOR","VO300",cCodCli)
		MAFISREF("NF_LOJA","VO300",SA1->A1_LOJA)
		For i_x := 1 to len(aColsFec[2])
			if Empty(aColsFEC[2,i_x,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]) .and. Empty(aColsFEC[2,i_x,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)])
				Loop
			Endif
			n := n + 1
			cKeyAce := aColsFEC[2,i_x,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,i_x,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			FG_SEEK("SB1","cKeyAce",7,.f.)
			SF4->(dbSetOrder(1))
			If Empty(VO3->VO3_CODTES)
				SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
			Else
				SF4->(dbSeek(xFilial("SF4")+VO3->VO3_CODTES))
			Endif

			MAFISREF("IT_PRODUTO","VO300",SB1->B1_COD)
			MAFISREF("IT_TES","VO300",aColsFEC[2,i_x,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)])
			MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,i_x,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
			MAFISREF("IT_DESCONTO","VO300",aColsFEC[2,i_x,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)])
			aColsFEC[2,i_x,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)] := MaFisRet(i_x,"IT_ALIQICM")
			aColsFEC[2,i_x,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] := MaFisRet(i_x,"IT_VALICM")

		Next

		aColsFEC[2] := FS_ITEZER()
		nTotTTp += nTotPec

		If len(aColsFec[2]) == 0

			aColsFEC[2]:={Array(nUsado02+1)}
			aColsFEC[2,1,nUsado02+1] := .F.
			For _ni:=1 to nUsado02
				aColsFEC[2,1,_ni] := If(aHeaderFEC[2,_ni,10] == "V",If( aHeaderFEC[2,_ni,8] == "C" , space(aHeaderFEC[2,_ni,4]), If( aHeaderFEC[2,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[2,_ni,2]))
			Next

		EndIf

		*** Ordena Vetor

		aSort(aColsFEC[2],1,,{ |x,y| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] < y[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+y[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]})


	Case cParam01 == 3

		If len(aColsFec[2]) == 0

			aColsFEC[2]:={Array(nUsado02+1)}
			aColsFEC[2,1,nUsado02+1] := .F.
			For _ni:=1 to nUsado02
				aColsFEC[2,1,_ni] := If(aHeaderFEC[2,_ni,10] == "V",If( aHeaderFEC[2,_ni,8] == "C" , space(aHeaderFEC[2,_ni,4]), If( aHeaderFEC[2,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[2,_ni,2]))
			Next

		EndIf

EndCase

If MaFisFound('NF')
	ntotttp := MaFisRet(,"NF_TOTAL")
Endif

dbSelectArea(cSelect)

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_TTPECA  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totaliza Itens Analiticos em Sinteticos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TTPECA(cTipTot)

Local ix4
Local ix6
Local ix1 := 0
Local _ni := 0
Local ix2 := 0

For ix1 := 1 to len(aColsFEC[2])

	If Empty(aColsFEC[2,1,1])
		Loop
	EndIf

	ix4 := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == aColsFEC[2,ix1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)]})

	If ix4 == 0

		If cParam01 == NIL

			If empty(aColsFEC[1,1,1])

				aColsFEC[1]:={Array(nUsado01+1)}

				aColsFEC[1,1,nUsado01+1] := .F.
				For _ni:=1 to nUsado01
					aColsFEC[1,1,_ni]:=CriaVar(aHeaderFEC[1,_ni,2])
				Next

			Else

				aAdd(aColsFEC[1],Array(nUsado01+1))
				aColsFEC[1,len(aColsFEC[1]),nUsado01+1] := .F.

				For _ni:=1 to nUsado01
					aColsFEC[1,len(aColsFEC[1]),_ni]:=CriaVar(aHeaderFEC[1,_ni,2])
				Next

			EndIf

		Else

			If lFlag01

				lFlag01 := .f.

				aColsFEC[1]:={Array(nUsado01+1)}

				aColsFEC[1,1,nUsado01+1] := .F.
				For _ni:=1 to nUsado01
					aColsFEC[1,1,_ni]:=CriaVar(aHeaderFEC[1,_ni,2])
				Next

			Else

				aAdd(aColsFEC[1],Array(nUsado01+1))
				aColsFEC[1,len(aColsFEC[1]),nUsado01+1] := .F.

				For _ni:=1 to nUsado01
					aColsFEC[1,len(aColsFEC[1]),_ni]:=CriaVar(aHeaderFEC[1,_ni,2])
				Next

			EndIf

		EndIf

	EndIf

	If cTipTot == "NORMAL"

		For ix2 := 1 to len(aHeaderFEC[2])

			ix3 := aScan(aHeaderFEC[1],{ |x| x[02] == aHeaderFEC[2,ix2,02] })
			If ix3 == 0
				loop
			Endif
			If aHeaderFEC[1,ix3,08] == "N"
				If aColsFec[1,len(aColsFec[1]),ix3] == nil
					aColsFec[1,len(aColsFec[1]),ix3] := aColsFec[2,ix1,ix2]
				Else
					aColsFEC[1,len(aColsFEC[1]),ix3] += aColsFEC[2,ix1,ix2]
				EndIf
			Else
				aColsFEC[1,len(aColsFEC[1]),ix3] := aColsFEC[2,ix1,ix2]
			EndIf

		Next

	Else

		For ix2 := 1 to len(aHeaderFEC[2])

			ix3 := aScan(aHeaderFEC[1],{ |x| x[02] == aHeaderFEC[2,ix2,02] })
			If ix3 == 0
				loop
			Endif

			ix6 := aScan(aColsFEC[1],{ |x| x[01] == aColsFEC[2,ix1,01] })

			If aHeaderFEC[1,ix3,08] == "N"
				If aColsFec[1,ix6,ix3] == nil
					aColsFec[1,ix6,ix3] := aColsFec[2,ix1,ix2]
				Else
					aColsFEC[1,ix6,ix3] += aColsFEC[2,ix1,ix2]
				EndIf
			Else
				aColsFEC[1,ix6,ix3] := aColsFEC[2,ix1,ix2]
			EndIf

		Next

	EndIf

	For ix2 := 1 to len(aColsFEC[1])

		cKeyAce := aColsFEC[1,ix2,FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)]
		FG_SEEK("SBM","cKeyAce",1,.f.)
		aColsFEC[1,ix2,FS_POSVAR("VO3_DESGRU","aHeaderFEC",1)] := SBM->BM_DESC

	Next

Next

If len(aColsFec[1]) == 0

	aColsFEC[1]:={Array(nUsado01+1)}
	aColsFEC[1,1,nUsado01+1] := .F.
	For _ni:=1 to nUsado01
		aColsFEC[1,1,_ni] := If(aHeaderFEC[1,_ni,10] == "V",If( aHeaderFEC[1,_ni,8] == "C" , space(aHeaderFEC[1,_ni,4]), If( aHeaderFEC[1,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[1,_ni,2]))
	Next

EndIf

*** Ordena Vetor

aSort(aColsFEC[1],1,,{ |x,y| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] < y[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)]})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SRVACOLS³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Levantamento de Servicos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SRVACOLS()
Local ixx     := 0
Local ix1     := 0
Local ix2     := 0
Local ix3     := 0
Local cSelect := Alias()
Local aVetSer := {}
Local aVetKlm := {}
Local cTipAnt := ""
Local cCodAnt := ""
Local cChaAnt := ""
Local aVetAnt := ""
Local nTotTiph:= 0
Local nTotAnth:= 0
Local nTotTipv:= 0
Local nTotTipG:= 0
Local nTotTipo:= 0
Local nTotAntv:= 0
Local nKilIni := 0
Local nKilFin := 0
Local nFaiAnt := 0
Local nValorX := 0   // Variaveis para arredondamento de Rateio
Local nValorY := 0   // Variaveis para arredondamento de Rateio
Local nValorZ := 0   // Variaveis para arredondamento de Rateio
Local _NI	  := 0
Local nVO6_VALSER := 0
Local lVO6_VALSER := VO6->(FieldPos("VO6_VALSER")) > 0
Local lVO4DESCONTO := (VO4->(FieldPos("VO4_PERDES")) > 0 .AND. VO4->(FieldPos("VO4_VALDES")) > 0)

nTotSrv := 0

Do Case
	Case cParam01 == 1     // Fechamento Individual

		For ixx := 1 to len(aVetTTp)

			If aVetTTp[ixx,01]

				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1") + aVetTTp[ixx,04] + aVetTTp[ixx,10] ))

				FP_INIIMP(SA1->A1_COD,SA1->A1_LOJA)

				dbSelectArea("VO2")
				DbSetOrder(1)
				nTotSrv := 0

				If FG_SEEK("VO2","VO1->VO1_NUMOSV",1,.f.)

					While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. VO2->VO2_FILIAL == xFilial("VO2") .and. !eof()

						If VO2->VO2_TIPREQ == "S"     // Requisicao de Servicos

							dbSelectArea("VO4")
							DbSetOrder(1)
							aCodSer := {}

							If FG_SEEK("VO4","VO2->VO2_NOSNUM",1,.f.)

								cTTpAnt := VO4->VO4_TIPTEM

								While VO2->VO2_NOSNUM == VO4->VO4_NOSNUM .and. VO4->VO4_FILIAL == xFilial("VO4") .and. !eof()

									If aVetTTp[ixx,3] != VO4->VO4_TIPTEM
										dbSkip()
										Loop
									EndIf

									FG_SEEK("VOI","VO4->VO4_TIPTEM",1,.f.)
									FG_SEEK("SA1","VO4->VO4_FATPAR+VO4->VO4_LOJA",1,.f.)
									FG_SEEK("VOK","VO4->VO4_TIPSER",1,.f.)
									FG_SEEK("VO6","VO4->VO4_SERINT",1,.f.)

									ix1 := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+x[FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]+x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] == VO4->VO4_TIPSER+VO4->VO4_GRUSER+VO4->VO4_CODSER } )

									If ix1 == 0

										If !empty(aColsFec[4,1,1])

											aAdd(aColsFEC[4],Array(nUsado04+1))

										EndIf

										aColsFEC[4,len(aColsFEC[4]),nUsado04+1] := .F.

										For _ni:=1 to nUsado04
											aColsFEC[4,len(aColsFEC[4]),_ni] := CriaVar(aHeaderFEC[4,_ni,2])
										Next

										for ix2 := 1 to len(aHeaderFEC[4])

											if aHeaderFEC[4,ix2,10] == "V"
												loop
											EndIf
											If aHeaderFec[4,ix2,02] == "VO4_TEMTRA"
												loop
											EndIf
											aColsFEC[4,len(aColsFEC[4]),ix2] := &("VO4->"+aHeaderFEC[4,ix2,2])

										Next

										Do Case
											Case VOK->VOK_INCMOB == "0"     // Mao-de-Obra Gratuita

												If VOK->VOK_INCTEM == "3"   // Tempo Trabalhado
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
												Else
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
												EndIf

											Case VOK->VOK_INCMOB == "1"     // Por Mao-de-Obra

												If VOK->VOK_INCTEM == "3"  // Tempo Trabalhado
													nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

													if lVO4DESCONTO
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
														nTotDes += VO4->VO4_VALDES
													endif

												Else                        // Tempo - Fabrica/Concessionaria/Informado

													nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													If aScan(aVetSer,aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]) == 0
														aAdd(aVetSer,aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CODSER","aHeaderFEC",4)])
														nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													EndIf
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

													if lVO4DESCONTO
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
														nTotDes += VO4->VO4_VALDES
													endif

												EndIf

											Case VOK->VOK_INCMOB == "2"     // Servico de Terceiro

												nVO6_VALSER := VO4->VO4_VALVEN
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												if lVO4DESCONTO
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
													nTotDes += VO4->VO4_VALDES
												endif

											Case VOK->VOK_INCMOB == "3"     // Valor Livre com Base na Tabela

												If VOK->VOK_INCTEM == "3"  // Tempo Trabalhado
													nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf

													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

													if lVO4DESCONTO
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
														nTotDes += VO4->VO4_VALDES
													endif

												Else                        // Fabrica/Concessionaria/Informado

													nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													If aScan(aVetSer,aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]) == 0
														aAdd(aVetSer,aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CODSER","aHeaderFEC",4)])
														nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													EndIf
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

													if lVO4DESCONTO
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
														nTotDes += VO4->VO4_VALDES
													endif

												EndIf

											Case VOK->VOK_INCMOB == "4"     // Retorno de Servico

												If VOK->VOK_INCTEM == "3"  // Tempo Trabalhado

													nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

													if lVO4DESCONTO
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
														nTotDes += VO4->VO4_VALDES
													endif

												Else                        // Fabrica/Concessionaria/Informado

													nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													If aScan(aVetSer,aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]) == 0
														aAdd(aVetSer,aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CODSER","aHeaderFEC",4)])
														nTotSrv += If(VOI->VOI_SITTPO != "0",nVO6_VALSER,0)
													EndIf
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

													if lVO4DESCONTO
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
														aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
														nTotDes += VO4->VO4_VALDES
													endif

												EndIf

												//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
												//³Rubens - 15/09/2009                                                  ³
												//³FNC - 22385/2009                                                     ³
												//³Nao estava calculando o valor do servico para o Tipo de Cobranca = 5 ³
												//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											Case VOK->VOK_INCMOB == "5"                        // Kilometro Rodado

												nVO6_VALSER := VO4->VO4_KILROD * VOK->VOK_PREKIL
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												if lVO4DESCONTO
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
													nTotDes += VO4->VO4_VALDES
												endif

											Case VOK->VOK_INCMOB == "6"     // Franquia

												nVO6_VALSER := VO4->VO4_VALVEN
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												if lVO4DESCONTO
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VO4->VO4_PERDES
													aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VO4->VO4_VALDES
													nTotDes += VO4->VO4_VALDES
												endif

										EndCase

										If VOI->VOI_SITTPO == "3"  // Tipo de Tempo Interno

											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := 0
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := 0
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := 0

										EndIf

									Else

										Do Case
											Case VOK->VOK_INCMOB == "0"     // Mao-de-Obra Gratuita

												If VOK->VOK_INCTEM == "3"   // Tempo Trabalhado
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
												Else
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
												EndIf

											Case VOK->VOK_INCMOB == "1"     // Por Mao-de-Obra

												If VOK->VOK_INCTEM == "3"   // Tempo Trabalhado
													nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)          // Tempo Trabalhado
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												Else

													nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												EndIf

											Case VOK->VOK_INCMOB == "2"     // Servico de Terceiro

												nVO6_VALSER := VO4->VO4_VALVEN
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Case VOK->VOK_INCMOB == "3"     // Valor Livre com Base na Tabela

												If VOK->VOK_INCTEM == "3"   // Tempo Trabalhado
													nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)          // Tempo Trabalhado
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												Else
													nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												EndIf

											Case VOK->VOK_INCMOB == "4"     // Retorno de Servico

												If VOK->VOK_INCTEM == "3"   // Tempo Trabalhado
													nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)          // Tempo Trabalhado
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												Else
													nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
													If lVO6_VALSER
														If VO6->VO6_VALSER > 0
															nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
														EndIf
													EndIf
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
													aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

												EndIf

											Case VOK->VOK_INCMOB == "5"                        // Kilometro Rodado

												nVO6_VALSER := VO4->VO4_KILROD * VOK->VOK_PREKIL
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Case VOK->VOK_INCMOB == "6"     // Franquia

												nVO6_VALSER := VO4->VO4_VALVEN
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

										EndCase

										If VOI->VOI_SITTPO == "3"  // Tipo de Tempo Interno

											aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := 0
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := 0
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := 0

										EndIf

									EndIf

									DbSelectArea("VO4")
									DbSkip()

								EndDo

							EndIf

						EndIf

						DbSelectArea("VO2")
						DbSkip()

					EndDo

				EndIf

			EndIf

		Next

		nTotTTp += nTotSrv

		If len(aColsFec[4]) == 0

			aColsFEC[4]:={Array(nUsado04+1)}
			aColsFEC[4,1,nUsado04+1] := .F.
			For _ni:=1 to nUsado04
				aColsFEC[4,1,_ni] := If(aHeaderFEC[4,_ni,10] == "V",If( aHeaderFEC[4,_ni,8] == "C" , space(aHeaderFEC[4,_ni,4]), If( aHeaderFEC[4,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[4,_ni,2]))
			Next

		EndIf

		// Ordena Vetor

		aSort(aColsFEC[4],1,,{ |x,y| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] < y[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+y[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]})

		FS_LEVVET()

	Case cParam01 == 2     // Fechamento Agrupado

		nTotSrv := 0
		For ixx := 1 to len(aVetOSv)

			cKeyAce := aVetOSv[ixx,01]
			FG_SEEK("VO1","cKeyAce",1,.f.)

			dbSelectArea("VO2")
			DbSetOrder(1)

			If FG_SEEK("VO2","VO1->VO1_NUMOSV",1,.f.)

				While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. VO2->VO2_FILIAL == xFilial("VO2") .and. !eof()

					If VO2->VO2_TIPREQ == "S"     // Requisicao de Servicos

						dbSelectArea("VO4")
						DbSetOrder(1)
						aCodSer := {}

						If FG_SEEK("VO4","VO2->VO2_NOSNUM",1,.f.)

							cTTpAnt := VO4->VO4_TIPTEM

							While VO2->VO2_NOSNUM == VO4->VO4_NOSNUM .and. VO4->VO4_FILIAL == xFilial("VO4") .and. !eof()

								If cParam04 != VO4->VO4_TIPTEM
									dbSkip()
									Loop
								EndIf

								FG_SEEK("VOI","VO4->VO4_TIPTEM",1,.f.)
								FG_SEEK("SA1","VO4->VO4_FATPAR+VO4->VO4_LOJA",1,.f.)
								FG_SEEK("VOK","VO4->VO4_TIPSER",1,.f.)
								FG_SEEK("VO6","VO4->VO4_SERINT",1,.f.)

								//ix1 := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]+x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] == VO4->VO4_GRUSER+VO4->VO4_CODSER } )
								ix1 := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+x[FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]+x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] == VO4->VO4_TIPSER+VO4->VO4_GRUSER+VO4->VO4_CODSER } )

								If ix1 == 0

									aAdd(aColsFEC[4],Array(nUsado04+1))

									aColsFEC[4,len(aColsFEC[4]),nUsado04+1] := .F.

									For _ni:=1 to nUsado04
										aColsFEC[4,len(aColsFEC[4]),_ni] := CriaVar(aHeaderFEC[4,_ni,2])
									Next

									for ix2 := 1 to len(aHeaderFEC[4])

										if aHeaderFEC[4,ix2,10] == "V"
											loop
										EndIf
										If aHeaderFec[4,ix2,02] == "VO4_TEMTRA"
											loop
										EndIf
										aColsFEC[4,len(aColsFEC[4]),ix2] := &("VO4->"+aHeaderFEC[4,ix2,2])

									Next

									Do Case
										Case VOK->VOK_INCMOB == "0"     // Mao-de-Obra Gratuita

											If VOK->VOK_INCTEM == "3"
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
											Else
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
												EndIf
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
											EndIf

										Case VOK->VOK_INCMOB == "1"     // Por Mao-de-Obra

											If VOK->VOK_INCTEM == "3"  // Tempo Trabalhado
												nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Else                        // Fabrica/Concessionaria/Informado

												nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												EndIf
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											EndIf

										Case VOK->VOK_INCMOB == "2"     // Servico de Terceiro

											nVO6_VALSER := VO4->VO4_VALVEN
											If lVO6_VALSER
												If VO6->VO6_VALSER > 0
													nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
												EndIf
											EndIf
											nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
											aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

										Case VOK->VOK_INCMOB == "3"     // Valor Livre com Base na Tabela

											If VOK->VOK_INCTEM == "3"  // Tempo Trabalhado

												nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Else                        // Fabrica/Concessionaria/Informado

												nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												EndIf
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											EndIf

										Case VOK->VOK_INCMOB == "4"     // Retorno de Servico

											If VOK->VOK_INCTEM == "3"  // Tempo Trabalhado

												nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Else                        // Fabrica/Concessionaria/Informado

												nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
												EndIf
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] := VO4->VO4_TEMTRA
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] := VO4->VO4_TEMPAD
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
												aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											EndIf

										Case VOK->VOK_INCMOB == "5"                        // Kilometro Rodado

											nVO6_VALSER := VO4->VO4_KILROD * VOK->VOK_PREKIL
											If lVO6_VALSER
												If VO6->VO6_VALSER > 0
													nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
												EndIf
											EndIf
											nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
											aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

										Case VOK->VOK_INCMOB == "6"     // Franquia

											nVO6_VALSER := VO4->VO4_VALVEN
											If lVO6_VALSER
												If VO6->VO6_VALSER > 0
													nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
												EndIf
											EndIf
											nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nVO6_VALSER
											aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := nVO6_VALSER
											aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

									EndCase

									If VOI->VOI_SITTPO == "3"  // Tipo de Tempo Interno

										aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := 0
										aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := 0
										aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := 0

									EndIf

								Else

									Do Case
										Case VOK->VOK_INCMOB == "0"     // Mao-de-Obra Gratuita

											If VOK->VOK_INCTEM == "3"
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
											Else
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMPAD
												EndIf
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,0,0,0,0,0,0,VO4->(RECNO()),0})
											EndIf

										Case VOK->VOK_INCMOB == "1"     // Por Mao-de-Obra

											If VOK->VOK_INCTEM == "3"

												nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] += VO4->VO4_TEMPAD
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)          // Tempo Trabalhado
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Else

												nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												EndIf
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})
											EndIf

										Case VOK->VOK_INCMOB == "2"  // Servico de Terceiro

											nVO6_VALSER := VO4->VO4_VALVEN
											If lVO6_VALSER
												If VO6->VO6_VALSER > 0
													nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
												EndIf
											EndIf
											nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
											aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

										Case VOK->VOK_INCMOB == "3"     // Valor Livre com Base na Tabela

											If VOK->VOK_INCTEM == "3"

												nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] += VO4->VO4_TEMPAD
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)          // Tempo Trabalhado
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Else

												nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												EndIf
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})
											EndIf

										Case VOK->VOK_INCMOB == "4"     // Retorno de Servico

											If VOK->VOK_INCTEM == "3"

												nVO6_VALSER := round((VO4->VO4_TEMTRA / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] += VO4->VO4_TEMPAD
												EndIf
												nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)          // Tempo Trabalhado
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
												aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											Else

												nVO6_VALSER := round((VO4->VO4_TEMPAD / 100) * FG_VALHOR(VO4->VO4_TIPTEM,dDataBase,VO4->VO4_VHRDIG,VO4->VO4_VALHOR),2)
												If lVO6_VALSER
													If VO6->VO6_VALSER > 0
														nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
													EndIf
												EndIf
												If aScan(aVetSer,{ |x| x[01]+x[02] == VO1->VO1_NUMOSV+VO4->VO4_CODSER } ) == 0
													aAdd(aVetSer,{VO1->VO1_NUMOSV,VO4->VO4_CODSER})
													nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMPAD","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_TEMVEN","aHeaderFEC",4)] += VO4->VO4_TEMPAD
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
													aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
												EndIf
												aColsFEC[4,ix1,FS_POSVAR("VO4_TEMTRA","aHeaderFEC",4)] += VO4->VO4_TEMTRA
												aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,VO4->VO4_CODPRO,VO4->VO4_TEMPAD,VO4->VO4_TEMTRA,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

											EndIf

										Case VOK->VOK_INCMOB == "5"                        // Kilometro Rodado

											nVO6_VALSER := VO4->VO4_KILROD * VOK->VOK_PREKIL
											If lVO6_VALSER
												If VO6->VO6_VALSER > 0
													nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
												EndIf
											EndIf
											nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
											aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

										Case VOK->VOK_INCMOB == "6"  						// Servico de Terceiro

											nVO6_VALSER := VO4->VO4_VALVEN
											If lVO6_VALSER
												If VO6->VO6_VALSER > 0
													nVO6_VALSER := VO6->VO6_VALSER // Valor Fixo do Servico
												EndIf
											EndIf
											nTotSrv += If(VOI->VOI_SITTPO != "3",nVO6_VALSER,0)
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nVO6_VALSER
											aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nVO6_VALSER
											aAdd(aVetMec,{VO1->VO1_NUMOSV,VO4->VO4_TIPSER,VO4->VO4_CODSER,"",0,0,0,0,0,0,0,0,nVO6_VALSER,0,0,0,0,0,VO4->(RECNO()),0})

									EndCase

									If VOI->VOI_SITTPO == "3"  // Tipo de Tempo Interno

										aColsFEC[4,ix1,FS_POSVAR("VO4_TEMCOB","aHeaderFEC",4)] := 0
										aColsFEC[4,ix1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := 0
										aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := 0

									EndIf

								EndIf

								dbSelectArea("VO4")
								dbSkip()

							EndDo

						EndIf

					EndIf

					dbSelectArea("VO2")
					dbSkip()

				EndDo

			EndIf

		Next

		nTotTTp += nTotSrv

		If len(aColsFec[4]) == 0

			aColsFEC[4]:={Array(nUsado04+1)}
			aColsFEC[4,1,nUsado04+1] := .F.
			For _ni:=1 to nUsado04
				aColsFEC[4,1,_ni] := If(aHeaderFEC[4,_ni,10] == "V",If( aHeaderFEC[4,_ni,8] == "C" , space(aHeaderFEC[4,_ni,4]), If( aHeaderFEC[4,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[4,_ni,2]))
			Next

			//aAdd(aVetMec,{"","","","","",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})

		EndIf

		// Ordena Vetor

		aSort(aColsFEC[4],1,,{ |x,y| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] < y[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+y[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]})

		FS_LEVVET()

	Case cParam01 == 3     // Fechamento Kilometragem

		For ix1 := 1 to len(aVetKil)

			If cChaAnt != aVetKil[ix1,01]

				cChaAnt := aVetKil[ix1,01]
				cKeyAce := aVetKil[ix1,01]
				FG_SEEK("VV1","cKeyAce",1,.f.)
				FG_SEEK("VO5","cKeyAce",1,.f.)

				DbSelectArea("VF4")
				FG_SEEK("VF4","VV1->VV1_CHAINT",1,.f.)
				nKilIni := VO5->VO5_KILINI

				while VF4->VF4_CHAINT == aVetKil[ix1,01] .and. VF4->VF4_FILIAL == xFilial("VF4") .and. !eof()

					If !empty(VF4->VF4_NUMOSV)
						dbSkip()
						Loop
					EndIf
					If !IsMark("VF4_OK",ThisMark(),ThisInv()) // Se Nao Marcado
						dbskip()
						Loop
					EndIf
					If VF4->VF4_DATKIL == aVetKil[ix1,03]
						Exit
					EndIf
					nKilIni += VF4->VF4_KILROD

					DbSkip()

				EndDo
			endif

			DbSelectArea("VFA")
			DbSetOrder(1)
			DbSeek( xFilial("VFA") + VV1->VV1_PROATU + VV1->VV1_LJPATU + VO5->VO5_CATACO )

			nKilIniT := nKilIni
			nKilRodT := aVetKil[ix1,04]
			nKilIniA := nKilIni
			while nKilRodT > 0
				while nKilIniT >= VFA->VFA_KILFAI .and. !(VFA->(eof())) .and. VV1->VV1_PROATU+VV1->VV1_LJPATU+VO5->VO5_CATACO == VFA->VFA_CODCLI+VFA->VFA_LOJA+VFA->VFA_CATACO .and. VFA->VFA_FILIAL == xFilial("VFA")
					VFA->(DBSkip())
				enddo

				if VFA->(eof()) .or. VV1->VV1_PROATU+VV1->VV1_LJPATU != VFA->VFA_CODCLI+VFA->VFA_LOJA .or. VFA->VFA_FILIAL != xFilial("VFA")
					VFA->(DbSkip(-1))
				endif
				if nKilRodT > VFA->VFA_KILFAI
					nKilDFaixa = VFA->VFA_KILFAI - nKilIniT
					nKilRodT = nKilRodT - (VFA->VFA_KILFAI - nKilIniT)
					nKilIniT = VFA->VFA_KILFAI
				else
					nKilDFaixa = nKilRodT
					nKilRodT = 0
				endif
				nKilIniA += nKilDFaixa
				FG_SEEK("VO6","FG_MARSRV(VV1->VV1_CODMAR,VFA->VFA_CODSER)+VFA->VFA_CODSER",2,.f.)
				aAdd(aVetKlm,{nKilIniA,nKilDFaixa,"R",VFA->VFA_CODSER,If(empty(VFA->VFA_VALFAI),FG_VALHOR(VOI->VOI_TIPTEM,dDataBase),VFA->VFA_VALFAI),VFA->VFA_GRUSER,VFA->VFA_TIPSER,aVetKil[ix1,02]})

			enddo

		next
		/*
		nFaiAnt := 0

		while VV1->VV1_PROATU+VV1->VV1_LJPATU == VFA->VFA_CODCLI+VFA->VFA_LOJA .and. VFA->VFA_FILIAL == xFilial("VFA") .and. !eof()

		If nKilIni >= nFaiAnt .and. nKilIni <= VFA->VFA_KILFAI
		Exit
		EndIf

		nFaiAnt := VFA->VFA_KILFAI
		DbSkip()

		EndDo

		nKilFin := 0

		For ixx := 1 to len(aVetKil)

		If aVetKil[ix1,01] != aVetKil[ixx,01]
		Loop
		EndIf

		nKilFin += aVetKil[ixx,04]
		cKeyAce := aVetKil[ixx,01]
		FG_SEEK("VV1","cKeyAce",1,.f.)
		FG_SEEK("VO5","cKeyAce",1,.f.)

		FG_SEEK("VF2","VV1->VV1_PROATU+VV1->VV1_LJPATU+VO5->VO5_CATACO",1,.f.)

		cKeyAce := aVetKil[ixx,01]

		nFaiAnt := 0
		DbSelectArea("VFA")
		FG_SEEK("VFA","VV1->VV1_PROATU+VV1->VV1_LJPATU",2,.f.)

		while VV1->VV1_PROATU+VV1->VV1_LJPATU == VFA->VFA_CODCLI+VFA->VFA_LOJA .and. VFA->VFA_FILIAL == xFilial("VFA") .and. !eof()

		If nKilFin >= nFaiAnt .and. nKilFin <= VFA->VFA_KILFAI
		Exit
		EndIf

		nFaiAnt := VFA->VFA_KILFAI

		DbSkip()

		EndDo

		If VFA->(eof())
		dbSkip(-1)
		EndIf

		FG_SEEK("VO6","FG_MARSRV(VV1->VV1_CODMAR,VFA->VFA_CODSER)+VFA->VFA_CODSER",2,.f.)

		aAdd(aVetKlm,{aVetKil[ixx,04],aVetKil[ixx,04],"R",VFA->VFA_CODSER,If(empty(VFA->VFA_VALFAI),FG_VALHOR(VOI->VOI_TIPTEM,dDataBase),VFA->VFA_VALFAI),VFA->VFA_GRUSER,VFA->VFA_TIPSER,aVetKil[ixx,2]})
		aVetKlm[len(aVetKlm),01] += aVetKlm[len(aVetKlm)-1,1]

		Next

		DbSelectArea("VFA")
		FG_SEEK("VFA","VV1->VV1_PROATU+VV1->VV1_LJPATU",2,.f.)

		while VV1->VV1_PROATU+VV1->VV1_LJPATU == VFA->VFA_CODCLI+VFA->VFA_LOJA .and. VFA->VFA_FILIAL == xFilial("VFA") .and. !eof()

		aAdd(aVetKlm,{VFA->VFA_KILFAI,0,"A",VFA->VFA_CODSER,If(empty(VFA->VFA_VALFAI),FG_VALHOR(VOI->VOI_TIPTEM,dDataBase),VFA->VFA_VALFAI),VFA->VFA_GRUSER,VFA->VFA_TIPSER,aVetKil[ix1,02]})

		DbSkip()

		EndDo

		EndIf

		Next

		aSort(aVetKlm,1,,{ |x,y| x[8]+str(x[1],8) < y[8]+str(y[1],8)})

		cChaAnt := ""

		For ixx := 1 to len(aVetKlm)

		If cChaAnt != aVetKlm[ixx,8]
		aVetKlm[ixx,3] := "X"
		cChaAnt := aVetKlm[ixx,8]
		ixx ++
		EndIf
		If aVetKlm[ixx,3] == "A"
		loop
		EndIf
		If aVetKlm[ixx-1,3] == "A"
		aVetKlm[ixx-1,2] := aVetKlm[ixx-1,1] - aVetKlm[ixx-2,1]
		aVetKlm[ixx-1,3] := "R"
		aVetKlm[ixx-1,8] := aVetKlm[ixx,8]
		aVetKlm[ixx,2]   -= aVetKlm[ixx-1,2]
		EndIf

		Next
		*/
		For ixx := 1 to len(aVetKlm)

			If aVetKlm[ixx,3] != "R"
				Loop
			EndIf
			cKeyAce := aVetKlm[ixx,04]

			FG_SEEK("VO6","FG_MARSRV(VV1->VV1_CODMAR,cKeyAce)+cKeyAce",2,.f.)
			aAdd(aColsFEC[4],Array(nUsado04+1))
			aColsFEC[4,len(aColsFEC[4]),nUsado04+1] := .F.

			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)] := aVetKlm[ixx,08]
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)] := aVetKlm[ixx,06]
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] := aVetKlm[ixx,04]
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_DESSER","aHeaderFEC",4)] := VO6->VO6_DESABR
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] := aVetKlm[ixx,07]
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_DESTPS","aHeaderFEC",4)] := Posicione("VOK",1,xFilial("VOK")+aVetKlm[ixx,07],"VOK_DESSER")
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := 0
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := 0
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_KILATU","aHeaderFEC",4)] := aVetKlm[ixx,1]
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_KILROD","aHeaderFEC",4)] := aVetKlm[ixx,2]
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := aVetKlm[ixx,2] * aVetKlm[ixx,5]
			aColsFEC[4,len(aColsFEC[4]),FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aVetKlm[ixx,2] * aVetKlm[ixx,5]
			nTotSrv += If(VOI->VOI_SITTPO != "3",aVetKlm[ixx,2] * aVetKlm[ixx,5],0)
			nTotTTp += aVetKlm[ixx,2] * aVetKlm[ixx,5]

		Next

		If len(aColsFec[4]) == 0

			aColsFEC[4]:={Array(nUsado04+1)}
			aColsFEC[4,1,nUsado04+1] := .F.
			For _ni:=1 to nUsado04
				aColsFEC[4,1,_ni] := If(aHeaderFEC[4,_ni,10] == "V",If( aHeaderFEC[4,_ni,8] == "C" , space(aHeaderFEC[4,_ni,4]), If( aHeaderFEC[4,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[4,_ni,2]))
			Next

			//aAdd(aVetMec,{"","","","","",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0})

		EndIf

		// Ordena Vetor
		aSort(aColsFEC[4],1,,{ |x,y| x[FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)]+str(x[FS_POSVAR("VO4_KILATU","aHeaderFEC",4)],8) < y[FS_POSVAR("VO4_CHASSI","aHeaderFEC",4)]+str(y[FS_POSVAR("VO4_KILATU","aHeaderFEC",4)],8)})

EndCase

If MaFisFound('NF')
	ntotttp := MaFisRet(,"NF_TOTAL")
Endif
if cParam01 != 3
	nTotTTp += nTotSrv
endif

dbSelectArea(cSelect)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_TTSRVC  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Totaliza itens analiticos em sinteticos                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TTSRVC(cTipTot)
Local ix4
Local ix5
Local ix6
Local cCodSer := ""
Local aVetSer := {}
Local nContar := .f.
Local ix1 := 0
Local _NI := 0
Local ix2 := 0

For ix1 := 1 to len(aColsFEC[4])

	If Empty(aColsFEC[4,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])
		Loop
	EndIf

	ix4 := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == aColsFEC[4,ix1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]})

	If ix4 == 0

		If cParam01 == NIL

			If Empty(aColsFEC[3,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])

				aColsFEC[3]:={Array(nUsado03+1)}

				aColsFEC[3,1,nUsado03+1] := .F.
				For _ni:=1 to nUsado03
					aColsFEC[3,1,_ni]:=CriaVar(aHeaderFEC[3,_ni,2])
				Next

			Else

				aAdd(aColsFEC[3],Array(nUsado03+1))
				aColsFEC[3,len(aColsFEC[3]),nUsado03+1] := .F.

				For _ni:=1 to nUsado03
					aColsFEC[3,len(aColsFEC[3]),_ni]:=CriaVar(aHeaderFEC[3,_ni,2])
				Next

			EndIf

		Else

			If lFlag03

				lFlag03 := .f.

				aColsFEC[3]:={Array(nUsado03+1)}

				aColsFEC[3,1,nUsado03+1] := .F.
				For _ni:=1 to nUsado03
					aColsFEC[3,1,_ni]:=CriaVar(aHeaderFEC[3,_ni,2])
				Next

			Else

				aAdd(aColsFEC[3],Array(nUsado03+1))
				aColsFEC[3,len(aColsFEC[3]),nUsado03+1] := .F.

				For _ni:=1 to nUsado03
					aColsFEC[3,len(aColsFEC[3]),_ni]:=CriaVar(aHeaderFEC[3,_ni,2])
				Next

			EndIf

		EndIf

	EndIf

	cCodSer := aColsFEC[4,ix1,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
	cKeyAce := aColsFEC[4,ix1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
	FG_SEEK("VOK","cKeyAce",1,.f.)

	ix4 := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == aColsFEC[4,ix1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]})
	If ix4 == 0
		ix4 := Len(aColsFEC[3])
	EndIf

	If cTipTot == "NORMAL"

		For ix2 := 1 to len(aHeaderFEC[4])

			ix3 := aScan(aHeaderFEC[3],{ |x| x[02] == aHeaderFEC[4,ix2,02] })

			If ix3 == 0
				loop
			EndIf

			If aHeaderFEC[3,ix3,08] == "N"

				ix5 := aScan(aVetSer,cCodSer)
				If ix5 == 0
					nContar := ix1
					aAdd(aVetSer,cCodSer+strzero(nContar,3))
				EndIf

				If ix5 != 0 .and. aHeaderFEC[3,ix3,02] == "VO4_TEMPAD"
					loop
				EndIf

				if cParam01 == 3
					nContar := ix1
				endif

				If VOK->VOK_INCMOB != "0" .and. VOK->VOK_INCTEM $ "1/2/4" .and. nContar != ix1
					Loop
				EndIf
				If aColsFec[4,ix1,ix2] == nil // Verifica se existe o campo/posicao no vetor
					aColsFec[4,ix1,ix2] := 0
				EndIf
				If aColsFec[3,ix4,ix3] == nil
					aColsFec[3,ix4,ix3] := aColsFec[4,ix1,ix2]
				Else
					aColsFEC[3,ix4,ix3] += aColsFEC[4,ix1,ix2]
				EndIf
			Else
				If aColsFec[4,ix1,ix2] == nil // Verifica se existe o campo/posicao no vetor
					aColsFec[4,ix1,ix2] := 0
				EndIf
				aColsFEC[3,ix4,ix3] := aColsFEC[4,ix1,ix2]
			EndIf

		Next

	Else

		For ix2 := 1 to len(aHeaderFEC[4])

			ix3 := aScan(aHeaderFEC[3],{ |x| x[02] == aHeaderFEC[4,ix2,02] })

			If ix3 == 0
				loop
			EndIf

			If cParam01 < 3
				ix6 := aScan(aColsFEC[3],{ |x| x[01] == aColsFEC[4,ix1,04] })
			Else
				ix6 := aScan(aColsFEC[3],{ |x| x[01] == aColsFEC[4,ix1,05] })
			EndIf

			If aHeaderFEC[3,ix3,08] == "N"

				ix5 := aScan(aVetSer,cCodSer)
				If ix5 == 0
					nContar := ix1
					aAdd(aVetSer,cCodSer+strzero(nContar,3))
				EndIf

				If ix5 != 0 .and. aHeaderFEC[3,ix3,02] == "VO4_TEMPAD"
					loop
				EndIf

				If VOK->VOK_INCMOB != "0" .and. VOK->VOK_INCTEM $ "1/2/4" .and. nContar != ix1
					Loop
				EndIf

				If aColsFec[3,ix6,ix3] == nil
					aColsFec[3,ix6,ix3] := aColsFec[4,ix1,ix2]
				Else
					aColsFEC[3,ix6,ix3] += aColsFEC[4,ix1,ix2]
				EndIf
			Else
				aColsFEC[3,ix6,ix3] := aColsFEC[4,ix1,ix2]
			EndIf

		Next

	EndIf

	For ix2 := 1 to len(aColsFEC[3])

		cKeyAce := aColsFEC[3,ix2,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]
		FG_SEEK("VOK","cKeyAce",1,.f.)
		aColsFEC[3,ix2,FS_POSVAR("VO4_DESTPS","aHeaderFEC",3)] := VOK->VOK_DESSER

	Next

	if ix4 > 0
		aColsFEC[3,ix4,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)] := VOI->VOI_CODTES
	Endif

Next

If len(aColsFec[3]) == 0

	aColsFEC[3]:={Array(nUsado03+1)}
	aColsFEC[3,1,nUsado03+1] := .F.
	For _ni:=1 to nUsado03

		aColsFEC[3,1,_ni] := If(aHeaderFEC[3,_ni,10] == "V",If( aHeaderFEC[3,_ni,8] == "C" , space(aHeaderFEC[3,_ni,4]), If( aHeaderFEC[3,_ni,8] == "N" , 0 , Ctod("  /  /  ")) ),CriaVar(aHeaderFEC[3,_ni,2]))

	Next

EndIf

*** Ordena Vetor

aSort(aColsFEC[3],1,,{ |x,y| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] < y[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)]})

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_LEVVET    ³ Autor ³ Emilton          ³ Data ³ 08/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Levanta, prepara e rateia vetor interno                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Especifico                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_LEVVET()
Local ix1     := 0
Local cOSvAnt := ""
Local cTipAnt := ""
Local cCodAnt := ""

Local lSomVal

Local nTotalS := 0
Local nTotalT := 0
Local nTotalO := 0
Local nTotalSV:= 0
Local nTotalTV:= 0
Local nTotalOV:= 0

Local aSrvSrv := {}
Local aTipSrv := {}
Local aOsvSrv := {}

If len(aVetMec) == 0
	Return .t.
EndIf

aSort(aVetMec,1,,{ |x,y| x[01]+x[02]+x[03] < y[01]+y[02]+y[03] })

cOsvAnt := aVetMec[01,01]
cTipAnt := aVetMec[01,02]
cCodAnt := aVetMec[01,03]

For ix1 := 1 to len(aVetMec)

	If cOsvAnt != aVetMec[ix1,01]
		FS_TOTCOD(cOSvAnt,cTipAnt,cCodAnt,nTotalS,nTotalSV)
		FS_TOTTIP(cOSvAnt,cTipAnt,nTotalT,nTotalTV)
		FS_TOTOSV(cOSvAnt,nTotalO,nTotalOV)
		cOsvAnt := aVetMec[ix1,01]
		cTipAnt := aVetMec[ix1,02]
		cCodAnt := aVetMec[ix1,03]
		nTotalS := 0
		nTotalT := 0
		nTotalO := 0
		nTotalSV:= 0
		nTotalTV:= 0
		nTotalOV:= 0
	EndIf

	If cTipAnt != aVetMec[ix1,02]
		FS_TOTCOD(cOSvAnt,cTipAnt,cCodAnt,nTotalS,nTotalSV)
		FS_TOTTIP(cOSvAnt,cTipAnt,nTotalT,nTotalTV)
		cTipAnt := aVetMec[ix1,02]
		cCodAnt := aVetMec[ix1,03]
		nTotalS := 0
		nTotalT := 0
		nTotalSV:= 0
		nTotalTV:= 0
	EndIf

	If cCodAnt != aVetMec[ix1,03]
		FS_TOTCOD(cOSvAnt,cTipAnt,cCodAnt,nTotalS,nTotalSV)
		cCodAnt := aVetMec[ix1,03]
		nTotalS := 0
		nTotalSV:= 0
	EndIf

	cKeyAce := aVetMec[ix1,02]
	FG_SEEK("VOK","cKeyAce",1,.f.)
	// Tempo para Calculo = 3-Trabalhado ou Tipo de Cobranca = 2-Serv. Terceiros/5-Socorro/6-Franquia
	If VOK->VOK_INCTEM == "3" .or. VOK->VOK_INCMOB $ "2/5/6"
		lSomVal := .t.
		nTotalSV += aVetMec[ix1,13]
		nTotalTV += aVetMec[ix1,13]
		nTotalOV += aVetMec[ix1,13]
	Else
		If aScan(aTipSrv,cOSvAnt+cCodAnt) == 0
			aAdd(aTipSrv,cOSvAnt+cCodAnt)
			lSomVal := .t.
			nTotalSV += aVetMec[ix1,13]
			nTotalTV += aVetMec[ix1,13]
			nTotalOV += aVetMec[ix1,13]
		Else
			lSomVal := .f.
		EndIf
	EndIf

	nTotalS  += aVetMec[ix1,06]  // Total do Tempo Trabalhado do Servico
	nTotalT  += aVetMec[ix1,06]  // Total do Tempo Trabalhado do Tipo do Servico
	nTotalO  += aVetMec[ix1,06]  // Total do Tempo Trabalhado da OS

Next

FS_TOTCOD(cOSvAnt,cTipAnt,cCodAnt,nTotalS,nTotalSV)
FS_TOTTIP(cOSvAnt,cTipAnt,nTotalT,nTotalTV)
FS_TOTOSV(cOSvAnt,nTotalO,nTotalOV)

For ix1 := 1 to len(aVetMec)

	cKeyAce := aVetMec[ix1,02]
	FG_SEEK("VOK","cKeyAce",1,.f.)
	If VOK->VOK_INCMOB $ "2/5/6"    // Servico de Terceiros ou Socorro ou Franquia
		aVetMec[ix1,10] := aVetMec[ix1,13] / aVetMec[ix1,16] // % em Relacao a este Servico
		aVetMec[ix1,11] := aVetMec[ix1,13] / aVetMec[ix1,17] // % em Relacao a este Tipo de Servico
		aVetMec[ix1,12] := aVetMec[ix1,13] / aVetMec[ix1,18] // % em Relacao a esta OS
		aVetMec[ix1,14] := aVetMec[ix1,16] * aVetMec[ix1,10] // Valor Rateado do Servico sem Desconto
		aVetMec[ix1,15] := aVetMec[ix1,16] * aVetMec[ix1,10] // Valor Rateado do Servico sem Desconto
	Else
		aVetMec[ix1,10] := aVetMec[ix1,06] / aVetMec[ix1,07] // % em Relacao a este Servico
		aVetMec[ix1,11] := aVetMec[ix1,06] / aVetMec[ix1,08] // % em Relacao a este Tipo de Servico
		aVetMec[ix1,12] := aVetMec[ix1,06] / aVetMec[ix1,09] // % em Relacao a esta OS
		aVetMec[ix1,14] := aVetMec[ix1,16] * aVetMec[ix1,10] // Valor Rateado do Servico sem Desconto
		aVetMec[ix1,15] := aVetMec[ix1,16] * aVetMec[ix1,10] // Valor Rateado do Servico sem Desconto
		Do Case
			Case VOK->VOK_INCTEM == "3"
				aVetMec[ix1,20] := aVetMec[ix1,06]
			Case VOK->VOK_INCTEM $ "1/2/4"
				aVetmEC[IX1,20] := aVetMec[ix1,05] * aVetMec[ix1,10]
		EndCase
	EndIf

Next

Return

Function FS_TOTCOD(cOsvAnt,cTipAnt,cCodAnt,nTotalS,nValSom)
Local ix2
For ix2 := 1 to len(aVetMec)
	If aVetMec[ix2,01] == cOSvAnt .and.;
		aVetMec[ix2,02] == cTipAnt .and.;
		aVetMec[ix2,03] == cCodAnt

		DbSelectarea("VOK")
		DbSetOrder(1)
		If Dbseek(xFilial("VOK")+cTipAnt) .And. VOK->VOK_INCMOB $ "2/5/6" // Servico de Terceiros ou Socorro ou Franquia
			aVetMec[ix2,07] := aVetMec[ix2,06]
			aVetMec[ix2,16] := aVetMec[ix2,13]
		Else
			aVetMec[ix2,07] := nTotalS
			aVetMec[ix2,16] := nValSom
		EndIf

	EndIf

Next

Return .t.

Function FS_TOTTIP(cOSvAnt,cTipAnt,nTotalT,nValSom)
Local ix2
For ix2 := 1 to len(aVetMec)

	If aVetMec[ix2,01] == cOSvAnt .and.;
		aVetMec[ix2,02] == cTipAnt

		DbSelectarea("VOK")
		DbSetOrder(1)
		If Dbseek(xFilial("VOK")+cTipAnt) .And. VOK->VOK_INCMOB $ "2/5/6" // Servico de Terceiros ou Socorro ou Franquia
			aVetMec[ix2,08] := aVetMec[ix2,06]
			aVetMec[ix2,17] := aVetMec[ix2,13]
		Else
			aVetMec[ix2,08] := nTotalT
			aVetMec[ix2,17] := nValSom
		EndIf

	EndIf

Next

Return .t.

Function FS_TOTOSV(cOsvAnt,nTotalO,nValSom)
Local ix2

For ix2 := 1 to len(aVetMec)

	If aVetMec[ix2,01] == cOSvAnt
		aVetMec[ix2,09] := nTotalO
		aVetMec[ix2,18] := nValSom
	EndIf

Next

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_POSVAR    ³ Autor ³ Emilton          ³ Data ³ 08/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Retorna a posicao do campo no aHeader                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  Nome do Campo                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³  Posicao do Campo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Geral                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_POSVAR(Arg1,Arg2,Arg3)
If Arg2 == Nil
	Arg2 := "aHeader"
Endif

Return (aScan(&(Arg2+"["+strzero(Arg3,2)+"]"),{|x| AllTrim(x[2])==Arg1}))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  FS_ADMCPO    ³ Autor ³ Emilton          ³ Data ³ 11/04/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Controla Campos das 4 GetDados                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ADMCPO()

Local nPerDes := 0
Local nValBru := 0
Local nValTot := 0
Local nValTra := 0
Local nTotBru := 0
Local nTotTot := 0
Local nTotDsc := 0
Local nTotCus := 0
Local nValorX := 0   // Para Rateio de Descontos
Local nValorY := 0   // Para Rateio de Descontos
Local nValorZ := 0   // Para Rateio de Descontos
Local nValorXT:= 0   // Para Rateio de Valor Total
Local nValorYT:= 0   // Para Rateio de Valor Total
Local nValorZT:= 0   // Para Rateio de Valor Total
Local nPerDesx:= 0
Local cAliasA := ""
Local nResto  := 0
Local nRound  := 0
Local nMaiorVlr:= 0
Local ixy	  := 0
Local ixx     := 0
Local cCli    := ""
Local cLoja   := ""
Local nAuxCont := 0
Private nValDes := 0

// Nao executar funcao quando foi chamada pelo VALID do VO3_CODTES na Requisicao de PECAS/SERVICOS //
// Rubens - 16/03/2010, adicionado OFIOM010, pois pode ser feita a chamada do OFIOM020/OFIOM030 atraves dele
If !FM_PILHA("OFIOM160")
	Return(.t.)
EndIf
/////////////////////////////////////////////////////////////////////////////////////////////////////

cCli  := VO1->VO1_FATPAR
cLoja := VO1->VO1_LOJA
if Empty(cCLi)
	cCli  := VO1->VO1_PROVEI
	cLoja := VO1->VO1_LOJPRO
Endif

cKeyAce := __cUserID
FG_SEEK("VAI","cKeyAce",4,.f.)

If !MaFisFound('NF')
	If !Empty(cCli)
		FP_IniImp(cCli,cLoja)
	EndIf
Else
	MaFisReprocess(2)
EndIf

//If "VO3" $ ReadVar()
//	If cFocus == "Sin"
//		aHeader := aClone(aHeaderFEC[1])
//		aCols   := aClone(FS_CRIA_ACOLS(1))
//   ElseIf cFocus == "Ana"
//		aHeader := aClone(aHeaderFEC[2])
//		aCols   := aClone(FS_CRIA_ACOLS(2))
//	EndIf
//ElseIf "VO4" $ ReadVar()
//	If cFocus == "Sin"
//		aHeader := aClone(aHeaderFEC[3])
//		aCols   := aClone(FS_CRIA_ACOLS(3))
//   ElseIf cFocus == "Ana"
//		aHeader := aClone(aHeaderFEC[4])
//		aCols   := aClone(FS_CRIA_ACOLS(4))
//	EndIf
//EndIf

If ExistBlock("OM160VLD")
	lRetPE := ExecBlock("OM160VLD",.f.,.f.)
	If !lRetPE
		Return (.f.)
	Endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FECHAMENTO TT - INTERNO                                       ³
//³ Se for alterado valor bruto do servico na GetDados sintetica, ³
//³ verificar se nao existe mais de um servico para o grupo       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if VOI->VOI_SITTPO == "3" .and. nBroAtu == 3 .and. ReadVar() == "M->VO4_VALBRU"
	nAuxCont := 0
	For ixx := 1 to len(aColsFEC[4])

		If aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER

			nAuxCont++
			if nAuxCont > 1
				MsgAlert(STR0184)
				Return .f.
			endif
		EndIf

	Next

endif

Do Case
	Case ReadVar() == "M->VO3_CODTES"

		If nBroAtu == 1
			If Empty(aColsFEC[1,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)])
				Return .f.
			EndIf
		Else
			If Empty(aColsFEC[2,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
				Return .f.
			EndIf
		EndIf

		nTotBru := 0
		nTotTot := 0
		nTotDsc := 0

		ixx := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == M->VO3_GRUITE+M->VO3_CODITE })
		if ixx > 0
		
			// Valida TES 
			If !OM160CMPTES( aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] , M->VO3_CODTES )
				Return .f.
			EndIf
			//
		
			n := ixx
			cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			FG_SEEK("SB1","cKeyAce",7,.f.)
			If Empty(M->VO3_CODTES)
				SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
			Else
				SF4->(dbSeek(xFilial("SF4")+M->VO3_CODTES))
			Endif
			MAFISREF("IT_PRODUTO","VO300",SB1->B1_COD)
			MAFISREF("IT_TES","VO300",M->VO3_CODTES)
			MaFisAlt("IT_TES",M->VO3_CODTES,n)

			aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := M->VO3_CODTES
			aColsFEC[2,ixx,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)] := MaFisRet(n,"IT_ALIQICM")
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] := MaFisRet(n,"IT_VALICM")

			M->VO3_ALQICM := aColsFEC[2,ixx,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)]
			M->VO3_VALICM := aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]

			aCols[n,FG_POSVAR("VO3_CODTES")] := M->VO3_CODTES
			aCols[n,FG_POSVAR("VO3_ALQICM")] := M->VO3_ALQICM
			aCols[n,FG_POSVAR("VO3_VALICM")] := M->VO3_VALICM

			ixx := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
			if ixx > 0
				aColsFEC[1,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := aColsFEC[1,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] - aColsFEC[1,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]
				If MaFisFound('NF')
					M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
					M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
					//					M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
					M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
					M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
					FG_ATUALOBJ()
				EndIf

				nTotTTp := MaFisRet(,"NF_TOTAL")
				nTotTTp += nTotSrv

				oGetPecSin:oBrowse:SetFocus()
				oGetPecAna:oBrowse:SetFocus()
				oTotPec03:refresh()
				oTotTTp03:refresh()
				oTotDes03:refresh()
				oTotPec02:refresh()
				oTotTTp02:refresh()
				oTotDes02:refresh()
				ixx := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == M->VO3_GRUITE+M->VO3_CODITE })
				if ixx > 0
					aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] :=M->VO3_CODTES
				Endif

			Endif
		Endif

	Case ReadVar() == "M->VO3_PERDES"

		//		If VOI->VOI_SITTPO == "3"
		//			Help(" ",1,"M160NAODES")   // Para Tipo de Tempo Interno, nao e possivel aplicar desconto
		//			Return .f.
		//		EndIf

		If M->VO3_PERDES > 99.99
			Help(" ",1,"M160PERDES")
			Return .f.
		EndIf

		If nBroAtu == 1
			If Empty(aColsFEC[1,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)])
				Return .f.
			EndIf
		Else
			If Empty(aColsFEC[2,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
				Return .f.
			EndIf

			nValDes := NoRound( (M->VO3_VALBRU * (M->VO3_PERDES / 100)) , 2)
			FS_AcertDes()

		EndIf

		nValTra := M->VO3_PERDES

		nTotDes -= aCols[n,FG_POSVAR("VO3_VALDES")]         // Valor do Desconto
		nTotPec -= aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico
		nTotTTp -= aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico
		nnAnt := n
		nTotBru := 0
		nTotTot := 0
		nTotDsc := 0

		If nBroAtu == 1

			nValDes := M->VO3_VALDES
			nValBru := M->VO3_VALBRU
			nValTot := M->VO3_VALBRU - nValDes
			nPerDes := M->VO3_PERDES
			M->VO3_VALBRU := nValBru
			M->VO3_VALDES := NoRound( (M->VO3_VALBRU * (M->VO3_PERDES / 100)) ,2)
			M->VO3_VALTOT := M->VO3_VALBRU - M->VO3_VALDES
			M->VO3_VALDES := M->VO3_VALBRU - M->VO3_VALTOT

			nResto    := 0
			nRound    := 0
			nMaiorVlr := 0
			for ixx := 1 to len(aColsFEC[2])
				If aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE
					If aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] > nMaiorVlr
						nMaiorVlr := aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
					EndIf
					nRound += (NoRound((aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]/aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * (nPerDes / 100) ,2) * aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)])
				EndIf
			Next
			nResto  := ( M->VO3_VALDES - nRound )
			nValTra := M->VO3_VALDES
			nValorZ := 0

			for ixx := 1 to len(aColsFEC[2])

				If aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE

					aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := val(str((NoRound((aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]/aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * (nPerDes / 100) ,2) * aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]),12,2))
					aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := val(str((aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]),12,2))
					aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := val(str(aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)],12,2))

					n := ixx
					cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
					FG_SEEK("SB1","cKeyAce",7,.f.)
					SF4->(dbSetOrder(1))
					If Empty(M->VO3_CODTES)
						SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
					Else
						SF4->(dbSeek(xFilial("SF4")+M->VO3_CODTES))
					Endif
					MAFISREF("IT_PRODUTO","VO300",SB1->B1_COD)
					MAFISREF("IT_TES","VO300",Iif(Empty(M->VO3_CODTES),FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"),M->VO3_CODTES))
					MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
					MAFISREF("IT_DESCONTO" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)])
					aColsFEC[2,ixx,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)] := MaFisRet(n,"IT_ALIQICM")
					aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] := MaFisRet(n,"IT_VALICM")

					aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := ( (aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] * 100) / aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] )

					M->VO3_GRUITE := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
					M->VO3_CODITE := aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
					M->VO3_QTDREQ := aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
					M->VO3_VALICM := aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]
					SBM->(dbSetOrder(1))
					SBM->(dbSeek(xFilial("SBM")+M->VO3_GRUITE))
					FG_PERDES(SBM->BM_CODMAR,VAI->VAI_CC,"P",M->VO3_GRUITE,M->VO3_CODITE,M->VO3_QTDREQ, aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] ,,VV1->VV1_MODVEI)
					If MaFisFound('NF')
						M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
						M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
						//						M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
						M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
						M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
						FG_ATUALOBJ()
					EndIf

					nTotBru += aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
					nTotTot += aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
					nTotDsc += aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]

				EndIf
			Next
			/*
			for ixx := 1 to len(aColsFEC[2])
			If aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE
			nTotBru += aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
			nTotTot += aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
			nTotDsc += aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
			EndIf
			Next
			*/
			ixx := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
			aColsFEC[1,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := M->VO3_PERDES
			aColsFEC[1,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := nTotDsc
			aColsFEC[1,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := aColsFEC[1,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] - aColsFEC[1,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]

			M->VO3_VALDES := nTotDsc
			n := nnAnt
			aCols[n,FG_POSVAR("VO3_PERDES")] := nPerDes                // Valor de Desconto
			aCols[n,FG_POSVAR("VO3_VALDES")] := nTotDsc                // Valor de Desconto
			aCols[n,FG_POSVAR("VO3_VALTOT")] := nTotTot                // Valor Total

		Else

			ixx := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == M->VO3_GRUITE+M->VO3_CODITE })
			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM")+M->VO3_GRUITE))
			FG_PERDES(SBM->BM_CODMAR,VAI->VAI_CC,"P",M->VO3_GRUITE,M->VO3_CODITE,M->VO3_QTDREQ,M->VO3_PERDES,,VV1->VV1_MODVEI)

			nPerDes := M->VO3_PERDES

			aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := M->VO3_PERDES
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := nValDes//NoRound( (aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] * (nPerDes / 100)) ,2)
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := nValDes//aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

			n := ixx
			cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			FG_SEEK("SB1","cKeyAce",7,.f.)
			If Empty(M->VO3_CODTES)
				SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
			Else
				SF4->(dbSeek(xFilial("SF4")+M->VO3_CODTES))
			Endif
			MAFISREF("IT_PRODUTO","VO300",SB1->B1_COD)
			MAFISREF("IT_TES","VO300",Iif(Empty(M->VO3_CODTES),FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"),M->VO3_CODTES))
			MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
			MAFISREF("IT_DESCONTO" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)])
			aColsFEC[2,ixx,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)] := MaFisRet(n,"IT_ALIQICM")
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] := MaFisRet(n,"IT_VALICM")

			M->VO3_VALTOT := aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
			M->VO3_VALDES := aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
			M->VO3_VALICM := aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]

			n := nnAnt
			aCols[n,FG_POSVAR("VO3_VALICM")] := M->VO3_VALICM
			aCols[n,FG_POSVAR("VO3_PERDES")] := M->VO3_PERDES
			aCols[n,FG_POSVAR("VO3_VALDES")] := M->VO3_VALDES
			nValTra       := aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
			nValdes       := M->VO3_VALDES

			for ixx := 1 to len(aColsFEC[2])

				If aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE
					If ixx == oGetPecAna:oBrowse:nAt
						nTotBru += M->VO3_VALBRU
						nTotTot += M->VO3_VALTOT
						nTotDsc += M->VO3_VALDES
					Else
						nTotBru += aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
						nTotTot += aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
						nTotDsc += aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
					EndIf
				EndIf

			next

			ixx := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
			aColsFEC[1,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := NoRound( ((nTotDsc * 100) / nTotBru) ,2 )
			aColsFEC[1,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := nTotDsc
			aColsFEC[1,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := aColsFEC[1,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] - aColsFEC[1,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]

			If MaFisFound('NF')
				M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
				M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
				//				M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
				M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
				M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
				FG_ATUALOBJ()
			EndIf
			n := nnAnt
			aCols[n,FG_POSVAR("VO3_PERDES")] := M->VO3_PERDES
			aCols[n,FG_POSVAR("VO3_VALDES")] := NoRound(nValDes,2)
			aCols[n,FG_POSVAR("VO3_VALTOT")] := nValTra

		EndIf

		nTotDes += aCols[n,FG_POSVAR("VO3_VALDES")]         // Valor do Desconto
		nTotPec += aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico
		nTotTTp += aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico

		lSalvou := .f.

		If cFocus == "Sin"
			oGetPecAna:oBrowse:SetFocus()
			oGetPecAna:oBrowse:Refresh()
			oGetPecSin:oBrowse:SetFocus()
			oGetPecSin:oBrowse:Refresh()
		ElseIf cFocus == "Ana"
			oGetPecSin:oBrowse:SetFocus()
			oGetPecSin:oBrowse:Refresh()
			oGetPecAna:oBrowse:SetFocus()
			oGetPecAna:oBrowse:Refresh()
		EndIf

		oTotPec03:refresh()
		oTotTTp03:refresh()
		oTotDes03:refresh()
		oTotPec02:refresh()
		oTotTTp02:refresh()
		oTotDes02:refresh()

	Case ReadVar() == "M->VO3_VALDES"

		//		If VOI->VOI_SITTPO == "3"
		//			Help(" ",1,"M160NAODES")   // Para Tipo de Tempo Interno, nao e possivel aplicar desconto
		//			Return .f.
		//EndIf

		If M->VO3_VALDES >= M->VO3_VALBRU
			Help(" ",1,"M160VALDES")
			Return .f.
		EndIf

		If nBroAtu == 1
			If empty(aColsFEC[1,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)])
				return .f.
			EndIf
		Else
			If empty(aColsFEC[2,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
				return .f.
			EndIf

			nValdes := M->VO3_VALDES
			FS_AcertDes()

		EndIf

		nTotDes -= aCols[n,FG_POSVAR("VO3_VALDES")]         // Valor do Desconto
		nTotPec -= aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico
		nTotTTp -= aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico
		nnAnt := n

		nTotBru := 0
		nTotTot := 0
		nTotDsc := 0
		If nBroAtu == 1

			nValDes := M->VO3_VALDES
			nValBru := M->VO3_VALBRU
			nValTot := M->VO3_VALBRU - nValDes
			nPerDes := Val(str((100 - ((nValTot / nValBru) * 100)),12,2))
			M->VO3_VALBRU := nValBru
			M->VO3_PERDES := nPerDes
			M->VO3_VALDES := NoRound( (M->VO3_VALBRU * (nPerDes / 100)) ,2)
			M->VO3_VALTOT := M->VO3_VALBRU - M->VO3_VALDES
			M->VO3_VALDES := M->VO3_VALBRU - M->VO3_VALTOT

			nResto    := 0
			nRound    := 0
			nMaiorVlr := 0
			for ixx := 1 to len(aColsFEC[2])
				If aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE
					If aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] > nMaiorVlr
						nMaiorVlr := aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
					EndIf
					nRound += (NoRound((aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]/aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]) * (nPerDes / 100) ,2) * aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)])
				EndIf
			next
			nResto  := ( M->VO3_VALDES - nRound )
			nValTra := M->VO3_VALDES
			nValorZ := 0

			for ixx := 1 to len(aColsFEC[2])

				If aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE

					aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := val(str(aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] * (nPerDes / 100) / aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)] ,12,2)) * aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
					aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := val(str((aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]),12,2))
					aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := val(str(aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)],12,2))

					n := ixx
					cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
					FG_SEEK("SB1","cKeyAce",7,.f.)
					If Empty(M->VO3_CODTES)
						SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
					Else
						SF4->(dbSeek(xFilial("SF4")+M->VO3_CODTES))
					Endif
					MAFISREF("IT_PRODUTO","VO300",SB1->B1_COD)
					MAFISREF("IT_TES","VO300",Iif(Empty(M->VO3_CODTES),FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"),M->VO3_CODTES))
					MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
					MAFISREF("IT_DESCONTO" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)])
					aColsFEC[2,ixx,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)] := MaFisRet(n,"IT_ALIQICM")
					aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] := MaFisRet(n,"IT_VALICM")

					If MaFisFound('NF')
						M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
						M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
						//						M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
						M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
						M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
						FG_ATUALOBJ()
					EndIf

					aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := ( (aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] * 100) / aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] )

					M->VO3_GRUITE := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
					M->VO3_CODITE := aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
					M->VO3_QTDREQ := aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
					M->VO3_PERDES := aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
					M->VO3_VALICM := aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]
					SBM->(dbSetOrder(1))
					SBM->(dbSeek(xFilial("SBM")+M->VO3_GRUITE))
					FG_PERDES(SBM->BM_CODMAR,VAI->VAI_CC,"P",M->VO3_GRUITE,M->VO3_CODITE,M->VO3_QTDREQ,M->VO3_PERDES,,VV1->VV1_MODVEI)

					nTotBru += aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
					nTotTot += aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
					nTotDsc += aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]

				EndIf

			next

			/*			for ixx := 1 to len(aColsFEC[2])
			If aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE
			nTotBru += aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
			nTotTot += aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
			nTotDsc += aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
			EndIf
			next
			*/
			ixx := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
			aColsFEC[1,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := NoRound( (100 - (((nTotBru - nTotDsc) / nTotBru) * 100)) ,2)
			aColsFEC[1,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := nTotDsc
			aColsFEC[1,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := aColsFEC[1,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] - aColsFEC[1,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]
			M->VO3_VALDES := nTotDsc
			n := nnAnt
			aCols[n,FG_POSVAR("VO3_PERDES")] := NoRound( ((nTotDsc * 100) / nTotBru) ,2)                // Percentual de Desconto
			aCols[n,FG_POSVAR("VO3_VALDES")] := nTotDsc                // Valor de Desconto
			aCols[n,FG_POSVAR("VO3_VALTOT")] := nTotTot                // Valor Total

		Else

			ixx := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == M->VO3_GRUITE+M->VO3_CODITE })
			M->VO3_GRUITE := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
			M->VO3_CODITE := aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			M->VO3_QTDREQ := aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
			M->VO3_PERDES := aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
			SBM->(dbSetOrder(1))
			SBM->(dbSeek(xFilial("SBM")+M->VO3_GRUITE))

			nValDes := M->VO3_VALDES
			nValBru := M->VO3_VALBRU
			nValTot := M->VO3_VALBRU - nValDes
			nPerDes := 100 - ((nValTot / nValBru) * 100)

			FG_PERDES(SBM->BM_CODMAR,VAI->VAI_CC,"P",M->VO3_GRUITE,M->VO3_CODITE,M->VO3_QTDREQ,nPerDes,,VV1->VV1_MODVEI)

			aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := NoRound( nPerDes ,2)
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := NoRound( (aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] * (nPerDes / 100)) ,2)
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

			n := ixx
			cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
			FG_SEEK("SB1","cKeyAce",7,.f.)
			If Empty(M->VO3_CODTES)
				SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
			Else
				SF4->(dbSeek(xFilial("SF4")+M->VO3_CODTES))
			Endif
			MAFISREF("IT_PRODUTO","VO300",SB1->B1_COD)
			MAFISREF("IT_TES","VO300",Iif(Empty(M->VO3_CODTES),FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"),M->VO3_CODTES))
			MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
			MAFISREF("IT_DESCONTO" ,"VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)])
			aColsFEC[2,ixx,FS_POSVAR("VO3_ALQICM","aHeaderFEC",2)] := MaFisRet(n,"IT_ALIQICM")
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)] := MaFisRet(n,"IT_VALICM")

			M->VO3_VALBRU := nValBru
			M->VO3_VALTOT := aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
			M->VO3_PERDES := NoRound( ((aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] * 100) / aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]) ,2)
			M->VO3_VALDES := aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
			M->VO3_VALICM := aColsFEC[2,ixx,FS_POSVAR("VO3_VALICM","aHeaderFEC",2)]

			n := nnAnt
			aCols[n,FG_POSVAR("VO3_VALICM")] := M->VO3_VALICM
			nValTra       := aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
			nPerdes       := M->VO3_PERDES
			nValDes       := M->VO3_VALDES

			for ixy := 1 to len(aColsFEC[2])
				If aColsFEC[2,ixy,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)] == M->VO3_GRUITE
					If ixy == oGetPecAna:oBrowse:nAt
						nTotBru += M->VO3_VALBRU
						nTotTot += M->VO3_VALTOT
						nTotDsc += M->VO3_VALDES
					Else
						nTotBru += aColsFEC[2,ixy,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
						nTotTot += aColsFEC[2,ixy,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
						nTotDsc += aColsFEC[2,ixy,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
					EndIf
				EndIf
			next

			ixy := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
			aColsFEC[1,ixy,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := NoRound( (100 - (((nTotBru - nTotDsc) / nTotBru) * 100)) ,2)
			aColsFEC[1,ixy,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := NoRound( nTotDsc ,2)
			aColsFEC[1,ixy,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := aColsFEC[1,ixy,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] - aColsFEC[1,ixy,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]

			M->VO3_PERDES := nPerDes
			n := nnAnt
			aCols[n,FG_POSVAR("VO3_PERDES")] := NoRound( nPerDes ,2)
			aCols[n,FG_POSVAR("VO3_VALDES")] := nValDes
			aCols[n,FG_POSVAR("VO3_VALTOT")] := nValTra
			aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := NoRound( nPerDes ,2)
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := nValDes
			aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := nValtra

		EndIf

		nTotDes += aCols[n,FG_POSVAR("VO3_VALDES")]         // Valor do Desconto
		nTotPec += aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico
		//		nTotTTp += aCols[n,FG_POSVAR("VO3_VALTOT")]         // Valor do Servico
		nTotTTp := MAFISRET(,"NF_TOTAL")
		nTotTTp += nTotSrv

		lSalvou := .f.

		If cFocus == "Sin"
			oGetPecAna:oBrowse:SetFocus()
			oGetPecAna:oBrowse:Refresh()
			oGetPecSin:oBrowse:SetFocus()
			oGetPecSin:oBrowse:Refresh()
		ElseIf cFocus == "Ana"
			oGetPecSin:oBrowse:SetFocus()
			oGetPecSin:oBrowse:Refresh()
			oGetPecAna:oBrowse:SetFocus()
			oGetPecAna:oBrowse:Refresh()
		EndIf

		oTotPec03:refresh()
		oTotTTp03:refresh()
		oTotDes03:refresh()
		oTotPec02:refresh()
		oTotTTp02:refresh()
		oTotDes02:refresh()

	Case ReadVar() == "M->VO4_CODTES"

		If nBroAtu == 1
			If Empty(aColsFEC[3,1,FS_POSVAR("VO4_GRUSER","aHeaderFEC",3)])
				Return .f.
			EndIf
		EndIf

		For ixx := 1 to len(aHeaderFEC[4])
			n := ixx
			cKeyAce := aColsFec[3,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
			FG_SEEK("VOK","cKeyAce",1,.f.)
			FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
			SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
			MAFISREF("IT_PRODUTO" , "VO300",SB1->B1_COD)
			MaFisAlt("IT_TES",M->VO4_CODTES,n)
			MAFISREF("IT_VALMERC" , "VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)])
			MAFISREF("IT_DESCONTO", "VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)])
		Next

		M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
		M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
		//		M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
		M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
		M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
		FG_ATUALOBJ()

		oGetSrvSin:oBrowse:SetFocus()
		oGetSrvAna:oBrowse:SetFocus()

	Case ReadVar() == "M->VO4_VALBRU"

		//		If VOI->VOI_SITTPO == "3"
		//			Help(" ",1,"M160NAODES")   // Para Tipo de Tempo Interno, nao e possivel aplicar desconto
		//			Return .f.
		//		EndIf

		If nBroAtu == 3
			If empty(aColsFEC[3,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])
				return .f.
			EndIf
		Else
			If empty(aColsFEC[4,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])
				return .f.
			EndIf
		EndIf

		cKeyAce := aCols[n,FG_POSVAR("VO4_TIPSER")]
		FG_SEEK("VOK","cKeyAce",1,.f.)

		If VOK->VOK_INCMOB $ "0/1/2" // 0=Por Mao-de-Obra Gratuita;1=Por Mao-de-Obra;2=Srv de Terceiro
			Help(" ",1,"M160VALBRU")
			return .f.
		EndIf

		nValTra := M->VO4_VALBRU

		If aCols[n,FG_POSVAR("VO4_VALDES")] != 0
			nTotDes -= aCols[n,FG_POSVAR("VO4_VALDES")]         // Valor do Desconto
		Endif
		If aCols[n,FG_POSVAR("VO4_VALTOT")] != 0
			nTotSrv -= aCols[n,FG_POSVAR("VO4_VALBRU")]         // Valor do Servico
			nTotTTp -= aCols[n,FG_POSVAR("VO4_VALBRU")]         // Valor do Servico
		Endif
		nnAnt := n

		If nBroAtu == 3

			nPerDesX := (100 - (( M->VO4_VALBRU * 100 ) / aCols[n,FG_POSVAR("VO4_VALBRU")] ) )
			If M->VO4_VALBRU > aCols[n,FG_POSVAR("VO4_VALBRU")]
				nPerDesX := (((M->VO4_VALBRU / aCols[n,FG_POSVAR("VO4_VALBRU")])-1) * 100)
			EndIf

			ixx := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER })

			nValorZ := 0

			For ixx := 1 to len(aColsFEC[4])

				If aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER

					If M->VO4_VALBRU > aCols[n,FG_POSVAR("VO4_VALBRU")]
						aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += NoRound( ((aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] * (nPerDesx / 100))) ,2)
					Else
						aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] -= NoRound( ((aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] * (nPerDesx / 100))) ,2)
					EndIf
					aColsFEC[4,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := 0
					aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := 0
					aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
					nValorZ += aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]

				EndIf

			Next

			ixx := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER })

			If nValorZ != M->VO4_VALBRU

				Do Case

					Case nValorZ > M->VO4_VALBRU

						nValorX := nValorZ - M->VO4_VALBRU
						aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] -= nValorX
						aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] -= nValorx

					Case nValorZ < M->VO4_VALBRU

						nValorX := M->VO4_VALBRU - nValorZ
						aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] += nValorX
						aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nValorx

				EndCase

			EndIf

			nValBru := M->VO4_VALBRU
			nValTot := nValBru
			nValDes := 0
			nPerdes := 0

			nTotSrv += nValTot
			nTotTTp += nValTot

			n := nnAnt

			aCols[n,FG_POSVAR("VO4_VALBRU")] := nValBru
			aCols[n,FG_POSVAR("VO4_PERDES")] := nPerDes
			aCols[n,FG_POSVAR("VO4_VALDES")] := nValDes
			aCols[n,FG_POSVAR("VO4_VALTOT")] := nValTot

			M->VO4_PERDES := nPerDes
			M->VO4_VALDES := nValDes
			M->VO4_VALTOT := nValtot

			FS_RATEIO(0,M->VO4_VALBRU,nBroAtu,.t.)

		Else

			for ixx := 1 to len(aColsFEC[4])

				If aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER
					If ixx == oGetSrvAna:oBrowse:nAt
						nTotBru += M->VO4_VALBRU
					Else
						nTotBru += aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
					EndIf
				EndIf

			next

			ixx := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == M->VO4_TIPSER })

			aColsFEC[3,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)] := nTotBru
			aColsFEC[3,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 0
			aColsFEC[3,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] := 0
			aColsFEC[3,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] := aColsFEC[3,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]

			nValBru := M->VO4_VALBRU
			nValTot := nValBru
			nPerdes := 0

			nTotSrv += nValBru
			nTotTTp += nValBru
			nTotDes += nValDes

			n := nnAnt

			aCols[n,FG_POSVAR("VO4_VALBRU")] := nValBru
			aCols[n,FG_POSVAR("VO4_PERDES")] := nPerDes
			aCols[n,FG_POSVAR("VO4_VALDES")] := nValDes
			aCols[n,FG_POSVAR("VO4_VALTOT")] := nValTot

			aColsFEC[4,n,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := nValBru
			aColsFEC[4,n,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := 0
			aColsFEC[4,n,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := 0
			aColsFEC[4,n,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]

			M->VO4_PERDES := nPerDes
			M->VO4_VALDES := nValDes
			M->VO4_VALTOT := nValtot

			FS_RATEIO(0,M->VO4_VALBRU,nBroAtu,.t.)

		EndIf

		lSalvou := .f.

		If cFocus == "Sin"
			oGetSrvAna:oBrowse:SetFocus()
			oGetSrvAna:oBrowse:Refresh()
			oGetSrvSin:oBrowse:SetFocus()
			oGetSrvSin:oBrowse:Refresh()
		ElseIf cFocus == "Ana"
			oGetSrvSin:oBrowse:SetFocus()
			oGetSrvSin:oBrowse:Refresh()
			oGetSrvAna:oBrowse:SetFocus()
			oGetSrvAna:oBrowse:Refresh()
		EndIf

		oTotSrv03:refresh()
		oTotTTp03:refresh()
		oTotDes03:refresh()
		oTotSrv02:refresh()
		oTotTTp02:refresh()
		oTotDes02:refresh()

	Case ReadVar() == "M->VO4_PERDES"

		cKeyAce := aCols[n,FG_POSVAR("VO4_TIPSER")]
		FG_SEEK("VOK","cKeyAce",1,.f.)

		//		If VOI->VOI_SITTPO == "3" // .Or. VOK->VOK_TIPHOR # "1"
		//			Help(" ",1,"M160NAODES")   // Para Tipo de Tempo Interno, nao e possivel aplicar desconto
		//			Return .f.
		//		EndIf

		If M->VO4_PERDES > 99.99
			Help(" ",1,"M160PERDES")
			Return .f.
		EndIf

		If nBroAtu == 3
			If empty(aColsFEC[3,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])
				return .f.
			EndIf
		Else
			If empty(aColsFEC[4,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])
				return .f.
			EndIf
		EndIf

		If VOK->VOK_INCMOB == "0" // 0=Por Mao-de-Obra Gratuita
			return .f.
		EndIf

		nValTra := M->VO4_PERDES
		If nBroAtu == 3

			FG_PERDES(,,"S",M->VO4_TIPSER,,,M->VO4_PERDES)

			nValorZ := 0
			nValorZT:= 0

			for ixx := 1 to len(aColsFEC[4])

				If aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER
					aColsFEC[4,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := M->VO4_PERDES
					aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := round(aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] * (aColsFEC[4,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] / 100),2)
					aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] - aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					nValorZ += aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					nValorZT+= aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
				EndIf

			next

			M->VO4_PERDES := nValTra

		Else

			FG_PERDES(,,"S",M->VO4_TIPSER,M->VO4_CODSER,,M->VO4_PERDES)

		EndIf

		If aCols[n,FG_POSVAR("VO4_VALDES")] != 0
			nTotDes -= aCols[n,FG_POSVAR("VO4_VALDES")]         // Valor do Desconto
		Endif
		If aCols[n,FG_POSVAR("VO4_VALTOT")] != 0
			nTotSrv -= aCols[n,FG_POSVAR("VO4_VALTOT")]         // Valor do Servico
			nTotTTp -= aCols[n,FG_POSVAR("VO4_VALTOT")]         // Valor do Servico
		Endif

		nPerDes       := M->VO4_PERDES / 100
		nValBru       := M->VO4_VALBRU
		nValDes       := NoRound(nValBru * nPerDes,2)
		nValTot       := nValBru - nValDes
		M->VO4_VALDES := nValDes
		M->VO4_VALBRU := nValBru
		M->VO4_VALTOT := nValTot

		aCols[n,FG_POSVAR("VO4_VALDES")]   := nValDes                // Valor de Desconto
		aCols[n,FG_POSVAR("VO4_VALBRU")]   := nValBru                // Valor Bruto
		aCols[n,FG_POSVAR("VO4_VALTOT")]   := nValTot                // Valor Total
		aCols[n,FG_POSVAR("VO4_PERDES")] := M->VO4_PERDES := nValTra // Percentual de Desconto

		//Atualizar Valores da primeira getdados

		If nBroAtu == 4

			nTotBru := 0
			nTotTot := 0
			nTotDsc := 0

			for ixx := 1 to len(aColsFEC[4])

				If aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER
					If ixx == oGetSrvAna:oBrowse:nAt
						nTotBru += M->VO4_VALBRU
						nTotTot += M->VO4_VALTOT
						nTotDsc += M->VO4_VALDES
					Else
						nTotBru += aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
						nTotTot += aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
						nTotDsc += aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					EndIf
				EndIf

			next

			ixx := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == M->VO4_TIPSER })
			aColsFEC[3,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 100 - (((nTotBru - nTotDsc) / nTotBru) * 100)
			aColsFEC[3,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] := nTotDsc
			aColsFEC[3,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] := aColsFEC[3,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)] - aColsFEC[3,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)]

			FS_RATEIO(M->VO4_PERDES,M->VO4_VALTOT,nBroAtu,.f.)
			FS_RATCOB(nBroAtu,M->VO4_PERDES)

		Else

			If nValorZ != M->VO4_VALDES .or. nValorZT != M->VO4_VALTOT

				// Arredondamento de Rateio para Valor de Desconto & Valor Total

				ixx := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER })
				If nValorZ != M->VO4_VALDES
					Do Case
						Case nValorZ > M->VO4_VALDES
							nValorX := nValorZ - M->VO4_VALDES
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] -= nValorX
						Case nValorZ < M->VO4_VALDES
							nValorX := M->VO4_VALDES - nValorZ
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] += nValorX
					EndCase
				EndIf
				If nValorZT != M->VO4_VALTOT
					Do Case
						Case nValorZT > M->VO4_VALTOT
							nValorXT := nValorZT - M->VO4_VALTOT
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] -= nValorxT
						Case nValorZT < M->VO4_VALTOT
							nValorXT := M->VO4_VALTOT - nValorZT
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nValorxT
					EndCase
				EndIf

			EndIf

			FS_RATEIO(M->VO4_PERDES,M->VO4_VALTOT,nBroAtu,.f.)
			FS_RATCOB(nBroAtu,M->VO4_PERDES)

		EndIf

		nTotTTp += nValTot
		nTotSrv += nValTot
		nTotDes += nValDes

		lSalvou := .f.

		If cFocus == "Sin"
			oGetSrvAna:oBrowse:SetFocus()
			oGetSrvAna:oBrowse:Refresh()
			oGetSrvSin:oBrowse:SetFocus()
			oGetSrvSin:oBrowse:Refresh()
		ElseIf cFocus == "Ana"
			oGetSrvSin:oBrowse:SetFocus()
			oGetSrvSin:oBrowse:Refresh()
			oGetSrvAna:oBrowse:SetFocus()
			oGetSrvAna:oBrowse:Refresh()
		EndIf

		oTotSrv03:refresh()
		oTotTTp03:refresh()
		oTotDes03:refresh()
		oTotSrv02:refresh()
		oTotTTp02:refresh()
		oTotDes02:refresh()

	Case ReadVar() == "M->VO4_VALDES"

		cKeyAce := aCols[n,FG_POSVAR("VO4_TIPSER")]
		FG_SEEK("VOK","cKeyAce",1,.f.)

		//		If VOI->VOI_SITTPO == "3" // .Or. VOK->VOK_TIPHOR # "1"
		//			Help(" ",1,"M160NAODES")   // Para Tipo de Tempo Interno, nao e possivel aplicar desconto
		//			Return .f.
		//		EndIf

		If M->VO4_VALDES >= M->VO4_VALBRU .and. M->VO4_VALBRU <> 0
			Help(" ",1,"M160VALDES")
			Return .f.
		EndIf

		If nBroAtu == 3
			If empty(aColsFEC[3,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])
				return .f.
			EndIf
		Else
			If empty(aColsFEC[4,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])
				return .f.
			EndIf
		EndIf

		If VOK->VOK_INCMOB == "0" // 0=Por Mao-de-Obra Gratuita
			return .f.
		EndIf

		If aCols[n,FG_POSVAR("VO4_VALDES")] != 0
			nTotDes       -= aCols[n,FG_POSVAR("VO4_VALDES")]         // Valor do Desconto
		Endif
		If aCols[n,FG_POSVAR("VO4_VALTOT")] != 0
			nTotSrv       -= aCols[n,FG_POSVAR("VO4_VALTOT")]         // Valor do Servico
			nTotTTp       -= aCols[n,FG_POSVAR("VO4_VALTOT")]         // Valor do Servico
		Endif
		nnAnt := n

		nValDes       := M->VO4_VALDES
		nValBru       := M->VO4_VALBRU
		nValTot       := M->VO4_VALBRU - nValDes
		nPerDes       := 100 - ((nValTot / nValBru) * 100)
		M->VO4_VALBRU := nValBru
		M->VO4_VALTOT := nValTot
		M->VO4_PERDES := nPerDes

		nValTra := M->VO4_VALDES

		If nBroAtu == 3

			FG_PERDES(,,"S",M->VO4_TIPSER,,,(100 - ((M->VO4_VALTOT / M->VO4_VALBRU) * 100)))

			nValorZ := 0
			nValorZT:= 0

			for ixx := 1 to len(aColsFEC[4])

				If aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER
					aColsFEC[4,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := M->VO4_PERDES
					aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := round(aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] * (nPerDes / 100),2)
					aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] - aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					nValorZ += aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					nValorZT+= aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
				EndIf

			next

			If nValorZ != M->VO4_VALDES .or. nValorZT != M->VO4_VALTOT

				// Arredondamento de Rateio para Valor de Desconto & Valor Total

				ixx := aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER })
				If nValorZ != M->VO4_VALDES
					Do Case
						Case nValorZ > M->VO4_VALDES
							nValorX := nValorZ - M->VO4_VALDES
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] -= nValorX
						Case nValorZ < M->VO4_VALDES
							nValorX := M->VO4_VALDES - nValorZ
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] += nValorX
					EndCase
				EndIf
				If nValorZT != M->VO4_VALTOT
					Do Case
						Case nValorZT > M->VO4_VALTOT
							nValorXT := nValorZT - M->VO4_VALTOT
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] -= nValorxT
						Case nValorZT < M->VO4_VALTOT
							nValorXT := M->VO4_VALTOT - nValorZT
							aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] += nValorxT
					EndCase
				EndIf

			EndIf

			FS_RATEIO(M->VO4_PERDES,M->VO4_VALTOT,nBroAtu,.f.)
			FS_RATCOB(nBroAtu,M->VO4_PERDES)

			M->VO4_VALDES := nValTra

		Else

			FG_PERDES(,,"S",M->VO4_TIPSER,M->VO4_CODSER,,(100 - ((M->VO4_VALTOT * 100) / M->VO4_VALBRU)))

		EndIf

		n := nnAnt
		aCols[n,FG_POSVAR("VO4_PERDES")]   := NoRound(nPerDes ,2)    // Percentual de Desconto
		aCols[n,FG_POSVAR("VO4_VALDES")]   := nValDes                // Valor de Desconto
		aCols[n,FG_POSVAR("VO4_VALTOT")]   := nValTot                // Valor Total

		If nBroAtu == 4

			nTotBru := 0
			nTotTot := 0
			nTotDsc := 0

			for ixx := 1 to len(aColsFEC[4])

				If aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)] == M->VO4_TIPSER
					If ixx == oGetSrvAna:oBrowse:nAt
						nTotBru += M->VO4_VALBRU
						nTotTot += M->VO4_VALTOT
						nTotDsc += M->VO4_VALDES
					Else
						nTotBru += aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
						nTotTot += aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
						nTotDsc += aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					EndIf
				EndIf

			next

			ixx := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == M->VO4_TIPSER })
			aColsFEC[3,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 100 - (((nTotBru - nTotDsc) / nTotBru) * 100)
			aColsFEC[3,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] := nTotDsc
			aColsFEC[3,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] := aColsFEC[3,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)] - aColsFEC[3,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)]

			M->VO4_VALDES := nValTra
			FS_RATEIO(M->VO4_PERDES,M->VO4_VALTOT,nBroAtu,.f.)
			FS_RATCOB(nBroAtu,M->VO4_PERDES)

		EndIf

		nTotSrv += nValTot
		nTotTTp += nValTot
		nTotDes += nValDes

		lSalvou := .f.

		If cFocus == "Sin"
			oGetSrvAna:oBrowse:SetFocus()
			oGetSrvAna:oBrowse:Refresh()
			oGetSrvSin:oBrowse:SetFocus()
			oGetSrvSin:oBrowse:Refresh()
		ElseIf cFocus == "Ana"
			oGetSrvSin:oBrowse:SetFocus()
			oGetSrvSin:oBrowse:Refresh()
			oGetSrvAna:oBrowse:SetFocus()
			oGetSrvAna:oBrowse:Refresh()
		EndIf

		oTotSrv03:refresh()
		oTotTTp03:refresh()
		oTotDes03:refresh()
		oTotSrv02:refresh()
		oTotTTp02:refresh()
		oTotDes02:refresh()

	Case ReadVar() == "M->VSF_DESACE"


		nTotTTP := 0
		MAFISREF("NF_DESPESA","VSF00",M->VSF_DESACE)

		//		M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
		If aScan(aColsFEC[4],{ |x| !Empty(x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]) } ) != 0 .and. aScan(aColsFEC[2],{ |x| !Empty(x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]) } ) == 0 // Fechamento de Servicos
			If SF4->F4_DESPICM $ "3.4"
				nTotTTP := MaFisRet(,"NF_TOTAL")
				M->VSF_VTOTNF := nTotTTP 	//( MaFisRet(,"NF_TOTAL") + M->VSF_DESACE )
			Else
			    if SF4->F4_ISS == "S"
					nTotTTP := MaFisRet(,"NF_TOTAL")+M->VSF_DESACE
				Else
					nTotTTP := MaFisRet(,"NF_TOTAL")
				Endif
				M->VSF_VTOTNF := nTotTTP
			Endif
		Else
				nTotTTP := MaFisRet(,"NF_TOTAL")
			M->VSF_VTOTNF := nTotTTP 	//( MaFisRet(,"NF_TOTAL") + M->VSF_DESACE )
		Endif
		M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")

		//      M->VSF_DESACE := MaFisRet(,"NF_DESPESA")

		/*
		for ixx := 1 to len(aColsFEC[2])

		nTotTTP += aColsFEC[2,ixx,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

		next

		for ixx := 1 to len(aColsFEC[4])

		nTotTTP += aColsFEC[4,ixx,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]

		next
		*/
		//nTotTTP       += M->VSF_DESACE

		oLbParc:Refresh()

		/////////////////////////////////////////////////////

EndCase

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_INITEL  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa a Tela do fechamento controlando os Folders       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_INITEL()
If GetNewPar("Mv_ChmTDP","N") == "S" // Se chama tela de Departamento
	FM_TelDP() // Chama a Tela onde e' informado o Departamento
Endif

aHeader  := aClone(aHeaderFec[1])
aCols    := aClone(aColsFec[1])
n        := len(aCols)

FG_MEMVAR()

oGetPecSin:oBrowse:SetFocus()
nBroAtu := 1

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_ENTFOC  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona vetores quando pega o foco                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ENTFOC(nE)

aHeader := AClone(aHeaderFec[nE])
aCols   := AClone(aColsFec[nE])
do Case
	Case nE == 1
		n := oGetPecSin:oBrowse:nAt
		cFocus := "Sin"
	Case nE == 2
		n := oGetPecAna:oBrowse:nAt
		cFocus := "Ana"
	Case nE == 3
		n := oGetSrvSin:oBrowse:nAt
		cFocus := "Sin"
	Case nE == 4
		n := oGetSrvAna:oBrowse:nAt
		cFocus := "Ana"
EndCase
nBroAtu := nE

FG_MEMVAR()

/*  Em visita do Sandro no dia 03/05/2000 - Nao deu certo
If nE== 3
oFolderFEC:SetOption(2)
oFolderFEC:Refresh()
Elseif nE == 1
oFolderFEC:SetOption(1)
oFolderFEC:Refresh()
Endif

If nE== 3
oFolderFEC:SetOption(If(nE < 3,2,3))
oFolderFEC:Refresh()
Elseif nE == 1
oFolderFEC:SetOption(If (nE < 3,2,3))
oFolderFEC:Refresh()
Endif
*/


return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SAIFOC  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Posiciona vetores quando perde o foco                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SAIFOC(nE)

aHeaderFec[nE]   := aClone(aHeader)
aColsFec[nE]     := aClone(aCols)
n                := len(aCols)

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_LISTBOX ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao controle para o listbox do fechamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LISTBOX()
Local ixx
Local nAuxPos
Local lVO3VALLIQ := VO3->(FieldPos("VO3_VALLIQ")) <> 0
Local lVO4DESCONTO := (VO4->(FieldPos("VO4_PERDES")) > 0 .AND. VO4->(FieldPos("VO4_VALDES")) > 0)
Do Case
	Case cParam01 == 1

		// Verifica se o TT foi liberado parcialmente ...
		If OM160LIBP( aVetTTp[oVetTTp:nAt,02],aVetTTp[oVetTTp:nAt,03] )
			MsgStop(STR0201) // "Tipo de tempo liberado parcialmente, não será possível continuar através desta rotina"
			Return .f.
		EndIf
		//
		
		// Valida TES das requisicoes de pecas ...
		If Len(aVetTTp) == 1
			If !aVetTTp[01,01]
				If !OM160VLDTES(aVetTTp[01,02] , aVetTTp[01,03])
					Return .f.
				EndIf
			EndIf
		EndIf
		//

		If ExistBlock("OM160TIK")
			lRetPE := ExecBlock("OM160TIK",.f.,.f.,{cParam01})
			If !lRetPE
				Return (.f.)
			Endif
		Endif

		SA1->(DbSetOrder(1))
		SA1->(DbSeek( xFilial("SA1") + aVetTTp[oVetTTp:nAt,04] + aVetTTp[oVetTTp:nAt,10] ))

		// Verifica se o cliente esta bloqueado
		If SA1->A1_MSBLQL == "1"
			MsgStop(STR0177+CHR(13)+CHR(10)+CHR(13)+CHR(10)+SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME,STR0133) // Cliente bloqueado! / Atencao
			Return(.f.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ RUBENS - 29/07/2010                    ³
		//³ Inicializa Fiscal e Zera Variaveis ... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		if MaFisFound("NF")
			MaFisClear()
		endif
		nTotTTp    := 0
		nTotPec    := 0
		nTotSrv    := 0
		nTotDes    := 0
		//

		lFlagProc := .t.
		Private lFlag01 := .t.
		Private lFlag03 := .t.
		aVetMec :={}

		VOI->(DbSetOrder(1))
		VOI->(DbSeek( xFilial("VOI") + aVetTTp[oVetTTp:nAt,03] ))

		If Len(aVetTTp) == 1

			If !aVetTTp[01,01]

				If FS_VTTPFEC(aVetTTp[oVetTTp:nAt,02],aVetTTp[oVetTTp:nAt,03])// Verifica se a OS/Tipo de Tempo ja esta Fechado/Cancelado

					aVetTTp[oVetTTp:nAt,01] := .t.

					aHeader  := aClone(aHeaderFEC[2])
					aCols    := aClone(FS_CRIA_ACOLS(2))
					n := oGetPecAna:oBrowse:nAt
					oGetPecAna:oBrowse:Refresh()

					aHeader  := aClone(aHeaderFEC[1])
					aCols    := aClone(FS_CRIA_ACOLS(1))
					n := oGetPecSin:oBrowse:nAt
					oGetPecSin:oBrowse:Refresh()

					aHeader  := aClone(aHeaderFEC[4])
					aCols    := aClone(FS_CRIA_ACOLS(4))
					n := oGetSrvAna:oBrowse:nAt
					oGetSrvAna:oBrowse:Refresh()

					aHeader  := aClone(aHeaderFEC[3])
					aCols    := aClone(FS_CRIA_ACOLS(3))
					n := oGetSrvSin:oBrowse:nAt
					oGetSrvSin:oBrowse:Refresh()

					// Atualiza os descontos
					if lVO3VALLIQ  .and. nTotPec <> 0
						FS_ENTFOC(2)
						for nAuxPos := 1 to Len(aCols)
							If aColsFEC[2,nAuxPos,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] <> 0
								N := nAuxPos
								__READVAR := ""
								FG_MEMVAR()
								__READVAR := "M->VO3_VALDES"
								FS_ADMCPO()
							EndIf
						Next nAuxPos
					endif
					if lVO4DESCONTO .and. nTotSrv <> 0
						//						FS_ENTFOC(4)
						oGetSrvAna:oBrowse:SetFocus()
						for nAuxPos := 1 to Len(aCols)
							If aCols[n,FG_POSVAR("VO4_VALDES")] <> 0
								N := nAuxPos
								oGetSrvAna:oBrowse:nAt := N
								__READVAR := ""
								FG_MEMVAR()
								__READVAR := "M->VO4_VALDES"
								FS_ADMCPO()
							EndIf
						Next nAuxPos
						N := 1
						oGetSrvAna:oBrowse:nAt := 1
						FG_MEMVAR()
						oGetSrvAna:oBrowse:Refresh()
					endif

					oTotPec02:refresh()
					oTotTTp02:refresh()
					oTotDes02:refresh()
					oTotPec03:refresh()
					oTotTTp03:refresh()
					oTotDes03:refresh()

					oFolderFEC:nOption := 1
					oFolderFEC:aDialogs[1]:SetFocus()
					oFolderFEC:aDialogs[1]:Refresh()
					oVetTTp:SetFocus()
					oVetTTp:Refresh()

				EndIf

			Else

				aVetTTp[oVetTTp:nAt,01] := .f.

				aHeaderFEC := aClone(aHdFec)
				aColsFEC   := aClone(aClFec)

				aHeader  := aClone(aHeaderFEC[2])
				aCols    := aClone(aColsFEC[2])
				n := oGetPecAna:oBrowse:nAt
				oGetPecAna:oBrowse:Refresh()

				aHeader  := aClone(aHeaderFEC[1])
				aCols    := aClone(aColsFEC[1])
				n := oGetPecSin:oBrowse:nAt
				oGetPecSin:oBrowse:Refresh()

				aHeader  := aClone(aHeaderFEC[4])
				aCols    := aClone(aColsFEC[4])
				n := oGetSrvAna:oBrowse:nAt
				oGetSrvAna:oBrowse:Refresh()

				aHeader  := aClone(aHeaderFEC[3])
				aCols    := aClone(aColsFEC[3])
				n := oGetSrvSin:oBrowse:nAt
				oGetSrvSin:oBrowse:Refresh()

				nTotTTp    := nTtTTpa
				nTotPec    := nTtPeca
				nTotSrv    := nTtSrva
				nTotDes    := nTtDesa
				oTotSrv02  := oTtSrv02
				oTotPec02  := oTtPec02
				oTotDes02  := oTtDes02
				oTotTtp02  := oTtTtp02
				oTotSrv03  := oTtSrv03
				oTotPec03  := oTtPec03
				oTotDes03  := oTtDes03
				oTotTtp03  := oTtTtp03

				oTotPec02:refresh()
				oTotTTp02:refresh()
				oTotDes02:refresh()
				oTotPec03:refresh()
				oTotTTp03:refresh()
				oTotDes03:refresh()

				oFolderFEC:nOption := 1
				oFolderFEC:aDialogs[1]:SetFocus()
				oFolderFEC:aDialogs[1]:Refresh()
				oVetTTp:SetFocus()
				oVetTTp:Refresh()

			EndIf

		Else

			For ixx := 1 to len(aVetTTp)

				aVetTTp[ixx,01] := .f.

			Next

			aHeaderFEC := aClone(aHdFec)
			aColsFEC   := aClone(aClFec)

			If !aVetTTp[oVetTTp:nAt,01]

				If FS_VTTPFEC(aVetTTp[oVetTTp:nAt,02],aVetTTp[oVetTTp:nAt,03])// Verifica se a OS/Tipo de Tempo ja esta Fechado/Cancelado

					aVetTTp[oVetTTp:nAt,01] := .t.

					aHeader  := aClone(aHeaderFEC[2])
					aCols    := aClone(FS_CRIA_ACOLS(2))
					n := oGetPecAna:oBrowse:nAt
					oGetPecAna:oBrowse:Refresh()

					aHeader  := aClone(aHeaderFEC[1])
					aCols    := aClone(FS_CRIA_ACOLS(1))
					n := oGetPecSin:oBrowse:nAt
					oGetPecSin:oBrowse:Refresh()

					aHeader  := aClone(aHeaderFEC[4])
					aCols    := aClone(FS_CRIA_ACOLS(4))
					n := oGetSrvAna:oBrowse:nAt
					oGetSrvAna:oBrowse:Refresh()

					aHeader  := aClone(aHeaderFEC[3])
					aCols    := aClone(FS_CRIA_ACOLS(3))
					n := oGetSrvSin:oBrowse:nAt
					oGetSrvSin:oBrowse:Refresh()

					// Atualiza os descontos
					if lVO3VALLIQ .and. nTotPec <> 0
						FS_ENTFOC(2)
						for nAuxPos := 1 to Len(aCols)
							If aColsFEC[2,nAuxPos,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] <> 0
								N := nAuxPos
								FG_MEMVAR()
								__READVAR := "M->VO3_VALDES"
								FS_ADMCPO()
							EndIf
						Next nAuxPos
					endif
					if lVO4DESCONTO .and. nTotSrv <> 0
						//						FS_ENTFOC(4)
						oGetSrvAna:oBrowse:SetFocus()
						for nAuxPos := 1 to Len(aCols)
							If aCols[n,FG_POSVAR("VO4_VALDES")] <> 0
								N := nAuxPos
								oGetSrvAna:oBrowse:nAt := N
								FG_MEMVAR()
								__READVAR := "M->VO4_VALDES"
								FS_ADMCPO()
							EndIf
						Next nAuxPos
						N := 1
						oGetSrvAna:oBrowse:nAt := 1
						FG_MEMVAR()
						oGetSrvAna:oBrowse:Refresh()
					endif

					oTotPec02:refresh()
					oTotTTp02:refresh()
					oTotDes02:refresh()
					oTotPec03:refresh()
					oTotTTp03:refresh()
					oTotDes03:refresh()

					oFolderFEC:nOption := 1
					oFolderFEC:aDialogs[1]:SetFocus()
					oFolderFEC:aDialogs[1]:Refresh()
					oVetTTp:SetFocus()
					oVetTTp:Refresh()

				EndIf

			Else

				aVetTTp[oVetTTp:nAt,01] := .f.

				aHeaderFEC := aClone(aHdFec)
				aColsFEC   := aClone(aClFec)

				aHeader  := aClone(aHeaderFEC[2])
				aCols    := aClone(aColsFEC[2])
				n := oGetPecAna:oBrowse:nAt
				oGetPecAna:oBrowse:Refresh()

				aHeader  := aClone(aHeaderFEC[1])
				aCols    := aClone(aColsFEC[1])
				n := oGetPecSin:oBrowse:nAt
				oGetPecSin:oBrowse:Refresh()

				aHeader  := aClone(aHeaderFEC[4])
				aCols    := aClone(aColsFEC[4])
				n := oGetSrvAna:oBrowse:nAt
				oGetSrvAna:oBrowse:Refresh()

				aHeader  := aClone(aHeaderFEC[3])
				aCols    := aClone(aColsFEC[3])
				n := oGetSrvSin:oBrowse:nAt
				oGetSrvSin:oBrowse:Refresh()

				nTotTTp    := nTtTTpa
				nTotPec    := nTtPeca
				nTotSrv    := nTtSrva
				nTotDes    := nTtDesa
				oTotSrv02  := oTtSrv02
				oTotPec02  := oTtPec02
				oTotDes02  := oTtDes02
				oTotTtp02  := oTtTtp02
				oTotSrv03  := oTtSrv03
				oTotPec03  := oTtPec03
				oTotDes03  := oTtDes03
				oTotTtp03  := oTtTtp03

				oTotPec02:refresh()
				oTotTTp02:refresh()
				oTotDes02:refresh()
				oTotPec03:refresh()
				oTotTTp03:refresh()
				oTotDes03:refresh()

				oFolderFEC:nOption := 1
				oFolderFEC:aDialogs[1]:SetFocus()
				oFolderFEC:aDialogs[1]:Refresh()
				oVetTTp:SetFocus()
				oVetTTp:Refresh()

				Return .t.

			EndIf

		EndIf

	Case cParam01 == 2

		lFlag01 := .t.
		lFlag03 := .t.

	Case cParam01 == 3

EndCase

//Traz os descontos gravados anteriormente
FS_ABRENEG()

//Traz desconto da franquia
FS_DESFRAN()

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_RATCOB  ³ Autor ³ Emilton               ³ Data ³ 15/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rateia Tempo Cobrado                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico deste programa                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RATCOB(nBroAtu,nPerDesconto)

Local nEncAtu  := nBroatu
Local ix4      := 0

If nEncAtu == 3

	for ix4 := 1 to len(aVetMec)
		If M->VO4_TIPSER == aVetMec[ix4,02]
			If !(VOK->VOK_INCMOB $ "2/5/6") // NAO é 2=Srv de Terceiro;5=Km Socorro;6=Franquia
				Do Case
					Case VOK->VOK_INCTEM == "3"
						aVetMec[ix4,20] := aVetMec[ix4,06] - (aVetMec[ix4,06] * (nPerDesconto /100))
					Case VOK->VOK_INCTEM $ "1/2/4"
						aVetMec[ix4,20] := (aVetMec[ix4,05] * aVetMec[ix4,10]) - ((aVetMec[ix4,05] * aVetMec[ix4,10]) *  (nPerDesconto /100))
				EndCase
			EndIf
		EndIf
	Next

Else

	for ix4 := 1 to len(aVetMec)
		If M->VO4_CODSER == aVetMec[ix4,03]
			If !(VOK->VOK_INCMOB $ "2/5/6") // NAO é 2=Srv de Terceiro;5=Km Socorro;6=Franquia
				Do Case
					Case VOK->VOK_INCTEM == "3"
						aVetMec[ix4,20] := aVetMec[ix4,06] - (aVetMec[ix4,06] * (nPerDesconto /100))
					Case VOK->VOK_INCTEM $ "1/2/4"
						aVetMec[ix4,20] := (aVetMec[ix4,05] * aVetMec[ix4,10]) - ((aVetMec[ix4,05] * aVetMec[ix4,10]) *  (nPerDesconto /100))
				EndCase
			EndIf
		EndIf
	Next

EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_RATEIO  ³ Autor ³ Emilton               ³ Data ³ 12/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza rateio de descontos                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico deste programa                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RATEIO(nPerDes,nValArr,nBroAtu,lValBru)

Local nPerDesR := nPerDes
Local nValArrR := nValArr
Local nEncAtu  := nBroAtu
Local lValBruR := lValBru
Local nValorZ  := 0
Local nValorX  := 0
Local ixx

If cParam01 == 3
	return .t.
EndIf

If lValBruR

	If nEncAtu == 3

		for ixx := 1 to len(aVetMec)

			If aVetMec[ixx,02] == M->VO4_TIPSER
				aVetMec[ixx,14] := round(nValArrR * aVetMec[ixx,11],2)
				aVetMec[ixx,15] := round(nValArrR * aVetMec[ixx,11],2)
				nValorZ += aVetMec[ixx,14]
			EndIf

		next

		If nValorZ != nValArrR

			ixx := aScan(aVetMec,{ |x| x[02] == M->VO4_TIPSER })

			Do Case

				Case nValorZ > nValArrR

					nValorX := nValorZ - nValArrR
					aVetMec[ixx,14] -= nValorX
					aVetMec[ixx,15] -= nValorX

				Case nValorZ < nValArrR

					nValorX := nValArrR - nValorZ
					aVetMec[ixx,14] += nValorX
					aVetMec[ixx,15] += nValorX

			EndCase

		EndIf

	Else

		for ixx := 1 to len(aVetMec)

			If aVetMec[ixx,02]+aVetMec[ixx,03] == M->VO4_TIPSER+M->VO4_CODSER
				aVetMec[ixx,14] := round(nValArrR * aVetMec[ixx,11],2)
				aVetMec[ixx,15] := round(nValArrR * aVetMec[ixx,11],2)
				nValorZ += aVetMec[ixx,14]
			EndIf

		next

		If nValorZ != nValArrR

			ixx := aScan(aVetMec,{ |x| x[02]+x[03] == M->VO4_TIPSER+M->VO4_CODSER })

			Do Case

				Case nValorZ > nValArrR

					nValorX := nValorZ - nValArrR
					aVetMec[ixx,14] -= nValorX
					aVetMec[ixx,15] -= nValorX

				Case nValorZ < nValArrR

					nValorX := nValArrR - nValorZ
					aVetMec[ixx,14] += nValorX
					aVetMec[ixx,15] += nValorX

			EndCase

		EndIf

	EndIf

Else

	If nEncAtu == 3

		for ixx := 1 to len(aVetMec)

			If aVetMec[ixx,02] == M->VO4_TIPSER
				aVetMec[ixx,15] := aVetMec[ixx,14] - (round(aVetMec[ixx,14] * (nPerDesR / 100),2))
				nValorZ += aVetMec[ixx,15]
			EndIf

		next

		If nValorZ != nValArrR

			ixx := aScan(aVetMec,{ |x| x[02] == M->VO4_TIPSER })

			Do Case

				Case nValorZ > nValArrR

					nValorX := nValorZ - nValArrR
					aVetMec[ixx,15] -= nValorX

				Case nValorZ < nValArrR

					nValorX := nValArrR - nValorZ
					aVetMec[ixx,15] += nValorX

			EndCase

		EndIf

	Else

		for ixx := 1 to len(aVetMec)

			If aVetMec[ixx,02]+aVetMec[ixx,03] == M->VO4_TIPSER+M->VO4_CODSER
				aVetMec[ixx,15] := aVetMec[ixx,14] - (round(aVetMec[ixx,14] * (nPerDesR / 100),2))
				nValorZ += aVetMec[ixx,15]
			EndIf

		next

		If nValorZ != nValArrR

			ixx := aScan(aVetMec,{ |x| x[02]+x[03] == M->VO4_TIPSER+M->VO4_CODSER })

			Do Case

				Case nValorZ > nValArrR

					nValorX := nValorZ - nValArrR
					aVetMec[ixx,15] -= nValorX

				Case nValorZ < nValArrR

					nValorX := nValArrR - nValorZ
					aVetMec[ixx,15] += nValorX

			EndCase

		EndIf

	EndIf

EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_AVETMEC  ³ Autor ³ Emilton               ³ Data ³ 11/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Mostra Posicao analitica dos Servicos para controle interno  ³±±
±±³          ³ do programa                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico deste programa                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_AVETMEC()

Local oDlgVetMec, oVetMec
Local oFonte2  := TFont():New( "Ms Sans Serif", 6, 11 )

If empty(aVetMec)
	return .t.
endif

DEFINE MSDIALOG oDlgVetMec FROM 001,000 TO 035,080 TITLE OemToAnsi(STR0084) OF oMainWnd

@ 012,001 LISTBOX oVetMec FIELDS HEADER OemToAnsi(STR0085),;
OemToAnsi(STR0086),;
OemToAnsi(STR0087),;
OemToAnsi(STR0088),;
OemToAnsi(STR0089),;
OemToAnsi(STR0090),;
OemToAnsi(STR0091),;
OemToAnsi(STR0092),;
OemToAnsi(STR0093),;
OemToAnsi(STR0094),;
OemToAnsi(STR0095),;
OemToAnsi(STR0096),;
OemToAnsi(STR0097),;
OemToAnsi(STR0098),;
OemToAnsi(STR0099),;
OemToAnsi(STR0100),;
OemToAnsi(STR0101),;
OemToAnsi(STR0102),;
OemToAnsi(STR0103);
COLSIZES 30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30,30;
SIZE 315,200 OF oDlgVetMec  PIXEL

oVetMec:SetArray(aVetMec)
oVetMec:bLine := { || {  aVetMec[oVetMec:nAt,01] ,; 	// Nro da Os
aVetMec[oVetMec:nAt,02] ,;                     			// Tipo de Servico
aVetMec[oVetMec:nAt,03] ,;                     			// Codigo do Servico
aVetMec[oVetMec:nAt,04] ,;                     			// Codigo do Produtivo
Transform(aVetMec[oVetMec:nAt,05],"@r 999:99") ,;       // Tempo Padrao do Servico
Transform(aVetMec[oVetMec:nAt,06],"@r 999:99") ,;       // Tempo Trabalhado deste segmento
Transform(aVetMec[oVetMec:nAt,07],"@r 999:99") ,;       // Total de Tempo Trabalhado deste Servico
Transform(aVetMec[oVetMec:nAt,08],"@r 999:99") ,;       // Total de Tempo Trabalhado deste Tipo de Servico
Transform(aVetMec[oVetMec:nAt,09],"@r 999:99") ,;       // Total de Tempo Trabalhado desta Ordem de Servico
Transform(aVetMec[oVetMec:nAt,10] * 100,"@r 999.99") ,; // % em Relacao a este Servico
Transform(aVetMec[oVetMec:nAt,11] * 100,"@r 999.99") ,; // % em Relacao a este Tipo de Servico
Transform(aVetMec[oVetMec:nAt,12] * 100,"@r 999.99") ,; // % em Relacao a esta Ordem de Servico
Transform(aVetMec[oVetMec:nAt,13],"@r 999,999.99") ,;   // Valor Bruto do Servico
Transform(aVetMec[oVetMec:nAt,14],"@r 999,999.99") ,;   // Valor Rateado do Servico sem Desconto
Transform(aVetMec[oVetMec:nAt,15],"@r 999,999.99") ,;   // Valor Rateado do Servico com Desconto
Transform(aVetMec[oVetMec:nAt,16],"@r 999,999.99") ,;   // Valor Bruto Total do Servico
Transform(aVetMec[oVetMec:nAt,17],"@r 999,999.99") ,;   // Valor Bruto Total do Tipo de Servico
Transform(aVetMec[oVetMec:nAt,18],"@r 999,999.99") ,;   // Valor Bruto Total da Ordem de Servico
Transform(aVetMec[oVetMec:nAt,20],"@r 999:99") }}       // Tempo Cobrado deste Servico

@ 217,003 SAY OemToAnsi(STR0104)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 223,003 SAY OemToAnsi(STR0105)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 229,003 SAY OemToAnsi(STR0106)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 235,003 SAY OemToAnsi(STR0107)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 241,003 SAY OemToAnsi(STR0108)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 247,003 SAY OemToAnsi(STR0109)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 217,160 SAY OemToAnsi(STR0110)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 223,160 SAY OemToAnsi(STR0111)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 229,160 SAY OemToAnsi(STR0112)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 235,160 SAY OemToAnsi(STR0113)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 241,160 SAY OemToAnsi(STR0114)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 247,160 SAY OemToAnsi(STR0115)       OF oDlgVetMec PIXEL FONT OFONTE2 COLOR CLR_BLUE
@ 213,001 TO 255,315 LABEL OemToAnsi() OF oDlgVetMec PIXEL              COLOR CLR_BLACK

ACTIVATE MSDIALOG oDlgVetMec CENTER ON INIT (FS_CHBARMEC160(oDlgVetMec,{|| nOpca := 1,oDlgVetMec:End()},{|| nOpca := 0,oDlgVetMec:End()}))

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHBARMEC ³ Autor ³ Fabio                 ³ Data ³ 12/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHBARMEC(oDlg,bOk,bCancel)

Local oBar, bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0117)  //Recortar
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0118)  //Copiar
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION NaoDisp()     TOOLTIP OemToAnsi(STR0119)  //Colar
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP OemToAnsi(STR0120)  //Calculadora
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION Agenda()      TOOLTIP OemToAnsi(STR0121)  //Agenda.
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION OurSpool()    TOOLTIP OemToAnsi(STR0122)  //Gerenciador de ImpressÆo.
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar       ACTION HelProg()     TOOLTIP OemToAnsi(STR0123)  //Help de Programa.

oBar:nGroups += 6
//DEFINE BUTTON oBtOk RESOURCE OemToAnsi("OK") OF oBar GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP OemToAnsi("Ok - <Ctrl-O>")  //"OK"###"Ok - <Ctrl-O>"
//SetKEY(15,oBtOk:bAction)

//DEFINE BUTTON oBtCan RESOURCE OemToAnsi(STR0124) OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP OemToAnsi(STR0125) //"CANCEL"###"Cancelar - <Ctrl-X>"
DEFINE BUTTON oBtCan RESOURCE OemToAnsi(STR0124) OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP OemToAnsi(STR0125) //"CANCEL"###"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan:bAction)

//oDlg:bSet15 := oBtOk:bAction
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}

Return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHBAR160 ³ Autor ³ Fabio                 ³ Data ³ 12/09/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CHBAR160(oDlg,bOk,bCancel)

Local oBar, bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan , oBtOs
Local lVolta :=.f.

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar       ACTION (NaoDisp(),oFolderFEC:nOption := 1)     TOOLTIP OemToAnsi(STR0117) 	//Recortar
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar       ACTION (NaoDisp(),oFolderFEC:nOption := 1)     TOOLTIP OemToAnsi(STR0118) 	//Copiar
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar       ACTION (NaoDisp(),oFolderFEC:nOption := 1)     TOOLTIP OemToAnsi(STR0119) 	//Colar
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION (Calculadora(),oFolderFEC:nOption := 1) TOOLTIP OemToAnsi(STR0120) 	//Calculadora...
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar       ACTION (Agenda(),oFolderFEC:nOption := 1)       TOOLTIP OemToAnsi(STR0121) 	//Agenda...
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar       ACTION (OurSpool(),oFolderFEC:nOption := 1) TOOLTIP OemToAnsi(STR0122) 	//Gerenciador de ImpressÆo..
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar       ACTION (HelProg(),oFolderFEC:nOption := 1)   TOOLTIP OemToAnsi(STR0123) 	//Help de Programa...
DEFINE BUTTON RESOURCE "S4WB011N" OF oBar       ACTION (FS_AVETMEC(),oFolderFEC:nOption := 1)  TOOLTIP OemToAnsi(STR0126)  	// Posicao Analitica dos Servicos
//boby fnc 8257/13082 - 23/06/10 (FS_AVETMEC(),oFolderFEC:nOption := 1)
oBar:nGroups += 6
//DEFINE BUTTON oBtOk RESOURCE OemToAnsi("OK") OF oBar GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP OemToAnsi("Ok - <Ctrl-O>")  //"OK"###"Ok - <Ctrl-O>"
//SetKEY(15,oBtOk:bAction)
DEFINE BUTTON oBtOs RESOURCE "PESQUISA" OF oBar ACTION (FG_OSONLINE(),oFolderFEC:nOption := 1) TOOLTIP OemToAnsi(STR0143)
//boby fnc 8257/13082 - 23/06/10 - (FG_OSONLINE(),oFolderFEC:nOption := 1)
//DEFINE BUTTON oBtCan RESOURCE OemToAnsi(STR0124) OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtonOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP OemToAnsi(STR0125) //"CANCEL"###"Cancelar - <Ctrl-X>"
//SetKEY(24,oBtCan:bAction)

If !(cPaisLoc == "BRA")
	DEFINE BUTTON oBtOk RESOURCE OemToAnsi("OK") OF oBar GROUP ACTION (  Processa( { || cTudoOk, If(FS_FECHAR16(),(oDlgFechamento:End()),.t.) },OemtoAnsi(STR0076),"",.t.)) TOOLTIP OemToAnsi(STR0077)
	SetKEY(15,oBtOk:bAction)
	oDlg:bSet15 := oBtOk:bAction
Endif

//	DEFINE BUTTON RESOURCE " " OF oBar ACTION ( Processa( { || cTudoOk, If(FS_FECHAR(),(FS_VOLTAR(),oDlgFechamento:End()),.t.) },OemtoAnsi(STR0076),"",.t.) ) TOOLTIP OemToAnsi(STR0077)  // "OK"###"Executar Fechamento - <Ctrl-O>"

//oDlg:bSet15 := oBtOk:bAction
//oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}

Return nil

Static Function ButtonOff(bSet6,bSet15,bSet24,lOk)

DEFAULT lOk := .t.

IF lOk
	SetKey(6,bSet6)
	SetKey(15,bSet15)
	SetKey(24,bSet24)
Endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_FILCLI  ³ Autor ³ Emilton               ³ Data ³ 26/05/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Filtra cliente para pergunte                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FILCLI()

If cParam01 == 2

	//   return FG_SEEK("VOO","SA1->A1_COD+SA1->A1_LOJA",1,.f.)
	return FG_SEEK("VOO","SA1->A1_COD",3,.f.)

Else

	FG_SEEK("VF4","SA1->A1_COD+SA1->A1_LOJA",3,.f.)
	If empty(VF4->VF4_NUMOSV)
		return .t.
	Else
		Return .f.
	EndIf


EndIf

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_TELACOND³ Autor ³ Emilton               ³ Data ³ 02/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Condicao de Pagamento                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TELACOND()

aRotinaOld := aClone(aRotina)
aRotina := MenuDef()
///aRotina := {{STR0002, "AxPesqui",0,1},;		//Pesquisar
///{STR0002, "AxPesqui",0,2},;		//Pesquisar
///{STR0002, "AxPesqui",0,3},;		//Pesquisar
///{STR0003, "OFIM160I",0,4}}		//Fechar

FG_TELACOND(oFolderFEC:aDialogs[4],2)

aRotina := aClone(aRotinaOld)

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_Inicia  ³ Autor ³ Emilton               ³ Data ³ 02/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Inicializa a Tela do Fechamento da OS                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_Inicia()

aTela := aClone(aSvATela[1])
aGets := aClone(aSvAGets[1])

Do Case
	Case cParam01 == 1
		dbSelectArea("VO1")
	Case cParam01 == 2
		dbSelectArea("SA1")
	Case cParam01 == 3
		dbSelectArea("SA1")
EndCase

Return .T.


//Static Function FS_Entra(nE,cAlias)
Function FS_Entra(nE,cAlias)
aTela := AClone(aSvAtela[nE])
aGets := AClone(aSvaGets[nE])
dbSelectArea(cAlias)
Return


//Static Function FS_Sai(nE)
Function FS_Sai(nE)
aSvATela[nE]	:= aClone(aTela)
aSvAGets[nE]   	:= aClone(aGets)
Return


//////////////////////
Function FS_MUDAFPG1()

Local wRet := .t.
Local nValor

if Left(Funname(),4) == "OFIX" .or. FunName() == "OFIOM350"
	return .t.
endif

nValor := nTotTTP

cTipPagMil := cTipPag
If lVO1_NATSRV
	if !Empty(SA1->A1_TIPPER)
		if !(!Empty(cForPeri) .and. cForPeri == cTipPag)

			nPosVirg := AT(",",GETMV("MV_NATPER"))
			If _cPecSrv == "P"
				If Empty(VOI->VOI_NATPEC)// Natureza de Pecas
					cVO1_NATURE := If(nPosVirg>0,Left(GETMV("MV_NATPER"),nPosVirg-1),GETMV("MV_NATPER"))
				Endif
			ElseIf _cPecSrv == "S" // Natureza de Servicos
				If Empty(VOI->VOI_NATSRV)
					cVO1_NATSRV := If(nPosVirg>0,Alltrim(Subs(GETMV("MV_NATPER"),nPosVirg+1)),GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
				Endif
			Else
				If Empty(VOI->VOI_NATPEC)
					cVO1_NATURE := If(nPosVirg>0,Left(GETMV("MV_NATPER"),nPosVirg-1),GETMV("MV_NATPER"))
				Endif
				If Empty(VOI->VOI_NATSRV)
					cVO1_NATSRV := If(nPosVirg>0,Alltrim(Subs(GETMV("MV_NATPER"),nPosVirg+1)),GETMV("MV_NATPER"))   // Codigo da natureza dos titulos a serem gerados
				Endif
			Endif

			nOperacao := Aviso( STR0152 , STR0153  , { STR0154 , STR0155 } )//Cliente Periodico # Este e um cliente periodico, mudando a condicao de pagamento o sistema nao gerara titulos provisorios...! # OK # Cancela
			if nOperacao <> 1
				Return .f.
			Endif
		Endif
	Else
		If _cPecSrv  == "P" // Natureza de Pecas
			If Empty(cVO1_NATURE)
				cVO1_NATURE := VOI->VOI_NATPEC
			Endif
			cVO1_NATSRV := Space(TAMSX3("VOI_NATSRV")[1])
		ElseIf _cPecSrv == "S" // Natureza de Servicos
			If Empty(cVO1_NATSRV)
				cVO1_NATSRV := VOI->VOI_NATSRV
			Endif
			cVO1_NATURE := Space(TAMSX3("VOI_NATPEC")[1])
		Else
			If Empty(cVO1_NATURE)
				cVO1_NATURE := VOI->VOI_NATPEC
			Endif
			If Empty(cVO1_NATSRV)
				cVO1_NATSRV := VOI->VOI_NATSRV
			Endif
		Endif
	Endif
Endif

DbSelectArea("SE4")
DbGotop()
if DbSeek(xFilial("SE4")+cTipPag)
	cDesPag := SE4->E4_DESCRI
Else
	wRet := .f.
Endif

if wRet

	//	if SA1->A1_RECISS == "1" .and. nTotSrv > 0
	//		MsgInfo( STR0156 , STR0133 )//Cliente com retenção de ISS... # Atencao!
	//		nIssRet := Round(((nTotSrv * GetMV("MV_ALIQISS"))/100),2)
	//		nValor := nTotTTP - nIssRet
	//	Endif

	if SE4->(DbSeek(xFilial("SE4")+cTipPag))
		if SE4->E4_TIPO#"A"

			FG_CONDICAO(cCondic1,cCondic2,cCondic3,cCondic4,cCondic5,cTipPag,nValor,cTipOpe)

		Else

			FG_DESFPAG()
			cCondic1:=ctod(" ")
			cCondic2:=space(02)
			cCondic3:= space(len(SE1->E1_PARCELA))
			cCondic4:=space(02)

		Endif
	Endif
Endif
if wRet ==.t.
	if Empty(cTipPag)
		cTipPag := cTipPagMil
	endif
endif
if type("oDesPag") == "O"
	oDesPag:Refresh()
Endif

Return(wRet)


//////////////////////
Function FS_MUDABCO1()

Local lRetFech := .t.

if Empty(cCodBco)
	cCodBco := Space(3)
	cDesBco := Space(3)
	If Type("oDesBco") == "O"
		oDesBco:Refresh()
	Endif
Else
	if FG_SEEK("SA6","cCodBco",1,.f.)
		cDesBco := SA6->A6_NOME
		If Type("oDesBco") == "O"
			oDesBco:Refresh()
		Endif
	Else
		lRetFech := .f.
	Endif
Endif

Return(lRetFech)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_TRAABA  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao para tratamento de processos em cada aba              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TRAABA()

Local ixx,ixy
Local nTT  := 1
Local nTTF := 1
Local oArea := GetArea()
Local cAuxTES := ""
n := 1
If cParam01 == 1 // Fechamento Individual
	nTT := 0
	For nTTF := 1 to len(aVetTTP)
		If aVetTTP[nTTF,1]
			nTT++
		Endif
	Next
EndIf
If oFolderFEC:nOption == 2

	If nTT == 0
		Help(" ",1,"M160FALTTP")   // Falta tipo de tempo
		oFolderFec:nOption := 1
		return
	Endif

	VO3->(dBSetOrder(8))                   //boby fnc 8257/13082 - 23/06/10
	If VO3->(!dbSeek(xFilial("VO3")+VO1->VO1_NUMOSV))
		VO3->(dBSetOrder(1))
		MSGSTOP(STR0182,STR0181)   //"OS Não Possui Peças","Atenção"
		oFolderFec:nOption := 1
		return
	Endif
	VO3->(dBSetOrder(1))
	n:= oGetPecSin:oBrowse:nAt
	oGetPecSin:oBrowse:SetFocus()

ElseIf oFolderFEC:nOption == 3

	If nTT == 0
		Help(" ",1,"M160FALTTP")   // Falta tipo de tempo
		oFolderFec:nOption := 1
		return
	Endif

	if cParam01 != 3
		VO4->(dBSetOrder(10))            //boby fnc 8257/13082 - 23/06/10
		If VO4->(!dbSeek(xFilial("VO4")+VO1->VO1_NUMOSV))
			VO4->(dBSetOrder(1))
			MSGSTOP(STR0183,STR0181)   //"OS Não Possui Serviço","Atenção"
			oFolderFec:nOption := 1
			return
		Endif
	endif
	VO4->(dBSetOrder(1))
	n:= oGetSrvSin:oBrowse:nAt
	oGetSrvSin:oBrowse:SetFocus()

ElseIf oFolderFEC:nOption == 4

	If nTT == 0
		Help(" ",1,"M160FALTTP")   // Falta tipo de tempo
		oFolderFec:nOption := 1
		return
	Endif

	If cPaisLoc == "BRA" // Manoel - 12/05/2009

		If lCond1Vez
			lCond1Vez := .f.
			n := oGetCondicao:oBrowse:nAt
			oGetCondicao:oBrowse:SetFocus()

			n := 1
			oGetPecSin:oBrowse:SetFocus()
			oGetPecSin:oBrowse:Refresh()
		EndIf

	EndIf

	Do Case
		Case cParam01 == 1  // Fechamento Individual

			ProcRegua(len(aColsFEC[2])+len(aColsFEC[4]))

			For ixy := 1 to len(aVetTTp)

				If aVetTTp[ixy,01]

					MaFisClear()
					If !MaFisFound('NF')
						SA1->(DbSetOrder(1))
						SA1->(DbSeek(xFilial("SA1") + aVetTTp[ixy,04] + aVetTTp[ixy,10] ))
						If !Empty(SA1->A1_LOJA)
							FP_INIIMP(SA1->A1_COD,SA1->A1_LOJA)
						EndIf
					Else
						MaFisReprocess(2)
					EndIf
					n := 0
					If !Empty(aColsFEC[2,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
						For ixx := 1 to len(aColsFec[2])

							&& Valida se o valor esta correto
							If !FS_VALVLR160(aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)],aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)],aColsFEC[2,ixx,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)])
								oFolderFec:nOption := 2
								Return(.f.)
							EndIf

							n ++
							cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
							if FG_SEEK("SB1","cKeyAce",7,.f.)
								SF4->(dbSetOrder(1))
								//								MAFISREF("IT_PRODUTO", "VO300",SB1->B1_COD)
								//								MAFISREF("IT_TES"    , "VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)])
								//								MAFISREF("IT_VALMERC", "VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
								//								MAFISREF("IT_DESCONTO","VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)])
								SF4->(dbSeek( xFilial("SF4") + aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] ))

								MaFisIniLoad(n,{	SB1->B1_COD,;
								aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)],;
								" "  ,;
								aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],;
								"",;
								"",;
								SB1->(RecNo()),;	//IT_RECNOSB1
								SF4->(RecNo()),;	//IT_RECNOSF4
								0 }) 			//IT_RECORI
								MaFisLoad("IT_PRODUTO",SB1->B1_COD,n)
								MaFisLoad("IT_QUANT",aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],n)
								MaFisLoad("IT_TES",aColsFEC[2,ixx,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)],n)
								MaFisLoad("IT_VALMERC",Round(aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)],2),n)
								MaFisLoad("IT_DESCONTO",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)],n)
								MaFisRecal("",n)
								MaFisEndLoad(n,1)
							Endif
							IncProc(STR0127)
						Next
					EndIf

					cKeyAce := aVetTTp[ixy,3]
					FG_SEEK("VOI","cKeyAce",1,.f.)
					FG_SEEK("SF4","VOI->VOI_CODTES",1,.f.)

					If !Empty(aColsFec[4,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])

						SF4->(dbSetOrder(1))

						For ixx := 1 to len(aColsFec[4])

							If !FS_VALVLR160(,,aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)],aColsFEC[4,ixx,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)],aVetTTp[ixy,3],aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])
								oFolderFec:nOption := 3
								Return(.f.)
							EndIf
							n ++
							cKeyAce := aColsFec[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
							FG_SEEK("VOK","cKeyAce",1,.f.)
							FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
							//							FG_SEEK("SF4","SB1->B1_TS",1,.f.)
							//							MAFISREF("IT_PRODUTO" , "VO400",SB1->B1_COD)
							//							ix4 := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]})
							//							if ix4 > 0
							//								MAFISREF("IT_TES"  , "VO400",aColsFEC[3,ix4,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)])
							//							Endif
							//							MAFISREF("IT_VALMERC" , "VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)])
							//							MAFISREF("IT_DESCONTO", "VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)])

							ix4 := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]})
							if ix4 > 0
								cAuxTES := aColsFEC[3,ix4,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)]
							Else
								cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
							EndIf
							SF4->(dbSeek( xFilial("SF4") + cAuxTES ))

							MaFisIniLoad(n,{	SB1->B1_COD,;
							cAuxTES,;
							" "  ,;
							1,;	// Qtde
							"",;
							"",;
							SB1->(RecNo()),;	//IT_RECNOSB1
							SF4->(RecNo()),;	//IT_RECNOSF4
							0 }) 			//IT_RECORI
							MaFisLoad("IT_PRODUTO",SB1->B1_COD,n)
							MaFisLoad("IT_QUANT",1,n)
							MaFisLoad("IT_TES",cAuxTES,n)
							//	MaFisLoad("IT_PRCUNI",aColsP[nCntFor,FG_POSVAR("VS3_VALPEC","aHeaderP")],n)
							MaFisLoad("IT_VALMERC",aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)],n)
							MaFisLoad("IT_DESCONTO",aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)],n)
							MaFisRecal("",n)
							MaFisEndLoad(n,1)

							IncProc(STR0128)
						Next
					EndIf

					//	   				oGetCondicao:oBrowse:SetFocus()
					//	   				oGetCondicao:oBrowse:Refresh()

					If MaFisFound('NF')
						if M->VSF_DESACE > 0
							MAFISREF("NF_DESPESA","VSF00",M->VSF_DESACE)
						Endif
						M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
						M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
						//						M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
						If cPaisLoc == "BRA" // Manoel - 12/05/2009
							M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
							M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
						Endif
						FG_ATUALOBJ()
					EndIf

				EndIf

			Next

		Case cParam01 == 2  // Fechamento Agrupado

			FG_SEEK("SA1","cParam02+cParam03",1,.F.)
			ProcRegua(len(aColsFEC[2])+len(aColsFEC[4]))

			For ixy := 1 to len(aVetOSv)

				cKeyAce := aVetOSv[ixy,01]
				FG_SEEK("VO1","cKeyAce",1,.f.)

				If !MaFisFound('NF')
					If !Empty(SA1->A1_LOJA)
						FP_IniImp(SA1->A1_COD,SA1->A1_LOJA)
					EndIf
				Else
					MaFisReprocess(2)
				EndIf

				n := 0

				If !Empty(aColsFEC[2,1,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])

					For ixx := 1 to len(aColsFec[2])

						&& Valida se o valor esta correto
						If !FS_VALVLR160(aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)],aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)],aColsFEC[2,ixx,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)])
							oFolderFec:nOption := 2
							Return(.f.)
						EndIf

						n ++
						cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
						FG_SEEK("SB1","cKeyAce",7,.f.)
						SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
						MAFISREF("IT_PRODUTO" , "VO300",SB1->B1_COD)
						MAFISREF("IT_TES"     , "VO300",FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"))
						MAFISREF("IT_VALMERC" , "VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
						MAFISREF("IT_DESCONTO", "VO300",aColsFEC[2,ixx,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)])
						IncProc(STR0129)

					Next

				EndIf

				cKeyAce := cParam04
				FG_SEEK("VOI","cKeyAce",1,.f.)
				FG_SEEK("SF4","VOI->VOI_CODTES",1,.f.)
				If !Empty(aColsFec[4,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])

					For ixx := 1 to len(aColsFec[4])

						If !FS_VALVLR160(,,aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)],aColsFEC[4,ixx,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)],cParam04,aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])
							oFolderFec:nOption := 3
							Return(.f.)
						EndIf

						n ++
						cKeyAce := aColsFec[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
						FG_SEEK("VOK","cKeyAce",1,.f.)
						FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`¿
						//³ Busca a TES do Tipo de Servico ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ`Ù
						cAuxTES := ""
						nPosTPSRVC := aScan( aColsFEC[3] , { |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == cKeyAce } )
						if nPosTPSRVC > 0
							cAuxTES := aColsFEC[3,nPosTPSRVC,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)]
						endif
						if Empty(cAuxTES)
							cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
						endif
						if Empty(cAuxTES)
							cAuxTES := VOI->VOI_CODTES
						endif

						SF4->(dbSetOrder(1))
						SF4->(dbSeek(xFilial("SF4") + cAuxTES ))
						MAFISREF("IT_PRODUTO", "VO400",SB1->B1_COD)
						MAFISREF("IT_TES",     "VO400",cAuxTES)
						MAFISREF("IT_VALMERC", "VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)])
						MAFISREF("IT_DESCONTO","VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)])
						IncProc(STR0130)

					Next

				EndIf

				If MaFisFound('NF')
					M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
					M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
					//					M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
					If cPaisLoc == "BRA" // Manoel - 12/05/2009
						M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
						M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
					Endif
					FG_ATUALOBJ()
				EndIf

			Next

		Case cParam01 == 3  // Fechamento Kilometro

			ProcRegua(len(aColsFec[4]))

			If !MaFisFound('NF')
				If !Empty(SA1->A1_LOJA)
					FP_IniImp(SA1->A1_COD,SA1->A1_LOJA)
				EndIf
			Else
				MaFisReprocess(2)
			EndIf
			If !Empty(aColsFec[4,1,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])

				n := 0

				cKeyAce := cParam04
				FG_SEEK("VOI","cKeyAce",1,.f.)
				FG_SEEK("SF4","VOI->VOI_CODTES",1,.f.)

				For ixx := 1 to len(aColsFec[4])

					n ++
					cKeyAce := aColsFec[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
					FG_SEEK("VOK","cKeyAce",1,.f.)
					FG_SEEK("SB1","VOK->VOK_GRUITE+VOK->VOK_CODITE",7,.f.)
					SF4->(dbSeek(xFilial("SF4")+FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")))
					MAFISREF("IT_PRODUTO" ,"VO400",SB1->B1_COD)
					MAFISREF("IT_TES"     ,"VO400",VOI->VOI_CODTES)
					MAFISREF("IT_VALMERC" ,"VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)])
					MAFISREF("IT_DESCONTO","VO400",aColsFEC[4,ixx,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)])
					IncProc(STR0131)

				Next

			EndIf

			If MaFisFound('NF')
				M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
				M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
				//				M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
				IF cParam01 != 3
					MAFISREF("IT_TES","VO400",FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS"))
				endif
				If cPaisLoc == "BRA" // Manoel - 12/05/2009
					M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
					M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
				Endif

				FG_ATUALOBJ()
			EndIf

	EndCase
	cQryAlias = "SQLORC"
	lVaiOrc := .f.
	cQuery := "SELECT VS1_CODBCO FROM "+RetSqlName("VS1")+ " WHERE VS1_FILIAL ='"+xFilial("VS1")+"' AND VS1_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VS1_CODBCO <> ' ' AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
	(cQryAlias)->(dbGoTop())
	if !(cQryAlias)->(eof())
		cCodBco := (cQryAlias)->(VS1_CODBCO)
		lVaiOrc := .t.
	endif
	(cQryAlias)->(dbCloseArea())
	//
	cQryAlias = "SQLORC"
	cQuery := "SELECT VS1_FORPAG FROM "+RetSqlName("VS1")+ " WHERE VS1_FILIAL ='"+xFilial("VS1")+"' AND VS1_NUMOSV = '"+VO1->VO1_NUMOSV+"' AND VS1_FORPAG <> ' ' AND D_E_L_E_T_=' '"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQryAlias, .F., .T. )
	(cQryAlias)->(dbGoTop())
	if !(cQryAlias)->(eof())
		//		cTipPag := (cQryAlias)->(VS1_FORPAG)
		lVaiOrc := .t.
	endif
	(cQryAlias)->(dbCloseArea())
	RestArea( oArea )
	//
	if lVaiOrc
		lSalvou := .f.
		FS_MUDAFPG()
		oCodBco:Refresh()
		oTipPag:Refresh()
	endif
	If !(cPaisLoc == "BRA") // Manoel - 12/05/2009
		oFolderFec:nOption := 1
		Return .f.
	Endif
EndIf

Return .t.

/*
Static Function ButtOff(bSet6,bSet15,bSet24,lOk)

DEFAULT lOk := .t.

if lOk
SetKey(6,bSet6)
SetKey(15,bSet15)
SetKey(24,bSet24)
Endif

Return .t.
*/
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_LIBVEN  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata a Liberacao da Venda                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_LIBVEN()

Local lLibVen := .t.
Local ixx := 0

For ixx := 1 to len(aColsFEC[2])

	If aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] > 0

		cKeyAce := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
		FG_SEEK("SBM","cKeyAce",1,.f.)

		If aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] > SBM->BM_PERDES

			lLibVen := .f.

			If MsgYesNo(OemToAnsi(STR0132),OemToAnsi(STR0133))//Atencao
				X := 0
			EndIf

		EndIf

	EndIf

Next

For ixx := 1 to len(aColsFEC[4])

	If aColsFEC[4,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] > 0

		cKeyAce := aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
		FG_SEEK("VOK","cKeyAce",1,.f.)

		If aColsFEC[4,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] > VOK->VOK_PERDES

			lLibVen := .f.

			If MsgYesNo(OemToAnsi(STR0134),OemToAnsi(STR0133))
				X := 0
			EndIf

		EndIf

	EndIf

Next

Return .f.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_AVAFEC  ³ Autor ³ Emilton               ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Trata a Avaliacao de Resultados do Fechamento de OS          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_AVAFEC()

Local ixw		  := 0
Private aSomaStru := {}
Private nCont     := 0

If !FS_VERTTP()
	if valType(aColsC) <> "U"
		n := 1
		aHeader  := aClone(aHeaderC)
		aCols    := aClone(aColsC)
	endif

	return .f.
EndIf

If cPaisLoc == "BRA" // Manoel - 13/05/2009
	If Empty(cTipPag)
		Help(" ",1,"M160TIPPAG")   // Falta Tipo de Pagamento
		if valType(aColsC) <> "U"
			n := 1
			aHeader  := aClone(aHeaderC)
			aCols    := aClone(aColsC)
		endif
		Return .f.
	EndIf

	If Empty(cCodBco) .and. !empty(cTipPag)
		cKeyAce := cTipPag
		If FG_SEEK("SE4","cKeyAce",1,.f.)
			If SE4->E4_TIPO == "A"
				If Empty(cCondic2) .or. Empty(cCondic3) .or. Empty(cCondic4)
					Help(" ",1,"M160CONNEG")   // Condicao negociada carece de informacoes de financiamento
					if valType(aColsC) <> "U"
						n := 1
						aHeader  := aClone(aHeaderC)
						aCols    := aClone(aColsC)
					endif
					Return .f.
				EndIf
			EndIf
		EndIf
	EndIf

	If !Empty(cCodCDCI) .and. Empty(aIteParc[1,1])
		Help(" ",1,"M160CALPAR")   // Parcelas nao Calculadas
		if valType(aColsC) <> "U"
			n := 1
			aHeader  := aClone(aHeaderC)
			aCols    := aClone(aColsC)
		endif

		Return .f.
	EndIf
EndIf

Private aStruP  := {}
Private aStruS  := {}
Private aStruO  := {}
Private cCodMap
Private cOutMoed
Private cSimOMoe
Private lCalcTot:= .f.
Private cCpoDiv := "    1"
Private cNumIde
PRIVATE cTipAva := "4"

If !PERGUNTE("ATDOFI")
	if valType(aColsC) <> "U"
		n := 1
		aHeader  := aClone(aHeaderC)
		aCols    := aClone(aColsC)
	endif

	return .t.
EndIf

cMapPecas := Mv_Par01
cMapSrvcs := Mv_Par02
cMapOdSrv := Mv_Par03

cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

DbSelectArea("VS6")
RecLock("VS6",.t.)
VS6->VS6_FILIAL := xFilial("VS6")
VS6->VS6_NUMIDE := GetSxENum("VS6","VS6_NUMIDE")
ConfirmSx8()
if VS6->(FieldPos("VS6_TIPTEM")) > 0
	VS6->VS6_TIPTEM := VOO->VOO_TIPTEM
endif
VS6->VS6_DATOCO := dDataBase
VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
VS6->VS6_NUMORC := ""
VS6->VS6_TIPOCO := "000008"
VS6->VS6_DESOCO := "DESCONTOS"
VS6->VS6_USUARI := substr(cUsuario,7,15)
VS6->VS6_TIPAUT := "2"
VS6->VS6_CODCLI := SA1->A1_COD
VS6->VS6_LOJA   := SA1->A1_LOJA
VS6->VS6_FORPAG := cTipPag
// cNumLib := VS6->VS6_NUMIDE  <------- Na avaliacao de resultados precisa haver numero da liberacao ??

// MSMM(,TamSx3("VS6_OBSERV")[1],,cObserv,1,,,"VS6","VS6_OBSMEM")
MsUnlock()

DbSelectArea("VS7")
For ixw:=1 to Len(aColsFEC[2])

	If !empty(aColsFEC[2,ixw,1])
		RecLock("VS7",.t.)

		VS7->VS7_FILIAL := xFilial("VS7")
		VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
		VS7->VS7_SEQUEN := Strzero(ixw,4)
		VS7->VS7_TIPAUT := "1"
		VS7->VS7_GRUITE := aColsFEC[2,ixw,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
		VS7->VS7_CODITE := aColsFEC[2,ixw,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]

		//Atribui a variavel "nDesPer" o Desconto Permitido
		SBM->(dbSetOrder(1))
		SBM->(dbSeek(xFilial("SBM")+aColsFEC[2,ixw,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]))
		//		FG_PERDES(SBM->BM_CODMAR,VAI->VAI_CC,"P",aColsFEC[2,ixw,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)],aColsFEC[2,ixw,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)],aColsFEC[2,ixw,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],(100 - ((aColsFEC[2,ixw,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] * 100) / aColsFEC[2,ixw,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])),.f.)
		aRetDes := OX005PERDES(SBM->BM_CODMAR,VAI->VAI_CC,aColsFEC[2,ixw,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)],aColsFEC[2,ixw,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)],aColsFEC[2,ixw,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],(100 - ((aColsFEC[2,ixw,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] * 100) / aColsFEC[2,ixw,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])),.t.,SA1->A1_COD,SA1->A1_LOJA," ",aColsFEC[2,ixw,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]/aColsFEC[2,ixw,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],3)
		dbSelectArea("VS7")
		VS7->VS7_DESPER := nDesPer := aRetDes[2]
		VS7->VS7_MARPER := aRetDes[3]
		VS7->VS7_DESDES := aColsFEC[2,ixw,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
		VS7->VS7_VALORI := aColsFEC[2,ixw,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
		VS7->VS7_VALPER := aColsFEC[2,ixw,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]*(1-(VS7->VS7_DESPER/100))
		VS7->VS7_VALDES := aColsFEC[2,ixw,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
		MsUnlock()

	EndIf

Next

For ixw:=1 to Len(aColsFEC[4])

	If !empty(aColsFEC[4,ixw,1])

		RecLock("VS7",.t.)
		VS7->VS7_FILIAL := xFilial("VS7")
		VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
		VS7->VS7_SEQUEN := Strzero(ixw,4)
		VS7->VS7_TIPAUT := "2"
		VS7->VS7_GRUSER := aColsFEC[4,ixw,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
		VS7->VS7_CODSER := aColsFEC[4,ixw,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
		VS7->VS7_TIPSER := aColsFEC[4,ixw,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
		cKeyAce := aColsFEC[4,ixw,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]

		If FG_SEEK("VOK","cKeyAce",1,.f.)
			VS7->VS7_DESPER := VOK->VOK_PERMAX
		Endif
		dbSelectArea("VS7")

		VS7->VS7_DESDES := aColsFEC[4,ixw,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
		VS7->VS7_VALORI := aColsFEC[4,ixw,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
		VS7->VS7_VALPER := aColsFEC[4,ixw,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]*(1-(VS7->VS7_DESPER/100))
		VS7->VS7_VALDES := aColsFEC[4,ixw,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
		MsUnlock()

	EndIf

Next
cNumero := VS6->VS6_NUMIDE
cParPro := "1"
cContChv:= "VEC_NUMORC"
cParTem := ""

FS_GRAAVA(VS6->VS6_NUMIDE)

MSGRUN(oemtoansi( STR0157 ),"",{||CursorWait(),FS_AVRES2(),CursorArrow()}) //Aguarde... Processando Mapa de Avaliacao

FG_ResAva(cOutMoed,3,"S","","OFIOM160",{aStruP,aStruS,aStruO})

if valType(aColsC) <> "U"
	n := 1
	aHeader  := aClone(aHeaderC)
	aCols    := aClone(aColsC)
endif


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VERTTP   ³ Autor ³ Emilton             ³ Data ³ 13/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verfica se ha tipo de tempo selecionado                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³OFIOM160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERTTP()

Local lRetFech      := .f.
Local ixi       := 0

Do Case
	Case cParam01 == 1

		For ixi := 1 to len(aVetTTp)
			If aVetTTp[ixi,01]
				lRetFech := .t.
				exit
			EndIf
		Next

		If !lRetFech
			Help(" ",1,"M160FALTTP")   // Falta Tipo de Tempo
			Return .f.
		EndIf

	Case cParam01 == 2

	Case cParam01 == 3

EndCase

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FP_INIIMP   ³ Autor ³ ANDRE               ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Inicia Empresa                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Cliente e Loja                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Funcao Microsiga                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FP_INIIMP(cCodCli,cLoja)

If !MaFisFound('NF')
	if lA1_IBGE
		FG_SEEK("VAM","SA1->A1_IBGE",1,.f.)
	endif
	//If (SA1->A1_PESSOA == "J" .or. SA1->A1_PESSOA == "F" ) .and. !Empty(SA1->A1_INSCR) .and. VAM->VAM_ESTADO <> GETMV("MV_ESTADO")
	//	cCodCli := GetMv("MV_CLIPAD")
	//	cLoja := GetMv("MV_LOJAPAD")
	//Endif

	If !Empty(cLoja)
		//      MaFisIni(cCodCli,cLoja,'C','N',SA1->A1_TIPO,A103RelImp())
		MaFisIni(cCodCli,cLoja,'C','N',SA1->A1_TIPO,MAFISRelImp("OFIOM160",{"SC5","SC6"}))
	Else
		//       MaFisIni(cCodCli,SA1->A1_LOJA,'C','N',SA1->A1_TIPO,A103RelImp())
		MaFisIni(cCodCli,SA1->A1_LOJA,'C','N',SA1->A1_TIPO,MAFISRelImp("OFIOM160",{"SC5","SC6"}))
	EndIf

	//Volta estado do cliente (qdo cliente padrao)
	//if SA1->A1_TIPO <> "R" .and. VAM->VAM_ESTADO <> GETMV("MV_ESTADO")
	//	MaFisAlt("NF_CODCLIFOR",GetMv("MV_CLIPAD"))
	//	MaFisAlt("NF_LOJA",GetMv("MV_LOJAPAD"))
	//Endif

Else
	//If (SA1->A1_PESSOA == "J" .or. SA1->A1_PESSOA == "F" ) .and. !Empty(SA1->A1_INSCR) .and. VAM->VAM_ESTADO <> GETMV("MV_ESTADO")
	//	cCodCli := GetMv("MV_CLIPAD")
	//	cLoja := GetMv("MV_LOJAPAD")
	//Endif

	MaFisRef("NF_CODCLIFOR","VO300",cCodCli)
	If !Empty(cLoja)
		MaFisRef("NF_LOJA","VO300",cLoja)
	Else
		MaFisRef("NF_LOJA","VO300",SA1->A1_LOJA)
	EndIf
EndIf

if !Empty(SA1->A1_TIPPER)
	M->VS1_FORPAG := SA1->A1_COND
	cForPeri      := SA1->A1_COND
	cTipPag       := SA1->A1_COND
	if Empty(cTipPag) .and. !Empty(VO1->VO1_FORPAG)
		//		cTipPag := VO1->VO1_FORPAG
	Endif
	FS_MUDAFPG1()
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_CONCOR  ³ Autor ³ Emilton               ³ Data ³ 15/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Atualiza Conta Corrente do Produtivo                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CONCOR()

//FG_CONTCOR(VO4->VO4_CODPRO,dDataBase,0,0,0,VO4->VO4_TEMVEN,VO4->VO4_TEMCOB,aColsFEC[4,ix1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)],0,0,.t.)

return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_IMPGAR  ³ Autor ³ Emilton               ³ Data ³ 19/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Importacao da Garantia                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_IMPGAR(cTipTem)
Local cFunExp := ""
Local cFuncao, ixy
cKeyAce := cTipTem

FG_SEEK("VOI","cKeyAce",1,.f.)

If !(VOI->VOI_SITTPO $ "2/4")
	Return .t.
EndIf

FG_SEEK("VE4","VO1->VO1_CODMAR",1,.f.)

If VE4->VE4_QDOIMP != "2"
	Return .t.
EndIf

IncProc( STR0158 )//Atualizando Informacoes de Garantia
If lAbortPrint
	If MsgYesNo(OemToAnsi(STR0136),OemToAnsi(STR0133))
		Help("  ",1,"M160PROABO")
		lRetFech := .f.
		DisarmTransaction()
		Break
	Else
		lAbortPrint := .F.
	EndIf
EndIf

If FG_SEEK("VEG","VE4->VE4_FOREXP",1,.f.)

	cFuncao := Alltrim(VEG->VEG_FORMUL)

	For ixy := 1 to len(cFuncao)

		If SubStr(cFuncao,ixy,1) == "("
			cFunExp += "('F')"
			Exit
		EndIf
		cFunExp += SubStr(cFuncao,ixy,1)

	Next

	If !FG_VERFORGAR(cFunExp)            // Funcao de Importacao para Garantia
		DisarmTransaction()
		Break
	EndIf

EndIf

Return .t.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_PREVF3  ³ Autor ³ Emilton               ³ Data ³ 18/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Prepara VF3 para gravacao                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cTipVF3 - P - Peca/S - Servico                               ³±±
±±³          ³ nVlrInt - Valor da Hora Interna                              ³±±
±±³          ³ nVetSer - Vetor para controlar a duplicidade de Servicos     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_PREVF3(cTipVF3,nVlrInt,aVetSer)

Local lRetFech := .t.

If VO5->VO5_VEIACO != "1"
	return .t.
EndIf

If cTipVF3 == "P"

	If AllTrim(SBM->BM_TIPGRU) == "1" .and. VOI->VOI_SITTPO == "3"  // Lubrificantes e Tipo de Tempo Interno -> apenas acordo

		aVetVal := {}
		aAdd(aVetVal,0)                // 01 - Horas Padrao
		aAdd(aVetVal,0)                // 02 - Horas Trabalhadas
		aAdd(aVetVal,0)                // 03 - Valor de Custo das Horas Padrao
		aAdd(aVetVal,0)                // 04 - Valor de Faturado das Horas Padrao
		aAdd(aVetVal,0)                // 05 - Valor de Faturado das Horas Padrao em MF
		aAdd(aVetVal,VEC->VEC_CUSMED) // 06 - Pecas - Valor de Custo
		aAdd(aVetVal,0)                // 07 - Pecas - Valor Faturado
		aAdd(aVetVal,VEC->VEC_CMFMED) // 08 - Pecas - Valor Faturado em MF
		aAdd(aVetVal,0)                // 09 - Servico de Terceiro - Custo
		aAdd(aVetVal,0)                // 10 - Servico de Terceiro - Faturado
		aAdd(aVetVal,0)                // 11 - Servico de Terceiro - Faturado em MF

		If !FS_GRAVF3("L",dDataBase,VO5->VO5_CHAINT,cNota,cSerie,VEC->VEC_NUMOSV,.f.,VOI->VOI_SITTPO,aVetVal)
			lRetFech := .f.
		EndIf
	Else
		aVetVal := {}
		aAdd(aVetVal,0)                // 01 - Horas Padrao
		aAdd(aVetVal,0)                // 02 - Horas Trabalhadas
		aAdd(aVetVal,0)                // 03 - Valor de Custo das Horas Padrao
		aAdd(aVetVal,0)                // 04 - Valor de Faturado das Horas Padrao
		aAdd(aVetVal,0)                // 05 - Valor de Faturado das Horas Padrao em MF
		aAdd(aVetVal,VEC->VEC_CUSMED) // 06 - Pecas - Valor de Custo
		aAdd(aVetVal,VEC->VEC_VALVDA) // 07 - Pecas - Valor Faturado
		aAdd(aVetVal,VEC->VEC_VMFVDA) // 08 - Pecas - Valor Faturado em MF
		aAdd(aVetVal,0)                // 09 - Servico de Terceiro - Custo
		aAdd(aVetVal,0)                // 10 - Servico de Terceiro - Faturado
		aAdd(aVetVal,0)                // 11 - Servico de Terceiro - Faturado em MF

		If !FS_GRAVF3(FS_SITUAC("P",VEC->VEC_GRUITE,VEC->VEC_CODITE),dDataBase,VO5->VO5_CHAINT,cNota,cSerie,VEC->VEC_NUMOSV,.f.,VOI->VOI_SITTPO,aVetVal)
			lRetFech := .f.
		EndIf
	EndIf
Else
	aVetVal := {}
	aAdd(aVetVal,VSC->VSC_TEMPAD)                // 01 - Horas Padrao
	aAdd(aVetVal,VSC->VSC_TEMTRA)                // 02 - Horas Trabalhadas
	aAdd(aVetVal,VSC->VSC_TEMPAD*nVlrInt)        // 03 - Valor de Custo das Horas Padrao
	aAdd(aVetVal,VSC->VSC_VALSER)                // 04 - Valor de Faturado do Servico
	aAdd(aVetVal,VSC->VSC_VMFSER)                // 05 - Valor de Faturado do Servico em MF
	aAdd(aVetVal,0)                              // 06 - Pecas - Valor de Custo
	aAdd(aVetVal,0)                              // 07 - Pecas - Valor Faturado
	aAdd(aVetVal,0)                              // 08 - Pecas - Valor Faturado em MF
	aAdd(aVetVal,VSC->VSC_CUSSER)                // 09 - Servico de Terceiro - Custo
	aAdd(aVetVal,VSC->VSC_VALSER)                // 10 - Servico de Terceiro - Faturado
	aAdd(aVetVal,VSC->VSC_VMFSER)                // 11 - Servico de Terceiro - Faturado em MF

	Do Case
		Case VOI->VOI_TPOKLM == "1"  // Kilometragem - Acordo de Manutencao
			aVetVal[01] := 0                  // 01 - Horas Padrao
			aVetVal[02] := 0                  // 02 - Horas Trabalhadas
			aVetVal[03] := 0                  // 03 - Valor de Custo das Horas Padrao
			aVetVal[09] := 0                  // 09 - Servico de Terceiro - Custo
			aVetVal[10] := 0                  // 10 - Servico de Terceiro - Faturado
			aVetVal[11] := 0                  // 11 - Servico de Terceiro - Faturado em MF
			If !FS_GRAVF3(FS_SITUAC("S",,,VSC->VSC_CODSER),dDataBase,VO5->VO5_CHAINT,cNota,cSerie,VSC->VSC_NUMOSV,.t.,VOI->VOI_SITTPO,aVetVal)
				lRetFech := .f.
			EndIf
		Case VOK->VOK_INCMOB == "5" // Servico de Socorro
			aVetVal[01] := 0                // 01 - Horas Padrao
			aVetVal[02] := 0                // 02 - Horas Trabalhadas
			aVetVal[03] := VSC->VSC_VALSER  //03 - Valor do Custo = Valor do Servico (kilometragem de socorro nao tem custo)
			aVetVal[09] := 0                 // 09 - Servico de Terceiro - Custo
			aVetVal[10] := 0                 // 10 - Servico de Terceiro - Faturado
			aVetVal[11] := 0                 // 11 - Servico de Terceiro - Faturado em MF
			If !FS_GRAVF3(FS_SITUAC("S",,,VSC->VSC_CODSER),dDataBase,VO5->VO5_CHAINT,cNota,cSerie,VSC->VSC_NUMOSV,.f.,VOI->VOI_SITTPO,aVetVal)
				lRetFech := .f.
			EndIf
		OtherWise                       // Fabrica/Concessionaria/Informado
			ixa := aScan(aVetSer,VSC->VSC_CODSER)
			If ixa > 0
				aAdd(aVetSer,VSC->VSC_CODSER)
			EndIf
			Do Case
				Case VOK->VOK_INCMOB == "0"  // Nao Incide MOB, so exporta o custo
					aVetVal[01] := If(ixa == 0,aVetVal[01],0) // 01 - Horas Padrao
					aVetVal[03] := If(ixa == 0,aVetVal[03],0) // 03 - Valor de Custo das Horas Padrao
					aVetVal[04] := 0                            // 04 - Valor de Faturado do Servico
					aVetVal[05] := 0                            // 05 - Valor de Faturado do Servico em MF
					aVetVal[09] := 0                            // 09 - Servico de Terceiro - Custo
					aVetVal[10] := 0                            // 10 - Servico de Terceiro - Faturado
					aVetVal[11] := 0                            // 11 - Servico de Terceiro - Faturado em MF
					If !FS_GRAVF3(FS_SITUAC("S",,,VSC->VSC_CODSER),dDataBase,VO5->VO5_CHAINT,cNota,cSerie,VSC->VSC_NUMOSV,.f.,VOI->VOI_SITTPO,aVetVal)
						lRetFech := .f.
					EndIf
				Case VOK->VOK_INCMOB == "2"  // Servico de Terceiros
					aVetVal[01] := 0                // 01 - Horas Padrao
					aVetVal[02] := 0                // 02 - Horas Trabalhadas
					aVetVal[03] := 0                // 03 - Valor de Custo das Horas Padrao
					aVetVal[04] := 0                // 04 - Valor de Faturado do Servico
					aVetVal[05] := 0                // 05 - Valor de Faturado do Servico em MF
					If !FS_GRAVF3(FS_SITUAC("S",,,VSC->VSC_CODSER),dDataBase,VO5->VO5_CHAINT,cNota,cSerie,VSC->VSC_NUMOSV,.f.,VOI->VOI_SITTPO,aVetVal)
						lRetFech := .f.
					EndIf
				OtherWise
					aVetVal[01] := If(ixa == 0,aVetVal[01],0) // 01 - Horas Padrao
					aVetVal[03] := If(ixa == 0,aVetVal[03],0) // 03 - Valor de Custo das Horas Padrao
					aVetVal[09] := 0                            // 09 - Servico de Terceiro - Custo
					aVetVal[10] := 0                            // 10 - Servico de Terceiro - Faturado
					aVetVal[11] := 0                            // 11 - Servico de Terceiro - Faturado em MF
					If !FS_GRAVF3(FS_SITUAC("S",,,VSC->VSC_CODSER),dDataBase,VO5->VO5_CHAINT,cNota,cSerie,VSC->VSC_NUMOSV,.f.,VOI->VOI_SITTPO,aVetVal)
						lRetFech := .f.
					EndIf
			EndCase
	EndCase
EndIf

Return lRetFech
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GRAVF3  ³ Autor ³ Emilton               ³ Data ³ 26/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava VF3 - Posicao de Acordo de Manutencao                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                              ³±±
±±³          ³ 01- 1-Preditiva/2-Preventiva/3-Corretiva                     ³±±
±±³          ³ 02- Data do Fechamento                                       ³±±
±±³          ³ 03- Chassi Interno                                           ³±±
±±³          ³ 04- Numero da NF                                             ³±±
±±³          ³ 05- Serie da NF                                              ³±±
±±³          ³ 06- Numero da Os                                             ³±±
±±³          ³ 07- Os de Kilometragem .t. = sim                             ³±±
±±³          ³ 08- Situacao do Tempo                                        ³±±
±±³          ³     1-Publico                                                ³±±
±±³          ³     2-Garantia                                               ³±±
±±³          ³     3-Interno                                                ³±±
±±³          ³     4-Revisao                                                ³±±
±±³          ³ 09- Vetor de Tempos e Valores                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAVF3(cSituac,dDatFec,cChaInt,cNumNFi,cSerNFi,cNumOSv,lOSvKil,cSitTpo,aVetVal)

If VO5->VO5_VEIACO != "1"
	return .t.
EndIf
cKeyAce := cNumOSv
FG_SEEK("VO1","cKeyAce",1,.f.)

If FG_SEEK("VF3","cKeyAce",1,.f.)

	If !RecLock("VF3",.f.)
		Return .f.
	EndIf

Else

	If !RecLock("VF3",.t.)
		Return .f.
	EndIf

	VF3->VF3_FILIAL := xFilial("VF3")
	VF3->VF3_DATPOS := dDatFec
	VF3->VF3_CHAINT := cChaint
	VF3->VF3_NUMNFI := cNumNFi
	VF3->VF3_SERNFI := cSerNFi
	VF3->VF3_NUMOSV := cNumOsv
	VF3->VF3_KILOME := VO1->VO1_KILOME

EndIf

Do Case
	Case cSitTpo == "1"  // Publico

		If lOSvKil  // Kilometragem

			VF3->VF3_VLRCNF += aVetVal[04]
			VF3->VF3_VLRCMF += aVetVal[05]

		Else

			VF3->VF3_HPDCLI += aVetVal[01]  // Horas Padrao
			VF3->VF3_HTRCLI += aVetVal[02]  // Horas Trabalhadas
			VF3->VF3_CLICUS += aVetVal[03]  // Valor de Custo das Horas Padrao
			VF3->VF3_CLI_NF += aVetVal[04]  // Valor Faturado das Horas Padrao
			VF3->VF3_CLI_MF += aVetVal[05]  // Valor Faturado das Horas Padrao em MF
			VF3->VF3_PCUCLI += aVetVal[06]  // Pecas - Valor de Custo
			VF3->VF3_PNFCLI += aVetVal[07]  // Pecas - Valor Faturado
			VF3->VF3_PMFCLI += aVetVal[08]  // Pecas - Valor Faturado em MF
			VF3->VF3_3CUCLI += aVetVal[09]  // Servico de Terceiro - Custo
			VF3->VF3_3NFCLI += aVetVal[10]  // Servico de Terceiro - Faturado
			VF3->VF3_3MFCLI += aVetVal[11]  // Servico de Terceiro - Faturado em MF

		EndIf

	Case cSitTpo == "3"  // Interno

		Do Case
			Case cSituac == "1"   // Preditiva

				VF3->VF3_HPDPRD += aVetVal[01]  // Horas Padrao
				VF3->VF3_HTRPRD += aVetVal[02]  // Horas Trabalhadas
				VF3->VF3_PRDCUS += aVetVal[03]  // Valor de Custo das Horas Padrao
				VF3->VF3_PRD_NF += aVetVal[04]  // Valor Faturado das Horas Padrao
				VF3->VF3_PRD_MF += aVetVal[05]  // Valor Faturado das Horas Padrao em MF
				VF3->VF3_PCUPRD += aVetVal[06]  // Pecas - Valor de Custo
				VF3->VF3_PNFPRD += aVetVal[07]  // Pecas - Valor Faturado
				VF3->VF3_PMFPRD += aVetVal[08]  // Pecas - Valor Faturado em MF
				//VF3->VF3_3CUPRD += aVetVal[09]  // Servico de Terceiro - Custo
				//VF3->VF3_3NFPRD += aVetVal[10]  // Servico de Terceiro - Faturado
				//VF3->VF3_3MFPRD += aVetVal[11]  // Servico de Terceiro - Faturado em MF

			Case cSituac == "2"   // Preventiva

				VF3->VF3_HPDPRV += aVetVal[01]  // Horas Padrao
				VF3->VF3_HTRPRV += aVetVal[02]  // Horas Trabalhadas
				VF3->VF3_PRVCUS += aVetVal[03]  // Valor de Custo das Horas Padrao
				VF3->VF3_PRV_NF += aVetVal[04]  // Valor Faturado das Horas Padrao
				VF3->VF3_PRV_MF += aVetVal[05]  // Valor Faturado das Horas Padrao em MF
				VF3->VF3_PCUPRV += aVetVal[06]  // Pecas - Valor de Custo
				VF3->VF3_PNFPRV += aVetVal[07]  // Pecas - Valor Faturado
				VF3->VF3_PMFPRV += aVetVal[08]  // Pecas - Valor Faturado em MF
				//VF3->VF3_3CUPRV += aVetVal[09]  // Servico de Terceiro - Custo
				//VF3->VF3_3NFPRV += aVetVal[10]  // Servico de Terceiro - Faturado
				//VF3->VF3_3MFPRV += aVetVal[11]  // Servico de Terceiro - Faturado em MF

			Case cSituac == "3"   // Corretiva

				VF3->VF3_HPDCOR += aVetVal[01]  // Horas Padrao
				VF3->VF3_HTRCOR += aVetVal[02]  // Horas Trabalhadas
				VF3->VF3_CORCUS += aVetVal[03]  // Valor de Custo das Horas Padrao
				VF3->VF3_COR_NF += aVetVal[04]  // Valor Faturado das Horas Padrao
				VF3->VF3_COR_MF += aVetVal[05]  // Valor Faturado das Horas Padrao em MF
				VF3->VF3_PCUCOR += aVetVal[06]  // Pecas - Valor de Custo
				VF3->VF3_PNFCOR += aVetVal[07]  // Pecas - Valor Faturado
				VF3->VF3_PMFCOR += aVetVal[08]  // Pecas - Valor Faturado em MF
				//VF3->VF3_3CUCOR += aVetVal[09]  // Servico de Terceiro - Custo
				//VF3->VF3_3NFCOR += aVetVal[10]  // Servico de Terceiro - Faturado
				//VF3->VF3_3MFCOR += aVetVal[11]  // Servico de Terceiro - Faturado em MF

			Case cSituac == "R"   // Servico de Terceiros

				VF3->VF3_S3RCUS += aVetVal[03]  // Custo do Servico de Terceiro
				VF3->VF3_S3R_MF += aVetVal[05]  // Custo do Servico de Terceiro MF

			Case cSituac == "S"   // Socorro

				VF3->VF3_SRSCCU += aVetVal[03]  // Servico de Socorro
				VF3->VF3_SRSCMF += aVetVal[05]  // Servico de Socorro MF

			Case cSituac == "L"   // Lubrificantes

				VF3->VF3_LUBCUS += aVetVal[06]  // Pecas - Valor de Custo
				VF3->VF3_LUB_NF += aVetVal[07]  // Pecas - Valor Faturado
				VF3->VF3_LUB_MF += aVetVal[08]  // Pecas - Valor Faturado em MF

		EndCase

	Case cSitTpo $  "2/4" // Garantia ou Revisao

		VF3->VF3_HPDGAR += aVetVal[01]  // Horas Padrao
		VF3->VF3_HTRGAR += aVetVal[02]  // Horas Trabalhadas
		VF3->VF3_GARCUS += aVetVal[03]  // Valor de Custo das Horas Padrao
		VF3->VF3_GAR_NF += aVetVal[04]  // Valor Faturado das Horas Padrao
		VF3->VF3_GAR_MF += aVetVal[05]  // Valor Faturado das Horas Padrao em MF
		VF3->VF3_PCUGAR += aVetVal[06]  // Pecas - Valor de Custo
		VF3->VF3_PNFGAR += aVetVal[07]  // Pecas - Valor Faturado
		VF3->VF3_PMFGAR += aVetVal[08]  // Pecas - Valor Faturado em MF
		VF3->VF3_3CUGAR += aVetVal[09]  // Servico de Terceiro - Custo
		VF3->VF3_3NFGAR += aVetVal[10]  // Servico de Terceiro - Faturado
		VF3->VF3_3MFGAR += aVetVal[11]  // Servico de Terceiro - Faturado em MF

EndCase

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SITUAC  ³ Autor ³ Emilton               ³ Data ³ 27/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Situacao (1-Preditiva/2-Preventiva/3-Corretiva)              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cIndOpe - P-Pecas/S-Servicos                                 ³±±
±±³          ³ cGruIte - Grupo do Item                                      ³±±
±±³          ³ cCodIte - Codigo do Item                                     ³±±
±±³          ³ cCodSer - Codigo do Servico                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SITUAC(cIndOpe,cGruite,cCodIte,cCodSer)
************************************************

Local cSituac := "3"

If cIndOpe == "P"

	cKeyAce := VV1->VV1_CODMAR+VV1->VV1_MODVEI+cGruite+cCodIte

	If FG_SEEK("VO8","cKeyAce",4,.f.)

		while VO8->VO8_CODMAR+VO8->VO8_MODVEI+VO8->VO8_GRUITE+VO8->VO8_CODITE == cKeyAce .and. VO8->VO8_FILIAL == xFilial("VO8") .and. VO8->(!eof())

			If aScan(aColsFEC[4],{ |x| x[FS_POSVAR("VO4_CODSER","aHeaderFEC",4)] == VO8->VO8_CODSER } ) > 0
				cSituac := "2"
			EndIf
			VO8->(dbSkip())

		EndDo

	EndIf

Else

EndIf

Return cSituac

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SAIVEI  ³ Autor ³ Emilton               ³ Data ³ 02/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Registra a Saida do Veiculo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_SAIVEI(cParam01)
***********************************
return .t.
/*
Do Case
Case cParam01 == 1

If Empty(VO1->VO1_DATSAI)
If MsgYesNo(OemToAnsi("Registra a saida do veiculo Mod. "+VV2->VV2_DESMOD+" Placa "+VV1->VV1_PLAVEI+" Cod.Frt. "+VV1->VV1_CODFRO+" da OS "+VO1->VO1_NUMOSV+" ?"),OemToAnsi("Atencao !!"))
dbSelectArea("VO1")

If !RecLock("VO1",.f.)
Help("  ",1,"REGNLOCK")
lRetFech := .f.
DisarmTransaction()
Break
EndIf

VO1->VO1_DATSAI := dDataBase
VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
MsUnlock()
EndIf
EndIf

Case cParam01 == 2

If Empty(VO1->VO1_DATSAI)
If MsgYesNo(OemToAnsi("Registra a saida do veiculo Mod. "+VV2->VV2_DESMOD+" Placa "+VV1->VV1_PLAVEI+" Cod.Frt. "+VV1->VV1_CODFRO+" da OS "+VO1->VO1_NUMOSV+" ?"),OemToAnsi("Atencao !!"))
dbSelectArea("VO1")

If !RecLock("VO1",.f.)
Help("  ",1,"REGNLOCK")
lRetFech := .f.
DisarmTransaction()
Break
EndIf

VO1->VO1_DATSAI := dDataBase
VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
MsUnlock()
EndIf
EndIf

Case cParam01 == 3

If Empty(VO1->VO1_DATSAI)
If MsgYesNo(OemToAnsi("Registra a saida do veiculo Mod. "+VV2->VV2_DESMOD+" Placa "+VV1->VV1_PLAVEI+" Cod.Frt. "+VV1->VV1_CODFRO+" da OS "+VO1->VO1_NUMOSV+" ?"),OemToAnsi("Atencao !!"))
dbSelectArea("VO1")

If !RecLock("VO1",.f.)
Help("  ",1,"REGNLOCK")
lRetFech := .f.
DisarmTransaction()
Break
EndIf

VO1->VO1_DATSAI := dDataBase
VO1->VO1_HORSAI := val(left(time(),2)+substr(time(),4,2))
MsUnlock()
EndIf
EndIf

EndCase

Return .t.
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_OCHKLIBºAutor  ³Andre               º Data ³  11/08/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Libera a Venda                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OCHKLIB()

Local lRetFech := .t.
//Local lAuxRetFech := .t.
Local cAliasVS6 := "TVS6"

Local lDesPerPec := .f. // Desconto permitido de Pecas
Local lDesPerSer := .f. // Desconto permitido de Servicos

Local lVerifPec := .f.
Local lVerifSer := .f.

Private lAltDel   := .f.
Private lLiberado := .f.	// Venda Liberada ???
Private lDesPer   := .t.	// Desconto Permitido ???
/*
DbSelectArea("VS6")
DbSetOrder(2)
If DbSeek(xFilial("VS6")+Iif(cParam01==1,"Ind-",Iif(cParam01==2,"Agr-","Qui-"))+VO1->VO1_NUMOSV)
if VS6->(FieldPos("VS6_TIPTEM")) > 0
while !eof() .and. xFilial("VS6")+Iif(cParam01==1,"Ind-",Iif(cParam01==2,"Agr-","Qui-"))+VO1->VO1_NUMOSV == VS6_FILIAL+VS6_DOC
if VS6->VS6_TIPTEM == VOI->VOI_TIPTEM
cNumLib := VS6->VS6_NUMIDE
endif
DBSkip()
enddo
else
cNumLib := VS6->VS6_NUMIDE
endif
Endif
*/

// Fechamento por Quilometragem
If cParam01 == 3

	DbSelectArea("VS6")
	DbSetOrder(2)
	If DbSeek(xFilial("VS6") + "Qui-" + VO1->VO1_NUMOSV)
		if VS6->(FieldPos("VS6_TIPTEM")) > 0
			while !eof() .and. xFilial("VS6") + "Qui-" + VO1->VO1_NUMOSV == VS6_FILIAL + VS6_DOC
				if VS6->VS6_TIPTEM == VOI->VOI_TIPTEM
					cNumLib := VS6->VS6_NUMIDE
				endif
				DBSkip()
			enddo
		else
			cNumLib := VS6->VS6_NUMIDE
		endif
	Endif

Else

	// Verifica Descontos ...
	FS_VRFDSC( @lDesPerPec, @lDesPerSer)

	cSQL := "SELECT VS6.VS6_NUMIDE"
	cSQL +=  " FROM " + RetSQLName("VS6") + " VS6"
	cSQL += " WHERE VS6.VS6_FILIAL = '" + xFilial("VS6") + "'"
	cSQL +=   " AND VS6.VS6_DOC = '" + Iif(cParam01==1,"Ind-","Agr-") + VO1->VO1_NUMOSV + "'"
	If VS6->(FieldPos("VS6_TIPTEM")) > 0
		cSQL +=   " AND VS6.VS6_TIPTEM = '" + VOI->VOI_TIPTEM + "'"
	EndIf
	cSQL +=   " AND VS6.D_E_L_E_T_ = ' '"
	cSQL += " ORDER BY VS6.VS6_NUMIDE"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cSQL ), cAliasVS6 , .F., .T. )
	If (cAliasVS6)->(Eof())
		cNumLib := ""
		If !FS_OPRCLIB( cNumLib , lDesPerPec, lDesPerSer)
			lRetFech := .f.
		EndIf
	Else
		While !(cAliasVS6)->(Eof())

			cNumLib := (cAliasVS6)->VS6_NUMIDE

			lDesPer := .t.

			nDesPec := FM_SQL("SELECT SUM(VS7_VALDES) FROM " + RetSQLName("VS7") + " VS7 WHERE VS7_FILIAL = '" + xFilial("VS7") + "' AND VS7_NUMIDE = '" + cNumLib + "' AND VS7_TIPAUT = '1' AND VS7.D_E_L_E_T_ = ' '")
			nDesSer := FM_SQL("SELECT SUM(VS7_VALDES) FROM " + RetSQLName("VS7") + " VS7 WHERE VS7_FILIAL = '" + xFilial("VS7") + "' AND VS7_NUMIDE = '" + cNumLib + "' AND VS7_TIPAUT = '2' AND VS7.D_E_L_E_T_ = ' '")

			If nDesPec <> 0
				lVerifPec := .t.
				If lDesPer .and. !lDesPerPec
					lDesPer := .f.
				EndIf
			EndIf

			If nDesSer <> 0
				lVerifSer := .t.
				If lDesPer .and. !lDesPerSer
					lDesPer := .f.
				EndIf
			EndIf

			If !FS_OPRCLIB( cNumLib , lDesPerPec, lDesPerSer)
				lRetFech := .f.
			EndIf
			(cAliasVS6)->(dbSkip())
		End

		// Se o Desconto de Peca nao for permitido e foi analisado a liberacao de Desconto marca como Permitido
		If !lDesPerPec .and. lVerifPec
			lDesPerPec := .t.
		EndIf

		// Se o Desconto de Servico nao for permitido e foi analisado a liberacao de Desconto marca como Permitido
		If !lDesPerSer .and. lVerifSer
			lDesPerSer := .t.
		EndIf

		// Se nao foi analisado desconto de peca ou desconto de servico e
		// os mesmos nao forem permitidos, chamar funcao para gerar liberacao
		If !lDesPerPec .or. !lDesPerSer
			cNumLib := ""
			lDesPer := .f.
			If !FS_OPRCLIB( cNumLib , lDesPerPec, lDesPerSer)
				lRetFech := .f.
			EndIf
		EndIf

	EndIf
	(cAliasVS6)->(dbCloseArea())
	dbSelectArea("VS6")
EndIf

Return lRetFech

Static Function FS_OPRCLIB( cNumLib , lDesPerPec, lDesPerSer )

Local ixv
Local lRetFech:= .T.
Local nDesPec := 0	// Total Desejado de Pecas
Local nDesSer := 0	// Total Desejado de Servicos

Local lGeraSep := (GetNewPar("MV_GLIBVEN","N") == "S")

If !Empty(cNumLib)

	DbSelectArea("VS6")
	DbSetOrder(1)
	If DbSeek(xFilial("VS6")+cNumLib)
		dbSelectArea("VS7")
		dbSetOrder(1)
		If dbSeek(xFilial("VS7")+cNumLib)

			If lDesper == .t.
				Help(" ",1,"M160DELVS6")   // Os Descontos aplicados foram corrigidos e o pedido de liberacao de venda sera eliminado
				lAltDel := .t.

				FS_APAGALIB()

				lRetFech := .t.

			Else

				nDesPec := FM_SQL("SELECT SUM(VS7_VALDES) FROM " + RetSQLName("VS7") + " VS7 WHERE VS7_FILIAL = '" + xFilial("VS7") + "' AND VS7_NUMIDE = '" + cNumLib + "' AND VS7_TIPAUT = '1' AND VS7.D_E_L_E_T_ = ' '")
				nDesSer := FM_SQL("SELECT SUM(VS7_VALDES) FROM " + RetSQLName("VS7") + " VS7 WHERE VS7_FILIAL = '" + xFilial("VS7") + "' AND VS7_NUMIDE = '" + cNumLib + "' AND VS7_TIPAUT = '2' AND VS7.D_E_L_E_T_ = ' '")

				If !lGeraSep
					If nDesPec <> nTotPec .or. nDesSer <> nTotSrv
						lAltDel := .t.
					EndIf
				Else
					If ( nDesPec <> 0 .and. nDesPec <> nTotPec ) .or. ( nDesSer <> 0 .and. nDesSer <> nTotSrv )
						lAltDel := .t.
					EndIf
				EndIf

				If lAltDel

					Help(" ",1,"M160ALTVS6")   // Os Descontos aplicados ainda continuam acima do permitido, o sistema alterara o pedido de liberacao de venda para os novos valores
					lAltDel := .t.
					dbSelectArea("VS6")
					RecLock("VS6",.f.)
					VS6->VS6_DATOCO := dDataBase
					VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
					VS6->VS6_DATAUT := ctod("00/00/00")
					VS6->VS6_LIBPRO := ""
					VS6->VS6_HORAUT := 0
					MsUnlock()

					DbSelectArea("VS7")
					For ixv := 1 to Len(aColsFEC[2])

						IF dbSeek(xFilial("VS7")+cNumLib+StrZero(ixv,4)+"1")
							RecLock("VS7",.f.)
							VS7->VS7_DESDES := aColsFEC[2,ixv,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
							VS7->VS7_VALDES := aColsFEC[2,ixv,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
							MsUnlock()
						endif

					Next

					For ixv := 1 to Len(aColsFEC[4])

						If empty(aColsFEC[4,ixv,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)])
							loop
						EndIf
						if dbSeek(xFilial("VS7")+cNumLib+StrZero(ixv,4)+"2")
							RecLock("VS7",.f.)
							VS7->VS7_DESDES := aColsFEC[4,ixv,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
							VS7->VS7_VALDES := aColsFEC[4,ixv,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
							MsUnlock()
						endif

					Next

				EndIf

				dbSelectArea("VS6")

			Endif

		EndIf

		If lAltDel == .f.
			VS6->(DbSetOrder(1))
			VS6->(DbSeek(xFilial("VS6")+cNumLib))

			nDesPec := FM_SQL("SELECT SUM(VS7_VALDES) FROM " + RetSQLName("VS7") + " VS7 WHERE VS7_FILIAL = '" + xFilial("VS7") + "' AND VS7_NUMIDE = '" + cNumLib + "' AND VS7_TIPAUT = '1' AND VS7.D_E_L_E_T_ = ' '")
			nDesSer := FM_SQL("SELECT SUM(VS7_VALDES) FROM " + RetSQLName("VS7") + " VS7 WHERE VS7_FILIAL = '" + xFilial("VS7") + "' AND VS7_NUMIDE = '" + cNumLib + "' AND VS7_TIPAUT = '2' AND VS7.D_E_L_E_T_ = ' '")

			If Empty(VS6->VS6_DATAUT)
				If !lGeraSep
					MsgInfo(OemToAnsi(STR0137),OemToAnsi(STR0133))       //"Venda ainda nao Liberada...","Atencao!")
				Else
					If nDesPec <> 0
						MsgInfo(STR0137 + chr(13) + chr(13) + STR0190, STR0133)       //"Venda ainda nao Liberada...","Atencao!")
					EndIf
					If nDesSer <> 0
						MsgInfo(STR0137 + chr(13) + chr(13) + STR0191, STR0133)       //"Venda ainda nao Liberada...","Atencao!")
					EndIf
				EndIf
				Return .f.
			Else
				If !lGeraSep
					MsgInfo(OemToAnsi(STR0138),OemToAnsi(STR0139))    //"Venda Liberada...","Ok"
				Else
					If nDesPec <> 0
						MsgInfo(STR0138 + chr(13) + chr(13) + STR0190,STR0139)    //"Venda Liberada...","Ok"
					EndIf
					If nDesSer <> 0
						MsgInfo(STR0138 + chr(13) + chr(13) + STR0191,STR0139)    //"Venda Liberada...","Ok"
					EndIf
				EndIf
				lDesPer   := .t.
				lLiberado := .t.
			EndIf
		EndIf
	EndIf
EndIf

If !lDesPer
	// Se tiver vazio, gera uma Liberacao nova ...
	If Empty(cNumLib)
		FS_LIBVENDA( lDesPerPec, lDesPerSer )
	EndIf
	//
	lRetFech := .f.
EndIf
Return(lRetFech)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_VRFDSC ³ Autor ³ Emilton               ³ Data ³ 08/11/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Verifica Descontos                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VRFDSC( lDesPerPec, lDesPerSer)

Local lRetFech := .t.
Local ixx := 0

lDesPerPec := .t.
lDesPerSer := .t.

cKeyAce := __cUserID
FG_SEEK("VAI","cKeyAce",4,.f.)

// Pecas
For ixx := 1 to len(aColsFEC[2])
	M->VO3_GRUITE := aColsFEC[2,ixx,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
	M->VO3_CODITE := aColsFEC[2,ixx,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
	M->VO3_QTDREQ := aColsFEC[2,ixx,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
	M->VO3_PERDES := aColsFEC[2,ixx,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
	if Empty(M->VO3_GRUITE)
		Loop
	Endif
	SBM->(dbSetOrder(1))
	SBM->(dbSeek(xFilial("SBM")+M->VO3_GRUITE))
	if !FG_PERDES(SBM->BM_CODMAR,VAI->VAI_CC,"P",M->VO3_GRUITE,M->VO3_CODITE,M->VO3_QTDREQ,M->VO3_PERDES,.f.,VV1->VV1_MODVEI)
		lDesPer  := .f.
		lRetFech := .f.
		lDesPerPec := .f.
	Endif
Next

//Servicos
For ixx := 1 to len(aColsFEC[4])
	M->VO4_TIPSER := aColsFEC[4,ixx,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
	M->VO4_PERDES := aColsFEC[4,ixx,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
	if Empty(M->VO4_TIPSER)
		Loop
	Endif
	if !FG_PERDES(,,"S",M->VO4_TIPSER,,,M->VO4_PERDES,.f.)
		lDesPer  := .f.
		lRetFech := .f.
		lDesPerSer := .f.
	Endif
Next

Return(lRetFech)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VLIBVEN ³ Autor ³ Takahashi           ³ Data ³ 26/01/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a Autorizado o Pedido de Liberacao de Venda    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_VLIBVEN()

// Salva negociacao antes de verificar se a venda esta liberada ...
lSalvou := .F.
If !FS_SALVA()
	Return .f.
EndIf
//

// Chama rotina de verificacao de Descontos
FS_OCHKLIB()
//

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LIBVENDA  ³ Autor ³ ANDRE                 ³ Data ³ 01/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Liberacao de Venda com descontos acima do Permitido         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lDesPerPec = Desconto Permitido de Pecas                   ³±±
±±³          ³ lDesPerSer = Desconto Permitido de Servicos                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LIBVENDA( lDesPerPec, lDesPerSer )

Local aMemSlv
Local ixa := 0

Local lGeraSep := (GetNewPar("MV_GLIBVEN","N") == "S")

Default lDesPerPec := .f.
Default lDesPerSer := .f.

If MsgYesNo(OemToAnsi(STR0140),OemToAnsi(STR0133))

	aMemSlv := aClone(aMemos)
	PRIVATE aMemos  := {{"VS6_OBSMEM","VS6_OBSERV"}}
	PRIVATE oFonte  := TFont():New( "Arial", 6, 12 )

	//	cObserv := MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1])
	cObserv := ""

	DEFINE MSDIALOG oDlg1 TITLE OemtoAnsi(STR0141) FROM  02,04 TO 14,56 OF oMainWnd

	DEFINE SBUTTON FROM 076,137 TYPE 1 ACTION (oDlg1:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 076,168 TYPE 2 ACTION (oDlg1:End()) ENABLE OF oDlg1

	@ 01,011 GET oObserv VAR cObserv OF oDlg1 MEMO SIZE 182,67 PIXEL
	oObserv:oFont := oFonte
	oObserv:bRClicked := {|| AllwaysTrue() }
	oObserv:SetFocus()

	ACTIVATE MSDIALOG oDlg1 CENTER

	cNumLib := ""

	If !lDesPerPec .OR. !lGeraSep
		DbSelectArea("VS7")
		For ixa := 1 to Len(aColsFEC[2])

			If !empty(aColsFEC[2,ixa,1])

				If Empty(cNumLib)
					// Grava Cabecalho da Liberacao de Venda
					FS_GCABLIB(cObserv)
				EndIf

				If !RecLock("VS7",.t.)
					Help("  ",1,"REGNLOCK")
					lRetFech := .f.
					DisarmTransaction()
					Break
				EndIf

				VS7->VS7_FILIAL := xFilial("VS7")
				VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
				VS7->VS7_SEQUEN := Strzero(ixa,4)
				VS7->VS7_TIPAUT := "1"
				VS7->VS7_GRUITE := aColsFEC[2,ixa,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
				VS7->VS7_CODITE := aColsFEC[2,ixa,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]

				//Atribui a variavel "nDesPer" o Desconto Permitido
				SBM->(dbSetOrder(1))
				SBM->(dbSeek(xFilial("SBM")+aColsFEC[2,ixa,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]))
				//				FG_PERDES(SBM->BM_CODMAR,VAI->VAI_CC,"P",aColsFEC[2,ixa,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)],aColsFEC[2,ixa,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)],aColsFEC[2,ixa,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],(100 - ((aColsFEC[2,ixa,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] * 100) / aColsFEC[2,ixa,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])),.f.,VV1->VV1_MODVEI)
				aRetDes := OX005PERDES(SBM->BM_CODMAR,VAI->VAI_CC,aColsFEC[2,ixa,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)],aColsFEC[2,ixa,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)],aColsFEC[2,ixa,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],(100 - ((aColsFEC[2,ixa,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] * 100) / aColsFEC[2,ixa,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])),.t.,SA1->A1_COD,SA1->A1_LOJA," ",aColsFEC[2,ixa,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]/aColsFEC[2,ixa,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)],3)
				dbSelectArea("VS7")
				VS7->VS7_DESPER := nDesPer := aRetDes[2]
				VS7->VS7_MARPER := aRetDes[3]

				VS7->VS7_DESDES := aColsFEC[2,ixa,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
				VS7->VS7_VALORI := aColsFEC[2,ixa,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
				VS7->VS7_VALPER := aColsFEC[2,ixa,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]*(1-(nDesPer/100))
				VS7->VS7_VALDES := aColsFEC[2,ixa,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
				MsUnlock()

			EndIf

		Next
	EndIf

	If lGeraSep
		cNumLib := ""
	EndIf

	If !lDesPerSer .OR. !lGeraSep
		For ixa := 1 to Len(aColsFEC[4])

			If !empty(aColsFEC[4,ixa,1])

				If Empty(cNumLib)
					// Grava Cabecalho da Liberacao de Venda
					FS_GCABLIB(cObserv)
				EndIf

				If !RecLock("VS7",.t.)
					Help("  ",1,"REGNLOCK")
					lRetFech := .f.
					DisarmTransaction()
					Break
				EndIf

				VS7->VS7_FILIAL := xFilial("VS7")
				VS7->VS7_NUMIDE := VS6->VS6_NUMIDE
				VS7->VS7_SEQUEN := Strzero(ixa,4)
				VS7->VS7_TIPAUT := "2"
				VS7->VS7_GRUSER := aColsFEC[4,ixa,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
				VS7->VS7_CODSER := aColsFEC[4,ixa,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
				VS7->VS7_TIPSER := aColsFEC[4,ixa,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
				cKeyAce := aColsFEC[4,ixa,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]

				If FG_SEEK("VOK","cKeyAce",1,.f.)
					VS7->VS7_DESPER := VOK->VOK_PERMAX
				Endif

				VS7->VS7_DESDES := aColsFEC[4,ixa,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
				VS7->VS7_VALORI := aColsFEC[4,ixa,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
				VS7->VS7_VALPER := aColsFEC[4,ixa,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]*If(VOK->VOK_PERMAX >0,(1-(VOK->VOK_PERMAX/100)),1)
				VS7->VS7_VALDES := aColsFEC[4,ixa,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
				MsUnlock()

			EndIf

		Next
	Endif

	FS_GRAAVA(VS6->VS6_NUMIDE)

Endif

Return

Static Function FS_GCABLIB(cObserv)

DbSelectArea("VS6")
If !RecLock("VS6",.t.)
	Help("  ",1,"REGNLOCK")
	lRetFech := .f.
EndIf

VS6->VS6_FILIAL := xFilial("VS6")
VS6->VS6_NUMIDE := GetSxENum("VS6","VS6_NUMIDE")
VS6->VS6_DATOCO := dDataBase
VS6->VS6_HOROCO := val(substr(time(),1,2)+substr(time(),4,2))
VS6->VS6_NUMORC := ""
if VS6->(FieldPos("VS6_TIPTEM")) > 0
	VS6->VS6_TIPTEM := VOO->VOO_TIPTEM
EndIf
VS6->VS6_TIPOCO := "000008"
VS6->VS6_DESOCO := STR0142
VS6->VS6_USUARI := substr(cUsuario,7,15)
VS6->VS6_TIPAUT := "2"
VS6->VS6_CODCLI := SA1->A1_COD
VS6->VS6_LOJA   := SA1->A1_LOJA
cNumLib := VS6->VS6_NUMIDE
VS6->VS6_DOC := Iif(cParam01==1,"Ind-",Iif(cParam01==2,"Agr-","Qui-"))+VO1->VO1_NUMOSV
VS6->VS6_FORPAG := cTipPag

MSMM(VS6->VS6_OBSMEM,TamSx3("VS6_OBSERV")[1],,cObserv,1,,,"VS6","VS6_OBSMEM")
ConfirmSx8()
MsUnlock()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_RATCDCI ³ Autor ³ Emilton               ³ Data ³ 22/08/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Realiza rateio de descontos qdo forma de pagamento for CDCI  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico deste programa                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_RATCDCI(nValorCom,aParcelas,nDesconto)

Local i,y,ixu
Local nPerIte  := 0
Local nPerSrv  := 0
Local nValDesc := 0

Local nPerPec  := 0
//Local nPerSrv  := 0
Local nVlrPec  := 0
Local nVlrSrv  := 0
Local nValorX  := 0
Local nValorY  := 0
Local nValorZ  := 0
Local nTotDesR := nTotDes
Local nTotTTpR := nTotTTp
Local nTotPecR := nTotPec
Local nTotSrvR := nTotSrv
Local x := 0

If nTotTTp+M->VSF_DESACE == nValorCom .or. nValorCom == 0
	Return .t.
EndIf

If lFlgVet
	lFlgVet  := .f.
	aColsBKP := aClone(aColsFEC)
	nTotDesA := nTotDes
	nTotTTpA := nTotTTp
	nTotPecA := nTotPec
	nTotSrvA := nTotSrv
Else
	aColsFEC := aClone(aColsBKP)
	nTotDes := nTotDesA
	nTotTTp := nTotTTpA
	nTotPec := nTotPecA
	nTotSrv := nTotSrvA

	nTotDesR := nTotDes
	nTotTTpR := nTotTTp
	nTotPecR := nTotPec
	nTotSrvR := nTotSrv
EndIf
If len(aColsFec) > 1 .and. len(aColsBKP) > 1
	aColsFEC[2] := aClone(aColsBKP[2])
EndIf
nPerPec     := nTotPec/(nTotTTp+M->VSF_DESACE)
nPerSrv     := nTotSrv/(nTotTTp+M->VSF_DESACE)
nDescP      := nDesconto * nPerPec
nDescS      := nDesconto * nPerSrv
nVlrPec     := (nTotPec - nDescP) * nPerPec
nVlrSrv     := (nTotSrv - nDescS) * nPerSrv

nTotDes := 0
nTotTTp := 0
nTotPec := 0
nTotSrv := 0

if Len(aColsBKP[2]) = 0
	aColsBKP[2] := aClone(aColsFEC[2])
	aColsBKP[4] := aClone(aColsFEC[4])
Else
	aColsFEC[2]   := aClone(aColsBKP[2])
	aColsFEC[4]   := aClone(aColsBKP[4])
Endif

aCols      := aClone(aColsFEC[2])
aHeader    := aCLone(aHeaderFEC[2])

nValRestoP := nDesconto * nPerPec
nValRestoS := nDesconto * nPerSrv

if nDesconto > 0

	// Pecas

	nMaiorValor :=0
	For ixu:=1 to Len(aColsFEC[2])
		/*
		cGruIte := aColsFEC[2,ixu,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
		cCodIte := aColsFEC[2,ixu,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
		DbSelectArea("SB1")
		DbSetOrder(7)
		DbSeek(xFilial("SB1")+cGruIte+cCodIte)
		if !TipoTes(SB1->B1_TS)
		Loop
		Endif
		*/
		n := ixu

		M->VO3_VALPEC := aColsFEC[2,ixu,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)]
		M->VO3_QTDREQ := aColsFEC[2,ixu,FS_POSVAR("VO3_QTDREQ","aHeaderFEC",2)]
		M->VO3_VALTOT := aColsFEC[2,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

		nPerIte  := (M->VO3_VALTOT / nVlrPec) * 100
		nValDesc := (nDescP / 100) * nPerIte

		if nValRestoP = 0
			nValDesc := 0
		Elseif nValRestoP < nValDesc
			nValDesc  := nValRestoP
			nValRestoP := 0
		Endif

		aColsFEC[2,ixu,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] += nValDesc
		M->VO3_VALDES := aColsFEC[2,ixu,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
		aColsFEC[2,ixu,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := (M->VO3_VALDES / (M->VO3_VALPEC * M->VO3_QTDREQ)) * 100
		aColsFEC[2,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := (M->VO3_VALPEC * M->VO3_QTDREQ ) - M->VO3_VALDES

		if nValRestoP > 0
			nValRestoP -= nValDesc
			if aColsFEC[2,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] > nMaiorValor
				nMaiorValor := aColsFEC[2,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
				y := i
			Endif
		Endif

		nTotDes += aColsFEC[2,ixu,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
		nTotPec += aColsFEC[2,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
		nTotTTp += aColsFEC[2,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

		MaFisRef("IT_DESCONTO","VS300",M->VO3_VALDES)

	Next

	For ixu := 1 to len(aColsFEC[1])
		aColsFEC[1,ixu,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] := 0
		aColsFEC[1,ixu,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := 0
		aColsFEC[1,ixu,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := 0
		aColsFEC[1,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := 0
	Next

	FS_TTPECA("CDCI")

	nValorZ := 0
	For ixu := 1 to len(aColsFEC[1])
		aColsFEC[1,ixu,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := 100 - ((aColsFEC[1,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] / aColsFEC[1,ixu,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]) * 100)
		nValorZ += aColsFEC[1,ixu,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
	Next

	If nVlrPec != nValorZ
		Do Case
			Case nValorZ > nVlrPec
				nValorZ := nValorZ - nVlrPec
				aColsFEC[1,1,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] += nValorZ
				aColsFEC[1,1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] -= nValorZ
				aColsFEC[1,1,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := 100 - ((aColsFEC[1,1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] / aColsFEC[1,1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]) * 100)
			Case nValorZ < nVlrPec
				nValorZ := nVlrPec - nValorZ
				aColsFEC[1,1,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] -= nValorZ
				aColsFEC[1,1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] += nValorZ
				aColsFEC[1,1,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := 100 - ((aColsFEC[1,1,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] / aColsFEC[1,1,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]) * 100)
		EndCase
	EndIf


	// Servicos

	nMaiorValor :=0
	For ixu:=1 to Len(aColsFEC[4])
		n := ixu

		M->VO4_VALTOT := aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]

		nPerSrv  := (M->VO4_VALTOT / nVlrSrv) * 100
		nValDesc := (nDescS / 100) * nPerSrv

		if nValRestoS = 0
			nValDesc := 0
		Elseif nValRestoS < nValDesc
			nValDesc  := nValRestoS
			nValResto := 0
		Endif

		aColsFEC[4,ixu,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] += nValDesc
		M->VO4_VALDES := aColsFEC[4,ixu,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
		aColsFEC[4,ixu,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := aColsFEC[4,ixu,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] - aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
		aColsFEC[4,ixu,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := 100 - ((aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] / aColsFEC[4,ixu,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]) * 100)

		if nValRestoS > 0
			nValRestoS -= nValDesc
			if aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] > nMaiorValor
				nMaiorValor := aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
				y := ixu
			Endif
		Endif

		nTotDes += aColsFEC[4,ixu,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
		nTotSrv += aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
		nTotTTp += aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]

		If cParam01 < 3
			M->VO4_TIPSER := aColsFEC[4,ixu,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
			M->VO4_CODSER := aColsFEC[4,ixu,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
			FS_RATEIO(aColsFEC[4,ixu,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)],aColsFEC[4,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)],4,.f.)
			FS_RATCOB(4,aColsFEC[4,ixu,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)])
		EndIf

	Next

	For ixu := 1 to len(aColsFEC[3])

		aColsFEC[3,ixu,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)] := 0
		aColsFEC[3,ixu,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] := 0
		aColsFEC[3,ixu,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 0
		aColsFEC[3,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] := 0

	Next

	FS_TTSRVC("CDCI")  // Recalcula GetDados Sintetica

	nValorZ := 0
	For ixu := 1 to len(aColsFEC[3])
		aColsFEC[3,ixu,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 100 - ((aColsFEC[3,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] / aColsFEC[3,ixu,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]) * 100)
		nValorz += aColsFEC[3,ixu,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
	Next

	If nVlrSrv != nValorZ
		Do Case
			Case nValorZ > nVlrSrv
				nValorZ := nValorZ - nVlrSrv
				aColsFEC[3,1,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] += nValorZ
				aColsFEC[3,1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] -= nValorZ
				aColsFEC[3,1,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 100 - ((aColsFEC[3,1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] / aColsFEC[3,1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]) * 100)
			Case nValorZ < nVlrSrv
				nValorZ := nVlrSrv - nValorZ
				aColsFEC[3,1,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] -= nValorZ
				aColsFEC[3,1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] += nValorZ
				aColsFEC[3,1,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 100 - ((aColsFEC[3,1,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] / aColsFEC[3,1,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]) * 100)
		EndCase
	EndIf


	// Valor a Financiar - Entrada

	nValEnt := 0
	For x:=1 to Len(aColsC)
		if !aColsC[x,Len(aColsC[x])] .and. !Empty(aColsC[x,1])
			nValEnt := nValEnt + aColsC[x,FG_POSVAR("VS9_VALPAG","aHeaderC")]
		Endif
	Next

	nVlCal := 0
	For i:=1 to Len(aParcelas)
		nVlCal := nVlCal + aParcelas[i,2]
	Next

	nVlDif := nValorCom - (nVlCal+nValEnt)
	aParcelas[Len(aParcelas),2] := aParcelas[Len(aParcelas),2] + nVlDif

	aIteParc := aClone(aParcelas)

	// Refaz o ListBox das Parcelas
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}
	oLbParc:Refresh()

Endif

cTipPag := RetCondVei()
cCodBco := Space(3)
oTipPag:Refresh()
oCodBco:Refresh()

DbSelectArea("SE4")
if DbSeek(xFilial("SE4")+cTipPag)
	cDesPag := SE4->E4_DESCRI
	M->VS1_FORPAG := cTipPag
	M->VS1_DESFPG := cDesPag
Else
	wRet := .f.
Endif

FS_MUDABCO1()

oGetPecAna:oBrowse:SetFocus()
n := oGetPecAna:oBrowse:nAt
oGetPecAna:oBrowse:Refresh()
oGetPecSin:oBrowse:SetFocus()
n := oGetPecSin:oBrowse:nAt
oGetPecSin:oBrowse:Refresh()
oGetSrvAna:oBrowse:SetFocus()
n := oGetSrvAna:oBrowse:nAt
oGetSrvAna:oBrowse:Refresh()
oGetSrvSin:oBrowse:SetFocus()
n := oGetSrvSin:oBrowse:nAt
oGetSrvSin:oBrowse:Refresh()

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_160PESQºAutor  ³Fabio               º Data ³  02/14/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Pesquisa no arquivo sem perder o filtro no browse           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_160PESQ()

Local cAliasBrow := Alias() , nIndBrow := &(Alias()+"->(IndexOrd())")

If Type("aPesquisa") # "U"
	FG_AXPESQUISA()
Else
	AxPesqui()
EndIf

DbSelectArea(cAliasBrow)
DbSetOrder(nIndBrow)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AcertDesºAutor  ³Manoel Filho               º Data ³  16/07/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao Local que acerta Valor de Desconto por Item          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_AcertDes()

//If str(val(str(nvaldes/M->VO3_QTDREQ,10,2))*M->VO3_QTDREQ,10,2) != str(nvaldes,10,2)
//	nValdes := val(str(nvaldes/M->VO3_QTDREQ,10,2))*M->VO3_QTDREQ
//Endif
//M->VO3_VALDES := nValdes

M->VO3_VALDES :=  nValDes := val(str(nValDes/M->VO3_QTDREQ,12,2))*M->VO3_QTDREQ

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_AVRES2 ºAutor  ³Ricardo Farinelli   º Data ³  21/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Complemento ao Mapa de Avaliacao de Resultados              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao de Concessionarias                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_AVRES2()
// Avaliacao de Pecas
Local n_ := 0
If FG_SEEK("VSY","VS6->VS6_NUMIDE",1,.f.)

	dbSelectArea("VSY")

	While VS6->VS6_NUMIDE == VSY_NUMIDE .and. VSY->VSY_FILIAL == xFilial("VSY") .and. !eof()

		DbSelectArea("VOQ")
		FG_Seek("VOQ","cMapPecas",1,.f.)
		FG_SEEK("SB1","VSY->VSY_GRUITE+VSY->VSY_CODITE",7,.f.)
		nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ_CODIGO})
		ncont := nPosVet
		while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

			If VOQ_INDATI != "1" // Sim
				dbSkip()
				Loop
			Endif

			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

			if nPosVet == 0
				aadd(aStruP,{ VSY->VSY_NUMOSV,,SB1->B1_COD,;
				VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
				aadd(aSomaStru,{0,0,0,0,0,0})
			Else

				aStruP[nCont,1]  := VSY->VSY_NUMOSV
				aStruP[nCont,2]  := Nil
				aStruP[nCont,3]  := SB1->B1_COD
				aStruP[nCont,4]  := VOQ_CLAAVA
				aStruP[nCont,5]  := cDescVOQ
				aStruP[nCont,6]  := VOQ_ANASIN
				aStruP[nCont,7]  := VOQ_CODIGO
				aStruP[nCont,8]  := VOQ_SINFOR
				aStruP[nCont,9]  := 0
				aStruP[nCont,10] := 0
				aStruP[nCont,11] := SB1->B1_GRUPO+" "+SB1->B1_CODITE
				aStruP[nCont,12] := 0
				aStruP[nCont,13] := 0
				aStruP[nCont,14] := .f.
				aStruP[nCont,15] := VOQ->VOQ_PRIFAI
				aStruP[nCont,16] := VOQ->VOQ_SEGFAI
				aStruP[nCont,17] := VOQ_FUNADI
				aStruP[nCont,18] := VOQ_CODIMF
				aStruP[nCont,19] := dDataBase
				aStruP[nCont,20] := 0
				aStruP[nCont,21] := 0

			Endif

			nCont++

			DbSkip()

		Enddo

		DbSelectArea("VSY")

		cNumero := VS6->VS6_NUMIDE
		aStruP := FG_CalcVlrs(aStruP,SB1->B1_COD,cCpoDiv)

		if nPosVet == 0
			cCpoDiv := cCpoDiv + "#" + str(len(aStruP)+1,5)
		Endif

		FG_Seek("VOQ","cMapPecas",1,.f.)
		FG_SEEK("SB1","VSY->VSY_GRUITE+VSY->VSY_CODITE",7,.f.)
		nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ->VOQ_CODIGO})
		If nPosVet == 0
			nPosVet := 1
		Endif

		For n_:=nPosVet to Len(aSomaStru)
			aSomaStru[n_,1] += aStruP[n_,9]
			aSomaStru[n_,3] += aStruP[n_,12]
			aSomaStru[n_,5] += aStruP[n_,20]
		Next

		For n_:=1 to Len(aSomaStru)
			aStruP[n_,9]  := aSomaStru[n_,1]
			aStruP[n_,12] := aSomaStru[n_,3]
			aStruP[n_,20] := aSomaStru[n_,5]
		Next

		DbSkip()

	EndDo

	lCalcTot:= .t.

	DbSelectArea("VOQ")
	FG_Seek("VOQ","cMapPecas",1,.f.)

	While cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

		If VOQ_INDATI != "1" // Sim
			dbSkip()
			Loop
		Endif

		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
		aadd(aStruP,{ VSY->VSY_NUMOSV,,STR0135,;
		VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

		DbSkip()

	EndDo

	cNumero := VS6->VS6_NUMIDE
	aStruP := FG_CalcVlrs(aStruP,STR0135,cCpoDiv)

EndIf

// Avaliacao de Servicos

aSomaStru := {}
cCpoDiv   := "    1"
lCalcTot  := .f.

If FG_SEEK("VSZ","VS6->VS6_NUMIDE",1,.f.)

	DbSelectArea("VSZ")
	While  VS6->VS6_NUMIDE == VSZ_NUMIDE .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. !eof()

		DbSelectArea("VOQ")
		FG_Seek("VOQ","cMapSrvcs",1,.f.)
		nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSZ->VSZ_CODSER+VOQ_CODIGO})
		nCont := nPosVet

		While cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

			if VOQ_INDATI != "1" // Sim
				DbSkip()
				Loop
			Endif

			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

			If nPosVet == 0
				aAdd(aStruS,{ VSZ->VSZ_NUMOSV,,VSZ->VSZ_CODSER,;
				VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
				aAdd(aSomaStru,{0,0,0,0,0,0})
			Else
				aStruS[nCont,1]  := VSZ->VSZ_NUMOSV
				aStruS[nCont,2]  := Nil
				aStruS[nCont,3]  := VSZ->VSZ_CODSER
				aStruS[nCont,4]  := VOQ_CLAAVA
				aStruS[nCont,5]  := cDescVOQ
				aStruS[nCont,6]  := VOQ_ANASIN
				aStruS[nCont,7]  := VOQ_CODIGO
				aStruS[nCont,8]  := VOQ_SINFOR
				aStruS[nCont,9]  := 0
				aStruS[nCont,10] := 0
				aStruS[nCont,11] := VSZ->VSZ_CODSER
				aStruS[nCont,12] := 0
				aStruS[nCont,13] := 0
				aStruS[nCont,14] := .f.
				aStruS[nCont,15] := VOQ->VOQ_PRIFAI
				aStruS[nCont,16] := VOQ->VOQ_SEGFAI
				aStruS[nCont,17] := VOQ_FUNADI
				aStruS[nCont,18] := VOQ_CODIMF
				aStruS[nCont,19] := dDataBase
				aStruS[nCont,20] := 0
				aStruS[nCont,21] := 0
			Endif

			nCont ++

			DbSkip()

		EndDo

		DbSelectArea("VSZ")
		nArea := GetArea()

		cNumero := VS6->VS6_NUMIDE + VSZ->VSZ_CODSER + VSZ->VSZ_NUMOSV
		aStruS := FG_CalcVlrs(aStruS,VSZ->VSZ_CODSER,cCpoDiv)

		If nPosVet == 0
			cCpoDiv := cCpoDiv + "#" + str(len(aStruS)+1,5)
		Endif

		FG_Seek("VOQ","cMapSrvcs",1,.f.)
		nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSZ->VSZ_CODSER+VOQ->VOQ_CODIGO})
		If nPosVet == 0
			nPosVet := 1
		Endif

		For n_:=nPosVet to Len(aSomaStru)
			aSomaStru[n_,1] += aStruS[n_,9]
			aSomaStru[n_,3] += aStruS[n_,12]
			aSomaStru[n_,5] += aStruS[n_,20]
		Next

		For n_:=1 to Len(aSomaStru)
			aStruS[n_,9]  := aSomaStru[n_,1]
			aStruS[n_,12] := aSomaStru[n_,3]
			aStruS[n_,20] := aSomaStru[n_,5]
		Next

		DbSelectArea("VSZ")
		RestArea(nArea)
		DbSkip()

	EndDo

	lCalcTot:= .t.

	DbSelectArea("VOQ")
	FG_SEEK("VOQ","cMapSrvcs",1,.f.)

	while cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

		If VOQ_INDATI != "1" // Sim
			DbSkip()
			Loop
		Endif

		cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
		aadd(aStruS,{ VSZ->VSZ_NUMOSV,,STR0135,;
		VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
		DbSkip()

	EndDo

	cNumero := VS6->VS6_NUMIDE
	aStruS := FG_CalcVlrs(aStruS,STR0135,cCpoDiv)

EndIf

// Avaliacao da Ordem de Servico

aSomaStru := {}
cCpoDiv := "    1"

If FG_SEEK("VSY","VS6->VS6_NUMIDE",1,.f.)

	DbSelectArea("VSY")

	While VS6->VS6_NUMIDE == VSY_NUMIDE .and. VSY->VSY_FILIAL == xFilial("VSY") .and. !eof()

		DbSelectArea("VOQ")
		FG_Seek("VOQ","cMapOdSrv",1,.f.)

		while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

			If VOQ_INDATI != "1" // Sim
				dbSkip()
				Loop
			Endif

			FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)

			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
			aadd(aStruO,{ VSY->VSY_NUMOSV,,SB1->B1_COD,;
			VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

			dbSkip()

		Enddo

		DbSelectArea("VSY")

		cNumero := VS6->VS6_NUMIDE
		aStruO := FG_CalcVlrs(aStruO,SB1->B1_GRUPO+" "+SB1->B1_CODITE,cCpoDiv)
		cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
		dbSkip()

	EndDo

EndIf

If FG_SEEK("VSZ","VS6->VS6_NUMIDE",1,.f.)

	DbSelectArea("VSZ")

	While VS6->VS6_NUMIDE == VSZ_NUMIDE .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. !eof()

		DbSelectArea("VOQ")
		FG_Seek("VOQ","cMapOdSrv",1,.f.)

		While cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

			if VOQ_INDATI != "1" // Sim
				DbSkip()
				Loop
			Endif

			cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
			aadd(aStruO,{ VSZ->VSZ_NUMOSV,,VSZ->VSZ_CODSER,;
			VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

			DbSkip()

		Enddo

		DbSelectArea("VSZ")

		cNumero := VS6->VS6_NUMIDE
		aStruO := FG_CalcVlrs(aStruO,VSZ->VSZ_CODSER,cCpoDiv)
		cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
		DbSkip()

	EndDo

EndIf

lCalcTot:= .t.

DbSelectArea("VOQ")
FG_SEEK("VOQ","cMapOdSrv",1,.f.)

while cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

	If VOQ_INDATI != "1" // Sim
		DbSkip()
		Loop
	Endif

	cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
	aadd(aStruO,{ VSZ->VSZ_NUMOSV,,STR0135,;
	VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

	DbSkip()

EndDo

cNumero := VS6->VS6_NUMIDE
aStruO := FG_CalcVlrs(aStruO,STR0135,cCpoDiv)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALVLR1ºAutor  ³Fabio               º Data ³  07/07/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o valor do fechamento do item esta correto       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALVLR160(cGruIte,cCodIte,nValor,cCodSrv,cTipTem,cTipSrv)

Local lRetValVlr := .t. , cMsg160 := ""
Local nPosSB1 := SB1->(Recno())
Local nPosSB5 := SB5->(Recno())
Local nPosSX3 := SX3->(Recno())
Local nPosVOI := VOI->(Recno())

Default cGruIte := ""
Default cCodIte := ""
Default cCodSrv := ""
Default cTipTem := ""
Default cTipSrv := ""

If !Empty(cGruIte) .And. !Empty(cCodIte) .And. nValor <= 0

	DbSelectArea("SB1")
	DbSetOrder(7)
	DbSeek( xFilial("SB1") + cGruIte + cCodIte )
	DbSelectArea("SB5")
	DbSetOrder(1)
	DbSeek( xFilial("SB5") + SB1->B1_COD )
	DbSelectArea("SX3")
	DbSetOrder(2)

	cMsg160 += STR0159 +CHR(13)+CHR(10)													//Peca com valor menor ou igual a zero!
	cMsg160 += STR0160 +cGruIte+CHR(13)+CHR(10)											//Grupo............:
	cMsg160 += STR0161 +cCodIte+CHR(13)+CHR(10)											//Codigo Item......:
	cMsg160 += STR0162 +Transform(nValor,"@E 999,999,999.99")+CHR(13)+CHR(10)+CHR(13)+CHR(10)	//Vlr do Fechamento:

	cMsg160 += STR0163 +CHR(13)+CHR(10)													//Valores cadastrados:
	SX3->(DbSeek( "B1_PRV1" ))
	cMsg160 += X3Titulo()+Transform(SB1->B1_PRV1,"@E 999,999,999.99")+CHR(13)+CHR(10)
	SX3->(DbSeek( "B5_PRV2" ))
	cMsg160 += X3Titulo()+Transform(SB5->B5_PRV2,"@E 999,999,999.99")+CHR(13)+CHR(10)
	SX3->(DbSeek( "B5_PRV3" ))
	cMsg160 += X3Titulo()+Transform(SB5->B5_PRV3,"@E 999,999,999.99")+CHR(13)+CHR(10)
	SX3->(DbSeek( "B5_PRV4" ))
	cMsg160 += X3Titulo()+Transform(SB5->B5_PRV4,"@E 999,999,999.99")+CHR(13)+CHR(10)
	SX3->(DbSeek( "B5_PRV5" ))
	cMsg160 += X3Titulo()+Transform(SB5->B5_PRV5,"@E 999,999,999.99")+CHR(13)+CHR(10)
	SX3->(DbSeek( "B5_PRV6" ))
	cMsg160 += X3Titulo()+Transform(SB5->B5_PRV6,"@E 999,999,999.99")+CHR(13)+CHR(10)
	SX3->(DbSeek( "B5_PRV7" ))
	cMsg160 += X3Titulo()+Transform(SB5->B5_PRV7,"@E 999,999,999.99")+CHR(13)+CHR(10)

	Help("  ",1,"VALVLR160",, cMsg160 ,3,1)

	lRetValVlr := .f.

	SB1->(DbGoto(nPosSB1))
	SB5->(DbGoto(nPosSB5))
	SX3->(DbGoto(nPosSX3))

ElseIf !Empty(cCodSrv) .And. nValor <= 0

	DbSelectArea("VOI")
	DbSetOrder(1)
	DbSeek( xFilial("VOI") + cTipTem )

	DbSelectArea("VOK")
	DbSetOrder(1)
	DbSeek( xFilial("VOK") + cTipSrv )

	If VOI->VOI_SITTPO # "3" .and. VOK->VOK_INCMOB <> "0"

		cMsg160 += STR0164 +CHR(13)+CHR(10)										//Servico com valor menor ou igual a zero!
		cMsg160 += STR0165 +cCodSrv+CHR(13)+CHR(10)								//Codigo Servico...:
		cMsg160 += STR0162 +Transform(nValor,"@E 999,999,999.99")+CHR(13)+CHR(10)	//Vlr do Fechamento:

		Help("  ",1,"VALVLR160",, cMsg160 ,3,1)

		lRetValVlr := .f.

	EndIf

	VOI->(DbGoto(nPosVOI))

EndIf

Return(lRetValVlr)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SALVANEG³ Autor ³ Andre                 ³ Data ³ 17/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Salva Negociacao de Pagamento e descontos nas PECAS/SERVICOS ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
function FS_SALVANEG()

Local i, j, ii, ixx, cont, nVarct, cGrupo, cItem, cNumIn, cTipTp, lAchou
Local nQtdOs := 0
Local cTipTem := ""
Local cSeekVO1 := ""
Local nX := 0
Local nRecVO1 := 0
Local cLibVOO := ""

if lSalvou
	Return(.t.)
Endif

Do Case
	Case cParam01 == 1   // Fechamento Individual (referencia1)

		ixx := Ascan(aVetTTp,{|x| x[1]==.t.})
		if ixx = 0
			Return(.f.)
		Endif
		cTipTem := aVetTTp[ixx,3]

	Case cParam01 == 2   // Fechamento Agrupado (referencia2)

		cTipTem := cParam04

	Case cParam01 == 3   // Fechamento de Kilometragem (referencia3)

		cTipTem := cParam04

EndCase

if Empty(cTipTem)
	Return(.f.)
Endif

Begin Transaction

dbSelectArea("VS9")
DELNEG160()

// Grava -> BANCO / TIPO DE PAGAMENTO / NATUREZA //
nRecVO1 := VO1->(RecNo())
DbSelectArea("VO1")
DbSetOrder(1)
For nX := 1 to len(aOS_GRV)
	If DbSeek(xFilial("VO1")+aOS_GRV[nX,1])
		RecLock("VO1",.f.)
		VO1->VO1_CODBCO := cCodBco
		VO1->VO1_FORPAG := cTipPag
		If lVO1_NATURE
			VO1->VO1_NATURE := cVO1_NATURE
		EndIf
		MsUnlock()
	EndIf
Next
DbGoTo(nRecVO1)

DbSelectArea("VOO")
DbSetOrder(1)//filial + ordem de servico+Tipo de Tempo
For nX := 1 to len(aOS_GRV)
	If DbSeek(xFilial("VOO")+aOS_GRV[nX,1]+cTipTem)
		Reclock("VOO",.f.)
		VOO->VOO_CONDPG := cTipPag
		VOO->VOO_DEPTO  := cDepVOO
		IF lVO1_NATSRV
			VOO->VOO_NATPEC := cVO1_NATURE
			VOO->VOO_NATSRV := cVO1_NATSRV
		EndIf
		MsUnlock()
	
		If VOO->(FieldPos("VOO_LIBVOO")) <> 0 //.and. cParam01 == 1
			cLibVOO := VOO->VOO_LIBVOO
		EndIf
	
	Endif
Next

//altera a filial para apagar os registros que nao estiverem mais no fechamento
dbSelectArea("VZ1")
dbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV)
while !Eof() .and. VZ1_FILIAL = xFilial("VZ1") .and. VZ1_NUMOSV = VO1->VO1_NUMOSV
	if VZ1_TIPFEC == strzero(cParam01,1) .AND. VZ1_TIPTEM == cTipTem
		RecLock("VZ1",.f.)
		VZ1->VZ1_FILIAL := "ZZ"
		MsUnlock()
		dbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV)
	Else
		dbSkip()
	Endif
Enddo

dbSelectArea("VZ1")
dbSetOrder(1)
For cont := 1 to Len(aColsFEC[2])
	if Empty(aColsFEC[2,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)])
		Loop
	Endif
	lAchou := dbSeek("ZZ"+VO1->VO1_NUMOSV+cTipTem+"P"+strzero(cParam01,1)+aColsFEC[2,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,cont,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)])
	RecLock("VZ1",!lAchou)
	VZ1->VZ1_FILIAL := xFilial("VZ1")
	VZ1->VZ1_NUMOSV := VO1->VO1_NUMOSV
	VZ1->VZ1_TIPTEM := cTipTem
	VZ1->VZ1_PECSER := "P"
	VZ1->VZ1_TIPFEC := strzero(cParam01,1)
	VZ1->VZ1_GRUITE := aColsFEC[2,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
	VZ1->VZ1_CODITE := aColsFEC[2,cont,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)]
	VZ1->VZ1_PERDES := aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
	VZ1->VZ1_VALDES := aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
	VZ1->VZ1_VALBRU := aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
	VZ1->VZ1_CODTES := aColsFEC[2,cont,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]
	VZ1->VZ1_VALUNI := aColsFEC[2,cont,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)]
	
	If VOO->(FieldPos("VOO_LIBVOO")) <> 0 //.and. cParam01 == 1
		VZ1->VZ1_LIBVOO := cLibVOO
	EndIf
	
	MsUnlock()
Next

dbSelectArea("VZ1")
dbSetOrder(2)
For cont := 1 to Len(aColsFEC[4])
	if Empty(aColsFEC[4,cont,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)])
		Loop
	Endif
	lAchou := dbSeek("ZZ"+VO1->VO1_NUMOSV+cTipTem+"S"+strzero(cParam01,1)+aColsFEC[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+aColsFEC[4,cont,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]+aColsFEC[4,cont,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)])
	RecLock("VZ1",!lAchou)
	VZ1->VZ1_FILIAL := xFilial("VZ1")
	VZ1->VZ1_NUMOSV := VO1->VO1_NUMOSV
	VZ1->VZ1_TIPTEM := cTipTem
	VZ1->VZ1_PECSER := "S"
	VZ1->VZ1_TIPFEC := strzero(cParam01,1)
	VZ1->VZ1_TIPSER := aColsFEC[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
	VZ1->VZ1_GRUSER := aColsFEC[4,cont,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]
	VZ1->VZ1_CODSER := aColsFEC[4,cont,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
	VZ1->VZ1_PERDES := aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
	VZ1->VZ1_VALDES := aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
	VZ1->VZ1_VALBRU := aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
	VZ1->VZ1_VALUNI := aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
	ix4 := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == aColsFEC[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]})
	if ix4 > 0
		VZ1->VZ1_CODTES := aColsFEC[3,ix4,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)]
	Endif

	If VOO->(FieldPos("VOO_LIBVOO")) <> 0 //.and. cParam01 == 1
		VZ1->VZ1_LIBVOO := cLibVOO
	EndIf	
	
	MsUnlock()
Next

//apaga os registros nao usados
dbSelectArea("VZ1")
dbSeek("ZZ")
while !Eof() .and. VZ1_FILIAL = "ZZ" .and. VZ1_NUMOSV = VO1->VO1_NUMOSV
	RecLock("VZ1",.f.,.t.)
	VZ1->(dbDelete())
	MsUnlock()
	WriteSx2("VZ1")
	dbSkip()
Enddo

//NEGOCIACAO
dbselectarea("VSE")
lAchou := dbSeek(xFilial("VSE")+VO1->VO1_NUMOSV+"O")
For i:=1 to Len(aGravaEnt)
	RecLock("VSE",!lAchou)
	VSE->VSE_FILIAL := xFilial("VSE")
	VSE->VSE_NUMIDE := VO1->VO1_NUMOSV
	VSE->VSE_TIPOPE := "O"
	VSE->VSE_SEQUEN := StrZero(aGravaEnt[i,1],2)
	VSE->VSE_TIPPAG := aGravaEnt[i,2]
	VSE->VSE_DESCCP := aGravaEnt[i,3]
	VSE->VSE_NOMECP := aGravaEnt[i,4]
	VSE->VSE_TIPOCP := aGravaEnt[i,5]
	VSE->VSE_TAMACP := aGravaEnt[i,6]
	VSE->VSE_DECICP := aGravaEnt[i,7]
	VSE->VSE_PICTCP := aGravaEnt[i,8]
	//	VSE->VSE_VALDIG := alltrim(str(aColsC[i,FG_POSVAR("VS9_VALPAG","aHeaderC")]))
	VSE->VSE_VALDIG := aGravaEnt[i,9]
	If VSE->(FieldPos("VSE_TIPTEM")) <> 0
		VSE->VSE_TIPTEM := VOO->VOO_TIPTEM
	Endif
	If VOO->(FieldPos("VOO_LIBVOO")) <> 0 //.and. cParam01 == 1
		VSE->VSE_LIBVOO := cLibVOO
	EndIf
Next


dbSelectarea("VS9")
dbSetOrder(1)

For j:=1 to Len(aColsC)
	If !aColsC[j,Len(aColsC[j])] .and. !Empty(aColsC[j,1])
		RecLock("VS9",.T.)
		Fg_Gravar("VS9",aColsC,aHeaderC,j)
		VS9->VS9_FILIAL := xFilial("VS9")
		VS9->VS9_NUMIDE := VO1->VO1_NUMOSV
		VS9->VS9_TIPOPE := "O"
		VS9->VS9_TIPFEC := strzero(cParam01,1)
		VS9->VS9_TIPPAG := aColsC[j,FG_POSVAR("VS9_TIPPAG","aHeaderC")]
		cVar := aMemos[1][2]
		MSMM(,TamSx3("VS9_OBSERV")[1],,&cVar,1,,,"VS9","VS9_OBSMEM")
		If VS9->(FieldPos("VS9_TIPTEM")) <> 0
			VS9->VS9_TIPTEM := VOO->VOO_TIPTEM
		Endif
		MsUnlock()
		If VOO->(FieldPos("VOO_LIBVOO")) <> 0 //.and. cParam01 == 1
			VS9->VS9_LIBVOO := cLibVOO
		EndIf
	Endif
Next

For i:=1 to Len(aIteParc)
	If !Empty(aIteParc[i,1])
		RecLock("VS9",.T.)
		VS9->VS9_FILIAL := xFilial("VS9")
		VS9->VS9_NUMIDE := VO1->VO1_NUMOSV
		VS9->VS9_TIPOPE := "O"
		VS9->VS9_TIPPAG := "DP"
		VS9->VS9_TIPFEC := strzero(cParam01,1)
		//		VS9->VS9_DESPAG := OemToAnsi("DUPLICATA") - Campo VIRTUAL nao eh Possivel atribuir conteudo
		VS9->VS9_DATPAG := DataValida(aIteParc[i,1])
		VS9->VS9_VALPAG := aIteParc[i,2]
		if !Empty(cCondic1) .and. !Empty(cCondic3)
			VS9->VS9_REFPAG := alltrim(dtoc(cCondic1))+strzero(val(cCondic2),2)+strzero(val(cCondic3),2)+strzero(val(cCondic4),2)
		Endif
		If VS9->(FieldPos("VS9_TIPTEM")) <> 0 .and. Empty(VS9->VS9_TIPTEM)
			VS9->VS9_TIPTEM := VOO->VOO_TIPTEM
		Endif
		If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATURE")) <> 0
			VS9->VS9_NATURE := cVO1_NATURE
		Endif
		If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATSRV")) <> 0
			VS9->VS9_NATSRV := cVO1_NATSRV
		Endif
		If VOO->(FieldPos("VOO_LIBVOO")) <> 0 //.and. cParam01 == 1
			VS9->VS9_LIBVOO := cLibVOO
		EndIf
		MsUnlock()
	Endif
Next

dbSelectArea("VS9")

if !Empty(cCodCDCI) .and. nValorCom > 0
	RecLock("VS9",.T.)
	VS9->VS9_FILIAL := xFilial("VS9")
	VS9->VS9_NUMIDE := VO1->VO1_NUMOSV
	VS9->VS9_TIPOPE := "O"
	VS9->VS9_TIPPAG := "CD"
	VS9->VS9_TIPFEC := strzero(cParam01,1)
	VS9->VS9_DATPAG := dDataBase
	VS9->VS9_VALPAG := nValorCom
	VS9->VS9_REFPAG := cCodCDCI
	If VS9->(FieldPos("VS9_TIPTEM")) <> 0
		VS9->VS9_TIPTEM := VOO->VOO_TIPTEM
	Endif
	If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATURE")) <> 0
		VS9->VS9_NATURE := cVO1_NATURE
	Endif
	If VO1->(FieldPos("VO1_NATURE")) <> 0 .and. VS9->(FieldPos("VS9_NATSRV")) <> 0
		VS9->VS9_NATSRV := cVO1_NATSRV
	Endif
	If VOO->(FieldPos("VOO_LIBVOO")) <> 0 //.and. cParam01 == 1
		VS9->VS9_LIBVOO := cLibVOO
	EndIf
	MsUnlock()
Endif


dbSelectArea("VSF")
dbSetOrder(1)
if RecLock("VSF",If(dbSeek(xFilial("VSF")+VO1->VO1_NUMOSV+strzero(cParam01,1)+cTipTem),.f.,.t.))
	VSF->VSF_FILIAL := xFilial("VSF")
	VSF->VSF_NUMOSV := VO1->VO1_NUMOSV
	VSF->VSF_TIPFEC := strzero(cParam01,1)
	VSF->VSF_TIPTEM := cTipTem
	VSF->VSF_DESACE := M->VSF_DESACE
	MsUnlock()
Endif

lSalvou := .t.

//Grava NUMERO E ITEM DO PEDIDO DA NFE
If VO3->(FieldPos("VO3_PEDXML")) <> 0

	dbSelectArea("VO2")
	DbSetOrder(1)

	If cParam01 == 1 // Individual
		nQtdOs := 1
	ElseIf cParam01 == 2 // Agrupado
		If Len(aArrPec) > 0
			nQtdOs := Len(aArrPec)
		Else
			nQtdOs := 0
		Endif
	Endif

	For ii := 1 to nQtdOs

		If cParam01 == 1 // Individual
			cSeekVO1 := M->VO1_NUMOSV
		ElseIf cParam01 == 2 // Agrupado
			cSeekVO1 := aArrPec[ii,1]
		Endif


		If Iif(cParam01 == 2,FG_SEEK("VO1",'"'+(cSeekVO1)+'"',1,.f.),.t.) .and. FG_SEEK("VO2",'"'+(cSeekVO1)+'"',1,.f.)

			While VO1->VO1_NUMOSV == VO2->VO2_NUMOSV .and. VO2->VO2_FILIAL == xFilial("VO2") .and. !eof()

				If VO2->VO2_TIPREQ == "P"     // Requisicao de Pecas

					dbSelectArea("VO3")
					dbSetOrder(1)
					If FG_SEEK("VO3","VO2->VO2_NOSNUM",1,.f.)

						nRegVAI := VAI->(RecNo())
						cKeyAce := __cUserID
						FG_SEEK("VAI","cKeyAce",4,.f.)

						While VO2->VO2_NOSNUM == VO3->VO3_NOSNUM .and. VO3->VO3_FILIAL == xFilial("VO3") .and. !eof()

							If cParam01 == 1 // Individual
								If aVetTTp[ixx,3] != VO3->VO3_TIPTEM
									dbSkip()
									Loop
								EndIf
							Endif

							nPosItem := aScan(aColsFEC[2],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+x[FS_POSVAR("VO3_CODITE","aHeaderFEC",2)] == VO3->VO3_GRUITE + VO3->VO3_CODITE } )
							If nPosItem > 0
								DbSelectArea("VO3")
								If !RecLock("VO3",.f.)
									Help("  ",1,"REGNLOCK")
									lRetFech := .f.
									DisarmTransaction()
									Break
								EndIf
								VO3->VO3_PEDXML := aColsFEC[2,nPosItem,FS_POSVAR("VO3_PEDXML","aHeaderFEC",2)]
								VO3->VO3_ITEXML := aColsFEC[2,nPosItem,FS_POSVAR("VO3_ITEXML","aHeaderFEC",2)]
								MsUnlock()
							Endif

							dbSelectArea("VO3")
							dbSkip()

						EndDo

						VAI->(DbGoTo(nRegVAI))

					EndIf

				EndIf

				dbSelectArea("VO2")
				dbSkip()

			EndDo

		EndIf

	Next

Endif

End Transaction

aCols   := aClone(aColsC)
aHeader := aClone(aHeaderC)
n       := nC
return(.t.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_ABRENEG ³ Autor ³ Andre                 ³ Data ³ 17/10/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre Negociacao de Pagamento e descontos nas PECAS/SERVICOS  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametro ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Exclusivo                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ABRENEG()

Local cont, ixx, _ni
Local cTipTem := ""
Local lPec, lSer
Local nAuxPerDes,nAuxValLiq

Do Case
	Case cParam01 == 1   // Fechamento Individual (referencia1)

		ixx := Ascan(aVetTTp,{|x| x[1]==.t.})
		if ixx = 0
			Return(.f.)
		Endif
		cTipTem := aVetTTp[ixx,3]

	Case cParam01 == 2   // Fechamento Agrupado (referencia2)

		cTipTem := cParam04

	Case cParam01 == 3   // Fechamento de Kilometragem (referencia3)

		cTipTem := cParam04
EndCase

if Empty(cTipTem)
	Return(.f.)
Endif

dbSelectArea("VZ1")
dbSetOrder(1)
lPec := dbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV+cTipTem+"P"+strzero(cParam01,1))
dbSetOrder(2)
lSer := dbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV+cTipTem+"S"+strzero(cParam01,1))

If lPec .or. lSer
	If !MsgYesNo(STR0192,STR0181) // "Existe negociação salva para este Tipo de Tempo! Deseja restaurá-la?"
		lPec := .f.
		lSer := .f.
	Endif
Endif

if !lPec .and. !lSer
	//Nao existe negociacao de pecas ou servicos gravada
	Return(.t.)
Endif

//nTotPec := 0  // Valor das pecas
//nTotSrv := 0  // Valor dos servicos
//nTotDes := 0  // Valor do Desconto
//nTotTTP := 0  // Valor da OS

cCodBco := VO1->VO1_CODBCO
cVO1_NATURE := Space(TAMSX3("VO1_NATURE")[1])
if lVO1_NATSRV
	cVO1_NATSRV := Space(TAMSX3("VOO_NATSRV")[1])
endif

//cTipPag := VO1->VO1_FORPAG
DbSelectArea("VOO")
DbSetOrder(1)//filial + ordem de servico+Tipo de Tempo
If DbSeek(xFilial("VOO")+VO1->VO1_NUMOSV+cTipTem)
	If !Empty(VOO->VOO_DEPTO)
		cDepVOO := VOO->VOO_DEPTO
	Endif
	If !Empty(VOO->VOO_CONDPG)
		cTipPag := VOO->VOO_CONDPG
	Endif
	If VOO->(FieldPos("VOO_NATPEC")) > 0
		cVO1_NATURE := VOO->VOO_NATPEC
	Endif
	If VOO->(FieldPos("VOO_NATSRV")) > 0
		cVO1_NATSRV := VOO->VOO_NATSRV
	Endif
EndIf

//Procura descontos de pecas gravados
if lPec
	for cont := 1 to Len(aColsFEC[1])

		DbSelectArea("VZ1")
		DbSetOrder(1)
		If DbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV+cTipTem+"P"+strzero(cParam01,1)+aColsFEC[1,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)])

			If ( nTotPec -= aColsFEC[1,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] ) < 0
				nTotPec := 0
			EndIf
			If ( nTotDes -= aColsFEC[1,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] ) < 0
				nTotDes := 0
			EndIf
			If ( nTotTTP -= aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] ) < 0
				nTotTTP := 0
			EndIf

			aColsFEC[1,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] := 0
			aColsFEC[1,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := 0
			aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := 0

		Endif

	next
Endif

nBKPn := n

dbSelectArea("VZ1")
dbSetOrder(1)
For cont := 1 to Len(aColsFEC[2])
	if dbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV+cTipTem+"P"+strzero(cParam01,1)+aColsFEC[2,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]+aColsFEC[2,cont,FS_POSVAR("VO3_CODITE","aHeaderFEC",2)])
		If Type("oGetPecAna") # "U"
			oGetPecAna:oBrowse:SetFocus()
		EndIf

		n := Cont

		aColsFEC[2,cont,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)] := VZ1->VZ1_VALUNI
		aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] := VZ1->VZ1_VALBRU
		aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := VZ1->VZ1_PERDES
		aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := VZ1->VZ1_VALDES
		aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - VZ1->VZ1_VALDES
		if !Empty(VZ1->VZ1_CODTES)
			aColsFEC[2,cont,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)] := VZ1->VZ1_CODTES
			MAFISREF("IT_TES","VO300",VZ1->VZ1_CODTES)
		Endif
		nTotDes += VZ1->VZ1_VALDES
		nTotTTP += aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
		nTotPec += aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
		aCols[cont,FG_POSVAR("VO3_VALPEC")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALPEC","aHeaderFEC",2)]
		aCols[cont,FG_POSVAR("VO3_VALBRU")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)]
		aCols[cont,FG_POSVAR("VO3_PERDES")] := aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
		aCols[cont,FG_POSVAR("VO3_VALDES")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
		aCols[cont,FG_POSVAR("VO3_VALTOT")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
		aCols[cont,FG_POSVAR("VO3_CODTES")] := aColsFEC[2,cont,FS_POSVAR("VO3_CODTES","aHeaderFEC",2)]
		//		MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]-VZ1->VZ1_VALDES)
		MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)])
		MAFISREF("IT_DESCONTO","VO300",VZ1->VZ1_VALDES)

		If Type("oGetPecSin") # "U"
			oGetPecSin:oBrowse:SetFocus()
		EndIf

		M->VO3_GRUITE := aColsFEC[2,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
		ix_ := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
		If ix_ > 0
			aColsFEC[1,ix_,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] += VZ1->VZ1_VALBRU
			aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] += VZ1->VZ1_VALDES
			aColsFEC[1,ix_,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] += VZ1->VZ1_VALBRU - VZ1->VZ1_VALDES
			aColsFEC[1,ix_,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := NoRound( ((aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] * 100) / aColsFEC[1,ix_,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]) ,2 )
			aCols[ix_,FG_POSVAR("VO3_VALBRU")] := aColsFEC[1,ix_,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]
			aCols[ix_,FG_POSVAR("VO3_PERDES")] := aColsFEC[1,ix_,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)]
			aCols[ix_,FG_POSVAR("VO3_VALDES")] := aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]
			aCols[ix_,FG_POSVAR("VO3_VALTOT")] := aColsFEC[1,ix_,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
		EndIf
	Endif
Next

n := nBKPn
If MaFisFound('NF') .AND. nTotPec > 0
	nTotTTP := MaFisRet(,"NF_TOTAL") + nTotSrv
Else
	nTotTTP := 0
EndIf

//Procura descontos de servicos gravados
if lSer
	for cont := 1 to Len(aColsFEC[3])

		DbSelectArea("VZ1")
		DbSetOrder(2)
		If DbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV+cTipTem+"S"+strzero(cParam01,1)+aColsFEC[3,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)])

			If ( nTotSrv -= aColsFEC[3,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)] ) < 0
				nTotSrv := 0
			EndIf
			If ( nTotDes -= aColsFEC[3,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] ) < 0
				nTotDes := 0
			EndIf
			If ( nTotTTP -= aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] ) < 0
				nTotTTP := 0
			EndIf

			aColsFEC[3,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)] := 0
			aColsFEC[3,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] := 0
			aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] := 0

		EndIf

	next
Endif

dbSelectArea("VZ1")
dbSetOrder(2)
For cont := 1 to Len(aColsFEC[4])
	if dbSeek(xFilial("VZ1")+VO1->VO1_NUMOSV+cTipTem+"S"+strzero(cParam01,1)+aColsFEC[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]+aColsFEC[4,cont,FS_POSVAR("VO4_GRUSER","aHeaderFEC",4)]+aColsFEC[4,cont,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)])
		If Type("oGetSrvAna") # "U"
			oGetSrvAna:oBrowse:SetFocus()
		EndIf
		aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] := VZ1->VZ1_VALBRU
		aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := VZ1->VZ1_PERDES
		aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := VZ1->VZ1_VALDES
		aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] - VZ1->VZ1_VALDES
		nTotDes += VZ1->VZ1_VALDES
		nTotTTP += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
		nTotSrv += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
		aCols[cont,FG_POSVAR("VO4_VALBRU")] := aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)]
		aCols[cont,FG_POSVAR("VO4_PERDES")] := aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
		aCols[cont,FG_POSVAR("VO4_VALDES")] := aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
		aCols[cont,FG_POSVAR("VO4_VALTOT")] := aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
		//		MAFISREF("IT_VALMERC" ,"VO400",aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]-VZ1->VZ1_VALDES)
		MAFISREF("IT_VALMERC" ,"VO400",aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)])
		MAFISREF("IT_DESCONTO","VO400",VZ1->VZ1_VALDES)

		If Type("oGetSrvSin") # "U"
			oGetSrvSin:oBrowse:SetFocus()
		EndIf
		M->VO4_TIPSER := aColsFEC[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
		ix_ := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == M->VO4_TIPSER })
		If ix_ > 0
			aColsFEC[3,ix_,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)] += VZ1->VZ1_VALBRU
			aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] += VZ1->VZ1_VALDES
			aColsFEC[3,ix_,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] += VZ1->VZ1_VALBRU - VZ1->VZ1_VALDES
			aColsFEC[3,ix_,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := NoRound( ((aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] * 100) / aColsFEC[3,ix_,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]) ,2 )
			if !Empty(VZ1->VZ1_CODTES)
				aColsFEC[3,ix_,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)] := VZ1->VZ1_CODTES
			Endif
			aCols[ix_,FG_POSVAR("VO4_VALBRU")] := aColsFEC[3,ix_,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]
			aCols[ix_,FG_POSVAR("VO4_PERDES")] := aColsFEC[3,ix_,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)]
			aCols[ix_,FG_POSVAR("VO4_VALDES")] := aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)]
			aCols[ix_,FG_POSVAR("VO4_VALTOT")] := aColsFEC[3,ix_,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
			aCols[ix_,FG_POSVAR("VO4_CODTES")] := aColsFEC[3,ix_,FS_POSVAR("VO4_CODTES","aHeaderFEC",3)]
		EndIf
	Endif
Next

// Atualiza desconto de desconto 
For cont := 1 to Len(aColsFEC[4])
	If aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] <> 0
		M->VO4_TIPSER := aColsFec[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
		M->VO4_CODSER := aColsFec[4,cont,FS_POSVAR("VO4_CODSER","aHeaderFEC",4)]
		nAuxPerDes := aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] / aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] * 100
		nAuxValLiq := aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] - aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
		FS_RATEIO(nAuxPerDes,nAuxValLiq,4,.f.)
	EndIf
Next cont

If MaFisFound('NF')
	M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
	M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
	//	M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
	M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
	M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")
EndIf
dbSelectArea("VSF")
dbSetOrder(1)
if dbSeek(xFilial("VSF")+VO1->VO1_NUMOSV+strzero(cParam01,1)+cTipTem)
	M->VSF_DESACE := VSF->VSF_DESACE
	nTotTTP       += M->VSF_DESACE
	MAFISREF("NF_DESPESA","VSF00",VSF->VSF_DESACE)
Endif
If Type("oCabecNF") # "U"
	FG_ATUALOBJ()
EndIf

If Type("oTotPec03") # "U"
	oTotPec03:refresh()
EndIf
If Type("oTotTTp03") # "U"
	oTotTTp03:refresh()
EndIf
If Type("oTotDes03") # "U"
	oTotDes03:refresh()
EndIf
If Type("oTotPec02") # "U"
	oTotPec02:refresh()
EndIf
If Type("oTotTTp02") # "U"
	oTotTTp02:refresh()
EndIf
If Type("oTotDes02") # "U"
	oTotDes02:refresh()
EndIf
If Type("oGetSrvSin") # "U"
	oGetSrvSin:oBrowse:SetFocus()
	oGetSrvSin:oBrowse:Refresh()
EndIf
If Type("oGetSrvAna") # "U"
	oGetSrvAna:oBrowse:SetFocus()
	oGetSrvAna:oBrowse:Refresh()
EndIf
If Type("oGetPecAna") # "U"
	oGetPecAna:oBrowse:SetFocus()
	oGetPecAna:oBrowse:Refresh()
EndIf
If Type("oGetPecSin") # "U"
	oGetPecSin:oBrowse:SetFocus()
	oGetPecSin:oBrowse:Refresh()
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array de Entradas                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS9")
dbSetOrder(2)
if dbSeek(xFilial("VS9")+strzero(cParam01,1)+VO1->VO1_NUMOSV)
	aIteParc := {}
	aColsC := {}
	nC := 1
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. alltrim(VS9->VS9_NUMIDE) == VO1->VO1_NUMOSV .and. VS9->VS9_TIPOPE == "O" .and. VS9->VS9_TIPFEC ==  strzero(cParam01,1)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta o aCols da Entrada                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If VS9->(FieldPos("VS9_TIPTEM")) <> 0
			If VS9->VS9_TIPTEM <> VOO->VOO_TIPTEM
				DbSkip()
				Loop
			Endif
		Endif
		If VS9->VS9_TIPPAG == "DP" //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			if !Empty(VS9->VS9_REFPAG)
				cCondic1 := cTod(Substr(VS9->VS9_REFPAG,01,08))
				cCondic2 := Substr(VS9->VS9_REFPAG,09,02)
				cCondic3 := Substr(VS9->VS9_REFPAG,11,02)
				cCondic4 := Substr(VS9->VS9_REFPAG,13,02)
			Endif
		Else
			AADD(aColsC,Array(nUsadoC+1))
			nTotEntr += VS9->VS9_VALPAG
			For _ni:=1 to nUsadoC
				aColsC[Len(aColsC),_ni]:=If(aHeaderC[_ni,10] # "V",FieldGet(FieldPos(aHeaderC[_ni,2])),CriaVar(aHeaderC[_ni,2]))
			Next
			aColsC[Len(aColsC),nUsadoC+1]:=.F.
		Endif
		dbSkip()
	Enddo
	//	aHeader := aClone(aHeaderC)
	//	aCols   := aClone(aColsC)
	//	If Type("oGetCondicao") # "U"
	//		oGetCondicao:oBrowse:refresh()
	//	Endif
Endif
if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
Endif

if Len(aColsC) == 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols da Entrada                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aColsC:={Array(nUsadoC+1)}
	aColsC[1,nUsadoC+1]:=.F.
	For _ni:=1 to nUsadoC
		aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
	Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array de Financiamento                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("VS9")
dbSetOrder(2)
if dbSeek(xFilial("VS9")+strzero(cParam01,1)+VO1->VO1_NUMOSV+"  ODP")
	aIteParc := {}
	Do While !Eof() .and. xFilial("VS9") == VS9->VS9_FILIAL .and. alltrim(VS9->VS9_NUMIDE) == VO1->VO1_NUMOSV .and. VS9->VS9_TIPOPE == "O" .and. VS9->VS9_TIPFEC == strzero(cParam01,1)
		If VS9->(FieldPos("VS9_TIPTEM")) <> 0
			If VS9->VS9_TIPTEM <> VOO->VOO_TIPTEM
				DbSkip()
				Loop
			Endif
		Endif
		If VS9->VS9_TIPPAG == "DP"  //Duplicata
			aAdd(aIteParc, {VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			if !Empty(VS9->VS9_REFPAG)
				cCondic1 := cTod(Substr(VS9->VS9_REFPAG,01,08))
				cCondic2 := Substr(VS9->VS9_REFPAG,09,02)
				cCondic3 := Substr(VS9->VS9_REFPAG,11,02)
				cCondic4 := Substr(VS9->VS9_REFPAG,13,02)
			Endif
		Else
			//			aadd(aIteParc,{VS9->VS9_DATPAG,VS9->VS9_VALPAG})
			nTotEntr += VS9->VS9_VALPAG
		Endif
		dbSkip()
	Enddo
Endif
if Len(aIteParc) == 0
	aIteParc := {{cTod(""),0}}
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se houve CDCI traz codigo e valor combinado                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValorCom := 0
dbSelectArea("VS9")
dbSetOrder(2)
if dbSeek(xFilial("VS9")+strzero(cParam01,1)+VO1->VO1_NUMOSV+"  ")
	Do While !Eof() .and. xFilial("VS9")==VS9->VS9_FILIAL .and. VS9->VS9_TIPOPE==strzero(cParam01,1) .and. VS9->VS9_NUMIDE==VO1->VO1_NUMOSV+"  "
		If VS9->(FieldPos("VS9_TIPTEM")) <> 0
			If VS9->VS9_TIPTEM <> VOO->VOO_TIPTEM
				DbSkip()
				Loop
			Endif
		Endif
		If VS9->VS9_TIPPAG=="CD" // CDCI
			cCodCDCI  := left(alltrim(VS9->VS9_REFPAG)+space(4),4)
			nValorCom += VS9->VS9_VALPAG
		EndIf
		DbSkip()
	EndDo
Endif

// Refaz o ListBox das Parcelas
If Type("oLbParc") # "U"
	oLbParc:SetArray(aIteParc)
	oLbParc:bLine := { || { dToc(aIteParc[oLbParc:nAt,1]),;
	Transform(aIteParc[oLbParc:nAt,2],"999,999,999.99")}}
	oLbParc:Refresh()
EndIf

// Traz forma de pagamento escolhida
dbSelectArea("SE4")
if dbSeek(xFilial("SE4")+VO1->VO1_FORPAG)
	cTipPag := VO1->VO1_FORPAG
	cDesPag := SE4->E4_DESCRI
	If Type("oTipPag") # "U"
		oTipPag:Refresh()
	EndIf
	If Type("oDesPag") # "U"
		oDesPag:Refresh()
	Endif
Endif

lSalvou := .t.

Return

Function FS_SALVA()
Local lRetFech := .t.

// Verifica a situacao do Tipo de Tempo ...
If !FS_VTTPSTAT()
	Return .f.
EndIf
//

if !lSalvou
		FS_SALVANEG()
		MsgInfo(STR0194)
Endif
Return(lRetFech)


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    DELNEG160   ³ Autor ³ Fabio                ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ofiom160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DELNEG160()

Local _Fil  := xFilial("VS9")

dbSelectArea("VSE")
dbSeek(xFilial("VSE")+VO1->VO1_NUMOSV+"  O")
While !Eof() .and. xFilial("VSE") == VSE->VSE_FILIAL .and. alltrim(VSE->VSE_NUMIDE) == alltrim(VO1->VO1_NUMOSV) .and. VSE->VSE_TIPOPE == "O"
	If VSE->(FieldPos("VSE_TIPTEM")) <> 0
		If VSE->VSE_TIPTEM <> VOO->VOO_TIPTEM
			DbSkip()
			Loop
		Endif
	Endif
	if RecLock("VSE",.f.,.t.)
		VSE->(dbDelete())
		MsUnlock()
		WriteSx2("VSE")
	Endif
	dbSkip()
Enddo

dbSelectArea("VS9")
dbSetOrder(2)
dbSeek(xFilial("VS9")+strzero(cParam01,1)+VO1->VO1_NUMOSV)
Do While alltrim(_Fil+VO1->VO1_NUMOSV) == alltrim(VS9_FILIAL+VS9_NUMIDE) .and. !Eof() .and. VS9->VS9_TIPFEC == strzero(cParam01,1)
	If VS9->(FieldPos("VS9_TIPTEM")) <> 0
		If VS9->VS9_TIPTEM <> VOO->VOO_TIPTEM
			DbSkip()
			Loop
		Endif
	Endif
	RecLock("VS9",.F.,.T.)
	dbdelete()
	MsUnlock()
	WriteSx2("VS9")
	dbskip()
Enddo

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³OM160LEG   ³ Autor ³ Fabio                ³ Data ³ 16/02/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ofiom160                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM160LEG()

Local aLegenda  := {	{ 'BR_VERDE'   , STR0166 } ,; // Aberta
{ 'BR_AZUL'    , STR0167 } ,; // Liberada
{ 'BR_VERMELHO', STR0168 } ,; // Fechado
{ 'BR_PRETO'   , STR0169}}    // Cancelado

BrwLegenda(cCadastro,STR0116,aLegenda)  			  //Legenda

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_DESFRANºAutor  ³Fabio               º Data ³  08/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Desconta o valor da franquia no fechamento                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_DESFRAN()

Local aArea := {}, nSalvaAbe := 0

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO2")
aArea := sGetArea(aArea , "VO4")

If VOI->VOI_SEGURO == "1" .And. !Empty(VOI->VOI_TIPFRA)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Franquia de peca esta separada da franquia de servico ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If VOI->(FieldPos("VOI_TPSEGU")) <> 0

		If cParam01 == 1                 		// Fechamento Individual de Ordem de Servico

			FS_LEVFRA2(VO1->VO1_NUMOSV,VOI->VOI_TPSEGU)

		ElseIf cParam01 == 2                 	// Fechamento Agrupado de Ordem de Servico

			//Traz os descontos gravados anteriormente
			For nSalvaAbe := 1 to Len(aVetOsv)
				FS_LEVFRA2(aVetOsv[nSalvaAbe,1],VOI->VOI_TPSEGU)
			Next

		EndIf


	Else

		If cParam01 == 1                 		// Fechamento Individual de Ordem de Servico

			FS_LEVFRAN(VO1->VO1_NUMOSV,VOI->VOI_TIPFRA)

		ElseIf cParam01 == 2                 	// Fechamento Agrupado de Ordem de Servico

			//Traz os descontos gravados anteriormente
			For nSalvaAbe := 1 to Len(aVetOsv)
				FS_LEVFRAN(aVetOsv[nSalvaAbe,1],VOI->VOI_TIPFRA)
			Next

		EndIf

	EndIf
EndIf


&& Volta posicoes originais
sRestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FS_LEVFRA2 ºAutor  ³ Rubens Takahashi º Data ³  06052010   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aplica descontos da Franquia                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cNumOsv = Numero da OS a Ser Fechada                       º±±
±±º          ³ cTpoFranq = Tipo de Tempo de Franquia                      º±±
±±º          ³ cTPSegur = Tipo de Seguro para aplicar descontos           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVFRA2(cNumOsv,cTPSegur)

Local nVlrFranq := 0, nPerPec := 0, nPerSrv := 0, nValDPec := 0, nValDSrv := 0
Local cont := 0, nTot := 0, nPec := 0, nSrv := 0
Local lAplicDesc := .f.

Local cQuery := ""

Default cNumOsv := VO1->VO1_NUMOSV

nTotPec := 0  // Valor das pecas
nTotSrv := 0  // Valor dos servicos
nTotDes := 0  // Valor do Desconto
nTotTTP := 0  // Valor da OS

nTot := nPec := nSrv := 0


//1=Servicos;2=Peças;3=Ambos
// Aplica descontos em SERVICOS ou AMBOS
if cTPSegur == "1" .or. cTPSegur == "3"

	cQuery := "SELECT VO1_FRANQU FROM " + RetSQLName("VO1") + " VO1 WHERE VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1_NUMOSV = '" + cNumOsv + "' AND D_E_L_E_T_ = ' '"
	nVlrFranq := FM_SQL( cQuery )

	If nVlrFranq > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura total de Servicos ... ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For cont := 1 to Len(aColsFEC[3])
			//			nSrv += aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
			nSrv += aColsFEC[3,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]
		Next

		If nVlrFranq >= nSrv

			MsgInfo( STR0185 + Chr(13)+Chr(10); // "Valor da franquia maior do que o valor dos serviços"
			+ STR0186 + STR0069 + " " + Transform( nVlrFranq ,"@E 99,999,999.99")+" "+ ; // "Franquia de Servicos:"
			STR0187 + STR0069 + " " + Transform( nSrv ,"@E 99,999,999.99") , STR0133 ) // "Valor total de Servicos:"

		Else

			lAplicDesc := .t.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma Total de Servicos e Zera Descontos na aCols Sintetica de SERVICOS ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nSrv := 0
			For cont := 1 to Len(aColsFEC[3])
				//				nSrv += aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
				nSrv += aColsFEC[3,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]

				aColsFEC[3,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := 0
				aColsFEC[3,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] := 0
				aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] := 0

			Next

			&& Acha o percentual de servicos/pecas sobre o total
			nValDSrv := nVlrFranq
			nPerSrv  := ( (nValDSrv * 100) / nSrv )

			For cont := 1 to Len(aColsFEC[4])

				If Type("oGetSrvAna") # "U"
					oGetSrvAna:oBrowse:SetFocus()
				EndIf

				nValDSrv := ( aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] * ( nPerSrv / 100 ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza GetDados Analitica de SERVICOS ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := NoRound( nPerSrv ,2 )
				aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := nValDSrv
				aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] - aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]

				nTotDes += nValDSrv
				nTotTTP += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
				nTotSrv += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]

				aCols[cont,FG_POSVAR("VO4_PERDES")] := aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
				aCols[cont,FG_POSVAR("VO4_VALDES")] := aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
				aCols[cont,FG_POSVAR("VO4_VALTOT")] := aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]

				MAFISREF("IT_VALMERC" ,"VO400",aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)])
				MAFISREF("IT_DESCONTO","VO400",nValDSrv)

				If Type("oGetSrvSin") # "U"
					oGetSrvSin:oBrowse:SetFocus()
				EndIf

				M->VO4_TIPSER := aColsFEC[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza GetDados Sintetica de Servicos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ix_ := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == M->VO4_TIPSER })
				If ix_ > 0
					aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] += aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					aColsFEC[3,ix_,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
					aColsFEC[3,ix_,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := NoRound( ((aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] * 100) / aColsFEC[3,ix_,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]) ,2 )

					aCols[ix_,FG_POSVAR("VO4_PERDES")] := aColsFEC[3,ix_,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)]
					aCols[ix_,FG_POSVAR("VO4_VALDES")] := aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)]
					aCols[ix_,FG_POSVAR("VO4_VALTOT")] := aColsFEC[3,ix_,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
				EndIf

			Next

		EndIf

	EndIf
EndIf

// Aplica descontos em PECAS ou AMBOS
if cTPSegur == "2" .or. cTPSegur == "3"

	cQuery := "SELECT VO1_FRANQP FROM " + RetSQLName("VO1") + " VO1 WHERE VO1_FILIAL = '" + xFilial("VO1") + "' AND VO1_NUMOSV = '" + cNumOsv + "' AND D_E_L_E_T_ = ' '"
	nVlrFranq := FM_SQL( cQuery )

	If nVlrFranq > 0

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Procura total de Pecas ...    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For cont := 1 to Len(aColsFEC[1])
			//			nPec += aColsFEC[1,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]
			nPec += aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
		Next

		If nVlrFranq >= nPec

			MsgInfo( STR0188 + Chr(13)+Chr(10); // "Valor da franquia maior do que o valor das pecas"
			+ STR0186 + STR0068 + " " + Transform( nVlrFranq ,"@E 99,999,999.99")+" "+ ; // "Franquia de Pecas"
			STR0187 + STR0068 + " " + Transform( nPec ,"@E 99,999,999.99"), STR0133 )  // "Valor total de Pecas"
		Else

			lAplicDesc := .t.
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Soma Total de Servicos e Zera Descontos na aCols Sintetica de PECAS    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPec := 0
			For cont := 1 to Len(aColsFEC[1])
				//				nPec += aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
				nPec += aColsFEC[1,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]

				aColsFEC[1,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := 0
				aColsFEC[1,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := 0
				aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := 0
			Next

			&& Acha o percentual de servicos/pecas sobre o total
			nValDPec := nVlrFranq
			nPerPec  := ( (nValDPec * 100) / nPec )

			For cont := 1 to Len(aColsFEC[2])

				If Type("oGetPecAna") # "U"
					oGetPecAna:oBrowse:SetFocus()
				EndIf

				nValDPec := ( aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] * ( nPerPec / 100 ) )

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza GetDados Analitica de PECAS    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := NoRound( nPerPec ,2)
				aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := nValDPec
				aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := ( aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] )

				nTotDes += nValDPec
				nTotTTP += aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
				nTotPec += aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

				aCols[cont,FG_POSVAR("VO3_PERDES")] := aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
				aCols[cont,FG_POSVAR("VO3_VALDES")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
				aCols[cont,FG_POSVAR("VO3_VALTOT")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]

				MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]-nValDPec)
				MAFISREF("IT_DESCONTO","VO300",nValDPec)

				If Type("oGetPecSin") # "U"
					oGetPecSin:oBrowse:SetFocus()
				EndIf

				M->VO3_GRUITE := aColsFEC[2,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza GetDados Sintetica de Pecas    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				ix_ := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
				If ix_ > 0

					aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] += nValDPec
					aColsFEC[1,ix_,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := ( aColsFEC[1,ix_,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] - aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] )
					aColsFEC[1,ix_,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := NoRound( ((aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] * 100) / aColsFEC[1,ix_,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]) ,2 )

					aCols[ix_,FG_POSVAR("VO3_PERDES")] := aColsFEC[1,ix_,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)]
					aCols[ix_,FG_POSVAR("VO3_VALDES")] := aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]
					aCols[ix_,FG_POSVAR("VO3_VALTOT")] := aColsFEC[1,ix_,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
				EndIf

			Next

		EndIf

	EndIf

EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Foi aplicado desconto ... ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if lAplicDesc

	If MaFisFound('NF')
		M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
		M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
		//		M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
		M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
		M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")

		If Type("oCabecNF") # "U"
			FG_ATUALOBJ()
		EndIf
	EndIf

	If Type("oTotPec03") # "U"
		oTotPec03:refresh()
	EndIf
	If Type("oTotTTp03") # "U"
		oTotTTp03:refresh()
	EndIf
	If Type("oTotDes03") # "U"
		oTotDes03:refresh()
	EndIf
	If Type("oTotPec02") # "U"
		oTotPec02:refresh()
	EndIf
	If Type("oTotTTp02") # "U"
		oTotTTp02:refresh()
	EndIf
	If Type("oTotDes02") # "U"
		oTotDes02:refresh()
	EndIf
	If Type("oGetSrvSin") # "U"
		oGetSrvSin:oBrowse:SetFocus()
		oGetSrvSin:oBrowse:Refresh()
	EndIf
	If Type("oGetSrvAna") # "U"
		oGetSrvAna:oBrowse:SetFocus()
		oGetSrvAna:oBrowse:Refresh()
	EndIf
	If Type("oGetPecAna") # "U"
		oGetPecAna:oBrowse:SetFocus()
		oGetPecAna:oBrowse:Refresh()
	EndIf
	If Type("oGetPecSin") # "U"
		oGetPecSin:oBrowse:SetFocus()
		oGetPecSin:oBrowse:Refresh()
	EndIf

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LEVFRAN ºAutor  ³Fabio              º Data ³  08/17/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Aplica descontos da Franquia                               º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_LEVFRAN(cNumOsv,cTpoFranq)

Local nVlrFranq := 0, nPerPec := 0, nPerSrv := 0, nValDPec := 0, nValDSrv := 0
Local cont := 0, nTot := 0, nPec := 0, nSrv := 0

Default cNumOsv := VO1->VO1_NUMOSV

DbSelectArea("VO2")
DbSetOrder(1)
If DbSeek( xFilial("VO2") + cNumOsv + "S" )

	DbSelectArea("VO4")
	DbSetOrder(1)
	If DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM + cTpoFranq )
		nVlrFranq := VO4->VO4_VALVEN
	EndIf

	If !Empty(nVlrFranq)

		For cont := 1 to Len(aColsFEC[3])
			nSrv += aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
		Next
		For cont := 1 to Len(aColsFEC[1])
			nPec += aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
		Next
		nTot := ( nPec + nSrv )

		If nVlrFranq >= nTot

			MsgInfo(OemToAnsi( STR0170 +Chr(13)+Chr(10);//Tipo de tempo de seguro com franquia de valor maior que o valor da ordem de servico!
			+ STR0171 +".: "+Transform( nVlrFranq ,"@E 99,999,999.99")+" "+ STR0172 +".: "+Transform( nTot ,"@E 99,999,999.99") ),OemToAnsi(STR0133))//Valor da franquia.: # Valor da OS # Atencao !!!

		Else

			If MsgYesNo(OemToAnsi( STR0173 +Chr(13)+Chr(10); //Tipo de tempo de seguro, deseja descontar o valor da franquia
				+ STR0171 +".: "+Transform( nVlrFranq ,"@E 99,999,999.99") ),OemToAnsi(STR0133))//Valor da franquia # Atencao !!!

				nTotPec := 0  // Valor das pecas
				nTotSrv := 0  // Valor dos servicos
				nTotDes := 0  // Valor do Desconto
				nTotTTP := 0  // Valor da OS

				//Procura descontos de servicos gravados
				nTot := nPec := nSrv := 0
				For cont := 1 to Len(aColsFEC[3])
					nSrv += aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
					aColsFEC[3,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] := 0
					aColsFEC[3,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] := 0
				Next
				For cont := 1 to Len(aColsFEC[1])
					nPec += aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
					aColsFEC[1,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] := 0
					aColsFEC[1,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] := 0
				Next
				nTot := ( nPec + nSrv )

				&& Acha o percentual de servicos/pecas sobre o total
				nPerSrv  := ( (nSrv * 100) / nTot )
				nValDSrv := ( nVlrFranq * ( nPerSrv / 100 ) )
				nPerSrv  := ( (nValDSrv * 100) / nSrv )

				For cont := 1 to Len(aColsFEC[4])

					If Type("oGetSrvAna") # "U"
						oGetSrvAna:oBrowse:SetFocus()
					EndIf

					nValDSrv := ( aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] * ( (aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]+nPerSrv) / 100 ) )

					aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)] := NoRound( (aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]+nPerSrv) ,2)
					aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)] := nValDSrv
					aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)] := aColsFEC[4,cont,FS_POSVAR("VO4_VALBRU","aHeaderFEC",4)] - aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					nTotDes += nValDSrv
					nTotTTP += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
					nTotSrv += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
					aCols[cont,FG_POSVAR("VO4_PERDES")] := aColsFEC[4,cont,FS_POSVAR("VO4_PERDES","aHeaderFEC",4)]
					aCols[cont,FG_POSVAR("VO4_VALDES")] := aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
					aCols[cont,FG_POSVAR("VO4_VALTOT")] := aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
					MAFISREF("IT_VALMERC" ,"VO400",aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)])
					MAFISREF("IT_DESCONTO","VO400",nValDSrv)

					If Type("oGetSrvSin") # "U"
						oGetSrvSin:oBrowse:SetFocus()
					EndIf
					M->VO4_TIPSER := aColsFEC[4,cont,FS_POSVAR("VO4_TIPSER","aHeaderFEC",4)]
					ix_ := aScan(aColsFEC[3],{ |x| x[FS_POSVAR("VO4_TIPSER","aHeaderFEC",3)] == M->VO4_TIPSER })
					If ix_ > 0
						aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] += aColsFEC[4,cont,FS_POSVAR("VO4_VALDES","aHeaderFEC",4)]
						aColsFEC[3,ix_,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)] += aColsFEC[4,cont,FS_POSVAR("VO4_VALTOT","aHeaderFEC",4)]
						aColsFEC[3,ix_,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)] := NoRound( ((aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)] * 100) / aColsFEC[3,ix_,FS_POSVAR("VO4_VALBRU","aHeaderFEC",3)]) ,2 )
						aCols[ix_,FG_POSVAR("VO4_PERDES")] := aColsFEC[3,ix_,FS_POSVAR("VO4_PERDES","aHeaderFEC",3)]
						aCols[ix_,FG_POSVAR("VO4_VALDES")] := aColsFEC[3,ix_,FS_POSVAR("VO4_VALDES","aHeaderFEC",3)]
						aCols[ix_,FG_POSVAR("VO4_VALTOT")] := aColsFEC[3,ix_,FS_POSVAR("VO4_VALTOT","aHeaderFEC",3)]
					EndIf

				Next

				&& Acha o percentual de servicos/pecas sobre o total
				nPerPec  := ( (nPec * 100) / nTot )
				nValDPec := ( nVlrFranq * ( nPerPec / 100 ) )
				nPerPec  := ( (nValDPec * 100) / nPec )

				For cont := 1 to Len(aColsFEC[2])

					If Type("oGetPecAna") # "U"
						oGetPecAna:oBrowse:SetFocus()
					EndIf

					nValDPec := ( aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] * ( (aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]+nPerPec) / 100 ) )

					aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)] := NoRound( (aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]+nPerPec) ,2)
					aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] := nValDPec
					aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)] := ( aColsFEC[2,cont,FS_POSVAR("VO3_VALBRU","aHeaderFEC",2)] - aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)] )
					nTotDes += nValDPec
					nTotTTP += aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
					nTotPec += aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
					aCols[cont,FG_POSVAR("VO3_PERDES")] := aColsFEC[2,cont,FS_POSVAR("VO3_PERDES","aHeaderFEC",2)]
					aCols[cont,FG_POSVAR("VO3_VALDES")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALDES","aHeaderFEC",2)]
					aCols[cont,FG_POSVAR("VO3_VALTOT")] := aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]
					MAFISREF("IT_VALMERC" ,"VO300",aColsFEC[2,cont,FS_POSVAR("VO3_VALTOT","aHeaderFEC",2)]-nValDPec)
					MAFISREF("IT_DESCONTO","VO300",nValDPec)

					If Type("oGetPecSin") # "U"
						oGetPecSin:oBrowse:SetFocus()
					EndIf

					M->VO3_GRUITE := aColsFEC[2,cont,FS_POSVAR("VO3_GRUITE","aHeaderFEC",2)]
					ix_ := aScan(aColsFEC[1],{ |x| x[FS_POSVAR("VO3_GRUITE","aHeaderFEC",1)] == M->VO3_GRUITE })
					If ix_ > 0
						aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] += nValDPec
						aColsFEC[1,ix_,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)] += ( aColsFEC[1,ix_,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)] - aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] )
						aColsFEC[1,ix_,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)] := NoRound( ((aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)] * 100) / aColsFEC[1,ix_,FS_POSVAR("VO3_VALBRU","aHeaderFEC",1)]) ,2 )
						aCols[ix_,FG_POSVAR("VO3_PERDES")] := aColsFEC[1,ix_,FS_POSVAR("VO3_PERDES","aHeaderFEC",1)]
						aCols[ix_,FG_POSVAR("VO3_VALDES")] := aColsFEC[1,ix_,FS_POSVAR("VO3_VALDES","aHeaderFEC",1)]
						aCols[ix_,FG_POSVAR("VO3_VALTOT")] := aColsFEC[1,ix_,FS_POSVAR("VO3_VALTOT","aHeaderFEC",1)]
					EndIf

				Next

				If MaFisFound('NF')
					M->VSF_VTOTNF := MaFisRet(,"NF_TOTAL")
					M->VSF_VALDES := MaFisRet(,"NF_DESCONTO")
					//					M->VSF_DESACE := MaFisRet(,"NF_DESPESA")
					M->VSF_ICMCAL := MaFisRet(,"NF_VALICM")
					M->VSF_ISSCAL := MaFisRet(,"NF_VALISS")

					If Type("oCabecNF") # "U"
						FG_ATUALOBJ()
					EndIf
				EndIf

				If Type("oTotPec03") # "U"
					oTotPec03:refresh()
				EndIf
				If Type("oTotTTp03") # "U"
					oTotTTp03:refresh()
				EndIf
				If Type("oTotDes03") # "U"
					oTotDes03:refresh()
				EndIf
				If Type("oTotPec02") # "U"
					oTotPec02:refresh()
				EndIf
				If Type("oTotTTp02") # "U"
					oTotTTp02:refresh()
				EndIf
				If Type("oTotDes02") # "U"
					oTotDes02:refresh()
				EndIf
				If Type("oGetSrvSin") # "U"
					oGetSrvSin:oBrowse:SetFocus()
					oGetSrvSin:oBrowse:Refresh()
				EndIf
				If Type("oGetSrvAna") # "U"
					oGetSrvAna:oBrowse:SetFocus()
					oGetSrvAna:oBrowse:Refresh()
				EndIf
				If Type("oGetPecAna") # "U"
					oGetPecAna:oBrowse:SetFocus()
					oGetPecAna:oBrowse:Refresh()
				EndIf
				If Type("oGetPecSin") # "U"
					oGetPecSin:oBrowse:SetFocus()
					oGetPecSin:oBrowse:Refresh()
				EndIf

			EndIf

		EndIf

	EndIf

EndIf

Return

Static Function MenuDef()
Local aRotina := {}
if funname() <> "OFIOM160"
	aRotina := {{STR0002,"FS_OM160Pesq",0,1},; 	// Pesquisar
	{STR0003, "OFIM160I"   ,0,4},; 			//Fechar// Incluir
	{STR0116, "OM160LEG"   ,0,10}} 	        //Legenda
Else
	aRotina := {{STR0002,"FS_OM160Pesq",0,1},; 	// Pesquisar
	{STR0003, "OFIM160I"   ,0,4},; 			//Fechar// Incluir
	{STR0116, "OM160LEG"   ,0,10},; 	        //Legenda
	{STR0193, "OM160V"   ,0,1}} 	        //Pesq.Avancada
Endif
Return aRotina

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_VTTPFEC       ³ Andre Luis Almeida    ³ Data ³ 02/03/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se a OS / Tipo de Tempo ja esta Fechado/Cancelado ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VTTPFEC(_cNumOSV,_cTipTem)
Local lRetFech := .t.
Local aArea := {}
aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VO3")
aArea := sGetArea(aArea , "VO4")

_cPecSrv := ""

// Se tiver integrado com o Loja, verifica se ja existe orcamento no Loja
// se encontrar, o TT nao pode ser selecionado para fechamento ...
If Substr(GetMv("MV_LOJAVEI",,"NNN"),2,1) == "S"
	VOO->(dbSetOrder(1))
	If VOO->(dbSeek( xFilial("VOO") + _cNumOSV  + _cTipTem))
		If !Empty( VOO->VOO_PESQLJ )
			SL1->(DbSetOrder(1))
			If SL1->(DbSeek(xFilial("SL1")+VOO->VOO_PESQLJ))
				MsgInfo(STR0189,STR0133)
				lRetFech := .f.
			EndIf
		EndIf
	EndIf
EndIf
//
If lRetFech
	// PECAS //
	DbSelectArea("VO3")
	DbSetOrder(8) // Filial + Numero OS + Tipo de Tempo
	If DbSeek( xFilial("VO3") + _cNumOSV + _cTipTem )
		If !Empty(VO3->VO3_DATCAN)
			MsgInfo(STR0175,STR0133)
			lRetFech := .f.
		Else
			If !Empty(VO3->VO3_DATFEC)
				MsgInfo(STR0176,STR0133)
				lRetFech := .f.
			EndIf
		EndIf
		If lRetFech
			_cPecSrv := "P" // Pecas
		Endif
	EndIf
EndIf
If lRetFech
	// SERVICOS //
	DbSelectArea("VO4")
	DbSetOrder(10) // Filial + Numero OS + Tipo de Tempo
	If DbSeek( xFilial("VO4") + _cNumOSV + _cTipTem )
		If !Empty(VO4->VO4_DATCAN)
			MsgInfo(STR0175,STR0133)
			lRetFech := .f.
		Else
			If !Empty(VO4->VO4_DATFEC)
				MsgInfo(STR0176,STR0133)
				lRetFech := .f.
			EndIf
		EndIf
		If lRetFech
			If "P" $ _cPecSrv
				_cPecSrv := "A" // Ambos
			Else
				_cPecSrv := "S" // Servicos
			Endif
		Endif
	EndIf
EndIf

// Volta posicoes originais
sRestArea(aArea)
Return(lRetFech)

Static Function FS_Fechar16()
Local nTT  := 1
Local nTTF := 1
Local cSelect := alias()
If cParam01 == 1 // Fechamento Individual
	nTT := 0
	For nTTF := 1 to len(aVetTTP)
		If aVetTTP[nTTF,1]
			nTT++
		Endif
	Next
EndIf
If nTT == 0
	Help(" ",1,"M160FALTTP")   // Falta tipo de tempo
	oFolderFec:nOption := 1
	return .f.
Endif

aCols := aClone(aColsC)
aHeader := aClone(aHeaderC)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validar se o campo VOO_DEPTO deve ser informado³
//³Rafael/Manoel - 15/06/2010                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
DbSetOrder(2)
If DbSeek("VOO_DEPTO")
	If x3obrigat("VOO_DEPTO") .and. Empty(cDepVOO)
		Help(1," ","OBRIGAT",,"Codigo do Departamento nao informado.",5,1)  //
		oFolderFec:nOption := 1
		return .f.
	EndIf
EndIF

If _cPecSrv == "P" .or. _cPecSrv == "A"
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("VOO_NATPEC")
		If x3obrigat("VOO_NATPEC") .and. Empty(cVO1_NATURE)
			Help(1," ","OBRIGAT",,"Natureza de Pecas nao informada.",5,1)  //
			oFolderFec:nOption := 1
			return .f.
		EndIf
	EndIF
EndIF

If _cPecSrv == "S" .or. _cPecSrv == "A"
	DbSelectArea("SX3")
	DbSetOrder(2)
	If DbSeek("VOO_NATSRV")
		If x3obrigat("VOO_NATSRV") .and. Empty(cVO1_NATSRV)
			Help(1," ","OBRIGAT",,"Natureza de Servicos nao informada.",5,1)  //
			oFolderFec:nOption := 1
			return .f.
		EndIf
	EndIF
Endif

dbSelectArea(cSelect)
Return(Fs_Fechar())


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Pergunte OF160A                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Static Function FS_VALIDPERG()
//Local cPerg := "OF160A"+space(15)
//dbSelectArea("SX1")
//dbSetOrder(1)
//cPerg := left(cPerg,len(SX1->X1_GRUPO))
////FNC - 6963/2010 - BOBY - 29/03/10
//If dbSeek(cPerg+"02")
//	If SX1->X1_VALID <> "Vazio().or.FG_SEEK('VO1','STRZERO(VAL(MV_PAR02),8)',1,.F.)"
//		dbSelectArea("SX1")
//		If RecLock("SX1",.F.)
//			SX1->X1_VALID := "Vazio().or.FG_SEEK('VO1','STRZERO(VAL(MV_PAR02),8)',1,.F.)"
//			MsUnlock()
//		EndIf
//	EndIf
//Else
//	dbSelectArea("SX1")
//	If RecLock("SX1",.t.)
//		SX1->X1_GRUPO   := cPerg
//		SX1->X1_ORDEM   := "02"
//		SX1->X1_PERGUNT := "Ordem de Servico?"
//		SX1->X1_VARIAVL := "MV_CH2"
//		SX1->X1_TIPO    := "C"
//		SX1->X1_TAMANHO := 8
//		SX1->X1_DECIMAL := 0
//		SX1->X1_PRESEL  := 0
//		SX1->X1_GSC     := "G"
//		SX1->X1_VALID   := "Vazio().or.FG_SEEK('VO1','STRZERO(VAL(MV_PAR02),8)',1,.F.)"
//		SX1->X1_VAR01   := "MV_PAR02"
//		SX1->X1_F3      := "VO1FEC"
//		SX1->X1_PYME    := "S"
//		MsUnlock()
//	EndIf
//EndIf
//Return()

//////////////////////////////////////////////////////////////////////
// VOLTA FILTRO DO VO1  | Andre Luis Almeida / Rubens  | 02/07/2010 //
//////////////////////////////////////////////////////////////////////
Static Function FS_VFILTVO1()
VAI->(dbSetOrder(4))
VAI->(dbSeek(xFilial("VAI")+__cUserID))
If VAI->VAI_TIPTEC == "4"
	DbSelectArea("VO1")
	dbSetOrder(1)
	cCondicao := "VO1->VO1_FUNABE == VAI->VAI_CODTEC"
	FilBrowse('VO1',{},cCondicao) // Filtra Usuario
EndIf 
If cParam01 == 3
	cParam02 := cPar02sv
	cParam03 := cPar03sv
	mv_par01 := cPar02sv
	mv_par02 := cPar03sv
EndIf

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | FS_OBSNF  º Autor ³ Andre Luis Almeida º Data ³ 05/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Observacao para Impressao da NF                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OBSNF()
Local cAliasSLV := Alias()
If VOO->(FieldPos("VOO_OBSMNF")) > 0
	M->VOO_OBSENF := FM_OBSMEM("Observacao na Impressao da NF",VOO->VOO_OBSMNF,"VOO_OBSMNF","VOO_OBSENF",.t.,.t.) // Titulo Janela, Campo Caracter, Nome do Campo Caracter, Campo Memo, Altera (.t./.f.) , Traz Texto existente (.t./.f.)
	If Empty(M->VOO_OBSENF)
		M->VOO_OBSENF := CHR(13)+CHR(10) // Limpar Observacao da NF
	EndIf
	DbSelectArea("VOO")
	M->VOO_OBSMNF := VOO->VOO_OBSMNF
	MSMM(M->VOO_OBSMNF,TamSx3("VOO_OBSENF")[1],,M->VOO_OBSENF,1,,,"VOO","VOO_OBSMNF")
	M->VOO_OBSMNF := VOO->VOO_OBSMNF
	If !Empty(cAliasSLV)
		DbSelectArea(cAliasSLV)
	EndIf
EndIf
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | FS_FIELDOK º Autor ³ Rubens Takahashi  º Data ³ 21/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ FieldOK de GetDados de Pecas Analitica                     º±±
±±º          ³ FieldOK de GetDados de Servicos Sintetica                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FIELDOK()

Local cAuxTES := ""
Local aArea

if ReadVar() == "M->VO3_OPER" .and. FG_POSVAR("VO3_CODTES") <> 0 .and. MaFisFound('NF')

	aArea := sGetArea(aArea,Alias())
	aArea := sGetArea(aArea,"SB1")

	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1")+M->VO3_GRUITE+M->VO3_CODITE)
	cAuxTES := MaTesInt(2,M->VO3_OPER,MaFisRet(,"NF_CODCLIFOR"),MaFisRet(,"NF_LOJA"),"C",SB1->B1_COD)
	If Empty(cAuxTES)
		cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
	Endif
	
	// Valida TES 
	If !OM160CMPTES( aCols[n,FG_POSVAR("VO3_CODTES")] , cAuxTES )
		Return .f.
	EndIf
	//
	
	aCols[n,FG_POSVAR("VO3_CODTES")] := M->VO3_CODTES := cAuxTES
	if SFM->(FieldPos("FM_FORMUL")) > 0  .and. !Empty(SFM->FM_FORMUL)
		M->VO3_FORMUL := SFM->FM_FORMUL
		aCols[n,FG_POSVAR("VO3_FORMUL")] := M->VO3_FORMUL
	endif

	aCols[n,FG_POSVAR("VO3_OPER")] := M->VO3_OPER

	sRestArea( aArea )

	__ReadVar := 'M->VO3_CODTES'
	FS_ADMCPO()

endif

if ReadVar() == "M->VO4_OPER" .and. FG_POSVAR("VO4_CODTES") <> 0 .and. MaFisFound('NF')

	aArea := sGetArea(aArea,Alias())
	aArea := sGetArea(aArea,"SB1")

	dbSelectArea("VOK")
	dbSetOrder(1)
	if !dbSeek(xFilial("VOK")+M->VO4_TIPSER)
		sRestArea( aArea )
		return .t.
	endif

	dbSelectArea("SB1")
	dbSetOrder(7)
	dbSeek(xFilial("SB1") + VOK->VOK_GRUITE + VOK->VOK_CODITE)
	cAuxTES := MaTesInt(2,M->VO4_OPER,MaFisRet(,"NF_CODCLIFOR"),MaFisRet(,"NF_LOJA"),"C",SB1->B1_COD)
	If Empty(cAuxTES)
		cAuxTES := FM_PRODSBZ(SB1->B1_COD,"SB1->B1_TS")
	Endif
	aCols[n,FG_POSVAR("VO4_CODTES")] := M->VO4_CODTES := cAuxTES
	aCols[n,FG_POSVAR("VO4_OPER")] := M->VO4_OPER
	if SFM->(FieldPos("FM_FORMUL")) > 0  .and. !Empty(SFM->FM_FORMUL)
		M->VO4_FORMUL := SFM->FM_FORMUL
		aCols[n,FG_POSVAR("VO4_FORMUL")] := M->VO4_FORMUL
	endif
	sRestArea( aArea )

	__ReadVar := 'M->VO4_CODTES'
	FS_ADMCPO()

endif

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_O160FILºAutor  ³Fabio               º Data ³  11/29/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Filtra browse do fechamento agrupado                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_O160FILMK()

If cParam02 == VOO->VOO_FATPAR .And. cParam03 == VOO->VOO_LOJA

	If ( empty(cParam04) .Or. cParam04 == VOO->VOO_TIPTEM )


		If Empty(VOO->VOO_NUMNFI) .AND. Empty(VOO->VOO_PESQLJ) ;
			.AND. ( VO1->( DbSeek(xFilial('VO1')+VOO->VOO_NUMOSV) ) .And. VO1->VO1_TEMLIB == 'S' .And. VO1->VO1_STATUS $ 'A/D' .And. (Empty(cChassiInt) .Or. VO1->VO1_CHAINT == cChassiInt) )

			Return( .T. )

		ElseIf (Len(aFilMarkBrow) # 0 .And. Ascan(aFilMarkBrow, VOO->(Recno()) ) # 0 )

			Return( .T. )

		EndIf

	EndIf

EndIf

Return( .F. )

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | OM160V     | Autor |  Thiago		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Pesquisa Avancada                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OM160V()
nOpc := 1
OFIOC450()
Return(.t.)


/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Fun‡„o    | FSO16F12   | Autor |  Manoel		          | Data | 19/07/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descri‡„o | Parametros da F12                                            |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FSO16F12
Local xSlvPar01 := Mv_Par01

If !Pergunte("OF160F12",.t.)
	Mv_Par01   := xSlvPar01
	Return()
EndIf

nVerParFat := Mv_Par01
Mv_Par01   := xSlvPar01

Return

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OM160LIBP  | Autor |  Rubens		          | Data | 05/01/12 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Verifica se o TT foi liberado parcialmente                   |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OM160LIBP( cNumOsv , cTipTem )

Local lRetorno := .f.

If VOO->(FieldPos("VOO_LIBVOO")) <= 0
	Return lRetorno
EndIf

cSQL := "SELECT COUNT(*) FROM ( "
cSQL += " SELECT DISTINCT VO3_LIBVOO LIBVOO "
cSQL +=  " FROM " + RetSQLName("VO3") + " VO3"
cSQL += " WHERE VO3_FILIAL = '" + xFilial("VO3") + "' "
cSQL +=   " AND VO3_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cSQL +=   " AND VO3_TIPTEM = '" + cTipTem + "'"
cSQL +=   " AND VO3_DATFEC = '        '"
cSQL +=   " AND VO3_DATCAN = '        '"
cSQL +=   " AND VO3.D_E_L_E_T_ = ' '"
cSQL += " UNION "
cSQL += " SELECT DISTINCT VO4_LIBVOO LIBVOO"
cSQL +=  " FROM " + RetSQLName("VO4") + " VO4"
cSQL += " WHERE VO4_FILIAL = '" + xFilial("VO4") + "'"
cSQL +=  " AND VO4_NUMOSV = '" + VO1->VO1_NUMOSV + "'"
cSQL +=  " AND VO4_TIPTEM = '" + cTipTem + "'"
cSQL +=  " AND VO4_DATFEC = '        '"
cSQL +=  " AND VO4_DATCAN = '        '"
cSQL +=  " AND VO4.D_E_L_E_T_ = ' ' "
cSQL += " ) TEMP"
lRetorno := ( FM_SQL( cSQL ) > 1 )

Return lRetorno
