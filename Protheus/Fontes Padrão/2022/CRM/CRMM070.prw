#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMM070.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMMPHONEDDI
Serviço para consulta dos dados de DDI tabela ACJ. 

@author		Renato da Cunha
@since		16/01/2018
@version	12.1.20
/*/
//------------------------------------------------------------------------------
WSRESTFUL CRMMPHONEDDI DESCRIPTION STR0001                                       //"Lista códigos de DDI disponíveis"
    WSDATA Language     AS STRING   OPTIONAL
    WSMETHOD GET	    DESCRIPTION STR0002 WSSYNTAX "/CRMMPHONEDDI/{Language}"  //"Retorna lista de códigos DDIs"
ENDWSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc} GET / CRMMPHONEDDI
Metodo GET para obtenção de arquivo Json contendo código e descrição
do DDI País. 

@param	Language	, caracter, EN para Inglês, ES para Espanhol

@return cResponse	, caracter, JSON com as oportunidades.

@author		Renato da Cunha
@since		16/01/2018
@version	12.1.20
/*/
//-------------------------------------------------------------------
WSMETHOD GET WSRECEIVE Language WSSERVICE CRMMPHONEDDI
    Local cResponse      := ''
    Local cAliasACJ      := GetNextAlias()
    Local cQuery         := ''
    Local cLanguage      := ''
    Local aDDI           := {}
    Local aReadData      := {}
    Local nX             := 0
    Local nLenCount      := 0
    Local oJsonPositions := JsonObject():New()

	Default Self:Language	 := 'pt'
	
    Self:SetContentType("application/json")
    
    If ( Len(Self:aURLParms) > 0 .And. !Empty( Self:aURLParms[1] ) )
		Self:Language := Self:aURLParms[1]
	EndIf

    cLanguage := Upper(Self:Language)

    cQuery := BuildQry(cLanguage)

    DBUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasACJ, .T., .T. )

    If (cAliasACJ)->( !EOF() )
        ( cAliasACJ )->( DBGoTop() )
        While (cAliasACJ)->(!EOF() )
            AAdd(aReadData,{(cAliasACJ)->CODE,(cAliasACJ)->COUNTRY})
            (cAliasACJ)->( DBSkip() )                
        EndDo
    Else
        AAdd(aReadData,{'',''})
    EndIf
    (cAliasACJ)->( DbCloseArea() )

    nLenCount   := Len(aReadData)

    For nX := 1 to nLenCount
        aAdd( aDDI,  JsonObject():New() )
        aDDI[nX]['code'   ]   := Alltrim(aReadData[nX,1])
        aDDI[nX]['country']   := EncodeUTF8( CRMMText( aReadData[nX,2], .F., .T. ) )
    Next nX        

    oJsonPositions["ddi"]	:= aDDI
    
    cResponse := FwJsonSerialize( oJsonPositions, .T. )
    
    Self:SetResponse( cResponse )
    FreeObj( oJsonPositions )
    oJsonPositions := Nil
	Asize(aReadData,0)
    Asize(aDDI,0)
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} BuildQry()
Constroi Query para uso no serviço CRMMPHONEDDI

@param  cLanguage     , caracter, Define qual campo de descrição do país será devolvido na Query. 

@return cQuery  	, caracter, Retorna para o usuario uma query pronta para realizar a consulta de DDI.

@author	Squad CRM/Faturamento
@since		26/03/2018
@version	12.1.17
/*/
//------------------------------------------------------------------- 
Static Function BuildQry(cLanguage)
    Local cQuery        := ''
    Local cFilACJ       := xFilial("ACJ")
    
    Default cLanguage   := 'PT'

    cQuery := 'SELECT ACJ_DDI CODE, '
    
    If cLanguage == 'EN'
        cQuery += 'ACJ_PAIS_I '
    ElseIf cLanguage == 'ES'
        cQuery += 'ACJ_PAIS_E '
    Else
        cQuery += 'ACJ_PAIS '
    EndIf

    cQuery  += 'COUNTRY'
    cQuery  += " FROM " + RetSqlName('ACJ') + " ACJ " 
    cQuery  += " WHERE "
    cQuery  += " ACJ.ACJ_FILIAL = '" + cFilACJ + "' AND "
    cQuery  += " ACJ.D_E_L_E_T_ = ' ' "

    cQuery := ChangeQuery( cQuery )
Return cQuery