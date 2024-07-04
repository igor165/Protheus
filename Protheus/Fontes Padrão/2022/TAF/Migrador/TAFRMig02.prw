#Include "Protheus.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} TAFRMig02
Relatório com os status de importação do Migrador
@author  Victor A. Barbosa
@since   12/06/2019
@version 1
/*/
//-------------------------------------------------------------------
Function TAFRMig02(aNotImport)

Default aNotImport := {}

If MsgYesNo( "Foram encontrados inconsistências na importação do arquivo." + Chr(10) + Chr(13) + "Deseja visualizar?", "TOTVS" )
    RMigr02Print(aNotImport)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} RMigr02Print
Efetua a impressão do relatório
@author  Victor A. Barbosa
@since   12/06/2019
@version 1
/*/
//-------------------------------------------------------------------
Static Function RMigr02Print(aNotImport)

Local oExcel 	:= FWMSExcel():New()
Local oExcelApp	:= Nil
Local cAba  	:= "Registros"
Local cTabela	:= "Registros"
Local cArquivo	:= "import_" + DTOS(Date()) + "_" + StrTran(Time(), ":", "") + ".xls"
Local cPath		:= cGetFile( "Diretório" + "|*.*", "Procurar", 0,, .T., GETF_LOCALHARD + GETF_RETDIRECTORY, .T. )
Local cDefPath	:= GetSrvProfString( "StartPath", "\system\" )
Local nX		:= 0

oExcel:AddWorkSheet(cAba)
oExcel:AddTable(cAba, cTabela)

oExcel:AddColumn(cAba, cTabela, "Arquivo"	, 1, 1, .F.)
oExcel:AddColumn(cAba, cTabela, "Mensagem"	, 1, 1, .F.)

For nX := 1 To Len(aNotImport)

    oExcel:AddRow(cAba,;
				  cTabela,;
                  { aNotImport[nX][1],;
				  	aNotImport[nX][2];
				  })
Next nX

If !Empty(oExcel:aWorkSheet)

    oExcel:Activate()
    oExcel:GetXMLFile(cArquivo)
 
    CpyS2T(cDefPath+cArquivo, cPath)

    FErase(cDefPath+cArquivo)

    oExcelApp := MsExcel():New()
    oExcelApp:WorkBooks:Open(cPath+cArquivo) // Abre a planilha
    oExcelApp:SetVisible(.T.)

EndIf

Return