#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TECM010.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

Classe responsável por retornar os dados do Atendente

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------

WSRESTFUL CHECKINGS DESCRIPTION STR0001  //"CheckIn GS"

	WSDATA cAttendant AS STRING
	WSDATA cPswd AS STRING
	WSDATA cDate AS STRING
	WSDATA cBeginDate AS STRING
	WSDATA cEndDate AS STRING
	WSDATA cCodTec AS STRING
	WSDATA cIdStation AS STRING
	WSDATA cInOut AS STRING
	WSDATA cIdSchedule AS STRING
	WSDATA oSelfie AS OBJECT
	WSDATA cComments AS STRING
	WSDATA aImages AS ARRAY
	WSDATA nLatitude AS STRING
	WSDATA nLongitude AS STRING
	WSDATA cParamName AS STRING
				
	WSDATA start AS INTEGER
	WSDATA limit AS INTEGER

	WSMETHOD POST  DESCRIPTION STR0002  PATH "attendant" PRODUCES APPLICATION_JSON //"Atendente valido"
	WSMETHOD GET   DESCRIPTION STR0003  PATH "getAppointments" PRODUCES APPLICATION_JSON //"Locais de atendimento"
	WSMETHOD GET getAppointmentsByScale DESCRIPTION STR0004  PATH "getAppointmentsByScale" PRODUCES APPLICATION_JSON //"Locais de atendimento por escala"
	WSMETHOD GET getStationsByDay DESCRIPTION STR0005  PATH "getStationsByDay" PRODUCES APPLICATION_JSON //"Locais por dia"
	WSMETHOD GET getSchedules DESCRIPTION STR0006  PATH "getSchedules" PRODUCES APPLICATION_JSON //"Horarios de um determindo local"
	WSMETHOD POST putCheckIn  DESCRIPTION STR0008  PATH "putCheckIn" PRODUCES APPLICATION_JSON //"Efetiva o checkin do atendente"
	WSMETHOD GET getCheckIn  DESCRIPTION STR0009  PATH "getCheckIn" PRODUCES APPLICATION_JSON //"Dados do proximo Check-in do atendente "
	WSMETHOD POST MailForAttendant  DESCRIPTION STR0021 PATH "MailForAttendant" PRODUCES APPLICATION_JSON //"Envia as marcações para o Atendente por e-mail"
	WSMETHOD POST protheusparams  DESCRIPTION "Obter valor de um parametro no protheus"  PATH "protheusparams" PRODUCES APPLICATION_JSON 


END WSRESTFUL


//-------------------------------------------------------------------
/*/{Protheus.doc} prParams

Retorna o valor de um parâmetro, do Protheus

@author Diego Bezerra
@since 2021
/*/
//-----------------------------------------------------------------
WSMETHOD POST protheusparams WSREST CHECKINGS 

Local cResponse 	:= '{"param":""}'
Local cPar		:= ''
Local xParamContent	:= ''
Local cTypeParam	:= ''
Local oOppJson		:= Nil

cBody := Self:GetContent()

If !EMPTY( cBody )
	FWJsonDeserialize(cBody,@oOppJson) 

	If !Empty( oOppJson )  
		cPar := oOppJson:cParamName
	Else
		cPar := ''
	EndIf
ENDIF

Self:SetContentType("application/json")

If !Empty(cPar)
	xParamContent := SuperGetMV(cPar, , -1)  
	//cPar := Self:cParamName
	If !(Valtype(xParamContent)=='N' .AND. xParamContent == -1)
		cTypeParam	:= VALTYPE(xParamContent)
		cResponse := '{"param":"'+cPar+'",'
		DO CASE
			CASE cTypeParam == 'C'
				cResponse += '"content":"'+xParamContent+'"}'
				nStatusCode := 200
				lRet := .T.
			CASE cTypeParam == 'N'
				cResponse += '"content":"'+cValToChar(xParamContent)+'"}'
				nStatusCode := 200
				lRet := .T.
			CASE cTypeParam == 'D'
				cResponse += '"content":"'+DTOC(xParamContent)+'"}'
				nStatusCode := 200
				lRet := .T.
			OTHERWISE
				cMessage := STR0026 + cTypeParam + STR0027 //"O tipo de dado"### " não é suportado"
				lRet := .F.
				nStatusCode := 201
		ENDCASE
	Else
		cResponse := '{"param":"'+cPar+'",'
		cResponse += '"content":"Not found"}'
		nStatusCode := 201
	EndIf
Else
	cResponse := '{"param":"'+cPar+'",'
	cResponse += '"content":"Not found"}'
	nStatusCode := 201
EndIf

Self:SetResponse( cResponse )

return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} getContratos

Verifica se um atendente é valido

@author Matheus Lando Raimundo
@since 29/05/2017
/*/
//-----------------------------------------------------------------


WSMETHOD POST WSREST CHECKINGS	
Local cTemp			:= GetNextAlias()
Local cResponse		:= '{ "attendant":[], "count": 0 }'	
Local nRecord		:= 0
Local ncount 		:= 0
Local cMessage		:= "Internal Server Error"
Local nStatusCode	:= 500
Local lRet	 		:= .F.
Local cBody			:= ""
Local oOppJson		:= Nil
Local cEmail		:= SuperGetMV("MV_TECAPPM", ,"2") //1-ativo,2-desativado 

// MV_GSMPSAI = 2 ==> Ao realizar o checkin no app Meu posto, o ser? realiado o logoff autom?tico do atendente - (modo qui?sque)
Local nMvAutoExit	:= SuperGetMV("MV_GSMPSAI", , 1)  
 
cBody := Self:GetContent()
		
If !Empty( cBody )
	
	FWJsonDeserialize(cBody,@oOppJson) 
	
	If !Empty( oOppJson )  
		Self:cAttendant := oOppJson:cAttendant
		Self:cPswd := oOppJson:cPswd		
	End
End
				
// Define o tipo de retorno do método
Self:SetContentType("application/json")

If !Empty(Self:cAttendant) .And. !Empty(Self:cPswd) 

	BeginSQL Alias cTemp
		
		SELECT 
			AA1_CODTEC, AA1_NOMTEC
		FROM 	
			%Table:AA1% AA1
		WHERE 
			AA1.AA1_FILIAL = %Exp:xFilial("AA1")% AND
			AA1.AA1_NREDUZ = %Exp:Self:cAttendant% AND
			AA1.AA1_SENHA = %Exp:Self:cPswd% AND
			AA1.%NotDel%
	EndSql
	
	If ( cTemp )->( !Eof() )
	
		lRet := .T.
		
		//-------------------------------------------------------------------
		// Identifica a quantidade de registro no alias temporário.    
		//-------------------------------------------------------------------
		count TO nRecord
		
		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.  
		//-------------------------------------------------------------------	
		( cTemp )->( DBGoTop() )
		
		cResponse	:= ""
		cResponse	+= '{ "attendant":[ ' 
			
			
		Self:cCodTec := ( cTemp )->AA1_CODTEC
		//-------------------------------------------------------------------
		// Incrementa o contador.  
		//-------------------------------------------------------------------	
		ncount++
	
		cResponse += '{"codtec":"' + ( cTemp )->AA1_CODTEC + '",' 
		cResponse += '"nomtec":"' + ( cTemp )->AA1_NOMTEC + '",'
		cResponse += '"cemail":"' + cEmail + '",'
		cResponse += '"cautoexit":"' + CValToChar(nMvAutoExit) + '"}' 						
		cResponse += ' ] } '
		
		nStatusCode	:= 200 
	Else
		nStatusCode	:= 200
		lRet	:= .T.
		cMessage 		:= STR0010
	EndIf
	(cTemp)->(dbCloseArea())
Else
	lRet := .T.
	nStatusCode	:= 203
	cMessage 	:= STR0011 //"Necessario informar os parametros de usuario e senha do atendente"
EndIf

If lRet
	Self:SetResponse( cResponse )
Else 
	SetRestFault( nStatusCode, EncodeUTF8(cMessage))
EndIf

Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------
WSMETHOD GET WSRECEIVE cAttendant, cBeginDate, cEndDate WSREST CHECKINGS
Local cTemp				:= GetNextAlias()
Local cResponse			:= '{ "appointment":[], "count": 0 }'	
Local nRecord			:= ""
Local ncount 			:= 0
Local cMessage			:= "Internal Server Error"
Local nStatusCode		:= 500
Local lRet	 			:= .F.
Local cDtIni			:= ""
Local lMV_MultFil 		:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cQuery			:= ""

Default Self:cAttendant	:= ""

Default Self:cEndDate	:= Self:cBeginDate
 
// Define o tipo de retorno do método	
Self:SetContentType("application/json")

If !Empty(Self:cAttendant) .And. !Empty(Self:cBeginDate) 

	cQuery += "SELECT ABS.ABS_DESCRI, ABB_DTINI, ABB_DTFIM, ABB_HRINI, ABB_HRFIM"
	cQuery += " FROM "  + RetSqlName( "AA1" ) + " AA1 "
	cQuery += "INNER JOIN "  + RetSqlName( "ABB" ) + " ABB ON "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL ='"+xFilial("ABB") +"' "
	Else
		cQuery += FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.)
	EndIf
	cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' " "
		cQuery += "INNER JOIN "  + RetSqlName( "ABS" ) + " ABS ON "
	If !lMV_MultFil
		cQuery += "ABS.ABS_FILIAL ='"+xFilial("ABS") +"' "
	Else
		cQuery += FWJoinFilial("ABS" , "ABB" , "ABS", "ABB", .T.)
	EndIf
	cQuery += " AND ABB.ABB_LOCAL = ABS.ABS_LOCAL "
	cQuery += " AND ABS.D_E_L_E_T_ = ' ' " "
	cQuery += " WHERE "
	cQuery += "	AA1.AA1_FILIAL  = '" + xFilial("AA1") + "' AND "
	cQuery += " AA1.AA1_NREDUZ  = '" + Self:cAttendant + "' AND "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND"
	EndIf 				 
	cQuery += " ABB.ABB_CODTEC = AA1.AA1_CODTEC AND "
	cQuery += " ABB.ABB_DTINI BETWEEN '" + Self:cBeginDate + "' AND '" + Self:cEndDate + "' AND"  			
	cQuery += "	AA1.D_E_L_E_T_ = ' ' "
    
    cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

	If ( cTemp )->( !Eof() )
		
		lRet := .T.
		
		//-------------------------------------------------------------------
		// Identifica a quantidade de registro no alias temporário.    
		//-------------------------------------------------------------------
		count TO nRecord
		
		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.  
		//-------------------------------------------------------------------	
		( cTemp )->( DBGoTop() )
		
		cResponse	:= ""
		cResponse	+= '{ "appointments":[' 
				
		While ( cTemp )->( !Eof() )
			
			//-------------------------------------------------------------------
			// Incrementa o contador.  
			//-------------------------------------------------------------------									
			cDtIni := ( cTemp )->ABB_DTINI
			cResponse += '{"data" : ' + '"' + cDtIni + '",'							
				
			cResponse += '"stations":['
			While cDtIni == ( cTemp )->ABB_DTINI
				cResponse += '{"station":"' + EncodeUtf8(Alltrim(( cTemp )->ABS_DESCRI)) + '",'			 				
				cResponse += '"hrini":"' + ( cTemp )->ABB_HRINI + '",'
				cResponse += '"hrfim":"' + ( cTemp )->ABB_HRFIM + '"}'	
							
				ncount++
					
				( cTemp )->( DBSkip() )
				
				If  cDtIni == ( cTemp )->ABB_DTINI
					cResponse += ','
				Else
					cResponse += ']}'
				EndIf
			End
			
			If ncount < nRecord 
				cResponse += ','
			EndIf								
		End
		
		cResponse += ' ],   '
		cResponse += '"count": ' +cBIStr( nRecord ) + ' } ' 
	Else
		nStatusCode	:= 200
		lRet	:= .T.
		cMessage 		:= STR0012	 //"Nenhum local encontrado..."
	EndIf
	(cTemp)->(dbCloseArea())
Else
	nStatusCode	:= 400
	cMessage 		:= STR0013 //"Necessario informar os parametros de usuario e data da agenda"
EndIf

If lRet
	Self:SetResponse( cResponse )
Else 
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------

WSMETHOD GET getAppointmentsByScale WSRECEIVE cAttendant, cBeginDate, cEndDate WSREST CHECKINGS
Local cTemp			:= GetNextAlias()
Local cResponse		:= '{ "appointment":[], "count": 0 }'	
Local nRecord		:= 0
Local ncount 		:= 0
Local cMessage		:= "Internal Server Error"
Local nStatusCode	:= 500
Local lRet	 		:= .F.
Local cDtIni		:= ""
Local lMV_MultFil 	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cQuery		:= ""

Default Self:cAttendant	:= ""

Default Self:cEndDate	:= Self:cBeginDate
 
// Define o tipo de retorno do método	
Self:SetContentType("application/json")

If !Empty(Self:cAttendant) .And. !Empty(Self:cBeginDate)
	lRet := .T. 

	cQuery += "SELECT ABS.ABS_DESCRI, ABB_DTINI, ABB_DTFIM, ABB_HRINI, ABB_HRFIM,ABB_HRCHIN,ABB_HRCOUT,"
	cQuery += " CASE WHEN ABB_CHEGOU <> 'S' THEN '2' ELSE '1' END ABB_CHEGOU, "
	cQuery += " CASE WHEN ABB_SAIU <> 'S' THEN '2' ELSE '1' END ABB_SAIU "
	cQuery += " FROM "  + RetSqlName( "AA1" ) + " AA1 "
	cQuery += "INNER JOIN "  + RetSqlName( "ABB" ) + " ABB ON "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL ='"+xFilial("ABB") +"' "
	Else
		cQuery += FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.)
	EndIf
	cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' " "
	cQuery += "INNER JOIN "  + RetSqlName( "ABS" ) + " ABS ON "
	If !lMV_MultFil
		cQuery += "ABS.ABS_FILIAL ='"+xFilial("ABS") +"' "
	Else
		cQuery += FWJoinFilial("ABS" , "ABB" , "ABS", "ABB", .T.)
	EndIf
	cQuery += " AND ABB.ABB_LOCAL = ABS.ABS_LOCAL "
	cQuery += " AND ABS.D_E_L_E_T_ = ' ' " "
	cQuery += " WHERE "
	cQuery += "	AA1.AA1_FILIAL  = '" + xFilial("AA1") + "' AND "
	cQuery += " AA1.AA1_NREDUZ  = '" + Self:cAttendant + "' AND "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND"
	EndIf 
	cQuery += " ABB.ABB_CODTEC = AA1.AA1_CODTEC AND "
	cQuery += " ABB.ABB_DTINI BETWEEN '" + Self:cBeginDate + "' AND '" + Self:cEndDate + "' AND"
	cQuery += " ABB.ABB_ATIVO = '1' AND "
	cQuery += "	AA1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY ABB_DTINI DESC "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

	If ( cTemp )->( !Eof() )
			
		//-------------------------------------------------------------------
		// Identifica a quantidade de registro no alias temporário.    
		//-------------------------------------------------------------------
		count TO nRecord
		
		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.  
		//-------------------------------------------------------------------	
		( cTemp )->( DBGoTop() )
		
		cResponse	:= ""
		cResponse	+= '{ "appointments":[' 
				
		While ( cTemp )->( !Eof() )
			
			//-------------------------------------------------------------------
			// Incrementa o contador.  
			//-------------------------------------------------------------------									
			cDtIni := ( cTemp )->ABB_DTINI
			cResponse += '{"data" : ' + '"' + cDtIni + '",'							
				
			cResponse += '"stations":['
			While cDtIni == ( cTemp )->ABB_DTINI
				cResponse += '{"station":"' + EncodeUTF8(Alltrim(( cTemp )->ABS_DESCRI)) + '",'			 				
				cResponse += '"schedule":"' + Iif(( cTemp )->ABB_CHEGOU == '1', ( cTemp )->ABB_HRCHIN,( cTemp )->ABB_HRINI) + '",'
				cResponse += '"inout":"1",'
				cResponse += '"executed":"' + ( cTemp )->ABB_CHEGOU + '"},'
				
				cResponse += '{"station":"' + EncodeUTF8(Alltrim(( cTemp )->ABS_DESCRI)) + '",'			 				
				cResponse += '"schedule":"' + Iif(( cTemp )->ABB_SAIU == '1', ( cTemp )->ABB_HRCOUT, ( cTemp )->ABB_HRFIM)  + '",'
				cResponse += '"inout":"2",'
				cResponse += '"executed":"' + ( cTemp )->ABB_SAIU  + '"}'
				
					
							
				ncount++
					
				( cTemp )->( DBSkip() )
				
				If  cDtIni == ( cTemp )->ABB_DTINI
					cResponse += ','
				Else
					cResponse += ']}'
				EndIf
			End
			
			If ncount < nRecord 
				cResponse += ','
			EndIf								
		End
		
		cResponse += ' ],   '
		cResponse += '"count": ' +cBIStr( nRecord * 2 ) + ' } ' 	
	EndIf
	(cTemp)->(dbCloseArea())
Else
	nStatusCode	:= 400
	cMessage 		:= STR0013 //"Necessario informar os parametros de usuario e data da agenda"
EndIf

If lRet
	Self:SetResponse( cResponse )
Else 
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getStationsByDay WSRECEIVE cAttendant, cDate WSREST CHECKINGS
Local cTemp			:= GetNextAlias()
Local cResponse		:= '{ "stations":[], "count": 0 }'	
Local nRecord		:= 0
Local ncount 		:= 0
Local cMessage		:= "Internal Server Error"
Local nStatusCode	:= 500
Local lRet	 		:= .F.
Local lMV_MultFil 	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cQuery		:= ""

Default Self:cAttendant	:= ""

// Define o tipo de retorno do método	
Self:SetContentType("application/json")

If !Empty(Self:cAttendant) .And. !Empty(Self:cDate) 

	cQuery += "SELECT DISTINCT ABS.ABS_LOCAL, ABS.ABS_CHFOTO ,ABS.ABS_DESCRI "
	cQuery += " FROM "  + RetSqlName( "AA1" ) + " AA1 "
	cQuery += "INNER JOIN "  + RetSqlName( "ABB" ) + " ABB ON "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL ='"+xFilial("ABB") +"' "
	Else
		cQuery += FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.)
	EndIf
	cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' " "
	cQuery += "INNER JOIN "  + RetSqlName( "ABS" ) + " ABS ON "
	If !lMV_MultFil
		cQuery += "ABS.ABS_FILIAL ='"+xFilial("ABS") +"' "
	Else
		cQuery += FWJoinFilial("ABS" , "ABB" , "ABS", "ABB", .T.)
	EndIf
	cQuery += " AND ABB.ABB_LOCAL = ABS.ABS_LOCAL "
	cQuery += " AND ABS.D_E_L_E_T_ = ' ' " "
	cQuery += " WHERE "
	cQuery += "	AA1.AA1_FILIAL  = '" + xFilial("AA1") + "' AND "
	cQuery += " AA1.AA1_NREDUZ  = '" + Self:cAttendant + "' AND "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND"
	EndIf 
	cQuery += " ABB.ABB_CODTEC = AA1.AA1_CODTEC AND "
	cQuery += " (ABB.ABB_DTINI = '" + Self:cDate + "' OR ABB.ABB_DTFIM = '" + Self:cDate + "') AND "
	cQuery += "	AA1.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

	If ( cTemp )->( !Eof() )
		
		lRet := .T.
		
		//-------------------------------------------------------------------
		// Identifica a quantidade de registro no alias temporário.    
		//-------------------------------------------------------------------
		count TO nRecord
		
		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.  
		//-------------------------------------------------------------------	
		( cTemp )->( DBGoTop() )
		
		cResponse	:= ""
		cResponse	+= '{ "stations":[' 
				
		While ( cTemp )->( !Eof() )
			
			//-------------------------------------------------------------------
			// Incrementa o contador.  
			//-------------------------------------------------------------------												
						
				cResponse += '{"id":"' + (( cTemp )->ABS_LOCAL) + '",'
				cResponse += '"requiredPhoto":"' + (IIF(( cTemp )->ABS_CHFOTO == " ", "1", ( cTemp )->ABS_CHFOTO)) + '",'
				cResponse += '"station":"' + EncodeUTF8(Alltrim(( cTemp )->ABS_DESCRI)) + '"}'			 				
															
				ncount++
					
				( cTemp )->( DBSkip() )
				
				If ncount < nRecord
					cResponse += ','				
				EndIf
											
		EndDo
		
		cResponse += ' ],   '
		cResponse += '"count": ' +cBIStr( nRecord ) + ' } ' 
	Else
		nStatusCode	:= 400
		cMessage 		:= STR0012	 //"Nenhum local encontrado..."
	EndIf
	(cTemp)->(dbCloseArea())
Else
	nStatusCode	:= 400
	cMessage 		:= STR0013 //"Necessario informar os parametros de usuario e data da agenda"
EndIf

If lRet
	Self:SetResponse( cResponse )
Else 
	SetRestFault( nStatusCode, EncodeUTF8(cMessage) )
EndIf

Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------
WSMETHOD GET getSchedules WSRECEIVE cAttendant, cDate, cIdStation, cInOut WSREST CHECKINGS
Local cTemp			:= GetNextAlias()
Local cResponse		:= '{ "schedule":[], "count": 0 }'	
Local nRecord		:= 0
Local ncount 		:= 0
Local cMessage		:= "Internal Server Error"
Local nStatusCode	:= 500
Local lRet	 		:= .F.
Local lMV_MultFil 	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cQuery		:= ""

Default Self:cAttendant	:= ""
 
// Define o tipo de retorno do método	
Self:SetContentType("application/json")

If !Empty(Self:cAttendant) .And. !Empty(Self:cDate) .And. !Empty(Self:cIdStation) .And. !Empty(Self:cInOut) 

	lRet := .T.
	
	cQuery += "SELECT ABB_HRINI, ABB_HRFIM, ABB.ABB_CODIGO "
	cQuery += " FROM "  + RetSqlName( "AA1" ) + " AA1 "
	cQuery += "INNER JOIN "  + RetSqlName( "ABB" ) + " ABB ON "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL ='"+xFilial("ABB") +"' "
	Else
		cQuery += FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.)
	EndIf
	cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' " "
	cQuery += " WHERE "
	cQuery += "	AA1.AA1_FILIAL  = '" + xFilial("AA1") + "' AND "
	cQuery += " AA1.AA1_NREDUZ  = '" + Self:cAttendant + "' AND "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND"
	EndIf 
	cQuery += " ABB.ABB_CODTEC = AA1.AA1_CODTEC AND "
	cQuery += " ABB.ABB_DTINI = '" + Self:cDate + "' AND"
	cQuery += " ABB.ABB_LOCAL = '" + Self:cIdStation + "' AND"
	cQuery += "	AA1.D_E_L_E_T_ = ' ' "

	If Self:cInOut == '1'
		cQuery += "AND ABB.ABB_CHEGOU <> 'S' "
	ElseIf Self:cInOut == '2' 
		cQuery += "AND ABB.ABB_SAIU <> 'S' "
	EndIf 

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)

	If ( cTemp )->( !Eof() )
		
		//-------------------------------------------------------------------
		// Identifica a quantidade de registro no alias temporário.    
		//-------------------------------------------------------------------
		count TO nRecord
		
		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.  
		//-------------------------------------------------------------------	
		( cTemp )->( DBGoTop() )
		
		cResponse	:= ""
		cResponse	+= '{ "schedules":[' 
				
		While ( cTemp )->( !Eof() )
			
			//-------------------------------------------------------------------
			// Incrementa o contador.  
			//-------------------------------------------------------------------												

				If Self:cInOut == '1'
					cResponse += '{"schedule":"' + ((cTemp)->ABB_HRINI) + '",'
				Else	
					cResponse +=  '{"schedule":"' + ((cTemp)->ABB_HRFIM) + '",'
				EndIf	
							 				
				cResponse +=  '"code":"' + ((cTemp)->ABB_CODIGO) + '"}'							 				
															
				ncount++
					
				( cTemp )->( DBSkip() )
				
				If ncount < nRecord
					cResponse += ','				
				EndIf
											
		EndDo
		
		cResponse += ' ],   '
		cResponse += '"count": ' +cBIStr( nRecord ) + ' } ' 	
	EndIf
	(cTemp)->(dbCloseArea())
Else
	lRet := .F.
	nStatusCode	:= 400
	cMessage 	:= STR0014 //"Necessario informar os parametros de atendente, data da agenda, local de trabalho e o tipo (entrada ou saída)"
EndIf

If lRet
	Self:SetResponse( cResponse )
Else 
	SetRestFault( nStatusCode, EncodeUTF8(cMessage))
EndIf

Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------
WSMETHOD POST putCheckIn WSREST CHECKINGS	
Local cResponse			:= '{"status":"ok"}'	
Local cMessage			:= "Internal Server Error"
Local nStatusCode		:= 500
Local lRet	 			:= .F.
Local cBody				:= ""
Local oOppJson			:= Nil
Local aDist				:= {}
Local cFilABB 			:= ""
Local lMV_MultFil		:= TecMultFil()
  
cBody := Self:GetContent()
		
If !Empty( cBody )
	
	FWJsonDeserialize(cBody,@oOppJson) 
	
	If !Empty( oOppJson ) 				
		lRet := .T.		
	EndIf 			
End

Self:SetContentType("application/json")

If lRet .And. (Empty(oOppJson:cIdSchedule) .Or. Empty(oOppJson:cInOut))
	lRet := .F.
	nStatusCode := 400
	cMessage := STR0015	 //"Informe o Código da ABB e o tipo (entrada ou saída)"
EndIf

If lRet
	If lMV_MultFil
		aDist := TecBuscaABB(oOppJson,@cFilABB)
	Else
		aDist := TECMABSLtL(oOppJson:cIdSchedule)
	EndIf
	If  aDist[1] > 0 .And. distanciaGPS(oOppJson:nLatitude,oOppJson:nLongitude,aDist[2],aDist[3]) > aDist[1]
		lRet 		:= .F.
		nStatusCode := 400
		cMessage 	:= STR0016 //"Tolerância de distância excedida entre a posição atual e o posto de trabalho"
		
	EndIf	
EndIf

If lRet  		
	lRet := TECMProCf(oOppJson,cFilABB,lMV_MultFil)
	If !lRet
		nStatusCode := 400
		cMessage := STR0017  //"Não foi possível atualizar a agenda do atendente (ABB)"
	EndIf		
EndIf
	
If lRet
	Self:SetResponse( cResponse )
Else 
	SetRestFault( nStatusCode, EncodeUTF8(cMessage))
EndIf	

Return( lRet ) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------

WSMETHOD GET getCheckIn WSRECEIVE cAttendant, cDate, cIdStation WSREST CHECKINGS
Local cTemp			:= GetNextAlias()
Local cResponse		:= '{ "checkin":[], "count": 0 }'	
Local cMessage		:= "Internal Server Error"
Local nStatusCode	:= 500
Local lRet	 		:= .F.
Local lMV_MultFil 	:= TecMultFil() //Indica se a Mesa considera multiplas filiais
Local cQuery		:= ""
Local lCkABB		:= .T.

Default Self:cAttendant	:= ""
 
// Define o tipo de retorno do método	
Self:SetContentType("application/json")

If !Empty(Self:cAttendant) .And. !Empty(Self:cDate) .And. !Empty(Self:cIdStation) 

	lRet := .T.
	
	cQuery += "SELECT ABB.ABB_CODIGO, "
	cQuery += "CASE WHEN ABB_CHEGOU <> 'S'  THEN ABB_HRINI WHEN ABB_CHEGOU = 'S' AND "
	cQuery += "ABB_SAIU = '' THEN ABB_HRFIM END ABBHR," 
	cQuery += "CASE WHEN ABB_CHEGOU <> 'S' THEN '1' WHEN ABB_CHEGOU = 'S' AND "
	cQuery += "ABB_SAIU = '' THEN '2' END INOUT "
	cQuery += " FROM "  + RetSqlName( "AA1" ) + " AA1 "
	cQuery += "INNER JOIN "  + RetSqlName( "ABB" ) + " ABB ON "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL ='"+xFilial("ABB") +"' "
	Else
		cQuery += FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.)
	EndIf
	cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
	cQuery += " AND ABB.D_E_L_E_T_ = ' ' " "
	cQuery += " WHERE "
	cQuery += "	AA1.AA1_FILIAL  = '" + xFilial("AA1") + "' AND "
	cQuery += " AA1.AA1_NREDUZ  = '" + Self:cAttendant + "' AND "
	If !lMV_MultFil
		cQuery += "ABB.ABB_FILIAL = '" + xFilial("ABB") + "' AND"
	EndIf 
	cQuery += " ABB.ABB_CODTEC = AA1.AA1_CODTEC AND "
	cQuery += " (ABB.ABB_DTINI = '" + Self:cDate + "' OR ABB.ABB_DTFIM = '" + Self:cDate + "' ) AND " 
	cQuery += " ABB.ABB_LOCAL = '" + Self:cIdStation + "' AND"
	cQuery += " ABB.ABB_ATIVO = '1' AND "
	cQuery += "	AA1.D_E_L_E_T_ = ' ' AND "
	cQuery += "(ABB.ABB_CHEGOU <> 'S' OR ABB.ABB_SAIU <> 'S') AND "
	cQuery += " ABB_HRINI = "
	cQuery += " (SELECT MIN(ABBSUB.ABB_HRINI) "
	cQuery += " FROM "  + RetSqlName( "AA1" ) + " AA1SUB "
	cQuery += "INNER JOIN "  + RetSqlName( "ABB" ) + " ABBSUB ON "
	If !lMV_MultFil
		cQuery += "ABBSUB.ABB_FILIAL ='"+xFilial("ABB") +"' "
	Else
		cQuery += FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.)
	EndIf
	cQuery += " AND ABBSUB.ABB_CODTEC = AA1SUB.AA1_CODTEC "
	cQuery += " AND ABBSUB.D_E_L_E_T_ = ' ' " "
	cQuery += " WHERE "
	cQuery += "	AA1SUB.AA1_FILIAL  = '" + xFilial("AA1") + "' AND "
	cQuery += " AA1SUB.AA1_NREDUZ  = '" + Self:cAttendant + "' AND "
	If !lMV_MultFil
		cQuery += "ABBSUB.ABB_FILIAL = '" + xFilial("ABB") + "' AND"
	EndIf 
	cQuery += " ABBSUB.ABB_CODTEC = AA1SUB.AA1_CODTEC AND "
	cQuery += " ( ABBSUB.ABB_DTINI = '" + Self:cDate + "' OR ABBSUB.ABB_DTFIM = '" + Self:cDate + "' ) AND "
	cQuery += " ABBSUB.ABB_LOCAL = '" + Self:cIdStation + "' AND "
	cQuery += " ABBSUB.ABB_ATIVO = '1' AND "
	cQuery += "	AA1SUB.D_E_L_E_T_ = ' ' AND "
	cQuery += " (ABBSUB.ABB_CHEGOU <> 'S' OR ABBSUB.ABB_SAIU <> 'S'))"

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)
	
	If ( cTemp )->( !Eof() )
		If ExistBlock("CCKABB")	
			lCkABB := ExecBlock("CCKABB",.F.,.F.,{cTemp})
		EndIf	
		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.  
		//-------------------------------------------------------------------	
		If lCkABB
			( cTemp )->( DBGoTop() )
																		
			cResponse	:= ""
			cResponse	+= '{ "checkin":['		
			cResponse 	+= '{"idschedule":"' + ((cTemp)->ABB_CODIGO) + '",'
			cResponse 	+= '"inout":"' + ((cTemp)->INOUT) + '",'
			cResponse 	+=  '"schedule":"' + ((cTemp)->ABBHR) + '"}'
			cResponse 	+= ' ],'
			cResponse 	+= '"count": 1 }' 
		EndIf	
	EndIf

	(cTemp)->(dbCloseArea())

Else
	nStatusCode	:= 400
	cMessage 		:= STR0018 //"Necessario informar os parametros de atendente, data da agenda, local de trabalho"
EndIf

If lRet
	Self:SetResponse( cResponse )
Else 
	SetRestFault( nStatusCode, cMessage )
EndIf

Return( lRet ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} MailForAttendant
localhost:8080/rest/CHECKINGS/MailForAttendant
{ 
  "cAttendant": "1",
  "cBeginDate": "2019/11/05",
  "cEndDate": "2019/11/05"
}
@author	 Luiz Gabriel
@since		05/11/2019
/*/
//------------------------------------------------------------------------------
WSMETHOD POST MailForAttendant WSREST CHECKINGS
Local cMessage		:= "Internal Server Error"
Local nStatusCode	:= 500
Local lRet	 		:= .F.
Local cBody			:= ""
Local oOppJson		:= Nil
Local aResp			:= {}

cBody := Self:GetContent()
		
If !Empty( cBody )
	
	FWJsonDeserialize(cBody,@oOppJson) 
	
	If !Empty( oOppJson ) 				
		lRet := .T.		
	EndIf 			
End

Self:SetContentType("application/json")

If lRet .And. !AttIsMemberOf(oOppJson, "cAttendant")
	lRet := .F.
	nStatusCode := 400
	cMessage := STR0022 //"Expecting <cAttendant> attribute"
EndIf

If lRet .And. !AttIsMemberOf(oOppJson, "cBeginDate")
	lRet := .F.
	nStatusCode := 400
	cMessage := STR0023 //"Expecting <cBeginDate> attribute"
EndIf

If lRet .And. !AttIsMemberOf(oOppJson, "cEndDate")
	lRet := .F.
	nStatusCode := 400
	cMessage := STR0024 //"Expecting <cEndDate> attribute"
EndIf

If lRet .And. Empty(oOppJson:cAttendant)
	lRet := .F.
	nStatusCode := 400
	cMessage := STR0025 //"Informe um valor para o atendente"
EndIf

If lRet .And. (Empty(oOppJson:cBeginDate) .Or. Empty(oOppJson:cEndDate))
	lRet := .F.
	nStatusCode := 400
	cMessage := STR0019 //"Informe uma data inicio ou fim para consulta"
EndIf

If lRet
	aResp := At760RetHtml(oOppJson:cAttendant,oOppJson:cBeginDate,oOppJson:cEndDate,.T.)
	If  Len(aResp) > 0 .And. !aResp[1][1]
		lRet := .F.
		nStatusCode := 400
		cMessage := aResp[1][2]	
	Else
		nStatusCode := 200
		cMessage := STR0020 //"E-mail enviado com sucesso"
	EndIf	
EndIf

cMessage := EncodeUTF8(cMessage)
	
If lRet
	HTTPSetStatus(nStatusCode, cMessage)
Else 
	SetRestFault( nStatusCode,cMessage)
EndIf	

Return( lRet ) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECMProCf
Rotina para Confirmar chegadas
@sample 	TECMProCf()
@since		26/08/2016
/*/
//------------------------------------------------------------------------------
Function TECMProCf(oObj,cFilABB,lMV_MultFil)
Local aArea	    := GetArea()
Local lRet      := .T.
Local cItem		:= ""
Local nI        := 1
Local cTime 	:= Time() 
Local cHour 	:= SubStr( cTime, 1, 2 ) 
Local cMin  	:= SubStr( cTime, 4, 2 )
Local cFilT48	:= "" 
Local aTimeUf	:= {}
Local cUFLoc	:= ""
Local lHVerao	:= SuperGetMv("MV_HVERAO",.F.,.F.)

If !Empty(oObj:cIdSchedule)
	cUFLoc := UF_ABS(oObj:cIdSchedule)
	if( !Empty(cUFLoc) )
		aTimeUf := FwTimeUF(cUFLoc,,lHVerao,DTOS(dDataBase) )
		cTime 	:= SubStr(aTimeUF[2],1,5) 
		cHour 	:= SubStr( cTime, 1, 2 )
		cMin  	:= SubStr( cTime, 4, 2 )
	EndIf
EndIf

If !lMV_MultFil
	cFilABB := xFilial("ABB")
	cFilT48 := xFilial("T48")
Else
	cFilT48 := cFilABB
EndIf

cTime := cHour + ':' + cMin

BEGIN TRANSACTION
	dbSelectArea('ABB')
	
	If !Empty(oObj:cIdSchedule)	
		dbSelectArea("ABB")
		ABB->(dbSetOrder(8))
		If ABB->(DbSeek(cFilABB+ oObj:cIdSchedule))				
			cItem := GetItemT48(oObj:cIdSchedule,cFilT48)
			RecLock("ABB",.F.)		
			
			If oObj:cInOut == '1'
				ABB->ABB_CHEGOU := 'S'
				//ABB->ABB_SELFIN := oObj:oSelfie:image
				ABB->ABB_OBSIN := DecodeUtf8(oObj:cComments)
				ABB->ABB_LATIN := Alltrim(Str(oObj:nLatitude))
				ABB->ABB_LONIN := Alltrim(Str(oObj:nLongitude))
				ABB->ABB_HRCHIN := cTime
				ABB->(MsUnlock())
				
				RecLock("T48",.T.)
				T48->T48_FILIAL := cFilT48
				T48->T48_CODABB := oObj:cIdSchedule
				T48->T48_ITEM := cItem
				T48->T48_TIPO := '1'
				T48->T48_FOTO := oObj:oSelfie:image
				T48->(MsUnlock())
				
				
				For nI := 1 To Len(oObj:aImages)
					cItem := GetItemT48(oObj:cIdSchedule,cFilT48)
					RecLock("T48",.T.)
					T48->T48_FILIAL := cFilT48
					T48->T48_CODABB := oObj:cIdSchedule
					T48->T48_ITEM := cItem
					T48->T48_TIPO := '3'
					T48->T48_FOTO := oObj:aImages[nI]:image
					T48->(MsUnlock())
				Next nI
				
			ElseIf oObj:cInOut == '2'
				ABB->ABB_SAIU := 'S'
				ABB->ABB_ATENDE := '1'
				ABB->ABB_OBSOUT := DecodeUtf8(oObj:cComments)				
				ABB->ABB_LATOUT := Alltrim(Str(oObj:nLatitude))
				ABB->ABB_LONOUT := Alltrim(Str(oObj:nLongitude))
				ABB->ABB_HRCOUT := cTime
				ABB->(MsUnlock())	
				
				RecLock("T48",.T.)
				T48->T48_FILIAL := cFilT48
				T48->T48_CODABB := oObj:cIdSchedule
				T48->T48_ITEM := cItem
				T48->T48_TIPO := '2'
				T48->T48_FOTO := oObj:oSelfie:image
				T48->(MsUnlock())
				
				For nI := 1 To Len(oObj:aImages)
					cItem := GetItemT48(oObj:cIdSchedule,cFilT48)
					RecLock("T48",.T.)
					T48->T48_FILIAL := cFilT48
					T48->T48_CODABB := oObj:cIdSchedule
					T48->T48_ITEM := cItem
					T48->T48_TIPO := '4'
					T48->T48_FOTO := oObj:aImages[nI]:image
					T48->(MsUnlock())
				Next nI
			EndIf   
		Else
			lRet := .F.	
		EndIf
	Else
		lRet := .F.			
	EndIf

END TRANSACTION	

RestArea(aArea)
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CHECKINGS

@author	 Matheus Lando Raimundo
@since		29/05/2017
/*/
//------------------------------------------------------------------------------
Function GetItemT48(cCodAbb,cFilT48)
Local cItem := ""
Local cTemp	:= GetNextAlias()

Default cFilT48 := xFilial("T48")

BeginSQL Alias cTemp
		
	SELECT MAX(T48_ITEM) T48_ITEM FROM %Table:T48% T48
	WHERE T48_FILIAL = %Exp:cFilT48% AND
		T48_CODABB = %Exp:cCodAbb% AND		
		T48.%NotDel%
EndSql

If ( cTemp )->( !Eof() )
	cItem := Soma1(( cTemp )->T48_ITEM)  
Else
	cItem := Soma1(Replicate("0", (TamSx3('T48_ITEM')[1]))) 
EndIf

Return cItem 



//------------------------------------------------------------------------------
/*/{Protheus.doc} distanciaGPS
Calcula a distância em metros entre duas coordenadas  

@sample     distanciaGPS(cLat1, cLong1, cLat2, cLong2)
@param             cLat1 Latitude da primeira coordenada
@param             cLong1       Longitude da primeira coordenada
@param             cLat2 Latitude da segunda coordenada
@param             cLong2       Longitude da segunda coordenada

@author     guilherme.pimentel
@since             08/08/2017
@version    P12
/*/
//------------------------------------------------------------------------------
Function distanciaGPS(cLat1, cLong1, cLat2, cLong2) 
Local cRaio := 6371
Local nPi := 3.1415
Local nRet := 0
   
cLat1 := cLat1 * nPi / 180
cLong1 := cLong1 * nPi / 180
cLat2 := cLat2 * nPi / 180
cLong2 := cLong2 * nPi / 180
   
cDifLat := cLat2 - cLat1
cDifLong := cLong2 - cLong1
   
nA := sin(cDifLat / 2) * sin(cDifLat / 2) + cos(cLat1) * cos(cLat2) * sin(cDifLong / 2) * sin(cDifLong / 2)
nC := 2 * atn2(sqrt(nA), sqrt(1 - nA)) 

nRet := cRaio * nC * 1000 
nRet := Round(nRet,1)   

Return nRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} TECMABSLtL

@author	 Matheus Lando Raimundo
@since		01/09/2017
@version	12.1.16
/*/
//------------------------------------------------------------------------------
Function TECMABSLtL(cCodABB)
Local aRet 		:= {}
Local aArea 	:= GetArea()
Local cCodLocal	:= ""

ABB->(dbSetOrder(8))
If ABB->(DbSeek(XFilial("ABB")+ cCodABB))
	cCodLocal	:= ABB->ABB_LOCAL
	TFL->(dbSetOrder(1))
		
	ABS->(dbSetOrder(1))
	If ABS->(DbSeek(XFilial("ABS")+ cCodLocal))
		Aadd(aRet,ABS->ABS_METROS)
		Aadd(aRet,Val(ABS->ABS_LATITU))
		Aadd(aRet,Val(ABS->ABS_LONGIT))
	EndIf	
EndIf

RestArea(aArea)
Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} TecBuscaABB

Realiza a busca de registro da ABB quando está com o parametro de Multi-filial
está ativado

@author	 Luiz Gabriel
@since		16/11/2020
/*/
//------------------------------------------------------------------------------
Static Function TecBuscaABB(oParam,cFilABB)
Local aRet		:= {}
Local cTemp		:= GetNextAlias()
Local cQuery	:= ""
Local cCodLocal	:= ""
Local aArea		:= GetArea()

cQuery += "SELECT ABB.ABB_CODIGO,ABB.ABB_LOCAL,ABB.ABB_FILIAL,ABB.R_E_C_N_O_ REC "
cQuery += " FROM "  + RetSqlName( "AA1" ) + " AA1 "
cQuery += "INNER JOIN "  + RetSqlName( "ABB" ) + " ABB ON "
cQuery += FWJoinFilial("ABB" , "AA1" , "ABB", "AA1", .T.)
cQuery += " AND ABB.ABB_CODTEC = AA1.AA1_CODTEC "
cQuery += " AND ABB.D_E_L_E_T_ = ' ' " "
cQuery += " WHERE "
cQuery += "	AA1.AA1_FILIAL  = '" + xFilial("AA1") + "' AND "
cQuery += " AA1.AA1_NREDUZ  = '" + oParam:cAttendant + "' AND "
cQuery += " ABB.ABB_CODTEC = AA1.AA1_CODTEC AND "
cQuery += " ABB.ABB_DTINI = '" + oParam:cDate + "' AND"
cQuery += " ABB.ABB_ATIVO = '1' AND "
cQuery += " ABB.ABB_CODIGO = '" + oParam:cIdSchedule + "' AND"
cQuery += "	AA1.D_E_L_E_T_ = ' '

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cTemp, .F., .T.)
	
If ( cTemp )->( !Eof() )
	cCodLocal 	:= (cTemp)->ABB_LOCAL
	cFilABB		:= (cTemp)->ABB_FILIAL
EndIf

If !Empty(cCodLocal) .And. !Empty(cFilABB)
	TFL->(dbSetOrder(1))
			
	ABS->(dbSetOrder(1))
	If ABS->(DbSeek(XFilial("ABS")+ cCodLocal))
		Aadd(aRet,ABS->ABS_METROS)
		Aadd(aRet,Val(ABS->ABS_LATITU))
		Aadd(aRet,Val(ABS->ABS_LONGIT))
	EndIf	
EndIf

(cTemp)->(dbCloseArea())

RestArea(aArea)

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} UF_ABS

@author	 	Diego Bezerra
@since		05/10/2022
@description Retorna o campo UF do local de atendimento (ABS) para uma determinada agenda (ABB)
/*/
//------------------------------------------------------------------------------
Static Function UF_ABS(cIdABB)

Local cUF := ''
Local cAlias := GetNextAlias()

BeginSQL Alias cAlias
	SELECT ABS_ESTADO FROM %Table:ABS% ABS
		INNER JOIN %Table:ABB% ABB ON ABB.ABB_FILIAL = %Exp:xFilial("ABB")% 
			AND ABB.ABB_LOCAL = ABS.ABS_LOCAL
			AND ABB.ABB_CODIGO = %Exp:cIdABB%
			AND ABB.%NotDel% 
		WHERE ABS.ABS_FILIAL = %Exp:xFilial("ABS")%
			AND ABS.%NotDel%
EndSql

If ( cAlias )->( !Eof() )
	IF !EMPTY( ( cAlias )->ABS_ESTADO)
		cUF := ( cAlias )->ABS_ESTADO
	EndIF 
EndIf

( cAlias )->( DbCloseArea() )
Return cUF
