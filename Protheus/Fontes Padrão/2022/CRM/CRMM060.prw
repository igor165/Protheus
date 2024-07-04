#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#Include "CRMM060.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMCONTACTPOSITION

Instancia classe REST responsável por retornar a lista de cargos disponíveis para cadastro
de contato.

@author		Renato da Cunha
@since		04/01/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
WSRESTFUL CRMMCONTACTPOSITION DESCRIPTION STR0001                                       //"Lista cargos disponíveis"
    WSDATA IdPosition   AS STRING	OPTIONAL
    WSDATA Language     AS STRING   OPTIONAL
    WSMETHOD GET	DESCRIPTION STR0002  WSSYNTAX "/CRMMCONTACTPOSITION/{IdPosition,Language}"   //"Retorna o Cargo do Contato"
ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / CRMMCONTACTPOSITION
 Retorna  os registros da tabela SUM.

@param	IdPosition	, caracter, Código de um Cargo.

@return cResponse	, caracter, JSON com as oportunidades.

@author		Renato da Cunha
@since		04/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE IdPosition, Language WSSERVICE CRMMCONTACTPOSITION
    Local cResponse      := ''
    Local cDescCntry     := ''
    Local cAliasSUM      := ''
    Local cQuery         := ''
    Local cLanguage      := ''
    Local cFilSUM        := xFilial("SUM")
    Local aPositions     := {}
    Local aReadData      := {}
    Local nX             := 0
    Local nLenCount      := 0
    Local nRecord        := 0
    Local oJsonPositions := JsonObject():New()

    Default Self:IdPosition  := ''
	Default Self:Language	 := 'pt'
	
    Self:SetContentType("application/json")
    
    If ( Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] ) )
		Self:IdPosition := Self:aURLParms[1]
	EndIf

    If ( Len(Self:aURLParms) > 1 .And. !Empty( Self:aURLParms[2] ) )
		Self:Language := Self:aURLParms[2]
	EndIf
 
    cLanguage := Upper(Self:Language)

	If  !Empty( Self:IdPosition ) 
		SUM->( DBSetOrder(1) )
        If SUM->( MSSeek(cFilSUM + Self:IdPosition ) )
            If cLanguage == 'EN'
                cDescCntry :=  SUM->UM_DESC_I
            ElseIf cLanguage == 'ES'
                cDescCntry :=   SUM->UM_DESC_E
            Else
                cDescCntry :=   SUM->UM_DESC
            EndIf

            AAdd(aReadData,{SUM->UM_CARGO, cDescCntry })
            nRecord++
        Else
            AAdd(aReadData,{'',''})
            nRecord := 0
        EndIf
	Else
		cAliasSUM   := GetNextAlias()
        
        cQuery := BuildQry(cLanguage,cFilSUM )

        DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasSUM, .T., .T. )

        If (cAliasSUM)->( !EOF() )
            ( cAliasSUM )->( DBGoTop() )
            While (cAliasSUM)->(!EOF() )
                AAdd(aReadData,{(cAliasSUM)->CARGO,(cAliasSUM)->DESCRI })
                (cAliasSUM)->( DBSkip() )                
                nRecord++
            EndDo
        Else
            AAdd(aReadData,{'',''})
            nRecord := 0
        EndIf
        (cAliasSUM)->( DbCloseArea() )
    EndIf

    nLenCount   := Len(aReadData)

    For nX := 1 to nLenCount
        aAdd( aPositions,  JsonObject():New() )
        aPositions[nX]['position_code'     ]   := aReadData[nX,1]
        aPositions[nX]['position_descr'    ]   := CRMMText( aReadData[nX,2], .F., .T. )
    Next nX        

    oJsonPositions["positions"]	:= aPositions
    oJsonPositions["count"] := nRecord
    cResponse := FwJsonSerialize( oJsonPositions, .T. )
    Self:SetResponse( cResponse )
    FreeObj( oJsonPositions )
    oJsonPositions := Nil
	
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQry()
Constroi um Query para ser utilizada no DBUseAerea

@param     cLanguage    , caracter, Lingua da Descrição do Cargo
           cFilSUM      , caracter, Filial da tabela SUM

@return cQuery  , caracter, Retorna Query

@author		Renato da Cunha
@since		27/03/2018
@version	12.1.17
/*/
//------------------------------------------------------------------- 
Static Function BuildQry(cLanguage, cFilSUM)
    Local cQuery        := ''
    Default cLanguage   := 'PT'
    Default cFilSUM     := xFilial('SUM')
    
    cQuery  := 'SELECT UM_CARGO CARGO,'
            
    If cLanguage == 'EN'
        cQuery  += ' UM_DESC_I '
    ElseIf cLanguage == 'ES'
        cQuery  += ' UM_DESC_E '
    Else
        cQuery  += ' UM_DESC '
    EndIf 
    
    cQuery  += 'DESCRI '
    cQuery  += " FROM " + RetSqlName('SUM') + " SUM " 
    cQuery  += " WHERE "
    cQuery  += " SUM.UM_FILIAL = '" + cFilSUM + "' AND "
    cQuery  += " SUM.UM_MSBLQL <> 1 AND "
    cQuery  += " SUM.D_E_L_E_T_ = ' ' "

Return ChangeQuery( cQuery )