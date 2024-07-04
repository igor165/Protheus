#Include "GTPA800.ch"
#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#INCLUDE "FWTABLEATTACH.CH"
#include 'parmtype.ch' 



/*/{Protheus.doc} GTP800Brow
(Rotina responsavel pela workarea do monitor CTE)
@type function
@author GTP
@since 28/10/2020
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTP800Brow(oWorkArea)
Local oBrowse	:= FWLoadBrw('GTPA801')

oBrowse:SetFilterDefault ( 'G99_FILIAL == "' + xFilial('G99') + '"')

oBrowse:setOwner( oWorkarea:GetPanel( "WDGT01" ) )

oBrowse:DisableDetails()
oBrowse:Activate()

SetKey( VK_F5, { || RetFun(oBrowse, '#REFRESH_MONITOR')} ) 

Return oBrowse

/*/{Protheus.doc} GTPA800
(Rotina responsavel pela workarea do monitor CTE)
@type function
@author gustavo.silva2
@since 27/09/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPA800()

FWMsgRun(/*oComponent*/, { ||  CreateWorkArea() }, STR0007, STR0008 )		// "Aguarde" / "Carregando Área de Trabalho..."   

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} CreateWorkArea
Função responsavel pela criação workarea do monitor operacional
@type Function
@author gustavo.silva2
@since 11/07/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function CreateWorkArea()

Local cMenuItem     := Nil
Local oMenu         := Nil
Local oMenuItem     := Nil
Local aSize         := FWGetDialogSize( oMainWnd )
Local oDlgWA        := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0006, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Monitor CTE"
Local oWorkArea		:= FWUIWorkArea():New( oDlgWA )
Local oBrowse		:= Nil

oWorkarea:SetMenuWidth( 200 )

oMenu := FWMenu():New()
oMenu:Init()

//------------------------------------------------------------------------------------------------------
//  Entrada de documentos
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0001, "A") //"Entrada de Encomenda"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0010 + " [F5]"     , "E", { || RetFun(oBrowse,"#REFRESH_MONITOR"        )} )// "+ Refresh do monitor"
oMenuItem:AddContent( STR0012               , "E", { || RetFun(oBrowse,"#ENCOMENDAS_VISUALIZA"   )} )// "+ Visualização"
oMenuItem:AddContent( STR0011               , "E", { || RetFun(oBrowse,"#ENCOMENDAS_INCLUI"      )} )// "+ Inclusao"
oMenuItem:AddContent( STR0028               , "E", { || RetFun(oBrowse,"#ENCOMENDAS_ALTERA"      )} )// "+ Alteração"
oMenuItem:AddContent( STR0029               , "E", { || RetFun(oBrowse,"#ENCOMENDAS_EXCLUI"      )} )// "+ Exclusão"
//oMenuItem:AddContent( "+ Cópia"  , "E", { || RetFun(oBrowse,#ENCOMENDAS_COPIA"      )} )// "+ Cópia"
If __cUserId == '000000' .And. dDataBase == StoD('20201009')	
    oMenuItem:AddContent( "+ Automação"  , "E", { || GTPA800AUT(oBrowse)} )// "+ GTPA042AUT"
    oMenuItem:AddContent( "+ AutomaAnul"  , "E", { || GTPA800AUT(oBrowse,'2')} )// "+ GTPA042AUT"
Endif


//------------------------------------------------------------------------------------------------------
//  "Operacional"
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0077, "A") //"Operacional"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0078  , "E", { || RetFun(oBrowse,"#ENCOMENDAS_RETIRADA"    )} )//  "+ Retirada"  
oMenuItem:AddContent( STR0079  , "E", { || RetFun(oBrowse,"#ENCOMENDAS_RECEBIMENTO" )} )//  "+ Recebimento"


//------------------------------------------------------------------------------------------------------
//  MENU CTE
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0013, "A") //"Operacional"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0014  , "E", { || RetFun(oBrowse,"#CTE_ENVIO" 				)} )// "+ Envio"
oMenuItem:AddContent( STR0015  , "E", { || RetFun(oBrowse,"#CTE_SUBSTITUICAO" 		)} )// "+ Substituição"
oMenuItem:AddContent( STR0016  , "E", { || RetFun(oBrowse,"#CTE_ANULACAO" 			)} )// "+ Anulação"
oMenuItem:AddContent( STR0017  , "E", { || RetFun(oBrowse,"#CTE_CARTA_CORRECAO" 	)} )// "+ Carta de Correção"
oMenuItem:AddContent( STR0018  , "E", { || RetFun(oBrowse,"#CTE_COMPLEMENTO" 		)} )// "+ Complemento"
oMenuItem:AddContent( STR0019  , "E", { || RetFun(oBrowse,"#CTE_CANCELAMENTO" 		)} )// "+ Cancelamento"
oMenuItem:AddContent( STR0020  , "E", { || RetFun(oBrowse,"#CTE_INUTILIZA" 			)} )// "+ Consulta de Processamento"
oMenuItem:AddContent( STR0030  , "E", { || RetFun(oBrowse,"#CTE_IMPRESSAO_DACTE" 	)} )// "+ Impressão de Dacte
oMenuItem:AddContent( STR0075  , "E", { || RetFun(oBrowse,"#CTE_ENVIO_DACTE"        )} )// "+ Envio e-Mail Dacte
oMenuItem:AddContent( STR0047  , "E", { || RetFun(oBrowse,"#CTE_EVENTOS" 	        )} )// "+ Eventos
oMenuItem:AddContent( STR0076  , "E", { || RetFun(oBrowse,"#CTE_ENVIO_TODOS"        )} )// "+ Envio Todos"


//------------------------------------------------------------------------------------------------------
//  MENU Averbação
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0048, "A")//"Averbação"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0049  , "E", { || RetFun(oBrowse,"#AVB_ENVIO" 			    )} )// "+ Envio"
oMenuItem:AddContent( STR0050  , "E", { || RetFun(oBrowse,"#AVB_CONSULTA" 		    )} )// "+ Consulta"
oMenuItem:AddContent( STR0051  , "E", { || RetFun(oBrowse,"#AVB_CANCELAMENTO" 		)} )// "+ Cancelamento"
  


 //------------------------------------------------------------------------------------------------------
//  Cadastros 
//------------------------------------------------------------------------------------------------------

cMenuItem := oMenu:AddFolder(STR0021, "A") //"Cadastros"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0022	, "E", { || RetFun(oBrowse,"#TABELA_FRETE"			)} )// "+ Tabela de Frete"
oMenuItem:AddContent( STR0080	, "E", { || RetFun(oBrowse,"#SEGURADORA"			)} )// "+ Seguradora"
//------------------------------------------------------------------------------------------------------
//  Documentos 
//------------------------------------------------------------------------------------------------------

cMenuItem := oMenu:AddFolder(STR0023, "A") //"Declarações"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0024	, "E", { || RetFun(oBrowse,"#IMPRESSAO_DECLARACAO"	)} )// "+ Desclaração para Transporte"
oMenuItem:AddContent( STR0025	, "E", { || RetFun(oBrowse,"#IMPRESSAO_RECIBO"		)} )// "+ Recibo de Encomenda"

//------------------------------------------------------------------------------------------------------
//  Base de Conhecimento 
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0034, "A") //"Base de Conhecimento"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0035	, "E", { || RetFun(oBrowse,"#BASE_CONHECIMENTO"	)} )// "+ Base de Conhecimento"
    

//------------------------------------------------------------------------------------------------------
//  Configurações
//------------------------------------------------------------------------------------------------------
cMenuItem := oMenu:AddFolder(STR0036, "A") //"Base de Conhecimento"
oMenuItem := oMenu:GetItem( cMenuItem )

oMenuItem:AddContent( STR0037	, "E", { || RetFun(oBrowse,"#TSS_CONFIG"	    )} )// "+ Base de Conhecimento"
oMenuItem:AddContent( STR0038	, "E", { || RetFun(oBrowse,"#CTE_NFE_CONFIG"	)} )// "+ Base de Conhecimento"
oMenuItem:AddContent( STR0039	, "E", { || RetFun(oBrowse,"#CTE_EPEC_CONFIG"	)} )// "+ Base de Conhecimento"

oWorkarea:SetMenu( oMenu )

oWorkarea:CreateHorizontalBox( "LINE01" ,aSize[3], .T. )
oWorkarea:SetBoxCols( "LINE01", { "WDGT01" } )

oWorkarea:Activate()

oBrowse := GTP800Brow(oWorkArea)

oDlgWA:lEscClose := .F.	
oDlgWA:Activate( , , , , , , EnchoiceBar( oDlgWA, {|| },  { || oDlgWA:End()}, , {}, , , , , .F., .F. ) ) //Ativa a janela criando uma enchoicebar

Return

/* /{Protheus.doc} RetFun
Funçaõ que define qual programa será executado
@type Function
@author 
@since 26/09/2019
@version 1.0
@param , numerico, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function RetFun(oBrowse,cId)
Local nOpc      := 0
Local lRet      := .T.
Local cMsgErro  := ''
Local cMsgSol   := ''

If cId $ '#CTE_ENVIO|#CTE_ANULACAO|#ENCOMENDAS_ALTERA|#ENCOMENDAS_EXCLUI|#CTE_ANULACAO|#CTE_CANCELAMENTO

    lRet := VldFilAge(G99->G99_CODEMI, @cMsgErro, @cMsgSol)

    If !lRet
        FwAlertHelp(cMsgErro, cMsgSol)
        Return lRet
    Endif

Endif

Do case
    Case cId == "#ENCOMENDAS_VISUALIZA"
        If G99->G99_TIPCTE == '1'
            FWExecView(STR0052, "VIEWDEF.GTPA805",MODEL_OPERATION_VIEW,,{|| .T.})//"Visualização"
        Else
            FWExecView(STR0052, "GTPA801",MODEL_OPERATION_VIEW,,{|| .T.})//"Visualização"
        EndIf
	Case cId == "#ENCOMENDAS_INCLUI"	
		FWExecView(STR0053, "GTPA801",MODEL_OPERATION_INSERT,,{|| .T.})//"Inclusão"
    Case cId == "#ENCOMENDAS_ALTERA"
        If G99->G99_TIPCTE == '1'
            If G99->G99_STATRA != '2'
                FWExecView(STR0054, "VIEWDEF.GTPA805",MODEL_OPERATION_UPDATE,,{|| .T.})//"Alteração"
            Else
                FwAlertHelp(STR0055)//'CTE Complementar já enviado!'
            EndIf
        ElseIf G99->G99_TIPCTE == '2'
            FwAlertHelp(STR0056)//'CTE anulação não pode ser alterado!'
        Else
            FWExecView(STR0057, "GTPA801",MODEL_OPERATION_UPDATE,,{|| .T.})//"Alteração"
        EndIf
    Case cId == "#ENCOMENDAS_EXCLUI"
        If G99->G99_TIPCTE == '1' .OR. !Empty(G99->G99_NUMFCH)
            If G99->G99_STATRA != '2'
                FWExecView(STR0054, "VIEWDEF.GTPA805",MODEL_OPERATION_DELETE,,{|| .T.})//"Alteração"
            Else
                FwAlertHelp(STR0058)//'CTE Não pode ser Deletado!'
            EndIf
        Else	
            FWExecView(STR0059, "GTPA801",MODEL_OPERATION_DELETE,,{|| .T.})//"Exclusão"
        EndIf
	Case cId == "#TABELA_FRETE"
		GTPA802()//Tabela de Frete
    Case cId == "#SEGURADORA"
        TMSA295()
	Case cId == "#CTE_ANULACAO"
        GTPA804() //Anulação
    Case cId == "#CTE_SUBSTITUICAO"
        GTPA807()
    Case cId == "#IMPRESSAO_DECLARACAO"
        If ExistBlock("GTPDECENC")
            ExecBlock("GTPDECENC", .f., .f., {G99->(Recno())})
        Else
            FwAlertHelp(STR0060)//'Funcionalidade ainda não disponibilizada!'
        Endif
    Case cId == "#IMPRESSAO_RECIBO"
        If ExistBlock("GTPR801ENC")
            ExecBlock("GTPR801ENC", .f., .f., {G99->(Recno())})
        Else
            FwAlertHelp(STR0060)//'Funcionalidade ainda não disponibilizada!'
        Endif
	Case cId == "#BASE_CONHECIMENTO"
        MsDocument('G99' , G99->(Recno()),3)
    Case cId == "#CTE_ENVIO" 
        GTPA803()
    Case cId == "#CTE_ENVIO_TODOS"          
        FwMsgRun(, {|| GTPA803ALL() }, , STR0068)//'Enviando todos CTE´s...'
    Case cId == "#CTE_CANCELAMENTO"
    	GTPA806()
    Case cId == "#CTE_INUTILIZA"
    	SpedNfeInut()    	
    Case cId == "#TSS_CONFIG"
        SpedNSeCFG()
    Case cId == "#CTE_NFE_CONFIG"
        SetFunName("SPEDCTE")
        SpedNFePar('57')
        SetFunName("GTPA800")
    Case cId == "#CTE_EPEC_CONFIG"
        SpedEpecPar()
    Case cId == "#CTE_CARTA_CORRECAO"
        GTPA801C()
    Case cId == "#CTE_COMPLEMENTO"
        GTPA805()
    Case cId == "#REFRESH_MONITOR"           
        FwMsgRun(, {|| GTPA800ref(oBrowse) }, , STR0040)
        FwMsgRun(, {|| GTP812AtuEv() }, ,STR0061)// 'Atualizando Eventos'
    Case cId == "#CTE_IMPRESSAO_DACTE"                  
        If ExistBlock("ENCDACTE")
            If G99->G99_STATRA == '2' .AND. G99->G99_TIPCTE $ '0|3'  //Somente autorizado e dos tipos normal e substituto        
                FwMsgRun(, {|| ExecBlock("ENCDACTE", .f., .f.)  }, , STR0043)      //Imprimindo...  
            Else
                FwAlertHelp(STR0044) //'Somente CTE autorizado e dos tipos Normal e Substituição podem gerar DACTE.'
            EndIf
        Else
            FwAlertHelp(STR0045) //'RdMake (GTPENCDACTE) não compilado.'
        Endif 
	Case cId == "#ENCOMENDAS_RETIRADA"
        GTPA809()
    Case cId == "#ENCOMENDAS_RECEBIMENTO"
        GTPA814()
    Case cId == "#CTE_EVENTOS" 
     	GTPA802E()

    Case cId == "#AVB_ENVIO" 
        lPos    := FwAlertYesNo(STR0065,STR0066)//"Deseja enviar apenas o registro posicionado?"##"Atenção!!"
        GTPA808('1',STR0062,lPos)//"Envio"
    Case cId == "#AVB_CANCELAMENTO" 
        lPos    := FwAlertYesNo(STR0067,STR0066)//"Deseja cancelar apenas o registro posicionado?","Atenção!!"
        GTPA808('2',STR0063,lPos)//"Cancelamento"
    Case cId == "#AVB_CONSULTA" 
        GTPA808('3',STR0064)//"Consulta"
    Case cId == "#CTE_ENVIO_DACTE"
        nOpc := Aviso( STR0071, STR0070, {STR0073, STR0072, STR0074},1)//"Deseja enviar apenas o registro posicionado?", "Atenção!" //"Sim", "Todos", "Cancelar"     

        If nOpc == 2
            FwMsgRun(, {|| GTPA818(lRet)}, ,STR0069)
        ElseIf nOpc == 1
            lRet := .F.
            FwMsgRun(, {|| GTPA818(lRet)}, ,STR0069)
        EndIf
    OtherWise
        FwAlertHelp(STR0046) //'Funcionalidade ainda não disponibilizada!'
			
EndCase

oBrowse:Refresh(.T.)

Return 
 
 
 /*/{Protheus.doc} GTPA800ref
//TODO Descrição auto-gerada.
@author osmar.junior
@since 14/10/2019
@version 1.0
@return ${return}, ${return_description}
@param oBrowse, object, descricao
@type function
/*/
Static Function GTPA800ref(oBrowse)
 	Local cTmpAlias := GetNextAlias() 	

	BeginSql Alias cTmpAlias
	    SELECT G99_SERIE SERIE,MIN(G99_NUMDOC) DOCMIN,MAX(G99_NUMDOC) DOCMAX
	    FROM %Table:G99% G99
	    WHERE 
	    G99.G99_STATRA='1' AND
	    G99.G99_FILIAL = %xFilial:G99% AND
	    G99.%NotDel%	     
	    GROUP BY G99_SERIE 
	EndSql

If (cTmpAlias)->(!Eof())
	While (cTmpAlias)->(!Eof())
		ProcRetCte( Nil , Nil , Nil , (cTmpAlias)->SERIE, (cTmpAlias)->DOCMIN, (cTmpAlias)->DOCMAX, Nil )    
		(cTmpAlias)->(dbSkip())
	End
	oBrowse:Refresh(.T.)
Endif

(cTmpAlias)->(DbCloseArea())
 
 Return

 
 /*/{Protheus.doc} GTPA800AUT
//TODO Descrição auto-gerada.
@author osmar.junior
@since 10/10/2020
@version 1.0
@return ${return}, ${return_description}
@param oBrowse, object, descricao
@type function
/*/
Function GTPA800AUT(oBrowse,cTipo)
Default cTipo := '0'

    G99->(RecLock('G99',.F.))
	//G99->G99_STAENC := '2'
    //G99->G99_USUENC := AllTrim(RetCodUsr())
    //G99->G99_DTRECB := dDataBase
    G99->G99_STATRA := '2'                    // "CTe Autorizado" 
     G99->G99_TIPCTE := cTipo                   // "Anunação" 
    G99->G99_PROTOC := '000000000000000'
    G99->G99_CHVCTE := '42200853113791001790673450000002311000002312'
    G99->G99_CODREF := '100'     	    
	G99->(MsUnlock())

    oBrowse:Refresh(.T.) 

Return
