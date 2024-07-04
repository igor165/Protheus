#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

Static __cCNPJRev
Static __cHashRev
Static __cOriArm
Static __cTipoProd
Static __cDestInt
Static __cDestRev

/*/{Protheus.doc} UBSA010
//Integração SISDEV-MT
@author joaquim.burjack
@since 16/09/2019
@version 1.0
@type function
/*/
Function UBSA010()
	Local bKeyF12 	:= { || Pergunte('UBSA010001', .T.) }
	Local oBrowse   := Nil
	SetKey( VK_F12, bKeyF12 )

	oBrowse:=FWMBrowse():New()
	oBrowse:SetAlias('ND3')
	oBrowse:SetDescription( "Integração SISDEV" )

	//Adiciona legendas
	//	oBrowse:AddLegend( "Empty(ND3_TRANS) ", "RED", "Pendente" )
	//	oBrowse:AddLegend( "!Empty(ND3_TRANS) ", "GREEN", "Realizada" )
	oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 16/09/2019
@version 1.0

@type function
/*/
Static Function MenuDef()
	Local nx
	Local aRetM
	Local aRotina 	:= {}
	Local lPEmenu	:= ExistBlock('UBS010MNU')

	ADD OPTION aRotina Title "Visualizar"	Action 'VIEWDEF.UBSA010'	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title "Transmitir"	Action 'UBSA010AUT'			OPERATION 4 ACCESS 0
	ADD OPTION aRotina Title "Excluir"		Action 'VIEWDEF.UBSA010'	OPERATION 5 ACCESS 0
	//Ponto de Entrada para Adição de opções no menu
	if lPEmenu
		aRetM := ExecBlock('UBS010MNU',.F.,.F.)
		If ValType(aRetM) == 'A'
			for nx := 1 To Len(aRetM)
				ADD OPTION aRotina Title aRetM[nx,1] Action aRetM[nx,2] OPERATION 7 ACCESS 0
			Next nx
		Endif
	Endif

Return aRotina

/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 16/09/2019
@version 1.0

@type function
/*/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruND3 	:= FwFormStruct( 1, "ND3" )//

	// Instancia o modelo de dados
	oModel:=MpFormModel():New( 'UBSA010',/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/ )
	oModel:SetDescription( "Integração SISDEV" )

	// Adiciona estrutura do cabecallho no modelo de dados
	oModel:AddFields( 'CABEC', /*cOwner*/, oStruND3 ,  , )
	oModel:GetModel( "CABEC" ):SetDescription( 'Dados' )

	// Seta Chave Primaria
	oModel:SetPrimaryKey( {} )

Return oModel


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 16/09/2019
@version 1.0

@type function
/*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "UBSA010" )
	Local oStruND3 	:= FwFormStruct( 2, "ND3" ) // Transmissão SISDEV

	// Instancia a View
	oView := FwFormView():New()

	// Seta o model
	oView:SetModel( oModel )

	// Adiciona os campos na estrutura da View
	oView:AddField( 'VIEW_ND3', oStruND3, 'CABEC' )

	// Cria o Box
	oView:CreateHorizontalBox( 'SUP', 100 )

	// Seta Owner
	oView:SetOwnerView( 'VIEW_ND3', 'SUP' )

Return oView

/*/{Protheus.doc} UBSA010AUT
Realiza a comunicação com o WebService SISDEV (UBSA010)
@author luiz.dias
@since 07/11/2019
@version P12
@type function
@return Object, Retorno 
/*/
Function UBSA010AUT()
	Local aAreaAtu  	:= GetArea()
	Local oJson			:= JsonObject():new()
	Local cHeadRet		:= ""
	Local aHeadOut		:= {}
	Local sPostRet		:= ""
	Local nTimeOut		:= 30
	Local cParamEn		:= AllTrim( SuperGetMv( "MV_AGRE001" ) ) //Parametro com o link WebService entradaMudasSementes
	Local cParamSa		:= AllTrim( SuperGetMv( "MV_AGRS001" ) ) //Parametro com o link WebService saidaMudasSementes
	Local cParamPr		:= AllTrim( SuperGetMv( "MV_AGRS002" ) ) //Parametro com o link WebService vendaMudasSementes
	Local cBasicUP		:= AllTrim( SuperGetMv( "MV_AGRH002" ) ) //Parametro com o BaseEncode64 - 53113791002761:65759c User:Password

	Private _cNota		:= ND3->ND3_DOC
	Private _cSerie		:= ND3->ND3_SERIE
	Private _cFornec	:= ND3->ND3_FORNEC
	Private _cLoja		:= ND3->ND3_LOJA
	Private _cCliente	:= ND3->ND3_CLIENT
	Private _cCodProd	:= ND3->ND3_CODPRO

	Pergunte('UBSA010001', .F.)

//	__cCNPJRev			:= AllTrim( MV_PAR01 ) // CNPJ da Revenda para composição da validação do JSON (Saída ou Entrada)
	__cCNPJRev			:= AllTrim( (FWArrFilAtu(cEmpAnt,cFilAnt))[18] ) // CNPJ da Revenda para composição da validação do JSON (Saída ou Entrada)
	__cHashRev			:= AllTrim( SuperGetMv( "MV_AGRH001" ) ) //Hash da revenda para composição da validação do JSON (Saída ou Entrada)
	__cOriArm			:= IIF( MV_PAR02 = 1, 'true', 'false' ) //Origem da Armazenagem - Utilizando na entrada ou saída de sementes
	__cTipoProd			:= IIF( MV_PAR03 = 1, '2', '8' ) //Tipo do Produto utilizado para adicionar ao JSON o tipo 'sementes'
	__cDestInt			:= IIF( MV_PAR04 = 1, 'true', 'false' ) //Destino Internacional - utilizando em requisição de saída de sementes
	__cDestRev			:= IIF( MV_PAR05 = 1, 'true', 'false' ) //Destino da Revenda - utilizando em requisição de saída de sementes

	/*-------------------------------------------//
	// Cabeçalho da requisição REST ao WebService //
	//-------------------------------------------*/

	Aadd( aHeadOut,"Accept: application/json" ) //necessario para lib superior abril/2018
	Aadd( aHeadOut,"Content-Type: application/json" )
	Aadd( aHeadOut,"Authorization: Basic " + cBasicUP )

	/*---------------------------------------------------------//
	// Condicionamento do tipo de transmissão (Entrada, Saída, Venda-Produtor) //
	//---------------------------------------------------------*/

	ND3->( dbSetOrder( 2 ) )
	ND3->( dbSeek( FWxFilial( "ND3" ) + _cNota + _cSerie + _cFornec + _cLoja ) )
	If ND3->ND3_TIPOOP == "1" //Entrada de Nota
		oJson	 := UBSA010ENT()
		sPostRet := HttpPost( cParamEn, '', oJson, nTimeOut, aHeadOut, @cHeadRet )
	ElseIf ND3->ND3_TIPOOP == "2" //Saída de Nota
		oJson	 := UBAS010SAI()
		sPostRet := HttpPost( cParamSa, '', oJson, nTimeOut, aHeadOut, @cHeadRet )
	ElseIf ND3->ND3_TIPOOP == "4" //Venda-Produtor
		oJson 	 := UBAS010PROD()
		sPostRet := HttpPost( cParamPr, '', oJson, nTimeOut, aHeadOut, @cHeadRet )
	EndIf

	UBSA010AJN( oJson ) //Gerando log com o JSON gerado e enviado na requisição em protheus_data
	UBSA010ATX( sPostRet ) //Gerando log em protheus_data - Resposta da requisição ao WebService

	/*-----------------------------------------------------------------------------------//
	// Tratamento do retorno e gravação na tabela ND3 - Campo Retorno e Data Transmissão //
	//-----------------------------------------------------------------------------------*/
	While ND3->( !Eof() ) .And. ND3->ND3_FILIAL = FWxFilial( "ND3" ) .And. ND3->ND3_DOC == _cNota .And. ND3->ND3_SERIE == _cSerie;
    .And. ND3->ND3_FORNEC == _cFornec .And. ND3->ND3_CLIENT == _cCliente .And. ND3->ND3_LOJA == _cLoja       
		If RecLock( "ND3", .F. )
			If sPostRet == Nil
          		ND3->ND3_TRANSM := 'Comunicação não realizada, tente novamente.'
          		ND3->ND3_DTTRAN := dDatabase
			ElseIf(lBIIsDigit(sPostRet, .T.))
           		ND3->ND3_TRANSM := 'Transmitido com sucesso. Detalhes: '+sPostRet
            	ND3->ND3_DTTRAN := dDatabase
			Else
	       		ND3->ND3_TRANSM := sPostRet
            	ND3->ND3_DTTRAN := dDatabase    
			EndIf
        	ND3->( DbSkip() )
			ND3->( MsUnlock() )
		EndIf	
	EndDo
	FreeObj( oJson )

	RestArea( aAreaAtu )

Return

/*/{Protheus.doc} UBSA010ENT
Criação do JSON com informações de entrada de sementes SISDEV - POST 
@author luiz.dias
@since 07/11/2019
@version 1.0
@return Object, (cSemente) JSON com as informações de transmissão.
@type function
/*/
Static Function UBSA010ENT()
	Local lAgrSISDEV:= ExistBlock( 'AGRSDEV' )
	Local lCodigo	:= IIF(!Empty(ND3->ND3_CODIGO), .T., .F.)
	Local aRet		:= {}
	Local aMaster	:= {}
	Local aDetail	:= {}
	Local aAreaAtu  := GetArea()
	Local aItens	:= {}
	Local oSemente	:= JsonObject():new()
	Local nItens	:= 0
	Local ny		:= 0
	Local nSaveSx8  := GetSx8Len()
	Local cSemente	:= ""
	Local cCodigo	:= ""

	/*-----------------------------------------------------------------------------------------//
	//	Gera um número sequencial, verifica se o registro tem código de lançamento/transmissão //
	//-----------------------------------------------------------------------------------------*/
	If !lCodigo
		cCodigo	:= GetSx8Num( "ND3", "ND3_CODIGO" )
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSx8()
		End
	EndIf

	/*--------------------------------------------------------------//
	//	Verifica a existencia do Ponto de Entrada e executa AGRSDEV //
	//--------------------------------------------------------------*/
	If lAgrSISDEV
		aRet := ExecBlock( 'AGRSDEV',.F.,.F., )
		If ValType( aRet ) == 'A' 
			aMaster := aClone( aRet[1] )
			aDetail := aClone( aRet[2] )
		EndIf
	EndIf

	/*--------------------------------------------------------------------//
	//	Construção do cabeçalho objeto Json para envio da entrada de nota //
	//--------------------------------------------------------------------*/
	oSemente['cnpjRevenda']				:= __cCNPJRev
	oSemente['hashRevenda']				:= __cHashRev
	oSemente['origemArmazenador'] 		:= __cOriArm
	oSemente['cpfCnpjFornecedor']		:= AllTrim( ND3->( ND3_CGC )	)
	oSemente['codMunicipioFornecedor']	:= AllTrim( ND3->( ND3_CODMUN ) ) 
	oSemente['renasemFornecedor']		:= AllTrim( ND3->( ND3_RENASE ) ) 
	oSemente['nomeFornecedor']			:= AllTrim( ND3->( ND3_FORCLI ) )
	oSemente['observacao']				:= AllTrim( ND3->( ND3_OBSERV ) )
	oSemente['nrNf']					:= AllTrim( ND3->( ND3_DOC ) )
	oSemente['dtNf']					:= Year2Str( ND3->( ND3_DTDOC ) ) + '-' + Month2Str( ND3->( ND3_DTDOC ) ) + '-' + Day2Str( ND3->( ND3_DTDOC ) )
	oSemente['serieNf'] 				:= AllTrim( ND3->( ND3_SERIE ) ) 
	oSemente['dataEntrada'] 			:= Year2Str( ND3->( ND3_DTENTR ) ) + '-' + Month2Str( ND3->( ND3_DTENTR ) ) + '-' + Day2Str( ND3->( ND3_DTENTR ) )
	oSemente['codTipoProduto'] 			:= __cTipoProd
	oSemente['codLancamentoUsuario'] 	:= IIF(lCodigo, ND3->ND3_CODIGO, cCodigo)


	/*----------------------------------------------------------------------------//
	//	Verifica a existência e executa as alterações no objeto do cabeçalho JSON //
	//----------------------------------------------------------------------------*/
	If lAgrSISDEV
		For ny := 1 to Len(aMaster)
			oSemente[aMaster[ny][1]] 	:= aMaster[ny][2]
		Next ny
	EndIF

	/*-----------------------------------------------------------------------------------------------//
	//	Filtragem para realizar a construção da lista de itens da nota de entrada a enviar ao SISDEV //
	//-----------------------------------------------------------------------------------------------*/
	ND3->(dbSetOrder( 2 ))
	ND3->(dbSeek(FWxFilial("ND3") + _cNota + _cSerie + _cFornec + _cLoja))
	While ND3->(!Eof()) .And. ND3->ND3_FILIAL = FWxFilial("ND3") .And. ND3->ND3_DOC == _cNota .And. ND3->ND3_SERIE == _cSerie .And. ND3->ND3_FORNEC == _cFornec .And. ND3->ND3_LOJA == _cLoja
		IF RecLock("ND3", .F.)	
			Aadd(aItens,JsonObject():new())
			nItens									:= Len(aItens)
			aItens[nItens]['codCultivar']			:= AllTrim( ND3->( ND3_CTVAR ) )
			aItens[nItens]['codCategoriaSementes']	:= AllTrim( ND3->( ND3_CTGSMT ) )
			aItens[nItens]['nrDarIndea']			:= AllTrim( ND3->( ND3_DINDEA ) )  
			aItens[nItens]['nrDarFase']				:= AllTrim( ND3->( ND3_DFASE ) ) 
			aItens[nItens]['lote']					:= AllTrim( ND3->( ND3_LOTE ) )
			aItens[nItens]['qntProduto']			:= ND3->( ND3_QUANT )

			If lCodigo .AND. ND3->( ND3_CODIGO ) <> cCodigo
				cCodigo	            := ND3->( ND3_CODIGO )
			Else
				ND3->( ND3_CODIGO )	:= cCodigo
			EndIf

			If lAgrSISDEV
				For ny := 1 to Len(aDetail)
					aItens[nItens][aDetail[ny][1]] := aDetail[ny][2]
				Next ny
			EndIf
			ND3->(DbSkip())
			ND3->(MsUnlock())
		EndIf	
	EndDo

	oSemente['itens'] := aItens
	cSemente		  := oSemente:toJSON()

	RestArea( aAreaAtu )

Return cSemente

/*/{Protheus.doc} UBAS010SAIDA
Criação do JSON com informações de saída de sementes SISDEV - POST 
@author luiz.dias
@since 07/11/2019
@version 1.0
@return Object, (cSemente) JSON com as informações de transmissão.
@type function
/*/
Static Function UBAS010SAI()
	Local lCodigo	:= IIF(!Empty(ND3->ND3_CODIGO), .T., .F.)
	Local aAreaAtu  := GetArea()
	Local aItens	:= {}
	Local oSemente	:= JsonObject():new()
	Local nSaveSx8  := GetSx8Len()
	Local cSemente	:= ""
	Local cCodigo

	/*-----------------------------------------------------------------------------------------//
	//	Gera um número sequencial, verifica se o registro tem código de lançamento/transmissão //
	//-----------------------------------------------------------------------------------------*/
	If !lCodigo
		cCodigo	:= GetSx8Num( "ND3", "ND3_CODIGO" )
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSx8()
		End
	EndIf

	/*---------------------------------------------------------------------//
	//	Construção do cabeçalho objeto Json para envio da entrada de saída //
	//---------------------------------------------------------------------*/
	oSemente['cnpjRevenda']				:= __cCNPJRev
	oSemente['hashRevenda']				:= __cHashRev
	oSemente['destinoArmazenador'] 		:= __cOriArm
	oSemente['nrNf']					:= AllTrim(ND3->( ND3_DOC ) )
	oSemente['serieNf'] 				:= AllTrim(ND3->( ND3_SERIE ) )
	oSemente['dtNf']					:= Year2Str(ND3->( ND3_DTDOC )) + '-' + Month2Str(ND3->( ND3_DTDOC )) + '-' + Day2Str(ND3->( ND3_DTDOC ))
	oSemente['destinoRevenda']			:= __cDestRev
	oSemente['codTipoProduto'] 			:= __cTipoProd
	If Empty(ND3->( ND3_RENASE ))
		oSemente['renasemDestino']		:= ' '
	else
		oSemente['renasemDestino']		:= AllTrim( ND3->( ND3_RENASE ) )
	Endif
	oSemente['nomeDestino']				:= AllTrim(ND3->( ND3_FORCLI ) )
	oSemente['observacao']				:= AllTrim(ND3->( ND3_OBSERV ) )
	oSemente['destinoInternacional']	:= __cDestInt
	oSemente['cpfCnpjDestino']			:= AllTrim(ND3->ND3_CGC	)
	oSemente['codMunicipioDestino']		:= AllTrim(ND3->ND3_CODMUN)	
	oSemente['codLancamentoUsuario'] 	:= IIF(lCodigo, ND3->ND3_CODIGO, cCodigo)

	/*---------------------------------------------------------------------------------------------//
	//	Filtragem para realizar a construção da lista de itens da nota de saída a enviar ao SISDEV //
	//---------------------------------------------------------------------------------------------*/
	ND3->(dbSetOrder( 3 ))
	ND3->(dbSeek(FWxFilial("ND3") + _cNota + _cSerie + _cCliente + _cLoja))
	While ND3->(!Eof()) .And. ND3->ND3_FILIAL = FWxFilial("ND3") .And. ND3->ND3_DOC == _cNota .And. ND3->ND3_SERIE == _cSerie .And. ND3->ND3_CLIENT == _cCliente .And. ND3->ND3_LOJA == _cLoja
		If RecLock("ND3", .F.)
			Aadd(aItens,JsonObject():new())
			nItens									:= Len(aItens)
			aItens[nItens]['codCultivar']			:= AllTrim(ND3->ND3_CTVAR)
			aItens[nItens]['lote']					:= AllTrim(ND3->ND3_LOTE)
			aItens[nItens]['qntProduto']			:= ND3->ND3_QUANT

			If lCodigo .AND. ND3->ND3_CODIGO <> cCodigo
				cCodigo			:= ND3->ND3_CODIGO
			Else
				ND3->ND3_CODIGO	:= cCodigo
			EndIf
			ND3->(DbSkip())
			ND3->(MsUnlock())
		EndIf	
	End
	
	oSemente['itens'] := aItens
	cSemente		  := oSemente:toJSON()

	RestArea( aAreaAtu )

Return cSemente


/*/{Protheus.doc} UBSA010AJN
Função responsável pela criação do arquivo com o json.
@author luiz.dias
@since 13/11/2019
@version 1.0
@param Object, oObjJson, Json construido para exportação.
@type function
/*/
Static Function UBSA010AJN(oObjJson)
	Local cArq		:= "\TransmissãoSISDEV" + cValToChar(ND3->ND3_CODIGO) + ".json"
	Local nHandle	:= FCreate(cArq, 0, NIL, .F.)

	If nHandle < 0
		MsgAlert("Erro ao criar o arquivo" + cArq)
	Else
		FWrite(nHandle, oObjJson)	
		FClose(nHandle)	
	EndIf	
Return

/*/{Protheus.doc} UBSA010ATX
Função responsável pela criação do arquivo em formato txt.
@author luiz.dias
@since 08/12/2019
@version 1.0
@param RespReq, Caracter , Resposta da requisição ao WebService SISDEV.
@type function
/*/
Static Function UBSA010ATX(RespReq)
	Local cArq		:= "\Resposta requisição SISDEV" + cValToChar(ND3->ND3_CODIGO) + ".txt"
	Local nHandle	:= FCreate(cArq, 0, NIL, .F.)

	If nHandle < 0
		MsgAlert("Erro ao criar o arquivo" + cArq)
	Else
		If RespReq != Nil
			FWrite(nHandle, RespReq)
		EndIf
		FClose(nHandle)
	EndIf
Return

/*/{Protheus.doc} UBAS010PROD
Criação do JSON com informações de venda de sementes/mudas - Produtor - SISDEV - POST 
@author lara.rodrigues
@since 06/04/2020
@version 1.0
@return Object, (cSemente) JSON com as informações de transmissão.
@type function
/*/
Static Function UBAS010PROD()
	Local lCodigo	:= IIF(!Empty(ND3->ND3_CODIGO), .T., .F.)
	Local aAreaAtu  := GetArea()
	Local aItens	:= {}
	Local oSemente	:= JsonObject():new()
	Local nSaveSx8  := GetSx8Len()
	Local cSemente	:= ""
	Local cCodigo	:= ""
	Local ny		:= 0
	Local lAgrSISDEV:= ExistBlock( 'AGRSDEV' )
	Local aRet		:= {}
	Local aMaster	:= {}
	Local aDetail	:= {}
	
	/*-----------------------------------------------------------------------------------------//
	//	Gera um número sequencial, verifica se o registro tem código de lançamento/transmissão //
	//-----------------------------------------------------------------------------------------*/
	If !lCodigo
		cCodigo	:= GetSx8Num( "ND3", "ND3_CODIGO" )
		While ( GetSX8Len() > nSaveSx8 )
			ConfirmSx8()
		End
	EndIf

	/*--------------------------------------------------------------//
	//	Verifica a existencia do Ponto de Entrada e executa AGRSDEV //
	//--------------------------------------------------------------*/
	If lAgrSISDEV
		aRet := ExecBlock( 'AGRSDEV',.F.,.F., )
		If ValType( aRet ) == 'A' 
			aMaster := aClone( aRet[1] )
			aDetail := aClone( aRet[2] )
		EndIf
	EndIf

	/*---------------------------------------------------------------------//
	//	Construção do cabeçalho objeto Json para envio da entrada de saída //
	//---------------------------------------------------------------------*/
	oSemente['cnpjRevenda']				:= __cCNPJRev
	oSemente['hashRevenda']				:= __cHashRev
	oSemente['nrNf']					:= AllTrim(ND3->( ND3_DOC ) )
	oSemente['serieNf'] 				:= AllTrim(ND3->( ND3_SERIE ) )
	oSemente['dtNf']					:= Year2Str(ND3->( ND3_DTDOC )) + '-' + Month2Str(ND3->( ND3_DTDOC )) + '-' + Day2Str(ND3->( ND3_DTDOC ))
	oSemente['destinoRevenda']			:= __cDestRev
	oSemente['codTipoProduto'] 			:= __cTipoProd
	If Empty(ND3->( ND3_RENASE ))
		oSemente['renasemDestino']		:= ' '
	else
		oSemente['renasemDestino']		:= AllTrim( ND3->( ND3_RENASE ) )
	Endif
	oSemente['nomeDestino']				:= AllTrim(ND3->( ND3_FORCLI ) )
	oSemente['observacao']				:= AllTrim(ND3->( ND3_OBSERV ) )
	oSemente['destinoInternacional']	:= __cDestInt
	oSemente['cpfCnpjDestino']			:= AllTrim(ND3->( ND3_CGC ) )
	If ND3->(FieldPos("ND3_CODSAF")) > 0
		oSemente['codSafra']			:= AllTrim(ND3->( ND3_CODSAF ) )
	Else
		oSemente['codSafra']	        := ''
	Endif	
	oSemente['codMunicipioDestino']		:= AllTrim(ND3->ND3_CODMUN)	
	oSemente['codLancamentoUsuario'] 	:= IIF(lCodigo, ND3->ND3_CODIGO, cCodigo)

	/*----------------------------------------------------------------------------//
	//	Verifica a existência e executa as alterações no objeto do cabeçalho JSON //
	//----------------------------------------------------------------------------*/
	If lAgrSISDEV
		If ValType( aMaster ) == 'A'
			For ny := 1 to Len(aMaster)
				oSemente[aMaster[ny][1]] 	:= aMaster[ny][2]
			Next ny
		EndIf
	EndIF

/*---------------------------------------------------------------------------------------------//
	//	Filtragem para realizar a construção da lista de itens da nota de saída a enviar ao SISDEV //
	//---------------------------------------------------------------------------------------------*/
	ND3->(dbSetOrder( 2 ))
	ND3->(dbSeek(FWxFilial("ND3") + _cNota + _cSerie + _cFornec + _cLoja))
	While ND3->(!Eof()) .And. ND3->ND3_FILIAL = FWxFilial("ND3") .And. ND3->ND3_DOC == _cNota .And. ND3->ND3_SERIE == _cSerie .And. ND3->ND3_FORNEC == _cFornec .And. ND3->ND3_LOJA == _cLoja
		IF RecLock("ND3", .F.)
			Aadd(aItens,JsonObject():new())
			nItens									:= Len(aItens)
			aItens[nItens]['codCultivar']			:= AllTrim( ND3->( ND3_CTVAR ) )
			aItens[nItens]['codCategoriaSementes']	:= AllTrim( ND3->( ND3_CTGSMT ) )
			aItens[nItens]['darIndea']				:= AllTrim( ND3->( ND3_DINDEA ) )  
			aItens[nItens]['darFase']				:= AllTrim( ND3->( ND3_DFASE ) ) 
			aItens[nItens]['lote']					:= AllTrim( ND3->( ND3_LOTE ) )
			aItens[nItens]['qntProduto']			:= ND3->( ND3_QUANT )

			If lCodigo .AND. ND3->( ND3_CODIGO ) <> cCodigo
				cCodigo				:= ND3->( ND3_CODIGO )
			Else
				ND3->( ND3_CODIGO )	:= cCodigo
			EndIf

			If lAgrSISDEV
				If ValType( aDetail ) == 'A'
					For ny := 1 to Len(aDetail)
						aItens[nItens][aDetail[ny][1]] := aDetail[ny][2]
					Next ny
				EndIf
			EndIf
			ND3->(DbSkip())
			ND3->(MsUnlock())
		EndIf
	EndDo

	oSemente['itens'] := aItens
	cSemente		  := oSemente:toJSON()

	RestArea( aAreaAtu )

Return cSemente
