#Include "PROTHEUS.ch"                        

Static lFWCodFil := FindFunction("FWCodFil")

/*/
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥UpdTms12  ≥ Autor ≥Katia                  ≥ Data ≥23/01/2014|±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Executa a Procedure, incluindo o Codigo do Solicitante (DUE)|±±
±±≥          ≥e a Sequencia de Endereco (DUL)                             |±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥Migrador da Versao 11 para 12                               |±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/         
Function UpdTms12()           
Local nProx     := 0
Local aProc     := {}
Local cProc     := ""                                                                                         
Local lRet		:= .F.
Local cArqTrb   := ""
Local iX        := 0
Local cExec     := ""
Local cRet      := ""
Local cIndex    := ""
Local cFilOld   := cFilAnt
Local aAreaSM0  := {}  
Local lGestao    := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local lCmpEmDUE  := .F.
Local lCmpUnDUE  := .F.
Local lCmpFlDUE  := .F.
Local lCmpEmDUL  := .F.
Local lCmpUnDUL  := .F.            
Local lCmpFlDUL  := .F.            
Local aArea      := GetArea()
Local cQuery	 := ""
Local cAliasQry  := GetNextAlias()

lRet:= If(Alltrim(Upper(TCGetDb())) $ "MSSQL|MSSQL7|ORACLE|DB2|DB2/400|INFORMIX", .T., .F.)
                                                      
TmsLogMsg("INFO", 'Inicio UPDTMS12: '+Time())

If lRet	
	lRet := MsFile( RetArq( __cRdd, AllTrim( FWSX2Util():GetPath( "DUE" ) ) + AllTrim( FWSX2Util():GetFile( "DUE" ) ) , .T. ) )

	If lRet 
		lRet := MsFile( RetArq( __cRdd, AllTrim( FWSX2Util():GetPath( "DUL" ) ) + AllTrim( FWSX2Util():GetFile( "DUL" ) ) , .T. ) )
	EndiF

	If !lRet
		TmsLogMsg("WARN", "Tabela DUE n„o existe")
		Return .T.
	EndIf
	
EndIf


/* ---------------------------l-------------------------------------------------------------------------------
	Criacao dos Indices Temporarios.
	---------------------------------------------------------------------------------------------------------- */
If lRet
	TmsLogMsg("INFO", 'UPDTMS12 - Inicio Processamento'+ ' - ' + cEmpAnt)
	aAreaSM0:= SM0->(GetArea())
	
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt)) 
	If SM0->M0_CODIGO == cEmpAnt  
		cFilAnt:= Iif( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)		
	EndIf	                                           
	
	lCmpEmDUE := ( FWModeAccess('DUE',1) == "C" )    
	lCmpUnDUE := ( FWModeAccess('DUE',2) == "C" )
	lCmpFlDUE := ( FWModeAccess('DUE',3) == "C" )
			
	lCmpEmDUL := ( FWModeAccess('DUL',1) == "C" )		
	lCmpUnDUL := ( FWModeAccess('DUL',2) == "C" )		
	lCmpFlDUL := ( FWModeAccess('DUL',3) == "C" )  
	              
	//--- Gestao de Empresas, sempre criar· o indice com Filial, caso contrario verifica somente o compartilhamento da Filial
	If !lGestao
		If lCmpFlDUE
			lCmpUnDUE:= .T.
			lCmpEmDUE:= .T.
		EndIf
		If lCmpFlDUL		
			lCmpUnDUL:= .T.
			lCmpEmDUL:= .T.			
		EndIf
	EndIf	
	
    //--- Indice das tabelas relacionados ao Solicitante     
    If !lGestao .And. (lCmpEmDUE .And. lCmpUnDUE .And. lCmpFlDUE)
		cIndex := "Create Index "+RetSqlName("DVJ")+"_T1 ON "+RetSqlName("DVJ")+" ( DVJ_DDD, DVJ_TEL, DVJ_CODPRO, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DUL")+"_T1 ON "+RetSqlName("DUL")+" ( DUL_DDD, DUL_TEL, DUL_SEQEND, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DF0")+"_T1 ON "+RetSqlName("DF0")+" ( DF0_DDD, DF0_TEL, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)		
		cIndex := "Create Index "+RetSqlName("DT4")+"_T1 ON "+RetSqlName("DT4")+" ( DT4_DDD, DT4_TEL, DT4_FILORI, DT4_NUMCOT, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)          
		cIndex := "Create Index "+RetSqlName("DT5")+"_T1 ON "+RetSqlName("DT5")+" ( DT5_DDD, DT5_TEL, DT5_DATSOL, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)
	Else
		cIndex := "Create Index "+RetSqlName("DVJ")+"_T1 ON "+RetSqlName("DVJ")+" ( DVJ_FILIAL, DVJ_DDD, DVJ_TEL, DVJ_CODPRO, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DUL")+"_T1 ON "+RetSqlName("DUL")+" ( DUL_FILIAL, DUL_DDD, DUL_TEL, DUL_SEQEND, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)		
		cIndex := "Create Index "+RetSqlName("DF0")+"_T1 ON "+RetSqlName("DF0")+" ( DF0_FILIAL, DF0_DDD, DF0_TEL, R_E_C_N_O_ )"+CRLF	
		TCSQLExec(cIndex)		
		cIndex := "Create Index "+RetSqlName("DT4")+"_T1 ON "+RetSqlName("DT4")+" ( DT4_FILIAL, DT4_DDD, DT4_TEL, DT4_FILORI, DT4_NUMCOT, R_E_C_N_O_ )"+CRLF		
		TCSQLExec(cIndex)		
		cIndex := "Create Index "+RetSqlName("DT5")+"_T1 ON "+RetSqlName("DT5")+" ( DT5_FILIAL, DT5_DDD, DT5_TEL, DT5_DATSOL, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)		
	EndIf	
	
    //--- Indice das tabelas relacionados a Sequencia de Endereco    
    If !lGestao .And. (lCmpEmDUL .And. lCmpUnDUL .And. lCmpFlDUL)
		cIndex := "Create Index "+RetSqlName("DF0")+"_T2 ON "+RetSqlName("DF0")+" ( DF0_CODSOL, DF0_SEQEND, R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DF1")+"_T2 ON "+RetSqlName("DF1")+" ( DF1_CLIREM, DF1_LOJREM, DF1_SQEREM,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DT5")+"_T2 ON "+RetSqlName("DT5")+" ( DT5_CLIDES, DT5_LOJDES, DT5_SQEDES,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)	
		cIndex := "Create Index "+RetSqlName("DT5")+"_T3 ON "+RetSqlName("DT5")+" ( DT5_CODSOL, DT5_SEQEND,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)		
		cIndex := "Create Index "+RetSqlName("DTC")+"_T2 ON "+RetSqlName("DTC")+" ( DTC_CLIDES, DTC_LOJDES, DTC_SQEDES,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DE5")+"_T2 ON "+RetSqlName("DE5")+" ( DE5_SEQEND, DE5_CGCDES, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)		
	Else	
		cIndex := "Create Index "+RetSqlName("DF0")+"_T2 ON "+RetSqlName("DF0")+" ( DF0_FILIAL, DF0_CODSOL, DF0_SEQEND, R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DF1")+"_T2 ON "+RetSqlName("DF1")+" ( DF1_FILIAL, DF1_CLIREM, DF1_LOJREM, DF1_SQEREM,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)		
		cIndex := "Create Index "+RetSqlName("DT5")+"_T2 ON "+RetSqlName("DT5")+" ( DT5_FILIAL, DT5_CLIDES, DT5_LOJDES, DT5_SQEDES,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)		
		cIndex := "Create Index "+RetSqlName("DT5")+"_T3 ON "+RetSqlName("DT5")+" ( DT5_FILIAL, DT5_CODSOL, DT5_SEQEND,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)
		cIndex := "Create Index "+RetSqlName("DTC")+"_T2 ON "+RetSqlName("DTC")+" ( DTC_FILIAL, DTC_CLIDES, DTC_LOJDES, DTC_SQEDES,  R_E_C_N_O_ )"+CRLF  
		TCSQLExec(cIndex)                                                                                                                                 
		cIndex := "Create Index "+RetSqlName("DE5")+"_T2 ON "+RetSqlName("DE5")+" ( DE5_FILIAL, DE5_SEQEND, DE5_CGCDES, R_E_C_N_O_ )"+CRLF
		TCSQLExec(cIndex)
	EndIf	
	Sleep(500)       
	                                                  
	cFilAnt:= cFilOld          
	RestArea(aAreaSM0)
EndIf
/* ----------------------------------------------------------------------------------------------------------
	Inicio da criacao das PROCEDURES DIN‚MICAS
	PROC01 - MSSTRZERO           - > MSSTRZERO ........................................................aProc[1]
	PROC02 - Cadastro Solicitante- > Inclui o Codigo do Solicitante (DUE_CODSOL), iniciando com........aProc[2]
				                      codigo igual 1 para cada Filial.                         
	PROC03 - Sequencia Endereco  - > Altera a Sequencia de Endereco (DUL_SEQEND), iniciando com........aProc[3]
				                      codigo igual 1 para cada Filial e guarda a sequencia anterior no campo
				                      DUL_OLDSEQ

     cProc - Nome da procedure sem a empresa
     aProc - arrauy com todas as procedures e tamanho do campo do DUE_CODSOL e DUL_SEQEND
	---------------------------------------------------------------------------------------------------------- */

If lRet 
	
	TmsLogMsg("INFO", 'UPDTMS12 - Criando Procedure')
	
	/* ---------------------------------------------------------
	   Cria a procedure ( MSSTRZERO )-> aProc[1]
	   --------------------------------------------------------- */
   	cArqTrb := CriaTrab(,.F.)   
	nProx:= nProx+1
	cProc := 'UPDTMS12'+cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)
	lRet  := UpdTmsPr01(cProc,aProc)  // UpdTmsPr01 -> Msstrzero -> aProc[1]
EndIf
If lRet
	/* ---------------------------------------------------------
	   Cria a procedure (Cadastro Solicitante) -> aProc[2]
	   --------------------------------------------------------- */
	nProx:= nProx+1
	cProc := 'UPDTMS12'+cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)   
	lRet  := UpdTmsPr02(cProc,aProc,lGestao,lCmpEmDUE,lCmpUnDUE,lCmpFlDUE)       // UpdTmsPr02 -> aProc[2]
EndIf
If lRet   
	/*  ---------------------------------------------------------
	   Cria a procedure (Sequencia de Endereco) -> aProc[3]
	    --------------------------------------------------------- */     
	nProx:= nProx+1
	cProc := 'UPDTMS12'+cArqTrb+StrZero(nProx,2)
	AADD( aProc, cProc+"_"+cEmpAnt)
	lRet  := UpdTmsPr03(cProc,aProc,lGestao,lCmpEmDUL,lCmpUnDUL,lCmpFlDUL)       // UpdTmsPr03 -> aProc[3]
EndIf
                                                                                             
If lRet
	lRet:= TMSProcUpd(aProc)
EndIf


If lRet

	/* -------------------------------------------------------------------
		Exclui as procedures criadas e indices temporarios
		------------------------------------------------------------------- */
	For iX = 1 to Len(aProc)   
		If TCSPExist(aProc[iX])
			cExec := "Drop procedure "+aProc[iX]
			cRet := TcSqlExec(cExec)
			If cRet <> 0
				MsgAlert("Erro na exclusao da Procedure: "+aProc[iX] +". Excluir manualmente no banco")
			Endif
		EndIf
	Next iX

	/* -------------------------------------------------------------------
		Exclui os Indices temporarios Solicitantes
		------------------------------------------------------------------- */
	cIndex := "Drop Index "+RetSqlName("DVJ")+"."+RetSqlName("DVJ")+"_T1"+CRLF
	TCSQLExec(cIndex) 
	
	cIndex := "Drop Index "+RetSqlName("DUL")+"."+RetSqlName("DUL")+"_T1"+CRLF
	TCSQLExec(cIndex)                                            
	
	cIndex := "Drop Index "+RetSqlName("DF0")+"."+RetSqlName("DF0")+"_T1"+CRLF
	TCSQLExec(cIndex)                                                         
	
	cIndex := "Drop Index "+RetSqlName("DT4")+"."+RetSqlName("DT4")+"_T1"+CRLF
	TCSQLExec(cIndex)                                            
	
	cIndex := "Drop Index "+RetSqlName("DT5")+"."+RetSqlName("DT5")+"_T1"+CRLF
	TCSQLExec(cIndex)                                            
	
	/* -------------------------------------------------------------------
		Exclui os Indices temporarios Sequencia de Endereco
		------------------------------------------------------------------- */
	cIndex := "Drop Index "+RetSqlName("DF0")+"."+RetSqlName("DF0")+"_T2"+CRLF
	TCSQLExec(cIndex)                                                   
	
	cIndex := "Drop Index "+RetSqlName("DF1")+"."+RetSqlName("DF1")+"_T2"+CRLF
	TCSQLExec(cIndex)                                             
	
	cIndex := "Drop Index "+RetSqlName("DT5")+"."+RetSqlName("DT5")+"_T2"+CRLF
	TCSQLExec(cIndex)                      
	
	cIndex := "Drop Index "+RetSqlName("DT5")+"."+RetSqlName("DT5")+"_T3"+CRLF
	TCSQLExec(cIndex)                                                   
	                             
	cIndex := "Drop Index "+RetSqlName("DTC")+"."+RetSqlName("DTC")+"_T2"+CRLF
	TCSQLExec(cIndex)        
	
	cIndex := "Drop Index "+RetSqlName("DE5")+"."+RetSqlName("DE5")+"_T2"+CRLF
	TCSQLExec(cIndex)                                            

	TmsLogMsg("INFO", 'UPDTMS12 - Fim Procedure')

EndIf


RestArea(aArea)
Return lRet

/* 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥UpdTmsPr01≥ Autor ≥Katia                  ≥ Data ≥23/01/2014|±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria Procedure MsStrZero                                    |±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥Migrador da Versao 11 para 12                               |±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function UpdTmsPr01(cProc)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cQuery    := ''
Local nRet      := 0

cQuery := ProcSTRZERO(cProc)

If !TCSPExist( cProc )
   	nRet := TcSqlExec(cQuery)
	If nRet != 0
		MsgAlert("Erro na criacao da procedure UpdTmsPr01 "+cProc)
		lRet:= .F.
	EndIf
EndIf
RestArea(aSaveArea)
Return(lRet)

/* 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥UpdTmsPr02≥ Autor ≥Katia                  ≥ Data ≥23/01/2014|±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria Procedure Solicitante                                  |±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥Migrador da Versao 11 para 12                               |±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function UpdTmsPr02(cProc, aProc, lGestao, lCmpEmDUE, lCmpUnDUE, lCmpFlDUE)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cProcNome := cProc+"_"+cEmpAnt
Local cQuery    := ''
Local aCampos   := DUE->(dbStruct())
Local cTipo     := ''
Local nRet      := 0
Local nPos      := 0
Local nPTratRec	:= 0
Local nTamCodSol:= 0                      

nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_CODSOL" } )
If nPos > 0
	nTamCodSol:= aCampos[nPos][3]
EndIf        

cQuery:="Create Procedure "+cProcNome+"("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIALDE        "+cTipo+CRLF
cQuery+="   @IN_FILIALATE       "+cTipo+CRLF
cQuery+="   @OUT_RESULT Char( 01) OutPut"+CRLF
cQuery+="   )"+CRLF
cQuery+="as"+CRLF

/* ------------------------------------------------------------------------------------
   Vers„o          - <v>  Protheus 12 </v>
   Assinatura      - <a>  001 </a>
   Fonte           - <s>  UpdTMS12 </s>
   Descricao       - <d>  Inclui o Codigo do Solicitante </d>
   Entrada         - <ri> @IN_FILIALDE  - Filial Corrente
                   - <ri> @IN_FILIALATE - Filial Ate     
   Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
   Tabelas         - <t>  DVE, DVJ, DUL, DF0, DT4, DT5
   -------------------------------------------------------------------------------------- */
nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUE_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDVJ_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDUL_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDF0_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDT4_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDT5_FILIAL   "+cTipo+CRLF

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_DDD" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"    
cQuery+="Declare @cDUE_DDD     "+cTipo+CRLF
cQuery+="Declare @cDVJ_DDD     "+cTipo+CRLF
cQuery+="Declare @cDUL_DDD     "+cTipo+CRLF
cQuery+="Declare @cDF0_DDD     "+cTipo+CRLF
cQuery+="Declare @cDT4_DDD     "+cTipo+CRLF
cQuery+="Declare @cDT5_DDD     "+cTipo+CRLF
                      
nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_TEL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"    
cQuery+="Declare @cDUE_TEL     "+cTipo+CRLF
cQuery+="Declare @cDVJ_TEL     "+cTipo+CRLF
cQuery+="Declare @cDUL_TEL     "+cTipo+CRLF
cQuery+="Declare @cDF0_TEL     "+cTipo+CRLF
cQuery+="Declare @cDT4_TEL     "+cTipo+CRLF
cQuery+="Declare @cDT5_TEL     "+cTipo+CRLF

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_CODSOL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"    
cQuery+="Declare @cDUE_CODSOL     "+cTipo+CRLF
cQuery+="Declare @cDVJ_CODSOL     "+cTipo+CRLF
cQuery+="Declare @cDUL_CODSOL     "+cTipo+CRLF
cQuery+="Declare @cDF0_CODSOL     "+cTipo+CRLF
cQuery+="Declare @cDT4_CODSOL     "+cTipo+CRLF
cQuery+="Declare @cDT5_CODSOL     "+cTipo+CRLF
cQuery+="Declare @cCodSol	     "+cTipo+CRLF

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_CODCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"    
cQuery+="Declare @cDUE_CODCLI     "+cTipo+CRLF

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUE_LOJCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"    
cQuery+="Declare @cDUE_LOJCLI     "+cTipo+CRLF

cQuery+="Declare @iCodSol     Integer"+CRLF
cQuery+="Declare @cAux        Char( 03 )"+CRLF
cQuery+="Declare @iTamCod     Integer"+CRLF
cQuery+="Declare @iRegs       Integer"+CRLF
cQuery+="Declare @iTranCount  Integer"+CRLF //Esta variavel È utilizada para que o commit tran nao seja retirado no Parse

cQuery+="Begin"+CRLF
   
cQuery+="	Select @OUT_RESULT	= '0'"+CRLF
cQuery+="	Select @cDUE_FILIAL = ' '"+CRLF
cQuery+="	Select @cDUE_DDD    = ' '"+CRLF
cQuery+="	Select @cDUE_TEL    = ' '"+CRLF
cQuery+="	Select @cDUE_CODCLI = ' '"+CRLF
cQuery+="	Select @cDUE_LOJCLI = ' '"+CRLF
cQuery+="	Select @cCodSol   	= ' '"+CRLF
cQuery+="	Select @iCodSol   	= 0"+CRLF
cQuery+="	Select @iTamCod   	= 0"+CRLF
cQuery+="	Select @iRegs       = 0"+CRLF

cQuery+="   "+CRLF              

cQuery+="	-- Verifica o ultimo codigo do solicitante"+CRLF   
cQuery+="	Select @iCodSol = Convert(Int, IsNull(Max(DUE_CODSOL),0)) From "+RetSqlName("DUE")+CRLF 
cQuery+="		Where DUE_FILIAL = @IN_FILIALDE"+CRLF
cQuery+="		And DUE_CODSOL <> ' ' "+CRLF
cQuery+="       And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF
cQuery+="	-- Cursor declaration cCursorDUE"+CRLF         
cQuery+="   Declare cCursorDUE insensitive cursor for"+CRLF
cQuery+="   "+CRLF
cQuery+="    Select DISTINCT DUE_FILIAL, DUE_DDD, DUE_TEL, DUE_CODCLI, DUE_LOJCLI"+CRLF
cQuery+="      From "+RetSqlName("DUE")+CRLF
cQuery+="		Where DUE_FILIAL = @IN_FILIALDE"+CRLF
cQuery+="		And DUE_CODSOL = ' '"+CRLF
cQuery+="       And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF
cQuery+="   For Read Only"+CRLF
cQuery+="   "+CRLF
cQuery+="   Open cCursorDUE"+CRLF
cQuery+="   "+CRLF
cQuery+="   Fetch cCursorDUE into @cDUE_FILIAL, @cDUE_DDD, @cDUE_TEL, @cDUE_CODCLI, @cDUE_LOJCLI"+CRLF
cQuery+="   "+CRLF
cQuery+="   While ( @@FETCH_STATUS = 0 ) Begin"+CRLF
cQuery+="   "+CRLF
cQuery+=" 		Select @iCodSol = @iCodSol + 1"+CRLF	
cQuery+="       Select @iTamCod  = "+cValToChar(nTamCodSol)+" "+CRLF        
cQuery+="       Exec "+aProc[1]+" @iCodSol, @iTamCod, @cCodSol OutPut"+CRLF  //Chama procedure MsStrZero 
cQuery+="   "+CRLF
cQuery+="	Select @iRegs = @iRegs+1"+CRLF
cQuery+="	If @iRegs = 1 Begin"+CRLF
cQuery+="		Begin tran"+CRLF
cQuery+="			Select @iRegs = @iRegs"+CRLF
cQuery+="	End"+CRLF
cQuery+="   "+CRLF
cQuery+="			Update "+RetSqlName("DUE")+" Set DUE_CODSOL = @cCodSol "+CRLF
cQuery+="			Where DUE_FILIAL = @cDUE_FILIAL "+CRLF
cQuery+="			And DUE_DDD = @cDUE_DDD "+CRLF
cQuery+="			And DUE_TEL = @cDUE_TEL "+CRLF   
cQuery+="			And D_E_L_E_T_ = ' ' "+CRLF
cQuery+="   "+CRLF                                                               
//Tabela DVJ 
cQuery+="			Update "+RetSqlName("DVJ")+" Set DVJ_CODSOL = @cCodSol "+CRLF  
If lGestao                                     
	If !lCmpEmDUE .And. !lCmpUnDUE .And. !lCmpFlDUE
		cQuery+="           Where DVJ_FILIAL = @IN_FILIALDE "+CRLF	
		cQuery+="			And DVJ_DDD = @cDUE_DDD "+CRLF
	Else 
		cQuery+="           Where DVJ_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE "+CRLF
		cQuery+="			And DVJ_DDD = @cDUE_DDD "+CRLF
	EndIf
Else 
    If !lCmpFlDUE
	    cQuery+="           Where DVJ_FILIAL = @IN_FILIALDE "+CRLF
	    cQuery+="			And DVJ_DDD = @cDUE_DDD "+CRLF
    Else
		cQuery+="           Where DVJ_DDD = @cDUE_DDD "+CRLF
    EndIf
EndIf
cQuery+="			And DVJ_TEL = @cDUE_TEL "+CRLF
cQuery+="			And D_E_L_E_T_ = ' ' "+CRLF
cQuery+="   "+CRLF                                                               
//Tabela DUL
cQuery+="			Update "+RetSqlName("DUL")+" Set DUL_CODSOL = @cCodSol "+CRLF  
If lGestao                                     
	If !lCmpEmDUE .And. !lCmpUnDUE .And. !lCmpFlDUE
		cQuery+="           Where DUL_FILIAL = @IN_FILIALDE "+CRLF	
		cQuery+="			And DUL_DDD = @cDUE_DDD "+CRLF
	Else 
		cQuery+="           Where DUL_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE "+CRLF
		cQuery+="			And DUL_DDD = @cDUE_DDD "+CRLF
	EndIf
Else 
    If !lCmpFlDUE
	    cQuery+="           Where DUL_FILIAL = @IN_FILIALDE "+CRLF
	    cQuery+="			And DUL_DDD = @cDUE_DDD "+CRLF
    Else
		cQuery+="           Where DUL_DDD = @cDUE_DDD "+CRLF
    EndIf
EndIf
cQuery+="			And DUL_TEL = @cDUE_TEL "+CRLF
cQuery+="			And D_E_L_E_T_ = ' ' "+CRLF
cQuery+="   "+CRLF                                                               
//Tabela DF0
cQuery+="			Update "+RetSqlName("DF0")+" Set DF0_CODSOL = @cCodSol "+CRLF  
If lGestao                                     
	If !lCmpEmDUE .And. !lCmpUnDUE .And. !lCmpFlDUE
		cQuery+="           Where DF0_FILIAL = @IN_FILIALDE "+CRLF	
		cQuery+="			And DF0_DDD = @cDUE_DDD "+CRLF
	Else 
		cQuery+="           Where DF0_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE "+CRLF
		cQuery+="			And DF0_DDD = @cDUE_DDD "+CRLF
	EndIf
Else 
    If !lCmpFlDUE
	    cQuery+="           Where DF0_FILIAL = @IN_FILIALDE "+CRLF
	    cQuery+="			And DF0_DDD = @cDUE_DDD "+CRLF
    Else
		cQuery+="           Where DF0_DDD = @cDUE_DDD "+CRLF
    EndIf
EndIf
cQuery+="			And DF0_TEL = @cDUE_TEL "+CRLF
cQuery+="			And D_E_L_E_T_ = ' ' "+CRLF
cQuery+="   "+CRLF                                                               
//Tabela DT4
cQuery+="			Update "+RetSqlName("DT4")+" Set DT4_CODSOL = @cCodSol "+CRLF  
If lGestao                                     
	If !lCmpEmDUE .And. !lCmpUnDUE .And. !lCmpFlDUE
		cQuery+="           Where DT4_FILIAL = @IN_FILIALDE "+CRLF	
		cQuery+="			And DT4_DDD = @cDUE_DDD "+CRLF
	Else 
		cQuery+="           Where DT4_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE "+CRLF
		cQuery+="			And DT4_DDD = @cDUE_DDD "+CRLF
	EndIf
Else 
    If !lCmpFlDUE
	    cQuery+="           Where DT4_FILIAL = @IN_FILIALDE "+CRLF
	    cQuery+="			And DT4_DDD = @cDUE_DDD "+CRLF
    Else
		cQuery+="           Where DT4_DDD = @cDUE_DDD "+CRLF
    EndIf
EndIf
cQuery+="			And DT4_TEL = @cDUE_TEL "+CRLF
cQuery+="			And D_E_L_E_T_ = ' ' "+CRLF
cQuery+="   "+CRLF                                                               
//Tabela DT5
cQuery+="			Update "+RetSqlName("DT5")+" Set DT5_CODSOL = @cCodSol "+CRLF  
If lGestao                                     
	If !lCmpEmDUE .And. !lCmpUnDUE .And. !lCmpFlDUE
		cQuery+="           Where DT5_FILIAL = @IN_FILIALDE "+CRLF	
		cQuery+="			And DT5_DDD = @cDUE_DDD "+CRLF
	Else 
		cQuery+="           Where DT5_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE "+CRLF
		cQuery+="			And DT5_DDD = @cDUE_DDD "+CRLF
	EndIf
Else 
    If !lCmpFlDUE
	    cQuery+="           Where DT5_FILIAL = @IN_FILIALDE "+CRLF
	    cQuery+="			And DT5_DDD = @cDUE_DDD "+CRLF
    Else
		cQuery+="           Where DT5_DDD = @cDUE_DDD "+CRLF
    EndIf
EndIf
cQuery+="			And DT5_TEL = @cDUE_TEL "+CRLF
cQuery+="			And D_E_L_E_T_ = ' ' "+CRLF            
//Grava registros
cQuery+="   "+CRLF                                                               
cQuery+="			If @iRegs > 10000 begin"+CRLF
cQuery+="				Commit tran "+CRLF
cQuery+="				Select @iRegs = 0"+CRLF
cQuery+="			End"+CRLF
cQuery+="   "+CRLF                          
//Comando para que retorne ao While em DB2 (utilizado no Parse)
If AllTrim(TcGetDb()) = 'DB2'
	cQuery+= "			Select @fim_CUR = 0"+CRLF
EndIf
cQuery+="		Fetch cCursorDUE into  @cDUE_FILIAL, @cDUE_DDD, @cDUE_TEL, @cDUE_CODCLI, @cDUE_LOJCLI"+CRLF
cQuery+="   "+CRLF
cQuery+="   End"+CRLF
cQuery+="   Close cCursorDUE"+CRLF
cQuery+="   Deallocate cCursorDUE"+CRLF                                 
cQuery+="	If @iRegs > 0 begin"+CRLF          
cQuery+="		Select @iTranCount = 0"+CRLF  //Comando para que execute o commit em Oracle (utilizado no Parse)
cQuery+="		Commit tran"+CRLF
cQuery+="   End"+CRLF
cQuery+="   Select @OUT_RESULT = '1'"+CRLF 
cQuery+="End"+CRLF

cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query do admin UpdTmsPr02 nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		nRet := TcSqlExec(cQuery)
		If nRet != 0
			MsgAlert("Erro na criacao da procedure UpdTmsPr02 "+cProc)
			lRet:= .F.
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)

/* 
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥UpdTmsPr03≥ Autor ≥Katia                  ≥ Data ≥23/01/2014|±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥DescriáÖo ≥Cria Sequencia de Endereco                                  |±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Uso       ≥Migrador da Versao 11 para 12                               |±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function UpdTmsPr03(cProc, aProc, lGestao, lCmpEmDUL, lCmpUnDUL, lCmpFlDUL)
Local aSaveArea := GetArea()
Local lRet      := .T.
Local cProcNome := cProc+"_"+cEmpAnt
Local cQuery    := ''
Local aCampos   := DUL->(dbStruct())
Local cTipo     := ''
Local nRet      := 0
Local nPos      := 0
Local nPTratRec	:= 0     
Local nTamSeq   := 0    

If lRet
	nPos:= Ascan( aCampos, {|x| Alltrim(x[1]) == "DUL_SEQEND" } )
	If nPos > 0
		nTamSeq:= aCampos[nPos][3]
	EndIf	
EndIf		

cQuery:="Create Procedure "+cProcNome+"("+CRLF
nPos := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUL_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" ),"
cQuery+="   @IN_FILIALDE        "+cTipo+CRLF
cQuery+="   @IN_FILIALATE       "+cTipo+CRLF
cQuery+="   @OUT_RESULT Char(01) OutPut"+CRLF
cQuery+="   )"+CRLF
cQuery+="as"+CRLF

/* ------------------------------------------------------------------------------------
   Vers„o          - <v>  Protheus 12 </v>
   Assinatura      - <a>  001 </a>
   Fonte           - <s>  UpdTMS12 </s>
   Descricao       - <d>  Altera o Codigo da Sequencia de EndereÁo </d>
   Entrada         - <ri> @IN_FILIALDE     - Filial Corrente
                   - <ri> @IN_FILIALATE    - Filial Ate  
   Saida           - <o>  @OUT_RESULTADO   - Indica o termino OK da procedure </ro>
   Tabelas         - <t>  DUL, DF0, DF1, DT5, DTC, DE5 </t>
   -------------------------------------------------------------------------------------- */
cQuery+="-- Declaration of variables"+CRLF
cQuery+="   "+CRLF

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUL_FILIAL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUL_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDF0_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDF1_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDT5_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDTC_FILIAL   "+cTipo+CRLF
cQuery+="Declare @cDE5_FILIAL   "+cTipo+CRLF

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUL_CODSOL" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUL_CODSOL   "+cTipo+CRLF
cQuery+="Declare @cDVJ_CODSOL   "+cTipo+CRLF
cQuery+="Declare @cDF0_CODSOL   "+cTipo+CRLF 
cQuery+="Declare @cDT4_CODSOL   "+cTipo+CRLF 
cQuery+="Declare @cDT5_CODSOL   "+cTipo+CRLF 

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUL_CODCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUL_CODCLI   "+cTipo+CRLF
cQuery+="Declare @cDF1_CLIREM   "+cTipo+CRLF              
cQuery+="Declare @cDF1_CLIDES   "+cTipo+CRLF 
cQuery+="Declare @cDT5_CLIDES   "+cTipo+CRLF 
cQuery+="Declare @cDTC_CLIDES   "+cTipo+CRLF 

nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUL_LOJCLI" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUL_LOJCLI   "+cTipo+CRLF 
cQuery+="Declare @cDF1_LOJREM   "+cTipo+CRLF 
cQuery+="Declare @cDF1_LOJDES   "+cTipo+CRLF 
cQuery+="Declare @cDT5_LOJDES   "+cTipo+CRLF 
cQuery+="Declare @cDTC_LOJDES   "+cTipo+CRLF 
               
nPos  := Ascan( aCampos, {|x| Alltrim(x[1]) == "DUL_SEQEND" } )
cTipo := " Char( "+StrZero(aCampos[nPos][3],3)+" )"
cQuery+="Declare @cDUL_SEQEND   "+cTipo+CRLF

cQuery+="Declare @cCodSeq       "+cTipo+CRLF
cQuery+="Declare @iCodSeq        Integer"+CRLF
cQuery+="Declare @cAux           Char( 03 )"+CRLF
cQuery+="Declare @iTamSeq        Integer"+CRLF
cQuery+="Declare @iRegs          Integer"+CRLF
cQuery+="Declare @iTranCount     Integer"+CRLF //Esta variavel È utilizada para que o commit tran nao seja retirado no Parse
cQuery+="   "+CRLF       

cQuery+="Begin "+CRLF 
cQuery+="   "+CRLF
cQuery+="	Select @OUT_RESULT   = '0'"+CRLF
cQuery+="	Select @cDUL_FILIAL  = ' '"+CRLF
cQuery+="	Select @cDUL_CODSOL  = ' '"+CRLF
cQuery+="	Select @cDUL_CODCLI  = ' '"+CRLF
cQuery+="	Select @cDUL_LOJCLI  = ' '"+CRLF
cQuery+="	Select @cDUL_SEQEND  = ' '"+CRLF
cQuery+="	Select @cCodSeq      = ' '"+CRLF
cQuery+="	Select @iCodSeq      = 0"+CRLF
cQuery+="	Select @iTamSeq      = 0"+CRLF
cQuery+="	Select @iRegs       = 0"+CRLF
cQuery+="   "+CRLF

cQuery+="	Select @iCodSeq = Convert(Int, IsNull(Max(DUL_SEQEND),0)) From "+RetSqlName("DUL")+CRLF 
cQuery+="		Where DUL_FILIAL = @IN_FILIALDE"+CRLF
cQuery+="		And DUL_OLDSEQ <> ' '"+CRLF     //Se gravou novo codigo na sequencia, este campo estara preenchido
cQuery+="       And D_E_L_E_T_ = ' '"+CRLF

cQuery+="	-- Cursor declaration cCursorDUL"+CRLF   
cQuery+="	Declare cCursorDUL insensitive  Cursor for"+CRLF	
cQuery+="   "+CRLF
cQuery+="	Select  DUL_FILIAL, DUL_CODSOL, DUL_CODCLI, DUL_LOJCLI, DUL_SEQEND From "+RetSqlName("DUL")+CRLF
cQuery+="	  Where DUL_FILIAL  = @IN_FILIALDE"+CRLF
cQuery+="	  And DUL_OLDSEQ  = ' '"+CRLF    
cQuery+="	  And D_E_L_E_T_  = ' '"+CRLF
cQuery+="   "+CRLF
cQuery+="	For Read Only"+CRLF
cQuery+="   "+CRLF
cQuery+="	Open cCursorDUL"+CRLF   
cQuery+="	Fetch cCursorDUL"+CRLF 
    
cQuery+="	Into @cDUL_FILIAL, @cDUL_CODSOL, @cDUL_CODCLI, @cDUL_LOJCLI, @cDUL_SEQEND"+CRLF   
cQuery+="   "+CRLF	
cQuery+="	While ( (@@FETCH_STATUS  = 0 ) ) Begin"+CRLF
cQuery+="		Select @iCodSeq  = @iCodSeq  + 1"+CRLF   
cQuery+="		Select @iTamSeq  = "+cValToChar(nTamSeq)+" "+CRLF     
cQuery+="		Exec "+aProc[1]+" @iCodSeq , @iTamSeq , @cCodSeq output"+CRLF    //Chama procedure MsStrZero
cQuery+="   "+CRLF		
cQuery+="	Select @iRegs = @iRegs+1"+CRLF
cQuery+="	If @iRegs = 1 Begin"+CRLF
cQuery+="		Begin tran"+CRLF
cQuery+="			Select @iRegs = @iRegs"+CRLF
cQuery+="	End"+CRLF
cQuery+="   "+CRLF
cQuery+="			Update "+RetSqlName("DUL")+CRLF         
cQuery+="			Set DUL_OLDSEQ = Substring(@cDUL_SEQEND,1,2), DUL_SEQEND = @cCodSeq"+CRLF       
cQuery+="			  Where DUL_FILIAL = @cDUL_FILIAL"+CRLF  
cQuery+="			  And DUL_CODCLI = @cDUL_CODCLI"+CRLF 
cQuery+="			  And DUL_LOJCLI = @cDUL_LOJCLI"+CRLF 
cQuery+="			  And DUL_CODSOL = @cDUL_CODSOL"+CRLF 
cQuery+="			  And DUL_SEQEND = @cDUL_SEQEND"+CRLF 
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF        

//Tabela DF0
cQuery+="			Update "+RetSqlName("DF0")+CRLF
cQuery+="			Set DF0_OLDSEQ = Substring(@cDUL_SEQEND,1,2), DF0_SEQEND = @cCodSeq"+CRLF
If lGestao                                     
	If !lCmpEmDUL .And. !lCmpUnDUL .And. !lCmpFlDUL
		cQuery+="			  Where DF0_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DF0_CODSOL = @cDUL_CODSOL"+CRLF 
	Else
		cQuery+="			  Where DF0_FILIAL BETWEEN  @IN_FILIALDE AND @IN_FILIALATE"+CRLF 
		cQuery+="			  And DF0_CODSOL = @cDUL_CODSOL"+CRLF 
	EndIf   
Else             
    If !lCmpFlDUL
		cQuery+="			  Where DF0_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DF0_CODSOL = @cDUL_CODSOL"+CRLF 
    Else
		cQuery+="			  Where DF0_CODSOL = @cDUL_CODSOL"+CRLF 
    EndIf
EndIf	
cQuery+="			  And DF0_SEQEND = @cDUL_SEQEND"+CRLF 
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF                       
cQuery+="   "+CRLF
//Tabela DF1 Cliente Remetente
cQuery+="			Update "+RetSqlName("DF1")+CRLF
cQuery+="			Set DF1_OLDSQR = Substring(@cDUL_SEQEND,1,2), DF1_SQEREM = @cCodSeq"+CRLF
If lGestao                                     
	If !lCmpEmDUL .And. !lCmpUnDUL .And. !lCmpFlDUL
		cQuery+="			  Where DF1_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DF1_CLIREM = @cDUL_CODCLI"+CRLF	
	Else
		cQuery+="			  Where DF1_FILIAL BETWEEN  @IN_FILIALDE AND @IN_FILIALATE"+CRLF 
		cQuery+="			  And DF1_CLIREM = @cDUL_CODCLI"+CRLF	
	EndIf	
Else
	If !lCmpFlDUL
		cQuery+="			  Where DF1_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DF1_CLIREM = @cDUL_CODCLI"+CRLF	
	Else
		cQuery+="			  Where DF1_CLIREM = @cDUL_CODCLI"+CRLF
	EndIf	
EndIf	
cQuery+="			  And DF1_LOJREM = @cDUL_LOJCLI"+CRLF
cQuery+="			  And DF1_SQEREM = @cDUL_SEQEND"+CRLF
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF
//Tabela DF1 Cliente Destinatario
cQuery+="			Update "+RetSqlName("DF1")+CRLF
cQuery+="			Set DF1_OLDSQD = Substring(@cDUL_SEQEND,1,2), DF1_SQEDES = @cCodSeq"+CRLF       
If lGestao                                     
	If !lCmpEmDUL .And. !lCmpUnDUL .And. !lCmpFlDUL
		cQuery+="     		  Where DF1_FILIAL = @IN_FILIALDE"+CRLF  
		cQuery+="			  And DF1_CLIDES = @cDUL_CODCLI"+CRLF
	Else 
		cQuery+="     		  Where DF1_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE"+CRLF  
		cQuery+="			  And DF1_CLIDES = @cDUL_CODCLI"+CRLF
	EndIf	
Else                                                         
	If !lCmpFlDUL
		cQuery+="     		  Where DF1_FILIAL = @IN_FILIALDE"+CRLF  
		cQuery+="			  And DF1_CLIDES = @cDUL_CODCLI"+CRLF
	Else
		cQuery+="			  Where DF1_CLIDES = @cDUL_CODCLI"+CRLF
	EndIf		
EndIf	
cQuery+="			  And DF1_LOJDES = @cDUL_LOJCLI"+CRLF
cQuery+="			  And DF1_SQEDES = @cDUL_SEQEND"+CRLF
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF           
//Tabela DT5 Cliente Remetente
cQuery+="			Update "+RetSqlName("DT5")+CRLF
cQuery+="			Set DT5_OLDSQD = Substring(@cDUL_SEQEND,1,2), DT5_SQEDES = @cCodSeq"+CRLF
If lGestao                                     
	If !lCmpEmDUL .And. !lCmpUnDUL .And. !lCmpFlDUL
		cQuery+="			  Where DT5_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DT5_CLIDES = @cDUL_CODCLI"+CRLF
	Else
		cQuery+="			  Where DT5_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE"+CRLF 
		cQuery+="			  And DT5_CLIDES = @cDUL_CODCLI"+CRLF
	EndIf	
Else
	If !lCmpFlDUL
		cQuery+="			  Where DT5_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DT5_CLIDES = @cDUL_CODCLI"+CRLF
	Else
		cQuery+="			  Where DT5_CLIDES = @cDUL_CODCLI"+CRLF
	EndIf	
EndIf	
cQuery+="			  And DT5_LOJDES = @cDUL_LOJCLI"+CRLF
cQuery+="			  And DT5_SQEDES = @cDUL_SEQEND"+CRLF
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF
//Tabela DT5 Solicitante
cQuery+="			Update "+RetSqlName("DT5")+CRLF
cQuery+="			Set DT5_OLDSEQ = Substring(@cDUL_SEQEND,1,2), DT5_SEQEND = @cCodSeq"+CRLF
If lGestao                                     
	If !lCmpEmDUL .And. !lCmpUnDUL .And. !lCmpFlDUL
		cQuery+="			  Where DT5_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DT5_CODSOL = @cDUL_CODSOL"+CRLF
	Else 
		cQuery+="			  Where DT5_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE"+CRLF 
		cQuery+="			  And DT5_CODSOL = @cDUL_CODSOL"+CRLF
	EndIf	
Else
	If !lCmpFlDUL
		cQuery+="			  Where DT5_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DT5_CODSOL = @cDUL_CODSOL"+CRLF
	Else
		cQuery+="			  Where DT5_CODSOL = @cDUL_CODSOL"+CRLF
	EndIf	
EndIf	
cQuery+="			  And DT5_SEQEND = @cDUL_SEQEND"+CRLF
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF
//Tabela DTC
cQuery+="			Update "+RetSqlName("DTC")+CRLF
cQuery+="			Set DTC_OLDSQD = Substring(@cDUL_SEQEND,1,2), DTC_SQEDES = @cCodSeq"+CRLF
If lGestao                                     
	If !lCmpEmDUL .And. !lCmpUnDUL .And. !lCmpFlDUL
		cQuery+="			  Where DTC_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DTC_CLIDES = @cDUL_CODCLI"+CRLF
	Else
		cQuery+="			  Where DTC_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE"+CRLF 
		cQuery+="			  And DTC_CLIDES = @cDUL_CODCLI"+CRLF
	EndIf	
Else
	If !lCmpFlDUL
		cQuery+="			  Where DTC_FILIAL = @IN_FILIALDE"+CRLF 
		cQuery+="			  And DTC_CLIDES = @cDUL_CODCLI"+CRLF
	Else
		cQuery+="			  Where DTC_CLIDES = @cDUL_CODCLI"+CRLF
	EndIf			
EndIf	
cQuery+="			  And DTC_LOJDES = @cDUL_LOJCLI"+CRLF
cQuery+="			  And DTC_SQEDES = @cDUL_SEQEND"+CRLF
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF                              
//Tabela DE5
cQuery+="			Update "+RetSqlName("DE5")+CRLF
cQuery+="			Set DE5_OLDSEQ = Substring(@cDUL_SEQEND,1,2), DE5_SEQEND = @cCodSeq"+CRLF
If lGestao                                     
	If !lCmpEmDUL .And. !lCmpUnDUL .And. !lCmpFlDUL
		cQuery+="			  Where DE5_FILIAL = @IN_FILIALDE"+CRLF  
		cQuery+="			  And DE5_SEQEND = @cDUL_SEQEND"+CRLF
	Else
		cQuery+="			  Where DE5_FILIAL BETWEEN @IN_FILIALDE AND @IN_FILIALATE"+CRLF 
		cQuery+="			  And DE5_SEQEND = @cDUL_SEQEND"+CRLF
	EndIf	
Else
	If !lCmpFlDUL
		cQuery+="			  Where DE5_FILIAL = @IN_FILIALDE"+CRLF    
		cQuery+="			  And DE5_SEQEND = @cDUL_SEQEND"+CRLF		
	Else
		cQuery+="			  Where DE5_SEQEND = @cDUL_SEQEND"+CRLF
	EndIf			
EndIf	
cQuery+="             And DE5_CGCDES IN (Select A1_CGC FROM "+RetSqlName("SA1")+" SA1"+CRLF
cQuery+="                                Where A1_FILIAL BETWEEN @IN_FILIALDE And @IN_FILIALATE AND SA1.A1_COD = @cDUL_CODCLI AND A1_LOJA = @cDUL_LOJCLI AND SA1.D_E_L_E_T_=' ')
cQuery+="			  And D_E_L_E_T_ = ' '"+CRLF
cQuery+="   "+CRLF  
//Grava registros
cQuery+="			If @iRegs > 10000 begin"+CRLF
cQuery+="				Commit tran "+CRLF
cQuery+="				Select @iRegs = 0"+CRLF
cQuery+="			End"+CRLF
cQuery+="   "+CRLF				
//Comando para que retorne ao While em DB2 (utilizado no Parse)
If AllTrim(TcGetDb()) = 'DB2'
	cQuery+= "			Select @fim_CUR = 0"+CRLF
EndIf
cQuery+="			Fetch cCursorDUL"+CRLF
cQuery+="   "+CRLF			
cQuery+="			Into @cDUL_FILIAL, @cDUL_CODSOL, @cDUL_CODCLI, @cDUL_LOJCLI, @cDUL_SEQEND"+CRLF
cQuery+="	End"+CRLF
cQuery+="   "+CRLF	
cQuery+="   	Close cCursorDUL"+CRLF   
cQuery+="   	Deallocate cCursorDUL"+CRLF   
cQuery+="		If @iRegs > 0 begin"+CRLF
cQuery+="			Select @iTranCount = 0"+CRLF
cQuery+="			Commit tran"+CRLF
cQuery+="		End"+CRLF
cQuery+="   	Select @OUT_RESULT  = '1'"+CRLF 
cQuery+="   "+CRLF
cQuery+="   End"+CRLF
cQuery+="   "+CRLF    

cQuery := MsParse(cQuery, If(Upper(TcSrvType())= "ISERIES", "DB2", Alltrim(TcGetDB())))
cQuery := CtbAjustaP(.F., cQuery)

If Empty( cQuery )
	MsgAlert(MsParseError(),'A query do UpdTmsPr03 nao passou pelo Parse '+cProc)
	lRet := .F.
Else
	If !TCSPExist( cProc )
		nRet := TcSqlExec(cQuery)
		If nRet != 0
			MsgAlert("Erro na criacao da procedure UpdTmsPr03 "+cProc)
			lRet:= .F.
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

Return(lRet)

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥TMSProcUpd∫Autor  ≥Katia               ∫ Data ≥  27/01/14   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥Executa as Procedures de todas as filiais                   ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ UPDTMS12                                                   ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function TMSProcUpd(aProc)  

Local nCount   := 0
Local nPos     := 0
Local cNomeProc:= ""
Local lRet     := .T.

Default aProc  := ""

If Empty(aProc) 
	Return .F.
EndIf

/* ----------------------------------------------------------------------------------------------------------
	Verifica o compartilhamento da tabela DUE para execucao da procedure
	aProc[3] - Procedure Solicitante (DUE)
	aProc[4] - Procedure Sequencia de Endereco (DUL)
	--------------------------------------------------------------------------------------------------------- */	
nCount:= 1	
If lRet
	For nCount = 1 to Len(aProc)   
		If nCount >= 2 .And. nCount <= 3   //Procedure do Solicitante (DUE) e Sequencia Endereco (DUL)
	   		nPos:= 0
			nPos:= At("_",aProc[nCount])
			If nPos > 0     
				cNomeProc:= SubStr(aProc[nCount],1,(nPos - 1))	 
			
			   	If nCount == 2      //Procedure Solicitante
					lRet:= TmsSelFil('DUE',cNomeProc)					
				ElseIf nCount == 3  //Procedure Sequencia Endereco, executa somente se a Procedure do Solicitante for Executada
					If lRet 
						lRet:= TmsSelFil('DUL',cNomeProc)					
					EndIf	
				EndIf               
			EndIf	                           
		EndIf	
	Next nCount	              
EndIf                   
                  
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥TmsSelFil  ≥ Autor ≥ TOTVS			     ≥ Data ≥ 23/03/12 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±∫Desc.     ≥Busca as Filiais De/Ate da Empresa x Unidade de Negocio      ∫±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Parametros≥ 				                                               ≥±±
±±≥          ≥ cAlias    = Tabela                                          ≥±±
±±≥          ≥ cNomeProc = Nome da Procedure                               ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso		 ≥ UPDTMS12 											  	   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Function TmsSelFil(cAlias, cNomeProc)

Local aArea 	 := GetArea()
Local lCompEmp   := .F.
Local lCompUni   := .F.
Local lCompFil   := .F.
Local aFilValido := {'',''}
Local cFilOld    := cFilAnt
Local lExecuta   := .F.
Local cLayout 	 := Alltrim(FwSM0Layout())                      
Local nTamEmp    := 0
Local nTamUn     := 0
Local nTamFil    := 0
Local lGestao    := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local aAreaSM0   := {}
Local lRet       := .T.
Local cFilDe     := ""
Local cFilAte    := ""

nTamEmp:= Len(SubStr(cLayout,1,At("U",cLayout)-1))    
If At("U",cLayout) > 0
	nTamUn:= Len(SubStr(cLayout,At("U",cLayout),At("F",cLayout)-At("U",cLayout)))
EndIf
nTamFil:= Len(SubStr(cLayout,At("F",cLayout),Len(cLayout)))

SM0->(DbSetOrder(1))
SM0->(DbSeek(cEmpAnt)) 
While !SM0->(Eof()) .and. SM0->M0_CODIGO == cEmpAnt  
	cFilAnt:= Iif( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL)	
	
	lCompEmp := ( FWModeAccess(cAlias,1) == "C" )
	lCompUni := ( FWModeAccess(cAlias,2) == "C" )
	lCompFil := ( FWModeAccess(cAlias,3) == "C" )
	lExecuta := .T.

   	//Filial Execlusiva executa a procedure por Filial
	If !lCompFil   
		aFilValido[1]:= FwFilial(cAlias)
		aFilValido[2]:= FwFilial(cAlias)
		
		cFilDe     := FwFilial(cAlias)
		cFilAte    := FwFilial(cAlias)	
	Else
   	    //Filial Compartilhada, executa a procedure da Filial De/Ate
		If !lGestao
			If (nPos:= Ascan(aFilValido, cFilAnt)) > 0
				lExecuta:= .F.
			Else
				aFilValido := FWAllFilial(,,cEmpAnt)   //este array contera as filiais validas				
			EndIf	
		Else	
			If (nPos:= Ascan(aFilValido, cFilAnt)) > 0
				lExecuta:= .F.
			Else
				aFilValido := TMSFilArr( lCompEmp, lCompUni, lCompFil )  ////este array contera as filiais validas	
			EndIf                    
		EndIf
	EndIf                         
	
	If lExecuta .And. Len(aFilValido) > 0
		aAreaSM0:= SM0->(GetArea())
		              
		If lCompFil   //Tabela DUE ou DUL compartilhada executa de todas as filiais
			If FwModeAccess(cAlias,1) == "C" //Empresa compartilhada
				cFilDe  := Replicate(" ",nTamEmp)
				cFilAte := Replicate("Z",nTamEmp)
			Else
				cFilDe  := SubStr(cFilAnt,1,nTamEmp)
				cFilAte := SubStr(cFilAnt,1,nTamEmp)
			EndIf	

			If FwModeAccess(cAlias,2) == "C" //Un. NegÛcio compartilhada
				cFilDe  += Replicate(" ",nTamUn)
				cFilAte += Replicate("Z",nTamUn)
			Else
				cFilDe  += SubStr(cFilAnt,nTamEmp+1,nTamUn)
				cFilAte += SubStr(cFilAnt,nTamEmp+1,nTamUn)
			EndIf	

			If FwModeAccess(cAlias,3) == "C" //Filial compartilhada
				cFilDe  += Replicate(" ",nTamFil)
				cFilAte += Replicate("Z",nTamFil)
			EndIf
		EndIf
		
		//------- Executa Procedure          
		TmsLogMsg("INFO", VarInfo("Procedure: ",cNomeProc,,.f.))
		TmsLogMsg("INFO", "Inicio : "+Time())
		TmsLogMsg("INFO", "Filial De : "+cFilDe+"  Filial Ate : "+cFilAte )
               
   		aResult  := TCSPExec(xProcedures(cNomeProc), cFilDe, cFilAte)

		If Empty(aResult) .Or. aResult[1] = "0"
			MsgAlert(TcSqlError(),"Erro na execucao da Procedure " + " ! ")
			lRet := .F.	
			Exit
		EndIf
		TmsLogMsg("INFO", "Fim : "+Time())
		//---------
		
		RestArea(aAreaSM0)   	
	EndIf
	
	SM0->(dbSkip())
EndDo
                           
cFilAnt:= cFilOld

RestArea(aArea) 
     
Return lRet

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥FunáÑo	 ≥TMSFilArr  ≥ Autor ≥ TOTVS			     ≥ Data ≥ 23/03/12 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±∫Desc.     ≥Busca as Filiais De/Ate da Empresa x Unidade de Negocio      ∫±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥ Uso		 ≥ UPDTMS12 											  	   ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
/*/
Static Function TMSFilArr( lCompEmp, lCompUni, lCompFil )
Local aAuxFil := {}
Local aFilSM0 := AdmAbreSM0()
Local nX      := 0         
Local aArea   := GetArea()

If "E" $ FWSM0Layout() .And. lCompEmp  //se a empresa eh compartilhada uni e fil tb sao

	For nX := 1 TO Len(aFilSM0)
		If aFilSM0[nX, 1] == cEmpAnt
			aAdd(aAuxFil, aFilSM0[nX, 2])
		EndIf
	Next

ElseIf "U" $ FWSM0Layout() .And. lCompUni  //se a unid neg eh compartilhada fil tb sao

	For nX := 1 TO Len(aFilSM0)
		If aFilSM0[nX, 1] == cEmpAnt
			If aFilSM0[nX, 3] == FwCompany()
				aAdd(aAuxFil, aFilSM0[nX, 2])
			EndIf
		EndIf
	Next

ElseIf "F" $ FWSM0Layout() .And. lCompFil  //se filial compartilhada

	If "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout()
		For nX := 1 TO Len(aFilSM0)
			If aFilSM0[nX, 1] == cEmpAnt
				If aFilSM0[nX, 3] == FwCompany()
					If aFilSM0[nX, 4] == FWUnitBusiness()
						aAdd(aAuxFil, aFilSM0[nX, 2])
					EndIf
				EndIf
			EndIf
		Next
	Else
		If "E" $ FWSM0Layout()
			For nX := 1 TO Len(aFilSM0)
				If aFilSM0[nX, 1] == cEmpAnt
					If aFilSM0[nX, 3] == FwCompany()
						aAdd(aAuxFil, aFilSM0[nX, 2])
					EndIf
				EndIf
			Next
		EndIf
    EndIf
EndIf
                                  
RestArea(aArea)

Return(aAuxFil)
