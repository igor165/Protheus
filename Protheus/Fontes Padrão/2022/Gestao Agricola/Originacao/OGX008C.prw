#INCLUDE "Protheus.ch"

/*{Protheus.doc} OGX008CDTV()
Retorna as datas de vencimento dos itens do romaneio

@type  Function
@author francisco.nunes
@since 29/05/2018
@version 1.0
@param  cFilRom, Character, Filial do Romaneio
@param  cCodRom, Character, C�digo do Romaneio
@param  cItRom, Character, Item do Romaneio
@param  nVlrUn, Number, Valor unit�rio da comercializa��o (NJM) do romaneio
@param aDatasVenc, Array, Datas de vencimento e seus respectivos volumes
@param aVlrUni, Array, Valores unit�rios da comercializa��o (Utilizado para m�dia)
*/
Function OGX008CDTV(cFilRom, cCodRom, cItRom, nVlrUn, aDatasVenc, aVlrUni)
	Local cQuery    := ""
	Local cAliasQry := ""
	Local nVlrUnDt  := 0
	Local nX	    := 0
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT N9K.N9K_DTVENC, "
	cQuery += "        SUM(N9K.N9K_QTDVNC) AS QTDVNC "	
	cQuery += " FROM " + RetSqlName('N9K')+ " N9K "	
	cQuery += " WHERE N9K.D_E_L_E_T_ = '' "
	cQuery += "   AND N9K.N9K_FILIAL = '" + cFilRom + "' "
	cQuery += "   AND N9K.N9K_CODROM = '" + cCodRom + "' "
	cQuery += "   AND N9K.N9K_ITEROM = '" + cItRom + "' "
	cQuery += " GROUP BY N9K.N9K_DTVENC "
	
	cQuery := ChangeQuery(cQuery)
	If select("cAliasQry") <> 0
		(cAliasQry)->(DbCloseArea())
	EndIf
	
	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)

	DbSelectArea(cAliasQry)  
	(cAliasQry)->(DbGoTop())
	While .Not. (cAliasQry)->(Eof())
		
		// O sistema permite apenas 4 parcelas de vencimento na SC5 ent�o, caso ultrapasse, ser� somado na �ltima
		If Len(aDatasVenc) = 4
			aDatasVenc[4][2] += (cAliasQry)->QTDVNC
			
			For nX := 1 to Len(aVlrUni)
				nVlrUnDt += aVlrUni[nX]
			Next nX
			
			// M�dia de pre�o
			aDatasVenc[4][3] := (nVlrUnDt + nVlrUn) / (Len(aVlrUni) + 1)  
			
			Aadd(aVlrUni, nVlrUn)			
		Else
			Aadd(aDatasVenc, {(cAliasQry)->N9K_DTVENC, (cAliasQry)->QTDVNC, nVlrUn})
			
			If Len(aDatasVenc) = 4
				Aadd(aVlrUni, nVlrUn)
			EndIf
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo 
	(cAliasQry)->(DbCloseArea())
	
Return .T. 
