#Include "protheus.ch"

/*/{Protheus.doc} FWDLEXLIST
    Função respónsavel por devolver uma lista de extenções autorizadas para download no tWebEngine.

    ------------------------------------ IMPORTANTE ----------------------------------------------
    
            Essa fonte é de uso exclusivo do FRAMEWORK, qualquer alteração deve ser alinhada,
            caso contrário serão desfeitas

    ----------------------------------------------------------------------------------------------

    @type  Function
    @return aAllowed array com as extenções de arquivos permitidas para download. 
    
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


    // Chama função que pode adicionar temporariamente extensões para download
    // FwTWebEngineDownloadList():GetTemporaryAllowed() -> recupera as extensões
    // FwTWebEngineDownloadList():SetTemporaryAllowed() -> adicionará as extensões
    // FwTWebEngineDownloadList():ClearTemporaryAllowed() -> limpa as definições anteriores
    If FindClass('FwTWebEngineDownloadList')
        aNewItems := FwTWebEngineDownloadList():GetTemporaryAllowed()
        AddNewItems(aNewItems, @aAllowed)
    EndIf

    // Ponto de entrada para inclusão de novas extenções
    If ExistBlock("AdDLExList")
        aNewItems := ExecBlock("AdDLExList",.F.,.F.,{aClone(aAllowed)})
        AddNewItems(aNewItems, @aAllowed)
    EndIf

Return aAllowed

//-------------------------------------------------------------------
/*/{Protheus.doc} AddNewItems
	Faz o processo de adicionar as extensões não existentes à lista

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
