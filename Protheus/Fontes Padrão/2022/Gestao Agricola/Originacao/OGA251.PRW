#INCLUDE "OGA251.ch"
#INCLUDE "protheus.ch"
#INCLUDE "fwmvcdef.ch"

Static __aTab1221   := {"N83"} //tabelas SLC - previsão liberação 1220
Static __lLib1221   := .F. //Proteção de fonte para liberação 12.20 SLC
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
	
/** {Protheus.doc} OGA251
Rotina de Romaneio Simbólico.
@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	24/04/2015
@Uso: 		SIGAAGR
*/
Function OGA251( cAlias, nReg, nAcao )
	Local bTeclaF11 	:= SetKey( VK_F11, { || aIniPad := OGA250INIT( .t. ) } )
	Private oBrowseNJJ	:= Nil
	Private aIniPad		:= OGA250INIT( .f. )
	Private aMtzDes		:= { { "", "" }, { "", "" }, { "", "" } }
	Private aVetNK4     := {}
	Private lTemNFTrans := .F.
	Private lF10Exec    := .T.
	Private nDecPeso	:= SuperGetMV("MV_OGDECPS",,0)
	Private cPicPeso	:= SuperGetMV("MV_OGPICPS",,"@E 999,999,999")	
	Private aFardRom  := {}	
	Private _lAltIE		:= .F. //OGA250 usa	
	Private _lVincFard  := .F.	
	Private _cCLTTEMP //Cria a Temp Table de Consulta de Ordem de Colheita

	__lLib1221 := AGRTABDIC(__aTab1221) //verifica se array de tabelas existe no dicionario de dados - para proteção fonte SLC
	
	If !SuperGetMv("MV_AGRORI",,.F.) .OR. !SuperGetMv("MV_SIGAAGR",,.F.)  
		Agrhelp(STR0034,STR0065,STR0066)//"Para acessar a rotina de Romaneios do modulo Agroindústria é necessários ativar os parâmetros MV_AGRORI e MV_SIGAAGR"
		Return
	EndIf

	If _cCLTTEMP == Nil .And. FWHasEAI( "AGRA530", .T., .F., .T. )
		_cCLTTEMP := AGRA530TTO(@_cCLTTEMP) //AGRA530TTO
	EndIf

	oBrowseNJJ := FWMBrowse():New()
	oBrowseNJJ:SetAlias( "NJJ" )
	oBrowseNJJ:SetDescription( STR0001 ) //"Romaneios Simbólicos"
	oBrowseNJJ:SetMenuDef( "OGA251" )

	oBrowseNJJ:AddLegend( "NJJ_STATUS=='0'", "RED"		, X3CboxDesc( "NJJ_STATUS", "0" ) ) //"Pendente"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='1'", "YELLOW"	, X3CboxDesc( "NJJ_STATUS", "1" ) ) //"Completo"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='2'", "ORANGE"	, X3CboxDesc( "NJJ_STATUS", "2" ) ) //"Atualizado"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='3'", "GREEN"	, X3CboxDesc( "NJJ_STATUS", "3" ) ) //"Encerrado"
	oBrowseNJJ:AddLegend( "NJJ_STATUS=='4'", "BLACK"	, X3CboxDesc( "NJJ_STATUS", "4" ) ) //"Cancelado"

	oBrowseNJJ:aColumns[1]:cTitle := "Sts.Rom."
	
	bColor02 := { || Iif(NJJ->NJJ_LIBQLD=='0','BR_CINZA', Iif(NJJ->NJJ_LIBQLD=='1','BR_VERDE', Iif(NJJ->NJJ_LIBQLD=='2','BR_VERMELHO', 'BR_CINZA')))}
    ADD STATUSCOLUMN oColumn DATA bColor02 DOUBLECLICK { |oBrowseNJJ| OGA250Leg() }  OF oBrowseNJJ
	
	oBrowseNJJ:aColumns[2]:cTitle := "Par.Qld."
		
	oBrowseNJJ:SetFilterDefault("NJJ_TIPENT $ '2|3'") //0=Físico;1=Gerencial;2=Simbolico;3=Retenção	
		
	oBrowseNJJ:DisableDetails()
	oBrowseNJJ:Activate()

	SetKey( VK_F11, bTeclaF11 )
	
//	OGA250NF( Alias(), Recno(), 4, .t. )
	oBrowseNJJ:DeActivate()
Return( )

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Marlon Richard Trettin
@since: 	24/04/2015
@Uso: 		SIGAAGR
*/
Static Function MenuDef()
	Local aRotina := {}
    Local nx      := 0
    
	aAdd( aRotina, { STR0002	   , "PesqBrw"							, 0, 1, 0, .t. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003		, "OGA250Visual()"					, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004		, "OGA251Inclu()"					, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005		, "OGA251Alter()" 					, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006		, "OGA250ATUC()"					, 0, 4, 0, Nil } ) //"Atualizar"
	aAdd( aRotina, { STR0007	 	, "OGA250NF()"						, 0, 4, 0, Nil } ) //"Confirmar"	
	aAdd( aRotina, { STR0008		, "OGA250REA()"						, 0, 4, 0, Nil } ) //"Reabrir"
	aAdd( aRotina, { STR0009		, "OGA250CAN()"						, 0, 4, 0, Nil } ) //"Cancelar"
	aAdd( aRotina, { STR0010		, "OGA251Exclu()"					, 0, 5, 0, Nil } ) //"Excluir"
	aAdd( aRotina, { STR0011    	, "AGRCONHECIM('NJJ')"              , 0, 4, 0, Nil } ) //"Conhecimento"
	aAdd( aRotina, { STR0012		, "OGR250()"						, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0014		, "OGA251Simb()" 					, 0, 3, 0, Nil } ) //"Gerar pela NF"
	aAdd( aRotina, { STR0015		, "OGA250HIS"						, 0, 7, 0, Nil } ) //"Histórico"
	aAdd( aRotina, { STR0059		, "OGASPED()"  						, 0, 4, 0, Nil } ) //"Sped.NfE"
	aAdd( aRotina, { STR0060		, "OGA250ANA"						, 0, 4, 0, Nil } ) //"Insp.Analise"
    If __lLib1221
		aAdd( aRotina, { STR0062	, "AGRX500FAR()"  , 0, 4, 0, .F. } ) //"Vincular Fardos"			
		aAdd( aRotina, { "Registro de Entrega"	, "OGA250REG(NJJ->NJJ_FILIAL, NJJ->NJJ_CODROM)"	   , 0, 4, 0, .F. } ) //"Registro de Entrega"
	EndIf	
   
   If ExistBlock('OG251MNU')
        aRetM := ExecBlock('OG251MNU',.F.,.F.)
        If Type("aRetM") == 'A'
            For nx := 1 To Len(aRetM)
            Aadd(aRotina,aRetM[nx])
            Next nx 
        EndIf
    EndIf 
Return( aRotina )

/** {Protheus.doc} OGA251Inclu
Função para inclusão de Romaneio Simbólico

@author: 	Marlon Richard Trettin
@since: 	24/04/2015
@Uso: 		SIGAAGR
*/
Function OGA251Inclu()
	Local xRet 
	//			FWExecView([ cTitulo ], <cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
	xRet := 	FWExecView( STR0016, "OGA250", MODEL_OPERATION_INSERT ) 	//"Simbólico - Inclusão"
Return xRet

/** {Protheus.doc} OGA251Alter
Função para alteração de Romaneio Simbólico

@author: 	Marlon Richard Trettin
@since: 	24/04/2015
@Uso: 		SIGAAGR
*/
Function OGA251Alter()
	Local xRet
	Local aAreaAtu  := GetArea()
	Local cRetorno	:= "0"
	Local lExistN9E := .F.
	
	if TableInDic('N9E')
		cRetorno := RetOrigRom(xFilial('N9E'), NJJ->NJJ_CODROM)
		lExistN9E := .T.
	endIf
		
	If (cRetorno $ "1,2" .OR. (cRetorno == "7" .AND. NJJ->NJJ_TPFORM == "1" .AND. NJJ->NJJ_TIPO = '7' )) .AND. lExistN9E 
	
		If cRetorno $ "1,2"
			Help(" ",1,".OGA250000002.")
			Return .F.
		Else
			MsgAlert(STR0063, STR0064)
			Return .F.
		EndIf		
	Else 		
		xRet := 	FWExecView( STR0017, "OGA250", MODEL_OPERATION_UPDATE ) 	//"Simbólico - Alteração"	
	EndIf
	
	RestArea( aAreaAtu )

Return xRet

/** {Protheus.doc} RetOrigRom
Retornar a origem do romaneio (N9E_ORIGEM)

@return: Nil
@author: Thiago Henrique Rover
@since:  27/02/2018
@Uso: 	 OGA250 - Romaneio
*/
Static Function RetOrigRom(cFilRom, cCodRom)
	
	Local cOrigem := ""

	// Verifica a origem do romaneio
	cAliasQry := GetNextAlias()
	cQuery := " SELECT N9E_ORIGEM"
	cQuery += " FROM " + RetSqlName("N9E") + " N9E "
	cQuery += " WHERE N9E_FILIAL = '" +cFilRom+"'"
	cQuery += "   AND N9E_CODROM = '" +cCodRom+"'"
	cQuery += "   AND D_E_L_E_T_ = '' "
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.) 
	If !(cAliasQry)->(Eof())
		cOrigem := (cAliasQry)->N9E_ORIGEM
	EndIf
	(cAliasQry)->(dbCloseArea())
	
Return cOrigem

/** {Protheus.doc} OGA251Exclu
Função para exclusão de Romaneio Simbólico

@author: 	Marlon Richard Trettin
@since: 	24/04/2015
@Uso: 		SIGAAGR
*/
Function OGA251Exclu()
	Local xRet 
	//			FWExecView([ cTitulo ], <cPrograma >, [ nOperation ], [ oDlg ], [ bCloseOnOK ], [ bOk ], [ nPercReducao ], [ aEnableButtons ], [ bCancel ], [ cOperatId ], [ cToolBar ], [ oModelAct ])-> nValor
	xRet := 	FWExecView( STR0018, "OGA250", MODEL_OPERATION_DELETE ) 	//"Simbólico - Exclusão"
Return xRet

/** {Protheus.doc} OGA251Simb
Abre a tela de parametros e de seleção da NF para geração automatica do Romaneio Simbólico

@param: 	Nil
@author: 	Marlon Richard Trettin
@since: 	22/04/2015
@Uso: 		SIGAAGR
*/
Function OGA251Simb()
	Local cPerg := "OGA251SIMB"
	
	// Abre a tela de parametros 
	If .Not. Pergunte( cPerg, .T., STR0019 ) //"Geracao de Romaneio Simbolico"
		Return( NIL ) 
	EndIf
	AGRGRAVAHIS(STR0019,"NJJ",NJJ->NJJ_FILIAL+NJJ->NJJ_CODROM,"N")
	
	// Gera o romaneio simbólico a partir da NF
				// NJJ_TIPO, NJJ_CODENT, NJJ_LOJENT, NJJ_DOCSER, NJJ_DOCNUM
	OGA251GSimb( MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06 )
Return( NIL )

/** {Protheus.doc} OGA251GSimb
Gera o romaneio simbólico de acordo com os parâmetros

@param: 	pcTipo		Tipo do romaneio
@param: 	pcCodEnt	Código da Entidade
@param: 	pcLojEnt	Loja da Entidade
@param: 	pcDocSer	Série da NF
@param: 	pcDocNum 	Número da NF
@param: 	pcCodCtr 	Contrato 
@return:	.T. / .F. 
@author: 	Marlon Richard Trettin
@since: 	26/04/2015
@Uso: 		SIGAAGR
@type function
*/
Function OGA251GSimb( pcTipo, pcCodEnt, pcLojEnt, pcDocSer, pcDocNum, pcCodCtr, cProduto, cItem, cRomOrg )
	Local aAreaAtu  := GetArea()
	Local lRetorno	:= .F.
	Local lRetPE	:= .T.
	Local aSays 	:= {}
	Local aButtons	:= {}
	
	Private cAliasCab 	:= ""
	Private cPrefCab 		:= ""
	Private cAliasIte 	:= ""
	Private cPrefIte		:= ""
	Private cChavePesq	:= ""
	Private cChaveIndi	:= ""
	Private lEntrada		:= .T.

	Default _lComplRom  := .F.
	Default cItem       := ""
	Default cProduto    := ""
    Default cRomOrg     := ""
	
	///////////////////////////////////////
	// Posiciona na Nota Fiscal de Entrada ou Saída e no cadastro de Entidades
	///////////////////////////////////////
	If ! fPosicNF( pcTipo, pcCodEnt, pcLojEnt, pcDocNum, pcDocSer )
		RestArea( aAreaAtu )
		Return( .F. )
	EndIf
	
	///////////////////////////////////////
	// Posiciona no Contrato
	///////////////////////////////////////
	NJR->( dbSetOrder( 1 ) )
	If ! NJR->( dbSeek( FWxFilial( "NJR" ) + pcCodCtr ) )
		Help(, , STR0034, , STR0046 + Chr(10) + Chr(13) + "[ " + pcCodCtr + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar o Contrato no cadastro de Contratos (NJR)."	   
		RestArea( aAreaAtu )
		Return( .F. )
	EndIf
	
	// Se tipo do contrato for incompatível com tipo do romaneio
	If NJR->( NJR_TIPO ) <> OGX010TC( pcTipo )  
		Help(, , STR0034, , STR0047 + "[ " + X3CboxDesc( "NJR_TIPO", NJR->( NJR_TIPO ) ) + " ]", 1, 0 ) //"AJUDA"###"O -Contrato- informado não pode ser utilizado neste romaneio, pois é um contrato do tipo "
		RestArea( aAreaAtu )
		Return( .F. )
	EndIf
	
	If ExistBlock("OGA251R1")
		lRetPE := ExecBlock( "OGA251R1",.F.,.F.,{NJR->NJR_CODENT, NJR->NJR_LOJENT, pcCodEnt, pcLojEnt})
		If ValType(lRetPE) != "L"
			Help(, , STR0034, , STR0048 + Chr(10) + Chr(13) + "[ " + NJR->( NJR_CODENT ) +" / " + NJR->( NJR_LOJENT ) + " ]", 1, 0 ) //"AJUDA"###"O -Contrato- informado pertence a outra Entidade / Loja."
			lRetPE := .F.			
		EndIf
		
		IF !lRetPE
			RestArea( aAreaAtu )
			Return( .F. )
		EndIF
	Else
		// Se o contrato pertence a outra entidade
		If NJR->( NJR_CODENT + NJR_LOJENT ) <> pcCodEnt + pcLojEnt
			Help(, , STR0034, , STR0048 + Chr(10) + Chr(13) + "[ " + NJR->( NJR_CODENT ) +" / " + NJR->( NJR_LOJENT ) + " ]", 1, 0 ) //"AJUDA"###"O -Contrato- informado pertence a outra Entidade / Loja."
			RestArea( aAreaAtu )
			Return( .F. )
		EndIf
	EndIf
	
	///////////////////////////////////////
	// Posiciona no Item da Nota Fiscal
	///////////////////////////////////////
	
	If pcTipo $ "3|5|7|9" 	// Se for Romaneio de ENTRADA
		
		lEntrada	:= .T.
		cAliasCab 	:= "SF1"
		cPrefCab 	:= "F1"
		cAliasIte 	:= "SD1"
		cPrefIte	:= "D1"
		cChavePesq	:= xFilial( "SD1" ) + pcDocNum + pcDocSer + SF1->F1_FORNECE + SF1->F1_LOJA + cProduto + cItem
		cChaveIndi	:= "SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA"
		
		If !Empty(cProduto)
			cChaveIndi += " + SD1->D1_COD"
		EndIf

		If !Empty(cItem)
			cChaveIndi += " + SD1->D1_ITEM"
		EndIf

		SD1->( DbSetOrder( 1 ) ) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		
	Else 						// Se for Romaneio de SAIDA
		
		lEntrada	:= .F.
		cAliasCab 	:= "SF2"
		cPrefCab 	:= "F2"
		cAliasIte 	:= "SD2"
		cPrefIte	:= "D2"
		cChavePesq	:= xFilial( "SD2" ) + pcDocNum + pcDocSer + SF2->F2_CLIENTE + SF2->F2_LOJA + cProduto + cItem
		cChaveIndi	:= "SD2->D2_FILIAL + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA"
		
		If !Empty(cProduto)
			cChaveIndi += " + SD2->D2_COD"
		EndIf

		If !Empty(cItem)
			cChaveIndi += " + SD2->D2_ITEM"
		EndIf

		SD2->( DbSetOrder( 3 ) ) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		
	EndIf
	
	If (cAliasIte)->( DbSeek( cChavePesq ) ) 
		
		// Verifica se o Produto da NF é igual ao Produto do Contrato
		If NJR->( NJR_CODPRO ) <> (cAliasIte)->&( cPrefIte+"_COD" ) 
			Help(, , STR0034, , STR0049 + Chr(10) + Chr(13) + "[ " + NJR->( NJR_CODPRO )+ " ]", 1, 0 ) //"AJUDA"###"O produto da Nota Fiscal é diferente do produto do Contrato informado."
			RestArea( aAreaAtu )
			Return( .F. )
		EndIf
		
		// Verifica se a NF informada já pertence a outro romaneio
		IF lEntrada
			If  ! Empty( (cAliasCab)->&( cPrefCab+"_CODROM" ) ) ;
			.And. ! Empty( (cAliasIte)->&( cPrefIte+"_CODROM" ) )
				Help(, , STR0034, , STR0051 + Chr(10) + Chr(13) + "[ " + (cAliasCab)->&( cPrefCab+"_CODROM" ) + " ]", 1, 0 ) //"AJUDA"###"A Nota Fiscal informada pertence a outro romaneio."
				RestArea( aAreaAtu )
				Return( .F. )
			EndIf
		Else 
			//se existir a tabela de extensão N8K.			
			If TableInDic('N8K')			
				DbselectArea( 'N8K' )
				N8K->( dbSetOrder( 6 ) ) //_FILIAL+_DOC+_SERIE+_CLIFOR+_LOJA+_PRODUT+_ITEDOC
				IF N8K->(DbSeek( FwXfilial('N8K') + SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM) ))
					Help(, , STR0034, , STR0051 + Chr(10) + Chr(13) + "[ " + N8K->N8K_CODROM  + " ]", 1, 0 ) //"AJUDA"###"A Nota Fiscal informada pertence a outro romaneio."
					RestArea( aAreaAtu )
					Return( .F. )
				EndIF 
			Else //se não, busca diretamente da sd2.
				DbselectArea( 'SD2' )
				SD2->( dbSetOrder( 6 ) ) //_FILIAL+_DOC+_SERIE+_CLIFOR+_LOJA+_PRODUT+_ITEDOC
				IF SD2->(DbSeek( FwXfilial('SD2') + SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM) ))
					Help(, , STR0034, , STR0051 + Chr(10) + Chr(13) + "[ " + SD2->D2_CODROM  + " ]", 1, 0 ) //"AJUDA"###"A Nota Fiscal informada pertence a outro romaneio."
					RestArea( aAreaAtu )
					Return( .F. )
				EndIf 
			EndIf			
		EndIF
		
		AADD( aSays, STR0057 ) //"Esta rotina tem por objetivo gerar o Romaneio Simbolico para a Nota Fiscal"
		AADD( aSays, STR0058 ) //"informada, de acordo com os parametros abaixo:" 
		AADD( aSays, " " ) 
		AADD( aSays, "- "+STR0025+" = " + pcTipo + " - " + AllTrim( Posicione( "SX5", 1, xFilial("SX5") + "K5" + pcTipo, "X5_DESCRI" ) ) ) //"Tipo de Romaneio"
		AADD( aSays, "- "+STR0027+" / "+STR0029+" = " + pcCodEnt + " / " + pcLojEnt ) //"Entidade"###"Loja"
		AADD( aSays, "- "+STR0033+" / "+STR0031+" = " + pcDocNum + " / " + pcDocSer ) //"Numero NF"###"Serie NF"
		AADD( aSays, "- "+STR0045+" = " + pcCodCtr + " - " + NJR->( NJR_DESCRI ) ) //"Contrato"
		AADD( aButtons, { 1, .T., {|| iIf( MsgNoYes( STR0052 );  //"Confirma a geracao automatica do Romaneio Simbolico?"
											 , ( lRetorno:=.T., FechaBatch() ); 	// Se clicar em SIM
											 , FechaBatch() ); 			 			// Se clicar em NAO
										} } ) 
		AADD(aButtons, { 2, .T., {|| FechaBatch() } } )  
		FormBatch( STR0019, aSays, aButtons,, 250, 450 ) //"Geracao de Romaneio Simbolico"
	
		If lRetorno                   
		
			// Faz a criação do romaneio Simbólico 
			MsgRun( STR0019+"...", STR0056 , {|| lRetorno := fGravaRomSimb( pcTipo, cRomOrg ) } ) //"Geracao de Romaneio Simbolico"...###"AGUARDE"
			If lRetorno .and. !_lComplRom
				MsgInfo( STR0054 + "[ " + NJJ->( NJJ_CODROM ) + " ]" + Chr(10) + Chr(13) + STR0055, STR0019 ) //"Romaneio Simbólico criado com sucesso: "###"Este romaneio foi criado com status igual a -Completo-. Utilize a opcao -Atualizar- para alimentar os saldos do contrato, e -Confirmar- para encerra-lo."###"Geracao de Romaneio Simbolico"
			EndIf
		
		Else
			MsgAlert( STR0053 ) //"Operação abortada!"
			RestArea( aAreaAtu )
			Return( .F. )
		EndIf
		
		
	Else
		Help(, , STR0034, , STR0050 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar o Item da NF informada."
		RestArea( aAreaAtu )
		Return( .F. )
	EndIf
	
	RestArea( aAreaAtu )
Return( .T. )

/** {Protheus.doc} fPosicNF
Posiciona na Nota Fiscal de Entrada ou Saída

@param: 	pcTipo		Tipo do romaneio
@param: 	pcDocSer	Série da NF
@param: 	pcDocNum 	Número da NF
@param: 	pcCodEnt	Código da Entidade
@param: 	pcLojEnt	Loja da Entidade
@return:	.T. / .F. 
@author: 	Marlon Richard Trettin
@since: 	27/04/2015
@Uso: 		SIGAAGR
*/
Static Function fPosicNF( pcTipo, pcCodEnt, pcLojEnt, pcDocNum, pcDocSer )
	Local cCodFor		:= ""
	Local cLojFor 	:= ""
	Local cCodCli		:= ""
	Local cLojCli		:= ""
	
	Default _lComplRom := .F. //para complementos (declarada OGA250COMP)

	// Cadastro de Entidades
	NJ0->( dbSetOrder( 1 ) )
	If NJ0->( dbSeek( xFilial( "NJ0" ) + pcCodEnt + pcLojEnt ) )
		cCodFor	:= NJ0->( NJ0_CODFOR )
		cLojFor 	:= NJ0->( NJ0_LOJFOR )
		cCodCli	:= NJ0->( NJ0_CODCLI )
		cLojCli	:= NJ0->( NJ0_LOJCLI )
	Else
		Help(, , STR0034, , STR0035 + Chr(10) + Chr(13) + "[ " + pcCodEnt + " - " + pcLojEnt + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar o cadastro da Entidade + Loja no cadastro de Entidades (NJ0)."	   
		Return( .F. )
	EndIf
	
	
	SF1->( DbSetOrder( 1 ) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	SF2->( DbSetOrder( 1 ) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	
	//////////////////////////////////////
	/// Tipos de Romaneio de Entrada   ///
	//////////////////////////////////////
	
	If pcTipo == "3" // ENTRADA para Depósito de 3o.
		
		If ! SF1->( DbSeek( xFilial( "SF1" ) + pcDocNum + pcDocSer + cCodFor + cLojFor + "N" ) )
			If ! SF1->( DbSeek( xFilial( "SF1" ) + pcDocNum + pcDocSer + cCodCli + cLojCli + "B" ) )
				Help(, , STR0034, , STR0036 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Entrada de Depósito de 3o."	   
				Return( .F. )
			EndIf
		EndIf
		
	ElseIf pcTipo == "5" // ENTRADA para Compra
		cTipoNf :=  iIf(_lComplRom, "C", "N") //define o tipo da nota a ser buscada. 
		
		If ! SF1->( DbSeek( xFilial( "SF1" ) + pcDocNum + pcDocSer + cCodFor + cLojFor + cTipoNf) )
			Help(, , STR0034, , STR0037 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Entrada de Compra"	   
			Return( .F. )
		EndIf
		
	ElseIf pcTipo == "7" // ENTRADA por Devolução de Remessa
		
		If ! SF1->( DbSeek( xFilial( "SF1" ) + pcDocNum + pcDocSer + cCodFor + cLojFor + "N" ) )
			If ! SF1->( DbSeek( xFilial( "SF1" ) + pcDocNum + pcDocSer + cCodCli + cLojCli + "D" ) )
				Help(, , STR0034, , STR0038 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Entrada de Devolução de Remessa"	   
				Return( .F. )
			EndIf
		EndIf
		
	ElseIf pcTipo == "9" // ENTRADA por Devolução de Venda
		
		If ! SF1->( DbSeek( xFilial( "SF1" ) + pcDocNum + pcDocSer + cCodCli + cLojCli + "D" ) )
			Help(, , STR0034, , STR0039 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Entrada de Devolução de Venda"	   
			Return( .F. )
		EndIf
		
	//////////////////////////////////////
	/// Tipos de Romaneio de Saída     ///
	//////////////////////////////////////
		
	ElseIf pcTipo == "2" // SAIDA para Remessa de Depósito em 3o.
		
		If ! SF2->( DbSeek( xFilial( "SF2" ) + pcDocNum + pcDocSer + cCodFor + cLojFor ) )
			If ! SF2->( DbSeek( xFilial( "SF2" ) + pcDocNum + pcDocSer + cCodCli + cLojCli ) )
				Help(, , STR0034, , STR0040 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Saída de Remessa de Depósito em 3o."	   
				Return( .F. )
			EndIf
		EndIf
		
	ElseIf pcTipo == "4" // SAIDA por Venda
		
		If ! SF2->( DbSeek( xFilial( "SF2" ) + pcDocNum + pcDocSer + cCodCli + cLojCli ) )
			Help(, , STR0034, , STR0041 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Saída de Venda."	   
			Return( .F. )
		EndIf
		
	ElseIf pcTipo == "6" // SAIDA por Devolução de Depósito de 3o.
		
		If ! SF2->( DbSeek( xFilial( "SF2" ) + pcDocNum + pcDocSer + cCodCli + cLojCli ) )
			If ! SF2->( DbSeek( xFilial( "SF2" ) + pcDocNum + pcDocSer + cCodFor + cLojFor ) )
				Help(, , STR0034, , STR0042 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Saída de Devolução de Depósito de 3o."
				Return( .F. )
			EndIf
		EndIf
		
	ElseIf pcTipo == "8" // SAIDA por Devolução de Compra
		
		If ! SF2->( DbSeek( xFilial( "SF2" ) + pcDocNum + pcDocSer + cCodCli + cLojCli ) )
			If ! SF2->( DbSeek( xFilial( "SF2" ) + pcDocNum + pcDocSer + cCodFor + cLojFor ) )
				Help(, , STR0034, , STR0043 + Chr(10) + Chr(13) + "[ " + pcDocNum + " / " + pcDocSer + " ]", 1, 0 ) //"AJUDA"###"Não foi possível localizar a NF de Saída de Devolução de Compra"
				Return( .F. )
			EndIf
		EndIf
		
	EndIf
	
Return( .T. )

/** {Protheus.doc} fGravaRomSimb
Atualiza os dados do romaneio na NF relacionada, em caso de romaneio simbólico

@param: 	pcTipo		Tipo do romaneio
@return:	.T. / .F.
@author: 	Marlon Richard Trettin
@since: 	28/04/2015
@Uso: 		SIGAAGR
*/
Static Function fGravaRomSimb( pcTipo, cRomOrg ) 
	Local aRecNJM		:= {}
	Local nX 			:= 0
	Local cNewCodRom	:= ""
	Local cIteRom
	Local nSeqItem 	:= 0
	
	//Vars. de Vinculo
	Local aVincCab		:= {}
	Local aVincITE		:= {}
	Local aLinhaVinc	:= {}
	Local lVinculou		:= .f.
	Local aVincCabNF 	:= {}
	Local aVincIteNF 	:= {}
    Local cItemCad      := ""
    Local cRegraFis     := ""
    Local cFilOrg       := ""
	
	Local nPosCpo		:= 0

    Default cRomOrg     := ""
	
	IF !lEntrada // Tratamento pq a nf. pode ter 2 pvs em seus itens.
	
		cFiltro := " SD2->D2_FILIAL == '" 	+ 	FWXFILIAL('SD2') 	+ "' .and. "
		cFiltro += " SD2->D2_DOC == '"		+ 	SD2->D2_DOC			+ "' .and. "
		cFiltro += " SD2->D2_SERIE == '"	+   SD2->D2_SERIE		+ "' .and. "
		cFiltro += " SD2->D2_CLIENTE == '" 	+  	SD2->D2_CLIENTE		+ "' .and. "
		cFiltro += " SD2->D2_LOJA == '" 	+  	SD2->D2_LOJA			+ "'"
		
		SD2->( DBClearFilter() )	//Retirando o Filtro
		SD2->( DBSetFilter ( {|| &cFiltro}, cFiltro) )    // Filtra somente Registros selecionados e da Filial Corrente
		
		SD2->( DbSetOrder( 8 ) ) //D2_FILIAL+D2_PEDIDO+D2_ITEMPV
		SD2->( dbGoTop() )
			
	EndIF
	
	BEGIN TRANSACTION
		
		/////////////////////////////////////
		/// Insere cabeçalho do Romaneio  ///
		/////////////////////////////////////
		cNewCodRom := GetSXENum('NJJ','NJJ_CODROM')
        If ( __lSx8 )
			ConfirmSX8()
		EndIf

		dbSelectArea( "NJJ" )
		If RecLock( "NJJ", .t. )
			NJJ->( NJJ_FILIAL ) 	:= FWxFilial( "NJJ" )
			NJJ->( NJJ_CODROM ) 	:= cNewCodRom
			NJJ->( NJJ_TIPO ) 	:= pcTipo
			NJJ->( NJJ_CODENT ) 	:= NJ0->( NJ0_CODENT )
			NJJ->( NJJ_LOJENT ) 	:= NJ0->( NJ0_LOJENT )
			NJJ->( NJJ_ENTENT ) 	:= NJ0->( NJ0_CODENT )
			NJJ->( NJJ_ENTLOJ ) 	:= NJ0->( NJ0_LOJENT )
			NJJ->( NJJ_TPFORM ) 	:= iIf( (cAliasCab)->&( cPrefCab+"_FORMUL" ) == "S", "1", "2" ) //// 1=Sim (form. próprio); 2=Não
			NJJ->( NJJ_DOCSER ) 	:= (cAliasCab)->&( cPrefCab+"_SERIE" )
			NJJ->( NJJ_DOCNUM ) 	:= (cAliasCab)->&( cPrefCab+"_DOC" )
			NJJ->( NJJ_DOCEMI ) 	:= (cAliasCab)->&( cPrefCab+"_EMISSAO" )
			NJJ->( NJJ_DOCESP ) 	:= (cAliasCab)->&( cPrefCab+"_ESPECIE" )
			NJJ->( NJJ_CHVNFE ) 	:= (cAliasCab)->&( cPrefCab+"_CHVNFE" )
			NJJ->( NJJ_QTDFIS ) 	:= (cAliasIte)->&( cPrefIte+"_QUANT" )
			NJJ->( NJJ_VLRTOT ) 	:= (cAliasIte)->&( cPrefIte+"_TOTAL" )
			If lEntrada
				NJJ->( NJJ_NFPSER )  := (cAliasIte)->&( cPrefIte+"_NFPSER" )
				NJJ->( NJJ_NFPNUM )  := (cAliasIte)->&( cPrefIte+"_NFPNUM" )
				NJJ->( NJJ_MSGNFS )	:= (cAliasCab)->&( cPrefCab+"_MENNOTA" )
				NJJ->( NJJ_VLRUNI ) 	:= (cAliasIte)->&( cPrefIte+"_VUNIT" )
			Else
				NJJ->( NJJ_VLRUNI ) 	:= (cAliasIte)->&( cPrefIte+"_PRCVEN" )
			EndIf
			NJJ->( NJJ_TES )     := (cAliasIte)->&( cPrefIte+"_TES" )
			NJJ->( NJJ_CODSAF ) 	:= NJR->( NJR_CODSAF )
			NJJ->( NJJ_CODPRO )	:= NJR->( NJR_CODPRO )			
			NJJ->( NJJ_UM1PRO )	:= NJR->( NJR_UM1PRO )
			NJJ->( NJJ_LOCAL )   := (cAliasIte)->&( cPrefIte+"_LOCAL" )
			NJJ->( NJJ_TABELA )	:= NJR->( NJR_TABELA )
			NJJ->( NJJ_DATPS1 )	:= dDataBase
			NJJ->( NJJ_HORPS1 )	:= Substr( Time(), 1, 5 )
			NJJ->( NJJ_MODPS1 )	:= "M"
			NJJ->( NJJ_DATPS2 )	:= dDataBase
			NJJ->( NJJ_HORPS2 )	:= Substr( Time(), 1, 5 )
			NJJ->( NJJ_PESO2 )	:= 0            
			NJJ->( NJJ_MODPS2 )	:= "M"
			NJJ->( NJJ_PSDESC )	:= 0
			NJJ->( NJJ_PSEXTR )	:= 0
			NJJ->( NJJ_DATA ) 	:= dDataBase
			NJJ->( NJJ_DTRANS ) := (cAliasCab)->&( cPrefCab+"_DTDIGIT" )
			NJJ->( NJJ_FRETE )	:= (cAliasCab)->&( cPrefCab+"_FRETE" )
			NJJ->( NJJ_SEGURO )	:= (cAliasCab)->&( cPrefCab+"_SEGURO" )
			NJJ->( NJJ_DESPES )	:= (cAliasCab)->&( cPrefCab+"_DESPESA" )
			NJJ->( NJJ_TPFRET )	:= (cAliasCab)->&( cPrefCab+"_TPFRETE" )
			NJJ->( NJJ_STSCLA )  := "1"		// 0=Não Classificado; 1=Classificado
			NJJ->( NJJ_STSPES )  := "2"		// 0=Sem Pesagem; 1=Primeira Pesagem; 2=Segunda Pesagem
			NJJ->( NJJ_STATUS )	:= "1"		// 0=Pendente; 1=Completo; 2=Atualizado; 3=Confirmado; 4=Cancelado
			NJJ->( NJJ_STAFIS ) 	:= "1"		// 1=Sem Fiscal; 2=Com Fiscal; 3=Gerencial
			NJJ->( NJJ_STACTR ) 	:= "2"		// 1=Sem CTR; 2=Com CTR
			NJJ->( NJJ_TRSERV )  := "0"		// 0=Nao; 1=Tarifa Origem; 2=Tarifa Destino                                                                                          
			NJJ->( NJJ_TIPENT )  := "2"		// 0=Físico; 1=Gerencial; 2=Simbolico; 3=Retenção
			NJJ->( MsUnLock() )
		EndIf
		
		/////////////////////////////////////
		/// Insere itens do Romaneio      ///
		/////////////////////////////////////
		nSeqItem := 0
		While ! (cAliasIte)->( Eof() ) .And. &( cChaveIndi ) == cChavePesq
			
			nSeqItem++
			cIteRom := StrZero( nSeqItem, TamSX3( "NJM_ITEROM" )[1] )
			
			dbSelectArea( "NJM" )
			If RecLock( "NJM", .t. )
				NJM->( NJM_FILIAL )	:= FWxFilial( "NJJ" )
				NJM->( NJM_CODROM )	:= cNewCodRom
				NJM->( NJM_ITEROM )	:= cIteRom 
				NJM->( NJM_TIPO )  	:= pcTipo
				NJM->( NJM_CODCTR )	:= NJR->( NJR_CODCTR )
				If NJM->(ColumnPos("NJM_GENMOD")) > 0 .AND. NJR->(ColumnPos("NJR_GENMOD")) > 0
					NJM->( NJM_GENMOD )	:= NJR->( NJR_GENMOD )
				EndIf
				NJM->( NJM_CODENT )	:= NJ0->( NJ0_CODENT )
				NJM->( NJM_LOJENT )	:= NJ0->( NJ0_LOJENT )
				NJM->( NJM_CODSAF )	:= NJR->( NJR_CODSAF )
				NJM->( NJM_CODPRO )	:= NJR->( NJR_CODPRO )				
				NJM->( NJM_UM1PRO )	:= NJR->( NJR_UM1PRO )
				NJM->( NJM_LOCAL )	:= (cAliasIte)->&( cPrefIte+"_LOCAL" )
				NJM->( NJM_TES )		:= (cAliasIte)->&( cPrefIte+"_TES" )
				NJM->( NJM_TPFORM )	:= iIf( (cAliasCab)->&( cPrefCab+"_FORMUL" ) == "S", "1", "2" ) //// 1=Sim (form. próprio); 2=Não
				NJM->( NJM_DOCSER )	:= (cAliasCab)->&( cPrefCab+"_SERIE" )
				NJM->( NJM_DOCNUM )	:= (cAliasCab)->&( cPrefCab+"_DOC" )
				NJM->( NJM_DOCEMI )	:= (cAliasCab)->&( cPrefCab+"_EMISSAO" )
				NJM->( NJM_DOCESP )	:= (cAliasCab)->&( cPrefCab+"_ESPECIE" )
				NJM->( NJM_CHVNFE )	:= (cAliasCab)->&( cPrefCab+"_CHVNFE" )
				NJM->( NJM_QTDFIS )	:= (cAliasIte)->&( cPrefIte+"_QUANT" )
				NJM->( NJM_QTDFCO )	:= (cAliasIte)->&( cPrefIte+"_QUANT" )
				NJM->( NJM_VLRTOT )	:= (cAliasIte)->&( cPrefIte+"_TOTAL" )
				If lEntrada
					NJM->( NJM_NFPSER )	:= (cAliasIte)->&( cPrefIte+"_NFPSER" )
					NJM->( NJM_NFPNUM ) 	:= (cAliasIte)->&( cPrefIte+"_NFPNUM" )
					NJM->( NJM_MSGNFS )  := (cAliasCab)->&( cPrefCab+"_MENNOTA" )
					NJM->( NJM_VLRUNI )	:= (cAliasIte)->&( cPrefIte+"_VUNIT" )
				Else
					NJM->( NJM_PEDIDO ) 	:= (cAliasIte)->&( cPrefIte+"_PEDIDO" )
					NJM->( NJM_VLRUNI )	:= (cAliasIte)->&( cPrefIte+"_PRCVEN" )
				EndIf
				NJM->( NJM_DTRANS )	:= (cAliasIte)->&( cPrefIte+"_DTDIGIT" )
				NJM->( NJM_CONDPG )	:= (cAliasCab)->&( cPrefCab+"_COND" )
				NJM->( NJM_FRETE ) 	:= (cAliasCab)->&( cPrefCab+"_FRETE" )
				NJM->( NJM_SEGURO ) 	:= (cAliasCab)->&( cPrefCab+"_SEGURO" )
				NJM->( NJM_DESPES )	:= (cAliasCab)->&( cPrefCab+"_DESPESA" )
				NJM->( NJM_TRANS ) 	:= iIf( pcTipo $ "1|2|3|4|5", "1", "2" )  // 1=Entrega; 2=Devolução
				NJM->( NJM_TIPMOV )	:= "1" 	// 1=Física; 2=Financeira
				NJM->( NJM_STAFIS )	:= "1"		// 1=Sem Fiscal; 2=Com Fiscal; 3=Gerencial
				NJM->( NJM_TRSERV )	:= "0" 	// 0=Não; 1=Tarifa Origem; 2=Tarifa Destino

                If _lComplRom .and. __lnewNeg .and. !Empty(cRomOrg)
                    fGetRegraFis(@cItemCad, @cRegraFis, @cFilOrg, cRomOrg, cIteRom)
                    NJM->NJM_ITEM   := cItemCad
                    NJM->NJM_SEQPRI := cRegraFis
                    NJM->NJM_FILORG := cFilOrg
                EndIf 
				NJM->( MsUnLock() )
			EndIf
			
			// Guarda o recno do registro de NJM que foi inserido
			aAdd( aRecNJM, NJM->( Recno() ) )
			
			// Atualiza os totais na NJJ
			If RecLock( "NJJ", .F. )
				NJJ->( NJJ_PESO1 )	+= NJM->( NJM_QTDFCO )
				NJJ->( NJJ_PSSUBT )	+= NJM->( NJM_QTDFCO )
				NJJ->( NJJ_PSBASE )	+= NJM->( NJM_QTDFCO )
				NJJ->( NJJ_PSLIQU )	+= NJM->( NJM_QTDFCO )
                NJJ->( NJJ_PESO3 )	+= NJM->( NJM_QTDFCO )
				NJJ->( MsUnLock() )
			EndIf
			
			// Grava os campos do romaneio nos itens dos documentos fiscais
			If lEntrada
				If RecLock( "SD1", .F. )
					SD1->( D1_CTROG )	:= NJM->( NJM_CODCTR )
					SD1->( D1_CODSAF )	:= NJM->( NJM_CODSAF )
					SD1->( D1_CODROM )	:= NJM->( NJM_CODROM )
					SD1->( D1_ITEROM )	:= NJM->( NJM_ITEROM )
					SD1->( MsUnLock() )
				EndIf
				
			Else
				If SD2->(ColumnPos("D2_CTROG")) > 0
					If RecLock( "SD2", .F. )
						SD2->( D2_CTROG )	:= NJM->( NJM_CODCTR )
						SD2->( D2_CODSAF )	:= NJM->( NJM_CODSAF )
						SD2->( D2_CODROM )	:= NJM->( NJM_CODROM )
						SD2->( D2_ITEROM )	:= NJM->( NJM_ITEROM )
						SD2->( MsUnLock() )
					EndIf
				EndIf

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
				aadd( aLinhaVinc, { "N8K_ORIGEM"    , 'OGA251'			} )
				aadd( aLinhaVinc, { "N8K_HISTOR"    , FWI18NLang("OGA251","STR0061",61)	} )
				
				aAdd( aVincIteNF, aLinhaVinc )
			
				//Array de vinculo do Agro com o doc. Sada
				
				IF Len (aVincCabNF) == 0
					aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8K')	} )
					aadd( aVincCabNF, { "N8J_DOC"		, SD2->D2_DOC		} )
					aadd( aVincCabNF, { "N8J_SERIE"		, SD2->D2_SERIE		} )
					aadd( aVincCabNF, { "N8J_CLIFOR"    , SD2->D2_CLIENTE	} ) 
					aadd( aVincCabNF, { "N8J_LOJA"    	, SD2->D2_LOJA		} )
					aadd( aVincCabNF, { "N8J_TPDOC"    	, SD2->D2_TIPO   	} )
					aadd( aVincCabNF, { "N8J_CODCTR"    , NJM->NJM_CODCTR	} )
					aadd( aVincCabNF, { "N8J_CODROM"    , NJM->NJM_CODSAF	} )
					aadd( aVincCabNF, { "N8J_CODROM"   	, NJM->NJM_CODROM   } )
					aadd( aVincCabNF, { "N8J_CODOTR"   	, ''				} )
					aadd( aVincCabNF, { "N8J_CODFIX"	, ''				} )
					aadd( aVincCabNF, { "N8J_CODOTR"	, ''				} )		
					aadd( aVincCabNF, { "N8J_ORPGRC"	, ''				} )
					aadd( aVincCabNF, { "N8J_FECSER"	, ''				} )
					aadd( aVincCabNF, { "N8J_ORIGEM"	, 'OGA251'			} )
					aadd( aVincCabNF, { "N8J_HISTOR"	, FWI18NLang("OGA251","STR0061",61)	} )
				EndIf
			
				//Gerando o link com o pv de saida				
				IF len(aVincCab) > 0
					nPosCpo:= ASCAN(aVincCab, {|aVincCab| aVincCab[1] ==  'N8H_NUMPV' })
					IF ! Alltrim ( aVincCab[nPosCpo] ) ==  SD2->D2_PEDIDO
						lVinculou := fAgrVncPV (aVincCab,aVincITE  , 3)  	//Incluir
					EndIF
					aVincCab := {}
					aVincITE := {}
				EndIF
			
				aLinhaVinc := {}
				aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 			} )
				aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SD2->D2_ITEMPV			} )
				aadd( aLinhaVinc, { "N8I_PRODUT"    	, SD2->D2_COD				} )
				aadd( aLinhaVinc, { "N8I_TPPROD"    	, ''			 			} )
				aadd( aLinhaVinc, { "N8I_CODCTR"    	, NJM->NJM_CODCTR			} )
				aadd( aLinhaVinc, { "N8I_SAFRA"    		, NJM->NJM_CODSAF			} )
				aadd( aLinhaVinc, { "N8I_CODROM"    	, NJM->NJM_CODROM			} )
				aadd( aLinhaVinc, { "N8I_ITEROM"    	, NJM->NJM_ITEROM			} )
				aadd( aLinhaVinc, { "N8I_CODOTR"   		, ''						} )
				aadd( aLinhaVinc, { "N8I_ITEOTR"   		, ''						} )
				aadd( aLinhaVinc, { "N8I_CODFIX"    	, ''						} )
				aadd( aLinhaVinc, { "N8I_ORIGEM"    	, 'OGA251'		 			} )		
				aAdd( aLinhaVinc, { "N8I_HISTOR"    	, FWI18NLang("OGA251","STR0061",61)	} )  //'Romaneio (fajustafiscal' 
						
				aAdd(aVincITE, aLInhaVinc )
				
			
				// Criando Array de vinculo
				// Alimentando as tabelas de auxiliares de vinculo com ERP
				
				If len( avincCab) == 0
					aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 						} )
					aadd( aVincCab, { "N8H_NUMPV"    	, SD2->D2_PEDIDO			  			} )
					aadd( aVincCab, { "N8H_CODCTR"    	, NJM->NJM_CODCTR		 			} )
					aadd( aVincCab, { "N8H_CODROM"    	, NJM->NJM_CODROM					} )
					aadd( aVincCab, { "N8H_CODFIX"   	, ""									} )
					aadd( aVincCab, { "N8H_CODOTR"   	, ""									} )
					aadd( aVincCab, { "N8H_ORIGEM"   	, "OGA251"								} )
					aAdd( aVincCab, { "N8H_HISTOR"    	, FWI18NLang("OGA251","STR0061",61)		} )	//'Romaneio (fajustafiscal'
				EndIF 
				aVncCRec := {}
			EndIf
			
			(cAliasIte)->( DbSkip() )
			 
			IF (cAliasIte)->( Eof() )
				lVinculou := fAgrVncPV (aVincCab,aVincITE  , 3)  	//Incluir
				SD2->( DBClearFilter() )	//Retirando o Filtro
				Exit
			EndIF
			
		EndDo		
		
		// Grava os campos do romaneio nos documentos fiscais
		If lEntrada
			If RecLock( "SF1", .F. )
				SF1->( F1_CODROM )	:= NJJ->( NJJ_CODROM )
				SF1->( MsUnLock() )
			EndIf
		Else
			If SF2->(ColumnPos("F2_CODROM")) > 0
				If RecLock( "SF2", .F. )
					SF2->( F2_CODROM )	:= NJJ->( NJJ_CODROM )
					SF2->( MsUnLock() )
					lVinculou := .T.
				EndIf
			EndIf

			//Cria arq. de vinculo da nf.
			IF  Len( aVincCabNF ) > 0 .and. Len( aVincIteNF ) > 0 
				lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 3)  		//Incluir
			EndIf

		EndIf
		
		// Atualiza campos de valores propocionais na NJM
		For nX := 1 to Len( aRecNJM )
			NJM->( DbGoTo( aRecNJM[ nX ] ) )
			If RecLock( "NJM", .F. )
				NJM->( NJM_PERDIV )	:= ( NJM->( NJM_QTDFCO ) / NJJ->( NJJ_PSLIQU ) ) * 100
				NJM->( NJM_FRETE ) 	:= NJM->( NJM_FRETE  ) * ( NJM->( NJM_PERDIV ) / 100 )
				NJM->( NJM_SEGURO ) := NJM->( NJM_SEGURO ) * ( NJM->( NJM_PERDIV ) / 100 )
				NJM->( NJM_DESPES )	:= NJM->( NJM_DESPES ) * ( NJM->( NJM_PERDIV ) / 100 )
				NJM->( MsUnLock() )
			EndIf			
		Next nX
		
	END TRANSACTION
	
Return( .T. )

/** {Protheus.doc} OGA251Del
Atualiza os dados do romaneio na NF relacionada, em caso de romaneio simbólico

@param: 	pnRecNJJ	Recno() da tabela NJJ
@return:	NIL
@author: 	Marlon Richard Trettin
@since: 	28/04/2015
@Uso: 		SIGAAGR
*/
Function OGA251Del( pnRecNJJ ) 
	Local aAreaAtu  	:= GetArea()
	Local aCliFor		:= {}
	Local cTipoNF		:= ""
	Local cCliFor		:= ""
	Local cLoja 		:= ""
	
	//Vars vinc PV
	Local aLinhaVinc	:= {}
	Local aVincCab 		:= {}
	Local aVincITE 		:= {}
	Local nPosCpo		:= 0
	
	//Vars vinc nfsaida
	Local aLinha		:= {}
	Local aVincCabNF	:= {}
	Local aVincIteNF	:= {}
	
	
	
	// Posiciona no Romaneio (NJJ)
	DbSelectArea( "NJJ" )
	DbGoTo( pnRecNJJ )
	
	If NJJ->( NJJ_TIPENT ) <> "2" // Se não for romaneio simbólico
		Return( NIL )
	EndIf
	
	// Lê os Itens do Romaneio (NJM)
	NJM->( DbSetOrder( 1 ) )
	NJM->( DbSeek( xFilial( "NJM" ) + NJJ->( NJJ_CODROM ) ) )
	While ! NJM->( Eof() ) .And. NJM->( NJM_FILIAL + NJM_CODROM ) == xFilial( "NJM" ) + NJJ->( NJJ_CODROM )
		
		//Retorna o Cliente ou Fornecedor, conforme o tipo do movimento do romaneio
		aCliFor := OGA250ClFr( NJM->( NJM_CODENT ), NJM->( NJM_LOJENT ), NJM->( NJM_TES ), NJM->( NJM_TIPO ), NJM->( NJM_QTDFIS ) )
		cTipoNF	:= aCliFor[ 1 ]
		cCliFor	:= aCliFor[ 2 ]
		cLoja 		:= aCliFor[ 3 ]
			
		If NJM->( NJM_TIPO ) $ "3|5|7|9" // Se for romaneio de ENTRADA
				
			SD1->( DbSetOrder( 1 ) ) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If SD1->( DbSeek( xFilial( "SF1" ) + NJM->( NJM_DOCNUM ) + NJM->( NJM_DOCSER ) + cCliFor + cLoja ) )
				
				// Desvincula o romaneio da NF
				If RecLock( "SF1", .F. )
					SF1->( F1_CODROM )	:= Space( TamSX3( "F1_CODROM" )[1] )
					SF1->( MsUnLock() )
				EndIf
				
				SD1->( dbSetOrder( 1 ) )
				SD1->( dbSeek( xFilial( "SD1" ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA ) ) )
				While .Not. SD1->( Eof() ) ;
				.And. SD1->( D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA ) == xFilial( "SD1" ) + SF1->( F1_DOC + F1_SERIE + F1_FORNECE + F1_LOJA )
 					
					// Desvincula o romaneio do item da NF
					If RecLock( "SD1", .F. )
						SD1->( D1_CTROG )	:= Space( TamSX3( "D1_CTROG" )[1] )
						SD1->( D1_CODSAF )	:= Space( TamSX3( "D1_CODSAF" )[1] )
						SD1->( D1_CODROM )	:= Space( TamSX3( "D1_CODROM" )[1] )
						SD1->( D1_ITEROM )	:= Space( TamSX3( "D1_ITEROM" )[1] )
						SD1->( MsUnLock() )
					EndIf
					
					SD1->( DbSkip() )
				EndDo
				
			EndIf
				
		Else	// Se for romaneio de SAIDA
				
			SC5->( DbSetOrder( 1 ) ) //C5_FILIAL+C5_NUM
			If SC5->( DbSeek( xFilial( "SC5" ) + NJM->( NJM_PEDIDO ) ) )
				
				// Desvincula o romaneio do PV
				SF2->( DbSetOrder( 1 ) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
				If SF2->( DbSeek( xFilial( "SF2" ) + SC5->( C5_NOTA ) + SC5->( C5_SERIE ) + SC5->( C5_CLIENTE ) + SC5->( C5_LOJACLI ) ) )
					
					// Desvincula o romaneio da NF
					
					SD2->( dbSetOrder( 3 ) )
					SD2->( dbSeek( xFilial( "SD2" ) + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA ) ) ) 
					While .Not. SD2->( Eof() ) ;
					.And. SD2->( D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == xFilial("SD2") + SF2->( F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA )
					
						/***************************************************************************/
						//Tratamento para eliminar a tabela de vinculos
						/***************************************************************************/
						// Desvincula o romaneio do item da NF
						//Array de vinculo do Agro com o doc. Sada ( Cab )
						IF Len (aVincCabNF) == 0
							aadd( aVincCabNF, { "N8J_FILIAL"	, FwXfilial('N8K')	} )
							aadd( aVincCabNF, { "N8J_DOC"		, SF2->F2_DOC		} )
							aadd( aVincCabNF, { "N8J_SERIE"		, SF2->F2_SERIE		} )
							aadd( aVincCabNF, { "N8J_CLIFOR"    , SF2->F2_CLIENTE	} ) 
							aadd( aVincCabNF, { "N8J_LOJA"    	, SF2->F2_LOJA		} )
						EndIf
							
						//Array Vinc. do Agro com doc. saida ( Itens )	
						aLinha := {}
						aadd( aLinha, { "N8K_FILIAL"    , FwXfilial('N8K')	} )
						aadd( aLinha, { "N8K_DOC" 	   	, SD2->D2_DOC		} )
						aadd( aLinha, { "N8K_SERIE"    	, SD2->D2_ITEM		} )
						aadd( aLinha, { "N8K_CLIFOR"    , SD2->D2_CLIENTE	} ) 
						aadd( aLinha, { "N8K_LOJA"    	, SD2->D2_LOJA		} )
						aadd( aLinha, { "N8K_ITEDOC"    , SD2->D2_ITEM   	} )
						aAdd( aVincIteNF, aLinha )
						
						/**********************************************************************************/
						// Tratando o Vinc. do Pv. para ser excluido da tab. de vinculo
						// Podemos ter uma nf. contendo itens de varios pedidos.
						/**********************************************************************************/
						IF len(aVincCab) > 0   			// Chama função pra eliminar registro de vinculo do PV, (caso nf. tenha 2 pedidos em seus itens e o pv mudou)
						   nPosCpo:= ASCAN(aVincCab, {|aVincCab| aVincCab[1] ==  'N8H_NUMPV' })
						   IF ! Alltrim ( aVincCab[nPosCpo] ) ==  SD2->D2_PEDIDO
						      lVinculou := fAgrVncPV (aVincCab,aVincITE  , 5)  	//Excluir ( Irá excluir o vinculo de todos os itens do pedido )
						   EndIF
						   aVincCab := {}
						   aVincITE := {}
						EndIF
						
						IF len( avincCab) == 0
			 		   		aadd( aVincCab, { "N8H_FILIAL"      , FwXfilial('N8H') 						} )
			 		   		aadd( aVincCab, { "N8H_NUMPV"    	, SD2->D2_PEDIDO			  			} )
			 		   	EndIF 
					
						aLinhaVinc := {}
						aadd( aLinhaVinc, { "N8I_FILIAL"    	, FwXfilial('N8I') 			} )
						aadd( aLinhaVinc, { "N8I_NUMPV"    		, SD2->D2_PEDIDO			} )
						aadd( aLinhaVinc, { "N8I_ITEMPV"    	, SD2->D2_ITEMPV			} )
								
						aAdd(aVincITE, aLInhaVinc )
						
						SD2->( DbSkip() )
					EndDo
					
					IF Len(aVincCabNF) > 0 // Chama função para elimnar registro de vinculo da NF
						lVinculou := fAgrVncNFS (aVincCabNF,aVincIteNF  , 5)  		//Excluir
						aVincCabNF := {}
						aVincIteNF := {}
					EndIF
					
					IF len( avincCab) > 0 // Chama função pra eliminar registro de vinculo do PV
						lVinculou := fAgrVncPV (aVincCab,aVincITE  , 5)  	//Excluir ( Irá excluir o vinculo de todos os itens do pedido )
					EndIF
				EndIf
			EndIf	
		EndIf	
			
		NJM->( DbSkip() )
	EndDo				
		
	RestArea( aAreaAtu )
Return( NIL )


/*/{Protheus.doc} fGetRegraFis
    Busca regra fiscal do romaneio original para complemento
    @type  Static Function
    @author user
    @since 17/09/2020
    @version version    
    /*/
Static Function fGetRegraFis(cItemCad,cRegraFis, cFilOrg, cRomOrg, cIteRom)
    Local cAliasQry := GetNextAlias()    

    BeginSql Alias cAliasQry
        SELECT NJM_ITEM, NJM_SEQPRI, NJM_FILORG
          FROM %table:NJM% NJM
        WHERE NJM_FILIAL = %xFilial:NJM%
          AND NJM_CODROM = %Exp:cRomOrg%
          AND NJM_ITEROM = %Exp:cIteRom%
          AND NJM.%notDel%
    EndSql

    cItemCad  := (cAliasQry)->NJM_ITEM
    cRegraFis := (cAliasQry)->NJM_SEQPRI
    cFilOrg   := (cAliasQry)->NJM_FILORG
    
    (cAliasQry)->(dbCloseArea())

Return 
