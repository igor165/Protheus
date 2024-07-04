#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===================================================
/*****  Funções da rotina AGRA500 - Romaneios  *****/
//===================================================



/*/{Protheus.doc} AGRX500BLT
//Retorna boletin para o fardao integrado
//Se ja foi gerado, retorna o mesmo por integridade com o PIMS
@author carlos.augusto
@since 21/04/2018
@version undefined
@type function
/*/
Function AGRX500IBT(cCodUni)
	Local cBoletim := "0"
	Local cQry		 := ""
	Local cAliasQry  := ""
	Local cZeroSpc	 := PADR("0",TamSx3("DX0_BOLETI")[1] ," ")
	
	If .Not. Empty(cCodUni)
		//Procura o Boletim gerado na ultima integracao ALTERACAO
		cAliasQry := GetNextAlias()
		cQry := " SELECT DX0.DX0_BOLETI "
		cQry += "	     FROM " + RetSqlName("DX0") + " DX0 "
		cQry += "	     WHERE DX0.DX0_FILIAL = '"+ FwXfilial("DX0") +"' "
		cQry += "		AND DX0.DX0_CODUNI = '"+ cCodUni +"' AND (DX0.DX0_BOLETI <> '" + cZeroSpc + " ' AND DX0.DX0_BOLETI <> '') " //Pode estar deletado tambem
		cQry := ChangeQuery(cQry)	
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),cAliasQry,.F.,.T.)
	
		dbSelectArea(cAliasQry)
		(cAliasQry)->(DbGoTop())
		
		If (cAliasQry)->(.Not. Eof())
			cBoletim := (cAliasQry)->DX0_BOLETI
		EndIf
		(cAliasQry)->(DbCloseArea())	
	EndIf
	
	//Se nao teve, gera Boletin
	If cBoletim = "0"
		cBoletim := GetSXENum('DX0','DX0_BOLETI')
	EndIf

Return cBoletim


/*/{Protheus.doc} AGRX500RAT
//Como o PIMS nao aceita demais na pesagem, foi realizado este rateio
@author carlos.augusto
@since 07/05/2018
@version undefined
@type function
/*/
Function AGRX500IRT()
	Local nX
	Local nCount	:= 1
	Local nTam        := 0
		
	Local nPesoBruto
	Local nBrutoRat
	Local nFaltBruto
	
	Local nPesoLiq
	Local nLiqRat
	Local nFaltLiq
	
	Local nPesDesc
	Local nDescRat
	Local nFaltDesc
	Local oModel	:= FwModelActive()

	//Carrego as estruturas do modelo.
	oMldDX0 := oModel:GetModel('AGRA500_DX0') 
	oMldNJJ	:= IIF(IsInCallStack("AGRA500") .Or. IsInCallStack("AGRA500POP"), oModel:GetModel( "AGRA500_NJJ" ), oModel:GetModel( "NJJUNICO" ))

	For nX := 1 to oMldDX0:Length() 
		oMldDX0:GoLine( nX )
		If .Not. oMldDX0:isDeleted()
			nTam ++
		Endif
	Next nX
	
	nPesoBruto	:= IIF(oMldNJJ:GetValue("NJJ_PESO1") > oMldNJJ:GetValue("NJJ_PESO2"), oMldNJJ:GetValue("NJJ_PESO1"), oMldNJJ:GetValue("NJJ_PESO2"))
	nBrutoRat	:= NOROUND((nPesoBruto / nTam),0)
	nFaltBruto	:= nPesoBruto - (nBrutoRat * nTam)
	
	nPesoLiq	:= IIF(oMldNJJ:GetValue("NJJ_PESO2") > oMldNJJ:GetValue("NJJ_PESO1"), oMldNJJ:GetValue("NJJ_PESO1"), oMldNJJ:GetValue("NJJ_PESO2"))
	nLiqRat		:= NOROUND((nPesoLiq / nTam),0)
	nFaltLiq	:= nPesoLiq - (nLiqRat * nTam)

	nPesDesc	:= oMldNJJ:GetValue("NJJ_PSDESC")
	nDescRat	:= NOROUND((nPesDesc / nTam),0)
	nFaltDesc	:= nPesDesc - (nDescRat * nTam)

	For nX := 1 to oMldDX0:Length()
		oMldDX0:GoLine( nX )
		If .Not. oMldDX0:isDeleted()

			If nCount == 1
				oMldDX0:LoadValue("DX0_PSBRUT", nFaltBruto + nBrutoRat)
				oMldDX0:LoadValue("DX0_TARA", nFaltLiq + nLiqRat)
				oMldDX0:LoadValue("DX0_PSDESC", nFaltDesc + nDescRat)
			Else
				oMldDX0:LoadValue("DX0_PSBRUT", nBrutoRat)
				oMldDX0:LoadValue("DX0_TARA", 	nLiqRat)
				oMldDX0:LoadValue("DX0_PSDESC", nDescRat)
			EndIf
			nCount ++
		Endif
	Next nX

Return 

