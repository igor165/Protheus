#Include "protheus.ch"

/*/{Protheus.doc} FWDLEXLIST
    Fun��o resp�nsavel por devolver uma lista de exten��es autorizadas para download no tWebEngine.

    ------------------------------------ IMPORTANTE ----------------------------------------------
    
            Essa fonte � de uso exclusivo do FRAMEWORK, qualquer altera��o deve ser alinhada,
            caso contr�rio ser�o desfeitas

    ----------------------------------------------------------------------------------------------

    @type  Function
    @return aAllowed array com as exten��es de arquivos permitidas para download. 
    
    @see (https://tdn.totvs.com/display/PROT/AdDLExList)

/*/
Function FwDLExList()
    Local aAllowed as Array
    Local aNewItems as Array

    aAllowed := {}
    aNewItems := {}

    aAdd(aAllowed, "xls")
    aAdd(aAllowed, "xlsx")
    aAdd(aAllowed, "pdf")
    aAdd(aAllowed, "csv")
    aAdd(aAllowed, "txt")
    aAdd(aAllowed, "doc")
    aAdd(aAllowed, "docx")
    aAdd(aAllowed, "xml")
	aAdd(aAllowed, "zip") 


    // Chama fun��o que pode adicionar temporariamente extens�es para download
    // FwTWebEngineDownloadList():GetTemporaryAllowed() -> recupera as extens�es
    // FwTWebEngineDownloadList():SetTemporaryAllowed() -> adicionar� as extens�es
    // FwTWebEngineDownloadList():ClearTemporaryAllowed() -> limpa as defini��es anteriores
    If FindClass('FwTWebEngineDownloadList')
        aNewItems := FwTWebEngineDownloadList():GetTemporaryAllowed()
        AddNewItems(aNewItems, @aAllowed)
    EndIf

    // Ponto de entrada para inclus�o de novas exten��es
    If ExistBlock("AdDLExList")
        aNewItems := ExecBlock("AdDLExList",.F.,.F.,{aClone(aAllowed)})
        AddNewItems(aNewItems, @aAllowed)
    EndIf

Return aAllowed

//-------------------------------------------------------------------
/*/{Protheus.doc} AddNewItems
	Faz o processo de adicionar as extens�es n�o existentes � lista

@author  josimar.assuncao
@since   14.01.2021
/*/
//-------------------------------------------------------------------
static function AddNewItems(aNewItems, aAllowed)
    local nX as numeric
    local cItem as character

    for nX := 1 to Len(aNewItems)
        cItem := Lower(aNewItems[nX])
        if aScan(aAllowed, {|x| x == cItem} ) == 0
            aAdd(aAllowed, cItem )
        endif
   next nX
return
