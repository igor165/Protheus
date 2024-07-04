#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} PORTALPRESTADOR

Serviços utilizados pelo aplicativo Portal do Prestador

@author     Diego Bezerra
@since      19/02/2020
/*/
//------------------------------------------------------------------------------
WSRESTFUL PORTALPRESTADOR  DESCRIPTION "Portal do Prestador"

    WSDATA cStart 		AS STRING
    WSDATA cEnd 		AS STRING
    WSDATA nSituation	AS INTEGER
    WSDATA cMinutes 	AS STRING
    WSDATA cStation 	AS STRING    
    WSDATA cSupervisor 	AS STRING
    WSDATA cDescAbn     AS STRING
    WSDATA aRegiao 	AS ARRAY
    WSDATA nPage 		AS NUMBER
    WSDATA nPageSize 	AS NUMBER
    WSDATA cContrt      AS STRING
    WSDATA cClient      AS STRING
    WSDATA cLoja        AS STRING
    WSDATA dDataDe      AS STRING
    WSDATA dDataAte     AS STRING
    WSDATA cLocal       AS STRING     
    WSDATA cProdut      AS STRING
    WSDATA cPosto       AS STRING   

    WSMETHOD GET appointments	      DESCRIPTION 'Appointments'            PATH "appointments"	        PRODUCES APPLICATION_JSON 
    WSMETHOD GET stations	      DESCRIPTION 'Work stations'	        PATH "stations"		        PRODUCES APPLICATION_JSON 
    WSMETHOD GET supervisors	      DESCRIPTION 'Get supervisor'	        PATH "supervisors"	        PRODUCES APPLICATION_JSON
    WSMETHOD GET descriManut        DESCRIPTION 'Get descriManut'         PATH "descriManut"            PRODUCES APPLICATION_JSON
    WSMETHOD GET manut              DESCRIPTION 'Get Manut'               PATH "manut"                  PRODUCES APPLICATION_JSON
    WSMETHOD GET fstations          DESCRIPTION 'Get the lookup data'     PATH "filters/stations"       PRODUCES APPLICATION_JSON
    WSMETHOD GET clients            DESCRIPTION 'Get clients'             PATH "filters/clients"        PRODUCES APPLICATION_JSON 
    WSMETHOD GET fcostations        DESCRIPTION 'Get clients'             PATH "fcolstation"            PRODUCES APPLICATION_JSON // done
    WSMETHOD GET linechartdata      DESCRIPTION 'Get linechartDate'       PATH "linechart"              PRODUCES APPLICATION_JSON
    WSMETHOD GET RhIten             DESCRIPTION 'Get RhIten'              PATH "filters/rhiten"         PRODUCES APPLICATION_JSON 
    WSMETHOD GET AtendimentSta      DESCRIPTION 'Get AtendimentSta'       PATH "filters/atendimentsta"  PRODUCES APPLICATION_JSON
    WSMETHOD GET Contrat            DESCRIPTION 'Get Contrat'             PATH "filters/contrat"        PRODUCES APPLICATION_JSON
    WSMETHOD GET AttendantsUsed     DESCRIPTION 'Get AttendUsed'          PATH "attendantsused"         PRODUCES APPLICATION_JSON
    WSMETHOD GET AttOciosos         DESCRIPTION 'Iddle Att'               PATH 'ociosos'                PRODUCES APPLICATION_JSON
    WSMETHOD GET gtctrtatv          DESCRIPTION 'Active Contracts'        PATH 'ctrtatv'                PRODUCES APPLICATION_JSON

END WSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc} clients

@description Retorna os apontamentos (agendas) do atendente para o dia atual
@author   Diego Bezerra
@since    19/02/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET clients WSRECEIVE page, pageSize  WSREST PORTALPRESTADOR

Local cTemp             := GetNextAlias()
Local cResponse         := '{ "appointments":[], "count": 0 }'   

Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local lRet              := .T.
Local nRecord           := 0

If lRet 

      BeginSQL Alias cTemp
      
            SELECT A1_COD, A1_NOME

            FROM %Table:SA1% SA1      
                  
            WHERE 
                  SA1.A1_FILIAL  = %Exp:xFilial("SA1")%               
                  AND SA1.%NotDel%   
            EndSql

            ( cTemp )->( DBGoTop() )                 

            cResponse := ''
            cResponse := '{"items":['   

            While ( cTemp )->( !Eof() )
                  nRecord++
                  cResponse += '{"value":"' + AllTrim( (cTemp)->A1_COD ) + '",'
                  cResponse += '"desc":"' + AllTrim( (cTemp)->A1_NOME ) + '"},'
                  ( cTemp )->( DBSkip() )   
            EndDo
            (cTemp)->(dbCloseArea())

            cResponse = Left(cResponse, Len(cResponse)-1 )
            cResponse += '], '
            cResponse += '"count": ' +cBIStr( nRecord ) + ' } '

      Self:SetResponse( EncodeUTF8(cResponse) )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} PORTALPRESTADOR

@description Retorna os apontamentos (agendas) do atendente para o dia atual
@author   Diego Bezerra
@since    19/02/2020
/*/
//------------------------------------------------------------------------------

WSMETHOD GET appointments WSRECEIVE nPage, nPageSize, cStation, cStart, cEnd, cMinutes  WSREST PORTALPRESTADOR
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "appointments":[], "count": 0 }'   

Local cMessage          := "Internal Server Error"
Local cTime             := Time()
Local nStatusCode       := 500

Local nRecord           := 0
Local lRet              := .T.
Local cLate             := "2"
Local cExpHr            := "%0 = 0%"
Local cObsMan           := ""
Local cAlert            := ""
Local cStatus           := ""
Local cLegend           := ""
Local cData             := ""
Local nDiffIn           := 0
Local lOk               := .T.
Local lHasNext          := .F.
Local nDiffOut          := 0
Local nQtdRegIni        := 0
Local nQtdRegFim        := 0
Local nMin              := Self:cMinutes
Local nMinutes          := 0
Local nHour             := 0
Local cQry              := ""
Local cAliasABR         := ""

If ValType(Self:nPage) == "C"
      Self:nPage := Val(Self:nPage)
EndIf

If ValType(Self:nPageSize) == "C"
      Self:nPageSize := Val(Self:nPageSize)
EndIf

// Define o tipo de retorno do mótodo    
Self:SetContentType("application/json")

If Empty(Self:cStation) 
      lRet := .F.
      cMessage := "Informe o local de atendimento"
EndIf 

If lRet    

      If Self:nPage == 0
            Self:nPage := 1
      EndIf
      
      If Self:nPageSize == 0
            Self:nPageSize := 1
      EndIf 

      nQtdRegIni := ((Self:nPage-1) * Self:nPageSize)
      nQtdRegFim := (Self:nPage * Self:nPageSize)
      nQtdReg    := 0
     
      If !Empty(Self:cStart) .And. !Empty(Self:cEnd)  
            cExpHr:= "% (ABB_HRINI >= '" + Self:cStart + "' AND ABB_HRFIM <= '" +  Self:cEnd + "') %"
      ElseIf !Empty(Self:cStart)
            cExpHr:= "% ABB_HRINI >= '" + Self:cStart + "' %"
      ElseIf !Empty(Self:cEnd)     
            cExpHr := "% ABB_HRFIM <= '" +  Self:cEnd + "' %"
      EndIf

      BeginSQL Alias cTemp
      COLUMN TDV_DTREF AS DATE
      COLUMN ABB_DTINI AS DATE
      SELECT ABB_CODIGO, ABB_LOCAL, AA1.AA1_NOMTEC,  ABB.ABB_DTINI, ABB.ABB_CHEGOU, ABB.ABB_SAIU, ABB.ABB_MANIN, ABB.ABB_MANOUT, TDV.TDV_DTREF, ABB.ABB_ATENDE, ABB.ABB_MANUT,
            CASE WHEN ABB.ABB_HRCHIN = '' OR ABB.ABB_HRCHIN IS NULL THEN ABB.ABB_HRINI ELSE ABB.ABB_HRCHIN END ABB_HRINI,
            CASE WHEN ABB.ABB_HRCOUT = '' OR ABB.ABB_HRCOUT IS NULL THEN ABB.ABB_HRFIM ELSE ABB.ABB_HRCOUT END ABB_HRFIM 
      FROM %Table:ABB% ABB      
            INNER JOIN %Table:AA1% AA1 ON AA1.AA1_FILIAL = %Exp:xFilial("AA1")% AND AA1.%NotDel% AND AA1.AA1_CODTEC = ABB.ABB_CODTEC   
            INNER JOIN %Table:TDV% TDV ON TDV.TDV_CODABB = ABB.ABB_CODIGO
      WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%               
            AND TDV.TDV_FILIAL = %Exp:xFilial("TDV")%
            AND ABB.ABB_LOCAL  = %Exp:Self:cStation%
            AND %exp:cExpHr%
            AND ABB_ATIVO = '1'                        
            AND TDV.TDV_DTREF = %Exp:dDataBase%
            AND ABB.%NotDel%   
            AND TDV.%NotDel%                            
      EndSql

      If ( cTemp )->( !Eof() )

            If !Empty(nMin)
                  nMinutes := Val(nMin)
                  If nMinutes > 60
                        While nMinutes > 60
                              nHour := nHour + 1
                              nMinutes := nMinutes - 60          
                        EndDo
                        nMin := Alltrim(Str(nHour)) + ":" + Alltrim(Str(nMinutes))
                  Else
                        nMin := Alltrim(Str(nMinutes / 100))                                                                   
                  EndIf 
                  nMin := TecConvHr( nMin )
            EndIf

//-------------------------------------------------------------------
// Identifica a quantidade de registro no alias temporário.    
//-------------------------------------------------------------------
/*count TO nRecord*/

//-------------------------------------------------------------------
// Posiciona no primeiro registro.  
//-------------------------------------------------------------------  
            ( cTemp )->( DBGoTop() )                 

            cResponse := ''
            cResponse := '{"appointments":['   

            While ( cTemp )->( !Eof() )
                  
                  nQtdReg++
                  cLate := "2"
                  cAlert := "2"
                  cObsMan := ""
                  lOk := .T.                                                                                                            
                  If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim) 
                        If lOk 
                              
                              nRecord++
                              
                              If nRecord > 1
                                    cResponse += ','
                              EndIf 
                              If ( cTemp )->ABB_ATENDE == "1" .OR. (( cTemp )->ABB_CHEGOU == "S" .OR. ( cTemp )->ABB_SAIU == "S")
                                    cStatus := '4'
                                    cLegend := "MARC. REALIZADA"
                              ElseIf ( cTime > ( cTemp )->ABB_HRINI .AND. ( cTemp )->TDV_DTREF  == ( cTemp )->ABB_DTINI)
                                    If ( cTemp )->ABB_CHEGOU <> "S" .AND. ( cTemp )->ABB_ATENDE <> "1"
                                          cLate := "1"
                                          cStatus := '2' 
                                          cLegend := "ATRASADO" 
                                    EndIf
                              ElseIf cTime <= ( cTemp )->ABB_HRINI
                                    If !Empty(nMin)
                                          nDiffIn := SubHoras( ( cTemp )->ABB_HRINI, cTime)
                                          If nDiffIn <= nMin
                                                cAlert := '1'
                                                cStatus := '1'
                                                cLegend := "MARC. PENDENTE"
                                          Else
                                                cStatus := '3'
                                                cLegend := "AGENDA FUTURA"   
                                          EndIf
                                    Else
                                          cStatus := '3'
                                          cLegend := "AGENDA FUTURA"
                                    EndIf
                              ElseIf ( cTemp )->ABB_DTINI <> ( cTemp )->TDV_DTREF .AND. (!Empty(Self:cStart) .OR. !Empty(Self:cEnd))
                                    cStatus := '5'
                                    cLegend := "Virada de Dia"
                              Else
                                    cStatus := '3'
                                    cLegend := "AGENDA FUTURA"
                              EndIf

                     
                              cData := Left(DToC(( cTemp )->ABB_DTINI), 6) + cValtoChar(Year(( cTemp )->ABB_DTINI))
                              cResponse += '{"code":"' + Alltrim(( cTemp )->ABB_CODIGO) + '",' 
                              cResponse += '"attendant":"' + Alltrim(( cTemp )->AA1_NOMTEC) + '",'
                              cResponse += '"status": "' + cStatus + '",' 
                              cResponse += '"ABBDTINI":"' + cData + '",'
                              cResponse += '"HoraIni":"' + Alltrim(( cTemp )->ABB_HRINI) + '",'                       
                              cResponse += '"HoraFim":"' + Alltrim(( cTemp )->ABB_HRFIM) + '",'
                              cResponse += '"Legend":"' + AllTrim(cLegend) + '",'
                             

                              If (cTemp)->ABB_MANUT <> '2'
                                    cResponse += '"desc":"' + ( cTemp )->ABB_CHEGOU + '",'
                                    
                                    cQry += " SELECT ABR_DTINIA, ABR_HRINIA, ABR_DTFIMA, ABR_HRFIMA,  ABN_DESC "
                                    cQry += " FROM " + retSqlName('ABR') + " ABR "
                                    cQry += " INNER JOIN " + retSqlName('ABN') + " ABN ON ABN.ABN_CODIGO = ABR.ABR_MOTIVO "
                                    cQry += " AND ABN.ABN_FILIAL = '" + xFilial('ABN') + "'  AND ABN.D_E_L_E_T_ = ' ' "
                                    cQry += " WHERE  ABR_AGENDA = '" + (cTemp)->ABB_CODIGO + "' "
                                    cQry += " AND ABR.ABR_FILIAL = '" + xFilial('ABR') + "' "
                                    cQry += " AND ABR.D_E_L_E_T_ = ' ' "
                                    cQry := ChangeQuery(cQry)

                                    cAliasABR := GetNextAlias()
                                    dbUseArea( .T. , "TOPCONN", TCGENQRY( , , cQry), cAliasABR, .F., .T.)
                                    If (cAliasABR)->(!EOF())
                                          cResponse += '"detail": ['
                                          While (cAliasABR)->(!Eof())
                                                
                                                cResponse += '{"dtini":"' + (cAliasABR)->ABR_DTINIA + '",'
                                                cResponse += '"hrini":"' + (cAliasABR)->ABR_HRINIA + '",'
                                                cResponse += '"dtfim":"' + (cAliasABR)->ABR_DTFIMA + '",'
                                                cResponse += '"hrfim":"' + (cAliasABR)->ABR_HRFIMA + '",'
                                                cResponse += '"descmanu":"' + (cAliasABR)->ABN_DESC + '"},'
                                          
                                          (cAliasABR)->(DbSkip())
                                          EndDo
                                          (cAliasABR)->(dbCloseArea())
                                          cResponse = Left(cResponse, Len(cResponse)-1 )
                                          cResponse += ']}'
                                    EndIf
                              Else
                                    cResponse += '"desc":"' + ( cTemp )->ABB_CHEGOU + '"}'
                              EndIf

                        EndIf                              
                  ElseIf (nQtdReg == nQtdRegFim + 1)
                        lHasNext := .T.
                        Exit
                  EndIf
                  ( cTemp )->( DBSkip() )      
            EndDo
      EndIf
      (cTemp)->(dbCloseArea())
      If nQtdReg > nQtdRegFim
            cResponse += '], "hasNext": "true" }'
      else
            cResponse += '], "hasNext": "false" }'
      EndIf
         

      Self:SetResponse( EncodeUTF8(cResponse) )

Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf

Return( lRet ) 

//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PORTALPRESTADOR

@description Realiza a query e aplica a regra de acordo com os filtros, para retorna o(s) local(is) de atendimento(s).
@author Augusto Albuquerque
@since  21/02/2020
/*/
//-------------------------------------------------------------------------------------------------------------------- 
WSMETHOD GET stations WSRECEIVE nSituation, cStart, cEnd, cMinutes, cSupervisor, aRegiao  WSREST PORTALPRESTADOR
Local aLocais     := {}
Local cResponse   := '{ "stations":[], "count": 0 }' 
Local cQuery      := ""
Local cAliasABS   := GetNextAlias()
Local cType       := "2"
Local cAux        := "" 
Local cLocal      := ""
Local cABBIni     := ""
Local cTime       := Time()
Local cDescri     := ""
Local lRet        := .T.
Local lPrimeira   := .T.
Local lOK         := .T.
Local lFutura     := .F.
Local lUltimo     := .F.
Local lAlerta     := .F.
Local lContinua   := .T.
Local lPin        := .T.
Local nMin        := Self:cMinutes
Local nSitua      := 3
Local nHour       := 0
Local nMinutes    := 0
Local nCount      := 0

Self:SetContentType("application/json")

If !Empty(nMin)
      nMinutes := Val(nMin)
      If nMinutes > 60
            While nMinutes > 60
                  nHour := nHour + 1
                  nMinutes := nMinutes - 60          
            EndDo
            nMin := Alltrim(Str(nHour)) + ":" + Alltrim(Str(nMinutes))
      Else
            nMin := Alltrim(Str(nMinutes / 100))                                                                   
      EndIf 
      nMin := TecConvHr( nMin )
EndIf

If !Empty(Self:nSituation)
      nSitua := Self:nSituation
EndIf
If !Empty(Self:aRegiao)
      Self:aRegiao := "'" + Self:aRegiao
      If AT(",",Self:aRegiao) > 0
            Self:aRegiao := STRTRAN(Self:aRegiao, ",","','")
      EndIf
      Self:aRegiao += "'"
EndIf
cQuery := " SELECT ABS.ABS_LOCAL, ABS.ABS_DESCRI, ABS.ABS_LATITU, ABS.ABS_LONGIT, ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_CHEGOU, ABB.ABB_SAIU, TDV.TDV_DTREF, ABB.ABB_DTINI, ABB.ABB_ATENDE "
If !Empty(Self:cSupervisor)
      cQuery += ", CASE WHEN TXI.TXI_DTINI = '' OR TXI.TXI_DTINI IS NULL THEN '"+ DToS(dDataBase) +"' ELSE TXI.TXI_DTINI END TXI_DTINI, "
      cQuery += " CASE WHEN TXI.TXI_DTFIM = '' OR TXI.TXI_DTFIM IS NULL THEN '"+ DToS(dDataBase) +"' ELSE TXI.TXI_DTFIM END TXI_DTFIM "
EndIf
cQuery += " FROM " + RetSqlName( "ABS" ) + " ABS "
If !Empty(Self:cSupervisor)
      cQuery += " INNER JOIN "  + RetSqlName( "TXI" ) + " TXI "
      cQuery += " ON TXI.TXI_FILIAL = '" + xFilial("TXI") + "' "
      cQuery += " AND TXI.TXI_LOCAL = ABS.ABS_LOCAL "
EndIf
cQuery += " INNER JOIN " + RetSqlName( "ABB" ) + " ABB "
cQuery += " ON ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
cQuery += " AND ABB.ABB_LOCAL = ABS.ABS_LOCAL "
cQuery += " INNER JOIN " + RetSqlName( "TDV" ) + " TDV "
cQuery += " ON TDV.TDV_FILIAL  = '" + xFilial("TDV") + "' AND TDV.TDV_CODABB = ABB.ABB_CODIGO "
cQuery += " WHERE ABS.ABS_FILIAL  = '" + xFilial("ABS") + "' "
cQuery += " AND ABS.ABS_LATITU <> '' AND ABS.ABS_LONGIT  <> '' "
If !Empty(Self:aRegiao)
      cQuery += " AND ABS.ABS_REGIAO IN (" + Self:aRegiao + ") "
EndIf
cQuery += " AND TDV.TDV_DTREF = '" +  DToS(dDataBase) + "' "

If !Empty(Self:cStart) .And. !Empty(Self:cEnd)  
      cQuery += " AND (ABB_HRINI >= '" + Self:cStart + "' AND ABB_HRFIM <= '" +  Self:cEnd + "') "
      cQuery += " AND ABB.ABB_DTFIM = TDV_DTREF "
ElseIf !Empty(Self:cStart)
      cQuery += " AND ABB_HRINI >= '" + Self:cStart + "' "
ElseIf !Empty(Self:cEnd)     
      cQuery += " AND ABB_HRFIM <= '" +  Self:cEnd + "' "
EndIf

If !Empty(Self:cSupervisor)
      cQuery += " AND TXI.TXI_CODTEC = '"  + Self:cSupervisor + "' "
      cQuery += " AND TXI.D_E_L_E_T_ = ' ' "
EndIf
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
cQuery += " AND ABS.D_E_L_E_T_ = ' ' "
cQuery += " AND TDV.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABS, .F., .T.)
If ( cAliasABS )->( !Eof() )
      cResponse := '{"stations":['
      While ( cAliasABS )->( !Eof() )
            If !Empty(Self:cSupervisor)
                  lContinua := ( cAliasABS )->TXI_DTINI <= DToS(dDataBase) .AND. ( cAliasABS )->TXI_DTFIM >= DToS(dDataBase)
            EndIf
            If lContinua
                  If cLocal <> ( cAliasABS )->ABS_LOCAL
                        If !lPrimeira
                              If !lOk 
                                    cType := "2"
                              ElseIf lAlerta 
                                    cType := "4"
                              Else
                                    cType := "1"
                              EndIf
                              If nSitua == 3 .OR. nSitua == Val(cType) .OR. lAlerta
                                    If nCount > 0
                                          cResponse += ','
                                    EndIf
                                    cResponse += '{"code":"' + Alltrim(cAux) + '",'                                     
                                    cResponse += '"desc":"' + Alltrim(cDescri) + '",'
                                    cResponse += '"type":"' + cType + '",'
                                    cResponse += '"lat":"' + Alltrim(cLati) + '",'
                                    cResponse += '"long":"' + Alltrim(cLong) + '"}'
                                    nCount += 1 
                                    AADD( aLocais, { cAux}) 
                              EndIf
                        Else
                              lPrimeira := .F. 
                        EndIf
                        cAux := ( cAliasABS )->ABS_LOCAL
                        cDescri := ( cAliasABS )->ABS_DESCRI
                        cLati := ( cAliasABS )->ABS_LATITU
                        cLong := ( cAliasABS )->ABS_LONGIT
                        cABBIni := ( cAliasABS )->TDV_DTREF  
                        lOk := .T.
                        lFutura := .F.
                        lPin := .T.
                  EndIf
                  If (( cAliasABS )->ABB_ATENDE == "1" .OR. ( cAliasABS )->ABB_CHEGOU == "S") .AND. lPin
                        lOk := .T.
                  ElseIf ( cTime > ( cAliasABS )->ABB_HRINI .AND. cABBIni == ( cAliasABS )->ABB_DTINI) .AND. lOK 
                        If ( cAliasABS )->ABB_CHEGOU <> "S" .AND. ( cAliasABS )->ABB_ATENDE <> "1"
                              lOk := .F.
                              lPin := .F.
                        EndIf
                  ElseIf cTime <= ( cAliasABS )->ABB_HRINI .AND. (lOk .AND. !lAlerta) .AND. lPin
                        If !Empty(nMin)
                              nDifHor := SubHoras( ( cAliasABS )->ABB_HRINI, cTime)
                              If nDifHor <= nMin
                                    lAlerta := .T.
                              EndIf
                        EndIf
                  EndIf                       
                  lUltimo := .T.                                                                                                                           
                  cLocal := ( cAliasABS )->ABS_LOCAL
                  cABBIni := ( cAliasABS )->ABB_DTINI 
            EndIf                                    
            ( cAliasABS )->( DBSkip() )     
      EndDo
      If lUltimo .AND. Ascan( aLocais, { |a| a[1] == cAux }) == 0
            If !lOk 
                  cType := "2"
            ElseIf lAlerta 
                  cType := "4"
            Else
                  cType := "1"
            EndIf
            If nSitua == 3 .OR. nSitua == Val(cType) .OR. lAlerta
                  If nCount > 0
                        cResponse += ','
                  EndIf
                  cResponse += '{"code":"' + Alltrim(cAux) + '",'                                     
                  cResponse += '"desc":"' + Alltrim(cDescri) + '",'
                  cResponse += '"type":"' + cType + '",'
                  cResponse += '"lat":"' + Alltrim(cLati) + '",'
                  cResponse += '"long":"' + Alltrim(cLong) + '"}'
                  nCount += 1 
            EndIf
      EndIf
      If nCount > 0
            cResponse += ' ], '                      
            cResponse += '"count": ' +cBIStr( nCount ) + ' } '
      Else
            cResponse   := '{ "stations":[], "count": 0 }' 
      EndIf
EndIf
(cAliasABS)->(dbCloseArea())
Self:SetResponse( EncodeUTF8(cResponse) )

Return ( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@description Retorna os supervisores
@author   Diego Bezerra
@since    19/02/2020
/*/
//------------------------------------------------------------------------------

WSMETHOD GET supervisors WSRECEIVE cStation WSREST PORTALPRESTADOR
Local cTemp       := GetNextAlias()
Local cQry        := ""
Local cResponse   := '{ "supervisors":[], "count": 0 }'   
Local cMessage    := "Internal Server Error"
Local cCodTec     := ""
Local nRecord     := 0
Local nStatusCode := 200

cQry += " SELECT AA1.AA1_CODTEC, AA1.AA1_FUNCAO, AA1.AA1_NOMTEC "
cQry += " FROM " + RetSqlName("AA1") + " AA1 "
cQry += " WHERE AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
cQry += " AND AA1.AA1_SUPERV = '1' "
cQry += " AND AA1.D_E_L_E_T_ = ' ' "

cQry := ChangeQuery(cQry)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),cTemp, .F., .T.)

If ( cTemp )->( !Eof() )
      ( cTemp )->( DBGoTop() )                 
      cResponse := ''
      cResponse := '{"items":['   
      cTime := Time()
      
      While ( cTemp )->( !Eof() )
            
            If cCodTec <> ( cTemp )->AA1_CODTEC
                  nRecord++
                  cResponse   +=      '{"value":"'     +    Alltrim(( cTemp )->AA1_CODTEC)      + '",'                                     
                  cResponse   +=      '"name":"'       +    Alltrim(( cTemp )->AA1_NOMTEC)      + '",'
                  cResponse   +=      '"function":"'   +    Alltrim(( cTemp )->AA1_FUNCAO)      + '"},'
            EndIf
            cCodTec := ( cTemp )->AA1_CODTEC
            ( cTemp )->( DBSkip() ) 
      EndDo
      cResponse = Left(cResponse, Len(cResponse)-1 )
      cResponse += ' ], '                      
      cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
      Self:SetResponse( EncodeUTF8(cResponse) )

Else
      Self:SetResponse( EncodeUTF8(cResponse) )
EndIF
(cTemp)->(dbCloseArea())
Return ( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} manut

@description Retorna informações para o grafico de manutenção
@author   Augusto Albuquerque
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET manut WSRECEIVE cContrt, cClient, cStation, cLoja, cProdut, cPosto, dDataDe, dDataAte WSREST PORTALPRESTADOR
Local lRet        := .T.
Local cAliasMNT   := GetNextAlias()
Local aManut      := {}
Local nPos        := 0
Local cQuery      := ""
Local nX
Local cResponse   := ""
Local cContrt     := Self:cContrt
Local cClient     := Self:cClient
Local cLoja       := Self:cLoja
Local cPosto      := Self:cPosto
Local cStation    := Self:cStation
Local cProdut     := Self:cProdut
Local dDataDe     := Self:dDataDe //STOD('')
Local dDataAte    := Self:dDataAte //STOD('')

If Empty( dDataDe )
      If Empty( dDataAte )
            dDataDe := DToS( dDataBase - 5 )
      Else
            dDataDe := DToS( STod( dDataAte ) - 5 )
      EndIf
EndIf
If Empty( dDataAte )
      If Empty( dDataDe )
            dDataAte := DTos( dDataBase )
      Else
            dDataAte := DToS( SToD( dDataDe ) + 5 )
      EndIf
EndIf

Self:SetContentType("application/json")

cQuery := ""
cQuery := " SELECT ABN.ABN_TIPO  "
cQuery += " FROM " + RetSqlName("ABN") + " ABN "
cQuery += " INNER JOIN " + RetSqlName( "ABR" ) + " ABR ON ABR.ABR_MOTIVO = ABN.ABN_CODIGO AND "
cQuery += " " + FWJoinFilial("ABN" , "ABR" , "ABN", "ABR", .T.) + " AND "
cQuery += " ABR.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName( "ABB" ) + " ABB "
cQuery += " ON " + FWJoinFilial("ABR" , "ABB" , "ABR", "ABB", .T.) + " "
cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
cQuery += " AND ABB.ABB_CODIGO = ABR.ABR_AGENDA "
cQuery += " LEFT JOIN " + RetSqlName( "TDV" ) + " TDV "
cQuery += " ON " + FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) + " "
cQuery += " AND TDV.D_E_L_E_T_ = ' ' "
cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "  
cQuery += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
cQuery += " " + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + " AND ABQ.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = ABQ.ABQ_PRODUT AND "
cQuery += " " + FWJoinFilial("ABQ" , "SB1" , "ABQ", "SB1", .T.) + " AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON ABB.ABB_LOCAL = ABS.ABS_LOCAL AND "
cQuery += " " + FWJoinFilial("ABB" , "ABS" , "ABB", "ABS", .T.) + " AND ABS.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
cQuery += " " + FWJoinFilial("ABQ" , "TFF" , "ABQ", "TFF", .T.) + " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
cQuery += " " + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
cQuery += " " + FWJoinFilial("TFL" , "TFJ" , "TFL", "TFJ", .T.) + " AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
cQuery += " WHERE "
cQuery += " ABN.ABN_FILIAL = '" +  xFilial('ABN') + "' AND "
cQuery += " (TDV.TDV_DTREF >= '" + dDataDe + "' AND  TDV.TDV_DTREF <= '" + dDataAte + "') AND " 
cQuery += " ABN.D_E_L_E_T_ = ' ' "
If !EMPTY(cContrt)
      cQuery += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
EndIf
If !EMPTY(cClient)
      cQuery += " AND TFJ.TFJ_CODENT = '" + cClient + "' "
      If !EMPTY(cLoja)
            cQuery += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
      EndIf
EndIf
If !EMPTY(cStation)
      cQuery += " AND TFL.TFL_LOCAL = '" + cStation + "' "
EndIf
If !EMPTY(cProdut)
      cQuery += " AND TFF.TFF_PRODUT = '" + cProdut + "' "
EndIf
If !EMPTY(cPosto)
      cQuery += " AND TFF.TFF_COD = '" + cPosto + "' "
EndIf
cQuery += " ORDER BY ABN_CODIGO "
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasMNT, .F., .T.)

If ( cAliasMNT )->( !Eof() )
      DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
      While ( cAliasMNT )->( !Eof() )
            If (nPos := ASCAN( aManut, { |a| a[1] == ( cAliasMNT )->ABN_TIPO }) )== 0
                  If SX5->(DbSeek(xFilial("SX5")+"I5"+( cAliasMNT )->ABN_TIPO))
                        nPos := Len(aManut) + 1
                        AADD( aManut, {   ( cAliasMNT )->ABN_TIPO,;
                                          X5Descri(),;
                                          0})
                  EndIf
            EndIf
            aManut[nPos][3] += 1
            ( cAliasMNT )->( DBSkip() ) 
      EndDo
      cResponse := "[ "
      For nX := 1 To Len(aManut)
            cResponse += '{ "category": "' + AllTrim(aManut[nX][2]) + '", '
            cResponse += '"value": ' + cValToChar(aManut[nX][3]) + ', '
            cResponse += '"tooltip": "' + AllTrim(aManut[nX][2]) + ': ' + cValToChar(aManut[nX][3]) + '" }, '
      Next nX
      cResponse := Left(cResponse, Len(cResponse)-2 )  
      cResponse += "]" 
Else
      cResponse := "[ "
      cResponse += '{ "category":"Sem dados para exibir", '
      cResponse += '"value": "0", '
      cResponse += '"tooltip": "Não há dados para exibir" }' 
      cResponse += "]" 
EndIf
Self:SetResponse( EncodeUTF8(cResponse) )
Return ( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} descriManut

@description Retorna a descrição para o grafico de manutenção
@author   Augusto Albuquerque
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET descriManut WSRECEIVE cDescAbn, cContrt, cClient, cStation, cLoja, cPosto, cProdut, dDataDe, dDataAte WSREST PORTALPRESTADOR
Local cResponse   := '{ "supervisors":[], "count": 0 }'   
Local cAliasSX5   := GetNextAlias()
Local cAliasABN   := GetNextAlias()
Local cQuery      := ""
Local cCodAbn     := ""
Local cCodAux     := ""
Local cDescAux    := ""
Local lPrimeira   := .T.
Local nCountAbn   := 0
Local cPosto      := Self:cPosto
Local cContrt     := Self:cContrt
Local cClient     := Self:cClient
Local cLoja       := Self:cLoja
Local cStation    := Self:cStation
Local cProdut     := Self:cProdut
Local dDataDe     := Self:dDataDe //STOD('')
Local dDataAte    := Self:dDataAte //STOD('')

If Empty( dDataDe )
      If Empty( dDataAte )
            dDataDe := DToS( dDataBase - 5 )
      Else
            dDataDe := DToS( STod( dDataAte ) - 5 )
      EndIf
EndIf
If Empty( dDataAte )
      If Empty( dDataDe )
            dDataAte := DTos( dDataBase )
      Else
            dDataAte := DToS( SToD( dDataDe ) + 5 )
      EndIf
EndIf

Self:SetContentType("application/json")


cQuery := " SELECT ABN_TIPO "
cQuery += " FROM " + retSqlName('ABN') + " ABN "
cQuery += " WHERE ABN.ABN_FILIAL = '" + xFilial('ABN') + "' "
cQuery += " AND ABN.ABN_DESC = '" + AllTrim(Self:cDescAbn)+"' "
cQuery += " AND ABN.D_E_L_E_T_ = '' "


//cQuery := " SELECT SX5.X5_CHAVE "
//cQuery += " FROM " + retSqlName("SX5") + " SX5 "
//cQuery += " WHERE SX5.X5_FILIAL = '" + xFilial("SX5") + "' "
//cQuery += " AND SX5." + cDescri  + " = '" + AllTrim(Self:cDescAbn) + "' "
//cQuery += " AND SX5.X5_TABELA = 'I5'"
//cQuery += " AND SX5.D_E_L_E_T_ = ' ' "

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasSX5, .F., .T.)
If !( cAliasSX5 )->( Eof() )
      cCodAbn := AllTrim(( cAliasSX5 )->ABN_TIPO)
EndIf
(cAliasSX5)->(dbCloseArea())
If !Empty( cCodAbn )

      cQuery := ""
      cQuery := " SELECT  ABN.ABN_CODIGO, ABN.ABN_DESC  "
      cQuery += " FROM " + RetSqlName("ABN") + " ABN "
      cQuery += " INNER JOIN " + RetSqlName( "ABR" ) + " ABR ON ABR.ABR_MOTIVO = ABN.ABN_CODIGO AND "
      cQuery += " " + FWJoinFilial("ABN" , "ABR" , "ABN", "ABR", .T.) + " AND "
      cQuery += " ABR.D_E_L_E_T_ = ' ' "
      cQuery += " LEFT JOIN " + RetSqlName( "ABB" ) + " ABB "
      cQuery += " ON " + FWJoinFilial("ABR" , "ABB" , "ABR", "ABB", .T.) + " "
      cQuery += " AND ABB.D_E_L_E_T_ = ' ' "
      cQuery += " AND ABB.ABB_CODIGO = ABR.ABR_AGENDA "
      cQuery += " LEFT JOIN " + RetSqlName( "TDV" ) + " TDV "
      cQuery += " ON " + FWJoinFilial("ABB" , "TDV" , "ABB", "TDV", .T.) + " "
      cQuery += " AND TDV.D_E_L_E_T_ = ' ' "
      cQuery += " AND TDV.TDV_CODABB = ABB.ABB_CODIGO "  
      cQuery += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
      cQuery += " " + FWJoinFilial("ABB" , "ABQ" , "ABB", "ABQ", .T.) + " AND ABQ.D_E_L_E_T_ = ' ' "
      cQuery += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = ABQ.ABQ_PRODUT AND "
      cQuery += " " + FWJoinFilial("ABQ" , "SB1" , "ABQ", "SB1", .T.) + " AND SB1.D_E_L_E_T_ = ' ' "
      cQuery += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON ABB.ABB_LOCAL = ABS.ABS_LOCAL AND "
      cQuery += " " + FWJoinFilial("ABB" , "ABS" , "ABB", "ABS", .T.) + " AND ABS.D_E_L_E_T_ = ' ' "
      cQuery += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
      cQuery += " " + FWJoinFilial("ABQ" , "TFF" , "ABQ", "TFF", .T.) + " AND TFF.D_E_L_E_T_ = ' ' "
      cQuery += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
      cQuery += " " + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + " AND TFL.D_E_L_E_T_ = ' ' "
      cQuery += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
      cQuery += " " + FWJoinFilial("TFL" , "TFJ" , "TFL", "TFJ", .T.) + " AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
      cQuery += " WHERE "
      cQuery += " ABN.ABN_FILIAL = '" +  xFilial('ABN') + "' AND "
      cQuery += " ABN.ABN_TIPO = '" + cCodAbn + "' AND "
      cQuery += " (TDV.TDV_DTREF >= '" + dDataDe + "' AND  TDV.TDV_DTREF <= '" + dDataAte + "') AND "  
      cQuery += " ABN.D_E_L_E_T_ = ' ' "
      If !EMPTY(cContrt)
            cQuery += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
      EndIf
      If !EMPTY(cClient)
            cQuery += " AND TFJ.TFJ_CODENT = '" + cClient + "' "
            If !EMPTY(cLoja)
                  cQuery += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
            EndIf
      EndIf
      If !EMPTY(cStation)
            cQuery += " AND TFL.TFL_LOCAL = '" + cStation + "' "
      EndIf
      If !EMPTY(cProdut)
            cQuery += " AND TFF.TFF_PRODUT = '" + cProdut + "' "
      EndIf

      If !EMPTY(cPosto)
            cQuery += " AND TFF.TFF_COD = '" + cPosto + "' "
      EndIf

      cQuery += " ORDER BY ABN_CODIGO "
      cQuery := ChangeQuery(cQuery)

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasABN, .F., .T.)
      If ( cAliasABN )->( !Eof() )
            cResponse := '[ '
            While ( cAliasABN )->( !Eof() )
                  If cCodAux <> ( cAliasABN )->ABN_CODIGO
                        If !lPrimeira
                              cResponse += '{ "chave": "' + cCodAux + '", "descri": "' + cDescAux + '", "quanti": ' + cValToChar(nCOuntAbn) + ' },'
                              nCountAbn := 1
                        Else
                              lPrimeira := .F.
                              nCountAbn++
                        EndIf 
                        cCodAux := ( cAliasABN )->ABN_CODIGO
                        cDescAux := AllTrim(( cAliasABN )->ABN_DESC)
                  Else
                      nCountAbn++  
                  EndIf
                  ( cAliasABN )->( DBSkip() ) 
            EndDo
            If nCountAbn > 0
                  cResponse += '{ "chave": "' + cCodAux + '", "descri": "' + cDescAux + '", "quanti": ' + cValToChar(nCOuntAbn) + ' },'
            EndIf
            cResponse = Left(cResponse, Len(cResponse)-1 )
            cResponse += ' ] ' 
      EndIf
      (cAliasABN)->(dbCloseArea())
EndIf
Self:SetResponse( EncodeUTF8(cResponse) )

Return ( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} fstations

@description Consulta padrão posto de trabalho
@author   Diego bezerra
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET fstations WSRECEIVE cContrt, cClient, cStation, cLoja, cProdut WSREST PORTALPRESTADOR
Local cTempTFF    := GetNextAlias()
Local cResponse   := '{ "appointments":[], "count": 0 }'   
Local cQuery      := ""
Local cMessage    := "Internal Server Error"
Local nStatusCode := 500
Local lRet        := .T.
Local nRecord     := 0
Local cContrt     := Self:cContrt
Local cClient     := Self:cClient
Local cLoja       := Self:cLoja
Local cStation    := Self:cStation
Local cProdut     := Self:cProdut

cQuery := " SELECT TFF.TFF_FILIAL, TFF.TFF_COD, SB1.B1_COD, SB1.B1_DESC, TFF.TFF_CONTRT, ABS.ABS_DESCRI, TFF.TFF_PERINI, TFF.TFF_PERFIM, TFF.TFF_QTDVEN, "
cQuery += " TFF.TFF_FUNCAO, TFF.TFF_TURNO, TFF.TFF_ESCALA, "
cQuery += " CASE WHEN TFF_COBCTR = '1' THEN 'SIM' ELSE 'NÃO' END TFF_COBCTR, " // SIM ## NÃO
cQuery += " CASE WHEN RJ_DESC IS NOT NULL THEN RJ_DESC ELSE ' ' END RJ_DESC, "
cQuery += " CASE WHEN R6_DESC IS NOT NULL THEN R6_DESC ELSE ' ' END R6_DESC, "
cQuery += " CASE WHEN TDW_DESC IS NOT NULL THEN TDW_DESC ELSE ' ' END TDW_DESC "
cQuery += " FROM " + RetSqlName("TFF") + " TFF "
cQuery += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = TFF.TFF_PRODUT AND "
cQuery += " " + FWJoinFilial("TFF" , "SB1" , "TFF", "SB1", .T.) + " AND "
cQuery += " SB1.D_E_L_E_T_ = ' ' "
cQuery += " LEFT JOIN " + RetSqlName( "SRJ" ) + " SRJ "
cQuery += " ON " + FWJoinFilial("TFF" , "SRJ" , "TFF", "SRJ", .T.) + " "
cQuery += " AND SRJ.D_E_L_E_T_ = ' ' "
cQuery += " AND SRJ.RJ_FUNCAO = TFF.TFF_FUNCAO "
cQuery += " LEFT JOIN " + RetSqlName( "SR6" ) + " SR6 "
cQuery += " ON " + FWJoinFilial("TFF" , "SR6" , "TFF", "SR6", .T.) + " "
cQuery += " AND SR6.D_E_L_E_T_ = ' ' "
cQuery += " AND SR6.R6_TURNO = TFF.TFF_TURNO "  
cQuery += " LEFT JOIN " + RetSqlName( "TDW" ) + " TDW "
cQuery += " ON " + FWJoinFilial("TFF" , "TDW" , "TFF", "TDW", .T.) + " "
cQuery += " AND TDW.D_E_L_E_T_ = ' ' "
cQuery += " AND TDW.TDW_COD = TFF.TFF_ESCALA "  
cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
cQuery += " ON " + FWJoinFilial("TFF" , "TFL" , "TFF", "TFL", .T.) + " "
cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
cQuery += " ON " + FWJoinFilial("TFF" , "TFJ" , "TFF", "TFJ", .T.) + " AND "
cQuery += " TFJ.D_E_L_E_T_ = ' ' "
cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
cQuery += " AND TFJ.TFJ_STATUS = '1' "
cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
If !EMPTY(cContrt)
      cQuery += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
EndIf
cQuery += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON TFL.TFL_LOCAL = ABS.ABS_LOCAL AND "
cQuery += " " + FWJoinFilial("ABS" , "TFL" , "ABS", "TFL", .T.) + " "
cQuery += " AND ABS.D_E_L_E_T_ = ' ' "
cQuery += " WHERE "
cQuery += " TFF.TFF_FILIAL = '" +  xFilial('TFF') + "' AND "
cQuery += " TFF.D_E_L_E_T_ = ' ' "
If !EMPTY(cClient)
      cQuery += " AND TFJ.TFJ_CODENT = '" + cClient + "' "
      If !EMPTY(cLoja)
            cQuery += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
      EndIf
EndIf

If !EMPTY(cStation)
      cQuery += " AND TFL.TFL_LOCAL = '" + cStation + "' "
EndIf

If !EMPTY(cProdut)
      cQuery += " AND TFF.TFF_PRODUT = '" + cProdut + "' "
EndIf
cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTempTFF, .F., .T.)
cResponse := '{"items":[ '
If ( cTempTFF )->( !Eof() )
      While ( cTempTFF )->( !Eof() )
            cResponse += '{"valueTFF":"' + AllTrim( (cTempTFF)->TFF_COD ) + '",'
            cResponse += '"valueSB1":"' + AllTrim( (cTempTFF)->B1_COD ) + '",'
            cResponse += '"descSB1":"' + AllTrim( (cTempTFF)->B1_DESC ) + '",'
            cResponse += '"contr":"' + AllTrim( (cTempTFF)->TFF_CONTRT ) + '",'
            cResponse += '"descABS":"' + AllTrim( (cTempTFF)->ABS_DESCRI ) + '",'
            cResponse += '"dateSta":"' + AllTrim( (cTempTFF)->TFF_PERINI ) + '",'
            cResponse += '"dateFin":"' + AllTrim( (cTempTFF)->TFF_PERFIM ) + '",'
            cResponse += '"numberV":"' + AllTrim( (cTempTFF)->TFF_QTDVEN ) + '",'
            cResponse += '"function":"' + AllTrim( (cTempTFF)->TFF_FUNCAO ) + '",'
            cResponse += '"turn":"' + AllTrim( (cTempTFF)->TFF_TURNO ) + '",'
            cResponse += '"scale":"' + AllTrim( (cTempTFF)->TFF_ESCALA ) + '",'
            cResponse += '"cobctr":"' + AllTrim( (cTempTFF)->TFF_COBCTR ) + '",'
            cResponse += '"descRj":"' + AllTrim( (cTempTFF)->RJ_DESC ) + '",'
            cResponse += '"descR6":"' + AllTrim( (cTempTFF)->R6_DESC ) + '",'
            cResponse += '"descTDW":"' + AllTrim( (cTempTFF)->TDW_DESC ) + '"},'
            ( cTempTFF )->( DBSkip() ) 
      EndDo      
Else
    cResponse += '{"valueTFF":" ","valueSB1":" ","descSB1":" ","contr":" ","descABS":" ","dateSta":" ","dateFin":" ","numberV":" ","function":" ","turn":" ","scale":" ","cobctr":" ","descRj":" ","descR6":" ","descTDW":" "},'            
EndIf
cResponse = Left(cResponse, Len(cResponse)-1 )
cResponse += '], '
cResponse += '"count": ' +cBIStr( nRecord ) + ' } '   
(cTempTFF)->(dbCloseArea())
Self:SetResponse( EncodeUTF8(cResponse) )

Return ( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} fcostations

@description Retorna a descrição para o grafico de manutenção
@author    Diego bezerra
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET fcostations WSREST PORTALPRESTADOR

cResponse := '{"columns":[ '
cResponse += '{"property": "code", "label": "Codigo", "width": "80px"},'
cResponse += '{"property": "description", "label": "Descricao", "width": "80px"},'
cResponse += '{"property": "code of product", "label": "Codigo do Produto", "width": "80px"}, '
cResponse += '{"property": "description of product", "label": "Descrição do Produto", "width": "80px"}, '
cResponse += '{"property": "contract", "label": "Contrato", "width": "80px"}, '
cResponse += '{"property": "occupation", "label": "Funcao", "width": "80px"}]'
cResponse += '}'

Self:SetContentType("application/json")

Self:SetResponse( EncodeUTF8(cResponse) )

Return ( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} linechartdata

@description Retorno de dados para o grafico de linhas
@author    Diego bezerra
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET linechartdata WSRECEIVE cContrt, cClient, cStation, cLoja, cProdut, cPosto, dDataDe, dDataAte WSREST PORTALPRESTADOR
Local cMessage    := "Internal Server Error"
Local cResponse   := '{ "chartData":[], "count": 0 }' 
Local dDataDe     := Self:dDataDe //STOD('')
Local dDataAte    := Self:dDataAte //STOD('')
Local cClient     := Self:cClient
Local cProdut     := Self:cProdut
Local cPosto      := Self:cPosto
Local cLoja       := Self:cLoja

Local cCtr        := Self:cContrt
Local cLocal      := ''
Local cSql        := ''
Local cAliasQry   := ''
Local nStatusCode := 500
Local nCount      := 0
Local aData       := {}
Local nPos        := 0
Local nPosAux     := 0
Local aAux        := {}
Local nX          := 0
Local d1          := STOD('')
Local d2          := STOD('')

If EMPTY(dDataDe) .AND. EMPTY(dDataAte)
      dDataDe  := STOD('')
      dDataAte := STOD('')
EndIf

cSql += " SELECT TDV.TDV_DTREF, ABB.ABB_CODTEC,ABB.ABB_HRINI, ABB.ABB_HRFIM, ABB.ABB_MANUT "
cSql += " FROM " + RetSqlName( "ABB" ) + " ABB INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
cSql += " TDV.D_E_L_E_T_ = ' ' AND "
cSql += " TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND "
cSql += " TDV.TDV_CODABB = ABB.ABB_CODIGO "
cSql += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
cSql += " ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "
cSql += " AND ABQ.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = ABQ.ABQ_PRODUT AND "
cSql += " SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cSql += " AND SB1.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON ABB.ABB_LOCAL = ABS.ABS_LOCAL AND "
cSql += " ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
cSql += " AND ABS.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
cSql += " TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cSql += " AND TFF.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
cSql += " TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cSql += " AND TFL.D_E_L_E_T_ = ' ' "
cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
cSql += " TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
cSql += " AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
cSql += " AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
cSql += " AND AA1.D_E_L_E_T_ = ' ' "
cSql += " WHERE ABB.D_E_L_E_T_ = ' ' "
cSql += " AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "


d1 := STOD(dDataDe)
d2 := STOD(dDataATe)
aAux := {}

While d1 <= d2
      aAdd(aData,{dToS(d1),0,0})
      d1++
EndDo

If !EMPTY(dDataDe) .AND. !EMPTY(dDataAte)
      cSql += " AND TDV.TDV_DTREF >= '" + dDataDe + "' AND TDV.TDV_DTREF <= '" + dDataAte + "' "
EndIf
If !EMPTY(cClient)
      cSql += " AND TFJ.TFJ_CODENT = '" + cClient + "' "
      If !EMPTY(cLoja)
            cSql += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
      EndIf
EndIf
If !EMPTY(cLoja)
      cSql += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
EndIf
If !EMPTY(cCtr)
      cSql += " AND TFJ.TFJ_CONTRT = '" + cCtr + "' "
EndIf
If !EMPTY(cLocal)
      cSql += " AND ABQ.ABQ_LOCAL = '" + cLocal + "' "
EndIf
If !EMPTY(cProdut)
      cSql += " AND TFF.TFF_PRODUT = '" + cProdut + "' "
EndIf
If !EMPTY(cPosto)
      cSql += " AND TFF.TFF_COD = '" + cPosto + "' "
EndIf

cSql += " ORDER BY TDV.TDV_DTREF, ABB.ABB_CODTEC,ABB.ABB_DTINI, ABB.ABB_HRINI"

cSql := ChangeQuery(cSql)
cAliasQry := GetNextAlias()

dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

If ( cAliasQry )->( !Eof() )
      ( cAliasQry )->( DBGoTop() )
      
      
      While ( cAliasQry )-> ( !Eof() )
            nPos := aScan(aData, {|x| x[1] == (cAliasQry)->TDV_DTREF })
            If nPos > 0
                  nPosAux := aScan(aAux,{|x| x[1] == (cAliasQry)->TDV_DTREF .AND. x[2] == (cAliasQry)->ABB_CODTEC .AND. x[3] == (cAliasQry)->ABB_HRINI .AND. x[4] == (cAliasQry)->ABB_HRFIM})
                  If nPosAux == 0
                        aData[nPos][2]++ 
                        If (cAliasQry)->ABB_MANUT == '1'
                          aData[nPos][3]++
                        EndIf   
                        aAdd(aAux,{(cAliasQry)->TDV_DTREF, (cAliasQry)->ABB_CODTEC, (cAliasQry)->ABB_HRINI,(cAliasQry)->ABB_HRFIM})                      
                  EndIf
            Else
                  aAdd(aData,{(cAliasQry)->TDV_DTREF, 1, iif((cAliasQry)->ABB_MANUT == '1', 1 ,0)})
                  aAdd(aAux,{(cAliasQry)->TDV_DTREF, (cAliasQry)->ABB_CODTEC,(cAliasQry)->ABB_HRINI,(cAliasQry)->ABB_HRFIM })
            EndIF
            ( cAliasQry )-> ( dbSkip() )
      EndDo

      //SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf
cResponse := ''
cResponse := '{"chartdata":['  
For nX := 1 to Len(aData)
      cResponse += '{ "date":"'+aData[nX][1]+'", '
      cResponse += '"count":'+cValToChar(aData[nX][2]) + ', '
      cResponse += '"manut":'+cValToChar(aData[nX][3])+'}, '
Next nX
cResponse := Left(cResponse, Len(cResponse)-2 )
cResponse += "]}"

Self:SetResponse( EncodeUTF8(cResponse) )

Return ( .T. )

//------------------------------------------------------------------------------
/*/{Protheus.doc} RhIten

@description Consulta padrão de Item de RH
@author    Augusto Albuquerque
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET RhIten WSRECEIVE page, pageSize, cContrt, cClient, cStation, cLoja  WSREST PORTALPRESTADOR

Local cTempSB1    := GetNextAlias()
Local cResponse   := '{ "appointments":[], "count": 0 }'   
Local cQuery      := ""
Local cMessage    := "Internal Server Error"
Local nStatusCode := 500
Local lRet        := .T.
Local nRecord     := 0
Local cContrt     := Self:cContrt
Local cClient     := Self:cClient
Local cLoja       := Self:cLoja
Local cStation    := Self:cStation

If lRet

      cQuery := " SELECT DISTINCT SB1.B1_COD, SB1.B1_DESC, SB1.B1_FILIAL "
      cQuery += " FROM " +  RetSqlName( "SB1" ) + " SB1 " 
      cQuery += " INNER JOIN " + RetSqlName( "TFF" ) + " TFF "
      cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
      cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
      cQuery += " AND TFF.TFF_PRODUT = SB1.B1_COD "
      cQuery += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL "
      cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
      cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
      cQuery += " AND TFL.TFL_CODIGO = TFF.TFF_CODPAI "
      cQuery += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ "
      cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
      cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
      cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
      cQuery += " AND TFJ.TFJ_STATUS = '1' "
      cQUery += " AND TFJ.TFJ_CONTRT <> ' ' "
      cQuery += " WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
      cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
      If ValType(cContrt) == "C" .AND. !EMPTY(cContrt)
            cQuery += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
      EndIf
      If ValType(cClient) == "C" .AND. !EMPTY(cClient)
            cQuery += " AND TFJ.TFJ_CODENT = '" + cClient + "' "
            If !EMPTY(cLoja)
                  cQuery += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
            EndIf
      EndIf
      If ValType(cStation) == "C" .AND. !EMPTY(cStation)
            cQuery += " AND TFL.TFL_LOCAL = '" + cStation + "' "
      EndIf

      cQuery := ChangeQuery(cQuery)
      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTempSB1, .F., .T.)

      ( cTempSB1 )->( DBGoTop() )                 

      cResponse := ''
      cResponse := '{"items":['   

      If ( cTempSB1 )->( !Eof() )
            While ( cTempSB1 )->( !Eof() )
                  nRecord++
                  cResponse += '{"value":"' + AllTrim( (cTempSB1)->B1_COD ) + '",'
                  cResponse += '"desc":"' + AllTrim( (cTempSB1)->B1_DESC ) + '"},'
                  ( cTempSB1 )->( DBSkip() )   
            EndDo
      Else
            cResponse += '{"value":" ","desc":" "},'
      EndIf
      (cTempSB1)->(dbCloseArea())

      cResponse = Left(cResponse, Len(cResponse)-1 )
      cResponse += '], '
      cResponse += '"count": ' +cBIStr( nRecord ) + ' } '

      Self:SetResponse( EncodeUTF8(cResponse) )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtendimentSta

@description Consulta padrão de local de atendimento
@author    Augusto Albuquerque
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET AtendimentSta WSRECEIVE page, pageSize, cContrt, cClient, cStation, cLoja  WSREST PORTALPRESTADOR

Local cTempSB1    := GetNextAlias()
Local cResponse   := '{ "appointments":[], "count": 0 }'   
Local cQuery      := ""
Local cMessage    := "Internal Server Error"
Local nStatusCode := 500
Local lRet        := .T.
Local nRecord     := 0
Local cContrt     := Self:cContrt
Local cClient     := Self:cClient
Local cLoja       := Self:cLoja
Local cStation    := Self:cStation

If lRet
    
      cQuery := " SELECT DISTINCT ABS.ABS_FILIAL FILLOC ,ABS.ABS_LOCAL, ABS.ABS_LOCPAI, ABS.ABS_DESCRI, ABS.ABS_CCUSTO, ABS.ABS_REGIAO, ABS.ABS_FILIAL "
      cQuery += " FROM " + RetSqlName("ABS") + " ABS "
      cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
      cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
      cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
      cQuery += " AND TFL.TFL_LOCAL = ABS.ABS_LOCAL "
      cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
      cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' AND "
      cQuery += " TFJ.D_E_L_E_T_ = ' ' "
      cQuery += " AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
      cQuery += " AND TFJ.TFJ_STATUS = '1' "
      cQuery += " AND TFJ.TFJ_CONTRT <> ' ' "
      cQuery += " WHERE ABS.ABS_FILIAL = '" +  xFilial('ABS') + "' AND "
      cQuery += " ABS.D_E_L_E_T_ = ' ' "
      If ValType(cContrt) == "C" .AND. !EMPTY(cContrt)
            cQuery += " AND TFJ.TFJ_CONTRT = '" + cContrt + "' "
      EndIf
      If ValType(cClient) == "C" .AND. !EMPTY(cClient)
            cQuery += " AND TFJ.TFJ_CODENT = '" + cClient + "' "
            If !EMPTY(cLoja)
                  cQuery += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
            EndIf
      EndIf
      If ValType(cStation) == "C" .AND. !EMPTY(cStation)
            cQuery += " AND TFL.TFL_LOCAL = '" + cStation + "' "
      EndIf

      cQuery := ChangeQuery(cQuery)
      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTempSB1, .F., .T.)

      ( cTempSB1 )->( DBGoTop() )                 

      cResponse := ''
      cResponse := '{"items":['   

      If ( cTempSB1 )->( !Eof() )
            While ( cTempSB1 )->( !Eof() )
                  nRecord++
                  cResponse += '{"value":"' + AllTrim( (cTempSB1)->ABS_LOCAL ) + '",'
                  cResponse += '"desc":"' + AllTrim( (cTempSB1)->ABS_DESCRI ) + '"},'
                  ( cTempSB1 )->( DBSkip() )   
            EndDo
      Else
             cResponse += '{"value":" ","desc":" "},'
      EndIf
      (cTempSB1)->(dbCloseArea())

      cResponse = Left(cResponse, Len(cResponse)-1 )
      cResponse += '], '
      cResponse += '"count": ' +cBIStr( nRecord ) + ' } '

      Self:SetResponse( cResponse )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} Contrat

@description Consulta padrão de contrato
@author    Augusto Albuquerque
@since    02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET Contrat WSRECEIVE page, pageSize, cClient, cLoja  WSREST PORTALPRESTADOR
Local cTempCN9    := GetNextAlias()
Local cResponse   := '{ "appointments":[], "count": 0 }'   
Local cQuery      := ""
Local cMessage    := "Internal Server Error"
Local nStatusCode := 500
Local lRet        := .T.
Local nRecord     := 0
Local cClient     := Self:cClient
Local cLoja       := Self:cLoja

If lRet

      cQuery := " SELECT DISTINCT CN9_FILIAL, CN9.CN9_NUMERO, CN9.CN9_REVISA, TFJ.TFJ_CODENT, TFJ.TFJ_LOJA, SA1.A1_NOME "
      cQuery += " FROM " + RetSqlName("CN9") + " CN9 "
      cQuery += " INNER JOIN " + RetSqlName("TFJ") + " TFJ "
      cQuery += " ON TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
      cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
      cQuery += " AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
      cQuery += " AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
      cQuery += " AND TFJ.TFJ_STATUS = '1' "
      cQuery += " INNER JOIN " + RetSqlName("TFL") + " TFL "
      cQuery += " ON TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
      cQuery += " AND TFL.D_E_L_E_T_ = ' ' "
      cQuery += " AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
      cQuery += " INNER JOIN " + RetSqlName("TFF") + " TFF "
      cQuery += " ON TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
      cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
	cQuery += " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += " ON SA1.A1_FILIAL = '" + xFilial("SA1") + "' "
	cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SA1.A1_COD = TFJ.TFJ_CODENT "
	cQuery += " AND SA1.A1_LOJA = TFJ.TFJ_LOJA "
      cQuery += " WHERE CN9.CN9_FILIAL = '" +  xFilial('CN9') + "' AND "
      cQuery += " CN9.D_E_L_E_T_ = ' ' "
      If ValType(cClient) == "C" .AND. !EMPTY(cClient)
            cQuery += " AND TFJ.TFJ_CODENT = '" + cClient + "' "
            If !EMPTY(cLoja)
                  cQuery += " AND TFJ.TFJ_LOJA = '" + cLoja + "' "
            EndIf
      EndIf

      cQuery := ChangeQuery(cQuery)
      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTempCN9, .F., .T.)

      ( cTempCN9 )->( DBGoTop() )                 

      cResponse := ''
      cResponse := '{"items":['   
      If ( cTempCN9 )->( !Eof() )
            While ( cTempCN9 )->( !Eof() )
                  nRecord++
                  cResponse += '{"value":"' + AllTrim( (cTempCN9)->CN9_NUMERO ) + '",'
                  cResponse += '"review":"' + AllTrim( (cTempCN9)->CN9_REVISA ) + '",'
                  cResponse += '"client":"' + AllTrim( (cTempCN9)->TFJ_CODENT ) + '",'
                  cResponse += '"store":"' + AllTrim( (cTempCN9)->TFJ_LOJA ) + '",'
                  cResponse += '"desc":"' + AllTrim( (cTempCN9)->A1_NOME ) + '"},'
                  ( cTempCN9 )->( DBSkip() )   
            EndDo
      Else
            cResponse += '{"value":" ","review":" ","client":" ","store":" ","desc":" "},'
      EndIf
      (cTempCN9)->(dbCloseArea())
      cResponse = Left(cResponse, Len(cResponse)-1 )
      cResponse += '], '
      cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
      Self:SetResponse( EncodeUTF8(cResponse) )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf

Return .T.
//------------------------------------------------------------------------------
/*/{Protheus.doc} AttendantsUsed

@description Porcentagem de atendentes ultilizados.
@author    Kaique Schiller
@since     02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET AttendantsUsed WSRECEIVE cClient, cLoja, cContrt, cLocal, cProdut, cPosto, dDataDe, dDataAte WSREST PORTALPRESTADOR

Local cMessage    := "Internal Server Error"
Local cResponse   := '{ "chartData":[], "count": 0 }' 
Local cCli        := Self:cClient
Local cLoj        := Self:cLoja
Local cCtr        := Self:cContrt
Local cLoc        := Self:cLocal
Local cPrd        := Self:cProdut
Local cPost       := Self:cPosto
Local dDtDe       := Self:dDataDe 
Local dDtAte      := Self:dDataAte
Local cSql        := ''
Local cAliasQry   := ''
Local nStatusCode := 500
Local nX          := 0
Local nDia        := 0
Local nAtdUtil    := 0
Local nAtdNUtil   := 0
Local aAtdUlt     := {}
Local nPercAtd    := 0
Local lRestrRH    := .F.
Local lResRHTXB	:= TableInDic("TXB") //Restrições de RH
Local nPosTXBDtI  := 0
Local nPosTXBDtF  := 0	

If Empty(dDtDe)
      dDtDe := dDataBase
Else
      dDtDe := Stod(dDtDe)
Endif

If Empty(dDtAte)
      dDtAte := dDataBase
Else
      dDtAte := Stod(dDtAte)
EndIf

While (dDtDe+nDia) <= dDtAte

      nAtdUtil  := 0
      nAtdNUtil := 0

      //Query para verificar os atendentes utilizados.
      cSql := " SELECT ABB.ABB_CODTEC "
      cSql += " FROM " + RetSqlName( "ABB" ) + " ABB INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
      cSql += "   TDV.D_E_L_E_T_ = ' ' AND "
      cSql += "   TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND "
      cSql += "   TDV.TDV_CODABB = ABB.ABB_CODIGO "
      cSql += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
      cSql += "   ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "
      cSql += "   AND ABQ.D_E_L_E_T_ = ' ' "
      cSql += "   INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = ABQ.ABQ_PRODUT AND "
      cSql += "   SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
      cSql += "   AND SB1.D_E_L_E_T_ = ' ' "
      cSql += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON ABB.ABB_LOCAL = ABS.ABS_LOCAL AND "
      cSql += "   ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
      cSql += "   AND ABS.D_E_L_E_T_ = ' ' "
      cSql += "   INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
      cSql += "   TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
      cSql += "   AND TFF.D_E_L_E_T_ = ' ' "
      cSql += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
      cSql += "   TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
      cSql += "   AND TFL.D_E_L_E_T_ = ' ' "
      cSql += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
      cSql += "   TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
      cSql += "   AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
      cSql += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
      cSql += "   AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
      cSql += "   AND AA1.D_E_L_E_T_ = ' ' "
      cSql += " INNER JOIN " + RetSqlName( "TGY" ) + " TGY ON TGY.TGY_CODTFF = TFF.TFF_COD "
      cSql += "   AND TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
      cSql += "   AND TGY.D_E_L_E_T_ = ' ' "
      cSql += " INNER JOIN " + RetSqlName( "TCU" ) + " TCU ON TCU.TCU_COD = TGY.TGY_TIPALO AND "
      cSql += "   TCU.TCU_FILIAL = '" + xFilial("TCU") + "' "
      cSql += "   AND TCU.D_E_L_E_T_ = ' ' "
      cSql += " WHERE ABB.D_E_L_E_T_ = ' ' "
      cSql += "   AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
      cSql += "   AND ABB.ABB_ATIVO = '1' "
      cSql += "   AND TDV.TDV_DTREF = '" + dTos((dDtDe+nDia)) + "' "
      cSql += "   AND '" + dTos((dDtDe+nDia)) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_ULTALO"
      cSql += "   AND TCU.TCU_RESTEC <> '2' "

      If !EMPTY(cCli)
            cSql += " AND TFJ.TFJ_CODENT = '" + cCli + "' "
      EndIf

      If !EMPTY(cLoj)
            cSql += " AND TFJ.TFJ_LOJA = '" + cLoj + "' "
      EndIf

      If !EMPTY(cCtr)
            cSql += " AND TFJ.TFJ_CONTRT = '" + cCtr + "' "
      EndIf

      If !EMPTY(cLoc)
            cSql += " AND TFL.TFL_LOCAL = '" + cLoc + "' "
      EndIf

      If !EMPTY(cPrd)
            cSql += " AND TFF.TFF_PRODUT = '" + cPrd + "' "
      EndIf

      If !EMPTY(cPost)
            cSql += " AND TFF.TFF_COD = '" + cPost + "' "
      EndIf

      cSql += "   GROUP BY ABB.ABB_CODTEC "

      cSql := ChangeQuery(cSql)

      cAliasQry := GetNextAlias()

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)
      
      While (cAliasQry)->(!Eof())
            
            lRestrRH := .F.            
            
            If dDtDe == (dDtDe+nDia)
                  ChkCfltAlc(dDtDe,dDtAte,(cAliasQry)->ABB_CODTEC)

                  If lResRHTXB .And. nPosTXBDtI == 0 .And. nPosTXBDtF == 0
                        nPosTXBDtI:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTINI'})
                        nPosTXBDtF:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTFIM'})
                  Endif
            Endif
            
            If !lRestrRH .And. Len(AT330ArsSt("aDiasFer")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasFer"),{|x| (dDtDe+nDia) >= x[2] .And. (dDtDe+nDia) <= x[3]} ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasFer2")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasFer2"),{|x| (dDtDe+nDia) >= x[2] .And. (dDtDe+nDia) <= x[3]} ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasFer3")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasFer3"),{|x| (dDtDe+nDia) >= x[2] .And. (dDtDe+nDia) <= x[3]} ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasDem")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasDem"),{|x| (dDtDe+nDia) >= x[2] } ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasAfast")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasAfast"),{|x| (dDtDe+nDia) >= x[2] .And. (dDtDe+nDia) <= x[3]} ) > 0)
            EndIf

            If lResRHTXB .And. !lRestrRH .And. Len(AT330ArsSt("ACFLTATND")) > 0  .And. nPosTXBDtI > 0 .And. nPosTXBDtF > 0
                  lRestrRH := (Ascan(AT330ArsSt("ACFLTATND"),{|x| !Empty(x[nPosTXBDtI]) .And. (dDtDe+nDia) >= sTod(x[nPosTXBDtI]) .And. ( Empty(x[nPosTXBDtF]) .Or. (dDtDe+nDia) <= sTod(x[nPosTXBDtF])) } ) > 0)
            Endif

            If !lRestrRH 
                  nAtdUtil++
            Endif
      
            AT330ArsSt(,.T.)

            (cAliasQry)->(dbSkip())
      EndDo
      
      (cAliasQry)->(dbCloseArea())

      //Query para verificar os atendentes não utilizados.
      cSql := " SELECT AA1.AA1_CODTEC "
      cSql += " FROM " + RetSqlName( "AA1" ) + " AA1 "
      cSql += " WHERE AA1.D_E_L_E_T_ = ' ' "
      cSql += "   AND AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
      cSql += "   AND (EXISTS (SELECT 1 "
      cSql += "                FROM " + RetSqlName( "TGY" ) + " TGY "
      cSql += "                INNER JOIN " + RetSqlName( "TCU" ) + " TCU ON TCU.TCU_COD = TGY.TGY_TIPALO "
      cSql += "                 AND TCU.TCU_FILIAL = '" + xFilial("TCU") + "' "
      cSql += "                 AND TCU.TCU_RESTEC = '2' "
      cSql += "                 AND TCU.D_E_L_E_T_ = '' "
      cSql += "                WHERE TGY.TGY_ATEND = AA1.AA1_CODTEC "
      cSql += "                 AND TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
      cSql += "                 AND ('" + dTos((dDtDe+nDia)) + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_ULTALO ) "
      cSql += "                 AND TGY.D_E_L_E_T_ = '') "
      cSql += "   OR NOT EXISTS (SELECT 1 "
      cSql += "                  FROM " + RetSqlName( "TGY" ) + " TGY2 "
      cSql += "                  WHERE TGY2.TGY_ATEND = AA1.AA1_CODTEC "
      cSql += "                   AND TGY2.TGY_FILIAL = '" + xFilial("TGY") + "' "
      cSql += "                   AND ('" + dTos((dDtDe+nDia)) + "' BETWEEN TGY2.TGY_DTINI AND TGY2.TGY_ULTALO ) "
      cSql += "                   AND TGY2.D_E_L_E_T_ = '' )) "
      cSql += " GROUP BY AA1.AA1_CODTEC "
      cSql += " ORDER BY AA1.AA1_CODTEC "

      cSql := ChangeQuery(cSql)

      cAliasQry := GetNextAlias()

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cSql),cAliasQry, .F., .T.)

      While (cAliasQry)->(!Eof())
            nAtdNUtil++
            (cAliasQry)->(dbSkip())
      EndDo

      (cAliasQry)->(dbCloseArea())
      Aadd(aAtdUlt,{(dDtDe+nDia),nAtdUtil,nAtdNUtil,Round(((nAtdUtil/(nAtdNUtil+nAtdUtil))*100),2)})
      nDia++

EndDo

If !Empty(aAtdUlt)
      For nX := 1 To Len(aAtdUlt)
            nPercAtd := (nPercAtd+aAtdUlt[nX,4])
      Next nX

      nPercAtd := Round((nPercAtd/Len(aAtdUlt)),2)

      cResponse := '{"total": "'+cValToChar(nPercAtd)+'" }'

      Self:SetResponse( EncodeUTF8(cResponse) )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
Endif

Return ( .T. )


//------------------------------------------------------------------------------
/*/{Protheus.doc} gtctrtatv

@description Retorna a quantidade de contratos ativos
@author    Diego Bezerra
@since     19/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET gtctrtatv WSRECEIVE cClient, cLoja, cContrt, cLocal, cProdut, cPosto, dDataDe, dDataAte WSREST PORTALPRESTADOR

Local cResponse   := ""
Local cCli        := Self:cClient
Local cLoj        := Self:cLoja
Local cCtr        := Self:cContrt
Local cLoc        := Self:cLocal
Local cPrd        := Self:cProdut
Local cPost       := Self:cPosto
Local dDtDe       := Self:dDataDe 
Local dDtAte      := Self:dDataAte
Local nTotal      := 0

If EMPTY(dDtDe) .AND. EMPTY(dDtAte)
      dDtDe  := STOD('')
      dDtAte := STOD('')
EndIf

cQuery := "SELECT DISTINCT CN9.CN9_NUMERO AS TOTAL "
cQuery += "FROM " + retSqlName("CN9") + " CN9 "
cQuery += "INNER JOIN " + retSqlName("TFJ") +" TFJ ON CN9.CN9_NUMERO  = TFJ.TFJ_CONTRT  AND  TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
cQuery += " AND TFJ.D_E_L_E_T_ = ' ' "
cQuery += " AND TFJ.TFJ_CONTRT = CN9.CN9_NUMERO "
cQuery += "	AND TFJ.TFJ_CONREV = CN9.CN9_REVISA "
cQuery += "	AND TFJ.TFJ_STATUS = '1' "
cQuery += " INNER JOIN " + retSqlName("TFL") + " TFL ON TFL.TFL_CODPAI = TFJ.TFJ_CODIGO AND TFL.TFL_FILIAL = '" + xFilial("TFL") + "' " 
cQuery += "	AND TFL.D_E_L_E_T_ = ' ' "
cQuery += "	AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
cQuery += " INNER JOIN " + retSqlName("TFF") + " TFF ON TFF.TFF_CODPAI = TFL.TFL_CODIGO AND TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQuery += " AND TFF.D_E_L_E_T_ = ' ' "
cQuery += " AND TFF.TFF_CODPAI = TFL.TFL_CODIGO "
cQuery += " WHERE CN9.CN9_FILIAL = '"+ xFilial("CN9") + "' "
cQuery += " AND CN9.D_E_L_E_T_ = ' ' "

If !EMPTY(dDtDe) .AND. !EMPTY(dDtAte)
      cQuery += " AND '" + dDtDe + "' BETWEEN CN9.CN9_DTINIC AND CN9.CN9_DTFIM "
EndIf

If !EMPTY(cCli)
      cQuery += " AND TFJ.TFJ_CODENT = '" + cCli + "' "
      If !EMPTY(cLoj)
            cQuery += " AND TFJ.TFJ_LOJA = '" + cLoj + "' "
      EndIf
EndIf

If !EMPTY(cCtr)
      cQuery += " AND TFJ.TFJ_CONTRT = '" + cCtr + "' "
EndIf

If !EMPTY(cLoc)
      cQuery += " AND TFL.TFL_LOCAL = '" + cLoc + "' "
EndIf

If !EMPTY(cPrd)
      cQuery += " AND TFF.TFF_PRODUT = '" + cPrd + "' "
EndIf

If !EMPTY(cPost)
      cQuery += " AND TFF.TFF_COD = '" + cPost + "' "
EndIf


cAlias := GetNextAlias()
dbUseArea( .T. , "TOPCONN", TCGENQRY( , , cQuery), cAlias, .F., .T.)

While (cAlias)->(!Eof())
      nTotal++
(cAlias)->(DbSkip())
EndDo
(cAlias)->(dbCloseArea())
cResponse := '{"kpi": "' + cValToChar(nTotal) + '" }'

Self:SetResponse( EncodeUTF8(cResponse) )

Return ( .T. )


//------------------------------------------------------------------------------
/*/{Protheus.doc} AttendantsUsed

@description Total de atendentes ociosos
@author    Diego Bezerra
@since     02/06/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET AttOciosos WSRECEIVE cClient, cLoja, cContrt, cLocal, cProdut, cPosto, dDataDe, dDataAte WSREST PORTALPRESTADOR
      
Local cResponse   := "" 
Local cQrySA1     := ""
Local cAliasSA1   := GetNextAlias()
Local cQryTGY     := ""
Local cAliasTGY   := ""
Local cQryABB     := ""
Local cAliasABB   := ""
Local cCli        := Self:cClient
Local cLoj        := Self:cLoja
Local cCtr        := Self:cContrt
Local cLoc        := Self:cLocal
Local cPrd        := Self:cProdut
Local cPost       := Self:cPosto
Local cDataDe     := Self:dDataDe
Local cDataAte    := Self:dDataAte
Local dDataDe     := sToD(cDataDe)
Local dDataAte    := sToD(cDataAte)
Local aDados      := {}
Local nAux        := 0
Local nX          := 0

      If EMPTY(dDataDe) .AND. EMPTY(dDataAte)
            dDataDe  := STOD('')
            dDataAte := STOD('')
      EndIf

     //Query para verificar os atendentes utilizados.
      cQrySA1 := " SELECT AA1.AA1_CODTEC, AA1.AA1_NOMTEC, SRA.RA_FILIAL, SRA.RA_SEXO, RA_MAT, RA_NOME "
      cQrySA1 += " FROM " + RetSqlName( "AA1" ) + " AA1 INNER JOIN " + RetSqlName( "SRA" ) + " SRA ON "
      cQrySA1 += "   SRA.RA_FILIAL = '" + xFilial("SRA") + "' "
      cQrySA1 += "   AND SRA.RA_MAT = AA1.AA1_CDFUNC "
      cQrySA1 += "   AND SRA.D_E_L_E_T_ = ' ' "
      cQrySA1 += "   WHERE AA1.AA1_FILIAL = '" + xFilial('AA1') + "' "
      cQrySA1 += "   AND AA1.D_E_L_E_T_ = ' ' "

      cQrySA1 := ChangeQuery(cQrySA1)

      dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQrySA1),cAliasSA1, .F., .T.)

      While (cAliasSA1)->(!Eof())

            // Verificar TGY
            cQryTGY := TGYQry(cDataDe, cDataAte, cCli, cLoj, cCtr, cLoc, cPost, cPrd, (cAliasSA1)->AA1_CODTEC)
            cQryTGY := ChangeQuery(cQryTGY)
            cAliasTGY := GetNextAlias()
            dbUseArea( .T., "TOPCONN", TCGENQRY( , , cQryTGY), cAliasTGY, .F., .T.)
            
            // Verificar Agendas
            cQryABB := ABBQry(cDataDe, cDataAte, cCli, cLoj, cCtr, cLoc, cPrd, cPost, (cAliasSA1)->AA1_CODTEC, (cAliasTGY)->(Eof()))
            cQryABB := ChangeQuery(cQryABB)
            cAliasABB := GetNextAlias()
            dbUseArea( .T. , "TOPCONN", TCGENQRY( , , cQryABB), cAliasABB, .F., .T.)

            // Se alguns dos parâmetros do filtro estiverem preenchidos e não encontrar TGY, não considerar
            If !Empty(cCli) .OR. !Empty(cCtr) .OR. !Empty(cLoc) .OR. !Empty(cPrd) .OR. !Empty(cPost)
                  If (cAliasTGY)->(!EOF()) 
                        checkTrab(dDataDe, dDataAte, (cAliasSA1)->AA1_CODTEC, cAliasABB, cAliasTGY, @aDados)
                  EndIf
            Else
                  checkTrab(dDataDe, dDataAte, (cAliasSA1)->AA1_CODTEC, cAliasABB, cAliasTGY, @aDados)
            EndIf
            (cAliasABB)->(dbCloseArea())
            (cAliasTGY)->(dbCloseArea())
       (cAliasSA1)->(dbSkip())
      EndDo
      (cAliasSA1)->(dbCloseArea())
      For nX := 1 to Len(aDados)
            nAux += aDados[nX][2]
      Next nX

      If nAux > 0
            nMedia := nAux / Len(aDados) 
      Else
            nMedia := 0
      EndIf
      cResponse := '{"kpi": "'+cValToChar(nMedia)+'" }'

      Self:SetResponse( EncodeUTF8(cResponse) )

Return (.T.)

//------------------------------------------------------------------------------
/*/{Protheus.doc} checkTrab

@description Realiza a verificação de dia trabalhado, restrições de RH e a disponibilidade de atendente em um período
@return aDados, array organizado por datas e quantidade de atendente ocioso
@author   Diego Bezerra
@since    17/06/2020
/*/
//------------------------------------------------------------------------------ 
Static Function checkTrab(dDataDe,dDataAte,cCodTec,cAliasABB,cAliasTGY,aDados)

Local lRet := .F.
Local lResRHTXB	:= TableInDic("TXB") //Restrições de RH
Local nPosTXBDtI  := 0
Local nPosTXBDtF  := 0	
Local d1          := dDataDe
Local nPosData    := 0
Local lExistTGY   := .F.
Local lExistABB   := .F.
Local lRestrRH    := .F.
Local lDiaTrb     := .F.
Local lTgY        := .F.
Local cChavTGY    := ""
Local aPrjAgd     := {}
Local nX          := 0
Local nY          := 0

ChkCfltAlc(dDataDe, dDataAte, cCodTec)		

If lResRHTXB .And. nPosTXBDtI == 0 .And. nPosTXBDtF == 0
      nPosTXBDtI:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTINI'})
      nPosTXBDtF:= AScan(AT330ArsSt("aCfltHead"),{|e| e == 'TXB_DTFIM'})
Endif

d1 := dDataDe

While d1 <= dDataAte
      nPosData = aScan(aDados, {|x| x[1] == dToS(d1)})
      lExistTGY := .F.
      lExistABB := .F.
      lRestrRH  := .F.
      lDiaTrb   := .F.
      lTgY      := .F.
      
      If nPosData == 0 
            aAdd(aDados,{ dToS(d1), 0 })
      EndIf
      While (cAliasTGY)->(!Eof())
            lTgY := .T.
            If d1 >= sTod((cAliasTGY)->TGY_DTINI) .And. d1 <= sTod((cAliasTGY)->TGY_ULTALO)				
                  lExistTGY := .T.
                  //Projeção de agenda.
                  If cChavTGY <> (cAliasTGY)->(TGY_FILIAL+TGY_ESCALA+TGY_CODTDX+TGY_CODTFF+TGY_ITEM) .And.;
                        TDX->(MsSeek(xFilial("TDX")+(cAliasTGY)->TGY_CODTDX))
                  
                        Aadd(aPrjAgd,ProjAgend(sTod((cAliasTGY)->TGY_DTINI),sTod((cAliasTGY)->TGY_ULTALO),TDX->TDX_TURNO,TDX->TDX_SEQTUR))
                        cChavTGY := (cAliasTGY)->(TGY_FILIAL+TGY_ESCALA+TGY_CODTDX+TGY_CODTFF+TGY_ITEM)
                  Endif
            Endif 
            (cAliasTGY)->(dbSkip())
      EndDo

      (cAliasABB)->(dBGoTop())
      While (cAliasABB)->(!Eof())
            If d1 >= sTod((cAliasABB)->ABB_DTINI) .And. d1 <= sTod((cAliasABB)->ABB_DTFIM)
                  lExistABB := .T.
                  Exit
            Elseif sTod((cAliasABB)->ABB_DTINI) > d1
                  Exit
            Endif
            (cAliasABB)->(dbSkip())
      EndDo

      //Verifica a exclusão de agenda
      If lExistTGY .And. !lExistABB
            For nX := 1 To Len(aPrjAgd)
                  For nY := 1 To Len(aPrjAgd[nX])
                        If aPrjAgd[nX,nY,1] == d1 .And. aPrjAgd[nX,nY,3] == "S"
                              lDiaTrb := .T.
                              Exit
                        Elseif aPrjAgd[nX,nY,1] > d1
                              Exit
                        Endif
                  Next nY
                  If lDiaTrb
                        Exit
                  EndIf
            Next nX		
      Endif

      If (!lExistABB .And. !lExistTGY) .Or. lDiaTrb 

            If !lRestrRH .And. Len(AT330ArsSt("aDiasFer")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasFer"),{|x| d1 >= x[2] .And. d1 <= x[3]} ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasFer2")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasFer2"),{|x| d1 >= x[2] .And. d1 <= x[3]} ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasFer3")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasFer3"),{|x| d1 >= x[2] .And. d1 <= x[3]} ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasDem")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasDem"),{|x| d1 >= x[2] } ) > 0)
            EndIf

            If !lRestrRH .And. Len(AT330ArsSt("aDiasAfast")) > 0
                  lRestrRH := (Ascan(AT330ArsSt("aDiasAfast"),{|x| d1 >= x[2] .And. d1 <= x[3]} ) > 0)
            EndIf

            If lResRHTXB .And. !lRestrRH .And. Len(AT330ArsSt("ACFLTATND")) > 0  .And. nPosTXBDtI > 0 .And. nPosTXBDtF > 0
                  lRestrRH := (Ascan(AT330ArsSt("ACFLTATND"),{|x| !Empty(x[nPosTXBDtI]) .And. d1 >= sTod(x[nPosTXBDtI]) .And. ( Empty(x[nPosTXBDtF]) .Or. d1 <= sTod(x[nPosTXBDtF])) } ) > 0)
            Endif

            If !lRestrRH 
                  lRet := .T.
                  nPosData = aScan(aDados, {|x| x[1] == dToS(d1)})                              
                  If nPosData > 0
                        aDados[nPosData][2]++
                  Else
                        aAdd(aDados,{dToS(d1),1})
                  EndIf
            Else
                  nPosData = aScan(aDados, {|x| x[1] == dToS(d1)})                              
                  If nPosData == 0
                        aAdd(aDados,{dToS(d1),0})
                  EndIf
            Endif
      EndIf
d1++
EndDo

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TGYQry

@description Retorna query para obter as TGY baseadas nos filtros do portal
@author   Diego Bezerra
@since    17/06/2020
/*/
//------------------------------------------------------------------------------           
Static Function TGYQry(cDataDe,cDataAte,cCli, cLoj, cCtr, cLoc, cPost,cPrd, cCodTec)

      Local cQryTGY := ""

      cQryTGY := "SELECT TGY.TGY_FILIAL,TGY.TGY_ESCALA,TGY.TGY_CODTDX,TGY.TGY_CODTFF,TGY.TGY_ITEM,TGY.TGY_DTINI,TGY.TGY_ULTALO "
      cQryTGY += " FROM " + RetSqlName("TGY")+" TGY "
      cQryTGY += " INNER JOIN " + RetSqlName("TFF") + " TFF ON TGY.TGY_CODTFF = TFF.TFF_COD "
      cQryTGY += "    AND TFF.TFF_FILIAL = '" + xFilial('TFF') + "' "
      cQryTGY += "    AND TFF.D_E_L_E_T_ = ' ' "
      cQryTGY += " INNER JOIN " + RetSqlName("TFL") + " TFL ON TFF.TFF_CODPAI = TFL.TFL_CODIGO "
      cQryTGY += "    AND TFL.TFL_FILIAL = '" + xFilial('TFL') + "' "
      cQryTGY += "    AND TFL.D_E_L_E_T_ = ' ' "
      cQryTGY += " INNER JOIN " + RetSqlName("TFJ") + " TFJ ON TFL.TFL_CODPAI = TFJ.TFJ_CODIGO "
      cQryTGY += "    AND TFJ.TFJ_FILIAL = '" + xFilial('TFJ') + "' "
      cQryTGY += "    AND TFJ.TFJ_STATUS = '1' AND TFJ.D_E_L_E_T_ = ' ' " 
      cQryTGY += " WHERE TGY.TGY_FILIAL = '" + xFilial('TGY') + "' "

      If !EMPTY(cCli)
            cQryTGY += " AND TFJ.TFJ_CODENT = '" + cCli + "' "
      EndIf

      If !EMPTY(cLoj)
            cQryTGY += " AND TFJ.TFJ_LOJA = '" + cLoj + "' "
      EndIf

      If !EMPTY(cCtr)
            cQryTGY += " AND TFJ.TFJ_CONTRT = '" + cCtr + "' "
      EndIf

      If !EMPTY(cLoc)
            cQryTGY += " AND TFL.TFL_LOCAL = '" + cLoc + "' "
      EndIf

      If !EMPTY(cPrd)
            cQryTGY += " AND TFF.TFF_PRODUT = '" + cPrd + "' "
      EndIf

      If !EMPTY(cPost)
            cQryTGY += " AND TFF.TFF_COD = '" + cPost + "' "
      EndIf

      cQryTGY += " AND TGY.TGY_ATEND = '" + cCodTec + "' "
      cQryTGY += " AND (TGY.TGY_DTINI BETWEEN '"+cDataDe+"' AND '" + cDataAte + "'  OR TGY.TGY_ULTALO BETWEEN '" + cDataDe +"' AND '"+cDataAte+"' " 
      cQryTGY += " OR ('" + cDataDe + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_ULTALO OR '" + cDataAte + "' BETWEEN TGY.TGY_DTINI AND TGY.TGY_ULTALO OR TGY.TGY_ULTALO = ' ')) "
      cQryTGY += " AND TGY.D_E_L_E_T_ = ' ' "
      cQryTGY += "        AND EXISTS "
      cQryTGY += "              (SELECT TCU.TCU_COD FROM " + RetSqlName("TCU") + " TCU "
      cQryTGY += "                    WHERE TCU.TCU_FILIAL = '" + xFilial("TCU") + "' "
      cQryTGY += "                          AND TCU.TCU_COD = TGY.TGY_TIPALO "
      cQryTGY += "                          AND TCU.TCU_RESTEC <> '1' "
      cQryTGY += "                          AND TCU.D_E_L_E_T_ = ' ' )"

Return cQryTGY

//------------------------------------------------------------------------------
/*/{Protheus.doc} ABBQry

@description Retorna query para obter as agendas baseadas nos filtros do portal
@author   Diego Bezerra
@since    17/06/2020
/*/
//------------------------------------------------------------------------------ 
Static Function ABBQry(cDataDe,cDataAte,cCli, cLoj, cCtr, cLoc, cPrd, cPost, cCodTec, lTgy)

Local cQryABB := ""

cQryABB := " SELECT ABB.ABB_CODIGO,ABB.ABB_DTINI, ABB.ABB_DTFIM "
cQryABB += " FROM " + RetSqlName( "ABB" ) + " ABB INNER JOIN " + RetSqlName( "TDV" ) + " TDV ON "
cQryABB += "   TDV.D_E_L_E_T_ = ' ' AND "
cQryABB += "   TDV.TDV_FILIAL = '" + xFilial("TDV") + "' AND "
cQryABB += "   TDV.TDV_CODABB = ABB.ABB_CODIGO "
cQryABB += " INNER JOIN " + RetSqlName( "ABQ" ) + " ABQ ON ABB.ABB_IDCFAL = ABQ.ABQ_CONTRT || ABQ.ABQ_ITEM || ABQ.ABQ_ORIGEM AND "
cQryABB += "   ABQ.ABQ_FILIAL = '" + xFilial("ABQ") + "' "
cQryABB += "   AND ABQ.D_E_L_E_T_ = ' ' "
cQryABB += "   INNER JOIN " + RetSqlName( "SB1" ) + " SB1 ON SB1.B1_COD = ABQ.ABQ_PRODUT AND "
cQryABB += "   SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
cQryABB += "   AND SB1.D_E_L_E_T_ = ' ' "
cQryABB += " INNER JOIN " + RetSqlName( "ABS" ) + " ABS ON ABB.ABB_LOCAL = ABS.ABS_LOCAL AND "
cQryABB += "   ABS.ABS_FILIAL = '" + xFilial("ABS") + "' "
cQryABB += "   AND ABS.D_E_L_E_T_ = ' ' "
cQryABB += "   INNER JOIN " + RetSqlName( "TFF" ) + " TFF ON TFF.TFF_COD = ABQ.ABQ_CODTFF AND TFF.TFF_FILIAL = ABQ.ABQ_FILTFF AND "
cQryABB += "   TFF.TFF_FILIAL = '" + xFilial("TFF") + "' "
cQryABB += "   AND TFF.D_E_L_E_T_ = ' ' "
cQryABB += " INNER JOIN " + RetSqlName( "TFL" ) + " TFL ON TFL.TFL_CODIGO = TFF.TFF_CODPAI AND "
cQryABB += "   TFL.TFL_FILIAL = '" + xFilial("TFL") + "' "
cQryABB += "   AND TFL.D_E_L_E_T_ = ' ' "
cQryABB += " INNER JOIN " + RetSqlName( "TFJ" ) + " TFJ ON TFJ.TFJ_CODIGO = TFL.TFL_CODPAI AND "
cQryABB += "   TFJ.TFJ_FILIAL = '" + xFilial("TFJ") + "' "
cQryABB += "   AND TFJ.D_E_L_E_T_ = ' ' AND TFJ.TFJ_STATUS = '1' "
cQryABB += " INNER JOIN " + RetSqlName( "AA1" ) + " AA1 ON AA1.AA1_CODTEC = ABB.ABB_CODTEC AND "
cQryABB += "   AA1.AA1_FILIAL = '" + xFilial("AA1") + "' "
cQryABB += "   AND AA1.D_E_L_E_T_ = ' ' "

If lTgy
      cQryABB += " INNER JOIN " + RetSqlName( "TGY" ) + " TGY ON TGY.TGY_CODTFF = TFF.TFF_COD "
      cQryABB += "   AND TGY.TGY_FILIAL = '" + xFilial("TGY") + "' "
      cQryABB += "   AND TGY.D_E_L_E_T_ = ' ' "
      cQryABB += " INNER JOIN " + RetSqlName( "TCU" ) + " TCU ON TCU.TCU_COD = TGY.TGY_TIPALO AND "
      cQryABB += "   TCU.TCU_FILIAL = '" + xFilial("TCU") + "' "
      cQryABB += "   AND TCU.D_E_L_E_T_ = ' ' "
EndIf

cQryABB += " WHERE ABB.D_E_L_E_T_ = ' ' "
cQryABB += "   AND ABB.ABB_FILIAL = '" + xFilial("ABB") + "' "
cQryABB += "   AND ABB.ABB_ATIVO <> '2' "
cQryABB += "   AND ABB.ABB_CODTEC = '" + cCodTec + "' "
cQryABB += "   AND (ABB.ABB_DTINI BETWEEN '" + cDataDe + "' AND '" + cDataAte + "' OR ABB.ABB_DTFIM BETWEEN '" + cDataDe + "' AND '" + cDataAte + "' "
cQryABB += "   OR ( '"+ cDataDe + "' BETWEEN ABB.ABB_DTINI AND ABB.ABB_DTFIM OR '" + cDataAte + "' BETWEEN ABB.ABB_DTINI AND ABB.ABB_DTFIM)) "

If lTgy
      cQryABB += "        AND EXISTS "
      cQryABB += "              (SELECT TCU.TCU_COD FROM " + RetSqlName('TCU') + " TCU "
      cQryABB += "                    WHERE TCU.TCU_FILIAL = '" + xFilial('TCU') + "' "
      cQryABB += "                          AND TCU.TCU_COD = ABB.ABB_TIPOMV "
      cQryABB += "                          AND TCU.TCU_RESTEC <> '1' "
      cQryABB += "                          AND TCU.D_E_L_E_T_ = ' ' ) "   
      cQryABB += "   AND TCU.TCU_RESTEC <> '2' "
EndIf

If !EMPTY(cCli)
      cQryABB += " AND TFJ.TFJ_CODENT = '" + cCli + "' "
EndIf

If !EMPTY(cLoj)
      cQryABB += " AND TFJ.TFJ_LOJA = '" + cLoj + "' "
EndIf

If !EMPTY(cCtr)
      cQryABB += " AND TFJ.TFJ_CONTRT = '" + cCtr + "' "
EndIf

If !EMPTY(cLoc)
      cQryABB += " AND TFL.TFL_LOCAL = '" + cLoc + "' "
EndIf

If !EMPTY(cPrd)
      cQryABB += " AND TFF.TFF_PRODUT = '" + cPrd + "' "
EndIf

If !EMPTY(cPost)
      cQryABB += " AND TFF.TFF_COD = '" + cPost + "' "
EndIf

cQryABB += "   GROUP BY ABB.ABB_CODIGO,ABB.ABB_DTINI, ABB.ABB_DTFIM "

Return cQryABB


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ProjAgend
Retorna a projeção de agenda de um determinado perodo
@author Kaique Schiller
@since 13/05/2020
@return aProjAgd, array, todos os dias do turno.
/*/
//-------------------------------------------------------------------------------------
Static Function ProjAgend(dDtIni,dDtFim,cTurno,cSeqIni)
Local aProjAgd  := {}
Local dDtProj   := dDtIni
Local aDiasSPJ  := {}
Local cAliasSPJ := GetNextAlias()
Local lPriDia	:= .F.
Local cUltSeq	:= ""
Local nSeq		:= 0
Local nPos		:= 0

BeginSql Alias cAliasSPJ
	SELECT SPJ.PJ_TURNO,
		   SPJ.PJ_SEMANA,
		   SPJ.PJ_DIA,
		   SPJ.PJ_TPDIA
	FROM %table:SPJ% SPJ
	WHERE SPJ.PJ_FILIAL = %xFilial:SPJ%
		AND SPJ.PJ_TURNO = %Exp:cTurno%
		AND SPJ.%notDel%
	ORDER BY PJ_TURNO,PJ_SEMANA,PJ_DIA
EndSql

While (cAliasSPJ)->(!Eof())
	aAdd(aDiasSPJ,{(cAliasSPJ)->PJ_SEMANA,; //Sequencia
					(cAliasSPJ)->PJ_DIA,;   //Dia semana
					(cAliasSPJ)->PJ_TPDIA}) //Tipo do dia - "S" Trabalahdo
	(cAliasSPJ)->(dbSkip())
	If !Empty((cAliasSPJ)->PJ_SEMANA)
		cUltSeq := (cAliasSPJ)->PJ_SEMANA
	Endif
EndDo

cSeqAux := cSeqIni

While dDtProj <= dDtFim

	If lPriDia .And. Dow(dDtProj) == 2
		nSeq++
		If (nSeq+Val(cSeqAux)) > Val(cUltSeq)
			nSeq 	:= 0
			cSeqAux := cSeqIni
		Else
			cSeqAux := PadL(cValToChar((nSeq+Val(cSeqAux))),TamSx3("PJ_SEMANA")[1],"0")
		Endif
	Endif
	
	If (nPos := AScan( aDiasSPJ ,{|e| e[1] == cSeqAux .And. e[2] == cValToChar(Dow(dDtProj)) })) > 0
		aAdd(aProjAgd, {dDtProj, aDiasSPJ[nPos,2],aDiasSPJ[nPos,3] })
		lPriDia := .T.
	Endif
		
	dDtProj++
EndDo

(cAliasSPJ)->(DbCloseArea())

Return aProjAgd

