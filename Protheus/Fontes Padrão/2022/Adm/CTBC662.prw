#Include 'Protheus.ch'
#Include 'CTBC662.ch'
#INCLUDE 'FWMVCDEF.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTBC662   ³ Autor ³ Wilson P. Godoi       ³ Data ³01/04/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Rotina utilizada para Rastrear Lancamento Contabil         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBC662(cAlias,__nRecProc)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBC662                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cAlias : Alias do arquivo                                  ³±±
±±³          ³ __nRecProc: Numero do Registro Doc. Original               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBC662( cAlias, __nRecOri)
Local lRet				:= .F.
Local cSeq				:= ""
Local cChave			:= ""                                   
Local dDtCV3			:= ""
Local nInitCBox			:= 0
Local lDel				:= Set(_SET_DELETED) 
Local aArea   			:= GetArea()
Local aAreaSE2			:= {}
Local aAreaCT2			:= {}
Local aAreaCV3			:= {}
Local aAreaSF1			:= {}
Local aAreaSE5			:= {}
Local aAreaSEK			:= {}
Local aAreaSEZ			:= {}
Local aAreaSEV			:= {}
Local aAreaSEU			:= {}
Local aAreaSN3			:= {}
Local aAreaSN4			:= {}
Local aAreaF43          := {}
Local aAreaF36          := {}
Local aAreaF3C          := {}
Local aCbox				:= {}
Local cTabOri 			:= cAlias
Local aEnableButtons	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil}}
Local cChaveBsc			:= ""
Local cSN3KEY			:= "" 
Local nTamChave			:= 0
Local lRetCT2			:= .F.
Local cTabF4C           := ""

PRIVATE __cAliasORI		:= cTabOri
PRIVATE __nRecProc 		:= __nRecOri
PRIVATE cCpoOri 		:= ""
PRIVATE aCpoOri 		:= {} // Utilizar no MVC para mostrar campos do Doc.Original
PRIVATE __aLanCT2		:= {}
PRIVATE __aRetItem		:= {}
PRIVATE __aDocOri		:= {}
PRIVATE __cLP			:= ""
PRIVATE cCadastro		:= OemToAnsi(STR0001) //"Rastrear Lançamentos Contabeis"
PRIVATE aCboxCT5		:= {}
PRIVATE lIsRussia		:= cPaisLoc=="RUS"

SX3->(DbSetOrder(2))
SX3->(DbSeek("CT5_DC"))
aCbox := RetSX3Box(X3Cbox(),@nInitCBox,,SX3->X3_TAMANHO)
If Empty(aCbox)
	Aadd(aCboxCT5,STR0004)	//"a debito"
	Aadd(aCboxCT5,STR0005)	//"a credito"	
	Aadd(aCboxCT5,STR0006)	//"partida dobrada"
Else
	For nInitCBox := 1 To Len(aCbox)
		Aadd(aCboxCT5,aCbox[nInitCBox,3])
	Next
Endif
SX3->(DbSetOrder(1))

Do Case
	Case cTabOri == "F4C" //Bank statement
		//Find Bank Transactions 
		__cAliasORI := "F4C"
		__cLP       := "570" 
		DbSelectArea("F4C")
		F4C->(DbGoto(__nRecProc))
		//Add Fields to be showed 
	 	aAdd(aCpoOri,"F4C_INTNUM")
	 	aAdd(aCpoOri,"F4C_DTTRAN")
	 	aAdd(aCpoOri,"F4C_BNKORD")
	 	aAdd(aCpoOri,"F4C_PAYACC")
	 	aAdd(aCpoOri,"F4C_ACPNAM")
	    CargaINI()	//Download fields of original document in model		
		lRet := CargaCT2(__cAliasORI,__nRecProc) // Select Bank Transaction Postings related to BS
		//Find Wtrite Offs 		
		cQuery := " SELECT                                                                 "
		cQuery += "        FK2.R_E_C_N_O_                                                  "
		cQuery += " FROM"        + RetSQLName("FKA") + "                 FKA               "
		cQuery += " INNER JOIN " + RetSQLName("FK2") + "                 FK2               "
		cQuery += "         ON   FK2.FK2_FILIAL ='"+xFilial("FK2") + "'                    "
		cQuery += "        AND   FK2.FK2_IDFK2  = FKA.FKA_IDORIG                           "
		cQuery += "        AND   FK2.D_E_L_E_T_ = ' '                                      "
		cQuery += " INNER JOIN                                                             "
		cQuery += "           (                                                            "
		cQuery += "             SELECT                                                     "
		cQuery += "                    FKAPROC.FKA_IDPROC                                  "
		cQuery += "             FROM "       + RetSQLName("FK5") + "     FK5               "
		cQuery += "             INNER JOIN " + RetSQLName("FKA") + " FKAPROC               "
		cQuery += "                     ON   FKAPROC.FKA_FILIAL = '"+xFilial("FKA")+"'     "
		cQuery += "                    AND   FKAPROC.FKA_IDORIG = FK5.FK5_IDMOV            "
		cQuery += "                    AND   FKAPROC.D_E_L_E_T_ = ' '                      "
		cQuery += "             WHERE  FK5.FK5_FILIAL = '"+xFilial("FK5")+ "'              "
		cQuery += "               AND  FK5.FK5_IDBS   = '"+ F4C->F4C_CUUID + "'            "
		cQuery += "               AND  FK5.D_E_L_E_T_ = ' '                                "
		cQuery += "             GROUP  BY FKAPROC.FKA_IDPROC                               "
		cQuery += "           )                                          PRO               "
		cQuery += " ON   FKA.FKA_FILIAL = '"+xFilial("FKA")+"'                             "
		cQuery += " AND  FKA.FKA_IDPROC = PRO.FKA_IDPROC                                   "
		cQuery += " AND  FKA.FKA_TABORI = 'FK2'                                            "
		cQuery += " AND  FKA.D_E_L_E_T_ = ' '                                              "
		cQuery := ChangeQuery(cQuery)
		cTabF4C := MPSysOpenQuery(cQuery)
		DbSelectArea(cTabF4C)
		DBGoTop()
		While (cTabF4C)->(!EoF())
			lRet := CargaCT2("FK2",(cTabF4C)->R_E_C_N_O_) // Select Write-Off Postings related to BS
			(cTabF4C)->(DbSkip())
		EndDo
		(cTabF4C)->(DBCloseArea())
	Case cTabOri == "SC5" //Pedido de venda
		//Busca a Nota de Entrada
		DbSelectArea("SC5")
		SC5->(DbGoto(__nRecProc))
		__nRecProc:= (__cAliasORI)->(Recno())
		__cLP:="621"
		CargaCTL(__cLP,"SC5")
		lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da Nota de Entrada
		cQuery := "select R_E_C_N_O_ From " + RetSQLName("SC6")
		cQuery += " where C6_FILIAL = '" + xFilial("SC6") + "'"
		cQuery += " and C6_NUM = '" + SC5->C5_NUM + "'"
		cQuery += " and D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cTabSEV := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEV,.T.,.T.)
		While !((cTabSEV)->(Eof()))
			lRet:= CargaCT2("SC6",(cTabSEV)->R_E_C_N_O_) // Seleciona os Lanctos Contábeis da Nota de Entrada
			(cTabSEV)->(DbSkip())
		Enddo
		DbSelectArea(cTabSEV)
		DbCloseArea()
	
	Case cTabOri == "SE2" //FINA050
		dbSelectArea("SE2")
		dbSetOrder(1)
		DbGoto(__nRecProc)
		__cLP:="510" // Fixo para pegar os campos da SE2 que estão na CTL
		CargaCTL(__cLP,"SE2")
		lRet:=CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SE2
		
		//Busca Baixas
		DbSelectArea("SE5")
		dbSetOrder(7)
		SE5->(DbSeek(xFilial("SE5")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
		While !(EOF()) .And. xFilial("SE5")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) == xFilial("SE5")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
			__cAliasORI:= "SE5"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSE5:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSE5)
			SE5->(DbSkip())
		End
		
		//Busca a Nota de Entrada
		DbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1") + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)))
			__cAliasORI:="SF1"
			__nRecProc:= (__cAliasORI)->(Recno())
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
		EndIf

		//Busca a Nota de Entrada (itens)
		DbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		cChaveBsc := xFilial("SD1")+SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)
		If SD1->(DbSeek(cChaveBsc))
			__cAliasORI:="SD1"

			While !SD1->( Eof() ) .And. SD1->( D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA ) == cChaveBsc
				__nRecProc:= (__cAliasORI)->(Recno())
				lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
				SD1->( dbSkip() )
			EndDo
		EndIf
		
		//Busca a Nota de credito 
		DbSelectArea("SF2")
		SF2->(dbSetOrder(2))
		If SF2->(DbSeek(xFilial("SF2")+SE2->(E2_FORNECE + E2_LOJA + E2_NUM + E2_PREFIXO)))
			__cAliasORI:="SF2"
			__nRecProc:= (__cAliasORI)->(Recno())
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
		EndIf
		
		//Busca a Nota de credito (itens)
		DbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		cChaveBsc :=  xFilial("SD2")+SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)
		If SD2->(DbSeek(cChaveBsc))
			__cAliasORI:="SD2"

			While !SD2->( Eof() ) .And. SD2->( D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ) == cChaveBsc 
				__nRecProc:= (__cAliasORI)->(Recno())
				lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
				SD2->( dbSkip() )
			EndDo
		EndIf

		//Busca Rateio por Natureza com CC
		DbSelectArea("SE2")
		SE2->(dbSetOrder(1))
		SE2->(DbGoto(__nRecOri))
		cTabSEZ	  := GetNextAlias()
		cQuerY		:= ""
		cQuery		+= "SELECT"
		cQuery		+= " R_E_C_N_O_ "
		cQuery		+= " FROM "+RetSQLName("SEZ")+" TMP"
		cQuery		+= " WHERE"
		cQuery		+= " EZ_FILIAL = '"+xFilial("SEZ")+"' AND "
		cQuery		+= " EZ_PREFIXO = '"+E2_PREFIXO+"' AND "
		cQuery		+= " EZ_NUM = '"+E2_NUM+"' AND "
		cQuery		+= " EZ_PARCELA = '"+E2_PARCELA+"' AND "
		cQuery		+= " EZ_TIPO = '"+E2_TIPO+"' AND "
		cQuery		+= " EZ_CLIFOR = '"+E2_FORNECE+"' AND "
		cQuery		+= " EZ_LOJA = '"+E2_LOJA+"' AND "
		cQuery     += " TMP.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEZ,.T.,.T.)
		
		__cAliasORI:="SEZ"
		While !((cTabSEZ)->(Eof()))
			__nRecProc:= (cTabSEZ)->R_E_C_N_O_
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SEZ
			(cTabSEZ)->(DbSkip())
		End
		DbSelectArea(cTabSEZ)
		DbCloseArea()
	
		//Busca Multiplas Naturezas por Titulo
		DbSelectArea("SE2")
		SE2->(dbSetOrder(1))
		SE2->(DbGoto(__nRecOri))
		cTabSEV	  := GetNextAlias()
		cQuerY		:= ""
		cQuery		+= "SELECT"
		cQuery		+= " R_E_C_N_O_ "
		cQuery		+= " FROM "+RetSQLName("SEV")+" TMP"
		cQuery		+= " WHERE"
		cQuery		+= " EV_FILIAL = '"+xFilial("SEV")+"' AND "
		cQuery		+= " EV_PREFIXO = '"+E2_PREFIXO+"' AND "
		cQuery		+= " EV_NUM = '"+E2_NUM+"' AND "
		cQuery		+= " EV_PARCELA = '"+E2_PARCELA+"' AND "
		cQuery		+= " EV_TIPO = '"+E2_TIPO+"' AND "
		cQuery		+= " EV_CLIFOR = '"+E2_FORNECE+"' AND "
		cQuery		+= " EV_LOJA = '"+E2_LOJA+"' AND "
		cQuery     += " TMP.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEV,.T.,.T.)
	
		__cAliasORI:="SEV"
		While !((cTabSEV)->(Eof()))
			__nRecProc:= (cTabSEV)->R_E_C_N_O_
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SEV
			(cTabSEV)->(DbSkip())
		End
		DbSelectArea(cTabSEV)
		DbCloseArea()
	
			
	Case cTabOri == "SE1" //FINA040
	
		dbSelectArea("SE1")
		dbSetOrder(1)
		DbGoto(__nRecProc)
		__cLP:="500" // Fixo para pegar os campos da SE1 que estão na CTL
		CargaCTL(__cLP,"SE1")
		lRet:=CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF2
		
		//Busca Baixas
		DbSelectArea("SE5")
		dbSetOrder(7)
		SE5->(DbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
		While !(EOF()) .And. xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == xFilial("SE5")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
			__cAliasORI:= "SE5"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSE5:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE2
			RestArea(aAreaSE5)
			SE5->(DbSkip())
		End
		
		//Busca a Nota de Saida
		DbSelectArea("SF2")
		SF2->(dbSetOrder(2))
		If SF2->(DbSeek(xFilial("SF2") + SE1->(E1_CLIENTE + E1_LOJA + E1_NUM + If(Empty(E1_SERIE),E1_PREFIXO,E1_SERIE))))
			__cAliasORI:="SF2"
			__nRecProc:= (__cAliasORI)->(Recno())
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
		EndIf
		
		//Busca a Nota de Saida (itens)
		DbSelectArea("SD2")
		SD2->(dbSetOrder(3))
		cChaveBsc := xFilial("SD2") + SE1->(E1_NUM + If(Empty(E1_SERIE),E1_PREFIXO,E1_SERIE) + E1_CLIENTE + E1_LOJA)
		If SD2->(DbSeek(cChaveBsc))
			__cAliasORI:="SD2"

			While !SD2->( Eof() ) .And. SD2->( D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA ) == cChaveBsc
				__nRecProc:= (__cAliasORI)->(Recno())
				lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
				SD2->( dbSkip() )
			EndDo
		EndIf

		//Busca a Nota de credito
		DbSelectArea("SF1")
		SF1->(dbSetOrder(1))
		If SF1->(DbSeek(xFilial("SF1") + SE1->(E1_NUM + If(Empty(E1_SERIE),E1_PREFIXO,E1_SERIE) + E1_CLIENTE + E1_LOJA)))
			__cAliasORI:="SF1"
			__nRecProc:= (__cAliasORI)->(Recno())
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
		EndIf

		//Busca a Nota de credito (itens)
		DbSelectArea("SD1")
		SD1->(dbSetOrder(1))
		cChaveBsc := xFilial("SD1") + SE1->(E1_NUM + If(Empty(E1_SERIE),E1_PREFIXO,E1_SERIE) + E1_CLIENTE + E1_LOJA)
		If SD1->(DbSeek(cChaveBsc))
			__cAliasORI:="SD1"

			While !SD1->( Eof() ) .And. SD1->( D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA ) == cChaveBsc 
				__nRecProc:= (__cAliasORI)->(Recno())
				lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SF1
				SD1->( dbSkip() )
			EndDo
		EndIf

		//Busca a Rateios do Titulo
		DbSelectArea("SE1")
		SE1->(dbSetOrder(1))		
		SE1->(DbGoto(__nRecOri))
		cTabSEZ	  := GetNextAlias()
		cQuerY		:= ""
		cQuery		+= "SELECT"
		cQuery		+= " R_E_C_N_O_ "
		cQuery		+= " FROM "+RetSQLName("SEZ")+" TMP"
		cQuery		+= " WHERE"
		cQuery		+= " EZ_FILIAL = '"+xFilial("SEZ")+"' AND "
		cQuery		+= " EZ_PREFIXO = '"+E1_PREFIXO+"' AND "
		cQuery		+= " EZ_NUM = '"+E1_NUM+"' AND "
		cQuery		+= " EZ_PARCELA = '"+E1_PARCELA+"' AND "
		cQuery		+= " EZ_TIPO = '"+E1_TIPO+"' AND "
		cQuery		+= " EZ_CLIFOR = '"+E1_CLIENTE+"' AND "
		cQuery		+= " EZ_LOJA = '"+E1_LOJA+"' AND "
		cQuery     += " TMP.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEZ,.T.,.T.)
		
		__cAliasORI:="SEZ"
		While !((cTabSEZ)->(Eof()))
			__nRecProc:= (cTabSEZ)->R_E_C_N_O_
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SEZ
			(cTabSEZ)->(DbSkip())
		End
		DbSelectArea(cTabSEZ)
		DbCloseArea()
	
	//Busca Multiplas Naturezas por Titulo
		DbSelectArea("SE2")
		SE2->(dbSetOrder(1))
		SE2->(DbGoto(__nRecOri))
		cTabSEV	  := GetNextAlias()
		cQuerY		:= ""
		cQuery		+= "SELECT"
		cQuery		+= " R_E_C_N_O_ "
		cQuery		+= " FROM "+RetSQLName("SEV")+" TMP"
		cQuery		+= " WHERE"
		cQuery		+= " EV_FILIAL = '"+xFilial("SEV")+"' AND "
		cQuery		+= " EV_PREFIXO = '"+E2_PREFIXO+"' AND "
		cQuery		+= " EV_NUM = '"+E2_NUM+"' AND "
		cQuery		+= " EV_PARCELA = '"+E2_PARCELA+"' AND "
		cQuery		+= " EV_TIPO = '"+E2_TIPO+"' AND "
		cQuery		+= " EV_CLIFOR = '"+E2_FORNECE+"' AND "
		cQuery		+= " EV_LOJA = '"+E2_LOJA+"' AND "
		cQuery     += " TMP.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEV,.T.,.T.)
	
		__cAliasORI:="SEV"
		While !((cTabSEV)->(Eof()))
			__nRecProc:= (cTabSEV)->R_E_C_N_O_
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SEV
			(cTabSEV)->(DbSkip())
		End
		DbSelectArea(cTabSEV)
		DbCloseArea()
	
	
	Case cTabOri == "SN1" //ATFA012
		dbSelectArea("SN1")
		DbGoto(__nRecProc)

		If cPaisLoc == "RUS"
			lIsRussia := .T.
		 	__cAliasORI:= "SN1"
			__cLP:="807" // Fixo para pegar os campos da SN1 que estão na CTL
		 	aAdd(aCpoOri,"N1_FILIAL")
		 	aAdd(aCpoOri,"N1_CBASE")
		 	aAdd(aCpoOri,"N1_ITEM")
		 	aAdd(aCpoOri,"N1_DESCRIC")
		 	CargaINI()	//Download fields of original document in model
		Else
			//Busca SN4
			dbSelectArea("SN4")
			dbSetOrder(1)
			DbSeek(xFilial("SN4")+SN1->(N1_CBASE+N1_ITEM),.F.)
			__cLP:="807" // Fixo para pegar os campos da SN1 que estão na CTL
			__cAliasORI:= "SN4"
			CargaCTL(__cLP,"SN4")
		
		EndIf
		//Busca SN3 na CV3
		dbSelectArea("SN3")
		dbSetOrder(1)
		DbSeek(xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM),.F.)
		While !(EOF()) .And. xFilial("SN3")+SN3->(N3_CBASE+N3_ITEM) == xFilial("SN1")+SN1->(N1_CBASE+N1_ITEM)
			__cAliasORI:= "SN3"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSN3:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSN3)
			SN3->(DbSkip())
		End
		
		//Busca SN4 na CV3
		DbSelectArea("SN4")
		dbSetOrder(1)
		DbSeek(xFilial("SN4")+SN1->(N1_CBASE+N1_ITEM),.F.)
		While !(EOF()) .And. xFilial("SN4")+SN4->(N4_CBASE+N4_ITEM) == xFilial("SN1")+SN1->(N1_CBASE+N1_ITEM)
			__cAliasORI:= "SN4"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSN4:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSN4)
			SN4->(DbSkip())
		End
	
	Case cTabOri == "SN3" //ATFA060 - ATFA036
		dbSelectArea("SN3")
		DbGoto(__nRecProc)
		__cLP:="807" // Fixo para pegar os campos da SN1 que estão na CTL
		__cAliasORI:= "SN3"
		CargaCTL(__cLP,"SN3")
		lRet:=CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da CT2
		
		//Busca SN4
		dbSelectArea("SN4")
		dbSetOrder(1)
		DbSeek(xFilial("SN4")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO),.F.)
		__cLP:="807" // Fixo para pegar os campos da SN1 que estão na CTL
		__cAliasORI:= "SN4"
		
		//Busca SN4 na CV3
		DbSelectArea("SN4")
		dbSetOrder(1)
		DbSeek(xFilial("SN4")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO),.F.)
		While !(EOF()) .And. xFilial("SN4")+SN4->(N4_CBASE+N4_ITEM+N4_TIPO) == xFilial("SN3")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO)
			__cAliasORI:= "SN4"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSN4:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSN4)
			SN4->(DbSkip())
		End

	Case cTabOri == "FN6" //ATFA036
		DbSelectArea("FN6")
		DbGoto(__nRecProc)

		//Busca SN4
		DbSelectArea("SN4")
		DbSetOrder(1)
		DbSeek(XFilial("SN4")+FN6->(FN6_CBASE+FN6_CITEM),.F.)
		__cLP:="807" // Fixo para pegar os campos da SN1 que estão na CTL
		__cAliasORI:= "SN4"
		CargaCTL(__cLP,"SN4")

		//Busca SN3 na CV3
		DbSelectArea("SN3")
		DbSetOrder(1)
		DbSeek(xFilial("SN3")+FN6->(FN6_CBASE+FN6_CITEM),.F.)
		While !(EOF()) .And. XFilial("SN3")+SN3->(N3_CBASE+N3_ITEM) == XFilial("FN6")+FN6->(FN6_CBASE+FN6_CITEM)
			__cAliasORI:= "SN3"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSN3:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSN3)
			SN3->(DbSkip())
		End

		//Busca SN4 na CV3
		DbSelectArea("SN4")
		DbSetOrder(1)
		DbSeek(xFilial("SN4")+FN6->(FN6_CBASE+FN6_CITEM),.F.)
		While !(EOF()) .And. XFilial("SN4")+SN4->(N4_CBASE+N4_ITEM) == XFilial("FN6")+FN6->(FN6_CBASE+FN6_CITEM)
			__cAliasORI:= "SN4"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSN4:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSN4)
			SN4->(DbSkip())
		End

	Case cTabOri == "SEF" //FINA096
		dbSelectArea("SEF")
		DbGoto(__nRecProc)
		__cLP:="590" // Fixo para pegar os campos da SE2 que estão na CTL
		CargaCTL(__cLP,"SEF")
		lRet:=CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SE2
		
		//Busca Baixas
		DbSelectArea("SE5")
		dbSetOrder(11)
		SE5->(DbSeek(xFilial("SE5")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM+DTOS(EF_DATA))))
		While !(EOF()) .And. xFilial("SE5")+SEF->(EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM+DTOS(EF_DATA)) == xFilial("SE5")+SE5->(E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ+DTOS(E5_DATA))
			__cAliasORI:= "SE5"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSE5:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSE5)
			SE5->(DbSkip())
		End
	
	
	Case cTabOri == "SF1" //MATA103
		
		//Busca a Nota de Entrada
		DbSelectArea("SF1")
		SF1->(DbGoto(__nRecProc))
		cChaveSD1:= xFilial("SD1")+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA // Chave para procura da SD1
		__nRecProc:= (__cAliasORI)->(Recno())
		__cLP:="650"
		CargaCTL(__cLP,"SF1")
		lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da Nota de Entrada
		cQuery := "select R_E_C_N_O_ From " + RetSQLName("SD1")
		cQuery += " where D1_FILIAL = '" + xFilial("SD1") + "'"
		cQuery += " and D1_DOC = '" + SF1->F1_DOC + "'"
		cQuery += " and D1_SERIE = '" + SF1->F1_SERIE + "'"
		cQuery += " and D1_FORNECE = '" + SF1->F1_FORNECE + "'"
		cQuery += " and D1_LOJA = '" + SF1->F1_LOJA + "'"
		cQuery += " and D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cTabSEV := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEV,.T.,.T.)
		While !((cTabSEV)->(Eof()))
			lRet:= CargaCT2("SD1",(cTabSEV)->R_E_C_N_O_) // Seleciona os Lanctos Contábeis da Nota de Entrada
			(cTabSEV)->(DbSkip())
		Enddo
		DbSelectArea(cTabSEV)
		DbCloseArea()

	Case cTabOri == "FJT" //fina846
		DbSelectArea("FJT")
		FJT->(DbGoto(__nRecProc))
		cChaveSEL := xFilial("SEL")+FJT_SERIE+FJT_RECIBO+FJT_VERSAO // Chave para procura da SEL
		__nRecProc := (__cAliasORI)->(Recno()) 
		__cLP:="576"
		CargaCTL(__cLP,"FJT")
		lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da Nota de Entrada
		cQuery := "select R_E_C_N_O_ From " + RetSQLName("SEL")
		cQuery += " where EL_FILIAL = '" + xFilial("SEL") + "'"
		cQuery += " and EL_SERIE = '" + FJT->FJT_SERIE + "'"
		cQuery += " and EL_RECIBO = '" + FJT->FJT_RECIBO + "'"
		cQuery += " and EL_VERSAO = '" + FJT->FJT_VERSAO + "'"		
		cQuery += " and D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cTabSEV := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEV,.T.,.T.)
		While !((cTabSEV)->(Eof()))
			lRet:= CargaCT2("SEL",(cTabSEV)->R_E_C_N_O_) // Seleciona os Lanctos Contábeis da Nota de Entrada
			(cTabSEV)->(DbSkip())
		Enddo
		DbSelectArea(cTabSEV)
		DbCloseArea()

		Case cTabOri $ "SF2|SC9"
		
		//Busca a Nota de Saida
		DbSelectArea("SF2")
		If cTabOri == "SF2"
			SF2->(DbGoto(__nRecProc))
			cChaveSD2 := xFilial("SD2")+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA // Chave para procura da SD2
			__nRecProc := (__cAliasORI)->(Recno())
		Else
			SF2->(dbSetOrder(1))
			SF2->(DbSeek(xFilial("SF2") + SC9->C9_NFISCAL + SC9->C9_SERIENF + SC9->C9_CLIENTE + SC9->C9_LOJA ))
			__cAliasORI := "SF2"
			__nRecProc := (__cAliasORI)->(Recno())
		EndIf	
		__cLP:="620"
		CargaCTL(__cLP,"SF2")
		lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da Nota de Entrada
		cQuery := "select R_E_C_N_O_ From " + RetSQLName("SD2")
		cQuery += " where D2_FILIAL = '" + xFilial("SD2") + "'"
		cQuery += " and D2_DOC = '" + SF2->F2_DOC + "'"
		cQuery += " and D2_SERIE = '" + SF2->F2_SERIE + "'"
		cQuery += " and D2_CLIENTE = '" + SF2->F2_CLIENTE + "'"
		cQuery += " and D2_LOJA = '" + SF2->F2_LOJA + "'"
		cQuery += " and D_E_L_E_T_ = ' '"
		cQuery := ChangeQuery(cQuery)
		cTabSEV := GetNextAlias()
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabSEV,.T.,.T.)
		While !((cTabSEV)->(Eof()))
			lRet:= CargaCT2("SD2",(cTabSEV)->R_E_C_N_O_) // Seleciona os Lanctos Contábeis da Nota de Entrada
			(cTabSEV)->(DbSkip())
		Enddo
		DbSelectArea(cTabSEV)
		DbCloseArea()
	
	Case cTabOri == "SET" //FINA550
		dbSelectArea("SET")
		dbSetOrder(1)
		DbGoto(__nRecProc)
		__cLP:="572"
		__cAliasORI:="SET"
		aAdd(aCpoOri,"ET_FILIAL")
		aAdd(aCpoOri,"ET_CODIGO")
		aAdd(aCpoOri,"ET_NOME")
		CargaINI()
	
		//Busca todos movimentos deste Caixinha
		DbSelectArea("SEU")
		dbSetOrder(2)
		SEU->(DbSeek(xFilial("SEU")+SET->(ET_CODIGO)))
		While !(EOF()) .And. xFilial("SEU")+SEU->(EU_CAIXA) == xFilial("SET")+SET->(ET_CODIGO)
			__cAliasORI:= "SEU"
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSEU:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
			RestArea(aAreaSEU)
			SEU->(DbSkip())
		EndDo
	
	Case cPaisLoc <> "BRA" .And. cTabOri == "FJR" //FINA847
		dbSelectArea("FJR")
		DbGoto(__nRecProc)
		__cLP:="570" // Fixo para pegar os campos da FJR que estão na CTL
		
		//lRet:=CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis da SE2
		
		//Busca Ordem de Pago
		DbSelectArea("SEK")
		dbSetOrder(1)
		__cAliasORI:= "SEK"
		SEK->(DbSeek(xFilial("SEK")+FJR->FJR_ORDPAG))
		CargaCTL(__cLP,"SEK")
		While !(EOF()) .And. xFilial("SEK")+SEK->EK_ORDPAGO == xFilial("SEK")+FJR->FJR_ORDPAG
			__nRecProc:=(__cAliasORI)->(Recno())
			aAreaSEK:= GetArea()
			lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SEK
			RestArea(aAreaSEK)
			SEK->(DbSkip())
		EndDo

	Case cTabOri == "F35"
		dbSelectArea(__cAliasORI)
		(__cAliasORI)->(DbGoto(__nRecProc))
		__cLP:=""
		lRet:=CargaCT2(__cAliasORI,__nRecProc)
		
		DbSelectArea("F36")
		F36->(DbSetOrder(1)) //F36_FILIAL+F36_KEY+F36_ITEM
		If (F36->(DbSeek(xFilial("F36") + F35->F35_KEY)))
			While ((F36->(!Eof())) .And. (F35->F35_KEY == F36->F36_KEY))
				__cAliasORI:= "F36"
				__nRecProc:=(__cAliasORI)->(Recno())
				aAreaF36:= GetArea()
				lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
				RestArea(aAreaF36)
				
				F36->(DbSkip())
			Enddo
		Endif
	
	Case cTabOri=="F3B"// Purchase book RU09T05
		dbSelectArea(__cAliasORI)
		(__cAliasORI)->(DbGoto(__nRecProc))
		__cLP:=""
		lRet:=CargaCT2(__cAliasORI,__nRecProc)

		DbSelectArea("F3C")
        F3C->(DbSetOrder(2)) //F3C_FILIAL + F3C_BOOKEY
        If (F3C->(DbSeek(xFilial("F3C") + F3B->F3B_BOOKEY)))
            While ((F3C->(!Eof())) .And. (F3C->F3C_FILIAL + F3C->F3C_BOOKEY == F3B->F3B_FILIAL + F3B->F3B_BOOKEY))
                __cAliasORI:= "F3C"
                __nRecProc:=(__cAliasORI)->(Recno())
                aAreaF3C:= GetArea()
                lRet:= CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contabeis da SE5
                RestArea(aAreaF3C)

                F3C->(DbSkip())
            Enddo
		EndIf
	Otherwise
		dbSelectArea(__cAliasORI)
		(__cAliasORI)->(DbGoto(__nRecProc))
		__cLP:=""
		lRet:=CargaCT2(__cAliasORI,__nRecProc) // Seleciona os Lanctos Contábeis
EndCase
If lRet == .F.
	Help(" ",1,"NAOLANC",,STR0002,1,0)  //"Não se encontrou lançamentos contábeis para o documento"
EndIf	

RestArea(aArea)
Set(_SET_DELETED, lDel)
If lRet
	FWExecView(IIf(lIsRussia, STR0013 ,STR0003),"CTBC662",3,, { || .T. },,,aEnableButtons )  // "Contábil"
EndIF

Asize(aAreaSE2,0)
Asize(aAreaCT2,0)
Asize(aAreaCV3,0)
Asize(aAreaSF1,0)
Asize(aAreaSE5,0)
Asize(aAreaSEK,0)
Asize(aAreaSEZ,0)
Asize(aAreaSEV,0)
Asize(aAreaSEU,0)
Asize(aAreaSN3,0)
Asize(aAreaSN4,0)
Asize(aCbox,0)
Asize(aCboxCT5,0)

aAreaSE2 := Nil
aAreaCT2 := Nil
aAreaCV3 := Nil
aAreaSF1 := Nil
aAreaSE5 := Nil
aAreaSEK := Nil
aAreaSEZ := Nil
aAreaSEV := Nil
aAreaSEU := Nil
aAreaSN3 := Nil
aAreaSN4 := Nil
aCbox := Nil
aCboxCT5 := Nil
Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} CargaINI(__cAliasORI)
 Carga dos Campos da Tabela Origem para Mostrar na AddField 

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CargaINI()
	
	Local nX:= 0 

	For nX:=1 to Len(aCpoOri)
		If lIsRussia .AND.;
		   GetSX3Cache(aCpoOri[nX],"X3_CONTEXT") == "V"
		    aAdd(__aDocOri,;
				     Eval(&("{|| "+AllTrim(GetSX3Cache(aCpoOri[nX],;
					 "X3_RELACAO"))+"} "))                         )
		    Loop
		EndIf
		aAdd(__aDocOri,&(__cAliasORI+"->"+aCpoOri[nX]))
	Next nX

Return __aDocOri


//-------------------------------------------------------------------
/*/{Protheus.doc} CargaCT2(__cAliasORI,__nRecProc)
Busca os Lançamentos Contábeis da CT2

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function CargaCT2(__cAliasORI,__nRecProc)
	Local lRet		:= .T.
	Local cQuery	:= ""
	Local aArea		:= GetArea()
	Local oFields	:= FWFormStruct(1, 'CT2')
	Local aCpoCT2	:= {}
	Local aCpoExc	:= {} //{"CT2_CONVER","CT2_VALR02","CT2_VALR03","CT2_VALR04","CT2_VALR05","CT2_DTTX02","CT2_DTTX03","CT2_DTTX04","CT2_DTTX05"}
	Local nX		:= 0         
	Local nY		:= 0        
	Local aAux		:= {}
	Local cCampo 	:= ""
	Local cTabCV3	:= ""
	Local cTabCT2	:= ""
	Local cChave	:= ""
	Local cCT2_DC	:= ""
	Local cQryCT2	:= ""
	Local cAliasCT2	:= ""
	
	DbSelectArea("CV3")
	CV3->(DbSetOrder(3))
	DbSeek(xFilial("CV3")+__cAliasORI+AllTrim(Str(__nRecProc)),.F.)
	If Empty(__cLP)
		__cLP:=CV3->(CV3_LP)
		CargaCTL(__cLP,__cAliasORI)
	EndIf
		cTabCV3	  := GetNextAlias()

		cQuerY		:= ""
		cQuery		+= "SELECT"
		cQuery		+= " CV3_RECDES"
		cQuery		+= " FROM "+RetSQLName("CV3")+" TMP"
		cQuery		+= " WHERE"               
		cQuery		+= " CV3_FILIAL = '"+xFilial("CV3")+"' AND " 
		cQuery		+= " CV3_TABORI = '"+__cAliasORI+"' AND "	
		cQuery		+= " CV3_RECORI = '"+ALLTRIM(STR(__nRecProc))+"' AND "
		cQuery		+= " (CV3_MOEDLC = '01' OR CV3_MOEDLC = '') AND"
		cQuery     += " TMP.D_E_L_E_T_ = ' ' "
		cQuery := ChangeQuery(cQuery)
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTabCV3,.T.,.T.)
		                                                 
		For nY := 1 to Len(oFields:aFields)
			aAdd(aCpoCT2, Alltrim(oFields:aFields[nY][3]) )
		Next nY
		
		aAdd(aCpoCT2, "CT2_DEC" )
		aAdd(aCpoCT2, "R_E_C_N_O_" )
		
		While (cTabCV3)->(!EOF())
		
			nPos:= Ascan(__aLanCT2,{|x| x[2,Len(aCpoCT2)] == (cTabCV3)->CV3_RECDES })
			If nPos == 0
				lRet:= IIf(Empty(Val((cTabCV3)->CV3_RECDES)),.F.,.T.)
				If lRet
					aAux := Nil
					aAux := Array(Len(aCpoCT2))
					CT2->(DbGoto(Val((cTabCV3)->CV3_RECDES)))
					
					If CT2->(eof())
						(cTabCV3)->(dbSkip())
						Loop 	
					EndIF

					If CT2->CT2_DC == "4"
						(cTabCV3)->(dbSkip())
						Loop
					EndIf
										
					If ! CT2->( Deleted() )
					
						For nX := 1 to Len(aCpoCT2)
							If aCpoCT2[nX] == "CT2_DC"
								cCampo   := aCpoCT2[nX]
								cCT2_DC := aCboxCT5[Val(CT2->&(cCampo))]
							EndIf
	//						If AScan(aCpoExc, { |x| UPPER(x) == aCpoCT2[nX]})== 0    // Não pegar esses campos Virtuais
							If CT2->(FieldPos(aCpoCT2[nX])) > 0 .Or. Alltrim(aCpoCT2[nX]) == "R_E_C_N_O_" .Or. AllTrim(aCpoCT2[nX]) == "CT2_DEC"
	
								If aCpoCT2[nX] = 'R_E_C_N_O_'
									cCampo   := aCpoCT2[nX]
									aAux[nX] := (cTabCV3)->(CV3_RECDES)
								ElseIf aCpoCT2[nX] = 'CT2_DEC'
									cCampo   := aCpoCT2[nX]
									aAux[nX] := cCT2_DC
								ElseIf aCpoCT2[nX] = 'CT2_HIST'
									cCampo := aCpoCT2[nX]
									cQryCT2 := "select CT2_HIST from " + RetSQLName("CT2")
									cQryCT2 += " where CT2_FILIAL='" + xFilial("CT2") + "'"
									cQryCT2 += " and CT2_DATA='" + Dtos(CT2->CT2_DATA) + "'"
									cQryCT2 += " and CT2_LOTE='" + CT2->CT2_LOTE + "'"
									cQryCT2 += " and CT2_SBLOTE='" + CT2->CT2_SBLOTE + "'"
									cQryCT2 += " and CT2_DOC='" + CT2->CT2_DOC + "'" 
									cQryCT2 += " and CT2_SEQLAN='" + CT2->CT2_SEQLAN + "'"
									cQryCT2 += " and CT2_FILORI='" + CT2->CT2_FILORI + "'"
									cQryCT2 += " and CT2_EMPORI='" + CT2->CT2_EMPORI + "'"
									cQryCT2 += " and CT2_MOEDLC='01'"
									cQryCT2 += " and D_E_L_E_T_=' '"
									cQryCT2 += " order by R_E_C_N_O_"
									cQryCT2 := ChangeQuery(cQryCT2)
									cAliasCT2 := GetNextAlias()
									DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryCT2),cAliasCT2,.F.,.T.)
									aAux[nX] := ""
									While !((cAliasCT2)->(Eof())) 
										aAux[nX] += (cAliasCT2)->CT2_HIST
										(cAliasCT2)->(DbSkip())
									Enddo
									DbSelectArea(cAliasCT2)
									DbCloseArea()
									DbSelectArea(cTabCV3)
								Else
									cCampo   := aCpoCT2[nX]
									aAux[nX] := CT2->&(cCampo)
								EndIf
							EndIF
						Next nX
						
						aAdd(__aLanCT2,{0 ,aAux })
					EndIf
				EndIf
			EndIf
			(cTabCV3)->(dbSkip())
		EndDo      
		If Select(cTabCV3) > 0
			DbSelectArea(cTabCV3)
			(cTabCV3)->(DbCloseArea())
		Endif
		If lRet
			If Empty(__aLanCT2)
				lRet := .F.
			Else
				lRet:= .T.
			EndIf
		EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel	:= Nil
Local cAliasTMP	:= GetNextAlias()
Local oStr1 	:= MontaSCab(cAliasTMP)
Local oStr3 	:= FWFormStruct(1,'CT2')

oModel := MPFormModel():New('CTBC662')

oModel:SetDescription(IIf(lIsRussia, STR0013 ,STR0007+"-"))  //"Rastreamento"

oStr3:AddField('CT2_DEC',STR0008 , 'CT2_DEC', 'C',17 )  //"Tipo de Lancamento"  -- Campo para colocar nome do tipo (a debito/a credito/partida dobrada)
oStr3:AddField('R_E_C_N_O_',"Recno CT2" , 'R_E_C_N_O_', 'C',17 ) // Cria o Recno na Field para guardar o RECDES da CV3 

oModel:addFields('DOCORI',,oStr1,,,{|oModel|CargaORI(oModel)},,)
//oModel:AddGrid(cId , cOwner , oModelStruct , bLinePre , bLinePost , bPre , bLinePost ,,, bLoad )
oModel:addGrid('LCTCT2','DOCORI',oStr3,,,,,{|oModel| CargaLCTO(oModel) })

oModel:SetPrimaryKey(  { "'"+(cAliasTMP)+"'->" + (cAliasTMP)+'_FILIAL'+"'"+(cAliasTMP)+"'->" + (cAliasTMP)+'_DATA' }) 
                                   
oModel:getModel('DOCORI'):SetDescription(STR0009) //"Documento"
oModel:getModel('LCTCT2'):SetDescription(STR0010) //"Lançamentos Contabeis"

oModel:Activate()

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oStr1:= MontaVCab()
Local oStr3:= FWFormStruct(2, 'CT2')
Local cTabOri:= ""
Local coView := ""
Local nRecDes:= 0
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( 'CTBC662' )
Local oView

//RETIRADO OS CAMPOS DE OUTRAS MOEDAS POIS RASTREIO EH SEMPRE NA MOEDA 1 
//PARA VISUALIZAR AS OUTRAS MOEDAS PRESSIONAR OUTRAS ACOES - VISUALIZAR Q CHAMA CTBA101
oStr3:RemoveField('CT2_VALR02')
oStr3:RemoveField('CT2_VALR03')
oStr3:RemoveField('CT2_VALR04')
oStr3:RemoveField('CT2_VALR05')

oView := FWFormView():New()

oView:SetModel(oModel)
If lIsRussia 
	If SubStr(aCpoOri[1],1,3)=="F3B"
		oStr1:RemoveField("F3B_BOOKEY")
	ElseIf SubStr(aCpoOri[1],1,3)=="F3D"
		oStr1:RemoveField("F3D_WRIKEY")
	ElseIf SubStr(aCpoOri[1],1,3)=="F52"
		oStr1:RemoveField("F52_RESKEY")
	EndIf
EndIf	
oView:AddField('DOCORIV' , oStr1,'DOCORI' )
oView:AddGrid('LCTCT2V'  , oStr3,'LCTCT2')

coView := oView:AVIEWS[2][1]

oView:AddUserButton(STR0011, 'FORM', {|oView| ConLCT(coView,oModel) } ) // "Visualizar" 
If !lIsRussia
	oView:AddUserButton(STR0012, 'FORM', {|oView| CTBR662(aCpoOri,__aDocOri,__aLanCT2) } ) // "Imprimir"
EndIf

oView:CreateHorizontalBox( 'BOXFORM1', 20)
oView:CreateHorizontalBox( 'BOXFORM3', 80)
                   
oView:CreateVerticalBox( 'EMCIMADIR',100, 'BOXFORM1' ) 
 
oView:SetOwnerView('DOCORIV','BOXFORM1')
oView:SetOwnerView('DOCORIV','EMCIMADIR')
oView:SetOwnerView('LCTCT2V','BOXFORM3')

If !lIsRussia
	oView:EnableTitleView('DOCORIV' , STR0009 )				//'Documento'
	oView:EnableTitleView('LCTCT2V' , STR0010 )			//'Lançamentos'
Else
	If FindFunction("CTBC662PRT")
		oView:AddUserButton(STR0014, "", {|| CTBC662PRT() })// "Print FA Accounting Enteries"
	Endif
	oView:SetViewProperty("LCTCT2V", "GRIDFILTER",{.T.}) 
	oView:SetViewProperty("LCTCT2V", "GRIDSEEK", {.T.})
EndIf
oView:SetViewProperty('LCTCT2V' , 'GRIDVSCROLL', {lIsRussia} )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSCab()
Retorna estrutura do tipo FWformModelStruct.

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static function MontaSCab(cAliasTMP)
   	Local oStruct := FWFormStruct( 1,cAliasTMP, /*bAvalCampo*/, /*lViewUsado*/ )
	Local nX := 0	
	oStruct:AddTable('DOCORIG',aCpoOri,STR0009)//'Documento"
	For nX:=1 to Len(aCpoOri)
			//AddField(< cTitulo >          , < cTooltip >        , < cIdField >, < cTipo >            ,< nTamanho >          , [ nDecimal ]        , [ bValid ], [ bWhen ], [ aValues ], [ lObrigat ], [ bInit ], < lKey >, [ lNoUpd ], [ lVirtual ], [ cValid ])-> NIL		
		oStruct:AddField(RetTitle(aCpoOri[nX]),RetTitle(aCpoOri[nX]), aCpoOri[nX], TamSx3(aCpoOri[nX])[3],TamSx3(aCpoOri[nX])[1],TamSx3(aCpoOri[nX])[2],            ,           ,              ,               ,           ,.T.        )
	Next nX
	
return oStruct                       
 

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaVCab()
Retorna estrutura do tipo FWFormViewStruct.

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------

static function MontaVCab()
	Local oStruct := FWFormViewStruct():New()
    Local nX:= 0                                       
	For nX:=1 to Len(aCpoOri)
			   //AddField(< cIdField >          , < cOrdem >     , < cTitulo >          , < cDescric >        ,< aHelp >,<cType>,<cPicture>                 , < bPictVar >, < cLookUp >, < lCanChange >, < cFolder >, < cGroup >, [ aComboValues ], [ nMaxLenCombo ], < cIniBrow >, < lVirtual >, < cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL
		oStruct:AddField( aCpoOri[nX]            ,alltrim(str(nX)),RetTitle(aCpoOri[nX]) , RetTitle(aCpoOri[nX]),          ,'Get'  ,/*pesqpict(aCpoOri[nX])*/  ,                ,		       ,.F.              )
	Next nX

return oStruct
       

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaORI(oModel)
 Carga da Tabela Origem na AddField do Model

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CargaORI(oModel)
		
Return __aDocOri


//-------------------------------------------------------------------
/*/{Protheus.doc} ConLCT()
Abre a Consulta do regitro Original pelo do Lançamento Contábil

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ConLCT(coView,oModel)

Local nOpcX	 := 2
Local aArea := GetArea() 
Local cTabDes:= "CT2"
Local oSubDetail := oModel:GetModel('LCTCT2')
Local nLin := oSubDetail:GetLine()

If coView == "LCTCT2V"
	nRecDes:= VAL(oModel:GetValue('LCTCT2',"R_E_C_N_O_" ))
	(cTabDes)->(DbGoto(nRecDes))
	CTBA101(nOpcX,nRecDes,cTabDes)
	oSubDetail:SetLine(nLin)
	
EndIf
RestArea(aArea)

Return .F.
	

//-------------------------------------------------------------------
/*/{Protheus.doc} CargaLCTO(oModel)
Carga do Lançamento Contábil

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CargaLCTO(oModel)

Local aCpyCT2 := Aclone(__aLanCT2)
	
Return aCpyCT2
	
	
	
	
/*/{Protheus.doc} CargaCTL(__cLP)
Carga do Lançamento Padrão, pega os campos a exibir na AddField

@author wilson.possani

@since 02/04/2014
@version 1.0
/*/

Static Function CargaCTL(__cLP,cTabOri)	
	Local aArea	:= {}
	
	aArea := GetArea()
	//procura o LP na CTL e Adicionar campos do CTL_KEY para mostrar na tela de Documento Original no MVC
	dbSelectArea("CTL")
	dbSetOrder(1)
	If CTL->(dbSeek(xFilial("CTL")+__cLP))
		If CTL->(CTL_ALIAS) == cTabOri 
			cCpoOri:= ALLTRIM(CTL_KEY)
		Else
			cCpoOri := Alltrim((cTabOri)->(IndexKey(1)))
		Endif
	Else
		cCpoOri := Alltrim((cTabOri)->(IndexKey(1)))
	Endif
	cCpoOri:= Replace(cCpoOri,'DTOS', '')
	cCpoOri:= Replace(cCpoOri,'(', '')
	cCpoOri:= Replace(cCpoOri,')', '')
	if cPaisLoc = "RUS"
		cCpoOri:= Replace(cCpoOri,' ', '')
	Endif
	cCpoOri:= '{"' +Replace(cCpoOri,'+','","')+  '"}'
	aCpoOri :=&(cCpoOri)
	CargaINI() // Carrega os Dados
	RestArea(aArea)
	Asize(aArea,0)
	aArea := Nil
Return



