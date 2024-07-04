#INCLUDE "TMSA430.ch"
#INCLUDE "Protheus.ch"

Static lDelOk    := .F.
Static lTM430GRV := ExistBlock('TM430GRV')
Static lTM430TOK := ExistBlock('TM430TOK')
Static lTM430NOF := ExistBlock("TM430NOF")

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TmsA430  ³ Autor ³Rodrigo de A Sartorio  ³ Data ³01.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Movimento de Veiculos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA430()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA430(cAlias, xAutoCab, xAutoVei, xAutoMot, nOpcAuto)

Local aCores      := {}
Local aRet        := {}
Local aIndex      := {}
Local cCondicao   := ""

Private aAutoCab   := {}
Private aItensVei  := {}
Private aItemsMot  := {}
Private l430Auto   := xAutoCab <> NIL  .And. (xAutoVei <> NIL .Or. xAutoMot <> NIL)
Private lMotorista := (Valtype(cAlias) == "C" .And. cAlias == "DTO")
Private cStatus1   := "1" // Em Aberto
Private cStatus2   := "2" // Liberado
Private cStatus3   := "3" // Reservado
Private cCadastro  := If(lMotorista,STR0001,STR0002) //"Movimento de Motoristas"###"Movimento de Veiculos"
Private lBaixa     := .F.
Private cVeiGen    := AllTrim(GetMv("MV_VEIGEN",.F.,""))
Private cMotGen    := AllTrim(GetMv("MV_MOTGEN",.F.,""))
Private bFiltraBrw := {|| Nil}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva as variaveis utilizadas na GetDados Anterior.    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SaveInter()

Private aRotina	:= MenuDef()

Default xAutoCab   := {}
Default xAutoVei   := {}
Default xAutoMot   := {}

Aadd(aCores,{If(lMotorista,"DTO","DTU")+"_STATUS=='1'",'BR_AMARELO'	}) // Em aberto
Aadd(aCores,{If(lMotorista,"DTO","DTU")+"_STATUS=='2'",'BR_VERDE'		}) // Liberado
Aadd(aCores,{If(lMotorista,"DTO","DTU")+"_STATUS=='3'",'BR_AZUL'		}) // Reservado
Aadd(aCores,{If(lMotorista,"DTO","DTU")+"_STATUS=='4'",'BR_VERMELHO'	}) // Baixado

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(IIf(lMotorista,"DTO","DTU"))

If !l430Auto
	If  ! ParamBox({{ 2, STR0016, 2, {STR0017,STR0018},50,'',.T.}},cCadastro,@aRet) //'Entradas ja Baixadas'###'1 - Sim'###'2 - Nao'
		Return NIL
	EndIf

	aRet[1] := If( (ValType(aRet[1]) == 'N'), Str( aRet[1], 1 ), aRet[1] )

	lBaixa := (Left(aRet[1],1)=='1')
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lMotorista
		If Empty(cVeiGen)
			cVeiGen := Space(TamSX3("DTU_CODVEI")[1])
		EndIf
		cCondicao := ' DTU->DTU_FILIAL == "' + xFilial("DTU") + '" .And. '
		If !lBaixa
			cCondicao += 'DTU->DTU_STATUS <> "4" .And. '
		EndIf
		cCondicao += '(!( AllTrim(DTU->DTU_CODVEI) == "' + cVeiGen + '" .And. DTU->DTU_STATUS == "1" ) .Or. '
		cCondicao += '  ( AllTrim(DTU->DTU_CODVEI) <> "' + cVeiGen + '" .And. DTU->DTU_STATUS == "1" ) )'
	Else
		If Empty(cMotGen)
			cMotGen := Space(TamSX3("DTO_CODMOT")[1])
		EndIf
		cCondicao := ' DTO->DTO_FILIAL == "' + xFilial("DTO") + '" .And. '
		If !lBaixa
			cCondicao += 'DTO->DTO_STATUS <> "4" .And. '
		EndIf
		cCondicao += '(!( AllTrim(DTO->DTO_CODMOT) == "' + cMotGen + '" .And. DTO->DTO_STATUS == "1" ) .Or. '
		cCondicao += '  ( AllTrim(DTO->DTO_CODMOT) <> "' + cMotGen + '" .And. DTO->DTO_STATUS == "1" ) )'
	EndIf

	//-- Realiza o filtro
	bFiltraBrw := {|| FilBrowse(If(lMotorista,"DTO","DTU"), @aIndex, cCondicao)}
	Eval(bFiltraBrw)

	dbSetOrder(3)
	mBrowse( 6,1,22,75,If(lMotorista,"DTO","DTU"),,,,,,aCores)

	//-- Restaura a integridade
	dbSelectArea(If(lMotorista,"DTO","DTU"))
	RetIndex(If(lMotorista,"DTO","DTU"))
	dbClearFilter()
	aEval(aIndex,{|x| Ferase(x[1]+OrdBagExt())})
Else
	lMsHelpAuto := .T.

	aAutoCab   := xAutoCab
	aItensVei  := xAutoVei
	aItensMot  := xAutoMot

	MBrowseAuto(nOpcAuto,Aclone(aAutoCab),If(lMotorista,"DTO","DTU"),,.T.)
EndIf

RestInter()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA430Leg³ Autor ³ Rodrigo de A. Sartorio³ Data ³01.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Exibe a legenda do status da Entrada de Motoristas.        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA430Leg()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA430Leg()

BrwLegenda( cCadastro, STR0009 ,; //"Status"
			{	{ "BR_AMARELO" , STR0010},; //"Em Aberto"
				{ "BR_VERDE"   , STR0011},; //"Liberado"
				{ "BR_AZUL"    , STR0012},; //"Reservado"
				{ "BR_VERMELHO", STR0013}}) //"Baixado"
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA430Mnt³ Autor ³Rodrigo de A. Sartorio ³ Data ³01.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua manutencoes.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA430Mnt()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA430Mnt( cAlias, nRecno, nOpc )

Local nOpca     := 0
Local lGravaOk  := .F.
Local nMaximoLinhas := 0
Local bSeekFor  := {}
Local oEnchoice
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura variaveis do Objeto Folder                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aPages    := {"HEADER","HEADER"}
Local aTitles   := {"&" + STR0014,"&" + STR0015} //"&Veiculos"###"&Motoristas"
Local aSize     := {}
Local aObjects  := {}
Local aInfo     := {}
Local aPosObj   := {}
Local aVisual   := {}
Local aYesFields:= {}
Local aPosGetD  := {}
Local aButtons  := {}
Local aAreaDTO  := DTO->(GetArea())
Local aAreaDTU  := DTU->(GetArea())
Local cSeek     := ""
Local bWhile    := {|| .T.}
Local lContVei  := GetMV('MV_CONTVEI',,.T.)
Local nCntFor   := 0
Local aNoFields := {}
Local aCampos   := {}

Private aColsOri1   := {}
Private aColsOri2   := {}
Private aDadoRegMot := {}
Private aHeader     := {}
Private aCols       := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ aSvFolder[ n, 1 ] = aHeader                                               ³
//³ aSvFolder[ n, 2 ] = aCols                                                 ³
//³ aSvFolder[ n, 3 ] = Nr da linha da GetDados da pasta atual, variavel n    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aSvFolder := {}
Private aTela[0][0],aGets[0]
Private o1Get, o2Get,oDlg
Private nPosVei:=0,nPosOdo:=0,nPosModVei:=0,nPosTipVei:=0,nPosMot:=0,nPosNomMot:=0
Private nOpcx:=nOpc,bAddOri1:="",bDelOri1:="",bAddOri2:="",bDelOri2:=""

Private lEntrada   := ( nOpc == 3 )
Private lLiberacao := ( nOpc == 4 )

If !lContVei
	Help("", 1,'TMSA43040') //'A Rotina de Movimentacao de Veiculos / Motoristas esta desativada. Verifique o parametro MV_CONTVEI.'
	Return .T. 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Identifica a consulta de veiculos e motoristas                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc == 5
	aButtons := {{'CARGA',{|| TMSA430Con(1,nOpc,n) },STR0014},{'BMPUSER',{|| TMSA430Con(2,nOpc,n)},STR0015}} //"Veiculos"###"Motoristas"
ElseIf nOpc == 4
	aButtons := {{'WEB',{|| TA430RegMot(@aSvFolder,N,nOpc,oFolder) }, STR0025 , STR0030 },{'CARGA',{|| TMSA430Con(1,nOpc,n) },STR0014},{'BMPUSER',{|| TMSA430Con(2,nOpc,n)},STR0015}} //"Veiculos"###"Motoristas" //"Regiões por Motorista"
ElseIf nOpc == 2
	aButtons := {{'WEB',{|| TA430RegMot(@aSvFolder,N,nOpc,oFolder) }, STR0025 , STR0030}} //"Regioes por Motorista"
EndIf

If nOpc == 4 .Or. nOpc == 5 // Liberacao ou Saida.
	If !TA430MovOk( nOpc, cAlias )
		Return Nil
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria ou carregas as variaveis de memoria.                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos para visualizacao na Enchoice.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lMotorista
	//-- Se ja foi apontada a Saida do motorista (Status:Baixado), nao sera permitido efetuar o estorno desta saida.
	//-- Ou seja, devera' ser efetuado novamente a entrada do motorista na filial; Isto tem que ser feito para evitar
	//-- problemas com a Saida Prevista / Saida Eventual do motorista na mesma Filial
	If nOpc == 6
		If DTO->DTO_STATUS == StrZero(4, Len(DTO->DTO_STATUS)) //-- Estorno
			Help("", 1,'TMSA43041') //'Nao sera permitido efetuar o estorno de um movimento ja baixado. Efetue a Entrada do motorista novamente ...'
			Return (.F.)
		Endif
		//-- Verifica se existem documentos na viagem com ocorrencias informadas.
		If !TMSA350Oco(DTO->DTO_FILVGE,DTO->DTO_NUMVGE)
			Help("", 1,'TMSA35014') //"Existem documentos na viagem com ocorrências informadas"
			Return (.F.)
		EndIf
	EndIf
	RegToMemory("DTO",nOpc # 2 .And. nOpc # 6 .And. nOpc # 8)
	If nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 8
		Aadd(aVisual, "DTO_NUMENT")
		Aadd(aVisual, "DTO_DATENT")
		Aadd(aVisual, "DTO_HORENT")

		If nOpc == 2 .Or. nOpc == 6 .Or. nOpc == 8
			Aadd(aVisual, "DTO_DATLIB")
			Aadd(aVisual, "DTO_HORLIB")
			Aadd(aVisual, "DTO_DATSAI")
			Aadd(aVisual, "DTO_HORSAI")
		EndIf

	ElseIf nOpc == 4
		Aadd(aVisual, "DTO_NUMLIB")
		Aadd(aVisual, "DTO_DATLIB")
		Aadd(aVisual, "DTO_HORLIB")
	EndIf

	If nOpc # 4
		Aadd(aVisual, "DTO_FILORI")
		Aadd(aVisual, "DTO_VIAGEM")
		If nOpc == 5
			Aadd(aVisual, "DTO_DATSAI")
			Aadd(aVisual, "DTO_HORSAI")
		EndIf
		If nOpc == 2 .Or. nOpc == 6 .Or. nOpc == 8
			If DTO->DTO_STATUS == StrZero(4, Len(DTO->DTO_STATUS)) //Baixado
				M->DTO_FILORI := DTO->DTO_FILVGS
				M->DTO_VIAGEM := DTO->DTO_NUMVGS
			Else
				M->DTO_FILORI := DTO->DTO_FILVGE
				M->DTO_VIAGEM := DTO->DTO_NUMVGE
			EndIf
		EndIf
	EndIf
Else

	//-- Se ja foi apontada a Saida do veiculo (Status:Baixado), nao sera permitido efetuar o estorno desta saida.
	//-- Ou seja, devera' ser efetuado novamente a entrada do veiculo na filial; Isto tem que ser feito para evitar
	//-- problemas com a Saida Prevista / Saida Eventual do veiculo na mesma Filial
	If nOpc == 6 
		If DTU->DTU_STATUS == StrZero(4, Len(DTU->DTU_STATUS)) //-- Estorno
			Help("", 1,"TMSA43030") //"Nao sera permitido efetuar o estorno de um movimento ja baixado. Efetue a Entrada do veiculo novamente."
			Return(.F.)
		EndIf
		//-- Verifica se existem documentos na viagem com ocorrencias informadas.
		If DTU->DTU_STATUS <> StrZero(2, Len(DTU->DTU_STATUS)) .And. !TMSA350Oco(DTU->DTU_FILVGE,DTU->DTU_NUMVGE)
			Help("", 1,'TMSA35014') //"Existem documentos na viagem com ocorrências informadas"
			Return (.F.)
		EndIf
	EndIf

	RegToMemory("DTU",nOpc # 2 .And. nOpc # 6 .And. nOpc # 8)
	If nOpc == 2 .Or. nOpc == 3 .Or. nOpc == 6 .Or. nOpc == 8
		Aadd(aVisual, "DTU_NUMENT")
		Aadd(aVisual, "DTU_DATENT")
		Aadd(aVisual, "DTU_HORENT")

		If nOpc == 2 .Or. nOpc == 6 .Or. nOpc == 8
			Aadd(aVisual, "DTU_DATLIB")
			Aadd(aVisual, "DTU_HORLIB")
			Aadd(aVisual, "DTU_DATSAI")
			Aadd(aVisual, "DTU_HORSAI")
		EndIf

	ElseIf nOpc == 4
		Aadd(aVisual, "DTU_NUMLIB")
		Aadd(aVisual, "DTU_DATLIB")
		Aadd(aVisual, "DTU_HORLIB")
	EndIf
	If nOpc # 4
		If nModulo <> 39 //-- Frete Embarcador
			Aadd(aVisual, "DTU_FILORI")
			Aadd(aVisual, "DTU_VIAGEM")
		EndIf
		If nOpc == 5 .Or. nOpc == 6 .Or. nOpc == 8
			Aadd(aVisual, "DTU_DATSAI")
			Aadd(aVisual, "DTU_HORSAI")
			If nOpc == 2 .Or. nOpc == 6
				If DTU->DTU_STATUS == StrZero(4, Len(DTU->DTU_STATUS)) //Baixado
					M->DTU_FILORI := DTU->DTU_FILVGS
					M->DTU_VIAGEM := DTU->DTU_NUMVGS
				Else
					M->DTU_FILORI := DTU->DTU_FILVGE
					M->DTU_VIAGEM := DTU->DTU_NUMVGE
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader e aCols.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos para visualizacao na GetDados.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aYesFields:={"DTU_CODVEI","DTU_MODVEI","DTU_TIPVEI","DTU_PLACA"}
If nModulo <> 39 //-- Frete Embarcador
	If nOpc == 2 .Or. nOpc == 6 
		AADD(aYesFields,"DTU_ODOENT")
		AADD(aYesFields,"DTU_ODOSAI")
	ElseIf nOpc == 3
		AADD(aYesFields,"DTU_ODOENT")
	ElseIf nOpc == 5
		AADD(aYesFields,"DTU_ODOENT")
		AADD(aYesFields,"DTU_ODOSAI")
	EndIf
EndIf

If lTM430NOF
	aCampos := ExecBlock("TM430NOF",.F.,.F.,nOpc)
	If ValType(aCampos) == 'A'
		aNoFields := aClone(aCampos)
	EndIf
EndIf

Aadd(aNoFields,"DTU_NUMENT")
Aadd(aNoFields,"DTU_DATENT")
Aadd(aNoFields,"DTU_HORENT")
Aadd(aNoFields,"DTU_FILORI")
Aadd(aNoFields,"DTU_VIAGEM")
Aadd(aNoFields,"DTU_FROVEI")
Aadd(aNoFields,"DTU_DATLIB")
Aadd(aNoFields,"DTU_HORLIB")
Aadd(aNoFields,"DTU_FILVGS")
Aadd(aNoFields,"DTU_NUMVGS")
Aadd(aNoFields,"DTU_DATSAI")
Aadd(aNoFields,"DTU_HORSAI")
Aadd(aNoFields,"DTU_ODOSAI")
If nModulo == 39 //-- Frete Embarcador
	Aadd(aNoFields,"DTU_ODOENT")
EndIf

If If( lMotorista, !Empty( M->DTO_NUMLIB), !Empty( M->DTU_NUMLIB) )
	cSeek  := xFilial("DTU")+If(lMotorista,M->DTO_NUMLIB,M->DTU_NUMLIB)
	bWhile := { || DTU->(DTU_FILIAL + DTU_NUMLIB)}
	nOrdem := 4
Else
	cSeek  := xFilial("DTU")+If(lMotorista,M->DTO_NUMENT,M->DTU_NUMENT)
	bWhile := { || DTU->(DTU_FILIAL + DTU_NUMENT)}
	nOrdem := 1
EndIf
bSeekFor := {|| .T. }
TMSFillGetDados(nOpc, "DTU", nOrdem, cSeek, bWhile, bSeekFor ,aNoFields, aYesFields)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa aSvFolder e Carrega variaveis para pasta Parceria               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aSvFolder,{ACLONE(aHeader),ACLONE(aCols),1})
aColsOri1:=ACLONE(aCols)
nPosVei  :=GdFieldPos('DTU_CODVEI')
If nOpc == 3
	nPosOdo :=GdFieldPos('DTU_ODOENT')
ElseIf nOpc == 5
	nPosOdo :=GdFieldPos('DTU_ODOSAI')
EndIf
nPosModVei:=GdFieldPos('DTU_MODVEI')
nPosTipVei:=GdFieldPos('DTU_TIPVEI')
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o aHeader e aCols.                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define os campos para visualizacao na GetDados.                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader:={};aCols:={}
aYesFields:={"DTO_CODMOT","DTO_NOMMOT"}
aNoFields :={}

If nModulo <> 39 //-- Frete Embarcador
	If nOpc == 3
		AAdd(aYesFields,"DTO_CRACHA")
	ElseIf nOpc == 4
		AAdd(aYesFields,"DTO_LIBSEG")
		AAdd(aYesFields,"DTO_VALSEG")
	EndIf
EndIf

If If( lMotorista, !Empty( M->DTO_NUMLIB), !Empty( M->DTU_NUMLIB) )
	cSeek  := xFilial("DTO")+If(lMotorista,M->DTO_NUMLIB,M->DTU_NUMLIB)
	bWhile := { || DTO->(DTO_FILIAL + DTO_NUMLIB)}
	nOrdem := 4
Else
	cSeek  := xFilial("DTO")+If(lMotorista,M->DTO_NUMENT,M->DTU_NUMENT)
	bWhile := { || DTO->(DTO_FILIAL + DTO_NUMENT)}
	nOrdem := 1
EndIf
TMSFillGetDados(nOpc, "DTO", nOrdem, cSeek, bWhile, bSeekFor ,aNoFields, aYesFields, .T.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa aSvFolder e Carrega variaveis para pasta Parceria               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aSvFolder,{ACLONE(aHeader),ACLONE(aCols),1})
aColsOri2:=ACLONE(aCols)
nPosMot:=GdFieldPos('DTO_CODMOT')
nPosNomMot:=GdFieldPos('DTO_NOMMOT')

nMaximoLinhas := If( nOpc == 2, Len(aCols) , 99)

If !l430Auto
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Calcula as dimensoes dos objetos.                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aSize := MsAdvSize()
	AAdd( aObjects, { 100,040,.T.,.T. } )
	AAdd( aObjects, { 100,100,.T.,.T.,.T. } )
	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects,.T. )

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	oEnchoice := MsMGet():New(If(lMotorista,"DTO","DTU"),nRecno,nOpc,,,, aVisual,aPosObj[1],,3,,,,,,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o Objeto Folder                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:=TFolder():New( aPosObj[2,1],aPosObj[2,2],aTitles,aPages,oDlg,,,,.T.,.T.,aPosObj[2,3],aPosObj[2,4])
	aPosGetD := { 5, 5, aPosObj[ 2, 4 ] - 18, aPosObj[ 2, 3 ] - 8 }
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Consistencia a cada mudanca de pasta do Objeto Folder                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oFolder:bSetOption:={|nAtu| TA430Muda(nAtu,oFolder:nOption,oDlg)}
	For nCntFor := 1 To Len(oFolder:aDialogs)
		oFolder:aDialogs[nCntFor]:oFont := oDLg:oFont
	Next nCntFor
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder Motorista                                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader	:={};aCols	:={}
	aHeader	:= aClone(aSvFolder[2,1])
	aCols	:= aClone(aSvFolder[2,2])
	n		:= 1
	o2Get:=MSGetDados():New(aPosGetD[1],aPosGetD[2],aPosGetD[3],aPosGetD[4],nOpc,"TA430LinOK","AllWaysTrue",,.T.,,,,nMaximoLinhas,,,,"TA430DelOk",oFolder:aDialogs[2])
	o2Get:oBrowse:Default()
	o2Get:oBrowse:lDisablePaint := .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Folder Veiculo                                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader 	:={}
	aCols		:={}
	aHeader 	:= aClone(aSvFolder[1,1])
	aCols		:= aClone(aSvFolder[1,2])
	n			:= 1
	o1Get:=MSGetDados():New(aPosGetD[1],aPosGetD[2],aPosGetD[3],aPosGetD[4],nOpc,"TA430LinOK","AllWaysTrue",,.T.,,,,nMaximoLinhas,,,,"TA430DelOk",oFolder:aDialogs[1])
	o1Get:oBrowse:Default()
	o1Get:oBrowse:lDisablePaint := .F.
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(o1Get:TudoOK() .And. o2Get:TudoOK() .And. TA430TOK() .And. TA430Ok(nOpc),(nOpca:=1,oDlg:End()),nOpca:=0) },{||oDlg:End()},,aButtons)
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols contendo os dados do Veiculo                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aClone(aSvFolder[1,1])
	MsGetDAuto(aItensVei,,{|| .T.} ,aAutoCab)
	aSvFolder[1,1] := AClone(aHeader)
	aSvFolder[1,2] := AClone(aCols)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta o aCols contendo os dados do Motorista                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader := aClone(aSvFolder[2,1])
	MsGetDAuto(aItensMot,,{|| .T.} ,aAutoCab)
	aSvFolder[2,1] := AClone(aHeader)
	aSvFolder[2,2] := AClone(aCols)

	//-- Valida a Enchoice
	If EnchAuto(cAlias,aAutoCab,,,aVisual,{|| Obrigatorio(aGets,aTela)})

		aHeader  := aClone(aSvFolder[1,1])
		aCols	 := aClone(aSvFolder[1,2])
		//-- Executa a Funcao de LinhaOk() e TudoOK() para validar os dados da Pasta de Veiculos
		For nCntFor := 1 to Len(aCols)
			n := nCntFor
			lRet:= TA430LinOk(,,1) .And. TA430TOk(1)
			If !lRet
				Exit
			EndIf
		Next nCntFor

		If lRet
			aHeader := aClone(aSvFolder[2,1])
			aCols	:= aClone(aSvFolder[2,2])
			//-- Executa a Funcao de LinhaOk() e TudoOK() para validar os dados da Pasta de Motoristas
			For nCntFor:= 1 to Len(aCols)
				n := nCntFor
				lRet := TA430LinOk(,,2) .And. TA430TOk(2)
				If !lRet
					Exit
				EndIf
			Next nCntFor
		EndIf

		If lRet
			nOpca := 1
		EndIf
		
	EndIf
EndIf

If nOpca == 1 .And. nOpc != 2
	CursorWait()
	lGravaOk := TmsA430Grv(nOpc,aVisual)
	CursorArrow()
	If __lSX8 .And. lGravaOk
		ConfirmSX8()
	EndIf
ElseIf __lSX8
	While (GetSx8Len() > 0)
		RollBackSX8()
	EndDo
EndIf

If nOpc == 4 .Or. nOpc == 5 // Liberacao ou Saida.
	TA430MovOk( nOpc, cAlias, .T. )
EndIf

If nOpc == 8  .And. nOpca == 1 // Exclusao
	TA430Excl(cAlias)
EndIf

RestArea(aAreaDTO)
RestArea(aAreaDTU)

//-- Na Saida de Veiculos, quando nao apresentar os lancamentos baixados, posiciona no primeiro registro.
If !lBaixa .And. nOpca == 1 .And. nOpc == 5
	If lMotorista
		DTO->(MsSeek(xFilial("DTO")))
	Else
		DTU->(MsSeek(xFilial("DTU")))
	EndIf
EndIf

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430Muda ³ Autor ³Rodrigo de A. Sartorio ³ Data ³02.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa a mudanca de pasta no Objeto Folder                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430Muda(ExpN1,ExpN2,ExpO1)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero do Folder que se deseja ir. Se igual a zero ³±±
±±³          ³         foi chamado da funcao At250TudOk, apenas para      ³±±
±±³          ³         atualizar o vetor aSvFolder.                       ³±±
±±³          ³ ExpN2 = Numero do Folder que estou                         ³±±
±±³          ³ Exp01 = Dialog                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA430Muda(nIndo,nEstou,oDlg)

Local lRet:=.T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Valida a linha antes de mudar o Folder                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
lRet := TA430LinOk(NIL,.T.)
If lRet
	If nEstou == 1
		o1Get:oBrowse:lDisablePaint := .T.
		// Atualiza matriz atraves do aCols alterado
		aSvFolder[1][1]:= Aclone(aHeader)
		aSvFolder[1][2]:= Aclone(aCols)
		aSvFolder[1][3]:= Len(aCols)
	ElseIf nEstou == 2
		o2Get:oBrowse:lDisablePaint := .T.
		// Atualiza matriz atraves do aCols alterado
		aSvFolder[2][1]:= Aclone(aHeader)
		aSvFolder[2][2]:= Aclone(aCols)
		aSvFolder[2][3]:= Len(aCols)
	EndIf
	If	nIndo == 1
		o1Get:oBrowse:nAt	:= 1
		// Atualiza aHeader e aCols com dados
		aHeader	:={}
		aCols	:={}
		aHeader := Aclone(aSvFolder[1,1])
		aCols	:= Aclone(aSvFolder[1,2])
		n		:= Len(aCols)
		// Refresh na tela
		o1Get:oBrowse:lDisablePaint := .F.
		o1Get:oBrowse:Refresh(.T.)
		o1Get:ForceRefresh()
		oDlg:Refresh()
	ElseIf nIndo == 2
		o2Get:oBrowse:nAt	:= 1
		// Atualiza aHeader e aCols com dados
		aHeader	:={}
		aCols	:={}
		aHeader := Aclone(aSvFolder[2,1])
		aCols	:= Aclone(aSvFolder[2,2])
		n		:= Len(aCols)
		// Refresh na tela
		o2Get:oBrowse:lDisablePaint := .F.
		o2Get:oBrowse:Refresh(.T.)
		o2Get:ForceRefresh()
		oDlg:Refresh()
	EndIf
	oFolder:Refresh(.T.)
	nEstou := nIndo
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430Viage³ Autor ³ Rodrigo de A. Sartorio³ Data ³02.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a viagem digitada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430Viage()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA430Viage()

Local lRet       := .T.
Local cCampo     := UPPER(Alltrim(ReadVar()))
Local cFilOri    := If(cCampo$"DTO_FILORI/DTU_FILORI",&(ReadVar()),If(lMotorista,M->DTO_FILORI,M->DTU_FILORI))
Local cViagem    := If(cCampo$"DTO_VIAGEM/DTU_VIAGEM",&(ReadVar()),If(lMotorista,M->DTO_VIAGEM,M->DTU_VIAGEM))
Local aArea      := GetArea(),aSoma:={},aSoma2:={}
Local nz         := 0
Local aEmptyPar  := {}
Local nA         := 0
Local cTes       := GetMV("MV_TESDR" ,,"")
Local aAreaDTQ   := {}
Local aAreaDTR   := {}
Local cAtividade := ''
Local cAtivCHG   := GetMv("MV_ATIVCHG",,'') // Atividade de Chegada.
Local cAtivSAI   := GetMv("MV_ATIVSAI",,'') // Atividade de Saida.
Local cAtivRTA   := GetMv("MV_ATIVRTA",,'') // Atividade de Retorno de Aeroporto
Local cAtivRTP   := GetMv("MV_ATIVRTP",,'') // Atividade de Retorno de Porto
Local cAtivRDP   := GetMv("MV_ATIVRDP",,'') // Atividade de Saida para Retirada no Porto
Local lTercRbq   := DTR->(ColumnPos("DTR_CODRB3")) > 0

//-- Verifica a Atividade que sera realizada
If nOpcx == 3
	cAtividade := cAtivCHG
	If cFilOri == cFilAnt
		If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))
			cAtividade := cAtivRTA
		ElseIf DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA))
			cAtividade := cAtivRTP
		EndIf
	EndIf
Else
	cAtividade := cAtivSAI
	If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And.;
		DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And.;
		DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
		cAtividade := cAtivRDP
	EndIf
EndIf

// Limpa as linhas das GETDADOS quando a viagem nao for informada
// utilizando para isso os arrays com o ACOLS ORIGINAL - VAZIO
If Empty(cViagem)
	If  !l430Auto
		// Seta os campos que podem ser alterados quando a viagem for BRANCO
		o2Get:aAlter := NIL
		If !Empty(bAddOri2) .And. !Empty(bDelOri2)
			o2Get:oBrowse:bADD   := bAddOri2
			o2Get:oBrowse:bDelete:= bDelOri2
		EndIf
		// Efetua refresh para setar propriedades
		o2Get:oBrowse:lDisablePaint := .F.
		o2Get:oBrowse:Refresh(.T.)
		o2Get:ForceRefresh()
		// Seta os campos que podem ser alterados quando a viagem for BRANCO
		o1Get:aAlter         := NIL
		If !Empty(bAddOri1) .And. !Empty(bDelOri1)
			o1Get:oBrowse:bADD   := bAddOri1
			o1Get:oBrowse:bDelete:= bDelOri1
		EndIf
		// Efetua refresh para setar propriedades
		If oFolder:nOption == 1
			o1Get:oBrowse:lDisablePaint := .F.
			o1Get:oBrowse:Refresh(.T.)
			o1Get:ForceRefresh()
		ElseIf oFolder:nOption == 2
			o2Get:oBrowse:lDisablePaint := .F.
			o2Get:oBrowse:Refresh(.T.)
			o2Get:ForceRefresh()
		EndIf
		oDlg:Refresh()
		oFolder:Refresh(.T.)
	EndIf
Else
	// Valida existencia da VIAGEM
	DTQ->(dbSetOrder(2))
	If !DTQ->(dbSeek(xFilial("DTQ")+cFilOri+cViagem))
		Help(" ",1,"TMSA43007") //"A viagem informada não foi encontrada"
		A430ZerViag()
		Return( .F. )
	EndIf
	// Valida Status da viagem
	If lRet
		If nOpcx == 3 // Entrada
			If DTQ->DTQ_STATUS != StrZero( 2, Len( DTQ->DTQ_STATUS ))
				Help(" ",1,"TMSA43001") //A Viagem informada não está fechada ou encerrada, portanto não pode ser utilizada.
				A430ZerViag()
				Return( .F. )
			EndIf

			If DTQ->DTQ_SERTMS == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) //-- Transporte
				SF4->( DbSetOrder( 1 ) )
				If	SF4->( ! MsSeek( xFilial('SF4') + cTes, .F. ) )
					Help( ' ', 1, 'TMSA20015',, " TES : "+ cTes,5,11)	 //"Tipo de entrada/saida informado no parametro MV_TESDR nao encontrado (SF4).
					A430ZerViag()
					Return( .F. )
				EndIf

				If	SF4->F4_TIPO != 'E'
					Help( ' ', 1, 'TMSA20016',, " TES : " + cTes,5,11)	//"Tipo de entrada/saida informado no parametro MV_TESDR nao eh um TES de entrada (SF4).
					A430ZerViag()
					Return( .F. )
				EndIf

				If DTQ->DTQ_TIPTRA == StrZero( 2, Len( DTQ->DTQ_SERTMS ) ) .And. ;
					DTQ->DTQ_FILORI <> cFilAnt
					Help("",1,"TMSA43034") //A Entrada da Viagem Aerea devera ser feita somente na Filial de Origem da Viagem.
					A430ZerViag()
					Return .F.
				EndIf

				If DTQ->DTQ_TIPTRA == StrZero( 3, Len( DTQ->DTQ_SERTMS ) ) .And. ;
					DTQ->DTQ_FILORI <> cFilAnt
					Help("",1,"TMSA43042") //A Entrada da Viagem Fluvial devera ser feita somente na Filial de Origem da Viagem.
					A430ZerViag()
					Return .F.
				EndIf
			EndIf

		Else // Saida
			If DTQ->DTQ_STATUS != StrZero( 5, Len( DTQ->DTQ_STATUS ) ) .And. cAtividade <> cAtivRDP
				Help(" ",1,"TMSA43019") // Saida permitida somente para viagens fechadas
				A430ZerViag()
				Return( .F. )
			EndIf

			//-- Verifica se todas viagens interligadas estao fechadas
			DTR->(DbSetOrder(2))
			If DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem))
				aAreaDTQ := DTQ->(GetArea())
				While DTR->(!Eof()) .And. DTR->DTR_FILIAL + DTR->DTR_FILVGE + DTR->DTR_NUMVGE == xFilial("DTR") + cFilOri + cViagem
					DTQ->(DbSetOrder(2))
					If DTQ->(MsSeek(xFilial("DTQ")+DTR->DTR_FILORI+DTR->DTR_VIAGEM))
						If DTQ->DTQ_STATUS != StrZero( 5, Len( DTQ->DTQ_STATUS ) ) // Fechada
							Help(" ",1,"TMSA43044",,DTQ->DTQ_FILORI+" "+DTQ->DTQ_VIAGEM ,1) //"A viagem interligada nao esta fechada: "
							A430ZerViag()
							Return( .F. )
						EndIf
					EndIf
					DTR->(DbSkip())
				EndDo
				RestArea( aAreaDTQ )
			EndIf
		EndIf
	EndIf

	// Verifica se a viagem eh interligada e sugere a viagem original.
	DTR->(dbSetOrder(1))
	If DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem)) .And. !Empty(DTR->DTR_FILVGE) .And.;
		!Empty(DTR->DTR_NUMVGE)

		If (DTR->DTR_FILORI + DTR->DTR_VIAGEM) != (DTR->DTR_FILVGE + DTR->DTR_NUMVGE)
			Help(" ",1,"TMSA43014",, DTR->DTR_FILVGE + " - " +DTR->DTR_NUMVGE, 5, 1) // Viagem interligada. Utilize a viagem original :
			A430ZerViag()
			Return( .F. )
		EndIf
	EndIf

	If !(StrZero(GetMv("MV_PCANOP"), Len(DTW->DTW_STATUS)) $ "0|1|2|3")
		Aadd(aEmptyPar, "MV_PCANOP")
	EndIf

	If Empty(cAtivCHG)
		Aadd(aEmptyPar, "MV_ATIVCHG")
	EndIf

	If Empty(cAtivSAI)
		Aadd(aEmptyPar, "MV_ATIVSAI")
	EndIf

	For nA:=1 To Len(aEmptyPar)
		Help("",1,"TMSA43015",,aEmptyPar[nA],5,5) //Este parametro esta vazio. E obrigatario preenche-lo.
	Next
	// Verifica se todos os parametros foram preenchidos.
	lRet := Len(aEmptyPar) == 0

	// Preenche as GETDADOS com os valores correspondentes encontrados
	If lRet
		If !l430Auto
			DA3->(dbSetOrder(1))
			DTR->(dbSetOrder(1))
			DTR->(MsSeek(xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))

			// ZERA OS ARRAYS QUE SALVAM OS CONTEUDOS DAS DUAS GETDADOS
			aSvFolder[1,2] := {}
			aSvFolder[2,2] := {}

			//-- Zera veiculo, quando a selecao do veiculo for efetuada atraves da viagem
			If lMotorista
				If Type("M->DTU_CODVEI") <> "U"
					M->DTU_CODVEI := CriaVar("DTU_CODVEI", .F.)
				EndIf
			Else
				M->DTU_CODVEI := CriaVar("DTU_CODVEI", .F.)
			EndIf

			Do While !DTR->(Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) ==  xFilial("DTR")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM

				If DA3->(! DbSeek(xFilial('DA3')+DTR->DTR_CODVEI))
					Help('',1,'TMSA43020',,DTR->DTR_CODVEI,2) //Veiculo nao cadastrado
					RestArea(aArea)
					Return .F.
				EndIf

				//-- Nao mostrar na GetDados os Veiculos do Tipo 'Especial'
				If Posicione("DUT",1,xFilial("DUT")+DA3->DA3_TIPVEI,"DUT_CATVEI") == StrZero(4,Len(DUT->DUT_CATVEI))
					DTR->(dbSkip())
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Veiculo Principal ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpcx == 3
					If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And.;
						DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And.;
						cAtividade <> cAtivRTP
						DF7->(DbSetOrder(2))
						If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
							If aScan(aSoma, {|x| x[nPosVei] == DF7->DF7_CODVEI} ) == 0
								AADD(aSoma,ACLONE(aColsOri1[1]))
								aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODVEI
							EndIf
						EndIf
					Else
						AADD(aSoma,ACLONE(aColsOri1[1]))
						aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODVEI
					EndIf
				Else
					If cAtividade  == cAtivRDP
						DF7->(DbSetOrder(2))
						If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
							If aScan(aSoma, {|x| x[nPosVei] == DF7->DF7_CODVEI} ) == 0
								AADD(aSoma,ACLONE(aColsOri1[1]))
								aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODVEI
							EndIf
						EndIf
					Else
						AADD(aSoma,ACLONE(aColsOri1[1]))
						aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODVEI
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ 1.o Reboque ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(DTR->DTR_CODRB1)
					If DA3->(! DbSeek(xFilial('DA3')+DTR->DTR_CODRB1))
						Help('',1,'TMSA43020',,DTR->DTR_CODRB1,2) //Veiculo nao cadastrado
						RestArea(aArea)
						Return .F.
					Else
						If nOpcx == 3
							If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And.;
								DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And.;
								cAtividade <> cAtivRTP
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
									If aScan(aSoma, {|x| x[nPosVei] == DF7->DF7_CODRB1} ) == 0
										AADD(aSoma,ACLONE(aColsOri1[1]))
										aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODRB1
									EndIf
								EndIf
							Else
								If cAtividade == cAtivRTP
									DF7->(DbSetOrder(3))
									If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
										AADD(aSoma,ACLONE(aColsOri1[1]))
										aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODRB1
									EndIf
								Else
									AADD(aSoma,ACLONE(aColsOri1[1]))
									aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB1
								EndIf
							EndIf
						Else
							If cAtividade <> cAtivRDP
								AADD(aSoma,ACLONE(aColsOri1[1]))
								aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB1
							Else
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
									If !Empty(DF7->DF7_FILDTR) .And. !Empty(DF7->DF7_VGEDTR)
										aAreaDTR := DTR->(GetArea())
										DTR->(DbSetOrder(3))
										If DTR->(MsSeek(xFilial('DTR') + DF7->(DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI)))
											If aScan(aSoma, {|x| x[1] == DTR->DTR_CODRB1} ) == 0
												AADD(aSoma,ACLONE(aColsOri1[1]))
												aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB1
											EndIf
										EndIf
										RestArea(aAreaDTR)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ 2.o Reboque ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(DTR->DTR_CODRB2)
					If DA3->(! DbSeek(xFilial('DA3')+DTR->DTR_CODRB2))
						Help('',1,'TMSA43020',,DTR->DTR_CODRB2,2) //Veiculo nao cadastrado
						RestArea(aArea)
						Return .F.
					Else
						If nOpcx == 3
							If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And.;
								DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And.;
								cAtividade <> cAtivRTP
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
									If aScan(aSoma, {|x| x[nPosVei] == DF7->DF7_CODRB2} ) == 0
										AADD(aSoma,ACLONE(aColsOri1[1]))
										aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODRB2
									EndIf
								EndIf
							Else
								If cAtividade == cAtivRTP
									DF7->(DbSetOrder(3))
									If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
										AADD(aSoma,ACLONE(aColsOri1[1]))
										aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODRB2
									EndIf
								Else
									AADD(aSoma,ACLONE(aColsOri1[1]))
									aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB2
								EndIf
							EndIf
						Else
							If cAtividade <> cAtivRDP
								AADD(aSoma,ACLONE(aColsOri1[1]))
								aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB2
							Else
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
									If !Empty(DF7->DF7_FILDTR) .And. !Empty(DF7->DF7_VGEDTR)
										aAreaDTR := DTR->(GetArea())
										DTR->(DbSetOrder(3))
										If DTR->(MsSeek(xFilial('DTR') + DF7->(DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI)))
											If aScan(aSoma, {|x| x[1] == DTR->DTR_CODRB2} ) == 0
												AADD(aSoma,ACLONE(aColsOri1[1]))
												aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB2
											EndIf
										EndIf
										RestArea(aAreaDTR)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ 3.o Reboque ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lTercRbq .And. !Empty(DTR->DTR_CODRB3)
					If DA3->(! DbSeek(xFilial('DA3')+DTR->DTR_CODRB3))
						Help('',1,'TMSA43020',,DTR->DTR_CODRB3,2) //Veiculo nao cadastrado
						RestArea(aArea)
						Return .F.
					Else
						If nOpcx == 3
							If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And.;
								DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And.;
								cAtividade <> cAtivRTP
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
									If aScan(aSoma, {|x| x[nPosVei] == DF7->DF7_CODRB3} ) == 0
										AADD(aSoma,ACLONE(aColsOri1[1]))
										aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODRB3
									EndIf
								EndIf
							Else
								If cAtividade == cAtivRTP
									DF7->(DbSetOrder(3))
									If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
										AADD(aSoma,ACLONE(aColsOri1[1]))
										aSoma[Len(aSoma),nPosVei] := DF7->DF7_CODRB3
									EndIf
								Else
									AADD(aSoma,ACLONE(aColsOri1[1]))
									aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB3
								EndIf
							EndIf
						Else
							If cAtividade <> cAtivRDP
								AADD(aSoma,ACLONE(aColsOri1[1]))
								aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB3
							Else
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
									If !Empty(DF7->DF7_FILDTR) .And. !Empty(DF7->DF7_VGEDTR)
										aAreaDTR := DTR->(GetArea())
										DTR->(DbSetOrder(3))
										If DTR->(MsSeek(xFilial('DTR') + DF7->(DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI)))
											If aScan(aSoma, {|x| x[1] == DTR->DTR_CODRB3} ) == 0
												AADD(aSoma,ACLONE(aColsOri1[1]))
												aSoma[Len(aSoma),nPosVei] := DTR->DTR_CODRB3
											EndIf
										EndIf
										RestArea(aAreaDTR)
									EndIf
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Motoristas ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÙ
				DA4->(dbSetOrder(1))
				DUP->(dbSetOrder(1))
				DUP->(MsSeek(xFilial("DUP")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+DTR->DTR_ITEM))
				//-- Verifica se foi informado Motoristas da Viagem para o Item de Veiculo (DTR_CODVEI)
				Do While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == xFilial("DUP")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM+DTR->DTR_ITEM
					If DA4->(!dbSeek(xFilial('DA4')+DUP->DUP_CODMOT))
						Help('',1,'TMSA43021',,DUP->DUP_CODMOT,2) //Motorista nao Cadastrado
						RestArea(aArea)
						Return .F.
					Else
						If nOpcx == 3
							If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And.;
								DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And.;
								cAtividade <> cAtivRTP
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ->(DTQ_FILORI + DTQ_VIAGEM)))
									If  DF7->DF7_ITEDTR == DUP->DUP_ITEDTR .And.;
										aScan(aSoma2, {|x| x[nPosMot] == DUP->DUP_CODMOT} ) == 0
										AADD(aSoma2,ACLONE(aColsOri2[1]))
										aSoma2[Len(aSoma2),nPosMot] := DUP->DUP_CODMOT
									EndIf
								EndIf
							Else
								AADD(aSoma2,ACLONE(aColsOri2[1]))
								aSoma2[Len(aSoma2),nPosMot] := DUP->DUP_CODMOT
							EndIf
						Else
							If cAtividade == cAtivRDP
								DF7->(DbSetOrder(2))
								If DF7->(MsSeek(xFilial('DF7') + DTQ ->(DTQ_FILORI+DTQ_VIAGEM)))
									If DF7->DF7_ITEDTR == DUP->DUP_ITEDTR
										AADD(aSoma2,ACLONE(aColsOri2[1]))
										aSoma2[Len(aSoma2),nPosMot] := DUP->DUP_CODMOT
									EndIf
								EndIf
							Else
								AADD(aSoma2,ACLONE(aColsOri2[1]))
								aSoma2[Len(aSoma2),nPosMot] := DUP->DUP_CODMOT
							EndIf
						EndIf
					EndIf
					DUP->(dbSkip())
				EndDo

				// INCLUI AS INFORMACOES NOS ARRAYS QUE SALVAM OS CONTEUDOS DAS DUAS GETDADOS
				aSvFolder[1,2] := ACLONE(aSoma)
				aSvFolder[2,2] := ACLONE(aSoma2)
				DTR->(dbSkip())
			EndDo
			// Caso nao tenha encontrado informacoes Limpa as linhas das GETDADOS
			// utilizando para isso os arrays com o ACOLS ORIGINAL - VAZIO
			If Empty(aSvFolder[1,2])
				aSvFolder[1,2]:=ACLONE(aColsOri1)
			EndIf
			If Empty(aSvFolder[2,2])
				aSvFolder[2,2]:=ACLONE(aColsOri2)
			EndIf
			// Preenche as informacoes atraves da funcao de executar gatilhos
			// para a SEGUNDA GETDADOS
			aHeader := Aclone(aSvFolder[2,1])
			aCols	:= Aclone(aSvFolder[2,2])
			For nz:= 1 to Len(aCols)
				N := nZ
				RunTrigger(2,nz,,o2Get,"DTO_CODMOT")
			Next nz
			aSvFolder[2,1]:= Aclone(aHeader)
			aSvFolder[2,2]:= Aclone(aCols)
			aSvFolder[2,3]:= Len(aCols)
			// Preenche as informacoes atraves da funcao de executar gatilhos
			// para a PRIMEIRA GETDADOS
			aHeader := Aclone(aSvFolder[1,1])
			aCols	:= Aclone(aSvFolder[1,2])
			For nz:= 1 to Len(aCols)
				N := nZ
				RunTrigger(2,nz,,o1Get,"DTU_CODVEI")
			Next nz
			aSvFolder[1,1]:= Aclone(aHeader)
			aSvFolder[1,2]:= Aclone(aCols)
			aSvFolder[1,3]:= Len(aCols)
			n		:= Len(aCols)


			// Salva o bloco de codigo original
			If Empty(bAddOri1) .And. Empty(bDelOri1)
				bAddOri1:=o1Get:oBrowse:bADD
				bDelOri1:=o1Get:oBrowse:bDelete
			EndIf
			// Salva o bloco de codigo original
			If Empty(bAddOri2) .And. Empty(bDelOri2)
				bAddOri2:=o2Get:oBrowse:bADD
				bDelOri2:=o2Get:oBrowse:bDelete
			EndIf

			// Se a Viagem Nao for de Transporte Fluvial
			If DTQ->DTQ_SERTMS <> StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA <> StrZero(3,Len(DTQ->DTQ_TIPTRA))
				// Seta os campos que podem ser alterados quando a viagem for digitada
				o2Get:aAlter         := If(nOpcx==3,{"DTO_CRACHA"},{})
				o2Get:oBrowse:bADD   := {|| .F. }
				o2Get:oBrowse:bDelete:= {|| .F. }
			EndIf

			// Efetua refresh para setar propriedades
			o2Get:oBrowse:lDisablePaint := .F.
			o2Get:oBrowse:Refresh(.T.)
			o2Get:ForceRefresh()

			// Se a Viagem Nao for de Transporte Fluvial
			If DTQ->DTQ_SERTMS <> StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA <> StrZero(3,Len(DTQ->DTQ_TIPTRA))
				// Seta os campos que podem ser alterados quando a viagem for digitada
				o1Get:aAlter         := If(nOpcx==3,{"DTU_ODOENT"},{"DTU_ODOSAI"})
				o1Get:oBrowse:bADD   := {|| .F. }
				o1Get:oBrowse:bDelete:= {|| .F. }
			EndIf
			// Efetua refresh para setar propriedades
			oFolder:nOption:=1
			o1Get:oBrowse:lDisablePaint := .F.
			o1Get:oBrowse:Refresh(.T.)
			o1Get:ForceRefresh()

			oDlg:Refresh()
			oFolder:Refresh(.T.)
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430LinOk³ Autor ³ Rodrigo de A. Sartorio³ Data ³02.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa a LINHA digitada na GETDADOS                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430LinOK(ExpO1,ExpL1,ExpN1)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Indica se a chamada ocorre por mudanca de pasta    ³±±
±±³          ³ ExpN1 = Folder Atual                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA430LinOk(o,lMudaPasta,nFolderAtu)

LOCAL nz       := 0
LOCAL nCarreta := 0
LOCAL lCavalo  :=.F.
LOCAL lComum   :=.F.
LOCAL lEspecial:=.F.
LOCAL lRet     :=.T.
LOCAL aArea    :=GetArea()
Local lVeiGen  := .F.
Local nQtdVei  := IIf(DTR->(ColumnPos('DTR_CODRB3'))> 0,3,2)

DEFAULT lMudaPasta  := .F.
DEFAULT nFolderatu  := oFolder:nOption

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se linha do acols foi preenchida            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lMudaPasta .And. !CheckCols(n,aCols)
	lRet:= .F.
EndIf

// Valida Veiculo
If lRet .And. nFolderatu == 1
	// Valida informacoes
	If If(lMotorista,Empty(M->DTO_VIAGEM),Empty(M->DTU_VIAGEM))
		// Verifica se o veiculo nao esta digitado com STATUS
		dbSelectArea("DUT")
		dbSetOrder(1)
		dbSelectArea("DA3")
		dbSetOrder(1)
		For nz:=1 to Len(aCols)

			//-- Caso exista veiculo generico informado nao consiste as informacoes na entrada.
			If AllTrim(aCols[nz,nPosVei]) == cVeiGen
				lVeiGen := .T.
				Exit
			EndIf

			// Verifica se a linha nao esta deletada
			If ValType(aCols[nz,Len(aCols[nz])]) == "L" .And. !aCols[nz,Len(aCols[nz])]
				// Verifica a existencia de veiculos repetidos
				If aCols[nz,nPosVei] == aCols[n,nPosVei] .And. nz # n
					If ValType(aCols[n,Len(aCols[n])]) == "L" .And. !aCols[n,Len(aCols[n])]
						lRet:=.F.
						Help(" ",1,"TMSA43008") //Algum Veiculo foi informado mais de uma vez nesse movimento.
						Exit
					EndIf
				EndIf
				// Pesquisa o Veiculo
				dbSelectArea("DA3")
				dbSetOrder(1)
				If dbSeek(xFilial()+aCols[nz,nPosVei])	.And. DUT->(dbSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
					// Comum
					If DUT->DUT_CATVEI == "1"
						If !lComum
							lComum:=.T.
						Else
							lRet:=.F.
							Help(" ",1,"TMSA43002") //Nao pode ser utilizado mais de um Veiculo Comum nesse movimento.
							Exit
						EndIf
						// Valida se quilometragem foi digitada
						If lRet .And. nPosOdo > 0 .And. Empty(aCols[nz,nPosOdo])
							If nOpcx == 3
								Help(" ",1,"NVAZIO",,'DTU_ODOENT',3,1) //Este campo deve ser informado.
							ElseIf nOpcx == 5
								Help(" ",1,"NVAZIO",,'DTU_ODOSAI',3,1) //Este campo deve ser informado.
							EndIf
							lRet:=.F.
							Exit
						EndIf
						// Cavalo
					ElseIf DUT->DUT_CATVEI == "2"
						If !lCavalo
							lCavalo:=.T.
						Else
							lRet:=.F.
							Help(" ",1,"TMSA43003") //"Nao pode ser utilizado mais de um Veiculo Tracionador nesse movimento"
							Exit
						EndIf
						// Valida se quilometragem foi digitada
						If lRet .And. nPosOdo > 0 .And. Empty(aCols[nz,nPosOdo])
							If nOpcx == 3
								Help(" ",1,"NVAZIO",,'DTU_ODOENT',3,1) //"Este campo deve ser informado"
							ElseIf nOpcx == 5
								Help(" ",1,"NVAZIO",,'DTU_ODOSAI',3,1) //"Este campo deve ser informado"
							EndIf
							lRet:=.F.
							Exit
						EndIf
						// Carreta
					ElseIf DUT->DUT_CATVEI == "3"
						nCarreta += 1
						// Especial
					ElseIf DUT->DUT_CATVEI == "4"
						If !lEspecial
							lEspecial=.T.
						Else
							lRet:=.F.
							Help(" ",1,"TMSA43013") //"Informe apenas um Veículo Especial"
							Exit
						EndIf
					EndIf
				EndIf
			EndIf
		Next nz
		// Verifica o numero de carretas e a relacao entre cavalo/carreta
		If lRet
			If !lVeiGen
				If lComum
					If lCavalo .Or. nCarreta > 0
						lRet:=.F.
						Help(" ",1,"TMSA43004") //"Nao pode ser utilizado nesse movimento Veiculo Comum + Veiculo Tracionador"
					EndIf
				ElseIf nCarreta > nQtdVei
					If !( ( nOpcx == 4 .Or. nOpcx == 6) .And. ( nCarreta > 0 .And. !lCavalo .And. !lComum .And. !lEspecial ) )
						lRet:=.F.
						Help(" ",1,"TMSA43006") //"Nao podem ser utilizados mais de dois Veiculos Reboques nesse movimento"
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
	// Valida Motorista
ElseIf lRet .And. nFolderatu == 2 .And. If(lMotorista,Empty(M->DTO_VIAGEM),Empty(M->DTU_VIAGEM))
	For nz:=1 to Len(aCols)
		// Verifica se a linha nao esta deletada
		If ValType(aCols[nz,Len(aCols[nz])]) == "L" .And. !aCols[nz,Len(aCols[nz])]
			// Verifica a existencia de motoristas repetidos
			If aCols[nz,nPosMot] == aCols[n,nPosMot] .And. nz # n .And. AllTrim(aCols[nz,nPosMot]) <> cMotGen
				If ValType(aCols[n,Len(aCols[n])]) == "L" .And. !aCols[n,Len(aCols[n])]
					lRet:=.F.
					Help(" ",1,"TMSA43009") //"Algum MOTORISTA foi informado mais de uma vez nesse movimento"
					Exit
				EndIf
			EndIf
		EndIf
	Next nz
EndIf
RestArea(aArea)

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430TOk  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³05.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Checa o conteudos das duas GETDADOS utilizadas             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430TOK(ExpN1)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Folder Atual                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA430TOK(nFolderAtu)

Local nz          := 0
Local nCarreta    := 0
Local lCavalo     :=.F.
Local lComum      :=.F.
Local lEspecial   := .F.
Local lRet        := .T.
Local aAreaDTU    := DTU->( GetArea() )
Local aAreaDTO    := DTO->( GetArea() )
Local aAreaDUT    := DUT->( GetArea() )
Local aAreaDA3    := DA3->( GetArea() )
Local aAreaDA4    := DA4->( GetArea() )
Local aValid      := {}
Local cFilOri     := If(lMotorista,M->DTO_FILORI,M->DTU_FILORI)
Local cViagem     := If(lMotorista,M->DTO_VIAGEM,M->DTU_VIAGEM)
Local lViagem     := If(lMotorista,!Empty(M->DTO_VIAGEM),!Empty(M->DTU_VIAGEM))
Local nMotoristas := 0
Local lVeiGen     := .F.
Local cQuery      := ''
Local cAliasQry   := ''
Local lFilBas     := DA4->( FieldPos('DA4_FILBAS') ) > 0
Local nQtdVei  	  := IIf(DTR->(ColumnPos('DTR_CODRB3'))> 0,3,2)
Local lTercRbq    := DTR->(ColumnPos("DTR_CODRB3")) > 0
Local aColig	  := {}

DEFAULT nFolderatu := oFolder:nOption

// Possiveis STATUS de MOTORISTAS e VEICULOS
// Em aberto STATUS=='1'
// Liberado  STATUS=='2'
// Reservado STATUS=='3'
// Baixado   STATUS=='4'

If nFolderAtu == 1
	// Atu aliza matriz atraves do aValid alterado
	aSvFolder[1][1]:= Aclone(aHeader)
	aSvFolder[1][2]:= Aclone(aCols)
ElseIf nFolderAtu == 2
	// Atualiza matriz atraves do aValid alterado
	aSvFolder[2][1]:= Aclone(aHeader)
	aSvFolder[2][2]:= Aclone(aCols)
EndIf

DTU->(DbSetOrder(2))
DTO->(DbSetOrder(2))
DUT->(dbSetOrder(1))
DA3->(dbSetOrder(1))
DA4->(dbSetOrder(1))

// Valida Veiculo
aValid:=ACLONE(aSvFolder[1][2])
For nz:=1 to Len(aValid)
	If ValType(aValid[nz,Len(aValid[nz])]) == "L" .And. !aValid[nz,Len(aValid[nz])] .And. !Empty(aValid[nz,nPosVei])

		If lViagem
			//-- Se a Viagem Nao for de Transporte Fluvial
			DTQ->(dbSetOrder(2))
			If DTQ->(MsSeek(xFilial('DTQ')+cFilOri+cViagem)) .And. DTQ->DTQ_TIPTRA <> StrZero(3,Len(DTQ->DTQ_TIPTRA))
				cQuery := "SELECT DTR.DTR_FILORI , DTR.DTR_VIAGEM FROM " + RetSqlName("DTR") + " DTR"
				cQuery += " WHERE DTR.DTR_FILIAL = '" + xFilial("DTR")  + "'"
				cQuery += " AND   DTR.DTR_FILORI = '" + DTQ->DTQ_FILORI + "'"
				cQuery += " AND   DTR.DTR_VIAGEM = '" + DTQ->DTQ_VIAGEM + "'"
				cQuery += " AND  (DTR.DTR_CODVEI = '" + aValid[nz,nPosVei] + "' OR DTR_CODRB1 = '" + aValid[nz,nPosVei] +"' OR DTR_CODRB2 = '" + aValid[nz,nPosVei] + "'"
				If lTercRbq
					cQuery += " OR DTR_CODRB3 = '" + aValid[nz,nPosVei] + "')"
				Else
					cQuery += ")"
				EndIf 
				cQuery += " AND   DTR.D_E_L_E_T_ = ' '"
				cQuery    := ChangeQuery(cQuery)
				cAliasQry := GetNextAlias()
				dbUseArea( .T., 'TOPCONN', TCGENQRY(,, cQuery), cAliasQry, .T., .T. )
				(cAliasQry)->(dbGoTop())
				lRet := (cAliasQry)->(!Eof())
				(cAliasQry)->(dbCloseArea())
				//-- Verifica se existe o Complemento de Viagem.
				If !lRet
					Help("", 1,'TMSA43043',,aValid[nz,nPosVei] + STR0031 + cFilOri + '/' + cViagem,1,10) //"O Veiculo : "###"nao pertence a viagem "
					Exit
				EndIf
			EndIf
		EndIf

		dbSelectArea("DTU")
		dbSetOrder(2)
		If AllTrim(aValid[nz,nPosVei]) <> cVeiGen .And. ;
			((nOpcx == 3 .And.  dbSeek(xFilial()+aValid[nz,nPosVei]+"1")) .Or.;
			( nOpcx == 4 .And. !dbSeek(xFilial()+aValid[nz,nPosVei]+"1")) .Or.;
			((nOpcx == 3 .Or. nOpcx == 4) .And. dbSeek(xFilial()+aValid[nz,nPosVei]+"2")) .Or.;
			((nOpcX == 3 .Or. nOpcx == 4) .And. dbSeek(xFilial()+aValid[nz,nPosVei]+"3"))) //DTU_STATUS: 1=Em Aberto;2=Liberado;3=Reservado;4=Baixado
			lRet := .F.
			Help(" ",1,"TMSA43012") //"Informe um VEICULO/MOTORISTA valido para esse movimento"
			Exit
		EndIf
		If nOpcx == 3 //-- Entrada
			If AllTrim(aValid[nz,nPosVei]) <> cVeiGen
				lRet := TMSEmViag(cFilOri,cViagem,aValid[nz,nPosVei],1)
			Else
				lVeiGen := .T. //-- Veiculo Generico
			EndIf
		EndIf
		// Pesquisa o Veiculo
		aColig := VgaColigada(cFilOri, cViagem)
		If lRet
			DA3->(dbSeek(xFilial()+aValid[nz,nPosVei]))
			If DA3->DA3_ATIVO == "2" //-- Nao
				Help(" ",1,"TMSA43023",,aValid[nz,nPosVei],2,1) // Veiculo nao esta ativo
				lRet := .F.
				Exit
			ElseIf nOpcx == 3 .And. DA3->DA3_STATUS == StrZero(3,Len(DA3->DA3_STATUS)) .And. DA3->DA3_FILVGA <> cFilOri .And. DA3->DA3_NUMVGA <> cViagem  .And. !Empty(aColig) .And. Len(aColig) > 1 // Em Viagem				
				If nModulo <> 39 //-- Frete Embarcador
					If AllTrim(DA3->DA3_COD) <> cVeiGen
						Help(" ",1,"TMSA43016",, DA3->DA3_FILVGA + "/" + DA3->DA3_NUMVGA, 5, 1) // O Veiculo/Motorista digitado esta sendo utilizado na viagem :
						lRet := .F.
						Exit
					EndIf
				EndIf
			ElseIf nOpcx == 5 //-- Saida
				//-- Verifica se o Veiculo Nao esta disponivel
				If DA3->DA3_STATUS == StrZero(1,Len(DA3->DA3_STATUS))
					Help(" ",1,"TMSA43039",,aValid[nz,nPosVei],4,0) // Veiculo Nao Disponivel
					lRet := .F.
					Exit
				EndIf
				//-- Veiculo reservado e saida sem viagem
				If nModulo <> 39 //-- Frete Embarcador
					If DTU->(MsSeek(xFilial('DTU')+aValid[nz,nPosVei]+StrZero(3,Len(DTU->DTU_STATUS)))) .And. !lViagem
						Help(" ",1,"TMSA43024",,aValid[nz,nPosVei],4,0) // Para veiculos reservados, a saida somente podera ser efetuada atraves de uma viagem
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
			If DUT->(! dbSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
				Help(" ",1,"TMSA43025",,DA3->DA3_TIPVEI,2,0) // Tipo de veiculo nao cadastrado
				lRet := .F.
				Exit
			EndIf
			If lRet
				If DUT->DUT_CATVEI == "1" //-- Comum
					If !lComum
						lComum := .T.
					Else
						If !lViagem
							Help(" ",1,"TMSA43002") //"Nao pode ser utilizado mais de um Veiculo Comum nesse movimento"
							lRet := .F.
							Exit
						EndIf
					EndIf
					// Valida se quilometragem foi digitada
					If lRet .And. nPosOdo > 0 .And. Empty(aValid[nz,nPosOdo])
						If nOpcx == 3 //-- Entrada
							Help(" ",1,"NVAZIO",,'DTU_ODOENT',3,1) //"Este campo deve ser informado"
						ElseIf nOpcx == 5 //-- Saida
							Help(" ",1,"NVAZIO",,'DTU_ODOSAI',3,1) //"Este campo deve ser informado"
						EndIf
						lRet := .F.
						Exit
					EndIf
					// Cavalo
				ElseIf DUT->DUT_CATVEI == "2"
					If !lCavalo
						lCavalo := .T.
					Else
						If !lViagem
							lRet:=.F.
							Help(" ",1,"TMSA43003") //"Nao pode ser utilizado mais de um Veiculo Tracionador nesse movimento"
							Exit
						EndIf
					EndIf
					// Valida se quilometragem foi digitada
					If lRet .And. nPosOdo > 0 .And. Empty(aValid[nz,nPosOdo])
						If nOpcx == 3
							Help(" ",1,"NVAZIO",,'DTU_ODOENT',3,1) //"Este campo deve ser informado"
						ElseIf nOpcx == 5
							Help(" ",1,"NVAZIO",,'DTU_ODOSAI',3,1) //"Este campo deve ser informado"
						EndIf
						lRet := .F.
						Exit
					EndIf
					// Carreta
				ElseIf DUT->DUT_CATVEI == "3"
					nCarreta += 1
					// Especial
				ElseIf DUT->DUT_CATVEI == "4"
					If !lEspecial
						lEspecial := .T.
					Else
						If !lViagem
							lRet:=.F.
							Help(" ",1,"TMSA43013") //"Informe apenas um Veiculo Especial"
							Exit
						EndIf
					EndIf
				EndIf
				If lRet
					If !Empty(DA3->DA3_CODBEM)
						If nOpcx == 4
							STJ->(DbSetOrder(12))
							If STJ->(MsSeek(xFilial("STJ")+Padr(DA3->DA3_CODBEM,Len(STJ->TJ_CODBEM))+"N"))
								Help(" ",1,"TMSA43045") //"Existem Ordens de Servico em aberto para esse veiculo"
								lRet := .F.
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		Else
			Exit
		EndIf
	EndIf
Next nz
// Verifica o numero de carretas e a relacao entre cavalo/carreta
// Valida motoristas
If lRet
	If !lVeiGen
		If lComum
			If lCavalo .Or. nCarreta > 0
				lRet:=.F.
				Help(" ",1,"TMSA43004") //"Nao pode ser utilizado nesse movimento Veiculo Comum + Veiculo Tracionador"
			EndIf
		ElseIf nCarreta > 0 .And. !lCavalo .And. nOpcx # 4 .And. nOpcx # 6
			lRet:=.F.
			Help(" ",1,"TMSA43005") //"Não pode ser utilizado nesse movimento um VEICULO REBOQUE sem um VEICULO TRACIONADOR"
		ElseIf nCarreta > nQtdVei .And. nOpcx == 4
			If !( nCarreta > 0 .And. !lCavalo .And. !lComum .And. !lEspecial )
				lRet:=.F.
				Help(" ",1,"TMSA43006") //"Nao podem ser utilizados mais de dois Veiculos Reboques nesse movimento"
			EndIf
		EndIf
	EndIf
	If lRet
		// Valida Motorista
		aValid:=ACLONE(aSvFolder[2][2])
		For nz:=1 to Len(aValid)
			// Verifica se a linha nao esta deletada

			If ValType(aValid[nz,Len(aValid[nz])]) == "L" .And. !aValid[nz,Len(aValid[nz])] .And. !Empty(aValid[nz,nPosMot])

				If lViagem
					DUP->(dbSetOrder(2))
					If !DUP->(MsSeek(xFilial('DTR')+cFilOri+cViagem+aValid[nz,nPosMot]))
						Help(" ",1,"TMSA43046",,aValid[nz,nPosMot] + ', ' + STR0031 + cFilOri + '/' + cViagem,2,1) //"O Motorista "###"nao pertence a viagem"
						lRet := .F.
						Exit
					EndIf
				EndIf

				DA4->(dbSeek(xFilial()+aValid[nz,nPosMot]))
				lRet := TMSVldFunc( DA4->DA4_MAT, If( lFilBas, DA4->DA4_FILBAS, '' ) )

				If lRet
					If DA4->DA4_BLQMOT == "1" //-- Sim
						Help(" ",1,"TMSA43026",,aValid[nz,nPosMot],2,0) // Motorista esta Bloqueado
						lRet := .F.
						Exit
					ElseIf nOpcx == 3 //-- Entrada
						If AllTrim(aValid[nz,nPosMot]) <> cMotGen
							If !TMSEmViag(cFilOri,cViagem,aValid[nz,nPosMot],2)
								lRet := .F.
								Exit
							EndIf
						EndIf
					ElseIf nOpcx == 5 //-- Saida
						//-- Motorista reservado e saida sem viagem
						If nModulo <> 39 //-- Frete Embarcador
							If DTO->(MsSeek(xFilial('DTO')+aValid[nz,nPosMot]+StrZero(3,Len(DTO->DTO_STATUS)))) .And. !lViagem
								Help(" ",1,"TMSA43027",,aValid[nz,nPosMot],4,0) // Para motoristas reservados, a saida somente podera ser efetuada através de uma viagem
								lRet := .F.
								Exit
							EndIf
						EndIf
						If ( nCarreta == 0 .And. !lCavalo .And. !lComum .And. !lEspecial ) .And. ; // Sem Veiculo
							DTO->(MsSeek(xFilial('DTO')+aValid[nz,nPosMot]+StrZero(2,Len(DTO->DTO_STATUS)))) //-- Motorista Liberado
							Help(" ",1,"TMSA43047") // Nao e permitido a saida de motoristas liberados sem veiculos.
							lRet := .F.
							Exit
						EndIf
					EndIf
				Else
					Exit
				EndIf
				nMotoristas += 1
			EndIf
		Next nz
		If lRet
			If nMotoristas == 0
				//-- Permite liberar carreta sem motorista
				If !( ( nOpcx == 4 .Or. nOpcx == 6 ) .And. ( nCarreta > 0 .And. !lCavalo .And. !lComum .And. !lEspecial ) )
					Help(" ",1,"TMSA43010") //"Digite pelo menos um MOTORISTA por movimento"
					lRet := .F.
				EndIf
			Else
				//-- Nao permite carreta com motorista
				If ( nOpcx == 4 .Or. nOpcx == 6 ) .And. ( nCarreta > 0 .And. !lCavalo .And. !lComum .And. !lEspecial )
					Help(" ",1,"TMSA43038") //Nao e permitido a movimentacao de veiculos do tipo carreta com motorista
					lRet := .F.
				EndIf
			EndIf
			If lRet
				If nCarreta == 0 .And. !lCavalo .And. !lComum .And. !lEspecial
					If nMotorista == 0
						Help(" ",1,"TMSA43011") //"Digite pelo menos um VEICULO por movimento"
						lRet := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDTU )
RestArea( aAreaDTO )
RestArea( aAreaDUT )
RestArea( aAreaDA3 )
RestArea( aAreaDA4 )

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA430Grv³ Autor ³Rodrigo de A. Sartorio ³ Data ³05.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua a gravacao dos movimentos de veiculos e motoristas  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1:=TmsA430Grv(ExpN1,ExpA1)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao do arotina que esta sendo executada          ³±±
±±³          ³ ExpA1 = Array com os campos atualizados na MSMGET          ³±±
±±³			 ³ ExpL1 = Retorno indicando se gravacao foi bem sucedida(.T.)³±±
±±³			 ³ ou nao (.F.)                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA430Grv(nOpc,aVisual)

Local lRet			:= .T.
Local cStatus		:= ''
Local nz			:= 0
Local zx			:= 0
Local xVar			:= ""
Local aValidH		:= {}
Local aValidCols	:= {}
Local aCab			:= {}
Local aArea			:= GetArea()
Local aAreaDTO		:= DTO->(GetArea())
Local aAreaDTU		:= DTU->(GetArea())
Local aAreaDTQ		:= DTQ->(GetArea())
Local aAreaDTR		:= DTR->(GetArea())
Local cVeiculo		:= ""
Local cVeiculo1		:= ""
Local cVeiculo2		:= ""
Local cVeiculo3		:= ""
Local nOdometro		:= 0
Local cFilOri		:= If(lMotorista,M->DTO_FILORI,M->DTU_FILORI)
Local cViagem		:= If(lMotorista,M->DTO_VIAGEM,M->DTU_VIAGEM)
Local dDatIni		:= Ctod("")
Local cHorIni		:= ""
Local cSeqAte		:= ""                 // Sequencia da operacao.
Local cAtividade	:= ""                 // Atividade da operacao de transporte.
Local aViagens		:= {}
Local nA			:= 0
Local nB			:= 0
Local bCampo		:= {|x| FieldName(x) }
Local nCampos		:= 0
Local nCntFor		:= 0
Local nSequen		:= 0
Local lSeek			:= .T.
Local lGrvOk		:= .T.
Local lCancOp		:= .T.
Local nSeqAte		:= 0
Local cLibSeg		:= ''
Local nValSeg		:= 0
Local nOdoRb1		:= 0
Local nOdoRb2		:= 0
Local nOdoRb3		:= 0
Local nPosLibSeg	:= 0
Local nPosValSeg	:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes do parametro "MV_PCANOP" :                                ³
//³ 0 = Cancelar as Operacoes Anteriores.                            ³
//³ 1 = Perguntar se as Operacoes Anteriores deverao ser canceladas. ³
//| 2 = Nao Cancelar	as Operacoes Anteriores                      |
//| 3 = Apontamento Obrigatorio das Operacoes Anteriores             |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local nPCanOp := GetMv("MV_PCANOP") // Opcoes para o cancelamento de operacoes de transportes.
Local lPergOp := nPCanOp == 1       // Exibe pergunta(Cancela operacoes Sim/Nao).
Local dDatEnt := CtoD('')
Local dDatSai := CtoD('')
Local cHorEnt := ''
Local cHorSai := ''
Local lAptJor := SuperGetMv("MV_CONTJOR",,.F.) .And. AliasInDic('DEW') //-- Apontamento da jornada de trabalho do motorista  
Local cAptJor := ""	
Local cAtivChg 	:= GetMv('MV_ATIVCHG',,'') // Atividade de Chegada
Local cAtivSai	:= GetMv("MV_ATIVSAI") 		// Atividade de Saída
Local lIdDTW   	:= DTW->(ColumnPos("DTW_IDDTW")) > 0 
Local cIdDTW	:= ""
// Possiveis STATUS de MOTORISTAS e VEICULOS
// Em aberto STATUS=='1'
// Liberado  STATUS=='2'
// Reservado STATUS=='3'
// Baixado   STATUS=='4'

If nOpc == 6 // Estornar
	TMSA430Est()
	Return ( .F. )
EndIf

If !Empty(cViagem) .And. !Empty(cFilOri)
	// Adiciona ao array a viagem original.
	Aadd(aViagens, {cFilOri, cViagem})

	// Verifica se existem viagens interligadas.
	DTR->(dbSetOrder(2))
	DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem))

	While DTR->(!Eof()) .And. DTR->DTR_FILIAL == xFilial("DTR") .And. DTR->DTR_FILVGE == cFilOri .And.;
		DTR->DTR_NUMVGE == cViagem

		// Adiciona ao array as viagens interligadas.
		If (DTR->DTR_FILORI + DTR->DTR_VIAGEM) != (DTR->DTR_FILVGE + DTR->DTR_NUMVGE)

			If Ascan(aViagens, {|x| x[1] + x[2] == DTR->DTR_FILORI + DTR->DTR_VIAGEM}) == 0
				Aadd(aViagens , {DTR->DTR_FILORI, DTR->DTR_VIAGEM})
			EndIf
		EndIf

		DTR->(dbSkip())
	EndDo

	If nOpc == 3 // Entrada
		cAtividade := GetMv("MV_ATIVCHG",,"") // Atividade de chegada.
		If cFilOri == cFilAnt
			If DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))
				cAtividade  := GetMv("MV_ATIVRTA",,"") // Atividade de retorno de Aeroporto
			ElseIf DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA))
				cAtividade  := GetMv("MV_ATIVRTP",,"") // Atividade de retorno do Porto
			EndIf
		EndIf
	Else         // Saida
		cAtividade := GetMv("MV_ATIVSAI",,"") // Atividade de saida.
		If	DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) .And.;
			DTQ->DTQ_TIPTRA == StrZero(3,Len(DTQ->DTQ_TIPTRA)) .And.;
			DTQ->DTQ_STATUS == StrZero(2,Len(DTQ->DTQ_STATUS))
			cAtividade := GetMv("MV_ATIVRDP",,"")
		EndIf
	EndIf

	For nA := 1 To Len(aViagens)
		DTW->(dbSetOrder(4))
		// Posiciona a operacao de chegada/saida.
		If DTW->(MsSeek(xFilial("DTW") + aViagens[nA, 1] + aViagens[nA, 2] + cAtividade + cFilAnt))
			//Guarda a sequencia da operacao de chegada/saida.
			nSeqAte := DTW->DTW_SEQUEN

			DTW->(dbSetOrder(3))
			// Verifica se existem operacoes anteriores a chegada/saida em aberto.
			If DTW->(MsSeek(xFilial("DTW") + aViagens[nA, 1] + aViagens[nA, 2] + StrZero(1, Len(DTW->DTW_STATUS)))) .And.;
				DTW->DTW_SEQUEN < nSeqAte 
				If lPergOp
					// Informa que existem operacoes em aberto de acordo com o parametro(MV_PCANOP == 1).
					lCancOp  := MsgYesNo(STR0021, STR0020)//"Existem operacoes anteriores 'em aberto'. Deseja cancelar essas operacoes ?"
				EndIf

				If nPCanOp == 3 //-- Apontamento Obrigatorio das Operacoes anteriores
					Help("", 1,'TMSA43048') //"Existem Operacoes Anteriores em Aberto. Favor aponta-las"
					Return .F.
				EndIf

				Exit // Abandona o For, pois o retorno da MsgYesNo vale para todas as viagens.

			EndIf
		EndIf
	Next nA
EndIf

If !lCancOp
	Return .F.
EndIF

// Status a ser gravado na Entrada
If nOpc == 3
	// Valida existencia da VIAGEM
	DTQ->(dbSetOrder(2))
	If !Empty(cFilOri+cViagem) .And. DTQ->(dbSeek(xFilial("DTQ")+cFilOri+cViagem))
		// Se a viagem jah estiver encerrada OU for Transp. Aereo ou Transp. Fluvial , veiculo entra em aberto
		If   DTQ->DTQ_STATUS == StrZero(3, Len(DTQ->DTQ_STATUS)) .Or. ;
			(DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(2, Len(DTQ->DTQ_SERTMS)) ) .Or. ;
			(DTQ->DTQ_SERTMS == StrZero(2, Len(DTQ->DTQ_SERTMS)) .And. DTQ->DTQ_TIPTRA == StrZero(3, Len(DTQ->DTQ_SERTMS)) )
			cStatus := "1"
		Else
			cStatus := "3"
		EndIf
	Else
		cStatus := "1"
	EndIf
	dDatIni := If(lMotorista,M->DTO_DATENT,M->DTU_DATENT)
	cHorIni := If(lMotorista,M->DTO_HORENT,M->DTU_HORENT)
	// Status a ser gravado na Liberacao
ElseIf nOpc == 4
	cStatus := "2"
	// Status a ser gravado na Saida
ElseIf nOpc == 5
	cStatus := "4"
	dDatIni := If(lMotorista,M->DTO_DATSAI,M->DTU_DATSAI)
	cHorIni := If(lMotorista,M->DTO_HORSAI,M->DTU_HORSAI)
EndIf

If !Empty(cFilOri) .And. !Empty(cViagem)
	For nB := 1 To Len(aViagens)
		lGrvOk := .F.
		DTW->(dbSetOrder(4))
		If DTW->(MsSeek(cSeek:=xFilial("DTW") + aViagens[nB, 1] + aViagens[nB, 2] + cAtividade + cFilAnt)) 
			Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM+DTW_ATIVID+DTW_FILATI) == cSeek
				If DTW->DTW_STATUS == StrZero(1, Len(DTW->DTW_STATUS))
					lGrvOk := TMSA350Grv(3, aViagens[nB, 1], aViagens[nB, 2], cAtividade, dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""))					
				EndIf
				DTW->(dbSkip())
			EndDo
		EndIf

		//-- Se nao encontrou Atividade de Chegada/Saida 'Prevista' com status 'Em Aberto' no DTW,
		//-- grava operacao de chegada/Saida 'Eventual'
		If !lGrvOk
			//-- Obtem a sequencia anterior da atividade
			DTW->(DbSetOrder(7))
			DTW->(MsSeek(xFilial('DTW') + aViagens[nB,1] + aViagens[nB,2] + cAtividade))
			DTW->(DbSkip(-1))
			nSequen := 0
			nSequen := Soma1(DTW->DTW_SEQUEN)
			//-- Permitir a chegada/saida de uma viagem em uma filial nao prevista
			DTW->(DbSetOrder(3))
			DTW->(MsSeek(xFilial('DTW') + aViagens[nB,1] + aViagens[nB,2] + StrZero(1,Len(DTW->DTW_STATUS)),.T.))

			If	(DTW->DTW_FILIAL + DTW->DTW_FILORI + DTW->DTW_VIAGEM == xFilial('DTW') + aViagens[nB,1] + aViagens[nB,2] .And. DTW->DTW_STATUS != StrZero(1,Len(DTW->DTW_STATUS))) .Or.;
				DTW->DTW_FILIAL + DTW->DTW_FILORI + DTW->DTW_VIAGEM != xFilial('DTW') + aViagens[nB,1] + aViagens[nB,2]
				DTW->(DbSkip(-1))
			EndIf

			If	DTW->DTW_FILIAL + DTW->DTW_FILORI + DTW->DTW_VIAGEM + DTW->DTW_STATUS == xFilial('DTW') + aViagens[nB,1] + aViagens[nB,2] + StrZero(1,Len(DTW->DTW_STATUS))
				aAreaDTW := DTW->(GetArea())

				//-- Gera Operacao de Chegada de Viagem Eventual
				RegToMemory('DTW',.F.)

				M->DTW_FILIAL := xFilial('DTW')
				M->DTW_SEQUEN := nSequen
				M->DTW_TIPOPE := StrZero(2,Len(DTW->DTW_TIPOPE))
				M->DTW_DATPRE := dDataBase
				M->DTW_HORPRE := StrTran(Left(Time(),5),':','')
				M->DTW_ATIVID := cAtivChg
				M->DTW_STATUS := StrZero(2,Len(DTW->DTW_STATUS))
				M->DTW_FILATU := cFilAnt
				M->DTW_CATOPE := StrZero(2,Len(DTW->DTW_CATOPE))				//-- Categoria da operacao 2=Eventual

				nCampos := DTW->( FCount() )

				RecLock('DTW',.T.)
				For nCntFor := 1 To nCampos
					FieldPut( nCntFor, M->&( Eval( bCampo,nCntFor ) ) )
				Next
				DTW->( MsUnLock() )

				lGrvOk := TMSA350Grv(3, aViagens[nB, 1], aViagens[nB, 2], cAtivChg , dDatIni, cHorIni, dDataBase, StrTran(Left(Time(),5),":",""))

				RestArea(aAreaDTW)

				//-- Gera Operacao de Saida de Viagem Eventual
				//-- A operacao de Saida de Viagem 'Eventual', sera' criada pela funcao TMSCriaDTW(), e nao atraves da funcao TMSA350Grv().
				//-- Isto e' feito porque a funcao TMSA350Grv() executa a TMSMovViag(), que deixaria a operacao de 'Saida 
				//-- de Viagem Eventual' com Status 'Baixado' e a Viagem com Status 'Em Transito'; Sendo que o correto,
				//-- e' gerar uma operacao de 'Chegada de Viagem Eventual' com Status 'Baixado' e uma Operacao de
				//-- 'Saida de Viagem Eventual' com Status 'Em Aberto'; Ao apontar a Saida de Viagem, no Movto. de Veiculos/
				//-- motorista, a Operacao de 'Saida de Viagem Eventual' ficara' com Status 'Baixado' e a Viagem com Status
				//-- 'Em Transito'
				If DTW->DTW_SERTMS == StrZero(2,Len(DTW->DTW_SERTMS)) //-- Transporte
					nSequen := Soma1(nSequen)
					Aadd( aCab, { 'DTW_FILORI', DTW->DTW_FILORI,		Nil } )
					Aadd( aCab, { 'DTW_VIAGEM', DTW->DTW_VIAGEM,		Nil } )
					Aadd( aCab, { 'DTW_SEQUEN', nSequen,				Nil } )
					Aadd( aCab, { 'DTW_DATPRE', dDataBase,				Nil } )
					Aadd( aCab, { 'DTW_HORPRE', StrTran(Left(Time(),5),':',''), Nil } )
					Aadd( aCab, { 'DTW_DATINI', Ctod(""),				Nil } )
					Aadd( aCab, { 'DTW_HORINI', "",						Nil } )
					Aadd( aCab, { 'DTW_DATREA', Ctod(""),				Nil } )
					Aadd( aCab, { 'DTW_HORREA', "",						Nil } )
					Aadd( aCab, { 'DTW_SERVIC', DTW->DTW_SERVIC,		Nil } )
					Aadd( aCab, { 'DTW_TAREFA', DTW->DTW_TAREFA,		Nil } )
					Aadd( aCab, { 'DTW_ATIVID', cAtivSai,				Nil } )
					Aadd( aCab, { 'DTW_FILATI', cFilAnt,				Nil } )
					Aadd( aCab, { 'DTW_FILATU', cFilAnt,				Nil } )
					Aadd( aCab, { 'DTW_SERTMS', DTW->DTW_SERTMS	,		Nil } )
					Aadd( aCab, { 'DTW_TIPTRA', DTW->DTW_TIPTRA	,		Nil } )
					Aadd( aCab, { 'DTW_STATUS', StrZero(1,Len(DTW->DTW_STATUS)), Nil } ) // Aberto
					Aadd( aCab, { 'DTW_TIPOPE', StrZero(2,Len(DTW->DTW_STATUS)), Nil } ) // Tipo de Operacao == "Transporte"
					Aadd( aCab, { 'DTW_CATOPE', StrZero(2,Len(DTW->DTW_STATUS)), Nil } ) // Categoria da operacao 2=Eventual
					If lIdDTW .And. ExistFunc("Tm351IdDTW") 
						cIdDTW	:= Tm351IdDTW( DTW->DTW_FILORI, DTW->DTW_VIAGEM	)
						Aadd( aCab, { 'DTW_IDDTW'	, cIdDTW	    , Nil } )
					EndIf
					lGrvOk := TMSCriaDTW( aCab )
				EndIf
			EndIf

			//-- Para Coleta/Entrega devera ser atualizada a filial destino da viagem.
			If DTW->DTW_SERTMS <> StrZero(2,Len(DTW->DTW_SERTMS)) //-- Transporte
				DTQ->(DbSetOrder(2))
				If DTQ->(MsSeek(xFilial("DTQ")+aViagens[nB,1]+aViagens[nB,2]))
					RecLock("DTQ",.F.)
					DTQ->DTQ_FILDES := cFilAnt
					MsUnlock()
				EndIf
				// Posiciona a operacao de chegada/saida.
				// Encerra a operacao de transporte de chegada/saida da origem.
				DTW->(dbSetOrder(4))
				If DTW->(MsSeek(xFilial("DTW") + aViagens[nB, 1] + aViagens[nB, 2] + cAtividade + aViagens[nB, 1]))
					RecLock('DTW',.F.)
					DTW->DTW_DATREA := dDataBase
					DTW->DTW_HORREA := StrTran(Left(Time(),5),":","")
					DTW->DTW_STATUS := StrZero(9, Len(DTW->DTW_STATUS))
					DTW->( MsUnLock() )
				EndIf
			EndIf

		EndIf
		//-- Verifica se devera ser canceladas as operacoes em aberto
		If lGrvOk .And. nPCanOp <> 2

			DTW->(dbSetOrder(4))
			// Posiciona a operacao de chegada/saida.
			If DTW->(MsSeek(xFilial("DTW") + aViagens[nB, 1] + aViagens[nB, 2] + cAtividade + cFilAnt))
				//Guarda a sequencia da operacao de chegada/saida.
				cSeqAte := DTW->DTW_SEQUEN
				// Le todas a operacoes em aberto anteriores a de chegada/saida.
				DTW->(dbSetOrder(3))
				While DTW->(MsSeek(xFilial("DTW") + aViagens[nB, 1] + aViagens[nB, 2] +;
					StrZero(1, Len(DTW->DTW_STATUS)))) .And. DTW->DTW_SEQUEN < cSeqAte
					// Encerra as operacoes de transportes anteriores a de chegada/saida
					RegToMemory('DTW',.F.) //Carrega as variaveis
					M->DTW_DATINI := dDatIni
					M->DTW_HORINI := cHorIni
					M->DTW_DATREA := dDataBase
					M->DTW_HORREA := StrTran(Left(Time(),5),":","")
					M->DTW_FILATI := cFilAnt
					M->DTW_STATUS := StrZero(9, Len(DTW->DTW_STATUS))
					nCampos := DTW->( FCount() )
					RecLock('DTW',.F.)
					For nCntFor := 1 To nCampos
						FieldPut( nCntFor, M->&( Eval( bCampo,nCntFor ) ) )
					Next
					DTW->( MsUnLock() )
				EndDo
			EndIf
		EndIf
	Next nB
EndIf

If lGrvOk

	Begin Transaction

	// Seta as ordens necessarias
	dbSelectArea("DUT")
	dbSetOrder(1)
	dbSelectArea("DA3")
	dbSetOrder(1)

	// Gravacao de veiculos
	aValidH:=ACLONE(aSvFolder[1][1])
	aValidCols:=ACLONE(aSvFolder[1][2])
	dbSelectArea("DTU")
	dbSetOrder(2) //DTU_FILIAL+DTU_CODVEI+DTU_STATUS+DTU_NUMENT
	For nz := 1 to Len(aValidCols)
		If ValType(aValidCols[nz,Len(aValidCols[nz])]) == "L" .And. !aValidCols[nz,Len(aValidCols[nz])] .And. !Empty(aValidCols[nz,nPosVei])
			dbSelectArea("DTU")
			// Posiciona registros CASO SEJA liberacao ou saida
			If nOpc == 4     // Liberacao
				lSeek := .F.
				If	MsSeek(xFilial("DTU")+aValidCols[nz,nPosVei]+"1") // Em Aberto
					lSeek := .T.
				EndIf
			ElseIf nOpc == 5 // Saida
				lSeek := .F.
				If	MsSeek(xFilial("DTU")+aValidCols[nz,nPosVei]+"1") .Or. ; // Em Aberto
					MsSeek(xFilial("DTU")+aValidCols[nz,nPosVei]+"2") .Or. ; // Liberado
					MsSeek(xFilial("DTU")+aValidCols[nz,nPosVei]+"3")        // Reservado
					lSeek := .T.
				EndIf
			EndIf
			If lSeek
				Reclock("DTU",nOpc==3)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza dados do DTU BASEADO na MSMGET                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For zx := 1 TO Len(aVisual)
					nPos:=FieldPos("DTU"+Substr(aVisual[zx],4))
					If nPos > 0
						FieldPut(nPos,M->&(aVisual[zx]))
					EndIf
				Next zx
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza dados do DTU BASEADO na GETDADOS                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nOpc == 3
					Replace DTU_FILIAL with xFilial("DTU")
					Replace DTU_FILVGE with cFilOri
					Replace DTU_NUMVGE with cViagem
					For zx := 1 to Len(aValidH)
						If aValidH[zx][10] # "V"
							xVar := Trim(aValidH[zx][2])
							Replace &xVar. With aValidCols[nz][zx]
						Endif
					Next zx
				ElseIf nOpc == 5
					If nPosOdo > 0
						Replace DTU_ODOSAI With aValidCols[nz,nPosOdo]
					EndIf
					Replace DTU_FILVGS with cFilOri
					Replace DTU_NUMVGS with cViagem
				EndIf
				If nOpc != 8
					Replace DTU_STATUS With cStatus
				EndIf

				MsUnlock()

				//- Nao atualiza o status do generico
				If AllTrim(aValidCols[nz,nPosVei]) <> cVeiGen
					// Pesquisa o Veiculo
					dbSelectArea("DA3")
					dbSetOrder(1)
					If dbSeek(xFilial()+aValidCols[nz,nPosVei]) .And. DUT->(dbSeek(xFilial("DUT")+DA3->DA3_TIPVEI))
						// Comum
						If DUT->DUT_CATVEI == "1"
							cVeiculo :=aValidCols[nz,nPosVei]
							If (nOpc == 3 .Or. nOpc == 5) .And. nPosOdo > 0
								nOdometro:=aValidCols[nz,nPosOdo]
							EndIf
							// Cavalo
						ElseIf DUT->DUT_CATVEI == "2"
							cVeiculo :=aValidCols[nz,nPosVei]
							If (nOpc == 3 .Or. nOpc == 5) .And. nPosOdo > 0
								nOdometro:=aValidCols[nz,nPosOdo]
							EndIf
							// Carreta
						ElseIf DUT->DUT_CATVEI == "3"
							If Empty(cVeiculo1)
								cVeiculo1:=aValidCols[nz,nPosVei]
								If (nOpc == 3 .Or. nOpc == 5) .And. nPosOdo > 0
									nOdoRb1:=aValidCols[nz,nPosOdo]
								EndIf
							ElseIf Empty(cVeiculo2)
								cVeiculo2:=aValidCols[nz,nPosVei]
								If (nOpc == 3 .Or. nOpc == 5) .And. nPosOdo > 0
									nOdoRb2:=aValidCols[nz,nPosOdo]
								EndIf
							ElseIf Empty(cVeiculo3) 
								cVeiculo3:=aValidCols[nz,nPosVei]
								If (nOpc == 3 .Or. nOpc == 5) .And. nPosOdo > 0
									nOdoRb3:=aValidCols[nz,nPosOdo]
								EndIf
							Endif
							// Especial
						ElseIf DUT->DUT_CATVEI == "4"
							cVeiculo:=aValidCols[nz,nPosVei]
							If (nOpc == 3 .Or. nOpc == 5) .And. nPosOdo > 0
								nOdometro:=aValidCols[nz,nPosOdo]
							EndIf
						EndIf

						If nOpc == 3  // Entrada
							RecLock("DA3",.F.)
							DA3->DA3_STATUS := "2" // Em Filial
							DA3->DA3_FILATU := cFilAnt
							//DLOGTMS01-3186 - Alimentar Data e Hora do Status com Data e Hora Corrente.
							If DA3->(ColumnPos("DA3_DATSTS")) > 0 .And. DA3->(ColumnPos("DA3_HORSTS")) > 0
								DA3->DA3_DATSTS := M->DTU_DATENT
								DA3->DA3_HORSTS := M->DTU_HORENT
							EndIf
							MsUnLock()
						ElseIf nOpc == 5 .And. Empty(cViagem) .And. Empty(cFilOri)	//Saida s/ Viagem
							RecLock("DA3",.F.)
							DA3->DA3_STATUS := "1"	// Nao Disponivel
							DA3->DA3_FILATU := CriaVar("DA3_FILATU", .F.)
							DA3->DA3_FILVGA := CriaVar("DA3_FILVGA", .F.)
							DA3->DA3_NUMVGA := CriaVar("DA3_NUMVGA", .F.)
							//DLOGTMS01-3186 - Alimentar Data e Hora do Status com Data e Hora Corrente.
							If DA3->(ColumnPos("DA3_DATSTS")) > 0 .And. DA3->(ColumnPos("DA3_HORSTS")) > 0
								DA3->DA3_DATSTS := M->DTU_DATSAI
								DA3->DA3_HORSTS := M->DTU_HORSAI
							EndIf							
							MsUnLock()
						EndIf
					EndIf
				EndIf
			Else
				lGrvOk := .F.
				Exit
			EndIf
		EndIf
	Next nz

	If lGrvOk
		// Atualiza registro de entrada e saida de viagem
		If (nOpc == 3 .Or. nOpc == 5)
			If !Empty(cFilOri) .And. !Empty(cViagem)
				If	lMotorista
					dDatEnt := M->DTO_DATENT
					cHorEnt := M->DTO_HORENT
					dDatSai := M->DTO_DATSAI
					cHorSai := M->DTO_HORSAI
				Else
					dDatEnt := M->DTU_DATENT
					cHorEnt := M->DTU_HORENT
					dDatSai := M->DTU_DATSAI
					cHorSai := M->DTU_HORSAI
				EndIf
				Tmsa430Duv(nOpc==5,cFilOri,cViagem,cVeiculo,cVeiculo1,cVeiculo2,nOdometro,cFilAnt,dDatEnt,cHorEnt,dDatSai,cHorSai,nOdoRb1,nOdoRb2,cVeiculo3,nOdoRb3)
			EndIf
			//Funcao para Atualizar o Odometro - Integracao TMS X MNT (Manutencao de Ativos)
			TMSAtuMnt(cVeiculo,cVeiculo1,cVeiculo2,nOdometro,nOdoRb1,nOdoRb2,,,,,cVeiculo3,nOdoRb3)
		EndIf
		// Gravacao de motoristas
		aValidH    := ACLONE(aSvFolder[2][1])
		aValidCols := ACLONE(aSvFolder[2][2])
		dbSelectArea("DTO")
		dbSetOrder(2) // DTO_FILIAL+DTO_CODMOT+DTO_STATUS+DTO_NUMENT
		For nz:=1 to Len(aValidCols)
			If ValType(aValidCols[nz,Len(aValidCols[nz])]) == "L" .And. !aValidCols[nz,Len(aValidCols[nz])] .And. ;
				!Empty(aValidCols[nz,nPosMot]) .And. aValidCols[nz,nPosMot] <> cMotGen
				// Posiciona registros CASO SEJA liberacao ou saida
				If nOpc == 4     // Liberacao
					lSeek := .F.
					If	MsSeek(xFilial("DTO")+aValidCols[nz,nPosMot]+"1") // Em Aberto
						lSeek := .T.
					EndIf
				ElseIf nOpc == 5 // Saida
					lSeek := .F.
					If	MsSeek(xFilial("DTO")+aValidCols[nz,nPosMot]+"1") .Or. ; // Em Aberto
						MsSeek(xFilial("DTO")+aValidCols[nz,nPosMot]+"2") .Or. ; // Liberado
						MsSeek(xFilial("DTO")+aValidCols[nz,nPosMot]+"3")        // Reservado
						lSeek := .T.
					EndIf
				EndIf
				If lSeek
					Reclock("DTO",nOpc==3)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza dados BASEADO na MSMGET                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For zx := 1 TO Len(aVisual)
						nPos:=FieldPos("DTO"+Substr(aVisual[zx],4))
						If nPos > 0
							FieldPut(nPos,M->&(aVisual[zx]))
						EndIf
					Next zx
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza dados BASEADO na GETDADOS                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpc == 3
						Replace DTO_FILIAL with xFilial()
						Replace DTO_FILVGE with cFilOri
						Replace DTO_NUMVGE with cViagem
						For zx := 1 to Len(aValidH)
							If aValidH[zx][10] # "V"
								xVar := Trim(aValidH[zx][2])
								Replace &xVar. With aValidCols[nz][zx]
							Endif
						Next zx
					ElseIf nOpc == 5
						Replace DTO_FILVGS with cFilOri
						Replace DTO_NUMVGS with cViagem
					EndIf
					Replace DTO_STATUS With cStatus
					MsUnlock()
               
					//-- Atualização da jornada do motorista - DEW
               If lAptJor .And. Empty(cViagem) .And. Empty(cFilOri)  
               
               	If nOpc == 3
               		cAptJor := "IJ"
               	ElseIf nOpc == 5
               		cAptJor := "FJ"
               	EndIf 
               	
               	If !Empty(cAptJor) .And. FindFunction("TMSAptJor")
               		TMSAptJor( aValidCols[nz,nPosMot] , cAptJor , dDatIni , cHorIni )
               		cAptJor	:= ""
                  EndIf
               EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Faz a atualizacao dos dados de Seguro no Cadastro de Motoristas ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpc == 4
						//-- Nao atualiza motoristas genericos
						If AllTrim(aValidCols[nz,nPosMot]) <> cMotGen
							dbSelectArea( "DA4" )
							dbSetOrder( 1 )
							If dbSeek( xFilial( "DA4" ) + aValidCols[nZ][aScan( aValidH, {|ExpA1| AllTrim(ExpA1[2]) == "DTO_CODMOT"} )] )
								nPosLibSeg := aScan( aValidH, {|ExpA1| AllTrim(ExpA1[2]) == "DTO_LIBSEG"} )
								nPosValSeg := aScan( aValidH, {|ExpA1| AllTrim(ExpA1[2]) == "DTO_VALSEG"} )
								If nPosLibSeg > 0 .And. nPosValSeg > 0
									cLibSeg := aValidCols[nZ][nPosLibSeg]
									nValSeg := aValidCols[nZ][nPosValSeg]
									RecLock( "DA4" , .F. )
									If !Empty(cLibSeg) .And. nValSeg > 0
										DA4->DA4_LIBSEG := cLibSeg
										DA4->DA4_VALSEG := nValSeg
									EndIf
									MsUnlock()
								EndIf
							EndIf
							dbSelectArea( "DTO" )
						EndIf
					EndIf
				Else
					lGrvOk := .F.
					Exit
				EndIf
			EndIf
		Next nz
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Faz a gravacao dos dados de Regiao do Motorista                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpc == 4 .And. !Empty( aDadoRegMot ) .And. lGrvOk
		dbSelectArea( "DTB" )
		dbSetOrder( 1 )

		For nZ := 1 To Len( aDadoRegMot )
			For nB := 1 To Len( aDadoRegMot[nZ][2] )
				If ! aTail( aDadoRegMot[nZ][2][nB] )
					dbSelectArea( "DTB" )
					RecLock( "DTB" , .T. )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Dados de Header                                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Replace DTB_FILIAL With xFilial( "DTB" )
					Replace DTB_NUMLIB With DTU->DTU_NUMLIB
					Replace DTB_CODMOT With aDadoRegMot[nZ][1]

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Dados de Item                                                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					For nA := 1 To Len( aDadoRegMot[nZ][3] )
						If Upper( aDadoRegMot[nZ][3][nA][10] ) != "V"
							nPos := FieldPos( aDadoRegMot[nZ][3][nA][2] )
							FieldPut(nPos,aDadoRegMot[nZ][2][nB][nA])
						EndIf
					Next nA

					MsUnlock()
				EndIf
			Next nB
		Next nZ

		dbSelectArea( "DTO" )
	EndIf

	//-- Liberação dos Cavalos e Motoristas na chegada final da viagem de transferência
	If nOpc == 3
		For nA := 1 To Len(aViagens)
			TMA490LibV(aViagens[nA,1],aViagens[nA,2])
		Next nA
	EndIf

	If !lGrvOk
		DisarmTransaction()
	EndIf

	End Transaction

EndIf

If lGrvOk
	If lTM430GRV
		ExecBlock('TM430GRV',.F.,.F.,{nOpc,aViagens})
	EndIf
Else
	lRet := .F.
	Help('',1,'TMSA43022') //-- Erro ao atualizar movimento de veiculos/motoristas
EndIf

RestArea(aAreaDTR)
RestArea(aAreaDTQ)
RestArea(aAreaDTO)
RestArea(aAreaDTU)
RestArea(aArea)

RETURN lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA430Con³ Autor ³Rodrigo de A. Sartorio ³ Data ³06.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Monta as consultas de veiculo e motorista                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA430Con(ExpN1,ExpC1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tipo da consulta 1 - veiculo 2 - motorista         ³±±
±±³          ³ ExpC1 = Status a ser pesquisado                            ³±±
±±³          ³ ExpN2 = Numero da linha a ser atualizada                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA430Con(nTipo,nOpc,n)

Local aAreaAnt := GetArea()
Local aAreaDTU := DTU->( GetArea() )
Local aAreaDTO := DTO->( GetArea() )
Local cStatus  := "1"

Default nTipo  :=1

If If(lMotorista,Empty(M->DTO_VIAGEM),Empty(M->DTU_VIAGEM))
	If nTipo == 1
		If GDFieldPos("DTU_CODVEI") > 0
			If TmsConsDTU(cStatus,.T.,"DTU_CODVEI",n,If(nOpc == 4,.F.,.T.))
				If TMSA430St(1,DTU->DTU_CODVEI)
					RunTrigger(2,n,,o1Get,"DTU_CODVEI")
				EndIf
			EndIf
		EndIf
	ElseIf nTipo == 2
		If GDFieldPos("DTO_CODMOT") > 0
			If TmsConsDTO(cStatus,.T.,"DTO_CODMOT",n,If(nOpc == 4,.F.,.T.))
				If TMSA430St(2,DTO->DTO_CODMOT)
					RunTrigger(2,n,,o2Get,"DTO_CODMOT")
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

RestArea( aAreaDTU )
RestArea( aAreaDTO )
RestArea( aAreaAnt )

RETURN

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA430St ³ Autor ³Rodrigo de A. Sartorio ³ Data ³06.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida o status do veiculo e do motorista digitado         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA430St(ExpN1,ExpC1)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tipo da validacao 1 - veiculo 2 - motorista        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA430St(nTipo,cVarDigi)

Local lRet       := .T.
Local cAlias     := Alias()
Local aAreaDTO   := DTO->(GetArea())
Local aAreaDTU   := DTU->(GetArea())
Local cFilAtu    := ""
Local nTamCpo    := 0
Local nA         := 0
Local cCampo	 := ReadVar()

DEFAULT cVarDigi:=&(ReadVar())
DEFAULT nTipo :=1

If AllTrim( cCampo ) == "M->DTU_PLACA"
	cVarDigi:= Posicione( 'DA3', 3, xFilial( 'DA3' ) + cVarDigi, "DA3_COD" )  
EndIf

// Posiciona na area correta
If	nTipo == 1
	dbSelectArea("DTU")
	dbSetOrder(2)
	cFilAtu := xFilial("DTU")
	If	AllTrim(cVarDigi) <> cVeiGen .And. ;
		((nOpcx == 3 .And.  dbSeek(xFilial()+cVarDigi+"1")) .Or. ;
		( nOpcx == 4 .And. !dbSeek(xFilial()+cVarDigi+"1")) .Or. ;
		((nOpcx == 3 .Or. nOpcx == 4) .And. dbSeek(xFilial()+cVarDigi+"2")) .Or.;
		((nOpcX == 3 .Or. nOpcX == 4) .And. dbSeek(xFilial()+cVarDigi+"3")))
		lRet := .F.
	EndIf
ElseIf	nTipo == 2
	dbSelectArea("DTO")
	dbSetOrder(5)
	cFilAtu := ""
	If	AllTrim(cVarDigi) <> cMotGen .And. ;
		((nOpcx == 3 .And.  dbSeek(cVarDigi+"1")) .Or.;
		( nOpcx == 4 .And. !dbSeek(cVarDigi+"1")) .Or.;
		((nOpcx == 3 .Or. nOpcx == 4) .And. dbSeek(cVarDigi+"2")) .Or.;
		((nOpcX == 3 .Or. nOpcX == 4) .And. dbSeek(cVarDigi+"3")))
		lRet := .F.
	EndIf
EndIf

If !lRet
	Help(" ",1,"TMSA43012") //"Informe um VEICULO/MOTORISTA valido para esse movimento"
EndIf

If lRet .And. nOpcx == 3

	/* Entrada de veiculo sem viagem. */
	If  nTipo == 1
		If ( Iif( !lMotorista, Empty(M->DTU_FILORI) .And. Empty(M->DTU_VIAGEM),Empty(M->DTO_FILORI) .And. Empty(M->DTO_VIAGEM) ) )
			TA430SgMot(cVarDigi)
		EndIf
	EndIf

ElseIf lRet .And. ( nOpcx == 4 .Or. nOpcx == 5)// Na Liberacao ou Saida sugere o motorista X veiculo vinculados.
	If nOpcx == 4
		dbSeek(cFilAtu+cVarDigi+"1")
		TA430NEntr(nTipo,cVarDigi)
	Else
		nTamCpo := Iif( lMotorista, Len( DTO->DTO_STATUS ), Len( DTU->DTU_STATUS ) )
		For nA := 1 To 3
			If MsSeek( cFilAtu + cVarDigi + StrZero( nA, nTamCpo ) )
				TA430NEntr(nTipo,cVarDigi)
				Exit
			EndIf
		Next nA
	EndIf
EndIf

// Restaura area
If nTipo == 1
	RestArea(aAreaDTU)
ElseIf nTipo == 2
	RestArea(aAreaDTO)
EndIf
dbSelectArea(cAlias)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Tmsa430Duv³ Autor ³Rodrigo de A. Sartorio ³ Data ³07.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualiza arquivo DUV de acordo com parametros relatados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA430Duv(ExpL1,ExpC1,ExpC2,ExpC3,ExpC4,ExpC5,ExpN1,ExpC6,³±±
±±³          ³ ExpD1,ExpC7,ExpD2,ExpC8)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpL1 = Flag que indica se esta atualizando saida (.T.)    ³±±
±±³          ³ ExpC1 = Filial Origem                                      ³±±
±±³          ³ ExpC2 = Viagem                                             ³±±
±±³          ³ ExpC3 = Veiculo                                           ³±±
±±³          ³ ExpC4 = Veiculo 1                                          ³±±
±±³          ³ ExpC5 = Veiculo 2                                          ³±±
±±³          ³ ExpN1 = Odometro do Veiculo 1                              ³±±
±±³          ³ ExpC6 = Filial de Entrada / Saida                          ³±±
±±³          ³ ExpD1 = Data de Entrada                                    ³±±
±±³          ³ ExpC7 = Hora de Entrada                                    ³±±
±±³          ³ ExpD2 = Data de Saida                                      ³±±
±±³          ³ ExpC8 = Hora de Saida                                      ³±±
±±³          ³ ExpN2 = Odometro do Reboque1                               ³±±
±±³          ³ ExpN3 = Odometro do Reboque2                               ³±±
±±³          ³ ExpN4 = Veiculo 3			                                ³±±
±±³          ³ ExpN5 = Odometro do Reboque3                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Tmsa430Duv(lSaida,cFilOri,cViagem,cVeiculo,cVeiculo1,cVeiculo2,nOdometro,cFilEntSai,dDatEnt,cHorEnt,dDatSai,cHorSai,nOdoRb1,nOdoRb2,cVeiculo3,nOdoRb3)

Local aArea    := GetArea(),aDadosVg := TMSPesoVge(cFilOri,cViagem)
Local bCampo   := {|x| FieldName(x) }
Local nCampos  := 0
Local nCntFor  := 0
Local aAreaDTR := DTR->(GetArea())
Local nPeso    := aDadosVg[1]
Local nPesoM3  := aDadosVg[2]
Local nPesoSt  := aDadosVg[4]
Local nPes3St  := aDadosVg[5]
Local cFilOld  := ""
Local cVgeOld  := ""         
Local lTM430DUV:= ExistBlock('TM430DUV')
Local lTercRbq := DTR->(ColumnPos("DTR_CODRB3")) > 0

DEFAUlT lSaida    := .T.
DEFAULT cFilOri   := ""
DEFAULT cViagem   := ""
DEFAULT cFilEntSai := ""
DEFAULT cVeiculo  := ""
DEFAULT cVeiculo1 := ""
DEFAULT cVeiculo2 := ""
DEFAULT cVeiculo3 := ""
DEFAULT nOdometro := 0
DEFAULT dDatEnt   := CtoD('')
DEFAULT dDatSai   := CtoD('')
DEFAULT cHorEnt   := ''
DEFAULT cHorSai   := ''
DEFAULT nOdoRb1   := 0
DEFAULT nOdoRb2   := 0
DEFAULT nOdoRb3	  := 0
// Inclui registro de saida do veiculo
If lSaida

	//-- Soma Peso de todas viagens interligadas
	DTR->(DbSetOrder(2))
	If DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem))
		While DTR->(!Eof()) .And. DTR->DTR_FILIAL + DTR->DTR_FILVGE + DTR->DTR_NUMVGE == xFilial("DTR") + cFilOri + cViagem
			If cFilOld + cVgeOld <> DTR->DTR_FILORI + DTR->DTR_VIAGEM
				aDadosVg := TMSPesoVge(DTR->DTR_FILORI,DTR->DTR_VIAGEM)
				nPeso    += aDadosVg[1]
				nPesoM3  += aDadosVg[2]
			EndIf
			cFilOld := DTR->DTR_FILORI
			cVgeOld := DTR->DTR_VIAGEM
			DTR->(DbSkip())
		EndDo
	EndIf

	RegToMemory('DUV',.T.)
	M->DUV_FILIAL := xFilial('DUV')
	M->DUV_FILORI := cFilOri
	M->DUV_VIAGEM := cViagem
	M->DUV_CODVEI := cVeiculo
	M->DUV_CODRB1 := cVeiculo1
	M->DUV_CODRB2 := cVeiculo2
	M->DUV_PESO   := nPeso
	M->DUV_PESOM3 := nPesoM3
	M->DUV_FILSAI := cFilEntSai
	M->DUV_ODOSAI := nOdometro
	M->DUV_DATSAI := dDatSai
	M->DUV_HORSAI := cHorSai
	//-- Atualiza o odometro dos reboques
	M->DUV_ODOSR1 := nOdoRb1
	M->DUV_ODOSR2 := nOdoRb2
	If lTercRbq
		M->DUV_CODRB3 := cVeiculo3
		M->DUV_ODOSR3 := nOdoRb3
	EndIf
	
	nCampos := DUV->( FCount() )
	RecLock('DUV',.T.)
	For nCntFor := 1 To nCampos
		FieldPut( nCntFor, M->&( Eval( bCampo,nCntFor ) ) )
	Next
	DUV->(MsUnlock())
	// Procura registro da saida e atualiza registro de entrada do veiculo
Else

	//-- Soma Peso estatistico de todas viagens interligadas
	DTR->(DbSetOrder(2))
	If DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem))
		While DTR->(!Eof()) .And. DTR->DTR_FILIAL + DTR->DTR_FILVGE + DTR->DTR_NUMVGE == xFilial("DTR") + cFilOri + cViagem
			If cFilOld + cVgeOld <> DTR->DTR_FILORI + DTR->DTR_VIAGEM
				aDadosVg := TMSPesoVge(DTR->DTR_FILORI,DTR->DTR_VIAGEM)
				nPesoSt  += aDadosVg[4]
				nPes3St  += aDadosVg[5]
			EndIf
			cFilOld := DTR->DTR_FILORI
			cVgeOld := DTR->DTR_VIAGEM
			DTR->(DbSkip())
		EndDo
	EndIf

	dbSelectArea("DUV")
	dbSetOrder(2)
	If dbSeek(xFilial()+cFilOri+cViagem+cVeiculo+Criavar("DUV_FILENT",.F.))
		Reclock("DUV",.F.)
		DUV->DUV_FILENT := cFilEntSai
		DUV->DUV_ODOENT := nOdometro
		DUV->DUV_DATENT := dDatEnt
		DUV->DUV_HORENT := cHorEnt
		DUV->DUV_PESOST := nPesoSt
		DUV->DUV_PES3ST := nPes3St
		//-- Atualiza o odometro dos reboques
		DUV->DUV_ODOER1 := nOdoRb1
		DUV->DUV_ODOER2 := nOdoRb2
		If lTercRbq
			DUV->DUV_ODOER3 := nOdoRb3
		EndIf
		DUV->(MsUnlock())
	EndIf
EndIf
                        
If lTM430DUV
	ExecBlock("TM430DUV",.F.,.F.,{lSaida, cFilOri, cViagem, dDatSai})
EndIf

RestArea( aArea    )
RestArea( aAreaDTR )

RETURN

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430NEntr³ Autor ³ Rodrigo de A. Sartorio³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere veiculos X motoristas de acordo com dados digitados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Tipo da validacao 1 - veiculo 2 - motorista        ³±±
±±³          ³ ExpC1 = Codigo Veiculo / Motorista                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA430NEntr(nTipo,cVarDigi)

Local cNumEnt := ""
Local aArea   := GetArea()
Local aArea2  := {}
Local aSoma   := {}
Local nOri    := 0
Local aValida := {}
Local lSoma   := .T.
Local nz      := 0

If nTipo == 1 // Digitou veiculos -> Inicializa Motorista

	DbSelectArea("DA3")
	If MsSeek(xFilial("DA3")+cVarDigi) .And. DUT->(MsSeek(xFilial("DUT")+DA3->DA3_TIPVEI))

		If DUT->DUT_CATVEI <> "3" // Carreta

			// Pesquisa Motoristas pelo numero de entrada
			cNumEnt := DTU->DTU_NUMENT
			aValida := ACLONE(aSvFolder[2,2])

			// Caso o motorista nao estiver informado, sugere o motorista que entrou com o veiculo
			If Len(aValida) == 0 .Or. Empty(aValida[1,1])
				aArea2 := DTO->(GetArea())
				DbSelectArea("DTO")
				DbSetOrder(1)
				If MsSeek(xFilial("DTO")+cNumEnt)
					While DTO->(!Eof()) .And. DTO_FILIAL + DTO_NUMENT == xFilial("DTO") + cNumEnt
						If	DTO->DTO_STATUS == StrZero(1,Len(DTO->DTO_STATUS)) .Or. ;	//-- Em Aberto
							DTO->DTO_STATUS == StrZero(2,Len(DTO->DTO_STATUS))			//-- Liberado
							Aadd(aSoma,AClone(aColsOri2[1])) // Inclui Linha em branco no array que somara motoristas
							aSoma[Len(aSoma),nPosMot]:= DTO->DTO_CODMOT // Busca as informacoes do arquivo
						EndIf
						DbSkip()
					EndDo
				EndIf
				RestArea(aArea2)

				// Caso existam motoristas a serem somados
				If Len(aSoma) > 0
					// Salva Getdados Atual
					aSvFolder[1,1]:= Aclone(aHeader)
					aSvFolder[1,2]:= Aclone(aCols)
					aSvFolder[1,3]:= Len(aCols)
					// Preenche na getdados dos motoristas as informacoes
					aHeader := Aclone(aSvFolder[2,1])
					aCols	:= Aclone(aSvFolder[2,2])
					If Empty(aCols[Len(aCols),nPosMot])
						nOri    := Len(aCols)-1
					Else
						nOri    := Len(aCols)
					EndIf
					ASIZE(aCols,nOri+Len(aSoma))
					For nz:=nOri+1 to Len(aCols)
						aCols[nz]:=ACLONE(aSoma[nz-nOri])
					Next nz
					// Executa gatilhos
					For nz:=1 to Len(aCols)
						RunTrigger(2,nz,,o2Get,"DTO_CODMOT")
					Next nz
					// Salva a getdados dos motoristas
					aSvFolder[2,1]:= Aclone(aHeader)
					aSvFolder[2,2]:= Aclone(aCols)
					aSvFolder[2,3]:= Len(aCols)
					// Volta a GetDados dos veiculos
					aHeader:=ACLONE(aSvFolder[1,1])
					aCols:=ACLONE(aSvFolder[1,2])
					n:=aSvFolder[1,3]
				EndIf
			EndIf
		EndIf
	EndIf

ElseIf nTipo == 2 // Digitou motoristas -> Inicializa Veiculos
	// Pesquisa Veiculos pelo numero de entrada
	cNumEnt:=DTO->DTO_NUMENT
	aValida:=ACLONE(aSvFolder[1,2])
	dbSelectArea("DTU")
	aArea2:=GetArea()
	dbSetOrder(1)
	dbSeek(xFilial("DTU")+cNumEnt)
	While !Eof() .And. DTU_FILIAL+DTU_NUMENT == xFilial("DTU")+cNumEnt
		lSoma:=.T.
		// Valida se o veiculo ja foi digitado
		For nz:=1 to Len(aValida)
			If aValida[nz,nPosVei] == DTU->DTU_CODVEI
				lSOMA:=.F.
			EndIf
		Next nz
		// Verifica se pode somar
		If lSoma
			If DTU->DTU_STATUS == StrZero(1,Len(DTU->DTU_STATUS)) //-- Em Aberto
				// Inclui Linha em branco no array que somara motoristas
				AADD(aSoma,ACLONE(aColsOri1[1]))
				// Busca as informacoes do arquivo
				aSoma[Len(aSoma),nPosVei]   := DTU->DTU_CODVEI
			EndIf
		EndIf
		dbSkip()
	End
	RestArea(aArea2)
	// Caso existam veiculos a serem somados
	If Len(aSoma) > 0
		// Salva Getdados Atual
		aSvFolder[2,1]:= Aclone(aHeader)
		aSvFolder[2,2]:= Aclone(aCols)
		aSvFolder[2,3]:= Len(aCols)
		// Preenche na getdados dos veiculos as informacoes
		aHeader := Aclone(aSvFolder[1,1])
		aCols	:= Aclone(aSvFolder[1,2])
		If Empty(aCols[Len(aCols),nPosVei])
			nOri    := Len(aCols)-1
			ASIZE(aCols,nOri+Len(aSoma))
			For nz:=nOri+1 to Len(aCols)
				aCols[nz]:=ACLONE(aSoma[nz-nOri])
			Next nz
			// Executa gatilhos
			For nz:=1 to Len(aCols)
				RunTrigger(2,nz,,o1Get,"DTU_CODVEI")
			Next nz
		EndIf
		// Salva a getdados dos veiculos
		aSvFolder[1,1]:= Aclone(aHeader)
		aSvFolder[1,2]:= Aclone(aCols)
		aSvFolder[1,3]:= Len(aCols)
		// Volta a GetDados dos motoristas
		aHeader:=ACLONE(aSvFolder[2,1])
		aCols:=ACLONE(aSvFolder[2,2])
		n:=aSvFolder[2,3]
	EndIf
EndIf

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430Ok   ³ Autor ³ Rodrigo de A. Sartorio³ Data ³19.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida data e hora(Liberacao / Saida).                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430Ok()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA430Ok(nOpc)

Local lRet     := .T.
Local nPosLIB  := aScan( aSvFolder[2][1],{|ExpA1| AllTrim(ExpA1[2]) == "DTO_LIBSEG"} )
Local nPosVAL  := aScan( aSvFolder[2][1],{|ExpA1| AllTrim(ExpA1[2]) == "DTO_VALSEG"} )
Local nX       := 0
Local aColsVei := aClone( aSvFolder[1][2] )
Local aColsMot := aClone( aSvFolder[2][2] )
Local lRetPE   := .F.

If lMotorista
	If nOpc == 4 // Liberacao
		lRet := ValDatHor(M->DTO_DATLIB,M->DTO_HORLIB,DTO->DTO_DATENT,DTO->DTO_HORENT)
	ElseIf nOpc == 5 // Saida
		lRet := ValDatHor(M->DTO_DATSAI,M->DTO_HORSAI,DTO->DTO_DATLIB,DTO->DTO_HORLIB)
	EndIf
	// Veiculos.
Else
	If nOpc == 4  // Liberacao
		lRet := ValDatHor(M->DTU_DATLIB,M->DTU_HORLIB,DTU->DTU_DATENT,DTU->DTU_HORENT)
	ElseIf nOpc == 5  // Saida
		lRet := ValDatHor(M->DTU_DATSAI,M->DTU_HORSAI,DTU->DTU_DATLIB,DTU->DTU_HORLIB)
	EndIf
EndIf

If lRet
	For nX := 1 To Len( aColsMot )
		If !GdDeleted( nX , aSvFolder[2][1] , aColsMot )
			If nOpc == 3 //-- Entrada
				If !TA430MotOk(aColsMot[nX,nPosMot])
					lRet := .F.
					Exit
				EndIf
			ElseIf nOpc == 4 //-- Liberacao
				If nModulo <> 39 //-- Frete Embarcador
					If	( Empty( aColsMot[nX][nPosLIB] ) .And. !Empty( aColsMot[nX][nPosVAL] ) ) .Or. ;
						(!Empty( aColsMot[nX][nPosLIB] ) .And.  Empty( aColsMot[nX][nPosVAL] ) )
						Help(" ",1,"TMSA43017") // Nao foi possivel encontrar os dados de Liberacao de Seguro ou Valor de Seguro
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next nX
EndIf

If lTM430TOK
	lRetPE:= ExecBlock('TM430TOK',.F.,.F., { nOpc, aColsVei, aColsMot })
	If ValType(lRetPE) == "L"
		lRet:= lRetPE
	EndIf
EndIf

Return( lRet )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA430Vld³ Autor ³ Robson Alves          ³ Data ³28.10.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida a quilometragem de entrada.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA430Vld()                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA430Vld()

Local cCampo   := ReadVar()
Local lRet     := .T.
Local nAux     := 0
Local lFilBas  := DA4->( FieldPos('DA4_FILBAS') ) > 0
Local aArea    := GetArea()
Local aAreaDUV := DUV->( GetArea() )
Local aAreaDA4 := DA4->( GetArea() )

If cCampo == "M->DTU_CODVEI"
	If AllTrim(M->DTU_CODVEI) == cVeiGen
		Help(" ",1,"TMSA43049") //-- "Veiculo Generico, informe outro veiculo."
		lRet := .F.
	EndIf

ElseIf cCampo == "M->DTU_ODOENT"

	lRet := TMSVOdoEnt(aCols[n,GDFieldPos("DTU_CODVEI")],M->DTU_ODOENT,,,,	If(lMotorista,M->DTO_DATENT,M->DTU_DATENT))

ElseIf cCampo == "M->DTO_CODMOT"

	If nOpcx <> 3 .And. AllTrim(M->DTO_CODMOT) == cMotGen
		Help(" ",1,"TMSA43050") //"Motorista Generico, informe outro motorista."
		lRet := .F.
	EndIf

	//-- Verifica se o motorista esta demitido ou afastado (SRA).
	If lRet
		DA4->( DbSetOrder(1) )
		If DA4->( DbSeek( xFilial('DA4') + M->DTO_CODMOT ) )
			lRet := TMSVldFunc( DA4->DA4_MAT, If( lFilBas, DA4->DA4_FILBAS, '' ) )
		EndIf
	EndIf

	If lRet .And. nOpcx == 3 //Entrada
		lRet := TA430MotOk(M->DTO_CODMOT)
	EndIf

	If lRet .And. nOpcx == 4 //-- Liberacao
		If M->DTO_CODMOT != aCols[N][aScan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DTO_CODMOT"})]
			nAux := IIf( Type( "aDadoRegMot" ) == "A",aScan( aDadoRegMot,{|ExpA1| ExpA1[1] == aCols[N][aScan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DTO_CODMOT"})]} ),0)
			If ( lRet ) .And. ( nAux > 0 )
				//"Existe uma Região do Motorista cadastrada, deseja realmente efetuar a alteração do código? (os dados de Região do Motorista serão perdidos)"
				If MsgYesNo( STR0022 ,STR0020)
					aDel(aDadoRegMot,nAux)
					aSize(aDadoRegMot,Len(aDadoRegMot)-1)
				Else
					lRet := .F.
				EndIf
			EndIf
		EndIf
	EndIf

EndIf

RestArea( aAreaDA4 )
RestArea( aAreaDUV )
RestArea( aArea )
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430SgMot³ Autor ³ Robson Alves          ³ Data ³14.01.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere o motorista vinculado ao veiculo.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA430SgMot(cCodVei)

Local aSoma    := {}
Local aValida  := ACLONE(aSvFolder[2,2]) // ACols Motoristas.
Local aAreaDA3 := DA3->(GetArea())
Local aAreaDA4 := DA4->(GetArea())
Local nOri     := 0
Local nz       := 0

DA3->(dbSetOrder(1))
DA4->(dbSetOrder(1))

// Caso o motorista nao estiver informado, sugere o motorista informado no cadastro de veiculo.
If Len(aValida) == 0 .Or. Empty(aValida[1,1])

	/* Verifica se o motorista esta vinculado ao veiculo. */
	If DA3->(MsSeek(xFilial("DA3") + cCodVei)) .And. !Empty(DA3->DA3_MOTORI)
		If DA4->(MsSeek(xFilial("DA4") + DA3->DA3_MOTORI))
			/* Verifica se o motorista ainda nao foi digitado. */
			If Ascan(aValida, {|x| x[nPosMot] == DA4->DA4_COD}) == 0
				/* Preenche o array com o codigo do motorista. */
				AADD(aSoma, ACLONE(aColsOri2[1]))
				aSoma[Len(aSoma), nPosMot] := DA4->DA4_COD
			EndIf
		EndIf
		If Len(aSoma) > 0
			/* Salva Getdados Atual(Veiculos). */
			aSvFolder[1,1]:= Aclone(aHeader)
			aSvFolder[1,2]:= Aclone(aCols)
			aSvFolder[1,3]:= Len(aCols)
			/* Preenche a getdados dos motoristas. */
			aHeader := Aclone(aSvFolder[2,1])
			aCols	  := Aclone(aSvFolder[2,2])
			nOri    := Iif(Empty(aCols[Len(aCols), nPosMot]), (Len(aCols) - 1), Len(aCols))
			ASIZE(aCols, nOri + 1)
			For nz := nOri + 1 To Len(aCols)
				aCols[nz] := ACLONE(aSoma[nz - nOri])
			Next nz
			/* Executa os gatilhos. */
			For nz := 1 To Len(aCols)
				RunTrigger(2,nz,,o2Get,"DTO_CODMOT")
			Next nz
			/* Salva a getdados dos motoristas. */
			aSvFolder[2,1] := Aclone(aHeader)
			aSvFolder[2,2] := Aclone(aCols)
			aSvFolder[2,3] := Len(aCols)
			/* Volta a GetDados dos veiculos. */
			aHeader := ACLONE(aSvFolder[1,1])
			aCols   := ACLONE(aSvFolder[1,2])
			n       := aSvFolder[1,3]
		EndIf
	EndIf
EndIf

RestArea(aAreaDA3)
RestArea(aAreaDA4)

Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA430NEt³ Autor ³Rodrigo de A. Sartorio ³ Data ³06.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa o numero de entrada.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA430NEt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA430NEt()
Local cNumero := ""

If	lEntrada
	cNumero := GetSX8Num("DTU", "DTU_NUMENT", , 1)
EndIf

Return( cNumero )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA430NLb³ Autor ³Rodrigo de A. Sartorio ³ Data ³06.08.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inicializa o numero de liberacao.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA430NLb()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nil                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA430NLb()
Local cNumero := ""

If lLiberacao 
	If Type( "M->DTU_NUMLIB" ) == "U"
		cNumero := GetSX8Num("DTU", "DTU_NUMLIB", , 4)
	EndIf
EndIf

Return( cNumero )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TA430RegMo³ Autor ³Fernando Salvatori     ³ Data ³17/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Realiza a manutencao dos dados de Regiao por Motorista     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430RegMot(ExpA1,ExpN2,ExpN3,ExpO4)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA1 -> aCols e aHeader atual                             ³±±
±±³          ³ ExpN2 -> Posicao do registro do aCols                      ³±±
±±³          ³ ExpN3 -> Opcao selecionada                                 ³±±
±±³          ³ ExpO4 -> Objeto Folder                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TA430RegMot(aSvFolder,nPosCols,nOpc,oFolder)

Local aArea      := GetArea( )					//Area do sistema
Local aBackCols  := IIf( Type( "aCols" )   == "A",     aClone( aCols )  , {} ) //Backup aCols
Local aBackHead  := IIf( Type( "aHeader" ) == "A",     aClone( aHeader ), {} ) //Backup aHeader
Local aBackTela	 := IIf( Type( "aTela" )   == 'A',     aClone( aTela )  , {} ) //Backup aTela
Local aBackGets  := IIf( Type( "aGets" )   == 'A',     aClone( aGets )  , {} ) //Backup aGets
Local aBackDadR  := IIf( Type( "aDadoRegMot" ) == 'A', aClone( aDadoRegMot ), {} ) //Backup aGets
Local nBackN     := IIf( Type( "N" ) == "N", N, 1) //BackUp posicao do aCols
Local nPosCdMot  := aScan( aHeader, {|ExpA1| AllTrim(ExpA1[2]) == "DTO_CODMOT"} ) //Posicao do codigo do motorista
Local aNoFields  := {} //Campos nao exibidos no aCols
Local bInit       //Codeblock para Init do MSDIALOG
Local bValid      //Valid do DIALOG
Local oDlgReg     //Objeto de Tela
Local oPanel      //Objeto do Painel
Local nX         := 0 //Var Auxiliar
Local cMotorista := ""  //Codigo do Motorista
Local cDescMotor := ""  //Descricao do Motorista
Local aTmsVisual := {}  //Campos visuais
Local aTmsAltera := {}  //Campos alteraveis
Local aYesFields := {}  //Campos utilizados no aCols
Local lOK        := .F. //Confirmacao da tela
Local nAux       := 0  //Variavel auxiliar
Local aLimpCols  := {} //Retirar os registros deletados do aCols
Local lLGPD		 := FindFunction('FWPDCanUse') .And. FWPDCanUse(.T.) .And. FindFunction('TMLGPDCpPr')
Local lOfusca    := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se o usuario selecionou o motorista da folder de motoristas    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If oFolder:nOption != 2
	Return
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verificar se a posicao atual do registro esta com motorista digitado     ³
//³e verificando tambem se o mesmo encontra-se deletado                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty( aCols[N][nPosCdMot] ) .Or. aTail( aCols[n] )
	Return
EndIf

Private aTela[0][0]
Private aGets[0]
Private oGetD		  //Objeto do GetDados

cMotorista := aCols[N][nPosCdMot]

If lLGPD
	If Len(FwProtectedDataUtil():UsrAccessPDField( __CUSERID, {"DA4_NOME"} )) == 0		
		cDescMotor := Replicate('*',TamSX3('DA4_NOME')[1])
		lOfusca:= .T.
	EndIf	
EndIf

If !lOfusca	
	cDescMotor := Posicione("DA4",1,xFilial("DA4") + aCols[N][nPosCdMot],"DA4_NOME")
EndIf		

dbSelectArea("DTB")
dbSetOrder(1)

RegToMemory("DTB", .T. )

aHeader := {}
aCols := {}
N := 1

Aadd( aTmsVisual, 'DTB_CODMOT' )
Aadd( aTmsVisual, 'DTB_NOMMOT' )

Aadd( aTmsAltera, 'DTB_CODMOT' )

Aadd( aNoFields, 'DTB_CODMOT' )
Aadd( aNoFields, 'DTB_NOMMOT' )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configura as variaveis da MSGETDADOS                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
TMSFillGetDados(IIf(nOpc == 2,2,3), 'DTB', 1,xFilial( 'DTB' ) + DTU->DTU_NUMLIB + cMotorista, ;
{ || 	DTB->DTB_FILIAL + DTB->DTB_NUMLIB + DTB->DTB_CODMOT }, { || .T. }, aNoFields,	aYesFields )

If nOpc != 2
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso exista dados cadastrados para o motorista selecionado, traze-los    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nAux := aScan( aDadoRegMot, {|ExpA1| ExpA1[1] == cMotorista} )
	If nAux > 0
		aCols := aClone( aDadoRegMot[nAux][2] )
	Else
		If nOpc == 2
			Help(" ",1,"TMSA43018") //Nao existe Regiao do Motorista cadastrado para o Motorista selecionado
		Else
			If Len( aCols ) == 1 .And. Empty( GDFieldGet( 'DTB_CDRDES', 1 ) )
				GDFieldPut( 'DTB_ITEM', StrZero(1,Len(DTB->DTB_ITEM)), 1 )
			EndIf
		EndIf
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Init da EnchoiceBar                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
bInit := {|| ( EnchoiceBar(oDlgReg,{|| IIf((lOk := TA430RTudOK()),oDlgReg:End(),NIL)},{|| lOk := .F.,oDlgReg:End() },,))}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicoes do Dialogo                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oDlgReg := MSDialog():New( 10,10,300,500,STR0026,,,,,,,,,.T. ) //"Região por Motorista"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definicao do Painel                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPanel 	:= TPanel()	:New( 25,5, "", oDlgReg, Nil, .T., .F.,Nil, Nil, 235, 55, .T., .F. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos utilizados na Dialog                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 15,06 SAY STR0027          SIZE 70,9 of oPanel PIXEL //"Cod. Motorista"
@ 13,45 MSGET cMotorista     SIZE 30,9 OF oPanel WHEN .F. PIXEL

@ 28,06 SAY STR0028          SIZE 70,9 of oPanel PIXEL //"Motorista"
@ 26,45 MSGET cDescMotor     SIZE 130,9 OF oPanel WHEN .F. PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³MsGetDados                                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetD := MsGetDados():New(73,06,140,239,IIf(nOpc == 2,2,3),"TA430RLinOk",,"+DTB_ITEM",.T.,,,.F.,,,,,,oDlgReg)

oDlgReg:Activate( ,,,.T.,bValid,,bInit )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso utilize confirmacao, atualizo Array principal com as informacoes    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lOk .And. nOpc != 2

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Limpando registros deletados                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aCols )
		If !aTail(aCols[nX])
			AAdd(aLimpCols,aCols[nX])
		EndIf
	Next nX

	aCols := {}
	aCols := aClone( aLimpCols )

	nAux := aScan( aDadoRegMot, {|ExpA1| ExpA1[1] == cMotorista} )
	If nAux <= 0
		AAdd( aDadoRegMot, { cMotorista, aClone( aCols ), aClone( aHeader ) } )
	Else
		aDadoRegMot[nAux][2] := aClone( aCols )
	EndIf
Else
	aDadoRegMot := aClone( aBackDadR )
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restauracao das variaveis da tela anterior                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCols := {}
aHeader := {}

If ValType( aBackCols ) == "A"
	aCols := aClone( aBackCols )
EndIf
If ValType( aBackHead ) == "A"
	aHeader := aClone( aBackHead )
EndIf
If ValType( aBackTela ) == "A"
	aTela := aClone( aBackTela )
EndIf
If ValType( aBackGets ) == "A"
	aGets := aClone( aBackGets )
EndIf
If ValType( nBackN ) == "N"
	N := nBackN
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaurando area do sistema                                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea( aArea )

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TA430RLinO³ Autor ³ Fernando Salvatori    ³ Data ³18/02/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Validacoes da linha da GetDados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430LinOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TA430RLinOk()

Local lRet := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Nao avaliar caso a linha esteja deletada                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	!GDDeleted( n ) .And. (lRet:=MACheckCols(aHeader,acols,n))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existe itens duplicados na GetDados                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lRet := GDCheckKey( { 'DTB_CDRDES' }, 4 )
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TA430RTudO³ Autor ³ Fernando Salvatori    ³ Data ³18/03/2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tudo Ok da GetDados                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TA430TudOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TA430RTudOK()

Local lRet := .T.

lRet := oGetD:ChkObrigat( n )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica a linha atual                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	lRet := TA430RLinOk()
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430Vld  ³ Autor ³ Alex Egydio           ³ Data ³22.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacoes do sistema (Regiao do Motorista)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430Vld()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TA430Vld()

Local aAreaAnt	:= GetArea()
Local cCampo	:= ReadVar()
Local lRet		:= .T.

If cCampo == 'M->DTB_CDRDES'

	lRet := TmsTipReg( M->DTB_CDRDES, StrZero( 2, Len( DTN->DTN_TIPREG ) ) )

ElseIf cCampo == 'M->DTB_REGDES'

	cCampo := 'DTB_CDRDES'
	M->&(cCampo) := CriaVar(cCampo)

	lRet := TmsPesqRegiao(cCampo,'DTB_REGDES')
	If	!Empty( M->DTB_CDRDES )
		GDFieldPut( 'DTB_CDRDES', M->DTB_CDRDES, n )
	EndIf
	GDFieldPut( 'DTB_REGDES', M->DTB_REGDES, n )

EndIf

RestArea( aAreaAnt )

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³TA430DelOkºAutor  ³Fernando Salvatori  º Data ³  19/02/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida linha de delecao do aCols                           º±±
±±º          ³ Dados do Motorista (MsGetDados Principal                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA430                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TA430DelOk()

Local lRet := .T.         //Retorno da Funcao
Local nAux := 0           //Var Auxiliar

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Devido a um problema contido no BIN, a funcao DelOk eh     ³
//³executada 2 vezes, sendo assim, foi declarada uma variavel ³
//³Estatica para controlar se ja foi executada ou nao a funcao³
//³Variavel "lDelOk"                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lDelOk
	nAux := IIf( Type( "aDadoRegMot" ) == "A",aScan( aDadoRegMot,{|ExpA1| ExpA1[1] == aCols[N][aScan( aHeader,{|ExpA1| AllTrim(ExpA1[2]) == "DTO_CODMOT"})]} ),0)
	If ( lRet ) .And. ( nAux > 0 )
		//"Existe uma Região do Motorista cadastrada, deseja realmente efetuar a exclusao do registro? (os dados de Região do Motorista serão perdidos)"
		If MsgYesNo( STR0023 ,STR0020)
			aDel(aDadoRegMot,nAux)
			aSize(aDadoRegMot,Len(aDadoRegMot)-1)
		Else
			lRet := .F.
		EndIf
	EndIf
	lDelOk := .T.
Else
	lDelOk := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA430Est³ Autor ³Patricia A. Salomao    ³ Data ³02.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o Estorno dos movimentos de veiculos e motoristas   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA430Est()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA430Est()

Local cAlias     := IIf(lMotorista, "DTO", "DTU")
Local cAtivCHG   := GetMv("MV_ATIVCHG") // Atividade de Chegada.
Local cAtivRTA   := GetMv("MV_ATIVRTA") // Atividade de Retorno de Aeroporto
Local cAtivRTP   := GetMv("MV_ATIVRTP") // Atividade de Retorno de Porto
Local aValidH    := {}
Local aValidCols := {}
Local aAreaDUD   := {}
Local aViagens   := {}
Local cSeekDTU, cSeekDTO, cSeek, cSeekDUV, cFilOri, cViagem 
Local nB         := 0
Local aAreaDTU   := DTU->(GetArea())
Local aAreaDTO   := DTO->(GetArea())

If lMotorista
	If DTO->DTO_STATUS == StrZero(4, Len(DTO->DTO_STATUS)) //Baixado
		cFilOri := DTO->DTO_FILVGS
		cViagem := DTO->DTO_NUMVGS
	Else
		cFilOri := DTO->DTO_FILVGE
		cViagem := DTO->DTO_NUMVGE
	EndIf
Else
	If DTU->DTU_STATUS == StrZero(4, Len(DTU->DTU_STATUS)) //Baixado
		cFilOri := DTU->DTU_FILVGS
		cViagem := DTU->DTU_NUMVGS
	Else
		cFilOri := DTU->DTU_FILVGE
		cViagem := DTU->DTU_NUMVGE
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Status do Motorista (DTO) / Veiculo (DTU) :       ³
//³ 1 - Aberto                                       ³
//³ 2 - Liberado                                     ³
//³ 3 - Reservado                                    ³
//³ 4 - Baixado                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If &(cAlias+"->"+cAlias+"_STATUS") == StrZero(1, Len(DTO->DTO_STATUS)) // Em Aberto
	If Empty(cFilOri) .And. Empty(cViagem)
		Help("",1,"TMSA43028") //"O Estorno nao sera Efetuado"
		Return ( .F. )
	Else
		//-- Verifica se a Viagem esta encerrada
		If !TMSChkViag( cFilOri, cViagem, .F., .F., .F., .T., .F., .F., .F., .F., .F., {}, .F., .T., .F. )
			Return .F.
		EndIf

		// Verifica se alguma atividade Posterior ja foi apontada
		If !TA430StaOpe(cFilOri, cViagem, @aViagens, IIf(DTQ->DTQ_TIPTRA == '2', cAtivRTA, cAtivRTP) )
			Return .F.
		EndIf

		DUV->(dbSetOrder(1))
		DUV->(MsSeek(cSeekDUV := xFilial("DUV")+cFilOri+cViagem))
		// Efetua o Estorno 
		TA430EstRes(cFilOri, cViagem, IIf(DTQ->DTQ_TIPTRA == '2', cAtivRTA, cAtivRTP) , cSeekDUV, aViagens)
	EndIf

ElseIf &(cAlias+"->"+cAlias+"_STATUS") == StrZero(2, Len(DTO->DTO_STATUS)) // Liberado
	Begin Transaction

	// Atualiza DTU (Movimento de Veiculos)
	aValidH    := AClone(aSvFolder[1][1])
	aValidCols := AClone(aSvFolder[1][2])
	dbSelectArea("DTU")
	dbSetOrder(2)
	For nB:=1 to Len(aValidCols)
		If ValType(aValidCols[nB,Len(aValidCols[nB])]) == "L" .And. !aValidCols[nB,Len(aValidCols[nB])] .And. !Empty(aValidCols[nB,nPosVei])
			dbSelectArea("DTU")
			cSeekDTU := xFilial('DTU')+aValidCols[nB,nPosVei]
			If MsSeek( cSeekDTU+StrZero(2, Len(DTU->DTU_STATUS)),.T. )
				RecLock("DTU", .F.)
				DTU->DTU_STATUS := StrZero(1, Len(DTU->DTU_STATUS))	// Em Aberto
				DTU->DTU_NUMLIB := CriaVar("DTU_NUMLIB", .F.)
				DTU->DTU_HORLIB := CriaVar("DTU_HORLIB", .F.)
				DTU->(MsUnLock())
			EndIf
		EndIf
	Next nB

	// Atualiza DTO (Movimento de Motoristas)
	aValidH    := AClone(aSvFolder[2][1])
	aValidCols := AClone(aSvFolder[2][2])
	dbSelectArea("DTO")
	dbSetOrder(2)
	For nB:=1 to Len(aValidCols)
		If ValType(aValidCols[nB,Len(aValidCols[nB])]) == "L" .And. !aValidCols[nB,Len(aValidCols[nB])] .And. !Empty(aValidCols[nB,nPosMot])
			dbSelectArea("DTO")
			cSeekDTO := xFilial('DTO')+aValidCols[nB,nPosMot]
			If MsSeek( cSeekDTO+StrZero(2, Len(DTO->DTO_STATUS)),.T. )
				RecLock("DTO", .F.)
				DTO->DTO_STATUS := StrZero(1, Len(DTO->DTO_STATUS)) // Em Aberto
				DTO->DTO_NUMLIB := CriaVar("DTO_NUMLIB", .F.)
				DTO->DTO_HORLIB := CriaVar("DTO_HORLIB", .F.)
				DTO->(MsUnLock())
			EndIf
		EndIf
	Next nB
	End Transaction

ElseIf &(cAlias+"->"+cAlias+"_STATUS") == StrZero(3, Len(DTO->DTO_STATUS)) //Reservado

	DUV->(dbSetOrder(1))
	If DUV->(MsSeek(cSeekDUV := xFilial("DUV")+cFilOri+cViagem))


		// So efetuar o Estorno da Entrada de Veiculos, se nao tiver sido feito carregamento
		// na Filial Atual.
		DTA->(dbSetOrder(2))
		DTA->(MsSeek(xFilial("DTA")+cFilOri+cViagem))
		Do While !DTA->(Eof()) .And. DTA->(DTA_FILIAL+DTA_FILORI+DTA_VIAGEM) == xFilial("DTA")+cFilOri+cViagem
			If DTA->DTA_FILATU == cFilAnt
				Help("",1,"TMSA43032") //"O Estorno Nao sera Efetuado pois ja foi feito Carregamento nesta Filial"
				Return .F.
			EndIf
			DTA->(dbSkip())
		EndDo

		aAreaDUD := DUD->(GetArea())
		DUD->(DbSetOrder(2))
		DUD->(MsSeek(cSeek := xFilial('DUD') + cFilOri + cViagem))
		While DUD->(! Eof() .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM == cSeek)
			If	DUD->DUD_FILATU == cFilAnt
				Help("",1,"TMSA43033",,DUD->DUD_FILDOC+'/'+DUD->DUD_DOC+'/'+DUD->(&(SerieNfId("DUD",3,"DUD_SERIE"))),4,1) // O Estorno nao sera Efetuado, pois ja foi Gerada Viagem nesta Filial para o Documento :
				Return .F.
			EndIf
			DUD->(DbSkip())
		EndDo
		RestArea(aAreaDUD)

		// Verifica se alguma atividade Posterior ja foi apontada
		If !TA430StaOpe(cFilOri, cViagem, @aViagens, cAtivCHG)
			Return .F.
		EndIf

		// Efetua o Estorno 
		TA430EstRes(cFilOri, cViagem, cAtivCHG, cSeekDUV, aViagens)

	Else
		Help("",1,"TMSA43029") //"O Estorno nao sera realizado"
		Return .F.
	EndIf
EndIf

RestArea( aAreaDTU )
RestArea( aAreaDTO )

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmA430EstO³ Autor ³Patricia A. Salomao    ³ Data ³02.04.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Efetua o Estorno das Operacoes (DTW)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA430EstOpe()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Origem                                   ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±³          ³ ExpC3 - Atividade (MV_ATIVCHG ou MV_ATIVSAI)               ³±±
±±³          ³ ExpA1 - Array Contendo os no. das Viagens                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMA430EstOpe(cFilOri, cViagem, cAtividade, aViagens)

Local aAreaDTW     := {}
Local nCntFor      := 0
Local cAtivChg     := GetMV("MV_ATIVCHG",,"")
Local cAtivSai     := GetMV("MV_ATIVSAI",,"")
Local cSeek        := ""
Default cFilOri    := ""
Default cViagem    := ""
Default cAtividade := ""
Default aViagens   := {}

For nCntFor := 1 To Len(aViagens)
	// Posiciona a operacao de chegada/saida.
	DTW->(dbSetOrder(4))
	If DTW->(MsSeek(cSeek := xFilial("DTW") + aViagens[nCntFor, 1] + aViagens[nCntFor, 2] + cAtividade + cFilAnt))

		cSerTms := DTW->DTW_SERTMS
		cCatOpe := DTW->DTW_CATOPE
		aAreaDTW := DTW->(GetArea())
		TMSA350Grv(5, aViagens[nCntFor, 1], aViagens[nCntFor, 2], cAtividade)
		RestArea(aAreaDTW)

		//-- Se Atividade for de chegada ou saida, estorna tambem as Operacoes Anteriores Canceladas
		DTW->(DbSetOrder(1))
		If cAtividade == cAtivSai .Or. cAtividade == cAtivChg
			Do While DTW->(!Bof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM) ==  xFilial("DTW") + aViagens[nCntFor, 1] + aViagens[nCntFor, 2]
				If DTW->DTW_FILATI == cFilAnt .And. DTW->DTW_STATUS == StrZero(9, Len(DTW->DTW_STATUS)) // Se Operacao Cancelada
					TMSA350Grv(5, aViagens[nCntFor, 1], aViagens[nCntFor, 2], cAtividade)
				EndIf
				DTW->(dbSkip(-1))
			EndDo
		EndIf

		//-- Reativa a operacao de chegada em filial (Origem) quando for estorno de chegada eventual.
		If cAtividade == cAtivChg .And. ; //-- Chegada de Viagem
			cSerTms <> StrZero(2,Len(DTW->DTW_SERTMS)) .And. ; //-- Diferente de Transporte (Coleta/Entrega)
			cCatOpe == StrZero(2,Len(DTW->DTW_CATOPE)) //-- Eventual
			//-- Para Coleta/Entrega devera ser atualizada a filial destino da viagem.
			DTQ->(DbSetOrder(2))
			If DTQ->(MsSeek(xFilial("DTQ")+aViagens[nCntFor,1]+aViagens[nCntFor,2]))
				RecLock("DTQ",.F.)
				DTQ->DTQ_FILDES := aViagens[nCntFor,1]
				MsUnlock()
			EndIf
			DTW->(dbSetOrder(4))
			If DTW->(MsSeek(xFilial("DTW") + aViagens[nCntFor,1] + aViagens[nCntFor,2] + cAtividade + aViagens[nCntFor,1] ))
				RecLock('DTW',.F.)
				DTW->DTW_DATREA := CriaVar('DTW_DATREA', .F.)
				DTW->DTW_HORREA := CriaVar('DTW_HORREA', .F.)
				DTW->DTW_STATUS := StrZero(1,Len(DTW->DTW_STATUS))	//-- Aberto
				MsUnLock()
			EndIf
		EndIf

	EndIf
Next

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430EstRe³ Autor ³Patricia A. Salomao    ³ Data ³08.05.2003  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Efetua o Estorno do Movto. de Motoristas / Veiculos (DTO/DTU),³±±
±±³          ³com Status "Em Aberto"(Viagem Aerea) OU com Status "Reservado"³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMA430EstRes()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Origem                                     ³±±
±±³          ³ ExpC2 - Viagem                                               ³±±
±±³          ³ ExpC3 - Atividade (MV_ATIVCHG ou MV_ATIVRTA ou MV_ATIVRTP)   ³±±
±±³          ³ ExpC4 - Chave do Seek efetuado no DUV                        ³±±
±±³          ³ ExpA1 - Array contendo os nos. das Viagens                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA430EstRes(cFilOri, cViagem, cAtividade, cSeek, aViagens)

Default cFilOri    := ""
Default cViagem    := ""
Default cAtividade := ""
Default cSeek      := ""
Default aViagens   := {}

Begin Transaction

	// Atualiza DUV (Registro de Entrada / Saida de Veiculos)
	Do While !DUV->(Eof()) .And. DUV->(DUV_FILIAL+DUV->DUV_FILORI+DUV->DUV_VIAGEM) == cSeek
		If DUV->DUV_FILENT == cFilAnt
			RecLock("DUV", .F.)
			DUV->DUV_FILENT := CriaVar("DUV_FILENT", .F.)
			DUV->(MsUnLock())
		EndIf
		DUV->(dbSkip())
	EndDo

	// Deleta DTU (Movimento de Veiculos)
	DTU->(dbSetOrder(1))
	If DTU->(MsSeek(xFilial("DTU")+If(lMotorista,M->DTO_NUMENT,M->DTU_NUMENT)) )
		While DTU->(!Eof()) .And. DTU->DTU_FILIAL + DTU->DTU_NUMENT == xFilial("DTU")+If(lMotorista,M->DTO_NUMENT,M->DTU_NUMENT)
			RecLock("DTU", .F.)
			DTU->(dbDelete())
			DTU->(MsUnLock())
			DTU->(DbSkip())
		EndDo
	EndIf

	// Deleta DTO (Movimento de Motoristas)
	DTO->(dbSetOrder(1))
	If DTO->(MsSeek(xFilial("DTO")+If(lMotorista,M->DTO_NUMENT,M->DTU_NUMENT)) )
		While DTO->(!Eof()) .And. DTO->DTO_FILIAL + DTO->DTO_NUMENT == xFilial("DTO")+If(lMotorista,M->DTO_NUMENT,M->DTU_NUMENT)
			RecLock("DTO", .F.)
			DTO->(dbDelete())
			DTO->(MsUnLock())
			DTO->(DbSkip())
		EndDo
	EndIf

	// Estorna as Operacoes (DTW)
	TMA430EstOpe(cFilOri, cViagem, cAtividade, aViagens)

End Transaction

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430StaOp³ Autor ³Patricia A. Salomao    ³ Data ³12.05.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe Operacoes Posteriores ja Apontadas      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430StaOpe()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Filial de Origem                                   ³±±
±±³          ³ ExpC2 - Viagem                                             ³±±
±±³          ³ ExpA1 - Array contendo os nos. das Viagens                 ³±±
±±³          ³ ExpC3 - Codigo da Atividade                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA430StaOpe(cFilOri, cViagem, aViagens, cAtividade) 

Local nB       := 0
Local aAreaDTW := DTW->(GetArea())
Local aAreaDTR := DTR->(GetArea())

Default cViagem    := ''
Default cFilOri    := ''
Default aViagens   := {}
Default cAtividade := {}

// Adiciona ao array a viagem original.
Aadd(aViagens, {cFilOri, cViagem})

// Verifica se existem viagens interligadas.
DTR->(dbSetOrder(2))
DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem))

While DTR->(!Eof()) .And. DTR->DTR_FILIAL == xFilial("DTR") .And. DTR->DTR_FILVGE == cFilOri .And.;
	DTR->DTR_NUMVGE == cViagem

	// Adiciona ao array as viagens interligadas.
	If (DTR->DTR_FILORI + DTR->DTR_VIAGEM) != (DTR->DTR_FILVGE + DTR->DTR_NUMVGE)

		If Ascan(aViagens, {|x| x[1] + x[2] == DTR->DTR_FILORI + DTR->DTR_VIAGEM}) == 0
			Aadd(aViagens , {DTR->DTR_FILORI, DTR->DTR_VIAGEM})
		EndIf
	EndIf

	DTR->(dbSkip())
EndDo

For nB := 1 to Len(aViagens)
	DTW->(dbSetOrder(4))
	// Posiciona a operacao de chegada/saida.
	If DTW->(MsSeek(xFilial("DTW") + aViagens[nB, 1] + aViagens[nB, 2] + cAtividade + cFilAnt))
		DTW->(dbSetOrder(1))
		DTW->(dbSkip())
		Do While !DTW->(Eof()) .And. DTW->(DTW_FILIAL+DTW_FILORI+DTW_VIAGEM) == xFilial("DTW")+aViagens[nB,1]+aViagens[nB,2]
			//-- Nao considera as operacoes 'Eventuais' Encerradas
			If DTW->DTW_STATUS == StrZero(2, Len(DTW->DTW_STATUS)) .And. DTW->DTW_CATOPE <> StrZero(2,Len(DTW->DTW_CATOPE))
				Help('',1,'TMSA43035') // O Estorno Nao sera Efetuado, pois existem Operacoes Posteriores que ja foram Apontadas ...
				Return .F.
			EndIf
			DTW->(dbSkip())
		EndDo
	EndIf
Next

RestArea(aAreaDTW)
RestArea(aAreaDTR)

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430MovOk³ Autor ³ Robson Alves          ³ Data ³01.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se existe status para o movimento saida/liberacao.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430MovOk(ExpN1, ExpL1)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao do aRotina.                                  ³±±
±±³          ³ ExpC1 - Alias posicionado.                                 ³±±
±±³          ³ ExpL1 - Verificacao Final( Sim ou Nao ).                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA430MovOk( nOpc, cAlias, lFinal )

Local lRet   := .F.
Local cSeek  := ""
Local nA     := 0

Default lFinal := .F.

If nOpc == 4 // Liberacao
	/* Para efetuar a liberacao, verifica se existe veiculo/motorista em aberto. */
	cSeek := Iif( lMotorista,	xFilial("DTO") + StrZero( 1, Len( DTO->DTO_STATUS ) ),;
								xFilial("DTU") + StrZero( 1, Len( DTU->DTU_STATUS ) ) )
	dbSetOrder(3)
	lRet := MsSeek(cSeek)
	If !lRet .And. !lFinal
		Help(" ",1,"TMSA43036") //Nao foi encontrado nenhum movimento para liberacao"
	EndIf
Else // Saida.
	/* Para efetuar a saida, verifica se existe veiculo/motorista em aberto, liberado ou reservado. */
	cSeek := Iif( lMotorista,	xFilial("DTO"), xFilial("DTU") )
	dbSetOrder( 3 )
	For nA := 1 To 3
		If MsSeek( cSeek + StrZero( nA, Len( &( cAlias + "->" + cAlias + "_STATUS" ) ) ) )
			lRet := .T.
			Exit
		EndIf
	Next nA

	If !lRet .And. !lFinal
		Help(" ",1,"TMSA43037") //Nao foi encontrado nenhum movimento para saida"
		Return Nil
	EndIf
EndIf
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Quando a verificacao for no final da rotina de manutencao("TmsA430Mnt"), ³
³e nao for encontrado nenhum status valido para o movimento em questao, nao³
³chama novamente a tela de liberacao/Saida.                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
If !lRet .And. lFinal
	MBRCHGLoop()
EndIf

Return( Iif( lFinal, Nil, lRet ) )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430SgOdo³ Autor ³ Robson Alves          ³ Data ³01.08.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Sugere o odometro de entrada/saida.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430SgOdo()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numerico( Odometro de entrada/saida ).                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TA430SgOdo()

Local nRetOdo  := 0
Local nA       := 0
Local cCodVei  := ""

If lMotorista
	cCodVei  := Iif( Type("M->DTU_CODVEI") <> "U", M->DTU_CODVEI, GDFieldGet( "DTU_CODVEI", n ) )
Else
	cCodVei  := Iif( !Empty( M->DTU_CODVEI ), M->DTU_CODVEI, GDFieldGet( "DTU_CODVEI", n ) )
EndIf

DTU->( dbSetOrder( 2 ) )
For nA := 1 To 3 // Status : em aberto, liberado e reservado.
	If DTU->( MsSeek( xFilial("DTU") + cCodVei + StrZero( nA, Len( DTU->DTU_STATUS ) ) ) )
		nRetOdo := DTU->DTU_ODOENT
		Exit
	EndIf
Next nA

Return( nRetOdo )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³A430ZerViag³ Autor ³ Eduardo de Souza     ³ Data ³ 17/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Limpa o campo Filial da Viagem / Viagem                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A430ZerViag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A430ZerViag()

Local cCampo    := UPPER(Alltrim(ReadVar()))
Local cFilOri   := If(cCampo$"DTO_FILORI/DTU_FILORI",&(ReadVar()),If(lMotorista,M->DTO_FILORI,M->DTU_FILORI))
Local cViagem   := If(cCampo$"DTO_VIAGEM/DTU_VIAGEM",&(ReadVar()),If(lMotorista,M->DTO_VIAGEM,M->DTU_VIAGEM))

If !Empty(cFilOri) .Or. !Empty(cViagem)
	If lMotorista
		M->DTO_FILORI := CriaVar("DTO_FILORI",.F.)
		M->DTO_VIAGEM := CriaVar("DTO_VIAGEM",.F.)
	Else
		M->DTU_FILORI := CriaVar("DTO_FILORI",.F.)
		M->DTU_VIAGEM := CriaVar("DTO_VIAGEM",.F.)
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TmsA430DTU³ Autor ³ Alex Egydio           ³ Data ³09.03.2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta movimento de veiculos ou veiculos conforme        ³±±
±±³          ³ parametro MV_CONTVEI. Acionado na consulta SXB( DTU )      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Function TmsA430DTU()

Local aAreaDTQ 	:= DTQ->( GetArea() )
Local bRetorno 	:= { || Iif(GetMV('MV_CONTVEI',,.T.),TMSConsDTU(),Conpad1(,,,'DA3',,,.F.)) }
Local lVgeMod3  := Iif(FindFunction("TmsVgeMod3"),TmsVgeMod3(),.F.)

If !IsInCallStack('TMSA146')
	If Alltrim( FunName() ) == "TMSA240" //-- Complemento de Viagem.
	//-- Quando a Viagem for planejada, habilita a consulta pelo Cadastro de Veiculos.
		DTQ->( dbSetOrder( 2 ) )
		If DTQ->( MsSeek( xFilial("DTQ") + M->DTR_FILORI + M->DTR_VIAGEM ) ) .And. DTQ->DTQ_TIPVIA == StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) //-- Viagem Planejada.
			bRetorno := { || Conpad1(,,,'DA3',,,.F.) }
		EndIf
		RestArea( aAreaDTQ )
	
	ElseIf Left( FunName(), 7 ) $ "TMSA140|TMSA141|TMSA143|TMSA144|" .Or. lVgeMod3
		If M->DTQ_TIPVIA == StrZero( 3, Len( DTQ->DTQ_TIPVIA ) ) //-- Viagem Planejada.
			bRetorno := { || Conpad1(,,,'DA3',,,.F.) }
		EndIf
	EndIf
EndIf	

Return( Eval( bRetorno ) )


/*----------------------------------------------------------------------------------------------------
{Protheus.doc} TMS430Vei  
Expressão de consulta para retornar apenas os veículos do tipo cavalo para o campo DF8_CODCAV.

@protected
@author Israel A Possoli
@since 18/08/2017
@version 1.0
------------------------------------------------------------------------------------------------------*/
Function TMS430Vei()
	Local lRet      := .T.
	Local cAliasQry := ''
	Local cQuery    := ''
	Local aTitle    := {}
	Local aItens    := {}
	Local nSelec    := 0
	
	
	AAdd( aTitle, RetTitle( 'DA3_COD' ) )
	AAdd( aTitle, RetTitle( 'DA3_DESC' ) )
	AAdd( aTitle, RetTitle( 'DA3_PLACA' ) )
	AAdd( aTitle, RetTitle( 'DUT_DESCRI' ) )
	
	cQuery := "SELECT DA3.DA3_COD, DA3.DA3_PLACA, DA3.DA3_DESC, DUT.DUT_DESCRI "
	cQuery += "FROM " + RetSQLTab('DA3') + ', ' + RetSQLTab('DUT') 
	cQuery += "WHERE DA3.DA3_FILIAL = '" + xFilial('DA3') + "' AND "
	cQuery += "      DA3.D_E_L_E_T_ = '' AND "
	cQuery += "      DUT.DUT_FILIAL = '" + xFilial('DUT') + "' AND "
	cQuery += "      DUT.DUT_CATVEI = '" + StrZero(2, TamSX3("DUT_CATVEI")[1]) + "' AND "
	cQuery += "      DUT.DUT_TIPVEI = DA3.DA3_TIPVEI AND "
	cQuery += "      DUT.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery(cQuery)
	
	cAliasQry := GetNextAlias()
	DbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry )
	
	If !(cAliasQry)->( Eof() )
		While !(cAliasQry)->( Eof() )
			AAdd( aItens, { 	(cAliasQry)->DA3_COD,;
									(cAliasQry)->DA3_DESC,;
									(cAliasQry)->DA3_PLACA,;
									(cAliasQry)->DUT_DESCRI } )
			
			(cAliasQry)->( DbSkip() )
		End
		(cAliasQry)->( DbCloseArea() )
	Else
		lRet := .F.
	Endif
	
	If lRet
		nSelec := TmsF3Array( aTitle, aItens, 'Veículos tipo Cavalo', .F. )
	
		If nSelec <> 0
			VAR_IXB := aItens[nSelec,1]
			lRet    := .T.
		Else
			lRet    := .F.
		EndIf	
	EndIf
Return( lRet )



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ TMA490LibV³ Autor ³ Eduardo de Souza     ³ Data ³ 05/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se deverá liberar cavalo e motorista na entrada do³±±
±±³          ³ veiculo na chegada final da viagem                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A430ZerViag()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMA490LibV(cFilOri,cViagem)

Local lContVei  := SuperGetMV('MV_CONTVEI',,.T.) // Parametro para verificar se o sistema devera' controlar veiculo/motorista

//-- Verifica se deverá liberar cavalo e motorista na entrada do veiculo na chegada final da viagem de transporte
If lContVei
	DTQ->(DbSetOrder(2))
	If DTQ->(MsSeek(xFilial("DTQ")+cFilOri+cViagem)) .And. DTQ->DTQ_SERTMS == StrZero(2,Len(DTQ->DTQ_SERTMS)) //-- Transporte
		If DTQ->DTQ_FILDES == cFilAnt .And. A340AtuStat(DTQ->DTQ_FILORI, DTQ->DTQ_VIAGEM, 3)
			TMSA340Sta(DTQ->DTQ_FILORI,DTQ->DTQ_VIAGEM,'3','2',.T.)
		EndIf
	EndIf
EndIf

Return .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Marco Bianchi         ³ Data ³01/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³    1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function MenuDef()

Private aRotina	:= {	{ STR0003,"PesqBrw",   0,1,0,.F.},; //"Pesquisar"
						{ STR0004,"TmsA430Mnt",0,2,0,NIL},; //"Visualizar"
						{ STR0005,"TmsA430Mnt",0,3,0,NIL},; //"Entrada"
						{ STR0006,"TmsA430Mnt",0,3,0,NIL},; //"liBeracao"
						{ STR0007,"TmsA430Mnt",0,3,0,NIL},; //"Saida"
						{ STR0029,"TmsA430Mnt",0,5,0,NIL},; //"Estorno Ent"
						{ STR0008,"TmsA430Leg",0,7,0,.F.},; //"Legenda"
						{ STR0033,"TmsA430Mnt",0,8,0,NIL} } //"Excluir Ent." } 


If ExistBlock("TM430MNU")
	ExecBlock("TM430MNU",.F.,.F.)
EndIf

Return(aRotina)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TA430MotOk³ Autor ³ Richard Anderson      ³ Data ³11.12.2020³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Excluir DTU e aopntamento de operações                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430MotOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Código do Motorista                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA430MotOk(cCodMot)
Local lRet      := .T.
Local cQuery    := ''
Local aAreaAtu  := GetArea()
Local aAreaSM0  := SM0->(GetArea())
Local cAliasQry := GetNextAlias()
Default cCodMot := ''

cQuery := " SELECT DTO_FILIAL "
cQuery += "   FROM " + RetSqlName("DTO")
cQuery += "   WHERE DTO_CODMOT  = '" + cCodMot + "' "
cQuery += "     AND DTO_STATUS <> '" + StrZero(4,Len(DTO->DTO_STATUS)) + "'"
cQuery += "     AND D_E_L_E_T_  = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
If (cAliasQry)->(!Eof())
	Help("", 1,"TMSA43051",,(cAliasQry)->DTO_FILIAL+"-"+Posicione('SM0',1,cEmpAnt+(cAliasQry)->DTO_FILIAL,'M0_FILIAL'),3,1) //-- Já foi registrada a entrada deste motorista na filial
	lRet := .F.
EndIf
(cAliasQry)->(dbCloseArea())
RestArea(aAreaAtu)
RestArea(aAreaSM0)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    TA430Excl Autor ³     Felipe Barbiere      ³ Data ³05.01.2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TA430Excl()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 - Alias da tabela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMSA430                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TA430Excl(cAlias)

Local aViagens	:= {}
Local cFilOri	:= ""
Local cViagem	:= ""
Local cAtivChg	:= GetMV("MV_ATIVCHG",,"")
Local cSeekDUV	:= ""

If lMotorista
	If DTO->DTO_STATUS == StrZero(4, Len(DTO->DTO_STATUS)) //Baixado
		cFilOri := DTO->DTO_FILVGS
		cViagem := DTO->DTO_NUMVGS
	Else
		cFilOri := DTO->DTO_FILVGE
		cViagem := DTO->DTO_NUMVGE
	EndIf
Else
	If DTU->DTU_STATUS == StrZero(4, Len(DTU->DTU_STATUS)) //Baixado
		cFilOri := DTU->DTU_FILVGS
		cViagem := DTU->DTU_NUMVGS
	Else
		cFilOri := DTU->DTU_FILVGE
		cViagem := DTU->DTU_NUMVGE
	EndIf
EndIf

cSeekDUV	:= xFilial("DUV")+cFilOri+cViagem
//-- Verifica se a Viagem esta encerrada
If !TMSChkViag( cFilOri, cViagem, .F., .F., .F., .T., .F., .F., .F., .F., .F., {}, .F., .T., .F. )
	Return .F.
EndIf

If &(cAlias+"->"+cAlias+"_STATUS") == StrZero(3, Len(DTO->DTO_STATUS)) //Reservado
// Verifica se alguma atividade Posterior ja foi apontada
	If !TA430StaOpe(cFilOri, cViagem, @aViagens, cAtivCHG)
		Return .F.
	EndIf

	// Efetua o Estorno 
	TA430EstRes(cFilOri, cViagem, cAtivCHG, cSeekDUV, aViagens)
EndIf

