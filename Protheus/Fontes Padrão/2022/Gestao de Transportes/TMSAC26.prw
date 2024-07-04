#include 'TOTVS.ch'
#include 'TMSAC26.ch'

#define DATA_STATUS		1
#define DATA_FILDOC		2
#define DATA_DOC		3
#define DATA_SERIE		4
#define DATA_CLIENTE	5
#define DATA_LOJACLI	6
#define DATA_NOMECLI	7
#define DATA_NOMEREDZ	8
#define DATA_ENDERECO	9
#define DATA_BAIRRO		10
#define DATA_CIDADE		11
#define DATA_ESTADO		12
#define DATA_CEP		13
#define DATA_RESPON		14
#define DATA_DOCRES		15
#define DATA_DATACHEG	16
#define DATA_HORACHEG	17
#define DATA_TIPODOC	18
#define DATA_IMAGEM		19
#define DATA_IDMPOS		20
#define DATA_VOLUME		21

#define DM0_ENVIADO		'13'
#define DM0_RECEBIDO	'2'

//-------------------------------------------------------------------
/*{Protheus.doc} TMSAC26()
Montagem e visualização do mapa com integração OPENSTREET

Uso: TMSAC26

@sample
//ViewDef()

@author Rodrigo Pirolo 
@since 09/09/2021
@version 1.0
@type function
*/
//-------------------------------------------------------------------
Function TMSAC26()

	Local oSize		:= Nil
	Local oListTmp	:= Nil
	Local aCab		:= { "", STR0007, STR0008, STR0016, STR0017, STR0009, STR0018, STR0019, STR0020, STR0021, STR0022, STR0010, STR0011, STR0012, STR0013, "Imagem" }
	
	Private oBrowseC26	:= Nil
	Private oDlgC26		:= Nil
	Private aDocs		:= {}
	Private oWebChannel	:= TWebChannel():New()

	//-- Calcula as dimensoes dos objetos
	oSize := FwDefSize():New( .T. )  // Com enchoicebar
	//-- Cria Enchoice
	oSize:AddObject( "MASTER", 100, 100, .T., .T. ) // Adiciona enchoice

	// adiciona Enchoice
	oSize:AddObject( "PANELMAIN", 100, 10, .T., .T. ) // Adiciona enchoice

	// adiciona Tpanel
	oSize:AddObject( "DOCS",100, 15, .T., .T. ) // Adiciona DOCS

	// adiciona Tpanel
	oSize:AddObject( "DETALHE",100, 15, .T., .T. ) // Adiciona DOCS

	// adiciona Tpanel
	oSize:AddObject( "MAP",100, 60, .T., .T. ) // Adiciona DOCS

	//-- Dispara o calculo
	oSize:Process()

	If DTQ->( LoadPedidos( DTQ_FILORI, DTQ_VIAGEM, DTQ_SERTMS ) )
		DEFINE MsDialog oDlgC26 TITLE STR0001 FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL //STR0001 "Mapa de Entregas e Coletas Realizadas
		DTQ->( LayLinear( DTQ_FILORI, DTQ_VIAGEM, oSize, oListTmp, aCab ) )
		ACTIVATE MsDialog oDlgC26 ON INIT ( EnchoiceBar( oDlgC26, { || }, { || oDlgC26:End() }, .F./*lMsgDel*/, /*aButtons*/, /*nRecno*/, /*cAlias*/, .F./*lMashups*/, .F./*lImpCad*/, /*lPadrao*/, .F./*lHasOk*/, .F./*lWalkThru*/, /*cProfileID*/ ) )
	EndIf

	FwFreeArray(aDocs)

	FwFreeObj(oDlgC26)
	
Return .T.

/*/{Protheus.doc} LoadPedidos
	(long_description)
	@type  Static Function
	@author Caio Murakami
	@since 21/09/2021
	@version 1.0
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function LoadPedidos( cFilOri, cViagem, cSerTms )

	Local cQuery	:= ""
	Local cAliasQry	:= GetNextAlias()
	Local nCount	:= 0
	Local cHelp		:= STR0002 // "Esta viagem não possui"
	Local cDoc		:= ""
	Local cPosic	:= ""
	Local lDM0Pos	:= DM0->(FieldPos("DM0_IDMPOS")) > 0

	Default cFilOri		:= ""
	Default cViagem		:= ""
	Default cSerTms		:= ""

	If FwIsInCallStack( "TMSAF60" ) .AND. cSerTms <> '1'
		cQuery		:= " SELECT DM3_FILDOC FILDOC, DM3_DOC DOC, DM3_SERIE SERIE, DM0_STATUS, DM0_NOMRES, DM0_DOCRES, DM0_DATREA, DM0_HORREA "
		cQuery		+= Iif(lDM0Pos," , DM0_IDMPOS ", "")
		cQuery		+= " FROM " + RetSqlName("DM3") + " DM3 "
		cQuery		+=			" INNER JOIN " + RetSqlName("DM0") + " DM0 ON "
		cQuery		+=			" DM0.DM0_FILDOC = DM3_FILDOC "
		cQuery		+=			" AND DM0.DM0_DOC = DM3_DOC "
		cQuery		+=			" AND DM0.DM0_SERIE = DM3_SERIE "
		cQuery		+=			" AND DM0.D_E_L_E_T_ = ' ' "
		cQuery		+= " WHERE DM3_FILIAL = '" + xfilial("DM3") + "' "
		cQuery		+= " AND DM3_FILORI = '" + cFilOri + "' "
		cQuery		+= " AND DM3_VIAGEM = '" + cViagem + "' "
		cQuery		+= " AND DM3.D_E_L_E_T_ = ' ' "
	ElseIf cSerTms == '1'
		cQuery		:= " SELECT DUD_FILDOC FILDOC, DUD_DOC DOC, DUD_SERIE SERIE, DM0_STATUS, DM0_NOMRES, DM0_DOCRES, DM0_DATREA, DM0_HORREA "
		cQuery		+= Iif(lDM0Pos," , DM0_IDMPOS ", "")
		cQuery		+= " FROM " + RetSqlName("DUD") + " DUD "
		cQuery		+=			" INNER JOIN " + RetSqlName("DM0") + " DM0 ON "
		cQuery		+=			" DM0.DM0_FILDOC = DUD_FILDOC "
		cQuery		+=			" AND DM0.DM0_DOC = DUD_DOC "
		cQuery		+=			" AND DM0.DM0_SERIE = DUD_SERIE "
		cQuery		+=			" AND DM0.D_E_L_E_T_ = ' ' "
		cQuery		+= " WHERE DUD_FILIAL = '" + xfilial("DUD") + "' "
		cQuery		+= " AND DUD_FILORI = '" + cFilOri + "' "
		cQuery		+= " AND DUD_VIAGEM = '" + cViagem + "' "
		cQuery		+= " AND DUD.D_E_L_E_T_ = ' ' "
	ElseIf cSerTms == '3'
		cQuery		:= " SELECT DTA_FILDOC FILDOC, DTA_DOC DOC, DTA_SERIE SERIE, DM0_STATUS, DM0_NOMRES, DM0_DOCRES, DM0_DATREA, DM0_HORREA "
		cQuery		+= Iif(lDM0Pos," , DM0_IDMPOS ", "")
		cQuery		+= " FROM " + RetSqlName("DTA") + " DTA "
		cQuery		+=			" INNER JOIN " + RetSqlName("DM0") + " DM0 ON "
		cQuery		+=			" DM0.DM0_FILDOC = DTA_FILDOC "
		cQuery		+=			" AND DM0.DM0_DOC = DTA_DOC "
		cQuery		+=			" AND DM0.DM0_SERIE = DTA_SERIE "
		cQuery		+=			" AND DM0.D_E_L_E_T_ = ' ' "
		cQuery		+= " WHERE DTA_FILIAL = '" + xfilial("DTA") + "' "
		cQuery		+= " AND DTA_FILORI = '" + cFilOri + "' "
		cQuery		+= " AND DTA_VIAGEM = '" + cViagem + "' "
		cQuery		+= " AND DTA.D_E_L_E_T_ = ' ' "
	EndIf

	cQuery := ChangeQuery(cQuery)
	DbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), cAliasQry, .F., .T. )

	aDocs	:= {}
	SA1->( DbSetOrder(1) )
	DT6->( DbSetOrder( 1 ) ) // DT6_FILIAL, DT6_FILDOC, DT6_DOC, DT6_SERIE
	DT5->( DbSetOrder( 1 ) ) // DT5_FILIAL+DT5_FILORI+DT5_NUMSOL
	While (cAliasQry)->( !Eof() )

		nCount++
		Aadd( aDocs, {	(cAliasQry)->DM0_STATUS,; //01
						(cAliasQry)->FILDOC,(cAliasQry)->DOC, (cAliasQry)->SERIE,; //02,03,04
						"","","","","","","","","",; //05,06,07,08,09,10,11,12,13
						(cAliasQry)->DM0_NOMRES,; //14
						(cAliasQry)->DM0_DOCRES,; //15
						SToD( (cAliasQry)->DM0_DATREA ),; //16
						Transform((cAliasQry)->DM0_HORREA, PesqPict( "DTW", "DTW_HORAJU" ) ),; //17
						"",">> Imagem <<",; //18 e 19
						Iif(lDM0Pos,(cAliasQry)->DM0_IDMPOS,""),; // 20
                        (cAliasQry)->( GetVolDua( FILDOC, DOC, SERIE, Iif(SERIE == "COL","1","3") ) ) } ) // 21

		If (cAliasQry)->SERIE == "COL"
			If DT5->( MsSeek( xFilial("DT5") + (cAliasQry)->(FILDOC + DOC) ) )
                If DUE->( MsSeek( xFilial("DUE") + DT5->DT5_CODSOL ) )
                    aDocs[nCount][05] := DT5->DT5_CODSOL
                    aDocs[nCount][07] := DUE->DUE_NOME
                    aDocs[nCount][08] := DUE->DUE_NREDUZ
                    aDocs[nCount][09] := DUE->DUE_END
                    aDocs[nCount][10] := DUE->DUE_BAIRRO
                    aDocs[nCount][11] := DUE->DUE_MUN
                    aDocs[nCount][12] := DUE->DUE_EST
                    aDocs[nCount][13] := ""
					aDocs[nCount][18] := "COL"
                Endif
            EndIf

        Else
			If DT6->( MsSeek( xFilial("DT6") + (cAliasQry)->(FILDOC + DOC + SERIE) ) )
				If SA1->( MsSeek( xFilial("SA1") + DT6->DT6_CLIDES + DT6->DT6_LOJDES ) )
                    aDocs[nCount][05] := DT6->DT6_CLIDES
                    aDocs[nCount][06] := DT6->DT6_LOJDES
                    aDocs[nCount][07] := SA1->A1_NOME
                    aDocs[nCount][08] := SA1->A1_NREDUZ
                    aDocs[nCount][09] := SA1->A1_END
                    aDocs[nCount][10] := SA1->A1_BAIRRO
                    aDocs[nCount][11] := SA1->A1_MUN
                    aDocs[nCount][12] := SA1->A1_EST
                    aDocs[nCount][13] := SA1->A1_CEP
					aDocs[nCount][18] := "CTE"
				EndIf
			EndIf
		EndIf

		(cAliasQry)->( dbSkip() )
	EndDo

	(cAliasQry)->(DbCloseArea())
	
	If Empty( aDocs )
		cDoc := STR0003 //" registros de integração com o Checklist"
	EndIf

	DbSelectArea("DAV")
	DAV->( DbSetOrder(3) ) //DAV_FILIAL, DAV_FILORI, DAV_VIAGEM, DAV_CODVEI
	If !( DAV->( DbSeek( xFilial( "DAV" ) + cFilOri + cViagem ) ) )
		cPosic += STR0004 //" registros de Posicionamento (DAV)"
	EndIf

	If nCount == 0
		If !Empty( cDoc ) .AND. !Empty( cPosic )
			cHelp := cHelp + cDoc + " " + STR0005 + cPosic + "." // "e"
		Else
			cHelp := cHelp + cDoc + cPosic + "."
		EndIf

		Help( NIL, NIL, "TMSAC26", NIL, cHelp, 1, 0, NIL, NIL, NIL, NIL, NIL, { STR0006 } ) // "Esta Rotina só pode ser utilizada quando existir registros de Posicionamento (DAV) e integração com o Checklist."
	EndIf

Return ( nCount > 0 )

//-------------------------------------------------------------------
/*{Protheus.doc} LayLinear()
Montagem e visualização do mapa com integração OPENSTREET

Uso: TMSAC26

@sample
//ViewDef()

@author Rodrigo Pirolo 
@since 09/09/2021
@version 1.0
@type function
*/
//-------------------------------------------------------------------

Static Function LayLinear( cFilOri, cViagem, oSize, oListTmp, aCab )

	Local oColumn	:= Nil
	Local cCadastro	:= STR0001

	Default cFilOri		:= ""
	Default cViagem		:= ""

	// Frame
	oPanelBody := TPanel():New( oSize:GetDimension("MASTER","LININI"), oSize:GetDimension("MASTER","COLINI"), Nil, oDlgC26, , .F., , 0, 0, oSize:GetDimension("MASTER","LINEND"), oSize:GetDimension("MASTER","COLEND") )
	oPanelBody:Align := CONTROL_ALIGN_ALLCLIENT

	// Itens do painel topo
	oPnTop := TPanel():New( 10, 3, Nil, oPanelBody, , .F., , , , oSize:GetDimension("DOCS","XSIZE"), oSize:GetDimension("DOCS","YSIZE") )
	oPnTop:Align := CONTROL_ALIGN_TOP

	// Define o Browse
	oBrowseC26 := FWBrowse():New( oPnTop )
	oBrowseC26:SetDataArray( .T. )
	oBrowseC26:SetArray( aDocs )
	oBrowseC26:SetDescription( cCadastro )
	oBrowseC26:DisableConfig( .T. )
	oBrowseC26:DisableReport( .T. )
	oBrowseC26:DisableLocate( .T. )
	oBrowseC26:DisableFilter( .T. )

	// Cria uma coluna de legenda
	oBrowseC26:AddLegend( { || aDocs[oBrowseC26:nAt, DATA_STATUS] $  DM0_ENVIADO	}, "RED",	STR0028 ) //STR0028 "Entregue/Coletado."
	oBrowseC26:AddLegend( { || aDocs[oBrowseC26:nAt, DATA_STATUS] == DM0_RECEBIDO	}, "GREEN",	STR0027 ) //STR0027 "Em Transito."

	// Adiciona as colunas do Browse
	oColumn := FWBrwColumn():New()
	oColumn:SetData( { || aDocs[oBrowseC26:nAt, DATA_TIPODOC] } )
	oColumn:SetTitle( STR0007 ) // "Tipo Doc"
	oColumn:SetSize( 3 )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { || aDocs[oBrowseC26:nAt, DATA_FILDOC ] } )
	oColumn:SetTitle( STR0023 ) //"Filial Documento"
	oColumn:SetPicture( PesqPict( "DT6", "DT6_FILDOC" ) )
	oColumn:SetSize( TamSX3("DT6_FILDOC")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { || aDocs[oBrowseC26:nAt, DATA_DOC ] } )
	oColumn:SetTitle( STR0008 ) //"Nº Documento"
	oColumn:SetPicture( PesqPict( "DT6", "DT6_DOC" ) )
	oColumn:SetSize( TamSX3("DT6_DOC")[1])

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { || aDocs[oBrowseC26:nAt, DATA_SERIE ] } )
	oColumn:SetTitle( STR0024 ) //"Serie"
	oColumn:SetPicture( PesqPict( "DT6", "DT6_SERIE" ) )
	oColumn:SetSize( TamSX3("DT6_SERIE")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_CLIENTE] } )
	oColumn:SetTitle( STR0016 ) // "Cod. Cliente Destinatario"
	oColumn:SetPicture( PesqPict( "DT6", "DT6_CLIDES" ) )
	oColumn:SetSize( TamSX3("DT6_CLIDES")[1] )

	oBrowseC26:SetColumns( { oColumn } )
	
	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_LOJACLI] } )
	oColumn:SetTitle( STR0017 ) // "Loja Cliente Destinatário"
	oColumn:SetPicture( PesqPict( "DT6", "DT6_LOJDES" ) )
	oColumn:SetSize( TamSX3("DT6_LOJDES")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_NOMEREDZ] } )
	oColumn:SetTitle( STR0009 ) // "Cliente Destinatário"
	oColumn:SetPicture( PesqPict( "SA1", "A1_NREDUZ" ) )
	oColumn:SetSize( TamSX3("A1_NREDUZ")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_ENDERECO] } )
	oColumn:SetTitle( STR0018 ) // "Endereço Destinatário"
	oColumn:SetPicture( PesqPict( "SA1", "A1_END" ) )
	oColumn:SetSize( TamSX3("A1_END")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_BAIRRO] } )
	oColumn:SetTitle( STR0019 ) // "Bairro Destinatário"
	oColumn:SetPicture( PesqPict( "SA1", "A1_BAIRRO" ) )
	oColumn:SetSize( TamSX3("A1_BAIRRO")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_CIDADE] } )
	oColumn:SetTitle( STR0020 ) // "Cidade Destinatário"
	oColumn:SetPicture( PesqPict( "SA1", "A1_MUN" ) )
	oColumn:SetSize( TamSX3("A1_MUN")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_ESTADO] } )
	oColumn:SetTitle( STR0021 ) // "Estado Destinatário"
	oColumn:SetPicture( PesqPict( "SA1", "A1_EST" ) )
	oColumn:SetSize( TamSX3("A1_EST")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_CEP] } )
	oColumn:SetTitle( STR0022 ) // "CEP Destinatário"
	oColumn:SetPicture( PesqPict( "SA1", "A1_CEP" ) )
	oColumn:SetSize( TamSX3("A1_CEP")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_RESPON] } )
	oColumn:SetTitle( STR0010 ) // 'Nome do Responsavel'
	oColumn:SetPicture( PesqPict( "DM0", "DM0_NOMRES" ) )
	oColumn:SetSize( TamSX3("DM0_NOMRES")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_DOCRES] } )
	oColumn:SetTitle( STR0011 ) // Documento do Responsavel 
	oColumn:SetPicture( PesqPict( "DM0", "DM0_NOMRES" ) )
	oColumn:SetSize( TamSX3("DM0_DOCRES")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_DATACHEG] } )
	oColumn:SetTitle( STR0012 ) // "Data da Realização"
	oColumn:SetPicture( PesqPict( "DM0", "DM0_NOMRES" ) )
	oColumn:SetSize( TamSX3("DM0_DATREA")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_HORACHEG] } )
	oColumn:SetTitle( STR0013 ) // Hora da Realização
	oColumn:SetPicture( PesqPict( "DTW", "DTW_HORAJU" ) )
	oColumn:SetSize( TamSX3("DM0_HORREA")[1] )

	oBrowseC26:SetColumns( { oColumn } )

	oColumn := FWBrwColumn():New()
	oColumn:SetData( { ||aDocs[oBrowseC26:nAt, DATA_IMAGEM] } )
	oColumn:SetTitle( STR0025 ) // Imagem
	oColumn:SetSize( TamSX3("DM0_HORREA")[1] )
	oColumn:SetDoubleClick( { || TMSAE71Img( aDocs[oBrowseC26:nAt, DATA_FILDOC ], aDocs[oBrowseC26:nAt, DATA_DOC ], aDocs[ oBrowseC26:nAt, DATA_SERIE ] ) } )

	oBrowseC26:SetColumns( { oColumn } )

	oBrowseC26:Activate()

	// Cria navegador embedado
	oPanelCent := TPanel():New( 0, 0, Nil, oPanelBody, , .F., , 0, , 1890, 620 )
	oPanelCent:Align := CONTROL_ALIGN_ALLCLIENT
	
	oPanelSup := TPanel():New( 1400, 0, Nil, oPanelCent, , .F., , 0, , 1890, 620 )
	oPanelSup:Align := CONTROL_ALIGN_TOP

	TMSAC27( oPanelSup, cFilOri, cViagem, aDocs )

Return

//-------------------------------------------------------------------
/*{Protheus.doc} GetVolDua()
Busca o volume da entrega ou coleta realizada pelo checklist

Uso: TMSAC26
@sample
@author Rodrigo Pirolo 
@since 26/10/2021
@version 1.0
@type function
*/
//-------------------------------------------------------------------

Static Function GetVolDua( cFilDoc, cDoc, cSerie, cSerTms )

	Local aArea			:= GetArea()
	Local aAreaDTQ		:= DTQ->( GetArea() )
	Local aAreaDUA		:= DUA->( GetArea() )
	Local cOcorr		:= ""
	Local nRet			:= 0

	Default cFilDoc		:= ""
	Default cDoc		:= ""
	Default cSerie		:= ""
	Default cSerTms		:= ""

	If ( cSerie == 'COL' .AND. cSerTms == '3' ) .OR. cSerTms == '1'
		cOcorr := PadR( SuperGetMV( "MV_OCORCOL", .F., ""), Len( DT2->DT2_CODOCO ) )
	ElseIf cSerTms == '3'
		cOcorr := PadR( SuperGetMV( "MV_OCORENT", .F., ""), Len( DT2->DT2_CODOCO ) )
	EndIf

	DbSelectArea("DUA")
	DUA->( DbSetOrder( 3 ) )// DUA_FILIAL, DUA_CODOCO, DUA_FILDOC, DUA_DOC, DUA_SERIE

	If DUA->( DbSeek( FWxFilial("DUA") + cOcorr + cFilDoc + cDoc + cSerie ) )
		nRet := DUA->DUA_QTDOCO
	EndIf

	RestArea(aArea)
	RestArea(aAreaDTQ)
	RestArea(aAreaDUA)

Return nRet
