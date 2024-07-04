#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "Oga430G.ch"

Static _cCodCTR	:=''

//------------------------------------------------------------------------------
/*/{Protheus.doc} oga430g(cCodctr, cItemFix, cCodRom, cItemRom)

Rotina que lista as nfs. de compl. vinculadas ou emitidas  
do Ctrato / fixação do recno corrente da NNC
@Parametros 	cCodCtr 	= 	Codigo do Ctrato
cItemFix	= 	Item da Fixação
cCodRom	= 	Codigo do Romaneio
cItemRom	= 	Item do Romaneio
@owner      Agroindustria
@author      Emerson Coelho
@since       09/10/2013 
@return     nil 
/*/
//------------------------------------------------------------------------------

function oga430g(cCodctr, cItemFix, cCodRom, cItemRom)

	Local aDms		:= FWGetDialogSize(oMainWnd)
	Local oDlg		:= MsDialog():New( aDms[1],aDms[2], aDms[3]/1.7, aDms[4]/1.7, STR0001, , , , , , , , oMainWnd, .T. ) //#"Controle de documentos complementares de preço"

	Private cAliasTmp	:= GetNextAlias()
	_cCodCTR	:= cCodCtr

	oBrowse := FWFormBrowse():New()
	oBrowse:DisableDetails()
	oBrowse:SetDescription( STR0002 ) //#"Notas Fiscais de Complemento do(s) romaneio(s)"
	oBrowse:SetDataQuery(.T.)
	oBrowse:SetQuery( fQuerY(cCodctr, cItemFix, cCodRom, cItemRom) )
	oBrowse:SetMenuDef("OGA430G")
	//oBrowse:AddStatusColumns( { || AT920Status((cAliasTmp)->AA1_CODTEC, cEvento, dDtDe, dDtAte, (cAliasTmp)->ABB_CODIGO) }, { || AT920Legen() } )
	oBrowse:SetColumns( fColumns( cCodCtr ) )
	oBrowse:SetAlias(cAliasTmp)
	oBrowse:SetOwner( odlg )

	aMenu := Menudef()
	oBrowse:AddButton( aMenu[2, 1], aMenu[2,2], Nil, aMenu[2,4], aMenu[2,5], (aMenu[2,4] > 1) )

	oBrowse:Activate()
	oDlg:Activate( ,,,.T.,,, )

	Return

	//------------------------------------------------------------------------------
	/*/{Protheus.doc} fQuerY()

	Monta a Query dos doctos fiscais que deverão ser listados.

	@owner      arthur.colado
	@author      arthur.colado
	@version     V119
	@since       09/10/2013 
	@return     aColumns 
	/*/
//------------------------------------------------------------------------------



Static Function fQuerY(cCtrato, cFixacao, cRomaneio, cItRoman)
	Local lCtrVnd	:= IIF( Posicione( "NJR", 1, xFilial( "NJR" ) + cCtrato, "NJR_TIPO" ) == '2', .t., .f. ) //1 Cpra , 2 Venda
	Local cQuery 	:= ""
	Local cCodCliFor := ''
	Local cLojCliFor := ''
	Local aRtPE430G := {}
	
	If lCtrVnd	//Ctrato de Venda
		cCodCliFor	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODCLI")	// Cod. Cliente
		cLojCliFor	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJCLI")	// Loja Cliente
	Else // Ctr. de Compra
		cCodCliFor	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_CODFOR")	// Cod Forn. Origem
		cLojCliFor	:= Posicione("NJ0",1,FwxFilial("NJ0")+NJR->NJR_CODENT+NJR->NJR_LOJENT,"NJ0->NJ0_LOJFOR")	// Loja Forn. Origem
	EndIF

	//Ponto de entrada para alteração dos dados na localização das notas de Entrada e/ou Saida.
	If ExistBlock("OGA430G1") 
		aRtPE430G := ExecBlock( "OGA430G1",.F.,.F.,{cCodCliFor, cLojCliFor, cCtrato, cRomaneio })
		If ValType(aRtPE430G)=="A" .And. Len(aRtPE430G) > 0 .And. Len(aRtPE430G)== 2
			cCodCliFor	:= IIF(Empty(aRtPE430G[1]), cCodCliFor	, aRtPE430G[1] )					
			cLojCliFor	:= IIF(Empty(aRtPE430G[2]), cLojCliFor	, aRtPE430G[2] )	
		EndIf
	EndIf

	IF lCtrVnd	//Ctrato de Venda
		
		cQuery 	+= " SELECT "
		cQuery	+= 	" 		SF2.F2_EMISSAO, F2_FORMUL, F2_SERIE, F2_DOC, F2_VALMERC, F2_COND, SF2.R_E_C_N_O_ AS F2_RECNO,"
		cQuery 	+= 	" NKC.NKC_CODROM, NKC.NKC_ITEROM, "
        cQuery  += " 'COMPL. AJUSTE FIXAÇÃO         ' AS ORIG_COMPL "
		cQuery	+=	" FROM 		" + RetSqlName("SF2") + " SF2 "

		cQuery += " INNER JOIN 	" + RetSqlName("NKC") + " NKC "
		cQuery += " 		 	 ON NKC.NKC_DOCTO 	= SF2.F2_DOC "
		cQuery += " 			AND NKC.NKC_SERIE 	= F2_SERIE "
		cQuery += " 			AND NKC.D_E_L_E_T_ 	= ' ' "
		cQuery += " 			AND NKC.NKC_FILIAL 	= '" 	+ fwXfilial('NKC') 	+ "'"
		cQuery += " 			AND  NKC.NKC_CODCTR = '"	+ cCtrato 			+ "'"
		cQuery += " 			AND NKC.NKC_ITEMFX 	= '"	+ cFixacao 			+ "'"
		//-- se quiser barrar a nivel de romaneio e item de romaneio somente adicionar as 2 linhas abaixo comentadas.
		//cQuery += " 		AND NKC.NKC_CODROM = '" + cRomaneio + "'"
		//cQuery += " 		AND NKC.NKC_ITEROM = '" + cItRoman + "'"
		cQuery += " WHERE SF2.F2_CLIENTE 	= '" 	+ cCodCliFor 			+ "'"
		cQuery += " 	AND SF2.F2_LOJA 	= '" 	+ cLojCliFor 			+ "'"
		cQuery += " 	AND SF2.F2_FILIAL 	= '" 	+ fWxfilial('SF2') 	+ "'"
		cQuery += " 	AND SF2.D_E_L_E_T_ 	= ' '"

        /* BUSCA COMPLEMENTOS EMITIDOS NA ORIGEM - OGA250*/
        If TableInDic("N8J") .AND. TableInDic("ND4")
            cQuery += " UNION ALL "            
            cQuery += " SELECT SF2.F2_EMISSAO,  "
            cQuery += "        SF2.F2_FORMUL,   "
            cQuery += "        SF2.F2_SERIE,    "
            cQuery += "        SF2.F2_DOC,      "
            cQuery += "        SF2.F2_VALMERC,  "
            cQuery += "        SF2.F2_COND,     "
            cQuery += "        SF2.R_E_C_N_O_ AS F2_RECNO,  "
            cQuery += "        NJM.NJM_CODROM AS NKC_CODROM,              "
            cQuery += "        NJM.NJM_ITEROM AS NKC_ITEROM,               "
            cQuery += "        'COMPL. ROMANEIO DE ORIGEM' AS ORIG_COMPL "
            cQuery += " FROM " + RetSqlName("NJM") + " NJM "
            cQuery += " INNER JOIN " + RetSqlName("N8J") + " N8J ON N8J.N8J_FILIAL = NJM.NJM_FILIAL AND N8J.N8J_CODROM = NJM.NJM_CODROM AND N8J.N8J_CODCTR = NJM.NJM_CODCTR AND N8J.N8J_TPDOC = 'C' AND N8J.D_E_L_E_T_ = '' "
            cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_FILIAL  = N8J.N8J_FILIAL AND N8J.N8J_DOC    = SF2.F2_DOC AND N8J.N8J_SERIE = SF2.F2_SERIE AND N8J.N8J_CLIFOR = SF2.F2_CLIENTE AND N8J.N8J_LOJA = SF2.F2_LOJA AND SF2.D_E_L_E_T_ = '' "
            cQuery += " WHERE NJM.NJM_CODROM IN (SELECT ND4_ROMREL "
            cQuery += "                         FROM " + RetSqlName("ND4") + " ND4 "
            cQuery += "                         WHERE ND4.ND4_FILIAL = NJM.NJM_FILIAL "
            cQuery += "                         AND ND4.ND4_ROMREL   = NJM.NJM_CODROM "
            cQuery += "                         AND ND4.ND4_TIPREL = 'C' "
            cQuery += "                         AND ND4.D_E_L_E_T_ = '') "            
            cQuery += " AND NJM.NJM_CODCTR = '" + cCtrato + "'"
            cQuery += " AND NJM.D_E_L_E_T_ = '' "
        EndIf
	Else // Ctr. de Compra
		
		cQuery += " SELECT "
		cQuery	+= 	" 		SF1.F1_EMISSAO, F1_FORMUL, F1_SERIE, F1_DOC, F1_VALMERC, F1_COND, SF1.R_E_C_N_O_ AS F1_RECNO, "
		cQuery += 	" NKC.NKC_CODROM, NKC.NKC_ITEROM "
		cQuery +=	" FROM 		" + RetSqlName("SF1") + " SF1 "

		cQuery += " INNER JOIN 	" + RetSqlName("NKC") + " NKC "
		cQuery += " 		 	 ON NKC.NKC_DOCTO 	= SF1.F1_DOC "
		cQuery += " 			AND NKC.NKC_SERIE 	= F1_SERIE "
		cQuery += " 			AND NKC.D_E_L_E_T_ 	= ' ' "
		cQuery += " 			AND NKC.NKC_FILIAL 	= '" + fwXfilial('NKC') + "' "
		cQuery += " 			AND  NKC.NKC_CODCTR	= '" + cCtrato + "' "
		cQuery += " 			AND NKC.NKC_ITEMFX 	= '" + cFixacao + "' "
		cQuery += " WHERE SF1.F1_FORNECE 	= '" + cCodCliFor + "' "
		cQuery += " 	AND SF1.F1_LOJA 	= '" + cLojCliFor + "' "
		cQuery += " 	AND SF1.F1_FILIAL 	= '" + fWxfilial('SF1') + "' "
		cQuery += " 	AND SF1.D_E_L_E_T_ 	= ' ' "
	EndIF

	cQuery :=  ChangeQuery(cQuery)

	Return cQuery

	//------------------------------------------------------------------------------
	/*/{Protheus.doc} fColumns( cCodCtr )

	Define os campos que irão compor o browser, sendo que esses campos da tabela não
	são configurados para exibição no browser

	@owner      arthur.colado
	@author      arthur.colado
	@version     V119
	@since       09/10/2013 
	@return     aColumns 
	/*/
//------------------------------------------------------------------------------

Static Function fColumns( cCodCtr )

	Local aColumns:= {}
	Local nI         := 1
	Local nJ         := 1
	Local aArea    	:= GetArea()
	Local aAreaSX3:= SX3->(GetArea())
	Local aCampos 	:= {}
	Local lCtrVnd		:= IIF( Posicione( "NJR", 1, xFilial( "NJR" ) + cCodCtr, "NJR_TIPO" ) == '2', .t., .f. ) //1 Cpra , 2 Venda

	//    aAdd(aCampos, cCampoDt)
	//    aAdd(aCampos, cCampoHr)

	aAdd(aCampos, "NKC_CODROM")
	aAdd(aCampos, "NKC_ITEROM")
	IF lCtrVnd //Ctrato de Venda
		aAdd(aCampos, "F2_EMISSAO")
		aAdd(aCampos, "F2_FORMUL")
		aAdd(aCampos, "F2_SERIE")
		aAdd(aCampos, "F2_DOC")
		aAdd(aCampos, "F2_VALMERC")
		aAdd(aCampos, "F2_COND")
        aAdd(aCampos, "ORIG_COMPL")
	Else
		aAdd(aCampos, "F1_EMISSAO")
		aAdd(aCampos, "F1_FORMUL")
		aAdd(aCampos, "F1_SERIE")
		aAdd(aCampos, "F1_DOC")
		aAdd(aCampos, "F1_VALMERC")
		aAdd(aCampos, "F1_COND")
	EndIF	

	For nI := 1 To Len(aCampos)
		If ALLTRIM(aCampos[nI]) != 'ORIG_COMPL'
            SX3->(dbSetOrder(2))
            If SX3->(dbSeek( aCampos[nI] ))
                
                AAdd( aColumns, FWBrwColumn():New() )
                
                If TamSx3(aCampos[nI])[3] == "D"
                    aColumns[nJ]:SetData( &("{||STOD(" + aCampos[nI] + ")}") )
                Else
                    aColumns[nJ]:SetData( &("{||" + aCampos[nI] + "}") )
                EndIf
                
                aColumns[nJ]:SetTitle( X3Titulo() )

                aColumns[nJ]:SetSize( TamSx3(aCampos[nI])[1] )
                aColumns[nJ]:SetDecimal( TamSx3(aCampos[nI])[2] )
                aColumns[nJ]:SetPicture( X3PICTURE(aCampos[nI]) )
                aColumns[nJ]:SetAlign( If(TamSx3(aCampos[nI])[3] == "N",CONTROL_ALIGN_RIGHT,CONTROL_ALIGN_LEFT) )//Define alinhamento                

                nJ++
            EndIf
        Else                
            AAdd( aColumns, FWBrwColumn():New() )
            aColumns[nJ]:SetData( &("{||" + aCampos[nI] + "}") )                
            
            aColumns[nJ]:SetTitle( "Origem Compl." )

            aColumns[nJ]:SetSize( 30 )
            aColumns[nJ]:SetDecimal( 0 )
            aColumns[nJ]:SetPicture( "@!" )
            aColumns[nJ]:SetAlign( CONTROL_ALIGN_CENTER )//Define alinhamento
            nJ++
        EndIf
	Next nI


	RestArea(aAreaSX3)
	RestArea(aArea)

Return aColumns



/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		OGA280 - Contratos
*/
Static Function MenuDef()
	Private aRotina := {}

	aAdd( aRotina, { STR0003		, "PesqBrw"        	, 0, 1, 0, .t. } ) //"Pesquisar"
	aAdd( aRotina, { STR0004		, "StaticCall(OGA430G,fShowDoc)"			, 0, 2, 0, Nil } ) //"Visualizar"
	//	aAdd( aRotina, { STR0011   	, "ViewDef.OGA280"	, 0, 3, 0, Nil } ) //"Incluir"
	//	aAdd( aRotina, { STR0012   	, "ViewDef.OGA280"	, 0, 4, 0, Nil } ) //"Alterar"
	//	aAdd( aRotina, { STR0017   	, "ViewDef.OGA280"	, 0, 5, 0, Nil } ) //"Excluir"
	//	aAdd( aRotina, { STR0018  	, "ViewDef.OGA280"	, 0, 8, 0, Nil } ) //"Imprimir"
	//	aAdd( aRotina, { STR0020    , "ViewDef.OGA280"	, 0, 9, 0, Nil } ) //"Copiar"
Return( aRotina )


/** {Protheus.doc} fShowdoc
Função q faz chamada a função de Viusualizar do Mata103

@param: 	Nil
@return:	Nil
@author: 	ECoelho
@since: 	18/02/2015
@Uso: 		Agroindustria
*/

Static Function fShowDoc()


	Local aAreaAtu 	:= GetArea()
	Local aAreaSF1 	:= SF1->( GetArea() )
	Local aAreaSF2 	:= SF2->( GetArea() )
	Local lCtrVnd	:= IIF( Posicione( "NJR", 1, xFilial( "NJR" ) + _cCodCtr, "NJR_TIPO" ) == '2', .t., .f. ) //1 Cpra , 2 Venda
	Private aRotina	:= menudef() 						//-- Utilizado no A103NFISCAL --//

	IF lCtrVnd   // Ctrato de Venda
		DbSelectArea( "SF2" )
		SF2->(DbGoto( (cAliasTmp)->F2_RECNO ) ) 		//--Posiciona na NF a Visualizar --//
		Mc090Visual( "SF2", (cAliasTmp)->F2_RECNO , 2 ) // Visualização da NF de Saída
		// A410Visual( "SC5", SC5->( Recno() ), 2 )	// Visualização do Pedido de Vendas 
	Else
		DbSelectArea('SF1')
		SF1->(DbGoto( (cAliasTmp)->F1_RECNO ) ) 		//--Posiciona na NF a Visualizar --//
		a103NFISCAL("SF1", (cAliasTmp)->F1_RECNO , 2 )	//-- Rotina de visualizar do Mata103 --//
	EndIF

	RestArea(aAreaSF2)	
	RestArea(aAreaSF1)
	RestArea(aAreaAtu)

Return
