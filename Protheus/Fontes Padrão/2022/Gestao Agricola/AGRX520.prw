#INCLUDE "AGRA520.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} AGRX520PED
//Respons�vel por gerar PV do tipo devolu��o, seguido de NF Sa�da para a filial destino da pendencia e
// NF Entrada para a filial origem da pend�ncia.
@author brunosilva
@since 14/03/2018

@type function
/*/
Function AGRX520PED(cFil, cCodrom, nQtdPen, cCodEnt, cLojEnt, cRomOri)
	Local aArea          := GetArea()
	Local aPedido		 := {{},{}}
	Local cPvGerado	     := Criavar("C5_NUM",.F. )  // Ira Armazenar o nr. do Pv Gerado
	Local cSerie         := SuperGetMV("MV_OGASERS",," ")
	Local aRet           := {}
	Local aRetPe         := {}
	Local lRet           := .T.
	Local cAliasQry      := ""
	Local cQry
	local cFilTemp		 := cFilAnt
	Local cNFent		 := ""

	Private lMsErroAuto  := .F.
	Private _aCab		 := {}
	Private _aItens 	 := {}

	cAliasQry := GetNextAlias()

	cQry := " SELECT * FROM "+ RetSqlName("NJM") +" NJM "
	cQry += "  WHERE NJM_FILIAL = '" + cFil + "' "
	cQry += "    AND  NJM_CODROM  = '" + cCodrom + "'" 
	cQry += "    AND D_E_L_E_T_<> '*' "

	cQry := ChangeQuery( cQry )	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )	

	nModulo := 5

	aAdd(aPedido[1],{"C5_CODROM"   , cCodrom , Nil})
	aAdd(aPedido[1],{"C5_TIPO"     , "D"	                        , Nil}) //Devolu��o
	aAdd(aPedido[1],{"C5_CLIENTE"  , Posicione('NJ0',1,FWxFilial('NJ0')+cCodEnt+cLojEnt,'NJ0_CODFOR'), Nil})
	aAdd(aPedido[1],{"C5_LOJACLI"  , Posicione('NJ0',1,FWxFilial('NJ0')+cCodEnt+cLojEnt,'NJ0_LOJFOR'), Nil})
	aAdd(aPedido[1],{"C5_CONDPAG"  , Iif(!(EMPTY((cAliasQry)->NJM_CONDPG)),(cAliasQry)->NJM_CONDPG, '001'), Nil})
	aAdd(aPedido[1],{"C5_CODSAF"   , (cAliasQry)->NJM_CODSAF        , Nil})
	aAdd(aPedido[1],{"C5_MOEDA"    , 1     		                    , Nil})
	aAdd(aPedido[1],{"C5_ORIGEM"   , 'AGRA520'                      , Nil})		
	aAdd(_aCab, aPedido[1])

	//Pego a TES de devolu��o cadastrada para a TES vinculada ao romaneio de origem.
	aAdd(aPedido[2], {"C6_TES"     , POSICIONE('SF4',1,FWxFilial('SF4')+(cAliasQry)->NJM_TES, 'F4_TESDV'), Nil})                                                        
	aAdd(aPedido[2], {"C6_ITEM"	   , '01'   	                    , Nil})
	aAdd(aPedido[2], {"C6_PRODUTO" , (cAliasQry)->NJM_CODPRO        , Nil})
	
	If .NOT. empty((cAliasQry)->NJM_LOTCTL)
		aAdd(aPedido[2], {"C6_LOTECTL" , (cAliasQry)->NJM_LOTCTL        , Nil})
	EndIf
	
	If .NOT. empty((cAliasQry)->NJM_NMLOT)
		aAdd(aPedido[2], {"C6_NUMLOTE" , (cAliasQry)->NJM_NMLOT         , Nil})
	EndIf
	
	If .NOT. empty((cAliasQry)->NJM_LOCLIZ)
		aAdd(aPedido[2], {"C6_LOCALIZ" , (cAliasQry)->NJM_LOCLIZ        , Nil})
	EndIf
	
	aAdd(aPedido[2], {"C6_QTDVEN"  , nQtdPen 						, Nil})
	aAdd(aPedido[2], {"C6_QTDLIB"  , nQtdPen 						, Nil})		
	aAdd(aPedido[2], {"C6_PRCVEN"  , (cAliasQry)->NJM_VLRUNI        , Nil})
	aAdd(aPedido[2], {"C6_NFORI"   , (cAliasQry)->NJM_DOCNUM        , Nil})
	aAdd(aPedido[2], {"C6_SERIORI" , (cAliasQry)->NJM_DOCSER        , Nil})
	aAdd(aPedido[2], {"C6_ITEMORI" , '0001', Nil}) //Aqui consideramos s� ter um item na SD1(Itens da nota fiscal!)
	aAdd(_aItens, aPedido[2])

	If !(Empty(_aItens)) 
		//PONTO DE ENTRADA PARA GERA��O DE PEDIDO DE VENDA NA SOLU��O DE PENDENCIA F�SICA
		If EXISTBLOCK ("AGX520PU") 
			aRetPe := ExecBlock("AGR520PU",.F.,.F.,{oModel, aPedido[1], _aItens})

			If Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
				aPedido[1] := aRetPe[1]
				_aItens    := aRetPe[2]
			EndIf
		EndIf

		_aCab      := aPedido[1]
		aPedido[1] := FWVetByDic(_aCab,'SC5')
		_aItens    := FWVetByDic(_aItens,'SC6',.T.)
		MsgRun(STR0024,STR0021,{||MSExecAuto({|a,b,c|Mata410(a,b,c)},_aCab,_aItens,3)}) //"Gerando Pedido de Venda."  //"Aguarde"
	EndIf

	If lMsErroAuto .OR. Empty(_aItens) .OR. !lRet
		MostraErro()
		lRet := .F.
	Else
		cPvGerado := SC5->C5_NUM
	EndIf
	//Devolvo o m�dulo AGR
	nModulo := 67

	//Se a gera��o do pedido foi conclu�da com sucesso.
	IF lRet
		MsgRun(STR0025,STR0021,{|| aRet := AgrGeraNFS(cPVGerado,cSerie)}) //"Gerando NF de Saida." //"Aguarde"
		// Se gerou NF sa�da com sucesso
		If !(EMPTY(aRet))
			aAdd(aRet, cCodrom) //C�digo do romaneio no destino
			aAdd(aRet, nQtdPen) //Quantidade da pendencia

			//Logo na filial correspondente a entidade da pendencia.
			cFilAnt := Posicione('NJ0',1,FWxFilial('NJ0')+cCodEnt+cLojEnt,'NJ0_CODCRP')

			//Gera NF de Entrada na filial de origem
			MsgRun(STR0026,STR0021,{|| OGX009A(cRomOri,aRet)}) //"Gerando NF de Entrada na filial de origem." //"Aguarde"
			cNFent := SD1->D1_DOC //Pego o numero do documento de entreda gerado, para garantir que foi gerado.
		Else //Caso houve algum erro na gera��o de NF saida, desfaz.
			lRet := .F.
		EndIF

		If !(EMPTY(cNFent)) //Se a gera��o de NF entrada ocorreu com sucesso
			ConfirmSx8()
		Else //Caso n�o, desfaz.
			lRet := .F.
		EndIf
	EndIF

	//Devolvo a filial 
	cFilAnt := cFilTemp

	RestArea(aArea)
Return lRet

//*******************************************************************************//
//*******************************************************************************//
// Esta fun��o n�o est� sendo usada, todas as chamadas dela est�o comentadas.    //
// Esta fun��o estava atualizando o peso do fard�o para o valor antigo, pois     //
//ele pega o vinculo da DXO da filial de origem, por�m, o valor j� foi corrigido //
//no momento da confirma��o do romaneio.									     //
//*******************************************************************************//
//*******************************************************************************//
/*/{Protheus.doc} AX520APFar
Fun��o para atualizar o peso do fard�o de acordo com o peso l�quido do romaneio
@author silvana.torres
@since 03/04/2018
@version undefined
@param cfil, characters, descricao
@param cRomaneio, characters, descricao
@param nValPend, numeric, descricao
@type function
/*/
Function AX520APFar(cfil, cRomaneio, nValPend)

	Local aArea 	:= GetArea()
	Local lRet		:= .F.			
	Local oMdDXL  	:= FwLoadModel('AGRA601') 

	DbSelectArea("DX0")
	DX0->(dbSetOrder(3))	//DX0_FILIAL+DX0_NRROM
	DX0->(MsSeek(cfil + cRomaneio))
	
	While !DX0->(EOF())  .AND. DX0->DX0_FILIAL == cfil .And. DX0->DX0_NRROM == cRomaneio
		
		DbSelectArea("DXL")
		DXL->(dbGotop())
		DXL->(dbSetOrder(2))	//DXL_FILIAL+DXL_CODUNI

		if (DXL->(MsSeek(DXL->DXL_FILIAL + DX0->DX0_CODUNI)))		
			oMdDXL:SetOperation(MODEL_OPERATION_UPDATE) //Altera��o
		
			If oMdDXL:Activate()
				oMdDXL:GetModel("DXLMASTER"):LoadValue('DXL_PSLIQU',DX0->DX0_PSLIQU)	
		
				If (lRet := oMdDXL:VldData())
					oMdDXL:CommitData()
					lRet := .T.								
				Else
					lRet := .F.
					oMdDXL:SetErrorMessage( , , , , , oMdDXL:GetErrorMessage()[6])
				Endif
			Endif
		endIf
		
		DXL->(dbCloseArea())
	
		oMdDXL:DeActivate()	
		
		DX0->(dbSkip())
	End  
	
	DX0->(dbCloseArea())
	
	RestArea(aArea)
	
Return lRet