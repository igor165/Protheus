#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'PARMTYPE.CH'
#INCLUDE 'FILEIO.CH'
#INCLUDE 'JURA262.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA262
Faz a importação de distribuições via fornecedor OITO. 

@param 	 cOperacao - 1=Busca, 2=Confirma
@author  Ronaldo Gonçalves de Oliveira
@since 	 23/04/2018
@version 1.0
/*/ 
//-------------------------------------------------------------------
Function JURA262(cUser, cPwd, cEndPoint, cOperacao, aDados, lTeste)

Local oRest    		:= Nil     
Local aHeader     	:= {"Authorization: Basic " + Encode64(cUser + ":" + cPwd)}
Local oJson       	:= tJsonParser():New()
Local cStrJson	 	:= ""
Local aJsonfields 	:= {}
Local nRetParser  	:= 0
Local lRet        	:= .F.
Local nItem			:= 0
Local aAux			:= {}
Local aDadosNZZ		:= {}
Local nTeste		:= 0
Local dDtAud		:= cTod("  /  /  ")
Local cHrAud 		:= ""

Default aDados		:= {}
Default lTeste 		:= .F.
		
	//Atualiza tabela NZP
	//AtuNZP("2", cUser)
	
	oRest := FWRest():New(cEndPoint)
	
	//Busca as Distribuições na OITO
	if cOperacao == '1'
	
		oRest:SetPath("/monitor/api/externo/14/distribuido/processos/distribuidos")

		If oRest:Get(aHeader)
			cStrJson := oRest:GetResult()
			cStrJson := DecodeUtf8(cStrJson, "")
			
			lRet := oJson:Json_Hash(cStrJson, Len(cStrJson), @aJsonfields, @nRetParser)
		
			If lRet
			
				// Armazena os dados da distribição no banco
				If (lTeste .And. (len(aJsonfields[1]) > 5))
				 	nTeste := 5
				Else 
					nTeste := len(aJsonfields[1]) 
				EndIf  
	
				For nItem := 1 To nTeste
				
					aAux := {}
					Aadd(aAux, {"NZZ_LOGIN" , cUser} )
					Aadd(aAux, {"NZZ_ESCRI" , '' } )
					Aadd(aAux, {"NZZ_DTDIST", (J262GetVal (aJsonfields[1][nItem][2], 'dataDistribuicao')/1000/3600/24)+cTod('01/01/1970')} )
					Aadd(aAux, {"NZZ_TERMO" , '' } )
					Aadd(aAux, {"NZZ_TRIBUN", J262GetVal (aJsonfields[1][nItem][2], 'tribunal')} )
					Aadd(aAux, {"NZZ_NUMPRO", AllTrim(J262GetVal (aJsonfields[1][nItem][2], 'numeroProcesso'))} )
					Aadd(aAux, {"NZZ_OCORRE", J262GetVal (aJsonfields[1][nItem][2], 'assunto')} )
					Aadd(aAux, {"NZZ_REU"   , J262GetVal (aJsonfields[1][nItem][2], 'reus') } )
					Aadd(aAux, {"NZZ_AUTOR" , J262GetVal (aJsonfields[1][nItem][2], 'autores') } )
					Aadd(aAux, {"NZZ_FORUM" , J262GetVal (aJsonfields[1][nItem][2], 'foro') } )
					Aadd(aAux, {"NZZ_VARA"  , J262GetVal (aJsonfields[1][nItem][2], 'vara') } )
					Aadd(aAux, {"NZZ_CIDADE", J262GetVal (aJsonfields[1][nItem][2], 'comarca') } )
					Aadd(aAux, {"NZZ_ESTADO", J262GetVal (aJsonfields[1][nItem][2], 'uf') } )
					Aadd(aAux, {"NZZ_VALOR" , J262GetVal (aJsonfields[1][nItem][2], 'valor')} )
					Aadd(aAux, {"NZZ_ADVOGA", J262GetVal (aJsonfields[1][nItem][2], 'advogados')} )
					
					dDtAud := J262GetVal (aJsonfields[1][nItem][2], 'audiencias')
					
					If Empty(dDtAud)
						Aadd(aAux, {"NZZ_DTAUDI", cTod("  /  /  ")} )
					Else	
						Aadd(aAux, {"NZZ_DTAUDI", cTod(substr(dDtAud, 1, 10))})
					EndIf
					
					cHrAud := J262GetVal (aJsonfields[1][nItem][2], 'audiencias')
					
					If Empty(cHrAud)
						Aadd(aAux, {"NZZ_HRAUDI", ''} )
					Else	
						Aadd(aAux, {"NZZ_HRAUDI", AllTrim(substr(cHrAud, 11, Len(cHrAud)-10))})
					EndIf
					
					Aadd(aAux, {"NZZ_LINK", J262GetVal(aJsonfields[1][nItem][2], 'linksDocumento')} )
									  
					Aadd(aDadosNZZ, aClone(aAux))
					
				Next nItem
			EndIf	
		Else
		    JurConOut(STR0001, {"GET - " + oRest:GetLastError()})	//"Distribuições, falha na conexão com a OITO: #1"
		EndIf

	//Confirma o Recebimento das Distribuições na OITO
	ElseIf !lTeste
	
		oRest:SetPath("/monitor/api/externo/14/distribuido/processos/baixa_distribuicao")
		
		Aadd(aHeader, "Content-Type:application/json")
		
		For nItem := 1 To len(aDados)
			oRest:SetPostParams('{ "numeroProcesso" : "' + J262GetVal (aDados[nItem], "NZZ_NUMPRO") + '" }')
			If oRest:Post(aHeader)
			   oRest:GetResult()
			Else
			   JurConOut(STR0001, {"POST - " + oRest:GetLastError()})	//"Distribuições, falha na conexão com a OITO: #1"
			EndIf
		Next	
	EndIf
	
	FwFreeObj(oJson)
	FwFreeObj(oRest)
	
	aSize(aJsonfields, 0)

return aDadosNZZ

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA262
Retorna o Valor referente a TAG de um Json. 

@author  Ronaldo Gonçalves de Oliveira
@since 	 24/04/2018
@version 1.0
/*/
//-------------------------------------------------------------------
Function J262GetVal (aJson, cTag)

	Local cRet := ''
	Local nPos := 0

	nPos := Ascan(aJson, {|x| x[1] == cTag})
	
	If nPos > 0
		cRet := aJson[nPos][2]
	EndIf	
	
Return cRet