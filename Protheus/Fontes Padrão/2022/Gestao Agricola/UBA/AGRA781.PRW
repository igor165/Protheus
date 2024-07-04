#include 'protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "AGRA781.CH"


/*
Programa responsável pelo sincronismo dos registros do cadastro de cadastros do Protheus to  OFFLINE:

usuario   	- USR
conjunto  	- DXE
fardao    	- DXL
fardos    	- DXI
fazenda   	- NN2
variedade 	- NNV
produtor  	- DX8
turno		- SH7

*/  
Function AGRA781()		
	Local aArea	    := GetArea()
	Local aTabsOff    := {"DX6","SB1","NN1","NN2","SH7","NNV","DX8"}
	Local cMsg		:= ""
	Private cTPConect := "TCPIP" 						// Tipo de conexao que sera usada
	
	if isblind()  
    	SchedDef()											// Chama Pergunte pelo Schedule
    else
    	if !Pergunte('AGRA780',.T.) 					// Chama e exibe perguntas
    		return  
    	endif
    endif      
															// Dados do servidor On-Line													
	Private cBDon			:= ALLTRIM(MV_PAR01) 	// Comunicacao com BD Protheus On-Line. Usado na funcao //TCLINK.
	Private cIPSrvOn		:= ALLTRIM(MV_PAR02)		// IP do servidor de aplicacoes
	Private nPortTopOn		:= 7890  					// Porta TCP/IP do TOPCONNECT/DBAccess para aplicação On - LINE
	Private _ConnProtheus 	:= 0 						// Identificador numero da conexão
	Private cUB				:= ALLTRIM(MV_PAR05)		//Unidade de Beneficiamento	 													
															// Dados do servidor Off-Line
														
	Private cBDOff	        := ALLTRIM(MV_PAR03) 			// Comunicacao com BD Protheus OFF-Line. Usado na funcao //TCLINK.
	Private cIPSrvOff       := ALLTRIM(MV_PAR04) 			// IP do servidor de aplicacoes
	Private nPortTopOf      := 7890   						// Porta TCP/IP do TOPCONNECT/DBAccess para aplicação OFF - LINE
	Private _ConnOffline    := 0 								// Identificador numero da conexão
	Private aCamposOff	    := {}	
	TCCONTYPE(cTPConect)
	
	_ConnProtheus	:= TCLink(cBDon,cIPSrvOn,nPortTopOn)  	// conexao com Protheus On-line
	_ConnOffline	:= TCLink(cBDOff,cIPSrvOff,nPortTopOf) // conexao com Protheus Off-line

	cPortOn := cValToChar(nPortTopOn)
	cPortOf := cValToChar(nPortTopOf)

	If _ConnProtheus < 0
		cMsg := STR0001 + cBDon + STR0002 + cIPSrvOn + STR0003 + cPortOn
		FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
	ElseIf _ConnOffline < 0
		cMsg := STR0001 + cBDOff + STR0002+ cIPSrvOff + STR0003 + cPortOf
		FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
	Else
		cMsg := STR0004 + cBDOff
		FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})

		// Buscas as informações de balança, prensa, fardões e as atualiza no banco offline
		lOkOff =  AGRIntgrOnOff(aTabsOff,_ConnProtheus, _ConnOffline) 
		
	EndIf

	TCUnlink ( _ConnProtheus )
	TCUnlink ( _ConnOffline )

	RestArea( aArea )
Return( Nil )

Static Function SchedDef()

Return { "P", "AGRA780", "", {}, "" }

/**
**
** Função de Integração de Banco Online (Protheus) com Offline (MySQL)
** -> As informações das tabelas DX5, DX6, DXC, DXE e DXL são buscas no banco online e atualizadas no
**    offline 
****/
Static Function AGRIntgrOnOff(aTabsOff, _ConnProtheus, _ConnOffline)
	Local nX		  := 0
	Local cAlias	  := ""	
	local lRet      :=.T.
	Local cMsg		:= ""
	
	For nX := 1 to Len( aTabsOff )

		//conectando com o Protheus Online
		TCSETCONN(_ConnProtheus)	
				
		//Verifica se existem registros para ser importados para a base Offline
		if aTabsOff[nX] == "DXE"
			cAlias:= AGRDXELoadBaseOn(aTabsOff[nX])
		elseif  aTabsOff[nX] == "SB1"
			cAlias:= AGRSB1LoadBaseOn(aTabsOff[nX])
		elseif  aTabsOff[nX] == "SH7"
			cAlias:= "SH7"
		elseif  aTabsOff[nX] == "DX6"
			cAlias:= AGRDX6LoadBaseOn(aTabsOff[nX])	
		elseif  aTabsOff[nX] == "DX8"
			cAlias:= AGRDX8LoadBaseOn(aTabsOff[nX])					
		else
			cAlias:= AGRLoadBaseOn(aTabsOff[nX])
		endif
		 
		While (cAlias)->(!Eof())

			Begin Transaction
			//Importa os registro para a base Offline
				TCSETCONN(_ConnProtheus)
				//Grava os registros na base Offline.
				lRet:= AGRUpdateOff(cAlias, aTabsOff[nX], _ConnProtheus, _ConnOffline) 
			        	            
			End Transaction
			
			If !lRet
				cMsg := STR0005 + aTabsOff[nX]
				FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
				Mostraerro("c:\temp\","UBAlog.log")
			EndIf

			(cAlias)->(DbSkip())
                
		EndDo

		(cAlias)->(DbCloseArea())
	Next nX

Return (lRet)
/*---------------------------------------------------------------------**/


	/**-------------------------------------------------------------**/

/****
**
** Função para o carregamento dos registros da base ONLINE
**
****/
Static Function AGRLoadBaseOn(cTab)
	Local cQry		  := ""
	Local cAliasQry := ""
	
	TCSETCONN(_ConnProtheus)
		
	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	cQry := "SELECT (R_E_C_N_O_) RECNO, " + cTab + ".* FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry += " WHERE " + cTab + "_FILIAL = '"+xFilial(cTab)+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()
Return(cAliasQry)
/**------------------------------------------------------------**/
/****
**
** Função para o carregamento dos registros de Produtores da base ONLINE
**
****/
Static Function AGRDX8LoadBaseOn(cTab)
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	cQry := "SELECT DX8_FILIAL,DX8_CODIGO,DX8_LOJA,DX8_NOME,CC2_MUN,CC2_EST FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry += " LEFT JOIN "+RetSqlName('CC2')+" ON DX8_COD_MU=CC2_CODMUN AND DX8_EST=CC2_EST"
	cQry += " WHERE " + cTab + "_FILIAL = '"+xFilial(cTab)+"'"
	cQry += " AND DX8.D_E_L_E_T_ <> '*'"	
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()

Return(cAliasQry)
/**------------------------------------------------------------**/
/****
**
** Função para o carregamento dos registros de Balanças da base ONLINE
**
****/
Static Function AGRDX6LoadBaseOn(cTab, cod_Usuario)
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	cQry := "SELECT DX6_CODUSU, DX6_CODBAL, DX6_MODAL, DX5_TIPVEL, DX5_NBITDA, "
	cQry += "DX5_DESCRI, DX5_CONFLU, DX5_MARCA, DX5_MODELO, DX5_TIPPAR, DX6_FILIAL, "
	cQry += "DX5_TIPPOR, DX5_STATUS, DX5_NBITPA, DX5_TIMOUT"
	cQry += " FROM " + RetSqlName(cTab) 
    cQry += " LEFT JOIN " + RetSqlName('DX5') +" ON DX6_CODBAL=DX5_CODIGO  and DX6_FILIAL = DX5_FILIAL "
	cQry += " WHERE " + cTab + "_FILIAL = '"+xFilial(cTab)+"' AND "
	cQry += RetSqlName(cTab) + ".D_E_L_E_T_ <> '*'"	
	
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()

Return(cAliasQry)


/****
**
** Função para o carregamento dos registros da base ONLINE
**
****/
Static Function AGRSB1LoadBaseOn(cTab)
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	
	cQry := "SELECT DISTINCT B1_FILIAL,B1_COD,B1_DESC FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry +=+" INNER JOIN " + RetSqlName('DXL') +" ON B1_COD=DXL_CODPRO"
	cQry += " WHERE B1_FILIAL = '"+ALLTRIM(xFilial(cTab)) +"'"
	cQry += " union "
	cQry += "SELECT DISTINCT B1_FILIAL,B1_COD,B1_DESC FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry +=+" INNER JOIN " + RetSqlName('DXE') +" ON B1_COD=DXE_CODPRO"
	cQry += " WHERE B1_FILIAL = '"+ALLTRIM(xFilial(cTab)) +"'"		
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()

Return(cAliasQry)
	/**------------------------------------------------------------**/	


/****
**
** Função para o carregamento dos registros da base ONLINE
**
****/
Static Function AGRRecNOSB1LoadBaseOn(cTab,cProduto)
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	cQry := "SELECT B1_FILIAL, B1_COD, B1_DESC FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry += " WHERE B1_FILIAL = '"+xFilial(cTab)+"'"
	cQry += " AND B1_COD = '" +ALLTRIM(cProduto)+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()

Return(cAliasQry)
/**------------------------------------------------------------**/	

	

/****
**
** Função para o carregamento dos registros da tabela DXL da base ONLINE
**
****/
Static Function AGRDXCLoadBaseOn(cTab,cCodigo)
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	cQry := "SELECT (R_E_C_N_O_) RECNO, " + cTab + ".* FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry += " WHERE " + cTab + "_FILIAL = '"+xFilial(cTab)+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " AND DXC_CODIGO = '"+cCodigo+"'"
	cQry += " AND DXC_PLUMA = '1'"
		
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()

Return(cAliasQry)
	/**------------------------------------------------------------**/
	
/****
**
** Função para o carregamento dos registros da tabela DXF da base ONLINE
**
****/
Static Function AGRDXFLoadBaseOn(cTab,cCodigo)
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	cQry := "SELECT (R_E_C_N_O_) RECNO, " + cTab + ".* FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry += " WHERE " + cTab + "_FILIAL = '"+xFilial(cTab)+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
	cQry += " AND DXF_CODIGO = '"+cCodigo+"'"		
	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()
	
Return(cAliasQry)
	/**------------------------------------------------------------**/	
/****
**
** Função para o carregamento dos registros da tabela DXE da base ONLINE
**
****/
Static Function AGRDXELoadBaseOn(cTab)
	Local cQry		  := ""
	Local cAliasQry := ""

	cAliasQry:= GetNextAlias( )
	
	//Seleciona os registros que ainda não foram sincronizados
	cQry := "SELECT (R_E_C_N_O_) RECNO, " + cTab + ".* FROM "
	cQry += RetSqlName(cTab) +" "+ cTab
	cQry += " WHERE " + cTab + "_FILIAL = '"+xFilial(cTab)+"'"
	cQry += " AND D_E_L_E_T_ <> '*'"
		
	cQry := ChangeQuery( cQry )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()

Return(cAliasQry)	
	
/*	/**-------------------------------------------------------------------**/

/***
**
** Função para a gravação dos registros na base OFFLINE
**
**/

Static Function AGRUpdateOff (cAlias, cTab, _ConnProtheus, _ConnOffline)
	Local aArea 	      	:= GetArea()
	Local nSql          	:= 0
	Local cStatusFardao 	:= ""	
	Local NomeEmpresa 	:= FWEmpName(cEmpAnt)
	Local lRetorno       := .t.
	Local cOperacao		:= ""	
	Local cStatement 		:= ""
	Local cMsg			:= ""
	If cTab == "DXE"
		cDXFAlias := AGRDXFLoadBaseOn("DXF",(cAlias)->DXE_CODIGO)			
		cDXCAlias := AGRDXCLoadBaseOn("DXC",(cAlias)->DXE_CODIGO)
		cProdAlias := AGRRecNOSB1LoadBaseOn("SB1",(cAlias)->DXE_CODPRO)
		If !(AGRFindOff("conjunto"," WHERE codConjunto = '" + cValToChar((cAlias)->DXE_CODIGO) + "'"	 ))
			cOperacao := "I"
			cStatement := "INSERT INTO conjunto(codFilial,codConjunto,codSAI,codUBA,descricao,empresa,percentualDeRendimento,pesoAdicional,pesoMaximo,pesoMinimo,codProduto)
			cStatement += "VALUES ("
			cStatement += "'" + cValToChar((cAlias)->DXE_FILIAL)  	+ "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_CODIGO)  	+ "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_CODSAI)  	+ "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_UBA)     	+ "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_DESCRI) 	+ "',"
			cStatement += "'" + cValToChar(NomeEmpresa)			  	+ "',"		
			cStatement += "'" + cValToChar((cDXCAlias)->DXC_PERC) 	+ "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_PSBAL)    + "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_PSMAX) 	+ "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_PSMIN)    + "',"
			cStatement += "'" + cValToChar((cAlias)->DXE_CODPRO) 	+ "')"		
		else	
			cOperacao := "U"
			cStatement := "UPDATE conjunto SET "
			cStatement += "codSai = '" + cValToChar((cAlias)->DXE_CODSAI) + "',"
			cStatement += "codUBA = '" + cValToChar((cAlias)->DXE_UBA) + "',"
			cStatement += "descricao = '" + cValToChar((cAlias)->DXE_DESCRI) + "',"
			cStatement += "empresa = '" + cValToChar(NomeEmpresa) + "',"				
			cStatement += "pesoAdicional = '" +cValToChar((cAlias)->DXE_PSBAL) + "',"
			cStatement += "percentualDeRendimento = '" + cValToChar((cDXCAlias)->DXC_PERC) + "',"
			cStatement += "codProduto = '" + cValToChar((cAlias)->DXE_CODPRO) + "'"
			cStatement += " WHERE codConjunto = '" + cValToChar((cAlias)->DXE_CODIGO) + "'"		

		endif
			
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0007 +cBDOff+ STR0008 + cValToChar((cAlias)->DXE_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
		elseIf cOperacao =  "I"	
			cMsg := STR0009 +cBDOff+ STR0008 + cValToChar((cAlias)->DXE_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})	
		endif
													
	Endif
		
	If cTab == "NN2"
		If !(AGRFindOff("fazenda"," WHERE CodFazenda = '" + cValToChar((cAlias)->NN2_CODIGO) + "'"	 ))
			cOperacao := "I"
			cStatement := "INSERT INTO fazenda VALUES ("
			cStatement += "'" + cValToChar((cAlias)->NN2_CODIGO) + "',"
			cStatement += "'" + CVALTOCHAR((CALIAS)->NN2_FILIAL)  + "',"
			cStatement += "'" + cValToChar((cAlias)->NN2_NOME) + "')"			
		else	
			cOperacao := "U"    
			cStatement := "UPDATE fazenda SET "
			cStatement += "descricao = ' " + cValToChar((cAlias)->NN2_NOME) + "'"
			cStatement += "WHERE codFazenda = '" + cValToChar((cAlias)->NN2_CODIGO) +"'"
		endif
		
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0010 +cBDOff+ STR0008 + cValToChar((cAlias)->NN2_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
		elseIf cOperacao =  "I"	
			cMsg := STR0011 +cBDOff+ STR0008 + cValToChar((cAlias)->NN2_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
		Endif				
	Endif


	If cTab == "SH7"	
		If !(AGRFindOff("turno"," WHERE codturno = '" + cValToChar((cAlias)->H7_CODIGO) + "'"	 ))
			cOperacao := "I"
			cStatement := "INSERT INTO turno VALUES ("
			cStatement += "'" + cValToChar((cAlias)->H7_CODIGO) + "',"
			cStatement += "'" + cValToChar((cAlias)->H7_DESCRI) + "')"
	    else 
	    	cOperacao := "U"  
			cStatement := "UPDATE turno SET "
			cStatement += "descricao = ' " + cValToChar((cAlias)->H7_DESCRI) + "'"
			cStatement += "WHERE codTurno = '" + cValToChar((cAlias)->H7_CODIGO) +"'"
		endif 
		
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0012 +cBDOff+ STR0008 + cValToChar((cAlias)->H7_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})	
		elseIf cOperacao =  "I"	
			cMsg := STR0013 +cBDOff+ STR0008 + cValToChar((cAlias)->H7_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})	
		Endif					
	Endif
	
	If cTab == "NN1"
		If !(AGRFindOff("safra"," WHERE codsafra = '" + cValToChar((cAlias)->NN1_ANO+(cAlias)->NN1_SEQ) + "'"	 ))		
			cOperacao := "I"  
			cStatement := "INSERT INTO safra VALUES ("
			cStatement += "'" + cValToChar((cAlias)->NN1_ANO+(cAlias)->NN1_SEQ) + "',"
			cStatement += "'" + cValToChar((cAlias)->NN1_FILIAL)  + "',"		
			cStatement += "'" + cValToChar((cAlias)->NN1_DESCRI) + "')"	
		else
			cOperacao := "U"  
			cStatement := "UPDATE safra SET "
			cStatement += "descricao = ' " + cValToChar((cAlias)->NN1_DESCRI) + "'"
			cStatement += "WHERE codSafra = '" + cValToChar((cAlias)->NN1_ANO+(cAlias)->NN1_SEQ) +"'"	
		endif
		
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0014 +cBDOff+ STR0008 + cValToChar((cAlias)->NN1_ANO+(cAlias)->NN1_SEQ)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})	
		elseIf cOperacao =  "I"	
			cMsg := STR0015 +cBDOff+ STR0008 + cValToChar((cAlias)->NN1_ANO+(cAlias)->NN1_SEQ)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})		
		Endif	  	
	Endif
	
	
	If cTab == "NNV"
		If !(AGRFindOff("variedade"," WHERE codvariedade = '" + cValToChar((cAlias)->NNV_CODIGO)+ "'"	 ))		
			cOperacao := "I"  
			cStatement := "INSERT INTO variedade VALUES ("
			cStatement += "'" + cValToChar((cAlias)->NNV_CODIGO) + "',"
			cStatement += "'" + cValToChar((cAlias)->NNV_FILIAL)  + "',"
			cStatement += "'" + cValToChar((cAlias)->NNV_DESCRI) + "')"
		else
			cOperacao := "U"  	
			cStatement := "UPDATE variedade SET "
			cStatement += "descricao = ' " + cValToChar((cAlias)->NNV_DESCRI) + "'"
			cStatement += "WHERE codVariedade = '" + cValToChar((cAlias)->NNV_CODIGO) +"'"
		endif
		
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0016 +cBDOff+ STR0008 + cValToChar((cAlias)->NNV_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})	
		elseIf cOperacao =  "I"	
			cMsg := STR0017 +cBDOff+ STR0008 + cValToChar((cAlias)->NNV_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})	
		Endif				
	Endif
		
	If cTab == "SB1"
		If !(AGRFindOff("produto"," WHERE codproduto= '" + cValToChar((cAlias)->B1_COD)+ "'"	 ))		
			cOperacao := "I"  			
			cStatement := "INSERT INTO produto VALUES ("		
			cStatement += "'" + cValToChar((cAlias)->B1_COD) + "',"
			cStatement += "'" + cValToChar((cAlias)->B1_FILIAL)  + "',"		
			cStatement += "'" + cValToChar((cAlias)->B1_DESC) + "')"
		else
			cOperacao := "U"  		
			cStatement := "UPDATE produto SET "
			cStatement += "descricao = '" + cValToChar((cAlias)->B1_DESC) + "'"	
			cStatement += "WHERE codProduto = '" + cValToChar((cAlias)->B1_COD) + "'"
		endif	
		
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0018 +cBDOff+ STR0008 + cValToChar((cAlias)->B1_COD)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
		elseIf cOperacao =  "I"	
			cMsg := STR0019 +cBDOff+ STR0008 + cValToChar((cAlias)->B1_COD)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
		Endif	
	Endif
	
	If cTab == "DX8"	
		If !(AGRFindOff("produtor"," WHERE codprodutor= '" + cValToChar((cAlias)->DX8_CODIGO)+ "' AND codLoja = '" + cValToChar((cAlias)->DX8_LOJA) + "'" ))	
			cOperacao := "I" 				
			cStatement := "INSERT INTO produtor (codFilial,codLoja,codProdutor,cidadeProdutor,descricao)"	
			cStatement += "VALUES ("
			cStatement += "'" + ALLTRIM(cFilAnt)  + "',"	//pega a filial logada
			cStatement += "'" + cValToChar((cAlias)->DX8_LOJA) + "',"
			cStatement += "'" + cValToChar((cAlias)->DX8_CODIGO) + "',"
			cStatement += "'" + AllTrim(cValToChar((cAlias)->CC2_MUN))  +"-"+ AllTrim(cValToChar((cAlias)->CC2_EST))  + "',"  //CIDADE DO PRODUTOR		
			cStatement += "'" + cValToChar((cAlias)->DX8_NOME) + "')"
		else
			cOperacao := "U"  		
			cStatement := "UPDATE produtor SET "
			cStatement += "descricao = '" + AllTrim(cValToChar((cAlias)->DX8_NOME)) + "',"
			cStatement += "cidadeprodutor =  '" + AllTrim(cValToChar((cAlias)->CC2_MUN))  +"-"+ AllTrim(cValToChar((cAlias)->CC2_EST))  + "' "
			cStatement += "WHERE codProdutor = '" + cValToChar((cAlias)->DX8_CODIGO) + "'"
			cStatement += "  and codLoja     = '" + cValToChar((cAlias)->DX8_LOJA) + "'"
			cStatement += "  and codFilial   = '" + ALLTRIM(cFilAnt)  + "'"	 
		endif
		
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0020 +cBDOff+ STR0008 + cValToChar((cAlias)->DX8_CODIGO)+" - "+ cValToChar((cAlias)->DX8_LOJA)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
		elseIf cOperacao =  "I"	
			cMsg := STR0021 +cBDOff+ STR0008 + cValToChar((cAlias)->DX8_CODIGO)+" - "+ cValToChar((cAlias)->DX8_LOJA)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
		Endif	
	Endif
				
	If cTab == "DX6"
		If PswSeek((cAlias)->DX6_CODUSU)
			aUser := PswRet()
		endif
		If !(AGRFindOff("balancadousuario"," WHERE codUsuario= '" +  ALLTRIM(cValToChar((cAlias)->DX6_CODUSU)) + "' and codbalanca = '" + ALLTRIM(cValToChar((cAlias)->DX6_CODBAL))+ "'"	 ))
			If !(AGRFindOff("usuario"," WHERE codUsuario = '" + cValToChar((cAlias)->DX6_CODUSU) + "'"	 ))	
				cOperacao := "I" 			
				cStatement := "INSERT INTO usuario (codFilial,codUsuario,login) VALUES ("
				cStatement += "'" + cValToChar((cAlias)->DX6_FILIAL)  + "',"
				cStatement += "'" + cValToChar((cAlias)->DX6_CODUSU) + "',"
				cStatement += "'" + UsrRetName(cValToChar((cAlias)->DX6_CODUSU)) + "')"
				PswOrder(1)		
				nSql := TcSqlExec(cStatement)			
				If nSql < 0
					lRetorno := .f.
					FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
				elseIf cOperacao =  "U"
					cMsg := STR0022 +cBDOff+ STR0008 +USRRETNAME(cValToChar((cAlias)->DX6_CODUSU))+ STR0024 + ALLTRIM(cValToChar((cAlias)->DX5_DESCRI))
					FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
				elseIf cOperacao =  "I"	
					cMsg := STR0023 +cBDOff+ STR0008 +USRRETNAME(cValToChar((cAlias)->DX6_CODUSU))+ STR0024 + ALLTRIM(cValToChar((cAlias)->DX5_DESCRI))
					FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
				Endif	
				
			endif
			If lRetorno =  .T.
				cOperacao := "I" 		
				cStatement := "INSERT INTO balancadousuario(baudrate,codfilial,codbalanca,databits,descricao,flowcontrolmode,marca,"
				cStatement += "modalidade,modelo,parity,porta,status,stopbits,timeout,codUsuario)"
				cStatement += "VALUES ("
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_TIPVEL)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX6_FILIAL)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX6_CODBAL)) + "',"	
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_NBITDA)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_DESCRI)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_CONFLU)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_MARCA)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX6_MODAL)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_MODELO)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_TIPPAR)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_TIPPOR)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_STATUS)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_NBITPA)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX5_TIMOUT)) + "',"
				cStatement += "'" + ALLTRIM(cValToChar((cAlias)->DX6_CODUSU)) + "')"
			endif	
					
		else
			Operacao := "U" 
			cStatement := "UPDATE balancadousuario SET "
			cStatement += "baudrate  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_TIPVEL)) + "',"
			cStatement += "databits  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_NBITDA)) + "',"
			cStatement += "descricao  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_DESCRI)) + "',"
			cStatement += "flowcontrolmode  = '" 	+ ALLTRIM(cValToChar((cAlias)->DX5_CONFLU)) + "',"
			cStatement += "marca  = '" 				+ ALLTRIM(cValToChar((cAlias)->DX5_MARCA)) + "',"
			cStatement += "modalidade  = '" 		+ ALLTRIM(cValToChar((cAlias)->DX6_MODAL)) + "',"
			cStatement += "modelo  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_MODELO)) + "',"
			cStatement += "parity  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_TIPPAR)) + "',"
			cStatement += "porta  = '" 				+ ALLTRIM(cValToChar((cAlias)->DX5_TIPPOR)) + "',"
			cStatement += "status  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_STATUS)) + "',"
			cStatement += "stopbits  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_NBITPA)) + "',"
			cStatement += "timeout  = '" 			+ ALLTRIM(cValToChar((cAlias)->DX5_TIMOUT)) + "' "
			cStatement += "where  codUsuario = '"	+ ALLTRIM(cValToChar((cAlias)->DX6_CODUSU)) + "' and codbalanca = '" + ALLTRIM(cValToChar((cAlias)->DX6_CODBAL)) + "'"			
		Endif
		
		if !Empty(cStatement)
			nSql := TcSqlExec(cStatement)			
			If nSql < 0
				lRetorno := .f.
				FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
			elseIf cOperacao =  "U"
				cMsg := STR0025 +cBDOff+ STR0008 +USRRETNAME(cValToChar((cAlias)->DX6_CODUSU))+ STR0024 + ALLTRIM(cValToChar((cAlias)->DX5_DESCRI))
				FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
			elseIf cOperacao =  "I"	
				cMsg := STR0026 +cBDOff+ STR0008 +USRRETNAME(cValToChar((cAlias)->DX6_CODUSU))+ STR0024 + ALLTRIM(cValToChar((cAlias)->DX5_DESCRI))
				FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})
			Endif	
		endif			
	Endif		
		
			
	If cTab == "DXL"
		cStatusFardao := ""
		DO case
			case (cAlias)->DXL_STATUS == "1"
				cStatusFardao := "PREVISTO"		
			case (cAlias)->DXL_STATUS == "2"
				cStatusFardao := "EMROMANEIO"		
			case (cAlias)->DXL_STATUS == "3"
				cStatusFardao := "DISPONIVEL"		
			case (cAlias)->DXL_STATUS == "4"
				cStatusFardao := "EMBENEFICIAMENTO"
			case (cAlias)->DXL_STATUS == "5" 	
				cStatusFardao := "BENEFICIADO"
		EndCase

		If !(AGRFindOff("fardao"," WHERE FARDAO = '" +  cValToChar((cAlias)->DXL_CODIGO)+ "'"	 ))
			cOperacao := "I" 	
			cStatement := "INSERT INTO fardao(codFilial,FARDAO,PERCENTUAL, PESOLIQUIDO, PESOLIQUIDOFARDOS, QTD_FARDOS, STATUSFARDAO, "
			cStatement += "codFazenda,codProduto, codProdutor, codSafra, codVariedade, pesoPrevisto, codLoja ) " 
			cStatement += "VALUES ("
			cStatement += "'" + cValToChar( (cAlias)->DXL_FILIAL) + "',"  //filial		
			cStatement += "'" + cValToChar( (cAlias)->DXL_CODIGO) + "',"  //fardao
			cStatement += "'" + cValToChar( (cAlias)->DXL_RDMTO)  + "',"  //percentual
			cStatement += "'" + cValToChar( (cAlias)->DXL_PSLIQU) + "',"  //peso liquido
			cStatement += "'0',"                                          //qtd fardos -> no inicio ainda não tem fardos beneficiados
			cStatement += "'0',"                                          //Peso liquidos dos fardos -> no inicio ainda não tem fardos beneficiados
			cStatement += "'" + cStatusFardao + "',"  					    //status
			cStatement += "'" + cValToChar((cAlias)->DXL_FAZ)    + "',"    //fazenda
			cStatement += "'" + cValToChar((cAlias)->DXL_CODPRO) + "',"   //produto
			cStatement += "'" + cValToChar((cAlias)->DXL_PRDTOR) + "',"   //produtor
			cStatement += "'" + cValToChar((cAlias)->DXL_SAFRA)  + "',"   //safra		
			cStatement += "'" + cValToChar((cAlias)->DXL_CODVAR) + "',"   //variedade
			cStatement += "'" + cValToChar((cAlias)->DXL_PSESTI) + "',"   //Peso Previsto
			cStatement += "'" + cValToChar((cAlias)->DXL_LJPRO)  + "')"   //loja
		else 
			cOperacao := "U"
			cStatement := "UPDATE fardao SET "
			cStatement +="PERCENTUAL='"+cValToChar( (cAlias)->DXL_RDMTO)+"',"									
			cStatement +="PESOLIQUIDO='"+cValToChar( (cAlias)->DXL_PSLIQU)+"',"
			cStatement +="pesoPrevisto='"+cValToChar( (cAlias)->DXL_PSESTI)+"',"
			cStatement +="STATUSFARDAO='"+cStatusFardao+"' "
			cStatement += "WHERE FARDAO = '" + cValToChar((cAlias)->DXL_CODIGO) + "'"				
			cStatement += " AND STATUSFARDAO in ('PREVISTO','EMROMANEIO')"				
		endif
		
		nSql := TcSqlExec(cStatement)			
		If nSql < 0
			lRetorno := .f.
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',TcSqlERROR() , 0, 0, {})
		elseIf cOperacao =  "U"
			cMsg := STR0027 +cBDOff+ STR0008 + cValToChar( (cAlias)->DXL_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})		
		elseIf cOperacao =  "I"	
			cMsg := STR0028 +cBDOff+ STR0008 + cValToChar( (cAlias)->DXL_CODIGO)
			FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {})	
		Endif					
	Endif
	
	RestArea(aArea)
Return(lRetorno)

Static Function AGRFindOff(cTab,cwhere)
	Local aArea 	    := GetArea()
	Local cQry		  := ""
	Local cAliasQry := ""
	Local lFind	  := .F.
	TCSETCONN(_ConnOffline)	
	cAliasQry:= GetNextAlias( )
	cQry := " Select * from "+cTab+" "+cwhere
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )
	DbGoTop()
	
	if (cAliasQry)->(!Eof())
		lFind := .T.
	else 
		lFind := .F.
	endif		
	(cAliasQry)->(DbCloseArea())
RestArea(aArea)	
Return(lFind)
