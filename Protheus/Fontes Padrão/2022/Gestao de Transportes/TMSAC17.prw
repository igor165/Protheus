#Include 'Protheus.ch'
//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCANFESEFAZ()
Classe para busca de NFe na SEFAZ

@author Felipe Barbiere
@since 22/04/2021
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCANFESEFAZ

    //-- Certificado
    DATA cIdEnt       As Character
    DATA cError       As Character
    DATA aResult      As Array

    METHOD New()    Constructor  
    METHOD GetIdent()
    METHOD GetXMLNFe()
    METHOD CreateXMLFile()
    METHOD UpdRetSEFAZ()

END CLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Felipe Barbiere
@since 22/04/2021
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New() CLASS TMSBCANFESEFAZ

    ::aResult := {}

    ::GetIdent()   

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetIdent()
GetIdent

@author     Felipe Barbiere
@since      22/04/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD GetIdent() CLASS TMSBCANFESEFAZ

Local lUsacolab := UsaColaboracao("5")

    ::cIdEnt := RetIdEnti(lUsaColab)

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetXMLNFe()
Busca XML na SEFAZ

@author     Felipe Barbiere
@since      22/04/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD GetXMLNFe(aChvNFes) CLASS TMSBCANFESEFAZ

Local oWs       := Nil
Local cAmbiente := ""
Local nX        := 0
Local cURL      := PadR(GetNewPar("MV_SPEDURL","http://"),250)    

Default aChvNFes := {}

If RetRdTSS() .And. !Empty(aChvNFes)
    oWs :=WSMANIFESTACAODESTINATARIO():New()
    oWs:cUserToken   := "TOTVS"
    oWs:cIDENT       := ::cIdEnt
    oWs:cAMBIENTE    := ""
    oWs:cVERSAO      := ""
    oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw" 
    oWs:CONFIGURARPARAMETROS()
    cAmbiente         := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE 
            
    oWs:cUserToken   := "TOTVS"
    oWs:cIDENT       := ::cIdEnt
    oWs:cAMBIENTE    := cAmbiente
            
    oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
               
    oWs:oWSDOCUMENTOS:oWSDOCUMENTO  := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()  
        
    If !Empty(aChvNFes)
       For nX := 1 to Len(aChvNFes)
            AAdd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
                 oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[nX]:CCHAVE := aChvNFes[nX]
        Next nX

        If oWs:BAIXARXMLDOCUMENTOS()
           If ValType ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"
                For nX := 1 to Len(oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET)
                    If ::CreateXMLFile(oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET[nX]:CNFEPROCZIP, oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET[nX]:CCHAVE )
                        AAdd(::aResult, {oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET[nX]:CCHAVE, "2" }) //Processada
                    EndIf
                Next nX
            Else
                For nX := 1 to Len(aChvNFes)
                    AAdd(::aResult, {aChvNFes[nX], "3" }) //Não encontrada
                Next nX
            EndIf
        EndIf
    EndIf
EndIf

Return ::aResult

//-----------------------------------------------------------------
/*/{Protheus.doc} CreateXMLFile()
Cria as tags do XML á ser enviado para SEFAZ

@author     Felipe Barbiere
@since      23/04/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD CreateXMLFile(cRetorno, cChaveNFe) CLASS TMSBCANFESEFAZ

Local cPath         := "XMLNFE"
Local cPathNew      := "NEW"
Local cUnXML        := ""
Local nTamanho      := 0
Local lRet          := .T.

Default cRetorno    := "" 
Default cChaveNFe   := "" 

If !Empty(cRetorno)
    //Cria os diretórios caso não existam
    If IsSrvUnix()
        cPath += "/"
        cPathNew += "/"
    Else
        cPath := "\" + cPath + "\"  
        cPathNew += "\"
    EndIf

    If !ExistDir(cPath)     
        MakeDir(cPath)
        MakeDir(cPath + cPathNew)
    EndIf

    //Pega o tamanho e descriptografa o conteúdo
    nTamanho  := Len(cRetorno)
    lRet      := GzStrDecomp(cRetorno, nTamanho, @cUnXML)

    //Cria o arquivo com o conteúdo
    lRet := MemoWrite(cPath + cPathNew + cChaveNFe + ".xml", cUnXML)
EndIf

Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} UpdRetSEFAZ()
Atualiza a tabela DMH com o retorno da SEFAZ

@author     Felipe Barbiere
@since      28/04/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
METHOD UpdRetSEFAZ(aRet) CLASS TMSBCANFESEFAZ
Local nCount := 0
Local lRet   := .F. 

Default aRet := {}

DMH->(DbSetOrder(2)) 
For nCount := 1 to Len(aRet)
    If DMH->(DBSeek(xFilial("DMH") + aRet[nCount][1]))
        RecLock('DMH',.F.)
        DMH->DMH_STATUS := aRet[nCount][2]   //1-Pendente //2-Processada //3-Não encontrada      
	    MsUnLock()
        lRet := .T.
    EndIf
Next nCount

Return lRet


//-----------------------------------------------------------------
/*/{Protheus.doc} TMSAC17Job()
Job para atualização e busca das NFs

@author     Felipe Barbiere
@since      28/04/2021
@version    1.0 
/*/
//--------------------------------------------------------------------
Function TMSAC17()

Local cAlias    := ""
Local cQuery    := ""
Local aChvNFes  := {}
Local aRet      := {}
Local oNFeSEFAZ

    cAlias := GetNextAlias()

    cQuery := " SELECT DMH.DMH_CHVNFE  "
    cQuery += " FROM " + RetSqlName("DMH") + " DMH "
    cQuery += " WHERE DMH.DMH_FILIAL = '" + xFilial("DMH") + "' "
    cQuery +=       " AND DMH_STATUS = '1' "
    cQuery +=       " AND DMH.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery(cQuery)
    DbUseArea( .T., "TOPCONN", TCGENQRY( , , cQuery ), cAlias, .F., .T. )

    While (cAlias)->(!Eof())
        AAdd(aChvNFes, (cAlias)->DMH_CHVNFE )    
        (cAlias)->(DbSkip())
    EndDo
    
    (cAlias)->( DbCloseArea() ) 

    If !Empty(aChvNFes)
        oNFeSEFAZ := TMSBCANFESEFAZ():New()
        aRet      := oNFeSEFAZ:GetXMLNFe(aChvNFes)
        If !Empty(aRet)
            oNFeSEFAZ:UpdRetSEFAZ(aRet)
        EndIf
    EndIf

Return Nil


//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Scheddef
Permite a execucao da rotina via Scheddef.
@type function
@author     Felipe Barbiere
@since      29/04/2021
@version    1.0 
/*/
//-------------------------------------------------------------------------------------------------
Static Function Scheddef()
Local aParam

aParam := {"P",;  	//Tipo R para relatorio P para processo   
		   ,;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DMH",;  // Alias            
		   ,;   	//Array de ordens   
		   'Schedule - Busca NFes'} //--> Schedule - Repom   

Return aParam