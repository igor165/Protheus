#INCLUDE "PROTHEUS.CH"
Static __cORGSPFL := SuperGetMv( "MV_ORGSPFL", .F., 'N' )
/*/
зддддддддддбдддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддддд©
ЁFun┤└o    ЁSQBSPFilter  Ё Autor ЁRogerio Ribeiro      Ё Data Ё//          Ё
цддддддддддедддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддддд╢
ЁDescri┤└o ЁSuperFiltro da Tabela SQB                                      Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSintaxe   Ё<Vide Parametros Formais>                                      Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁParametrosЁ<Vide Parametros Formais>                                      Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁSX2etorno ЁcExp = Expressao de filtro para a tabela SQB                   Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
ЁObserva┤└oЁ                                                               Ё
цддддддддддеддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё Uso      ЁGenerico                                                       Ё
цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢
Ё             ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL.            Ё
цддддддддддддбддддддддддбддддддддддддддддбддддддддддддддддддддддддддддддддд╢
ЁProgramador Ё Data     Ё BOPS/FNC       ЁMotivo da Alteracao              Ё
цддддддддддддеддддддддддеддддддддддддддддеддддддддддддддддддддддддддддддддд╢
ЁCecilia C.  Ё04/08/2014ЁTQFZO4          ЁIncluido o fonte da 11 para a 12.Ё
юддддддддддддаддддддддддаддддддддддддддддаддддддддддддддддддддддддддддддддды/*/

Function SQBSPFilter()
	Local aSaveArea := GetArea()

	Local cExp     := ""
	Local cQuery, cQueryTemp
	Local cNameFun := ""				//Funcao que esta sendo utilizada (Chamada)
	Local cCondSpFl:= ""				//Condicao de filtro do ChkRh()
	Local cAliasQry:= GetNextAlias()

	Local nPermitidos, nNegados

	Local aDeptos:= {}
	Local cUserId
	Local aGrupos 
	
	If __cORGSPFL # 'S'
		Return cExp
	Endif	
		
	cUserId	:= RetCodUsr()
	If cUserId = "000000" 
		Return cExp
	EndIf
	
	aGrupos   := UsrRetGrp(cUserName)
	If (AScan(aGrupos, { |x| x == "000000"}) > 0)
		Return cExp
	EndIf	


	If ( SuperGetMV("MV_ORGCFG", .F., "0") $ "1/2" .and. __cORGSPFL== "S" )

		cQuery :=	"SELECT "
		cQuery += 		"###FIELDS### "
		cQuery += 	"FROM " + RetSqlName("RD4") + " K "
		cQuery += 	"RIGHT OUTER JOIN " + RetSqlName("RBZ") + " Z ON "
		cQuery += 		"Z.RBZ_CODVIS = K.RD4_CODIGO AND "
		cQuery += 		"Z.RBZ_FILVIS = K.RD4_FILIAL AND "
		cQuery += 		"Z.RBZ_CODIDE = K.RD4_CODIDE AND "
		cQuery += 		"Z.RBZ_FILIDE = K.RD4_FILIDE AND "
		cQuery += 		"Z.RBZ_TIPO = '1' AND "
		cQuery += 		"Z.RBZ_ACAO IN ('2','4','6') AND "
		cQuery += 		"Z.RBZ_CODUSR = '" + __cUserID + "' AND "
		cQuery +=		"Z.D_E_L_E_T_ = ' ' "
		cQuery +=	"RIGHT OUTER JOIN " + RetSqlName("RD4") + " R ON "
		cQuery +=		"R.RD4_CODIGO = Z.RBZ_CODVIS AND "
		cQuery +=	 	"R.RD4_FILIAL = Z.RBZ_FILVIS AND "
		cQuery +=		"R.RD4_CHAVE LIKE RTRIM(K.RD4_CHAVE)+'%' AND "
		cQuery +=		"R.D_E_L_E_T_ = ' ' "
		cQuery += 	"RIGHT OUTER JOIN " + RetSqlName("SQB") + " SQB ON "
		cQuery += 		"SQB.QB_FILIAL = R.RD4_FILIDE AND "
		cQuery += 		"SQB.QB_DEPTO = R.RD4_CODIDE AND "
		cQuery += 		"K.D_E_L_E_T_ = ' ' "
		cQuery += 	"LEFT OUTER JOIN " + RetSqlName("RBZ") + " X ON "
		cQuery +=		"X.RBZ_CODUSR = Z.RBZ_CODUSR AND "
		cQuery +=		"X.RBZ_CODIDE = R.RD4_CODIDE AND "
		cQuery += 		"X.RBZ_FILIDE = R.RD4_FILIDE AND "
		cQuery += 		"X.RBZ_TIPO = '3' AND "
		cQuery += 		"X.RBZ_ACAO IN ('3','5','7') AND "
		cQuery += 		"X.D_E_L_E_T_=' ' "
		cQuery += 	"WHERE "
		cQuery += 		"SQB.D_E_L_E_T_ = ' ' AND "
		cQuery += 		"###CONDITION###"
	                                         
	
		cQueryTemp:= StrTran(cQuery, "###FIELDS###", "COUNT(*) AS QUANTIDADE")
		cQueryTemp:= StrTran(cQueryTemp, "###CONDITION###", "(X.RBZ_FILIAL IS NULL AND K.RD4_FILIAL IS NOT NULL)")
		cQueryTemp:= ChangeQuery(cQueryTemp)
		DBUseArea(.T., "TOPCONN", TcGenQry(,,cQueryTemp), cAliasQry, .T., .T.)
	
		nPermitidos:= (cAliasQry)->QUANTIDADE
	               
		DBCloseArea()
	
		cQueryTemp:= StrTran(cQuery, "###FIELDS###", "COUNT(*) AS QUANTIDADE")
		cQueryTemp:= StrTran(cQueryTemp, "###CONDITION###", "(X.RBZ_FILIAL IS NOT NULL OR K.RD4_FILIAL IS NULL)")
		cQueryTemp:= ChangeQuery(cQueryTemp)
		DBUseArea(.T., "TOPCONN", TcGenQry(,,cQueryTemp), cAliasQry, .T., .T.)
	
		nNegados:= (cAliasQry)->QUANTIDADE
	
		DBCloseArea()
	
		cQueryTemp:= StrTran(cQuery, "###FIELDS###", "QB_DEPTO")
		
		IF nNegados > nPermitidos
			cQueryTemp:= StrTran(cQueryTemp, "###CONDITION###", "(X.RBZ_FILIAL IS NULL AND K.RD4_FILIAL IS NOT NULL)")
		Else
			cQueryTemp:= StrTran(cQueryTemp, "###CONDITION###", "(X.RBZ_FILIAL IS NOT NULL OR K.RD4_FILIAL IS NULL)")
		EndIf
	
		cQueryTemp:= ChangeQuery(cQueryTemp + " ORDER BY QB_FILIAL, QB_DEPTO")  
	
		DBUseArea(.T., "TOPCONN", TcGenQry(,,cQueryTemp), cAliasQry, .T., .T.)	
		
		If !Empty((cAliasQry)->QB_DEPTO)
			
			DBEval({|| AAdd(aDeptos, (cAliasQry)->QB_DEPTO) })
			DBCloseArea()
		
			cExp:= IIF(nNegados < nPermitidos, "!", "") + "QB_DEPTO $ '"
			AEval(aDeptos, {|cDepto| cExp+= cDepto + "/"})	
			cExp:= SubStr(cExp, 1, len(cExp)-1) + "'"
				
		Endif
		
	EndIf
	
	DbSelectArea("SQB")
	cCondSpFl := " " + GetGPEXSpFl("SQB","QB")

	If ( Empty(cExp) )
		cExp := cCondSpFl
	Else
		cExp += " .and. " + cCondSpFl
	EndIf

	/*/
	зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	Ё Caso a expressao de filtro seja maior que 4000 caracteres   Ё
	Ё imprime o tamanho no server								  Ё	
	юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды/*/	
	If ( Len(cExp) > 4000 )
		ConOut("Tamanho: " + Str(Len(cExp)))
	EndIf		

	RestArea(aSaveArea)
Return cExp
