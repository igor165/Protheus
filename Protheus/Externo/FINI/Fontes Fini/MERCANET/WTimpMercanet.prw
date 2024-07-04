#Include 'Totvs.ch'
#Include 'TbiConn.ch'
#Include 'TopConn.ch'

/*
|==============================================================================|
|                           S A N C H E Z   C A N O                            |
|==============================================================================|
| Programa  | WTIMPMERCANET   |Autor  Cristian Müller      |Data 03/04/2016    |
|-----------+------------------------------------------------------------------|
|           |                                                                  |
|           |                                                                  |
| Descrição | Rotina via JOB para integração de Pedidos de Vendas vindos       |
|           | do Mercanet.                                                     |
|           |                                                                  |
|           |                                                                  |
|           |                                                                  |
|           |                                                                  |
|-----------+------------------------------------------------------------------|
|    Uso    |   Protheus      | Móduto | Faturamento      | Chamado |          |
|------------------------------------------------------------------------------|
|>>>>>>>>>>>>>>>>>>>>>>>>>> Histórico de Alterações <<<<<<<<<<<<<<<<<<<<<<<<<<<|
|------------------------------------------------------------------------------|
|   Data    |               Alteração               |    Autor     |  Chamado  |
|-----------+---------------------------------------+--------------+-----------|
|==============================================================================|
*/

User Function impMercanet(_par01)

	Local   cEmp           := _par01
	Local   cFil           := "01"
	Local   cQry           := ""
	Local   cPedRet        := ""
	Local   cFilaPro       := ""
	Local   lResiduo
	Local   cFilBkp
	Local   lEstOk
	Local   lCotaOk  
	Local   lShelfOK 
	Local   aRetEst        := {}

    Private cVerMerc       := "[MERCANET V.2022-10]"
	Private cDescEmp       := iif(cEmp=="01","01-SANCHEZ","02-FINI")
	Private cStatus        := ""
	Private cTxtErr        := ""
	Private cSemaforo      := ""
	Private cTopPed
	Private lTemComis
	Private lTemRegra      // Define se cliente tem regra de shelf-life   
	Private lShlfON        // Define se a regra shelf-life esta ativa ou nao - Parametro ZZ_MERCSHF   

	//---------------------------------------------------------------------
	// Inicializa ambiente sem consumir licencas
	//---------------------------------------------------------------------
	RPCSetType(3)
	RpcSetEnv(cEmp,cFil,,,,GetEnvServer(),{ })

	//---------------------------------------------------------------------
	// Verifica semaforo de integracao para continuar
	//---------------------------------------------------------------------
	cSemaforo := U_GETZPA("SEMAFORO_MERCANET","ZZ")
	if cSemaforo == "OFF"
		ConOut( "(SEMAFORO_MERCANET=OFF) "+dtoc( Date() )+" "+Time()+" Semaforo fechado para integracao de pedidos." )
		RpcClearEnv()
		return
	else
		ConOut( cVerMerc + space(01) + dtoc( Date() )+" "+Time()+" Inicio integracao de pedidos - Empresa "+cDescEmp )
		// Caio Souza 06/04/2022 - Segregação da fila de processamento de pedidos
		cFilaPro := U_GETZPA("FILA_PED_MERCANET","ZZ")
		DbSelectArea("ZPA")
    	ZPA->(DbSetOrder(1))
    	ZPA->(DbGoTop())
		ConOut( cVerMerc + space(01) + dtoc( Date() )+" "+Time()+" Processando Pedidos da Fila "+cFilaPro )
	endif

	//---------------------------------
	// Guarda filial corrente
	//---------------------------------
	cFilBkp := cFilAnt

	//-------------------------------------
	// Obtem total de pedidos a processar
	//-------------------------------------
	cTopPed := getMv("ZZ_MERCPED")

	//-----------------------------------------
	// Verifica se regra shelf-life esta ativa
	//-----------------------------------------
    lShlfON := GETNEWPAR("ZZ_MERCSHF", .F.) 
	ConOut( cVerMerc + space(01) + dtoc( Date() )+" "+Time()+" Regra SHELF-LIFE esta "+iif(lShlfON,"ATIVADA","DESATIVADA") + " (ZZ_MERCSHF)" )

	//---------------------------------------------------------------
	// Seleciona pedidos pendentes enviados pelo Mercanet
	// Orderna por fila de entrada para processamento
	//---------------------------------------------------------------
	cQry := " SELECT TOP " + alltrim(cTopPed) + " "
	cQry += " ZC5_FILIAL,ZC5_NUM,ZC5_CLIENT,ZC5_LOJACL,ZC5_TRANSP,ZC5_CONDPA,ZC5_TABELA,ZC5_VEND1,ZC5_BANCO,ZC5_EMISSA, "
	cQry += " ZC5_VTOT,ZC5_PEDMER,ZC5_STATUS,ZC5_FILA,ZC5_DTINC,ZC5_HRINC,ZC5_DTINI,ZC5_HRINI,ZC5_DTFIM,ZC5_HRFIM,ZC5_ESTOK, "
	cQry += " ZC5_MENNOT,ZC5_TPFRET,ZC5_PROCRT,ZC5_TIPVEN,ZC5_PEDPAI,ZC5_VLDEST,ZC5_ELIRES,ZC5_ZZDSCB,ZC5_MTDSB1,ZC5_VLDSB1,ZC5_HSTDB1, "
	cQry += " ZC5_MTDSB2,ZC5_VLDSB2,ZC5_HSTDB2,ZC5_MTDSB3,ZC5_VLDSB3,ZC5_HSTDB3,ZC5_ZZMOTB,ZC5_ZZDEST,ZC5_ZZDESB,ZC5_EDI,ZC5_PEDCLI,ZC5_PEDEMI, "
	cQry += " ZC5_DATENT,ZC5_EANFOR,ZC5_EANCPR,ZC5_EANCOB,ZC5_EANENT,ZC5_CNPCLI,ZC5_CNPCOB,ZC5_CNPENT,ZC5_NOMARQ,ZC5_TPMERC, "
	cQry += " ZC5_PERSB1 , ZC5_PERSB2 , ZC5_PERSB3 , ZC5_USRINC, ZC5_EMAILC, ZC5_VLDPRO " //Caio Souza 11/10/2022 - Projeto Desconto NF
	cQry += " FROM " + retSqlName("ZC5") + " ZC5 WITH(NOLOCK) "
	cQry += " WHERE ZC5.D_E_L_E_T_ = '' "
	cQry += " AND ZC5.ZC5_STATUS = '' "
	cQry += " AND ZC5.ZC5_PROCRT = 'L' "  // Nova condicao para processar somente quando ok do mercanet de que todos os itens foram enviados para a integracao.
	// Caio Souza 06/04/2022 - Segregação da fila de processamento de pedidos (Já prepara a proxima fila para execução)
	If cFilaPro == 'NORMAL'
		cQry += " AND ZC5.ZC5_EMAILC = '' "
		If ZPA->(DbSeek(FWxFilial("ZPA")+'ZZ'+'FILA_PED_MERCANET'))
			If Alltrim(ZPA->ZPA_CONTEUD) == 'NORMAL'
				RecLock('ZPA',.F.)
		   		ZPA->ZPA_CONTEUD := 'COTA'	
				ZPA->(MsUnlock())
			EndIf
		EndIf
	Else
		cQry += " AND ZC5.ZC5_EMAILC = 'S' "
		If ZPA->(DbSeek(FWxFilial("ZPA")+'ZZ'+'FILA_PED_MERCANET'))
			If Alltrim(ZPA->ZPA_CONTEUD) == 'COTA'
				RecLock('ZPA',.F.)
		   		ZPA->ZPA_CONTEUD := 'NORMAL'	
				ZPA->(MsUnlock())
			EndIf
		EndIf
	EndIf
	cQry += " ORDER BY ZC5.ZC5_FILA "
	TCQUERY cQry NEW ALIAS "TRBZC5"

	ZPA->(DbCloseArea())

	//-----------------------------------------------------------------
	// Gera pedido de vendas via MsExecAuto
	//-----------------------------------------------------------------
	dbSelectArea("TRBZC5")
	DBGoTop()
	do while !TRBZC5->(eof())

		lResiduo := .F. // Zera flag residuo eliminado
		cPedRet  := ""  // Nro pedido gerado Protheus

		//----------------------------
		// Ordem por fila tabela ZC5
		//----------------------------
		ZC5->(dbSetOrder(3))

		if ZC5->(MsSeek(TRBZC5->ZC5_FILA))

			//------------------------------------------
			// Se linha já processada, ignora registro
			//------------------------------------------
			if !empty(ZC5->ZC5_STATUS)
				TRBZC5->(dbSkip())
				loop
			endif

			//-----------------------------
			// Troca filial conforme ZC5
			//-----------------------------
			cFilAnt := TRBZC5->ZC5_FILIAL

			//----------------------------------------------
			//- Mensagem de inicio de importacao no console
			//----------------------------------------------
			conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " + cDescEmp + " Filial " + cFilAnt + " -> Pedido " + alltrim(TRBZC5->ZC5_PEDMER) + " : Gerando pedido Protheus")

			//-------------------------------------------------------
			// Marca Status inicial como INI antes de rodar Execauto
			// Essa marca é necessaria pois caso ocorrer error log
			// os próximos pedidos da fila não serao prejudicados
			//-------------------------------------------------------
			ZC5->(reclock("ZC5",.F.))
			ZC5->ZC5_STATUS := "INI"
			ZC5->ZC5_DTINI  := DATE()
			ZC5->ZC5_HRINI  := TIME()
			ZC5->(msUnLock())

			//-----------------------------------------------------------
			// Posiciona Cliente
			//-----------------------------------------------------------
			SA1->(dbSetOrder(1))
			SA1->(dbSeek(xFilial("SA1")+ZC5->ZC5_CLIENT+ZC5->ZC5_LOJACL))

			//-------------------------------------------------------
			// Verifica se cliente tem shelf-life caso regra ativada 
			//-------------------------------------------------------
			if lShlfON 
				lTemRegra := iif(empty(SA1->A1_ZZREGRA),.F.,.T.) 
			else
	   			lTemRegra := .F. 
			endif 

			//------------------------------------------------------------------
			// Avalia se todos os itens do pedido terao estoque disponivel
			// Caso um ou mais itens não tiver  , nao importa o pedido.
			// Caso campo ZC5_VLDEST = 'N', forca a entrada e liberacao
			// do pedido no sistema com saldo disponivel no momento
			//------------------------------------------------------------------
			aRetEst  := avalEst(lTemRegra,ZC5->ZC5_VEND1,TRBZC5->ZC5_VLDEST)
			lEstOk   := aRetEst[1][1]
			lShelfOK := aRetEst[1][2]
			lCotaOK  := aRetEst[1][3]
    
			if TRBZC5->ZC5_VLDEST == "N"
				lEstOk   := .T.
				lShelfOK := .T. 
				lCotaOK  := .T. 
			endif

			//----------------------------------------------------------------
			// Gera pedido de vendas caso estoque Ok em todos os itens
			// ou pedido entrou com opcao de liberar o que estiver disponivel
			//----------------------------------------------------------------
			if lEstOk .and. lShelfOK .and. lCotaOK  

				//--------------------------------------------
				// Inclui e libera Pedido via MsExecAuto
				//--------------------------------------------
				cPedRet := geraPed(cEmp)

				if !empty(cPedRet)

					//-------------------------------------------------------------------
					// Chama funcao apos geracao e liberacao do pedido de vendas 
					// Verifica para eliminar residuos e atualizar campos customizados 
					//-------------------------------------------------------------------
					lResiduo := finalPedido(cPedRet)

					//------------------------------------------------------------------
					// Verifica se exitem motivos de bonificacao no pedido
					// Caso existir, atualiza o nro do pedido do Protheus na tabela ZC7
					//------------------------------------------------------------------
					atuBonific(cPedRet)

				endif

				//--------------------------------------
				// Define Flag de Estoque OK
				//--------------------------------------
				do case
				case TRBZC5->ZC5_VLDEST == "S"  // Validou todo o estoque como Ok
					cFlagEst := "S"
				case TRBZC5->ZC5_VLDEST == "N"
					cFlagEst := "N"
				otherWise
					cFlagEst := ""
				endcase

				//---------------------------------------
				// Atualiza status final no ZC5
				//---------------------------------------
				ZC5->(reclock("ZC5",.F.))
				ZC5->ZC5_STATUS := cStatus
				ZC5->ZC5_ESTOK  := cFlagEst
				ZC5->ZC5_DTFIM  := DATE()
				ZC5->ZC5_HRFIM  := TIME()
				ZC5->ZC5_ERRO   := cTxtErr
				ZC5->ZC5_NUM    := cPedRet
				ZC5->ZC5_ELIRES := iif(lResiduo,"S","")
				ZC5->(msUnLock())


			else

				//---------------------------------------
				// Estoque Nao OK . Grava status erro
				//---------------------------------------
				ZC5->(reclock("ZC5",.F.))
				ZC5->ZC5_STATUS := "ERR"
				ZC5->ZC5_ESTOK  := "N"
				ZC5->ZC5_DTFIM  := DATE()
				ZC5->ZC5_HRFIM  := TIME()
				ZC5->(msUnLock())

			endif

			//-----------------------------
			// Retorna filial padrao
			//-----------------------------
			cFilAnt := cFilBkp

		endif

		//----------------------------
		// Proximo pedido a integrar
		//----------------------------
		TRBZC5->(dbSkip())

	enddo

	//---------------------------------
	// Finaliza ambiente
	//---------------------------------
	TRBZC5->(dbCloseArea())
	RpcClearEnv()

	ConOut( cVerMerc + space(01) + dtoc( Date() )+" "+Time()+" Final Processamento PEDIDOS - "+cDescEmp )

Return



//=================================================================================
// 
//
// Funcao para a inclusao de pedidos vindos do Mercanet no Protheus via Execauto
//
//
//================================================================================= 
Static Function geraPed(cEmp)

	Local aCabec           := {}
	Local aLinha           := {}
	Local aItens           := {}
	Local aQtLib           := {}
	Local aLog             := {}
	Local cRet             := ""
	Local cMarca           := ""
	Local cEmail           := U_GETZPA("EMAIL_ERRO_MERCANET","ZZ")        // E-mail para envio de aviso de erros
	Local cPedCli          := ""
	Local nXitem           := 1
	Local nMoedPad		   := 1
	Local cItem            := "01"
	Local cCCven           := space(09)
	Local cProcWIS         := ""
	Local nQtdLib          := 0
	Local aCota            := {} 
    Local lTemRegra        
	Local nX

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .T.
	Private lAutoErrNoFile := .T.
	Private nVlrTot	       := 0

	//-----------------------------------------------
	// Posiciona Cliente
	//-----------------------------------------------
	SA1->(dbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+TRBZC5->ZC5_CLIENT+TRBZC5->ZC5_LOJACL))

	//-------------------------------------------------------
	// Verifica se cliente tem shelf-life caso regra ativada 
	//-------------------------------------------------------
	if lShlfON 
		lTemRegra := iif(empty(SA1->A1_ZZREGRA),.F.,.T.) 
	else
	   lTemRegra := .F. 
	endif 

	//-----------------------------------------------
	// Posiciona Vendedor
	//-----------------------------------------------
	SA3->(DbSetOrder(1))
	SA3->(DbSeek(xFilial("SA3")+TRBZC5->ZC5_VEND1))

	//--------------------------------------------------------------
	// Busca tipo de pedidos VENDAS e TRADE MKT
	//--------------------------------------------------------------
	cTpVENDA  := alltrim(U_GETZPA("TPED_VENDA_MERCANET","ZZ"))
	cTpTRADE  := alltrim(U_GETZPA("TPED_TRADE_MERCANET","ZZ"))
	cTpTRADE2 := alltrim(U_GETZPA("TPED_TRADE2_MERCANET","ZZ")) // criar e colocar o tipo de pedido 85

	//--------------------------------------------------------------
	// Define regra para buscar nome e centro de custo do vendedor
	//--------------------------------------------------------------
	do case
		//- Pedido de Bonificacao -> Vendas Normais
	case UPPER(TRBZC5->ZC5_TIPVEN) == "B" .and. TRBZC5->ZC5_TPMERC $ cTpVENDA
		cCCven := SA3->A3_ZZCC
		//- Pedido de Venda ou Bonificacao -> Vendas Trade
	case UPPER(TRBZC5->ZC5_TIPVEN) $ "V,B" .and. TRBZC5->ZC5_TPMERC $ cTpTRADE
		cCCven := posicione("ZZP",1,xFilial("ZZP")+SA1->A1_SATIV1,"ZZP_CC")
		//- Pedido de Venda ou Bonificacao -> Vendas Trade (Material Leve/Display/PDV)
	case UPPER(TRBZC5->ZC5_TIPVEN) $ "V,B" .and. TRBZC5->ZC5_TPMERC $ cTpTRADE2
		cCCven := SuperGetMV('ZZ_CCPTMTL',.F.,'') // criar o parametro e incliur o cc 710216
	otherwise
		cCCven := space(9)
	endcase

	//-----------------------------
	// Atualiza itens do pedido
	//-----------------------------
	cQry := " SELECT * FROM " + retSqlName("ZC6") + " ZC6 WITH(NOLOCK)"
	cQry += " WHERE ZC6.D_E_L_E_T_ = '' "
	cQry += " AND ZC6.ZC6_FILIAL = '" + TRBZC5->ZC5_FILIAL + "' "
	cQry += " AND ZC6.ZC6_PEDMER = '" + TRBZC5->ZC5_PEDMER + "' "
	cQry += " ORDER BY ZC6.ZC6_FILIAL , ZC6.ZC6_PEDMER , ZC6.ZC6_ITPMER "
	TCQUERY cQry NEW ALIAS "TRBZC6"

	do while !TRBZC6->(eof())

		//------------------------------------------------------------------
		// Verifica saldo disponivel do item para efetuar a libercao SC9
		//------------------------------------------------------------------
		nSlEst := sldSB2(TRBZC6->ZC6_PRODUT,TRBZC6->ZC6_LOCAL) 

		//---------------------------------------------------------------
	    // Projeto COTAS 2022 
		// Calcula saldo disponivel da cota do Vendedor/Item do pedido 
		//---------------------------------------------------------------
		aCota := sldCota(TRBZC6->ZC6_FILIAL , TRBZC5->ZC5_VEND1, TRBZC6->ZC6_PRODUT ) 
		if aCota[1][3] <> 999999999  // itens que não possuem controle de cotas ficam com saldo 999.999.999 
			nSlEst  := aCota[1][3] - ( aCota[1][1] + aCota[1][2] )
		endif 

		//-------------------------------------------------------------------------
		// Calcula dias regra Shelf-life do cliente 
		// Calcula saldo disponivel conforme regra shelf-life caso cliente possuir  
		// Caso nao possuir regra de shelf-life, saldo sera o mesmo do SB2
		//-------------------------------------------------------------------------
		if lTemRegra
			nDiasShelf := u_CalcSLife(TRBZC6->ZC6_PRODUT, TRBZC6->ZC6_CLI, TRBZC6->ZC6_LOJA)
	       	nSlShelf   := saldoShelf(nDiasShelf,TRBZC6->ZC6_PRODUT,TRBZC6->ZC6_LOCAL,TRBZC6->ZC6_FILIAL)
		    //------------------------------------------------------------------------------------------
			// Se saldo disponivel shelf-life maior que o saldo SB2, iguala os saldos pois com novo WMS
			// os pedidos liberados que nao reservam lote no pedido, o saldo do SB8 fica sem empenho 
			//------------------------------------------------------------------------------------------
			if nSlShelf > nSlEst 
			   nSlShelf := nSlEst 
			endif 
			//-------------------------------------------------------------------------------------------
			// Para clientes com a regra shelf-life, considera o saldo disponivel dos lotes que atendem 
			// ao inves do total disponivel no SB2
			//-------------------------------------------------------------------------------------------
            nSlEst := nSlShelf 
	    else 
		    nDiasShelf := 0 
			nSlShelf   := nSlEst 
		endif 

	
	    //----------------------------------------------------------
		// Ajusta caso saldo disponivel for negativo 
		//----------------------------------------------------------
		if nSlEst < 0 
		   nSlEst := 0 
		endif 
	
	    //--------------------------------------------------------------
		// Define qtde a liberar conforme saldo disponível no momento 
		//--------------------------------------------------------------
		If nSlEst >= TRBZC6->ZC6_QTDVEN
			nQtdLib := TRBZC6->ZC6_QTDVEN
		Else
			nQtdLib := nSlEst
		EndIf

		//------------------------------------------------------
		// Se cliente possuir regra de shelf-life nao libera 
		// no padrao do execauto. Sera liberado apos geracao 
		// do pedido para selecionar lotes dentro da regra 
		//------------------------------------------------------
		if lTemRegra 
		   aadd( aQtLib ,  { nQtdLib , nDiasShelf }  )
		   nQtdLib := 0 
		endif 
		
		//--------------------------------------------------------
		//- Define qual nro de pedido do cliente sera gravado
		//--------------------------------------------------------
		if TRBZC5->ZC5_EDI == 'S'
			cPedCli := TRBZC5->ZC5_PEDCLI
		elseif Empty(TRBZC6->ZC6_PEDCLI)
			cPedCli := TRBZC6->ZC6_PEDMER
		else
			cPedCli := TRBZC6->ZC6_PEDCLI
		endif

		// Caio Souza 17/03/2022 - Validação de Moeda de acordo com a tabela de preço de venda (Projeto Comex-Mercanet)
		If TRBZC5->ZC5_TPMERC $ U_GETZPA("TIP_PEDIDO_VALDMOEDA","ZZ")
			nMoedPad := Posicione('DA1',1,xFilial('DA1')+UPPER(TRBZC5->ZC5_TABELA),'DA1_MOEDA')
		EndIf

		//---------------------------------------------------------------
		// Atualiza array do item do pedido para o execauto 
		//---------------------------------------------------------------
		dbSelectArea("TRBZC6") 
		aLinha := {}
		aadd(aLinha,{"C6_FILIAL"   , cFilAnt                    , Nil })
		aadd(aLinha,{"C6_ITEM"     , cItem                      , Nil })
		aadd(aLinha,{"C6_PRODUTO"  , UPPER(TRBZC6->ZC6_PRODUT)  , Nil })
		aadd(aLinha,{"C6_QTDVEN"   , TRBZC6->ZC6_QTDVEN         , Nil })
		aadd(aLinha,{"C6_QTDLIB"   , nQtdLib                    , Nil }) 
		aadd(aLinha,{"C6_PRCVEN"   , TRBZC6->ZC6_PRCVEN         , Nil })
		aadd(aLinha,{"C6_PRUNIT"   , TRBZC6->ZC6_PRCVEN         , Nil })
		aadd(aLinha,{"C6_PRCORIG"  , TRBZC6->ZC6_PRCVEN         , Nil })
		aadd(aLinha,{"C6_VALOR"    , TRBZC6->ZC6_VALOR          , Nil })
		aadd(aLinha,{"C6_TES"      , UPPER(TRBZC6->ZC6_TES)     , Nil })
		aadd(aLinha,{"C6_LOCAL"    , UPPER(TRBZC6->ZC6_LOCAL)   , Nil })
		aadd(aLinha,{"C6_ENTREG"   , STOD(TRBZC6->ZC6_ENTREG)   , Nil })
		aadd(aLinha,{"C6_ZZMERC"   , TRBZC6->ZC6_PEDMER         , Nil })
		aadd(aLinha,{"C6_ZZITMER"  , TRBZC6->ZC6_ITPMER         , Nil })
		aadd(aLinha,{"C6_ZZFAS"    , "06"                       , Nil })
		aadd(aLinha,{"C6_COMIS1"   , TRBZC6->ZC6_COMIS1         , Nil })
		aadd(aLinha,{"C6_CC"       , cCCven                     , Nil })
		aadd(aLinha,{"C6_USERINC"  , TRBZC5->ZC5_USRINC         , Nil })
		aadd(aLinha,{"C6_VLDSCBO"  , TRBZC6->ZC6_VLDSB1         , Nil })
		aadd(aLinha,{"C6_ZZMTDSC"  , TRBZC6->ZC6_MTDSB1         , Nil })
		aadd(aLinha,{"C6_PERSBO"   , TRBZC6->ZC6_PERSB1         , Nil })
		aadd(aLinha,{"C6_PEDCLI"   , cPedCli                    , Nil })
		aAdd(aLinha,{"C6_NUMPCOM"  , cPedCli                    , Nil }) // Pedido do Cliente para sair no XML da NFE - Daniel Pitthan 03/02/2014
		aAdd(aLinha,{"C6_ITEMPC"   , StrZero(nXitem,3)          , Nil }) //para sair no XML da NFE - Daniel Pitthan 03/02/2014
		aAdd(aLinha,{"C6_SERVIC"   , 'DS1'                      , Nil }) // Campo projeto novo WMS - Conteúdo fixo conforme solicitaçao Guilherme TOTVS IP 
		aadd(aItens,aLinha)

		//---------------------------------------------------
		// Determina marca para gravar no cabecalho pedido
		//---------------------------------------------------
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+TRBZC6->ZC6_PRODUT))
		If !Empty(SB1->B1_MARCA)
			cMarca := SB1->B1_MARCA
		Else
			cMarca := "Z" //Nao se aplica
		EndIf

		//---------------------------------------------------
		// Totaliza para gravar campo de total no cabecalho
		//---------------------------------------------------
		nVlrTot += Round(TRBZC6->ZC6_QTDVEN * TRBZC6->ZC6_PRCVEN , 2)

		//----------------------------
		// Proximo item do pedido
		//----------------------------
		TRBZC6->(dbSkip())
		nXitem++
		cItem := Soma1(cItem)
	enddo

	TRBZC6->(dbCloseArea())

	//-------------------------------------------------------------------------------------------------
	// Busca supervisor do vendedor
	//-------------------------------------------------------------------------------------------------
	cSuperv := Posicione("ZOH",1,xFilial("ZOH")+TRBZC5->ZC5_VEND1+substr(dtos(DATE()),1,4),"ZOH_SUP")

	//------------------------------------------------------------
	// Busca codigo processo WMS - Projeto WIS Junho 2018
	//------------------------------------------------------------
	if cEmp == "01"
		cProcWIS := "010" // Valor fixo provisorio para Sanchez - Pedidos Marca Propia , conforme solicitacao CM Solutions em 17/08/2018
	else
	    if cFilant == "06"  // Filial DVR deve ficar em branco com a implantacao do novo WMS Janeiro 2021   
			cProcWIS := ""
		else	
			cProcWIS := Posicione("ZCE",1,xFilial("ZCE")+iif(empty(TRBZC5->ZC5_TPMERC),"00",TRBZC5->ZC5_TPMERC),"ZCE_WMSPRC")
		endif 
	endif

	//------------------------------------------------------------
	// Atualiza cabecalho do pedido
	//------------------------------------------------------------
	aadd(aCabec,{"C5_FILIAL"  ,  cFilant                  ,Nil})
	aadd(aCabec,{"C5_TIPO"    ,  "N"                      ,Nil})
	aadd(aCabec,{"C5_CLIENTE" ,  TRBZC5->ZC5_CLIENT       ,Nil})
	aadd(aCabec,{"C5_LOJACLI" ,  TRBZC5->ZC5_LOJACL       ,Nil})
	aadd(aCabec,{"C5_LOJAENT" ,  TRBZC5->ZC5_LOJACL       ,Nil})
	aadd(aCabec,{"C5_TIPOCLI" ,  iif(TRBZC5->ZC5_TPMERC=="88","F",SA1->A1_TIPO) ,Nil})  // Para tipo pedido 88 ( Brindes ), tipo do cliente deve ser Consumidor Final - Regra para cálculo do DIFAL-ST
	aadd(aCabec,{"C5_TRANSP"  ,  TRBZC5->ZC5_TRANSP       ,Nil})
	aadd(aCabec,{"C5_TABELA"  ,  UPPER(TRBZC5->ZC5_TABELA),Nil})
	aadd(aCabec,{"C5_CONDPAG" ,  UPPER(TRBZC5->ZC5_CONDPA),Nil})
	aadd(aCabec,{"C5_VEND1"   ,  TRBZC5->ZC5_VEND1        ,Nil})
	aadd(aCabec,{"C5_BANCO"   ,  TRBZC5->ZC5_BANCO        ,Nil})
	aadd(aCabec,{"C5_ZZUF"    ,  SA1->A1_EST              ,Nil})
	aadd(aCabec,{"C5_MENNOTA" ,  SubStr(TRBZC5->ZC5_MENNOT,001,060) ,Nil})
	aadd(aCabec,{"C5_ZZMENNF" ,  SubStr(TRBZC5->ZC5_MENNOT,061,120) ,Nil})
	aadd(aCabec,{"C5_ZZMENF2" ,  SubStr(TRBZC5->ZC5_MENNOT,121,180) ,Nil})
	aadd(aCabec,{"C5_TPFRETE" ,  UPPER(TRBZC5->ZC5_TPFRET),Nil})
	aadd(aCabec,{"C5_ZZTIPVE" ,  UPPER(TRBZC5->ZC5_TIPVEN),Nil})
	aadd(aCabec,{"C5_ZZCRED"  ,  "S"                      ,Nil})
	aadd(aCabec,{"C5_ZZSTA"   ,  "ROMANEI"                ,Nil})
	aadd(aCabec,{"C5_ZZTIPO"  ,  iif(empty(TRBZC5->ZC5_TPMERC),"00",TRBZC5->ZC5_TPMERC) , Nil})
	aadd(aCabec,{"C5_COMIS1"  ,  0                        ,Nil})
	aadd(aCabec,{"C5_ZZFAS"   ,  "RM"                     ,Nil})
	aadd(aCabec,{"C5_ZZMARCA" ,  cMarca                   ,Nil})
	aadd(aCabec,{"C5_ORIGEM"  ,  "MERCANET"               ,Nil})
	aadd(aCabec,{"C5_ZZMERC"  ,  TRBZC5->ZC5_PEDMER       ,Nil})
	aadd(aCabec,{"C5_EMISSAO" ,  STOD(TRBZC5->ZC5_EMISSA) ,Nil})
	aadd(aCabec,{"C5_ZZVTOT"  ,  nVlrTot                  ,Nil})
	aadd(aCabec,{"C5_ZZSUP"   ,  cSuperv                  ,Nil})
	aadd(aCabec,{"C5_ZZDSCB"  ,  TRBZC5->ZC5_ZZDSCB       ,Nil})
	aadd(aCabec,{"C5_MTDSCB1"  , TRBZC5->ZC5_MTDSB1       ,Nil})
	aadd(aCabec,{"C5_VLDSCB1"  , TRBZC5->ZC5_VLDSB1       ,Nil})
	aadd(aCabec,{"C5_HSTDSB1"  , TRBZC5->ZC5_HSTDB1       ,Nil})
	aadd(aCabec,{"C5_MTDSCB2"  , TRBZC5->ZC5_MTDSB2       ,Nil})
	aadd(aCabec,{"C5_VLDSCB2"  , TRBZC5->ZC5_VLDSB2       ,Nil})
	aadd(aCabec,{"C5_HSTDSB2"  , TRBZC5->ZC5_HSTDB2       ,Nil})
	aadd(aCabec,{"C5_MTDSCB3"  , TRBZC5->ZC5_MTDSB3       ,Nil})
	aadd(aCabec,{"C5_VLDSCB3"  , TRBZC5->ZC5_VLDSB3       ,Nil})
	aadd(aCabec,{"C5_HSTDSB3"  , TRBZC5->ZC5_HSTDB3       ,Nil})
	aadd(aCabec,{"C5_CC"       , cCCven                   ,Nil})
	aadd(aCabec,{"C5_PERSB1"   , TRBZC5->ZC5_PERSB1       ,Nil})
	aadd(aCabec,{"C5_PERSB2"   , TRBZC5->ZC5_PERSB2       ,Nil})
	aadd(aCabec,{"C5_PERSB3"   , TRBZC5->ZC5_PERSB3       ,Nil})
	aadd(aCabec,{"C5_XWMSPRC"  , cProcWIS                 ,Nil})  // Adicionado campo projeto WMS Fini - Cristian 28/06/2018
	aadd(aCabec,{"C5_MOEDA"    , nMoedPad                 ,Nil})  // Projeto Comex - Mercanet - Caio Souza 17/03/2022
	aadd(aCabec,{"C5_DESCONT"  , TRBZC5->ZC5_VLDPRO       ,Nil})  // Caio Souza 11/10/2022 - Projeto Desconto NF

	//---------------------------------------
	// Executa inclusao pedido via ExecAuto
	//--------------------------------------
	MsExecAuto( { |x,y,z| MATA410(x,y,z) },aCabec,aItens,3)

   	//-----------------------------------
	// Se ocorreu erro, grava motivo
	//-----------------------------------
	cTxtErr  := ""
	cMailErr := ""
	If lMsErroAuto
		conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " + cDescEmp + " Filial " + cFilAnt + " -> ERRO MsExecAuto -  Pedido  " + TRBZC5->ZC5_PEDMER + " nao importado. " )
		cStatus := "ERR"
		cRet    := ""
		aLog := GetAutoGRLog()
		For nX := 1 To Len(aLog)
			cTxtErr  += aLog[nX]+CHR(13)+CHR(10)
			cMailErr += aLog[nX]+"<BR>"
		Next nX
		conOut( cTxtErr )
		//---------------------------------------
		// Envia e-mail do erro ao responsavel
		//---------------------------------------
		envMail(aCabec,aItens,cMailErr,cEmail)
	else
		//---------------------------------------------
		// Libera pedido vendas para selecionar lotes 
		// caso cliente tenha regra de shelf-life  
		//---------------------------------------------
		if lTemRegra
			GeraLib(SC5->C5_NUM,.F.,aQtLib)
		endif 

		conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " + cDescEmp + " Filial " + cFilAnt + " -> Pedido " + alltrim(TRBZC5->ZC5_PEDMER) + " : Pedido Protheus " + SC5->C5_NUM + " gerado e liberado" )
		cStatus        := "PRO"
		cRet           := SC5->C5_NUM
	endif

Return(cRet)



//=================================================================================
//
//
// 
// Funcao para a avaliar estoque disponivel dos itens de pedidos vindos do Mercanet
// antes de integrar ao Protheus. Caso um ou mais itens não tenha estoque suficiente
// o pedido não será integrado ao Protheus. 
//
//
//================================================================================= 
Static Function avalEst(lTemRegra,zc5Vend,zc5VldEst)

	Local lEst       := .T. // Status .T. se todos os itens do pedido tem saldo em estoque.Caso ocorrer corte total ou parcial Status =.F.
	Local lShelfOK   := .T.
	Local lCotaOk    := .T. 
	Local nSlEst     := 0
	Local nSlShelf   := 0 
	Local nDiasShelf := 0
	Local aRet       := {} 
	Local aCota      := {} 
	Local nSlCota    := 0 
	Local aCabCota   := {}
	Local aItCota    := {}  
	Local aLinha     := {} 
	Local cMailCota  := U_GETZPA("EMAIL_COTA_MERCANET","ZZ")   // destinatarios e-mail cota 
	Local lMailCota  := .T.    // Define se envia o e-mail com aviso do erro de cota
	Local cMaiVend   := ''
	Local cMaiSup    := ''
	Local cMailTot	 := ''

	//------------------------------------------------------------
	// Busca itens do pedido enviado pelo Mercanet
	// Ordena por pedido PAI para avaliar pedidos que
	// sofreram Split, pois se 1 dos pedidos sofrer corte o outro
	// não podera ser integrado ,mesmo que tenha saldo a atender
	//------------------------------------------------------------
	cQry := " SELECT * FROM " + retSqlName("ZC6") + " ZC6 WITH(NOLOCK)"
	cQry += " WHERE ZC6.D_E_L_E_T_ = '' "
	cQry += " AND ZC6.ZC6_FILIAL = '" + TRBZC5->ZC5_FILIAL + "' "
	cQry += " AND ZC6.ZC6_PEDPAI = '" + TRBZC5->ZC5_PEDPAI + "' "
	cQry += " ORDER BY ZC6.ZC6_FILIAL , ZC6.ZC6_PEDPAI , ZC6.ZC6_ITPMER "
	TCQUERY cQry NEW ALIAS "TRBZC6"

	TRBZC6->(dbGotop())
	do while !TRBZC6->(eof())

			//- Posiciona na tabela fisica ZC6
			ZC6->(dbSetOrder(1))
			ZC6->(dbSeek(TRBZC6->ZC6_FILIAL+TRBZC6->ZC6_PEDMER+TRBZC6->ZC6_ITPMER))


            //--------------------------------------------------------------------------------------
			// Calcula quantidade disponivel do item conforme parametro do tipo de saldo a avaliar 
			//--------------------------------------------------------------------------------------
			nSlEst := sldSB2(TRBZC6->ZC6_PRODUT,TRBZC6->ZC6_LOCAL) 

			//-----------------------------------------------------------------------------------
			// Calcula dias e saldo disponivel conforme regra Shelf-life do cliente caso existir 
			// Caso nao possuir regra de shelf-life, saldo sera o mesmo do SB2
			//-----------------------------------------------------------------------------------
			if lTemRegra 
				nDiasShelf := u_CalcSLife(TRBZC6->ZC6_PRODUT, TRBZC6->ZC6_CLI, TRBZC6->ZC6_LOJA)
        		nSlShelf   := saldoShelf(nDiasShelf,TRBZC6->ZC6_PRODUT,TRBZC6->ZC6_LOCAL,TRBZC6->ZC6_FILIAL)
				//------------------------------------------------------------------------------------------
				// Se saldo disponivel shelf-life maior que o saldo SB2, iguala os saldos pois com novo WMS
				// os pedidos liberados que nao reservam lote no pedido, o saldo do SB8 fica sem empenho 
				//------------------------------------------------------------------------------------------
				if nSlShelf > nSlEst 
			   		nSlShelf := nSlEst 
				endif 
			else
			    nSlShelf := nSlEst 
			endif 

			//-------------------------------------------------------------
			// Grava saldo disponivel total e saldo dentro da regra 
			// do shelf-life no momento da avaliacao do pedido
			//-------------------------------------------------------------
			ZC6->(recLock("ZC6",.F.))
			ZC6->ZC6_SLDISP := nSlEst  
			ZC6->ZC6_SLSHEL := nSlShelf

			//----------------------------------------------------------------
			// Define se existe saldo para atender totalmente o item
			// Caso saldo zero ou inferior, pedido não podera ser integrado
			//----------------------------------------------------------------
			If nSlEst < TRBZC6->ZC6_QTDVEN
			    ZC6->ZC6_ESTOK := "N"
				lEst           := .F.
			else
			    ZC6->ZC6_ESTOK := "S"
			EndIf

			//--------------------------------------------------------------------
			// Verifica saldo disponivel atende regra de shelf-life do cliente
			// Grava status se atendeu regra de shelf-life ou nao
			//--------------------------------------------------------------------
			if lTemRegra .and. nSlShelf < TRBZC6->ZC6_QTDVEN 
			   lShelfOK        := .F.
			   ZC6->ZC6_SHLFOK := "N"
			else 
			   ZC6->ZC6_SHLFOK := "S"
			endif 


			//--------------------------------------------------------------------------
			// Projeto COTAS - 2022 
			//--------------------------------------------------------------------------

			//---------------------------------------------------------------
			// Calcula saldo disponivel da cota do Vendedor/Item do pedido 
			//---------------------------------------------------------------
			aCota    := sldCota(TRBZC6->ZC6_FILIAL , zc5Vend , TRBZC6->ZC6_PRODUT ) 
			if aCota[1][3] = 999999999  // itens que não possuem controle de cotas ficam com saldo 999.999.999 
				nSlCota  := aCota[1][3]
			else
				nSlCota  := aCota[1][3] - ( aCota[1][1] + aCota[1][2] )  
			endif 
			ZC6->ZC6_COTASL  := nSlCota 

			//--------------------------------------------------------------
			// Verifica se o pedido já teve a cota avaliada anteriormente (ZC5_EMAILC = S)
			// Caso positivo, marca flag para não enviar e-mail de cota 
			//--------------------------------------------------------------
			if  ZC5->ZC5_EMAILC == 'S'
				lMailCota  := .F. 
			endif 
		
			//----------------------------------------------------------------
			// Define se o saldo da cota do produto para o vendedor do pedido 
			// é suficiente para atender o item a liberar
			// Caso negativo, força flag de estoque insuficiente  
			//----------------------------------------------------------------
			If nSlCota < TRBZC6->ZC6_QTDVEN
			    ZC6->ZC6_ESTOK   := "N"
				ZC6->ZC6_COTAOK  := "N"
				lEst             := .F.
				lCotaOk          := .F. 
			else
			    ZC6->ZC6_ESTOK   := "S"
				ZC6->ZC6_COTAOK  := "S"
			EndIf


            //------------------------------
			// Libera registro 
			//------------------------------
			ZC6->(msUnLock())

			//--------------------------------------------------------------
			// Adicina itens no array para e-mail erro cotas 
			//--------------------------------------------------------------
			aLinha := {}
			aadd(aLinha,{"C6_FILIAL"   , cFilAnt                    , Nil })
			aadd(aLinha,{"C6_ITEM"     , TRBZC6->ZC6_ITPMER         , Nil })
			aadd(aLinha,{"C6_PRODUTO"  , UPPER(TRBZC6->ZC6_PRODUT)  , Nil })
			aadd(aLinha,{"C6_QTDVEN"   , TRBZC6->ZC6_QTDVEN         , Nil })
			aadd(aLinha,{"C6_QTDLIB"   , TRBZC6->ZC6_QTDVEN         , Nil }) 
			aadd(aLinha,{"C6_PRCVEN"   , TRBZC6->ZC6_PRCVEN         , Nil })
			aadd(aLinha,{"SLD_COTA"    , nSlCota                    , Nil })
			aadd(aLinha,{"COTA_OK"     , if(nSlCota<TRBZC6->ZC6_QTDVEN,.F.,.T.), Nil })
			aadd(aItCota,aLinha)

			//------------------------
			// Proximo item
			//------------------------
			TRBZC6->(DbSkip())

	enddo

	TRBZC6->(dbCloseArea())

	if !lEst .or. !lShelfOK 
		conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " + cDescEmp + " Filial " + cFilAnt + " -> Pedido " + alltrim(TRBZC5->ZC5_PEDMER) + " : " + iif(lShelfOK,'Estoque insuficiente para atender o pedido',' Sald disp. fora da regra Shelf-Life do Cliente'))
	endif 

	aadd( aRet , { lEst , lShelfOK , lCotaOK })

	//----------------------------------------------------
	// Envia e-mail aos responsáveis caso algum 
	// item do pedido nao tenha sido liberado por
	// conta do saldo de cota insuficiente
	// Somente se validação do estoque = 'S' 
	//-----------------------------------------------------
	if !lCotaOk .and. zc5VldEst == "S" .and. lMailCota
		// Caio Souza 12/04/2022 - enviar e-mail de erro de Cota para Time Comercial + Vendedor + Supervisor
		cMaiVend := Posicione('SA3',1,xFilial('SA3')+zc5Vend,'A3_EMAIL')
		cMaiSup  := Posicione('SA3',1,xFilial('SA3')+zc5Vend,'A3_EMACORP')
		cMailTot := cMailCota+";"+cMaiVend+";"+cMaiSup   
		envMail(aCabCota,aItCota,"COTA",cMailTot)
		// Caio Souza 31/03/2022 - Preencher o campo ZC5_EMAILC com S para que o envio de e-mail com o erro de cota
		// seja feito uma unica vez - nos testes notamos o comportamento de envio constante de email devido
		// ao retorno da Mercanet (não foi envolvida no Projeto de Cota) 
		ZC5->(reclock("ZC5",.F.))
			ZC5->ZC5_EMAILC := 'S'
		ZC5->(msUnLock())
	endif 

Return(aRet)


//==========================================================================================
//
// Atualiza campos customizados do SC5 / SC9 
// Elimina residuo do pedido caso existir algum item com quantidade liberada = 0 
//
//
//==========================================================================================
Static Function finalPedido(cPed)

	Local aArea    := GetArea()
	Local cPedido  := cPed
	Local lResiduo := .F.
		
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+cPedido))

    //------------------------------------------------------------------------------------------
	// Verifica se algum item do pedido teve corte total para marcar como resíduo
	//------------------------------------------------------------------------------------------
	dbSelectArea("SC6")
	dbSetOrder(1)
	MsSeek(xFilial("SC6")+SC5->C5_NUM)
	While ( !Eof() .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM )
		//-----------------------------------------------------------
		// So marca eliminado residuo caso nao tenha liberado no SC9
		//-----------------------------------------------------------
		if SC6->C6_QTDEMP = 0  
			SC6->(recLock("SC6",.F.))
			SC6->C6_BLQ := 'R'
			SC6->(msUnlock())
			lResiduo := .T.
		EndIf
		//-----------------------
		// Proximo item 
		//-----------------------
		dbSelectArea("SC6")
		dbSkip()
	EndDo

	//-------------------------------------------------------------------
	// Se houve eliminacao de residuo, registra no historico do pedido 
	//-------------------------------------------------------------------
	if lResiduo
		U_FAT9099(SC5->C5_NUM,SC5->C5_ZZFAS,"Resíduo Auto. Itens Saldo 0", , , ,.T.)
	endif

	//-------------------------------------------------------------------
	// Atualiza campos customizados na tabela SC9 
	//-------------------------------------------------------------------
	SC9->(dbSetOrder(1))
	SC9->(MsSeek(xFilial("SC9")+SC5->C5_NUM,.T.,.F.))
	While ( !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM )
		RecLock("SC9",.F.)
		SC9->C9_BLCRED  := space(01)   // garante que o Protheus nao faca bloq. por credito pois a liberação ja foi feita pelo Mercanet
		SC9->C9_ZZFAS   := "RM"        // fase de romaneio 
		SC9->C9_ZZMERCA := "S"         // liberacao Mercanet 
		SC9->(MsUnLock())
		SC9->(dbSkip())
	EndDo

	//------------------------------------------------------------------------------------------
	// Faz update no SC5 para disparar trigger Mercanet e atualizar status do pedido
	// Coloca pedido na fase RM
	//------------------------------------------------------------------------------------------
	SC5->(recLock("SC5",.F.))
	SC5->C5_LIBEROK := 'S'
	SC5->C5_ZZFAS   := "RM"
	SC5->(msUnlock())
	U_FAT9099(SC5->C5_NUM,SC5->C5_ZZFAS,"Liberado para Romaneio", , , ,.T.)
    
	RestArea(aArea)

Return(lResiduo)


//==========================================================================================
//
// 
// Funcao para retornar saldo disponivel conforme regra shelf-life do cliente 
//
//
//==========================================================================================
Static Function saldoShelf(nDiasShelf, cProduto , cArm , cFilB8 )  

	Local nSaldo := 0
	Local cQry   := ""

	cQry := " SELECT SUM(B8_SALDO-B8_EMPENHO-B8_QACLASS) AS SALDO_B8 "
	cQry += " FROM " + retSqlName("SB8") + " SB8 WITH(NOLOCK) "
	cQry += " WHERE SB8.D_E_L_E_T_ = '' "
	cQry += " AND SB8.B8_FILIAL  = '"  + cFilB8   + "' "
	cQry += " AND SB8.B8_LOCAL   = '"  + cArm     + "' "
	cQry += " AND SB8.B8_PRODUTO = '"  + cProduto + "' "
	cQry += " AND SB8.B8_DTVALID >= '" + DTOS(dDatabase + nDiasShelf) + "' " 
	TCQUERY cQry NEW ALIAS "TRBSB8"

	TRBSB8->(dbGotop())
	nSaldo := int(TRBSB8->SALDO_B8) 
	TRBSB8->(dbCloseArea())


Return(nSaldo)


//==========================================================================================
//
// 
// Funcao para retornar dias Shelf-Life conforme regra do Cliente / Produto 
//
//
//==========================================================================================
User Function CalcSLife(cProd, cCliente, cLoja)

    Local nDiasShelf    := 0
    Local aAreaAtu      := GetArea()
    Local aAreaSB1      := SB1->(GetArea())
    Local aAreaSA1      := SA1->(GetArea())
    Local cRegraShelf   := ""

	
	SA7->(dbSetOrder(1))
	If SA7->(dbSeek(xFilial("SA7") + cCliente + cLoja + cProd )) .and. SA7->(FieldPos("A7_ZZDIASH")) > 0
		nDiasShelf := SA7->A7_ZZDIASH
	Endif

	//CM Solutions - Allan Constantino Bonfim - 28/12/2020 - Projeto WMS Padrão - Tratamento para o Shelf Life na liberação de pedidos
	If nDiasShelf == 0 // Se não achou, procura no cliente
		If SA1->(FieldPos("A1_ZZREGRA")) > 0 .AND. SA1->(FieldPos("A1_ZZDIASH")) > 0 .AND. SA1->(FieldPos("A1_ZZPORSH")) > 0 .AND. SB1->(FieldPos("B1_PRVALID")) > 0 
			cRegraShelf   := Posicione("SA1",1,xFilial("SA1") + cCliente + cLoja, "A1_ZZREGRA")

			If cRegraShelf == "1" // Fixa
				nDiasShelf := SA1->A1_ZZDIASH
			ElseIf cRegraShelf == "2" .and. !Empty(SA1->A1_ZZPORSH) // Fracionada/Percentual
				nDiasShelf := Round(Posicione("SB1",1,xFilial("SB1")+cProd,"B1_PRVALID") * (SA1->A1_ZZPORSH / 100),0)
			Endif
			
		Endif
	EndIf

    RestArea(aAreaSA1)
    RestArea(aAreaSB1)
    RestArea(aAreaAtu)
	
    
     
Return(nDiasShelf) 


//==========================================================================================
//
// Funcao para calcular e retornar saldo disponivel do produto no SB2 
//
//===========================================================================================
Static Function sldSB2(_cProd,_cLocal) 

    //Local lNecessidade    := .F.  // .F. = Retira do saldo disponivel B2_QACLASS
	//Local lEmpenho        := .F.
	//Local dDataFim        := Nil
	//Local lConsTerc       := Nil
	//Local nQtdEmp         := Nil
	//Local nQtdPrj         := Nil
	//Local lSaldoSemR      := Nil
	//Local dDtRefSld       := dDatabase
	//Local lConsEmpSA      := Nil
	Local nRet            := 0 
	Local aAreaAtu        := GetArea()
    Local aAreaSB2        := SB2->(GetArea())

	dbSelectArea("SB2")
	dbSetOrder(1)
	If dbSeek(xFilial("SB2")+PADR(_cProd,LEN(SB2->B2_COD))+_cLocal)
		
        //- Alterado em 26/08/2021 para sempre calcular saldo pela funcao SALDOSB2 , independente do parametro MV_TPSALDO 
	    nRet := SaldoSB2()
		/*If SuperGetMV("MV_TPSALDO") == "C"
			nRet := SaldoMov(lNecessidade,lEmpenho,dDataFim,lConsTerc,nQtdEmp,nQtdPrj,lSaldoSemR,dDtRefSld,lConsEmpSA)
		ElseIf SuperGetMV("MV_TPSALDO") == "Q"
			nRet := SB2->B2_QATU-SB2->B2_QACLASS-SB2->B2_RESERVA
		ElseIf SuperGetMV("MV_TPSALDO") == "S"
			nRet := SaldoSB2()
		EndIf
        */ 

	EndIf

    nRet := int(nRet) // nao considera saldo fracionado 

	RestArea(aAreaSB2)
    RestArea(aAreaAtu)

Return(nRet)



//------------------------------------------------------------------------
//
//
// Atualiza nro pedido e item Protheus na tabela de controle bonificacao  
//
//
//------------------------------------------------------------------------
Static Function atuBonific(cPedRet)

	ZC7->(dbSetOrder(1))
	SC6->(dbSetOrder(1))

	SC6->(dbSeek(xFilial("SC6")+cPedRet))
	do while !SC6->(eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cPedRet
		if ZC7->(dbSeek(SC6->C6_FILIAL+SC6->C6_ZZMERC+SC6->C6_ZZITMER))
			do while !ZC7->(eof()) .and. ZC7->ZC7_FILIAL == SC6->C6_FILIAL .and. ZC7->ZC7_PEDMER == SC6->C6_ZZMERC .and. ZC7->ZC7_ITPMER == SC6->C6_ZZITMER
				ZC7->(recLock("ZC7",.F.))
				ZC7->ZC7_NUM   := SC6->C6_NUM
				ZC7->ZC7_ITEM  := SC6->C6_ITEM
				ZC7->(msUnlock())
				ZC7->(dbSkip())
			enddo
		endif
		SC6->(dbSkip())
	enddo

Return


//------------------------------------------------------------------------
//
//
// Envia e-mail ao responsavel quando ocorrer erro no MsExecAuto 
//
//
//------------------------------------------------------------------------
Static Function envMail(aCab,aIt,cTxtErr,cEmail)

    Local x
	Local cAmbient := U_GETZPA('AMBIENTE_EMAILS','ZZ') 

	// Caio Souza 12/04/2022 - Identifica o ambiente em uso para disparo de e-mails
	cTitulo := cAmbient+"Integração MERCANET - Erro " + if(cTxtErr=="COTA",cTxtErr,"ExecAuto") + " - Pedido " + TRBZC5->ZC5_PEDMER

	cTexto  := ""
	cTexto  += '<table border="1">'
	cTexto  += "<tr>"
	cTexto  += "<td><b>Empresa</b></td>"
	cTexto  += "<td>"+space(02)+cDescEmp+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Filial</b></td>"
	cTexto  += "<td>"+space(02)+TRBZC5->ZC5_FILIAL+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Nro. Pedido Mercanet</b></td>"
	cTexto  += "<td>"+space(02)+TRBZC5->ZC5_PEDMER+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Data Inclusão Pedido</b></td>"
	cTexto  += "<td>"+space(02)+DTOC(STOD(TRBZC5->ZC5_DTINC))+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Hora Inclusão </b></td>"
	cTexto  += "<td>"+space(02)+TRBZC5->ZC5_HRINC+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Cliente</b></td>"
	cTexto  += "<td>"+space(02)+TRBZC5->ZC5_CLIENT+" - "+posicione("SA1",1,xFilial("SA1")+TRBZC5->ZC5_CLIENT+TRBZC5->ZC5_LOJACL,"A1_NOME")+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Vendedor</b></td>"
	cTexto  += "<td>"+space(02)+TRBZC5->ZC5_VEND1+" - "+posicione("SA3",1,xFilial("SA3")+TRBZC5->ZC5_VEND1,"A3_NOME")+"</td>"
	cTexto  += "</tr>"
	cTexto  += "<tr>"
	cTexto  += "<td><b>Valor (R$)</b></td>"
	cTexto  += "<td>"+str(TRBZC5->ZC5_VTOT,12,2)+"</td>"
	cTexto  += "</tr>"
	cTexto  += "</table>"
	cTexto  += "<BR><BR><b>Itens do pedido</b>"
	cTexto  += "<hr>"
	cTexto  += '<table border="1">'
	cTexto  += "<tr>"
	cTexto  += "<td><b>Item</b></td>"
	cTexto  += "<td><b>Produto</b></td>"
	cTexto  += "<td><b>Descrição</b></td>"
	cTexto  += "<td><b>Quantidade</b></td>"
	cTexto  += "<td><b>Preço venda</b></td>"
	cTexto  += "<td><b>Valor total</b></td>"
	if cTxtErr=='COTA'
		cTexto  += "<td><b>Saldo da COTA</b></td>"
		cTexto  += "<td><b>STATUS da COTA</b></td>"

	endif 
	cTexto  += "</tr>"
	for x:=1 to len(aIt)
		cTexto  += "<tr>"
		cTexto  += "<td>"+aIt[x][2][2]+"</td>"
		cTexto  += "<td>"+aIt[x][3][2]+"</td>"
		cTexto  += "<td>"+POSICIONE("SB1",1,xFilial("SB1")+aIt[x][3][2],"B1_DESC")+"</td>"
		cTexto  += "<td>"+STR(aIt[x][4][2],10,2)+"</td>"
		cTexto  += "<td>"+STR(aIt[x][6][2],10,2)+"</td>"
		cTexto  += "<td>"+STR( (aIt[x][4][2]*aIt[x][6][2]),10,2)+"</td>"
		if cTxtErr=='COTA'
		    cTexto  += "<td>"+str(aIt[x][7][2],10,0)+"</td>"
			if aIt[x][8][2]
			   cTexto  += "<td>Ok</td>"   
			else
			  cTexto  += "<td>INSUFICIENTE</td>"
	        endif 
		endif 
		cTexto  += "</tr>"
	next
	cTexto  += "</table>"
	cTexto  += "<BR><BR><hr>"
	cTexto  += '<table border="1">'
	cTexto  += "<tr>"
	cTexto  += "<td><b>Descrição do Erro - MsExecAuto</b></td>"
	cTexto  += "</tr>"
	cTexto  += "</table>"
	cTexto += cTxtErr
	_cAnexos := ""

	U_SUBEML(cEmail,cTitulo,cTexto,_cAnexos)

Return




//=================================================================================
//
//
// 
// Funcao para a liberacao de pedidos vindos do Mercanet no Protheus via Execauto
//
//
//
//================================================================================= 
Static Function GeraLib(cPed,lLibEst,aQtLib)

	Local nQtdSomaLib   := 0
	Local nZ            := 1 
	Local nX            := 0 
	Local nDiasLib      := 0 

	Local lMvVLDLOTE := SuperGetMV("MV_VLDLOTE",.F.,.T.)
	Local cMvLOTVENC := SuperGetMv("MV_LOTVENC")
	Local cMvSELPLOT := SuperGetMv("MV_SELPLOT",.F.,"2")

	Private lBloqCred   := .F.    //Bloqueia Credito
	Private lEstoque    := .F.    //Bloqueia Estoque
	Private lAvCred     := .F.    //Avalia Credito
	Private lAvEst      := .F.    //Avalia Estoque
	Private lLibPar     := .F.    //iif(cAvalEst=="S",.F.,.T.)  //Libera Parcial se flag pedido nao avaliar estoque.Caso contrario so libera total
	Private lTrfLocal   := .F.    //Tranfere Locais automaticamente
	Private aEmpenho    := NIL    //Empenhos ( Caso seja informado nao efetua a gravacao apenas avalia )
	Private bBlock      := NIL    //CodBlock a ser avaliado na gravacao do SC9
	Private aEmpPronto  := NIL    //Array com Empenhos previamente escolhidos
	Private lTrocaLot   := NIL    //Indica se apenas esta trocando lotes do SC9
	Private lOkExpedicao:= NIL
	Private nVlrCred    := NIL    //Valor a ser adicionado ao limite de credito
	Private nQtdalib2   := NIL    //Quantidade a Liberar - segunda UM

	conout( "[MERCANET] "+dtoc( Date() )+" "+Time() + " " +cDescEmp + " Filial " + cFilAnt + " -> Pedido " + alltrim(TRBZC5->ZC5_PEDMER) + " : Liberando pedido - Regra Shelf-Life " )

	//-----------------------------------
	//Posiciona no Cabeçalho do Pedido
	//-----------------------------------
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+cPed))

	If !lLibEst 

		//+--------------------------------------------+
		//Percorre todos os itens para liberação
		//+--------------------------------------------+
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6")+cPed))
		While SC6->(!Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cPed
	
		    //-------------------------------------------------------
			// Determina quantidade a liberar.Se 0 , nao libera item                                          
			//-------------------------------------------------------
			nQtdLib := aQtLib[nZ][1] 
			If nQtdLib <= 0
			    nZ++
				SC6->(DbSkip())
				Loop
			EndIf
		
			//-----------------------------------------------------------
			// Determina nro de dias da regra de shelf life do item 
			//-----------------------------------------------------------
			nDiasLib :=  aQtLib[nZ][2]

			//-------------------------------------------------------------
			// Posiciona na tabela de saldos SB2 
			//-------------------------------------------------------------
			dbSelectArea("SB2")
			SB2->(dbSetOrder(1))
			dbSeek(xFilial("SB2")+PADR(SC6->C6_PRODUTO,LEN(SB2->B2_COD))+SC6->C6_LOCAL)
			
			//-------------------------------------------------------------
			// Posiciona na tabela de TES 
			//-------------------------------------------------------------
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES))

			//-------------------------------------------------------------
			// Obtem os lotes com saldo disponivel para o item 
			//-------------------------------------------------------------
			lVldDtLote := lMvVLDLOTE
			lUsaVenc   := IIf(!Empty(SC6->C6_LOTECTL+SC6->C6_NUMLOTE),.T.,cMvLOTVENC=='S')
			lLote      := cMvSELPLOT == "1"
			lInfoWms   := (IntDL(SC6->C6_PRODUTO) .And. !Empty(SC6->C6_SERVIC))
			aSaldos    := {}
			aSldLote   := SldPorLote(SC6->C6_PRODUTO,SC6->C6_LOCAL,SaldoSb2(nil,.F.),0,Iif(lLote,Nil,SC6->C6_LOTECTL),Iif(lLote,Nil,SC6->C6_NUMLOTE),SC6->C6_LOCALIZ,SC6->C6_NUMSERI,NIL,NIL,NIL,lUsaVenc,,,IIf(lVldDtLote,dDataBase,Nil),lInfoWms)

            //----------------------------------------------------------------------------------
			// Seleciona apenas lotes que estejam dentro da regra de shelf-life do cliente/item 
			//----------------------------------------------------------------------------------
			For nX := 1 To Len(aSldLote)
				IF INT(aSldLote[nX][05]) > 0 .and. aSldLote[nX][07] >= dDataBase+nDiasLib  
					aadd(aSaldos,{aSldLote[nX][01],aSldLote[nX][02],aSldLote[nX][03],aSldLote[nX][04],INT(aSldLote[nX][05]),aSldLote[nX][12],aSldLote[nX][07]})
				Endif
			Next nX

			dbSelectArea("SF4")
			SF4->(dbSetOrder(1))		//F4_FILIAL+F4_CODIGO
			If SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES,.T.,.F.))
				dbSelectArea("SC5")
				SC5->(dbSetOrder(1))	//C5_FILIAL+C5_NUM
				If SC5->(MsSeek(xFilial("SC5") + SC6->C6_NUM,.T.,.F.)) .AND. RecLock("SC5")
					dbSelectArea("SC6")
					RecLock("SC6")
					//+----------------------------------------+
					//|GERA A LIBERACAO NO SC9                 |
					//+----------------------------------------+
					nQtdLib2 	:= ConvUM(SC6->C6_PRODUTO,nQtdLib,0,2)
					lBloqCred	:= .T.			//Bloqueia Credito nunca pois não é usado o padrão para isso
					lEstoque	:= lLibEst		//Bloqueia Estoque
					lLibPar 	:= .T. 		// permite liberação parcial
					lTrfLocal 	:= .F. 		// Tranfere Locais automaticamente

					nQtdSomaLib += MaLibDoFat(SC6->(RECNO()),nQtdLib,lBloqCred,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lOkExpedicao,nVlrCred,nQtdLib2)

					//Atualiza dados do Registro do SC9, Romaneio e Fase
					dbSelectArea("SC9")
					dbSetOrder(1)
					SC9->(MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.T.,.F.))

					nOpc 		:= 1 		 //1 - Liberacao ou 2 - Rejeicao
					lAtuCred 	:= .F. 		 //Indica uma Liberacao de Credito
					lAtuEst 	:= .T. 		 //Indica uma liberacao de Estoque
					lHelp 		:= Nil 		 //Indica se exibira o help da liberacao
					aSaldos 	:= aSaldos 	 //Saldo dos lotes a liberar
					lAvEst      := .F. 	     //Forca analise da liberacao de estoque

					a450Grava(nOpc,lAtuCred,lAtuEst,lHelp,aSaldos,lAvEst)

					dbSelectArea("SC9")
					SC9->(dbSetOrder(1))
					SC9->(dbGotop())
					SC9->(MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.T.,.F.))
					While ( !Eof() .And. SC9->C9_FILIAL == xFilial("SC9") .And.;
							SC9->C9_PEDIDO == SC6->C6_NUM .And.;
							SC9->C9_ITEM   == SC6->C6_ITEM )
						If ( Empty(SC9->C9_NFISCAL) )
							RecLock("SC9",.F.)
							SC9->C9_BLCRED  := ""
							SC9->C9_ZZFAS   := "RM"  // alteracao mercanet
							SC9->C9_ZZMERCA := "S"   // alteracao mercanet
							SC9->(MsUnLock())
						EndIf
						SC9->(dbSkip())
					EndDo

					dbSelectArea("SC6")
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Atualiza o Flag do Pedido de Venda                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					SC6->(MaLiberOk({ Padr(SC6->C6_NUM,TamSx3("C6_NUM")[01]) },.F.))
				EndIf
				SC5->(MsUnLock())
			EndIf
			//-------------------------------
			// Proximo item do pedido
			//-------------------------------
			dbSelectArea("SC6")
			SC6->(msUnlock())  
			SC6->(DbSkip())
	        nZ++
		EndDo
	EndIf

Return


//==========================================================================================
//
// 
// Funcao para retornar quantidade a faturar/vendida/cota atual de um determinado 
// Vendedor/Produto  do mês corrente. Utilizado para validação do projeto de Cotas 
//
//==========================================================================================
Static Function sldCota(cFilFat , cVend1 , cProdPar )  

	Local aRet      := {} 
	Local cQry      := ""
	Local dPerIni   := dtos(FirstDate(date()))
	Local dPerFim   := dtos(LastDate(date()))
	Local lVendZCO  := .F. 
	Local cSuper    := Alltrim(Posicione("ZOH",1,xFilial("ZOH")+cVend1+substr(dtos(DATE()),1,4),"ZOH_SUP"))
	Local lSuperZCO := .F. 

	// Verifica se vendedor tem Cota cadastrada no Ano e Mes atual 
	ZCO->(dbSetOrder(1))
	if ZCO->(dbSeek( xFilial("ZCO")+substr(dPerIni,1,6)+cVend1+cProdPar)) 
	   lVendZCO := .T. 
	endif 

	// Verifica se supervisor do vendedor tem Cota cadastrada no Ano e Mes atual 
	ZCO->(dbSetOrder(3))
	if ZCO->(dbSeek( xFilial("ZCO")+substr(dPerIni,1,6)+cSuper+cProdPar)) 
	   lSuperZCO := .T. 
	endif 


	cQry += " SELECT SUM(A.TOT_SC9) AS TOT_SC9  , SUM(A.TOT_SD2) AS TOT_SD2  , " // SUM(A.TOT_COTA) AS TOT_COTA "  
	cQry += " CASE WHEN SUM(A.TOT_COTA) = 999999999 AND (SUM(A.COTA_PROD)) = 0 THEN 999999999 "
	cQry += "      WHEN SUM(A.TOT_COTA) = 999999999 AND (SUM(A.COTA_PROD)) > 0 THEN 0 " 
	cQry += " 	 ELSE SUM(A.TOT_COTA) "
    cQry += " END TOT_COTA " 
	
	cQry += " FROM	( "

	cQry += " SELECT SUM(C9_QTDLIB) AS TOT_SC9 , 0 AS TOT_SD2 , 0 AS TOT_COTA , 0 AS COTA_PROD " 
	cQry += " FROM " + retSqlName("SC9") + " SC9 WITH(NOLOCK) "
	cQry += " INNER JOIN " + retSqlName("SC5") + " SC5 WITH(NOLOCK) ON SC5.D_E_L_E_T_='' AND SC5.C5_FILIAL=SC9.C9_FILIAL AND SC5.C5_NUM=SC9.C9_PEDIDO "
	cQry += " WHERE SC9.D_E_L_E_T_ = '' "
	cQry += " AND SC9.C9_NFISCAL = '' "
	cQry += " AND SC9.C9_BLEST = ''  "
	cQry += " AND SC9.C9_BLCRED = '' "
    cQry += " AND SC9.C9_ZZMERCA = 'S' "  // 05/04/2022 - Solicitacao Nara para so considerar pedidos vindo do Mercanet
	cQry += " AND SC9.C9_FILIAL = '" + cFilFat + "' "

	if lVendZCO .and. !lSuperZCO 
		cQry += " AND SC5.C5_VEND1  = '" + cVend1 + "' "
	else 
	   cQry += " AND SC5.C5_VEND1  IN  ( SELECT ZOH_CODVEN FROM " + retSqlName("ZOH") + " ZOH WITH(NOLOCK) " 
	   cQry += " WHERE ZOH.D_E_L_E_T_='' AND ZOH.ZOH_ANO = '" + substr(dPerIni,1,4) + "' AND ZOH.ZOH_SUP='" +cSuper+"') "  
	endif  


	cQry += " AND SC9.C9_PRODUTO = '" + cProdPar + "' "
    cQry += " AND SC9.C9_DATALIB BETWEEN '" + dPerIni +"' AND '" + dPerFim + "' "  


	cQry += " UNION ALL "

	cQry += " SELECT 0 AS TOT_SC9 , ISNULL(SUM(D2_QUANT),0) AS TOT_SD2 , 0 AS TOT_COTA  , 0 AS COTA_PROD " 
	cQry += " FROM " + retSqlName("SD2") + " SD2 WITH(NOLOCK) "  
	cQry += " INNER JOIN " + retSqlName("SF2") + " SF2 WITH(NOLOCK) ON SF2.D_E_L_E_T_='' AND SF2.F2_FILIAL=SD2.D2_FILIAL AND SF2.F2_DOC = SD2.D2_DOC "
	cQry += " 										AND SF2.F2_CLIENTE=SD2.D2_CLIENTE AND SF2.F2_LOJA = SD2.D2_LOJA "
        
    cQry += " INNER JOIN " + retSqlName("ZC5") + " ZC5 WITH(NOLOCK) ON ZC5.D_E_L_E_T_='' AND ZC5_FILIAL = SD2.D2_FILIAL AND ZC5.ZC5_NUM = SD2.D2_PEDIDO " 

	cQry += " WHERE SD2.D_E_L_E_T_ = '' "
	cQry += " AND SD2.D2_TIPO = 'N'  "
	cQry += " AND SD2.D2_FILIAL = '" + cFilFat + "' " 
	
	if lVendZCO .and. !lSuperZCO 
		cQry += " AND SF2.F2_VEND1  = '" + cVend1 + "' "
	else 
	   cQry += " AND SF2.F2_VEND1 IN  ( SELECT ZOH_CODVEN FROM " + retSqlName("ZOH") + " ZOH WITH(NOLOCK) " 
	   cQry += " WHERE ZOH.D_E_L_E_T_='' AND ZOH.ZOH_ANO = '" + substr(dPerIni,1,4) + "' AND ZOH.ZOH_SUP='" +cSuper+"') "  
	endif  

	cQry += " AND SD2.D2_COD = '" + cProdPar + "' "

	//cQry += " AND SD2.D2_EMISSAO BETWEEN '" + dPerIni +"' AND '" + dPerFim + "' "  
	// 05/04/2022 - Solicitacao Nara - Considerar data integracao do pedido no Protheus para soma das notas fiscais
     cQry += " AND ZC5.ZC5_DTFIM BETWEEN '" + dPerIni +"' AND '" + dPerFim + "' "  



	cQry += " UNION ALL

	cQry += " SELECT  0 AS TOT_SC9 , 0 AS TOT_SD2 , ISNULL(SUM(ZCO.ZCO_COTA),999999999)  AS TOT_COTA  , 0 AS COTA_PROD "  
	cQry += " FROM " + retSqlName("ZCO") + " ZCO " 
	cQry += " WHERE "
	cQry += " ZCO.D_E_L_E_T_ = '' "
	cQry += " AND ZCO.ZCO_FILIAL  = '" + cFilFat + "' 
	cQry += " AND ZCO.ZCO_ANO     = '" + substr(dPerIni,1,4) + "' "   
	cQry += " AND ZCO.ZCO_MES     = '" + substr(dPerIni,5,2) + "' "
	if lVendZCO .and. !lSuperZCO 
		cQry += " AND ZCO.ZCO_CODVEN  = '" + cVend1 + "' "
	else
		cQry += " AND ZCO.ZCO_CODSUP  = '" + cSuper + "' "
	endif 
	cQry += " AND ZCO.ZCO_CODPRO  = '" + cProdPar + "' "

	cQry += " UNION ALL

	cQry += " SELECT  0 AS TOT_SC9 , 0 AS TOT_SD2 , 0  AS TOT_COTA  , ISNULL(COUNT(*),0)  AS COTA_PROD "  
	cQry += " FROM " + retSqlName("ZCO") + " ZCO " 
	cQry += " WHERE "
	cQry += " ZCO.D_E_L_E_T_ = '' "
	cQry += " AND ZCO.ZCO_FILIAL  = '" + cFilFat + "' 
	cQry += " AND ZCO.ZCO_ANO     = '" + substr(dPerIni,1,4) + "' "   
	cQry += " AND ZCO.ZCO_MES     = '" + substr(dPerIni,5,2) + "' "
	cQry += " AND ZCO.ZCO_CODPRO  = '" + cProdPar + "' "


	cQry += " ) AS A "

	TCQUERY cQry NEW ALIAS "TRBCOTA"

	TRBCOTA->(dbGotop())
	Aadd( aRet , { TRBCOTA->TOT_SC9 , TRBCOTA->TOT_SD2 , TRBCOTA->TOT_COTA }) 
	TRBCOTA->(dbCloseArea())

Return(aRet)

