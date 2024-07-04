#INCLUDE "LOJA900F.ch"
#Include 'Protheus.ch'
#Include 'TOPCONN.ch'
#INCLUDE "TBICONN.CH" 


//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900F
Função de teste integracao Protheus e-commerce CiaShop envio de tabela de preço por Variante
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900()
/*/
//-------------------------------------------------------------------
Function LOJA900F(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA900F" //Rotina
Local lLock := .F. //Bloqueado
Local oLJCLocker	:= Nil               		// Obj de Controle de Carga de dados
Local lCallStack := .F. 							//Chamada de uma pilha de chamadas (1 job que chama todas as rotinas)
Local cName := "" //Chave de travamento
Local cMessage := ""

If Valtype(aParam) != "A" 
	_cEmp := cEmpAnt
	_cFil := cFilant
	
	If Valtype(aParam) = "L"
		lCallStack := aParam
	EndIf
Else

	_lJob :=  .T.
	_cEmp := aParam[1]
	_cFil := aParam[2]
EndIf

If _lJob 
	RPCSetType(3)     
	RpcSetEnv(_cEmp, _cFil,,,"LOJ" ) 	// Seta Ambiente
EndIf

//Gera SEMAFORO - para não dar erro de execução simultanea
oLJCLocker  := LJCGlobalLocker():New()
cName := cFunction+cEmpAnt+cFilAnt

lLock := oLJCLocker:GetLock( cName )

If lLock

	If  ExistFunc("Lj904IntOk") //Verifica os parametros básicos da integração e-commerce CiaShop
		If  !lCallStack .AND. !Lj904IntOk(.T., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf

	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time() ) //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
	Lj900FPr(_lJob, lCallStack)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0003) + STR0004 + DTOC(Date()) + " - " + Time()) //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]")
	EndIf
	Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0003) )	 //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900CPr(lAJob, lCallStack)
Função de teste integracao Protheus e-commerce CiaShop envio envio de tabela de preço por Variante
@param   	lAJob- Execução em Job - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900FPr(lAJob, lCallStack)
/*/
//-------------------------------------------------------------------
Function Lj900FPr(lAJob, lCallStack)

local cSeq     := "" //Sequencia de Inclusão
Local cTabPad	 := SuperGetMV("MV_LJECOMQ", , "001") //Tabela de Preço Padrão
Local cTabProm := SuperGetMV("MV_LJECOML", , "") //Tabela de Promoção contendo a vigência da Promoção
Local cXML := "" //XML de Envio
Local dDataIni := Date() //Data Inicial do Job
Local cHoraIni := Time() //Hora Inicial do Job
Local oWS := NIL //webservice
Local cAlias := GetNextAlias()
Local cECFlag := "" //Flag e-commerce 
Local cOper := "" //Operacao
Local aRecDA1 := {}
Local aRecDA0 := {} 
Local nC := 0  
Local cRetorno := "" //Retorno do Webservice
Local lErro := .F. //erro do webService
Local cError := "" // Erro no Parser 
Local cWarning  := "" //Alerta no parser
Local lAtuDA0 := .T. //Atualiza DA0
Local cTabAtu := "" //Tabela Atual
Local nPosTab := 0 //Posição da tabela

	
Default lAJob := .F. //Execução em Job
Default lCallStack := .f.

//mandar com macrosubstituição
oWS := Lj904WS()

//Consulta os produtos que deverão ser enviados
cAlias     := GetNextAlias()
Lj900FPE(cAlias, cTabPad, cTabProm, lCallStack)

//Resultado da sincronização
cSeq := GETSXENUM("MGM","MGM_SEQ")
CONFIRMSX8()

//Log de registros enviados
dbSelectArea("MGY")


While !(cAlias)->( Eof() )

	//Operação: I - Incluir
	//          D - Deletar
	//          U - Atualizar      
	
	If ( !Empty((cAlias)->DA0_DATATE) .and. (cAlias)->DA0_DATATE < dDataBase )  .OR.  (cAlias)->DA1_ATIVO == "2" .OR. !Empty( (cAlias)->DA1_EX)
		cECFlag := "2"
	Else
		cECFlag := (cAlias)->DA0_ECFLAG
	EndIf           
	       
	aAdd(aRecDA1, (cAlias)->DA1REG )
	cOper := Lj900FGO((cAlias)->DA0_CODTAB, (cAlias)->DA1_CODPRO, cECFlag, (cAlias)->DA1_ITEM, (cAlias)->DA1_DATVIG, (cAlias)->DA0REG, (cAlias)->DA1REG) 
	
	If aSCan( aRecDA0, { |cTab| cTab ==  (cAlias)->DA0REG }) = 0 
		aAdd( aRecDA0,  (cAlias)->DA0REG)
	EndIf         
	
	If !Empty(cOper)  
	
		Lj900XLg("LOJA900F " + (cAlias)->DA0_CODTAB + " " + (cAlias)->DA1_CODPRO + " " + cOper)
		Lj900FGr(cAlias,cSeq, (cAlias)->DA0_CODTAB, (cAlias)->DA1_CODPRO, (cAlias)->DA1_PRCVEN, (cAlias)->DA1_ITEM, cEcFlag)
	
		//Montagem do XML  
		cXML += '<TabelaPrecoVariante'

		//Reservado
		cXML += ' xmlns=""'
		
		cXML += ' op="' +  cOper + '"'
		
		cCodProd := alltrim((cAlias)->DA1_CODPRO)
			
		cXML += ' sku="' + cCodProd +'"'

		//Nome do produto
		cXML += ' tabelapreco="' + alltrim((cAlias)->DA0_CODTAB) + '"'

		//Preço do produto (Multiplicado por 100)
		cXML += ' list_price="' + cValToChar(NoRound((cAlias)->DA1_PRCVEN,2) * 100) + '"'     
			
		cXML += ' />'
		
		IF Len(cXML) >= 50000
			cTabAtu := alltrim((cAlias)->DA0_CODTAB)
			If (cAlias)->(!Eof())
				//Ainda está na mesma tabela DA0, sinaliza para processar novamente
				(cAlias)->(DbSkip())
				If alltrim((cAlias)->DA0_CODTAB) == cTabAtu
					nPosTab := aSCan( aRecDA0, { |cTab| cTab ==  (cAlias)->DA0REG })
					If nPosTab > 0
						aDel(aRecDA0, nPosTab)
						aSize(aRecDA0, Len(aRecDA0)-1)
					EndIf
					
				EndIf
			EndIf
			Exit
		EndIF    
		
	EndIf
	(cAlias)->(DbSkip())

EndDo

(cAlias)->(DbCloseArea() )

//Somente comunica se há preços para enviar
if !Empty(cXML) 

	cXML := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>' +;
		'<TabelaPrecoVarianteList xmlns="dsReceipt.xsd">' +;
		cXML +;
		'</TabelaPrecoVarianteList>'
	iif(!lAJob, Memowrit('envioPrVar.xml', cXML), )
	
	//Consome método
	if !oWs:TabelaPrecoVariante(, , cXML)
		lErro := .T.
		cRetorno := STR0007 //"Erro ao consumir o método TabelaPrecoVariante do WebService!"
	else
		iif(!lAJob, MemoWrit('retornorVar.xml', oWs:cXml), )

		//Retorna o XML parseado em um objeto com as tags em variáveis
		oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )

		if !Empty(cError)
			cRetorno := STR0008  + Chr(13) + cError //"Erro no método XmlParser: "
			cRetorno += Chr(13) + "XML: " + oWs:cXml
			lErro := .T.
		else
			cRetorno := oWs:cXml
			lErro := !oWs:lTabelaPrecoVarianteResult
		endif
		MemoWrit('Retorno.txt', cRetorno)
	endif
		
	DbSelectArea("MGM")
	RecLock("MGM", .T.)
	MGM->MGM_FILIAL  := xFilial("MGM")
	MGM->MGM_SERVIC := "LOJA900F"
	MGM->MGM_SEQ     := cSeq

	MGM->MGM_DATA    := dDataIni
	MGM->MGM_HORAIN  := cHoraIni
	
	MGM->MGM_XMLENV := cXML
	MGM->MGM_XMLRET  := cRetorno
	MGM->MGM_HORAFI := Time()
	If !lErro
		MGM->MGM_RESULT := "1"
	Else
		MGM->MGM_RESULT  := "2"
	EndIf
	MGM->(msUnLock())

Endif

If !lErro
	SET DELETED OFF 
	   
	    For nC := 1 to Len(aRecDA1)
	    	DA1->(DbGoTo(aRecDA1[nC]))
	    	If RecLock("DA1", .F.)
	    		DA1->DA1_ECDTEX := Dtos(Date())
	    		DA1->DA1_ECSEQ := cSeq
	    		DA1->(MsUnLock())
	    	EndIf
	    	
	    Next nC

	    For nC := 1 to Len(aRecDA0) 
	    	DA0->(DbGoTo(aRecDA0[nC]) ) 
	    	If RecLock("DA0", .F.)
	    			DA0->DA0_ECDTEX := Dtos(Date())
	    			DA0->DA0_ECSEQ := cSeq
	    			If !Empty(DA0->DA0_DATATE) .AND. DA0->DA0_DATATE <  dDataBase //Tabela venceu, inativa para não enviar novamente
	    				DA0->DA0_ECFLAG := "2"
	    			EndIf
	    			DA0->(MsUnLock())
	    	EndIf
	    Next nC  
    SET DELETED ON
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900FPE
Seleção dos preços de produtos a serem enviados
@param   	cAAlias - Alias da Consulta.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------
Static Function Lj900FPE(cAAlias, cTabPad, cTabProm, lCallStack)    

Default cAAlias := GetNextAlias()
Default cTabPad := SuperGetMV("MV_LJECOMQ", , "001") 
Default cTabProm := ""
Default lCallStack := .F.

BeginSQL Alias cAAlias
	column DA0_DATATE as Date, DA1_DATVIG  as Date   

	%noparser%
        
	SELECT  DA0.DA0_CODTAB, DA0.DA0_DATATE , DA0.DA0_ECFLAG, DA1.DA1_CODPRO, DA1.DA1_ITEM, DA1.DA1_PRCVEN, DA1.DA1_ATIVO, DA1.DA1_DATVIG,  DA1.R_E_C_N_O_ AS DA1REG, DA1.D_E_L_E_T_ AS DA1_EX, DA0.R_E_C_N_O_ AS DA0REG 
       
	FROM
	
	(select SB1.B1_COD 
	
	FROM
	
	%table:SB0% SB0, %table:SB1% SB1
	
	WHERE

		SB0.B0_COD = SB1.B1_COD
		AND SB1.B1_FILIAL = %xFilial:SB1%
		AND SB0.B0_FILIAL = %xFilial:SB0%
		AND SB1.B1_PRODPAI <> ' '
		AND SB0.B0_ECFLAG   <> ' '
		AND SB0.B0_ECDTEX  <> ' '
		AND SB1.D_E_L_E_T_ = ' '
		AND SB0.D_E_L_E_T_ = ' '
	
	UNION
	
	SELECT  SB1.B1_COD 
	
	FROM %table:SB5% SB5, %table:SB1% SB1
	
	WHERE
	
		SB5.B5_COD = SB1.B1_COD
		AND SB1.B1_FILIAL = %xFilial:SB1%
		AND SB5.B5_FILIAL = %xFilial:SB5%
		AND ( SB1.B1_PRODPAI = ' ' OR SB1.B1_PRODPAI = SB1.B1_COD)
		AND SB5.B5_ECFLAG   <> ' '
		AND SB5.B5_ECDTEX  <> ' '
		AND SB1.D_E_L_E_T_ = ' '
		AND SB5.D_E_L_E_T_ = ' ' ) XB1, 
	%table:DA0% DA0, %table:DA1% DA1   
	WHERE 
 		( ( DA1.DA1_ECDTEX  = ' '  AND DA0.DA0_ECDTEX = ' ' AND DA0.D_E_L_E_T_ = ' ') OR /*TABELA ATIVA E PRODUTO ALTERADO*/
 		  (	DA1.DA1_ECDTEX  <> ' '  AND /* PRODUTO NAO ATERADO E "*/
   			( ( ( DA0.DA0_ECDTEX = ' ' AND DA0.DA0_ECFLAG = '2' )   OR  /* PRODUTO NAO ALTERADO E TABELA INATIVA (DELETADA OU NAO) OU   "*/
          		(DA0.DA0_DATATE <> ' ' AND DA0.DA0_DATATE <  %Exp: dDataBase% AND DA0_ECFLAG <> '2' AND DA0.DA0_ECDTEX <> ' ' AND DA0.D_E_L_E_T_ <> ' ')    /* PRODUTO NAO ALTERADO E TABELA VENCIDA E  NAO EXCLUIDA "*/
      			)  
      		) 
          ) 
      	) AND
	DA1.DA1_CODPRO = XB1.B1_COD	AND
	DA0.DA0_CODTAB = DA1.DA1_CODTAB AND 
	DA0.DA0_FILIAL = DA1.DA1_FILIAL AND  
	DA1.DA1_DATVIG <= %Exp: dDataBase%  AND
	DA1.DA1_FILIAL = %xFilial:DA1%	AND
	DA0.DA0_ECFLAG <> ' '  AND
	( DA0.DA0_CODTAB <> %Exp: cTabPad% AND DA0.DA0_CODTAB <> %Exp: cTabProm% )  AND
	DA0.DA0_FILIAL = %xFilial:DA0%  	
	ORDER BY DA0_CODTAB,  DA1_CODPRO, DA1_ITEM

EndSQL 

If lCallStack
	 Lj900XRC( cAAlias, "LOJA900F")
EndIf

Return 


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900FGr
Grava os dados enviados 
@param   	cAlias - Alias da Consulta
@param   	cSeq- Sequencia
@param   	cCodTab - Tabela de Preco
@param   	cCodProd -  Codigo da Variante
@param   	nPrcVen - Preço de Venda
@param		cItemTab - Item da Tabela de Preco
@param   	cEcFlag - Ativo e-commerce?
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900FGr(cAlias,cSeq, cCodTab, cCodProd, nPrcVen, cItemTab, cEcFlag)
/*/
//-------------------------------------------------------------------
Static Function Lj900FGr(cAlias,cSeq, cCodTab, cCodProd, nPrcVen, cItemTab, cEcFlag)    

Default cAlias 		:= ""
Default cSeq 		:= ""
Default cCodTab 	:= "" 
Default cCodProd 	:= ""
Default nPrcVen 	:= 0
Default cItemTab 	:= "" 
Default cEcFlag 	:= ""

RecLock("MGY", .T.)
MGY->MGY_FILIAL  := xFilial("MGY")
MGY->MGY_SEQ     := cSeq    
MGY->MGY_CODTAB	 := cCodTab
MGY->MGY_PRODUT  := cCodProd
MGY->MGY_PRCVEN  := nPrcVen
MGY->MGY_ITEM 	 := cItemTab
MGY->MGY_ECFLAG  := cEcFlag
MGY->(MsUnLock() )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900FGO
Verifica qual a operação a ser realizada I - Inclusão ou U - Alteração
@param		cCodTab - Codigo da tabela de preco 
@param   	cAProd - Codigo do Produto  
@param		cECFlag - Ativo e-commerce? 
@param 		cItem - Item da tabela de Preco 
@param		dDatVig - Vigencia do Item
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900FGO(cCodTab, cAProd, cECFlag, cItem, dDatVig)
/*/
//-------------------------------------------------------------------
Static Function Lj900FGO(cCodTab, cAProd, cECFlag, cItem, dDatVig, nRecDA0, nRecDA1)

local cQuery   := "" //Consulta
local cAliaLoc := GetNextAlias() //Alias da Consulta
local cRet     := "I" //Retorno da Rotina    

Default cCodTab 	:= "" 
Default cAProd 		:= ""
Default cECFlag 	:= "" 
Default cItem 		:= "" 
Default dDatVig 	:= CtoD("")

//Verifica se é a ultima sequencia 
//Se não for ignora o registro
cQuery := " SELECT 1 "
cQuery += " FROM  " + RetSqlName("DA1") + " DA1, " 
cQuery +=  RetSqlName("DA0") + " DA0 " 
cQuery += " WHERE DA1.DA1_FILIAL = '" + xFilial("DA1") + "' " 		
cQuery += " AND DA1.DA1_ITEM <> '" + cItem + "' " 
If cECFlag <> "2" 		
	cQuery += " AND (  DA1.DA1_ECDTEX <> ' '  )"  
EndIf		
cQuery += " AND DA1.DA1_CODTAB = '" + cCodTab + "' "
cQuery += " AND DA1.DA1_DATVIG >= " + ValtoSql(dDatVig)  + " "		
cQuery += " AND DA1.DA1_DATVIG <= " + ValtoSql(dDataBase)  + " "
cQuery += " AND DA1.R_E_C_N_O_ <> " + ValtoSql(nRecDA1) + " "		
cQuery += " AND DA1.DA1_CODTAB = '" + cCodTab + "'  "
cQuery += " AND DA0.DA0_CODTAB  = DA1.DA1_CODTAB  "
cQuery += " AND DA0.R_E_C_N_O_ = " + ValtoSql(nRecDA0) + "  "
cQuery += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "
cQuery += " AND DA0.DA0_FILIAL = '" + xFilial("DA0") + "' "
cQuery += " AND DA1.DA1_CODPRO = '" + cAProd + "' "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliaLoc, .F., .T.)    


lSeqAtv := (cAliaLoc)->(Eof()) //Ultimo regsitro válido
(cAliaLoc)->(DbCloseArea()) 

If lSeqAtv          

	cQuery := " SELECT 1 "
	cQuery += " FROM  " + RetSqlName("MGY") + " MGY "
	cQuery += " INNER JOIN " + RetSqlName("MGM") + " MGM "
	cQuery += " ON MGM.MGM_FILIAL = MGY.MGY_FILIAL "
	cQuery += " AND MGM.MGM_SEQ = MGY.MGY_SEQ "
	cQuery += " AND MGM.D_E_L_E_T_ <> '*' "
	cQuery += " AND MGM.MGM_RESULT = '1' "
	cQuery += " WHERE MGY.MGY_FILIAL = '" + xFilial("MGY") + "' "
	cQuery += " AND MGY.MGY_CODTAB = '" + cCodTab + "' "
	cQuery += " AND MGY.MGY_PRODUT = '" + cAProd + "' "
	cQuery += " AND MGY.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliaLoc, .F., .T.)

	if !(cAliaLoc)->(Eof()) 
		 If cECFlag == "2"  //Inativo   
		 	cRet := "D"
		 Else
			cRet := "U"
		 EndIf
	Else  
		 If cECFlag == "2"   //Inativo 
			cRet := ""
	     EndIf 
	endif

	(cAliaLoc)->(DbCloseArea())    
Else
	cRet := "" //Não processar o registro
EndIf
       
Return  cRet    

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ECOM015
Função de teste integracao Protheus e-commerce CiaShop envio de tabela de preço por Variante
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900
/*/
//-------------------------------------------------------------------

User Function ECOM015 //Teste e-commerce

aParam := {"T1","D MG 01",,"DEBUG"}
Loja900F(aParam)
	
Return