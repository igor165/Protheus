#Include "Protheus.Ch"
/*/                
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³PORT35SC  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 01.04.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Preparacao do meio-magnetico para o PORT35SC                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
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
Function Port35SC()

Local aStru		:= {}
Local cArq		:= ""
Local aSF3		:= {"SF3",""}
Local cDbf		:= "F3_FILIAL=='"+ xFilial("SF3") +"' .And. DTOS(F3_ENTRADA)>='"+ DTOS(MV_PAR01) +"' .And. DTOS(F3_ENTRADA)<='"+ DTOS(MV_PAR02) +"' .And. Left(SF3->F3_CFO,1) < '5' .And. F3_TIPO<>'S'"
Local cTop		:= "F3_FILIAL='"+xFilial("SF3")+"' AND F3_ENTRADA>='"+ DTOS(MV_PAR01) +"' AND F3_ENTRADA<='"+ DTOS(MV_PAR02) +"' AND (F3_CFO LIKE '1%' OR F3_CFO LIKE '2%' OR F3_CFO LIKE '3%') AND F3_TIPO<>'S'"
Local nCredPis	:= 0
Local nCredCof	:= 0
Local cCNPJ		:= ""
Local cSeek		:= ""
Local cNumDoc	:= ""
Local cSerie	:= ""
Local cFornece	:= ""
Local cLoja		:= ""
Local cDtEmis	:= ""
Local cDtEnt	:= ""
Local cCfop		:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ R01 - Notas Fiscais de Entrada               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AADD(aStru,{"CNPJ"		,"C",014,0})
AADD(aStru,{"NUMDOC"	,"C",TamSX3("F2_DOC")[1],0})
AADD(aStru,{"SERIE"		,"C",003,0})
AADD(aStru,{"FORNECE"	,"C",006,0})
AADD(aStru,{"LOJA"		,"C",002,0})
AADD(aStru,{"DTEMIS"	,"C",008,0})
AADD(aStru,{"DTENT"		,"C",008,0})
AADD(aStru,{"CFOP"		,"C",004,0})
AADD(aStru,{"VALCONT"	,"N",014,2})
AADD(aStru,{"VALIPI"	,"N",014,2})
AADD(aStru,{"CREDPIS"	,"N",014,2})
AADD(aStru,{"CREDCOF"	,"N",014,2})
AADD(aStru,{"SDOC"		,"C",003,0})

cArq := CriaTrab(aStru)
dbUseArea(.T.,__LocalDriver,cArq,"R01")
IndRegua("R01",cArq,"NUMDOC+SERIE+FORNECE+LOJA+CFOP")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posicionamento das tabelas                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SA1->(dbSetOrder(1))
SA2->(dbSetOrder(1))
		
dbSelectArea("SF3")
dbSetOrder(1)
FsQuery(aSF3,1,cTop,cDbf,IndexKey())
dbGoTop()
While !Eof()
	cCNPJ		:= ""
	nCredPis	:= 0
	nCredCof	:= 0
	cCfop		:= Alltrim(SF3->F3_CFO)		
	cSeek		:= SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA
	cNumDoc		:= SF3->F3_NFISCAL
	cSerie		:= IIf(Left(SF3->F3_SERIE,1)=="U","U  ",SF3->F3_SERIE)
	cFornece	:= SF3->F3_CLIEFOR
	cLoja		:= SF3->F3_LOJA
	cDtEmis		:= DataInt(SF3->F3_EMISSAO)
	cDtEnt		:= DataInt(SF3->F3_ENTRADA)

	If SF3->F3_TIPO $ "DB"
		If SA1->(dbSeek(xFilial("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			cCNPJ := StrZero(Val(aRetDig(IIf(SF3->F3_ESTADO=="EX",SM0->M0_CGC,SA1->A1_CGC),.F.)),14)
		Endif
	Else
		If SA2->(dbSeek(xFilial("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
			cCNPJ := StrZero(Val(aRetDig(IIf(SF3->F3_ESTADO=="EX",SM0->M0_CGC,SA2->A2_CGC),.F.)),14)
		Endif
	Endif

	dbSelectArea("R01")
	dbSetOrder(1)
	If Empty(SF3->F3_DTCANC)                                  
		If !dbSeek(cNumDoc+cSerie+cFornece+cLoja+cCfop)
			RecLock("R01",.T.)
			R01->CNPJ		:= cCNPJ
			R01->NUMDOC		:= cNumDoc
			R01->SERIE		:= cSerie
			R01->FORNECE	:= cFornece
			R01->LOJA		:= cLoja		
			R01->DTEMIS		:= cDtEmis
			R01->DTENT		:= cDtEnt
			R01->CFOP		:= cCfop
			R01->VALCONT	:= SF3->F3_VALCONT
			R01->VALIPI		:= SF3->F3_VALIPI
			R01->SDOC       := SerieNfId("SF3",2,"F3_SERIE")
	
			RetPisCof(cSeek,cCfop,@nCredPis,@nCredCof)
			R01->CREDPIS	:= nCredPis
			R01->CREDCOF	:= nCredCof
		Else
			RecLock("R01",.F.)
			R01->VALCONT	+= SF3->F3_VALCONT
			R01->VALIPI		+= SF3->F3_VALIPI
		Endif
	EndIf
	MsUnlock()
	
	dbSelectArea("SF3")
	dbSkip()
Enddo
FsQuery(aSF3,2)

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³RetPisCof  ³ Autor ³Sergio S. Fuzinaka     ³ Data ³ 26.12.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Retorna os creditos de PIS e COFINS                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function RetPisCof(cSeek,cCfop,nCredPis,nCredCof)

Local aArea := GetArea()

dbSelectArea("SD1")
dbSetOrder(1)
If dbSeek(xFilial("SD1")+cSeek)
	While !Eof() .And. D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA == xFilial("SD1")+cSeek
		If Alltrim(D1_CF) == cCfop
			nCredCof += SD1->D1_VALIMP5
			nCredPis += SD1->D1_VALIMP6
		Endif
		dbSelectArea("SD1")
		dbSkip()
	Enddo
Endif

RestArea(aArea)

Return(.T.)

