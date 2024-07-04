#Include "Protheus.Ch"
#Include "Matr949.Ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Matr949   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³MAPA DEMONSTRATIVO DAS ENTRADAS E SAIDAS DE PRODUTOS        ³±±
±±³          ³CONTROLADOS - COMANDO MILITAR - EXERCITO                    ³±±
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
Function Matr949()

Local cString	:=	""
Local cPerg		:= 	"MTR949"
Local cTitulo  	:= OemToAnsi(STR0003)	//"Mapa de Produtos Controlados"
Local cDesc1  	:= OemToAnsi(STR0004)	//"Relatorio de movimentacoes de Produtos Controlados"
Local cCpoB5	:= GetNewPar("MV_MTR949A","")	//Produto Controlado - Exercito
Local aDelArqs	:=	{}

Private wnrel 	:= "MATR949"
Private cTam	:= "G"	 	// P/M/G
Private Limite	:= 220  	// 80/132/220
Private lEnd 	:= .F.		// Controle de cancelamento do relatorio
Private m_pag  	:= 1  		// Contador de Paginas
Private aReturn	:= {OemToAnsi(STR0001),1,OemToAnsi(STR0002),2,2,1,"",1}	//"Zebrado"###"Administracao"

Private oTmpTable1	:= NIL
Private oTmpTable2	:= NIL
Private oTmpTable3	:= NIL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Validacao de campos                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (Empty(cCpoB5) .Or. SB5->(FieldPos(cCpoB5)) == 0)
	xMagHelpFis(OemToAnsi(STR0027),OemToAnsi(STR0028),OemToAnsi(STR0029))
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

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera arquivo temporarios³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
GeraTemp()

RptStatus({|lEnd| ProcRel(lEnd)},cTitulo)

If (aReturn[5]==1)
	Set Printer To 	
   	ourspool(wnrel)
Endif
MS_FLUSH()
                    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui arquivo temporario³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oTmpTable1:Delete()
oTmpTable2:Delete()
oTmpTable3:Delete()

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcRel   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa o relatorio                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcRel(lEnd)
Local cQuery	:= ""
Local cAliasSB5	:= "SB5"
Local nX		:= 0 
Local aStru		:= {}
Local cIndex	:= ""
Local nIndex	:= 0
Local cProduto	:= mv_par01
Local cCpoB5	:= GetNewPar("MV_MTR949A","")	//Produto Controlado 
Local cCpo2B5	:= GetNewPar("MV_MTR949D","")	//Descricao do Produto da tabela SB5

Mtr949Est(1,MV_PAR02,MV_PAR03)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Processa Produtos Controlados                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB5")
dbSetOrder(1)
SetRegua(LastRec())
cAliasSB5	:= "TopSB5"
aStru		:= SB5->(dbStruct())
cQuery 		:= "SELECT SB5.B5_COD,SB5."+(cCpoB5)+",SB5."+(cCpo2B5)+" "
cQuery 		+= "FROM "+RetSqlName("SB5")+" SB5 "
cQuery 		+= "WHERE SB5.B5_FILIAL='"+xFilial("SB5")+"' AND "

If !Empty(cProduto)
	cQuery += "SB5.B5_COD='"+cProduto+"' AND "
Endif	

cQuery 		+= "SB5."+(cCpoB5)+"='S' AND "		
cQuery 		+= "SB5.D_E_L_E_T_ = ' ' "	
cQuery 		+= "ORDER BY "+SqlOrder(SB5->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSB5,.T.,.T.)
	
For nX := 1 To len(aStru)
	If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
		TcSetField(cAliasSD1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
	EndIf
Next nX

dbSelectArea(cAliasSB5)
dbGoTop()
If !Eof()
	While !Eof()
		IncRegua()
		If Interrupcao(lEnd)
			Return Nil
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Calculando Saldo Anterior³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+(cAliasSB5)->B5_COD))
		
		dbSelectArea("TRB")
		If !dbSeek((cAliasSB5)->B5_COD)
			RecLock("TRB",.T.)
			TRB->PRODUTO	:= (cAliasSB5)->B5_COD
			TRB->DESCRICAO 	:= (cAliasSB5)->(FieldGet(FieldPos(cCpo2B5)))
			TRB->SLDANT 	:= Iif(TMP->(DbSeek((cAliasSB5)->B5_COD)),TMP->QUANT,0)
			MsUnlock()
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa Entradas                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcEnt(cAliasSB5)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa Saidas                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcSai(cAliasSB5)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Processa Movimentos internos - SD3³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ProcSd3(cAliasSB5)
	
		dbSelectArea(cAliasSB5)
		dbSkip()
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impressao do relatorio            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	GeraRel(lEnd)
Endif

dbSelectArea(cAliasSB5)
dbCloseArea()

Mtr949Est(2,MV_PAR02,MV_PAR03)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcEnt   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Entradas                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcEnt(cAliasSB5)
Local aArea		:= GetArea()
Local dDtIni	:= mv_par02
Local dDtFim	:= mv_par03
Local cAliasSD1	:= "SD1"
Local nX		:= 0 
Local aStru		:= {}
Local cIndex	:= ""
Local nIndex	:= 0
Local cCpoA1	:= GetNewPar("MV_MTR949B","")	//Pais de Origem - Cliente
Local cCpoA2	:= GetNewPar("MV_MTR949C","")	//Pais de Origem - Fornecedor
Local cEmp		:= ""
Local cPais		:= ""
Local cMun		:= ""
Local cUF		:= ""
Local cCmpQry	:= ""
Local aCampos	:=	{}
	

dbSelectArea("SD1")
dbSetOrder(1)
SetRegua(LastRec())

	cAliasSD1	:= "TopSD1"

    aAdd(aCampos,{"SD1","D1_FILIAL"})
    aAdd(aCampos,{"SD1","D1_COD"})
    aAdd(aCampos,{"SD1","D1_LOCAL"})
    aAdd(aCampos,{"SD1","D1_TIPO"})
    aAdd(aCampos,{"SD1","D1_FORNECE"})
    aAdd(aCampos,{"SD1","D1_LOJA"})
    aAdd(aCampos,{"SD1","D1_QUANT"})
 	    
  	aStru  := Mtr949Str(aCampos,@cCmpQry)
	
	cQuery 		:= "SELECT "
	cQuery 		+= cCmpQry
	cQuery 		+= "FROM "+RetSqlName("SD1")+" SD1,"+RetSqlName("SF4")+" SF4 "
	cQuery 		+= "WHERE D1_FILIAL='"+xFilial("SD1")+"' AND "
	cQuery 		+= "SD1.D1_DTDIGIT>='"+Dtos(dDtIni)+"' AND "
	cQuery 		+= "SD1.D1_DTDIGIT<='"+Dtos(dDtFim)+"' AND "
	cQuery 		+= "SD1.D1_CF NOT IN('000','999','0000','9999') AND "
	cQuery 		+= "SD1.D1_COD='"+(cAliasSB5)->B5_COD+"' AND "
	cQuery 		+= "SD1.D_E_L_E_T_ = ' ' AND "
	cQuery 		+= "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
	cQuery 		+= "SF4.F4_CODIGO=SD1.D1_TES AND "	
	cQuery 		+= "SF4.F4_ESTOQUE = 'S' AND "		
	cQuery 		+= "SF4.D_E_L_E_T_=' ' "
	
	cQuery 		+= "ORDER BY "+SqlOrder(SD1->(IndexKey()))
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1,.T.,.T.)
		
	For nX := 1 To len(aStru)
		If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
			TcSetField(cAliasSD1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
		EndIf
	Next nX

dbSelectArea(cAliasSD1)
dbGoTop()
While !Eof()
	IncRegua()
	If Interrupcao(lEnd)
		Return Nil
	Endif
	
	If (cAliasSD1)->D1_TIPO$"D/B"
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
			cEmp	:= SA1->A1_NOME
			cPais	:= IIf((Empty(cCpoA1) .Or. SA1->(FieldPos(cCpoA1))==0),"",SA1->&(cCpoA1))
			cMun	:= SA1->A1_MUN
			cUF		:= SA1->A1_EST
		Endif
	Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		If dbSeek(xFilial("SA2")+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA)
			cEmp	:= SA2->A2_NOME
			cPais	:= IIf((Empty(cCpoA2) .Or. SA2->(FieldPos(cCpoA2))==0),"",SA2->&(cCpoA2))
			cMun	:= SA2->A2_MUN
			cUF		:= SA2->A2_EST
		Endif
	Endif

    dbSelectArea("TRB1")
    If !TRB1->(DbSeek((cAliasSB5)->B5_COD+cUF+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA))
	    RecLock("TRB1",.T.)
		TRB1->PRODUTO	:= (cAliasSB5)->B5_COD
		TRB1->CLIFOR		:= (cAliasSD1)->D1_FORNECE
		TRB1->LOJA		:= (cAliasSD1)->D1_LOJA
		TRB1->EMPRESA	:= cEmp
		TRB1->MUN		:= cMun
		TRB1->UF			:= cUF
		TRB1->PAIS		:= cPais
	Else
		RecLock("TRB1",.F.)
	EndIf
	TRB1->QTDE		+= (cAliasSD1)->D1_QUANT
    MsUnlock()

	dbSelectArea(cAliasSD1)
	dbSkip()
Enddo

dbSelectArea(cAliasSD1)
dbCloseArea()

RestArea(aArea)
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcSai   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Saidas                                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcSai(cAliasSB5)
Local aArea		:= GetArea()
Local dDtIni	:= mv_par02
Local dDtFim	:= mv_par03
Local cAliasSD2	:= "SD2"
Local nX		:= 0 
Local aStru		:= {}
Local cIndex	:= ""
Local nIndex	:= 0
Local cCpoA1	:= GetNewPar("MV_MTR949B","")	//Pais de Origem - Cliente
Local cCpoA2	:= GetNewPar("MV_MTR949C","")	//Pais de Origem - Fornecedor
Local cEmp		:= ""
Local cPais		:= ""
Local cMun		:= ""
Local cUF		:= ""
Local cCmpQry	:=	""
Local aCampos	:=	{}
	


dbSelectArea("SD2")
dbSetOrder(1)
SetRegua(LastRec())
cAliasSD2	:= "TopSD2"
aStru		:= SD2->(dbStruct())

    aAdd(aCampos,{"SD2","D2_FILIAL"})
    aAdd(aCampos,{"SD2","D2_COD"})
    aAdd(aCampos,{"SD2","D2_LOCAL"})
    aAdd(aCampos,{"SD2","D2_TIPO"})
    aAdd(aCampos,{"SD2","D2_CLIENTE"})
    aAdd(aCampos,{"SD2","D2_LOJA"})
    aAdd(aCampos,{"SD2","D2_QUANT"})
 	    
  	aStru  := Mtr949Str(aCampos,@cCmpQry)

cQuery 		:= "SELECT "
cQuery 		+= cCmpQry
cQuery 		+= "FROM "+RetSqlName("SD2")+" SD2,"+RetSqlName("SF4")+" SF4 "
cQuery 		+= "WHERE D2_FILIAL='"+xFilial("SD2")+"' AND "
cQuery 		+= "SD2.D2_EMISSAO>='"+Dtos(dDtIni)+"' AND "
cQuery 		+= "SD2.D2_EMISSAO<='"+Dtos(dDtFim)+"' AND "
cQuery 		+= "SD2.D2_CF NOT IN('000','999','0000','9999') AND "
cQuery 		+= "SD2.D2_COD='"+(cAliasSB5)->B5_COD+"' AND "
cQuery 		+= "SD2.D_E_L_E_T_ = ' ' AND "
cQuery 		+= "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND "
cQuery 		+= "SF4.F4_CODIGO=SD2.D2_TES AND "	
cQuery 		+= "SF4.F4_ESTOQUE = 'S' AND "		
cQuery 		+= "SF4.D_E_L_E_T_=' ' "
cQuery 		+= "ORDER BY "+SqlOrder(SD2->(IndexKey()))

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
	
For nX := 1 To len(aStru)
	If aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0
		TcSetField(cAliasSD2,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
	EndIf
Next nX


dbSelectArea(cAliasSD2)
dbGoTop()
While !Eof()
	IncRegua()
	If Interrupcao(lEnd)
		Return Nil
	Endif

	If (cAliasSD2)->D2_TIPO$"D/B"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If dbSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cEmp	:= SA2->A2_NOME
			cPais	:= IIf((Empty(cCpoA2) .Or. SA2->(FieldPos(cCpoA2))==0),"",SA2->&(cCpoA2))
			cMun	:= SA2->A2_MUN
			cUF		:= SA2->A2_EST
		Endif
	Else
		dbSelectArea("SA1")
		dbSetOrder(1)
		If dbSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cEmp	:= SA1->A1_NOME
			cPais	:= IIf((Empty(cCpoA1) .Or. SA1->(FieldPos(cCpoA1))==0),"",SA1->&(cCpoA1))
			cMun	:= SA1->A1_MUN
			cUF		:= SA1->A1_EST 
		Endif
	Endif
		
    dbSelectArea("TRB2")
    If !TRB2->(DbSeek((cAliasSB5)->B5_COD+cUF+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA))
	    RecLock("TRB2",.T.)
		TRB2->PRODUTO	:= (cAliasSB5)->B5_COD
		TRB2->CLIFOR		:= (cAliasSD2)->D2_CLIENTE
		TRB2->LOJA		:= (cAliasSD2)->D2_LOJA
		TRB2->EMPRESA	:= cEmp
		TRB2->MUN		:= cMun
		TRB2->UF			:= cUF
		TRB2->PAIS		:= cPais
	Else
		RecLock("TRB2",.F.)
	EndIf
	TRB2->QTDE		+= (cAliasSD2)->D2_QUANT
    MsUnlock()
    
	dbSelectArea(cAliasSD2)
	dbSkip()
Enddo

dbSelectArea(cAliasSD2)
dbCloseArea()

RestArea(aArea)
Return Nil
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ProcSd3   ³ Autor ³Gustavo G. Rueda       ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Processa Movimentos internos                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ProcSd3(cAliasSB5)
Local 	aArea		:= GetArea()
Local 	dDtIni		:= 	mv_par02
Local 	dDtFim		:= 	mv_par03
Local	cAliasSD3	:= 	"SD3"
Local	cArqInd		:=	""
Local	cChave		:=	""
Local	cCondicao	:=	""

Local	cQuery		:=	""
Local	cCmpQry		:= 	""
Local	aStruSD3	:= 	{}
Local	aCampos		:=	{}
Local	nX			:=	0

		aStruSD3	:= {}
		cAliasSD3	:= GetNextAlias()   
					
	    aAdd(aCampos,{"SD3","D3_FILIAL"})
   	    aAdd(aCampos,{"SD3","D3_EMISSAO"})
   	    aAdd(aCampos,{"SD3","D3_COD"})
   	    aAdd(aCampos,{"SD3","D3_QUANT"})
   	    aAdd(aCampos,{"SD3","D3_CF"})
   	    aAdd(aCampos,{"SD3","D3_TM"})
   	    aAdd(aCampos,{"SD3","D3_LOCAL"})
   	    
    	aStruSD3  := Mtr949Str(aCampos,@cCmpQry)

		cQuery    := "SELECT "
		cQuery    += cCmpQry
		cQuery    += "FROM " + RetSqlName("SD3") + " SD3 "
		cQuery    += "WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' AND "
		cQuery    += "SD3.D3_EMISSAO >= '" + dtOs(dDtIni) + "' AND "
		cQuery    += "SD3.D3_EMISSAO <= '" + dtOs(dDtFim) + "' AND "
		cQuery    += "SD3.D3_COD = '" +(cAliasSB5)->B5_COD+ "' AND "
		cQuery    += "SD3.D3_ESTORNO <> 'S' AND "
		cQuery    += "SD3.D3_CF IN('PR0','PR1','ER0','ER1','DE0','DE1','DE2','DE3','DE4','DE5','DE6','DE7','RE0','RE1','RE2','RE3','RE4','RE5','RE6','RE7') AND "
		cQuery    += "SD3.D_E_L_E_T_ = '' "
		cQuery    += "ORDER BY SD3.D3_FILIAL,SD3.D3_OP,SD3.D3_COD,SD3.D3_LOCAL"

	    cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD3,.T.,.T.)
	
		For nX := 1 To len(aStruSD3)
			If aStruSD3[nX][2] <> "C" 
				TcSetField(cAliasSD3,aStruSD3[nX][1],aStruSD3[nX][2],aStruSD3[nX][3],aStruSD3[nX][4])
			EndIf
		Next nX
	
		dbSelectArea(cAliasSD3)

Do While !((cAliasSD3)->(Eof()))
	If Interrupcao(@lEnd)
		Return Nil
	Endif

	If (cAliasSD3)->D3_CF$"PR0/PR1"
	    If !TRB1->(DbSeek((cAliasSB5)->B5_COD+SM0->M0_ESTENT+"SD3SM0"))
		    RecLock("TRB1",.T.)
			TRB1->PRODUTO	:= (cAliasSB5)->B5_COD
			TRB1->CLIFOR	:= "SD3SM0"
			TRB1->EMPRESA	:= SM0->M0_NOMECOM
			TRB1->MUN		:= SM0->M0_CIDENT
			TRB1->UF		:= SM0->M0_ESTENT
			TRB1->PAIS		:= ""
		Else
			RecLock("TRB1",.F.)
		EndIf
		TRB1->QTDE			+= (cAliasSD3)->D3_QUANT
	    MsUnlock()
	Else
		If !TRB2->(DbSeek((cAliasSB5)->B5_COD+SM0->M0_ESTENT+"SD3SM0"))
		    RecLock("TRB2",.T.)
			TRB2->PRODUTO	:= (cAliasSB5)->B5_COD
			TRB2->CLIFOR	:=	"SD3SM0"
			TRB2->EMPRESA	:= SM0->M0_NOMECOM
			TRB2->MUN		:= SM0->M0_CIDENT
			TRB2->UF		:= SM0->M0_ESTENT
			TRB2->PAIS		:= ""
		Else
			RecLock("TRB2",.F.)
		EndIf
		If (cAliasSD3)->D3_CF$"DE0/DE1/DE2/DE3/DE4/DE5/DE6/DE7"
			TRB2->QTDE		-= (cAliasSD3)->D3_QUANT
		Else
			TRB2->QTDE		+= (cAliasSD3)->D3_QUANT
		EndIf
	    MsUnlock()
	EndIf
	(cAliasSD3)->(dbSkip())
EndDo  

dbSelectArea(cAliasSD3)
dbCloseArea()

RestArea(aArea)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraRel   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Geracao dos dados para impressao                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GeraRel()

Local aProduto	:= {}
Local nI		:= 0

dbSelectArea("TRB")
dbSetOrder(1)
dbGoTop()
ProcRegua(LastRec())
While !Eof()
	IncRegua()
	If Interrupcao(lEnd)
		Return Nil
	Endif

 	If Len(aProduto) == 4
 		ImprRel(aProduto)
 	    aProduto := {}
 	Endif
 	AADD(aProduto,{TRB->PRODUTO,TRB->SLDANT,TRB->DESCRICAO})

	dbSelectArea("TRB")
	dbSkip()
Enddo
If Len(aProduto) > 0
	If Len(aProduto) < 4
		For nI := 1 To (4 - Len(aProduto))
			AADD(aProduto,{"",0,""})
		Next
	Endif
	ImprRel(aProduto)
Endif
Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ImprRel   ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao do Relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImprRel(aProduto)

Local cRM		:= RetRM(mv_par04)		//Retorna os estados pertencentes a RM - Regiao Militar
Local dDtIni	:= mv_par02
Local dDtFim	:= mv_par03
Local aL		:= Array(24)
Local nLin		:= 0
Local nX		:= 0
Local nI		:= 0
Local cTitulo	:= Upper(STR0004)+" - "+Ltrim(Str(mv_par04))+"ª RM - SFPC/2-10"
Local cCR		:= Alltrim(mv_par05)		//CR - Certificado de Registro
Local cPeriodo	:= RetPer(dDtIni,dDtFim)
Local aDados	:= {}
Local aSoma		:= {0,0,0,0}
Local aTotEn	:= {0,0,0,0}
Local aTotEnt	:= {}
Local aTotSa	:= {0,0,0,0}
Local aTotSai	:= {}
Local cAlias	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o LayOut                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LayOut(@aL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Imprime cabecalho                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Cabecalho(@nLin,cTitulo,aProduto,cCR,cPeriodo,aL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Entradas                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FmtLin(,aL[09],,,@nLin)	
FmtLin(,aL[05],,,@nLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Saldo Anterior                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FmtLin({aProduto[1,2],aProduto[2,2],aProduto[3,2],aProduto[4,2]},aL[10],,,@nLin)	
FmtLin(,aL[05],,,@nLin)
aTotEn[1] += aProduto[1,2]
aTotEn[2] += aProduto[2,2]
aTotEn[3] += aProduto[3,2]
aTotEn[4] += aProduto[4,2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao das Entradas / Saidas  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To 2	//1-Entradas e 2-Saidas

	cAlias := IIf(nX==1,"TRB1","TRB2")

	If nX == 2
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Saidas                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		++nLin
		FmtLin(,aL[05],,,@nLin)
		FmtLin(,aL[20],,,@nLin)	
		FmtLin(,aL[05],,,@nLin)
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Do/Para Exterior                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nX == 1	 //Entrada
		FmtLin(,aL[11],,,@nLin)
	Else
		FmtLin(,aL[21],,,@nLin)
	Endif
	FmtLin(,aL[19],,,@nLin)
	dbSelectArea(cAlias)
	aSoma := {0,0,0,0}
	For nI := 1 To 4
		If !Empty(aProduto[nI,1]) .And. dbSeek(aProduto[nI,1]+"EX")
			While !Eof() .And. (cAlias)->PRODUTO+(cAlias)->UF == aProduto[nI,1]+"EX"
				If nLin > 55
					FmtLin(,aL[05],,,@nLin)
					Cabecalho(@nLin,cTitulo,aProduto,cCR,cPeriodo,aL)
					If nX == 1		//Entrada
						FmtLin(,aL[09],,,@nLin)	
					Else 
						FmtLin(,aL[20],,,@nLin)					
					Endif
					FmtLin(,aL[05],,,@nLin)
				Endif
				aDados := {}			
				AADD(aDados,(cAlias)->EMPRESA)
				AADD(aDados,(cAlias)->PAIS)
				AADD(aDados,IIf(nI==1,(cAlias)->QTDE,0))
				AADD(aDados,IIf(nI==2,(cAlias)->QTDE,0))
				AADD(aDados,IIf(nI==3,(cAlias)->QTDE,0))
				AADD(aDados,IIf(nI==4,(cAlias)->QTDE,0))									
		
				aSoma[1] += aDados[3]
				aSoma[2] += aDados[4]
				aSoma[3] += aDados[5]
				aSoma[4] += aDados[6]
		
				If nX == 1	//Entrada
					aTotEn[1] += aDados[3]
					aTotEn[2] += aDados[4]
					aTotEn[3] += aDados[5]
					aTotEn[4] += aDados[6]
				Else
					aTotSa[1] += aDados[3]
					aTotSa[2] += aDados[4]
					aTotSa[3] += aDados[5]
					aTotSa[4] += aDados[6]
				Endif
				FmtLin(aDados,aL[12],,,@nLin)
				dbSelectArea(cAlias)
				dbSkip()
			Enddo
		Endif
	Next
	FmtLin(,aL[19],,,@nLin)
	FmtLin(aSoma,aL[13],,,@nLin)
	FmtLin(,aL[05],,,@nLin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Dos/Para Estados exceto a RM     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nX == 1		//Entrada
		FmtLin(,aL[14],,,@nLin)
	Else
		FmtLin(,aL[22],,,@nLin)	
	Endif
	FmtLin(,aL[19],,,@nLin)
	dbSelectArea(cAlias)
	dbGoTop()
	aSoma := {0,0,0,0}
	For nI := 1 To 4
		If !Empty(aProduto[nI,1]) .And. dbSeek(aProduto[nI,1])
			While !Eof() .And. (cAlias)->PRODUTO == aProduto[nI,1]
				If !((cAlias)->UF $ ("EX/"+cRM))
					If nLin > 55
						FmtLin(,aL[05],,,@nLin)
						Cabecalho(@nLin,cTitulo,aProduto,cCR,cPeriodo,aL)
						If nX == 1		//Entrada
							FmtLin(,aL[09],,,@nLin)	
						Else 
							FmtLin(,aL[20],,,@nLin)					
						Endif
						FmtLin(,aL[05],,,@nLin)
					Endif
					aDados := {}
					AADD(aDados,(cAlias)->EMPRESA)
					AADD(aDados,(cAlias)->MUN)
					AADD(aDados,(cAlias)->UF)				
					AADD(aDados,IIf(nI==1,(cAlias)->QTDE,0))
					AADD(aDados,IIf(nI==2,(cAlias)->QTDE,0))
					AADD(aDados,IIf(nI==3,(cAlias)->QTDE,0))
					AADD(aDados,IIf(nI==4,(cAlias)->QTDE,0))									
	
					aSoma[1] += aDados[4]
					aSoma[2] += aDados[5]
					aSoma[3] += aDados[6]
					aSoma[4] += aDados[7]												
	
					If nX == 1		//Entrada
						aTotEn[1] += aDados[4]
						aTotEn[2] += aDados[5]
						aTotEn[3] += aDados[6]
						aTotEn[4] += aDados[7]
					Else
						aTotSa[1] += aDados[4]
						aTotSa[2] += aDados[5]
						aTotSa[3] += aDados[6]
						aTotSa[4] += aDados[7]
					Endif				
					FmtLin(aDados,aL[16],,,@nLin)
				Endif
				dbSelectArea(cAlias)
				dbSkip()
			Enddo
		Endif
	Next
	FmtLin(,aL[19],,,@nLin)
	FmtLin(aSoma,aL[13],,,@nLin)
	FmtLin(,aL[05],,,@nLin)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Producao/Consumo na RM           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nX == 1		//Entrada
		FmtLin(,aL[15],,,@nLin)
	Else
		FmtLin(,aL[23],,,@nLin)
	Endif
	FmtLin(,aL[19],,,@nLin)
	dbSelectArea(cAlias)
	dbGoTop()
	aSoma := {0,0,0,0}
	For nI := 1 To 4
		If !Empty(aProduto[nI,1]) .And. dbSeek(aProduto[nI,1])
			While !Eof() .And. (cAlias)->PRODUTO == aProduto[nI,1]
				If (cAlias)->UF $ cRM
					If nLin > 55
						FmtLin(,aL[05],,,@nLin)
						Cabecalho(@nLin,cTitulo,aProduto,cCR,cPeriodo,aL)
						If nX == 1		//Entrada
							FmtLin(,aL[09],,,@nLin)	
						Else 
							FmtLin(,aL[20],,,@nLin)					
						Endif
						FmtLin(,aL[05],,,@nLin)
					Endif
					aDados := {}
					AADD(aDados,(cAlias)->EMPRESA)
					AADD(aDados,(cAlias)->MUN)
					AADD(aDados,(cAlias)->UF)
					AADD(aDados,IIf(nI==1,(cAlias)->QTDE,0))
					AADD(aDados,IIf(nI==2,(cAlias)->QTDE,0))
					AADD(aDados,IIf(nI==3,(cAlias)->QTDE,0))
					AADD(aDados,IIf(nI==4,(cAlias)->QTDE,0))									
	
					aSoma[1] += aDados[4]
					aSoma[2] += aDados[5]
					aSoma[3] += aDados[6]
					aSoma[4] += aDados[7]
					
					If nX == 1		//Entrada
						aTotEn[1] += aDados[4]
						aTotEn[2] += aDados[5]
						aTotEn[3] += aDados[6]
						aTotEn[4] += aDados[7]
					Else
						aTotSa[1] += aDados[4]
						aTotSa[2] += aDados[5]
						aTotSa[3] += aDados[6]
						aTotSa[4] += aDados[7]
					Endif
					FmtLin(aDados,aL[16],,,@nLin)
				Endif
				dbSelectArea(cAlias)
				dbSkip()
			Enddo
		Endif
	Next
	FmtLin(,aL[19],,,@nLin)
	FmtLin(aSoma,aL[13],,,@nLin)
	FmtLin(,aL[05],,,@nLin)

	If nX == 1
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Total das Entradas               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTotEnt := aClone(aTotEn)
		FmtLin(aTotEn,aL[17],,,@nLin)
		FmtLin(,aL[05],,,@nLin)
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Total das Saidas                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aTotSai := aClone(aTotSa)
		FmtLin(aTotSa,aL[24],,,@nLin)
		FmtLin(,aL[05],,,@nLin)
	Endif
	
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Saldo para trimestre seguinte    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
FmtLin({(aTotEnt[1]-aTotSai[1]),(aTotEnt[2]-aTotSai[2]),(aTotEnt[3]-aTotSai[3]),(aTotEnt[4]-aTotSai[4])},aL[18],,,@nLin)
FmtLin(,aL[05],,,@nLin)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³Cabecalho ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cabecalho do relatorio                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Cabecalho(nLin,cTitulo,aProduto,cCR,cPeriodo,aL)

nLin := Cabec(cTitulo,"","","MATR949",cTam,18)
++nLin
FmtLin({SM0->M0_NOMECOM},aL[01],,,@nLin)
FmtLin({SM0->M0_ENDENT},aL[02],,,@nLin)
FmtLin({SM0->M0_CIDENT,SM0->M0_BAIRENT,Transform(SM0->M0_CEPENT,"@R 99999-999"),SM0->M0_TEL},aL[03],,,@nLin)		
FmtLin({Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),Transform(SM0->M0_INSC,"@R 999.999.999.999"),cCR,cPeriodo},aL[04],,,@nLin)
++nLin
FmtLin(,aL[05],,,@nLin)	
FmtLin(,aL[06],,,@nLin)
FmtLin(,aL[07],,,@nLin)
FmtLin({aProduto[1,3],aProduto[2,3],aProduto[3,3],aProduto[4,3]},aL[08],,,@nLin)		
FmtLin(,aL[05],,,@nLin)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetRM     ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 16.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna as UF's que fazem parte da RM - Regiao Militar      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetRM(nRM)

Local cRet := "SP"

Do Case
	Case nRM == 1
		cRet := "RJ/ES"
	Case nRM == 2
		cRet := "SP"
	Case nRM == 3
		cRet := "RS"
	Case nRM == 4
		cRet := "MG"
	Case nRM == 5
		cRet := "PR/SC"							
	Case nRM == 6
		cRet := "BA"
	Case nRM == 7
		cRet := "RN/PB/PE/AL/SE"
	Case nRM == 8
		cRet := "PA/MA/AP"
	Case nRM == 9
		cRet := "MS/MT"
	Case nRM == 10
		cRet := "CE/PI"
	Case nRM == 11
		cRet := "DF/GO/TO"
	Case nRM == 12
		cRet := "AM/AC/RO/RR"								
EndCase

Return(cRet)

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

Local aStru := {}
Local cArq1 := ""
Local aDelArqs := {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TRB - Tabela de Produtos       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"PRODUTO"	,"C",015,0})	//Codigo do Produto
AADD(aStru,{"DESCRICAO"	,"C",030,0})	//Descricao do Produto
AADD(aStru,{"LOCAIS"	,"C",300,0})	//Locais de Armazenagem
AADD(aStru,{"SLDANT"	,"N",015,2})	//Saldo Anterior

oTmpTable1 := FWTemporaryTable():New( "TRB" )
oTmpTable1:SetFields( aStru )
oTmpTable1:AddIndex("indice1", {"PRODUTO"} )
oTmpTable1:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TRB1 - Tabela de Entradas       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
cArq1 := ""
AADD(aStru,{"PRODUTO"	,"C",15,0})								//Codigo do Produto
AADD(aStru,{"CLIFOR"	,"C",TamSx3("F3_CLIEFOR")[1],0})		//Codigo Cliente/Fornecedor
AADD(aStru,{"LOJA"		,"C",TamSx3("F3_LOJA")[1],0})			//Loja
AADD(aStru,{"EMPRESA"	,"C",40,0})								//Empresa
AADD(aStru,{"MUN"		,"C",15,0})	   							//Municipio da Empresa
AADD(aStru,{"UF"		,"C",02,0})								//UF da Empresa
AADD(aStru,{"PAIS"		,"C",25,0})	   							//Pais Origem e/ou Destino
AADD(aStru,{"QTDE"		,"N",15,2})	  							//Quantidade Entrada

oTmpTable2 := FWTemporaryTable():New( "TRB1" )
oTmpTable2:SetFields( aStru )
oTmpTable2:AddIndex("indice1", {"PRODUTO","UF","CLIFOR","LOJA"} )
oTmpTable2:Create()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TRB2 - Tabela de Saidas         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru := {}
cArq1 := ""
AADD(aStru,{"PRODUTO"	,"C",15,0})	 							//Codigo do Produto
AADD(aStru,{"CLIFOR"	,"C",TamSx3("F3_CLIEFOR")[1],0})		//Codigo Cliente/Fornecedor
AADD(aStru,{"LOJA"		,"C",TamSx3("F3_LOJA")[1],0})			//Loja
AADD(aStru,{"EMPRESA"	,"C",40,0})	  							//Empresa
AADD(aStru,{"MUN"		,"C",15,0})	 							//Municipio da Empresa
AADD(aStru,{"UF"		,"C",02,0})	  							//UF da Empresa
AADD(aStru,{"PAIS"		,"C",25,0})	   							//Pais Origem e/ou Destino
AADD(aStru,{"QTDE"		,"N",15,2})								//Quantidade Entrada

oTmpTable3 := FWTemporaryTable():New( "TRB2" )
oTmpTable3:SetFields( aStru )
oTmpTable3:AddIndex("indice1", {"PRODUTO","UF","CLIFOR","LOJA"} )
oTmpTable3:Create()


Return aDelArqs

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetPer    ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 13.03.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna o Periodo                                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetPer(dDtIni,dDtFim)

Local cRet := ""

If Month(dDtIni) == Month(dDtFim)
	cRet := Alltrim(Upper(MesExtenso(Month(dDtFim))))+"/"+Str(Year(dDtIni),4)
Else
	Do Case
		Case Month(dDtFim) == 3
			cRet := "01"+"/"+Str(Year(dDtFim),4)
		Case Month(dDtFim) == 6			
			cRet := "02"+"/"+Str(Year(dDtFim),4)
		Case Month(dDtFim) == 9			
			cRet := "03"+"/"+Str(Year(dDtFim),4)
		Case Month(dDtFim) == 12		
			cRet := "04"+"/"+Str(Year(dDtFim),4)
	EndCase
Endif

Return(cRet)

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

aL[01] := OemToAnsi(STR0005)	//"Empresa: ##################################################"
aL[02] := OemToAnsi(STR0006)	//"Local Licenciado: ########################################"
aL[03] := OemToAnsi(STR0007)	//"Cidade: ####################      Bairro: ####################      Cep.: #########"
aL[04] := OemToAnsi(STR0008)	//"CGC: ##.###.###/####-##           INSCRICAO ESTADUAL: ###.###.###.###      CR No.: #########      TRIMESTRE: ###############"
aL[05] := OemToAnsi(STR0009)	//"+----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+"
aL[06] := OemToAnsi(STR0010)	//"|                        P R O C E D E N C I A                         |                              ARMAS, MUNICOES, EXPLOSIVOS E SEUS ELEMENTOS E OUTROS PRODUTOS CONTROLADOS                           |"
aL[07] := OemToAnsi(STR0011)	//"|                                  E                                   |-----------------------------------------------------------------------------------------------------------------------------------|"
aL[08] := OemToAnsi(STR0012)	//"|                            D E S T I N O                             | ############################## | ############################## | ############################## | ############################## |"
aL[09] := OemToAnsi(STR0013)	//"|                                                                                     E   N   T   R   A   D   A   S                                                                                        |"
aL[10] := OemToAnsi(STR0015)	//"| T O T A L   D O   T R I M E S T R E   A N T E R I O R                |                ############### |                ############### |                ############### |                ############### |"
aL[11] := OemToAnsi(STR0016)	//"| D O   E X T E R I O R                                                |                                |                                |                                |                                |"
aL[12] := OemToAnsi(STR0018)	//"| ######################################## | #################### |    |                ############### |                ############### |                ############### |                ############### |"
aL[13] := OemToAnsi(STR0019)	//"| S O M A                                                              |                ############### |                ############### |                ############### |                ############### |"
aL[14] := OemToAnsi(STR0020)	//"| D O S   E S T A D O S                                                |                                |                                |                                |                                |"
aL[15] := OemToAnsi(STR0023)	//"| P R O D U C A O   N A   R M                                          |                                |                                |                                |                                |"
aL[16] := OemToAnsi(STR0022)	//"| ######################################## | #################### | ## |                ############### |                ############### |                ############### |                ############### |"		
aL[17] := OemToAnsi(STR0025)	//"| T O T A L   D A S   E N T R A D A S                                  |                ############### |                ############### |                ############### |                ############### |"
aL[18] := OemToAnsi(STR0030)	//"| S A L D O  P A R A  O  T R I M E S T R E  S E G U I N T E            |                ############### |                ############### |                ############### |                ############### |"
aL[19] := OemToAnsi(STR0031)	//"|----------------------------------------------------------------------|--------------------------------|--------------------------------|--------------------------------|--------------------------------|"
aL[20] := OemToAnsi(STR0014)	//"|                                                                                              S A I D A S                                                                                                 |"
aL[21] := OemToAnsi(STR0017)	//"| P A R A   O   E X T E R I O R                                        |                                |                                |                                |                                |"
aL[22] := OemToAnsi(STR0021)	//"| P A R A   O S   E S T A D O S                                        |                                |                                |                                |                                |"
aL[23] := OemToAnsi(STR0024)	//"| C O N S U M O   N A   R M                                            |                                |                                |                                |                                |"
aL[24] := OemToAnsi(STR0026)	//"| T O T A L   D A S   S A I D A S                                      |                ############### |                ############### |                ############### |                ############### |"
								
Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mtr949Str ºAutor  ³Gustavo G. Rueda    º Data ³ 17/05/2007  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar um array apenas com os campos utiLizados na query    º±±
±±º          ³para passagem na funcao TCSETFIELD                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³aCampos: campos a serem tratados na query                   º±±
±±º          ³cCmpQry: string contendo os campos para select na query     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR949                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                       
Static Function Mtr949Str(aCampos,cCmpQry)

Local	aRet		:=	{}
Local	nX			:=	0
Local	aTamSx3		:=	{}   
Local	cFieldPos	:= ""

For nX := 1 To Len(aCampos)
	cFieldPos := aCampos[nX][01] + '->' + '(FieldPos("' + aCampos[nX][02] + '"))'
	If &(cFieldPos) > 0
		aTamSx3 := TamSX3(aCampos[nX][02])
		aAdd (aRet,{aCampos[nX][02],aTamSx3[3],aTamSx3[1],aTamSx3[2]})
		cCmpQry	+=	aCampos[nX][01] + "." + aCampos[nX][02] + ", "
	EndIf
Next(nX)

If(Len(cCmpQry)>0)
	cCmpQry	:=	" " + SubStr(cCmpQry,1,Len(cCmpQry)-2) + " "
EndIf 
Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Mtr949Est ³ Autor ³ Gustavo G. Rueda      ³ Data ³28/03/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Gera os arquivos temporarios com os movimentos de estoque   ³±±
±±³          ³no inicio e no final do periodo.                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1 = Tipo (1 - gera arquivos / 2 - deleta gerados)       ³±±
±±³          ³ExpD2 = Data inicial de geracao das informacoes             ³±±
±±³          ³ExpD3 = Data final de geracao das informacoes               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Matr947                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mtr949Est(nTipo,dDtIni,dDtFim)
Local cCpoB5	:= GetNewPar("MV_MTR949A","")
Local cArqAnt 	:= ""
Local dDtAnt  	:= FirstDay(dDtIni)-1
Local cFiltraB5	:= ""    

// Indicacao de produto controlado ou nao				
If !Empty(cCpoB5) .And. SB5->(FieldPos(cCpoB5)) > 0
	cFiltraB5 += " AND SB5." + Alltrim(cCpoB5) + " = 'S'"       
Endif          


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cria os arquivos temporarios com o estoque inicial/final dos produtos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nTipo == 1 // Gera os temporarios com o estoque inicial/final

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ TMP - Estoque Anterior                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	FsEstInv({"TMP",""},1,.T.,.F.,dDtAnt,.F.,,.T.,cFiltraB5)
	dbSelectArea("TMP")
	cArqAnt := CriaTrab(NIL,.F.)
	IndRegua("TMP",cArqAnt,"CODIGO")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Exclui os temporarios criados com o estoque final e inicial³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Else
	FsEstInv({"TMP",""},2,,,dDtAnt,.F.,,.T.,cFiltraB5)	//Estoque Anterior
Endif
Return .T.