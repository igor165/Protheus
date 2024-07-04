#INCLUDE "LOJA900C.ch"
#Include 'Protheus.ch'
#Include 'TOPCONN.ch'
#INCLUDE "TBICONN.CH" 

user function tcom006()
Lj900CPr(.T.,{"0001001002","0001001003","0001001004"})
return


//-------------------------------------------------------------------
/*/{Protheus.doc} U_ECOM006
Função de teste integracao Protheus e-commerce CiaShop envio de Estoque
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900
/*/
//-------------------------------------------------------------------

User Function ECOM006 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja900C(aParam)
	 
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900C
Função de teste integracao Protheus e-commerce CiaShop envio de Estoque
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900()
/*/
//-------------------------------------------------------------------
Function LOJA900C(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA900C" //Rotina
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
	
	Lj900CPr(_lJob, ,,,, lCallStack)
	
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
/*/{Protheus.doc} LOJA900CPr(lAJob, aProd,nCnt,cCont, oWS, lCallStack)
Função de teste integracao Protheus e-commerce CiaShop envio de Estoque
@param   	lAJob- Execução em Job - Default .f.
@param   	aProd- Lista de Produtos - Default {}
@param   	nCnt - Contador de Produtos - Default 0
@param   	cCont - Codigo do Produto
@param   	oWS - Objeto WebService
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CPr(lAJob, aProd,nCnt,cCont, oWS)
/*/
//-------------------------------------------------------------------
Function Lj900CPr(lAJob, aProd,nCnt,cCont, oWS, lCallStack)

	local cSeq     := "" //Sequencia de Inclusão
	local nQtdeEst	:= 0 //Quantidade em Estoque
	local nVlrNorm	:= 0 //Preço de Venda
	Local i := 0		//Contador
	Local cTabPad	 := SuperGetMV("MV_LJECOMQ", , "001") //Tabela de Preço Padrão
	Local aMascRaiz  := &("{"+SuperGetMV("MV_MASCGRD",,"11,2,2")+"}")	 //Estrutura da Grade de Produtos
	Local cXML := "" //XML de Envio
	Local cCodigo := "" //Codigo do Produto
	Local cTabProm := SuperGetMV("MV_LJECOML", , "") //Tabela de Promoção contendo a vigência da Promoção
	Local dDataIni := Date() //Data Inicial do Job
	Local cHoraIni := Time() //Hora Inicial do Job
	Local aFilLoc  := IIF( ExistFunc("LOJX904Loc") , LOJX904Loc(), { {cFilAnt, {}} }) //Locais de Estoque EC
	Local lEstLoja :=  Len(aFilLoc) > 1 .OR. ( Len(aFilLoc) = 1 .AND. Len(aFilLoc[1]) > 1 .AND.  Len(aFilLoc[01, 02]) > 0)  
	Local cSB5Fil := xFilial("SB5") //Filial da tabela de complemento
		
	Default lAJob := .F. //Execução em Job
	default aProd := {} //Array de Produtos
	default nCnt := 1 //Contador do Laço
	default cCont := "" //Codigo do Produto
	Default oWS := NIL //WebService
	Default lCallStack := .F. //Pilha de chamadas

//mandar com macrosubstituição
	If oWS == NIL
		oWS := Lj904Ws()
	EndIf
	
	If ExistFunc("LJ900IPr")
		LJ900IPr(,lCallStack)
	EndIf

//Resultado da sincronização
	cSeq := GETSXENUM("MGM","MGM_SEQ")
	CONFIRMSX8()

	dbSelectArea("SB2")
	SB2->(DbSetOrder(1))

	dbSelectArea('SB5')
	SB5->(DbSetOrder(1))
	SB5->(DbSeek(cSB5Fil))
	
	SB1->(DbSetOrder(1))

	SB0->(DbSetOrder(1))
	
	dbSelectArea('MGR')

	If Len(aProd) == 0
	    
	    If cCont <> ""
	    	dbSelectArea("SB5")
			SB5->(DbSetOrder(1))
			SB5->(DbSeek(cSB5Fil+cCont))
		Endif
	 
		//Envia o Estoque dos Skus
		If lCallStack
			 Lj900XRC( "SB5", "LOJA900C", .T.)
		EndIf
		
		
		While SB5->(!EOF() .AND. B5_FILIAL == cSB5Fil) 
    		
			If (SB5->B5_ECFLAG == "1" ) .And. !Empty(SB5->B5_ECSEQ)  
				LjGrvLog("7 - CiaShop", "Entrou no If !Empty(SB5->B5_ECFLAG) .And. !Empty(SB5->B5_ECSEQ) "  )
				//Gera o XML - pai
				Lj900CC(cSeq, SB5->B5_COD, cTabPad, @cXML, cTabProm, lEstLoja, aFilLoc)
				cCodigo := ""
				
				//Gera o XML dos Filhos
				Lj900CFE(SB5->B5_COD, cSeq, cTabPad,aMascRaiz[1] , @cXML, cTabProm, lEstLoja, aFilLoc)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclusao dos produtos pai e filhos relacionado ao codigo                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				IF len(cXML) >= 55000
					Lj900CEX(cXML,lAJob, oWS, dDataIni, cHoraIni, cSeq)
					//Chamada recurssiva da rotina
					Lj900CPr(.F.,,,SB5->B5_COD, oWS, lCallStack)
					cXML := ""
					Exit
				EndIF
			EndIf
		
			SB5->(DBSkip())
					
		Enddo
		
	Else

		For i:=nCnt to Len(aProd)

			SB5->(DbSeek(xFilial("SB5")+ aProd[i]))

			If SB5->B5_ECFLAG <> "1" .Or. Empty(SB5->B5_ECSEQ) 
				LjGrvLog("10 - CiaShop", "Entrou no If Empty(SB5->B5_ECFLAG).Or. Empty(B5_ECSEQ) "  )
				Loop
			Endif

			IF len(cXML) >= 55000
				Lj900CEX(cXML,lAJob, oWS, dDataIni, cHoraIni, cSeq)
				Lj900CPr(.F.,aProd,i,,oWS, lCallStack)
				cXML := ""
				Exit
			EndIf
			
			Lj900CC(cSeq, SB5->B5_COD, cTabPad, @cXML, cTabProm, lEstLoja, aFilLoc)

			//Gera o XML dos Filhos
			Lj900CFE(SB5->B5_COD, cSeq, cTabPad,aMascRaiz[1] , @cXML, cTabProm, lEstLoja, aFilLoc)
	
		Next i
        
	Endif 
	
	If !Empty(cXML)
		Lj900CEX(cXML,lAJob, oWS, dDataIni, cHoraIni, cSeq)
	Endif
		
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900CEX
Envia o XML de Estoque
@param   	cXML - XML
@param   	lAJob- Execução em Job - Default .f.
@param   	oWS - WebService
@param   	dDataIni - Data Inicial do Job
@param   	cHoraIni - Hora Inicial do job
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CEX(cXML,lAJob, oWS,dDataIni, cHoraIni)
/*/
//-------------------------------------------------------------------	
Static Function Lj900CEX(cXML,lAJob, oWS,dDataIni, cHoraIni, cSeq)
Local cError := "" //Erro do parser
Local cWarning := "" //Alerta do parser
Local cRetorno := "" //Retorno
Local oRetXML := NIL //Objeto Retorno
Local lErro    := .F. //Erro de envio

Default dDataIni := Date()
Default cHoraIni := Time()
Default cSeq := "0"


	If !Empty(cXML)
		cXML := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>' +;
			'<update_stockList xmlns="dsReceipt.xsd">	' +;
			cXML +;
			'</update_stockList>'
	Endif
        
//Somente comunica se há estoque/preço para enviar
	If !Empty(cXML)
 		iif(!lAJob, Memowrit('envioQtdeEst.xml', cXML), )

		//Consome método
		If !oWs:AtualizaEstoque(, , cXML)
			lErro := .T.
			cRetorno := STR0008 //"Erro ao consumir o método 'AtualizaEstoque' do WebService!"
		Else
			iif(!lAJob, MemoWrit('retornoQtdeEst.xml', oWs:cXml), )

			//Retorna o XML parseado em um objeto com as tags em variáveis
			oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )

			If !Empty(cError)
				cRetorno := STR0009 + Chr(13) + cError //"Erro no método XmlParser: "
				cRetorno += Chr(13) + "XML: " + oWs:cXml
				lErro := .T.
			Else
				cRetorno := oWs:cXml
				lErro := !oWs:lAtualizaEstoqueResult
			Endif
		Endif
		
		dbSelectArea("MGM")
		RECLOCK("MGM", .T.)
		MGM->MGM_FILIAL  := xFilial("MGM")
		MGM->MGM_SERVIC := "LOJA900C"
		MGM->MGM_SEQ     := cSeq
		MGM->MGM_DATA    := dDataIni
		MGM->MGM_HORAIN  := cHoraIni
		If !lErro
			MGM->MGM_RESULT := "1"
		Else
			MGM->MGM_RESULT  := "2"	
		Endif
		MGM->MGM_XMLRET  := cRetorno
		MGM->MGM_HORAFI := Time()
		MGM->MGM_XMLENV := cXML
		MGM->(msUnLock())

	Endif

Return
	
	
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900CC
Gera o XML de Envio da Atualização de Estoque
@param 	cSeq - Sequencia de Inclusão  	
@param cCodigo - Codigo do Produto  	
@param cTabPad - Tabela Padrão  	
@param cXML - XML Enivo  	
@param cTabProm - Tabela Promocional
@param lEstLoja - Estoque por Ident Loja
@param aFilLoc - Filiais e Locais da Loja
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CC(cSeq, cCodigo, cTabPad, @cXML, cTabProm, lEstLoja, aFilLoc)
/*/
//-------------------------------------------------------------------
Static Function Lj900CC(cSeq, cCodigo, cTabPad, cXML, ;
						 cTabProm, lEstLoja, aFilLoc)
	
	Local nQtdeEst   := 0 //Quantidade em estoque
	Local nVlrNorm   := 0 //Preco de Venda
	Local nVlrDesc   := 0  //Desconto
	Local lAtuEst	 := .F. //Atualiza estoque
	Local lAtuPrc    := .T. //Atualiza Preço?
	Local nC		 := 0 //Contador de Lojas
	Local lAtuProm	 := ExistFunc("Lj904Prom") .AND. MGR->(ColumnPos("MGR_VLRPRO")) > 0
	Local aDtProm    := {} //Dados promocionais
	Local cXMLProm   := "" //XML da promocao
	Local nC2		 := 0 //Contador de Armazéns
	Local aLocais 	 := Array(1) //Locais de Estoque
	Local lMGUFilPed := MGR->(ColumnPos("MGR_FILARM")) > 0
	Default cTabPad	 := SuperGetMV("MV_LJECOMQ", , "001")
	Default cTabProm := SuperGetMV("MV_LJECOML", , "") //Tabela de Promoção contendo a vigência da Promoção
	

	//Preço de venda
	nVlrNorm := Lj904XPr(cCodigo, cTabPad, @lAtuPrc) 
	
	If !lAtuProm
		//Verifica se houve atualização de preço promocinal para reenviar os produtos
		If !Empty(cTabProm)
			nVlrDesc := Lj904XPr(cCodigo, cTabProm)
			If nVlrDesc > 0 .AND. nVlrDesc  < nVlrNorm
				nVlrDesc := (nVlrNorm - nVlrDesc) 
			Else
			 	nVlrDesc := 0
			EndIf
		Else
			nVlrDesc := 0
		EndIf 
	Else
		aDtProm := Lj904Prom(cTabProm, nVlrNorm, cCodigo, "LOJA904")
	EndIf
	
	If !lEstLoja
		aFilLoc[01, 02] := Array(1)
	EndIf

	DA1->(DbSetorder(1))

	For nC := 1 to Len(aFilLoc)
		
		For nC2 := 1 to Len(aFilLoc[nC, 02])
			lAtuEst := .F.
		
			If lEstLoja
				aLocais := {aFilLoc[nC, 02][nC2]}
			Else
				aLocais := {}
			EndIf
			//Calcula estoque
			nQtdeEst := Lj904XES(cCodigo, @lAtuEst,aFilLoc[nC, 01], aLocais )
			//Verifico se o item não foi excluido da tabela de Promocao caso sim gravo o valor zero para nao enviar novamente.
			If Len(aDtProm) >= 6			
				If !DA1->(DbSeek(xFilial("DA1")+ cTabProm +cCodigo))
					aDtProm[3] := 0 
				EndIf		
			EndIf
		
			//Verifica se houve alteração do saldo em estoque, preco 
			If lAtuEst  .OR. lAtuPrc  .or. Len(aDtProm) >= 6
				cXMLProm := ""
				//Inclui na tabela MGR (Log)
				RecLock("MGR", .T.)
				MGR->MGR_FILIAL  := xFilial("MGR")
				MGR->MGR_SEQ     := cSeq
				MGR->MGR_PRODUT := cCodigo
				MGR->MGR_QTDE    := Int(nQtdeEst) 
				MGR->MGR_PRECO   := nVlrNorm
				If Len(aDtProm) >= 6
					//Dados da promocao
					MGR->MGR_VLRPRO :=  aDtProm[3]
					MGR->MGR_PROINI := aDtProm[4]
					MGR->MGR_PROFIN := aDtProm[5]
					cXMLProm := aDtProm[6]
				EndIf
				
			If lEstLoja .And. lMGUFilPed
				MGR->MGR_FILARM := aFilLoc[nC, 01]
				MGR->MGR_ARMAZE := aFilLoc[nC, 02][nC2]
				MGR->MGR_ARMECO := Ljx904Arm( aFilLoc[nC, 01], aFilLoc[nC,02][ nC2])
			EndIf
				MGR->(MsUnLock())
				
				
				cXML += '<update_stock'
				
				//Código do produto
				cXML += ' sku="' + cCodigo + '"'
				
				//Quantidade limite da ciashop
				If nQtdeEst > 99999999.99
					nQtdeEst := 99999999.99
					Lj900XLg("Produto "+ AllTrim(cCodigo) +" com quantidade de estoque maior que o da ciashop - " + AllTrim(Str(nQtdeEst)) )
				EndIf 
				
				If lEstLoja
					cXML += ' armazem="' + RTrim(MGR->MGR_ARMECO) + '"'
				EndIf
				//Quantidade em estoque
				cXML += ' estoque="' + cValToChar(Int(nQtdeEst)) + '"'
				
				//Preço
				cXML += ' preco="' + cValToChar(nVlrNorm * 100) + '"'
				
				cXML += cXMLProm
				
				//Reservado
				cXML += ' xmlns=""'
				
				cXML += '/>'
			EndIf
		Next nC2
	Next nC
	
	If !lAtuProm
		//somente marca para altera o preço promocional se houve alteração no site
		Lj900CP(cCodigo, nVlrDesc)
	EndIf

	

Return 
	

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900CFE
Gera o XML do  Estoque dos produtos-filhos
@param 	cCodPai - Produto-Pai 	
@param cSeq - Sequencia de Inclusao	
@param cTabPad - Tabela Padrão  	
@param nMascRaiz - Tamanho do Codigo produto-raiz  	
@param cXML - XML Enivo
@param cTabProm - Tabela Promocional
@param lEstLoja - Estoque por Ident Loja
@param aFilLoc - Filiais e Locais da Loja
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CC(cSeq, cCodigo, cTabPad, @cXML, cTabProm, lEstLoja, aFilLoc)
/*/
//-------------------------------------------------------------------
Static Function Lj900CFE(cCodPai, cSeq, cTabPad,nMascRaiz,;
							cXML, cTabProm, lEstLoja, aFilLoc)
							
Local cCodigo := "" //Codigo Raiz do produto

	SB1->(dbSeek(xFilial("SB1")+cCodPai))
	If !Empty(SB1->B1_PRODPAI)
		cCodigo := SB1->(Left(B1_PRODPAI,nMascRaiz )) //Obtem a raiz do produto sem a variacao da grade.   
		SB1->(dbSeek(xFilial("SB1")+cCodigo))

		While SB1->(!EOF() .And. B1_FILIAL == xFilial("SB1") .And. Left(B1_COD,nMascRaiz) == cCodigo)
			SB0->(dbSeek(xFilial("SB0")+SB1->B1_COD ))
	    	If SB1->B1_PRODPAI <> SB1->B1_COD .AND. SB0->B0_ECFLAG == "1"
	    		Lj900CC(cSeq, SB1->B1_COD, cTabPad, @cXML, cTabProm, lEstLoja, aFilLoc)
	    	EndIf
	    	SB1->(DbSkip(1))
	    EndDo	

	EndIf

Return 
	
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900CP
Verifica se houve atualização dos dados promocionais
@param cCodigo - Codigo do Produto  	
@param nVlrDesc - Valor do Desconto  	
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900CP(cCodigo, nVlrDesc)
/*/
//-------------------------------------------------------------------
Static Function Lj900CP(cCodigo, nVlrDesc)
Local cAlias 	:= GetNextAlias()
Local lLock 	:= .f. //Registro Bloqueado
		
	BeginSQL Alias cAlias
	
		%noparser%

		SELECT X.*, Y.MGN_REC		
		
		FROM 
		(
			select SB1.B1_FILIAL, SB1.B1_PRODPAI, SB1.B1_COD, 'SB0' AS TABELA , SB0.R_E_C_N_O_ AS REC 
			
			FROM
			
			%table:SB0% SB0, %table:SB1% SB1
			
			WHERE
		
				SB0.B0_COD = SB1.B1_COD
				AND SB1.B1_COD = %Exp: cCodigo %
				AND SB1.B1_FILIAL = %xFilial:SB1%
				AND SB0.B0_FILIAL = %xFilial:SB0%
				AND SB1.B1_PRODPAI <> ' '
				AND SB1.D_E_L_E_T_ = ' '
				AND SB0.D_E_L_E_T_ = ' '
			
			UNION
			
			SELECT  SB1.B1_FILIAL, SB1.B1_PRODPAI, SB1.B1_COD, 'SB5' AS TABELA , SB5.R_E_C_N_O_ AS REC 
			
			FROM %table:SB5% SB5, %table:SB1% SB1
			
			WHERE
			
				SB5.B5_COD = SB1.B1_COD
				AND SB1.B1_COD = %Exp: cCodigo %
				AND SB1.B1_FILIAL = %xFilial:SB1%
				AND SB5.B5_FILIAL = %xFilial:SB5%
				AND ( SB1.B1_PRODPAI = ' ' OR SB1.B1_PRODPAI = SB1.B1_COD)
				AND SB1.D_E_L_E_T_ = ' '
				AND SB5.D_E_L_E_T_ = ' '
			) X  ,			
			(
			SELECT MGN_FILIAL, MGN_CODIGO, MGN.R_E_C_N_O_ AS MGN_REC 
			FROM %table:MGN% MGN
			WHERE
			    MGN.MGN_FILIAL  = %xFilial:MGN%
			AND MGN.MGN_VLRDES <>  %Exp: nVlrDesc %
			AND MGN.D_E_L_E_T_ = ' '
			AND MGN.MGN_SEQ = (
					SELECT MAX(MGN_2.MGN_SEQ)
					FROM %table:MGN% MGN_2
						INNER JOIN %table:MGM% MGM_2
							ON  MGM_2.MGM_FILIAL  = MGN_2.MGN_FILIAL
							AND MGN_2.MGN_CODIGO = %Exp: cCodigo %
							AND MGM_2.MGM_SEQ     = MGN_2.MGN_SEQ
							AND MGM_2.MGM_RESULT  = '1'
							AND MGM_2.D_E_L_E_T_ = ' '
					WHERE
					    MGN_2.MGN_FILIAL  = %xFilial:MGN%
					AND MGN.MGN_CODIGO = %Exp: cCodigo %
					AND MGN_2.MGN_CODIGO  = MGN.MGN_CODIGO
					AND MGN_2.D_E_L_E_T_ = ' '	)							
			) Y								
			WHERE 
		   Y.MGN_CODIGO = X.B1_COD
		   
	EndSQL
		
	Do While 	!(cAlias)->(Eof())

	If (cAlias)->TABELA == "SB0" .AND. (cAlias)->REC > 0
			
			SB0->(DbGoTo((cAlias)->REC ))
			lLock := 	Lj900XRL("SB0", .F., "LOJA900C")
			If lLock
				SB0->B0_ECDTEX := ""
				SB0->( MsUnLock() )
			EndIf
		ElseIf (cAlias)->TABELA == "SB5" .AND. (cAlias)->REC > 0
			SB5->(DbGoTo((cAlias)->REC ))
			lLock := 	Lj900XRL("SB5", .F., "LOJA900C")
			If lLock
				SB5->B5_ECDTEX := ""
				SB5->(MsUnLock() )	
			EndIf		
		EndIf
			
		(cAlias)->(DbSkip(1))
	EndDo
	
	(cAlias)->(DbCloseArea())
Return
 

 
