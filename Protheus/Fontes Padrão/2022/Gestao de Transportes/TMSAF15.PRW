#Include "PROTHEUS.CH"
#Include "TMSAF15.CH"

Static _cCodVei   := ''
Static _lCompViag := .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSAF15  ³ Autor ³ Vitor Raspa           ³ Data ³ 11.Dez.06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retirada de Reboques                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF15()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ TMS - Gestao de Transportes                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15() 
Local aCores       := {}
Private cCadastro  := STR0001 //-- Retorno de Reboques
Private aRotina    := MenuDef()

Aadd(aCores,{"DF7_STATUS=='1'",'BR_VERDE'}) 	// 'Em Aberto'
Aadd(aCores,{"DF7_STATUS=='2'",'BR_VERMELHO'})	// 'Encerrado'

MBrowse(,,,,'DF7',,,,,,aCores)

RetIndex('DF7')

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSAF15Mnt ³ Autor ³ Vitor Raspa        ³ Data ³  11.Dez.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Manutencao dos Retornos de Reboques                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF15Mnt( ExpC1,ExpN1,ExpN2 )                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 - Alias                                               ³±±
±±³          ³ExpC2 - Registro                                            ³±±
±±³          ³ExpC3 - Opcao Selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nil                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSAF15                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15Mnt(cAlias,nReg,nOpc,aStruct,lCompViag, aHeaderDTR, aColsDTR)
Local oEnchoice    := Nil
Local lOk          := .F.
Local oDlg         := Nil
Local aSize        := {}
Local aObjects     := {}
Local aInfo        := {}
Local aPosObj      := {}
Local aButtons     := NIL
Local lContVei     := GetMV('MV_CONTVEI',,.T.)
Local cCodUser	   := ""
Local aAltCpos     := NIL
Local aVeiculos    := {}
Local nAux         := 0
Local aAreaDTQ     := DTQ->(GetArea())

Local nPosCodVei   := aScan( aHeaderDTR, {|x| x[2] == 'DTR_CODVEI'} )
Local nPosValFre   := aScan( aHeaderDTR, {|x| x[2] == 'DTR_VALFRE'} )
Local nPosTabFre   := aScan( aHeaderDTR, {|x| x[2] == 'DTR_TABFRE'} )
Local nPosTabCar   := aScan( aHeaderDTR, {|x| x[2] == 'DTR_TABCAR'} )
Local nPosTipTab   := aScan( aHeaderDTR, {|x| x[2] == 'DTR_TIPTAB'} )

Private aSetKey    := {}
Private aHeader    := {}
Private aCols      := {}
Private aHeaderMot := {}
Private aColsMot   := {}
Private aHeaderAju := {}
Private aColsAju   := {}

Private aTela[0][0]
Private aGets[0]

Default cAlias     := 'DF7'
Default nReg	   := 1
Default nOpc	   := 2

//-- Verifica se o retorno do reboque esta sendo chamado 
//-- pela rotina de Complemento de viagem
_lCompViag := lCompViag

If !_lCompViag
	aButtons := {}
	AAdd(aButtons,	{'USER'		,{|| If(Obrigatorio(aGets,aTela), TMSAF15Mot(nOpc),NIL)}	, STR0011 , STR0012 })	//-- "Motoristas da Viagem - <F4>" ### "Motor."
	Aadd(aSetKey,	{ VK_F4 	,{|| If(Obrigatorio(aGets,aTela), TMSAF15Mot(nOpc),NIL)}})
	AAdd(aButtons,	{'BMPUSER'	,{|| If(Obrigatorio(aGets,aTela), TMSA240Aju(nOpc),NIL)}	, STR0013 , STR0014 })	//-- "Ajudantes da Viagem - <F5>" ### "Ajud."
	Aadd(aSetKey,	{ VK_F5 	,{|| If(Obrigatorio(aGets,aTela), TMSA240Aju(nOpc),NIL)}})
	If lContVei .And. TmsAcesso(,'TMSA430',@cCodUser,,.F.)
		AAdd(aButtons, {'CARGASEQ',{|| TMSA430('DTU') }, STR0026 , STR0027}) //'Movto. Veiculos - <F11>' ### 'Mov.Veic.'
		Aadd(aSetKey , { VK_F11   ,{|| TMSA430('DTU') } } )
		AAdd(aButtons, {'BMPGROUP',{|| TMSA430('DTO') }, STR0024 , STR0025 }) //'Movto. Motoristas - <F10>' ### 'Mov.Mot.
		Aadd(aSetKey , { VK_F10   ,{|| TMSA430('DTO') } } )	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se o registro nao esta em uso por outra estacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !_lCompViag .And. (nOpc == 4 .Or. nOpc == 5)
	If DF7->DF7_STATUS == StrZero(2,Len(DF7->DF7_STATUS))
		Help('',1,'TMSAF1503') //-- 'A retirada do reboque ja foi finalizada. Alteracao/Exclusao nao permitidas'
		Return Nil
	Else
		If !SoftLock("DF7")
			Return Nil
		EndIf	
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Dimensoes Padroes³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSize := MsAdvSize()
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo 	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
aPosObj	:= MsObjSize( aInfo, aObjects,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicializa as Varivaveis³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory( cAlias, nOpc==3 )
If !_lCompViag
	TMSAF15IniVar(nOpc)
EndIf

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

If _lCompViag
	aAltCpos := {'DF7_CODRB1', 'DF7_VALFRE'}
	If Len(aRetRbq) == 0
		M->DF7_CODVEI := aColsDTR[1,nPosCodVei]
		M->DF7_MODVEI := Posicione('DA3',1,xFilial('DA3')+M->DF7_CODVEI,'DA3_DESC')
		M->DF7_VALFRE := aColsDTR[1,nPosValFre]
		M->DF7_TABCAR := aColsDTR[1,nPosTabCar]
		M->DF7_TABFRE := aColsDTR[1,nPosTabFre]
		M->DF7_TIPTAB := aColsDTR[1,nPosTipTab]
	Else	
		M->DF7_CODRB1 := aRetRbq[ aScan(aRetRbq, {|x| x[1] == 'DF7_CODRB1'}), 2]
		M->DF7_MODRB1 := Posicione('DA3',1,xFilial('DA3')+M->DF7_CODRB1,'DA3_DESC')
		If nOpc == 3
			TMSAF15ConsRb( .T. )
		EndIf
		M->DF7_CODVEI := aRetRbq[ aScan(aRetRbq, {|x| x[1] == 'DF7_CODVEI'}), 2]
		M->DF7_MODVEI := Posicione('DA3',1,xFilial('DA3')+M->DF7_CODVEI,'DA3_DESC')
		M->DF7_VALFRE := aRetRbq[ aScan(aRetRbq, {|x| x[1] == 'DF7_VALFRE'}), 2]
		M->DF7_TABCAR := aColsDTR[1,nPosTabCar]
		M->DF7_TABFRE := aColsDTR[1,nPosTabFre]
		M->DF7_TIPTAB := aColsDTR[1,nPosTipTab]
	EndIf
EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

oEnchoice := MsMGet():New(cAlias, nReg, nOpc,,,,, aPosObj[1], aAltCpos,,,,,,,.T.)

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg,	{|| If(Obrigatorio(aGets,aTela) .And. TMSAF15TOk(nOpc), ( lOk := .T.,oDlg:End()), lOk := .F. )} ,;
													{|| lOk := .F., oDlg:End()},,aButtons) CENTERED

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualizacao dos Dados³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc != 2 .And. lOk  	
    If !_lCompViag
		TMSAF15Grv(nOpc)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se o Retorno de Reboque estiver sendo lancado a partir da tela    ³
		//³de Complemento de Viagem, atualiza o array aRetRbq para posterior ³
		//³gravacao no programa de Viagem ou no programa de Compl. de Viagem ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aRetRbq := {}
		For nAux := 1 To DF7->(FCount())
			AAdd( aRetRbq, { DF7->(FieldName(nAux)), M->&(DF7->(FieldName(nAux))) } )
		Next
	EndIf
EndIf

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

RestArea(aAreaDTQ)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15TOk ³ Autor ³ Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tudo Ok na validacao da tela principal                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF15TOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAF15TOk( nOpc )
Local lRet    := .T.
Local nCntFor := 0
Local nDel    := 0

If !_lCompViag
	If nOpc == 3 .Or. nOpc == 4
		If Len(aColsMot) > 0
			For nCntFor := 1 To Len(aColsMot)
				If aColsMot[nCntFor, Len(aHeaderMot)+1]
					nDel++
				EndIf
			Next
			If nDel == Len(aColsMot)
				Help('',1,'TMSAF1504') //-- 'Motorista para retirada do reboque nao informado!'
				lRet := .F.
			EndIf
		Else
			Help('',1,'TMSAF1504') //-- 'Motorista para retirada do reboque nao informado!'
			lRet := .F.
		EndIf
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15Grv ³ Autor ³ Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao dos Dados                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF15Grv()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15Grv(nOpc, aDadRetRbq)
Local lContVei     := GetMV('MV_CONTVEI',,.T.)
Local nAux         := 0
Local cFilOri      := ''
Local cViagem      := ''
Local cIteDTR      := ''
Local cCodVei      := ''
Local cCodRB1      := ''
Local cCodRB2      := ''
Local cCodRB3	   := ''
Local nValFre      := 0
Local cTabCar      := ''
Local cTabFre      := ''
Local cTipTab      := ''
Local lCompViag    := .F.
Local aMotoristas  := {}
Local aAjudantes   := {}
Local lTercRbq     := DF7->(ColumnPos("DF7_CODRB3")) > 0

Default aDadRetRbq := {}

If Len(aDadRetRbq) > 0
	lCompViag := .T.

	cFilOri   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_FILORI'}), 2]
	cViagem   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_VIAGEM'}), 2]
	cCodVei   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_CODVEI'}), 2]
	cCodRB1   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_CODRB1'}), 2]
	cCodRB2   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_CODRB2'}), 2]
	nValFre   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_VALFRE'}), 2]
	cTabCar   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_TABCAR'}), 2]
	cTabFre   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_TABFRE'}), 2]
	cTipTab   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_TIPTAB'}), 2]
	cIteDTR   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_ITEDTR'}), 2]
	cFilDTR   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_FILDTR'}), 2]
	cVgeDTR   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_VGEDTR'}), 2]
	If lTercRbq
		cCodRB3   := aDadRetRbq[aScan(aDadRetRbq, {|x| x[1] == 'DF7_CODRB3'}), 2]
	EndIf
Else
	cFilOri := M->DF7_FILORI
	cViagem := M->DF7_VIAGEM
	cCodVei := M->DF7_CODVEI
	cCodRB1 := M->DF7_CODRB1
	cCodRB2 := M->DF7_CODRB2
	nValFre := M->DF7_VALFRE
	cIteDTR := M->DF7_ITEDTR
	If lTercRbq
		cCodRB3 := M->DF7_CODRB3
	EndIf
EndIf		

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³INICIO DA ATUALIZACAO DOS DADOS³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction
	If nOpc == 5
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Exclui o Veiculo do Complemento de Viagem ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DTR->(DbSetOrder(1))
		If DTR->(MsSeek(xFilial('DTR') + cFilOri + cViagem + cIteDTR,.F.))		

			If lContVei .And. !lCompViag
				//-- Altera Status de Veiculo para Liberado
				aAltStaDTU("3", DTR->DTR_CODVEI)

				//-- Altera Status do 1o. Reboque para Liberado
				If !Empty(DTR->DTR_CODRB1)
					aAltStaDTU("3", DTR->DTR_CODRB1)
				EndIf
			
				//-- Altera Status do 2o. Reboque para Liberado
				If !Empty(DTR->DTR_CODRB2)
					aAltStaDTU("3", DTR->DTR_CODRB2)
				EndIf
				If lTercRbq
					//-- Altera Status do 3o. Reboque para Liberado
					If !Empty(DTR->DTR_CODRB3)
						aAltStaDTU("3", DTR->DTR_CODRB3)
					EndIf
				EndIf
			EndIf

			RecLock('DTR',.F.,.T.)
			DTR->(dbDelete())
			MsUnLock()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os Motoristas para Retirada do Reboque ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUP->(DbSetOrder(1))
			If DUP->(MsSeek(xFilial('DUP') + cFilOri + cViagem + cIteDTR, .F.))
				While DUP->(!Eof() .And. DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR == xFilial('DUP') + cFilOri + cViagem + cIteDTR)
					//-- Altera Status do Motorista	p/ Liberado
					If lContVei .And. !lCompViag
						aAltStaDTO("3")
					EndIf	
					RecLock('DUP',.F.,.T.)
					DUP->(dbDelete())
					MsUnLock()
					DUP->(DbSkip())
				EndDo
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui os Ajudantes para Retirada do Reboque ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			DUQ->(DbSetOrder(1))
			If DUQ->(MsSeek(xFilial('DUQ') + cFilOri + cViagem + cIteDTR, .F.))
				While DUQ->(!Eof() .And. DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM+DUQ_ITEDTR == xFilial('DUQ') + cFilOri + cViagem + cIteDTR)
					RecLock('DUQ',.F.,.T.)
					DUQ->(dbDelete())
					MsUnLock()
					DUQ->(DbSkip())
				EndDo
			EndIf
   	    EndIf

		RecLock('DF7',.F.)
		DF7->(DbDelete())
		MsUnLock()
	Else
		If nOpc == 3
			//-- Obtem o Item que sera gerado no DTR
			DTR->(dbSetOrder(1))
			DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem + 'z',.T.))
			DTR->(dbSkip(-1))
			If DTR->(!Eof()) .And. DTR->(DTR_FILIAL+DTR_FILORI+DTR_VIAGEM) == xFilial("DTR") + cFilOri + cViagem
				cIteDTR := Soma1(DTR->DTR_ITEM)
			EndIf
		Else
			DTR->(dbSetOrder(1))
			DTR->(MsSeek(xFilial("DTR") + cFilOri + cViagem + cIteDTR,.T.))
		EndIf

		RecLock('DTR', (nOpc == 3))
		DTR->DTR_FILIAL := xFilial('DTR')
		DTR->DTR_FILORI := cFilOri
		DTR->DTR_VIAGEM := cViagem
		DTR->DTR_ITEM   := cIteDTR
		DTR->DTR_CODVEI := cCodVei
		DTR->DTR_CODRB1 := cCodRB1
		DTR->DTR_CODRB2 := cCodRB2
		If lTercRbq
			DTR->DTR_CODRB3 := cCodRB3
		EndIf
		If lTercRbq
			DTR->DTR_QTDEIX := Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_QTDEIX') + ;
								  Posicione('DA3',1,xFilial('DA3')+cCodRB1,'DA3_QTDEIX') + ;
								  Posicione('DA3',1,xFilial('DA3')+cCodRB2,'DA3_QTDEIX')+ ;
								  Posicione('DA3',1,xFilial('DA3')+cCodRB3,'DA3_QTDEIX')
		Else 
			DTR->DTR_QTDEIX := Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_QTDEIX') + ;
								Posicione('DA3',1,xFilial('DA3')+cCodRB1,'DA3_QTDEIX') + ;
									Posicione('DA3',1,xFilial('DA3')+cCodRB2,'DA3_QTDEIX')
		EndIf  

		If DTR->(FieldPos('DTR_QTEIXV')) > 0 .And. lTercRbq
			DTR->DTR_QTEIXV := Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_QTDEIX') + ;
								Posicione('DA3',1,xFilial('DA3')+cCodRB1,'DA3_QTDEIX') + ;
								Posicione('DA3',1,xFilial('DA3')+cCodRB2,'DA3_QTDEIX')+ ;
								Posicione('DA3',1,xFilial('DA3')+cCodRB3,'DA3_QTDEIX')
		Else 
			DTR->DTR_QTEIXV := Posicione('DA3',1,xFilial('DA3')+cCodVei,'DA3_QTDEIX') + ;
								Posicione('DA3',1,xFilial('DA3')+cCodRB1,'DA3_QTDEIX') + ;
								Posicione('DA3',1,xFilial('DA3')+cCodRB2,'DA3_QTDEIX')
		EndIf

		If DTR->(FieldPos("DTR_CALRB1")) > 0
			DTR->DTR_CALRB1 := '2' //-- O Valor do Frete NAO foi Calculado
		Endif
		If DTR->(FieldPos("DTR_CALRB2")) > 0
			DTR->DTR_CALRB2 := '2' //-- O Valor do Frete NAO foi Calculado
		Endif
		If lTercRbq
			DTR->DTR_CALRB3 := '2' //-- O Valor do Frete NAO foi Calculado
		EndIf
			
		If nValFre <> 0
			DTR->DTR_VALFRE := nValFre
			DTR->DTR_TABCAR := cTabCar
			DTR->DTR_TABFRE := cTabFre
			DTR->DTR_TIPTAB := cTipTab
		Else
			DTR->DTR_VALFRE := CriaVar('DTR_VALFRE')
			DTR->DTR_TABCAR := CriaVar('DTR_TABCAR')
			DTR->DTR_TABFRE := CriaVar('DTR_TABFRE')
			DTR->DTR_TIPTAB := CriaVar('DTR_TIPTAB')
		EndIf

		If lContVei .And. !lCompViag
			//-- Altera Status do Veiculo para Reservado
			aAltStaDTU("2", cCodVei, cFilOri, cViagem)

			//-- Altera Status do 1o. Reboque para Reservado
			If !Empty(cCodRB1)
				aAltStaDTU("2", cCodRB1, cFilOri, cViagem)
			EndIf

			//-- Altera Status do 2o. Reboque para Reservado
			If !Empty(cCodRB2)
				aAltStaDTU("2", cCodRB2, cFilOri, cViagem)
			EndIf
			If lTercRbq
				//-- Altera Status do 3o. Reboque para Reservado
				If !Empty(cCodRB3)
					aAltStaDTU("2", cCodRB3, cFilOri, cViagem)
				EndIf
			EndIf
		EndIf

		If !lCompViag			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Motoristas da Viagem                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A240AtuDUP( aHeaderMot, {{cIteDTR,aColsMot}}, cFilOri, cViagem, cIteDTR, cCodVei )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os Ajudantes da Viagem                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			A240AtuDUQ( aHeaderAju, {{cIteDTR,aColsAju}}, cFilOri, cViagem, cIteDTR, cCodVei )
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica se o Retorno de Reboque esta amarrado a outra Viagem³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOpc == 4 .And. !Empty(DF7->DF7_FILDTR)  .And. !Empty(DF7->DF7_VGEDTR)
				DTR->(DbSetOrder(3))
				If DTR->(MsSeek(xFilial('DTR') + DF7->(DF7_FILDTR+DF7_VGEDTR+DF7_CODVEI)))
					A240AtuDUP( aHeaderMot, {{ DTR->DTR_ITEM, aColsMot }}, DF7->DF7_FILDTR, DF7->DF7_VGEDTR,DTR->DTR_ITEM,cCodVei )
					A240AtuDUQ( aHeaderAju, {{ DTR->DTR_ITEM, aColsAju }}, DF7->DF7_FILDTR, DF7->DF7_VGEDTR,DTR->DTR_ITEM,cCodVei )
				EndIf
			EndIf
		Else
			If Upper(AllTrim(FunName())) <> 'TMSA240'
				//-- Retorno do Reboque lancado diretamente pelos programas de Viagem
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os Motoristas da Viagem                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				AAdd(aMotoristas, aCompViag[4][aScan(aCompViag[2], {|X| X[2] == cCodVei} )])
				aMotoristas[1,1] := cIteDTR
				A240AtuDUP( aCompViag[3], aMotoristas, cFilOri, cViagem, cIteDTR, cCodVei )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os Ajudantes da Viagem                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aCompViag[6]) > 0
					AAdd(aAjudantes, aCompViag[6][aScan(aCompViag[2], {|X| X[2] == cCodVei} )])
					aAjudantes[1,1] := cIteDTR
					A240AtuDUQ( aCompViag[5], aAjudantes, cFilOri, cViagem, cIteDTR, cCodVei )
				EndIf
			Else
				//-- Retorno de Reboque lancado diretamente pelo Complemento de Viagem
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os Motoristas da Viagem                                ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aMotoristas := aClone(aMotViag)
				aMotoristas[1,1] := cIteDTR
				A240AtuDUP( aHeaderDUP, aMotoristas, cFilOri, cViagem, cIteDTR, cCodVei )
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava os Ajudantes da Viagem                                 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Len(aAjuViag) > 0
					aAjudantes := aClone(aAjuViag)
					aAjudantes[1,1] := cIteDTR
					A240AtuDUQ( aHeaderDUQ, aAjudantes, cFilOri, cViagem, cIteDTR, cCodVei )
				EndIf
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o Retorno do Reboque                                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RecLock("DF7",(nOpc == 3))
		If !lCompViag
			DF7->(Aeval(dbStruct(),{|aFieldName,nI| FieldPut(nI,If('FILIAL' $ aFieldName[1],xFilial( "DF7" ),M->&(aFieldName[1])))}))
		Else
			For nAux := 1 To Len(aDadRetRbq)
				DF7->&(aDadRetRbq[nAux,1]) := aDadRetRbq[nAux,2]
			Next
		EndIf
		DF7->DF7_STATUS := StrZero(1,Len(DF7->DF7_STATUS))
		DF7->DF7_ITEDTR := cIteDTR
		MsUnLock()
	EndIf
End Transaction

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15Vld ³ Autor ³ Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao de Campos                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF15Vld()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15Vld(cCampo)
Local lRet       := .T.
Local lContVei   := GetMV('MV_CONTVEI',,.T.)
Local lEmViag    := GetMV("MV_EMVIAG",,.F.)
Local cVeiGen    := GetMV('MV_VEIGEN')
Local cNumLiber  := ''
Local nCntFor    := 0
Local nX         := 0
Local nY         := 0
Local cAjudante  := ''
Local aVeiculos  := {}
Local nPosCodMot := Ascan(aHeaderMot, {|x| x[2] == "DUP_CODMOT" })
Local nPosNomMot := Ascan(aHeaderMot, {|x| x[2] == "DUP_NOMMOT" })
Local nPosTipMot := Ascan(aHeaderMot, {|x| x[2] == "DUP_TIPMOT" })
Local nPosCodAju := Ascan(aHeaderAju, {|x| x[2] == "DUQ_CODAJU" })
Local nPosNomAju := Ascan(aHeaderAju, {|x| x[2] == "DUQ_NOMAJU" })
Local lFilBas    := DA4->( FieldPos('DA4_FILBAS') ) > 0
Local aArea      := GetArea()
Local aAreaDA4   := DA4->( GetArea() )

Default cCampo    := ReadVar()

If cCampo $ 'M->DF7_CODRB1'	
	If !ExistChav("DF7",M->DF7_CODRB1+M->DF7_FILORI+M->DF7_VIAGEM) .Or. !ExistCpo("DA3",M->DF7_CODRB1)
		lRet := .F. 
	EndIf
	
	If lRet
		lRet := TMSAF15ConsRb( .T. )
	EndIf
	
	If lRet .And. Empty(M->DF7_VALFRE)
		AAdd(aVeiculos, { M->DF7_CODRB1, Posicione("DA3",1,xFilial("DA3")+M->DF7_CODRB1,"DA3_QTDEIX"), 0 })
		MsgRun(STR0023,,{|| TMSAF15Frt( aVeiculos )} ) //-- "Aguarde... Calculando o Frete de Carreteiro"
	EndIf

ElseIf cCampo $ 'M->DF7_CODVEI'
	DTR->(DbSetOrder(1))
	DTR->(MsSeek(xFilial('DTR') + M->(DF7_FILORI+DF7_VIAGEM)))
	
	DTQ->(DbSetOrder(2))
	DTQ->(MsSeek(xFilial('DTQ') + M->(DF7_FILORI+DF7_VIAGEM)))
	
	If lContVei
		//-- Nao pode selecionar o mesmo veiculo em mais 
		//-- de uma viagem ao mesmo tempo         
		If !LockByName("VGEVEI" + M->DF7_CODVEI,.T.,.F.)
			Help( ' ', 1, 'TMSA24050', , STR0016 + M->DF7_CODVEI ,3 ,0) //"O Veiculo esta sendo utilizado por outra viagem." ### "Veiculo: "
			lRet := .F.
		EndIf
	EndIf

	If lRet
		DA3->( DbSetOrder( 1 ) )
		If !DA3->(MsSeek(xFilial('DA3') + M->DF7_CODVEI, .F.))
			Help(' ', 1, 'TMSA24025',,STR0016 + M->DF7_CODVEI,5,11)	 //"Veiculo não cadastrado ..." ### "Veiculo : "
			lRet := .F.
		Else
			If DA3->DA3_ATIVO != '1'
				Help(' ', 1, 'TMSA24001',,STR0016 + M->DF7_CODVEI,5,11)	//-- Este veiculo nao esta ativo (DA3)	//'Veiculo : ' //'Veiculo : '
				lRet := .F.
			EndIf
		EndIf
	EndIf

	//-- Se for veiculo proprio zera os campos de Frete de Terceiros
	If lRet .And. DA3->DA3_FROVEI == StrZero(1, Len(DA3->DA3_FROVEI))
		M->DF7_VALFRE := 0
		M->DF7_TABCAR := CriaVar('DF7_TABCAR',.F.)
		M->DF7_TABFRE := CriaVar('DF7_TABFRE',.F.)
		M->DF7_TIPTAB := CriaVar('DF7_TIPTAB',.F.)
	EndIf

	//-- Verifica a Categoria do Veiculo
	If lRet
		DUT->(dbSetOrder(1))
		If !DUT->(MsSeek(xFilial('DUT')+DA3->DA3_TIPVEI))
			Help('',1,'TMSA24011') //-- Nao foi encontrado Categoria de Veiculo para este Tipo de Veiculo
			lRet := .F.
		Else
			If DUT->DUT_CATVEI <> '2
				Help('',1,'TMSA24010')	//--Os veiculos do reboque deverao ser de categoria igual "3" (Carreta).
				lRet := .F.
			EndIf
		EndIf
	EndIf

	// Verifica se o Veiculo esta sendo utilizado em outra Viagem
	If lRet .And. (lContVei .Or. lEmViag) .And. !TMSEmViag(, , M->DF7_CODVEI, 1)
		lRet := .F.
	EndIf

	//-- Verifica se o Veiculo esta Liberado
	DTU->( DbSetOrder(2) )
	If lRet .And. lContVei .And. (M->DF7_CODVEI <> cVeiGen .And. !DTU->(MsSeek(xFilial("DTU")+M->DF7_CODVEI+"2") ))
		Help(' ', 1, 'TMSA24006',,STR0016 + M->DF7_CODVEI ,5,11)	//"Veiculo sem Entrada Liberada!" ### "Veiculo : "
		lRet := .F.
	Else
		cNumLiber := DTU->DTU_NUMLIB
	EndIf

	//-- Quando selecionar um veiculo, gatilhar os motoristas
	If lRet .And. M->DF7_CODVEI <> _cCodVei
		If lContVei .And. !Empty(cNumLiber)
			DTO->(dbSetOrder(4))
			If DTO->(MsSeek(xFilial('DTO')+cNumLiber+'2'))
				While !DTO->(Eof()) .And. DTO->(DTO_FILIAL+DTO_NUMLIB+DTO_STATUS) == xFilial('DTO')+cNumLiber+'2'
					DA4->( DbSetOrder(1) )
					If DA4->( DbSeek( xFilial('DA4') + DTO->DTO_CODMOT ) )
						If TMSVldFunc( DA4->DA4_MAT, If( lFilBas, DA4->DA4_FILBAS, '' ) )
							If aScan( aColsMot, {|x| x[nPosCodMot] == DTO->DTO_CODMOT} ) == 0
								AAdd(aColsMot, Array(Len(aHeaderMot)+1))
								For nCntFor := 1 To Len(aHeaderMot)
									aColsMot[Len(aColsMot),nCntFor] := CriaVar(aHeaderMot[nCntFor,2])
								Next
								aColsMot[Len(aColsMot), nPosCodMot] := DTO->DTO_CODMOT
								aColsMot[Len(aColsMot), nPosNomMot] := Posicione("DA4",1,xFilial("DA4")+DTO->DTO_CODMOT,"DA4_NOME")
								aColsMot[Len(aColsMot), nPosTipMot] := DA4->DA4_TIPMOT
								aColsMot[Len(aColsMot),Len(aHeaderMot)+1] := .F.
							EndIf
						EndIf
					EndIf
					DTO->(dbSkip())
				EndDo
            EndIf
		ElseIf !Empty(DA3->DA3_MOTORI)
			DA4->( DbSetOrder(1) )
			If DA4->( DbSeek( xFilial('DA4') + DA3->DA3_MOTORI ) )
				If TMSVldFunc( DA4->DA4_MAT, If( lFilBas, DA4->DA4_FILBAS, '' ) )
					If aScan( aColsMot, {|x| x[nPosCodMot] == DA3->DA3_MOTORI} ) == 0
						AAdd(aColsMot, Array(Len(aHeaderMot)+1))
						For nCntFor := 1 To Len(aHeaderMot)
							aColsMot[Len(aColsMot),nCntFor] := CriaVar(aHeaderMot[nCntFor,2])
						Next
						aColsMot[Len(aColsMot), nPosCodMot] := DA3->DA3_MOTORI
						aColsMot[Len(aColsMot), nPosNomMot] := Posicione("DA4",1,xFilial("DA4")+DA3->DA3_MOTORI,"DA4_NOME")
						aColsMot[Len(aColsMot), nPosTipMot] := DA4->DA4_TIPMOT
						aColsMot[Len(aColsMot),Len(aHeaderMot)+1] := .F.
					EndIf
				EndIf
			EndIf			
		EndIf        
		//-- Se no cadastro do motorista (DA4) foi informado Ajudante(s), gatilhar os codigos
		//-- automaticamente no aCols de Ajudantes
		For nCntFor := 1 To Len(aColsMot)
			If lContVei
				LockByName("VGEMOT" + aColsMot[nCntFor,nPosCodMot],.T.,.F.)
			EndIf
			DA4->(DbSetOrder(1))
			If DA4->(MsSeek(xFilial("DA4")+ aColsMot[nCntFor,nPosCodMot]))
				For nX := 1 To 3
					cAjudante := AllTrim( Str(nX) )
					If !Empty(DA4->(DA4_AJUDA&cAjudante))
						//--Bloqueia o ajudante para nao ser utilizado em outra viagem
						If !LockByName("VGEAJU" + DA4->(DA4_AJUDA&cAjudante),.T.,.F.)
							Help( ' ', 1, 'TMSA24048', , STR0021 + DA4->(DA4_AJUDA&cAjudante) ,3 ,0) //"O Ajudante esta sendo utilizado por outra viagem." ### "Ajudante: "
						Else
							If aScan(aColsAju, {|x| x[nPosCodAju] == DA4->(DA4_AJUDA&cAjudante)} ) == 0
								AAdd(aColsAju,Array(Len(aHeaderAju)+1))
								For nY := 1 To Len(aHeaderAju)
									aColsAju[Len(aColsAju),nY] := CriaVar(aHeaderAju[nY,2])
								Next nY
								aColsAju[Len(aColsAju), nPosCodAju] := DA4->(DA4_AJUDA&cAjudante)
								aColsAju[Len(aColsAju), nPosNomAju] := Posicione("DAU",1,xFilial("DAU")+DA4->(DA4_AJUDA&cAjudante),"DAU_NOME")
								aColsAju[Len(aColsAju), Len(aHeaderAju)+1] := .F.
								//--Bloqueia o ajudante para nao ser utilizado em outra viagem
								LockByName("VGEAJU" + DA4->(DA4_AJUDA&cAjudante),.T.,.F.)
							EndIf
						EndIf
					EndIf
				Next nX
			EndIf
		Next nCntFor
		_cCodVei := M->DF7_CODVEI
	EndIf

	//-- Preparacao para o calculo do valor do Frete Terceiro
	If lRet .And. Empty(M->DF7_VALFRE)
		AAdd(aVeiculos, { M->DF7_CODVEI, Posicione("DA3",1,xFilial("DA3")+M->DF7_CODVEI,"DA3_QTDEIX"), 0 })
		MsgRun(STR0023,,{|| TMSAF15Frt( aVeiculos )} ) //-- "Aguarde... Calculando o Frete de Carreteiro"
	EndIf
EndIf


RestArea( aAreaDA4 )
RestArea( aArea )
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15Mot ³Autor  ³Vitor Raspa           ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Motoristas da Retirada do Reboque                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA240Mot(nExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExpN1 - Opcao Selecionada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF15                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAF15Mot(nOpc)
Local oDlg
Local oGetDados
Local aButtons   := {}
Local lContVei   := GetMV('MV_CONTVEI',,.T.)
Local cNoFields  := ''
Local lOk        := .F.
Local nCntFor    := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(aHeaderMot)
aCols   := {}

If nOpc == 3
	DUP->(DbGoTo(0))
	If Len(aColsMot) == 0
		aCols := {}
		AAdd(aCols,Array(Len(aHeader)+1))
		For nCntFor := 1 To Len(aHeader)
			aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
		Next
		aCols[1,Len(aHeader)+1] := .F.
	Else
		aCols := aClone( aColsMot )
	EndIf
Else
	If Len(aColsMot) == 0
		DUP->(DbSetOrder(1))
		If DUP->(MsSeek(xFilial('DUP') + DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)))
			Do While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == xFilial("DUP")+DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)
				AAdd(aCols,Array(Len(aHeaderMot)+1))
				For nCntFor := 1 To Len(aHeaderMot)
					If	aHeaderMot[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=DUP->(FieldGet(FieldPos(aHeaderMot[nCntFor,2])))
					Else
						aCols[Len(aCols),nCntFor]:=CriaVar(aHeaderMot[nCntFor,2])
					EndIf
				Next nCntFor
				aCols[Len(aCols),Len(aHeaderMot)+1]:=.F.
				DUP->(dbSkip())
			EndDo
		EndIf
	Else
		aCols := aClone( aColsMot )
	EndIf
EndIf

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

If lContVei
	If DUP->( FieldPos('DUP_LIBSEG') )  > 0 .And. DUP->( FieldPos('DUP_VALSEG') > 0 )
		cNoFields := 'DUP_FILORI.DUP_VIAGEM.DUP_ITEDTR.DUP_CODVEI.DUP_LIBSEG.DUP_VALSEG'
	Else
		cNoFields := 'DUP_FILORI.DUP_VIAGEM.DUP_ITEDTR.DUP_CODVEI'
	EndIf
Else
	cNoFields := 'DUP_FILORI.DUP_VIAGEM.DUP_ITEDTR.DUP_CODVEI'
EndIf

//-- Tratamento para Operadoras de Frota / Vale-Pedagio
cNoFields += '.DUP_CODOPE.DUP_NOMOPE.DUP_IDOPE'

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inteface com o Usuario                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg FROM 94 ,104 TO 330,650 TITLE STR0017 Of oMainWnd PIXEL  //-- 'Motoristas'

@ 018,003 SAY STR0015 Of oDlg PIXEL SIZE 56 ,9  //"Viagem : "
@ 018,036 SAY M->DF7_FILORI+"/"+M->DF7_VIAGEM Of oDlg PIXEL SIZE 50 ,9

@ 018,096 SAY STR0016 Of oDlg PIXEL SIZE 60 ,9  //"Veiculo : "
@ 018,125 SAY M->DF7_CODVEI + ' - ' + M->DF7_MODVEI Of oDlg PIXEL SIZE 140 ,9

oGetDados := MSGetDados():New(30,2,118,271,nOpc,'TMSAF15MtLOk','AllwaysTrue', ,.T.,,,,100,,,,If(nOpc == 2 .Or. nOpc == 5,"AlwaysFalse",'AllWaysTrue'))

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (	oGetdados:Refresh(),;
											EnchoiceBar(oDlg, 	{|| If( TMSAF15MtTOk(nOpc), (lOk := .T., oDlg:End()), lOk := .F.) },;
																{|| lOk := .F., oDlg:End()},,aButtons) )

If lOk .And. (nOpc <> 2 .And. nOpc <> 5)
	aColsMot := aClone(aCols)
EndIf

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15MtLOk³ Autor ³ Vitor Raspa         ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Linha da GetDados de Motoristas               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF15MtLOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSAF15MtLOk()                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15MtLOk()
Local lRet     := .T.
Local lEmViag  := GetMV("MV_EMVIAG",,.F.)
Local lContVei := GetMv("MV_CONTVEI")

If !GdDeleted(n)
	If !MaCheckCols(aHeader,aCols,n)
		lRet := .F.
	EndIf

	If lRet .And. !GDCheckKey( {'DUP_CODMOT'}, 4 )
		lRet := .F.
	EndIf

	//-- Verifica se o Motorista esta sendo utilizado em outra viagem.
	//-- Verificacao realizada quando o parametro MV_CONVEI ou o parametro MV_EMVIAG estivem ativos e a viagem
	//-- for diferente de 'Planejada'
	If lRet .And. ( lContVei .Or. lEmViag )
		If !TMSEmViag(M->DF7_FILORI, M->DF7_VIAGEM, GDFieldGet('DUP_CODMOT',n), 2, .T.)
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15MtTOk³ Autor ³Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao Geral da Tela de Motoristas                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF15MtTOk(nExpN1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³TMSAF15                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15MtTOk(nOpc)
Local lRet     := .T.
Local nAux     := 0
Local lEmViag  := GetMV("MV_EMVIAG",,.F.)
Local lContVei := GetMv("MV_CONTVEI")
Local aAreaDTR := DTR->(GetArea())
Local aAreaDA4 := DA4->( GetArea() )
Local nDel     := 0       
Local lFilBas  := DA4->( FieldPos('DA4_FILBAS') ) > 0

//--Verifica se foram informados motoristas
//--para operacao:
If lRet .And. (nOpc == 3 .Or. nOpc == 4)
	For nAux := 1 To Len(aCols)
		If aCols[nAux,Len(aHeader)+1]
			nDel++
		EndIf
	Next
	If nDel == Len(aCols)
		Help('',1,'TMSAF1504') //-- 'Motorista para retirada do reboque nao informado!'
		lRet := .F.
	EndIf
EndIf

//--Valida as Linhas:
If lRet
	lRet := IIf(nOpc == 3 .Or. nOpc == 4, TMSAF15MtLOk(), .T.) 
EndIf

//--Verifica a situacao do motorista X folha (GPE)
If lRet
	DA4->( DbSetOrder(1) )
	If DA4->( DbSeek( xFilial('DA4') + GDFieldGet('DUP_CODMOT',n) ) )
		lRet := TMSVldFunc( DA4->DA4_MAT, If( lFilBas, DA4->DA4_FILBAS, '' ) )
	EndIf
EndIf

//-- Verifica se o Motorista esta sendo utilizado em outra viagem.
//-- Verificacao realizada quando o parametro MV_CONVEI ou o parametro MV_EMVIAG estivem ativos e a viagem
If lRet .And. ( lContVei .Or. lEmViag )
	For nAux := 1 To Len(aCols)
		If !GDDeleted( nAux ) .And. !TMSEmViag(M->DF7_FILORI, M->DF7_VIAGEM, GDFieldGet('DUP_CODMOT',nAux), 2, .T.)
			lRet := .F.
		EndIf
	Next
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15Aju ³ Autor ³ Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Ajudantes do Retorno de Reboque                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF15Aju(nExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExpN1 - Opcao Selecionada                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSAF15                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSA240Aju(nOpc)
Local lOk       := .F.
Local nCntFor   := 0
Local oDlg      := NIL
Local oGetDados := NIL

//-- Finaliza as Teclas de Atalhos
TmsKeyOff(aSetKey)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aCols                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeader := aClone(aHeaderAju)
aCols   := {}

If nOpc == 3 
	DUQ->(DbGoTo(0))
	If Len(aColsAju) == 0
		aCols := {}
		If Empty(aCols)
			AAdd(aCols,Array(Len(aHeader)+1))
			For nCntFor := 1 To Len(aHeader)
				aCols[1,nCntFor] := CriaVar(aHeader[nCntFor,2])
			Next
			aCols[1,Len(aHeader)+1] := .F.
		EndIf
	Else
		aCols := aClone(aColsAju)
	EndIf
Else
	If Len(aColsAju) == 0
		DUQ->(DbSetOrder(1))
		If DUQ->(MsSeek(xFilial('DUQ') + DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)))
			Do While !DUQ->(Eof()) .And. DUQ->(DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM+DUQ_ITEDTR) == xFilial("DUQ")+DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)
				AAdd(aCols,Array(Len(aHeaderAju)+1))
				For nCntFor := 1 To Len(aHeaderAju)
					If	aHeaderAju[nCntFor,10] != "V"
						aCols[Len(aCols),nCntFor]:=DUQ->(FieldGet(FieldPos(aHeaderAju[nCntFor,2])))
					Else
						aCols[Len(aCols),nCntFor]:=CriaVar(aHeaderAju[nCntFor,2])
					EndIf
				Next nCntFor
				aCols[Len(aCols),Len(aHeaderAju)+1]:=.F.
				DUQ->(dbSkip())
			EndDo
		EndIf
	Else
		aCols := aClone( aColsAju )
	EndIf
EndIf

DEFINE MSDIALOG oDlg FROM 94 ,104 TO 330,650 TITLE STR0020 Of oMainWnd PIXEL  //'Ajudantes'

@ 18 ,3   SAY STR0015  Of oDlg PIXEL SIZE 56 ,9  //"Viagem : "
@ 18 ,36  SAY M->DF7_FILORI+"/"+M->DF7_VIAGEM Of oDlg PIXEL SIZE 50 ,9

@ 18 ,96  SAY STR0016 Of oDlg PIXEL SIZE 60 ,9  //"Veiculo : "
@ 18 ,125 SAY M->DF7_CODVEI + ' - ' + M->DF7_MODVEI Of oDlg PIXEL SIZE 140 ,9

oGetDados := MSGetDados():New(30,2,118,271,nOpc,'TMSAF15AjLOk','AllwaysTrue()',,.T.,,,,100,,,,If(nOpc == 2 .Or. nOpc == 5,'AlwaysFalse','AllWaysTrue'))

ACTIVATE MSDIALOG oDlg CENTERED ON INIT (	oGetdados:Refresh(),;
											EnchoiceBar(oDlg, 	{|| Iif(TMSAF15AjTOk(nOpc),( lOk := .T., oDlg:End()),lOk := .F.)},;
																{|| lOk := .F., oDlg:End()}) )

If lOk .And. (nOpc <> 2 .And. nOpc <> 5)
	aColsAju := aClone(aCols)
EndIf

//-- Iniciliza as Teclas de Atalhos
TmsKeyOn(aSetKey)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15AjLOk³ Autor ³Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da Linha da GetDados de Ajudantes                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSAF15AjLOk()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15AjLOk()
Local lRet       := .T.
Local lContVei   := GetMv("MV_CONTVEI")
Local lEmViag := GetMV("MV_EMVIAG",,.F.)

//-- Analisa se ha itens duplicados na GetDados.
If !GdDeleted(n)                                
	If !MaCheckCols(aHeader,aCols,n)
		lRet := .F.
	EndIf

	If lRet .And. !GDCheckKey( {'DUQ_CODAJU'}, 4 )
		lRet := .F.
	EndIf            

	//-- Valida se o Ajudante, esta sendo utilizado em outra Viagem
	If lRet .And. ( lContVei .Or. lEmViag ) .And. !TMSEmViag(M->DF7_FILORI, M->DF7_VIAGEM, GdFieldGet("DUQ_CODAJU",n), 3)
		lRet := .F.
	EndIf
EndIf

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15AjTOk³ Autor ³Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Validacao da Tela  da GetDados de Ajudantes                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF15AjTOk(nExpN1)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15AjTOk(nOpc)
Local lRet         := .T.

lRet := IIf( nOpc == 3 .Or. nOpc == 4, TMSAF15AjLOk(), .T.)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15IniVar³Autor ³Vitor Raspa          ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Inicializa Variaveis                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF15IniVar(nExpN1)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nExpN1 - Opcao Selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Logico                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAF15IniVar( nOpc )
Local cNoFieldsDUP := ''
Local lContVei     := GetMV('MV_CONTVEI',,.T.)
Local nCntFor      := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader - Motoristas                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeaderMot := {}
If lContVei
	aHeaderMot := ApBuildHeader("DUP", {"DUP_FILORI","DUP_VIAGEM","DUP_ITEDTR","DUP_CODVEI","DUP_LIBSEG","DUP_VALSEG","DUP_CODOPE","DUP_NOMOPE","DUP_IDOPE"})
Else
	aHeaderMot := ApBuildHeader("DUP", {"DUP_FILORI","DUP_VIAGEM","DUP_ITEDTR","DUP_CODVEI","DUP_CODOPE","DUP_NOMOPE","DUP_IDOPE"})
EndIf 

If nOpc == 4
	DUP->(DbSetOrder(1))
	If DUP->(MsSeek(xFilial('DUP') + DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)))
		Do While !DUP->(Eof()) .And. DUP->(DUP_FILIAL+DUP_FILORI+DUP_VIAGEM+DUP_ITEDTR) == xFilial("DUP")+DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)
			AAdd(aColsMot,Array(Len(aHeaderMot)+1))
			For nCntFor := 1 To Len(aHeaderMot)
				If	aHeaderMot[nCntFor,10] != "V"
					aColsMot[Len(aColsMot),nCntFor] := DUP->(FieldGet(FieldPos(aHeaderMot[nCntFor,2])))
				Else
					aColsMot[Len(aColsMot),nCntFor] := CriaVar(aHeaderMot[nCntFor,2])
				EndIf
			Next nCntFor
			aColsMot[Len(aColsMot),Len(aHeaderMot)+1]:=.F.
			DUP->(dbSkip())
		EndDo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Montagem do aHeader - Ajudantes                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aHeaderAju := ApBuildHeader("DUQ", {"DUQ_FILORI", "DUQ_VIAGEM","DUQ_ITEDTR","DUQ_CODVEI"})

If nOpc == 4
	DUQ->(DbSetOrder(1))
	If DUQ->(MsSeek(xFilial('DUQ') + DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)))
		Do While !DUQ->(Eof()) .And. DUQ->(DUQ_FILIAL+DUQ_FILORI+DUQ_VIAGEM+DUQ_ITEDTR) == xFilial("DUQ")+DF7->(DF7_FILORI+DF7_VIAGEM+DF7_ITEDTR)
			AAdd(aColsAju,Array(Len(aHeaderAju)+1))
			For nCntFor := 1 To Len(aHeaderAju)
				If	aHeaderAju[nCntFor,10] != "V"
					aColsAju[Len(aColsAju),nCntFor]:=DUQ->(FieldGet(FieldPos(aHeaderAju[nCntFor,2])))
				Else
					aColsAju[Len(aColsAju),nCntFor]:=CriaVar(aHeaderAju[nCntFor,2])
				EndIf
			Next nCntFor
			aColsAju[Len(aColsAju),Len(aHeaderAju)+1]:=.F.
			DUQ->(dbSkip())
		EndDo
	EndIf
EndIf

Return

/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15Frt³ Autor ³Vitor Raspa            ³ Data ³ 11.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Calcula Frete Carreteiro                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF15Frt(aExpA1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aExpA1 - Veiculos Informados                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TMSAF15Frt(aVeiculos)
Local cChave     := ''
Local cCodVei    := M->DF7_CODVEI
Local cCodRb1    := M->DF7_CODRB1
Local cCodRb2    := M->DF7_CODRB2
Local cCodRb3    := M->DF7_CODRB3
Local cVeiRas    := ''
Local cCodFor    := ''
Local cLojFor    := ''
Local cFrovei    := ''
Local cSerTMSVge := ''
Local cTipTraVge := ''
Local cFilOri    := ''
Local cViagem    := ''
Local lTercRbq   := DF7->(ColumnPos("DF7_CODRB3")) > 0
Local lTipOpVg   := DTQ->(ColumnPos("DTQ_TPOPVG")) > 0

Default aVeiculos := {}
                             
DTQ->(DbSetOrder(2))
If DTQ->(MsSeek(xFilial('DTQ') + cFilOri + cViagem))
	cSerTMSVge := DTQ->DTQ_SERTMS
	cTipTraVge := DTQ->DTQ_TIPTRA
EndIf

DA3->(DbSetOrder(1))
If DA3->(MsSeek(xFilial('DA3')+ cCodVei))
	cFrovei := DA3->DA3_FROVEI 
	cChave  := DA3->DA3_TIPVEI
	cCodFor := DA3->DA3_CODFOR
	cLojFor := DA3->DA3_LOJFOR
	cVeiRas := DA3->DA3_VEIRAS
EndIf

If DA3->(MsSeek(xFilial('DA3')+ cCodRb1))
	cChave+= DA3->DA3_FROVEI
Else
	cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
EndIf

If DA3->(MsSeek(xFilial('DA3')+cCodRb2 ))
	cChave+= DA3->DA3_FROVEI
Else
	cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
EndIf
If lTercRbq
	If DA3->(MsSeek(xFilial('DA3')+cCodRb3 ))
		cChave+= DA3->DA3_FROVEI
	Else
		cChave+= StrZero(0, Len(DA3->DA3_FROVEI))
	EndIf
EndIf
cChave+=cVeiRas

If DTT->(FieldPos("DTT_TIPVIA")) > 0
	cChave += DTQ->DTQ_TIPVIA
EndIf

//- Estrutura do Array de retorno da funcao TMSFretCar: 
//- Verificar fonte TMSXFUNA
aRet := TMSFretCar(DTQ->DTQ_ROTA, cCodFor, cLojFor, aVeiculos, cChave, cSerTMSVge, cTipTraVge,,,,,,Iif(lTipOpVg,DTQ->DTQ_TPOPVG,''))

If !Empty(aRet)
	If cFrovei <> "1"
		M->DF7_VALFRE :=  aRet[2]
		M->DF7_TABCAR :=  If(Empty(aRet[2]),CriaVar('DF7_TABCAR',.F.),aRet[3])
	EndIf
EndIf              	

If Empty(aRet[2]) .AND. cFrovei <> "1"
	aFrePag := TMSCalFrePag( cFilOri, cViagem, cCodVei,, .T. )
	IF Len(aFrePag) > 0 
		M->DF7_TABFRE := aFrePag[1,1]
		M->DF7_TIPTAB := aFrePag[1,2]
		M->DF7_VALFRE := aFrePag[1,3]
	Endif	                                       		
EndIf

Return( .T. )

/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15ConsRb³ Autor ³Vitor Raspa         ³ Data ³ 13.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consulta padrao para retornar os Reboques disponiveis no    ³±±
±±³          ³Porto                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF15ConsRb( lExpL1 )                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExpL1: Realiza apenas validacao do que foi informado?     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15ConsRb( lValida )
Local aArea       := GetArea()
Local cAliasQry   := ''
Local cQuery      := ''
Local nItem       := 0
Local aReboques   := {}
Local cAtivChP    := GetMv('MV_ATIVCHP',,'')
Local lRet        := .T.
Local aButtonAdic := {}
Local cFilDA3     := ''

Local cPlacaRB1 := Space(Len(DA3->DA3_PLACA))
Local cPlacaRB2 := Space(Len(DA3->DA3_PLACA))
Local cPlacaRB3 := Space(Len(DA3->DA3_PLACA))
Local cModRB1   := Space(Len(DA3->DA3_DESC))
Local cModRB2   := Space(Len(DA3->DA3_DESC))
Local cModRB3   := Space(Len(DA3->DA3_DESC))
Local cCodRB3   := ''
Local aCabec    := {}
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

Default lValida := .F.

cQuery += "SELECT DTW.DTW_FILORI, DTW.DTW_VIAGEM, DTW.DTW_ATIVID,"
cQuery += " DTR.DTR_CODVEI, DTR.DTR_CODRB1, DTR.DTR_CODRB2 "
If lTercRbq
	cQuery += " , DTR.DTR_CODRB3 "
EndIf
cQuery += "FROM " + RetSQLName('DTW') + " DTW," + RetSQLName('DTR') + " DTR "
cQuery += "WHERE DTR.DTR_FILIAL = '" + xFilial('DTR') + "'"
cQuery += " AND DTR.DTR_FILORI = DTW.DTW_FILORI"
cQuery += " AND DTR.DTR_VIAGEM = DTW.DTW_VIAGEM"
cQuery += " AND DTR.D_E_L_E_T_ = ' '"
cQuery += " AND DTW.DTW_FILATI = '" + cFilAnt + "'"
cQuery += " AND DTW.DTW_ATIVID = '" + cAtivChP + "'"
cQuery += " AND DTW.DTW_STATUS = '2'"
cQuery += " AND DTW.D_E_L_E_T_ = ' '"
cQuery += " AND NOT EXISTS ( SELECT DW4_FILORI, DW4_VIAGEM FROM " + RetSQLName('DW4') + "  DW4 "
cQuery += 					"WHERE DW4.DW4_FILORI = DTR.DTR_FILORI"
cQuery += 					" AND DW4.DW4_VIAGEM = DTR.DTR_VIAGEM"
cQuery += 					" AND DW4.DW4_CODVEI = DTR.DTR_CODVEI"
cQuery += 					" AND DW4.D_E_L_E_T_ = ' ')"
cQuery += "	AND NOT EXISTS ( SELECT DF7.DF7_CODRB1 FROM " + RetSQLName('DF7') + " DF7 "
cQuery += 					"WHERE DF7.DF7_FILORI = DTR.DTR_FILORI"
cQuery += 					" AND DF7.DF7_VIAGEM = DTR.DTR_VIAGEM"
cQuery += 					" AND DF7.D_E_L_E_T_ = ' ')"
cQuery    := ChangeQuery(cQuery)
cAliasQry := GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

While !(cAliasQry)->(EoF())


	cFilDA3 := If( !Empty(xFilial('DA3')), (cAliasQry)->DTW_FILORI, xFilial('DA3') )
	
	DA3->(DbSetOrder(1))
	If !Empty((cAliasQry)->DTR_CODRB1) .And. DA3->(MsSeek(cFilDA3 + (cAliasQry)->DTR_CODRB1))
		cPlacaRB1 := DA3->DA3_PLACA
		cModRB1   := DA3->DA3_DESC
	EndIf
	If !Empty((cAliasQry)->DTR_CODRB2) .And. DA3->(MsSeek(cFilDA3 + (cAliasQry)->DTR_CODRB2))
		cPlacaRB2 := DA3->DA3_PLACA
		cModRB2   := DA3->DA3_DESC
	Endif
	If lTercRbq
		If !Empty((cAliasQry)->DTR_CODRB3) .And. DA3->(MsSeek(cFilDA3 + (cAliasQry)->DTR_CODRB3))
			cPlacaRB3 := DA3->DA3_PLACA
			cModRB3   := DA3->DA3_DESC
		Endif
	Else
		cPlacaRB3 := ""
		cModRB3 	:= ""
	EndIf
	
	If lTercRbq
		cCodRB3 := (cAliasQry)->DTR_CODRB3
	Else 
		cCodRB3 := ""
	EndIf 

	AAdd(aReboques,{	(cAliasQry)->DTR_CODRB1,; 
						cPlacaRB1,;
						cModRB1,;
						(cAliasQry)->DTR_CODRB2,;
						cPlacaRB2,;
						cModRB2,;
						(cAliasQry)->DTW_FILORI,;
						(cAliasQry)->DTW_VIAGEM,cCodRB3,cPlacaRb3,cModRB3} )

	(cAliasQry)->(DbSkip())
EndDo

If !Empty(aReboques)

	If lValida
		nItem := aScan( aReboques, {|x| AllTrim(x[1]) == AllTrim(M->DF7_CODRB1)} )
		If nItem == 0
			Help('',1,'TMSAF1502') //-- 'O reboque informado nao esta disponivel para realizar a retirada no porto'
			lRet := .F.
		EndIf
	Else
		If lTercRbq
			cCodRB3 	:= RetTitle("DTR_CODRB3")
		 	cPlacaRB3	:= RetTitle("DA3_PLACA")
		 	cModRb3	:= RetTitle("DTR_MODRB3")
		Else
			cCodRB3	:= ""
			cPlacaRB3	:= ""
			cModRb3	:= ""
		EndIf		
		aCabec := {RetTitle("DTR_CODRB1"),;
					  RetTitle("DA3_PLACA" ),;
		           RetTitle("DA3_DESC"  ),;
					  RetTitle("DTR_CODRB2"),;
					  RetTitle("DA3_PLACA" ),;
					  RetTitle("DA3_DESC"  ),;
					  RetTitle("DTW_FILORI"),;
					  RetTitle("DTW_VIAGEM"),cCodRB3,cPlacaRB3,cModRb3}
					  
		aButtonAdic := {{15, {|nItem| TmsVisViag(aReboques[nItem,7],aReboques[nItem,8])} }}

		nItem := TmsF3Array( {	RetTitle('DTR_CODRB1'),;
								RetTitle('DA3_PLACA'),;
								RetTitle('DTR_MODRB1'),;
								RetTitle('DTR_CODRB2'),;
								RetTitle('DA3_PLACA'),;
								RetTitle('DTR_MODRB2'),;
								RetTitle('DTR_FILORI'),;
								RetTitle('DTR_VIAGEM'),cCodRB3,cPlacaRB3,cModRb3},;
								aReboques,; 
								STR0022,,; //-- 'Veiculos disponiveis no Porto'
								aButtonAdic,;
								aCabec) // Utiliza Filtro
	EndIf

	If	nItem > 0 .And. lRet
		//-- VAR_IXB eh utilizada como retorno da consulta F3
		VAR_IXB       := aReboques[nItem, 1]
		M->DF7_CODRB2 := aReboques[nItem, 4]
		M->DF7_MODRB2 := Posicione('DA3',1,xFilial('DA3') + aReboques[nItem, 4],'DA3_DESC')
		M->DF7_FILORI := aReboques[nItem, 7]
		M->DF7_VIAGEM := aReboques[nItem, 8]
		If lTercRbq	
			M->DF7_CODRB3 := aReboques[nItem, 9]
			M->DF7_MODRB3 := Posicione('DA3',1,xFilial('DA3') + aReboques[nItem, 9],'DA3_DESC')
		EndIf

		DTQ->(DbSetOrder(2))
		If DTQ->(MsSeek(xFilial('DTQ') + M->(DF7_FILORI+DF7_VIAGEM)))
			M->DF7_ROTA   := DTQ->DTQ_ROTA
			M->DF7_DESROT := Posicione('DA8',1,xFilial('DA8')+M->DF7_ROTA,'DA8_DESC')
		EndIf
	EndIF
Else
	Help('',1,'TMSAF1501') //-- 'Nao existem veiculos para efetuar retirada no porto'
EndIf

(cAliasQry)->(DbCloseArea())
RestArea(aArea)
Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Vitor Raspa           ³ Data ³ 11.Dez.06³±±
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
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()

Private aRotina	:=	{	{ STR0002 ,"AxPesqui", 0, 1, 0, .F. },;	//"Pesquisar"
						{ STR0003 ,"TMSAF15Mnt", 0, 2, 0, NIL },;	//"Visualizar"
						{ STR0004 ,"TMSAF15Mnt", 0, 3, 0, NIL },;	//"Incluir"
						{ STR0005 ,"TMSAF15Mnt", 0, 4, 0, NIL },;	//"Alterar"
						{ STR0006 ,"TMSAF15Mnt", 0, 5, 0, NIL },;	//"Excluir"
						{ STR0007 ,"TMSAF15Leg", 0, 6, 0, NIL }}	//"Legenda

//-- Ponto de Entrada para adicionar itens ao Menu
If ExistBlock("TMAF15MNU")
	ExecBlock("TMAF15MNU",.F.,.F.)
EndIf

Return(aRotina)

/*                                                                           
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSAF15Leg³ Autor ³Vitor Raspa            ³ Data ³ 13.Dez.06³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Legenda                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSAF15Leg()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSAF15Leg()
BrwLegenda( cCadastro,; 
			STR0008  ,; //"Status"
			{	{ "BR_VERDE"	, STR0009},;	//'Em Aberto'
				{ "BR_VERMELHO"	, STR0010}})	//'Encerrado'

Return(.T.)

