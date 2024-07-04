#INCLUDE "AGRA602.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "PARMTYPE.ch"
#include "report.ch"

// constantes do array aDXMagrup
#DEFINE A_DXM_PRDTOR 	01
#DEFINE A_DXM_LJPRO 		02
#DEFINE A_DXM_NMPDTR 	03
#DEFINE A_DXM_PSFISC 	04
#DEFINE A_DXM_PSLIQU 	05
#DEFINE A_COL_DIFERENCA 	06

// constantes do array aDXMdetalhe
#DEFINE A_DXMD_MARCA	 	01
#DEFINE A_DXMD_CODIGO 	02
#DEFINE A_DXMD_DTEMIS	03
#DEFINE A_DXMD_NOTA 		04
#DEFINE A_DXMD_SERIE	 	05
#DEFINE A_DXMD_PSFISC 	06
#DEFINE A_DXMD_PSLIQU 	07
#DEFINE A_COLD_DIFERENCA	08
#DEFINE A_DXMD_NFCOMP	09
#DEFINE A_DXMD_SRCOMP	10
#DEFINE A_DXMD_RECNO	 	11

//Pula Linha
#DEFINE CTRL Chr(13)+Chr(10)

Static __oArqTemp := Nil
/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGRA602
Lista os complementos necessários para os Romaneios de Entrada

@param: Nil
@author: Marlon Richard Trettin
@since: 25/07/14
@Uso: GENERICO
------------------------------------------------------------------------------------------ **/
Function AGRA602()

	Local oDlg
	Local aButtons  := {}
	Local cVar 		:= Nil

	Private oDXMagrup, aDXMagrup := {}
	Private dDataIni  	:= CtoD("//")
	Private dDataFim  	:= dDataBase
	Private cPerg 		:= PADR("AGRA602",10)

	// Abre a tela de parâmetros para o usuário
	Pergunte(cPerg, .T.)

	dDataIni := MV_PAR01
	dDataFim := MV_PAR02

	// Define botões da tela
	AAdd( aButtons, { "IMPRESSAO",{ || A602Imprime()}, STR0001 , STR0002 } ) //"Imprimir romaneios que necessitam NF complementar"###"Imprimir"
	AAdd( aButtons, { "BMPCONS",  { || A602Vincula( aDXMagrup[ oDXMagrup:nAt, A_DXM_PRDTOR ], aDXMagrup[ oDXMagrup:nAt, A_DXM_LJPRO ] )}, STR0003 , STR0004 } ) //"Vincular nota fiscal complementar aos romaneios"###"Vincular"

	DEFINE MSDIALOG oDlg FROM  000,000 TO 477,680 TITLE STR0005 PIXEL Style DS_MODALFRAME //"Romaneios que necessitam de nota fiscal complementar"

	@ 10,005 SAY STR0006 OF oDlg PIXEL //"Período de"
	@ 08,050 MSGET dDataIni Picture "@D"  SIZE 40,9 When .F. OF oDlg PIXEL
	@ 10,095 SAY STR0007 OF oDlg PIXEL //"Até"
	@ 08,130 MSGET dDataFim Picture "@D"  SIZE 40,9 When .F. OF oDlg PIXEL

	@ 25,001 TO 235,335 LABEL "" OF oDlg PIXEL

	@ 30,003 LISTBOX oDXMagrup VAR cVar Fields HEADER ;
	TitSX3( "DXM_PRDTOR" )[1], TitSX3( "DXM_LJPRO" )[1], TitSX3( "DXM_NMPDTR" )[1], TitSX3( "DXM_PSFISC" )[1], TitSX3( "DXM_PSLIQU" )[1], STR0008; //"Diferença"
	COLSIZES 40, 20, 90, 50, 50, 50 SIZE 330, 190 OF oDlg PIXEL

	// Inicializa a lista
	Processa( {|| QryDXMagrup() }, STR0009 ) //"AGUARDE"

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg, {|| oDlg:End() }, {|| oDlg:End() } ,, @aButtons )

Return NIL

/** ------------------------------------------------------------------------------------------
{Protheus.doc} QryDXMagrup
Carrega dados para o array aDXMagrup

@param: Nil
@author: Marlon Richard Trettin
@since: 25/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function QryDXMagrup()

	Local cFiltro := ""
	Private cUserBenf := A655GETUNB()// Busca a unidade de beneficiamento

	ProcRegua(0)
	IncProc()

	aDXMagrup := {}

	cFiltro := " DXM.DXM_DTDIGI BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"'"
	cFiltro += "AND DXM.DXM_NFCOMP =  ' ' "
	cFiltro += "AND DXM.DXM_SRCOMP =  ' ' "
	cFiltro += "AND DXM.DXM_STATUS =  '2' " // 2=Encerrado
	cFiltro += "AND DXM.DXM_FILIAL =  '"+FWxFilial("DXM")+"' "
	cFiltro += "AND DXM.DXM_NOTA   <> ' ' "
	IIF (!Empty(cUserBenf), cFiltro += "AND DXM.DXM_CODUNB =  '"+cUserBenf+"'",)
	cFiltro := "%" + cFiltro + "%"

	BeginSql Alias "QryDXM"
		Select
		DXM.DXM_PRDTOR, DXM.DXM_LJPRO, SUM(DXM.DXM_PSFISC) AS DXM_PSFISC, SUM(DXM.DXM_PSLIQU) AS DXM_PSLIQU
		From
		%Table:DXM% DXM
		Where
		DXM.%NotDel% And
		%Exp:cFiltro%
		Group By DXM.DXM_PRDTOR, DXM.DXM_LJPRO
	EndSQL

	While .Not. QryDXM->( Eof() )

		IncProc()

		aAdd( aDXMagrup, { QryDXM->( DXM_PRDTOR ),; 	//A_DXM_PRDTOR
		QryDXM->( DXM_LJPRO ),;		//A_DXM_LJPRO
		IIF(GetRPORelease() < "12.1.023",Posicione( "DX8", 1, xFilial("DX8") + QryDXM->( DXM_PRDTOR ) + QryDXM->( DXM_LJPRO ), "DX8_NOME"),; 
		Posicione( "NJ0", 1, FWxFilial("NJ0") + QryDXM->( DXM_PRDTOR ) + QryDXM->( DXM_LJPRO ), "NJ0_NOME" )),; 	//A_DXM_NMPDTR
		QryDXM->( DXM_PSFISC ),;	//A_DXM_PSFISC
		QryDXM->( DXM_PSLIQU ),;	//A_DXM_PSLIQU
		QryDXM->( DXM_PSLIQU ) - QryDXM->( DXM_PSFISC ) } )	//A_COL_DIFERENCA

		QryDXM->( dbSkip() )
	EndDo
	QryDXM->( dbCloseArea() )

	If Len( aDXMagrup ) == 0
		aAdd( aDXMagrup, { "", "", "", 0, 0, 0 } )
	EndIf

	// Ordena o array pelo nome do produtor
	aDXMagrup := aSort( aDXMagrup,,, { |x, y| x[ A_DXM_NMPDTR ] < y[ A_DXM_NMPDTR ] } )

	RefDXMagrup()

Return .T.

/** ------------------------------------------------------------------------------------------
{Protheus.doc} RefDXMagrup
Inicializa e dá refresh na lista criada pelo array aDXMagrup

@param: Nil
@author: Marlon Richard Trettin
@since: 25/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function RefDXMagrup()

	oDXMagrup:SetArray(aDXMagrup)
	oDXMagrup:nAt   := 1
	oDXMagrup:bLine := {|| { aDXMagrup[ oDXMagrup:nAt, A_DXM_PRDTOR ],;
	aDXMagrup[ oDXMagrup:nAt, A_DXM_LJPRO ],;
	aDXMagrup[ oDXMagrup:nAt, A_DXM_NMPDTR ],;
	Transform( aDXMagrup[ oDXMagrup:nAt, A_DXM_PSFISC ], PesqPict( "DXM", "DXM_PSFISC" ) ),;
	Transform( aDXMagrup[ oDXMagrup:nAt, A_DXM_PSLIQU ], PesqPict( "DXM", "DXM_PSLIQU" ) ),;
	Transform( aDXMagrup[ oDXMagrup:nAt, A_COL_DIFERENCA ], PesqPict( "DXM", "DXM_PSFISC" ) ) } }
	oDXMagrup:Refresh()

Return NIL

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A602Vincula
Lista os romaneios que necessitam ser vinculados a uma NF complementar

@param: pcPrdtor, pcLjPro
@author: Marlon Richard Trettin
@since: 27/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function A602Vincula(pcPrdtor, pcLjPro)

	Local oDlgVinc
	Local aButtons	:= {}
	Local cNomPro 	:= IIF(GetRPORelease() < "12.1.023", Posicione( "DX8", 1, xFilial("DX8") + pcPrdtor + pcLjPro, "DX8_NOME" ),Posicione( "NJ0", 1, FWxFilial("NJ0") + pcPrdtor + pcLjPro, "NJ0_NOME" ))
	Local oSize     := Nil
	Local oPnMain
	Local oPnFardao
	Local oPnButton
	Local aCords	:= FWGetDialogSize( oMainWnd )

	Private oDXMdetalhe, aDXMdetalhe := {}
	Private oStO		:= LoadBitmap( GetResources(), "unchecked_15" )
	Private oStX		:= LoadBitmap( GetResources(), "checked_15" )
	Private oTtPSFISC, nTtPSFISC := 0
	Private oTtPSLIQU, nTtPSLIQU := 0
	Private oTtDifer, nTtDifer  := 0
	Private cMarca		:= GetMark()
	Private oBrowseRom	:= Nil
	Private cAliasTRB 	:= GetNextAlias()
	Private aColumns 	:= {}
	
	DEFINE MSDIALOG oDlgVinc FROM  000,000 TO aCords[ 3 ]*0.8, aCords[ 4 ]*0.8 TITLE STR0005 PIXEL Style DS_MODALFRAME //"Romaneios que necessitam de nota fiscal complementar"

	//Limitadores de utilizacao de espacos da tela
	oSize := FwDefSize():New()             
	oSize:AddObject( "CABECALHO",  100, 5, .T., .T. ) 
	If .NOT.(IsV12("12"))
		oSize:AddObject( "GRID"     ,  100, 90, .T., .T. )
	Else
		oSize:AddObject( "GRID"     ,  100, 90, .T., .T. )
	EndIf	
	oSize:AddObject( "RODAPE"     ,  100, 5, .T., .T. )
	oSize:lProp 	 := .T. // Proporcional             
	oSize:aMargins := { 1, 1, 1, 1 } // Espaco ao lado dos objetos 0, entre eles 3 
	oSize:Process() 	   // Dispara os calculos   

	oPnMain := TPanel():New( oSize:GetDimension("CABECALHO","LININI"), oSize:GetDimension("CABECALHO","COLINI"), ,oDlgVinc, , , , , ,oSize:GetDimension("CABECALHO","COLEND"), oSize:GetDimension("CABECALHO","LINEND"))

	If .NOT.(IsV12("12"))
		oPnFardao := TPanel():New( oSize:GetDimension("GRID","LININI"), oSize:GetDimension("GRID","COLINI"), ,oDlgVinc, , , , , ,oSize:GetDimension("GRID","COLEND")/1.26, oSize:GetDimension("GRID","LINEND")/1.5)
	Else
		oPnFardao := TPanel():New( oSize:GetDimension("GRID","LININI"), oSize:GetDimension("GRID","COLINI"), ,oDlgVinc, , , , , ,oSize:GetDimension("GRID","COLEND")/1.26, oSize:GetDimension("GRID","LINEND")/1.8)
	EndIf

	oPnButton := TPanel():New( oSize:GetDimension("RODAPE","LININI")/1.3, oSize:GetDimension("RODAPE","COLINI"), ,oDlgVinc, , , , , ,oSize:GetDimension("RODAPE","COLEND"), oSize:GetDimension("RODAPE","LINEND"))

	//Campos Cabecalho
	@ 002,005 SAY TitSX3( "DXM_PRDTOR" )[1] OF oPnMain PIXEL //"Produtor"
	@ 001,050 MSGET pcPrdtor 	Picture "@!"  SIZE 40,9 	When .F. OF oPnMain PIXEL
	@ 001,090 MSGET pcLjPro	Picture "@!"  SIZE 20,9 	When .F. OF oPnMain PIXEL
	@ 001,110 MSGET cNomPro	Picture "@!"  SIZE 150,9 	When .F. OF oPnMain PIXEL

	//Cria tabela temporaria para browse
	cAliasTRB := CriaTmpTbl(@aColumns, @cAliasTRB, pcPrdtor, pcLjPro)

	oBrowseRom := FwMarkBrowse():New()
	oBrowseRom:SetDescription("")  
	oBrowseRom:SetFieldMark("DXM_OK")
	oBrowseRom:SetOwner(oPnFardao)
	oBrowseRom:SetDataQuery(.F.)
	oBrowseRom:SetDataTable(.T.)
	oBrowseRom:SetAlias(cAliasTRB)
	oBrowseRom:cMark := cMarca
	oBrowseRom:bAllMark := { ||  }
	oBrowseRom:SetColumns(aColumns)
	oBrowseRom:DisableConfig(.t.)
	oBrowseRom:DisableReport(.t.)
	oBrowseRom:DisableDetails()
	oBrowseRom:SetMenuDef("")
	oBrowseRom:DisableFilter()
	oBrowseRom:SetAfterMark({|| AtuaRodape(cAliasTRB, oBrowseRom) })
	oBrowseRom:SetAllMark({|| AtuaRodape(cAliasTRB, oBrowseRom)})
	oBrowseRom:Activate(oPnFardao)

	//Campos rodape
	@ 001,160 MSGET oTtPSFISC VAR nTtPSFISC		Picture PesqPict( "DXM", "DXM_PSFISC" )  SIZE 50,9 	When .F. OF oPnButton PIXEL
	@ 001,210 MSGET oTtPSLIQU VAR nTtPSLIQU		Picture PesqPict( "DXM", "DXM_PSLIQU" )  SIZE 50,9 	When .F. OF oPnButton PIXEL
	@ 001,260 MSGET oTtDifer  VAR nTtDifer		Picture PesqPict( "DXM", "DXM_PSLIQU" )  SIZE 50,9 	When .F. OF oPnButton PIXEL

	// Define botões da tela
	AAdd( aButtons, { "BMPCONS",  { || VinculaNF(@cAliasTRB, @oBrowseRom)}, STR0003 , STR0004 } ) //"Vincular nota fiscal complementar aos romaneios"###"Vincular"

	ACTIVATE MSDIALOG oDlgVinc CENTERED ON INIT EnchoiceBar( oDlgVinc, {|| AGR602Conf(@cAliasTRB, @oBrowseRom), oDlgVinc:End() }, {|| oDlgVinc:End() } ,, @aButtons )


Return NIL

/** ------------------------------------------------------------------------------------------
{Protheus.doc} AtuaRodape
Atualiza o rodape

@param: cAliasGrid, oGrid
@author: Carlos Augusto Pereira
@since: 23/05/2017
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function AtuaRodape(cAliasGrid, oGrid)
	Local aArea := GetArea()
	Local lRet  := .T.

	nTtPSFISC := 0
	nTtPSLIQU := 0
	nTtDifer  := 0

	dbSelectArea(cAliasGrid)
	dbGoTop()

	While .Not. Eof()	

		If oGrid:IsMark()
			nTtPSFISC += (cAliasGrid)->DXM_PSFISC
			nTtPSLIQU += (cAliasGrid)->DXM_PSLIQU
			nTtDifer  += (cAliasGrid)->DXM_PSLIQU - (cAliasGrid)->DXM_PSFISC
		Endif

		DbSkip()
	EndDo	

	oTtPSFISC:CtrlRefresh()
	oTtPSLIQU:CtrlRefresh()
	oTtDifer:CtrlRefresh()

	RestArea(aArea)
Return lRet



/** ------------------------------------------------------------------------------------------
{Protheus.doc} QryDXMdetalhe
Carrega dados para o array aDXMdetalhe

@param: pcPrdtor, pcLjPro
@author: Marlon Richard Trettin
@since: 27/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function QryDXMdetalhe( pcPrdtor, pcLjPro )

	Local cFiltro := ""

	ProcRegua(0)
	IncProc()

	aDXMdetalhe := {}

	cFiltro := " DXM.DXM_DTDIGI BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"'"
	cFiltro += "AND DXM.DXM_NFCOMP = ' ' "
	cFiltro += "AND DXM.DXM_SRCOMP = ' ' "
	cFiltro += "AND DXM.DXM_STATUS = '2' " // 2=Encerrado
	cFiltro += "AND DXM.DXM_FILIAL = '"+FWxFilial("DXM")+"' "
	cFiltro += "AND DXM.DXM_PRDTOR = '"+pcPrdtor+"' "
	cFiltro += "AND DXM.DXM_LJPRO = '"+pcLjPro+"' "
	cFiltro += "AND DXM.DXM_NOTA <> ' ' "
	IIF (!Empty(cUserBenf), cFiltro += "AND DXM.DXM_CODUNB =  '"+cUserBenf+"'",)

	cFiltro := "%" + cFiltro + "%"

	BeginSql Alias "QryDXM"
		Select
		DXM.DXM_CODIGO, DXM.DXM_DTEMIS, DXM.DXM_NOTA, DXM.DXM_SERIE, DXM.DXM_PSFISC, DXM.DXM_PSLIQU, DXM.DXM_NFCOMP, DXM.DXM_SRCOMP, DXM.R_E_C_N_O_ AS DXM_RECNO
		From
		%Table:DXM% DXM
		Where
		DXM.%NotDel% And
		%Exp:cFiltro%
	EndSQL

	While .Not. QryDXM->( Eof() )

		IncProc()

		aAdd( aDXMdetalhe, { .F.					  ,;	//A_DXMD_MARCA
		QryDXM->( DXM_CODIGO ),; 			//A_DXMD_CODIGO
		StoD( QryDXM->( DXM_DTEMIS ) ),;	//A_DXMD_DTEMIS
		QryDXM->( DXM_NOTA   ),;			//A_DXMD_NOTA
		QryDXM->( DXM_SERIE  ),;			//A_DXMD_SERIE
		QryDXM->( DXM_PSFISC ),;			//A_DXMD_PSFISC
		QryDXM->( DXM_PSLIQU ),;			//A_DXMD_PSLIQU
		QryDXM->( DXM_PSLIQU ) - QryDXM->( DXM_PSFISC ),;	//A_COLD_DIFERENCA
		QryDXM->( DXM_NFCOMP ),;			//A_DXMD_NFCOMP
		QryDXM->( DXM_SRCOMP ),;			//A_DXMD_SRCOMP
		QryDXM->( DXM_RECNO  ) } )			//A_DXMD_RECNO

		QryDXM->( dbSkip() )
	EndDo
	QryDXM->( dbCloseArea() )

	If Len( aDXMdetalhe ) == 0
		aAdd( aDXMdetalhe, { .F., "", CtoD("//"), "", "", 0, 0, 0, "", "", 0 } )
	EndIf

Return .T.

/** ------------------------------------------------------------------------------------------
{Protheus.doc} NFCompDado
Carrega dados para o array aDXMdetalhe

@param: pcPrdtor, pcLjPro
@author: Marlon Richard Trettin
@since: 27/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function NFCompDado( pcPrdtor, pcLjPro, cAliasTRB )

	Local cFiltro := ""

	ProcRegua(0)
	IncProc()

	aDXMdetalhe := {}

	cFiltro := " DXM.DXM_DTDIGI BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"'"
	cFiltro += "AND DXM.DXM_NFCOMP = ' ' "
	cFiltro += "AND DXM.DXM_SRCOMP = ' ' "
	cFiltro += "AND DXM.DXM_STATUS = '2' " // 2=Encerrado
	cFiltro += "AND DXM.DXM_FILIAL = '"+FWxFilial("DXM")+"' "
	cFiltro += "AND DXM.DXM_PRDTOR = '"+pcPrdtor+"' "
	cFiltro += "AND DXM.DXM_LJPRO = '"+pcLjPro+"' "
	cFiltro += "AND DXM.DXM_NOTA <> ' ' "
	IIF (!Empty(cUserBenf), cFiltro += "AND DXM.DXM_CODUNB =  '"+cUserBenf+"'",)

	cFiltro := "%" + cFiltro + "%"

	BeginSql Alias "QryDXM"
		Select
		DXM.DXM_CODIGO, DXM.DXM_DTEMIS, DXM.DXM_NOTA, DXM.DXM_SERIE, DXM.DXM_PSFISC, DXM.DXM_PSLIQU, DXM.DXM_NFCOMP, DXM.DXM_SRCOMP, DXM.R_E_C_N_O_ AS DXM_RECNO
		From
		%Table:DXM% DXM
		Where
		DXM.%NotDel% And
		%Exp:cFiltro%
	EndSQL

	While .Not. QryDXM->( Eof() )

		IncProc()

		Reclock(cAliasTRB, .T.)
		Replace (cAliasTRB)->DXM_CODIGO With QryDXM->( DXM_CODIGO )
		Replace (cAliasTRB)->DXM_DTEMIS With StoD(QryDXM->( DXM_DTEMIS ))
		Replace (cAliasTRB)->DXM_NOTA With QryDXM->( DXM_NOTA )
		Replace (cAliasTRB)->DXM_SERIE With QryDXM->( DXM_SERIE )
		Replace (cAliasTRB)->DXM_PSFISC With QryDXM->( DXM_PSFISC )
		Replace (cAliasTRB)->DXM_PSLIQU With QryDXM->( DXM_PSLIQU )
		Replace (cAliasTRB)->DXM_DIF With (QryDXM->( DXM_PSLIQU ) - QryDXM->( DXM_PSFISC ))
		Replace (cAliasTRB)->DXM_NFCOMP With QryDXM->( DXM_NFCOMP )
		Replace (cAliasTRB)->DXM_SRCOMP With QryDXM->( DXM_SRCOMP )

		(cAliasTRB)->(MsUnlock())

		QryDXM->( dbSkip() )
	EndDo
	QryDXM->( dbCloseArea() )

Return cAliasTRB


/** ------------------------------------------------------------------------------------------
{Protheus.doc} VinculaNF
Abre um diálogo para o usuário informar o número e série da NF complementar, e vincula aos romaneios selecionados 

@param: Nil
@author: Marlon Richard Trettin
@since: 27/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function VinculaNF(cAliasTRB, oBrowseRom)

	Local oDlgVincNF
	Local aButtons	:= {}
	Local cNFComp := Space(TamSX3("DXM_NFCOMP")[1])
	Local cSrComp := Space(TamSX3("DXM_SRCOMP")[1])
	Local aRet := {}
	Local lRetSF1 := .F.
	Local oPnMainNF
	Local lAG600VNF := ExistBlock("AG600VNF")

	Private _lAg602Ret := .F.



	If !AGRIsSelec(@cAliasTRB, @oBrowseRom)
		MsgAlert( STR0011 ) //"Marque os romaneios que deseja vincular à nota fiscal complementar."
		Return( .F. )
	EndIf

   //-- PONTO DE ENTRADA - Alimentar via PE dados de NF de vinculo
	If lAG600VNF
		aRet := ExecBlock("AG600VNF",.F.,.F.)
		If ValType(aRet) == "A"
			cNFComp := aRet[1]
			cSrComp := aRet[2]
		EndIf
	Else
		DEFINE MSDIALOG oDlgVincNF FROM  000,000 TO 125,350 TITLE STR0010 PIXEL Style DS_MODALFRAME //"Vincular romaneios selecionados a"

		oSizeNF := FwDefSize():New()             
		oSizeNF:AddObject( "TOTAL",  100, 100, .T., .T. ) 
		oSizeNF:lProp 	 := .T. // Proporcional             
		oSizeNF:aMargins := { 1, 1, 1, 1 } // Espaco ao lado dos objetos 0, entre eles 3 
		oSizeNF:Process() 	   // Dispara os calculos   

		oPnMainNF := TPanel():New( oSizeNF:GetDimension("TOTAL","LININI"), oSizeNF:GetDimension("TOTAL","COLINI"), ,oDlgVincNF, , , , , ,oSizeNF:GetDimension("TOTAL","COLEND"), oSizeNF:GetDimension("TOTAL","LINEND"))

		@ 005,005 SAY TitSX3( "DXM_NFCOMP" )[1] OF oPnMainNF PIXEL //"NF Complem"
		@ 003,050 MSGET cNFComp 	Picture "@!"  SIZE 40,9 	When .T. OF oPnMainNF PIXEL 
		@ 017,005 SAY TitSX3( "DXM_SRCOMP" )[1] OF oPnMainNF PIXEL //"Serie Compl"
		@ 017,050 MSGET cSrComp	Picture "@!"  SIZE 40,9 	When .T. OF oPnMainNF PIXEL 
		
		ACTIVATE MSDIALOG oDlgVincNF CENTERED ON INIT EnchoiceBar( oDlgVincNF, {|| _lAg602Ret:=.T., oDlgVincNF:End() }, {|| _lAg602Ret:=.F., oDlgVincNF:End() } ,, @aButtons )	
	EndIf


	If _lAg602Ret

		lRetSF1 := Agr602SF1(cNFComp,cSrComp)

		If lRetSF1

			dbSelectArea(cAliasTRB)
			dbGoTop()
			While .Not. Eof()
				If oBrowseRom:IsMark()
					dbSelectArea("DXM")
					dbSetOrder(1)
					If MSSeek(FWxFilial("DXM")+(cAliasTRB)->DXM_CODIGO)

						RecLock(cAliasTRB, .F. )

						(cAliasTRB)->DXM_NFCOMP := cNFComp
						(cAliasTRB)->DXM_SRCOMP := cSrComp

						MsUnLock(cAliasTRB)
					EndIf
				EndIf
				dbSelectArea(cAliasTRB)
				DbSkip()
			EndDo	
			(cAliasTRB)->(dbGoTop())
			oBrowseRom:Refresh()
		EndIf 

	EndIf

Return( .T. )


/** ------------------------------------------------------------------------------------------
{Protheus.doc} Agr602SF1
Valida nota de complemento

@param: Nil
@author: Maicol lange
@since: 21/07/15
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function Agr602SF1(cNFComp, cSrComp)
	Local lRet  	:= .F.
	Local cCodEnt	:=	aDXMagrup[ oDXMagrup:nAt, A_DXM_PRDTOR]
	Local cLjEnt	:=	aDXMagrup[ oDXMagrup:nAt, A_DXM_LJPRO ]
	Local cCliFor 	:= Space(TamSX3("DXM_PRDTOR")[1])
	Local cLjCliFor := Space(TamSX3("DXM_LJPRO")[1])
	Local aArea		:= GetArea()
	Local aAreaDXM	:= DXM->(GetArea())
	
	dbSelectArea(cAliasTRB)
	(cAliasTRB)->(dbGoTop()) //arquivo temporario com os romaneio marcados para vincular a NF de complemento
	dbSelectArea("DXM")
	DXM->(dbSetOrder(1))
	While (cAliasTRB)->(!Eof())
		If oBrowseRom:IsMark() //se esta marcado
			If DXM->(MSSeek(FWxFilial("DXM")+(cAliasTRB)->DXM_CODIGO)) 
				//posiciona na DXM conforme primeiro romaneio marcado no browser e não o posicionado em tela	
				dbSelectArea("NJ0")
				NJ0->(dbSetOrder(1))
				If NJ0->(MsSeek(FWxFilial("NJ0")+cCodEnt+cLjEnt))
					cCliFor 	:= If( DXM->DXM_PROPRI  == '1', NJ0->NJ0_CODFOR, NJ0->NJ0_CODCLI )
					cLjCliFor	:= If( DXM->DXM_PROPRI  == '1', NJ0->NJ0_LOJFOR, NJ0->NJ0_LOJCLI )
				EndIf
				Exit //sai do while, pega somente o primeiro romaneio marcado
			EndIf
		EndIf
		dbSelectArea(cAliasTRB)
		(cAliasTRB)->(DbSkip())
	EndDo
	
	DbSelectArea("SF1")
	SF1->(DBSetOrder(2))
	If SF1->(MSSeek(FWxFilial("SF1")+cCliFor+cLjCliFor+cNFComp))
		if (nTtDifer != SF1->F1_PLIQUI)
			Help("",1,STR0012,,STR0013 + CHR(13)+ CVALTOCHAR(SF1->F1_PLIQUI) ,1)// Quantidade da nota diferente do complemento
			lRet := .F.
		else
			lRet := .T.
		endif	
	Else
		Help("",1, STR0012,,STR0014+ CHR(10)+;
		STR0015 + cNFComp+ CHR(10)+;
		STR0016+cSrComp,1) // nota fical não existe
		lRet := .F.
	EndIf

	RestArea(aAreaDXM)
	RestArea(aArea)

Return(lRet)

/** ------------------------------------------------------------------------------------------
{Protheus.doc} A602Imprime
Imprime relatório com todos os romaneios que necessitam de NF complementar, quebrando por produtor

@param: Nil
@author: Marlon Richard Trettin
@since: 27/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function A602Imprime()

	Local aOrd := {}
	Local cTitulo := STR0005

	Private cDesc1	 := cTitulo
	Private cDesc2	 := ""
	Private cDesc3	 := ""
	Private nLin         := 80
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private limite       := 130
	Private tamanho      := "M"
	Private nomeprog     := "AGRA602" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "AGRA602" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cAlias	   := "DXM"

	dbSelectArea("DXM")
	dbSetOrder(1)

	// Seleciona Impressao
	NLASTKEY := 0

	cProg := SetPrint(cAlias,nomeprog,"",cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,,Tamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cAlias)

	nTipo := If(aReturn[4]==1,15,18)

	// Processamento. RPTSTATUS monta janela com a regua de processamento
	RptStatus( {|| RunReport( cTitulo, nLin ) }, cTitulo )

Return NIL

/** ------------------------------------------------------------------------------------------
{Protheus.doc} RunReport
Funcao auxiliar chamada pela RPTSTATUS

@param: Nil
@author: Marlon Richard Trettin
@since: 27/07/14
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function RunReport( cTitulo, nLin )

	Local nX := 0, nY := 0
	Local Cabec1 := ""
	Local Cabec2 := ""
	Local cLblPrdtor := TitSX3( "DXM_PRDTOR" )[1]

	Private aDXMdetalhe := {}

	Cabec2 := PadR( AllTrim( TitSX3( "DXM_CODIGO" )[1] ), 12, "." )+" "+;
	PadR( AllTrim( TitSX3( "DXM_DTEMIS" )[1] ), 12, "." )+" "+;
	PadR( AllTrim( TitSX3( "DXM_NOTA"   )[1] ), 12, "." )+" "+;
	PadR( AllTrim( TitSX3( "DXM_SERIE"  )[1] ), 12, "." )+"  "+;
	PadR( AllTrim( TitSX3( "DXM_PSFISC" )[1] ), 13, "." )+"  "+;
	PadR( AllTrim( TitSX3( "DXM_PSLIQU" )[1] ), 13, "." )+"  "+;
	PadR( AllTrim( STR0008 /*"Diferença"*/   ), 13, "." )

	//    0         1         2         3         4         5         6         7         8         9         10        11        12        13        14        15        16        17        18        19        20        21                  
	//    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
	//Cabec2 := "Codigo...... Dt.Emissao.. NF Entrada.. Serie NFE...  Ps. Fiscal...  Peso Liquido.  Diferenca...."
	//Cabec2 := "123456       dd/mm/aaaa   123456789    123           99,999,999.99  99,999,999.99  99,999,999.99"

	SetRegua(Len(aDXMagrup))

	For nX := 1 to Len( aDXMagrup )

		IncRegua()

		// Carrega detalhes dos romaneios no array aDXMdetalhe
		QryDXMdetalhe( aDXMagrup[ nX, A_DXM_PRDTOR ], aDXMagrup[ nX, A_DXM_LJPRO ] )

		// Define o cabecalho
		Cabec1 := cLblPrdtor + " : " + aDXMagrup[ nX, A_DXM_PRDTOR ] + " " + aDXMagrup[ nX, A_DXM_LJPRO ] + " - " + aDXMagrup[ nX, A_DXM_NMPDTR ]

		// Quebra a página
		Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 9

		For nY := 1 to Len( aDXMdetalhe )

			If nLin > 65
				Cabec(cTitulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
			Endif

			@ nlin,000 	      Psay PadR( aDXMdetalhe[ nY, A_DXMD_CODIGO ], 12 )
			@ nLin , pCol()+1   PSay PadR( DtoC( aDXMdetalhe[ nY, A_DXMD_DTEMIS ] ), 12 )
			@ nLin , pCol()+1   PSay PadR( aDXMdetalhe[ nY, A_DXMD_NOTA  ], 12 )
			@ nLin , pCol()+1   PSay PadR( aDXMdetalhe[ nY, A_DXMD_SERIE ], 12 )
			@ nLin , pCol()+2   PSay Transform( aDXMdetalhe[ nY, A_DXMD_PSFISC ], PesqPict( "DXM", "DXM_PSFISC" ) )
			@ nLin , pCol()+2   PSay Transform( aDXMdetalhe[ nY, A_DXMD_PSLIQU ], PesqPict( "DXM", "DXM_PSLIQU" ) )
			@ nLin , pCol()+2   PSay Transform( aDXMdetalhe[ nY, A_COLD_DIFERENCA ], PesqPict( "DXM", "DXM_PSFISC" ) )

			nLin ++
		Next nY

		@ nlin,000 	      Psay Space(12)
		@ nLin , pCol()+1   PSay Space(12)
		@ nLin , pCol()+1   PSay Space(12)
		@ nLin , pCol()+1   PSay Space(12)
		@ nLin , pCol()+2   PSay Replicate("-",13)
		@ nLin , pCol()+2   PSay Replicate("-",13)
		@ nLin , pCol()+2   PSay Replicate("-",13)
		nLin ++
		@ nlin,000 	      Psay Space(12)
		@ nLin , pCol()+1   PSay Space(12)
		@ nLin , pCol()+1   PSay Space(12)
		@ nLin , pCol()+1   PSay Space(12)
		@ nLin , pCol()+2   PSay Transform( aDXMagrup[ nX, A_DXM_PSFISC ], PesqPict( "DXM", "DXM_PSFISC" ) )
		@ nLin , pCol()+2   PSay Transform( aDXMagrup[ nX, A_DXM_PSLIQU ], PesqPict( "DXM", "DXM_PSLIQU" ) )
		@ nLin , pCol()+2   PSay Transform( aDXMagrup[ nX, A_COL_DIFERENCA ], PesqPict( "DXM", "DXM_PSFISC" ) )

	Next nX

	If aReturn[5] = 1
		Set Printer To
		dbCommitall()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return NIL

/** ------------------------------------------------------------------------------------------
{Protheus.doc} CriaTmpTbl
Cria tabela temporaria para browse

@param:  Nil
@author: Carlos Augusto Pereira
@since:  23/05/2017
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function CriaTmpTbl(aColumns, cAliasTRB, pcPrdtor, pcLjPro)
	Local aCampos 	:= {'DXM_CODIGO','DXM_DTEMIS','DXM_NOTA' , "DXM_SERIE", "DXM_PSFISC", "DXM_PSLIQU",/*Dif*/ "DXM_DIF", "DXM_NFCOMP", "DXM_SRCOMP" }
	Local aCampIni2 := {}
	Local aIndices 	:= {}
	Local nX 		:= 0
	Local aCpSX3	:= {}
	

	//Limpando temp Table
	If __oArqTemp <> Nil
		AGRDLTPTB(@__oArqTemp, NIL, .T.)
	EndIf

	//Defini as colunas na temp table		 
	AADD(aCampIni2,{"DXM_OK", "C",2,0,  "OK", "@!"})

	//Definindo as colunas do Browse	
	For nX := 1 To Len(aCampos)
		aCpSX3 := {}
		aCpSX3 := FWSX3Util():GetFieldStruct( aCampos[nX] )
		If Len(aCpSX3) > 0 .AND. Alltrim(aCpSX3[1]) == Alltrim(aCampos[nX])
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aCampos[ nX ]+"}") )
			aColumns[Len(aColumns)]:SetTitle( AllTrim(FWX3Titulo(aCampos[nX])) )
			aColumns[Len(aColumns)]:SetSize( aCpSX3[3] )
			aColumns[Len(aColumns)]:SetDecimal( aCpSX3[4] )
			aColumns[Len(aColumns)]:SetPicture( PesqPict("DXM",aCampos[nX]) )
			aColumns[Len(aColumns)]:SetAlign( 0 )//Define alinhamento

			AADD(aCampIni2,{aCampos[nX], aCpSX3[2], aCpSX3[3], aCpSX3[4],  AllTrim(FWX3Titulo(aCampos[nX])), PesqPict("DXM",aCampos[nX])})
		
		ElseIf aCampos[nX] == "DXM_DIF"
			aCpSX3 := FWSX3Util():GetFieldStruct( "DXM_PSLIQU" )
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||"+aCampos[ nX ]+"}"))
			aColumns[Len(aColumns)]:SetTitle(STR0008)
			aColumns[Len(aColumns)]:SetSize( aCpSX3[3] )
			aColumns[Len(aColumns)]:SetDecimal( aCpSX3[4] )
			aColumns[Len(aColumns)]:SetPicture(PesqPict("DXM",aCpSX3[1]) )
			aColumns[Len(aColumns)]:SetAlign( 0 )//Define alinhamento 

			AADD(aCampIni2,{ aCampos[nX], aCpSX3[2], aCpSX3[3], aCpSX3[4],  STR0008 /*Diferenca*/, PesqPict("DXM",aCpSX3[1]) })		
		
		EndIf
	Next nX

    aAdd(aIndices, {"", "DXM_CODIGO" })
    
    __oArqTemp  := AGRCRTPTB(cAliasTRB, {aCampIni2, aIndices })	

    cAliasTRB   := NFCompDado( pcPrdtor, pcLjPro, @cAliasTRB )
    
Return cAliasTRB



/** ------------------------------------------------------------------------------------------
{Protheus.doc} AGR602Conf
Atualiza romaneio de entrada com nota e serie complementares

@param:  Nil
@author: Carlos Augusto Pereira
@since:  23/05/2017
@Uso: AGRA602
------------------------------------------------------------------------------------------ **/
Static Function AGR602Conf(cAliasTRB, oBrowseRom)

	dbSelectArea(cAliasTRB)
	dbGoTop()
	While .Not. Eof()
		If oBrowseRom:IsMark()
			dbSelectArea("DXM")
			dbSetOrder(1)
			If MSSeek(FWxFilial("DXM")+(cAliasTRB)->DXM_CODIGO)
				If .Not. Empty((cAliasTRB)->DXM_NFCOMP)
					RecLock( "DXM", .F. )
					DXM->( DXM_NFCOMP ) := (cAliasTRB)->DXM_NFCOMP
					DXM->( DXM_SRCOMP ) := (cAliasTRB)->DXM_SRCOMP
					MsUnLock( "DXM" )
				EndIf
			EndIf
		EndIf
		dbSelectArea(cAliasTRB)
		DbSkip()
	EndDo	

Return .T.
