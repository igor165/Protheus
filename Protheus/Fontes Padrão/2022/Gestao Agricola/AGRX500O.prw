#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX500O.CH"

//======================================================
/*****  Funções relacionadas análise de crédito  *****/
//======================================================

/*/{Protheus.doc} AGRX500VlC
Função para análise de crédito (considera os pedidos em aberto, os romaneios em andamento sem pedido e o romaneio corrente)
@author silvana.torres / marina.muller
@since 17/07/2018
@version undefined
@param oModel, object, descricao
@param cCodRom, characters, descricao
@type function
/*/
Function AGRX500VlC(oModel, cCodRom)
	Local lRet 		:= .T.
	Local lCredito  := .T.
	Local aSaveArea := GetArea()
	Local oMldN9E 	
	Local cCodBlq   := ""
	Local cCodEnt   := ""
	Local cLjEnt    := ""              
 	Local nVlAcumC  := 0 //valor acumulado do romaneio corrente
 	Local nVlAcumA  := 0 //valor acumulado dos romaneios em andamento
 	Local nVlAcumCt := 0 //valor acumulado dos contratos abertos ou iniciados
 	Local nVlAcumT  := 0 //valor acumulado total 
	
	Local oModel	:= FwModelActive() 
	Local oView   := FwViewActive()

	If FwIsInCallStack("AGRA500") .Or. FWIsInCallStack('GFEA523')
		oMldN9E := oModel:GetModel('AGRA500_N9E') //Integracao Romaneio
		oMldNJJ := oModel:GetModel('AGRA500_NJJ')
	ElseIf FwIsInCallStack("OGA250") .OR. FwIsInCallStack("OGX290NFUT") 
		oMldN9E := oModel:GetModel('N9EUNICO') //Integracao Romaneio
	ElseIf FwIsInCallStack("AGRA550")
		oMldN9E := oModel:GetModel('AGRA550_N9E') //Integracao Romaneio
	EndIf
    
    If oMldN9E:Length(.T.) <= 0
       Return .T.
    Endif   	

 	cCodEnt := M->NJJ_CODENT
	cLjEnt  := M->NJJ_LOJENT
    
	//se houver o objeto do njj
	If Type('oMldNJJ') == 'O'
		//ele pega a placa via getvalue
		cPlaca := oMldNJJ:GetValue('NJJ_PLACA')
	Else
		//se não, ele pega da memoria do campo 
		cPlaca := M->NJJ_PLACA 	
	EndIf

	If Empty(cPlaca) .And. !FwIsInCallStack("OGX290NFUT") //Global Venda Futura
		lRet := .F.
		oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0001 , STR0002, "", "") //"Placa do veículo não informada."#"Favor informar a placa do veículo no romaneio!"
	Else
		nVlAcumC 	:= AX500FVlRo(oMldN9E, cCodRom, @cCodEnt, @cLjEnt) //busca o valor do romaneio corrente (contrato da IE)		
		nVlAcumA 	:= AX500FVlAn(cCodEnt, cLjEnt) //busca o valor dos romaneios em andamento
		nVlAcumCt	:= AX500FVlCt(cCodEnt, cLjEnt) //busca o valor dos contratos iniciados ou abertos

		nVlAcumT 	:= nVlAcumC + nVlAcumA + nVlAcumCt 

	    //chama função para fazer avaliação de crédito por cliente (fonte FATXFUN.PRX)
		lCredito := MaAvalCred(cCodEnt, cLjEnt, nVlAcumT, 1, .T., @cCodBlq)

		If !(lCredito)
			If cCodBlq == "01"
				lRet := .F.
				oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0003 , STR0004, "", "") //"Limite de credito excedido para este cliente/loja."#"Favor analisar o limite de crédito do cliente/loja!"

			ElseIf cCodBlq == "04"
				lRet := .F.
				oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0005 , STR0006, "", "") //"Data de vencimento do limite de credito expirou para este cliente/loja."#"Favor analisar a data de vencimento do limite de crédito do cliente/loja!"
			EndIf
		EndIf
	EndIf
    
	RestArea(aSaveArea)

Return lRet

/*/{Protheus.doc} AGRX500VCC
Função para análise de crédito do cliente do contrato(considera os pedidos em aberto e os romaneios em andamento sem pedido)
@author silvana.torres
@since 19/07/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Function AGRX500VCC(oModel)
	Local lRet 		:= .T.
	Local lCredito  := .T.
	Local aSaveArea := GetArea()
	Local cCodBlq   := ""
 	Local nVlAcumA  := 0 //valor acumulado dos romaneios em andamento
 	Local nVlAcumCt := 0 //valor acumulado dos contratos abertos ou iniciados
 	Local nVlAcumT  := 0 //valor acumulado dos romaneios em andamento mais o valor total previsto do contrato
 	Local lBloqCtr	:= SuperGetMv('MV_AGRB005', , .F.) //Análise de crédito bloqueia contrato?
	
	nVlAcumA 	:= AX500FVlAn(NJR->NJR_CODENT, NJR->NJR_LOJENT) 
	nVlAcumCt	:= AX500FVlCt(NJR->NJR_CODENT, NJR->NJR_LOJENT) 
	
	nVlAcumT := nVlAcumA + nVlAcumCt + NJR->NJR_VLRTOT

    //chama função para fazer avaliação de crédito por cliente (fonte FATXFUN.PRX)
	lCredito := MaAvalCred(NJR->NJR_CODENT, NJR->NJR_LOJENT, nVlAcumT, 1, .T., @cCodBlq)

	If !(lCredito)
		If cCodBlq == "01"
			Help( ,,STR0003,, STR0004 , 1, 0 ) //"Limite de credito excedido para este cliente/loja."#"Favor analisar o limite de crédito do cliente/loja!"
			If lBloqCtr
				lRet := .F.
			EndIf
		ElseIf cCodBlq == "04"
			Help( ,,STR0005,, STR0006 , 1, 0 ) //"Data de vencimento do limite de credito expirou para este cliente/loja."#"Favor analisar a data de vencimento do limite de crédito do cliente/loja!"
			If lBloqCtr
				lRet := .F.
			EndIf
		EndIf
	EndIf
    
	RestArea(aSaveArea)

Return lRet

/*/{Protheus.doc} AX500FVlRo
Busca o valor do romaneio corrente multiplicado pela capacidade máxima do veículo do romaneio
@author silvana.torres / marina.muller
@since 17/07/2018
@version undefined
@param oMldN9E, object, descricao
@param cCodRom, characters, descricao
@type function
/*/
Static Function AX500FVlRo(oMldN9E, cCodRom, cCodEnt, cLjEnt)
	Local nVlUniCtr 	:= 0
	Local nVlAcumu		:= 0
	Local cCodCtr		:= ""
	Local nCpMxCm		:= 0
	Local nQtdReg	    := 0
	Local nI            := 0 
	Local cCodIne       := ""
	Local cFilOri       := ""
	
    nQtdReg := oMldN9E:Length(.T.)
    
    If !Empty(M->NJJ_PSLIQU)
        If nQtdReg > 0
	    	nCpMxCm := M->NJJ_PSLIQU / nQtdReg
	    Else
	    	nCpMxCm := M->NJJ_PSLIQU
	    EndIf
    Else
	    //busca capacidade do veiculo pela placa informada romaneio corrente
		dbSelectArea('DA3')
		DA3->(dbSetOrder(3))    	
		If DA3->(MsSeek(FwxFilial("DA3")+NJJ->NJJ_PLACA)) //DA3_FILIAL+DA3_PLACA
		    If nQtdReg > 0
		    	nCpMxCm := DA3->DA3_CAPACM / nQtdReg
		    Else
		    	nCpMxCm := DA3->DA3_CAPACM
		    EndIf
		EndIf
		DA3->(dbCloseArea())
	EndIf	
    
    For nI := 1 To oMldN9E:Length()    
		oMldN9E:GoLine(nI)
		
		IF !oMldN9E:IsDeleted()	
			//se já tiver contrato carregado na N9E utiliza desta tabela
			If !Empty(oMldN9E:GetValue("N9E_CODCTR", oMldN9E:GetLine()))
				cCodCtr := oMldN9E:GetValue("N9E_CODCTR", oMldN9E:GetLine())
			//se não tiver busca pela IE contrato da N7S
			Else
				cCodIne := oMldN9E:GetValue("N9E_CODINE", oMldN9E:GetLine())
				cFilOri := oMldN9E:GetValue("N9E_FILIAL", oMldN9E:GetLine())
	          
				If trim(cFilOri) = ""
					cFilOri := ""
				EndIf
				
				dbSelectArea('N7S')
				N7S->(dbSetOrder(3))
				If N7S->(MsSeek(FwxFilial("N7S")+cCodIne+cFilOri)) //N7S_FILIAL+N7S_CODINE+N7S_FILORG
					cCodCtr := N7S->N7S_CODCTR
				EndIf
				N7S->(dbCloseArea())
			EndIf
			  
			//busca valor unitário do contrato para romaneio corrente
			If !Empty(cCodCtr)
				dbSelectArea('NJR')
			    NJR->(dbSetOrder(1))    	
			    If NJR->(MsSeek(FwxFilial("NJR")+cCodCtr)) //NJR_FILIAL+NJR_CODCTR
			        nVlUniCtr := NJR->NJR_VLRUNI
			        cCodEnt   := NJR->NJR_CODENT
			        cLjEnt    := NJR->NJR_LOJENT 
			    EndIf
			    NJR->(dbCloseArea())
			EndIf
		    
			//acumula o cálculo do valor unitário do contrato x capacidade máxima do veículo romaneio corrente 
			nVlAcumu := nVlAcumu + (nVlUniCtr * nCpMxCm)
		EndIf			    
	Next nI

Return nVlAcumu

/*/{Protheus.doc} AX500FVlAn
Busca o valor dos romaneios em andamento multiplicados pela capacidade máxima do veículo de cada romaneio
@author silvana.torres / marina.muller
@since 17/07/2018
@version undefined
@param cCodEnt, characters, descricao
@param cLjEnt, characters, descricao
@type function
/*/
Static Function AX500FVlAn(cCodEnt, cLjEnt)
	Local cAliasNJJ := GetNextAlias()
	Local nVlUniCtr	:= 0
	Local nCpMxCm	:= 0
	Local nVlAcumu	:= 0
	Local nPsLiqu   := 0
    Local cQuery	:= ""
    Local cRetQuery := ""
    
	//busca os romaneios de saídas em andamento para entidade/loja + agendamentos de saídas em andamento
	cQuery := " SELECT NJJ.NJJ_CODROM, N9E.N9E_CODINE, NJJ.NJJ_PLACA AS PLACA, "
	cQuery += "	       NJJ.NJJ_PSLIQU AS PSLIQU, NJR.NJR_VLRUNI AS VLRUNI      "
	cQuery += "   FROM " + RetSqlName('NJJ')+ " NJJ "
	cQuery += "  INNER JOIN " + RetSqlName('N9E')+ " N9E   "
	cQuery += "     ON NJJ.NJJ_FILIAL  = N9E.N9E_FILIAL    "
	cQuery += "    AND NJJ.NJJ_CODROM  = N9E.N9E_CODROM    "
	cQuery += "    AND NJJ.D_E_L_E_T_  = '' "
	cQuery += "    AND N9E.D_E_L_E_T_  = '' "
	cQuery += "  INNER JOIN " + RetSqlName('NJM')+ " NJM   "
	cQuery += "     ON NJM.NJM_FILIAL  = NJJ.NJJ_FILIAL    "
	cQuery += "    AND NJM.NJM_CODROM  = NJJ.NJJ_CODROM    "
	cQuery += "    AND NJM.D_E_L_E_T_  = '' "
	cQuery += "  INNER JOIN " + RetSqlName('N7S')+ " N7S   "
	cQuery += "     ON N7S.N7S_FILORG  = N9E.N9E_FILIAL    "   
	cQuery += "    AND N7S.N7S_CODINE  = N9E.N9E_CODINE    "   
	cQuery += "    AND N7S.D_E_L_E_T_  = '' "
	cQuery += "  INNER JOIN " + RetSqlName('NJR')+ " NJR   "    
	cQuery += "     ON NJR.NJR_CODCTR  = N7S.N7S_CODCTR    "    
	cQuery += "    AND NJR.D_E_L_E_T_  = '' "
	cQuery += "  WHERE NJJ.NJJ_TIPO IN ('2','4','6','8')   "    
	cQuery += "    AND NJJ.NJJ_STATUS NOT IN ('3','4','6') " 
	cQuery += "    AND NJJ.NJJ_CODENT  = '"+ cCodEnt 	+"'" 
	cQuery += "    AND NJJ.NJJ_LOJENT  = '"+ cLjEnt 	+"'"   
	cQuery += "    AND NJJ.NJJ_PLACA   <> ''"
	cQuery += "    AND N9E.N9E_CODINE  <> ''"   
	cQuery += "    AND NJM.NJM_PEDIDO  =  ''"                  
	cQuery += "    AND NJR.NJR_VLRUNI  > 0  "   
	cQuery += " UNION "   
	cQuery += " SELECT NJJ.NJJ_CODROM, N9E.N9E_CODINE, NJJ.NJJ_PLACA AS PLACA, "
	cQuery += "        NJJ.NJJ_PSLIQU AS PSLIQU, NJR.NJR_VLRUNI AS VLRUNI      "   
	cQuery += "   FROM " + RetSqlName('NJJ')+ " NJJ "   
	cQuery += "  INNER JOIN " + RetSqlName('N9E')+ " N9E   " 
    cQuery += "     ON NJJ.NJJ_FILIAL  = N9E.N9E_FILIAL    "
    cQuery += "    AND NJJ.NJJ_CODROM  = N9E.N9E_CODROM    "  
    cQuery += "    AND NJJ.D_E_L_E_T_  = '' " 
    cQuery += "    AND N9E.D_E_L_E_T_  = '' "
    cQuery += "  INNER JOIN " + RetSqlName('N7S')+ " N7S   "   
    cQuery += "     ON N7S.N7S_FILORG  = N9E.N9E_FILIAL    "   
    cQuery += "    AND N7S.N7S_CODINE  = N9E.N9E_CODINE    "  
    cQuery += "    AND N7S.D_E_L_E_T_  = '' " 
    cQuery += "  INNER JOIN " + RetSqlName('NJR')+ " NJR   "    
    cQuery += "     ON NJR.NJR_CODCTR  = N7S.N7S_CODCTR    "   
    cQuery += "    AND NJR.D_E_L_E_T_  = '' "   
    cQuery += "  WHERE NJJ.NJJ_TIPO IN ('2','4','6','8')   " 
    cQuery += "    AND NJJ.NJJ_STATUS  = '6' "    
    cQuery += "    AND NJJ.NJJ_CODENT  = ''  "    
    cQuery += "    AND NJJ.NJJ_LOJENT  = ''  " 
    cQuery += "    AND NJJ.NJJ_PLACA   <> '' "     
    cQuery += "    AND N9E.N9E_CODINE  <> '' "   
    cQuery += "    AND NJR.NJR_VLRUNI  > 0   "   
    
    //ponto de entrada para manipular query de romaneio/agendamento em andamento
    If ExistBlock("AGR500QA")
        cRetQuery := ExecBlock("AGR500QA",.F.,.F.,{cQuery})
        If ValType(cRetQuery) == "C"
            cQuery := cRetQuery
        EndIf
    EndIf
           
	//--Identifica se tabela esta aberta e fecha
	If Select(cAliasNJJ) <> 0
		(cAliasNJJ)->(dbCloseArea())
	EndIf
				
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasNJJ,.T.,.T.)
	If (cAliasNJJ)->( !Eof() )
	
		(cAliasNJJ)->(dbGoTop())
	    While (cAliasNJJ)->(!Eof())
	        
	        //atribui valor unitário do contrato
	        nVlUniCtr := (cAliasNJJ)->VLRUNI
	        
	        //atribui valor peso líquido
	        nPsLiqu   := (cAliasNJJ)->PSLIQU 
	    	
	    	If nPsLiqu > 0 
	    	   nCpMxCm := nPsLiqu 
	    	Else
		    	//busca capacidade do veiculo pela placa informada romaneio
		    	dbSelectArea('DA3')
			    DA3->(dbSetOrder(3))    	
			    If DA3->(MsSeek(FwxFilial("DA3")+(cAliasNJJ)->PLACA)) //DA3_FILIAL+DA3_PLACA
			       //atribui capacidade máxima do veículo
			       nCpMxCm := DA3->DA3_CAPACM
			    EndIf
			    DA3->(dbCloseArea())
			EndIf    
	
		    If nCpMxCm > 0
		    	//acumula o cálculo do valor unitário do contrato x capacidade máxima do veículo 
		    	nVlAcumu := nVlAcumu + (nVlUniCtr * nCpMxCm)
		    EndIf 
	
	    	(cAliasNJJ)->(dbSkip())
	    
	    EndDo
	    (cAliasNJJ)->( dbCloseArea() )
	EndIf
	    
Return nVlAcumu


/*/{Protheus.doc} AX500FVlCt
Busca o total do valor dos contratos em aberto ou iniciados 
@author silvana.torres
@since 19/07/2018
@version undefined
@param cCodEnt, characters, descricao
@param cLjEnt, characters, descricao
@type function
/*/
Static Function AX500FVlCt(cCodEnt, cLjEnt)
	Local cAliasN9A := GetNextAlias()
	Local nVlAcumu	:= 0
	Local cQuery	:= ""
	Local cRetQuery := ""

	cQuery := " SELECT SUM(N9A_SDOINS) AS saldoIE   " 
	cQuery += "   FROM " + RetSqlName('N9A')+ " N9A "
	cQuery += "  INNER JOIN " + RetSqlName('NJR')+ " NJR "  
    cQuery += "     ON NJR.NJR_FILIAL = N9A.N9A_FILIAL   "    
    cQuery += "    AND NJR.NJR_CODCTR = N9A.N9A_CODCTR   "    
    cQuery += "    AND N9A.D_E_L_E_T_ = '' "       
    cQuery += "    AND NJR.D_E_L_E_T_ = '' "    
    cQuery += "  WHERE N9A.N9A_CODENT = '"+ cCodEnt  +"'"     
    cQuery += "    AND N9A.N9A_LOJENT = '"+ cLjEnt 	 +"'"       
    cQuery += "    AND NJR.NJR_MODELO IN ('2','3') "   
    cQuery += "    AND NJR.NJR_STATUS IN ('A','I') "     
    
    //ponto de entrada para manipular query de contrato em andamento      
    If ExistBlock("AGR500QC")
        cRetQuery := ExecBlock("AGR500QC",.F.,.F.,{cQuery})
        If ValType(cRetQuery) == "C"
            cQuery := cRetQuery
        EndIf
    EndIf
           
	//--Identifica se tabela esta aberta e fecha
	If Select(cAliasN9A) <> 0
		(cAliasN9A)->(dbCloseArea())
	EndIf
				
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasN9A,.T.,.T.)
	(cAliasN9A)->(dbGoTop())
    If (cAliasN9A)->(!Eof()) 
    	nVlAcumu := (cAliasN9A)->saldoIE    
    EndIf
    (cAliasN9A)->(dbCloseArea())

Return nVlAcumu
