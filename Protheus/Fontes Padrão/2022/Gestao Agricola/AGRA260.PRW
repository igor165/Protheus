#INCLUDE "AGRA260.ch"
#include 'protheus.ch'


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA260  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Tranferencia de Produtos Entre Clientes no mesmo บฑฑ
ฑฑบ          ณ armazem.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA260()

Private cCadastro := STR0001 //"Transferencia Interna"
Private aRotina   := MenuDef()


dbSelectArea('NPI')
dbSetOrder(1)

FilBrowse('NPI',{},'NPI_TIPO=="N"')

mBrowse( 6, 1, 22, 75, 'NPI', Nil, Nil, Nil, Nil, Nil)

dbClearFilter()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA260A บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina auxiliar para montagem da tela de cadastro.         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA260A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nY       := 0

Private oDlg
Private oEnch
Private aGets   := Array(0)
Private aTela   := Array(0,0)

RegToMemory('NPI',(nOpcX == 3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch   := MsMGet():New('NPI',nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oEnch:oBox:Align := CONTROL_ALIGN_ALLCLIENT
	
Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(AGRA260B(nOpc), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })

If nOpcA == 1
	Begin Transaction
	If nOpcX == 3
		dbSelectArea('NPI')
		dbSetOrder(1)
		dbSeek(xFilial('NPI')+M->NPI_CODIGO)
		If RecLock('NPI',.t.)
			For nY := 1 To FCount()
				&('NPI->'+FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			NPI->NPI_FILIAL := xFilial('NPI')
			NPI->NPI_TIPO   := 'N'
			MsUnLock()
		EndIf
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava arquivo de estoque agricola.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea('NPL')
		dbSetOrder(1)
		If dbSeek(xFilial('NPL')+NPI->NPI_CDCLIO+NPI->NPI_LJCLIO+NPI->NPI_SAFRA+NPI->NPI_ARM)
			If RecLock('NPL',.f.)
				NPL->NPL_SDTRFS := NPL->NPL_SDTRFS + M->NPI_QUANT
				NPL->NPL_SALDO  := NPL->NPL_SALDO  - M->NPI_QUANT
				msUnLock()
			EndIf
		EndIf
		If dbSeek(xFilial('NPL')+NPI->NPI_CDCLID+NPI->NPI_LJCLID+NPI->NPI_SAFRA+NPI->NPI_ARM)
			If RecLock('NPL',.f.)
				NPL->NPL_ENTRFS := NPL->NPL_ENTRFS + M->NPI_QUANT
				NPL->NPL_SALDO  := NPL->NPL_SALDO  + M->NPI_QUANT
				msUnLock()
			EndIf
		Else
			If RecLock('NPL',.t.)
				NPL->NPL_FILIAL := xFilial('NPL')
				NPL->NPL_CODCLI := NPI->NPI_CDCLID
				NPL->NPL_LOJCLI := NPI->NPI_LJCLID
				NPL->NPL_NOMCLI := NPI->NPI_DSCLID
				NPL->NPL_SAFRA  := NPI->NPI_SAFRA
				NPL->NPL_ARM    := NPI->NPI_ARM
				NPL->NPL_ENTRFS := NPI->NPI_QUANT
				NPL->NPL_SALDO  := NPI->NPI_QUANT
			EndIf
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
	EndIf
	If nOpcX==5
		dbSelectArea('NPI')
		dbSetOrder(1)
		dbSeek(xFilial('NPI')+M->NPI_CODIGO)
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava arquivo de estoque agricola.ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea('NPL')
		dbSetOrder(1)
		If dbSeek(xFilial('NPL')+NPI->NPI_CDCLIO+NPI->NPI_LJCLIO+NPI->NPI_SAFRA+NPI->NPI_ARM)
			If RecLock('NPL',.f.)
				NPL->NPL_SDTRFS := NPL->NPL_SDTRFS - M->NPI_QUANT
				NPL->NPL_SALDO  := NPL->NPL_SALDO  + M->NPI_QUANT
				msUnLock()
			EndIf
			If NPL_ENBRUT+NPL_ENDESC+NPL_ENEXTR+NPL_ENLIQU+NPL_ENTRFS+NPL_SDBRUT+NPL_SDDESC+NPL_SDEXTR+NPL_SDLIQU+NPL_SDTRFS+NPL_SALDO == 0
				If RecLock('NPL',.f.)
					dbDelete()
					msUnLock()
				EndIf
            EndIf
		EndIf
		If dbSeek(xFilial('NPL')+NPI->NPI_CDCLID+NPI->NPI_LJCLID+NPI->NPI_SAFRA+NPI->NPI_ARM)
			If RecLock('NPL',.f.)
				NPL->NPL_ENTRFS := NPL->NPL_ENTRFS - M->NPI_QUANT
				NPL->NPL_SALDO  := NPL->NPL_SALDO  - M->NPI_QUANT
				msUnLock()
			EndIf
			If NPL_ENBRUT+NPL_ENDESC+NPL_ENEXTR+NPL_ENLIQU+NPL_ENTRFS+NPL_SDBRUT+NPL_SDDESC+NPL_SDEXTR+NPL_SDLIQU+NPL_SDTRFS+NPL_SALDO == 0
				If RecLock('NPL',.f.)
					dbDelete()
					msUnLock()
				EndIf
            EndIf
		EndIf
		If RecLock('NPI',.f.)
			dbDelete()
			msUnLock()
		EndIf
	EndIf
	End Transaction
Else
	If nOpcX == 3
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
ฑฑบPrograma  ณ AGRA260B บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Valida Enchoice para nใo permitir transferencias com valor บฑฑ
ฑฑบ          ณ negativo...                                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA260B(nOpcX)
Local lRetorno := .t.
Local nSaldo   := 0

If nOpcX==3
	If Obrigatorio(aGets,aTela)
		If M->NPI_CDCLIO+M->NPI_LJCLIO <> M->NPI_CDCLID+M->NPI_LJCLID
			If .Not. GetMV('MV_AGRSNEG',,.t.)
				dbSelectArea('NPL')
				dbSetOrder(1)
				If dbSeek(xFilial('NPL')+M->NPI_CDCLIO+M->NPI_LJCLIO+M->NPI_SAFRA+M->NPI_ARM)
					nSaldo := NPL->NPL_SALDO
				EndIf
				If nSaldo < M->NPI_QUANT
					ApMsgAlert(STR0006,STR0007)
					lRetorno := .f.
				EndIf
			EndIf
		Else
			ApMsgAlert(STR0008,STR0009)
			lRetorno := .f.
		EndIf
	Else
		lRetorno := .f.
	EndIf
EndIf
If nOpcX==5; lRetorno := .t.; EndIf

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
				 { STR0003 ,'AxVisual',0,2} ,; //"Visualizar"
				 { STR0004 ,'AGRA260A',0,3} ,; //"Incluir"
				 { STR0005 ,'AGRA260A',0,5}  ; //"Excluir"
				 }

Return(aRotina)

