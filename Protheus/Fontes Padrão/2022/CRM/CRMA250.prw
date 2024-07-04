#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "APWIZARD.CH"   
#INCLUDE "CRMA250.CH"
#INCLUDE "CRMDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA250

Rotina de Campanhas Rapidas

@sample 	CRMA250( )

@param		cAlias - Alias da entidade da chamada

@return   	Nil

@author	Paulo Figueira
@since		25/03/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA250(cAlias,aAddFil)

Local lRet			:= .F.

Private aRotina		:= MenuDef()
Private cCodLista	:= "" //Código da Lista de Marketing
Private cUnicoList	:= "" //X2_Unico da Lista     

Default cAlias      := "" 
Default aAddFil		:= {}

If Alltrim(SU4->U4_FILIAL) <> Left(xFilial("AOC"),Len(Alltrim(SU4->U4_FILIAL)))
	 Help('',1,'CRM250FIL',,STR0035,1) // "Não é possível inserir uma campanha rápida nesta filial. Selecione a mesma filial da lista de marketing."
ElseIf Empty(SU4->U4_LISTA)
	 Help('',1,'CRM250NOLIST',,STR0049,1) //"Não é possivel criar uma campanha rápida sem uma lista de marketing"
Else
	//---------------------------
	// Browse Campanhas Rapidas.
	//---------------------------
	BrowseDef( /*oMBrowse*/, aAddFil, cAlias )
	lRet := .T.
EndIf

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse de Campanhas Rapidas

@sample	BrowseDef( oMBrowse, aAddFil, cAlias ) 

@param		oMBrowse	, Objeto	, Browse criado pelo Widget da Area de Trabalho.
			aAddFil	, Array		, Filtros relacionados.
			cAlias		, Caracter	, Tabela relacionada a campanhas rapidas.
		
@return	oMBrowse	, Objeto	, Retorna o objeto FWMBrowse.

@author	Anderson Silva
@since		05/12/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef( oMBrowse, aAddFil, cAlias )

Local lWidget			:= .F.		
Local cFiltro			:= 	""
Local aDadosSX2		:= {}
Local lRet				:= .F.
Local oTableAtt		:= Nil 
Local cFiltroEnt		:= ""
Local cCodEnt    		:= ""
Local nX				:= 0

Default oMBrowse		:= Nil
Default aAddFil		:= {}
Default cAlias		:= "AOC"

If Empty( oMBrowse )
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "AOC" )	
Else
	lWidget := .T.
EndIf

oMBrowse:SetCanSaveArea(.T.) 

//³ Filtros adicionais do Browse de Contratos ³
For nX := 1 To Len(aAddFil)
	oMBrowse:DeleteFilter( aAddFil[nX][ADDFIL_ID] )
	oMBrowse:AddFilter(	aAddFil[nX][ADDFIL_TITULO]		,;
						 	aAddFil[nX][ADDFIL_EXPR]			,;
						 	aAddFil[nX][ADDFIL_NOCHECK]		,;
						   	aAddFil[nX][ADDFIL_SELECTED]	,; 
						   	aAddFil[nX][ADDFIL_ALIAS]		,;
						   	aAddFil[nX][ADDFIL_FILASK]		,;
						  	aAddFil[nX][ADDFIL_FILPARSER]	,;
						   	aAddFil[nX][ADDFIL_ID] )		 
	oMBrowse:ExecuteFilter()	 
Next nX	

If IsInCallStack("TMKA061") 
	cCodLista := SU4->U4_LISTA	
	aDadosSX2  := CRMXGetSX2("SU4")	
	If !Empty(aDadosSX2)
		cUnicoList  := ("SU4")->&(aDadosSX2[1])
	EndIf
	cFiltro := "AOC_CHVLST=='"+cUnicoList+"'"
	oMBrowse:SetFilterDefault(cFiltro)//"Filtro de Campanhas"
Else
	cFiltro := CRMXFilEnt("AOC", .T.)
	oMBrowse:DeleteFilter( "AO4_FILENT" )
	oMBrowse:AddFilter(STR0001,cFiltro,.T.,.T.,"AO4", , , "AO4_FILENT")//"Filtro do CRM"
	oMBrowse:ExecuteFilter()
	
	If  !( FunName() == "CRMA250" ) .And. ProcName( 2 ) <> "CRMA290RFUN"  
		aDadosSX2  := CRMXGetSX2(cAlias)
		If !Empty(aDadosSX2)
			cCodEnt := (cAlias)->&(aDadosSX2[1])
		EndIf	
		cFiltroEnt := "AOG_ENTIDA = '"+cAlias+"' AND AOG_CHAVE = '"+xFilial(cAlias)+cCodEnt+"' AND D_E_L_E_T_ = ' '"
		oMBrowse:DeleteFilter( "AOG_FILENT" )
		oMBrowse:AddFilter(STR0046,cFiltroEnt,.T.,.T.,"AOG", , , "AOG_FILENT")//"Filtro de Entidade"
		oMBrowse:ExecuteFilter()
	EndIf
EndIf

oMBrowse:SetDescription(STR0004) //"Cadastro de Campanha Rápida"
oMBrowse:SetChgAll(.F.)	
oMBrowse:SetSeeAll(.F.)
oMBrowse:DisableDetails(.F.)

If !lWidget
	//Cria visoes e graficos padrão da rotina
	oTableAtt := TableAttDef()
	oMBrowse:SetAttach( .T. )
	oMBrowse:SetViewsDefault(oTableAtt:aViews)
	oMBrowse:SetChartsDefault(oTableAtt:aCharts)	
	oMBrowse:SetIDChartDefault( "CRDate" )
	oMBrowse:SetMainProc("CRMA250")
	oMBrowse:SetTotalDefault("AOC_CODIGO","COUNT",STR0040) // "Total de Registros"
	oMBrowse:Activate()	
EndIf

Return Nil

//------------------------------------------------------------------------------
/*/	{Protheus.doc} TableAttDef

Cria as visões e gráficos padrão para Campanhas Rápidas.

@sample	TableAttDef()

@param		Nenhum

@return	ExpA - Array de Objetos com as Visoes.

@author	Aline Kokumai
@since		06/06/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt	:= FWTableAtt():New()
Local oMyVision	:= Nil 					//Visão Minhas Campanhas Rapidas
Local oCRDate	:= Nil						//Gráfico Campanhas Rápidas por Data de Cadastro
Local oQualifi	:= Nil	 					//Gráfico Qualificação de Suspects e Prospects
Local aRole		:= CRMXGetPaper()
Local cCodUsr	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local cRole		:= ""

If ! ( Empty( aRole ) ) 
	cUser 	:= aRole[1]
	cRole	:= aRole[2] + aRole[3]
EndIf

oTableAtt:SetAlias("AOC")

oMyVision := FWDSView():New()
oMyVision:SetName( STR0037 ) //"Minhas Campanhas Rápidas"
oMyVision:SetID("MyVision") 
oMyVision:SetPublic( .T. )
oMyVision:SetCollumns( {	"AOC_CODIGO", "AOC_DESCAM", "AOC_DTCAD", "AOC_TIPO", "AOC_QTDE", "AOC_OPORTU" ,;
						 	"AOC_SUSPEC", "AOC_PROSPE", "AOC_DESQUA" } )
oMyVision:SetOrder( 1 ) //AOC_FILIAL+AOC_CODIGO                                                                                                                                           
oMyVision:AddFilterRelation( 'AO4', 'AO4_CHVREG', 'AOC_FILIAL+AOC_CODIGO' )
If ! Empty(cRole)
	oMyVision:AddFilter( STR0037, "AO4_ENTIDA = 'AOC' .AND. AO4_CODUSR = '" + cUser + "' .AND. ( AO4_USRPAP = '" + cRole + "' .OR. AO4_USRPAP = ' ' ) .AND. AO4_CTRLTT = 'T'", 'AO4' ) //"Minhas Campanhas Rápidas"
Else						 
	oMyVision:AddFilter( STR0037, "AO4_ENTIDA = 'AOC' .AND. AO4_CODUSR = '" +cCodUsr+ "' .AND. AO4_CTRLTT = 'T'", 'AO4' ) //"Minhas Campanhas Rápidas"
EndIf
oTableAtt:AddView(oMyVision)

oQualifi := FWDSChart():New()
oQualifi:SetName( STR0038 ) //"Qualificação de Suspects e Prospects" 
oQualifi:SetTitle( STR0038 )//"Qualificação de Suspects e Prospects" 
oQualifi:SetID("Qualifi") 
oQualifi:SetPublic( .T. )
oQualifi:SetSeries( { { "AOC", "AOC_SUSPEC", "SUM" }, { "AOC", "AOC_PROSPE", "SUM" } } )
oQualifi:SetCategory( { { "AOC", "AOC_DESCAM" } } )
oQualifi:SetType( "BARCOMPCHART" ) //Grafico de Barras
oQualifi:SetLegend( CONTROL_ALIGN_BOTTOM )//Inferior
oQualifi:SetTitleAlign( CONTROL_ALIGN_CENTER )
oTableAtt:AddChart(oQualifi)

oCRDate := FWDSChart():New()
oCRDate:SetName( STR0039 ) //"Por Data de Criação"
oCRDate:SetTitle( STR0039 )//"Por Data de Criação"
oCRDate:SetID("CRDate") 
oCRDate:SetPublic( .T. )
oCRDate:SetSeries( { { "AOC", "AOC_CODIGO", "COUNT" } } )
oCRDate:SetCategory( { { "AOC", "AOC_DTCAD" } } )
oCRDate:SetType( "BARCOMPCHART" ) //Grafico de Barras
oCRDate:SetLegend( CONTROL_ALIGN_BOTTOM ) //Inferior
oCRDate:SetTitleAlign( CONTROL_ALIGN_CENTER )
oTableAtt:AddChart(oCRDate)

Return(oTableAtt)

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operacoes que serao utilizadas pela aplicacao

@return   	aRotina - Array das operacoes

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local nPos        := 0
Local aRotina     := {}
Local aAtiv       := {}
Local aAnotac     := {}
Local aEntRelac   := {}

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.CRMA250' OPERATION 2 ACCESS 0 //Visualizar

If IsInCallStack("TMKA061") 
	ADD OPTION aRotina TITLE STR0025 ACTION 'CRM250Inc()' OPERATION 3 ACCESS 0 //Incluir
	ADD OPTION aRotina TITLE STR0026 ACTION 'VIEWDEF.CRMA250' OPERATION 4 ACCESS 0 //Alterar
EndIf
ADD OPTION aRotina 	Title STR0027 ACTION "VIEWDEF.CRMA250" OPERATION 5 ACCESS 0	 //Excluir
ADD OPTION aEntRelac Title STR0031 ACTION "Tk310Memb()" OPERATION 6 ACCESS 0	    //Membros de Campanha
ADD OPTION aRotina 	Title STR0036 ACTION "CRM250ATIV()" OPERATION 7 ACCESS 0	    //Distribuir Atividades
ADD OPTION aEntRelac Title STR0028 ACTION "CRMA260()" OPERATION 7 ACCESS 0	       //Respostas de Campanha
ADD OPTION aEntRelac Title STR0032 ACTION "CRMA200('AOC')" OPERATION 8 ACCESS 0	//Privilégios

aEntRelac := CRMXINCROT( "AOC", aEntRelac )

nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA190Con()",Nil) })
If nPos > 0 
	ADD OPTION aRotina TITLE aEntRelac[nPos][1] ACTION aEntRelac[nPos][2] OPERATION 8  ACCESS 0//"Conectar"
	Adel(aEntRelac,nPos)
	Asize(aEntRelac,Len(aEntRelac)-1)
EndIf

nPos := ASCAN(aEntRelac, { |x|  IIF(ValType(x[2]) == "C", x[2] == "CRMA180()", Nil) })
If nPos > 0
	ADD OPTION aAtiv   TITLE STR0042 ACTION "CRMA180()" OPERATION 8  ACCESS 0 //"Todas as ATividades"
	aEntRelac[nPos][2] := aAtiv
EndIf

nPos := ASCAN(aEntRelac, { |x| IIF(ValType(x[2]) == "C", x[2] == "CRMA090()", Nil)})
If nPos > 0
	ADD OPTION aAnotac   TITLE STR0043 ACTION "CRMA090(3)" OPERATION 3  ACCESS 0 //"Nova Anotação"
	ADD OPTION aAnotac   TITLE STR0044 ACTION "CRMA090()" OPERATION 8  ACCESS 0 //"Todas as Anotações" 
	aEntRelac[nPos][2] := aAnotac
EndIf

Asort(aEntRelac,,,{ | x,y | y[1] > x[1] } )
ADD OPTION aRotina TITLE  STR0045 ACTION aEntRelac 	    OPERATION 8  ACCESS 0//"Relacionadas"


Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Modelo de dados (Regra de Negocio)

@return   	oModel - Objeto do modelo

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oStruAOC := FWFormStruct( 1, 'AOC', /*bAvalCampo*/,/*lViewUsado*/ )

Local oModel
Local bCommit	:= {|oModel| CRM250Comt(oModel)}

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('CRMA250',/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)

// Adiciona ao modelo uma estrutura de formulario de edicao por campo
oModel:AddFields( 'AOCMASTER', /*cOwner*/, oStruAOC, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
       
// Adiciona a descriao do Modelo de Dados
oModel:SetDescription( STR0004 ) //"Cadastro de Campanhas Rapidas"

// Adicao do modelo da AO4 para evitar a validacao indevida do relacionamento SX9 antes da funcao CRMA200PAut
GdModel("AOCMASTER", oModel, "AO4", "AOC" )
GdModel("AOCMASTER", oModel, "AOG", "AOC" )


oModel:SetPrimaryKey( {} )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Interface de interacao com o Modelo de Dados (Model)

@return   	oView - Objeto da View

@author	Paulo Figueira
@since		17/02/2014
@version	P12 
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= Nil	
Local oModel   	:= FWLoadModel( 'CRMA250' )
Local oStruAOC 	:= FWFormStruct( 2, 'AOC', /*bAvalCampo*/,/*lViewUsado*/ ) 

oStruAOC:RemoveField( "AOC_CHVLST" )	
oStruAOC:AddGroup( "GRUPO01", STR0029, "", 2 ) //"Detalhes da Campanha Rápida"
oStruAOC:AddGroup( "GRUPO02", STR0030, "", 2 ) //"Indicadores"
oStruAOC:SetProperty("AOC_CODIGO" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruAOC:SetProperty("AOC_DESCAM" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruAOC:SetProperty("AOC_DESCRI"  , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruAOC:SetProperty("AOC_DTCAD" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruAOC:SetProperty("AOC_HRCAD" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruAOC:SetProperty("AOC_LISTMK" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruAOC:SetProperty("AOC_LISTDE" , MVC_VIEW_GROUP_NUMBER, "GRUPO01" )
oStruAOC:SetProperty("AOC_QTDE" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruAOC:SetProperty("AOC_OPORTU" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruAOC:SetProperty("AOC_SUSPEC" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruAOC:SetProperty("AOC_PROSPE" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )
oStruAOC:SetProperty("AOC_DESQUA" , MVC_VIEW_GROUP_NUMBER, "GRUPO02" )

oView := FWFormView():New()
// Define qual o Modelo de dados sera utilizado
oView:SetModel( oModel )

oView:AddField( 'VIEW_AOC', oStruAOC, 'AOCMASTER' )

// Criar um "box" Horizontal
oView:CreateHorizontalBox( 'TELA_CAB' , 100 )

// Relaciona o identificador (ID) da View com o "box" para exibicao
oView:SetOwnerView("VIEW_AOC",'TELA_CAB')

oView := CRMXAddAct("AOC",oView)//Adcionar Rotinas no 'Ações relacionadas' do Formulário

oView:SetCloseOnOk({|| .T.} )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM250Inc

Inclusão do cadastro. 

@sample		CRM250Inc()

@param			Nenhum

@return		Nenhum

@author		Aline Kokumai
@since			24/04/2014
@version		P12
/*/
//------------------------------------------------------------------------------
Function CRM250Inc()

Local aArea		:= GetArea()
Local oModel     	:= Nil 
Local oView      	:= Nil
local lRet			:= .T.
Local aSize     	:= FWGetDialogSize( oMainWnd ) 

oModel := FWLoadModel("CRMA250")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
oModel:GetModel("AOCMASTER"):SetValue("AOC_FILIAL",	xFilial("AOC"))			
oModel:GetModel("AOCMASTER"):SetValue("AOC_DTCAD",	Date())
oModel:GetModel("AOCMASTER"):SetValue("AOC_HRCAD",	SubStr(Time(),1,5))
oModel:GetModel("AOCMASTER"):SetValue("AOC_HRCAD",	SubStr(Time(),1,5))
oModel:GetModel("AOCMASTER"):SetValue("AOC_LISTMK",	cCodLista) 
oModel:GetModel("AOCMASTER"):SetValue("AOC_LISTDE",	Posicione("SU4",1,xFilial("SU4") + cCodLista, "U4_DESC"))
oModel:GetModel("AOCMASTER"):SetValue("AOC_CHVLST",	cUnicoList)
		
oView := FWLoadView("CRMA250")
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_INSERT) 
oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar(.T.)            
oFWMVCWin:SetView(oView)
oFWMVCWin:SetCentered(.T.)
oFWMVCWin:SetPos(aSize[1],aSize[2])
oFWMVCWin:SetSize(aSize[3],aSize[4])
oFWMVCWin:SetTitle(STR0025)//"Incluir"
oFWMVCWin:oView:BCloseOnOk := {|| .T.  }
oFWMVCWin:Activate()

RestArea(aArea)

Return lRet 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMDscEnt(cUnicoEnt)

Descrição do Membro da Campanha (Camapanhas Rapidas)

@sample 	CRMDscEnt(cUnicoEnt) ->	Retorna descricao da entidade posicionada

@return   	cDescEnt -> Descricao do codigo da entidade 

@author	Paulo Figueira
@since		25/03/2014
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMDscEnt(cUnicoEnt)

Local aArea			:= GetArea()
Local cDescEnt		:= ""
Local cEntidade		:= ""
Local cFilList		:= ""

Default cUnicoEnt	:= ""

cEntidade:= SU6->U6_ENTIDA

DBSelectArea(cEntidade)
(cEntidade)->(DBSetOrder(1))  //ACH|SUS|SA1: XX_FILIAL + XX_CODIGO + XX_LOJA //SU5: U5_FILIAL + U5_CODIGO
If cEntidade == "SA1"
	cDescEnt:= Posicione("SA1",1,xFilial("SA1") + cUnicoEnt, "A1_NOME")

ElseIf cEntidade == "ACH"
	cDescEnt:= Posicione("ACH",1,xFilial("ACH") + cUnicoEnt, "ACH_RAZAO")

ElseIf cEntidade == "SUS"
	cDescEnt:= Posicione("SUS",1,xFilial("SUS") + cUnicoEnt, "US_NOME")

ElseIf cEntidade == "SU5"
	cDescEnt:= Posicione("SU5",1,xFilial("SU5") + cUnicoEnt, "U5_CONTAT")
EndIf

RestArea(aArea)

Return cDescEnt 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM250Comt

Bloco de Commit. 

@sample		CRM250Comt(oModel)

@param			oModel 		Objeto do modelo 

@return		lRet		.T.

@author		Aline Kokumai
@since			18/04/2014
@version		P12
/*/
//------------------------------------------------------------------------------

Static Function CRM250Comt( oModel )

Local aArea		:= GetArea()   
Local aAreaAO4	:= AO4->(GetArea())
Local cAliasAOG	:= GetNextAlias()     
Local cAliasSU4	:= SU4->(GetArea())                    
Local nOpc			:= oModel:GetOperation()   
Local cUnico		:= ""							
Local cEntidade	:= ""
Local cUnicoEnt	:= ""
Local nLenSX8		:= GetSx8Len()
Local lRet			:= .T.  
Local cCodCamp	:= oModel:GetModel("AOCMASTER"):GetValue("AOC_CODIGO")
//Local cDescCamp	:= oModel:GetModel("AOCMASTER"):GetValue("AOC_DESCAM")
Local aNvlEstrut	:= {}
Local aExecAuto	:= {}
Local cChave		:= ""
Local lContinua	:= .T.

//X2_UNICO da Campanha Rapida
cUnico := xFilial("AOC")+cCodCamp

If nOpc == MODEL_OPERATION_DELETE
	//Busca os membros para efetuar a exclusão
	BeginSql Alias cAliasAOG
	
		SELECT  AOG.AOG_ENTIDA
				,AOG.AOG_CHAVE
				,AOG.AOG_CHVLST
		FROM	%table:AOG% AOG
		WHERE	AOG.AOG_FILIAL = %xFilial:AOG%
		AND		AOG.AOG_CHVCAM = %Exp:cUnico%
		AND		AOG.AOG_TIPCAM = '2'
		AND		AOG.%NotDel% 
		
	EndSql
	
	DbSelectArea("AOG")
	AOG->(DbSetOrder(3)) // AOG_FILIAL+AOG_CHVLST+AOG_CHAVE+AOG_CHVCAM+AOG_TIPCAM
	
	While (cAliasAOG)->(!EOF())
		If AOG->(DbSeek(xFilial("AOG")+(cAliasAOG)->AOG_CHVLST+(cAliasAOG)->AOG_CHAVE+cUnico+"2"))
			RecLock("AOG",.F.)
				DbDelete()
			AOG->(MsUnlock())
		EndIf
		(cAliasAOG)->(DbSkip())
	End		
	
	(cAliasAOG)->(DBCloseArea()) 

ElseIf nOpc == MODEL_OPERATION_INSERT
	
	//Grava os dados da campanha rapida e os membros, conforme a lista de Marketing selecionada	
	DBSelectArea("SU6")
	SU6->(DBSetOrder(1))//U6_FILIAL+U6_LISTA+U6_CODIGO                                                                                                                                    
	SU6->(DBGoTop())
	
	IF dbSeek(xFilial("SU6") + cCodLista)
		While (!SU6->(EOF()) .And. SU6->U6_FILIAL == xFilial("SU6") .And. SU6->U6_LISTA == cCodLista )
			//X2 Unico da Entidade
			cEntidade:= SU6->U6_ENTIDA
			DBSelectArea(cEntidade) 
			(cEntidade)->(DBSetOrder(1)) //ACH|SUS|SA1: XX_FILIAL + XX_CODIGO + XX_LOJA //SU5: U5_FILIAL + U5_CODIGO
			If cEntidade <> "SU5"
				If dbSeek(xFilial(cEntidade)+ AllTrim(SU6->U6_CODENT))
					aDadosSX2  := CRMXGetSX2(cEntidade)
					If !Empty(aDadosSX2)
		      			cUnicoEnt  := (cEntidade)->&(aDadosSX2[1])
		    	  	EndIf	
		 		EndIf     		
			Else
				If dbSeek(xFilial(cEntidade)+ AllTrim(SU6->U6_CONTATO))
					aDadosSX2  := CRMXGetSX2(cEntidade)
					If !Empty(aDadosSX2)
		      			cUnicoEnt  := (cEntidade)->&(aDadosSX2[1])
		      		EndIf	
		 		EndIf     
			EndIf
			//Grava Membros da Campanha
			If RecLock("AOG",.T.)
          		AOG->AOG_FILIAL   :=    xFilial("AOG")    
              AOG->AOG_CODIGO   :=    GETSXENUM("AOG","AOG_CODIGO")
              AOG->AOG_ENTIDA   :=    Iif(!Empty(SU6->U6_ENTIDA) .And. !Empty(SU6->U6_CONTATO),"SU5",SU6->U6_ENTIDA)
              AOG->AOG_CHAVE    :=    xFilial(cEntidade)+cUnicoEnt
              AOG->AOG_CHVLST   :=    xFilial("SU4")+cUnicoList
              AOG->AOG_TIPCAM   :=    "2"
              AOG->AOG_CHVCAM   :=    xFilial("AOC")+cCodCamp
              AOG->(MsUnlock())       
              ConfirmSX8()            
           Else
          		lRet := .F.
              While GetSx8Len() > nLenSX8
              	RollBackSX8()
              EndDo
          	EndIf 
		
		SU6->(DbSkip())
		EndDo
	EndIf	
	//Atualiza a data da última utilizacao da lista de Marketing
	TK61DtList( cCodLista )
EndIf

FWFormCommit(oModel,Nil,{|oModel,cId,cAlias| CRMA250CmtAft(oModel,cId,cAlias)})

RestArea( aAreaAO4 )
RestArea( aArea )

Return( lRet )


//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRMA250CmtAft

Bloco de transacao durante o commit do model. 

@sample	CRMA250CmtAft(oModel,cId,cAlias)

@param		ExpO1 - Modelo de dados
			ExpC2 - Id do Modelo
			ExpC3 - Alias

@return	ExpL  - Verdadeiro / Falso

@author	Anderson Silva
@since		06/08/2014
@version	12               
/*/
//------------------------------------------------------------------------------
Static Function CRMA250CmtAft(oModel,cId,cAlias)

Local nOperation	:= oModel:GetOperation()
Local cChave    	:= ""		
Local aAutoAO4  	:= {}
Local lRetorno 	:= .T.
		
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Adiciona ou Remove o privilegios deste registro.  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cId == "AOCMASTER" .AND. ( nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_DELETE ) 
	cChave 	:= PadR( xFilial("AOC")+oModel:GetValue("AOC_CODIGO"),TAMSX3("AO4_CHVREG")[1])
	aAutoAO4	:= CRMA200PAut(nOperation,"AOC",cChave,/*cCodUsr*/,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)    
	lRetorno	:= CRMA200Auto(aAutoAO4[1],aAutoAO4[2],nOperation)
EndIf 

Return(lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM250ATIV

Rotina para Chamar a a tela de atividades para cadastro e distribuição para os 
registros da lista  

@sample		CRM250ATIV()

@param			Nenhum

@return		Nenhum

@author		Victor Bitencourt
@since			23/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------
Function CRM250ATIV() 

Local lRet := .T.

Processa( { || CRM250DTRA() },STR0033,STR0034)  // "Aguarde"//"Distribuido Atividades para lista da campanha ..." 

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM250DTRA

Rotina para distribuir atividades para os regidtros da lista de marketing 

@sample		CRM250DTRA()

@param			Nenhum

@return		Nenhum

@author		Victor Bitencourt
@since			22/04/2014
@version		12.0
/*/
//------------------------------------------------------------------------------
Function CRM250DTRA() 

Local lOk			:= .F.
Local lFirst		:= .T. 
Local lProcessa 	:= .F.
Local cChvCamp		:= "" 
Local cDesTin		:= ""
Local cRemete		:= ""
Local cBodyPadrao	:= ""
Local cChvReg		:= ""
Local cBodyMesc		:= ""
Local cCodRastr		:= ""
Local cCodUSR		:= ""
Local aAnexos		:= {}
Local aExecAuto		:= {}
Local aAreaTMP		:= {}
Local aDadUsr		:= {}
Local nTam			:= 0


Private lMsErroAuto := .F.
Private aCRM180ANX  := {}

cChvCamp := xFilial("AOG")+AOC->AOC_CODIGO
BeginSql Alias "TMPAOG"
	SELECT 
		AOG.AOG_ENTIDA,
		AOG.AOG_CHAVE
	FROM	%table:AOG% AOG
	WHERE	
		AOG.AOG_FILIAL = %xFilial:AOG% AND
		AOG.AOG_CHVCAM = %Exp:cChvCamp% AND
		AOG.AOG_TIPCAM = "2" AND
		AOG.%NotDel% 
EndSql

lOk := CRMA180( Nil, Nil, Nil, 3,TMPAOG->AOG_ENTIDA)//Incluir Atividades


If lOk .AND. FWAlertNoYes(STR0048,STR0047)//"Deseja enviar essas atividades a um usuário especifico ?"//"Usuário x Atividade"
	If Conpad1(,,,"AO3")
		cCodUSR := AO3->AO3_CODUSR
	EndIf
EndIf

If lOk	
		
	If Select(TMPAOG->AOG_ENTIDA) > 0
		aAreaTMP := (TMPAOG->AOG_ENTIDA)->(GetArea())
	Else
		DbSelectArea(TMPAOG->AOG_ENTIDA)
	EndIf		
	(TMPAOG->AOG_ENTIDA)->(DbSetOrder(1))
	
	If AOF->AOF_TIPO == TPEMAIL // Verificando o tipode de Atividade criada.
		aDadUsr   := CRM170GetS(.T.)// pegando os dados do usuario
		If aDadUsr[3]// verifica se é usuario do CRM
			cRemete := aDadUsr[_PREFIXO][_EndEmail]
		Else
			cRemete := UsrRetMail(If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) ) 
		EndIf
		Do Case // Pegando o Campo de Email do Registro
			Case TMPAOG->AOG_ENTIDA == "SA1"
				cCmpDest := "SA1->A1_EMAIL"
			Case TMPAOG->AOG_ENTIDA == "ACH"
				cCmpDest := "ACH->ACH_EMAIL"
			Case TMPAOG->AOG_ENTIDA == "SUS"
				cCmpDest := "SUS->US_EMAIL"
			Case TMPAOG->AOG_ENTIDA == "SU5"
				cCmpDest := "SU5->U5_EMAIL"
		EndCase
		
		If AOF->AOF_ANEXO == "1"
			aAnexos := CRMA180ANX("AOF",XFilial("AOF")+AOF->AOF_CODIGO)
		EndIf
	EndIf
		
	While TMPAOG->(!EOF())
		
		nTam := IIF(TMPAOG->AOG_ENTIDA=="SU5",6,8)
		cChvReg := Right(Alltrim(TMPAOG->AOG_CHAVE),nTam)
		
		If (TMPAOG->AOG_ENTIDA)->(DbSeek(TMPAOG->AOG_CHAVE))
			
			Do Case //Não procesar registros que estão bloqueados por MSBLQL 
				Case TMPAOG->AOG_ENTIDA == "SA1"
						lProcessa := IIF(SA1->A1_MSBLQL == "2", .T., .F.)
				Case TMPAOG->AOG_ENTIDA == "SUS"
						lProcessa := IIF(SUS->US_MSBLQL == "2", .T., .F.)
				Case TMPAOG->AOG_ENTIDA == "ACH"
						lProcessa := IIF(ACH->ACH_MSBLQL == "2", .T., .F.)
				Case TMPAOG->AOG_ENTIDA == "SU5"
						lProcessa := IIF(SU5->U5_MSBLQL == "2", .T., .F.)
			EndCase	
			
			If lProcessa
				AAdd(aExecAuto,{"AOF_FILIAL",xFilial("AOF"),Nil})
				If lFirst
					AAdd(aExecAuto,{"AOF_CODIGO", AOF->AOF_CODIGO ,Nil})
					nOper  := 4
					cBodyPadrao := AOF->AOF_DESCRI // pegando o html padrao 
					cCodRastr   := AllTrim(SHA1(AOF->AOF_CODIGO)) //codigo rastreavel para imagens no html padrao
				Else 
					nOper  := 3	
				EndIf
				
				Do Case 
					Case AOF->AOF_TIPO == TPTAREFA
							AAdd(aExecAuto,{"AOF_DESCRI",AOF->AOF_DESCRI  ,Nil})
							AAdd(aExecAuto,{"AOF_DTINIC",AOF->AOF_DTINIC  ,Nil})
							AAdd(aExecAuto,{"AOF_HRINIC",AOF->AOF_HRINIC  ,Nil})
							AAdd(aExecAuto,{"AOF_DTFIM" ,AOF->AOF_DTFIM   ,Nil})
							AAdd(aExecAuto,{"AOF_HRFIM" ,AOF->AOF_HRFIM   ,Nil})
							AAdd(aExecAuto,{"AOF_PERCEN",AOF->AOF_PERCEN  ,Nil})
							AAdd(aExecAuto,{"AOF_PRIORI",AOF->AOF_PRIORI  ,Nil})
							AAdd(aExecAuto,{"AOF_HRLEMB",AOF->AOF_HRLEMB  ,Nil})
							AAdd(aExecAuto,{"AOF_HRLEMB",AOF->AOF_HRLEMB  ,Nil})
							AAdd(aExecAuto,{"AOF_STATUS",AOF->AOF_STATUS  ,Nil})
					
					Case AOF->AOF_TIPO == TPCOMPROMISSO
							AAdd(aExecAuto,{"AOF_DESCRI",AOF->AOF_DESCRI  ,Nil})
							AAdd(aExecAuto,{"AOF_PARTIC",AOF->AOF_PARTIC  ,Nil})
							AAdd(aExecAuto,{"AOF_LOCAL" ,AOF->AOF_LOCAL   ,Nil})
							AAdd(aExecAuto,{"AOF_DTINIC",AOF->AOF_DTINIC  ,Nil})
							AAdd(aExecAuto,{"AOF_HRINIC",AOF->AOF_HRINIC  ,Nil})
							AAdd(aExecAuto,{"AOF_DTFIM" ,AOF->AOF_DTFIM   ,Nil})
							AAdd(aExecAuto,{"AOF_HRFIM" ,AOF->AOF_HRFIM   ,Nil})
							AAdd(aExecAuto,{"AOF_PERCEN",AOF->AOF_PERCEN  ,Nil})
							AAdd(aExecAuto,{"AOF_PRIORI",AOF->AOF_PRIORI  ,Nil})
							AAdd(aExecAuto,{"AOF_STATUS",AOF->AOF_STATUS  ,Nil})
				
					Case AOF->AOF_TIPO == TPEMAIL
							AAdd(aExecAuto,{"AOF_DESCRI",CRM170MEEM(cBodyPadrao,TMPAOG->AOG_ENTIDA) ,Nil})		
							AAdd(aExecAuto,{"AOF_DESTIN",(TMPAOG->AOG_ENTIDA)->&(cCmpDest)         ,Nil})
							AAdd(aExecAuto,{"AOF_LNKIMG",AOF->AOF_LNKIMG  ,Nil})
							AAdd(aExecAuto,{"AOF_REMETE",cRemete          ,Nil})
							AAdd(aExecAuto,{"AOF_PARTIC",AOF->AOF_PARTIC  ,Nil})
							AAdd(aExecAuto,{"AOF_STATUS",STPENDENTE       ,Nil})
							
				EndCase
				If !Empty(cCodUSR)
					AAdd(aExecAuto,{"AOF_CODUSR",cCodUSR			,Nil})
				EndIf
				AAdd(aExecAuto,{"AOF_CHVCAM",cChvCamp				,Nil})
				AAdd(aExecAuto,{"AOF_CODCAM",AOC->AOC_CODIGO		,Nil})
				AAdd(aExecAuto,{"AOF_TIPCAM","AOC"	 				,Nil})
				AAdd(aExecAuto,{"AOF_TIPO"  , AOF->AOF_TIPO      ,Nil})
				AAdd(aExecAuto,{"AOF_ASSUNT", AOF->AOF_ASSUNT    ,Nil})
				AAdd(aExecAuto,{"AOF_ENTIDA", TMPAOG->AOG_ENTIDA ,Nil})
				AAdd(aExecAuto,{"AOF_CHAVE" , cChvReg,Nil})
			
				CRMA180( aExecAuto, nOper, .T., Nil, Nil , aAnexos,,,, cCodRastr) // Importar agenda por rotina automatica
				lFirst := .F.
				Asize( aExecAuto, 0)
			EndIf	 	
		EndIf	
		TMPAOG->(DbSkip())
	EndDo
EndIf

aCRM180ANX := Nil
TMPAOG->(DbCloseArea())

Return lOk

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} GdModel

Cria um GridModel associado ao modelo informado no parãmetro, para evitar
a validação do SX9 da entidade principal do modelo informado com a AO4

@param, cIDModel, ID do modelo principal                              , String
@param, oModel  , Objeto do modelo a que o novo modelo serah associado, MPFormModel

@sample		GdModel(cIDModel, oModel)

@return, Nil

@author		Squad CRM/Faturamento
@since		30/06/2021
@version	12.1.27
/*/
//----------------------------------------------------------------------------------
Static Function GdModel(cIDMasterM, oModel, cAliasTab, cAliasMast )
Local oStruct := FWFormStruct(1,cAliasTab,/*bAvalCampo*/,/*lViewUsado*/)
Default cIDMasterM := ""
Default cAliasTab  := ""
Default cAliasMast := ""

oModel:AddGrid(cAliasTab+"CHILD",cIDMasterM,oStruct,/*bPreValid*/,/*bPosValid*/, , ,{|oGridModel, lCopy|LoadGd(oGridModel, lCopy, cAliasTab)})
Do Case
	Case cAliasTab == 'AO4'
		oModel:SetRelation( cAliasTab+"CHILD" ,{ { "AO4_FILIAL", "FWxFilial( 'AO4' )" }, { "AO4_ENTIDA", cAliasMast }, { "AO4_CHVREG", ( cAliasMast )->( IndexKey( 1 ) ) }  }, (cAliasTab)->( IndexKey( 1 ) ) )
	Case cAliasTab == 'AOG'
		oModel:SetRelation( cAliasTab+"CHILD" ,{ { "AOG_FILIAL", "FWxFilial( 'AOG' )" },{ "AOG_CHVCAM", ( cAliasMast )->( IndexKey( 1 ) ) }  }, (cAliasTab)->( IndexKey( 2 ) ) )
EndCase

oModel:GetModel(cAliasTab+"CHILD"):SetOnlyView()
oModel:GetModel(cAliasTab+"CHILD"):SetOnlyQuery()
oModel:GetModel(cAliasTab+"CHILD"):SetOptional(.T.)
oModel:GetModel(cAliasTab+"CHILD"):SetNoInsertLine(.T.)
oModel:GetModel(cAliasTab+"CHILD"):SetNoUpdateLine(.T.)
oModel:GetModel(cAliasTab+"CHILD"):SetNoDeleteLine(.T.)

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} LoadGd

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
Static Function LoadGd(oGridModel, lCopy, cAliasTab)
	
	Local aLoad      := {}
	Local oStruct := FWFormStruct(1,cAliasTab,/*bAvalCampo*/,/*lViewUsado*/)
	Local aFields    := {}
	Local nField     := 0
	Local nQtFields  := 0
	Local xValue     := Nil
	Local cField     := ""
	Local cType      := ""
	Local nLen       := 0

	aFields   := oStruct:GetFields()
	nQtFields := Len(aFields)

	AAdd(aLoad, {0,{}})

	For nField := 1 To nQtFields
		
		cField := aFields[nField][3]
		
		If Alltrim(cField) == cAliasTab+"_FILIAL"
			xValue := XFilial(cAliasTab)
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

	FwFreeObj(oStruct)
	FwFreeObj(aFields)

Return aLoad
 

