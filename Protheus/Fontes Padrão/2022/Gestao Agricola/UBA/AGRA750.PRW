#include "AGRA750.CH"
#include "PROTHEUS.CH"
#include "FWMVCDEF.CH"

/** -------------------------------------------------------------------------------------
{Protheus.doc}
Romaneio de Saida

@param: 	Nil
@author: 	Ricardo Tomasi
@since: 	11/09/2012 
@Uso: 		UBA
------------------------------------------------------------------------------------- **/
Function AGRA750()
	Local bKeyF12 	  := { || aPerBal := AGRX003E( .T., "AGRA750001" ) }
	Local oBrowse 	  := Nil

	//Vários Romaneios usam a mesma carga
	Private nPesMulti := 0

	//Pesagem não é autorizada
	Private aPerBal	  := nil
	Private aFardos	  := {}
	Private aFdDisp	  := {}
	Private aRateio	  := {}
	Private nTotPsLiq := 0

	Static lModified  := .F.

	If aPerBal == Nil
		aPerBal := AGRX003E( .F., "AGRA750001" )
	Endif

	// Seta acao para tecla F12
	SetKey( VK_F12, bKeyF12 )

	// Instancia o Browser
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "DXS" )
	oBrowse:SetDescription( STR0001 ) //"Romaneios de Saída"
	oBrowse:DisableDetails()

	// Adiciona Legendas no Browser
	oBrowse:AddLegend( " DXS_STATUS == '1'" , "GREEN"	, Alltrim(AGRTxtBox('1','DXS_STATUS') )	)
	oBrowse:AddLegend( " DXS_STATUS == '2'" , "YELLOW"  , Alltrim(AGRTxtBox('2','DXS_STATUS') )	)
	oBrowse:AddLegend( " DXS_STATUS == '3'" , "RED"  	, Alltrim(AGRTxtBox('3','DXS_STATUS') )	)
	oBrowse:AddLegend( " DXS_STATUS == '4'" , "BLACK"  	, Alltrim(AGRTxtBox('4','DXS_STATUS') )	)

	// Ativa o Browser
	oBrowse:Activate()

	// Retira acao da tecla F12
	SetKey( VK_F12, Nil )
Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de dados para a rotina

@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruDXS 	:= FwFormStruct( 1, "DXS" )
	Local oStruDXT 	:= FwFormStruct( 1, "DXT" )

	// Instacia o modelo de dados
	oModel := MPFormModel():New( "AGRA750", , { |oMdl| PosModelo( oMdl ) } ,  { |oMdl| GrvModelo( oMdl ) }, { | oMdl | CanModelo( oMdl ) } )
	oModel:SetDescription( STR0002 ) //"Modelo de Dados dos Romaneios de Saida"

	oStruDXS:SetProperty( "DXS_NUMPED", MODEL_FIELD_VALID  , {|oFields| AGRA750NFS(oFields) } )
	oStruDXS:SetProperty( "DXS_TICKET", MODEL_FIELD_VALID  , {|| Vazio() .Or.  AGRA750CPO() } )

	// Adiciona a estrutura dos campos da field no modelo de dados
	oModel:AddFields( "MDFIELDDXS", , oStruDXS )
	oModel:GetModel( "MDFIELDDXS" ):SetDescription( STR0003 ) //"Cabeçalho do Romaneio"

	// Adiciona a estrutura dos camnpos da grid no modelo de dados
	oModel:AddGrid( "MDGRIDDXT", "MDFIELDDXS", oStruDXT, {|oMdGridDXT, nLine, cAction, cField, xValueNew, xValueOld| PreLinha(oMdGridDXT, nLine, cAction, cField, xValueNew, xValueOld ) } )
	oModel:SetRelation( "MDGRIDDXT", { { "DXT_FILIAL", "xFilial('DXT')" }, { "DXT_CODIGO", "DXS_CODIGO" } }, DXT->( IndexKey( 1 ) ) )
	oModel:GetModel( "MDGRIDDXT" ):SetDescription( STR0004 ) //"Itens do Romaneio"

	// Cria os campos de totalizadores da grid
	oModel:AddCalc( 'AGRA750CALC', "MDFIELDDXS", "MDGRIDDXT", 'DXT_QUANT'	, 'TOTQTD'	, 'SUM', { || .T. },, STR0005 ) //"Quantidade Total"
	oModel:AddCalc( 'AGRA750CALC', "MDFIELDDXS", "MDGRIDDXT", 'DXT_PSBRUT'	, 'TOTPSB'	, 'SUM', { || .T. },, STR0006 ) //"Peso Bruto Total"
	oModel:AddCalc( 'AGRA750CALC', "MDFIELDDXS", "MDGRIDDXT", 'DXT_PSLIQU'	, 'TOTPSL'	, 'SUM', { || .T. },, STR0007 ) //"Peso Líquido Total"
	oModel:AddCalc( 'AGRA750CALC', "MDFIELDDXS", "MDGRIDDXT", 'DXT_PSRAT'	, 'TOTDIF'	, 'SUM', { || .T. },, STR0008 ) //"Total de Dif. de Peso"
	oModel:AddCalc( 'AGRA750CALC', "MDFIELDDXS", "MDGRIDDXT", 'DXT_PSFISC'	, 'TOTPSF'	, 'SUM', { || .T. },, STR0009 ) //"Peso Fiscal Total"

	// Validação de linha duplicada
	oModel:GetModel( "MDGRIDDXT" ):SetUniqueLine( { 'DXT_NUMIE', 'DXT_ITEMIE' } )

	// Seta preenchimento opicional da Grid
	oModel:GetModel( "MDGRIDDXT" ):SetOptional( .T. )

	// Validação da ativação do model
	oModel:SetVldActivate( { |oModel| A750VLDACT( oModel ) } )

	//------------------------------------
	// Validação após Ativar do model
	//------------------------------------
	oModel:SetActivate( { | oModel | A750ACTIVE(oModel) } )
Return(oModel)

/** -------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna a View (tela) da rotina

@param: 	Nil
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA750" )
	Local oStruDXS 	:= FwFormStruct( 2, "DXS" )
	Local oStruDXT 	:= FwFormStruct( 2, "DXT", {|cCampo| !(AllTRim(cCampo) $ "DXT_SAFRA" )} )

	// Remove campos da estrutura
	oStruDXS:RemoveField( "DXS_STATUS" )
	oStruDXT:RemoveField( "DXT_CODIGO" )

	oStruDXS:SetProperty("DXS_MODPS1" ,MVC_VIEW_ORDEM,'14')
	oStruDXS:SetProperty("DXS_MODPS2" ,MVC_VIEW_ORDEM,'17')


	If IsinCallStack("AGRA750M")
		oStruDXS:SetProperty( "DXS_NUMPED", MVC_VIEW_CANCHANGE  , .t. )
	Endif

	// Instancia a View
	oView := FwFormView():New()
	oView:SetModel( oModel )

	// Instancia o objeto de calculo
	oCalc := FWCalcStruct( oModel:GetModel( 'AGRA750CALC') )

	// Adiciona a estrutura ao modelo
	oView:AddField( "VIEW_DXS", oStruDXS, "MDFIELDDXS" )
	oView:AddGrid( "VIEW_DXT", oStruDXT, "MDGRIDDXT" )
	oView:AddField( 'VIEW_CALC', oCalc, 'AGRA750CALC' )

	// Cria Box
	oView:CreateHorizontalBox( "SUP", 40 )
	oView:CreateHorizontalBox( "MED", 50 )
	oView:CreateHorizontalBox( "INF", 10 )

	// Seta o Owner da View
	oView:SetOwnerView( "VIEW_DXS", "SUP" )
	oView:SetOwnerView( "VIEW_DXT", "MED" )
	oView:SetOwnerView( "VIEW_CALC", "INF" )

	// Adiciona os botoes na tela
	oView:AddUserButton( STR0010, 'CLIPS', {|x| Pesagem( x ) } ) //'Pesagem'

	oView:AddUserButton( STR0011, 'CLIPS', {|x| IncFardos( x ) } ) //'Selecionar Fardos'

	// Define o campo incremental
	oView:AddIncrementField( 'VIEW_DXT', 'DXT_ITEM' )

Return(oView)

/** -------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 11/09/2012
@Uso: AGRA750
------------------------------------------------------------------------------------- **/
Static Function MenuDef()
	Local aRotina := {}    

	aAdd( aRotina, { STR0012 , "PesqBrw"			, 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0014 , "ViewDef.AGRA750"	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0015 , "ViewDef.AGRA750"	, 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0016 , "ViewDef.AGRA750"	, 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0017 , "AGRA750P()"			, 0, 4, 0, Nil } ) //"Prep.Doc.Sai."
	aAdd( aRotina, { STR0018 , "AGRA750C()"			, 0, 4, 0, Nil } ) //"Cancela"
	aAdd( aRotina, { STR0019 , "AGRAR750"			, 0, 8, 0, Nil } ) //"Imprimir"
	aAdd( aRotina, { STR0097 , "AGRAR760"			, 0, 8, 0, Nil } ) //"Imprimir Ticket de Pesagem"

	If ExistBlock('AGR750BW')
		aRet := ExecBlock('AGR750BW',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf

Return(aRotina)

/** -------------------------------------------------------------------------------------
{Protheus.doc} A750VLDACT
Validação da ativação do model

@param: 	oModel - Modelo de dados da rotina
@author: 	Aecio Ferreira Gomes
@since: 	20/11/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function A750VLDACT(oModel)
	Local aArea		:= GetArea()
	Local lRet		:= .T.

	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		//Função que valida os documentos de saida e pedido de venda, caso os mesmos tenham sido excluidos nas suas respectivas rotinas
		BuscaDocSaida()
		
		DO CASE
			// Preparação do documento fiscal
		CASE IsIncallStack("AGRA750P")
			If DXS->DXS_STATUS == "3"  // Status "3" = Encerrado
				lRet := .F.
				Help("",1,STR0020,,STR0021+Alltrim(AGRTxtBox('3','DXS_STATUS'))+STR0022,1) //"ATENÇÃO"###"Este romaneio está "###" ! "
			ElseIf DXS->DXS_STATUS == "4" // Status "4" = Cancelado
				lRet := .F.
				Help("",1,STR0020,,STR0023+Alltrim(AGRTxtBox('4','DXS_STATUS'))+STR0024,1) //"ATENÇÃO"###"Este romaneio foi "###" !"
			EndIf
			// Cancelamento	
		CASE IsIncallStack("AGRA750C")
			If DXS->DXS_STATUS == "4" // Status "4" = Cancelado
				lRet := .F.
				Help("",1,STR0020,,STR0021+Alltrim(AGRTxtBox('4','DXS_STATUS'))+ STR0024 ,1) //"ATENÇÃO"###"Este romaneio está "###" !"
			EndIf

		OTHERWISE
			If DXS->DXS_STATUS $ "2|3|4" // Status "2|3|4" = Em pedido de venda, Encerrado ou Cancelado
				lRet := .F.
				Help("",1,STR0020,,STR0021+Alltrim(AGRTxtBox(DXS->DXS_STATUS,'DXS_STATUS'))+STR0025 ,1) //"ATENÇÃO"###"Este romaneio está "###" Por este motivo não pode sofrer alterações!"
			EndIf
		ENDCASE
	EndIf

	RestArea(aArea)	
Return(lRet)

/**-------------------------------------------------------------------
{Protheus.doc} PreLinha
Pré validação da Grid

@author Aécio Ferreira Gomes
@since 24/04/2013
@version 1.0
-------------------------------------------------------------------**/
Static Function PreLinha(oMdGridDXT, nLine, cAction, cField, xValueNew, xValueOld)
	Local lRet  := .T.

	Do Case
	Case cAction == "DELETE"
		If (oMdGridDXT:GetValue("DXT_QUANT") > 0)
			lRet := .F.
			Help("",1,STR0020,, STR0098,1,0) //'Atenção'###"Instrução de embarque não pode ser deletada, pois há fardos selecionados."
		Endif
	ENDCASE
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} Pesagem
Rotina de pesagem (integracao com a balança)

@param: 	oView - Modelo de visualização da rotina
@return:	.T. ou .F.
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Function Pesagem( oView )
	Local oModel	 := FwModelActive()
	Local oMdlDXS	 := oModel:GetModel( "MDFIELDDXS" )
	Local oDlg 		 := Nil
	Local oCombo	 := Nil
	Local cCombo	 := ""
	Local lRet		 := .T.
	Local lPeso1  	 := FwFldGet( "DXS_PESO1" ) == 0
	Local lPeso2  	 := FwFldGet( "DXS_PESO2" ) == 0
	Local lPeso3  	 := FwFldGet( "DXS_PESO1" ) > 0 .And. FwFldGet( "DXS_PESO2" ) > 0
	Local nItem		 := 1
	Local nPeso		 := 0
	Local lPesagManu := .F.
	// Variaveis de descontos da carga
	// Se estiver preenchido o ticket de pesagem não faz a pesagem pelo o romaneio de saida.
	If !Empty(oMdlDXS:GetValue("DXS_TICKET"))
		lRet := .F. 
	EndIf

	If lRet
		lRet := INCLUI .Or. ALTERA .And. !aPerBal[ 4 ] // Se for operação de inclusao ou alteracao e o usuario tiver permição para pesagem
	EndIf

	If lRet
		If lPeso3 //Ja possui as duas pesagens
			oDlg 	:= TDialog():New(0,0,24,300,'',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
			oCombo 	:= TComboBox():New( 001, 001, { |u| If( PCount() > 0, cCombo := u, cCombo ) }, {STR0028, STR0029}, 100, 020, oDlg, , { || nItem := oCombo:nAt }, , , , .t., , , , , , , , , 'cCombo' ) //"Primeira Pesagem"###"Segunda Pesagem"
			oTButt 	:= TButton():New( 001, 104, STR0030, oDlg, { || oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Confirma"
			oDlg:Activate( , , , .t., { | | .T. }, , { || } )

			If nItem = 1
				lPeso1 := .t.
				lPeso2 := .f.
			ElseIf nItem = 2
				lPeso1 := .f.
				lPeso2 := .t.
			EndIf
		EndIf

		If lPeso1 //Primeira Pesagem
			// Apresenta tela de pesagem
			AGRX003A( @nPeso, , aPerBal, , @lPesagManu )
			oMdlDXS:SetValue( "DXS_PESO1" , nPeso )
			oMdlDXS:SetValue( "DXS_DATPS1", dDataBase )
			oMdlDXS:SetValue( "DXS_HORPS1", Substr( Time(), 1, 5 ) )
			oMdlDXS:SetValue( "DXS_MODPS1", IIf( lPesagManu, "M", "A" ) )
		Else
			If lPeso2 //Segunda Pesagem
				// Apresenta tela de pesagem
				AGRX003A( @nPeso, , aPerBal, , @lPesagManu )
				oMdlDXS:SetValue( "DXS_PESO2" , nPeso )
				oMdlDXS:SetValue( "DXS_DATPS2", dDataBase )
				oMdlDXS:SetValue( "DXS_HORPS2", Substr( Time(), 1, 5 ) )
				oMdlDXS:SetValue( "DXS_MODPS2", IIf( lPesagManu, "M", "A" ) )
			EndIf
		EndIf

		oView:SetModified()
		// Atualiza o peso líquido da carga
		If FwFldGet("DXS_PESO2") > FwFldGet("DXS_PESO1")
			FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO2") - FwFldGet("DXS_PESO1")  ) )
		Else
			FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO1") - FwFldGet("DXS_PESO2") ) )
		EndIf

		FwFldPut( "DXS_PSBASE", ( FwFldGet("DXS_PSSUBT") - FwFldGet("DXS_PSDESC") ) )
		FwFldPut( "DXS_PSLIQU", ( ( FwFldGet("DXS_PSSUBT") - FwFldGet("DXS_PSDESC") ) - FwFldGet("DXS_PSEXTR") ) )		
	EndIf
Return(.T.)

/** -------------------------------------------------------------------------------------
{Protheus.doc} IncFardos
Rotina para validaçao antes de iniciar o modelo de dados

@param:		oView - Modelo de visualização da rotina
@return:	.t. ou .f.	Verdadeiro (.t.) se deve carregar o modelo
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function IncFardos( oView )
	Local oModel	:= FwModelActive()
	Local oMdlDXT	:= Nil
	Local cCodRom	:= ""
	Local cIteRom	:= ""
	Local cCodIE	:= ""
	Local cCodTip	:= ""
	Local cCodBlq	:= ""

	If INCLUI .Or. ALTERA

		oFldDXS	:= oModel:GetModel("MDFIELDDXS")
		oMdlDXT	:= oModel:GetModel("MDGRIDDXT")

		cCodRom := oFldDXS:GetValue("DXS_CODIGO")
		cIteRom := oMdlDXT:GetValue("DXT_ITEM")
		cCodIE 	:= oMdlDXT:GetValue("DXT_NUMIE")
		cIteIE 	:= oMdlDXT:GetValue("DXT_ITEMIE")
		cCodTip := oMdlDXT:GetValue("DXT_TIPO")
		cCodBlq := oMdlDXT:GetValue("DXT_BLOCO")

		If !Empty( cCodTip ) .And. !Empty( cCodBlq ) .And. !Empty( cCodIE )
			CarFardos(oModel, cCodRom, cIteRom, cCodIE, cIteIE )
			SelFardos( )
		Else
			Help( , , STR0026, , STR0031, 1, 0) //"Selecione um bloco para depois selecionar os fardos!!!"
		EndIf
	EndIf
Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} CarFardos
Rotina para validaçao antes de iniciar o modelo de dados

@param: 	cRomaneio - Numero do romaneio
@param: 	cItemR - Item do romaneio
@param: 	cNumIE - Numero da instrução de embarque
@param: 	cItemIE - Item da instrução de embarque
@return:	.T. ou .F.
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function CarFardos(oModel, cRomaneio, cItemR, cNumIE, cItemIE )
	Local oMdGridDXT:= oModel:GetModel('MDGRIDDXT')
	Local aVincul	:= {}
	Local aLivres	:= {}
	Local lReserv	:= .F.
	Local nX		:= 0
	Local cBloco    := oMdGridDXT:GetValue('DXT_BLOCO')

	//aFardos := {}
	// Valida se o item ja existe no array
	If ASCAN(aFardos, {|x| x[1] == cItemR}) == 0
		BeginSql Alias "QryDXI"
			Select
			DXI.*
			From
			%table:DXI% DXI
			Where
			DXI.DXI_FILIAL = %xFilial:DXI%   AND
			DXI.DXI_ROMSAI = %exp:cRomaneio% AND
			DXI.DXI_ITROMS = %exp:cItemR%    AND
			DXI.DXI_BLOCO  = %exp:cBloco%    AND
			DXI.%NotDel%
			Order By
			DXI.DXI_ETIQ
		EndSql

		QryDXI->( dbGotop() )
		While !QryDXI->( Eof() )
			aAdd( aVincul, { "2", QryDXI->( DXI_ETIQ ), QryDXI->( DXI_CODIGO ), QryDXI->( DXI_PSBRUT ), QryDXI->( DXI_PSLIQU ) } )
			QryDXI->( dbSkip() )
		End
		QryDXI->( dbCloseArea( ) )

		If Len( aVincul ) > 0
			aAdd( aFardos, { cItemR, aClone(aVincul) } )
		EndIf

	EndIf

	// Valida se o item já existe no array
	If ASCAN(aFdDisp, {|x| x[1] == cItemR}) == 0
		
		BeginSql Alias "ALIASQRY"
			SELECT
			DXI.*, DXO.*
			FROM
			%table:DXI% DXI, %table:DXO% DXO
			WHERE
			DXI.DXI_FILIAL = %xFilial:DXI%  AND
			DXO.DXO_FILIAL = %xFilial:DXO%  AND
			DXI.DXI_ROMSAI = %exp:space(1)% AND
			DXI.DXI_ITROMS = %exp:space(1)% AND
			DXI.DXI_CODRES = DXO_CODRES     AND
			DXI.DXI_ITERES = DXO_ITEMRS     AND
			DXI.DXI_BLOCO  = %exp:cBloco%   AND
			DXO.DXO_NUMIE  = %exp:cNumIE%   AND
			DXO.DXO_ITEM   = %exp:cItemIE%  AND
			DXO.%NotDel%                    AND
			DXI.%NotDel%				
			ORDER BY 
			DXI.DXI_ETIQ		
		EndSql
		ALIASQRY->(dbGotop())
		While ALIASQRY->( !Eof() )
			For nX := 1 To Len(aFardos)
				aAux := aClone(aFardos[nX,2])

				If aScan(aAux, {|x| x[2] == ALIASQRY->DXI_ETIQ } ) > 0
					lReserv := .T. // Indica que o fardo já pertence ao romaneio
					Exit
				EndIf
			Next nX

			If lReserv
				lReserv := .F.
				ALIASQRY->( dbSkip() )
				Loop
			EndIf

			aAdd( aLivres, { "2", ALIASQRY->( DXI_ETIQ ), ALIASQRY->( DXI_CODIGO ), ALIASQRY->( DXI_PSBRUT ), ALIASQRY->( DXI_PSLIQU ) } )
			ALIASQRY->( dbSkip() )
		End
		ALIASQRY->( dbCloseArea() )

		If Len( aLivres ) > 0
			aAdd( aFdDisp, { cItemR, aClone(aLivres) } )
		Else
			aAdd( aFdDisp, { cItemR, {} } ) //todos os fardinhos podem estar vinculos
		EndIf

	EndIF
	
Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} SelFardos
Rotina de seleção de fardos para o romaneio

@return:	nQtdSel - Quantidade de fardos selecionados
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function SelFardos()
	Local oView		:= FwViewActive()
	Local oModel	:= FwModelActive()
	Local oMdlDXT	:= oModel:GetModel("MDGRIDDXT")
	Local oDlg		:= Nil
	Local oFwLayer	:= Nil
	Local oPnEsq 	:= Nil
	Local oPnCnt 	:= Nil
	Local oPnDir 	:= Nil
	Local oBrwEsq	:= Nil
	Local oBrwDir	:= Nil
	Local oOK	   	:= LoadBitmap(GetResources(),'LBOK')
	Local oNo     	:= LoadBitmap(GetResources(),'LBNO')
	Local aCords	:= FWGetDialogSize( oMainWnd )
	Local aSaveLines:= FWSaveRows()
	Local cNumIE	:= oMdlDXT:GetValue("DXT_NUMIE")
	Local cItemIE	:= oMdlDXT:GetValue("DXT_ITEMIE")
	Local cItemR	:= oMdlDXT:GetValue("DXT_ITEM")
	Local nOpcX		:= 0
	Local nQtdSel	:= 0
	Local nPos		:= 0

	Private aItsEsq	:= {}
	Private aItsDir	:= {}
	Private cItemRom := oMdlDXT:GetValue("DXT_ITEM")

	Static lMarcAllD := .T.
	Static lMarcAllE := .T.

	If (nPos := ASCAN(aFdDisp, {|x| x[1] == cItemR })) > 0
		aItsEsq	:= aClone( aFdDisp[ nPos, 2] )
	EndIf

	If (nPos := ASCAN(aFardos, {|x| x[1] == cItemR })) > 0
		aItsDir	:= aClone( aFardos[ nPos, 2] )
	EndIf

	nQtdSel	:= Len( aItsDir )

	//- Coordenadas da area total da Dialog
	oSize:= FWDefSize():New(.T.)
	oSize:AddObject("DLG",100,100,.T.,.T.)    
	oSize:SetWindowSize(aCords)
	oSize:lProp 	:= .T.      
	oSize:aMargins := {0,0,0,0}      
	oSize:Process()

	// Instancia o objeto TDIALOG
	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0032, , , ,;
	, CLR_BLACK, CLR_WHITE, , , .t. ) //"Seleção de Fardos"

	// Cria Panel 
	oPnl:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3])

	// Instancia o objeto FWLAYER
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oPnl, .F., .T. )

	oFWLayer:AddLine( "SUP", 10, .T. )
	oFWLayer:AddLine( "INF", 70, .F. )

	oFWLayer:AddCollumn( "UNI" , 100, .F., "SUP" )
	oFWLayer:AddCollumn( "ESQ" ,  45, .F., "INF" )
	oFWLayer:AddCollumn( "CNT" ,  10, .F., "INF" )
	oFWLayer:AddCollumn( "DIR" ,  45, .F., "INF" )

	oFWLayer:AddWindow( "UNI" , "PSP", STR0033 	, 100, .F., .T., {||}, "SUP" ) //"Intrução de Embarque"
	oFWLayer:AddWindow( "ESQ" , "PNE", STR0066 	, 100, .F., .T., {||}, "INF" ) //"Fardos Livres"
	oFWLayer:AddWindow( "CNT" , "PNC", STR0035 	, 100, .F., .T., {||}, "INF" ) //"Ações"
	oFWLayer:AddWindow( "DIR" , "PND", STR0036	, 100, .F., .T., {||}, "INF" ) //"Fardos Romaneio"

	oPnSup := oFWLayer:GetWinPanel( "UNI", "PSP", "SUP" )
	oPnEsq := oFWLayer:GetWinPanel( "ESQ", "PNE", "INF" )
	oPnCnt := oFWLayer:GetWinPanel( "CNT", "PNC", "INF" )
	oPnDir := oFWLayer:GetWinPanel( "DIR", "PND", "INF" )

	oSizeSU := FwDefSize():New()
	oSizeSU:AddObject( "PE0", 100, 100, .t., .t. )    
	oSizeSU:SetWindowSize( { 0, 0, oPnSup:nHeight, oPnSup:nWidth } )
	oSizeSU:lProp 	 := .t.
	oSizeSU:aMargins := { 0, 0, 0, 0 }      
	oSizeSU:Process()

	tSay():New( oSizeSU:aPosObj[1,1]+10, oSizeSU:aPosObj[1,2]+10, {|| STR0037 } , oPnSup, , , , , , .t., CLR_BLACK, CLR_WHITE, 040, 9 ) //"Nº Instrução"
	tGet():New( oSizeSU:aPosObj[1,1]+10, oSizeSU:aPosObj[1,2]+45, {|| cNumIE } , oPnSup, 40, 9, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F.,, cNumIE,,,, )
	tSay():New( oSizeSU:aPosObj[1,1]+10, oSizeSU:aPosObj[1,2]+90, {|| STR0038 } , oPnSup, , , , , , .t., CLR_BLACK, CLR_WHITE, 020, 9 ) //"Item"
	tGet():New( oSizeSU:aPosObj[1,1]+10, oSizeSU:aPosObj[1,2]+115, {|| cItemIE } , oPnSup, 12, 9, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.t.,.F.,, cItemIE,,,, )

	oSizeE0 := FwDefSize():New()
	oSizeE0:AddObject( "PE0", 100, 100, .t., .t. )    
	oSizeE0:SetWindowSize( { 0, 0, oPnEsq:nHeight, oPnEsq:nWidth } )
	oSizeE0:lProp 	:= .t.
	oSizeE0:aMargins := { 0, 0, 0, 0 }      
	oSizeE0:Process()

	oBrwEsq := TCBrowse():New( oSizeE0:aPosObj[1,1], oSizeE0:aPosObj[1,2], oSizeE0:aPosObj[1,3], oSizeE0:aPosObj[1,4], , , , oPnEsq, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
	oBrwEsq:AddColumn( TCColumn():New(""     , { || IIf( aItsEsq[oBrwEsq:nAt,01] == "1", oOK, oNO ) },,,,"CENTER",,.t.,.t.,,,,.f., ) )
	oBrwEsq:AddColumn( TCColumn():New(STR0039, { || aItsEsq[oBrwEsq:nAt,02] }									, , , , "LEFT" 	, 100, .f., .t., , , , .f., ) ) //"Etiqueta"
	oBrwEsq:AddColumn( TCColumn():New(STR0040, { || aItsEsq[oBrwEsq:nAt,03] }									, , , , "LEFT" 	, 050, .f., .t., , , , .f., ) ) //"Fardo"
	oBrwEsq:AddColumn( TCColumn():New(STR0041, { || Transform( aItsEsq[oBrwEsq:nAt,04], "@E 999,999,999.99" ) }	, , , , "RIGHT"	, 050, .f., .t., , , , .f., ) ) //"Peso Liquido"
	oBrwEsq:AddColumn( TCColumn():New(STR0042, { || Transform( aItsEsq[oBrwEsq:nAt,05], "@E 999,999,999.99" ) }	, , , , "RIGHT"	, 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
	oBrwEsq:AddColumn( TCColumn():New(""	 , { || "" }														, , , , "LEFT"	, 001, .f., .t., , , , .f., ) )
	oBrwEsq:SetArray( aItsEsq )
	oBrwEsq:bLDblClick 		:= {|| MarcaUm( oBrwEsq, aItsEsq)}
	oBrwEsq:bHeaderClick 	:= {|| MarcaTudo( oBrwEsq, aItsEsq, @lMarcAllE ) }
	oBrwEsq:Align := CONTROL_ALIGN_ALLCLIENT

	oSizeC0 := FwDefSize():New()
	oSizeC0:AddObject( "PC0", 100, 100, .t., .t. )    
	oSizeC0:SetWindowSize( { 0, 0, oPnCnt:nHeight, oPnCnt:nWidth } )
	oSizeC0:lProp 	 := .t.
	oSizeC0:aMargins := { 0, 3, 0, 3 }
	oSizeC0:Process()

	tButton():New( oSizeC0:aPosObj[1,1]+10, oSizeC0:aPosObj[1,2], ">>" , oPnCnt, {|| MovFardos( ">", oBrwEsq, oBrwDir ) }, oSizeC0:aPosObj[1,4], 15, , /**oFont*/, , .t., , STR0043 ) //"Vincular Marcados"
	tButton():New( oSizeC0:aPosObj[1,1]+30, oSizeC0:aPosObj[1,2], "<<" , oPnCnt, {|| MovFardos( "<", oBrwEsq, oBrwDir ) }, oSizeC0:aPosObj[1,4], 15, , /**oFont*/, , .t., , STR0044 ) //"Desvincular Marcados"
	tSay():New( oSizeC0:aPosObj[1,1]+100, oSizeC0:aPosObj[1,2], {|| STR0045 } , oPnCnt, , , , , , .t., CLR_BLACK, CLR_WHITE, oSizeC0:aPosObj[1,4], 9 ) //"Fardos"
	TGet():New( oSizeC0:aPosObj[1,1]+110, oSizeC0:aPosObj[1,2], {|| Len( aItsDir )	}, oPnCnt, oSizeC0:aPosObj[1,4], 9, "@E 999"			, , 0, , , .f., , .t., , .F., , .F., .F., , .t., .F., , "tGet1", , , , , , , , )
	tSay():New( oSizeC0:aPosObj[1,1]+125, oSizeC0:aPosObj[1,2], {|| STR0042  	}, oPnCnt, , , , , , .t., CLR_BLACK, CLR_WHITE, oSizeC0:aPosObj[1,4], 9 ) //"Peso Liquido"
	TGet():New( oSizeC0:aPosObj[1,1]+135, oSizeC0:aPosObj[1,2], {|| SomaPeso( "L" )	}, oPnCnt, oSizeC0:aPosObj[1,4], 9, "@E 999,999.99"	, , 0, , , .f., , .t., , .F., , .F., .F., , .t., .F., , "tGet2", , , , , , , , )
	tSay():New( oSizeC0:aPosObj[1,1]+150, oSizeC0:aPosObj[1,2], {|| STR0041		} , oPnCnt, , , , , , .t., CLR_BLACK, CLR_WHITE, oSizeC0:aPosObj[1,4], 9 ) //"Peso Bruto"
	TGet():New( oSizeC0:aPosObj[1,1]+160, oSizeC0:aPosObj[1,2], {|| SomaPeso( "B" )	}, oPnCnt, oSizeC0:aPosObj[1,4], 9, "@E 999,999.99"	, , 0, , , .f., , .t., , .F., , .F., .F., , .t., .F., , "tGet3", , , , , , , , )

	oSizeD0 := FwDefSize():New()
	oSizeD0:AddObject( "PD0", 100, 100, .t., .t. )    
	oSizeD0:SetWindowSize( { 0, 0, oPnDir:nHeight, oPnDir:nWidth } )
	oSizeD0:lProp 	 := .t.
	oSizeD0:aMargins := { 0, 0, 0, 0 }      
	oSizeD0:Process()

	oBrwDir := TCBrowse():New( oSizeD0:aPosObj[1,1], oSizeD0:aPosObj[1,2], oSizeD0:aPosObj[1,3], oSizeD0:aPosObj[1,4], , , , oPnDir, , , , {|| }, {|| }, , , , , , , .f., , .t., , .f., , , )
	oBrwDir:AddColumn( TCColumn():New(""		, { || IIf( aItsDir[oBrwDir:nAt,01] == "1", oOk, oNo ) },,,,"CENTER",,.t.,.t.,,,,.f., ) )
	oBrwDir:AddColumn( TCColumn():New(STR0039	, { || aItsDir[oBrwDir:nAt,02] }									, , , , "LEFT" 		, 100, .f., .t., , , , .f., ) ) //"Etiqueta"
	oBrwDir:AddColumn( TCColumn():New(STR0040	, { || aItsDir[oBrwDir:nAt,03] }									, , , , "LEFT" 		, 050, .f., .t., , , , .f., ) ) //"Fardo"
	oBrwDir:AddColumn( TCColumn():New(STR0041	, { || Transform( aItsDir[oBrwDir:nAt,04], "@E 999,999,999.99" ) }	, , , , "RIGHT"		, 050, .f., .t., , , , .f., ) ) //"Peso Bruto"
	oBrwDir:AddColumn( TCColumn():New(STR0042	, { || Transform( aItsDir[oBrwDir:nAt,05], "@E 999,999,999.99" ) }	, , , , "RIGHT"		, 050, .f., .t., , , , .f., ) ) //"Peso Liquido"
	oBrwDir:AddColumn( TCColumn():New(""		, { || "" }                     									, , , , "LEFT"		, 001, .f., .t., , , , .f., ) )
	oBrwDir:SetArray( aItsDir )
	oBrwDir:bLDblClick 		:= {|| MarcaUm( oBrwDir, aItsDir )}
	oBrwDir:bHeaderClick 	:= {|| MarcaTudo( oBrwDir, aItsDir, @lMarcAllD ) }

	oBrwDir:Align := CONTROL_ALIGN_ALLCLIENT

	oDlg:Activate( , , , .t., , , EnchoiceBar(oDlg, {|| nOpcX := 1, oDlg:End() } , {|| nOpcX := 0, oDlg:End() } ) )

	If nOpcX == 1  .And. lModified
		CalcFardos()
	EndIf

	If lModified
		oView:SetModified() 
	EndIf

	lMarcAllD 	:= .T.
	lMarcAllE 	:= .T.
	FWRestRows(aSaveLines)
Return(nQtdSel)

/** -------------------------------------------------------------------------------------
{Protheus.doc} CalcFardos
Responsavel pela transferencia de fardos entre os browsers.

@since: 	11/05/2019
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function CalcFardos()
	Local oModel	:= FwModelActive()
	Local oMdlDXS	:= oModel:GetModel("MDFIELDDXS")
	Local oMdlDXT	:= oModel:GetModel("MDGRIDDXT")
	Local nX        := 1 
	Local nPsBruTot := 0
	Local nPsLiqTot := 0

	If (nPos := ASCAN(aFardos, {|x| x[1] == FwFldGet("DXT_ITEM")})) > 0
		aFardos[nPos, 2] := aClone( aItsDir )
	Else
		AADD(aFardos, {FwFldGet("DXT_ITEM"), aClone( aItsDir )} )
	EndIf

	nQtdSel := Len( aItsDir )

	oMdlDXT:SetValue( "DXT_QUANT"  , nQtdSel )
	oMdlDXT:SetValue( "DXT_PSLIQU" , SomaPeso( "L" ) )
	oMdlDXT:SetValue( "DXT_PSBRUT" , SomaPeso( "B" ) )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Calcula o peso do total do material adicional que compoem o peso bruto dos fardos ³
	//³	para descontar posteriormente do peso liquido da carga do caminhão apos a segunda ³
	//³	pesagem                                                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1  To oMdlDXT:Length()
		oMdlDXT:GoLine( nX )
		nPsBruTot += oMdlDXT:GetValue("DXT_PSBRUT")
		nPsLiqTot += oMdlDXT:GetValue("DXT_PSLIQU")
	Next

	oMdlDXS:SetValue( "DXS_PSDESC", nPsBruTot - nPsLiqTot)
	If FwFldGet("DXS_PESO2") > FwFldGet("DXS_PESO1")
		FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO2") - FwFldGet("DXS_PESO1") ) )
	Else
		FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO1") - FwFldGet("DXS_PESO2") ) )
	EndIf

	FwFldPut( "DXS_PSBASE", ( FwFldGet("DXS_PSSUBT") - FwFldGet("DXS_PSDESC") ) )
	FwFldPut( "DXS_PSLIQU", ( ( FwFldGet("DXS_PSSUBT") - FwFldGet("DXS_PSDESC") ) - FwFldGet("DXS_PSEXTR" ) ) )

	// Atualiza rateio do peso da carga entre os itens do romaneio
	Rateio(oMdlDXT)

Return
/** -------------------------------------------------------------------------------------
{Protheus.doc} MovFardos
Responsavel pela transferencia de fardos entre os browsers.

@param: 	cSeta - ">|<" indica a movimentação dos registros marcados
@param: 	oBrwEsq - Browser da divisão esquerda
@param: 	oBrwDir - Browser da divisão esquerda
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function MovFardos( cSeta, oBrwEsq, oBrwDir )
	Local aItsOrig 	:= {}
	Local aItsDest 	:= {}
	Local lRet		:= .T.
	Local nX		:= 0
	Local nSaldo	:= 0
	Local nFardos	:= 0
	Local nDif		:= 0
	Local nPos		:= 0

	If cSeta == ">"
		aItsOrig 	:= aClone( aItsEsq )
		aItsDest 	:= aClone( aItsDir )
		
		If (nPos := ASCAN(aFdDisp, {|x| x[1] == cItemRom })) > 0
			aFdDisp[ nPos, 2] := aClone(aItsEsq) 
		EndIf
	EndIf
	If cSeta == "<"
		aItsOrig 	:= aClone( aItsDir )
		aItsDest 	:= aClone( aItsEsq )
		
		If (nPos := ASCAN(aFdDisp, {|x| x[1] == cItemRom })) > 0
			aFdDisp[ nPos, 2] := aClone(aItsEsq) 
		EndIf
	EndIf

	If ASCAN(aItsOrig, {|x| x[1] == "1" } ) > 0
		lModified := .T.
	EndIf

	If lModified
		For nX := 1 to Len( aItsOrig )
			If nX > Len( aItsOrig )
				Exit
			EndIf

			If aItsOrig[ nX, 1 ] == "1"
				aAdd( aItsDest, aItsOrig[ nX ] )
				aItsDest[ Len( aItsDest ), 1 ] := "2"

				aDel( aItsOrig, nX )
				aSize( aItsOrig, Len( aItsOrig )-1 )
				nX--		
			EndIf
		Next nX

		// Valida se a quantidade de fardos vinculados ao romaneio de saída é maior que o saldo da intrução de embarque.
		If cSeta == ">"
			DXO->( dbSetOrder(1) )
			If	DXO->( dbSeek( xFilial("DXO")+FwFldGet("DXT_NUMIE")+FwFldGet("DXT_ITEMIE") ) )
				nSaldo  := ( DXO->( DXO_QTDFD-DXO_QTDEMB ) )
				nFardos := A750QTDFD( FwFldGet("DXS_CODIGO"), FwFldGet("DXT_ITEM") )
				nDif	:= ( Len(aItsDest) - nFardos )

				If nDif > nSaldo
					lRet := .F.
					Help("",1,STR0020,,STR0069,1) //"ATENÇÃO"###" A quantidade fardos selecionados é superior ao saldo da instrução de embarque! "###"
				EndIf
			EndIf
		EndIf

		If lRet
			aItsOrig := ASort( aItsOrig, , , { | x, y | x[ 1 ] + x[ 3 ] < y[ 1 ] + y[ 3 ]})
			aItsDest := ASort( aItsDest, , , { | x, y | x[ 1 ] + x[ 3 ] < y[ 1 ] + y[ 3 ]})

			If cSeta == ">"
				aItsEsq := aClone( aItsOrig )
				aItsDir := aClone( aItsDest )
				
				If (nPos := ASCAN(aFdDisp, {|x| x[1] == cItemRom })) > 0
					aFdDisp[ nPos, 2] := aClone(aItsEsq) 
				EndIf
			EndIf
			If cSeta == "<"
				aItsEsq := aClone( aItsDest )
				aItsDir := aClone( aItsOrig )
				
				If (nPos := ASCAN(aFdDisp, {|x| x[1] == cItemRom })) > 0
					aFdDisp[ nPos, 2] := aClone(aItsEsq) 
				EndIf
			EndIf

			oBrwEsq:SetArray( aItsEsq )
			oBrwDir:SetArray( aItsDir )
			oBrwEsq:Refresh()
			oBrwDir:Refresh()
		EndIf
	EndIf
Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} MarcaUm
Marca/Desmarca Posicionado

@param:		oBrwMrk - Browse onde estão localizados os registros 
@param:		aItsMrk - Registros 
@author: 	Aecio Ferreira Gomes
@since: 	10/12/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function MarcaUm( oBrwMrk, aItsMrk)

	DO CASE
	CASE aItsMrk[ oBrwMrk:nAt, 1 ] == "1"
		aItsMrk[ oBrwMrk:nAt, 1 ] := "2"
	CASE aItsMrk[ oBrwMrk:nAt, 1 ] == "2"
		aItsMrk[ oBrwMrk:nAt, 1 ] := "1"
	OTHERWISE
		MsgInfo( STR0046, STR0047 ) //"Este fardo pertence a outra reservada!"###"Selecão não permitida..."
	ENDCASE

	oBrwMrk:Refresh()
Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} MarcaTudo
Marca/Desmarca Todos

@param:		oBrwMrk - Browse onde estão localizados os registros 
@param:		aItsMrk - Registros 
@param:		lMark 	- .T. Marca .F. Desmarca
@author: 	Aecio Ferreira Gomes
@since: 	10/12/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function MarcaTudo( oBrwMrk, aItsMrk, lMark )
	Local nX	:= 0

	Default lMark := .T.

	For nX := 1 to Len( aItsMrk )
		If aItsMrk[ nX, 1 ] $ "1|2"
			aItsMrk[ nX, 1 ] := If(lMark, "1", "2")
		EndIf
	Next nX

	oBrwMrk:Refresh()
	lMark := !lMark
Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} SomaPeso
Rotina após cancelamento da gravação do modelo de dados

@param:		cTipo 	- "L" Liquido  "B" Bruto
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function SomaPeso( cTipo )
	Local nRet	:= 0
	Local nX	:= 0

	For nX := 1 to Len( aItsDir )
		If cTipo == "B"
			nRet += aItsDir[ nX, 4 ]
		EndIf
		If cTipo == "L"
			nRet += aItsDir[ nX, 5 ]
		EndIf
	Next nX

Return(nRet)             

/** -------------------------------------------------------------------------------------
{Protheus.doc} PosModelo
Pos Validação do modelo de dados

@param:		oModel 	- Modelo de dados da rotina
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function PosModelo( oModel )
	Local oMdGridDXT    := oModel:GetModel("MDGRIDDXT")
	Local lRet 			:= .T.                         
	Local nOperac		:= oModel:GetOperation()
	Local cSafra        := ""

	If nOperac # MODEL_OPERATION_DELETE
		// Valida o percentual de rateio
		lRet := A750VLPERC(oMdGridDXT)

		ADA->(dbSetOrder(1)) // Filial + Contrato
		ADA->(dbSeek(xFilial("ADA")+ FwFldGet("DXS_CODCTP")))
		cSafra	:= ADA->ADA_CODSAF

		If Empty(cSafra)
			lRet := .F.
			Help('', 1, STR0020, , STR0077, 1 )
		Endif
	EndIf
Return( lRet )

/** -------------------------------------------------------------------------------------
{Protheus.doc} GrvModelo
Rotina para gravação do modelo de dados

@param:		oModel 	- Modelo de dados da rotina
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function GrvModelo( oModel )
	Local oFldDXS		:= oModel:GetModel("MDFIELDDXS")
	Local oMdlDXT		:= oModel:GetModel("MDGRIDDXT")
	Local aAreaAtu	    := GetArea( )
	Local cRomaneio	    := FwFldGet("DXS_CODIGO")
	Local cEtiqueta	    := ""
	Local cSafra		:= ""
	Local lRet			:= .T.
	Local nOperac 	    := oModel:GetOperation()
	Local nX, nI    	:= 0
	Local nPos			:= 0
	Local nPSSUBT1  	:= 0
	Local nTotPSB1		:= 0
	Local nTotPSL1		:= 0
	Local nPerc         := 0
	Local aTicket1      := {}
	Local cTicket       := ""
	Local cTicketAnt    := ""
	Local nDesconto     := 0

	Local aTicket 
	Local nTotLiq       := 0
	Local nTDesc        := 0
	Local nLiqRom       := 0

	Private cQryGr1 := GetNextAlias()
	Private cQryGr2 := GetNextAlias()

	ADA->(dbSetOrder(1)) // Filial + Contrato
	ADA->(dbSeek(xFilial("ADA")+ FwFldGet("DXS_CODCTP")))
	cSafra	:= oFldDXS:GetValue("DXS_SAFRA")

	BEGIN TRANSACTION
		If lRet .And. (INCLUI .Or. ALTERA)
			If !Empty(oFldDXS:GetValue("DXS_TICKET"))  .And. ALTERA

				cTicket := Posicione("DXS",1,xFilial("DXS")+oFldDXS:GetValue("DXS_CODIGO"),"DXS_TICKET")
				If oFldDXS:GetValue("DXS_TICKET") != cTicket

					//Atualiza valores com o ticket atual	
					If !Empty(oFldDXS:GetValue("DXS_TICKET"))
						cQuery := " SELECT * "
						cQuery +=   " FROM "+ RetSqlName("DXS") + " DXS "
						cQuery +=  " WHERE DXS.DXS_FILIAL = '" + xFilial( 'DXS' ) + "'" 
						cQuery +=  " AND DXS.DXS_TICKET   = '" + oFldDXS:GetValue("DXS_TICKET") + "'"
						cQuery +=  " AND DXS.DXS_STATUS   = '1' "
						cQuery +=  " ORDER BY DXS.DXS_CODIGO "
						cQuery := ChangeQuery(cQuery)
						If Select(cQryGr1) <> 0
							(cQryGr1)->(dbCloseArea())
						EndIf
						dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQryGr1,.T.,.T.)

						dbSelectArea(cQryGr1)
						(cQryGr1)->(dbGoTop())			
						While (cQryGr1)->(!Eof())

							nPSSUBT1 := (cQryGr1)->DXS_PSSUBT

							dbSelectArea("DXT")
							dbSetOrder(1)
							If dbSeek(xFilial("DXT")+(cQryGr1)->DXS_CODIGO)
								While !Eof() .AND. DXT->DXT_CODIGO = (cQryGr1)->DXS_CODIGO

									Aadd( aTicket1, { (cQryGr1)->DXS_CODIGO, DXT->DXT_ITEM, DXT->DXT_PSBRUT, DXT->DXT_PSLIQU } )

									//total liquido da query
									nTotPSB1 += DXT->DXT_PSBRUT
									nTotPSL1 += DXT->DXT_PSLIQU																	
									dbSkip()
								Enddo
							EndIf
							(cQryGr1)->(dbSkip())
						EndDo

						For nX := 1 to Len(aTicket1)
							If oFldDXS:GetValue("DXS_CODIGO") != aTicket1[nx][1]
								If AGRIFDBSEEK("DXS",aTicket1[nx][1],1,.F.)
									AGRTRAVAREG("DXS",.F.)	
									DXS->DXS_PSDESC	:= nTotPSB1 - nTotPSL1
									DXS->DXS_PSBASE := nPSSUBT1 - DXS->DXS_PSDESC 
									DXS->DXS_PSLIQU := nPSSUBT1 - DXS->DXS_PSDESC - DXS->DXS_PSEXTR										
									AGRDESTRAREG("DXS")
								EndIf
							EndIf
						Next nX
						(cQryGr1)->(dbCloseArea())	
					EndIf

					//Caso tenha existido um ticket anterior, recalcula e acerta os outros romaneios relacionados a ele
					If !Empty(cTicket)
						aTicket := SumByTicket(cTicket, oFldDXS:GetValue("DXS_CODIGO"), oFldDXS:GetValue('DXS_PSDESC'))
						nTotLiq := aTicket[1]
						nTDesc  := aTicket[2]

						//Atualiza Rateio
						dbSelectArea('DXS')
						dbSetOrder(2)
						If dbSeek(xFilial('DXS') + cTicket )

							While !Eof()                      .And.;
							DXS->DXS_FILIAL = xFilial('DXS')  .And.;
							DXS->DXS_TICKET = cTicket

									If DXS->DXS_STATUS  = '1' .And. DXS->DXS_CODIGO != oFldDXS:GetValue("DXS_CODIGO")
									nLiqRom := SumByRomaneio(DXS->DXS_CODIGO)

									nPerc    := (nLiqRom/nTotLiq)*100
									nValDifT := Round((DXS->DXS_PSSUBT - nDesconto - nTotLiq) *(nPerc/100), TamSX3("DXT_PSDIF")[2] )

									dbSelectArea('DXT')
									dbSetOrder(1)
									If dbSeek(xFilial('DXT') + DXS->DXS_CODIGO )
										While !Eof()                     .And.;
										DXT->DXT_FILIAL = xFilial('DXT') .And.;
										DXT->DXT_CODIGO = DXS->DXS_CODIGO

												If RecLock('DXT',.F.)
												DXT->DXT_PSDIF	:= nValDifT
												DXT->DXT_PERC  	:= Round((DXT->DXT_PSLIQU/nLiqRom)*100,  TamSX3("DXT_PERC")[2] )
												DXT->DXT_PSRAT 	:= Round((DXT->DXT_PSDIF*((DXT->DXT_PSLIQU/nLiqRom)*100))/100, TamSX3("DXT_PSRAT")[2]  )
												DXT->DXT_PSFISC	:= Round(DXT->DXT_PSLIQU+DXT->DXT_PSRAT, TamSX3("DXT_PSFISC")[2]  )
												MsUnlock()
											Endif
											dbSkip()
										EndDo
									Endif

								Endif

								DbSelectArea('DXS')		
								DbSkip()
							EndDo
						Endif
					EndIf
				EndIf
			EndIf

			// Atualiza o relacionamento entre os itens do romaneio e os fardos 
			If (lModified .OR. IsBlind() ) .And. Len(aFardos) > 0
				// Atualiza o saldo da instrução de embarque
				A750ATUDXO(oMdlDXT, nOperac )

				dbSelectArea( "DXI" )
				DXI->(dbSetOrder(1))

				For nX := 1 to oMdlDXT:Length()
					oMdlDXT:GoLine( nX )

					cItemR := oMdlDXT:GetValue("DXT_ITEM")
					If !oMdlDXT:IsDeleted() .And. (nPos := ASCAN(aFardos, {|x| x[1] == cItemR})) > 0

						For nI := 1 to Len(aFardos[nPos,2])

							cEtiqueta := aFardos[nPos,2,nI,2]

							If DXI->(dbSeek( xFilial( "DXI" ) + cSafra + cEtiqueta ))
								RecLock( "DXI", .F. )
								DXI_ROMSAI := cRomaneio
								DXI_ITROMS := cItemR
								DXI->(MsUnLock())
							else
								lRet := .F.	
							EndIf
						Next nI
					EndIf
				Next nX
			EndIf
		EndIf

		If lRet
			// Se não for operação EXCLUIR
			If nOperac # 5
				// Atualiza rateio do peso da carga entre os itens do romaneio
				Rateio(oMdlDXT)
			Else
				A750ATUDXO(oMdlDXT, MODEL_OPERATION_DELETE)
			EndIf

			cTicketAnt := Posicione("DXS",1,xFilial("DXS")+oFldDXS:GetValue("DXS_CODIGO"),"DXS_TICKET")

			FwFormCommit( oModel )

			If cTicketAnt <> cTicket .And. !Empty(cTicketAnt)
				aTicket := SumByTicket(cTicketAnt, oFldDXS:GetValue("DXS_CODIGO"), oFldDXS:GetValue('DXS_PSDESC'))
				nTotLiq := aTicket[1]
				nTDesc  := aTicket[2]

				//Atualiza Rateio
				dbSelectArea('DXS')
				dbSetOrder(2)
				If dbSeek(xFilial('DXS') + cTicketAnt )

					While !Eof()                      .And.;
					DXS->DXS_FILIAL = xFilial('DXS')  .And.;
					DXS->DXS_TICKET = cTicketAnt

							If DXS->DXS_STATUS  = '1' .And. DXS->DXS_CODIGO != oFldDXS:GetValue("DXS_CODIGO")
							nLiqRom := SumByRomaneio(DXS->DXS_CODIGO)
							nPerc    := (nLiqRom/nTotLiq)*100
							nValDifT := Round((DXS->DXS_PSSUBT - nDesconto - nTotLiq) *(nPerc/100), TamSX3("DXT_PSDIF")[2] )

							dbSelectArea('DXT')
							dbSetOrder(1)
							If dbSeek(xFilial('DXT') + DXS->DXS_CODIGO )
								While !Eof()                     .And.;
								DXT->DXT_FILIAL = xFilial('DXT') .And.;
								DXT->DXT_CODIGO = DXS->DXS_CODIGO

										If RecLock('DXT',.F.)
										DXT->DXT_PSDIF	:= nValDifT
										DXT->DXT_PERC  	:= Round((DXT->DXT_PSLIQU/nLiqRom)*100, TamSX3("DXT_PERC")[2] )
										DXT->DXT_PSRAT 	:= Round((DXT->DXT_PSDIF*((DXT->DXT_PSLIQU/nLiqRom)*100))/100, TamSX3("DXT_PSRAT")[2] )
										DXT->DXT_PSFISC	:= Round(DXT->DXT_PSLIQU+DXT->DXT_PSRAT, TamSX3("DXT_PSFISC")[2] )
										MsUnlock()
									Endif
									dbSkip()
								EndDo
							Endif

						Endif

						DbSelectArea('DXS')		
						DbSkip()
					EndDo
				Endif
			Endif

			If !Empty(oFldDXS:GetValue("DXS_TICKET"))
				aTicket := SumByTicket(oFldDXS:GetValue("DXS_TICKET"), oFldDXS:GetValue("DXS_CODIGO"), oFldDXS:GetValue('DXS_PSDESC'))
				nTotLiq := aTicket[1]
				nTDesc  := aTicket[2]

				//Atualiza Rateio
				dbSelectArea('DXS')
				dbSetOrder(2)
				If dbSeek(xFilial('DXS') + oFldDXS:GetValue("DXS_TICKET") )

					While !Eof()                      .And.;
					DXS->DXS_FILIAL = xFilial('DXS')  .And.;
					DXS->DXS_TICKET = oFldDXS:GetValue("DXS_TICKET")

							If DXS->DXS_STATUS  = '1' .And. DXS->DXS_CODIGO <> oFldDXS:GetValue("DXS_CODIGO")
							nLiqRom := SumByRomaneio(DXS->DXS_CODIGO)
							nPerc    := (nLiqRom/nTotLiq)*100
							nValDifT := Round((DXS->DXS_PSSUBT - nTDesc - nTotLiq) *(nPerc/100), TamSX3("DXT_PSDIF")[2] )

							dbSelectArea('DXT')
							dbSetOrder(1)
							If dbSeek(xFilial('DXT') + DXS->DXS_CODIGO )
								While !Eof()                     .And.;
								DXT->DXT_FILIAL = xFilial('DXT') .And.;
								DXT->DXT_CODIGO = DXS->DXS_CODIGO

										If RecLock('DXT',.F.)
										DXT->DXT_PSDIF	:= nValDifT
										DXT->DXT_PERC  	:= Round((DXT->DXT_PSLIQU/nLiqRom)*100, TamSX3("DXT_PERC")[2] )
										DXT->DXT_PSRAT 	:= Round((DXT->DXT_PSDIF*((DXT->DXT_PSLIQU/nLiqRom)*100))/100, TamSX3("DXT_PSRAT")[2])
										DXT->DXT_PSFISC	:= Round(DXT->DXT_PSLIQU+DXT->DXT_PSRAT, TamSX3("DXT_PSFISC")[2] )
										MsUnlock()
									Endif
									dbSkip()
								EndDo
							Endif
						Endif

						DbSelectArea('DXS')		
						DbSkip()
					EndDo
				Endif
			Endif
		Else
			DisarmTransaction()
		EndIf
	END TRANSACTION()

	aFardos 	:= {}
	aFdDisp		:= {}
	aRateio		:= {}
	lModified 	:= .F.                

	RestArea( aAreaAtu )
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} Rateio
Responsavel por fazer o rateio do peso da carga entre os itens do romaneio

@param:		oMdGridDXT 	- Modelo de dados da grid
@param:		nLine 		- Linha Grid
@param:		cAction 	- acao feita na linha "DELETE" ou "UNDELETE"
@param:		nA 	- Linha Grid
@author: 	Aécio Ferreira Gomes
@since: 	23/04/2013
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function Rateio(oMdGridDXT)
	Local oModel	  := FwModelActive() 	
	Local oMdFieldDXS := oModel:GetModel( "MDFIELDDXS" )
	Local nX 		  := 0
	Local nTotGer	  := 0
	Local aLines	  := FwSaveRows()
	Local nPerTot 	  := 0
	Local nPSLTot 	  := 0
	Local lNoExist	  := .F.
	Local nValDif     := 0
	Local nPSLiq      := 0
	Local nDesc       := 0
	Local lHasTicket  := .F.
	Local nValDifT    := 0
	Local nDifGrdTot  := 0

	Private cQryRat := GetNextAlias()

	If FUNNAME() = "AGRA750"

		If !Empty(oMdFieldDXS:GetValue("DXS_TICKET"))
			//limpa array do rateio toda vez que entrar 
			aRateio		:= {}

			cQuery := " SELECT * "
			cQuery +=   " FROM "+ RetSqlName("DXS") + " DXS "
			cQuery +=  " WHERE DXS.DXS_FILIAL = '" + xFilial( 'DXS' ) + "'"   

			If oModel:GetOperation() == MODEL_OPERATION_UPDATE
				cQuery +=  " AND DXS.DXS_TICKET   =  '" + oMdFieldDXS:GetValue("DXS_TICKET") + "'"
				cQuery +=  " AND DXS.DXS_CODIGO   <> '" + FwFldGet("DXS_CODIGO") + "'"
			Else
				cQuery +=  " AND DXS.DXS_TICKET   = '" + oMdFieldDXS:GetValue("DXS_TICKET") + "'"
			EndIf

			cQuery +=  " AND DXS.DXS_STATUS   = '1' "
			cQuery +=  " ORDER BY DXS.DXS_CODIGO "
			cQuery := ChangeQuery(cQuery)

			If Select(cQryRat) <> 0
				(cQryRat)->(dbCloseArea())
				lNoExist := .T.
			EndIf

			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cQryRat,.T.,.T.)
			dbSelectArea(cQryRat)
			(cQryRat)->(dbGoTop())
			nTotGer	:= 0	
			nCount 	:= 0		
			While (cQryRat)->(!Eof()) .AND. (cQryRat)->DXS_TICKET = oMdFieldDXS:GetValue("DXS_TICKET")
				lNoExist := .F.
				dbSelectArea("DXT")
				dbSetOrder(1)
				If dbSeek(xFilial("DXT")+(cQryRat)->DXS_CODIGO)
					While !Eof() .AND. DXT->DXT_CODIGO = (cQryRat)->DXS_CODIGO

						Aadd( aRateio, { (cQryRat)->DXS_CODIGO, DXT->DXT_ITEM, DXT->DXT_PSLIQU } )

						nCount ++
						//total liquido da query
						nTotGer += DXT->DXT_PSLIQU
						dbSkip()
					Enddo
				EndIf
				If (cQryRat)->DXS_CODIGO = oMdFieldDXS:GetValue('DXS_CODIGO')
					lHasTicket := .T.
				Endif

				nDesc += (cQryRat)->DXS_PSDESC			
				(cQryRat)->(dbSkip())
			EndDo

			//Se o peso de desconto do romaneio atual não está considerado
			//Adiciona ao total de desconto, para o calculo correto do rateio
			If .Not. lHasTicket
				nDesc += oMdFieldDXS:GetValue('DXS_PSDESC')
			Endif

			// Total de peso líquido dos fardos
			nTotPsLiq := oModel:GetModel("AGRA750CALC"):GetValue("TOTPSL")+nTotGer
			nPSLiq    := oModel:GetModel("AGRA750CALC"):GetValue("TOTPSL")

			/**********************************
			* A primeira execução do laço é para verificar qual a diferença de carga relativa 
			* a quantidade de fardos selecionadas para esse romaneio 
			***********************************/
			nValDifT := 0
			For nX := 1 to oMdGridDXT:Length()
				oMdGridDXT:GoLine( nX )

				// Se o numero da intrução estiver em branco
				If Empty(oMdGridDXT:GetValue("DXT_NUMIE"))
					Loop
				EndIf

				// Atualiza a diferença de peso da carga do caminhão
				nPerc    := (oMdGridDXT:GetValue("DXT_PSLIQU") / nTotPsLiq)*100
				nValDif  := Round((oMdFieldDXS:GetValue("DXS_PSSUBT") - nDesc - nTotPsLiq) *(nPerc/100), TamSX3("DXS_PSSUBT")[2] )
				nValDifT += nValDif
			Next nX

			// Atualiza o peso fiscal dos fardos
			For nX := 1 to oMdGridDXT:Length()
				oMdGridDXT:GoLine( nX )

				// Se o numero da intrução estiver em branco
				If Empty(oMdGridDXT:GetValue("DXT_NUMIE"))
					Loop
				EndIf

				// Atualiza a diferença de peso da carga do caminhão
				oMdGridDXT:SetValue("DXT_PSDIF",nValDifT)

				nPerc := Round((oMdGridDXT:GetValue("DXT_PSLIQU") / nPSLiq)*100, TamSX3( "DXT_PERC" )[2] )
				nPerTot	+= nPerc  

				// Calcula a quantidade rateada do item
				nPsRat  := Round(oMdGridDXT:GetValue("DXT_PSDIF") *(nPerc/100), TamSX3("DXT_PSDIF")[2] )
				nPSLTot += nPsRat

				// Atualiza o percentual do item 
				oMdGridDXT:SetValue("DXT_PERC",nPerc)
				nValDif  := Round(oMdGridDXT:GetValue("DXT_PSDIF") *(nPerc/100), TamSX3("DXT_PSDIF")[2] )

				// Atualiza a quantidade rateada do item
				oMdGridDXT:SetValue("DXT_PSRAT",nValDif)

				// Ajusta diferença de arredondamento
				//linha igual a contador for
				If oMdGridDXT:Length() = nX
					If nPerTot <> 100
						// Atualiza o percentual do item 
						oMdGridDXT:SetValue("DXT_PERC",nPerc+(100-nPerTot))
					EndIf
					nDifGrdTot := oMdGridDXT:GetValue("DXT_PSDIF") - nPSLTot
					If nPSLTot <> oMdGridDXT:GetValue("DXT_PSDIF")
						// Atualiza o percentual do item 
						oMdGridDXT:SetValue("DXT_PSRAT",Round(oMdGridDXT:GetValue("DXT_PSDIF") *(oMdGridDXT:GetValue("DXT_PERC")/100), TamSX3("DXT_PSRAT")[2] )+nDifGrdTot)
					EndIf
				EndIf

				// Atualiza o Peso Fiscal do Item
				oMdGridDXT:SetValue("DXT_PSFISC",Round(oMdGridDXT:GetValue("DXT_PSLIQU")+oMdGridDXT:GetValue("DXT_PSRAT"), TamSX3("DXT_PSFISC")[2] ))	
			Next
		Else
			// Total de peso líquido dos fardos
			nTotPsLiq := oModel:GetModel("AGRA750CALC"):GetValue("TOTPSL")

			// Atualiza o peso fiscal dos fardos
			For nX := 1 to oMdGridDXT:Length()
				oMdGridDXT:GoLine( nX )

				// Se o numero da intrução estiver em branco
				If Empty(oMdGridDXT:GetValue("DXT_NUMIE"))
					Loop
				EndIf

				// Atualiza a diferença de peso da carga do caminhão
				oMdGridDXT:SetValue("DXT_PSDIF",Round(FwFldGet("DXS_PSLIQU") - nTotPsLiq,TamSX3("DXT_PSDIF")[2] ))

				nPerc 	:= Round((oMdGridDXT:GetValue("DXT_PSLIQU") / nTotPsLiq)*100, TamSX3("DXT_PERC")[2])
				nPerTot	+= nPerc

				// Calcula a quantidade rateada do item
				nPsRat  := Round(oMdGridDXT:GetValue("DXT_PSDIF") * (nPerc/100) , TamSX3("DXT_PSRAT")[2])
				nPSLTot += nPsRat

				// Atualiza o percentual do item 
				oMdGridDXT:SetValue("DXT_PERC",nPerc)

				// Atualiza a quantidade rateada do item
				oMdGridDXT:SetValue("DXT_PSRAT",nPsRat)

				// Ajusta diferença de arredondamento
				If oMdGridDXT:Length() = nX
					If nPerTot <> 100
						// Atualiza o percentual do item 
						oMdGridDXT:SetValue("DXT_PERC",nPerc+(100-nPerTot))
					EndIf
					If nPSLTot <> oMdGridDXT:GetValue("DXT_PSDIF")
						// Atualiza o percentual do item 
						nDifGrdTot := oMdGridDXT:GetValue("DXT_PSDIF") - nPSLTot
						oMdGridDXT:SetValue("DXT_PSRAT", (nPsRat +  nDifGrdTot) )
					EndIf
				EndIf

				// Atualiza o Peso Fiscal do Item
				oMdGridDXT:SetValue("DXT_PSFISC",Round(oMdGridDXT:GetValue("DXT_PSLIQU")+oMdGridDXT:GetValue("DXT_PSRAT"),TamSX3("DXT_PSFISC")[2]))	
			Next
		EndIf
	EndIf

	FwRestRows(aLines)	
Return(Nil)

/** -------------------------------------------------------------------------------------
{Protheus.doc} CanModelo
Rotina após cancelamento da gravação do modelo de dados

@param:		oModel 	- Modelo de dados da rotina
@author: 	Ricardo Tomasi
@since: 	13/12/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Static Function CanModelo( oModel )
	aFardos 	:= {}
	lModified   := .F.
Return(.T.)

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA750P
Rotina de pesagem;
Responsável por gerar o pedido de vendas e fazer a preparacao do documento de saida

@param:		cAlias 	- Alias corrente
@param:		nReg 	- Registro posicionado
@param:		nOpc 	- Opção do Browse
@author: 	Ricardo Tomasi
@since: 	11/09/2012
@Uso: 		AGRA750
------------------------------------------------------------------------------------- **/
Function AGRA750P( cAlias, nReg, nOpc )
	Local oModel	:= FwLoadModel( "AGRA750" )
	Local aAreaAtu	:= GetArea()
	Local nTotFrds	:= 0
	Local lRet		:= .T.
	Local lExit     := .F.
	Local lAG750NF	:= EXISTBLOCK ("AG750NF")
	Local lNF		:= .T.     
	Private _cNumPV	:= ""
	//-----------------------------------
	//Ponto de entrada para desativar geração
	//geração de documento de saida automaticamente
	//apos gerar pedido, sendo necessario gerar 
	//pelo módulo de faturamento para dar continuidade
	//-----------------------------------
	If lAG750NF
		lNF := ExecBlock('AG750NF',.F.,.F.,)
	EndIf

	oModel:SetOperation(4)

	If (lRet := oModel:Activate())

		If lRet .And. DXS->( DXS_PESO1 ) <= 0 .Or. DXS->( DXS_PESO2 ) <= 0
			lRet := .F.
			Help( , , STR0026, , STR0048, 1, 0 ) //"AJUDA"###"Romaneio de Saída não pode ser faturado, pois as pesagens estao incompletas!"
		EndIf

		nTotFrds := oModel:GetModel("AGRA750CALC"):GetValue("TOTQTD")

		If lRet .And. nTotFrds <= 0
			lRet := .F.
			Help( , , "AJUDA", , STR0049, 1, 0 ) //"Romaneio de Saída não pode ser faturado, pois não há fardos vinculados!"
		EndIf

		// Cria o Pedido de Vendas	
		If lRet .And. Empty(DXS->DXS_NUMPED)
			//verifica se há movimentos vinculados ao romaneio
			If !Empty(DXS->DXS_NUMDOC) 
				lRet := .F.
				Help( , , "AJUDA", , STR0101, 1, 0 ) //"Romaneio de Saída não pode ser faturado, pois  há movimentos vinculados!"
			EndIf

			If lRet
				lRet :=  GeraPedV()
			Endif
			If lRet .and. lNF
				If SC5->( dbSeek( xFilial("SC5")+_cNumPV ) ) .AND. !IsBlind() // proteç?o para automaç?o
					SC5->( Ma410PvNfs(Alias(), Recno()) )
				Else
					lRet := .F.	
				EndIf
			EndIf

			// Caso ja exista o pedido de vendas gera a nota de saida
		ElseIf lRet .And. !Empty(DXS->DXS_NUMPED) .And. Empty(DXS->DXS_NUMNFS) .and. lNF
			
			SC5->(dbSetOrder(1))
			If lRet .AND. SC5->( dbSeek( xFilial("SC5")+DXS->DXS_NUMPED ) )
				SC5->( Ma410PvNfs(Alias(), Recno()) )
			EndIf
			//Caso tenha sido feita vinculação do Pedido de Venda no Romaneio
		Elseif lRet .And. !Empty(DXS->DXS_NUMPED) .And. !Empty(DXS->DXS_NUMNFS)
			lExit := .F.
			BEGIN TRANSACTION
				If (lRet := A750QTDPRG(1))
					//Faz ajuste de estoque 
					If (lRet := A750GERAD3())
						If DXS->( RecLock("DXS", .F.) )
							DXS->DXS_STATUS := '3'
							DXS->(MsUnLock())
							RestArea(aAreaAtu)
							lExit := .T.
						EndIf
					Else
						RestArea(aAreaAtu)
						DisarmTransaction()
					Endif
				Else
					RestArea(aAreaAtu)
					DisarmTransaction()
				Endif
			END TRANSACTION

			If lExit
				Return()
			EndIf

		EndIf

		If lRet
			//Atualiza o romaneio com os dados do documento fiscal de saida
			SD2->(dbSetOrder(8)) //Filial + Num. Pedido + Item Ped.
			If !Empty(DXS->DXS_NUMPED) .And. SD2->(dbSeek(xFilial("SD2")+DXS->DXS_NUMPED))
				If DXS->( RecLock("DXS", .F.) )
					DXS->DXS_NUMNFS := SD2->D2_DOC
					DXS->DXS_SERNFS := SD2->D2_SERIE
					DXS->DXS_STATUS := '3'
					DXS->(MsUnLock())
					If MsgYesNo(STR0080, STR0081)//"Deseja imprimir o Ticket de Pesagem para esse romaneio?", "Ticket de Pesagem"
						AGRAR760()
					EndIf
				EndIf
			EndIf
		EndIf
	Else
		AutoGrLog( STR0050	+ ' [' + AllToChar( oModel:GetErrorMessage()[6] )	+ ']' ) //'Erro'
		MostraErro()
	EndIf

	RestArea(aAreaAtu)
Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} A750GERAD3
Responsavel por fazer o ajuste de estoque via movimentos internos

@param: nOperac - Tipo de Operação 3 = Inclusão; 
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA750
------------------------------------------------------------------------------------- **/
Function A750GERAD3(nOperac)
	Local aArea		:= GetArea()
	Local aCab			:= {}
	Local aLinhas		:= {}
	Local cTM			:= ""
	Local cNumDoc		:= ""
	Local lRet			:= .T.  
	Local lAchou		:= .F. 
	Local nPosCod		:= 0
	Local nPosQuant	:= 0
	Local nX			:= 0
	Local nModuloOld 	:= nModulo
	Local lAGR75ID3 := ExistBlock('AGR75ID3')
	Default nOperac 	:= 3

	SaveInter() // Salva as Variaveis publicas	

	DXT->(dbSetOrder(1)) // Filial + Romaneio + Item
	DXO->(dbSetOrder(1)) // Filial + Intrução + Item
	DXQ->(dbSetOrder(1)) // Filial + Reserva + Item
	ADB->(dbSetOrder(1)) // Filial + Contrato + Item 
	SB1->(dbSetOrder(1)) // Filial + Produdo

	If nOperac == 3
		// Busca o proximo numero de documento
		cNumDoc := NextNumDoc()	
	Else
		// Busca o numero do documento do movimento
		SD3->(dbSetOrder(2))
		SD3->(dbSeek(xFilial("SD3")+DXS->DXS_NUMDOC))
		While SD3->(!Eof() .And. D3_DOC == DXS->DXS_NUMDOC )
			cNumDoc 	:= SD3->D3_DOC
			cTM 		:= SD3->D3_TM

			// Se encontrou um registro valido sai do laco
			If SD3->D3_ESTORNO # "S"
				Exit
			EndIf
		End
	EndIf

	DXT->(dbGotop()) // Filial + Romaneio + Item 
	If DXT->(dbSeek( xFilial( "DXT" )+DXS->DXS_CODIGO)) .And. DXT->DXT_PSDIF <> 0

		// Recupera o tipo da TM para ajuste de estoque
		If lRet .And. nOperac == 3
			If DXT->DXT_PSDIF > 0
				cTM := SuperGetMV("MV_AGRTMDV",.F.,"")

				If lRet := SF5->(dbSeek(xFilial("SF5")+cTM))
					lRet := SF5->F5_TIPO $ "D"
				EndIf
			Else
				cTM := SuperGetMV("MV_AGRTMPP",.F.,"")

				If lRet := SF5->(dbSeek(xFilial("SF5")+cTM))
					lRet := SF5->F5_TIPO $ "R"
				EndIf
			EndIf

			If !lRet
				Help(" ",1,"A240TM")
			EndIf
		ElseIf lRet
			lRet := SF5->(dbSeek(xFilial("SF5")+cTM))			
		EndIf

		If lRet
			AADD(aCab, {"D3_DOC"		, cNumDoc				, Nil } ) // Documento
			AADD(aCab, {"D3_TM"			, cTM					, Nil } ) // TM 
			AADD(aCab, {"D3_CC"			, CriaVar("D3_TM",.F.)	, Nil } ) // Centro de Custo
			AADD(aCab, {"D3_EMISSAO"	, ddatabase				, Nil } ) // Data de Emissão

			While DXT->(!Eof() .And. DXT_FILIAL+DXT_CODIGO == xFilial( "DXT" )+DXS->DXS_CODIGO)

				If DXO->( dbSeek( xFilial("DXO")+DXT->( DXT_NUMIE + DXT_ITEMIE ) ) )

					If ADB->( dbSeek( xFilial( "ADB" ) + DXO->(DXO_CODCTP) + DXO->(DXO_ITECTP) ) )
						// Posiciona no codigo do produto
						SB1->( dbSeek( xFilial('SB1')+ADB->ADB_CODPRO ) )

						// Valida se ja existe o produto no array e soma as quantidades
						For nX := 1 To Len(aLinhas)
							If (nPosCod := ASCAN(aLinhas[nX], {|x| x[1] == "D3_COD" } ) ) > 0 ;
							.And. 	aLinhas[nX,nPosCod,2] == SB1->B1_COD

								// Acumula a quantidade do item
									If (nPosQuant := ASCAN(aLinhas[nX], {|x| x[1] == "D3_QUANT" } ) ) > 0
									aLinhas[nX,nPosQuant,2] += Abs(DXT->DXT_PSRAT)
								EndIf

								lAchou := .T.
								Exit
							EndIf
						Next

						If !lAchou
							AADD(aLinhas,{})
							AADD(aTail(aLinhas),  {"D3_COD"		,SB1->B1_COD 				,NIL} )
							AADD(aTail(aLinhas),  {"D3_LOCAL"  ,ADB->ADB_LOCAL				,NIL} )
							AADD(aTail(aLinhas),  {"D3_QUANT"	,Abs(DXT->DXT_PSRAT)		,NIL} )

							If SF5->(F5_VAL) = "S"

								SB2->(dbSetOrder(1))
								SB2->(dbSeek(xFilial("SB2") + SB1->B1_COD + ADB->ADB_LOCAL))

								For nX := 1 to 5
									AADD(aTail(aLinhas),  {"D3_CUSTO"+Str(nX,1) ,( &("SB2->B2_CM" + Str(nX,1)) ) * Abs(DXT->DXT_PSRAT)		,NIL} )
								Next
							EndIf

							//-----------------------------------
							//Saulo Carvalho Gomes - 08/10/2014
							//Ajuste com autorização de Vitor/Totvs	
							//Ponto de Entrada para adicionar campos
							//customizados.
							//-----------------------------------
							If lAGR75ID3
								aRet := ExecBlock('AGR75ID3',.F.,.F.,{aLinhas})
								If ValType(aRet) == 'A'
									aLinhas:= aRet // Itens do movimento interno
								EndIf
							EndIf
						EndIf

						lAchou := .F.
					EndIf
				EndIf
				DXT->(dbSkip())
			End

			Private	lMSErroAuto := .F.
			Private	lMSHelpAuto := .T.

			//-----------------------------------
			//Saulo Carvalho Gomes - 09/10/2014
			//Ajuste com autorização de Vitor/Totvs	
			//Ponto de Entrada para adicionar campos
			//customizados.
			//-----------------------------------
			If ExistBlock('AGR750D3')
				aRet := ExecBlock('AGR750D3',.F.,.F.,{aCab, aLinhas})
				If ValType(aRet) == 'A'
					aCab	:= aRet[1] // Cabeçalho do movimento interno
					aLinhas:= aRet[2] // Itens do movimento interno
				EndIf
			EndIf

			MsAguarde({||MSExecAuto({|x,y,z|MATA241(x,y,z)},aCab,aLinhas,nOperac)},STR0051,STR0052) //"Aguarde..."###"Ajustando estoque..."

			If lMSErroAuto
				lRet := .F.
				MostraErro()
				DisarmTransaction()
			Else
				//-----------------------------------------------------------------------
				// Relaciona o numero do documento da movimentação de estoque ao romaneio
				//-----------------------------------------------------------------------
				RecLock("DXS",.F.)
				DXS->DXS_NUMDOC :=  If(nOperac == 3, cNumDoc, "" )
				DXS->(MsUnLock())
			EndIf
		EndIf
	EndIf

	nModulo := nModuloOld  
	RestInter() // Restaura as variaveis publicas
	RestArea(aArea)
Return( lRet )     

/** -------------------------------------------------------------------------------------
{Protheus.doc} NextNumDoc()
Retorna o proximo numero disponivel para o documento

@author: Aecio Ferreira Gomes
@since: 26/11/2012
@Uso: AGRA750
------------------------------------------------------------------------------------- **/
Static Function NextNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumDoc 	:= ""
	Local cMay			:= ""

	//----------------------------------------------------
	// Inicializa o numero do Documento com o ultimo + 1
	//----------------------------------------------------
	dbSelectArea("SD3")
	cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)
	cNumDoc := A261RetINV(cNumDoc)
	dbSetOrder(2)
	dbSeek(cFilAnt+cNumDoc)
	cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
	While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumDoc .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO # "S"
			cNumDoc := Soma1(cNumDoc)
			cMay := "SD3"+Alltrim(cFilAnt)+cNumDoc
		EndIf
		dbSkip()
	EndDo

	RestArea( aAreaAtu )
Return( cNumDoc )

/** -------------------------------------------------------------------------------------
{Protheus.doc} IncluiPV
Função auxiliar para geração do pedido de vendas

@author: 	Aecio Gomes
@since: 	08/06/2012
@Uso: 		AGRA750
@type function
------------------------------------------------------------------------------------- **/
Static Function IncluiPV(cNumPV)
	Local oModel		:= FwModelActive()
	Local aAreaAtu		:= GetArea()
	Local aPedido	    := {} //Cabeçalho - Pedido de Venda
	Local aItens		:= {} //Linhas - Itens do Pedido de Venda
	Local aAux          := {}
	Local nX			:= 0
	Local nMaxVend  	:= Fa440CntVen() 

	/** Variaveis do Cabeçalho do Pedido de Venda */
	Local cTipo			:= "N"
	Local cVend			:= ""	
	Local cCampo		:= ""

	/** Variaveis do Item do Pedido de Venda */
	Local cItSC6		:= STRZERO(0,TAMSX3("C6_ITEM")[1])
	Local nVolume		:= oModel:GetModel("AGRA750CALC"):GetValue("TOTQTD") 
	Local aRetPE        := {}

	Private lMsErroAuto := .f.

	// Começo do ponto de entrada BOM FUTURO
	If EXISTBLOCK ("AGRA75001")
		lMsErroAuto:= ExecBlock("AGRA75001",.F.,.F.,{cNumPV})
		// Fim do ponto de entrada BOM FUTURO
	Else
		ADA->(dbSetOrder(1)) // Filial + Contrato
		ADA->(dbSeek( xFilial("ADA")+DXS->DXS_CODCTP))

		SA1->( dbSetOrder(1) ) // Filial + Cliente + Loja
		SA1->( dbSeek(xFilial("SA1")+DXS->(DXS_CLIENT+DXS_LJCLI)))

		aAdd(aPedido, {"C5_NUM"		, cNumPV			, Nil })
		aAdd(aPedido, {"C5_TIPO"		, cTipo			, Nil })
		aAdd(aPedido, {"C5_CLIENTE"	, ADA->ADA_CODCLI	, Nil })
		aAdd(aPedido, {"C5_LOJACLI"	, ADA->ADA_LOJCLI	, Nil })
		aAdd(aPedido, {"C5_CLIENT"	, ADA->ADA_CODCLI	, Nil })
		aAdd(aPedido, {"C5_LOJAENT"	, ADA->ADA_LOJCLI	, Nil })
		aAdd(aPedido, {"C5_CONDPAG"	, ADA->ADA_CONDPG	, Nil })
		aAdd(aPedido, {"C5_TABELA"	, ADA->ADA_TABELA	, Nil })
		aAdd(aPedido, {"C5_TIPOCLI"	, SA1->A1_TIPO	, Nil })
		aAdd(aPedido, {"C5_DESC1"	, ADA->ADA_DESC1 	, Nil })
		aAdd(aPedido, {"C5_DESC2"	, ADA->ADA_DESC2 	, Nil })
		aAdd(aPedido, {"C5_DESC3"	, ADA->ADA_DESC3 	, Nil })
		aAdd(aPedido, {"C5_DESC4"	, ADA->ADA_DESC4 	, Nil })
		aAdd(aPedido, {"C5_MOEDA" 	, ADA->ADA_MOEDA 	, Nil })
		aAdd(aPedido, {"C5_VOLUME1"	, nVolume	 		, Nil }) // Dado adicional solicitado pelo cliente piloto bom futuro
		aAdd(aPedido, {"C5_TRANSP" 	, DXS->DXS_TRANSP	, Nil }) // Dado adicional solicitado pelo cliente piloto bom futuro
		aAdd(aPedido, {"C5_TPFRETE"	, DXS->DXS_TPFRET	, Nil }) // Dado adicional solicitado pelo cliente piloto bom futuro
		
		If SC5->(FieldPos("C5_INDPRES")) > 0 //Presença Comprador (NT 2020.006)
            aAdd(aPedido, {"C5_INDPRES"	, "0"	, Nil })
        EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Transfere vendedores                                                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cVend := "1"
		For nX := 1 To nMaxVend
			cCampo := "ADA_VEND"+cVend
			If ADA->(FieldPos(cCampo)) > 0
				nY := ADA->(FieldPos(cCampo))
				cCampo := "C5"+SubStr(cCampo,4)
				aAdd(aPedido, {cCampo, ADA->(FieldGet(nY)) 	, Nil })
			EndIf
			cCampo := "ADA_COMIS"+cVend
			If ADA->(FieldPos(cCampo)) > 0
				nY := ADA->(FieldPos(cCampo))
				cCampo := "C5"+SubStr(cCampo,4)	
				aAdd(aPedido, {cCampo, ADA->(FieldGet(nY)) 	, Nil })
			EndIf
			cVend := Soma1(cVend,1)
		Next nX

		//Recupera posicição do campo especie no cabeçalho
		nPosEspeci := aScan(aPedido, {|x| x[1] == "C5_ESPECI1"})

		DXT->(dbSetOrder(1)) // Filial + Romaneio + Item
		DXO->(dbSetOrder(1)) // Filial + Intrução + Item
		DXQ->(dbSetOrder(1)) // Filial + Reserva + Item
		ADB->(dbSetOrder(1)) // Filial + Contrato + Item 

		DXT->(dbGotop()) // Filial + Romaneio + Item 
		DXT->(dbSeek( xFilial( "DXT" )+DXS->DXS_CODIGO))
		While DXT->(!Eof() .And. DXT_FILIAL+DXT_CODIGO == xFilial( "DXT" )+DXS->DXS_CODIGO)


			If DXO->( dbSeek( xFilial("DXO")+DXT->( DXT_NUMIE+DXT_ITEMIE ) ) )

				If ADB->( dbSeek( xFilial( "ADB" ) + DXO->(DXO_CODCTP) + DXO->(DXO_ITECTP) ) )

					dbSelectArea("SB1")
					dbSetOrder(1)
					MsSeek(xFilial("SB1")+ADB->ADB_CODPRO)

					If nPosEspeci > 0 .And. Empty(aPedido[nPosEspeci,2])
						aPedido[nPosEspeci,2]   := Posicione("SB5",1,xFilial("SB5")+ADB->ADB_CODPRO,"B5_EMB1")
					EndIf

					aAux		:= {}
					cItSC6      := Soma1(cItSC6)

					aAdd(aAux	, {"C6_ITEM"		, cItSC6	  , Nil })
					aAdd(aAux	, {"C6_PRODUTO"	, ADB->ADB_CODPRO , Nil})
					aAdd(aAux	, {"C6_UM"		, SB1->B1_UM	  , Nil })
					aAdd(aAux	, {"C6_QTDVEN"	, DXT->DXT_PSFISC , Nil })
					aAdd(aAux	, {"C6_PRCVEN"	, ADB->ADB_PRCVEN , Nil})
					aAdd(aAux	, {"C6_QTDLIB"	, DXT->DXT_PSFISC , Nil})

					If !Empty(ADB->ADB_TESCOB) .And. Empty(ADB->ADB_PEDCOB)
						aAdd(aAux	, {"C6_TES"	, ADB->ADB_TESCOB	, Nil })
					Else
						aAdd(aAux	, {"C6_TES"	, ADB->ADB_TES	, Nil })
					EndIf

					aAdd(aAux	, {"C6_LOCAL"	, ADB->ADB_LOCAL  , Nil })
					aAdd(aAux	, {"C6_VALDESC"	, ADB->ADB_VALDES , Nil })
					aAdd(aAux	, {"C6_DESCONT"	, ADB->ADB_DESC	  , Nil })
					aAdd(aAux	, {"C6_ENTREG"	, dDataBase		  , Nil })
					aAdd(aAux	, {"C6_PRUNIT"	, ADB->ADB_PRUNIT , Nil })
					aAdd(aAux	, {"C6_CONTRAT"	, ADB->ADB_NUMCTR , Nil })
					aAdd(aAux	, {"C6_ITEMCON"	, ADB->ADB_ITEM	  , Nil })
					aAdd(aAux	, {"C6_CODISS"	, SB1->B1_CODISS  , Nil })
					AADD(aItens,aAux)
				EndIf

			EndIf
			DXT->(dbSkip())
		EndDo

		If ExistBlock("AGR750PV")
			aRetPE := ExecBlock("AGR750PV",.F.,.F.,{aPedido, aItens})

			If ValType(aRetPE) == 'A' .and. Len(aRetPE) == 2
				If ValType(aRetPE[1]) == "A" .AND. Len(aRetPE) > 0
					aPedido := aClone(aRetPE[1])
				EndIf
				If ValType(aRetPE[2]) == "A" .AND. Len(aRetPE) > 1
					aItens := aClone(aRetPE[2])
				EndIf
			EndIf
		Endif

		//*Ordena conforme o dicionário para uso em rotinas de MSExecAuto.
		aPedido 	:= FWVetByDic(aPedido	, 'SC5',	.F. )
		aItens   	:= FWVetByDic(aItens	, 'SC6',	.T.	 )
			
	    /*Necessitamos alterar o modulo para a utilização através do SIGAAGR*/
	    cModulo := "FAT"
	    nModulo := 5

		MsAguarde({||MSExecAuto({ | a, b, c | Mata410( a, b, c ) }, aPedido, aItens, 3)},STR0051,STR0053) //"Aguarde..."###"Gerando pedido de vendas..."

		If lMsErroAuto
			If !IsBlind()
				MostraErro()
			EndIf
			RollBackSX8()
			RestArea(aAreaAtu)
		Else
			ConfirmSX8()
		EndIf
		nModulo := 67            		
	EndIf

	RestArea(aAreaAtu)
Return(!lMsErroAuto)

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA750C
Cancela o Romaneio de Saida

@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA750
------------------------------------------------------------------------------------- **/
Function AGRA750C()
	Local oModel  	 := FwloadModel("AGRA750")
	Local oFldDXS	 := oModel:GetModel("MDFIELDDXS")
	Local oAux		 := Nil 

	Local aRegSD2	 := {}
	Local aRegSE1    := {}
	Local aRegSE2    := {}
	Local aCabPV	 := {}
	Local aItensPV	 := {}
	Local lRet 		 := .T.
	Local nPerc      := 0
	Local lValNF     := .T.
	Local nDesconto  := 0
	Local aTicket

	oModel:SetOperation( 4 )

	If lRet := oModel:Activate()
		If !IsBlind() //Proteç?o para automaç?o
			lRet := Aviso (STR0054,STR0055; //"Aviso"###"O romaneio será inutizado e os movimentos gerados serão estornados!"
			+CRLF+CRLF+STR0056 ,{STR0030,STR0018},1) == 1 //" Deseja realmente cancelar o romaneio?"###"Confirma"###"Cancela"
		Else
			lRet := .T.
		endif
		If lRet
			oAux 		:= oModel:GetModel('MDFIELDDXS')
			cNumDoc	    := oAux:GetValue("DXS_NUMDOC") // Numero do documento do ajuste de estoque
			cNumPV		:= oAux:GetValue("DXS_NUMPED") // Numero do pedido de vendas 
			cNFS		:= oAux:GetValue("DXS_NUMNFS") // Numero do documento de saida
			cSERNFS	    := oAux:GetValue("DXS_SERNFS") // Serie do documento de saida
			lValNF      :=  GetMV("MV_AGRVNFS") // F = não preciso validar a nota fiscal

			BEGIN TRANSACTION
				If lRet .And. !Empty(cNFS)
					if (lValNF)
						SF2->(DbSetOrder(1))//Busca note fiscal
						If !SF2->(DbSeek(xFilial("SF2")+DXS->(DXS_NUMNFS+DXS_SERNFS)))
							Help( , , "ATENÇÃO", , STR0057+DXS->(DXS_NUMNFS+DXS_SERNFS)+STR0058, 1, 0 ) //"Nota "###" nao encontrada "
							lRet := .F.
						endif
						// Validacao da exclusao dos Documentos de Saida
						If lRet .And. !MaCanDelF2("SF2",SF2->(RecNo()),@aRegSD2,@aRegSE1,@aRegSE2)
							Help( , , STR0020, , STR0059, 1, 0 ) //"ATENÇÃO"###"Falha na validação da exclusao da nota"
							lRet := .F.
						EndIf

						If lRet
							// Estorna o documento de saida e deixa o pedido de vendas em carteira
							MsAguarde({||SF2->(MaDelNFS(aRegSD2,aRegSE1,aRegSE2,.F.,.F.,.F.,.T.))},STR0051,STR0060) //"Aguarde..."###"Estonarndo o documento de saída..."				
						EndIf
					Else
						If SF2->(DbSeek(xFilial("SF2")+DXS->(DXS_NUMNFS+DXS_SERNFS)))
							Help( , , "ATENÇÃO", ,STR0073, 1, 0 ) //" Só é possível excluir romaneio com nf excluida "
							lRet := .F.						
						EndIf
					Endif
				EndIf

				//Valida a quantidade programada e atualiza a quantidade embarcada da programação de embarque
				If !A750QTDPRG(2)
					lRet := .F.
				EndIf

				If lRet .And. !Empty(cNumPV)
					SC5->(dbSetOrder(1)) // C5_FILIAL+C5_NUM
					SC6->(dbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
					If SC5->(dbSeek(xFilial("SC5")+cNumPV))

						AADD(aCabPV, { "C5_NUM", cNumPV, Nil } )	

						If SC6->(dbSeek(xFilial("SC6")+cNumPV))
							While( !Eof() .And. cNumPV == SC6->C6_NUM)
								AADD(aItensPV, {})
								AADD(aTail(aItensPV),{ "C6_NUM"		, SC6->C6_NUM	, Nil } )
								AADD(aTail(aItensPV),{ "C6_ITEM"	, SC6->C6_ITEM	, Nil } )
								SC6->(dbSkip())
							End
						EndIf

						Private	lMSErroAuto := .F.
						Private	lMSHelpAuto := .T.

						MsAguarde({||MSExecAuto({|x,y,z|Mata410(x,y,z)}, aCabPV, aItensPV, 5)},STR0051,STR0061) //"Aguarde..."###"Excluindo Pedido de Vendas..."

						If lMSErroAuto
							lRet := .F.
							MostraErro()
							DisarmTransaction()
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Estorna a movimentação de estoque gerada pela romaneio³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lRet .And. !Empty(cNumDoc)
					MsAguarde({||A750GERAD3(6)},STR0051,STR0062) //"Aguarde..."###"Estornando movimentos de estoque..."
				EndIf

				If lRet
					// Desfaz o relacionamento com o pedido de vendas 
					RecLock("DXS",.F.)
					DXS->DXS_NUMNFS 	:=  ""
					DXS->DXS_NUMPED 	:=  ""
					DXS->DXS_NUMDOC 	:=  ""
					DXS->DXS_SERNFS 	:=  ""
					DXS->DXS_STATUS		:= '4' // Cancelado				
					DXS->(MsUnLock())
					If AGRIFDBSEEK("DXT",DXS->DXS_CODIGO,1,.F.)
						WHILE !Eof() .and. Xfilial("DXS") = DXT->DXT_FILIAL .and. DXS->DXS_CODIGO = DXT->DXT_CODIGO
							RECLOCK("DXT", .F.)
							DXT->DXT_BLOCO := ""
							DXT->(MsUnLock())		       
							dbskip()
						ENDDO
					Endif
				EndIf

				// Atualiza o saldo da instrução de embarque
				If lRet
					A750ATUDXO(oModel:GetModel('MDGRIDDXT'), MODEL_OPERATION_DELETE)
				EndIf

				If !Empty(oFldDXS:GetValue("DXS_TICKET"))

					aTicket := SumByTicket(oFldDXS:GetValue("DXS_TICKET"), oFldDXS:GetValue("DXS_CODIGO"), oFldDXS:GetValue('DXS_PSDESC'))
					nTotLiq := aTicket[1]
					nTDesc  := aTicket[2]

					//Atualiza Rateio
					dbSelectArea('DXS')
					dbSetOrder(2)
					If dbSeek(xFilial('DXS') + oFldDXS:GetValue("DXS_TICKET") )

						While !Eof()                      .And.;
						DXS->DXS_FILIAL = xFilial('DXS')  .And.;
						DXS->DXS_TICKET = oFldDXS:GetValue("DXS_TICKET")

								If DXS->DXS_STATUS  = '1'
								nLiqRom := SumByRomaneio(DXS->DXS_CODIGO)

								If DXS->DXS_CODIGO = oFldDXS:GetValue("DXS_CODIGO")

									If RecLock('DXS',.F.)
										DXS->DXS_PSDESC	:= oFldDXS:GetValue( "DXS_PSDESC")
										DXS->DXS_PSBASE := oFldDXS:GetValue( "DXS_PSBASE")
										DXS->DXS_PSLIQU := oFldDXS:GetValue( "DXS_PSLIQU")
										DXS->DXS_PSSUBT := oFldDXS:GetValue( "DXS_PSSUBT")
										MsUnlock()
									Endif
								Else
									nPerc    := (nLiqRom/nTotLiq)*100
									nValDifT := Round((DXS->DXS_PSSUBT - nDesconto - nTotLiq) *(nPerc/100), TamSX3("DXT_PSDIF")[2] )

									dbSelectArea('DXT')
									dbSetOrder(1)
									If dbSeek(xFilial('DXT') + DXS->DXS_CODIGO )
										While !Eof()                     .And.;
										DXT->DXT_FILIAL = xFilial('DXT') .And.;
										DXT->DXT_CODIGO = DXS->DXS_CODIGO

												If RecLock('DXT',.F.)
												DXT->DXT_PSDIF	:= nValDifT
												DXT->DXT_PERC  	:= Round((DXT->DXT_PSLIQU/nLiqRom)*100, TamSX3("DXT_PERC")[2])
												DXT->DXT_PSRAT 	:= Round((DXT->DXT_PSDIF*((DXT->DXT_PSLIQU/nLiqRom)*100))/100, TamSX3("DXT_PSRAT")[2])
												DXT->DXT_PSFISC	:= Round(DXT->DXT_PSLIQU+DXT->DXT_PSRAT, TamSX3("DXT_PSFISC")[2])
												MsUnlock()
											Endif
											dbSkip()
										EndDo
									Endif
								Endif
							Endif

							DbSelectArea('DXS')		
							DbSkip()
						EndDo
					Endif
				Endif
			END TRANSACTION()
		EndIf
	Else
		AutoGrLog( 'Erro'	+ ' [' + AllToChar( oModel:GetErrorMessage()[6] )	+ ']' )
		MostraErro()
	EndIf

	aFardos := {}
	aFdDisp	:= {}
Return()

/*/{Protheus.doc} SumByRomaneio
//Função que sumariza peso liquido por romaneio
@author bruna.rocio
@since 19/06/2017
@version undefined
@param cRomaneio, characters, descricao
@type function
/*/
Static Function SumByRomaneio(cRomaneio)
	Local aArea   := GetArea()
	Local nPsLiqu := 0

	dbSelectArea('DXT')
	dbSetOrder(1)
	If dbSeek(xFilial('DXT') + cRomaneio )
		While !Eof()                     .And.;
				DXT->DXT_FILIAL = xFilial('DXT') .And.;
				DXT->DXT_CODIGO = DXS->DXS_CODIGO

			nPsLiqu += DXT->DXT_PSLIQU
			DbSkip()
		EndDo
	Endif

	RestArea(aArea)
Return nPsLiqu

/*/{Protheus.doc} SumByTicket
//Sumariza o peso liquido total já apontado para o ticket e também o peso total de desconto 
@author bruna.rocio
@since 19/06/2017
@version undefined
@param cTicket, characters, descricao
@param cRomCorrente, characters, descricao
@type function
/*/
Static Function SumByTicket(cTicket, cRomCorrente, nDesCorrente)
	Local aArea      := GetArea()
	Local nPsLiqu    := 0
	Local nDesc      := 0
	Local aTicket    := { 0, 0}
	Local lHasTicket := .F.

	dbSelectArea('DXS')
	dbSetOrder(2)
	If dbSeek(xFilial('DXS') + cTicket )

		While !Eof()                      .And.;
				DXS->DXS_FILIAL = xFilial('DXS')  .And.;
				DXS->DXS_TICKET = cTicket

			If DXS->DXS_CODIGO = cRomCorrente
				lHasTicket := .T.
			Endif

			If DXS->DXS_STATUS  = '1'

				dbSelectArea('DXT')
				dbSetOrder(1)
				If dbSeek(xFilial('DXT') + DXS->DXS_CODIGO )
					While !Eof()                     .And.;
							DXT->DXT_FILIAL = xFilial('DXT') .And.;
							DXT->DXT_CODIGO = DXS->DXS_CODIGO

						nPsLiqu += DXT->DXT_PSLIQU
						DbSkip()
					EndDo
				Endif
			Endif

			nDesc += DXS->DXS_PSDESC

			DbSelectArea('DXS')
			DbSkip()
		EndDo
	Endif

	If .Not. lHasTicket
		nDesc += nDesCorrente
	Endif

	aTicket[1] := nPsLiqu
	aTicket[2] := nDesc

	RestArea(aArea)
Return aTicket

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGR750WHEN()
Validação de edição dos campos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 01/11/2012
@Uso: AGRA750
------------------------------------------------------------------------------------- **/
Function AGR750WHEN()
	Local oModel    := FwModelActive()    
	Local aHeader 	:= oModel:GetModel("MDGRIDDXT"):aHeader
	Local aCols		:= oModel:GetModel("MDGRIDDXT"):aCols
	Local nPosIE	:= aScan(aHeader, {|x| x[2] == "DXT_NUMIE"})  // Instrução de embarque
	Local lRet 		:= .T.        

	If ValType(oModel) <> "o" .And. nPosIE > 0
		lRet := !aScan(aCols, {|x| !Empty(x[nPosIE]) } ) > 0  
	EndIf
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} A750ATUDXO()
Atualiza o saldo da instrução de embarque

@param: oMdlDXT - Modelo de dados da Grid
@param: nOperac - Tipo da Operação: 3 = Inclusão; 4 = Alteração; 5 = Exclusão
@author: Aecio Ferreira Gomes
@since: 27/12/2012
@Uso: AGRA750
------------------------------------------------------------------------------------- **/
Static Function A750ATUDXO(oMdlDXT, nOperac)
	Local nX		 := 0
	Local oModel 	 := oMdlDXT:GetModel()
	Local oMdlDXS    := oModel:GetModel("MDFIELDDXS")

	DXO->(dbSetOrder(1)) //Instrução+Item

	For nX := 1 to oMdlDXT:Length()
		oMdlDXT:GoLine( nX )

		dbSelectArea( "DXI" )
		DXI->(dbGoTop())
		DXI->(dbSetOrder(6))
			
		If DXI->(dbSeek(xFilial("DXI") + PADR(oMdlDXS:GetValue("DXS_CODIGO"),TamSX3("DXI_ROMSAI")[1]) + oMdlDXT:GetValue("DXT_ITEM") ))
			While DXI->(!Eof()) .And. DXI->DXI_FILIAL = xFilial("DXI") .And. Alltrim(DXI->DXI_ROMSAI) = Alltrim(oMdlDXS:GetValue("DXS_CODIGO")) ;
					.and.  Alltrim(DXI->DXI_ITROMS)  = Alltrim(oMdlDXT:GetValue("DXT_ITEM"))  
				RecLock( "DXI", .F. )
				DXI->DXI_ROMSAI := ""
				DXI->DXI_ITROMS := ""
				DXI->(MsUnLock())			
				
				DXI->(dbGoTop())
				DXI->(dbSetOrder(6))
				DXI->(dbSeek(xFilial("DXI")+ PADR(oMdlDXS:GetValue("DXS_CODIGO"),TamSX3("DXI_ROMSAI")[1]) + oMdlDXT:GetValue("DXT_ITEM") ))
					
			EndDo
		EndIf

		DO CASE
			// CASO OPERACAO INCLUIR
		CASE nOperac == MODEL_OPERATION_INSERT
			//Se Linha deletada
			If oMdlDXT:IsDeleted()
				Loop
			EndIf

			// Posiciona no registro da instrução de embarque para atualizar a quantidade embarcada
			If DXO->(dbSeek(xFilial("DXO")+oMdlDXT:GetValue("DXT_NUMIE")+oMdlDXT:GetValue("DXT_ITEMIE")))
				RecLock("DXO",.F.)
				DXO_QTDEMB += oMdlDXT:GetValue("DXT_QUANT")
				MsUnlock()	
			EndIf
			// CASO OPERACAO ALTERAR
		CASE nOperac == MODEL_OPERATION_UPDATE

			// Se Linha nova e estiver deletada
			If oMdlDXT:IsInserted() .And. oMdlDXT:IsDeleted()
				Loop
			EndIf

			// Se não houve manutenção na linha
			If !oMdlDXT:IsInserted() .And. !oMdlDXT:IsDeleted() .And. !oMdlDXT:IsUpdated()
				Loop
			EndIf

			// Posiciona no registro da instrução de embarque
			If DXO->(dbSeek(xFilial("DXO")+oMdlDXT:GetValue("DXT_NUMIE")+oMdlDXT:GetValue("DXT_ITEMIE")))
				DO CASE
					// CASO LINHA NOVA
				CASE oMdlDXT:IsInserted()

					// Atualiza a quantidade embarcada
					RecLock("DXO",.F.)
					DXO_QTDEMB += oMdlDXT:GetValue("DXT_QUANT")
					MsUnlock()	

					// CASO LINHA ALTERADA
				CASE oMdlDXT:IsUpdated()

					// Posiciona no item do romaneio da base de dados
					If DXT->( dbSeek( xFilial("DXT")+oMdlDXS:GetValue("DXS_CODIGO")+oMdlDXT:GetValue("DXT_ITEM") ) )

						// Verifica se houve alteração no codigo da intrução e item da instrucao
						If oMdlDXT:GetValue("DXT_NUMIE")+oMdlDXT:GetValue("DXT_ITEMIE") == DXT->(DXT_NUMIE+DXT_ITEMIE)

							// Se a Linha deletada
							If oMdlDXT:IsDeleted()
								// Atualiza a quantidade embarcada
								RecLock("DXO", .F.)
								DXO_QTDEMB -= DXT->DXT_QUANT
								MsUnlock()
							Else
								// Verifica se houve alteracao na quandidade de fardos vinculados ao item
								If (oMdlDXT:GetValue("DXT_QUANT") - DXT->DXT_QUANT ) <> 0
									// Atualiza a quantidade embarcada
									RecLock("DXO", .F.)
									DXO_QTDEMB += (oMdlDXT:GetValue("DXT_QUANT") - DXT->DXT_QUANT )
									MsUnlock()
								EndIf
							EndIf
						Else
							// Guarda a recno da instrução atual posicionada
							nRecnoDXO := DXO->(Recno())
							// Posiciona na instrução da base de dados  
							If DXO->( dbSeek( xFilial("DXO")+DXT->(DXT_NUMIE+DXT_ITEMIE) ) )
								// Atualiza a quantidade embarcada
								RecLock("DXO", .F.)
								DXO_QTDEMB -= DXT->DXT_QUANT 
								MsUnlock()
							EndIf

							// Volta o posicionamento do registro da instrucao atual
							DXO->(dbGoto(nRecnoDXO)) 
							// Se a Linha não estiver deletada
							If !oMdlDXT:IsDeleted()
								// Atualiza o quantidade embarcada 
								RecLock("DXO",.F.)
								DXO_QTDEMB += oMdlDXT:GetValue("DXT_QUANT")		
								MsUnlock()
							EndIf
						EndIf
					EndIf
					// CASO LINHA DELETADA
				CASE oMdlDXT:IsDeleted()
					// Atualiza quantidade embarcada
					RecLock("DXO",.F.)
					DXO_QTDEMB -= oMdlDXT:GetValue("DXT_QUANT")	
					MsUnlock()	
				ENDCASE
			EndIf
			// CASO OPERACAO EXLUIR
		CASE nOperac == MODEL_OPERATION_DELETE
			// Posiciona no registro da instrução de embarque
			If DXO->(dbSeek(xFilial("DXO")+oMdlDXT:GetValue("DXT_NUMIE")+oMdlDXT:GetValue("DXT_ITEMIE")))
				//Atualiza a quantidade embarcada
				RecLock("DXO",.F.)
				DXO_QTDEMB -= oMdlDXT:GetValue("DXT_QUANT")
				MsUnlock()	
			EndIf

		ENDCASE
	Next nX

Return()

/** -------------------------------------------------------------------------------------
{Protheus.doc} A750QTDPRG(nOpc)
Valida a quantidade programada e atualiza a quantidade embarcada da programação;
de embarque

@param: nOpc - 1 = Preparação do documento de saída; 2 = Cancelamento do romaneio
@author: Aecio Ferreira Gomes
@since: 28/12/2012
@Uso: AGRA750
------------------------------------------------------------------------------------- **/
Function A750QTDPRG(nOpc)
	Local aAreaDXT  := DXT->(GetArea())
	Local lRet      := .T.
	Local lProgEmbq := .T.

	//Programação de Embarque
	lProgEmbq  := GETMV("MV_AGREMBQ")
	If lProgEmbq
		DXT->(dbSetOrder(1))
		DXR->(dbSetOrder(1))
		DXT->(dbSeek(xFilial("DXT")+DXS->DXS_CODIGO))

		While DXT->(!Eof() .And. DXT_CODIGO == DXS->DXS_CODIGO)

			If DXO->( dbSeek( xFilial("DXO")+DXT->( DXT_NUMIE + DXT_ITEMIE ) ) )
				If DXQ->( dbSeek( xFilial("DXQ")+DXO->( DXO_CODRES + DXO_ITEMRS ) ) )
					If DXP->( dbSeek( xFilial("DXP")+DXO->DXO_CODRES ) )

						cAliasQry := GetNextAlias()

						cQry := "SELECT DXR_QTDPRG 	AS QTDPRG, DXR_QTDEMB 	AS QTDEMB, DXR_ITEMCT"
						cQry += "FROM "+RetSqlName("DXR")+ " DXR "
						cQry += "WHERE DXR_FILIAL 	= '"+xFilial("DXR")+"' "
						cQry += "AND DXR_CODCTR 	= '"+DXP->DXP_CODCTP+"' "
						cQry += "AND DXR_ITEMCT 	= '"+DXP->DXP_ITECTP+"' "
						cQry += "AND DXR_ANO 		= '"+Alltrim(STR(YEAR(DXS->DXS_DATA)))+"' "
						cQry += "AND DXR_MES 		= '"+Alltrim(STR(MONTH(DXS->DXS_DATA)))+"' "
						cQry += "AND DXR.D_E_L_E_T_ = '' "

						cQry := ChangeQuery( cQry ) 

						dbUseArea( .T., "TOPCONN", TcGenQry( , , cQry ), cAliasQry, .F., .T. )

						If (cAliasQry)->(Eof())
							lRet := .F.
							Help("",1,"NAOPROG",,STR0068,1) //"Não foi localizado nenhuma programação de embarque para a data do romaneio"
							Exit
						EndIf

						If lRet .And. nOpc == 2
							Reclock("DXR", .F.)
							DXR->DXR_QTDEMB +=  -DXT->DXT_PSFISC
							DXR->(Msunlock())
						EndIf

						If lRet .And. nOpc == 1 .And. ((cAliasQry)->QTDEMB + DXT->DXT_PSFISC) > (cAliasQry)->QTDPRG
							lRet := .F.
							Help("",1,"QTDEPROG",,STR0063+DXT->DXT_ITEM+STR0064+(cAliasQry)->DXR_ITEMCT+STR0067,1)			 //"A soma da quantidade entregue mais a quantidade do item [ "###" ] é maior que a quantidade programada do item  [ "###" ] do contrato para este periodo"
							Exit
						EndIf

						If lRet .AND. nOpc == 1 .And. DXR->(dbSeek(xFilial("DXR")+DXS->DXS_CODCTP+(cAliasQry)->DXR_ITEMCT))
							Reclock("DXR", .F.)
							DXR->DXR_QTDEMB +=  DXT->DXT_PSFISC
							DXR->(Msunlock())
						EndIf
					EndIf
				EndIf
			EndIf
			DXT->(dbSkip())	
		EndDo
	Endif
	RestArea(aAreaDXT)
Return(lRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} A750QTDFD
Retorna a quantidade fardos vinculados ao item do romaneio

@param: cRomaneio = Número do romaneio de saída
@param: cItemR = Item do romaneio de saída
@author: Aecio Ferreira Gomes
@since: 23/04/2013
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Static Function A750QTDFD(cRomaneio, cItemR)
	Local nRet	:= 0

	BeginSql Alias "QryDXI"
		Select
		COUNT(DXI_ETIQ) AS QTDFDI
		From
		%table:DXI% DXI
		Where
		DXI.DXI_FILIAL = %xFilial:DXI% AND
		DXI.DXI_ROMSAI = %exp:cRomaneio% AND
		DXI.DXI_ITROMS = %exp:cItemR% AND
		DXI.%NotDel%
	EndSql

	nRet := QTDFDI

	QryDXI->(dbCloseArea())
Return(nRet)

/** -------------------------------------------------------------------------------------
{Protheus.doc} AGRA750CPO()
Validações de Campos

@author: Aecio Ferreira Gomes
@since: 24/04/2013
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Function AGRA750CPO()
	Local oModel 		:= FwModelActive()
	Local oMdGridDXT	:= oModel:GetModel("MDGRIDDXT")
	Local oFldDXS    	:= oModel:GetModel("MDFIELDDXS")
	Local aLines		:= FwSaveRows()	
	Local lRet 			:= .T.
	Local lUsado    	:= .F.
	Local nPsBruT1  	:= 0
	Local nPsLiqT1  	:= 0

	DO CASE
	CASE ("DXT_NUMIE" $ ReadVar())

		oMdGridDXT:LoadValue("DXT_SAFRA",FwFldGet('DXS_SAFRA'))
		oMdGridDXT:LoadValue("DXT_ITEMIE", CriaVar("DXT_ITEMIE"))
		oMdGridDXT:LoadValue("DXT_TIPO"	 , CriaVar("DXT_TIPO"))
		oMdGridDXT:LoadValue("DXT_BLOCO" , CriaVar("DXT_BLOCO"))		

		If FUNNAME() = "AGRA751"
			oMdGridDXT:SetValue('DXT_QUANT',FwFldGet("DXS_PESO2") - FwFldGet("DXS_PESO1"))
		Endif
		
	CASE ("DXS_PESO1" $ ReadVar())
		// Atualiza o peso líquido da carga
		If FwFldGet("DXS_PESO2") > 0
			If FwFldGet("DXS_PESO2") > FwFldGet("DXS_PESO1")
				FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO2") - FwFldGet("DXS_PESO1") ) )
			Else
				FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO1") - FwFldGet("DXS_PESO2") ) )
			EndIf

			FwFldPut( "DXS_PSBASE", ( FwFldGet("DXS_PSSUBT") - FwFldGet("DXS_PSDESC") ) )
			FwFldPut( "DXS_PSLIQU", (  FwFldGet("DXS_PSSUBT") - (FwFldGet("DXS_PSDESC")  + FwFldGet("DXS_PSEXTR" ) ) ) )
			// Atualiza rateio do peso da carga entre os itens do romaneio
			Rateio(oMdGridDXT)
		EndIf
	CASE ("DXS_PESO2" $ ReadVar())
		// Atualiza o peso líquido da carga
		If FwFldGet("DXS_PESO2") > FwFldGet("DXS_PESO1")
			FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO2") - FwFldGet("DXS_PESO1")  ) )
		Else
			FwFldPut( "DXS_PSSUBT", ( FwFldGet("DXS_PESO1") - FwFldGet("DXS_PESO2")  ) )
		EndIf

		FwFldPut( "DXS_PSBASE", ( FwFldGet("DXS_PSSUBT") - FwFldGet("DXS_PSDESC") ) )
		FwFldPut( "DXS_PSLIQU", ( FwFldGet("DXS_PSSUBT") - (FwFldGet("DXS_PSDESC")  + FwFldGet("DXS_PSEXTR") ) ) )

		// Atualiza rateio do peso da carga entre os itens do romaneio
		Rateio(oMdGridDXT)	
	CASE ("DXS_TICKET" $ ReadVar())

		dbSelectArea('DXS')
		dbSetOrder(2)
		If dbSeek(xFilial('DXS') + oFldDXS:GetValue("DXS_TICKET") )

			While !Eof()                      .And.;
			DXS->DXS_FILIAL = xFilial('DXS')  .And.;
			DXS->DXS_TICKET = oFldDXS:GetValue("DXS_TICKET")

					If DXS->DXS_STATUS <> '1'
					lUsado := .T.
				Endif

				If DXS->DXS_STATUS = '1' //somente romaneios abertos
					dbSelectArea('DXT')
					dbSetOrder(1)
					If dbSeek(xFilial('DXT') + DXS->DXS_CODIGO )
						While !Eof()                     .And.;
						DXT->DXT_FILIAL = xFilial('DXT') .And.;
						DXT->DXT_CODIGO = DXS->DXS_CODIGO

							nPsBruT1 +=	DXT->DXT_PSBRUT
							nPsLiqT1 += DXT->DXT_PSLIQU	

							DbSkip()
							EndDo
					Endif
				Endif

				dbSelectArea('DXS')	
				DbSkip()
			EndDo
		Endif

		If lUsado .And. !Empty(oFldDXS:GetValue("DXS_TICKET"))
			Help(,,STR0020,, STR0082,1,0) //"Atenção"##"Ticket não pode ser utilizado. Todos os romaneios associados ao tickets devem estar abertos ou estornados.!"
			lRet := .F.
		Endif

		If !Empty(oFldDXS:GetValue("DXS_TICKET"))
			// Verifica se a pesagem pertence a algum romaneio	
			lRet := !A750TICKET(oFldDXS:GetValue("DXS_TICKET"))

			// Valida status da pesagem
			If lRet
				If (lRet := DX9->( dbSeek( xFilial("DX9")+oFldDXS:GetValue("DXS_TICKET") ) ) )
					If !(lRet := DX9->DX9_STATUS == "3")
						Help(,,STR0020,,STR0083,1,0) //"Atenção"##"A pesagem informada não foi finalizada!"
					EndIf
				Else
					Help(,,"REGNOIS")
				EndIf
			EndIf
		EndIf

	CASE ("DXS_CODCTP" $ ReadVar())
		ADA->(dbSetOrder(1)) // Filial + Contrato
		ADA->(dbSeek(xFilial("ADA")+ FwFldGet("DXS_CODCTP")))

		lRet := FwFldGet( "DXS_CODCTP" ) + FwFldGet( "DXS_CLIENT" ) + FwFldGet( "DXS_LJCLI" ) + FwFldGet( "DXS_SAFRA" ) == ;
		ADA->ADA_NUMCTR          + ADA->ADA_CODCLI          + ADA->ADA_LOJCLI         + ADA->ADA_CODSAF
	ENDCASE

	FwRestRows(aLines)
Return(lRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA750FIE()
Filtro da instrução de embarque para a consulta padrão DXODXT

@param: Nil
@author: Aecio Ferreira Gomes
@since: 30/04/2013
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Function AGRA750FIE()
	Local cRet 		:= ""

	cRet  := "@#DXO_CODCTP == '" + M->DXS_CODCTP + "' .And. DXO_SAFRA == '" + M->DXS_SAFRA +"'@#"
Return(cRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} A750VLPERC()
Valida o percentual de rateio da carga entre os itens

@param: oMdGridDXT	- Modelo de dados da grid
@param: cAction		- Ação da linha (Pre-Validação da linha)
@author: Aecio Ferreira Gomes
@since: 06/05/2013
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Static Function A750VLPERC(oMdGridDXT, cAction)
	Local lRet	:= .T.
	Local nCont	:= 0
	Local nPerc	:= 0
	Local nX	:= 0

	Default cAction = ""

	If cAction == "UNDELETE"
		nPerc += oMdGridDXT:GetValue("DXT_PERC")
	EndIf

	// Soma o percentual de rateio
	For nX := 1 To oMdGridDXT:Length()
		oMdGridDXT:Goline(nX)
		If oMdGridDXT:IsDeleted()
			Loop
		EndIf

		// Valida o preenchimento do campo DXT_NUMIE para indicar que a linha foi preenchida
		If !Empty( oMdGridDXT:GetValue("DXT_NUMIE") )
			nCont++
		EndIf
		nPerc += oMdGridDXT:GetValue("DXT_PERC")
	Next nX

	If nCont > 0
		If (nPerc == 0)
			Rateio(oMdGridDXT)
		Else
			IF !(lRet := (nPerc == 100))
				Help(,,STR0020,,STR0071,1,0) //"###Atenção"###""O percentual de rateio da carga não pode ser diferente de 100%"###" "
			EndIf
		EndIf
	EndIf

Return(lRet)


/**-------------------------------------------------------------------------------------
{Protheus.doc} A750TICKET()
Indica se o ticket de pesagem está vinculado a algum romaneio 

@param: cTicket	- Código identificador da pesagem avulsa
@author: Aecio Ferreira Gomes
@since: 06/05/2013
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Static Function A750TICKET(cTicket)
	Local aArea			:= GetArea()
	Local lRet	  		:= .F.
	Local lUsado  		:= .F.
	Local nPs     		:= 0
	Local nSaldo  		:= 0
	Local nSubTot 		:= 0
	Local cQuery  		:= ""
	Local cAliasDXS		:= GetNextAlias()	
	
	//Realiza a contagem de registros com o Filial + Ticket + Status 2 (Em pedido de venda) ou 3 (Encerrado)
	cQuery	:= "SELECT min(DXS.R_E_C_N_O_) DXSRecNo "+ CRLF
	cQuery	+= "FROM " + RetSQLName('DXS') + ' DXS' + CRLF
	cQuery	+= "WHERE DXS.DXS_FILIAL ='" + FWxFilial('DXS') + "' AND" + CRLF
	cQuery	+= "DXS.DXS_TICKET ='" + cTicket + "' AND" + CRLF
	cQuery	+= "DXS.DXS_STATUS IN ( '2', '3')"
	DbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cAliasDXS, .T., .T.)
	If ( cAliasDXS )->( DXSRecNo > 0 )
		lUsado := .T.
	EndIf
	(cAliasDXS)->(DbCloseArea())

	BeginSql Alias "QryDXS"
		Select DXS.DXS_TICKET
		,SUM(DXS.DXS_PSSUBT) DXS_PSSUBT
		,SUM(DXT.DXT_PSBRUT) DXT_PSBRUT From %Table:DXS% DXS
		Inner Join %Table:DXT% DXT
		On DXT.%notDel%
		And DXT.DXT_FILIAL = %xFilial:DXT%	
		And DXT.DXT_CODIGO = %exp:DXS->DXS_CODIGO%
		Where DXS.%notDel%
		and DXS.DXS_FILIAL = %xFilial:DXS%
		and DXS.DXS_TICKET = %exp:cTicket% 
		and DXS.DXS_STATUS != %exp:'4'% 
		GROUP BY DXS.DXS_TICKET
	EndSql
	QryDXS->(DbGoTop())
	If QryDXS->(!Eof())
		nSubTot := QryDXS->DXS_PSSUBT
		nPs := QryDXS->DXT_PSBRUT
	EndIf
	QryDXS->(dbCloseArea())
	//Calcula saldo do ticket
	nSaldo := nSubTot - nPs

	If lUsado .OR. nSaldo <= 0
		BeginSql Alias "QryDXS"
			Select
			DXS.*
			From
			%table:DXS% DXS
			Where
			DXS.DXS_FILIAL = %xFilial:DXS% AND
			DXS.DXS_TICKET = %exp:cTicket% AND
			DXS.DXS_STATUS <> %exp:"4"% AND
			DXS.%NotDel%
			Order By
			DXS.DXS_CODIGO
		EndSql

		QryDXS->( dbGotop() )
		lRet := QryDXS->( !Eof() )
		QryDXS->( dbCloseArea( ) )
	Endif

	RestArea(aArea)
Return(lRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA750FPS()
Filtro da pesagem avulsa

@author: Aecio Ferreira Gomes
@since: 06/05/2013
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Function AGRA750FPS()
	Local cFilter	:= ""

	cFilter	+= "@"
	cFIlter += " DX9_STATUS = '3' AND"
	cFilter	+= " Not Exists ("
	cFilter	+= " SELECT * "
	cFilter	+= " FROM " + RetSQLName('DXS') + " DXS"
	cFilter	+= " WHERE DXS.DXS_FILIAL ='" + FWxFilial('DXS') + "' AND"
	cFilter	+= " DXS.DXS_TICKET = DX9_CODIGO AND"
	cFilter	+= " DXS.DXS_STATUS IN ( '2', '3'))"
	
	
Return(cFIlter)

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA750M()
Função de Manutenção 

@author: 
@since:  
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Function AGRA750M()
	FWExecView('Manutenção','AGRA750', MODEL_OPERATION_UPDATE, , { || .t. }, , 0 )

	If !Empty(DXS->DXS_NUMPED)
		AGRA750P()
	Else
		Help("",1,STR0020,,STR0099,1) 
	Endif
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} AGRA750NFS()
Função AGRA750NFS

@author: 
@since:  
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Function AGRA750NFS(oDXS)
	Local aAreaAtu := GetArea()
	Local cPedido  := oDXS:GetValue("DXS_NUMPED")

	SC5->(dbSetOrder(1))
	If SC5->(dbSeek(xFilial("SC5") + cPedido))
		If .Not. Empty(Alltrim(SC5->(C5_NOTA)))

			If ( DXS->(DXS_CLIENT) + DXS->(DXS_LJCLI ) ) = ( SC5->(C5_CLIENTE) + SC5->(C5_LOJACLI) )
				//Verifica se o Pedido de Venda não foi gerado ou relacionado com outro Romaneio
				If Select("QryDXS") > 0
					QryDXS->( dbCloseArea() )
				Endif

				BeginSql Alias "QryDXS"
					Select
					DXS.DXS_CODIGO
					From
					%table:DXS% DXS
					Where
					DXS.DXS_FILIAL = %xFilial:DXS% AND
					DXS.DXS_NUMPED = %exp:cPedido% AND
					DXS.DXS_STATUS <> %exp:"4"%  
					DXS.%NotDel%
				EndSql

				QryDXS->( dbGotop() )

				If  .Not. QryDXS->( Eof() )
					lRet := .f.
					MsgInfo(STR0084 + QryDXS->( DXS_CODIGO ) ) //"O Pedido de Venda informado está relacionado com o Romaneio "
				Else
					oDXS:LoadValue("DXS_NUMNFS", SC5->(C5_NOTA))
					oDXS:LoadValue("DXS_SERNFS", SC5->(C5_SERIE))
				EndIf

				QryDXS->( dbCloseArea() )
			Else
				lRet := .f.
				MsgInfo(STR0085) //"Verifique se o Pedido de Venda informado, pois o mesmo não é do cliente do Romaneio."
			Endif
		Else
			lRet := .f.
			MsgInfo(STR0086) //"Verifique se o Pedido de Venda informado, pois o mesmo não foi faturado."
		Endif
	Else
		lRet := .f.
		MsgInfo(STR0087) //"Verifique se o Pedido de Venda informado existe."
	Endif
	RestArea(aAreaAtu)
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} LoadFardos()
Carrega em Array os fardos pertencentes a Reserva e os fardos pertencentes ao bloco
informado no item da reserva que estÃ£o livres

@param: oMdGridDXQ - Modelo de dados da Grid
@author: Aecio Ferreira Gomes
@since: 12/04/2013
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function LoadFardos(oModel)
	Local aArea		 := GetArea()
	Local oMdlDXT	 := oModel:GetModel("MDGRIDDXT")
	Local oMdlDXS    := oModel:GetModel("MDFIELDDXS")
	Local aSaveLines := FWSaveRows()
	Local cCodRom	 := ""
	Local cIteRom	 := ""
	Local cCodIE	 := ""
	Local cCodTip	 := ""
	Local cCodBlq	 := ""
	Local lRet		 := .T.
	Local nX
	Local nSavLine  := oMdlDXT:nLine 

	aFardos := {}
	aFdDisp := {}

	For nX := 1 To oMdlDXT:Length()
		oMdlDXT:GoLine(nX)

		cCodRom := oMdlDXS:GetValue("DXS_CODIGO")
		cIteRom := oMdlDXT:GetValue("DXT_ITEM")
		cCodIE 	:= oMdlDXT:GetValue("DXT_NUMIE")
		cIteIE 	:= oMdlDXT:GetValue("DXT_ITEMIE")
		cCodTip := oMdlDXT:GetValue("DXT_TIPO")
		cCodBlq := oMdlDXT:GetValue("DXT_BLOCO")

		If !Empty( cCodTip ) .And. !Empty( cCodBlq ) .And. !Empty( cCodIE )
			CarFardos(oModel, cCodRom, cIteRom, cCodIE, cIteIE )
		endif
	Next nX

	oMdlDXT:GoLine(nSavLine)
	RestArea( aArea )
	FWRestRows( aSaveLines )
Return(lRet)

/**-------------------------------------------------------------------------------------
{Protheus.doc} A720ACTIVE
ValidaÃ§Ã£o apÃ³s ativaÃ§Ã£o do modelos de dados

@param: oModel - Modelo de dados
@author: Maicol Lange
@since: 19/08/2015
@Uso: AGRA720
-------------------------------------------------------------------------------------**/
Static Function A750ACTIVE(oModel)
	//---------------------------------------------------
	// Carrega em um array os fardos vinculados a reserva
	//---------------------------------------------------
	LoadFardos(oModel)
Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} GeraPedV
ValidaÃ§Ã£o apÃ³s ativaÃ§Ã£o do modelos de dados

@param: oModel - Modelo de dados
@author: Felipe Mendes
@since: 19/06/2022
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Static Function GeraPedV()
Local  lRet := .T.

	BEGIN TRANSACTION
		//Valida e atualiza a quantidade da programação de embarque 
		If (lRet := A750QTDPRG(1))

			//Faz ajuste de estoque antes de gerar o pedido de vendas
			If (lRet := A750GERAD3())

				_cNumPV := GetSXENum( "SC5", "C5_NUM" )

				// Inclusão do pedido de vendas
				If (lRet := IncluiPV(_cNumPV))
					If DXS->( RecLock("DXS", .F.) )
						DXS->DXS_NUMPED := _cNumPV
						DXS->DXS_STATUS := '2'
						DXS->(MsUnLock())
					EndIf
				EndIf
			EndIf
		EndIf

		If !lRet
			DisarmTransaction()
		EndIf
	END TRANSACTION()

Return lRet

/**-------------------------------------------------------------------------------------
{Protheus.doc} BuscaDocSaida
ValidaÃ§Ã£o apÃ³s ativaÃ§Ã£o do modelos de dados

@param: oModel - Modelo de dados
@author: Felipe Mendes
@since: 19/06/2022
@Uso: AGRA750
-------------------------------------------------------------------------------------**/
Static Function BuscaDocSaida()
Local lEstorno := .F.
Local lPedVenda := .F.
Local lMovimento := .F.
Local lDocSaida := .F.
	
	//Verifica se há documento de saida
	DbSelectArea("SF2")
	DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  
	If !Empty(DXS->DXS_NUMNFS) .AND. DbSeek(xFilial("SF2")+DXS->DXS_NUMNFS+DXS->DXS_SERNFS)
		lDocSaida := .T.
	else
		 //Se encontrar Documento saida retorna true
		If DXS->( RecLock("DXS", .F.) )
			DXS->DXS_NUMNFS := ''
			DXS->DXS_SERNFS := ''			
			DXS->(MsUnLock())
		EndIf		
	EndIf
	
	//verifica se há pedidos de venda
	DbSelectArea("SC5") //Verifica se tem pedido de venda
	DbSetOrder(1)//C5_FILIAL+C5_NUM                                                                                                                                                
	If !Empty(DXS->DXS_NUMPED) .AND. DbSeek( xFilial("SC5")+ DXS->DXS_NUMPED ) 
		lPedVenda := .T.	
	Else	
		If DXS->( RecLock("DXS", .F.) )
			DXS->DXS_NUMPED := ''		
			DXS->(MsUnLock())
		EndIf		
	EndIf

	//Verifica se há movimentos internos e se o mesmo está estornado
	DbSelectArea("SD3")
	DbSetOrder(2)
	If !Empty(DXS->DXS_NUMDOC) .AND. DbSeek(xFilial("SD3") + DXS->DXS_NUMDOC)
		lEstorno := .F.
		lMovimento := .T.
		While !(SD3->(Eof())) .AND. xFilial("SD3") + DXS->DXS_NUMDOC == SD3->D3_FILIAL + SD3->D3_DOC 
			If SD3->D3_ESTORNO $ "S"
				lEstorno := .T.
				lMovimento := .F.
			EndIf			
			SD3->(DbSkip())
		Enddo

		If lEstorno .AND. DXS->( RecLock("DXS", .F.) )
			DXS->DXS_NUMDOC := ''
			DXS->(MsUnLock())
		EndIf
	EndIf

	If DXS->( RecLock("DXS", .F.) )
		If lDocSaida // Tem doc saida
			DXS->DXS_STATUS := '3'
		elseif lPedVenda .OR. (lMovimento .AND. !lEstorno) //Tem pedido de venda ou movimentos sem estorno
			DXS->DXS_STATUS := '2'
		Else 
			DXS->DXS_STATUS := '1'
		endIf
		DXS->(MsUnLock())

	EndIf	

Return 
