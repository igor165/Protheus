#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FATA600.CH"
#INCLUDE "DBTREE.CH"

#DEFINE FT600PGRID	5

Static aConfigAlo		:= {}									//Configuracao da alocacao de recurso.
Static _lBlqProp		:= .F.									// Define se a proposta comercial será bloqueada.
Static _lGeraOrc		:= SuperGetMv("MV_CRMGORC",, .T.)	// O pedido de vendas não será mais gerado de forma automática ao desabilitar o parâmetro. (Inicialmente criado para atender à TDI para não gravar mais CJ e CK, ao desabilitá-lo). 
Static _FT600VTC		:= ExistBlock("FT600VTC")
Static _lFT600TOK		:= ExistBlock("FT600TOK")										//Ponto de entrada para validacao do usuario
Static _lFT600QTD		:= ExistBlock("FT600QTD")
Static _lFT600LOK		:= ExistBlock("FT600LOK")
Static _lFT600T9A		:= ExistBlock("FT600T9A")
Static _lFT600TOC		:= ExistBlock("FT600TOC") //Ponto de entrada para filtrar produtos a serem considerados no Cronograma Financeiro

//-------------------------------------------------------------------
/*/{Protheus.doc} Ft600LinePre
Pré Validação da linha do Grid

@author luiz.jesus
@since 18/03/2014
@version 12
/*/
//-------------------------------------------------------------------
Function Ft600LinePre(oModel, nLine, cAction, cField, nFolder)

Local lRet				:= .T.
Local cVar				:= AllTrim(ReadVar())
Local lHasOrcSer  	:= .F. //Verifica se o item está vinculado á um Orc. Serviços

If	( cAction = "DELETE" .Or. cAction == "UNDELETE" ) .AND. !IsInCallStack("FT600AtuADZ")
	lRet := A600Del(nFolder, oModel:GetModel())
EndIf

If lRet
	
	Do Case
		
		Case cVar == oModel:GetValue("ADZ_PRODUT")
			
			lHasOrcSer := IsItOrcServ(FwFldGet("ADZ_ITEM")) //Verifica se o item está vinculado á um Orc. Serviços
			
			If Empty( FwFldGet( "ADY_TABELA" ) )
				lRet := .F.
				Help(,,'Ft600LinePre',, STR0019 + ": " + STR0021, 1,0) //"Atenção"###"Informe a tabela de preço"
			ElseIf lHasOrcSer .And. !GetMv('MV_GSORCPR', ,.F.)
				lRet := .F.
				Help(,,'ALTORCSER01',, STR0197 + CRLF + STR0198, 1,0) // 'Não é permitido alterar o produto referência do Orçamento de Serviços na Proposta'##'Faça a alteração no Orçamento de Serviços'
			EndIf
			
		Case cVar == "M->ADZ_QTDVEN"
			
			lHasOrcSer := IsItOrcServ(FwFldGet("ADZ_ITEM")) //Verifica se o item está vinculado á um Orc. Serviços
			
			If	_lFT600QTD
				lRet := ExecBlock('FT600QTD', .F., .F., {oModel})
				If	( ValType(lRet) <> 'L' )
					lRet := .T.
				EndIf
			EndIf
			
			If lRet .And. lHasOrcSer .And. !IsInCallStack('SetDadosOrc')
				lRet := .F.
				Help(,,'ALTORCSER02',, STR0199 + CRLF + STR0198 ,1,0) // 'Não é permitido alterar a quantidade de um item do Orçamento de Serviços na Proposta'#// 'Faça a alteração no Orçamento de Serviços'
			EndIf
			
		Case cVar == "M->ADZ_PRCVEN"
			
			lHasOrcSer := IsItOrcServ(FwFldGet("ADZ_ITEM")) //Verifica se o item está vinculado á um Orc. Serviços
			
			If lHasOrcSer .And. !IsInCallStack('SetDadosOrc') .And. !IsInCallStack('TECA280') 
				lRet := .F.
				Help(,,'ALTORCSER03',, STR0200 + CRLF +STR0198 ,1,0)  // 'Não é permitido alterar o valor de um item do Orçamento de Serviços na Proposta'##'Faça a alteração no Orçamento de Serviços'
			EndIf
			
		Case cVar == "M->ADZ_VALDES"
			
			lHasOrcSer := IsItOrcServ(FwFldGet("ADZ_ITEM")) //Verifica se o item está vinculado á um Orc. Serviços
			
			If lHasOrcSer
				lRet := .F.
				Help(,,'ALTORCSER04',, STR0201 + CRLF + STR0198 ,1,0) // 'Não é permitido alterar o percentual de desconto de um item do Orçamento de Serviços na Proposta'#'Faça a alteração no Orçamento de Serviços'
			EndIf
			
		Case cVar == "M->ADZ_DESCON"
			
			lHasOrcSer := IsItOrcServ(FwFldGet("ADZ_ITEM")) //Verifica se o item está vinculado á um Orc. Serviços
			
			If lHasOrcSer
				lRet := .F.
				Help(,,'ALTORCSER05',, STR0202 + CRLF + STR0198 ,1,0)  // 'Não é permitido alterar o valor de desconto de um item do Orçamento de Serviços na Proposta'## 'Faça a alteração no Orçamento de Serviços'
			EndIf
			
		Case cVar == "M->ADZ_CONDPG" .And. !GetMv('MV_GSORCPR', ,.F.)
			
			lHasOrcSer := IsItOrcServ(FwFldGet("ADZ_ITEM")) //Verifica se o item está vinculado á um Orc. Serviços
			
			If lHasOrcSer .And. !IsInCallStack('SetDadosOrc') .And. !IsInCallStack('A600ImpVis') 
				lRet := .F.
				Help(,,'ALTORCSER06',, STR0203 + CRLF + STR0198 ,1,0) // 'Não é permitido alterar condição de pagamento de um item do Orçamento de Serviços na Proposta'##'Faça a alteração no Orçamento de Serviços'
			EndIf
			
	EndCase
	
EndIf

If lRet .AND. FindFunction('A600PrpSrv') //Verifica se utiliza a nova integração de proposta de serviços.

	If cAction == 'UNDELETE'
		If !A600PrpSrv(oModel)
			lRet := .F.
			Help(Nil, Nil, "FT600PrSr1", Nil,;
				STR0439,; // #"Ao utilizar a Proposta de Serviço todos os itens devem estar relacionados a um Orçamento de Projeto."
			  	1, 0, NIL, NIL, NIL, NIL, NIL,;
			  	{STR0441}) // #"Informe os produtos através do Orçamemto de Projeto."
		EndIf
	ElseIf  (cAction == 'CANSETVALUE' .AND. cField $ "ADZ_PRODUT|ADZ_QTDVEN|ADZ_PRCVEN") .OR. (cAction == 'DELETE' .AND. !ProcName(FT600PGRID) == "FT600RLGRID" .AND. !Empty(oModel:GetValue('ADZ_PRODUT',nLine)))
		If !A600PrpSrv(oModel)	
			lRet := .F.
			Help(Nil, Nil, "FT600PrSr2", Nil,;
				STR0439,; // #"Ao utilizar a Proposta de Serviço todos os itens devem estar relacionados a um Orçamento de Projeto."
			  	1, 0, NIL, NIL, NIL, NIL, NIL,;
			  	{STR0442}) // #"Edite os itens de produtos através do Orçamemto de Projeto."
		EndIf
	EndIf
EndIf 

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A600LOk
Pós Validação da linha do grid

@author luiz.jesus
@since 18/03/2014
@version 12
/*/
//-------------------------------------------------------------------
Function At600LOk(oMdlAtu, nLine)

Local lRet			:= .T.

Default oMdlAtu		:= Nil
Default nLine		:= 0

If lRet .And. _lFT600LOK
	lRet := ExecBlock("FT600LOK", .F.,.F., {oMdlAtu})
	If ValType( lRet ) <> "L"
		lRet := .T.
	EndIf
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} At600TOk
Pós-validação do modelo da Prospota Comercial (Equivale ao TUDOOK)
@author luiz.jesus
@since 18/03/2014
@version 12
/*/
//-------------------------------------------------------------------
Function At600TOk(oModel)

Local aArea		:= GetArea()
Local aAreaACA  	:= ACA->(GetArea())   											//Guarda area atual.
Local cCodRepr  	:= ""																//Codigo do Grupo Representante.
Local cSimbPrd  	:= SuperGetMv("MV_SIMB1")+Space(1) 							//Simbolo da Moeda padrao.
Local cSimbVar  	:= ""                     										//Simbolo da Moeda variavel.
Local cCodInt   	:= ""																//Codigo inteligente do vendedor.
Local aVdSup    	:= {}				  												//Retorna array vendedores superior
Local aMsgTmpAux	:= {{},{}}															//Array temporário que ira armazenar as mensagens das pastas Produtos/Acessórios.
Local cMsgFinal 	:= STR0104			  												//"O limite estipulado para seu grupo foi excedido,deseja continuar a gravação?"
Local lRetorno  	:= .T.																//Retorno da validacao.
Local lHasOrcSer	:= .F.																//Item associado a um Orçamento de Serviços do SIGATEC?
Local nTmFolder	:= GetSX3Cache("ADZ_FOLDER","X3_TAMANHO")						//Variável para ajustar tamanho do campo Folder da proposta
Local nPMxDesc  	:= 0 																//Percentual maximo de desconto.
Local nVMxDesc  	:= 0 																//Valor maximo de desconto.
Local nPMxAcr   	:= 0 																//Percentual maximo para acrescimo.
Local nVMxAcr  	:= 0 																//Valor maximo para acrescimo.
Local nPMxAux		:= 0																//Variável auxiliar do Percentual Máximo.
Local nVMxAux		:= 0																//Variável auxiliar do Valor Máximo.
Local nPos      	:= 0																//Posicao do array
Local nX        	:= 0																//Incremento utilizado no laco For.
Local nI 	    	:= 0																//Incremento utilizado no laco For.
Local nPosABO   	:= 0 																//Posicao do item na ABO.
Local nAba			:= 0																//Número da aba da tela
Local nVlrTGrid	:= 0																//Valor total das grids de Produtos/Acessórios
Local nVlrTCrono	:= 0																//Valor total do cronograma financeiro
Local cAba			:= ""
Local cChave		:= ""																//Folder atual.
Local cFolder		:= ""
Local cMsg			:= ""
Local cTitMsg		:= ""
Local cTpCont		:= FwFldGet("ADY_TPCONT")										//Tipo de Contrato
Local cFilABO		:= xFilial("ABO")
Local cFilSA3		:= xFilial("SA3")
Local cFilAO3		:= xFilial("AO3")
Local aTipo09 		:= Ft600GetTipo09()
Local lSoma		:= .T.

aConfigAlo := Ft600GetAloc()
//Reinicializa a Varivel _lBlqProp 
_lBlqProp  	:= .F.
	
//Validacao dos produtos de alocacao.
ABO->(DbSetOrder(1))

For nAba := 1 to 2
	If	nAba == 1
		cFolder	:= "ADZPRODUTO"	// Valida a pasta produtos.
		cMsg		:= STR0173			// "Na aba produtos existem produtos do tipo alocação que não foram configurados."
	Else
		cFolder	:= "ADZACESSOR"	// Valida a pasta acessorios.
		cMsg		:= STR0175			// "Na aba acessórios existem produtos do tipo alocação que não foram configurados."
	EndIf
	cTitMsg	:= STR0174				// "Atenção"
	cAba		:= PadR(AllTrim(Str(nAba)),nTmFolder)

	If lRetorno .AND. !( oModel:GetModel(cFolder):IsEmpty() )

		For nX := 1 To oModel:GetModel(cFolder):Length()
			oModel:GetModel(cFolder):GoLine(nX)
			If	!( oModel:GetModel(cFolder):IsDeleted() )
				If oModel:GetModel(cFolder):GetValue("ADZ_PRDALO") == "1" .AND. (oModel:GetModel(cFolder):IsUpdated() .Or. oModel:GetModel(cFolder):IsInserted())
					If ABO->(! DbSeek(cFilABO +;
					                  FwFldGet("ADY_PROPOS") +;
					                  FwFldGet("ADY_PREVIS") +;
					                  cAba +;
					                  oModel:GetModel(cFolder):GetValue("ADZ_ITEM") +;
					                  oModel:GetModel(cFolder):GetValue("ADZ_PRODUT")))
						cChave		:= PadR(AllTrim(Str(nAba)),nTmFolder) + oModel:GetModel(cFolder):GetValue("ADZ_ITEM") + oModel:GetModel(cFolder):GetValue("ADZ_PRODUT")
						nPosABO	:= aScan(aConfigAlo,{|x| x[1] == cChave } )
						If nPosABO == 0
							Help( "", 1, "At600TOk", ,cTitMsg + ": " + cMsg, 1, 0)
							lRetorno	:= .F.
							EXIT
						EndIf
					EndIf
				EndIf

				If oModel:GetOperation() <> MODEL_OPERATION_DELETE
					lHasOrcSer	:= (IsItOrcServ(oModel:GetModel(cFolder):GetValue("ADZ_ITEM")))      /* .And. IsInCallStack('SetDadosOrc'))*/ //Verifica se o item está vinculado á um Orc. Serviços
					If !( lHasOrcSer ) .AND. ( oModel:GetModel(cFolder):GetValue("ADZ_TOTAL") <= 0 .OR. oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN") <= 0 )
						Help( "", 1, "At600TOk", ,STR0358,2,,,,,,,{STR0409} ) //"Gravação cancelada."###"Existe ao menos um produto/acessório com preço de venda não informado ou negativo. Informe um preço de venda válido para o mesmo."
						lRetorno	:= .F.
						EXIT
					EndIf
				EndIf

				lSoma := .T.
				
				If _lFT600TOC
					lSoma := ExecBlock( 'FT600TOC', .F., .F., { oModel:GetModel(cFolder):GetValue("ADZ_PRODUT"), oModel, nAba, nX } )
					If ValType( lSoma ) <> 'L'
						lSoma := .T.
					EndIf
				EndIf
				
				If lSoma
					nVlrTGrid += oModel:GetModel(cFolder):GetValue("ADZ_TOTAL")
				EndIf
				
			EndIf
		Next nX

	EndIf
Next nAba

If lRetorno .AND. oModel:GetOperation() <> MODEL_OPERATION_DELETE .And. !Empty(aTipo09)

	For nX := 1 To oModel:GetModel("CRONOFIN"):Length()
		oModel:GetModel("CRONOFIN"):GoLine(nX)
		If	!( oModel:GetModel("CRONOFIN"):IsDeleted() )
			nVlrTCrono += oModel:GetModel("CRONOFIN"):GetValue("ZYY_TOTAL")
		EndIf
	Next nX
	If nVlrTGrid <> nVlrTCrono
		Help( "", 1, "At600TOk", ,STR0358,2,,,,,,,{STR0406} ) //"Gravação cancelada."##"O valor total dos produtos/acessórios não está sendo considerado no cronograma financeiro. Verifique e refaça os cálculos do cronograma."
		lRetorno	:= .F.
	EndIf

EndIf

If lRetorno
		
	If nModulo != 73
		cCodRepr := Posicione("SA3",1,cFilSA3+AD1->AD1_VEND,"A3_GRPREP")
		cCodInt  := Posicione("SA3",1,cFilSA3+AD1->AD1_VEND,"A3_NVLSTR")
	Else
		cCodRepr := Posicione("AO3",2,cFilAO3+AD1->AD1_VEND,"AO3_CODEQP")
		cCodInt  := Posicione("AO3",2,cFilAO3+AD1->AD1_VEND,"AO3_IDESTN")
	EndIf
	aVdSup   := Ft520Sup(cCodInt)
			
	ACA->(DbSetOrder(1))
	If ACA->(DbSeek(xFilial("ACA")+cCodRepr))
		nPMxAcr  := ACA->ACA_PACRMX
		nVMxAcr  := ACA->ACA_VACRMX
		nPMxDesc := ACA->ACA_PDSCMX
		nVMxDesc := ACA->ACA_VDSCMX
	EndIf
			
	For nAba := 1 to 2

		If	nAba == 1
			cFolder	:= "ADZPRODUTO"	// Valida a pasta produtos.
		Else
			cFolder	:= "ADZACESSOR"	// Valida a pasta acessorios.
		EndIf

		If	!( oModel:GetModel(cFolder):IsEmpty() )
			For nX := 1 To oModel:GetModel(cFolder):Length()
				oModel:GetModel(cFolder):GoLine(nX)
				If	!( oModel:GetModel(cFolder):IsDeleted() )
					If (oModel:GetModel(cFolder):IsUpdated() .Or. oModel:GetModel(cFolder):IsInserted()) .AND. !Empty(oModel:GetModel(cFolder):GetValue("ADZ_PRODUT"))

						cSimbVar	:= Alltrim(SuperGetMv("MV_SIMB"+oModel:GetModel(cFolder):GetValue("ADZ_MOEDA")))+Space(1)												//Simbolo variavel

						If oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN") > oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB")

							nPos		:= aScan(aMsgTmpAux[nAba], {|x| AllTrim(x[1]) == STR0105})																				//"acréscimo"
							nCPPrcVen	:= oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB") + ((oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB")/100) * nPMxAcr)			//Preco de Venda com percentual de acrescimo.
							nCVPrcVen	:= oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB") + nVMxAcr																			//Preco de Venda com valor de acrescimo.

							If nPMxAcr <> 0
								If  oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN") > nCPPrcVen
									If nPos == 0
										aAdd(aMsgTmpAux[nAba], {STR0105, {}})																										//"acréscimo"
										nPos	:= Len(aMsgTmpAux[nAba])
									EndIf
									aAdd(aMsgTmpAux[nAba][nPos][2], {STR0107 + oModel:GetModel(cFolder):GetValue("ADZ_ITEM") + STR0106,;																	//"Item - "//" - atingiu por percentual."
									                                 STR0108 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB"),"@E 999,999,999.99"))),;	//"Preço de tabela: "
									                                 STR0109 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN"),"@E 999,999,999.99"))),;	//"Valor liberado: "
									                                 STR0110 + cSimbVar + Alltrim(cValToChar(TransForm(nCPPrcVen,"@E 999,999,999.99")))})												//"Valor máximo permitido: "
									Loop
								EndIf
							EndIf

							If nVMxAcr <> 0
								If oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN") > nCVPrcVen
									If nPos == 0
										aAdd(aMsgTmpAux[nAba], {STR0105, {}})																										//"acréscimo"
										nPos	:= Len(aMsgTmpAux[nAba])
									EndIf
									aAdd(aMsgTmpAux[nAba][nPos][2], {STR0107 + oModel:GetModel(cFolder):GetValue("ADZ_ITEM") + STR0111,;																	//"Item - "//" - atingiu por valor máximo."
									                                 STR0108 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB"),"@E 999,999,999.99"))),;	//"Preço de tabela: "
									                                 STR0109 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN"),"@E 999,999,999.99"))),;	//"Valor liberado: "
									                                 STR0110 + cSimbVar + AllTrim(cValToChar(Transform(nCVPrcVen,"@E 999,999,999.99")))})												//"Valor máximo permitido: "
									Loop
								EndIf
							EndIf

						ElseIf oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN") < oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB")

							nPos		:= aScan(aMsgTmpAux[nAba], {|x| AllTrim(x[1]) == STR0112})																				//"desconto"
							nCPPrcVen	:= oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB") - ((oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB")/100) * nPMxDesc)		//Preco de Venda com percentual de desconto
							nCVPrcVen	:= oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB") - nVMxDesc																			//Preco de Venda com valor de desconto

							If nPMxDesc <>  0
								If oModel:GetModel(cFolder):GetValue("ADZ_DESCON") > nPMxDesc
									If nPos == 0
										aAdd(aMsgTmpAux[nAba], {STR0112, {}})																										//"desconto"
										nPos	:= Len(aMsgTmpAux[nAba])
									EndIf
									aAdd(aMsgTmpAux[nAba][nPos][2], {STR0107 + oModel:GetModel(cFolder):GetValue("ADZ_ITEM") + STR0106,;																	//"Item - "//" - atingiu por percentual."
									                                 STR0108 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB"),"@E 999,999,999.99"))),;	//"Preço de tabela: "
									                                 STR0109 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN"),"@E 999,999,999.99"))),;	//"Valor liberado: "
									                                 STR0110 + cSimbVar + AllTrim(cValToChar(TransForm(nCPPrcVen,"@E 999,999,999.99")))})												//"Valor máximo permitido: "
									Loop
								EndIf
							EndIf

							If nVMxDesc <> 0
								If  oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN") < nCVPrcVen
									If nPos == 0
										aAdd(aMsgTmpAux[nAba], {STR0112, {}})																										//"desconto"
										nPos	:= Len(aMsgTmpAux[nAba])
									EndIf
									aAdd(aMsgTmpAux[nAba][nPos][2], {STR0107 + oModel:GetModel(cFolder):GetValue("ADZ_ITEM") + STR0111,;																	//"Item -//"- atingiu por valor máximo."
									                                 STR0108 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCTAB"),"@E 999,999,999.99"))),;	//"Preço de tabela: "
									                                 STR0109 + cSimbVar + AllTrim(cValToChar(TransForm(oModel:GetModel(cFolder):GetValue("ADZ_PRCVEN"),"@E 999,999,999.99"))),;	//"Valor liberado: "
									                                 STR0113 + cSimbVar + AllTrim(cValToChar(TransForm(nCVPrcVen,"@E 999,999,999.99")))})												//"Valor mínimo permitido: "
									Loop
								EndIf
							EndIf

						EndIf

					EndIf
				EndIf

			Next nX
		EndIf

	Next nAba

	If	Len(aMsgTmpAux[01]) > 0 .OR. Len(aMsgTmpAux[02]) > 0

		For nAba := 1 to 2
			For nI := 1 To Len(aMsgTmpAux[nAba])
				If nI == 1
					cMsgFinal += chr(10) + chr(10)
					cMsgFinal += If(nAba == 1, STR0180, STR0181)	//"Pasta - Produtos" ## "Pasta - Acessórios"
					cMsgFinal += chr(10)
				EndIf
				If aMsgTmpAux[nAba][nI][1] == STR0105																									//"acréscimo"
					nPMxAux	:= nPMxAcr		//Percentual máximo de acréscimo
					nVMxAux	:= nVMxAcr		//Valor máximo de acréscimo
				Else
					nPMxAux	:= nPMxDesc	//Percentual máximo de desconto
					nVMxAux	:= nVMxDesc	//Valor máximo de desconto
				EndIf
				cMsgFinal	+= chr(10) + STR0114 + aMsgTmpAux[nAba][nI][1] + STR0115 + chr(10) +; 												//"Limite de "//" estipulado."
				         	   "-----------------------------------------------" + chr(10) +;
				         	   IIf(nPMxAux <> 0,;
				         	       STR0116 + AllTrim(cValToChar(nPMxAux)) + " %" + chr(10),;														//"Percentual máximo: "
				         	       "") +;
				         	   IIf(nVMxAux <> 0,;
				         	       STR0117 + cSimbPrd + AllTrim(cValToChar(TransForm(nVMxAux,"@E 999,999,999.99"))) + chr(10),;				//"Valor máximo: "
				         	       "") +;
				         	   "-----------------------------------------------"
				For nX := 1 To Len(aMsgTmpAux[nAba][nI][2])
					cMsgFinal	+= chr(10) + aMsgTmpAux[nAba][nI][2][nX][1] + chr(10) + aMsgTmpAux[nAba][nI][2][nX][2] +;
					         	   chr(10) + aMsgTmpAux[nAba][nI][2][nX][3] + chr(10) + aMsgTmpAux[nAba][nI][2][nX][4] + chr(10) +;
					         	   "-----------------------------------------------"
				Next nX
			Next nI
		Next nAba

		If DlgMsgCRM(cMsgFinal, STR0096, .T., .F., .T.)
			If Len(aVdSup) > 0   //A proposta sera bloqueada somente se o vendedor tiver superiores na sua estrutura de venda.
				_lBlqProp	:= .T.
			EndIf
		Else
			lRetorno	:= .F.
			Help( "", 1, "At600TOk", ,STR0358,2,,,,,,,{STR0359} ) //"Gravação cancelada."##"Informe um desconto válido."
		EndIf

	EndIf
EndIf

//Valida os itens quanto a sua configuração dentro do contrato
If lRetorno .AND. cTpCont $ "23"
	If _FT600VTC
		lRetorno := ExecBlock("FT600VTC", .F.,.F., {cTpCont})
	Else
		lRetorno := At600CntOk(cTpCont)
	Endif
EndIf

//Executa ponto de entrada de TudoOk
If lRetorno .AND. _lFT600TOK
	uRetPE		:= ExecBlock("Ft600TOk", .F.,.F., oModel)
	If ValType(uRetPE) == "L"
		lRetorno	:= uRetPE
	EndIf
EndIf

RestArea(aAreaACA)
RestArea(aArea)
Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} A600VldCPg

Validação Condição de Pagamento. 

@author luiz.jesus

@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function A600VldCPg(cMdlGrid)

Local lRet			:= .T.
Local aArea		:= GetArea()
Local nItemT9		:= 0
Local oModel		:= FwModelActive()
Local oMdlAtu		:= Nil
Local aTipo09		:= {}

Default cMdlGrid	:= ""

If ! Empty(cMdlGrid)
	SE4->(DbSetOrder(1))
	oMdlAtu := oModel:GetModel(cMdlGrid)
	If SE4->(DbSeek(xFilial("SE4")+oMdlAtu:GetValue("ADZ_CONDPG")))

		If	SE4->E4_TIPO == "9"
			//Caso seja condicao de pagamento tipo 9 valida o valor total do produto
			If	oMdlAtu:GetValue("ADZ_TOTAL") <= 0
				Help(,,'A600VldCPg',, STR0051, 1, 0) //"Calcule o valor total do produto !"
				lRet := .F.
			Endif
		Else
			//Verifica se o item esta incluido na lista de parcelas do tipo 9, caso afirmativo
			//exclui as parcelas, evitando que sejam calculadas no cronograma financeiro
			aTipo09 := Ft600GetTipo09()
			For nItemT9 := Len(aTipo09) To 1 Step -1
				If (aTipo09[nItemT9,5] == oMdlAtu:GetValue('ADZ_ITEM')) .AND. (AllTrim(aTipo09[nItemT9,1]) == AllTrim(oMdlAtu:GetValue('ADZ_PRODUT')))
					Adel(aTipo09,nItemT9)
					ASize(aTipo09,Len(aTipo09)-1)
				EndIf
			Next nItemT9
			Ft600SetTipo09( aTipo09 )
		EndIf

	EndIf
EndIf

//Só cria cronograma ao final do gatilho
A600CroFinance()

RestArea(aArea)
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} At600Tp9Tot
Valida parcelas e vencimentos informados para condicao tipo 9.

@author luiz.jesus

@since 18/03/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function At600Tp9Tot(aCols,cCodTp9,oModel,cFolder)

Local lRet			:= .T.
Local aArea		:= (Alias())->(GetArea())
Local aAreaSX3	:= {}
Local nS			:= 0
Local nSomaIt		:= 0
Local cPosCod		:= oModel:GetModel(cFolder):GetValue("ADZ_PRODUT")	//Conteudo do campo Produto
Local nPosTot		:= oModel:GetModel(cFolder):GetValue("ADZ_TOTAL")	//Conteudo do campo Valor do Desconto
Local cPosItem	:= oModel:GetModel(cFolder):GetValue("ADZ_ITEM")		//Conteudo do campo Item
Local cPosFolder	:= oModel:GetModel(cFolder):GetValue("ADZ_FOLDER")	//Conteudo do campo Folder
Local nPosItem	:= 0
Local nParcelas	:= SuperGetMv("MV_NUMPARC") 							// Numero de parcelas permitidas para tipo 9
Local nUltLinha	:= 1														// Número da última linha válida
Local cParcela	:= "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
Local cChave		:= ""
Local cChave1		:= ""
Local dData		:= dDataBase	// Data Inicial
Local aTipo09		:= {}
Local nParcaCols	:= 0
Local nColVlr		:= aScan(aHeader,{|x|Alltrim(x[2])=="L4_VALOR"}) //coluna de valores
Local nColData	:= aScan(aHeader,{|x|Alltrim(x[2])=="L4_DATA"}) //coluna de valores
Local nColDel		:= Len(aHeader) + 1 //coluna de delecao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Relacao entre nParcelas (MV_NUMPARC) e Base de Dados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nParcelas > 4 .And. _lGeraOrc
	cChave   := "CJ_DATA"+Subs(cParcela,nParcelas,1)
	cChave1  := "CJ_PARC"+Subs(cParcela,nParcelas,1)
	aAreaSX3 := SX3->(GetArea())
	DbSelectArea("SX3")
	DbSetOrder(2)
	If !DbSeek(cChave) .or. !DbSeek(cChave1)
		Help(" ",1,"TMKTIP905") //"A quantidade de parcelas nao esta compativel. Verificar junto ao administrador do sistema relacao entre parametro MV_NUMPARC e dicionario de dados"
		lRet	:= .F.
	EndIf
	RestArea(aAreaSX3)
EndIf

If	lRet
	aEval(aCols, {|x| Iif(x[nColDel], ,nParcaCols++)})
	If nParcaCols > nParcelas
		Help( ,, 'A600TP9C',, STR0399 + Str(nParcelas), 1, 0 ) //O numero de parcelas deve ser maior que 0 e menor que ###
		lRet	:= .F.
	EndIf

	If	lRet
		For nS := 1 To Len(aCols)
			If	!aCols[nS,nColDel]
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida a Data informada ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Empty(aCols[nS][nColData]) .OR. (aCols[nS][nColData] < dDataBase)
					Help(" ",1,"A600TP9A")	//"A data esta incorreta"
					lRet	:= .F.
					EXIT
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valida Data da ultima parcela ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nS > 1
					dData := aCols[nUltLinha][nColData]
				Endif

				If (aCols[nS][nColData] < dData)
					Help(" ",1,"A600TP9B")	//"As datas das parcelas precisam ser crescentes"
					lRet	:= .F.
					EXIT
				Endif
				If Empty(aCols[nS][nColVlr])
					MsgStop(STR0142)	//"Não foi informado o valor da parcela."
					lRet	:= .F.
					EXIT
				Endif

				nSomaIt += aCols[nS,nColVlr]

				nUltLinha := nS
			Endif
		Next nS

		If	lRet
			If nSomaIt > nPosTot
				MsgAlert(STR0055,STR0019) //"Valor da(s) parcela(s) maior que o total do item !"###"Atencao"
				lRet := .F.
			ElseIf nSomaIt < nPosTot
				MsgAlert(STR0056,STR0019) //"Valor da(s) parcela(s) menor que o total do item !"###"Atencao"
				lRet := .F.
			Endif

			If lRet .And. _lFT600T9A
				lRet := ExecBlock("FT600T9A", .F., .F., {aCols, aHeader})
				If ValType(lRet) <> 'L'
					lRet := .T.
				EndIf
			EndIf

			If lRet
				aTipo09 := Ft600GetTipo09()
				For nS := 1 To Len(aTipo09)
					nPosItem := aScan(aTipo09, {|x| x[5] == cPosItem .And. x[6] == cPosFolder})
					If nPosItem > 0
						Adel(aTipo09,nPosItem)
						ASize(aTipo09,Len(aTipo09)-1)
					EndIf
				Next nS
				For nS := 1 To Len(aCols)
					If	!aCols[nS,nColDel]
						aadd(aTipo09, {cPosCod, aCols[nS,nColData], aCols[nS,nColVlr],cCodTp9, cPosItem, cPosFolder})
					Endif
				Next nS
				Ft600SetTipo09(aTipo09)
			EndIf
			A600CroFinance()	// Atualiza Cronograma com as parcelas
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft600VdFCpo
 Valida se os campos necessários para a inclusão dos itens foram preenchidos.

@sample	Ft600VdFCpo( aCampos )

@param		aCampos	Array com os campos que devem ser validados

@return 	lRet		Indica se todos os campos necessários foram informados

@author	Danilo Dias
@since		29/04/2014
@version	12  
/*/
//-----------------------------------------------------------------------------------------
Function Ft600VdFCpo( aCampos )

Local aArea	:= GetArea()
Local lRet 	:= .T.
Local nX 		:= 0

Default aCampos 	:= {}

DbSelectArea("SX3")		//Campos da Tabela
SX3->(DbSetOrder(2))
 
For nX := 1 To Len( aCampos )

	If ( SX3->( DbSeek( aCampos[nX] ) ) )

		If ( Empty( &( aCampos[nX] ) ) )
			Help(,,"FT600VDFPO",,STR0230 + X3Descric(),1,0) //"Por favor, preencha o campo: "
			lRet := .F.
			Exit
		EndIf
		
	EndIf

Next nX

RestArea( aArea )

Return lRet

//-----------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft600BlqProp

Devido ao fracionamento dos fontes, é necessário guardar o conteúdo da variável estática do
retorno do bloqueio da proposta para passar para os outros fontes que compõem o FATA600,
evitando assim, a declaração de variáveis Private.	 

@sample     Ft600BlqProp( ) 

@return     _lBlqProp  = .T. Bloqueia, .F. Não Bloqueia 

@author     Thamara Villa Jacomo
@since      13/01/2014
@version    P12
/*/
//-----------------------------------------------------------------------------------------
Function Ft600BlqProp()

Return( _lBlqProp )

//------------------------------------------------------------------------------
/*/{Protheus.doc} Ft600VProd
@description	Valida se existe o produto e retorna os acessorios caso haja.
@sample	 	Ft600VProd( cMdlDetail )
@param			cMdlDetail		, Caracter	, Nome do ModelGrid
@Return	   	lRet		 	, Logico	, Verdadeiro se o produto digitado existe e se a carga dos acessorios foi executada com sucesso caso haja.
@author		Anderson Silva
@since			09/03/2016
@version		12.1.17 
/*/
//------------------------------------------------------------------------------
Function Ft600VProd(cMdlDetail)

Local oModel 		:= FwModelActive()
Local oMdlAtu		:= oModel:GetModel( cMdlDetail )
Local oMdlAce		:= Nil
Local cIdProduct	:= oMdlAtu:GetValue("ADZ_PRODUT")
Local lRet 		:= ExistCpo("SB1",cIdProduct,1)

If lRet .And. oMdlAtu:GetId() == "ADZPRODUTO"
	oMdlAce	:= oModel:GetModel("ADZACESSOR")
	lRet 		:= FT600Accessory( oMdlAtu:GetValue("ADZ_ITEM") ,oMdlAtu:GetValue("ADZ_PRODUT"), oMdlAce )
EndIf
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} A600VTP09
@description	Executa a tela de parcelas da cond. pgto Tipo 9
              	Este tratamento foi retirado da validação de campo, para que seja executado após a
              	execução das validações de usuário do TDI
@sample	 	A600VTP09 ( cMdlGrid )
@param			cMdlGrid, Caracter, Nome do Model. Produto / Acessório
@Return	   	lRet, Logico, Falso se a condição de pagamento for 9 e houver problemas na geração das parcelas
@author		Renato Cunha
@since			05/05/2016
@version		12.1.17 
/*/
//-------------------------------------------------------------------------------------
Function A600VTP09(cMdlGrid)

Local aArea	:=	GetArea()
Local oModel	:= FwModelActive()
Local oMdlAtu	:= Nil
Local lRet 	:= .T. 

Default cMdlGrid	:= ""

If !Empty(cMdlGrid)
	oMdlAtu := oModel:GetModel(cMdlGrid)
	SE4->(DbSetOrder(1))
	If SE4->(DbSeek(xFilial("SE4")+oMdlAtu:GetValue("ADZ_CONDPG")))
		If SE4->E4_TIPO == "9" .and. !At600Tipo9(oMdlAtu:GetValue("ADZ_CONDPG"),oModel,cMdlGrid,SE4->E4_COND)
			lRet := .F.
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return ( lRet )
