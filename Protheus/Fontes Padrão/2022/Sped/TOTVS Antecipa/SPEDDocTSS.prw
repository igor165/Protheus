#include "protheus.ch"

Function SpedFisDocs( cObject As Character, aRecnos As Array )
Local aDocuments  As Array
Local aData       As Array

aData := {}

aDocuments  := GetDocumentIDS( cObject, aRecnos)   
TFLog("Buscando notas para "+cValToChar(len(aDocuments))+" documentos")
If len (aDocuments) > 0
    aData := GetFiscalDocs( aDocuments)
EndIf

Return aData

/*/{Protheus.doc} GetDocumentIDS
Recupera os IDs das Notas Fiscais que devem ter o XML recuperado

@author Valter.dsilva
@param cObject, character, nome da tabela a ser consultada. Ex. SF2990
@param aRecno, array, array de Recnos da SF2
@return aIds, array de identificadores
/*/
Static Function GetDocumentIDS( cObject As Character, aRecnos As Array ) As Array

    Local aIds As Array
    Default cObject := 'SF2'
    aIDs := {}
    
    If cObject = 'SF2'
        aIds := GetDocSF2(aRecnos )
    else
        TFLog("A tabela a ser consultada não e valido para consulta: "+cObject)
    Endif

Return aIds

/*/{Protheus.doc} GetDocSF2
Recupera os IDs das Notas Fiscais que devem ter o XML recuperado

@author izac.ciszevski
@param cObject, character, nome da tabela a ser consultada. Ex. SF2990
@param aRecno, array, array de Recnos da SF2
@return aIds, array de identificadores
/*/

Static Function GetDocSF2(aRecnos As Array )

    Local cQuery        As Character
    Local cAlias        As Character
    Local aIDs          As Array
    Local cSE1Name      As Character
    Local cSF2Name      As Character

    aIDs := {}
    cSE1Name := RetSqlName("SE1" )
    cSF2Name := RetSqlName("SF2" )

    cQuery := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_PREFIXO, F2_CHVNFE, SF2.R_E_C_N_O_ RECNO, Count( * ) Parcelas "
    cQuery += "   FROM " + cSF2Name + " SF2 "
    cQuery += " INNER JOIN " + cSE1Name + " SE1 ON "
    cQuery += AdjJoin('SF2', "SE1")
    cQuery += " F2_PREFIXO = E1_PREFIXO AND "
    cQuery += " F2_DUPL    = E1_NUM     AND "
    cQuery += " SE1.D_E_L_E_T_ = ' ' "
    cQuery += " WHERE "
    cQuery += " SF2." + AddPaging( aRecnos )
    cQuery += " AND F2_CHVNFE != ' ' "
    cQuery += " GROUP BY F2_FILIAL, F2_CHVNFE, F2_DOC, F2_SERIE, F2_PREFIXO, SF2.R_E_C_N_O_ "
    cQuery += " ORDER BY F2_FILIAL, SF2.R_E_C_N_O_ "
    cQuery := ChangeQuery( cQuery )

    cAlias := MpSysOpenQuery( cQuery )

    While ( cAlias )->( !EoF() )
        AAdd( aIDs, ( cAlias )->( { F2_SERIE + F2_DOC, F2_CHVNFE, F2_FILIAL, Parcelas, RECNO } ) )
        ( cAlias )->( DbSkip() )
    EndDo

    ( cAlias )->( DbCloseArea() )

Return aIDs

/*/{Protheus.doc} SendFiscalDoc
Recupera e envia a os XML das NFe

@author izac.ciszevski
@param cObject, character, nome da tabela a ser consultada. Ex. SF2990
@param aRecno, array, array de Recnos da SF2
@param oClient, objeto, client de conexÃ£o com o WS do TSS
@param cObject , character, nome da tabela que serÃ¡ utilizada: SF2 (nota TSS) ou CKO (nota ColaboraÃ§Ã£o).
Opcional, default SF2
@return Nil
/*/
Static Function GetFiscalDocs( aDocuments As Array, oClient As Object )
    Local cURL          As Character
    Local cXML          As Character
    Local cError        As Character
    Local cFilXML       As Character
    Local cBkpFilAnt    As Character
    Local aXMLDocuments As Array
    Local aData         As Array
    Local nDocument     As Numeric
    Local nI            As Numeric
    Local nTotalDocs    As Numeric
    Local nAux          As Numeric
    Local nBatch        As Numeric
    Local oDocument     As Object
    Local lNewRequest   As Logical
    Local lSendRequest  As Logical
    Local cXfilial      As Character
    Local lTotvsColab   As Logical
    Local lNextFil      As Logical
    Local cId           As Character
    Local aErrorRec     As Array
    Local cQuery        As Character
    Local nQtdParcelas  As Numeric
    Local cAuxXml       As Character
    Local cOrgCode      As Character

    aXMLDocuments := {}
    aData         := {}
    cError        := ""
    cFilXML       := ""
    cBkpFilAnt    := cFilAnt
    nBatch        := 20
    nTotalDocs    := Len( aDocuments )
    lNextFil      := .T.
    lTotvsColab   := .F.
    lAjustFil     := .T.
    lNewRequest   := .T.

    // Inicializa o WS
    Default oClient := WsNFesBra():New()
    oClient:cUSERTOKEN        := "TOTVS"
    oClient:nDIASPARAEXCLUSAO := 0
    oClient:oWSNFEID          := NFesBra_NFes2():New()
    
    // Obtem os documentos em ordem de Empresa/Filial
    For nDocument := 1 To nTotalDocs

        If lNewRequest
            
            cFilXML := aDocuments[ nDocument ][ 03 ]

            DbSelectArea( "SM0" )
            DbSetOrder( 1 )
            MsSeek( cEmpAnt + cFilXML )

            cFilAnt := SM0->M0_CODFIL
            cXfilial := FwxFilial(SubStr('SF2',1,3))
            //somente olhar o totvs colaboração após a troca do cfilant pois tem parâmetro envolvido
            //-----------------------
            If lAjustFil
                lTotvsColab := UsaColaboracao("1")
                lAjustFil   :=.F.
            Endif
           
            If !lTotvsColab
                TFLog('Sistema de notas via TSS')
                cURL := PadR( GetNewPar( "MV_SPEDURL", "http://" ), 250 )
                // Obtem o código da Entidade das Notas
                oClient:cID_ENT := RetIdEnti()
                oClient:_URL    := AllTrim( cURL ) + "/NFeSBRA.apw"
                oClient:oWSNFEID:oWSNotas := NFesBra_ArrayOfNFesId2():New()
            Endif

            lNewRequest := .F.
            aErrorRec := {}
        EndIf

        // Usa caboração.
        If lTotvsColab
            cNota :=""
            cIDERP:=""
            cNota   := aDocuments[ nDocument ][ 01 ]
            cIDERP  := (cNota + FwGrpCompany()+cXfilial)

            CKO->(dbSetOrder(3))
            if CKO->(dbSeek( PADR(cIdErp,Len(CKO->CKO_IDERP)) ) )
                 AAdd(aXMLDocuments, {aDocuments[ nDocument ][ 02],CKO->CKO_XMLRET,aDocuments[ nDocument ][ 04]})
            Endif
        Else
            AAdd( oClient:oWSNFEID:oWSNotas:oWSNFESID2, Nil )
            ATail( oClient:oWSNFEID:oWSNotas:oWSNFESID2 ) := NFesBra_NFesId2():New()
            ATail( oClient:oWSNFEID:oWSNotas:oWSNFESID2 ):cID := aDocuments[ nDocument ][ 1 ]
            aadd(aErrorRec, aDocuments[ nDocument ][ 5 ])
        Endif

        // aqui teste 

        If nDocument <> nTotalDocs 
            IF cFilXML <> aDocuments[ nDocument + 1 ][ 03 ]
                lAjustFil:=.T.
            ENDIF
        ENDIF

        lSendRequest := nDocument % nBatch == 0 .Or. nDocument == nTotalDocs .Or. cFilXML <> aDocuments[ nDocument + 1 ][ 03 ]

        If lSendRequest
            lNewRequest := .T. // força a criação de nova requisição
            cOrgCode := GetOrgCodes( cFilXMl )[4]
            
            If lTotvsColab
                TFLog('Quantidade de notas retornadas pelo Totvs Colaboração: ' + cValToChar(len(aXMLDocuments))) 
                For nI := 1 to Len( aXMLDocuments )
                    cId := aXMLDocuments[ nI ][1]
                    cXML := aXMLDocuments[nI][2]
                    nQtdParcelas := aXMLDocuments[nI][3]
  
                    oDocument := JsonObject():New()
                    oDocument[ "invoiceId" ]  := cId

                    cAuxXml := EncodeUtf8(cXML)

                    If cAuxXml <> nil
		                cXML := cAuxXml
	                Endif

                    oDocument[ "invoiceXML" ]     := cXML
                    oDocument[ "installmentQty" ] := nQtdParcelas
                    oDocument[ "Organization" ]   := cOrgCode
                    oDocument[ "Tenant" ]         := FwTechFinConfiguration():GetConfig("platform-tenantId")
                    oDocument[ "Created_At" ]     := Nil
                    oDocument[ "Updated_At" ]     := Nil
                    oDocument[ "Sent_At" ]        := "###SENT_AT###"
                    oDocument[ "ERP" ]            := "PROTHEUS"

                    AAdd( aData, oDocument )
                Next nI

            ElseIf oClient:RetornaNotas()
                aXMLDocuments := oClient:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3
                TFLog('Quantidade de notas retornadas pelo TSS:' + cValToChar(len(aXMLDocuments) ) + 'nota(s)')
                For nI := 1 to Len( aXMLDocuments )

                    cXML := GetXML( aXMLDocuments[ nI ]:oWSNFE:cXML, aXMLDocuments[ nI ]:oWSNFE:cXMLPROT )
                    nAux := AScan( aDocuments, { | x | Alltrim( x[ 1 ] ) == AllTrim( aXMLDocuments[ nI ]:cId ) .And. cXfilial == x[ 3 ] } )
                    nQtdParcelas := aDocuments[ nAux ][ 4 ]
                    cId :=  aDocuments[ nAux ][ 2 ]
                  
                    oDocument := JsonObject():New()
                    oDocument[ "invoiceId" ]  := cId

                    cAuxXml := EncodeUtf8(cXML)

                    If cAuxXml <> nil
		                cXML := cAuxXml
	                Endif

                    oDocument[ "invoiceXML" ]     := cXML
                    oDocument[ "installmentQty" ] := nQtdParcelas
                    oDocument[ "Organization" ]   := cOrgCode
                    oDocument[ "Tenant" ]         := FwTechFinConfiguration():GetConfig("platform-tenantId")
                    oDocument[ "Created_At" ]     := Nil
                    oDocument[ "Updated_At" ]     := Nil
                    oDocument[ "Sent_At" ]        := "###SENT_AT###"
                    oDocument[ "ERP" ]            := "PROTHEUS"

                    AAdd( aData, oDocument )
                Next nI
            Else
                //-------------------------------
                //Se deu erro na recuperação da notas marca os registros como não atualizados
                //------------------------------
                cError := If( !Empty( GetWscError( 3 ) ), GetWscError( 3 ), GetWscError( 1 ) )
                TFLog("ERRO SPED - "+ cError + "ERROR" ) 

                cQuery := 'UPDATE ' + RetSqlName('SF2')
                cQuery += " SET S_T_A_M_P_ = "
                if FWIsPostGres()
                    cQuery += "null"
                Else
                    cQuery += "''"
                Endif
                cQuery += " WHERE"
                cQuery += " " + AddPaging( aErrorRec )

                If !TCSqlExec(cQuery) >= 0
                   TFLog( "Erro ao restaurar TimesStamp da SF2 - '"+ TCSqlError(), "ERROR" )
                Endif
            EndIf
            
            FwFreeObj( aXMLDocuments )
        EndIf
    Next nDocument

    FwFreeObj( oClient )

    cFilAnt := cBkpFilAnt

Return aData

//-------------------------------------------------------------------
/*/{Protheus.doc} AdjJoin
Realiza o ajuste da JoinFilial e retorna branco caso o relacionamento
nÃ£o precise ser incluÃ­do
@param cAlias1 Primeiro alias do relacionamento
@param cAlias@ segundo alias do relacionamento
@return cRet Join como "RCO.RCO_FILIAL = SUBSTRING(SRA.RA_FILIAL,1,6) AND " ou branco.
@author  Valter Silva
@since   20/05/2021
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AdjJoin(cAlias1, cAlias2)

    Local cJoinFilial As Character

    cJoinFilial := FWJoinFilial(cAlias1, cAlias2)
    If !(cJoinFilial == "' ' = ' '")
        cJoinFilial += " AND "
    Else
        cJoinFilial := ''
    Endif

Return cJoinFilial


Static Function AddPaging( aRecnos, cAliasQry )
    Return StaticCall( FwTechFinJob, AddPaging, aRecnos, cAliasQry )

Static Function GetOrgCodes( cFil )
    Return StaticCall( FwTechFinJob, GetOrgCodes, cFil )

/*/{Protheus.doc} GetXML
Monta o XML no padrÃ£o SEFAZ conforme XML e Protocolo do TSS
@type function
@author Valter Silva
@since 04/03/2020
@param cXMLTSS, character, XML registrado no TSS
@param cXMLPROT, character, Protocolo registrado no TSS
@return character, XML padrÃ£o SEFAZ
/*/
Static Function GetXML( cXMLTSS As Character, cXMLPROT As Character ) As Character
    Local cXML    As Character
    Local cVersao As Character

    // Monta o XML com o Protocolo no padrao da SEFAZ
    //TODO: Ver como fazer melhor isto
    cXML := '<?xml version="1.0" encoding="UTF-8"?>'
    cXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="#1">'
    // Pego a versao do layout XML
    cVersao := SubStr( cXMLPROT, At( 'versao="', cXMLPROT ) + 8 )
    cVersao := SubStr( cVersao, 1, At( '"', cVersao ) - 1 )
    cXML := StrTran( cXML, "#1", cVersao )
    cXML += cXMLTSS
    cXML += cXMLPROT
    cXML += '</nfeProc>'

Return cXML

//-------------------------------------------------------------------
/*/{Protheus.doc} UsaColaboracao
Verifica se parametro MV_TCNEW esta configurado para 0-Todos ou 1-NFE

@author	valter Silva
@since		18/04/2020
@version	1.0
/*/
//-------------------------------------------------------------------
static function UsaColaboracao(cModelo)
	Local lUsa := .F.

	If FindFunction("ColUsaColab")
		lUsa := ColUsaColab(cModelo)
	endif
return (lUsa)
