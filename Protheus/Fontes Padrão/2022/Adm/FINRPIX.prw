#Include "PROTHEUS.CH"
#INCLUDE "FWPRINTSETUP.CH"
#Include "RPTDEF.CH"
#Include "TOPCONN.CH"
#Include "TBICONN.CH"
#Include "FinRPIX.ch"

Static __oRegPix := Nil

/*/{Protheus.doc} FINRPIX
	Relat�rio de impress�o do QrCode 
	dos t�tulos em situa��o de carteira pix
	com entrada confirmada no banco
	
	@author Eduardo Augusto
	@since 15/10/2020
	@version P12
	
	@Param cFilCli, Char, Filial do cliente
	@Param cCliente, Char, C�digo do cliente
    @Param cLojaCli, Char, Loja do cliente
	@Param aIdDocs, Array, vetor com os
	Identificadores dos	documentos no complemento 
	de t�tulo
	@return cFilePrint, Char, Diret�rio+Nome do relat�rio criado
	/*/
Function FINRPIX(cFilCli, cCliente, cLojaCli, aIdDocs) As Char
	Local cNomeArq   As Character
	Local cFile 	 As Character
	Local cQry		 As Character
	Local cCodCli	 As Character
	Local cChvNFE	 As Character
	Local cSerie	 As Character
	Local cCliDe	 As Character
	Local cCliAte	 As Character
	Local cPathPrint As Character
	Local cFilePrint As Character
	Local cIdDoc     As Character
	Local cF71Tmp    As Character
	Local cFilF71    As Character
	Local cFilSF2    As Character
	Local nLin		 As Numeric
	Local nLinFim	 As Numeric
	Local nCol		 As Numeric
	Local nColFim	 As Numeric
	Local nPagina	 As Numeric
	Local nX    	 As Numeric
	Local nPrintType As Numeric
	Local nFlags	 As Numeric
	Local nLocal	 As Numeric
	Local nTotalDoc  As Numeric
	Local lCabec	 As Logical
	Local l890Mail   As Logical
	Local lCopy      As Logical
	Local lJob		 As Logical
	Local oPrinter	 As Object
	Local oSetup	 As Object
	Local aAreaF71   As Array
	Local dEmisIni	 As Date
	Local dEmisFim	 As Date
	Local dVencIni	 As Date
	Local dVencFim	 As Date

	Private cPerg 	As Character

	Default cFilCli  := ""
	Default cCliente := ""
	Default cLojaCli := ""
	Default aIdDocs  := {}

	cQry		:= ""
	cIdDoc		:= ""
	oPrinter	:= Nil
	oSetup		:= Nil
	cFile 		:= "pix.rel"
	nLin		:= 10
	nLinFim		:= 700
	nCol		:= 10
	nColFim		:= 585
	lCabec		:= .T.
	cCodCli		:= ""
	nPagina		:= 1
	cChvNFE		:= ""
	cSerie		:= ""
	nFlags 		:= PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
	nPrintType	:= 6
	nLocal		:= 2
	cCliDe		:= ""
	cCliAte		:= ""
	dEmisIni	:= Ctod("  /  /  ")
	dEmisFim	:= Ctod("  /  /  ")
	dVencIni	:= Ctod("  /  /  ")
	dVencFim	:= Ctod("  /  /  ")
	cPerg		:= "FINPIX"
	aAreaF71	:= F71->(GetArea())
	cFilePrint  := ''
	l890Mail    := .F.
	nX			:= 0
	cPathPrint  := ''
	lCopy		:= .F.
	cNomeArq	:= ''
	lJob		:= Upper(Funname()) == "F890SCHPIX"
	cF71Tmp     := ""
	nTotalDoc   := 0
	cFilF71     := ""
	cFilSF2     := ""

	If !Empty(Alltrim(cCliente)) .AND. Valtype(cCliente) == 'C'
		
		cNomeArq   := cCliente + '_' + cLojaCli + '_' + StrTran(Time(),':','-')
		cFile      := cNomeArq + '.rel'
		cFilePdf   := cNomeArq + '.pdf'
		l890Mail    := .T.
		nLocal	   := 1
		nPrintType := IMP_PDF
		cLocal 	   := '\SPOOL\'

		If lJob
			oPrinter := FWMSPrinter():New(cFilePdf, IMP_PDF, .F., '', .T., .F., , , .T., .T., , .F.)
			oPrinter:cPathPDF := cLocal
			oPrinter:cFilePrint:= oPrinter:cPathPrint + cFilePdf
		Else
			oPrinter := FWMSPrinter():New(cFile,IMP_PDF,.F.,cLocal,.T.,,,,,,.F.,)
			oPrinter:lViewPDF := .F.
		Endif

	Else	
		Pergunte("FINPIX", .F.)
		oPrinter := FWMSPrinter():New(cFile, IMP_SPOOL, .F., Nil, .T., Nil, Nil, Nil, Nil, .F., Nil, .T., Nil)
		oSetup   := FWPrintSetup():New(nFlags, STR0001)	// "Relatorio PIX"
		oSetup:SetUserParms({||Pergunte(cPerg, .T.)})
		oSetup:SetPropert(PD_PRINTTYPE, nPrintType )
		oSetup:SetPropert(PD_ORIENTATION, 1)
		oSetup:SetPropert(PD_DESTINATION, nLocal )
		oSetup:SetPropert(PD_MARGIN, {0,0,0,0} )
		oSetup:SetPropert(PD_PAPERSIZE, 1 )
		
		If oSetup:Activate() == PD_OK
			If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
				oPrinter:nDevice := IMP_SPOOL
				oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]
				oPrinter:lServer := .F.
				oPrinter:lViewPDF := .F.
			ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
				oPrinter:nDevice := IMP_PDF
				oPrinter:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
			EndIf
		Else
			oPrinter:Deactivate()
			Pergunte("FINPIX", .F.)
			Return
		EndIf
	Endif
	
	cCliDe   := Mv_Par01
	cCliAte	 := Mv_Par02
	dEmisIni := Mv_Par03
	dEmisFim := Mv_Par04
	dVencIni := Mv_Par05
	dVencFim := Mv_Par06

	Pergunte("FINPIX", .F.)

	oPrinter:SetParm( "-RFS")
	oPrinter:SetPortrait()
	oPrinter:StartPage()   	// Inicia uma nova p�gina

	oFont1	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
	oFont1N	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
	oFont2	:= TFont():New("Courier New",11,11,,.F.,,,,.T.,.F.)
	oFont3	:= TFont():New("Courier New",12,12,,.F.,,,,.T.,.F.)
	oFont4	:= TFont():New("Courier New",13,13,,.T.,,,,.T.,.F.)

	If !l890Mail
		If __oRegPix == Nil
			cQry := "SELECT F71_IDDOC, F71_CODCLI, F71_SEQ, R_E_C_N_O_ RECF71 FROM ? WHERE "
			cQry += "F71_FILIAL = ? "
			cQry += "AND F71_STATUS IN ('3','4') AND F71_EMVPIX IS NOT NULL "
			cQry += "AND F71_CODCLI BETWEEN ? AND ? "
			cQry += "AND F71_EMISSA BETWEEN ? AND ? "
			cQry += "AND F71_VENCTO BETWEEN ? AND ? AND D_E_L_E_T_ = ' ' "
			cQry += "ORDER BY F71_CODCLI "
			cQry      := ChangeQuery(cQry)
			__oRegPix := FWPreparedStatement():New(cQry)
		EndIf
		
		__oRegPix:SetNumeric(1, RetSqLName("F71"))
		__oRegPix:SetString(2, xFilial("F71"))
		__oRegPix:SetString(3, cCliDe)
		__oRegPix:SetString(4, cCliAte)
		__oRegPix:SetDate(5, dEmisIni)
		__oRegPix:SetDate(6, dEmisFim)
		__oRegPix:SetDate(7, dVencIni)
		__oRegPix:SetDate(8, dVencFim)
		
		cQry := __oRegPix:GetFixQuery()	
		cF71Tmp := MpSysOpenQuery(cQry)
		
		While !(cF71Tmp)->(EOf())
			AAdd(aIdDocs, (cF71Tmp)->(F71_IDDOC+F71_SEQ))
			(cF71Tmp)->(DbSkip())
		EndDo
		
		(cF71Tmp)->(DbCloseArea())
	EndIf

	If (nTotalDoc := Len(aIdDocs)) > 0
		DbSelectAre("F71")
		F71->(DbSetOrder(1))
		
		Begin Transaction
			SF2->(DbSetOrder(1))
			cFilF71 := xFilial("F71")
			cFilSF2 := xFilial("SF2")
			
			For nX := 1 To nTotalDoc
				If F71->(DbSeek(cFilF71+aIdDocs[nX]))
					If SF2->(DbSeek(cFilSF2+F71->(F71_NUM+F71_PREFIX+F71_CODCLI+F71_LOJCLI)))
						cChvNFE := Alltrim(SF2->F2_CHVNFE)
						cSerie	 := Alltrim(SF2->F2_SERIE)
					EndIf
					
					If lCabec	// Imprime no inicio da p�gina
						MontaLinha(oPrinter, lCabec, @nLin, @nCol, @nLinFim, @nColFim, @nPagina, l890Mail)
						oPrinter:Say(nLinFim + 125, nColFim - 75, STR0007 + StrZero(nPagina,3), oFont2, 1400, )	// "P�gina: "
						cCodCli := F71->F71_CODCLI
					Else
						If cCodCli != F71->F71_CODCLI
							cCodCli := F71->F71_CODCLI
							MontaLinha(oPrinter, lCabec, @nLin, @nCol, @nLinFim, @nColFim, @nPagina, l890Mail)
							nLin += 55
						EndIf
						
						If nLin > nLinFim //Quebra de p�gina
							MontaLinha(oPrinter, lCabec, @nLin, @nCol, @nLinFim, @nColFim, @nPagina, l890Mail)
							lCabec := .T.
						Else
							nLin -= 55
						EndIf
					EndIf
					
					//Montagem dos boxes	
					oPrinter:Box(nLin + 70, nCol, nLin + 200, nColFim, "-4")
					oPrinter:Say(nLin + 80, nCol + 270, STR0008, oFont1N, 1400, )	// "Nota/Titulo"
					oPrinter:Say(nLin + 90, nCOl + 270, F71->F71_NUM, oFont2, 1400, )
					oPrinter:Say(nLin + 115, nCol + 270, STR0009, oFont1N, 1400, )	// "Parcela"
					oPrinter:Say(nLin + 125, nCol + 270, F71->F71_PARCEL, oFont2, 1400, )
					
					If !Empty(cSerie)
						oPrinter:Say(nLin + 145, nCol + 270, STR0010, oFont1N, 1400, )	// "Serie NF"
						oPrinter:Say(nLin + 155, nCol + 270, cSerie, oFont2, 1400, )
					EndIf
					
					oPrinter:Say(nLin + 80, nCol + 420, STR0011, oFont1N, 1400, )	// "Valor Titulo"
					oPrinter:Say(nLin + 90, nCol + 360, Transform(F71->F71_VLRPIX,PesqPict("F71","F71_VLRPIX")),oFont2,,,,1)
					oPrinter:Say(nLin + 115, nCol + 420, STR0012, oFont1N, 1400, )	// "Emissao"
					oPrinter:Say(nLin + 125, nCol + 420, DtoC(F71->F71_EMISSA), oFont2, 1400, )
					oPrinter:Say(nLin + 145, nCol + 420, STR0013, oFont1N, 1400, )	// "Vencimento"
					oPrinter:Say(nLin + 155, nCol + 420, DtoC(F71->F71_VENCTO), oFont2, 1400, )
					
					If !Empty(cChvNFE)
						oPrinter:Say(nLin + 175, nCol + 270, STR0014, oFont1N, 1400, )	// "Chave NFE"
						oPrinter:Say(nLin + 185, nCOl + 270, cChvNFE, oFont2, 1400, )
					EndIf
					
					//Imprimi o QRCode
					oPrinter:QRCode((nLin+194), (nCol+05), Alltrim(F71->F71_EMVPIX), 120)
					nLin += 194
					lCabec	:= .F.
					
					If !l890Mail .And. F71->F71_STATUS == "3"
						RecLock("F71",.F.)
						F71->F71_STATUS := "4"
						MsUnLock()
					Endif
					
					cChvNFE := ""
					cSerie	 := ""
				EndIf
			Next nX
			
			oPrinter:EndPage()
			
			If !l890Mail
				If !oPrinter:Preview()
					DisarmTransaction()
				EndIf
			Else
				oPrinter:Print()
				cFilePrint:= oPrinter:cPathPdf + cFilePdf
				
				If !lJob
					cPathPrint:= oPrinter:cPathPrint + cFilePdf	
					lCopy := __CopyFile(cFilePrint, cPathPrint,,,.F.)
					
					If lCopy
						Ferase(cFilePrint)
						cFilePrint:=cPathPrint
					Endif
				Endif
			Endif
		End Transaction
	Else
		Help(Nil, Nil, "NOREGPIX", Nil, STR0015, 2, 0, Nil, Nil, Nil, Nil, Nil, {""})
	EndIf
	
	RestArea(aAreaF71)
Return cFilePrint

/*/{Protheus.doc} MontaLinha
(long_description) Monta o Cabe�alho e trata a quebra das paginas
@type  Static Function
@author user
@since 15/10/2020
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/

Static Function MontaLinha(oPrinter, lCabec, nLin, nCol, nLinFim, nColFim, nPagina,l890Mail)
Local cNomCli As Character

cNomCli := Posicione("SA1",1,xFilial("SA1",F71->F71_FILIAL)+F71->(F71_CODCLI+F71_LOJCLI),"A1_NOME")

If !lCabec
	oPrinter:EndPage()		// Finaliza a p�gina
	oPrinter:StartPage()   	// Inicia uma nova p�gina
	nPagina++
	oPrinter:Say( nLinFim + 125, nColFim - 75, STR0007 + StrZero(nPagina,3), oFont2, 1400, )	// "P�gina: "
EndIf

nLin := 10
oPrinter:Box( nLin, nCol, nLin + 60, nColFim, "-4")

If l890Mail .AND. F71->F71_STATUS == '7'
	oPrinter:Say( nLin + 15, nCol + 05, STR0017, oFont1, 1400, )	    //"Segue lista de t�tulos cancelados para sua empresa atrav�s da forma de pagamento PIX, para seu"
	oPrinter:Say( nLin + 30, nCol + 05, STR0018, oFont1, 1400, )	// "controle."
Else
	oPrinter:Say( nLin + 15, nCol + 05, STR0002, oFont1, 1400, )	// "Segue lista de t�tulos gerados para sua empresa atrav�s da forma de pagamento PIX, para seu"
	oPrinter:Say( nLin + 30, nCol + 05, STR0003, oFont1, 1400, )	// "controle e pagamento."
Endif

oPrinter:Say( nLin + 50, nCol + 05, STR0004 + F71->F71_CODCLI + Space(02) + STR0005 + F71->F71_LOJCLI + Space(02) + STR0006 + Alltrim(cNomCli), oFont4, 1400, )	// "Cliente: " ### "Loja: " ### "Nome: "

If nLin > nLinFim	// Quebra de p�gina
	nPagina++
	oPrinter:Say( nLinFim + 125, nColFim - 75, STR0007 + StrZero(nPagina,3), oFont2, 1400, )	// "P�gina: "
	nLin += 55
EndIf

Return		
