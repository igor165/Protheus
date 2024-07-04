#INCLUDE "Protheus.ch"
#INCLUDE "OGX008.ch"

#define COL_COUNT    19
#define COL_MARK     1
#define COL_DOC      2
#define COL_SERIE    3
#define COL_EMISSAO  4
#define COL_ITEM     5
#define COL_QUANT    6
#define COL_QTDFIX   7
#define COL_VUNIT    8
#define COL_VTOTAL   9
#define COL_SALDO    10
#define COL_DISTRIB  11
#define COL_VDISTR   12
#define COL_IDENTB6  13
#define COL_LOTECTL  14
#define COL_VAZIO    15
#define COL_CODROM   16
#define COL_ITEROM   17
#define COL_QTDRET   18
#define COL_QTDQTC   19

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio

/** {Protheus.doc} OGX008A
Rotina para geração do documento de Saída

@param:     Nil
@return:    lRetorno - .t. - verdadeiro / .f. - falso
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       SIGAAGR - Originação de Grãos
@type function
*/
Function OGX008A(cRomaneio,cItRom,aRecVenda)
	Local aAreaAtu 	:= GetArea()
	Local nX       	:= 0
	Local nY       	:= 0
	Local aRetPe	:= {}   //-- Variavel de Ret. do PE OGX008PV --//
	Local lTrfSld	:= FwIsInCallStack("OGA455")

	//-- Variaveis de queries
	Local cQNFREF1		:= ""
	Local cQNFREF2		:= ""
	Local cQueryNJM		:= ""

	Local cAliasREF1	:= GetNextAlias()
	Local cAliasREF2	:= GetNextAlias()
	Local cAliasNJM		:= GetNextAlias()
	//-----------------------------------

	/** Variaveis do Cabeçalho do Pedido de Venda */
	Local aCab      := {}
	Local aEspecie  := {}
	Local aVolume   := {}
	Local cPedido   := ""	//GetSXENum( "SC5", "C5_NUM" )
	Local cTipo     := ""
	Local cCliente  := ""
	Local cLoja     := ""	
	Local cCondPg   := ""
	Local cTransp   := ""
	Local cVeic1  	:= ""
	Local cVeic2  	:= ""
	Local cTpFrete  := ""
	Local cDoc      := ""
	Local cSerie    := ""
	Local nQtdRegA  := 0
	Local nQtdRegD  := 0
	Local cOrigem   := ""

	/** Variaveis do Item do Pedido de Venda */
	Local aLinha        := {}
	Local aItens        := {}
	Local aSelNfs       := {}
	Local aItemAlg		:= {}
	Local cProduto      := ""
	Local cTipProd      := ""
	Local cTes          := ""
	Local cOpeFis		:= ""
	Local cLocal        := ""
	Local cCodCtr       := ""
	Local cCodDocC5     := ""
	Local cCodDocC6     := ""
	Local cIteDocC6     := ""
	Local cIdentB6      := ""
	Local cItemSeq      := StrZero(0, TamSX3( "C6_ITEM" )[1])
	Local nQuant        := 0
	Local nTotal        := 0
	Local nTotPed       := 0
	Local nPreco        := 0	
	Local nQTotalX      := 0
	Local nVUnitX       := 0
	Local nVTotalX      := 0	
	Local nPSLiq        := 0
	Local nPSSubt       := 0
	Local dEmissao      := ""	//IIf( NJM->( NJM_TPFORM ) = "1", dDataBase, NJM->( NJM_DOCEMI ) )
	Local cFormulario   := ""	//IIf( NJM->( NJM_TPFORM ) = "1", "S", "N" )
	Local _cObs         := ""
	Local cMsgNfAux     := ""
	Local cClassVlr     := ""
	Local lCond         := .f.
	Local lVencimento   := .f.
	Local cCodSaf       := ""
	Local lOperTri      := .t.
	Local cNumero       := ""	//NJM->( NJM_DOCNUM )
	Local nRecno        := 0
	Local nFrete        := 0
	Local nSeguro       := 0
	Local nDespesa      := 0
	Local nQuantEmb     := 0

	//Produto Adicional
	Local _cInDap       := ""
	Local dVcntDAP      := ""
	Local _cITVDAP      := "2"
	Local cModAtu       := cModulo
	Local nModAtu       := nModulo

	//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
	Local lVinculou		:= .F.
	Local cHist         := ""
	Local aAreaNJM		:= NJM->(GetArea())
	Local lExced		:= .F.

	Local aDatasVenc    := {}
	Local aVlrUni		:= {}
	Local nTotPedVenc   := 0
	Local nTotParc   	:= 0
	
	Local cNumAvi       := ""
	Local cNumDco       := ""
	Local cSeqDco       := ""
	Local cTpAvis       := ""
	Local cObserv       := ""
	Local aRfVenda      := {}
	Local aNFSVnd		:= {}
	Local lRastro       := SuperGetMv('MV_RASTRO', , .F.) == 'S'	
	Local lQrbPrc       := SuperGetMV("MV_AGRO209",, .F.)
	Local nTam 			:= TamSx3("NJJ_DOCNUM")[1] 
	Local aVincCabNF	:= {}
	Local aVincIteNF	:= {}	
	Local cC5INDPRES    := "" //armazena informação para C5_INDPRES Presença Comprador (NT 2020.006)
	Local cC5CODA1U     := "" //armazena informação para C5_CODA1U Codigo Intermediador (NT 2020.006)	
	
	Default cItRom 		:= ""

	Private lMsErroAuto := .F.
	Private _lNFOrigem  := .F. 
	Private _aItensTrf	:= {}
	
	//--Variaveis que indicam qual a movimentação a realizar
	Private _lCtrlTer	:= .F.	//Devolução com controle de teceiros
	Private _lCtrlDev	:= .F.	//Devolução de quantidade
	Private _lCtrlDVl	:= .F.	//Devolução de valores
	Private _lCtrlCom	:= .F.	//Complemento
	Private _lTipNfNB	:= .F.	//Valida se é nota do tipo normal ou beneficiamento
	Private _lInctDAP	:= .F.	//Valida se entidade é de incentivo DAP
	Private _lCtrlN8K	:= .F.	//Valida se existe vinculo com as tabelas auxiliares de saída
    Private _cCliEntr   := ""
	Private _cLojEntr   := ""
    Private _cTipoEnt   := ''
	
	IF IsInCallStack('OGA250')
		cOrigem := 'OGA250'
	ElseIF IsInCallStack('OGA251')
		cOrigem := 'OGA251'
	ElseIf IsInCallStack('AGRA500')
		cOrigem := 'AGRA500'
	EndIF

	//--Posiciona na tabela NJJ conforme o Romaneio enviado para a função
	dbSelectArea("NJJ")
	NJJ->( dbSetOrder(1) )
	NJJ->( MsSeek(FWxFilial("NJJ")+cRomaneio) )

	cTransp    	:= NJJ->( NJJ_CODTRA )
	cPlaca		:= NJJ->( NJJ_PLACA  )

	//--Posiciona na tabela NJM com o Romaneio enviado por parametro (Romaneio estava se perdendo)
	dbSelectArea("NJM")
	NJM->( dbSetOrder(1) )
	NJM->( MsSeek(FWxFilial("NJM")+cRomaneio+cItRom) )

	dEmissao    := IIf( NJM->( NJM_TPFORM ) = "1", dDataBase, NJM->( NJM_DOCEMI ) )
	cFormulario := IIf( NJM->( NJM_TPFORM ) = "1", "S", "N" )
	cSerie      := NJM->( NJM_DOCSER )
	cNumero     := NJM->( NJM_DOCNUM )
	cCodDocC5	:= NJM->( NJM_CODROM )
	cLocal      := NJM->( NJM_LOCAL )
	//--Busca veiculo pelo indice 3 atraves da placa
	//--Apos, busca pelo indice 1 atraves do codigo do veiculo
	//--Realizada dessa forma, pois por algum motivo o pedido de venda estava apresentando inconsistencias.
	cVeic1      := Posicione( "DA3", 3, FWxFilial( "DA3" ) + cPlaca, "DA3_COD" )
	cVeic2		:= Posicione( "DA3", 1, FWxFilial( "DA3" ) + cVeic1, "DA3_COD" )

	If NJM->(ColumnPos('NJM_SUBTIP')) > 0
		If  NJM->(NJM_SUBTIP) != "46"  .AND.  NJM->(NJM_SUBTIP) != "45" // (S) VENDA A ORDEM
			//Retorna o Cliente ou Fornecedor de Entrega, conforme o tipo do movimento do romaneio
			aRetClFr    := OGA250ClFr( NJJ->( NJJ_ENTENT ), NJJ->( NJJ_ENTLOJ ), NJM->( NJM_TES ), NJM->( NJM_TIPO ), NJM->( NJM_QTDFIS ), NJJ->NJJ_FILIAL )
			_cCliEntr    := aRetClFr[2]
			_cLojEntr    := aRetClFr[3]
			_cTipoEnt    := aRetClFr[4]
		EndIf
	Else
		//Retorna o Cliente ou Fornecedor de Entrega, conforme o tipo do movimento do romaneio
		aRetClFr    := OGA250ClFr( NJJ->( NJJ_ENTENT ), NJJ->( NJJ_ENTLOJ ), NJM->( NJM_TES ), NJM->( NJM_TIPO ), NJM->( NJM_QTDFIS ), NJJ->NJJ_FILIAL )
		_cCliEntr    := aRetClFr[2]
		_cLojEntr    := aRetClFr[3]
		_cTipoEnt    := aRetClFr[4]
	EndIf

	//--Tabela de Contratos
	dbSelectArea( "NJR" )
	NJR->( dbSetOrder( 1 ) )
	If NJR->( MsSeek( FWxFilial( "NJR" ) + NJM->( NJM_CODCTR ) ) )

		//removida esta regra para tratar por fardos ou granel, caso seja granel será sempre 1 fixo
		//caso seja algodão a query na N9D irá retornar a quantidade de  fardos e ajustará os volumes
		//de forma automática.
		//aAdd( aVolume , (NJM->( NJM_QTDFIS ) / 60 ) ) //Dividido por 60kg a sacas para não dar erro no volume, pois a quantidade é de 5 Caracter

		//se for algodão
		If AGRTPALGOD(NJM->NJM_CODPRO)

			IF NJJ->NJJ_PESEMB == 0
				nQuantEmb := 1  //Quando não tem fardos, gravar quantidade 1 - DAGROGAP-4086
			Else
				//Verifica movimento dos fardos do romaneio para identificar a qtde de fardos
				cAliasQry := GetNextAlias()
				cQry := " SELECT COUNT(N9D_FARDO) AS QTD "
				cQry += " FROM " + RetSqlName("N9D") + " N9D "
				cQry += " WHERE N9D.N9D_FILORG = '" + NJJ->NJJ_FILIAL + "' "
				cQry += "   AND N9D.N9D_CODROM = '" + NJJ->NJJ_CODROM + "' "
				cQry += "   AND N9D.N9D_TIPMOV = '07' "
				cQry += "   AND N9D.N9D_STATUS = '2' "
				cQry += "   AND N9D.D_E_L_E_T_ = '' "

				cQry := ChangeQuery( cQry )

				dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

				dbSelectArea(cAliasQry)
				(cAliasQry)->(DbGoTop())
				If (cAliasQry)->(!Eof())
					nQuantEmb := (cAliasQry)->QTD
				EndIf
				(cAliasQry)->(DbCloseArea())
			EndIf

			//tratado para não incluir zero
			If nQuantEmb > 0
				aAdd( aVolume , nQuantEmb )
			EndIf
		Else
			aAdd( aVolume , 1 ) //fixo 1
		EndIf

		If .Not. Empty( NJR->( NJR_TIPEMB ) )
			aAdd( aEspecie, NJR->( NJR_TIPEMB ) )
		EndIf
	EndIf

	//--Tabela de Entidades
	dbSelectArea( "NJ0" )
	NJ0->( dbSetOrder( 1 ) )
	NJ0->( MsSeek( FWxFilial( "NJ0" ) + NJM->( NJM_CODENT + NJM_LOJENT ) ) )
	_cInDap  := NJ0->( NJ0_ITVDAP )
	dVcntDAP := NJ0->( NJ0_DTVDAP )

	//-- NJM_TIPMOV - Tipo de Movimentação - 1=Fisica;2=Financeira
	If NJM->( NJM_TIPMOV ) = '1'	//1=Fisica
		//--Tipo de Movimento igual a 2=Financeira
		//--Romaneio igual ao posicionado
		//--Contrato do romaneio
		cQNFREF1 := " SELECT * "
		cQNFREF1 +=   " FROM "+RetSqlName("NJM")+" NJM "
		cQNFREF1 +=  " WHERE NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"'"
		cQNFREF1 +=    " AND NJM.NJM_CODROM = '"+ cRomaneio + "'"
		cQNFREF1 +=    " AND NJM.NJM_TIPMOV = '2' "	//2=Financeira
		cQNFREF1 +=    " AND NJM.NJM_CODCTR = '" + NJM->( NJM_CODCTR ) + "' "
		cQNFREF1 +=    " AND NJM.D_E_L_E_T_ = '' "

		cQNFREF1 := ChangeQuery(cQNFREF1 )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQNFREF1),(cAliasREF1),.F.,.T.)

		dbSelectArea((cAliasREF1))
		((cAliasREF1))->( dbGoTop() )
		If (cAliasREF1)->( Eof() )
			(cAliasREF1)->( dbCloseArea() )

			//--Tipo de Movimento igual a 2=
			//--Romaneio igual ao posicionado
			//--Contrato do romaneio
			cQNFREF2 := " SELECT * "
			cQNFREF2 +=   " FROM "+RetSqlName("NJM")+" NJM "
			cQNFREF2 +=  " WHERE NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"'"
			cQNFREF2 +=    " AND NJM.NJM_CODROM <>'"+ cRomaneio + "'"
			cQNFREF2 +=    " AND NJM.NJM_TIPMOV = '2' "	//2=Financeira
			cQNFREF2 +=    " AND NJM.NJM_CODCTR = '" + NJM->( NJM_CODCTR ) + "' "
			cQNFREF2 +=    " AND NJM.D_E_L_E_T_ = '' "
			cQNFREF2 := ChangeQuery(cQNFREF2)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQNFREF2),(cAliasREF2),.F.,.T.)

			lOperTri := .F.
		EndIf

		dbSelectArea((cAliasREF2))
		((cAliasREF2))->( dbGoTop() )
		While ((cAliasREF2))->( .NOT. Eof() )
			If (cAliasREF2)->NJM_DOCSER + (cAliasREF2)->NJM_DOCNUM != " "
				_cObs   := "Ref. NF " + (cAliasREF2)->NJM_DOCSER + " - " + (cAliasREF2)->NJM_DOCNUM
			EndIf
			(cAliasREF2)->( dbSkip() )
		EndDo
		(cAliasREF2)->( dbCloseArea() )

		IF _cObs != ""
			IF lOperTri
				_cObs   += ". "
			Else
				_cObs   += ", " + AllTrim( Posicione( "SA1", 1, FWxFilial( "SA1" ) + NJ0->( NJ0_CODCLI ) + NJ0->( NJ0_LOJCLI ), "A1_NOME" )) + ", CNPJ " + AllTrim(Posicione( "SA1", 1, FWxFilial( "SA1" ) + NJ0->( NJ0_CODCLI ) + NJ0->( NJ0_LOJCLI ), "A1_CGC" )) + ". "
			Endif
		EndIf

	EndIf //Fim - NJM->( NJM_TIPMOV ) = '1'

	//-- Se formulario proprio é igual a Sim e Série estiver vazia
	If cFormulario == "S" .and. Empty(cSerie)
		//--Busca serie de nota de Saida  *Parametro*
		cSerie   := SuperGetMV("MV_OGASERS")
	EndIf

	//--Caso a tabela temporaria esteja habilitada
	If Select((cAliasNJM)) > 0
		//--Fecha
		((cAliasNJM))->( dbCloseArea() )
	EndIf

	//--Agrupa para geração do Pedido de Venda e Documento de compra
	cQueryNJM := " SELECT * "
	cQueryNJM +=   " FROM "+RetSqlName("NJM")+" NJM "
	cQueryNJM +=  " WHERE NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"'"
	cQueryNJM +=    " AND NJM.NJM_CODROM = '"+ cRomaneio + "'"
	cQueryNJM +=    " AND NJM.NJM_CODENT = '"+ NJM->( NJM_CODENT ) +"'"
	cQueryNJM +=    " AND NJM.NJM_LOJENT = '"+ NJM->( NJM_LOJENT ) +"'"
	cQueryNJM +=    " AND NJM.NJM_DOCNUM = '"+ NJM->( NJM_DOCNUM ) +"'"
	cQueryNJM +=    " AND NJM.NJM_DOCSER = '"+ NJM->( NJM_DOCSER ) +"'"
	cQueryNJM +=    " AND NJM.NJM_TIPMOV = '"+ NJM->( NJM_TIPMOV ) +"'"
	cQueryNJM +=    " AND NJM.NJM_CODCTR = '"+ NJM->( NJM_CODCTR ) +"'"

	If NJM->(ColumnPos('NJM_ITEM')) > 0 ;
		.AND. NJM->(ColumnPos('NJM_SEQPRI')) > 0;
		.AND. NJM->(ColumnPos('NJM_NUMAVI')) > 0;
		.AND. NJM->(ColumnPos('NJM_NUMDCO')) > 0;
		.AND. NJM->(ColumnPos('NJM_SEQDCO')) > 0;
		.AND. NJM->(ColumnPos('NJM_SUBTIP')) > 0

		cQueryNJM +=    " AND NJM.NJM_ITEM 	 = '"+ NJM->( NJM_ITEM ) +"'"
		cQueryNJM +=    " AND NJM.NJM_SEQPRI = '"+ NJM->( NJM_SEQPRI ) +"'"
		cQueryNJM +=    " AND NJM.NJM_SUBTIP = '"+ NJM->( NJM_SUBTIP ) +"'"
		cQueryNJM +=    " AND NJM.NJM_NUMAVI = '"+ NJM->(NJM_NUMAVI) + "' "
		cQueryNJM +=    " AND NJM.NJM_NUMDCO = '"+ NJM->(NJM_NUMDCO) + "' "
		cQueryNJM +=    " AND NJM.NJM_SEQDCO = '"+ NJM->(NJM_SEQDCO) + "' "
	Else
		cQueryNJM +=    " AND NJM.NJM_ITEROM = '"+ NJM->( NJM_ITEROM ) +"'"
	EndIf

	If NJM->(fieldPos("NJM_INDPRE")) > 0 .AND. !EMPTY(NJM->( NJM_INDPRE)) //SE CAMPO EXISTIR FILTRA PARA QUEBRA
		cQueryNJM +=    " AND NJM.NJM_INDPRE = '"+ NJM->( NJM_INDPRE) +"' " //Presença Comprador (NT 2020.006)
		cQueryNJM +=    " AND NJM.NJM_CODA1U = '"+ NJM->( NJM_CODA1U) +"' " //codigo Intermediador (NT 2020.006)
	EndIf

	If lQrbPrc
		cQueryNJM += " AND NJM.NJM_VLRUNI = '"+ cValToChar(NJM->(NJM_VLRUNI)) +"'"
	EndIf

	cQueryNJM +=    " AND NJM.NJM_STAFIS = '1' "
	cQueryNJM +=    " AND NJM.D_E_L_E_T_ = '' "
	cQueryNJM +=  " ORDER BY NJM_ITEROM "

	cQueryNJM := ChangeQuery(cQueryNJM)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryNJM),(cAliasNJM),.F.,.T.)

	dbSelectArea((cAliasNJM))
	((cAliasNJM))->( dbGoTop() )
	While ((cAliasNJM))->( .NOT. Eof() )

		//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
		aRetClFr    := OGA250ClFr( (cAliasNJM)->( NJM_CODENT ), (cAliasNJM)->( NJM_LOJENT ), (cAliasNJM)->( NJM_TES ), (cAliasNJM)->( NJM_TIPO ), (cAliasNJM)->( NJM_QTDFIS ), NJJ->NJJ_FILIAL )
		cTipo       := aRetClFr[ 1 ]
		cCliente    := aRetClFr[ 2 ]
		cLoja       := aRetClFr[ 3 ]
		_cTipoEnt	:= aRetClFr[ 4 ]

		If Empty(cCliente) .OR. Empty(cLoja)
			Help( ,, STR0028,, STR0029, 1, 0) //'Erro'###"Cliente e Loja da Entidade não pode ser branco."
			RestArea( aAreaAtu )
			Exit
			Return .F.
		EndIf

		cProduto    := (cAliasNJM)->( NJM_CODPRO )
		cTes        := (cAliasNJM)->( NJM_TES )
		nPSLiq      += (NJJ->( NJJ_PSLIQU ) * (cAliasNJM)->( NJM_PERDIV ) / 100)
		nPSSubt     += (NJJ->( NJJ_PSSUBT ) * (cAliasNJM)->( NJM_PERDIV ) / 100)
		nQuant      := (cAliasNJM)->( NJM_QTDFIS )
		nPreco      := A410Arred( (cAliasNJM)->( NJM_VLRUNI ), "NJM_VLRUNI" )
		nTotal      := A410Arred( nQuant * nPreco, "C6_VALOR" )
		cCodCtr     := (cAliasNJM)->( NJM_CODCTR )
		cCodDocC6   := (cAliasNJM)->( NJM_CODROM )
		cIteDocC6   := (cAliasNJM)->( NJM_ITEROM )
		cCodSaf     := (cAliasNJM)->( NJM_CODSAF )
		cLoteCtl    := (cAliasNJM)->( NJM_LOTCTL )
		
		If NJM->(fieldPos("NJM_INDPRE")) > 0 .AND. !EMPTY((cAliasNJM)->( NJM_INDPRE )) //SE CAMPO EXISTIR E COM VALOR
			cC5INDPRES 	:= (cAliasNJM)->( NJM_INDPRE ) //Presença Comprador (NT 2020.006)
			cC5CODA1U	:= (cAliasNJM)->( NJM_CODA1U ) //codigo Intermediador (NT 2020.006)
		EndIf

		If __lnewNeg .AND. 	NJM->(ColumnPos('NJM_CLVL')) > 0
			cClassVlr   := (cAliasNJM)->( NJM_CLVL)
		Else
			cClassVlr   := " "
		EndIF

		cHist := Alltrim(Posicione("SX5",1,FWxFilial("SX5")+'K5'+(cAliasNJM)->( NJM_TIPO ),"X5_DESCRI"))

		//-- Tratando Frete, Seguro e Despesas --//
		IF NJM->( FieldPos("NJM_FRETE") ) > 0
			nFrete      += (cAliasNJM)->NJM_FRETE
			nSeguro 	+= (cAliasNJM)->NJM_SEGURO
			nDespesa    += (cAliasNJM)->NJM_DESPES
		EndIF

		//-- Tratando Mensagem da NF --//
		IF Empty( Alltrim((cAliasNJM)->NJM_MSGNFS) ) //-- não existe mensagem no romaneio --//
			cMsgNfAux += " " + Alltrim( POSICIONE("NJR", 1, FWxFilial("NJR") + cCodCTR, "NJR_MSGNFS" ) )    //-- Buscando mensagem do Contrato -- //
		Else
			cMsgNfAux += " " + Alltrim( (cAliasNJM)->NJM_MSGNFS )
		EndIF
		//-- Tratando Mensagem da NF --//

		//-- Natureza Financeira --//
		cNatuFin := " "

		If __lnewNeg .AND. NJM->(ColumnPos('NJM_ITEM')) > 0;
		.AND. NJM->(ColumnPos('NJM_SEQPRI')) > 0 ;
		.AND. NJM->(ColumnPos('NJM_FILORG')) > 0

			cNatuFin := Posicione("N9A",1,(cAliasNJM)->(NJM_FILORG + NJM_CODCTR + NJM_ITEM + NJM_SEQPRI),"N9A_NATURE")
		EndIf
		//se nao encontrar a natureza na regra fiscal entao utiliza do cliente
		If Empty(cNatuFin)
			If _cTipoEnt == "SA1"
				cNatuFin := Posicione("SA1",1,FwXFilial("SA1")+cCliente+cLoja,"A1_NATUREZ")
			Else
				cNatuFin := Posicione("SA2",1,FwXFilial("SA2")+cCliente+cLoja,"A2_NATUREZ")
			EndIf
		EndIf

		//-- Natureza Financeira --//

		//Para remessa de venda futura e operacaao triangular
		If __lnewNeg
			cOpeFis := IIf((cAliasNJM)->NJM_SUBTIP $ '44|46|', '', (cAliasNJM)->NJM_OPEFIS)

			/* *********************************************************************************  */
			dbSelectArea( "N9E" )
			N9E->( dbSetOrder( 1 ) )
			N9E->( MsSeek( FWxFilial( "N9E" ) + NJM->( NJM_CODROM ) ) )
			cCodIne := N9E->( N9E_CODINE )
			cFilIE  := N9E->( N9E_FILIE )

			cDesIne :=  Posicione("N7Q",1,cFilIE+cCodIne,"N7Q_DESINE")

			/* *********************************************************************************  */
		Else
			cDesIne := " "
			cCodIne := " "
			cFilIE  := " "
			cOpeFis := " "
		EndIf

		//-- Tabela de Tipos de Entrada e Saída
		dbSelectArea( "SF4" )
		SF4->( dbSetOrder( 1 ) )
		SF4->( MsSeek( FWxFilial( "SF4" ) + NJM->( NJM_TES )))

		//Caso seja uma transferência entre filiais, desconsidera o preenchimento da aLinha
		If lTrfSld

			aItens := aClone(_aLinha)
			//aAdd( aItens, aLinha )

			//-- Para romaneios do tipo 6-Dev. Deposito ou 8-Dev. Compra
			//-- Com notas do tipo N-Normal D-Devolução
		elseIf NJM->( NJM_TIPO ) $ "6|8" .And. cTipo $ "N|D"
			nRecno := NJM->( Recno() )
			//--Se a quantidade [NJM_QTDFIS]  for diferente de Zero
			If nQuant <> 0
				//--Se a TES controla poder de terceiro R=Remessa;D=Devolucao;N=Nao Controla
				If SF4->( F4_PODER3 ) $ "DR"
					//--Indica que controla terceiros
					_lNFOrigem 	:= .T.
					_lCtrlTer 	:= .T.
					aSelNfs 	:= SelNfs( cRomaneio, cCodCtr, nQuant, cProduto, NJM->( NJM_TIPO ), NJJ->( NJJ_TIPENT ), cLoteCtl )

					If Len( aSelNfs ) <= 0 .And. _lNFOrigem
						Help( , , STR0001, , STR0002, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
						(cAliasNJM)->(dbCloseArea())
						RestArea( aAreaAtu )
						Return( .F. )
					EndIf
					//--Não controla poder em terceiros
				Else
					//--Indica que controla devolução quantidade
					_lNFOrigem 	:= .T.
					_lCtrlDev 	:= .T.
					aSelNfs 	:= SelNfs( cRomaneio, cCodCtr, nQuant, cProduto, '', '', cLoteCtl )

					If Len( aSelNfs ) <= 0 .And. _lNFOrigem
						Help( , , STR0001, , STR0002, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
						(cAliasNJM)->(dbCloseArea())
						RestArea( aAreaAtu )
						Return( .F. )
					
					EndIf
				EndIf

				If Len( aSelNfs ) <= 0 .AND. !_lNFOrigem .AND. (cAliasNJM)->NJM_TIPO = "8" .AND. !Empty(cLoteCtl) //DEVOLUÇÃO DE COMPRA COM LOTE
					//trata quando não encontra documento fiscal para o contrato e lote informado no romaneio de devolução de compra
					Agrhelp(STR0001,STR0052 + cCodCtr + STR0053 + cLoteCtl + STR0054 , STR0055) //##Não foi encontrado documento de origem para o contrato xxxx e lote yyyy.  ###Reabra o romaneio e ajuste a informação do campo lote. Para a devolução, o lote deve ser o mesmo informado nos documentos de entrada do contrato.
					(cAliasNJM)->(dbCloseArea())
					RestArea( aAreaAtu )
					Return( .F. )
				EndIf

				dbSelectArea('NJM')
				NJM->( dbGoTo(nRecno) )
				//--Senão, Se a quantidade [NJM_QTDFIS]  for igual a Zero
			Else
				//--Indica que controla devolução de valor
				_lNFOrigem 	:= .T.
				_lCtrlDVl 	:= .T.
				aSelNfs 	:= SelNfs( cRomaneio, cCodCtr, (cAliasNJM)->( NJM_VLRTOT ), cProduto, '', '',cLoteCtl )

				If Len( aSelNfs ) <= 0 .And. _lNFOrigem
					Help( , , STR0001, , STR0002, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
					(cAliasNJM)->(dbCloseArea())
					RestArea( aAreaAtu )
					Return( .F. )
				EndIf

			EndIf
		ElseIf cTipo $ "C"
			_lNFOrigem 	:= .T.
			_lCtrlCom 	:= .T.
			aSelNfs 	:= SelNfs( cRomaneio, cCodCtr, Nil , cProduto, '', '', cLoteCtl )

			nQuant  	:= 0

			If Len( aSelNfs ) <= 0 .And. _lNFOrigem
				Help( , , STR0001, , STR0002, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
				(cAliasNJM)->(dbCloseArea())
				RestArea( aAreaAtu )
				Return( .F. )
			EndIf

		EndIf

		//--Item sequencial
		cItemSeq := Soma1(cItemSeq)

		//--Verifica se o array aSelNfs é maior que zero, caso sim o For percorre o tamanho do array, caso contrario percorre somente uma vez.
		If !lTrfSld
			For nX := 1 to If(Len( aSelNfs ) > 0, Len( aSelNfs ), 1)
				If nX > 1
					cItemSeq := Soma1(cItemSeq)
				EndIf

				//-- Se encontrou a NF
				If _lNFOrigem
					//-- Se array for maior que zero
					If Len( aSelNfs ) > 0
						//--Indica que controla devolução de valor
						If  _lCtrlDVl
							nQuant      := 1
							nPreco      := aSelNfs[ nX, COL_VDISTR   ]
							nTotal      := A410Arred( aSelNfs[ nX, COL_VDISTR  ] , "C6_VALOR" )
						EndIf

						//--Indica que controla terceiros _OU_ devolução de quantidade
						If _lCtrlTer .OR. _lCtrlDev 
							nQuant      := aSelNfs[ nX, COL_DISTRIB ]
							nPreco      := aSelNfs[ nX, COL_VUNIT   ]
							nTotal      := A410Arred( aSelNfs[ nX, COL_VDISTR  ] , "C6_VALOR" )
							cIdentB6    := aSelNfs[ nX, COL_IDENTB6 ]
						EndIf

						//--Indica que controla complemento
						If _lCtrlCom
							nQuant   := 0

							nVTotalY := (cAliasNJM)->( NJM_VLRTOT )
							nVTotalX := (cAliasNJM)->( NJM_VLRTOT )
							For nX := 1 to Len( aSelNfs )
								nQTotalX += aSelNfs[ nX, COL_QUANT  ]
								nVTotalX += aSelNfs[ nX, COL_VTOTAL ]
							Next nX
							nVUnitX := Round( ( nVTotalX / nQTotalX ), TamSX3( "C6_PRCVEN" )[2] )

							nPreco  := ( ( aSelNfs[ nX, COL_QUANT ] * nVUnitX ) - aSelNfs[ nX, COL_VTOTAL ] )
							nTotal  := A410Arred( ( ( aSelNfs[ nX, COL_QUANT ] * nVUnitX ) - aSelNfs[ nX, COL_VTOTAL ] ), "C6_VALOR" )

							If nX = Len( aSelNfs )
								nPreco := Round( nVTotalY, TamSX3( "C6_VALOR" )[2] )
								nTotal := A410Arred( nVTotalY, "C6_VALOR" )
							Else
								nVTotalY -= nTotal
							EndIf

						EndIf	//If _lCtrlCom
	
						//--Variaveis das notas fiscais de origem
						cNfOri      := aSelNfs[ nX, COL_DOC     ]
						cSeriOri    := aSelNfs[ nX, COL_SERIE   ]
						cItemOri    := aSelNfs[ nX, COL_ITEM    ]

						If NJM->( NJM_TIPO ) $ "6|8" .and. aSelNfs[ nX, COL_DISTRIB ] = aSelNfs[ nX, COL_SALDO ]  
						//Esta devolvendo todo/restante da quantidade da NF
							nTotal := fTotaltNota( aSelNfs, nX  )
						EndIf

					EndIf //If Len( aSelNfs ) > 0

					//--Se não tiver nota fiscal
				Else
					//--Indica que controla devolução de valor
					If _lCtrlDVl
						nQuant  := 1
						//--Indica que controla complemento
					ElseIf _lCtrlCom
						nQuant  := 0
					EndIf

					//--Para os controles de devolução ou complemento o tipo é igual a N
					//--quando não há Origem
					If _lCtrlTer .OR. _lCtrlDev .OR. _lCtrlDVl .OR. _lCtrlCom
						cTipo       := "N"
					EndIF

					nTotal      := A410Arred( nQuant * nPreco, "C6_VALOR" )

				EndIf	//If _lNFOrigem

				//--Para quando DIFERENTE de Paraguai
				If cPaisLoc <> "PAR" //PAR - Paraguai
					//Alimentado o array para pedidos
					aLinha := {}

					If AGRTPALGOD(cProduto) //se produto algodão
						If (cAliasNJM)->NJM_SUBTIP == "49" // (S) SAIDA POR VENDA EXCEDENTE
							lExced := .T.
						EndIf
						cIteRom   := (cAliasNJM)->( NJM_ITEROM )

						If (cAliasNJM)->NJM_SUBTIP == "46" // (S) REMESSA POR VENDA A ORDEM

							//Encontra o item de venda correspondente, para localizar os fardos
							cAliIteRom := GetNextAlias()
							cQryIteRom := " SELECT COUNT(NJM_ITEROM) / 2 AS QTDNJM "
							cQryIteRom +=   " FROM "+RetSqlName("NJM")+" NJM "
							cQryIteRom +=  " WHERE NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"'"
							cQryIteRom +=    " AND NJM.NJM_CODROM = '"+ cRomaneio + "'"
							cQryIteRom +=    " AND NJM.D_E_L_E_T_ = '' "

							cQryIteRom := ChangeQuery(cQryIteRom )
							dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryIteRom),(cAliIteRom),.F.,.T.)

							dbSelectArea((cAliIteRom))
							((cAliIteRom))->( dbGoTop() )
							IF ((cAliIteRom))->( .NOT. Eof() )
								nAux      := Val((cAliasNJM)->NJM_ITEROM ) - (cAliIteRom)->QTDNJM
								cIteRom   := IIf( nAux > 0, STRZERO( nAux ,TamSX3("NJM_ITEROM")[1]), (cAliasNJM)->NJM_ITEROM )
							EndIf
							(cAliIteRom)->( dbCloseArea() )
						EndIF

						lCtlLote := Posicione("SB1", 1, FwXFilial("SB1")+N7Q->N7Q_CODPRO, "B1_RASTRO") <> "N" .And. lRastro //se controla lote produto algodão
						aItemAlg := OGX008BGFR( 1, NJJ->NJJ_FILIAL, cRomaneio, cIteRom , lExced, lCtlLote , cTes )
						//busca quebra dos itens dos fardos de algodão para quebra SC6
					EndIf

					For nY := 1 to If(Len( aItemAlg ) > 0, Len( aItemAlg ), 1)
						If nY > 1
							cItemSeq := Soma1(cItemSeq)
						EndIf

						If Len( aItemAlg ) > 0 //se tem quebra dos itens de fardos de algodão
							aLinha := {}
							cLoteCtl  := aItemAlg[nY][2] //Lote do item
							nQuant    := aItemAlg[nY][6] //Quantidade do item
							nPreco    := A410Arred( aItemAlg[nY][3], "NJM_VLRUNI" ) //Preço do item
							nTotal    := A410Arred( nQuant * nPreco, "C6_VALOR" ) //valor total do item
							cTipProd  := aItemAlg[nY][1] //tipo do produto do item
						EndIf
						If __lnewNeg
							//Se for Venda Entrega Futura
							If (cAliasNJM)->(NJM_SUBTIP) == '43' .AND. (cAliasNJM)->(ColumnPos('NJM_NUMAVI')) > 0 
								cNumAvi := (cAliasNJM)->(NJM_NUMAVI)
								cNumDco := (cAliasNJM)->(NJM_NUMDCO)
								cSeqDco := (cAliasNJM)->(NJM_SEQDCO)
								cTpAvis := ""
								cObserv := getObsInd(cNumAvi, cCliente, cLoja, cTpAvis )
							ElseIf (cAliasNJM)->(NJM_SUBTIP) == '21'
								If Len( aItemAlg ) > 0
									If aItemAlg[nY][7] = '1'
										//ler todas as regras fiscais dos fardos da ie de venda quebrar e acumular pepro
										aRfVenda := OG250GRFD(cRomaneio,cCliente,cLoja,aRecVenda)
										For nX := 1 to Len(aRfVenda)
											if !Empty(aRfVenda[nX][2])
												If  nX == 1
													cNumAvi := aRfVenda[nX][1]
													cNumDco := aRfVenda[nX][2]
													cSeqDco := aRfVenda[nX][3]
													cTpAvis := aRfVenda[nX][4]
													cObserv := aRfVenda[nX][5]
												Else
													cNumAvi += '/' + aRfVenda[nX][1]
													cNumDco += '/' + aRfVenda[nX][2]
													cSeqDco += '/' + aRfVenda[nX][3]
													cTpAvis += '/' + aRfVenda[nX][4]
													cObserv += '/' + aRfVenda[nX][5]
												EndIF
											EndIF
										Next nX
									EndIF
								EndIF
							ElseIf (cAliasNJM)->(ColumnPos('NJM_NUMAVI')) > 0 
									cNumAvi := (cAliasNJM)->(NJM_NUMAVI)
									cNumDco := (cAliasNJM)->(NJM_NUMDCO)
									cSeqDco := (cAliasNJM)->(NJM_SEQDCO)
									cTpAvis := ""
									cObserv := getObsInd(cNumAvi, cCliente, cLoja, cTpAvis )
							EndIf
						EndIf

						If __lnewNeg .AND. (cAliasNJM)->(NJM_SUBTIP) == '44' //44=(S)Remessa por venda futura
							//quando remessa por venda futura será adicionado na NF de origem a NF da venda futura
							DBSelectArea('N9A')
							N9A->(DBSetOrder(1))
							If N9A->(dbSeek(FWxFilial("N9A")+(cAliasNJM)->(NJM_CODCTR)+(cAliasNJM)->(NJM_ITEM)+(cAliasNJM)->(NJM_SEQPRI)))
								If N9A->N9A_OPEFUT = '1' //operação futura
									aNFSVnd := NFSNJMSD2( N9A->N9A_CODROM,'', '43') //busca NF da Venda 43=(S)Venda Entrega Futura
									If Len(aNFSVnd) > 0
										cNfOri      := aNFSVnd[1]
										cSeriOri    := aNFSVnd[2]
										cItemOri    := aNFSVnd[3]
									EndIf
								EndIf
							EndIf
						ElseIf (cAliasNJM)->(NJM_SUBTIP) == '45' //45 = (S)venda a ordem
							//quando venda a ordem, será adicionado na NF de origem a NF da remessa venda a ordem, a remessa é transmitida antes da venda
							aNFSVnd := NFSNJMSD2( cRomaneio,'', '46') //busca NF de venda 46=(S)Remessa venda a Ordem
							If Len(aNFSVnd) > 0
								cNfOri      := aNFSVnd[1]
								cSeriOri    := aNFSVnd[2]
								cItemOri    := aNFSVnd[3]
							EndIf
						EndIf

						aAdd( aLinha, { "C6_ITEM"       , cItemSeq      , Nil } )
						aAdd( aLinha, { "C6_PRODUTO"    , cProduto      , Nil } )
						aAdd( aLinha, { "C6_TES"        , cTes          , Nil } )
						If !Empty(cOpeFis)
							aAdd( aLinha, { "C6_OPER"       , cOpeFis       , Nil } )
						EndIf

						If !Empty(cDesIne)
							aAdd( aLinha, { "C6_NUMPCOM", Left(cDesIne,15)   , Nil } )
						EndIf

						//--Indica que controla terceiros _OU_ devolução de quantidade
						If _lCtrlTer .OR. _lCtrlDev
							aAdd( aLinha, { "C6_IDENTB6"    , cIdentB6  , Nil } )
						EndIf

						If ( _lNFOrigem .AND. Len( aSelNfs ) > 0 ) .OR. ( Len(aNFSVnd) > 0 )
							aAdd( aLinha, { "C6_NFORI"      , cNfOri    , Nil } )
							aAdd( aLinha, { "C6_SERIORI"    , cSeriOri  , Nil } )
							aAdd( aLinha, { "C6_ITEMORI"    , cItemOri  , Nil } )
						EndIF

						//--Indica que NÃO controla complemento
						If .NOT. _lCtrlCom
							aAdd( aLinha, { "C6_QTDVEN"     , nQuant    , Nil } )
							aAdd( aLinha, { "C6_QTDLIB"     , nQuant    , Nil } )
						EndIf

						aAdd( aLinha, { "C6_PRCVEN"     , nPreco        , "alwaystrue()" } )
						aAdd( aLinha, { "C6_VALOR"      , nTotal        , Nil } )
						aAdd( aLinha, { "C6_LOCAL"      , cLocal        , Nil } )
						if !EMPTY(cClassVlr)
							aAdd( aLinha, { "C6_CLVL"       , cClassVlr     , Nil } )
						endIf

						if 	!Empty(cLoteCtl)
							aAdd( aLinha, { "C6_LOTECTL", cLoteCtl      , Nil } )
						endIf

						// Ponto de entrada inserido para controlar dados especificos do cliente no item do pedido de venda 19/03/2019
						If ExistBlock("OGX008IT")
							aRetPe := ExecBlock("OGX008IT",.F.,.F.,{ cAliasNJM ,aLinha, ((cAliasNJM)->NJM_SUBTIP $ '44|46|') })
							If ValType(aRetPe) == "A" .And. Len(aRetPe) >= 1 //Verifica se o retorno é um array e sem linha
								aLinha := aRetPe
							EndIf
						EndIf

						If .NOT. __lnewNeg
							aAdd( aLinha, { "C6_CTROG"      , cCodCtr       , Nil } )
							//aAdd( aLinha, { "C6_CODSAF"     , cCodSaf       , "alwaystrue()" } )
							aAdd( aLinha, { "C6_CODROM"     , cCodDocC6     , Nil } )
							aAdd( aLinha, { "C6_ITEROM"     , cIteDocC6     , Nil } )
						EndIf

						//Criando Vinculo com SC5 / SC6
						aLinhaVinc := {}
						aadd( aLinhaVinc, { "N8I_FILIAL"	, FwXfilial('N8I') 	} )
						aadd( aLinhaVinc, { "N8I_ITEMPV"   	, cItemSeq 			} )
						aadd( aLinhaVinc, { "N8I_PRODUT"   	, cProduto 			} )
						aadd( aLinhaVinc, { "N8I_TPPROD"   	, cTipProd		 	} )
						aadd( aLinhaVinc, { "N8I_CODCTR"   	, cCodCtr			} )
						aadd( aLinhaVinc, { "N8I_SAFRA"  	, cCodSaf 			} )
						aadd( aLinhaVinc, { "N8I_CODROM"   	, cCodDocC6			} )
						aadd( aLinhaVinc, { "N8I_ITEROM"   	, cIteDocC6			} )
						aadd( aLinhaVinc, { "N8I_CODOTR" 	, ''				} )
						aadd( aLinhaVinc, { "N8I_ITEOTR" 	, ''				} )
						aadd( aLinhaVinc, { "N8I_CODFIX"  	, ''				} )
						aadd( aLinhaVinc, { "N8I_ORIGEM"   	, cOrigem		 	} )
						aAdd( aLinhaVinc, { "N8I_HISTOR"   	, cHist				} )

						//Iens do Aviso PEPRO
						aAdd( aLinhaVinc, { "N8I_NUMAVI"   	, cNumAvi    		} )
						aAdd( aLinhaVinc, { "N8I_NUMDCO"   	, cNumDco    		} )
						aAdd( aLinhaVinc, { "N8I_SEQDCO"   	, cSeqDco			} )
						aAdd( aLinhaVinc, { "N8I_TPAVIS"   	, cTpAvis			} )
						aAdd( aLinhaVinc, { "N8I_OBSERV"   	, cObserv			} )

						nTotPed += nTotal
						aAdd( aVincITE, aLinhaVinc )
						aAdd( aItens,   aLinha )

					Next nY
					
				Else
					//--Para quando for IGUAl a Paraguai
					//Alimentado o array para nota fiscal de saída
					aLinha := {}
					aAdd( aLinha, { "D2_ITEM"       , cItemSeq      , Nil } ) //ok  AADD(aLinha,{"D2_ITEM"    ,StrZero( nItens, TamSX3( "D2_ITEM" )[1] ) ,NIL})
					aAdd( aLinha, { "D2_COD"        , cProduto      , Nil } ) //ok  AADD(aLinha,{"D2_COD"     ,NJM->NJM_CODPRO,NIL})
					aAdd( aLinha, { "D2_TES"        , cTes          , Nil } ) //ok AADD(aLinha,{"D2_TES"     ,NJM->NJM_TES   ,NIL})
					If _lNFOrigem
						aAdd( aLinha, { "D2_NFORI"      , cNfOri    , Nil } )
						aAdd( aLinha, { "D2_SERIORI"    , cSeriOri  , Nil } )
						aAdd( aLinha, { "D2_ITEMORI"    , cItemOri  , Nil } )
					EndIF
					aAdd( aLinha, { "D2_QUANT"      , nQuant        , Nil } ) //ok AADD(aLinha,{"D2_QUANT"   ,NJM->NJM_QTDFCO,NIL})
					aAdd( aLinha, { "D2_PRCVEN"     , nPreco        , Nil } ) //ok AADD(aLinha,{"D2_PRCVEN"  ,NJM->NJM_VLRUNI ,NIL})
					aAdd( aLinha, { "D2_TOTAL"      , nTotal        , Nil } ) //ok AADD(aLinha,{"D2_TOTAL"   ,NJM->NJM_VLRTOT ,NIL})
					aAdd( aLinha, { "D2_PESO"       , nPSLiq        , Nil } ) //ok AADD(aLinha,{"D2_PESO"    ,nPSLiq         ,NIL})
					aAdd( aLinha, { "D2_LOCAL"      , cLocal        , Nil } ) //ok AADD(aLinha,{"D2_LOCAL"   ,NJM->NJM_LOCAL ,NIL})

					aAdd( aLinha, { "D2_LOTECTL"    , cLoteCtl      , Nil } )
					
					If (cAliasNJM)->NJM_TIPO $ "6|8"
						aAdd( aLinha, { "D2_ESPECIE"    , 'RCD'  	    , Nil } ) 
					else
						AAdd( aLinha, { "D2_ESPECIE" 	, 'RFN'  	  	, Nil } ) //ok	
					EndIf

					aAdd( aLinha, { "D2_CLVL"       , cClassVlr     , Nil } )
					aAdd( aLinha, { "D2_UM"         , Posicione('SB1',1,FWxFilial('SB1')+cProduto,'B1_UM'), Nil } ) //ok AAdd(aLinha,{"D2_UM"      ,NJJ->NJJ_UM1PRO,Nil})

					//--Retirado conforme a tarefa DAGROCOM-1923
					//--Comentario para Historico - importante deixar
					////aAdd( aLinha, { "D2_CTROG"      , cCodCtr       , Nil } )
					////aAdd( aLinha, { "D2_CODSAF"     , cCodSaf       , Nil } )
					////aAdd( aLinha, { "D2_CODROM"     , cCodDocC6     , Nil } )
					////aAdd( aLinha, { "D2_ITEROM"     , cIteDocC6     , Nil } )

					nTotPed += nTotal
					aAdd( aItens,   aLinha )

				EndIf  //FIM - If cPaisLoc <> "PAR"

				//------------------
				//-- Para devoluções
				If _lCtrlTer .OR. _lCtrlDev .OR. _lCtrlDVl
					//-----------------------------------------------------------------------
					//--Caso possua um produto adicional, deve-se inserir o produto no array
					//-----------------------------------------------------------------------

					//--Tabela de Produtos adicionais
					dbSelectArea('NJV')
					NJV->( dbSetOrder( 1 ) )
					If NJV->( MsSeek( FWxFilial( "NJV" ) + cProduto ) )
						cItemSeq := Soma1(cItemSeq)

						//--Codigo Produto Adicional _E_ Tipo contém 8-Dev.de Compra _E_ Conter nota de origem
						If .NOT. Empty(NJV->( NJV_CODSPD )) .AND. NJM->( NJM_TIPO ) $ "8" .AND. _lNFOrigem
							cItemOri := NextNumero("SC6",1,"C6_ITEMORI",.T.,cItemOri)
							//--Tabela de Produtos
							dbSelectArea('SD1')
							SD1->( dbSetOrder( 1 ) )
							If SD1->( MsSeek( FWxFilial( "SD1" ) + cNfOri + cSeriOri + cCliente + cLoja + NJV->( NJV_CODSPD ) + cItemOri) )
								cProduto    := NJV->( NJV_CODSPD )
								nPreco      := A410Arred( SD1->( D1_VUNIT ), "C6_PRCVEN" )
								nTotal      := A410Arred( nQuant * nPreco, "C6_VALOR" )
								nTotPed 	+= nTotal
								_cITVDAP    := "1"
							EndIF
						EndIf

						//--Se entidade controla incentivo DAP _E_ a data de vencimento do DAP é maior ou igual a emissão
						//--Codigo Produto Adicional _E_ Tipo contém 8-Dev.de Compra
						If _cInDap == "1" .AND. dVcntDAP >= dEmissao .AND. .NOT. Empty(NJV->( NJV_CODSPD )) .AND. NJM->( NJM_TIPO ) $ "8"
							cProduto    := NJV->( NJV_CODSPD )
							nPreco      := A410Arred( NJV->( NJV_VALOR ), "C6_PRCVEN" )
							nTotal      := A410Arred( nQuant * nPreco, "C6_VALOR" )
							nTotPed 	+= nTotal
							_cITVDAP    := "1"
						EndIF

						//--Para quando DIFERENTE de Paraguai
						If cPaisLoc <> "PAR" //PAR - Paraguai
							//Alimentado o array para pedidos
							aLinha := {}
							aAdd( aLinha, { "C6_ITEM"       , cItemSeq      , Nil } )
							aAdd( aLinha, { "C6_PRODUTO"    , cProduto      , Nil } )

							If _lNFOrigem
								aAdd( aLinha, { "C6_NFORI"      , cNfOri        , Nil } )
								aAdd( aLinha, { "C6_SERIORI"    , cSeriOri      , Nil } )
								aAdd( aLinha, { "C6_ITEMORI"    , cItemOri      , Nil } )
							EndIf

							aAdd( aLinha, { "C6_QTDVEN"     , nQuant        , Nil } )
							aAdd( aLinha, { "C6_QTDLIB"     , nQuant        , Nil } )
							aAdd( aLinha, { "C6_PRCVEN"     , nPreco        , "alwaystrue()" } )
							aAdd( aLinha, { "C6_VALOR"      , nTotal        , Nil } )
							aAdd( aLinha, { "C6_TES"        , cTes          , Nil } )
							aAdd( aLinha, { "C6_OPER"       , cOpeFis       , Nil } )
							aAdd( aLinha, { "C6_LOCAL"      , cLocal        , Nil } )
							if !EMPTY(cClassVlr)
								aAdd( aLinha, { "C6_CLVL"       , cClassVlr     , Nil } )
							endIf
							aAdd( aLinha, { "C6_LOTECTL"    , cLoteCtl      , Nil } )

							// Ponto de entrada inserido para controlar dados especificos do cliente no item do pedido de venda 19/03/2019
							If ExistBlock("OGX008IT")
								aRetPe := ExecBlock("OGX008IT",.F.,.F.,{ cAliasNJM , aLinha, ((cAliasNJM)->NJM_SUBTIP $ '44|46|') })
								If ValType(aRetPe) == "A" .And. Len(aRetPe) >= 1 //Verifica se o retorno é um array e sem linha

									aLinha := aRetPe

								EndIf
							EndIf

							//Criando Vinculo com SC5 / SC6
							aLinhaVinc := {}
							aadd( aLinhaVinc, { "N8I_FILIAL"	, FwXfilial('N8I') 	} )
							aadd( aLinhaVinc, { "N8I_ITEMPV"   	, cItemSeq 			} )
							aadd( aLinhaVinc, { "N8I_PRODUT"   	, cProduto 			} )
							aadd( aLinhaVinc, { "N8I_TPPROD"   	, cTipProd		 	} )
							aadd( aLinhaVinc, { "N8I_CODCTR"   	, cCodCtr			} )
							aadd( aLinhaVinc, { "N8I_SAFRA"  	, cCodSaf 			} )
							aadd( aLinhaVinc, { "N8I_CODROM"   	, cCodDocC6			} )
							aadd( aLinhaVinc, { "N8I_ITEROM"   	, cIteDocC6			} )
							aadd( aLinhaVinc, { "N8I_CODOTR" 	, ''				} )
							aadd( aLinhaVinc, { "N8I_ITEOTR" 	, ''				} )
							aadd( aLinhaVinc, { "N8I_CODFIX"  	, ''				} )
							aadd( aLinhaVinc, { "N8I_ORIGEM"   	, cOrigem		 	} )
							aAdd( aLinhaVinc, { "N8I_HISTOR"   	, FWI18NLang("OGX008","STR0034",34)	} ) //'Produto Adicionai'

							//--Para quando for IGUAl a Paraguai
						Else
							//Alimentado o array para nota fiscal de saída
							aLinha := {}
							aAdd( aLinha, { "D2_ITEM"       , cItemSeq      , Nil } )
							aAdd( aLinha, { "D2_COD"        , cProduto      , Nil } )
							aAdd( aLinha, { "D2_TES"        , cTes          , Nil } )

							If _lNFOrigem
								aAdd( aLinha, { "D2_NFORI"      , cNfOri        , Nil } )
								aAdd( aLinha, { "D2_SERIORI"    , cSeriOri      , Nil } )
								aAdd( aLinha, { "D2_ITEMORI"    , cItemOri      , Nil } )
							EndIf

							aAdd( aLinha, { "D2_QUANT"      , nQuant        , Nil } )
							aAdd( aLinha, { "D2_PRCVEN"     , nPreco        , Nil } )
							aAdd( aLinha, { "D2_TOTAL"      , nTotal        , Nil } )
							aAdd( aLinha, { "D2_PESO"       , nPSLiq        , Nil } )
							aAdd( aLinha, { "D2_LOCAL"      , cLocal        , Nil } )
							aAdd( aLinha, { "D2_LOTECTL"    , cLoteCtl      , Nil } )
							aAdd( aLinha, { "D2_ESPECIE"    , 'RCD'  	    , Nil } )
							aAdd( aLinha, { "D2_CLVL"       , cClassVlr     , Nil } )
							aAdd( aLinha, { "D2_UM"         , Posicione('SB1',1,FWxFilial('SB1')+cProduto,'B1_UM'), Nil } )

						EndIf //FIM - If cPaisLoc <> "PAR"

						aAdd( aVincITE, aLinhaVinc )
						aAdd( aItens,   aLinha )

					EndIf	//--FIM - If NJV->( MsSeek( FWxFilial( "NJV" ) + cProduto ) )
				EndIf //--FIM - If _lCtrlTer .OR. _lCtrlDev .OR. _lCtrlDVl
			Next nX
		Else
			//Criando Vinculo com SC5 / SC6
			aLinhaVinc := {}
			aadd( aLinhaVinc, { "N8I_FILIAL"	, FwXfilial('N8I') 	} )
			aadd( aLinhaVinc, { "N8I_ITEMPV"   	, cItemSeq 			} )
			aadd( aLinhaVinc, { "N8I_PRODUT"   	, cProduto 			} )
			aadd( aLinhaVinc, { "N8I_TPPROD"   	, cTipProd		 	} )

 			aadd( aLinhaVinc, { "N8I_CODCTR"   	, cCodCtr			} )
			aadd( aLinhaVinc, { "N8I_SAFRA"  	, cCodSaf 			} )
			aadd( aLinhaVinc, { "N8I_CODROM"   	, cCodDocC6			} )
			aadd( aLinhaVinc, { "N8I_ITEROM"   	, cIteDocC6			} )
			aadd( aLinhaVinc, { "N8I_CODOTR" 	, ''				} )
			aadd( aLinhaVinc, { "N8I_ITEOTR" 	, ''				} )
			aadd( aLinhaVinc, { "N8I_CODFIX"  	, ''				} )
			aadd( aLinhaVinc, { "N8I_ORIGEM"   	, cOrigem		 	} )
			aAdd( aLinhaVinc, { "N8I_HISTOR"   	, cHist				} )

			//Iens do Aviso PEPRO
			aAdd( aLinhaVinc, { "N8I_NUMAVI"   	, cNumAvi    		} )
			aAdd( aLinhaVinc, { "N8I_NUMDCO"   	, cNumDco    		} )
			aAdd( aLinhaVinc, { "N8I_SEQDCO"   	, cSeqDco			} )
			aAdd( aLinhaVinc, { "N8I_TPAVIS"   	, cTpAvis			} )
			aAdd( aLinhaVinc, { "N8I_OBSERV"   	, cObserv			} )

			nTotPed += nTotal
			aAdd( aVincITE, aLinhaVinc )
			//aAdd( aItens,   aLinha )
		endIf  

		If __lnewNeg .AND. Posicione("SE4",1,FWxFilial("SE4")+NJM->(NJM_CONDPG),"E4_TIPO") == "9"
			OGX008CDTV((cAliasNJM)->NJM_FILIAL, (cAliasNJM)->NJM_CODROM, (cAliasNJM)->NJM_ITEROM, (cAliasNJM)->NJM_VLRUNI, @aDatasVenc, @aVlrUni)
		EndIf

		(cAliasNJM)->( dbSkip() )
	EndDo

	(cAliasNJM)->(dbCloseArea())

	If cPaisLoc <> "PAR" //NÃO FOR Paraguai
		//aAdd( aCab, {"C5_NUM"         , cPedido       , Nil } )
		aAdd( aCab, {"C5_TIPO"          , cTipo     	, Nil } )
		aAdd( aCab, {"C5_CLIENTE"       , cCliente      , Nil } )
		aAdd( aCab, {"C5_LOJACLI"       , cLoja     	, Nil } )
		if _cTipoEnt = 'SA1'
			aAdd( aCab, {"C5_TIPOCLI"		, Posicione("SA1",1,FWxFilial("SA1")+cCliente+cLoja,"A1_TIPO"), Nil})
		endIf

		If .Not. Empty( _cCliEntr ) .And. .Not. Empty( _cLojEntr )
			aAdd( aCab, {"C5_CLIENT"    , _cCliEntr      , Nil } )
			aAdd( aCab, {"C5_LOJAENT"   , _cLojEntr      , Nil } )
		Else
			aAdd( aCab, {"C5_CLIENT"    , cCliente      , Nil } )
			aAdd( aCab, {"C5_LOJAENT"   , cLoja     	, Nil } )
		EndIf

		cCondPg := NJM->( NJM_CONDPG )

		SE4->( DbSetOrder( 1 ) )
		If SE4->( MsSeek( FWxFilial( "SE4" )+ cCondPg ))
			If SE4->E4_TIPO == "9"

				If Len(aDatasVenc) > 0

					For nX := 1 to Len(aDatasVenc)
						aAdd(aCab, {"C5_DATA"+AllTrim(STR(nX)), cToD(SUBSTR(aDatasVenc[nX][1], 7, 2) + "/" + SUBSTR(aDatasVenc[nX][1], 5, 2) + "/" + SUBSTR(aDatasVenc[nX][1], 1, 4)), Nil})

						If Alltrim(SE4->(E4_COND)) = "%"
							aAdd(aCab, {"C5_PARC"+AllTrim(STR(nX)), (aDatasVenc[nX][2] / nPSLiq) * 100, Nil})
							nTotPedVenc += (aDatasVenc[nX][2] / nPSLiq) * 100
						Else
							aAdd(aCab, {"C5_PARC"+AllTrim(STR(nX)), aDatasVenc[nX][2] * aDatasVenc[nX][3], Nil})
							nTotPedVenc += aDatasVenc[nX][2] * aDatasVenc[nX][3]
						EndIf
					Next nX

					// Verifica se o valor das parcelas é o total do romaneio, caso não seja, joga o valor na última parcela
					If Alltrim(SE4->(E4_COND)) = "%" .AND. nTotPedVenc < 100
						nPosCpo := aScan(aCab, {|x| AllTrim(x[1]) == "C5_PARC"+AllTrim(STR(Len(aDatasVenc)))})

						aCab[nPosCpo][2] += 100 - nTotPedVenc
					ElseIf Alltrim(SE4->(E4_COND)) != "%" .AND. nTotPedVenc < nTotPed
						nPosCpo := aScan(aCab, {|x| AllTrim(x[1]) == "C5_PARC"+AllTrim(STR(Len(aDatasVenc)))})

						aCab[nPosCpo][2] += nTotPed - nTotPedVenc
					EndIf

				ElseIf !lCond  
					//MODELO CLASSICO
					lVencimento := .f.
					nTotPedVenc := 0
					aDatasVenc := fParVencMC( NJR->( NJR_CODCTR ), cCliente, cLoja, dEmissao, nTotPed) 

					If Len(aDatasVenc) > 0
							
						For nX := 1 to Len(aDatasVenc)
							lVencimento := .t.
							nTotParc := 0
							aAdd(aCab, {"C5_DATA"+AllTrim(STR(nX)), aDatasVenc[nX][1], Nil})
							
							If Alltrim(SE4->(E4_COND)) = "%"
								nTotParc := NOROUND( ((aDatasVenc[nX][2] / nTotPed) * 100) , 0)
								aAdd(aCab, {"C5_PARC"+AllTrim(STR(nX)), nTotParc , Nil})
								nTotPedVenc += nTotParc
							Else
								aAdd(aCab, {"C5_PARC"+AllTrim(STR(nX)), aDatasVenc[nX][2] , Nil})
								nTotPedVenc += aDatasVenc[nX][2] 
							EndIf
						Next nX

						// Verifica se o valor das parcelas é o valor do pedido, caso não seja, joga o valor na última parcela
						If Alltrim(SE4->(E4_COND)) = "%" .AND. nTotPedVenc < 100
							nPosCpo := aScan(aCab, {|x| AllTrim(x[1]) == "C5_PARC"+AllTrim(STR(Len(aDatasVenc)))})

							aCab[nPosCpo][2] += 100 - nTotPedVenc
						ElseIf Alltrim(SE4->(E4_COND)) != "%" .AND. nTotPedVenc < nTotPed
							nPosCpo := aScan(aCab, {|x| AllTrim(x[1]) == "C5_PARC"+AllTrim(STR(Len(aDatasVenc)))})

							aCab[nPosCpo][2] += nTotPed - nTotPedVenc
						EndIf

					Else
						//se não tem previsão financeira na SE1
						NN7->( dbSetOrder( 1 ) )
						NN7->( MsSeek( FWxFilial( "NN7" ) + NJR->( NJR_CODCTR ) ) )
						lVencimento := .f.
						While !NN7->( Eof() ) .And. NN7->( NN7_FILIAL ) + NN7->( NN7_CODCTR ) == FWxFilial( "NN7" ) + NJR->( NJR_CODCTR ) .And. NN7->( NN7_DTVENC ) >= dEmissao
							lVencimento := .t.				
							
							If Alltrim(SE4->( E4_COND )) = "%"
								lCond := .t.
								aAdd( aCab, {"C5_DATA1", NN7->( NN7_DTVENC ), Nil } )
								aAdd( aCab, {"C5_PARC1", 100.00, Nil } )
							Else
								aAdd( aCab, {"C5_DATA1", NN7->( NN7_DTVENC ), Nil } )
								aAdd( aCab, {"C5_PARC1", nTotPed, Nil } )
							EndIf

							Exit
							
						EndDo
					EndIf

					IF !lVencimento
						If Alltrim(SE4->( E4_COND )) = "%"
							lCond := .t.
							aAdd( aCab, {"C5_DATA1", dEmissao, Nil } )
							aAdd( aCab, {"C5_PARC1", 100.00, Nil } )
						Else
							aAdd( aCab, {"C5_DATA1", dEmissao, Nil } )
							aAdd( aCab, {"C5_PARC1", nTotPed, Nil } )
						EndIf						
					EndIf

				EndIf
			EndIf
		EndIf

		aAdd( aCab, {"C5_CONDPAG"       , cCondPg       , Nil } )
		aAdd( aCab, {"C5_TIPLIB"        , "2"           , Nil } )

		_cObs := OemToansi(Rtrim( _cObs ) + Rtrim( cMsgNfAux ) ) //-- Emerson,27/02/2015 -  Ajustando a Mensagem da Nf --//

		If .Not. Empty( _cObs )
			aAdd( aCab, {"C5_MENNOTA" , Alltrim( _cObs )        , Nil } )   //Campo mensagem da nota
		EndIf

		If Len( aEspecie ) > 0
			For nX := 1 to Len( aEspecie )
				aAdd( aCab, {"C5_ESPECI" + AllTrim( Str( nX ) ), aEspecie[ nX ], Nil } )
				If nX = 4
					Exit
				EndIf
			Next nX
		EndIf

		If Len( aVolume ) > 0
			For nX := 1 to Len( aVolume )
				aAdd( aCab, {"C5_VOLUME" + AllTrim( Str( nX ) ), aVolume[ nX ], Nil } )
				If nX = 4
					Exit
				EndIf
			Next nX
		EndIf

		cTpFrete:= IF( !Empty(NJJ->NJJ_TPFRET), NJJ->NJJ_TPFRET, NJR->NJR_TPFRET )

		aAdd( aCab, {"C5_TRANSP"    , cTransp       , Nil } )
		aAdd( aCab, {"C5_TPFRETE"   , cTpFrete      , Nil } )
		aAdd( aCab, {"C5_VEICULO"   , cVeic2      	, Nil } )
		aAdd( aCab, {"C5_PESOL"     , nPSLiq        , Nil } )
		aAdd( aCab, {"C5_PBRUTO"    , nPSSubt       , Nil } )
		aAdd( aCab, {"C5_NATUREZ"   , cNatuFin      , Nil } )

		If .NOT. __lnewNeg
			aAdd( aCab, {"C5_CODROM"    , cCodDocC5 , Nil } )
		EndIf
		//-- Emerson Implementação para tratar Vr. de Frete,Seguto,Outras despesas. --//
		aAdd( aCab, {"C5_FRETE"     , nFrete        , Nil } )
		aAdd( aCab, {"C5_SEGURO"    , nSeguro       , Nil } )
		aAdd( aCab, {"C5_DESPESA"   , nDespesa      , Nil } )

		If SC5->(FieldPos("C5_INDPRES")) > 0 
			If NJM->(FieldPos("NJM_INDPRE")) > 0 .AND. !Empty(cC5INDPRES) 
				aAdd( aCab, {"C5_INDPRES", cC5INDPRES, Nil } )	//Presença Comprador (NT 2020.006)
				If !Empty(cC5CODA1U) 
					aAdd( aCab, {"C5_CODA1U", cC5CODA1U, Nil } ) //codigo Intermediador (NT 2020.006)
				EndIf
			Else
				aAdd( aCab, {"C5_INDPRES", "0", Nil } )	////Presença Comprador (NT 2020.006) --> valor padrão 0 = Não Aplica
			EndIf
		EndIf

		//----------------------------------------------------------------------------//

		// Ponto de entrada inserido para controlar dados especificos do cliente 25/02/2015
		If ExistBlock("OGX008PV")
			aRetPe := ExecBlock("OGX008PV",.F.,.F.,{aCab,aItens})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
				aCab    := aClone(aRetPe[1])
				aItens  := aClone(aRetPe[2])
			EndIf
			/* Exemplo do PE
			User Function OGX008PV()
			Local aCab := aClone(PARAMIXB[1])
			Local aItens := aClone(PARAMIXB[2])
			Local aRet := {} //Customizações do usuário

			aAdd( aCab, {"C5_MEUCAMPO"  , 'Valor'       , Nil } )

			aRet := {aCab,aItens}

			Return aRet
			*/
		EndIf

		If Len( aCab ) > 0 .And. Len( aItens ) > 0
			// Atribuo o nr. do PV, somente qdo realmente vou Chamar a Função
			cPedido         :=  GetSxeNum("SC5","C5_NUM")
	
			//Validar Numero do Pedido devido falha da numeracao da base SLC - GetSxeNum("SC5","C5_NUM") está retornando numero ja utilizado
			//--Encontra a pedido de venda
			DbSelectArea( "SC5" )
			SC5->( DbSetOrder( 1 ) ) //C5_FILIAL+C5_NUM
			While SC5->( DbSeek( FwxFilial( "SC5" ) + cPedido ) )
				ConfirmSX8()
				cPedido         :=  GetSxeNum("SC5","C5_NUM")
			EndDo

			aAdd( aCab,     {"C5_NUM"           , cPedido       , Nil } )
			// Criando Array de vinculo
			// Alimentando as tabelas de auxiliares de vinculo com ERP
			aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 	} )
			aadd( aVincCab, { "N8H_NUMPV"    	, cPedido		  	} )
			aadd( aVincCab, { "N8H_CODCTR"    	, cCodCtr		 	} )
			aadd( aVincCab, { "N8H_CODROM"    	, cCodDocC6			} )
			aadd( aVincCab, { "N8H_CODFIX"   	, ""				} )
			aadd( aVincCab, { "N8H_CODOTR"   	, ""				} )
			aadd( aVincCab, { "N8H_ORIGEM"   	, cOrigem			} )

			IF Len( aVincITE ) > 0
				aLinhaVinc := aClone( aVincITE[1] )
				nPosCpo:= ASCAN(aLinhaVinc, {|aLinhaVinc| aLinhaVinc[1] ==  'N8I_HISTOR' })
				aadd( aVincCab, { "N8H_HISTOR"   	, aLinhaVinc[nPosCpo , 2]		} )
			EndIF

			/* Necessitamos solicitar o modulo pois alguns campos como LOTE e DTLOTE
			não estao setados para trabalhar com o SIGAAGR */
			cModulo := "FAT" // FIN ALTERADO POIS GERAVA ERRO DE C6_CODROM INVALIDO NO ROMANEIO S/PESAGEM
			nModulo := 5

			MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCab, aItens, 3)

			//Retornando o modulo do SIGAAGR
			cModulo := cModAtu
			nModulo := nModAtu

			If lMsErroAuto
				MostraErro()
				If __lSX8; RollBackSX8(); EndIf
				RestArea( aAreaAtu )
				Return( .f. )
			Else
				If __lSX8; ConfirmSX8(); EndIf

				lVinculou := fAgrVncPV (aVincCab,aVincITE  , 3)  	//Incluir
				If lVinculou
					DbSelectArea( "N8I" )
					N8I->( DbSetOrder( 1 ) )  //N8I_FILIAL+N8I_NUMPV+N8I_ITEMPV

					If N8I->( MsSeek( FWxFilial( "N8I" ) + cPedido ))
						While N8I->( !Eof() ) .And. N8I->( N8I_FILIAL + N8I_NUMPV) == FWxFilial( "N8I" ) + cPedido
							DbSelectArea( "NJM" )
							DbSetOrder( 1 ) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
							If NJM->( MsSeek( FWxFilial( "NJM" ) + N8I->( N8I_CODROM + N8I_ITEROM ) ) )
								If RecLock( "NJM", .f. )
									NJM->( NJM_PEDIDO ) := cPedido
									NJM->( NJM_ITVDAP ) := _cITVDAP
									NJM->( msUnLock() )
								EndIf
							EndIf

							N8I->( DbSkip() )
						EndDo
					EndIf
				Else
					AgrHelp(STR0001,"Ocorreu um erro no vinculo do pedido com as tabelas N8H e N8I.","Contate o suporte do produto.")
					RestArea( aAreaAtu )
					Return( .f. )
				EndIf

				//PE para manipular o pedido de vendas já gravado.
				//A execução deste PE não influencia no andamento da rotina.
				If EXISTBLOCK ("OGX008PG")
					ExecBlock("OGX008PG",.F.,.F.,{SC5->C5_FILIAL, SC5->C5_NUM})
				EndIf

			EndIf
		Else
			RestArea( aAreaAtu )
			Return( .f. )
		EndIf
	Else
		//SE PARAGUAI
		/*--- Cabeçalho ---*/
		cSerie := "R"+Space(TamSx3("F2_SERIE")[1] - 1)

		SF2->(DbSelectArea("SF2"))
		nQtdRegA := Reccount()

		SF2->(DbSetOrder(4))
		SF2->(MsSeek(FWxFilial("SF2")+cSerie,.T.))
		IF SF2->( Eof() )
			cDoc := STRZERO(0,nTam)
		Else
			While SF2->(F2_FILIAL) + SF2->(F2_SERIE) == FWxFilial("SF2") + cSerie .AND. !SF2->( Eof() )
				cDoc := SF2->F2_DOC
				SF2->(dbSkip())
			End
		Endif

		cDoc := Soma1(cDoc)

		If .Not. Empty( _cCliEntr ) .And. .Not. Empty( _cLojEntr )
			aAdd( aCab, {"F2_CLIENT"  , _cCliEntr , Nil } )
			aAdd( aCab, {"F2_LOJAENT" , _cLojEntr , Nil } )
		Else
			aAdd( aCab, {"F2_CLIENT"  , cCliente , Nil } )
			aAdd( aCab, {"F2_LOJAENT" , cLoja    , Nil } )
		EndIf

		If !Empty(cDoc)
			AAdd(aCab,{ "F2_DOC"   , cDoc , Nil } )
		EndIF

		aAdd(aCab,{"F2_CLIENTE",cCliente  ,Nil})
		aAdd(aCab,{"F2_LOJA"   ,cLoja     ,Nil})
		AADD(aCab,{"F2_SERIE"  ,cSerie    ,NIL})
		AADD(aCab,{"F2_EMISSAO",dDataBase ,NIL})
		AADD(aCab,{"F2_TXMOEDA",1  		  ,NIL})
		AADD(aCab,{"F2_MOEDA"  ,1    	  ,NIL})
		AADD(aCab,{"F2_TIPO"   ,"N"       ,NIL})
		AADD(aCab,{"F2_FORMUL" ,IIf( NJM->NJM_TPFORM = "1", "S", "N" ),NIL})

		If NJM->NJM_TIPO $ "6|8"
			aAdd(aCab,{"F2_COND"   ,cCondPg   ,NIL})
			aAdd(aCab,{"F2_CODROM" ,NJM->NJM_CODROM } )
			AADD(aCab,{"F2_TIPODOC","61"      ,NIL})
			AADD(aCab,{"F2_ESPECIE","RCD"+Space(TamSx3("F2_ESPECIE")[1] - 3)  ,NIL})
		Else
			AADD(aCab,{"F2_TIPODOC","50"      ,NIL}) 
			AADD(aCab,{"F2_ESPECIE","RFN"+Space(TamSx3("F2_ESPECIE")[1] - 3)  ,NIL})
		EndIf

		DbSelectArea("SF2")
		nQtdRegA := Reccount()

		If NJM->NJM_TIPO $ "6|8"
			MSExecAuto( { |x,y,z| Mata102dn(x,y,z) }, aCab, aItens, 3 )
		Else
			MSExecAuto( { |x,y,z| Mata462n(x,y,z)  }, aCab, aItens, 3 ) 
		EndIf

		DbSelectArea("SF2")
		nQtdRegD := Reccount()
		SF2->( DbGoBottom() )

		If lMsErroAuto .And. nQtdRegA == nQtdRegD
			MostraErro()
			Return .F.
		Else
			If Reclock("NJJ",.F.)
				NJJ->NJJ_DOCSER := SF2->F2_SERIE
				NJJ->NJJ_DOCNUM := SF2->F2_DOC
				NJJ->NJJ_DOCEMI := SF2->F2_EMISSAO
				NJJ->NJJ_DOCESP := SF2->F2_ESPECIE
				NJJ->NJJ_STAFIS := "2"

				NJJ->(MsUnLock())
			EndIf

			If Reclock("NJM",.F.)
				NJM->NJM_DOCSER := SF2->F2_SERIE
				NJM->NJM_DOCNUM := SF2->F2_DOC
				NJM->NJM_DOCEMI := SF2->F2_EMISSAO
				NJM->NJM_DOCESP := SF2->F2_ESPECIE
				NJM->NJM_CHVNFE := SF2->F2_CHVNFE
				NJM->NJM_STAFIS := "2"
				NJM->NJM_DTRANS := dDatabase
				NJM->(MsUnLock())
			EndIf

			If tableindic("N8J")  
				dbselectArea( "SD2" ) // Item da NF de Saída
				SD2->(dbSetOrder( 3 ))
				If SD2->(dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) ))
					//Array de vinculo do Agro com o doc. Sada
					aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8J')	} )
					aadd( aVincCabNF, { "N8J_DOC"		, SF2->F2_DOC 		} )
					aadd( aVincCabNF, { "N8J_SERIE"		, SF2->F2_SERIE		} )
					aadd( aVincCabNF, { "N8J_CLIFOR"    , SF2->F2_CLIENTE	} ) 
					aadd( aVincCabNF, { "N8J_LOJA"    	, SF2->F2_LOJA		} )
					aadd( aVincCabNF, { "N8J_TPDOC"    	, SF2->F2_TIPO   	} )
					aadd( aVincCabNF, { "N8J_CODCTR"    , NJM->NJM_CODCTR	} )
					aadd( aVincCabNF, { "N8J_CODROM"    , NJM->NJM_CODSAF	} )
					aadd( aVincCabNF, { "N8J_CODROM"   	, NJM->NJM_CODROM   } )
					aadd( aVincCabNF, { "N8J_CODFIX"	, ''				} )
					aadd( aVincCabNF, { "N8J_CODOTR"	, ''				} )		
					aadd( aVincCabNF, { "N8J_ORPGRC"	, ''				} )
					aadd( aVincCabNF, { "N8J_FECSER"	, ''				} )
					aadd( aVincCabNF, { "N8J_ORIGEM"	, cOrigem			} )
					aadd( aVincCabNF, { "N8J_HISTOR"	, cHist				} )	

					While .Not. SD2->( Eof() ) ;
						.And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
						
							//Array de vinculo do Agro com os Itens do doc. Saida
							aLinhaVinc := {}
							aadd( aLinhaVinc, { "N8K_FILIAL"    , FwXfilial('N8K')	} )
							aadd( aLinhaVinc, { "N8K_DOC" 	   	, SD2->D2_DOC		} )
							aadd( aLinhaVinc, { "N8K_SERIE"    	, SD2->D2_SERIE		} )
							aadd( aLinhaVinc, { "N8K_CLIFOR"    , SD2->D2_CLIENTE	} ) 
							aadd( aLinhaVinc, { "N8K_LOJA"    	, SD2->D2_LOJA		} )
							aadd( aLinhaVinc, { "N8K_ITEDOC"    , SD2->D2_ITEM   	} )
							aadd( aLinhaVinc, { "N8K_PRODUT"    , SD2->D2_COD 		} )
							aadd( aLinhaVinc, { "N8K_TPPROD"    , ''				} )
							aadd( aLinhaVinc, { "N8K_CODCTR"    , NJM->NJM_CODCTR	} )
							aadd( aLinhaVinc, { "N8K_SAFRA"    	, NJM->NJM_CODSAF 	} )
							aadd( aLinhaVinc, { "N8K_CODROM"   	, NJM->NJM_CODROM   } )
							aadd( aLinhaVinc, { "N8K_ITEROM"   	, NJM->NJM_ITEROM	} )
							aadd( aLinhaVinc, { "N8K_CODFIX"    , ''				} )
							aadd( aLinhaVinc, { "N8K_CODOTR"    , ''				} )		
							aadd( aLinhaVinc, { "N8K_ITEOTR"    , ''			 	} )
							aadd( aLinhaVinc, { "N8K_ORPGRC"    , ''			 	} )
							aadd( aLinhaVinc, { "N8K_FECSER"    , ''				} )
							aadd( aLinhaVinc, { "N8K_ORIGEM"    , cOrigem			} )
							aadd( aLinhaVinc, { "N8K_HISTOR"    , cHist				} )
							aAdd( aVincIteNF, aLinhaVinc )
							SD2->( dbSkip() )
					EndDo

					lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 3)  	//Incluir
				
				EndIf
			EndIf   

		EndIf

	EndIF

	RestArea(aAreaNJM)
	RestArea( aAreaAtu )
Return( .t. )

/** {Protheus.doc} SelNfsDev
Função auxiliar para seleção de documentos de origem para amarracao na NF de devolução.

@obs Para arredondamento usar a função A410Arred() do estoque, para evitar erros nas casas decimais com relação ao truncamento ou arredondamento, 
mantendo assim o padrão do estoque. O parametro MV_ARREFAT tambem pode interferir. 

@param:     Nil
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       ARMA247 - Documentos de Entrada
@type function
*/
Static Function SelNfs( cRomaneio, cCodCtr, nQtdDev, cProduto, cTipo , cTipEnt, cLoteCtl )
	Local aRetorno      := {}
	Local aAreaAtu      := GetArea()
	Local oSize         := Nil
	Local oDlg          := Nil
	Local oPnUm         := Nil
	Local oPnDois       := Nil
	Local oFont         := Nil
	Local oStO          := LoadBitmap( GetResources(), "LBNO" )//"unchecked_15" )	//--Sem Seleção
	Local oStX          := LoadBitmap( GetResources(), "LBOK" )//"checked_15" )		//--Com Seleção
	Local aButtons      := {}
	Local aAux          := {}
	Local nOpcao        := 0
	Local nY            := 0
	Local cTesNFT       := AllTrim(SuperGetMV( "MV_TESNFT",, "" ))
	Local lOgUsaNt      := SuperGetMV( "MV_OGUSANT",, .F. )
	Local cQueryFix     := ""
	Local cQuerySD1     := ""
	Local cFiltro		:= ""
	Local cOrder		:= "" 
	Local nSaldo        := 0
	Local nQtdFix		:= 0
	Local nValSel       := 0
	Local nValDev       := 0

	Private oBrowse     := Nil
	Private oSay        := Nil
	Private nQtdAdl     := nQtdDev
	Private nQtdSel     := 0
	Private cAliasNNC   := ''
	Private cAliasSD1	:= ''

	aAdd( aButtons, { "", {|| EditQtd() }, OemToAnsi( "Editar" ) } )

	cAliasSD1 := GetNextAlias()
	cQuerySD1 += " SELECT SD1.D1_DOC, "
	cQuerySD1 += 	    " SD1.D1_SERIE, "
	cQuerySD1 +=        " SD1.D1_EMISSAO, "
	cQuerySD1 +=        " SD1.D1_ITEM, "
	cQuerySD1 +=        " SD1.D1_TES, "
	cQuerySD1 +=        " SD1.D1_QUANT, "
	cQuerySD1 +=        " SD1.D1_VUNIT, "
	cQuerySD1 +=        " SD1.D1_TOTAL, "
	cQuerySD1 +=        " SD1.D1_CODROM, "
	cQuerySD1 +=        " SD1.D1_ITEROM, "
	cQuerySD1 +=        " (SD1.D1_QUANT - SD1.D1_QTDEDEV) AS D1_SALDO, "
	cQuerySD1 +=        " SD1.D1_IDENTB6, "
	cQuerySD1 +=        " SD1.D1_LOTECTL "

	//--Para devolução com terceiros verificar a tabela SB6
	IF _lCtrlTer
		cQuerySD1 +=   ", SB6.B6_SALDO "        
	EndIF

	cQuerySD1 += " FROM " + RetSqlName('SD1')+ " SD1 "

	//--Para devolução com terceiros verificar a tabela SB6
	IF _lCtrlTer
		cQuerySD1 += " INNER JOIN  " + RetSqlName('SB6')+ " SB6  ON SB6.D_E_L_E_T_  = '' "
		cQuerySD1 +=                                          " AND SB6.B6_FILIAL  = SD1.D1_FILIAL  "
		cQuerySD1 +=                                          " AND SB6.B6_IDENT   = SD1.D1_IDENTB6 "
		cQuerySD1 +=                                          " AND SB6.B6_SALDO   > 0 "
	EndIf

	cFiltro += " WHERE SD1.D1_FILIAL = '"+ FWxFilial("SD1") +"'"
	cFiltro += " AND SD1.D1_LOTECTL = '"+ cLoteCtl +"'"
	cFiltro += " AND SD1.D_E_L_E_T_= '' "
	cFiltro += " AND SD1.D1_CTROG = '"+ cCodCtr +"'"

	//--Se complemento
	If _lCtrlCom
		cFiltro += " AND SD1.D1_TIPO    = 'N' "
		cFiltro += " AND SD1.D1_QUANT   > 0   "
	Else
		cFiltro += " AND SD1.D1_COD     = '"+ cProduto +"'"
		cFiltro += " AND (SD1.D1_QUANT - SD1.D1_QTDEDEV) > 0 "
	EndIf

	cOrder += "ORDER BY SD1.D1_EMISSAO, SD1.D1_SERIE, SD1.D1_DOC "

	If ExistBlock("OG008SLNF")
		aRetPe := ExecBlock("OG008SLNF",.F.,.F.,{cQuerySD1, cFiltro, cOrder})
		
		If Len(aRetPe) == 3 .And.( ValType(aRetPe[1]) == "C" .And. ValType(aRetPe[2]) == "C" .And. ValType(aRetPe[3]) == "C")
			cQuerySD1 := aRetPe[1]
			cFiltro   := aRetPe[2]
			cOrder	  := aRetPe[3]		
		EndIf

	EndIf

	cQuerySD1 := cQuerySD1 + cFiltro + cOrder
	
	cQuerySD1 := ChangeQuery(cQuerySD1)
	If Select("cAliasSD1") <> 0
		(cAliasSD1)->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySD1),cAliasSD1,.F.,.T.)

	DbSelectArea( (cAliasSD1) )

	(cAliasSD1)->( dbGoTop() )
	If (cAliasSD1)->( Eof() )
		(cAliasSD1)->( dbCloseArea() )
		RestArea( aAreaAtu )
		_lNFOrigem := .F.
		Return( aRetorno )
	EndIf

	While .Not. (cAliasSD1)->( Eof() )

		If lOgUsaNt

			If (cAliasSD1)->( D1_TES ) = cTesNFT
				(cAliasSD1)->( DbSkip() )
				Loop
			Endif
		Endif

		cAliasNNC := GetNextAlias()
		cQueryFix := " SELECT SUM( NNC_QTDFIX ) QTDFIX"
		cQueryFix += " FROM " + RetSqlName('NNC')+ " NNC "
		cQueryFix += " WHERE NNC.D_E_L_E_T_  = '' "
		cQueryFix += " AND NNC.NNC_CODCTR  = '" + cCodCtr  + "' "
		cQueryFix += " AND NNC.NNC_CODROM  = '" + (cAliasSD1)->( D1_CODROM )  + "' "
		cQueryFix += " AND NNC.NNC_ITEROM  = '" + (cAliasSD1)->( D1_ITEROM )  + "' "
		cQueryFix += " AND NNC.NNC_FILIAL  = '" +  FWXFilial("NNC") + "' "
		cQueryFix := ChangeQuery(cQueryFix)
		If select("cAliasNNC") <> 0
			cAliasNNC->( dbCloseArea() )
		EndIf
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryFix),cAliasNNC,.T.,.T.)

		DbSelectArea( cAliasNNC )
		(cAliasNNC)->( dbGoTop() )
		If .Not. (cAliasNNC)->( Eof() )
			//Valor da fixação
			nQtdFix := (cAliasNNC)->QTDFIX
		EndIF
		(cAliasNNC)->( dbCloseArea() )

		//--Se controla terceiro utiliza saldo da SB6->B6_SALDO
		If _lCtrlTer
			nSaldo := (cAliasSD1)->(B6_SALDO) - nQtdFix
		ElseIf .NOT. _lCtrlCom
			nSaldo := (cAliasSD1)->(D1_SALDO) - nQtdFix
		EndIf

		aAdd( aAux, Array( COL_COUNT ) )
		aAux[ Len( aAux ), COL_MARK     ] := "0"
		aAux[ Len( aAux ), COL_DOC      ] := (cAliasSD1)->( D1_DOC   )
		aAux[ Len( aAux ), COL_SERIE    ] := (cAliasSD1)->( D1_SERIE )
		aAux[ Len( aAux ), COL_EMISSAO  ] := DTOC( STOD( (cAliasSD1)->( D1_EMISSAO ) ) )
		aAux[ Len( aAux ), COL_ITEM     ] := (cAliasSD1)->( D1_ITEM  )
		aAux[ Len( aAux ), COL_QUANT    ] := (cAliasSD1)->( D1_QUANT )
		aAux[ Len( aAux ), COL_VUNIT    ] := A410Arred( (cAliasSD1)->( D1_VUNIT ), "C6_PRCVEN" )
		aAux[ Len( aAux ), COL_VTOTAL   ] := (cAliasSD1)->( D1_TOTAL )
		aAux[ Len( aAux ), COL_LOTECTL  ] := (cAliasSD1)->( D1_LOTECTL )
		aAux[ Len( aAux ), COL_VAZIO ] 	  := "1"

		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			aAux[ Len( aAux ), COL_QTDFIX   ] := nQtdFix
			aAux[ Len( aAux ), COL_IDENTB6  ] := (cAliasSD1)->( D1_IDENTB6 )
		EndIf

		//--Se for devolução de terceiro
		If _lCtrlTer			
            aAux[ Len( aAux ), COL_CODROM ]   := (cAliasSD1)->( D1_CODROM )    // romaneio
			aAux[ Len( aAux ), COL_ITEROM ]   := (cAliasSD1)->( D1_ITEROM )    // seq comerc romaneio
		EndIf

		//--Se não é complemento
		If .NOT. _lCtrlCom
			aAux[ Len( aAux ), COL_SALDO    ] := nSaldo
			aAux[ Len( aAux ), COL_DISTRIB  ] := 0
			aAux[ Len( aAux ), COL_VDISTR   ] := 0
		EndIf

		//Devolução para Depósito _E_ Se for devolução de terceiro
		If cTipo = '6' .AND. _lCtrlTer
			nQuebra 	:= 0
			nRetencao   := 0

			aNotaAux     := {}                       //Atenção foi criado o Array aNotaAxu, Para q possiveis auterações no aauxB não influenciem no array passado a X262QTRET
			nLineAAuxB   := Len( aAux )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_MARK      ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_DOC       ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_SERIE     ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_EMISSAO   ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_ITEM      ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_QUANT     ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_VUNIT     ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_VTOTAL    ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_SALDO     ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_DISTRIB   ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_VDISTR    ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_IDENTB6   ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_VAZIO     ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_CODROM    ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_ITEROM    ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_QTDRET    ] )
			aAdd( aNotaAux, aAux[ nLineAAuxB, COL_QTDQTC    ] )

			aRetencao := X262QTRET( cCodCtr, aNotaAux, .t.) // quantidade retenções não confirmadas
			If Len(aRetencao) > 0
				nQuebra 	:= aRetencao[1]
				nRetencao   := aRetencao[2]
			EndIf

			If !cTipent = '3'
				nSaldo  := nSaldo - (nRetencao + nQuebra)
			else
				// se o tipo de romaneio for retenção está fazendo o retorno e tem que ter saldo para devolver
				nSaldo := nSaldo - (nRetencao )
			endIf

			aAux[ Len( aAux ), COL_QTDRET ] := nRetencao
			aAux[ Len( aAux ), COL_SALDO  ] := nSaldo
			aAux[ Len( aAux ), COL_QTDQTC ] := nQuebra
		EndIf

		//--Se for devolução de terceiro ou devolução quantidade tipos 6 ou 8
		If _lCtrlTer .OR. _lCtrlDev
			//--Se quantidade de devolução maior que zero
			If nQtdAdl > 0
				//--Se devolução quantidade tipos 6 ou 8
				If _lCtrlDev
					//Se o saldo da nota for diferente de zero
					If !(cAliasSD1)->( D1_SALDO ) == 0
						//Se q qtd de devolucao for maior que saldo E se a qtd da nota for maior que a fixacao
						If  nQtdAdl >= aAux[ Len( aAux ), COL_SALDO ] .And. (cAliasSD1)->( D1_QUANT ) > nQtdFix
							aAux[ Len( aAux ), COL_MARK     ] := "1"
							aAux[ Len( aAux ), COL_DISTRIB  ] := aAux[ Len( aAux ), COL_SALDO ]
							nQtdAdl -= aAux[ Len( aAux ), COL_SALDO ]
							nQtdSel += aAux[ Len( aAux ), COL_SALDO ]

							//Senao a qtd da nota for maior que a fixacao
						ElseIf (cAliasSD1)->( D1_QUANT ) > nQtdFix
							aAux[ Len( aAux ), COL_MARK     ] := "1"
							aAux[ Len( aAux ), COL_DISTRIB  ] := nQtdAdl
							nQtdSel += nQtdAdl
							nQtdAdl := 0
						EndIf
					Endif

					//Tratando arrendondamentos chamado TUQTSG
					//aAux[ Len( aAux ), COL_VDISTR     ] := A410Arred( aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ], "C6_VALOR" )
					aAux[ Len( aAux ), COL_VUNIT    ] := aAux[ Len( aAux ), COL_VTOTAL  ] / aAux[ Len( aAux ), COL_QUANT ]
					aAux[ Len( aAux ), COL_VDISTR   ] := aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ]

					//--Se for devolução de terceiro
				Else
					//Se q qtd de devolucao for maior que saldo E se a qtd da nota for maior que a fixacao
					If nQtdAdl >= nSaldo .And. (cAliasSD1)->( D1_QUANT ) > nQtdFix
						If nSaldo > 0 //para não marcar registro com saldo zero, inclusive o que tem retenção/quebra tecnica
							aAux[ Len( aAux ), COL_MARK       ] := "1"
							aAux[ Len( aAux ), COL_DISTRIB    ] := nSaldo
							nQtdAdl -= nSaldo
							nQtdSel += nSaldo
						EndIf
						//Se a qtd da nota for maior que a fixacao
					ElseIf (cAliasSD1)->( D1_QUANT ) > nQtdFix
						aAux[ Len( aAux ), COL_MARK       ] := "1"
						aAux[ Len( aAux ), COL_DISTRIB    ] := nQtdAdl
						nQtdSel += nQtdAdl
						nQtdAdl := 0
					EndIf

					//Tratando arrendondamentos chamado 12637275 DAGROOGD-15187
					aAux[ Len( aAux ), COL_VDISTR ] := A410Arred( aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ], "C6_VALOR")

				EndIf
			EndIf	//FIM - If nQtdAdl > 0
		EndIf	//FIM - If _lCtrlTer .OR. _lCtrlDev

		(cAliasSD1)->( dbSkip() )
	EndDo
	(cAliasSD1)->( dbCloseArea() )

	If Len(aAux) <= 0
		RestArea( aAreaAtu )
		_lNFOrigem := .F.
		Return( aRetorno )
	Endif

	oSize := FwDefSize():New()
	oSize:AddObject( "P1", 100, 80, .t., .t., .t. )
	oSize:AddObject( "P2", 100, 20, .t., .t., .t. )
	oSize:lProp     := .t.
	oSize:aMargins  := { 3, 3, 3, 3 }
	oSize:Process()
	If ! IsBlind()
		oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], STR0005 ,,,,,CLR_BLACK,CLR_WHITE,,,.t.)	//"Seleção de Romaneios x Notas Fiscais"

		oPnUm   := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" ),oSize:GetDimension( "P1", "YSIZE" ) )
		oPnDois := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ),oSize:GetDimension( "P2", "YSIZE" ) )

		oBrowse := TCBrowse():New( 01, 01, 260, 156, , , , oPnUm, , , , , , , , , , , , .f., ,.t., , .f. )

		oBrowse:AddColumn( TCColumn():New( ""       , { || IIf( aAux[oBrowse:nAt, COL_MARK ] == "1", oStX, oStO ) }             				,,,,"CENTER"    , 040,.t.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( STR0006  , { || aAux[ oBrowse:nAt, COL_SERIE                     ] }                                 ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Serie"
		oBrowse:AddColumn( TCColumn():New( STR0007  , { || aAux[ oBrowse:nAt, COL_DOC                       ] }                                 ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Numero"
		oBrowse:AddColumn( TCColumn():New( STR0008  , { || aAux[ oBrowse:nAt, COL_EMISSAO                   ] }                                 ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Emissao"
		oBrowse:AddColumn( TCColumn():New( STR0009	, { || aAux[ oBrowse:nAt, COL_ITEM                      ] }                                 ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Item"

		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			oBrowse:AddColumn( TCColumn():New( STR0010 , { || aAux[ oBrowse:nAt, COL_IDENTB6                   ] }                                 ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Ident"
		EndIf

		oBrowse:AddColumn( TCColumn():New( STR0038  , { || aAux[ oBrowse:nAt, COL_LOTECTL                   ] }                                 ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Lote"
		oBrowse:AddColumn( TCColumn():New( STR0011	, { || Transform( aAux[ oBrowse:nAt, COL_QUANT          ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Quantidade"

		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			oBrowse:AddColumn( TCColumn():New( STR0039	, { || Transform( aAux[ oBrowse:nAt, COL_QTDFIX         ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT" 	,  	 ,.f.,.t.,,,,.f.,) )	//"Qtd. Fixada"            
		EndIf       

		oBrowse:AddColumn( TCColumn():New( STR0012	, { || Transform( aAux[ oBrowse:nAt, COL_VUNIT          ], "@E 9,999,999.999999"   ) }    	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Vlr. Unit."
		oBrowse:AddColumn( TCColumn():New( STR0013  , { || Transform( aAux[ oBrowse:nAt, COL_VTOTAL         ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Vlr. Total"
		
        //--Se não for contrato de complemento apresenta a coluna
		If .NOT. _lCtrlCom	

			//Devolução para Depósito _E_ Se for devolução de terceiro
			If cTipo = '6' .AND. _lCtrlTer
				oBrowse:AddColumn( TCColumn():New( "Retenção"  	 , { || Transform( aAux[ oBrowse:nAt, COL_QTDRET         ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Retenção"
				oBrowse:AddColumn( TCColumn():New( "Quebra Tec."  , { || Transform( aAux[ oBrowse:nAt, COL_QTDQTC         ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Retenção"
			EndIf

            oBrowse:AddColumn( TCColumn():New( STR0014	, { || Transform( aAux[ oBrowse:nAt, COL_SALDO          ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Saldo"			
            oBrowse:AddColumn( TCColumn():New( STR0015	, { || Transform( aAux[ oBrowse:nAt, COL_DISTRIB        ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Distribuido"
			oBrowse:AddColumn( TCColumn():New( STR0016  , { || Transform( aAux[ oBrowse:nAt, COL_VDISTR         ], "@E 999,999,999,999.99" ) }  	,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Valor Distr."
		EndIf

		oBrowse:AddColumn( TCColumn():New( " "          , { || aAux[ oBrowse:nAt, COL_VAZIO                     ] }                                 ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )

		oBrowse:SetArray( aAux )
		oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
		oBrowse:bLDblClick  := {|| MarcaUm( aAux, oBrowse:nAt, nQtdDev ) }

		//--Se não for complemento
		If .NOT. _lCtrlCom
			oFont   := TFont():New( "Courier new", , -16, .t. )
			oSay    := TSay():New( 01, 01, {|| RetTexto( aAux, nQtdDev ) }, oPnDois, , oFont, , , , .t., CLR_RED, CLR_WHITE, 200, 20 )
			oSay:Align := CONTROL_ALIGN_ALLCLIENT
		EndIf		   

        bValida :=  {|| fValSaldo(aAux, cProduto, nQtdDev, nQtdSel, nValDev, nValSel) } 

		oDlg:Activate( , , , .t., bValida, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() },, @aButtons ) } )
	Else
		nOpcao := 1
	EndIf
	If nOpcao = 1
		For nY := 1 to Len( aAux )
			If aAux[ nY, COL_MARK ] = "1"
				aAdd( aRetorno, aAux[ nY ] )
			EndIf
		Next nY
	EndIf

	RestArea( aAreaAtu )
Return( aRetorno )

/** {Protheus.doc} MarcaUm
*/
Static Function MarcaUm( aItsMrk, nLinMrk, nQtdDev )
	//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
	If _lCtrlTer .OR. _lCtrlDev
		Do Case
			Case aItsMrk[ nLinMrk, COL_MARK ] == "0" .and. aItsMrk[ nLinMrk, COL_SALDO ] > 0
				If nQtdAdl > 0
					If nQtdAdl >= aItsMrk[ nLinMrk, COL_SALDO ]
						aItsMrk[ nLinMrk, COL_MARK      ] := "1"
						aItsMrk[ nLinMrk, COL_DISTRIB   ] := aItsMrk[ nLinMrk, COL_SALDO ]
						nQtdAdl -= aItsMrk[ nLinMrk, COL_SALDO ]
					Else
						aItsMrk[ nLinMrk, COL_MARK      ] := "1"
						aItsMrk[ nLinMrk, COL_DISTRIB   ] := nQtdAdl
						nQtdAdl := 0
					EndIf
					aItsMrk[ nLinMrk, COL_VDISTR    ] := A410Arred( aItsMrk[ nLinMrk, COL_DISTRIB ] * aItsMrk[ nLinMrk, COL_VUNIT ] , "C6_VALOR")
				EndIf
			Case aItsMrk[ nLinMrk, COL_MARK ] == "1"
				aItsMrk[ nLinMrk, COL_MARK ] := "0"
				nQtdAdl += aItsMrk[ nLinMrk, COL_DISTRIB ]
				aItsMrk[ nLinMrk, COL_DISTRIB ] := 0
				aItsMrk[ nLinMrk, COL_VDISTR  ] := 0
		EndCase
	EndIf

	//--Se for complemento ou devolução de valor
	If _lCtrlCom	.OR. _lCtrlDVl
		Do Case
			Case aItsMrk[ nLinMrk, COL_MARK ] == "0"
			aItsMrk[ nLinMrk, COL_MARK      ] := "1"
			If _lCtrlDVl
				EditVal( )
			EndIf
			Case aItsMrk[ nLinMrk, COL_MARK ] == "1"
			aItsMrk[ nLinMrk, COL_MARK ] := "0"
		EndCase
	EndIF

	If _lCtrlTer .OR. _lCtrlDev .OR. _lCtrlDVl
		oSay:Refresh()
	EndIf

	oBrowse:Refresh()
Return( )

/** {Protheus.doc} RetQtd()
*/
Static Function RetTexto( aItsMrk, nQtdDev )
	Local cTexto        := ""
	Local nX            := 0

	nQtdSel := 0

	For nX := 1 to Len( aItsMrk )
		If aItsMrk[ nX, COL_MARK ] = "1"
			nQtdSel += aItsMrk[ nX, COL_DISTRIB ]
		EndIf
	Next nX

	cTexto += STR0017 + Transform( nQtdDev, "@E 999,999,999.99" )	//"Quantidade da Devolução: "
	cTexto += Chr( 13 ) + Chr( 10 )
	cTexto += STR0018 + Transform( nQtdSel, "@E 999,999,999.99" )	//"Quantidade Selecionada : "
Return( cTexto )

/** {Protheus.doc} OGX008B
Funcao auxiliar para geracao do pedido de venda

@param:     Nil
@author:    Fernando Pereira Leite
@since:     10/05/2013
@Uso:       ARMA244 - Documento Fiscal
*/
Function OGX008B( cPedido )
	Local aAreaAtu      := GetArea()
	Local aAreaSC5      := SC5->( GetArea())
	Local aAreaSC6      := SC6->( GetArea())
	Local aAreaSC9      := SC9->( GetArea())
	Local aCab          := {}
	Local aItens        := {}

	Private lMsErroAuto := .f.

	SC5->( dbSetOrder( 1 ) )
	If SC5->( MsSeek( FWxFilial( "SC5" ) + cPedido ) )

		aAdd( aCab, {"C5_NUM"       , SC5->( C5_NUM )       , Nil } )
		aAdd( aCab, {"C5_TIPO"      , SC5->( C5_TIPO )      , Nil } )
		aAdd( aCab, {"C5_CLIENTE"   , SC5->( C5_CLIENTE )   , Nil } )
		aAdd( aCab, {"C5_LOJACLI"   , SC5->( C5_LOJACLI )   , Nil } )

		Estorna_PV( cPedido, aCab, aItens )

		If lMsErroAuto
			MostraErro()
			RestArea( aAreaSC9 )
			RestArea( aAreaSC6 )
			RestArea( aAreaSC5 )
			RestArea( aAreaAtu )
			Return( .f. )
		EndIf

	EndIf

	RestArea( aAreaSC9 )
	RestArea( aAreaSC6 )
	RestArea( aAreaSC5 )
	RestArea( aAreaAtu )
Return( .t. )

/** {Protheus.doc} EditQtd
Funcao para alterar a quantidade parcial a ser devolvida

@param:     Nil
@author:    Fernando Pereira
@since:     14/06/2013
@Uso:       ARMA249 - Documentos de saída
*/
Static Function EditQtd()

	Local   nOpcao      := 0
	Local   oDlg        := Nil
	Local   lMark       := oBrowse:aArray[ oBrowse:nAt, COL_MARK    ] = "1"
	Local   nQtdAnt :=  oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ]
	Local   nQtdSal :=  oBrowse:aArray[ oBrowse:nAt, COL_SALDO  ]
	Private nQtdNew :=  oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ]

	If lMark
		Define MsDialog oDlg Title STR0021 From 9,0 to 20,50 Of oMainWnd	//"Alterar - Quantidade"
		@ 030,015 Say OemToAnsi(STR0022) Of oDlg Pixel	//"Quantidade: "
		@ 030,065 MsGet nQtdNew  Valid nQtdNew >= 0 .And. nQtdNew <= nQtdSal Picture("@E 999,999,999,999.99") Size 070, 010  Of oDlg Pixel
		Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() })
		If nOpcao == 1
			If  nQtdNew = 0
				oBrowse:aArray[ oBrowse:nAt, COL_MARK   ] := "0"
				oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ] := 0
			Else
				oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ] := nQtdNew
			EndIf

			oBrowse:aArray[ oBrowse:nAt, COL_VDISTR     ] := A410Arred( oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ] * oBrowse:aArray[ oBrowse:nAt, COL_VUNIT ], "C6_VALOR")

			nQtdAdl :=  nQtdAdl + ( nQtdAnt - nQtdNew )

			oSay:Refresh()
			oBrowse:Refresh()
		EndIf
	EndIf
Return( Nil )

/** {Protheus.doc} EditVal

*/
Static Function EditVal()
	Local nOpcao    := 0
	Local oDlg      := Nil
	Local lMark     := oBrowse:aArray[ oBrowse:nAt, COL_MARK    ] = "1"
	Local nValNfs   := oBrowse:aArray[ oBrowse:nAt, COL_VTOTAL  ]
	Local nValAnt   := oBrowse:aArray[ oBrowse:nAt, COL_VDISTR  ]
	Local nValNew   := oBrowse:aArray[ oBrowse:nAt, COL_VDISTR  ]
	Local nValSel   := 0

	If lMark

		Define MsDialog oDlg Title STR0024 From 9,0 to 20,50 Of oMainWnd	//"Alterar - Valor"
		@ 030,015 Say OemToAnsi(STR0025) Of oDlg Pixel	//"Valor: "
		@ 030,065 MsGet nValNew  Valid nValNew < nValNfs Picture("@E 999,999,999.99") Size 070, 010  Of oDlg Pixel
		Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() })
		If nOpcao == 1
			If  nValNew = 0
				oBrowse:aArray[ oBrowse:nAt, COL_MARK   ] := "0"
				oBrowse:aArray[ oBrowse:nAt, COL_VDISTR ] = 0
			Else
				oBrowse:aArray[ oBrowse:nAt, COL_VDISTR ] = nValNew
			EndIf

			nValSel :=  nValSel + ( nValAnt - nValNew )

			oSay:Refresh()
			oBrowse:Refresh()
		EndIf

	EndIf

Return( Nil )

/** {Protheus.doc} OGXVerific
Funcao para impedir a alteração de registros de Pedido de Compra/Venda gerados a partir do Gestor de Entidades
@param:     Nil
@author:    Marcos Wagner Jr.
@since:     07/06/2017
@Uso:       MATA120 - Pedidos de Compra
*/

Function OGXVerific(cFuncMata,lAlteracao,lExclusao)
	Default lAlteracao := .t.
	Default lExclusao  := .t.

	If cPaisLoc == "PAR" .or. cPaisLoc == "ARG"
		If (lAlteracao .OR. lExclusao) .AND. !(IsIncallStack("OGA450")) .AND.;
		((cFuncMata == "MATA120" .AND. !Empty(SC7->C7_CODOPG)) .OR. (cFuncMata == "MATA410" .AND. !Empty(SC5->C5_CODOPG)))
			If cFuncMata == "MATA120"
				Help(1," ","HELP",,STR0030,3,0) //"Não é permitida a Alteração/Exclusão dos Pedidos de Compra gerados pelo Gestor de Entidades!"
			ElseIf cFuncMata == "MATA410"
				Help(1," ","HELP",,STR0031,3,0) //"Não é permitida a Alteração/Exclusão dos Pedidos de Venda gerados pelo Gestor de Entidades!"
			EndIf

			Return .F.

		EndIf
	EndIf

	Return .T.

	/*/{Protheus.doc} OGX008ACPL
	Gera a NF de complemento bom base em um romaneio e grava as tabelas de relacionamento
	@type Function
	@author filipe.olegini
	@since 29/06/2018
	@param cFilRom, char, Filial do romaneio
	@param cCodRom, char, Codigo do romaneio
	@param cItemRom, char, item do romaneio
	@param cTipo, char, Tipo de NF de complemento
	@param nValor, numeric, Valor a ser Gerado
	@see (links_or_references)
	/*/
	Function OGX008ACPL(cFilRom as char, cCodRom as char, cItemRom as char, cSerieNFC as char, cTipo as char, nValor as numeric, aItensNKC as array, aVenc as array)
	Local aAreaAtu   as array
	Local aAreaSC5   as array
	Local aAreaSC6   as array
	Local aAreaSE4   as array
	Local aAreaNJM   as array
	Local aCab 	     as array
	Local aItens     as array
	Local aLinha     as array
	Local aDatasVenc as array
	Local aVlrUni    as array
	Local aVincCab   as array
	Local aLinhaVinc as array
	Local aVincITE   as array
	Local aGerouDoc  as array
	Local aArqLogs   as array
	Local nX         as numeric
	local cNumPed    as char
	Local cNfOri	 as char
	Local cSeriOri   as char
	Local cItemOri   as char
	Local cNewNFC    as char
	Local cNewSNFC   as char
	Local cQuery     as char
	Local cAliasQry  as char
	Local cItemFix   as char
	Local cCliente   as char
	Local cLojClie   as char
	Local cItemNKC   as char
	Local cMsgErr    as char
	Local nDifVal    as numeric
	Local cFilAtu    as char
	Local nPosCpo    as numeric
	Local nMedia	 as numeric
	Local nPreCalc	 as numeric
	Local nValCalc	 as numeric
	Local cNatuFin   as char
	Local cModAtu    as char
	Local nModAtu    as numeric

	//variáveis do execauto
	Private lMsErroAuto as logical

	Default aVenc	:= {}

	//inicialização das variáveis
	aAreaAtu	:= GetArea()
	aAreaSC5 	:= SC5->(GetArea())
	aAreaSC6 	:= SC6->(GetArea())
	aAreaSE4	:= SE4->(GetArea())
	aAreaNJM	:= NJM->(GetArea())
	aCab 		:= {}
	aItens 		:= {}
	aLinha		:= {}
	aDatasVenc  := {}
	aVlrUni     := {}
	aVincCab    := {}
	aLinhaVinc  := {}
	aVincITE    := {}
	aGerouDoc   := {}
	aArqLogs    := {}
	nX          := 0
	cNumPed     := ""
	cNfOri		:= ""
	cSeriOri	:= ""
	cItemOri	:= ""	
	cNewNFC     := ""
	cNewSNFC    := ""
	cQuery      := ""
	cAliasQry   := ""
	cItemFix    := ""
	cCliente    := ""
	cLojClie    := ""
	cItemNKC    := ""
	cMsgErr     := ""
	nDifVal     := 0
	nPosCpo     := 0
	nMedia		:= 0
	cModAtu     := cModulo
	nModAtu     := nModulo

	lMsErroAuto := .F.

	If Empty(cSerieNFC)
	   cSerieNFC := GetNewPar("MV_OGASERS","1")
	EndIf

	// -- Eliminando os arquivos de log dos erros gerados anteriormente
	aArqLogs := Directory("SC*.LOG")
	For nX := 1 to Len(aArqLogs)
		FErase(aArqLogs[nX,1])
	Next nX

	//posiciona no registro enviado
	DbSelectArea("NJM")
	DbSetOrder(1) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If !(DbSeek(cFilRom + cCodRom + cItemRom))
		cMsgErr := STR0044 // romaneio informado nos parametros não encontrado
		Return {.F., cMsgErr}
	EndIf

	//Carrega os dados da nota de origem
	cNfOri		:= NJM->NJM_DOCNUM
	cSeriori	:= NJM->NJM_DOCSER
	cItemOri	:= Soma1(Strzero(0, TamSX3("D2_ITEMORI")[1]))

	//-- Natureza Financeira --//
	cNatuFin := " "
	
	cNatuFin := Posicione("N9A",1,NJM->(NJM_FILORG + NJM_CODCTR + NJM_ITEM + NJM_SEQPRI),"N9A_NATURE")

	// Inclusao dos dados do Cabecalho do pedido
	cNumPed     := GetSxeNum( "SC5", "C5_NUM" )
	RollBAckSx8()   //Para não pular o numero.

	cCliente := Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),"NJ0_CODCLI")
	cLojClie := Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),"NJ0_LOJCLI")

	aAdd( aCab, { "C5_NUM"    , cNumPed, Nil} )
	aAdd( aCab, { "C5_CLIENTE", cCliente, Nil } ) 
	aAdd( aCab, { "C5_LOJACLI", cLojClie, Nil } )

	//Inclui o tipo de devolução
	aAdd( aCab, { "C5_TIPO", "C", Nil } )
	If SC5->(FieldPos("C5_TPCOMPL")) > 0
		aAdd( aCab, {"C5_TPCOMPL", cTipo, Nil } )	//1=Preço; 2=Complemento
	EndIf

	//Utiliza a condição de pagamento tipo 9 do romaneio
	aAdd( aCab, {"C5_CONDPAG" , NJM->NJM_CONDPG, Nil } )
	aAdd( aCab, {"C5_NATUREZ" , cNatuFin      , Nil } )

	//verifica condição de pagamento, se for tipo 9 pega do contrato
	dBSelectArea("SE4")
	SE4->(DbSetOrder(1))
	If SE4->(DbSeek( xFilial("SE4")+ NJM->NJM_CONDPG ))

		If SE4->E4_TIPO == "9"
			//chama função utilizada no romaneio
			If Len(aVenc) > 0
				aDatasVenc  := aVenc
			Else
				OGX008CDTV(NJM->NJM_FILIAL, NJM->NJM_CODROM, NJM->NJM_ITEROM, NJM->NJM_VLRUNI, @aDatasVenc, @aVlrUni)
			EndIf

			nDifVal := 0
			nMedia	:= 0

			If Len(aDatasVenc) > 0
				//soma as quantidades das datas
				For nX := 1 To Len(aDatasVenc)
					nMedia +=  aDatasVenc[nX][2]
				Next

				For nX := 1 to Len(aDatasVenc)
					//se a data for menor que hoje, seta como hoje
					If aDatasVenc[nX][1] < dtos(dDatabase)
						aAdd(aCab, {"C5_DATA"+AllTrim(STR(nX)), dDatabase, Nil})
					Else
						aAdd(aCab, {"C5_DATA"+AllTrim(STR(nX)), stod(aDatasVenc[nX][1]), Nil})
					EndIf

					//busca o percentual
					nPreCalc := Round( ((aDatasVenc[nX][2] * 100) / nMedia ), TamSX3("C5_PARC1")[2])

					//se a condição de pagamento usar percentual, caso contrário ele aplica a quantidade
					If Alltrim(SE4->(E4_COND)) = "%"
						//se for percentual faz uma regra de 3
						aAdd(aCab, {"C5_PARC"+AllTrim(STR(nX)), nPreCalc , Nil})
					Else
						nValCalc := Round( ((nValor * nPreCalc) / 100), TamSX3("C5_PARC1")[2])
						//verifica é a ultima linha e se tem diferença para incluir ja ajustado
						aAdd(aCab, {"C5_PARC"+AllTrim(STR(nX)), nValCalc , Nil})
					EndIf

				Next nX

			Else
				// se nao achar joga com data de hoje
				aAdd(aCab, {"C5_DATA1", dDatabase, Nil})
				If Alltrim(SE4->(E4_COND)) = "%"
					aAdd(aCab, {"C5_PARC1", 100, Nil}) //100%
				Else
					aAdd(aCab, {"C5_PARC1", nValor, Nil})
				EndIf
			EndIf

		EndIf
	EndIf

	//Informa o item que terá o complemento
	aLinha := {}
	aAdd( aLinha, { "C6_ITEM"		, Soma1(StrZero(Val("0"), TamSX3("C6_ITEM")[1] ))	, Nil } )
	aAdd( aLinha, { "C6_PRODUTO"	, NJM->NJM_CODPRO	, Nil } )
	aAdd( aLinha, { "C6_PRCVEN"		, nValor			, Nil } )
	aAdd( aLinha, { "C6_VALOR"		, nValor			, Nil } )
	aAdd( aLinha, { "C6_TES"		, NJM->NJM_TES		, Nil } )
	aAdd( aLinha, { "C6_NFORI"		, cNfOri            , Nil } )
	aAdd( aLinha, { "C6_SERIORI"	, cSeriori          , Nil } )
	aAdd( aLinha, { "C6_ITEMORI"	, cItemOri          , Nil } )
	//joga o array na linha dos itens
	aAdd( aItens, aLinha )

	// Criando a Tab. de vinculo com Cab Pedido de venda
	aadd( aVincCab, { "N8H_FILIAL"  , NJM->NJM_FILIAL 								} ) //usa mesma filial do romaneio
	aadd( aVincCab, { "N8H_NUMPV"   , cNumPed                                       } )
	aadd( aVincCab, { "N8H_CODCTR"  , NJM->NJM_CODCTR			 					} )
	aadd( aVincCab, { "N8H_CODROM"  , NJM->NJM_CODROM								} )
	aadd( aVincCab, { "N8H_CODFIX"  , ""                                            } )
	aadd( aVincCab, { "N8H_CODOTR"  , ""											} )
	aadd( aVincCab, { "N8H_ORPGRC"  , ""											} )
	aadd( aVincCab, { "N8H_ORIGEM"  , "OGA450"										} )
	aAdd( aVincCab, { "N8H_HISTOR"  , STR0042                                       } ) //Emissão de pv. de complemento de preço

	//Criando Vinculo com SC5 / SC6
	aadd( aLinhaVinc, { "N8I_FILIAL" , NJM->NJM_FILIAL 							} ) //usa mesma filial do romaneio
	aadd( aLinhaVinc, { "N8I_ITEMPV" , Soma1(StrZero(Val("0"), TamSX3("C6_ITEM")[1] ))} )
	aadd( aLinhaVinc, { "N8I_PRODUT" , NJM->NJM_CODPRO                          } )
	aadd( aLinhaVinc, { "N8I_TPPROD" , ""			 							} )
	aadd( aLinhaVinc, { "N8I_CODCTR" , NJM->NJM_CODCTR							} )
	aadd( aLinhaVinc, { "N8I_SAFRA"  , NJM->NJM_CODSAF                          } )
	aadd( aLinhaVinc, { "N8I_CODROM" , NJM->NJM_CODROM							} )
	aadd( aLinhaVinc, { "N8I_ITEROM" , NJM->NJM_ITEROM							} )
	aadd( aLinhaVinc, { "N8I_CODOTR" , ""										} )
	aadd( aLinhaVinc, { "N8I_ITEOTR" , ""										} )
	aadd( aLinhaVinc, { "N8I_CODFIX" , ""               						} )
	aadd( aLinhaVinc, { "N8I_ORPGRC" , "" 										} )
	aadd( aLinhaVinc, { "N8I_ORIGEM" , "OGA450"		 							} )
	aAdd( aLinhaVinc, { "N8I_HISTOR" , STR0042                                  } )  //complemento de preço gerao pelo gestao de entidade

	aAdd( aVincITE, aLinhaVinc )

	//ordena os arrays de acordo com o dicionário para passar para rotina automárica
	aCab   := FWVetByDic(aCab	, 'SC5', .F.)
	aItens := FWVetByDic(aItens	, 'SC6', .T.)

	//controle de filial para gerar na filial que vem da tela
	cFilAtu := cFilAnt
	cFilAnt := NJM->NJM_FILIAL

	//gera o pedido de venda
	/* Necessitamos solicitar o modulo pois alguns campos como LOTE e DTLOTE
	não estao setados para trabalhar com o SIGAAGR */
	cModulo := "FAT" // FIN ALTERADO POIS GERAVA ERRO DE C6_CODROM INVALIDO NO ROMANEIO S/PESAGEM
	nModulo := 5			
			
	MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCab, aItens, 3)
	
	//Retornando o modulo do SIGAAGR
	cModulo := cModAtu
	nModulo := nModAtu

	If lMsErroAuto
		ROLLBACKSX8()
		cMsgErr := sfAchaErro() //retorna o erro do MATA
		Return {.F., cMsgErr}
	Else
		ConfirmSX8()

		If __lnewNeg
			//ao confirmar o pedido de venda, gera relacionamento nas tabela N8H e N8I
			fAgrVncPV(aVincCab, aVincITE, 3)
		EndIf
		//chama rotina para gerar a NF com base no pedido
		aGerouDoc := AgrGeraNFS( cNumPed, cSerieNFC )

		If  ( ValType(aGerouDoc) == "A" .And. Len(aGerouDoc) > 0 )
			cNewNFC     := aGerouDoc[1]
			cNewSNFC    := aGerouDoc[2]
			cAliasQry := GetNextAlias()

			If Len(aItensNKC) > 0
				For nX := 1 To Len(aItensNKC)

					// busca o sequencia
					If Select(cAliasQry) <> 0
						(cAliasQry)->(dbCloseArea())
					EndIf

					cQuery := " SELECT MAX(NKC_ITEM) AS ITEM"
					cQuery += " FROM " + RetSqlName('NKC')
					cQuery += " WHERE D_E_L_E_T_ = '' "
					cQuery +=   " AND NKC_FILIAL = '" + aItensNKC[nX][1][2] + "' "
					cQuery +=   " AND NKC_CODCTR = '" + aItensNKC[nX][2][2] + "' "
					cQuery +=   " AND NKC_ITEMFX = '" + aItensNKC[nX][3][2] + "' "
					cQuery +=   " AND NKC_CODROM = '" + aItensNKC[nX][4][2] + "' "
					cQuery +=   " AND NKC_ITEROM = '" + aItensNKC[nX][5][2] + "' "

					cQuery := ChangeQuery(cQuery)

					dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

					If (cAliasQry)->(!Eof())
						cItemNKC := IIF(Empty((cAliasQry)->ITEM),"0", (cAliasQry)->ITEM)

						cItemNKC := Soma1(StrZero(Val(cItemNKC), TamSX3("NKC_ITEM")[1]))
					EndIF

					//grava tabela NKC com base nos ajustes de fixações
					//ATENCAO não aterar a ordem dos campos sem ajustar o OGA450
					if Reclock('NKC',.T. )
						NKC->NKC_FILIAL	:= aItensNKC[nX][1][2]  //1
						NKC->NKC_CODCTR	:= aItensNKC[nX][2][2]  //2
						NKC->NKC_ITEMFX	:= aItensNKC[nX][3][2]  //3
						NKC->NKC_CODROM	:= aItensNKC[nX][4][2]  //4
						NKC->NKC_ITEROM	:= aItensNKC[nX][5][2]  //5
						NKC->NKC_ITEM	:= cItemNKC         //6
						NKC->NKC_SERIE	:= cNewsNFC         //7
						NKC->NKC_DOCTO	:= cNewNFC          //8
						NKC->NKC_PREFIX	:= "NFC"            //9
						NKC->NKC_FORMUL	:= "S"              //10
						NKC->NKC_QTD	:= aItensNKC[nX][11][2] //11
						NKC->NKC_VRUN	:= aItensNKC[nX][12][2] //12
						NKC->NKC_VRTOT	:= aItensNKC[nX][13][2] //13
						NKC->NKC_VRIMP  := aItensNKC[nX][14][2] //14
						NKC->NKC_DATA	:= dDataBase        //15
						NKC->NKC_TPDOC	:= "2"              //16 //-- Nf. de Complemento de Preço Saida/Entrada
						NKC->NKC_PEDIDO	:= cNumPed	        //17 //-- Para Ctr.Venda Grava o nr. do Pedido
						NKC->NKC_FORCLI := cCliente         //18
						NKC->NKC_LOJA   := cLojClie	        //19
						NKC->( MsUnLock() )
					EndIf
				Next
			Else
				//grava tabela NKC sem fixacao pois é apenas um complemento forçado sem ajuste
				If Reclock('NKC',.T. )
					NKC->NKC_FILIAL	:= NJM->NJM_FILIAL
					NKC->NKC_CODCTR	:= NJM->NJM_CODCTR
					NKC->NKC_ITEMFX	:= " "
					NKC->NKC_CODROM	:= NJM->NJM_CODROM
					NKC->NKC_ITEROM	:= NJM->NJM_ITEROM
					NKC->NKC_ITEM	:= cItemNKC
					NKC->NKC_SERIE	:= cNewsNFC
					NKC->NKC_DOCTO	:= cNewNFC
					NKC->NKC_PREFIX	:= "NFC"
					NKC->NKC_FORMUL	:= "S"
					NKC->NKC_QTD	:= 0        //NOTA DE COMPLEMENTO SO TEM VALOR
					NKC->NKC_VRUN	:= nValor
					NKC->NKC_VRTOT	:= nValor
					NKC->NKC_VRIMP  := 0        // trata a retenção de impostos posteriormente
					NKC->NKC_DATA	:= dDataBase
					NKC->NKC_TPDOC	:= "2"      //-- Nf. de Complemento de Preço Saida/Entrada
					NKC->NKC_PEDIDO	:= cNumPed	//-- Para Ctr.Venda Grava o nr. do Pedido
					NKC->NKC_FORCLI := cCliente
					NKC->NKC_LOJA   := cLojClie
					NKC->( MsUnLock() )
				EndIf
			EndIf
		Else
			cMsgErr := STR0047 //Problema ao gerar a Nota fiscal de Complemento na
			Return {.F., cMsgErr}
		EndIF
	Endif

	cFilAnt := cFilAtu

	RestArea( aAreaNJM )
	RestArea( aAreaSC5 )
	RestArea( aAreaSC6 )
	RestArea( aAreaSE4 )
	RestArea( aAreaAtu )

Return {.T., cMsgErr,cNewNFC,cNewsNFC}

/** {Protheus.doc} sfAchaErro
Função que le o log. de erro do Execauto, e retorna os cpos. que apresentaram incocistencia
@param: 	nil
@return:	cMemo.
@author: 	filipe.olegini
@since: 	13/07/2018
*/
Static Function sfAchaErro()
	Local cFileLog  as char
	Local cRet	    as char
	Local nPos	    as numeric
	Local cConteudo as char

	cFileLog	:= NomeAutoLog() //Alltrim(cStartPath) + Alltrim(NomeAutoLog())
	cRet		:= ""
	nPos		:=0
	cConteudo	:= MemoRead( cFileLog ) //Pega o Conteudo do Arquivo Texto do LOG

	If "HELP: OBRIGAT" $ cConteudo
		cRet := StrTran(cConteudo,chr(13)+chr(10)," ")
	Else

		aConteudo := Separa(cConteudo,chr(13)+chr(10))

		For nPos := 1 to Len(aConteudo)
			IF len(aconteudo[npos]) == 0
				Exit
			EndIf
			cRet += aConteudo[nPos] + chr(13)+chr(10)
		next nPos

		For nPos := nPos + 1 to Len(aConteudo)
			If "< -- Invalido" $ aConteudo[nPos]
				cRet += aConteudo[nPos] + chr(13)+chr(10)
			EndIF
		next nPos
	EndIf

	fErase(cFileLog)

Return ( cRet )

/*/{Protheus.doc} NFSNJMSD2
//TODO Descrição auto-gerada.
@author claudineia.reinert
@since 11/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodRom, characters, codigo do romaneio
@param cItemRom, characters, item do romaneio na NJM
@param cSubTipo, characters, codigo do subtipo do romaneio na NJM
@type function
/*/
Static Function NFSNJMSD2(cCodRom, cItemRom, cSubTipo)
	Local aAreaAtu := GetArea()
	Local aNFVnd := {}
	Local cAliasQry := GetNextAlias()
	Local cQuery := ''

	Default cItemRom = ''
	Default cSubTipo = ''

	cQuery := " SELECT SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_ITEM "
	cQuery += " FROM " + RetSqlName('NJM') + " NJM "
	cQuery += " INNER JOIN " + RetSqlName('NJJ') + " NJJ ON NJJ.D_E_L_E_T_ = '' AND NJJ_FILIAL = NJM_FILIAL "
	cQuery += "     AND NJJ_CODROM = NJM_CODROM AND NJJ_STATUS = '3' AND NJJ_STAFIS = '2' "
	cQuery += " INNER JOIN " + RetSqlName('N8K') + " N8K ON N8K.D_E_L_E_T_ = '' AND N8K.N8K_FILIAL = NJM.NJM_FILIAL "
	cQuery += "     AND N8K.N8K_CODROM = NJM.NJM_CODROM AND N8K.N8K_ITEROM = NJM.NJM_ITEROM "
	cQuery += "     AND N8K.N8K_DOC = NJM_DOCNUM AND N8K.N8K_SERIE = NJM_DOCSER "
	cQuery += " INNER JOIN " + RetSqlName('SD2') + " SD2 ON SD2.D_E_L_E_T_ = '' AND SD2.D2_FILIAL = N8K.N8K_FILIAL AND SD2.D2_DOC = N8K.N8K_DOC "
	cQuery += "     AND SD2.D2_SERIE = N8K.N8K_SERIE AND SD2.D2_ITEM = N8K.N8K_ITEDOC "
	cQuery += " WHERE NJM.D_E_L_E_T_ = '' AND NJM.NJM_FILIAL = '"+ FWxFilial('NJJ') +"' "
	cQuery += " AND NJM_CODROM = '"+ cCodRom +"' AND NJM_TIPO = '4' "
	If !Empty(cItemRom)
		cQuery += " AND NJM_ITEROM = '"+ cItemRom +"' "
	ElseIf !Empty(cSubTipo)
		cQuery += " AND NJM_SUBTIP = '"+ cSubTipo +"' "
	EndIf
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If !(cAliasQry)->(Eof())
		AADD(aNFVnd, (cAliasQry)->D2_DOC   )
		AADD(aNFVnd, (cAliasQry)->D2_SERIE )
		AADD(aNFVnd, (cAliasQry)->D2_ITEM  )
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aAreaAtu)

Return aNFVnd

/*/{Protheus.doc} fValSaldo
    Função para verificar se há pedidos em aberto que possam comprometer o saldo de devolução
    @type  Static Function
    @author user
    @since 11/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fValSaldo(aAux, cProduto, nQtdDev, nQtdSel, nValDev, nValSel)
        
    Local cPedidos := ""
    Local nX       := ""
    Local lRetorno := .T.

    //--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9		
    If _lCtrlTer .OR. _lCtrlDev        
        If !(lRetorno := (nQtdDev = nQtdSel))
            AgrHelp(STR0001, STR0050) //"Quantidade devolvida é diferente da quantidade selecionada."
        EndIf
    EndIf

    //--Se for devolução valor
    If _lCtrlDVl
        If !(lRetorno := (nValDev = nValSel))
            AgrHelp(STR0001, STR0051, "") //"Valor de devolução é diferente do valor selecionado."
        EndIf
    EndIf

    //--Se for complemento
    If _lCtrlCom
        lRetorno := .T.
    EndIf     

    If (_lCtrlTer .or. _lCtrlDev) .and. lRetorno 
        For nX := 1 To Len(aAux)
            If aAux[nX, COL_MARK] == "1"            
                fQryPedido(_cCliEntr, _cLojEntr, cProduto, aAux[nX, COL_DOC], aAux[nX, COL_SERIE], aAux[nX, COL_IDENTB6], @cPedidos)                
            EndIf
        Next nX

        If !Empty(cPedidos)                    
            AgrHelp(STR0001, STR0049 + cPedidos, "") //"Não é possível continuar, pois o saldo está comprometido pelo(s) pedido(s) em aberto: "
            lRetorno := .F.
        EndIf            
    EndIf
    
Return lRetorno

/*/{Protheus.doc}  fQryPedido
    Função para executar a query na tabela de pedidos para verificar se existem
    pedidos em aberto que possam comprometer o saldo de devol. 
    @type  Static Function
    @author user
    @since 11/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fQryPedido(cCliente, cLoja, cProduto, cNFOrig, cSerOrig, cIdentb6, cPedidos)
    Local cAliasQry := GetNextAlias()
    Local aPedido   := {}    

    BeginSql Alias cAliasQry
        SELECT C6_NUM, C6_QTDVEN, C6_QTDEMP, C6_QTDENT 
          FROM %table:SC6% 
        WHERE C6_FILIAL  = %xFilial:SC6%
          AND C6_CLI     = %Exp:cCliente%
          AND C6_LOJA    = %Exp:cLoja%
          AND C6_PRODUTO = %Exp:cProduto%
          AND C6_NFORI   = %Exp:cNFOrig%
          AND C6_SERIORI = %Exp:cSerOrig%
          AND C6_IDENTB6 = %Exp:cIdentb6%
          AND %notDel%
    EndSql

    While (cAliasQry)->(!eof())
        If aScan(aPedido,{|x| x == (cAliasQry)->C6_NUM}) == 0 .And.  (Max((cAliasQry)->C6_QTDVEN,(cAliasQry)->C6_QTDEMP)-(cAliasQry)->C6_QTDENT) > 0            
            aAdd(aPedido,(cAliasQry)->C6_NUM)
            If Empty(cPedidos)
                cPedidos += alltrim((cAliasQry)->C6_NUM)
            Else
                cPedidos += ", " + alltrim((cAliasQry)->C6_NUM)
            EndIf
        EndIf
    
        (cAliasQry)->(dbskip())
    EndDo

    (cAliasQry)->(dbCloseArea())    
    
Return

/** {Protheus.doc} fParVencMC
Para o comercialização classica, gera array com dados de data e valor da parcela conforme total do pedido 
gerando as parcelas conforme saldo da SE1 gerado pela previsão financeira do contrato.
@param cCliente, characters, codigo do cliente
@param cLoja, characters, loja do cliente
@param dEmissao, data, data padrão para emissão 
@param nTotPed, numerico, total do pedido
@return:    aDados - array - array com 2 posições, primeira será a data de vencimento, segundo será o valor para a parcela
@author:    claudineia.reinert
@since:     13/10/2020
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function fParVencMC(cCodctr, cCliente, cLoja, dEmissao, nTotPed)
	Local aDados := {}
	Local cQry := ""
	Local cAliasQry := GetNextAlias()
	Local nParc := 0 
	Local nTotPedVenc := nTotPed
	
	cQry := " SELECT SE1.* "
	cQry += " FROM " + RetSqlName("SE1") + " SE1 "
	cQry += " WHERE SE1.E1_FILIAL = '" + FWxFilial( "SE1" ) + "' "
	cQry += "   AND SE1.E1_NUM = '" + cCodctr + "' "
	cQry += "   AND SE1.E1_PREFIXO = 'CTR' "
	cQry += "   AND SE1.E1_TIPO = 'PR' "
	cQry += "   AND SE1.E1_CLIENTE = '" + cCliente + "' "
	cQry += "   AND SE1.E1_LOJA = '" + cLoja + "' "
	cQry += "   AND SE1.D_E_L_E_T_ = '' "
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		If (cAliasQry)->( E1_VALOR ) > 0
			
			If (cAliasQry)->( E1_VENCTO ) < DToS(dEmissao)
				nParc := aScan(aDados, {|x| x[1] ==  dEmissao })
				If nParc = 0 
					nParc := Len(aDados) + 1
					aAdd( aDados, { dEmissao , 0 } )
				EndIf
			Else
				nParc := Len(aDados) + 1
				aAdd( aDados, { cToD(SUBSTR((cAliasQry)->( E1_VENCTO ), 7, 2) + "/" + SUBSTR((cAliasQry)->( E1_VENCTO ), 5, 2) + "/" + SUBSTR((cAliasQry)->( E1_VENCTO ), 1, 4)), 0 } )
			EndIf

			If (cAliasQry)->( E1_VALOR ) < nTotPedVenc
				nTotPedVenc -= (cAliasQry)->( E1_VALOR )
				aDados[nParc][2] += (cAliasQry)->( E1_VALOR )
			Else
				aDados[nParc][2] += nTotPedVenc
				nTotPedVenc := 0
				Exit
			EndIf
			
		EndIf
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->(DbCloseArea())

Return aDados

/** {Protheus.doc} fTotaltNota
Para o comercialização classica, soma o total das notas de retorno para que não haja diferença entre a nota original e as notas de retorno
Exemplo: Na devolução o valor da devolução deve ser o mesmo da entrada, se entrou quantidade de 10.000 a um valor de R$10.000 não poderá retornar q quantidade de 10.000 com uma valor de R$10.001 ou R$9.999, o sistema não permite.
@author:    felipe.mendes
@since:     13/10/2021
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function fTotaltNota( aSelNfs , nX )
	Local nVlrTotEnt := 0
	Local nVlrTotSai := 0
	Local cAliasQry := GetNextAlias()
	Local cQry := ''
	Local nVlrDist := aSelNfs[ nX, COL_VDISTR ] 
	Local nSaldo := 0 

	nVlrTotEnt    := Posicione( "SD1", 1, FWxFilial( "SD1" ) + aSelNfs[ nX, COL_DOC ] + aSelNfs[ nX, COL_SERIE ], "D1_TOTAL" )

	//valida se o valor(R$) esta fechando
	cQry := " SELECT SUM(C6_VALOR) VALOR"
	cQry += " FROM " + RetSqlName("SC6") + " SC6 "
	cQry += " WHERE SC6.C6_FILIAL = '" + FWxFilial( "SC6" ) + "' "
	cQry += "   AND SC6.C6_NFORI = '" + aSelNfs[ nX, COL_DOC ] + "' "
	cQry += "   AND SC6.C6_SERIORI = '" + aSelNfs[ nX, COL_SERIE ] + "' "	
	cQry += "   AND SC6.D_E_L_E_T_ = '' "
	cQry := ChangeQuery( cQry )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		nVlrTotSai :=(cAliasQry)->VALOR
		(cAliasQry)->( dbSkip() )
	EndDo
	(cAliasQry)->(DbCloseArea())

	nSaldo := nVlrTotEnt - ( nVlrTotSai + nVlrDist ) //saldo de valor(R$)

	If nSaldo = 0.01 .or. nSaldo = -0.01
		nVlrDist := nVlrTotEnt - nVlrTotSai  //ajusta para não sobrar/ultrapassar total(R$) da NF de entrada
	Endif

Return nVlrDist
 