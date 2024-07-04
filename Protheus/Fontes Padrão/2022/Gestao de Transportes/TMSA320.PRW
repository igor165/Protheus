#INCLUDE "tmsa320.ch"
#INCLUDE "protheus.ch"

Static aManifesto := {}
Static aManAux    := {}
Static oNoMarked
Static oMarked
Static oOk
Static oNo
Static oBr
Static lTM320Grv  := ExistBlock('TM320Grv')
Static lExibeTab  := .F. // utilizado para controlar a exibicao da tabela de frete.
Static lAWBRepete
Static lAWBDigito
Static lDTX_DIGAWB
Static lDT8_DIGAWB      

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TMSA320  ³ Autor ³Patricia A. Salomao    ³ Data ³12.03.2002  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Geracao da AWB                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320()                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SigaTMS - Gestao de Transporte                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA320()

Private cCadastro  := STR0001 //"Geracao de AWB"
Private aRotina    := MenuDef()

//-- Cria variaveis privates caso a função TMSA320Mnt tenha sido chamada pelo menu de manutenção em Aereo->Viagens
If Valtype(lAWBRepete) == "U"
	lAWBRepete := DT8->(FieldPos("DT8_CODCIA")) > 0 .And. DT8->(FieldPos("DT8_LOJCIA")) > 0  
EndIf
If Valtype(lAWBDigito) == "U"
	lAWBDigito := TmsA320Six()
EndIf
If Valtype(lDTX_DIGAWB) == "U"
	lDTX_DIGAWB:= (DTX->(FieldPos("DTX_DIGAWB")) > 0)
EndIf
If Valtype(lDT8_DIGAWB) == "U"
	lDT8_DIGAWB:= (DT8->(FieldPos("DT8_DIGAWB")) > 0)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
mBrowse(6,1,22,75,"DTV")

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA320Mnt  ³ Autor ³ Patricia A. Salomao ³ Data ³12.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao da AWB                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320Mnt(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do registro                                 ³±±
±±³          ³ ExpN2 = Opcao selecionada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA320Mnt(cAlias, nReg, nOpcx, cFilOri, cViagem)

Local cSeek			:= ''
Local cDscComp		:= ''
Local lRet			:= .F.
//-- Controle de dimensoes de objetos
Local aSize			:= {}
Local aObjects		:= {}
Local aInfo			:= {}
Local aPosObj		:= {}
//-- Folder
Local aPages		:= {'HEADER'}
Local aTitles		:= { STR0013 } //"Composicao do frete"
Local oFolder
//-- Listbox
Local cLbx			:= ''
Local oEnch
Local nCntFor		:= 0
Local nOpca			:= 0
Local aAreaAnt		:= GetArea()
Local aButtons		:= {}
Local aVisual		:= {}
Local cCodDes		:= GetMV("MV_DESAWB") // Despesa AWB.
Local cTesAWB		:= GetMV("MV_TESAWB") // Tes da AWB.
Local aEmptyCpo		:= {}
Local nY
Local nCont			:= 0
Local aSomaButtons	:= {}

//-- Utilizado pela funcao TmsA500Dsc
Local lPrimComp  := .T.

Local aFldDTV		:= {}

Default cFilOri  := ""
Default cViagem  := ""

Private cOpcao   := STR0014 //'Digitacao do Componente'
Private nPerOri  := 0
Private aFrtOri  := {}
Private aSetKey  := {}

Private oLbx
Private aFrete   := {}
Private aCodPro  := {}
Private cProdCal := ""
Private cDocTMS  := '3' // AWB
Private aTela[0][0],aGets[0]
Private nAlqICM  := 0
Private aCompos  := {}
//-- Cria variaveis privates caso a função TMSA320Mnt tenha sido chamada pelo menu de manutenção em Aereo->Viagens
If Valtype(lAWBRepete) == "U"
	lAWBRepete := DT8->(FieldPos("DT8_CODCIA")) > 0 .And. DT8->(FieldPos("DT8_LOJCIA")) > 0  
EndIf
If Valtype(lAWBDigito) == "U"
	lAWBDigito := TmsA320Six()
EndIf
If Valtype(lDTX_DIGAWB) == "U"
	lDTX_DIGAWB:= (DTX->(FieldPos("DTX_DIGAWB")) > 0)
EndIf
If Valtype(lDT8_DIGAWB) == "U"
	lDT8_DIGAWB:= (DT8->(FieldPos("DT8_DIGAWB")) > 0)
EndIf

If Empty(cCodDes)
	AADD(aEmptyCpo,"MV_DESAWB")
EndIf
If Empty(cTesAWB)
	AADD(aEmptyCpo,"MV_TESAWB")
EndIf

For nY:=1 To Len(aEmptyCpo)
	Help("",1,"TMSA32001",,aEmptyCpo[nY],5,5) // Este Parametro esta vazio ... E Obrigatorio preenche-lo para geracao da AWB
Next

If Len(aEmptyCpo) > 0
	Return ( .F. )
EndIf

If nOpcx == 3

	If !(DT7->(MsSeek(xFilial("DT7") + cCodDes)))
		Help("", 1, "TMSA32009") // Despesa AWB invalida.
		Return .F.
	EndIf

	If !(DUI->(MsSeek(xFilial("DUI") + cDocTMS )))
		Help("", 1, "TMSA32011",,cDocTMS+" - "+TMSValField("CDOCTMS",.F.),03,01) // Configuracao de Documento nao Encontrada para o Documento...
		Return .F.
	EndIf

	cProdCal := DUI->DUI_CODPRO

	If Empty( cProdCal )
		Help("", 1, "TMSA32012",,cDocTMS+" - "+TMSValField("CDOCTMS",.F.),02,14) // Produto nao Encontrado na Configuracao do Documento ...
		Return .F.
	EndIf

ElseIf nOpcx == 4 .And. DTV->(FieldPos('DTV_FATURA')) > 0 .And. !Empty(DTV->DTV_FATURA)
	MsgAlert(STR0034) //"AWB já está faturada. Não é possível realizar estorno."
	Return .F.

ElseIf nOpcx == 4 
		DbSelectArea("DY8")
		DbSetOrder(2) //DY8_FILIAL+DY8_NUMAWB+DY8_DIGAWB+DY8_CODCIA+DY8_LOJCIA+DY8_STATUS                                                                                               
 		If DY8->(MsSeek(xFilial('DY8')+DTV->DTV_NUMAWB+DTV->DTV_DIGAWB+DTV->DTV_CODCIA+DTV->DTV_LOJCIA+"1")) .Or. ;
 			DY8->(MsSeek(xFilial('DY8')+DTV->DTV_NUMAWB+DTV->DTV_DIGAWB+DTV->DTV_CODCIA+DTV->DTV_LOJCIA+"2"))
 			MsgAlert(STR0051,STR0038)//"Esta AWB já possui confirmação de embarque"###"Atenção"
 			Return .F.
 		EndIf
EndIf

//-- apresenta o botao que Indica o valor de devolucao na inclusao
If nOpcx == 3
	Aadd(aSetKey,  { VK_F5    , {|| TmsA500Dsc(6,@lPrimComp,M->DTV_CODCIA,M->DTV_LOJCIA,M->DTV_FILDES)} } )
	Aadd(aButtons,	{'BUDGET'  , {|| TmsA500Dsc(6,@lPrimComp,M->DTV_CODCIA,M->DTV_LOJCIA,M->DTV_FILDES)}, cOpcao + ' - <F5>' , Padr(cOpcao + ' - <F5>',21) + '.' })

	Aadd(aSetKey,  { VK_F6    , {|| TMSA320Vld('M->DTV_LOJCIA') } } )
	Aadd(aButtons,	{'PRECO'   , {|| TMSA320Vld('M->DTV_LOJCIA') } , STR0012 , STR0015 })  //'Atualiza a composicao - <F6>'###'Atualiza Compos.'
	Aadd(aSetKey , { VK_F7    , {|| TMSA320Cot() } } )
	Aadd(aButtons,	{'COMPTITL', {|| TMSA320Cot() } , STR0043 , STR0044 })//'Cotação de Frete - <F7>'###'Cotação' 
	If FindFunction('TMSChkVer') .And. TMSChkVer('11','R5')
		Aadd(aSetKey,  { VK_F10   , {|| TMSA940Voo() } } )
		Aadd(aButtons, {'NOTE'    , {|| TMSA940Voo() } , STR0045 , STR0046 } ) //"Exibe Grade Voo - <F10>"###"Exb.Grd.Voo"
	EndIf
EndIf

//--Nao apresenta o botao tabela de frete na inclusao
If nOpcx <> 3
	Aadd(aSetKey,  { VK_F6    , {|| TmsA320Tab() } } )
	AAdd(aButtons, {'BMPORD'  ,{|| TmsA320Tab() }, STR0016 , STR0022 }) //"Tabela de Frete - <F6>"###'Tabela de Frete'
	If FindFunction('TMSChkVer') .And. TMSChkVer('11','R5')
		Aadd(aSetKey,  { VK_F9    , {|| TmsViewPre() } } )
		Aadd(aButtons, {'AVIAO'   , {|| TmsViewPre() } , STR0047 , STR0048 }) //"Visul. Pre-Alerta - <F9>"###"Pre-Alerta"
		If DTV->(FieldPos('DTV_CODTRA')) > 0
			cObs := E_MsMM(DTV->DTV_CODTRA,80)
			Aadd(aSetKey, { VK_F11 , {|| TMSA940Obs(cObs,.F.) } } )
			Aadd(aButtons, {'bmpvisual', {|| TMSA940Obs(cObs,.F.)} , STR0049 , STR0050 } )//"Exibe Obs.Tmp.Translado - <F11>"###"Obs.Tmp.Trans."
		EndIf
	EndIf
EndIf

//-- Teclas de Atalhos
TmsKeyOn( aSetKey )

//-- Ponto de entrada para incluir botoes na enchoicebar
If	ExistBlock('TM320BUT')
	aSomaButtons:=ExecBlock('TM320BUT',.F.,.F.,{nOpcx})
	If	ValType(aSomaButtons) == 'A'
		For nCont:=1 To Len(aSomaButtons)
			AAdd(aButtons,aSomaButtons[nCont])
		Next
	EndIf
EndIf

aFldDTV := ApBuildHeader("DTV", If(nOpcx == 3, {"DTV_VALICM", "DTV_BASICM"}, {}))

For nY := 1 To Len(aFldDTV)
	cCampo := aFldDTV[nY][2]
	aAdd(aVisual, cCampo)
Next

RegToMemory("DTV", INCLUI)

//-- Preenche o vetor aFrete com a composicao do frete
If	nOpcx != 3
	TmsViewFrt('6',,DTV->DTV_NUMAWB,,,,,,,,,DTV->DTV_CODCIA,DTV->DTV_LOJCIA,TMSA320Dig(DTV->DTV_DATEMI,DTV->DTV_DIGAWB))
Else
	TmsViewFrt('8')

	If ValType(cFilOri) == 'C' .And. !Empty(cFilOri) .Or. !Empty(cViagem)
		M->DTV_FILORI := cFilOri
		M->DTV_VIAGEM := cViagem
	EndIf

EndIf

//-- Calcula as dimensoes dos objetos
aSize  := MsAdvSize( .T. )

AAdd( aObjects, { 100,50,.T.,.T. } )
AAdd( aObjects, { 100,50,.T.,.T. } )

aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
aPosObj:= MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL

	//-- Monta a Enchoice
	oEnch := MsMGet():New( cAlias, nReg, nOpcx, , , , aVisual, aPosObj[1], , 3, , , , , ,.T. )

	//-- Monta o Objeto Folder
	oFolder:=TFolder():New( aPosObj[2,1], aPosObj[2,2], aTitles, aPages, oDlg,,,,.T.,.T.,aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1])

	For nCntFor := 1 To Len( oFolder:aDialogs )
		oFolder:aDialogs[ nCntFor ]:oFont := oDlg:oFont
	Next

	//-- Folder Totalizador Composicao do Frete
	@ 0, 0 LISTBOX oLbx VAR cLbx FIELDS HEADER STR0018,STR0019,STR0020,STR0019 + ' + ' + STR0020 SIZE aPosObj[2,4]-aPosObj[2,2],aPosObj[2,3]-aPosObj[2,1]-15	OF oFolder:aDialogs[1] ON DBLCLICK ( .T. ) PIXEL //"Composicao" ### "Valor" ### "Imposto" ### "Valor + Imposto"

	//-- Apresenta a composicao do frete
	TmsViewFrt('9')

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(TM320TudOk(nOpcx) .And. Obrigatorio(aGets,aTela),(nOpca:= 1,oDlg:End()),.T.)},{||oDlg:End()},, aButtons )

If nOpcx != 2 .And. nOpca == 1

	Begin Transaction
		Processa({|| lRet := TMSA320Grava(nOpcx, cCodDes, cTesAWB)},cCadastro,Iif(nOpcx == 3, STR0007, STR0011)) //"Gerando AWB ..."###"Estornando AWB ..."
		If ( __lSX8 )
			ConfirmSX8()
		EndIf
	End Transaction
	If lRet .And. (nOpcx == 3)
		//-- Atualiza status financeiro da AWB
		TMSA320Fin()
	EndIf
Else
	If ( __lSX8 )
		RollBackSX8()
	EndIf
EndIf

MsUnlockAll()

aManifesto := {}
RestArea(aAreaAnt)

TmsKeyOff(aSetKey)

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA320Vld  ³ Autor ³ Patricia A. Salomao ³ Data ³12.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao dos Campos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320Mnt()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA320Vld(cCampo)

Local aAreaSA2 := SA2->(GetArea())
Local nAchou   := nTotPes:=nTotPesM3:=nTotVol:=0
Local nOpca    := 0
Local oItem, cOpc, cItem, oDlg
Local cCdrOri  := Space(Len(DUY->DUY_GRPVEN))
Local cTes     := ''
Local aRet     := {}
Local nSeek    := 0
Local aMsgErr  := {}
Local nA       := 0
Local cDesProd := ""
Local aContr   := {}
Local aTabs    := {}
Local nLoop    := 0
Local nX       := 0
Local cCodAer  := ""
Local cCodReg  := ""
Local cDesReg  := ""
Local cLockBy  := 'AWBNUMPRO'
Local nTent    := 0
Local cNumAWB  := ''
Local cAWBPRO  := GetMv("MV_AWBPRO",,"")

Default cCampo := AllTrim(ReadVar())

DTQ->(DbSetOrder(2))
If	DTQ->(MsSeek(xFilial('DTQ')+M->DTV_FILORI+M->DTV_VIAGEM))
	//-- Obtem a Regiao Origem / Ultimo Destino da Rota
	aRet := TMSRegDca(DTQ->DTQ_ROTA)
	If ! Empty(aRet)
		cCdrOri := aRet[1,1]
		If Empty(M->DTV_FILDES) .And. !Empty(ALLTRIM(M->DTV_CDRDES))
			M->DTV_FILDES := aRet[Len(aRet),3]
		EndIf
	EndIf
EndIf
aRet := {}

If cCampo $ 'M->DTV_BALCAO'
	If M->DTV_BALCAO == '1' //-- Sim
		While .T.
			nTent += 1
			If nTent > 20
				MsgAlert(STR0035)
				Exit
			EndIf
			If LockByName(cLockBy,.F.,.T.)
				cNumAWB := Soma1(cAWBPRO)
				DTV->(dbSetOrder(1))
				While DTV->(dbSeek(xFilial("DTV")+'P'+cNumAWB))
					cNumAWB := Soma1(cNumAWB)
				EndDo
				M->DTV_NUMAWB := 'P'+cNumAwb
				M->DTV_DIGAWB := CriaVar('DTV_DIGAWB',.F.)
				//-- Grava no SX6 o numero da ultima AWB provisoria
				PutMV("MV_AWBPRO",cNumAwb)
				UnLockByName(cLockBy,.F.,.T.)
				Exit
			EndIf
			Sleep(5000)
		EndDo
	Else
		M->DTV_NUMAWB := CriaVar('DTV_NUMAWB',.F.)
	EndIf

ElseIf cCampo == 'M->DTV_NUMAWB' .Or. cCampo == 'M->DTV_DIGAWB'

	If M->DTV_BALCAO <> '1' //Sim
		M->DTV_NUMAWB := StrZero(Val(M->DTV_NUMAWB),Len(DTV->DTV_NUMAWB))
	EndIf

	If lAWBRepete
		If !Empty(M->DTV_CODCIA) .And. !Empty(M->DTV_LOJCIA)
			If !ExistChav('DTV',M->DTV_NUMAWB+TMSA320Dig(M->DTV_DATEMI,M->DTV_DIGAWB)+M->DTV_CODCIA+M->DTV_LOJCIA,1)
				Return( .F. )
			EndIf
		EndIf
	Else
		If !ExistChav('DTV',M->DTV_NUMAWB,1)
			Return( .F. )
		EndIf
	EndIf

ElseIf cCampo == "M->DTV_CODCIA" .Or. cCampo == "M->DTV_LOJCIA"
	SA2->(DbSetOrder(1))
	If ! Empty(M->DTV_CODCIA + M->DTV_LOJCIA) .And. SA2->(MsSeek(xFilial("SA2")+M->DTV_CODCIA + M->DTV_LOJCIA) )

		If Empty(SA2->A2_TIPAWB)
			Help("",1,"TMSA32018",,M->DTV_CODCIA + " - " + M->DTV_LOJCIA,5,1) //"Tipo de AWB nao informado no cadastro de Fornecedores:"
			Return(.F.)
		EndIf

		If Empty(SA2->A2_COND)
			Help("",1,"TMSA32016") //"Condicao de Pagamento nao Informada no Cadastro do Fornecedor :"
			Return(.F.)
		EndIf

		If	! TmsChkTES('5',@cTes)
			Return(.F.)
		EndIf

		If lAWBRepete
			If !ExistChav('DTV',M->DTV_NUMAWB+TMSA320Dig(M->DTV_DATEMI,M->DTV_DIGAWB)+M->DTV_CODCIA+M->DTV_LOJCIA,1)
				Return( .F. )
			EndIf
		Else
			If !ExistChav('DTV',M->DTV_NUMAWB,1)
				Return( .F. )
			EndIf
		EndIf

		If !lExibeTab
			//-- Verifica se o Fornecedor tem contrato
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Estrutura do Array aContr :                              ³
			//³ aContr[n][1] - No. do Contrato                           ³
			//³ aContr[n][2] - Tabela de Frete                           ³
			//³ aContr[n][3] - Tipo da Tabela                            ³
			//³ aContr[n][4] - Tabela de Carreteiro                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aContr := TMSContrFor(SA2->A2_COD, SA2->A2_LOJA,, DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA,,,DTQ->DTQ_TPOPVG)

			If Empty(aContr)
				Return( .F. )
			ElseIf Len(aContr) == 1
				M->DTV_TABFRE := aContr[1,2]
				M->DTV_TIPTAB := aContr[1,3]
			ElseIf Len(aContr) > 1
				For nX :=1 To Len(aContr)
					AAdd(aTabs, { .F., aContr[nX][2], aContr[nX][3] } )
				Next nX
				If !Tm320Contr( @aTabs )
					Return ( .F. )
				EndIf
				nLoop := Ascan( aTabs, { |aItem| aItem[1] == .T. } )
				M->DTV_TABFRE := Left( aTabs[ nLoop ][2], 4 )
				M->DTV_TIPTAB := Left( aTabs[ nLoop ][3], 2 )
			EndIf

			//-- Calcula a composicao do frete, baseado na tabela de frete informada
			aFrete:= {}
			aFrete:= TmsCalFret(M->DTV_TABFRE	,;
								M->DTV_TIPTAB	,;
												,;
								cCdrOri			,;
								M->DTV_CDRDES	,;
								M->DTV_CODCIA	,;
								M->DTV_LOJCIA	,;
								M->DTV_CODPRO	,;
												,;
												,;
												,;
												,;
								@aMsgErr		,;
												,;
								M->DTV_VALMERC	,;
								Max(M->DTV_PESO,M->DTV_PESOM3),;
								0				,;
								0				,;
								M->DTV_QTDVOL	,;
												,,,,,,,,,,,,,,,,,,,;
								M->DTV_PESO		,;
								M->DTV_PESOM3	,;
												,;
								M->DTV_VALMER	,;
								M->DTV_QTDVOL	,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
								DTQ->DTQ_FILORI ,;
								DTQ->DTQ_VIAGEM)
			nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })

			If	Empty(nSeek) .Or. Empty(aFrete[nSeek, 2]) .Or. nSeek <> Len(aFrete)
				If Empty(nSeek) .Or. nSeek <> Len(aFrete)
					AAdd(aMsgErr,{STR0024,'00',''}) //"Falha na linha totalizadora da composicao do frete"
				ElseIf Empty(aFrete[nSeek, 2])
					AAdd(aMsgErr,{STR0025,'00',''}) //"Tabela de frete nao encontrada"
				EndIf
				If !Empty(aMsgErr)
					TmsMsgErr(aMsgErr)
				EndIf
				Return(.F.)
			EndIf

			TmsA040Imp( aFrete, M->DTV_CODCIA, M->DTV_LOJCIA, cDocTms, '1', M->DTV_CDRDES, .T., @nAlqICM, M->DTV_FILDES, SA2->A2_TIPO )

			//-- Atualiza o vetor de composicao de frete.
			If Type('oLbx') == 'O'
				//-- Apresenta a composicao do frete
				TmsViewFrt('9')
				oLbx:Refresh()
			EndIf
		EndIf

		lExibeTab := .F.
		RestArea(aAreaSA2)

	EndIf
ElseIf cCampo == "M->DTV_CDRDES"

	If cCdrOri == &(ReadVar())
		Help("",1,"TMSA32002") // Codigo da Regiao Destino Igual ao Codigo da Regiao Origem ...
		Return .F.
	EndIf

	DUY->(dbSetOrder(1))
	DUY->(MsSeek(xFilial("DUY")+M->DTV_CDRDES))
	M->DTV_FILDES := DUY->DUY_FILDES
	M->DTV_NOMDES := TmsA320NDes(M->DTV_FILDES)
	M->DTV_AERDES := Space(Len(DTV->DTV_AERDES))

	//-- Caso o usuario altere a regiao de destino e calcule a cotacao.
	lExibeTab := .F.
	aCompos   := {}


ElseIf cCampo == "M->DTV_VIAGEM"

	If !TMSChkViag( M->DTV_FILORI, M->DTV_VIAGEM, .F., .F., .F., , .F., .F., , , , , .F. )
		Return .F.
	EndIf

	If DTQ->DTQ_SERTMS == StrZero(1, Len(DTQ->DTQ_TIPTRA) )
		Help("",1,"TMSA32020") //"Nao e permitido gerar AWB para Viagens de Coleta"
		Return .F.
	EndIf

	If ! DTQ->DTQ_TIPTRA == StrZero(2, Len(DTQ->DTQ_TIPTRA) )
		Help("",1,"TMSA32003") // A Viagem Informada nao e area
		Return .F.
	EndIf

	//-- Retorna dados dos manifestos
	aRet := TMSA320Man()

	M->DTV_PESO   := aRet[1]
	M->DTV_PESOM3 := aRet[2]
	M->DTV_QTDVOL := aRet[3]
	M->DTV_VALMER := aRet[4]
	M->DTV_CDRDES := aRet[5]
	M->DTV_REGDES := Posicione('DUY',1,xFilial('DUY')+M->DTV_CDRDES,'DUY_DESCRI')
	M->DTV_FILDES := aRet[6]
	M->DTV_NOMDES := TmsA320NDes(M->DTV_FILDES)

	aCodPro := {}
	DUD->(dbSetOrder(2))
	DUD->(MsSeek(xFilial("DUD")+ M->DTV_FILORI + M->DTV_VIAGEM))
	Do While !DUD->(Eof()) .And. DUD->DUD_FILIAL+DUD->DUD_FILORI+DUD->DUD_VIAGEM == xFilial("DUD")+ M->DTV_FILORI + M->DTV_VIAGEM
		DTC->(dbSetOrder(3))
		DTC->(MsSeek(xFilial("DTC")+DUD->DUD_FILDOC+DUD->DUD_DOC+DUD->DUD_SERIE))
		nAchou := Ascan(aCodPro, { |x| x[3] == DTC->DTC_CODPRO } )
		If nAchou == 0
			SB1->(dbSetOrder(1))
			SB1->(MsSeek(xFilial("SB1")+ DTC->DTC_CODPRO) )
			AADD(aCodPro, {.F.,"1",DTC->DTC_CODPRO, SB1->B1_DESC} )
		EndIf
		DUD->(dbSkip())
	EndDo
	If Len(aCodPro) > 0
		If Len(aCodPro) == 1
			M->DTV_CODPRO := aCodPro[1, 3]
			M->DTV_DESPRO := AllTrim(aCodPro[1, 4])
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Le na resource os bitmaps utilizados no Listbox p/ sele‡ao  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oOk := If(oOk==NIL,LoadBitmap( GetResources(), "LBOK"),oOk)
			oNo := If(oNo==NIL,LoadBitmap( GetResources(), "LBNO"),oNo)
			oBr := If(oBr==NIL,LoadBitmap( GetResources(), "NADA"),oBr)

			DEFINE MSDIALOG oDlg TITLE STR0008 From 150,200 To 350,650 OF oMainWnd PIXEL //"Selecione o Produto"
				@ 05,10 LISTBOX oItem VAR cOpc Fields HEADER "",STR0009, STR0010  SIZE 170,90 ON DBLCLICK (aCodPro:=TrocaItCF(oItem:nAt,aCodPro,.T.),oItem:Refresh()) NOSCROLL OF oDlg PIXEL //"Produto"###"Descricao"
				oItem:SetArray(aCodPro)
				oItem:bLine := { || {If(aCodPro[oItem:nAt,2]=="0",oBr,IF(aCodPro[oItem:nAt,1],oOk,oNo)),aCodPro[oItem:nAt,3],aCodPro[oItem:nAt,4]}}
				DEFINE SBUTTON FROM 03,190 TYPE 1 ACTION (IF(ItTudOk(aCodPro,@cItem),(nOpca:=1,oDlg:End()),)) ENABLE OF oDlg
				DEFINE SBUTTON FROM 18,190 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg

			If nOpcA == 1
				For nA := 1 To Len(aCodPro)
					If aCodPro[nA, 1]
						cDesProd += Alltrim(aCodPro[nA, 4]) + "/"
					EndIf
				Next nA
				M->DTV_DESPRO := Iif(!Empty(cDesProd), cDesProd, Space(Len(DTV->DTV_DESPRO)))
			ElseIf nOpca == 0
				M->DTV_DESPRO := Space(Len(DTV->DTV_DESPRO))
			EndIf
		EndIf
	EndIf

ElseIf cCampo $ 'M->DTV_TABFRE.M->DTV_TIPTAB'

	SA2->(DbSetOrder(1))
	SA2->(MsSeek(xFilial('SA2')+M->DTV_CODCIA + M->DTV_LOJCIA))

	//-- Verifica se o Fornecedor tem contrato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aContr :                              ³
	//³ aContr[n][1] - No. do Contrato                           ³
	//³ aContr[n][2] - Tabela de Frete                           ³
	//³ aContr[n][3] - Tipo da Tabela                            ³
	//³ aContr[n][4] - Tabela de Carreteiro                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aContr := TMSContrFor(SA2->A2_COD, SA2->A2_LOJA,, DTQ->DTQ_SERTMS, DTQ->DTQ_TIPTRA,,, DTQ->DTQ_TPOPVG)

	If Ascan(aContr, {|x| x[2]+x[3] == M->DTV_TABFRE+M->DTV_TIPTAB } ) == 0
		Help('',1,'TMSA32019') // Tabela Invalida ...
		Return ( .F. )
	EndIf

	//-- Calcula a composicao do frete, baseado na tabela de frete informada
	aFrete:= {}
	aFrete:= TmsCalFret(M->DTV_TABFRE	,;
						M->DTV_TIPTAB	,;
										,;
						cCdrOri			,;
						M->DTV_CDRDES	,;
						M->DTV_CODCIA	,;
						M->DTV_LOJCIA	,;
						M->DTV_CODPRO	,;
										,;
										,;
										,;
										,;
						@aMsgErr		,;
										,;
						M->DTV_VALMERC	,;
						Max(M->DTV_PESO,M->DTV_PESOM3),;
						0				,;
						0				,;
						M->DTV_QTDVOL	,;
										,,,,,,,,,,,,,,,,,,,;
						M->DTV_PESO		,;
						M->DTV_PESOM3	,;
										,;
						M->DTV_VALMER	,;
						M->DTV_QTDVOL	,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
						DTQ->DTQ_FILORI ,;
						DTQ->DTQ_VIAGEM)
	nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })

	If	Empty(nSeek) .Or. Empty(aFrete[ nSeek, 2 ]) .Or. nSeek <> Len(aFrete)
		If Empty(nSeek) .Or. nSeek <> Len(aFrete)
			AAdd(aMsgErr,{ STR0024 ,'00',''}) //"Falha na linha totalizadora da composicao do frete"
		EndIf
		If	!Empty(aMsgErr)
			TmsMsgErr(aMsgErr)
		EndIf
		Return(.F.)
	EndIf

	TmsA040Imp( aFrete, M->DTV_CODCIA, M->DTV_LOJCIA, cDocTms, '1', M->DTV_CDRDES, .T., @nAlqICM, M->DTV_FILDES, SA2->A2_TIPO )

	//-- Atualiza o vetor de composicao de frete.
	If Type('oLbx') == 'O'
		//-- Apresenta a composicao do frete
		TmsViewFrt('9')
		oLbx:Refresh()
	EndIf

ElseIf cCampo $ 'M->DTV_AERORI;M->DTV_AERDES'
	If M->DTV_AERORI == M->DTV_AERDES
		Return(.F.)
	EndIf
	If cCampo  $ 'M->DTV_AERORI'
		cCodAer := M->DTV_AERORI
		cCodReg := Padr(GetMv('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN))
		cDesReg := 'origem'
	Else
		cCodAer := M->DTV_AERDES
		cCodReg := M->DTV_CDRDES
		cDesReg := 'destino'
	EndIf
	If !TmsA320DD7(.T.)
		Return(.F.)
	EndIf

ElseIf cCampo $ 'M->DTV_QTDVOL;M->DTV_PESO;M->DTV_PESOM3;M->DTV_VALMER'
	//-- Caso o usuario altere a regiao de destino e calcule a cotacao.
	lExibeTab := .F.
	aCompos   := {}
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TM320TudOk  ³ Autor ³ Patricia A. Salomao ³ Data ³12.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao Geral                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TM320TudOk()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TM320TudOk(nOpcx)

Local lRet := .T.
Local dDatFTMS := GetMv("MV_DATATMS",.F.,CtoD(''))
Local aManife  := aClone(aManifesto)

If M->DTV_RETAER == StrZero(2,Len(DTV->DTV_RETAER))  .And. Empty(M->DTV_LOCENT)
	Help("",1, "TMSA32005") // Informe o Local de Entrega ...
	lRet := .F.
EndIf

If nOpcx == 3
	If lAWBRepete
		lRet := ExistChav('DTV',M->DTV_NUMAWB+TMSA320Dig(M->DTV_DATEMI,M->DTV_DIGAWB)+M->DTV_CODCIA+M->DTV_LOJCIA,1)
	Else
		lRet := ExistChav('DTV',M->DTV_NUMAWB,1)
	EndIf
EndIf

If lRet .And. !Empty(dDatFTMS)
	If dDataBase <= dDatFTMS
		Help ( " ", 1, "FECHATMS" )
		lRet := .F.
	EndIf
EndIf
If lRet .And. !Empty(GetMV("MV_DATAFIS",,""))
	If !FisChkDt(dDataBase)
		Return( .F. )
	EndIf
EndIf
If lRet .And. ExistBlock('TM320TOK')
	lRet := ExecBlock('TM320TOK',.F.,.F.,{ nOpcx,aManife })
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA320Grava³ Autor ³ Patricia A. Salomao ³ Data ³15.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava Dados                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320Grava()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Opcao Selecionada                                  ³±±
±±³          ³ ExpC1 - Codigo da Despesa AWB                              ³±±
±±³          ³ ExpC2 - Codigo da TES da  AWB                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±/*/
Function TMSA320Grava(nOpcx, cCodDes, cTesAWB)

Local aDocto     := {}
Local aFrtAnt    := AClone(aFrete)
Local aFrtAux    := {}
Local nCntFor    := 0
Local nSeek      := 0
Local cSeek      := ''
Local cCondPag	 := ''
Local cEstado    := ''
Local cPrefixo   := Left(M->DTV_NUMAWB, 3) // Prefixo AWB
Local cNumTit    := Right(M->DTV_NUMAWB, 6)// Numero do Titulo.
Local cDocDes    := ''                      // Documento de Despesa.
Local lRet       := .T.
Local lTM320Nfe  := ExistBlock('TM320NFE')
Local aDoc       := {}
Local cAliasNew  := GetNextAlias()
Local lGrvNfe    := .T.
Local cDigito    := ''

Default cTesAWB:= ''

//-- Fornecedor
SA2->(dbSeek(xFilial('SA2')+M->DTV_CODCIA+M->DTV_LOJCIA))
cCondPag  := SA2->A2_COND
cEstado   := SA2->A2_EST

// Se for Exclusao
If nOpcx == 4

	DTQ->(dbSetOrder(2))
	If DTQ->( MsSeek( xFilial("DTQ") + M->DTV_FILORI + M->DTV_VIAGEM ) ) .And. DTQ->DTQ_STATUS == Strzero( 3, Len( DTQ->DTQ_STATUS ) )
		Help("", 1, "TMSA32010") // Viagem ja foi Encerrada !!!
		lRet := .F.
	EndIf

	If lRet
		aDoc   := TMSA320Awb( M->DTV_NUMAWB, M->DTV_DIGAWB, .T., M->DTV_CODCIA, M->DTV_LOJCIA, M->DTV_DATEMI )
		aDocto := {}
		AAdd(aDocto,Posicione('DUI',1,xFilial('DUI')+'3','DUI_CODPRO'))	//-- 1 Produto
		AAdd(aDocto,aDoc[1])												//-- 2 Docto
		AAdd(aDocto,aDoc[2])												//-- 3 Serie
		AAdd(aDocto,M->DTV_CODCIA)											//-- 4 Cliente/Fornecedor
		AAdd(aDocto,M->DTV_LOJCIA)											//-- 5 Loja do Cliente/Fornecedor
		AAdd(aDocto,0)														//-- 6 Volume
		AAdd(aDocto,0)														//-- 7 Valor da mercadoria
		AAdd(aDocto,'')														//-- 8 Condicao de pagamento
		AAdd(aDocto,'')														//-- 9 Especie
		AAdd(aDocto,0)														//--10 Aliquota ICM
		AAdd(aDocto,'N')													//--11 Tipo da nota
		AAdd(aDocto, cTesAWB)												//--12 TES da AWB
		AAdd(aDocto, cEstado)												//--13 Estado Fornecedor

		//-- Estornar documento de entrada
		If !TmsA320NFE(aDocto,5)
			lRet := .F.
		EndIf

		If lRet
			//-- Atualizar Manifesto
			cQuery := " SELECT R_E_C_N_O_ AS RECDTX "
			cQuery += "   FROM " + RetSQLName("DTX")
			cQuery += "   WHERE DTX_FILIAL = '" + xFilial("DTX") + "' "
			cQuery += "     AND DTX_FILORI = '" + M->DTV_FILORI  + "' "
			cQuery += "     AND DTX_VIAGEM = '" + M->DTV_VIAGEM  + "' "
			cQuery += "     AND DTX_NUMAWB = '" + M->DTV_NUMAWB  + "' "
			If lAWBRepete
				cQuery += "   AND DTX_CODCIA = '" + M->DTV_CODCIA  + "' AND DTX_LOJCIA ='" + M->DTV_LOJCIA +"' "

				cDigito := TMSA320Dig(M->DTV_DATEMI,M->DTV_DIGAWB)
				If lDTX_DIGAWB .And. Len(cDigito) > 0
					cQuery += "   AND DTX_DIGAWB = '" + cDigito + "' "
				EndIf
			Endif
			cQuery += "     AND D_E_L_E_T_ = ' ' "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )	
			While (cAliasNew)->(!Eof())
				DTX->(DbGoto((cAliasNew)->RECDTX))
				If lAWBRepete
					RecLock("DTX",.F.)
					DTX->DTX_NUMAWB := ""
					DTX->DTX_CODCIA := ""
					DTX->DTX_LOJCIA := ""
					If lDTX_DIGAWB
						DTX->DTX_DIGAWB := ""
					EndIf
					MsUnLock()
				Else
					RecLock("DTX",.F.)
					DTX->DTX_NUMAWB := ""
					MsUnLock()
				Endif
				(cAliasNew)->(dbSkip())
			Enddo
			(cAliasNew)->(dbClosearea())

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Estorna o Movim. de Custo de Transporte                                 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SDG->(dbSetOrder(1))
			SDG->(MsSeek(xFilial("SDG")+DTV->DTV_DOCDES))
			Do While !SDG->(Eof()) .And. SDG->(DG_FILIAL+DG_DOC) == xFilial("SDG")+ DTV->DTV_DOCDES
				If SDG->DG_ORIGEM <> "DTV" .Or. (SDG->DG_FILORI <> M->DTV_FILORI .And. SDG->DG_VIAGEM <> M->DTV_VIAGEM)
					SDG->(dbSkip())
					Loop
				EndIf
				
				AtuTabSDG(,5)
				SDG->(dbSkip())
			EndDo

			//-- Deletar AWB
			DTV->(dbSetOrder(1))
			DTV->(MsSeek(xFilial("DTV")+ M->DTV_NUMAWB) )
			Do While DTV->(!Eof()) .And. DTV->DTV_FILIAL+DTV->DTV_NUMAWB == xFilial("DTV") + M->DTV_NUMAWB
				If DTV->DTV_FILORI == M->DTV_FILORI .And. DTV->DTV_VIAGEM == M->DTV_VIAGEM 
					If lAWBRepete 
						If DTV->DTV_CODCIA == M->DTV_CODCIA .And. DTV->DTV_LOJCIA == M->DTV_LOJCIA .And. If(Len(cDigito)>0,(DTV->DTV_DIGAWB==cDigito),.T.)
							RecLock("DTV",.F.)
							dbDelete()
							MsUnLock()
						EndIf
					Else
						RecLock("DTV",.F.)
						dbDelete()
						MsUnLock()
					EndIf
				EndIf
				DTV->(dbSkip())
			EndDo

			MSMM(DTV->DTV_CODOBS,,,,2)

			//-- Exclui a composicao do frete
			DT8->(DbSetOrder( 3 ))
			DT8->( MsSeek( xFilial('DT8') + M->DTV_NUMAWB ) )  
			While DT8->(!Eof()) .And. DT8->(DT8_FILIAL+DT8_NUMAWB) == xFilial("DT8") + M->DTV_NUMAWB
				If lAWBRepete
					If DT8->DT8_CODCIA == M->DTV_CODCIA .And. DT8->DT8_LOJCIA == M->DTV_LOJCIA .And. If(lDT8_DIGAWB .And. Len(cDigito)>0,(DT8->DT8_DIGAWB==cDigito),.T.)
						RecLock('DT8',.F.,.T.)
						DT8->( DbDelete() )
						MsUnLock()
					EndIf
				Else
					RecLock('DT8',.F.,.T.)
					DT8->( DbDelete() )
					MsUnLock()
				EndIf
				DT8->(dbSkip())
			EndDo
		EndIf
	EndIf

Else

	//-- Gera NFE - AWB
	nSeek := AScan(aFrete,{|x| x[3]=='TF' })
	If nSeek > 0 .And. aFrete[ nSeek, 2 ] > 0
		If lTM320Nfe
			lGrvNfe := ExecBlock('TM320NFE',.F.,.F.)
		EndIf
		If lGrvNfe
			aDoc   := TMSA320Awb( M->DTV_NUMAWB, M->DTV_DIGAWB,, M->DTV_CODCIA, M->DTV_LOJCIA, M->DTV_DATEMI )
			aDocto := {}
			AAdd(aDocto,Posicione('DUI',1,xFilial('DUI')+'3','DUI_CODPRO'))	//-- 1 Produto
			AAdd(aDocto,aDoc[1])												//-- 2 Docto
			AAdd(aDocto,aDoc[2])												//-- 3 Serie
			AAdd(aDocto,M->DTV_CODCIA)											//-- 4 Cliente/Fornecedor
			AAdd(aDocto,M->DTV_LOJCIA)											//-- 5 Loja do Cliente/Fornecedor
			AAdd(aDocto,M->DTV_QTDVOL)											//-- 6 Volume
			AAdd(aDocto,aFrete[ nSeek, 2 ] )									//-- 7 Valor do Frete
			AAdd(aDocto,cCondPag)												//-- 8 Condicao de pagamento
			AAdd(aDocto,'CA')													//-- 9 Especie
			AAdd(aDocto,nAlqICM)												//--10 Aliquota ICM 
			AAdd(aDocto,'N')													//--11 Tipo da nota
			AAdd(aDocto, cTesAWB)												//--12 TES da AWB
			AAdd(aDocto, cEstado)												//--13 Estado

			//-- Gera documento de entrada
			If M->DTV_BALCAO == '1'
				lGrvNfe := .F.
			EndIf

			If lGrvNfe
				If !TmsA320NFE(aDocto,nOpcx)
					Return(.F.)
				EndIf
				// Gera Movimento de custo de transporte.
				nSeek := AScan(aFrete,{|x| x[3]=='TF' })
				M->DTV_DOCDES := TMA250GrvSDG("DTV" , M->DTV_FILORI, M->DTV_VIAGEM, cCodDes, aFrete[ nSeek, 6 ], 1,,,,,,,,,,,,,,,,"TMSA320","2" )
			EndIf
		EndIf

		M->DTV_USER	:= RetCodUsr()

		//-- Grava AWB
		dbSelectArea("DTV")
		RecLock("DTV",.T.)
		For nCntFor := 1 TO FCount()
			If "FILIAL"$Field(nCntFor)
				FieldPut(nCntFor,xFilial())
			Else
				If Type("M->"+FieldName(nCntFor)) <> "U"
					FieldPut(nCntFor,M->&(FieldName(nCntFor)))
				EndIf
			EndIf
		Next

		MSMM(DTV->DTV_CODOBS,,,M->DTV_OBS,1,,,"DTV","DTV_CODOBS")
		MsUnLock()

		//-- Monto a estrutura do vetor afrete para atender a gravacao da composicao
		aFrtAux := {}
		AAdd(aFrtAux,{Space(Len(DT8->DT8_CODPRO)),aFrete})
		aFrete := {}
		aFrete := AClone(aFrtAux)
		cDigito := TMSA320Dig(M->DTV_DATEMI,M->DTV_DIGAWB)

		//-- Grava composicao do frete
		TmsGrvDT8( 'TMSA320', M->DTV_FILORI, M->DTV_NUMAWB ,,,,,,,, M->DTV_CODCIA , M->DTV_LOJCIA , cDigito )
		//-- Restauro a estrutura do vetor afrete
		aFrete := AClone(aFrtAnt)

		//-- Atualiza Manifesto
		ASort( aManifesto,,,{|x,y| x[1] > y[1] })
		For nCntFor := 1 To Len(aManifesto)
			//-- Somente manifestos marcados
			If !aManifesto[nCntFor,1]
				Exit
			EndIf
			DTX->(DbGoto(aManifesto[nCntFor,13])) //-- Recno do DTX
			RecLock("DTX",.F.)
			DTX_NUMAWB := M->DTV_NUMAWB
			If lAWBRepete
				DTX_CODCIA := M->DTV_CODCIA
				DTX_LOJCIA := M->DTV_LOJCIA
				If lDTX_DIGAWB 
					DTX_DIGAWB := M->DTV_DIGAWB
				EndIf
			EndIf
			MsUnLock()
		Next nCntFor

	EndIf

EndIf

If FindFunction('TMSChkVer') .And. TMSChkVer('11','R5')
	If (DTV->DTV_BALCAO == '2') .Or. (DTV->DTV_BALCAO == '1' .And. !Empty(DTV->DTV_NUMORI))
		//-- 0=Utilizado ; 1=Desprezado
		If DTV->DTV_TMPTRA == '1'
			If nOpcx == 3
				If Type('_cObsTrans') <> 'U' .And. !Empty(_cObsTrans)
					MSMM(DTV->DTV_CODTRA,,,_cObsTrans,1,,,"DTV","DTV_CODTRA")
				EndIf
			ElseIf nOpcx == 4
				MSMM(DTV->DTV_CODTRA,,,,2)
			EndIf
		EndIf
	EndIf
EndIf
If lTm320grv .and. lRet
	ExecBlock('TM320GRV',.F.,.F., nOpcx )
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA320Whe  ³ Autor ³ Patricia A. Salomao ³ Data ³15.03.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao do Campo DTV_LOCENT (X3_WHEN)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320Whe()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Logico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Function TMSA320Whe(cCampo)

Local   lRet   := .T.
Default cCampo := AllTrim(ReadVar())

If cCampo $ 'M->DTV_NUMAWB;M->DTV_DIGAWB'
	lRet := (M->DTV_BALCAO == '2')
ElseIf cCampo $ 'M->DTV_LOCENT'
	lRet := (M->DTV_RETAER == '2')
EndIf
Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA320NFE³ Autor ³ Alex Egydio           ³ Data ³17.06.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera documento de entrada                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320NFE(aDocto,nOpcx)

Local aAreaAnt  := GetArea()
Local aAreaDTC  := DTC->(GetArea())
Local aCab      := {}
Local aItSD1    := {}
Local aLinSD1   := {}
Local cArmazem  := ''
Local cCodPro   := ''
Local cDocto    := ''
Local cSerie    := ''
Local cCliFor   := ''
Local cLoja     := ''
Local cCondPag  := ''
Local cEspecie  := ''
Local cTipoNf   := ''
Local nQtdVol   := 0
Local nPIcm     := 0
Local cTesAWB   := ''
Local cFormul   := ''
Local cEstado   := ''
Local lRet      := .T.
Local cFilSF1   := ''

Local aAreaSBZ

Private lMsErroAuto  := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Funcao utilizada para verificar a ultima versao dos fontes      ³
//³ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF !(FindFunction("SIGACUS_V") .and. SIGACUS_V() >= 20050512)
    Final(STR0029) //"Atualizar SIGACUS.PRW !!!"
Endif
IF !(FindFunction("SIGACUSA_V") .and. SIGACUSA_V() >= 20050512)
    Final(STR0030) //"Atualizar SIGACUSA.PRX !!!"
Endif
IF !(FindFunction("SIGACUSB_V") .and. SIGACUSB_V() >= 20050512)
    Final(STR0031) //"Atualizar SIGACUSB.PRX !!!"
Endif

//-- Formato do vetor aDocto
//-- aDocto[1] Produto
//-- aDocto[2] Docto
//-- aDocto[3] Serie
//-- aDocto[4] Cliente/Fornecedor
//-- aDocto[5] Loja
//-- aDocto[6] Volume
//-- aDocto[7] Valor do Frete
//-- aDocto[8] Condicao de pagamento
//-- aDocto[9] Especie
//-- aDocto[10] Aliquota ICM
//-- aDocto[11] Tipo da nota
//-- aDocto[12] TES da AWB
//-- aDocto[13] Estado
cCodPro   := aDocto[1]
cDocto    := aDocto[2]
cSerie    := aDocto[3]
cCliFor   := aDocto[4]
cLoja     := aDocto[5]
nQtdVol   := aDocto[6]
nValFre   := aDocto[7]
cCondPag  := aDocto[8]
cEspecie  := aDocto[9]
nPIcm     := aDocto[10]
cTipoNf   := aDocto[11]
cTesAWB   := aDocto[12]
cEstado   := aDocto[13]
cFormul   := 'N'

If RetArqProd(cCodPro)
	cArmazem := Posicione('SB1',1,xFilial('SB1')+cCodPro,'B1_LOCPAD')
Else
	aAreaSBZ := GetArea()
	cArmazem := Posicione('SBZ',1,xFilial('SBZ')+cCodPro,'BZ_LOCPAD')
	RestArea(aAreaSBZ)
Endif

SF4->( DbSetOrder( 1 ) )
If	SF4->( ! MsSeek( xFilial('SF4') + cTesAWB ) )
	Help("", 1, "TMSA32021") //"TES informado no parametro MV_TESAWB nao cadastrado !!!"
	Return(.F.)
EndIf

//-- Cabecalho da nota fiscal de entrada
aCab := {}
Aadd( aCab, { 'F1_DOC'		, cDocto	, Nil } )	// Documento				( Obrigatorio )
Aadd( aCab, { 'F1_SERIE'	, cSerie	, Nil } )	// Serie da NF				( Obrigatorio )
Aadd( aCab, { 'F1_TIPO'		, cTipoNf	, Nil } )	// Tipo da NF				( Obrigatorio )
Aadd( aCab, { 'F1_FORNECE'	, cCliFor	, Nil } )	// Cliente/Fornecedor		( Obrigatorio )
Aadd( aCab, { 'F1_LOJA'		, cLoja 	, Nil } )	// Loja						( Obrigatorio )
Aadd( aCab, { 'F1_EMISSAO'	, dDataBase	, Nil } )	// Emissao da NF			( Obrigatorio )
Aadd( aCab, { 'F1_FORMUL'	, cFormul	, Nil } )	// Formulario
Aadd( aCab, { 'F1_ESPECIE'	, cEspecie	, Nil } )	// Especie
Aadd( aCab, { 'F1_COND'		, cCondPag	, Nil } )	// Condicao de pagamento
Aadd( aCab, { 'F1_EST'		, cEstado	, Nil } )	// Estado

//-- Itens da nota fiscal de entrada
aLinSD1	:= {}
aItSD1	:= {}

Aadd( aLinSD1, { 'D1_COD'  , cCodPro							, Nil } )	// Codigo do produto
Aadd( aLinSD1, { 'D1_ITEM' , StrZero( 1, Len( SD1->D1_ITEM ) )	, Nil } )	// Item da nota fiscal
Aadd( aLinSD1, { 'D1_QUANT', 1									, Nil } )	// Quantidade do produto
Aadd( aLinSD1, { 'D1_VUNIT', nValFre							, Nil } )	// Valor unitario
Aadd( aLinSD1, { 'D1_TOTAL', nValFre							, Nil } )	// Valor total
Aadd( aLinSD1, { 'D1_TES'  , SF4->F4_CODIGO						, Nil } )	// Tipo de entrada da nota
Aadd( aLinSD1, { 'D1_LOCAL', cArmazem							, Nil } )	// Codigo do armazem
Aadd( aLinSD1, { 'D1_PICM' , nPIcm								, Nil } )	// Aliquota ICM

Aadd( aItSD1, Aclone(aLinSD1) )

//-- Esta funcao funciona para inclusao ou estorno de notas fiscais

If	nOpcx == 3
	//-- Gera nota fiscal de entrada
	MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItSD1,nOpcx)
Else
	cFilSF1 := xFilial('SF1')
	SF1->(DbSetOrder( 1 ))
	If SF1->(MsSeek(cFilSF1 + cDocto + cSerie + cCliFor + cLoja + cTipoNf))
		//-- Estorna nota fiscal de entrada
		MSExecAuto({|x,y,z| MATA103(x,y,z)},aCab,aItSD1,nOpcx)
	EndIf
EndIf

//-- Se houve problemas na entrada de notas fiscais, apresenta o motivo do erro e sai do laco no arquivo DTC
If lMsErroAuto
	MostraErro()
	lRet := .F.
Else
	SF1->(DbSetOrder( 1 ))
	cFilSF1 := xFilial('SF1')
	If nOpcx == 3
		//-- Verifica de realmente a Nota Foi incluida.
		If !SF1->(MsSeek(cFilSF1 + cDocto + cSerie + cCliFor + cLoja + cTipoNf))
			MsgAlert(STR0041) //"Falha ao Incluir Documento Fiscal"
			lRet := .F.
		EndIf
	Else
		//-- Verifica se realmente excluiu a nota.
		If SF1->(MsSeek(cFilSF1 + cDocto + cSerie + cCliFor + cLoja + cTipoNf))
			MsgAlert(STR0042) //"Falha ao Excluir Documento Fiscal"
			lRet := .F.
		EndIf
	EndIf
EndIF

If !lRet
	DisarmTransaction()
EndIf

RestArea(aAreaDTC)
RestArea(aAreaAnt)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA320Tab ³ Autor ³ Eduardo de Souza     ³ Data ³ 20/04/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza a tabela de frete do documento                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA320Tab()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA320Tab()
Local cDigito := TMSA320Dig(DTV->DTV_DATEMI,DTV->DTV_DIGAWB)

//-- Zera Teclas de Atalhos
TmsKeyOff(aSetKey)

TmsVisTabel(,DTV->DTV_NUMAWB,,'3',,DTV->DTV_CODCIA,DTV->DTV_LOJCIA,cDigito)

//-- Retorna Teclas de Atalhos
TmsKeyOn(aSetKey)

Return Nil
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA320Cot ³ Autor ³ Richard Anderson     ³ Data ³ 25/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Cotação de Frete a Pagar                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA320Cot()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA320Cot()

Local aAreaAtu := GetArea()
Local nOpca    := 0
Local nAT      := 0
Local cTes     := ''

//-- Controle de dimensoes de objetos
Local aObjects := {}
Local aInfo    := {}
Local aPosObj  := {}
Local aSize    := {}

//-- MsDialog
Local oDlgEsp

//-- ListBox
Local cLbx     := ''

Local aCpoVld    := {}
Local nI         := 0
Local aSetKeyOld := {}
Local aButtons   := {}
Local cDigito    := ''

Private oLbxComp
Private aVisErr  := {}

Aadd(aCpoVld, { M->DTV_NUMAWB, RetTitle('DTV_NUMAWB') })
Aadd(aCpoVld, { M->DTV_VIAGEM, RetTitle('DTV_VIAGEM') })
Aadd(aCpoVld, { M->DTV_CDRDES, RetTitle('DTV_CDRDES') })

For nI := 1 To Len(aCpoVld)
	If Empty(aCpoVld[nI,1])
		MsgAlert('Informe '+AllTrim(aCpoVld[nI,2]),STR0038) //"ATENÇÃO"
		Return Nil
	EndIf
Next nI

//-- Inicializa Teclas de Atalhos
aSetKeyOld := aClone(aSetKey)
TmsKeyOff(aSetKey)

aSetKey := {}
aButtons:= {}

Aadd( aSetKey,  { VK_F7  , { || IIf(MsgYesNo("Deseja efetuar o recalculo das cotações?"), Processa({|| CursorWait(), TmsA320Rec(.T.), CursorArrow() },"Realizando recalculo das cotações","Processando...",.F.) ,Nil) } } )
Aadd( aButtons, { "PRECO", { || IIf(MsgYesNo("Deseja efetuar o recalculo das cotações?"), Processa({|| CursorWait(), TmsA320Rec(.T.), CursorArrow() },"Realizando recalculo das cotações","Processando...",.F.) ,Nil) } , "Recalcula cotação de Frete - <F7>" , "Rec.Cotac." } )

TmsKeyOn(aSetKey)

// funcao para calcular as cotacoes
If Len(aCompos) == 0
	//MsgRun( "Realizando calculo das cotações" , "Aguarde..." , {|| CursorWait(), aCompos := TmsA320Rec(), CursorArrow()})
	Processa({|| CursorWait(), aCompos := TmsA320Rec(), CursorArrow() },"Realizando calculo das cotações","Processando...",.F.)
EndIf

lExibeTab := .F.

If Len(aCompos) > 0	
	//-- Calcula as dimensoes dos objetos
	aSize  := MsAdvSize( .T. )

	AAdd( aObjects, { 100, 60,.T.,.T. } )

	aInfo  := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
	aPosObj:= MsObjSize( aInfo, aObjects,.T. )
	DEFINE MSDIALOG oDlgEsp TITLE 'Cotação de Frete a Pagar' FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //"Composicao do frete"

			@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbxComp VAR cLbx FIELDS HEADER Posicione('SX3', 2, 'DTV_CODCIA', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DTV_LOJCIA', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DTV_NOMCIA', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DTV_TABFRE', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DTV_TIPTAB', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DT0_DESTIP', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DT6_VALFRE', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DT6_VALIMP', 'X3Titulo()'),;
			                                                                      Posicione('SX3', 2, 'DT6_VALTOT', 'X3Titulo()') ;
			                                                                      SIZE aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlgEsp ON DBLCLICK (.T.) PIXEL 

			oLbxComp:SetArray( aCompos )

			oLbxComp:bLine := {|| {	aCompos[ oLbxComp:nAT, 1 ],;
									aCompos[ oLbxComp:nAT, 2 ],;
									aCompos[ oLbxComp:nAT, 3 ],;
									aCompos[ oLbxComp:nAT, 4 ],;
									aCompos[ oLbxComp:nAT, 5 ],;
									aCompos[ oLbxComp:nAT, 6 ],;
									TransForm( aCompos[ oLbxComp:nAT, 7 ], PesqPict('DT8','DT8_VALPAS') ),;
									TransForm( aCompos[ oLbxComp:nAT, 8 ], PesqPict('DT8','DT8_VALIMP') ),;
									TransForm( aCompos[ oLbxComp:nAT, 9 ], PesqPict('DT8','DT8_VALTOT') ) } }


	ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{||(nOpca := 1,nAT := oLbxComp:nAT,oDlgEsp:End())},{||oDlgEsp:End()},,aButtons)

	If nOpca == 1 .And. TmsChkTES('5',@cTes)
		//-- Verifica se ja existe AWB para o fornecedor
		cDigito := TMSA320Dig(M->DTV_DATEMI,M->DTV_DIGAWB)
		DTV->(dbSetOrder(1))
		If DTV->(MsSeek(xFilial("DTV") + M->DTV_NUMAWB)) .And. DTV->DTV_CODCIA + DTV->DTV_LOJCIA == aCompos[nAT,1] + aCompos[nAT,2] .And. If(Len(cDigito)>0,(DTV->DTV_DIGAWB==cDigito),.T.) 
			Help("",1,"TMSA32013",,aCompos[nAT,1] + " - " + aCompos[nAT,2], 5, 1) // AWB ja cadastrado para esse fornecedor.
		ElseIf Empty(aCompos[nAT,10])
			Help("",1,"TMSA32016") //Condicao de Pagamento nao Informada no Cadastro do Fornecedor :
		Else

			M->DTV_CODCIA := aCompos[nAT,01]
			M->DTV_LOJCIA := aCompos[nAT,02]
			M->DTV_NOMCIA := aCompos[nAT,03]
			M->DTV_TABFRE := aCompos[nAT,04]
			M->DTV_TIPTAB := aCompos[nAT,05]
			aFrete        := aCompos[nAT,10]
			lExibeTab     := .T.

			//-- Atualiza o vetor de composicao de frete.
			If Type('oLbx') == 'O'
				//-- Apresenta a composicao do frete
				TmsViewFrt('9')
				oLbx:Refresh()
			EndIf
		EndIf
	EndIf
Else
	If Empty( aVisErr )
		Help('',1,'REGNOIS')
	Else
		TmsMsgErr( aVisErr )
	EndIf
EndIf

TmsKeyOff(aSetKey)
aSetKey := aClone(aSetKeyOld)
TmsKeyOn(aSetKey)
RestArea(aAreaAtu)

Return Nil



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA320Rec ³ Autor ³ Jose Luiz P. Jr.     ³ Data ³ 22/04/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Funcao utilizado para fazer calculo das cotacoes.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA320Des()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA320Rec(lRecalculo)
Local cQuery    := ""
Local aAreaAtu  := GetArea()
Local cAliasQry := GetNextAlias()
Local cCdrOri   := Padr(SuperGetMv('MV_CDRORI',,''),Len(DUY->DUY_GRPVEN))
Local aMsgErr   := {}
Local aVisErr   := {}
Local aFrtAWB   := {}
Local nI        := 0
Local nSeek     := 0
Local nTotReg   := 0
Local aRet      := {}
Local aContr    := {}

Default lRecalculo := .F.

cQuery := "SELECT A2_COD, A2_LOJA, A2_TIPO, A2_NREDUZ, A2_COND FROM "
cQuery += RetSqlName("SA2")+" SA2 "
cQuery += " WHERE A2_FILIAL  = '"+xFilial("SA2")+"'" 
cQuery += "   AND A2_TIPAWB <> ' '"
cQuery += "   AND D_E_L_E_T_ = ' '"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

If lRecalculo
	aCompos := {}
	oLbxComp:SetArray( aCompos )
	oLbxComp:Refresh()
EndIf

While (cAliasQry)->(!Eof())
	nTotReg++
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbGoTop())

ProcRegua(nTotReg,16,4)

While (cAliasQry)->(!Eof())

	IncProc()

	//-- Verifica se o Fornecedor tem contrato
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Estrutura do Array aContr :                              ³
	//³ aContr[n][1] - No. do Contrato                           ³
	//³ aContr[n][2] - Tabela de Frete                           ³
	//³ aContr[n][3] - Tipo da Tabela                            ³
	//³ aContr[n][4] - Tabela de Carreteiro                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aContr := TMSContrFor((cAliasQry)->A2_COD,(cAliasQry)->A2_LOJA,,DTQ->DTQ_SERTMS,DTQ->DTQ_TIPTRA,.F.)
	If !Empty(aContr)
		For nI := 1 To Len(aContr)
			//-- Calcula a composicao do frete, baseado na tabela de frete informada
			aMsgErr:= {}
			aFrtAWB:= {}
			aFrtAWB:= TmsCalFret(	aContr[nI,2]	,;
									aContr[nI,3]	,;
													,;
									cCdrOri			,;
									M->DTV_CDRDES	,;
													,;
													,;
									M->DTV_CODPRO	,;
													,;
													,;
													,;
													,;
									@aMsgErr		,;
													,;
									M->DTV_VALMERC	,;
									Max(M->DTV_PESO,M->DTV_PESOM3),;
									0				,;
									0				,;
									M->DTV_QTDVOL	,;
													,,,,,,,,,,,,,,,,,,,;
									M->DTV_PESO		,;
									M->DTV_PESOM3	,;
													,;
									M->DTV_VALMER	,;
									M->DTV_QTDVOL	,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
									DTQ->DTQ_FILORI ,;
									DTQ->DTQ_VIAGEM)
			nSeek := Ascan( aFrtAWB,{|x| x[3] == 'TF' })

			If	Empty( nSeek ) .Or. nSeek != Len(aFrtAWB)
				AAdd(aMsgErr,{'Fornecedor: '+(cAliasQry)->A2_COD+'-'+(cAliasQry)->A2_LOJA+' '+STR0024,'00',''}) //"Falha na linha totalizadora da composicao do frete"
			ElseIf Empty( aFrtAWB[ nSeek, 2 ] )
				AAdd(aMsgErr,{'Fornecedor: '+(cAliasQry)->A2_COD+'-'+(cAliasQry)->A2_LOJA+' '+STR0025,'00',''}) //"Tabela de frete nao encontrada"
			Else				
				TmsA040Imp( aFrtAWB, M->DTV_CODCIA, M->DTV_LOJCIA, cDocTms, '1', M->DTV_CDRDES, .T., @nAlqICM, M->DTV_FILDES, (cAliasQry)->A2_TIPO )
					Aadd( aRet, {	(cAliasQry)->A2_COD   , ;
									(cAliasQry)->A2_LOJA  , ;
									(cAliasQry)->A2_NREDUZ, ;
									aContr[nI,2]          , ;
									aContr[nI,3]          , ;
									Tabela("M5", aContr[nI,3],.F.)  , ;
									aFrtAWB[ nSeek, 2 ]   , ;
									aFrtAWB[ nSeek, 5 ]   , ;
									aFrtAWB[ nSeek, 6 ]   , ;
									AClone(aFrtAWB)       , ;
									(cAliasQry)->A2_COND  } )
			EndIf
			If !Empty(aMsgErr)
				AaddMsgErr( aMsgErr, @aVisErr)
			EndIf
		Next nI
	EndIf
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

aRet := ASort(aRet,,,{ | x, y | x[9] < y[9] })

If lRecalculo
	aCompos := aClone(aRet)
	oLbxComp:SetArray( aCompos )
	oLbxComp:bLine := { || {	aCompos[ oLbxComp:nAT, 1 ],;
								aCompos[ oLbxComp:nAT, 2 ],;
								aCompos[ oLbxComp:nAT, 3 ],;
								aCompos[ oLbxComp:nAT, 4 ],;
								aCompos[ oLbxComp:nAT, 5 ],;
								aCompos[ oLbxComp:nAT, 6 ],;
								TransForm( aCompos[ oLbxComp:nAT, 7 ], PesqPict('DT8','DT8_VALPAS') ),;
								TransForm( aCompos[ oLbxComp:nAT, 8 ], PesqPict('DT8','DT8_VALIMP') ),;
								TransForm( aCompos[ oLbxComp:nAT, 9 ], PesqPict('DT8','DT8_VALTOT') ) } }

	oLbxComp:Refresh()
EndIf

RestArea(aAreaAtu)

Return aClone(aRet)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA320NDes³ Autor ³ Rodolfo K. Rosseto³   Data ³ 17/11/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Posiciona e restaura o SM0                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA320NDes()                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320NDes(cFilDes)

Local aArea    := GetArea()
Local aAreaSM0 := SM0->(GetArea())
Local cNomDes  := ''

cNomDes := Posicione('SM0',1,cEmpAnt+cFilDes,'M0_FILIAL')

RestArea(aAreaSM0)
RestArea(aArea)

Return cNomDes

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA320Man ³ Autor ³ Eduardo de Souza     ³ Data ³ 07/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Selecao dos manifestos                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320Man()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA320Man(lMostra)

Local cTitFilMan := RetTitle('DTX_FILMAN')
Local cTitManif  := RetTitle('DTX_MANIFE')
Local cTitQtdDoc := RetTitle('DTX_QTDDOC')
Local cTitQtdVol := RetTitle('DTX_QTDVOL')
Local cTitPeso   := RetTitle('DTX_PESO')
Local cTitPesoM3 := RetTitle('DTX_PESOM3')
Local cTitPesCob := RetTitle('DTX_PESCOB')
Local cTitValMer := RetTitle('DTX_VALMER')
Local cTitFilDca := RetTitle('DTX_FILDCA')
Local cTitCdrdes := RetTitle('DTX_CDRDES')
Local cTitRegdes := RetTitle('DTV_REGDES')
Local cFilOri    := ''
Local cViagem    := ''
Local cDigito    := ''
Local lDTX_CDRDES:= DTX->(FieldPos("DTX_CDRDES")) > 0
Local oDlgEsp
Local oLbx
Local cAliasNew  := ""
Local cQuery     := ""
Local nOpca      := 0
Local nPeso      := M->DTV_PESO
Local nPesoM3    := M->DTV_PESOM3
Local nQtdVol    := M->DTV_QTDVOL
Local nValMer    := M->DTV_VALMER
Local oNoMarked  := LoadBitmap( GetResources(),'LBNO' )
Local oMarked    := LoadBitmap( GetResources(),'LBOK' )
Local aButtons   := {}
Local nCnt       := 0
Local cCdrDes    := Space(Len(DUY->DUY_GRPVEN))
Local aHMan      := {}
Local aItem      := {}
Local cFilDes    := ""

Private lTM320CMA := ExistBlock( 'TM320CMA' ) //-- Permite ao usuario, incluir colunas nos Manifestos.
Private aUsHMan := {}

Default lMostra  := lDTX_CDRDES

//-- Inclui colunas do usuario
If lTM320CMA
	If ValType( aUsHMan := ExecBlock( 'TM320CMA', .F., .F. ) ) <> 'A'
		aUsHMan := {}
	EndIf
EndIf

//-- Atualiza a variavel com os manifestos.
aManAux   := aClone(aManifesto)

Aadd(aButtons,	{'DEVOLNF', {|| TMSA320Doc(oLbx:nAt) }, STR0032 , STR0028 }) //"Documento"###"Docum."

If !lMostra .Or. Empty(aManAux) .Or. ;
	M->DTV_FILORI <> cFilori .Or. M->DTV_VIAGEM <> cViagem
	aManAux  := {}
	cAliasNew  := GetNextAlias()
	cQuery := " SELECT * "
	cQuery += "   FROM " + RetSQLName("DTX")
	cQuery += "   WHERE DTX_FILIAL = '" + xFilial("DTX") + "' "
	cQuery += "     AND DTX_FILORI = '" + M->DTV_FILORI  + "' "
	cQuery += "     AND DTX_VIAGEM = '" + M->DTV_VIAGEM  + "' "
	cQuery += "     AND DTX_NUMAWB = ' ' "
	cQuery += "     AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

	If (cAliasNew)->(!Eof())
		While (cAliasNew)->(!Eof())
			aItem := {}
			Aadd( aItem, Iif(lMostra,.F.,.T.) )   //-- 01
			Aadd( aItem, (cAliasNew)->DTX_FILMAN) //-- 02
			Aadd( aItem, (cAliasNew)->DTX_MANIFE) //-- 03
			Aadd( aItem, Iif(lDTX_CDRDES,(cAliasNew)->DTX_CDRDES,cCdrDes) ) //-- 04
			If Empty(aItem[Len(aItem)])
				aItem[Len(aItem)] := PadR(SuperGetMV("MV_CDRORI",,,(cAliasNew)->DTX_FILDCA),Len(DTX->DTX_CDRDES))
			EndIf
			Aadd( aItem, Posicione("DUY",1,xFilial("DUY")+aItem[Len(aItem)],"DUY_DESCRI") )  //-- 05
			Aadd( aItem, (cAliasNew)->DTX_QTDDOC) //-- 06
			Aadd( aItem, (cAliasNew)->DTX_QTDVOL) //-- 07
			Aadd( aItem, (cAliasNew)->DTX_PESO  ) //-- 08 
			Aadd( aItem, (cAliasNew)->DTX_PESOM3) //-- 09
			Aadd( aItem, (cAliasNew)->DTX_PESCOB) //-- 10
			Aadd( aItem, (cAliasNew)->DTX_VALMER) //-- 11
			Aadd( aItem, (cAliasNew)->DTX_FILDCA) //-- 12
			Aadd( aItem, (cAliasNew)->R_E_C_N_O_) //-- 13

			If !Empty(aUsHMan)
				For nCnt := 1 To Len(aUsHMan)
					AAdd(aItem, (cAliasNew)->&( aUsHMan[nCnt,2] ) )
				Next nCnt
			EndIf
			Aadd( aManAux, aClone(aItem) )

			(cAliasNew)->(DbSkip())
		EndDo
	Else
		Help("", 1, "TMSA32022") //"Nao foram encontrados manifestos sem vinculo com AWB !!!"
	EndIf
	(cAliasNew)->(DbCloseArea())
EndIf

If lMostra
	If !Empty(aManAux)
		DEFINE MSDIALOG oDlgEsp TITLE STR0027 FROM 00,00 TO 300,600 PIXEL //"Manifestos"

			Aadd( aHMan,' '        )  //-- 01
			Aadd( aHMan,cTitFilMan )  //-- 02
			Aadd( aHMan,cTitManif  )  //-- 03
			Aadd( aHMan,cTitCdrdes )  //-- 04
			Aadd( aHMan,cTitRegdes )  //-- 05
			Aadd( aHMan,cTitQtdDoc )  //-- 06
			Aadd( aHMan,cTitQtdVol )  //-- 07
			Aadd( aHMan,cTitPeso   )  //-- 08
			Aadd( aHMan,cTitPesoM3 )  //-- 09
			Aadd( aHMan,cTitPesCob )  //-- 10
			Aadd( aHMan,cTitValMer )  //-- 11
			Aadd( aHMan,cTitFilDca )  //-- 12

			//-- Inclui colunas do usuario
			If lTM320CMA
				For nCnt := 1 To Len(aUsHMan)
					Aadd( aHMan, aUsHMan[nCnt,1] )
				Next nCnt
			EndIf

			oLbx:= TWBrowse():New( 030, 000, 300, 140, NIL, aHMan, NIL, oDlgEsp, NIL, NIL, NIL,,,,,,,,,, "ARRAY", .T. )
			oLbx:SetArray( aManAux )
			oLbx:bLDblClick  := { || { aManAux[oLbx:nAT,1] := !aManAux[oLbx:nAT,1] }}
			oLbx:bLine := &('{ || TMSA320Line(oLbx:nAT) }')
		
		ACTIVATE MSDIALOG oDlgEsp ON INIT EnchoiceBar(oDlgEsp,{|| nOpca := 1, oDlgEsp:End()},{||oDlgEsp:End()},,aButtons) CENTERED
	EndIf
Else
	nOpca := 1
EndIf

If nOpca == 1
	nPeso   := 0
	nPesoM3 := 0
	nQtdVol := 0
	nValMer := 0
	ASort( aManAux,,,{|x,y| x[1] > y[1] })
	For nCnt := 1 To Len(aManAux)
		//-- Somente manifestos marcados
		If !aManAux[nCnt,1]
			Exit
		EndIf
		If nCnt == 1
			cCdrDes := aManAux[nCnt,04]
			cFilDes := aManAux[nCnt,12]
		EndIf
		nPeso   += aManAux[nCnt, 8]
		nPesoM3 += aManAux[nCnt, 9]
		nQtdVol += aManAux[nCnt, 7]
		nValMer += aManAux[nCnt,11]
		//-- Zera a regiao qdo encontrada uma regiao diferente.
		If cCdrDes <> aManAux[nCnt,04]
			cCdrDes  := Space(Len(DUY->DUY_GRPVEN))
			cFilDes  := Space(Len(DUY->DUY_FILDES))
		EndIf
	Next nCnt
	cFilOri := M->DTV_FILORI
	cViagem := M->DTV_VIAGEM
	ASort( aManAux,,,{|x,y| x[2] + x[3] < y[2] + y[3] })
	aManifesto := aClone(aManAux)
EndIf

Return { nPeso, nPesoM3, nQtdVol, nValMer, cCdrDes, cFilDes }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA320Line³ Autor ³ Jose Luiz P. Jr      ³ Data ³ 24/05/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Atualizacao da bLine do documento.                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320Line(ExpN1)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Posicao da linha no listbox                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGATMS                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA320Line(nAt)

Local abLine  := {}
Local nPosIni := 0
Local nCnt    := 0

If oMarked == Nil
	oMarked := LoadBitmap( GetResources(),'LBOK' )
EndIf
If oNoMarked == Nil
	oNoMarked := LoadBitmap( GetResources(),'LBNO' )
EndIf

Aadd( abLine, Iif(aManAux[ nAT, 01 ] , oMarked, oNoMarked ) )
Aadd( abLine, aManAux[ nAT, 02 ] )
Aadd( abLine, aManAux[ nAT, 03 ] )
Aadd( abLine, aManAux[ nAT, 04 ] )
Aadd( abLine, aManAux[ nAT, 05 ] )
Aadd( abLine, aManAux[ nAT, 06 ] )
Aadd( abLine, aManAux[ nAT, 07 ] )
Aadd( abLine, aManAux[ nAT, 08 ] )
Aadd( abLine, aManAux[ nAT, 09 ] )
Aadd( abLine, aManAux[ nAT, 10 ] )
Aadd( abLine, aManAux[ nAT, 11 ] )
Aadd( abLine, aManAux[ nAT, 12 ] )

//-- Inclui colunas do usuario
//-- Ultima posicao do aDocto padrao para inicializar o bline do usuario.
If lTM320CMA
	nPosIni  := (Len(aManAux[nAt]) - Len(aUsHMan)) + 1
	For nCnt := nPosIni To Len(aManAux[nAt])
		Aadd( abLine, aManAux[nAt,nCnt] )
	Next nCnt
EndIf

Return abLine

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TMSA320Doc ³ Autor ³ Eduardo de Souza     ³ Data ³ 07/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza documentos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TMSA320Doc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA320Doc(nAt)

Local cFiltro1   := ""
Local cCadastro  := STR0026 //"Documentos"
Local aRotOld    := aClone(aRotina)
Local aCampos    := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE.                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aCampos, "DUD_FILDOC")
Aadd(aCampos, "DUD_DOC")
Aadd(aCampos, "DUD_SERIE")
Aadd(aCampos, "DUD_REGDES")

aRotina := {}
Aadd( aRotina, { STR0003,"TmsA320VDc",0,2,,,.T.} ) // "Visualizar"

DUD->(dbSetOrder(5))
cFiltro1 := '"'+xFilial("DUD")+M->DTV_FILORI+M->DTV_VIAGEM+aManAux[nAt,2]+aManAux[nAt,3]+'"'

MaWndBrowse(0,0,300,600,cCadastro,"DUD",aCampos,aRotina,,cFiltro1,cFiltro1,.T.)

aRotina := aClone(aRotOld)

Return .T.

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA320VDc ³ Autor ³ Eduardo de Souza     ³ Data ³ 07/06/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza documentos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA320VDc()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320VDc()

SaveInter()

//-- Alterada a aRotina permitindo a visualizacao do documento
aRotina := {{ '','',0,2},{ '','',0,2}}
TMSViewDoc(DUD->DUD_FILDOC,DUD->DUD_DOC,DUD->DUD_SERIE)

RestInter()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TMSA320_V  ³ Autor ³ Telso Carneiro       ³ Data ³ 02/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao utilizada para verificar a ultima versao do fonte   ³±±
±±³          ³ TMSA320.PRW aplicado no rpo do cliente, assim verificando  ³±±
±±³          ³ a necessidade de uma atualizacao neste fonte.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA144Sub                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function TMSA320_V()
Local nRet := 20061002 // 02 de outubro de 2006
Return nRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³TmsA320DD7 ³ Autor ³ Richard Anderson     ³ Data ³ 01/07/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza aeroportos da regiao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TmsA320DD7()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320DD7(lValida)

Local cQuery    := ""
Local cAliasQry := GetNextAlias()
Local cCampo    := AllTrim(ReadVar())
Local cCodReg   := Iif("DTV_AERORI" $ cCampo,SuperGetMv("MV_CDRORI",,""),M->DTV_CDRDES)
Local lRet      := .T.
Local aItens    := {}
Local nCntFor   := 0
Local aRegiao   := {} 	//-- Obtem os niveis superiores da regiao
Local cRegiao   := ""
Local cCadastro := 'Escolha o Aeroporto'
Local aNewButton:= {}
Local lCancel   := .T.
Local lPesq     := .T.
Local lTMA320DD7:= ExistBlock("TMA320DD7")
Local cAux		:= ""

Private   aTitulo := {}

Default lValida   := .F.

If lTMA320DD7
	cAux	:= ExecBlock("TMA320DD7",.F.,.F.,{cCodReg , cCampo })
	If !Empty(cAux)
		cCodReg		:= cAux
	EndIf
EndIf

aRegiao		:= TMSNivSup(cCodReg)

DD7->(dbSetOrder(1))
If DD7->(!dbSeek(xFilial('DD7')+cCodReg))
	For nCntFor := 1 To Len(aRegiao)
		If !Empty(cRegiao)
			cRegiao += ", "
		EndIf
		cRegiao += "'"+aRegiao[nCntFor]+"'"
	Next nCntFor
Else
	cRegiao := "'"+cCodReg+"'"	
EndIf

cQuery := "SELECT DD7_CODREG, DD7_CODAER, R_E_C_N_O_ DD7RECNO FROM "+RetSqlName("DD7")
cQuery += " WHERE DD7_FILIAL  = '"+xFilial("DD7")+"'" 
cQuery += "   AND DD7_CODREG IN ("+cRegiao+")"
cQuery += "   AND D_E_L_E_T_  = ' '"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )
While (cAliasQry)->(!Eof())
	Aadd(aItens,{ (cAliasQry)->DD7_CODAER, Tabela("M9",(cAliasQry)->DD7_CODAER,.F.), (cAliasQry)->DD7RECNO })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

If Len(aItens) > 0
	If lValida
		If Ascan(aItens,{ | e | e[1] == &(cCampo) }) == 0
			lRet := .F.
			Help('',1,'REGNOIS')
		EndIf
	Else

		Aadd( aTitulo, RetTitle('DD7_CODAER') )
		Aadd( aTitulo, RetTitle('DD7_NOMAER') )
		aCabec := aClone(aTitulo)

		AAdd(aNewButton, {15,{|nAt| TmsA320Vis(aItens[nAt,Len(aTitulo)+1],'DD7') } } )

		nRet := TmsF3Array( aTitulo, aItens, cCadastro, lCancel, aNewButton, aCabec ) // TmsF3Array( aHeadTms, aItemTms, cTitulo, lCancel, aNewButton, aCabec )

		If !Empty(nRet)
			DD7->(dbGoTo(aItens[nRet,Len(aTitulo)+1]))
		Else
			lRet := .F.
		EndIf

	EndIf
Else
	MsgAlert(STR0036 + AllTrim(cCodReg)) //"Não existem aeroportos relacionados a região "
	lRet := .F.
EndIf
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³Tm320Contr ³ Autor ³ Jose Luiz Pinheir Jr ³ Data ³ 05/08/10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Visualiza tabela de Fretes                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Tm320Contr()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ TMSA320                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Tm320Contr(aTabs)
Local lRet      := .F.
Local aItens    := {}
Local nCntFor   := 0
Local lCancel   := .T.

Private aTitulo := {}

For nCntFor := 1 To Len(aTabs)
	Aadd(aItens,{ aTabs[nCntFor,2], aTabs[nCntFor,3],Tabela('M5',aTabs[nCntFor,3],.F.), nCntFor })
Next nCntFor

If Len(aItens) > 0

	Aadd( aTitulo, STR0022 ) //"Tabela de Frete"
	Aadd( aTitulo, STR0023 ) //"Tipo"
	Aadd( aTitulo, RetTitle('DTL_DESTIP') )
	aCabec := aClone(aTitulo)

	nRet := TmsF3Array( aTitulo, aItens, STR0021, lCancel, /*aNewButton*/, aCabec )  //"Escolha a Tabela de Frete"

	If !Empty(nRet)
		aTabs[nRet,1] := .T.
		lRet := .T.
	EndIf

EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Efeº Autor ³ Richard Anderson   º Data ³  01/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que monta tela para troca do numero da AWB gerada   º±±
±±º          ³ no balcao.                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA320Efe(cAlias, nReg, nOpcx, cOriFun)
// Variaveis Locais da Funcao
Local oGet1
Local oGet2
Local oGet3
Local oGet4
Local oGet5
Local oGet6
Local oGet7
Local oGet8
Local oGet9
Local oGeta
Local oGetb
Local cNroProv   := DTV->DTV_NUMAWB
Local nVlrProv   := 0
Local nPesProv   := DTV->DTV_PESO
Local nPesM3Prov := DTV->DTV_PESOM3
Local cNroOfic   := CriaVar('DTV_NUMAWB',.F.)
Local nVlrOfic   := 0
Local cDigOfic   := CriaVar('DTV_DIGAWB',.F.)
Local nPesOfic   := nPesProv
Local nPesM3Ofic := nPesM3Prov
Local lRet       := .T.
Local nVlrFre    := 0
Local lContinua  := .T.
Local dDatEmi    := DTV->DTV_DATEMI
Local cHorEmi    := DTV->DTV_HOREMI
Local cDigito    := ''
Local lTM320Efet := ExistBlock('TM320EFET')

Default cOriFun	:= ''
//-- Variaveis Private da Funcao
Private oDlg //-- Dialog Principal
//-- Total do Frete
Private aFrete    := {}
//-- Utilizado pela funcao TmsA500Dsc
Private cOpcao    := 'Alteração do Frete'
Private nPerOri   := 0
Private aFrtOri   := {}
Private aSetKey   := {}
Private lPrimComp := .T.
Private aCodPro   := {}
Private cProdCal  := ""
Private cDocTMS   := '3' // AWB
Private nAlqICM   := Iif(DTV->(FieldPos('DTV_PICM')) > 0,DTV->DTV_PICM,0)
Private aTela[0][0],aGets[0]

If cOriFun	!= 'TM320EstEf'
	nOpcx := aRotina[nOpcx,4]
EndIf

//-- Configura variaveis da Enchoice
RegToMemory("DTV",.F.)

If M->DTV_BALCAO == "2" .Or. Empty(M->DTV_BALCAO)
	Aviso(STR0038,"AWB: " + AllTrim(M->DTV_NUMAWB) + " não foi emitida no balcão",{"OK"})
	lContinua := .F.
EndIf

If lContinua .And. !Empty(M->DTV_NUMORI) .And. cOriFun	!= 'TM320EstEf'
	Aviso(STR0038,"AWB: " + AllTrim(M->DTV_NUMAWB) + " já foi efetivada",{"OK"})
	lContinua := .F.
EndIf

If lContinua .And. M->DTV_FILORI <> cFilAnt
	Aviso(STR0038,"AWB: " + AllTrim(M->DTV_NUMAWB) + " somente pode ser efetivada na filial "+M->DTV_FILORI,{"OK"})
	lContinua := .F.
EndIf

If lContinua

	If lAWBRepete
		cDigito  := TMSA320Dig(DTV->DTV_DATEMI,DTV->DTV_DIGAWB)
		cDigito  := If(Len(cDigito)>0,cDigito,Space(Len(DTV->DTV_DIGAWB)))
		nVlrProv := Posicione("DT8",3,xFilial("DT8")+DTV->DTV_NUMAWB+cDigito+DTV->DTV_CODCIA+DTV->DTV_LOJCIA+'TF',"DT8_VALTOT")
	Else
		nVlrProv := Posicione("DT8",3,xFilial("DT8")+DTV->DTV_NUMAWB+'TF',"DT8_VALTOT")
	EndIf
	nVlrOfic := nVlrProv
	nVlrFre  := DT8->DT8_VALPAS

	//-- Obtem a composição do frete
	If lAWBRepete
		TmsViewFrt('6',,M->DTV_NUMAWB,,,,,,,,,M->DTV_CODCIA,M->DTV_LOJCIA,cDigito)
	Else
		TmsViewFrt('6',,M->DTV_NUMAWB)
	EndIf
	
	If lTM320Efet
		lContinua	:= ExecBlock('TM320EFET',.F.,.F., { nOpcx , DTV->DTV_FILIAL, cNroProv , DTV->DTV_DIGAWB , DTV->DTV_CODCIA , DTV->DTV_LOJCIA } )
		lRet		:= lContinua
	EndIf

	If lContinua

		DEFINE MSDIALOG oDlg TITLE "Efetivar" FROM C(268),C(243) TO C(575),C(625) PIXEL

			// Cria as Groups do Sistema
			@ C(004),C(003) TO C(064),C(190) LABEL " AWB Provisório " PIXEL OF oDlg
			@ C(068),C(003) TO C(128),C(190) LABEL " AWB Oficial "    PIXEL OF oDlg

			// Cria Componentes Padroes do Sistema
			@ C(015),C(008) Say "Numero" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(015),C(030) MsGet oGet1 Var cNroProv When .F. Size C(060),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_NUMAWB") PIXEL OF oDlg
			@ C(015),C(097) Say "Valor" Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(015),C(121) MsGet oGet2 Var nVlrProv When .F.  Size C(060),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_VALMER") PIXEL OF oDlg
			@ C(040),C(007) Say "Peso" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(039),C(030) MsGet oGet3 Var nPesProv When .F.  Size C(060),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_PESO") PIXEL OF oDlg
			@ C(040),C(097) Say "Peso M3" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(039),C(121) MsGet oGet4 Var nPesM3Prov When .F.  Size C(060),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_PESOM3") PIXEL OF oDlg
		
			@ C(080),C(008) Say "Numero"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(080),C(032) MsGet oGet5       Var cNroOfic   Size C(020),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_NUMAWB") PIXEL OF oDlg VALID AllWaysTrue(cNroOfic := StrZero(Val(cNroOfic),Len(DTV->DTV_NUMAWB)))
			@ C(080),C(062) Say "Dígito"      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(080),C(074) MsGet oGet9       Var cDigOfic   Size C(008),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_DIGAWB") PIXEL OF oDlg 
			@ C(080),C(097) Say "Valor"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(080),C(121) MsGet oGet6       Var nVlrOfic   Size C(060),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_VALMER") PIXEL OF oDlg WHEN .F.
			@ C(095),C(008) Say "Peso"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(094),C(032) MsGet oGet7       Var nPesOfic   Size C(060),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_PESO")   PIXEL OF oDlg VALID TMSA320Cal(1,@nVlrOfic,@nVlrFre,oGet6,nPesOfic  ,cNroOfic,cDigOfic)
			@ C(095),C(097) Say "Peso M3"     Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(094),C(121) MsGet oGet8       Var nPesM3Ofic Size C(060),C(009) COLOR CLR_BLACK Picture PesqPict("DTV","DTV_PESOM3") PIXEL OF oDlg VALID TMSA320Cal(2,@nVlrOfic,@nVlrFre,oGet6,nPesM3Ofic,cNroOfic,cDigOfic)
			@ C(110),C(008) Say "Dt.Emissão"  Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(110),C(032) MsGet oGeta       Var dDatEmi    Size C(020),C(009) COLOR CLR_BLACK PIXEL OF oDlg VALID dDatEmi >= DTV->DTV_DATEMI .And. dDatEmi <= dDataBase
			@ C(110),C(097) Say "Hr.Emissão"  Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
			@ C(110),C(121) MsGet oGetb       Var cHorEmi    Size C(012),C(009) COLOR CLR_BLACK PIXEL OF oDlg VALID AtVldHora(cHorEmi) PICTURE "@R 99:99"
			DEFINE SBUTTON FROM C(136),C(065) TYPE 5 ENABLE OF oDlg ACTION(TMSA320Frt(@nVlrOfic,@nVlrFre,oGet6)) ONSTOP "Altera Frete"
			DEFINE SBUTTON FROM C(136),C(108) TYPE 1 ENABLE OF oDlg ACTION(lRet := Val(cNroOfic) > 0 .And. TMSA320Alt(cNroProv,cNroOfic,nVlrOfic,nPesOfic,nPesM3Ofic,nVlrFre,cDigOfic,dDatEmi,cHorEmi),IIf(lRet,oDlg:End(),nil))
			DEFINE SBUTTON FROM C(136),C(151) TYPE 2 ENABLE OF oDlg ACTION(lRet := .F., oDlg:End())

		ACTIVATE MSDIALOG oDlg CENTERED

		If lTM320GRV .And. lRet
			ExecBlock('TM320GRV',.F.,.F., nOpcx )
		EndIf
		
	EndIf
EndIf

Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Frtº Autor ³ Richard Anderson   º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Permite alteração do frete a pagar                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA320Frt(nVlrOfic,nVlrFre,oGet6)

Local nSeek := 0

TmsA500Dsc(6,@lPrimComp,M->DTV_CODCIA,M->DTV_LOJCIA,M->DTV_FILDES)

nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })

If nSeek > 0
	nVlrFre := aFrete[nSeek,2]
	nVlrOfic:= aFrete[nSeek,6]
	oGet6:Refresh()
EndIf

Return NIL

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Calº Autor ³ Richard Anderson   º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Calcula novo frete                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA320Cal(nTpPeso,nVlrOfic,nVlrFre,oGet6,nPeso,cNroOfic,cDigOfic)

Local lRet  := .T.
Local lCalc := .T.

If nTpPeso == 1 //-- Peso 
	If M->DTV_PESO != nPeso
		M->DTV_PESO := nPeso
	Else
		lCalc := .F.
	EndIf
ElseIf nTpPeso == 2 //-- Peso Cubado
	If M->DTV_PESOM3 != nPeso
		M->DTV_PESOM3 := nPeso
	Else
		lCalc := .F.
	EndIf
EndIf

If lCalc
	M->DTV_NUMAWB := cNroOfic
	M->DTV_DIGAWB := cDigOfic
	//-- Executa calculo do frete
	If TMSA320Vld('M->DTV_CODCIA')
		nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
		If nSeek > 0
			MsgAlert(STR0037,STR0038) //"Frete recalculado!"###"ATENÇÃO"
			nVlrFre := aFrete[nSeek,2]
			nVlrOfic:= aFrete[nSeek,6]
			oGet6:Refresh()
		EndIf
	Else
		lRet := .F.	
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320AltºAutor  ³ Richard Anderson   º Data ³  01/07/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina que grava a alteracao dos valores efetuados pelo     º±±
±±º          ³usuario.                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNroAWB     : Numero original da AWB                        º±±
±±º          ³cNroOfic    : Novo numero da AWB                            º±±
±±º          ³nVlrOfic    : Novo valor da AWB                             º±±
±±º          ³nPesOfic    : Novo peso da AWB                              º±±
±±º          ³nPesM3Ofic  : Novo peso M3 da AWB                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA320Alt(cNroAWB,cNroOfic,nVlrOfic,nPesOfic,nPesM3Ofic,nVlrFre,cDigOfic,dDatEmi,cHorEmi)

Local aArea     := GetArea()
Local lRet      := .T.
Local aDocto    := {}
Local cCondPag  := ''
Local cTesAWB   := GetMV("MV_TESAWB") // Tes da AWB.
Local cCodDes   := GetMV("MV_DESAWB") // Despesa AWB.
Local nRecnoDT8 := 0
Local nRecnoDTX := 0
Local nSeek     := 0
Local aFrtAux   := {}
Local aFrtAnt   := AClone(aFrete)
Local aDoc      := TMSA320Awb( cNroOfic, cDigOfic,.T., M->DTV_CODCIA, M->DTV_LOJCIA, M->DTV_DATEMI )
Local cFilOri   := M->DTV_FILORI
Local cDoc      := aDoc[1]
Local cSerie    := aDoc[2]
Local lTM320Nfe := ExistBlock('TM320NFE')
Local lGrvNfe   := .T.

If Empty(cNroOfic) .Or.	nVlrOfic <= 0 .Or. nPesOfic <= 0 
	Aviso(STR0038,STR0040,{"OK"}) //"ATENÇÃO"###"Favor verificar valores informados!"
	lRet := .F.
EndIf

If lRet
	If lAWBRepete
		lRet := ExistChav('DTV',cNroOfic+TMSA320Dig(M->DTV_DATEMI,cDigOfic)+M->DTV_CODCIA+M->DTV_LOJCIA,1)
	Else
		lRet := ExistChav('DTV',cNroOfic,1)
	EndIf
EndIf

If lRet
	lRet := ChkF1Nfe( cFilOri, cDoc, cSerie, M->DTV_CODCIA, M->DTV_LOJCIA )
EndIf

If lRet
	CursorWait()

	dbSelectArea("DTV")
	dbSetOrder(1)

	If MsSeek(xFilial("DTV")+cNroAWB)

		Begin Transaction

		nSeek := AScan(aFrete,{|x| x[3] == 'TF' })
		M->DTV_DOCDES := TMA250GrvSDG("DTV" , DTV->DTV_FILORI, DTV->DTV_VIAGEM, cCodDes, aFrete[ nSeek, 6 ], 1,,,,,,,,,,,,,,,,"TMSA320","2" )

		RecLock("DTV",.F.)
		DTV->DTV_NUMORI := cNroAWB
		DTV->DTV_PESORI := M->DTV_PESO
		DTV->DTV_PM3ORI := M->DTV_PESOM3
		DTV->DTV_NUMAWB := cNroOfic
		DTV->DTV_DIGAWB := cDigOfic
		DTV->DTV_PESO   := nPesOfic
		DTV->DTV_PESOM3 := nPesM3Ofic
		DTV->DTV_DATEMI := dDatEmi
		DTV->DTV_HOREMI := cHorEmi
		DTV->DTV_TABFRE := M->DTV_TABFRE
		DTV->DTV_TIPTAB := M->DTV_TIPTAB
		DTV->DTV_DOCDES := M->DTV_DOCDES
		DTV->DTV_DATEFE := dDataBase
		DTV->DTV_HOREFE := Padr(StrTran(Time(),':',''),4)
		MsUnLock()

		//-- Grava composicao do frete alterada
		//-- Exclui a composicao do frete da AWB provisoria
		DT8->(dbSetOrder(3))
		While DT8->(dbSeek(xFilial("DT8")+cNroAWB))
			RecLock('DT8',.F.)
			dbDelete()
			MsUnLock()
		EndDo
		//-- Monto a estrutura do vetor afrete para atender a gravacao da composicao da AWB Oficial
		aFrtAux:= {}
		AAdd(aFrtAux,{Space(Len(DT8->DT8_CODPRO)),aFrete})
		aFrete := {}
		aFrete := AClone(aFrtAux)
		TmsGrvDT8( 'TMSA320', M->DTV_FILORI, cNroOfic ,,,,,,,, M->DTV_CODCIA , M->DTV_LOJCIA , cDigOfic )
		//-- Restauro a estrutura do vetor afrete
		aFrete := AClone(aFrtAnt)

		//-- Troca numero na composição de frete
		DT8->(dbSetOrder(3))
		DT8->(dbSeek(xFilial("DT8")+cNroAWB))
		While DT8->(!Eof()) .And. DT8->(DT8_FILIAL+DT8_NUMAWB) == xFilial('DT8')+cNroAWB
			DT8->(dbSkip())
			nRecnoDT8 := DT8->(Recno())
			DT8->(dbSkip(-1))
			RecLock("DT8",.F.)
			DT8->DT8_NUMAWB := cNroOfic
			MsUnLock()
			DT8->(dbGoTo(nRecnoDT8))
		EndDo

		//-- Troca numero do Manifesto de Carga
		DTX->(dbSetOrder(4))
		DTX->(dbSeek(xFilial('DTX')+cNroAWB))
		While DTX->(!Eof()) .And. DTX->(DTX_FILIAL+DTX_NUMAWB) == xFilial('DTX')+cNroAWB
			DTX->(dbSkip())
			nRecnoDTX := DTX->(Recno())
			DTX->(dbSkip(-1))
			RecLock('DTX',.F.)
			DTX->DTX_NUMAWB := cNroOfic
			If lDTX_DIGAWB 
				DTX->DTX_DIGAWB := cDigOfic
			EndIf
			DTX->(dbGoTo(nRecnoDTX))
		EndDo
	
		If lTM320Nfe
			lGrvNfe := ExecBlock('TM320NFE',.F.,.F.)
		EndIf
		
		If lGrvNfe
			//-- Cond. Pagto da Cia Aerea
			cCondPag := Posicione('SA2',1,xFilial('SA2')+M->(DTV_CODCIA+DTV_LOJCIA),'A2_COND')
			
			//-- Gera documento de entrada
			aDocto   := {}
			AAdd(aDocto,Posicione('DUI',1,xFilial('DUI')+'3','DUI_CODPRO'))	//-- 1 Produto
			AAdd(aDocto,cDoc)													//-- 2 Docto
			AAdd(aDocto,cSerie)													//-- 3 Serie
			AAdd(aDocto,M->DTV_CODCIA)											//-- 4 Cliente/Fornecedor
			AAdd(aDocto,M->DTV_LOJCIA)											//-- 5 Loja do Cliente/Fornecedor
			AAdd(aDocto,M->DTV_QTDVOL)											//-- 6 Volume
			AAdd(aDocto,nVlrFre)												//-- 7 Valor do Frete
			AAdd(aDocto,cCondPag)												//-- 8 Condicao de pagamento
			AAdd(aDocto,'CA')													//-- 9 Especie
			AAdd(aDocto,nAlqICM)												//--10 Aliquota ICM
			AAdd(aDocto,'N')													//--11 Tipo da nota
			AAdd(aDocto,cTesAWB)												//--12 TES da AWB
			AAdd(aDocto,SA2->A2_EST)											//--13 Estado
	
			lRet := TmsA320NFE(aDocto,3)
		EndIf

		End Transaction

		If lRet
			//-- Atualiza status financeiro
			TMSA320Fin()
		EndIf

	EndIf

EndIf

RestArea(aArea)

CursorArrow()

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Finº Autor ³ Richard Anderson   º Data ³  28/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualiza status financeiro da AWB                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TMSA320Fin()

Local aArea    := GetArea()
Local nPtoAWB  := SuperGetMv('MV_PTOAWB',,0)
Local nSeek    := 0
Local cStaFin  := '1' //-- Faturamento em Aberto
Local cSeekDTV := ""
Local nFrtAWB  := 0
Local nFrtCal  := 0
Local nValTot  := 0
Local nPercen  := 0
Local cSeekDT8 := ""
Local aFrete   := {}
Local cCdrOri  := ""
Local aRet     := {}
Local aMsgErr  := {}
Local cQuery   := ''
Local nRentab  := 0
Local nValFre  := 0
Local cFilSf1  := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
Local aDoc     := TMSA320Awb( DTV->DTV_NUMAWB, DTV->DTV_DIGAWB, .T., DTV->DTV_CODCIA, DTV->DTV_LOJCIA, DTV->DTV_DATEMI )
Local aValor   := TMSA320Vlr(cFilSF1, aDoc[1], aDoc[2], DTV->DTV_CODCIA, DTV->DTV_LOJCIA)
Local cAliasQry:= GetNextAlias()
Local cDigito  := ''
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0

nFrtAWB := aValor[1]
nValTot := aValor[2]

//-- Executa calculo do frete
DTQ->(DbSetOrder(2))
If	DTQ->(MsSeek(xFilial('DTQ')+M->DTV_FILORI+M->DTV_VIAGEM))
	//-- Obtem a Regiao Origem / Ultimo Destino da Rota
	aRet := TMSRegDca(DTQ->DTQ_ROTA)
	If !Empty(aRet)
		cCdrOri := aRet[1,1]
	EndIf
EndIf	
//-- Calcula a composicao do frete, baseado na tabela de frete informada
aFrete:= {}
aFrete:= TmsCalFret(	M->DTV_TABFRE	,;
						M->DTV_TIPTAB	,;
										,;
						cCdrOri			,;
						M->DTV_CDRDES	,;
						M->DTV_CODCIA	,;
						M->DTV_LOJCIA	,;
						M->DTV_CODPRO	,;
										,;
										,;
										,;
										,;
						@aMsgErr		,;
										,;
						M->DTV_VALMERC	,;
						Max(M->DTV_PESO,M->DTV_PESOM3),;
						0				,;
						0				,;
						M->DTV_QTDVOL	,;
										,,,,,,,,,,,,,,,,,,,;
						M->DTV_PESO		,;
						M->DTV_PESOM3	,;
										,;
						M->DTV_VALMER	,;
						M->DTV_QTDVOL	,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,;
						M->DTV_FILORI   ,;
						M->DTV_VIAGEM)

nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })

If	Empty( nSeek ) .Or. Empty( aFrete[ nSeek, 2 ] ) .Or. nSeek != Len(aFrete)
	Return NIL
EndIf

//-- Executa calculo do frete
nSeek := Ascan( aFrete,{|x| x[3] == 'TF' })
If nSeek > 0
	nFrtCal := aFrete[nSeek,2]
	If nFrtAWB > nFrtCal
		nPercen := (nFrtCal / nFrtAWB) * 100
		If nPercen > nPtoAWB
			cStaFin := '2' //-- Faturamento bloqueado
		EndIf
	EndIf
EndIf

cQuery := "SELECT SUM(DT6.DT6_VALFRE) VALDT6 "
cQuery += "  FROM " + RetSqlName("DTX") + " DTX "
cQuery += "  JOIN " + RetSqlName("DUD") + " DUD "
cQuery += "    ON DUD.DUD_FILIAL  = '" + xFilial("DUD") + "' "
cQuery += "   AND DUD.DUD_FILORI  = DTX.DTX_FILORI "
cQuery += "   AND DUD.DUD_VIAGEM  = DTX.DTX_VIAGEM "
cQuery += "   AND DUD.DUD_MANIFE  = DTX.DTX_MANIFE "
If lDTX_SERMAN
	cQuery += "   AND DUD.DUD_SERMAN  = DTX.DTX_SERMAN "
EndIf
cQuery += "   AND DUD.D_E_L_E_T_  = ' ' "
cQuery += "  JOIN " + RetSqlName("DT6") + " DT6 "
cQuery += "    ON DT6.DT6_FILIAL  = '" + xFilial("DT6") + "' "
cQuery += "   AND DT6.DT6_FILDOC  = DUD.DUD_FILDOC "
cQuery += "   AND DT6.DT6_DOC     = DUD.DUD_DOC "
cQuery += "   AND DT6.DT6_SERIE   = DUD.DUD_SERIE "
cQuery += "   AND DT6.D_E_L_E_T_  = ' ' "
cQuery += " WHERE DTX.DTX_FILIAL  = '" + xFilial("DTX")  + "' "
cQuery += "   AND DTX.DTX_FILMAN  = '" + DTV->DTV_FILORI + "' "
cQuery += "   AND DTX.DTX_NUMAWB  = '" + DTV->DTV_NUMAWB + "' "
If lAWBRepete
	cQuery += "   AND DTX.DTX_CODCIA = '" + DTV->DTV_CODCIA  + "' AND DTX.DTX_LOJCIA ='" + DTV->DTV_LOJCIA +"' "	   
	cDigito := TMSA320Dig(DTV->DTV_DATEMI,DTV->DTV_DIGAWB)
	If lDTX_DIGAWB .And. Len(cDigito) > 0
		cQuery += "   AND DTX.DTX_DIGAWB = '" + cDigito + "' "
	EndIf
Endif
cQuery += "   AND DTX.D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
If (cAliasQry)->(!Eof())
	nValFre := (cAliasQry)->VALDT6
EndIf
(cAliasQry)->(dbCloseArea())

nRentab := Round((nFrtAWB / nValFre) * 100,2)
If nFrtAWB > nValFre
	nRentab:= nRentab * -1
EndIf
RecLock('DTV',.F.)
DTV->DTV_PICM   := nAlqICM
DTV->DTV_VAWBLQ := nFrtAWB
DTV->DTV_VAWB   := nValTot
DTV->DTV_VCALC  := nFrtCal
DTV->DTV_VALFRE := nValFre
DTV->DTV_RENTAB := nRentab
DTV->DTV_STAFIN := cStaFin
MsUnLock()

RestArea(aArea)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA320Awb ºAutor  ³ Richard Anderson º Data ³  04/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna numero do documento a partir do numero da AWB      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGATMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA320Awb ºAutor  ³ Richard Anderson º Data ³  04/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna numero do documento a partir do numero da AWB      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGATMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA320Awb( cNumAWB, cDigAWB, lLocaliza, cCodCia, cLojCia, dData )
Local cFilSF1	:= ""
Local cDoc		:= ""
Local cSerie	:= ""
Local nTent		:= 0
Local bCondSF1	:= {||SF1->(dbSeek(cFilSF1+cDoc+cSerie+DTV->(DTV_CODCIA+DTV_LOJCIA)))}
Local cSeekDTV	:= ""
Local aAreaAtu	:= GetArea()
Local aAreaSF1	:= SF1->(GetArea())
Local aAreaDTV	:= DTV->(GetArea())
Local dDataINI	:= CTOD(SubStr(GetMV("MV_AWBINI"),1,At('|',GetMV("MV_AWBINI"))-1))
Local cHoraINI	:= SubStr(GetMV("MV_AWBINI"),At('|',GetMV("MV_AWBINI"))+1,Len(GetMV("MV_AWBINI")))
Local lAWBAnt	:= .F.
Local dDatEmi	:= Ctod("")
Local cHorEmi	:= ""

Default lLocaliza := .F.
Default cCodCia   := ""
Default cLojCia   := ""
Default dData     := CtoD("")

If lLocaliza
	bCondSF1 := {||SF1->(!dbSeek(cFilSF1+cDoc+cSerie+DTV->(DTV_CODCIA+DTV_LOJCIA)))}
EndIf

If !Empty(cCodCia)
	cSeekDTV := xFilial('DTV')+cNumAWB+TMSA320Dig(dData,cDigAWB)+cCodCia+cLojCia
Else
	cSeekDTV := xFilial('DTV')+cNumAWB
EndIf
DTV->(dbSetOrder(1))
If DTV->(dbSeek(cSeekDTV))
	If DTV->DTV_BALCAO == '1' .And. !Empty(DTV->DTV_DATEFE)
		dDatEmi := DTV->DTV_DATEFE
		cHorEmi := DTV->DTV_HOREFE
	Else
		dDatEmi := DTV->DTV_DATEMI
		cHorEmi := DTV->DTV_HOREMI
	EndIf
	If dDatEmi < dDataINI
		lAWBAnt := .T.
	ElseIf dDatEmi == dDataINI .And. cHorEmi <= cHoraINI
		lAWBAnt := .T.
	EndIf
ElseIf TamSX3('F1_DOC')[1] == 6
	lAWBAnt := .T.
EndIf

If lAWBAnt
	//-- Compatibiliza com o tamanho da versão 811
	cNumAWB := Padr(cNumAWB,7)
	If Substr(cNumAWB,1,1) == '0'
		cDoc   := Padr(Right(cNumAWB,6),Len(SF1->F1_DOC))
		cSerie := Padr(cDigAWB,Len(SF1->F1_SERIE))
		If DTV->(MsSeek(cSeekDTV))
			SF1->(dbSetOrder(1))
			cFilSF1 := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
			For nTent := 1 To 2
				If Eval(bCondSF1)
					If nTent == 1
						cDoc   := PadR(Left(cNumAWB,6),Len(SF1->F1_DOC))
						cSerie := PadR(Right(cNumAWB,1),Len(SF1->F1_SERIE))
					Else
						cDoc   := PadR(Left(cNumAWB,6),Len(SF1->F1_DOC))
						cSerie := PadR(Right(cNumAWB,1)+cDigAWB,Len(SF1->F1_SERIE))
					EndIf
				Else
					Exit
				EndIf
			Next nTent
		EndIf
	ElseIf Empty(Right(cNumAWB,1))
		cDoc   := PadR(Left(cNumAWB,6),Len(SF1->F1_DOC))
		cSerie := PadR(Right(cNumAWB,1),Len(SF1->F1_SERIE))
	Else
		cDoc   := PadR(Left(cNumAWB,6),Len(SF1->F1_DOC))
		cSerie := PadR(Right(cNumAWB,1)+cDigAWB,Len(SF1->F1_SERIE))
		If DTV->(MsSeek(xFilial('DTV')+cSeekDTV))
			SF1->(dbSetOrder(1))
			cFilSF1 := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
			If Eval(bCondSF1)
				cDoc   := PadR(Left(cNumAWB,6),Len(SF1->F1_DOC))
				cSerie := PadR(Right(cNumAWB,1),Len(SF1->F1_SERIE))
			EndIf
		EndIf
	EndIf
Else
	cDoc   := PadR(cNumAWB,Len(SF1->F1_DOC))
	cSerie := PadR(cDigAWB,Len(SF1->F1_SERIE))
EndIf

RestArea(aAreaDTV)
RestArea(aAreaSF1)
RestArea(aAreaAtu)

Return { cDoc, cSerie } 


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA320VlrºAutor ³ Jose Luiz Pinheiro Jr.º Data ³ 27/05/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o valor liquido e bruto da AWB.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGATMS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA320Vlr( cFilOri, cNumAWB, cDigAWB, cCodCia, cLojCia ) 
Local cAliasQry := GetNextAlias()
Local nValFre   := 0
Local nValTot   := 0
Local cQuery    := ''

cQuery := "Select Sum(D1_CUSTO) AS VALFRE, Sum(D1_BASEICM) AS VALTOT "
cQuery += "  FROM " + RetSqlName("SD1") + " D1 "
cQuery += " WHERE D1_FILIAL = '"  + cFilOri + "' "
cQuery += "   AND D1_DOC = '"     + cNumAwb + "' "
cQuery += "   AND D1_SERIE = '"   + cDigAwb + "' "
cQuery += "   AND D1_FORNECE = '" + cCodCia + "' "
cQuery += "   AND D1_LOJA = '"    + cLojCia + "' "
cQuery += "   AND D_E_L_E_T_ = ' ' "
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)
TcSetField(cAliasQry,"VALFRE","N",TamSX3("DT6_VALTOT")[1],TamSX3("DT6_VALTOT")[2])
TcSetField(cAliasQry,"VALTOT","N",TamSX3("DT6_VALTOT")[1],TamSX3("DT6_VALTOT")[2])
If (cAliasQry)->(!Eof())
	nValFre := (cAliasQry)->VALFRE
	nValTot := (cAliasQry)->VALTOT
	If Empty(nValTot)
		nValTot := nValFre
	EndIf
EndIf
(cAliasQry)->(dbCloseArea())

Return { nValFre, nValTot }

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ChkF1Nfe ºAutor  ³ Richard Anderson   º Data ³  04/08/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica a existencia de nota fiscal de entrada com o      º±±
±±º          ³ numero informado                                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cDoc        : No. documento                                º±±
±±º          ³ cSerie      : Serie do documento                           º±±
±±º          ³ cCodFor     : Fornecedor                                   º±±
±±º          ³ cLojFor     : Loja                                         º±±
±±º          ³ cFormul     : Tipo do formulario ('S' - Proprio, 'N' - Ext)º±±
±±º          ³ lHelp       : Exibe help?                                  º±±
±±º          ³ cMsg        : Mensagem para o Help                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ EAL                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ChkF1Nfe( cFilOri, cDoc, cSerie, cCodFor, cLojFor, cFormul, lHelp, cMsg )

Local   aArea   := GetArea()
Local   aAreaSF1:= SF1->(GetArea())
Local   cQuery  := ""
Local   lRet    := .T.
Default cFilOri := Iif(Empty(xFilial('SF1')),xFilial('SF1'),DTV->DTV_FILORI)
Default cDoc    := ""
Default cSerie  := ""
Default cCodFor := ""
Default cLojFor := ""
Default cForMul := "N"
Default lHelp   := .T.
Default cMsg    := STR0039 //"Número informado já está em uso para este fornecedor"


cQuery := " SELECT COUNT(*) SF1NOTA"
cQuery += "   FROM "+RetSqlName("SF1")+" SF1 "
cQuery += "  WHERE SF1.F1_FILIAL  = '"+cFilOri+"'"
cQuery += "    AND SF1.F1_DOC     = '"+cDoc   +"'"
cQuery += "    AND SF1.F1_SERIE   = '"+cSerie +"'"
cQuery += "    AND SF1.F1_FORMUL  IN ('"+Space(Len(SF1->F1_FORMUL))+"','"+cForMul+"')"
If !Empty(cCodFor)
	cQuery += " AND SF1.F1_FORNECE = '"+cCodFor+"'"
EndIf
If !Empty(cLojFor)
	cQuery += " AND SF1.F1_LOJA    = '"+cLojFor+"'"
EndIf
cQuery += "    AND SF1.D_E_L_E_T_ = ' '"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CHKF1NOTA",.T.,.T.)
If CHKF1NOTA->SF1NOTA > 0
	If lHelp
		MsgAlert(cMsg)
	EndIf
	lRet := .F.
EndIf
dbCloseArea()
RestArea(aAreaSF1)
RestArea(aArea)
Return( lRet )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Ciaº Autor ³ Jose Luiz Pinheiro Jrº Data ³ 07/Abr/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Consulta Padrao Utilizada Para visualizar Cia Aereas       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320SA2(lCancel,lPesq,lRastre)
Local cAliasQry  := 'SA2CIA'
Local cQuery     := ''
Local aAreaAtu   := GetArea()
Local aCabec     := {}
Local lRet       := .T.
Local nRet       := 0
Local cCadastro  := STR0067 //"Escolha a Cia Aerea"
Local aNewButton := {}
Local cSegAtiv   := SuperGetMv("MV_SATVGER",,"") //-- Segmento de atividade do fornecedor   
Local aColOfusca := {}
Local aCpoAccess := {'A2_COD', 'A2_LOJA', 'A2_NOME'}
Local aCpoAccNew := {}
Local aUsrAcsPFl := {}
Local nCountCpo	 := 0
Local lLGPD		 := ExistFunc('FWPDCanUse') .And. FWPDCanUse(.T.)

Private aCia    := {}
Private aTitulo := {}

Default lCancel := .T.
Default lPesq   := .T.
Default lRastre := .F.

Aadd( aTitulo, RetTitle('A2_COD' ) )
Aadd( aTitulo, RetTitle('A2_LOJA') )
Aadd( aTitulo, RetTitle('A2_NOME') )

If lPesq
	aCabec := aClone(aTitulo)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Certifico de que o SA2CIA esta fechado.                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Select(cAliasQry)<>0)
	dbSelectArea(cAliasQry)
	dbCloseArea()
EndIf
	
cQuery := ''
cQuery += " SELECT A2_COD, A2_LOJA, A2_NOME, SA2.R_E_C_N_O_ RECNOSA2 "
cQuery += " FROM " + RETSQLNAME('SA2') + " SA2 "

cQuery += " WHERE A2_FILIAL  = '" + xFilial('SA2') + "' AND SA2.D_E_L_E_T_ = ' ' "
If lRastre  
	cQuery += " AND A2_SATIV1 IN ('" +	StrTran(cSegAtiv,";",",") + "'  )" 
	cCadastro := STR0068 //"Escolha o Fabricante do Rastreador"
Else
	cQuery += "AND A2_TIPAWB <> ' ' "
EndIf
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TopConn", TCGenQry(,,cQuery), cAliasQry, .T., .T. )
While (cAliasQry)->(!Eof())
	Aadd(aCia,{ (cAliasQry)->A2_COD, (cAliasQry)->A2_LOJA, (cAliasQry)->A2_NOME,(cAliasQry)->RECNOSA2 })
	(cAliasQry)->(dbSkip())
EndDo
(cAliasQry)->(dbCloseArea())

RestArea(aAreaAtu)

If Len(aCia) > 0

	//--A partir dos campos protegidos verifica quais o usuario possui acesso
	If llGPD .And. ExistFunc('TMLGPDCpPr')
		aCpoAccNew := TMLGPDCpPr(aCpoAccess,'SA2') //--Campos protegidos e que são apresentados na rotina.
		aUsrAcsPFl := FwProtectedDataUtil():UsrAccessPDField( __CUSERID, aCpoAccNew ) //--Campos protegidos usados na rotina e que o usuário possue acesso

		//--Monta Array com as colunas que nao serao exibidas devido ao acesso do usuario
		If Len(aCpoAccNew) > 0
			For nCountCpo := 1 To Len(aCpoAccess)
				If Ascan( aCpoAccNew, { |x|  AllTrim(x) == aCpoAccess[nCountCpo] } ) == 0
					AADD(aColOfusca,.F.)
				Else
					If Ascan( aUsrAcsPFl, { |x|  AllTrim(x) == aCpoAccess[nCountCpo] } ) == 0
						AADD(aColOfusca,.T.)
					Else
						AADD(aColOfusca,.F.)
					EndIf
				EndIf	
			Next nCountCpo
		EndIf	
	EndIf

	AAdd(aNewButton, {15,{|nAt| TmsA320Vis(aCia[nAt,Len(aTitulo)+1],'SA2') } } )

	nRet := TmsF3Array( aTitulo, aCia, cCadastro, lCancel, aNewButton,aCabec, aColOfusca ) 

	If !Empty(nRet)
		SA2->(dbGoTo(aCia[nRet,Len(aTitulo)+1]))
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Visº Autor ³ Jose Luiz Pinheiro Jrº Data ³ 07/Abr/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para visualizar o cadastro de fornecedor            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function TmsA320Vis(nR,cA)
Local nRecno := nR
Local cAlias := cA
Local bInclui:= Inclui

If !Empty(cAlias) .And. nRecno > 0
	If cAlias == 'SA2'
		&(cAlias)->(dbGoTo(nRecno))
		AxVisual(cAlias,&(cAlias+"->(Recno())"),2)
	Else
		&(cAlias)->(dbGoTo(nRecno))
		Inclui := .F.
		TMA910Mnt(cAlias, nRecno, 2)
		Inclui := bInclui
	EndIf
Endif

//TMA910Mnt(cAlias, nReg, nOpcx)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If "MP8" $ oApp:cVersion
	If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
	EndIf
EndIf
Return Int(nTam)
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Sixº Autor ³ Jose Luiz Pinheiro Jrº Data ³ 07/Abr/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para validar o uso do novo Indice do AWB            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320Six()
Local lRet      := .T.
Local aAreaSix  := SIX->(GetArea())

SIX->(dbSetOrder(1))
If !( SIX->(dbSeek("DTV1")) .And. "DTV_DIGAWB" $ SIX->CHAVE )
	lRet := .F.
EndIf

RestArea(aAreaSix)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TMSA320Digº Autor ³ Jose Luiz Pinheiro Jrº Data ³ 07/Abr/09 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para validar e retornar se usa ou nao digito do AWB.º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320Dig(dDtRef,cDig)
Local cRet      := ''
Local dDtAWBDig := GetMv("MV_AWBDIG",.F.,CtoD(''))

Default dDtRef := CToD('')
Default cDig   := ''

If Type( 'lAWBDigito' ) == 'U'
	lAWBDigito := TMSA320Six()
EndIf

If lAWBDigito
	If /*!Empty(dDtRef) .And.*/ dDtRef >= dDtAWBDig 
		cRet := PadR(cDig,Len(DTV->DTV_DIGAWB))
	EndIf
EndIf

//-- Caso o retorno seja vazio, significa que nao é para utilizar o digito na chave de pesquisa do DTV,
//-- caso constrario, o retorno sera o proprio digito passado na chamada da função.
Return cRet
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA320Cfe º Autor ³ Gustavo Almeida    ºData ³ 11/05/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Apontamento de Confirmação de Embarque.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP 11.5                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320Cfe()
Local aArea   := { GetArea() , DTQ->(GetArea()) }
Local nX      := 0
Local aCab    := {}
Local aItens  := {}
Local cOcoCfe := PadR(SuperGetMv('MV_OCORCFE',,""), TamSx3('DUA_CODOCO')[1])

Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

If Alltrim(DTV->DTV_FILORI) <> Alltrim(cFilAnt)
	Help("", 1, "TMSA32023") // Não é possivel confirmar embarque em filial diferente da filial de origem da viagem
	Return Nil
EndIf 

If (DTV->DTV_BALCAO == '2' .Or. (DTV->DTV_BALCAO == '1' .And. !Empty(DTV->DTV_DATEFE) ))
	//-- Verifica se já há reg de confirmação de embarque com pre-alerta
	DY8->(dbSetOrder(2))//DY8_FILIAL+DY8_NUMAWB+DY8_DIGAWB+DY8_CODCIA+DY8_LOJCIA+DY8_STATUS
	If	DY8->(MsSeek(xFilial('DY8')+DTV->DTV_NUMAWB+DTV->DTV_DIGAWB+DTV->DTV_CODCIA+DTV->DTV_LOJCIA+"1")) .Or. ;
		DY8->(MsSeek(xFilial('DY8')+DTV->DTV_NUMAWB+DTV->DTV_DIGAWB+DTV->DTV_CODCIA+DTV->DTV_LOJCIA+"2"))
		MsgAlert(STR0051,STR0038)//"Esta AWB já possui confirmação de embarque"###"Atenção"
	Else
		DTQ->(dbSetOrder(2))
		If	DTQ->(MsSeek(xFilial('DTQ')+DTV->DTV_FILORI+DTV->DTV_VIAGEM))
			//-- Cabecalho da Ocorrencia
			AAdd(aCab  , {"DUA_FILORI",DTV->DTV_FILORI,Nil})
			AAdd(aCab  , {"DUA_VIAGEM",DTV->DTV_VIAGEM,Nil})
			//-- Itens da Ocorrencia
		 	AAdd(aItens, {	{"DUA_SEQOCO", StrZero(1,TamSx3('DUA_SEQOCO')[1]), Nil},;
										{"DUA_DATOCO", dDatabase                          , Nil},;
										{"DUA_HOROCO", Left(StrTran(Time(),":",""),4)    , Nil},;
										{"DUA_CODOCO", cOcoCfe                            , Nil}})
							 
			MsExecAuto({|w,x,y,z|Tmsa360(w,x,y,z)},aCab,aItens,{},3)
			If lMsErroAuto
				MostraErro()
			EndIf
		EndIf
	EndIf
Else
	MsgAlert(STR0052,STR0038)//"Não é permitido apontamento de Confirmação de Embarque para AWB Provisória"###"Atenção"
EndIf

For nX := 1 To Len(aArea)
	RestArea(aArea[nX])
Next nX

Return NIL
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TMSA320Cae º Autor ³ Gustavo Almeida    ºData ³ 03/06/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Rotina de Cancelamento de confirmação de Embarque.         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³AP 11.5                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TmsA320Cae()
Local   aArea
Local   nX          := 0
Local   aCab        := {}
Local   aItens      := {}
Local   dDatEmb   := Ctod('')
Local   cHorPar   := ""
Local	 dDatChg   := ""
Local	 cHorChg   := ""
Local	 cNumVoo   := ""
Private lMsHelpAuto := .T.
Private lMsErroAuto := .F.

//Verifica a versão se é 11.5
If !FindFunction('TMSChkVer') .And. !TMSChkVer('11','R5')
	lMsHelpAuto := .F.
	Aviso(STR0063, STR0064 + Chr(10)+Chr(13) + STR0065, {STR0066}, 1) //"Versão Protheus" "Versão do sistema atual é inferior a 11.5" "Atualize o sistema!" "Ok"
	Return Nil
EndIf

If Alltrim(DTV->DTV_FILORI) <> Alltrim(cFilAnt)
	Help("", 1, "TMSA32024") // Não é possivel cancelar a confirmação de embarque em filial diferente da filial de origem da viagem
	Return Nil
EndIf 

aArea := { GetArea() , DTQ->(GetArea()) }

If MsgYesNo(STR0058+DTV->DTV_NUMAWB+"-"+DTV->DTV_DIGAWB+"?",STR0059)//"Deseja cancelar a confirmação de embarque para a AWB:"###"Cancelar Confirmação de Embarque"
	//-- Verifica se há pré-alerta
	DY8->(dbSetOrder(2))//DY8_FILIAL+DY8_NUMAWB+DY8_DIGAWB+DY8_CODCIA+DY8_LOJCIA+DY8_STATUS
	If	DY8->(MsSeek(xFilial('DY8')+DTV->DTV_NUMAWB+DTV->DTV_DIGAWB+DTV->DTV_CODCIA+DTV->DTV_LOJCIA+"1")) .Or. ;
		DY8->(MsSeek(xFilial('DY8')+DTV->DTV_NUMAWB+DTV->DTV_DIGAWB+DTV->DTV_CODCIA+DTV->DTV_LOJCIA+"2"))

		//-- MSexecAuto Estorno de Reg. Ocorrencia
		//--DUA_FILIAL+DUA_FILOCO+DUA_NUMOCO+DUA_FILORI+DUA_VIAGEM+DUA_SEQOCO                                                                                               
		DUA->(dbSetOrder(1))
		DUA->(MsSeek(xFilial('DUA')+DY8->DY8_FILOCO+DY8->DY8_NUMOCO+DY8->DY8_FILOCO))

		//-- Cabecalho da Ocorrencia
		Aadd(aCab,{"DUA_FILOCO",DUA->DUA_FILOCO,NIL})
		Aadd(aCab,{"DUA_NUMOCO",DUA->DUA_NUMOCO,NIL})
		Aadd(aCab,{"DUA_FILORI",DUA->DUA_FILORI,NIL})
		Aadd(aCab,{"DUA_VIAGEM",DUA->DUA_VIAGEM,NIL})
		
		//-- Itens da Ocorrencia
		
		While DUA->(!Eof()) .And. xFilial('DUA')+DY8->DY8_FILOCO+DY8->DY8_NUMOCO+DY8->DY8_FILOCO == DUA->DUA_FILIAL+DUA->DUA_FILOCO+DUA->DUA_NUMOCO+DUA->DUA_FILOCO
			Aadd(aItens,{	{"DUA_SEQOCO", DUA->DUA_SEQOCO , NIL},;
								{"DUA_ESTOCO", StrZero( 1, TamSX3('DUA_ESTOCO')[1]), NIL},;
								{"DUA_DATOCO", DUA->DUA_DATOCO , NIL},;
								{"DUA_HOROCO", DUA->DUA_HOROCO , NIL},;
								{"DUA_CODOCO", DUA->DUA_CODOCO , NIL},;
								{"DUA_SERTMS", DUA->DUA_SERTMS , NIL},;
								{"DUA_FILDOC", DUA->DUA_FILDOC , NIL},;
								{"DUA_DOC"   , DUA->DUA_DOC    , NIL},;
								{"DUA_SERIE" , DUA->DUA_SERIE  , NIL},;
								{"DUA_QTDOCO", DUA->DUA_QTDOCO , NIL},;
								{"DUA_PESOCO", DUA->DUA_PESOCO , NIL}})
			DUA->(DbSkip()) 
		EndDo
		
		//-- Estorno da Ocorrencia
		MsExecAuto({|w,x,y,z|Tmsa360(w,x,y,z)},aCab,aItens,{},6)

		If lMsErroAuto
			MostraErro()
		EndIf
		If !lMsErroAuto
			RecLock("DY8",.F.)
			DY8->DY8_STATUS := ""
			MsUnLock()

			DTQ->(DbSetOrder(2))
			DTQ->(DbSeek(xFilial('DTQ')+DTV->DTV_FILORI+DTV->DTV_VIAGEM)) 
			//-- Embarque Aereo					
			If DTQ->DTQ_TIPTRA == StrZero(2,Len(DTQ->DTQ_TIPTRA))
				DVH->(DbSetOrder(1))
					If DVH->(DbSeek(xFilial("DVH")+DTV->DTV_FILORI+DTV->DTV_VIAGEM+DY8->DY8_FILOCO+DY8->DY8_NUMOCO))
						dDatEmb := DVH->DVH_DATPAR
						cHorPar := DVH->DVH_HORPAR
						dDatChg := DVH->DVH_DATCHG
						cHorChg := DVH->DVH_HORCHG
						cNumVoo := DVH->DVH_NUMVOO
						RecLock("DVH",.F.)
						dbDelete()
						MsUnLock()
							
						If FindFunction('TMSChkVer') .And. TMSChkVer('11','R5')
							TMSA360Pre(4,DY8->DY8_FILOCO+DY8->DY8_NUMOCO,DTV->DTV_FILORI+DTV->DTV_VIAGEM,dDatEmb,cHorPar,dDatChg,cHorChg,cNumVoo)
						EndIf	
					EndIf
			EndIf
		
		EndIf
	Else
		MsgAlert(STR0060,STR0038)//"Esta AWB não possui confirmação de embarque para ser cancelada"###"Atenção"
	EndIf
EndIf

For nX := 1 To Len(aArea)
	RestArea(aArea[nX])
Next nX

Return NIL
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TMSA320Rel ³ Autor ³  Gustavo Almeida      ³ Data ³ 12/05/2011 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³X3_RELACAO                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TMSA320Rel(ExpC1)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Campo                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSA320Rel(cCampo)

Local cRet     := ""
Local aAreaDTV := DTV->(GetArea())

Default cCampo := ReadVar()

//-- Utilizado em Confirmação de Embarque via Geração de AWB
DTV->(DbSetOrder(2))
If DTV->(MsSeek(xFilial("DTV")+M->(DUA_FILORI+DUA_VIAGEM)))
	If "DVH_NUMVOO" $ cCampo
		cRet := DTV->DTV_NUMVOO
	ElseIf "DVH_NUMAWB" $ cCampo
		cRet := DTV->DTV_NUMAWB
	ElseIf "DVH_DIGAWB" $ cCampo
		cRet := DTV->DTV_DIGAWB
	ElseIf "DVH_NUMVOO" $ cCampo
		cRet := DTV->DTV_NUMVOO
	EndIf
EndIf

RestArea(aAreaDTV)
Return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Jose Luiz Pinheiro Jr ³ Data ³11/03/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
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
Local aSubMenu  := {	{ STR0061 ,"TMSA320Cfe",0,8,0,NIL},; //"Confirmar"
						{ STR0062 ,"TMSA320Cae",0,9,0,NIL} } //"Cancelar"

Private aRotina := {	{ STR0002,"AxPesqui"  ,0,1,0,.F.},; //"Pesquisar"
						{ STR0003,"TMSA320Mnt",0,2,0,NIL},; //"Visualizar"
						{ STR0004,"TMSA320Mnt",0,3,0,NIL},; //"Incluir"
						{ STR0005,"TMSA320Mnt",0,5,0,NIL},; //"Estornar"
						{ STR0006,"U_RTMSR08" ,0,6,0,NIL},; //"Imprimir"
						{ STR0033,"TMSA320Efe",0,7,0,NIL},; //"Efetivar"
						{ STR0069,"TM320EstEf",0,9,0,NIL},; //"Altera Efetivação?"
						{ STR0057, aSubMenu   ,0,8,0,NIL} } //"Conf. Embarque"

If ExistBlock("TM320MNU")
	ExecBlock("TM320MNU",.F.,.F.)
EndIf

Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³TM320EstEf Autor³Fabio Marchiori Sampaioº Data³ 16/05/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao que Estorna a Efetivação do AWB Balção			    º±±
±±º          ³ 			                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ TMSA320                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function TM320EstEf(cAlias, nReg, nOpcx)

Local cCondPag	:= ""
Local cEstado		:= ""
Local aDocto		:= {}
Local aDoc			:= {}
Local cTesAWB		:= ""
Local lRet			:= .T.
Local cOriFun		:= 'TM320EstEf'

If !Empty(DTV->DTV_NUMORI)
	If MsgYesNo(STR0072) //Tem certeza que deseja alterar um valor já efetivado?
		//-- Fornecedor
		SA2->(dbSeek(xFilial('SA2')+DTV->DTV_CODCIA+DTV->DTV_LOJCIA))
		cCondPag  := SA2->A2_COND
		cEstado   := SA2->A2_EST
	
		aDoc   := TMSA320Awb( DTV->DTV_NUMAWB, DTV->DTV_DIGAWB, .T., DTV->DTV_CODCIA, DTV->DTV_LOJCIA, DTV->DTV_DATEMI )
		aDocto := {}
		AAdd(aDocto,Posicione('DUI',1,xFilial('DUI')+'3','DUI_CODPRO'))	//-- 1 Produto
		AAdd(aDocto,aDoc[1])														//-- 2 Docto
		AAdd(aDocto,aDoc[2])														//-- 3 Serie
		AAdd(aDocto,DTV->DTV_CODCIA)											//-- 4 Cliente/Fornecedor
		AAdd(aDocto,DTV->DTV_LOJCIA)											//-- 5 Loja do Cliente/Fornecedor
		AAdd(aDocto,0)															//-- 6 Volume
		AAdd(aDocto,0)															//-- 7 Valor da mercadoria
		AAdd(aDocto,'')															//-- 8 Condicao de pagamento
		AAdd(aDocto,'')															//-- 9 Especie
		AAdd(aDocto,0)															//--10 Aliquota ICM
		AAdd(aDocto,'N')															//--11 Tipo da nota
		AAdd(aDocto, cTesAWB)													//--12 TES da AWB
		AAdd(aDocto, cEstado)													//--13 Estado Fornecedor
	
		//-- Estornar documento de entrada
		If !TmsA320NFE(aDocto,5)
			lRet := .F.
		EndIf
		If lRet
			If TMSA320Efe(, , , cOriFun)
			   MsgAlert(STR0070) //Valor alterado com sucesso !!
			EndIf
		EndIf
	EndIf
Else
	MsgAlert(STR0071) //Documento ainda não foi efetivado !!
EndIf

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} AtuTabSDG
Atualiza SDG
@type Function
@author CAio Murakami
@since 10/06/2021
@version 12.1.30
@param
@return lRet
*/
//------------------------------------------------------------------
Static Function AtuTabSDG( aCab , nOpc )
Local nCount	:= 1 
Local lExclui	:= .F. 
Local aArea		:= GetArea()

Default aCab	:= {}
Default nOpc	:= 3 

If FindFunction("TMSA070Aut")
	TMSA070Aut( aCab , nOpc )
Else 

	If nOpc == 3 
		RecLock("SDG",.T.)
	ElseIf nOpc == 4 .Or. nOpc == 5 
		RecLock("SDG",.F.)
		If nOpc == 5 
			lExclui	:= .T. 
		EndIf 
	EndIf 

	If lExclui
		SDG->(DbDelete())
	Else	
		For nCount := 1 To Len(aCab )
			SDG->&(aCab[nCount,1])	:= aCab[nCount,2]
		Next nCount 
	EndIf 

	SDG->(MsUnlock())
EndIf 

RestArea(aArea)
Return 
