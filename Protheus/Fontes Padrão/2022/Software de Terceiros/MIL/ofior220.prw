#INCLUDE "OFIOR220.CH"
#INCLUDE "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOR220 ³ Autor ³ Eveli Morasco         ³ Data ³ 05/02/93 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Listagem dos itens inventariados                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Gen‚rico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcelo Pim.³04/12/97³07906A³Definir a moeda a ser utilizada(MV_PAR10) ³±±
±±³Marcelo Pim.³09/12/97³07618A³Ajuste no posicionamento inicial do B7 p/ ³±±
±±³            ³        ³      ³nao utilizar o Local padrao.              ³±±
±±³Fernando J. ³23/09/98³06744A³Incluir informa‡”oes de LOTE, SUB-LOTE e  ³±±
±±³            ³        ³      ³NUMERO DE SERIE.                          ³±±
±±³Rodrigo Sar.³17/11/98³18459A³Acerto na impressao qdo almoxarIfado CQ   ³±±
±±³Cesar       ³30/03/99³20706A³Imprimir Numero do Lote                   ³±±
±±³Cesar       ³30/03/99³XXXXXX³Manutencao na SetPrint()                  ³±±
±±³Fernando Jol³20/09/99³19581A³Incluir pergunta "Imprime Lote/Sub-Lote?" ³±±
±±³Patricia Sal³30/12/99³XXXXXX³Acerto LayOut (Doc. 12 digitos);Troca da  ³±±
±±³            ³        ³      ³PesqPictQt() pela PesqPict().             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOR220
Local oReport
Local aArea := GetArea()
Private cImp := ""
If FindFunction("TRepInUse") .and. TRepInUse()
	oReport := ReportDef()
	oReport:PrintDialog()
Else
	FS_OFR220R3()
EndIf
RestArea( aArea )
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ReportDef³ Autor ³ Andre Luis Almeida    ³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatorio usando o TReport                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef()
Local oReport
Local oSection1
Local oCell
oReport := TReport():New("OFIOR220",STR0001,"OFR22A",{|oReport| OFR220IMP(oReport)})

oSection1 := TRSection():New(oReport,OemToAnsi("Secao 1"),{})
oSection1:lReadOnly := .T.
TRCell():New(oSection1,"",,"","@!",220,,{|| substr(cImp,001,220) })

Return oReport

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFR220IMP³ Autor ³ Andre Luis Almeida    ³ Data ³ 17/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Executa a impressao do relatorio do TReport                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Oficina                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFR220IMP(oReport)
Local oSection1 := oReport:Section(1)
Local nSB7Cnt  := 0
Local nTotal   := 0
Local nTotVal  := 0
Local nSubVal  := 0
Local i        := 0
Local cAnt     := ""
Local cSeek    := ""
Local cCompara := ""
Local cLocaliz := ""
Local cNumSeri := ""
Local cLoteCtl := ""
Local cNumLote := ""
Local aSaldo   := {}
Local aSalQtd  := {}
Local aCM      := {}
Local	cLocCQ   := GetMV("MV_CQ")
PERGUNTE("OFR22A",.F.)
DbSelectArea("SB1")
DbSetOrder(1)
DbSeek( xFilial("SB1") + MV_PAR01 , .t. )
oReport:SetMeter(RecCount())
oSection1:Init()
Do While !Eof() .and. !oReport:Cancel() .and. SB1->B1_FILIAL == xFilial("SB1") .and. SB1->B1_COD <= MV_PAR02
	oReport:IncMeter()
	If ( SB1->B1_TIPO < MV_PAR04 ) .or. ( SB1->B1_TIPO > MV_PAR05 )
		DbSelectArea("SB1")
		DbSkip()
		Loop
	EndIf
	If ( SB1->B1_LOCPAD < MV_PAR06 ) .or. ( SB1->B1_LOCPAD > MV_PAR07 )
		DbSelectArea("SB1")
		DbSkip()
		Loop
	EndIf
	If ( SB1->B1_GRUPO < MV_PAR08 ) .or. ( SB1->B1_GRUPO > MV_PAR09 )
		DbSelectArea("SB1")
		DbSkip()
		Loop
	EndIf
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek( xFilial("SB2") + SB1->B1_COD )
	Do While !Eof() .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == SB1->B1_COD
		If SB2->B2_DINVENT > MV_PAR03 // Ate a Data de Selecao
			DbSelectArea("SB2")
			DbSkip()
			Loop
		EndIf
		If ( SB2->B2_LOCAL < MV_PAR06 ) .or. ( SB2->B2_LOCAL > MV_PAR07 )
			DbSelectArea("SB2")
			DbSkip()
			Loop
		EndIf
		DbSelectArea("SB7")
		DbSetOrder(1)
		DbSeek( xFilial("SB7") + DtoS(MV_PAR03) + SB2->B2_COD + SB2->B2_LOCAL )
		Do While !Eof() .and. SB7->B7_FILIAL == xFilial("SB7") .and. DtoS(SB7->B7_DATA) + SB7->B7_COD + SB7->B7_LOCAL == DtoS(MV_PAR03) + SB2->B2_COD + SB2->B2_LOCAL
			nTotal   := 0
			nSB7Cnt  := 0
			cSeek    := xFilial("SB7")+DtoS(MV_PAR03)+SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE
			cCompara := "SB7->B7_FILIAL+DTOS(SB7->B7_DATA)+SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE"
			cLocaliz := SB7->B7_LOCALIZ
			cNumSeri := SB7->B7_NUMSERI
			cLoteCtl := SB7->B7_LOTECTL
			cNumLote := SB7->B7_NUMLOTE
			Do While !SB7->(Eof()) .and. cSeek == &(cCompara)
				If ( SB7->B7_LOCAL < MV_PAR06 ) .or. ( SB7->B7_LOCAL > MV_PAR07 )
					DbSelectArea("SB7")
					DbSkip()
					Loop
				EndIf
				nSB7Cnt++
				cImp := ""
				If nSB7Cnt == 1
					cImp += left(SB1->B1_GRUPO,04)+" "+left(SB1->B1_CODITE,21)+" "+left(SB1->B1_COD,30)+" "+left(SB1->B1_DESC,15)+" "
				EndIf
		    	If MV_PAR11 == 1
		    		cImp += left(SB7->B7_LOTECTL,10)+" "+left(SB7->B7_NUMLOTE,06)+" "
     				If MV_PAR13 == 1
		  				cImp += left(SB7->B7_LOCALIZ,15)+" "+left(SB7->B7_NUMSERI,20)+" "
					EndIf
					If nSB7Cnt == 1
			  			cImp += left(SB1->B1_TIPO,02)+" "+left(SB1->B1_UM,02)+" "+left(SB2->B2_LOCAL,02)+" "
					EndIf
			    	cImp += SB7->B7_DOC+" "+Transform(SB7->B7_QUANT,SB7->(PesqPict("SB7","B7_QUANT",10)))
		   		oSection1:PrintLine()
		   		cImp := ""
				Else
				 	If MV_PAR13 == 1
				    	cImp += left(SB7->B7_LOCALIZ,15)+" "+left(SB7->B7_NUMSERI,20)+" "
					EndIf
			   	If nSB7Cnt == 1
	    				cImp += left(SB1->B1_TIPO,02)+" "+left(SB1->B1_UM,02)+" "+left(SB2->B2_LOCAL,02)+" "
					EndIf
			      cImp += SB7->B7_DOC+" "+Transform(SB7->B7_QUANT, SB7->(PesqPict("SB7","B7_QUANT",15)))
		   		oSection1:PrintLine()
		   		cImp := ""
			  	EndIf
				nTotal += SB7->B7_QUANT
				DbSelectArea("SB7")
				DbSkip()
			EndDo
			If nSB7Cnt == 0
				DbSelectArea("SB2")
				DbSkip()
				Loop
			EndIf
			If nSB7Cnt > 1
				cImp += STR0017+Transform(nTotal,SB7->(PesqPict("SB7","B7_QUANT",10)))
			EndIf
			aSaldo := CalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1)
			If (Localiza(SB2->B2_COD) .and. !Empty(cLocaliz+cNumSeri)) .or. (Rastro(SB2->B2_COD) .and. !Empty(cLotectl+cNumLote))
				aSalQtd := CalcEstL(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1,cLoteCtl,cNumLote,cLocaliz,cNumSeri)
				aSaldo[1] := aSalQtd[1]
				aSaldo[2] := aSaldo[2] / aSaldo[1] * aSalQtd[1]
				aSaldo[3] := aSaldo[3] / aSaldo[1] * aSalQtd[1]
				aSaldo[4] := aSaldo[4] / aSaldo[1] * aSalQtd[1]
				aSaldo[5] := aSaldo[5] / aSaldo[1] * aSalQtd[1]
				aSaldo[6] := aSaldo[6] / aSaldo[1] * aSalQtd[1]
				aSaldo[7] := aSalQtd[7]
			Else
				If cLocCQ == SB2->B2_LOCAL
					aSalQtd := A340QtdCQ(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1,"")
					aSaldo[1] := aSalQtd[1]
					aSaldo[2] := aSaldo[2] / aSaldo[1] * aSalQtd[1]
					aSaldo[3] := aSaldo[3] / aSaldo[1] * aSalQtd[1]
					aSaldo[4] := aSaldo[4] / aSaldo[1] * aSalQtd[1]
					aSaldo[5] := aSaldo[5] / aSaldo[1] * aSalQtd[1]
					aSaldo[6] := aSaldo[6] / aSaldo[1] * aSalQtd[1]
					aSaldo[7] := aSalQtd[7]
				EndIf
			EndIf
			cImp += Transform(aSaldo[1],SB2->(PesqPict("SB2","B2_QFIM",10)))
			If nSB7Cnt > 0
				If MV_PAR12 == 1
					aCM := {}
					For i := 2 to Len(aSaldo)
						AADD(aCM,aSaldo[i]/aSaldo[1])
					Next
     			Else
              	aCM := PegaCMFim(SB2->B2_COD,SB2->B2_LOCAL)
				EndIf
            cImp += Transform(nTotal-aSaldo[1],SB7->(PesqPict("SB7","B7_QUANT",10)))+Transform((nTotal-aSaldo[1])*aCM[MV_PAR10],"@E 999,999,999,999.99")
	   		oSection1:PrintLine()
	   		cImp := ""
				nTotVal += ( nTotal - aSaldo[1] ) * aCM[MV_PAR10]
				nSubVal += ( nTotal - aSaldo[1] ) * aCM[MV_PAR10]
			EndIf
			oReport:SkipLine()
		EndDo
		DbSelectArea("SB2")
		DbSkip()
	EndDo
	DbSelectArea("SB1")
	DbSkip()
	If cAnt # SB1->B1_TIPO .and. nSB7Cnt >= 1
      cImp := "- "+left(space(14)+left(cAnt,4)+repl(".",51),51)+Transform(nSubVal,"@E 999,999,999,999.99")
  		oSection1:PrintLine()
  		cImp := ""
		cAnt    := SB1->B1_TIPO
		nSubVal := 0
		oReport:SkipLine()
		oReport:SkipLine()		
	EndIf
EndDo
If nTotVal # 0
	oReport:SkipLine()
   cImp := "- "+left(Alltrim(STR0020)+repl(".",51),51)+Transform(nTotVal,"@E 999,999,999,999.99")
	oSection1:PrintLine()
EndIf
oSection1:Finish()
Return Nil


//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FS_OFR220R3()
Local Tamanho := "G"
Local Titulo  := STR0001 // 'Listagem dos Itens Inventariados'
Local cDesc1  := STR0002 // 'Emite uma relacao que mostra o saldo em estoque e todas as'
Local cDesc2  := STR0003 // 'contagens efetuadas no inventario. Baseado nestas duas in-'
Local cDesc3  := STR0004 // 'formacoes ele calcula a dIferenca encontrada.'
Local cString := 'SB1'
Local nTipo   := 0
Local aOrd    := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008),OemToAnsi(STR0009)}		//' Por Codigo    '###' Por Tipo      '###' Por Grupo   '###' Por Descricao '###' Por Local    '
Local wnRel   := 'OFIOR220'
Private aReturn  := {OemToAnsi(STR0010), 1,OemToAnsi(STR0011), 2, 2, 1, '',1 }   //'Zebrado'###'Administracao'
Private nLastKey := 0
Private cPerg    := 'OFR22A'
Private limite   := 220
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01             // Produto de                           ³
//³ MV_PAR02             // Produto ate                          ³
//³ MV_PAR03             // Data de Selecao                      ³
//³ MV_PAR04             // De  Tipo                             ³
//³ MV_PAR05             // Ate Tipo                             ³
//³ MV_PAR06             // De  Local                            ³
//³ MV_PAR07             // Ate Local                            ³
//³ MV_PAR08             // De  Grupo                            ³
//³ MV_PAR09             // Ate Grupo                            ³
//³ MV_PAR10             // Qual Moeda (1 a 5)                   ³
//³ MV_PAR11             // Imprime Lote/Sub-Lote                ³
//³ MV_PAR12             // Custo Medio Atual/Ultimo Fechamento  ³
//³ MV_PAR13             // Imprime Localizacao ?                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
wnRel := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho,,.F.)
If nLastKey == 27
	Set Filter to
	Return Nil
EndIf
SetDefault(aReturn,cString)
RptStatus({|lEnd| C285Imp(aOrd,@lEnd,wnRel,cString,titulo,Tamanho)},titulo)
Return Nil
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C285IMP  ³ Autor ³ Rodrigo de A. Sartorio³ Data ³ 12.12.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ OFIOR220		   	                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C285Imp(aOrd,lEnd,WnRel,cString,titulo,Tamanho)
Local nSB7Cnt  := 0
Local i			:= 0
Local nTotal   := 0
Local nTotVal  := 0
Local nSubVal  := 0
Local nCntImpr := 0
Local cAnt     :='',cSeek:='',cCompara :='',cLocaliz:='',cNumSeri:='',cLoteCtl:='',cNumLote:=''
Local cRodaTxt := STR0012 // 'PRODUTO(S)'
Local aSaldo   := {}
Local aSalQtd  := {}
Local aCM      := {}
Local	cLocCQ	:= GetMV("MV_CQ")
Private	lLocCQ	:=.T.
Private cCondicao := ''
Private Li    := 80
Private m_Pag := 1
nTipo := If(aReturn[4]==1,15,18)
If Type('NewHead') # 'U'
	ewHead += ' (' + AllTrim(aOrd[aReturn[8]]) + ')'
Else
	Titulo += ' (' + AllTrim(aOrd[aReturn[8]]) + ')'
EndIf
If MV_PAR11 == 1
	If MV_PAR13 == 1
        Cabec1 := STR0023 // 'CODIGO          DESCRICAO                LOTE       SUB    LOCALIZACAO     NUMERO DE SERIE      TP GRP  UM AL DOCUMENTO            QUANTIDADE         QTD NA DATA   _____________DIfERENCA______________'
        Cabec2 := STR0024 // '                                                    LOTE                                                                         INVENTARIADA       DO INVENTARIO          QUANTIDADE              VALOR'
	Else
        Cabec1 := STR0013 // 'CODIGO          DESCRICAO                LOTE       SUB    TP GRP  UM AL DOCUMENTO            QUANTIDADE         QTD NA DATA   _____________DIfERENCA______________'
        Cabec2 := STR0014 // '                                                    LOTE                                    INVENTARIADA       DO INVENTARIO          QUANTIDADE              VALOR'
	EndIf	
Else
	If MV_PAR13 == 1
        Cabec1 := STR0025 // 'CODIGO          DESCRICAO                LOCALIZACAO     NUMERO DE SERIE      TP GRP  UM AL DOCUMENTO            QUANTIDADE         QTD NA DATA  _______________DIfERENCA_____________'
        Cabec2 := STR0026 // '                                                                                                               INVENTARIADA       DO INVENTARIO          QUANTIDADE              VALOR'
	Else
        Cabec1 := STR0021 // 'CODIGO          DESCRICAO                TP GRP  UM AL DOCUMENTO            QUANTIDADE         QTD NA DATA  _______________DIfERENCA_____________'
        Cabec2 := STR0022 // '                                                                          INVENTARIADA       DO INVENTARIO          QUANTIDADE              VALOR'
	EndIf
EndIf
DbSelectArea('SB2')
DbSetOrder(1)
DbSelectArea('SB7')
DbSetOrder(1)
DbSelectArea('SB1')
SetRegua(LastRec())
If aReturn[8] == 2
	DbSetOrder(2) //-- Tipo
	DbSeek(cFilial + MV_PAR04, .T.)
	cCondicao := '!Eof() .and. B1_TIPO <= MV_PAR05'
	cAnt      := B1_TIPO
ElseIf aReturn[8] == 3
	DbSetOrder(4) //-- Grupo
	DbSeek(cFilial + MV_PAR08, .T.)
	cCondicao := '!Eof() .and. B1_GRUPO <= MV_PAR09'
	cAnt      := B1_GRUPO
ElseIf aReturn[8] == 4
	DbSetOrder(3) //-- Descricao
	DbSeek(cFilial)
	cCondicao := '!Eof()'
ElseIf aReturn[8] == 5
	cNomArq := CriaTrab('', .F.) //-- Local
	cKey    := 'B1_FILIAL + B1_LOCPAD + B1_COD'
	IndRegua('SB1',cNomArq,cKey,,,STR0015) // 'Selecionando Registros...'
	DbSeek(cFilial + MV_PAR06, .T.)
	cCondicao := '!Eof() .and. B1_LOCPAD <= MV_PAR07'
Else
	DbSetOrder(1) //-- Codigo
	DbSeek(cFilial + MV_PAR01, .T.)
	cCondicao := '!Eof() .and. B1_COD <= MV_PAR02'
EndIf
nTotVal := 0
nSubVal := 0
Do While B1_FILIAL == cFilial .and. &cCondicao
	If (SB1->B1_COD > MV_PAR02 .and. aReturn[8] == 1)
		Exit
	ElseIf (SB1->B1_GRUPO < MV_PAR08) .or. (SB1->B1_GRUPO > MV_PAR09) .or. ;
		(SB1->B1_TIPO < MV_PAR04) .or. (SB1->B1_TIPO > MV_PAR05) .or. ;
		(SB1->B1_COD < MV_PAR01) .or. (SB1->B1_COD > MV_PAR02)
		SB1->(DbSkip())
		Loop
	EndIf
	If aReturn[8] == 2
		cAnt := SB1->B1_TIPO
	ElseIf aReturn[8] == 3
		cAnt := SB1->B1_GRUPO
	EndIf
	If lEnd
		@ pRow()+1, 000 PSAY STR0016 // 'CANCELADO PELO OPERADOR'
		Exit
	EndIf
	IncRegua()
	SB2->(DbSeek(xFilial('SB2') + SB1->B1_COD, .T.))
	Do While !SB2->(Eof()) .and. ;
		SB2->B2_FILIAL + SB2->B2_COD == xFilial('SB2') + SB1->B1_COD
		If SB2->B2_DINVENT > MV_PAR03
			SB2->(DbSkip())
			Loop
		EndIf
		SB7->(DbSeek(xFilial('SB7') + DtoS(MV_PAR03) + SB2->B2_COD + SB2->B2_LOCAL, .T.))
		Do While !SB7->(Eof()) .and. ;
			SB7->B7_FILIAL + DtoS(SB7->B7_DATA) + SB7->B7_COD + SB7->B7_LOCAL == xFilial('SB7') + DtoS(MV_PAR03) + SB2->B2_COD + SB2->B2_LOCAL
			If (SB7->B7_LOCAL < MV_PAR06) .or. (SB7->B7_LOCAL > MV_PAR07)
				SB7->(DbSkip())
				Loop
			EndIf
			nTotal  := 0
			nSB7Cnt := 0
			cSeek:=xFilial('SB7')+DtoS(MV_PAR03)+SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE
			cCompara:="SB7->B7_FILIAL+DTOS(SB7->B7_DATA)+SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE"
			cLocaliz:=SB7->B7_LOCALIZ
			cNumSeri:=SB7->B7_NUMSERI
			cLoteCtl:=SB7->B7_LOTECTL
			cNumLote:=SB7->B7_NUMLOTE
			Do While !SB7->(Eof()) .and. cSeek == &(cCompara)
				If (SB7->B7_LOCAL < MV_PAR06) .or. (SB7->B7_LOCAL > MV_PAR07)
					SB7->(DbSkip())
					Loop
				EndIf
				If Li > 55
					Cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
				EndIf
				nSB7Cnt++
				If nSB7Cnt == 1
	   	    	@ Li, 000 PSAY Left(SB1->B1_GRUPO,04)+" "+left(SB1->B1_CODITE,21)+" "+left(SB1->B1_COD,30)+" "+left(SB1->B1_DESC,15)
				EndIf
		    	If MV_PAR11 == 1
  			  		@ Li, 076 PSAY Left(SB7->B7_LOTECTL,10)
    				@ Li, 087 PSAY Left(SB7->B7_NUMLOTE,06)
	     			If MV_PAR13 == 1                            
	  					@ Li, 095 PSAY Left(SB7->B7_LOCALIZ,15)
						@ Li, 111 PSAY Left(SB7->B7_NUMSERI,20)
					EndIf 
				  	If nSB7Cnt == 1
		  				@ Li,If(MV_PAR13==1,131,094) PSAY Left(SB1->B1_TIPO   ,02)
						@ Li,If(MV_PAR13==1,137,099) PSAY Left(SB1->B1_UM     ,02)
			  			@ Li,If(MV_PAR13==1,139,101) PSAY Left(SB2->B2_LOCAL  ,02)
					EndIf
		       	@ Li,If(MV_PAR13==1,143,078) PSAY SB7->B7_DOC
				 	@ Li,If(MV_PAR13==1,168,089) PSAY Transform(SB7->B7_QUANT, SB7->(PesqPict("SB7",'B7_QUANT', 10)))
			      li++
				Else
				 	If MV_PAR13 == 1
				    	@ Li, 076 PSAY Left(SB7->B7_LOCALIZ,15)
				    	@ Li, 091 PSAY Left(SB7->B7_NUMSERI,20)
					EndIf	
		   	 	If nSB7Cnt == 1
	    				@ Li,If(MV_PAR13==1,111,076) PSAY Left(SB1->B1_TIPO   ,02)
		 				@ Li,If(MV_PAR13==1,115,080) PSAY Left(SB1->B1_UM     ,02)
		    			@ Li,If(MV_PAR13==1,118,083) PSAY Left(SB2->B2_LOCAL  ,02)
					EndIf 
	     	   	@ Li,If(MV_PAR13==1,122,087) PSAY SB7->B7_DOC 
					@ Li,If(MV_PAR13==1,142,104) PSAY Transform(SB7->B7_QUANT, SB7->(PesqPict("SB7",'B7_QUANT', 15)))
               li++
			  	EndIf
				nTotal += SB7->B7_QUANT
				SB7->(DbSkip())
			EndDo
			If nSB7Cnt == 0
				SB2->(DbSkip())
				Loop
			EndIf
			nCntImpr++
			If nSB7Cnt == 1
				Li--
			ElseIf nSB7Cnt > 1
				If MV_PAR11 == 1
					@ Li,If(MV_PAR13==1,100,063) PSAY STR0017 // 'TOTAL .................'
			        @ Li,If(MV_PAR13==1,168,122) PSAY Transform(nTotal, SB7->(PesqPict("SB7",'B7_QUANT', 10)))
				Else  
			     	@ Li,If(MV_PAR13==1,118,080) PSAY STR0017 // 'TOTAL .................'
			  	    @ Li,If(MV_PAR13==1,140,103) PSAY Transform(nTotal, SB7->(PesqPict("SB7",'B7_QUANT', 10)))
				EndIf
			EndIf
			If (Localiza(SB2->B2_COD) .and. !Empty(cLocaliz+cNumSeri)) .or. (Rastro(SB2->B2_COD) .and. !Empty(cLotectl+cNumLote))
				aSalQtd :=CalcEstL(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1,cLoteCtl,cNumLote,cLocaliz,cNumSeri)
				aSaldo  :=CalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1)
				aSaldo[1] := aSalQtd[1]
				aSaldo[2] := aSaldo[2] / aSaldo[1] * aSalQtd[1]
				aSaldo[3] := aSaldo[3] / aSaldo[1] * aSalQtd[1]
				aSaldo[4] := aSaldo[4] / aSaldo[1] * aSalQtd[1]
				aSaldo[5] := aSaldo[5] / aSaldo[1] * aSalQtd[1]
				aSaldo[6] := aSaldo[6] / aSaldo[1] * aSalQtd[1]
				aSaldo[7] := aSalQtd[7]
			Else
				If cLocCQ == SB2->B2_LOCAL
					aSalQtd := A340QtdCQ(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1,"")
					aSaldo  :=CalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1)
					aSaldo[1] := aSalQtd[1]
					aSaldo[2] := aSaldo[2] / aSaldo[1] * aSalQtd[1]
					aSaldo[3] := aSaldo[3] / aSaldo[1] * aSalQtd[1]
					aSaldo[4] := aSaldo[4] / aSaldo[1] * aSalQtd[1]
					aSaldo[5] := aSaldo[5] / aSaldo[1] * aSalQtd[1]
					aSaldo[6] := aSaldo[6] / aSaldo[1] * aSalQtd[1]
					aSaldo[7] := aSalQtd[7]
				Else
					aSaldo  :=CalcEst(SB2->B2_COD,SB2->B2_LOCAL,MV_PAR03+1)
				EndIf
			EndIf
			If MV_PAR11 == 1
                @ Li,If(MV_PAR13==1,190,152) PSAY Transform(aSaldo[1], SB2->(PesqPict("SB2",'B2_QFIM', 10)))
			Else
                @ Li,If(MV_PAR13==1,167,134) PSAY Transform(aSaldo[1], SB2->(PesqPict("SB2",'B2_QFIM', 10)))
			EndIf
			If nSB7Cnt > 0
				If MV_PAR12 == 1
					aCM := {}
					For i:=2 to Len(aSaldo)
						AADD(aCM,aSaldo[i]/aSaldo[1])
					Next i
                Else
                	aCM := PegaCMFim(SB2->B2_COD, SB2->B2_LOCAL)
				EndIf
				If MV_PAR11 == 1
			 	  	@ Li,If(MV_PAR13==1,208,162) PSAY Transform(nTotal-aSaldo[1], SB7->(PesqPict("SB7",'B7_QUANT', 10)))
			        @ Li,If(MV_PAR13==1,206,170) PSAY Transform((nTotal-aSaldo[1])*aCM[MV_PAR10], '@E 999,999,999,999.99')
			        li++
				Else
		        	@ Li,If(MV_PAR13==1,183,138) PSAY Transform(nTotal-aSaldo[1], SB7->(PesqPict("SB7",'B7_QUANT', 10)))
	  			    @ Li,If(MV_PAR13==1,194,169) PSAY Transform((nTotal-aSaldo[1])*aCM[MV_PAR10], '@E 999,999,999,999.99')
				    li++
		  		EndIf
				nTotVal += (nTotal-aSaldo[1])*aCM[MV_PAR10]
				nSubVal += (nTotal-aSaldo[1])*aCM[MV_PAR10]
			EndIf
			Li++
		EndDo
		SB2->(DbSkip())
	EndDo
	SB1->(DbSkip())
	If aReturn[8] == 2
		If cAnt # B1_TIPO .and. nSB7Cnt >= 1
			If MV_PAR11 == 1
	  			@ Li,If(MV_PAR13==1,199,166) PSAY STR0018 + Left(cAnt,2) + ' .............' // 'TOTAL DO TIPO '
				@ Li,If(MV_PAR13==1,134,197) PSAY Transform(nSubVal, '@E 999,999,999,999.99')
		       li++
			Else     
		  		@ Li,If(MV_PAR13==1,183,144) PSAY STR0018 + Left(cAnt,2) + ' .............' // 'TOTAL DO TIPO '
				@ Li,If(MV_PAR13==1,117,179) PSAY Transform(nSubVal, '@E 999,999,999,999.99')
		       li++
			EndIf 
			cAnt    := B1_TIPO
			nSubVal := 0
			Li += 2
		EndIf   
		LI++
	ElseIf aReturn[8] == 3
		If cAnt # B1_GRUPO
			If MV_PAR11 == 1
	  			@ Li,If(MV_PAR13==1,193,163) PSAY STR0019 + Left(cAnt,4) + ' .............' // 'TOTAL DO GRUPO '
				@ Li,If(MV_PAR13==1,134,197) PSAY Transform(nSubVal, '@E 999,999,999,999.99')
		    li++
			Else
		  		@ Li,If(MV_PAR13==1,176,137) PSAY STR0019 + Left(cAnt,4) + ' .............' // 'TOTAL DO GRUPO '
				@ Li,If(MV_PAR13==1,117,179) PSAY Transform(nSubVal, '@E 999,999,999,999.99')
			li++
			EndIf
			cAnt    := B1_GRUPO
			nSubVal := 0
			Li += 2
		EndIf
	EndIf
EndDo       
If nTotVal # 0
	Li++   
	If MV_PAR11 == 1
	 	@ Li,If(MV_PAR13==1,100,159) PSAY STR0020 // 'TOTAL DAS DIfERENCAS EM VALOR .............'
	    @ Li,If(MV_PAR13==1,154,203) PSAY Transform(nTotVal, '@E 999,999,999,999.99')
       li++
		Else 
	    @ Li,If(MV_PAR13==1,130,133) PSAY STR0020 // 'TOTAL DAS DIfERENCAS EM VALOR .............'
   		@ Li,If(MV_PAR13==1,194,184) PSAY Transform(nTotVal, '@E 999,999,999,999.99')
    li++
  	EndIf
EndIf
If Li # 80
	Roda(nCntImpr, cRodaTxt, Tamanho)
EndIf
DbSelectArea(cString)
RetIndex(cString)
DbSetOrder(1)
Set Filter To
SB2->(DbSetOrder(1))
SB7->(DbSetOrder(1))
SB1->(DbSetOrder(1))
If aReturn[8] == 5
	If File(cNomArq + OrdBagExt())
		fErase(cNomArq + OrdBagExt())
	EndIf
EndIf
If aReturn[5] == 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
EndIf
MS_FLUSH()
Return Nil
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////