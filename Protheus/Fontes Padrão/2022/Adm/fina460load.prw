#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "FINA460.CH"

Static nTamLiq 		:= 0
Static lF460NUM		:= NIL
Static __cMarca 	:=  GetMark()
Static lCpoFO1Ad	:= .F.
Static lPLSFN460	:= findFunction('PLSFN460')
Static __nTxJuros  	:= NIL
Static __cJurTipo	:= NIL
Static __lF460PGE	:= NIL
Static __oStNumLi 	:= NIL
Static __lExcImpo   := Nil
Static __lCnabImp   := Nil
Static __oPagPix    := Nil
//-------------------------------------------------------------------
/*/{Protheus.doc} FINA460LOAD()
Funções para a carga do modelo de liquidação a receber

@author Pâmela Bernardo
@since 15/10/2015
@version P12.1.8
/*/
//-------------------------------------------------------------------
Function FINA460LOAD()

Return

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F460Mtela()
	Funções para a carga do modelo de liquidação a receber

	@author Pâmela Bernardo
	@since 15/10/2015
	@version P12.1.8
	@param cAliasFO1: tabela temporária, para carga de dados
	@param oModelLiq: Modelo Ativo
	@param cCLient: Cliente usado para geração dos títulos
	@param cLoja: Loja do cliente usado para geração dos títulos
	@param nMoeda: Moeda usada na geração de títulos
	@param cNaturez: Natureza usada na geração de títulos
	@param nOpc: 1 para load de gravação de liquidação/simulação ou 2 para simulação já existente

	/*/
//-------------------------------------------------------------------

Function F460Mtela(cAliasFO1, oModelLiq, cCLient, cLoja, nMoeda,cNaturez, lCmC7 )

	Local oFO0		:= Nil
	Local oFO1		:= Nil
	Local cChaveFK7	:= ""
	Local cChaveTit	:= ""
	Local cNomeCli	:= ""
	Local aArea		:= GetArea()
	Local cVersao 	:= '0001'
	Local cMvJurTipo:= cJurTipo() // calculo de Multa do Loja , se JURTIPO == L
	Local lMulLoj	:= SuperGetMv("MV_LJINTFS", ,.F.)
	Local nLimVld   := SuperGetMV("MV_LMVLDLQ",.F.,0)
	Local nTxMulta 	:= 0 
	Local nTotLiq	:= 0
	Local cNLiquid	:= ""
	Local lUsaMark	:= (FwIsInCallStack("F460AIncl") .Or. FwIsInCallStack("A460Liquid"))
	Local cOrigem   := ""
	Local lTMKA271  := FwIsInCallStack("TMKA271D")
	Local lCodLig   := Type("cCodLig") == "C"
	Local lCpoTxMoed:= FO0->(ColumnPos("FO0_TXMOED")) > 0
	Local lCpoCalJur:= FO0->(ColumnPos("FO0_CALJUR")) > 0

	If FwIsInCallStack("A460Liquid") 
		cNLiquid := F460NumLiq()
	EndIf

	Default cAliasFO1	 := ""
	Default cCLient	     := ""
	Default cLoja		 := ""
	Default nMoeda	 	 := 1
	Default cNaturez	 := ""
	Default lCMC7		 := .F.

	oFO0 := oModelLiq:GetModel('MASTERFO0')
	oFO1 := oModelLiq:GetModel('TITSELFO1')
	
	If Empty(cFunOrig)
		If SubStr(FunName(),1,8) $ "FINA740|FINA460"
			cOrigem:= "FINA460"
		Else
			cOrigem := SubStr(FunName(),1,8)
		EndIf
	Else
		cOrigem := cFunOrig
	Endif

	cNomeCli:= Posicione("SA1",1,xFilial("SA1") + cClient + cLoja, "A1_NOME")

	If cMvJurTipo == "L"
		nTxJuros()
	Endif

	If cMvJurTipo == "L" .Or. lMulLoj
		nTxMulta := SuperGetMV("MV_LJMULTA",.F.,0)
	EndIf

	cProcess := FINIDPROC("FO0","FO0_PROCES",cVersao)

	oFO0:LoadValue("FO0_PROCES"	, cProcess	)
	oFO0:LoadValue("FO0_VERSAO"	, cVersao	)
	oFO0:LoadValue("FO0_RAZAO"  , cNomeCli  )
	oFO0:LoadValue("FO0_CLIENT"	, cClient	)
	oFO0:LoadValue("FO0_LOJA"	, cLoja  	)
	oFO0:LoadValue("FO0_NATURE"	, cNaturez	)
	oFO0:LoadValue("FO0_MOEDA"	, nMoeda	)
	oFO0:LoadValue("FO0_DATA"	, dDataBase	)
	oFO0:LoadValue("FO0_DTVALI"	, dDataBase+nLimVld	)//Data atual + Limite de dias para vencimento 
	oFO0:LoadValue("FO0_TXJUR"	, __nTxJuros)
	oFO0:LoadValue("FO0_TXMUL"	, nTxMulta	)
	oFO0:LoadValue("FO0_NUMLIQ"	, cNLiquid	)
	oFO0:LoadValue("FO0_ORIGEM"	, cOrigem	)
	If lCpoTxMoed .And. lOpcAuto .And. nOutrMoed = 3
		oFO0:LoadValue("FO0_TXMOED",nTxNegoc)
	EndIf

	If lCpoCalJur .And. lOpcAuto
		oFO0:LoadValue("FO0_CALJUR",nTxCalJur)
	Endif

	If lTMKA271 .And. lCodLig
		oFO0:LoadValue("FO0_CODLIG" , cCodLig )
	EndIf

	dbSelectArea(cAliasFO1)		
	If nValorMax > 0
		DbEval({ |a| FA460DBEVA(cAliasFO1, nValorMax, @nQtdTit)})
	EndIf		
	(cAliasFO1)->(dbGoTop())

	While !(cAliasFO1)->(Eof())

		cChaveTit := xFilial("SE1",(cAliasFO1)->FO1_FILORI) + "|" + (cAliasFO1)->FO1_PREFIX + "|" + (cAliasFO1)->FO1_NUM     + "|" + (cAliasFO1)->FO1_PARCEL + "|" + ;
		(cAliasFO1)->FO1_TIPO + "|" + (cAliasFO1)->FO1_CLIENT + "|" + (cAliasFO1)->FO1_LOJA
		cChaveFK7 := FINGRVFK7("SE1", cChaveTit,  xFilial("SE1",(cAliasFO1)->FO1_FILORI))

		If !oFO1:IsEmpty()
			oFO1:AddLine()
		EndIf

		oFO1:LoadValue("FO1_MARK"	, (cAliasFO1)->FO1_MARK/*!lUsaMark*/	)			
		oFO1:LoadValue("FO1_PROCES"	,  oFO0:GetValue("FO0_PROCES")	)
		oFO1:LoadValue("FO1_VERSAO"	,  oFO0:GetValue("FO0_VERSAO")	)
		oFO1:LoadValue("FO1_FILORI"	, (cAliasFO1)->FO1_FILORI	)
		oFO1:LoadValue("FO1_PREFIX"	, (cAliasFO1)->FO1_PREFIX	)
		oFO1:LoadValue("FO1_NUM"	, (cAliasFO1)->FO1_NUM		)
		oFO1:LoadValue("FO1_PARCEL"	, (cAliasFO1)->FO1_PARCEL	)
		oFO1:LoadValue("FO1_TIPO"	, (cAliasFO1)->FO1_TIPO		)
		oFO1:LoadValue("FO1_CLIENT"	, (cAliasFO1)->FO1_CLIENT	)
		oFO1:LoadValue("FO1_LOJA"	, (cAliasFO1)->FO1_LOJA		)
		oFO1:LoadValue("FO1_NATURE"	, (cAliasFO1)->FO1_NATURE	)
		oFO1:LoadValue("FO1_IDDOC"	, cChaveFK7					)
		oFO1:LoadValue("FO1_MOEDA"	, (cAliasFO1)->FO1_MOEDA	)
		oFO1:LoadValue("FO1_TXMOED"	, (cAliasFO1)->FO1_TXMOED	)
		oFO1:LoadValue("FO1_EMIS"	, (cAliasFO1)->FO1_EMIS		)
		oFO1:LoadValue("FO1_VENCTO"	, (cAliasFO1)->FO1_VENCTO	)
		oFO1:LoadValue("FO1_VENCRE"	, (cAliasFO1)->FO1_VENCRE	)
		oFO1:LoadValue("FO1_SALDO"  , (cAliasFO1)->FO1_SALDO	)
		oFO1:LoadValue("FO1_BAIXA"	, (cAliasFO1)->FO1_BAIXA	)
		oFO1:LoadValue("FO1_VLBAIX"	, (cAliasFO1)->FO1_VLBAIX	)
		oFO1:LoadValue("FO1_HIST"	, (cAliasFO1)->FO1_HIST		)
		oFO1:LoadValue("FO1_TXJUR"	, (cAliasFO1)->FO1_TXJUR	)
		oFO1:LoadValue("FO1_VLDIA"	, (cAliasFO1)->FO1_VLDIA	)
		oFO1:LoadValue("FO1_VLJUR"	, (cAliasFO1)->FO1_VLJUR	)
		oFO1:LoadValue("FO1_TXMUL"	, (cAliasFO1)->FO1_TXMUL	)
		oFO1:LoadValue("FO1_VLMUL"	, (cAliasFO1)->FO1_VLMUL	)
		oFO1:LoadValue("FO1_DESCON"	, (cAliasFO1)->FO1_DESCON   )
		oFO1:LoadValue("FO1_VLABT"	, (cAliasFO1)->FO1_VLABT	)
		oFO1:LoadValue("FO1_ACRESC"	, (cAliasFO1)->FO1_ACRESC	)
		oFO1:LoadValue("FO1_DECRES"	, (cAliasFO1)->FO1_DECRES	)
		oFO1:LoadValue("FO1_VALCVT"	, (cAliasFO1)->FO1_VALCVT	)
		oFO1:LoadValue("FO1_TOTAL"	, (cAliasFO1)->FO1_TOTAL	)		
		oFO1:LoadValue("FO1_VACESS" , (cAliasFO1)->FO1_VACESS	)
		oFO1:LoadValue("FO1_CCUST"  , (cAliasFO1)->FO1_CCUST	)
		oFO1:LoadValue("FO1_ITEMCT" , (cAliasFO1)->FO1_ITEMCT	)
		oFO1:LoadValue("FO1_CLVL"   , (cAliasFO1)->FO1_CLVL 	)
		oFO1:LoadValue("FO1_CREDIT" , (cAliasFO1)->FO1_CREDIT 	)
		oFO1:LoadValue("FO1_DEBITO" , (cAliasFO1)->FO1_DEBITO 	)	
		oFO1:LoadValue("FO1_CCC" 	, (cAliasFO1)->FO1_CCC 	)	
		oFO1:LoadValue("FO1_CCD" 	, (cAliasFO1)->FO1_CCD 	)	
		oFO1:LoadValue("FO1_ITEMC" 	, (cAliasFO1)->FO1_ITEMC 	)	
		oFO1:LoadValue("FO1_ITEMD" 	, (cAliasFO1)->FO1_ITEMD 	)	
		oFO1:LoadValue("FO1_CLVLCR" , (cAliasFO1)->FO1_CLVLCR 	)	
		oFO1:LoadValue("FO1_CLVLDB" , (cAliasFO1)->FO1_CLVLDB 	)	
		
		If lTMKA271
			oFO1:LoadValue("FO1_DESJUR"	, (cAliasFO1)->FO1_DESJUR	)
		EndIf

		//Totalizador de valor a liquidar
		If (cAliasFO1)->FO1_MARK .or. !lUsaMark
			nTotLiq += (cAliasFO1)->FO1_TOTAL
		Endif

		(cAliasFO1)->(dbSkip())

	Enddo

	oFO0:LoadValue("FO0_VLRLIQ"	,nTotLiq )
	oFO0:LoadValue("FO0_VLRNEG"	, 0)

	oFO1:SetNoInsertLine(.T.)
	oFO1:SetNoDeleteLine(.T.)

	RestArea(aArea)

	Return .T.

	//-------------------------------------------------------------------
	/*/{Protheus.doc} F460TitGer()

	Rotina que realiza carga das parcelas no grid de títulos gerados

	@author julio.teixeira
	@since 21/10/2015
	@version P12.1.8
	/*/
//-------------------------------------------------------------------
Function F460TitGer(oModel, cCampo, nLinFO1,lUsaCmC7,lMarkAll,lUltTit, __lNExbMsg)
	Local lRet			:= .T.
	Local oModelFO0 	:= oModel:GetModel('MASTERFO0')
	Local oModelFO1 	:= oModel:GetModel('TITSELFO1')
	Local oModelFO2		:= oModel:GetModel('TITGERFO2')
	Local oView 		:= FWViewActive()

	Local cCondicao 	:= oModelFO0:GetValue("FO0_COND")
	Local cNum			:= ''
	Local cTipoTit		:= ''
	Local cLastParc		:= ''
	Local cMensagem		:= ''
	Local cQuery		:= ''
	Local cTMPNum	   	:= ''
	Local cNumLiq		:= ''

	Local nMarcas		:= 0
	Local nCount		:= 0
	Local nValParc		:= 0
	Local nDifer		:= 0
	Local nCond			:= 0
	Local nValJur		:= 0
	Local nTamParc      := TamSx3("E1_PARCELA")[1]
	Local nJuros        := 0
	Local nDescon       := 0

	Local cE1Chv		:= ""
	Local cCliente		:= ''
	Local cLoja			:= ''
	Local cNumRa		:= ''
	Local cPerLet		:= ''
	Local cTurma		:= ''
	Local cIDAPLIC		:= ''
	Local nRecAux		:= 0
	Local nOpera		:= oModel:GetOperation()
	Local nTotNeg		:= 0
	Local nTotLiq		:= 0
	Local nQtdeTit		:= 0
	Local nVlrNeg		:= 0
	Local nTtlJur		:= 0
	Local nTtlNeg		:= 0
	Local nTtlPos		:= 0
	Local lGeraSEF		:= SuperGetMv("MV_GRSEFLQ",.F., .F. )
	Local aAreaAtu		:= {}
	Local lNoAltGrid 	:= (!(FwIsInCallStack("F460AIncl")) .and. !(FwIsInCallStack("A460Liquid")) .and. !(FwIsInCallStack("F460AltSim")) .and. !(FwIsInCallStack("F460VerSim")) .and. !(FwIsInCallStack("TMKA271D")) )
	Local cBanco		:= ""
	Local cAgencia		:= ""
	Local cConta		:= ""
	Local cParc2Ger  	:= Alltrim(SuperGetMv("MV_1DUP")) 
	Local cTipoCond    	:= ''
	Local nX           	:= 0
	Local nTotMark     	:= 0
	Local nTotNegFO0   	:= 0
	Local nTtlLiq	   	:= 0
	Local nTtlFO2	   	:= 0
	Local nTtlJurFO0   	:= 0	
	Local lExecElse    	:= .F.
	Local cPrefix	   	:= oModelFO2:GetValue("FO2_PREFIX") 
	Local lTMKA271	   	:= FwIsInCallStack("TMKA271D")
	Local lPrfTMK	   	:= Type("cPrfTMK") == "C"
	Local nPorcJur		:= 0
	Local nPosFO1		:= oModelFO1:GetLine()
	Local lF460DES	    := ExistBlock("F460DES")
	Local nDescBol 		:= 0
	Local lFini055		:= IsInCallStack("FINI055")
	Local lSldBxCr		:= (SuperGetMv('MV_SLDBXCR',.F.,'B') == 'C') .And. FindFunction('TemChqCr')
	local l460PGE		:= Existblock("F460PGE")
	Local lSitCobPix	:= .F.	
	Local bEValPix		:= {||TtBxImpPix(SE1->(Recno()))}
	Local cIdDocFK7		:= ""
	Local lTemImpPix    := .F.
	
	Default cCampo		:= ""
	Default nLinFO1		:= 0
	Default lUsaCmC7	:= .F.
	Default lMarkAll	:= .F.
	Default lUltTit		:= .F.
	Default __lNExbMsg  := .F.
	
	If nTamParc > Len(cParc2Ger)
		cParc2Ger := cParc2Ger + SPACE( nTamParc-Len(cParc2Ger) )
	ElseIf nTamParc < Len(cParc2Ger)
		cParc2Ger := Substr(cParc2Ger,1,nTamParc)
	EndIf

	nRecAux := SE1->(Recno())
	cE1Chv 	:= xFilial("SE1",oModelFO1:GetValue("FO1_FILORI"))+oModelFO1:GetValue("FO1_PREFIX")+oModelFO1:GetValue("FO1_NUM")+oModelFO1:GetValue("FO1_PARCEL")+oModelFO1:GetValue("FO1_TIPO")

	dbSelectArea("FO1")
	lCpoFO1Ad := FO1->(ColumnPos("FO1_VLADIC")) > 0

	SE1->(DbSetOrder(1))
	SE1->(MsSeek(cE1Chv))

	cCliente		:= SE1->E1_CLIENTE
	cLoja			:= SE1->E1_LOJA
	
   	If __lExcImpo == Nil
		__lExcImpo := FindFunction("ExcluiImpo")
	EndIf
	
	If __lCnabImp == Nil 
		__lCnabImp := SuperGetMV("MV_CNABIMP", .F., .F.)
	EndIf
	
	If __lExcImpo .And. !__lCnabImp .And. cCampo == "FO1_MARK"
		lTemImpPix := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)
		
		If !lTemImpPix
			lTemImpPix := HistPagPix(SE1->E1_FILORIG, SE1->(E1_FILIAL+"|"+E1_PREFIXO+"|"+E1_NUM+"|"+E1_PARCELA+"|"+E1_TIPO+"|"+E1_CLIENTE+"|"+E1_LOJA), @__oPagPix)
			
			If !lTemImpPix  .And. (lSitCobPix := IIf(!lSitCobPix, Eval(bEvalPix) ,lSitCobPix))				
				lRet := IIf(!lOpcAuto .And. !__lNExbMsg, MsgTtBxPix(.F.,.F.,.T., @__lNExbMsg), .T.)
				
				If !lRet 
					oModelFO1:SetValue("FO1_MARK", .F.)	
					
					If !lOpcAuto
						oView:Refresh()
					EndIf		
				ElseIf lRet  .And. ExcluiImpo(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, Nil)
					cIdDocFK7 := FinBuscaFK7(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA, "SE1", SE1->E1_FILORIG)
					PIXCancel(SE1->E1_FILIAL, cIdDocFK7)
					F460AtuMod(nMoeda)
				EndIf		
			EndIf
		EndIf
	EndIf
	
	If !Empty(MV_PAR08)
		If cCampo == "FO0_TXJUR" .Or. cCampo == "FO0_TXMUL"
			cPrefix	:= oModelFO2:GetValue("FO2_PREFIX")
		Else
			cPrefix	:= Upper(MV_PAR08)
		Endif
	Else
		If cCampo == "FO0_TXJUR" .Or. cCampo == "FO0_TXMUL"
			cPrefix	:= oModelFO2:GetValue("FO2_PREFIX")
		Endif
	Endif

	If GetNewPar("MV_RMCLASS",.F.)
		cNumRa		:= SE1->E1_NUMRA
		cPerLet		:= SE1->E1_PERLET
		cTurma		:= SE1->E1_TURMA
		cIDAPLIC	:= SE1->E1_IDAPLIC
		cBanco		:= SE1->E1_PORTADO
		cAgencia	:= SE1->E1_AGEDEP
		cConta		:= SE1->E1_CONTA
	EndIf

	If GetNewPar('MV_RMBIBLI',.F.) .And. AllTrim(Upper(Posicione("SE1", 1, cE1Chv, "E1_ORIGEM") ) ) == 'L' .And. (oModelFO1:GetValue("FO1_MARK"))
		Aviso(STR0188,STR0189,{STR0190}) //"Não é permitido liquidar/renegociar títulos nativos do RM Biblios"
		lRet := .F.
		oModelFO1:SetValue("FO1_MARK", .F.)
		If !lOpcAuto
			oView:Refresh()
		EndIf
	ElseIf GetNewPar('MV_RMCLASS',.F.)

		//Validação para integração do Protheus x RM Classis via mensagem única
		//A validação na verdade ocorre antes da chamda da integdef, durante a seleção dos títulos para liquidação
		If SE1->(MsSeek(cE1Chv))

			If (Empty(cNumRa) .And. Empty(cPerLet) .And. Empty(cTurma) .And. Empty(cIDAPLIC)) .And.;
			(!Empty(SE1->E1_NUMRA) .And. !Empty(SE1->E1_PERLET) .And. !Empty(SE1->E1_TURMA) .And. !Empty(E1_IDAPLIC))
				Aviso(STR0221,STR0222,{'Ok'})	//'Integração Protheus x RM Classis'###'Não é permitido selecionar títulos oriundos da integração com títulos distintos'
				lRet := .F.
			EndIf

			If SE1->(E1_CLIENTE+E1_LOJA) != cCliente+cLoja
				Aviso(STR0221,STR0223,{'Ok'})	//'Integração Protheus x RM Classis'###'Não é permitido selecionar títulos de clientes diferentes'
				lRet := .F.
			EndIf

			If SE1->E1_NUMRA != cNumRa
				Aviso(STR0221,STR0224,{'Ok'})	//'Integração Protheus x RM Classis'###'É permitido renegociar apenas títulos que pertençam a um mesmo número de RA'
				lRet := .F.				
			EndIf

			If SE1->E1_PERLET != cPerLet
				Aviso(STR0221,STR0225,{'Ok'})	//'Integração Protheus x RM Classis'###'É permitido renegociar apenas títulos que pertençam a um mesmo Período Letivo'
				lRet := .F.				
			EndIf

			If SE1->E1_TURMA != cTurma
				Aviso(STR0221,STR0226,{'Ok'})	//'Integração Protheus x RM Classis'###'É permitido renegociar apenas títulos que pertençam a uma mesma Turma'
				lRet := .F.								
			EndIf

			If SE1->E1_IDAPLIC != cIDAPLIC
				Aviso(STR0221,STR0227,{'Ok'})	//'Integração Protheus x RM Classis'###'É permitido renegociar apenas títulos que pertençam a uma mesma Matriz Aplicada'
				lRet := .F.								
			EndIf

		EndIf

	EndIf
	//Verifica se existe cheque para o título aguardando compensação
	If lRet	.And. lSldBxCr .And. cCampo != "FO0_COND"
		If TemChqCr(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO )
			lRet := .F.
			oModelFO1:SetValue("FO1_MARK", .F.)
			Help(" ",1,"F460TITCH",,STR0275, 1, 0)//'Títulos com cheques aguardando compensações não serão selecionados!'
			If ! lOpcAuto
				oView:Refresh()
			EndIf
		EndIf
	EndIf
	
	If  cCampo == "FO1_MARK" .And. oModelFO1:GetValue("FO1_TOTAL") < 0
		cMensagem	:= STR0231 + CRLF
		cMensagem	+= STR0232

		lRet	:= .F.
		Help(" ",1,"F460ANEG",,cMensagem, 1, 0) 	//"Não é possivel selecionar esse titulo. O valor a negociar está negativo.  "	
		oModelFO1:SetValue("FO1_MARK", .F.)		//"Favor verificar os valores acessorios cadastrados para esse títuo. "                                                                                                                                                                                                                                                                                                                                                                                                                                               
		If !lOpcAuto
			oView:Refresh()
		EndIf	
	EndIf

    //verificacao SIGAPLS
	if lPLSFN460 .and. cCampo == "FO1_MARK" .and. lRet
		if PLSFN460(oModelFO1)
			lRet := .F.
            oModelFO1:SetValue("FO1_MARK", .f.)	
			if ! lOpcAuto
				oView:Refresh()
			endIf
        endIf
    endIf    

	If cCampo == "FO1_MARK" .And. lRet

		If (SE1->( SimpleLock())) .And. oModelFO1:GetValue("FO1_MARK") .AND. (Empty(SE1->E1_TIPOLIQ) .OR. SE1->E1_SALDO <> 0)
			lRet := .T.
		ElseIf (SE1->( SimpleLock())) .and. !oModelFO1:GetValue("FO1_MARK") .And. (Empty(SE1->E1_TIPOLIQ) .OR. SE1->E1_SALDO <> 0)
			SE1->(MsUnlock())
			lRet := .T.
		ElseIf !(SE1->( SimpleLock())) .Or. !Empty(SE1->E1_TIPOLIQ)

			If !lMarkAll 
				Help(" ",1,"F460MARCA",,STR0239, 1, 0) 
			EndIf	
			oModelFO1:SetValue("FO1_MARK", .F.)
			If !lOpcAuto
				oView:Refresh()
			Endif		      
			lRet := .F.
		EndIF
	Endif	
	If Empty(oModelFO0:GetValue("FO0_TIPO"))
		cTipoTit	:= oModelFO2:GetValue("FO2_TIPO")	
	Else
		If cCampo == "FO0_TXJUR" .Or. cCampo == "FO0_TXMUL"
			oModelFO2:GoLine(1)
			cTipoTit	:= oModelFO2:GetValue("FO2_TIPO")
		Else
			cTipoTit	:= oModelFO0:GetValue("FO0_TIPO") 
		Endif
	EndIf

	If lRet 
		If !lMarkAll .Or. (lMarkAll .And. lUltTit) 
			aAreaAtu 	:= GetArea()
			//Query verifica qual o codigo MAX da SE1 com o prefixo LIQ e TIPO FT para o cliente.
			cQuery := " SELECT MAX(E1_NUM) AS NUMMAX " 		+ CRLF
			cQuery += " FROM " + RetSqlName("SE1") + " SE1 "	+ CRLF
			cQuery += " WHERE " 									+ CRLF
			cQuery += " SE1.E1_FILIAL 	= '" + xFilial("SE1",oModelFO1:GetValue("FO1_FILORI")) + "' AND " + CRLF
			cQuery += " SE1.E1_TIPO 	= '" + cTipoTit   + "' AND " + CRLF
			cQuery += " SE1.E1_PREFIXO 	= '" + cPrefix + "' AND " + CRLF
			cQuery += " SE1.D_E_L_E_T_	= ''                     " + CRLF
	
			cQuery 	:= ChangeQuery(cQuery)
			cTMPNum	:= GetNextAlias()
			dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTMPNum, .F., .T.)
	
			cNumLiq := Iif(!Empty((cTMPNum)->NUMMAX),SOMA1(Alltrim((cTMPNum)->NUMMAX)),SOMA1((cTMPNum)->NUMMAX))
	
			While !MayIUseCode( oModelFO1:GetValue("FO1_FILORI") + cPrefix + cNumLiq)  //verifica se esta na memoria, sendo usado
				// busca o proximo numero disponivel 
				cNumLiq := Soma1(cNumLiq)
			EndDo
	
			(cTMPNum)->( dbCloseArea() )
	
			If !Empty(cTipoTit)
				If cCampo == "FO0_TXJUR" .Or. cCampo == "FO0_TXMUL"
					cNum := oModelFO2:GetValue("FO2_NUM")
				Else
					cNum := cNumLiq
				Endif	
			EndIf
			RestArea(aAreaAtu)
	
			oModelFO2:Goline(1)
			oModelFO2:SetNoInsertLine(.F.)
			oModelFO2:SetNoDeleteLine(.F.)
		EndIf

		If cCampo == "FO0_COND" .AND. nOpera == MODEL_OPERATION_INSERT
			oModelFO2:ClearData( .T. )//Limpa o grid com as parcelas calculadas
			oModelFO0:LoadValue("FO0_VLRNEG", 0 )

		Elseif cCampo == "FO1_MARK"

			If lRet .And. ExistBlock( "F460LQOK" ) 
				lRet := ExecBlock( "F460LQOK" )

				If !lRet
					oModelFO1:loadValue("FO1_MARK", lRet )
					nTtlJur := 0
					For nX := 1 to oModelFO1:Length()
						If oModelFO1:GetValue("FO1_MARK",nX)
							nTotMark += oModelFO1:GetValue("FO1_TOTAL",nX)
							nTtlJur  += oModelFO1:GetValue("FO1_VLJUR",nX)
							nQtdeTit++
						EndIf
					Next nX
					oModelFO0:LoadValue("FO0_VLRLIQ", nTotMark)
					oModelFO0:LoadValue("FO0_VLRNEG" , nTotMark )
					oModelFO0:LoadValue("FO0_VLRJUR", nTtlJur) 
					If !lOpcAuto
						oView:Refresh()
					EndIf
				Else
					lExecElse := .T.
				Endif 	
			Else
				lExecElse := .T.
			Endif
			
		ElseIf  "FO1_" $ cCampo
			nTtlJur  := 0
			nTotMark := 0
			nQtdeTit := 0
			For nX := 1 to oModelFO1:Length()
				If oModelFO1:GetValue("FO1_MARK",nX)
					nTotMark += oModelFO1:GetValue("FO1_TOTAL",nX)
					nTtlLiq  += oModelFO1:GetValue("FO1_SALDO",nX)
					nTtlJur  += oModelFO1:GetValue("FO1_VLJUR",nX) + oModelFO1:GetValue("FO1_VLMUL",nX)
					nQtdeTit++
				EndIf
			Next nX
			
			For nX := 1 To oModelFO2:Length()
				oModelFO2:GoLine(nX)
				nTotNegFO0 += oModelFO2:GetValue("FO2_TOTAL")
			Next nX
			
			oModelFO0:LoadValue("FO0_VLRLIQ", nTtlLiq)
			oModelFO0:LoadValue("FO0_VLRNEG", nTotNegFO0)
			oModelFO0:LoadValue("FO0_VLRJUR", nTtlJur) 
			
		ElseIf  cCampo == "FO0_TXJUR"
			If oModelFO0:GetValue("FO0_TXMUL") > 0
				nTtlJur  := 0
				nTotMark := 0
				nQtdeTit := 0
			Endif
			For nX := 1 to oModelFO1:Length()
				If oModelFO1:GetValue("FO1_MARK",nX)
					nTotMark += oModelFO1:GetValue("FO1_TOTAL",nX)
					nTtlLiq  += oModelFO1:GetValue("FO1_SALDO",nX)
					nTtlJur  += oModelFO1:GetValue("FO1_VLJUR",nX) + oModelFO1:GetValue("FO1_VLMUL",nX)
					nQtdeTit++
				EndIf
			Next nX
			oModelFO0:LoadValue("FO0_VLRLIQ", nTtlLiq)
			oModelFO0:LoadValue("FO0_VLRJUR", nTtlJur) 	
			
		ElseIf  cCampo == "FO0_TXMUL"
			If oModelFO0:GetValue("FO0_TXJUR") > 0
				nTtlJur  := 0
				nTotMark := 0
				nQtdeTit := 0
			Else	
				nTtlJur  := 0
				nTotMark := 0
				nQtdeTit := 0
			Endif
			For nX := 1 to oModelFO1:Length()
				If oModelFO1:GetValue("FO1_MARK",nX)
					nTotMark += oModelFO1:GetValue("FO1_TOTAL",nX)
					nTtlLiq  += oModelFO1:GetValue("FO1_SALDO",nX)
					nTtlJur  += (oModelFO1:GetValue("FO1_VLJUR",nX) + oModelFO1:GetValue("FO1_VLMUL",nX))
					nQtdeTit++
				EndIf
			Next nX
			oModelFO0:LoadValue("FO0_VLRLIQ", nTtlLiq)
			oModelFO0:LoadValue("FO0_VLRNEG", nTotMark)
			oModelFO0:LoadValue("FO0_VLRJUR", nTtlJur) 
		Else
			lExecElse := .T.
		Endif	

		If lExecElse

			nTotLiq  := oModelFO0:GetValue("FO0_VLRLIQ")
			nTtlJur	 := oModelFO0:GetValue("FO0_VLRJUR")
			nQtdeTit := Val(oModelFO0:GetValue("FO0_TTLTIT"))
			nVlrNeg  := oModelFO0:GetValue("FO0_VLRNEG")

			If lF460DES
				nDescon := ExecBlock("F460DES",.F.,.F.)
			Else
				nDescon := FaDescFin("SE1",dDataBase,SE1->E1_VALOR,SE1->E1_MOEDA)
			EndIf
			//Atualizar o valor de bolsa para integração RM Educacional
			If !lFini055 .and. cFilMsg == "1"
				If !FA070Integ(.F.)
					oModelFO1:SetValue("FO1_MARK", .F.)
					lRet:= .F.
				Else
					nDescBol := SE1->E1_VLBOLSA
					nDescon += nDescBol
				EndIf
			Endif
			
			nDescon := Round(NoRound(xMoeda(nDescon,SE1->E1_MOEDA,SE1->E1_MOEDA,,3),3),2)
			
			oModelFO1:GoLine(nPosFO1)
			
			If oModelFO1:GetValue("FO1_MARK")
				nTxJuros()
				If __nTxJuros > 0 .And. oModelFO0:GetValue("FO0_TXJUR") = __nTxJuros
					nJuros := FA070JUROS(SE1->E1_MOEDA,SE1->E1_SALDO)
				ElseIf oModelFO0:GetValue("FO0_TXJUR") > 0

					nJuros := faJuros( SE1->E1_VALOR, SE1->E1_SALDO, oModelFO1:GetValue("FO1_VENCTO"),;
					, oModelFO0:GetValue("FO0_TXJUR"),oModelFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
					oModelFO1:GetValue("FO1_VENCTO"),,,,,,/*Recalculo .T. */ ,  /*Liquidação*/)			

					IF SE1->E1_MOEDA <> nMoeda
						nJuros := Round(NoRound(xMoeda(nJuros,SE1->E1_MOEDA,nMoeda,dDataBase,3,oModelFO1:GetValue("FO1_TXMOED")),3),2) 
					EndIF

				Endif

				If nJuros > 0
					oModelFO1:LoadValue("FO1_VLJUR", nJuros )
					oModelFO1:LoadValue("FO1_TXJUR", oModelFO0:GetValue("FO0_TXJUR") )
					F460JurMul(oModel,"FO1_VLJUR",,.T.)
				EndIf
				
				oModelFO1:LoadValue("FO1_DESCON", nDescon )

				If oModelFO0:GetValue("FO0_TXMUL") > 0 .And. oModelFO1:GetValue("FO1_VENCTO") < dDataBase
					oModelFO1:LoadValue("FO1_TXMUL", oModelFO0:GetValue("FO0_TXMUL") )
					oModelFO1:LoadValue("FO1_VLMUL", Round(NoRound(xMoeda(oModelFO1:GetValue("FO1_SALDO"),oModelFO1:GetValue("FO1_MOEDA"),nMoeda,dDataBase,3,oModelFO1:GetValue("FO1_TXMOED")) * (oModelFO1:GetValue("FO1_TXMUL")/100) ,3),2) )
				Endif

				nTotLiq += oModelFO1:GetValue("FO1_SALDO")
				nTtlJur += oModelFO1:GetValue("FO1_VLJUR") + oModelFO1:GetValue("FO1_VLMUL")
				nVlrNeg += oModelFO1:GetValue("FO1_TOTAL") + oModelFO1:GetValue("FO1_VACESS")
				nQtdeTit++

				oModelFO0:LoadValue("FO0_VLRLIQ", nTotLiq)
				oModelFO0:LoadValue("FO0_TTLTIT", StrZero(nQtdeTit,4))
				oModelFO0:LoadValue("FO0_VLRJUR", nTtlJur)
				
				nTtlPos := (oModelFO1:GetValue("FO1_ACRESC") + oModelFO1:GetValue("FO1_VLJUR") + oModelFO1:GetValue("FO1_VLMUL") + oModelFO1:GetValue("FO1_VACESS"))
				nTtlNeg := (oModelFO1:GetValue("FO1_DECRES") + oModelFO1:GetValue("FO1_VLABT") + nDescon)

				oModelFO1:LoadValue("FO1_TOTAL" , oModelFO1:GetValue("FO1_VALCVT") - nTtlNeg + nTtlPos)
			Else

				nTotLiq  -= oModelFO1:GetValue("FO1_SALDO") 
				oModelFO0:LoadValue("FO0_VLRLIQ", nTotLiq)

				nQtdeTit--
				oModelFO0:LoadValue("FO0_TTLTIT", StrZero(nQtdeTit,4))

				nTtlJur  -= oModelFO1:GetValue("FO1_VLJUR") + oModelFO1:GetValue("FO1_VLMUL")
				oModelFO0:LoadValue("FO0_VLRJUR", nTtlJur)

				//SE TIVER TAXA DE JUROS OU TAXA DE PERMANENCIA ---- VALOR NÃO ZERA...
				oModelFO1:LoadValue("FO1_VLJUR",SE1->E1_VALJUR )
				oModelFO1:LoadValue("FO1_DESCON", nDescon )
				
				//AO DESMARCAR, A MULTA DEVE SER ATUALIZADA COM BASE NA FO0 OU ZERADA
				If oModelFO0:GetValue("FO0_TXMUL" ) > 0 .And. oModelFO1:GetValue("FO1_VENCTO") < dDataBase
					oModelFO1:LoadValue("FO1_TXMUL", oModelFO0:GetValue("FO0_TXMUL") )
					oModelFO1:LoadValue("FO1_VLMUL", Round(NoRound(oModelFO1:GetValue("FO1_VALCVT") * (oModelFO1:GetValue("FO1_TXMUL")/100) ,3),2) )
				Else
					oModelFO1:LoadValue("FO1_TXMUL", 0 )
					oModelFO1:LoadValue("FO1_VLMUL", 0 )
				EndIf				

				nTtlPos := (oModelFO1:GetValue("FO1_ACRESC") + oModelFO1:GetValue("FO1_VLMUL") + oModelFO1:GetValue("FO1_VLJUR" ) + oModelFO1:GetValue("FO1_VACESS"))
				nTtlNeg := (oModelFO1:GetValue("FO1_DECRES") + oModelFO1:GetValue("FO1_VLABT") + oModelFO1:GetValue("FO1_DESCON"))
				
				F460VldE1(oModelFo1:GetValue("FO1_PREFIX"), oModelFo1:GetValue("FO1_NUM"), oModelFo1:GetValue("FO1_PARCEL"), oModelFo1:GetValue("FO1_TIPO"), @nPorcJur)
				
				If nPorcJur > 0 
					nValJur := faJuros(	oModelFO1:GetValue("FO1_SALDO"),oModelFO1:GetValue("FO1_SALDO"),oModelFO1:GetValue("FO1_VENCTO"),;
					, nPorcJur,oModelFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
					oModelFO1:GetValue("FO1_VENCTO"),,,,,,/*Recalculo .T. */ ,  /*Liquidação*/)
					
					oModelFO1:LoadValue("FO1_TXJUR", nPorcJur )
					oModelFO1:LoadValue("FO1_VLJUR", nValJur )
				Else
					If oModelFO0:GetValue("FO0_TXJUR" ) > 0
						oModelFO1:LoadValue("FO1_TXJUR", oModelFO0:GetValue("FO0_TXJUR" ) )
						oModelFO1:LoadValue("FO1_VLJUR", oModelFO1:GetValue("FO1_VLJUR") )
					Else
						oModelFO1:LoadValue("FO1_TXJUR", 0 )
						oModelFO1:LoadValue("FO1_VLJUR", 0 )
					Endif
				Endif
				
				oModelFO1:LoadValue("FO1_TOTAL" , oModelFO1:GetValue("FO1_VALCVT") - nTtlNeg + nTtlPos)

				If lCpoFO1Ad
					oModelFO1:LoadValue("FO1_VLADIC", 0 )
				EndIf
				
				If !lUsaCmC7
					For nCount := 1 To oModelFO1:Length()
						If oModelFO1:GetValue("FO1_MARK",nCount)
							nMarcas++
						EndIf
					Next nCount

					If nMarcas == 0
						oModelFO2:ClearData( .T. )//Limpa o grid com as parcelas calculadas
						oModelFO0:LoadValue("FO0_VLRNEG", 0 )
					EndIf
				Endif
			EndIf

		EndIf

		If !lMarkAll .Or. (lMarkAll .And. lUltTit)
			SE4->( dbSetOrder( 1 ) )
			If !Empty(cCondicao) .AND. SE4->( MsSeek( xFilial("SE4") + cCondicao  ) )
				cTipoCond := SE4->E4_TIPO
				If SE4->E4_TIPO == "9" 
					If !lOpcAuto
						oView:Refresh()
					EndIf
					aParcelas := {{dDataBase,oModelFO1:GetValue("FO1_TOTAL")}}
				ElseIf SE4->E4_TIPO == "A"
					oModelFO0:LoadValue("FO0_COND",Space(3))
					Help(" ",1,"FA460TIPO",,STR0186, 1, 0)	// As condicoes de pagamento do tipo A são exclusivas dos modulos SIGAVEI e SIGAOFI.
					If !lOpcAuto
						oView:Refresh()
					EndIf
					lRet:= .F.
				EndIf
	
				If lRet
					nValor := 0
					For nCond := 1 to oModelFO1:Length()
						oModelFO1:GoLine(nCond)
						If oModelFO1:GetValue("FO1_MARK",nCond)
							nValor += oModelFO1:GetValue("FO1_TOTAL",nCond)
						EndIf
					Next nCond
	
					If cTipoCond <> "9"
						aParcelas := Condicao( nValor, cCondicao, , dDataBase )
					EndIf 
	
					//------------------------------------------------------------------------------------------------------------
					// Corrige possiveis diferencas entre o valor selecionado e o apurado após a divisao das parcelas
					//------------------------------------------------------------------------------------------------------------
	
					For nCond := 1 to Len(aParcelas)
						nValParc += aParcelas [ nCond, 2]
					Next nCond
					If nValParc != nValor .and. cTipoCond <> "9" 
						nDifer := round(nValor - nValParc,2)
						aParcelas [ Len(aParcelas), 2 ] += nDifer
					EndIf
				EndIf
	
				If nValor > 0 .AND. lRet
	
					nTotNeg := 0
					
					For nCond := 1 To Len(aParcelas)
						
						// Alterar Verificar quando houve alteração na condição de pagamento para não limpar o submodelo. Ao inves disso apenas alterar os valores
						If cCampo == "FO0_COND" .AND. nOpera == MODEL_OPERATION_INSERT
							If !oModelFO2:IsEmpty()
								oModelFO2:AddLine()
								oModelFO2:GoLine(nCond)
							EndIf
						Else
							If nCond > 1 .AND. nCond > oModelFO2:Length()
								oModelFO2:AddLine()
							EndIf
							oModelFO2:GoLine(nCond)
							If oModelFO2:IsDeleted()
								oModelFO2:UnDeleteLine()
							EndIf
						EndIf
	
						If !Empty(cPrefix)
							oModelFO2:LoadValue("FO2_PREFIX", Alltrim(cPrefix))
						EndIf
	
						If !Empty(cBanco)
							oModelFO2:LoadValue("FO2_BANCO", Alltrim(cBanco))
						EndIf
						If !Empty(cAgencia)
							oModelFO2:LoadValue("FO2_AGENCI", Alltrim(cAgencia))
						EndIf
						If !Empty(cConta)
							oModelFO2:LoadValue("FO2_CONTA", Alltrim(cConta))
						EndIf
		
						If lTMKA271 .And. lPrfTMK
							oModelFO2:LoadValue("FO2_PREFIX",cPrfTMK)
						EndIf
	
						If !Empty(cNum) 
	
							//Gero numero da Parcela
							F460GerParc(oModelFO2,oModelFO2:GetLine(),cPrefix,@cNum,cTipoTit,@cLastParc,.T.)
							oModelFO2:LoadValue("FO2_TIPO", Alltrim(cTipoTit))
							oModelFO2:LoadValue("FO2_NUM", Alltrim(cNum))
							If nCond == 1
								If cCampo == "FO0_TXJUR" .Or. cCampo == "FO0_TXMUL"
									cParc2Ger := oModelFO2:GetValue("FO2_PARCEL")
									oModelFO2:LoadValue("FO2_PARCEL",cParc2Ger)
								Else
									oModelFO2:LoadValue("FO2_PARCEL",cParc2Ger)
								Endif
							Else
								If cCampo == "FO0_TXJUR" .Or. cCampo == "FO0_TXMUL"
									cParc2Ger := oModelFO2:GetValue("FO2_PARCEL")
									oModelFO2:LoadValue("FO2_PARCEL",cParc2Ger)
								Else
									cParc2Ger := Soma1(alltrim(cParc2Ger))
									cParc2Ger := cParc2Ger + Space(nTamParc - Len(cParc2Ger))									
									oModelFO2:LoadValue("FO2_PARCEL",cParc2Ger := cParc2Ger)
								Endif
							Endif
						Else
							cNum := "000000001"
							oModelFO2:LoadValue("FO2_NUM", Alltrim(cNum))
							If nCond == 1
								oModelFO2:LoadValue("FO2_PARCEL",cParc2Ger)
							Else
								oModelFO2:LoadValue("FO2_PARCEL",cParc2Ger := Soma1(cParc2Ger))
							Endif	
						Endif
	
						If Alltrim(oModelFO2:GetValue("FO2_TIPO")) == Alltrim(MVCHEQUE) .And. !lGeraSEf
							oModelFO2:LoadValue("FO2_NUMCH",Alltrim(cNum))
						EndIf			
						oModelFO2:LoadValue("FO2_IDSIM" ,FWUUIDV4() ) //Chave ID tabela FK1.
						oModelFO2:LoadValue("FO2_PROCES",oModelFO0:GetValue("FO0_PROCES")) //Processo
						oModelFO2:LoadValue("FO2_VERSAO",oModelFO0:GetValue("FO0_VERSAO")) //Versão
						oModelFO2:LoadValue("FO2_VENCTO",aParcelas[nCond,1])	           // data
						oModelFO2:LoadValue("FO2_VALOR" ,aParcelas[nCond,2])		       // valor da parcela
						oModelFO2:LoadValue("FO2_VLPARC",aParcelas[nCond,2] + oModelFO2:GetValue("FO2_VLJUR")	)
						oModelFO2:LoadValue("FO2_TOTAL" ,aParcelas[nCond,2] + oModelFO2:GetValue("FO2_VLJUR")	) // valor total negociado
	
						nTotNeg += oModelFO2:GetValue("FO2_TOTAL")

						If l460PGE
							Execblock("F460PGE",.F.,.F.,{oModelFO0,oModelFO1,oModelFO2})
						EndIf
	
					Next nCond
	
					oModelFO0:LoadValue("FO0_VLRNEG" ,nTotNeg)	// valor total negociado
	
				EndIf
				nValorLiq	:= 0
				nNroParc	:= 0
			Else
				If !lUsaCmC7
					If Empty(oModelFO2:GetValue("FO2_NUM"))
						oModelFO2:LoadValue("FO2_NUM",Alltrim(cNum))
					Endif
				EndIf	

				nValor := 0
				For nCond := 1 to oModelFO1:Length()
					oModelFO1:GoLine(nCond)
					If oModelFO1:GetValue("FO1_MARK",nCond)
						nValor += oModelFO1:GetValue("FO1_TOTAL",nCond)
					EndIf
				Next nCond
				If (!lUsaCmC7 .And. oModelFO2:Length() == 1 .And. Empty(oModelFO2:GetValue("FO2_NUMCH")) ) .Or. ;
					(lUsaCmC7 .And. Empty(oModelFO2:GetValue("FO2_NUMCH")) .And. nValor > 0 )
					oModelFO2:LoadValue("FO2_VALOR" , nValor)
				EndIf
				If cCampo == "FO0_TXJUR" .Or. cCampo == "FO0_TXMUL" .or. cCampo == "FO1_MARK"
					oModelFO2:LoadValue("FO2_TIPO",oModelFO2:GetValue("FO2_TIPO"))					
					For nCond := 1 to oModelFO2:Length()
						oModelFO2:GoLine(nCond)
						nValJur := faJuros(	oModelFO2:GetValue("FO2_VALOR"),oModelFO2:GetValue("FO2_VALOR"),oModelFO2:GetValue("FO2_VENCTO"),;
						, oModelFO0:GetValue("FO0_TXJUR"),oModelFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
						oModelFO2:GetValue("FO2_VENCTO"),,,,,,/*Recalculo .T. */ , .T. /*Liquidação*/)
						
						oModelFO2:LoadValue("FO2_VLJUR" , nValJur)
						oModelFO2:LoadValue("FO2_VLPARC", oModelFO2:GetValue("FO2_VALOR") + nValJur)
						oModelFO2:LoadValue("FO2_TOTAL" , oModelFO2:GetValue("FO2_VALOR") + nValJur)
						nTtlFO2    += oModelFO2:GetValue("FO2_VALOR") + nValJur
					Next nCond
					oModelFO0:LoadValue("FO0_VLRNEG", nTtlFO2)
					
					For nCond := 1 to oModelFO1:Length()
						oModelFO1:GoLine(nCond)
						If oModelFO1:GetValue("FO1_MARK",nCond)
							nTtlJurFO0 += oModelFO1:GetValue("FO1_VLJUR",nCond) + oModelFO1:GetValue("FO1_VLMUL",nCond)
						EndIf
					Next nCond					
					oModelFO0:LoadValue("FO0_VLRJUR", nTtlJurFO0)
				Else
					If !lUsaCmC7
						If !Empty(oModelFO0:GetValue("FO0_TIPO")) .And. Empty(oModelFO2:GetValue("FO2_TIPO"))
							oModelFO2:LoadValue("FO2_TIPO",oModelFO0:GetValue("FO0_TIPO"))
						Endif
					EndIf
				Endif
			EndIf
		EndIf

		F460CalJur(oModel,oView,2)
		
		oModelFO1:SetNoInsertLine(.T.)
		oModelFO1:SetNoDeleteLine(.T.)

		If cCampo == "FO0_COND" .OR. cCampo == "FO0_TXMUL" .OR. cCampo == "FO0_TXJUR"
			oModelFO1:GoLine(1)
		Else 
			oModelFO1:GoLine(nPosFO1)
		EndIf

		If lNoAltGrid 
			oModelFO2:SetNoInsertLine(.T.)
			oModelFO2:SetNoDeleteLine(.T.)
		Endif
		oModelFO2:GoLine(1)

		If !lOpcAuto 
			oView:Refresh()
		EndIf

	EndIf
	
	If __oPagPix != Nil
		__oPagPix:Destroy()
		__oPagPix := Nil
	EndIf
Return lRet

	//-------------------------------------------------------------------
	/*/{Protheus.doc} FA460LOAD()
	Funções para a carga do modelo de liquidação a receber	

	@author Pâmela Bernardo
	@since 15/10/2015
	@version P12.1.8
	@param oModelLiq: Modelo Ativo

	//-------------------------------------------------------------------
	/*/
Function FA460LOAD(oModelLiq )
	Local nX			:= 0
	Local oFO0			:= Nil
	Local oFO1			:= Nil
	Local oFO2			:= Nil
	Local cChaveTit		:= ""
	Local cNLiquid		:= ""
	Local aArea			:= GetArea()
	Local nMoeda		:= 0
	Local nValorNeg		:= 0
	Local nValorLiq		:= 0
	Local nValTotal		:= 0
	Local nValParc		:= 0
	Local lUsaMark		:= (FwIsInCallStack("F460AEfet")  .Or. FwIsInCallStack("F460AltSim"))
	Local lVerSimul		:= (FwIsInCallStack('F460VerSim') .or. FwIsInCallStack('F460ABlqCan'))
	Local INCLUI		:= oModelLiq:GetOperation() == MODEL_OPERATION_INSERT
	Local lCpCalJur	    := FO0->(ColumnPos("FO0_CALJUR")) > 0 .And. FO2->(ColumnPos("FO2_TXCALC")) > 0 .And. FO2->(ColumnPos("FO2_VLRJUR")) > 0  // Proteção criada para versão 12.1.27

	Default oModelLiq	:= FWLoadModel("FINA460A")

	oFO0 := oModelLiq:GetModel('MASTERFO0')
	oFO1 := oModelLiq:GetModel('TITSELFO1')
	oFO2 := oModelLiq:GetModel('TITGERFO2')

	If FwIsInCallStack("F460AEfet")
		cNLiquid := F460NumLiq()
	ElseIf FwIsInCallStack("A460Liquid") .And. lF460NUM
		cNLiquid := ExecBlock("F460NUM",.F.,.F.,{cNLiquid})
	Else
		cNLiquid := FO0->FO0_NUMLIQ
	Endif
	nMoeda := oFO0:GetValue("FO0_MOEDA")

	oFO0:LoadValue("FO0_NUMLIQ"	, cNLiquid	)

	dbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	dbSelectArea("FK7")
	FK7->(DbSetOrder(1))

	For nX := 1 To oFO1:Length()
		oFO1:Goline(nX)
		If FK7->(MsSeek(xFilial("FK7",oFO1:GetValue("FO1_FILORI"))+ oFO1:GetValue("FO1_IDDOC")))
			cChaveTit:= FinFK7Key(FK7->FK7_CHAVE,"")

			If SE1->(DbSeek((cChaveTit)))
				If lUsaMark .or. lVerSimul
					If lUsaMark
						oFO1:LoadValue("FO1_MARK",  .T.	)
					Endif
					nValorLiq += oFO1:GetValue("FO1_TOTAL")	
				EndIf

				If FwIsInCallStack("F460ABlqCan")
					oFO1:LoadValue("FO1_MARK"	, .T.	        			)
				Endif
				oFO1:LoadValue("FO1_PREFIX"	, SE1->E1_PREFIXO				)
				oFO1:LoadValue("FO1_NUM"	, SE1->E1_NUM					)
				oFO1:LoadValue("FO1_PARCEL"	, SE1->E1_PARCELA				)
				oFO1:LoadValue("FO1_TIPO"	, SE1->E1_TIPO					)
				oFO1:LoadValue("FO1_CLIENT"	, SE1->E1_CLIENTE				)
				oFO1:LoadValue("FO1_LOJA"	, SE1->E1_LOJA					)
				oFO1:LoadValue("FO1_EMIS"	, SE1->E1_EMISSAO				)
				oFO1:LoadValue("FO1_VENCTO"	, SE1->E1_VENCTO				)
				oFO1:LoadValue("FO1_VENCRE"	, SE1->E1_VENCREA				)
				oFO1:LoadValue("FO1_BAIXA"	, SE1->E1_BAIXA					)
				oFO1:LoadValue("FO1_VLBAIX"	, SE1->E1_VALOR - SE1->E1_SALDO	)
				oFO1:LoadValue("FO1_VALCVT"	, Round(NoRound(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoeda,,3),3),2))
				oFO1:LoadValue("FO1_HIST"	, SE1->E1_HIST					)
				oFO1:LoadValue("FO1_NATURE"	, SE1->E1_NATUREZ				)

			Endif
		Endif

	Next nX

	If !INCLUI
		For nX := 1 To oFO2:Length()
			oFO2:Goline(nX)
			nValParc := oFO2:GetValue("FO2_VALOR") + oFO2:GetValue("FO2_VLJUR") + Iif(lCpCalJur,oFO2:GetValue("FO2_VLRJUR"),0)
			oFO2:LoadValue("FO2_VLPARC", nValParc)
			nValTotal := nValParc + oFO2:GetValue("FO2_ACRESC") - oFO2:GetValue("FO2_DECRES")
			nValorNeg += oFO2:GetValue("FO2_TOTAL")
		Next
	Endif	

	oFO0:LoadValue("FO0_VLRLIQ"	, nValorLiq	)
	oFO0:LoadValue("FO0_VLRNEG"	, nValorNeg	)

	RestArea(aArea)

	Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FA460GRV()
Funções para gravação da simulação

@author Pâmela Bernardo
@since 27/10/2015
@version P12.1.8
@param oModel: Modelo Ativo
/*/
//-------------------------------------------------------------------
Function FA460GRV(oModel )

	Local oSubFO0		:= oModel:GetModel("MASTERFO0")
	Local oSubFO1		:= oModel:GetModel("TITSELFO1")
	Local oSubFO2		:= oModel:GetModel("TITGERFO2")
	Local aFO0Fields	:= oModel:GetModel("MASTERFO0"):oFormModelStruct:GetFields()
	Local aFO1Fields	:= oModel:GetModel("TITSELFO1"):oFormModelStruct:GetFields()
	Local aFO2Fields	:= oModel:GetModel("TITGERFO2"):oFormModelStruct:GetFields()
	Local nCampo		:= 0
	Local nDados		:= 0			
	Local aArea		:= GetArea()
	Local cCampo		:= ""
	Local lIntPFS		:= SuperGetMV("MV_JURXFIN",, .F.) //Integração SIGAPFS x SIGAFIN

	//inicia a gravação da FO0
	FO0->(RecLock("FO0",.T.))

	For nCampo := 1 To Len(aFO0Fields) 
		cCampo := aFO0Fields[nCampo][3]
		FO0->&(cCampo) := oSubFO0:GetValue(cCampo)
	Next nX

	FO0->FO0_FILIAL	:= xFilial("FO0")
	If lRecalcula .And. FwIsInCallStack("F460AEfet")	//Efetivação com recalculo, status é gravado como gerado
		FO0->FO0_STATUS := "4"
	EndIf
	FO0->(MsUnLock())

	//Inicia a gravação da FO1
	For nDados := 1 to oSubFO1:Length()
		oSubFO1:GoLine(nDados)
		FO1->(RecLock("FO1" , .T.))

		For nCampo := 1 to Len(aFO1Fields)
			cCampo := aFO1Fields[nCampo][3]
			FO1->&(cCampo) := oSubFO1:GetValue(cCampo)
		Next nCampo

		FO1->FO1_FILIAL := xFilial("FO1")
		FO1->(MsUnlock("FO1"))
	Next nDados

	//Inicia a gravação da FO2
	For nDados := 1 to oSubFO2:Length()
		oSubFO2:GoLine(nDados)
		If !oSubFO2:IsDeleted()
			FO2->(RecLock("FO2" , .T.))

			For nCampo := 1 To Len(aFO2Fields)
				cCampo := aFO2Fields[nCampo][3]
				FO2->&(cCampo) := oSubFO2:GetValue(cCampo)
			Next nCampo

			FO2->FO2_FILIAL := xFilial("FO2")
			FO2->(MsUnlock("FO2"))
		EndIf
	Next nDados

	// Faz a gravação na tabela OHT - Relac. Fatura x Títulos
	If lIntPFS .And. oSubFO0:GetValue("FO0_STATUS") == '4' .And. Chkfile("OHT") .And. FindFunction("JurGrvOHT")
		JurGrvOHT(xFilial("FO0"), oSubFO0:GetValue("FO0_NUMLIQ"), ;
		          oSubFO0:GetValue("FO0_CLIENT"), oSubFO0:GetValue("FO0_LOJA"))
	EndIf

	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} FinxRJur
Funções para gravação da simulação

@author Rodrigo Pirolo
@since 11/11/2015
@version P12.1.8
@param nPerJuros, nDias, nSaldo, nMoeda, dDataRef, dDtVencRea
/*/
//-------------------------------------------------------------------

Function FinxRJur( nPerJuros, nDias, nSaldo, nMoeda, dDataRef, dDtVencRea, nValJur )

	Local cMvJurTipo	:= cJurTipo()	//Forma de calculo de Juros

	Local nSaldoTit		:= 0	//Saldo do titulo
	Local nJuros		:= 0	//Valor de Juros
	Local nAcrescimo	:= 0
	Local nMVFINJRTP	:= SuperGetMv("MV_FINJRTP",,1)
	Local nAtrSimp		:= 0
	Local nDiasAtraso	:= 0
	Local nSaldoC		:= 0

	Local lMV_LJCALJM	:= SuperGetMV("MV_LJCALJM", NIL, .F.)	//Calcula Juros, conforme regra do Financeiro?
	Local lCalcLoj		:= .T.									//Calcula juros conforme o loja
	Local lRegraFin		:= SuperGetMV("MV_LJJUFIN", , .F.)
	Local lAcresVlTit	:= ( FindFunction("Lj950Acres") .AND. Lj950Acres(SM0->M0_CGC)) .OR. (GetRpoRelease("R5") .AND. SuperGetMV("MV_LJICMJR",,.F.) .AND. cPaisLoc == "BRA")   

	Default nPerJuros	:= nTxJuros()
	Default nSaldo		:= 0
	Default nMoeda		:= 0
	Default dDataRef	:= dDataBase
	Default nValJur		:= 0
	

	lCalcLoj := !lRegraFin .OR. cMvJurTipo == "L" //Incluído para calcular regra do loja

	nSaldoTit :=  nSaldo

	If lAcresVlTit
		nSaldoTit += nAcrescimo
	EndIf
	If ( nDias != 0 .AND. !Empty(nPerJuros) )
		If !Empty( nValJur ) .AND. nMVFINJRTP == 1 		//  MV_FINJRTP = 1.Tx Perm
			nJuros := nValJur * nDias
		Else //MV_FINJRTP = 2.Juros ou 3.Ambos
			nTxPer := nPerJuros

			// Calcula os juros compostos caso o parƒmetro seja "C"
			// Calcula os juros simples caso o parametro seja "S"
			// Calcula os juros mistos  caso o parametro seja "M".
			If cMvJurTipo == "M" .OR. cMvJurTipo == "S" .OR. cMvJurTipo == "L"

				//³ Calcula os juros simples
				If ( cMvJurTipo == "M")
					nAtrSimp := If( nDias > 30 , 30 , nDias )
				Else
					nAtrSimp := nDias
				EndIf
				nJuros := nSaldo*(1+(nAtrSimp*(nTxPer/100)))
				nDiasAtraso := nDias
				nDias := Iif(cMvJurTipo == "M", nDias-30, nDias )
			EndIf
			If ( cMvJurTipo=="M" .AND. nDias > 0 ) .OR. cMvJurTipo == "C"

				//Calcula os juros compostos
				If cMvJurTipo == "C" .OR. cMvJurTipo == "L"
					nSaldoC := nSaldo
				Else
					nSaldoC := nJuros
				EndIf
				nJuros := nSaldoC *( (1+( nTxPer/100 ) ) ** nDias )
			EndIf

			nJuros := nJuros - nSaldo

			If nMVFINJRTP == 3 .and. !Empty( nValJur )  // MV_FINJRTP = 3.Ambos
				nJuros := nJuros + (nValJur * nDiasAtraso)
			EndIf

			//Integração TIN x PROTHEUS
			If AllTrim(SE1->E1_ORIGEM) == "FINI055"
				nJuros := (nSaldo*(1+(nAtrSimp*(nValJur/100)))) - nSaldo
				nMulta := (nPerJuros/100) * nSaldo
			Endif
		EndIf
	EndIf

	If lCalcLoj .OR. cMvJurTipo == "L"

		If dDtVencRea > dDataRef .OR. lMV_LJCALJM

			nJuros	:= NoRound(( ( nSaldoTit * ( nPerJuros * nDias ) ) / 100 ), 2)

		EndIf

	EndIf

Return nJuros

//-------------------------------------------------------------------
/*/{Protheus.doc} Fa460Repl
Grava registros no arquivo temporario

Observacao
Migrada do fonte FINA460

@author Mauricio Pequim Jr
@since 20/02/97
@version P12.1.8
@param nPerJuros, nDias, nSaldo, nMoeda, dDataRef, dDtVencRea
/*/
//-------------------------------------------------------------------

Function Fa460Repl(cAliasSE1, cAliasTMP)

	Local nAbat		:= 0
	Local nJuros	:= 0
	Local nDescon	:= 0
	Local nValBxd	:= 0
	Local lF460DES	:= ExistBlock("F460DES")
	Local lF460JUR	:= ExistBlock("F460JUR")
	Local nMulta	:= 0
	Local cMvJurTipo:= cJurTipo()  // calculo de Multa do Loja , se JURTIPO == L
	Local lMulLoj	:= SuperGetMv("MV_LJINTFS", ,.F.) //Calcula multa conforme regra do loja, se integração com financial estiver habilitada
	Local nPerMulta	:= SuperGetMv("MV_LJMULTA", ,0)
	Local nPerJuros	:= SuperGetMv("MV_TXPER", ,0)
	Local lConverte	:= .F.
	Local nTotal	:= 0
	Local nVlJur	:= 0
	Local nVlMul	:= 0
	Local nTxMoeda	:= 0
	Local nSdAcres	:= 0
	Local nSdDecre	:= 0
	Local nVA		:= 0
	Local l460load 	:= ExistBlock("FA460LD")
	Local cChave	:= ""
	Local nLjJuros	:= nTxJuros()
	//639.04 Base Impostos diferenciada
	Local lBaseImp	:= F040BSIMP(2)
	Local nTotAbImp	:= 0
	Local cNatImpPcc:= ""
	Local lAbateIss := .F.
	Local aAreaSE1 	:= {}

	//Gestao
	Local cFilAtu	:= cFilAnt
	Local cNomeFil	:= ""
	Local cFilTit	:= ""
	
	DEFAULT cAliasSE1	:= "SE1"

	If l460Load
		cChave	:= ExecBlock("FA460LD",.F.,.F.,{"SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO"})	
	EndIf

	dbSelectArea(cAliasSE1)

	dbGotop()

	While !(cAliasSE1)->(Eof())
		//------------------------------------------------------------------------------
		// Posiciono no SE1 original para uso das rotinas de calculo de juros, 
		// abatimento e desconto. Principalmente por conta de FA070JUROS() e   
		// FA070DESCF() se utilizarem do SE1 para os calculos.                 
		//------------------------------------------------------------------------------
		dbSelectArea("SE1")

		If !lOpcAuto .OR. lAutoQuery
			SE1->(DbGoTo((cAliasSE1)->RECNO))
		EndIf

		If cFilTit != SE1->E1_FILORIG
			cNomeFil := FWFilialName(,SE1->E1_FILORIG)
			cFilTit  := SE1->E1_FILORIG
			cFilAnt := cFilTit
		Endif

		If SE1->E1_MOEDA <> nMoeda// Precisa converter os valores dos titulos
			lConverte	:= .T.

			If Empty(SE1->E1_TXMOEDA)
				nTxMoeda := RecMoeda(dDataBase, SE1->E1_MOEDA)
			Else
				nTxMoeda := SE1->E1_TXMOEDA
			EndIf
		EndIf

		//------------------------------------------------------------------------------
		// Mexico - Manejo de Anticipo                              
		// Validacao para nao selecionar os titulos das notas de adiantamento e 
		// os titulos do tipo RA gerados pela rotina recebimentos diversos.                            
		//------------------------------------------------------------------------------
		If cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT") .And.;
		Upper(Alltrim(SE1->E1_ORIGEM)) $ "FINA087A|MATA467N" .And. GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+SE1->E1_NATUREZ,1,"") == "1"
			(cAliasSE1)->(dbSkip())
			Loop
		EndIf

		SA1->(dbSetOrder(1))
		SA1->(MsSeek(xFilial("SA1")+SE1->(E1_CLIENTE+E1_LOJA)))

		lAbateIss	:= (SA1->A1_RECISS == "1" .And. GetNewPar("MV_DESCISS",.F.))

		nTotAbImp	:= 0
		aAreaSE1	:= SE1->(GetArea())
		nAbat		:= SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"S",dDatabase,@nTotAbImp)
		SE1->(RestArea(aAreaSE1))
		//Impostos PCC com calculo para o Cliente/Natureza
		cNatImpPcc	:= F460NatImp()

		//639.04 Base Impostos diferenciada
		If lBaseImp .and. !Empty(cNatImpPcc)
			nAbat	 -= nTotAbImp
		EndIf

		If lF460JUR
			nJuros := ExecBlock("F460JUR",.F.,.F.)
		Else
			nPerJuros := SE1->E1_PORCJUR
			//Somente irá considerar o parâmetro MV_LJJUROS, se o E1_PORCJUR não estiver preenchido.
			If nPerJuros = 0  
				If cMvJurTipo == "L"
					nPerJuros := nLjJuros
				Endif
			EndIf
			nJuros := FA070JUROS(SE1->E1_MOEDA,SE1->E1_SALDO)
		Endif
		If lF460DES
			nDescon := ExecBlock("F460DES",.F.,.F.)
		Else
			nDescon := FaDescFin("SE1",dDataBase,SE1->E1_VALOR,SE1->E1_MOEDA)
		Endif
		If cMvJurTipo == "L" .Or. lMulLoj
			//*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//*³ Calcula o valor da Multa  :funcao LojxRMul :fonte Lojxrec          ³
			//*ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nMulta := LojxRMul(,,,SE1->E1_SALDO,SE1->E1_ACRESC,SE1->E1_VENCREA,dDataBase,,SE1->E1_MULTA,,SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,"SE1",.T.)
		EndIf
		//Valores acessórios		
		nVa := FValAcess(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_NATUREZ, Iif(Empty(SE1->E1_BAIXA),.F.,.T.),"","R",dDataBase,,SE1->E1_MOEDA,nMoeda,SE1->E1_TXMOEDA)
		
		nValBxd := SE1->E1_VALOR - SE1->E1_SALDO

		RecLock(cAliasTMP, .T.)
		Replace FO1_FILORI	With cFilant//cNomeFil
		Replace	FO1_PREFIX	With SE1->E1_PREFIXO
		Replace	FO1_NUM	    With SE1->E1_NUM
		Replace	FO1_PARCEL	With SE1->E1_PARCELA
		Replace	FO1_TIPO	With SE1->E1_TIPO
		Replace	FO1_NATURE	With SE1->E1_NATUREZ
		Replace	FO1_CLIENT	With SE1->E1_CLIENTE
		Replace	FO1_LOJA	With SE1->E1_LOJA
		Replace	FO1_EMIS	With SE1->E1_EMISSAO
		Replace	FO1_VENCTO	With SE1->E1_VENCTO
		Replace	FO1_VENCRE	With SE1->E1_VENCREA
		Replace	FO1_BAIXA	With SE1->E1_BAIXA
		Replace	FO1_SALDO	With SE1->E1_SALDO
		
		Replace	FO1_CCUST	With SE1->E1_CCUSTO
		Replace	FO1_ITEMCT	With SE1->E1_ITEMCTA
		Replace	FO1_CLVL	With SE1->E1_CLVL
		Replace	FO1_CREDIT	With SE1->E1_CREDIT
		Replace	FO1_DEBITO	With SE1->E1_DEBITO
		Replace	FO1_CCC		With SE1->E1_CCC
		Replace	FO1_CCD		With SE1->E1_CCD
		Replace	FO1_ITEMC	With SE1->E1_ITEMC
		Replace	FO1_ITEMD	With SE1->E1_ITEMD
		Replace	FO1_CLVLCR	With SE1->E1_CLVLCR
		Replace	FO1_CLVLDB	With SE1->E1_CLVLDB

		If lConverte
			Replace	FO1_VLDIA	With Round(NoRound(xMoeda(SE1->E1_VALJUR, SE1->E1_MOEDA, nMoeda, dDataBase, 2, nTxMoeda), 3), 2)

			nVlJur	:= Round(NoRound(xMoeda(nJuros, SE1->E1_MOEDA, nMoeda, dDataBase, 2, nTxMoeda), 3), 2)
			Replace	FO1_VLJUR	With nVlJur
			Replace FO1_TXJUR	With nPerJuros

			If SE1->E1_VENCREA < dDataBase .AND. cMvJurTipo == "L"

				nVlMul	:= Round(NoRound(xMoeda(nMulta, SE1->E1_MOEDA, nMoeda, dDataBase, 3,nTxMoeda), 3), 2)			

				Replace	FO1_TXMUL	With nPerMulta
				Replace	FO1_VLMUL	With nVlMul
			EndIf

			nDescon	:= Round(NoRound(xMoeda(nDescon,SE1->E1_MOEDA,nMoeda, dDataBase, 3, nTxMoeda),3),2)
			Replace	FO1_DESCON	With nDescon

			nAbat	:= Round(NoRound(xMoeda(nAbat,SE1->E1_MOEDA,nMoeda, dDataBase, 3, nTxMoeda),3),2)
			Replace	FO1_VLABT	With nAbat

			nValBxd	:= Round(NoRound(xMoeda(nValBxd, SE1->E1_MOEDA, nMoeda, dDataBase, 3, nTxMoeda),3),2)
			Replace	FO1_VLBAIX	With nValBxd

			Replace	FO1_VACESS	With nVa

			Replace FO1_MOEDA  	With SE1->E1_MOEDA
			Replace FO1_TXMOED 	With If( Empty(SE1->E1_TXMOEDA), RecMoeda(dDataBase, SE1->E1_MOEDA), SE1->E1_TXMOEDA)
			Replace FO1_VALCVT	With Round(NoRound(xMoeda(SE1->E1_SALDO, SE1->E1_MOEDA, nMoeda, dDataBase, 3, nTxMoeda), 3), 2)			
		
			nTotal	:= Round(NoRound(xMoeda(SE1->E1_VALOR+SE1->E1_SDACRES-SE1->E1_SDDECRE, SE1->E1_MOEDA, nMoeda, dDataBase, 2, nTxMoeda), 3), 2)
			nTotal  += (nMulta + nJuros + nVa -nAbat - nDescon - nValBxd) //Já convertidos para a moeda do processo
			Replace	FO1_TOTAL	With nTotal

			nSdAcres := Round(NoRound(xMoeda( SE1->E1_SDACRES,SE1->E1_MOEDA,nMoeda, dDataBase,3,nTxMoeda),3),2)
			Replace	FO1_ACRESC	With nSdAcres

			nSdDecre := Round(NoRound(xMoeda(SE1->E1_SDDECRE,SE1->E1_MOEDA,nMoeda, dDataBase, 3, nTxMoeda),3),2)
			Replace	FO1_DECRES	With nSdDecre

		Else

			Replace FO1_VALCVT	With SE1->E1_SALDO
			Replace	FO1_TOTAL	With SE1->E1_VALOR - nAbat - nValBxd - nDescon + nMulta + nJuros + SE1->E1_SDACRES - SE1->E1_SDDECRE + nVA
			Replace	FO1_VLDIA	With SE1->E1_VALJUR
			Replace	FO1_VLJUR	With nJuros
			Replace FO1_TXJUR   With nPerJuros

			If SE1->E1_VENCREA < dDataBase .AND. cMvJurTipo == "L"
				Replace	FO1_TXMUL	With nPerMulta
				Replace	FO1_VLMUL	With nMulta
			EndIf

			Replace	FO1_DESCON	With nDescon
			Replace	FO1_VLABT	With nAbat
			Replace	FO1_VLBAIX	With nValBxd
			Replace FO1_MOEDA  	With SE1->E1_MOEDA
			Replace FO1_TXMOED 	With If( Empty(SE1->E1_TXMOEDA), RecMoeda(dDataBase, SE1->E1_MOEDA), SE1->E1_TXMOEDA)
			Replace	FO1_ACRESC	With SE1->E1_SDACRES
			Replace	FO1_DECRES	With SE1->E1_SDDECRE
			Replace	FO1_VACESS	With nVA
		EndIf

		Replace	FO1_HIST With SE1->E1_HIST
		If l460load
			Replace	CHAVE With  &(cChave)
		Else
			Replace	CHAVE With SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO 
		EndIf
		Replace	CHAVE2 With SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO
		Replace	TITPAI With SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA

		//639.04 Base Impostos diferenciada
		If lBaseImp

			Replace OUTRIMP	With	If (nTotAbImp > 0, SE1->(E1_IRRF+E1_INSS)+(If(lAbateIss,SE1->E1_ISS,0)), 0)			

			If SE1->(E1_PIS+E1_CSLL+E1_COFINS) > 0
				Replace BASEIMP	With If (SE1->E1_BASEPIS > 0 , 	SE1->E1_BASEPIS, SE1->E1_VALOR )
				Replace PIS		With If (nTotAbImp > 0, SE1->E1_PIS, 0)
				Replace COFINS	With If (nTotAbImp > 0, SE1->E1_COFINS, 0)
				Replace CSLL	With If (nTotAbImp > 0, SE1->E1_CSLL, 0)
			Endif
		Endif

		(cAliasTMP)->(MsUnlock())	
			
		(cAliasSE1)->(dbSkip())
	endDo

	cFilAnt  := cFilAtu

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} FA460DBEVA
Trata o dbeval para marcar e desmarcar item

Observacao
Migrada do fonte FINA460

@author Mauricio Pequim Jr
@since 18/12/00
@version P12.1.8
@param cAliasFO1, nValorMax, nQtdTit
/*/
//-------------------------------------------------------------------
Static Function Fa460DbEva(cAliasFO1, nValorMax, nQtdTit)

	If (cAliasFO1)->(MsRLock()) // Se conseguir travar o registro
		If nValor < nValorMax .And. ((cAliasFO1)->FO1_TOTAL+nValor) <= nValorMax
			nValor += (cAliasFO1)->FO1_TOTAL
			(cAliasFO1)->FO1_MARK := .T.
			nQtdTit++
		Else
			(cAliasFO1)->FO1_MARK := .F.
		EndIf
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} F460NumLiq
Controla numeração da Liquidação

@author Mauricio Pequim Jr
@since 06/07/2016
@version P12.1.8

/*/
//-------------------------------------------------------------------
Function F460NumLiq()

	Local cLiquid 		as character
	local lFO0Exist 	as logical
	local cFil 			as character
	local nTamNumLiq 	as numeric

	cLiquid		:= ""
	lFO0Exist 	:= .T.
	cFil		:= ""	
	nTamNumLiq 	:= F460TamLiq()

	If lF460NUM == NIL
		lF460NUM := ExistBlock("F460NUM")
	Endif

	//Ponto de Entrada para tratamento do usuário
	If lF460NUM
		cLiquid := ExecBlock("F460NUM",.F.,.F.,{cLiquid})
	Else
		//Trata numero da liquidacao
		cLiquid := AllTrim(GetMv("MV_NUMLIQ",,.T.))
		cLiquid := Replicate("0", nTamNumLiq - Len(cLiquid)) + cLiquid
		cLiquid := left(cLiquid, nTamNumLiq)
		cLiquid := Soma1(cLiquid)
		
		cFil := SX6->X6_FIL

		//Verifica se o número já existe na FO0
		if __oStNumLi = NIL
			cQuery := "SELECT FO0_NUMLIQ "
			cQuery += "FROM "+ retSQLName("FO0") +" FO0 "
			cQuery += "WHERE FO0_NUMLIQ = ? "
			if allTrim(cFil) != ""
				cQuery += "AND FO0_FILIAL = ?
			endIf
			cQuery += "AND D_E_L_E_T_ = ' ' "
			__oStNumLi := FWPreparedStatement():New(cQuery)			
		endIf		
		while lFO0Exist
			__oStNumLi:setString(1, cLiquid)
			if allTrim(cFil) != ""
				__oStNumLi:setString(2, cFil)
			endIf
			lFO0Exist := !Empty(MpSysExecScalar(__oStNumLi:GetFixQuery(),"FO0_NUMLIQ"))
			if lFO0Exist				
				cLiquid := Soma1(cLiquid) // busca o próximo número disponível
			endIf
		endDo

		//verifica se esta na memoria, sendo usado e se o número é válido
		While !MayIUseCode("SE1" + cFil + cLiquid)
			cLiquid := Soma1(cLiquid) // busca o proximo numero disponivel
		EndDo				
	Endif

Return cLiquid	


//--------------------------------------------------------------------------------
/*/{Protheus.doc} F460TamLiq
Retorna o tamanHo do campo E1_NUMLIQ
@author Mauricio Pequim Jr
@since  06/07/2016
@version P12
/*/
//--------------------------------------------------------------------------------	
Function F460TamLiq()

	If nTamLiq == 0
		nTamLiq 	:= TamSx3('E1_NUMLIQ')[1]
	Endif

Return nTamLiq 


//--------------------------------------------------------------------------------
/*/{Protheus.doc} FINIDPROC
Função para definir o ID usando GETSXENUM
@author Mauricio Pequim Jr
@since  06/07/2016
@version P12
/*/
//--------------------------------------------------------------------------------
Function FINIDPROC(cAliasFO0, cCampo, cVersao)
	Local cIdFO0	:= ""
	Local aArea	:= GetArea()

	DbSelectArea(cAliasFO0)
	DbSetOrder(1)

	While .T.
		cIdFO0 := GetSxENum(cAliasFO0, cCampo )
		ConfirmSX8()
		If !(Dbseek(xFilial(cAliasFO0) + cIdFO0 + cVersao))
			Exit 
		Endif
	Enddo

	RestArea(aArea)

Return cIdFO0

//-------------------------------------------------------------------
/*/ {Protheus.doc} F460MRKNEW
Função validar/marcar todos os titulos

@author Francisco Oliveira
@since 10/07/2019
@version 1.0

@return 
/*/
//-------------------------------------------------------------------

Function F460MRKNEW(oView, oModel, nAcao, __lNExbMsg)

Local nX	    AS Numeric	
Local nCond		AS Numeric
Local lMarca   	AS Logical
Local lRet		AS Logical
Local lLockTab	AS Logical
Local aParcelas AS Array
Local aAreaSE1	AS Array
Local cQuery	AS Character
Local cNumLiq	AS Character
Local cTMPNum	AS Character
Local cPrefix	AS Character
Local cParc2Ger	AS Character
Local oModel   	AS Object
Local oView    	AS Object
Local oSubFO0	AS Object
Local oSubFO1	AS Object
Local oSubFO2	AS Object
Local nTamParc	AS Numeric
Local nTamNum	AS Numeric
Local FO1VLJUR	AS Numeric
Local FO1VLMUL	AS Numeric
Local FO1DESCON	AS Numeric
Local FO1DECRES	AS Numeric
Local FO1VLABT	AS Numeric
Local FO1DESJUR	AS Numeric
Local FO1VACESS	AS Numeric
Local FO1VLBAIX AS Numeric
Local FO1VLTOTA	AS Numeric
Local nQtdTit   AS Numeric
Local nQtdFil   AS Numeric
Local lUltTit	AS Logical
Local aFilFO1   AS Array
Local VldCmc7 	As Logical
Local lCpoCalJur AS Logical
Local lFini055	 AS Logical
Local lSldBxCr	 AS Logical
Local cE1Chv	 As Character
Local lErroChqCr As Logical
Local lSitCobPix As Logical
Local bEValPix   As Block
Local cChaveTit  As Character
Local cIdDocFK7  As Character
Local lRetorno   As Logical
Local lFirst     As Logical
Local lTemImpPix As Logical

//Inicializa variáveis
nX	    	:= 0
nCond		:= 0
lMarca   	:= .F.
lRet		:= .T.
lLockTab	:= .F.
aParcelas	:= {}
aAreaSE1	:= SE1->(GetArea())
cQuery		:= ""
cNumLiq		:= ""
cTMPNum		:= ""
cPrefix		:= ""
cParc2Ger	:= Alltrim(SuperGetMv("MV_1DUP"))
oModel   	:= FWModelActive()
oView    	:= FwViewActive()
oSubFO0		:= oModel:GetModel("MASTERFO0")
oSubFO1		:= oModel:GetModel("TITSELFO1")
oSubFO2		:= oModel:GetModel("TITGERFO2")
nTamParc	:= TamSx3("E1_PARCELA")[1]
nTamNum		:= TamSx3("E1_NUM")[1]
FO1VLJUR	:= 0
FO1VLMUL	:= 0
FO1DESCON	:= 0
FO1DECRES	:= 0
FO1VLABT	:= 0
FO1DESJUR	:= 0
FO1VACESS	:= 0
FO1VLBAIX 	:= 0
FO1VLTOTA	:= 0
nQtdTit   	:= 0
nQtdFil   	:= 0
lUltTit		:= .F.
aFilFO1   	:= oView:GetViewObj("VIEW_FO1")[3]:GetFilLines() 
lCpoCalJur	:= FO0->(ColumnPos("FO0_CALJUR")) > 0  // Proteção criada para versão 12.1.27
VldCmc7 	:= Iif(Type("lCmc7") == "L", lCmc7, .F.)
nQtdTit		:= oSubFO1:Length()
nQtdFil		:= Len(aFilFO1)
lFini055	:= IsInCallStack("FINI055")
lSldBxCr	:= (SuperGetMv('MV_SLDBXCR',.F.,'B') == 'C') .And. FindFunction('TemChqCr')
cE1Chv		:= ""
lErroChqCr	:= .F. // Indica que existe título com cheque vinculado
lSitCobPix	:= .F.	
bEValPix	:= {||TtBxImpPix(SE1->(Recno()))}			  
cChaveTit	:= ""
cIdDocFK7	:= ""
lRetorno 	:= .T.
lFirst		:= .T.
lTemImpPix  := .F.

Default __lNExbMsg  := .F.

If __lExcImpo == Nil
	__lExcImpo := FindFunction("ExcluiImpo")
EndIf

If __lCnabImp == Nil 
	__lCnabImp := SuperGetMV("MV_CNABIMP", .F., .F.)
EndIf

ProcRegua(nQtdTit)

For nX:=1 To nQtdTit
	lRet := .T.
	lLockTab := .F.
	IncProc(STR0270 + Alltrim(Str(nX))) //"Selecionando o Título: "

	oSubFO1:GoLine(nX)
	lMarca := oSubFO1:GetValue("FO1_MARK")

	//Verificação para marcação
	If !lMarca .And. nAcao == 1 .And. lRet
		//Verifica se existe cheque para o título aguardando compensação
		If SE1->(DbSeek(xFilial("SE1",oSubFO1:GetValue("FO1_FILORI")) + oSubFO1:GetValue("FO1_PREFIX") + oSubFO1:GetValue("FO1_NUM") + oSubFO1:GetValue("FO1_PARCEL") + oSubFO1:GetValue("FO1_TIPO")))
			If !SE1->( SimpleLock()) .Or. !Empty(SE1->E1_TIPOLIQ)
				lRet := .F.
				lLockTab := .T.
			Endif
		Endif
		
		If lSldBxCr
			If TemChqCr(xFilial("SE1",oSubFO1:GetValue("FO1_FILORI")), oSubFO1:GetValue("FO1_PREFIX"), oSubFO1:GetValue("FO1_NUM"), oSubFO1:GetValue("FO1_PARCEL"), oSubFO1:GetValue("FO1_TIPO"))
				lRet := .F.
				lErroChqCr := .T.
			EndIf
		EndIf
		
		If __lExcImpo .And. !__lCnabImp 
			lTemImpPix := BorderoImp(SE1->E1_FILORIG, SE1->E1_NUMBOR, "R", SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA)
			
			If !lTemImpPix 
				lTemImpPix := HistPagPix(SE1->E1_FILORIG, SE1->(E1_FILIAL+"|"+E1_PREFIXO+"|"+E1_NUM+"|"+E1_PARCELA+"|"+E1_TIPO+"|"+E1_CLIENTE+"|"+E1_LOJA), @__oPagPix)
				
				If !lTemImpPix
					lSitCobPix := IIf(!lSitCobPix, Eval(bEvalPix), lSitCobPix)
					
					If lSitCobPix
						If lFirst .Or. (!lRetorno .Or. (!__lNExbMsg .And. lRetorno))  
							lRetorno := MsgTtBxPix(.F.,.T.,.T.,@__lNExbMsg)						
							lFirst   := .F.		
						EndIf
						
						If !lRetorno								
							oSubFO1:LoadValue("FO1_MARK",.F.) 
							
							lRet := .F.
							
							If !lOpcAuto
								oView:Refresh()
							EndIf
						ElseIf lRetorno .And. ExcluiImpo(SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, Nil)
							cIdDocFK7 := FinBuscaFK7(SE1->E1_FILIAL+"|"+SE1->E1_PREFIXO+"|"+SE1->E1_NUM+"|"+SE1->E1_PARCELA+"|"+SE1->E1_TIPO+"|"+SE1->E1_CLIENTE+"|"+SE1->E1_LOJA, "SE1", SE1->E1_FILORIG)
							PIXCancel(SE1->E1_FILIAL, cIdDocFK7)
							F460AtuMod( nMoeda )				
						EndIf
						
						lSitCobPix	:= .F.		
					EndIf
				EndIf
			EndIf		
		EndIf
		
		If oSubFO0:GetValue("FO0_TXMUL") > 0 .And. oSubFO1:GetValue("FO1_VENCTO") < dDataBase
			oSubFO1:LoadValue("FO1_TXMUL", oSubFO0:GetValue("FO0_TXMUL") )
			oSubFO1:LoadValue("FO1_VLMUL", Round(NoRound(xMoeda(oSubFO1:GetValue("FO1_SALDO"),oSubFO1:GetValue("FO1_MOEDA"),nMoeda,dDataBase,3,oSubFO1:GetValue("FO1_TXMOED")) * (oSubFO1:GetValue("FO1_TXMUL")/100) ,3),2) )
			FO1VLJUR += oSubFO1:GetValue("FO1_VLMUL")
		Endif
		
		//Atualizar o valor de bolsa para integração RM Educacional
		If !lFini055 .and. cFilMsg == "1"
			cE1Chv := xFilial("SE1",oSubFO1:GetValue("FO1_FILORI"))+oSubFO1:GetValue("FO1_PREFIX")+oSubFO1:GetValue("FO1_NUM")+oSubFO1:GetValue("FO1_PARCEL")+oSubFO1:GetValue("FO1_TIPO")
			
			SE1->(DbSetOrder(1))
			SE1->(MsSeek(cE1Chv))
			
			If !FA070Integ(.F.)
				lRet := .F.
			Else
				oSubFO1:LoadValue("FO1_DESCON", SE1->E1_VLBOLSA )
				oSubFO1:LoadValue("FO1_TOTAL", oSubFO1:GetValue("FO1_SALDO") - oSubFO1:GetValue("FO1_DESCON") + oSubFO1:GetValue("FO1_VLJUR") + oSubFO1:GetValue("FO1_VLMUL") + oSubFO1:GetValue("FO1_VACESS"))			 		 
			EndIf
		Endif

	EndIf
	
	If nAcao == 1 .And. lRet
		lMarca := .T.
		lUltTit := nX == aFilFO1[nQtdFil]
		If aScan(aFilFO1,nX) > 0
			oSubFO1:GoLine(nX) 
			oSubFO1:LoadValue("FO1_MARK",lMarca) 
			FO1VLJUR	+= (oSubFO1:GetValue("FO1_VLJUR"))
			FO1VLMUL	+= (oSubFO1:GetValue("FO1_VLMUL"))
			FO1DESCON	+= (oSubFO1:GetValue("FO1_DESCON"))
			FO1DECRES	+= (oSubFO1:GetValue("FO1_DECRES"))
			FO1VLABT	+= (oSubFO1:GetValue("FO1_VLABT"))
			FO1DESJUR	+= (oSubFO1:GetValue("FO1_DESJUR"))
			FO1VACESS	+= (oSubFO1:GetValue("FO1_VACESS"))
			FO1VLBAIX	+= (oSubFO1:GetValue("FO1_TOTAL"))
			FO1VLTOTA	+= (oSubFO1:GetValue("FO1_SALDO"))

		EndIf
	ElseIf nAcao == 2
		If SE1->(DbSeek(xFilial("SE1",oSubFO1:GetValue("FO1_FILORI")) + oSubFO1:GetValue("FO1_PREFIX") + oSubFO1:GetValue("FO1_NUM") + oSubFO1:GetValue("FO1_PARCEL") + oSubFO1:GetValue("FO1_TIPO")))
			If SE1->( SimpleLock())
				SE1->(MsUnlock())
			Endif
		Endif
		lMarca := .F.
		lUltTit := nX == aFilFO1[nQtdFil]
		oSubFO1:GoLine(nX) 
		oSubFO1:LoadValue("FO1_MARK",lMarca) 
	Endif		
Next nX

If nAcao == 1 .And. FO1VLBAIX > 0 .And. lRet
	oSubFO0:LoadValue("FO0_VLRLIQ", FO1VLTOTA)
	If !VldCmc7
		oSubFO0:LoadValue("FO0_VLRNEG", FO1VLBAIX)
	EndIf
	oSubFO0:LoadValue("FO0_VLRJUR", FO1VLJUR )
	oSubFO0:LoadValue("FO0_TTLTIT", StrZero(nQtdFil,4))

	If !VldCmc7
		If Empty(MV_PAR08)
			cPrefix	:= oSubFO2:GetValue("FO2_PREFIX")
		Else
			cPrefix	:= Upper(MV_PAR08)
		Endif

		cQuery := " SELECT MAX(E1_NUM) AS NUMMAX " 										+ CRLF
		cQuery += " FROM " + RetSqlName("SE1") + " SE1 "								+ CRLF
		cQuery += " WHERE " 															+ CRLF
		cQuery += " SE1.E1_FILIAL 	= '" + xFilial("SE1") 					+ "' AND " 	+ CRLF
		cQuery += " SE1.E1_TIPO 	= '" + oSubFO0:GetValue("FO0_TIPO")     + "' AND "	+ CRLF
		cQuery += " SE1.E1_PREFIXO 	= '" + cPrefix							+ "' AND " 	+ CRLF
		cQuery += " SE1.D_E_L_E_T_	= ''                     " 							+ CRLF

		cQuery 	:= ChangeQuery(cQuery)
		cTMPNum	:= GetNextAlias()
		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTMPNum, .F., .T.)
			
		cNumLiq	:= Alltrim((cTMPNum)->NUMMAX)

		(cTMPNum)->(dbCloseArea())

		SE4->( dbSetOrder( 1 ) )
		If SE4->( DbSeek( xFilial("SE4") + oSubFO0:GetValue("FO0_COND")  ) )
			If SE4->E4_TIPO $ "A|9"
				oSubFO0:LoadValue("FO0_COND",Space(3))
				Help(" ",1,"FA460PAGTO",,STR0186, 1, 0)	// As condicoes de pagamento do tipo A são exclusivas dos modulos SIGAVEI e SIGAOFI.
				If !lOpcAuto
					oView:Refresh()
				EndIf
				lRet:= .F.
			Else
				aParcelas := Condicao( FO1VLBAIX, oSubFO0:GetValue("FO0_COND"), , dDataBase )
			Endif
		Else		
			aParcelas := {{dDataBase,FO1VLBAIX}}
		EndIf

		If !Empty(cNumLiq)
			cNumLiq	:= SOMA1(Alltrim(cNumLiq))
		Else
			cNumLiq := StrZero(1,nTamNum)
		Endif

		oSubFO2:ClearData( .T. )

		For nCond := 1 To Len(aParcelas)

			If nCond > 1
				oSubFO2:AddLine()
				oSubFO2:GoLine(nCond)
			Endif
			
			cParc2Ger := cParc2Ger + Space(nTamParc - Len(cParc2Ger))	

			oSubFO2:LoadValue("FO2_PREFIX", Alltrim(cPrefix))
			oSubFO2:LoadValue("FO2_NUM"   , Alltrim(cNumLiq))
			oSubFO2:LoadValue("FO2_PARCEL", cParc2Ger)
			oSubFO2:LoadValue("FO2_TIPO"  , Alltrim(oSubFO0:GetValue("FO0_TIPO")))
			oSubFO2:LoadValue("FO2_VENCTO", aParcelas[nCond,1])	          
			oSubFO2:LoadValue("FO2_VALOR" , aParcelas[nCond,2])
			oSubFO2:LoadValue("FO2_TXJUR" , oSubFO0:GetValue("FO0_TXJRG"))
			oSubFO2:LoadValue("FO2_VLPARC", aParcelas[nCond,2])
			oSubFO2:LoadValue("FO2_TOTAL" , aParcelas[nCond,2])
			oSubFO2:LoadValue("FO2_IDSIM" , FWUUIDV4() )
			oSubFO2:LoadValue("FO2_PROCES", oSubFO0:GetValue("FO0_PROCES"))
			oSubFO2:LoadValue("FO2_VERSAO", oSubFO0:GetValue("FO0_VERSAO"))

			If oSubFO0:GetValue("FO0_TXMUL") > 0 .And. oSubFO1:GetValue("FO1_VENCTO") < dDataBase
				oSubFO1:LoadValue("FO1_TXMUL", oSubFO0:GetValue("FO0_TXMUL") )
				oSubFO1:LoadValue("FO1_VLMUL", Round(NoRound(oSubFO1:GetValue("FO1_SALDO") * (oSubFO1:GetValue("FO1_TXMUL")/100) ,3),2) )
			Endif

			if __lF460PGE == NIL
				__lF460PGE := Existblock("F460PGE")
			endIf
			If __lF460PGE
				Execblock("F460PGE",.F.,.F.,{oSubFO0,oSubFO1,oSubFO2})
			EndIf

			cParc2Ger := Soma1(alltrim(cParc2Ger))

		Next nCond

		If lCpoCalJur
			If oSubFO0:GetValue("FO0_CALJUR") > 0
				F460CalJur(oModel,oView,0)
			Endif
		Endif

	Endif
ElseIf nAcao == 2
	If !VldCmc7
		oSubFO2:ClearData( .T. )
	Endif
	oSubFO0:LoadValue("FO0_VLRLIQ", 0)
	oSubFO0:LoadValue("FO0_VLRNEG", 0)
	oSubFO0:LoadValue("FO0_VLRJUR", 0)
	oSubFO0:LoadValue("FO0_TTLTIT", StrZero(0,4))
Endif

If lErroChqCr
	Help(" ",1,"F460MARKCH",,STR0275, 1, 0)//'Títulos com cheques aguardando compensações não serão selecionados!'
EndIf

If lLockTab
	Help(" ",1,"F460MARCA",,STR0239, 1, 0) 
Endif

oSubFO1:GoLine(1)
oSubFO2:GoLine(1)
oView:Refresh() 

RestArea(aAreaSE1)

If __oPagPix != Nil
	__oPagPix:Destroy()
	__oPagPix := Nil
EndIf
Return

//-------------------------------------------------------------------
/*/ {Protheus.doc} F460CalJur
Função calcula os juros futuro, com resultado na tabela FO2

@author Francisco Oliveira
@since 15/11/2019
@version 1.0

@return 
/*/
//-------------------------------------------------------------------

Function F460CalJur(oModel,oView,nAcJur)

Local nX	    AS Numeric	
Local oModel   	AS Object
Local oView    	AS Object
Local oSubFO0	AS Object
Local oSubFO1	AS Object
Local oSubFO2	AS Object
Local nValJur	AS Numeric
Local nTxMoeda	AS Numeric
Local nMoedaFO0 AS Numeric
Local nPosFO2	AS Numeric
Local nJurFO2	AS Numeric
Local nTxJurFO2 AS Numeric
Local lVlrCalc	AS Logical
Local lCpCalJur AS Logical

Default nAcJur	:= 0

nX	    	:= 0
oModel   	:= FWModelActive()
oView    	:= FwViewActive()
oSubFO0		:= oModel:GetModel("MASTERFO0")
oSubFO1		:= oModel:GetModel("TITSELFO1")
oSubFO2		:= oModel:GetModel("TITGERFO2")
nValJur		:= 0
nMoedaFO0	:= oSubFO0:GetValue("FO0_MOEDA")
lCpCalJur	:= FO0->(ColumnPos("FO0_CALJUR")) > 0 .And. FO2->(ColumnPos("FO2_TXCALC")) > 0 .And. FO2->(ColumnPos("FO2_VLRJUR")) > 0  // Proteção criada para versão 12.1.27
nPosFO2		:= oSubFO2:GetLine()
nTxMoeda	:= RecMoeda(dDataBase, nMoedaFO0 )
nJurFO2		:= 0
nTxJurFO2	:= 0

If !lCpCalJur
	Return
Endif

lVlrCalc	:= oSubFO0:GetValue("FO0_CALJUR") > 0

If !lVlrCalc .And. nAcJur = 0
	For nX := 1 To oSubFO2:Length()
		oSubFO2:Goline(nX)
		oSubFO2:LoadValue("FO2_TXCALC", 0 )
		oSubFO2:LoadValue("FO2_VLRJUR", 0 )

		nTotal := oSubFO2:GetValue("FO2_VALOR") + oSubFO2:GetValue("FO2_VLRJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES")
		
		oSubFO2:LoadValue("FO2_TOTAL" , nTotal)
		oSubFO2:LoadValue("FO2_VLPARC", nTotal)

		nJurFO2 += oSubFO2:GetValue("FO2_TOTAL")
	Next nX
	
	oSubFO0:LoadValue("FO0_VLRNEG", nJurFO2)
	
	oSubFO1:GoLine(1)
	oSubFO2:GoLine(1)
	oView:Refresh() 
	Return
Endif

If nAcJur = 0 // Chamado pelo campo FO0_CALJUR e quando Marcar todos FO1_MARK
	For nX := 1 To oSubFO2:Length()
		oSubFO2:Goline(nX)
		If oSubFO2:GetValue("FO2_VENCTO") > dDataBase
			oSubFO2:LoadValue("FO2_TXCALC",oSubFO0:GetValue("FO0_CALJUR"))
		Else
			oSubFO2:LoadValue("FO2_TXCALC", 0 )
		Endif
		
		nValJur := faJuros(	oSubFO2:GetValue("FO2_VALOR") ,oSubFO2:GetValue("FO2_VALOR"),oSubFO2:GetValue("FO2_VENCTO"),;
							,oSubFO2:GetValue("FO2_TXCALC"),oSubFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
							oSubFO2:GetValue("FO2_VENCTO"),,,,,,, .T.)

		oSubFO2:LoadValue("FO2_VLRJUR", Round(NoRound(xMoeda(nValJur,nMoedaFO0,nMoedaFO0,,3, , nTxMoeda),3),2) )

		nTotal := oSubFO2:GetValue("FO2_VALOR") + oSubFO2:GetValue("FO2_VLRJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES")
		
		oSubFO2:LoadValue("FO2_TOTAL" , nTotal)
		oSubFO2:LoadValue("FO2_VLPARC", nTotal)
	Next nX
ElseIf nAcJur = 1 //Chamado pelo alteração de valor do campo FO2_TXCALC
	oSubFO2:Goline(nPosFO2)
	If oSubFO2:GetValue("FO2_VENCTO") > dDataBase
		nValJur := faJuros(	oSubFO2:GetValue("FO2_VALOR") ,oSubFO2:GetValue("FO2_VALOR"),oSubFO2:GetValue("FO2_VENCTO"),;
							,oSubFO2:GetValue("FO2_TXCALC"),oSubFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
							oSubFO2:GetValue("FO2_VENCTO"),,,,,,, .T.)

		oSubFO2:LoadValue("FO2_VLRJUR", Round(NoRound(xMoeda(nValJur,nMoedaFO0,nMoedaFO0,,3, , nTxMoeda),3),2) )

		nTotal := oSubFO2:GetValue("FO2_VALOR") + oSubFO2:GetValue("FO2_VLRJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES")
			
		oSubFO2:LoadValue("FO2_TOTAL" , nTotal)
		oSubFO2:LoadValue("FO2_VLPARC", nTotal)
	Else
		oSubFO2:LoadValue("FO2_TXCALC", 0 )
		oSubFO2:LoadValue("FO2_VLRJUR", 0 )
	Endif
ElseIf nAcJur = 2 // Chamado pelo MARK individual do FO1_MARK
	For nX := 1 To oSubFO2:Length()
		oSubFO2:Goline(nX)
		If oSubFO2:GetValue("FO2_TXCALC") > 0
			nValJur := faJuros(	oSubFO2:GetValue("FO2_VALOR") ,oSubFO2:GetValue("FO2_VALOR"),oSubFO2:GetValue("FO2_VENCTO"),;
								,oSubFO2:GetValue("FO2_TXCALC"),oSubFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
								oSubFO2:GetValue("FO2_VENCTO"),,,,,,, .T.)

			oSubFO2:LoadValue("FO2_VLRJUR", Round(NoRound(xMoeda(nValJur,nMoedaFO0,nMoedaFO0,,3, , nTxMoeda),3),2) )

			nTotal := oSubFO2:GetValue("FO2_VALOR") + oSubFO2:GetValue("FO2_VLRJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES")
			
			oSubFO2:LoadValue("FO2_TOTAL" , nTotal)
			oSubFO2:LoadValue("FO2_VLPARC", nTotal)
		ElseIf oSubFO2:GetValue("FO2_VENCTO") > dDataBase .And. oSubFO0:GetValue("FO0_CALJUR") > 0
			oSubFO2:LoadValue("FO2_TXCALC", oSubFO0:GetValue("FO0_CALJUR") )
			nValJur := faJuros(	oSubFO2:GetValue("FO2_VALOR") ,oSubFO2:GetValue("FO2_VALOR"),oSubFO2:GetValue("FO2_VENCTO"),;
								,oSubFO2:GetValue("FO2_TXCALC"),oSubFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
								oSubFO2:GetValue("FO2_VENCTO"),,,,,,, .T.)

			oSubFO2:LoadValue("FO2_VLRJUR", Round(NoRound(xMoeda(nValJur,nMoedaFO0,nMoedaFO0,,3, , nTxMoeda),3),2) )
			
			nTotal := oSubFO2:GetValue("FO2_VALOR") + oSubFO2:GetValue("FO2_VLRJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES")
			
			oSubFO2:LoadValue("FO2_TOTAL" , nTotal)
			oSubFO2:LoadValue("FO2_VLPARC", nTotal)
		Endif
	Next nX
ElseIf nAcJur = 3 .Or. nAcJur = 4 // Chamado quando houver alterção da data da FO2_VENCTO E Chamado quando houver alteração do valor FO2_VALOR 
	oSubFO2:Goline(nPosFO2)
	If oSubFO2:GetValue("FO2_VENCTO") > dDataBase .And. (oSubFO2:GetValue("FO2_TXCALC") > 0 .Or. oSubFO0:GetValue("FO0_CALJUR") > 0)
		If oSubFO2:GetValue("FO2_TXCALC") > 0
			nTxJurFO2 := oSubFO2:GetValue("FO2_TXCALC")
		ElseIf oSubFO0:GetValue("FO0_CALJUR") > 0
			nTxJurFO2 := oSubFO0:GetValue("FO0_CALJUR")
		Endif

		nValJur := faJuros(	oSubFO2:GetValue("FO2_VALOR") ,oSubFO2:GetValue("FO2_VALOR"),oSubFO2:GetValue("FO2_VENCTO"),;
							,nTxJurFO2,oSubFO0:GetValue("FO0_MOEDA"),,dDatabase,,,;
							oSubFO2:GetValue("FO2_VENCTO"),,,,,,, .T.)

		oSubFO2:LoadValue("FO2_VLRJUR", Round(NoRound(xMoeda(nValJur,nMoedaFO0,nMoedaFO0,,3, , nTxMoeda),3),2) )
		oSubFO2:LoadValue("FO2_TXCALC", nTxJurFO2 )
		
		nTotal := oSubFO2:GetValue("FO2_VALOR") + oSubFO2:GetValue("FO2_VLRJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES")
			
		oSubFO2:LoadValue("FO2_TOTAL" , nTotal)
		oSubFO2:LoadValue("FO2_VLPARC", nTotal)
	ElseIf oSubFO2:GetValue("FO2_VENCTO") <= dDataBase .And. oSubFO2:GetValue("FO2_TXCALC") > 0
		oSubFO2:LoadValue("FO2_VLRJUR", 0 )
		oSubFO2:LoadValue("FO2_TXCALC", 0 )

		nTotal := oSubFO2:GetValue("FO2_VALOR") + oSubFO2:GetValue("FO2_VLRJUR") + oSubFO2:GetValue("FO2_ACRESC") - oSubFO2:GetValue("FO2_DECRES")
			
		oSubFO2:LoadValue("FO2_TOTAL" , nTotal)
		oSubFO2:LoadValue("FO2_VLPARC", nTotal)
	Endif
Endif

For nX := 1 To oSubFO2:Length()
	oSubFO2:Goline(nX)
	If !oSubFO2:IsDeleted()
		nJurFO2 += oSubFO2:GetValue("FO2_TOTAL")
	EndIf
Next nX

oSubFO0:LoadValue("FO0_VLRNEG", nJurFO2)

If !lOpcAuto
	oSubFO1:GoLine(1)
	oSubFO2:GoLine(nPosFO2)
	oView:Refresh() 
Endif

Return

/*/{Protheus.doc} nTxJuros
Conteúdo do parâmetro MV_LJJUROS
@author  Guilherme de Sordi
@since   28/01/2022
@version 1.0
/*/
static function nTxJuros() as numeric
	if __nTxJuros == NIL
		__nTxJuros := SuperGetMV("MV_LJJUROS", NIL, 0)
	endIf
return __nTxJuros

/*/{Protheus.doc} nTxJuros
Conteúdo do parâmetro MV_JURTIPO
@author  Guilherme de Sordi
@since   28/01/2022
@version 1.0
/*/
static function cJurTipo() as character
	if __cJurTipo == NIL
		__cJurTipo := SuperGetMv("MV_JURTIPO", NIL,"") 
	endIf
return __cJurTipo

/*/ {Protheus.doc} F460AtuMod
	Função para atualizar o model FO1 com os valores dos imadpostos excluídos

	@author Simone Mie Sato Kakinoana
	@since 23/06/2022
	@version 1.0

	@return 
/*/
Function F460AtuMod(nMoeda As Numeric)
	Local oModel  As Object
	Local oView   As Object
	Local oSubFO1 As Object
	Local nTtlPos As Numeric
	Local nTtlNeg As Numeric
	
	Default nMoeda := 1
	
	//Inicializa variáveis
	oModel   	:= FWModelActive()
	oView    	:= FwViewActive()
	oSubFO1		:= oModel:GetModel("TITSELFO1")
	nTtlPos 	:= (oSubFO1:GetValue("FO1_ACRESC") + oSubFO1:GetValue("FO1_VLJUR") + oSubFO1:GetValue("FO1_VLMUL") + oSubFO1:GetValue("FO1_VACESS"))
	nTtlNeg 	:= (oSubFO1:GetValue("FO1_DECRES") + oSubFO1:GetValue("FO1_VLABT") + oSubFO1:GetValue("FO1_DESCON"))
	
	oSubFO1:LoadValue("FO1_BAIXA"	, SE1->E1_BAIXA	)
	oSubFO1:LoadValue("FO1_SALDO"	, SE1->E1_SALDO )
	oSubFO1:LoadValue("FO1_VLBAIX"	, SE1->E1_VALOR - SE1->E1_SALDO	)
	oSubFO1:LoadValue("FO1_VALCVT"	, Round(NoRound(xMoeda(SE1->E1_SALDO,SE1->E1_MOEDA,nMoeda,,3),3),2))
	oSubFO1:LoadValue("FO1_TOTAL" , oSubFO1:GetValue("FO1_VALCVT") - nTtlNeg + nTtlPos)
	
	If !lOpcAuto
		oView:Refresh()
	EndIf
Return Nil
