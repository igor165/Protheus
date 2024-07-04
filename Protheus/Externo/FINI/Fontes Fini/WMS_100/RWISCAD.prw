#include "Protheus.ch"
#Include 'topconn.ch'

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISCAD

Rotina de integração entre o Protheus e WIS - Projeto WMS 100%

@author Roberto Marques
@since  03/07/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function RWISCAD(aParam)


Local cTitulo   	:= "Integração de Cadastros Protheus -> WIS"
Local nOpcao    	:= 0
Local aButtons  	:= {}
Local aSays     	:= {}
Local cEmp
Local cFil
Local cpar01
Local cpar02

Default aParam	:= {}
//Default cpar01	:= "02"
//Default cpar02	:= "01"	

If Len(aParam) > 0
	cpar01 := aParam[1]
	cpar02	:= aParam[2]
Else
	cpar01	:= "02"
	cpar02	:= "01"
EndIf


If (Type("oMainWnd")=="O")

    AADD(aSays,OemToAnsi("Esta rotina tem como objetivo integrar os cadastros do Protheus para o WIS."))
    AADD(aSays,"")  
    AADD(aSays,OemToAnsi("Os cadastros integrados são: Produtos (SB1), Clientes(SA1), Fornecedores(SA2) e"))
    AADD(aSays,"Transportadoras(SA4).")
    AADD(aSays,"")  
    AADD(aSays,OemToAnsi("Clique no botão Ok para continuar."))
    
    AADD(aButtons, {1, .T., {|o| nOpcao:= 1,o:oWnd:End()}})
    AADD(aButtons, {2, .T., {|o| nOpcao:= 2,o:oWnd:End()}})
    
    FormBatch(cTitulo, aSays, aButtons,,,530)
 
    If nOpcao = 1
		CONOUT("INTEGRACAO DE CADASTROS PROTHEUS -> WIS - WMS 100% - INICIO - EMPRESA "+cpar01+" - FILIAL "+cpar02+" - "+DTOC(ddatabase)+" - "+Time())		
		FWMsgRun(, {|| U_RWISCINT()}, "Cadastros Protheus -> WMS", "Processando")
		CONOUT("INTEGRACAO DE CADASTROS PROTHEUS -> WIS - WMS 100% - FIM - EMPRESA "+cpar01+" - FILIAL "+cpar02+" - "+DTOC(ddatabase)+" - "+Time())
		
		DelClassIntf()		 
    Endif
			
Else

	cEmp := cpar01
	cFil := cpar02
	
	//---------------------------------------------------------------------
	// Inicializa ambiente sem consumir licencas
	//---------------------------------------------------------------------
	RPCSetType(3)
	RpcSetEnv(cEmp, cFil,,,, GetEnvServer(), { })
	
	CONOUT("INTEGRACAO DE CADASTROS PROTHEUS -> WIS - WMS 100% - INICIO - EMPRESA "+cEmp+" - FILIAL "+cFil+" - "+DTOC(ddatabase)+" - "+Time())		
		FWMsgRun(, {|| U_RWISCINT()}, "Cadastros - WMS", "Processando")
	CONOUT("INTEGRACAO DE CADASTROS PROTHEUS -> WIS - WMS 100% - FIM - EMPRESA "+cEmp+" - FILIAL "+cFil+" - "+DTOC(ddatabase)+" - "+Time())				
	
	DelClassIntf()
	
	RpcClearEnv()
	
EndIf


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISCINT

Rotina de integração entre o Protheus e WIS

@author Allan Constantino Bonfim
@since  03/07/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function RWISCINT(cCadAlias, nCadRec)

Local mSQL 			:= ""
Local lIntegra 		:= .T.
Local nHndERP 		:= AdvConnection() 	// Salva a Conexão atual (SQL - Protheus)
Local cDBOra  		:= "" 
Local cSrvOra 		:= ""
Local nPorta			:= 0
Local nHndOra 		:= -1
Local nRegPrc			:= GetMv("MV_ZZWISIQ",, 99999)
Local nOk				:= 0
Local nX				:= 0 
Local nY				:= 0 
Local cWISAlias		:= GetMv("MV_ZZWISAL",, "WIS50")
Local nPosTipo		:= 5
Local nPosIPad		:= 3
Local cAliasZWA		:= GetNextAlias()
Local cEmp
Local cFil
	
Default cCadAlias		:= ""
Default nCadRec		:= 0


If U_GETZPA("TIPO_ACESSO_WIS","ZZ") = "WISHML"  //WISHML ou WIS
//	cDBOra  	:= "ODBC/"+U_GETZPA("TIPO_ACESSO_WIS","ZZ")
	cDBOra  	:= "ORACLE/"+U_GETZPA("TIPO_ACESSO_WIS","ZZ")
	cSrvOra 	:= GetMv("ZZ_WISERVH")
	nPorta		:= GetMv("ZZ_WISPORH")
Else
	cDBOra  	:= "ORACLE/"+U_GETZPA("TIPO_ACESSO_WIS","ZZ")
	cSrvOra 	:= GetMv("ZZ_WISERV")
	nPorta		:= GetMv("ZZ_WISPORT")
Endif

mSQL := "SELECT ZWA.R_E_C_N_O_ AS ZWAREC, * "+CHR(13)+CHR(10)
mSQL += "FROM "+ RetSQLName("ZWA")+" ZWA "+CHR(13)+CHR(10)
mSQL += "WHERE ZWA.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
mSQL += "AND ZWA_FILIAL = '"+xFilial("ZWA")+"' "+CHR(13)+CHR(10)
mSQL += "AND ZWA_IDPROC = 'N' "+CHR(13)+CHR(10)

If !EMPTY(cCadAlias)
	mSQL += "AND ZWA_CALIAS = '"+cCadAlias+"' "+CHR(13)+CHR(10)
EndIf

If !EMPTY(nCadRec)
	mSQL += "AND ZWA_FILL5 = '"+cValtoChar(nCadRec)+"' "+CHR(13)+CHR(10)
EndIf

mSQL += "ORDER BY ZWA.R_E_C_N_O_ "+CHR(13)+CHR(10)

// Verifica Se Existe View Aberta
If Select(cAliasZWA) > 0
	(cAliasZWA)->(DbCloseArea())
EndIf

//Execulta a query
dbUseArea( .T., "TOPCONN", TcGenQry(,,mSQL), cAliasZWA, .T., .F.)
	
While !(cAliasZWA)->(Eof())
	lIntegra	:= .F.
	cErro 		:= ""

	If nOk > nRegPrc 
		Exit
	EndIf
			
	If (cAliasZWA)->ZWA_CALIAS == "SA1" .AND. (cAliasZWA)->ZWA_TIPO == "CAD"	// SA1 - CLIENTES
		cInterface := "INT_E_CLIENTE" 
	ElseIf (cAliasZWA)->ZWA_CALIAS == "SA2" .AND. (cAliasZWA)->ZWA_TIPO == "CAD"	// SA2 - FORNECEDORES
		cInterface := "INT_E_FORNECEDOR"
	ElseIf (cAliasZWA)->ZWA_CALIAS == "SA4" .AND. (cAliasZWA)->ZWA_TIPO == "CAD"  // SA4 - TRANSPORTADORA
		cInterface := "INT_E_TRANSPORTADORA"
	ElseIf (cAliasZWA)->ZWA_CALIAS == "SB1" .AND. (cAliasZWA)->ZWA_TIPO == "CAD"  // SB1 - PRODUTOS
		cInterface := "INT_E_PRODUTO"
	ElseIf (cAliasZWA)->ZWA_CALIAS == "SB1" .AND. (cAliasZWA)->ZWA_TIPO == "BAR"
		cInterface := "INT_E_CODIGO_BARRAS"
	EndIf

	cCampos 	:= U_WW01GCPO(1, cInterface, "1")
	aCampos 	:= U_WW01GCPO(3, cInterface, "1")
					
	cQuery := "INSERT INTO "+cWISAlias+"."+cInterface+" "
	cQuery += "("+cCampos+") "			
	cQuery += "VALUES "			
		
	cValores 	:= "("
	xValTmp	:= NIL
						
	For nX:= 1 to Len(aCampos)						
		If nX > 1
			cValores += ","
		EndIf
			
		xValTmp := (cAliasZWA)->&(aCampos[nX][1])
			
		If Empty(xValTmp) .AND. !Empty(aCampos[nX][nPosIPad]) //Inicializador Padrão
			xValTmp := aCampos[nX][nPosIPad]
		EndIf						
			
		If !EMPTY(aCampos[nX][8]) //Opções do campo							
			aOpcoes := StrTokArr(aCampos[nX][8], ";")
				
			For nY := 1 to Len(aOpcoes)
				If ALLTRIM(xValTmp) == ALLTRIM(SUBSTR(aOpcoes[ny], 1, (AT("=", aOpcoes[ny])-1)))
					xValTmp := SUBSTR(aOpcoes[ny], (AT("=", aOpcoes[ny])+1), LEN(aOpcoes[ny]))
					Exit
				EndIf
			Next 
		EndIf		
			
		If aCampos[nX][nPosTipo] == "1" //Caracter
			If Valtype(xValTmp) == "N"
				If !EMPTY(aCampos[nX][6])
					xValTmp := STR(xValTmp,aCampos[nX][6], aCampos[nX][7])
				Else
					xValTmp := cValtoChar(xValTmp)
				EndIf
			EndIf
		ElseIf aCampos[nX][nPosTipo] == "2" //Numerico
			If Valtype(xValTmp) == "C"
				xValTmp := STR(Val(xValTmp),aCampos[nX][6], aCampos[nX][7])
			Else
				xValTmp := STR(xValTmp,aCampos[nX][6], aCampos[nX][7])
			EndIf
		ElseIf aCampos[nX][nPosTipo] == "3" //Data
			If !EMPTY(aCampos[nX][nPosIPad]) .OR. EMPTY(xValTmp)
				xValTmp := "TO_DATE('"+StrZero(Year(dDataBase),4)+"/"+StrZero(Month(dDatabase),2)+"/"+StrZero(day(dDataBase),2)+" "+Time()+"', 'yyyy/mm/dd hh24:mi:ss')"
			Else
				If Valtype(xValTmp) == "C" .AND. !EMPTY(xValTmp) //.AND. EMPTY(aCampos[nX][nPosIPad])
					xValTmp := "TO_DATE('"+xValTmp+" 00:00:00', 'yyyymmdd hh24:mi:ss')"
				EndIf
			EndIf				
		EndIf
										
		If EMPTY(xValTmp) .AND. aCampos[nX][4] == "1" //Campo obrigatório em branco
			xValTmp := aCampos[nX][nPosIPad]
		EndIf

		//Allan Constantino Bonfim - 05/09/2018 - Projeto WMS 100% - Correção para a retirada do apostrofo - evitando erro no insert com o WIS.								//Allan Constantino Bonfim - Projeto WMS 100% - Correção para a retirada do apostrofo - evitando erro no insert com o WIS.
		If aCampos[nX][nPosTipo] == "1"
			xValTmp := STRTRAN(xValTmp, "'", " ")
		EndIf
														
		If EMPTY(xValTmp)
			cValores += "NULL"
		ElseIf aCampos[nX][nPosTipo] == "1"
			cValores += "'"+ALLTRIM(xValTmp)+"'"
		ElseIf EMPTY(Val(xValTmp)) 
			If aCampos[nX][4] == "1" //Obrigatório
				cValores += ALLTRIM(xValTmp)
			Else
				cValores += "NULL"
			EndIf
		Else 
			cValores += ALLTRIM(xValTmp)
		EndIf												
	Next 
		
	cValores += ")"
	
	cQuery += cValores	

	// Cria uma conexão com um outro banco, outro DBAcces
	nHndOra := TcLink(cDbOra, cSrvOra, nPorta)
	If nHndOra >= 0	
		
		Begin Transaction		
							
			If TcSetConn(nHndORA)    //Conecta no Banco do Oracle (WIS)						
				If TcSQLExec(cQuery) >= 0 //Executa as Instruçoes do INSERT		
					cQuery := "Commit WORK"
					If TcSQLExec(cQuery) >= 0 //Realiza um Commit
						lIntegra := .T.						
					Else
						cErro 		:= "FALHA NA CONFIRMAÇÃO DA INCLUSÃO DOS DADOS NO BANCO DE DADOS WIS (COMMIT)"
						lIntegra 	:= .F.
					EndIf
				Else
					cErro 		:= "FALHA NA INCLUSÃO DOS DADOS NO BANCO DE DADOS WIS (INSERT)"
					lIntegra 	:= .F.
				EndIf				
			Else
				lIntegra 	:= .F.
				cErro 		:= "FALHA NA CONEXÂO COM BANCO DE DADOS WIS - "+cDbOra+" (SET CONNECTION)"						
			EndIf		

			TCUnlink(nHndOra)	// Finaliza a conexão TCLINK	
							
			TcSetConn(nHndERP)		// Volta a Instância para SQL (Protheus)					
			
			If !(cAliasZWA)->(EOF())
				DbSelectArea("ZWA")
				ZWA->(DbGoto((cAliasZWA)->ZWAREC))
				If lIntegra == .T.
					RecLock("ZWA", .F.)
						ZWA->ZWA_IDPROC := "S"
						ZWA->ZWA_DTPROC := dDataBase
					ZWA->(MsUnlock())
				Else
					RecLock("ZWA", .F.)
						ZWA->ZWA_IDPROC 	:= "E"
						ZWA->ZWA_DTPROC 	:= dDataBase
						ZWA->ZWA_ERRO 	:= cQuery //"ERRO( "+cErro+" )"+CHR(13)+CHR(10)+" QUERY( "+cQuery+") "+CHR(13)+CHR(10)+" SQLERROR( "+TCSQLError()+")"
					ZWA->(MsUnlock())					
				Endif
			EndIf
		End Transaction
		
	Else
		//UserException("Falha na conexão com " + cDbOra + " em " + cSrvOra)			
		cErro 		:= "FALHA NA CONEXÃO COM BANCO DE DADOS WIS - "+cDbOra+ " em " + cSrvOra+" (TCLINK)"
		lIntegra 	:= .F.	
	EndIf
		
	nOk++		
	(cAliasZWA)->(dbSkip())  
EndDo

If Select(cAliasZWA) > 0
	(cAliasZWA)->(DbCloseArea())
EndIf
	
Return
	
	
//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISTINT

Rotina para geração da tabela integradora dos cadastros no Protheus para o WIS

@author Allan Constantino Bonfim
@since  12/07/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function RWISTINT(cCadAlias, nCadRecno, nSituac)

Local aArea 		:= GetArea()
Local cFila		:= ""
Local aCodEmp		:= {"01", "02"} //StrTokArr(GetMv("MV_ZZWECAD",, "01,02"), "," )
Local aFilEmp		:= {} 
Local nX			:= 0
Local nY			:= 0 
Local cIntWis		:= "3"
Local lIntCad		:= GETMV("MV_ZZWICAD", , .F.)
Local nEmpresa 
Local aAreaZWA
Local cSvFilAnt 
Local cSvEmpAnt 
Local cSvArqTab 
Local cModo
		 
Default cCadAlias	:= ""
Default nCadRecno	:= 0
Default nSituac 	:= 0

If lIntCad //Integra os cadastros da empresa / filial atual
	If !Empty(cCadAlias) .AND. !Empty(nCadRecno)
	
		DbSelectArea(cCadAlias)
		(cCadAlias)->(DbGoto(nCadRecno))
				
		If cCadAlias == "SA1" //Cadastro de Clientes
			
			aAreaZWA 	:= ZWA->(GetArea())
			cSvFilAnt 	:= cFilAnt //Salva a Filial Anterior 
			cSvEmpAnt 	:= cEmpAnt //Salva a Empresa Anterior 
			cSvArqTab 	:= cArqTab //Salva os arquivos de //trabalho 
			
			For nX := 1 to Len(aCodEmp)				
			
				If aCodEmp[nX] == "02"
					aFilEmp := {"001", "006", "080"}
				Else
					aFilEmp := {"001"}
				EndIf
	
				/*
				EmpOpenFile(cNewAls,cAlias,nOrder,lOpen,cEmpresa,cModo)
				Onde: 
				cNewAls -> Apelido com o qual a Tabela será aberto
				cAlias -> Apelido da Tabela que se deseja abrir
				nOrder -> Ordem do Indice para abertura da Tabela
				lOpen -> .T. abre a Tabela .F. Fecha-a
				cEmpresa -> Codigo da Empresa para abertura da Tabela
				cModo -> Retornado por referência, define o Modo de acesso do arquivo
				*/
				 
				If EmpOpenFile("ZWA", "ZWA", 1, .T., aCodEmp[nX], @cModo) 				
					nEmpresa := IIf(aCodEmp[nX] == '01', 2, IIF(aCodEmp[nX] == '02', 1, 0))
									
					For nY := 1 to Len(aFilEmp)					
						Begin Transaction					
							cFila	:= STRZERO(U_FILAZWA("SA1", "CAD"), 10)
												
							RecLock("ZWA", .T.)
								ZWA->ZWA_FILIAL	:= xFilial("ZWA")
								ZWA->ZWA_CALIAS	:= cCadAlias
								ZWA->ZWA_TIPO 	:= "CAD"
								ZWA->ZWA_EMPRES	:= nEmpresa
								ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
								ZWA->ZWA_CODIGO	:= Alltrim(SA1->A1_COD + SA1->A1_LOJA)
								ZWA->ZWA_NOME		:= Alltrim(SA1->A1_NOME)
								ZWA->ZWA_INSCRI	:= IIF(SA1->A1_INSCR $ 'ISENT', 0, VAL(SA1->A1_INSCR))
								ZWA->ZWA_CNPJ		:= VAL(IIF(SA1->A1_EST = 'EX', '99999999999999', SA1->A1_CGC))
								ZWA->ZWA_CEP		:= Alltrim(SA1->A1_CEP)
								ZWA->ZWA_ENDERE	:= Alltrim(SA1->A1_END)
								ZWA->ZWA_BAIRRO	:= Alltrim(SA1->A1_BAIRRO)
								ZWA->ZWA_MUNICI	:= Alltrim(SA1->A1_MUN)
								ZWA->ZWA_UF		:= Alltrim(SA1->A1_EST)
								ZWA->ZWA_REDUZI	:= Alltrim(SA1->A1_NREDUZ)
								ZWA->ZWA_FANTAS	:= Alltrim(SA1->A1_NREDUZ)
								ZWA->ZWA_TELEF	:= VAL(SA1->A1_TEL)
								ZWA->ZWA_FAX		:= VAL(SA1->A1_FAX)
								
								If !Empty(nSituac)
									ZWA->ZWA_SITUAC	:= nSituac
								Else
									ZWA->ZWA_SITUAC	:= IIF(SA1->A1_MSBLQL = '1', 16, 15)
								EndIf
								
								ZWA->ZWA_DTINCL	:= date()
								ZWA->ZWA_HRINCL	:= TIME()
								ZWA->ZWA_IDPROC	:= 'N'
								ZWA->ZWA_FILA 	:= cFila
								ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
							ZWA->(MsUnLock())
					
							//Allan Constantino Bonfim - 11/07/2018 - Gravação do cliente na tabela integradora de fornecedor do WIS
							RecLock("ZWA", .T.)
								ZWA->ZWA_FILIAL	:= xFilial("ZWA")
								ZWA->ZWA_CALIAS	:= "SA2"
								ZWA->ZWA_TIPO 	:= "CAD"
								ZWA->ZWA_EMPRES	:= nEmpresa
								ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
								ZWA->ZWA_CODIGO	:= "C"+Alltrim(SA1->A1_COD + SA1->A1_LOJA)
								ZWA->ZWA_NOME		:= Alltrim(SA1->A1_NOME)
								ZWA->ZWA_INSCRI	:= IIF(SA1->A1_INSCR $ 'ISENT', 0, VAL(SA1->A1_INSCR))
								ZWA->ZWA_CNPJ		:= VAL(IIF(SA1->A1_EST = 'EX', '99999999999999', SA1->A1_CGC))
								ZWA->ZWA_CEP		:= Alltrim(SA1->A1_CEP)
								ZWA->ZWA_ENDERE	:= Alltrim(SA1->A1_END)
								ZWA->ZWA_BAIRRO	:= Alltrim(SA1->A1_BAIRRO)
								ZWA->ZWA_MUNICI	:= Alltrim(SA1->A1_MUN)
								ZWA->ZWA_UF		:= Alltrim(SA1->A1_EST)
								ZWA->ZWA_REDUZI	:= Alltrim(SA1->A1_NREDUZ)
								ZWA->ZWA_FANTAS	:= Alltrim(SA1->A1_NREDUZ)
								ZWA->ZWA_TELEF	:= VAL(SA1->A1_TEL)
								ZWA->ZWA_FAX		:= VAL(SA1->A1_FAX)
								
								If !Empty(nSituac)
									ZWA->ZWA_SITUAC	:= nSituac
								Else
									ZWA->ZWA_SITUAC	:= IIF(SA1->A1_MSBLQL = '1', 16, 15)
								EndIf
								
								ZWA->ZWA_DTINCL	:= date()
								ZWA->ZWA_HRINCL	:= TIME()
								ZWA->ZWA_IDPROC	:= 'N'
								ZWA->ZWA_FILA 	:= cFila
								ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
								
							ZWA->(MsUnLock())
						End Transaction				
					Next
				
					EmpOpenFile("ZWA", "ZWA", 1, .F., aCodEmp[nX], @cModo)
				EndIf 	
			Next
				
			(cCadAlias)->(dbCloseArea()) //Restaura os Dados de Entrada ( Ambiente ) 
			
			cFilAnt := cSvFilAnt 
			cEmpAnt := cSvEmpAnt  
			ChkFile("ZWA") //Reabre o SRA da empresa atual  
			
			RestArea(aAreaZWA)	
	
		ElseIf cCadAlias == "SA2" //Cadastro de Fornecedores
			
			aAreaZWA 	:= ZWA->(GetArea())
			cSvFilAnt 	:= cFilAnt //Salva a Filial Anterior 
			cSvEmpAnt 	:= cEmpAnt //Salva a Empresa Anterior 
			cSvArqTab 	:= cArqTab //Salva os arquivos de //trabalho 
			
			For nX := 1 to Len(aCodEmp)				
			
				If aCodEmp[nX] == "02"
					aFilEmp := {"001", "006", "080"}
				Else
					aFilEmp := {"001"}
				EndIf
	
				/*
				EmpOpenFile(cNewAls,cAlias,nOrder,lOpen,cEmpresa,cModo)
				Onde: 
				cNewAls -> Apelido com o qual a Tabela será aberto
				cAlias -> Apelido da Tabela que se deseja abrir
				nOrder -> Ordem do Indice para abertura da Tabela
				lOpen -> .T. abre a Tabela .F. Fecha-a
				cEmpresa -> Codigo da Empresa para abertura da Tabela
				cModo -> Retornado por referência, define o Modo de acesso do arquivo
				*/
				 
				If EmpOpenFile("ZWA", "ZWA", 1, .T., aCodEmp[nX], @cModo) 				
					nEmpresa := IIf(aCodEmp[nX] == '01', 2, IIF(aCodEmp[nX] == '02', 1, 0))
									
					For nY := 1 to Len(aFilEmp)					
						Begin Transaction					
							cFila	:= STRZERO(U_FILAZWA("SA2", "CAD"), 10)
						
							RecLock("ZWA", .T.)
								ZWA->ZWA_FILIAL	:= xFilial("ZWA")
								ZWA->ZWA_CALIAS	:= cCadAlias
								ZWA->ZWA_TIPO 	:= "CAD"
								ZWA->ZWA_EMPRES	:= nEmpresa
								ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
								ZWA->ZWA_CODIGO	:= Alltrim(SA2->A2_COD + SA2->A2_LOJA)
								ZWA->ZWA_NOME		:= Alltrim(SA2->A2_NOME)
								ZWA->ZWA_INSCRI	:= IIF(SA2->A2_INSCR $ 'ISENT', 0, VAL(SA2->A2_INSCR))
								ZWA->ZWA_CNPJ		:= VAL(IIF(SA2->A2_EST = 'EX', '99999999999999', SA2->A2_CGC))
								ZWA->ZWA_CEP		:= Alltrim(SA2->A2_CEP)
								ZWA->ZWA_ENDERE	:= Alltrim(SA2->A2_END)
								ZWA->ZWA_BAIRRO	:= Alltrim(SA2->A2_BAIRRO)
								ZWA->ZWA_MUNICI	:= Alltrim(SA2->A2_MUN)
								ZWA->ZWA_UF		:= Alltrim(SA2->A2_EST)
								ZWA->ZWA_REDUZI	:= Alltrim(SA2->A2_NREDUZ)
								ZWA->ZWA_FANTAS	:= Alltrim(SA2->A2_NREDUZ)
								ZWA->ZWA_TELEF	:= VAL(SA2->A2_TEL)
								ZWA->ZWA_FAX		:= VAL(SA2->A2_FAX)
								
								If !Empty(nSituac)
									ZWA->ZWA_SITUAC	:= nSituac
								Else
									ZWA->ZWA_SITUAC	:= IIF(SA2->A2_MSBLQL = '1', 16, 15)
								EndIf
								
								ZWA->ZWA_DTINCL	:= DATE()
								ZWA->ZWA_HRINCL	:= TIME()
								ZWA->ZWA_IDPROC	:= 'N'
								ZWA->ZWA_FILA 	:= cFila
								ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
								
							ZWA->(MsUnLock())
								
							//Allan Constantino Bonfim - 11/07/2018 - Gravação do fornecedor na tabela integradora de cliente do WIS
							RecLock("ZWA", .T.)
								ZWA->ZWA_FILIAL	:= xFilial("ZWA")
								ZWA->ZWA_CALIAS	:= "SA1"
								ZWA->ZWA_TIPO 	:= "CAD"
								ZWA->ZWA_EMPRES	:= nEmpresa
								ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
								ZWA->ZWA_CODIGO	:= "F"+Alltrim(SA2->A2_COD + SA2->A2_LOJA)
								ZWA->ZWA_NOME		:= Alltrim(SA2->A2_NOME)
								ZWA->ZWA_INSCRI	:= IIF(SA2->A2_INSCR $ 'ISENT', 0, VAL(SA2->A2_INSCR))
								ZWA->ZWA_CNPJ		:= VAL(IIF(SA2->A2_EST = 'EX', '99999999999999', SA2->A2_CGC))
								ZWA->ZWA_CEP		:= Alltrim(SA2->A2_CEP)
								ZWA->ZWA_ENDERE	:= Alltrim(SA2->A2_END)
								ZWA->ZWA_BAIRRO	:= Alltrim(SA2->A2_BAIRRO)
								ZWA->ZWA_MUNICI	:= Alltrim(SA2->A2_MUN)
								ZWA->ZWA_UF		:= Alltrim(SA2->A2_EST)
								ZWA->ZWA_REDUZI	:= Alltrim(SA2->A2_NREDUZ)
								ZWA->ZWA_FANTAS	:= Alltrim(SA2->A2_NREDUZ)
								ZWA->ZWA_TELEF	:= VAL(SA2->A2_TEL)
								ZWA->ZWA_FAX		:= VAL(SA2->A2_FAX)
								
								If !Empty(nSituac)
									ZWA->ZWA_SITUAC	:= 16
								Else
									ZWA->ZWA_SITUAC	:= IIF(SA2->A2_MSBLQL = '1', 16, 15)
								EndIf
								ZWA->ZWA_DTINCL	:= DATE()
								ZWA->ZWA_HRINCL	:= TIME()
								ZWA->ZWA_IDPROC	:= 'N'
								ZWA->ZWA_FILA 	:= cFila
								ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
								
							ZWA->(MsUnLock())		
						End Transaction				
					Next
				
					EmpOpenFile("ZWA", "ZWA", 1, .F., aCodEmp[nX], @cModo) 
				EndIf 	
			Next
				
			(cCadAlias)->(dbCloseArea()) //Restaura os Dados de Entrada ( Ambiente ) 
			
			cFilAnt := cSvFilAnt 
			cEmpAnt := cSvEmpAnt  
			ChkFile("ZWA") //Reabre o SRA da empresa atual  
			
			RestArea(aAreaZWA)	
	
		ElseIf cCadAlias == "SA4" //Cadastro de Transportadoras
			
			aAreaZWA 	:= ZWA->(GetArea())
			cSvFilAnt 	:= cFilAnt //Salva a Filial Anterior 
			cSvEmpAnt 	:= cEmpAnt //Salva a Empresa Anterior 
			cSvArqTab 	:= cArqTab //Salva os arquivos de //trabalho 
			
			For nX := 1 to Len(aCodEmp)				
			
				If aCodEmp[nX] == "02"
					aFilEmp := {"001", "006", "080"}
				Else
					aFilEmp := {"001"}
				EndIf
	
				/*
				EmpOpenFile(cNewAls,cAlias,nOrder,lOpen,cEmpresa,cModo)
				Onde: 
				cNewAls -> Apelido com o qual a Tabela será aberto
				cAlias -> Apelido da Tabela que se deseja abrir
				nOrder -> Ordem do Indice para abertura da Tabela
				lOpen -> .T. abre a Tabela .F. Fecha-a
				cEmpresa -> Codigo da Empresa para abertura da Tabela
				cModo -> Retornado por referência, define o Modo de acesso do arquivo
				*/
				 
				If EmpOpenFile("ZWA", "ZWA", 1, .T., aCodEmp[nX], @cModo) 				
					nEmpresa := IIf(aCodEmp[nX] == '01', 2, IIF(aCodEmp[nX] == '02', 1, 0))
									
					For nY := 1 to Len(aFilEmp)					
						Begin Transaction					
							cFila	:= STRZERO(U_FILAZWA("SA4", "CAD"), 10)
						
							RecLock("ZWA", .T.)
								ZWA->ZWA_FILIAL	:= xFilial("ZWA")
								ZWA->ZWA_CALIAS 	:= cCadAlias
								ZWA->ZWA_TIPO 	:= "CAD"
								ZWA->ZWA_EMPRES	:= nEmpresa
								ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
								ZWA->ZWA_CODIGO 	:= Alltrim(SA4->A4_COD)
								ZWA->ZWA_NOME 	:= Alltrim(SA4->A4_NOME)
								ZWA->ZWA_CNPJ 	:= VAL(iif(SA4->A4_EST = 'EX', '99999999999999', SA4->A4_CGC))
								ZWA->ZWA_CEP 		:= Alltrim(SA4->A4_CEP)
								ZWA->ZWA_ENDERE 	:= Alltrim(SA4->A4_END)
								ZWA->ZWA_BAIRRO 	:= Alltrim(SA4->A4_BAIRRO)
								ZWA->ZWA_MUNICI 	:= Alltrim(SA4->A4_MUN)
								ZWA->ZWA_UF 		:= Alltrim(SA4->A4_EST)
								ZWA->ZWA_SITUAC 	:= IIF(SA4->A4_MSBLQL = '1', 16, 15)
								ZWA->ZWA_DTINCL 	:= DATE()
								ZWA->ZWA_HRINCL	:= TIME()
								ZWA->ZWA_IDPROC 	:= 'N'
								ZWA->ZWA_FILA 	:= cFila
								ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
								
							ZWA->(MsUnLock())						
						End Transaction				
					Next
				
					EmpOpenFile("ZWA", "ZWA", 1, .F., aCodEmp[nX], @cModo)
				EndIf 	
			Next
				
			(cCadAlias)->(dbCloseArea()) //Restaura os Dados de Entrada ( Ambiente ) 
			
			cFilAnt := cSvFilAnt 
			cEmpAnt := cSvEmpAnt  
			ChkFile("ZWA") //Reabre o SRA da empresa atual  
			
			RestArea(aAreaZWA)
			
		ElseIf cCadAlias == "SB1" //Cadastro de Produtos
	
			If FWCodEmp() == "02"
				aFilEmp := {"001", "006", "080"}
			Else
				aFilEmp := {"001"}
			EndIf
	
			cIntWis := IIf(FWCodEmp() == '01', "1", IIF(FWCodEmp() == '02', "2", "Z"))
			
			If SB1->B1_ZINTWIS == cIntWis //Verifica se o produto integra com o WIS											
				
				For nY := 1 to Len(aFilEmp)		
					Begin Transaction							
						cFila 		:= STRZERO(U_FILAZWA("SB1", "CAD"), 10)
						nEmpresa 	:= IIf(FWCodEmp() == '01', 2, IIF(FWCodEmp() == '02', 1, 0))
									 				
						RecLock("ZWA",.T.)
							ZWA->ZWA_FILIAL	:= xFilial("ZWA")
							ZWA->ZWA_CALIAS 	:= cCadAlias
							ZWA->ZWA_TIPO 	:= "CAD"
							ZWA->ZWA_EMPRES	:= nEmpresa
							ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
							ZWA->ZWA_CODIGO	:= Alltrim(SB1->B1_COD)
							ZWA->ZWA_NOME		:= SUBSTRING(SB1->B1_DESC, 1, 38)
							ZWA->ZWA_REDUZI	:= SUBSTRING(SB1->B1_DESC, 1, 38)
							ZWA->ZWA_CDUM		:= Alltrim(SB1->B1_UM)
							ZWA->ZWA_DSUM		:= Posicione("SAH", 1, xFilial("SAH")+SB1->B1_UM, "AH_DESCPO")
							ZWA->ZWA_ATUDEC	:= 'N'
							ZWA->ZWA_CDEMB	:= 'N'
							ZWA->ZWA_DSEMB	:= 'NC'
							ZWA->ZWA_QTEMB	:= 1
							ZWA->ZWA_CDPROD	:= Alltrim(SB1->B1_COD)
							ZWA->ZWA_QTITEM	:= 1
							ZWA->ZWA_CDFAMI	:= 'NC'
							ZWA->ZWA_DSFAMI	:= 'NAO CADASTRADO'
							ZWA->ZWA_SITUAC	:= IIF(SB1->B1_MSBLQL = '1', 16, 15)
							ZWA->ZWA_ROTATI	:= 'A'
							ZWA->ZWA_CDCLAS	:= IIF(nEmpresa = 1, SB1->B1_ZLINPRO, '1')
							ZWA->ZWA_DSCLAS	:= IIF(nEmpresa = 1, Posicione("ZLP", 1, xFilial("ZLP")+SB1->B1_ZLINPRO, "ZLP_NOME"), 'GERAL') 
							ZWA->ZWA_DTINCL	:= DATE()
							ZWA->ZWA_HRINCL	:= TIME()
							ZWA->ZWA_IDPROC	:= 'N'
							ZWA->ZWA_CDLINH	:= 'NC'
							ZWA->ZWA_CDGRP	:= 'NC'
							ZWA->ZWA_CDSBGR	:= 'NC'
							ZWA->ZWA_CDMODE	:= 'NC'
							ZWA->ZWA_DSLINH	:= 'GERAL'
							ZWA->ZWA_DSGRP	:= 'NAO CADASTRADO'
							ZWA->ZWA_DSSBGR	:= 'NAO CADASTRADO'
							ZWA->ZWA_DSMODE	:= 'NAO CADASTRADO'
									//CM Solutions - Allan Constantino Bonfim - 14/09/2020 - Melhorias GFE - Ajuste nos campos para o cálculo do volume - De B5_COMPRLC, B5_LARGLC, B5_ALTURLC para B5_COMPR, B5_LARG, B5_ALTURA
							ZWA->ZWA_ALTURA 	:= Posicione("SB5", 1, xFilial("SB5")+SB1->B1_COD, "B5_ALTURA")
							ZWA->ZWA_LARGUR 	:= Posicione("SB5", 1, xFilial("SB5")+SB1->B1_COD, "B5_LARG")
							ZWA->ZWA_PROFUN 	:= Posicione("SB5", 1, xFilial("SB5")+SB1->B1_COD, "B5_COMPR")
							ZWA->ZWA_PLIQUI 	:= SB1->B1_PESO
							ZWA->ZWA_PBRUTO 	:= SB1->B1_PESBRU
							ZWA->ZWA_MAXPAL	:= SB1->B1_ZZCXPLT
							ZWA->ZWA_DIAVAL	:= SB1->B1_PRVALID
							ZWA->ZWA_DIAREM	:= 0
							ZWA->ZWA_CTRLOT	:= IIF(SB1->B1_RASTRO = 'L', 'S', 'N')
							ZWA->ZWA_CTRLSE	:= Alltrim(SB1->B1_LOCALIZ)
							ZWA->ZWA_CTRLVA	:= IIF(SB1->B1_RASTRO = 'L' .AND. SB1->B1_USAFEFO = '1', 'S', 'N')
							ZWA->ZWA_QCXFEC	:= 1
							ZWA->ZWA_CNPJ		:= 0
							ZWA->ZWA_FILA 	:= cFila
							ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
							
						ZWA->(MsUnLock())
						
						If !Empty(Alltrim(SB1->B1_EAN13A))
							RecLock("ZWA",.T.)
								ZWA->ZWA_FILIAL	:= xFilial("ZWA")
								ZWA->ZWA_CALIAS 	:= cCadAlias
								ZWA->ZWA_TIPO 	:= "BAR"
								ZWA->ZWA_EMPRES	:= nEmpresa
								ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
								ZWA->ZWA_CODIGO	:= Alltrim(SB1->B1_COD)
								ZWA->ZWA_NOME		:= SUBSTRING(SB1->B1_DESC, 1, 38)
								ZWA->ZWA_CDBARR	:= Alltrim(SB1->B1_EAN13A)
								ZWA->ZWA_SITUAC	:= IIF(SB1->B1_MSBLQL = '1', 2, 1)
								ZWA->ZWA_QTEMB	:= 1
								ZWA->ZWA_TPCODB	:= 13
								ZWA->ZWA_IDCODP	:= 'N'
								ZWA->ZWA_DTINCL	:= DATE()
								ZWA->ZWA_HRINCL	:= TIME()
								ZWA->ZWA_IDPROC	:= 'N'
								ZWA->ZWA_FILA 	:= cFila
								ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
								
							ZWA->(MsUnLock())
						Endif
						
						If !Empty(Alltrim(SB1->B1_CODBAR))
							RecLock("ZWA",.T.)
								ZWA->ZWA_FILIAL	:= xFilial("ZWA")
								ZWA->ZWA_CALIAS 	:= cCadAlias
								ZWA->ZWA_TIPO 	:= "BAR"
								ZWA->ZWA_EMPRES	:= nEmpresa
								ZWA->ZWA_DEPOSI	:= aFilEmp[nY]
								ZWA->ZWA_CODIGO	:= Alltrim(SB1->B1_COD)
								ZWA->ZWA_NOME		:= SUBSTRING(SB1->B1_DESC,1, 38)
								ZWA->ZWA_CDBARR	:= Alltrim(SB1->B1_CODBAR)
								ZWA->ZWA_SITUAC	:= IIF(SB1->B1_MSBLQL = '1', 2, 1)
								ZWA->ZWA_QTEMB	:= 1
								ZWA->ZWA_TPCODB	:= 14
								ZWA->ZWA_IDCODP	:= 'N'
								ZWA->ZWA_DTINCL	:= DATE()
								ZWA->ZWA_HRINCL	:= TIME()
								ZWA->ZWA_IDPROC	:= 'N'
								ZWA->ZWA_FILA 	:= cFila
								ZWA->ZWA_FILL5	:= cValtoChar(nCadRecno)
								
							ZWA->(MsUnLock())
						EndIf
					End Transaction
				Next
			EndIf			
		EndIf
	EndIf
EndIf

RestArea(aArea)
		
Return


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISISA1

Rotina para geração da tabela integradora do cadastro de clientes no Protheus para o WIS

@author Allan Constantino Bonfim
@since  12/07/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function RWISISA1(nSA1Recno)

Local cQuery 		:= ""
Local cAQuery		:= GetNextAlias()

Default nSA1Recno	:= 0

cQuery := "SELECT A1_FILIAL, A1_COD, SA1.R_E_C_N_O_ AS SA1REC, A1_MSBLQL "+CHR(13)+CHR(10) 
cQuery += "FROM " +RetSQLName("SA1")+ " SA1 "+CHR(13)+CHR(10)
cQuery += "WHERE SA1.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)

If nSA1Recno > 0
	cQuery += "AND SA1.R_E_C_N_O_ = '"+cValtoChar(nSA1Recno)+"' "+CHR(13)+CHR(10)
EndIf

cQuery += "ORDER BY A1_FILIAL, A1_COD "+CHR(13)+CHR(10)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAQuery, .T., .F. )

While !(cAQuery)->(EOF())
	U_RWISTINT("SA1", (cAQuery)->SA1REC, IIF((cAQuery)->A1_MSBLQL = '1', 16, 15))
	(cAQuery)->(DbSkip())
EndDo

If Select(cAQuery) > 0
	(cAQuery)->(DbCloseArea())
EndIf

Return


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISISA2

Rotina para geração da tabela integradora do cadastro de fornecedores no Protheus para o WIS

@author Allan Constantino Bonfim
@since  12/07/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function RWISISA2(nSA2Recno)

Local cQuery 		:= ""
Local cAQuery		:= GetNextAlias()

Default nSA2Recno	:= 0

cQuery := "SELECT A2_FILIAL, A2_COD, SA2.R_E_C_N_O_ AS SA2REC, A2_MSBLQL "+CHR(13)+CHR(10) 
cQuery += "FROM " +RetSQLName("SA2")+ " SA2 "+CHR(13)+CHR(10)
cQuery += "WHERE SA2.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)

If nSA2Recno > 0
	cQuery += "AND SA2.R_E_C_N_O_ = '"+cValtoChar(nSA2Recno)+"' "+CHR(13)+CHR(10)
EndIf

cQuery += "ORDER BY A2_FILIAL, A2_COD "+CHR(13)+CHR(10)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAQuery, .T., .F. )

While !(cAQuery)->(EOF())
	U_RWISTINT("SA2", (cAQuery)->SA2REC, IIF((cAQuery)->A2_MSBLQL = '1', 16, 15))
	(cAQuery)->(DbSkip())
EndDo

If Select(cAQuery) > 0
	(cAQuery)->(DbCloseArea())
EndIf

Return


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISISA4

Rotina para geração da tabela integradora do cadastro de transportadoras no Protheus para o WIS

@author Allan Constantino Bonfim
@since  12/07/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function RWISISA4(nSA4Recno)

Local cQuery 		:= ""
Local cAQuery		:= GetNextAlias()

Default nSA4Recno	:= 0

cQuery := "SELECT A4_FILIAL, A4_COD, SA4.R_E_C_N_O_ AS SA4REC, A4_MSBLQL "+CHR(13)+CHR(10) 
cQuery += "FROM " +RetSQLName("SA4")+ " SA4 "+CHR(13)+CHR(10)
cQuery += "WHERE SA4.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)

If nSA4Recno > 0
	cQuery += "AND SA4.R_E_C_N_O_ = '"+cValtoChar(nSA4Recno)+"' "+CHR(13)+CHR(10)
EndIf

cQuery += "ORDER BY A4_FILIAL, A4_COD "+CHR(13)+CHR(10)

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAQuery, .T., .F. )

While !(cAQuery)->(EOF())
	U_RWISTINT("SA4", (cAQuery)->SA4REC, IIF((cAQuery)->A4_MSBLQL = '1', 16, 15))
	(cAQuery)->(DbSkip())
EndDo

If Select(cAQuery) > 0
	(cAQuery)->(DbCloseArea())
EndIf

Return


//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISISB1

Rotina para geração da tabela integradora do cadastro de produtos no Protheus para o WIS

@author Allan Constantino Bonfim
@since  12/07/2018
@version P12
@return NIL
/*/
//-----------------------------------------------------------------------------------------
User Function RWISISB1(nSB1Recno)

Local cQuery 		:= ""
Local cAQuery		:= GetNextAlias()
Local cIntWis		:= IIf(FWCodEmp() == '01', "1", IIF(FWCodEmp() == '02', "2", "Z"))

Default nSB1Recno	:= 0

If !Empty(cIntWis)
	cQuery := "SELECT B1_FILIAL, B1_COD, SB1.R_E_C_N_O_ AS SB1REC, B1_MSBLQL "+CHR(13)+CHR(10) 
	cQuery += "FROM " +RetSQLName("SB1")+ " SB1 "+CHR(13)+CHR(10)
	cQuery += "WHERE SB1.D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
	cQuery += "AND B1_ZINTWIS IN ('1', '2') "+CHR(13)+CHR(10)
	
	If nSB1Recno > 0
		cQuery += "AND SB1.R_E_C_N_O_ = '"+cValtoChar(nSB1Recno)+"' "+CHR(13)+CHR(10)
	EndIf
	
	If !EMPTY(cIntWis)
		cQuery += "AND B1_ZINTWIS = '"+cIntWis+"' "+CHR(13)+CHR(10)
	EndIf
	
	cQuery += "ORDER BY B1_FILIAL, B1_COD "+CHR(13)+CHR(10)
	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAQuery, .T., .F. )
	
	While !(cAQuery)->(EOF())
		U_RWISTINT("SB1", (cAQuery)->SB1REC, IIF((cAQuery)->B1_MSBLQL = '1', 16, 15))
		(cAQuery)->(DbSkip())
	EndDo
	
	If Select(cAQuery) > 0
		(cAQuery)->(DbCloseArea())
	EndIf
EndIf

Return


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RWISTCAD

Rotina para integração PROTHEUS x WIS.

@author Allan Constantino Bonfim
@since  05/05/2018
@version P12
@return cProc, Codigo do Processo
/*/
//-------------------------------------------------------------------------------------------------
User Function RWISTCAD(nOpcA, cCodInt)

Local aArea		:= GetArea()
Local aPergs 		:= {}
Local aRet			:= {}
Local cTxtDoc		:= ""
Local nRecCad		:= 0

Default nOpcA		:= 0
Default cCodInt	:= ""


If Empty(cCodInt)                                                                                                                                                                                                                    
	If nOpcA == 1 //Cadastro de Produto	   
		aAdd(aPergs ,{9, cTxtDoc, 200,,.T.})
		aAdd(aPergs ,{1, "Produto: ", SPACE(80), "@!", "NaoVazio()", "SB1", "", 80, .T.})    
	ElseIf nOpcA == 2 //Cadastro de Clientes
		aAdd(aPergs ,{9, cTxtDoc, 200,,.T.})
		aAdd(aPergs ,{1, "Cliente: ", SPACE(TAMSX3("A1_COD")[1]), "@!", "NaoVazio()", "SA1", "", TAMSX3("A1_COD")[1], .T.})    
	ElseIf nOpcA == 3 //Cadastro de Fornecedor
		aAdd(aPergs ,{9, cTxtDoc, 200,,.T.})
		aAdd(aPergs ,{1, "Fornecedor: ", SPACE(TAMSX3("A2_COD")[1]), "@!", "NaoVazio()", "SA2", "", TAMSX3("A2_COD")[1], .T.})    
	ElseIf nOpcA == 4 //Cadastro de Transportadora
		aAdd(aPergs ,{9, cTxtDoc, 200,,.T.})
		aAdd(aPergs ,{1, "Transportadora: ", SPACE(TAMSX3("A4_COD")[1]), "@!", "NaoVazio()", "SA4", "", TAMSX3("A4_COD")[1], .T.})    
	EndIf

	ParamBox(aPergs, "Integração Cadastro WIS", aRet)
Else
	aRet := {cTxtDoc, cCodInt}
EndIf

If nOpcA > 0
	If !Empty(aRet[2])
		If nOpcA == 1 //Cadastro de Produtos
			DbSelectArea("SB1")
			DbSetOrder(1)
			If SB1->(DbSeek(xFilial("SB1")+Alltrim(aRet[2])))
				nRecCad := SB1->(RECNO())
				U_RWISISB1(nRecCad)
				U_RWISCINT("SB1", nRecCad)
			EndIf 
		ElseIf nOpcA == 2 //Cadastro de Clientes
			DbSelectArea("SA1")
			DbSetOrder(1)
			If SA1->(DbSeek(xFilial("SA1")+Alltrim(aRet[2])))
				nRecCad := SA1->(RECNO())
				U_RWISISA1(nRecCad)
				U_RWISCINT("SA1", nRecCad)
				U_RWISCINT("SA2", nRecCad)
			EndIf 
		ElseIf nOpcA == 3 //Cadastro de Fornecedores
			DbSelectArea("SA2")
			DbSetOrder(1)
			If SA2->(DbSeek(xFilial("SA2")+Alltrim(aRet[2])))
				nRecCad := SA2->(RECNO())
				U_RWISISA2(nRecCad)
				U_RWISCINT("SA2", nRecCad)
				U_RWISCINT("SA1", nRecCad)
			EndIf 
		ElseIf nOpcA == 4 //Cadastro de Transportadora
			DbSelectArea("SA4")
			DbSetOrder(1)
			If SA4->(DbSeek(xFilial("SA4")+Alltrim(aRet[2])))
				nRecCad := SA4->(RECNO())
				U_RWISISA4(nRecCad)
				U_RWISCINT("SA4", nRecCad)
			EndIf 	
		EndIf
	EndIf	
EndIf
	
RestArea(aArea)

Return
