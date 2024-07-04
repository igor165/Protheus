#INCLUDE "PROTHEUS.ch"
#INCLUDE "GCPA009.ch"
          
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GCPA009    ºAutor  ³ Totvs              º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Geracao dos dados para Pedidos de Venda, Pedidos de Compra e º±±
±±º			 ³ Contratos conforme vencedores do edital.						º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GCPA010, GCPA011 e GCPA013									º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GCPA009()
Local aRet 		:= {}
Local aParticip := {}
Local aGCP9QRY	:= {}
Local cQuery  	:= ""
Local cFornec 	:= ""
Local cLoja   	:= ""
Local nGCP9QTD	:= 0
Local nPos    	:= 0
Local nX	  	:= 0
Local aCTBEnt 	:= CtbEntArr()
Local oDlg		:= NIL
Local oLbx		:= NIL
Local lGCP9QRY  := Existblock('GCP9QRY')
Local lRatItens	:= .F.  //-- Grava dados contabeis do pedido como rateio (SCH)
local lSCCNI	:= SuperGetMV("MV_SCLCNI",.F.,.F.)
Local cAval  := CO1->CO1_AVAL
Local cAliasQry := GetNextAlias()
Local cAliasSC1 := GetNextAlias()

BeginSQL Alias cAliasSC1
	SELECT COUNT(*) AS USARAT
	FROM %Table:SC1% SC1
	WHERE SC1.%NotDel% AND
		SC1.C1_FILIAL = %xFilial:SC1% AND
		SC1.C1_CODED = %Exp:CO1->CO1_CODEDT% AND
		SC1.C1_NUMPR = %Exp:CO1->CO1_NUMPRO% AND
		SC1.C1_FILIAL <> SC1.C1_FILENT
EndSQL

//-- Caso o edital seja de compra compartilhada,
//-- desabilita a utilizacao do rateio por item do pedido (SCH)
lRatItens := SuperGetMV("MV_GCPRATP",.F.,.F.) .And. Empty((cAliasSC1)->USARAT)
(cAliasSC1)->(dbCloseArea())

cQuery := "SELECT CO3.CO3_FILIAL FILIAL, "
cQuery += " CO3.CO3_CODEDT CODEDT, "
cQuery += " CO3.CO3_NUMPRO NUMPROC, "
cQuery += " CO3.CO3_CODIGO CODIGO, "
cQuery += " CO3.CO3_LOJA LOJA, "
cQuery += " CO3.CO3_TIPO TIPO, "

If cAval == "1"
	cQuery += " CO3.CO3_CODPRO CODPRO, "
Else
	cQuery += " CO3.CO3_LOTE LOTE, "
	cQuery += " CP6.CP6_CODPRO CODPRO, "		
	cQuery += " CP6.CP6_PRCUN PRCUNI, "
EndIf
	
cQuery += " CO3.CO3_VLUNIT VLUNIT, "
If lRatItens
	cQuery += " CO2.CO2_QUANT QUANT, " 
	cQuery += " CO2.CO2_ITEM ITEM, "
Else
	cQuery += " ISNULL(SC1.C1_QUANT,CO2.CO2_QUANT) QUANT, " 
	cQuery += " ISNULL(SC1.C1_ITEM,CO2.CO2_ITEM) ITEM, "      
EndIf      
cQuery += " ISNULL(SC1.C1_CC,SB1.B1_CC) CC, "
cQuery += " ISNULL(SC1.C1_CONTA,SB1.B1_CONTA) CONTA, "
cQuery += " ISNULL(SC1.C1_ITEMCTA,SB1.B1_ITEMCC) ITEMCTA, "
cQuery += " ISNULL(SC1.C1_CLVL,SB1.B1_CLVL) CLVL, "
cQuery += " ISNULL(SC1.C1_NUM,'') NUMSC, "
cQuery += " ISNULL(SC1.C1_FILENT,'') FILENT "

//-- Adiciona campos das novas entidades contabeis
For nPos := 1 To Len(aCTBEnt)
	If SC1->(FieldPos("C1_EC" +aCTBEnt[nPos] +"CR")) > 0
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"CR,SB1.B1_EC" +aCTBEnt[nPos] +"CR) EC" +aCTBEnt[nPos] +"CR "
		cQuery += ", ISNULL(SC1.C1_EC" +aCTBEnt[nPos] +"DB,SB1.B1_EC" +aCTBEnt[nPos] +"DB) EC" +aCTBEnt[nPos] +"DB "
	Else
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"CR EC" +aCTBEnt[nPos] +"CR "
		cQuery += ", SB1.B1_EC" +aCTBEnt[nPos] +"DB EC" +aCTBEnt[nPos] +"DB "
	EndIf
Next nPos

//-- Ponto de entrada para adicao de campos na query
If lGCP9QRY
	aGCP9QRY := Execblock('GCP9QRY',.F.,.F.)
	
	If (lGCP9QRY := ValType(aGCP9QRY[1]) == "C" .And. ValType(aGCP9QRY[2]) == "C")
		cQuery += aGCP9QRY[1]
	EndIf
EndIf

cQuery += "FROM " +RetSqlName("CO3") +" CO3 "

cQuery += "JOIN " +RetSQLName("CO2") +" CO2 ON "
cQuery += " CO2.D_E_L_E_T_ <> '*' AND "
cQuery += " CO2.CO2_FILIAL = '" +xFilial("CO2") +"' AND "
cQuery += " CO2.CO2_CODEDT = CO3.CO3_CODEDT AND "
cQuery += " CO2.CO2_NUMPRO = CO3.CO3_NUMPRO "

If cAval == "1"
	cQuery += "AND CO2.CO2_CODPRO = CO3.CO3_CODPRO "  
Else
	cQuery += "AND CO2.CO2_LOTE = CO3.CO3_LOTE "
	cQuery += "JOIN " +RetSQLName("CP6") +" CP6 ON "
	cQuery += " CP6.D_E_L_E_T_ <> '*' AND "
	cQuery += " CP6.CP6_FILIAL = '" +xFilial("CP6") +"' AND "
	cQuery += " CP6.CP6_CODEDT = CO2.CO2_CODEDT AND " 
	cQuery += " CP6.CP6_NUMPRO = CO2.CO2_NUMPRO AND"
	cQuery += " CP6.CP6_CODPRO = CO2.CO2_CODPRO "	
EndIf

cQuery += "JOIN " +RetSQLName("SB1") +" SB1 ON "
cQuery += " SB1.D_E_L_E_T_ <> '*' AND "
cQuery += " SB1.B1_FILIAL = '" +xFilial("SB1") +"' AND "
cQuery += " SB1.B1_COD = CO2.CO2_CODPRO "

cQuery += "LEFT JOIN " +RetSQLName("SC1") +" SC1 ON "
cQuery += " SC1.D_E_L_E_T_ <> '*' AND "
cQuery += " SC1.C1_FILIAL = '"+xFilial("SC1")+"' AND "	
cQuery += " SC1.C1_CODED = CO2.CO2_CODEDT AND "
cQuery += " SC1.C1_NUMPR = CO2.CO2_NUMPRO AND "
cQuery += " SC1.C1_PRODUTO = CO2.CO2_CODPRO "

//-- Se rateio contabil na SCH, forca nao trazer SC1
If lRatItens
	cQuery += " AND SC1.C1_PRODUTO = '' "
EndIf

cQuery += "WHERE CO3.CO3_FILIAL = '"+xFilial("CO3")+"' "
cQuery += " AND CO3.CO3_CODEDT = '" +CO1->CO1_CODEDT+ "' "
cQuery += " AND CO3.CO3_NUMPRO = '" +CO1->CO1_NUMPRO+ "' "
//cQuery += " AND CO3.CO3_CLASS = '1' "
cQuery += " AND CO3.CO3_STATUS = '5' "

//-- Ponto de entrada para adicao de filtro
If lGCP9QRY
	cQuery += aGCP9QRY[2]
EndIf

cQuery += " AND CO3.D_E_L_E_T_ <> '*' "

If lRatItens
	If lSCCNI
		cQuery += "ORDER BY FILIAL,CODIGO,LOJA,TIPO,FILENT"
	Else
		cQuery += "ORDER BY FILIAL,ITEM,TIPO,CODIGO,LOJA"
	EndIf
ElseIf cAval == "2"
	cQuery += "ORDER BY FILIAL,CODIGO,LOJA,FILENT,LOTE
Else
	cQuery += "ORDER BY FILIAL,CODIGO,LOJA,FILENT,ITEM,CODPRO" 
EndIf

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry)

//Verifica se existe Pre-Fornecedor que ainda nao e' fornecedor
While (cAliasQry)->(!Eof())
	cFornec := (cAliasQry)->CODIGO //QRY01->CODIGO
	cLoja   := (cAliasQry)->LOJA //QRY01->LOJA
	/*If QRY01->TIPO == "1"
		nPos := aScan(aParticip,{|x| x[2] == QRY01->CODIGO})
		If nPos == 0
			CO6->(dbSetOrder(1))
			If CO6->(dbSeek(xFilial("CO6")+QRY01->CODIGO)) .And. Empty(CO6->CO6_FORNEC)
				aAdd(aParticip,{xFilial("CO6"),QRY01->CODIGO,CO6->CO6_NOME,CO6->CO6_TIPO})
				cFornec := CO6->CO6_CODIGO
				cLoja   := CO6->CO6_LOJFOR
			ElseIf !Empty(CO6->CO6_FORNEC) .And. !Empty(CO6->CO6_LOJFOR)
				cFornec := CO6->CO6_FORNEC
				cLoja   := CO6->CO6_LOJFOR
			EndIf        
		EndIf
	EndIf*/
	
	aAdd(aRet,Array(14))
	
	aTail(aRet)[1] := cFornec																//-- 1. Codigo do fornecedor
	aTail(aRet)[2] := cLoja																	//-- 2. Loja do fornecedor
	aTail(aRet)[3] := (cAliasQry)->CODPRO	   														//-- 3. Codigo do produto
	//-- Ponto de entrada para manipulacao da quantidade
	If Existblock('GCP9QTD')
		nGCP9QTD := Execblock('GCP9QTD',.F.,.F.,{cAliasQry})
		aTail(aRet)[4] := If(ValType(nGCP9QTD) == "N" .And. nGCP9QTD > 0,nGCP9QTD,(cAliasQry)->QUANT)
	Else
		aTail(aRet)[4] := (cAliasQry)->QUANT														//-- 4. Quantidade
	EndIf
	aTail(aRet)[5] := IIf(cAval == "2",(cAliasQry)->PRCUNI,(cAliasQry)->VLUNIT) 						//-- 5. Preço unitario
	aTail(aRet)[6] := (cAliasQry)->CODEDT							  								//-- 6. Codigo do edital
	aTail(aRet)[7] := (cAliasQry)->NUMPROC														//-- 7. Numero do processo
	aTail(aRet)[8] := If(!lRatItens,(cAliasQry)->CC,"")											//-- 8. Centro de custo
	aTail(aRet)[9] := If(!lRatItens,(cAliasQry)->CONTA,"")										//-- 9. Conta contabil
	aTail(aRet)[10] := If(!lRatItens,(cAliasQry)->ITEMCTA,"")									//-- 11. Item de conta
	aTail(aRet)[11] := If(!lRatItens,(cAliasQry)->CLVL,"")										//-- 10. Classe de valor]
	aTail(aRet)[12] := If(!lRatItens .And. !Empty((cAliasQry)->NUMSC),(cAliasQry)->NUMSC,"")			//-- 12. Solicitacao
	aTail(aRet)[13] := If(!lRatItens .And. !Empty((cAliasQry)->NUMSC),PadR((cAliasQry)->ITEM,TamSX3("C1_ITEM")[1]),"")	//-- 13. Item
	aTail(aRet)[14] := (cAliasQry)->FILENT														//-- 14. Filial de Entrega
	
	//-- Adiciona entidades contabeis
	For nPos := 1 To Len(aCTBEnt)
		aAdd(aTail(aRet),If(!lRatItens,(cAliasQry)->&("EC"+aCTBEnt[nPos]+"CR"),""))
		aAdd(aTail(aRet),If(!lRatItens,(cAliasQry)->&("EC"+aCTBEnt[nPos]+"DB"),""))
	Next nPos
	
	If cAval == '2'
		aAdd(aTail(aRet), (cAliasQry)->LOTE)
	EndIf
	
	(cAliasQry)->(dbSkip())
End

//-- Se ha participantes nao cadastrados, chama cadastro
/*If Len(aParticip) > 0
	DEFINE MSDIALOG oDlg TITLE STR0007 FROM 0,0 TO 300,500 PIXEL //"Participantes"
	@ 010,010 SAY STR0003 +If(AllTrim(CO1->CO1_MODALI)=="LL",STR0001,STR0002) +STR0004 OF oDlg PIXEL //-- Os seguintes ganhadores não constam cadastrados como clientes/fornecedores e serão cadastrados.
	@ 30,10 LISTBOX oLbx FIELDS HEADER STR0008,STR0016 SIZE 230,95 OF oDlg PIXEL //"Codigo"##"Nome"	
	oLbx:SetArray(aParticip)
	oLbx:bLine := {|| {aParticip[oLbx:nAt,2],aParticip[oLbx:nAt,3]}}
	DEFINE SBUTTON FROM 130,213 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
	
	If !CadPartic(aParticip,@aRet)
		aRet := {}

		aGrvCO7 := {	{"CO7_CODEDT", CO1->CO1_CODEDT},;
						{"CO7_NUMPRO", CO1->CO1_NUMPRO},;
						{"CO7_DTMOV" , dDataBase},;
						{"CO7_HRMOV" , Time()},;
						{"CO7_CODUSU", Upper(Alltrim(Substr(cUsuario,7,15)))},;
						{"CO7_MOVATU", CO1->CO1_ETAPA},;
						{"CO7_DESATU", Tabela("LE",CO1->CO1_ETAPA,.F.)},;
						{"CO7_ACAO"  , STR0005 +If(AllTrim(CO1->CO1_MODALI)=="LL",STR0001,STR0002) +STR0006},; //-- Cadastramento dos Ganhadores no cadastro de clientes/fornecedores cancelado pelo usuário.
						{"CO7_PASATU", CO1->CO1_PASSO}	}	
						
		GCPA006(aGrvCO7)
	EndIf
EndIf*/	

(cAliasQry)->(DbCloseArea())
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CadPartic   ºAutor  ³ Totvs              º Data ³  01/04/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Inclui os participantes do edital ainda nao cadastradados comoº±±
±±º			 ³ fornecedores/clientes.									 	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GCPA009							                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CadPartic(aParticip,aDados)
Local lRet		:= .T.
Local cCodNew	:= ""
Local cLojNew	:= ""
Local nY		:= 0
Local cAliasCO3 := ""

Begin Transaction
							
For nY := 1 To Len(aParticip)
	CO6->(DbSetOrder(1))
	If CO6->(DbSeek(aParticip[nY,1]+aParticip[nY,2]))
	    cAlias := Iif(CO6->CO6_TIPO == "C","SA1","SA2")
	    
		(cAlias)->(DbSetOrder(1))
		If	!(cAlias)->(DbSeek(xFilial(cAlias)+CO6->CO6_CODIGO+CO6->CO6_LOJFOR))
			cCodNew := CO6->CO6_CODIGO
			cLojNew := CO6->CO6_LOJFOR
		Else
			cCodNew := CriaVar(Substr(cAlias,2,2)+"_COD")
			cLojNew := CriaVar(Substr(cAlias,2,2)+"_LOJA")
		EndIf
		If CO6->CO6_TIPO == "C"
			lRet := (A030WebbIc({	{"A1_COD",cCodNew},				{"A1_LOJA",cLojNew},;
								{"A1_PESSOA","J"},				{"A1_CGC",CO6->CO6_CNPJ},;
								{"A1_NOME",CO6->CO6_NOME},		{"A1_TEL",CO6->CO6_TEL},;
								{"A1_CONTATO",CO6->CO6_CONTAT},	{"A1_END",CO6->CO6_END},;
								{"A1_BAIRRO",CO6->CO6_BAIRRO},	{"A1_MUN",CO6->CO6_MUN},;
								{"A1_ESTADO",CO6->CO6_UF},		{"A1_CEP",CO6->CO6_CEP},;
								{"A1_EMAIL",CO6->CO6_EMAIL},	{"A1_INSCR",CO6->CO6_INSCR},;
								{"A1_TIPO","F"}	})) == 1
		Else
			lRet := (GCPCadForn({	{"A2_COD",cCodNew},				{"A2_LOJA",cLojNew},;
								{"A2_TIPO","J"},				{"A2_CGC",CO6->CO6_CNPJ},;
								{"A2_NOME",CO6->CO6_NOME},		{"A2_TEL",CO6->CO6_TEL},;
								{"A2_CONTATO",CO6->CO6_CONTAT},	{"A2_END",CO6->CO6_END},;
								{"A2_BAIRRO",CO6->CO6_BAIRRO},	{"A2_MUN",CO6->CO6_MUN},;
								{"A2_EST",CO6->CO6_UF},			{"A2_CEP",CO6->CO6_CEP},;
								{"A2_EMAIL",CO6->CO6_EMAIL},	{"A2_INSCR",CO6->CO6_INSCR}	}))
		EndIf

		If !lRet
			DisarmTransaction()
			Exit
		Else
			RecLock("CO6",.F.)
			CO6->CO6_FORNEC := (cAlias)->&(Substr(cAlias,2,2)+"_COD")
			CO6->CO6_LOJFOR := (cAlias)->&(Substr(cAlias,2,2)+"_LOJA")
			CO6->(MsUnLock())
		
			If (nPos := aScan(aDados,{|x| x[1]+x[2] == CO6->(CO6_CODIGO+CO6_LOJFOR)})) > 0
				aDados[nPos,1] := CO6->CO6_FORNEC
				aDados[nPos,2] := CO6->CO6_LOJFOR
			EndIf		


			//-- Substitui no CO3 o pre-fornecedor pelo fornecedor
			If	CO6->CO6_TIPO=="F"

				cAliasCO3 := GetNextAlias()

				BeginSQL Alias cAliasCO3
	
				SELECT CO3.R_E_C_N_O_ RecCO3
		
				FROM %table:CO3% CO3
		
				WHERE CO3.CO3_FILIAL = %xfilial:CO3%
					AND CO3.CO3_CODEDT = %exp:CO1->CO1_CODEDT%
					AND CO3.CO3_NUMPRO = %exp:CO1->CO1_NUMPRO%
					AND CO3.CO3_TIPO   = '1'
					AND CO3.CO3_CODIGO = %exp:CO6->CO6_CODIGO%
					AND CO3.CO3_LOJA   = %exp:CO6->CO6_LOJFOR%
					AND CO3.%NotDel%
				ORDER BY %Order:CO3%
			
				EndSql
				
				While (cAliasCO3)->(!Eof())
					CO3->(DbGoTo((cAliasCO3)->RecCO3))

					If (nPos := aScan(aDados,{|x| x[1]+x[2] == CO6->(CO6_CODIGO+CO6_LOJFOR)})) > 0
						aDados[nPos,1] := CO6->CO6_FORNEC
						aDados[nPos,2] := CO6->CO6_LOJFOR
					EndIf		
							
					RecLock("CO3",.F.)
					CO3->CO3_CODIGO := CO6->CO6_FORNEC
					CO3->CO3_LOJA   := CO6->CO6_LOJFOR
					CO3->CO3_TIPO   := "2"
					CO3->(MsUnLock())
					
					(cAliasCO3)->(DbSkip())
				EndDo
				(cAliasCO3)->(DbCloseArea())
				DbSelectArea("CO6")
			EndIf
			//--

		EndIf
	EndIf
Next nY

End Transaction

Return(lRet)
