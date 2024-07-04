#INCLUDE "Protheus.ch"
#INCLUDE "OGX009.ch"

#define COL_COUNT       15
#define COL_MARK        1
#define COL_DOC         2
#define COL_SERIE       3
#define COL_EMISSAO     4
#define COL_ITEM        5
#define COL_QUANT       6
#define COL_QTDFIX      7
#define COL_VUNIT       8
#define COL_VTOTAL      9
#define COL_SALDO       10
#define COL_DISTRIB     11
#define COL_VDISTR      12
#define COL_IDENTB6     13
#define COL_LOTECTL     14
#define COL_VAZIO       15

Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static __lVlUnitDev := SuperGetMv('MV_AGRO047', , .F.) // Parâmetro que indica se irá considerar ou não na dev. o valor unitário informado manualmente no romaneio.

/** {Protheus.doc} OGX009A
Rotina para geração do documento de Entrada
* Função reescrita *  
@param:     Nil
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       SIGAAGR 
@type: Function 
*/
Function OGX009A(cRomaneio, aTpANFD, cItRom)

	Local aAreaAtu      := GetArea()
	Local aCab          := {}		//--Array de cabeçalho para geração da nota fiscal SF1 
	Local aLinha        := {}		//--Array auxiliador
	Local aSelNfs		:= {}		//--Array retorno dos complementos
	Local cModAtu       := cModulo
	Local nModAtu       := nModulo
	
	/** Variaveis de query **/
	Local (cAliasNJM) 	:= GetNextAlias()
	Local cQueryNJM		:= ""

	/** Variaveis do Cabeçalho do Documento de Entrada */
	Local cTipoNF       := "N"	//--Tipo do documento de entrada 
	Local cPlaca        := ""	//NJJ->( NJJ_PLACA )
	Local cCodTra       := ""	//NJJ->( NJJ_CODTRA )
	Local dEmissao      := ""	//IIf( NJM->( NJM_TPFORM ) = "1", dDataBase, NJM->( NJM_DOCEMI ) )
	Local cFormulario   := ""	//IIf( NJM->( NJM_TPFORM ) = "1", "S", "N" )
	Local cChvNFe       := ""	//NJM->( NJM_CHVNFE )
	Local cCodDocF1     := ""	//NJM->( NJM_CODROM )
	Local cDocTranNr    := ""	//NJM->( NJM_NFPNUM )
	Local cDocTranSe    := ""	//NJM->( NJM_NFPSER )
	Local cParEspe      := RetParams(NJJ->NJJ_DOCSER)
	Local cEspecie      := ""	//IIf( NJM->( NJM_TPFORM ) = "1", "SPED", NJM->( NJM_DOCESP ) )
	Local cFornecedor   := ""
	Local cLoja         := ""
	Local cAliasClFr    := ""
	Local cUF           := ""
	Local nPSLiq        := 0
	Local nPSubt        := 0
	Local cNFPNum       := ""
	Local cNFPSer       := ""
	Local cEsp1         := ""
	Local cMsgNF        := ""
	Local cMsgNFAux     := ""   
	Local aRetClFr      := {}
	Local cTpFrete      := ""
	Local nFrete        := 0
	Local nSeguro       := 0
	Local nDespesa      := 0    

	/** Variaveis dos Itens do Documento de Entrada */
	Local cItemSeq      := ""
	Local cProduto      := ""
	Local nQuant        := 0
	Local nPreco        := 0
	Local nTotal        := 0
	Local cNfOri        := ""
	Local cSeriOri      := ""
	Local cItemOri      := ""
	Local cTes          := ""
	Local cLocal        := ""
	Local cCodSaf       := ""	//NJM->( NJM_CODSAF )
	Local cCodCtr       := ""	//NJM->( NJM_CODCTR )
	Local cSerie        := ""	//NJM->( NJM_DOCSER )
	Local cIteRom       := ""
	Local cIdentB6      := ""
	Local nItens        := 1
	Local dVcntDAP      := ""
	Local cIncetDAP    	:= ""	//--Incentivo DAP 	- Cadastro de Entidades
	Local cITVDAP      	:= "2"	//--Incent. DAP 	- Possui o Incentivo DAP - 1=Sim;2=Nao
	Local cTxMoeda      := 0
	Local cMoeda        := 0
	Local cClassVlr     := ""
	Local cPdrTer 		:= ""
	Local nX            := 0
	Local nQtdDevol	 	:= 0
	Local lExport		:= .F.
	Local aItens		:= {}
	Local cRegra        := SuperGetMV("MV_ARRPEDC",.F.,"")
	Local nTamPreco     := TamSX3("D1_VUNIT")[2]
	Local cNatuFin      as character
	Local cInsEstad     := ""

	//Variaveis usadas na NFE de devolução quando transferencia entre filiais.
	Local lOri520       := IsInCallStack('AGRA520')
	Local cFiltemp      := cFilAnt
	Local cF1INDPRES    := "" //armazena informação para F1_INDPRES Presença Comprador (NT 2020.006)
	Local cF1CODA1U     := "" //armazena informação para F1_CODA1U Codigo Intermediador (NT 2020.006)	

	Local cTpNrNFS 		:= SuperGetMV("MV_TPNRNFS",.F. ,"1")	
		
	//--Variaveis que indicam qual a movimentação a realizar
	Private _lCtrlTer	:= .F.	//Devolução com controle de teceiros
	Private _lCtrlDev	:= .F.	//Devolução de quantidade
	Private _lCtrlDVl	:= .F.	//Devolução de valores
	Private _lCtrlCom	:= .F.	//Complemento
	Private _lTipNfNB	:= .F.	//Valida se é nota do tipo normal ou beneficiamento 
	Private _lInctDAP	:= .F.	//Valida se entidade é de incentivo DAP
	Private _lCtrlN8K	:= .F.	//Valida se existe vinculo com as tabelas auxiliares de saída

	Private _cNumero    := ""	//NJM->( NJM_DOCNUM )
	Private _cOGUBS_NF  := ""	//fAgrtpnf(NJJ->( NJJ_TIPO ))       
	Private _lNFOrigem  := .T.	//Valida se existe NF para devolução.
	Private lMsErroAuto := .F.	//Mensagem de erro das funções execauto
	Private _lPEQry     := .F.
	Private lmudouNum		:= .f.
	
	Default aTpANFD     := {} 
	Default cRomaneio   := NJJ->( NJJ_CODROM )
	Default	cItRom		:= ''

	Iif(lOri520, cTipoNF = 'D',)
	//--Posiciona na tabela NJJ conforme o Romaneio enviado para a função
	dbSelectArea("NJJ")
	NJJ->( dbSetOrder(1) )
	IF NJJ->( MsSeek(FWxFilial("NJJ")+cRomaneio) )
		cPlaca		:= NJJ->( NJJ_PLACA )
		cCodTra 	:= NJJ->( NJJ_CODTRA )	
		_cOGUBS_NF  := fAgrtpnf(NJJ->( NJJ_TIPO ))  
		If NN2->(FieldPos("NN2_CADPRO") > 0)
			cInsEstad   := Posicione( "NN2",3, FWxFilial("NN2") + NJJ->(NJJ_CODENT+NJJ_LOJENT+NJJ_FAZ), "NN2_CADPRO" ) //Incrição / Cad Pro
		EndIF
	EndIf
	
	//--Posiciona na tabela NJM com o Romaneio enviado por parametro (Romaneio estava se perdendo)
	dbSelectArea("NJM")
	NJM->( dbSetOrder(1) )
	NJM->( MsSeek(FWxFilial("NJM")+cRomaneio+cItRom) )

	dEmissao      	:= IIf( NJM->( NJM_TPFORM ) = "1", dDataBase, NJM->( NJM_DOCEMI ) )
	cFormulario   	:= IIf( NJM->( NJM_TPFORM ) = "1", "S", "N" )
	
	If NJM->(NJM_TPFORM) = "1"
		If Empty(cParEspe)
			cEspecie := "SPED"
		Else
			cEspecie := cParEspe
		EndIf
	Else
		cEspecie := NJM->(NJM_DOCESP)		
	EndIf
		
	cChvNFe       	:= NJM->( NJM_CHVNFE )
	cCodDocF1     	:= NJM->( NJM_CODROM )
	cDocTranNr    	:= NJM->( NJM_NFPNUM )
	cDocTranSe    	:= NJM->( NJM_NFPSER )	
	cCodSaf       	:= NJM->( NJM_CODSAF )
	cCodCtr       	:= NJM->( NJM_CODCTR )
	cSerie        	:= NJM->( NJM_DOCSER )	
	_cNumero		:= NJM->( NJM_DOCNUM )	

	//--Formulario proprio igual a SIM [NJM_TPFORM]
	If cFormulario == "S" .AND. !(lOri520)
		//--Se serie estiver vazio [NJM_DOCSER]
		If Empty(cSerie)
			//Busca serie de nota de entrada da tabela [NJJ_DOCSER]
			cSerie  := Alltrim(NJJ->NJJ_DOCSER)
			//--Se o campo não estiver preenchido pega o valor do parametro
			If Empty (cSerie) 
				cSerie  := SuperGetMV("MV_OGASERE",," ")
			EndIf	
			// Se a serie não estiver preenchida no parametro, abre a tela para seleção da série	
			If Empty(cSerie)
				If .Not. SX5NumNota(@cSerie, cTpNrNFS)
					Return .F.
				EndIf
			EndIf	
		EndIf

		If !Empty(cSerie)
			//--Se for SX5 e não tiver numeração		
			If cTpNrNFS == "1" .and. Empty (_cNumero)  
				_cNumero := NxtSX5Nota(cSerie)
			ElseIf cTpNrNFS == "3" .and. Empty (_cNumero)
				_cNumero := PADL("1",TamSx3('F1_DOC')[1],"0" ) //aqui a numeração pode ser aleatoria, o mata103 ira validar e gerar a numeração correta, porem recomendado não enviar em branco(DAGROOGD-15985).
			EndIf
		EndIf
		
	EndIf
	
	If NJJ->NJJ_TIPO $ "7|9" // Retorno de Remessa OU Devolução de Venda
	/*
		DbSelectArea("N9E")
		N9E->(DbSetOrder(3)) // N9E_FILIAL+N9E_CODROM+N9E_ORIGEM
		If N9E->(DbSeek(FWxFilial("N9E")+cRomaneio+"7"))
			While N9E->(!Eof()) .AND. N9E->(N9E_FILIAL+N9E_CODROM+N9E_ORIGEM) == FWxFilial("N9E")+cRomaneio+"7"
				If RecLock("N9E", .F.)
					N9E->N9E_STARET := '0' // Não foi relacionada a NF de Retorno
					N9E->(MsUnlock())
				EndIf
				
				N9E->(DbSkip())
			EndDo
		EndIf
	*/
	EndIf
	
	If Select((cAliasNJM)) > 0
		((cAliasNJM))->( dbCloseArea() )
	EndIf
	
	//--Agrupa para geração do Documento de compra
	cQueryNJM := " SELECT * "
	cQueryNJM +=   " FROM "+RetSqlName("NJM")+" NJM "
	cQueryNJM +=  " WHERE NJM.NJM_FILIAL = '"+ FWxFilial("NJM") +"'"
	cQueryNJM +=    " AND NJM.NJM_CODROM = '"+ cRomaneio + "'"
	cQueryNJM +=    " AND NJM.NJM_CODENT = '"+ NJM->( NJM_CODENT ) +"'"
	cQueryNJM +=    " AND NJM.NJM_LOJENT = '"+ NJM->( NJM_LOJENT ) +"'"
	cQueryNJM +=    " AND NJM.NJM_DOCNUM = '"+ NJM->( NJM_DOCNUM ) +"'"
	cQueryNJM +=    " AND NJM.NJM_DOCSER = '"+ NJM->( NJM_DOCSER ) +"'"
	cQueryNJM +=    " AND NJM.NJM_TIPMOV = '"+ NJM->( NJM_TIPMOV ) +"'"	 
	cQueryNJM +=    " AND NJM.NJM_STAFIS = '1' "
	cQueryNJM +=    " AND NJM.D_E_L_E_T_ = '' "

	If cPaisLoc == "BRA" .AND. NJM->(fieldPos("NJM_INDPRE")) > 0 .AND. cFormulario == "S" .AND. !EMPTY(NJM->( NJM_INDPRE)) //SE CAMPO EXISTIR FILTRA PARA QUEBRA
		cQueryNJM +=    " AND NJM.NJM_INDPRE = '"+ NJM->( NJM_INDPRE) +"' " //Presença Comprador (NT 2020.006)
		cQueryNJM +=    " AND NJM.NJM_CODA1U = '"+ NJM->( NJM_CODA1U) +"' " //codigo Intermediador (NT 2020.006)
	EndIf

	/* 
	 * Quando for Tipos que a Tes não movimenta financeiro (muito provavel para estes tipos)
	 * tiro o contrato do cwhere Pois não preciso gerar titulo por contrato como é no caso de compras
	 * nestes casos do tipo 7  provavelmente não tenha nem mesmo titulo 
	 */	

	If NJM->NJM_TIPO $ "7"   
		cQueryNJM += " AND NJM.NJM_CODCTR != ' ' "
	Else
		cQueryNJM += " AND NJM.NJM_CODCTR = '" + NJM->( NJM_CODCTR ) + "'"
	EndIF
	
	cQueryNJM := ChangeQuery(cQueryNJM)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryNJM),(cAliasNJM),.F.,.T.)
	
	dbSelectArea((cAliasNJM))
	((cAliasNJM))->( dbGoTop() )
	While ((cAliasNJM))->( .NOT. Eof() )

		//--Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio e cadastrado na entidade/loja
		aRetClFr    := OGA250ClFr( (cAliasNJM)->( NJM_CODENT ), (cAliasNJM)->( NJM_LOJENT ), (cAliasNJM)->( NJM_TES ), (cAliasNJM)->( NJM_TIPO ), (cAliasNJM)->( NJM_QTDFIS ), NJJ->NJJ_FILIAL )
		cTipoNF     := aRetClFr[ 1 ]	//--Tipo de nota fiscal a ser gerada
		cFornecedor := aRetClFr[ 2 ]	//--Código do cliente ou fornecedor
		cLoja       := aRetClFr[ 3 ]	//--Loja do cliente ou fornecedor
		cAliasClFr  := aRetClFr[ 4 ]	//--Alias de retorno (SA1 ou SA2)
	     
		If cAliasClFr == "SA1"
			cUF  := Posicione( cAliasClFr, 1, FWxFilial( cAliasClFr ) + cFornecedor + cLoja, "A1_EST" )
		Else
			cUF  := Posicione( cAliasClFr, 1, FWxFilial( cAliasClFr ) + cFornecedor + cLoja, "A2_EST" )
		EndIf
	
		cIncetDAP	:= Posicione( "NJ0", 1, FWxFilial('NJ0') + (cAliasNJM)->( NJM_CODENT ) + (cAliasNJM)->( NJM_LOJENT ), "NJ0_ITVDAP" )		//--Possui o Incentivo DAP   
		dVcntDAP    := Posicione( "NJ0", 1, FWxFilial('NJ0') + (cAliasNJM)->( NJM_CODENT ) + (cAliasNJM)->( NJM_LOJENT ), "NJ0_DTVDAP" )  	//--Data Vencimento DAP
		
		//--Se entidade não estiver com vinculo de fornecedor/cliente
		If Empty(cFornecedor) .or. Empty(cLoja)
			Help( ,, STR0026,, STR0025, 1, 0) //'Erro'###"Fornecedor e Loja da Entidade não pode ser branco."
			Exit
			Return .F.
		EndIf

		cProduto	:= (cAliasNJM)->( NJM_CODPRO )
		nQuant     	:= (cAliasNJM)->( NJM_QTDFIS )
		nPreco     	:= (cAliasNJM)->( NJM_VLRUNI )
		nTotal     	:= (cAliasNJM)->( NJM_VLRTOT )
		If !Empty(cRegra) .AND. NJJ->NJJ_TPFORM == '1' //apenas quando for formulario proprio
			If AllTrim(cRegra) == "NOROUND"
				nPreco := NOROUND(nTotal/nQuant,nTamPreco)
				nTotal := nQuant * nPreco
			ElseIf AllTrim(cRegra) == "ROUND"
				nPreco := Round(nTotal/nQuant,nTamPreco)
				nTotal := nQuant * nPreco
			EndIf			
		EndIf
		cLocal     	:= (cAliasNJM)->( NJM_LOCAL )
		cCodCtr 	:= (cAliasNJM)->( NJM_CODCTR )
		cCodRom 	:= (cAliasNJM)->( NJM_CODROM )
		cIteRom 	:= (cAliasNJM)->( NJM_ITEROM )
		cNFPNum 	:= (cAliasNJM)->( NJM_NFPNUM )
		cNFPSer 	:= (cAliasNJM)->( NJM_NFPSER )
		cTes        := (cAliasNJM)->( NJM_TES )
		cCodSaf  	:= (cAliasNJM)->( NJM_CODSAF )
		cLoteCtl	:= (cAliasNJM)->( NJM_LOTCTL )
		If __lnewNeg
			cClassVlr  	:= (cAliasNJM)->( NJM_CLVL)
		EndIf 
		//--Tratando Frete, Seguro e Despesas --//
		IF NJM->( FieldPos("NJM_FRETE") ) > 0 
			nFrete      += (cAliasNJM)->( NJM_FRETE )
			nSeguro 	+= (cAliasNJM)->( NJM_SEGURO )
			nDespesa    += (cAliasNJM)->( NJM_DESPES )
		EndIF

		If cPaisLoc == "BRA" .AND. NJM->(fieldPos("NJM_INDPRE")) > 0 .AND. cFormulario == "S" .AND. !EMPTY((cAliasNJM)->( NJM_INDPRE )) //SE CAMPO EXISTIR E COM VALOR
			cF1INDPRES 	:= (cAliasNJM)->( NJM_INDPRE ) //Presença Comprador (NT 2020.006)
			cF1CODA1U	:= (cAliasNJM)->( NJM_CODA1U ) //codigo Intermediador (NT 2020.006)
		EndIf

		cMsgAux := ""
		dbSelectArea( "NJR" )
		NJR->( dbSetOrder( 1 ) )
		If NJR->( MsSeek( FWxFilial( "NJR" ) + cCodCtr ) )
			If Empty(cEsp1)
				cEsp1   := NJR->( NJR_TIPEMB )
			EndIf
			If !Empty(NJR->( NJR_MSGNFS ))
				cMsgNFAux   := NJR->NJR_MSGNFS
			EndIf
			cTpFrete	:= NJR->NJR_TPFRET  	//--Vai pegar o Tipo de frete do contrato do ultimo item do njm
			cMoeda   	:= NJR->NJR_MOEDA
			cTxMoeda 	:= NJR->NJR_TXMOED
		EndIf

		//--Ajustando a mensagem da NF                                                                 --//
		//--Se existe Mensagem de NF. no romaneio considera o romaneio, senão Considera do Ctrato.     --//
		IF .NOT. Empty( NJM->NJM_MSGNFS )
			cMsgNF	+= Alltrim( NJM->NJM_MSGNFS )
		Else
			cMsgNF	+= Alltrim( cMsgNFAux )
		EndIF  

		If (cAliasNJM)->( NJM_TIPMOV ) = "2"
			nQuant	:= 0
		EndIf
		
		//-- Para romaneios do tipo 7-Dev. Remessa ou 9-Dev. Venda
		//-- Com notas do tipo N-Normal D-Devolução
		If (cAliasNJM)->( NJM_TIPO ) $ "7|9" .And. cTipoNF $ "N|D"
			//--Se a quantidade [NJM_QTDFIS]  for diferente de Zero
			If nQuant <> 0
				//--Se a TES controla poder de terceiro R=Remessa;D=Devolucao;N=Nao Controla
				cPdrTer := Posicione( "SF4", 1, FWxFilial('SF4') + cTes, "F4_PODER3" )
				If cPdrTer $ "DR"
					//--Indica que controla terceiros
					_lCtrlTer := .T.								
				//--Não controla poder em terceiros
				Else
					//--Indica que controla devolução quantidade
					_lCtrlDev := .T.									
				EndIf //--Fim cPdrTer
				
				nQtdDevol := (cAliasNJM)->(NJM_QTDFIS)
				/*
				DbSelectArea("N9E") // Romaneios X Angendamentos
				N9E->(DbSetOrder(1)) // N9E_FILIAL+N9E_CODROM+N9E_SEQUEN
				If N9E->(dbSeek(xFilial("N9E")+cRomaneio))
					If !(N9E->(Eof()))			
						If N9E->(N9E_ORIGEM) == "2"
							nQtdDevol := NJJ->(NJJ_QTDFIS)
							lExport	  := .T.
						EndIf									
					EndIf
				EndIf
				N9E->(dbCloseArea())				
				*/

				//--Seleciona as notas fiscais de devoluções
				If __lnewNeg
					aSelNfs := SelNfs(cRomaneio, (cAliasNJM)->( NJM_CODCTR ), nQtdDevol, cProduto, cLoteCtl, lExport)
				Else
					aSelNfs := SelNfsDev( (cAliasNJM)->( NJM_CODCTR ), (cAliasNJM)->( NJM_QTDFIS ), cProduto, cLoteCtl )
				EndIf 
				
				If Len( aSelNfs ) <= 0 .And. _lNFOrigem
					if !_lPEQry
						Help( , , STR0015, , STR0024, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
					endIf
					(cAliasNJM)->( dbCloseArea() )
					Return( .f. )
				EndIf
				  
			//--Senão, Se a quantidade [NJM_QTDFIS]  for igual a Zero     
			Else 
				//--Indica que controla devolução de valor
				_lCtrlDVl 	:= .T.
				nQuant 		:= 0
				
				//--Seleciona as notas fiscais de devoluções
				aSelNfs := SelNfs( cRomaneio, (cAliasNJM)->( NJM_CODCTR ), (cAliasNJM)->( NJM_VLRTOT ), cProduto, cLoteCtl )
				
				If Len( aSelNfs ) <= 0 .And. _lNFOrigem
					Help( , , STR0015, , STR0024, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
					(cAliasNJM)->( dbCloseArea() )
					Return( .f. )
				EndIf
			EndIf //nQuant <> 0
			
			//-- Para romaneios do tipo 7-Dev. Remessa e Não tem nota fiscal de origem
			If NJM->( NJM_TIPO ) $ "7" .And. !Empty(cNfOri)
				//--Seleciona a tabela SD2 - Itens de Nota Fiscal de Saída
				dbSelectArea("SD2")
				SD2->( dbSetOrder( 3 ) )	//--D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
				If SD2->( MsSeek( FWxFilial( "SD2" ) + cNfOri + cSeriOri + cFornecedor + cLoja + cProduto + cItemOri) )
					If SD2->( D2_TIPO ) = "N"
						cTipoNF := "B"
					EndIf
				EndIf
			EndIf
			
		//--Se tipo da nota fiscal for do tipo de complemento	
		ElseIf cTipoNF $ "C"
			//--Indica que controla complemento
			_lCtrlCom 	:= .T.
			nQuant 		:= 0
			
			//--Seleciona as notas fiscais de complemento
			aSelNfs := SelNfs( cRomaneio, (cAliasNJM)->( NJM_CODCTR ),0,cProduto, cLoteCtl  )
			             
			If Len( aSelNfs ) <= 0 .And. _lNFOrigem
				Help( , , STR0015, , STR0024, 1, 0 ) //"AJUDA"###"E obrigatoria a selecao dos documentos de Origem!"
				(cAliasNJM)->( dbCloseArea() )
				Return( .f. )
			EndIf
			
		ElseIf cTipoNF $ "D"
			nQuant   := aTpANFD[4] //Peso da pendencia gerada(AGRA520).
			nTotal   := nQuant * nPreco
			cNfOri	 := (cAliasNJM)->( NJM_DOCNUM )
			cSeriOri := (cAliasNJM)->( NJM_DOCSER )
			cItemOri := (cAliasNJM)->( NJM_DOCITE )			 
			_cNumero := aTpANFD[1]
			cSerie   := aTpANFD[2]
			cTES     := Posicione('SF4',1,FWxFilial('SF4')+cTES,'F4_TESDV')
			dEmissao    := dDatabase		
			cFormulario := 'N'
			cEspecie    := 'NFE'
			
			//Até aqui, peguei todos os dados do romaneio que está na filial de destino da pendência
			// Agora preciso logar na filial de origem para gerar a NFE de devolução.
			//cFilAnt     := Posicione('NJ0',1,FWxFilial('NJ0')+(cAliasNJM)->NJM_CODENT+(cAliasNJM)->NJM_LOJENT,'NJ0_CODCRP')
		
		Else
			If cTipoNF $ "N|B"
				 _lTipNfNB := .T.
			EndIf

			//--Produto Adicional
			dbSelectArea("NJV")
			NJV->( dbSetOrder( 1 ) )
			If NJV->( MsSeek( xFilial( "NJV" ) + cProduto ) )
				//--Se entidade controla incentivo DAP 
				//--E a data de vencimento do DAP é maior ou igual a emissão
				//--E não vazio o codigo Produto Adicional 
				//--E tipo do romaneio igual a Entrada por Compra
				If cIncetDAP == "1" .And. dVcntDAP >= dEmissao .And. !Empty(NJV->( NJV_CODSPD )) .And. NJM->( NJM_TIPO ) $ "5"
					_lInctDAP 	:= .T.
					
					cProduto    := NJV->( NJV_CODSPD )
					nPreco      := NJV->( NJV_VALOR )
					nTotal      := Round( ( nQuant * nPreco ), TamSX3( "D1_VUNIT" )[2] )
					cITVDAP   	:= "1"
					cNfOri		:= ''
					cSeriOri	:= ''
					cItemOri	:= ''	
					cLoteCtl    := ''				
				EndIf
			Endif
		EndIf

		For nX := 1 to If(Len( aSelNfs ) > 0, Len( aSelNfs ), 1)
			//-- Se encontrou a NF
			If _lNFOrigem 
				cItemSeq    := StrZero( nItens, TamSX3( "D1_ITEM" )[1] )
				//-- Se array for maior que zero 
				If Len( aSelNfs ) > 0
					If __lVlUnitDev 
						nPreco  := (cAliasNJM)->NJM_VLRUNI  
                        nTotal  := aSelNfs[ nX, COL_DISTRIB  ]  * nPreco  						
					Else
						nPreco  := aSelNfs[ nX, COL_VUNIT   ]
						nTotal  := If(aSelNfs[ nX, COL_VDISTR  ] <> Nil ,aSelNfs[ nX, COL_VDISTR  ] , aSelNfs[ nX, COL_VTOTAL  ] )
					EndIf
					cNfOri      := aSelNfs[ nX, COL_DOC 	]
					cSeriOri    := aSelNfs[ nX, COL_SERIE 	]
					cItemOri    := aSelNfs[ nX, COL_ITEM 	]
					//--Se contrato for de terceiros
					If _lCtrlTer
						cIdentB6    := aSelNfs[ nX, COL_IDENTB6 ]
					EndIf 	
					//--Se contrato for de devolução de valor
					If _lCtrlDVl
						nQuant  := 0
					//--Se contrato não for de complemento
					ElseIf .NOT. _lCtrlCom
						nQuant	:= aSelNfs[ nX, COL_DISTRIB ]
					EndIf
				EndIf 
			//--Se não encontrou a NF
			Else
				cTipoNF     := "N"
				cItemSeq    := StrZero( nItens, TamSX3( "D1_ITEM" )[1] )
				cNfOri		:= ''
				cSeriOri	:= ''
				cItemOri	:= ''
			EndIf
			
			//----Alimenta o array para geração da NF
			aLinha := {}
			If cPaisLoc == "PAR" //Paraguai
				aAdd( aLinha, { "D1_UM"         , Posicione('SB1',1,xFilial('SB1')+cProduto,'B1_UM'), Nil } )
				aAdd( aLinha, { "D1_CF"         , Posicione('SF4',1,xFilial('SF4')+cTes,'F4_CF'), Nil } )
			EndIf
			
				
			aAdd( aLinha, { "D1_COD"        , cProduto          , Nil } )
			
			IF nQuant > 0  
				aAdd( aLinha, { "D1_QUANT"      , nQuant            , Nil } )	//_lCtrlDVl  _lCtrlCom _lTipNfNB
			EndIf
			
			aAdd( aLinha, { "D1_VUNIT"      , nPreco            , Nil } )
			aAdd( aLinha, { "D1_TOTAL"      , nTotal            , Nil } )
			aAdd( aLinha, { "D1_LOCAL"      , cLocal            , Nil } )
			aAdd( aLinha, { "D1_TES"        , cTes              , Nil } )
			aAdd( aLinha, { "D1_CTROG"      , cCodCtr           , Nil } )
			aAdd( aLinha, { "D1_CODSAF"     , cCodSaf           , Nil } )
			aAdd( aLinha, { "D1_CODROM"     , cCodRom           , Nil } )
			aAdd( aLinha, { "D1_ITEROM"     , cIteRom           , Nil } )
			aAdd( aLinha, { "D1_NFPNUM"     , cNFPNum           , Nil } )
			aAdd( aLinha, { "D1_NFPSER"     , cNFPSer           , Nil } )
			aAdd( aLinha, { "D1_PLACA"      , cPlaca            , Nil } )
			If (_lNFOrigem .AND. Len( aSelNfs ) > 0) .OR. lOri520
				aAdd( aLinha, { "D1_NFORI"      , cNfOri        , Nil } )
				aAdd( aLinha, { "D1_SERIORI"    , cSeriOri      , Nil } )
				aAdd( aLinha, { "D1_ITEMORI"    , cItemOri      , Nil } )
			EndIF
			If _lCtrlTer
				aAdd( aLinha, { "D1_IDENTB6"    , cIdentB6          , Nil } )	//_lCtrlTer senão não tem
			EndIf
			
			if !Empty(cLoteCtl)
				aAdd( aLinha, { "D1_LOTECTL"    , cLoteCtl          , Nil } )
			EndIf
			
			aAdd( aLinha, { "D1_CLVL"       , cClassVlr         , Nil } )
			aAdd( aItens, aLinha )

			nItens++

		Next nX
		
		nPSLiq  += (NJJ->( NJJ_PSLIQU ) * (cAliasNJM)->( NJM_PERDIV ) / 100)
		nPSubt  += (NJJ->( NJJ_PSSUBT ) * (cAliasNJM)->( NJM_PERDIV ) / 100)

		(cAliasNJM)->( dbSkip() )
	EndDo

	(cAliasNJM)->( dbCloseArea() )

	If ! Len(cSerie) = TamSx3('F1_SERIE')[1]
		cSerie := PadR(Alltrim(cSerie),TamSx3('F1_SERIE')[1] )
	EndIf   

	aAdd( aCab, { "F1_TIPO"     , cTipoNF       } )
	aAdd( aCab, { "F1_FORMUL"   , cFormulario   } )
	aAdd( aCab, { "F1_SERIE"    , cSerie        } )
	aAdd( aCab, { "F1_DOC"      , _cNumero      } )
	aAdd( aCab, { "F1_EMISSAO"  , dEmissao      } )
	aAdd( aCab, { "F1_FORNECE"  , cFornecedor   } )
	aAdd( aCab, { "F1_LOJA"     , cLoja         } )
	aAdd( aCab, { "F1_ESPECIE"  , cEspecie      } )
	aAdd( aCab, { "F1_COND"     , NJM->( NJM_CONDPG ) } )
	aAdd( aCab, { "F1_UF"       , cUf           } )
	
	//valido se a tes tem financeiro
	If (Posicione("SF4",1,xFilial("SF4")+cTes,"F4_DUPLIC") == 'S')
		//pego a natureza do cliente
		If cAliasClFr == "SA1"
			cNatuFin := Posicione("SA1",1,FwXFilial("SA1")+cFornecedor+cLoja,"A1_NATUREZ")
		Else
			cNatuFin := Posicione("SA2",1,FwXFilial("SA2")+cFornecedor+cLoja,"A2_NATUREZ")
		EndIf	

		aAdd( aCab,  {"F1_NATUREZ"   ,cNatuFin,NIL})

	EndIf

	If .Not. Empty( cChvNFe )
		aAdd( aCab, { "F1_CHVNFE"  ,cChvNFe   } )
	EndIf

	// Codigo do Movimento Fiscal
	aAdd( aCab, { "F1_CODROM"      ,cCodDocF1 } )

	// Especie e Mensagem da Nota
	If .Not. Empty(  cEsp1 )
		aAdd( aCab, { "F1_ESPECI1" ,cEsp1     } )
	EndIf

	If .Not. Empty( cMsgNF )
		aAdd( aCab, { "F1_MENNOTA" ,OemToansi( AllTrim(cMsgNF) ) } )
	EndIf

	// Peso Liquido 
	If nPSLiq > 0 
		aAdd( aCab, { "F1_PLIQUI"  ,Iif (!(lOri520), nPSLiq, nQuant) } )
	EndIf

	// Peso Bruto
	If nPSubt > 0
		aAdd( aCab, { "F1_PBRUTO"  ,Iif (!(lOri520), nPSubt, nQuant) } )
	EndIf

	// Placa    
	If .Not. Empty( cPlaca )
		aAdd( aCab, { "F1_PLACA"   ,cPlaca  } )
	EndIf

	// Transportadora
	If .Not. Empty( cCodTra )
		aAdd( aCab, { "F1_TRANSP"  ,cCodTra } )
	EndiF

	//-- Emerson Implementação para tratar Vr. de Frete,Seguto,Outras despesas. --//
	IF nFrete > 0
		cTpFrete := IF( !Empty(NJJ->NJJ_TPFRET), NJJ->NJJ_TPFRET, cTpFrete )

		aAdd( aCab, {"F1_TPFRETE"   , cTpFrete      , Nil } )
		aAdd( aCab, {"F1_FRETE"     , nFrete        , Nil } )
	Else
		aAdd( aCab, {"F1_TPFRETE"   , cTpFrete      , Nil } )
	EndIF

	if nSeguro > 0
		aAdd( aCab, {"F1_SEGURO"    , nSeguro       , Nil } )
	EndIF
	IF nDespesa > 0
		aAdd( aCab, {"F1_DESPESA"   , nDespesa      , Nil } )
	EndIF

	If cPaisLoc == "PAR" //Paraguai
		aAdd( aCab,  {"F1_NATUREZ"   ,Space(TamSx3("F1_NATUREZ")[2])                              ,NIL})
		aAdd( aCab,  {"F1_DTDIGIT"   ,dDataBase                                                   ,NIL})
		aAdd( aCab,  {"F1_MOEDA"     ,cMoeda                                                      ,NIL})
		aAdd( aCab,  {"F1_TXMOEDA"   ,IIf(cMoeda=1, 1,cTxMoeda)                                   ,NIL})
		aAdd( aCab,  {"F1_TIPODOC"   ,"60"                                                        ,NIL})
		aAdd( aCab,  {"F1_EST"       ,Posicione("SA2",1,xFilial("SA2")+cFornecedor+cLoja,"A2_EST"),NIL})
	EndIf

	If cPaisLoc == "BRA" .AND. SF1->(FieldPos("F1_INDPRES")) > 0 .AND. cFormulario == "S"
		If NJM->(FieldPos("NJM_INDPRE")) > 0 .AND. !Empty(cF1INDPRES) 
			aAdd( aCab, {"F1_INDPRES", cF1INDPRES, Nil } )	//Presença Comprador (NT 2020.006)
			If !Empty(cF1CODA1U) 
				aAdd( aCab, {"F1_CODA1U", cF1CODA1U, Nil } ) //codigo Intermediador (NT 2020.006)
			EndIf
		Else
			aAdd( aCab, {"F1_INDPRES", "0", Nil } )	////Presença Comprador (NT 2020.006) --> valor padrão 0 = Não Aplica
		EndIf
	EndIf
	
	//----------------------------------------------------------------------------//

	If Len( aCab ) > 0 .And. Len( aItens ) > 0
		// Ponto de entrada inserido para controlar dados especificos do cliente 22/12/2015
		// Antes de Chamar a Mata103
		If ExistBlock("OGX009NF")
			aRetPe := ExecBlock("OGX009NF",.F.,.F.,{aCab,aItens})
			If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
				aCab    := aClone(aRetPe[1])
				aItens  := aClone(aRetPe[2])
			EndIf
			/* Exemplo do PE
			#include 'protheus.ch'
			#include 'parmtype.ch'

			User Function OGX009NF()
			Local aCab      := aClone(PARAMIXB[1])
			Local aItens    := aClone(PARAMIXB[2])
			Local aRet := {} //Customizações do usuário

			Local nPMenNf   :=  aSCAN(aCab, {|aCab| aCab[1] == "F1_MENNOTA" })

			IF nPMenNf > 0 // Ja stá no array
			aCab[nPmenNf,1] += 'Mensagem do PE OGX009NF'  // 
			Else // Ainda n. se encontra no Array Adicionar
			aAdd( aCab, { "F1_MENNOTA"  , 'Mensagem do PE OGX009NF' } )
			EndIF

			aRet := {aCab,aItens}

			Return aRet
			*/
		EndIf
		aCab   := FWVetByDic(aCab, 'SF1')
		aItens := FWVetByDic(aItens, 'SD1',.T.)

		/* Necessitamos solicitar o modulo pois alguns campos como LOTE e DTLOTE
		não estao setados para trabalhar com o SIGAAGR */
		cModulo := "COM"
		nModulo := 2

		If cPaisLoc == "PAR"
			If NJM->NJM_TIPO $ "3|5|7"
				// Executa a rotina automatica para geracao do Remito de Entrada... 
				MSExecAuto({|x,y| Mata102N(x,y)},aCab,aItens)
			ElseIf NJM->NJM_TIPO == "9" //Mata462dn
				// Executa a rotina automatica para geracao do Remito de Entrada...
				If NJM->NJM_TPFORM == "1"
					MSExecAuto( { | x, y, z | LocxNf( x, y, z ) }, 51, aCab, aItens, 3 )
				Else
					MSExecAuto( { | x, y, z | LocxNf( x, y, z ) }, 53, aCab, aItens, 3 )
				EndIf
			EndIf

		Else
			MSExecAuto( { | x, y, z | Mata103( x, y, z ) }, aCab, aItens, 3 ) //Opção desejada: 3-Inclusão; 4-Alteração ; 5-Exclusão
		EndIf

		//Retornando o modulo do SIGAAGR
		cModulo := cModAtu
		nModulo := nModAtu

		If lMsErroAuto
			MostraErro()
			RestArea( aAreaAtu )
			Return( .f. )
		Else
			If cPaisLoc == "PAR"
				dbSelectArea("SF1")
				SF1->( dbSetOrder(1) )
				SF1->( MsSeek(xFilial("SF1")+_cNumero+cSerie+cFornecedor+cLoja+cTipoNF) )

				If Reclock("NJJ",.F.)
					NJJ->NJJ_DOCSER := SF1->F1_SERIE
					NJJ->NJJ_DOCNUM := SF1->F1_DOC
					NJJ->NJJ_DOCEMI := SF1->F1_EMISSAO
					NJJ->NJJ_DOCESP := SF1->F1_ESPECIE
					NJJ->NJJ_STAFIS := "2"
					NJJ->(MsUnLock()) 
				EndIf

				If Reclock("NJM",.F.)
					NJM->NJM_DOCSER := SF1->F1_SERIE
					NJM->NJM_DOCNUM := SF1->F1_DOC
					NJM->NJM_DOCEMI := SF1->F1_EMISSAO
					NJM->NJM_DOCESP := SF1->F1_ESPECIE
					NJM->NJM_CHVNFE := SF1->F1_CHVNFE
					NJM->NJM_STAFIS := "2"
					NJM->NJM_DTRANS := dDatabase
					NJM->(MsUnLock()) 
				EndIf
			Else
				If NN2->(FieldPos("NN2_CADPRO") > 0)
					If Reclock("NJM",.F.)
						NJM->NJM_CADPRO := cInsEstad
						NJM->(MsUnLock()) 
					EndIf	
				EndIf
			EndIf
		EndIf
	Else
		RestArea( aAreaAtu )
		Return( .f. )
	EndIf
	
	//Devolvo a filial logada originalmente
	cFiltemp := cFilAnt

	RestArea( aAreaAtu )
Return( .t. )

/** {Protheus.doc} SelNfs
Função auxiliar para seleção de documentos de origem para amarracao na NF de devolução ou complemento.

@param: Nil
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGX009
*/
Static Function SelNfs( cRomaneio, cCodCtr, nQtdDev, cProduto, cLoteCtl, lExport )
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
	Local cQueryFix     := ""
	Local cQuerySD2		:= ""
	Local nSaldo        := 0
	Local nQtdFix		:= 0
	Local cCodRomaneio	:= ""
	Local lRetDevol     := .F.
	Local aNFRet	    := {}
	Local lNFRet	    := .F.
	Local nQtdNF		:= 0
	Local nIt		    := 0

	Private oBrowse     := Nil
	Private oSay        := Nil
	Private nQtdAdl     := nQtdDev
	Private nQtdSel     := 0
	Private nValSel     := 0 
	Private cAliasNNC   := ''
	Private cAliasSD2 	:= ''
	Private cAliasN9E	:= ''
	Private cQueryN9E	:= '' 
	
	Default lExport := .F.

	aAdd( aButtons, { "", {|| EditQtd() }, OemToAnsi( "Editar" ) } )
	
	If !lExport	
		
		cAliasN9E := GetNextAlias()
		cQueryN9E := " SELECT N9E.N9E_DOC, N9E.N9E_SERIE, N9E.N9E_CLIFOR, N9E.N9E_LOJA, N9E.N9E_ITEDOC, N9E.N9E_QTDRET "
		cQueryN9E += "   FROM " + RetSqlName("N9E")+ " N9E "
		cQueryN9E +=  " WHERE N9E.D_E_L_E_T_ = ' ' "
		cQueryN9E +=  "   AND N9E.N9E_ORIGEM = '7' " // Nota Fiscal
		cQueryN9E +=  "   AND N9E.N9E_STARET = '0' " // Não vinculado a retorno	
		cQueryN9E +=  "   AND N9E.N9E_CODROM = '"+cRomaneio+"'"
		cQueryN9E +=  "   AND N9E.N9E_FILIAL = '" + FWxFilial("N9E") + "' " 
	 
		cQueryN9E := ChangeQuery(cQueryN9E)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryN9E),cAliasN9E,.F.,.T.)
	
		DbSelectArea((cAliasN9E))  
		(cAliasN9E)->( dbGoTop())	
		If !(cAliasN9E)->(Eof())
			lRetDevol := .T.
			
			While !(cAliasN9E)->(Eof())
			 	 Aadd(aNFRet, {(cAliasN9E)->N9E_DOC, (cAliasN9E)->N9E_SERIE, (cAliasN9E)->N9E_CLIFOR, (cAliasN9E)->N9E_LOJA, (cAliasN9E)->N9E_ITEDOC, (cAliasN9E)->N9E_QTDRET})
			 
				 (cAliasN9E)->(DbSkip())
			EndDo
		EndIf				
		(cAliasN9E)->(dbCloseArea())
		
		dbSelectArea("N8K")
		N8K->(dbSetOrder(3))	//N8K_FILIAL+N8K_CODCTR+N8K_CODROM+N8K_ITEROM+N8K_CODFIX
		If N8K->( MsSeek(FWxFilial("N8K") + cCodCtr )) 
			_lCtrlN8K := .T.
		EndIf
	Else	
		_lCtrlN8K := .T.
		
		/*  */
		cAliasN9E := GetNextAlias()
		cQueryN9E += " SELECT DISTINCT N9E.N9E_CODROM "
		cQueryN9E += "   FROM " + RetSqlName('N9E')+ " N9E "
		cQueryN9E +=  " WHERE N9E.N9E_FILIAL = '"+ FWxFilial("N9E") +"'"
		cQueryN9E +=    " AND EXISTS (SELECT 1 FROM " + RetSqlName('N9E')+ " N9E2 "
		cQueryN9E +=    "             WHERE N9E2.N9E_FILIAL = N9E.N9E_FILIAL "
		cQueryN9E +=				  " AND N9E2.N9E_CODROM = '"+ cRomaneio +"' "
		cQueryN9E +=				  " AND N9E2.N9E_PEDIDO = N9E.N9E_PEDIDO "
		cQueryN9E +=				  " AND N9E2.N9E_ORIGEM = '2' "
		cQueryN9E +=                  " AND N9E2.D_E_L_E_T_ = ' ') "
		cQueryN9E +=    " AND N9E.N9E_ORIGEM = '1' "	
		cQueryN9E +=    " AND N9E.D_E_L_E_T_ = ' ' "
		
		cQueryN9E := ChangeQuery(cQueryN9E)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryN9E),cAliasN9E,.F.,.T.)
	
		DbSelectArea((cAliasN9E))  
		(cAliasN9E)->( dbGoTop())
		If !(cAliasN9E)->(Eof())
			cCodRomaneio := (cAliasN9E)->N9E_CODROM
		EndIf
		(cAliasN9E)->(dbCloseArea())		
	EndIf
	
	cAliasSD2 := GetNextAlias() 
	cQuerySD2 += " SELECT SD2.D2_DOC,    SD2.D2_SERIE,  SD2.D2_EMISSAO,  	"
	cQuerySD2 +=        " SD2.D2_ITEM,   SD2.D2_QUANT,  SD2.D2_PRCVEN,    	"
	cQuerySD2 +=        " SD2.D2_TOTAL, ( SD2.D2_QUANT - SD2.D2_QTDEDEV ) AS D2_SALDO,	"
	cQuerySD2 +=        " SD2.D2_IDENTB6, SD2.D2_LOTECTL "
	
	If !_lCtrlN8K
		cQuerySD2 += ", SD2.D2_CTROG "
	EndIf
	
	If lRetDevol 
		cQuerySD2 += ", SD2.D2_CLIENTE, SD2.D2_LOJA "
	EndIf
	
	//--Para quando tiver vinculo das notas de saida
	If _lCtrlN8K
		cQuerySD2 += " ,N8K.N8K_CODROM AS CODROM, N8K.N8K_ITEROM AS ITEROM "
	Else 
		cQuerySD2 += " ,SD2.D2_CODROM AS CODROM, SD2.D2_ITEROM AS ITEROM"
	EndIF 
	
	//--Para devolução com terceiros verificar a tabela SB6
	IF _lCtrlTer
		cQuerySD2 += ", SB6.B6_SALDO " 
	EndIF

	cQuerySD2 += " FROM " + RetSqlName('SD2')+ " SD2 " 
	
	//--Para devolução com terceiros verificar a tabela SB6
	IF _lCtrlTer
		cQuerySD2 += " INNER JOIN " + RetSqlName('SB6')+ " SB6 "
		cQuerySD2 +=         " ON SB6.D_E_L_E_T_  = '' "
		cQuerySD2 +=        " AND SB6.B6_FILIAL  = SD2.D2_FILIAL "
		cQuerySD2 +=        " AND SB6.B6_IDENT   = SD2.D2_IDENTB6 "
		cQuerySD2 +=        " AND SB6.B6_SALDO   > 0 "
	EndIF	
	
	//--Para quando tiver vinculo das notas de saida
	If _lCtrlN8K
		cQuerySD2 += " INNER JOIN " +  RetSqlName('N8K')+ " N8K " 
		cQuerySD2 +=         " ON N8K.D_E_L_E_T_ 	= '' "
		cQuerySD2 +=        " AND N8K.N8K_FILIAL 	= SD2.D2_FILIAL "
		cQuerySD2 +=        " AND N8K.N8K_DOC		= SD2.D2_DOC 	"
		cQuerySD2 +=        " AND N8K.N8K_SERIE		= SD2.D2_SERIE 	"
		cQuerySD2 +=        " AND N8K.N8K_ITEDOC	= SD2.D2_ITEM	"	
		cQuerySD2 +=        " AND N8K.N8K_CLIFOR	= SD2.D2_CLIENTE"
		cQuerySD2 +=        " AND N8K.N8K_LOJA		= SD2.D2_LOJA 	"
		cQuerySD2 +=        " AND N8K.N8K_PRODUT	= SD2.D2_COD	"	
		
		If !lExport		
			cQuerySD2 +=        " AND N8K.N8K_CODCTR	= '"+ cCodCtr +"'"
		Else
			cQuerySD2 +=        " AND N8K.N8K_CODROM	= '"+ cCodRomaneio +"'"
		EndIf	
	EndIf 	

	cQuerySD2 += " WHERE SD2.D_E_L_E_T_ = '' "
	cQuerySD2 += " AND SD2.D2_FILIAL  = '"+ FWxFilial("SD2") +"'"
	cQuerySD2 += " AND SD2.D2_LOTECTL = '"+ cLoteCtl +"'"
	
	//--Se complemento
	If _lCtrlCom
		cQuerySD2 += " AND SD2.D2_TIPO    = 'N' "
		cQuerySD2 += " AND SD2.D2_QUANT   > 0 "
	Else
		cQuerySD2 += " AND SD2.D2_COD     = '"+ cProduto +"'"
		cQuerySD2 += " AND ( SD2.D2_QUANT - SD2.D2_QTDEDEV ) > 0 "
	EndIf 
	
	IF .NOT. _lCtrlN8K
		cQuerySD2 += " AND SD2.D2_CTROG = '"+ cCodCtr +"'"
	EndIF 
	
	cQuerySD2 += " ORDER BY SD2.D2_EMISSAO, SD2.D2_SERIE, SD2.D2_DOC "
	cQuerySD2 := ChangeQuery(cQuerySD2)
	If Select("cAliasSD2") <> 0
		(cAliasSD2)->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySD2),cAliasSD2,.F.,.T.)

	DbSelectArea( (cAliasSD2) )  
	(cAliasSD2)->( dbGoTop() )

	(cAliasSD2)->( dbGoTop() )
	If (cAliasSD2)->( Eof() )
		(cAliasSD2)->( dbCloseArea() )
		RestArea( aAreaAtu )
		_lNFOrigem := .F.
		Return( aRetorno )
	EndIf

	While .Not. (cAliasSD2)->( Eof() )
	
		nQtdNF := (cAliasSD2)->(D2_QUANT)
	
		If lRetDevol		
			lNFRet := .F.
		
			For nIt := 1 to Len(aNFRet)				
				If aNFRet[nIt][1] == (cAliasSD2)->(D2_DOC) .AND. aNFRet[nIt][2] == (cAliasSD2)->(D2_SERIE) .AND.;
				   aNFRet[nIt][3] == (cAliasSD2)->(D2_CLIENTE) .AND. aNFRet[nIt][4] == (cAliasSD2)->(D2_LOJA) .AND.;
				   aNFRet[nIt][5] == (cAliasSD2)->(D2_ITEM)
				   lNFRet := .T.
				   nQtdNF := aNFRet[nIt][6]
				   EXIT								 
				EndIf				
			Next nIt
			
			If !lNFRet
				(cAliasSD2)->(DbSkip())
				LOOP
			EndIf					
		EndIf
					
		cAliasNNC := GetNextAlias() 
	
		cQueryFix := " SELECT SUM( NNC_QTDFIX ) QTDFIX"
		cQueryFix +=   " FROM " + RetSqlName('NNC')+ " NNC "
		cQueryFix +=  " WHERE NNC.D_E_L_E_T_  = '' "
		cQueryFix +=    " AND NNC.NNC_CODCTR  = '" + cCodCtr  + "' "
		cQueryFix +=    " AND NNC.NNC_CODROM  = '" + (cAliasSD2)->( CODROM )  + "' "
		cQueryFix +=    " AND NNC.NNC_ITEROM  = '" + (cAliasSD2)->( ITEROM )  + "' "
		cQueryFix := ChangeQuery(cQueryFix)
		If select("cAliasNNC") <> 0
			(cAliasNNC)->( dbCloseArea() )
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
			nSaldo := (cAliasSD2)->(B6_SALDO)
		ElseIf .NOT. _lCtrlCom 
			nSaldo := (cAliasSD2)->(D2_SALDO) 
		EndIf

		aAdd( aAux, Array( COL_COUNT ) )
		aAux[ Len( aAux ), COL_MARK     ] := "0"
		aAux[ Len( aAux ), COL_DOC      ] := (cAliasSD2)->( D2_DOC   )
		aAux[ Len( aAux ), COL_SERIE    ] := (cAliasSD2)->( D2_SERIE )
		aAux[ Len( aAux ), COL_EMISSAO  ] := DTOC( STOD( (cAliasSD2)->( D2_EMISSAO ) ) )
		aAux[ Len( aAux ), COL_ITEM     ] := (cAliasSD2)->( D2_ITEM  )
		aAux[ Len( aAux ), COL_QUANT    ] := nQtdNF
		aAux[ Len( aAux ), COL_VUNIT    ] := (cAliasSD2)->( D2_PRCVEN )
		aAux[ Len( aAux ), COL_VTOTAL   ] := (cAliasSD2)->( D2_TOTAL )
		aAux[ Len( aAux ), COL_LOTECTL  ] := (cAliasSD2)->( D2_LOTECTL )
		aAux[ Len( aAux ), COL_VAZIO ] := ""
		
		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			aAux[ Len( aAux ), COL_QTDFIX   ] := nQtdFix
			aAux[ Len( aAux ), COL_IDENTB6  ] := (cAliasSD2)->( D2_IDENTB6 )
		EndIf
		
		//--Se não é complemento
		If .NOT. _lCtrlCom
			aAux[ Len( aAux ), COL_SALDO    ] := nSaldo - nQtdFix
			aAux[ Len( aAux ), COL_DISTRIB  ] := 0
			aAux[ Len( aAux ), COL_VDISTR   ] := 0
		EndIf
		
		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			//--Se quantidade de devolução maior que zero E se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
			If nQtdAdl > 0 
				//Se q qtd de devolucao for maior que saldo E se a qtd da nota for maior que a fixacao
				If nQtdAdl >= nSaldo .And. nQtdNF > nQtdFix
					aAux[ Len( aAux ), COL_MARK     ] := "1"
					aAux[ Len( aAux ), COL_DISTRIB  ] := aAux[ Len( aAux ), COL_SALDO ]
					nQtdAdl -= aAux[ Len( aAux ), COL_SALDO ]
					nQtdSel += aAux[ Len( aAux ), COL_SALDO ]
				ElseIf nQtdNF > nQtdFix
					aAux[ Len( aAux ), COL_MARK     ] := "1"
					aAux[ Len( aAux ), COL_DISTRIB  ] := nQtdAdl
					nQtdSel += nQtdAdl
					nQtdAdl := 0
				EndIf
	
				//aAux[ Len( aAux ), COL_VDISTR   ] := Round( aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ], TamSX3( "D1_TOTAL" )[2] ) 
				aAux[ Len( aAux ), COL_VDISTR   ] := A410Arred( aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ], "C6_VALOR" )
			EndIf
		EndIf
		
		If lRetDevol .AND. aAux[Len(aAux), COL_MARK] == "1"	
			DbSelectArea("N9E")
			N9E->(DbSetOrder(4)) // N9E_FILIAL+N9E_CODROM+N9E_DOC+N9E_SERIE+N9E_CLIFOR+N9E_LOJA+N9E_ITEDOC
			If N9E->(DbSeek(FWxFilial("N9E")+cRomaneio+(cAliasSD2)->(D2_DOC)+(cAliasSD2)->(D2_SERIE)+(cAliasSD2)->(D2_CLIENTE)+(cAliasSD2)->(D2_LOJA)+(cAliasSD2)->(D2_ITEM))) 
			    If RecLock("N9E", .F.)
			   	   N9E->N9E_STARET := '1' // Relacionada a NF de Retorno
			   	   N9E->(MsUnlock())
			    EndIf
			EndIf
		EndIf
		
		(cAliasSD2)->( dbSkip() )
	EndDo
	(cAliasSD2)->( dbCloseArea() )

	IF !lExport .AND. !lRetDevol
	
		oSize := FwDefSize():New()
		oSize:AddObject( "P1", 100, 80, .t., .t., .t. )
		oSize:AddObject( "P2", 100, 20, .t., .t., .t. )
		oSize:lProp     := .t.
		oSize:aMargins  := { 3, 3, 3, 3 }
		oSize:Process()
	
		oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], "Seleção de Romaneios para Complementar",,,,,CLR_BLACK,CLR_WHITE,,,.t.)
	
		oPnUm   := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" ),oSize:GetDimension( "P1", "YSIZE" ) )
		oPnDois := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ),oSize:GetDimension( "P2", "YSIZE" ) )
	
		oBrowse := TCBrowse():New( 01, 01, 250, 150, , , , oPnUm, , , , , , , , , , , , .f., ,.t., , .f. )
		
		oBrowse:AddColumn( TCColumn():New( " " 		, { || IIf( aAux[oBrowse:nAt, COL_MARK 	] == "1", oStX, oStO ) }        ,,,,"CENTER"    , 020,.t.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( STR0028	, { || aAux[ oBrowse:nAt, COL_SERIE     ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Serie"
		oBrowse:AddColumn( TCColumn():New( STR0029  , { || aAux[ oBrowse:nAt, COL_DOC       ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Numero"
		oBrowse:AddColumn( TCColumn():New( STR0030  , { || aAux[ oBrowse:nAt, COL_EMISSAO   ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Emissao"
		oBrowse:AddColumn( TCColumn():New( STR0031  , { || aAux[ oBrowse:nAt, COL_ITEM      ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Item"
		
		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			oBrowse:AddColumn( TCColumn():New( STR0032	, { || aAux[ oBrowse:nAt, COL_IDENTB6 ] }                           ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Ident"
		EndIf
		
		oBrowse:AddColumn( TCColumn():New( STR0033	, { || aAux[ oBrowse:nAt, COL_LOTECTL   		] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	//"Lote"
		oBrowse:AddColumn( TCColumn():New( STR0034  , { || Transform( aAux[ oBrowse:nAt, COL_QUANT  ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Quantidade"
		
		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			oBrowse:AddColumn( TCColumn():New( STR0035	, { || Transform( aAux[ oBrowse:nAt, COL_QTDFIX ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Qtd. Fixada"
		EndIf
		
		oBrowse:AddColumn( TCColumn():New( STR0036	, { || Transform( aAux[ oBrowse:nAt, COL_VUNIT  ], "@E 9,999,999.999999" ) }    ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Vlr. Unit."
		oBrowse:AddColumn( TCColumn():New( STR0037  , { || Transform( aAux[ oBrowse:nAt, COL_VTOTAL ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Vlr. Total"
		
		//--Se não for contrato de complemento apresenta a coluna
		If .NOT. _lCtrlCom	
			oBrowse:AddColumn( TCColumn():New( STR0038	, { || Transform( aAux[ oBrowse:nAt, COL_SALDO   ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Saldo"
			oBrowse:AddColumn( TCColumn():New( STR0039	, { || Transform( aAux[ oBrowse:nAt, COL_DISTRIB ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Distribuido"
			oBrowse:AddColumn( TCColumn():New( STR0040  , { || Transform( aAux[ oBrowse:nAt, COL_VDISTR  ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )	//"Valor Distr."
		EndIF
		
		oBrowse:AddColumn( TCColumn():New( " " 			, { || aAux[ oBrowse:nAt, COL_VAZIO              ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )	
		oBrowse:SetArray( aAux )
		oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
		oBrowse:bLDblClick	:= {|| MarcaUm( aAux, oBrowse:nAt ) }
	
		//--Se não for complemento
		If .NOT. _lCtrlCom	
			oFont   := TFont():New( "Courier new", , -16, .t. )
			oSay    := TSay():New( 01, 01, {|| RetTexto( aAux, nQtdDev ) }, oPnDois, , oFont, , , , .t., CLR_RED, CLR_WHITE, 200, 20 )
			oSay:Align := CONTROL_ALIGN_ALLCLIENT
		EndIf
	
		//--Se for devolução de terceiro ou devolução quantidade tipos 7 ou 9
		If _lCtrlTer .OR. _lCtrlDev
			bValida := {|| nQtdDev = nQtdSel }
		EndIf
	
		//--Se for devolução valor
		If _lCtrlDVl
			bValida := {|| .T. }		
		EndIf	 
	
		//--Se for complemento
		If _lCtrlCom
			bValida := {|| .T. }
		EndIf	
		
		oDlg:Activate( , , , .t., bValida, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() },, @aButtons ) } )
	EndIf
	
	If nOpcao = 1 .Or. lExport .Or. lRetDevol     
		For nY := 1 to Len( aAux )          
			If aAux[ nY, COL_MARK ] = "1"               
				aAdd( aRetorno, aAux[ nY ] )                
			EndIf
		Next nY     
	EndIf
	
	RestArea( aAreaAtu )
Return( aRetorno )


/** {Protheus.doc} MarcaUm
* Função de marcação 
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
				aItsMrk[ nLinMrk, COL_VDISTR    ] := Round( aItsMrk[ nLinMrk, COL_DISTRIB ] * aItsMrk[ nLinMrk, COL_VUNIT ], TamSX3( "D1_TOTAL" )[2] )
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


/** {Protheus.doc} RetTexto()
*/
Static Function RetTexto( aItsMrk, nQtdDev )
	Local cTexto 	:= ""
	Local nX        := 0

	nQtdSel	:= 0

	For nX := 1 to Len( aItsMrk )

		If aItsMrk[ nX, COL_MARK ] = "1"
			nQtdSel += aItsMrk[ nX, COL_DISTRIB ]
		EndIf

	Next nX

	cTexto += STR0041 + Transform( nQtdDev, "@E 999,999,999.99" )	//"Quantidade da Devolução: "
	cTexto += Chr( 13 ) + Chr( 10 )
	cTexto += STR0042 + Transform( nQtdSel, "@E 999,999,999.99" )	//"Quantidade Selecionada : "
Return( cTexto )


/** {Protheus.doc} EditQtd
Funcao para alterar a quantidade parcial a ser devolvida

@param:     Nil
@author:    Fernando Pereira 
@since:     14/06/2013
@Uso:       OGX009
*/
Static Function EditQtd()
	Local   nOpcao      := 0
	Local   oDlg        := Nil
	Local   lMark       := oBrowse:aArray[ oBrowse:nAt, COL_MARK    ] = "1"
	Local   nQtdAnt :=  oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ]
	Local   nQtdSal :=  oBrowse:aArray[ oBrowse:nAt, COL_SALDO  ]
	Private nQtdNew :=  oBrowse:aArray[ oBrowse:nAt, COL_DISTRIB    ]

	If lMark
		Define MsDialog oDlg Title STR0043 From 9,0 to 20,50 Of oMainWnd	//"Alterar - Quantidade"
		@ 030,015 Say OemToAnsi(STR0044) Of oDlg Pixel	//"Quantidade: "
		@ 030,065 MsGet nQtdNew  Valid nQtdNew >= 0 .And. nQtdNew <= nQtdSal Picture("@E 999,999,999,999") Size 070, 010  Of oDlg Pixel
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
	
	//Inicializa o campo com o valor maximo
	If nValNew == 0 
		nValNew := oBrowse:aArray[ oBrowse:nAt, COL_SALDO ] *  oBrowse:aArray[ oBrowse:nAt, COL_VUNIT ]
	EndIf

	If lMark
		Define MsDialog oDlg Title STR0045 From 9,0 to 20,50 Of oMainWnd	//"Alterar - Valor" 
		@ 030,015 Say OemToAnsi(STR0046) Of oDlg Pixel	//"Valor: "
		@ 030,065 MsGet nValNew  Valid nValNew < nValNfs Picture("@E 999,999,999.99") Size 070, 010  Of oDlg Pixel
		Activate MsDialog oDlg Centered On Init EnchoiceBar(oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() })
		If nOpcao == 1
			If  nValNew = 0
				oBrowse:aArray[ oBrowse:nAt, COL_MARK   ] := "0"
				oBrowse:aArray[ oBrowse:nAt, COL_VDISTR ] := 0
			Else
				If oBrowse:aArray[ oBrowse:nAt, COL_VDISTR ] <= ( oBrowse:aArray[ oBrowse:nAt, COL_SALDO ] *  oBrowse:aArray[ oBrowse:nAt, COL_VUNIT ]  )
					oBrowse:aArray[ oBrowse:nAt, COL_VDISTR ] := nValNew
				EndIf
			EndIf

			nValSel :=  nValSel + ( nValAnt - nValNew )
			//nQtdSel :=  nQtdSel + ( nValAnt - nValNew )
			oSay:Refresh()
			oBrowse:Refresh()
		EndIf
	EndIf
Return( Nil )


/*/{Protheus.doc} RetParams
//Retorna a especie do parametro MV_ESPECIE relacionada com a serie informada
@author carlos.augusto
@since 08/08/2018
@version 12.1.22
@param cDocSer serie da tela
@link http://tdn.totvs.com/pages/releaseview.action?pageId=225267033
@type function
/*/
Static Function RetParams(cDocSer)
	Local cEspecie	:= SuperGetMv("MV_ESPECIE", .T., "")
	Local aParams	:= StrTokArr(cEspecie, ";" )
	Local cEspSerie := ""
	Local nX
	
	If .Not. Empty(cEspecie)
		For nX := 1 To len(aParams)
			If(cDocSer = StrTokArr(aParams[nX], "=" )[1])
				cEspSerie := StrTokArr(aParams[nX], "=" )[2]
				exit
			EndIf
		Next nX
	EndIf
	
Return cEspSerie


/** {Protheus.doc} SelNfsDev
Função auxiliar para seleção de documentos de origem para amarracao na NF de devolução.

@param: Nil
@author:    Equipe Agroindustria
@since:     08/06/2010
@Uso:       OGX009
*/
Static Function SelNfsDev( cCodCtr, nQtdDev, cProduto, cLoteCtl )
	Local aRetorno      := {}
	Local aAreaAtu      := GetArea()
	Local oSize         := Nil
	Local oDlg          := Nil
	Local oPnUm         := Nil
	Local oPnDois       := Nil
	Local oFont         := Nil
	Local oStO          := LoadBitmap( GetResources(), "unchecked" )
	Local oStX          := LoadBitmap( GetResources(), "checked" )
	Local aButtons      := {}
	Local aAux          := {}
	Local nOpcao        := 0
	Local nY            := 0
	Local cQueryFix     := ""
	Local lCtrlN8K		:= GetRPORelease() >= '12.1.023'
	Local cAliasSD2 	:= GetNextAlias()
	Local cQuerySD2		:= ""
	Local cFiltro		:= ""
	Local cOrder		:= "" 
	Local nSaldo        := 0	
	Local aRetPe		:= {}

	Private oBrowse     := Nil
	Private oSay        := Nil
	Private nQtdAdl     := nQtdDev
	Private nQtdSel     := 0
	Private nValSel     := 0

	Private cAliasNNC   := ''

	aAdd( aButtons, { "", {|| EditQtd() }, OemToAnsi( "Editar" ) } )

	cQuerySD2 += " SELECT SD2.D2_DOC,    SD2.D2_SERIE,  SD2.D2_EMISSAO,  	"
	cQuerySD2 +=        " SD2.D2_ITEM,   SD2.D2_QUANT,  SD2.D2_PRCVEN,    	"
	cQuerySD2 +=        " SD2.D2_TOTAL, ( SD2.D2_QUANT - SD2.D2_QTDEDEV ) AS D2_SALDO,	"
	cQuerySD2 +=        " SD2.D2_IDENTB6, SD2.D2_LOTECTL "

	If lCtrlN8K
		cQuerySD2 += " ,N8K.N8K_CODROM AS CODROM, N8K.N8K_ITEROM AS ITEROM "
	Else 
		cQuerySD2 += " , SD2.D2_CTROG, SD2.D2_CODROM AS CODROM, SD2.D2_ITEROM AS ITEROM"
	EndIF 
	//--Para devoluç?o com terceiros verificar a tabela SB6
	IF _lCtrlTer
		cQuerySD2 += ", SB6.B6_SALDO " 
	EndIF
	cQuerySD2 += " FROM " + RetSqlName('SD2')+ " SD2 " 
	
	If lCtrlN8K
		cQuerySD2 += " INNER JOIN " +  RetSqlName('N8K')+ " N8K " 
		cQuerySD2 +=         " ON N8K.D_E_L_E_T_ 	= '' "
		cQuerySD2 +=        " AND N8K.N8K_FILIAL 	= SD2.D2_FILIAL "
		cQuerySD2 +=        " AND N8K.N8K_DOC		= SD2.D2_DOC 	"
		cQuerySD2 +=        " AND N8K.N8K_SERIE		= SD2.D2_SERIE 	"
		cQuerySD2 +=        " AND N8K.N8K_ITEDOC	= SD2.D2_ITEM	"	
		cQuerySD2 +=        " AND N8K.N8K_CLIFOR	= SD2.D2_CLIENTE"
		cQuerySD2 +=        " AND N8K.N8K_LOJA		= SD2.D2_LOJA 	"
		cQuerySD2 +=        " AND N8K.N8K_PRODUT	= SD2.D2_COD	"	
		cQuerySD2 +=        " AND N8K.N8K_CODCTR	= '"+ cCodCtr +"'"
	EndIf 	
	//--Para devoluç?o com terceiros verificar a tabela SB6
	IF _lCtrlTer
		cQuerySD2 += " INNER JOIN " + RetSqlName('SB6')+ " SB6 "
		cQuerySD2 +=         " ON SB6.D_E_L_E_T_  = '' "
		cQuerySD2 +=        " AND SB6.B6_FILIAL  = SD2.D2_FILIAL "
		cQuerySD2 +=        " AND SB6.B6_IDENT   = SD2.D2_IDENTB6 "
		cQuerySD2 +=        " AND SB6.B6_SALDO   > 0 "
	EndIf 	

	cFiltro += " WHERE SD2.D_E_L_E_T_ = '' "
	cFiltro += " AND SD2.D2_FILIAL  = '"+ FWxFilial("SD2") +"'"
	
	IF !lCtrlN8K
		cFiltro += " AND SD2.D2_CTROG = '"+ cCodCtr +"'"
	EndIF
	
	cFiltro += " AND SD2.D2_COD = '" + cProduto + "' "
	cFiltro += " AND ( SD2.D2_QUANT - SD2.D2_QTDEDEV ) > 0 "
	cFiltro += " AND SD2.D2_LOTECTL = '"+ cLoteCtl +"'"
	cOrder += " ORDER BY SD2.D2_EMISSAO, SD2.D2_SERIE, SD2.D2_DOC "
	
	If EXISTBLOCK ("OG009SLNF") 
		aRetPe := ExecBlock("OG009SLNF",.F.,.F.,{cQuerySD2, cFiltro, cOrder})
		
		If Len(aRetPe) == 3 .And.( ValType(aRetPe[1]) == "C" .And. ValType(aRetPe[2]) == "C" .And. ValType(aRetPe[3]) == "C")
			cQuerySD2 := aRetPe[1]
			cFiltro   := aRetPe[2]
			cOrder	  := aRetPe[3]
			
			_lPEQry := .T.
		EndIf
	EndIf
	
	cQuerySD2 := cQuerySD2 + cFiltro + cOrder
	
	cQuerySD2 := ChangeQuery(cQuerySD2)
//	If Select("cAliasSD2") <> 0
//		(cAliasSD2)->( dbCloseArea() )
//	EndIf
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuerySD2),cAliasSD2,.F.,.T.)

	DbSelectArea( (cAliasSD2) )  
	(cAliasSD2)->( dbGoTop() )

	If (cAliasSD2)->( Eof() )
	   (cAliasSD2)->( dbCloseArea() )
	    Help( , ,"Aviso", , "Não foram encontrados romaneios para a entidade informada neste romaneio.", 1, 0 )
		RestArea( aAreaAtu )
		lNFOrigem := .F.
		Return( aRetorno )
	EndIf

	cAliasNNC := GetNextAlias() 
	If select(cAliasNNC) > 0
		(cAliasNNC)->( dbCloseArea() )
	EndIf

	While .Not. (cAliasSD2)->( Eof() )

		//--Se controla terceiro utiliza saldo da SB6->B6_SALDO
		If _lCtrlTer
			nSaldo := (cAliasSD2)->(B6_SALDO)
		ElseIf .NOT. _lCtrlCom 
			nSaldo := (cAliasSD2)->(D2_SALDO) 
		EndIf
		
		cQueryFix := " SELECT SUM( NNC_QTDFIX ) QTDFIX"
		cQueryFix +=   " FROM " + RetSqlName('NNC')+ " NNC "
		cQueryFix +=  " WHERE NNC.D_E_L_E_T_  = '' "
		cQueryFix +=    " AND NNC.NNC_CODCTR  = '" + cCodCtr  + "' "
		cQueryFix +=    " AND NNC.NNC_CODROM  = '" + (cAliasSD2)->( CODROM )  + "' "
		cQueryFix +=    " AND NNC.NNC_ITEROM  = '" + (cAliasSD2)->( ITEROM )  + "' "
		
		cQueryFix := ChangeQuery(cQueryFix)
	
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryFix),cAliasNNC,.T.,.T.)

		DbSelectArea( cAliasNNC )  
		(cAliasNNC)->( dbGoTop() )
		If .Not. (cAliasNNC)->( Eof() )
			//Valor da fixação
			nQtdFix := (cAliasNNC)->QTDFIX
		EndIF 
		(cAliasNNC)->( dbCloseArea() )

		aAdd( aAux, Array( COL_COUNT ) )
		aAux[ Len( aAux ), COL_MARK     ] := "0"
		aAux[ Len( aAux ), COL_DOC      ] := (cAliasSD2)->( D2_DOC   )
		aAux[ Len( aAux ), COL_SERIE    ] := (cAliasSD2)->( D2_SERIE )
		aAux[ Len( aAux ), COL_EMISSAO  ] := DTOC( STOD( (cAliasSD2)->( D2_EMISSAO ) ) )
		aAux[ Len( aAux ), COL_ITEM     ] := (cAliasSD2)->( D2_ITEM  )
		aAux[ Len( aAux ), COL_QUANT    ] := (cAliasSD2)->( D2_QUANT )
		aAux[ Len( aAux ), COL_QTDFIX   ] := nQtdFix
		aAux[ Len( aAux ), COL_VUNIT    ] := (cAliasSD2)->( D2_PRCVEN )
		aAux[ Len( aAux ), COL_VTOTAL   ] := (cAliasSD2)->( D2_TOTAL )
		aAux[ Len( aAux ), COL_SALDO    ] := nSaldo - nQtdFix
		aAux[ Len( aAux ), COL_DISTRIB  ] := 0
		aAux[ Len( aAux ), COL_VDISTR   ] := 0
		aAux[ Len( aAux ), COL_IDENTB6  ] := (cAliasSD2)->( D2_IDENTB6 )
		aAux[ Len( aAux ), COL_LOTECTL  ] := (cAliasSD2)->( D2_LOTECTL )

		If nQtdAdl > 0
			//Se q qtd de devolucao for maior que saldo E se a qtd da nota for maior que a fixacao
			If nQtdAdl >= (cAliasSD2)->( D2_SALDO ) .And. (cAliasSD2)->( D2_QUANT ) > nQtdFix
				aAux[ Len( aAux ), COL_MARK     ] := "1"
				aAux[ Len( aAux ), COL_DISTRIB  ] := aAux[ Len( aAux ), COL_SALDO ]
				nQtdAdl -= aAux[ Len( aAux ), COL_SALDO ]
				nQtdSel += aAux[ Len( aAux ), COL_SALDO ]
			ElseIf (cAliasSD2)->( D2_QUANT ) > nQtdFix
				aAux[ Len( aAux ), COL_MARK     ] := "1"
				aAux[ Len( aAux ), COL_DISTRIB  ] := nQtdAdl
				nQtdSel += nQtdAdl
				nQtdAdl := 0
			EndIf

			//aAux[ Len( aAux ), COL_VDISTR   ] := Round( aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ], TamSX3( "D1_TOTAL" )[2] ) 
			aAux[ Len( aAux ), COL_VDISTR   ] := A410Arred( aAux[ Len( aAux ), COL_DISTRIB ] * aAux[ Len( aAux ), COL_VUNIT ], "C6_VALOR" )
		EndIf
		aAux[ Len( aAux ), COL_VAZIO ] := ""

		(cAliasSD2)->( dbSkip() )
	EndDo
	(cAliasSD2)->( dbCloseArea() )

	oSize := FwDefSize():New()
	oSize:AddObject( "P1", 100, 80, .t., .t., .t. )
	oSize:AddObject( "P2", 100, 20, .t., .t., .t. )
	oSize:lProp     := .t.
	oSize:aMargins  := { 3, 3, 3, 3 }
	oSize:Process()
	If ! IsBlind()	
		oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], "Seleção de Romaneios para Devolução",,,,,CLR_BLACK,CLR_WHITE,,,.t.)

		oPnUm   := tPanel():New( oSize:GetDimension( "P1", "LININI" ), oSize:GetDimension( "P1", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P1", "XSIZE" ),oSize:GetDimension( "P1", "YSIZE" ) )
		oPnDois := tPanel():New( oSize:GetDimension( "P2", "LININI" ), oSize:GetDimension( "P2", "COLINI" ), "", oDlg,,,,CLR_BLACK,CLR_WHITE,oSize:GetDimension( "P2", "XSIZE" ),oSize:GetDimension( "P2", "YSIZE" ) )
	
		oBrowse := TCBrowse():New( 01, 01, 260, 156, , , , oPnUm, , , , , , , , , , , , .f., ,.t., , .f. )
	
		oBrowse:AddColumn( TCColumn():New( ""               , { || IIf( aAux[oBrowse:nAt, COL_MARK                  ] == "1", oStX, oStO ) }        ,,,,"CENTER"    , 040,.t.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Serie"          , { || aAux[ oBrowse:nAt, COL_SERIE                     ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Numero"         , { || aAux[ oBrowse:nAt, COL_DOC                       ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Emissao"        , { || aAux[ oBrowse:nAt, COL_EMISSAO                   ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Item"           , { || aAux[ oBrowse:nAt, COL_ITEM                      ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Ident"          , { || aAux[ oBrowse:nAt, COL_IDENTB6                   ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Lote"           , { || aAux[ oBrowse:nAt, COL_LOTECTL                   ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Quantidade"     , { || Transform( aAux[ oBrowse:nAt, COL_QUANT          ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Qtd. Fixada"    , { || Transform( aAux[ oBrowse:nAt, COL_QTDFIX         ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Vlr. Unit."     , { || Transform( aAux[ oBrowse:nAt, COL_VUNIT          ], PesqPict("SC6","C6_PRCVEN") ) }    ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Vlr. Total"     , { || Transform( aAux[ oBrowse:nAt, COL_VTOTAL         ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Saldo"          , { || Transform( aAux[ oBrowse:nAt, COL_SALDO          ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Distribuido"    , { || Transform( aAux[ oBrowse:nAt, COL_DISTRIB        ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( "Valor Distr."   , { || Transform( aAux[ oBrowse:nAt, COL_VDISTR         ], "@E 999,999,999,999.99" ) }  ,,,,"RIGHT"     ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:AddColumn( TCColumn():New( " "              , { || aAux[ oBrowse:nAt, COL_VAZIO                     ] }                             ,,,,"LEFT"      ,    ,.f.,.t.,,,,.f.,) )
		oBrowse:SetArray( aAux )
		oBrowse:Align       := CONTROL_ALIGN_ALLCLIENT
		oBrowse:bLDblClick  := {|| MarcaUm( aAux, oBrowse:nAt, nQtdDev ) }
	
		oFont   := TFont():New( "Courier new", , -16, .t. )
		oSay    := TSay():New( 01, 01, {|| RetTexto( aAux, nQtdDev ) }, oPnDois, , oFont, , , , .t., CLR_RED, CLR_WHITE, 200, 20 )
		oSay:Align := CONTROL_ALIGN_ALLCLIENT

		oDlg:Activate( , , , .t., {|| nQtdDev = nQtdSel }, , { || EnchoiceBar( oDlg, {|| nOpcao := 1, oDlg:End() },{|| nOpcao := 0, oDlg:End() },, @aButtons ) } )
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

/*/{Protheus.doc} OGX009CPL
Gerar NF de Complemento de preço para contrato de compra com base em um romaneio de origem e grava as tabelas de relacionamento
@type function
@version  P12.1.33
@author claudineia.reinert
@since 01/02/2022
@param cFilRom, character, Filial do romaneio de origem
@param cCodRom, character, Codigo do romaneio de origem
@param cItemRom, character, Item NJM do romaneio de origem
@param cSerieNFC, character, Serie do romaneio de origem
@param cTipo, character, Tipo da Nf de complemento - 1=preço
@param nValor, numeric, Valor para o complemento
@param aItensNKC, array, array com os dados da NKC. OBs: não aterar a ordem dos campos sem ajustar o OGA450
@return array, sendo: 	posição 1: logical - .T. se tudo ocorreu bem ou .F. se ocorreu erro.
						posição 2: character - conteudo do erro gerado se gerou erro no processo.
						posição 3: character - numero da NF de complemento.
						posição 4: character - serie da Nf de complemento.
/*/
Function OGX009CPL( cFilRom as char, cCodRom as char, cItemRom as char, cSerieNFC as char, cTipo as char, nValor as numeric, aItensNKC as array)
	Local cMsgErr 		:= ""
	Local cNfOri 		:= ""
	Local cSeriori 		:= ""
	Local cItemOri 		:= ""
	Local cNatFin 		:= ""
	Local cFornece 		:= ""
	Local cLojafor 		:= ""
	Local cE2PrefOri 	:= ""
	Local cE2NumOri  	:= ""
	Local cCCusto  		:= ""
	Local cNumeroNFC  	:= CriaVar("F1_DOC",.f.)
	Local cModAtu       := cModulo
	Local nModAtu       := nModulo
	Local cFiltemp      := cFilAnt
	Local cNumNFC 		:= ""
	Local cSerNFC 		:= ""
	Local nX 			:= 0
	Local lRet  		:= .T.
	Local aCab			:= {}
	Local aLinha		:= {}
	Local aItens		:= {}
	Local aAreaAtu		:= GetArea()
	Local aAreaNJM 		:= NJM->(GetArea())
	Local aAreaNJ0 		:= NJ0->(GetArea())
	Local aAreaSF1 		:= SF1->(GetArea())
	Local aAreaSE2		:= SE2->(GetArea())

	Private lMsErroAuto := .f. 		//necessario a criacao, pois sera

	If Len(aItensNKC) <= 0 .or. Empty(aItensNKC)  //é obrigatorio
		cMsgErr := STR0050 + ProcName()
		Return {.F., cMsgErr}
	EndIf

	//posiciona no registro do romaneio enviado
	DbSelectArea("NJM")
	NJM->(DbSetOrder(1)) //NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	If !(NJM->(DbSeek(cFilRom + cCodRom + cItemRom)))
		cMsgErr := STR0049 //##"Romaneio de origem não encontrado." 
		Return {.F., cMsgErr}
	EndIf

	//Loga na filial do romaneio
	cFilAnt := cFilRom

	//Carrega os dados da nota de origem
	cNfOri		:= NJM->NJM_DOCNUM
	cSeriori	:= NJM->NJM_DOCSER
	cItemOri	:= Soma1(Strzero(0, TamSX3("D1_ITEMORI")[1]))
	
	//-- Buscando o Fornecedor no Cadastro de Entidade --//
	cFornece	:= Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),	"NJ0_CODFOR"	)	// Cod Forn. Origem
	cLojafor	:= Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),	"NJ0_LOJFOR"	)	// Loja Forn. Orige
		
	//--Encontrando o prefixo do tit. da nf. original idx 1= F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	cE2PrefOri	:= Posicione("SF1",1,FwxFilial("SF1") + cNfOri + cSeriOri + cFornece + cLojaFor + 'N',	"F1_PREFIXO"	)	// Retorna o Prefixo do Tit. Original
	cE2NumOri	:= Posicione("SF1",1,FwxFilial("SF1") + cNfOri + cSeriOri + cFornece + cLojaFor + 'N',	"F1_DUPL"	)	// Retorna o Prefixo do Tit. Original

	DbSelectArea("SE2")
	SE2->(DbSetOrder(6)) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO  
	If SE2->(DbSeek( FwxFilial("SE2") + cFornece + cLojaFor + cE2PrefOri + cE2NumOri ))
		cNatFin := SE2->E2_NATUREZ
		cCCusto	:= SE2->E2_CCD
	EndIf

	If ! Len(cSerieNFC) = TamSx3('F1_SERIE')[1]
		cSerieNFC := PadR(Alltrim(cSerieNFC),TamSx3('F1_SERIE')[1] )
	EndIf	

	If SuperGetMV("MV_TPNRNFS",.F. ,"1") $ "1" .and. Empty(cNumeroNFC)  
		cNumeroNFC := NxtSX5Nota(cSerieNFC)
	EndIf

	//-- Monta o cabecalho --//
	aAdd( aCab, { "F1_TIPO"		, "C"	 				} ) //complemento
	aAdd( aCab, { "F1_TPCOMPL"	, "1"					} ) //1=Preco; 2=Quantidade; 3=Frete
	aAdd( aCab, { "F1_FORMUL"	, "S"					} ) // formulario proprio sim
	aAdd( aCab, { "F1_SERIE"  	, cSerieNFC				} )
	aAdd( aCab, { "F1_DOC"		, cNumeroNFC			} )
	aAdd( aCab, { "F1_EMISSAO"	, dDataBase				} )
	aAdd( aCab, { "F1_FORNECE"	, cFornece				} )
	aAdd( aCab, { "F1_LOJA"		, cLojafor				} )
	aAdd( aCab, { "F1_ESPECIE"	, "SPED"				} )
	aAdd( aCab, { "F1_CODROM"	, NJM->NJM_CODROM		} )
	aAdd( aCab, { "F1_COND"		, NJM->NJM_CONDPG		} )
		
	IF !Empty( cNatFin )
		aAdd( aCab, { "F1_NATUREZ"	, cNatFin			} )
	ENDif

	//-- ATENÇÃO: Para Nfs. de compl. n. devo informar o Vr. Unitario e nem a Qtidade. --//
	aLinha := {}
	aAdd( aLinha, { "D1_COD"	,	NJM->NJM_CODPRO	,	Nil } )
	aAdd( aLinha, { "D1_DOC"    ,   cNumeroNFC      ,   Nil } )
	aAdd( aLinha, { "D1_VUNIT",		nValor			, 	Nil } )
	aAdd( aLinha, { "D1_TOTAL"	, 	nValor			,	Nil } )
	aAdd( aLinha, { "D1_LOCAL"	,	NJM->NJM_LOCAL	,	Nil } )
	aAdd( aLinha, { "D1_TES"	,	NJM->NJM_TES	,	Nil } )
	aAdd( aLinha, { "D1_CODSAF"	, 	NJM->NJM_CODSAF	,	Nil } )
	aAdd( aLinha, { "D1_CTROG"	, 	NJM->NJM_CODCTR	,	Nil } )
	aAdd( aLinha, { "D1_CODROM"	, 	NJM->NJM_CODROM	,	Nil } )
	aAdd( aLinha, { "D1_ITEROM"	, 	NJM->NJM_ITEROM	,	Nil } )
	aAdd( aLinha, { "D1_CC"		,   cCCusto			,	Nil } )
	//-- Por se Tratar de Nf. de Compl. Preço é Preciso Informar os Dados do docto de Origem Abaixo --//
	aAdd( aLinha, { "D1_NFORI"	, 	cNfOri			,	Nil } )
	aAdd( aLinha, { "D1_SERIORI",	cSeriOri		,	Nil } )	
	aAdd( aItens, aLinha )

	aCab   := FWVetByDic(aCab, 'SF1')
	aItens := FWVetByDic(aItens, 'SD1',.T.)

	/* Necessitamos solicitar o modulo pois alguns campos como LOTE e DTLOTE
		não estao setados para trabalhar com o SIGAAGR */
	cModulo := "COM"
	nModulo := 2

	//-- Gerando  a NF. de Complemento de Preço --//
	MSExecAuto( { | x, y, z | Mata103( x, y, z ) }, aCab, aItens, 3 )

	//Retornando o modulo do SIGAAGR
	cModulo := cModAtu
	nModulo := nModAtu

	If lMsErroAuto
		MostraErro() 
		lRet := .F.
	Else
		lRet := .T.
		cNumNFC := SF1->F1_DOC
		cSerNFC := SF1->F1_SERIE
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
					NKC->NKC_SERIE	:= cSerNFC          //7
					NKC->NKC_DOCTO	:= cNumNFC          //8
					NKC->NKC_PREFIX	:= "NFC"            //9
					NKC->NKC_FORMUL	:= "S"              //10
					NKC->NKC_QTD	:= aItensNKC[nX][11][2] //11
					NKC->NKC_VRUN	:= aItensNKC[nX][12][2] //12
					NKC->NKC_VRTOT	:= aItensNKC[nX][13][2] //13
					NKC->NKC_VRIMP  := aItensNKC[nX][14][2] //14
					NKC->NKC_DATA	:= dDataBase        //15
					NKC->NKC_TPDOC	:= "1"              //16 // 1=Nf. Entrada Compl.Prc;2=Nf. Saida Compl.Prc;
					NKC->NKC_FORCLI := cFornece         //18
					NKC->NKC_LOJA   := cLojaFor	        //19
					NKC->( MsUnLock() )
				EndIf
			Next
		EndIf
	Endif

	//retorna a filial logada originalmente
	cFilAnt := cFiltemp

	RestArea( aAreaNJM )
	RestArea( aAreaNJ0 )
	RestArea( aAreaSF1 )
	RestArea( aAreaSE2 )
	RestArea( aAreaAtu )

Return {lRet, cMsgErr,cNumNFC,cSerNFC}
