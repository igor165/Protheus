#Include "Protheus.Ch"
#Include "Matr947.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR947   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³10.05.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³MAPA DE PRODUTOS CONTROLADOS - POLICIA CIVIL                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Matr947()
	Matr947R3()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Matr947R3 ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 13.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³MAPA DE PRODUTOS CONTROLADOS - POLICIA CIVIL - RELEASE 3    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Matr947R3()

Local cString	:=	""
Local cPerg		:= 	"MTR947"
Local cTitulo  	:= OemToAnsi(STR0003)	//"MOVIMENTO GERAL (ANEXO I)"
Local cDesc1  	:= OemToAnsi(STR0004)	//"Relatorio de movimentacoes de Produtos Controlados"
Local cCpoB5	:= GetNewPar("MV_MTR947A","")	//Produto Controlado 
Local aDelArqs	:= {}

Private wnrel 	:= "MATR947"
Private cTam	:= "G"	 	// P/M/G
Private Limite	:= 220  	// 80/132/220
Private lEnd 	:= .F.		// Controle de cancelamento do relatorio
Private m_pag  	:= 1  		// Contador de Paginas
Private aReturn	:= {OemToAnsi(STR0001),1,OemToAnsi(STR0002),2,2,1,"",1}	//"Zebrado"###"Administracao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao de campo                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cCpoB5) 
	xMagHelpFis(OemToAnsi(STR0071),OemToAnsi(STR0072),OemToAnsi(STR0073))
	Return Nil
Endif	

Pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,wnRel,cPerg,cTitulo,cDesc1,,,.F.,,.F.,cTam)

If (nLastKey==27)
	dbClearFilter()
	Return Nil
Endif
SetDefault (aReturn, cString)
If (nLastKey==27)
	dbClearFilter()
	Return Nil
Endif

RptStatus({|lEnd| ProcRel(lEnd,cTam,.T.,@aDelArqs)},cTitulo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Excluindo temporarios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M947DelArq(aDelArqs)

If (aReturn[5]==1)
	Set Printer To 	
   	ourspool(wnrel)
Endif
MS_FLUSH()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRel   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 13.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa o relatorio                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRel(lEnd,cTam,lPrint,aDelArqs)

Local lQuery	:= .F.
Local cQuery	:= ""
Local cAliasSD1	:= "SD1"
Local cAliasSD2	:= "SD2"
Local cAliasSD3	:= "SD3"
Local cAliasSB1	:= "SB1"
Local cAliasSB5	:= "SB5"
Local nX		:= 0 
Local aStru		:= {}
Local cIndex	:= ""
Local nIndex	:= 0
Local cProduto	:= mv_par01
Local dDtIni	:= mv_par02
Local dDtFim	:= mv_par03
Local cEmp		:= ""
Local cEnd		:= ""
Local cMun		:= ""
Local cUF		:= ""
Local cBairro	:= ""  
Local cDDD		:= ""
Local cNome		:= ""
Local cTel		:= ""
Local cCpoB5	:= GetNewPar("MV_MTR947A","")	//Produto Controlado 
Local lGrava	:= .T.
Local nEstqAnt	:= 0
Local nEstqAtu  := 0	
Local nProduz 	:= 0
Local nUtiliza 	:= 0       
Local cTipo		:= ""      
Local cOrdem	:= ""     
Local aCampos	:= {}
Local cCmpQry	:= ""
Local cTransp	:= "" 
Local cNomTran  := ""
Local cEndTran  := ""
Local cCepTran  := ""
Local cCidTran  := ""
Local cUfTran   := ""
Local cTelTran  := ""
Local cCep      := ""

Default lPrint	:= .T.
Default lEnd	:= .F.
Default cTam	:= "G"

#IFDEF TOP
	If TcSrvType()<>"AS/400"
		lQuery := .T.
	Endif
#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temporarios                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aDelArqs := GeraTemp()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o estoque de todos os produtos controlados.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mtr947Est(1,dDtIni,dDtFim,cProduto)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Entradas                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("SD1")
dbSetOrder(1)

dbSelectArea("SA2")
dbSetOrder(1)
If lQuery
	cAliasSD1	:= "TopSD1"
	aStru		:= SD1->(dbStruct())
	cQuery 		:= "SELECT SD1.D1_COD, SD1.D1_LOCAL, SD1.D1_QUANT, SD1.D1_DTDIGIT, SD1.D1_DOC, SD1.D1_SERIE, "
	cQuery 		+= "SD1.D1_FORNECE, SD1.D1_LOJA, SD1.D1_TIPO, SD1.R_E_C_N_O_ "
	cQuery 		+= "FROM "+RetSqlName("SD1")+" SD1 "
	cQuery 		+= "LEFT JOIN " +RetSqlName("SC2") +" SC2 ON  "
	cQuery 		+= " SC2.D_E_L_E_T_=' ' AND "
	cQuery 		+= " SC2.C2_FILIAL='"+xFilial("SC2")+"' AND "
	cQuery 		+= " SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD=SD1.D1_OP "
	cQuery 		+= " ,"+RetSqlName("SB5")+" SB5,"+RetSqlName("SF4")+" SF4 "
	cQuery 		+= "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
	cQuery 		+= "SD1.D1_DTDIGIT>='"+Dtos(dDtIni)+"' AND "
	cQuery 		+= "SD1.D1_DTDIGIT<='"+Dtos(dDtFim)+"' AND "
	cQuery 		+= "SD1.D1_CF NOT IN('000','999','0000','9999') AND "

	If !Empty(cProduto)
		cQuery += "SD1.D1_COD='"+cProduto+"' AND "
	Endif	

	cQuery 		+= "SD1.D_E_L_E_T_=' ' AND "
	cQuery 		+= "B5_FILIAL='"+xFilial("SB5")+"' AND "
	cQuery 		+= "SB5.B5_COD=SD1.D1_COD AND "	
	cQuery 		+= "SB5."+(cCpoB5)+"='S' AND "		
	cQuery 		+= "SB5.D_E_L_E_T_ = ' ' AND "	
	
	cQuery 		+= "F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery 		+= "SF4.F4_CODIGO=SD1.D1_TES AND "	
	cQuery 		+= "SF4.F4_ESTOQUE = 'S' AND "		
	cQuery 		+= "SF4.D_E_L_E_T_=' '  AND "	
	
	//-- Filtro para não listar os retornos simbólicos de remessa para industrialização
	cQuery 		+= "(SD1.D1_OP = ' ' OR SC2.C2_TPPR <> 'E' OR SF4.F4_PODER3 <> 'D') "

	cQuery 		+= "UNION "

	//-- Query para listar produção externa como entrada por nota (aquisição do serviço de beneficiamento)
	cQuery 		+= "SELECT SD3.D3_COD D1_COD, SD3.D3_LOCAL D1_LOCAL, SD3.D3_QUANT D1_QUANT, SD3.D3_EMISSAO D1_DTDIGIT, SF1.F1_DOC D1_DOC, SF1.F1_SERIE D1_SERIE, "
	cQuery 		+= "SF1.F1_FORNECE D1_FORNECE, SF1.F1_LOJA D1_LOJA, SF1.F1_TIPO D1_TIPO, SD3.R_E_C_N_O_ "
	cQuery 		+= "FROM "+RetSqlName("SD3")+" SD3,"+RetSqlName("SB5")+" SB5,"+RetSqlName("SC2")+" SC2,"+RetSqlName("SF1")+" SF1 "
	cQuery 		+= "WHERE D3_FILIAL='"+xFilial("SD3")+"' AND "
	cQuery 		+= "SD3.D3_EMISSAO>='"+Dtos(dDtIni)+"' AND "
	cQuery 		+= "SD3.D3_EMISSAO<='"+Dtos(dDtFim)+"' AND "
	cQuery 		+= "SD3.D3_CF ='PR0' AND "
	cQuery 		+= "SD3.D3_CHAVEF1 <> ' ' AND "

	If !Empty(cProduto)
		cQuery += "SD3.D3_COD='"+cProduto+"' AND "
	Endif

	cQuery 		+= "SD3.D_E_L_E_T_=' ' AND "
	cQuery 		+= "B5_FILIAL='"+xFilial("SB5")+"' AND "
	cQuery 		+= "SB5.B5_COD=SD3.D3_COD AND "	
	cQuery 		+= "SB5."+(cCpoB5)+"='S' AND "		
	cQuery 		+= "SB5.D_E_L_E_T_ = ' ' AND "	
	
	cQuery 		+= "SC2.D_E_L_E_T_=' ' AND "
	cQuery 		+= "C2_FILIAL='"+xFilial("SC2")+"' AND "
	cQuery 		+= "SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD=SD3.D3_OP AND "	
	cQuery 		+= "SC2.C2_TPPR = 'E' AND "

	cQuery 		+= "SF1.D_E_L_E_T_=' ' AND "
	cQuery 		+= "F1_FILIAL='"+xFilial("SF1")+"' AND "
	cQuery 		+= "SF1.F1_FILIAL||SF1.F1_DOC||SF1.F1_SERIE||SF1.F1_FORNECE||SF1.F1_LOJA=SD3.D3_CHAVEF1
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
	
		
	For nX := 1 To len(aStru)
		If aStru[nX][2] <> "C" 
			TcSetField(cAliasSD1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
Else
    cIndex	:= CriaTrab(NIL,.F.)
	cQuery 	:= "D1_FILIAL=='"+xFilial("SD1")+"' .AND. "
	cQuery 	+= "Dtos(D1_DTDIGIT)>='"+Dtos(dDtIni)+"' .AND. "
	cQuery 	+= "Dtos(D1_DTDIGIT)<='"+Dtos(dDtFim)+"' .AND. "

	If !Empty(cProduto)
		cQuery += "D1_COD=='"+cProduto+"' .AND. "
	Endif	

	cQuery 	+= "!(D1_CF$'000/999/0000/9999') "

    IndRegua(cAliasSD1,cIndex,SD1->(IndexKey()),,cQuery)
    nIndex := RetIndex("SD1")
	dbSetIndex(cIndex+OrdBagExt())
	dbSelectArea("SD1")
    dbSetOrder(nIndex+1)
EndIf

SF4->(dbSetOrder(1))
dbSelectArea(cAliasSD1)
dbGoTop()     
While !Eof()
cNomTran  := ""
cEndTran  := ""
cCepTran  := ""
cCidTran  := ""
cUfTran   := ""
cTelTran  := ""
cTransp	  := "" 

	If Interrupcao(@lEnd)
		Return Nil
	Endif
   	
		If !lQuery
		lGrava := (Posicione("SB5",1,xFilial("SB5")+(cAliasSD1)->D1_COD,SB5->(cCpoB5))=="S")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o TES do movimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		If !(SF4->(MsSeek(xFilial("SF4")+(cAliasSD1)->D1_TES)))
			(cAliasSD1)->(DbSkip())
			Loop
		Endif              
		If SF4->F4_ESTOQUE <> "S"
			(cAliasSD1)->(DbSkip())
			Loop
		Endif
	Endif

	If lGrava
		If (cAliasSD1)->D1_TIPO$"D/B"
			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
				cEmp	:= SA1->A1_NOME
				cEnd	:= SA1->A1_END
				cMun	:= SA1->A1_MUN
				cUF		:= SA1->A1_EST
				cCEP    := SA1->A1_CEP
				cFone   := SA1->A1_TEL
				cBairro := SA1->A1_BAIRRO
				cDDD	:= SA1->A1_DDD
				cTel	:= SA1->A1_TEL
				cNome	:= SA1->A1_NREDUZ
			Endif
		Else
			dbSelectArea("SA2")
			dbSetOrder(1)
			If dbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
				cEmp	:= SA2->A2_NOME
				cEnd	:= SA2->A2_END
				cMun	:= SA2->A2_MUN
				cUF		:= SA2->A2_EST
				cCEP    := SA2->A2_CEP
				cFone   := SA2->A2_TEL 
				cBairro := SA2->A2_BAIRRO 
				cDDD	:= SA2->A2_DDD
				cTel	:= SA2->A2_TEL
				cNome	:= SA2->A2_NREDUZ
			Endif
		Endif
	  	  	
			dbSelectArea("SF1")
			dbSetOrder(1)
			If dbSeek(xFilial("SF1")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)	
   				cTransp	:= &(GetNewPar("MV_TRANSF1",""))
   			EndIf
   			
			If !Empty(cTransp)	
				dbSelectArea("SA4")
		 	    dbSetOrder(1)
				If dbSeek(xFilial("SA4") + cTransp)
					cNomTran  := SA4->A4_NREDUZ
					cEndTran  := SA4->A4_END
					cCepTran  := SA4->A4_CEP
					cCidTran  := SA4->A4_MUN
					cUfTran   := SA4->A4_EST 
					cTelTran  := SA4->A4_TEL  
	        	EndIf
	        Else 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Localiza se nota de entrada tem um conhecimento de Frete.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	            dbSelectArea("SF8")   //zatt
				dbSetOrder(2)
	            If dbSeek(xFilial("SF8")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
	            	dbSelectArea("SA2")
					dbSetOrder(1)
					If dbSeek(xFilial("SA2")+SF8->F8_TRANSP+SF8->F8_LOJTRAN)
						cNomTran  := SA2->A2_NREDUZ
						cEndTran  := SA2->A2_END
						cCepTran  := SA2->A2_CEP
						cCidTran  := SA2->A2_MUN
						cUfTran   := SA2->A2_EST
						cTelTran  := SA2->A2_TEL  
					Endif	  
	            Else
		        	dbSelectArea("SA2")
					dbSetOrder(1)
					If dbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA) 
						dbSelectArea("SA4")
			 	    	dbSetOrder(1)
			    		If dbSeek(xFilial("SA4") + SA2->A2_TRANSP)
							cNomTran  := SA4->A4_NREDUZ
							cEndTran  := SA4->A4_END
							cCepTran  := SA4->A4_CEP
							cCidTran  := SA4->A4_MUN
							cUfTran   := SA4->A4_EST 
							cTelTran  := SA4->A4_TEL  
		        		EndIf	
		        	EndIf
		    	EndIf
		    EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ T01 - Sintetico                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("T01")
		dbSetOrder(1)
		If !dbSeek((cAliasSD1)->D1_COD)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o saldo anterior dos produtos de acordo com as movimentacoes de estoque.         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEstqAnt := 0
			If ANT->(dbSeek((cAliasSD1)->D1_COD)) 
				nEstqAnt := ANT->QUANT
			Endif 
			
			RecLock("T01",.T.)
			T01->CODPROD	:= (cAliasSD1)->D1_COD
			T01->DESCPROD	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_DESC")
			T01->SLDANT		:= nEstqAnt
			T01->UM         := Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_UM")
		Else
			RecLock("T01",.F.)
		Endif
		T01->COMPRAS	+= (cAliasSD1)->D1_QUANT
		MsUnlock()					
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ T02 - Analitico  COMPRAS         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("T02")
		dbSetOrder(1)
		If (cAliasSD1)->D1_TIPO <> "C"
			If !dbSeek((cAliasSD1)->D1_COD+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
				RecLock("T02",.T.)
				T02->CODPROD	:= (cAliasSD1)->D1_COD
				T02->EMISSAO	:= (cAliasSD1)->D1_DTDIGIT
				T02->EMPRESA	:= cEmp
				T02->ENDE		:= cEnd
				T02->MUN		:= cMun
				T02->UF			:= cUF
				T02->NF			:= (cAliasSD1)->D1_DOC
				T02->SERIE		:= (cAliasSD1)->D1_SERIE
				T02->CLIEFOR	:= (cAliasSD1)->D1_FORNECE
				T02->LOJA		:= (cAliasSD1)->D1_LOJA
				T02->UM         := Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_UM")
				T02->CEP		:= cCEP
				T02->FONE		:= cFone
				T02->NTRANSP    := cNomTran
				T02->ENDTRAN    := cEndTran
				T02->CEPTRAN    := cCepTran
				T02->MUNTRAN    := cCidTran
				T02->ESTTRAN    := cUfTran
				T02->TELTRAN	:= cTelTran		
			Else
				RecLock("T02",.F.)
			Endif
				T02->QUANT += (cAliasSD1)->D1_QUANT
			MsUnlock()
		EndIf
		
		dbSelectArea("T05")
		dbSetOrder(1)
		If !dbSeek((cAliasSD1)->D1_COD+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
			RecLock("T05",.T.)
			T05->CODPROD	:= (cAliasSD1)->D1_COD
			T05->DESCPROD	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_DESC")
			T05->SLDANT		:= nEstqAnt
			T05->UM		    := Posicione("SB1",1,xFilial("SB1")+(cAliasSD1)->D1_COD,"B1_UM")
			T05->BAIRRO		:= cBairro   
			T05->CEP		:= cCEP
			T05->NREDUZ		:= cNome
			T05->ENDE		:= cEnd
			T05->MUN		:= cMun
			T05->UF			:= cUF
		Else
			RecLock("T02",.F.)
		Endif		
	Endif
	dbSelectArea(cAliasSD1)
	dbSkip()
Enddo

If lQuery
	dbSelectArea(cAliasSD1)
	dbCloseArea()
Else
  	dbSelectArea("SD1")
	RetIndex("SD1")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Saidas                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SD2")
dbSetOrder(1)
If lQuery
	cAliasSD2	:= "TopSD2"
	aStru		:= SD2->(dbStruct())
	cQuery 		:= "SELECT SD2.D2_COD, SD2.D2_LOCAL, SD2.D2_QUANT, SD2.D2_EMISSAO, SD2.D2_DOC, SD2.D2_SERIE, "
	cQuery 		+= "SD2.D2_CLIENTE, SD2.D2_LOJA, SD2.D2_TIPO "
	cQuery 		+= "FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SB5")+" SB5,"+RetSqlName("SF4")+" SF4 "
	cQuery 		+= "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
	cQuery 		+= "SD2.D2_EMISSAO>='"+Dtos(dDtIni)+"' AND "
	cQuery 		+= "SD2.D2_EMISSAO<='"+Dtos(dDtFim)+"' AND "
	cQuery 		+= "SD2.D2_CF NOT IN('000','999','0000','9999') AND "

	If !Empty(cProduto)
		cQuery += "SD2.D2_COD='"+cProduto+"' AND "
	Endif	
	
	cQuery 		+= "SD2.D_E_L_E_T_ = ' ' AND "
	cQuery 		+= "B5_FILIAL='"+xFilial("SB5")+"' AND "
	cQuery 		+= "SB5.B5_COD=SD2.D2_COD AND "	
	cQuery 		+= "SB5."+(cCpoB5)+"='S' AND "		
	cQuery 		+= "SB5.D_E_L_E_T_ = ' ' AND "	

	cQuery 		+= "F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery 		+= "SF4.F4_CODIGO=SD2.D2_TES AND "	
	cQuery 		+= "SF4.F4_ESTOQUE = 'S' AND "		
	cQuery 		+= "SF4.D_E_L_E_T_=' ' "	

	cQuery 		+= "ORDER BY "+SqlOrder(SD2->(IndexKey()))
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		
	For nX := 1 To len(aStru)
		If aStru[nX][2] <> "C" 
			TcSetField(cAliasSD2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX
Else
    cIndex	:= CriaTrab(NIL,.F.)
	cQuery 	:= "D2_FILIAL=='"+xFilial("SD2")+"' .AND. "
	cQuery 	+= "Dtos(D2_EMISSAO)>='"+Dtos(dDtIni)+"' .AND. "
	cQuery 	+= "Dtos(D2_EMISSAO)<='"+Dtos(dDtFim)+"' .AND. "

	If !Empty(cProduto)
		cQuery += "D2_COD=='"+cProduto+"' .AND. "
	Endif	

	cQuery 	+= "!(D2_CF$'000/999/0000/9999') "

    IndRegua(cAliasSD2,cIndex,SD2->(IndexKey()),,cQuery)
    nIndex := RetIndex("SD2")
	dbSetIndex(cIndex+OrdBagExt())
	dbSelectArea("SD2")
    dbSetOrder(nIndex+1)
EndIf

dbSelectArea(cAliasSD2)
dbGoTop()
While !Eof()
	If Interrupcao(@lEnd)
		Return Nil
	Endif
	
	If !lQuery
		lGrava := (Posicione("SB5",1,xFilial("SB5")+(cAliasSD2)->D2_COD,cCpoB5)=="S")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Posiciona o TES do movimento³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SF4->(dbSetOrder(1))
		If !(SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)))
			(cAliasSD2)->(DbSkip())
			Loop
		Endif              
		If SF4->F4_ESTOQUE <> "S"
			(cAliasSD2)->(DbSkip())
			Loop
		Endif
	Endif

	If lGrava
		If (cAliasSD2)->D2_TIPO$"D/B"
			dbSelectArea("SA2")
			dbSetOrder(1)
			If dbSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
				cEmp	:= SA2->A2_NOME
				cEnd	:= SA2->A2_END
				cMun	:= SA2->A2_MUN
				cUF		:= SA2->A2_EST
				cNome   := SA2->A2_NREDUZ
				cCEP    := SA2->A2_CEP
				cBairro := SA2->A2_BAIRRO
				cDDD	:= SA2->A2_DDD
				cTel	:= SA2->A2_TEL
			Endif
		Else
			dbSelectArea("SA1")
			dbSetOrder(1)
			If dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
				cEmp	:= SA1->A1_NOME
				cEnd	:= SA1->A1_END
				cMun	:= SA1->A1_MUN
				cUF		:= SA1->A1_EST 
				cBairro := SA1->A1_BAIRRO 
				cCEP	:= SA1->A1_CEP
				cDDD	:= SA1->A1_DDD
				cTel	:= SA1->A1_TEL
				cNome	:= SA1->A1_NREDUZ
			Endif
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ T01 - Sintetico                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("T01")
		dbSetOrder(1)
		If !dbSeek((cAliasSD2)->D2_COD)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o saldo anterior dos produtos de acordo com as movimentacoes de estoque.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEstqAnt := 0
			If ANT->(dbSeek((cAliasSD2)->D2_COD)) 
				nEstqAnt := ANT->QUANT
			Endif 

			RecLock("T01",.T.)
			T01->CODPROD	:= (cAliasSD2)->D2_COD
			T01->DESCPROD	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSD2)->D2_COD,"B1_DESC")
			T01->SLDANT		:= nEstqAnt
			T01->UM		    := Posicione("SB1",1,xFilial("SB1")+(cAliasSD2)->D2_COD,"B1_UM")
		Else	
			RecLock("T01",.F.)
		Endif
		T01->VENDAS	+= (cAliasSD2)->D2_QUANT
		MsUnlock()		

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ T03 - Analitico  VENDAS          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("T03")
			dbSetOrder(1)
			If !dbSeek((cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
				RecLock("T03",.T.)
				T03->QUANT		:= (cAliasSD2)->D2_QUANT
				T03->CODPROD	:= (cAliasSD2)->D2_COD
				T03->DOC		:= (cAliasSD2)->D2_DOC
				T03->DESCPROD	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSD2)->D2_COD,"B1_DESC")
				T03->EMISSAO	:= (cAliasSD2)->D2_EMISSAO
				T03->EMPRESA	:= cEmp
				T03->ENDE		:= cEnd
				T03->MUN		:= cMun
				T03->UF			:= cUF
				T03->NF			:= (cAliasSD2)->D2_DOC
				T03->SERIE		:= (cAliasSD2)->D2_SERIE
				T03->CLIEFOR	:= (cAliasSD2)->D2_CLIENTE
				T03->LOJA		:= (cAliasSD2)->D2_LOJA
				T03->UM		    := Posicione("SB1",1,xFilial("SB1")+(cAliasSD2)->D2_COD,"B1_UM")
				T03->BAIRRO		:= cBairro   
				T03->CEP		:= cCEP
				T03->TEL		:= cTel
				T03->DDD		:= cDDD
				T03->NREDUZ		:= cNome
			Else
				RecLock("T03",.F.)
			Endif
			MsUnlock()		 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ T04 - Analitico  VENDAS          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("T04")
		dbSetOrder(1)
		If !dbSeek((cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			RecLock("T04",.T.)
			T04->CODPROD	:= (cAliasSD2)->D2_COD
			T04->DESCPROD	:= Posicione("SB1",1,xFilial("SB1")+(cAliasSD2)->D2_COD,"B1_DESC")
			T04->SLDANT		:= nEstqAnt
			T04->UM		    := Posicione("SB1",1,xFilial("SB1")+(cAliasSD2)->D2_COD,"B1_UM")
			T04->BAIRRO		:= cBairro   
			T04->CEP		:= cCEP
			T04->NREDUZ		:= cNome
			T04->ENDE		:= cEnd
			T04->MUN		:= cMun
			T04->UF			:= cUF
		Else
			RecLock("T04",.F.)
		Endif
		MsUnlock()		
	Endif
	dbSelectArea(cAliasSD2)
	dbSkip()
Enddo

If lQuery
	dbSelectArea(cAliasSD2)
	dbCloseArea()
Else
  	dbSelectArea("SD2")
	RetIndex("SD2")
	dbClearFilter()
	Ferase(cIndex+OrdBagExt())
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa os movimentos de Producao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP

    If TcSrvType()<>"AS/400"

		lQuery 		:= .T.
		aStruSD3	:= {}
		cAliasSD3	:= GetNextAlias()   
		cAliasSB1	:= cAliasSD3
		cAliasSB5	:= cAliasSD3
		cCmpQry		:= ""
					
	    aAdd(aCampos,{"SD3","D3_FILIAL"})
		aAdd(aCampos,{"SD3","D3_OP"})
   	    aAdd(aCampos,{"SD3","D3_EMISSAO"})
   	    aAdd(aCampos,{"SD3","D3_COD"})
		aAdd(aCampos,{"SD3","D3_LOCAL"})
   	    aAdd(aCampos,{"SD3","D3_QUANT"})
   	    aAdd(aCampos,{"SD3","D3_CF"})
   	    aAdd(aCampos,{"SB1","B1_DESC"})
   	    
    	aStruSD3  := Mtr947Str(aCampos,@cCmpQry)

		cQuery	:= "SELECT DISTINCT"
		cQuery	+= cCmpQry
		cQuery  += ",SD3.R_E_C_N_O_ "
		cQuery	+= "FROM " + RetSqlName("SD3") + " SD3 "
		cQuery	+= "INNER JOIN " + RetSqlName("SD3") + " SD3DEST "
		cQuery	+= "ON SD3.D3_NUMSEQ = SD3DEST.D3_NUMSEQ "
		cQuery	+= "INNER JOIN " + RetSqlName("SB1") + " SB1 " 
		cQuery	+= "ON SD3.D3_COD = SB1.B1_COD "
		cQuery	+= "INNER JOIN " + RetSqlName("SB5") + " SB5 "
		cQuery	+= "ON SB1.B1_COD = SB5.B5_COD "
		cQuery	+= "LEFT JOIN " + RetSqlName("SC2") + " SC2 "
		cQuery	+= "ON SC2.D_E_L_E_T_ = ' ' AND SC2.C2_FILIAL = '" +xFilial("SC2") +"' AND "
		cQuery	+= "SC2.C2_NUM||SC2.C2_ITEM||SC2.C2_SEQUEN||SC2.C2_ITEMGRD = SD3.D3_OP "
		cQuery  += "WHERE (SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND "
		cQuery  += "SD3.D3_EMISSAO >= '" + dtOs(dDtIni) + "' AND "
		cQuery  += "SD3.D3_EMISSAO <= '" + dtOs(dDtFim) + "' AND "
		If !Empty(cProduto)
			cQuery	+= "SD3.D3_COD = '" + cProduto + "' AND "
		Endif
		cQuery	+= "SD3.D3_ESTORNO <> 'S' AND "
		cQuery	+= "SD3.D_E_L_E_T_ = '' AND "
		cQuery	+= "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
		cQuery	+= "SD3.D3_COD = SB1.B1_COD AND "
		cQuery	+= "SB1.D_E_L_E_T_ = '' AND "
		cQuery	+= "SB5.B5_FILIAL = '" + xFilial("SB5") + "' AND "		
		cQuery	+= "SB5.B5_COD = SB1.B1_COD "
		If !Empty(cCpoB5) 
			cQuery	+= "AND SB5." + Alltrim(cCpoB5) + " = 'S' "       
		Endif
		cQuery	+= "AND SB5.D_E_L_E_T_ = '') "
		cQuery	+= "AND ((SD3.D3_COD != SD3DEST.D3_COD AND "
		cQuery	+= "SD3.D3_CF IN ('DE4','RE4')) "
		cQuery	+= "OR SD3.D3_CF IN ('PR0', 'PR1', 'ER0', 'ER1', 'DE0', 'DE1', 'DE2', 'DE3', 'DE5', 'RE0', 'RE1', 'RE2', 'RE3', 'RE5')) AND "
		//-- Não lista movimentos de produção externa
		cQuery	+= "COALESCE(SC2.C2_TPPR,' ') <> 'E'
		cQuery	+= "ORDER BY SD3.D3_FILIAL,SD3.D3_OP,SD3.D3_COD,SD3.D3_LOCAL"

	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3,.T.,.T.)
	
		For nX := 1 To len(aStruSD3)
			If aStruSD3[nX][2] <> "C" 
				TcSetField(cAliasSD3,aStruSD3[nX][1],aStruSD3[nX][2],aStruSD3[nX][3],aStruSD3[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSD3)

	Else
	                  
#ENDIF
		cArqInd		:=	CriaTrab(Nil,.F.)
		cChave		:=	"D3_OP+D3_COD+D3_LOCAL"
		cCondicao 	:= 'D3_FILIAL == "' + xFilial("SD3") + '" .And. ' 
		cCondicao 	+= 'Dtos(D3_EMISSAO) >= "' + Dtos(dDtIni) + '" .And. Dtos(D3_EMISSAO) <= "' + Dtos(dDtFim) + '" .And. '
		If !Empty(cProduto) 
			cCondicao 	+= 'D3_COD = "' + cProduto + '" .And. '
		Endif
		cCondicao 	+= 'D3_ESTORNO <> "S" .And. '
		cCondicao 	+= 'D3_CF $ "PR0/PR1/ER0/ER1/DE0/DE1/DE2/DE3/DE5/RE0/RE1/RE2/RE3/RE5"'
		
		IndRegua(cAliasSD3,cArqInd,cChave,,cCondicao,"Selecionando Registros")  
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF                
		(cAliasSD3)->(dbGotop())
#IFDEF TOP
	Endif    
#ENDIF

Do While !((cAliasSD3)->(Eof()))

	If Interrupcao(@lEnd)
		Return Nil
	Endif

	If !lQuery

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Checa o grupo do produto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SB1->(dbSetOrder(1))
		If !(SB1->(MsSeek(xFilial("SB1")+(cAliasSD3)->D3_COD)))
			(cAliasSD3)->(DbSkip())
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Campos e consideracoes que deverao ser analisadas referentes ao SB5 de acordo com os parametros da rotina - CODEBASE³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// Verifica a existencia do SB5
		SB5->(dbSetOrder(1))
		If !SB5->(MsSeek(xFilial("SB5")+(cAliasSD3)->D3_COD))
			(cAliasSD3)->(DbSkip())
			Loop
		Endif
		// Indicacao de produto controlado ou nao			
		If !Empty(cCpoB5) 
			If SB5->&cCpoB5 <> "S"
				(cAliasSD3)->(DbSkip())
				Loop
			Endif
		Endif

	Endif

	nProduz 	:= 0
	nUtiliza 	:= 0
	nEstqAnt 	:= 0
	nEstqAtu 	:= 0
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Producao Manual e Automatica  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSD3)->D3_CF == "PR0" .Or. (cAliasSD3)->D3_CF == "PR1"
		nProduz	:= (cAliasSD3)->D3_QUANT
		cTipo 	:= "P" // Producao
		cOrdem	:= "2"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estorno de producao Manual e Automatico³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSD3)->D3_CF == "ER0" .Or. (cAliasSD3)->D3_CF == "ER1"
		nProduz -= (cAliasSD3)->D3_QUANT
		cTipo 	:= "EP" // Estorno de Producao
		cOrdem	:= "8"
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Requisicao Manual e Automatica³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSD3)->D3_CF $ "RE0/RE1/RE2/RE3/RE4/RE5"
		nUtiliza 	:= (cAliasSD3)->D3_QUANT
		cTipo 		:= "U" // Utilizacao
		cOrdem		:= "6"
    Endif    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Devolucao Manual e Automatica ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (cAliasSD3)->D3_CF $ "DE0/DE1/DE2/DE3/DE4/DE5"
		nUtiliza -= (cAliasSD3)->D3_QUANT
		cTipo 		:= "EU" // Estorno de Utilizacao
		cOrdem		:= "4"
    Endif    

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ T01 - Sintetico                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("T01")
	dbSetOrder(1)
	If !dbSeek((cAliasSD3)->D3_COD)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica o saldo anterior dos produtos de acordo com as movimentacoes de estoque.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   	nEstqAnt := 0
	   	If ANT->(dbSeek((cAliasSD3)->D3_COD))
			nEstqAnt := ANT->QUANT
		Endif 

		RecLock("T01",.T.)
		T01->CODPROD	:= (cAliasSD3)->D3_COD
		T01->DESCPROD	:= (cAliasSB1)->B1_DESC
		T01->SLDANT		:= nEstqAnt
		T01->UM		    := Posicione("SB1",1,xFilial("SB1")+(cAliasSD3)->D3_COD,"B1_UM")
	Else
		RecLock("T01",.F.)
	Endif
	T01->CONSUMO	+= nProduz
	T01->CONSUMO 	+= nUtiliza
	T01->CF       := (cAliasSD3)->D3_CF
	MsUnlock()		
    

	// ALTERAR SE FOR PRECISO -  CRIAR UMA TABELA PARA OS DADOS NECESSARIOS DO NOVO RELATORIO

    /*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ T02 - Analitico                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("T02")
	dbSetOrder(3)
	If !dbSeek((cAliasSD3)->D3_COD+dTos((cAliasSD3)->D3_EMISSAO)+cTipo)
		RecLock("T02",.T.)
		T02->CODPROD	:= (cAliasSD3)->D3_COD
		T02->EMISSAO	:= (cAliasSD3)->D3_EMISSAO
		T02->EMPRESA	:= SM0->M0_NOMECOM
		T02->ENDE		:= SM0->M0_ENDENT
		T02->MUN		:= SM0->M0_CIDENT
		T02->UF			:= SM0->M0_ESTENT
		T02->NF			:= "-"
		T02->UM		    := (cAliasSB1)->B1_UM
	Else
		RecLock("T02",.F.)
	Endif
	T02->QUANT += (cAliasSD3)->D3_QUANT
	MsUnlock()		
    */
    
	(cAliasSD3)->(dbSkip())
EndDo  

If !lQuery
	RetIndex("SD3")	
	dbClearFilter()	
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSD3)
	dbCloseArea()
Endif




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica os produtos em estoque, mas sem movimentacao no periodo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ATU->(dbGoTop())
Do While !ATU->(Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ T01 - Sintetico                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("T01")
	dbSetOrder(1)
	If !dbSeek(ATU->CODIGO)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura o saldo anterior³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nEstqAnt := 0
		If ANT->(dbSeek(ATU->CODIGO)) 
			nEstqAnt := ANT->QUANT
		Endif

		RecLock("T01",.T.)
		T01->CODPROD	:= ATU->CODIGO
		T01->DESCPROD	:= ATU->DESC_PRD
		T01->SLDANT		:= nEstqAnt

	Endif

	ATU->(dbSkip())
Enddo

If lPrint
	PrintRel()
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui os arquivo de estoque inicial/final.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Mtr947Est(2,dDtIni,dDtFim,cProduto)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PrintRel  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 13.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Imprime o relatorio                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintRel()

Local aL		 := Array(71)
Local nLin		 := 0
Local cTrimestre := mv_par04
Local cVistoria  := mv_par05
Local cAlvara    := mv_par06
Local cValidade	 := mv_par07
Local cTitulo	 := Upper(STR0003)//"MOVIMENTO GERAL (ANEXO I)"
Local dDtIni   	 := mv_par02
Local dDtFim	:= mv_par03
Local lMov 		:= .F.

Local cNome  := Alltrim(mv_par08)
Local cCargo := Alltrim(mv_par09)
Local cRg    := Alltrim(mv_par10)
Local cCompl := (cNome+" - "+cCargo+" - "+cRg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o LayOut                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LayOut(@aL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprimindo o Relatorio           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("T01")
dbSetOrder(1)
dbGoTop()

While !Eof()
	If Interrupcao(@lEnd)
		Return Nil
	Endif

	If nLin == 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin(,aL[01],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,cVistoria},aL[02],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[03],,,@nLin)
		FmtLin({SM0->M0_CIDENT,SM0->M0_BAIRENT,Transform(SM0->M0_CEPENT,"@R 99999-999")},aL[04],,,@nLin)				
		FmtLin({SM0->M0_TEL,cAlvara},aL[05],,,@nLin)				
		FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),Transform(SM0->M0_INSC,"@R 999.999.999.999"),Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[06],,,@nLin)
		FmtLin(,aL[07],,,@nLin)		
		FmtLin(,aL[08],,,@nLin)		
		FmtLin(,aL[09],,,@nLin)
		FmtLin(,aL[21],,,@nLin)
	Endif
	
		
	If nLin > 52
		nLin := 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin(,aL[01],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,cVistoria},aL[02],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[03],,,@nLin)
		FmtLin({SM0->M0_CIDENT,SM0->M0_BAIRENT,Transform(SM0->M0_CEPENT,"@R 99999-999")},aL[04],,,@nLin)				
		FmtLin({SM0->M0_TEL,cAlvara},aL[05],,,@nLin)				
		FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),Transform(SM0->M0_INSC,"@R 999.999.999.999"),Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[06],,,@nLin)
		FmtLin(,aL[07],,,@nLin)		
		FmtLin(,aL[08],,,@nLin)		
		FmtLin(,aL[09],,,@nLin)
		FmtLin(,aL[21],,,@nLin)
	Endif
	//PR0 - Produção manual. 
	//PR1 - Produção automática.
	If (T01->CF == "PR0" .Or. T01->CF == "PR1")
		FmtLin({SubStr(Alltrim(T01->CODPROD)+" - "+T01->DESCPROD,1,78),;
		Transform(T01->SLDANT,"@R 999,999,999,999.99"),;
		Transform(T01->COMPRAS,"@R 999,999,999,999.99"),;
		Transform(T01->SLDANT+T01->COMPRAS,"@R 999,999,999,999.99"),;
		Transform(T01->CONSUMO,"@R 999,999,999,999.99"),;	
		Transform(T01->VENDAS,"@R 999,999,999,999.99"),;
		Transform(T01->SLDANT+T01->COMPRAS-T01->VENDAS+T01->CONSUMO,"@R 999,999,999,999.99"),;
		T01->UM},;
		aL[10],,,@nLin)	
	Else	
		FmtLin({SubStr(Alltrim(T01->CODPROD)+" - "+T01->DESCPROD,1,78),;
		Transform(T01->SLDANT,"@R 999,999,999,999.99"),;
		Transform(T01->COMPRAS,"@R 999,999,999,999.99"),;
		Transform(T01->SLDANT+T01->COMPRAS,"@R 999,999,999,999.99"),;
		Transform(T01->CONSUMO,"@R 999,999,999,999.99"),;	
		Transform(T01->VENDAS,"@R 999,999,999,999.99"),;
		Transform(T01->SLDANT+T01->COMPRAS-T01->VENDAS-T01->CONSUMO,"@R 999,999,999,999.99"),;
		T01->UM},;
		aL[10],,,@nLin)	
 	Endif	
 	lMov := .T.
	dbSelectArea("T01")
	dbSkip()
Enddo

  //	If !lMov
  //	 	nLin := Cabec(cTitulo,"","","MATR947",cTam)
   //	 	++nLin                                  
	// 	FmtLin(,aL[01],,,@nLin)
	// 	FmtLin({SM0->M0_NOMECOM,cVistoria},aL[02],,,@nLin)
	 //	FmtLin({SM0->M0_ENDENT},aL[03],,,@nLin)
	 //	FmtLin({SM0->M0_CIDENT,SM0->M0_BAIRENT,Transform(SM0->M0_CEPENT,"@R 99999-999")},aL[04],,,@nLin)				
	// 	FmtLin({SM0->M0_TEL,cAlvara},aL[05],,,@nLin)				
	// 	FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),Transform(SM0->M0_INSC,"@R 999.999.999.999"),Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[06],,,@nLin)
	// 	FmtLin(,aL[07],,,@nLin)		
	 //	FmtLin(,aL[08],,,@nLin)		
	 //	FmtLin(,aL[09],,,@nLin)
	 //	FmtLin(,aL[21],,,@nLin)
   	 // 	FmtLin(,aL[70],,,@nLin)
  // 	EndIf
	FmtLin(,aL[63],,,@nLin)
	FmtLin(,aL[64],,,@nLin)		
	FmtLin(,aL[65],,,@nLin)		
	FmtLin(,aL[66],,,@nLin)		
	FmtLin(,aL[67],,,@nLin)	
	FmtLin({cCompl},aL[68],,,@nLin)		
	FmtLin(,aL[69],,,@nLin)
	FmtLin(,aL[63],,,@nLin)	

cTitulo	 := Upper(STR0026)//"MAPA TRIMESTRAL REFERENTE A COMPRAS (ANEXO II)"
nLin     := 0 
lMov	 := .F.
 
dbSelectArea("T02")
dbSetOrder(1)
dbGoTop()

While !Eof()
	If Interrupcao(@lEnd)
		Return Nil
	Endif

	If nLin == 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin({Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[22],,,@nLin)
		FmtLin({cAlvara},aL[23],,,@nLin)						
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aL[24],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[25],,,@nLin)
		++nLin
		FmtLin(,aL[12],,,@nLin)		
		FmtLin(,aL[13],,,@nLin)		
		FmtLin(,aL[14],,,@nLin)		
		FmtLin(,aL[15],,,@nLin)		
	Endif
	If nLin > 52
		nLin := 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin({Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[22],,,@nLin)
		FmtLin({cAlvara},aL[23],,,@nLin)						
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aL[24],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[25],,,@nLin)
		++nLin
		FmtLin(,aL[12],,,@nLin)		
		FmtLin(,aL[13],,,@nLin)		
		FmtLin(,aL[14],,,@nLin)		
		FmtLin(,aL[15],,,@nLin)		
	Endif
	
	FmtLin({CToD (StrZero (Day(T02->EMISSAO), 2)+"/"+StrZero (Month (T02->EMISSAO), 2)+"/"+StrZero (Year (T02->EMISSAO), 4)),T02->NF,Transform(T02->QUANT,"999999999999.99"),T02->UM,;
	SubStr(Alltrim(T02->CODPROD)+" - "+Posicione("SB1",1,xFilial("SB1")+T02->CODPROD,"B1_DESC"),1,55),;
	Substr(T02->EMPRESA,1,36),T02->NTRANSP,1,36},aL[16],,,@nLin)		              
	FmtLin({Substr(T02->ENDE,1,26),T02->CEP,Substr(T02->ENDTRAN,1,26),T02->CEPTRAN},aL[17],,,@nLin)
	FmtLin({T02->MUN,T02->UF,T02->MUNTRAN,T02->ESTTRAN},aL[18],,,@nLin)
	FmtLin({T02->FONE,T02->TELTRAN},aL[19],,,@nLin)
	
	lMov	 := .T.
	dbSelectArea("T02")
	dbSkip()
Enddo
    
    If !lMov
    	nLin := 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin
   		FmtLin({Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[22],,,@nLin)
		FmtLin({cAlvara},aL[23],,,@nLin)						
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aL[24],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[25],,,@nLin)
		++nLin
		FmtLin(,aL[12],,,@nLin)		
		FmtLin(,aL[13],,,@nLin)		
		FmtLin(,aL[14],,,@nLin)		
		FmtLin(,aL[15],,,@nLin)
		FmtLin(,aL[70],,,@nLin)
	EndiF
	 
    
	FmtLin(,aL[20],,,@nLin)
	++nLin
	FmtLin(,aL[33],,,@nLin)		
	FmtLin(,aL[34],,,@nLin)		
	FmtLin(,aL[35],,,@nLin)		
	FmtLin(,aL[36],,,@nLin)	
	FmtLin(,aL[37],,,@nLin)		
	FmtLin({cNome} ,aL[38],,,@nLin)		
	FmtLin({cCargo},aL[39],,,@nLin)	
	FmtLin({cRg}   ,aL[40],,,@nLin)  
	
	
	//ALTERAR DAQUI PARA BAIXO IMPRIMINDO O NOVO RELATORIO QUE FOR CRIADO

cTitulo	 := Upper(STR0051)//"MAPA TRIMESTRAL DE VENDA DE PRODUTOS CONTROLADOS (ANEXO III)"
nLin     := 0
lMov	 := .F.	
	
dbSelectArea("T03")
dbSetOrder(1)
dbGoTop()
While !Eof()
	If Interrupcao(@lEnd)
		Return Nil
	Endif

	If nLin == 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin({Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[22],,,@nLin)
		FmtLin({cAlvara},aL[23],,,@nLin)						
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aL[24],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[25],,,@nLin)
		++nLin
		FmtLin(,aL[46],,,@nLin)	
		FmtLin(,aL[47],,,@nLin)				
		FmtLin(,aL[50],,,@nLin)		
	Endif
	If nLin > 52
		nLin := 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin({Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[22],,,@nLin)
		FmtLin({cAlvara},aL[23],,,@nLin)						
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aL[24],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[25],,,@nLin)
		++nLin
		FmtLin(,aL[50],,,@nLin)	
		FmtLin(,aL[47],,,@nLin)		
		FmtLin(,aL[48],,,@nLin)		
		FmtLin(,aL[50],,,@nLin) 		
	Endif 

	FmtLin({CToD (StrZero (Day(T03->EMISSAO), 2)+"/"+StrZero (Month (T03->EMISSAO), 2)+"/"+StrZero (Year (T03->EMISSAO), 4)),Substr(T03->EMPRESA,1,25),Substr(T03->ENDE,1,29),T03->CEP,Substr(T03->BAIRRO,1,15),;
	Substr(T03->MUN,1,15),T03->UF,T03->DOC,Substr(T03->DDD,1,3),Substr(T03->TEL,1,8),SubStr(Alltrim(T03->CODPROD)+" - "+T03->DESCPROD,1,31),T03->UM,Transform(T03->QUANT,"999999999.99")},aL[49],,,@nLin)
	
	lMov	 := .T.
	dbSelectArea("T03")
	dbSkip()
Enddo	
	
	If !lMov
		nLin := 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin({Transform(cTrimestre,"9"),Transform(Year(mv_par02),"9999")},aL[22],,,@nLin)
		FmtLin({cAlvara},aL[23],,,@nLin)						
		FmtLin({SM0->M0_NOMECOM,Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")},aL[24],,,@nLin)
		FmtLin({SM0->M0_ENDENT},aL[25],,,@nLin)
		++nLin
		FmtLin(,aL[50],,,@nLin)	
		FmtLin(,aL[47],,,@nLin)		
		FmtLin(,aL[48],,,@nLin)		 
		FmtLin(,aL[70],,,@nLin)
	EndIf
		
	FmtLin(,aL[50],,,@nLin)
	++nLin
	FmtLin(,aL[33],,,@nLin)		
	FmtLin(,aL[34],,,@nLin)		
	FmtLin(,aL[35],,,@nLin)		
	FmtLin(,aL[36],,,@nLin)	
	FmtLin(,aL[37],,,@nLin)		
	FmtLin({cNome} ,aL[38],,,@nLin)		
	FmtLin({cCargo},aL[39],,,@nLin)	
	FmtLin({cRg}   ,aL[40],,,@nLin) 
	
cTitulo	 := Upper(STR0070)//"MAPA TRIMESTRAL DE TRANSPORTES
nLin     := 0
lMov	 := .F.	
	
dbSelectArea("T04")
dbSetOrder(1)
dbGoTop()
 
dbSelectArea("T05")
dbSetOrder(1)
dbGoTop()

While !T04->(Eof()) .Or. !T05->(Eof())
	If Interrupcao(@lEnd)
		Return Nil
	Endif

	If nLin == 0                                          
		nLin := Cabec(cTitulo,"","","MATR947",cTam)                                 								
		++nLin
		FmtLin(,aL[52],,,@nLin)	                                                       
		FmtLin(,aL[53],,,@nLin)		
		FmtLin(,aL[54],,,@nLin)
		FmtLin({SM0->M0_NOMECOM,cValidade},aL[55],,,@nLin)		 
		FmtLin(,aL[56],,,@nLin)			
		FmtLin({SM0->M0_BAIRCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,StrZero (Day(dDtIni), 2)+"/"+StrZero (Month (dDtIni), 2),StrZero (Day(dDtFim), 2)+"/"+StrZero (Month (dDtFim), 2),Transform(Year(dDtIni),"9999")},aL[57],,,@nLin)	
		FmtLin(,aL[58],,,@nLin)		
		FmtLin(,aL[59],,,@nLin)
		FmtLin(,aL[60],,,@nLin)	
		FmtLin(,aL[61],,,@nLin)
		If!T05->(Eof())		
	   		FmtLin({SubStr(Alltrim(T05->CODPROD)+" - "+T05->DESCPROD,1,40),Substr(T05->NREDUZ,1,20),Substr(T05->ENDE,1,20),Substr(T05->BAIRRO,1,12),Substr(T05->MUN,1,12),Substr(T05->CEP,1,8),Substr(T05->UF,1,2),Substr(SM0->M0_NOMECOM,1,20),Substr(SM0->M0_ENDENT,1,20),Substr(SM0->M0_BAIRCOB,1,12),Substr(SM0->M0_CIDCOB,1,12),Substr(SM0->M0_CEPENT,1,8),Substr(SM0->M0_ESTCOB,1,2)},aL[62],,,@nLin)
	   		FmtLin(,aL[63],,,@nLin)
	 	EndIf
		If!T04->(Eof())
	  		FmtLin({SubStr(Alltrim(T04->CODPROD)+" - "+T04->DESCPROD,1,40),Substr(SM0->M0_NOMECOM,1,20),Substr(SM0->M0_ENDENT,1,20),Substr(SM0->M0_BAIRCOB,1,12),Substr(SM0->M0_CIDCOB,1,12),Substr(SM0->M0_CEPENT,1,8),Substr(SM0->M0_ESTCOB,1,2), Substr(T04->NREDUZ,1,20),Substr(T04->ENDE,1,20),Substr(T04->BAIRRO,1,12),Substr(T04->MUN,1,12),Substr(T04->CEP,1,8),Substr(T04->UF,1,2)},aL[62],,,@nLin)
			FmtLin(,aL[63],,,@nLin)
		EndIf	
	Endif
	If nLin > 52
		nLin := 0
		nLin := Cabec(cTitulo,"","","MATR947",cTam)
		++nLin                                  
		FmtLin({SM0->M0_NOMECOM,cValidade},aL[55],,,@nLin)
		FmtLin({SM0->M0_BAIRCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,StrZero (Day(dDtIni), 2)+"/"+StrZero (Month (dDtIni), 2),StrZero (Day(dDtFim), 2)+"/"+StrZero (Month (dDtFim), 2),Transform(Year(dDtIni),"9999")},aL[57],,,@nLin)	
		++nLin
		FmtLin(,aL[52],,,@nLin)	
		FmtLin(,aL[53],,,@nLin)		
		FmtLin(,aL[54],,,@nLin)		 
		FmtLin(,aL[56],,,@nLin)			
		FmtLin(,aL[58],,,@nLin)		
		FmtLin(,aL[59],,,@nLin)
		FmtLin(,aL[60],,,@nLin)	
		FmtLin(,aL[61],,,@nLin)
		If!T05->(Eof())		
			FmtLin({SubStr(Alltrim(T05->CODPROD)+" - "+T05->DESCPROD,1,40),Substr(T05->NREDUZ,1,20),Substr(T05->ENDE,1,20),Substr(T05->BAIRRO,1,12),Substr(T05->MUN,1,12),Substr(T05->CEP,1,8),Substr(T05->UF,1,2),Substr(SM0->M0_NOMECOM,1,20),Substr(SM0->M0_ENDENT,1,20),Substr(SM0->M0_BAIRCOB,1,12),Substr(SM0->M0_CIDCOB,1,12),Substr(SM0->M0_CEPENT,1,8),Substr(SM0->M0_ESTCOB,1,2)},aL[62],,,@nLin)
			FmtLin(,aL[63],,,@nLin) 
		EndIf
		If!T04->(Eof())
	  		FmtLin({SubStr(Alltrim(T04->CODPROD)+" - "+T04->DESCPROD,1,40),Substr(SM0->M0_NOMECOM,1,20),Substr(SM0->M0_ENDENT,1,20),Substr(SM0->M0_BAIRCOB,1,12),Substr(SM0->M0_CIDCOB,1,12),Substr(SM0->M0_CEPENT,1,8),Substr(SM0->M0_ESTCOB,1,2), Substr(T04->NREDUZ,1,20),Substr(T04->ENDE,1,20),Substr(T04->BAIRRO,1,12),Substr(T04->MUN,1,12),Substr(T04->CEP,1,8),Substr(T04->UF,1,2)},aL[62],,,@nLin)
	  		FmtLin(,aL[63],,,@nLin)
	 	EndIf	 		
	Endif 
	
	lMov	 := .T.
	dbSelectArea("T04")
	dbSkip()
	 
	dbSelectArea("T05")
	dbSkip()
Enddo

	If !lMov
		nLin := Cabec(cTitulo,"","","MATR947",cTam)                                 								
		++nLin
		FmtLin(,aL[52],,,@nLin)	                                                       
		FmtLin(,aL[53],,,@nLin)		
		FmtLin(,aL[54],,,@nLin)
		FmtLin({SM0->M0_NOMECOM},aL[55],,,@nLin)		 
		FmtLin(,aL[56],,,@nLin)			
		FmtLin({SM0->M0_BAIRCOB,SM0->M0_CIDCOB,SM0->M0_ESTCOB,StrZero (Day(dDtIni), 2)+"/"+StrZero (Month (dDtIni), 2),StrZero (Day(dDtFim), 2)+"/"+StrZero (Month (dDtFim), 2),Transform(Year(dDtIni),"9999")},aL[57],,,@nLin)	
		FmtLin(,aL[58],,,@nLin)		
		FmtLin(,aL[59],,,@nLin)
		FmtLin(,aL[60],,,@nLin)	
		FmtLin(,aL[61],,,@nLin)		
		FmtLin(,aL[70],,,@nLin)
		FmtLin(,aL[63],,,@nLin)
	EndIf
	
	FmtLin(,aL[64],,,@nLin)		
	FmtLin(,aL[65],,,@nLin)		
	FmtLin(,aL[66],,,@nLin)		
	FmtLin(,aL[67],,,@nLin)	
	FmtLin({cCompl},aL[68],,,@nLin)		
	FmtLin(,aL[69],,,@nLin)
	FmtLin(,aL[63],,,@nLin)			
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraTemp  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 13.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa o relatorio                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraTemp()

Local aStru 	:= {}
Local cAlias	:= ""  
Local aDelArqs 	:= {}
Local oTempT01, oTempT02, oTempT03, oTempT04, oTempT05

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ T01 - Relatorio Sintetico COMPRAS          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"CODPROD"	,"C",TamSX3("B1_COD")[01],0})	//Codigo do Produto
AADD(aStru,{"DESCPROD"	,"C",TamSX3("B1_DESC")[01],0})	//Descricao do Produto
AADD(aStru,{"SLDANT"	,"N",TamSX3("B9_QINI")[01],TamSX3("B9_QINI")[02]})	//Saldo Anterior
AADD(aStru,{"COMPRAS"	,"N",015,2})					//Total de Compras
AADD(aStru,{"CONSUMO"	,"N",015,2})					//
AADD(aStru,{"CF"		,"C",TamSX3("D3_CF")[01],0})    // Tipo Requisição
AADD(aStru,{"VENDAS"	,"N",015,2})					//Total de Vendas, Perdas ou transferências
AADD(aStru,{"UM"	    ,"C",002,0})					//Unidade de Medida
AADD(aStru,{"ENDE"		,"C",TamSX3("A1_END")[01],0})							//Endereco
AADD(aStru,{"BAIRRO"	,"C",TamSX3("A1_BAIRRO")[01],0})						//Bairro
AADD(aStru,{"CEP"    	,"C",TamSX3("A1_CEP")[01],0})						    //Cep
AADD(aStru,{"MUN"		,"C",TamSX3("A1_MUN")[01],0})							//Municipio
AADD(aStru,{"UF"		,"C",TamSX3("A1_EST")[01],0})							//UF       
AADD(aStru,{"NREDUZ"	,"C",TamSX3("A1_NREDUZ")[01],0})						//Cliente/Fornecedor

cAlias := "T01"
oTempT01 := FwTemporaryTable():New(cAlias,aStru)

oTempT01:AddIndex("T01",{"CODPROD"})
oTempT01:Create()

aAdd(aDelArqs,oTempT01)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ T02 - Relatorio Analitico COMPRAS          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cAlias	:= ""

AADD(aStru,{"CODPROD"	,"C",TamSX3("B1_COD")[01],0})							//Codigo do Produto
AADD(aStru,{"EMISSAO"	,"D",TamSX3("F3_EMISSAO")[01],0})  						//Data
AADD(aStru,{"EMPRESA"	,"C",TamSX3("A1_NOME")[01],0})							//Cliente e/ou Fornecedor
AADD(aStru,{"ENDE"		,"C",TamSX3("A1_END")[01],0})							//Endereco
AADD(aStru,{"MUN"		,"C",TamSX3("A1_MUN")[01],0})							//Municipio
AADD(aStru,{"UF"		,"C",TamSX3("A1_EST")[01],0})							//UF
AADD(aStru,{"NF"		,"C",TamSX3("F3_NFISCAL")[01],0})						//Nota Fiscal
AADD(aStru,{"SERIE"		,"C",TamSX3("F3_SERIE")[01],0})							//Seria da NF
AADD(aStru,{"CLIEFOR"	,"C",TamSX3("A1_COD")[01],0})							//Cliente/Fornecedor
AADD(aStru,{"LOJA"		,"C",TamSX3("A1_LOJA")[01],0})							//Loja
AADD(aStru,{"QUANT"		,"N",TamSX3("D1_QUANT")[01],TamSX3("D1_QUANT")[02]})	//Quantidade
AADD(aStru,{"UM"	    ,"C",002,0})											//Unidade de Medida
AADD(aStru,{"CEP"		,"C",TamSX3("A1_CEP")[01],0})							//CEP
AADD(aStru,{"FONE"		,"C",TamSX3("A1_TEL")[01],0})							//Telefone  
AADD(aStru,{"NTRANSP"	,"C",TamSX3("A4_NREDUZ")[01],0})					//Nome transportadora
AADD(aStru,{"ENDTRAN"	,"C",TamSX3("A4_END")[01],0})				   		//Endereco da Transportadora   
AADD(aStru,{"CEPTRAN"	,"C",TamSX3("A4_CEP")[01],0})				   		//Cep da Transportadora 
AADD(aStru,{"MUNTRAN"	,"C",TamSX3("A4_MUN")[01],0})						//Municipio da Transportadora 
AADD(aStru,{"ESTTRAN"	,"C",TamSX3("A4_EST")[01],0})				 		//Estado da Transportadora 
AADD(aStru,{"TELTRAN"	,"C",TamSX3("A4_TEL")[01],0})				   		//Telefone da Transportadora

cAlias := "T02"
oTempT02 := FwTemporaryTable():New(cAlias,aStru)

oTempT02:AddIndex("T02",{"CODPROD","NF","SERIE","CLIEFOR","LOJA"})
oTempT02:Create()

aAdd(aDelArqs,oTempT02)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ T03 - Relatorio Analitico VENDAS           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cAlias	:= ""

AADD(aStru,{"CODPROD"	,"C",TamSX3("B1_COD")[01],0})							//Codigo do Produto
AADD(aStru,{"DESCPROD"	,"C",TamSX3("B1_DESC")[01],0})							//Descricao do Produto
AADD(aStru,{"EMISSAO"	,"D",TamSX3("F3_EMISSAO")[01],0})  						//Data
AADD(aStru,{"EMPRESA"	,"C",TamSX3("A1_NOME")[01],0})							//Cliente e/ou Fornecedor
AADD(aStru,{"ENDE"		,"C",TamSX3("A1_END")[01],0})							//Endereco
AADD(aStru,{"BAIRRO"	,"C",TamSX3("A1_BAIRRO")[01],0})						//Bairro
AADD(aStru,{"CEP"    	,"C",TamSX3("A1_CEP")[01],0})						    //Cep
AADD(aStru,{"MUN"		,"C",TamSX3("A1_MUN")[01],0})							//Municipio
AADD(aStru,{"UF"		,"C",TamSX3("A1_EST")[01],0})							//UF
AADD(aStru,{"DDD"   	,"C",TamSX3("A1_DDD")[01],0})						    //DDD
AADD(aStru,{"TEL"   	,"C",TamSX3("A1_TEL")[01],0})						    //Telefonte
AADD(aStru,{"NF"		,"C",TamSX3("F3_NFISCAL")[01],0})						//Nota Fiscal
AADD(aStru,{"SERIE"		,"C",TamSX3("F3_SERIE")[01],0})							//Seria da NF
AADD(aStru,{"CLIEFOR"	,"C",TamSX3("A1_COD")[01],0})							//Cliente/Fornecedor
AADD(aStru,{"NREDUZ"	,"C",TamSX3("A1_NREDUZ")[01],0})						//Cliente/Fornecedor
AADD(aStru,{"LOJA"		,"C",TamSX3("A1_LOJA")[01],0})							//Loja
AADD(aStru,{"QUANT"		,"N",TamSX3("D1_QUANT")[01],TamSX3("D1_QUANT")[02]})	//Quantidade
AADD(aStru,{"UM"	    ,"C",002,0})											//Unidade de Medida 
AADD(aStru,{"DOC"		,"C",TamSX3("D2_DOC")[01],0})							//Numero da NF.

cAlias := "T03"
oTempT03 := FwTemporaryTable():New(cAlias,aStru)

oTempT03:AddIndex("T03",{"CODPROD","NF","SERIE","CLIEFOR","LOJA"})
oTempT03:Create()

aAdd(aDelArqs,oTempT03)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ T04 - MAPA TRIMESTRAL DE TRANSPORTES       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cAlias	:= ""

AADD(aStru,{"CODPROD"	,"C",TamSX3("B1_COD")[01],0})	//Codigo do Produto
AADD(aStru,{"DESCPROD"	,"C",TamSX3("B1_DESC")[01],0})	//Descricao do Produto
AADD(aStru,{"SLDANT"	,"N",TamSX3("B9_QINI")[01],TamSX3("B9_QINI")[02]})	//Saldo Anterior
AADD(aStru,{"COMPRAS"	,"N",015,2})					//Total de Compras
AADD(aStru,{"CONSUMO"	,"N",015,2})					//
AADD(aStru,{"VENDAS"	,"N",015,2})					//Total de Vendas, Perdas ou transferências
AADD(aStru,{"UM"	    ,"C",002,0})					//Unidade de Medida
AADD(aStru,{"NF"		,"C",TamSX3("F3_NFISCAL")[01],0})						//Nota Fiscal
AADD(aStru,{"SERIE"		,"C",TamSX3("F3_SERIE")[01],0})							//Seria da NF
AADD(aStru,{"CLIEFOR"	,"C",TamSX3("A1_COD")[01],0})							//Cliente/Fornecedor
AADD(aStru,{"LOJA"		,"C",TamSX3("A1_LOJA")[01],0})							//Loja
AADD(aStru,{"ENDE"		,"C",TamSX3("A1_END")[01],0})							//Endereco
AADD(aStru,{"TEL"   	,"C",TamSX3("A1_TEL")[01],0})						    //Telefonte
AADD(aStru,{"BAIRRO"	,"C",TamSX3("A1_BAIRRO")[01],0})						//Bairro
AADD(aStru,{"CEP"    	,"C",TamSX3("A1_CEP")[01],0})						    //Cep
AADD(aStru,{"MUN"		,"C",TamSX3("A1_MUN")[01],0})							//Municipio
AADD(aStru,{"UF"		,"C",TamSX3("A1_EST")[01],0})							//UF       
AADD(aStru,{"NREDUZ"	,"C",TamSX3("A1_NREDUZ")[01],0})						//Cliente/Fornecedor

cAlias := "T04"
oTempT04 := FwTemporaryTable():New(cAlias,aStru)

oTempT04:AddIndex("T04",{"CODPROD","NF","SERIE","CLIEFOR","LOJA"})
oTempT04:Create()

aAdd(aDelArqs,oTempT04)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ T05 - MAPA TRIMESTRAL DE TRANSPORTES       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:= {}
cAlias	:= ""

AADD(aStru,{"CODPROD"	,"C",TamSX3("B1_COD")[01],0})	//Codigo do Produto
AADD(aStru,{"DESCPROD"	,"C",TamSX3("B1_DESC")[01],0})	//Descricao do Produto
AADD(aStru,{"SLDANT"	,"N",TamSX3("B9_QINI")[01],TamSX3("B9_QINI")[02]})	//Saldo Anterior
AADD(aStru,{"COMPRAS"	,"N",015,2})					//Total de Compras
AADD(aStru,{"CONSUMO"	,"N",015,2})					//
AADD(aStru,{"VENDAS"	,"N",015,2})					//Total de Vendas, Perdas ou transferências
AADD(aStru,{"UM"	    ,"C",002,0})					//Unidade de Medida
AADD(aStru,{"NF"		,"C",TamSX3("F3_NFISCAL")[01],0})						//Nota Fiscal
AADD(aStru,{"SERIE"		,"C",TamSX3("F3_SERIE")[01],0})							//Seria da NF
AADD(aStru,{"CLIEFOR"	,"C",TamSX3("A1_COD")[01],0})							//Cliente/Fornecedor
AADD(aStru,{"LOJA"		,"C",TamSX3("A1_LOJA")[01],0})							//Loja
AADD(aStru,{"ENDE"		,"C",TamSX3("A1_END")[01],0})							//Endereco
AADD(aStru,{"TEL"   	,"C",TamSX3("A1_TEL")[01],0})						    //Telefonte
AADD(aStru,{"BAIRRO"	,"C",TamSX3("A1_BAIRRO")[01],0})						//Bairro
AADD(aStru,{"CEP"    	,"C",TamSX3("A1_CEP")[01],0})						    //Cep
AADD(aStru,{"MUN"		,"C",TamSX3("A1_MUN")[01],0})							//Municipio
AADD(aStru,{"UF"		,"C",TamSX3("A1_EST")[01],0})							//UF       
AADD(aStru,{"NREDUZ"	,"C",TamSX3("A1_NREDUZ")[01],0})						//Cliente/Fornecedor

cAlias := "T05"
oTempT05 := FwTemporaryTable():New(cAlias,aStru)

oTempT05:AddIndex("T05",{"CODPROD","NF","SERIE","CLIEFOR","LOJA"})
oTempT05:Create()

aAdd(aDelArqs,oTempT05)

Return(aDelArqs)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³LayOut    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 13.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Layout do relatorio                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function LayOut(aL)

aL[01] := OemToAnsi(STR0005)	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[02] := OemToAnsi(STR0006)	//"Empresa: ##################################################"                                  |              MAPA TRIMESTRAL            | Certificado de Vistoria nº ########, expedido pela SSP/Policia Civil         |
aL[03] := OemToAnsi(STR0007)	//"Endereço: #################################################"                                  |      PRODUTOS QUÍMICOS CONTROLADOS      | Estadual.                                                                    |
aL[04] := OemToAnsi(STR0008)	//"Cidade: ####################      Bairro: ####################      Cep.: #########"          |                   DIRD                  |                                                                              |
aL[05] := OemToAnsi(STR0009)	//"Telefone: ##############                                                                      |  DPC - DIVISÃO DE PRODUTOS CONTROLADOS  | Alvará nº ######## expedido pela SSP/Polícia Civil Estadual                  |
aL[06] := OemToAnsi(STR0010)	//"CGC: ##.###.###/####-##           Inscricao Estadual: ###.###.###.###"                        |  Referente ao  #º trimestre de ####     |                                                                              |
aL[07] := OemToAnsi(STR0011)	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[08] := OemToAnsi(STR0012)	//"| Produto                                                                        |    Saldo Trimestre |            Compras |              Somas |            Consumo |     Vendas, perdas | Saldo que passa para | UN  |"
aL[09] := OemToAnsi(STR0013)	//"|                                                                                |       Anterior     |                    |                    |                    |  ou transferências | o trimestre seguinte |     |"
aL[21] := OemToAnsi(STR0025)	//"+--------------------------------------------------------------------------------|--------------------|--------------------|--------------------|--------------------|--------------------|----------------------|-----+"
aL[10] := OemToAnsi(STR0014)	//"| ############################################################################## | ################## | ################## | ################## | ################## | ################## | #################### | ##  |"
aL[11] := OemToAnsi(STR0015)	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"   
								//"| NÃO HOUVE COMPRA(OU VENDA)NO TRIMESTRE ACIMA ESPECIFICADO                      | ################## |                    |                    |                    |                    | #################### |     |"

aL[22] := OemToAnsi(STR0027)	//"                                                                                                               RELATÓRIO DO #º TRIMESTRE DE ####                                                                        "
aL[23] := OemToAnsi(STR0028)    //"                                                                                                                   Número do Alvará: ########                                                                           "
aL[24] := OemToAnsi(STR0029)    //"Razão Social: ##################################################                                                                                                                     CNPJ: ##.###.###/####-##           "
aL[25] := OemToAnsi(STR0030)	//"Local Licenciado: ##############################################"
aL[12] := OemToAnsi(STR0016)	//"+------------|----------------|-------------------|-------------------------------------------------------|-------------------------------------------------|----------------------------------------------------------+"
aL[13] := OemToAnsi(STR0017)	//"|    Data    | Nº NOTA FISCAL |  QUANTIDADE E     |  NOME DOS PRODUTOS                                    |   RAZÃO SOCIAL COMPLETA/ENDEREÇO COMPLETO       |   RAZÃO SOCIAL COMPLETA/ENDEREÇO COMPLETO                |"
aL[14] := OemToAnsi(STR0018)	//"|            |                | UNIDADE DE MEDIDA |     COMPRADOS                                         | CEP/FONE/CIDADE/UF DO FORNECEDOR/REMETENTE      |   CEP/FONE/CIDADE/UF DO TRANSPORTADOR                    |"
aL[15] := OemToAnsi(STR0019)	//"+------------|----------------|-------------------|-------------------------------------------------------|-------------------------------------------------|----------------------------------------------------------+"
aL[16] := OemToAnsi(STR0020)    //"|  ########  |   #########    |############### ## | ######################################################|Razão Social|####################################|Razão Social|#############################################|"
aL[17] := OemToAnsi(STR0021)    //"|            |                |                   |                                                       |Endereço/Cep|########################## #########|Endereço/Cep|################################### #########|"
aL[18] := OemToAnsi(STR0022)    //"|            |                |                   |                                                       |Cidade/UF   |################################# ##|Cidade/UF   |########################################## ##|"
aL[19] := OemToAnsi(STR0023)    //"|            |                |                   |                                                       |Telefone    |##############                      |Telefone    |##############                               |"
aL[20] := OemToAnsi(STR0024)    //"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"

aL[26] := OemToAnsi(STR0031)    //"                                                                                 ---------------------------------                                O que declaro é verdade, sob as penas da lei.                         "
aL[27] := OemToAnsi(STR0032)    //"                                                                                 |                               |                                                                                                      "
aL[28] := OemToAnsi(STR0033)    //"A não entrega deste até dez dias após o término                                  |                               |                                              ,        de             de                              "
aL[29] := OemToAnsi(STR0034)    //"de cada trimestre pode implicar à empresa severas                                |                               |                                                                                                      "
aL[30] := OemToAnsi(STR0035)    //"penalidades.                                                                     |                               |                                          Assinatura do Responsável                                   "
aL[31] := OemToAnsi(STR0036)    //"                                                                                 ---------------------------------                                 Nome: #####################################                          "
aL[32] := OemToAnsi(STR0037)    //"                                                                                                                                                   RG:   ####################                                           "


aL[33] := OemToAnsi(STR0038)    //"                                                                                                                                                   O que declaro é verdade, sob as penas da lei.                        "
aL[34] := OemToAnsi(STR0039)    //"                                                                                                                                                   Cidade/data:                                                         "
aL[35] := OemToAnsi(STR0040)    //"Atenção: O mapa deverá ser entregue em 3 vias até o décimo dia útil                                                                                                                                                     "
aL[36] := OemToAnsi(STR0041)    //"após o término de cada trimestre.                                                                                                                                                                                       "
aL[37] := OemToAnsi(STR0042)    //"                                                                                                                                                   Ass:                                                                 "
aL[38] := OemToAnsi(STR0043)    //"                                                                                                                                                   Responsável: ##################################################      "
aL[39] := OemToAnsi(STR0044)    //"                                                                                                                                                   Cargo:       #########################################               "
aL[40] := OemToAnsi(STR0045)    //"                                                                                                                                                   RG nº        #################                                       "

                
                
                
                //ALTERAR DAQUI PARA BAIXO CRIANDO UM RELATORIO POR CIMA DESSE EXEMPLO PODE INCLUIR LINHAS NOVAS E ALTERAR AS JÁ EXISTENTES ....COLOCAR AS LINHAS NO ARQUIVO MATR947.CH
                
                

aL[22] := OemToAnsi(STR0027)	//"                                                                                                               RELATÓRIO DO #º TRIMESTRE DE ####                                                                        "
aL[23] := OemToAnsi(STR0028)    //"                                                                                                                   Número do Alvará: ########                                                                           "
aL[24] := OemToAnsi(STR0029)    //"Razão Social: ##################################################                                                                                                                     CNPJ: ##.###.###/####-##           "
aL[25] := OemToAnsi(STR0030)	//"Local Licenciado: ##############################################"
aL[46] := OemToAnsi(STR0046)	//"+------------|--------------------------|-----------------------------------------|-----------------|-----------------|----|-------|--------------|---------------------------------|--------------|-------------------+"
aL[47] := OemToAnsi(STR0047)	//"|    Data    |    CLIENTE               |      ENDEREÇO/CEP                       |   BAIRRO        |   CIDADE        | UF | N.F.N | DDD/FONE     |        PRODUTO                  | UNID. MEDIDA |    QUANTIDADE     |"
aL[48] := OemToAnsi(STR0048)	//"+------------|--------------------------|-----------------------------------------|-----------------|-----------------|----|-------|--------------|---------------------------------|--------------|-------------------+"
aL[49] := OemToAnsi(STR0049)    //"|  ########  | ######################## | ############################## ######## | ############### | ############### | ## |#######  | ### ######## | ############################### |      ##      | ############### |"
aL[50] := OemToAnsi(STR0050)    //"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"





aL[52] := OemToAnsi(STR0052)	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[53] := OemToAnsi(STR0053)	//"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX       |    RESUMO   DOS   TRANSPORTES  DE  PRODUTOS    | EMPRESA LICENCIADA PELA SECRETARIA     									  |"
aL[54] := OemToAnsi(STR0054)	//"ESTABELECIMENTO LICENCIADO:                                                               |    CONTROLADOS PELA SECRETARIA DA SEGURANÇA    | DA SESURANÇA PÚBLICA, SOB                                                 |"
aL[55] := OemToAnsi(STR0055)	//"###################################################################################       |    PÚBLICA(SSP) - POLICIA  CIVIL ESTADUAL E    | N / VALIDADE: ########                                                    |"
aL[56] := OemToAnsi(STR0056)	//"BAIRRO, CIDADE E ESTADO                                                                   |    EXÉRCITO, EFETUADOS DURANTE O PERIODO DE    | 														                  |"
aL[57] := OemToAnsi(STR0057)	//"################### - ####################/##                                             |    * ############################ de #### *    |                                                                           |"
aL[58] := OemToAnsi(STR0058)	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[59] := OemToAnsi(STR0059)	//"| NOME DE CADA PRODUTO                        |  NOME DO EMBARCADOR   |                    ENDEREÇO COMPLETO                      | NOME DO DESTINATÁRIO  |                     ENDEREÇO COMPLETO                      |"
aL[60] := OemToAnsi(STR0060)	//"| CONTROLADO TRANSPORTADO                     |                       |         Rua, Número, Bairro, Cidade, Cep e Estado         |                       |           Rua, Número, Bairro, Cidade, Cep e Estado        |"
aL[61] := OemToAnsi(STR0061)	//"+---------------------------------------------|-----------------------|-----------------------------------------------------------|-----------------------|------------------------------------------------------------+"
aL[62] := OemToAnsi(STR0062)	//"| ########################################### | ##################### | ################### ############ ############ ######## ## | ##################### | #################### ############ ############ ######## ## |"
aL[63] := OemToAnsi(STR0063)	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[70] := OemToAnsi(STR0074)	//"| NÃO HOUVE COMPRA(OU VENDA)NO TRIMESTRE ACIMA ESPECIFICADO                                                                                                                                                            |"
aL[71] := OemToAnsi(STR0075)	//"| NÃO HOUVE COMPRA(OU VENDA)NO TRIMESTRE ACIMA ESPECIFICADO                      | ################## |                    |                    |                    |                    | #################### |     |"

aL[64] := OemToAnsi(STR0064)    //"+------------------------------------------------------                           ---------------------------------                ------------------------------------------------------------------------------------+"
aL[65] := OemToAnsi(STR0065)    //"|                                                     |                           |                               |                |    O que declaro é verdade, sob as penas da lei.                                  |"
aL[66] := OemToAnsi(STR0066)    //"|A não entrega deste até dez dias após o término      |                           |                               |                |                  ,        de             de                                       |"
aL[67] := OemToAnsi(STR0067)    //"|de cada trimestre pode implicar à empresa severas    |                           |                               |                |    ASSINATURA                                                                     |"
aL[68] := OemToAnsi(STR0068)    //"|penalidades.                                         |                           |                               |                |    NOME/CARGO/RG: ############################################################### |"
aL[69] := OemToAnsi(STR0069)    //"+------------------------------------------------------                           ---------------------------------                ------------------------------------------------------------------------------------+"

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mtr947Est ³ Autor ³ Mary C. Hergert       ³ Data ³28/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera os arquivos temporarios com os movimentos de estoque   ³±±
±±³          ³no inicio e no final do periodo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Tipo (1 - gera arquivos / 2 - deleta gerados)       ³±±
±±³          ³ExpD2 = Data inicial de geracao das informacoes             ³±±
±±³          ³ExpD3 = Data final de geracao das informacoes               ³±±
±±³          ³ExpC4 = Produto a ser filtrado                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Matr947                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mtr947Est(nTipo,dDtIni,dDtFim,cProduto)

Local dData		 :=DTOS(mv_par03)  
Local dDtAnt     := FirstDay(dDtIni)-1

Local cCpoB5	:= GetNewPar("MV_MTR947A","")
Local cArqAnt    := ""
Local cArqAtu 	 := ""
Local cFiltraB5	 := ""
Local cTrimestre := mv_par04  


Local aProd      :=Array(8)
Local aFiltraB5	:= {}

Local nX		:= 0
	
aProd[1] := Replicate("",TamSx3("B1_COD")[1])
aProd[2] := Replicate("Z",TamSx3("B1_COD")[1])
aProd[3] := Replicate("",TamSx3("B1_LOCPAD")[1])
aProd[4] := Replicate("Z",TamSx3("B1_LOCPAD")[1])
aProd[5] := 2
aProd[6] := 1
aProd[7] := 2
aProd[8] := 2

#IFDEF TOP     
	// Indicacao de produto controlado ou nao				
	If !Empty(cCpoB5) 
		cFiltraB5 += " AND SB5." + Alltrim(cCpoB5) + " = 'S'"       
	Endif          
	// Quando o relatorio sera gerado de um unico produto
	If !Empty(cProduto)
		cFiltraB5 += " AND SB5.B5_COD = '" + cProduto + "'" 
	Endif          
#ELSE

	// Indicacao de produto controlado ou nao				
	If !Empty(cCpoB5)
		aAdd(aFiltraB5,"SB5->" + Alltrim(cCpoB5) + " == 'S'")
	Endif
	// Quando o relatorio sera gerado de um unico produto
	If !Empty(cProduto)
		aAdd(aFiltraB5,"SB5->B5_COD = '" + cProduto + "'")
	Endif
			
	For nX := 1 to Len(aFiltraB5) 
		If nX == 1
			cFiltraB5 := aFiltraB5[nX]
		Else                        
			cFiltraB5 := cFiltraB5 + " .And. " + aFiltraB5[nX]
		Endif
	Next

#ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria os arquivos temporarios com o estoque inicial/final dos produtos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1 // Gera os temporarios com o estoque inicial/final

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ANT - Estoque Anterior                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FsEstInv({"ANT",""},1,.T.,.F.,dDtAnt,.F.,,.T.,cFiltraB5,,,,aProd)
	

	dbSelectArea("ANT")
	cArqAnt := CriaTrab(NIL,.F.)
	IndRegua("ANT",cArqAnt,"CODIGO")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ ATU - Estoque Atual                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
    If cTrimestre == 1
       dData := CToD("31/12/"+Substr(Alltrim(Str(Year(MV_PAR03)-1)),3))
    ElseIf cTrimestre == 2  
       dData := CToD("31/03/"+Substr(Alltrim(Str(Year(MV_PAR03))),3))
    ElseIf cTrimestre == 3   
       dData := CToD("30/06/"+Substr(Alltrim(Str(Year(MV_PAR03))),3))
    ElseIf cTrimestre == 4   
       dData := CToD("31/09/"+Substr(Alltrim(Str(Year(MV_PAR03))),3))
    Endif   
	
	FsEstInv({"ATU",""},1,.T.,.F.,dData,.F.,,.T.,cFiltraB5,,,,aProd)
	dbSelectArea("ATU")
	cArqAtu := CriaTrab(NIL,.F.)
	IndRegua("ATU",cArqAtu,"CODIGO")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui os temporarios criados com o estoque final e inicial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	FsEstInv({"ANT",""},2,,,dDtAnt,.F.,,.T.,cFiltraB5,,,,aProd)	//Estoque Anterior
	FsEstInv({"ATU",""},2,,,dDtFim,.F.,,.T.,cFiltraB5,,,,aProd)	//Estoque Atual
Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr947Str ºAutor  ³Mary Hergert        º Data ³ 03/04/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utiLizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR948                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Static Function Mtr947Str(aCampos,cCmpQry)

Local	aRet		:=	{}
Local	nX			:=	0
Local	aTamSx3		:=	{}   

For nX := 1 To Len(aCampos)

		aTamSx3 := TamSX3(aCampos[nX][02])
		aAdd (aRet,{aCampos[nX][02],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
		cCmpQry	+=	aCampos[nX][01] + "." + aCampos[nX][02] + ", "

Next(nX)

If(Len(cCmpQry)>0)
	cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
EndIf 
	
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M947DelArqºAutor  ³Mary Hergert        º Data ³ 03/04/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Exclui tabelas e indices temporarios criados.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aDelArqs : array com o alias e os arquivos                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR947                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Static Function M947DelArq(aDelArqs)

Local ni := 1
Local oTempX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Fechando as tabelas temporarias                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For ni := 1 to Len(aDelArqs)
	
	oTempX := aDelArqs[ni]
	oTempX:Delete()

Next

Return
