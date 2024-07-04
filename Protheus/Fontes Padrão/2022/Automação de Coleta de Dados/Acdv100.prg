#include "ACDV100.ch" 
#include "protheus.ch"
#include "apvt100.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ACDV100   ³ Autor ³ Ricardo               ³ Data ³ 23/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Reimpressao de etiquetas                                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ACDV100()
Local nOpc := 0
Local lRet := .T.
Local cTitulo	:= STR0010 //"Reimpressao de Etiquetas"

If IsTelNet()
	VTCLear()
	@ 0,0 VTSay STR0001
	nOpc := VTaChoice(2,0,3,VTMaxCol(),{ STR0011 , STR0015 } )   //"Etiqueta"###"Pallet"
	lRet := V100Run( nOpc )
Else
	DEFINE MSDIALOG oDlg FROM  180,080 TO 320,380 TITLE OemtoAnsi(cTitulo) PIXEL
	@ 20,50 Radio oRadio VAR nOpc ITEMS "1-Etiqueta","2-Pallet" 3D SIZE 50,10 OF oDlg PIXEL  
	DEFINE SBUTTON FROM 50,080 TYPE 1 ENABLE OF oDlg ACTION (lRet := V100Run( nOpc ),oDlg:End())
	DEFINE SBUTTON FROM 50,110 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()
	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

Return lRet


Function V100Run( nOpc )
Local oDlg, oEtiq, oLocImp
Local cTitulo	:= STR0010 //"Reimpressao de Etiquetas" 
Local lSair		:= .F.
Local lVolta	:= .F.

Private lGravaCB0
Private cEtiq , cLocImp
Default nOpc := 1

If !Type("lVT100B") == "L"
	Private lVT100B := .F.
EndIf

If IsTelNet()
	While .t.            
		cEtiq   := Space( 20 )
		cLocImp := Space( 6 )
		lSair := .f.
		VTClear()               
		If lVT100B
			While .T.
				lVolta := .F.
				@ 1,0 VTSay STR0001 //"Reimpressao de"
				If nOpc == 1
					@ 2,0 VTSay STR0002 //"Etiqueta :"
				Else
					@ 2,0 VTSay STR0016 //Pallet  :""
				EndIf
				@ 3,0 VTGet cEtiq pict '@!' VALID ! Empty(cEtiq) .and. VldEtiq( cEtiq, nOpc ) F3 IIf( nOpc == 1, "CB0", "CB0001" )
				
				VtRead
				If VTLastkey() != 27
					VTClear()
					@ 2,0 VTSay STR0007 //"Local de Impressao:"
					@ 3,0 VTGet cLocImp pict '@!' VALID ! Empty(cLocImp) .and. VldLocImp( cLocImp, nOpc ) F3 "CB5"

					VtRead                      
					If VTLastKey() == 27
						Exit
					EndIf
				Else
					lSair := .t. // Sai dos dois laços
					Exit
				EndIf
				
				If lVolta
					Loop
				EndIf
				Exit
			EndDo

			If lSair 
				Exit
			EndIf
		Else
			@ 1,0 VTSay STR0001 //"Reimpressao de"
			If nOpc == 1
				@ 2,0 VTSay STR0002 //"Etiqueta :"
			Else
				@ 2,0 VTSay STR0016 //Pallet  :""
			EndIf

			@ 4,0 VTSay STR0007 //"Local de Impressao:"
			@ 3,0 VTGet cEtiq 	pict '@!' VALID !Empty(cEtiq) 	.And. VldEtiq( cEtiq, nOpc ) 	 F3 IIf( nOpc == 1, "CB0", "CB0001" )
			@ 5,0 VTGet cLocImp pict '@!' VALID !Empty(cLocImp) .And. VldLocImp( cLocImp, nOpc ) F3 "CB5"
			VTRead                      
			If VTLastKey() == 27
				Exit
			EndIf

		EndIf
	EndDo
Else
   cEtiq   := Space(20)
   cLocImp := Space(6)
	DEFINE MSDIALOG oDlg FROM  180,080 TO 320,380 TITLE OemtoAnsi(cTitulo) PIXEL
	If nOpc == 1
		@ 10,10 SAY OemToAnsi(STR0011) SIZE 50,8 OF oDlg PIXEL //"Etiqueta"
	Else
		@ 10,10 SAY OemToAnsi(STR0015) SIZE 50,8 OF oDlg PIXEL //"Pallet"
	EndIf
	@ 10,60 MSGET oEtiq VAR cEtiq PICTURE "@!" F3 IIf( nOpc = 1, "CB0", "CB0001" ) VALID VldEtiq( cEtiq, nOpc )  SIZE 80,10 OF oDlg PIXEL
	@ 30,10 SAY OemToAnsi(STR0012) SIZE 50,8 OF oDlg PIXEL //"Local de Impressao "
	@ 30,60 MSGET oLocImp VAR cLocImp PICTURE "@!" F3 "CB5" SIZE 40,10 OF oDlg PIXEL

	DEFINE SBUTTON FROM 50,080 TYPE 1 ENABLE OF oDlg ACTION (ReimprEti( cLocImp, nOpc ),oDlg:End())
	DEFINE SBUTTON FROM 50,110 TYPE 2 ENABLE OF oDlg ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED
EndIf

Return

Static Function VldEtiq( cEtiq, nOpc )
Local lRet		:= .T.
Local nOrdCB0	:= IIf( nOpc == 1, IIf( Len( AllTrim( cEtiq ) ) > 10, 2, 1 ) , 5 )

Default nOpc := 1

dbSelectArea("CB0") 

If nOpc == 1
	CB0->( dbSetOrder( nOrdCB0 ) ) //CB0_FILIAL, CB0_CODETI
	CB0->( dbSeek( FWxFilial( "CB0" ) + cEtiq ) )
	lRet := CB0->( Found() )
Else
	CB0->( dbSetOrder( nOrdCB0 ) ) //CB0_FILIAL, CB0_PALLET
	CB0->( dbSeek( FWxFilial( "CB0" ) + cEtiq ) )
	lRet := CB0->( Found() )
	If !( lRet )
		nOrdCB0 := IIf( Len( AllTrim( cEtiq ) ) > 10, 2, 1 )
		CB0->( dbSetOrder( nOrdCB0 ) )
		CB0->( dbSeek( FWxFilial( "CB0" ) + cEtiq ) )
		lRet := CB0->( Found() )
	EndIf
EndIf

If !( lRet )
	If IsTelNet()
		VTAlert(STR0006,STR0004,.T.,3000)	 //"Etiqueta nao existe"###"Atencao"
	Else
		MsgStop(STR0006) //"Etiqueta nao existe"
	EndIf
EndIf

CB0->(dbSetOrder(1))             
Return lRet

Static Function VldLocImp( cLocImp, nOpc ) 
Return ReimprEti( cLocImp, nOpc )

Static Function ReimprEti( cLocImp, nOpc )
Local   lErro := .f.
Default nOpc  := 1

If IsTelNet()	
	VTMSG(STR0009)				 //"Imprimindo..."
EndIf

If nOpc == 2
	lErro := !( ImprPallet( cLocImp, CB0->CB0_PALLET, .F. ) )
Else	
	If CB0->CB0_TIPO == "01" //Tipo '01' produto
	If CBProdUnit( CB0->CB0_CODPRO )
			lErro:= ! ACDI10PR( cEtiq, cLocImp )
		Else 
			lErro:= ! ACDI10CX( cEtiq, cLocImp )	
		EndIf	

	ElseIf CB0->CB0_TIPO == "02" //Tipo '02' localizacao
		lErro :=! ACDI020LO(cEtiq,cLocImp)

	ElseIf CB0->CB0_TIPO == "04" //Tipo '04' operador
		lErro :=! ACDI060US(cEtiq,cLocImp)

	ElseIf CB0->CB0_TIPO == "06" //Tipo '06' transportadora
		lErro :=! ACDI050Tr(cEtiq,cLocImp)

	Else
	If IsTelNet()
			VTAlert(STR0003,STR0004,.T.,3000) //"Rotina de impressao nao disponivel para esta etiqueta"###"Atencao"
	Else
			MsgStop(STR0003) //"Rotina de impressao nao disponivel para esta etiqueta"
	EndIf

	EndIf
EndIf

If lErro
	If IsTelNet()
		VTAlert(STR0005,STR0004,.T.,3000)		 //"Problema na impressao"###"Atencao"		   
	Else
		MsgStop(STR0005) //"Problema na impressao"
	EndIf
EndIf

Return !lErro
