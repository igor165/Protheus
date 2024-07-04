#INCLUDE "TOTVS.CH"
#INCLUDE "OMSXFOTO.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} OMSGetFoto
Cria tela para captura da imagem
@author  Squad OMS
@since   03/10/2018
@version 1.0
@param cAlias,  caractere , alias da tabela que terá a foto gravada
@param cIdFile, caractere , nome para a imagem
@param oModel,  objeto,     modelo que contem o campo bitmap
@param cFldBmp, caractere,  campo bitmap
@param cCodUnq, caractere,  código único de identificação da imagem
/*/
//-------------------------------------------------------------------
Function OMSGetFoto(cAlias, cIdFile, oModel, cFldBmp, cCodUnq)
Local lRet      := .T.
Local lUnix     := IsSrvUnix()
Local cIniName  := GetRemoteIniName()
Local nPos      := Rat(IIF(lUnix, "/", "\" ), cIniName) 
Local cPathRmt  := IIF(nPos == 0,"",SubStr(cIniName, 1, nPos - 1))
Local cNomeDisp := ""
Local cComboBo1 := ""
Local nHandle   := 0
Local oDlg      := Nil
Local oComboBo1 := Nil
Local oSay1     := Nil
Local oSButton1 := Nil
Local oSButton2 := Nil
Local oSButton3 := Nil
Local oBitmap1  := Nil

Default cIdFile := FwGrpCompany()+xFilial(cAlias)+M->&cCodUnq

	If Empty(M->&cCodUnq)
		Alert(WmsFmtMsg(STR0001,{{"[VAR01]",cCodUnq}})) //Para capturar a foto é necessário que o campo [VAR01] esteja preenchido.
		Return .F.
	EndIf

	If Len(cIdFile) > TamSx3("DA4_BITMAP")[1]
		Alert(WmsFmtMsg(STR0003,{{"[VAR01]",cFldBmp},{"[VAR02]",cValToChar(Len(cIdFile))}})) //O tamanho do campo de foto [VAR01] é menor que o exigido para a inserção ([VAR02])
		Return .F.
	EndIf

	Begin Sequence
		
		nHandle := ExecInDLLOpen("imageload2.DLL")  
		If nHandle == -1
			cPathRmt += "\imageload2.dll"
			Alert(STR0004+cPathRmt+Chr(13)+Chr(10)+Chr(13)+Chr(10)+STR0005) //Não foi possível carregar a DLL //Verifique se o arquivo existe no caminho acima ou atualize seu ambiente e tente novamente.                  
			Return
		EndIf     
		
		// Obtem lista de cameras
		ExeDLLRun2(nHandle, 1, @cNomeDisp) 
		cNomeDisp := OemToAnsi(AllTrim(cNomeDisp)+AllTrim(cNomeDisp))
		aItems    := StrTokArr(cNomeDisp, "|")

		// Define dimenção de captura
		ExeDLLRun2(nHandle, 3, "0360|0270") // Largura|Altura
		
		// Altera Titulo da janela de captura
		ExeDLLRun2(nHandle, 4, STR0006) // APERTE F2 PARA CAPTURAR
		
        oDlg := MsDialog():New(000, 000, 450, 450, STR0007,,,,,0,16777215,,,.T.) // Captura de Fotos
        oComboBo1 := TComboBox():New(001, 002, {|u|If(PCount()>0,cComboBo1 := u, cComboBo1)} , aItems, 131, 010, oDlg, , , ,0 , 16777215)
        oSay1     := TSay():New(005, 007, {||STR0008}, oDlg,,,,,,.T., 0, 16777215, 067, 007) // Selecione a Câmera: 
        oSButton1 := SButton():New(027, 018, 14, {||lRet := Captura(cIdFile,oComboBo1:nAt, @nHandle, @oBitmap1)}, oDlg, .T.)	
        oSButton2 := SButton():New(027, 058, 02, {||lRet := .F.,oDlg:End()}, oDlg, .T.)
		oSButton3 := SButton():New(027, 098, 13, {||lRet := SalvaFoto(cIdFile, cAlias, cFldBmp, cCodUnq,oDlg),oDlg:End()}, oDlg, .T.)    
        oBitmap1  := TBitmap():New(057, 023, 350, 250, , , .T., oDlg, , , , , , , , ,.T.)
        oDlg:Activate(,,,.T.)
		
		If !lRet
			Break
		Endif
		
		//Grava campo no pmodel
		FWFldPut(cFldBmp, cIdFile,/*nLinha*/,oModel,.T.,.F.)
	End 

	ExecInDLLClose(nHandle)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} SalvaFoto
Carrega imagem no repositório
@author  Squad OMS	
@since   03/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SalvaFoto(cIdFile, cAlias, cFldBmp, cCodUnq,oDlg)
Local cFileBmp  := Alltrim(cIdFile)
Local cPathPict := Upper(GetTempPath()+cFileBmp+'.BMP')
Local oBmp      := TBmpRep():New ( 0, 0, 0, 0, "", .T.,oDlg, Nil, Nil, .F., .F. )
	IF !Empty(cPathPict)
		// Apaga arquivo anterior, se existir
		oBmp:OpenRepository()
		If oBmp:ExistBmp(cIdFile)
			oBmp:DeleteBmp(cIdFile)
		EndIf
		// Insere arquivo no repositório
		oBmp:InsertBmp(cPathPict,,.T.)
		oBmp:CloseRepository()
	EndIF
	M->&cFldBmp := Alltrim(cIdFile)
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} Captura
Captura imagem
@author  Squad OMS
@since   03/10/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Captura(cIdFile,nAt, nHandle, oBitmap)
Local cImgPadrao := ""
Local cFileBmp   := Alltrim(cIdFile)+'.BMP'
Local cPathPict  := Upper(GetTempPath()+cFileBmp)
	// Define dispositivo
	ExeDLLRun2(nHandle, 2, @cValToChar(nAt-1)) 
    // Apaga arquivo anterior, se existir
	If !Empty(cPathPict) .And. File(cPathPict)
  	 	FERASE(cPathPict)
	EndIf
	// Abre tela de captura e define arquivo de imagem de saida
	cImgPadrao := cPathPict
	ExeDLLRun2( nHandle, 5, @cImgPadrao )
	// Necessario para troca de imagem
	oBitmap:Load(,"ok.png")
  	ProcessMessages()
	// Exibe imagem capturada
	oBitmap:Load(,cPathPict)
	ProcessMessages()
Return .T.
