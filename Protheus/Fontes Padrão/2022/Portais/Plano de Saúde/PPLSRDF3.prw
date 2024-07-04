#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"

Static cBanco := AllTrim( TCGetDB() )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BA9.  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 do cid.		 													  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
user function PLSF3BA9()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cAlias	:= "BA9"
LOCAL cCampos	:= "BA9_CODDOE,DESCRICAO|Descrição|@!|200|C"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BA9_CODDOE, (CASE WHEN BA9_ABREVI != '' THEN BA9_ABREVI ELSE BA9_DOENCA END) as DESCRICAO, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BA9_CODDOE LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BA9_ABREVI LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3BR8C  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 da Tabela Padrao - consulta							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLF3BR8C()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cVldGen 	:= paramixb[3] //cCodPadSSol
LOCAL cAlias	:= "BR8"
LOCAL cCampos	:= "BR8_CODPSA,BR8_DESCRI"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BR8_CODPSA, BR8_DESCRI, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND BR8_TPPROC = '0' "
cSql += "	   AND D_E_L_E_T_ = '' "
cSql += "	   AND BR8_BENUTL <> '0' "

If BR8->( FieldPos("BR8_CONSUL") ) > 0
	cSql += " AND BR8_CONSUL = '1' "
EndIf

If BR8->(FieldPos("BR8_TPCONS")) > 0
	cSql += " AND BR8_TPCONS IN('1','2') "
EndIf

If !Empty(cVldGen)
	cSql += " AND BR8_CODPAD = '" + cVldGen + "' "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BR8_CODPSA LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BR8_DESCRI LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3BR8P  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 da Tabela Padrao - Procedimentos						  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLF3BR8P()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cVldGen 	:= paramixb[3] //cCodPadSSol
LOCAL cAlias	:= "BR8"
LOCAL cCampos	:= "BR8_CODPSA,BR8_DESCRI"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BR8_CODPSA, BR8_DESCRI, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "
cSql += "	   AND BR8_TPPROC <> '5' "
cSql += "	   AND BR8_BENUTL <> '0' "

If !Empty(cVldGen)
	cSql += "	   AND BR8_CODPAD = '" + cVldGen + "' "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BR8_CODPSA LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BR8_DESCRI LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3BR8O  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 da Tabela Padrao - OPM								  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLF3BR8O()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cVldGen 	:= paramixb[3] //cCodPadSSol
LOCAL cAlias	:= "BR8"
LOCAL cCampos	:= "BR8_CODPSA,BR8_DESCRI"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BR8_CODPSA, BR8_DESCRI, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "
cSql += "	   AND BR8_TPPROC = '5' "
cSql += "	   AND BR8_BENUTL <> '0' "

If !Empty(cVldGen)
	cSql += "	   AND BR8_CODPAD = '" + cVldGen + "' "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BR8_CODPSA LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BR8_DESCRI LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BSW  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 do Usuarios do Portal									  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSF3BSW()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cAlias	:= "BSW"
LOCAL cCampos	:= "BSW_CODUSR,BSW_LOGUSR"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BSW_CODUSR,BSW_LOGUSR, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BSW_CODUSR LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BSW_LOGUSR LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BI3  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 do Produto											  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSF3BI3()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cAlias	:= "BI3"
LOCAL cCampos	:= "BI3_CODIGO,BI3_NREDUZ"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BI3_CODIGO,BI3_NREDUZ, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BI3_CODIGO LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BA9_NREDUZ LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BCX  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 do Produto											  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSF3BCX()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cAlias	:= "BCX"
LOCAL cCampos	:= "BCX_CODIGO,BCX_DESCRI"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BCX_CODIGO,BCX_DESCRI, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BCX_CODIGO LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BCX_DESCRI LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BC9  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 do CEP												  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSF3BC9()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cAliasBC9	:= "BC9"
LOCAL cAliasB18	:= "B18"
LOCAL cAliasBID	:= "BID"
LOCAL cCampos	:= "BC9_CEP,BC9_END"
LOCAL cRetGat	:= "BC9_TIPLOG|BC9_END|BID_EST|BC9_CODMUN|BC9_BAIRRO"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BC9_CEP,BC9_TIPLOG,B18_DESCRI,BC9_END,BC9_BAIRRO,BC9_CODMUN,BID_DESCRI,BID_EST, " + cAliasBC9 + ".R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAliasBC9)+ " " + cAliasBC9 + ", " + RetSQLName(cAliasB18) + " " + cAliasB18 + ", " + RetSQLName(cAliasBID) + " " + cAliasBID
cSql += "	 WHERE " + cAliasBC9 + "_FILIAL = '" + xFilial(cAliasBC9) + "' "
cSql += "	   AND " + cAliasBC9 + ".D_E_L_E_T_ = '' "
cSql += "	   AND B18_FILIAL = BC9_FILIAL "
cSql += "	   AND B18_CODIGO = BC9_TIPLOG "
cSql += "	   AND " + cAliasB18 + ".D_E_L_E_T_ = '' "
cSql += "	   AND BID_FILIAL = BC9_FILIAL "
cSql += "	   AND BID_CODMUN = BC9_CODMUN "
cSql += "	   AND " + cAliasBID + ".D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BC9_CEP LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BC9_END LIKE '" + cBusca + "%' "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Referente ao gatilho
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		Case cTpBusca == "3"
	 		cSql += " AND BC9_CEP = '" + cBusca + "' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAliasBC9,cCampos,cSql,cRetGat} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BA1  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 do Usuario											  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSF3BA1()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cVldGen 	:= paramixb[3]
LOCAL cCodLWeb	:= paramixb[5]
LOCAL nTpPor	:= paramixb[6]
LOCAL cAlias	:= "BA1"
LOCAL cAliasAux	:= Iif( nTpPor==2 ,"B40" ,"B49")
LOCAL cCampos	:= "BA1_BENEFI|Matricula|@!|17|C,BA1_NOMUSR"
LOCAL cSql 		:= ""
LOCAL cPlusW	:= ""
LOCAL cAliasBlo := "BG3"
LOCAL cAliasBloFam := "BG1"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO AS BA1_BENEFI,BA1_CODEMP,BA1_NOMUSR," + RetSQLName(cAliaS) + ".R_E_C_N_O_ RECNO"
cSql += "  FROM " + RetSQLName(cAlias) + ", " + RetSQLName(cAliasAux) + IIF(nTpPor == 3, + ", " + RetSQLName(cAliasBlo) + ", " + RetSQLName(cAliasBloFam), "")
cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "   AND " + RetSQLName(cAlias) 	 +	".D_E_L_E_T_ = ' ' "
cSql += "   AND " + RetSQLName(cAliasAux) +	".D_E_L_E_T_ = ' ' "

If nTpPor == 3
cSql += "   AND " + RetSQLName(cAliasBlo) 	 +	".D_E_L_E_T_ = ' ' "
cSql += "   AND " + RetSQLName(cAliasBloFam) +	".D_E_L_E_T_ = ' ' "
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Empresa
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If nTpPor == 2
	cSql += " AND B40_FILIAL = '" + xFilial(cAlias) + "' "
	cSql += " AND B40_CODUSR = '" + cCodLWeb + "' "
	cSql += " AND BA1_CODINT = B40_CODINT "
	cSql += " AND BA1_CODEMP = B40_CODEMP "
	cSql += " AND BA1_CONEMP = B40_NUMCON "
	cSql += " AND BA1_VERCON = B40_VERCON "
	cSql += " AND BA1_SUBCON = B40_SUBCON "
	cSql += " AND BA1_VERSUB = B40_VERSUB "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Somente familia
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !Empty(cVldGen)
		cSql += " AND BA1_TIPREG = '" + GetNewPar("MV_PLTRTIT","00") + "' "
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Contrato
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	B40->( DbSetOrder(1) )//B40_FILIAL + B40_CODUSR + B40_CODINT + B40_CODEMP + B40_NUMCON + B40_VERCON + B40_SUBCON + B40_VERSUB
	B40->( MsSeek( xFilial("B40") + cCodLWeb ) )

	While !B40->( Eof() ) .And. B40->B40_CODUSR == cCodLWeb
		If Empty( B40->(B40_SUBCON+B40_VERSUB) ) .And. At( B40->(B40_SUBCON+B40_VERSUB),cPlusW) == 0
			cPlusW += "'" + B40->(B40_CODEMP+B40_NUMCON+B40_VERCON) + "',"
		EndIf
	B40->( DbSkip() )
	EndDo
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Where
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !Empty(cPlusW) 
		If !Empty(cBusca)
	    	Do Case
		    	Case cTpBusca == "1"
	 		    	cSql += " AND BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO LIKE '" + cBusca + "%' "
		        Case cTpBusca == "2"
	 		    	cSql += " AND BA1_NOMUSR LIKE '" + cBusca + "%' "
	       EndCase
        EndIf
		
		cSql += " UNION "

		cSql += "SELECT BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO AS BA1_BENEFI,BA1_CODEMP,BA1_NOMUSR," + RetSQLName(cAlias) + ".R_E_C_N_O_ RECNO"
		cSql += "  FROM " + RetSQLName(cAlias) + ", " + RetSQLName(cAliasAux)
		cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += "   AND " + RetSQLName(cAlias) 	 +	".D_E_L_E_T_ = ' ' "
		cSql += "   AND " + RetSQLName(cAliasAux) +	".D_E_L_E_T_ = ' ' "

		cSql += "   AND B40_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += "   AND B40_CODUSR = '" + cCodLWeb + "' "
		cSql += "   AND BA1_CODINT = B40_CODINT "
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		//³ Somente familia
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
		If !Empty(cVldGen)
			cSql += "   AND BA1_TIPREG = '" + GetNewPar("MV_PLTRTIT","00") + "' "
		EndIf
		cSql += " AND BA1_CODEMP||BA1_CONEMP||BA1_VERCON IN(" + Left(cPlusW,Len(cPlusW)-1) + ") "
	EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Beneficiario
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ElseIf nTpPor == 3
	cSql += " AND B49_FILIAL = '" + xFilial(cAlias) + "' "
	cSql += " AND B49_CODUSR = '" + cCodLWeb + "' "
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Somente familia
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !Empty(cVldGen)
		cSql += " AND BA1_TIPREG = '" + GetNewPar("MV_PLTRTIT","00") + "' "
	EndIf

	//Tratativa para que seja exibido todos os membros da familia, assim para os casos de inclusão futura não precisara incluir os beneficiarios	
	If UPPER(AllTrim(TcGetDb())) $ "DB2|ORACLE|INFORMIX|POSTGRES"
		cSql += " AND (BA1_CODINT||BA1_CODEMP||BA1_MATRIC) =  SUBSTRING(B49_BENEFI,1,14) "	
	Else
		cSql += " AND (BA1_CODINT+BA1_CODEMP+BA1_MATRIC)   =  SUBSTRING(B49_BENEFI,1,14) "	
	Endif	

	cSql += " AND (( BA1_DATBLO = ' ' )" // Busca apenas os beneficiários Ativos
	cSql += " OR (BA1_DATBLO <> ' ' AND BA1_CONSID = 'U' AND BA1_MOTBLO = BG3_CODBLO AND BG3_LOGIN = '1')" // Busca apenas os beneficiários com bloqueio no usuário e que acessam portal.
	cSql += " OR (BA1_DATBLO <> ' ' AND BA1_CONSID = 'F' AND BA1_MOTBLO = BG1_CODBLO AND BG1_LOGIN = '1'))"// Busca apenas os beneficiários com bloqueio na família e que acessam portal.
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BA1_NOMUSR LIKE '" + UPPER(cBusca) + "%' "
	EndCase
EndIf

cSql += " GROUP BY BA1_CODINT  , BA1_CODEMP  , BA1_MATRIC  , BA1_TIPREG  , BA1_DIGITO  , BA1_CODEMP  , BA1_NOMUSR  , "+RetSqlName("BA1")+".R_E_C_N_O_"

If nTpPor <> 3
	cSql += " ORDER BY BA1_CODEMP,BA1_NOMUSR "
Endif	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

//Se o "Tipo de Portal" for 0, significa que o usuario nao esta autenticado no portal
//Tipos de portal disponiveis: 1 - Prestador, 2 - Empresa e 3 - Familia
cSql := IIF(nTpPor == 0, "", cSql)

sleep(100)

Return( {cAlias,cCampos,cSql} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3BTQ  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 da Tabela Padrao - consulta							  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLF3BTQ()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL aBusca 	:= strToArray( paramixb[2], '|' )
LOCAL aBuscaVin := iIf( len(paramixb) >= 13, strToArray( paramixb[13], '|' ),{} )
LOCAL aVldGen 	:= strToArray( paramixb[3], '|' ) //cCodPadSSol
LOCAL cAlias	:= "BTQ"
LOCAL cCampos	:= "BTQ_CDTERM,BTQ_DESTER"
LOCAL cSql 		:= ""
LOCAL cDatabase	:= DTOS(dDataBase)
local lGriGH		:= iif(paramixb[12] $ "5/6", .t., .f.) 

PRIVATE cCodPad := ""
PRIVATE cCodPro := ""
PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
PRIVATE aErrVarVin := {.F., "", "", ""}
PRIVATE cQuery := ""
PRIVATE cVinc := ""

//Query para retornar dados do F3
If (Alltrim(aVldGen[1]) == '28' .OR. Alltrim(aVldGen[1]) == '32') .and. !Empty(aBuscaVin) //Válida se está chamando a consulta F3 do campo Dente/Região ou Faces da guia Odonto
	
	if Len(aBuscaVin) >= 2

		//De-para TUSS/PROTHEUS para o código da tabela e do procedimento
		cCodPad	:= AllTrim(PLSVARVINC('87','BR4',aBuscaVin[1]))
		cCodPro	:= AllTrim(PLSVARVINC(aBuscaVin[1],'BR8', aBuscaVin[2], cCodPad+aBuscaVin[2],,aTabDup,@CCODPAD))

	EndIf

	//Verifica duplicidade
	PChkTabDup(@cCodPad,cCodPro,aBuscaVin[1])
	
	//Segue por dente/regiao
	If Alltrim(aVldGen[1]) == '28'

		//Seeka a B05 para verificar dente/região atrelados ao procedimento da BR8
		B05->(DbSetOrder(1))

		If B05->( MsSeek(xFilial("B05") + AllTrim(cCodPad) + AllTrim(cCodPro) ))

			While !B05->( Eof()) .AND. AllTrim(B05->B05_CODPAD) == AllTrim(cCodPad)  .AND. AllTrim(B05->B05_CODPSA) == AllTrim(cCodPro)

				cVinc := PLSVARVINC('28','B04',Alltrim(B05->B05_CODIGO)) //De-para Protheus/TUSS para incluir na query da consulta

				If aErrVarVin[1] == .T. .and. ! Empty(cVinc)
					cVinc := PLSVARVINC('42','B04',Alltrim(B05->B05_CODIGO)) //Confirma se não existe na tabela 42 caso traga critica de falta de De-Para da 28.
				EndIF	

				If ! Empty(cVinc) .and. aErrVarVin[1] <> .T. //Valida se De-para existe e se não foi criticado por falta dele
					cQuery += "'" + cVinc + "'," //Caso exista adiciona a query
				EndIf
				
			B05->( DbSkip() )
			EndDo
			
		EndIf
		
	//Segue por Faces
	Elseif Alltrim(aVldGen[1]) == '32' .and. Len(aBuscaVin) > 2
	
		//Seeka a BYL para verificar faces atrelados ao procedimento da BR8
		BYL->(DbSetOrder(1)) //BYL_FILIAL + BYL_CODPAD + BYL_CODPSA + BYL_CODIGO + BYL_TIPO + BYL_FACE

		If BYL->( MsSeek( xFilial("BYL") + AllTrim(cCodPad) + Padr(AllTrim(cCodPro), TamSx3("BYL_CODPSA")[1] ) + Alltrim(aBuscaVin[3]) ))

			While !BYL->( Eof()) .AND. AllTrim(BYL->BYL_CODPAD) == AllTrim(cCodPad)  .AND. AllTrim(BYL->BYL_CODPSA) == AllTrim(cCodPro) .AND. AllTrim(BYL->BYL_CODIGO) == AllTrim(aBuscaVin[3])
				
				cVinc := PLSVARVINC('32','B09',Alltrim(BYL->BYL_FACE)) //De-para Protheus/TUSS para incluir na query da consulta
				
				If !Empty(cVinc) .and. aErrVarVin[1] <> .T. //Valida se De-para existe e se não foi criticado por falta dele
					cQuery += "'" + cVinc + "'," //Caso exista adiciona a query
				EndIf
				
			BYL->( DbSkip() )
			EndDo
			
		EndIf
		
	EndIf
	
	//Controle para querys em branco
	If !Empty(cQuery)
		cQuery := SubStr(cQuery, 1 , Len(cQuery)-1)
	Else
		cQuery := "''"
	EndIf
	
	cSql := "   SELECT BTQ_CDTERM, BTQ_DESTER, R_E_C_N_O_ RECNO "
	cSql += "     FROM " + RetSQLName("BTQ")
	cSql += "    WHERE BTQ_FILIAL = '" + xFilial("BTQ") + "' "
	cSql += IIF(len(aVldGen) <= 1,"      AND BTQ_CODTAB = '" + aVldGen[1] + "'", "      AND BTQ_CODTAB IN ('" + aVldGen[1] + "','" + aVldGen[2] + "')" )
	cSql += "      AND BTQ_CDTERM IN (" + cQuery + ")"
	cSql += "      AND BTQ_VIGDE <= '" + dtos(dDataBase) + "' "
	cSql += "      AND (BTQ_VIGATE = '' OR BTQ_VIGATE >= '" + cDataBase + "') "
	cSql += "      AND D_E_L_E_T_ = '' "

	If Len(aBusca) > 0
		cBusca := aBusca[1]
	EndIf
	
	//Inclui a busca especifica
	If ! Empty(cBusca)
		
		Do Case
		
			Case cTpBusca == "1"
				cSql += " AND UPPER (BTQ_CDTERM) LIKE '%" + UPPER (cBusca) + "%' "
			Case cTpBusca == "2"
				cSql += " AND UPPER (BTQ_DESTER) LIKE '%" + UPPER (cBusca) + "%' "
				
		EndCase
		
	EndIf
	
Else
	
	cSql := " SELECT BTQ_CDTERM,BTQ_DESTER, R_E_C_N_O_ RECNO "
	cSql += "  FROM " + RetSQLName("BTQ")
	cSql += " WHERE BTQ_FILIAL = '" + xFilial("BTQ") + "' "
	cSql += "   AND BTQ_VIGDE <= '" + dtos(dDataBase) + "' "
	
	If Len(aBusca) == 1 // Se for passado apenas o codigo da tabela na TISS
	
		If ! Empty(aVldGen[1])
			cSql += " AND BTQ_CODTAB = '" + aVldGen[1]  + "'"
		Else
			cSql += " AND BTQ_CODTAB = '" + aBusca[1]  + "'"
		EndIf
		
	// Caso contrario busca por tabela protheus e chave
	Else 
	
		cSql += "	   AND ( ( BTQ_CODTAB IN (SELECT BTP_CODTAB FROM " + RetSQLName("BTP")
		cSql += "                              WHERE BTP_FILIAL = '" + xFilial("BTP") + "'"
		cSql += "                                AND BTP_ALIAS = '" + aBusca[1] + "'"
		cSql += "                                AND BTP_CHVTAB ='" + aBusca[2] + "'"
		cSql += "                                AND D_E_L_E_T_ = '' ) ) "
		
		cSql += "	   OR    ( BTQ_CODTAB IN (SELECT BVL_CODTAB FROM " + RetSQLName("BVL")
		cSql += "                              WHERE BVL_FILIAL = '" + xFilial("BVL") + "'"
		cSql += "                                AND BVL_ALIAS = '" + aBusca[1] + "'"
		cSql += "                                AND BVL_CHVTAB = '" + aBusca[2] + "'"
		cSql += "                                AND D_E_L_E_T_ = '' ) ) )"
		
	EndIf
	
	if lGriGH .and. aVldGen[1] == '87'
		cSql += " AND BTQ_CDTERM IN (00, 22, 98)"	
	elseif (aVldGen[1] == '87')	
		cSql += " AND BTQ_CDTERM IN (" + GetNewPar("MV_TABFIL","''") + ")"
	Endif
	
	cSql += "     AND (BTQ_VIGATE = '' OR BTQ_VIGATE >= '" + cDataBase + "')"
	cSql += "     AND D_E_L_E_T_ = '' "
	
	If Len(aBusca) > 0
		cBusca := aBusca[1]
	EndIf
	
	//Inclui a busca especifica
	If ! Empty(cBusca)
	
		Do Case
			
			Case cTpBusca == "1"
				cSql += " AND UPPER(BTQ_CDTERM) LIKE '%" +  UPPER (cBusca) + "%' "
			Case cTpBusca == "2"
				cSql += " AND UPPER(BTQ_DESTER) LIKE '%" + UPPER (cBusca) + "%' "
		EndCase
			
	EndIf
	
EndIf

Return( {cAlias,cCampos,cSql} )

/*/{Protheus.doc} PF3BAU
Retorna a descrição do código de acreditações.

@Project	TTQLAU	 
@author	Lucas de Azevedo Nonato
@since		15/10/2015
@version	P12 
@Return	L
/*/
User Function PF3BAU()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 		:= paramixb[2] 
LOCAL cVldGen 	:= paramixb[3] 
LOCAL cUser		:= paramixb[5]         
LOCAL cAlias		:= "BAU"                   
LOCAL cCampos		:= "BAU_CODIGO,BAU_NOME"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BAU_CODIGO,BAU_NOME, R_E_C_N_O_ RECNO" 

cSql += "	 FROM " + RetSQLName(cAlias)  

cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "

If cVldGen == 'ACR'
	///SELECT BAU_CODIGO,BAU_NOME FROM BAU070  where bau_codigo IN (select bso_codigo from bso070 where bso_codusr = '000008')  order by bau_codigo;
	cSql += " AND BAU_CODIGO IN(SELECT BSO_CODIGO FROM " + RetSQLName("BSO") + " WHERE BSO_CODUSR = " +"'" + cUser+ "' )" 
	
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)    
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BAU_CODIGO LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BAU_NOME LIKE '" + cBusca + "%' "
	EndCase	               
EndIf	
cSql += " ORDER BY BAU_CODIGO "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ    ÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±    ±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿    ±±±
±±³Funcao    ³PF3BR8CC  ³ Autor ³ Roberto Vanderlei		³ Data ³ 30/10/15     ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´    ±±±
±±³Descricao ³ F3 da Tabela Padrao - Procedimentos(com filtro por classe Med.)³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ    ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±    ±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß    ßßßß
*/
User Function PF3BR8CC()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 		:= paramixb[2] 
LOCAL cAlias		:= "BR8"                   
LOCAL cCampos		:= "BR8_CODPSA,BR8_DESCRI"
Local cHeader    := "Procedimento,Descrição"
LOCAL cSql 		:= ""
LOCAL cCodInt 		:= PlsIntPad()
local cClasses := ""

BJE->( DbSetOrder(5) )//B40_FILIAL + B40_CODUSR + B40_CODINT + B40_CODEMP + B40_NUMCON + B40_VERCON + B40_SUBCON + B40_VERSUB
BJE->( MsSeek( xFilial("BJE") + cCodInt + "1") )

While !BJE->( Eof() )

	if BJE->BJE_CODINT + BJE->BJE_TIPO = cCodInt + "1"
	
		if len(cClasses) > 0
			cClasses += ","
		endif
	
		cClasses += "'"+BJE->BJE_CODIGO+"'" 
	endif
	
	BJE->( DbSkip() )
EndDo

//Caso não exista tipo 1, utiliza classe genérica para não retornar nenhum item.
if Empty(cClasses)
	cClasses := "'999999'"
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BR8_CODPSA, BR8_DESCRI, R_E_C_N_O_ RECNO" 
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND BR8_CLASSE IN(" + cClasses + ")"
cSql += " AND BR8_EXPBEN = '1'"
cSql += " AND D_E_L_E_T_ = '' "

If !EmpTy(cBusca)
	Do Case
		Case cTpBusca == "1"
			cSql += " AND UPPER (BR8_CODPSA) LIKE '%" + UPPER(cBusca) + "%' "
		Case cTpBusca == "2"
			cSql += " AND UPPER (BR8_DESCRI) LIKE '%" + UPPER(cBusca) + "%' "
	EndCAse
EndIf

cSql += " ORDER BY 2 "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql,cHeader} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3BR8P  ³ Autor ³ Totvs					³ Data ³ 05/02/12 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 da Tabela Padrao - Procedimentos(com filtro por classe)³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PF3BR8CP()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 		:= paramixb[2] 
LOCAL cVldGen 	:= paramixb[3] //Field_CODPAD | Field_TPDES
LOCAL cAlias		:= "BR8"                   
LOCAL cCampos		:= "BR8_CODPSA,BR8_DESCRI, BR8_CODPAD"
Local cHeader    	:= "Procedimento, Descrição"
LOCAL cSql 		:= ""
LOCAL aVldGen		:= 	StrToArray(StrTran(cVldGen,"|M",""), "|")
Local cCodInt		:= PLSINTPAD()
Local cTabRee		:= ""
Local aCdPad		:= {}
Local nI			:= 1

BA0->(DbSetOrder(1))
If BA0->(MsSeek(xFilial("BA0")+cCodInt))
	cTabRee := BA0->BA0_TBRFRE
EndIF

BA8->(DbSetOrder(1))
If BA8->(MsSeek(xFilial("BA8")+cCodInt+cTabRee))
	aadd(aCdPad, BA8->BA8_CODPAD)
EndIF

If PlsAliasExi("B7T")
	B7T->(DbSetOrder(1))
	If B7T->(DbSeek(xFilial("B7T")+cCodInt))
		while B7T->B7T_CODINT == cCodInt
			//Verifica se na B7T foi cadastrado tabela de reembolso ou tabela de preços
			If !Empty(B7T->B7T_TABREE)
				//Caso seja tabela de reembolso, verifica na BA8 o CODPAD referenciado.
				If BA8->(MsSeek(xFilial("BA8")+cCodInt+B7T->B7T_TABREE))
					aadd(aCdPad, BA8->BA8_CODPAD)
				EndIf
			EndIf
      		
			B7T->(DbSkip())
		enddo
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BR8_CODPSA, BR8_DESCRI, BR8_CODPAD, R_E_C_N_O_ RECNO" 
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
For nI := 1 to Len(aCdPad)

	If nI == 1
		cSql += " AND ("
	EndIf
	
	cSql += " BR8_CODPAD = '" + aCdPad[nI] + "' "
	
	If nI < Len(aCdPad)
		cSql += " OR"
	Else
		cSql += " )"
	EndIf	
Next

cSql += "	   AND D_E_L_E_T_ = '' "
cSql += "	   AND BR8_EXPBEN = '1' "

If !Empty(cVldGen) .AND. Len(aVldGen) > 0
	If Len(aVldGen) ==2
		If !Empty(aVldGen[1])
			cSql += "	   AND BR8_CODPAD = '" + aVldGen[1] + "' "
		EndIf
		If !Empty(aVldGen[2])
			cSql += "	   AND BR8_CLASSE = '" + aVldGen[2] + "' "
		EndIf
	Else
		If !Empty(aVldGen[1])
			cSql += "	   AND BR8_CLASSE = '" + aVldGen[1] + "' "
		EndIf		
	EndIf
EndIf	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)    
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BR8_CODPSA LIKE '" + UPPER(cBusca) + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BR8_DESCRI LIKE '%" + UPPER(cBusca) + "%' "
	EndCase	               
EndIf	    
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql, cHeader} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3CADGEN  ³ Autor ³ Karine Riquena Limp	³ Data ³ 03/06/15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 consulta padrão genérica                                ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLF3CADGEN()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cAlias	:= Alltrim(paramixb[7])
LOCAL cCampos  := paramixb[8] 
LOCAL aCampos 	:= StrToArray( paramixb[8], ',' )
LOCAL aCmpBus 	:= StrToArray( paramixb[9], ',' )
LOCAL aCodDes		:= StrToArray( paramixb[10], ',' )
LOCAL nI := 1
LOCAL nJ := 1
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql += "SELECT " 

For nI := 1 to Len(aCampos)
	cSql += aCampos[nI] + ", "
Next nI

cSql += "R_E_C_N_O_ RECNO"

cSql += "	 FROM " + RetSQLName(cAlias)

If cAlias <> "SX5"
	cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "'"
Else
	cSql += "	 WHERE X5_FILIAL = '" + xFilial(cAlias) + "'"
Endif

cSql += IIF((Len(aCmpBus) ==  1 .AND. Empty(aCmpBus[1])) .OR. Len(aCmpBus) <= 0 , " ", " AND ")

For nJ := 1 to Len(aCmpBus)
	cSql += aCmpBus[nJ]
	cSql += IIF(nJ == Len(aCmpBus), " "," AND ")
Next nJ

cSql += "	   AND D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND " + aCodDes[1] + " LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND " + aCodDes[2] + " LIKE '" + cBusca + "%' "
	EndCase
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PF3BA0
Retorna operadoras

@author		PLS TEAM
@since		15/10/2015
@version	P11 
/*/
//---------------------------------------------------------------------------------------
User Function PF3BA0()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2] 
LOCAL cAlias	:= "BA0"                   
LOCAL cCampos	:= "BA0_CODOPE|Operadora|@!|4|C,,BA0_NOMINT"
LOCAL cSql 		:= ""

//Query para retornar dados do F3
cSql := "SELECT BA0_CODIDE||BA0_CODINT AS BA0_CODOPE,BA0_NOMINT, R_E_C_N_O_ RECNO" 
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "

//Inclui a busca especifica
If !Empty(cBusca)    
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BA0_CODIDE||BA0_CODINT LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BA0_NOMINT LIKE '" + cBusca + "%' "
	EndCase	               
EndIf	
cSql += " ORDER BY BA0_CODIDE||BA0_CODINT "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PF3BAUJ
Retorna rede de atendimento juridica

@author		PLS TEAM
@since		15/10/2015
@version	P11 
/*/
//---------------------------------------------------------------------------------------
User Function PF3BAUJ()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2] 
LOCAL cAlias	:= "BAU"                   
LOCAL cCampos	:= "BAU_CODIGO,BAU_NOME"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BAU_CODIGO,BAU_NOME, R_E_C_N_O_ RECNO" 
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND BAU_TIPPE = 'J' "
cSql += "	   AND D_E_L_E_T_ = '' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)    
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BAU_CODIGO LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BAU_NOME LIKE '" + cBusca + "%' "
	EndCase	               
EndIf	
cSql += " ORDER BY BAU_CODIGO "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PF3BAUF
Retorna rede de atendimento fisica

@author		PLS TEAM
@since		15/10/2015
@version	P11 
/*/
//---------------------------------------------------------------------------------------
User Function PF3BAUF()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2] 
LOCAL cAlias	:= "BAU"                   
LOCAL cCampos	:= "BAU_CODIGO,BAU_NOME"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BAU_CODIGO,BAU_NOME, R_E_C_N_O_ RECNO" 
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND BAU_TIPPE = 'F' "
cSql += "	   AND D_E_L_E_T_ = '' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)    
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BAU_CODIGO LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BAU_NOME LIKE '" + cBusca + "%' "
	EndCase	               
EndIf	
cSql += " ORDER BY BAU_CODIGO "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BAQ  ³ Autor ³ Rodrigo Morgon			³ Data ³ 29/07/15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 da Especialidade												 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSF3BAQ()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2]
LOCAL cAlias	:= "BAQ"
LOCAL cCampos	:= "BAQ_CODESP,BAQ_DESCRI"
LOCAL cSql 		:= ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BAQ_CODESP,BAQ_DESCRI, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = '' "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BAQ_CODESP LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BAQ_DESCRI LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3B9G  ³ Autor ³ Oscar Zanin  			³ Data ³ 15/07/15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 da Tabela de Motivos						                  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLF3B9G()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 		:= paramixb[2]
LOCAL cAlias		:= "B9G"
LOCAL cCampos		:= "B9G_COD, B9G_MOTIVO"
LOCAL cSql 		:= ""
Local cCodInt		:= PLSINTPAD()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT B9G_COD, B9G_MOTIVO, R_E_C_N_O_ RECNO"
cSql += "	 FROM " + RetSQLName(cAlias)
cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
cSql += "	   AND D_E_L_E_T_ = ''  AND " + cAlias + "_CODINT = '" + cCodInt + "'"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Inclui a busca especifica
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !Empty(cBusca)
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND B9G_COD LIKE '" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND B9G_MOTIVO LIKE '" + cBusca + "%' "
	EndCase
EndIf
cSql += " ORDER BY 2 "
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLSF3BTP  ³ Autor ³ Rodrigo Morgon			³ Data ³ 14/08/15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ F3 do cabeçalho de terminologias da TISS						³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLSF3BTP()
	LOCAL cTpBusca 	:= paramixb[1]
	LOCAL cBusca 		:= paramixb[2]
	LOCAL cAlias	:= "BTP"
	LOCAL cCampos	:= "BTP_CODTAB,BTP_DESCRI"
	LOCAL cSql 		:= ""
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Query para retornar dados do F3
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	cSql := "SELECT BTP_CODTAB,BTP_DESCRI, R_E_C_N_O_ RECNO"
	cSql += "	 FROM " + RetSQLName(cAlias)
	cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	cSql += "	 AND BTP_CODTAB IN (" +Iif(!Empty(GETMV("MV_TABFIL")),GETMV("MV_TABFIL"), "''")+ ")"
	cSql += "	   AND D_E_L_E_T_ = '' "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Inclui a busca especifica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !Empty(cBusca)
		Do Case
			Case cTpBusca == "1"
		 		cSql += " AND BTP_CODTAB LIKE '" + cBusca + "%' "
			Case cTpBusca == "2"
		 		cSql += " AND BTP_DESCRI LIKE '" + cBusca + "%' "
		EndCase
	EndIf
	cSql += " ORDER BY 2 "
Return( {cAlias,cCampos,cSql} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³PLF3BR8D  ³ Autor ³ Roberto Vanderlei		³ Data ³ 09/04/15 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Pesquisa de pacotes						  						 ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function PLF3BR8D()
Local cCodProc 	:= ""
Local cAlias	:= "BLE"
Local cAliasBLD := "BLD"
Local cAliasBLZ := "BLZ"
Local cCampos	:= "BLE_CODPAD, BLE_CODPRO, BLD_DESPRO" 
Local cSql 		:= ""
Local aSepara := SEPARA(Paramixb[3], '$', .F.)
Local cCodRda 	:= aSepara[2]
If Len(aSepara[1]) > 8
	cCodProc	:= SubStr(aSepara[1],3,8)
Else
	cCodProc 	:= aSepara[1] //cVldGen
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
cSql := "SELECT BLE_CODPAD,BLE_CODPRO, BLD_DESPRO," +cAlias+ ".R_E_C_N_O_ RECNO"
cSql += " FROM " + RetSQLName(cAlias) + " " + cAlias + ", " + RetSQLName(cAliasBLD) + " " + cAliasBLD + ", " + RetSQLName(cAliasBLZ) + " " + cAliasBLZ
cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "'"
cSql += " AND " + cAliasBLD + "_FILIAL = '" + xFilial(cAliasBLD) + "'"
cSql += " AND " + cAliasBLZ + "_FILIAL = '" + xFilial(cAliasBLZ) + "'"
cSql += " AND BLE_TIPO = '9' " //Identifica que o procedimento esta na aba de procedimentos relacionados.
cSql += " AND BLE_CODPRO = BLD_CODPRO"
cSql += " AND BLE_CODPAD = BLZ_CODPAD "
cSql += " AND BLE_CODPRO = BLZ_CODPRO "
cSql += " AND BLZ_CODRDA = '" + cCodRda + "' "
cSql += " AND "+ cAlias+ ".D_E_L_E_T_ = '' "
cSql += " AND "+ cAliasBLD+ ".D_E_L_E_T_ = '' "
cSql += " AND "+ cAliasBLZ+ ".D_E_L_E_T_ = '' "
If !Empty(cCodProc)
	cSql += "	   AND BLE_CODOPC = '" + cCodProc + "' "
EndIf

cSql += " ORDER BY 1 "

Return( {cAlias,cCampos,cSql} )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLF3BE4I 
Executa a consulta padrao (especifica)

@author  PLS TEAM
@version P11
@since   27.02.14
/*/
//-------------------------------------------------------------------
User Function PLF3BE4I()

LOCAL cBusca 	:= ""
LOCAL cUsuario := "" //aBusca[1] paramixb[2]
Local cSql 	:= ""
Local cWhr 	:= ""
Local cRet 	:= ""
Local cAlias 	:= "BE4"
LOCAL cCampos	:= "INTERNA|Nº INTERNACAO|@R 9999.9999.99-99999999|18|C,BE4_DATPRO|Dt.Inter|99/99/9999|10|C,,BE4_DTALTA|Dt.Alta|99/99/9999|10|C"
LOCAL cTpGuia	:= ""
local cOpera 	:= ""
local cCodEMp	:= ""
local cMatric := ""
local cTipReg := ""
local cDigito := ""

if len(paramixb) >= 12
	cTpGuia	   	:= paramixb[12]
endif

if cTpGuia = "11" //Veio a partir da prorrogação
	cBusca := StrTran(paramixb[3],"|M","','")
	if !empty(cBusca)
		cBusca := "'" +  cBusca + "'"
	endif 	
Elseif cTpGuia = "6" .And. !Empty(paramixb[3])//Guia de Honorários
	cBusca := DtoS(CtoD(paramixb[3]))
endif

cUsuario 	:= paramixb[2]

if cBanco $ "ORACLE/DB2/POSTGRES"
	cSQL := " SELECT (BE4_CODOPE||BE4_ANOINT||BE4_MESINT||BE4_NUMINT) AS INTERNA,SUBSTR(BE4_DATPRO,7,2) || '/' || SUBSTR(BE4_DATPRO,5,2) || '/' || SUBSTR(BE4_DATPRO,1,4) AS BE4_DATPRO,SUBSTR(BE4_DTALTA,7,2) || '/' || SUBSTR(BE4_DTALTA,5,2) || '/' || SUBSTR(BE4_DTALTA,1,4) AS BE4_DTALTA, R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
else
	cSQL := " SELECT  (BE4_CODOPE+BE4_ANOINT+ BE4_MESINT+ BE4_NUMINT)  INTERNA, SUBSTRING(BE4_DATPRO,7,2) + '/' +SUBSTRING(BE4_DATPRO,5,2)+ '/' + SUBSTRING(BE4_DATPRO,1,4) AS BE4_DATPRO ,SUBSTRING(BE4_DTALTA,7,2) + '/' +SUBSTRING(BE4_DTALTA,5,2)+ '/' + SUBSTRING(BE4_DTALTA,1,4) AS BE4_DTALTA, R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
endif

cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' "
if !empty(cUsuario)
	cOpera 	:= Left(cUsuario, 4)
	cCodEMp	:= Substr(cUsuario,5,4)
	cMatric 	:= Substr(cUsuario,9,6)
	cTipReg 	:= Substr(cUsuario,15,2)
	cDigito 	:= Right(cUsuario,1 )
	
	//Verifico matrícula na BE4
	cWhr  += " AND BE4_CODOPE = '" + cOpera  + "' "
	cWhr  += " AND BE4_CODEMP = '" + cCodEmp + "' "
	cWhr  += " AND BE4_MATRIC = '" + cMatric + "' "
	cWhr  += " AND BE4_TIPREG = '" + cTipReg + "' "
	cWhr  += " AND BE4_DIGITO = '" + cDigito + "' "
endif	
		
cWhr += Iif (cTpGuia <> "6", " AND BE4_DATPRO <> ' ' ", " ")

if !empty(cBusca) .And. cTpGuia == "6"
	cWhr += " AND (BE4_DTALTA = ' ' OR ('" + cBusca + "' <= BE4_DTALTA)) AND BE4_CANCEL = '0' AND BE4_TIPGUI = '03' AND D_E_L_E_T_ = '' "
Else
	cWhr += " AND BE4_DTALTA = ' ' AND BE4_TIPGUI = '03' AND D_E_L_E_T_ = '' "
EndIf

if !empty(cBusca) .And. cTpGuia <> "6"
	cWhr += " AND BE4_CODRDA in (" + cBusca + ") "
endif

IF EXISTBLOCK("PL90ALTA")
	cRet := EXECBLOCK("PL90ALTA", .F., .F., cWhr)	//	cWhr - WHERE da Query
	IF VALTYPE(cRet) == "C" .AND. "WHERE " $ UPPER(cRet)
		cWhr := " " + ALLTRIM(cRet) 
	ENDIF
ENDIF
cSql += cWhr

Return( {cAlias,cCampos,cSql} )




//-------------------------------------------------------------------
/*/{Protheus.doc} PLF3B4AI
Executa a consulta padrao (especifica) para retornar guias de Anexos
@version P12
@since   30/10/2018
/*/
//-------------------------------------------------------------------
User Function PLF3B4AI()

Local cTpBusca 	:= paramixb[1]
Local cUsuario 	:= paramixb[2]  //chave de Busca
Local cSql 		:= ""
Local cExp      := IIF(cBanco == "MSSQL","+","||")
local cSubsBD	:= iif(cBanco == "MSSQL", " SUBSTRING", " SUBSTR")
Local cAlias	:= ""
Local cCampos	:= ""
Local lAutoma 	:= paramixb[14]

If !empty(cUsuario) .And. cUsuario <> 'undefined' .Or. lAutoma
	
	//Verifica outros banco de dados
	If cBanco $ "ORACLE|DB2|POSTGRES|INFORMIX" .Or. lAutoma
		If cTpBusca == "11" 
			cAlias	:= "BEA"
			cCampos	:= "ANEXOS|Numero da Guia Refer|@R 9999.9999.99-99999999|18|C, TIPO|Tipo Guia|@!|5|C, BEA_DATPRO|DT Guia Ref|99/99/9999|10|C"
			cSql := " SELECT 'SADT' TIPO, (BEA_OPEMOV"+cExp+"BEA_ANOAUT"+cExp+"BEA_MESAUT"+cExp+"BEA_NUMAUT) AS ANEXOS,"
			cSql += " SUBSTR(BEA_DATPRO,7,2) "+cExp+" '/' "+cExp+" SUBSTR(BEA_DATPRO,5,2) "+cExp+" '/' "+cExp+" SUBSTR(BEA_DATPRO,1,4) AS BEA_DATPRO,"
			cSql += " R_E_C_N_O_ RECNO FROM " +  RetSQLName("BEA")
			cSql += " WHERE BEA_FILIAL= '" + xFilial("BEA")+ "'"
			cSql += " AND  BEA_DATPRO <> ' '"
			cSql += " AND D_E_L_E_T_ = ''"
			cSql += " AND BEA_TIPGUI = '02'"
			cSql += " AND (BEA_OPEMOV "+cExp+" BEA_CODEMP "+cExp+" BEA_MATRIC "+cExp+" BEA_TIPREG "+cExp+" BEA_DIGITO) = '"+cUsuario+"'
		else
			cAlias	:= "BE4"
			cCampos	:= "ANEXOS|Numero da Guia Refer|@R 9999.9999.99-99999999|18|C, TIPO|Tipo Guia|@!|5|C, BE4_DATPRO|DT Guia Ref|99/99/9999|10|C"
			cSql := "SELECT 'INTERNACAO' TIPO,(BE4_CODOPE"+cExp+"BE4_ANOINT"+cExp+"BE4_MESINT"+cExp+"BE4_NUMINT) ANEXOS,"
			cSql += "SUBSTR(BE4_DATPRO,7,2) "+cExp+" '/' "+cExp+" SUBSTR(BE4_DATPRO,5,2) "+cExp+" '/' "+cExp+" SUBSTR(BE4_DATPRO,1,4) AS BE4_DATPRO,"
			cSql += "R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
			cSql += " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "'"
			cSql += " AND BE4_DATPRO <> ' '"
			cSql += " AND BE4_DTALTA = ' '"
			cSql += " AND D_E_L_E_T_ = ''"
			cSql += " AND (BE4_CODOPE "+cExp+" BE4_CODEMP "+cExp+" BE4_MATRIC "+cExp+" BE4_TIPREG "+cExp+" BE4_DIGITO) = '"+cUsuario+"'
		EndIf
	Else
		If cTpBusca == "11"
			cAlias	:= "BEA"
			cCampos	:= "ANEXOS|Numero da Guia Refer|@R 9999.9999.99-99999999|18|C, TIPO|Tipo Guia|@!|5|C, BEA_DATPRO|DT Guia Ref|99/99/9999|10|C"
			cSql := " SELECT 'SADT' TIPO, (BEA_OPEMOV"+cExp+"BEA_ANOAUT"+cExp+"BEA_MESAUT"+cExp+"BEA_NUMAUT) AS ANEXOS,"
			cSql += " SUBSTRING(BEA_DATPRO,7,2) "+cExp+" '/' "+cExp+" SUBSTRING(BEA_DATPRO,5,2) "+cExp+" '/' "+cExp+" SUBSTRING(BEA_DATPRO,1,4) AS BEA_DATPRO,"
			cSql += " R_E_C_N_O_ RECNO FROM " +  RetSQLName("BEA")
			cSql += " WHERE BEA_FILIAL= '" + xFilial("BEA")+ "'"
			cSql += " AND  BEA_DATPRO <> ' '"
			cSql += " AND D_E_L_E_T_ = ''"
			cSql += " AND BEA_TIPGUI = '02'"
			cSql += " AND (BEA_OPEMOV "+cExp+" BEA_CODEMP "+cExp+" BEA_MATRIC "+cExp+" BEA_TIPREG "+cExp+" BEA_DIGITO) = '"+cUsuario+"'
		else
			cAlias	:= "BE4"
			cCampos	:= "ANEXOS|Numero da Guia Refer|@R 9999.9999.99-99999999|18|C, TIPO|Tipo Guia|@!|5|C, BE4_DATPRO|DT Guia Ref|99/99/9999|10|C"
			cSql := "SELECT 'INTERNACAO' TIPO,(BE4_CODOPE"+cExp+"BE4_ANOINT"+cExp+"BE4_MESINT"+cExp+"BE4_NUMINT) ANEXOS,"
			cSql += "SUBSTRING(BE4_DATPRO,7,2) "+cExp+" '/' "+cExp+" SUBSTRING(BE4_DATPRO,5,2) "+cExp+" '/' "+cExp+" SUBSTRING(BE4_DATPRO,1,4) AS BE4_DATPRO,"
			cSql += "R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
			cSql += " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "'"
			cSql += " AND BE4_DATPRO <> ' '"
			cSql += " AND BE4_DTALTA = ' '"
			cSql += " AND D_E_L_E_T_ = ''"
			cSql += " AND (BE4_CODOPE "+cExp+" BE4_CODEMP "+cExp+" BE4_MATRIC "+cExp+" BE4_TIPREG "+cExp+" BE4_DIGITO) = '"+cUsuario+"'
		EndIf	
	EndIf
Else
		cAlias	:= "BEA"
		cCampos	:= "ANEXOS|Numero da Guia Refer|@R 9999.9999.99-99999999|18|C, TIPO|Tipo Guia|@!|5|C, BEA_DATPRO|DT Guia Ref|99/99/9999|10|C"
     	
		cSql := " SELECT 'SADT' TIPO, (BEA_OPEMOV"+cExp+"BEA_ANOAUT"+cExp+"BEA_MESAUT"+cExp+"BEA_NUMAUT) AS ANEXOS,"
		cSql += cSubsBD + "(BEA_DATPRO,7,2) " + cExp + " '/' " + cExp + cSubsBD + "(BEA_DATPRO,5,2) " + cExp + " '/' " + cExp + cSubsBD + "(BEA_DATPRO,1,4) AS BEA_DATPRO,"
		cSql += " R_E_C_N_O_ RECNO FROM " +  RetSQLName("BEA")
		cSql += " WHERE BEA_FILIAL = '" + xFilial("BEA")+ "'"
		cSql += " AND D_E_L_E_T_ = ' '" 
EndIf

Return( {cAlias,cCampos,cSql} )



//-------------------------------------------------------------------
/*/{Protheus.doc} PLF3INSAP
Executa a consulta padrao (especifica) para retornar guias de Internação e SADT no campo de pesquisa 3 - Número da Guia Principal na Guia SADT
Na guia SADT, posso relacionar guia de Internação e a própria guia SADT, pois no caso de cobrança de honorário e não desejo enviar a Guia de Hon.,
posso enviar uma guia SADT cobrando o valor, mas devo referenciar a guia SADT que contêm o procedimento.

@author  Renan Martins
@version P12
@since   08/06/2016
/*/
//-------------------------------------------------------------------
User Function PLF3INSAP()
	LOCAL cUsuario 	:= paramixb[3]  //VldGen é o número da Carteira
	LOCAL cBuscNAT	:= paramixb[2]  //chave de Busca
	Local cSql 		:= ""
	Local cSql2		:= ""
	Local cWhr 		:= ""
	Local cWhr2		:= ""
	Local cAlias 	:="BE4"
	LOCAL cCampos	:="INTERNA|Nº INTERNACAO/SADT|@R 9999.9999.99-99999999|18|C, TIPO|TIPO GUIA|@!|5|C, BE4_DATPRO|Dt.Inter/Dt. Atendimento|99/99/9999|10|C,,BE4_DTALTA|Dt.Alta|99/99/9999|10|C"

	If cBanco == "ORACLE"
		cSQL :=  " SELECT 'INT.' TIPO, (BE4_CODOPE||BE4_ANOINT||BE4_MESINT||BE4_NUMINT) AS INTERNA,SUBSTR(BE4_DATPRO,7,2) || '/' || SUBSTR(BE4_DATPRO,5,2) || '/' || SUBSTR(BE4_DATPRO,1,4) AS BE4_DATPRO,SUBSTR(BE4_DTALTA,7,2) || '/' || SUBSTR(BE4_DTALTA,5,2) || '/' || SUBSTR(BE4_DTALTA,1,4) AS BE4_DTALTA, R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
		cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  BE4_DATPRO <> ' ' AND BE4_DTALTA = ' ' AND D_E_L_E_T_ = ''"

		cSql2 := " SELECT 'SADT' TIPO, (BEA_OPEMOV||BEA_ANOAUT||BEA_MESAUT||BEA_NUMAUT)  INTERNA, SUBSTR(BEA_DATPRO,7,2) + '/' +SUBSTR(BEA_DATPRO,5,2)+ '/' + SUBSTR(BEA_DATPRO,1,4) AS BEA_DATPRO , ''  BEA_DTALTA, R_E_C_N_O_ RECNO FROM " +  RetSQLName("BEA")
		cWhr2 := " WHERE BEA_FILIAL= '" + xFilial("BEA")+ "' AND  BEA_DATPRO <> ' ' AND D_E_L_E_T_ = '' AND BEA_TIPGUI = '02' "

		if !empty(cUsuario)
			cWhr  += " AND  (BE4_CODOPE||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG||BE4_DIGITO) = '"+cUsuario+"'
			cWhr2 += " AND  (BEA_OPEMOV||BEA_CODEMP||BEA_MATRIC||BEA_TIPREG||BEA_DIGITO) = '"+cUsuario+"'
		ENDIF
		IF !empty(cBuscNAT)
			cWhr  += " AND  (BE4_CODOPE||BE4_ANOINT||BE4_MESINT||BE4_NUMINT) = '"+cBuscNAT+"'
			cWhr2 += " AND  (BEA_OPEMOV||BEA_ANOAUT||BEA_MESAUT||BEA_NUMAUT) = '"+cBuscNAT+"'			
		endif

	Else
		cSQL := " SELECT 'INT.' TIPO, (BE4_CODOPE+BE4_ANOINT+ BE4_MESINT+ BE4_NUMINT)  INTERNA, SUBSTRING(BE4_DATPRO,7,2) + '/' +SUBSTRING(BE4_DATPRO,5,2)+ '/' + SUBSTRING(BE4_DATPRO,1,4) AS BE4_DATPRO ,SUBSTRING(BE4_DTALTA,7,2) + '/' +SUBSTRING(BE4_DTALTA,5,2)+ '/' + SUBSTRING(BE4_DTALTA,1,4) AS BE4_DTALTA, R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
		cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  BE4_DATPRO <> ' ' AND BE4_DTALTA = ' ' AND D_E_L_E_T_ = ''"

		cSql2 := " SELECT 'SADT' TIPO, (BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT)  INTERNA, SUBSTRING(BEA_DATPRO,7,2) + '/' +SUBSTRING(BEA_DATPRO,5,2)+ '/' + SUBSTRING(BEA_DATPRO,1,4) AS BEA_DATPRO , '' BEA_DTALTA, R_E_C_N_O_ RECNO FROM " +  RetSQLName("BEA")
		cWhr2 := " WHERE BEA_FILIAL= '" + xFilial("BEA")+ "' AND  BEA_DATPRO <> ' ' AND D_E_L_E_T_ = '' AND BEA_TIPGUI = '02' "

		if !empty(cUsuario) 
			cWhr  += " AND  (BE4_CODOPE + BE4_CODEMP + BE4_MATRIC + BE4_TIPREG + BE4_DIGITO) = '"+cUsuario+"'
			cWhr2 += " AND  (BEA_OPEMOV + BEA_CODEMP + BEA_MATRIC + BEA_TIPREG + BEA_DIGITO) = '"+cUsuario+"'
		ENDIF
		IF !empty(cBuscNAT) 
			cWhr  += " AND  (BE4_CODOPE + BE4_ANOINT + BE4_MESINT + BE4_NUMINT) = '"+cBuscNAT+"'
			cWhr2 += " AND  (BEA_OPEMOV + BEA_ANOAUT + BEA_MESAUT + BEA_NUMAUT) = '"+cBuscNAT+"'	
		ENDIF
	Endif

	cSql += cWhr + " UNION " + cSql2 + cWhr2

Return( {cAlias,cCampos,cSql} )
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLF3DESP
F3 para tabela 25 de despesas, foi necessário criar essa função pois temos um facilitador para
quando o prestador selecionar determinada despesa, um codigo de tabela deve ser sugerido,
coloquei uma função de gatilho mas ela dispara apenas quando o campo é preenchido manualmente.

@author	Karine Riquena Limp
@since		30/06/2016
@version	P12
@Return	A

/*/
//---------------------------------------------------------------------------------------
User Function PLF3DESP()
LOCAL cTpBusca 	:= paramixb[1]
LOCAL aBusca 	:= StrToArray( paramixb[2], '|' )
LOCAL cVldGen 	:= paramixb[3] //cCodPadSSol
LOCAL cAlias	:= "BTQ"
LOCAL cCampos	:= "BTQ_CDTERM,BTQ_TABELA|Cód Tabela|@!|2|C, BTQ_DESTER"
//Local cHeader    := "Cód Termo,Cód Tabela, Descrição Termo"
LOCAL cSql 		:= ""
LOCAL cDatabase	:= DTOS(dDataBase)
PRIVATE cCodPad := ""
PRIVATE cCodPro := ""
PRIVATE aTabDup := PlsBusTerDup(SuperGetMv("MV_TISSCAB",.F.,"87"))
PRIVATE aErrVarVin := {.F., "", "", ""}
PRIVATE cQuery := ""
PRIVATE cVinc := ""
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Query para retornar dados do F3
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	
	cSql := "SELECT BTQ_CDTERM, BTQ_DESTER"
	
	cSql += ",CASE   "
   	cSql += "  WHEN BTQ_CDTERM IN('01','05','07') THEN '18' "
   	cSql += "  WHEN BTQ_CDTERM IN('03','08') THEN '19' "
   	cSql += "  WHEN BTQ_CDTERM IN('02') THEN '20'  " 	  
   	cSql += "END  AS BTQ_TABELA"
	
	cSql += ", R_E_C_N_O_ RECNO"
	cSql += "	 FROM " + RetSQLName(cAlias)
	cSql += "	 WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' AND BTQ_VIGDE <= '" + DTOS(dDataBase) + "' "

	cSql += " AND BTQ_CODTAB ='" + cVldGen  + "'"
	
	cSql += "	   AND (BTQ_VIGATE = '' OR BTQ_VIGATE >= '"+cDataBase+"')"
	cSql += "	   AND D_E_L_E_T_ = '' "
	
	If Len(aBusca) > 0
		cBusca := aBusca[1]
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Inclui a busca especifica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !Empty(cBusca)
		Do Case
		Case cTpBusca == "1"
			cSql += " AND UPPER (BTQ_CDTERM) LIKE '%" +  UPPER (cBusca) + "%' "
		Case cTpBusca == "2"
			cSql += " AND UPPER (BTQ_DESTER) LIKE '%" + UPPER (cBusca) + "%' "
		EndCase
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Fim da Funcao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
Return( {cAlias,cCampos,cSql} )


//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLF3PROF
F3 para listar os profissionais (solicitantes ou executantes).
Considera parâmetros do sistema que condicionam se serão listados:
 - Apenas os profissionais do corpo clínico (BC1) da RDA.
 - Todos do sistema (BB0).

@author	Rodrigo Morgon
@since		08/08/2016
@version	P12
/*/
//---------------------------------------------------------------------------------------
User Function PLF3PROF()

LOCAL cSql 		:= ""
LOCAL cAliasBB0	:= "BB0"
LOCAL cAliasBC1	:= "BC1"
LOCAL lFitrPSoli	:= GetNewPar("MV_PLSPRFS",.T.)//.T. filtra solicitantes pelo corpo clínico - .F.  lista todos
LOCAL lFitrPExec	:= GetNewPar("MV_PLSPRFX",.T.)//.T. filtra executantes pelo corpo clínico - .F.  lista todos
LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 		:= paramixb[2]
LOCAL aRdaInfo 	:= StrToArray( paramixb[3], '|' )
LOCAl cCampoOri 	:= paramixb[11]
LOCAL cTpGuia	   	:= iIf(len(paramixb) >= 12 , paramixb[12], "")
LOCAL cCampos		:= "BB0_CODIGO,BB0_NOME,BB0_CODSIG,BB0_NUMCR,BB0_ESTADO, BB0_CGC"
Local cHeader		:= "Código,Nome,Sigla C.R.,Número C.R.,Estado C.R., C.P.F"
LOCAL cCodProf  	:= ""
LOCAL cTipoRda  	:= "J" //Por padrão, define como pessoa jurídica para busca na BB0.
LOCAL cCodRda 	:= ""
LOCAL cCodLoc 	:= ""
LOCAL lCorpoCli	:= .F.

/*Caso um dos parâmetros de filtro do corpo clínico for ativado, verifico a origem da consulta para ativar o filtro:
*	lFitrPSoli <- Filtro de corpo clínico para profissionais solicitantes
*	lFitrPExec <- Filtro de corpo clinico para profissionais executantes
*/
lCorpoCli := (cCampoOri == "cProSol" .and. lFitrPSoli) .or. (cCampoOri == "cProExe" .and. lFitrPExec)

//Ajuste para o retorno nas guias de anexos clínicos 
if len(aRdaInfo) == 1
	
	If aRdaInfo[1] == "ANC"
		cCampos		:= "BB0_NOME,BB0_CODIGO,BB0_CODSIG,BB0_NUMCR,BB0_ESTADO"
		cHeader		:= "Nome,Código,Sigla C.R.,Número C.R.,Estado C.R."
	EndIf
	
//Se possui informações da RDA, atribuo para as variaveis da funcao.
ElseIf len(aRdaInfo) >= 2 
	cCodRda := aRdaInfo[1]
	cCodLoc := aRdaInfo[2]
	
	//Posiciono na BAU para localizar o tipo da RDA (pessoa física ou pessoa jurídica).
	BAU->(DbSetOrder(1))
	if BAU->(DbSeek(xFilial("BAU") + cCodRda))
		cTipoRda := BAU->BAU_TIPPE
		cCodProf := BAU->BAU_CODBB0
	endif
endif

//Verifica se é pessoa jurídica ou pessoa física. Padrão J, sendo assim, se não for informada RDA no parâmetro, busca em toda BB0.
If cTipoRda == "J"
   //Listar os profissionais de saude que nao estao bloqueados
	if lCorpoCli .and. !Empty(cCodRda)
		//Parâmetro ativo, listar apenas profissionais vinculado ao corpo clinico da RDA SE houver codigo de RDA	
		cSQL := " SELECT " + cCampos
		cSQL += " FROM " + RetSQLName(cAliasBB0) + "," + RetSQLName(cAliasBC1)
		cSQL += " WHERE BC1_FILIAL = '" + xFilial(cAliasBC1) + "'"
		cSQL += " AND BC1_CODIGO = '" + cCodRda + "'"

		If !Empty(cCodLoc)
			cSQL += " AND BC1_CODLOC = '" + cCodLoc + "'"
		EndIf

		cSQL += " AND BC1_CODINT = '" + PlsIntPad() + "'"
		cSQL += " AND BB0_FILIAL = '" + xFilial(cAliasBB0) + "'"
		cSQL += " AND BB0_CODIGO = BC1_CODPRF "
		cSQL += " AND (BC1_DATBLO = ' ' OR BC1_DATBLO > '" + dtos(dDataBase) + "') " //Valida bloqueio do prestador no corpo clínico
		cSQL += " AND (BB0_DATBLO = ' ' OR BB0_DATBLO > '" + dtos(dDataBase) + "') " //Valida bloqueio do prestador na BB0
		
		If ExistBlock("PLFILBC1")
			cSQl += ExecBlock("PLFILBC1",.F.,.F.)
		EndIf
		
			
		If !Empty(cBusca)
			Do Case
				Case cTpBusca == "1"
					cSql += " AND BB0_CODIGO = '" + cBusca + "' "
				Case cTpBusca == "2"
					cSql += " AND UPPER(BB0_NOME) LIKE '%" + UPPER(cBusca) + "%' "
				Case cTpBusca == "3"
					cSql += " AND BB0_NUMCR = '" + allTrim(UPPER(cBusca)) + "' "
			EndCase
		EndIf
		
		cSQL += " AND " + RetSQLName(cAliasBB0) + ".D_E_L_E_T_ = ' ' "
		cSQL += " AND " + RetSQLName(cAliasBC1) + ".D_E_L_E_T_ = ' ' "
		cSQL += " GROUP BY " + cCampos + " ORDER BY BB0_NOME "

	else
	
		//Parâmetro desativado ou RDA vazia, lista todos os profissionais da base (BB0).
		cSQL := " SELECT " + cCampos
		cSQL += " FROM " + RetSqlName(cAliasBB0) + " "
		cSQL += " WHERE BB0_FILIAL = '" + xFilial(cAliasBB0) + "' "
		
		//Inclui a busca especifica	
		If !Empty(cBusca)
			Do Case
				Case cTpBusca == "1"
					cSql += " AND BB0_CODIGO = '" + cBusca + "' "
				Case cTpBusca == "2"
					cSql += " AND UPPER(BB0_NOME) LIKE '%" + UPPER(cBusca) + "%' "
				Case cTpBusca == "3"
					cSql += " AND BB0_NUMCR = '" + allTrim(UPPER(cBusca)) + "' "
			EndCase
		EndIf
		
		cSQL += " AND (BB0_DATBLO = '' OR BB0_DATBLO > '" + dtos(dDataBase) + "')" //Valida bloqueio do prestador na BB0
		cSQL += " AND D_E_L_E_T_ = ' ' "
		cSQL += " GROUP BY " + cCampos + " ORDER BY BB0_NOME "
	endIf
	
ElseIf !Empty(cCodProf)

	if cTpGuia <> "2"
		//Pessoa física, buscar apenas o profissional que está vinculado a RDA
		cSQL := " SELECT " + cCampos
		cSQL += " FROM " + RetSqlName(cAliasBB0) + " "
		cSQL += " WHERE BB0_FILIAL = '" + xFilial(cAliasBB0) + "' "
		cSQL += " AND BB0_CODIGO = '" + cCodProf + "' "	//Se for informado RDA pessoa física, só localiza a RDA vinculada à mesma.
		cSQL += " AND (BB0_DATBLO = '' OR BB0_DATBLO > '" + dtos(dDataBase) + "')"  //Valida bloqueio do prestador na BB0
		cSQL += " AND D_E_L_E_T_ = ' ' "
		cSQL += " GROUP BY " + cCampos
	else
	
		//Parâmetro desativado ou Codigo Profissional vazio, lista todos os profissionais da base (BB0).
		cSQL := " SELECT " + cCampos
		cSQL += " FROM " + RetSqlName(cAliasBB0) + " "
		cSQL += " WHERE BB0_FILIAL = '" + xFilial(cAliasBB0) + "' "
		
		//Inclui a busca especifica	
		If !Empty(cBusca)
			Do Case
				Case cTpBusca == "1"
					cSql += " AND BB0_CODIGO = '" + cBusca + "' "
				Case cTpBusca == "2"
					cSql += " AND UPPER(BB0_NOME) LIKE '%" + UPPER(cBusca) + "%' "
				Case cTpBusca == "3"
					cSql += " AND BB0_NUMCR = '" + allTrim(UPPER(cBusca)) + "' "
			EndCase
		EndIf
		
		cSQL += " AND (BB0_DATBLO = '' OR BB0_DATBLO > '" + dtos(dDataBase) + "')" //Valida bloqueio do prestador na BB0
		cSQL += " AND D_E_L_E_T_ = ' ' "
		cSQL += " GROUP BY " + cCampos + " ORDER BY BB0_NOME "
	endIf
Endif

Return( {cAliasBB0,cCampos,cSql,cHeader} )

//--------------------------------------------------------------------------------------- 
/*/{Protheus.doc} PF3HOSP
Retorna a descrição do campo 020(Nome Hospital) da solicitação de internação.

@Project	PF3HOSP	 
@author	Thiago Guilherme
@since		21-09-2016
@version	P12 
/*/
//---------------------------------------------------------------------------------------
User Function PF3HOSP()

LOCAL cTpBusca 	:= paramixb[1]
LOCAL cBusca 	:= paramixb[2] 
LOCAL cAlias	:= "BAU"                   
LOCAL cCampos	:= "BAU_CPFCGC,BAU_NOME"
LOCAL cSql 		:= ""
LOCAL cTpPre	:= GetNewPar("MV_PLSTPPR","HOS")

// Pega as especialidades do corpo clinico
cSql := " SELECT BAU_CPFCGC,BAU_NOME, R_E_C_N_O_ RECNO "
cSql += " FROM "+BAU->( RetSQLName("BAU") )
cSql += " WHERE BAU_FILIAL = '"+xFilial("BAU")+"' "
cSql += " AND BAU_CODBLO = '"+Space( TamSx3("BAU_CODBLO")[1] )+"' "
cSql += " AND BAU_TIPPRE IN('"+cTpPre+"') "
	
If !Empty(cBusca)    
	Do Case
		Case cTpBusca == "1"
	 		cSql += " AND BAU_CPFCGC LIKE '%" + cBusca + "%' "
		Case cTpBusca == "2"
	 		cSql += " AND BAU_NOME LIKE '%" + cBusca + "%' "
	EndCase	               
EndIf

cSql += " AND D_E_L_E_T_ = ' ' "	
cSql += " ORDER BY BAU_NOME "

Return( {cAlias,cCampos,cSql} )

//-------------------------------------------------------------------
/*/{Protheus.doc} PLF3BE4RI 
Executa a consulta padrao (especifica)

@author  PLS TEAM
@version P11
@since   27.02.14
/*/
//-------------------------------------------------------------------
User Function PLF3BE4RI()
Local cTpBusca := paramixb[1]
Local cBusca 	:= paramixb[2] 
Local cVldGen := paramixb[3] 
Local cSql 	:= ""
Local cWhr 	:= ""
Local cAlias	:= "BE4"
LOCAL cCampos	:="INTERNA|Código-Internação|@R 9999.9999.99-99999999|8|C, MATRIC|Matrícula|@!|10|C, NOMUSR|Descrição-Nome|@!|60|C ,BE4_DATPRO|Dt.Inter|99/99/9999|10|C,BE4_DTALTA|Dt.Alta|99/99/9999|10|C"

If cBanco $ "ORACLE/DB2/POSTGRES"
	cSQL := " SELECT (BE4_CODOPE||BE4_ANOINT||BE4_MESINT||BE4_NUMINT) INTERNA, SUBSTR(BE4_DATPRO,7,2) || '/' || SUBSTR(BE4_DATPRO,5,2) || '/' || SUBSTR(BE4_DATPRO,1,4) BE4_DATPRO, SUBSTR(BE4_DTALTA,7,2) || '/' || SUBSTR(BE4_DTALTA,5,2) || '/' || SUBSTR(BE4_DTALTA,1,4) BE4_DTALTA, "
	cSql += " (BE4_OPEUSR||BE4_CODEMP||BE4_MATRIC||BE4_TIPREG||BE4_DIGITO) MATRIC, BE4_NOMUSR NOMUSR, R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
	cWhr := " WHERE BE4_FILIAL = '" + xFilial("BE4")+ "' AND BE4_DATPRO <> '' AND D_E_L_E_T_ = '' "
	cWhr += " AND BE4_TIPGUI <> '05' "
	cWhr += " AND BE4_FASE <> '4' AND BE4_SITUAC <> '2' AND BE4_STATUS <> '3' AND BE4_CODRDA = '" + cVldGen + "'"  //Diferente de faturado / Cancelado e Não Autorizado
	Iif (cTpBusca == "1", cWhr += " AND BE4_CODOPE||BE4_ANOINT||BE4_MESINT||BE4_NUMINT = '" + cBusca + "'", cWhr += " AND UPPER (BE4_NOMUSR) LIKE '%" + UPPER(cBusca) + "%'")
Else
	cSQL := " SELECT (BE4_CODOPE+BE4_ANOINT+ BE4_MESINT+ BE4_NUMINT) INTERNA, SUBSTRING(BE4_DATPRO,7,2) + '/' +SUBSTRING(BE4_DATPRO,5,2)+ '/' + SUBSTRING(BE4_DATPRO,1,4) BE4_DATPRO ,SUBSTRING(BE4_DTALTA,7,2) + '/' +SUBSTRING(BE4_DTALTA,5,2)+ '/' + SUBSTRING(BE4_DTALTA,1,4) BE4_DTALTA, "
	cSql += " (BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO) MATRIC, BE4_NOMUSR NOMUSR, R_E_C_N_O_ RECNO FROM " + RetSQLName("BE4")
	cWhr := " WHERE BE4_FILIAL= '" + xFilial("BE4")+ "' AND  BE4_DATPRO <> '' AND D_E_L_E_T_ = ''"
	cWhr += " AND BE4_TIPGUI <> '05' "
	cWhr += " AND BE4_FASE <> '4' AND BE4_SITUAC <> '2' AND BE4_STATUS <> '3' AND BE4_CODRDA = '" + cVldGen + "'"   //Diferente de faturado / Cancelado e Não Autorizado
	Iif (cTpBusca == "1", cWhr += " AND BE4_CODOPE+BE4_ANOINT+ BE4_MESINT+ BE4_NUMINT = '" + cBusca + "'", cWhr += " AND UPPER (BE4_NOMUSR) LIKE '%" + UPPER(cBusca) + "%'")
Endif	

cSql += cWhr

Return( {cAlias,cCampos,cSql} )

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PF3BAUCPF
Retorna CPF e NOME da rede de atendimento PF (consulta F3 - codigo operadora - portal prestador)

@author		totvs team
@since		28/06/2017
@version	11.8 
@return		{ cAlias,cCampos,cSql }
/*/
//---------------------------------------------------------------------------------------
User Function PF3BAUCPF()
	local cTpBusca 	:= paramixb[1]
	local cBusca 		:= paramixb[2]
	local cAlias		:= "BAU"
	local cCampos		:= "BAU_CPFCGC,BAU_NOME"
	local cSql 		:= ""
	
	cSql := " SELECT BAU_CPFCGC, BAU_NOME, R_E_C_N_O_ RECNO "
	cSql += " FROM " + RetSQLName( cAlias )
	cSql += " WHERE " + cAlias + "_FILIAL = '" + xFilial(cAlias) + "' "
	
	If !Empty(cBusca)    
		Do Case
			Case cTpBusca == "1"
	 			cSql += " AND BAU_CPFCGC LIKE '" + cBusca + "%' "
			Case cTpBusca == "2"
	 			cSql += " AND BAU_NOME LIKE '%" + cBusca + "%' "
		EndCase
	EndIf
	
	cSql += " AND D_E_L_E_T_ = '' "
	cSql += " ORDER BY BAU_CODIGO "

return( { cAlias,cCampos,cSql } )

//---------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSF3BG9
Retorna codigo e descrição do grupo empresa (consulta F3 - portal empresa/beneficiario)

@author		totvs team
@since		20/12/2017
@version	12.1.17
@return		{ cAlias,cCampos,cSql }
/*/
//---------------------------------------------------------------------------------------

User Function PLSF3BG9()
	LOCAL cTpBusca 	:= paramixb[1]
	LOCAL cBusca 		:= paramixb[2]
	LOCAL cCodLWeb	:= paramixb[5]
	LOCAL nTpPor		:= paramixb[6]
	LOCAL cAlias		:= "BG9"
	LOCAL cAliasAux	:= Iif( nTpPor == 2 ,"B40" ,"B49")
	Local cAliasBA1 	:= "BA1"
	LOCAL cCampos		:= "BG9_CODIGO,BG9_DESCRI"
	LOCAL cSql 		:= ""

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Query para retornar dados do F3
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If cBanco == "ORACLE"
		cSql := "SELECT DISTINCT CONCAT( BG9_CODINT,CONCAT('.',BG9_CODIGO))  BG9_CODIGO ,"			
	Else	
		cSql := "SELECT DISTINCT BG9_CODINT || '" + "." + "' + BG9_CODIGO  BG9_CODIGO,"
	Endif 
	cSql += " BG9_DESCRI,  " + RetSQLName(cAliaS) + ".R_E_C_N_O_ RECNO"
	cSql += "  FROM " + RetSQLName(cAlias) 		+ " " +  RetSQLName(cAlias) + ", " + RetSQLName(cAliasAux) + ", " + RetSQLName(cAliasBA1)
	cSql += " WHERE " + cAlias + "_FILIAL = '" 	+ xFilial(cAlias) + "' "
	cSql += "   AND " + RetSQLName(cAlias) 	 	+	".D_E_L_E_T_ = ' ' "
	cSql += "   AND " + RetSQLName(cAliasAux) 	+	".D_E_L_E_T_ = ' ' "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Empresa
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If nTpPor == 2
		cSql += " AND B40_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += " AND B40_CODUSR = '" + cCodLWeb + "' "
		cSql += " AND BG9_CODIGO = B40_CODEMP "
		cSql += " AND BG9_CODINT = B40_CODINT "
	
	ElseIf nTpPor == 3
		cSql += " AND B49_FILIAL = '" + xFilial(cAlias) + "' "
		cSql += " AND B49_CODUSR = '" + cCodLWeb + "' "
	  	cSQL += " AND BA1_CODINT||BA1_CODEMP||BA1_MATRIC||BA1_TIPREG||BA1_DIGITO = B49_BENEFI "   
	   	cSQL += " AND BG9_CODIGO = BA1_CODEMP"
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	//³ Inclui a busca especifica
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
	If !Empty(cBusca)
		Do Case
			Case cTpBusca == "1"
		 		cSql += " AND BG9_CODIGO = '" + cBusca + "%' "
		 		
			Case cTpBusca == "2"
		 		cSql += " AND BG9_DESCRI LIKE '" + cBusca + "%' "
		EndCase
	EndIf
	
	cSql += " ORDER BY BG9_CODIGO ,BG9_DESCRI "
	
Return( {cAlias,cCampos,cSql} )

