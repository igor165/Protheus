#include 'protheus.ch'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AGRM001  º Autor ³ Ricardo Tomasi     º Data ³  18/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Recalcula custo para as aplicações baseadas no custo medio º±±
±±º          ³ dos produtos e custo estimado da mão de obra e equipamento º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function AGRM001()
Local oDlg
Local oSay1
Local oSay2
Local oGet1
Local oSBtn1
Local oSBtn2
Private dDataIni := CToD('  /  /  ')

oDlg := MSDIALOG():Create()
oDlg:cName := 'oDlg'
oDlg:cCaption := "Reprocessamento de Custos da Aplicação"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 308
oDlg:nHeight := 191
oDlg:lShowHint := .F.
oDlg:lCentered := .T.

oSay1 := TSAY():Create(oDlg)
oSay1:cName := 'oSay1'
oSay1:cCaption := "Este reprocessamento ira recalcular todos os custos das aplicações apartir da data informada até a DataBase do sistema!"
oSay1:nLeft := 10
oSay1:nTop := 10
oSay1:nWidth := 280
oSay1:nHeight := 60
oSay1:lShowHint := .F.
oSay1:lReadOnly := .F.
oSay1:Align := 0
oSay1:lVisibleControl := .T.
oSay1:lWordWrap := .T.
oSay1:lTransparent := .F.

oSay2 := TSAY():Create(oDlg)
oSay2:cName := 'oSay2'
oSay2:cCaption := "Data Inicial"
oSay2:nLeft := 10
oSay2:nTop := 90
oSay2:nWidth := 60
oSay2:nHeight := 21
oSay2:lShowHint := .F.
oSay2:lReadOnly := .F.
oSay2:Align := 0
oSay2:lVisibleControl := .T.
oSay2:lWordWrap := .F.
oSay2:lTransparent := .F.

oGet1 := TGET():Create(oDlg)
oGet1:cName := 'oGet1'
oGet1:nLeft := 70
oGet1:nTop := 90
oGet1:nWidth := 120
oGet1:nHeight := 21
oGet1:lShowHint := .F.
oGet1:lReadOnly := .F.
oGet1:Align := 0
oGet1:cVariable := 'dDataIni'
oGet1:bSetGet := {|u| If(PCount()>0,dDataIni:=u,dDataIni) }
oGet1:lVisibleControl := .T.
oGet1:lPassword := .F.
oGet1:lHasButton := .F.
oGet1:bValid := {|| dDataIni < dDataBase }

oSBtn1 := SBUTTON():Create(oDlg)
oSBtn1:cName := 'oSBtn1'
oSBtn1:cCaption := "Confirmar"
oSBtn1:nLeft := 175
oSBtn1:nTop := 130
oSBtn1:nWidth := 52
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 1
oSBtn1:bAction := {|| fIniciar(), oDlg:End() }

oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := 'oSBtn2'
oSBtn2:cCaption := "Cancelar"
oSBtn2:nLeft := 235
oSBtn2:nTop := 130
oSBtn2:nWidth := 52
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 2
oSBtn2:bAction := {|| oDlg:End() }

oDlg:Activate()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fIniciar º Autor ³ Ricardo Tomasi     º Data ³  18/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Recalcula custo para as aplicações baseadas no custo medio º±±
±±º          ³ dos produtos e custo real da mão de obra e equipamentos.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fIniciar()
Local oDlg
Local oSay1

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := "Executando..."
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 245
oDlg:nHeight := 100
oDlg:lShowHint := .F.
oDlg:lCentered := .F.
oDlg:bInit := {|| fProcess(), oDlg:End() }

oSay1 := TSAY():Create(oDlg)
oSay1:cName := "oSay1"
oSay1:cCaption := "Aguarde em execução !!!"
oSay1:nLeft := 61
oSay1:nTop := 26
oSay1:nWidth := 125
oSay1:nHeight := 18
oSay1:lShowHint := .F.
oSay1:lReadOnly := .F.
oSay1:Align := 0
oSay1:lVisibleControl := .T.
oSay1:lWordWrap := .F.
oSay1:lTransparent := .F.

oDlg:Activate()

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ fProcess º Autor ³ Ricardo Tomasi     º Data ³  18/11/2005 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Recalcula custo para as aplicações baseadas no custo medio º±±
±±º          ³ dos produtos e custo real da mão de obra e equipamentos.   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Clientes Microsiga                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function fProcess()
Local nCusto := 0

dbSelectArea('NP5')
dbSetOrder(1)
dbGotop()
While .Not. Eof()

	If NP5->NP5_DATA >= dDataIni .And. NP5->NP5_DATA <= dDataBase

		dbSelectArea('NP6')
		dbSetOrder(1)
		dbGotop()
		If dbSeek(xFilial('NP6')+NP5->NP5_CODIGO)
			While .Not. Eof() .And. NP6->NP6_CODIGO == NP5->NP5_CODIGO
				Do Case
					Case NP6->NP6_TIPO == 'MO'
						//Calcula Custo da MO
						dbSelectArea('NNA')
						dbSetOrder(1)
						If dbSeek(xFilial('NNA')+NP6->NP6_MOCOD)
							nCusto := NP6->NP6_QTDTOT * NNA->NNA_CUSREA
						EndIf
					Case NP6->NP6_TIPO == 'EQ'
						//Calcula Custo do EQ
						dbSelectArea('NNB')
						dbSetOrder(1)
						If dbSeek(xFilial('NNB')+NP6->NP6_EQCOD)
							nCusto := NP6->NP6_QTDTOT * NNB->NNB_CUSREA
						EndIf
					Case NP6->NP6_TIPO == 'PD'
						//Calcula Custo do PD
						dbSelectArea('SB2')
						dbSetOrder(1)
						If dbSeek(xFilial('SB2')+NP6->NP6_PDCOD+NP6->NP6_LOCAL)
							nCusto := NP6->NP6_QTDTOT * B2_CM1
						EndIf
				EndCase
				dbSelectArea('NP6')
				If RecLock('NP6',.f.)
					NP6->NP6_CUSTO := nCusto
					msUnLock()
				EndIf
				dbSkip()
			EndDo
		EndIf

	EndIf

	dbSelectArea('NP5')
	dbSkip()
EndDo

Return(.t.)