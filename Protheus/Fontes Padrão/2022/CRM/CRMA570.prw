#include "CRMA570.CH"
#Include "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA570()

Rotina de Possíveis negociações


@param	 uRotAuto  - array contendo dados para rotina automatica
         nOpcAuto  - opração que deverá ser executada na rotina automatica
		 lExecAuto - indica se está sendo chamada por um procedimento automatico
		 aAddFil   - array contendo os filtros do browse

@return   Nenhum

@author   Victor Bitencourt
@since    03/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------
Function CRMA570(uRotAuto, nOpcAuto, lExecAuto, aAddFil)

Local oMBrowse   := Nil // Browse da lista de scripts executados
Local nX		   := 0  
Local cFiltroAO4 := ""

Private aRotina  := MenuDef()

Default uRotAuto  := Nil
Default nOpcAuto  := Nil
Default lExecAuto := .T.
Default aAddFil   := {}


If uRotAuto == Nil .AND. nOpcAuto == Nil 

	oMBrowse:= FWMBrowse():New()//		Criando Browser e Layer
	
	//--------------------------
	//	Criando o Filtro da AO4
	//--------------------------
	cFiltroAO4 := CRMXFilEnt( "AOJ", .T. )
	oMBrowse:DeleteFilter( "AO4_FILENT" )
	oMBrowse:AddFilter( STR0001, cFiltroAO4, .T., .T., "AO4", , , "AO4_FILENT" )//"Filtro do CRM"
	oMBrowse:ExecuteFilter()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtros adicionais do Browse                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len( aAddFil )
		oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
		oMBrowse:AddFilter( aAddFil[nX][ADDFIL_TITULO], ;
						      aAddFil[nX][ADDFIL_EXPR], ;
				              aAddFil[nX][ADDFIL_NOCHECK], ;
						      aAddFil[nX][ADDFIL_SELECTED], ;
						      aAddFil[nX][ADDFIL_ALIAS], ;
						      aAddFil[nX][ADDFIL_FILASK], ;
						      aAddFil[nX][ADDFIL_FILPARSER], ;
						      aAddFil[nX][ADDFIL_ID] )		 
		oMBrowse:ExecuteFilter()	
	Next nX		
	
	oMBrowse:SetAlias("AOJ")
	oMBrowse:SetDescription(STR0002)//"Possíveis Negociações"
	
	
	oMBrowse:SetAttach( .T. )//Habilita as visões do Browse
	oTableAtt := TableAttDef()
	
    //--------------------------------------------------------------------------------------
	//	Carrega Todas as visões e graficos disponiveis para atividades na função TableAttDef
	//---------------------------------------------------------------------------------------
	If oTableAtt <> Nil
		oMBrowse:SetViewsDefault( oTableAtt:aViews )
		oMBrowse:SetChartsDefault( oTableAtt:aCharts )
		oMBrowse:SetIDChartDefault( "GFEELM30" )
	EndIf

	oMBrowse:Activate()	

Else
// faz a execução da rotina automática 
	FWMVCRotAuto(ModelDef(),"AOJ",nOpcAuto,{{"AOJMASTER",uRotAuto}},/*lSeek*/,.T.)

  	If lMsErroAuto .AND. !lExecAuto
  		MostraErro()
  		lMsErroAuto := .F. //Setando valor padrão para variavel
  	Endif

EndIf

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef()

Cria as visões e gráficos

@sample	TableAttDef()

@param	  Nenhum

@return   ExpO - Objetos com as Visoes e Gráficos.  

@author   Victor Bitencourt
@since    03/12/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt 			:= FWTableAtt():New()
//Visões
Local oVMaior30			:= Nil // Possíveis Negociações com o Feeling maior que 30%

//Gráficos
Local oGMaior30			:= Nil // Possíveis Negociações por Feeling 

oTableAtt:SetAlias("AOJ")

//----------
// Visões
//----------
oVMaior30 := FWDSView():New()
oVMaior30:SetName(STR0003)//"Possíveis Negociações com o Feeling maior que 30%"
oVMaior30:SetID("VFEELM30")
oVMaior30:SetOrder(1) // AOJ_FILIAL+AOJ_CODIGO
oVMaior30:SetCollumns({"AOJ_CODIGO","AOJ_DESENT","AOJ_FEELIN","AOJ_DESCAT","AOJ_VLRPRE","AOJ_DTEXP"})
oVMaior30:SetPublic( .T. )
oVMaior30:AddFilter(STR0004, "AOJ_FEELIN == STR0005 .OR. AOJ_FEELIN == '3'")//"Possíveis Negociações com Feeling maior que 30%"//'2'

oTableAtt:AddView(oVMaior30)


//------------
// Gráficos
//------------
oGMaior30 := FWDSChart():New()
oGMaior30:SetName(STR0006) //"Possíveis negocações por Feeling"
oGMaior30:setTitle(STR0007)//"Possíveis negocações por Feeling"
oGMaior30:SetID("GFEELM30")
oGMaior30:SetType("BARCOMPCHART")
oGMaior30:SetSeries({ {"AOJ", "AOJ_CODIGO", "COUNT"} })
oGMaior30:SetCategory( { {"AOJ", "AOJ_FEELIN"} } )
oGMaior30:SetPublic( .T. )
oGMaior30:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oGMaior30:SetTitleAlign( CONTROL_ALIGN_CENTER )

oTableAtt:AddChart(oGMaior30)

Return (oTableAtt)


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Rotina para criar as opções de menu disponiveis 

@param	Nenhum

@return   array contendo as opções disponiveis

@author   Victor Bitencourt 
@since	   03/11/2014
@version  12.1.3
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aMenu := {}
	
	ADD OPTION aMenu TITLE STR0008  ACTION "VIEWDEF.CRMA570" OPERATION 2 ACCESS 0//"Visualizar"
	ADD OPTION aMenu TITLE STR0009  ACTION "VIEWDEF.CRMA570" OPERATION 5 ACCESS 0//"Excluir"

Return aMenu


//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Modelo de dados 

@param	 Nenhum

@return  oModel - objeto contendo o modelo de dados

@author  Victor Bitencourt 
@since	  03/11/2014
@version 12.1.3
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel      := Nil
Local oStructAOJ  := FWFormStruct(1,"AOJ")

oModel := MPFormModel():New("CRMA570",/*bPosValidacao*/,/*bPreValidacao*/, { |oModel| ModelCommit(oModel) },/*bCancel*/)
oModel:SetDescription(STR0010)//"Possíveis Negociações"

oModel:AddFields("AOJMASTER",/*cOwner*/,oStructAOJ,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)

oModel:SetPrimaryKey({"AOJ_FILIAL" ,"AOJ_CODIGO"})

oModel:GetModel("AOJMASTER"):SetDescription(STR0011)//"Possíveis Negociações"

return (oModel)



//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()

ViewDef - Visão do model 

@param	 Nenhum

@return  oView - objeto contendo a visão criada

@author  Victor Bitencourt 
@since	  03/11/2014
@version 12.1.3
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView	    := FWFormView():New()
Local oModel	    := FwLoadModel("CRMA570")

Local oStructAOJ  :=  FWFormStruct(2,"AOJ")

//	Associa o View ao Model
oView:SetModel( oModel )//Define que a view vai usar o model
oView:SetDescription(STR0012) //"Possíveis Negociações"

oView:AddField("VIEW_AOJ_FIELD", oStructAOJ, "AOJMASTER" )

//--------------------------------------
//	  Montagem da tela Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "LINEONE", 100 )

oView:AddField("VIEW_AOJ_FIELD", oStructAOJ, "AOJMASTER" )

oView:SetOwnerView( "VIEW_AOJ_FIELD", "LINEONE") 

Return (oView)



//----------------------------------------------------------
/*/{Protheus.doc} ModelCommit()

Rotina para efetuar o commit do model 

@param	  .T.

@return  oView - objeto contendo a visão criada

@author   Victor Bitencourt
@since	   03/12/2014
@version  12.1.3
/*/
//----------------------------------------------------------
Static Function ModelCommit(oModel)

Default oModel := Nil

If oModel <> Nil
	FWFormCommit(oModel,Nil,{|oModel,cId,cAlias| CRMA570CmtAft(oModel,cId,cAlias) }) //Salvando os Dados do Formulario.
EndIf

Return .T.


//----------------------------------------------------------
/*/{Protheus.doc} CRMA570CmtAft()

Bloco de transacao durante o commit do model.

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author   Victor Bitencourt
@since	   03/12/2014
@version  12.1.3
/*/
//----------------------------------------------------------
Static Function CRMA570CmtAft(oModel,cId,cAlias)

Local nOperation	:= oModel:GetOperation()
Local cChave    	:= ""
Local aAutoAO4  	:= {}
Local lRetorno 	    := .T.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona ou Remove o privilegios deste registro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cId == "AOJMASTER" .AND. ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE )
	cChave     := PadR(xFilial("AOJ")+FwFldGet("AOJ_CODIGO"),TAMSX3("AO4_CHVREG")[1])
  	aAutoAO4	:= CRMA200PAut(nOperation,"AOJ",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)
	CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
EndIf

Return(lRetorno)


