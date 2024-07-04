#INCLUDE "AGRA250.CH"
#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA250  บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina de Apontamento de Produ็ใo.                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA250()

Private aCores    := {;
					 {'NPA->NPA_FECHAD = "N"' ,'BR_VERDE'   },;
                     {'NPA->NPA_FECHAD = "S"' ,'BR_VERMELHO'} ;
                     }
Private cCadastro := STR0001 //"Apontamento de Produ็ใo"
Private aRotina   := MenuDef()

dbSelectArea('NPA')
dbSetOrder(1)

mBrowse( 6, 1, 22, 75, 'NPA', Nil, Nil, Nil, Nil, Nil, aCores)

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA250A บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Informativo de cadastros de apontamentos de produ็ใo.      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA250A(cAlias, nReg, nOpc)
Local aSize    := MsAdvSize()
Local aObjects := {{100,100,.t.,.t.},{100,100,.t.,.t.},{100,015,.t.,.f.}}
Local aInfo    := {aSize[1],aSize[2],aSize[3],aSize[4],3,3}
Local aPosObj  := MsObjSize(aInfo,aObjects)
Local nOpcX    := aRotina[nOpc,4]
Local nOpcA    := 0
Local nY       := 0
Local nX       := 0
Local nC       := 0
Local aCampos  := Array(0)
Local cNumPed  := ''
Local cNumIte  := ''
Local aPedCab  := Array(0)
Local aPedIte  := Array(0)
Local aPedIts  := Array(0)
Local lAgrXFat := GetMV('MV_AGRXFAT',,.F.)

Private aGets   := Array(0)
Private aTela   := Array(0,0)
Private aHeader := Array(0)
Private aCols   := Array(0)
Private oDlg
Private oEnch
Private oGetD
Private lMsErroAuto := .f.
Private nMaxLin := 0

aAdd(aCampos, 'NPB_ITEM'  ); aAdd(aCampos, 'NPB_CODVAR'); aAdd(aCampos, 'NPB_DESVAR')
aAdd(aCampos, 'NPB_PERVAR'); aAdd(aCampos, 'NPB_PSAPTO'); aAdd(aCampos, 'NPB_PSREAL')

For nX := 1 To Len(aCampos)
	If X3USADO(aCampos[nX]) .And. cNivel >= AGRRETNIV(aCampos[nX])
		aAdd(aHeader,{AllTrim(RetTitle(aCampos[nX])), aCampos[nX], X3PICTURE(aCampos[nX]), TamSx3(aCampos[nX])[1], TamSx3(aCampos[nX])[2], X3VALID(aCampos[nX]), X3USADO(aCampos[nX]), TamSx3(aCampos[nX])[3], "NPB", AGRRETCTXT("NPB", aCampos[nX]) })
	Endif
Next nX

If nOpcX==2 .Or. nOpcX==4 .Or. nOpcX==5
	dbSelectArea('NPB')
	dbSetOrder(1)
	dbSeek(xFilial('NPB')+NPA->NPA_CODIGO)
	While .Not. Eof() .And. xFilial('NPA')+NPA->NPA_CODIGO == xFilial('NPB')+NPB->NPB_CODIGO
		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := FieldGet(FieldPos(aHeader[nX,2]))
		Next
		aCols[nC,Len(aHeader)+1] := .f.
		dbSkip()
	EndDo
EndIf

If nOpcX==4 .Or. nOpcX==5
	If NPA->NPA_FECHAD=='S'
		ApMsgAlert(STR0007) //"Impossivel o Apontamento jแ esta fechado!!!"
		Return()
	EndIf
	dbSelectArea('SF2')
	dbSetOrder(1)//F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
	If dbSeek(xFilial('SF2')+NPA->NPA_NFSNUM+NPA->NPA_NFSSER+NPA->NPA_CODCLI+NPA->NPA_LOJCLI)
		ApMsgAlert("Existe uma Nota Fiscal emitida para este Apontamento!!!")
		Return()
	EndIf
EndIf

dbSelectArea('NPA')
dbSetOrder(1)
RegToMemory('NPA',(nOpcX==3))

Define MSDialog oDlg Title cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd Pixel

	oEnch := MsMGet():New('NPA',nReg,nOpc,,,,,aPosObj[1],,3,,,,oDlg,,.t.)
	oGetD := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcX,,'AGRA250E','+NPB_ITEM',.f.,,Len(aHeader),,nMaxLin,'AGRA250F',,,,oDlg)
		
Activate MsDialog oDlg On Init EnchoiceBar(oDlg, {|| nOpcA := 1, IIf(AGRA250B(nOpcX,lAgrXFat), oDlg:End(), nOpcA := 0) } , {|| nOpcA := 0, oDlg:End() })

If nOpcA==1 .And. (nOpcX==3 .Or. nOpcX==4 .Or. nOpcX==5)

	Begin Transaction

	If nOpcX== 3
		dbSelectArea('NPA')
		dbSetOrder(1)
		If RecLock('NPA',.t.)
			For nY := 1 To FCount()
				&('NPA->'+FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			NPA->NPA_FILIAL := xFilial('NPA')
			MsUnLock()
		EndIf
		If __lSX8
			ConfirmSX8()
		EndIf
		dbSelectArea('NPB')
		dbSetOrder(1)
		For nX := 1 To Len(aCols)
			If RecLock('NPB',.t.)
				NPB->NPB_FILIAL := xFilial('NPB')
				NPB->NPB_CODIGO := M->NPA_CODIGO
				For nY := 1 To Len(aHeader)
					&('NPB->'+aHeader[nY,2]) := aCols[nX,nY]
				Next nY
				msUnLock()
			EndIf
		Next nX
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava Pedido de Venda - Inclusใo      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAgrXFat .And. NPA->NPA_NFSEMI == 'N' //

			cNumPed := GetSXENum('SC5','C5_NUM')
			aAdd(aPedCab,{'C5_NUM'    , cNumPed        , Nil}) //Numero do Pedido
			aAdd(aPedCab,{'C5_TIPO'   , 'N'            , Nil}) //Tipo de Pedido
			aAdd(aPedCab,{'C5_CLIENTE', NPA->NPA_CODCLI, Nil}) //Codigo do Cliente
			aAdd(aPedCab,{'C5_LOJACLI', NPA->NPA_LOJCLI, Nil}) //Loja do Cliente
			aAdd(aPedCab,{'C5_EMISSAO', NPA->NPA_DATA  , Nil}) //Data de Emissao
			aAdd(aPedCab,{'C5_LIBEROK', 'S'            , Nil}) //Liberacao Total

			cNumIte := RetAsc( 1, TamSX3('C6_ITEM')[1],.F.)
			aAdd(aPedIte,{'C6_NUM'    , cNumPed         , Nil})
			aAdd(aPedIte,{'C6_ITEM'   , cNumIte         , Nil})
			aAdd(aPedIte,{'C6_PRODUTO', NPA->NPA_CODPRO , Nil})
			aAdd(aPedIte,{'C6_UM'     , NPA->NPA_UM     , Nil})
			aAdd(aPedIte,{'C6_LOCAL'  , NPA->NPA_LOCAL  , Nil})
			aAdd(aPedIte,{'C6_QTDVEN' , NPA->NPA_QTDEST , Nil})
			aAdd(aPedIte,{'C6_PRCVEN' , NPA->NPA_VLRUNI , Nil})
			aAdd(aPedIte,{'C6_VALOR'  , NPA->NPA_VLRTOT , Nil})
			aAdd(aPedIte,{'C6_TES'    , NPA->NPA_NFSTES , Nil})
			aAdd(aPedIts, aPedIte)

			MSExecAuto({|x,y,z|Mata410(x,y,z)}, aPedCab, aPedIts, 3) //Op็ใo para Inclusใo

			If lMsErroAuto
				Mostraerro()
			EndIf

			If __lSX8
				ConfirmSX8()
			EndIf

			If RecLock('NPA',.f.)
				NPA->NPA_PVNUM  := cNumPed
				NPA->NPA_PVITEM := cNumIte
				MsUnLock()
				cNumPed := ''
				cNumIte := ''
			EndIf

		EndIf //Encerra grava็ใo do pedido

		//integra็ใo com o estoque padrใo... - Inclusใo
		/*
		If GetMV('MV_AGRXEST',,.f.)
			aAdd(aMata650, {{'C2_NUM'    ,M->NPA_CODIGO  ,Nil},;
							{'C2_ITEM'   ,'AG'           ,Nil},;
						    {'C2_SEQUEN' ,'001'          ,Nil},;
						    {'C2_PRODUTO',M->NPA_CODPRO  ,Nil},;
						    {'C2_LOCAL'  ,M->NPA_LOCAL   ,Nil},;
						    {'C2_CC'     ,''             ,Nil},;
						    {'C2_QUANT'  ,M->NPA_QTDEST  ,Nil},;
						    {'C2_UM'     ,M->NPA_UM      ,Nil},;
						    {'C2_DATPRI' ,M->NPA_DATA    ,Nil},;
						    {'C2_DATPRF' ,M->NPA_DATA    ,Nil},;
						    {'C2_EMISSAO',M->NPA_DATA    ,Nil},;
						    {'C2_PRIOR'  ,'500'          ,Nil},;
						    {'C2_STATUS' ,'N'            ,Nil},;
						    {'C2_DESTINA','E'            ,Nil},;
						    {'C2_SEQPAI' ,'000'          ,Nil},;
						    {'C2_OBS'    ,'APTO SIGAAGR' ,Nil}})

			MSExecAuto({|x,y| mata650(x,y)},aMata650[1],3)
			If lMsErroAuto
				DisarmTransaction()
				Mostraerro()
				Break
			EndIf
		EndIf
		*/

	EndIf

	If nOpcX== 4
		dbSelectArea('NPA')
		dbSetOrder(1)
		If RecLock('NPA',.f.)
			For nY := 1 To FCount()
				&('NPA->'+FieldName(nY)) := &('M->'+FieldName(nY))
			Next nY
			MsUnLock()
		EndIf
		dbSelectArea('NPB')
		dbSetOrder(1)
		If dbSeek(xFilial('NPB')+M->NPA_CODIGO)
			While .Not. Eof() .And. xFilial('NPB')+NPB->NPB_CODIGO == xFilial('NPA')+M->NPA_CODIGO
				If RecLock('NPB',.f.)
					dbDelete()
					MsUnLock()
				EndIf
				dbSkip()
			EndDo
		EndIf
		For nX := 1 To Len(aCols)
			If RecLock('NPB',.t.)
				NPB->NPB_FILIAL := xFilial('NPB')
				NPB->NPB_CODIGO := M->NPA_CODIGO
				For nY := 1 To Len(aHeader)
					&('NPB->'+aHeader[nY,2]) := aCols[nX,nY]
				Next nY
				msUnLock()
			EndIf
		Next nX

		/*
		dbSelectArea('SC2')
		dbSetOrder(1)
		If dbSeek(xFilial('SC2')+M->NPA_CODIGO+'AG001')
			If SC2->C2_QUJE = 0
				//integra็ใo com o estoque padrใo... - Altera็ใo
				If GetMV('MV_AGRXEST',,.f.)
					aAdd(aMata650, {{'C2_NUM'    ,M->NPA_CODIGO  ,Nil},;
									{'C2_ITEM'   ,'AG'           ,Nil},;
								    {'C2_SEQUEN' ,'001'          ,Nil},;
								    {'C2_ITEMGRD',''             ,Nil},;
								    {'C2_PRODUTO',M->NPA_CODPRO  ,Nil},;
								    {'C2_LOCAL'  ,M->NPA_LOCAL   ,Nil},;
								    {'C2_CC'     ,''             ,Nil},;
								    {'C2_QUANT'  ,M->NPA_QTDEST  ,Nil},;
								    {'C2_UM'     ,M->NPA_UM      ,Nil},;
								    {'C2_DATPRI' ,M->NPA_DATA    ,Nil},;
								    {'C2_DATPRF' ,M->NPA_DATA    ,Nil},;
								    {'C2_EMISSAO',M->NPA_DATA    ,Nil},;
								    {'C2_PRIOR'  ,'500'          ,Nil},;
								    {'C2_STATUS' ,'N'            ,Nil},;
								    {'C2_DESTINA','E'            ,Nil},;
								    {'C2_SEQPAI' ,'000'          ,Nil},;
								    {'C2_OBS'    ,'APTO SIGAAGR' ,Nil}})
		
					MSExecAuto({|x,y| mata650(x,y)},aMata650[1],4)
					If lMsErroAuto
						DisarmTransaction()
						Mostraerro()
						Break
					EndIf
				EndIf

			EndIf
		EndIf
        */

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava Pedido de Venda - Altera็ใo     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If lAgrXFat .And. NPA->NPA_NFSEMI == 'N' //

			dbSelectArea('SA1')
			dbSetOrder(1)
			dbSeek(xFilial('SA1')+NPA->NPA_CODCLI+NPA->NPA_LOJCLI)

			dbSelectArea('SB1')
			dbSetOrder(1)
			dbSeek(xFilial('SB1')+NPA->NPA_CODPRO)

			dbSelectArea('SC5')
			dbSetOrder(1)
			If dbSeek(xFilial('SC5')+NPA->NPA_PVNUM)
				If SC5->C5_LIBEROK <> 'S'

					aAdd(aPedCab,{'C5_NUM'    , NPA->NPA_PVNUM , Nil}) //Numero do Pedido
					aAdd(aPedCab,{'C5_TIPO'   , SC5->C5_TIPO   , Nil}) //Tipo do Pedido
					aAdd(aPedCab,{'C5_CLIENTE', NPA->NPA_CODCLI, Nil}) //Codigo do Cliente
					aAdd(aPedCab,{'C5_LOJACLI', NPA->NPA_LOJCLI, Nil}) //Loja do Cliente
					aAdd(aPedCab,{'C5_TIPOCLI', SA1->A1_TIPO   , Nil}) //Tipo do Cliente
					aAdd(aPedCab,{'C5_EMISSAO', NPA->NPA_DATA  , Nil}) //Data de Emissao
					aAdd(aPedCab,{'C5_CONDPAG', SA1->A1_COND   , Nil}) //Condicao de Pagamanto
					aAdd(aPedCab,{'C5_LIBEROK', 'S'            , Nil}) //Liberacao Total
		
					aAdd(aPedIte,{'C6_NUM'    , NPA->NPA_PVNUM  , Nil})
					aAdd(aPedIte,{'C6_ITEM'   , NPA->NPA_PVITEM , Nil})
					aAdd(aPedIte,{'C6_PRODUTO', NPA->NPA_CODPRO , Nil})
					aAdd(aPedIte,{'C6_UM'     , NPA->NPA_UM     , Nil})
					aAdd(aPedIte,{'C6_LOCAL'  , NPA->NPA_LOCAL  , Nil})
					aAdd(aPedIte,{'C6_QTDVEN' , NPA->NPA_QTDEST , Nil})
					aAdd(aPedIte,{'C6_PRCVEN' , NPA->NPA_VLRUNI , Nil})
					aAdd(aPedIte,{'C6_VALOR'  , NPA->NPA_VLRTOT , Nil})
					aAdd(aPedIte,{'C6_TES'    , NPA->NPA_NFSTES , Nil})
					aAdd(aPedIts, aPedIte)
		
					MSExecAuto({|x,y,z|Mata410(x,y,z)}, aPedCab, aPedIts, 4) //Op็ใo para Altera็ใo
		
					If lMsErroAuto
						Mostraerro()
					EndIf

				EndIf

			EndIf

		EndIf //Encerra grava็ใo do pedido

	EndIf

	If nOpcX==5

		/*
		If GetMV('MV_AGRXEST',,.f.)
			dbSelectArea('SC2')
			dbSetOrder(1)
			If dbSeek(xFilial('SC2')+M->NPA_CODIGO+'AG001')
				If SC2->C2_QUJE = 0
					aAdd(aMata650, {{'C2_NUM'    ,M->NPA_CODIGO  ,Nil},;
									{'C2_ITEM'   ,'AG'           ,Nil},;
								    {'C2_SEQUEN' ,'001'          ,Nil}})
		
					MSExecAuto({|x,y| mata650(x,y)},aMata650[1],5)
					If lMsErroAuto
						DisarmTransaction()
						Mostraerro()
						Break
					EndIf
				EndIf
			EndIf
		EndIf
		*/

		dbSelectArea('NPA')
		dbSetOrder(1)
		If dbSeek(xFilial('NPA')+M->NPA_CODIGO)
			If RecLock('NPA',.f.)
				dbDelete()
				MsUnLock()
			EndIf
		EndIf

		dbSelectArea('NPB')
		dbSetOrder(1)
		If dbSeek(xFilial('NPB')+M->NPA_CODIGO)
			While .Not. Eof() .And. xFilial('NPB')+NPB->NPB_CODIGO == xFilial('NPA')+M->NPA_CODIGO
				If RecLock('NPB',.f.)
					dbDelete()
					MsUnLock()
				EndIf
				dbSkip()
			EndDo
		EndIf

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณGrava Pedido de Venda - Exclusใo      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		/*
		If NPA->NPA_NFSEMI == 'N' //

			aAdd(aPedCab,{'C5_NUM'    , NPA->NPA_PVNUM  , Nil}) //Numero do Pedido
			aAdd(aPedIte,{'C6_NUM'    , NPA->NPA_PVNUM  , Nil})
			aAdd(aPedIte,{'C6_ITEM'   , NPA->NPA_PVITEM , Nil})
			aAdd(aPedIts, aPedIte)

			MSExecAuto({|x,y,z|Mata410(x,y,z)}, aPedCab, aPedIts, 5) //Op็ใo para Exclusใo

			If lMsErroAuto
				Mostraerro()
			EndIf

		EndIf //Encerra grava็ใo do pedido
		*/

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
ฑฑบPrograma  ณ AGRA250B บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para validar o enchoice e o getdados deste cadastro.บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA250B(nOpcX,lAgrXFat)
Local lRetorno	:= .T.
Local aAreaSA1	:= {}

If nOpcX == 3 .Or. nOpcX == 4
	lRetorno := Obrigatorio(aGets,aTela) .And. oGetD:TudoOK()

	If lRetorno .And. M->NPA_NFSEMI == 'N'
		If M->NPA_NFSTES < '501'
			Help (" ",1,"A410NOTES")
			lRetorno := .F.
		EndIf
		aAreaSA1	:= GetArea()
		SA1->(dbSetOrder(1))
		If lAgrXFat .And. lRetorno .And. ;
			( !SA1->(MsSeek(xFilial("SA1")+M->NPA_CODCLI+M->NPA_LOJCLI)) .Or. SA1->(Empty(A1_COND)) )
			lRetorno := .F.
		EndIf
		SA1->(RestArea(aAreaSA1))
	EndIf

EndIf
Return(lRetorno)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA250C บ Autor ณ Ricardo Tomasi     บ Data ณ  25/05/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para fechamento de Apontamentos de Produ็ใo.        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AGRA250C(cCod, nQtd, lAut)
//Local oDlg
//Local oSay1
//Local oGet1
Local cCodApo  := IIf(cCod==Nil,NPA->NPA_CODIGO,cCod)
Local nQtdRea  := IIf(nQtd==Nil,0,nQtd)
//Local lRotAuto := IIf(lAut==Nil,.f.,lAut)
Local nOpcA    := IIf(lAut==Nil,0,IIf(lAut,1,0))
//Local aMata250 := Array(0,0)
//Local nX       := 0
//Local nY       := 0

Private lMsErroAuto := .f.

NPA->(dbSeek(xFilial('NPA')+cCodApo))
NPB->(dbSeek(xFilial('NPB')+cCodApo))

If NPA->NPA_FECHAD == 'S'
	ApMsgAlert(STR0008,STR0009) //"Nใo foi possivel baixar o Apontamento de Produ็ใo!!!"###"Baixa do Apontamento de Produ็ใo"
	Return()
EndIf

If nOpcA == 1

	//SB1->(dbSeek(xFilial('SB1')+cCodApo))

	Begin Transaction
        
		/*
		If GetMV('MV_AGRXEST',,.f.)
			aAdd(aMata250, {{'D3_TM'     ,Substr(GetMV('MV_AGRTM',,'001/101/501'),1,3),Nil},;
							{'D3_COD'    ,NPA->NPA_CODPRO             ,Nil},;
						    {'D3_UM'     ,NPA->NPA_UM                 ,Nil},;
						    {'D3_QUANT'  ,nQtdRea                     ,Nil},;
						    {'D3_LOCAL'  ,NPA->NPA_LOCAL              ,Nil},;
						    {'D3_EMISSAO',NPA->NPA_DATA               ,Nil},;
						    {'D3_TIPO'   ,SB1->B1_TIPO                ,Nil},;
						    {'D3_CF'     ,'PR0'                       ,Nil},;
						    {'D3_OP'     ,NPA->NPA_CODIGO+'AG001'     ,Nil},;
						    {'D3_DOC'    ,NPA->NPA_CODIGO             ,Nil},;
						    {'D3_CHAVE'  ,'R0'                        ,Nil},;
							{'D3_CUSTO1' ,NPA->NPA_VLRTOT             ,Nil},;
							{'D3_PARCTOT','T'                         ,Nil},;
							{'D3_PERDA'  ,ABS(NPA->NPA_QTDEST-nQtdRea),Nil},;
					    	{'D3_USUARIO',Substr(cUsuario,7,15)       ,Nil}})

			MSExecAuto({|x,y| mata250(x,y)},aMata250[1],3)
			If lMsErroAuto
				DisarmTransaction()
				Mostraerro()
				Return()
			EndIf
		EndIf
		*/

		If RecLock('NPA',.f.)
			NPA->NPA_QTDREA := nQtdRea
			NPA->NPA_FECHAD := 'S'
			MsUnLock()
		EndIf

		dbSelectArea('NPB')
		While .Not. Eof() .And. xFilial('NPA')+cCodApo == xFilial('NPB')+NPB->NPB_CODIGO
			If RecLock('NPB',.f.)
				NPB->NPB_PSREAL := (NPB->NPB_PERVAR * nQtdRea) / 100
				MsUnLock()
			EndIf
			dbSkip()
		EndDo

	End Transaction

EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA250D บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo no campo do talhใo. Para carregar as variedades  บฑฑ
ฑฑบ          ณ plantadas no mesmo.                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA250D()
Local aAreaAt   := GetArea()
Local lRetorno  := .t.
Local nX        := 0
Local nC        := 0
Local nP_ITEM   := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPB_ITEM'   })
Local nP_CODVAR := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPB_CODVAR' })
Local nP_DESVAR := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPB_DESVAR' })

aCols := Array(0)

dbSelectArea('NN3')
dbSetOrder(1)
dbSeek(xFilial('NN3')+M->NPA_SAFRA+M->NPA_FAZ+M->NPA_TALHAO)

If NN3->NN3_FECHAD == 'S'
	ApMsgAlert("Este talhใo ja esta fechado, e nใo pode ser movimentado.", "Talhใo Fechado")
	lRetorno := .f.
Else

	dbSelectArea('NN4')
	dbSetOrder(1)
	dbSeek(xFilial('NN4')+NN3->NN3_SAFRA+NN3->NN3_FAZ+NN3->NN3_TALHAO)
	
	While .Not. Eof() .And. xFilial('NN4')+NN4->NN4_SAFRA+NN4->NN4_FAZ+NN4->NN4_TALHAO == xFilial('NN3')+NN3->NN3_SAFRA+NN3->NN3_FAZ+NN3->NN3_TALHAO
	
		nC++
		aAdd(aCols, Array(Len(aHeader)+1))
		For nX := 1 to Len(aHeader)
			aCols[nC,nX] := CriaVar(aHeader[nX,2])
			aCols[nC,nP_ITEM]   := NN4->NN4_ITEM
			aCols[nC,nP_CODVAR] := NN4->NN4_CODVAR
			aCols[nC,nP_DESVAR] := NN4->NN4_DESVAR
		Next nX
		aCols[nC,Len(aHeader)+1] := .f.
	
		dbSkip()
	EndDo
	nMaxLin := nC
	oGetD:oBrowse:Refresh()

EndIf

RestArea(aAreaAt)
Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA250E บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo do GetDados para nใo permitir a soma dos percent-บฑฑ
ฑฑบ          ณ maior que 100.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA250E()
Local lRetorno  := .t.
Local nX        := 0
Local nPerVar   := 0
Local nP_PERVAR := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPB_PERVAR' })

For nX := 1 to Len(aCols)
	nPerVar += aCols[nX,nP_PERVAR]
Next nX

If nPerVar <> 100
	ApMsgAlert("A soma dos percentuais deve ser de 100% (cem por cento).","Soma do Percentual")
	lRetorno := .f.
EndIf

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA250F บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida campo do percentual para calcular o peso estimado   บฑฑ
ฑฑบ          ณ por variedade conforme percentual digitado.                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA250F()
Local lRetorno  := .t.
Local nX        := 0
Local nP_PERVAR := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPB_PERVAR' })
Local nP_PSAPTO := aScan(aHeader, { |x| Alltrim(x[2]) == 'NPB_PSAPTO' })

For nX := 1 to Len(aCols)

If n == nX .And. 'NPB_PERVAR' $ __READVAR
	aCols[nX,nP_PSAPTO] := (M->NPB_PERVAR * M->NPA_QTDEST) / 100
Else
	aCols[nX,nP_PSAPTO] := (aCols[nX,nP_PERVAR] * M->NPA_QTDEST) / 100
EndIf

Next nX

oGetD:oBrowse:Refresh()

Return(lRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AGRA250L บAutor  ณ Ricardo Tomasi     บ Data ณ  13/07/2005 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Legenda para Apontamento de Produ็ใo                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Clientes Microsiga                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function AGRA250L()
Local aLeg := {}

aAdd(aLeg,{'BR_VERDE'    ,'Apontamento Aberto'})
aAdd(aLeg,{'BR_VERMELHO' ,'Apontamento Fechado' })

BrwLegenda(cCadastro,"Legenda dos Apontamentos", aLeg)

Return()

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
				 { STR0003 ,'AGRA250A',0,2} ,; //"Visualizar"
				 { STR0004 ,'AGRA250A',0,3} ,; //"Incluir"
				 { STR0005 ,'AGRA250A',0,4} ,; //"Alterar"
				 { STR0006 ,'AGRA250A',0,5} ,; //"Excluir"
				 { "Legenda" ,'AGRA250L',0,6}  ;
				 }

Return(aRotina)
