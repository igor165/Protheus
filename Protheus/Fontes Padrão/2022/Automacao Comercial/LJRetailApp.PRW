#INCLUDE "PROTHEUS.CH"
#INCLUDE 'parmtype.ch'
#INCLUDE 'LJRETAILAPP.ch'
#DEFINE NLIMITOBJ	10000 // Limite de elementos new() no objeto JSON, de acordo com Carlo/Pablo foi solicitado a alteração para 10000
#DEFINE CRLF CHR(13)+CHR(10)

Static aRecTab := {} 

//-----------------------------------------------------------
/*/{Protheus.doc} LJRetailJob
Integracao com o RetailApp
@author Fábio S. dos Santos
@since 29/08/2017
@return
/*/
//-----------------------------------------------------------
/*Function LJRetailJob(cEmp, cFil)
Local nCount	:= 1
Local cTemp		:= ""
While nCount <= Len( cFil )

	cTemp := ""
	While SubStr( cFilTrab, nCount, 1 ) <> "," .AND. nCount <= Len( cFilTrab )
		cTemp += SubStr( cFilTrab, nCount, 1 )
		nCount++
	End
	AADD( aFiliais, { cTemp } )
	nCount++

End

nCount := 1

//Verifica o numero de filiais que esta sendo passado
RPCSetType(3)  // Nao utilizar licenca
If Len(aFiliais) > 1
	For nCount:=1 to Len(aFiliais)
		RPCSetEnv(cEmp,aFiliais[nCont],,,"LOJ")
		LJRetailApp(cEmp, cFil)
	Next nCount
Else
	RPCSetEnv(cEmp,cFil,,,"LOJ")
	LJRetailApp(cEmp, cFil)
Endif

Return
*/

//-----------------------------------------------------------
/*/{Protheus.doc} LJRetailApp
Integracao com o RetailApp
@author Leandro Lima
@since 11/05/2017
@return
/*/
//-----------------------------------------------------------
Function LJRetailApp(cEmp, cFil, lJob, cTipo, aFilsWiz, oSay, cDiasTela)
Local aSales		:= {}
Local cBeginDate	:= ''    				// data do processamento
Local cTokenCon		:= ''   				// Token de conexao com API REST
Local aParams		:= {}    				// Parametros utilizados
Local aRet			:= {.T.,""}
Local lLjMsgFim		:= .F.
Local cDtInvent		:= ""
Local lInvent		:= .T.
Local lUsers		:= .T.
Local nHandle		:= ""
Local cJob      	:= "LJRETAILAPP"	//Nome do Semaforo
Local oLocker   	:= Nil             	//Objeto utilizado para Semaforo
Local lLjPedVen		:= .F.				//Pedido de Venda

Default cEmp		:= '99'
Default cFil 		:= '01'
Default lJob		:= .T.
Default cTipo		:= 'M'
Default aFilsWiz	:= {}
Default oSay		:= Nil
Default cDiasTela	:= ""	//utilizado para processamento em tela, sem alteracao no parametro MV_LJRAPP1

If lJob
	RPCSetType(3)  // Nao utilizar licenca
	RPCSetEnv(cEmp,cFil,,,"LOJ")
	aFilsWiz := LerCSVOrg()//aadd(aFilsWiz,{.T., SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOMECOM, SM0->M0_ESTCOB, SM0->M0_CIDCOB})
	oLocker := LJCGlobalLocker():New()
  	If !oLocker:GetLock( cJob )
		Conout(" * * " + DtoC(dDataBase) + " " + Time() + " - <<< " + cJob + " >>> Processo ja esta em execucao.")
		RpcClearEnv()           //Reset Environment
		Return(Nil)
  	EndIf
Endif

LjGrvLog("LJRetailApp","aFilsWiz",aFilsWiz)

//verifico se o arquivo existe
If File("\retailapp\retail.ini")
	nHandle := FT_FUSE("\retailapp\retail.ini")
	If nHandle > 0
		FT_FGoTop()
		While !FT_FEOF()
			cLine  := FT_FReadLn()
			If Substr(cLine,1,At("=",cLine) - 1) == "Inventory"
				cDtInvent	:= Substr(cLine,At("=",cLine) + 1,Len(cLine))
				If DtoS(dDataBase) == cDtInvent
					lInvent := .F.
				EndIf
			ElseIf Substr(cLine,1,At("=",cLine) - 1) == "Users"
				cDtInvent	:= Substr(cLine,At("=",cLine) + 1,Len(cLine))
				If DtoS(dDataBase) == cDtInvent
					lUsers := .F.
				EndIf
			EndIf
			FT_FSkip()
		End
	EndIf
	FT_FUSE()
EndIf

// Estrutura do aParams
//aParams[1] - URL de login para recuperacao do token de conexao
//aParams[2] - URL para envio dos dados
//aParams[3] - URL para Calculo dos dados enviados
//aParams[4] - usuario de conexao
//aParams[5] - senha de conexao
//aParams[6] - quantidade de dias que serao enviadas as vendas
//aParams[7] - TES que serao consideradas como venda
If LjValidPar(@aParams, oSay)  // Valida as configuracoes de SSL no INI e os parametros da rotina e carregar o aParams

	LjGrvLog("LJRetailApp","aParams",aParams)
	//Tratamento para processamento quando origem via Wizard "LjGeraMov()"
	If !Empty(cDiasTela)
		aParams[6] := cDiasTela
	EndIf

    If cTipo <> 'M'
		cBeginDate := (DTOS(dDataBase - 365))
	Else
		cBeginDate := (DTOS(dDataBase - Val(aParams[6])))
	Endif

	// Envio dos dados das vendas via API REST
	If LjConectWS(@cTokenCon, aParams[4], aParams[5], aParams[1], oSay)  // Busca o token valido para a transmissao dos arquivos de movimento
		
		lLjPedVen := LjPedVen(.F.)  // Venda Entrega
		LjGrvLog("LJRetailApp","Venda Entrega sera acumulada ? ", lLjPedVen)
		
		LjGrvLog("LJRetailApp","Conexão OK - Envia Vendas")
		// Orders/Payments
		aRet[1] := LjROrders(@aSales, cBeginDate, cTokenCon, aParams, aFilsWiz, oSay, cTipo)
		LjGrvLog("LJRetailApp","Conexão OK - Retorno Vendas -> aRet[1]",aRet[1])

		If aRet[1] .AND. lLjPedVen
			// Venda Entrega
			aSales := {}
			LjGrvLog("LJRetailApp","Conexão OK - Entrega")
			aRet[1] := LjREntrega(@aSales, cBeginDate, cTokenCon, aParams[2], aFilsWiz, oSay)
			LjGrvLog("LJRetailApp","Conexão OK - Retorno Venda Entrega - aRet[1]",aRet[1])
		EndIf

		If aRet[1]
			//Inventory
			If lInvent
				LjGrvLog("LJRetailApp","Conexão OK - Inventario")
				aRet[1] := LjRInvent(DTOS(dDataBase), cTokenCon, aParams[2], oSay, cBeginDate, aFilsWiz)
				LjGrvLog("LJRetailApp","Conexão OK - Retorno Inventario - aRet[1]",aRet[1])
			EndIf
		EndIf

		If aRet[1]
			// Users - Vendedores
			If lUsers
				LjGrvLog("LJRetailApp","Conexão OK - Vendedores")
				aRet[1] := LjRUsers(cTokenCon, aParams[2], oSay, cBeginDate, aFilsWiz)
				LjGrvLog("LJRetailApp","Conexão OK - Retorno Vendedores - aRet[1]",aRet[1])
			EndIf
		EndIf

		If aRet[1]
			//Mensagem final de processamento
			LjGrvLog("LJRetailApp","Conexão OK - processamento")
			lLjMsgFim := LjRMsgFim(aFilsWiz, cTipo, lJob)
			LjGrvLog("LJRetailApp","Conexão OK - Retorno processamento - lLjMsgFim",lLjMsgFim)
		EndIf

		/* 		
		If aRet[1]
			LjGrvLog("LJRetailApp","Conexão OK - Log de Exportação")
			//Gravo Log de Exportação
			aRet[1] := LjRLogOrd(aFilsWiz, cBeginDate)
			LjGrvLog("LJRetailApp","Conexão OK - Retorno Log de Exportação - aRet[1]",aRet[1])
		EndIf
		*/

	Else
		LjGrvLog("LJRetailApp","aRet[1] .F.")
		aRet[1] := .F.
	Endif
EndIf

If lJob
	oLocker:ReleaseLock( cJob )
EndIf

Return aRet

//-----------------------------------------------------------
/*/{Protheus.doc} LjROrders
Transmite as vendas
@author Leandro Lima
@since 11/05/2017
@return .T. - caso OK, .F. - caso ocorra erro de validacao
/*/
//-----------------------------------------------------------
Static Function LjROrders(aSales, cBeginDate, cTokenCon, aParams,;
				 aFilsWiz, oSay, cTipo)
Local cAliasTmp	:= GetNextAlias()
Local lIniJSon	:= .F.
Local nCountObj	:= 0
Local cJSonObj	:= ''
Local cQuery	:= ''
Local lRet		:= .T.
Local cUrl		:= aParams[2]
Local cTes		:= aParams[7]
Local cDia		:= Space(02)
Local cMes		:= Space(02)
Local cAno		:= Space(04)
Local cFiliais	:= ""
Local nCont		:= 0
Local cPathLog	:= '\retailapp\'
Local nHandle	:= 0
Local nPos		:= 0
Local cFilOrder	:= ""
Local cDtEmiss	:= ""
Local aLine		:= {}
Local cRetDev	:= ""
Local aCarga	:= {}
Local cLine		:= ""
Local lQryOrder	:= ExistBlock("LjRAQryO") //P.E. para considerar a query do cliente
Local lQryCateg	:= ExistBlock("LjRACatG") //P.E. para considerar outra tabela de categoria

LjGrvLog("LjROrders"," Ponto de entrada LjRAQryO Compilado ?",lQryOrder)

For nCont := 1 To Len(aFilsWiz)
	If aFilsWiz[nCont,1]
		If nCont == 1
			cFiliais := "'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		Else
			cFiliais += ",'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		EndIf
	EndIf
Next nCont

LjGrvLog("LjROrders"," cFiliais",cFiliais)

//retiro "," da primeira posição
If AT(",",cFiliais) == 1
	cFiliais := SubStr(cFiliais,2,Len(cFiliais))
EndIf

//verifico se possui arquivo no diretório, se sim é pq teve algum processamento que foi interrompido antes de finalizar
If File(cPathLog+"carga_inicial.csv")
	nHandle := FT_FUse(cPathLog+"carga_inicial.csv")

	If nHandle <> -1
		While !FT_FEOF()
			cLine	:= FT_FReadLn()
			aadd(aLine,cLine)

			FT_FSKIP()
		End
	Endif

	FT_FUSE()
	FERASE(cPathLog+"carga_inicial.csv")

EndIf

//Verifica se tem o PE, caso possua vai executar o PE e recebe a nova query
If lQryOrder
	cQuery := ExecBlock("LjRAQryO",.F.,.F.,{cBeginDate,cFiliais})
Else
	cQuery := "SELECT SUM(D2_DESCON) D2DESCON, D2_DOC DOC, D2_SERIE SERIE, D2_COD COD, SUM(D2_QUANT) QTDE, SUM(D2_TOTAL) TOTAL, D2_EMISSAO EMISSAO, F2_HORA HORA, D2_FILIAL FILIAL, F2_VEND1, D2_GRUPO GRUPO, D2_CLIENTE CLIENTE, D2_LOJA LOJA, 'SD2' ALIAS, SF2.R_E_C_N_O_ RECNO, SB1.B1_DESC DESCRICAO"
	cQuery += " FROM " + RetSqlName('SD2') + " SD2"
	cQuery += " INNER JOIN " + RetSqlName('SF2') + " SF2 ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA "
	cQuery += "  LEFT JOIN " + RetSqlName('SB1') + " SB1 ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' AND SD2.D2_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE "

	If !Empty(cFiliais)
		cQuery += "SD2.D2_FILIAL IN (" + cFiliais + ") AND "
	EndIf

	If SF2->(ColumnPos("F2_MSEXP")) > 0
		cQuery += "SF2.F2_MSEXP = ' ' AND "
	EndIf

	cQuery += " (SF2.F2_NFCUPOM = ' ' OR SF2.F2_ESPECIE IN ('CF','ECF','NFCE','SATCE')) AND " //FILTRO SOMENTE AS NOTAS DAS VENDAS (EXCLUINDO AS NOTAS SOBRE CUPONS)
	cQuery += " SD2.D2_DOC <> ' ' AND SD2.D2_EMISSAO >= '" + cBeginDate + "' AND SD2.D2_TES IN (" + LjQueryIN(cTes) + ")"
	cQuery += " AND SD2.D2_TIPO = 'N' AND SD2.D_E_L_E_T_ = ' ' AND SF2.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY D2_DOC, D2_SERIE, D2_COD, D2_EMISSAO, F2_HORA, D2_FILIAL, F2_VEND1, D2_GRUPO, D2_CLIENTE, D2_LOJA, SF2.R_E_C_N_O_, SB1.B1_DESC "

	cQuery += " UNION ALL "

	cQuery += " SELECT SUM(D1_VALDESC) D2DESCON, D1_DOC DOC, D1_SERIE SERIE, D1_COD COD, SUM(D1_QUANT) QTDE, SUM(D1_TOTAL) TOTAL, D1_EMISSAO EMISSAO, F1_HORA HORA, D1_FILIAL FILIAL, F2_VEND1, D1_GRUPO GRUPO, D1_FORNECE CLIENTE, D1_LOJA LOJA, 'SD1' ALIAS, SF1.R_E_C_N_O_ RECNO, SB1.B1_DESC DESCRICAO"
	cQuery += " FROM " + RetSqlName('SD1') + " SD1"
	cQuery += " INNER JOIN " + RetSqlName('SF1') + " SF1 ON SD1.D1_FILIAL = SF1.F1_FILIAL AND SD1.D1_DOC = SF1.F1_DOC AND SD1.D1_SERIE = SF1.F1_SERIE AND SD1.D1_FORNECE = SF1.F1_FORNECE AND SD1.D1_LOJA = SF1.F1_LOJA AND SF1.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName('SD2') + " SD2 ON SD1.D1_FILORI = SD2.D2_FILIAL AND SD1.D1_NFORI = SD2.D2_DOC AND SD1.D1_SERIORI = SD2.D2_SERIE AND SD1.D1_ITEMORI = SD2.D2_ITEM AND SD1.D1_COD = SD2.D2_COD AND SD2.D_E_L_E_T_ = ' '"
	cQuery += " INNER JOIN " + RetSqlName('SF2') + " SF2 ON SD2.D2_FILIAL = SF2.F2_FILIAL AND SD2.D2_DOC = SF2.F2_DOC AND SD2.D2_SERIE = SF2.F2_SERIE AND SD2.D2_CLIENTE = SF2.F2_CLIENTE AND SD2.D2_LOJA = SF2.F2_LOJA AND SF2.D_E_L_E_T_ = ' '"
	cQuery += "  LEFT JOIN " + RetSqlName('SB1') + " SB1 ON SB1.B1_FILIAL = '" + xFilial('SB1') + "' AND SD1.D1_COD = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE"
	cQuery += " SD1.D1_FILIAL IN (" + cFiliais + ") AND "
	cQuery += " SD1.D1_EMISSAO >= '" + cBeginDate + "' AND "
	
	If SF1->(ColumnPos("F1_MSEXP")) > 0
		cQuery += "SF1.F1_MSEXP = ' ' AND "
	EndIf

	cQuery += " SD1.D1_DOC <> ' ' AND "
	cQuery += " SD1.D1_TIPO = 'D' AND "
	cQuery += " SD1.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY D1_DOC, D1_SERIE, D1_COD, D1_EMISSAO, F1_HORA, D1_FILIAL, F2_VEND1, D1_GRUPO, D1_FORNECE, D1_LOJA, SF1.R_E_C_N_O_, SB1.B1_DESC "
	cQuery += " ORDER BY FILIAL, EMISSAO"
EndIf

cQuery := ChangeQuery(cQuery)

LjGrvLog("LjROrders","cQuery SEM Ponto de entrada LjRAQryO",cQuery)
If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
EndIf

DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.F.)

//Posiciona no inicio do arquivo temporario
(cAliasTmp)->(dbGoTop())

While (cAliasTmp)->(!EOF())
    If !lIniJSon
		cJSonObj 	:= '{"orders":['
		lIniJSon 	:= 	.T.
		cFilOrder 	:= (cAliasTmp)->(FILIAL)
		cDtEmiss	:= (cAliasTmp)->(EMISSAO)
	Endif
	nPos := aScan(aLine, (cAliasTmp)->(FILIAL))
	If nPos > 0 .And. Val((cAliasTmp)->(EMISSAO)) < Val(aLine[2])
		(cAliasTmp)->(dbSkip())
		Loop
	EndIf
	If cDia <> Substr((cAliasTmp)->(EMISSAO), 7, 2)

		cDia := Substr((cAliasTmp)->(EMISSAO), 7, 2)
		cMes := Substr((cAliasTmp)->(EMISSAO), 5, 2)
		cAno := Substr((cAliasTmp)->(EMISSAO), 1, 4)

		LjRMsg("LjROrders - " + STR0001 + cDia + "/" + cMes + "/" + cAno + " - " + STR0028 + cEmpAnt+"/"+Rtrim((cAliasTmp)->(FILIAL)),,oSay) //"Executando Vendas - Periodo: "#"Empresa/Filial: "

	EndIf
	nCountObj++

	cRetDev := If(((cAliasTmp)->(ALIAS)) == 'SD1', '"Y"', "")
	cJSonObj += '{"ReceiptNumber":"'+If(!Empty(cRetDev),Alltrim((cAliasTmp)->(DOC))+Alltrim((cAliasTmp)->(SERIE))+'D',Alltrim((cAliasTmp)->(DOC))+Alltrim((cAliasTmp)->(SERIE)))+'",'
	cJSonObj += '"ReceiptDate":"'+Substr((cAliasTmp)->(EMISSAO), 1, 4)+'-'+Substr((cAliasTmp)->(EMISSAO), 5, 2)+'-'+Substr((cAliasTmp)->(EMISSAO),7,2)+'",'
	cJSonObj += '"ReceiptTime":"'+If(!Empty(Alltrim((cAliasTmp)->(HORA))),(cAliasTmp)->(HORA),"06:00")+'",'
	cJSonObj += '"SKU":"'+Alltrim((cAliasTmp)->(COD))+ ' - ' + LjRLimpa(NoAcento(Alltrim((cAliasTmp)->(DESCRICAO)))) + '",'
	cJSonObj += '"StoreID":"'+cEmpAnt+Rtrim((cAliasTmp)->(FILIAL))+'",'
	If !lQryCateg
		cJSonObj += '"Category":"'+LjRLimpa(NoAcento(OemToAnsi(Alltrim(Posicione('SBM', 1, xFilial('SBM')+(cAliasTmp)->(GRUPO), 'BM_DESC')))))+'",'
	Else
		cJSonObj += '"Category":"'+LjRLimpa(NoAcento(OemToAnsi(AllTrim(ExecBlock("LjRACatG",.F.,.F.,{Alltrim((cAliasTmp)->(FILIAL)),(cAliasTmp)->(COD)})))))+'",'
	EndIf
	cJSonObj += '"Quantity":'+Alltrim(Str((cAliasTmp)->(QTDE)))+','
	cJSonObj += '"CurrencyCode":'+'"BRL"'+','
	cJSonObj += '"Price":'+Alltrim(Str(Round(((cAliasTmp)->(TOTAL)/(cAliasTmp)->(QTDE)),2)))+','
	cJSonObj += '"OnPromotion":'+IIf((cAliasTmp)->(D2DESCON) > 0,'"Y"','"N"')+','
	cJSonObj += '"Return":'+If(!Empty(cRetDev),cRetDev,'"N"') +','  // caso devolucao total seta como Y
	cJSonObj += '"EmployeeID":"'+If(!Empty(Alltrim((cAliasTmp)->(F2_VEND1))),AllTrim((cAliasTmp)->(F2_VEND1)),"000001")+'"}'

	// Carrego o vetor com as vendas para montar na sequencia o array de pagamentos
	If aScan(aSales, {|x| x[1] == (cAliasTmp)->(FILIAL) .and. x[2] == (cAliasTmp)->(DOC) .and. x[3] == (cAliasTmp)->(SERIE) .and. x[4] == (cAliasTmp)->(CLIENTE) .and. x[5] == (cAliasTmp)->(LOJA)}) == 0
		Aadd(aSales, {(cAliasTmp)->(FILIAL), (cAliasTmp)->(DOC), (cAliasTmp)->(SERIE), (cAliasTmp)->(CLIENTE), (cAliasTmp)->(LOJA)})
		Aadd(aRecTab, {(cAliasTmp)->(ALIAS), (cAliasTmp)->(RECNO)})
	Endif

	If nCountObj == NLIMITOBJ
		If !Empty(cJSonObj)
			cJSonObj += ']}'

			If lRet := LjTransfWS(cTokenCon, cJSonObj, cUrl, oSay, "orders.json") .AND. Len(aSales) > 0   // Transmissao do Orders
				// Payments
				If lRet 
			
					LjGrvLog("LJRetailApp","Log de Exportação - LjROrders")
					lRet := LjRLogOrd(aFilsWiz, cBeginDate, aRecTab, "LjROrders")
					LjGrvLog("LJRetailApp","Retorno Log de Exportação - LjROrders")
		
					LjGrvLog("LjROrders","Envia Pagamentos")
					lRet := LjRPayments(aSales, cBeginDate, cTokenCon, cUrl, oSay, aFilsWiz)
					LjGrvLog("LjROrders","Resultado Envia Pagamentos -lRet",lRet )
				EndIf
			Else
				lRet := .F.
				//gravo o arquivo log da carga inicial com a filial e a data inicial do pacote json, esse arquivo será usado caso seja executada novamente a carga inicial
				//dessa forma a carga inicial será iniciada do ponto onde parou
				If cTipo == 'I'
					aadd(aCarga,cFilOrder)
					aadd(aCarga,cDtEmiss)
					LJGerCSV("carga_inicial.csv","", aCarga, cPathLog)
				EndIf

			EndIf

			If !lRet
				Exit
			EndIf

			lIniJSon  := .F.
			nCountObj := 0
			aSales    := {}
			cJSonObj  := ''
		EndIf
	EndIf

	(cAliasTmp)->(dbSkip())

	If !(cAliasTmp)->(Eof()) .and. !Empty(cJSonObj)
		cJSonObj += ','
	EndIf
End

If lRet .AND. !Empty(cJSonObj)
	cJSonObj += ']}'

	If lRet := LjTransfWS(cTokenCon, cJSonObj, cUrl, oSay, "orders.json") .AND. Len(aSales) > 0   // Transmissao do Orders

		If lRet 
			LjGrvLog("LJRetailApp","Log de Exportação - LjROrders")
			lRet := LjRLogOrd(aFilsWiz, cBeginDate, aRecTab, "LjROrders")
			LjGrvLog("LJRetailApp","Retorno Log de Exportação - LjROrders")
			
			//Payments
			lRet := LjRPayments(aSales, cBeginDate, cTokenCon, cUrl, oSay, aFilsWiz)
		EndIf
	Else
		lRet := .F.
		//gravo o arquivo log da carga inicial com a filial e a data inicial do pacote json, esse arquivo será usado caso seja executada novamente a carga inicial
		//dessa forma a carga inicial será iniciada do ponto onde parou
		If cTipo == 'I'
			aadd(aCarga,cFilOrder)
			aadd(aCarga,cDtEmiss)
			LJGerCSV("carga_inicial.csv","", aCarga, cPathLog)
		EndIf
	EndIf
EndIf

//Gravo o arquivo de configuração para controle das informações de orders e inventory
LJGerIni()

//Fecha Alias temporario
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} LjQueryIN
Funcao para poder gerar uma string de um array
@author Mauricio Canalle
@since 15/05/2017
@return string com informações do array recebido
/*/
//-----------------------------------------------------------
Static Function LjQueryIN(cTexto)
Local aText := StrToKArr(cTexto, ',')
Local cRet  := ""
Local nX 	:= 0

For nX := 1 to Len(aText)
	cRet += "'"+aText[nX]+"'"
	If Len(aText) > nX
		cRet +=","
	EndIf
Next nX

Return cRet

//-----------------------------------------------------------
/*/{Protheus.doc} LjRPayments
Transmite os pagamentos da venda, separando valores de entrada e parcelas
@author Mauricio Canalle
@since 15/05/2017
@return .T. - caso OK, .F. - caso ocorra erro de validacao
/*/
//-----------------------------------------------------------
Static Function LjRPayments(aSales, cBeginDate, cTokenCon, cUrl, oSay, aFilsWiz)
Local aPayments := {}
Local nI        := 0
Local nJ        := 0
Local nK        := 0
Local aMesParc  := {}
Local cMesParc  := ''
Local cAnoParc  := ''
Local nTotal    := 0
Local nValEnt   := 0
Local aParc     := {0,0,0,0,0,0,0,0,0,0,0,0}
Local cJSonObj  := ''   //  JSON de envio de dados
Local lRet		:= .T.

aRecTab := {}

nI := 1

SE1->(DbSetOrder(1))  //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO

For nI := 1 To Len(aSales)
	If SE1->(DbSeek(aSales[nI, 1] + aSales[nI, 3] + aSales[nI, 2] ))
		cMesParc  := Substr(DtoS(SE1->E1_EMISSAO), 5, 2)
		cAnoParc  := Substr(DtoS(SE1->E1_EMISSAO), 1, 4)

		// Monto um array com 12 meses consecutivos, partindo do mes e ano da venda
		aMesParc := {}
		For nK := 1 to 12
			Aadd(aMesParc, cAnoParc+cMesParc)

			If cMesParc < '12'
				cMesParc := Strzero(val(cMesParc)+1, 2)
			Else
				cMesParc := '01'
				cAnoParc := Str(val(cAnoParc)+1, 4)
			Endif
		Next

		Aadd(aPayments, Substr(DtoS(SE1->E1_EMISSAO), 1, 4)+'-'+Substr(DtoS(SE1->E1_EMISSAO), 5, 2)+'-'+Substr(DtoS(SE1->E1_EMISSAO),7,2)+','+; //ReceiptDate
		cEmpAnt+Rtrim(SE1->E1_FILIAL)+','+; //StoreID
		Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PREFIXO)+','+; //ReceiptNumber
		'%T%'+','+;   //ReceiptTotal
		'BRL'+','+; //CurrencyCode
		'%E%'+','+;   //Downpayment
		'%P01%'+','+;   //Installment_01
		'%P02%'+','+;   //Installment_02
		'%P03%'+','+;   //Installment_03
		'%P04%'+','+;   //Installment_04
		'%P05%'+','+;   //Installment_05
		'%P06%'+','+;   //Installment_06
		'%P07%'+','+;   //Installment_07
		'%P08%'+','+;   //Installment_08
		'%P09%'+','+;   //Installment_09
		'%P10%'+','+;   //Installment_10
		'%P11%'+','+;   //Installment_11
		'%P12%')   //Installment_12
				
		Aadd(aRecTab, {"SE1", SE1->(Recno())})

		nTotal  := 0
		nValEnt := 0
		aParc   := {0,0,0,0,0,0,0,0,0,0,0,0}

		// Distribuir os pagamentos da venda nos meses
		While SE1->E1_FILIAL == aSales[nI, 1] .and. SE1->E1_PREFIXO == aSales[nI, 3] .and. SE1->E1_NUM == aSales[nI, 2] .and. !SE1->(Eof())

			nTotal += SE1->E1_VALOR

			If IsMoney(Alltrim(SE1->E1_TIPO)) .OR. Alltrim(SE1->E1_TIPO) == 'CD'  // Entrada
				nValEnt += SE1->E1_VALOR
			Else  // Parcelas
				nPosParc := aScan(aMesParc, Substr(DTOS(SE1->E1_VENCREA), 1, 4)+Substr(DTOS(SE1->E1_VENCREA), 5, 2))
				If nPosParc > 0
					aParc[nPosParc] += SE1->E1_VALOR
				Endif
			Endif

			SE1->(DbSkip())
		End

		aPayments[Len(aPayments)] := StrTran(aPayments[Len(aPayments)], '%T%', Alltrim(Str(nTotal, TamSX3('E1_VALOR')[1], TamSX3('E1_VALOR')[2])))

		aPayments[Len(aPayments)] := StrTran(aPayments[Len(aPayments)], '%E%', Alltrim(Str(nValEnt, TamSX3('E1_VALOR')[1], TamSX3('E1_VALOR')[2])))

		For nJ := 1 to Len(aParc)
			aPayments[Len(aPayments)] := StrTran(aPayments[Len(aPayments)], ('%P'+StrZero(nJ,2)+'%'), Alltrim(Str(aParc[nJ], TamSX3('E1_VALOR')[1], TamSX3('E1_VALOR')[2])))
		Next
	Endif
Next
LjGrvLog("LjRPayments","aPayments",aPayments)
If Len(aPayments) > 0
	cJSonObj := '{"installments": ['

	For nI := 1 to Len(aPayments)
		aParc := StrToKArr(aPayments[nI], ',')

		cJSonObj += "{"
		cJSonObj += '"storeID":"'+aParc[02]+'",'
		cJSonObj += '"receiptNumber":"'+aParc[03]+'",'
		cJSonObj += '"receiptDate":"'+aParc[01]+'",'
		cJSonObj += '"receiptTotal":'+aParc[04]+','
		cJSonObj += '"currencyCode":"'+aParc[05]+'",'
		cJSonObj += '"downpayment":'+aParc[06]+','
		cJSonObj += '"installment_01":'+aParc[07]+','
		cJSonObj += '"installment_02":'+aParc[08]+','
		cJSonObj += '"installment_03":'+aParc[09]+','
		cJSonObj += '"installment_04":'+aParc[10]+','
		cJSonObj += '"installment_05":'+aParc[11]+','
		cJSonObj += '"installment_06":'+aParc[12]+','
		cJSonObj += '"installment_07":'+aParc[13]+','
		cJSonObj += '"installment_08":'+aParc[14]+','
		cJSonObj += '"installment_09":'+aParc[15]+','
		cJSonObj += '"installment_10":'+aParc[16]+','
		cJSonObj += '"installment_11":'+aParc[17]+','
		cJSonObj += '"installment_12":'+aParc[18]+'}'

		If nI < Len(aPayments) .AND. !Empty(cJSonObj)
		   cJSonObj += ','
		Endif

	Next

	LjGrvLog("LjRPayments","aParc",aParc)

	If !Empty(cJSonObj)
		cJSonObj += ']}'
		LjGrvLog("LjRPayments"," Enviando Pagamentos LjTransfWS")
		LjRMsg("LjRPayments - Executando pagamentos ",,oSay) //"Executando Vendas - Periodo: "#"Empresa/Filial: "
		lRet := LjTransfWS(cTokenCon, cJSonObj, cUrl, oSay, "payments.json")	// Transmissao do Payments
		If lRet
			LjGrvLog("LJRetailApp","Log de Exportação - LjRPayments")
			lRet := LjRLogOrd(aFilsWiz, cBeginDate, aRecTab, "LjRPayments")
			LjGrvLog("LJRetailApp","Retorno Log de Exportação - LjRPayments")
		EndIf
	Endif
Endif

LjGrvLog("LjRPayments","Fim Envia Pagamentos - lRet",lRet)

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} LjRInvent
Transmite o estoque atual
@author Leandro Lima
@since 15/05/2017
@return .T. - caso OK, .F. - caso ocorra erro de validacao
/*/
//-----------------------------------------------------------
Static Function LjRInvent(cDtInvent, cTokenCon, cUrl, oSay, cBeginDate,aFilsWiz)
Local cQuery	:= ""
Local cTempDb	:= GetNextAlias()
Local lIniJSon	:= .F.
Local nCountObj	:= 0
Local cJSonObj	:= ''          //  JSON de envio de dados
Local lRet		:= .T.
Local cModoSb1	:= ""
Local cModoSb2	:= ""
Local cFiliais	:= ""
Local cRetLjRAQr:= ""
Local nCont		:= 0
Local lQryInvent:= ExistBlock("LjRAQryI") //P.E. para considerar filtro adicional
Local lQryCateg	:= ExistBlock("LjRACatG") //P.E. para considerar outra tabela de categoria

Default cDtInvent	:= ""
Default cTokenCon	:= ""
Default cUrl		:= ""
Default oSay		:= Nil
Default aFilsWiz	:= {}

aRecTab := {}
cDtInvent := Substr(cDtInvent,1,4)+'-'+Substr(cDtInvent,5,2)+'-'+Substr(cDtInvent,7,2)   //YYYY-MM-DD
LjGrvLog("LjRInvent","cDtInvent",cDtInvent)

If lQryCateg
	LjGrvLog("LjRInvent","O ponto de Entrada LjRACatG será usado para a categoria")
EndIf

For nCont := 1 To Len(aFilsWiz)
	If aFilsWiz[nCont,1]
		If nCont == 1
			cFiliais := "'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		Else
			cFiliais += ",'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		EndIf
	EndIf
Next nCont

//retiro "," da primeira posição
If AT(",",cFiliais) == 1
	cFiliais := SubStr(cFiliais,2,Len(cFiliais))
EndIf

cModoSb1 := FWModeAccess("SB1",3)

cModoSb2 := FWModeAccess("SB2",3)

cQuery := "SELECT DISTINCT B2_FILIAL ,B2_COD, BM_DESC, SUM(B2_QATU) B2_QATU, B1_FILIAL, B1_COD, 'SB1' ALIAS, SB1.R_E_C_N_O_ RECNO, SB1.B1_DESC "
cQuery += "FROM "+ RetSQLName("SB2")+ " SB2 ,"+ RetSQLName("SB1")+" SB1 "
cQuery += "LEFT JOIN "+ RetSQLName("SBM")+" SBM ON SBM.BM_GRUPO = SB1.B1_GRUPO AND SBM.D_E_L_E_T_ = ' ' "
cQuery += "WHERE "
If cModoSb1 == "C"
	cQuery += "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND "
Else
	cQuery += " SB1.B1_FILIAL IN (" + cFiliais + ") AND "
EndIf
If cModoSb2 == "C"
	cQuery += "SB2.B2_FILIAL = '" + xFilial("SB2") + "' AND "
Else
	cQuery += " SB2.B2_FILIAL IN (" + cFiliais + ") AND "
EndIf

cQuery += "SB2.B2_QATU >= 1 AND "
cQuery += "SB1.D_E_L_E_T_ = ' ' AND "
cQuery += "SB2.D_E_L_E_T_ = ' ' AND "
cQuery += "SB1.B1_COD = SB2.B2_COD "

If lQryInvent
	LjGrvLog("LjRInvent","Antes da execução do PE LjRAQryI")
	cRetLjRAQr := ExecBlock("LjRAQryI",.F.,.F.)
	LjGrvLog("LjRInvent","Depois da execução do PE LjRAQryI",cRetLjRAQr)
	cQuery += "AND " + cRetLjRAQr
EndIf

cQuery += "GROUP BY B2_FILIAL ,B2_COD, BM_DESC, B1_FILIAL, B1_COD, SB1.R_E_C_N_O_, SB1.B1_DESC"

LjGrvLog("LjRInvent","cQuery Inventário",cQuery)

cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempDb,.F.,.F.)
(cTempDb)->(DbGoTop())
While (cTempDb)->(!Eof())
    If !lIniJSon
	   cJSonObj := '{"inventory": ['
	   lIniJSon := 	.T.
	Endif

	nCountObj++

	cJSonObj += "{"
	cJSonObj += '"inventoryDate":"'+cDtInvent+'",'
	cJSonObj += '"storeID":"'+cEmpAnt+Rtrim((cTempDb)->B2_FILIAL)+'",'
	cJSonObj += '"sku":"'+AllTrim((cTempDb)->B2_COD) + ' - ' + LjRLimpa(LjRmvAcent(NoAcento(AllTrim((cTempDb)->B1_DESC)))) + '",'
	If !lQryCateg
		cJSonObj += '"category":"'+LjRLimpa(LjRmvAcent(NoAcento(OemToAnsi(AllTrim((cTempDb)->BM_DESC)))))+'",'
	Else
		cJSonObj += '"category":"'+LjRLimpa(LjRmvAcent(NoAcento(OemToAnsi(AllTrim(ExecBlock("LjRACatG",.F.,.F.,{Alltrim((cTempDb)->(B1_FILIAL)),(cTempDb)->(B1_COD)})))))) +'",'
	EndIf
	cJSonObj += '"balanceOnHand":'+Alltrim(Str((cTempDb)->B2_QATU))+'}'

	Aadd(aRecTab, {(cTempDb)->ALIAS, (cTempDb)->RECNO})

	If nCountObj == NLIMITOBJ
		If !Empty(cJSonObj)
			cJSonObj += ']}'
			lRet := LjTransfWS(cTokenCon, cJSonObj, cUrl, oSay, "inventory.json")	// Transmissao do inventory
			If lRet
				LjGrvLog("LJRetailApp","Log de Exportação - LjRInvent")
				lRet := LjRLogOrd(aFilsWiz, cBeginDate, aRecTab, "LjRInvent")
				LjGrvLog("LJRetailApp","Retorno Log de Exportação - LjRInvent",lRet)
			EndIf
		Endif

		lIniJSon  := .F.
		nCountObj := 0

		cJSonObj  := ''
	Endif

	(cTempDb)->(DbSkip())

	If !(cTempDb)->(Eof())  .AND. !Empty(cJSonObj)
		cJSonObj += ","
	Endif
End

If !Empty(cJSonObj)
   	cJSonObj += ']}'
   	LjRMsg("LjRInvent - Executando Inventario ",,oSay)
   	LjGrvLog("LjRInvent","LjRInvent - Transmitindo Inventario ")
   	lRet := LjTransfWS(cTokenCon, cJSonObj, cUrl, oSay, "inventory.json")	// Transmissao do inventory
	If lRet
		LjGrvLog("LJRetailApp","Log de Exportação - LjRInvent")
		lRet := LjRLogOrd(aFilsWiz, cBeginDate, aRecTab, "LjRInvent")
		LjGrvLog("LJRetailApp","Retorno Log de Exportação - LjRInvent")
	EndIf   
Endif

//Fecha Alias temporario
If (Select(cTempDb) > 0)
	(cTempDb)->(dbCloseArea())
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc}LjRUsers
Transmite os usuarios do sistema
@author Leandro Lima
@since 11/05/2017
@return .T. - caso OK, .F. - caso ocorra erro de validacao
/*/
//-----------------------------------------------------------
Static Function LjRUsers(cTokenCon, cUrl, oSay, cBeginDate, aFilsWiz)
Local lIniJSon	:= .F.
Local cJsonObj	:= "" // JSON de envio de dados
Local lRet		:= .T.
Local cQuery	:= ""
Local cTempDb	:= GetNextAlias()
Local nCountObj	:= 0
Local nCont		:= 0
Local cModo		:= ""
Local cTam		:= ""

aRecTab := {}
LjGrvLog("LjRUsers","Gerando Dados Vendedores")

For nCont := 1 To Len(aFilsWiz)
	If aFilsWiz[nCont,1]
		If nCont == 1
			cFiliais := "'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		Else
			cFiliais += ",'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		EndIf
	EndIf
Next nCont

//retiro "," da primeira posição
If AT(",",cFiliais) == 1
	cFiliais := SubStr(cFiliais,2,Len(cFiliais))
EndIf

cModo := FWModeAccess("SA3",3)

cQuery := "SELECT DISTINCT A3_FILIAL ,A3_COD, A3_NOME, A3_NREDUZ, A3_EMAIL, 'SA3' ALIAS, R_E_C_N_O_ RECNO "
cQuery += "FROM " + RetSQLName("SA3") + " SA3 "
cQuery += "WHERE (SA3.A3_MSEXP < '" + cBeginDate + "' OR SA3.A3_MSEXP = '') "

If cModo != "C"
	cQuery += "AND SA3.A3_FILIAL IN (" + cFiliais + ") "
EndIf

cQuery += "AND SA3.A3_MSBLQL <> '1' AND SA3.D_E_L_E_T_ = ' ' "

LjGrvLog("LjRUsers","cQuery Vendedores",cQuery)
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTempDb,.F.,.F.)

For nCont := 1 To Len(aFilsWiz)
	If aFilsWiz[nCont, 1]
		(cTempDb)->(DbGoTop())
		While (cTempDb)->(!Eof())
			
			/* Realizado tratamento para quando a tabela SA3 esta exclusiva para não enviar o 
			mesmo vendedor sem que ele esteja cadastrado em uma determinada filial.*/
			If cModo == "E" .AND. !(AllTrim(aFilsWiz[nCont, 3]) == AllTrim((cTempDb)->A3_FILIAL))
				(cTempDb)->(DbSkip())
				Loop
			EndIf

			// A RetailApp disse que nao eh o usuario do sistemas são apenas os vendedores
			If !lIniJSon
				cJsonObj := '{"users": ['
				lIniJSon := .T.
			EndIf

			nCountObj++

			cJsonObj += "{"
			cJsonObj += '"firstName":"' + Iif(Empty(LjRLimpa(NoAcento(OemToAnsi(AllTrim((cTempDb)->A3_NREDUZ))))), ".", LjRLimpa(NoAcento(OemToAnsi(AllTrim((cTempDb)->A3_NREDUZ))))) + '",'
			cJsonObj += '"lastName":"' + Iif(Empty(LjRLimpa(NoAcento(OemToAnsi(AllTrim((cTempDb)->A3_NOME))))), ".", LjRLimpa(NoAcento(OemToAnsi(AllTrim((cTempDb)->A3_NOME))))) + '",'
			cJsonObj += '"email":"' + Iif(Empty((cTempDb)->A3_EMAIL),"teste@teste.com",RTrim((cTempDb)->A3_EMAIL)) + '",'
			cJsonObj += '"appUser":"Y",'
			cJsonObj += '"appAdmin":"N",'
			cJsonObj += '"entityName":"' + cEmpAnt + AllTrim(aFilsWiz[nCont,3]) + '",'
			cJsonObj += '"employeeID":"' + Alltrim((cTempDb)->A3_COD) + '"'
			cJsonObj += "}"

			Aadd(aRecTab, {(cTempDb)->ALIAS, (cTempDb)->RECNO})
			If nCountObj == NLIMITOBJ
				If !Empty(cJsonObj)
					cJsonObj += ']}'
					LjGrvLog("LjRUsers","Envia Vendedores")
					If lRet := LjTransfWS(cTokenCon, cJsonObj, cUrl, oSay, "users.json")
						If lRet
							LjGrvLog("LJRetailApp","Log de Exportação - LjRUsers")
							lRet := LjRLogOrd(aFilsWiz, cBeginDate, aRecTab, "LjRUsers")
							LjGrvLog("LJRetailApp","Retorno Log de Exportação - LjRUsers")
			
							LjGrvLog("LjRUsers","Sucesso")
							lIniJSon  := .F.
							nCountObj := 0
							cJsonObj  := ''
						EndIf
					Else
						LjGrvLog("LjRUsers","Falha")
					EndIf
				EndIf
			EndIf

			(cTempDb)->(DbSkip())

			If !(cTempDb)->(Eof()) .And. !Empty(cJsonObj)
				cJsonObj += ","
			EndIf
		End
		cTam := Len(cJSonObj)
		If substr(cJsonObj,cTam,cTam) != ","
			cJsonObj += ","
		Endif
	EndIf
Next nCont

If !Empty(cJsonObj) .And. Len(cJSonObj) > 1
	If SubStr(cJsonObj, Len(AllTrim(cJsonObj)), 1) == ","
		cJsonObj := Substr(cJsonObj,1,Len(cJsonObj)-1)
	EndIf
	cJsonObj += ']}'
	LjRMsg("LjRUsers - Executando Usuarios ",,oSay)
	LjGrvLog("LjRUsers","Enviando Usuários")
	lRet := LjTransfWS(cTokenCon, cJsonObj, cUrl, oSay, "users.json")	// Transmissao do users
	If lRet
		LjGrvLog("LJRetailApp","Log de Exportação - LjRUsers")
		lRet := LjRLogOrd(aFilsWiz, cBeginDate, aRecTab, "LjRUsers")
		LjGrvLog("LJRetailApp","Retorno Log de Exportação - LjRUsers")
	EndIf
Else	
	lRet := .F.
	LjGrvLog("LJRetailApp", "Não foi criado arquivo users.json - LjRUsers")
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} LjConectWS
Busca o TOKEN valido do servico
@author Mauricio Canalle
@since 01/06/2017
@return .T. - caso token valido, .F. - caso nao consiga recuperar o token
/*/
//-----------------------------------------------------------
Static Function LjConectWS(cTokenCon, cUserLog, cPassLog, cUrlLogin, oSay)
Local lRet			:= .T.
Local aHeadStr		:= {}
Local cCmdPost		:= ''
Local cRetHeadTkn	:= ''
Local aCausa		:= {}
Local cMsgErro 		:= "" //mensagem de erro do Json
Local nHttpRet		:= 0 //Retorno Http

LjRMsg( STR0002,,oSay) //"Validando conexao..."
aadd(aHeadStr,"Content-Type: application/json")
aadd(aHeadStr,"TOKEN_ONLY_RESPONSE: 1")

LjGrvLog("LjConectWS","LjConectWS","Conectando RetailApp")
//cUserLog 	:= "367@totvs.com.br"
//cPassLog	:= "Totvs2017"

cCmdPost := '{"email":"'+cUserLog+'","password":"'+cPassLog+'"}'

cTokenCon := HttpPost(cUrlLogin, "", cCmdPost, 3600 , aHeadStr , @cRetHeadTkn)

nHttpRet := HTTPGetStatus(@cMsgErro)

If Empty(cTokenCon) .or. !(nHttpRet > 199 .and. nHttpRet < 300)

   LjGrvLog("RETAILAPP","LjConectWS","Falha de Conexão: " + cUrlLogin + CHR(13)+ CHR(10) + "Erro Http " + cValToChar(nHttpRet) + " " +  cMsgErro	 )
   LjGrvLog("RETAILAPP","LjConectWS","cUrlLogin: " + cUrlLogin	 )
   LjGrvLog("RETAILAPP","LjConectWS","cCmdPost: " + cCmdPost	 )
   LjGrvLog("RETAILAPP","LjConectWS","cRetHeadTkn: " + cRetHeadTkn	 )
   LjGrvLog("RETAILAPP","LjConectWS","MV_LJRAPP0: " + SuperGetMv("MV_LJRAPP0", Nil, "")	 )
   LjGrvLog("RETAILAPP","LjConectWS","MV_LJRAPP1: " + SuperGetMv("MV_LJRAPP1", Nil, "")	 )

   lRet := .F.
   aadd(aCausa,STR0029)
   aadd(aCausa,STR0030)
   aadd(aCausa,STR0031)
   LjRMsg( STR0003 + CHR(10) + CHR(13) + STR0004 + cUrlLogin, cRetHeadTkn + CHR(13) + CHR(10) + STR0005 + CHR(13) + CHR(10),/*oSay*/ ,aCausa) //'Falha de Conexão: '#'Usuário/Senha inválidos : '#"Possíveis Causas:"
   LjGrvLog("LjConectWS","aCausa",aCausa)
   LJGerCSV("retail.json",cCmdPost,{})
Endif

LjGrvLog("LjConectWS","lRet",lRet)
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} LjTransfWS
Transmite os dados das vendas
@author Mauricio Canalle
@since 01/06/2017
@return .T. - caso transmissao OK, .F. - caso nao consiga transmitiro pacote
/*/
//-----------------------------------------------------------
Static Function LjTransfWS(cTokenCon, cJSonObj, cUrlData, oSay, cArq)
Local lRet		:= .T.
Local aHeadStr	:= {}
Local cRetHead	:= ''
Local cRetHttp	:= ''
Local cStatus	:= ''
Local nTent		:= 5
Local nCont		:= 0
Local nHttpRet	:= 0 //codigo de retorno Http

LjRMsg( STR0006,,oSay) //"Transmitindo informacoes..."

aadd(aHeadStr,"Content-Type: application/json; charset=UTF-8")
aadd(aHeadStr,"X-ZUMO-AUTH: "+Alltrim(cTokenCon))
aadd(aHeadStr,"Expect: 100-continue")

Conout(cJSonObj)

cJSonObj := EncodeUTF8(cJSonObj)
Conout(cJSonObj)

//Tento 5 vezes a transmissão...essas tentativas são feitas por conta de alguma instabilidade da rede
For nCont := 1 To nTent

	LjGrvLog("LjTransfWS","cUrlData",cUrlData)
	LjGrvLog("LjTransfWS","cJSonObj",cJSonObj)
	LjGrvLog("LjTransfWS","aHeadStr",aHeadStr)

	cRetHttp := HttpPost(cUrlData, "", cJSonObj, 3600 , aHeadStr , @cRetHead)
	nHttpRet := HttpGetStatus( @cStatus ) // Retorna o status da Conexão http

	If nCont < nTent .And. Alltrim(Upper(cStatus)) <> 'CREATED'
		LjRMsg( STR0007 + Alltrim(Str(nCont)) + STR0008 + cStatus,,oSay) //"Tentativa: "#" - Erro: "
		LjGrvLog("RETAILAPP","LjTransfWS",STR0007 + Alltrim(Str(nCont)) + STR0008 + cStatus +  "Erro Http " + cValToChar(nHttpRet) )
		Sleep(30000)
		Loop
	ElseIf nCont >= nTent .And. Alltrim(Upper(cStatus)) <> 'CREATED'
		lRet := .F.
		LjRMsg( STR0009 + cUrlData + CHR(13) + CHR(10) + Iif("Bad Gateway" $ cStatus, STR0010 ,""), cRetHead) //'Falha no Envio: '#"Falha de comunicação com o Retailapp. Não foi possível transmitir as informações. Verifique a Conexão da internet. Tente novamente mais tarde!"
		LjGrvLog("LjTransfWS","cJSonObj",cJSonObj)
		LjGrvLog("RETAILAPP","LjTransfWS",STR0009 + cUrlData + CHR(13) + CHR(10) + cStatus + CHR(13) + CHR(10) +  "Erro Http " + cValToChar(nHttpRet) )
		LJGerCSV("retail.json",cJSonObj,{})
	Else
		//LOGS DE ENVIO
		LJGerCSV(cArq,cJSonObj,{},'\retailapp\')
		LjGrvLog("LjTransfWS",cArq,"Transmitiu informações de:" + SubStr(cArq,1,At(".",cArq)-1))
		Exit
		Loop
   Endif
Next nCont

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc}LjAPICalc
Chama a API Calculate
@author Mauricio Canalle
@since 12/06/2017
@return .T. - caso transmissao OK, .F. - caso nao consiga transmitiro pacote
/*/
//-----------------------------------------------------------
Static Function LjAPICalc(cTokenCon, cUrlData, oSay)
Local lRet        := .T.
Local aHeadStr	  := {}
Local cRetHead    := ''
Local cRetHttp    := ''
Local cStatus     := ''

LjRMsg( STR0011, ,oSay) //'Realizando Cálculo...'
aadd(aHeadStr,"X-ZUMO-AUTH: "+Alltrim(cTokenCon))

cRetHttp := HttpsPost(cUrlData, "", "", 3600 , aHeadStr , @cRetHead)
HttpGetStatus( @cStatus ) // Retorna o status da Conexão http

If Alltrim(Upper(cStatus)) <> 'ACCEPTED'
   lRet := .F.
   LjRMsg( STR0012 + cUrlData, cRetHead) //'Falha no Calculo '
Endif

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} LjRMsg
Exibe as mensagens
@author Mauricio Canalle
@since 14/06/2017
@return
/*/
//-----------------------------------------------------------
Static Function LjRMsg(cMsg, cRetWs, oSay, aCausa)
Local nCont		:= 0
Local cMsgCau	:= ""

Default cMsg	:= ""
Default cRetWs	:= ""
Default oSay	:= Nil
Default aCausa	:= {}

LjGrvLog("LjRMsg","aCausa",aCausa)

If Len(aCausa) > 1
	For nCont := 1 To Len(aCausa)
		If nCont == 1
			cMsgCau	:= aCausa[nCont] + chr(13) + chr(10) + chr(13) + chr(10)
		Else
			cMsgCau += aCausa[nCont] + chr(13) + chr(10) + chr(13) + chr(10)
		EndIf
	Next nCont
EndIf
LjGrvLog("LjRMsg","cMsgCau",cMsgCau)

Conout("[RETAILAPP] [THREAD " + AllTrim(Str(ThreadId())) + "] [ " + DtoC(Date()) + " " + Time() + " ] - " + cMsg+CHR(13)+CHR(10)+cRetWs+cMsgCau)
If !isBlind()
	If oSay <> Nil
		oSay:cCaption := cMsg
		ProcessMessages()
	Else
		Alert(cMsg+CHR(13)+CHR(10)+cRetWs+cMsgCau)
	EndIf
EndIf
Return NIL

//-----------------------------------------------------------
/*/{Protheus.doc}LjValidPar
Validações dos parametros RetailApp e da seção SSLCONFIGURE do INI
@author Mauricio Canalle
@since 14/06/2017
@return .T. - caso OK, .F. - caso ocorra erro de validacao
/*/
//-----------------------------------------------------------
Static Function LjValidPar(aParams, oSay)
Local lRet     := .T.
Local cParAPP0 := SuperGetMv("MV_LJRAPP0", Nil, "")
Local cParAPP1 := SuperGetMv("MV_LJRAPP1", Nil, "")
Local aVetTrab := {}  // vetor de trabalho
Local nI       := 0
Local aKeySSL  := {{'TRYPROTOCOLS','1'}, {'HSM','0'}, {'SSL2','0'}, {'SSL3','0'}, {'TLS1','1'}, {'BUGS','1'}, {'CERTIFICATECLIENT',''}, {'KEYCLIENT',''}, {'PASSPHRASE',''}}  // Chaves obrigatorias de configuracao da secao SSL Configure

LjRMsg( STR0013,,oSay) //"Validando parametros..."
LjGrvLog("LjValidPar","Validando parametros...")


// Valida as configuracoes da secao SSL do INI do Server
aVetTrab := GetINISessions('APPSERVER.INI')  // Leitura das secoes do Server.INI
If aScan(aVetTrab, 'SSLCONFIGURE') > 0  //Valido se existe a secao SSLConfigure
	For nI := 1 to Len(aKeySSL)  //
		If GetPvProfString('SSLCONFIGURE', aKeySSL[nI,1], 'NOFOUND', 'APPSERVER.INI') == 'NOFOUND'  // valido as chaves da secao SSLCONFIGURE

			LjRMsg( STR0014 + aKeySSL[nI,1] + STR0015, STR0016) //"Chave "#" não localizada da seção SSLCONFIGURE do arquivo de INI do server"#"Verifique o arquivo de configuração"
			lRet := .F.
			LjGrvLog("LjValidPar","SSLCONFIGURE 1")
		Else
			If nI <= 6 .And. GetPvProfString("SSLCONFIGURE",aKeySSL[nI,1],"",GetAdv97()) != aKeySSL[nI,2]
				lRet := .F.

				LjRMsg( STR0017, STR0014 + aKeySSL[nI,1] + STR0018) //"Verifique o arquivo de configuração (appserver.ini) e a documentação: http://tdn.totvs.com.br/pages/releaseview.action?pageId=281982366"#"Chave"#" da seção SSLCONFIGURE configurada diferente do que o padrão estabelecido."
				LjGrvLog("LjValidPar","SSLCONFIGURE 2")
			EndIf
		Endif
	Next

	If aScan(aVetTrab, 'GENERAL') > 0
		If GetPvProfString('GENERAL', 'maxStringSize', 'NOFOUND', 'APPSERVER.INI') == 'NOFOUND'
			WritePProString("GENERAL","maxStringSize","100",GetAdv97())
			LjGrvLog("LjValidPar","GENERAL 1")
		Else
			If Val(GetPvProfString("GENERAL","maxStringSize","",GetAdv97())) < 100
				WritePProString("GENERAL","maxStringSize","100",GetAdv97())
				LjGrvLog("LjValidPar","GENERAL 2")
			EndIf
		EndIf
	EndIf
Else
	LjGrvLog("LjValidPar","Seção SSLCONFIGURE não localizada")
	LjRMsg( STR0019 , STR0016) //"Seção SSLCONFIGURE não localizada do arquivo de INI do server"#"Verifique o arquivo de configuração"
	lRet := .F.
Endif

// Valida os parametros
If !Empty(cParAPP0)
	aVetTrab := StrToKArr(cParAPP0, '|')

	If Len(aVetTrab) == 2
	    For nI := 1 to Len(aVetTrab)
    		Aadd(aParams, aVetTrab[nI])
	    Next
	Else
		LjGrvLog("LjValidPar","MV_LJRAPP0", aVetTrab)
		LjRMsg( STR0020, STR0021) //"Parâmetro MV_LJRAPP0 configurado de forma incorreta"#"Verifique se os parâmetros foram informados ou separador | foi utilizado corretamente"
		lRet := .F.
	Endif
Else
	LjGrvLog("LjValidPar","MV_LJRAPP0","Parâmetro MV_LJRAPP0 não cadastrado")
	LjRMsg("", STR0022) //"Parâmetro MV_LJRAPP0 não cadastrado"
	lRet := .F.
Endif

//PHSM -> Apenas algumas versoes do Wizard tinham 3 posicoes no primeiro param, se não tiver com 3 da erro no restante. POr esse motivo coloquei esse tratamento
If Len(aParams) < 3
	Aadd(aParams, "NaoUtilizado")
EndIf

If !Empty(cParAPP1)
	aVetTrab := StrToKArr(cParAPP1, '|')
	If Len(aVetTrab) >= 4
		For nI := 1 to Len(aVetTrab)
	    	If Upper(SubStr(aVetTrab[nI],1,1) ) == 'U' //Macro executar função para geração de TES, MV_LJRAPP1 tem tamanho limitado 
				If ExistFunc(aVetTrab[nI]) //caso a função nao exista retona que função nao existe.
					Aadd(aParams, &(aVetTrab[nI]))
					LjGrvLog("LjValidPar","MV_LJRAPP1 retorno das TES por User Function ",aParams)
				else
					LjGrvLog("LjValidPar","User Function não existe no repositorio - ",{aVetTrab[nI]})
					LjRMsg( STR0023, STR0032 + STR0021 )
					lRet := .F.	
				EndIf	
			else
				Aadd(aParams, aVetTrab[nI])	
			EndIf
	    Next
	Else
		LjGrvLog("LjValidPar","MV_LJRAPP1",aVetTrab)
		LjRMsg( STR0023, STR0021) //"Parâmetro MV_LJRAPP1 configurado de forma incorreta"#"Verifique se os parâmetros foram informados ou separador | foi utilizado corretamente"
		lRet := .F.
	EndIf

Else
	LjGrvLog("LjValidPar","MV_LJRAPP1","Parâmetro MV_LJRAPP1 não cadastrado")
	LjRMsg("", STR0024) //"Parâmetro MV_LJRAPP1 não cadastrado"
	lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc}LjREntrega
Transmite as vendas entrega
@author Mauricio Canalle
@since 16/06/2017
@return .T. - caso OK, .F. - caso ocorra erro de validacao
/*/
//-----------------------------------------------------------
Static Function LjREntrega(aSales, cBeginDate, cTokenCon, cUrl, aFilsWiz, oSay)
Local cAliasTmp	:= GetNextAlias()
Local lIniJSon  := .F.
Local cJSonObj  := ''
Local cQuery    := ''
Local lQtDeDev  := SL2->(ColumnPos("L2_QTDEDEV")) > 0
Local cQtdDev	:= ""
Local cFields	:= ""
Local cFieSum	:= ""
Local nQtdDev	:= 0
Local lRet		:= .T.
Local nCountObj	:= 0
Local lQryCateg	:= ExistBlock("LjRACatG") //P.E. para considerar outra tabela de categoria

If lQryCateg
	LjGrvLog("LjREntrega","O ponto de Entrada LjRACatG será usado para a categoria")
EndIf

If lQtDeDev // Considera devolucoes
	cQtdDev := ", SUM(L2_QTDEDEV) L2_QTDEDEV"
EndIf

cFields := "L2_FILIAL,L2_NUM,L2_EMISSAO,L1_HORA,L1_EMISNF,L2_VEND,L1_CLIENTE,L1_LOJA,"
cFields +=  "L2_PRODUTO,L1_DOCPED,L1_SERPED,B1_FILIAL,B1_COD,B1_GRUPO,L2_DESCRI"

cFieSum := ",SUM(L2_QUANT) L2_QUANT, SUM(L2_VLRITEM) L2_VLRITEM, SUM(L2_QTDEDEV) L2_QTDEDEV"

cQuery := 'SELECT DISTINCT '
cQuery += cFields
cQuery += cFieSum
cQuery += ' FROM '+RetSqlName('SL2')+' SL2'
cQuery += ' INNER JOIN '+RetSqlName('SL1')+' SL1 ON L1_FILIAL = L2_FILIAL AND L2_NUM = L1_NUM AND L2_SERIE = L1_SERIE '
cQuery += ' INNER JOIN '+RetSqlName('SB1')+' SB1 ON B1_COD = L2_PRODUTO'
cQuery += ' WHERE L1_EMISNF >= ' + "'" + cBeginDate + "' "
cQuery += " AND L2_ENTREGA <> '2' AND L2_ORCRES <> ' ' AND L2_LOJARES <> ' ' AND L2_RESERVA <> ' ' "
cQuery += " AND SL1.L1_DOCPED <> ' '  AND SL1.L1_SERPED <> ' '  AND SL1.L1_HORA <> ' ' "
cQuery += " AND SL2.D_E_L_E_T_ = ' ' AND SL1.D_E_L_E_T_ = ' '  AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " GROUP BY "
cQuery += cFields

cQuery := ChangeQuery(cQuery)

LjGrvLog("LjREntrega"," cQuery LjREntrega",cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.F.)

//Posiciona no inicio do arquivo temporario
(cAliasTmp)->(dbGoTop())

While (cAliasTmp)->(!EOF())
    If !lIniJSon
	   cJSonObj := '{"orders": ['
	   lIniJSon := 	.T.
	Endif

	If lQtDeDev  // Somente verifica o campo caso ele exista na base
		nQtdDev := (cAliasTmp)->(L2_QTDEDEV)
	EndIf

	LjRMsg("LjREntrega - Executando Vendas Entrega ",,oSay)

	nCountObj++
	cJSonObj += "{"
	cJSonObj += '"ReceiptNumber":"'+Alltrim((cAliasTmp)->(L1_DOCPED))+Alltrim((cAliasTmp)->(L1_SERPED))+'",'
	cJSonObj += '"ReceiptDate":"'+Substr((cAliasTmp)->(L1_EMISNF), 1, 4)+'-'+Substr((cAliasTmp)->(L1_EMISNF), 5, 2)+'-'+Substr((cAliasTmp)->(L1_EMISNF),7,2)+'",'
	cJSonObj += '"ReceiptTime":"'+ IIF(Empty((cAliasTmp)->(L1_HORA)),"00:00:00",(cAliasTmp)->(L1_HORA)) +'",' //Quando é SAT do TIPO ENTREGA o campo Hora nao é Gravado 
	cJSonObj += '"SKU":"' + AllTrim((cAliasTmp)->(L2_PRODUTO)) + ' - ' + LjRLimpa(LjRmvAcent(NoAcento(AllTrim((cAliasTmp)->(L2_DESCRI))))) + '",'
	cJSonObj += '"StoreID":"'+cEmpAnt+Rtrim((cAliasTmp)->(L2_FILIAL))+'",' 
	If !lQryCateg
		cJSonObj += '"Category":"'+LjRLimpa(NoAcento(Alltrim(Posicione('SBM', 1, xFilial('SBM')+(cAliasTmp)->(B1_GRUPO), 'BM_DESC'))))+'",'
	Else
		cJSonObj += '"Category":"'+LjRLimpa(NoAcento(OemToAnsi(AllTrim(ExecBlock("LjRACatG",.F.,.F.,{Alltrim((cAliasTmp)->(B1_FILIAL)),(cAliasTmp)->(B1_COD)})))))+'",'
	EndIf
	cJSonObj += '"Quantity":'+Alltrim(Str(If(((cAliasTmp)->(L2_QUANT) - nQtdDev )==0, (cAliasTmp)->(L2_QUANT), ((cAliasTmp)->(L2_QUANT) - nQtdDev ))))+','
	cJSonObj += '"CurrencyCode":'+'"BRL"'+','
	cJSonObj += '"Price":'+Alltrim(Str(Round(((cAliasTmp)->(L2_VLRITEM)/(cAliasTmp)->(L2_QUANT)),2)))+','
	cJSonObj += '"OnPromotion":'+'"N"'+','
	cJSonObj += '"Return":'+If(((cAliasTmp)->(L2_QUANT) - nQtdDev)==0, '"Y"', '"N"')+',' // caso devolucao total seta como Y
	cJSonObj += '"EmployeeID":"'+Alltrim((cAliasTmp)->(L2_VEND))+'"}'

	// Carrego o vetor com as vendas para montar na sequencia o array de pagamentos
	If aScan(aSales, {|x| x[1] == (cAliasTmp)->(L2_FILIAL) .and. x[2] == (cAliasTmp)->(L1_DOCPED) .and. x[3] == (cAliasTmp)->(L1_SERPED) .and. x[4] == (cAliasTmp)->(L1_CLIENTE) .and. x[5] == (cAliasTmp)->(L1_LOJA)}) == 0
		Aadd(aSales, {(cAliasTmp)->(L2_FILIAL), (cAliasTmp)->(L1_DOCPED), (cAliasTmp)->(L1_SERPED), (cAliasTmp)->(L1_CLIENTE), (cAliasTmp)->(L1_LOJA)})
	Endif

	If nCountObj == NLIMITOBJ
		If !Empty(cJSonObj)
			cJSonObj += ']}'
			If LjTransfWS(cTokenCon, cJSonObj, cUrl, oSay, "orders_reserva.json") .AND. Len(aSales) > 0   // Transmissao do Orders
				LjGrvLog("LjREntrega","Enviou Entregas")
				// Payments
				lRet := LjRPayments(aSales, cBeginDate, cTokenCon, cUrl, oSay, aFilsWiz)
				LjGrvLog("LjREntrega","Retorno de Envia Entregas",lRet)
			Else
				LjGrvLog("LjREntrega","Erro no envio de Entregas")
				lRet := .F.
			Endif

			lIniJSon  := .F.
			nCountObj := 0
			aSales    := {}
			cJSonObj  := ''

			If !lRet // Se deu problema na integracao retorna .F.
				Exit
			EndIf
		Endif
	Endif

	(cAliasTmp)->(dbSkip())
	If !(cAliasTmp)->(Eof()) .and. !Empty(cJSonObj)
		cJSonObj += ','
	Endif
EndDo

LjGrvLog("LjREntrega","aSales",aSales)

If !Empty(cJSonObj)
	cJSonObj += ']}'

	If LjTransfWS(cTokenCon, cJSonObj, cUrl, oSay, "orders_reserva.json") .AND. Len(aSales) > 0   // Transmissao do Orders
		LjGrvLog("LjREntrega","Envia Pagamentos Entregas")
		// Payments
		LjRPayments(aSales, cBeginDate, cTokenCon, cUrl, oSay, aFilsWiz)
		LjGrvLog("LjREntrega","Retorno de Envia Pagamentos Entregas sem retorno")
	Else
		lRet		:= .F.
	Endif
Endif

//Fecha Alias temporario
If (Select(cAliasTmp) > 0)
	(cAliasTmp)->(dbCloseArea())
EndIf

LjGrvLog("LjREntrega","Fim Envia Entrega -> lRet ",lRet)

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc}LjRMsgFim
Mensagem no final do processamento para executar a função de cálculo
@author Fábio S. dos Santos
@since 19/07/2017
@return (T) ou (F)
/*/
//-----------------------------------------------------------
Static Function LjRMsgFim(aFilsWiz,cTipo,lJob)
Local lRet		:= .F.
Local nCont		:= 0
Local cFiliais	:= ""
For nCont := 1 To Len(aFilsWiz)
	If aFilsWiz[nCont,1]
		If nCont == 1
			cFiliais := "'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		Else
			cFiliais += ",'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		EndIf
	EndIf
Next nCont
//retiro "," da primeira posição
If AT(",",cFiliais) == 1
	cFiliais := SubStr(cFiliais,2,Len(cFiliais))
EndIf

If !lJob
	MsgInfo( STR0025 + chr(13) + chr(10) + STR0026 + chr(13) + chr(10) + cFiliais) //"Processamento das filiais concluído com sucesso! "#"Filiais: "
	lRet := .T.
Else
	lRet := .T.
EndIf
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc}LJGerIni
Gera o arquivo ini na pasta informada
@author Fábio S. dos Santos
@since 30/08/2017
@return .t. ou .f.
/*/
//------------------------------------------------------------
Function LJGerIni()
Local nFileIni		:= 0
Local nI			:= 0
Local lRet			:= .T.
Local cDirCsv		:= "\retailapp\"
Local cNomeArq		:= "retail.ini"
Local aValores		:= {}

//adiciono no array as informações que serão gravadas no arquivo
aadd(aValores,{"Inventory",DtoS(dDataBase)})
aadd(aValores,{"Users",DtoS(dDataBase)})

nFileIni := FCreate(cDirCsv+cNomeArq,0,,.F.)
If nFileIni > 0

	For nI := 1 TO Len(aValores)
		FWrite(nFileIni,aValores[nI,1] + "=" + aValores[nI,2]+CRLF)
	Next nI
    FClose(nFileIni)
Else
    lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc}LjRLogOrd
Grava no campo _MSEXP a data da exportação
@author Fábio S. dos Santos
@since 31/08/2017
@return .t. ou .f.
/*/
//------------------------------------------------------------

Static Function LjRLogOrd(aFilsWiz,cBeginDate,aRecTab,cOper)
Local cQuery	:= ""
Local cFiliais	:= ""
Local nStatus	:= 0
Local nCont		:= 0
Local cAliasTmp	:= GetNextAlias()
Local _rRecno	:= 0

For nCont := 1 To Len(aFilsWiz)
	If aFilsWiz[nCont,1]
		If nCont == 1
			cFiliais := "'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		Else
			cFiliais += ",'" + AllTrim(aFilsWiz[nCont,3]) + "'"
		EndIf
	EndIf
Next nCont

//retiro "," da primeira posição
If AT(",",cFiliais) == 1
	cFiliais := SubStr(cFiliais,2,Len(cFiliais))
EndIf

//só executo a query, caso o campo esteja habilitado
If SF2->(ColumnPos( 'F2_MSEXP' )) > 0 .and. SF1->(ColumnPos( 'F1_MSEXP' )) > 0 .and. cOper == "LjROrders"

	LjGrvLog("LjRLogOrd","Atualizando tabela SF2 e SF1")

	//Posiciona na tabela pelo Recno
	For nCont := 1 To Len(aRecTab)
		IF aRecTab[nCont][1] == 'SD2'
			DbSelectArea("SF2")			
			SF2->(DbGoTo(aRecTab[nCont][2]))
			If SF2->(!EOF())
				RecLock("SF2", .F.)		
					SF2->F2_MSEXP := DtoS(dDataBase)		
				SF2->(MsUnLock()) //Confirma e finaliza a operação				
			EndIf	
			// Loop	
		Else
			DbSelectArea("SF1")			
			SF1->(DbGoTo(aRecTab[nCont][2]))
			If SF1->(!EOF())
				RecLock("SF1", .F.)		
					SF1->F1_MSEXP := DtoS(dDataBase)		
				SF1->(MsUnLock()) //Confirma e finaliza a operação
			EndIf
			// Loop	
		EndIf
	Next nCont
EndIf

If SE1->(ColumnPos( 'E1_MSEXP' )) > 0 .and. cOper == "LjRPayments"

	LjGrvLog("LjRLogOrd","Atualizando tabela SE1")
	//Atualiza MSEXP da tabela SE1
	For nCont := 1 To Len(aRecTab)
		IF aRecTab[nCont][1] == 'SE1'
			DbSelectArea("SE1")
			SE1->(DbGoTo(aRecTab[nCont][2]))
			If SE1->(!EOF())
				RecLock("SE1", .F.)		
					SE1->E1_MSEXP := DtoS(dDataBase)		
				MsUnLock() //Confirma e finaliza a operação
			EndIf
		EndIf
	Next nCont
EndIf

If SB1->(ColumnPos( 'B1_MSEXP' )) > 0 .and. cOper == "LjRInvent"

	LjGrvLog("LjRLogOrd","Atualizando tabela SB1")
	For nCont := 1 To Len(aRecTab)
		IF aRecTab[nCont][1] == 'SB1'
			DbSelectArea("SB1")
			SB1->(DbGoTo(aRecTab[nCont][2]))
			If SB1->(!EOF())
				RecLock("SB1", .F.)		
					SB1->B1_MSEXP := DtoS(dDataBase)		
					SB1->B1_HREXPO := Time()	
				MsUnLock() //Confirma e finaliza a operação
			EndIf
		EndIf
	Next nCont

EndIf

If SA3->(ColumnPos( 'A3_MSEXP' )) > 0 .and. cOper == "LjRUsers"

	LjGrvLog("LjRLogOrd","Atualizando tabela SA3")
	For nCont := 1 To Len(aRecTab)
		IF aRecTab[nCont][1] == 'SA3'
			DbSelectArea("SA3")
			SA3->(DbGoTo(aRecTab[nCont][2]))
			If SA3->(!EOF())
				RecLock("SA3", .F.)		
					SA3->A3_MSEXP := DtoS(dDataBase)		
					SA3->A3_HREXPO := Time()	
				MsUnLock() //Confirma e finaliza a operação
			EndIf
		EndIf
	Next nCont

EndIf
Return .T.

//-----------------------------------------------------------
/*/{Protheus.doc}LjRLimpa
Recebe um texto e retira os caracteres especiais
@author Fábio S. dos Santos
@since 26/02/2019
@return .t. ou .f.
/*/
//------------------------------------------------------------
Static Function LjRLimpa(cTexto)
Local aTiraCarac := {"\", "'", "ü", "ì","Å","É", "¥", "/"}
Local nI := 0

cTexto := AllTrim( StrTran(cTexto, '"', "'") )

For nI := 1 To Len(aTiraCarac)
    cTexto := AllTrim( StrTran(cTexto, aTiraCarac[nI], "") )
Next nI

Return cTexto

//-----------------------------------------------------------
/*/{Protheus.doc}RemoveAcento
Recebe um texto e retira os caracteres especiais
@author Fábio S. dos Santos
@since 26/02/2019
@return .t. ou .f.
/*/
//------------------------------------------------------------
Static Function RemoveAcento(cString)
Local nX        := 0
Local nY        := 0
Local cSubStr   := ""
Local cRetorno  := ""

Local cStrEqu   := "ABCDEFGHIJKLMNOPQRSTUVXZWY0123456789[]{}:@,.-" //char equivalente ao char especial

For nX:= 1 To Len(cString)
	cSubStr := SubStr(cString,nX,1)

	nY := At(Upper(cSubStr),cStrEqu)
	If nY > 0 .OR. cSubStr  = '"' .OR. cSubStr = ' '
		cRetorno += cSubStr
	EndIf
Next nX

Return cRetorno
