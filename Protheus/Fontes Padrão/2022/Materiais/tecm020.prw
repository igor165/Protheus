#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

Classe responsável por retornar os dados do Atendente

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------

WSRESTFUL SUPERVISORGS DESCRIPTION STR0001  //"CheckIn GS"

      WSDATA cStart AS STRING
      WSDATA cEnd AS STRING
      WSDATA nSituation AS INTEGER
      WSDATA cMinutes AS STRING
      WSDATA cStation AS STRING          
      WSDATA cCode AS STRING
      WSDATA cInOut AS STRING
      WSDATA cObs AS STRING
      WSDATA cClients AS OBJECT
      WSDATA cPlaces AS OBJECT
      WSDATA cRegions AS OBJECT
      WSDATA cSupervisor AS OBJECT
      WSDATA nPage AS INTEGER
      WSDATA nPageSize AS INTEGER
      WSDATA cSearchTerm AS STRING
      WSDATA cDataApont as STRING
      
      WSMETHOD GET stations                DESCRIPTION 'locais '  PATH "stations" PRODUCES APPLICATION_JSON 
      WSMETHOD GET appointments     DESCRIPTION 'agendas'  PATH "appointments" PRODUCES APPLICATION_JSON 
      WSMETHOD GET checkin                 DESCRIPTION 'checkin'  PATH "checkin" PRODUCES APPLICATION_JSON
      WSMETHOD GET regions                 DESCRIPTION 'regiões'  PATH "regions" PRODUCES APPLICATION_JSON    
      WSMETHOD GET places                       DESCRIPTION 'postos'   PATH "places" PRODUCES APPLICATION_JSON
      WSMETHOD GET clients                 DESCRIPTION 'clientes' PATH "clients" PRODUCES APPLICATION_JSON
      WSMETHOD POST operationalDecision DESCRIPTION 'operationalDecision'  PATH "operationalDecision" PRODUCES APPLICATION_JSON
      WSMETHOD GET supervisor     DESCRIPTION 'supervisor' PATH "supervisor" PRODUCES APPLICATION_JSON
      
END WSRESTFUL

//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------

WSMETHOD GET stations WSRECEIVE nSituation, cStart, cEnd, cMinutes, cClients, cPlaces, cRegions, cSupervisor  WSREST SUPERVISORGS
Local cIdUserRole       := "" 
Local cDescription      := ""
Local cSelected         := ""
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "stations":[], "count": 0 }' 
Local nRecord           := 0
Local nCount            := 0
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local lRet             := .T.
Local cDtIni            := ""
Local aLocais           := {}
Local nI                := 1  
Local cTime             := Time()
Local nTamCli           := 0
Local nTamLoja          := 0
Local nTamPlace         := 0
Local nTamRegion        := 0
Local nTamSuperv        := 0
Local nPosCli           := 0
Local aClientes         := {}
Local aPlaces           := {}       
Local aRegions          := {}
Local aSuperv           := {}
Local cCodCli           := ""
Local cLoja             := ""
Local cPlace            := ""
Local cRegion           := ""
Local cSuperv           := ""
Local cExpCli           := "% 0 = 0%"
Local cExpPla           := "%0 = 0%"
Local cExpReg           := "%0 = 0%"
Local cExpHr            := "%0 = 0%"
Local cExpMin           := "%0 = 0%"
Local cExpMax           := "%0 = 0%"
Local cTempAlerta   := GetNextAlias()
Local aLocaisPen  := {}
Local nHour             := 0
Local nMinutes          := 0
Local nDiffIn           := 0
Local nDiffOut          := 0
Local cExpAlert		    := "%0 = 0%"
Local lSuperv           := .F.

// Define o tipo de retorno do método    
Self:SetContentType("application/json")

If (Self:nSituation == 2 .Or. Self:nSituation == 3) .And. Empty(Self:cMinutes) 
      Self:cMinutes := 0
EndIf

//Verifica se a tabela TXI existe para realização do filtro por supervisor
If  !Empty(Self:cSupervisor) .And. TecSupTXI()
      lSuperv := .T.
EndIf 

If lRet

      If Self:nSituation == 0
            Self:nSituation := 3
      EndIf
      aClientes := Separa(Self:cClients, ',')
      
      nTamCli := TamSX3('A1_COD')[1]
      nTamLoja := TamSX3('A1_LOJA')[1] 
      
      //-- Clientes
      For nI := 1 To Len(aClientes)
            nPosCli := At("||",aClientes[nI])
      
            cCodCli := AllTrim(SubStr(aClientes[nI],1,nPosCli-1))
            cLoja       := AllTrim(SubStr(aClientes[nI],nPosCli + 2  , Len(aClientes[nI])))
            
            cCodCli := cCodCli + Space(nTamCli - Len(cCodCli))
            cLoja := cLoja + Space(nTamLoja - Len(cLoja))
            
            
            If nI == 1 
                  cExpCli :=  '%  ABS_CODIGO + ABS_LOJA IN (' + "'" + cCodCli +  cLoja +  "'"   
            Else  
                  cExpCli := cExpCli +  ",'" + cCodCli +  cLoja +  "'"                         
            EndIf
            
            If nI == Len(aClientes)
                  cExpCli := cExpCli + ")%"
            EndIf
            
      
      Next nI
      

      //-- Locais
      aPlaces := Separa(Self:cPlaces, ',')
      
      nTamPlace := TamSX3('ABS_LOCAL')[1]
      
      //Inclui os locais dos supervisores
      If lSuperv      
            aSuperv := Separa(Self:cSupervisor,',')
            nTamSuperv := TamSX3('AA1_CODTEC')[1]
            TecFilterTXI(aSuperv,@aPlaces,nTamSuperv,nTamPlace) 
      EndIf 

      For nI := 1 To Len(aPlaces)
            cPlace      := aPlaces[nI]    
            cPlace := cPlace + Space(nTamPlace - Len(cPlace))    
            
            If nI == 1
                  cExpPla :=  '%  ABS_LOCAL IN (' + "'" + cPlace +  "'"      
            Else  
                  cExpPla := cExpPla +  ",'" + cPlace +  "'"                       
            EndIf
                  
            If nI == Len(aPlaces)
                  cExpPla := cExpPla + ")%"
            EndIf
            
      Next nI
      
      //-- Regiões
      aRegions := Separa(Self:cRegions, ',')
      
      nTamRegion := TamSX3('ABS_REGIAO')[1]
      
      For nI := 1 To Len(aRegions)
            cRegion     := aRegions[nI]   
            cRegion := cRegion + Space(nTamRegion - Len(cRegion))      
            
            If nI == 1
            	cExpReg :=  '%  ABS_REGIAO IN (' + "'" + cRegion +  "'"    
            Else  
            	cExpReg := cExpReg +  ",'" + cRegion +  "'"                      
            EndIf 
            
            If nI == Len(aRegions)
            	cExpReg := cExpReg + ")%"
            EndIf
      Next nI
      
      If Empty(Self:cStart) 
      	Self:cStart := '00:00'
      EndIf
      
      If Empty(Self:cEnd)
   	  	Self:cEnd := '23:59'
   	  EndIf 	
   
       cExpHr := "%(ABB_HRINI BETWEEN  '" + Self:cStart + "' AND  '" + Self:cEnd + "'  AND ABB_HRINI <= '" +  cTime + "  ' AND ABB.ABB_CHEGOU <> 'S' OR "
       cExpHr += " (ABB_HRFIM BETWEEN '" +  Self:cStart + "' AND  '" + Self:cEnd  + "' AND  ABB_HRFIM  <= '" +  cTime + "  ' AND ABB.ABB_CHEGOU <> 'S'))%"
    
   	   cExpAlert := "% ( (ABB_HRINI BETWEEN  '" + Self:cStart + "' AND  '" + Self:cEnd + "') OR "
   	   cExpAlert += " (ABB_HRFIM BETWEEN '" +  Self:cStart + "' AND  '" + Self:cEnd  + "') )%"
      
      //-- 1 = sem pendencia, 2 = com pendencia, 3 = Alerta
      Do Case 
            Case Self:nSituation == 1
                  BeginSQL Alias cTemp
            
                        SELECT ABS_LOCAL, ABS_DESCRI, ABS_LATITU, ABS_LONGIT,  '00:00' ABB_HRINI , '00:00' ABB_HRFIM , '' ABB_CHEGOU, '' ABB_SAIU, '1' TIPO  FROM %Table:ABS% ABS         
                        WHERE ABS.ABS_FILIAL  = %Exp:xFilial("ABS")%
                              AND %exp:cExpCli%
                              AND   %exp:cExpPla%
                              AND   %exp:cExpReg%
                              AND ABS.%NotDel%
                              AND  ABS.ABS_LATITU <> '' 
                              AND  ABS.ABS_LONGIT  <> ''
                              AND EXISTS(
                                   SELECT 1 FROM %Table:ABB% ABB
                                         WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%                                      
                                                     AND ABB.%NotDel%
                                                     AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
                                                     AND ABB.ABB_DTINI = %Exp:dDataBase%
                                                     AND ABB.ABB_ATIVO = 1                                                                                                                                                                                                                                            
                                         )
                              AND NOT EXISTS (
                                           SELECT 1 FROM  %Table:ABB% ABB
                                                     WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%                                                    
                                                     AND ABB.%NotDel%
                                                     AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
                                                     AND ABB.ABB_DTINI = %Exp:dDataBase%
                                                     AND ABB.ABB_ATIVO = 1
                                                     AND  %exp:cExpHr%)                                                                                                     
                  EndSql
            
            Case Self:nSituation == 2
            
                  BeginSQL Alias cTemp
            
                        SELECT ABS_LOCAL, ABS_DESCRI, ABS_LATITU, ABS_LONGIT,  '00:00' ABB_HRINI , '00:00' ABB_HRFIM , '' ABB_CHEGOU, '' ABB_SAIU, '2' TIPO  FROM %Table:ABS% ABS         
                        WHERE ABS.ABS_FILIAL  = %Exp:xFilial("ABS")%
                              AND %exp:cExpCli%
                              AND %exp:cExpPla%
                              AND %exp:cExpReg%
                              AND ABS.%NotDel%                                                       
                              AND ABS.ABS_LATITU <> '' 
                              AND ABS.ABS_LONGIT <> ''                                               
                              AND EXISTS (
                                           SELECT 1 FROM %Table:ABB% ABB
                                                     WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%
                                                     AND ABB.%NotDel%                                                                              
                                                     AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
                                                     AND ABB.ABB_DTINI = %Exp:dDataBase%
                                                     AND ABB.ABB_ATIVO = 1   
                                                     AND   %exp:cExpHr%)                                                    
            EndSql
            
            
                             
            Case Self:nSituation == 3
                        BeginSQL Alias cTemp
            
                  SELECT ABS_LOCAL, ABS_DESCRI, ABS_LATITU, ABS_LONGIT,  '00:00' ABB_HRINI , '00:00' ABB_HRFIM , '' ABB_CHEGOU, '' ABB_SAIU, '1' TIPO  FROM %Table:ABS% ABS         
                        WHERE ABS.ABS_FILIAL  = %Exp:xFilial("ABS")%
                              AND %exp:cExpCli%
                              AND %exp:cExpPla%
                              AND %exp:cExpReg%
                              AND ABS.%NotDel%
                              AND ABS.ABS_LATITU <> '' 
                              AND ABS.ABS_LONGIT <> '' 
                              AND EXISTS(
                                   SELECT 1 FROM %Table:ABB% ABB
                                         WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%
                                                     AND ABB.%NotDel%
                                                     AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
                                                     AND ABB.ABB_DTINI = %Exp:dDataBase%
                                                     AND ABB.ABB_ATIVO = 1                                                                                                                        
                                         )
                              AND NOT EXISTS (
                                           SELECT 1 FROM  %Table:ABB% ABB
                                                     WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%
                                                     AND ABB.%NotDel%
                                                     AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
                                                     AND ABB.ABB_DTINI = %Exp:dDataBase%
                                                     AND ABB.ABB_ATIVO = 1
                                                     AND   %exp:cExpHr%)                                                     
                  UNION                                                
                  
                        
                  SELECT ABS_LOCAL, ABS_DESCRI, ABS_LATITU, ABS_LONGIT,  '00:00' ABB_HRINI , '00:00' ABB_HRFIM , '' ABB_CHEGOU, '' ABB_SAIU, '2' TIPO  FROM %Table:ABS% ABS         
                        WHERE ABS.ABS_FILIAL  = %Exp:xFilial("ABS")%
                              AND %exp:cExpCli%
                              AND %exp:cExpPla%
                              AND %exp:cExpReg%
                              AND ABS.%NotDel%                                                       
                              AND ABS.ABS_LATITU <> '' 
                              AND ABS.ABS_LONGIT <> ''                                               
                              AND EXISTS (
                                           SELECT 1 FROM %Table:ABB% ABB
                                                     WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%
                                                     AND ABB.%NotDel%                                                                              
                                                     AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
                                                     AND ABB.ABB_DTINI = %Exp:dDataBase%
                                                     AND ABB.ABB_ATIVO = 1   
                                                     AND   %exp:cExpHr%)                                                                                                               
            EndSql
                        
            
      EndCase           
      
      If Self:nSituation == 2 .Or. Self:nSituation == 3  
            If !Empty(Self:cMinutes) .And. Self:cMinutes <> '0'
                  BeginSQL Alias cTempAlerta
      
                 SELECT ABS_LOCAL, ABS_DESCRI, ABS_LATITU, ABS_LONGIT, ABB_HRINI , ABB_HRFIM , ABB_CHEGOU, ABB_SAIU, '3' TIPO   FROM %Table:ABB% ABB                                   
                       INNER JOIN %Table:ABS% ABS ON ABB.ABB_FILIAL = %Exp:xFilial("ABB")% AND ABS.%NotDel% AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
                       WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%
                       AND %exp:cExpCli%
                       AND %exp:cExpPla%                  
                       AND %exp:cExpReg%                                          
                       AND ABS.ABS_LATITU <> '' 
                                 AND ABS.ABS_LONGIT <> ''                                 
                       AND ABB.ABB_DTINI = %Exp:dDataBase%                       
                       AND ABB_ATIVO = 1
                       AND %Exp:cExpAlert%                                   
                       AND ABB.%NotDel%                   
                  EndSql
                             
                  ( cTempAlerta )->( DBGoTop() )
                  nMinutes := Val(Self:cMinutes)
                  
                  If nMinutes > 60
                        While nMinutes > 60
                             nHour := nHour + 1
                             nMinutes := nMinutes - 60          
                        EndDo
                        Self:cMinutes := Alltrim(Str(nHour)) + ":" + Alltrim(Str(nMinutes))
                  Else
                        Self:cMinutes := Alltrim(Str(nMinutes / 100))                                                                   
                  EndIf 

                  cTime := Time()
                  
                  While ( cTempAlerta )->( !Eof() )                                                  
                        nDiffIn :=  SubHoras(( cTempAlerta )->ABB_HRINI, cTime )
                        nDiffOut :=  SubHoras(( cTempAlerta )->ABB_HRFIM, cTime )                                                                                               
                        
                        If aScan(aLocais, {|x| x[1] ==( cTempAlerta )->ABS_LOCAL}) == 0                    
                             If (( cTempAlerta )->ABB_CHEGOU <> 'S' .And. (cTime < ( cTempAlerta )->ABB_HRINI) .And.  nDiffIn <= Val(StrTran(Self:cMinutes,':','.'))) .Or.;
                                   (( cTempAlerta )->ABB_SAIU <> 'S'  .And. (cTime < ( cTempAlerta )->ABB_HRFIM) .And. nDiffOut <= Val(StrTran(Self:cMinutes,':','.')))
                                   Aadd(aLocais, {( cTempAlerta )->ABS_LOCAL,( cTempAlerta )->ABS_DESCRI, ( cTempAlerta )->ABS_LATITU,  (cTempAlerta )->ABS_LONGIT})
                             EndIf
                        EndIf
                        
                        ( cTempAlerta )->( DBSkip() )      
                  EndDo
            EndIf
      EndIf                   
                  
      If ( cTemp )->( !Eof() )
                  
            
            //-------------------------------------------------------------------
            // Identifica a quantidade de registro no alias temporário.    
            //-------------------------------------------------------------------
            //count TO nRecord
            
            //-------------------------------------------------------------------
            // Posiciona no primeiro registro.  
            //-------------------------------------------------------------------  
            ( cTemp )->( DBGoTop() )                 
                        
            
            cResponse := ''
            cResponse := '{"stations":[' 
                  
                  
            While ( cTemp )->( !Eof() )              
                  //-------------------------------------------------------------------
                  // Incrementa o contador.  
                        //-------------------------------------------------------------------                                                                   
                  If ( cTemp )->TIPO == '1'          
                        If aScan(aLocais,{|x| Alltrim(x[1]) ==  Alltrim(( cTemp )->ABS_LOCAL)}) == 0      
                             If nCount > 0
                                   cResponse += ','
                             EndIf                                                            
                             cResponse += '{"code":"' + Alltrim(( cTemp )->ABS_LOCAL) + '",'                                     
                             cResponse += '"desc":"' + EncodeUTF8(Alltrim(( cTemp )->ABS_DESCRI)) + '",'
                             cResponse += '"type":"' + Alltrim(( cTemp )->TIPO) + '",'
                             cResponse += '"lat":"' + Alltrim(( cTemp )->ABS_LATITU) + '",'
                             cResponse += '"long":"' + Alltrim(( cTemp )->ABS_LONGIT) + '"}'
                        
                             nCount += 1                             
                        EndIf
                        ( cTemp )->( DBSkip() )      
                  ElseIf ( cTemp )->TIPO == '2' 
                             If nCount > 0
                                   cResponse += ','
                             EndIf       
                             cResponse += '{"code":"' + Alltrim(( cTemp )->ABS_LOCAL) + '",'                                     
                             cResponse += '"desc":"' + EncodeUTF8(Alltrim(( cTemp )->ABS_DESCRI)) + '",'
                             cResponse += '"type":"' + Alltrim(( cTemp )->TIPO) + '",'
                             cResponse += '"lat":"' + Alltrim(( cTemp )->ABS_LATITU) + '",'
                             cResponse += '"long":"' + Alltrim(( cTemp )->ABS_LONGIT) + '"}'
                             
                             nCount += 1
                             Aadd(aLocaisPen, Alltrim(( cTemp )->ABS_LOCAL))
                             ( cTemp )->( DBSkip() )
                                                     
                  ElseIf ( cTemp )->TIPO == '3'                                          
                        If !Empty(Self:cMinutes) .And. Self:cMinutes <> '0' 
                             If aScan(aLocais, {|x| x[1] ==( cTemp )->ABS_LOCAL}) == 0                    
                                   If (( cTemp )->ABB_CHEGOU <> 'S' .And. (Time() < ( cTemp )->ABB_HRINI) .And.  SubHoras(( cTemp )->ABB_HRINI, Time() ) * 100 <= Val(Self:cMinutes)) .Or.;
                                   (( cTemp )->ABB_SAIU <> 'S'  .And. (Time() < ( cTemp )->ABB_HRFIM) .And. SubHoras(( cTemp )->ABB_HRFIM, Time() ) * 100 <= Val(Self:cMinutes)) 
                                         Aadd(aLocais, {( cTemp )->ABS_LOCAL,( cTemp )->ABS_DESCRI, ( cTemp )->ABS_LATITU,  (cTemp )->ABS_LONGIT})
                                   EndIf
                             EndIf
                        EndIf 
                        ( cTemp )->( DBSkip() ) 
                  EndIf 
            EndDo       
            
            If (Self:nSituation == 3) .Or. (Self:nSituation == 2)                       
                  nLen := Len(aLocais) 
                  If nLen > 0                  
                        
                        For nI := 1 To nLen
                             If aScan(aLocaisPen, Alltrim(aLocais[nI,1])) == 0
                                   If  nCount > 0 
                                         cResponse += ','
                                   EndIf
                                   cResponse += '{"code":"' + Alltrim(aLocais[nI,1]) + '",'                                     
                                   cResponse += '"desc":"' + EncodeUTF8(Alltrim(aLocais[nI,2])) + '",'
                                   cResponse += '"type":"3",'
                                   cResponse += '"lat":"' + Alltrim(aLocais[nI,3]) + '",'
                                   cResponse += '"long":"' + Alltrim(aLocais[nI,4]) + '"}'
                                   nCount += 1
                             EndIf 
                             
                        Next nI           
                                               
                  EndIf
            EndIf                                                                            
      
            
            cResponse += ' ], '                      
            cResponse += '"count": ' +cBIStr( nCount ) + ' } '
                  
      EndIf
      
      Self:SetResponse( cResponse )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf


Return( lRet ) 



//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------

WSMETHOD GET appointments WSRECEIVE cStation, cStart, cEnd, cMinutes, cDataApont WSREST SUPERVISORGS
Local cIdUserRole       := "" 
Local cDescription      := ""
Local cSelected         := ""
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "appointments":[], "count": 0 }'   
Local nRecord           := 0
Local ncount            := 0
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local lRet              := .T.
Local cDtIni            := ""
Local aLocais           := {}
Local nI                := 1
Local cDtIni            := "" 
Local cTime             := ""
Local cLate             := "2"
Local cExpHr            := "%0 = 0%"
Local cObsMan           := ""
Local nDiffIn           := 0
Local nDiffOut          := 0
Local cAlert            := ""
Local lOk               := .T.
Local dData             := dDataBase

// Define o tipo de retorno do método    
Self:SetContentType("application/json")

If Empty(Self:cStation) 
      lRet := .F.
      cMessage := "Informe o local de atendimento"
EndIf 

If !Empty(Self:cDataApont) 
   dData := StoD(Self:cDataApont)
EndIf

If lRet     

      If !Empty(Self:cStart) .And. !Empty(Self:cEnd)  
            cExpHr := "% ((ABB_HRINI >= '" + Self:cStart + "' OR ABB_HRFIM >= '" + Self:cStart + "') OR "
            cExpHr += "(ABB_HRFIM <= '" +  Self:cEnd + "' OR ABB_HRINI <= '" + Self:cEnd  + "'))%"
      ElseIf !Empty(Self:cStart)
            cExpHr:= "% (ABB_HRINI >= '" + Self:cStart + "' OR ABB_HRFIM >= '" + Self:cStart + "')%"
      ElseIf !Empty(Self:cEnd)     
            cExpHr := "% (ABB_HRFIM <= '" +  Self:cEnd + "' OR ABB_HRINI <= '" + Self:cEnd  + "')%"
      EndIf
                                   
      BeginSQL Alias cTemp
      
            SELECT ABB_CODIGO, ABB_LOCAL, AA1.AA1_NOMTEC,  ABB.ABB_DTINI, ABB.ABB_HRINI, ABB.ABB_HRFIM,ABB_HRCHIN, ABB_HRCOUT, ABB.ABB_CHEGOU, ABB.ABB_SAIU, ABB.ABB_MANIN, ABB.ABB_MANOUT FROM %Table:ABB% ABB      
                  INNER JOIN %Table:AA1% AA1 ON AA1.AA1_FILIAL = %Exp:xFilial("AA1")% AND AA1.%NotDel% AND AA1.AA1_CODTEC = ABB.ABB_CODTEC                                    
                  WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%               
                        AND ABB.ABB_DTINI = %Exp:dData%
                        AND ABB.ABB_LOCAL  = %Exp:Self:cStation%
                        AND   %exp:cExpHr%
                        AND ABB_ATIVO = 1                        
                        AND ABB.%NotDel%                               
      EndSql
      
      If ( cTemp )->( !Eof() )
            
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
            
            
            cTime := Time()
            While ( cTemp )->( !Eof() )
                                   
                  cLate := "2"
                  cAlert := "2"
                  cObsMan := ""
                  lOk := .T.
                  
                  nDiffIn :=  SubHoras(( cTemp )->ABB_HRINI, Time() )
                  nDiffOut :=  SubHoras(( cTemp )->ABB_HRFIM, Time() )                                                                                               
                                               
                  //-- Entrada --//
                        If !Empty(Self:cStart) .And. !Empty(Self:cEnd)
                             lOk := ( cTemp )->ABB_HRINI >= Self:cStart .And. ( cTemp )->ABB_HRINI <= Self:cEnd
                        ElseIf !Empty(Self:cStart)
                             lOk :=  ( cTemp )->ABB_HRINI >= Self:cStart
                        ElseIf !Empty(Self:cEnd)
                             lOk :=  ( cTemp )->ABB_HRINI <= Self:cEnd
                        EndIf
                        
                        If lOk 
                             nRecord++
                             If nRecord > 1
                                   cResponse += ','
                             EndIf 
                             If (( cTemp )->ABB_CHEGOU <> 'S' .And. (cTime < ( cTemp )->ABB_HRINI) .And.  nDiffIn <= Val(StrTran(Self:cMinutes,':','.')))                
                                   cAlert := '1'
                             EndIf                                    
                             
                             If cTime > ( cTemp )->ABB_HRINI .And.  ( cTemp )->ABB_CHEGOU <> 'S'   
                                   cLate := "1"                                                                      
                             EndIf                                                                                   
                             
                             cObsMan := ""
                             If ( cTemp )->ABB_MANIN == 'S'                             
                                   cObsMan := Alltrim( Posicione("ABB",8,xFilial("ABB")+( cTemp )->ABB_CODIGO,"ABB_OBSMIN") )
                             EndIf
                                   
                             cResponse += '{"code":"' + Alltrim(( cTemp )->ABB_CODIGO) + '",'                                     
                             cResponse += '"attendant":"' + Alltrim(( cTemp )->AA1_NOMTEC) + '",'
                             cResponse += '"schedule":"' + Alltrim(( cTemp )->ABB_HRINI) + '",'                                                                                                                                                                                            
                             cResponse += '"realschedule":"' + Alltrim(( cTemp )->ABB_HRCHIN) + '",'
                             cResponse += '"inout":"1",'
                             cResponse += '"alert": "' + cAlert  +'",' 
                             cResponse += '"desc":"' + EncodeUTF8("Entrada") +'",'
                             cResponse += '"late":"' + Alltrim(cLate) + '",'
                             cResponse += '"maintenance":"' + Alltrim(( cTemp )->ABB_MANIN) + '",'                       
                             cResponse += '"obsmaintenance":"' + Alltrim(cObsMan) + '",'
                             cResponse += '"executed":"' + ( cTemp )->ABB_CHEGOU + '"}'
                        EndIf                              
                  
                  //-- Saida --//
                        cLate := "2"
                        cAlert := "2"
                        lOk := .T.
                        
                        If !Empty(Self:cStart) .And. !Empty(Self:cEnd)
                             lOk := ( cTemp )->ABB_HRFIM >= Self:cStart .And. ( cTemp )->ABB_HRFIM <= Self:cEnd
                        ElseIf !Empty(Self:cStart) .And. Empty(Self:cEnd)
                             lOk :=  ( cTemp )->ABB_HRFIM >= Self:cStart                      
                        ElseIf Empty(Self:cStart) .And. !Empty(Self:cEnd)
                             lOk :=  ( cTemp )->ABB_HRFIM <= Self:cEnd
                        EndIf
                        
                  
                  
                        If lOk
                             nRecord++
                             If nRecord > 1
                                   cResponse += ','
                             EndIf                                                                        
                             
                             If (( cTemp )->ABB_SAIU <> 'S'  .And. (Time() < ( cTemp )->ABB_HRFIM) .And. SubHoras(( cTemp )->ABB_HRFIM, Time() ) * 100 <= Val(Self:cMinutes))
                                   cAlert := '1'
                             EndIf 
                             
                             If cTime > ( cTemp )->ABB_HRFIM .And.  ( cTemp )->ABB_SAIU <> 'S'
                                   cLate := "1"                                                                      
                             EndIf
                             
                             cObsMan := ""
                             If ( cTemp )->ABB_MANIN == 'S'
                                   cObsMan := Alltrim( Posicione("ABB",8,xFilial("ABB")+( cTemp )->ABB_CODIGO,"ABB_OBSMOU") )
                             EndIf
                                   
                             cResponse += '{"code":"' + Alltrim(( cTemp )->ABB_CODIGO) + '",'                                     
                             cResponse += '"attendant":"' + Alltrim(( cTemp )->AA1_NOMTEC) + '",'
                             cResponse += '"schedule":"' + Alltrim(( cTemp )->ABB_HRFIM) + '",'
                             cResponse += '"realschedule":"' + Alltrim(( cTemp )->ABB_HRCOUT) + '",'
                             cResponse += '"inout":"2",'
                             cResponse += '"alert": "' + cAlert  +'",'
                             cResponse += '"desc":"' + EncodeUTF8("Saída") +'",'
                             cResponse += '"late":"' + Alltrim(cLate) + '",'                                                                                                                                                                           
                             cResponse += '"maintenance":"' + Alltrim(( cTemp )->ABB_MANOUT) + '",'
                             cResponse += '"obsmaintenance":"' + Alltrim(cObsMan) + '",'
                             cResponse += '"executed":"' + ( cTemp )->ABB_SAIU + '"}'
                                                                                                                                             
                  EndIf
                  ( cTemp )->( DBSkip() )      
            EndDo
                  
      
            cResponse += ' ], '                      
            cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
                  
                                   
      EndIf
      
      Self:SetResponse( cResponse )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf

Return( lRet ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------

WSMETHOD GET checkin WSRECEIVE cCode,cInOut WSREST SUPERVISORGS
Local cIdUserRole := "" 
Local cDescription      := ""
Local cSelected         := ""
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "checkin":[], "count": 0 }'  
Local nRecord           := 0
Local ncount            := 0
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local lRet              := .T.
Local cDtIni            := ""
Local aLocais           := {}
Local nI                := 1  
Local cObs              := ""
Local cImage            := ""
Local aAreaABB          := ABB->(GetArea())
Local aAreaABS          := ABS->(GetArea())
Local lUsePhoto

dbSelectArea('ABB')     
ABB->(dbSetOrder(8))
ABB->(DbSeek(XFilial("ABB")+ self:cCode))

lUsePhoto := Posicione("ABS",1,xFilial("ABS") + ABB->ABB_LOCAL,"ABS_CHFOTO") != "2" .And. !(ABB->ABB_CHEGOU == 'S' .AND. ABB->ABB_SAIU == 'S' .AND. Empty(ABB->ABB_LATOUT) )    

RestArea(aAreaABB)
RestArea(aAreaABS)

// Define o tipo de retorno do método    
Self:SetContentType("application/json")

If Empty(Self:cCode) 
      lRet := .F.
      cMessage := "Informe o código da agenda"
EndIf 
      
If lRet
      If lUsePhoto                 
            If Self:cInOut == '1'
                  BeginSQL Alias cTemp
                  SELECT ABB_CODIGO, ABB_LATIN LAT, ABB_LONIN LON, ABB_HRINI, ABB_HRCHIN HORA, T48_TIPO, T48_ITEM FROM %Table:ABB% ABB         
                        INNER JOIN %Table:T48% T48 ON T48.T48_FILIAL = %Exp:xFilial("T48")% AND T48.%NotDel% AND T48.T48_CODABB = ABB.ABB_CODIGO                                        
                        WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%                                       
                             AND ABB.ABB_CODIGO  = %Exp:Self:cCode%
                             AND ABB_ATIVO = 1
                             AND T48.T48_TIPO IN ('1','3')                              
                             AND ABB.%NotDel%                               
                             ORDER BY T48.T48_TIPO
                  EndSql
            Else
                  BeginSQL Alias cTemp
                  SELECT ABB_CODIGO, ABB_LATOUT LAT, ABB_LONOUT LON, ABB_HRFIM, ABB_HRCOUT HORA, T48_TIPO, T48_ITEM FROM %Table:ABB% ABB
                        INNER JOIN %Table:T48% T48 ON T48.T48_FILIAL = %Exp:xFilial("T48")% AND T48.%NotDel% AND T48.T48_CODABB = ABB.ABB_CODIGO                                        
                        WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%                                       
                             AND ABB.ABB_CODIGO  = %Exp:Self:cCode%
                             AND ABB_ATIVO = 1
                             AND T48.T48_TIPO IN ('2','4')                              
                             AND ABB.%NotDel%  
                             ORDER BY T48.T48_TIPO                          
                  EndSql
            
            EndIf
      Else
      
            If Self:cInOut == '1'
                  BeginSQL Alias cTemp
                  SELECT ABB_CODIGO, ABB_LATIN LAT, ABB_LONIN LON, ABB_HRINI, ABB_HRCHIN HORA FROM %Table:ABB% ABB                                              
                        WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%                                       
                             AND ABB.ABB_CODIGO  = %Exp:Self:cCode%
                             AND ABB_ATIVO = 1                  
                             AND ABB.%NotDel%                               
                  EndSql
            Else
                  BeginSQL Alias cTemp
                  SELECT ABB_CODIGO, ABB_LATOUT LAT, ABB_LONOUT LON, ABB_HRFIM, ABB_HRCOUT HORA, ABB_HRCHIN HORAIN  FROM %Table:ABB% ABB                                
                        WHERE ABB.ABB_FILIAL  = %Exp:xFilial("ABB")%                                       
                             AND ABB.ABB_CODIGO  = %Exp:Self:cCode%
                             AND ABB_ATIVO = 1            
                             AND ABB.%NotDel%                               
                  EndSql
            
            EndIf
      
      EndIf 
      
      If ( cTemp )->( !Eof() )
            
            //-------------------------------------------------------------------
            // Identifica a quantidade de registro no alias temporário.    
            //-------------------------------------------------------------------
            count TO nRecord
            
            //-------------------------------------------------------------------
            // Posiciona no primeiro registro.  
            //-------------------------------------------------------------------  
            ( cTemp )->( DBGoTop() )                 
                                   
            cResponse := ''
            cResponse := '{"checkin":['  
                                               
                  //-------------------------------------------------------------------
                  // Incrementa o contador.  
                  //-------------------------------------------------------------------                                                                   
                                                                                                          
            cResponse += '{"lat":"' + Alltrim(( cTemp )->LAT) + '",'                                      
            cResponse += '"long":"' + Alltrim(( cTemp )->LON) + '",'
            cResponse += '"protheusCheckin":"' + IIF(EMPTY(Alltrim(( cTemp )->LON)), '1', '2') + '",'
            If Self:cInOut == '1'
                  cResponse += '"hr":"' + Alltrim(( cTemp )->HORA) + '",'
            Else
                  cResponse += '"hr":"' + IIF(EMPTY(Alltrim(( cTemp )->LON)), Alltrim(( cTemp )->HORAIN) ,Alltrim(( cTemp )->HORA)) + '",'
            EndIf
            
            If Self:cInOut == '1'        
                  cObs := Alltrim( Posicione("ABB",8,xFilial("ABB")+( cTemp )->ABB_CODIGO,"ABB_OBSIN") )
            Else
                  cObs := Alltrim( Posicione("ABB",8,xFilial("ABB")+( cTemp )->ABB_CODIGO,"ABB_OBSOUT") )
            EndIf 
            
            cResponse += '"obs":"' + Alltrim(cObs) + '",'
            If lUsePhoto
                  cImage := Alltrim( Posicione("T48",1,xFilial("T48")+( cTemp )->ABB_CODIGO + ( cTemp )->T48_ITEM,"T48_FOTO") )
            EndIf
            cResponse += '"selfie":"' + Alltrim(cImage) + '",'
            ( cTemp )->( DBSkip() )            
            
            
            cResponse += '"additionalphotos": [
            If lUsePhoto
                  While ( cTemp )->( !Eof() )                                
                             
                        cImage := Alltrim( Posicione("T48",1,xFilial("T48")+( cTemp )->ABB_CODIGO + ( cTemp )->T48_ITEM,"T48_FOTO") )
                                                           
                        cResponse += '{"image":"' + Alltrim(cImage)  + '"}'                                                       
                             
                        ( cTemp )->( DBSkip() )
                        
                        If  ( cTemp )->( !Eof() )
                             cResponse += ','             
                        Else
                             //cResponse += ' ] '                     
                        EndIf
                  EndDo
            EndIf

            cResponse += ' ]}], '                    
            cResponse += '"count": ' +cBIStr( nRecord ) + ' } '
                  
                                   
      EndIf
      
      Self:SetResponse( cResponse )
Else
      SetRestFault( nStatusCode, EncodeUTF8(cMessage) )                      
EndIf

Return( lRet ) 

      
//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------
WSMETHOD POST operationalDecision WSREST SUPERVISORGS      
Local cTemp             := GetNextAlias()
Local cResponse         := '{"status":"ok"}'    
Local nRecord                := 0
Local ncount                 := 0
Local cMessage          := "Internal Server Error"
Local nStatusCode       := 500
Local lRet                   := .F.
Local cBody                  := ""
Local lExit                  := .F.
Local aDist                  := {}
Local oOppJson               := Nil
  
cBody := Self:GetContent()
            
If !Empty( cBody )
      
      FWJsonDeserialize(cBody,@oOppJson) 
      
      If !Empty( oOppJson )                    
            lRet := .T.       
      EndIf                   
End

Self:SetContentType("application/json")

If lRet .And. (Empty(oOppJson:cCode))
      lRet := .F.
      nStatusCode := 400
      cMessage := "Informe o Código da ABB
EndIf


If lRet           
      
      lRet := .F.

      dbSelectArea('ABB')     
      ABB->(dbSetOrder(8))
      
      If ABB->(DbSeek(XFilial("ABB")+ oOppJson:cCode))
            BEGIN TRANSACTION                              
                  
                  RecLock("ABB",.F.)                                               
                  If oOppJson:cInOut == '1'
                        ABB->ABB_MANIN:= 'S'
                        If !Empty(oOppJson:cObs)
                             ABB->ABB_OBSMIN := oOppJson:cObs
                        EndIf 
                        ABB->(MsUnlock())       
                        lRet := .T.             
                  ElseIf oOppJson:cInOut == '2'
                        ABB->ABB_MANOUT:= 'S'
                        If !Empty(oOppJson:cObs)
                             ABB->ABB_OBSMOU := oOppJson:cObs
                        EndIf 
                        ABB->(MsUnlock())       
                        lRet := .T.             
                  EndIf 
                             
            END TRANSACTION
      EndIf 
            
                  
      If !lRet
            nStatusCode := 400
            cMessage := "Não foi possível atualizar a agenda do atendente (ABB)"
      EndIf       
EndIf
      
If lRet
      Self:SetResponse( cResponse )
Else 
      SetRestFault( nStatusCode, EncodeUTF8(cMessage))
EndIf 

Return( lRet ) 



//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------

WSMETHOD GET regions WSREST SUPERVISORGS
Local cIdUserRole       := "" 
Local cDescription      := ""
Local cSelected         := ""
Local cResponse         := '{ "regions":[], "count": 0 }'  
Local nRecord           := 0
Local ncount            := 0
Local cMessage          := "Internal Server Error"
Local nStatusCode := 500
Local lRet             := .T.
Local cDtIni            := ""
Local aLocais           := {}
Local nI                := 1  

// Define o tipo de retorno do método    
Self:SetContentType("application/json")

      
cResponse := '{"regions":['  
            
cResponse += '{"code":"001",'
cResponse += '"desc":"Norte"},'

cResponse += '{"code":"002",'
cResponse += '"desc":"Sul"},'

cResponse += '{"code":"003",'
cResponse += '"desc":"Leste"},'

cResponse += '{"code":"004",'
cResponse += '"desc":"Oeste"},'

cResponse += '{"code":"005",'
cResponse += '"desc":"Centro"},'

cResponse += '{"code":"006",'
cResponse += '"desc":"Centro oeste"}],'
                                                                      
cResponse += '"count": 5 } '
            


Self:SetResponse( cResponse )


Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------
WSMETHOD GET places  WSRECEIVE nPage, nPageSize,cSearchTerm WSREST SUPERVISORGS
Local cIdUserRole := "" 
Local cDescription      := ""
Local cSelected         := ""
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "places":[], "count": 0 }'   
Local nRecord           := 0
Local ncount            := 0
Local cMessage          := "Internal Server Error"
Local nStatusCode := 500
Local lRet             := .T.
Local cDtIni            := ""
Local aLocais           := {}
Local nI                := 1  
Local cObs              := ""
Local cImage            := ""
Local nQtdRegIni := 0
Local nQtdRegFim  := 0
Local nQtdReg           := 0
Local lHasNext          := .F.
Local cFilter           := "%0 = 0%"

If Self:nPage == 0
      Self:nPage := 1
EndIf

      
If Self:nPageSize == 0
      Self:nPageSize := 1
EndIf  

nQtdRegIni := ((Self:nPage-1) * Self:nPageSize)
// Define o range para inclusão no JSON
nQtdRegFim := (Self:nPage * Self:nPageSize)
nQtdReg    := 0

If !Empty(Self:cSearchTerm)
      cFilter :=  "% (UPPER(ABS.ABS_LOCAL) LIKE '%"  + UPPER(Self:cSearchTerm) + "%' OR UPPER(ABS.ABS_DESCRI) LIKE '%"  + UPPER(Self:cSearchTerm) + "%')%"
EndIf 

// Define o tipo de retorno do método    
Self:SetContentType("application/json")


BeginSQL Alias cTemp
      SELECT ABS_LOCAL, ABS_DESCRI FROM %Table:ABS% ABS                                                         
      WHERE ABS.ABS_FILIAL  = %Exp:xFilial("ABS")%
            AND %Exp:cFilter%                                                                                                     
            AND ABS.%NotDel%                               
EndSql


If ( cTemp )->( !Eof() )
      
      //-------------------------------------------------------------------
      // Identifica a quantidade de registro no alias temporário.    
      //-------------------------------------------------------------------
      count TO nRecord
      
      //-------------------------------------------------------------------
      // Posiciona no primeiro registro.  
      //-------------------------------------------------------------------  
      ( cTemp )->( DBGoTop() )                 
                             
      cResponse := ''
      cResponse := '{"places":['   
                                         
            //-------------------------------------------------------------------
            // Incrementa o contador.  
            //-------------------------------------------------------------------       
                                                                       
      While ( cTemp )->( !Eof() )        
            nQtdReg++                                
            
            If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
                  If  nCount > 0 
                        cResponse += ','
                  EndIf
                  
                  cResponse += '{"code":"' + Alltrim(( cTemp )->ABS_LOCAL) + '",'                                     
                  cResponse += '"desc":"' + Alltrim(( cTemp )->ABS_DESCRI) + '"}'
                  nCount += 1                                                                                               
                  
            ElseIf (nQtdReg == nQtdRegFim + 1)
                  lHasNext := .T.
                  Exit                    
            EndIf 
            ( cTemp )->( DBSkip() ) 
      EndDo
      If (lHasNext)
            cResponse += '],"hasNext": "true" }'
      Else
            cResponse += '],"hasNext": "false" }'
      EndIf 
            
EndIf

Self:SetResponse( cResponse )


Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@author     Matheus Lando Raimundo
@since            29/05/2017
/*/
//------------------------------------------------------------------------------
WSMETHOD GET clients WSRECEIVE nPage, nPageSize,cSearchTerm WSREST SUPERVISORGS
Local cIdUserRole := "" 
Local cDescription      := ""
Local cSelected         := ""
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "clients":[] }'   
Local nRecord           := 0
Local nCount            := 0
Local cMessage          := "Internal Server Error"
Local nStatusCode := 500
Local lRet             := .T.
Local cDtIni            := ""
Local aLocais           := {}
Local nI                := 1  
Local cObs              := ""
Local cImage            := ""
Local nQtdRegIni := 0
Local nQtdRegFim  := 0
Local nQtdReg           := 0
Local lHasNext          := .F.
Local cFilter           := "%0 = 0%"


If !Empty(Self:cSearchTerm)
      cFilter :=  "% (UPPER(SA1.A1_COD) LIKE '%"  + UPPER(Self:cSearchTerm) + "%' OR UPPER(SA1.A1_LOJA) LIKE '%"  + UPPER(Self:cSearchTerm) +  "%' OR UPPER(SA1.A1_NOME) LIKE '%"  + UPPER(Self:cSearchTerm) + "%')%"
EndIf 


If Self:nPage == 0
      Self:nPage := 1
EndIf

      
If Self:nPageSize == 0
      Self:nPageSize := 1
EndIf  

nQtdRegIni := ((Self:nPage-1) * Self:nPageSize)
// Define o range para inclusão no JSON
nQtdRegFim := (Self:nPage * Self:nPageSize)
nQtdReg    := 0

// Define o tipo de retorno do método    
Self:SetContentType("application/json")


BeginSQL Alias cTemp
      SELECT DISTINCT A1_COD, A1_LOJA, A1_NOME FROM %Table:SA1% SA1
            INNER JOIN %Table:ABS% ABS ON ABS.ABS_FILIAL = %Exp:xFilial("ABS")% AND ABS.ABS_ENTIDA = '1' AND SA1.A1_COD =  ABS.ABS_CODIGO AND SA1.A1_LOJA = ABS.ABS_LOJA                                                                 
      WHERE SA1.A1_FILIAL  = %Exp:xFilial("SA1")%
      AND %Exp:cFilter%                                                                                   
      AND SA1.%NotDel%                               
EndSql


If ( cTemp )->( !Eof() )
      
      //-------------------------------------------------------------------
      // Identifica a quantidade de registro no alias temporário.    
      //-------------------------------------------------------------------
      
      
      //-------------------------------------------------------------------
      // Posiciona no primeiro registro.  
      //-------------------------------------------------------------------  
      ( cTemp )->( DBGoTop() )                 
                             
      cResponse := ''
      cResponse := '{"clients":['  
                                         
            //-------------------------------------------------------------------
            // Incrementa o contador.  
            //-------------------------------------------------------------------                                                                  
                                                                                                    
      While ( cTemp )->( !Eof() )
            nQtdReg++
      
            if (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
                  
                  
                  If  nCount > 0 
                        cResponse += ','
                  EndIf
                  
                  
                  cResponse += '{"code":"' + Alltrim(( cTemp )->A1_COD) + '",'                                        
                  cResponse += '"store":"' + Alltrim(( cTemp )->A1_LOJA) + '",'
                  cResponse += '"check":"false",'
                  cResponse += '"desc":"' + Alltrim(( cTemp )->A1_NOME) + '"}'
                  
                  nCount += 1                                                                  
            
            ElseIf (nQtdReg == nQtdRegFim + 1)
                  lHasNext := .T.
                  Exit                    
            EndIf
            ( cTemp )->( DBSkip() ) 
                  
      EndDo
      If (lHasNext)
            cResponse += '],"hasNext": "true" }'
      Else
            cResponse += '],"hasNext": "false" }'
      EndIf
      
            
            
EndIf

Self:SetResponse( cResponse )


Return( lRet )

//------------------------------------------------------------------------------
/*/{Protheus.doc} SUPERVISORGS

@author     Luiz Gabriel
@since      06/02/2020
/*/
//------------------------------------------------------------------------------
WSMETHOD GET supervisor  WSRECEIVE nPage, nPageSize,cSearchTerm WSREST SUPERVISORGS
Local cTemp             := GetNextAlias()
Local cResponse         := '{ "supervisor":[], "count": 0 }'   
Local nRecord           := 0
Local ncount            := 0
Local lRet              := .T.
Local nQtdRegIni        := 0
Local nQtdRegFim        := 0
Local nQtdReg           := 0
Local lHasNext          := .F.
Local cFilter           := "%0 = 0%"

If ExistFunc("TecSupTXI") .And. TecSupTXI()
      If Self:nPage == 0
            Self:nPage := 1
      EndIf
            
      If Self:nPageSize == 0
            Self:nPageSize := 1
      EndIf  

      nQtdRegIni := ((Self:nPage-1) * Self:nPageSize)
      // Define o range para inclusão no JSON
      nQtdRegFim := (Self:nPage * Self:nPageSize)
      nQtdReg    := 0

      If !Empty(Self:cSearchTerm)
            cFilter :=  "% (UPPER(AA1.AA1_CODTEC) LIKE '%"  + UPPER(Self:cSearchTerm) + "%' OR UPPER(AA1.AA1_NOMTEC) LIKE '%"  + UPPER(Self:cSearchTerm) + "%')%"
      EndIf 

      // Define o tipo de retorno do método    
      Self:SetContentType("application/json")

      BeginSQL Alias cTemp
            SELECT AA1_CODTEC, AA1_NOMTEC FROM %Table:AA1% AA1                                                         
                  WHERE AA1.AA1_FILIAL  = %Exp:xFilial("AA1")%
                  AND AA1.AA1_SUPERV = '1'
                  AND %Exp:cFilter%                                                                                                     
                  AND AA1.%NotDel%                               
      EndSql

      If ( cTemp )->( !Eof() )
                  
            //-------------------------------------------------------------------
            // Identifica a quantidade de registro no alias temporário.    
            //-------------------------------------------------------------------
            count TO nRecord
                  
            //-------------------------------------------------------------------
            // Posiciona no primeiro registro.  
            //-------------------------------------------------------------------  
            ( cTemp )->( DBGoTop() )                 
                                    
            cResponse := ''
            cResponse := '{"supervisor":['   
                                                
            //-------------------------------------------------------------------
            // Incrementa o contador.  
            //-------------------------------------------------------------------       
                                                                              
            While ( cTemp )->( !Eof() )        
                  nQtdReg++                                
                        
                  If (nQtdReg > nQtdRegIni .AND. nQtdReg <= nQtdRegFim)
                        If  nCount > 0 
                              cResponse += ','
                        EndIf
                              
                        cResponse += '{"code":"' + Alltrim(( cTemp )->AA1_CODTEC) + '",'                                     
                        cResponse += '"desc":"' + Alltrim(( cTemp )->AA1_NOMTEC) + '"}'
                        nCount += 1                                                                                               
                              
                  ElseIf (nQtdReg == nQtdRegFim + 1)
                        lHasNext := .T.
                        Exit                    
                  EndIf 
                  ( cTemp )->( DBSkip() ) 
            EndDo
            If (lHasNext)
                  cResponse += '],"hasNext": "true" }'
            Else
                  cResponse += '],"hasNext": "false" }'
            EndIf 
                        
      EndIf 
      ( cTemp )->( DbCloseArea() ) 
EndIf      

Self:SetResponse( cResponse )

Return( lRet ) 
