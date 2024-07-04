#include 'protheus.ch'
#include 'fileio.ch'
#include 'tmsac12.ch'

Static _aTipoVeic   := {}   //-- Tipo de veiculo
Static _aCarroc     := {}   //-- Carrocerias
Static _aLocal      := {}   //-- Localidades
Static _aTipoPreco  := {}   //-- Tipos de precos
Static _aEspecie    := {}   //-- Especies de carga

//-----------------------------------------------------------------
/*/{Protheus.doc} TMSBCAFreteBras()
Classe criada para comunicação com a Frete Bras

@author Caio Murakami
@since 29/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
CLASS TMSBCAFreteBras

    //-- ESTRUTURA INFORMAÇÕES TOKEN
    DATA url_fb         As Character
    DATA grant_type     As Character
    DATA client_id      As Character
    DATA client_secret  As Character
    DATA username       As Character
    DATA password       As Character
    DATA scope          As Character
    DATA expires_in     As Numeric
    DATA access_token   As Character
    DATA refresh_token  As Character
    DATA date_token     As Date
    DATA time_token     As Character
    DATA id_totvs       As Character
	DATA UrlRegis		As Character
	DATA UrlBill		As Character
    
    //-- ESTRUTURA CRIAR FRETE
    DATA frete_id       As Character
    DATA origem_estado  As Numeric
    DATA origem_cidade  As Numeric
    DATA destino_estado AS Numeric
    DATA destino_cidade As Numeric
    DATA carga_desc     As Character    
    DATA carga_complem  As Logical
    DATA carga_especie  As Numeric
    DATA volume_qtde    As Numeric
    DATA volume_peso    As Numeric
    DATA volume_dimensao As Numeric
    DATA preco_tipo     As Numeric
    DATA preco_valor    As Numeric
    DATA paga_pedagio   As Logical
    DATA info_adicional As Character
    DATA exige_rastreio As Logical
    DATA veiculos_ids   As Array 
    DATA carroceria_ids As Array 

    //-- Estrutura fechar frete
    DATA placa_veiculo  As Character
    DATA cpf_motorista  As Character

    //-- ESTRUTURA ERROS
    DATA exibe_erro     As Logical
    DATA last_error     As Character

    METHOD New()                    Constructor   
    
    //-- Métodos Token
    METHOD GetAccessToken() //-- Buscar Token
    METHOD GetInfoToken()
    METHOD GravaToken()
    METHOD GetLastToken()
    METHOD GetDadosDM1()    //-- MÉTODO BUSCA DADOS TABELA DM1 - CONFIGURADOR 
    METHOD GetFreteId()
    METHOD GetError()
    METHOD SetMostraErro()
    METHOD GetStatusApp()

    //-- GETS FreteBras
    METHOD GetTipoVeiculo()
    METHOD GetCarroceriaVeiculo()
    METHOD GetEspecie()
    METHOD GetPreco()
    METHOD GetUnidades()
    
    //-- Métodos para criar o frete
    METHOD CriaFrete()
    METHOD IdVeicJson()
    METHOD IdCarrocJson()
    METHOD OrigemJson()
    METHOD DestinoJson()
    METHOD CargaJson()
    METHOD PrecoJson()  
    METHOD AlteraFrete()
    METHOD RenovaFrete()
    METHOD FechaFrete()
    METHOD DeletaFrete()
    METHOD TraceRegister()
    METHOD IsVersaoTrial()
    METHOD RetQtdOfertas()
    METHOD VldFrete()

    //-- Métodos para input de informações
    METHOD SetOrigemDestino()
    METHOD SetCarga()
    METHOD SetVolume()
    METHOD SetPreco()
    METHOD SetInfoAdic()
    METHOD SetVeiculos()
    METHOD SetPlacaCPF()
    METHOD SetString()

END CLASS

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Caio Murakami
@since 29/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD New() CLASS TMSBCAFreteBras

//-- token
::url_fb        := ""         
::grant_type    := "" 
::client_id     := ""    
::client_secret := "" 
::username      := ""   
::password      := ""  
::scope         := ""    
::expires_in    := 0  
::access_token  := ""  
::refresh_token := ""  
::date_token    := CToD("")
::time_token    := ""  
::exibe_erro    := !IsBlind()
::last_error    := ""

//-- cria frete
::origem_estado  := 0
::origem_cidade  := 0
::destino_estado := 0
::destino_cidade := 0
::carga_desc     := "" 
::carga_complem  := .F.
::carga_especie  := 0
::volume_qtde    := 0
::volume_peso    := 0
::volume_dimensao := 0
::preco_tipo     := 0
::preco_valor    := 0
::paga_pedagio   := .F.
::info_adicional := ""
::exige_rastreio := .F.
::veiculos_ids   := {}
::carroceria_ids := {}

//-- Infos do motorista
::placa_veiculo := ""
::cpf_motorista := ""

::GetDadosDM1() 

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetDadosDM1()
Obtém dados da DM1

@author Caio Murakami
@since 02/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetDadosDM1() CLASS TMSBCAFreteBras
Local aArea     := GetArea()

::url_fb        := ""     
::grant_type    := "" 
::client_id     := ""
::client_secret := ""
::username      := ""
::password      := ""
::id_totvs      := ""
::UrlRegis		:= ""
::UrlBill		:= ""

DM1->(dbSetOrder(2))//-- FILIAL+MSBLQL
If DM1->(dbSeek(xFilial("DM1") + "2" ))
    self:url_fb     := RTrim( Lower(DM1->DM1_URLFBR) )       
    ::grant_type    := "password" 
    ::client_id     := RTrim(DM1->DM1_IDFBR)  
    ::client_secret := RTrim(DM1->DM1_IDSECR)
    ::username      := RTrim(DM1->DM1_USER) 
    ::password      := RTrim(DM1->DM1_SENHA)
	If DM1->(ColumnPos("DM1_URLREG")) > 0 .AND. DM1->(ColumnPos("DM1_URLBIL")) > 0
		::UrlRegis		:= AllTrim(DM1->DM1_URLREG)
		::UrlBill		:= AllTrim(DM1->DM1_URLBIL)
    EndIf
    If DM1->(ColumnPos("DM1_IDTOTV")) > 0
        ::id_totvs  := RTrim(DM1->DM1_IDTOTV)
    EndIf
EndIf

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetAccessToken()
Método construtor da classe

@author Caio Murakami
@since 29/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetAccessToken() CLASS TMSBCAFreteBras
Local cToken        := ""
Local lRet          := .T. 
Local aHeader       := {}
Local cEvent        := "/oauth/token"
Local cResult       := ""
Local dDataToken    := Nil
Local cTimeToken    := ""
Local oRest         := FwRest():New( ::url_fb  ) 
Local oBody         := JsonObject():New()

cToken  := ::GetLastToken()

If Empty(cToken)
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Content-Type: application/json" )

    oBody["grant_type"]     := ::grant_type
    oBody["client_id"]      := ::client_id
    oBody["client_secret"]  := ::client_secret
    oBody["username"]       := ::username
    oBody["password"]       := ::password
    oBody["scope"]          := "central-assinante"
  
    //-- Data e Hora de envio do token
    dDataToken  := dDataBase
    cTimeToken  := Time()

    oRest:SetPath(cEvent) //-- um novo caminho> https://..../token
    oRest:SetPostParams( oBody:ToJson() )
    lRet    := oRest:Post( aHeader ) 

    If lRet
        cResult     := oRest:GetResult()
        If ::GetInfoToken(cResult,dDataToken,cTimeToken)        
            ::GravaToken()
            cToken      :=  ::access_token        
        EndIf
    Else
        ::last_error   := ::SetString( AllTrim(oRest:GetLastError()) + CHR(13) + AllTrim( oRest:GetResult() ) )
        
        If ::exibe_erro        
            MsgStop(::last_error)
        EndIf
    EndIf
    
    FwFreeArray(aHeader)
    FwFreeObj(oRest)
EndIf

Return cToken

//-----------------------------------------------------------------
/*/{Protheus.doc} GetInfoToken()
Método para obter as informações do token

@author Caio Murakami
@since 29/05/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetInfoToken( cResult , dDataToken , cTimeToken ) Class TMSBCAFreteBras
Local oObj      := Nil 
Local lRet      := .T. 

Default cResult     := ""
Default dDataToken  := dDataBase
Default cTimeToken  := Time()

If FWJsonDeserialize(cResult,@oObj)
    lRet    := .T. 
    ::expires_in    := oObj:expires_in
    ::access_token  := oObj:access_token
    ::refresh_token := oObj:refresh_token
    ::date_token    := dDataToken
    ::time_token    := StrTran(cTimeToken,":","")
Else
    lRet    := .F. 
EndIf

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} GravaToken()
Grava token na base de dados

@author Caio Murakami
@since 01/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GravaToken() CLASS TMSBCAFreteBras
Local aArea     := GetArea()

DM1->(dbSetOrder(2))
If DM1->( MsSeek( xFilial("DM1") + "2" )) //-- Desbloqueado
    RecLock("DM1",.F.)
    DM1->DM1_TOKEN	:= ::access_token
    DM1->DM1_DTTOKE	:= ::date_token 
    DM1->DM1_HRTOKE	:= ::time_token 
    DM1->DM1_EXPIRE := ::expires_in
    DM1->DM1_RFSTOK := ::refresh_token
    DM1->(MsUnlock())
EndIf

RestArea(aArea)
Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GetLastToken()
Obtém último token ativo, se houver

@author Caio Murakami
@since 01/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetLastToken() CLASS TMSBCAFreteBras
Local aArea         := GetArea()
Local cQuery        := ""
Local nTimeOut      := ""
Local dData         := cToD("")
Local nTimeToken    := ""
Local cToken        := ""
Local cAliasQry     := GetNextAlias()

cQuery  := " SELECT DM1.R_E_C_N_O_ DM1RECNO "
cQuery  += " FROM " + RetSQLName("DM1") + " DM1 "
cQuery  += " WHERE DM1_FILIAL  = '" + xFilial("DM1") + "' "
cQuery  += " AND DM1_MSBLQL = '2' "
cQuery  += " AND DM1_HRTOKE <> ''  "
cQuery  += " AND DM1.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )
TcSetField(cAliasQry,"DM1_DTTOKE","D",8,0)

While (cAliasQry)->( !Eof() )
    
    DM1->(DbGoTo( (cAliasQry)->DM1RECNO ))

    dData       := DM1->DM1_DTTOKE
    nTimeToken  := HoraToInt( DM1->DM1_HRTOKE )
    nTimeOut    := DM1->DM1_EXPIRE 
    
    If dData == dDataBase
        If SubHoras(Time(), IntToHora(nTimeToken)  ) < nTimeOut
            cToken  := DM1->DM1_TOKEN
        EndIf
    ElseIf DateDiffDay(dData , dDataBase ) == 1
        nTimeToken  := SubHoras("23:59",IntToHora(nTimeToken))
        nTimeToken  += HoraToInt(Time())

        If nTimeToken  < nTimeOut
            cToken  := DM1->DM1_TOKEN
        EndIf
    EndIf

    (cAliasQry)->( dbSkip() )
EndDo

(cAliasQry)->( dbCloseArea())

If !Empty(cToken)
    ::access_token  := cToken
    ::date_token    := dData
    ::time_token    := IntToHora( nTimeToken )
    ::expires_in    := nTimeOut
EndIf

RestArea(aArea)
Return cToken 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetTipoVeiculo()
GET no Tipo de Veículo

@author Caio Murakami
@since 01/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetTipoVeiculo() CLASS TMSBCAFreteBras
Local aHeader       := {}
Local lRet          := .T. 
Local cResult       := ""
Local oRest         := FwRest():New(::url_fb)
Local oJson         := nil
Local nCount        := 1 

If Len(_aTipoVeic) == 0

    //-----------------------------------------
    //-- Montagem Header
    //-----------------------------------------
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )
    Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

    oRest:SetPath("/v1/veiculos/tipos")
    lRet    := oRest:Get( aHeader )  

    If lRet 
        cResult := oRest:GetResult()

        //-- Transforma arquivo texto em objeto JSON
        oJson   := JsonObject():New()
        oJson:FromJson(cResult)

        For nCount := 1 To Len( ojson["data"] )            
         
            Aadd( _aTipoVeic, { ojson["data"][nCount]["id"] ,;
                                DecodeUtf8(ojson["data"][nCount]["nome"] ) ,; 
                                DecodeUtf8(ojson["data"][nCount]["categoria"] ) } )
        
        Next nCount
    EndIf
EndIf

FwFreeArray( aHeader )
FwFreeObj(oRest)
FwFreeObj(oJson)

Return _aTipoVeic

//-----------------------------------------------------------------
/*/{Protheus.doc} GetCarroceriaVeiculo()
GET na carroceria de veículos

@author Caio Murakami
@since 01/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetCarroceriaVeiculo() CLASS TMSBCAFreteBras
Local aHeader       := {}
Local lRet          := .T. 
Local cResult       := ""
Local oRest         := FwRest():New(::url_fb)
Local oJson         := nil
Local nCount        := 1 

If Len(_aCarroc) == 0 
    //-----------------------------------------
    //-- Montagem Header
    //-----------------------------------------
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )
    Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

    oRest:SetPath("/v1/veiculos/carrocerias"  )
    lRet    := oRest:Get( aHeader ) 

    If lRet 
        cResult := oRest:GetResult()

        //-- Transforma arquivo texto em objeto JSON
        oJson   := JsonObject():New()
        oJson:FromJson(cResult)

        For nCount := 1 To Len( ojson["data"] )
            Aadd( _aCarroc , { ojson["data"][nCount]["id"] ,;
                               DecodeUtf8(ojson["data"][nCount]["nome"] ) ,; 
                               DecodeUtf8(ojson["data"][nCount]["categoria"] ) } )
        
        Next nCount
    EndIf
EndIf

FwFreeArray( aHeader )
FwFreeObj(oRest)
FwFreeObj(oJson)

Return _aCarroc

//-----------------------------------------------------------------
/*/{Protheus.doc} GetEspecie()
GET na especies de carga

@author Caio Murakami
@since 04/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetEspecie() CLASS TMSBCAFreteBras
Local aHeader       := {}
Local lRet          := .T. 
Local cResult       := ""
Local oRest         := FwRest():New(::url_fb)
Local oJson         := nil
Local nCount        := 1 

If Len( _aEspecie ) == 0 
    //-----------------------------------------
    //-- Montagem Header
    //-----------------------------------------
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )
    Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

    oRest:SetPath("/v1/especies"  )
    lRet    := oRest:Get( aHeader )  
    
    If lRet
        cResult := oRest:GetResult()

        //-- Transforma arquivo texto em objeto JSON
        oJson   := JsonObject():New()
        oJson:FromJson(cResult)

        For nCount := 1 To Len( oJson["data"] )

            Aadd( _aEspecie , { ojson["data"][nCount]["id"] ,;
                                DecodeUtf8(ojson["data"][nCount]["nome"] ) } )
        Next nCount 
    EndIf

EndIf

FwFreeArray( aHeader )
FwFreeObj(oRest)
FwFreeObj(oJson)

Return _aEspecie

//-----------------------------------------------------------------
/*/{Protheus.doc} GetEspecie()
GET nos tipos de precos

@author Caio Murakami
@since 04/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetPreco() CLASS TMSBCAFreteBras
Local aHeader       := {}
Local lRet          := .T. 
Local cResult       := ""
Local oRest         := FwRest():New(::url_fb)
Local oJson         := nil
Local nCount        := 1 

If Len(_aTipoPreco) == 0 

    //-----------------------------------------
    //-- Montagem Header
    //-----------------------------------------
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )
    Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

    oRest:SetPath("/v1/tipos/precos"  )
    lRet    := oRest:Get( aHeader )  

    If lRet
        cResult := oRest:GetResult()

        //-- Transforma arquivo texto em objeto JSON
        oJson   := JsonObject():New()
        oJson:FromJson(cResult)

        For nCount := 1 To Len( oJson["data"] )

            Aadd( _aTipoPreco , { ojson["data"][nCount]["id"] ,;
                                 DecodeUtf8(ojson["data"][nCount]["nome"] ) } )
        Next nCount 

    EndIf

EndIf

FwFreeArray( aHeader )
FwFreeObj(oRest)
FwFreeObj(oJson)

Return _aTipoPreco

//-----------------------------------------------------------------
/*/{Protheus.doc} GetUnidades()
GET nas unidades

@author Caio Murakami
@since 04/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetUnidades() CLASS TMSBCAFreteBras
Local aHeader       := {}
Local lRet          := .T. 
Local cResult       := ""
Local oRest         := FwRest():New(::url_fb)
Local oJson         := nil
Local nCount        := 1 

If Len( _aLocal ) == 0 
    //-----------------------------------------
    //-- Montagem Header
    //-----------------------------------------
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Authorization: " + "Bearer " + ::access_token )
    Aadd(aHeader, "Content-Type: application/json" )
    Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

    oRest:SetPath("/v1/assinantes/unidades"  )
    lRet    := oRest:Get( aHeader )  
    cResult := oRest:GetResult()

    //-- Transforma arquivo texto em objeto JSON
    oJson   := JsonObject():New()
    oJson:FromJson(cResult)

     For nCount := 1 To Len( oJson["data"] )
            Aadd( _aLocal , { ojson["data"][nCount]["id"] ,;
                            DecodeUtf8(ojson["data"][nCount]["nome"] ) } )
    Next nCount 

EndIf

FwFreeArray( aHeader )
FwFreeObj(oRest)
FwFreeObj(oJson)

Return _aLocal

//-----------------------------------------------------------------
/*/{Protheus.doc} CriaFrete()

Cria frete por assinante

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD CriaFrete() CLASS TMSBCAFreteBras
Local lRet      := .F. 
Local aArea     := GetArea()
Local oBody     := JsonObject():new()
Local oRest     := FwRest():New(::url_fb)
Local aHeader   := {}
Local cJson     := ""
Local cResult   := ""

::GetDadosDM1()

If ::VldFrete()

    //-- Monta cabeçalho
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Content-Type: application/json" )
    Aadd(aHeader, "Authorization:" + "Bearer " + ::access_token )
    Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

    //-- Monta corpo da mensagem
    oBody["origem"]         := ::OrigemJson()
    oBody["destino"]        := ::DestinoJson()
    oBody["carga"]          := ::CargaJson()
    oBody["preco"]          := ::PrecoJson()
    oBody["pedagio_pago_pela_empresa"]  := ::paga_pedagio
    oBody["informacoes_adicionais"]     := ::info_adicional
    oBody["exige_rastreamento"]         := ::exige_rastreio
    oBody["veiculos"]       := ::veiculos_ids
    oBody["carrocerias"]    := ::carroceria_ids

    cJson   := EncodeUTF8( oBody:ToJson() )

    //-- Envio
    oRest:SetPath("/v1/assinantes/fretes") 
    oRest:SetPostParams( cJson )

    lRet    := oRest:Post( aClone(aHeader) ) 

    If lRet
        FwFreeObj( oBody )

        cResult := oRest:GetResult()

        oBody   := JsonObject():new()
        oBody:FromJson(cResult)

        ::frete_id  := RTrim( oBody["id"] )
        
        lRet    := ::TraceRegister( ::frete_id , ::id_totvs )

    Else
        ::last_error   := ::SetString( AllTrim(oRest:GetLastError()) + CHR(13) + AllTrim( oRest:GetResult() ) )
        If ::exibe_erro        
            MsgStop(::last_error)
        EndIf
    EndIf
Else
    ::last_error   := ""
    If ::exibe_erro        
        MsgStop(::last_error)
    EndIf
EndIf

FwFreeArray(aHeader)
FwFreeObj(oBody)
FwFreeObj(oRest)

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} AlteraFrete()

Altera frete por assinante

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD AlteraFrete( cFreteId ) CLASS TMSBCAFreteBras
Local lRet      := .F. 
Local aArea     := GetArea()
Local oBody     := JsonObject():new()
Local oRest     := FwRest():New(::url_fb)
Local aHeader   := {}
Local cJson     := ""
Local cResult   := ""

Default cFreteId    := ::frete_id

::GetDadosDM1()

//-- Monta cabeçalho
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Content-Type: application/json" )
Aadd(aHeader, "Authorization:" + "Bearer " + ::access_token )
Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")
Aadd(aHeader, "Accept-Charset: utf-8 ")

//-- Monta corpo da mensagem
oBody["origem"]         := ::OrigemJson()
oBody["destino"]        := ::DestinoJson()
oBody["carga"]          := ::CargaJson()
oBody["preco"]          := ::PrecoJson()
oBody["pedagio_pago_pela_empresa"]  := ::paga_pedagio
oBody["informacoes_adicionais"]     := ::info_adicional
oBody["exige_rastreamento"]         := ::exige_rastreio
oBody["veiculos"]       := ::veiculos_ids
oBody["carrocerias"]    := ::carroceria_ids

cJson   := EncodeUTF8( oBody:ToJson() )

//-- Envio
oRest:SetPath("/v1/assinantes/fretes/" + cFreteId ) 

lRet    := oRest:Put( aHeader , cJson ) 

If lRet
    FwFreeObj( oBody )

    cResult := oRest:GetResult()

    oBody   := JsonObject():new()
    oBody:FromJson(cResult)

    ::frete_id  := oBody["id"]
Else  

    ::last_error   := ::SetString(  AllTrim(oRest:GetLastError()) + CHR(13) + AllTrim( oRest:GetResult() ) ) 
    If ::exibe_erro        
        MsgStop(::last_error)
    EndIf
EndIf

FwFreeArray(aHeader)
FwFreeObj(oBody)
FwFreeObj(oRest)

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} DeletaFrete()

Deleta frete por assinante

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD DeletaFrete( cFreteId ) CLASS TMSBCAFreteBras
Local lRet      := .F. 
Local aArea     := GetArea()
Local oRest     := FwRest():New(::url_fb)
Local aHeader   := {}

Default cFreteId    := ::frete_id

::GetDadosDM1()

//-- Monta cabeçalho
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Content-Type: application/json" )
Aadd(aHeader, "Authorization:" + "Bearer " + ::access_token )
Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

//-- Envio
oRest:SetPath("/v1/assinantes/fretes/" + cFreteId ) 
lRet    := oRest:Delete( aHeader ) 

If lRet
    cResult     := oRest:GetResult()
Else
    ::last_error   := ::SetString( AllTrim(oRest:GetLastError()) + CHR(13) + AllTrim( oRest:GetResult() ) )
    If ::exibe_erro  .And. !("204" $ oRest:GetLastError() )     
        MsgStop(::last_error)
    Else
        lRet    := .T. 
    EndIf
EndIf

FwFreeArray(aHeader)
FwFreeObj(oRest)

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RenovaFrete()

Renova frete por assinante

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RenovaFrete( cFreteId ) CLASS TMSBCAFreteBras
Local lRet      := .F. 
Local aArea     := GetArea()
Local oRest     := FwRest():New(::url_fb)
Local aHeader   := {}
Local cResult   := ""

Default cFreteId    := ::frete_id

::GetDadosDM1()

//-- Monta cabeçalho
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Content-Type: application/json" )
Aadd(aHeader, "Authorization:" + "Bearer " + ::access_token )
Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

//-- Envio
oRest:SetPath("/v1/assinantes/fretes/" + cFreteId + "/renovar") 
lRet    := oRest:Put( aHeader ) 

If lRet
    cResult     := oRest:GetResult()
Else
    ::last_error   := ::SetString( AllTrim(oRest:GetLastError()) + CHR(13) + AllTrim( oRest:GetResult() ) )
    If ::exibe_erro        
        MsgStop(::last_error)
    EndIf
EndIf

FwFreeArray(aHeader)
FwFreeObj(oRest)

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} FechaFrete()

Fechar frete por assinante

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD FechaFrete( cFreteId ) CLASS TMSBCAFreteBras
Local lRet      := .F. 
Local aArea     := GetArea()
Local oBody     := JsonObject():new()
Local oRest     := FwRest():New(::url_fb)
Local aHeader   := {}

Default cFreteId    := ::frete_id

::GetDadosDM1()

//-- Monta cabeçalho
Aadd(aHeader, "Accept: application/json" )
Aadd(aHeader, "Content-Type: application/json" )
Aadd(aHeader, "Authorization:" + "Bearer " + ::access_token )
Aadd(aHeader, "user-agent: " + cModulo + "/V.1.00")

//-- Monta corpo da mensagem
oBody["placa"]      := ::placa_veiculo
oBody["cpf"]        := ::cpf_motorista

//-- Envio
oRest:SetPath("/v1/assinantes/fretes/" + cFreteId + "/concretizar") 
oRest:SetPostParams( oBody:ToJson() )
lRet    := oRest:Post( aHeader ) 

If lRet
    cResult     := oRest:GetResult()
Else
    ::last_error   := ::SetString( AllTrim(oRest:GetLastError()) + CHR(13) + AllTrim( oRest:GetResult() ) )
    If ::exibe_erro        
        MsgStop(::last_error)
    EndIf
EndIf

FwFreeArray(aHeader)
FwFreeObj(oBody)
FwFreeObj(oRest)

RestArea(aArea)
Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} OrigemJson()

Retorna json origem

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD OrigemJson() CLASS TMSBCAFreteBras
Local oJson     := JsonObject():New()

oJson["estado"]     := ::origem_estado
oJson["cidade"]     := ::origem_cidade

Return oJson

//-----------------------------------------------------------------
/*/{Protheus.doc} DestinoJson()

Retorna json origem

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD DestinoJson() CLASS TMSBCAFreteBras
Local oJson     := JsonObject():New()

oJson["estado"]     := ::destino_estado
oJson["cidade"]     := ::destino_cidade

Return oJson

//-----------------------------------------------------------------
/*/{Protheus.doc} CargaJson()

Retorna json origem

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD CargaJson() CLASS TMSBCAFreteBras
Local oJson     := JsonObject():New()
Local oVolume   := JsonObject():New()

oVolume["quantidade"]   := ::volume_qtde
oVolume["peso"]         := ::volume_peso
oVolume["dimensao"]     := ::volume_dimensao

oJson["descricao"]      := ::carga_desc
oJson["complemento"]    := ::carga_complem
oJson["especie"]        := ::carga_especie
oJson["volume"]         := oVolume

Return oJson 

//-----------------------------------------------------------------
/*/{Protheus.doc} PrecoJson()

Retorna json origem

@author Caio Murakami
@since 03/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD PrecoJson() CLASS TMSBCAFreteBras
Local oJson     := JsonObject():New()

oJson["tipo"]       := ::preco_tipo
oJson["valor"]      := ::preco_valor

Return oJson

//-----------------------------------------------------------------
/*/{Protheus.doc} GetFreteId()

Obtém frete ID

@author Caio Murakami
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetFreteId() CLASS TMSBCAFreteBras
Return ::frete_id

//-----------------------------------------------------------------
/*/{Protheus.doc} GetError()

Obtém erro

@author Caio Murakami
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetError() CLASS TMSBCAFreteBras
Return ::last_error

//-----------------------------------------------------------------
/*/{Protheus.doc} SetMostraErro()

Seta se deve exibir erro em tela sim ou não

@author Caio Murakami
@since 08/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetMostraErro( lRet ) CLASS TMSBCAFreteBras

Default lRet    := .T. 

::exibe_erro    := lRet

Return 

//-----------------------------------------------------------------
/*/{Protheus.doc} SetOrigemDestino()
Seta a origem e o destino

@author Caio Murakami
@since 10/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetOrigemDestino( cCodUFOri , cCodMunOri , cCodUFDes, cCodMunDes ) CLASS TMSBCAFreteBras

Default cCodUFOri   := ""
Default cCodMunOri  := ""
Default cCodUFDes   := ""
Default cCodMunDes  := ""

::origem_estado    := Val(cCodUFOri)
::origem_cidade    := Val(cCodMunOri)
::destino_estado   := Val(cCodUFDes)
::destino_cidade   := Val(cCodMunDes)

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetCarga()
Seta propriedades da carga

@author Caio Murakami
@since 10/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetCarga( cDesc , lComplem , nEspecie ) CLASS TMSBCAFreteBras

Default cDesc       := ""
Default lComplem    := .F.
Default nEspecie    := 0

::carga_desc        := cDesc
::carga_complem     := lComplem
::carga_especie     := nEspecie

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetVolume()
Seta propriedades de volume

@author Caio Murakami
@since 10/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetVolume( nQtde , nPeso , nDimensao ) CLASS TMSBCAFreteBras

Default nQtde       := 0 
Default nPeso       := 0 
Default nDimensao   := 0 

::volume_qtde      := nQtde
::volume_peso      := nPeso
::volume_dimensao  := nDimensao

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetPreco()
Seta tipo de preço e valor

@author Caio Murakami
@since 10/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetPreco( nTipo, nPreco ) CLASS TMSBCAFreteBras

Default nTipo   := 0 
Default nPreco  := 0

::preco_tipo       := nTipo
::preco_valor      := nPreco

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetInfoAdic()
Seta as informações adicionais

@author Caio Murakami
@since 10/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetInfoAdic( lPagaPdg , cInfoAdic, lRastreio ) CLASS TMSBCAFreteBras

Default lPagaPdg    := .F. 
Default cInfoAdic   := ""
Default lRastreio   := .F. 

::paga_pedagio      := lPagaPdg
::info_adicional    := cInfoAdic
::exige_rastreio    := lRastreio

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetVeiculos()
Seta veículos e carroceria do veículo

@author Caio Murakami
@since 10/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetVeiculos( aIDVeic , aIDCarroc ) CLASS TMSBCAFreteBras

Default aIDVeic     := {}
Default aIDCarroc   := {}

::veiculos_ids      := aIDVeic
::carroceria_ids    := aIDCarroc

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetPlacaCPF()
Seta placa e CP`F

@author Caio Murakami
@since 16/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetPlacaCPF( cPlaca , cCPF ) CLASS TMSBCAFreteBras

Default cPlaca  := ""
Default cCPF    := ""

::placa_veiculo    := cPlaca
::cpf_motorista    := cCPF

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} SetString()
Seta string

@author Caio Murakami
@since 19/06/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD SetString(cString) CLASS TMSBCAFreteBras

cString := StrTran(cString,"\u00e7","ç")
cString := StrTran(cString,"\u00e3","ã")
cString := StrTran(cString,"\u00e9","é")

Return cString

//-----------------------------------------------------------------
/*/{Protheus.doc} TraceRegister()
Registra bilhetagem

@author Caio Murakami
@since 06/08/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD TraceRegister( cFreteId , cToken ) CLASS TMSBCAFreteBras
Local cUrl      := ""//"http://plan-usage-tracker.k8s-platform-prod-us-east-1.fluig.io" Local cUrl      := "http://plan-usage-tracker-homolog.k8s-platform-dev-us-east-1.fluig.io"
Local oRest     := Nil
Local aHeader   := {}
Local cJson     := ""
Local lRet      := .T. 
Local cResult   := ""
Local oBody     := JsonObject():new()

Default cFreteId    := ""
Default cToken      := ""

DM1->(dbSetOrder(2))//-- FILIAL + MSBLQL
If !Empty(cToken) .AND. DM1->(dbSeek(xFilial("DM1") + "2" ))
	If DM1->(ColumnPos("DM1_URLREG")) > 0
		cUrl	:= AllTrim(DM1->DM1_URLREG)
	EndIf
	oRest	:= FwRest():New(cUrl)
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Content-Type: application/json")
    Aadd(aHeader, "X-API-Key: " + cToken )

    oBody["code"]       := "logistica.publicarcarga.cargas"
    oBody["eventDate"]  :=  FWTimeStamp( 6 , dDataBase , Time() )
    oBody["value"]      := 1

    cJson   :=  EncodeUTF8( oBody:ToJson() ) 

    //-- Envio
    oRest:SetPath( "/plan-usage-tracker/api/v1/trace-registers" ) 
    oRest:SetPostParams( cJson )
    lRet    := oRest:Post( aClone(aHeader) )

    If !lRet
        If "204" $ oRest:GetLastError()
            lRet    := .T. 
        Else
            cResult := AllTrim( oRest:GetLastError() ) +chr(10) + chr(13)
            cResult += AllTrim( oRest:cResult )  
            ::last_error    := STR0002 + STR0003 + chr(13) + chr(10) + STR0004 + cResult //-- "Erro ao registrar a bilhetagem no FLUIG. O Frete foi incluído com sucesso, porém o mesmo não foi registrado. Entre em contato com o suporte e informe o erro: "
        EndIf
    EndIf
EndIf 

Return lRet

//-----------------------------------------------------------------
/*/{Protheus.doc} RetQtdOfertas()
Retorna quantidade de ofertas de frete publicadas

@author Caio Murakami
@since 17/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD RetQtdOfertas() CLASS TMSBCAFreteBras
Local aArea     := GetArea()
Local nQtde     := 0 
Local cQuery    := ""
Local cAliasQry := GetNextAlias()

cQuery  := " SELECT COUNT(*) QTDFRETE "
cQuery  += " FROM " + RetSQLName("DM2") + " DM2 "
cQuery  += " WHERE DM2_FILIAL   = '" + xFilial("DM2") + "' "
cQuery  += " AND DM2_IDFRT      <> '' "
 
cQuery := ChangeQuery( cQuery )
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery ), cAliasQry, .F., .T. )

While (cAliasQry)->( !Eof() )
    nQtde   := (cAliasQry)->QTDFRETE
    (cAliasQry)->(dbSkip())
EndDo 

(cAliasQry)->(dbCloseArea())

RestArea( aArea )
Return nQtde

//-----------------------------------------------------------------
/*/{Protheus.doc} VldFrete()
Retorna se o frete é válido

@author Caio Murakami
@since 17/09/2020
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD VldFrete() CLASS TMSBCAFreteBras
Local lRet      := .T. 

If Empty(::id_totvs ) .And. ::RetQtdOfertas() > 50
    lRet    := .F. 
EndIf 

Return lRet 

//-----------------------------------------------------------------
/*/{Protheus.doc} GetStatusApp()
Get Qtde Billing

@author Caio Murakami
@since 01/03/2021
@version 1.0
/*/
//--------------------------------------------------------------------
METHOD GetStatusApp() CLASS TMSBCAFreteBras

Local cApi		:= ""//"https://subscriptions-homolog.k8s-platform-dev-us-east-1.fluig.io/subscriptions/swagger-ui.html#/SubscriptionPlans"
Local oRest     := NIL
Local aHeader   := {}
Local lRet      := .F. 
Local cResult   := ""
Local oBody     := JsonObject():new()
Local oJson     := Nil 

DM1->(dbSetOrder(2))//-- FILIAL + MSBLQL
If DM1->(dbSeek(xFilial("DM1") + "2" ))
    If DM1->(ColumnPos("DM1_IDTOTV")) > 0
        ::id_totvs  := RTrim(DM1->DM1_IDTOTV)
    EndIf
	If DM1->(ColumnPos("DM1_URLBIL")) > 0
		cApi		:= AllTrim(DM1->DM1_URLBIL)
	EndIf
	oRest     := FwRest():New( cApi )
    Aadd(aHeader, "Accept: application/json" )
    Aadd(aHeader, "Content-Type: application/json")
    Aadd(aHeader, "X-API-Key: " + ::id_totvs  )

    oBody["appCode"]    := "publicarcarga"
    
	oRest:SetPath("/subscriptions/api/v1/subscription-plans/publicarcarga/status")
    lRet    := oRest:Get( aHeader  )  

    If lRet 
        cResult := oRest:GetResult()

        //-- Transforma arquivo texto em objeto JSON
        oJson   := JsonObject():New()
        oJson:FromJson(cResult)
        
        If AllTrim( Upper( oJson["status"] ) ) == "CANCELED" .Or. AllTrim( Upper( oJson["status"] ) ) == "TRIAL_END"
            lRet    := .F. 
        EndIf 
        
    EndIf

EndIf


Return lRet 
