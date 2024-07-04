#include "Protheus.Ch"
#include "GCPA008.Ch"

Static lLGPD := FindFunction("SuprLGPD") .And. SuprLGPD()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  GCPA008 ºAutor  ³ Totvs              º Data ³  23/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para verificar o saldo dos itens                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GCP - Gestão de Compras Publicas                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GCPSldItem(cAcao,aSldItem)
Local aAreaAnt:= GetArea()
Local aAreaSC7:= {}
Local cQuery  := ""
Local cCodEdt := ""
Local cNumPr  := ""
Local cCdProd := ""
Local nRet    := 0

Default cAcao := "1"
Default aSldItem := {}

If	cAcao == "1"
	nRet := CO2->CO2_QUANT
	If (CO1->CO1_REMAN .And. (CO1->CO1_MODALI<>"CC" .Or. (CO1->CO1_MODALI=="CC" .And. CO1->CO1_PASSO<>"20")))
		cQuery += "SELECT "
		
		If CO1->CO1_COPC == "2" .AND. CO1->CO1_GERDOC == "1"
			cQuery += "DISTINCT SC7.C7_CODED,SC7.C7_NUMPR,SC7.C7_RESREM,SC7.C7_PRODUTO,SC7.C7_QUANT QUANT,SC7.C7_QUJE QUJE "
		ElseIf CO1->CO1_COPC == "2" .AND. CO1->CO1_GERDOC == "2"
			cQuery += "SUM(SC6.C6_QTDVEN - SC6.C6_QTDENT) AS SLDREM "
		ElseIf CO1->CO1_COPC == "1"
			cQuery += "MAX(CNB.CNB_SLDREC) AS SLDREM "
		EndIf
		
		cQuery += "FROM " +RetSqlName("CO3") +" CO3 "
		
		Do Case
		Case CO1->CO1_COPC == "2" .AND. CO1->CO1_GERDOC == "1"
			cQuery += "JOIN " +RetSQLName("SC7") + " SC7 ON SC7.D_E_L_E_T_ <> '*' AND "
			If SC7->(FieldPos("C7_FISCORI")) == 0
				cQuery += "SC7.C7_FILIAL = '" +xFilial("SC7") +"' AND "
			Else
				cQuery += "CASE SC7.C7_FISCORI WHEN '" +Space(FWSizeFilial()) +"' THEN SC7.C7_FILIAL "
				cQuery += "ELSE SC7.C7_FISCORI END = '" +xFilial("SC7") +"' AND "
			EndIf
			cQuery += "SC7.C7_CODED = '" +CO1->CO1_CODEDT +"' AND SC7.C7_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
			cQuery += "SC7.C7_RESREM <> 'S' AND SC7.C7_PRODUTO = CO3.CO3_CODPRO"	
		Case CO1->CO1_COPC == "2" .AND. CO1->CO1_GERDOC == "2"
			cQuery += "JOIN " +RetSQLName("SC5") + " SC5 ON SC5.D_E_L_E_T_ <> '*' AND SC5.C5_FILIAL = '" +xFilial("SC5") +"' AND "
			cQuery += "SC5.C5_CODED = '" +CO1->CO1_CODEDT +"' AND SC5.C5_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
			cQuery += "SC5.C5_RESREM <> 'S' "
			
			cQuery += "JOIN " +RetSQLName("SC6") + " SC6 ON SC6.D_E_L_E_T_ <> '*' AND SC6.C6_FILIAL = '" +xFilial("SC6") +"' AND "
			cQuery += "SC6.C6_NUM = SC5.C5_NUM AND SC6.C6_PRODUTO = CO3.CO3_CODPRO "
		Case CO1->CO1_COPC == "1"
			cQuery += "JOIN " +RetSQLName("CN9") + " CN9 ON CN9.D_E_L_E_T_ <> '*' AND "
			If CN9->(FieldPos("CN9_FILORI")) == 0
				cQuery += "CN9.CN9_FILIAL = '" +xFilial("CN9") +"' AND "
			Else
				cQuery += "CN9.CN9_FILORI = '" +xFilial("CN9") +"' AND "
			EndIf
			cQuery += "CN9.CN9_CODED = '" +CO1->CO1_CODEDT +"' AND CN9.CN9_NUMPR = '" +CO1->CO1_NUMPRO +"' AND "
			cQuery += "CN9.CN9_REVATU = '" +Space(TamSX3("CN9_REVATU")[1]) +"' AND CN9.CN9_RESREM <> 'S' "
			
			cQuery += "JOIN " +RetSQLName("CNB") + " CNB ON CNB.D_E_L_E_T_ <> '*' AND "
			If CNB->(FieldPos("CNB_FILORI")) == 0
				cQuery += "CNB.CNB_FILIAL = '" +xFilial("CNB") +"' AND "
			Else
				cQuery += "CNB.CNB_FILORI = '" +xFilial("CNB") +"' AND "
			EndIf
			cQuery += "CNB.CNB_CONTRA = CN9.CN9_NUMERO AND CNB.CNB_REVISA = CN9.CN9_REVISA AND CNB.CNB_PRODUT = CO3.CO3_CODPRO "
		EndCase
		
		cQuery += "WHERE CO3.D_E_L_E_T_ <> '*' AND CO3.CO3_FILIAL = '" +xFilial("CO3") +"' AND "
		cQuery += "CO3.CO3_CODEDT = '" +CO1->CO1_CODEDT +"' AND CO3.CO3_NUMPRO = '" +CO1->CO1_NUMPRO +"' AND "
		cQuery += "CO3.CO3_REVOGA <> '1' AND "
		If	( CO1->CO1_MODALI $ "IN" )
			cQuery += "CO3.CO3_CLASS = 'X' AND CO3.CO3_CLAANT = ' ' AND CO3.CO3_CODPRO = '" +CO2->CO2_CODPRO +"'"
		Else
			//-- Aqui tenho duas etapas, a primeira eh a Escolha do ganhador quando estou no passo 07...
			If	AllTrim(CO1->CO1_PASSO)=="07" .Or. (CO1->CO1_MODALI=="CV" .And. CO1->CO1_PASSO=="20") .Or.;
			 	(CO1->CO1_MODALI=="DL" .And. CO1->CO1_TIPO=="DV" .And. CO1->CO1_PASSO=="20") .Or.;
			 	(CO1->CO1_MODALI=="DL" .And. CO1->CO1_TIPO=="DE" .And. CO1->CO1_PASSO=="36") .Or.;
			 	(CO1->CO1_MODALI=="DL" .And. CO1->CO1_TIPO=="AA" .And. CO1->CO1_PASSO=="36") .Or.;
			 	(CO1->CO1_MODALI=="DL" .And. CO1->CO1_TIPO=="DR" .And. CO1->CO1_PASSO=="32")
				cQuery += "CO3.CO3_CLASS = 'X' AND CO3.CO3_CLAANT = ' ' AND CO3.CO3_CODPRO = '" +CO2->CO2_CODPRO +"'"
			Else
				//-- ... a segunda eh para a rotina buscar o ganhador ja informado, quando estou no passo 11.
				//-- Quando remanescente e a modalidade for Pregao, buscar o fornecedor que ja foi informado no passo 07.
				cQuery += "CO3.CO3_CLASS = '1' AND CO3.CO3_CLAANT = '1' AND CO3.CO3_CODPRO = '" +CO2->CO2_CODPRO +"'"
			EndIf
		EndIf
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"SLDREM")
		
		If	CO1->CO1_COPC == "2" .AND. CO1->CO1_GERDOC == "1"
			nRet := SLDREM->QUANT - SLDREM->QUJE
		ElseIf CO1->CO1_COPC == "2" .AND. CO1->CO1_GERDOC == "2"
			nRet := SLDREM->SLDREM
		ElseIf CO1->CO1_COPC == "1"
			nRet := SLDREM->SLDREM
		EndIf
		
		SLDREM->(dbCloseArea())
	EndIf

//-- Executado pela funcao A103TemBlq
//-- Obtem a quantidade ja entregue de todos os pedidos de compras do Edital.
ElseIf cAcao == "2"
	aAreaSC7 := SC7->(GetArea())
	If	SC7->(FieldPos("C7_CODED"))>0 .And. !Empty(SC7->C7_CODED)
		cCodEdt	:= SC7->C7_CODED
		cNumPr	:= SC7->C7_NUMPR
		cCdProd := SC7->C7_PRODUTO  

		CO1->(DbSetOrder(1))
		If	CO1->(DbSeek(xFilial("CO1")+cCodEdt+cNumPr)) .And. CO1->CO1_REMAN
			
			BeginSQL Alias "SLDREM"
			
			SELECT SUM(SC7.C7_QUJE) nQuJE, SUM(SC7.C7_QTDACLA) nQaCl
			
			FROM %table:SC7% SC7
			
			WHERE SC7.C7_FILIAL = %xfilial:SC7%
				AND SC7.C7_CODED = %exp:cCodEdt%
				AND SC7.C7_NUMPR = %exp:cNumPr%
				AND SC7.C7_PRODUTO = %exp:cCdProd%
				AND SC7.%NotDel%
			
			EndSql
			aSldItem := {0,0,0}
			aSldItem[1] := SLDREM->nQuJE
			aSldItem[2] := SLDREM->nQaCl
			
			SLDREM->(DbCloseArea())
			
			aSldItem[3] := SomaCO2(cCodEdt,cNumPr,cCdProd)
			
		EndIf
	EndIf
	RestArea(aAreaSC7)

ElseIf	cAcao == "3"

	aAreaSC7 := SC7->(GetArea())
	cCodEdt	:= aSldItem[1]
	cNumPr	:= aSldItem[2]
	cCdProd := aSldItem[3]
	aSldItem := {0,0,0}

	If	SC7->(FieldPos("C7_CODED"))>0 .And. !Empty(SC7->C7_CODED)
		BeginSQL Alias "SLDREM"

		SELECT SC7.C7_QUJE nQuJE
		
		FROM %table:SC7% SC7
		
		WHERE SC7.C7_FILIAL = %xfilial:SC7%
			AND SC7.C7_CODED = %exp:cCodEdt%
			AND SC7.C7_NUMPR = %exp:cNumPr%
			AND SC7.C7_PRODUTO = %exp:cCdProd%
			AND SC7.%NotDel%

		EndSql
		If	SLDREM->(!Eof())
			aSldItem := {SLDREM->nQuJE,0,0}
		EndIf
		SLDREM->(DbCloseArea())
	EndIf
	RestArea(aAreaSC7)

EndIf
RestArea(aAreaAnt)	
Return nRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³  GCPA008 ºAutor  ³ Totvs              º Data ³  23/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao para validar todos os vencedores informados         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GCP - Gestão de Compras Publicas                           º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function GCPChkCO3(cAcao,cCodEdt,cNumPro,cPrdEdt,cModali,aRet)
Local cTxtFor	:= STR0024 //"Fornecedor"
Local cTxtPFor	:= STR0025 //"Pre-Fornecedor"
Local lRet		:= .T.

DEFAULT cPrdEdt:= ""
DEFAULT cModali	:= ""
DEFAULT aRet	:= {}

//-- Posiciona CO3
If	cAcao=="1"
	CO3->(DbSetOrder(1))
	lRet := CO3->(DbSeek(xFilial("CO3")+cCodEdt+cNumPro+cPrdEdt))
//-- Retorna informacoes cadastrais do licitante
ElseIf cAcao=="2"
	If	CO3->CO3_TIPO=="1"
		cNome := Posicione("CO6",1,xFilial("CO6")+CO3->CO3_CODIGO+CO3->CO3_LOJA,"CO6_NOME")
		If(lLGPD,RetTxtLGPD(@cNome,"CO6_NOME"),cNome)
		cTipo := cTxtPFor
	Else
		If	cModali == "LL"
			cNome := Posicione("SA1",1,xFilial("SA1")+CO3->CO3_CODIGO+CO3->CO3_LOJA,"A1_NOME")
			If(lLGPD,RetTxtLGPD(@cNome,"A1_NOME"),cNome)				
		Else
			SA2->(DbSetOrder(1))
			SA2->(MsSeek(xFilial("SA2")+CO3->CO3_CODIGO+CO3->CO3_LOJA))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_NOME,"A2_NOME"),SA2->A2_NOME))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_CGC,"A2_CGC"),SA2->A2_CGC))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_END,"A2_END"),SA2->A2_END))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_NR_END,"A2_NR_END"),SA2->A2_NR_END))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_BAIRRO,"A2_BAIRRO"),SA2->A2_BAIRRO))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_MUN,"A2_MUN"),SA2->A2_MUN))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_EST,"A2_EST"),SA2->A2_EST))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_CEP,"A2_CEP"),SA2->A2_CEP))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_DDD,"A2_DDD"),SA2->A2_DDD))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_TEL,"A2_TEL"),SA2->A2_TEL))
			AAdd(aRet,If(lLGPD,RetTxtLGPD(SA2->A2_EMAIL,"A2_EMAIL"),SA2->A2_EMAIL))
		EndIf
		cTipo := cTxtFor
	EndIf
//-- Verifica se o licitante ganhador foi informado
ElseIf cAcao=="3"
	lRet := .F.
	CO3->(DbSetOrder(1))
	CO3->(DbSeek(xFilial("CO3")+cCodEdt+cNumPro))
	While CO3->(!Eof() .And. CO3->CO3_FILIAL+CO3->CO3_CODEDT+CO3->CO3_NUMPRO==xFilial("CO3")+cCodEdt+cNumPro)
		If	CO3->CO3_CLASS == "1"
			lRet := .T.
			Exit
		EndIf
		CO3->(DbSkip())
	EndDo
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} SomaCO2()
Rotina que realiza a soma das quantidade de todos os itens do edital.
Rotina acionada pelo GCPA008 que verifica o saldo dos itens.

@author antenor.silva
@since 25/05/2016
@return Nil
/*/
//------------------------------------------------------------------
Function SomaCO2(cCodEdt,cNumPr,cCodPro)
Local nTotalCO2	:= 0  

BeginSQL Alias "SOMACO2"
		
SELECT SUM(CO2.CO2_QUANT) nQuant		
FROM %table:CO2% CO2		
WHERE CO2.CO2_FILIAL = %xfilial:CO2%
	AND CO2.CO2_CODEDT = %exp:cCodEdt%
	AND CO2.CO2_NUMPRO = %exp:cNumPr%
	AND CO2.CO2_CODPRO = %exp:cCodPro%
	AND CO2.%NotDel%
			
EndSql

nTotalCO2 := SOMACO2->nQuant

SOMACO2->(DbCloseArea())

Return nTotalCO2

