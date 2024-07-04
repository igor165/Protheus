#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSMGER.CH"
#INCLUDE "FWCALENDARWIDGET.CH"
#DEFINE ARQ_LOG_COR		"correcao_codope.log"

#DEFINE PB3DVCTO	01
#DEFINE PB3DREFERE	02
#DEFINE PB3DOBRDES	03
#DEFINE PB3DCODOPE	04
#DEFINE PB3DCDOBRI	05
#DEFINE PB3DCODIGO	06

#DEFINE CAMPO	01
#DEFINE TIPO	02
#DEFINE TAMANHO	03
#DEFINE DECIMAL	04

#DEFINE OBR_SIP 		"1"
#DEFINE OBR_SIB 		"2"
#DEFINE OBR_DIOPS	 	"3"

#DEFINE FINALIZADO	"6"

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC de dados para o conjunto B3A, B3U, B3C e B3D

@return oModel	objeto model criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	// Cria as estruturas a serem usadas no Modelo de Dados
	Local oStruB3A 		:= FWFormStruct( 1, 'B3A' )
	Local oStruB3U 		:= FWFormStruct( 1, 'B3U' )
	Local oStruB3C 		:= FWFormStruct( 1, 'B3C' )
	Local oStruB3D 		:= FWFormStruct( 1, 'B3D' )
	Local oModel // Modelo de dados construído

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New( 'PLSMVCCENTRAL' )

	// Adiciona ao modelo um componente de formulário
	oModel:AddFields( 'B3AMASTER', /*'B3ASLAVE'*/ , oStruB3A )
	//oModel:AddGrid( 'B3AMASTER', 'B3ASLAVE' , oStruB3A )
	// Adiciona ao modelo componente de grid
	oModel:AddGrid( 'B3UDETAIL', 'B3AMASTER', oStruB3U )
	oModel:AddGrid( 'B3CDETAIL', 'B3AMASTER', oStruB3C )
	oModel:AddGrid( 'B3DDETAIL', 'B3AMASTER', oStruB3D )

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'B3UDETAIL',  { 	{ 'B3U_FILIAL', 'xFilial( "B3U" )' },;
		{ 'B3U_CODOPE' , 'B3A_CODOPE' },;
		{ 'B3U_CDOBRI' , 'B3A_CODIGO' };
		}, B3U->( IndexKey( 1 ) ) )

	oModel:SetRelation( 'B3CDETAIL',  { 	{ 'B3C_FILIAL', 'xFilial( "B3U" )' },;
		{ 'B3C_CODOPE' , 'B3A_CODOPE' },;
		{ 'B3C_CDOBRI' , 'B3A_CODIGO' };
		}, B3C->( IndexKey( 1 ) ) )

	oModel:SetRelation( 'B3DDETAIL',  { 	{ 'B3D_FILIAL', 'xFilial( "B3U" )' },;
		{ 'B3D_CODOPE' , 'B3A_CODOPE' },;
		{ 'B3D_CDOBRI' , 'B3A_CODIGO' };
		}, B3D->( IndexKey( 1 ) ) )

	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Obrigações' )

	// Adiciona a descrição dos Componentes do Modelo de Dados
	oModel:GetModel( 'B3AMASTER' ):SetDescription( " Obrigações " )
	oModel:GetModel( 'B3UDETAIL' ):SetDescription( " Contatos da Obrigação " )
	oModel:GetModel( 'B3CDETAIL' ):SetDescription( " Configuração dos Compromissos " )
	oModel:GetModel( 'B3DDETAIL' ):SetDescription( " Compromissos " )

	// Retorna o Modelo de dados
Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela B3A

@return oView	objeto view criado

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de dados baseado no ModelDef do fonte informado
	Local oModel := FWLoadModel( 'PLSMVCCENTRAL' )

	// Cria as estruturas a serem usadas na View
	Local oStruB3A 			:= FWFormStruct( 2, 'B3A' )
	// Interface de visualização construída
	Local oView

	oView := FWFormView():New()

	// Define qual Modelo de dados será utilizado
	oView:SetModel( oModel )

	// Adiciona no nosso View um controle do tipo formulário (antiga Enchoice)
	oView:AddField( 'VIEW_B3A', oStruB3A, 'B3AMASTER' )

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	//Cria as Folders
	oView:CreateFolder( 'PASTA_INFERIOR' ,'INFERIOR' )

	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_B3A', 'SUPERIOR' )

	// Retorna o objeto de View criado
Return oView

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPnlSIB

Tela principal da Central de Obrigacoes filtrada apenas para o SIB

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CenPnlSIB()

	Local cFiltro := " B3A_FILIAL = xFilial( 'B3A' ) .AND. " +;
		" B3A_TIPO = '" + OBR_SIB + "' "

	PLSCENTOBR(cFiltro)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPnlSIB

Tela principal da Central de Obrigacoes filtrada apenas para o SIP

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CenPnlSIP()

	Local cFiltro := " B3A_FILIAL = xFilial( 'B3A' ) .AND. " +;
		" B3A_TIPO = '" + OBR_SIB + "' "

	PLSCENTOBR(cFiltro)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenPnlSIB

Tela principal da Central de Obrigacoes filtrada apenas para o DIOPS

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function CenPnlDIOPS()

	Local cFiltro := " B3A_FILIAL = xFilial( 'B3A' ) .AND. " +;
		" B3A_TIPO = '" + OBR_DIOPS + "' "

	PLSCENTOBR(cFiltro)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSCENTOBR

Tela principal da Central de Obrigacoes

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLSCENTOBR(cFiltroObr)
	Local aCoors 	:= FWGetDialogSize( oMainWnd )
	Local aEval 	:= {}
	Local nCampos 	:= 0
	Local oFWLayerLeft
	Local oPnlLft
	Local oPnlRgt
	Local oBrowseUp
	Local oBrowseDown
	Local oRelacB3D
	Local objCENFUNLGP := CENFUNLGP():New()
	Local aSeek := addSeek()
	private B8MN  := ""
	private B8MM  := ""
	private B8MS  := ""
	Private oDlgPrinc
	private nRegB3A := B3A->(RECCOUNT())

	Default cFiltroObr :=  " B3A_FILIAL = xFilial( 'B3A' ) "

	B3D->(dbSetOrder(2))
	// Função para carregar o cadastro de Operadoras do sistema PLS para a Central, caso exista.
	If BA0->(FieldPos("BA0_FLGCEN")) .And. Select("B2R") > 0
		Processa( { || lOk := PLLOADOPER() },'Aguarde','Importanto Operadoras de Saúde do PLS',.F.)
	EndIf
	//Comentado até subir o ajuste dos relacionamentos das tabelas
	//Processa( { || lOk := atuOperaMov() },'Aguarde','Corrigindo código da Operadora de Saúde nas movimentações SIB',.F.)
	//Processa( { || lOk := corHisBloq() },'Aguarde','Corrigindo a chave dos históricos de bloqueio',.F.)

	//Essa função verifica se os compromissos do ano já foram gerados e cria os compromissos, se necessário.
	If Month(dDataBase) >= 10
		Processa( { || lOk := PLLOADCOMP() },'Aguarde','Criando compromissos do ano seguinte',.F.)
	EndIf
	//Função criada para finalizar compromissos do SIB que já passaram do vencimento
	Processa( { || lOk := PlAtuStaCo() },'Aguarde','Finalizando compromissos do SIB vencidos.',.F.)

	Define MsDialog oDlgPrinc Title 'Central de Obrigações' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	//Cria o conteiner
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	//Crio a linha principal da tela
	oFWLayer:AddLine( 'LINE', 100, .F. )
	//Divido a linha em 2 colunas.. a esquerda ficarão os grids e a direita a agenda
	oFWLayer:AddCollumn( 'COLLEFT', 70, .T., 'LINE' )
	oFWLayer:AddCollumn( 'COLRIGHT', 30, .T., 'LINE' )

	//pega o objeto da coluna da esqueda
	oPnlLft := oFWLayer:GetColPanel( 'COLLEFT', 'LINE' )
	//pega o objeto da coluna da direita
	oPnlRgt := oFWLayer:GetColPanel( 'COLRIGHT', 'LINE' )

	//
	// Cria um conteiner para cada coluna
	//
	oFWLayerLeft := FWLayer():New()
	oFWLayerLeft:Init( oPnlLft, .F., .T. )
	oFWLayerRight := FWLayer():New()
	oFWLayerRight:Init( oPnlRgt, .F., .T. )

	//
	// Lado Direito Calendário
	//

	//Cria a linha do lado direito
	oFWLayerRight:AddLine( 'LINEDOWNRIGHT', 100, .F. )
	//Uma coluna de 100%
	oFWLayerRight:AddCollumn( 'COLDOWN' , 100, .T., 'LINEDOWNRIGHT' )

	oPnlRgtDown := oFWLayerRight:GetColPanel( 'COLDOWN' , 'LINEDOWNRIGHT' ) // Pego o objeto do pedaço esquerdo

	oBrwVcto:= FWmBrowse():New()
	oBrwVcto:SetOwner( oPnlRgtDown )

	aCampos := RetornaCampos()
	oTmpTab := CriaTabTemp('VCTOB3D',aCampos,"01",{"B3D_VCTO"})
	If BuscaVctos()
		CarregaArqTmp()
	EndIf
	oBrwVcto:SetDescription( "Próximos Vctos." )
	oBrwVcto:SetAlias( oTmpTab:getAlias() )
	oBrwVcto:SetMenuDef( '' )
	// LGPD ------------------
	if objCENFUNLGP:isLGPDAt()
		For nCampos := 1 To Len(aCampos)
			aAdd(aEval, aCampos[nCampos][1])
		Next nCampos
		oBrwVcto:SetObfuscFields(objCENFUNLGP:fieldsInList(aEval))
	EndIf
	//------------------------
	oBrwVcto:SetFields(montaFields(aCampos,'VCTOB3D'))
	oBrwVcto:SetProfileID( 'VCT1' )
	oBrwVcto:DisableDetails()
	oBrwVcto:SetWalkthru(.F.)
	oBrwVcto:SetAmbiente(.F.)
	oBrwVcto:Activate()

	//
	// Divide a coluna da esquerda em 2. Em cima ficarão as Obrigações e embaixo ficarão os compromissos
	//
	oFWLayerLeft:AddLine( 'LEFTUP', 35, .F. )
	oFWLayerLeft:AddLine( 'LEFTDOWN', 65, .F. )
	//Para cada nova linha é necesário criar uma nova coluna. Nesse caso de 100%
	oFWLayerLeft:AddCollumn( 'COLTOP', 100, .T., 'LEFTUP' )
	oFWLayerLeft:AddCollumn( 'COLDOWN' , 100, .T., 'LEFTDOWN' )
	oPnlLftUp := oFWLayerLeft:GetColPanel( 'COLTOP', 'LEFTUP' )
	oPnlLftDown := oFWLayerLeft:GetColPanel( 'COLDOWN' , 'LEFTDOWN' ) // Pego o objeto do pedaço esquerdo

	//
	// FWmBrowse Superior Obrigações
	//
	oBrowseUp:= FWmBrowse():New()
	// Aqui se associa o browse ao componente de tela
	oBrowseUp:SetOwner( oPnlLftUp )

	oBrowseUp:SetDescription( "Obrigações" )
	oBrowseUp:SetAlias( 'B3A' )

	// Define de onde virao os botoes deste browse
	oBrowseUp:SetMenuDef( 'PLSMVCOBRIGAC' )
	oBrowseUp:SetProfileID( 'OBR1' )
	oBrowseUp:ForceQuitButton()
	oBrowseUp:DisableDetails()
	oBrowseUp:SetWalkthru(.F.)
	oBrowseUp:SetAmbiente(.F.)
	If !Empty(cFiltroObr)
		oBrowseUp:SetFilterDefault( cFiltroObr )
	EndIf

	oBrowseUp:BCHANGE := {|| refreshMVC(oBrwVcto,oBrowseDown)}

	oBrowseUp:Activate()

	//
	// FWmBrowse Inferior Compromissos
	//
	oBrowseDown:= FWMBrowse():New()
	oBrowseDown:SetOwner( oPnlLftDown )

	aCampos  := CmpoB3DTmp()
	oTempB3D := CriaTabTemp('TEMPB3D',aCampos,"01",{"B3D_CDOBRI","Ordenacao","B3D_VCTO"})
	If BuscaB3D()
		LoadB3DTmp()
	EndIf
	oBrowseDown:SetDescription( 'Compromissos' )
	oBrowseDown:SetAlias( oTempB3D:getAlias() )
	oBrowseDown:SetMenuDef( 'PLSMVCCOMPROM' ) //Chamar MenuDef dos compromissos
	oBrowseDown:DisableDetails()

	oBrowseDown:SetFields(montaFields(aCampos,'TEMPB3D'))
	oBrowseDown:SetSeek(.T.,aSeek)
	oBrowseDown:SetFieldFilter(RtnFilterB3D())

	//1=Em Processamento;2=Criticado;3=Pronto para o Envio;4=Em processamento ANS;5=Criticado pela ANS;6=Finalizado
	oBrowseDown:AddLegend( "AllTrim(B3D_STATUS)=='1'", "YELLOW", "Pendente Envio" )
	oBrowseDown:AddLegend( "AllTrim(B3D_STATUS)=='2'", "RED", "Criticado" )
	oBrowseDown:AddLegend( "AllTrim(B3D_STATUS)=='3'", "BLUE", "Pronto para o Envio" )
	oBrowseDown:AddLegend( "AllTrim(B3D_STATUS)=='4'", "ORANGE", "Em processamento ANS" )
	oBrowseDown:AddLegend( "AllTrim(B3D_STATUS)=='5'", "BLACK", "Criticado pela ANS" )
	oBrowseDown:AddLegend( "AllTrim(B3D_STATUS)=='6'", "GREEN", "Finalizado" )

	oBrowseDown:SetProfileID( 'CPR1' )
	oBrowseDown:SetAmbiente(.F.)
	oBrowseDown:SetWalkthru(.F.)

	oBrowseDown:BCHANGE := {|| goToB3D(oBrowseDown)}

	oBrowseDown:Activate()
	//Crio o relacionamento entre os Grids

	oRelacB3D:= FWBrwRelation():New()
	oRelacB3D:AddRelation( oBrowseUp , oBrowseDown , { 	{ 'B3D_FILIAL', 'xFilial( "B3D" )' },;
		{ 'B3D_CODOPE' , 'B3A_CODOPE' },;
		{ 'B3D_CDOBRI' , 'B3A_CODIGO' };
		} )
	oRelacB3D:Activate()

	Activate MsDialog oDlgPrinc Center

	oTmpTab:delete()
	TEMPB3D->(dbCloseArea())

Return NIL

//---------------------------------------------------------------------------
/*/{Protheus.doc} CentralRClick

Funcao chamada ao clicar com o botao direito

@sample	CentralRClick( oItem )

@param		oItem - Item do calendário sobre o qual foi clicado com o botão direito

@return	Nenhum

@author	Thiago Tavares
@since		03/05/2014
@version	P12
/*/
//---------------------------------------------------------------------------
Function CentralRClick( oItem )

	Local aMenu := {}

Return aMenu

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCLDROT

Conta a quantidade de criticas de um compromisso

@return nQtdCri	Quantidade de criticas encontrada

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCLDROT(cRotina,cCodOpe,cCodObr,cCodCmp,cAno)
	Local aArea	:= B3D->(GetArea())

	B3D->(RestArea(aArea))

Return Nil


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLCOQTDCRI

Conta a quantidade de criticas de um compromisso

@return nQtdCri	Quantidade de criticas encontrada

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLCOQTDCRI()
	Local nQtdCri := 0

	//TODO Mudar forma de contrar críticas

	B3F->(dbSetOrder(3))//B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP
	If B3F->(MsSeek(xFilial("B3D")+B3D->(B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+"1")))
		Do While !B3F->(Eof()) .AND. B3F->(B3F_FILIAL+B3F_CODOPE+B3F_CDOBRI+B3F_ANO+B3F_CDCOMP+B3F_STATUS) == ;
				B3D->(B3D_FILIAL+B3D_CODOPE+B3D_CDOBRI+B3D_ANO+B3D_CODIGO+"1")

			nQtdCri++
			B3F->(DbSkip())

		EndDo
	EndIf

Return nQtdCri
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BuscaVctos

Busca os compromissos a vencer

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function BuscaVctos()
	Local cAliasTmp := "TRBB3D"
	Local cSql 		:= ""
	Local lFound	:= .F.

	cSql := " SELECT "
	cSql += "  B3D.B3D_CODOPE,B3D.B3D_CDOBRI,B3D.B3D_VCTO, "
	cSql += "  B3D.B3D_CODIGO,B3D.B3D_ANO,B3D.B3D_REFERE, B3D.R_E_C_N_O_ Recno "
	cSql += " FROM "
	cSql += "   " + RetSqlName("B3A") + " B3A "
	cSql += " , " + RetSqlName("B3D") + " B3D "
	cSql += " WHERE "
	cSQL += " B3A_FILIAL = '"+xFilial("B3A")+"' "
	cSQL += " AND B3D_FILIAL = '"+xFilial("B3D")+"' "
	cSQL += " AND B3D_CODOPE = B3A_CODOPE "
	cSQL += " AND B3D_CDOBRI = B3A_CODIGO "
	cSQL += " AND B3D_TIPOBR = B3A_TIPO "
	cSQL += " AND B3A_ATIVO = '1' "
	cSQL += " AND B3D_STATUS <> '" + FINALIZADO + "' "
	cSql += " AND B3D_VCTO >= '"+ DTOS(dDataBase) +"' "
	cSQL += " AND B3A.D_E_L_E_T_ = ''  "
	cSQL += " AND B3D.D_E_L_E_T_ = ''  "
	cSql += " ORDER BY B3D_VCTO "

	If (Select('TRBB3D') <> 0)
		dbSelectArea('TRBB3D')
		TRBB3D->(dbCloseArea())
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasTmp,.F.,.T.)

	lFound := !TRBB3D->(Eof())
	If !lFound
		TRBB3D->(dbCloseArea())
	EndIf

Return lFound

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BuscaB3D

Busca os compromissos da tabela temporaria

@author p.drivas
@since 01/10/2020
/*/
//--------------------------------------------------------------------------------------------------
Function BuscaB3D()
	Local cAliasTmp := "SEEKB3D"
	Local cSql 		:= ""
	Local lFound	:= .F.

	cSQL += " SELECT  "
	cSQL += " 	CASE  "
	cSQL += " 		WHEN B3D.B3D_STATUS ='1' OR B3D.B3D_STATUS ='2' OR B3D.B3D_STATUS ='3' "
	cSQL += " 			THEN '1' "
	cSQL += " 			ELSE B3D.B3D_STATUS "
	cSQL += " 	END AS NEW_STATUS, "
	cSql += " B3D_FILIAL,B3D_CODOPE,B3D_CDOBRI,B3D_CODIGO,B3D_TIPOBR, "
	cSql += " B3D_ANO,B3D_REFERE,B3D_VCTO,B3D_STATUS,B3D.R_E_C_N_O_ Recno "
	cSQL += " FROM "
	cSql += "   " + RetSqlName("B3A") + " B3A "
	cSql += " , " + RetSqlName("B3D") + " B3D "
	cSQL += " WHERE B3D.D_E_L_E_T_ = ' ' "
	cSQL += " AND B3A.D_E_L_E_T_ = ''  "
	cSQL += " AND B3A_FILIAL = '"+xFilial("B3A")+"' "
	cSQL += " AND B3D_FILIAL = '"+xFilial("B3D")+"' "
	cSQL += " AND B3D_CODOPE = B3A_CODOPE "
	cSQL += " AND B3D_CDOBRI = B3A_CODIGO "
	cSQL += " AND B3D_TIPOBR = B3A_TIPO "
	cSQL += " ORDER BY B3D.B3D_CDOBRI,NEW_STATUS,B3D.B3D_VCTO "

	If (Select(cAliasTmp) <> 0)
		dbSelectArea(cAliasTmp)
		(cAliasTmp)->(dbCloseArea())
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasTmp,.F.,.T.)

	lFound := !(cAliasTmp)->(Eof())
	// If !lFound
	// 	(cAliasTmp)->(dbCloseArea())
	// EndIf

Return lFound

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaCampos

Retorna os campos para criar o arquivo temporario

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaCampos()
	Local aCampos		:= {}

	aAdd(aCampos,{"B3D_VCTO"	,"D",008,0})
	aAdd(aCampos,{"B3D_REFERE"	,"C",010,0})
	aAdd(aCampos,{"B3D_OBRDES"	,"C",015,0})
	aAdd(aCampos,{"B3D_CODOPE"	,"C",006,0})
	aAdd(aCampos,{"B3D_CDOBRI"	,"C",003,0})
	aAdd(aCampos,{"B3D_CODIGO"	,"C",003,0})

Return aCampos

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CmpoB3DTmp

Retorna os campos para criar o arquivo temporario da B3D

@author p.drivas
@since 02/10/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CmpoB3DTmp()
	Local aCampos	:= {}
	Local aB3DSX3 := B3D->(DBSTRUCT())
	Local nCampos := 0
	Local aNames  := {"B3D_FILIAL","B3D_CODOPE","B3D_CDOBRI","B3D_CODIGO","B3D_TIPOBR","B3D_ANO","B3D_REFERE","B3D_VCTO","B3D_STATUS"}

	For nCampos := 1 to len(aB3DSX3)
		If aScan(aNames,aB3DSX3[nCampos][1]) > 0
			If aB3DSX3[nCampos][1] == 'B3D_TIPOBR'
				aAdd(aCampos,{aB3DSX3[nCampos][1],aB3DSX3[nCampos][2],15,aB3DSX3[nCampos][4]})
			ElseIf aB3DSX3[nCampos][1] == 'B3D_STATUS'
				aAdd(aCampos,{aB3DSX3[nCampos][1],aB3DSX3[nCampos][2],20,aB3DSX3[nCampos][4]})
			Else
				aAdd(aCampos,{aB3DSX3[nCampos][1],aB3DSX3[nCampos][2],aB3DSX3[nCampos][3],aB3DSX3[nCampos][4]})
			EndIf
		EndIf
	Next nCampos
	aAdd(aCampos,{"Ordenacao"	,"C",001,0})
	aAdd(aCampos,{"Recno"	,"N",010,0})

Return aCampos

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp

Cria o arquivo temporario de vencimentos

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaTabTemp(cAlias,aCampos,cIndex,aIndex)
	Local oTmpTab		:= Nil
	Default aCampos		:= {}

	oTmpTab := FWTemporaryTable():New( cAlias )
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex(cIndex,aIndex)
	If cAlias == 'TEMPB3D'
		oTmpTab:AddIndex("02",{"B3D_FILIAL","B3D_CODOPE","B3D_CDOBRI","B3D_ANO","B3D_TIPOBR","B3D_CODIGO","B3D_STATUS"})
	EndIf
	oTmpTab:Create()

Return oTmpTab

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com os registros criticados

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(oTmpTab)
	Local aB3A	:= B3A->(GetArea())

	While !TRBB3D->(Eof())

		RecLock('VCTOB3D',.T.)
		VCTOB3D->B3D_VCTO 	:= STOD(TRBB3D->B3D_VCTO)
		VCTOB3D->B3D_REFERE := TRBB3D->B3D_REFERE
		VCTOB3D->B3D_OBRDES := POSICIONE("B3A",1,xFilial("B3D")+TRBB3D->(B3D_CODOPE+B3D_CDOBRI),"B3A_DESCRI")
		VCTOB3D->B3D_CODOPE := TRBB3D->B3D_CODOPE
		VCTOB3D->B3D_CDOBRI := TRBB3D->B3D_CDOBRI
		VCTOB3D->B3D_CODIGO := TRBB3D->B3D_CODIGO
		VCTOB3D->B3D_REFERE := TRBB3D->B3D_REFERE
		VCTOB3D->(MsUnlock())
		TRBB3D->(DbSkip())

	EndDo

	TRBB3D->(dbCloseArea())
	RestArea(aB3A)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadB3DTmp

Preenche o arquivo temporario

@author p.drivas
@since 01/10/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function LoadB3DTmp(oTmpTab)

	Local aObrig := CENGETX3BX("B3A_TIPO")
	Local aB3A	 := B3A->(GetArea())


	While !SEEKB3D->(Eof())

		RecLock('TEMPB3D',.T.)
		TEMPB3D->B3D_FILIAL := SEEKB3D->B3D_FILIAL
		TEMPB3D->B3D_CODOPE := SEEKB3D->B3D_CODOPE
		TEMPB3D->B3D_CDOBRI := SEEKB3D->B3D_CDOBRI
		TEMPB3D->B3D_CODIGO := SEEKB3D->B3D_CODIGO
		TEMPB3D->B3D_TIPOBR := aObrig[Val(SEEKB3D->B3D_TIPOBR)][2]//X3COMBO("B3A_TIPO",B3A->B3A_TIPO)
		TEMPB3D->B3D_ANO    := SEEKB3D->B3D_ANO
		TEMPB3D->B3D_REFERE := SEEKB3D->B3D_REFERE
		TEMPB3D->B3D_VCTO   := STOD(SEEKB3D->B3D_VCTO)
		TEMPB3D->B3D_STATUS := SEEKB3D->B3D_STATUS//AllTrim(aStatus[Val(SEEKB3D->B3D_STATUS)][2])
		TEMPB3D->Ordenacao  := SEEKB3D->NEW_STATUS
		TEMPB3D->Recno      := SEEKB3D->Recno
		TEMPB3D->(MsUnlock())

		SEEKB3D->(DbSkip())

	EndDo

	SEEKB3D->(dbCloseArea())
	RestArea(aB3A)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaFields

Carrega os campos do browse de vencimentos

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function montaFields(aCampos,cTab)
	Local cCampo		:= ""
	Local cTitulo		:= ""
	Local cPicture		:= "@!"
	Local nAlign		:= 1
	Local nCampos   := 0
	Local aFields		:= {}

	If cTab == 'VCTOB3D'
		aAdd(aFields,GetColuna(aCampos[PB3DVCTO,CAMPO]  ,"Vencto"    ,aCampos[PB3DVCTO,TIPO]  ,cPicture,nAlign,aCampos[PB3DVCTO,TAMANHO]  ,aCampos[PB3DVCTO,DECIMAL]))
		aAdd(aFields,GetColuna(aCampos[PB3DREFERE,CAMPO],"Referencia",aCampos[PB3DREFERE,TIPO],cPicture,nAlign,aCampos[PB3DREFERE,TAMANHO],aCampos[PB3DREFERE,DECIMAL]))
		aAdd(aFields,GetColuna(aCampos[PB3DOBRDES,CAMPO],"Desc Obrig",aCampos[PB3DOBRDES,TIPO],cPicture,nAlign,aCampos[PB3DOBRDES,TAMANHO],aCampos[PB3DOBRDES,DECIMAL]))
		aAdd(aFields,GetColuna(aCampos[PB3DCODOPE,CAMPO],"Operadora" ,aCampos[PB3DCODOPE,TIPO],cPicture,nAlign,aCampos[PB3DCODOPE,TAMANHO],aCampos[PB3DCODOPE,DECIMAL]))
		aAdd(aFields,GetColuna(aCampos[PB3DCDOBRI,CAMPO],"Cod. Obrig",aCampos[PB3DCDOBRI,TIPO],cPicture,nAlign,aCampos[PB3DCDOBRI,TAMANHO],aCampos[PB3DCDOBRI,DECIMAL]))
		aAdd(aFields,GetColuna(aCampos[PB3DCODIGO,CAMPO],"Cod Compro",aCampos[PB3DCODIGO,TIPO],cPicture,nAlign,aCampos[PB3DCODIGO,TAMANHO],aCampos[PB3DCODIGO,DECIMAL]))
	Else
		For nCampos := 1 to len(aCampos)-3
			aAdd(aFields,GetColuna(aCampos[nCampos][1],FWX3Titulo( aCampos[nCampos][1] ),aCampos[nCampos][2],/*cPicture*/,nAlign,aCampos[nCampos][3],aCampos[nCampos][4]))
		Next nCampos
	EndIf
Return aFields

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetColuna

Retorna uma coluna para o markbrowse

@author everton.mateus
@since 15/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)
	Local aColuna		:= {}
	Local bData			:= &("{||" + cCampo +"}")
	Default nAlign		:= 1
	Default nSize		:= 20
	Default nDecimal	:= 0
	Default cTipo		:= "C"

	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLLOADCOMP

Verifica se e necessario gerar os compromissos do ano

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PLLOADCOMP()
	Local cAno := ""
	Local nAno := Year(dDataBase)
	Local aArea	:= GetArea()

	If Month(dDataBase) >= 10
		nAno++
	EndIf

	cAno := AllTrim( StrZero(nAno,4) )

	B3A->(dbSetOrder(1))
	B3D->(dbSetOrder(1))

	//Percorro todas as obrigações
	If B3A->(MsSeek(xFilial("B3A")))
		Do While !B3A->(Eof())
			If B3A->B3A_ATIVO == '1'
				nSazon := val(B3A->B3A_SZNLDD)
				if nSazon == 1
					nSazon := 12
				ElseIf nSazon == 2
					nSazon := 6
				ElseIf nSazon == 3
					nSazon := 4
				ElseIf nSazon == 4
					nSazon := 2
				ElseIf nSazon == 5
					nSazon := 1
				End If

				//Verifico se a ultima obrigação está no ano vigente.
				If !B3D->(MsSeek(xFilial("B3D")+B3A->(B3A_CODOPE+B3A_CODIGO)+cAno ) )
					PlInComPad( cAno )
				EndIf
			EndIf

			B3A->(DbSkip())
		Enddo
	EndIf
	RestArea(aArea)
Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PlAtuStaCo

Finaliza compromissos do SIB que já passaram do vencimento.

@author everton.mateus
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function PlAtuStaCo()
	Local cAno 	:= AllTrim(StrZero(Year(dDataBase),4))
	Local cSQL    := ""
	Local cStatusAtual    := ""

	Local aArea	:= GetArea()

	cSQL := " SELECT "
	cSQL += " B3D.R_E_C_N_O_ Recno"
	cSQL += " FROM "
	cSQL += RetSqlName("B3D") + " B3D, " + RetSqlName("B3A") + " B3A "
	cSQL += " WHERE "
	cSQL += " B3A_FILIAL = '"+xFilial("B3A")+"' "
	cSQL += " AND B3D_FILIAL = '"+xFilial("B3D")+"' "
	cSQL += " AND B3A_TIPO IN ('1','2','5') "
	cSQL += " AND B3A_ATIVO = '1' "
	cSQL += " AND B3D_CODOPE = B3A_CODOPE "
	cSQL += " AND B3D_CDOBRI = B3A_CODIGO "
	cSQL += " AND B3D_TIPOBR = B3A_TIPO "
	cSQL += " AND B3D_STATUS <> '" + FINALIZADO + "' "
	cSQL += " AND B3D_VCTO < '" + DTOS(dDataBase) + "' "
	cSQL += " AND B3A.D_E_L_E_T_ = ''  "
	cSQL += " AND B3D.D_E_L_E_T_ = ''  "

	PLSQuery(cSQL,"TRBCOM")

	While ! TRBCOM->(Eof())

		B3D->(DbGoto(TRBCOM->Recno))
		cStatusAtual := B3D->B3D_STATUS
		Reclock("B3D",.F.)
		B3D->B3D_STATUS := FINALIZADO
		MsUnlock()
		//Gravar histórico da mudança de fase
		PlCompHist(B3D->B3D_CODOPE,B3D->B3D_CDOBRI,B3D->B3D_ANO,B3D->B3D_CODIGO,cStatusAtual,FINALIZADO)
		TRBCOM->(DbSkip())
	Enddo

	TRBCOM->(DbCloseArea())


	RestArea(aArea)

Return Nil

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} IniBrwB3D

Inicializa descricao da obrigacao no compromisso

@author timoteo.bega
@since 09/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function IniBrwB3D()

	Local aB3A	:= B3A->(GetArea())

	cDescri := POSICIONE("B3A",1,XFILIAL("B3D")+B3D->(B3D_CODOPE+B3D_CDOBRI),"B3A_DESCRI")
	RestArea(aB3A)

Return cDescri

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} atuOperaMov()

Corrige a chave única das movimentações do SIB

@author everton.mateus
@since 09/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function atuOperaMov()

	Local nQtd := 0
	Local nProc:= 0

	B3K->(DbSetOrder(5))
	PlsLogFil(CENDTHRL("I") + " Inicio atuOperaMov ",ARQ_LOG_COR)
	If B3X->(FieldPos("B3X_CODCCO")) > 0
		nQtd := carMovtoSIB(.T.)
		If nQtd > 0
			ProcRegua( int(nQtd / 1000) + 1)
			carMovtoSIB(.F.)
			Do While !TRBCOR->(Eof())
				If nProc % 1000 == 0
					cMsg := "Movimentações lidas: " +AllTrim(Str(nQtd))+ ". Movimentações processadas:" +AllTrim(Str(nProc))+ "."
					IncProc(cMsg)
					PlsLogFil(CENDTHRL("I") + " atuOperaMov: " + cMsg ,ARQ_LOG_COR)
				EndIf
				B3X->( DbGoto(TRBCOR->RECB3X) )
				RecLock('B3X',.F.)
				B3X->B3X_BENEF := 0
				B3X->B3X_CODCCO := TRBCOR->B3K_CODCCO
				B3X->B3X_CODOPE := TRBCOR->B3K_CODOPE
				B3X->(MsUnlock())
				nProc++
				TRBCOR->(DbSkip())
			EndDo
			TRBCOR->(DbCloseArea())
		EndIf
	EndIf
	PlsLogFil(CENDTHRL("I") + " Fim atuOperaMov ",ARQ_LOG_COR)
Return

Static Function carMovtoSIB(lTotal)

	Local cSql := ""
	Local nQtd := 0

	Default lTotal := .F.

	If Select('TRBCOR') > 0
		TRBCOR->(dbCloseArea())
	EndIf

	cSql := " SELECT  "
	If lTotal
		cSql += " 	count(1) TOTAL "
	Else
		cSql += " 	B3X.R_E_C_N_O_ RECB3X, B3K_CODOPE, B3K_CODCCO "
	EndIf
	cSql += " FROM " + RetSqlName("B3X") + " B3X , "
	cSql += " " + RetSqlName("B3K") + " B3K "
	cSql += " WHERE "
	cSql += "	B3X_FILIAL = '" + xFilial('B3X') + "' "
	cSql += "	AND B3X_FILIAL = B3K_FILIAL "
	cSql += "	AND B3X_CODOPE = B3K_CODOPE "
	cSql += "	AND B3X_IDEORI = B3K_MATRIC "
	cSql += "	AND B3X_CODCCO = B3K_CODCCO "
	cSql += "	AND B3X.D_E_L_E_T_ = ' ' "
	cSql += "	AND B3K.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	PlsLogFil(CENDTHRL("I") + cSql ,ARQ_LOG_COR)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOR",.F.,.T.)

	If lTotal .AND. !TRBCOR->(Eof())
		nQtd := TRBCOR->TOTAL
	EndIf

Return nQtd

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} corHisBloq()

Corrige a chave única dos históricos de bloqueio da Central

@author everton.mateus
@since 09/11/2018
/*/
//--------------------------------------------------------------------------------------------------
Function corHisBloq()

	Local nQtd := 0
	Local nProc:= 0
	PlsLogFil(CENDTHRL("I") + " Iniciio corHisBloq ",ARQ_LOG_COR)
	If B4W->(FieldPos("B4W_CODCCO")) > 0
		nQtd := carHisBloq(.T.)
		If nQtd > 0
			ProcRegua( int(nQtd / 1000) + 1)
			carHisBloq(.F.)
			Do While !TRBCOR->(Eof())
				If nProc % 1000 == 0
					cMsg := "Movimentações lidas: " +AllTrim(Str(nQtd))+ ". Movimentações processadas:" +AllTrim(Str(nProc))+ "."
					IncProc(cMsg)
					PlsLogFil(CENDTHRL("I") + " corHisBloq: " + cMsg,ARQ_LOG_COR)
				EndIf
				B4W->( DbGoto(TRBCOR->RECB4W) )
				RecLock('B4W',.F.)
				B4W->B4W_CODCCO := TRBCOR->B3K_CODCCO
				B4W->B4W_CODOPE := TRBCOR->B3K_CODOPE
				B4W->(MsUnlock())
				nProc++
				TRBCOR->(DbSkip())
			EndDo
			TRBCOR->(DbCloseArea())
		EndIf
	EndIf
	PlsLogFil(CENDTHRL("I") + " Fim corHisBloq ",ARQ_LOG_COR)
Return

Static Function carHisBloq(lTotal)

	Local cSql := ""
	Local nQtd := 0

	Default lTotal := .F.

	If Select('TRBCOR') > 0
		TRBCOR->(dbCloseArea())
	EndIf

	cSql := " SELECT  "
	If lTotal
		cSql += " 	count(1) TOTAL "
	Else
		cSql += " 	B4W.R_E_C_N_O_ RECB4W, B3K_CODCCO, B3K_CODOPE "
	EndIf
	cSql += " FROM " + RetSqlName("B4W") + " B4W , "
	cSql += " " + RetSqlName("B3K") + " B3K, "
	cSql += " " + RetSqlName("B8M") + " B8M "
	cSql += " WHERE "
	cSql += "	B4W_FILIAL = '" + xFilial('B4W') + "' "
	cSql += "	AND B4W_FILIAL = B3K_FILIAL "
	cSql += "	AND B8M_FILIAL = B3K_FILIAL "
	cSql += "	AND B8M_CODOPE = B3K_CODOPE "
	cSql += "	AND B4W_MATRIC = B3K_MATRIC "
	//cSql += "	AND B4W_CODOPE = '' "
	cSql += "	AND B4W_CODCCO = '' "
	cSql += "	AND B4W.D_E_L_E_T_ = ' ' "
	cSql += "	AND B3K.D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery(cSql)
	PlsLogFil(CENDTHRL("I") + cSql ,ARQ_LOG_COR)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBCOR",.F.,.T.)

	If lTotal .AND. !TRBCOR->(Eof())
		nQtd := TRBCOR->TOTAL
	EndIf

Return nQtd

static function goToB3D(oBrowseDown)
	B3D->(DBGOTO(TEMPB3D->Recno))
return

static function refreshMVC(oBrwVcto,oBrowseDown)

	local nNewRegB3A := B3A->(RECCOUNT())

	If Valtype(oBrwVcto) <> "U" .And. ValType(oBrowseDown) <> "U"
		oBrwVcto:Refresh(.T.)
		oBrowseDown:Refresh(.T.)
	EndIf

	If nNewRegB3A > nRegB3A

		If SELECT("VCTOB3D") > 0
			dbselectarea('VCTOB3D')
			('VCTOB3D')->(DBGOTOP())
			While ('VCTOB3D')->(!Eof())
				Reclock('VCTOB3D',.F.)
				('VCTOB3D')->(DbDelete())
				MsUnlock()
				('VCTOB3D')->(DBSkip())
				End Do
				If BuscaVctos()
					StaticCall(PLSMVCCENTRAL,CarregaArqTmp)
				EndIf
				oBrwVcto:Refresh(.T.)
				EndIf

				If SELECT("TEMPB3D") > 0
					dbselectarea('TEMPB3D')
					//SEEKB3D->(DBCloseAREA())
					('TEMPB3D')->(DBGOTOP())
					While ('TEMPB3D')->(!Eof())
						Reclock('TEMPB3D',.F.)
						('TEMPB3D')->(DbDelete())
						MsUnlock()
						('TEMPB3D')->(DBSkip())
						End Do
						If BuscaB3D()
							StaticCall(PLSMVCCENTRAL,LoadB3DTmp)
						EndIf
						oBrowseDown:Refresh(.T.)
						EndIf

						nRegB3A:=nNewRegB3A

						EndIf

						return

						static function refreshB3D()
							If SELECT("TEMPB3D") > 0
								dbselectarea('TEMPB3D')
								('TEMPB3D')->(DBGOTOP())
								While ('TEMPB3D')->(!Eof())
									Reclock('TEMPB3D',.F.)
									('TEMPB3D')->(DbDelete())
									MsUnlock()
									('TEMPB3D')->(DBSkip())
								EndDo
								If BuscaB3D()
									StaticCall(PLSMVCCENTRAL,LoadB3DTmp)
								EndIf
							EndIf
						return

						static function addSeek()
							local aSeek := {}
							aAdd(aSeek,;
								{;
								"Reg. Ope. + Cd Obrigacao + Ano Referenc + Tipo Obrigac + Codigo Comp",;
								{;
								{"","C",017,0,"Cd Obrigacao"		,"@!"};
								},;
								};
								)
						return aSeek

						//--------------------------------------------------------------------------------------------------
						/*/{Protheus.doc} Retorna um array de campos

Retorna campos que formam a tela de Criar novos filtros

@author vinicius.nicolau
@since 30/11/2020
						/*/
						//--------------------------------------------------------------------------------------------------
						Function RtnFilterB3D()
							Local aFieFilter := {}
							Aadd(aFieFilter,{"B3D_FILIAL","Filial do sistema"		 ,"C",008, 0,"@!"})
							Aadd(aFieFilter,{"B3D_CODOPE","Registro Operadora"		 ,"C",006, 0,"@!"})
							Aadd(aFieFilter,{"B3D_CDOBRI","Codigo Obrigacao"		 ,"C",003, 0,"@!"})
							Aadd(aFieFilter,{"B3D_CODIGO","Codigo do Compromisso"    ,"C",003, 0,"@!"})
							Aadd(aFieFilter,{"B3D_TIPOBR","Tipo da Obrigacao"        ,"C",001, 0,"@!"})
							Aadd(aFieFilter,{"B3D_ANO"	 ,"Ano Referencia"           ,"C",004, 0,"@!"})
							Aadd(aFieFilter,{"B3D_REFERE","Referencia do Compromisso","C",010, 0,"@!"})
							Aadd(aFieFilter,{"B3D_VCTO"	 ,"Vencimento do Compromisso","D",008, 0,"@!"})
							Aadd(aFieFilter,{"B3D_STATUS","Status"                   ,"C",001, 0,"@!"})
						Return aFieFilter
