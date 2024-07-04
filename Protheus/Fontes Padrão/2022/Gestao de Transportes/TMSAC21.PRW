#include 'Totvs.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAC21Prc
Processa retorno JSON
@author Caio Murakami
@since  01/09/2021
@version P12.1.35
@type function
/*/
//------------------------------------------------------------------
Function TMSAC21Prc( cIdRot , cRetTPR )
Local aArea         := GetArea() 
Local aSequen       := {} 
Local aGeoLoc       := {}
Local oResult       := JsonObject():New() 
Local aRejeitados   := {}
Local lRet          := .F.

Default cIdRot      := "" 
Default cRetTPR     := Nil

TmsLogMsg("INFO","Inicio Processamento CallBack")   

Begin Transaction
    If GrvJson( cIdRot , cRetTPR )
        If FWJsonDeserialize(cRetTPR,@oResult)
            lRet:= .T.
            If AttIsMemberOf(oResult,"rejections") .And. ValType( oResult:rejections) == "A"
                aRejeitados := GetRejeitados ( aClone(oResult:rejections)  ) 
                If Len(aRejeitados) > 0
                    TmsLogMsg("INFO","Validando Doctos Rejeitados")   
                    //--- Verifica se existe NF rejeitadas para separação do lote
                    FwMsgRun( , { || lRet:= T146RejTPR(cIdRot,aRejeitados) }  , 'Processando' , 'Verificando Documentos Rejeitados '  ) 

                    If lRet
                        TmsLogMsg("INFO","Valição OK - Doctos Rejeitados")   
                    Else
                        TmsLogMsg("WARN","Falha na Valição - Doctos Rejeitados")  
                    EndIf
                EndIf
            EndIf

            If lRet
                If AttIsMemberOf(oResult,"tripsresults") .And. ValType( oResult:tripsresults ) == "A"
                    aSequen     := GetSeqDoc( aClone( oResult:tripsresults ) ) 
                    If Len(aSequen ) > 0
                        TmsLogMsg("INFO","Processando dados do Trip Results para geração da Programação de Carregamento") 
                        //--- Gera Programação de Carregamento
                        FwMsgRun( , { || lRet:= T146PrcTPR(cIdRot,aSequen)}  , 'Processando' , 'Gerando Programação de Carregamento'  )                     
                    EndIf
                ElseIf AttIsMemberOf(oResult,"geolocationResults") .And. ValType( oResult:geolocationResults ) == "A"
                        TmsLogMsg("INFO","Processando dados do Geolocation Results para geração da Referência Geográfica") 
                        //--- Gera a ref. geográfica
                        aGeoloc := aClone( oResult:geolocationResults )
                        FwMsgRun( , { || lRet:= T15PrcGeo(cIdRot,aGeoloc)}  , 'Processando' , 'Gerando Referência Geográfica'  )                     
                EndIf 
            EndIf

            If !lRet
                DisarmTransaction()
                Break
            Else
                //--- Atualiza Status da Roteirização (DMR)
                T146AtuDMR(cIdRot,'2')  //1-Pendente, 2-Processado
            EndIf
            
        EndIf 
    Else
        TmsLogMsg("WARN","Falha na gravação do Retorno CallBack  TPR ") 
    EndIf
End Transaction

FwFreeArray(aRejeitados)
FwFreeArray(aSequen)
FwFreeArray(aGeoLoc)
RestArea( aArea )
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetSeqDoc
Processa retorno JSON
@author Caio Murakami
@since  01/09/2021
@version P12.1.35
@type function
/*/
//------------------------------------------------------------------
Static Function GetSeqDoc( aTrip )
Local aRet      := {} 
Local nCount    := 1 
Local nStop     := 1 
Local aStop     := {} 
Local aOrders   := {} 
Local nOrders   := 1 
Local aDataUTC  := {}
Local dDtIniTPR := cTod('')
Local cHrIniTPR := ""
Local dDtFimTPR := cTod('')
Local cHrFimTPR := ""

Default aTrip   := {} 

For nCount := 1 To Len(aTrip)
    If AttIsMemberOf( aTrip[nCount] , "sequential") 
        If AttIsMemberOf( aTrip[nCount] , "stops") .And. ValType( aTrip[nCount]:stops ) == "A"
            aStop   := AClone( aTrip[nCount]:stops )       

            //--------- Busca a Data/Hora da Roteirização
            If Len(aStop) > 0 
                //--- Data/Hora Inicio 
                If AttIsMemberOf( aStop[1] , "arrivaltime")   //departureTime??
                    aDataUTC:= T21UTCData(aStop[1]:arrivaltime)
                    If Len(aDataUTC) > 0
                        dDtIniTPR:= aDataUTC[1]
                        cHrIniTPR:= aDataUTC[2]
                    EndIf
                EndIf

                //--- Data/Hora Fim
                If AttIsMemberOf( aStop[Len(aStop)] , "arrivaltime")
                    aDataUTC:= T21UTCData(aStop[Len(aStop)]:arrivaltime)
                    If Len(aDataUTC) > 0
                        dDtFimTPR:= aDataUTC[1]
                        cHrFimTPR:= aDataUTC[2]
                    EndIf
                EndIf
            EndIf

            Aadd( aRet , {} )
            Aadd( aRet[Len(aRet)] , { "SEQUENTIAL" , ;
                                      aTrip[nCount]:sequential, ;
                                      aTrip[nCount]:vehicle, ;
                                      dDtIniTPR, ;
                                      cHrIniTPR, ;
                                      dDtFimTPR, ;
                                      cHrFimTPR} )            

            For nStop := 1 To Len( aStop )
                If AttIsMemberOf( aStop[nStop] , "unloadedorders") .And. ValType(aStop[nStop]:unloadedorders) == "A"
                    aOrders := AClone( aStop[nStop]:unloadedorders ) 

                    For nOrders := 1 To Len(aOrders)
                        If AttIsMemberOf( aOrders[nOrders] , "identifier" ) 
                            Aadd( aRet[Len(aRet)] , aOrders[nOrders]:identifier ) 
                            //Aadd( aRet[Len(aRet)] , aClone( StrTokArr(aOrders[nOrders]:identifier,"|" ) ) )
                        EndIf   
                    Next nOrders 

                EndIf
            Next nStop 

        EndIf 
    EndIf

Next nCount 

FwFreeArray(aDataUTC)
Return aRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} GetRejeitados
Processa retorno JSON
@author Caio Murakami
@since  06/09/2021
@version P12.1.35
@type function
/*/
//------------------------------------------------------------------
Static Function GetRejeitados(aRejections)
Local aRet        := {} 
Local nCount      := 1 
Local nRej        := 1
Local aMessageRej := {}
Local cMessage    := ""

Default aRejections := {}

For nCount := 1 To Len(aRejections)

    If AttIsMemberOf( aRejections[nCount] , "order") .And. ValType( aRejections[nCount]:order ) == "O"
        Aadd( aRet , {} )
        Aadd( aRet[Len(aRet)] , aRejections[nCount]:order:identifier )

        cMessage:= ""    
        If AttIsMemberOf( aRejections[nCount] , "messages") .And. ValType( aRejections[nCount]:messages ) == "A"
            aMessageRej   := AClone( aRejections[nCount]:messages )

            For nRej := 1 To Len(aMessageRej)
                If AttIsMemberOf( aMessageRej[nRej] , "messagecode" ) .And. AttIsMemberOf( aMessageRej[nRej] , "message" ) 
                    cMessage += aMessageRej[nRej]:messagecode + " - " + aMessageRej[nRej]:message +  Chr(13) + Chr(10)
                EndIf 
            Next nRej 
        EndIf

        Aadd( aRet[Len(aRet)] , cMessage )
    EndIf

Next nCount 

FwFreeArray(aRejections)
FwFreeArray(aMessageRej)
Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvJson
Processa retorno JSON
@author Caio Murakami
@since  06/09/2021
@version P12.1.35
@type function
/*/
//------------------------------------------------------------------
Static Function GrvJson( cIdRot , cJsonRet )
Local aArea     := GetArea() 
Local cQuery    := "" 
Local cAliasQry := GetNextAlias() 
Local oTpr      := Nil 
Local lRet      := .F. 

Default cIdRot      := "" 
Default cJsonRet    := "" 

DMR->(DbSetOrder(1))  
If DMR->(DbSeek(xFilial("DMR")+cIdRot)) .And. DMR->DMR_STATUS == '1' //1-Pendente, 2-Processado
    cQuery  := " SELECT * FROM "
    cQuery  += RetSqlName("DLU") + "  DLU "
    cQuery  += " WHERE DLU_FILIAL  = '" + xFilial("DLU") + "' "
    cQuery  += " AND DLU_ENTIDA = 'DMR' "
    cQuery  += " AND DLU_FILENT = '" + xFilial("DMR") + "' "
    cQuery  += " AND DLU_CHVENT = '" + cIdRot + "' "
    cQuery  += " AND DLU.D_E_L_E_T_ = '' " 
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasQry, .T., .T.)

    While (cAliasQry)->(!Eof())
        oTpr    := TMSBCATPRNeolog():New()
        If AllTrim((cAliasQry)->DLU_API) $ 'Geoloc'
            oTpr:UpdateDLU( (cAliasQry)->DLU_FILENT , (cAliasQry)->DLU_ENTIDA , (cAliasQry)->DLU_CHVENT , "Geoloc", cIdRot, "TMSAO15", cJsonRet )
        Else 
            oTpr:UpdateDLU( (cAliasQry)->DLU_FILENT , (cAliasQry)->DLU_ENTIDA , (cAliasQry)->DLU_CHVENT , "Routing", cIdRot, "TMSA146", cJsonRet )
        EndIf 
        lRet    := .T. 
        (cAliasQry)->(DBSkip())
    EndDo 

    (cAliasQry)->(DBCloseArea())
EndIf

RestArea( aArea )
Return lRet  

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS21VlPdg
Retorna o Valor do Pedágio da TPR
@author Katia
@since  23/09/2021
@version P12.1.35
@type function
/*/
//------------------------------------------------------------------
Function TMS21VlPdg(cChvEnt)
Local nRet  := 0
Local aRet  := {}
Local nPos  := 0
Local nTam  := TamSX3("DTR_VALPDG")[2]
Local cJson := ""

cJson:= TMS21RetJs(cChvEnt)

aRet := TMS21GetJs(cJson)

If Len(aRet) > 0
    nPos:= aScan(aRet,{|x| AllTrim(Upper(x[1])) == 'TRIPSRESULTS' }) 
    If nPos > 0
        If aRet[1][2][nPos]:HasProperty('tollValue')  
            nRet:= Round(aRet[1][2][nPos]:GetJsonObject('tollValue'), nTam)
        EndIf           
    EndIf
EndIf

FwFreeArray(aRet)
Return nRet

/*/-----------------------------------------------------------
{Protheus.doc} TMS21RetJs()

Uso: TMSAC25/TMSAC21

@sample
//ViewDef()

@author Caio Murakami   
@since 01/07/2019
@version 1.0
@type function
-----------------------------------------------------------/*/
Function TMS21RetJs( cChvEnt )
Local cQuery		:= "" 
Local cAliasQry		:= GetNextAlias()
Local cJson			:= "" 

Default cChvEnt		:= "" 

cQuery	:= " SELECT R_E_C_N_O_ DLURECNO "
cQuery	+= " FROM " + RetSQLName("DLU") +" DLU "
cQuery	+= " WHERE DLU_FILIAL	=	'" + xFilial("DLU") + "' "
cQuery	+= " AND DLU_ENTIDA		= 'DMR' "
cQuery	+= " AND DLU_CHVENT		= '" + cChvEnt + "' "
cQuery	+= " AND DLU.D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)

While (cAliasQry)->(!Eof())
	DLU->(DBGoTo(( cAliasQry)->DLURECNO ))
	cJson	:= RTrim( DLU->DLU_RETORN )
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DBCloseArea())

Return cJson

//-------------------------------------------------------------------
/*/{Protheus.doc} TMS21GetJs
Retorna dados do retorno do Json em array
@author Katia
@since  23/09/2021
@version P12.1.35
@type function
/*/
//------------------------------------------------------------------
Function TMS21GetJs(cJson)
Local oJson      := Nil
Local aNames     := {}
Local aRet       := {}
Local nCount     := 1

Default cJson    := ""
If !Empty(cJson)
    oJson   := JsonObject():New()
    oJson:FromJson(cJson)
    aNames  := oJson:GetNames()
                        
    For nCount := 1 To Len(aNames)
        Aadd( aRet , { aNames[nCount] ,  oJson[aNames[nCount]]   })
    Next nCount
EndIf

FwFreeArray(aNames)
Return aRet


/*/{Protheus.doc} T21UTCData
Transforma uma data e hora universal para o formato local.
@author Totvs 
@since  14/10/2021
@version P12.1.35
@type function
/*/
Static Function T21UTCData( cUTC )
	Local dData        := CTOD("//")
	Local cHora        := ""
    //Local cUTCToLocal  := "UTCToLocal"

	//aLocal := &cUTCToLocal.( StrTran(SubStr(cUTC,1,10),"-",""),SubStr(cUTC,12,8) )
    //dData := SToD( aLocal[1])
    //cHora := SToD( aLocal[2])

    dData := StrTran(SubStr(cUTC,1,10),"-","")
    cHora := StrTran(SubStr(cUTC,12,5),":","")
	
Return { StoD(dData), cHora }
  


/*/{Protheus.doc} T21PrcCan
Exclui Roteirização conforme Tempo de Expiração
@author Totvs 
@since  14/10/2021
@version P12.1.35
@type function
/*/
Function T21PrcCan(cTmpExp)
Local aArea    := GetArea()
Local cQuery   := ""
Local cAliasDLU:= ""
Local lRet     := .F.
Local cRotina  := Padr('TMSA146',TamSX3('DLU_ROTINA')[1] )   
Local dDtEnvio := ""
Local cHrEnvio := ""
Local cHrBase  := ""
Local cTotHora := ""

Default cTmpExp:= TMSAC21Tmp()

If !Empty(cTmpExp)   
    //--- Data/Hora do Sistema
    cHrBase  := SubStr(Time(),1,2) + SubStr(Time(),4,2) 

    //--------------------------
    cAliasDLU:= GetNextAlias()
    cQuery := " SELECT DLU_FILENT, DLU_ENTIDA, DLU_CHVENT, DLU_DATENV, DLU_HORENV, "
    cQuery += " DLU.R_E_C_N_O_ DLURECNO, DMR.R_E_C_N_O_ DMRRECNO "
    cQuery += " FROM " + RetSqlName('DLU') + " DLU "   

    cQuery += " INNER JOIN " + RetSqlName('DMR') + " DMR "   
    cQuery += " ON DMR.DMR_FILIAL = '"+ xFilial("DMR") +"' "
    cQuery += " AND DMR.DMR_STATUS = '1' "
    cQuery += " AND DMR.D_E_L_E_T_ = ' ' "
    
    cQuery += " WHERE DLU.DLU_FILIAL = '"+ xFilial("DLU") +"' "
    cQuery += " AND DLU.DLU_FILENT = '"+ xFilial("DMR") +"' "
    cQuery += " AND DLU.DLU_ENTIDA = 'DMR' "
    cQuery += " AND DLU.DLU_MODULO = 'TMS' "
    cQuery += " AND DLU.DLU_ROTINA = '" + cRotina + "' "
    cQuery += " AND DLU.DLU_CHVENT = DMR.DMR_FILROT + DMR.DMR_IDROT "
    cQuery += " AND DLU.D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDLU,.F.,.T.)
    While  (cAliasDLU)->( !Eof() ) 
        lExcDLU   := .F.
        dDtEnvio  := StoD((cAliasDLU)->DLU_DATENV)
        cHrEnvio  := (cAliasDLU)->DLU_HORENV

        If !Empty(dDtEnvio) .And. !Empty(dDataBase) .And. !Empty(cHrEnvio) .And. !Empty(cHrBase)                    
            cTotHora:= TmsTotHora(dDtEnvio,cHrEnvio,dDataBase,cHrBase)

            If !Empty(cTotHora)
                If Val(cTotHora) > Val(cTmpExp)
                   lExcDLU:= .T.
                EndIf
            EndIf

        EndIf
                 
        //----- Exclui Roteirização
        If lExcDLU
            DMR->(dbGoTo( (cAliasDLU)->(DMRRECNO) ))                       
            Begin Transaction
                lRet:= T21DelRot()    
                If lRet
                    DLU->(dbGoTo( (cAliasDLU)->(DLURECNO) ))                       
                    RecLock("DLU",.F.)
                    DbDelete()
                    DLU->(MsUnlock())
                Else
                    DisarmTransaction()
                    Break
                EndIf
            End Transaction
        EndIf
        
        (cAliasDLU)->(DbSkip())  
    EndDo
    (cAliasDLU)->(DbCloseArea())
EndIf

RestArea(aArea)
Return lRet


/*/{Protheus.doc} TMSAC21Tmp
Retorna o tempo de Expedição para limpeza dos registros DMR/DMS
@author Katia
@since  19/10/2021
@version P12.1.35
@type function
/*/
Function TMSAC21Tmp()
Local cQuery   := ""
Local cAliasQry:= GetNextAlias()
Local cRet     := ""

    cQuery := " SELECT DLV_TMPEXP FROM "
    cQuery += RetSqlName("DLV") + "  DLV "
    cQuery += "   WHERE DLV_FILIAL = '" + xFilial("DLV") + "' "
    cQuery += "   AND DLV_ROTERI = '2' "
    cQuery += "   AND DLV_MSBLQL = '2'
    cQuery += "   AND D_E_L_E_T_ = ' ' "
    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasQry, .T., .T.)
    If (cAliasQry)->( !Eof() )
        cRet:= (cAliasQry)->DLV_TMPEXP
    EndIf

    (cAliasQry)->(dbCloseArea())

Return cRet

/*/{Protheus.doc} T21DelRot
Exclui a Roteirização
@author Katia
@since  19/10/2021
@version P12.1.35
@type function
/*/
Static Function T21DelRot()
Local oModel   := Nil
Local aArea    := GetArea()
Local lRet     := .F.

    oModel := FWLoadModel( 'TMSAC19' )
    oModel:SetOperation( 5 )
    oModel:Activate()

    lRet := oModel:VldData()
    If lRet 
        oModel:CommitData()
    Else
        Help(,,'HELP',, oModel:GetErrorMessage()[6],1,0) 
    EndIf
    oModel:Destroy()
    oModel:= Nil	

RestArea(aArea)
FwFreeArray(aArea)
Return lRet
            
