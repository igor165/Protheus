#INCLUDE 'PROTHEUS.CH'   
#INCLUDE 'TMSAO20.CH'


//-------------------------------------------------------------------
/*TMSAO20

Limpeza da tabela DAV - Posicionamento

@author  Caio Murakami
@since   08/11/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Function TMSAO20() 
Local bProcesso	:= {|oSelf| AO20Proces( oSelf ) }
Local cPerg		:= Iif(DTW->(ColumnPos('DTW_LATITU'))>0,"TMSAO20A","TMSAO20")  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                     Parametros - TMSAO20                     ³
//³                                                              ³
//³MV_PAR01: Data até?                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ       

oTProces := tNewProcess():New( "TMSAO20" , STR0001 , bProcesso , STR0002 + STR0003 , cPerg ,,,,,.T.,.T.) 
oTProces:SaveLog(OemToAnsi(STR0004))

Return  


//-------------------------------------------------------------------
/*AO20Proces

Processamento da limpeza 

@author  Caio Murakami
@since   08/11/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function AO20Proces( oSelf ) 
Local aArea 	:= GetArea()

TcInternal(5,"*OFF")   
RptStatus({|| AO20DelDAV()}, STR0004,STR0005 )
TcInternal(5,"*ON")
RestArea(aArea)  

Return .T.
  

//-------------------------------------------------------------------
/*AO20DelDAV

Rotina realiza a limpeza da DAV 

@author  Caio Murakami
@since   08/11/2012
@version 1.0      
*/
//-------------------------------------------------------------------

Static Function AO20DelDAV()
Local aStru			:= DAV->( dbStruct() )  
Local cAliasQry	:= ""  
Local cQuery		:= ""  
Local cKey			:= "" 
Local nRecnoDAV	:= 0  
Local nX				:= 0 
Local nY				:= 0 
Local nPos			:= 0
Local dLimite 		:= mv_par01 
   
 	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retira da estrutura campos do tipo MEMO                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	nPos := Ascan( aStru, {|x| x[1] == "DAV_DETMSG" } )	
	If nPos>0
		aDel( aStru , nPos )
		//-- Redefine tamanho
 		aSize( aStru, Len(aStru) - 1 )
	EndIf
	   
	nPos := Ascan( aStru, {|x| x[1] == "DAV_DETPOS" } ) 	
	If nPos>0
		aDel( aStru , nPos )
		//-- Redefine tamanho
 		aSize( aStru, Len(aStru) - 1 )
	EndIf
	
	nPos := Ascan( aStru, {|x| x[1] == "DAV_DETLOG" } ) 	
	If nPos>0
		aDel( aStru , nPos )
		//-- Redefine tamanho
 		aSize( aStru, Len(aStru) - 1 )
	EndIf
 		
	cAliasQry := "AO20Proces"
	cQuery := " SELECT DAV_FILORI, DAV_VIAGEM , DAV_CODVEI , R_E_C_N_O_ NRECNO , DAV_IDMPOS "
	cQuery += " 	FROM " + RetSQLName("DAV") + " DAV "
	cQuery += " 	WHERE  DAV_FILIAL = '"+ xFilial("DAV")  + "' "
	cQuery += " 		AND DAV_DATPOS <= " + dToS(dLimite)  + " "
	cQuery += "	  		AND D_E_L_E_T_ = ' ' "
	cQuery += "	  	ORDER BY DAV_FILORI, DAV_VIAGEM , DAV_CODVEI, DAV_IDMPOS ASC "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),(cAliasQry),.F.,.T.) 

	For nX := 1 To Len(aStru)
		If ( aStru[nX][2]!="C" )
			TcSetField(cAliasQry,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
	SetRegua( 100 )  
	
	While !(cAliasQry)->( Eof() )
	   IncRegua( STR0006 + ( cKey := (cAliasQry)->DAV_FILORI + (cAliasQry)->DAV_VIAGEM + (cAliasQry)->DAV_CODVEI  ) )      	   
	   		cKey := (cAliasQry)->DAV_FILORI + (cAliasQry)->DAV_VIAGEM + (cAliasQry)->DAV_CODVEI 
	     	nRecnoDAV 	:= (cAliasQry)->NRECNO 
		   	(cAliasQry)->( dbSkip() )       
	   	
	   	If nY < nRecnoDAV
	   		nY := nRecnoDAV
	   	EndIf	
	   	
	   	//-- Verifica se o proximo registro se é igual ao anterior
	   	If (cAliasQry)->DAV_FILORI + (cAliasQry)->DAV_VIAGEM + (cAliasQry)->DAV_CODVEI == cKey   	
		   	DAV->( dbGoTo( nRecnoDAV ) )	   		
		     
		   	RecLock("DAV",.F.)
		   	dbDelete()  	
		   	dbCommit()
		   	MsUnlock()	   	 	
	   	EndIf 
	EndDo   
	
 	(cAliasQry)->( dbCloseArea() )
 	
 	nX := 0 	
	While( nX <= nY )
	 	TcSqlExec(cQuery+"R_E_C_N_O_>="+Str(nX,10,0)+" AND R_E_C_N_O_<="+Str(nX+1023,10,0)+"")
		nX += 1024
	EndDo 

Return
