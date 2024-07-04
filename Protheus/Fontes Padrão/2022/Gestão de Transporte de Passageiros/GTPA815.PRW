#Include "GTPA815.ch"
#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#INCLUDE "FWTABLEATTACH.CH"
#include 'parmtype.ch' 


/*/
 * {Protheus.doc} GTPA815()
 * Monitor do Manifesto - MDF
 * type    Function
 * author  Eduardo Ferreira
 * since   05/11/2019
 * version 12.25
 * param   oWorkArea
 * return  oBrowse
/*/
Function GTP815Brow(oWorkArea)
Local oBrowse := FWLoadBrw('GTPA810')
DbSelectArea('GI9')

oBrowse:SetFilterDefault('GI9->GI9_FILIAL == "' + xFilial('GI9') + '"')

oBrowse:setOwner(oWorkarea:GetPanel("WDGT01"))

oBrowse:DisableDetails()

oBrowse:Activate()

SetKey( VK_F5, { || RetFun(oBrowse, '#MANIFESTO_MONITOR')} ) 
Return oBrowse


/*/
 * {Protheus.doc} GTPA815()
 * Rotina responsavel pela workarea do monitor MDF
 * type    Function
 * author  Eduardo Ferreira
 * since   05/11/2019
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Function GTPA815()

FWMsgRun(/*oComponent*/, {|| CreateWorkArea()}, STR0001, STR0002)	 //"Aguarde" //"Carregando Área de Trabalho..."

Return 


/*/
 * {Protheus.doc} GTPA815()
 * Criação workarea do monitor operacional
 * type    Function
 * author  Eduardo Ferreira
 * since   05/11/2019
 * version 12.25
 * param   Não há
 * return  Não há
/*/
Static Function CreateWorkArea()
Local cMenuItem := Nil
Local oMenu     := Nil
Local oMenuItem := Nil
Local aSize     := FWGetDialogSize(oMainWnd)
Local oDlgWA    := MSDialog():New(aSize[1], aSize[2], aSize[3], aSize[4], STR0003,,,, nOr(WS_VISIBLE, WS_POPUP),,,,, .T.,,,, .F.)    //"Monitor MDF"
Local oWorkArea	:= FWUIWorkArea():New(oDlgWA)
Local oBrowse	:= Nil

oWorkarea:SetMenuWidth(200)

oMenu := FWMenu():New()

oMenu:Init()

//------------------------------------------------------------------------------------------------------
//  Entrada do Manifesto
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0004, "A")  //"Entrada do Manifesto"
oMenuItem := oMenu:GetItem(cMenuItem)

oMenuItem:AddContent(STR0005+ " [F5]", "E", {|| RetFun(oBrowse, "#MANIFESTO_MONITOR"  )}) //"+ Atualizar Monitor"
oMenuItem:AddContent(STR0006,          "E", {|| RetFun(oBrowse, "#MANIFESTO_VISUALIZA")}) //
oMenuItem:AddContent(STR0007         , "E", {|| RetFun(oBrowse, "#MANIFESTO_INCLUI"   )}) //"+ Inclusao"
oMenuItem:AddContent(STR0008         , "E", {|| RetFun(oBrowse, "#MANIFESTO_ALTERA"   )}) //"+ Alteração"
oMenuItem:AddContent(STR0009         , "E", {|| RetFun(oBrowse, "#MANIFESTO_EXCLUI"   )}) //"+ Exclusão"

//------------------------------------------------------------------------------------------------------
//  Menu Operacional - MDF
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0010, "A")  //"Manifesto MDF-e"
oMenuItem := oMenu:GetItem(cMenuItem)

oMenuItem:AddContent(STR0011, "E", {|| RetFun(oBrowse, "#OPERACIONAL_ENVIO" 		   	)}) //"+ Envio"
oMenuItem:AddContent(STR0015, "E", {|| RetFun(oBrowse, "#OPERACIONAL_IMPRESSAO_DAMDFE"	)}) //"+ Impressão da DAMDFE"

//------------------------------------------------------------------------------------------------------
//  "Operacional"
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0038, "A") //"Operacional"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0037	, "E", { || RetFun(oBrowse,"#ENCOMENDAS_RECEBIMENTO"  )} )//  "+ Recebimento"
oMenuItem:AddContent( STR0039   , "E", { || RetFun(oBrowse,"#ENCOMENDAS_RETIRADA"    )} )//  "+ Retirada"  

//------------------------------------------------------------------------------------------------------
//  Menu Operacional - Eventos
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0020, "A") //"Eventos"
oMenuItem := oMenu:GetItem(cMenuItem)

oMenuItem:AddContent(STR0043, "E", {|| RetFun(oBrowse, "#EVENTOS_VISUALIZAR"    	)}) //"+ Visualização Eventp"
oMenuItem:AddContent(STR0012, "E", {|| RetFun(oBrowse, "#EVENTOS_ENCERRAMENTO"    	)}) //"+ Encerramento"
oMenuItem:AddContent(STR0013, "E", {|| RetFun(oBrowse, "#EVENTOS_CANCELAMENTO"    	)}) //"+ Cancelamento"
oMenuItem:AddContent(STR0014, "E", {|| RetFun(oBrowse, "#EVENTOS_CONDUTOR_INCLUIR"	)}) //"+ Inclusão do Condutor"
If __cUserId == '000000' .And. dDataBase == StoD('20201119')
	oMenuItem:AddContent('EVENTO CTE', "E", {|| GTPA812() }) 
Endif

//------------------------------------------------------------------------------------------------------
// Averbação
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0016, "A")//STR0016 //"Averbação"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0011, "E", { || RetFun(oBrowse,"#AVB_ENVIO" 		)} ) //"+ Envio"
oMenuItem:AddContent( STR0017, "E", { || RetFun(oBrowse,"#AVB_CONSULTA" 	)} ) //"+ Consulta"
oMenuItem:AddContent( STR0013, "E", { || RetFun(oBrowse,"#AVB_CANCELAMENTO" )} ) //"+ Cancelamento"



//------------------------------------------------------------------------------------------------------
// Relatórios
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0040, "A")//"Relatórios"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0041, "E", { || RetFun(oBrowse,"#REL_RECEBIMENTO" 		)} ) //"+ Recebimento"
oMenuItem:AddContent( STR0042, "E", { || RetFun(oBrowse,"#REL_PENDENCIAS")} ) //"+ Pendências"


//------------------------------------------------------------------------------------------------------
//  Configurações
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0021, "A") //"Configurações"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0022 , "E", { || RetFun(oBrowse,"#TSS_CONFIG"	    	)} )//"+ Configuração TSS"
oMenuItem:AddContent( STR0023 , "E", { || RetFun(oBrowse,"#MDFE_NFE_CONFIG"		)} )//"+ Configuração MDFe"
oMenuItem:AddContent( STR0024 , "E", { || RetFun(oBrowse,"#MDFE_EPEC_CONFIG"	)} )//"+ Configuração EPEC"


oWorkarea:SetMenu(oMenu)

oWorkarea:CreateHorizontalBox("LINE01" ,aSize[3], .T.)
oWorkarea:SetBoxCols("LINE01", {"WDGT01"})

oWorkarea:Activate()

oBrowse := GTP815Brow(oWorkArea)

oDlgWA:lEscClose := .F.	
oDlgWA:Activate(,,,,,, EnchoiceBar( oDlgWA, {|| }, {|| oDlgWA:End()},, {},,,,, .F., .F.)) //Ativa a janela criando uma enchoicebar

Return


/*/
 * {Protheus.doc} GTPA815()
 * Chamada das Funções
 * type    Function
 * author  Eduardo Ferreira
 * since   05/11/2019
 * version 12.25
 * param   oBrowse, cId
 * return  Não há
/*/
Static Function RetFun(oBrowse, cId)

Do case
    
    case cID == "#MANIFESTO_VISUALIZA"
    	
        FWExecView(STR0025, "VIEWDEF.GTPA810",MODEL_OPERATION_VIEW,,{|| .T.})//"Visualização"
    case cID == "#MANIFESTO_INCLUI"
         GTPA810A() 
    case cID == "#MANIFESTO_ALTERA" 
    	If !(Empty(GI9->GI9_CODIGO))
    		FWExecView(STR0027, "VIEWDEF.GTPA810",MODEL_OPERATION_UPDATE,,{|| .T.})//"Alteração"
        Else
        	FwAlertHelp(STR0036) //'Nenhum registro encontrado' 
        Endif
    case cID == "#MANIFESTO_EXCLUI" 
    	If !(Empty(GI9->GI9_CODIGO))
    		FWExecView(STR0028, "GTPA810",MODEL_OPERATION_DELETE,,{|| .T.})//"Exclusão"
        Else
        	FwAlertHelp(STR0036) //'Nenhum registro encontrado') 
        Endif
    case cID == "#OPERACIONAL_ENVIO"
        If !(Empty(GI9->GI9_CODIGO))
            If (GI9_STATUS == '1')
                If (GI9->GI9_STATRA <> "1" .AND. GI9->GI9_STATRA <> "2" .AND. GI9->GI9_STATRA <> "6")
                    FwMsgRun(, {|| GTPA816ENV() }, ,STR0018)//"Envio"
                Else
                    FwAlertHelp(STR0044) 
                EndIf
            Else
                    FwAlertHelp(STR0045) 
            EndIf
        Else
            FwAlertHelp(STR0036) //'Nenhum registro encontrado') 
        EndIf
    	
    case cID == "#MANIFESTO_MONITOR"     	
		 FwMsgRun(, {|| GTPATUMDF() }, , STR0019)
		 FwMsgRun(, {|| GTPA813ATU() }, , STR0029)//"Atualizando eventos..."
	
	case cID == "#EVENTOS_VISUALIZAR"
        GTPA813()
    case cID == "#EVENTOS_ENCERRAMENTO"
        GTPA813E()
    case cID == "#EVENTOS_CANCELAMENTO"
        GTPA813C()
    case cID == "#EVENTOS_CONDUTOR_INCLUIR"
        GTPA813I()
    case cId = "#ENCOMENDAS_RETIRADA"
        GTPA809()
    Case cId == "#ENCOMENDAS_RECEBIMENTO"
        GTPA814()
	Case cId == "#AVB_ENVIO"
        GTPA808('1',STR0030)//"Envio"
    Case cId == "#AVB_CANCELAMENTO"
        GTPA808('2',STR0031)//"Cancelamento"
    Case cId == "#AVB_CONSULTA"
        GTPA808('3',STR0032)//"Consulta"
     
    Case cId == "#TSS_CONFIG"
        SpedNSeCFG()
    Case cId == "#MDFE_NFE_CONFIG"
        TME73PAR()
    Case cId == "#MDFE_EPEC_CONFIG"
        SpedEpecPar()            
    Case cId == "#OPERACIONAL_IMPRESSAO_DAMDFE"
    	If (GI9->GI9_STATRA == "2") 
            If ExistBlock("GTPDANDE")
                FwMsgRun(, {|| ExecBlock("GTPDANDE", .f., .f., {GI9->(Recno())}) }, ,STR0034) 		    
            Else
                FwAlertHelp(STR0035) //'RdMake (GTPDANDE) não compilado.'
            Endif
        ElseIf (GI9->GI9_STATRA == "6") 
            FwAlertHelp(STR0046)//'Manifestos Operacionais não possíbilitam impressão de DAMDFe.'
        Else
            FwAlertHelp(STR0047)//'O Status do MDFe não permite impressão de DAMDFe.'
        EndIf
         

    Case cId == "#REL_RECEBIMENTO"
        GTPR814()
    Case cId == "#REL_PENDENCIAS"
        GTPR815()
	OtherWise
        FwAlertHelp(STR0033) //'Funcionalidade ainda não disponibilizada!'
			
EndCase

oBrowse:Refresh(.T.)

Return 
   
