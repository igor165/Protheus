#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA273.CH"

Static nRecSE2 := 0

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA273
Copia o título do contas a pagar

@author  Jonatas Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Function JURA273()
	Local aArea    := GetArea()
	Local aAreaSE2 := SE2->(GetArea())
	Local aAreaSED := SED->(GetArea())
	Local bExecuta := {|| FA050Inclu("SE2", SE2->(Recno()), 3)}

	If J273PreVld()[1]
		nRecSE2 := SE2->(Recno())
		FINA050(,,, bExecuta,,,,,,,, )
	EndIf

	RestArea(aAreaSED)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J273PreVld
Valida a cópia do título

@author  Jonatas Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Function J273PreVld()
Local lPEPreVld := ExistBlock("J273Pre")
Local lContinue := .F.
Local cMsgErro  := ""
Local cTitErro  := ""

	SA2->(DbSetOrder(1)) // A2_FILIAL + A2_FORNECE + A2_LOJA
	SA2->(DbSeek(xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA))

	SED->(DbSetOrder(1)) // ED_FILIAL + ED_CODIGO
	SED->(DbSeek(xFilial("SED") + SE2->E2_NATUREZ))

	Do Case
		Case !JVldTipoCp(SE2->E2_TIPO, .F.)
			cMsgErro := i18n(STR0008, {SE2->E2_TIPO}) // "Não é permitido copiar título do tipo '#1'."
			cTitErro := STR0007                       // "Tipo não permitido!"

		Case SA2->A2_MSBLQL == "1" // Fornecedor Bloqueado
			cMsgErro := STR0002 // "Não é permitido copiar título de fornecedor bloqueado."
			cTitErro := STR0001 // "Fornecedor bloqueado!"

		Case SED->ED_MSBLQL == "1" .Or. SED->ED_COND == "1"
			cMsgErro := STR0004 // "Não é permitido copiar título de natureza bloqueada."
			cTitErro := STR0007 // "Natureza bloqueada!"

		Case SED->ED_CCJURI == "5"
			cCbBoxCCJr := JurInfBox("ED_CCJURI", SED->ED_CCJURI, "3")

			cMsgErro := i18n(STR0006, {cCbBoxCCJr}) // "Não é permitido copiar título com natureza do tipo '#1'."
			cTitErro := STR0005                     //  "Natureza não permitida!"

		Case lPEPreVld
			lContinue := ExecBlock("J273Pre", .F. ,.F., {SE2->(Recno())})

			If ValType(lContinue) <> "L"
				lContinue := .F.
			EndIf
		OtherWise
			lContinue := .T.
	End Case

	If (!lContinue) .And. (!Empty(cMsgErro) .Or. !Empty(cTitErro))
		ApMsgAlert(cMsgErro, cTitErro)
	EndIf

Return {lContinue, cMsgErro, cTitErro}

//-------------------------------------------------------------------
/*/{Protheus.doc} J273LoadVar
Copia os dados do título posicionado para as variáveis de memória do
contas a pagar que está sendo aberto no modo de inclusão

@author  Jonatas Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Function J273LoadVar()
	Local aSE2Struct := SE2->(DBStruct())
	Local lPENoCopy  := ExistBlock("J273NCop")
	Local cPENoCopy  := ""
	Local cField     := ""
	Local xValue     := Nil
	Local nStru      := 0
	Local cSE2NoCopy := ""

	cSE2NoCopy += "E2_VENCTO |E2_VENCORI|E2_VENCREA|E2_BAIXA  |E2_NUMBOR |E2_DTBORDE|"
	cSE2NoCopy += "E2_LOTE   |E2_MOVIMEN|E2_VALLIQ |E2_NUMLIQ |E2_BCOCHQ |E2_AGECHQ |"
	cSE2NoCopy += "E2_BAIXA  |E2_BCOPAG |E2_LA     |E2_CTACHQ |E2_STATUS |E2_TITPAI |"
	cSE2NoCopy += "E2_TIPOLIQ|E2_DATALIB|E2_USUALIB|E2_STATLIB|E2_CODAPRO|E2_TIPOFAT|"
	cSE2NoCopy += "E2_FLAGFAT|E2_FATPREF|E2_FATURA |E2_DTFATUR|E2_FATFOR |E2_FATLOJ |"
	cSE2NoCopy += "E2_LINDIG |E2_CODBAR |E2_IDCNAB "

	If lPENoCopy
		cPENoCopy := ExecBlock("J273NCop", .F. ,.F., {cSE2NoCopy})

		If ValType(cPENoCopy) == "C" .And. !Empty(cPENoCopy)
			cSE2NoCopy := cPENoCopy
		EndIf
	EndIf

	For nStru := 1 To Len(aSE2Struct)
		cField := aSE2Struct[nStru][1]
		
		If PADR(cField, 10) $ cSE2NoCopy
			If cField = "E2_STATLIB"
				CriaVar("E2_STATLIB", .T.)
			EndIf
			Loop
		EndIf

		Do Case
			Case cField == "E2_FILIAL"
				xValue := xFilial("SE2")

			Case cField == "E2_NUM"
				xValue := ProxTitulo("SE2", SE2->E2_PREFIXO)

			Case cField == "E2_EMISSAO" .Or. cField == "E2_EMIS1"
				xValue := dDataBase

			Case cField == "E2_SALDO"
				xValue := SE2->E2_VALOR

			Case cField == "E2_ORIGEM"
				xValue := "FINA050"

			OtherWise
				xValue := SE2->(FieldGet(FieldPos(cField)))
		End Case
		
		&("M->" + cField) := xValue
	Next nField

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} J273RecSE2
Retorna o Recno da SE2 copiada

@Return nRecSE2, Recno da SE2 copiada

@author  Bruno Ritter, Jorge Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Function J273RecSE2()
Return nRecSE2

//-------------------------------------------------------------------
/*/{Protheus.doc} J273CpDesd
Copia desdobramentos

@param oModel, Modelo da OHF que está sendo ativo

@author  Bruno Ritter / Jorge Martins
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Function J273CpDesd(oModel)
	Local nRecSE2Pos := SE2->(Recno())
	Local cChaveTit  := ""
	Local cFieldOHF  := ""
	Local cFieldTab  := ""
	Local cNoCopy    := "OHF_FILIAL|OHF_IDDOC |OHF_CDESP |OHF_NZQCOD|OHF_CODLD |OHF_DTINCL|OHF_DTCONT|OHF_DTCONI"
	Local nStru      := 0
	Local nItem      := 0
	Local nTab       := 0
	Local nTamItem   := TamSX3("OHF_CITEM")[1]
	Local lAddLine   := .F.
	Local oModelOHF  := oModel:GetModel("OHFDETAIL")
	Local aOHFStruct := oModelOHF:GetStruct():GetFields()
	Local aTabOrig   := {"OHF", "OHG"}
	Local cTab       := ""
	Local lVirtual   := .F.
	Local lNatOriTra := .F.
	Local lNatAtuTra := .F.
	Local lOk        := .T.
	Local aErro      := {}
	Local cErro      := ""

	SE2->(DbGoTo(J273RecSE2()))
	cChaveTit  := SE2->E2_FILIAL + FINGRVFK7("SE2", SE2->E2_FILIAL+"|"+SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA)
	lNatOriTra := JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_CCJURI") == "7" // Transitória de pagamento

	SE2->(DbGoTo(nRecSE2Pos))
	lNatAtuTra := JurGetDados("SED", 1, xFilial("SED") + SE2->E2_NATUREZ, "ED_CCJURI") == "7" // Transitória de pagamento

	If !lNatOriTra .Or. lNatAtuTra
		For nTab := 1 To Len(aTabOrig)
			cTab := aTabOrig[nTab]

			(cTab)->(DbSetOrder(1)) // OHG_FILIAL + OHG_IDDOC + OHG_CITEM
			If (cTab)->(DbSeek(cChaveTit))
				While !(cTab)->(EOF()) .And. JGetField(cTab, "FILIAL") + JGetField(cTab, "IDDOC") == cChaveTit

					If !(JurGetDados("SED", 1, xFilial("SED") + JGetField(cTab, "CNATUR"), "ED_CCJURI") $ "5|6")
						IIf(lAddLine, oModelOHF:AddLine(), lAddLine := .T.)
						lOk := .T.

						For nStru := 1 To Len(aOHFStruct)
							cFieldOHF := aOHFStruct[nStru][3]
							cFieldTab := cTab + Substr(cFieldOHF, 4, 7)
							lVirtual  := aOHFStruct[nStru][14]

							Do Case
								Case lVirtual .Or. cFieldOHF $ cNoCopy
									Loop

								Case cFieldOHF == "OHF_CITEM"
									nItem++
									JurSetVal(oModelOHF, cFieldOHF, StrZero(nItem, nTamItem))

								Case cFieldOHF == "OHF_CPART"
									JurSetVal(oModelOHF, "OHF_SIGLA" , JurGetDados("RD0", 1, xFilial("RD0") + JGetField(cTab, "CPART") , "RD0_SIGLA"))
									JurSetVal(oModelOHF, "OHF_CPART" , JGetField(cTab, "CPART"))

								Case cFieldOHF == "OHF_CPART2"
									JurSetVal(oModelOHF, "OHF_SIGLA2", JurGetDados("RD0", 1, xFilial("RD0") + JGetField(cTab, "CPART2"), "RD0_SIGLA"))
									JurSetVal(oModelOHF, "OHF_CPART2", JGetField(cTab, "CPART2"))

								OtherWise
									JurSetVal(oModelOHF, cFieldOHF, (cTab)->(FieldGet(FieldPos(cFieldTab))))
							EndCase

							If oModel:HasErrorMessage()
								// Tenta reaproveitar a linha e limpa o erro e passa para um novo registro
								lAddLine := .F.
								nItem--
								aErro  := oModel:GetErrorMessage(.T.)
								cErro  += STR0009 + aErro[4] + CRLF // "Campo: "
								cErro  += STR0010 + aErro[6] + CRLF // "Problema: "
								cErro  += STR0011 + aErro[7] + CRLF // "Solução: "
								cErro  += Replicate( '-', 78 ) + CRLF + CRLF
								lOk := .F.
								Exit
							EndIf
						Next nStru
					EndIf
					(cTab)->(DbSkip())
				EndDo
				//Ir para o final de arquivo
				(cTab)->(DbGoBottom())
				(cTab)->(DbSkip())
			EndIf
		Next nTab

		If !lOk // Ocorreu um erro na última linha
			oModelOHF:DeleteLine()
		EndIf
	EndIf

	If !Empty(cErro)
		cErro := STR0012 + CRLF + STR0013 + CRLF + CRLF + cErro // "Não foi possível copiar um ou mais desdobramentos." / "Detalhes:"
		JurErrLog(cErro , STR0014) // "Atenção"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetField
Retorna o valor de um campo a partir da tabela posicionada

@param cTab, nome da tabela
@param cCampo, nome do campo sem o prefixo da tabela

@Return xValue, valor do campo

@author  Bruno Ritter
@since   09/04/2020
/*/
//-------------------------------------------------------------------
Static Function JGetField(cTab, cCampo)
	Local xValue := (cTab)->(FieldGet(FieldPos(cTab + "_" + cCampo)))
Return xValue
