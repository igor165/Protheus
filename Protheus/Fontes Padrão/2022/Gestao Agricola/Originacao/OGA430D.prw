#include 'protheus.ch'
#include 'parmtype.ch'
#include 'OGA430D.ch'

/*{Protheus.doc} OGA430D
Função Responsavel por ajustar os Titulos do financeiro que Possuem fixação a menor.
A Forma de Ajustes será inserir um Decrescimo no titulo.

@author Emerson Coelho
@since 22/06/2016
@version 1.0
@param   oMrkNNC	->  Bowse de Rom. a Ajustar  	( Como Referencia )
		 nTitAjsto	-> Numero de Titulos Ajustados  ( Como Referencia )
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references) -> OMrkNNC, ntitAjsto
*/
Function OGA430D( cFiltroNNC, nTitAjstdo, cShowMens )
	Local aTitAjstdo 	:={}
	Local cEOL     		:= Chr(13)+Chr(10) //--End of Line--//
	Local nX			:= 0

	CursorWait()
	cShowMens := ''

	Processa({|| aTitAjstdo:=fAjuFinA( cFiltroNNC )},OemToAnsi( STR0001 ) ) 		//#'Ajuste Financeiro sendo processado'

	//-- Identificando se Foi efetuado algum Ajuste Financeiro nos tits. do romaneio --//
	nTitAjstdo := 0 
	IF len(aTitAjstdo) > 0
	    nTitAjstdo := Len( aTitAjstdo ) 
		cShowMens := STR0002  + cEOL //#'Foram Ajustados os Seguintes Titulos'
		for nX := 1 to Len(aTitAjstdo) Step 1
			cShowMens+= STR0003  + aTitAjstdo[nX,1] + "	" + STR0004 + aTitAjstdo[nX,2] + "	" + STR0005 + cValToChar( aTitAjstdo[nX,3] ) + cEOL //#Roman.:$"Titulo:"#"Valor:
		nExt nX
	ELSE
		cShowMens := "Nenhum Titulo foi Ajustado"	//#"Nenhuma NF. de Complemento Gerada."
	EndIF

	CursorArrow()
Return()

/*{Protheus.doc} fAjuFinA
Função para ajuste financeiro

@author 	Emerson
@since 		22/06/2016
@version 	1.0
*/
Static Function fAjuFinA( cFiltro )
	Local aAreaAtu	:= GetArea()
	Local aAreaNNC  := NNC->( GetArea() )
	Local aAreaSE1  := SE1->( GetArea()	)
	Local aAreaNJR	:= NJR->( GetArea() )
	Local aAreaNJ0  := NJ0->( GetArea() )
	Local aAreaAux

	Local cShowMens  	:= ''
	Local cEOL     		:= Chr(13)+Chr(10) //--End of Line--//
	Local cMensErro			:= ''

	Local aTitProces 	:= {} //-1 = Romaneio + Item , 2= Nf.Nr + Serie , 3=Valor
	Local cSavFiltro	:= NNC->( dbfilter() )	

	Local nVrAjuFin		:= 0
	Local lContinua		:= .t.

	Local cCliFor		:= ""
	Local cLoja			:= ""

	Local cPrefixTit	:= Criavar('E1_PREFIXO',.F.)
	Local cTitNum		:= Criavar('E1_NUM',	.f.)
	Local cTitParc		:= Criavar('E1_PARCELA',.f.)
	Local lExit         := .F.

	Local aRtPE430D		:= {} //PE
	Local cNumDcto		:= "" 
	Local cSerDcto		:= "" 

	Procregua( 0 )
	
	// -- Filtrando o Arquivo Para Pegar Somentes os Registros Marcados --
	
	NNC->( DBSetFilter ( {|| &cFiltro}, cFiltro) )    // Filtra somente Registros selecionados e da Filial Corrente
	NNC->( dbGoTop() )
	
	IF lContinua
		// Verificando Contrato para Buscar o Cliente e Loja do romaneio
		//Buscando o Contrato
		DbSelectArea( "NJR" )
		DbSetOrder( 1 )
		IF NJR->( DbSeek( FWxFilial( "NJR" )  + NNC->NNC_CODCTR ) )
			//-- Tipo do contrato	-- 1=Compra;2=Venda
			cTipoCtr := NJR->NJR_TIPO		
		
			// Buscando Entidade do Contrato
			DbSelectArea('NJ0')
			NJ0->( DbSetOrder(1)  )  	//NJ0_FILIAL+NJ0_CODENT+NJ0_LOJENT
			IF  .not. NJ0->(DbSeek( FwXfilial('NJ0') +NJR->(NJR_CODENT + NJR_LOJENT ) ) )
				lContinua := .f.
				Help(,,STR0006,,STR0007 + NJR->NJR_CODENT + "/"+ NJR->NJR_LOJENT ,1,0) //#Ajuda#"Entidade ref ao romaneio, não foi encontrada; Entidade : "
			Else
				If cTipoCtr == '2'
					cCliFor	:= NJ0->NJ0_CODCLI
					cLoja	:= NJ0->NJ0_LOJCLI
				ElseIf cTipoCtr == '1'
					cCliFor	:= NJ0->NJ0_CODFOR
					cLoja	:= NJ0->NJ0_LOJFOR				
				EndIf
			EndIf
		Else
			lContinua 	:= .f.
			Help(,,STR0006,,STR0008 + NJR->NJR_CODCTR ,1,0)  //#'Ajuda'#"Contrato ref. ao romaneio, não foi encontrado; Contrato : "
		EndIf
	EndIF

	IF lContinua

		While NNC->( !eof() ) .AND. (!lExit)			
            Incproc( OemToAnsi( STR0009 ) + NNC->NNC_CODROM + '/' + NNC->NNC_ITEROM ) //#"Processando Romaneio: "

			nVrAjuFin:= (NNC->NNC_VRENPF + NNC->NNC_VLCMPL) -  NNC->NNC_VLFIXB

			cNumDcto := NNC->NNC_NUMDOC
			cSerDcto := NNC->NNC_SERDOC
			
			//Ponto de entrada para alteração dos dados na localização das notas de Entrada e/ou Saida.
			If ExistBlock("OGA430D1") 
				aRtPE430D := ExecBlock( "OGA430D1",.F.,.F.,{cNumDcto, cSerDcto, cCliFor, cLoja, NNC->NNC_CODCTR, NNC->NNC_CODROM })
				If ValType(aRtPE430D)=="A" .And. Len(aRtPE430D) > 0 .And. Len(aRtPE430D)== 4
					
					cNumDcto := IIF(Empty(aRtPE430D[1]), NNC->NNC_NUMDOC, aRtPE430D[1] )
					cSerDcto := IIF(Empty(aRtPE430D[2]), NNC->NNC_SERDOC, aRtPE430D[2] )
					cCliFor  := IIF(Empty(aRtPE430D[3]), cCliFor		, aRtPE430D[3] )					
					cLoja    := IIF(Empty(aRtPE430D[4]), cLoja			, aRtPE430D[4] )	
					
				EndIf
			EndIf

			BEGIN TRANSACTION
			lAjusteeOK 	:= .f.
			cMensErro	:=''
			cPrefixTit	:= Criavar('E1_PREFIXO',.F.)
			cTitNum		:= Criavar('E1_NUM',	.f.)
			cTitParc	:= Criavar('E1_PARCELA',.f.)
			
			//-- Tipo do contrato		
			If cTipoCtr == '2'			//-- 2=Venda
				//-- Rotina de recebimento 
				lAjusteOK 	:= fAltTitREC(cNumDcto, cSerDcto, cCliFor, cLoja, nVrAjuFin, @cMensErro, @cPrefixtit, @cTitNum, @cTitParc )
			ElseIf cTipoCtr == '1'		//-- 1=Compra
				//-- Rotina de pagamento
				lAjusteOK 	:= fAltTitCPG(cNumDcto, cSerDcto, cCliFor, cLoja, nVrAjuFin, @cMensErro, @cPrefixtit, @cTitNum, @cTitParc )			
			EndIf 
			
			IF lAjusteOk
				//-- Gravando NKC ---
				Reclock('NKC',.T. )
				NKC->NKC_FILIAL	:= fWxFilial('NKC')
				NKC->NKC_CODCTR	:= NNC->NNC_CODCTR
				NKC->NKC_ITEMFX	:= NNC->NNC_ITEMFX
				NKC->NKC_CODROM	:= NNC->NNC_CODROM
				NKC->NKC_ITEROM	:= NNC->NNC_ITEROM
				NKC->NKC_ITEM	:=  fNextNKCIt( NNC->NNC_CODCTR, NNC->NNC_ITEMFX, NNC->NNC_CODROM, NNC->NNC_ITEROM )
				NKC->NKC_SERIE	:=  ''
				NKC->NKC_DOCTO	:=  ''
				NKC->NKC_PREFIX	:=  ''
				NKC->NKC_FORMUL	:=  ''
				NKC->NKC_QTD	:=  0
				NKC->NKC_VRUN	:= nVrAjuFin
				NKC->NKC_VRTOT	:= nVrAjuFin
				NKC->NKC_VRIMP  := 0
				NKC->NKC_DATA	:= dDatabase
				NKC->NKC_TPDOC	:= '3' 			// Ajuste Financeiro Decrescimo
				NKC->NKC_PEDIDO	:= ''
				NKC->NKC_FORCLI := cCliFor
				NKC->NKC_LOJA   := cLoja				
				NKC->( MsUnLock() )

				// -- Atualiza o Arquivo NNC (Entregas da Fixação)-- //
				aAreaAux := NNC->(GetArea())	//Protegendo Area Atual da Tabela NNC

				Reclock("NNC",.f. )
				NNC->NNC_DECFIN += nVrAjuFin
				NNC->NNC_OK		:= ''

				//Atualiza status de forma Centralizada
				NNC->NNC_STATUS := OG430STAT( )  //'6' Ajuste Financeiro Processado

				NNC->( MsUnlock() )
				// -- Atualiza o Arquivo NNC (Entregas da Fixação)-- //
				//-- fim Atualiza Arq. Temporario --//


				//-- Alimenta Array c. os ajustes financeiros processados --//
				aAdd(aTitProces,				{;
				/*1 = Romaneio + Item 		*/	NNC->NNC_CODROM + '/' + NNC->NNC_ITEROM,;
				/*2= PREFIX+NR+PARC TITULO	*/	cPrefixtit + "/" + cTitNum + "/" + cTitParc,;
				/*3=Valor					*/	Transform(nVrAjuFin, PESQPICT("NKC","NKC_VRTOT")) })

				

			Else //-- Qdo Ocorreu erro no Execauto a cMensErro volta com o Erro Capturado --//
				DisarmTransaction()
				cShowMens := ''
				cShowMens := STR0010 + NNC->NNC_CODROM + '/' + NNC->NNC_ITEROM  //#'Não foi possivel efetuar Ajuste financeiro  para o Romaneio: '
				cShowMens += " "  + cEOL
				cShowMens += " "  + cEOL
				cShowMens += cMensErro //-- cMensErro está com o Erro do ExecAuto Capturado, por Linhas ( Estilo Memo ) --//
				//EasyHelp( cShowMens )
				Aviso(STR0011,cShowmens,{'OK'},3) //#'Aviso'
				lExit := .T.
			EndIF
			END TRANSACTION
			NNC->( dbSkip() )
		Enddo
	EndIF

	NNC->( DBClearFilter() )	//Retirando o Filtro
	IF !Empty(cSavFiltro)		
		NNC->( DBSetFilter ( {|| &cSavFiltro}, cSavFiltro) )  // Retorna o filtro Inicial
	EndIF

	RestArea( aAreaAtu	)
	RestArea( aAreaNNC	)
	RestArea( aAreaSE1	)
	RestArea( aAreaNJR	)
	RestArea( aAreaNJ0	)

	NNC->( dbGoTop() )

Return( aTitProces )

/*{Protheus.doc} fAltTitREC
Função Responsavel por Ajustar os Titulos do financeiro de recebimento, que  Possuem fixação a menor;
A Forma de Ajustes será inserir um Decrescimo no titulo.

@author Emerson Coelho
@since 22/06/2016
@version 1.0
@param 		cDoc 		-> Docto Fiscal que Gerou o titulo
cSerie		-> Serie DocFiscal  Gerou o titulo
cCliente 	-> Cliente Ref. ao Titulo
cLojCli		-> Loja Cliente Ref. ao Titulo
nDecrescer 	-> Vr. a Acrescer no Titulo (Negativo Indica que está Diminuindo o Ajuste )
@cDescErro	-> Variavel de Referencia que irá conter possivel mensagem de erro do Execauto 
@cPrefixtit	-> Variavel de Referencia que irá conter Prefixo   do titulo que será Ajustado
@cTitNum	-> Variavel de Referencia que irá conter o numero  do titulo que será Ajustado
@cTitParc	-> Variavel de Referencia que irá conter a parcela do titulo que será Ajustado
@return 	.t. Indica que o titulo foi Ajustado, 
.f. Indica que o titulo  não Ajustado
@example
(examples)
@see (links_or_references, cDescErro, cPrefixtit,cTitNum,cTitParc )
*/
Static Function fAltTitREC( cDoc, cSerie, cCliente, cLojCli, nDecrescer, cDescErro,cPrefixtit,cTitNum,cTitParc )
	Local 	aDadosSE1	:= {}
	Local 	nDecresAtu	:= 0
	Local 	cChave		:=''
	Local   nTitRecno   :=0
	Local   nI			:=0

	// Salvando Infs. sobre o Modulo Atual
	Local cModAtu   	:= cModulo
	Local nModAtu   	:= nModulo

	Private lMsErroAuto := .F.

	//Ajuste Possiveis disparidade entre tamanho de campos
	cCliente 	:= PADR(cCliente,	TamSX3("F2_CLIENTE"	)[1],'')      
	cLojCli 	:= PADR(cLojCli,	TamSX3("F2_LOJA"	)[1],'')
	cDoc 		:= PADR(cDoc,		TamSX3("F2_DOC" 	)[1],'')
	cSerie 		:= PADR(cSerie,		TamSX3("F2_SERIE" 	)[1],'')

	// Posicionando no Titulo
	//Encontrando NF. ref. ao Romaneio
	DbSelectArea('SF2')
	SF2->(DbSetOrder(2))	//F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE
	IF ! SF2->( DBSeek(FwXfilial('SF2') + cCliente + cLojCli + cDoc + cSerie))
		Final( STR0012  + cDoc + '/' + cSerie )   //#'NF. não encontrada no sistema docto: ' + cdoc + cSerie
	EndIF

	cChave := cCliente + cLojCli + SF2->( F2_PREFIXO + F2_DUPL  )

	DbSelectArea('SE1')
	SE1->(DbSetOrder(2))	//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	IF ! SE1->( DBSeek( FwXfilial('SE1') + cChave  ))

		IF .not. fWxFilial("SE1") = SE1->E1_FILIAL .And.	.not. SE1->(E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) == cChave
			Final( STR0013 + F2->F2_PREFIXO  + "/" + SF2->F2_DUPL   ) //#'Titulo não encontradO no sistema Prefixo/Numero: ' + + F2->F2_PREFIXO  + "/" + SF2->F2_DUPL
		EndIF
		/* Atenção deveriamos ter somente 1 titulo para cada item do romaneio
		While SE1->(!Eof()) .And. fWxFilial("SE1") == SE1->E1_FILIAL .And.	SE1->(E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM ) == cChave
		Exit
		EndDo
		*/
	Else
		nTitRecno := SE1->( Recno() )
	EndIF

	nDecresAtu	:= SE1->E1_DECRESC
	nDecresAtu 	+= nDecrescer

	//Valid para Decrescimo
	//(M->E1_DECRESC<M->E1_VALOR).AND.POSITIVO().AND.M->E1_ACRESC ==0.AND.iiF(INCLUI,.T.,SE1->E1_SALDO>0).OR.FINVLACDC('R')

	aDadosSE1 := {	{ "E1_PREFIXO"  , SE1->E1_PREFIXO	, NIL },;
	{ "E1_NUM"      , SE1->E1_NUM		, NIL },;
	{ "E1_DECRESC"	, nDecresAtu		, NIL } }   

	//ExecAuto Requer o SetOrder = 1 e o titulo posicionado
	DbSelectArea("SE1")  
	DbSetOrder(1)
	SE1->( DbGoto( nTitRecno 	)  )  //Posicionando no titulo

	// -- Eliminando os arquivos de log dos erros gerados anteriormente -- //
	aArqLogs := Directory("SC*.LOG")
	For nI := 1 to Len(aArqLogs)
		FErase(aArqLogs[nI,1])
	Next nI
	// ------------------------------------------------------------------- //

	// Mudando o Modulo pois na Fina040 possui Validação AMI
	cModulo	:= 'FIN'
	nModulo := 6

	MsExecAuto( { |x,y| FINA040( x,y )} , aDadosSE1, 4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

	//Retornando Infs. Sobre o Modulo que se encontrava Logado
	cModulo	:= cModAtu
	nModulo := nModAtu

	IF lMsErroAuto
		cDescErro := sfAchaErro()		//-- Busca o Log de Erro do Exec. Auto, cDescErro foi Passada como Ponteiro -- //
		lRetorno 	:= .f.
	Else
		//Alert("Título alterado com sucesso!")
		// Quandando o titulo q foi Ajustado
		cPrefixTit	:=	SE1->E1_PREFIXO
		cTitNum		:=	SE1->E1_NUM
		cTitParc	:=  SE1->E1_PARCELA

		lRetorno 	:= .t.
	EndIf 

Return ( lRetorno )

/** {Protheus.doc} fNextNkcIt
Função que retorna o número do próximo item da NKC

@param: 	cCodCtr	» Contrato;
cItemFx	» Item da Fixação;
cCodRom	» Codigo do Romaneio
cIteRom	» Item do Romaneio

@return:	cNextItem	» Item da NKB
@author: 	Emerson Coelho
@since: 	29/01/205
@Uso: 		OGA430D
*/
Static Function fNextNkcIt(cCodCtr, citemFx, cCodRom, cIteRom)
	Local aSaveArea 	:= GetArea()
	Local cAliasQry 	:= GetNextAlias()
	Local cNextItem	:=''

	BeginSql Alias cAliasQry
	SELECT 
	MAX( NKC_ITEM ) as LAST_ITEM
	FROM %Table:NKC% NKC
	WHERE 	NKC.%notDel%
	AND 	NKC_FILIAL = %xFilial:NKC%
	AND 	NKC_CODCTR = %exp:cCodCtr%
	AND 	NKC_ITEMFX = %exp:cItemFx%
	AND 	NKC_CODROM = %exp:cCodRom%
	AND 	NKC_ITEROM = %exp:cIteRom%
	EndSQL

	( cAliasQry )->( DbGoTop() )

	cNextItem := Soma1( ( cAliasQry )->LAST_ITEM )
	cNextItem := StrZero( Val(cNextItem), TamSX3( "NKC_ITEM" )[1] )

	( cAliasQry )->( DbCloseArea() )

	RestArea( aSaveArea )
Return( cNextItem )

/** {Protheus.doc} sfAchaErro
Função que le o log. de erro do Execauto,e retorna os cpos. que apresentaramincocistencia

@param: 	nil
@return:	cMemo.
@author: 	Emerson Coelho
@since: 	29/01/2015
@Uso: 		OGA430D
*/
Static Function sfAchaErro()
	//Local cStartPath:= GetSrvProfString("Startpath","")
	Local cFileLog	:= NomeAutoLog() //Alltrim(cStartPath) + Alltrim(NomeAutoLog())
	Local cRet		:= ""
	Local nPos		:=0

	//Pega o Conteudo do Arquivo Texto do LOG
	Local cConteudo	:= MemoRead( cFileLog )

	FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cfilelog , 0, 0, {})

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

/*{Protheus.doc} fAltTitCPG 
Função Responsavel por Ajustar os Titulos do financeiro de pagamento, que  Possuem fixação a menor;
A Forma de Ajustes será inserir um Decrescimo no titulo a pagar.

@author 	Emerson Coelho	[ Implementado para ctas a pagar por Ana Laura da função fAltTitREC() ]
@since 		22/06/2016
@version 	1.0
@param 		cDoc 		-> Docto Fiscal que Gerou o titulo
			cSerie		-> Serie DocFiscal  Gerou o titulo
			cCliente 	-> Fornecedor Ref. ao Titulo
			cLojCli		-> Loja Fornecedor Ref. ao Titulo
			nDecrescer 	-> Vr. a Acrescer no Titulo (Negativo Indica que está Diminuindo o Ajuste )
			@cDescErro	-> Variavel de Referencia que irá conter possivel mensagem de erro do Execauto 
			@cPrefixtit	-> Variavel de Referencia que irá conter Prefixo   do titulo que será Ajustado
			@cTitNum	-> Variavel de Referencia que irá conter o numero  do titulo que será Ajustado
			@cTitParc	-> Variavel de Referencia que irá conter a parcela do titulo que será Ajustado
@return 	.T. 		-> Indica que o titulo foi Ajustado
			.F. 		-> Indica que o titulo  não Ajustado
@example
(examples)
@see (links_or_references, cDescErro, cPrefixtit,cTitNum,cTitParc )			
*/
Static Function fAltTitCPG( cDoc, cSerie, cFornecedor, cLoja, nDecrescer, cDescErro,cPrefixtit,cTitNum,cTitParc )
	Local 	aDadosSE2	:= {}
	Local 	nDecresAtu	:= 0
	Local 	cChave		:=''
	Local   nTitRecno   :=0
	Local   nI			:=0

	// Salvando Infs. sobre o Modulo Atual
	Local cModAtu   	:= cModulo
	Local nModAtu   	:= nModulo

	Private lMsErroAuto := .F.

	//Ajuste Possiveis disparidade entre tamanho de campos
	cFornecedor := PADR(cFornecedor,TamSX3("F1_FORNECE"	)[1],'')      
	cLoja	 	:= PADR(cLoja,		TamSX3("F1_LOJA"	)[1],'')
	cDoc 		:= PADR(cDoc,		TamSX3("F1_DOC" 	)[1],'')
	cSerie 		:= PADR(cSerie,		TamSX3("F1_SERIE" 	)[1],'')

	// Posicionando no Titulo --- Encontrando NF. ref. ao Romaneio
	DbSelectArea('SF1')
	SF1->(DbSetOrder(1))	//F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	IF ! SF1->( DBSeek(FwXfilial('SF1') + cDoc + cSerie + cFornecedor + cLoja))
		Final( STR0012  + cDoc + '/' + cSerie )   //#'NF. não encontrada no sistema docto: ' + cdoc + cSerie
	Else
	//Verifica se a TES usada controla duplicatas
		If Empty(SF1->(F1_DUPL))
	   		Help(NIL, NIL, STR0014,;
			    NIL, STR0015,;
				 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0016})
  		Return ( .F. )
		EndIf
	EndIF
	
	//-- Chave da SE2 6 - E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	cChave := cFornecedor + cLoja + SF1->( F1_PREFIXO + F1_DUPL  )
	DbSelectArea('SE2')
	SE2->(DbSetOrder(6))	//E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	IF ! SE2->( DBSeek( FwXfilial('SE2') + cChave  ))
		IF .not. fWxFilial("SE2") = SE2->E2_FILIAL .And. .not. SE2->(E2_FORNECE + E2_LOJA + E2_PREFIXO + E2_NUM ) == cChave
			Final( STR0013 + SF1->F1_PREFIXO  + "/" + SF1->F1_DUPL   ) //#'Titulo não encontradO no sistema Prefixo/Numero: ' + + F2->F2_PREFIXO  + "/" + SF2->F2_DUPL
		EndIF
	Else
		nTitRecno := SE2->( Recno() )
	EndIF

	nDecresAtu	:= SE2->E2_DECRESC
	nDecresAtu 	+= nDecrescer

	aDadosSE2 := {	{ "E2_PREFIXO"  , SE2->E2_PREFIXO	, NIL },;
					{ "E2_NUM"      , SE2->E2_NUM		, NIL },;
					{ "E2_DECRESC"	, nDecresAtu		, NIL } }   

	//ExecAuto Requer o SetOrder = 1 e o titulo posicionado
	DbSelectArea("SE2")  
	DbSetOrder(1)
	SE2->( DbGoto( nTitRecno )  )  //Posicionando no titulo

	// -- Eliminando os arquivos de log dos erros gerados anteriormente -- //
	aArqLogs := Directory("SC*.LOG")
	For nI := 1 to Len(aArqLogs)
		FErase(aArqLogs[nI,1])
	Next nI
	// ------------------------------------------------------------------- //

	// Mudando o Modulo pois na Fina040 possui Validação AMI
	cModulo	:= 'FIN'
	nModulo := 6

	MsExecAuto( { |x,y,z| FINA050( x,y,z )} , aDadosSE2,, 4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
	//Retornando Infs. Sobre o Modulo que se encontrava Logado
	cModulo	:= cModAtu
	nModulo := nModAtu

	IF lMsErroAuto
		cDescErro := sfAchaErro()		//-- Busca o Log de Erro do Exec. Auto, cDescErro foi Passada como Ponteiro -- //
		lRetorno  := .f.
	Else
		//Alert("Título alterado com sucesso!")
		// Quandando o titulo q foi Ajustado
		cPrefixTit	:=	SE2->E2_PREFIXO
		cTitNum		:=	SE2->E2_NUM
		cTitParc	:=  SE2->E2_PARCELA

		lRetorno 	:= .T.
	EndIf 

Return ( lRetorno )
