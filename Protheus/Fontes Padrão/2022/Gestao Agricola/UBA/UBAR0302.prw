#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "REPORT.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "UBAR0302.CH"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF   6

#define DMPAPER_A4 9 // A4 210 x 297 mm
#define DMPAPER_LEGAL 5 // Legal 8 1/2 x 14 in

#DEFINE VBOX      080
#DEFINE VBOX      080
#DEFINE VSPACE    008
#DEFINE HSPACE    010
#DEFINE SAYVSPACE 008
#DEFINE SAYHSPACE 008
#DEFINE HMARGEM   030
#DEFINE VMARGEM   030


/*{Protheus.doc} UBAR0302
(Relátorio Cod.Barras de Remessa, para rotina UBAA030 (Gestão de Remessa) )
@type function
@author roney.maia
@since 17/02/2017
@version 1.0
*/
Function UBAR0302()

	Private _oPrint		:= Nil // Objeto FWMSPrinter
	Private _oFont3		:= Nil // Objeto de Fonte

	If !N72->(ColumnPos('N72_CODREM'))
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		return()
	EndIf

	_oFont3 := TFont():New("Courier New", , 14, .T., .T., 5,,, .T., .F.,,,,,, _oPrint) // Fonte para impressão
	
	Pergunte('UBAA030R', .T.) // Pergunte para filtro de remessas
	
	Processa({||SfImpLaser() }, STR0001) // Processa o Inicio da Impressão
	
Return


Static Function SfImpLaser()
	
	Local nLinhaCab	:= 0
	Local nPulo     	:= 10
	Local nIt			:= 0
	Local aRemessas	:= {}
	Local nLinEti 	:= 5
	Local nLinBarras 	:= 5
	
	Local lAdjustToLegacy 	:= .F.
	Local cDirPrint			:= GetTempPath() // Dirétorio Temporário
	Local cFileOP				:= STR0002 + ".pdf" // remessas

	FErase(cDirPrint+cFileOP) // Caso o arquivo temporário já exista, apaga o arquivo

	_oPrint := FWMSPrinter():New(cFileOP, IMP_SPOOL, lAdjustToLegacy, cDirPrint, .T.,,,,.T.)// Ordem obrigátoria de configuração do relatório
	_oPrint:cPathPDF := cDirPrint  // Diretório para o arquivo PDF
	_oPrint:SetPortrait() // Seta modo retrato como padrão
	_oPrint:SetPaperSize(DMPAPER_A4) // Seta o tipo de folha para impressão
	_oPrint:SetMargin(50,50,0,0) // Seta as margens
	_oPrint:lServer := .F. 
	_oPrint:nDevice := IMP_SPOOL // Tipo de impressão
	_oPrint:Setup() // Abre a tela de setup para o usuário
		
	If ! _oPrint:nModalResult = PD_OK //Usuario pressionou cancelar
		_oPrint:Deactivate()  //Libera o arquivo criado da memoria para que possa ser usado novamente caso o usuario entre na rotina de novo.
		_oPrint := Nil
		Return
	Endif
	
	aRemessas := UBAR0302REM() // Busca as Remessas conforme o pergunte
	
	_oPrint:cPathPDF := cDirPrint
	_oPrint:StartPage() // Inicia a Página
	
	If _oPrint:GetOrientation() == 1 // Se a impressão for modo Retrato
		For nIt := 1 To Len(aRemessas) // Loop com base na quantidade de remessas
			If nIt % 5 == 0 // Se houver mais de 4 remessas ou multiplos de 5, inicia a impressão em uma nova página
				_oPrint:StartPage()
			Endif
			PrnCab(nLinhaCab) //Imprime Cabeçalho.
			nLinhaCab 	+= 170
			_oPrint:FWMSBAR( 'CODE128', nLinBarras ,  6.5, Alltrim(aRemessas[nIt][3]), _oPrint, .F., , .T., 0.035, 1.7, .f., 'Courier New', '', .F. ) // Imprime o código de barras
			nLinEti += 10
			_oPrint:Say(nLinEti + npulo * 12 ,080, Alltrim(aRemessas[nIt][3]) , _oFont3)	// Descrição do código
			nLinEti += 10	
			_oPrint:Say(nLinEti + npulo * 13 ,080, STR0003 + ": " + AllTrim(FWFilialName(,aRemessas[nIt][1], 1)), _oFont3)	// Filial # Descrição Produto
	   		nLinEti -= 20
	   		nLinEti += 170
	   		nLinBarras += 14.4
	   		If nIt % 4 == 0 // Se houver 4 remessas ou multiplos de 4, finaliza a página
	   			nLinhaCab := 0
	   			nLinEti := 5
	   			nLinBarras := 5
				_oPrint:EndPage()
			EndIf
		Next nIt
	ElseIf _oPrint:GetOrientation() == 2 // Se a impressão for modo Paisagem
		For nIt := 1 To Len(aRemessas)
			If nIt % 4 == 0 // Se houver mais de 3 remessas ou multiplos de 4, inicia a impressão em uma nova página
				_oPrint:StartPage()
			Endif
			PrnCab(nLinhaCab) //Imprime Cabeçalho.
			nLinhaCab 	+= 170
			_oPrint:FWMSBAR( 'CODE128', nLinBarras ,  6.5, Alltrim(aRemessas[nIt][3]), _oPrint, .F., , .T., 0.035, 1.7, .F., 'Courier New', '', .F. ) // Imprime o código de barras
			nLinEti += 10
			_oPrint:Say(nLinEti + npulo * 12 ,080, Alltrim(aRemessas[nIt][3]), _oFont3)	// Descrição do código
			nLinEti += 10	
			_oPrint:Say(nLinEti + npulo * 13 ,080, STR0003 + ": " + AllTrim(FWFilialName(,aRemessas[nIt][1], 1)), _oFont3)	// Filial # Descrição Produto
	   		nLinEti -= 20
	   		nLinEti += 170
	   		nLinBarras += 14.4
	   		If nIt % 3 == 0 // Se houver 3 remessas ou multiplos de 3, finaliza a página
	   			nLinhaCab := 0
	   			nLinEti := 5
	   			nLinBarras := 5
				_oPrint:EndPage()
			EndIf
		Next nIt
	
	EndIf

	_oPrint:Preview() // Apresenta a visualização da impressão
	_oPrint:EndPage() // finaliza a ultima página
	_oPrint := Nil

Return


/*{Protheus.doc} PrnCab
(Função responsável por imprimir o cabeçalho que irá
conter o código de barras e demais informações)
@type function
@author roney.maia
@since 17/02/2017
@version 1.0
@param nLinhaCab, numérico, (Linha que devera ser feito a impressão)
*/
Static Function PrnCab(nLinhaCab)

	Local oBrush 	:= TBrush():New( , CLR_GRAY ) // Cor de fundo
	

	_oPrint:FillRect ({20 + nLinhaCab, 10, 35 + nLinhaCab, 540} , oBrush) // Printa um retangulo

	_oPrint:Say(31+nLinhaCab ,15, STR0004, _oFont3)// CODIGO INTELIGENTE DA REMESSA PARA CLASSIFICAÇÃO

	_oPrint:Box((35*1.2)+nLinhaCab , 10, 160 + nLinhaCab, 540) // Printa o box

Return


/*{Protheus.doc} UBAR0302REM
(Função responsável por buscar remessas com base no filtro 
informado na pergunta)
@type function
@author roney.maia
@since 17/02/2017
@version 1.0
@return ${return}, ${Array com as Remessas}
*/
Static Function UBAR0302REM()

	Local cAliasN72	:= GetNextAlias() // Obtém o proximo alias disponível
	Local cQryN72		:= "" // Query N72
	Local aRemessas	:= {}
	
	cQryN72 := "SELECT N72_FILIAL, N72_CODREM, N72_CODBAR"
	cQryN72 += " FROM "+ RetSqlName("N72") + " N72"
	cQryN72 += " WHERE D_E_L_E_T_ <> '*'"
	cQryN72 += " AND N72_STATUS <> '5'" 	
	
	
	If !Empty(MV_PAR01)
		cQryN72 += " AND N72_CODREM >= '" + MV_PAR01 + "'"
	EndIf
	If !Empty(MV_PAR02)
		cQryN72 += " AND N72_CODREM <= '" + MV_PAR02 + "'"
	EndIf
	
	If Select(cAliasN72) > 0
		(cAliasN72)->( dbCloseArea() )
	EndIf
		
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQryN72 ), cAliasN72, .F., .T. )

	//Seleciona a tabela 
	dbSelectArea(cAliasN72)
	dbGoTop()
	While (cAliasN72)->(!Eof()) // Adiciona as Remessas

		aAdd(aRemessas, {(cAliasN72)->N72_FILIAL, (cAliasN72)->N72_CODREM, (cAliasN72)->N72_CODBAR})
		(cAliasN72)->(DbSkip())
	EndDo
	
  	(cAliasN72)->(DbCloseArea())

Return aRemessas
