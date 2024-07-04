#INCLUDE "AGRA620.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

//Removidos de Private por nao se usar fora da tela 
Static oMkBrw01
Static __lnewNeg	:= SuperGetMv('MV_AGRO002', , .F.) // Parametro de utilização do novo modelo de negocio
Static aFardoesMk   := {}
Static __cMVTpReq 	:= SuperGetMV("MV_AGRB002", ,"N")

/*/{Protheus.doc} AGRA620
Rotina para geração da movimentação de estoque baseado na seleção
de fardões em beneficiamento que serao finalizados.
@author joaquim.burjack
@since 02/05/2016
@type function
/*/
Function AGRA620()
	Local cFiltro	:= ''
	Local cUserBenf := A655GETUNB()// Busca a unidade de beneficiamento
	Local aArea 	:= GetArea()

	If Pergunte( 'AGRA620001', .T. )
		dbSelectArea("DXL")

		cFiltro += "@DXL_STATUS='" + IIf( mv_par03=1, "6", "5" ) + "' "

		If !Empty(mv_par01)
			cFiltro += " And DXL_CODCNJ='" + mv_par01 + "' "
		Else
			cFiltro += " And DXL_CODCNJ <> ' '"
		Endif

		If !Empty(mv_par02)
			cFiltro += " And DXL_LOCAL='" + mv_par02 + "' "
		Endif

		If !Empty(mv_par06)
			cFiltro += " And DXL_DTBEN >='" +  DTOS(mv_par06 )+ "' "
		Endif

		If !Empty(mv_par07)
			cFiltro += " And DXL_DTBEN <='" + DTOS(mv_par07 ) + "' "
		Endif

		If !Empty(mv_par08)
			cFiltro += " And DXL_SAFRA >='" + mv_par08 + "' "
		Endif

		If !Empty(mv_par09)
			cFiltro += " And DXL_SAFRA <='" + mv_par09 + "' "
		Endif

		If !Empty(mv_par10)
			cFiltro += " And DXL_PRDTOR >='" + mv_par10 + "' "
		Endif

		If !Empty(mv_par12)
			cFiltro += " And DXL_PRDTOR <='" + mv_par12 + "' "
		Endif

		If !Empty(mv_par11)
			cFiltro += " And DXL_LJPRO >='" + mv_par11 + "' "
		Endif

		If !Empty(mv_par13)
			cFiltro += " And DXL_LJPRO <='" + mv_par13 + "' "
		Endif

		If !Empty(mv_par14)
			cFiltro += " And DXL_FAZ >='" + mv_par14+ "' "
		Endif

		If !Empty(mv_par15)
			cFiltro += " And DXL_FAZ <='" + mv_par15 + "' "
		Endif

		If mv_par03!= 1
			dbSelectArea("DXL")
			if DXL->(ColumnPos('DXL_CODUNI' )) > 0
				cFiltro += " AND DXL_PSLIQU > 0"
				cFiltro += " AND (DXL_CODROM <> ' ' OR EXISTS(SELECT DX0_CODUNI FROM " + RetSqlName('DX0') + " DX0 "
				cFiltro += " INNER JOIN " + RetSqlName('DXL') + " DXL ON "
				cFiltro += " DXL.DXL_FILIAL = '" + fwxFilial('DXL') + "' "
				cFiltro += " AND DXL.DXL_CODUNI = DX0.DX0_CODUNI  "
				cFiltro += " AND DXL.D_E_L_E_T_ = ' ' "
				cFiltro += " AND DX0.D_E_L_E_T_ = ' ' ))"
			Else
				cFiltro += " and DXL_PSLIQU > 0 and DXL_CODROM <> ' ' "
			Endif
		Endif
		//Trata Unidade de Beneficiamento
		If !Empty(cUserBenf)
			cFiltro += " AND DXL_CODUNB = '" + cUserBenf + "' "
		Endif

		RestArea(aArea)

		oMkBrw01 := FwMarkBrowse():New()
		oMkBrw01:SetAlias( 'DXL' )
		oMkBrw01:SetDescription( STR0001 ) //"Selecione os Fardões"
		// Acidiona Legenda no browser
		oMkBrw01:AddLegend( "DXL_STATUS == '5'", 'RED'   , AGRTxtBox('5','DXL_STATUS') ) //"Beneficiado"
		oMkBrw01:AddLegend( "DXL_STATUS == '6'", 'BLACK' , AGRTxtBox('6','DXL_STATUS') ) //"Finalizado"
		oMkBrw01:SetFieldMark( 'DXL_OK' )
		// Seta o filtro padrao do browser
		oMkBrw01:SetFilterDefault(cfiltro)
		oMkBrw01:SetAmbiente(.F.)
		oMkBrw01:SetSemaphore(.F.)
		oMkBrw01:DisableLocate()
		oMkBrw01:DisableDetails()
		// Ativa o browser
		oMkBrw01:Activate()

		/*Ao sair da rotina, limpa a DXL_OK dos fardões que foram selecionados mas que não sofreram nenhuma alteração. 
		 Para não gerar inconsistências e estornar fardões que não foram selecionados naquele momento - BF*/
		
		cFiltro += " AND DXL_OK <> ' '" 
		DXL->(dbSetFilter({||&cFiltro},cFiltro))
		DXL->(dbGotop())	
		While !DXL->(Eof() )
			If oMkBrw01:IsMark(oMkBrw01:Mark())
				Reclock('DXL', .F.)
				DXL->DXL_OK := ''
				MsUnlock()	
			EndIf
		DXL->(dbSkip())
		EndDo
		
	EndIf
Return()

/*/{Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina
@author joaquim.burjack
@since 02/05/2016
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { STR0004	, 'AGRA620PRC'	, 0, 1, 0, NIL } ) //"Processar"]

	If ExistBlock('AGR620MEN')
		aRet := ExecBlock('AGR620MEN',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf

Return( aRotina )

/*/{Protheus.doc} AGRA620PRC
Determina se o processo e de Inclusao ou estorno 
@author joaquim.burjack
@since 02/05/2016
@type function
/*/
Function AGRA620PRC()
	Local nx

	IniPerg620() //-- proteção campos do pergunte incluido a partir release 12.1.33, limpando e redefinindo o pergunte
	
	If (mv_par03 = 1)
		MsgRun( STR0005 , STR0006 , {|| A620Estorn(oMkBrw01) }) //"Estornando movimento de estoque"###"Estornando"
	Else
		A620Inclui(oMkBrw01)
	EndIf

	For nx := 1 To Len(aFardoesMk) //Após realizar o encerramento/estorno limpa o flag da DXL_OK
		DbSelectArea( 'DXL' )
		DBClearFilter()
		DXL->(dbSetOrder(1))
		If DXL->(MsSeek(FWxFilial('DXL') + aFardoesMk[nx][2] + aFardoesMk[nx][3] + aFardoesMk[nx][4] + aFardoesMk[nx][5] + aFardoesMk[nx][6]) )
			Reclock('DXL', .F.)
			DXL->DXL_OK := ''
			MsUnlock()
		Endif
	Next nx

	oMkBrw01:Refresh(.T.)

Return()

/*/{Protheus.doc} A620Inclui
Gera grid com as informações de fardões a serem desmontados, desmontagem e produção
@author bruna.rocio
@since 02/05/2016
@param oBrw, object, Browse de seleção
@type function
/*/
Static Function A620Inclui(oBrw)
	Local aAreaAtu		:= GetArea( )
	Local nOpcX 		:= 0
	Local nPsTotal	    := 0
	Local lRet			:= .T.
	Local oPnCab 		:= nil
	Local oPnSup 		:= nil
	Local oPnEsq 		:= nil
	Local oPnDir 		:= nil
	Local aFardoes	    := {}
	Local aDetItens     := {}
	Local aDetProd      := {}
	Local aProd         := {}
	Local cFiltro	    := ''
	Local cUserBenf     := A655GETUNB()// Busca a unidade de beneficiamento


	cFiltro += "@DXL_STATUS='" + IIf( mv_par03=1, "6", "5" ) + "' "

	If !Empty(mv_par01)
		cFiltro += " And DXL_CODCNJ='" + mv_par01 + "' "
	Else
		cFiltro += " And DXL_CODCNJ <> ' '"
	Endif

	If !Empty(mv_par02)
		cFiltro += " And DXL_LOCAL='" + mv_par02 + "' "
	Endif

	If mv_par03!= 1
		cFiltro += " and DXL_PSLIQU > 0 "
	Endif

	//Trata Unidade de Beneficiamento
	If !Empty(cUserBenf)
		cFiltro += " AND DXL_CODUNB = '" + cUserBenf + "' "
	Endif

	If !Empty(mv_par06)
		cFiltro += " And DXL_DTBEN >='" +  DTOS(mv_par06 )+ "' "
	Endif

	If !Empty(mv_par07)
		cFiltro += " And DXL_DTBEN <='" + DTOS(mv_par07 ) + "' "
	Endif

	If !Empty(mv_par08)
		cFiltro += " And DXL_SAFRA >='" + mv_par08 + "' "
	Endif

	If !Empty(mv_par09)
		cFiltro += " And DXL_SAFRA <='" + mv_par09 + "' "
	Endif

	If !Empty(mv_par10)
		cFiltro += " And DXL_PRDTOR >='" + mv_par10 + "' "
	Endif

	If !Empty(mv_par12)
		cFiltro += " And DXL_PRDTOR <='" + mv_par12 + "' "
	Endif

	If !Empty(mv_par11)
		cFiltro += " And DXL_LJPRO >='" + mv_par11 + "' "
	Endif

	If !Empty(mv_par13)
		cFiltro += " And DXL_LJPRO <='" + mv_par13 + "' "
	Endif

	If !Empty(mv_par14)
		cFiltro += " And DXL_FAZ >='" + mv_par14+ "' "
	Endif

	If !Empty(mv_par15)
		cFiltro += " And DXL_FAZ <='" + mv_par15 + "' "
	Endif

	//-------------------
	// Fardões
	//-------------------
	dbSelectArea('DXL')
	DXL->( dbSetOrder(0) )
	DXL->(dbSetFilter({||&cFiltro},cFiltro))
	DXL->( dbGotop() )
	While !DXL->( Eof() )
		If oBrw:IsMark(oBrw:Mark())
			nPsTotal += DXL->DXL_PSLIQU
			If DXL->(ColumnPos('DXL_FILBEN')) >0
				aAdd( aFardoes, {DXL->DXL_CODIGO, DXL->DXL_CODPRO, DXL->DXL_LOCAL, DXL->DXL_PSLIQU, '', DXL->(Recno()), DXL->DXL_CODCNJ, DXL->DXL_LOTCTL, DXL->DXL_NMLOT, DXL->DXL_LOCLIZ, DXL->DXL_FILBEN} )
			Else
				aAdd( aFardoes, {DXL->DXL_CODIGO, DXL->DXL_CODPRO, DXL->DXL_LOCAL, DXL->DXL_PSLIQU, '', DXL->(Recno()), DXL->DXL_CODCNJ} )
			Endif
			//Populando array para posteriomente limpar o campo DXL_OK de todos os fardões marcados - Para evitar falha de integridade
			aAdd(aFardoesMk, {DXL->DXL_FILIAL, DXL->DXL_CODIGO, DXL->DXL_SAFRA, DXL->DXL_PRDTOR, DXL->DXL_LJPRO, DXL->DXL_FAZ})			
		EndIf
		DXL->( dbSkip() )
	EndDo

	//----------------------------------------
	// Se não há fardões selecionados, volta
	//----------------------------------------
	If Len( aFardoes ) = 0
		lRet := .F.
		Help(' ',1,'AGR620PROC')
	EndIf

	//-------------------------------------------------------------
	// Busca os itens para desmontagem e produção
	//-------------------------------------------------------------
	AGRA620CIT(nPsTotal,aFardoes,@aDetItens,@aProd,@aDetProd)

	If lRet
		If !Empty(aDetItens)
			//---------------------------
			// Define tamanho da Dialog
			//---------------------------
			oSize := FwDefSize():New()
			oSize:AddObject( 'DLG', 100, 100, .t., .t. )
			oSize:lProp 	:= .t.
			oSize:aMargins 	:= { 3, 3, 3, 3 }
			oSize:Process()

			//-----------------------------------------------------------------
			// Cria Dialog -> "Quantidades/Percentuais de Separação/Produção"
			//-----------------------------------------------------------------
			oDlg := TDialog():New( oSize:aWindSize[ 1 ], oSize:aWindSize[ 2 ], oSize:aWindSize[ 3 ], oSize:aWindSize[ 4 ], STR0007,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

			//----------------------------------------------
			// Cria Panel
			//----------------------------------------------
			oPnl:= tPanel():New( oSize:GetDimension('DLG','LININI'),oSize:GetDimension('DLG','COLINI'),,oDlg,,,,,,oSize:GetDimension('DLG','XSIZE'),oSize:GetDimension('DLG','YSIZE'))

			//----------------------------------------------
			//Instancia layer para criação de windows
			//----------------------------------------------
			oFwLayer := FwLayer():New()
			oFwLayer:Init( oPnl, .F., .T. )

			//----------------------------------------------
			//Adiciona linhas para divisão dos painéis
			//----------------------------------------------
			oFWLayer:AddLine( "CAB", 15 , .T. )
			oFWLayer:AddLine( "SUP", 40, .T. )
			oFWLayer:AddLine( "INF", 45, .T. )

			//----------------------------------------------
			//Adiciona coluna para organização dos painéis
			//----------------------------------------------
			oFWLayer:AddCollumn( "CBC" , 100, .F., "CAB" )
			oFWLayer:AddCollumn( "FAR" , 100, .F., "SUP" )
			oFWLayer:AddCollumn( "ESQ" ,  50, .F., "INF" )
			oFWLayer:AddCollumn( "DIR" ,  50, .F., "INF" )

			//----------------------------------------------
			//Adiciona windows que receberão os painés
			//----------------------------------------------
			oFWLayer:AddWindow( "CBC" , "PCB", '' 		     , 100, .f., .t., {||}, "CAB" ) //"Cabeçalho"
			oFWLayer:AddWindow( "FAR" , "PSP", 'Fardões'     , 100, .f., .t., {||}, "SUP" ) //"Fardões"
			oFWLayer:AddWindow( "ESQ" , "PNE", 'Desmontagem' , 100, .f., .t., {||}, "INF" ) //"Desmontagem"
			oFWLayer:AddWindow( "DIR" , "PND", 'Produção'	 , 100, .f., .t., {||}, "INF" ) //"Produção"

			//Cria os painéis
			oPnCab := oFwLayer:GetWinPanel( "CBC", "PCB", "CAB" )
			oPnSup := oFWLayer:GetWinPanel( "FAR", "PSP", "SUP" )
			oPnEsq := oFWLayer:GetWinPanel( "ESQ", "PNE", "INF" )
			oPnDir := oFWLayer:GetWinPanel( "DIR", "PND", "INF" )

			//---------------------------------------------
			//Define tamanho do painel do cabeçalho
			//---------------------------------------------
			oSizeCB := FwDefSize():New()
			oSizeCB:AddObject( "CB0", 100, 100, .t., .t. )
			oSizeCB:SetWindowSize( { 0, 0, oPnCab:nHeight, oPnCab:nWidth } )
			oSizeCB:lProp 	:= .t.
			oSizeCB:aMargins := { 0, 0, 0, 0 }
			oSizeCB:Process()


			//"Quantidade de Fardões : [ "###" ]"
			cSay1 := STR0008 + AllTrim( Transform( Len( aFardoes ), '9,999' ) ) + STR0009
			//"Peso Liquido Total : [ "###" ]"
			cSay2 := STR0010 + AllTrim( Transform( nPsTotal, PesqPict( 'DXL', 'DXL_PSLIQU' ) ) ) + STR0009

			@ 001,030  Say cSay1 Of oPnCab COLOR CLR_BLACK Pixel
			@ 017,030  Say cSay2 Of oPnCab COLOR CLR_BLACK Pixel

			//Define tamanho do painel superior
			oSizeSU := FwDefSize():New()
			oSizeSU:AddObject( "SU0", 100, 100, .t., .t. )
			oSizeSU:SetWindowSize( { 0, 0, oPnSup:nHeight, oPnSup:nWidth } )
			oSizeSU:lProp 	:= .t.
			oSizeSU:aMargins := { 0, 0, 0, 0 }
			oSizeSU:Process()

			//----------------------------------------------------------------------------
			//Monta Browser Superior
			//----------------------------------------------------------------------------
			oBrwSuper := TCBrowse():New( 01, oSizeSU:GetDimension('SU0','COLINI'), oSizeSU:GetDimension('SU0','XSIZE'), oSizeSU:GetDimension('SU0','YSIZE'), , {}, {}, oPnSup,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
			oBrwSuper:AddColumn( TCColumn():New( STR0011 , { || aFardoes[oBrwSuper:nAt, 1] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) )  //"Fardão"
			oBrwSuper:AddColumn( TCColumn():New( STR0012 , { || aFardoes[oBrwSuper:nAt, 2] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) )  //"Produto"
			oBrwSuper:AddColumn( TCColumn():New( STR0013 , { || aFardoes[oBrwSuper:nAt, 3] }	,,,,'LEFT',,.F.,.T.,,,,.F.,) )   //"Local"
			oBrwSuper:AddColumn( TCColumn():New( STR0014 , { || aFardoes[oBrwSuper:nAt, 4] }	,,,,'RIGHT' ,,.F.,.T.,,,,.F.,) ) //"Peso Líquido"
			if DXC->(ColumnPos('DXC_LOTCTL')) > 0
				oBrwSuper:AddColumn( TCColumn():New( STR0039 , { || aFardoes[oBrwSuper:nAt, 8] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) )  //"Lote"
				oBrwSuper:AddColumn( TCColumn():New( STR0040 , { || aFardoes[oBrwSuper:nAt, 9] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) )  //"Sublote"
				oBrwSuper:AddColumn( TCColumn():New( STR0041 , { || aFardoes[oBrwSuper:nAt,10] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) )  //"Localização"
			endIf
			oBrwSuper:AddColumn( TCColumn():New( ""		 , { || aFardoes[oBrwSuper:nAt, 5] }	,,,,'RIGHT',,.F.,.T.,,,,.F.,) )
			oBrwSuper:SetArray( aFardoes )

			//----------------------------------------------------------------------------
			//Monta Browsers Inferiores
			//----------------------------------------------------------------------------

			//-------------------------------------------------------
			//Define tamanho do painel inferior	esquerdo
			//-------------------------------------------------------
			oSizeLF := FwDefSize():New()
			oSizeLF:AddObject( "IF0", 100, 100, .t., .t. )
			oSizeLF:SetWindowSize( { 0, 0, oPnEsq:nHeight, oPnEsq:nWidth } )
			oSizeLF:lProp 	:= .t.
			oSizeLF:aMargins := { 0, 0, 0, 0 }
			oSizeLF:Process()

			//------------------------------------------------------
			//Monta Browse Inferior Esquerdo
			//------------------------------------------------------
			oBrwEsq := TCBrowse():New( 01, oSizeLF:GetDimension('IF0','COLINI'), oSizeLF:GetDimension('IF0','XSIZE'), oSizeLF:GetDimension('IF0','YSIZE'), , {}, {}, oPnEsq,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
			oBrwEsq:AddColumn( TCColumn():New( STR0012 	, { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt, 1] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Produto"
			oBrwEsq:AddColumn( TCColumn():New( STR0015 	, { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt, 2] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Descrição"
			oBrwEsq:AddColumn( TCColumn():New( STR0016	, { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt, 3] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Unidade Medida"
			oBrwEsq:AddColumn( TCColumn():New( STR0017	, { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt, 5] }	,,,,'RIGHT',,.F.,.T.,,,,.F.,) ) //"Percentual"
			oBrwEsq:AddColumn( TCColumn():New( STR0018	, { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt, 4] }	,,,,'RIGHT',,.F.,.T.,,,,.F.,) ) //"Quantidade"
			oBrwEsq:AddColumn( TCColumn():New( STR0013  , { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt, 6] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Local"
			oBrwEsq:AddColumn( TCColumn():New( STR0029 	, { || Iif(aDetItens[oBrwSuper:nAt,oBrwEsq:nAt,7]  = '1', STR0026  , STR0027  ) }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) )
			if DXC->(ColumnPos('DXC_LOTCTL')) > 0
				oBrwEsq:AddColumn( TCColumn():New( STR0039  , { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt,10] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Lote"
				oBrwEsq:AddColumn( TCColumn():New( STR0040 	, { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt,11] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Sublote"
				oBrwEsq:AddColumn( TCColumn():New( STR0041  , { || aDetItens[oBrwSuper:nAt,oBrwEsq:nAt,12] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Localização"
			endIf
			oBrwEsq:SetArray( aDetItens[oBrwSuper:nAt] )

			//-------------------------------------------------------
			//Define tamanho do painel inferior	direito
			//-------------------------------------------------------
			oSizeRT := FwDefSize():New()
			oSizeRT:AddObject( "IF1", 100, 100, .t., .t. )
			oSizeRT:SetWindowSize( { 0, 0, oPnDir:nHeight, oPnDir:nWidth } )
			oSizeRT:lProp 	:= .t.
			oSizeRT:aMargins := { 0, 0, 0, 0 }
			oSizeRT:Process()

			//------------------------------------------------------
			//Monta Browse Inferior Direito
			//------------------------------------------------------
			oBrwDir := TCBrowse():New( 01, oSizeRT:GetDimension('IF1','COLINI'), oSizeRT:GetDimension('IF1','XSIZE'), oSizeRT:GetDimension('IF1','YSIZE'), , {}, {}, oPnDir,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
			If Len(aDetProd) > 0

				oBrwDir:AddColumn( TCColumn():New( STR0012 	, { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt, 1] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Produto"
				oBrwDir:AddColumn( TCColumn():New( STR0015 	, { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt, 2] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Descrição"
				oBrwDir:AddColumn( TCColumn():New( STR0016	, { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt, 3] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Unidade Medida"
				oBrwDir:AddColumn( TCColumn():New( STR0013	, { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt, 5] }	,,,,'RIGHT',,.F.,.T.,,,,.F.,) ) //"Local"
				oBrwDir:AddColumn( TCColumn():New( STR0018	, { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt, 4] }	,,,,'RIGHT',,.F.,.T.,,,,.F.,) ) //"Quantidade"
				oBrwDir:AddColumn( TCColumn():New( STR0032  , { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt, 6] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"TM"
				if DXC->(ColumnPos('DXC_LOTPRD')) > 0
					oBrwDir:AddColumn( TCColumn():New( STR0039  , { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt,14] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Lote"
					oBrwDir:AddColumn( TCColumn():New( STR0040  , { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt,15] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Sublote"
					oBrwDir:AddColumn( TCColumn():New( STR0041  , { || aDetProd[oBrwSuper:nAt,oBrwDir:nAt,16] }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Localização"
				endIf
				oBrwDir:SetArray( aDetProd[oBrwSuper:nAt] )
			Else
				oBrwDir:AddColumn( TCColumn():New( STR0012 	, { || }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Produto"
				oBrwDir:AddColumn( TCColumn():New( STR0015 	, { || }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Descrição"
				oBrwDir:AddColumn( TCColumn():New( STR0016	, { || }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Unidade Medida"
				oBrwDir:AddColumn( TCColumn():New( STR0013	, { || }	,,,,'RIGHT',,.F.,.T.,,,,.F.,) ) //"Local"
				oBrwDir:AddColumn( TCColumn():New( STR0018	, { || }	,,,,'RIGHT',,.F.,.T.,,,,.F.,) ) //"Quantidade"
				oBrwDir:AddColumn( TCColumn():New( STR0032  , { || }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"TM"
				oBrwDir:AddColumn( TCColumn():New( STR0039  , { || }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Lote"
				oBrwDir:AddColumn( TCColumn():New( STR0040  , { || }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Sublote"
				oBrwDir:AddColumn( TCColumn():New( STR0041  , { || }	,,,,'LEFT' ,,.F.,.T.,,,,.F.,) ) //"Localização"
			Endif

			//----------------------------------------------------------------------------
			//Faz relacionamento Browser Superior x Browsers Inferiores
			//----------------------------------------------------------------------------
			oBrwSuper:bChange := {|| AtuBrwInf(oBrwSuper, @oBrwEsq, @oBrwDir, @aDetItens, @aDetProd)}

			oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, {|| nOpcX := 1, oDlg:End() } , {|| nOpcX := 0, oDlg:End() } ) )

			If nOpcX = 1
				MsgRun( STR0021 , STR0022 , {|| AGRA620GRV(oBrw, aFardoes, aDetItens, aDetProd, aProd) }) //"Gerando movimentações de estoque..."###"Aguarde"
			Endif

		EndIf

	EndIf
	RestArea( aAreaAtu )
Return()


/**----------------------------------------------------------------------------
{Protheus.doc} AtuBrwInf
Atualiza o Browser inferior na mudança da linha do Browser Superior

@param oBrwSuper, object, Objeto Browser/Grid Superior da tela
@param oBrw, object, Objeto Browser/Grid Inferior da tela
@author	Aecio Ferreira Gomes
@since 	14/03/2013
@uso: 		Generico
@type function
----------------------------------------------------------------------------**/
Static Function AtuBrwInf(oBrwSuper, oBrwEsq, oBrwDir, aDetItens, aDetProd)

	oBrwEsq:SetArray(aDetItens[oBrwSuper:nAt])
	oBrwEsq:Refresh()

	If Len(aDetProd) > 0
		oBrwDir:SetArray(aDetProd[oBrwSuper:nAt])
		oBrwDir:Refresh()
	Endif

Return()

/*/{Protheus.doc} AGRA620CIT
Gera gride com as informações de desmontagem dos fardões.
@author joaquim.burjack
@since 02/05/2016
@type function
/*/
Function AGRA620CIT(nPsTotal,aDXL,aDetItens,aProd,aDetProd)
	Local aAreaAtu	:= GetArea()
	Local nX		:= 1
	Local nQuant    := 0
	Local nPerc     := 0
	Local nTotPLU   := 0
	Local nTotRest  := 0
	Local nY   		:= 0
	Local nZ  		:= 0
	Local lProd     := .f.
	Local cFilAntTmp := cFilAnt
	Local nPsLiqPluma := 0
	Local dLoteProd := STOD("")

	aDetItens := {}
	aProd     := {}
	aDetProd  := {}

	For nX := 1 to Len(aDXL)

		nPsLiqPluma := A620RETPS(aDXL[nX,6])[2] // Busca o peso líquido de algodão em pluma originado do fardão

		If DXL->(ColumnPos('DXL_FILBEN')) > 0 .AND. !Empty(aDXL[nX,11])//Filial em que foi realizado o beneficiamento
			cFilAnt := aDXL[nX,11]
		EndIf

		lProd := .f.
		nZ++
		aAdd( aDetItens, {} )

		nY++
		aAdd(aDetProd, {})

		nTotVar := 	aDXL[nX,4] - (nPsLiqPluma + A620Fixo(aDXL[nX,7],aDXL[nX,4]) )
		DXC->( dbSetOrder( 2 ) )
		DXC->( dbSeek( fwxFilial( 'DXC' ) + aDXL[nX,7] ) ) //Conjunto do Fardão
		While .Not. DXC->( Eof() ) .And. DXC->( DXC_FILIAL ) = fwxFilial( 'DXC' ) .And. DXC->( DXC_CODIGO ) = aDXL[nX,7] //Conjunto

			nPerc 	:= 0
			nQuant 	:= 0
			
			SB1->( dbSetOrder( 1 ) )
			SB1->( dbSeek( fwxFilial( 'SB1' ) + DXC->( DXC_CODPRO ) ) )

			If DXC->( DXC_PLUMA ) = '1' // Se for produtor pluma
				nQuant	:= nPsLiqPluma 
				nPerc   := Round( ( ( nQuant * 100 ) / aDXL[nX,4] ), TamSX3( 'DXC_PERC' )[2] )
				nTotPLU += nQuant
			Else
				If DXC->( DXC_TIPO ) = '1'
					nPerc 	 := DXC->( DXC_PERC )
					nQuant  := Round( ( ( aDXL[nX,4] * nPerc ) / 100 ), TamSX3( 'DXL_PSLIQU' )[2] )
				ElseIf DXC->( DXC_TIPO ) = '2'
					nPerc 	:= DXC->( DXC_PERC )
					nQuant 	:= Round( ( ( nTotVar * nPerc ) / 100 ), TamSX3( 'DXL_PSLIQU' )[2] )
					nPerc 	:= Round( ( ( nQuant * 100 ) / aDXL[nX,4] ), TamSX3( 'DXC_PERC' )[2] )
				EndIf
			EndIf

			//---------------------------------------------------------
			//   DADOS DESMONTAGEM
			//---------------------------------------------------------
			if DXC->(ColumnPos('DXC_LOTCTL')) > 0
				aAdd( aDetItens[nZ], { DXC->DXC_CODPRO  ,; 	   // [1] Codigo do Produto
				SB1->B1_DESC         ,; // [2] Descricao do Produto
				SB1->B1_UM           ,; // [3] Unidade de Medida
				nQuant				,; // [4] Quantidade de Separação
				cValTochar( nPerc )  ,; // [5] Percentual de Separação
				DXC->DXC_LOCAL       ,; // [6] Local de Estoque
				DXC->DXC_PLUMA       ,; // [7] Define o produto pluma
				DXC->DXC_RATEIO      ,; // [8] Rateio de custo
				aDXL[nX,6]           ,; // [9] Recno Romaneio
				DXC->DXC_LOTCTL      ,; // [10] Lote
				DXC->DXC_NMLOT       ,; // [11] Sublote
				DXC->DXC_LOCLIZ      ,; // [12] Localização
				DataLote (DXC->DXC_CODPRO,DXC->DXC_LOTCTL )              ,; // [13] Validade
				IIF(SB1->B1_RASTRO = 'N',.F.,.T.);
					})
			else
				aAdd( aDetItens[nZ], { DXC->DXC_CODPRO  ,; 	   // [1] Codigo do Produto
				SB1->B1_DESC         ,; // [2] Descricao do Produto
				SB1->B1_UM           ,; // [3] Unidade de Medida
				nQuant				,; // [4] Quantidade de Separação
				cValTochar( nPerc )  ,; // [5] Percentual de Separação
				DXC->DXC_LOCAL       ,; // [6] Local de Estoque
				DXC->DXC_PLUMA       ,; // [7] Define o produto pluma
				DXC->DXC_RATEIO      ,; // [8] Rateio de custo
				aDXL[nX,6]           ,; // [9] Recno Romaneio
				IIF(SB1->B1_RASTRO = 'N',.F.,.T.);
					})
			endIf

			//---------------------------------------------------------

			//---------------------------------------------------------
			// DADOS PRODUCAO
			//---------------------------------------------------------

			SB1->( dbSeek( fwxFilial( 'SB1' ) + DXC->DXC_PRDPRO ) )

			If DXC->DXC_GRPROD = '1'

				lProd := .t.
				dLoteProd := DataLote (DXC->DXC_CODPRO,DXC->DXC_LOTPRD )

				if DXC->(ColumnPos('DXC_LOTPRD')) > 0
					aAdd(aDetProd[nY], { DXC->DXC_PRDPRO     ,; //[01] Produto
					SB1->B1_DESC        ,; //[01] Descricao
					SB1->B1_UM          ,; //[03] UM
					nQuant				,; //[04] Quantidade
					DXC->DXC_LOCPRD     ,; //[05] Local
					DXC->DXC_TM         ,; //[06] TM
					DXC->DXC_GRPROD     ,; //[07] Gera Produção
					aDXL[nX,6]          ,; //[08] Recno Romaneio
					DXC->DXC_CODPRO     ,; //[09] Produto Desmontagem
					DXC->DXC_LOCAL		,; //[10] Local Desmontagem
					DXC->DXC_PLUMA      ,; //[11] Indica se o produto é PLUMA
					cValTochar( nPerc ) ,; //[12] Percentual de quanto representa do fardão
					aDXL[nX,7] 		    ,; //[13] Conjunto
					DXC->DXC_LOTPRD     ,; //[14] Lote produto acabado
					DXC->DXC_NMLPRD     ,; //[15] Sublote produto acabado
					DXC->DXC_LCLPRD     ,; //[16] Localização produto acabado
					dLoteProd			,; // [17] Validade
					IIF(SB1->B1_RASTRO = 'N',.F.,.T.);
						})
				else
					aAdd(aDetProd[nY], { DXC->DXC_PRDPRO     ,; //[01] Produto
					SB1->B1_DESC        ,; //[01] Descricao
					SB1->B1_UM          ,; //[03] UM
					nQuant				,; //[04] Quantidade
					DXC->DXC_LOCPRD     ,; //[05] Local
					DXC->DXC_TM         ,; //[06] TM
					DXC->DXC_GRPROD     ,; //[07] Gera Produção
					aDXL[nX,6]          ,; //[08] Recno Romaneio
					DXC->DXC_CODPRO     ,; //[09] Produto Desmontagem
					DXC->DXC_LOCAL		,; //[10] Local Desmontagem
					DXC->DXC_PLUMA      ,; //[11] Indica se o produto é PLUMA
					cValTochar( nPerc ) ,; //[12] Percentual de quanto representa do fardão
					aDXL[nX,7] 		    ,; //[13] Conjunto
					IIF(SB1->B1_RASTRO = 'N',.F.,.T.);
						})
				endIf

				If ( nPos := Ascan(aProd,{|x| x[1] = DXC->DXC_PRDPRO})) = 0

					if  DXC->(ColumnPos('DXC_LOTPRD')) > 0
						aAdd(aProd, { DXC->DXC_PRDPRO     ,; //Produto
						SB1->B1_DESC        ,; //Descricao
						''                  ,;
							nQuant			    ,; //Quantidade
						DXC->DXC_LOCPRD	    ,; //Local
						DXC->DXC_LOTPRD     ,; //Lote produto acabado
						DXC->DXC_NMLPRD     ,; //Sublote produto acabado
						DXC->DXC_LCLPRD	    , ; //Localização produto acabado
						dLoteProd           ,; // [13] Validade
						IIF(SB1->B1_RASTRO = 'N',.F.,.T.);
							})
					else
						aAdd(aProd, { DXC->DXC_PRDPRO     ,; //Produto
						SB1->B1_DESC        ,; //Descricao
						''                  ,;
							nQuant			    ,; //Quantidade
						DXC->DXC_LOCPRD	    ,; //Local
						IIF(SB1->B1_RASTRO = 'N',.F.,.T.);
							})
					endIf
				Else
					aProd[nPos,4] += nQuant
				Endif
			Endif

			SB1->(DbCloseArea())

			//---------------------------------------------------------

			DXC->( dbSkip() )
		EndDo

		DXC->(DbCloseArea())

		If !lProd
			// Abro a area para verificar a proteção de campo
			dbSelectArea('DXC')
			If DXC->(ColumnPos('DXC_LOTPRD')) > 0 // se existe o campo de lote
				aAdd(aDetProd[nY], { , , , , , , , , , , , , , , , , })
			Else
				aAdd(aDetProd[nY], { , , , , , , , , , , , , })
			EndIf
			DXC->(DbCloseArea())
		Endif
	Next nX
	nTotRest := nPsTotal - nTotPLU

	RestArea( aAreaAtu )
	cFilAnt := cFilAntTmp
Return

/*/{Protheus.doc} NextNumDoc
Retorna o proximo numero de documento disponivel
@author joaquim.burjack
@since 02/05/2016
@type function
/*/
Static Function NextNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumAux 	:= ''
	Local cMay		:= ''
	Local lPrNf	    := SuperGetMv("MV_AGRPNF", ,.F.)
	//----------------------------------------------------------------------------
	// Inicializa o numero do Documento com o ultimo + 1
	//----------------------------------------------------------------------------

	If !lPrNf
		dbSelectArea('SD3')
		cNumAux := NextNumero('SD3',2,'D3_DOC',.T.)
		cNumAux := A261RetINV(cNumAux)
		SD3->(dbSetOrder(2))
		SD3->(dbSeek(cFilAnt+cNumAux))
		cMay := 'SD3'+Alltrim(cFilAnt)+cNumAux
		While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumAux .Or. !MayIUseCode(cMay)
			If SD3->D3_ESTORNO # 'S'
				cNumAux := Soma1(cNumAux)
				cMay := 'SD3'+Alltrim(cFilAnt)+cNumAux
			EndIf
			SD3->(dbSkip())
		EndDo
		RestArea( aAreaAtu )
	Else
		cNumAux := GetSXENum('SD3','D3_DOC')
		SD3->(dbSetOrder(2)) //D3_FILIAL+D3_DOC+D3_COD                                                                                                                                         
		While SD3->(dbSeek(xFilial("SD3")+cNumAux))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cNumAux := GetSxENum("SD3","D3_DOC")
		EndDo
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
	EndIf
Return( cNumAux )

/*/{Protheus.doc} A620Estorn
//Gera gride com as informações de estorno da desmontagem dos fardões.
@author joaquim.burjack
@since 02/05/2016
@param oBrw, object, Gride de seleção de fardoes
@type function
/*/
Static Function A620Estorn(oBrw)
	Local aArea		:= GetArea()
	Local aFardoes 	:= {}
	Local a242Cab	:= {}
	Local a242Itens	:= {}
	Local nModBkp	:= nModulo
	Local nX		:= 0
	Local nY        := 0
	Local lRet		:= .T.
	Local oMdDXL    := FwLoadModel('AGRA601')
	Local aMata240  := {}
	Local aProd     := {}
	Local aDesmont  := {}
	Local nFardao 	:= 0
	Local cAliasSD3 := GetNextAlias()
	Local nRecno    := 0
	Local dDataFe
	Local lIniciada := .f.
	Local cUserBenf := A655GETUNB()// Busca a unidade de beneficiamento
	Local cFiltro   := ''
	Local cMvPar    := "mv_par04" 
	Local lRestMVPar := .F. //valor logico para definir se deve restaurar pergunte

	//Variaveis utilizadas na Query da SD3
	Local cCF       := "DE7"
	Local cEst      := "S"

	//Variaveis de uso do MsExecAuto
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	Pergunte( 'AGRA620001', .F.)

	cFiltro += "@DXL_STATUS='" + IIf( mv_par03=1, "6", "5" ) + "' "

	If !Empty(mv_par01)
		cFiltro += " And DXL_CODCNJ='" + mv_par01 + "' "
	Else
		cFiltro += " And DXL_CODCNJ <> ' '"
	Endif

	If !Empty(mv_par02)
		cFiltro += " And DXL_LOCAL='" + mv_par02 + "' "
	Endif

	If !Empty(cUserBenf)
		cFiltro += " AND DXL_CODUNB = '" + cUserBenf + "' "
	Endif

	If !Empty(mv_par06)
		cFiltro += " And DXL_DTBEN >='" +  DTOS(mv_par06 ) + "' "
	Endif

	If !Empty(mv_par07)
		cFiltro += " And DXL_DTBEN <='" + DTOS(mv_par07 ) + "' "
	Endif

	If !Empty(mv_par08)
		cFiltro += " And DXL_SAFRA >='" + mv_par08 + "' "
	Endif

	If !Empty(mv_par09)
		cFiltro += " And DXL_SAFRA <='" + mv_par09 + "' "
	Endif

	If !Empty(mv_par10)
		cFiltro += " And DXL_PRDTOR >='" + mv_par10 + "' "
	Endif

	If !Empty(mv_par12)
		cFiltro += " And DXL_PRDTOR <='" + mv_par12 + "' "
	Endif

	If !Empty(mv_par11)
		cFiltro += " And DXL_LJPRO >='" + mv_par11 + "' "
	Endif

	If !Empty(mv_par13)
		cFiltro += " And DXL_LJPRO <='" + mv_par13 + "' "
	Endif

	If !Empty(mv_par14)
		cFiltro += " And DXL_FAZ >='" + mv_par14+ "' "
	Endif

	If !Empty(mv_par15)
		cFiltro += " And DXL_FAZ <='" + mv_par15 + "' "
	Endif

	//cFiltro += " AND DXL_OK <> ' ' "

	lIniciada := Iif( MV_PAR05 = 1, .t., .f. )
	DXL->(dbSetFilter({||&cFiltro},cFiltro))
	DXL->(dbGotop())
	While !DXL->(Eof() )
		If oBrw:IsMark(oBrw:Mark())
			aAdd( aFardoes, { DXL->DXL_CODIGO, DXL->(Recno()) } )
			//Populando array para posteriomente limpar o campo DXL_OK de todos os fardões marcados - Para evitar falha de integridade
			aAdd(aFardoesMk, {DXL->DXL_FILIAL, DXL->DXL_CODIGO, DXL->DXL_SAFRA, DXL->DXL_PRDTOR, DXL->DXL_LJPRO, DXL->DXL_FAZ})
		EndIf
		DXL->(dbSkip())
	EndDo

	If Len( aFardoes ) = 0
		lRet := .F.
		Help(' ',1,'AGR620PROC')
	EndIf

	If lRet
		lMsHelpAuto := .T.
		//----------------------------------------------------------------------------
		// Atualiza status do fardoes processados
		//----------------------------------------------------------------------------
		For nFardao := 1 to Len(aFardoes)
			//redefine variavel, caso fardao anterior deu erro, podendo processar novo fardao
			lRet := .T. 
			lMsErroAuto := .F.

			Begin Transaction

				dbSelectArea('DXL')
				DXL->(dbGotop())
				dbGoto(aFardoes[nFardao,2])

				//Busca os apontamentos e ordens a serem estornados
				aProd := AGR605DESPRO(DXL->DXL_CODIGO, DXL->DXL_SAFRA, DXL->DXL_PRDTOR, DXL->DXL_LJPRO, DXL->DXL_FAZ)

				// Verifica se há ordens a serem estornadas
				// Em alguns casos, existirá apenas a desmontagem
				If Len(aProd) > 0

					For nX := 1 to Len(aProd)
						If lRet
							DbselectArea("SC2")
							DBClearFilter()
							If AGRIFDBSEEK("SC2",PADR(aProd[nX,2],TamSX3('C2_NUM')[1],' ')+'01'+;
									PADR(aProd[nX,3],TamSX3('C2_PRODUTO')[1],' '),9,.f.)
								AGRTRAVAREG("SC2")
								dDataFe       := SC2->C2_DATRF
								SC2->C2_DATRF := AGRINICIAVAR("C2_DATRF")
								AGRDESTRAREG("SC2")

							EndIf


							If __cMVTpReq = "N"
								If !lRestMVPar 
									//configura o pergunte MTA240 MV_PAR04, ira passar somente uma vez aqui e o pergunte deverá ser restaurado ao final do processamento dos fardões
									&cMvPar := ""
									Pergunte("MTA240",.F.)
									//Validar se o Pergunte MTA240 MV_PAR04 está com o valor 2 
									//Se não estiver alterar para 2 e depois retornar para o valor original, o estorno será por item
									If !(&cMvPar == 2)
										SetMVValue("MTA240",cMvPar,2) //altera para valor 2 --> (Quanto ao Estorno: 1=Por Documento; 2=Por Item)
										lRestMVPar := .T. //.T. = deve ser restaurado -- passa apenas uma vez aqui
									EndIf 
								EndIf
								
								If GetRpoRelease() <= "12.1.033" 
									aMata240 := ItensAdic( aProd[nX,1] )
									// Estorna a requisição dos itens adicionais
									If Len(aMata240) > 0
										
										nModulo := 10
										For nY := 1 to Len(aMata240)
											MSExecAuto({|x,y|MATA240(x,y)},aMata240[nY],5)
											If lMsErroAuto
												MostraErro()
												lRet := .F.
												Exit
											Endif
										Next nY
										// Retorna para o módulo 67
										nModulo := nModBkp
									Endif
								Else 
									//Mata240 deve ser substituido pelo MATA241
									nModulo := 04
									lRet := EstIteAdic(aProd[nX,1]) //chama função que realiza o estorno via MATA241
									// Retorna para o módulo 67
									nModulo := nModBkp
								EndIf
							Endif

							If lRet
								// Refaz o tratamento da OP
								DbselectArea("SC2")
								DBClearFilter()
								If AGRIFDBSEEK("SC2",PADR(aProd[nX,2],TamSX3('C2_NUM')[1],' ')+'01'+;
										PADR(aProd[nX,3],TamSX3('C2_PRODUTO')[1],' '),9,.f.)
									AGRTRAVAREG("SC2")
									SC2->C2_DATRF := If(SC2->C2_QUJE > 0,dDataFe,Ctod(''))
									AGRDESTRAREG("SC2")
								EndIf

								lRet := AGR601REOP( aProd[nX,2], aProd[nX,3], aProd[nX,1], lIniciada )
							EndIf
						Endif
					Next nX
				Endif

				If lRet
					//Posiciona no Registro do fardão
					aDesmont := AGR605RETDES(DXL->DXL_CODIGO, DXL->DXL_SAFRA, DXL->DXL_PRDTOR, DXL->DXL_LJPRO, DXL->DXL_FAZ)

					//Inicio bloco desmontagem
					If Len(aDesmont) > 0

						BeginSql Alias cAliasSD3
							Select R_E_C_N_O_ As D3_RECNO From  %table:SD3% SD3 
							Where SD3.D3_FILIAL   = %xFilial:SD3%
							And SD3.D3_DOC       = %exp:aDesmont[1]% 
							And SD3.D3_NUMSEQ    = %exp:aDesmont[2]% 
							And SD3.D3_CF        = %exp:cCF%
							And SD3.D3_ESTORNO  <> %exp:cEst% 
							And SD3.%notDel%
						EndSQL

						dbSelectArea(cAliasSD3)
						(cAliasSD3)->( dbGoTop() )

						If (cAliasSD3)->(!Eof())
							nRecno := (cAliasSD3)->D3_RECNO
						End

						(cAliasSD3)->( DbCloseArea() )

						dbSelectArea('SD3')
						SD3->(dbGotop())
						SD3->(dbGoto(nRecno))

						nModulo		:= 04
						MsExecAuto( { |v,x,y,z| Mata242(v,x,y,z) },a242Cab,a242Itens, 5, .T. )
						If lMsErroAuto
							MostraErro()
							lRet := .F.
						EndIf

						// Retorna o módulo ao 67
						nModulo := nModBkp

					Endif // Fim Bloco Estorno Desmontagem
				Endif

				If lRet
					//Seta a operação da DXL como alteração
					oMdDXL:SetOperation(4)
					If oMdDXL:Activate()
						If !Empty(mv_par16)
							oMdDXL:GetModel("DXLMASTER"):LoadValue('DXL_STATUS',If (mv_par16 == 1,'5', '4'))
						Else
							oMdDXL:GetModel("DXLMASTER"):LoadValue('DXL_STATUS','5')
						Endif
						If (lRet := oMdDXL:VldData())
							oMdDXL:CommitData()
							lRet := AGR605DEL(DXL->DXL_CODIGO, DXL->DXL_SAFRA, DXL->DXL_PRDTOR, DXL->DXL_LJPRO, DXL->DXL_FAZ, "AGRA620")
						Else
							oMdDXL:SetErrorMessage( , , , , , oMdDXL:GetErrorMessage()[6])
						Endif
					Else
						lRet := .F.
					Endif
					//Desativa o módulo
					oMdDXL:DeActivate()
				endif		

				If !lRet
					DisarmTransaction()
				EndIf

			End Transaction()
			
		Next nFardao
	EndIf

	If lRestMVPar //restaura pergunte MTA240
		SetMVValue("MTA240",cMvPar,1) //restaura o pergunte para valor 1 --> // (Quanto ao Estorno: 1=Por Documento; 2=Por Item)
	EndIF 

	nModulo := nModBkp
	oBrw:Refresh()
	RestArea(aArea)
Return()


/*/{Protheus.doc} ItensAdic
// Retorna array de itens adicionais
@author bruna.rocio
@since 26/05/2016
@version undefined

@type function
/*/
Static Function ItensAdic(cDoc)
	Local aArea     := GetArea()
	Local aItensAd  := {}
	Local cItem     := Space(TamSX3("D3_ITEM")[01])
	Local nX        := 0
	Local cCF       := "RE0"

	dbSelectArea('SD3')
	dbSetOrder(9)
	If dbSeek(FwXFilial('SD3')+cDoc+cItem+cCF)

		nX := 0
		While !SD3->(Eof())                   .And. ;
				SD3->D3_FILIAL = FwXFilial('SD3') .And. ;
				SD3->D3_DOC    = cDoc             .And. ;
				SD3->D3_ITEM   = cItem            .And. ;
				SD3->D3_CF     = cCF

			nX++

			aAdd(aItensAd,{})
			aAdd(aItensAd[nX],{"D3_TM",SD3->D3_TM,Nil})
			aAdd(aItensAd[nX],{"D3_COD",SD3->D3_COD,Nil})
			aAdd(aItensAd[nX],{"D3_QUANT",SD3->D3_QUANT,Nil})
			aAdd(aItensAd[nX],{"D3_LOCAL",SD3->D3_LOCAL,Nil})
			aAdd(aItensAd[nX],{"D3_CHAVE",SD3->D3_CHAVE,Nil})
			aAdd(aItensAd[nX],{"D3_EMISSAO",SD3->D3_EMISSAO,Nil})
			aAdd(aItensAd[nX],{"D3_NUMSEQ",SD3->D3_NUMSEQ,Nil})
			aAdd(aItensAd[nX],{"D3_PROJPMS",SD3->D3_PROJPMS,Nil})
			aAdd(aItensAd[nX],{"D3_TASKPMS",SD3->D3_TASKPMS,Nil})

			//verifica se produto tem controle por lote
			If VldLotePrd(SD3->D3_COD)
				aAdd(aItensAd[nX],{"D3_LOTECTL",SD3->D3_LOTECTL,Nil})
				aAdd(aItensAd[nX],{"D3_NUMLOTE",SD3->D3_NUMLOTE,Nil})
				aAdd(aItensAd[nX],{"D3_LOCALIZ",SD3->D3_LOCALIZ,Nil})
			EndIf
			aAdd(aItensAd[nX],{"INDEX",4,Nil})

			SD3->(dbSkip())
		EndDo
	Endif

	RestArea(aArea)
Return aItensAd

/*/{Protheus.doc} A620GRAVA
Faz a movimentação de estoque para baixar o saldo do produto fardão e gerar 
os saldos para os subprodutos originados.
@author joaquim.burjack
@since 02/05/2016
@param aFardoes, array, Fardões que serão encerrados
@param aItensDet, array, Subprodutos do fardão para desmontagem do fardão
@param aProdDet, array, Subprodutos de cada fardão que irão gerar produção 
@param aProd, array, agrupamento por subproduto do array aProdDet
@type function
/*/
Function AGRA620GRV(oBrw, aFardoes, aItensDet, aProdDet, aProd)
	Local aArea := GetArea()
	Local a242Cab	:= {}
	Local a242Itens	:= {}
	Local a242Item	:= {}
	Local aOrdem    := {}
	Local cNumDoc	:= ''
	Local cNumOP	:= ''
	Local nX, nY	:= 0
	Local nModBkp	:= nModulo
	Local lRet		:= .T.
	Local oMdDXL    := FwLoadModel('AGRA601')
	Local oDXL      := oMdDXL:GetModel('DXLMASTER')
	Local oStruDXL  := oDXL:GetStruct()
	Local cItem     := Space(TamSX3("D3_ITEM")[01])
	Local nApontOP  := 0
	Local lDesmont  := .f.
	Local dDtValid
	Local cFilAntTmp := cFilAnt
	Local lAGR620DP := ExistBlock('AGR620DP')
	Local lAG620TOK := ExistBlock('AG620TOK')
	Local lRetPe
	Local lok := .f.

	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.

	Pergunte( 'AGRA620001', .F. )
	nApontOP := MV_PAR04

	oStruDXL:DeActivate()

	oStruDXL:AddField(/*cTitulo*/'',;
	/*cTooltip*/'' ,;
	/*cIdField*/'DXL_OK',;
	/*cTipo*/'C',;
	/*nTamanho*/2,;
	/*nDecimal*/0,;
	/*bValid*/ ,;
	/*bWhen*/,;
	/*aValues*/,;
	/*lObrigat*/ .F.,;
	/*bInit*/ ,;
	/*lKey*/,;
	/*lNoUpd */,;
	/*lVirtual */ .F.)

	Begin Transaction

		If nApontOP = 2 //Agrupado
			If Len(aFardoes) > 0
				For nX := 1 to Len(aProd)
					cNumOP := ""
					lRet := A620GERAOP(aProd[nX], @cNumOP, Alltrim(MV_PAR01))

					If lRet
						Aadd(aOrdem,{aProd[nX,1],cNumOP})
					Else
						DisarmTransaction()
						If  IsInCallStack('AGRA620EA')
							AGRA620GE(aFardoes[1],cRotEA,cErroEA) //grava o erro na tabela NLO, usa primeiro fardão ja que aProd é uma agrupamento dos subprodutos do Fardão que geram OP
						EndIf
						BREAK //Finaliza indo para o END TRANSACTION
					Endif
				Next nX
			Endif
		Endif

		If lRet
			For nX := 1 to Len(aFardoes)

				If lAG620TOK
					lRetPe := ExecBlock('AG620TOK',.F.,.F., {aFardoes[nX]})

					If Valtype(lRetPe) == 'L' .AND. !lRetPe
						Loop
					Endif
				Endif

				If  DXL->(ColumnPos('DXL_FILBEN')) > 0 .AND. !Empty(aFardoes[nX,11])//Filial em que foi realizado o beneficiamento
					cFilAnt := aFardoes[nX,11]
				EndIf

				cNumDoc := NextNumDoc()

				dbSelectArea('DXL')
				DXL->(dbSetOrder(1))
				DXL->(dbGoTop())
				//Posiciona no fardão a ser atualizado
				DXL->(dbGoTo(aFardoes[nX,6]))

				IF DXL->DXL_STATUS = '5' .and. DXL->DXL_RDMTO <= 0 //esta beneficiado porem com rendimento zero
					AutoGrLog(STR0043) //##Não é possivel encerrar fardão com rendimento zero.
					AutoGrLog(STR0044) //##Efetue o ajuste na rotina de beneficamento.
					AutoGrLog(STR0011 + ": " + DXL->DXL_CODIGO) //##Fardão
					AutoGrLog(STR0042 + ": " + DXL->DXL_FILBEN) //##Filial
					
					DisarmTransaction()
					If IsInCallStack('AGRA620EA')
						cRotEA  := "AGRA620"
						cErroEA := AGR620LEAS(GetAutoGRLog()) 
						AGRA620GE(aFardoes[nX],cRotEA,cErroEA) //grava os erros na tabela NLO
					Else
						MostraErro()
					EndIf
					BREAK //Finaliza indo para o END TRANSACTION 
				EndIf

				aAdd( a242Cab, { 'cProduto'   , aFardoes[nX,2]					, Nil } )
				aAdd( a242Cab, { 'cLocOrig'   , aFardoes[nX,3]				 	, Nil } )
				aAdd( a242Cab, { 'nQtdOrig'   , aFardoes[nX,4]			 		, Nil } )
				aAdd( a242Cab, { 'nQtdOrigSe' , CriaVar( 'D3_QTSEGUM' )			, Nil } )
				aAdd( a242Cab, { 'cDocumento' , cNumDoc							, Nil } )

				//verifica se produto tem controle por lote
				If DXC->(ColumnPos('DXC_LOTCTL')) > 0 .AND. VldLotePrd(aFardoes[nX,2])
					If .NOT. empty(aFardoes[nX,9])
						aAdd( a242Cab, { 'cNumLote', aFardoes[nX,9]				 	, Nil } )
					Else
						aAdd( a242Cab, { 'cNumLote', CriaVar('D3_NUMLOTE')		 	, Nil } )
					EndIf

					If .NOT. empty(aFardoes[nX,8])
						aAdd( a242Cab, { 'cLoteDigi', aFardoes[nX,8]			 	, Nil } )
					Else
						aAdd( a242Cab, { 'cLoteDigi', CriaVar('D3_LOTECTL')		 	, Nil } )
					EndIf

					If .NOT. empty(aFardoes[nX,10])
						aAdd( a242Cab, { 'cLocaliza', aFardoes[nX,10]			 	, Nil } )
					Else
						aAdd( a242Cab, { 'cLocaliza', CriaVar('D3_LOCALIZ')		 	, Nil } )
					EndIf

					dDtValid := AGRA620DTV()

					If !Empty(dDtValid)
						aAdd( a242Cab, { 'dDtValid'   , dDtValid            		 	, Nil } )
					Else
						aAdd( a242Cab, { 'dDtValid'   , CriaVar('D3_DTVALID')	 	, Nil } )
					EndIf
				EndIf

				aAdd( a242Cab, { 'nPotencia'  , CriaVar('D3_POTENCI')		 	, Nil } )

				aAdd( a242Cab, { 'cNumSerie'  , CriaVar('D3_NUMSERI')		 	, Nil } )

				For nY := 1 to Len(aItensDet[nX])
					If aItensDet[nX,nY,4] > 0 // Adiciona se a quantidade for maior que zero
						a242Item	:= {}
						aAdd( a242Item, { 'D3_COD'    , aItensDet[nX,nY, 1]		, Nil } )
						aAdd( a242Item, { 'D3_LOCAL'  , aItensDet[nX,nY, 6]		, Nil } )
						aAdd( a242Item, { 'D3_QUANT'  , aItensDet[nX,nY, 4]		, Nil } )
						aAdd( a242Item, { 'D3_RATEIO' , aItensDet[nX,nY, 8]		, Nil } )

						//verifica se produto tem controle por lote
						If VldLotePrd(aItensDet[nX,nY,1])
							IF aItensDet[nX,nY,14]

								IF .NOT. empty(aItensDet[nX,nY,10])
									aAdd( a242Item, { 'D3_LOTECTL', aItensDet[nX,nY,10]		, Nil } )
								EndIf

								IF .NOT. empty(aItensDet[nX,nY,11])
									aAdd( a242Item, { 'D3_NUMLOTE', aItensDet[nX,nY,11]		, Nil } )
								EndIf

								IF .NOT. empty(aItensDet[nX,nY,12])
									aAdd( a242Item, { 'D3_LOCALIZ', aItensDet[nX,nY,12]		, Nil } )
								EndIf

								IF .NOT. empty(aItensDet[nX,nY,13])
									aAdd( a242Item, { 'D3_DTVALID', aItensDet[nX,nY,13]		, Nil } )
								EndIf
							Endif
						EndIf

						aAdd( a242Itens, a242Item )
					EndIf
				Next nY

			/* Permite manipular os dados antes de executar a rotina 
			automatica de desmontagem de produtos */
				If lAGR620DP
					aRet := ExecBlock('AGR620DP',.F.,.F.,{a242Cab, a242Itens,aFardoes[nx,7] /* Conjunto */})
					If ValType(aRet) == 'A'
						a242Cab	  := aRet[1] // Cabeçalho da desmontagem de produtos
						a242Itens := aRet[2] // Itens da demontagem de produtos
					EndIf
				EndIf

			nModulo := 04
			lok := MsExecAuto( { |v,x,y,z| Mata242(v,x,y,z) }, a242Cab, a242Itens, 3, .t. )
			nModulo := nModBkp

				If lMsErroAuto
					lRet := .F.
					DisarmTransaction()
					If  IsInCallStack('AGRA620EA')
						cRotEA := 'Mata242'
						cErroEA :=  AGR620LEAS(GetAutoGRLog()) //MostraErro("\")	
						AGRA620GE(aFardoes[nX],cRotEA,cErroEA) //grava os erros na tabela NLO
					Else
						Mostraerro()	
					EndIf	
					BREAK //Finaliza indo para o END TRANSACTION						
				Else
					a242Cab	  := {}
					a242Itens := {}
					a242Item  := {}

					SD3->(dbSelectArea('SD3'))
					SD3->(dbSetOrder(9))
						If SD3->(MsSeek(FwXFilial('SD3')+cNumDoc+cItem+"RE7"))
							RegToMemory('DXL',.f.,.f.)
							lRet := AGR605GRAVA()
							If !lRet 
								DisarmTransaction()
								If  IsInCallStack('AGRA620EA')
									AGRA620GE(aFardoes[nX],cRotEA,cErroEA) //grava os erros na tabela NLO
								EndIf	
								BREAK //Finaliza indo para o END TRANSACTION
							EndIf
						EndIf
					SD3->(dbCloseArea())
				EndIf

				If lRet
					lDesmont := .t.	
					If Len(aProdDet) > 0
						For nY := 1 to Len(aProdDet[nX])

							If aProdDet[nX,nY,7] = '1' //Gera Producao

								lDesmont := .f.
								If nApontOP = 2 //Agrupado
									cNumOP := ""
									//Atribui OP que deve ser usada	
									If ( nPos := Ascan(aOrdem,{|x| x[1] = aProdDet[nX,nY,1] /** Produto **/ })) > 0
										cNumOP := aOrdem[nPos,2]
									Endif
								Endif

								lRet := GeraProducao(aProdDet[nX,nY], oMdDXL, oDXL, cNumOP, aFardoes[nX,1])
								If !lRet
									DisarmTransaction()
									If  IsInCallStack('AGRA620EA')
										AGRA620GE(aFardoes[nx],cRotEA,cErroEA) //grava os erros na tabela NLO
									EndIf
									BREAK //Finaliza indo para o END TRANSACTION
								EndIf
							Endif
						Next nY
					Endif

					If lRet .and. lDesmont
						// Conjunto configurado para apenas gerar desmontagem

						//Seta operação do Fardão como alteração para encerrar o processo
						oMdDXL:SetOperation(4) //Alteração
						//Se for possível ativar o modelo, continua
						If oMdDXL:Activate()

							//Atualiza os campos
							oMdDXL:GetModel("DXLMASTER"):LoadValue('DXL_OK','')
							oMdDXL:GetModel("DXLMASTER"):LoadValue('DXL_STATUS','6')

							If (lRet := oMdDXL:VldData())
								oMdDXL:CommitData()								
							Else
								// Se foi retornado erro da validação do modelo
								// seta o retorno como false, mostra mensagem de erro
								// e interrompe o looping
								lRet := .F.
								oMdDXL:SetErrorMessage( , , , , , oMdDXL:GetErrorMessage()[6])	
								DisarmTransaction()							
								If  IsInCallStack('AGRA620EA')
									cRotEA := 'AGRA620GRV'
									cErroEA := oMdDXL:GetErrorMessage()[6]
									AGRA620GE(aFardoes[nX],cRotEA,cErroEA) //grava os erros na tabela NLO
								EndIf
								BREAK //Finaliza indo para o END TRANSACTION
							Endif
						Endif
						//Desativa o modelo
						oMdDXL:DeActivate()	
					Endif
				Endif

				If !lRet
					DisarmTransaction()
					If  IsInCallStack('AGRA620EA')
			    		AGRA620GE(aFardoes[nX],cRotEA,cErroEA) //grava os erros na tabela NLO
					EndIf
					BREAK //Finaliza indo para o END TRANSACTION
				EndIf

				If !IsInCallStack('AGRA615') .and. !IsInCallStack('AGRA620EA')
					oBrw:Refresh()
				endif
			Next nX
		EndIf
	End Transaction

	cFilAnt := cFilAntTmp		
	RestArea(aArea)	

Return()


/*/{Protheus.doc} GeraProducao
//Geração de Ordem e Apontamento de Produção para os produtos oriundos do beneficiamento
@author bruna.rocio
@since 12/05/2016
@type function
/*/
Static Function GeraProducao(aProducao, oMdDXL, oDXL, cNumOP, cFardao)
	Local aArea           		:= GetArea()
	Local lRet            		:= .T.
	Local cNumDoc				:= ""

	If ExistBlock('AGR620OP')
		cNumOP := ExecBlock('AGR620OP',.F.,.F.,{aProducao[1],aProducao[13]})
	EndIf

	If Empty(cNumOP)
		lRet := A620GERAOP(aProducao, @cNumOP, Alltrim(aProducao[13]))
	Endif

	If lRet .And. aProducao[11] = '1' //PLUMA
		//-------------------------------------------------------------------------------
		// Faz requisição dos itens originados na desmontagem para gerarem os itens
		// produzidos, no caso de PLUMA, podem ser requisitados os itens adicionais
		// de acordo com a parametrização disposta na tabela DXF
		//-------------------------------------------------------------------------------
		If __cMVTpReq = "N" //A requisição será feita exclusivamente por estrutura
			lRet :=	A620REQOP(aProducao, cNumOP, @cNumDoc)
		Endif
	EndIf

	If lRet
		//------------------------------------------------------
		// Aponta produção do produto gerado pelo beneficiamento
		//------------------------------------------------------
		If lRet := A620APROD(aProducao, cNumOP, @cNumDoc)

			dbSelectArea('DXL')
			DXL->(dbSetOrder(1))
			DXL->(dbGoTop())
			//Posiciona no fardão a ser atualizado
			DXL->(dbGoTo(aProducao[8]))

			//Seta operação do Fardão como alteração para encerrar o processo
			oMdDXL:SetOperation(4) //Alteração
			//Se for possível ativar o modelo, continua
			If oMdDXL:Activate()

				//Atualiza os campos
				oDXL:LoadValue('DXL_OK','')
				oDXL:LoadValue('DXL_STATUS','6')

				If (lRet := oMdDXL:VldData())
					lRet := oMdDXL:CommitData()

					dbSelectArea('SD3')
					SD3->(dbSetOrder(2))

					If SD3->(MsSeek(FwXFilial('SD3')+PADR(cNumDoc,TamSX3('D3_DOC')[1],' ')+;
							PADR(aProducao[1],TamSX3('D3_COD')[1],' ')))
						//Grava DXB
						lRet := AGR605GRAVA()			
					EndIf

					If lRet .and. aProducao[11] = '1' .AND. TableInDic('N9D') .AND. DXI->(ColumnPos('DXI_LOTE' )) > 0 //PLUMA
						lRet := AtualizaDXI(cFardao, PADR(aProducao[1],TamSX3('D3_COD')[1],' '),PADR(aProducao[14],TamSX3('D3_LOTECTL')[1],' '))
					Endif
				Else
					// Se foi retornado erro da validação do modelo
					// seta o retorno como false e mostra mensagem de erro
					lRet := .F.
					oMdDXL:SetErrorMessage( , , , , , oMdDXL:GetErrorMessage()[6])
					If IsInCallStack('AGRA620EA')
						cRotEA := 'A620APROD'
						cErroEA   := oMdDXL:GetErrorMessage()[6]
					EndIf
				Endif
			Endif
			//Desativa o modelo
			oMdDXL:DeActivate()
		EndIf
	EndIf

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} A620GERAOP
//Gera ordem de produção
@author joaquim.burjack
@since 02/05/2016
@version undefined
@param aProducao, array, Dados do produto para gerar a ordem de produção
@param cNumOP, characters, Numero da Ordem de Produção 
@param cConjunto, character, Codigo do conjunto
@type function
/*/
Static Function A620GERAOP(aProducao, cNumOP, cConjunto)
	Local aArea 		:= GetArea()
	Local aVetor		:= {}
	Local nModuloOld  	:= nModulo
	
	//-----------------------
	// Seta modulo para PCP
	//-----------------------
	nModulo := 10

	cNumOP := GetSXENum('SC2','C2_NUM')
	SC2->(dbSetOrder(1))
	While SC2->(dbSeek(xFilial("SC2")+cNumOP))
		If ( __lSx8 )
			ConfirmSX8()
		EndIf
		cNumOP := GetSxENum("SC2","C2_NUM")
	EndDo
	If ( __lSx8 )
		ConfirmSX8()
	EndIf

	//-------------------------------
	// Adiciona os dados em um vetor
	//-------------------------------
	AADD(aVetor, {'C2_NUM'		, cNumOP 			,Nil})
	AADD(aVetor, {'C2_ITEM'		, '01'		   		,Nil})
	AADD(aVetor, {'C2_SEQUEN' 	, '001'				,Nil})
	AADD(aVetor, {'C2_PRODUTO'	, aProducao[1]		,Nil})
	AADD(aVetor, {'C2_QUANT'  	, aProducao[4]		,Nil})
	AADD(aVetor, {'C2_LOCAL'  	, aProducao[5]		,Nil})
	AADD(aVetor, {'C2_DATPRI' 	, ddatabase			,Nil})
	AADD(aVetor, {'C2_DATPRF' 	, ddatabase			,Nil})
	AADD(aVetor, {'C2_EMISSAO'	, ddatabase     	,Nil})
	AADD(aVetor, {'C2_TPOP'  	, 'F'           	,Nil})
	AADD(aVetor, {'AUTEXPLODE'	, 'S'				,Nil})

	If ExistBlock('AGR620VOP')
		aRet := ExecBlock('AGR620VOP',.F.,.F.,{aVetor, cConjunto})
		If ValType(aRet) == 'A'
			aVetor	:= aClone(aRet)
		EndIf
	EndIf

	//-----------------------------
	// Executa a rotina automatica
	//-----------------------------
	MSExecAuto({|x,y| mata650(x,y)},aVetor, 3) // 3=Inclusao, 5=Exclusão

	If !lMsErroAuto
		cNumOP := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
		ConfirmSx8()
	Else
		If  IsInCallStack('AGRA620EA')
			cRotEA := 'mata650'
			cErroEA := AGR620LEAS(GetAutoGRLog()) //MostraErro("\")
		Else
			MostraErro()
		EndIf
		RollBackSx8()
	EndIf

	nModulo := nModuloOld

	RestArea(aArea)
Return(!lMsErroAuto)

/*/{Protheus.doc} A620REQOP
Faz requisição dos produtos para OP da PLUMA beneficiada.
@author joaquim.burjack
@since 02/05/2016
@version undefined
@param aPluma, array, descricao
@param cNumOP, characters, descricao
@param cNumDoc, characters, descricao
@param nOperac, numeric, descricao
@type function
/*/
Static Function A620REQOP(aProducao, cNumOP, cNumDoc)
	Local aArea		:= GetArea()
	Local aItensRQ  := Array(0,0)
	Local nModuloOld:= nModulo
	Local nFardos	:= 0
	Local nX 		:= 0
	Local nY 		:= 0
	Local cNumSeq	:= ''
	Local aMata241  := Array(0,0)
	Local aCabMt241 := Array(0,0)
	Local aIteMt241 := Array(0,0)
	Local aRet 		:= {}

	Private	lMSErroAuto := .F.
	Private	lMSHelpAuto := .T.

	nFardos := A620QTDFDI(aProducao[8]) //Retorna a quantidade de fardinhos originados do fardão
	cNumDoc := NextNumDoc()

	//--------------------------------------------------------------------------------------------------------
	// Adiciona nos itens da movimentação o produto definido como pluma na tabela de percentuais de separação
	//--------------------------------------------------------------------------------------------------------
	If !Empty(aProducao) .And. aProducao[11] = '1' //É PLUMA
		DXF->(dbSetOrder(1)) //Conjunto
		DXF->(dbSeek(xFilial('DXF')+aProducao[13])) //Conjunto
		While DXF->(!Eof()) .And. DXF->DXF_FILIAL =  FWxFilial('DXF') .AND.  DXF->DXF_CODIGO == aProducao[13]
			//*** DXF_MOVEST = Movimenta Estoque (1=Não/2=Sim) ***//
			If DXF->DXF_MOVEST = '2'
				If DXF->(ColumnPos('DXF_LOTCTL')) > 0
					AADD(aItensRQ, {DXF->DXF_CODPRO,(DXF->DXF_QTDPRO*nFardos), DXF->DXF_LOCAL, DXF->DXF_TM, cNumSeq, DXF->DXF_LOTCTL, DXF->DXF_NMLOT, DXF->DXF_LOCLIZ, DataLote(DXF->DXF_CODPRO,DXF->DXF_LOTCTL)} )
				Else
					AADD(aItensRQ, {DXF->DXF_CODPRO,(DXF->DXF_QTDPRO*nFardos), DXF->DXF_LOCAL, DXF->DXF_TM, cNumSeq} )
				Endif
			EndIf
			DXF->(dbSkip())
		End
	EndIf

	//------------------------------
	// Seta o modulo para estoque
	//------------------------------
	If Len(aItensRQ) > 0

		nModulo := 4

		For nX := 1 to Len(aItensRQ)

			dbSelectArea('SB1')
			SB1->(dbSeek(FwXFilial('SB1')+aItensRQ[nX,1]))

            aCabMt241 := {}	
            AADD(aCabMt241, {'D3_FILIAL' 	,FwXFilial("SD3")	,Nil} )
            AADD(aCabMt241, {'D3_DOC'    	,cNumDoc			,Nil} )
            AADD(aCabMt241, {'D3_EMISSAO' 	,ddatabase			,Nil } ) // Data de Emissão
            aAdd(aCabMt241, {'D3_TM'     	,aItensRQ[1][4] 	,Nil})

			aIteMt241 := {}			
			aAdd(aIteMt241, {'D3_COD'    ,aItensRQ[nX,1]	,Nil})
			aAdd(aIteMt241, {'D3_UM'     ,SB1->B1_UM      	,Nil})
			aAdd(aIteMt241, {'D3_QUANT'  ,aItensRQ[nX][2] 	,Nil})
			aAdd(aIteMt241, {'D3_LOCAL'  ,aItensRQ[nX][3] 	,Nil})
			aAdd(aIteMt241 ,{'D3_NUMSEQ' ,aItensRQ[nX,5]	,Nil})
			aAdd(aIteMt241 ,{'D3_OP  '	 ,cNumOP          	,Nil})

			//verifica se produto tem controle por lote
			If VldLotePrd(aItensRQ[nX,1])
				IF .NOT. empty(aItensRQ[nX,6])
					aAdd(aIteMt241 ,{'D3_LOTECTL'	,aItensRQ[nX,6]	 ,Nil})
				EndIf

				IF .NOT. empty(aItensRQ[nX,7])
					aAdd(aIteMt241 ,{'D3_NUMLOTE'	,aItensRQ[nX,7]	 ,Nil})
				EndIf

				IF .NOT. empty(aItensRQ[nX,8])
					aAdd(aIteMt241 ,{'D3_LOCALIZ'	,aItensRQ[nX,8]	 ,Nil})
				EndIf

				IF .NOT. empty(aItensRQ[nX,6])
					aAdd(aIteMt241 ,{'D3_DTVALID'	,aItensRQ[nX,9]	 ,Nil})
				EndIf
			EndIf

            Aadd(aMata241, {aCabMt241,aIteMt241})
		Next nX

		If ExistBlock('AGR620RQ') 
			If GetRpoRelease() <= "12.1.033"
				//gera o array aIteMt241 na estrutura correta para envio ao PE conforme forma de trabalho até a release 33 
				aIteMt241 := array(0,0)  //zera para recriar o array para o PE
				For nX:=1 to Len(aMata241) 
		    		AADD(aIteMt241,{})
					aIteMt241[nX] := aMata241[nX][1]
					For nY:=1 to Len(aMata241[nX][2]) 
						AADD(aIteMt241[nX],aMata241[nX][2][nY])						
       				Next nY
       			Next nX
				aRet := ExecBlock('AGR620RQ',.F.,.F.,{aIteMt241, aProducao[13] /* Conjunto */ })
				If ValType(aRet) == "A" .and. Len(aRet) > 0
					//recria o array aMata241 com os dados do array do PE na estrutura correta para envio ao execauto MATA241
					aMata241 := array(0,0) //zera para recriar com os dados do array que vem do PE
					For nX := 1 To Len(aRet)	
						aAdd(aMata241, {{},{}})
						For nY := 1 To Len(aRet[nX]) 						
							If UPPER( Alltrim( aRet[nX][nY][1] ) ) $ "D3_FILIAL|D3_DOC|D3_TM|D3_EMISSAO"
								Aadd(aMata241[nX][1], aRet[nX][nY]) //cabeçalho
							Else
								Aadd(aMata241[nX][2], aRet[nX][nY]) //item do cabeçalho
							EndIf
						Next nY
					Next nx
				EndIf
			Else
				//apartir da release P12.1.2210 o PE é ajustado para tratar cada item em 2 array, cabeçalho e item.
				aRet := ExecBlock('AGR620RQ',.F.,.F.,{aMata241, aProducao[13] /* Conjunto */ })
				If ValType(aRet) == "A" 
					aMata241 	:= aClone(aRet)
				EndIf
			EndIf

		EndIf

        For nX := 1 to Len(aMata241) //faz separado pois D3_TM do cabeçalho pode ser diferente para cada item conforme cadastro dos itens adicionais do conjunto(DXF)
		    MSExecAuto({|x,y,z| Mata241(x,y,z)}, aMata241[nX][1], {aMata241[nX][2]}, 3)
        Next nX

	Endif

	If lMsErroAuto
		If  IsInCallStack('AGRA620EA')
			cRotEA := 'mata241'
			cErroEA :=  AGR620LEAS(GetAutoGRLog())  //MostraErro("\")
		Else
			MostraErro()
		EndIf
	Endif

	nModulo := nModuloOld

	RestArea(aArea)
Return( !lMsErroAuto )

/*/{Protheus.doc} A620QTDFDI
Retorna a quantidade de fardinhos originados do fardão
@author joaquim.burjack
@since 02/05/2016
@type function
/*/
Static Function A620QTDFDI(nRecno)
	Local aArea := GetArea()
	Local nTotFdi 	:= 0
	Local cQry		:= ''
	Local cAliasQry := GetNextAlias()

	dbSelectArea('DXL')
	DXL->(dbGoTo(nRecno))

	cQry := "SELECT COUNT(DXI_ETIQ) AS QTDFDI"
	cQry += " FROM "+ RetSqlName("DXI") + " DXI"
	cQry += " WHERE	DXI.DXI_FILIAL = '"+xFilial("DXI")+"'"
	cQry += " AND DXI.DXI_FARDAO	= '"+DXL->DXL_CODIGO+"'"
	cQry += " AND DXI.DXI_SAFRA 	= '"+DXL->DXL_SAFRA+"'"
	cQry += " AND DXI.DXI_PRDTOR 	= '"+DXL->DXL_PRDTOR+"'"
	cQry += " AND DXI.DXI_LJPRO		= '"+DXL->DXL_LJPRO+"'"
	cQry += " AND DXI.DXI_FAZ 		= '"+DXL->DXL_FAZ+"'"
	cQry += " AND DXI.D_E_L_E_T_	= '' "

	cQry := ChangeQuery(cQry)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQry),cAliasQry,.F.,.T.)
	
	If !(cAliasQry)->(Eof())
		nTotFdi 	:= (cAliasQry)->(QTDFDI)
	EndIf
	//Fecha arquivo temporario
	(cAliasQry)->(dbCloseArea())
	RestArea(aArea)
Return(nTotFdi)

/*/{Protheus.doc} A620APROD
Aponta OP do produto beneficiado.
@author joaquim.burjack
@since 02/05/2016
@param aProducao, array, array com os dados dos produtos a serem apontados 	
@param cNumOP, character, Numero da Ordem de Produção
@param cNumDoc, character, Numero do Documento da movimentação
@type function
/*/
Function A620APROD(aProducao, cNumOP, cNumDoc)
	Local aArea			:= GetArea()
	Local aMata      	:= {}
	Local nModuloOld 	:= nModulo

	Default cNumOP	:= CriaVar('C2_NUM')

	//---------------------------------------------------------
	// Busca o numero do documento de movimentação de estoque
	//---------------------------------------------------------

	If Empty(cNumDoc)
		cNumDoc   := NextNumDoc()
	Endif

	//-------------------------------
	// Adiciona os dados em um vetor
	//-------------------------------
	AADD(aMata, {'D3_TM'     , aProducao[06]   						,Nil})
	AADD(aMata, {'D3_COD'    , aProducao[01]						,Nil})
	AADD(aMata, {'D3_UM'     , aProducao[03]						,Nil})
	AADD(aMata, {'D3_LOCAL'  , aProducao[05]						,Nil})
	AADD(aMata, {'D3_QUANT'  , aProducao[04]						,Nil})
	AADD(aMata, {'D3_DOC'    , cNumDoc       						,Nil})
	AADD(aMata, {'D3_OP'     , cNumOP        						,Nil})
	AADD(aMata, {'AUTPRTOTAL', 'S'           						,Nil})
	AADD(aMata, {'D3_EMISSAO', dDataBase     						,Nil})

	//verifica se produto tem controle por lote
	If VldLotePrd(aProducao[01])
		IF .NOT. empty(aProducao[14])
			AADD(aMata, {'D3_LOTECTL', aProducao[14],Nil})
		EndIf

		IF .NOT. empty(aProducao[15])
			AADD(aMata, {'D3_NUMLOTE', aProducao[15]						,Nil})
		EndIf

		IF .NOT. empty(aProducao[16])
			AADD(aMata, {'D3_LOCALIZ', aProducao[16]						,Nil})
		EndIf

		IF .NOT. empty(aProducao[17])
			AADD(aMata, {'D3_DTVALID', aProducao[17]						,Nil})
		EndIf
	EndIf

	If ExistBlock('AGR620PRD')
		aRet := ExecBlock('AGR620PRD',.F.,.F.,{aMata})
		If ValType(aRet) == 'A'
			aMata	:= aClone(aRet)
		EndIf
	EndIf

	//-----------------------
	// Seta modulo para PCP
	//-----------------------
	nModulo := 10

	//-----------------------------
	// Executa rotina a automatica
	//-----------------------------
	MsExecAuto( { |x,y| MATA250(x,y)},aMata, 3 ) // 3=Inclusao

	If lMsErroAuto
		If  IsInCallStack('AGRA620EA')
			cRotEA := 'MATA250'
			cErroEA :=  AGR620LEAS(GetAutoGRLog()) // MostraErro("\")
		Else
			MostraErro()
		EndIF
	EndIf

	nModulo := nModuloOld
	RestArea(aArea)
Return(!lMsErroAuto)


/*/{Protheus.doc} A620RETPS
Retorna o peso Bruto e Liquido total de separação de pluma do fardão
@author joaquim.burjack
@since 05/05/2016
@param nRecDXL, numeric, descricao
@type function
/*/
Static Function A620RETPS(nRecDXL)
	Local aArea	:= GetArea()
	Local aRet 	:= {0,0}

	Default nRecDXL := 0

	If nRecDXL > 0
		DXL->(dbGoto(nRecDXL))

		//------------------------------------------------------------------------------
		// Busca peso do algodao em pluma nos fardinhos de todos os fardoes selecionados
		//------------------------------------------------------------------------------
		BeginSql Alias "QryFrd"
			Select Sum( DXI_PSBRUT ) as PSBRUT, Sum( DXI_PSLIQU ) as PSLIQU
			From %Table:DXI% DXI
			Where DXI.DXI_FILIAL = %exp:xFilial("DXI")% And
			DXI.DXI_FARDAO = %exp:DXL->DXL_CODIGO% And
			DXI.DXI_SAFRA = %exp:DXL->DXL_SAFRA% and
			DXI.DXI_PRDTOR = %exp:DXL->DXL_PRDTOR% And
			DXI.DXI_LJPRO = %exp:DXL->DXL_LJPRO% And
			DXI.DXI_FAZ = %exp:DXL->DXL_FAZ% And
			DXI.%NotDel%
		EndSql

		If .Not. QryFrd->( Eof() )
			aRet[1] :=  QryFrd->( PSBRUT )
			aRet[2] :=  QryFrd->( PSLIQU )
		EndIf

		QryFrd->( dbCloseArea() )

	EndIf

	RestArea(aArea)
Return(aRet)



/*/{Protheus.doc} A620Fixo
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 15/06/2016
@version undefined
@type function
/*/
Static Function A620Fixo( cConjunto, nTotal )
	Local aArea := GetArea()
	Local nQtd  := 0

	DXC->( dbSetOrder( 2 ) )
	DXC->( dbSeek( xFilial( 'DXC' ) + cConjunto ) ) //Conjunto do Fardão
	While .Not. DXC->( Eof() ) .And. DXC->( DXC_FILIAL ) = xFilial( 'DXC' ) .And. DXC->( DXC_CODIGO ) = cConjunto

		If DXC->DXC_TIPO = '1' .And. DXC->DXC_PLUMA = '2' //Fixo e Diferente de Pluma
			nQtd += ROUND((nTotal * DXC->DXC_PERC) / 100, 2)
		Endif

		DXC->(dbSkip())
	EndDo

	RestArea(aArea)
Return nQtd


/*/{Protheus.doc} AGRA620DTV
//Função busca data de validade do documento da SD3
@author marina.muller
@since 21/06/2018
@version 1.0
@type function
/*/
Static Function AGRA620DTV()
	Local dDtValid

	DbSelectArea("DXB")
	DbSetOrder(2)
	If MsSeek(FwXFilial("DXB")+DXL->DXL_CODIGO+DXL->DXL_SAFRA+"AGRA601") //FILIAL+FARDAO+SAFRA+ROTINA
		DbSelectArea("SD3")
		DbSetOrder(2)
		If MsSeek(FwXFilial("SD3")+DXB->DXB_DOC+DXB->DXB_CODPRO) //FILIAL+DOC+COD
			dDtValid := SD3->D3_DTVALID
		EndIf
		SD3->(dbCloseArea())
	EndIf
	DXB->(dbCloseArea())

Return dDtValid

/*/{Protheus.doc} DataLote
//
@author agroindustria
@since 21/06/2018
@version 1.0

@type function
/*/
Static Function DataLote(cProd, cLote)
	Local aArea := GetArea()
	Local cQuery := ""
	Local cAliasQry := GetNextAlias()
	Local dData	:= SToD("")

	cQuery := " SELECT B8_DTVALID FROM "+RetSqlName("SB8")+" SB8 "
	cQuery += " WHERE SB8.B8_FILIAL = '"+Xfilial("SB8")+"' AND SB8.B8_PRODUTO = '"+cProd+"'"
	cQuery += " AND SB8.B8_LOTECTL = '"+cLote+"' AND SB8.D_E_L_E_T_ = '' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)

	If !(cAliasQry)->(Eof())
		dData := SToD((cAliasQry)->B8_DTVALID)
	EndIf
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)

Return dData

/*/{Protheus.doc} AtualizaDXI
//Gravação de lote e produto na tabela de fardinho.
@author brunosilva
@since 06/07/2018
@version undefined
@param cFardao, characters, descricao
@param cPluma, characters, descricao
@param cLote, characters, descricao
@param cSubLote, characters, descricao
@param cLocaliz, characters, descricao
@type function
/*/
Static Function AtualizaDXI(cFardao, cPluma, cLote, cSubLote, cLocaliz)
	Local aArea := GetArea()
	Local lRet       := .T.
	Local aMovFrd	 := {}
	Local aChaveMov	 := {}
	Local aRet		 := {}

	dbSelectArea('DXI')
	DXI->(dbSetOrder(2))
	If DXI->(dbSeek(FwXFilial('DXI')+cFardao))
		While DXI->(!Eof()) .And. ;
				DXI->DXI_FILIAL = FwXFilial('DXI') .And.;
				DXI->DXI_FARDAO = cFardao

			If RecLock('DXI',.F.)
				DXI->DXI_CODPRO := cPluma
				DXI->DXI_LOTE   := cLote
				MsUnLock()
			Endif
			If __lnewNeg
				//atualiza lote N9D
				aChaveMov := {{FwxFilial("N9D")	},;
					{DXI->DXI_SAFRA  	},;
					{DXI->DXI_ETIQ	}}

				aMovFrd   := {{{"N9D_LOTECT", cLote }}}

				aRet := AGRMOVFARD(aMovFrd, 4, 1, aChaveMov)

				if aRet[2] <> ""
					lRet := .F.
					Exit
				EndIf
			Endif

			DXI->(dbSkip())
		EndDo
	Endif

	If !lRet
		If IsInCallStack('AGRA620EA')
			cRotEA := 'AtualizaDXI'
			cErroEA   := aRet[2]
		Else
			MsgAlert(aRet[2])
		EndIf
	EndIf

	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} VldLotePrd
//Função verifica se produto tem controle por lote
@author marina.muller
@since 08/02/2019
@version 1.0
@param cProd, characters, descricao
@type function
/*/
Static Function VldLotePrd(cProd)
	Local aArea := GetArea()
	Local lRet := .T.

	DbSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(fwxFilial('SB1')+cProd))
		If SB1->B1_RASTRO = 'N'
			lRet := .F.
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet


/*/{Protheus.doc} IniPerg620
limpa variaveis do pergunte deixando campo vazio para ser reiniciado ao chamar o pergunte novamente
@type function
@version P12
@author claudineia.reinert
@since 18/08/2021
/*/
Static Function IniPerg620()
	local oFWSX1 	:= nil
	local aPergunte := {}
	Local nX 		:= 0
	Local cMVPar 	:= ""
	Local cPergunte := 'AGRA620001'
	Local nVar 		:= 16 //--numero de campos na release P12.1.33

	oFWSX1 := FWSX1Util():New()
	oFWSX1:AddGroup(cPergunte)
	oFWSX1:SearchGroup()

	aPergunte := oFWSX1:GetGroup(cPergunte)

	If Len(aPergunte) < nVar
		For nX := 1 To 16
			cMVPar := "mv_par" + PADL(cValTochar(nX),2,"0")
			&cMVPar := ""
		next nX
	EndIf

	Pergunte( 'AGRA620001', .F.) //chama pergunte para redefinir variaveis

Return .T.

/*/{Protheus.doc} EstIteAdic
Realiza o estorno por item usando a rotina MATA241
O estorno será realizado pelo MATA241 apartir da release 12.1.2210
Necessario configurar o pergunte MTA240 MV_PAR04=2(por item)
@type function
@version P12
@author claudineia.reinert
@since 27/06/2022
@param cDoc, character, numero do documento na SD3
@return Logical, Retorna se realizou o processo com sucesso ou não.
/*/
Static Function EstIteAdic(cDoc)
	Local aArea     := GetArea()
	Local aAreaSD3  := SD3->(GetArea())
	Local aItensAd  := {}
	Local aCabAd	:= {}
	Local cItem     := Space(TamSX3("D3_ITEM")[01])
	Local cCF       := "RE0"
	Local lRet 		:= .T.
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ AS D3_RECNO, D3_DOC,D3_TM,D3_EMISSAO,D3_COD,D3_UM,D3_QUANT,D3_LOCAL,D3_OP,D3_CHAVE,D3_NUMSEQ,
	cQuery += " D3_PROJPMS,D3_TASKPMS,D3_LOTECTL,D3_NUMLOTE,D3_LOCALIZ "
	cQuery += " FROM "+RetSqlName("SD3")+" SD3 "
	cQuery += " WHERE D3_FILIAL = '" + FWxFilial("SD3") + "' "
	cQuery += " AND D3_DOC = '" + cDoc + "' "
	cQuery += " AND D3_ITEM = '" + cItem + "' "
	cQuery += " AND D3_CF = '" + cCF + "' "
	cQuery += " AND SD3.D_E_L_E_T_ = '' "
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	While (cAliasQry)->(!Eof())  

		aCabAd := {}	
		aItensAd := {}	

		aAdd(aCabAd, {"D3_DOC"		, (cAliasQry)->D3_DOC				,Nil 	} ) // Documento
		aAdd(aCabAd, {"D3_TM"		,(cAliasQry)->D3_TM					,Nil	})
		aAdd(aCabAd, {"D3_EMISSAO"	,(cAliasQry)->D3_EMISSAO			,Nil	})
		
		aAdd(aItensAd,{"D3_ESTORNO"	,"S"						,Nil})
		aAdd(aItensAd,{"D3_COD"		,(cAliasQry)->D3_COD		,Nil})
		aAdd(aItensAd,{"D3_UM"		,(cAliasQry)->D3_UM			,Nil})
		aAdd(aItensAd,{"D3_QUANT"	,(cAliasQry)->D3_QUANT		,Nil})
		aAdd(aItensAd,{"D3_LOCAL"	,(cAliasQry)->D3_LOCAL		,Nil})
		aAdd(aItensAd,{"D3_OP"		,(cAliasQry)->D3_OP			,Nil})
		aAdd(aItensAd,{"D3_CHAVE"	,(cAliasQry)->D3_CHAVE		,Nil})			
		aAdd(aItensAd,{"D3_NUMSEQ"	,(cAliasQry)->D3_NUMSEQ		,Nil})
		aAdd(aItensAd,{"D3_PROJPMS"	,(cAliasQry)->D3_PROJPMS	,Nil})
		aAdd(aItensAd,{"D3_TASKPMS"	,(cAliasQry)->D3_TASKPMS	,Nil})

		//verifica se produto tem controle por lote
		If VldLotePrd(SD3->D3_COD)
			aAdd(aItensAd,{"D3_LOTECTL"	,(cAliasQry)->D3_LOTECTL	,Nil})
			aAdd(aItensAd,{"D3_NUMLOTE"	,(cAliasQry)->D3_NUMLOTE	,Nil})
			aAdd(aItensAd,{"D3_LOCALIZ"	,(cAliasQry)->D3_LOCALIZ	,Nil})
		EndIf

		lMsErroAuto := .F.
		lMsHelpAuto := .F.

		dbSelectArea('SD3')
		SD3->(dbGotop())
		SD3->(dbGoto((cAliasQry)->D3_RECNO)) //POSICIONA NO REGISTRO A SER ESTORNADO

		MSExecAuto({|x,y,z| Mata241(x,y,z)},aCabAd,{aItensAd},6) //Estorno faz por item
		If lMsErroAuto
			MostraErro()
			lRet := .F.
			Exit
		Endif

		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	RestArea(aArea)
	RestArea(aAreaSD3)
Return lRet
