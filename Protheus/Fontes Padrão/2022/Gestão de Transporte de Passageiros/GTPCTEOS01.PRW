#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPCTEOS.CH'

/*/{Protheus.doc} GTPCTEOS
    (Chamada da rotina)
    @type  Function
    @author Diego Faustino
    @since 16/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPCTEOS01()
    
    FWMsgRun( /*oComponent*/,{ || CreateWorkArea() }, STR0001, STR0002 ) //"Aguarde", "Carregando Área de trabalho"	

Return 

/*/{Protheus.doc} GTPCTEBrow
    (Funcção responsavel por criar a WorkArea do CTE-OS)
    @type  Function
    @author Diego Faustino
    @since 16/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function GTPCTEBrow(oWorkArea)
    
    Local oBrowse := FWMBrowse():New()

	oBrowse:SetAlias("H61")
    oBrowse:SetDescription("Controle CTe-OS")

    //0=Normal;1=Complemento;2=Anulacao;3=Substituicao;4=Documento excluído;5=Cancelamento 
    oBrowse:AddLegend("H61_STATUS=='0'", "GREEN"     ,"Normal" ,"H61_STATUS")
    oBrowse:AddLegend("H61_STATUS=='1'", "YELLOW"    ,"Complemento" ,"H61_STATUS")
    oBrowse:AddLegend("H61_STATUS=='2'", "GRAY"      ,"Anulacao" ,"H61_STATUS")
    oBrowse:AddLegend("H61_STATUS=='3'", "BROWN"     ,"Substituicao" ,"H61_STATUS")
    oBrowse:AddLegend("H61_STATUS=='4'", "RED"       ,"Documento excluído" ,"H61_STATUS")
    oBrowse:AddLegend("H61_STATUS=='5'", "BLACK"     ,"Cancelamento" ,"H61_STATUS")

    //1=Pendente;2=Transmitido;3=Erro de Transmissao;4=Documento Impresso
    oBrowse:AddLegend("H61_STATRA=='1'", "WHITE"     ,"Pendente" ,"H61_STATRA")
    oBrowse:AddLegend("H61_STATRA=='2'", "GREEN"     ,"Transmitido" ,"H61_STATRA")
    oBrowse:AddLegend("H61_STATRA=='3'", "RED"       ,"Erro de Transmissao" ,"H61_STATRA")
    oBrowse:AddLegend("H61_STATRA=='4'", "BLUE"      ,"Documento Impresso" ,"H61_STATRA")

	oBrowse:SetFilterDefault ( 'H61_FILIAL == "' + xFilial('H61') + '" ')
        
    oBrowse:setOwner( oWorkarea:GetPanel( "WDGT01" ) )

    oBrowse:Activate()

Return(oBrowse)

/*/{Protheus.doc} ViewDef
    (Função responsavel pela criação workarea do monitor operacional)
    @type  Static Function
    @author Diego Faustino
    @since 16/11/2021
    @version version
    @param param_name, param_type, param_descr
    @return Retorna a view da rotina oView
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function CreateWorkArea()

Local cMenuItem     := Nil
Local oMenu         := Nil
Local oMenuItem     := Nil
Local aSize         := FWGetDialogSize( oMainWnd )
Local oDlgWA        := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0003, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) //"Monitor CTE-OS"
Local oWorkArea		:= FWUIWorkArea():New( oDlgWA )

oWorkarea:SetMenuWidth( 200 )

oMenu := FWMenu():New()
oMenu:Init()

//------------------------------------------------------------------------------------------------------
//  Gerenciais
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0003, "A") //"Monitor CTE-OS "
cMenuItem := oMenu:AddFolder(STR0025, "A") //Gerenciais
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0009   , "E", { || RetFun(oBrowse , "#CTEOS_INCLUIR") } )   //+ Incluir   
oMenuItem:AddContent( STR0020   , "E", { || RetFun(oBrowse , "#CTEOS_VISUALIZAR") } )   //+ Visualizar   
oMenuItem:AddContent( STR0021   , "E", { || RetFun(oBrowse , "#CTEOS_EXCLUIR") } )   //+ Excluir
oMenuItem:AddContent( STR0022   , "E", { || RetFun(oBrowse , "#CTEOS_EDITAR") } )   //+ Editar  
oMenuItem:AddContent( "+ Atualizar"   , "E", { || RetFun(oBrowse , "#CTEOS_ATUALIZAR") } )   //+ Editar     
oMenuItem:AddContent( STR0024   , "E", { || RetFun(oBrowse , "#CTEOS_LEGENDA") } )   //+ Legenda
   
//------------------------------------------------------------------------------------------------------
//  Excesso de Bagagem
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0029, "A") //Excesso de Bagagem
oMenuItem := oMenu:GetItem( cMenuItem )
oMenuItem:AddContent( STR0018   , "E", { || RetFun(oBrowse , "#CTEOS_EXCESSO_BAGAGEM") } )//+ Excesso de Bagagem	

//------------------------------------------------------------------------------------------------------
//  Eventos
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0026, "A")//Eventos CTE-OS
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0006   , "E", { || RetFun(oBrowse , "#CTEOS_TRASMISSAO") } )   //+ Transmitir	        
oMenuItem:AddContent( STR0008   , "E", { || RetFun(oBrowse , "#CTEOS_CANCELAR") } )   //+ Cancelar CTe-OS	   
oMenuItem:AddContent( STR0014   , "E", { || RetFun(oBrowse , "#CTEOS_CONSULTA_EVENTS") } )   //+ Consulta Eventos 	 
oMenuItem:AddContent( STR0015   , "E", { || RetFun(oBrowse , "#CTEOS_CONSULTA_CTEOS") } )   //+ Consulta CTeOS    
oMenuItem:AddContent( STR0016   , "E", { || RetFun(oBrowse , "#CTEOS_CARTA_CORRECAO") } )   //+ Carta de Correção  
oMenuItem:AddContent( STR0017	, "E", { || RetFun(oBrowse , "#CTEOS_ANULACAO") } )         //+ Gera Anulação CTe-OS
oMenuItem:AddContent( STR0019   , "E", { || RetFun(oBrowse , "#CTEOS_INUTILIZACAO") } )   //+ Inutilização	      

//------------------------------------------------------------------------------------------------------
//  Relatorios
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0027, "A") //Relatórios
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0007   , "E", { || RetFun(oBrowse , "#CTEOS_IMPRIMIR_DACTEOS") } )   //+ Imprimir DACTE-OS	 
oMenuItem:AddContent( STR0010   , "E", { || RetFun(oBrowse , "#CTEOS_EXPORTAR") } )   //+ Exportar CTEOS 

//------------------------------------------------------------------------------------------------------
//  Configuração
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0028, "A") //Configurações
oMenuItem := oMenu:GetItem( cMenuItem )
oMenuItem:AddContent( STR0013   , "E", { || RetFun(oBrowse , "#CTEOS_CONFIG_TSS") } )   //+ Configuração TSS	  
oMenuItem:AddContent( STR0011	, "E", { || RetFun(oBrowse , "#CTEOS_PARAM_CONFIG") } )   //+ Parametros de Conf.
oMenuItem:AddContent( STR0012	, "E", { || RetFun(oBrowse , "#CTEOS_PARAM_EVENTS") } )   //+ Parametros Eventos.

oWorkarea:SetMenu( oMenu )

oWorkarea:CreateHorizontalBox( "LINE01" ,aSize[3], .T. )
oWorkarea:SetBoxCols( "LINE01", { "WDGT01" } )

oWorkarea:Activate()

oBrowse := GTPCTEBrow(oWorkArea)

oDlgWA:lEscClose := .F.	
oDlgWA:Activate( , , , , , , EnchoiceBar( oDlgWA, {|| },  { || oDlgWA:End()}, , {}, , , , , .F., .F. ) ) //Ativa a janela criando uma enchoicebar

Return

/* /{Protheus.doc} RetFun
Funçaõ que define qual programa será executado
@type Function
@author 
@since 19/11/2021
@version 1.0
@param , numerico, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function RetFun(oBrowse,cId)

Do case
    Case cId == "#CTEOS_INCLUIR"
        FWExecView("Incluir", "GTPA850",MODEL_OPERATION_INSERT,,{|| .T.})//"INcluir"
	Case cId == "#CTEOS_VISUALIZAR"
        FWExecView("Visualizar", "GTPA850",MODEL_OPERATION_VIEW,,{|| .T.})//"VIsualizar"
    Case cId == "#CTEOS_EXCLUIR"    
        GA850Manut(5)
    Case cId == "#CTEOS_EDITAR"	
		GA850Manut(3)
    Case cId == "#CTEOS_ATUALIZAR"
        GA850Atual()
	Case cId == "#CTEOS_EXCESSO_BAGAGEM"
        GTPAViewBag()
    Case cId == "#CTEOS_LEGENDA" //"Legenda"
        GTPA850Leg()
    Case cId == "#CTEOS_TRASMISSAO" //Transmissão
        GTPC852()
    Case cId == "#CTEOS_CANCELAR"
        GTPC854Cancel()
    Case cId == "#CTEOS_CONSULTA_EVENTS"
        H61EventCons()
	Case cId == "#CTEOS_CONSULTA_CTEOS"
        H61StsCTeOS()
    Case cId == "#CTEOS_CARTA_CORRECAO"   
        GTPC856CCE()
    Case cId == "#CTEOS_ANULACAO"   
        GTPC857Anula()
    Case cId == "#CTEOS_INUTILIZACAO"   
        SpedNfeInut()
    Case cId == "#CTEOS_IMPRIMIR_DACTEOS" //IMPRESSAO   
        GTPC853PRINT()
    Case cId == "#CTEOS_EXPORTAR"   
        GTPC855EXP()
    Case cId == "#CTEOS_CONFIG_TSS"
        SpedNFeCfg()  
    Case cId == "#CTEOS_PARAM_CONFIG"
        CTeOSCfg()
    Case cId == "#CTEOS_PARAM_EVENTS"   
        SpedEpecPar()
    OtherWise
        FwAlertHelp('Funcionalidade ainda não disponibilizada!')		
EndCase

oBrowse:Refresh(.T.)

Return 

