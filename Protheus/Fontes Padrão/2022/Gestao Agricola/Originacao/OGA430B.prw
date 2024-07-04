#include 'protheus.ch'
#include 'parmtype.ch'
#InClude 'OGA430B.CH'

Static __cPedVnda
Static __cSeriSF2	:= SuperGetMV("MV_OGASERS"	,.f.," "	)		//Busca serie de nota de Saida 	*Parametro*
Static __CPgtoSF1	:= SuperGetMV("MV_CONDPAD"	,.f.,"001"	)		//Busca Condicao de Pagto
Static __cSeriSF1	:= SuperGetMV("MV_OGASERE"	,.f.," "	)		//Busca serie de nota de Compra	*Parametro*
Static __lCtrVnd	:= nil											//Flag que indica se é um ctrato de Venda
Static __cCodCtr	:= ""

/*{Protheus.doc} fGerNfComp()
Chama Rotina Responsavel Por Gerar a Nf. de complemento 
Tanto Para Compra Como Para Venda

@param      cFiltroNNC 	-> Filtro a Ser Aplicado na tabela de vinculos de romaneios
@nNFGeradas	-> Irá conter o nr. de doctos gerados ( Referencia )
@cshowMens	-> Irá conter mensagem informando quais doctos foram gerados ( Referencia )
lCtrVnd		-> Indica se o Contrato é de Venda ou Nao( Compra ) 
@sample     fGerNfComp()
@return    ExpL    Verdadeiro / Falso
@author    Emerson coelho
@since      27/01/2015
@version    P11
*/
Function OGA430B( cFiltroNNC, nNFGeradas, cShowMens, lctrVnd , cCodCtr )
	Local cEOL     		:= Chr(13)+Chr(10) //--End of Line--//
	Local aNFGeradas 	:= {} //-1 = Romaneio + Item , 2= Nf.Nr + Serie , 3=Valor
	Local nX			:= 0
	Local cTes			:= Criavar('D2_TES',.f.)
	Local dDtVencto		:= dDataBase
	Local lContinua		:= .T.

	Private _dOgVctCpl  := dDataBase
	//Inicializando Static Var
	__lCtrVnd		:= lCtrVnd
	__cCodCtr		:= cCodCtr

	// Ponto de entrada de Uso Geral foi Criado porque a SG. em alguns Casos necessita apresentar uma Tela 
	// Com Alguns Dados ao Usuario antes de iniciar a emissão da NF. DE CPL.
	If ExistBlock("OG430ANF")
		ExecBlock("OG430ANF",.F.,.F.)
	EndIF

	// Verifica se deve ou não abrir a tela para escolha da serie 
	// da nf a Gerar
	IF .not. __lCtrVnd
		If Empty( __cSeriSF1 )						//-- Se a serie não estiver preenchida no parametro, abre a tela para seleção da série --//
			If .Not. SX5NumNota(@__cSeriSF1, GetNewPar("MV_TPNRNFS","1") )
				Return (  )
			EndIf
		EndIf
	Else
		If Empty( __cSeriSF2 )						//-- Se a serie não estiver preenchida no parametro, abre a tela para seleção da série --//
			If .Not. SX5NumNota(@__cSeriSF2, GetNewPar("MV_TPNRNFS","1") )
				Return (  )
			EndIf
		EndIf
	EndIF

	IF ! __lCtrVnd				//--É Ctrato de Compra
		Pergunte('OGA430',.F.) 	//-- Loading Params. Nf. de Compl Ctrs. Compra	--//

		cTes := MV_PAR01

		//--Validadndo TES --//
		Do Case
			Case Empty( cTes )
			Help( , , STR0001, , STR0002, 1, 0 ) //"AJUDA"###"Favor informar a TES de emissão do documento fiscal de Complemento."
			Return( aNfGeradas )
			OtherWise
			cTes :=  MV_PAR01
			SF4->( dbSetOrder( 1 ) )
			IF ! SF4->( dbSeek( xFilial( "SF4" ) + cTes ) )
				Help( , , STR0002, , STR0003, 1, 0 ) //"AJUDA"###"TES, informada não é valida"
				Return ( aNfGeradas )
			EndIF
		EndCase
		//--Validadndo TES --//
	EndIF

	//-- Verifica Se Precisa Ajustar ordem dos campos da D1, de nforigem,serieorigem e itemorigem --//
	IF ! fValidadic()
		Help( , , STR0001, , STR0004, 1, 0 ) //"AJUDA"###"Não é possivel emitir nfs. de complemento de preços. A ordem dos Campos D1_NFORI,D1_SERIORI,D1_ITEMORI não está sequencial crescente no dicionario de dados. Contate a TI para Verificar a ordem destes campos na tabela SD1 no dicionario de dados via configurador."
		Return ( aNfGeradas )
	EndIF

	If SF4->( F4_DUPLIC ) == "S"
		dbSelectArea("NN7")
		dbSetOrder(1) 
		IF MsSeek( xFilial("NN7") + __cCodCtr ) 
			While ! NN7->( Eof() ) .And. NN7->( NN7_FILIAL + NN7_CODCTR ) == xFilial( "NN7" ) + __cCodCtr
				If NN7->( NN7_DTVENC ) >= dDatabase
					dDtVencto := NN7->( NN7_DTVENC )
				Else 	
					dDtVencto := dDatabase
				EndIf              
				NN7->( DbSkip() )
			EndDo
		EndIf
	EndIF

	//-- Se é contrato de Compra - Habilita
	If .NOT. __lCtrVnd	
		//--Habilita tela para informar a data de vencimento do titulo
		fTelaGetDt( @dDtVencto, @lContinua )

		_dOgVctCpl := dDtVencto	//Data de vencimento
	EndIf 

	//-- Se .T. = alimenta variavel de data e gera NF
	If lContinua		
		CursorWait()
		Processa({|| fGerNFCpl(cTes, @aNfGeradas,cFiltroNNC )},OemToAnsi( STR0005 ) ) //#"Gerando Documento Fiscal de Complemento"
		CursorArrow()

		//-- Se .F. = alimenta array de nf geradas para branco.
	ElseIf .NOT. lContinua 
		aNfGeradas 	:= {}
	EndIf

	//-- Identificando se Foi Gerada alguma NF. de Complemento --//
	nNFGeradas := 0
	IF len(aNfGeradas) > 0
		nNFGeradas := len( aNfGeradas ) 
		cShowMens := STR0006 + cEOL //#"Foram Gerada(s) as Nf(s). de Complemento(s):"
		For nX := 1 to Len( aNfGeradas ) Step 1
			cShowMens+= STR0007 + aNfGeradas[nX,1] + "	" + STR0008 + aNfGeradas[nX,2] + "	" + STR0009 + cValToChar( aNfGeradas[nX,3] ) + cEOL //#Roman.:$"N.F.:"#"Valor:
		Next nX
	Else
		cShowMens := STR0013	//#"Nenhuma NF. de Complemento Gerada."
	EndIf

Return(.T.)

/** {Protheus.doc} fTelaGetDt
- Função para de tela para a escolha da data de vencimento
dos títulos de complemento de preço

@param: 	dDtVencto		Data de Vencimento
@param: 	lContinua		.T. para Verdadeiro .F. para Falso
@return:	Nil
@author: 	Ana Laura Olegini
@since: 	06/09/2016
*/
Static Function fTelaGetDt( dDtVencto, lContinua)
	Local aPergs 		:= {}
	Local aRetDt		:= {}	

	//-- aPergs = Array contendo os parâmetros
	aAdd( aPergs ,{ 9, STR0015 + DtoC(dDtVencto) + "." , 150, 40, .T. } )			//"A data de vencimento dos títulos de complemento de preço será "
	aAdd( aPergs ,{ 9, STR0016 , 150, 40, .T. } )									//"Caso deseja ajustar informe a data de vencimento." 
	aAdd( aPergs ,{ 9, " ", 70, 10, .T. } ) 
	aAdd( aPergs ,{ 1, STR0017 , dDtVencto , "",'.T.',,".T.",55,.F.} )				//"Data Vencimento " 

	//-- Enquanto verdadeiro 
	While .T.
		//-- Habilita a tela para a confirmação da data de vencimento
		If ParamBox( aPergs , STR0014 , aRetDt, , , .T.,,,,, .F., .F.)				//"Confirmação de Data"
			//-- Se OK = verifica se a data é maior que a data base [data do sistema]
			If aRetDt[4] >= dDataBase
				dDtVencto := aRetDt[4]	//Data para o sistema 
				lContinua := .T.		
				Exit
				//-- Senão = verifica se a data é menor que a data base [data do sistema]
			ElseIf dDataBase > aRetDt[4]
				//-- Apresenta a msg e retorna para informar a data.
				Help( , , STR0001, , STR0018 , 1, 0 )								//"AJUDA"#"Favor informar uma data maior que a data atual."
			EndIf
			//-- Se cancelar = retorna falso e sai do while para continuar
		Else
			lContinua := .F.
			Exit
		EndIf
	EndDo	

Return()

/*{Protheus.doc} Og430C5NUM()
Função Auxiliar de Valição do C5_NUM,
para evitar pular de 2 em 2 o numero;
Sua principal função eh executar um RollbackSX8()
(Para evitar que se fique pulando o Nr.)
é Executado somente qdo a MATA410, estiver Validando o NR.
@param        nil
@sample     Og430C5NUM()
@return    Sempre Verdadeiro
@author    Emerson coelho
@since      24/082015
@version    P11
*/
Function Og430C5NUM()
	Local lOk := .t.
	ROLLBACKSX8()
	lok :=ExistChav("SC5",fWxFilial('SC5'+__cPedVnda ))
Return( lOk )
/*{Protheus.doc} fImpCplto
Função Auxiliar Que Retorna soma dos seguintes impostos:
// [ -- Impostos a Considerados neste momento  (<< Senar, Fethab(MT), Facs (MT),FUNRURAL>,FUNDERSUL (MS) >>)]
@param      Nr.		Docto Gerado
Seire 	Docto Gerado
Codigo do Cli/For
Codigo do Lja

@sample     Og430C5NUM()
@return    Vr. da NF. de Complemento
@author    Emerson coelho
@since      24/082015
@version    P11
/*/

Static Function fImpCplto(cDoc,cSerie,cCliFor,cLoja)

	Local nVrImposto	:= 0
	Local aAreaATU		:= GetArea()
	Local aAreaSD1		:= SD1->( GetArea() )
	Local aAreaSD2		:= SD2->( GetArea() )

	IF .NOT. __lCtrVnd   //Ctrato de Compra
		DbSelectArea('SD1')
		SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		SD1->(dBSeek(fWxFilial('SD1')+cDoc+cSerie+cCliFor+cLoja))
		While SD1->(! Eof() )  .and. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == fWxFilial('SD1')+cDoc+cSerie+cCliFor+cLoja
			nVrImposto := SD1->(D1_VLSENAR + D1_VALFET + D1_VALFAC + D1_VALFUN + D1_VALFDS + D1_VALINS)
			SD1->( DbSkip() )
		EndDo
	Else
		DbSelectArea('SD2')
		SD2->(DbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		SD2->(dBSeek(fWxFilial('SD1')+cDoc+cSerie+cCliFor+cLoja))
		While SD2->(! Eof() )  .and. SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == fWxFilial('SD2')+cDoc+cSerie+cCliFor+cLoja
			nVrImposto := SD2->(D2_VLSENAR + D2_VALFET + D2_VALFAC + D2_VALFUN + D2_VALFDS)
			SD2->( DbSkip() )
		EndDo
	EndIF

	RestArea( aAreaATU )
	RestArea( aAreaSD1 )
	RestArea( aAreaSD2 )	

Return(nVrImposto)
/*{Protheus.doc} fAJUSTACPL
Função executada antes de emitir uma NF. de Complemento 
o Intuito é garantir que o vr. liquido da 
fixação (nn8) bata com os vrs. liquidos do financeiro
para esta Fixação senao Bater tenta ajustar na ultima nf de complemento

@param     	Vr. da Nf. de Compl. Baseado no Calc. da Fixação

@return    Vr. da Nf. de compl.a Ser emitida
@author    Emerson coelho
/*/

Static Function fAJUSTACPL( nVrlastNF )

	Local aAreaAtu 		:= GetArea()
	Local aAreaNJR		:= NJR->( GetArea() )
	Local aAreaNNC		:= NNC->( GetArea() )
	Local aAreaNN8		:= NN8->( GetArea() )

	Local cAliasNNC 	:= GetNextAlias()

	Local cFormul		:= 'S'
	///Local nVLCMPL		:= 0
	Local lLastCpl		:= .f.    //-->> não é o Ultimo Complemento -->>
	Local nVrSuger		:= 0
	Local lAjustar		:= .f.
	Local cClifor		:=''
	Local cCliforLja	:=''
	Local cTipoNF		:= '' // 'E' Indica que é uma Entrada, 'S' Indica que é Saida

	// -- Verificando se é A Ultima NF de Compl. a Ser Emitida
	BeginSql Alias cAliasNNC
	SELECT COUNT(NNC_ITEMFX) as EntrSemCpl FROM %Table:NNCC% NNC
	WHERE	NNC.%notDel%
	AND 	NNC.NNC_FILIAL  	= %xFilial:NNC%
	AND 	NNC.NNC_CODCTR  	= %exp:NN8->NN8_CODCTR%
	AND 	NNC.NNC_ITEMFX 	 	= %exp:NN8->NN8_ITEMFX%
	AND     NNC.NNC_FORMUL		= %exp:cFormul%
	AND     NNC.NNC_VLCMPL		= 0
	EndSQL

	( cAliasNNC )->( DbGoTop() )

	IF ( cAliasNNC )->EntrSemCpl = 1   .and. (NN8->NN8_QTDFIX = NN8->NN8_QTDENT )// Indica que é a Ultima NF. de Complemento que será emitida
		lLastCPL := .t.	   
	EndIF

	( cAliasNNC )->( DbCloseArea() )

	// -- Verificando se é A Ultima NF de Compl. a Ser Emitida


	// -- Verificando se já existe uma NF DE Compl. com Ajuste --
	IF lLastCPL   // Verifica se já tem um Item da Fixação com ajuste Se Sim não faz Mais Ajustes
		// Ocorre qdo emito todas as NFs. de complemento e depois vou e Excluo por ex. a 1a.
		//Nf. q foi gerada. A porxima vez q for re-emiti-la ele entende q é a ultima
		//porem n. devo ajustar.

		BeginSql Alias cAliasNNC
		SELECT COUNT(NNC.R_E_C_N_O_) AS NRECNOS FROM %Table:NNCC% NNC
		WHERE	NNC.%notDel%
		AND 	NNC.NNC_FILIAL  	= %xFilial:NNC%
		AND 	NNC.NNC_CODCTR  	= %exp:NN8->NN8_CODCTR%
		AND 	NNC.NNC_ITEMFX 	 	= %exp:NN8->NN8_ITEMFX%
		AND     NNC.NNC_FORMUL		= %exp:cFormul%
		AND     NNC_VLFBAJ		> 0
		EndSQL

		( cAliasNNC )->( DbGoTop() )

		IF ( cAliasNNC )->NRECNOS > 0   	// Indica que já existe uma nfcmpl de Ajuste e não devemos ajustar em outra
			lAjustar := .f.	   
		Else
			lAjustar := .t.
		EndIF

		( cAliasNNC )->( DbCloseArea() )
	EndIF


	// -- Fim Verificando se já existe uma NF DE Compl. com Ajuste --

	IF ! lAjustar   //Indica que não devemos Ajustar
		RestArea( aAreaNNC )
		RestArea( aAreaNJR )
		RestArea( aAreaNN8 )
		Return( nVrlastNF )
	EndIF


	//-- Indica Q tenho que Ajustar então inicio o processo	


	BeginSql Alias cAliasNNC
	SELECT 	SUM(NNC_QTDFIX) AS QTFIXADA, 
	SUM(NNC_VLFIXB) AS VRFIXADO, 
	SUM(NNC_VRENPF) AS VRNFENTREGA, 
	SUM(NNC_VLIMPF) AS VRIMPNFENTR, 
	SUM(NNC_VLCMPL) AS VRNFCPLEMENTO, 
	SUM(NNC_VLIMPC) AS VRIMPCPLEMENTO  
	FROM %Table:NNCC% NNC	
	WHERE	NNC.%notDel%
	AND 	NNC.NNC_FILIAL  	= %xFilial:NNC%
	AND 	NNC.NNC_CODCTR  	= %exp:NN8->NN8_CODCTR%
	AND 	NNC.NNC_ITEMFX 	 	= %exp:NN8->NN8_ITEMFX%
	EndSQL

	( cAliasNNC )->( DbGoTop() )

	nVRLiqFix := NN8->NN8_VLRLQT	// Valor Liquido da Fixação

	// -- Encontrando o Vr. dos titulos que estão no financeiro --
	nVrTits  := 0	   
	nVrtits	 +=	( cAliasNNC )->VRNFENTREGA  	//+Vr. Bruto da Nf Normal( Entrada / Saida )
	nVrtits	 -=	( cAliasNNC )->VRIMPNFENTR  	//-Vr. dos Impostos a desconsiderar da Nf Normal(Entrada / Saida)

	nVrtits	 +=	( cAliasNNC )->VRNFCPLEMENTO  	//+Vr. Bruto da Nf Complemento( Entrada / Saida )
	nVrtits	 -=	( cAliasNNC )->VRIMPCPLEMENTO  	//-Vr. dos Impostos a desconsiderar da Nf Complemento(Entrada / Saida)
	// nVrtits Corresponde Exatamente ao Vr. que temos a Receber no Financeiro
	( cAliasNNC )->( DbCloseArea() )

	nVrLqUltNF := nVRLiqFix - nVrtits    		//Encontro o Vr. Liquido q necessito para Igualar o Vr. Liq. da Fixação com o financeiro

	// -- Posicionando no Contrato --
	DbSelectArea( 'NJR' )
	NJR->( DbSetOrder(1) ) //NJR_FILIAL+NJR_CODCTR
	IF ! NJR->( DbSeek(fWXfilial('NJR') + NN8->NN8_CODCTR ) )
		Final("Erro: Contrato ref. a Fixação não encontrado;Contrato:" + NN8->NN8_CODCTR )
	EndIF


	// Verifico qual será o Vr. liquido do titulo Sem funrural + fethab, etc.
	IF NJR->NJR_TIPO == '1'  		//Ctrato de Compra
		cClifor		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODFOR")	// Cod Forn.
		cCliforLja	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJFOR")	// Loja Forn
		cTipoNF		:= 'E'
	ElseIF NJR->NJR_TIPO == '2'		//Contrato de Venda
		cClifor		:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODCLI")	// Cod 	Cliente
		cCliforLja	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJCLI")	// Loja Cliente
		cTipoNF		:= 'S'	   
	EndIF

	nVrTitAux		:= OG430FTxa(cTipoNF, cClifor, cCliforLja, NJR->NJR_CODPRO, NJR->NJR_TESEST, 1, nVrlastNF )

	IF  nVrLqUltNF ==  nVrTitAux //Tudo Certo o Vr. Liq. da Nf. que Será Gerada irá fazer com q o financeiro feche com o Vr. liq. da Fixacao 
		Return( nVrlastNF )
	ElseIF nVrLqUltNF > nVrTitAux
		lAddNaNF := .t.
	ElseIF nVrLqUltNF < nVrTitAux
		lAddNaNf := .f.
	EndIF

	ldifZerou := .f.   // Flag que indica que não temos mais diferença

	/*  nMenorVr, Irá conter a menor und, que o vr. Total pode Ter no caso 0.01 
	pois o Vr. total dos doctos fiscais tem 2 Casas;  
	*/
	nMenorVr := 0.01
	IF ! lAddNaNf 	// Se a Dif. é negativa tenho q Subtrair
		nMenorVr *= (-1) // forçando o Vr. ficar negativo Para Subtrair
	EndIF

//    If nVrLqUltNF - nVrTitaux >= 0.1 .or. nVrLqUltNF - nVrTitaux <= -0.1// tratamento realizado para melhorar a performance do gestor de entidade
//		nVrNFSimul := nVrlastNF + (nVrLqUltNF - nVrTitaux)
//	Else 
		nVrNFSimul	:= nVrlastNF
//	EndIf

	nDifInicio		:= nVrLqUltNF - nVrTitAux
	nVrNfSuger		:= 0
	While (.t.)    
		nVrNFSimul 	+=  nMenorVr
		nVrTitaux	:= OG430FTxa(CTipoNF, cClifor, cCliforLja, NJR->NJR_CODPRO, NJR->NJR_TESEST, 1, nVrNFSimul )
		IF (nVrLqUltNF - nVrTitAux) = 0 // -- Dif. Zerou --
			nVrsuger	:= nVrNFSimul
			lDifZerou	:= .T.
			Exit  
		ElseIF ( nVrLqUltNF - nVrTitAux) > 0 .and. lAddNaNf == .f.   // Indica que a dif. era negativa e agora passou a positiva 
			Exit  	// Tento Ajustar no Proximo item
		ElseIF ( nVrLqUltNF - nVrTitAux) < 0 .and. lAddNaNf == .t.    // Indica que a dif. era Positiva e agora passou a Negativa 
			Exit 	// Tento Ajustar no Proximo item                    //ou seja não conseguiu;             
		Else 		// Quardo o Vr. q Trouxe a menor diferença;
			nMenorDif  := nVrLqUltNF - nVrTitAux
			nVrSuger	:= nVrNFSimul
		EndIF                                  
	EndDo

	RestArea( aAreaATU )
	RestArea( aAreaNNC )
	RestArea( aAreaNJR )
	RestArea( aAreaNN8 )

Return( nVrSuger )

/** {Protheus.doc} fSeqCpos()
Esta função q Valida a ordem dos campos : D1_NFORI, D1_SERIORI, D1_ITEMORI
pois o execauto da mata103 falha se estes campos n. estiverem nesta ordem.

@param: 	nil.
@return:	.t. or .f. »Indicando q a ordem dos campos está ok no dicionario.
@author: 	Emerson Coelho
@since: 	29/01/2015
@Uso: 		OGA430
*/

Static function fValidadic()
	
	Local cOrdemOK	:= 'D1_NFORI'+'D1_SERIORI'+'D1_ITEMORI'
	Local cOrdemSX3	:=''
	Local aCposAux	:={}  // -- 1=Nr. da Ordem do cpo na SX3, 2=Nome do Campos -- //
	Local lordemOK	:= .t.

	//-- Identificando a Posição dos Campos ref. a Nf. de origem -//
	aAdd( aCposAux, {X3ORDEM('D1_NFORI')  ,'D1_NFORI'} )
	aAdd( aCposAux, {X3ORDEM('D1_SERIORI'),'D1_SERIORI'} )
	aAdd( aCposAux, {X3ORDEM('D1_ITEMORI'),'D1_ITEMORI'} )

	//-- Ordena o Array Multidimensional em ordem Crescente Considerando somente a 1a Coluna (X3_ORDEM) -- //
	aOrdemCpos  := ASORT(aCposAux,,, { |x, y| x[1] < y[1] })

	cOrdemSx3 := Alltrim( aOrdemCpos[1,2] ) + Alltrim( aOrdemCpos[2,2] ) + Alltrim( aOrdemCpos[3,2] )

	/*/
	Para o Execauto do Mata103 Funcionar os Campos D1_NFORI, D1_SERIORI,D1_ITEMORI
	devem estar no dicionario nesta ordem sequencial. (Caso ctrario o Execauto irá
	Falhar). Portanto o Array tem q ter obrigatoriamente na Posicao 1-D1_NFORI ,
	2-D1_SERIORI, 3-D1_ITEMORI. Se n. tiverem a Validação é .f.
	/*/

	IF !cOrdemSx3 = cOrdemOK
		lOrdemOk := .f.
	EndIF

Return ( lOrdemOK )

/** {Protheus.doc} fGetTitOrg
Funcao q Retorna o Recno do 1a. Tit. de Origem

@param: 	cPrfx 	- Prefixo
cNum	- Numero
cForn	- Fornecedor
cLja	- Loja
@return:	Recno do titulo.
@author: 	Emerson Coelho
@since: 	29/01/2015
@Uso: 		OGA430
*/


Static Function fGetTitOrg(cPrfx, cNum, cForn,cLja)

	Local aSaveArea 	:= GetArea()
	Local cAliasQry 	:= GetNextAlias()
	Local nRecOrigem	:= 0

	BeginSql Alias cAliasQry
	SELECT R_E_C_N_O_
	FROM %Table:SE2C% SE2
	WHERE SE2.%notDel%
	AND E2_FILIAL  	= %xFilial:SE2%
	AND E2_PREFIXO  	= %exp:cPrfx%
	AND E2_NUM 	 	= %exp:cNum%
	AND E2_FORNECE 	= %exp:cForn%
	AND E2_LOJA 		= %exp:cLja%
	ORDER BY R_E_C_N_O_
	EndSQL

	( cAliasQry )->( DbGoTop() )

	nRecOrigem	:= ( cAliasQry )->R_E_C_N_O_

	( cAliasQry )->( DbCloseArea() )

	RestArea( aSaveArea )
Return ( nRecOrigem )

/** {Protheus.doc} fNextNkcIt
Função que retorna o número do próximo item da NKC

@param: 	cCodCtr	» Contrato;
cItemFx	» Item da Fixação;
cCodRom	» Codigo do Romaneio
cIteRom	» Item do Romaneio

@return:	cNextItem	» Item da NKB
@author: 	Emerson Coelho
@since: 	29/01/205
@Uso: 		OGA430
*/
Static Function fNextNkcIt(cCodCtr, citemFx, cCodRom, cIteRom)
	Local aSaveArea 	:= GetArea()
	Local cAliasQry 	:= GetNextAlias()
	Local cNextItem	:=''

	BeginSql Alias cAliasQry
	SELECT MAX( NKC_ITEM ) as LAST_ITEM
	FROM %Table:NKC% NKC
	WHERE NKC.%notDel%
	AND NKC_FILIAL = %xFilial:NKC%
	AND NKC_CODCTR = %exp:cCodCtr%
	AND NKC_ITEMFX = %exp:cItemFx%
	AND NKC_CODROM = %exp:cCodRom%
	AND NKC_ITEROM = %exp:cIteRom%
	EndSQL

	( cAliasQry )->( DbGoTop() )

	cNextItem := Soma1( ( cAliasQry )->LAST_ITEM )

	cNextItem := StrZero( Val(cNextItem), TamSX3( "NKC_ITEM" )[1] )

	( cAliasQry )->( DbCloseArea() )

	RestArea( aSaveArea )

	Return( cNextItem )
	*******************


/** {Protheus.doc} sfAchaErro
Função que le o log. de erro do Execauto,
e retorna os cpos. que apresentaram
incocistencia

@param: 	nil
@return:	cMemo.
@author: 	Emerson Coelho
@since: 	29/01/2015
@Uso: 		OGA430
*/

Static Function sfAchaErro()
	//Local cStartPath:= GetSrvProfString("Startpath","")
	Local cFileLog	:= NomeAutoLog() //Alltrim(cStartPath) + Alltrim(NomeAutoLog())
	Local cRet		:= ""
	Local nPos		:=0

	//Pega o Conteudo do Arquivo Texto do LOG
	Local cConteudo	:= MemoRead( cFileLog )

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

/** {Protheus.doc} OGA430BNfCplV
Gerar NF de Complemento de pre

@param: 	nRecnoNNC ->	Recno da Tab. NNC a Gerar a Nf. de Complemento
nVrtotal	->	Vr. Total do Complemento
cDescErro	-> Var Passada via Ponteiro que será abastecida com erro do ExecAuto Caso Ocorra
@cSerie		-> Var Passada Como ponteiro que será abastecida com a Serie 	da Nf. Emitida
@cNfGerada	-> Var Passada Como Ponteiro que será abastecida com o Nr. 	  	da Nf Emitida
@nVrIMPCpl	-> Valor dos Impostos da Nf. de Complemento Gerada
@cCliente	-> Codigo do cliente
@cLjaCli	-> Loja do cliente
@return:	lOK - .t. ou .f.
@author: 	Emerson Coelho
@since: 	21/08/2015
@Uso: 		SIGAAGR
*/
Function OGA430BNfCplV( nRecnoNNC, nVrtotal, cDescErro, cSerie, cNfGerada,nVrImpCpl,cCliente,cLjaCli, oNJJModel)
	//-- Var de Retorno  e Controle do Fluxo--//
	Local lOk			:= .T.
	Local nI			:= 0

	// -- Salvando Posição das Aread de Trabalho -- //
	Local aAreaAtu		:= GetArea()
	Local aAreaSC5 		:= SC5->(GetArea())
	Local aAreaSC6 		:= SC6->(GetArea())
	Local aAreaSF2 		:= SF2->(GetArea())
	Local aAreaSD2		:= SD2->(GetArea())
	Local aAreaSE1		:= SE1->(GetArea())
	Local aAreaNNC		:= NNC->(GetArea())
	// -- Variaveis de Auxilio -- //
	Local aCab 		:= {}
	Local aItens 		:= {}
	Local aLinha		:= {}
	Local cItemSeq   	:= Criavar("C6_ITEM",.f.)
	//Local cCliente	:= ''
	//Local cLjaCli		:= ''
	Local cCodSaf		:= ''
	Local cNfOri		:= ''
	Local cSeriOri		:= ''
	Local cItemOri		:= ''
	Local dEmissao		:= dDataBase
	Local aGerouDoc		:= { } 								// Pos 1 = Doc.Num, Pos2 = Doc.Serie
	// ----------- //
	Local lCond			:= .F.
	Local lVencimento	:= .F.
	
	
	//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
	Local cModAtu       := cModulo
	Local nModAtu       := nModulo

	//-- Vars. Ctrole ExecAuto -- //
	Private lMsHelpAuto := .T.  		// se .t. direciona as mensagens de help
	Private lMsErroAuto := .F. 		//necessario a criacao, pois sera
	
	Default _lComplRom := .F. 	
	//------------------------------ Fim Declaração das Variaveis -----------------------------//
	//--Posicionando no Registro que Tem q ser Emitido nf de Compl.
	If _lComplRom //se é chamado via complemento do romaneio.
		__cSeriSF2 := cSerie
		cCodRom 	:=  ""
		cIteRom 	:=	""
		cItemFx 	:=  ""
		cPrograma 	:= "OGA251"	
		cCodCtr 	:= oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODCTR")
		cCliente	:= Posicione("NJ0",1,FwxFilial("NJ0") + oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODENT")+oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_LOJENT"),	"NJ0_CODCLI"	)	// Cod Cliente
		cLjaCli		:= Posicione("NJ0",1,FwxFilial("NJ0") + oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODENT")+oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_LOJENT"),	"NJ0_LOJCLI"	)	// Lja	Cliente
		cCodSaf		:= oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODSAF")
		cNfOri		:= oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_DOCNUM")
		cSeriori	:= oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_DOCSER")
		cItemOri	:= Soma1(Strzero( 0, TamSX3( "D2_ITEMORI" )[1] ) ) 			//-- Como Cada Item do Rom Gera uma Nf de Entrada , Sempre Será o item '001' --//
		cCondPg		:= oModelOrig:GetModel("NJMUNICO"):GetValue("NJM_CONDPG")
		cCodPrd		:= oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_CODPRO") 

		cLocal		:= oModelOrig:GetModel("NJJUNICO"):GetValue("NJJ_LOCAL")
		cItemSeq 	:= StrZero( Val( '0' ), TamSX3( "C6_ITEM" )[1] )

		cE1_Prefix	:= Posicione("SF2",1,FwxFilial("SF2") + cNfOri + cSeriOri + cCliente + cLjaCli + 'N',	"F2_PREFIXO"	)	// Retorna o Prefixo do Tit. Original
		cE1_Num	:= Posicione("SF2",1,FwxFilial("SF2") + cNfOri + cSeriOri + cCliente + cLjaCli + 'N',	"F2_DUPL"	)		// Retorna o Prefixo do Tit. Original

	Else
		NNC->( DbGoTo( nRecnoNNC ) )
		cCodRom := 		NNC->NNC_CODROM
		cIteRom :=		NNC->NNC_ITEROM
		//-- Encontrado os Dados do docto de Origem --//
		cNfOri		:= NNC->NNC_NUMDOC
		cSeriori	:= NNC->NNC_SERDOC
		cItemOri	:= Soma1(Strzero( 0, TamSX3( "D2_ITEMORI" )[1] ) ) 			//-- Como Cada Item do Rom Gera uma Nf de Entrada , Sempre Será o item '001' --//
		cItemFx := NNC->NNC_ITEMFX
		cPrograma := "OGA430B"	
		//-- Lendo os itens do Romaneio ---//
		NJM->( dbSetOrder( 1 ) )	//NJM_FILIAL+NJM_CODROM+NJM_ITEROM
		IF NJM->( dbSeek( fWxFilial( 'NJM' ) + NNC->NNC_CODROM + NNC->NNC_ITEROM ) )
			//-- Buscando o Fornecedor no Cadastro de Entidade --//
			cCodCtr 	:= NJM->NJM_CODCTR
			cCliente	:= Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),	"NJ0_CODCLI"	)	// Cod Cliente
			cLjaCli		:= Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),	"NJ0_LOJCLI"	)	// Lja	Cliente
			cCodSaf		:= NJM->NJM_CODSAF			
			cCodPrd		:= NJM->NJM_CODPRO 
			// -- Verificando Condicao de pagto e Dt. Vencto Cfe OGX008 -- //
			cCondPg	:= NJM->( NJM_CONDPG )

			cLocal		:= NJM->NJM_LOCAL
			cItemSeq 	:= StrZero( Val( '0' ), TamSX3( "C6_ITEM" )[1] )

			//--Encontrando o prefixo do tit. da nf. original idx 1= F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			cE1_Prefix	:= Posicione("SF2",1,FwxFilial("SF2") + cNfOri + cSeriOri + cCliente + cLjaCli + 'N',	"F2_PREFIXO"	)	// Retorna o Prefixo do Tit. Original
			cE1_Num	:= Posicione("SF2",1,FwxFilial("SF2") + cNfOri + cSeriOri + cCliente + cLjaCli + 'N',	"F2_DUPL"	)		// Retorna o Prefixo do Tit. Original
		Else
			Return(.f.) // Falha
		EndIF
	EndIf
	// -- Gerando o PV -- //

	// Cabecalho do pedido
	aAdd( aCab, { "C5_TIPO"     , "C"         	, Nil } )//Complemento de Preço
	aAdd( aCab, { "C5_CLIENTE"  , cCliente    	, Nil } )
	aAdd( aCab, { "C5_LOJACLI"  , cLjaCli      	, Nil } )

	//Verifica se o campo existe 
	If SC5->(FieldPos("C5_TPCOMPL")) > 0
		aAdd( aCab, { "C5_TPCOMPL" , '1', Nil } )	//1=Preço; 2=Complemento
	EndIf

	SE4->( DbSetOrder( 1 ) )
	If SE4->( DbSeek( xFilial( "SE4" )+ cCondPg ))
		If SE4->E4_TIPO == "9" .and. !lCond
			NN7->( dbSetOrder( 1 ) )
			NN7->( dbSeek( xFilial( "NN7" ) + cCodCtr ) )
			lVencimento := .f.

			While !NN7->( Eof() ) .And. NN7->( NN7_FILIAL + NN7_CODCTR ) == fWxFilial( "NN7" ) + NJR->NJR_CODCTR .And. NN7->NN7_DTVENC >= dEmissao
				lVencimento := .t.
				If Alltrim(SE4->( E4_COND )) = "%"
					lCond := .t.
					aAdd( aCab, {"C5_DATA1", NN7->( NN7_DTVENC ), Nil } )
					aAdd( aCab, {"C5_PARC1", 100.00, Nil } )
				Else
					aAdd( aCab, {"C5_DATA1", NN7->( NN7_DTVENC ), Nil } )
					aAdd( aCab, {"C5_PARC1", nVrtotal, Nil } )
				EndIf
				Exit
			EndDo

			IF !lVencimento
				If Alltrim(SE4->( E4_COND )) = "%"
					lCond := .t.
					aAdd( aCab, {"C5_DATA1", dEmissao, Nil } )
					aAdd( aCab, {"C5_PARC1", 100.00, Nil } )
				Else
					aAdd( aCab, {"C5_DATA1", dEmissao, Nil } )
					aAdd( aCab, {"C5_PARC1", nVrtotal, Nil } )
				EndIf
			EndIf
		EndIf
	EndIf

	aAdd( aCab, { "C5_CONDPAG" , cCondPG, Nil } )

	// -- Verificando Condicao de pagto e Dt. Vencto Cfe OGX008 -- //
	// -- Preparando Itens da Nf -- //

	//-- A Nf. de Compl. de preço sempre será de apenas 1 item, pois a cada item de romaneio se gera uma nota --//
	cItemSeq	:= Soma1(citemSeq)

	// -- ATENÇÃO: Para Nfs. de compl. n. devo informar a Qtidade. -- //

	dBSelectArea('SD2')
	SD2->(dbSetOrder(3) )		//D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	aItens := {}
	// -- Atencao o Tamanho do D1_ITEM É 4 e o D2_ITEM É 2 -- //
	cChave := NJM->(cNfOri + cSeriori ) + cCliente + cLjaCli + cCodPrd
	IF SD2->( dbSeek( FWxFilial( "SD2" )  + cChave ) )
		aLinha := {}
		aAdd( aLinha, { "C6_ITEM"		, Soma1(cItemSeq)	, Nil } )
		aAdd( aLinha, { "C6_PRODUTO"	, SD2->D2_COD		, Nil } )
		aAdd( aLinha, { "C6_PRCVEN"		, nVrTotal			, Nil } )
		aAdd( aLinha, { "C6_VALOR"		, nVrTotal			, Nil } )		
		aAdd( aLinha, { "C6_TES"		, SD2->D2_TES		, Nil } )		
		aAdd( aLinha, { "C6_NFORI"		, SD2->D2_DOC		, Nil } )
		aAdd( aLinha, { "C6_SERIORI"	, SD2->D2_SERIE		, Nil } )
		
		If !_lComplRom
			aAdd( aLinha, { "C6_ITEMORI"	, SD2->D2_ITEM		, Nil } )
			aAdd( aLinha, { "C6_CODROM"		, SD2->D2_CODROM	, Nil } )
			If GetRpoRelease() <= "12.1.017" //rpo 12.1.017 e anteriores
				aAdd( aLinha, { "C6_CTROG"		, SD2->D2_CTROG		, Nil } )
				aAdd( aLinha, { "C6_ITEROM"		, SD2->D2_ITEROM	, Nil } )
				aAdd( aLinha, { "C6_CODSAF"		, SD2->D2_CODSAF	, Nil } )	
			EndIf	
		EndIf

		aAdd( aItens, aLinha )
	
		If !_lComplRom //a partir do rpo 12.1.023 usa tabelas de extensão. Se for complemento não grava, pois irá gravar no romaneio simbólico
				//Criando Vinculo com SC5 / SC6
			aLinhaVinc := {}
			aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 							} )
			aadd( aLinhaVinc, { "N8I_ITEMPV"    	, Soma1(cItemSeq)							} )
			aadd( aLinhaVinc, { "N8I_PRODUT"    	, SD2->D2_COD								} )
			aadd( aLinhaVinc, { "N8I_TPPROD"    	, ''			 							} )
			aadd( aLinhaVinc, { "N8I_CODCTR"    	, cCodCtr 							        } )
			aadd( aLinhaVinc, { "N8I_SAFRA"    		, Posicione('NJJ',1,FWxFilial('NJJ')+cCodRom,'NJJ_CODSAF')} )
			aadd( aLinhaVinc, { "N8I_CODROM"    	, cCodRom									} ) 
			aadd( aLinhaVinc, { "N8I_ITEROM"    	, cIteRom									} )
			aadd( aLinhaVinc, { "N8I_CODOTR"   		, ''										} )
			aadd( aLinhaVinc, { "N8I_ITEOTR"   		, ''										} )
			aadd( aLinhaVinc, { "N8I_CODFIX"    	, cItemFx									} )
			aadd( aLinhaVinc, { "N8I_ORPGRC"   		, '' 										} )	
			aadd( aLinhaVinc, { "N8I_ORIGEM"    	, cPrograma	 							} )
			aAdd( aLinhaVinc, { "N8I_HISTOR"    	, FWI18NLang("OGA430B","STR0019",19)		} )  //Emissão de pv. de complemento de preço
						
			aAdd( aVincITE, aLinhaVinc )
		EndIf
	EndIF
	
	If !_lComplRom //a partir do rpo 12.1.023 usa tabelas de extensão, Se for complemento não grava, pois irá gravar no romaneio simbólico
		// Criando a Tab. de vinculo com Cab PV
		
		aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 								} )
		aadd( aVincCab, { "N8H_NUMPV"    	, '' 											} )  //Irei preencher logo abaixo
		aadd( aVincCab, { "N8H_CODCTR"    	, cCodCtr					 					} )
		aadd( aVincCab, { "N8H_CODROM"    	, cCodRom					 					} )
		aadd( aVincCab, { "N8H_CODFIX"   	, cItemFx										} )
		aadd( aVincCab, { "N8H_CODOTR"   	, ""											} )
		aadd( aVincCab, { "N8H_ORPGRC"   	, ''											} )
		aadd( aVincCab, { "N8H_ORIGEM"   	, cPrograma  									} )
		aAdd( aVincCab, { "N8H_HISTOR"    	, FWI18NLang("OGA430B","STR0019",19)			} ) //Emissão de pv. de complemento de preço
	EndIf	

	// -- Eliminando os arquivos de log dos erros gerados anteriormente -- //
	aArqLogs := Directory("SC*.LOG")
	For nI := 1 to Len(aArqLogs)
		FErase(aArqLogs[nI,1])
	Next nI
	// ------------------------------------------------------------------- //

	// ------Pegando o Nr. do pedido e fazendo Sort no array cfe SX3------	//
	// Add C5_NUM Somente momentos antes do Execauto//
	__cPedVnda := GetSxeNum( "SC5", "C5_NUM" )		
	aAdd( aCab, { "C5_NUM"     , __cPedVnda   , Og430C5NUM() } )
	If GetRpoRelease() >= "12.1.023" //a partir do rpo 12.1.023 usa tabelas de extensão
		IF Len( aVincCab ) > 0 
		   nPosCpo:= ASCAN(aVincCab, {|aVincCab| aVincCab[1] ==  'N8H_NUMPV' })
		   aVincCab[nPosCpo , 2] := __cPedVnda
		EndIF
    EndIf
	aCab 	:= FWVetByDic(aCab	, 'SC5',	.F. )
	aItens := FWVetByDic(aItens	, 'SC6',	.T.	 )
	// ----------------------------------------------------------------- //

	// Ponto de entrada inserido para controlar dados especificos do cliente 22/12/2015
	If ExistBlock("OGA430B1")
		aRetPe := ExecBlock("OGA430B1",.F.,.F.,{aCab,aItens})
		If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
			aCab    := aClone(aRetPe[1])
			aItens  := aClone(aRetPe[2])
		EndIf
	EndIf
	
	/* Necessitamos solicitar o modulo pois alguns campos como LOTE, DTLOTE, NATUREZ
	não estao setados para trabalhar com o SIGAAGR */
	cModulo := "FAT" 
	nModulo := 5
	//-- Gerando  a NF. de Complemento de Preço --//
	MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aCab, aItens, 3)
	//Retornando o modulo do SIGAAGR
	cModulo := cModAtu
	nModulo := nModAtu

	If lMsErroAuto
		ROLLBACKSX8()		
		cDescErro := sfAchaErro()	//-- Busca o Log de Erro do Exec. Auto, cDescErro foi Passada como Ponteiro -- //
		lOk := .f.
	Else
		ConfirmSX8()
		If GetRpoRelease() >= "12.1.023" .and. len(aVincCab) > 0 //a partir do rpo 12.1.023 usa tabelas de extensão
			// -- Funçao do AGRXFUN1 --//
			fAgrVncPV (aVincCab,aVincITE  , 3)  //Incluir
		EndIf
		aGerouDoc :={}
		aGerouDoc := AgrGeraNFS( __cPedVnda, __cSeriSF2 )			//Gera Docto Fiscal
		If  ( ValType(aGerouDoc) == "A" .And. Len(aGerouDoc) > 0 )
			cNfGerada := aGerouDoc[1]
			cSerie	:=  aGerouDoc[2]
			// Buscando o Vr. do Imposto da Nf Gerada
			nVrImpCpl := fImpCplto(SF2->F2_DOC,cSerie,cCliente,cLjaCli)   // Abastece Variavel veio compo Ponteiro
			lok := .t.
		Else
			LoK := .F.
		EndIF
	Endif

	RestArea( aAreaNNC )
	RestArea( aAreaSC5 )
	RestArea( aAreaSC6 )
	RestArea( aAreaSD2 )
	RestArea( aAreaSF2 )
	RestArea( aAreaSE1 )
	RestArea( aAreaAtu )


Return( lOk )


/** {Protheus.doc} fNfCplCpra
Gerar NF de Complemento de preço

@param: 	nRecnoNNC ->	Recno da Tab. NNC a Gerar a Nf. de Complemento
nVrUnFixdo->	Vr. Unitario da Fixação
cSerie		->	Serie do Dcto fiscal
cDescErro	-> Var Passada via Ponteiro que será abastecida com erro do ExecAuto Caso Ocorra
cNfGerada	-> Var Passada via Ponteiro que será abastecida com o Nr. da Nf Emitida
@return:	lOK - .t. ou .f.
@author: 	Emerson Coelho
@since: 	28/01/2015
@Uso: 		SIGAAGR
*/
Static Function fNfCplCpra( nRecnoNNC, cSerieAux, cTes, nVrtotal, cDescErro, cNfGerada,nVrImpCpl )
	//-- Var de Retorno  e Controle do Fluxo--//
	Local lOk			:= .t.
	Local nI			:= 0

	// -- Salvando Posição das Aread de Trabalho -- //
	Local aAreaAtu		:= GetArea()
	Local aAreaSF1 		:= SF1->(GetArea())
	Local aAreaSD1		:= SD1->(GetArea())
	Local aAreaSE2		:= SE2->(GetArea())
	Local aAreaNNC		:= NNC->(GetArea())

	// -- Vars ExecAuto -- //
	Local aCab 			:= {}
	Local aItens 		:= {}
	Local aLinha		:= {}

	//-- Variaveis do Cabeçalho do Documento de Entrada --//
	Local cFormProp		:= "S"	//-- É formulário proprio --//
	Local cTipo			:= "C"	//-- Complemento de Preço --//
	Local cFornece		:= ""
	Local cLojafor		:= ""
	Local cUF			:= ""
	Local cEspecie		:= "SPED"
	Local cNumeroAux	:= CriaVar("F1_DOC",.f.)
	Local cE2_prefix 	:= Criavar("E2_PREFIXO",.f.)
	Local cE2_Num	 	:= Criavar("E2_NUM",.f.)

	//-- Variaveis dos Itens do Documento de Entrada --/
	Local cLocal		:= ""

	//-- Vars. Ctrole ExecAuto -- //
	Private lMsHelpAuto := .t.  	// se .t. direciona as mensagens de help
	Private lMsErroAuto := .f. 		//necessario a criacao, pois sera

	/*Chamado TSJVFB*/
	Private cOGUBS_NF	:= fAgrtpnf(Nil)	

	//------------------------------ Fim Declaração das Variaveis -----------------------------//

	//--Posicionando no Registro que Tem q ser Emitido nf de Compl.
	NNC->( DbGoTo( nRecnoNNC ) )

	//-- Lendo os itens do Romaneio ---//
	NJM->( dbSetOrder( 1 ) )	//NJM_FILIAL+NJM_CODROM+NJM_ITEROM
	NJM->( dbSeek( fWxFilial( 'NJM' ) + NNC->NNC_CODROM + NNC->NNC_ITEROM ) )

	//-- Buscando o Fornecedor no Cadastro de Entidade --//
	cFornece	:= Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),	"NJ0_CODFOR"	)	// Cod Forn. Origem
	cLojafor	:= Posicione("NJ0",1,FwxFilial("NJ0") + NJM->(NJM_CODENT + NJM_LOJENT),	"NJ0_LOJFOR"	)	// Loja Forn. Orige
	cUF			:= Posicione("SA2",1,FwxFilial("SA2") + cFornece + cLojafor, "A2_EST"	)	// Unid Federativa

	//-- Buscando Infs. Sobre o Codigo da Safra -- //
	cCodSaf	:= NJM->NJM_CODSAF

	//-- Encontrado os Dados do docto de Origem --//
	cNfOri		:= NNC->NNC_NUMDOC
	cSeriori	:= NNC->NNC_SERDOC
	cItemOri	:= Soma1(Strzero( 0, TamSX3( "D1_ITEMORI" )[1] ) ) //-- Como Cada Item do Rom Gera uma Nf de Entrada , Sempre Será o item '0001' --//

	//--Encontrando o prefixo do tit. da nf. original idx 1= F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	cE2_Prefix	:= Posicione("SF1",1,FwxFilial("SF1") + cNfOri + cSeriOri + cFornece + cLojaFor + 'N',	"F1_PREFIXO"	)	// Retorna o Prefixo do Tit. Original
	cE2_Num	:= Posicione("SF1",1,FwxFilial("SF1") + cNfOri + cSeriOri + cFornece + cLojaFor + 'N',	"F1_DUPL"	)	// Retorna o Prefixo do Tit. Original

	//--Buscando o 1o. ou unico tit.originado pela nf. de origem--//
	nRecTitOrg := fGetTitOrg(cE2_Prefix, cE2_Num, cFornece,cLojafor)
	SE2->( DbGoto( nRecTitOrg ))
	cnatFin 	:= SE2->E2_NATUREZ
	cCCusto	:= SE2->E2_CCD
	dVencto	:= SE2->E2_VENCTO

	If ! Len(cSerieAux) = TamSx3('F1_SERIE')[1]
		cSerieAux := PadR(Alltrim(cSerieAux),TamSx3('F1_SERIE')[1] )
	EndIf	

	If GetNewPar("MV_TPNRNFS","1") $ "1" .and. Empty(cNumeroAux)  
		cNumeroAux := NxtSX5Nota(cSerieAux)
	EndIf

	//-- Monta o cabecalho --//
	aAdd( aCab, { "F1_TIPO"		, cTipo 				} )
	aAdd( aCab, { "F1_FORMUL"	, cFormProp				} )
	aAdd( aCab, { "F1_SERIE"  	, cSerieAux				} )
	aAdd( aCab, { "F1_DOC"		, cNumeroAux			} )
	aAdd( aCab, { "F1_EMISSAO"	, dDataBase				} )
	aAdd( aCab, { "F1_FORNECE"	, cFornece				} )
	aAdd( aCab, { "F1_LOJA"		, cLojafor				} )
	aAdd( aCab, { "F1_ESPECIE"	, cEspecie				} )
	aAdd( aCab, { "F1_CODROM"	, NNC->NNC_CODROM		} )
	aAdd( aCab, { "F1_COND"		, __CPgtoSF1			} )
	aAdd( aCab, { "F1_EST"		, cUF					} )
	//aAdd( aCab, { "E2_CTROG"	, NNC->NNC_CODCTR		} )
	//aAdd( aCab, { "E2_CODSAF"	, cCodSaf				} )
	IF !Empty( cNatFin )
		aAdd( aCab, { "E2_NATUREZ"	, cNatFin			} )
		aAdd( aCab, { "E2_VENCTO"	, dVencto			} )
	ENDif

	aCab := FWVetByDic(aCab, 'SF1') //--< Ordena o array de acordo com o sx3>>---

	//-- A Nf. de Compl. de preço sempre será de apenas 1 item, pois a cada item de romaneio se gera uma nota --//
	cLocal		:= NJM->NJM_LOCAL
	//cItemSeq 	:= StrZero( Val( '0' ), TamSX3( "D1_ITEM" )[1] )
	//cItemSeq	:= Soma1(citemSeq)

	//-- ATENÇÃO: Para Nfs. de compl. n. devo informar o Vr. Unitario e nem a Qtidade. --//
	aLinha := {}
	//aAdd( aLinha, { "D1_ITEM"	,	cItemSeq		,	Nil } )
	aAdd( aLinha, { "D1_COD"	,	NJM->NJM_CODPRO	,	Nil } )
	aAdd( aLinha, { "D1_DOC"    ,   cNumeroAux      ,   Nil } )
	//aAdd( aLinha, { "D1_QUANT", 	0				,	Nil } )
	aAdd( aLinha, { "D1_VUNIT",		nVrTotal		, 	Nil } )
	aAdd( aLinha, { "D1_TOTAL"	, 	nVrtotal		,	Nil } )
	aAdd( aLinha, { "D1_LOCAL"	,	cLocal			,	Nil } )
	aAdd( aLinha, { "D1_TES"	,	cTes			,	Nil } )
	aAdd( aLinha, { "D1_CODSAF"	, 	cCodSaf			,	Nil } )
	aAdd( aLinha, { "D1_CTROG"	, 	NNC->NNC_CODCTR	,	Nil } )
	aAdd( aLinha, { "D1_CODROM"	, 	NNC->NNC_CODROM	,	Nil } )
	aAdd( aLinha, { "D1_ITEROM"	, 	NNC->NNC_ITEROM	,	Nil } )
	aAdd( aLinha, { "D1_CC"		,   cCCusto			,	Nil } )
	//-- Por se Tratar de Nf. de Compl. Preço é Preciso Informar os Dados do docto de Origem Abaixo --//
	aAdd( aLinha, { "D1_NFORI"	, 	cNfOri			,	Nil } )
	aAdd( aLinha, { "D1_SERIORI",	cSeriOri		,	Nil } )
	aAdd( aLinha, { "D1_ITEMORI",	cItemOri		,	Nil } )

	aAdd( aItens, aLinha )

	aItens := FWVetByDic(aItens, 'SD1',.T.)

	// -- Eliminando os arquivos de log dos erros gerados anteriormente -- //
	aArqLogs := Directory("SC*.LOG")
	For nI := 1 to Len(aArqLogs)
		FErase(aArqLogs[nI,1])
	Next nI
	// ------------------------------------------------------------------- //

	// Ponto de entrada inserido para controlar dados especificos do cliente
	If ExistBlock("OGA430B2")
		aRetPe := ExecBlock("OGA430B2",.F.,.F.,{aCab,aItens})
		If ValType(aRetPe) == "A" .And. Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
			aCab    := aClone(aRetPe[1])
			aItens  := aClone(aRetPe[2])
		EndIf
	EndIf

	//-- Gerando  a NF. de Complemento de Preço --//
	MSExecAuto( { | x, y, z | Mata103( x, y, z ) }, aCab, aItens, 3 )

	If lMsErroAuto
		cDescErro := sfAchaErro()	//-- Busca o Log de Erro do Exec. Auto, cDescErro foi Passada como Ponteiro -- //
		lOk := .f.
	Else
		cNfGerada := SF1->F1_DOC
		lok := .t.

		nVrImpCpl := fImpCplto(SF1->F1_DOC,cSerieAux,cFornece,cLojafor)   // Variavel veio compo Ponteiro
	Endif

	RestArea( aAreaNNC )
	RestArea( aAreaSE2 )
	RestArea( aAreaSD1 )
	RestArea( aAreaSF1 )
	RestArea( aAreaAtu )

	Return( lOk )


	/*/{Protheus.doc} fGerNFCpl( cSerie, cTES, aNFGeradas, cFiltro )
	Rotina que prepara os Romaneios selecionados para emitir O
	docto de complemento.

	@param        	cTes			-> Tes da Nf. de Complemento
	@aNFGeradas 	-> Referencia a Array Vazio para abastecer as Nfs q foram geradas
	cFiltro			-> A Aplicar na tabela de romaneios vinculados a fixação

	@return    	ExpL    Verdadeiro / Falso
	@author    	Emerson coelho
	@since      	27/01/2015
	@version    	P11
	/*/
Static Function fGerNFCpl(cTES, aNFGeradas,  cFiltro )
	Local cShowMens  	:=	''
	Local cSerie		:= Criavar ('F1_SERIE', .F.)
	Local cNfGerada		:= CriaVar('F1_DOC', .F.)
	Local cMensErro		:=	''
	Local nVrImpCpl 	:=	0
	Local cEOL     		:= Chr(13)+Chr(10) //--End of Line--//
	Local lGerouNf		:= .t.
	Local nVrUn			:= 0
	Local nVRCPLORIG	:= 0
	Local nNNCVLFIXB	:= 0
	Local nVrComplem	:= 0
	Local cSavFiltro	:= NNC->( dbfilter() )	
	Local aAreaAux		
	Local lExit         := .F.
	Local lAjFino       := SuperGetMv('MV_AGRO208', , .F.)// valida se o calculo de complemento entra na função fAJUSTACPL

	ProcRegua(0)

	// -- Filtrando o Arquivo Para Pegar Somentes os Registros Marcados --
	NNC->( DBSetFilter ( {|| &cFiltro}, cFiltro) )    // Filtra somente Registros selecionados e da Filial Corrente
	NNC->( dbGoTop() )

	While NNC->( !eof() ) .AND. (!lExit)
		Incproc(OemToAnsi( STR0011 ) + NNC->NNC_CODROM + '/' + NNC->NNC_ITEROM ) //#"Processando Romaneio: "

		/*-- Encontrado o Vr. da NF. de Compl. de preço
		1-> Equaliza o Vr. un. Fixado para a Un. med. de Peso
		2-> Encontra o Vr. Un. da nf. de compl = ( Vr.un.da fixacao em Un. de peso - Vr. un. da nf. do romaneio )
		*/

		// Calculo Novo
		nVrUn :=  A410Arred(  NN8->NN8_VLRUNI  / AGRX001( NJR->NJR_UMPRC , NJR->NJR_UM1PRO, 1, NJR->NJR_CODPRO  ) , "NKC_VRUN") - NNC->NNC_DOCVUN

		nVRCPLORIG	:= 0
		nNNCVLFIXB	:= 0
		nVRCPLORIG  := NNC->NNC_VLFIXB - (NNC->NNC_VRENPF + NNC->NNC_VLCMPL)
		nVrComplem	:= nVRCPLORIG
   
        If lAjFino
		   nVrComplem	:=  fAJUSTACPL( nVRCPLORIG )    //Rotina q Verifica se temos q Fazer Ajuste de vr. na NV de Compl devido a dif de calculos
		EndIf
		IF ! nVrComplem =  nVRCPLORIG   // Se o Vr. da Nf. de complemento n. for igual ao q passamos
			nNNCVLFIXB		:=  NNC->NNC_VRENPF + nVrComplem
		EndIF
		nVrImpCPL := 0
		//Fim Calculo Novo

		lCtrVnd	:= IIF( Posicione( "NJR", 1, xFilial( "NJR" ) + NN8->NN8_CODCTR, "NJR_TIPO" ) == '1', .t., .f. ) //1 Cpra , 2 Venda
		cCodEnt := Posicione( "NJR", 1, xFilial( "NJR" ) + NN8->NN8_CODCTR, "NJR_CODENT" )
		cFilEnt := Posicione( "NJR", 1, xFilial( "NJR" ) + NN8->NN8_CODCTR, "NJR_LOJENT" )

		If lCtrVnd 	//1 Cpra  
			_cForCli := Posicione( "NJ0", 1, xFilial( "NJ0" ) + cCodEnt + cFilEnt, "NJ0_CODFOR" )		//Cliente/Fornecedor - Código
			_cLjClFo := Posicione( "NJ0", 1, xFilial( "NJ0" ) + cCodEnt + cFilEnt, "NJ0_LOJFOR" ) 		//Cliente/Fornecedor - Loja
		ElseIf  .not. lCtrVnd 		//2 Venda
			_cForCli := Posicione( "NJ0", 1, xFilial( "NJ0" ) + cCodEnt + cFilEnt, "NJ0_CODCLI" )		//Cliente/Fornecedor - Código
			_cLjClFo := Posicione( "NJ0", 1, xFilial( "NJ0" ) + cCodEnt + cFilEnt, "NJ0_LOJCLI" ) 		//Cliente/Fornecedor - Loja
		EndIf 

		BEGIN TRANSACTION
			cMensErro	:=''
			IF  __lCtrVnd   //-Ctrato de Venda
				__cPedVnda	:= ''
				cNfGerada	:= ''
				cSerie		:= __cSeriSF2
				lGerouNf := OGA430BNfCplV( NNC->(Recno() ),nVrComplem, @cMensErro,@cSerie,@cNfGerada,@nVrImpCPL )
			Else				//-Ctrato de Compra
				cSerie := __cSeriSF1
				lGerouNf  := fNFCplCpra( NNC->(Recno() ), cSerie, cTes,  nVrComplem, @cMensErro,@cNfGerada,@nVrImpCPL)
			EndIF

			IF lGerouNf
				//-- Gravando NKC ---

				Reclock('NKC',.T. )
				NKC->NKC_FILIAL	:= fWxFilial('NKC')
				NKC->NKC_CODCTR	:= NNC->NNC_CODCTR
				NKC->NKC_ITEMFX	:= NNC->NNC_ITEMFX
				NKC->NKC_CODROM	:= NNC->NNC_CODROM
				NKC->NKC_ITEROM	:= NNC->NNC_ITEROM
				NKC->NKC_ITEM	:=  fNextNKCIt( NNC->NNC_CODCTR, NNC->NNC_ITEMFX, NNC->NNC_CODROM, NNC->NNC_ITEROM )
				NKC->NKC_SERIE	:=  cSerie
				NKC->NKC_DOCTO	:=  cNfGerada
				NKC->NKC_PREFIX	:= 'NF'
				NKC->NKC_FORMUL	:= 'S'
				NKC->NKC_QTD	:= NNC->NNC_QTDENT
				NKC->NKC_VRUN	:= nVrUn
				NKC->NKC_VRTOT	:= nVrComplem
				NKC->NKC_VRIMP  := nVrImpCPL
				NKC->NKC_DATA	:= dDataBase
				NKC->NKC_TPDOC	:= IIF(__lCtrVnd,'2'			,'1'	)	//-- Nf. de Complemento de Preço Saida/Entrada 	--//
				NKC->NKC_PEDIDO	:= IIF(__lCtrVnd,__cPedVnda		,''		)	//-- Para Ctr.Venda Grava o nr. do Pedido 		--//
				NKC->NKC_FORCLI := _cForCli
				NKC->NKC_LOJA   := _cLjClFo			
				NKC->( MsUnLock() )

				// -- Atualiza o Arquivo NNC (Entregas da Fixação)-- //
				aAreaAux := NNC->(GetArea())	//Protegendo Area Atual da Tabela NNC
				Reclock("NNC",.f. )
				NNC->NNC_VLCMPL += nVrComplem
				NNC->NNC_VLIMPC += nVrImpCPL
				NNC->NNC_VLFBAJ := nNNCVLFIXB   // Contem o Vr. da Nf. de fixação q ficou diferente do calculado pela NNC, no intuito de sempre ter o vr. liq. da fix. no financeiro
				NNC->NNC_STATUS := ''
				NNC->NNC_OK		:= ''
				//Atualiza o status de forma centralizada
				NNC->NNC_STATUS := OG430STAT(  ) //'4' 				//-- Nf. Cpl. Emitida --//

				NNC->( MsUnlock() )
				RestArea( aAreaAux )			//Retaurando Area Da Tabela NNC
				// -- Atualiza o Arquivo NNC (Entregas da Fixação)-- //
				//-- fim Atualiza Arq. Temporario --//

				//-- Alimenta Array c. as Nfs. Geradas --//
				aAdd(aNFGeradas,			{;
				/*1 = Romaneio + Item 	*/	NNC->NNC_CODROM + '/' + NNC->NNC_ITEROM,;
				/*2= Nf.Nr + Serie		*/	cNfGerada + cSerie,;
				/*3=Valor				*/	Transform(nVrComplem, PESQPICT("NKC","NKC_VRTOT")) })

			Else //-- Qdo Ocorreu erro no Execauto a cMensErro volta com o Erro Capturado --//
				DisarmTransaction()
				cShowMens := ''
				cShowMens := STR0012 + NNC->NNC_CODROM + '/' + NNC->NNC_ITEROM // #Não foi possivel gerar Docto Fiscal de Complemento Para o item de romaneio:
				cShowMens += " "  + cEOL
				cShowMens += " "  + cEOL
				cShowMens += cMensErro //-- cMensErro está com o Erro do ExecAuto Capturado, por Linhas ( Estilo Memo ) --//
				//EasyHelp( cShowMens )
				Aviso(STR0010,cShowmens,{'OK'},3) //#'Aviso'
				lExit := .T.
			EndIF

		END TRANSACTION
		NNC->( dbSkip() )
	Enddo

	NNC->( DBClearFilter() )	//Retirando o Filtro
	IF !Empty(cSavFiltro)		
		NNC->( DBSetFilter ( {|| &cSavFiltro}, cSavFiltro) )  // Retorna o filtro Inicial
	EndIF

	NNC->( dbGoTop() )

Return ( aNfGeradas )
