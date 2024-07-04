#INCLUDE "JURA192.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA192
Pagamentos de Extratos de correspondentes

@author Rafael Tenorio da Costa
@since 05/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA192()

	Local cFiltro	:= ""
	Local cDtIni 	:= "" 
	Local cDtFim 	:= ""  
	Local cCorDe	:= "" 
	Local cLojCorDe	:= "" 
	Local cCodAte 	:= ""
	Local cLojCorAte:= ""
	Local cEscDe 	:= ""
	Local cEscAte 	:= ""
	Local cAreaDe 	:= ""
	Local cAreaAte 	:= ""
	Local cCliDe	:= ""
	Local cLojCliDe	:= ""
	Local cCliAte	:= ""
	Local cLojCliAte:= ""
	
	Private oBrowse	:= Nil
	
	//Apresenta pergunte
	If Pergunte("JURA189", .T.)
	
		cDtIni 		:= DtoS( MV_PAR01 )	//Periodo De:
		cDtFim 		:= DtoS( MV_PAR02 )	//Periodo Ate:
		cCorDe		:= MV_PAR03			//Correspondente De:
		cLojCorDe	:= MV_PAR04			//Loja Correspondente De:
		cCodAte 	:= MV_PAR05			//Correspondente Ate:
		cLojCorAte	:= MV_PAR06			//Loja Correspondente Ate:
		cEscDe 		:= MV_PAR07			//Escritorio De:
		cEscAte 	:= MV_PAR08			//Escritorio Ate:
		cAreaDe 	:= MV_PAR09			//Area De:
		cAreaAte 	:= MV_PAR10			//Area Ate:
		cCliDe		:= MV_PAR11			//Cliente De:
		cLojCliDe	:= MV_PAR12			//Loja Cliente De:
		cCliAte		:= MV_PAR13			//Cliente Ate:
		cLojCliAte	:= MV_PAR14			//Loja Cliente Ate:
		
		//Cria filtro
		cFiltro := 		  "	NZF_DTINI	>= '" +cDtIni+ 		"' .And. NZF_DTFIM 	<= '" +cDtFim+ 		"'"
		cFiltro += " .And.	NZF_CCORRE 	>= '" +cCorDe+ 		"' .And. NZF_CCORRE <= '" +cCodAte+ 	"'"
		cFiltro += " .And.	NZF_LCORRE 	>= '" +cLojCorDe+ 	"' .And. NZF_LCORRE <= '" +cLojCorAte+ 	"'"
		cFiltro += " .And.	NZF_CESCRI 	>= '" +cEscDe+ 		"' .And. NZF_CESCRI <= '" +cEscAte+ 	"'"
		cFiltro += " .And.	NZF_CAREA  	>= '" +cAreaDe+ 	"' .And. NZF_CAREA  <= '" +cAreaAte+ 	"'"
		cFiltro += " .And.	NZF_CCLIEN 	>= '" +cCliDe+ 		"' .And. NZF_CCLIEN <= '" +cCliAte+ 	"'"
		cFiltro += " .And.	NZF_LCLIEN 	>= '" +cLojCliDe+ 	"' .And. NZF_LCLIEN <= '" +cLojCliAte+ 	"'"
		cFiltro += " .And.	NZF_STATUS == '2'"	//Aprovado
		
		//Monta markbrowse
		oBrowse := FWMarkBrowse():New()
		oBrowse:SetDescription( STR0004 )	//"Pagamento extrato de correspondente"
		oBrowse:SetAlias( "NZF" )
		oBrowse:SetLocate()
		oBrowse:SetFieldMark( "NZF_OK" )
		oBrowse:SetWalkThru(.F.)
		oBrowse:SetAmbiente(.F.)
		
		JurSetLeg( oBrowse, "NZF" )
		JurSetBSize( oBrowse )
		
		oBrowse:SetFilterDefault( cFiltro )
		oBrowse:Activate()
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Rafael Tenorio da Costa
@since 05/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        	, 0, 1, 0, .T. } ) 	//"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA192"	, 0, 2, 0, NIL } ) 	//"Visualizar"
aAdd( aRotina, { STR0003, "Processa( { || J192ProxPg() }, '" + STR0005 + "','" + STR0009 +"' ,.F.) ", 0, 3, 0, NIL } )	//"Gera pagamento"	"Aguarde. . ."	"Gerando pagamento dos registros selecionados."

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Extratos de Correspondentes x Atos

@author Rafael Tenorio da Costa
@since 05/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  		:= FWLoadModel( "JURA192" )
Local oStructNZF	:= FWFormStruct( 2, "NZF" )
Local oStructNZG	:= FWFormStruct( 2, "NZG" )

oStructNZF:RemoveField("NZF_OK")

oStructNZG:RemoveField("NZG_COD")
oStructNZG:RemoveField("NZG_CCORRE")
oStructNZG:RemoveField("NZG_LCORRE")

JurSetAgrp( "NZF",, oStructNZF )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA192_VIEW", oStructNZF, "NZFMASTER"  )
oView:AddGrid( 	"JURA192_GRID", oStructNZG, "NZGDETAIL"  )

oView:AddIncrementField( "JURA192_GRID", "NZG_ITEM" )

oView:CreateHorizontalBox( "SUPERIOR", 40 )
oView:CreateHorizontalBox( "INFERIOR", 60 )

oView:SetOwnerView( "JURA192_VIEW"	, "SUPERIOR" )
oView:SetOwnerView( "JURA192_GRID"	, "INFERIOR" )

oView:SetDescription( STR0004 )		//"Pagamento extrato de correspondente"
oView:EnableControlBar( .T. )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Extratos de Correspondentes x Atos

@author Rafael Tenorio da Costa
@since 05/05/2015
@version 1.0

@obs NZFMASTER - Dados do Extratos de Correspondentes x Atos

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel		:= NIL
Local oStructNZF	:= FWFormStruct( 1, "NZF" )
Local oStructNZG 	:= FWFormStruct( 1, "NZG" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA192", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)

oModel:AddFields(	"NZFMASTER", NIL		, oStructNZF, /*Pre-Validacao*/	, /*Pos-Validacao*/ )
oModel:AddGrid( 	"NZGDETAIL", "NZFMASTER", oStructNZG, /*bLinePre*/		, /*bLinePost*/		, /*bPre*/, /*bPost*/ )

oModel:SetRelation( "NZGDETAIL", { 	{ "NZG_FILIAL", "NZF_FILIAL" } , { "NZG_COD"	, "NZF_COD" } 		, { "NZG_CCORRE", "NZF_CCORRE"	} ,;
									{ "NZG_LCORRE", "NZF_LCORRE" } , { "NZG_CESCRI"	, "NZF_CESCRI" }	, { "NZG_CAREA"	, "NZF_CAREA" 	} ,;
									{ "NZG_CCLIEN", "NZF_CCLIEN" } , { "NZG_LCLIEN"	, "NZF_LCLIEN" }	} , NZG->( IndexKey(1) ) )

oModel:SetDescription( STR0006 ) 							//"Modelo de Dados de Pagamento Extratos de Correspondentes"
oModel:GetModel( "NZFMASTER" ):SetDescription( STR0007 )	//"Dados de Pagamento Extratos de Correspondentes"
oModel:GetModel( "NZGDETAIL" ):SetDescription( STR0008 )	//"Grid do Pagamento Extratos de Correspondentes"

oModel:GetModel( "NZGDETAIL" ):SetUniqueLine( { "NZG_ITEM" } )

JurSetRules( oModel, "NZFMASTER",, "NZF" )
JurSetRules( oModel, "NZGDETAIL",, "NZG" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J192ProxPg
Chama rotina de que gera pagamento pelo agrupamento de pagamento 

@return	
@author Rafael Tenorio da Costa
@since 05/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function J192ProxPg( )

	Local lProc1 := .F.
	Local lProc2 := .F.

	//1=Correspondente/Escritorio/Area/Cliente/Periodo
	lProc1 := GeraPag( "1" )
	
	//2=Correspondente/Periodo
	lProc2 := GeraPag( "2" )
	
	If !lProc1 .And. !lProc2
		ApMsgInfo(STR0010)	//"Não existem registros a serem processados"
	EndIf
	
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraPag
Seleciona os registros e gera o pagamento pelo agrupamento de pagamento 

@return	
@author Rafael Tenorio da Costa
@since 05/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraPag( cAgrupExt )

	Local aArea		:= GetArea()
	Local cTabela	:= GetNextAlias()
	Local cQuery	:= ""
	Local cCampos	:= ""
	Local cGrupBy	:= ""
	Local cMarca   	:= oBrowse:Mark()
	Local aTamVlr	:= TamSx3("NZF_TOTAL")
	Local lContinua	:= .F.
	Local cNumPag	:= ""
	Local cTipPag	:= ""
	Local lRetorno	:= .F.
	Local cChaveAnt	:= ""
	Local cChave	:= "NZF_CCORRE + NZF_LCORRE"
	Local cCodCor 	:= "" 
	Local cLojCor	:= ""
	Local cEscri	:= "" 
	Local cArea		:= "" 
	Local cCodCli	:= "" 
	Local cLojCli	:= "" 	
	Local cCondPg	:= ""
	Local aProdutos	:= {}
	Local lDbSkip	:= .T.
	Local nSaveSx8	:= GetSx8Len()						// Numeracao do SX8

	//1=Correspondente/Escritorio/Area/Cliente/Periodo
	If cAgrupExt == "1"
		cCampos	:= ", NZF_CESCRI, NZF_CAREA, NZF_CCLIEN, NZF_LCLIEN " + CRLF
		cChave	+= " + NZF_CESCRI + NZF_CAREA + NZF_CCLIEN + NZF_LCLIEN"
	EndIf
	
	//-------------------------------------------------------------------
	//Monta query e define como sera o agrupamento para gerar os pagamentos 	
	//-------------------------------------------------------------------
	cQuery	:= " SELECT NZF_CCORRE, NZF_LCORRE " + CRLF
	
	cQuery += cCampos
	
	cQuery += 	" , NZI_ENVPAG, NZI_NATURE, NZI_TIPOTI, NZI_CONDPG " + CRLF
	cQuery += 	" , NZG_PRODUT, SUM(NZG_VLPAGA) TOTAL " + CRLF

	cQuery += " FROM " +RetSqlName("NZF")+ " NZF INNER JOIN " +RetSqlName("NZG")+ " NZG " + CRLF
	cQuery += 	" ON     NZF_FILIAL = NZG_FILIAL AND NZF_COD = NZG_COD AND NZF_CCORRE = NZG_CCORRE AND NZF_LCORRE = NZG_LCORRE " + CRLF 
	cQuery += 	  "	 AND NZF_CESCRI = NZG_CESCRI AND NZF_CAREA = NZG_CAREA AND NZF_CCLIEN = NZG_CCLIEN AND NZF_LCLIEN = NZG_LCLIEN " + CRLF
	cQuery +=	  "  AND NZF.D_E_L_E_T_ = NZG.D_E_L_E_T_" + CRLF 
	
	cQuery += " INNER JOIN " +RetSqlName("NZI")+ " NZI " + CRLF
	cQuery += 	" ON NZF_FILIAL = NZI_FILIAL AND NZF_CCORRE = NZI_CCORRE AND NZF_LCORRE = NZI_LCORRE AND NZF.D_E_L_E_T_ = NZI.D_E_L_E_T_" + CRLF
	
	cQuery += " WHERE NZF_FILIAL = '"	+xFilial("NZF")+	"' " + CRLF
	cQuery += 	" AND NZF_OK = '"		+cMarca+ 			"' " + CRLF
	cQuery += 	" AND NZI_AGRUEX = '" 	+cAgrupExt+			"' " + CRLF
	cQuery += 	" AND NZG_STATUS IN ('2','4') " + CRLF		//2=Aprovado 4=Encerrado	
	cQuery += 	" AND NZF.D_E_L_E_T_ = ' '" 	+ CRLF
	
	cGrupBy	:= " GROUP BY NZF_CCORRE, NZF_LCORRE " + CRLF

	cGrupBy += cCampos

	cGrupBy += 	" , NZI_ENVPAG, NZI_NATURE, NZI_TIPOTI, NZI_CONDPG " + CRLF
	cGrupBy += 	" , NZG_PRODUT " + CRLF
	
	cQuery += cGrupBy
	
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabela, .F., .T.)
	TcSetField(cTabela, "TOTAL", "N", aTamVlr[1], aTamVlr[2])
	
	While !(cTabela)->( Eof() )
	
		If (cTabela)->TOTAL > 0
	
			lRetorno	:= .T.
			lContinua	:= .F.
			cNumPag		:= ""
			cTipPag		:= ""
			cChaveAnt	:= ""
			cCodCor 	:= (cTabela)->NZF_CCORRE 
			cLojCor		:= (cTabela)->NZF_LCORRE
			cCondPg		:= (cTabela)->NZI_CONDPG
			aProdutos	:= {}
			lDbSkip		:= .T.
			
			//1=Correspondente/Escritorio/Area/Cliente/Periodo
			If cAgrupExt == "1"
			
				cEscri		:= (cTabela)->NZF_CESCRI 
				cArea		:= (cTabela)->NZF_CAREA 
				cCodCli		:= (cTabela)->NZF_CCLIEN 
				cLojCli		:= (cTabela)->NZF_LCLIEN
			Else

				cEscri		:= "" 
				cArea		:= "" 
				cCodCli		:= "" 
				cLojCli		:= ""
			EndIf
			
			Begin Transaction		
		
				//-------------------------------------------------------------------
				//Define como sera feito o pagamento do correspondente 	
				//-------------------------------------------------------------------
				If (cTabela)->NZI_ENVPAG == "1"
						
					//Gera 1=Financeiro		
					lContinua	:= GeraTitulo( cTabela, @cNumPag, cCondPg )
					cTipPag		:= "1"
				Else
				
					If cChaveAnt <> (cTabela)->&(cChave) 
					
						cChaveAnt := (cTabela)->(NZF_CCORRE + NZF_LCORRE)
					
						//1=Correspondente/Escritorio/Area/Cliente/Periodo
						If cAgrupExt == "1"
							cChaveAnt += (cTabela)->(NZF_CESCRI + NZF_CAREA + NZF_CCLIEN + NZF_LCLIEN)
						EndIf
						
						//Carrega dados para gerar o pedido de compras
						While cChaveAnt == (cTabela)->&(cChave)

							Aadd(aProdutos, { (cTabela)->NZG_PRODUT, (cTabela)->TOTAL } )
							 
							(cTabela)->( DbSkip() )
							lDbSkip := .F.
						EndDo
					EndIf
				
					//Gera 2=Compras		
					lContinua	:= GeraPedido( @cNumPag, cCodCor, cLojCor, cCondPg, aProdutos )
					cTipPag		:= "2"
				EndIf
				
				//Confirma atualizacao de numeracao
				If lContinua
					While GetSX8Len() > nSaveSx8
						ConfirmSx8()
					End
				EndIf				
	
				//-------------------------------------------------------------------
				//Atualiza registros de extrato correspondente NZF 	
				//-------------------------------------------------------------------
				If lContinua
				
					lContinua := AtuExtrato( cNumPag, cTipPag, cMarca, cAgrupExt, cCodCor	,;
											 cLojCor, cEscri , cArea , cCodCli  , cLojCli 	)
				EndIf
				
			End Transaction
		EndIf
	
		//Verifica se deve passar para o proximo registro
		If lDbSkip
			(cTabela)->( DbSkip() )
		EndIf
	EndDo
	
	(cTabela)->( DbCloseArea() )
	RestArea( aArea )
	
	oBrowse:Refresh( .T. )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraTitulo
Gera titulo a pagar para pagar o correspondente

@return	
@author Rafael Tenorio da Costa
@since 07/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraTitulo( cTabela, cNumTitulo, cCondPg )

	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local aSE2		:= {}
	Local cPrefixo	:= SuperGetMV( 'MV_JPREEXT',, 'NZF' )
	Local cOrigem	:= "JURA192"
	Local cErro		:= ""
	Local dEmissao	:= Date()
	Local aVencto	:= Condicao( (cTabela)->TOTAL, cCondPg, /*nValIpi*/, dEmissao, /*nValSol*/, /*aImpVar*/, /*aE4*/, /*nAcrescimo*/, /*nInicio3*/, /*aDias3*/)
	Local nVencto	:= Len(aVencto)
	Local nCont		:= 0 
	
	Private lMsErroAuto	:= .F.
	
	//Gera numeracao para o titulo
	cNumTitulo := GetSxeNum("NZF", "NZF_NUMPAG")	
	
	AAdd(aSE2, {"E2_FILIAL"  , xFilial("SE2")  			, Nil} )	//1
	AAdd(aSE2, {"E2_FORNECE" , (cTabela)->NZF_CCORRE	, Nil} )	//2
	AAdd(aSE2, {"E2_LOJA"    , (cTabela)->NZF_LCORRE	, Nil} )	//3
	AAdd(aSE2, {"E2_PREFIXO" , cPrefixo				 	, Nil} )	//4
	AAdd(aSE2, {"E2_NUM"     , cNumTitulo	      		, Nil} )	//5
	AAdd(aSE2, {"E2_PARCELA" , ""		 				, Nil} )	//6
	AAdd(aSE2, {"E2_TIPO"    , (cTabela)->NZI_TIPOTI    , Nil} )	//7
	AAdd(aSE2, {"E2_NATUREZ" , (cTabela)->NZI_NATURE 	, Nil} )	//8
	AAdd(aSE2, {"E2_EMISSAO" , dEmissao					, Nil} )	//9
	AAdd(aSE2, {"E2_VENCTO"	 , dEmissao					, Nil} )	//10
	AAdd(aSE2, {"E2_ORIGEM"  , cOrigem					, Nil} )	//11
	AAdd(aSE2, {"E2_VALOR"   , 0  						, Nil} )	//12
	
	For nCont:=1 To nVencto

		lMsErroAuto	:= .F.

		//Atualiza parcela
		aSE2[6][2]	:= StrZero( nCont, TamSx3("E2_PARCELA")[1] ) 
		
		//Atualiza data de vencimento
		aSE2[10][2] := aVencto[nCont][1]
		
		//Atualiza valor da parcela
		aSE2[12][2] := aVencto[nCont][2]

		//Inclui titulo a pagar
		MSExecAuto({|x,y,z| FINA050(x,y,z)}, aSE2, Nil, 3)
	
		If lMsErroAuto
			lRetorno:= .F.
			cErro 	:= MostraErro()
			Exit
		EndIf
	
	Next nCont
	
	RestArea( aArea )

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GeraPedido
Gera pedido de compras para pagar o correspondente

@return	
@author Rafael Tenorio da Costa
@since 07/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GeraPedido( cNumPed, cCodCor, cLojCor, cCondPg, aProdutos )

	Local aArea		:= GetArea()
	Local lRetorno 	:= .T.
	Local aCabSC7	:= {}
	Local aItemSC7	:= {}
	Local aAux		:= {}
	Local cItem		:= ""
	Local aDadosSB1	:= {}
	Local cUnidade	:= ""
	Local cLocal	:= ""
	Local cErro		:= ""
	Local nCont		:= 0
	
	Private lMsErroAuto	:= .F.
	
	//Gera numero do pedido de compra
	cNumPed := CriaVar("C7_NUM", .T.)
	
	//Carrega cabeçalho do pedido de compra
	AAdd(aCabSC7, {"C7_NUM" 	, cNumPed					 	,NIL} )
	AAdd(aCabSC7, {"C7_EMISSAO"	, CriaVar("C7_EMISSAO"	,.T.)	,NIL} )
  	AAdd(aCabSC7, {"C7_FORNECE" , cCodCor						,NIL} )
  	AAdd(aCabSC7, {"C7_LOJA"	, cLojCor						,NIL} )
	AAdd(aCabSC7, {"C7_CONTATO"	, CriaVar("C7_CONTATO"	,.T.)	,NIL} )
  	AAdd(aCabSC7, {"C7_COND"	, cCondPg						,NIL} )  
	AAdd(aCabSC7, {"C7_FILENT"	, CriaVar("C7_FILENT"	,.T.)	,NIL} )
	
	For nCont:=1 To Len( aProdutos )
	
		aAux		:= {}
		cItem		:= StrZero( nCont, TamSx3("C7_ITEM")[1] )
		aDadosSB1	:= JurGetDados ("SB1" , 1, xFilial("SB1") + aProdutos[nCont][1], {"B1_UM", "B1_LOCPAD"} )
		cUnidade	:= "" 
		cLocal		:= ""
	
		//Carrega item do pedido de compra
		If Len( aDadosSB1 ) > 1
			cUnidade:= aDadosSB1[1] 
			cLocal	:= aDadosSB1[2]
		EndIf
				
		AAdd(aAux, {"C7_ITEM"		, cItem					, NIL} )
		AAdd(aAux, {"C7_PRODUTO"	, aProdutos[nCont][1]	, NIL} )
		AAdd(aAux, {"C7_UM"			, cUnidade				, NIL} )
		AAdd(aAux, {"C7_PRECO"		, aProdutos[nCont][2]	, NIL} )
		AAdd(aAux, {"C7_QUANT"		, 1						, NIL} )
		AAdd(aAux, {"C7_TOTAL"		, aProdutos[nCont][2]	, NIL} )
		AAdd(aAux, {"C7_LOCAL"		, cLocal				, NIL} )
		
		//Carrega itens
		Aadd(aItemSC7, aAux)
	Next nCont
	

	//Inclui pedido de compra
	MSExecAuto( {|v,x,y,z,w| MATA120(v,x,y,z,w)}, 1, aCabSC7, aItemSC7, 3, .F.)//Efetua a operacao
	
	If lMsErroAuto
		lRetorno:= .F.
		cErro 	:= MostraErro()
	EndIf
	
	RestArea(aArea)

Return lRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuExtrato
Atualiza dados no extrato do correspondente NZF

@return	
@author Rafael Tenorio da Costa
@since 07/05/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function AtuExtrato( cNumPag, cTipPag, cMarca, cAgrupExt, cCodCor	,;
							cLojCor, cEscri , cArea , cCodCli  , cLojCli 	)

	Local aArea		:= GetArea()
	Local lRetorno	:= .F.
	Local oModel 	:= FWLoadModel("JURA192")
	Local cTabPgto	:= GetNextAlias()
	Local cQuery	:= ""
	
	cQuery := "SELECT NZF.R_E_C_N_O_ RECNONZF "
	cQuery += " FROM " +RetSqlName("NZF")+ " NZF "
	cQuery += " WHERE NZF_FILIAL = '"	+xFilial("NZF")+		"' " + CRLF
	cQuery += 	" AND NZF_OK = '"		+cMarca+ 				"' " + CRLF
	cQuery += 	" AND NZF_CCORRE = '" 	+cCodCor			+	"' " + CRLF
  	cQuery += 	" AND NZF_LCORRE = '" 	+cLojCor			+	"' " + CRLF
	
	//1=Correspondente/Escritorio/Area/Cliente/Periodo
	If cAgrupExt == "1"

		cQuery += 	" AND NZF_CESCRI = '" 	+cEscri	+	"' " + CRLF
		cQuery += 	" AND NZF_CAREA = '" 	+cArea	+	"' " + CRLF
		cQuery += 	" AND NZF_CCLIEN = '" 	+cCodCli+	"' " + CRLF
		cQuery += 	" AND NZF_LCLIEN = '" 	+cLojCli+	"' " + CRLF
	EndIf
	
	cQuery += " AND NZF.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTabPgto, .F., .T.)
	
	While !(cTabPgto)->( Eof() )
	
		NZF->( DbGoto( (cTabPgto)->RECNONZF ) )
		
		If !NZF->( Eof() )
		
			oModel:SetOperation( 4 )
			oModel:Activate()
			
			oModel:LoadValue("NZFMASTER", "NZF_TIPPAG"	, cTipPag)
			oModel:LoadValue("NZFMASTER", "NZF_NUMPAG"	, cNumPag) 
			oModel:LoadValue("NZFMASTER", "NZF_STATUS"	, "4")		//Encerrado
			oModel:LoadValue("NZFMASTER", "NZF_OK"		, "")
			
			If ( lRetorno := oModel:VldData() )
				oModel:CommitData()
			EndIf
			
			oModel:DeActivate()
		EndIf
	
		(cTabPgto)->( DbSkip() )
	EndDo

	(cTabPgto)->( DbCloseArea() )
	RestArea( aArea )

Return lRetorno