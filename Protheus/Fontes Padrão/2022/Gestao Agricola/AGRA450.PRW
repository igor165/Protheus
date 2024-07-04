#include 'AGRA450.CH'
#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA450  บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Cadastro de abastecimentos e manutencoes dos equipamentos. บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA450()
Private cCadastro := STR0001 //"Transferencias"
Private aRotina   := MenuDef()
Private aCores    := {;
					 {'AllTrim(DToS(NQT->NQT_DTORIG))  = "" .And. AllTrim(DToS(NQT->NQT_DTDEST))  = ""' ,'BR_VERDE'   },;
					 {'AllTrim(DToS(NQT->NQT_DTORIG)) <> "" .And. AllTrim(DToS(NQT->NQT_DTDEST))  = ""' ,'BR_AZUL'    },;
                     {'AllTrim(DToS(NQT->NQT_DTORIG))  = "" .And. AllTrim(DToS(NQT->NQT_DTDEST)) <> ""' ,'BR_PRETO'   },;
                     {'AllTrim(DToS(NQT->NQT_DTORIG)) <> "" .And. AllTrim(DToS(NQT->NQT_DTDEST)) <> ""' ,'BR_VERMELHO'} ;
                     }

dbSelectArea('NQT')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NQT', Nil, Nil, Nil, Nil, Nil, aCores)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA450A บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA450A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nY       := 0

Private aGets  := Array(0)
Private aTela  := Array(0,0)
Private oDlg
Private oEnch

If nOpcX==4 .Or. nOpcX==5
	If .Not. Empty(NQT->NQT_DTORIG) .Or. .Not. Empty(NQT->NQT_DTDEST)
		Alert('Ja existe movimento para esta transferencia!')
		Return(.t.)
	EndIf
EndIf

RegToMemory('NQT',(nOpcX==3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NQT',nReg,nOpcX,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT

Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA:=1, IIf(AGRA450B(nOpcX), oDlg:End(), nOpcA:=0) } , {|| nOpcA:=0, oDlg:End() })

If nOpcA==1 .And. (nOpcX==3 .Or. nOpcX==4 .Or. nOpcX==5)

	Begin Transaction
	dbSelectArea('NQT')
	dbSetOrder(1)
	//dbSeek(xFilial('NQT')+M->NQT_DOC+M->NQT_SEQ)
	If nOpcX==3 //Inclusใo
		If .Not. dbSeek(xFilial('NQT')+M->NQT_DOC+M->NQT_SEQ)
			If RecLock('NQT',.t.)
				For nY := 1 To FCount()
					&(FieldName(nY)) := &('M->'+FieldName(nY))
				Next nY
				NQT->NQT_FILIAL := xFilial('NQT')
				msUnLock()
			EndIf
			If __lSX8
				ConfirmSX8()
			EndIf
		Else
			Alert('Esta transferencia NAO foi gravada. Duplicidade de Sequencia!!!')
		EndIf
	EndIf
	If nOpcX==4 //Aletra็ใo
		If RecLock('NQT',.f.)
			For nY := 1 To FCount()
				&(FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			msUnLock()
		EndIf
	EndIf
	If nOpcX==5 //Exclusใo
		If RecLock('NQT',.f.)
			dbDelete()
			msUnLock()
		EndIf
	EndIf
	End Transaction

Else
	If nOpcX==3
		If __lSX8
			RollBackSX8()
		EndIf
	EndIf
EndIf

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA450B บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para validar a tela de cadastro.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA450B(nOpcX)
Local lRetorno := .t.

If nOpcX==3 .Or. nOpcX==4
	lRetorno := Obrigatorio(aGets,aTela)
EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA450E บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para validar a tela de cadastro.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA450E(nOpcX)
Local lRetorno := .t.
Local dDtSai   := dDataBase
Local cTMSai   := Space(3)
Local cTrans   := Space(15)
Local cItens   := Space(5)
Local cCodNQT  := NQT->NQT_DOC
Local cSeqINI  := NQT->NQT_SEQ
Local cSeqFIM  := NQT->NQT_SEQ
Local nZ       := 0
Local nAcao    := 0
Local aMata240 := Array(0,0)
Local oDlg,oSay0,oSay1,oSay2,oSay3,oSay4,oGet1,oGet2,oGet3,oCmb1,oSBtn1,oSBtn2

Private lMsErroAuto := .f.

If .Not. Empty(NQT->NQT_DTORIG)
	Alert('Este produto ja foi enviado...')
	Return(.t.)
EndIf

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := "Envio de Produtos"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 276
oDlg:nHeight := 200
oDlg:lShowHint := .F.
oDlg:lCentered := .F.

oSay0 := TSAY():Create(oDlg)
oSay0:cName := "oSay0"
oSay0:cCaption := "Confirma data de envio do produto."
oSay0:nLeft := 21
oSay0:nTop := 23
oSay0:nWidth := 205
oSay0:nHeight := 17
oSay0:lShowHint := .F.
oSay0:lReadOnly := .F.
oSay0:Align := 0
oSay0:lVisibleControl := .T.
oSay0:lWordWrap := .F.
oSay0:lTransparent := .F.

oSay1 := TSAY():Create(oDlg)
oSay1:cName := "oSay1"
oSay1:cCaption := "Data Envio:"
oSay1:nLeft := 23
oSay1:nTop := 50
oSay1:nWidth := 65
oSay1:nHeight := 17
oSay1:lShowHint := .F.
oSay1:lReadOnly := .F.
oSay1:Align := 0
oSay1:lVisibleControl := .T.
oSay1:lWordWrap := .F.
oSay1:lTransparent := .F.

oGet1 := TGET():Create(oDlg)
oGet1:cName := "oGet1"
oGet1:nLeft := 99
oGet1:nTop := 50
oGet1:nWidth := 121
oGet1:nHeight := 21
oGet1:lShowHint := .F.
oGet1:lReadOnly := .F.
oGet1:Align := 0
oGet1:cVariable := "dDtSai"
oGet1:bSetGet := {|u| If(PCount()>0,dDtSai := u, dDtSai) }
oGet1:lVisibleControl := .T.
oGet1:lPassword := .F.
oGet1:lHasButton := .F.

oSay2 := TSAY():Create(oDlg)
oSay2:cName := "oSay2"
oSay2:cCaption := "TM Saida:"
oSay2:nLeft := 23
oSay2:nTop := 70
oSay2:nWidth := 65
oSay2:nHeight := 17
oSay2:lShowHint := .F.
oSay2:lReadOnly := .F.
oSay2:Align := 0
oSay2:lVisibleControl := .T.
oSay2:lWordWrap := .F.
oSay2:lTransparent := .F.

oGet2 := TGET():Create(oDlg)
oGet2:cName := "oGet2"
oGet2:nLeft := 99
oGet2:nTop := 70
oGet2:nWidth := 60
oGet2:nHeight := 21
oGet2:lShowHint := .F.
oGet2:lReadOnly := .F.
oGet2:Align := 0
oGet2:cVariable := "cTMSai"
oGet2:bSetGet := {|u| If(PCount()>0,cTMSai := u, cTMSai) }
oGet2:cF3 := 'SF5'
oGet2:lVisibleControl := .T.
oGet2:lPassword := .F.
oGet2:lHasButton := .F.

oSay3 := TSAY():Create(oDlg)
oSay3:cName := "oSay3"
oSay3:cCaption := "Transport.:"
oSay3:nLeft := 23
oSay3:nTop := 90
oSay3:nWidth := 65
oSay3:nHeight := 17
oSay3:lShowHint := .F.
oSay3:lReadOnly := .F.
oSay3:Align := 0
oSay3:lVisibleControl := .T.
oSay3:lWordWrap := .F.
oSay3:lTransparent := .F.

oGet3 := TGET():Create(oDlg)
oGet3:cName := "oGet3"
oGet3:nLeft := 99
oGet3:nTop := 90
oGet3:nWidth := 121
oGet3:nHeight := 21
oGet3:lShowHint := .F.
oGet3:lReadOnly := .F.
oGet3:Align := 0
oGet3:cVariable := "cTrans"
oGet3:bSetGet := {|u| If(PCount()>0,cTrans := u, cTrans) }
oGet3:lVisibleControl := .T.
oGet3:lPassword := .F.
oGet3:lHasButton := .F.

oSay4 := TSAY():Create(oDlg)
oSay4:cName := "oSay4"
oSay4:cCaption := "Gera por:"
oSay4:nLeft := 23
oSay4:nTop := 110
oSay4:nWidth := 65
oSay4:nHeight := 17
oSay4:lShowHint := .F.
oSay4:lReadOnly := .F.
oSay4:Align := 0
oSay4:lVisibleControl := .T.
oSay4:lWordWrap := .F.
oSay4:lTransparent := .F.

oCmb1 := TCOMBOBOX():Create(oDlg)
oCmb1:cName := "oCmb1"
oCmb1:cCaption := ""
oCmb1:nLeft := 99
oCmb1:nTop := 110
oCmb1:nWidth := 80
oCmb1:nHeight := 21
oCmb1:lShowHint := .F.
oCmb1:lReadOnly := .F.
oCmb1:Align := 0
oCmb1:cVariable := "cItens"
oCmb1:bSetGet := {|u| If(PCount()>0,cItens:=u,cItens) }
oCmb1:lVisibleControl := .T.
oCmb1:aItems := { "Item","Total"}
oCmb1:nAt := 0

oSBtn1 := SBUTTON():Create(oDlg)
oSBtn1:cName := "oSBtn1"
oSBtn1:cCaption := "Confirmar"
oSBtn1:nLeft := 127
oSBtn1:nTop := 140
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 1
oSBtn1:bAction := {|| nAcao := 1, oDlg:End() }

oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "Cancelar"
oSBtn2:nLeft := 192
oSBtn2:nTop := 140
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 2
oSBtn2:bAction := {|| oDlg:End() }

oDlg:Activate()

If nAcao == 1

	If AllTrim(cItens) == 'Item'
		cSeqINI := NQT->NQT_SEQ
		cSeqFIM := NQT->NQT_SEQ
	Else
		cSeqINI := '   '
		cSeqFIM := 'ZZZ'
	EndIf

	dbSelectArea('NQT')
	dbSetOrder(1)
	dbSeek(xFilial('NQT')+cCodNQT+AllTrim(cSeqINI))
	While NQT->NQT_DOC == cCodNQT .And. NQT->NQT_SEQ >= cSeqINI .And. NQT->NQT_SEQ <= cSeqFIM

		nZ++
		aAdd(aMata240, {})

		//Posiciona Tabela de Produtos
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+NQT->NQT_CODPRO)
	
		//Pega TM para movimenta็ใo
		dbSelectArea('SF5')
		dbSetOrder(1)
		If dbSeek(xFilial('SF5')+cTMSai)
			If SF5->F5_VAL=='S'
				aAdd(aMata240[nZ], {'D3_CUSTO1',NQT->NQT_CUSTO,Nil})
			EndIf
		Else
			Alert('TM para movimenta็ใo, nใo informada!')
			Return()
		EndIf
	
		aAdd(aMata240[nZ], {'D3_TM'     ,SF5->F5_CODIGO  ,Nil})
		aAdd(aMata240[nZ], {'D3_COD'    ,SB1->B1_COD     ,Nil})
		aAdd(aMata240[nZ], {'D3_UM'     ,SB1->B1_UM      ,Nil})
		aAdd(aMata240[nZ], {'D3_QUANT'  ,NQT->NQT_QUANT  ,Nil})
		aAdd(aMata240[nZ], {'D3_LOCAL'  ,NQT->NQT_ARMORI ,Nil})
		aAdd(aMata240[nZ], {'D3_EMISSAO',dDtSai          ,Nil})
		aAdd(aMata240[nZ], {'D3_DOC'    ,NQT->NQT_DOC    ,Nil})
	
		MSExecAuto({|x,y| mata240(x,y)},aMata240[nZ],3)
	
		If lMsErroAuto
			DisarmTransaction()
			Mostraerro()
			Return()
		EndIf

		dbSelectArea('NQT')	
		RecLock('NQT',.f.)
		NQT->NQT_FILORI := cFilAnt
		NQT->NQT_TMSAI  := cTMSai
		NQT->NQT_DTORIG := dDtSai
		NQT->NQT_NOMTRA := cTrans
		NQT->NQT_USUORI := Substr(cUsuario,7,15)
		msUnLock()
		dbSkip()

	EndDo

EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA450R บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para validar a tela de cadastro.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA450R(nOpcX)
Local lRetorno := .t.
Local dDtEnt   := dDataBase
Local cTMEnt   := Space(3)
Local cItens   := Space(5)
Local cCodNQT  := NQT->NQT_DOC
Local cSeqINI  := NQT->NQT_SEQ
Local cSeqFIM  := NQT->NQT_SEQ
Local nZ       := 0
Local nAcao    := 0
Local aMata240 := Array(0,0)
Local oDlg,oSay0,oSay1,oSay2,oSay3,oGet1,oGet2,oCmb1,oSBtn1,oSBtn2
Private lMsErroAuto := .f.

If .Not. Empty(NQT->NQT_DTDEST)
	Alert('Este produto ja foi recebido...')
	Return(.t.)
EndIf

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := "Recebimento de Produtos"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 276
oDlg:nHeight := 175
oDlg:lShowHint := .F.
oDlg:lCentered := .F.

oSay0 := TSAY():Create(oDlg)
oSay0:cName := "oSay0"
oSay0:cCaption := "Confirma data de recebimento do produto."
oSay0:nLeft := 21
oSay0:nTop := 23
oSay0:nWidth := 205
oSay0:nHeight := 17
oSay0:lShowHint := .F.
oSay0:lReadOnly := .F.
oSay0:Align := 0
oSay0:lVisibleControl := .T.
oSay0:lWordWrap := .F.
oSay0:lTransparent := .F.

oSay1 := TSAY():Create(oDlg)
oSay1:cName := "oSay1"
oSay1:cCaption := "Data Recebimento:"
oSay1:nLeft := 23
oSay1:nTop := 50
oSay1:nWidth := 65
oSay1:nHeight := 17
oSay1:lShowHint := .F.
oSay1:lReadOnly := .F.
oSay1:Align := 0
oSay1:lVisibleControl := .T.
oSay1:lWordWrap := .F.
oSay1:lTransparent := .F.

oGet1 := TGET():Create(oDlg)
oGet1:cName := "oGet1"
oGet1:nLeft := 99
oGet1:nTop := 50
oGet1:nWidth := 121
oGet1:nHeight := 21
oGet1:lShowHint := .F.
oGet1:lReadOnly := .F.
oGet1:Align := 0
oGet1:cVariable := "dDtEnt"
oGet1:bSetGet := {|u| If(PCount()>0,dDtEnt := u, dDtEnt) }
oGet1:lVisibleControl := .T.
oGet1:lPassword := .F.
oGet1:lHasButton := .F.

oSay2 := TSAY():Create(oDlg)
oSay2:cName := "oSay2"
oSay2:cCaption := "TM Entrada:"
oSay2:nLeft := 23
oSay2:nTop := 70
oSay2:nWidth := 65
oSay2:nHeight := 17
oSay2:lShowHint := .F.
oSay2:lReadOnly := .F.
oSay2:Align := 0
oSay2:lVisibleControl := .T.
oSay2:lWordWrap := .F.
oSay2:lTransparent := .F.

oGet2 := TGET():Create(oDlg)
oGet2:cName := "oGet2"
oGet2:nLeft := 99
oGet2:nTop := 70
oGet2:nWidth := 60
oGet2:nHeight := 21
oGet2:lShowHint := .F.
oGet2:lReadOnly := .F.
oGet2:Align := 0
oGet2:cVariable := "cTMEnt"
oGet2:bSetGet := {|u| If(PCount()>0,cTMEnt := u, cTMEnt) }
oGet2:cF3 := 'SF5'
oGet2:lVisibleControl := .T.
oGet2:lPassword := .F.
oGet2:lHasButton := .F.

oSay3 := TSAY():Create(oDlg)
oSay3:cName := "oSay3"
oSay3:cCaption := "Gera por:"
oSay3:nLeft := 23
oSay3:nTop := 90
oSay3:nWidth := 65
oSay3:nHeight := 17
oSay3:lShowHint := .F.
oSay3:lReadOnly := .F.
oSay3:Align := 0
oSay3:lVisibleControl := .T.
oSay3:lWordWrap := .F.
oSay3:lTransparent := .F.

oCmb1 := TCOMBOBOX():Create(oDlg)
oCmb1:cName := "oCmb1"
oCmb1:cCaption := ""
oCmb1:nLeft := 99
oCmb1:nTop := 90
oCmb1:nWidth := 80
oCmb1:nHeight := 21
oCmb1:lShowHint := .F.
oCmb1:lReadOnly := .F.
oCmb1:Align := 0
oCmb1:cVariable := "cItens"
oCmb1:bSetGet := {|u| If(PCount()>0,cItens:=u,cItens) }
oCmb1:lVisibleControl := .T.
oCmb1:aItems := { "Item","Total"}
oCmb1:nAt := 0

oSBtn1 := SBUTTON():Create(oDlg)
oSBtn1:cName := "oSBtn1"
oSBtn1:cCaption := "Confirmar"
oSBtn1:nLeft := 127
oSBtn1:nTop := 120
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 1
oSBtn1:bAction := {|| nAcao := 1, oDlg:End() }

oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "Cancelar"
oSBtn2:nLeft := 192
oSBtn2:nTop := 120
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 2
oSBtn2:bAction := {|| oDlg:End() }

oDlg:Activate()

If nAcao == 1

	If AllTrim(cItens) == 'Item'
		cSeqINI := NQT->NQT_SEQ
		cSeqFIM := NQT->NQT_SEQ
	Else
		cSeqINI := '   '
		cSeqFIM := 'ZZZ'
	EndIf

	dbSelectArea('NQT')
	dbSetOrder(1)
	dbSeek(xFilial('NQT')+cCodNQT+AllTrim(cSeqINI))
	While NQT->NQT_DOC == cCodNQT .And. NQT->NQT_SEQ >= cSeqINI .And. NQT->NQT_SEQ <= cSeqFIM

		nZ++
		aAdd(aMata240, {})
	
		//Posiciona Tabela de Produtos
		dbSelectArea('SB1')
		dbSetOrder(1)
		dbSeek(xFilial('SB1')+NQT->NQT_CODPRO)
	
		//Pega TM para movimenta็ใo
		dbSelectArea('SF5')
		dbSetOrder(1)
		If dbSeek(xFilial('SF5')+cTMEnt)
			If SF5->F5_VAL=='S'
				aAdd(aMata240[nZ], {'D3_CUSTO1',NQT->NQT_CUSTO,Nil})
			EndIf
		Else
			Alert('TM para movimenta็ใo, nใo informada!')
			Return()
		EndIf
	
		aAdd(aMata240[nZ], {'D3_TM'     ,SF5->F5_CODIGO  ,Nil})
		aAdd(aMata240[nZ], {'D3_COD'    ,SB1->B1_COD     ,Nil})
		aAdd(aMata240[nZ], {'D3_UM'     ,SB1->B1_UM      ,Nil})
		aAdd(aMata240[nZ], {'D3_QUANT'  ,NQT->NQT_QUANT  ,Nil})
		aAdd(aMata240[nZ], {'D3_LOCAL'  ,NQT->NQT_ARMDES ,Nil})
		aAdd(aMata240[nZ], {'D3_EMISSAO',dDtEnt          ,Nil})
		aAdd(aMata240[nZ], {'D3_DOC'    ,NQT->NQT_DOC    ,Nil})
	
		MSExecAuto({|x,y| mata240(x,y)},aMata240[nZ],3)
	
		If lMsErroAuto
			DisarmTransaction()
			Mostraerro()
			Return()
		EndIf

		dbSelectArea('NQT')
		RecLock('NQT',.f.)
		NQT->NQT_FILDES := cFilAnt
		NQT->NQT_TMENT  := cTMEnt
		NQT->NQT_DTDEST := dDtEnt
		NQT->NQT_USUDES := Substr(cUsuario,7,15)
		msUnLock()
		dbSkip()

	EndDo

EndIf

Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA450I บ Autor ณ Ricardo Tomasi     บ Data ณ  21/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxilial para validar a tela de cadastro.           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA450I(nOpcX)
Local lRetorno := .t.

	AGRR451(NQT->NQT_DOC)

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MenuDef  บAutor  ณ Ricardo Tomasi     บ Data ณ  04/10/2006 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria็ใo do menu.                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

Local aRotina:= {;
				{ STR0002 ,'AxPesqui',0,1} ,; //"Pesquisar"
				{ STR0003 ,'AGRA450A',0,2} ,; //"Visualizar"
				{ STR0004 ,'AGRA450A',0,3} ,; //"Incluir"
				{ STR0005 ,'AGRA450A',0,4} ,; //"Alterar"
				{ STR0006 ,'AGRA450A',0,5} ,; //"Excluir"
				{ STR0007 ,'AGRA450E',0,6} ,; //"Envio"
				{ STR0008 ,'AGRA450R',0,6} ,; //"Recebimento"
				{ STR0009 ,'AGRA450I',0,6}  ; //"Imprimir"
				}
Return(aRotina)