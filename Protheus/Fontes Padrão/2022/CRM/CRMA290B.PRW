#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA290.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA290B

Cadastro de paineis da nova Área de Trabalho do SIGACRM  

@sample	CRMA290B( uRotAuto, nOpcAuto )

@param		oDlgWA   - Objeto da Janela 
			nOpcAuto - Numero de identificacao da operacao
			aAOHMaster - Array com os valores do cabeçalho
			aAOIDetail - Array com os valores do detalhe
			nOpcAuto - Numero de identificacao da operacao
			
@return	ExpL - Verdadeiro / Falso  

@author 	Thiago Tavares
@since 		09/05/2014
@version	P12
/*/
//-------------------------------------------------------------------
Function CRMA290B( nOpcAuto, aAOHMaster, aAOIDetail )

Local oBrowse  		:= Nil
Local cFiltro  		:= ""
Local aAutoRot 		:= {}

Private lMsErroAuto := .F.
Private aRotina     := MenuDef()

Default aAOHMaster 	:= Nil 
Default aAOIDetail 	:= Nil 
Default nOpcAuto   	:= Nil

If aAOHMaster == Nil .AND. nOpcAuto == Nil

	oBrowse := FWMBrowse():New()
	oBrowse:SetCanSaveArea(.T.) 
	oBrowse:SetAlias( "AOH" ) 
	oBrowse:SetDescription( STR0088 )		// "Cadastro de Paineis da Área de Trabalho"     	  

	cFiltro := CRMXFilEnt( "AOH", .T. )
	oBrowse:DeleteFilter( "AO4_FILENT" )
	oBrowse:AddFilter( STR0129, cFiltro, .T., .T., "AO4", , , "AO4_FILENT" )      // "Filtro do CRM"		       
	oBrowse:ExecuteFilter() 

	oBrowse:Activate()
	
Else

	aAdd(aAutoRot,{"AOHMASTER",aAOHMaster})
	
	If aAOIDetail <> Nil
		aAdd(aAutoRot,{"AOIDETAIL",aAOIDetail})
	EndIf	

	FWMVCRotAuto( ModelDef(), "AOH", nOpcAuto, aAutoRot, /*lSeek*/, .T. )
  	
  	If lMsErroAuto  
 		MostraErro()
  	EndIf
  	 
EndIf

Return !( lMsErroAuto )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definição do modelo de Dados

@sample	ModelDef()

@param		Nenhum
			
@return	ExpO - Objeto do modelo de dados  

@author 	Thiago Tavares
@since 		09/05/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStructAOH	:= FWFormStruct( 1, "AOH", /*bAvalCampo*/,  /*lViewUsado*/ )
Local oStructAOI	:= FWFormStruct( 1, "AOI", /*bAvalCampo*/, /*lViewUsado*/ ) 
Local bCommit		:= { | oModel | CRM290BCmm( oModel ) }		// Efetua a  validacao

oModel := MPFormModel():New( "CRMA290B", /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )
oModel:AddFields( "AOHMASTER",  /*cOwner*/, oStructAOH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( "AOIDETAIL", "AOHMASTER", oStructAOI, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/)
oModel:GetModel("AOIDETAIL"):SetNoDeleteLine(.T.)
oModel:SetRelation( "AOIDETAIL", { { "AOI_FILIAL", "xFilial('AOI')" }, {"AOI_CODIGO","AOH_CODIGO"} }, AOI->( IndexKey( 1 ) ) )		// AOI_FILIAL+AOI_CODIGO+AOI_ITEM
oModel:SetPrimaryKey( { "AOH_FILIAL", "AOH_CODIGO" } )
oModel:SetDescription( STR0088 )		// "Cadastro de Paineis da Área de Trabalho"

// Adicao do modelo da AO4 para evitar a validacao indevida do relacionamento SX9 antes da funcao CRMA200PAut
AO4GdModel("AOHMASTER", oModel, "AOH" )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definição do interface

@sample	ViewDef()

@param		Nenhum
			
@return	ExpO - Objeto do modelo da interface  

@author 	Thiago Tavares
@since 		09/05/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView      := Nil
Local oModel     := FWLoadModel( "CRMA290B" )
Local oStructAOH := FWFormStruct( 2, "AOH", /*bAvalCampo*/, /*lViewUsado*/ )
Local oStructAOI := FWFormStruct( 2, "AOI", /*bAvalCampo*/, /*lViewUsado*/ )  

oStructAOH:RemoveField( "AOH_PADRAO" )
oStructAOH:SetProperty( "*" , MVC_VIEW_CANCHANGE, .F. )
oStructAOI:SetProperty( "*" , MVC_VIEW_CANCHANGE, .F. )  

oView := FWFormView():New()
oView:SetModel( oModel, "AOHMASTER" )
oView:AddField( "VIEW_AOH" , oStructAOH, "AOHMASTER" )
oView:CreateHorizontalBox( "ALL", 20)
oView:SetOwnerView( "VIEW_AOH", "ALL" )

oView:AddGrid( "VIEW_AOI", oStructAOI, "AOIDETAIL" )
oView:CreateHorizontalBox( "GRID", 80)
oView:SetOwnerView( "VIEW_AOI", "GRID" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das rotinas do Menu

@sample	MenuDef()

@param		Nenhum
			
@return	ExpA - Array de rotinas   

@author	Thiago Tavares
@since		09/05/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0089 ACTION "VIEWDEF.CRMA290B" 	OPERATION 2 ACCESS 0	// "Visualizar"				
ADD OPTION aRotina Title STR0001 ACTION "CRM290BLoad()"     OPERATION 7 ACCESS 0	// "Área de Trabalho"				
ADD OPTION aRotina Title STR0090 ACTION "CRMA290A"         	OPERATION 3 ACCESS 0	// "Incluir"			
ADD OPTION aRotina Title STR0092 ACTION "VIEWDEF.CRMA290B" 	OPERATION 5 ACCESS 0	// "Excluir"		
ADD OPTION aRotina Title STR0096 ACTION "CRMA200('AOH')"  	OPERATION 8 ACCESS 0	// "Privilégios"		

Return( aRotina )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM290BCmm

Bloco de commit do modelo

@sample 	CRM290BCmm( oModel )

@param		oModel - Modelo de dados do sistema

@return   	ExpL - Verdadeiro

@author	Thiago Tavares
@since		15/05/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function CRM290BCmm( oModel )

Local aArea		:= GetArea()
Local lCommit	:= .F.

lCommit := FWFormCommit(oModel,Nil,{|oModel,cId,cAlias| CRM290CmtAft(oModel,cId,cAlias) })

RestArea( aArea )

Return( lCommit )

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM290CmtAft

Bloco de transacao durante o commit do model. 

@sample	CRM290CmtAft(oModel,cId,cAlias)

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author	Anderson Silva
@since		06/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRM290CmtAft(oModel,cId,cAlias)

Local nOperation	:= oModel:GetOperation()
Local cChave    	:= ""		
Local aAutoAO4  	:= {}
Local lRetorno 		:= .T.
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona ou Remove o privilegios deste registro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cId == "AOHMASTER" .AND. ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE ) 
	cChave 		:= PadR(xFilial("AOH")+oModel:GetValue("AOH_CODIGO"),TAMSX3("AO4_CHVREG")[1])
	aAutoAO4	:= CRMA200PAut(nOperation,"AOH",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
	lRetorno	:= CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
EndIf 

Return( lRetorno )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM290BLoad

Carrega os dados do painel posicionado e chama a área de trabalho    

@sample 	CRM290BLoad()

@param		Nenhum

@return   	Nenhum

@author	Thiago Tavares
@since		15/05/2012
@version	P12
/*/
//------------------------------------------------------------------------------
Function CRM290BLoad()
Local aArea	  	:= GetArea()	
Local cAliasTmp	:= GetNextAlias()
Local aControl	:= {}
Local aAlias    := {}
Local aOpcoes   := {}
Local aViewPad  := {}
Local aChartPad := {}
Local aUrls     := {}
Local aFontes   := {}
Local cMenu     := ""
Local nMunLay   := 1

nNumLay := AOH->AOH_NUMLAY 
cMenu   := AOH->AOH_MENU 
	
BeginSql Alias cAliasTmp
	SELECT AOI.AOI_OPCAO, AOI.AOI_ALIAS, AOI.AOI_URL, AOI.AOI_FONTE, AOI.AOI_VDFLT, AOI.AOI_GDFLT 
	FROM %Table:AOI% AOI WHERE AOI.AOI_CODIGO = %Exp:AOH->AOH_CODIGO% ORDER BY AOI.AOI_ITEM
EndSql
	
If !( cAliasTmp )->( Eof() )
	While !( cAliasTmp )->( Eof() )    
		
		aAdd( aOpcoes, Val( ( cAliasTmp )->AOI_OPCAO ) )
		aAdd( aAlias, ( cAliasTmp )->AOI_ALIAS )
		aAdd( aViewPad, ( cAliasTmp )->AOI_VDFLT )
		aAdd( aChartPad, ( cAliasTmp )->AOI_GDFLT )
		aAdd( aUrls, AllTRim( ( cAliasTmp )->AOI_URL ) )
		aAdd( aFontes, AllTRim( ( cAliasTmp )->AOI_FONTE ) )
		
		( cAliasTmp )->( DbSkip() )
	End
EndIf
( cAliasTmp )->( DbCloseArea() )

aAdd( aControl, nNumLay )				// 1 - Tela
aAdd( aControl, aClone( aOpcoes ) )		// 2 - Array das opções selecionadas para a tela   ( 2=Tabela   3=Gráfico    4=WebBrowser    5=Calendário )
aAdd( aControl, aClone( aAlias ) )		// 3 - Array dos Alias da tela
aAdd( aControl, aClone( aViewPad) ) 	// 4 - Array com o IDX das Visoes Iniciais
aAdd( aControl, aClone( aChartPad ) )	// 5 - Array com o IDX dos Graficos Iniciais
aAdd( aControl, aClone( aUrls ) ) 		// 6 - Array com as URL's caso opção 3=WebBrowser
aAdd( aControl, aClone( aFontes) ) 		// 7 - Array com os Fontes dos Alias das telas	 
aAdd( aControl, cMenu )					// 8 - XML com o Menu

RestArea(aArea)

FWMsgRun(/*oComponent*/, { || CRMA290WA( /*cCodUser*/, /*cCodPanel*/, aControl) }, Nil, STR0098 )

Return( .T. )

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} AO4GdModel

Cria um GridModel associado ao modelo informado no parãmetro, para evitar
a validação do SX9 da entidade principal do modelo informado com a AO4

@param, cIDModel, ID do modelo principal                              , String
@param, oModel  , Objeto do modelo a que o novo modelo serah associado, MPFormModel

@sample		AO4GdModel(cIDModel, oModel)

@return, Nil

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function AO4GdModel(cIDMasterM, oModel, cAliasMast )
Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
Default cIDMasterM := ""
Default cAliasMast := ""

oModel:AddGrid("AO4CHILD",cIDMasterM,oStructAO4,/*bPreValid*/,/*bPosValid*/, , ,{|oGridModel, lCopy|LoadGdAO4(oGridModel, lCopy)})
oModel:SetRelation( "AO4CHILD" ,{ { "AO4_FILIAL", "FWxFilial( 'AO4' )" }, { "AO4_ENTIDA", cAliasMast }, { "AO4_CHVREG", ( cAliasMast )->( IndexKey( 1 ) ) }  }, AO4->( IndexKey( 1 ) ) )
oModel:GetModel("AO4CHILD"):SetOnlyView()
oModel:GetModel("AO4CHILD"):SetOnlyQuery()
oModel:GetModel("AO4CHILD"):SetOptional(.T.)
oModel:GetModel("AO4CHILD"):SetNoInsertLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoUpdateLine(.T.)
oModel:GetModel("AO4CHILD"):SetNoDeleteLine(.T.)

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGdAO4 

Bloco de carga dos dados do submodelo.
Este bloco sera invocado durante a execução do metodo activate desta classe.
O bloco recebe por parametro o objeto de model do FormGrid(FWFormGridModel) e um 
valor lógico indicando se eh uma operação de copia.

@param, oGridModel, objeto de model do FormGrid, FWFormGridModel
@param, lCopy     , indica se eh uma operação de copia, Boolean

@sample	LoadGdAO4(oGridModel, lCopy)

@return, aLoad, array com os dados que serão carregados no objeto, 
                o array deve ter a estrutura abaixo:
					[n]
					[n][1] ExpN: Id do registro (RecNo)
					[n][2] Array com os dados, os dados devem seguir exatamente 
					       a mesma ordem da estrutura de dados submodelo

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function LoadGdAO4(oGridModel, lCopy)
	
	Local aLoad      := {}
	Local oStructAO4 := FWFormStruct(1,"AO4",/*bAvalCampo*/,/*lViewUsado*/)
	Local aFields    := {}
	Local nField     := 0
	Local nQtFields  := 0
	Local xValue     := Nil
	Local cField     := ""
	Local cType      := ""
	Local nLen       := 0

	aFields   := oStructAO4:GetFields()
	nQtFields := Len(aFields)

	AAdd(aLoad, {0,{}})

	For nField := 1 To nQtFields
		
		cField := aFields[nField][3]
		
		If Alltrim(cField) == "AO4_FILIAL"
			xValue := XFilial("AO4")
			cType  := ""
		Else
			cType  := aFields[nField][4]
			nLen   := aFields[nField][5]	
		EndIf

		Do Case
			Case cType == "C"
				xValue := Space(nLen)
			Case cType == "N"
				xValue := 0
			Case cType == "L"
				xValue := .T.
			Case cType == "D"
				xValue := CToD("  /  /    ")
		End Case

		AAdd(aLoad[1][2], xValue)
	Next nField

	FwFreeObj(oStructAO4)
	FwFreeObj(aFields)

Return aLoad
