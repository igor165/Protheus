#Include "Protheus.ch"
#Include "ApWizard.ch"
#Include "CRMA040.ch"
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CA240IPAO4()

Importação da linha para a tabela AO4

18/09/2017 - Função descontinuada - mantida devido a layouts Legado

@sample	CA240IPAO4( lInterface, aInfoAdc, aInfoLay, aDSaida, lErro )

@param		lInterface		Executado com interface .T. ou sem interface .F.
      		aInfoAdc		Array com informações adicionais
      		aInfoLay		Array das definições do layout
      		aDSaida			Array com os dados de Saída
      		lErro			Indica se houve erro na rotina automática

@return	Nenhum		

@author	Thiago Tavares
@since		27/05/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function CA240IPAO4( lInterface, aInfoAdc, aInfoLay, aDSaida, lErro )

Local nCodigo    := 0 
Local cCodigo    := ""
Local nLoja      := 0
Local cLoja      := ""
Local lContinua  := .F.
Local aArea      := GetArea()
Local aAreaEnt   := ( cAliasEnt )->( GetArea() )
Local nX         := 0

Default lInterface	:= .F.
Default aDSaida		:= {}
Default lErro		:= .F.

If !lErro

	Do Case 

		Case cAliasEnt == "SA1" 
			
			nCod := aScan( aDSaida[1, 4, 1], { |x| AllTrim( x[1] ) == "A1_COD" } )
			If nCod > 0
				cCodigo := aDSaida[1, 4, 1, nCod, 2]

				nLoja := aScan( aDSaida[1, 4, 1], { |x| AllTrim( x[1] ) == "A1_LOJA" } )
				If nLoja > 0
					lContinua := .T.
					cLoja := aDSaida[1, 4, 1, nLoja, 2]
				EndIf
			EndIf
				 
		Case cAliasEnt == "ACH"

			If ValType( aDSaida ) == "A"
				nCod := aScan( aDSaida[1, 4, 1], { |x| AllTrim( x[1] ) == "ACH_CODIGO" } )
				If nCod > 0
					cCodigo := aDSaida[1, 4, 1, nCod, 2]
	
					nLoja := aScan( aDSaida[1, 4, 1], { |x| AllTrim( x[1] ) == "ACH_LOJA" } )
					If nLoja > 0
						lContinua := .T.
						cLoja := aDSaida[1, 4, 1, nLoja, 2]
					EndIf
				EndIf
			ElseIf ValType( aDSaida ) == "O" .And. aDSaida:ClassName() == "FWFORMMODEL"
				cCodigo := FwFldGet( "ACH_CODIGO" )		
				cLoja   := FwFldGet( "ACH_LOJA" )  
			EndIf				 

		Case cAliasEnt == "SUS"
			
			If ValType( aDSaida ) == "A"
				nCod := aScan( aDSaida[1, 4, 1], { |x| AllTrim( x[1] ) == "US_COD" } )
				If nCod > 0
					cCodigo := aDSaida[1, 4, 1, nCod, 2]
	
					nLoja := aScan( aDSaida[1, 4, 1], { |x| AllTrim( x[1] ) == "US_LOJA" } )
					If nLoja > 0
						lContinua := .T.
						cLoja := aDSaida[1, 4, 1, nLoja, 2]
					EndIf
				EndIf
			ElseIf ValType( aDSaida ) == "O" .And. aDSaida:ClassName() == "FWFORMMODEL"  
				cCodigo := FwFldGet( "US_COD" )
				cLoja   := FwFldGet( "US_LOJA" )  
			EndIf				 
						 
	EndCase

EndIf

RestArea(aArea)
RestArea(aAreaEnt)

Return Nil