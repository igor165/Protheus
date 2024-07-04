#INCLUDE "LOJA900A.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} U_ECOM002
Função de teste integracao Protheus e-commerce CiaShop envio de Produtos
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@sample U_ECOM001
/*/
//-------------------------------------------------------------------

User Function ECOM002 //Teste e-commerce

	aParam := {"T1","D MG 01",,"DEBUG"}
	Loja900A(aParam)
	
REturn

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900A
Função de teste integracao Protheus e-commerce CiaShop envio de Produtos 
@param   	aParam - Array contendo os dados de execução em Schedule onde: [1] - Empresa, [2] - Filial, [4] - Tarefa
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LOJA900A()
/*/
//-------------------------------------------------------------------
Function LOJA900A(aParam)
local _lJob := .F. //Execução em Job
Local _cEmp := nil //Empresa
Local _cFil := nil //Filial
Local cFunction := "LOJA900A" //Rotina
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
		If   !lCallStack .AND. !Lj904IntOk(.T., @cMessage)
			Lj900XLg(cMessage,"") 	
		EndIf
	EndIf
	Lj900XLg(STR0001 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4] , STR0005) + STR0003 + DTOC(Date()) + " - " + Time() ) //######### //"INICIO DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
	Lj900APr(_lJob, lCallStack)
	
	Lj900XLg(STR0005 + cFunction + "[" + cEmpAnt+cFilAnt + "]"  + IIF(_lJob, STR0002 + aParam[4] , STR0005) + STR0003 + DTOC(Date()) + " - " + Time()) //######### //"FIM DO PROCESSO "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "###" - EM: "
	
Else
	If !IsBlind()
		MsgAlert(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]")
	EndIf
	Lj900XLg(STR0006 + cFunction + "[" + cEmpAnt+cFilAnt + "]" + IIF(_lJob, STR0002 + aParam[4], STR0005) )	 //###### //"JÁ EXISTE EXECUÇÃO DA ROTINA "###" - SCHEDULE - Tarefa "###" - SMARTC/PILHA CHAMADA "
EndIf

If lLock
	oLJCLocker:ReleaseLock( cName )
EndIf

If _lJob
	RPCClearEnv()
EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900APr
Função de teste integracao Protheus e-commerce CiaShop envio de Produtos 
@param   	lAJob - Execução via Schedule - Default .f.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900APr()
/*/
//-------------------------------------------------------------------
Function Lj900APr(lAJob, lCallStack)

	local cXML       := "" //XML ENVIO
	Local oWS			:= NIL //Objeto WebService
	Local cError     := ""	//Erro Parser
	Local cWarning   := ""	//Alerta Parser
	local oRetXML		:= NIL	//Retorno Parseado
	local cAlias		:= NIL //Alias da Consulta
	local cSeq       := ""	//Sequencia de Execução da Rotina
	local lErro      := .F.	//Erro da Rotina
	local cRetorno   := ""	//XML Retorno
	local dIniOferta := CToD("01/01/1975") //Data Inicio da Oferta
	local dFimOferta := CToD("01/01/2049") //Final da Oferta
	local nQtdeEst	:= 0 //Quantidade em Estoque
	local nVlrNorm	:= 0 // Valor Normal
	local aAlerts    := {}	//Altertas
	local nInd			:= 0 //Contadort
	Local cTabPad	 := SuperGetMV("MV_LJECOMQ", , "001") //Tabela de Preço  - Cenário de Vendas
	Local cTabProm := SuperGetMV("MV_LJECOML", , "") //Tabela de Promoção contendo a vigência da Promoção
	Local cCodProd	:= "" //Codido do Produto
	Local cMascGrd := SuperGetMV("MV_MASCGRD",,"11,2,2") //Estrutura da Grade
	Local aRecSB0 := {}	//Registros a atualizas
	Local aRecSB5 := {}	//Registros a Atualizar
	Local lVariante := .F. //Produto possui variantes?
	Local cVarDes := "" 	//Descrição da Variante
	Local cVarVal := ""  //Valor da Variante
	Local cVarDes2 := ""	//descrição 2 da variante
	Local cVarVal2 := "" //Valor 2 da variante
	Local cImgFile := "" //Arquivo de imagem
	Local cTitulo := "" //Titulo
	Local cVarAtiva := "" //Variavel Ativa?
	Local dDataIni := Date() //Data Inicial do Job
	Local cHoraIni := Time() //Hora Inicial do Job
	Local nTotRecSB0 	:= 0 //Total de Detalhe do Produto enviado
	Local nTotRecSB5	:= 0 //Total de Complemento de Produto enviado
	Local nI 			:= 0 //Condtador
	Local lLock 		:= .F. //Registro Bloqueado
	Local cMotErr 		:= "" //Motivo do Erro
	Local cCodAnt 		:= "" //Produto anterior
	Local lErroWS 		:= .F. // Erro do WS
	Local lSemPrcSB5 	:= .f. //produto sem preço no SB5
	Local nPrcSB5 		:= 0 //Preço do SB5
	Local cXMLVar 		:= "" //XML da Variante
	Local cXMLProd 		:= "" //Node XML
	Local lSB5Cad 		:= .T. //produto cadastrado no SB5
	Local lRegSel 		:= .F. //Registros selecionados
	Local nPeso 			:= 0 //Valor do peso
	Local nAltura 		:= 0 //altura
	Local nLargura 		:= 0 //largura
	Local nCompr 			:= 0 //comprimento
	Local lInvalidCd 		:= .f. //Codigo Invalido
	Local lProcProd 		:= .F. //Processa produto
	Local aAreaPE 		:= {} //WorkArea do Ponto de Entrada
	Local lPe900AGP 		:= ExistBlock("Lj900AGP") //Ponto de Entrada
	Local lNoProdPE 		:= .F. //sem produtos no P.E
	Local lSendPrc 		:= .T. //Envia preço de venda
	Local lB0Dim		:= SB0->(ColumnPos("B0_ECPROFU") > 0 .AND. ColumnPos("B0_ECCOMP") > 0 .AND. ColumnPos("B0_ECLARGU") > 0 )//Existe campos da Dimensão SB0?
	Local lB5Dim		:= SB5->(ColumnPos("B5_ECCOMP") > 0 .AND. ColumnPos("B5_ECLARGU") > 0 ) //Existe campos da Dimensão SB5?
	Local nAlturaP 		:= 0 //altura do pai
	Local nLarguraP 		:= 0 //largura do pai
	Local nComprP 		:= 0 //Comprimento do Pai
	Local lAgrup			:= SuperGetMv("MV_LJECMM3",.F.,.F.) //Utiliza o cadastro de agrupadores
	Local aDtProm			:= {} //Array com os Dados de Promoção
	Local aFilLoc  := IIF( ExistFunc("LOJX904Loc") , LOJX904Loc(), { {cFilAnt, {}} } ) //Array com os Locais de estoque
	Local nC			:= 0 //Contador de Local de Estoque
	Local lMultEst	:= .F. //Funcionalidade de multiestoque habilitada
	Local lLj904Prom			:= ExistFunc("Lj904Prom") //Dados da Promoção
	Local cEAN			:= "" //Codigo de Barras do produto
	Local lB5_ECTITU	:= SB5->(ColumnPos("B5_ECTITU")) > 0  // Campo titulo 
	Local nPesoP		:= 0 //Peso do Produto-pai
	
	Default lAJob := .F.
	Default lCallStack := .F.

	//mandar com macrosubstituição
	oWS := Lj904WS()

	//** Sincroniza as categorias
	LOJA900(.T.)
	
	If !lLj904Prom 
		//Não existe o componente de envio dos dados da promoção
		dbSelectArea("DA0")
		DA0->(DbSetOrder(1))
		If !Empty(cTabProm)
			if DA0->(DbSeek(xFilial("DA0") + cTabProm))
				dIniOferta := DA0->DA0_DATDE
				dFimOferta := DA0->DA0_DATATE
			endif
		EndIf
	EndIf

	dbSelectArea("SB2")
	SB2->(DbSetOrder(1))

	dbSelectArea("DA1")
	DA1->(DbSetOrder(1))

	dbSelectArea("ACV")
	ACV->(DbSetOrder(5))

	//Consulta os produtos que deverão ser enviados
	cAlias     := GetNextAlias()
	Lj900APE(cAlias, lCallStack)

	//Resultado da sincronização
	cSeq := GETSXENUM("MGN","MGN_SEQ")
	CONFIRMSX8()



	//Log de registros enviados
	dbSelectArea("MGN")

	cProdAux := ""
	
	//Verifica se a funcionalide de multiestoque está habilitada
	lMultEst := Len(aFilLoc) > 1 .OR. ( Len(aFilLoc) = 1 .AND. Len(aFilLoc[1]) > 1 .AND.  Len(aFilLoc[01, 02]) > 0) 

	While !(cAlias)->( Eof() )
		
		lInvalidCd := .F.
		
		lInvalidCd :=  At(space(1), AllTrim((cAlias)->B1_COD)) > 0
		Lj900XLg("(cAlias)->B1_COD ", (cAlias)->B1_COD )
		
		lVariante := !Empty((cAlias)->B1_PRODPAI)
		SB5->( dbSetOrder(1) )
		Lj900XLg( "(cAlias)->B1_PRODPAI)" , (cAlias)->B1_PRODPAI )
		If lVariante
			SB5->( dbSeek( xFilial("SB5") + (cAlias)->B1_PRODPAI ) )
		Else
			SB5->( dbSeek( xFilial("SB5") + (cAlias)->B1_COD ) )
		EndIf
		
		lProcProd := SB5->(Found()) //Processa produto
		
		If lProcProd .AND. lPe900AGP
			aAreaPE := GetArea()
			lProcProd := ExecBlock("Lj900AGP",.F.,.F., {(cAlias)->B1_COD, (cAlias)->B1_PRODPAI, lVariante ,  "1"})
			RestArea(aAreaPE)
		EndIf
		
		If lProcProd
		
			lRegSel := .T.
			Lj900XLg( "SB5->B5_COD" , (cAlias)->B1_PRODPAI )

			nQtdeEst := 0
			nVlrNorm := 0
			nVlrDesc := 0
			cVarDes := ""
			cVarVal := ""
			cVarDes2 := ""
			cVarVal2 := ""
			cImgFile := ""
			cTitulo := ""
			cVarAtiva := ""
			cMotErr := ""
			lSemPrcSB5 := .f.
			nAlturaP 		:= 0 //altura do pai
			nLarguraP 		:= 0 //largura do pai
			nComprP 		:= 0 //Comprimento do Pai
			nAltura		:= 0//altura
			nLargura		:= 0//largura
			nCompr			:= 0//Comprimento
			If lB5Dim 
				nAlturaP := SB5->B5_ECPROFU //altura
				nLarguraP := SB5->B5_ECLARGU  //largura
				nComprP := SB5->B5_ECCOMP //Comprimento
			EndIf	
				
			//XML node das variantes
			cXMLVar := ""
			cXMLProd := "" //Node XML
			lSB5Cad := RTrim((cAlias)->B1_PRODPAI) ==  RTrim((cAlias)->B1_COD) 
			cEAN := ""
	
			If !lAgrup
			//Categoria
				ACV->( dbSetOrder(5) )
				ACV->( dbSeek( xFilial("ACV") + SB5->B5_COD ) )
			EndIf
			
			lSendPrc := .T.
			//Sem variante ou produto-pai varia
			If !lVariante .OR. lSB5Cad
				lSendPrc := .T.
				nPrcSB5 :=  Lj904XPr( (cAlias)->B1_COD  , cTabPad, .F., @lSendPrc) 
				lSemPrcSB5 := lSendPrc .AND. nPrcSB5 = 0
			EndIf
			
			IF (!lAgrup .AND. !ACV->( Found() ) ) .OR. lSemPrcSB5 .OR. lInvalidCd
				
				If lInvalidCd
					aAdd(aAlerts, AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(SB5->B5_CEME) + STR0014) //"Codigo de Produto Invalido"
					Lj900XLg( AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(SB5->B5_CEME) + STR0014)//"Codigo de Produto Invalido"
					cMotErr := "4"			
				ElseIf (!lAgrup .AND. !ACV->( Found() ) )
					aAdd(aAlerts, AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(SB5->B5_CEME) + STR0009) //": Categoria não informada"
					Lj900XLg( AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(SB5->B5_CEME) + STR0009 )///": Categoria não informada"
					cMotErr := "1"
				Else
					cMotErr := "2"
					aAdd(aAlerts, AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(SB5->B5_CEME) + " " + STR0015 + " ["+ cTabPad +"]") //"Produto sem preço vigente na tabela de preço padrão"
					Lj900XLg( AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(SB5->B5_CEME) + " " + STR0015 + " ["+ cTabPad +"]" )//"Produto sem preço vigente na tabela de preço padrão"
	
				EndIf
				Lj900AGr(cAlias, cSeq, 0, 0, ;
								"", "", "", "",; 
								"", "", "", cMotErr, ;
								0/*peso*/, nAltura , nLargura, nCompr )	
												
				(cAlias)->(DbSkip())			

			Else
				
				//Montagem do XML
				cXMLProd += '<product'
		
				//Reservado
				cXMLProd += ' xmlns=""'
		
				//Operação: I - Incluir
				//          D - Deletar
				//          U - Atualizar
				cXMLProd += ' op="' + Lj900AGO((cAlias)->B1_COD)  + '"'
				
				cCodProd := alltrim(SB5->B5_COD)
		
				//Código do produto
				IF lVariante
					cCodProd := "VAR"+cCodProd
					
				EndIF
				
				cXMLProd += ' pf_id="' + cCodProd +'"'
		
				//Nome do produto
				cXMLProd += ' name="' + alltrim(_NoTags(IIf( lB5_ECTITU .And. !Empty(SB5->B5_ECTITU) , SB5->B5_ECTITU,SB5->B5_CEME))) + '"'
		
				//Rápida descrição
				cXMLProd += ' short_description="' + _NoTags(Iif(SB5->B5_ECFLAG == '2' .And. Empty(SB5->B5_ECDESCR), "x", StrTran(Alltrim(SB5->B5_ECDESCR),"."," ")))+'"' //se tiver 
		
				//Moeda
				cXMLProd += ' currency="1046"'
		
				//Preço do produto (Multiplicado por 100)
				cXMLProd += ' list_price="' + cValToChar(nVlrNorm * 100) + '"'
		
				//Bloqueado
				if SB5->B5_ECFLAG == '2'
					cXMLProd += ' bloqueado="S"'
					nPeso := Iif(SB5->B5_PESO == 0, 1, SB5->B5_PESO) //peso
					If lB5Dim 
						nAlturaP	:= Iif(SB5->B5_ECPROFU == 0, 1, SB5->B5_ECPROFU)  //altura
						nLarguraP	:= Iif(SB5->B5_ECLARGU == 0, 1, SB5->B5_ECLARGU)  //largura
						nComprP		:= Iif(SB5->B5_ECCOMP == 0, 1, SB5->B5_ECCOMP) //Comprimento
					EndIf
																
				else
					cXMLProd += ' bloqueado="N"'
		
					//Peso em gramas
					nPeso := SB5->B5_PESO
					If nPeso = 0
						nPeso := SB5->B5_ECPESOE
					EndIf
				endif
						
				//Armazena o Peso do Produto-pai
				nPesoP := nPeso
				cXMLProd += ' weight="' + cValToChar(Int(nPesoP * 1000)) + '"'
		
				//Recomendado
				cXMLProd += ' recomendado="S"'
		
				//Quantidade máxima de vezes sem que o preço do produto
				//pode ser divido aplicando a fórmula de juros
				cXMLProd += ' parcela_comjuros="0"'
		
				//Quantidade máxima de vezes sem que o preço do produto
				//pode ser divido sem aplicar a fórmula de juros
				cXMLProd += ' parcela_semjuros="1"'
		
				//Quantidade em estoque
		
				//Tipo de desconto:
				// $ = Desconto por valor
				// % = Desconto percentual
				cXMLProd += ' disc_type="%"'
		
				//Desconto em percentual atribuído ao produto
				cXMLProd += ' disc_perc="0"'
		
				//Desconto em valor atribuído ao produto (Multiplicado por 100)
				cXMLProd += ' disc_value="0"'
		
				//Data inicial do desconto
				cXMLProd += ' disc_start="1975-01-01"'
		
				//Data final do desconto
				cXMLProd += ' disc_end="1975-01-02"'
		
				//Valor do produto em oferta (Multiplicado por 100)
				cXMLProd += ' sale_price="' + cValToChar(nVlrNorm * 100) + '"'
				
				//dADOS DA OFERTA  - vai na variante
		
				//Arquivo de imagem do produto
				//(Deve estar presente na loja virtual)
				cXMLProd += ' image_file="' +alltrim(SB5->B5_ECIMGFI)+'"'
		
				//Atributo em destaque do produto
				cXMLProd += ' atributo1=""'
		
				//Atributo em destaque do produto
				cXMLProd += ' atributo2=""'
		
				//Estado do produto
				//0 = Produto novo
				//1 = Produto semi-novo
				cXMLProd += ' semi_novo="0"'
		
				IF lVariante //!Empty(Posicione("SB1",1,xFilial("SB1")+(cAlias)->B1_COD,"B1_VARDES"))
					cVarDes :=  _NoTags(Lj900ARGrd(cMascGrd, SB5->B5_COD,  1, 1, SB5->B5_COD))
					cVarDes2 := _NoTags(Lj900ARGrd(cMascGrd, SB5->B5_COD,  1, 2, SB5->B5_COD))
				endif
				
				cXMLProd += ' attr_label1="'+cVarDes+'"'
				cXMLProd += ' attr_label2="'+cVarDes2+'"'
		
				//Valor para a cubagem em cm3
				cXMLProd += ' cubagem="' + cValToChar(Int(SB5->B5_ECCUBAG)) + '"'
		
				//Data de lançamento do produto
				cXMLProd += ' lancamento="' + Lj900ADt(SB5->B5_ECDTLAN) + '"'		
				//Palavras-Chave do Produto
				cXMLProd += ' keywords="' + AllTrim(_NoTags(SB5->B5_ECPCHAV)) + '"'
		
				//Prazo de disponibilidade do produto
				cXMLProd += ' availability=""'
		
				//Habilita / Desabilita variante no site
				//cXML += ' variante_ativa="1" '
				cXMLProd += '>'
		
				If !lVariante .OR. lSB5Cad
					aAdd(aRecSB5,  SB5->(Recno()))
					Lj900XLg( AllTrim((cAlias)->B1_COD) + "Produto com iformações na SB5")
					
				EndIf
		
				//*********************************************************************
				//Lista de Variantes
				cXMLProd += '<variantList xmlns="">'
	
	
				cCodAnt := (cAlias)->B1_COD 
				cCodPai := (cAlias)->B1_PRODPAI
			
				While !(cAlias)->( Eof() ) .And. (  (cAlias)->B1_PRODPAI == cCodPai .or. !lVariante)
					lSendPrc := .T.
					
					SB0->( dbSetOrder(1) )
					SB0->( dbSeek( xFilial("SB0") + (cAlias)->B1_COD ) )
					
					lProcProd := .T. //processa produto
					
					If lPe900AGP
						aAreaPE := GetArea()
						lProcProd := ExecBlock("Lj900AGP",.F.,.F., {(cAlias)->B1_COD, (cAlias)->B1_PRODPAI, lVariante ,  "2"})
						RestArea(aAreaPE)						
					EndIf
					
					If lProcProd
						lRegSel := .T.
						If lVariante .AND. (cAlias)->B1_COD  <> cCodAnt
							//Se for outro produto, zera a variável de erro
							cMotErr := ""
							cCodAnt := (cAlias)->B1_COD 
						EndIf
		
						//troca de pai
						IF lVariante .AND. !Empty(SB0->B0_ECPAIAN)
							//exclui o antigo
							cRetorno := lj900AEF(SB0->B0_ECPAIAN,(cAlias)->B1_COD , oWS)
							//verifica se houve erro
							IF !Empty(cRetorno)
								aAdd(aAlerts, STR0010 +cRetorno) //"Excluir variante: "
							Else
								//limpa campo da pai anterior
								RecLock("SB0",.F.)
								SB0->B0_ECPAIAN := ""
								SB0->B0_ECDTEX := Dtos(Date())
								SB0->(msUnLock())
							EndIF
						EndIF
						
						//Atualiza a quantidade em estoque

						nQtdeEst := 0					
						If !lMultEst
							For nC := 1 to Len(aFilLoc)
								nQtdeEst += Lj904XES((cAlias)->B1_COD,, aFilLoc[nC, 01], aFilLoc[nC, 02])
							Next nC 
						EndIf
						nVlrNorm := Lj904XPr((cAlias)->B1_COD, cTabPad, .T., @lSendPrc) 
						nAltura := nAlturaP
						nLargura := nLarguraP
						nCompr := nComprP
						nPeso := nPesoP
						cEAN := ""
						
						If Empty((cAlias)->B1_PRODPAI) .or. (cAlias)->B1_COD == cCodPai
							cTitulo := _NoTags(SB5->B5_ECTITU)
							cImgFile := _NoTags(SB5->B5_ECIMGFI)
							cVarAtiva := _NoTags(SB5->B5_ECFLAG)
							If SB5->(ColumnPos("B5_ECEAN1")) > 0
								cEAN := SubStr(SB5->B5_ECEAN1,1,15)
							EndIf
						Else
							cTitulo := _NoTags(SB0->B0_ECTITU)
							cImgFile := _NoTags(SB0->B0_ECIMGFI)
							cVarAtiva := _NoTags(SB0->B0_ECFLAG)
							If lB0Dim  .AND. SB0->( B0_ECPROFU > 0 .OR. B0_ECCOMP > 0 .OR. B0_ECLARGU > 0 )
								nAltura := SB0->B0_ECPROFU
								nLargura := SB0->B0_ECLARGU
								nCompr := SB0->B0_ECCOMP									
							EndIf
							If (cAlias)->B1_PESBRU > 0
								nPeso :=  (cAlias)->B1_PESBRU
							EndIf
						EndIf

						If Empty(cEAN)
							cEAN := SubStr((cAlias)->B1_CODBAR,1,15)
						EndIf
						If nVlrNorm = 0 .AND. lSendPrc
						
							aAdd(aAlerts, AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(StrTran(SB5->B5_CEME,"'")) +  " " + STR0015 + " ["+ cTabPad +"]") //"Produto sem preço vigente na tabela de preço padrão"                                                                                                                                                                                                                                                                                                                                                                                                                                                               
							Lj900XLg( AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(StrTran(SB5->B5_CEME, "'")) +  " " + STR0015 + " ["+ cTabPad +"]" )//"Produto sem preço vigente na tabela de preço padrão"                                                                                                                                                                                                                                                                                                                                                                                                                                                               
							cMotErr := "2"
							Lj900AGr(cAlias, cSeq, nVlrNorm, 0, ;
									cVarDes, "", cVarDes2, "",; 
									"", "", "", cMotErr,;
									nPeso,  nAltura , nLargura, nCompr )								
	
						ElseIf (nAltura + nLargura + nCompr) > 0 .AND. (nAltura = 0 .OR. nLargura = 0 .OR. nCompr = 0  )
							aAdd(aAlerts, AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(StrTran(SB5->B5_CEME,"'")) + STR0016) //"Produto sem altura e/ou largura e/ou profundidade"
							Lj900XLg( AllTrim((cAlias)->B1_COD) + ' - ' + AllTrim(StrTran(SB5->B5_CEME, "'")) + STR0016 ) //Produto sem altura e/ou largura e/ou profundidade
							cMotErr := "3"
							Lj900AGr(cAlias, cSeq, nVlrNorm, 0, ;
									cVarDes, "", cVarDes2, "",; 
									"", "", "", cMotErr,;
									nPeso,  nAltura , nLargura, nCompr )	

						Else
						
			
							//*********************************************************************
							//Primeira variante
							cXMLVar += '<variant'
			
							//Reservado
							cXMLVar += ' xmlns=""'
			
							//Operação: I - Incluir
							//          D - Deletar
							//          U - Atualizar
							cXMLVar += ' op="' + Lj900AGO((cAlias)->B1_COD)  + '"'
			
							//Código do produto
							cXMLVar += ' pf_id="' + cCodProd + '"'
			
							//Código da variante
							cXMLVar += ' sku="' + Alltrim((cAlias)->B1_COD) + '"'
			
							//Quantidade máxima de vezes sem que
							//pode ser divido aplicando a fórmula de juros
							cXMLVar += ' parcela_comjuros="0"'
			
							//Quantidade máxima de vezes sem que o preço da variante
							//pode ser divido sem aplicar a fórmula de juros
							cXMLVar += ' parcela_semjuros="1"'
			
							//Variante principal do produto
							cXMLVar += ' default_var="0"'				
							
							//Valor do atributo 1/2
							IF lVariante //!Empty(Posicione("SB1",1,xFilial("SB1")+(cAlias)->B1_COD,"B1_VARDES"))
								cVarVal := _NoTags(Lj900ARGrd(cMascGrd, (cAlias)->B1_COD,  2, 1, (cAlias)->B1_PRODPAI))
								cVarVal2 := _NoTags(Lj900ARGrd(cMascGrd, (cAlias)->B1_COD,  2, 2, (cAlias)->B1_PRODPAI))
							endif
							cXMLVar += ' attr_value1 ="'+cVarVal+'"'
							cXMLVar += ' attr_value2="'+cVarVal2+'"'
	
							cXMLVar += ' ean="'+cEAN+'"'
							
							//Preço do produto (Multiplicado por 100)
							cXMLVar += ' list_price="' + cValToChar(nVlrNorm * 100) + '"'
							
							nVlrDesc := 0
							
							If !lLj904Prom 
								//Apura os dados da tabela de preco promocao
								If !Empty(cTabProm) .AND. ( Empty(dFimOferta) .OR. dFimOferta >= Date() )
									nVlrDesc := Lj904XPr((cAlias)->B1_COD, cTabProm,,@lSendPrc)
									If nVlrDesc > 0 .AND. nVlrDesc  < nVlrNorm
										nVlrDesc := (nVlrNorm - nVlrDesc) 
									Else
									 	nVlrDesc := 0
									EndIf
								Else
									nVlrDesc := 0
								EndIf
								If nVlrDesc = 0
								//PreçoPromocional (Multiplicado por 100)
								//Estamos enviado o ultimo preco enviado de date()-2 ate date()-1
								// pois esta é uma unica forma de enviar uma exclusão de tabela de preço					

							 		//Busca o ultimo preço promocional enviado para o produto
							 		nVlrDesc := Lj900APP((cAlias)->B1_COD)
							 		If nVlrDesc > 0
										aDtProm := { nVlrDesc,nVlrNorm,(nVlrNorm - nVlrDesc), Lj900ADt(Date()-2) , Lj900ADt(Date()-1) }
									EndIf
									nVlrDesc := 0
								Else
									dDataVig := dDatabase-1
									aDtProm := { nVlrDesc,nVlrNorm,(nVlrNorm - nVlrDesc), dDataVig, dFimOferta, ""}
									aDtProm[6] += ' sale_price="' + cValToChar(aDtProm[3] * 100) + '"'+;
													' sale_end="' + Lj900ADt(iif(aDtProm[2]> 0, aDtProm[5], CToD("01/01/2049"))) + '"'+;
													' sale_start="' + Lj900ADt(iif(aDtProm[2]> 0, aDtProm[4], CToD("01/01/1975"))) + '"'
								EndIf
								
							Else
								aDtProm := Lj904Prom(cTabProm, nVlrNorm, (cAlias)->B1_COD, "LOJA900A")
							EndIf
			
							If Len(aDtProm) >= 6 .AND. aDtProm[1] > 0
							
								//Verifico se o item não foi excluido da tabela de Promocao caso sim gravo o valor zero para nao enviar novamente.
								DA1->(DbSetorder(1))
								If !DA1->(DbSeek(xFilial("DA1")+ cTabProm +(cAlias)->B1_COD))
									nVlrDesc := 0 
								Else
									nVlrDesc := aDtProm[1]	
								EndIf								
								dDataVig := aDtProm[4]
								dFimOferta := aDtProm[5]
								cXMLVar += aDtProm[6]
								
							EndIf
	
					
							cVarAtiva := iif( cVarAtiva == '1', '1', '0') 
							
							//Arquivo de imagem do produto
							//(Deve estar presente na loja virtual			
							
							cXMLVar += ' image_file="' + alltrim(cImgFile)+'"' 
							//Descrição da variante
							cXMLVar += ' description_var="' + AllTrim(cTitulo) + '"'
			
							//Quantidade em estoque
							If !lMultEst
								cXMLVar += ' quantity="' + cValToChar(Int(nQtdeEst)) + '"'
							EndIf
		
							//Habilita / Desabilita variante no site
							// variante_ativa
							cXMLVar += ' variante_ativa="' + cVarAtiva + '"'
							

							If nAltura > 0 .AND. nLargura > 0 .AND. nCompr > 0
			               	//Largura 
			                  cXMLVar += ' width="' + cValToChar(Int(nLargura * 100 )) + '"' 
			                   
			                  //Altura
			                  cXMLVar += ' height="' + cValToChar(Int(nAltura * 100)) + '"'
			                   
			                  //Comprimento da embalagem
			                  cXMLVar += ' length="' + cValToChar(Int(nCompr * 100)) + '"' 
		                  Else
								nAltura := 0
								nLargura := 0
								nCompr := 0
		                  EndIf
		
		                  	//Peso da Variante, obtido do cadastro de produtos
		                  	cXMLVar += ' weight="' + cValToChar(Int(nPeso * 1000)) + '"'
		                  	
							cXMLVar += '/>'
			
			
							//Inclui na tabela MGN (Log)
							Lj900AGr(cAlias, cSeq, nVlrNorm, nVlrDesc, ;
									cVarDes, cVarVal, cVarDes2, cVarVal2,; 
									cImgFile, cTitulo, cVarAtiva, cMotErr,;
									nPeso,  nAltura , nLargura, nCompr  )
							
							If !(Empty((cAlias)->B1_PRODPAI) .or. (cAlias)->B1_COD == cCodPai) .AND. SB0->(Found())
								aAdd(aRecSB0,  SB0->(Recno()))
								Lj900XLg( AllTrim((cAlias)->B1_COD) + "Produto com variante")
							EndIf
							
						EndIf
					
					Else
					
							
							If !(Empty((cAlias)->B1_PRODPAI) .or. (cAlias)->B1_COD == cCodPai) .AND. SB0->(Found())
								aAdd(aRecSB0,  SB0->(Recno()))
								Lj900XLg( "Produto não enviado para integração em virtude do P.E. Lj900AGP", AllTrim((cAlias)->B1_COD))
							EndIf	
							
							lNoProdPE := .t.				
					
					EndIf
		
					//Encerra lista de variantes do produto
					//********************************************************************
					(cAlias)->(DbSkip())
					If !lVariante
						Exit
					EndIf
				Enddo
			
				//Existem nos amarrados a variante
				If !Empty(cXMLVar)
				//Encerra tag do produto
					cXMLVar += '</variantList>'
					cXMLProd += (cXMLVar + '</product>')
					cXML += cXMLProd
				EndIf							
				
			EndIF 
	
			
			IF len(cXML) >= 50000
				Exit
			EndIF
		Else
			If SB5->(Found())
				aAdd(aRecSB5,  SB5->(Recno()))
				Lj900XLg( " Produto não enviado para integração em virtude do P.E. Lj900AGP", AllTrim((cAlias)->B1_COD))		
				(cAlias)->(DbSkip())
				lNoProdPE := .T.
			EndIf
		EndIF

	EndDO
	dbSelectArea(cAlias)
	DbCloseArea()

	IF Len(aAlerts) > 0
		//cXML  := ""
		lErro := .T.
		if !lAJob
			FormBatch("Problemas encontrados nos produtos...", aAlerts, { { 1, .T., {|| FechaBatch()} }} )
		endif
		for nInd := 1 to Len(aAlerts)
			cRetorno += aAlerts[nInd] + ";" + Chr(13) + Chr(10)
		next nInd
	EndIF

	if !Empty(cXML)
		cXML := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>' +;
			'<productList xmlns="dsReceipt.xsd">' +;
			cXML +;
			'</productList>'
	endif
	MemoWrit('cXML.xml', cXML)
	MemoWrit('cRetorno.txt', cRetorno)


	lErroWS := .F.
	//Somente comunica se há produtos para enviar
	if !Empty(cXML)
		iif(!lAJob, Memowrit('envioProd.xml', cXML), )

		//Consome método
		Lj900XLg("oWs:Produtos horas", Time() )
		if !oWs:Produtos(, , cXML)
			lErroWS := .T.
			cRetorno := STR0012 //"Erro ao consumir o método Produtos do WebService!"
			lNoProdPE := .f.
		else
			iif(!lAJob, MemoWrit('retornoProd.xml', oWs:cXml), )

			//Retorna o XML parseado em um objeto com as tags em variáveis
			oRetXML := XmlParser(oWs:cXml, "_", @cError, @cWarning )

			if !Empty(cError)
				cRetorno := STR0013  + Chr(13) + cError //
				cRetorno += Chr(13) + "XML: " + oWs:cXml
				lErro := .T.
			else
				cRetorno := oWs:cXml
				lErro := !oWs:lProdutosResult
			endif
		endif
	Else
		cXML := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>' +;
			'<productList xmlns="dsReceipt.xsd">' +;
			cXML +;
			'</productList>'
		lErroWS := .T.
		//cRetorno := ""
	EndIf	
	If !lErroWS .or. lNoProdPE //Não foram executados produtos no P.E.

		nTotRecSB0 := Len(aRecSB0)
		nTotRecSB5	:= Len(aRecSB5)

		For nI := 1 to nTotRecSB0
			SB0->(DbGoto(aRecSB0[nI]))
			lLock := .F.
			
			lLock := 	Lj900XRL("SB0", .F., "LOJA900A")
				
			
			If lLock
				SB0->B0_ECDTEX := DtoS(Date())
				If lRegSel 
					SB0->B0_ECSEQ := cSeq
				EndIf
				SB0->(MsUnLock())
			EndIf
		
		Next nI
		
		
		For nI := 1 to nTotRecSB5
			SB5->(DbGoto(aRecSB5[nI]))
			
			lLock := .F.
			
			lLock := 	Lj900XRL("SB5", .F., "LOJA900A")
				
			
			If lLock

				SB5->B5_ECDTEX := DtoS(Date())
				If lRegSel 
					SB5->B5_ECSEQ := cSeq
				EndIf 
				SB5->(MsUnLock() )
			EndIf
		Next nI

	EndIf
	
	If lRegSel //Registros selecionados, gera o log
		dbSelectArea("MGM")
		RECLOCK("MGM", .T.)
		MGM->MGM_FILIAL  := xFilial("MGM")
		MGM->MGM_SERVIC := "LOJA900A"
		MGM->MGM_SEQ     := cSeq
	
		MGM->MGM_DATA    := dDataIni
		MGM->MGM_HORAIN  := cHoraIni
		
		MGM->MGM_XMLENV := cXML
		MGM->MGM_XMLRET  := cRetorno
		MGM->MGM_HORAFI := Time()
		If !lErroWS
			MGM->MGM_RESULT := "1"
		Else
			MGM->MGM_RESULT  := "2"
		EndIf
		MGM->(msUnLock())
	EndIf


	
	//** Sincroniza as categorias X produtos
	Lj900XLg("LOJA900BPr aguardando 5 segundos", Time() )
	Sleep(5000)
	Lj900XLg("Executando o LOJA900B", Time() )
	LOJA900B(.T.)

//** Sincroniza caracteristicas
	Lj900XLg("Lj900DPr aguardando 5 segundos", Time() )
	Sleep(5000)
	Lj900XLg("Executando o Lj900D", Time() )
	LOJA900D(.T.)



Return
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900APE
Seleção dos produtos a serem enviados
@param   	cAAlias - Alias da Consulta.
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------
Static Function Lj900APE(cAAlias, lCallStack)
	Local cSpcPrdPa := Space(TamSx3("B1_PRODPAI")[1]) //Tamanho do campo Produto -Pai
	Default lCallStack := .F.


	BeginSQL Alias cAAlias
	
		%noparser%

		SELECT X.* FROM
		
		(
		select SB1.B1_PRODPAI, SB1.B1_COD, SB1.B1_CODBAR, SB1.B1_PESBRU
		
		FROM
		
		%table:SB0% SB0, %table:SB1% SB1
		
		WHERE
	
			SB0.B0_COD = SB1.B1_COD
			AND SB1.B1_FILIAL = %xFilial:SB1%
			AND SB0.B0_FILIAL = %xFilial:SB0%
			AND ( SB1.B1_PRODPAI <> ' ' OR SB1.B1_PRODPAI <> %Exp:cSpcPrdPa%)
			AND SB1.B1_PRODPAI <> SB1.B1_COD
			AND SB0.B0_ECFLAG   <> ' '
			AND SB0.B0_ECDTEX  = ' '
			AND SB1.D_E_L_E_T_ = ' '
			AND SB0.D_E_L_E_T_ = ' '
		
		UNION
		
		SELECT  SB1.B1_PRODPAI, SB1.B1_COD , SB1.B1_CODBAR, SB1.B1_PESBRU
		
		FROM %table:SB5% SB5, %table:SB1% SB1
		
		WHERE
		
			SB5.B5_COD = SB1.B1_COD
			AND SB1.B1_FILIAL = %xFilial:SB1%
			AND SB5.B5_FILIAL = %xFilial:SB5%
			AND ( SB1.B1_PRODPAI = ' ' OR SB1.B1_PRODPAI = SB1.B1_COD OR SB1.B1_PRODPAI = %Exp:cSpcPrdPa%)
			AND SB5.B5_ECFLAG   <> ' '
			AND SB5.B5_ECDTEX  = ' '
			AND SB1.D_E_L_E_T_ = ' '
			AND SB5.D_E_L_E_T_ = ' '

		)X
		
		ORDER BY X.B1_PRODPAI, X.B1_COD
		

	EndSQL
	
	If lCallStack
		 Lj900XRC( cAAlias, "LOJA900A")
	EndIf
return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900ADt
Formata da Data para envio
@param   	dAData - Data
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample LJ900Pr(.F.)
/*/
//-------------------------------------------------------------------
Static Function Lj900ADt(dAData)

	local cData := "" //Retorno da Rotina

	default dAData := Date()

	if Empty(dAData)
		dAData := Date()
	endif
	
	cData := TransForm(DTos(dAData), "@R 9999-99-99")

return cData

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900AGr
Grava os dados enviados 
@param   	cAlias - Alias da Consulta
@param   	cSeq- Execução em Job - Default .f.
@param   	nVlrNorm- Valor do Produto
@param   	nVlrDesc - Valor do Desconto
@param   	cVarDes - Descricao da Variante
@param   	cVarVal - Valor da Variante
@param   	cVarDes2 - Descricao da 2 variante
@param   	cVarVal2 - Valor da 2 variante
@param   	cImgFile - Arquivo de Imagem
@param   	cTitulo - Titulo
@param   	cVarAtiva- Variavel ativa
@param		cMotErr - Motivo do Erro
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900AGr(cAlias,cSeq,nVlrNorm, nVlrDesc,	cVarDes, cVarVal, cVarDes2, cVarVal2, 	cImgFile, cTitulo, cVarAtiva)
/*/
//-------------------------------------------------------------------
Static Function Lj900AGr(cAlias,cSeq,nVlrNorm, nVlrDesc, ;
						cVarDes, cVarVal, cVarDes2, cVarVal2, ;
						cImgFile, cTitulo, cVarAtiva, cMotErr,;
						nPeso ,nAltura, nLargura , nCompr )

	RecLock("MGN", .T.)
	MGN->MGN_FILIAL  := xFilial("MGN")
	MGN->MGN_SEQ     := cSeq
	MGN->MGN_CODIGO  := (cAlias)->B1_COD
	MGN->MGN_DESC    := cTitulo
	MGN->MGN_PESOBR := NoRound(nPeso,3)
	MGN->MGN_BLQECO := cVarAtiva

	MGN->MGN_BREDES := SB5->B5_ECDESCR
	MGN->MGN_PCHAVE  := SB5->B5_ECPCHAV
	MGN->MGN_CUBAGE := Int(SB5->B5_ECCUBAG)
	MGN->MGN_DTLANC  := SB5->B5_ECDTLAN
	MGN->MGN_PRCPRO  := nVlrNorm
	MGN->MGN_VLRDES  := nVlrDesc
	MGN->MGN_IMGFIL := cImgFile
	MGN->MGN_VARDES	:= cVarDes
	MGN->MGN_VARIAN	:= cVarVal
	MGN->MGN_VARDE2	:= cVarDes2
	MGN->MGN_VARIA2	:= cVarVal2
	If MGN->(ColumnPos("MGN_MOTERR")) > 0
		MGN->MGN_MOTERR := cMotErr
	EndIf

 	If MGN->(ColumnPos("MGN_ECPROF")) > 0
		MGN->MGN_ECPROF := NoRound(nAltura,2)
	EndIf
 
 	If MGN->(ColumnPos("MGN_ECLARG")) > 0
		MGN->MGN_ECLARG := NoRound(nLargura,2)
	EndIf

  	If MGN->(ColumnPos("MGN_ECCOMP")) > 0
		MGN->MGN_ECCOMP := NoRound(nCompr,2)
	EndIf 
	
	MGN->(MsUnLock())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900AGO
Verifica qual a operação a ser realizada I - Inclusão ou U - Alteração
@param   	cAProd - Codigo do Produto
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900AGO(cAProd)
/*/
//-------------------------------------------------------------------
Static Function Lj900AGO(cAProd)

	local cQuery   := "" //Consulta
	local cAliaLoc := GetNextAlias() //Alias da Consulta
	local cRet     := "I" //Retorno da Rotina

	cQuery += " SELECT 1 "
	cQuery += " FROM  " + RetSqlName("MGN") + " MGN "
	cQuery += " INNER JOIN " + RetSqlName("MGM") + " MGM "
	cQuery += " ON MGM.MGM_FILIAL = MGN.MGN_FILIAL "
	cQuery += " AND MGM.MGM_SEQ = MGN.MGN_SEQ "
	cQuery += " AND MGM.D_E_L_E_T_ <> '*' "
	cQuery += " AND MGM.MGM_RESULT = '1' "
	cQuery += " WHERE MGN.MGN_FILIAL = '" + xFilial("MGN") + "' "
	cQuery += " AND MGN.MGN_CODIGO = '" + cAProd + "' "
	cQuery += " AND MGN.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery),cAliaLoc, .F., .T.)

	if !(cAliaLoc)->(Eof())
		cRet := "U"
	endif

	(cAliaLoc)->(DbCloseArea())

return cRet
//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900AEF
Gera o XML de Exclusão da Variante
@param   	cPaiAnt -Codigo do Pai a ser excluido
@param   	cCodigo -Produto a ser excluido
@param   	oWs - WebService
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900AEF(cPaiAnt, cCodigo, oWS)
/*/
//-------------------------------------------------------------------	
Static Function Lj900AEF(cPaiAnt, cCodigo, oWS)

	Local cXmlFilho := '<?xml version="1.0" encoding="ISO-8859-1" standalone="no" ?>' //XML de Envio

	Local cError := "" //Erro do parser
	Local cWarning := "" //Alerta do parser 
	Local cRetorno := "" //Retorno

	cXmlFilho += '<variantList xmlns="dsReceipt.xsd">'
	cXmlFilho += '<variant xmlns=""'
	cXmlFilho += ' op="D"'
	cXmlFilho += ' pf_id="' + "VAR"+cPaiAnt +'"'
	cXmlFilho += ' sku="'+ alltrim(cCodigo) +'"'
	cXmlFilho += ' parcela_comjuros="0"'
	cXmlFilho += ' parcela_semjuros="6"'
	cXmlFilho += ' default_var="1"'
	cXmlFilho += ' />'
	cXmlFilho += '</variantList>'

	//Consome método
	IF !oWS:Variantes(, , @cXmlFilho)
		cRetorno := STR0007 //"Erro ao consumir o método 'Produtos' do WebService!"
	Else
		//Retorna o XML parseado em um objeto com as tags em variáveis
		oRetXML := XmlParser(oWS:cXml, "_", @cError, @cWarning )

		IF !Empty(cError)
			cRetorno := STR0008 + Chr(13) + cError //"Erro no método XmlParser: "
			cRetorno += Chr(13) + "XML: " + oWS:cXml
		EndIF
	EndIF

Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900ADG
Retorna as informações da Grade 
@param   	cMascGrd - Estrutura da Grade
@param   	cCodigo - Codigo do Produto
@param   	nRet - Tipo do Retorno: 1 - Descrição da Linha/Coluna [default], 2 - Valor da Linha/Coluna
@param   	nAtributo - Sequencia do Atributo 1[default] ou 2
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900ARGrd(cMascGrd, cCodProd,  nRet, nAtributo)
/*/
//-------------------------------------------------------------------
Function Lj900ARGrd(cMascGrd, cCodProd,  nRet, nAtributo, cProdPai, lSendVar)
	Local aDadosGrd := {} //Array com Dados da Grade
	Local nGrdRaiz	:= 0 //Valor da Raiz
	Local nGrdLin		:= 0 //Tamanho da Linha
	Local nGrdCol		:= 0 //Tamanho da Coluna
	Local nGrdLC   	:= 0 //Tamanho Lin + Coluna
	Local cZrCol := ""	//Coluna Zerada	
	Local cZrLin := "" //Linha Zerada
	Local cRet := "" //Retorno
	Local cFilSB4 := xFilial("SB4") //Filial SB4
	Local cFilSBV :=  xFilial("SBV") //Filial SBV
	Local aAreaSB4 := {} //WorkArea SB4
	Local aAreaSBV := {} //WorkArea SBV
	Local cValor := "" //Valor do Produto
	Local cLinha := "" //Valor da Linha do Produto
	Local cColuna := "" //Valor da Coluna do Produto
	Local lZrLnPai := .F. //Linha do Pai Zerada?
	Local lZrClPai := .F. //Coluna do Pai Zerada?
	Local cPaiLn	:= ""	//Valor da Linha do Pai
	Local cPaiCl	:= "" //Valor da Coluna do Pai
	
	
	Default cMascGrd := SuperGetMV("MV_MASCGRD",,"11,2,2")
	Default cCodProd := ""
	Default nRet  := 1
	Default nAtributo := 1
	Default cProdPai := cCodProd
	Default lSendVar := .F.
	
		aDadosGrd := &("{"+cMascGrd+"}")
		
		nGrdRaiz	:= aDadosGrd[1]
		nGrdLin		:= aDadosGrd[2]
		nGrdCol		:= aDadosGrd[3]
		nGrdLC   	:= (nGrdLin + nGrdCol)
		cZrLin		:= Replicate("0",nGrdLin)
		cZrCol		:= Replicate("0",nGrdCol)
		cLinha :=  Substr(cCodProd, nGrdRaiz + 1 ,nGrdLin)
		cColuna := Substr(cCodProd, nGrdRaiz + nGrdLin + 1, nGrdCol)
		cPaiLn	:= Substr(cProdPai, nGrdRaiz + 1 , nGrdLin)	//Valor da Linha do Pai
		cPaiCl	:= Substr(cProdPai,nGrdRaiz + nGrdLin + 1, nGrdCol) //Valor da Coluna do Pai
		lZrLnPai := cPaiLn == cZrLin
		lZrClPai := cPaiCl == cZrCol
		

	If !Empty(cCodProd) .AND. ( lSendVar .OR.  !( cLinha == cZrLin .AND. cColuna == cZrCol .AND. lZrLnPai .AND. lZrClPai ) )
		aAreaSB4 := SB4->(GetArea())
	
		If nAtributo == 1 
			Do Case
			Case  lSendVar .OR. ( cLinha != cZrLin .OR. !lZrLnPai )
				//Descrição do atributo
				cRet := Posicione("SB4",1,cFilSB4+SubStr(cCodProd,1,nGrdRaiz),"B4_LINHA")
				If nRet == 1
					cRet := Lj900ADG(cRet)      
				Else
				//valor do atributo
					aAreaSBV := SBV->(GetArea())
					cRet := AllTrim(Posicione("SBV",1,xFilial("SBV")+cRet+cLinha,IIF(nRet == 2, "BV_DESCRI","BV_TABELA")))   
					RestArea(aAreaSBV) 
				EndIf
			
			Case lSendVar .OR. ( cLinha == cZrLin .AND. lZrLnPai)  //Condicao 2
				cRet := Posicione("SB4",1,xFilial("SB4")+SubStr(cCodProd,1,nGrdRaiz),"B4_COLUNA")
				If nRet == 1 
					cRet :=	Lj900ADG(cRet)   
				Else
					aAreaSBV := SBV->(GetArea())
					cRet := AllTrim(Posicione("SBV",1,xFilial("SBV")+cRet+cColuna,"BV_DESCRI"))   
					RestArea(aAreaSBV)         
				EndIf
			
			EndCase
			
		Else //nAtributo == 2
			Do Case
			Case lSendVar .OR. ( (cLinha != cZrLin .OR. !lZrLnPai)  .AND. ( cColuna != cZrCol  .OR. !lZrClPai) )
				cRet := Posicione("SB4",1,xFilial("SB4")+SubStr(cCodProd,1,nGrdRaiz),"B4_COLUNA")
				If nRet == 1
					cRet := Lj900ADG(cRet) 
				Else
					aAreaSBV := SBV->(GetArea())
					cRet := AllTrim(Posicione("SBV",1,xFilial("SBV")+cRet+cColuna,IIF(nRet == 2, "BV_DESCRI","BV_TABELA"))) 
					RestArea(aAreaSBV)   
				EndIf     
 			EndCase	 
		EndIf
		RestArea(aAreaSB4)
	EndIf


Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900ADG
Retorna a Descrição da Grade 
@param   	cCodigo - Codigo da Grade
@author  Varejo
@version 	P11.8
@since   	27/10/2014
@obs     
@sample Lj900ADG(cCodigo)
/*/
//-------------------------------------------------------------------
Static Function Lj900ADG(cCodigo)

Local aArea      := GetArea()  //Salva a area atual
Local cDescricao := ""         //Descricao do produto na grade.

Default cCodigo := ""

DbSelectArea("SBV")
DbSetOrder(1) //BV_FILIAL+BV_TABELA+BV_CHAVE

DbSeek(xFilial("SBV")+cCodigo)

While !( Eof() ) .And. (BV_FILIAL+BV_TABELA == xFilial("SBV")+cCodigo)

	If  !( Empty(BV_DESCTAB) )
		cDescricao := Alltrim(BV_DESCTAB)
		Exit
	EndIf

	DbSkip()
End	


RestArea(aArea)

Return cDescricao

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900XRL
Realiza o bloqueio do Registro
@param   	cTabela - Alias da Tabela.
@param   	lAppend - Insere Registro.
@param   	cRotina - Nome da Rotina.
@author  Varejo
@version 	P11.8
@Return 	lRet - Bloqueou o registro .t./.f.
@since   	27/10/2014
@obs     
@sample Lj900XRL("SB5", .f., "LOJA900A")
/*/
//-------------------------------------------------------------------
Function Lj900XRL(cTabela, lAppend, cRotina)

Local lRet := .F. //Retorno
Local cMsgLock := "" //Mensagem

Default lAppend := .F.
Default cTabela := Alias()
Default cRotina := FunName()

If !lAppend

	If (cTabela)->(Rlock())
			Reclock(cTabela, lAppend)
			lRet := .T.
	Else
		If ( RddName() == 'TOPCONN' )
	    	cMsgLock := TCInternal(53)
	    	IF !Empty(cMsgLock)
	      		Lj900XLg("Origem: " + cRotina + " Registro bloqueado pelo usuario" + Chr(13)+Chr(10) + StrTran("Usuário:"+cMsgLock,"|",Chr(13)+Chr(10)+" Função:") )  //"Usuário:"  ## | //" Função:"
	    	Endif
		EndIf
	EndIf	
Else
	lRet := Reclock(cTabela, lAppend)
EndIf	
					
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900XRC
Realiza a Contagem dos registros selecionados
@param   	cTabela - Alias da Tabela.
@param   	cFunction - Nome da Rotina
@param   	lTopConn - Tabela em TopConn (física) - Default .f.
@author  Varejo
@version 	P11.8
@Return 	nTotRec - Total de Registros
@since   	13/07/2015
@obs     
@sample  Lj900XRC( "TMPSL1", "LOJA907" )
/*/
//-------------------------------------------------------------------
Function Lj900XRC( cTabela, cFunction, lTopConn )
Local nRecAtu := 0 //Registro Atual
Local nTotRec := 0 //total de Registros


Default cTabela := Alias()
Default cFunction := FunName()
Default lTopConn := .F.



If (cTabela)->(!Eof())
	Lj900XLg(cFunction + " Registro Inicial " + cValTochar((cTabela)->(Recno())))
	nRecAtu := (cTabela)->(Recno())
	If !lTopConn
		If nRecAtu > 1
			(cTabela)->(DbGoTop())	
		EndIf
		(cTabela)->(DbEval({ || nTotRec := nTotRec + 1} ))
		(cTabela)->(DbGoTop())
	Else
		nTotRec := (cTabela)->(RecCount())
		(cTabela)->(DbGoTo(nRecAtu))
	EndIf

EndIf

Lj900XLg(cFunction + " Registros selecionados " + cValTochar( nTotRec))

If (cTabela)->(!Eof())
	Lj900XLg(cFunction + " Registro Inicial " + cValTochar((cTabela)->(Recno())))
EndIf

Return nTotRec

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900XLg
Gera o Log do e-commerce no console.log e sigaloja.log

@param   cTexto - Texto do Log
@param   cChave - Chave do Log
@param   xVar   - Conteudo da variavel
@author  Rafael Tenorio da Costa
/*/
//-------------------------------------------------------------------
Function Lj900XLg(cTexto, cChave, xVar)

    Local cMensagem := DtoC( Date() )+ " " + Time()

    Default cTexto := ""    //Texto do log
    Default cChave := ""    //Chave do log

    If Valtype(cChave) == "N"
        cChave := cValToChar(cChave)
    EndIf

    If !Empty(cChave)
        cMensagem +=  " " + STR0049 + AllTrim(cChave)  //"Chave: "
    EndIf

    cMensagem += " " + STR0050 + AllTrim( ProcName(1) ) + " - " + AllTrim(cTexto) //"Função: "

    Conout(cMensagem)

    //Grava o log loja
    LjGrvLog(cChave, cTexto, xVar)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ900ADE
Gera a descrição do Codigo de Erro
@param   	cCodErro - Codigo do Erro
@retun		cRet - Descrição do Erro
@author  Varejo
@version 	P11.8
@since   	13/07/2015
@obs     
@sample  LJ900ADE(cCodErro)
/*/
//-------------------------------------------------------------------
Function LJ900ADE(cCodErro)

Local cRet := "" //Retorno

Do Case 
Case cCodErro = "1"
	cRet := STR0017 // "Não existe categoria associada ao produto"
Case cCodErro = "2"
	cRet := STR0015 //"Produto sem preço cadastrado na tabela de preço padrão"
Case cCodErro = "3"
	cRet := STR0016 //"Produto sem altura e/ou largura e/ou comprimento"
Case cCodErro = "4"
	cRet := STR0014 //"Codigo de produto inválido"

EndCase
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LJ90AVPr
Função de Validação do Produto
@param   	cCodigo - Codigo do Produto
@retun		aRet - Descrição do Erro
//1 - Lógico - Produto válido
//2 - Mensagem a ser exibida na tela
//3 - Array, contendo a seguinte estrutura
	//1  - Mensagem do item validado
	//2 - Item válido (lógico)
@author  Varejo
@version 	P11.8
@since   	26/08/2015
@obs     
@sample  LJ90AVPr(cCodigo)
/*/
//-------------------------------------------------------------------
Function LJ90AVPr(cCodigo, cProdPai)
//Retorno contendo a seguinte estruruta
Local aRet 		:= {.F., "", {} }
Local lRet 		:= .F.
//1 - Lógico - Produto válido
//2 - Mensagem a ser exibida na tela
//3 - Array, cotendo a seguinte estrutura
	//1  - Item validado
	//2 - Item válido (lógico)
Local aItensVl 	:= {} //Array de itens a ser validados
//1 - Mensagem
//2 - Bloco de Codigo
//3 - Interfere no envio?
local aItensR 	:= {} //Itens a ser validados
Local aArea 		:= GetArea() //WorkArea Anterior
Local cTabPad 	:= SuperGetMV("MV_LJECOMQ", , "001") //Tabela de Preço Padrão
Local nX 			:= 0 //Cotnador
Local lRetnX 		:= .F. //Eval do item
Local nTamB1Cod 	:= SB1->(TamSX3("B1_COD"))[1] //Tamanho do campo B1_Cod
Local cLocEst 	:= AllTrim(SuperGetMv("MV_LJECOMG", .T., "")) //Local de Estoque
Local lSendPrc 	:= .T. //Envia preço?
Local cProdVld := "" //Produto a Ser Validado
Local lVarLnPai := .F. //Variação de linha pelo Pai
Local lVarClPai := .F. //Variação de coluna pelo Pai
Local lVarLnFil := .F. //Variação de linha pelo Pai
Local lVarClFil := .F. //Variação de coluna pelo Pai
Local cMascGrd := SuperGetMV("MV_MASCGRD",,"11,2,2") //Mascara de Grade
Local cDesLin := ""//Descrição da Linha
Local cDesCol := ""//Descrição da Coluna
Local lDimPaiVal := .T. //Dimensões do Pai Validas?


Default cCodigo := ""
Default cProdPai := ""

If !Empty(cProdPai)
	cProdVld := cCodigo
	cCodigo := cProdPai
EndIf

If Empty(cCodigo)
	cCodigo := space(nTamB1Cod)
	MsgGet2(STR0018,STR0019 ,@cCodigo,,{|| .t.})//"Produto"##"Informe o codigo do Produto "
	
EndIf

aItensVl := { ;
				{ STR0035, ; //"Código de Produto válido (sem espaços)"
					{ |x| 	At(space(1), AllTrim(x)) = 0}, ;
					Empty(cProdPai);
				},;	
				{ STR0021, ; //"Complemento de produto cadastrado (MATA180)"
					{ |x| SB5->(DbSetOrder(1)), SB5->(DbSeek(xFilial("SB5") + x))}, ;
					.T.;
				},;
				{ STR0022, ;//"Complemento cadastrado como e-commerce (MATA180)"
					{ |x| SB5->(Found() .AND. !Empty(FIELD->B5_ECFLAG))}, ;
					Empty(cProdPai);
				},;
				{ STR0023, ; //"Complemento disponível na fila e-commerce (MATA180)"
					{ |x| SB5->(Found() .AND. Empty(FIELD->B5_ECDTEX))}, ;
					.T.;
				} ,;
				{ STR0024, ; //"Complemento cadastrado com Nome Cientf., Peso, Descrição e Título (MATA180)"
					{ |x| SB5->(Found() .AND. !Empty(FIELD->B5_CEME) .AND. FIELD->B5_PESO > 0 .AND. !Empty(FIELD->B5_ECDESCR) .AND. !Empty(FIELD->B5_ECTITU) ) }, ;
					.T.;
				} }

If !SuperGetMv("MV_LJECMM3", .F., .F.)
	aAdd( aItensVl,  { STR0025, ; //"Existe categoria associada ao produto (FATA150)"
					{ |x| ACV->(DbSetOrder(5)), ACV->(DbSeek(xFilial("ACV") + x)) }, ;
						Empty(cProdPai);
					})
	aAdd( aItensVl,{ STR0026, ; //"Existe categoria e-commerce válida e associada ao produto (FATA140) "
						{ |x|  ACV->(Found() .AND. Lj900AVPC(x) ) }, ;
						.F.;
					})
EndIf
aAdd( aItensVl,	{ STR0027+" ["+cTabPad +"] (OMSA010)", ; //"Produto cadastrado na tabela de preço padrão"
					{ |x, y|  Lj904XPr(x, SuperGetMV("MV_LJECOMQ", , "001"), .F., @y) > 0  .or. !y }, ;
					Empty(cProdPai);
				})
aAdd( aItensVl,	{ STR0028 + IF(!Empty(cLocEst), STR0029 + cLocEst, ""), ;//"Produto possui saldo em estoque "##" no(s) armazém(s)"
					{ |x|  Lj904XES(x) > 0  }, ;
					.F.;
				})			
aAdd( aItensVl, { STR0036, ; //"Produto com altura e/ou largura e/ou comprimento válidos (MATA180)"
					{ |x|  SB5->(Found()  .AND. ( (ColumnPos("B5_ECLARGU") = 0 .OR. ColumnPos("B5_ECCOMP") = 0)  .OR. (B5_ECPROFU + B5_ECLARGU + B5_ECCOMP) = 0  .OR. (B5_ECPROFU > 0 .and. B5_ECLARGU > 0 .AND. B5_ECCOMP > 0 ) ) )  }, ;
					Empty(cProdPai);
				})				


If !Empty(cCodigo)
	
	//Valida se o produto pertence a uma grade e-commerce
	//caso pertença retorna que não é possível realizar a validação
	SB1->(DbSetOrder(1)) //B1_Filial + B1_COD
	
	If SB1->(DbSeek(xFilial("SB1") + Padr(cCodigo, nTamB1Cod)))
	
		If !Empty(SB1->B1_PRODPAI) 
			//cRet := STR0031 //"Produto com estrutura de grade, validação não pode ser realizada"
			aAdd(aItensR, { "***** " + STR0037 + "[" + SB1->B1_PRODPAI + "]" , IIF(SB1->B1_PRODPAI  <> cProdVld, STR0038, "")+ "*****"})//"Validação do Produto-Pai "##" apenas informativa "
			
			//Validações Adicionais  
			cDesLin := Lj900ARGrd(cMascGrd, cCodigo,  1, 1, cCodigo/*cProdPai*/)
			cDesCol := Lj900ARGrd(cMascGrd, cCodigo,  1, 2, cCodigo/*cProdPai*/)
			aAdd(aItensVl, {STR0039+"[" +cDesLin + "] (MATA550)", ;//"Possui variação 1 no atributo "
								{ |x, y, w, z|  w := !Empty(Lj900ARGrd(, x,  2, 1,  x/*cProdPai*/)) },;
								 .F. })
			aAdd(aItensVl, {STR0040+"[" +cDesCol + "] (MATA550)", ;//"Possui variação 2 no atributo "
								{ |x, y, w, z|  z := !Empty(Lj900ARGrd(, x,  2, 2,  x/*cProdPai*/)) },;
								 .F. })
								 
			aAdd(aItensVl, {STR0041, ; //"Possui variação? (MATA550)"
								{ |x, y, w, z|  z .or. y},;
								 .T. })


		EndIf
		
		//Realiza as seguintes validações
		//Seta como válido se achou o produto
		lRet := .T. 
		

		
		For nX := 1 to Len(aItensVl)
			lRetNX := .F.
			//Realiza o bloco de código de validação do produto
			lRetnX := Eval(aItensVl[nX, 2], SB1->B1_COD, lSendPrc,@lVarLnPai ,;
							 @lVarClPai, @lDimPaiVal )
			//Verifica se o resultado da integração interfere na subida do produto
				
			If aItensVl[nX, 3]
				lRet := lRet .AND. lRetnX
			EndIf
							
			//Copia o resultado no array
			aAdd(aItensR, { aItensVl[nX, 01], IIF(lRetnX, STR0047, STR0048)}) //"SIM"#"NÃO"
			
		Next nX 
		
		If !Empty(SB1->B1_PRODPAI) .AND. SB1->B1_PRODPAI  <> cProdVld
			//Validações Adicionais da Grade
			//Posiciona no Produto novamente
				
				lRet := .T.
				SB1->(DbSetOrder(1)) //B1_Filial + B1_COD
	
				If SB1->(DbSeek(xFilial("SB1") + Padr(cProdVld, nTamB1Cod)))
						aAdd(aItensR, { "***** " +STR0042 + "[" + SB1->B1_COD + "]", STR0043 +"****"})//" Validação do Produto-Filho (variante) "#" informações consideradas "
						aItensVl := { ;
						{ STR0035, ; //"Código de Produto válido (sem espaços)"
							{ |x| 	At(space(1), AllTrim(x)) = 0}, ;
							.T.;
						},;	
						{ STR0044, ;//"Produto cadastrado como e-commerce (LOJA110)"
							{ |x| SB0->(DbSeek(xFilial("SB0") + x) .AND. !Empty(FIELD->B0_ECFLAG))}, ;
							.T.;
						},;
						{ STR0045, ; //"Produto disponível na fila e-commerce (LOJA110)"
							{ |x| SB0->(Found() .AND. Empty(FIELD->B0_ECDTEX))}, ;
							.T.;
						} ,;
						{ STR0027+" ["+cTabPad +"] (OMSA010)", ; //"Produto cadastrado na tabela de preço padrão"
							{ |x, y|  Lj904XPr(x, SuperGetMV("MV_LJECOMQ", , "001"), .F., @y) > 0  .or. !y }, ;
							.T.;
						},;
						{ STR0028 + IF(!Empty(cLocEst), STR0029 + cLocEst, ""), ;//"Produto possui saldo em estoque "##" no(s) armazém(s)"
							{ |x|  Lj904XES(x) > 0  }, ;
							.F.;
						},;				
						{ STR0036, ; //"Produto com altura e/ou largura e/ou comprimento válidos (MATA180)"
							{ |x, y, z, w, a, b , c, d|   ( SB0->(Found()  .AND. ( (ColumnPos("B0_ECLARGU") = 0 .OR. ColumnPos("B0_ECCOMP") = 0 .OR. ColumnPos("B0_ECPROFU") = 0)  .OR. ( (B0_ECPROFU + B0_ECLARGU + B0_ECCOMP = 0) .AND. d ) .OR. (B0_ECPROFU > 0 .and. B0_ECLARGU > 0 .AND. B0_ECCOMP > 0 ) ) ) )  }, ;
							.T.;
						};			
					}	


					aAdd(aItensVl, {STR0039+ "[" +cDesLin + "], "+STR0046, ; //"Possui variação 1 no atributo "#"conforme definido pelo Pai (MATA550)?"
										{ |x, y, w, z, a, b , c|  ( ( b := !Empty(Lj900ARGrd(, x,  2, 1,  a/*cProdPai*/)) ) .AND.  w ) .OR. ( !b )   },;
										 .T. })
					aAdd(aItensVl, {STR0040+ "[" +cDesCol + "], "+STR0046, ; //"Possui variação 2 no atributo "#"conforme definido pelo Pai (MATA550)?"
										{ |x, y, w, z, a, b , c|   ((c := !Empty(Lj900ARGrd(, x,  2, 2,  a/*cProdPai*/)))  .AND. z ) .OR. ( !c )  },;
										 .T. })
										 
					aAdd(aItensVl, {STR0041, ; //"Possui variação (MATA550)?"
										{ |x, y, z, w, a, b , c|  b .Or. c },;
										.T.})


					For nX := 1 to Len(aItensVl)
						lRetNX := .F.
						//Realiza o bloco de código de validação do produto
						lRetnX := Eval(aItensVl[nX, 2], ;
										SB1->B1_COD, lSendPrc,@lVarLnPai ,@lVarClPai,;
										SB1->B1_PRODPAI, @lVarLnFil, @lVarClFil, @lDimPaiVal )
						//Verifica se o resultado da integração interfere na subida do produto
							
						If aItensVl[nX, 3]
							lRet := lRet .AND. lRetnX
						EndIf
										
						//Copia o resultado no array
						aAdd(aItensR, { aItensVl[nX, 01], IIF(lRetnX, STR0047, STR0048)}) //"SIM"#"NÃO") 
					
					Next nX 
	
					
				Else
					aRet[1] := .F.
					aItensR := {}
					cRet := STR0034 //"Produto não localizado"
				EndIf
		EndIf
		
		aRet[1] := lRet
		
		If lRet
			cRet := STR0032 //"Produto 'sobe' para o site"
		ElseIf !lRet
			cRet := STR0033 //"Produto NÃO 'sobe' para o site"
		EndIf
	Else
		cRet := STR0034 //"Produto não localizado"
		
	EndIf
	
	aRet[2] := cRet
		
	aRet[3] := aClone(aItensR)

EndIf

RestArea(aArea)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900AVPC
//Verifica se um produto está vinculado a uma categoria e-commerce válida
//Ultimo no e sinalizada como e-commerce
@param   	cCodigo - Codigo do Produto
@retun		lRet - Produto vinculado a categoria EC Válida
@author  Varejo
@version 	P11.8
@since   	26/08/2015
@obs     
@sample  Lj900AVPC(cCodigo)
/*/
//-------------------------------------------------------------------


Static Function Lj900AVPC(cCodigo)
Local aArea := GetArea() //WorkArea anterior
Local cFilACV := xFilial("ACV")//Filial ACV
Local cFilACU := xFilial("ACU") //Filial ACU
Local aAreaACV := ACV->(GetArea()) //WorkArea ACV
Local aAreaACU := ACU->(GetArea())//WorkArea ACU
Local lRet := .F.

//Já está posicionado no ACV

ACU->(DbSetOrder(2))//ACU_FILIAL+ACU_CODPAI                                                                                                                                                                                                                                                                         
Do While !lRet .AND. ACV->(ACV_FILIAL == cFilACV .and. RTrim(ACV_CODPRO) == Rtrim(cCodigo))
	//Verifica se a categoria não possui filhos (último nó)
	If !ACU->(DbSeek(cFilACU + ACV->ACV_CATEGO))
		//Verifica se é e-commerce
		ACU->(DbSetOrder(1))
		lRet := ACU->(DbSeek(cFilACU + ACV->ACV_CATEGO)) .AND. !Empty(ACU->ACU_ECFLAG)
		
		//Volta a ordem para a categoria-pai
		ACU->(DbSetOrder(2))
	EndIf                                                                                                                                        

	ACV->(DbSkip(1))
EndDo


RestArea(aAreaACU)
RestArea(aAreaACV)
RestArea(aArea)
Return lRet
 

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj900APP
Busca o ultimo preço promocional enviado	
@author  Varejo
@version 	P11.8
@since   	26/04/2016
@obs     
@sample Lj900APP(cCodigo)
/*/
//-------------------------------------------------------------------
Function Lj900APP(cCodigo)
		Local cAlias := GetNextAlias()
		Local nVlrProm := 0
		
	BeginSQL Alias cAlias
	
		%noparser%

		SELECT MGN_CODIGO, MGN.MGN_VLRDES, MGN.MGN_PRCPRO
			FROM %table:MGN% MGN
			WHERE
			    MGN.MGN_FILIAL  = %xFilial:MGN%
			AND MGN.MGN_CODIGO =  %Exp: cCodigo %
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

		   
	EndSQL
	
	If	!(cAlias)->(Eof())
		nVlrProm := (cAlias)->MGN_PRCPRO -  (cAlias)->MGN_VLRDES
		If nVlrProm >= (cAlias)->MGN_PRCPRO .OR. nVlrProm < 0
			nVlrProm := 0
		EndIf
	EndIf
	
	(cAlias)->(DbCloseArea())
Return nVlrProm
