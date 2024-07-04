#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#define ARQUIVO_LOG	"logs_gerais_monitoramento"

#DEFINE OBR_SIP   "1"
#DEFINE OBR_SIB   "2"
#DEFINE OBR_DIOPS "3"

#DEFINE CAMPO   01
#DEFINE TIPO    02
#DEFINE TAMANHO 03
#DEFINE DECIMAL 04
#DEFINE DESCRI 	05

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenDownXTE

Exibe um browse com as críticas agrupadas por código e descrição

@author everton.mateus
@since 22/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CenDownXTE(lAuto, cAno, cCodComp, cCodLote)

	Local aCampos := RetornaCampos()
	Local oTmpTab := CriaTabTemp(aCampos)
	Local aArquivos := {}
	Private oBrwDown := FWMarkBrowse():New()
	Default lAuto := .F.
	Default cAno := B3D->B3D_ANO
	Default cCodComp := B3D->B3D_CODIGO
	Default cCodLote := ""
	
	If BuscaArq(aArquivos,cAno,cCodComp,cCodLote)
		oBrwDown:SetDescription( "Download XTE" )
		oBrwDown:SetAlias( oTmpTab:getAlias() )
		oBrwDown:SetFields(montaFields(aCampos))
		oBrwDown:SetProfileID( 'CenDownXTE' )
		oBrwDown:DisableDetails()
		oBrwDown:ForceQuitButton()
		oBrwDown:SetWalkthru(.F.)
		oBrwDown:SetAmbiente(.F.)
		oBrwDown:SetTemporary()
		oBrwDown:SetFieldMark( 'BAIXAR' )
		oBrwDown:SetAllMark({ || MarcaBrw(oTmpTab:getAlias()) })
		oBrwDown:AddButton("Baixar"	, { || CenBaixXTE(.F.)},,2,1)
		
		CarregaArqTmp(aArquivos) 
		If !lAuto
			oBrwDown:Activate()		
		EndIf
	Else
		Aviso("Download XTE","Não foram encontrados arquivos para este " + IIf(Empty(cCodLote),"compromisso", "lote") + " na pasta \monitoramento\xte\")
	EndIf

	oTmpTab:delete()

Return oBrwDown

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaCampos

Retorna os campos para criar o arquivo temporario 

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaCampos()

	Local aCampos := {}
	
	aAdd(aCampos,{"BAIXAR"	,"C",002,0,"Baixar"})
	aAdd(aCampos,{"REGANS"	,"C",006,0,"Reg. ANS"})
	aAdd(aCampos,{"ANO"		,"C",004,0,"Ano"})
	aAdd(aCampos,{"MES"		,"C",003,0,"Mes"})
	aAdd(aCampos,{"SEQUEN"	,"C",004,0,"Sequen"})
	aAdd(aCampos,{"NOME"	,"C",020,0,"Nome"})
	
Return aCampos

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp

Cria o arquivo temporario de vencimentos

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaTabTemp(aCampos)

	Local oTmpTab   := Nil
	Default aCampos := {}

	oTmpTab := FWTemporaryTable():New( 'DOWNXTE' )
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex("01",{"NOME"})
	oTmpTab:Create()

Return oTmpTab

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} aArquivos
Busca os arquivos XTE que estão no servidor

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function BuscaArq(aArquivos,cAno,cCodComp,cCodLote)
	Local cPathSrv := "\monitoramento\xte\" + cAno + "\" + Substr(cCodComp,2,2) + "\"
	aArquivos := Directory(PLSMUDSIS(cPathSrv) + "*.xte", "D")
Return len(aArquivos) > 0

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com os registros criticados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(aArquivos)
	Local cFileName := ""
	Local nFile := 0
	Local nLen := Len(aArquivos)
	Local lRet := .F.
	Local oCenLogger := CenLogger():New()

	oCenLogger:setFileName(ARQUIVO_LOG)
	
	For nFile := 1 to nLen
		cFileName := aArquivos[nFile][1]
		oCenLogger:addLine("OBS", "Preenche o arquivo temporario com os registros criticados")
		oCenLogger:addLine("arquivo",cFileName)
		oCenLogger:addLog()
		RecLock('DOWNXTE',.T.)
		DOWNXTE->BAIXAR	:= ""
		DOWNXTE->REGANS := Substr(cFileName,1,6)
		DOWNXTE->ANO 	:= Substr(cFileName,7,4)
		DOWNXTE->MES 	:= Substr(cFileName,11,2)
		DOWNXTE->SEQUEN	:= Substr(cFileName,13,4)
		DOWNXTE->NOME	:= cFileName
		DOWNXTE->(MsUnlock())
	Next nFile

	oCenlogger:destroy()
	FreeObj(oCenlogger)
	oCenlogger := nil

	lRet := .T.

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaFields

Carrega os campos do browse de vencimentos 

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function montaFields(aCampos)

	Local cPicture := "@!"
	Local aFields  := {}
	Local nCampo := 0
	Local nLen	:= Len(aCampos)
	
	For nCampo := 2 to nLen
		aAdd(aFields,{aCampos[nCampo,DESCRI],aCampos[nCampo,CAMPO],aCampos[nCampo,TIPO],aCampos[nCampo,TAMANHO],aCampos[nCampo,DECIMAL],cPicture})
	Next nCampo

Return aFields 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MarcaBrw

Chama a funcao para marcar/desmarcar todos os registros da markbrowse 

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function MarcaBrw(cAliasTmp)
	Default cAliasTmp	:= ""
	MsgRun("Marcando / Desmarcando registros do browse","TOTVS",{ || PrcMarcaBrw(cAliasTmp) })
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PrcMarcaBrw

Marcar/desmarcar todos os registros da markbrowse 

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function PrcMarcaBrw(cAliasTmp)
	Default cAliasTmp	:= ""

	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
		oBrwDown:MarkRec()
		(cAliasTmp)->(dbSkip())
	EndDo
	oBrwDown:oBrowse:Refresh(.T.)

Return .T.

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} AjustaCritica

Chama o processamento de corrigir as criticas do registros selecionados 

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CenBaixXTE(lAuto)
	Local cDirLocal := cGetFile(,"Selecione o diretorio",,"",,GETF_LOCALHARD+GETF_RETDIRECTORY)
	If !Empty(cDirLocal)
		MsgRun("Ajustando registros criticados","TOTVS",{ || ProcDownload(cDirLocal) } )
	EndIf

Return .T.
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ProcDownload

Processa todos os registros selecionados

@author timoteo.bega
@since 30/01/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function ProcDownload(cDirLocal)
	Local cAliasTmp := oBrwDown:Alias()
	Local cMarca := oBrwDown:Mark()
	Local cPathSrv := ""
	
	(cAliasTmp)->(dbGoTop())
	While !(cAliasTmp)->(Eof())
		If (cAliasTmp)->BAIXAR == cMarca
			cPathSrv := PLSMUDSIS("\monitoramento\xte\" + AllTrim((cAliasTmp)->ANO) + "\" + AllTrim((cAliasTmp)->MES) + "\" + AllTrim((cAliasTmp)->NOME))
			CpyS2T( cPathSrv, cDirLocal )
		EndIf
		(cAliasTmp)->(dbSkip())
	EndDo

	oBrwDown:oBrowse:Refresh(.T.)
	MsgInfo("Download concluído na pasta: " + cDirLocal + ".")

Return .T.