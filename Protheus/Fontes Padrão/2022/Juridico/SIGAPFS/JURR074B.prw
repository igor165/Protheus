#include 'JURR074B.CH'
#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWPrintSetup.ch'
#INCLUDE "RPTDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURR074B()
Fun��o para gerar o relat�rio de listagem de protocolos (FWMsPrinter)

@param cProtIni , Protocolo Inicial
@param cProtFim , Protocolo Final
@param cProtTip , Tipo de Protocolo
@param lAutomato, Indica se a chamada foi feita via automa��o
@param cNameAuto, Nome do arquivo de relat�rio usado na automa��o

@author Mauricio Canalle
@since 02/05/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURR074B(cProtIni, cProtFim, cProtTip, lAutomato, cNameAuto)
	Local aArea           := Getarea()

	Local oFont14N        := TFont():New("Times New Roman", 9, 14, .T., .T.)
	Local oFont12         := TFont():New("Times New Roman", 9, 12, .T., .F.)
	Local oFont12N        := TFont():New("Times New Roman", 9, 12, .T., .T.)

	Local oPrint2         := Nil
	Local lAdjustToLegacy := .F. // Inibe legado de resolu��o com a TMSPrinter
	Local nLargTxt        := 620  // largura em pixel para alinhamento da funcao sayalign
	Local nLin            := 03
	Local cFaturas        := ""
	Local aVias           := {}
	Local nI              := 0
	Local lNewPage        := .T. // controla pagina nova - salto de pagina
	Local nCntPage        := 1  // contador de pagina
	Local cDataHora       := ""

	Default lAutomato     := .F.
	Default cNameAuto     := ""

	cDataHora := IIf(lAutomato, "", DToC(dDataBase) + '   ' + Time())

	NXH->(DbSetOrder(1))
	NXI->(DbSetOrder(1))
	NXJ->(DbSetOrder(1))
	NSO->(DbSetOrder(1))

	NXH->(DbSeek(xFilial('NXH') + cProtIni, .T.))

	If !lAutomato
		oPrint2 := FWMsPrinter():New('JU074B', IMP_PDF, lAdjustToLegacy,, .T.,,, "PDF" )
	Else
		oPrint2 := FWMSPrinter():New(cNameAuto, IMP_SPOOL,,, .T.,,,, .T.) // Inicia o relat�rio
		// Alterar o nome do arquivo de impress�o para o padr�o de impress�o automatica
		oPrint2:CFILENAME  := cNameAuto
		oPrint2:CFILEPRINT := oPrint2:CPATHPRINT + oPrint2:CFILENAME
	EndIf

	oPrint2:SetResolution(78) // Tamanho estipulado
	oPrint2:SetPortrait()
	oPrint2:SetPaperSize(0, 297, 210) // Tamanho da folha
	oPrint2:SetMargin(10,10,10,10)

	While !NXH->(Eof()) .and. xFilial('NXH') == NXH->NXH_FILIAL .and. NXH->NXH_COD >= cProtIni .and. NXH->NXH_COD <= cProtFim
		If AllTrim(NXH->NXH_CTIPO) == AllTrim(cProtTip) .or. Empty(cProtTip)
			cFaturas := ''
			aVias    := {}

			If NXI->(DbSeek(xFilial('NXI')+NXH->NXH_COD))   // FATURAS
				While !NXI->(Eof()) .and. xFilial('NXI') == NXI->NXI_FILIAL .and. NXI->NXI_CPROT == NXH->NXH_COD
					cFaturas += NXI->NXI_CFAT + ' '
					NXI->(DbSkip())
				End
			EndIf

			If NXJ->(DbSeek(xFilial('NXJ')+NXH->NXH_COD))  // VIAS PROTOCOLO
				While !NXJ->(Eof()) .and. xFilial('NXJ') == NXJ->NXJ_FILIAL .and. NXJ->NXJ_CPROT == NXH->NXH_COD
					Aadd(aVias, {NXJ->NXJ_COD, DTOC(NXJ->NXJ_DTENV), DTOC(NXJ->NXJ_DTREC), NXJ->NXJ_QUEMRE})
					NXJ->(DbSkip())
				End
			EndIf

			If lNewpage  // NOVA PAGINA
				oPrint2:StartPage() // Inicia uma nova p�gina

				oPrint2:SayAlign(nLin, 01, cDataHora, oFont12, nLargTxt, 200, CLR_BLACK, 1, 0)  // data e hora

				nLin += 12

				oPrint2:SayAlign(nLin, 01,  STR0001, oFont14N, nLargTxt, 200, CLR_BLACK, 2, 0)  // Relat�rio de Protocolos

				nLin += 25

				lNewPage := .F.
			EndIf

			oPrint2:Line(nLin, 01, nLin, nLargTxt, CLR_BLACK, "-1") 

			nLin += 10

			oPrint2:Say(nLin, 001, STR0002, oFont12N) // No Prot.
			oPrint2:Say(nLin, 150, STR0003, oFont12N) // Tipo
			oPrint2:Say(nLin, 350, STR0004, oFont12N) // Cliente

			nLin += 08

			oPrint2:Line(nLin, 01, nLin, nLargTxt, CLR_BLACK, "-1")

			nLin += 12

			oPrint2:Say(nLin, 001, NXH->NXH_COD, oFont12) // No Prot.
			oPrint2:Say(nLin, 150, Posicione("NSO", 1, xFilial("NSO") + NXH->NXH_CTIPO, "NSO_DESC"), oFont12) // Tipo
			oPrint2:Say(nLin, 350, AllTrim(NXH->NXH_RZSOC), oFont12) // Cliente

			nLin += 20

			oPrint2:Say(nLin, 001, STR0005, oFont12N) // Contato
			oPrint2:Say(nLin, 150, STR0006, oFont12N) // Endere�o
			oPrint2:Say(nLin, 350, STR0007, oFont12N) // Faturas

			nLin += 12

			oPrint2:Say(nLin, 001, AllTrim(NXH->NXH_CONTAT), oFont12) // Contato
			oPrint2:Say(nLin, 150, AllTrim(NXH->NXH_LOGRAD) + ' ' + AllTrim(NXH->NXH_BAIRRO) , oFont12) // Endere�o1
			oPrint2:Say(nLin, 350, Substr(cFaturas, 1, 150), oFont12) // Faturas1

			nLin += 12

			oPrint2:Say(nLin, 150, AllTrim(NXH->NXH_CEP) + ' ' + AllTrim(NXH->NXH_CID) + ' ' + AllTrim(NXH->NXH_UF) + ' ' + AllTrim(NXH->NXH_PAIS), oFont12) // Endere�o2
			oPrint2:Say(nLin, 350, Substr(cFaturas, 151, 150), oFont12) // Faturas2

			nLin += 12

			oPrint2:Say(nLin, 001, STR0008, oFont12N) // Observa��es

			nLin += 20

			If Len(aVias) > 0
				oPrint2:Say(nLin, 001, STR0009, oFont12N) // Via
				oPrint2:Say(nLin, 030, STR0010, oFont12N) // Data Envio
				oPrint2:Say(nLin, 120, STR0011, oFont12N) // Data Recebimento
				oPrint2:Say(nLin, 250, STR0012, oFont12N) // Quem Recebeu
				oPrint2:Say(nLin, 350, STR0013, oFont12N) // Observa��o

				For nI := 1 to len(aVias)
					nLin += 12
					oPrint2:Say(nLin, 001, aVias[nI, 1], oFont12) // Via
					oPrint2:Say(nLin, 030, aVias[nI, 2], oFont12) // Data Envio
					oPrint2:Say(nLin, 120, aVias[nI, 3], oFont12) // Data Recebimento
					oPrint2:Say(nLin, 250, aVias[nI, 4], oFont12) // Quem Recebeu
				Next

				nLin += 20
			EndIf
		EndIf

		NXH->(DbSkip())

		// CONTROLE DE SALTO DE PAGINA
		If nLin >= 700 .or. NXH->(Eof()) .or. NXH->NXH_COD > cProtFim
			oPrint2:SayAlign(If(nLin > 810, nLin, 810), 01, Strzero(nCntPage, 3), oFont12, nLargTxt, 200, CLR_BLACK, 1, 0)  // numero da pagina

			oPrint2:EndPage() // Finaliza a p�gina

			nLin     := 03
			lNewPage := .T.
			nCntPage++
		EndIf
	End

	oPrint2:Preview()

	RestArea(aArea)

Return