#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³GeraINV   ³ Autor ³Andressa ATaides       ³ Data ³ 15.04.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Gera Registro INV e EST - Inventario			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GeraINV(dDtInicial,dDtFinal,cSimples)

Local aArea   := GetArea()
Local aRet	  := {}
Local aStru   := {}
Local cArq 	  := ""
Local nAliq   := 0
Local nPrec   := 0
Local nIVA 	  := 0
Local nPrecFi := 0
Local nIcmsIVA := 0
Local nValTot  := 0
Local nMVICMPAD	:= SuperGetMV("MV_ICMPAD",,0)
Local aCat44   := {}   
DEFAULT cSimples := "2"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Array para montagem de tabela temporaria (TRB)          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aStru	:=	{}
aAdd (aStru,{"INV_CODI",	"C",	030,	0})
aAdd (aStru,{"INV_QTDE",	"N",	014,	3})
aAdd (aStru,{"INV_VRUN",	"N",	014,	2})	
aAdd (aStru,{"INV_TOT" ,	"N",	014,	2})	
aAdd (aStru,{"INV_ALIQ",    "N",	005,	2})
aAdd (aStru,{"INV_IVA  ",   "N",	006,	2})
aAdd (aStru,{"INV_PRFIN" ,	"N",	014,	2})	
aAdd (aStru,{"INV_VLICM" ,	"N",	014,	2})	
aAdd (aStru,{"INV_CODTP",   "C",	003,	0}) 
aAdd (aStru,{"INV_DESC",    "C",	030,	0})
aAdd (aStru,{"INV_UM",      "C",	002,	0})

cArq	:=	CriaTrab (aStru)
DbUseArea (.T., __LocalDriver, cArq, "INV")
IndRegua ("INV", cArq, "INV_CODI")
aAdd (aRet, {cArq, "INV"})

//Gravacao do Registro Inventario
//MV_PAR02 -> Data de Levantamento do Estoque (Conforme Anexo II)
FsEstInv({"ARQ",""},1,,,dDtFinal,,.F.,.T.)

dbSelectArea("SD1")
dbSetOrder(2)
ARQ->(DbGoTop())
Do While !ARQ->(Eof())
	If (SB1->(DbSeek(xFilial("SB1" )+ARQ->CODIGO))) .And. ARQ->QUANT>0
	
		If ExistBlock ("PRCAT44")
			aCat44   := ExecBlock("PRCAT44",.F.,.F.,{ARQ->CODIGO,Iif(SB1->B1_PICM<>0,SB1->B1_PICM,nMVICMPAD),SB1->B1_UPRC,SB1->B1_PICMENT,SB1->B1_PRV1}) 
			nAliq 	 := Iif(aCat44[1]<>0,aCat44[1],nMVICMPAD)
			nPrec	 := aCat44[2]     // Ultimo Preco de Compra
			nIVA	 := aCat44[3]     // Margem de Valor Agregado
			nPrecFi  := aCat44[4]	  // Preco Final
			nValTot  := (ARQ->QUANT * nPrec)
			IF "1" $ cSimples 
				// Calculo do Valor Devido quando se tratar de optante do Simples Nacional
				nIcmsIVA := Iif(nIVA>0,((((nValTot*nIVA)/100))*nAliq)/100,0)		 					
			Else                                                                       
				// Calculo do Valor Devido quando se tratar de optandte do Regime Periodico de Apuracao - RPA:
				nIcmsIVA := Iif(nIVA>0,((((nValTot*nIVA)/100)+nValTot)*nAliq)/100,0)		 	
			EndIf
		Else
			nAliq 	 	:= Iif(SB1->B1_PICM<>0,SB1->B1_PICM,nMVICMPAD)
			nPrec	 	:= Cat44Comp(ARQ->CODIGO,dDtInicial,dDtFinal)
			nIVA	 	:= SB1->B1_PICMENT  // Margem de Valor Agregado
			nPrecFi  	:= SB1->B1_PRV1		// Preco Final
			nValTot  	:= (ARQ->QUANT * nPrec)
			IF "1" $ cSimples 
				// Calculo do Valor Devido quando se tratar de optante do Simples Nacional
				nIcmsIVA := Iif(nIVA>0,((((nValTot*nIVA)/100))*nAliq)/100,0)		 					
			Else                                                                       
				// Calculo do Valor Devido quando se tratar de optandte do Regime Periodico de Apuracao - RPA:
				nIcmsIVA := Iif(nIVA>0,((((nValTot*nIVA)/100)+nValTot)*nAliq)/100,0)		 	
			EndIf
		EndIf  
	
		SB5->(dbSetOrder(1))
		If SB5->(DbSeek(xFilial("SB5")+ARQ->CODIGO))
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Somente processa se o campo B5_CODTP for preenchido com o   ³
			//³Codigo do Tipo da Mercadoria conforme Anexo II.             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
        	If !Empty(SB5->B5_CODTP)
		   		RecLock ("INV", .T.)
					INV->INV_CODI	:= ARQ->CODIGO
					INV->INV_QTDE	:= ARQ->QUANT
					INV->INV_VRUN	:= nPrec
					INV->INV_TOT	:= nValTot
					INV->INV_ALIQ   := Iif(SB5->B5_ISEN=="1",0,nAliq)
					INV->INV_IVA    := Iif(nIva>0,nIva,0)
					INV->INV_PRFIN	:= Iif(nIva>0,0,nPrecFi)
					INV->INV_VLICM  := Iif(nIva>0,nIcmsIVA,(nValTot*nAliq)/100)
					INV->INV_CODTP  := SB5->B5_CODTP
					INV->INV_DESC   := ARQ->DESC_PRD
					INV->INV_UM     := ARQ->UM
				MsUnLock ()	
			_aTotal[005]+=	1
			Endif	
		Endif
	Endif
	ARQ->(DbSkip())
Enddo
									
FsEstInv({"ARQ",""},2)
RestArea(aArea)

Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Cat44Comp ºAutor  ³Microsiga           º Data ³  06/26/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna a ultima compra de um produto a partir de uma data  º±±
±±º          ³de fechamento de estoque.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³CAT44                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Cat44Comp(cCodProd,dDtInicial,dDtFinal)

Local nPreco 	:= 0
Local cAliasSD1 := "SD1"

#IFDEF TOP
	Local cQuery	:= "" 
	Local aStruSD1 	:= {}
	Local nX		:= 0
#ELSE
	Local cIndex	:= ""
	Local cCondicao	:= ""  
	Local cKey		:= "" 
	Local nIndex	:= 0              
#ENDIF

SD2->(dbSetOrder(1))

#IFDEF TOP
    If TcSrvType()<>"AS/400"
		cAliasSD1 := GetNextAlias()
		aStruSD1  := SD1->(dbStruct())
		cQuery := "SELECT D1_VUNIT, D1_VALIPI, D1_VALFRE, D1_SEGURO, D1_DESPESA, D1_QUANT "
		cQuery += "FROM " + RetSqlName("SD1") + " "
		cQuery += "WHERE D1_FILIAL='" + xFilial("SD1") + "' AND "
		cQuery += "D1_COD = '" + cCodProd + "' AND "
		cQuery += "D1_DTDIGIT <= '" + Dtos(dDtFinal) + "' AND "
		cQuery += "D_E_L_E_T_ = ' ' "
		cQuery += "ORDER BY D1_DTDIGIT DESC "
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD1)
		For nX := 1 To len(aStruSD1)
			If aStruSD1[nX][2] <> "C" 
				TcSetField(cAliasSD1,aStruSD1[nX][1],aStruSD1[nX][2],aStruSD1[nX][3],aStruSD1[nX][4])
			EndIf
		Next nX
		dbSelectArea(cAliasSD1)	
	Else
#ENDIF
	    cIndex    := CriaTrab(NIL,.F.)
	    cKey	  := 'dtos(D1_DTDIGIT)'
	    cCondicao := 'D1_FILIAL=="'+xFilial("SD1")+'".And.'
		cCondicao += 'D1_COD == "' + cCodProd+'".And.'
	   	cCondicao += 'DTOS(D1_DTDIGIT)<="'+DTOS(dDtFinal)+'"'
	    IndRegua(cAliasSD1,cIndex,SD1->(IndexKey()),,cCondicao)
	    nIndex := RetIndex("SD1")
		#IFNDEF TOP
			dbSetIndex(cIndex+OrdBagExt())
		#ENDIF
		dbSelectArea("SD1")
	    dbSetOrder(nIndex+1)
	    dbSelectArea(cAliasSD1)
	    dbGoBottom()
#IFDEF TOP
	Endif    
#ENDIF

nPreco := Round((cAliasSD1)->(D1_VUNIT + (((cAliasSD1)->(D1_VALIPI + D1_VALFRE + D1_SEGURO + D1_DESPESA))/(cAliasSD1)->D1_QUANT)) ,2)

#IFDEF TOP
	dbSelectArea(cAliasSD1)
	dbCloseArea()
#ELSE
	dbSelectArea(cAliasSD1)
	RetIndex(cAliasSD1)
	Ferase(cIndex+OrdBagExt())
#ENDIF

Return nPreco
