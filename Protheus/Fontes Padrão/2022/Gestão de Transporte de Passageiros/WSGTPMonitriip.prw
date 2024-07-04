
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "SHELL.CH"

Static oTmpTab

//-------------------------------------------------------------------
/*/{Protheus.doc} WSGtpForms
MÃ©todos WS do GTP para integraÃ§Ã£o da ficha de remessa

@author SIGAGTP
@since 09/03/2021
@version 1.0

/*/
//-------------------------------------------------------------------

WSRESTFUL GTPMonitriip DESCRIPTION "WS de Integração entre o App Monitriip o módulo com Transporte de Passageiros" 

    WSDATA idDriver as STRING
    WSDATA documentDriver as STRING
    WSDATA licenseDriver  as STRING
    WSDATA nameDriver as STRING
    WSDATA idTrip as STRING
    WSDATA fromDateTrip as STRING
    WSDATA toDateTrip as STRING
    WSDATA fromTimeTrip as STRING
    WSDATA toTimeTrip as STRING
    WSDATA fromLocal as STRING
    WSDATA toLocal as STRING
    WSDATA idVehicle as STRING 

	// MÃ©todos GET
	WSMETHOD GET getTrip 	    DESCRIPTION 'Retorna a(s) viagem(ns) do motorista'  PATH "getTrip"          PRODUCES APPLICATION_JSON 
	WSMETHOD GET getDriver 	    DESCRIPTION 'Retorna dados do motorista'            PATH "getDriver"        PRODUCES APPLICATION_JSON 
	WSMETHOD GET getVehicleTrip DESCRIPTION 'Retorna dados do veÃ­culo da viagem'    PATH "getVehicleTrip"   PRODUCES APPLICATION_JSON 
	
	// MÃ©todos POST
	WSMETHOD POST beginTrip DESCRIPTION 'Inicia a viagem'  PATH "beginTrip" PRODUCES APPLICATION_JSON 
	WSMETHOD POST endTrip DESCRIPTION 'Finaliza a viagem'  PATH "endTrip" PRODUCES APPLICATION_JSON 
	WSMETHOD POST setOcurrencesTrip DESCRIPTION 'Finaliza a viagem'  PATH "setOcurrencesTrip" PRODUCES APPLICATION_JSON 

END WSRESTFUL

//-------------------------------------------------------------------
/*/{Protheus.doc}  
@method: getTrip
@service REST: GTPMonitriip
Retorna dados da viagem
@params
    idTrip*, caractere, identificador da viagem
    fromDateTrip, caractere, data de início da viagem (formato: aaaammdd)
    toDateTrip, caractere, data final da viagem (formato: aaaammdd)
    fromTimeTrip, caractere, horário de início da viagem (formato: 9999)
    toTimeTrip, caractere, horário final da viagem (formato: 9999)
    fromLocal, caractere, identificador da localidade de partida da viagem
    toLocal, caractere, identificador da localidade de chegada da viagem
    documentDriver, caractere, número do CPF do motorista
* parâmetros não obrigatórios
@return
    json com a formatação:
    
        membros: 
        {
            driverId: caractere,  identificador do Motorista
            tripDateStart: caractere, formato dd/mm/aaaa, data de início da viagem
            tripTimeStart: caractere, formato 99:99, hora inicial da viagem
            tripEnding: caractere, viagem está finalizada? (1- sim, 2-não)
            tripDateEnd: caractere, formato dd/mm/aaaa, data final da viagem
            tripLocalOrigin: caractere, Id da Localidade de partida da viagem
            tripDescDestination: caractere, Descrição da Localidade de chegada da viagem
            driverDocument: caractere, nro do CPF do motorista da viagem
            tripId: caractere, identificador da viagem
            tripType: caractere, tipo de viagem, 1=Normal;2=Extraordinária;3=Fret. Contínuo
            tripTimeEnd: caractere, formato 99:99, hora de finalização da viagem
            tripWay: caractere, sentido da viagem, 1=Ida;2=Volta
            tripExtraordinary: caractere, viagem extra? T, sim; F, não
            tripDescOrigin: caractere, descrição da localidade de partida
            tripLocalDestination: caractere, identificador da localidade de destino da viagem
        }
    Exemplo:
    {
        "driverId": "GTP001BUS",
        "tripDateStart": "23/09/2021",
        "tripTimeStart": "08:00",
        "tripEnding": "1",
        "tripDateEnd": "23/09/2021",
        "tripLocalOrigin": "LOC001",
        "tripDescDestination": "BELO HORIZONTE                          ",
        "driverDocument": "40426778006",
        "tripId": "000680",
        "tripType": "3",
        "tripTimeEnd": "18:00",
        "tripWay": "1",
        "tripExtraordinary": "F",
        "tripDescOrigin": "SAO PAULO                               ",
        "tripLocalDestination": "LOC002"
    }
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET getTrip WSRECEIVE idTrip, fromDateTrip, toDateTrip, fromTimeTrip, toTimeTrip, fromLocal, toLocal, documentDriver  WSREST GTPMonitriip

    Local lRet := .T.
    
    // Local oTmpTab
    Local oResponse

    Local cQry  := ""
    Local cMsg  := ""
    
    lRet := !Empty(self:idTrip) 

    If ( lRet )
        
        lRet := !Empty(self:documentDriver)
        
        If (!lRet)
            cMsg := "O parâmetro 'documentDriver' não foi preenchido."            
        EndIf

    Else

        lRet := !Empty(self:fromDateTrip) 
        lRet := lRet .And. !Empty(self:toDateTrip) 
        lRet := lRet .And. !Empty(self:fromTimeTrip)
        lRet := lRet .And. !Empty(self:toTimeTrip)
        lRet := lRet .And. !Empty(self:fromLocal)
        lRet := lRet .And. !Empty(self:toLocal)
        lRet := lRet .And. !Empty(self:documentDriver)
    
    EndIf

    If ( lRet )

        cQry := "SELECT distinct " + chr(13)
        cQry += TripFields()
        cQry += "FROM " + chr(13)
        cQry += "    " + RetSQLName("GYN") + " GYN " + chr(13)
        cQry += "INNER JOIN " + chr(13)
        cQry += "    " + RetSQLName("GQE") + " GQE " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    GQE.D_E_L_E_T_ = ' ' " + chr(13)
        cQry += "    AND GQE_FILIAL = GYN.GYN_FILIAL " + chr(13)
        cQry += "    AND GQE_VIACOD = GYN.GYN_CODIGO " + chr(13)
        cQry += "    AND GQE_TRECUR = '1' " + chr(13)
        cQry += "    AND GQE_TCOLAB = '01' " + chr(13)
        cQry += "INNER JOIN	" + chr(13)
        cQry += "    " + RetSQLName("GYG") + " GYG " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    GYG.D_E_L_E_T_ = ' ' " + chr(13)
        cQry += "    AND GYG_FILIAL = GQE_FILIAL " + chr(13)
        cQry += "    AND GYG_CODIGO = GYG_CODIGO " + chr(13)
        cQry += "    AND GYG_RECCOD = GQE_TCOLAB " + chr(13)
        cQry += "    AND GYG_CPF = '" + self:documentDriver + "' " + chr(13)
        cQry += "WHERE " + chr(13)
        cQry += TripFilter(self)
        
        cQry += " UNION " + chr(13)

        cQry += "SELECT distinct " + chr(13)
        cQry += TripFields()
        cQry += "FROM " + chr(13)
        cQry += "    " + RetSQLName("GYN") + " GYN " + chr(13)
        cQry += "INNER JOIN " + chr(13)
        cQry += "    " + RetSQLName("GQK") + " GQK " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    GQK.D_E_L_E_T_ = ' ' " + chr(13)
        cQry += "    AND GQK_FILIAL = GYN.GYN_FILIAL " + chr(13)
        cQry += "    AND GQK_CODVIA = GYN.GYN_CODIGO " + chr(13)
        cQry += "    AND GQK_TRECUR = '1' " + chr(13)
        cQry += "    AND GQK_TCOLAB = '01' " + chr(13)
        cQry += "INNER JOIN	" + chr(13)
        cQry += "    " + RetSQLName("GYG") + " GYG " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    GYG.D_E_L_E_T_ = ' ' " + chr(13)
        cQry += "    AND GYG_FILIAL = GQK_FILIAL " + chr(13)
        cQry += "    AND GYG_CODIGO = GYG_CODIGO " + chr(13)
        cQry += "    AND GYG_RECCOD = GQK_TCOLAB " + chr(13)
        cQry += "    AND GYG_CPF = '" + self:documentDriver + "' " + chr(13)
        cQry += "WHERE " + chr(13)
        cQry += TripFilter(self)

        GTPTemporaryTable(cQry,,,,@oTmpTab)  //oTmpTab := GTPTemporaryTable(cQry)

        If ( (oTmpTab:GetAlias())->(!Eof()) )
            
            oResponse := JsonObject():New()
            
            oResponse["branchId"]               := (oTmpTab:GetAlias())->(GYG_CODIGO)
            oResponse["driverId"]               := (oTmpTab:GetAlias())->(GYG_CODIGO)
            oResponse["driverDocument"]         := (oTmpTab:GetAlias())->(GYG_CPF)
            oResponse["tripId"]                 := (oTmpTab:GetAlias())->(GYN_CODIGO)
            oResponse["tripType"]               := (oTmpTab:GetAlias())->(GYN_TIPO)
            oResponse["tripWay"]                := (oTmpTab:GetAlias())->(GYN_LINSEN)
            oResponse["tripLocalOrigin"]        := (oTmpTab:GetAlias())->(GYN_LOCORI)
            oResponse["tripDescOrigin"]         := Posicione("GI1", 1, xFilial("GI1")+(oTmpTab:GetAlias())->(GYN_LOCORI), "GI1_DESCRI")
            oResponse["tripLocalDestination"]   := (oTmpTab:GetAlias())->(GYN_LOCDES)
            oResponse["tripDescDestination"]    := Posicione("GI1", 1, xFilial("GI1")+(oTmpTab:GetAlias())->(GYN_LOCDES), "GI1_DESCRI")
            oResponse["tripDateStart"]          := GTPCastType(GTPCastType((oTmpTab:GetAlias())->(GYN_DTINI),"D"),"C","dd/mm/aaaa")
            oResponse["tripTimeStart"]          := GTPCastType((oTmpTab:GetAlias())->(GYN_HRINI),"C","99:99")
            oResponse["tripDateEnd"]            := GTPCastType(GTPCastType((oTmpTab:GetAlias())->(GYN_DTFIM),"D"),"C","dd/mm/aaaa")
            oResponse["tripTimeEnd"]            := GTPCastType((oTmpTab:GetAlias())->(GYN_HRFIM),"C","99:99")
            oResponse["tripEnding"]             := (oTmpTab:GetAlias())->(GYN_FINAL)
            oResponse["tripExtraordinary"]      := (oTmpTab:GetAlias())->(GYN_EXTRA)

            Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

        Else
            lRet := .F.
            cMsg := "Dados da viagem não foram localizados."
        EndIf

        // oTmpTab:Delete()

    Else

        lRet := .F.
        
        cMsg := "Um ou mais parâmetros, da lista a seguir, não foram preenchidos: "
        cMsg += "'fromDateTrip', 'toDateTrip', 'fromTimeTrip', 'toTimeTrip', 'fromLocal', 'toLocal', 'documentDriver' "
        
        
    EndIf
    
    If (!lRet)
        SetRestFault(400, EncodeUtf8(cMsg))
    EndIf        

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}  
@method: getDriver
@service REST: GTPMonitriip
Retorna dados do motorista
@params
    idDriver*, caractere, identificador do motorista
    documentDriver, caractere, nro do CPF do motorista
    licenseDriver*, caractere, nro da CNH do motorista
    nameDriver*, caractere, nome do motorista
* parâmetros não obrigatórios
@return
    json com a formatação:
    
        membros: 
            branchId: caractere,  identificador do filial do Motorista
            driverId: caractere, identificador do Motorista
            driverLicense: caractere, nro da CNH do Motorista
            driverDocument: caractere, nro do CPF do motorista
            driverName: caractere, nome do Motorista
    }
    Exemplo:
    {
        "branchId": "D MG    ",
        "driverId": "000001",
        "driverLicense": "         ",
        "driverDocument": "40426778006",
        "driverName": "GTP001                        "
    }
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET getDriver WSRECEIVE idDriver, documentDriver, licenseDriver, nameDriver WSREST GTPMonitriip

    Local aResult   := {{"GYG_FILIAL","GYG_CODIGO","GYG_NOME","GYG_CPF","GYG_CNHNUM"}}
    Local aSeek     := {}

    Local oResponse 
    
    Local lRet      := .t.
    
    If ( !Empty(self:documentDriver) )

        aAdd(aSeek,{"GYG_CODIGO",   self:idDriver})
        aAdd(aSeek,{"GYG_CPF",      self:documentDriver})
        aAdd(aSeek,{"GYG_CNHNUM",   self:licenseDriver})
        aAdd(aSeek,{"GYG_NOME",     self:nameDriver})

        While ( ( nP := aScan(aSeek,{|x| Valtype(x[2]) == "U" }) ) > 0 )
            aSeek[nP,2] := ""
        End While 

        If ( SeekDriver(aSeek,aResult) )
            
            oResponse := JsonObject():New()
            
            oResponse['branchId'] 		:= aResult[2,1]
            oResponse['driverId']		:= aResult[2,2]
            oResponse['driverName']	    := aResult[2,3]
            oResponse['driverDocument'] := aResult[2,4]
            oResponse['driverLicense']	:= aResult[2,5]
            
            Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))
        
        Else
            lRet := .F.
            SetRestFault(400, EncodeUtf8("Não foi possível localizar registro do motorista"))
        EndIf

    Else
        lRet := .F.
        SetRestFault(400, EncodeUtf8("O parâmetro 'documentDriver' não foi informado. Ele é obrigatório."))
    EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}  
@method: getVehicleTrip
@service REST: GTPMonitriip
Retorna dados do Veículo da viagem
@params
    idVehicle*, caractere, Identificador do veículo
    fromDateTrip, caractere, formato aaaammdd, Data de início da viagem
    toDateTrip, caractere, formato aaaammdd, data final da viagem
    fromTimeTrip, caractere, formato 99:99, hora de início da viagem
    toTimeTrip, caractere, formato 99:99, hora final da viagem
    fromLocal, caractere, Identificador da localidade de partida 
    toLocal, caractere, identificador da localicadade de chegada
    documentDriver, caractere, nro do CPF do motorista da viagem
* parâmetros não obrigatórios
@return
    json com a formatação:
    
        membros: 
        {
            vehicleDesc: caractere,  descrição do veículo
            branchId: caractere, filial do cadastro do veículo
            vehicleId: caractere, identificador do cadastro do veículo
            tripId: caractere, identificador da viagem na qual o veículo está alocado           
        }
    Exemplo:
   {
        "vehicleDesc": "DSERGTP-2078                            ",
        "branchId": "D MG 01 ",
        "vehicleId": "GTPVEIC01       ",
        "tripId": "000680"
    }
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
WSMETHOD GET getVehicleTrip WSRECEIVE idVehicle, fromDateTrip, toDateTrip, fromTimeTrip, toTimeTrip, fromLocal, toLocal, documentDriver WSREST GTPMonitriip

    Local lRet  := .T.

    Local cQry  := ""
    Local cMsg  := ""

    // Local oTmpTab
    Local oResponse
    
    lRet := !Empty(self:idVehicle)
    lRet := lRet .Or. !Empty(self:fromDateTrip)
    lRet := lRet .And. !Empty(self:toDateTrip)
    lRet := lRet .And. !Empty(self:fromTimeTrip)
    lRet := lRet .And. !Empty(self:toTimeTrip)
    lRet := lRet .And. !Empty(self:fromLocal)
    lRet := lRet .And. !Empty(self:toLocal)
    lRet := lRet .And. !Empty(self:documentDriver)
    
    If ( lRet )

        cQry := "SELECT " + chr(13)
        cQry += VehicleFields()
        cQry += "FROM " + chr(13)
        cQry += "    " + RetSQLName("GYN") + " GYN " + chr(13)
        cQry += "INNER JOIN " + chr(13)
        cQry += "    " + RetSQLName("GQE") + " GQE " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    GQE_FILIAL = GYN_FILIAL " + chr(13)
        cQry += "    AND GQE_VIACOD = GYN_CODIGO	 " + chr(13)
        cQry += "    AND GQE_TRECUR = '2' " + chr(13)
        cQry += "    AND GQE_CANCEL = '1' " + chr(13)
        cQry += "    AND GQE.D_E_L_E_T_ = ' ' " + chr(13)
        cQry += "INNER JOIN " + chr(13)
        cQry += "    " + RetSQLName("ST9") + " ST9 " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    T9_CODBEM = GQE_RECURS " + chr(13)
        
        If ( !Empty(self:idVehicle) )
            cQry += "    AND ST9.T9_CODBEM = '" + self:idVehicle + "' " + chr(13)
        EndIf

        cQry += "    AND ST9.D_E_L_E_T_ = '' " + chr(13)
        cQry += "WHERE " + chr(13)
        cQry += VehicleFilter(self,"GQE")

        cQry += " UNION " + chr(13)

        cQry += "SELECT " + chr(13)
        cQry += VehicleFields()
        cQry += "FROM " + chr(13)
        cQry += "    " + RetSQLName("GYN") + " GYN " + chr(13)
        cQry += "INNER JOIN " + chr(13)
        cQry += "    " + RetSQLName("GQK") + " GQK " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    GQK_FILIAL = GYN_FILIAL " + chr(13)
        cQry += "    AND GQK_CODVIA = GYN_CODIGO	 " + chr(13)
        cQry += "    AND GQK_TRECUR = '2' " + chr(13)
        cQry += "    AND GQK.D_E_L_E_T_ = ' ' " + chr(13)
        cQry += "INNER JOIN " + chr(13)
        cQry += "    " + RetSQLName("ST9") + " ST9 " + chr(13)
        cQry += "ON " + chr(13)
        cQry += "    T9_CODBEM = GQK_RECURS " + chr(13)
        
        If ( !Empty(self:idVehicle) )
            cQry += "    AND ST9.T9_CODBEM = '" + self:idVehicle + "' " + chr(13)
        EndIf

        cQry += "    AND ST9.D_E_L_E_T_ = '' " + chr(13)
        cQry += "WHERE " + chr(13)
        cQry += VehicleFilter(self,"GQK")

        GTPTemporaryTable(cQry,,,,@oTmpTab)  //oTmpTab := GTPTemporaryTable(cQry)

        If ( (oTmpTab:GetAlias())->(!Eof()) )
            
            oResponse := JsonObject():New()
            
            oResponse["branchId"]       := (oTmpTab:GetAlias())->(FILIAL)
            oResponse["vehicleId"]      := (oTmpTab:GetAlias())->(ID_VEICULO)
            oResponse["vehicleDesc"]    := (oTmpTab:GetAlias())->(DESC_VEICU)
            oResponse["tripId"]         := (oTmpTab:GetAlias())->(ID_VAIGEM)

            Self:SetResponse(FWJsonSerialize(oResponse, .F., .F., .T.))

        Else
            lRet := .F.
            cMsg := "Dados do veículo não foram localizados."            
        EndIf

        // oTmpTab:Delete()
    
    Else
        
        cMsg := "Um ou mais parâmetros, da lista a seguir, não foram preenchidos: "
        cMsg += "'fromDateTrip', 'toDateTrip', 'fromTimeTrip', 'toTimeTrip', 'fromLocal', 'toLocal', 'documentDriver' "
        
        lRet := .F.       

    EndIf
    
    If (!lRet)
        SetRestFault(400, EncodeUtf8(cMsg))
    EndIf        

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc}  
@static function: SeekDriver
Função RECURSIVA de busca de motorista. A consulta dos dados do motorista será realizado de acordo
com o parâmetro aSeek. Este array pode possuir dados em branco ou até mesmo nulo. A função se 
responsabiliza por efetuar a busca de acordo com os dados efetivos que possui advindo 
do parâmetro aSeek.
@params
    aSeek, array, possui elementos com o nome do campo e o valor de busca,
        aSeek[n,1], caractere, nome do campo
        aSeek[n,2], qualquer, valor a ser buscado por equivalência ao campo de [n,1]
    aResult, array, possui o resultset da busca do motorista
        aResult[1], array com os campos do cabeçalho do resultset (campos do select)
            aResult[1,n], caractere, nome do campo
        aReseult[n], array, possui os valores retornados da consulta
            aRetult[n,m], qualquer, dado localizado de acordo com o tipo de campo de aResult[1,n]
    
@return
    lRet, lógico, .T., consulta de motorista realizada com sucesso
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SeekDriver(aSeek,aResult)

    Local lRet  := .T.
    
    Local nP    := 0
    
    Default aSeek     := {}
    Default aResult   := {}

    If ( Len(aResult) <= 1 )
        
        GTPSeekTable("GYG",aSeek,aResult,.F.)

        If ( Len(aResult) <= 1 .And. Len(aSeek) > 0 )            
            
            nP := aScan(aSeek,{|x| Empty(x[2])})
            
            If ( nP > 0 )
                aDel(aSeek,nP)
                aSize(aSeek,Len(aSeek)-1)
            Else
                Return (Len(aResult) > 1)
            EndIf
            
            lRet := SeekDriver(aSeek,aResult)            

        EndIf

    EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}  
@static function: TripFields
Esta função retorna uma string com os campos que serão utilizados na query
que efetua a consulta de viagem
@params
@return
    cFields, caractetere, lista de campos, em formato de "select" (query)
    para consulta da viagem
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TripFields()

    Local cFields := ""

    cFields += "    GYG_CODIGO, " + chr(13)
    cFields += "    GYG_CPF, " + chr(13)
    cFields += "    GYN_FILIAL, " + chr(13)
    cFields += "    GYN_CODIGO, " + chr(13)
    cFields += "    GYN_TIPO, " + chr(13)
    cFields += "    GYN_LINSEN, " + chr(13)
    cFields += "    GYN_LOCORI, " + chr(13)
    cFields += "    GYN_LOCDES, " + chr(13)
    cFields += "    GYN_DTINI, " + chr(13)
    cFields += "    GYN_HRINI, " + chr(13)
    cFields += "    GYN_DTFIM, " + chr(13)
    cFields += "    GYN_HRFIM, " + chr(13)
    cFields += "    GYN_FINAL, " + chr(13)
    cFields += "    GYN_EXTRA  " + chr(13)

Return(cFields)
//-------------------------------------------------------------------
/*/{Protheus.doc}  
@static function: VehicleFields
Esta função retorna uma string com os campos que serão utilizados na query
que efetua a consulta de veículo
@params
@return
    cFields, caractere, lista de campos, em formato de "select" (query)
    para consulta da veículo
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VehicleFields()

    Local cFields := ""
    
    cFields += "    T9_FILIAL   FILIAL, " + chr(13)
    cFields += "    T9_CODBEM   ID_VEICULO, " + chr(13)
    cFields += "    T9_NOME     DESC_VEICU,  " + chr(13)
    cFields += "    GYN_CODIGO  ID_VAIGEM " + chr(13)
    
Return(cFields)

//-------------------------------------------------------------------
/*/{Protheus.doc}  
@static function: TripFilter
Esta função retorna uma string com o filtro que será utilizado na 
clausula where da query que efetua a consulta de viagem
@params
    oWS, objeto, instância de WSGTPMonitriip
@return
    cWhere, caractetere, filtro da query para consulta da viagem
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function TripFilter(oWS)

    Local cWhere := ""
    
    cWhere := "    GYN.D_E_L_E_T_ = ' ' " + chr(13)
        
    If ( !Empty(oWS:idTrip) )
        cWhere += "    AND GYN_CODIGO = '" + oWS:idTrip + "' "
    Else
        
        cWhere += "    AND GYN_DTINI = '" + oWS:fromDateTrip + "' " + chr(13)
        cWhere += "    AND GYN_DTFIM = '" + oWS:toDateTrip + "' " + chr(13)
        cWhere += "    AND GYN_HRINI = '" + oWS:fromTimeTrip + "' " + chr(13)
        cWhere += "    AND GYN_HRFIM = '" + oWS:toTimeTrip + "' " + chr(13)
        cWhere += "    AND GYN_LOCORI = '" + oWS:fromLocal + "' " + chr(13)
        cWhere += "    AND GYN_LOCDES = '" + oWS:toLocal + "' "  + chr(13)

    EndIf
    
Return(cWhere)

//-------------------------------------------------------------------
/*/{Protheus.doc}  
@static function: VehicleFilter
Esta função retorna uma string com o filtro que será utilizado na 
clausula where da query que efetua a consulta de veículo
@params
    oWS, objeto, instância de WSGTPMonitriip
@return
    cWhere, caractetere, filtro da query para consulta da veículo
@author SIGAGTP
@since 10/02/2022
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function VehicleFilter(oWS,cAlias)

    Local cWhere    := ""
    Local cField    := IIf(cAlias == "GQE","GQE_VIACOD","GQK_CODVIA")

    cWhere := "    GYN_DTINI = '" + oWS:fromDateTrip + "' " + chr(13)
    cWhere += "    AND GYN_DTFIM = '" + oWS:toDateTrip + "' " + chr(13)
    cWhere += "    AND GYN_HRINI = '" + oWS:fromTimeTrip + "' " + chr(13)
    cWhere += "    AND GYN_HRFIM = '" + oWS:toTimeTrip + "' " + chr(13)
    cWhere += "    AND GYN_LOCORI = '" + oWS:fromLocal + "' " + chr(13)
    cWhere += "    AND GYN_LOCDES = '" + oWS:toLocal + "' " + chr(13)
    cWhere += "    AND GYN.D_E_L_E_T_ = ' ' " + chr(13)
    cWhere += "    AND EXISTS ( " + chr(13)
    cWhere += "        SELECT  " + chr(13)
    cWhere += "            1 " + chr(13)
    cWhere += "        FROM  " + chr(13)
    cWhere += "            " + RetSQLName(cAlias) + " A " + chr(13)
    cWhere += "        INNER JOIN " + chr(13)
    cWhere += "            " + RetSQLName("GYG") + " GYG " + chr(13)
    cWhere += "        ON " + chr(13)
    cWhere += "            GYG.D_E_L_E_T_ = ' ' " + chr(13)
    cWhere += "            AND GYG_CODIGO = A."+cAlias+"_RECURS " + chr(13)
    cWhere += "            AND GYG_CPF = '" + oWS:documentDriver + "' " + chr(13)
    cWhere += "        WHERE " + chr(13)
    cWhere += "            A.D_E_L_E_T_ = ' ' " + chr(13)
    cWhere += "            AND A." + cField + " = GYN.GYN_CODIGO " + chr(13)
    cWhere += "            AND A."+cAlias+"_TRECUR = '1' " + chr(13)
    
    If ( cAlias == "GQE" )
        cWhere += "            AND A.GQE_CANCEL = '1' " + chr(13)
    EndIf
    
    cWhere += "    ) " + chr(13)

Return(cWhere)
