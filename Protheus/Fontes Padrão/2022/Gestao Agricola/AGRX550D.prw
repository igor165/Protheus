#INCLUDE 'TOTVS.CH'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRX550D.CH"

//==========================================================
/*****  Funções validar saldo do contrato logístico   *****/
//==========================================================

/*/{Protheus.doc} AGRX550LOG
//Função verificar saldo do contrato logistico
@author marina.muller
@since 23/07/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function AGRX550LOG(oModel)
	Local aArea    := GetArea()
	Local lRet	   := .T.
	Local oMldN9E  := Nil 
	Local oMldNJJ  := Nil
	Local nQdtNeg  := 0
	Local nQtdCon  := 0
	Local nQtdAgd  := 0
	Local nI       := 0
	Local cCodIne  := ""
	Local cItem    := "" 
	Local cCodCtr  := ""
	Local cCodRom  := ""
	Local cMsg     := "" 

	If FwIsInCallStack("AGRA500") .Or. FWIsInCallStack('GFEA523')
		oMldN9E := oModel:GetModel('AGRA500_N9E') //Integracao Romaneio
		oMldNJJ := oModel:GetModel('AGRA500_NJJ')
		
	ElseIf FwIsInCallStack("OGA250")
		oMldN9E := oModel:GetModel('N9EUNICO')    //Integracao Romaneio
		oMldNJJ := oModel:GetModel('NJJUNICO')
		
	ElseIf FwIsInCallStack("AGRA550") .OR. FWIsInCallStack('GFEA522') .OR. (FWIsInCallStack("AGRX550AGD")) .OR. FWIsInCallStack("OGWSPUTATU") 
		oMldN9E := oModel:GetModel('AGRA550_N9E') //Integracao Romaneio
		oMldNJJ := oModel:GetModel('AGRA550_NJJ') 
	EndIf
	
    if ValType(oMldN9E) == 'O'
	    If oMldN9E:Length(.T.) <= 0
	       Return .T.
	    Endif
    
	    //busca as IE´s informadas na GRID
	    For nI := 1 To oMldN9E:Length()    
			oMldN9E:GoLine(nI)
			
			IF !oMldN9E:IsDeleted()	
				cCodIne := oMldN9E:GetValue("N9E_CODINE", oMldN9E:GetLine())
				cItem   := oMldN9E:GetValue("N9E_ITEM",   oMldN9E:GetLine())
				cCodCtr := oMldN9E:GetValue("N9E_CODCTR", oMldN9E:GetLine())
				nQtdAgd := oMldN9E:GetValue("N9E_QTDAGD", oMldN9E:GetLine())
				cCodRom := oMldNJJ:GetValue("NJJ_CODROM")
				
				//verifica se IE possui incoterm que não tem contrato logistico	
				If AGRX550INC(cCodIne)
					If !Empty(cCodIne) .And. !Empty(cItem) .And. !Empty(cCodCtr)
					
					    //busca quantidade com negociação de frete
						nQdtNeg := AX550QTDNE(cCodIne, cItem, cCodCtr)
					
						//busca quantidade consumida romaneio + agendamento
						nQtdCon := AX550QTDCO(cCodIne, cItem, cCodCtr, cCodRom)
						
						//se quantidade agendada for maior que zero
						If nQtdAgd > 0  
						   nQtdCon := nQtdCon + nQtdAgd 
						EndIf
						
						//se quantidade consumida for maior que quantidade negociada
						If nQtdCon > nQdtNeg
						    lRet := .F.
						    Exit
						EndIf 
					Endif
				EndIf	
			EndIf
		Next nI			
		
		If !(lRet)
			cMsg := STR0001 + cCodIne + STR0002 + cCodCtr + STR0003 + cItem // "Favor verificar negociação de frete da IE: " XX " Contrato: " XX " ID Entrega: " XX    
		    oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0004 , cMsg, "", "")  // "Quantidade da negociação de frete excedida."	
		EndIf
	
	endIf
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} AX550QTDNE
//Função busca quantidade com negociação de frete atendida (quantidade contratada)
@author marina.muller
@since 23/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodIne, characters, descricao
@param cItem, characters, descricao
@type function
/*/
Static Function AX550QTDNE(cCodIne, cItem, cCodCtr)
	Local cAliasN9R := GetNextAlias()
	Local nQdtNeg	:= 0

	BeginSql Alias cAliasN9R
	SELECT N9R.N9R_CODINE, N9R.N9R_CODCTR, N9R.N9R_ITEM, SUM(N9R.N9R_QTDCTR) AS QTD_NEGOCIADA
	  FROM %Table:N9R% N9R
	 INNER JOIN %Table:GXR% GXR
	    ON N9R.N9R_FILORI = GXR.GXR_FILIAL
	   AND N9R.N9R_IDREQ  = GXR.GXR_IDREQ
	   AND N9R.%NotDel%
	   AND GXR.%NotDel%
	 INNER JOIN %Table:N7S% N7S
	    ON N7S.N7S_FILORG = N9R.N9R_FILORI
	   AND N7S.N7S_CODINE = N9R.N9R_CODINE
	   AND N7S.N7S_CODCTR = N9R.N9R_CODCTR 
	   AND N7S.N7S_ITEM   = N9R.N9R_ITEM
	   AND N7S.%NotDel%
	 WHERE GXR.GXR_SIT    = '4'              //1=Em Edição;2=Requisitada;3=Em Negociação;4=Atendida;5=Cancelada
	   AND N9R.N9R_CODINE = %Exp:cCodIne%
	   AND N9R.N9R_CODCTR = %Exp:cCodCtr%
	   AND N9R.N9R_ITEM   = %Exp:cItem%
	 GROUP BY N9R.N9R_CODINE, N9R.N9R_CODCTR, N9R.N9R_ITEM
	EndSQL
	
	(cAliasN9R)->(dbGoTop())
    If (cAliasN9R)->(!Eof()) 
    	nQdtNeg := (cAliasN9R)->QTD_NEGOCIADA    
    EndIf
    (cAliasN9R)->(dbCloseArea())

Return nQdtNeg

/*/{Protheus.doc} AX550QTDCO
//Função busca quantidade em romaneio + agendamento (quantidade agendada/consumida) 
@author marina.muller
@since 23/07/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodIne, characters, descricao
@param cItem, characters, descricao
@type function
/*/
Static Function AX550QTDCO(cCodIne, cItem, cCodCtr, cCodRom)
	Local cAliasN9E := GetNextAlias()
	Local nQdtCon	:= 0

	BeginSql Alias cAliasN9E
	SELECT N9E.N9E_CODINE, N9E.N9E_CODCTR, N9E.N9E_ITEM, SUM(N9E.N9E_QTDAGD) AS QTD_CONSUMIDA
	  FROM %Table:NJJ% NJJ
	 INNER JOIN %Table:N9E% N9E
	    ON NJJ.NJJ_FILIAL  = N9E.N9E_FILIAL
	   AND NJJ.NJJ_CODROM  = N9E.N9E_CODROM
	   AND NJJ.%NotDel%
	   AND N9E.%NotDel%
	 INNER JOIN %Table:N7S% N7S
	    ON N7S.N7S_FILORG  = N9E.N9E_FILIAL
	   AND N7S.N7S_CODINE  = N9E.N9E_CODINE
	   AND N7S.N7S_CODCTR  = N9E.N9E_CODCTR
	   AND N7S.N7S_ITEM    = N9E.N9E_ITEM
	   AND N7S.%NotDel%
	 WHERE NJJ.NJJ_STATUS <> '4'             //0=Pendente;1=Completo;2=Atualizado;3=Confirmado;4=Cancelado;5=Pendente Aprovação;6=Previsto
	   AND NJJ.NJJ_TIPO IN ('2','4','6','8') //romaneios de saída (exceto transferência)
	   AND NJJ.NJJ_CODROM <> %Exp:cCodRom%
	   AND N9E.N9E_CODINE  = %Exp:cCodIne%
	   AND N9E.N9E_CODCTR  = %Exp:cCodCtr%
	   AND N9E.N9E_ITEM    = %Exp:cItem%
	 GROUP BY N9E.N9E_CODINE, N9E.N9E_CODCTR, N9E.N9E_ITEM
	EndSQL
	
	(cAliasN9E)->(dbGoTop())
    If (cAliasN9E)->(!Eof()) 
    	nQdtCon := (cAliasN9E)->QTD_CONSUMIDA    
    EndIf
    (cAliasN9E)->(dbCloseArea())

Return nQdtCon

/*/{Protheus.doc} AGRX550INC
//Função valida ou não solicitação de frete de acordo com parametrização incoterm
@author marina.muller
@since 25/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRX550INC(cCodIne)
	Local aArea     := GetArea()
    Local cIncoterm := SuperGetMV("MV_AGRO034",.F.,.F.)
    Local cIncoN7Q  := ""
	Local aIncoterm := {}
	Local nPosicao  := 0
	Local lRet    := .T.
	
	// se parâmetro não estiver vazio
	IF !Empty(cIncoterm)
		// transforma string com os dados do parâmetro em array
		aIncoterm := StrTokArr(cIncoterm, ",")
		
		//busca incoterm na tabela pai da IE
	    dbSelectArea('N7Q')
		N7Q->(dbSetOrder(1))    	
		If N7Q->(MsSeek(FwxFilial("N7Q")+cCodIne)) //N7Q_FILIAL+N7Q_CODINE
			cIncoN7Q := N7Q->N7Q_INCOTE
		EndIf  
		N7Q->(dbCloseArea())
		
		If !Empty(cIncoN7Q)
			
			//verifica se incoterm da N7Q está dentro do array
			nPosicao := Ascan(aIncoterm,{|x| ALLTRIM(x) == ALLTRIM(cIncoN7Q)})
			If nPosicao == 0
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf	
	EndIf
		
	RestArea(aArea)

Return lRet
