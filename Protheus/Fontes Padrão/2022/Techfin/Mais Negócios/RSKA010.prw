#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RSKA010.CH"
#INCLUDE "RSKDEFS.CH"

Static oBrowse      := Nil
Static cMemTktId    := ""
Static oMdlTktAct   := Nil
Static __lRskUpdLib := ExistBlock("RSK10LIB")

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKA010
Tickets de Crédito

@author Squad NT / TechFin
@since 11/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RSKA010( nOpcAuto, uAR0Auto, lAutomato )
    Local aAuto         := {}
    Local oModel        := Nil

    Private aRotina := MenuDef()

    Default uAR0Auto    := Nil
    Default nOpcAuto    := 0
    Default lAutomato   := .F.

    If uAR0Auto == Nil
        oBrowse := FWMBrowse():New() 
        oBrowse:SetAlias( "AR0" ) 
        oBrowse:SetDescription( STR0001 ) //"Tickets de Crédito"
        oBrowse:SetMenuDef( "RSKA010" )
        oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_AWAIT + "'",       "BR_BRANCO"   ,  STR0026 )    // 0="Aguardando Envio"
        oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_ANALYSIS + "'",    "BR_AMARELO"  ,  STR0002 )    // 1="Em Análise"
        oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_APPROVED + "'",    "BR_VERDE"    ,  STR0003 )    // 2="Aprovado"
        oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_DISAPPROVED + "'", "BR_VERMELHO" ,  STR0004 )    // 3="Reprovado"
        oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_CANCELED + "'",    "BR_PRETO"    ,  STR0005 )    // 4="Cancelado"
        oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_EXPIRED + "'",     "BR_LARANJA"  ,  STR0006 )    // 5="Vencido"
        If AR0->( ColumnPos( "AR0_SALDO" ) ) > 0
            oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_PARTIALLY + "'", "BR_MARROM" ,  STR0027 )    // 6="Faturado Parcialmente"
            oBrowse:AddLegend( "AR0->AR0_STATUS=='" + AR0_STT_BILLED + "'",    "BR_AZUL"   ,  STR0028 )    // 7="Faturado"
        EndIf
        oBrowse:Activate()
    
        FreeObj( oBrowse )
    Else
        oModel  := FWLoadModel( "RSKA010" )
        aAuto   := { { "AR0MASTER", uAR0Auto } }
        FWMVCRotAuto( oModel, "AR0", nOpcAuto, aAuto, /*lSeek*/, .T. )
        FreeObj( oModel )
    EndIf

    FWFreeArray( aAuto ) 
    FWFreeArray( uAR0Auto ) 
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do Browse

@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0007 ACTION 'Rsk010RBrw'        OPERATION 4 ACCESS 0    //'Atualizar'
    ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.RSKA010'   OPERATION 2 ACCESS 0    //'Visualizar'
    ADD OPTION aRotina TITLE STR0009 ACTION 'RskRTicket'        OPERATION 4 ACCESS 0    //'Reanálise'
    ADD OPTION aRotina TITLE STR0032 ACTION 'RSKCLEARTKT'       OPERATION 4 ACCESS 0    //'Limpar Saldo'
    ADD OPTION aRotina TITLE STR0010 ACTION 'Rsk010Lege'        OPERATION 6 ACCESS 0    //'Legenda'
Return aRotina 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function ModelDef()
    Local oStruAR0  := FWFormStruct( 1, "AR0" )
    Local oStruAR1  := FWFormStruct( 1, "AR1" )
    Local oStruAR6  := Nil
    Local oModel    := Nil

    oModel := MPFormModel():New( "RSKA010" )
    oModel:AddFields( "AR0MASTER", , oStruAR0 )
    oModel:SetPrimaryKey( { "AR0_FILIAL", "AR0_TICKET" } )
    oModel:SetDescription( STR0001 )    //"Tickets de Crédito"

    If FWAliasInDic("AR6")
        oStruAR6 := FWFormModelStruct():New()
        oStruAR6:AddTable("AR6",{},STR0029) //"NFS Mais Negócios"
        FormAR6Struct(oStruAR6)
        oModel:AddGrid( 'AR1DETAIL', 'AR0MASTER', oStruAR6,,,,, {| oStruAR6 | LoadAR6() } )
        oModel:GetModel("AR1DETAIL"):SetOnlyQuery(.T.)
        oModel:GetModel("AR1DETAIL"):SetOptional(.T.)
        oModel:GetModel("AR1DETAIL"):SetNoInsertLine(.T.)        
    Else
        oModel:AddGrid( 'AR1DETAIL', 'AR0MASTER', oStruAR1 )
        oModel:SetRelation( 'AR1DETAIL', { { 'AR1_FILIAL', 'xFilial( "AR1" )' }, { 'AR1_TKTRSK', 'AR0_TKTRSK' } }, AR1->( IndexKey( 1 ) ) )
        oModel:GetModel( 'AR1DETAIL' ):SetUniqueLine( { 'AR1_COD' } )
        oModel:GetModel( 'AR1DETAIL' ):SetDescription( STR0029 )    //"NFS Mais Negócios"
        oModel:GetModel( 'AR1DETAIL' ):SetOptional( .T. )
    EndIf

Return oModel 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View do formulario

@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Static Function ViewDef()
    Local oModel    := FWLoadModel( "RSKA010" )
    Local oStruAR0  := FWFormStruct( 2, "AR0" )
    Local oStruAR1  := FWFormStruct( 2, 'AR1' )
    Local oStruAR6  := Nil
    Local oView     := Nil
    //Campo descontinuado na integracao direta.
    oStruAR0:RemoveField( "AR0_DIASPP" )
    oStruAR0:RemoveField( "AR0_NPARCE" )
    oStruAR0:RemoveField( "AR0_DPARCE" ) 
    oStruAR0:RemoveField( "AR0_PRZMAX" )
    oStruAR0:RemoveField( "AR0_RSKLCR" )
    oStruAR0:RemoveField( "AR0_FILCLI" )
    oStruAR0:RemoveField( "AR0_TKTRSK" )
    oStruAR0:RemoveField( "AR0_RSKIDL" ) 
    oStruAR0:RemoveField( "AR0_DTSOLI" )  
    oStruAR0:RemoveField( "AR0_DTAVAL" )
    oStruAR0:RemoveField( "AR0_RCOUNT" ) 
    oStruAR0:RemoveField( "AR0_STARSK" )
    oStruAR0:RemoveField( "AR0_FILORI" )
    oStruAR0:RemoveField( "AR0_FILPED" )
    If AR0->( ColumnPos( "AR0_NUMNFS" ) ) > 0
        oStruAR0:RemoveField( "AR0_FILNFS" )
        oStruAR0:RemoveField( "AR0_NUMNFS" )
        oStruAR0:RemoveField( "AR0_SERNFS" )
    EndIf

    If FWAliasInDic("AR6")
        oStruAR6 := FWFormViewStruct():New()
        AddFieldAR6(oStruAR6)
        oView := FWFormView():New()
        oView:SetModel( oModel )
        oView:AddField( "VIEW_AR0", oStruAR0, "AR0MASTER" )
        oView:AddGrid(  'VIEW_AR1', oStruAR6, 'AR1DETAIL' )
    Else
        oStruAR1:RemoveField( "AR1_FILNF" )
        oStruAR1:RemoveField( "AR1_FILCLI" )
        oStruAR1:RemoveField( "AR1_CLIENT" )
        oStruAR1:RemoveField( "AR1_LOJA" )
        oStruAR1:RemoveField( "AR1_FILPAR" )
        oStruAR1:RemoveField( "AR1_FILORI" )
        oStruAR1:RemoveField( "AR1_TKTRSK" )
        oStruAR1:RemoveField( "AR1_CMDINV" )
        oStruAR1:RemoveField( "AR1_DTSOLI" )
        oStruAR1:RemoveField( "AR1_DTAVAL" )
        oStruAR1:RemoveField( "AR1_RCOUNT" )
        oStruAR1:RemoveField( "AR1_STARSK" )
        oStruAR1:RemoveField( "AR1_PREFIX" )
        oStruAR1:RemoveField( "AR1_NOMCLI" )
        oStruAR1:RemoveField( "AR1_NOMPAR" )
        oStruAR1:RemoveField( "AR1_CGCCLI" )
        oStruAR1:RemoveField( "AR1_CGCPAR" )
        oStruAR1:RemoveField( "AR1_CLIPAR" )
        oStruAR1:RemoveField( "AR1_LJPARC" ) 
        oStruAR1:RemoveField( "AR1_VLRREC" )
        oStruAR1:RemoveField( "AR1_DTPGTO" )
        oStruAR1:RemoveField( "AR1_TXNEG" )
        oStruAR1:RemoveField( "AR1_CONDPG" )
        oStruAR1:RemoveField( "AR1_OBSPAR" )
        oStruAR1:RemoveField( "AR1_DTSVIR" )
        oStruAR1:RemoveField( "AR1_DTAVIR" )

        oView := FWFormView():New()
        oView:SetModel( oModel )
        oView:AddField( "VIEW_AR0", oStruAR0, "AR0MASTER" )
        oView:AddGrid(  'VIEW_AR1', oStruAR1, 'AR1DETAIL' )
    EndIf

    oView:CreateHorizontalBox( 'SUPERIOR', 60 )
    oView:CreateHorizontalBox( 'INFERIOR', 40 )
    
    oView:SetOwnerView( "VIEW_AR0", "SUPERIOR" )
    oView:SetOwnerView( 'VIEW_AR1', 'INFERIOR' )

    oView:SetViewProperty( 'VIEW_AR1', "ENABLENEWGRID" )
    oView:SetViewProperty( 'VIEW_AR1', "GRIDSEEK", { .T. } )
    oView:SetViewProperty( 'VIEW_AR1', "GRIDFILTER", { .T. } )

    oView:EnableTitleView('VIEW_AR1', STR0029)   //'NFS Mais Negócios'

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk010Lege
Legenda

@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Function Rsk010Lege()
    Local aLegenda := {}

    AAdd( aLegenda, { "BR_BRANCO"     , STR0026 } )    //"Aguardando Envio"
    AAdd( aLegenda, { "BR_AMARELO"    , STR0002 } )    //"Em Análise"
    AAdd( aLegenda, { "BR_VERDE"      , STR0003 } )    //"Aprovado"
    AAdd( aLegenda, { "BR_VERMELHO"   , STR0004 } )    //"Reprovado"       
    AAdd( aLegenda, { "BR_PRETO"      , STR0005 } )    //"Cancelado"
    AAdd( aLegenda, { "BR_LARANJA"    , STR0006 } )    //"Vencido"
    If AR0->( ColumnPos( "AR0_SALDO" ) ) > 0
        AAdd( aLegenda, { "BR_MARROM"    , STR0027 } )    //"Faturado Parcialmente"
        AAdd( aLegenda, { "BR_AZUL"    , STR0028 } )    //"Faturado"
    EndIf
    BrwLegenda( STR0001, STR0010, aLegenda )   //"Tickets de Crédito"###"Legenda"

    FWFreeArray( aLegenda ) 
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskRTicket
Função para reanalizar o ticket de crédito.

@param  cAlias, caracter, nome da tabela atrelado ao browse
@param  nReg, number, RECNO do registro
@param  nOpc, number, opção do aRotina que está semdo executada
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author  Squad NT TechFin
@since   12/06/2020
/*/
//-------------------------------------------------------------------
Function RskRTicket( cAlias, nReg, nOpc, lAutomato )
    Local aArea     := GetArea()
    Local aAreaSC9  := SC9->( GetArea() )
    Local aError    := {} 
    Local oModel    := FwLoadModel( "RSKA010" )
    Local oMdlAR0   := NIL
    Local cQuery    := ""
    Local cTempSC9  := ""
    Local cTicket   := ""
    Local lDisapproved := .F.

    Default lAutomato := .F.
    
    SC9->( DBSetOrder(11) )   //C9_FILIAL+C9_TICKETC+C9_PEDIDO+C9_ITEM+C9_SEQUEN

    If SC9->( DBSeek( xFilial( "SC9" ) + AR0->AR0_TICKET ) ) 
        If AR0->AR0_STATUS $ '"' + AR0_STT_DISAPPROVED + '|' + AR0_STT_EXPIRED + '"'    // 3=Reprovado ### 5=Vencido
            cTempSC9    := GetNextAlias()

            lDisapproved := ( AR0->AR0_STATUS == AR0_STT_DISAPPROVED )  // 3=Reprovado

            cQuery      :=  " SELECT SC9.R_E_C_N_O_ RECNO " + ; 
                            " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
                            " WHERE SC9.C9_FILIAL = '" + xFilial( "SC9" ) + "' " + ;  
                            " AND SC9.C9_TICKETC = '" + AR0->AR0_TICKET + "' "  + ;
                            " AND SC9.D_E_L_E_T_ = ' ' " + ; 
                            " AND SC9.C9_NFISCAL = ' ' " +;
                            " AND SC9.C9_SERIENF = ' ' " +;
                            " ORDER BY " + SqlOrder( SC9->( IndexKey() ) )
            
            cQuery := ChangeQuery( cQuery )
            DBUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), cTempSC9, .F., .T. )

            BEGIN TRANSACTION 
                oModel:SetOperation( MODEL_OPERATION_UPDATE )
                oModel:Activate()
                If oModel:IsActive()
                    oMdlAR0 := oModel:GetModel( "AR0MASTER" )
        
                    If lDisapproved 
                        oMdlAR0:SetValue( "AR0_RCOUNT", 0 )                                                    
                        oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_AWAIT ) // 0=Aguardando Envio
                        oMdlAR0:SetValue( "AR0_STARSK", STARSK_SUBMIT ) // 1=Enviar
                        oMdlAR0:SetValue( "AR0_MREPRO", " " )
                        oMdlAR0:SetValue( "AR0_OBSRSK", " " )
                        oMdlAR0:SetValue( "AR0_DTSOLI", FWTimeStamp( 1, Date(), Time() ) )
                        oMdlAR0:SetValue( "AR0_DTAVAL", " " )
                        oMdlAR0:SetValue( "AR0_TKTRSK", " " )
                        oMdlAR0:SetValue( "AR0_TCKTRA", " " ) 
                    else
                        //------------------------------------------------------------------------------
                        // Cancelando o Ticket  que está vencido
                        //------------------------------------------------------------------------------
                        oMdlAR0:SetValue( "AR0_STARSK", STARSK_SUBMIT )     // 1=Enviar 
                        oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_CANCELED )  // 4=Cancelado                            
                    EndIf
                    
                    If oModel:VldData() 
                        oModel:CommitData()

                        If lDisapproved     
                            UpdC9BlCred( cTempSC9, lDisapproved )
                        Else
                            oModel:DeActivate()

                            //------------------------------------------------------------------------------
                            // Incluindo um novo ticket para ser submetido a aprovação.
                            //------------------------------------------------------------------------------
                            oModel:SetOperation( MODEL_OPERATION_INSERT )
                            oModel:Activate()

                            If oModel:IsActive()
                                oMdlAR0 := oModel:GetModel( "AR0MASTER" )

                                oMdlAR0:SetValue( "AR0_FILCLI", AR0->AR0_FILCLI )                                                    
                                oMdlAR0:SetValue( "AR0_CODCLI", AR0->AR0_CODCLI )                                
                                oMdlAR0:SetValue( "AR0_LOJCLI", AR0->AR0_LOJCLI ) 
                                oMdlAR0:SetValue( "AR0_FILPED", AR0->AR0_FILPED )
                                oMdlAR0:SetValue( "AR0_NUMPED", AR0->AR0_NUMPED )
                                oMdlAR0:SetValue( "AR0_DTSOLI", FWTimeStamp( 1, Date(), Time() ) )
                                oMdlAR0:SetValue( "AR0_TPAY"  , AR0->AR0_TPAY)
                                oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_AWAIT )     // 0=Aguardando envio
                                oMdlAR0:SetValue( "AR0_STARSK", STARSK_SUBMIT )     // 1=Enviar
                                oMdlAR0:SetValue( "AR0_FILORI", AR0->AR0_FILORI)
                                oMdlAR0:SetValue( "AR0_VALOR" , AR0->AR0_VALOR)

                                cTicket := oMdlAR0:GetValue( "AR0_TICKET")
                            
                                If oModel:VldData() 
                                    oModel:CommitData()
                            
                                    UpdC9BlCred( cTempSC9, lDisapproved, cTicket )
                                Else
                                    aError := oModel:GetErrorMessage()
                                    Help( "", 1, "RSK010RTKT", , aError[6], 1 )
                                EndIf
                            Else
                                aError := oModel:GetErrorMessage()
                                Help( "", 1, "RSK010RTKT", , aError[6], 1 )
                            EndIf
                        EndIf
                    Else
                        aError := oModel:GetErrorMessage()
                        Help( "", 1, "RSK010RTKT", , aError[6], 1 )
                    EndIf
                Else
                    aError := oModel:GetErrorMessage()
                    Help( "", 1, "RSK010RTKT", , aError[6], 1 )
                EndIf
                oModel:DeActivate()
                oModel:Destroy()
            END TRANSACTION 

            ( cTempSC9 )->( DBCloseArea() )
        Else
            Help( "", 1, "RSK010RTKT", , STR0011, 1, 0,,,,,, { STR0012 } )  //"Não será possível solicitar uma reanálise para este ticket de crédito."###"Somente tickets de crédito com status reprovado ou vencido poderão ser reavaliados pela plataforma Risk."
        EndIf
    Else
         Help( "", 1, "RSK010RTKT", , STR0013, 1, 0,,,,,, { STR0014 } )  //"Não há liberações de pedido de venda associadoa a este ticket de crédito"###"Faça uma nova liberação de pedido para geração do ticket de crédito."
    EndIf      
 
    RestArea( aArea )  
    RestArea( aAreaSC9 )  
  
    FWFreeArray( aArea )
    FWFreeArray( aAreaSC9 )
    FWFreeArray( aError )
    FreeObj( oModel )    
    FreeObj( oMdlAR0 )
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} UpdC9BlCred
Função que atualiza o código de bloqueio nos registros da SC9 relacionados a
determinado ticket.

@param  cTempSC9, caracter, Alias temporário com os dados da consulta
@param  lDisapproved, boolena, Indica se está tratando um registro reprovado.
@param  cNewTicket, caracter, Código do novo ticket criado pela função de reuso.

@author Marcia Junko
@since  17/08/2021
/*/
//-----------------------------------------------------------------------------
Static Function UpdC9BlCred( cTempSC9, lDisapproved, cNewTicket )
    Local aArea := GetArea()
    Local aAreaSC9 := SC9->( GetArea() )

    Default cNewTicket := ""

    (cTempSC9)->( DBGotop() )
    While (cTempSC9)->( !Eof() )
        SC9->( DBGoTo( (cTempSC9)->RECNO ) )
        RecLock( "SC9", .F. )
            SC9->C9_BLCRED := "80"  // 80=Em análise RISK  
            If !lDisapproved   // 5=Vencido
                SC9->C9_TICKETC := cNewTicket
            EndIf
        MsUnLock()
        (cTempSC9)->( DBSkip() )
    End  

    RestArea( aArea )
    RestArea( aAreaSC9 )
    FWFreeArray( aArea )
    FWFreeArray( aAreaSC9 )
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskUpdTicket
Função chamada pelo risk job command para atualizar os tickets de creditos
atualizados na plataforma risk.

@param  aRecords , array, Tickets de creditos atualizados pela plataforma risk.
    [1] = filial
    [2] = numero do ticket
    [3] = status
    [4] = motivo da reprovação
    [5] = id do ticket
    [6] = observação
    [7] = ID da linha de crédito
    [8] = data da avaliação de crédito pela plataforma
    [9] = código de pré-autorização
    [10] = Faturado Parcial ou Total ( 1=Parcial e 2=Total )
    [11] = saldo do ticket
@obs A estrutura do array aRecords é baseada na função GetRSKItems - Tipo 2 ( Atualização de ticket )
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  12/06/2020
/*/
//-----------------------------------------------------------------------------
Function RskUpdTicket( aRecords, lAutomato )
	Local aArea 	:= GetArea()
	Local aAreaAR0 	:= AR0->( GetArea() )
    Local aErrorMd  := {}
    Local nCtrArr   := 0 
    Local oModel    := FWLoadModel( "RSKA010" )  
    Local oMdlAR0   := Nil
    Local lRet      := .T.
    Local lLibPed  	:= SuperGetMV("MV_RSKNTKT",,.F.)
    Local lBalance  := AR0->( ColumnPos( "AR0_SALDO" ) ) > 0
    Local lUpdBal   := .F.
    Local lCancel   := .F.

    Default lAutomato := .F.

    AR0->( DBSetOrder(1) )  // AR0_FILIAL+AR0_TICKET

    //------------------------------------------------------------------------------
    // Valida se o ambiente está atualizado com os dados do faturamento parcial
    //------------------------------------------------------------------------------
    If !Empty( aRecords )
        lUpdBal := lBalance .And. ( Len( aRecords[ 1 ] ) > 9 ) .And. ( !Empty( aRecords[ 1 ][ UPD_T_TYPEINV ] ) )   // [10]-tipo de faturamento
    EndIf
    
    For nCtrArr := 1 To Len( aRecords )         
        lRet    := .T.
        lCancel := .F. 

        If AR0->( DBSeek( xFilial( "AR0" ) + aRecords[ nCtrArr ][ UPD_T_TICKET ] ) )    // [2]-numero do ticket 
            LogMsg( "RskUpdTicket", 23, 6, 1, "", "", "RskUpdTicket -> " + STR0015 + aRecords[ nCtrArr ][ UPD_T_BRANCH ] + " " + aRecords[ nCtrArr ][ UPD_T_TICKET ]  )   //"Processando o ticket " ### [1]-filial ### [2]-numero do ticket        
               
            BEGIN TRANSACTION
                oModel:SetOperation( MODEL_OPERATION_UPDATE )
                oModel:Activate() 
                
                If oModel:IsActive()     
                    oMdlAR0 := oModel:GetModel( "AR0MASTER" )                                         
                    oMdlAR0:SetValue( "AR0_TKTRSK", aRecords[ nCtrArr ][ UPD_T_ID ] )         // [5]-id do ticket
                    oMdlAR0:SetValue( "AR0_RSKIDL", aRecords[ nCtrArr ][ UPD_T_CREDITID ] )   // [7]-id da linha de crédito
                    oMdlAR0:SetValue( "AR0_TCKTRA", aRecords[ nCtrArr ][ UPD_T_AUTHCODE] )    // [9]-Codigo de transacao do parceiro. 
                    
                    If AR0->AR0_STATUS != AR0_STT_CANCELED  // 4=Cancelada
                        oMdlAR0:SetValue( "AR0_STARSK", STARSK_RECEIVED )   // 3=Recebido 
                        
                        If aRecords[ nCtrArr ][ UPD_T_STATUS ] == AR0_STT_DISAPPROVED       // [3]-Status ### 3=Reprovado 
                            oMdlAR0:SetValue( "AR0_MREPRO", aRecords[nCtrArr][ UPD_T_REASON ] )     // [4]-motivo da reprovação
                        ElseIf  aRecords[ nCtrArr ][ UPD_T_STATUS ] == AR0_STT_EXPIRED      // [3]-Status ### 5=Vencido
                            oMdlAR0:SetValue( "AR0_MREPRO", AR0_REPRO_EXP )         // 1=Credito Vemcido
                            Rsk010Bloq( aRecords[ nCtrArr ][ UPD_T_AUTHCODE ] )     // [9]-código de pré-autorização
                        Else 
                            oMdlAR0:SetValue( "AR0_MREPRO", AR0_NOT_REPROVED )   // " "=Sem Reprovação 
                        EndIf

                        If oMdlAR0:GetValue( "AR0_STATUS" ) == AR0_STT_ANALYSIS .And. lLibPed   // 1=Em análise
                            //------------------------------------------------------------------------------
                            // Cancela o ticket aprovado caso não haja liberações para este ticket.
                            //------------------------------------------------------------------------------
                            If !RskUpdLibPed( oMdlAR0:GetValue( "AR0_TICKET" ), aRecords[ nCtrArr ][ UPD_T_STATUS ], aRecords[ nCtrArr ][ UPD_T_REASON ] )  // [3]-Status ### [4]-motivo da reprovação
                                oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_CANCELED )      // 4=Cancelado 
                                oMdlAR0:SetValue( "AR0_OBSRSK", STR0016 ) //"Não foi possível validar a liberação do pedido para esse ticket de crédito."
                                lCancel := .T.
                            EndIf                                 
                        EndIf

                        If !lCancel
                            If lUpdBal
                                oMdlAR0:SetValue( "AR0_SALDO", Val( aRecords[ nCtrArr ][ UPD_T_BALANCE ] ) ) // [11]-saldo do ticket
                                If oMdlAR0:GetValue( "AR0_STATUS" ) $ '"' + AR0_STT_APPROVED + '|' + AR0_STT_PARTIALLY + '|' + AR0_STT_BILLED + '"'    // 2=Aprovado, 6=Faturado Parcialmente, 7=Faturado
                                    If Val(aRecords[ nCtrArr ][ UPD_T_BALANCE ]) > 0            // [10]-tipo de faturamento ### 1=Fat.Parcial 
                                        oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_PARTIALLY )     // 6=Faturado Parcialmente
                                    Else
                                        oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_BILLED )        // 7=Faturado
                                    EndIf
                                Else 
                                    oMdlAR0:SetValue( "AR0_STATUS",  aRecords[ nCtrArr ][ UPD_T_STATUS ] )  // [3]-Status 
                                EndIF 
                            Else
                                oMdlAR0:SetValue( "AR0_STATUS",  aRecords[ nCtrArr ][ UPD_T_STATUS ] )  // [3]-Status 
                            EndIF    
                            oMdlAR0:SetValue( "AR0_OBSRSK", aRecords[ nCtrArr ][ UPD_T_NOTE ] )     // [6]-observação
                        EndIf       
                    
                        oMdlAR0:SetValue( "AR0_DTAVAL", FWTimeStamp( 1, Date(), Time() ) ) 
                    EndIf

                    If oModel:VldData()  
                        oModel:CommitData() 
                    Else 
                        lRet := .F. 
                    EndIf 
                Else
                    lRet := .F.   
                EndIf

                If !lRet
                    aErrorMd := oModel:GetErrorMessage()
                    If !Empty( aErrorMd )
                        LogMsg( "RSkStatTkt", 23, 6, 1, "", "", "RskUpdTicket -> " + aErrorMd[6] )
                    EndIf
                    DisarmTransaction()
                EndIf

                oModel:DeActivate()             
            END TRANSACTION
        EndIf
    Next nCtrArr 

    RestArea( aArea )
    RestArea( aAreaAR0 )

    FWFreeArray( aAreaAR0 )
    FWFreeArray( aErrorMd )
    FreeObj( oModel )
    FreeObj( oMdlAR0 )
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskUpdLibPed
Funcao que relaciona o documento de saída com o ticket de credito.

@param  cTicketId   , caracter , Id do ticket de crédito
@param  cTktStatus  , caracter , Status do ticket de crédito
@param  cTktDReason , caracter , Motivo de reprovação do ticket
@param  cNumPed     , caracter , Numero do Pedido de Vendas

@return lRet        , logico   , Retorna verdadeiro se o pedido relacionado ao
                                 ticket foi liberado.
@author Squad NT TechFin
@since  26/08/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskUpdLibPed( cTicketId, cTktStatus, cTktDReason, cNumPed )
    Local aArea     := GetArea()
    Local aAreaAR0  := AR0->( GetArea() )
    Local aAreaSC9  := SC9->( GetArea() )
    Local cFilSC9   := xFilial( "SC9" )
    Local cCodBloq  := ""
    Local cTempSC9  := GetNextAlias()
    Local cQrySC9   := ""
    Local lRet      := .T. 

    Default cTicketId   := ""
    Default cTktStatus  := ""
    Default cTktDReason := ""
    Default cNumPed     := ""

    If !Empty( cTicketId )
        AR0->( DBSetOrder(1) )  //AR0_FILIAL+AR0_TICKET
        
        If AR0->( DBSeek( xFilial( "AR0" ) + cTicketId ) )
            cQrySC9 += " SELECT R_E_C_N_O_ RECNO "
            cQrySC9 += " FROM " + RetSqlName( "SC9" ) + " SC9 "
            cQrySC9 += " WHERE SC9.C9_FILIAL = '" + cFilSC9  + "' " 
            
            If Empty( cNumPed )
                cQrySC9 += " AND SC9.C9_TICKETC = '" + cTicketId + "' "
            Else
                cQrySC9 += " AND SC9.C9_PEDIDO = '" + cNumPed + "' " 
            EndIf
            
            cQrySC9 += " AND SC9.C9_NFISCAL = ' ' "
            cQrySC9 += " AND SC9.C9_SERIENF = ' ' "  
            cQrySC9 += " AND SC9.C9_BLCRED  IN ('80','92') "    // 80=Em análise - Risk ### 92=Reanálise Risk.
            cQrySC9 += " AND SC9.D_E_L_E_T_ = ' ' "        
            
            cQrySC9	:= ChangeQuery( cQrySC9 )           
            DbUseArea( .T., "TOPCONN", TCGenQry( , , cQrySC9 ), cTempSC9, .F., .T. )
        
            If ( cTempSC9 )->( !Eof() )
                While ( cTempSC9 )->( !Eof() )
                    SC9->( DBGoTo( ( cTempSC9 )->RECNO ) )
                    
                    Do Case
                        Case cTktStatus == AR0_STT_APPROVED     // 2=Aprovado
                            //------------------------------------------------------------------------------
                            // Variavel que controla numero ticket está sendo processado durante liberação do pedido,
                            // caso haja uma geração de uma nova SC9 a mesma será associada ao ticket posicionado.
                            //------------------------------------------------------------------------------
                            If AllTrim( SC9->C9_BLCRED ) == "80"  // 80=Em análise Risk
                                cMemTktId := AR0->AR0_TICKET
                                a450Grava( 1, .T., .F., Nil, Nil, Nil, Nil, .T. )   
                                cMemTktId := " " 

                                If SC9->C9_TICKETC != AR0->AR0_TICKET
                                    RecLock( "SC9", .F. )
                                        SC9->C9_TICKETC := AR0->AR0_TICKET 
                                    MsUnLock() 
                                EndIf          
                            Else
                                //------------------------------------------------------------------------------
                                // Se for uma reanalise Risk não precisa submeter a uma nova aprovação de credito.
                                //------------------------------------------------------------------------------
                                RecLock( "SC9", .F. )
                                    SC9->C9_BLCRED  := " "
                                    SC9->C9_TICKETC := AR0->AR0_TICKET 
                                MsUnLock()
                            EndIf
                            
                            If __lRskUpdLib
                                SC9->( DbSetOrder(1) )
                                If SC9->( Deleted() ) .And. !SC9->( MsSeek( SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN + C9_PRODUTO)  ) )
                                    SC9->( DBGoTo( ( cTempSC9 )->RECNO ) )
                                EndIf
                                ExecBlock("RSK10LIB", .F., .F.)
                            EndIf
                            LogMsg( "RskUpdLibPed", 23, 6, 1, "", "", "RskUpdLibPed -> " + I18N( STR0017, { SC9->C9_TICKETC, SC9->C9_PEDIDO } ) ) //"Aprovado o ticket: #1 / liberado o pedido: #2"

                        Case cTktStatus == AR0_STT_DISAPPROVED  // 3=Reprovado
                            If cTktDReason == AR0_REPRO_EXP         // 1=Credito Vencido 
                                cCodBloq    := "04"   // 04 - Vencimento do Limite de Crédito
                            ElseIf cTktDReason == AR0_REPRO_LIM     // 2=Limite de Credito
                                cCodBloq    := "01"   // 01 - Limite de Crédito
                            Else
                                cCodBloq    := "90"   // 90 - Bloqueado por regra de negocio da plataforma
                            EndIf
                            RecLock( "SC9", .F. )
                                SC9->C9_BLCRED := cCodBloq 
                            MsUnLock() 
                            LogMsg( "RskUpdLibPed", 23, 6, 1, "", "", "RskUpdLibPed -> " + I18N( STR0018, { SC9->C9_TICKETC } ) ) //Reprovado o ticket: #1"
                    EndCase
                    ( cTempSC9 )->( DBSkip() ) 
                EndDo
            Else
                lRet := .F.  
                LogMsg( "RskUpdLibPed", 23, 6, 1, "", "", "RskUpdLibPed -> " + I18N( STR0019, { cTicketId } ) )   //"Liberação de pedidos não encontrada para este ticket: #1"
            EndIf    

            ( cTempSC9 )->( DBCloseArea() )
        Else
            lRet := .F.
            LogMsg( "RskUpdLibPed", 23, 6, 1, "", "", "RskUpdLibPed -> " + I18N( STR0020, { cTicketID } ) )   //"Ticket: #1 não localizado.")
        EndIf 
    EndIf    

    RestArea( aAreaSC9 )
    RestArea( aAreaAR0 )  
    RestArea( aArea )  
    
    FWFreeArray( aArea ) 
    FWFreeArray( aAreaAR0 )  
    FWFreeArray( aAreaSC9 )   
Return lRet 


//------------------------------------------------------------------------------
/*/{Protheus.doc} RskGetMTkt
Pega da memória o número do ticket para processamento.

@author Squad NT TechFin
@since  27/10/2020
/*/ 
//-----------------------------------------------------------------------------
Function RskGetMTkt() 
Return cMemTktId

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskSetMTkt
Seta na memória o número do ticket para processamento.

@param cTicketId, caracter, Id do ticket de crédito
@author Squad NT TechFin
@since  27/10/2020
/*/ 
//-----------------------------------------------------------------------------
Function RskSetMTkt( cTicketId )
    Local aArea     := {}
    Local aAreaAR0  := {}

    Default cTicketId := ""

    If !Empty(cTicketId)
        If cTicketId <> cMemTktId  
            aArea     := GetArea()
            aAreaAR0  := AR0->(GetArea())
            
            AR0->( DBSetOrder(1) )    //AR0_FILIAL+AR0_TICKET
            If AR0->(MsSeek(xFilial("AR0") + cTicketId )) .And. ;
                AR0->AR0_STATUS $ '"' + AR0_STT_APPROVED + '|' + AR0_STT_PARTIALLY + '|' + AR0_STT_BILLED + '"'    // 2=Aprovado ### 6=Faturado Parcialmente ### 7=Faturado
                    cMemTktId := AR0->AR0_TICKET
            EndIf
            
            RestArea(aAreaAR0) 
            RestArea(aArea)
            FWFreeArray(aAreaAR0)
            FWFreeArray(aArea)  
        EndIf 
    Else 
        cMemTktId := ""     
    EndIf  
Return cMemTktId  

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskCanTicket
Funcao que faz o cancelamento dos tickets de credito para as liberações
dos pedidos excluidos.

@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  12/06/2020
/*/ 
//-----------------------------------------------------------------------------
Function RskCanTicket( lAutomato )
    Local aArea         := GetArea()
    Local aAreaAR0      := AR0->( GetArea() )
    Local aErrorMd      := {} 
    Local aRecNoSC9     := {}
    Local aDTAval       := {}
    Local cTempAR0      := ""
    Local cTempSC9      := ""
    Local cQryAR0       := "" 
    Local cQrySC9       := ""
    Local cFilSC6       := ""
    Local cFilSF4       := ""
    Local cObsRsk       := ""
    Local cElapTAval    := ""
    Local nReusaTkt     := 0
    Local nTktMCanc     := 0         
    Local nTotTicket    := 0
    Local nVlrTotLib    := 0 
    Local lRet          := .T.     
    Local lCanTicket    := .T.
    Local lReusaTkt     := .F.
    Local lLockByFil	:= !Empty(xFilial("AR0"))    
    Local oModel        := Nil
    Local oMdlAR0       := Nil  
    Local oQrySC9       := Nil

    Default lAutomato := .F.

    If LockByName("RskCanTicket", .T., lLockByFil )  
        oModel      := FwLoadModel( "RSKA010" )
        cTempAR0    := GetNextAlias()
        cTempSC9    := GetNextAlias()
        nReusaTkt   := SuperGetMv( "MV_RSKREUS", , 0 ) //Reutilizacao de tickets de credito. ( 0=Nao reusa;1=Valor Exato;2=Margem ) 
        nTktMCanc   := SuperGetMv( "MV_RSKMTCA", , 30 ) //Minutos para o Job Risk cancelar um ticket de crédito sem liberação de pedidos.
        cFilSC6     := xFilial( "SC6" )
        cFilSF4     := xFilial( "SF4" )   
        
        cQrySC9 := " SELECT SUM(SC9.C9_PRCVEN * SC9.C9_QTDLIB) VLRTOTLIB" + ;
                " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
                " INNER JOIN " + RetSQLName( "SC6" ) + " SC6 " + ;
                " ON SC6.C6_FILIAL = '" + cFilSC6  + "' " + ;
                " AND SC6.C6_NUM = SC9.C9_PEDIDO " + ;
                " AND SC6.C6_ITEM = SC9.C9_ITEM " + ;
                " AND SC6.C6_PRODUTO = SC9.C9_PRODUTO " + ;
                " AND SC6.D_E_L_E_T_ = ' ' " + ;
                " INNER JOIN " + RetSQLName( "SF4" ) + " SF4 " + ;
                " ON SF4.F4_FILIAL  = '" + cFilSF4 + "' " + ;
                " AND SF4.F4_CODIGO = SC6.C6_TES " +;
                " AND SF4.F4_DUPLIC = 'S' " +;
                " AND SF4.D_E_L_E_T_ = ' ' " + ;
                " WHERE SC9.C9_FILIAL = ? " + ;
                    " AND SC9.C9_PEDIDO = ? " + ;
                    " AND SC9.C9_CLIENTE = ? " + ;
                    " AND SC9.C9_LOJA = ? " + ;
                    " AND SC9.C9_NFISCAL = ' ' "  + ;
                    " AND SC9.C9_SERIENF = ' ' " + ;
                    " AND SC9.C9_BLCRED  IN ('80','92') "  + ;      // 80=Em análise - Risk; 92=Reanálise Risk.   
                    " AND SC9.D_E_L_E_T_ = ' ' "   

        cQrySC9	:= ChangeQuery( cQrySC9 )
        oQrySC9 := FWPreparedStatement():New( cQrySC9 ) 


        cQryAR0 := " SELECT AR0.R_E_C_N_O_ RECNO " + ;
                " FROM " + RetSqlName( "AR0" ) + " AR0 " + ;
                " WHERE AR0.AR0_FILIAL = '" + xFilial( "AR0" ) + "' " + ;
                    " AND AR0.AR0_STATUS IN ( '" + AR0_STT_AWAIT + "', '" + AR0_STT_ANALYSIS + "', '" + AR0_STT_APPROVED + ;    // 0=Aguardando Envio ### 1=Em Análise ### 2=Aprovada 
                        "', '" + AR0_STT_PARTIALLY + "', '" + AR0_STT_BILLED + "' ) " + ;   // 6=Faturado Parcialmente ### 7=Faturado
                    " AND AR0.D_E_L_E_T_ = ' ' " + ;  
                    " AND NOT EXISTS ( " + ; 
                        " SELECT SC9.C9_TICKETC " + ;
                        " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
                        " WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' " + ;
                            " AND SC9.C9_TICKETC = AR0.AR0_TICKET " + ;  
                            " AND SC9.D_E_L_E_T_ = ' ' ) "       

        cQryAR0	:= ChangeQuery( cQryAR0 )  
        DbUseArea( .T., "TOPCONN", TCGenQry( , , cQryAR0 ), cTempAR0, .F., .T. )

        While ( cTempAR0 )->( !Eof() )            
            AR0->( DBGoTo( ( cTempAR0 )->RECNO ) )
            
            lCanTicket  := .T.
            lRet        := .T.
            nVlrTotLib  := 0    
            nTotTicket  := 0
            aRecNoSC9   := {}

            BEGIN TRANSACTION 
                //------------------------------------------------------------------------------
                // So reusa ticket aprovado.
                //------------------------------------------------------------------------------
                If nReusaTkt > 0 
                    oQrySC9:SetString( 1, xFilial("SC9") ) 
                    oQrySC9:SetString( 2, AR0->AR0_NUMPED )
                    oQrySC9:SetString( 3, AR0->AR0_CODCLI )  
                    oQrySC9:SetString( 4, AR0->AR0_LOJCLI )
                
                    cQrySC9     := oQrySC9:GetFixQuery()
                    DbUseArea( .T., "TOPCONN", TCGenQry( , , cQrySC9 ), cTempSC9, .F., .T. )
                    
                    If ( cTempSC9 )->VLRTOTLIB > 0 
                        //------------------------------------------------------------------------------
                        // Valor total da nova liberação
                        //------------------------------------------------------------------------------
                        nTotTicket := RskCalcLPed( AR0->AR0_FILPED, AR0->AR0_NUMPED, ( cTempSC9 )->VLRTOTLIB ) 
    
                        If nReusaTkt == 1 
                            lReusaTkt   := nTotTicket == AR0->AR0_VLRMAX 
                        Else  
                            lReusaTkt := ( nTotTicket >= AR0->AR0_VLRMIN  .And. nTotTicket <= AR0->AR0_VLRMAX )
                        EndIf   

                        //------------------------------------------------------------------------------
                        // Mantem o ticket e atualiza o codigo do ticket na liberacao nova.
                        //------------------------------------------------------------------------------
                        If lReusaTkt        
                            lCanTicket := .F. 
                            If !RskUpdLibPed( AR0->AR0_TICKET, AR0->AR0_STATUS, Nil, AR0->AR0_NUMPED )  
                                lCanTicket := .T.
                            EndIf
                        EndIf                
                    Else  
                        //------------------------------------------------------------------------------
                        // Verifica se o ticket está dentro da validade de xx min até 24hs se estiver nao cancela.
                        //------------------------------------------------------------------------------
                        If AR0->AR0_STATUS == AR0_STT_APPROVED  // 2=Aprovado                
                            aDTAval  := StrToKArr( RskFmtTStamp( AR0->AR0_DTAVAL ), " " )
                            If !Empty( aDTAval )              
                                If nTktMCanc > 1440
                                    nTktMCanc := 30
                                EndIf
                                cElapTAval := SubStr( ElapTime( aDTAval[2], Time() ), 1, 5 )
                                If ( cTod( aDTAval[1] ) == Date() .And. cElapTAval < IntToHora( nTktMCanc / 60, 2 ) )
                                    lRet := .F.  
                                EndIf       
                            EndIf
                        EndIf                    
                    EndIf

                    ( cTempSC9 )->( DBCloseArea() ) 
                EndIf

                If lRet   
                    oModel:SetOperation( MODEL_OPERATION_UPDATE )
                    oModel:Activate()
    
                    If oModel:IsActive()  
                        oMdlAR0 := oModel:GetModel( "AR0MASTER" )

                        If lCanTicket
                            oMdlAR0:SetValue( "AR0_STARSK", STARSK_SUBMIT )     // 1=Enviar
                            oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_CANCELED )  // 4=Cancelado
                        Else
                            oMdlAR0:SetValue( "AR0_VALOR" , nTotTicket )
                        EndIf

                        If nTotTicket > 0   
                            oMdlAR0:SetValue( "AR0_OBSRSK", " " ) // Observacao
                        Else 
                            cObsRsk := STR0048 + Chr(13) + Chr(10) //"Liberação do pedido de venda sem valor para pré-autorização de crédito." 
                            cObsRsk += STR0049 + Chr(13) + Chr(10) //"Verifique as seguintes situações: "
                            cObsRsk += STR0050 + Chr(13) + Chr(10) //"Se existe liberação para pedido de venda associado a este ticket de crédito."
                            cObsRsk += STR0051 + Chr(13) + Chr(10) //"Se há itens no pedido de venda com TES que gera duplicatas no financeiro." 
                            cObsRsk += STR0052 + Chr(13) + Chr(10) //"Caso o pedido de venda seja negociado em moeda 2, verifique se a cotação do dia foi informada."
                            oMdlAR0:SetValue( "AR0_OBSRSK", cObsRsk )
                        EndIf 

                        oMdlAR0:SetValue( "AR0_DTAVAL", FWTimeStamp( 1, Date(), Time() ) )            
        
                        If oModel:VldData()  
                            oModel:CommitData()  
                            LogMsg( "RskCanTicket", 23, 6, 1, "", "", "RskCanTicket -> " + STR0042 + AllTrim(AR0->AR0_TICKET)  )   //"Ticket cancelado: " 
                        Else
                            lRet := .F.   
                        EndIf
                    Else    
                        lRet := .F.
                    EndIf

                    If !lRet 
                        DisarmTransaction()
                        aErrorMd := oModel:GetErrorMessage()
                        LogMsg( "RskCanTicket", 23, 6, 1, "", "", "RskCanTicket -> " + aErrorMd[6] )
                    EndIf 
                    
                    oModel:DeActivate()
                EndIf
            END TRANSACTION

            ( cTempAR0 )->( DBSkip() )
        End

        If oModel != Nil 
            oModel:Destroy() 
        EndIf

        ( cTempAR0 )->( DBCloseArea() )

         UnLockByName( "RskCanTicket", .T., lLockByFil )
    Else
        LogMsg( "RskCanTicket", 23, 6, 1, "", "", "RskCanTicket -> " + STR0043 )    //"Existe um processamento de cancelamento em outra instancia..."
    EndIf

    RestArea( aArea )
    RestArea( aAreaAR0 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaAR0 )
    FWFreeArray( aErrorMd )
    FWFreeArray( aRecNoSC9 )
    FWFreeArray( aDTAval )
    FreeObj( oModel )
    FreeObj( oMdlAR0 )     
    FreeObj( oQrySC9 )
Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskNewTicket
Funcao que gera novos tickets de creditos para novas liberações dos pedidos.

@param  aRecords , array, Tickets de creditos atualizados pela plataforma risk.
    [1] = filial
    [2] = pedido
    [3] = cliente
    [4] = loja
    [5] = sequencia
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@obs A estrutura do array aRecords é baseada na função GetRSKItems - Tipo 1 ( Criação de tickets )

@author Squad NT TechFin
@since  12/06/2020
/*/
//-----------------------------------------------------------------------------
Function RskNewTicket( aRecords, lAutomato )  
    Local aArea         := GetArea()
    Local aAreaSC5      := SC5->( GetArea() )
    Local aAreaSC9      := SC9->( GetArea() )
    Local aAreaSE4      := SE4->( GetArea() )
    Local aErrorMd      := {}
    Local cFilSA1       := ""
    Local cFilSC5       := ""
    Local cFilSE4       := ""
    Local cFilSF4       := ""
    Local cFilSC6       := ""
    Local cTempSC9      := ""
    Local cTempAR0      := ""
    Local cTicket       := "" 
    Local cQrySC9       := ""
    Local cQryAR0       := ""
    Local cObsRsk       := ""
    Local oMdlAR0       := Nil
    Local oModel        := Nil
    Local oQrySC9       := Nil
    Local oQryAR0       := Nil
    Local nPercMin      := 0
    Local nPercMax      := 0
    Local nItem         := 0
    Local nVlrTicket    := 0 
    Local nVlrTotLib    := 0
    Local lSeekSE4      := .F.  
    Local lRet          := .F.
    Local lLockByFil	:= !Empty(xFilial("AR0"))  	

    Default lAutomato := .F.

    If LockByName("RskNewTicket", .T., lLockByFil )
        oModel      := FwLoadModel( "RSKA010" )
        cFilSA1     := xFilial( "SA1" )
        cFilSC5     := xFilial( "SC5" )
        cFilSE4     := xFilial( "SE4" )
        cFilSC6     := xFilial( "SC6" )
        cFilSF4     := xFilial( "SF4" ) 
        nPercMin    := SuperGetMv( "MV_RSKMGRE", , 0 )  //Margem minina para reuso do ticket de credito.
        nPercMax    := SuperGetMv( "MV_RSKMGMA", , 0 )  //Margem maximo para reuso do ticket de credito.  
      
        SE4->( DbSetOrder(1) )  //E4_FILIAL + E4_CODIGO
        SC5->( DbSetOrder(1) )  //C5_FILIAL + C5_NUM

        cQrySC9 :=  " SELECT SC9.R_E_C_N_O_ RECNO, SF4.F4_DUPLIC DUPLIC " + ;
                    " FROM " + RetSQLName( "SC9" ) + " SC9 " + ;
                    " INNER JOIN " + RetSQLName( "SC6" ) + " SC6 " + ;
                    " ON SC6.C6_FILIAL = '" + cFilSC6  + "' " + ;
                    " AND SC6.C6_NUM = SC9.C9_PEDIDO " + ;
                    " AND SC6.C6_ITEM = SC9.C9_ITEM " + ;
                    " AND SC6.C6_PRODUTO = SC9.C9_PRODUTO " + ;
                    " AND SC6.D_E_L_E_T_ = ' ' " + ;
                    " INNER JOIN " + RetSQLName( "SF4" ) + " SF4 " + ;
                    " ON SF4.F4_FILIAL = '" + cFilSF4 + "' " + ;
                    " AND SF4.F4_CODIGO = SC6.C6_TES " +;
                    " AND SF4.D_E_L_E_T_ = ' ' " +;
                    " WHERE SC9.C9_FILIAL = ? " + ;  
                        " AND SC9.C9_PEDIDO = ? " + ;
                        " AND SC9.C9_CLIENTE = ? " + ;
                        " AND SC9.C9_LOJA = ? " + ;
                        " AND SC9.C9_TICKETC = ' ' " + ;
                        " AND SC9.C9_BLCRED IN ('80','92') " + ;    // 80=Em análise Risk ### 92=Reanálise Risk
                        " AND SC9.C9_NFISCAL = ' ' " + ;
                        " AND SC9.C9_SERIENF = ' ' " + ;
                        " AND SC9.D_E_L_E_T_ = ' ' " + ;   
                    " ORDER BY C9_FILIAL, C9_PEDIDO, C9_CLIENTE, C9_LOJA, C9_ITEM"
            
        cQrySC9 := ChangeQuery( cQrySC9 )
        oQrySC9 := FWPreparedStatement():New( cQrySC9 )    

        cQryAR0 := " SELECT AR0.AR0_TICKET " + ;
                    " FROM " + RetSqlName( "AR0" ) + " AR0 " + ;
                    " WHERE AR0.AR0_FILIAL = '" + xFilial( "AR0" ) + "' " + ;
                        " AND AR0.AR0_STATUS = '" + AR0_STT_APPROVED  + "' " + ;    // 2=Aprovada
                        " AND AR0.AR0_FILPED = ? " + ;
                        " AND AR0.AR0_NUMPED = ? " + ;
                        " AND AR0.AR0_CODCLI = ? " + ; 
                        " AND AR0.AR0_LOJCLI = ? " + ; 
                        " AND AR0.D_E_L_E_T_ = ' ' " + ;
                        " AND NOT EXISTS ( " + ; 
                            " SELECT SC9.C9_TICKETC " + ;
                            " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
                            " WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' " + ;
                                " AND SC9.C9_TICKETC = AR0.AR0_TICKET " + ;
                                " AND SC9.D_E_L_E_T_ = ' ' ) "     
        
        cQryAR0	:= ChangeQuery( cQryAR0 )
        oQryAR0 := FWPreparedStatement():New( cQryAR0 )

        For nItem := 1 to len( aRecords )        
            oQryAR0:SetString( 1, aRecords[ nItem ][ TKT_BRANCH ] )     // [1]-filial do pedido 
            oQryAR0:SetString( 2, aRecords[ nItem ][ TKT_ORDER ] )      // [2]-número do pedido
            oQryAR0:SetString( 3, aRecords[ nItem ][ TKT_CUSTOMER ] )   // [3]-código do cliente
            oQryAR0:SetString( 4, aRecords[ nItem ][ TKT_UNIT] )        // [4]-loja do cliente

            cQryAR0     := oQryAR0:GetFixQuery()
            cTempAR0    := MPSysOpenQuery( cQryAR0 )
            lRet        := Empty( (cTempAR0)->AR0_TICKET )
            
            If lRet   
                //------------------------------------------------------------------------------
                // Não cria um novo ticket de credito se teve liberação parcial do pedido
                //------------------------------------------------------------------------------
                lRet := !RskClrLibPed( aRecords[ nItem ] )  
            EndIf

            If lRet
                oQrySC9:SetString( 1, aRecords[ nItem ][ TKT_BRANCH ] )     // [1]-filial do pedido
                oQrySC9:SetString( 2, aRecords[ nItem ][ TKT_ORDER ] )      // [2]-número do pedido
                oQrySC9:SetString( 3, aRecords[ nItem ][ TKT_CUSTOMER ] )   // [3]-código do cliente
                oQrySC9:SetString( 4, aRecords[ nItem ][ TKT_UNIT ] )       // [4]-loja do cliente
            
                cQrySC9     := oQrySC9:GetFixQuery()
                cTempSC9    := MPSysOpenQuery( cQrySC9 )
                nVlrTotLib  := 0
            
                If ( cTempSC9 )->( !Eof() )   
                
                    BEGIN TRANSACTION 
                        //------------------------------------------------------------------------------
                        // Posiciona no Pedido de Vendas / Condição de Pagamento
                        //------------------------------------------------------------------------------
                        SC5->( MSSeek( cFilSC5 + aRecords[ nItem ][ TKT_ORDER ] ) )     // [2]-número do pedido
                        lSeekSE4 := SE4->( MsSeek( cFilSE4 + SC5->C5_CONDPAG ) ) 
                            
                        oModel:SetOperation( MODEL_OPERATION_INSERT )
                        oModel:Activate() 
                            
                        If oModel:IsActive()
                            oMdlAR0 := oModel:GetModel( "AR0MASTER" )
                
                            oMdlAR0:SetValue( "AR0_FILCLI", cFilSA1 )
                            oMdlAR0:SetValue( "AR0_CODCLI", aRecords[ nItem ][ TKT_CUSTOMER ] )     // [3]-código do cliente
                            oMdlAR0:SetValue( "AR0_LOJCLI", aRecords[ nItem ][ TKT_UNIT ] )         // [4]-loja do cliente
                            oMdlAR0:SetValue( "AR0_FILPED", cFilSC5 )  
                            oMdlAR0:SetValue( "AR0_NUMPED", aRecords[ nItem ][ TKT_ORDER ] )        // [2]-número do pedido
                            oMdlAR0:SetValue( "AR0_DTSOLI", FWTimeStamp( 1, Date(), Time() ) )

                            If lSeekSE4
                                oMdlAR0:SetValue( "AR0_TPAY"  , SE4->E4_TPAY ) 
                            EndIf  

                            cTicket := oMdlAR0:GetValue( "AR0_TICKET" )  
                            
                            While ( cTempSC9 )->( !Eof() )
                                SC9->( DBGoTo( ( cTempSC9 )->RECNO ) )
                                
                                If ( cTempSC9 )->DUPLIC == "S"
                                    nVlrTotLib += SC9->C9_QTDLIB * SC9->C9_PRCVEN  
                                EndIf

                                RecLock( "SC9", .F. )
                                    SC9->C9_TICKETC := cTicket   
                                MsUnLock()
                                ( cTempSC9 )->( DBSkip() )   
                            End 

                            nVlrTicket := RskCalcLPed( cFilSC5, aRecords[ nItem ][ TKT_ORDER ], nVlrTotLib )    // [2]-número do pedido
                            
                            If nVlrTicket > 0 
                                oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_AWAIT ) // 0=Aguardando Envio
                                oMdlAR0:SetValue( "AR0_STARSK", STARSK_SUBMIT ) // 1=Enviar
                                oMdlAR0:SetValue( "AR0_OBSRSK", " " ) // Observacao 
                            ElseIf nVlrTicket == 0 .And. RskPedAdt(SC5->C5_CONDPAG)
                                oMdlAR0:SetValue( "AR0_STARSK", STARSK_CONFIRMED )  // 4=Confirmado
                                oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_DISAPPROVED ) // 3=Reprovado
                                oMdlAR0:SetValue( "AR0_MREPRO", AR0_REPRO_RUL ) // 3=Por regras
                                oMdlAR0:SetValue( "AR0_OBSRSK", STR0055 ) //"O Pedido de Venda deve ter mais de uma parcela quando a condição de pagamento possui Adiantamento. Por favor verificar."
                            Else
                                oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_CANCELED )   // 4=Cancelado
                                oMdlAR0:SetValue( "AR0_STARSK", STARSK_CANCELED )   // 5=Cancelado
                                
                                cObsRsk := STR0048 + Chr(13) + Chr(10) //"Liberação do pedido de venda sem valor para pré-autorização de crédito." 
                                cObsRsk += STR0049 + Chr(13) + Chr(10) //"Verifique as seguintes situações: "
                                cObsRsk += STR0050 + Chr(13) + Chr(10) //"Se existe liberação para pedido de venda associado a este ticket de crédito."
                                cObsRsk += STR0051 + Chr(13) + Chr(10) //"Se há itens no pedido de venda com TES que gera duplicatas no financeiro." 
                                cObsRsk += STR0052 + Chr(13) + Chr(10) //"Caso o pedido de venda seja negociado em moeda 2, verifique se a cotação do dia foi informada."
                                oMdlAR0:SetValue( "AR0_OBSRSK", cObsRsk )  
                            EndIf  

                            oMdlAR0:SetValue( "AR0_FILORI", cFilAnt )  
                            oMdlAR0:SetValue( "AR0_RCOUNT", 0 ) 
                            oMdlAR0:SetValue( "AR0_VALOR" , nVlrTicket )   
                            oMdlAR0:SetValue( "AR0_VLRMIN", nVlrTicket - ( nVlrTicket * nPercMin / 100 ) )  //Valor minimo de tolerancia
                            oMdlAR0:SetValue( "AR0_VLRMAX", nVlrTicket + ( nVlrTicket * nPercMax / 100 ) )    //Valor maximo de tolerancia    

                            lRet := oModel:VldData()        

                            If lRet
                                LogMsg( "RskNewTicket", 23, 6, 1, "", "", "RskNewTicket -> " + I18N( STR0021, { cTicket } ) )    //"Gerando o ticket #1"
                                oModel:CommitData()
                            EndIf
                        Else
                            lRet := .F. 
                        EndIf  
            
                        If !lRet
                            aErrorMd := oModel:GetErrorMessage()
                            LogMsg( "RskNewTicket", 23, 6, 1, "", "", "RskNewTicket -> " + aErrorMd[6] )
                            DisarmTransaction()
                        EndIf  

                        oModel:DeActivate()     
                    END TRANSACTION
                EndIf

                (cTempSC9)->( DBCloseArea() )
            Else
                LogMsg( "RskNewTicket", 23, 6, 1, "", "", "RskNewTicket -> " + I18N( STR0031, { aRecords[ nItem ][ TKT_ORDER ] } )  ) //"Existe um ticket em uso para o pedido de vendas " ### [2]-número do pedido 
            EndIf

            (cTempAR0)->( DBCloseArea() )
        Next

        If oModel != Nil    
            oModel:Destroy() 
        EndIf
        
        UnLockByName("RskNewTicket", .T., lLockByFil ) 
    Else
        LogMsg( "RskNewTicket", 23, 6, 1, "", "", "RskNewTicket -> " + STR0044 ) //"Existe um processamento de novo ticket em outra instancia..."
    EndIf 
    
    RestArea( aArea )
    RestArea( aAreaSC5 )
    RestArea( aAreaSC9 )
    RestArea( aAreaSE4 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaSC5 )
    FWFreeArray( aAreaSC9 )
    FWFreeArray( aAreaSE4 )
    FWFreeArray( aErrorMd ) 
    FreeObj( oMdlAR0 )
    FreeObj( oModel ) 
    FreeObj( oQrySC9 )  
    FreeObj( oQryAR0 )
Return Nil
 
//---------------------------------------------------------------------------------
/*/{Protheus.doc} RskClrLibPed
Função que verifica se existe ticket de crédito para liberação de pedido de vendas
bloqueado por crédito. 
Caso exista o ticket de credito atual será desvinculado da liberação para ser
cancelado posteriormente pela função RskCanTicket
Na proxima avaliação de criação de ticket de credito todos os itens liberados serão 
associados com um novo ticket de crédito.

@param aData, array, vetor com as informações do pedido para pesquisa, onde:  
    [1]-Filial do Pedido
    [2]-Número do Pedido 
    [3]-Código do Cliente
    [4]-Loja do Cliente

@author Squad NT TechFin
@since  30/03/2021
/*/
//------------------------------------------------------------------------------
Static Function RskClrLibPed( aData )
    Local aArea     := GetArea()
    Local aAreaSC9  := SC9->( GetArea() )
    Local lRet      := .F. 
    Local cQrySC9   := "" 
    Local cTempSC9  := GetNextAlias()

    cQrySC9 := " SELECT R_E_C_N_O_ RECNO " + ;
                        " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
                        " WHERE SC9.C9_FILIAL = '" + aData[ TKT_BRANCH ] +  "' " + ;        // [1]-filial do pedido
                            " AND SC9.C9_PEDIDO = '" + aData[ TKT_ORDER ] +  "' " + ;       // [2]-número do pedido
                            " AND SC9.C9_CLIENTE = '" + aData[ TKT_CUSTOMER ] +  "' " + ;   // [3]-código do cliente
                            " AND SC9.C9_LOJA = '" + aData[ TKT_UNIT ] +  "' " + ;          // [4]-loja do cliente
                            " AND SC9.C9_NFISCAL = ' ' "  + ;
                            " AND SC9.C9_SERIENF = ' ' " + ;
                            " AND SC9.C9_TICKETC <> ' ' " + ;
                            " AND SC9.D_E_L_E_T_ = ' ' "
                            
    cQrySC9	:= ChangeQuery( cQrySC9 )
    DbUseArea( .T., "TOPCONN", TCGenQry( , , cQrySC9 ), cTempSC9, .F., .T. )

    If (cTempSC9)->(!Eof()) 
        lRet := .T.
        While (cTempSC9)->(!Eof())  
            SC9->( DBGoTo( ( cTempSC9 )->RECNO ) )  
            RecLock("SC9", .F.) 
                SC9->C9_TICKETC := " "
                If Empty( SC9->C9_BLCRED )
                    SC9->C9_BLCRED  := "92"     // 92=Reanálise Risk.
                EndIf     
            MsUnLock()
            (cTempSC9)->(DBSkip())    
        End
    EndIf 

    (cTempSC9)->(DBCloseArea())
 
    RestArea( aArea ) 
    RestArea( aAreaSC9 ) 
    FWFreeArray( aArea )
    FWFreeArray( aAreaSC9 )
Return lRet


//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskCalcLPed
Funcao que contem regras para calcular o valor total do ticket com base 
nas regras de negocio do pedido de vendas.

@param  cFilPed     , caracter , Filial do Pedido de Vendas
@param  cNumPed     , caracter , Numero do Pedido
@param  nVlrTotLib   , decimal , Valor total da liberacao do pedido

@return nVlrTotLib , numerico, Valor total da liberacao do pedido calculado.
@author Squad NT TechFin
@since  02/10/2020
/*/
//-----------------------------------------------------------------------------
Static Function RskCalcLPed( cFilPed, cNumPed, nVlrTotLib )
    Local aArea     := GetArea()
    Local aAreaSC5  := SC5->( GetArea() )
    Local aAreaSE4  := SE4->(GetArea())
    Local aPayCond  := {}
    Local nPercAcr  := SuperGetMv( "MV_RSKPACR", , 10 )  //Percentual de acréscimo durante geração do ticket de crédito. 
    Local lMoedaFre := SuperGetMv("MV_FRETMOE") == "S" 
    Local lRskPedVlOri := IsInCallStack("RskPedVlOri") //Chamada pela função de consulta do valor original liberado
    Local cFilSE4      := xFilial( "SE4" )

    Default cFilPed     := "" 
    Default cNumPed     := ""
    Default nVlrTotLib  := 0

    SC5->( DBSetOrder(1) )  //C5_FILIAL+C5_NUM
    SE4->( DbSetOrder(1) ) //E4_FILIAL+E4_CODIGO
               
    If SC5->( MsSeek( cFilPed + cNumPed ) )
        nTotDesp := SC5->C5_FRETE + SC5->C5_SEGURO + SC5->C5_DESPESA + SC5->C5_FRETAUT - SC5->C5_DESCONT

        If SC5->C5_MOEDA > 1
            //------------------------------------------------------------------------------
            // Calcula a moeda 2 para o valor total da liberação.
            //------------------------------------------------------------------------------
            nVlrTotLib   := xMoeda(nVlrTotLib,SC5->C5_MOEDA,1,dDataBase,TamSX3("AR0_VALOR")[1]) 

            //------------------------------------------------------------------------------
            // Calcula a moeda 2 para o frete + seguro + despesas.
            //------------------------------------------------------------------------------
            nTotDesp    := xMoeda(nTotDesp,IIF(lMoedaFre, SC5->C5_MOEDA, 1),1,dDataBase,TamSX3("AR0_VALOR")[1])  
        EndIf  

        //------------------------------------------------------------------------------
        // Tramento por causa do xMoeda conversão vem zero se a taxa do dia não foi informada pelo usuario.
        //------------------------------------------------------------------------------
        If nVlrTotLib > 0 
            //------------------------------------------------------------------------------
            // Soma as despesas acessórias.
            //------------------------------------------------------------------------------
            nVlrTotLib += nTotDesp     

            //------------------------------------------------------------------------------
            // Verifica se a condição de pagamento é Mais Negócios com Adiantamento
            //------------------------------------------------------------------------------
            If !lRskPedVlOri
                If RskPedAdt(SC5->C5_CONDPAG)
                    If SE4->( DbSeek( cFilSE4 + SC5->C5_CONDPAG ) )
                        aPayCond := Condicao( nVlrTotLib, SE4->E4_CODIGO )
                        If Len(aPayCond) > 0
                            //------------------------------------------------------------------------------
                            // Condição de pagamento com adiantamento desconsidera a primeira parcela que é compensada
                            //------------------------------------------------------------------------------
                            nVlrTotLib := nVlrTotLib - aPayCond[1,2]
                        EndIf
                    EndIf
                EndIf
            EndIf

            //------------------------------------------------------------------------------
            // Percentual de acréscimo durante geração do ticket de crédito
            //------------------------------------------------------------------------------
            If nPercAcr > 0
                nVlrTotLib := nVlrTotLib + ( nVlrTotLib * nPercAcr / 100 ) 
            EndIf  
        EndIf 
    EndIf          

    RestArea( aArea )
    RestArea( aAreaSC5 )
    RestArea( aAreaSE4 )
    FWFreeArray( aArea )
    FWFreeArray( aAreaSC5 )
    FWFreeArray( aAreaSE4 )
    FWFreeArray( aPayCond )
Return nVlrTotLib 

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskNFSTicket
Funcao que relaciona o documento de saída com o ticket de credito.

@param  cFilDoc   , caracter , Filial da NFS
@param  cNFDoc    , caracter , Número da NFS
@param  cNFSerie  , caracter , Série da NFS

@return lRet      , logico   , Retorna verdadeiro se o relacionamento da NFS com 
ticket de credito foi gravado. 
@author Squad NT TechFin
@since  12/06/2020
/*/
//-----------------------------------------------------------------------------
Function RskNFSTicket( cFilDoc, cNFDoc, cNFSerie )
    Local aArea     := {}
    Local aAreaAR0  := {}
    Local aErrorMd  := {}
    Local oModel    := Nil
    Local oMdlAR0   := Nil 
    Local cTempSC9  := ""
    Local lRet      := .T.
        
    Default cFilDoc     := ""
    Default cNFDoc      := "" 
    Default cNFSerie    := ""

    If RskIsActive()
        aArea     := GetArea()
        aAreaAR0  := AR0->( GetArea() )
        oModel    := FwLoadModel( "RSKA010" )
        cTempSC9  := GetNextAlias()

        AR0->( DBSetOrder(1) )  //AR0_FILIAL+AR0_TICKET

        BeginSql Alias cTempSC9
            SELECT 
                DISTINCT C9_TICKETC                                                                                          
            FROM
                %Table:SC9% SC9
            WHERE 
                SC9.C9_FILIAL = %xFilial:SC9% AND SC9.%NotDel%
                AND SC9.C9_NFISCAL = %Exp:cNFDoc% AND SC9.C9_SERIENF = %Exp:cNFSerie%
                AND SC9.C9_TICKETC <> ' '
        EndSql 
    
        While ( cTempSC9 )->( !Eof() )
            If AR0->( DBSeek( xFilial( "AR0" ) + ( cTempSC9 )->C9_TICKETC ) )
                oModel:SetOperation( MODEL_OPERATION_UPDATE )  
                oModel:Activate()
                If oModel:IsActive()
                    oMdlAR0 := oModel:GetModel( "AR0MASTER" )
                    oMdlAR0:SetValue( "AR0_FILNFS", cFilDoc )
                    oMdlAR0:SetValue( "AR0_NUMNFS", cNFDoc )
                    oMdlAR0:SetValue( "AR0_SERNFS", cNFSerie )
                    
                    lRet := oModel:VldData()
                    If lRet 
                        oModel:CommitData()
                    Else
                        lRet := .F.
                        aErrorMd := oModel:GetErrorMessage()
                        LogMsg( "RskNFSTicket", 23, 6, 1, "", "", "RskNFSTicket -> " + aErrorMd[6] )
                    EndIf
                Else
                    aErrorMd := oModel:GetErrorMessage()
                    LogMsg( "RskNFSTicket", 23, 6, 1, "", "", "RskNFSTicket -> " + aErrorMd[6] )
                EndIf
                oModel:DeActivate()
            EndIf
            ( cTempSC9 )->( DBSkip() )
        End
        oModel:Destroy()

        ( cTempSC9 )->( DBCloseArea() )

        RestArea( aAreaAR0 ) 
        RestArea( aArea )
    EndIf

    FWFreeArray( aAreaAR0 )
    FWFreeArray( aArea )
    FWFreeArray( aErrorMd )
    FreeObj( oModel )
    FreeObj( oMdlAR0 )
Return lRet  

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPostTicket
Funcao que envia os tickets de credito diretamente para plataforma risk.

@param  cStatus, caracter, Envia tickets filtrando por 0=Aguardando Envio ou 4=Cancelado.
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  24/08/2020
/*/
//-----------------------------------------------------------------------------
Function RskPostTicket( cStatus, lAutomato )    
    Local aArea         := GetArea()
    Local aAreaSE4      := SE4->( GetArea() )
    Local aAreaSC5      := SC5->( GetArea() )
    Local aAreaAR0      := AR0->( GetArea() )
    Local aJItems       := {}
    Local aErpIds       := {}
    Local aPayCond      := {}
    Local aJPCondItems  := {}
    Local aErrorMd      := {} 
    Local cTempAR0      := ""
    Local cHost         := GetRSKPlatform( .F. )  
    Local cEndPoint     := "/api/credit_ticket"
    Local cFilSE4       := xFilial( "SE4" )
    Local cQuery        := ""
    Local cErpId        := "" 
    Local cBody         := ""
    Local cDescription  := ""
    Local cSQLFilter    := ""
    Local nCount        := 0
    Local nRecProc      := 0
    Local nLimit        := 10
    Local nPedVlOri     := 0
    Local nRetryCount   := 99
    Local nX            := 0
    Local nPosErpId     := 0
    Local nLenPCond     := 0
    Local nStatus       := 0
    Local oJResult      := Nil    
    Local oJItem        := Nil
    Local oRest         := Nil
    Local oModel        := Nil
    Local oMdlAR0       := Nil
    Local oJPCondItem   := Nil
    Local lLockByFil	:= !Empty(xFilial("AR0")) 

    Default cStatus     := "0"
    Default lAutomato   := .F.   

    If LockByName("RskPostTicket", .T., lLockByFil ) 
        If cStatus $ '"' + AR0_STT_AWAIT + '|' + AR0_STT_CANCELED + '"'    // 0=Aguardando envio ### 4=Cancelado
            If !Empty( cHost ) .Or. lAutomato
                cTempAR0 := GetNextAlias()

                If cStatus == AR0_STT_AWAIT       // 0=Aguardando envio
                    //---------------------------------------------
                    // Envia os tickets de credito para analise.
                    //---------------------------------------------
                    cSQLFilter := " AND AR0_STATUS = '" + AR0_STT_AWAIT + "' "       // 0=Aguardando envio
                Else
                    //------------------------------------------------------------------------------
                    // Envia os tickets de credito que foram cancelados.
                    // Os tickets cancelados deverao ser enviados primeiro para evitar rejeicao
                    // de credito devido o valor pre-autorizado ser proximo do limite disponivel.
                    //------------------------------------------------------------------------------
                    cSQLFilter := " AND AR0_STATUS = '" + AR0_STT_CANCELED + "' AND AR0_TCKTRA <> ' ' "   // 4=Cancelado
                EndIf    
                
                SE4->( DbSetOrder(1) )  //E4_FILIAL + E4_CODIGO
                SC5->( DbSetOrder(1) )  //C5_FILIAL + C5_NUM
                
                cQuery  := " SELECT AR0_FILIAL, AR0_TICKET, AR0_FILCLI, AR0_CODCLI, AR0_LOJCLI, AR0_FILPED, " + ; 
                                " AR0_NUMPED, AR0_VALOR,  AR0_DTSOLI, AR0_TPAY, AR0_MREPRO, AR0_STATUS, " + ;
                                " AR0_DTAVAL, AR0_TCKTRA, AR0_TKTRSK, AR0_RCOUNT, R_E_C_N_O_ RECNO " + ;
                            " FROM " + RetSqlName( "AR0" ) + " AR0 " + ;
                            " WHERE AR0_FILIAL = '" + xFilial( "AR0" ) + "' " + ;  
                                " AND AR0_STARSK = '" + STARSK_SUBMIT  + "' " + ;   // 1=Enviar
                                cSQLFilter +;  
                                " AND AR0.D_E_L_E_T_ = ' ' " + ; 
                            " ORDER BY " + SqlOrder( AR0->( IndexKey(1) ) )     //AR0_FILIAL + AR0_TICKET
                    
                cQuery  := ChangeQuery( cQuery ) 
                DbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), cTempAR0, .F., .T. )
            
                If ( cTempAR0 )->( !Eof() )  
                    TcSetField( cTempAR0, "AR0_TPAY" ,"L", 1, 0 )

                    //-----------------------------------------------------------------------------------
                    // Identifica a quantidade de registro no alias temporário para processamento.
                    //-----------------------------------------------------------------------------------
                    COUNT TO nRecProc

                    //-------------------------------------------------------------------
                    // Posiciona no primeiro registro.
                    //-------------------------------------------------------------------
                    ( cTempAR0 )->( DBGoTop() )    

                    //------------------------------------------------------------------
                    // Ajusta o pagesize, caso o numero de registros de envio for menor.
                    //------------------------------------------------------------------
                    If nLimit > nRecProc
                        nLimit := nRecProc
                    EndIf 

                    oModel  := FWLoadModel( "RSKA010" )

                    While ( cTempAR0 )->( !Eof() )     
                        cErpId          := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTempAR0 )->AR0_FILIAL ) + "|" + AllTrim( ( cTempAR0 )->AR0_TICKET )
                        aPayCond        := {}
                        aJPCondItems    := {}
                        nLenPCond       := 0
                        nCount          += 1
                        nPedVlOri       := 0

                        nStatus := Val( ( cTempAR0 )->AR0_STATUS )

                        //------------------------------------------------------------------------------
                        // Na criação ou reanalise do ticket o comando 0=Aguardando Envio será alterado para Em Análise.
                        // O comando cancelamento não poderá ser modificado para Aguardando Envio
                        // devido a utilização deste status na regra de negocio da plataforma risk.
                        //------------------------------------------------------------------------------
                        If nStatus == Val( AR0_STT_AWAIT )        // 0=Aguardando envio
                            nStatus := Val( AR0_STT_ANALYSIS )    // 1=Em Análise
                        EndIf
                        
                        oJItem                              := JsonObject():New()
                        oJItem["id"]                        := IIF( !Empty( ( cTempAR0 )->AR0_TKTRSK ), ( cTempAR0 )->AR0_TKTRSK, "" )
                        oJItem["erpId"]                     := cErpId
                        oJItem["customerId"]                := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTempAR0 )->AR0_FILCLI ) + "|" + AllTrim( ( cTempAR0 )->AR0_CODCLI ) + "|" + AllTrim( ( cTempAR0 )->AR0_LOJCLI )
                        oJItem["salesOrderId"]              := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTempAR0 )->AR0_FILPED ) + "|" + AllTrim( ( cTempAR0 )->AR0_NUMPED )        
                        oJItem["amount"]                    := ( cTempAR0 )->AR0_VALOR
                        oJItem["requestDate"]               := RskDTimeUTC( ( cTempAR0 )->AR0_DTSOLI )
                        oJItem["totvsPay"]                  := IIF( ( cTempAR0 )->AR0_TPAY, 'true', 'false' )
                        oJItem["disapprovalReason"]         := Val( ( cTempAR0 )->AR0_MREPRO )
                        oJItem["status"]                    := nStatus
                        oJItem["creditEvaluationDate"]      := RskDTimeUTC( ( cTempAR0 )->AR0_DTAVAL )
                        oJItem["partnerTransactionId"]      := ( cTempAR0 )->AR0_TCKTRA
                        oJItem["retryCount"]                := ( cTempAR0 )->AR0_RCOUNT

                        If SC5->( MSSeek( ( cTempAR0 )->AR0_FILPED + ( cTempAR0 )->AR0_NUMPED ) ) 
                            If SE4->( MsSeek( cFilSE4 + SC5->C5_CONDPAG ) )                                                                
                                //------------------------------------------------------------------------------
                                // Verifica se a condição de pagamento é Mais Negócios com Adiantamento
                                //------------------------------------------------------------------------------
                                If RskPedAdt(SC5->C5_CONDPAG)
                                    nPedVlOri := RskPedVlOri(( cTempAR0 )->AR0_FILPED, ( cTempAR0 )->AR0_NUMPED,( cTempAR0 )->AR0_CODCLI,( cTempAR0 )->AR0_LOJCLI)
                                    aPayCond  := Condicao( nPedVlOri, SE4->E4_CODIGO )

                                    //------------------------------------------------------------------------------
                                    // Condição de pagamento com adiantamento desconsidera a primeira parcela que é compensada
                                    //------------------------------------------------------------------------------
                                    If Len(aPayCond) > 1                                            
                                        aDel(aPayCond, 1)
                                        aSize(aPayCond, Len(aPayCond)-1)
                                    EndIf
                                Else
                                    aPayCond := Condicao( ( cTempAR0 )->AR0_VALOR, SE4->E4_CODIGO )                                        
                                EndIf

                                nLenPCond   := Len( aPayCond )  
                                If nLenPCond > 0 
                                    For nX := 1 To nLenPCond
                                        oJPCondItem := JsonObject():New()
                                        oJPCondItem["installment"]      := nX    
                                        oJPCondItem["dueDate"]          := RskDTimeUTC( dTos( aPayCond[nX][1] ) )
                                        oJPCondItem["installmentValue"] := aPayCond[nX][2] 
                                        aAdd( aJPCondItems, oJPCondItem )
                                    Next nX 
                                EndIf  
                            EndIf 
                        EndIf 

                        oJItem["installments"]      := nLenPCond
                        oJItem["paymentConditions"] := aJPCondItems
                        oJItem["deleted"]           := 'false'
                    
                        aAdd( aErpIds, { cErpId, ( cTempAR0 )->RECNO } )
                        aAdd( aJItems, oJItem )   

                        If nCount == nLimit
                            IF !lAutomato
                                cBody := RSKRestExec( RSKPOST, cEndPoint, @oRest, aJItems, RISK, SERVICE, .F., .F. )   // POST ### 1=Risk ### 2=URL de autenticação de serviços
                            ELSE
                                cBody := RskADVPRData( 'RSKA010' )
                            EndIf

                            If !Empty( cBody )
                                oJResult    := JSONObject():New()
                                oJResult:FromJSON( cBody ) 
                                
                                For nX := 1 To Len( oJResult )
                                    oJItem      := oJResult[nX]
                                    nPosErpId   := aScan( aErpIds, {|x| x[1] == oJItem["erpId"] } )

                                    If nPosErpId > 0
                                        AR0->( DBGoTo( aErpIds[nPosErpId][2] ) )
                                        
                                        BEGIN TRANSACTION
                                            oModel:SetOperation( MODEL_OPERATION_UPDATE )
                                            oModel:Activate()  
    
                                            If oModel:IsActive() 
                                                oMdlAR0 := oModel:GetModel( "AR0MASTER" )  
                                                
                                                oMdlAR0:SetValue( "AR0_RCOUNT", oJItem["retryCount"] )
                                                
                                                If oJItem["statusProcess"] == 1  
                                                    If oMdlAR0:GetValue( "AR0_STATUS" ) == AR0_STT_AWAIT    // 0= Aguardando envio    
                                                        oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_ANALYSIS )  // 1=Em Análise
                                                    EndIf
                                                    oMdlAR0:SetValue( "AR0_STARSK", STARSK_SENT )  // 2=Enviado
                                                    cDescription := " "
                                                    LogMsg( "RskPostTicket", 23, 6, 1, "", "", "RskPostTicket -> " + STR0053 + AllTrim( oMdlAR0:GetValue( "AR0_TICKET" ) ) )    //"Ticket enviado: " 
                                                Else
                                                    cDescription := DecodeUTF8( oJItem["description"] ) + Chr(10)
                                                    If oJItem["retryCount"] >= nRetryCount
                                                        oMdlAR0:SetValue( "AR0_STARSK", STARSK_CANCELED )       // 5=Cancelado
                                                        oMdlAR0:SetValue( "AR0_STATUS", AR0_STT_DISAPPROVED )   // 3=Reprovado
                                                        oMdlAR0:SetValue( "AR0_MREPRO", AR0_REPRO_RUL )         // 3=Por Regras
                                                        
                                                        cDescription += STR0023 //"Gere um novo ticket de crédito ou solicite uma reanálise deste ticket." 
                                                        
                                                        RskUpdLibPed( oMdlAR0:GetValue( "AR0_TICKET" ), AR0_STT_DISAPPROVED, AR0_REPRO_EXP )    // 3=Reprovado ### 1=Credito Vencido 
                                                    Else    
                                                        cDescription += STR0022 + Chr(10) + STR0024 //"Ticket de crédito não enviado para plataforma Risk."###"Será realizada uma nova tentativa dentro de instantes..."
                                                    EndIf
                                                    LogMsg( "RskPostTicket", 23, 6, 1, "", "", "RskPostTicket -> " + STR0045 + AllTrim( oMdlAR0:GetValue( "AR0_TICKET" ) ) )  //"Ticket com falha: "
                                                EndIf 

                                                oMdlAR0:SetValue( "AR0_OBSRSK", cDescription )       

                                                If oModel:VldData()
                                                    oModel:CommitData()   
                                                Else
                                                    aErrorMd := oModel:GetErrorMessage()
                                                    LogMsg( "RskPostTicket", 23, 6, 1, "", "", "RskPostTicket -> " + aErrorMd[6] )       
                                                EndIf
                                            Else
                                                aErrorMd := oModel:GetErrorMessage()
                                                LogMsg( "RskPostTicket", 23, 6, 1, "", "", "RskPostTicket -> " + aErrorMd[6] )
                                            EndIf
                                            oModel:DeActivate()
                                        END TRANSACTION    
                                    EndIf
                                Next nX
                            Else
                                iF !lAutomato 
                                    LogMsg( "RskPostTicket", 23, 6, 1, "", "", "RskPostTicket -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )   
                                EndIf
                            EndIf 

                            aJItems     := {}
                            aErpIds     := {}  
                            nCount      := 0 
                            nRecProc    -= nLimit

                            //------------------------------------------------------------------
                            // Ajusta o pagesize para enviar os registros restantes.
                            //------------------------------------------------------------------
                            If nLimit > nRecProc
                                nLimit := nRecProc
                            EndIf 
                        EndIf
                        ( cTempAR0 )->( DBSkip() )
                    End

                    If oModel != Nil
                        oModel:Destroy()
                    EndIf 
                EndIf 

                ( cTempAR0 )->( DBCloseArea() )

                //------------------------------------------------------------------
                // NÃO RETIRAR O SLEEP - Aguarda 1 segundo para confirmar envio na plataforma.                              
                //------------------------------------------------------------------                            
                Sleep(1000)     
            Else
                LogMsg( "RskPostTicket", 23, 6, 1, "", "", "RskPostTicket -> " + STR0025 )  //"Host da plataforma RISK não informado."
            EndIf
        EndIf
        UnLockByName("RskPostTicket", .T., lLockByFil )
    Else
        LogMsg( "RskPostTicket", 23, 6, 1, "", "", "RskPostTicket -> " + STR0046  ) //"Existe um processamento de envio de ticket em outra instancia..."
    EndIf

    RestArea( aArea ) 
    RestArea( aAreaSE4 ) 
    RestArea( aAreaSC5 ) 
    RestArea( aAreaAR0 ) 

    FWFreeArray( aArea ) 
    FWFreeArray( aAreaSE4 ) 
    FWFreeArray( aAreaSC5 ) 
    FWFreeArray( aAreaAR0 ) 
    FWFreeArray( aJItems ) 
    FWFreeArray( aErpIds )
    FWFreeArray( aPayCond )
    FWFreeArray( aJPCondItems )
    FWFreeArray( aErrorMd )
    FreeObj( oJResult )     
    FreeObj( oJItem ) 
    FreeObj( oRest )       
    FreeObj( oModel )          
    FreeObj( oMdlAR0 ) 
    FreeObj( oJPCondItem )      
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk010RBrw
Botão de atualização do browse para o usuário.

@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Function Rsk010RBrw()
    If oBrowse := Nil
        oBrowse:Refresh()
    EndIf 
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk010Bloq
Função que  bloqueará o Pedido  caso vença a liberação.

@param  cCodPreAut, caracter , código da pré-autorização

@author Squad NT TechFin
@since  18/01/2021
/*/
//-----------------------------------------------------------------------------
Function Rsk010Bloq(cCodPreAut)
    Local aArea     := GetArea()
    Local aAreaSC9  := SC9->( GetArea() )
    Local cTempSC9  := GetNextAlias()
    Local lRet      := .f. 

    cQrySC9 := " SELECT SC9.R_E_C_N_O_ RECNO " + ;
            " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
            " INNER JOIN " + RetSqlName( "AR0" ) + " AR0" + ;
            " ON AR0.AR0_FILPED = SC9.C9_FILIAL" +;
            " AND AR0.AR0_NUMPED = SC9.C9_PEDIDO " +;
            " AND AR0.AR0_TICKET = SC9.C9_TICKETC " +;
            " AND SC9.C9_NFISCAL = ' ' " +;
            " AND AR0.AR0_TCKTRA = '" + cCodPreAut + "' " + ; 
            " AND SC9.D_E_L_E_T_  = ' '"   
    
    cQrySC9	:= ChangeQuery( cQrySC9 ) 
    DbUseArea( .T., "TOPCONN", TCGenQry( , , cQrySC9 ), cTempSC9, .F., .T. )

    If ( cTempSC9 )->( !Eof() )
        While ( cTempSC9 )->( !Eof() )
            SC9->( DBGoTo( ( cTempSC9 )->RECNO ) )
            RecLock("SC9",.F.)
                SC9->C9_BLCRED  := '90'     // 90=Bloqueado por regras Risk
                lRet := .T.
            MsUnlock()
            ( cTempSC9 )->( DBSkip() )
        End
    EndIf
    ( cTempSC9 )->( DBCloseArea() )

    RESTAREA(aArea)
    RESTAREA(aAreaSC9)

    FWFreeArray( aArea )
    FWFreeArray( aAreaSC9 )
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskClrPedBalance
Função que valida se o saldo do ticket foi liberado pelo Mais Negocios.

@param cNumPed, caracter , Número do pedido de venda
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return cRet, caracter, Retorno do processamento.
     0 - Pedido de venda não foi encerrado por residuo ou pedido não possui
     ticket de credito relacionado.
     1 - Saldo do ticket de credito liberado
     2 - Saldo do ticket de credito nao liberado.

@author  Squad NT TechFin
@since   09/04/2021
/*/
//-------------------------------------------------------------------------------------
Function RskClrPedBalance( cNumPed, lAutomato )
    Local aSvAlias      := GetArea()
    Local cTempAlias    := ""
    Local cRet          := AR0_SLD_NFOUND   // 0=Pedido de venda não foi encerrado por residuo ou pedido não possui ticket de credito relacionado.
    Local nTamNota      := TamSX3( "C5_NOTA" )[1]

    Default lAutomato := .F.

    If !Empty( cNumPed )
        cQuery := " SELECT AR0_TICKET" +;
                    " FROM " + RetSqlName("AR0") + " AR0 " +;
                        " INNER JOIN " + RetSqlName("SC5") + " SC5 " +;
                            " ON AR0.AR0_FILPED = SC5.C5_FILIAL " +;
                            " AND AR0.AR0_NUMPED = SC5.C5_NUM " +;
                            " AND SC5.C5_FILIAL = '" + xFilial("SC5") + "' " +;
                            " AND SC5.C5_NUM = '" + cNumPed + "' " +;
                            " AND ( SC5.C5_NOTA = '" + PadR("XXXXXX",nTamNota) + "' " +;
                            " OR SC5.C5_NOTA = '" + Replicate("X",nTamNota) + "' ) " +;  
                            " AND SC5.D_E_L_E_T_ = ' ' " +;
                    " WHERE AR0.AR0_FILIAL = '" + xFilial("AR0") + "' " +;
                            " AND AR0.AR0_TCKTRA <> ' ' " +;
                            " AND AR0.AR0_STATUS IN ( '" + AR0_STT_APPROVED + "', '" + AR0_STT_PARTIALLY + "' ) " +; // 2=Aprovado ### 6=Parcialmente Faturado;
                            " AND AR0.AR0_SALDO > 0 " +;
                            " AND AR0.D_E_L_E_T_ = ' ' "
                       
        cQuery      := ChangeQuery( cQuery )  
        cTempAlias  := MPSysOpenQuery( cQuery )   
        
        While (cTempAlias)->(!Eof())
            If RSKClrTktBalance( (cTempAlias)->AR0_TICKET, lAutomato )
                cRet := AR0_SLD_RELEASED    // 1=Saldo do ticket liberado
            Else
                cRet := AR0_SLD_UNRELEASED  // 2=Saldo do ticket não liberado.
                LogMsg( "RskClrPedBalance", 23, 6, 1, "", "", "RskClrPedBalance -> " + STR0047 + AllTrim((cTempAlias)->AR0_TICKET) )    //"Falha ao baixar o saldo do ticket: "
                Exit  
            EndIf
            (cTempAlias)->(DBSkip())    
        End
        (cTempAlias)->( DBCloseArea() )
    EndIf 

    RestArea( aSvAlias )

    FWFreeArray( aSVAlias )
Return cRet 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKClrTktBalance
Função que limpa o saldo do ticket de crédito.

@param  cTicket, caracter, Código do crédito
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return lRet, logico, Retorna verdadeiro se o saldo do ticket de credito foi liberado.
@author  Squad NT TechFin
@since   06/08/2020
/*/
//-------------------------------------------------------------------------------------
Function RSKClrTktBalance( cTicket, lAutomato )
    Local aArea         := GetArea()
    Local aAreaSA1      := SA1->(GetArea())
    Local aAreaAR0      := AR0->(GetArea())
    Local aErrorMd      := {}
    Local oMdlAR0       := Nil
    Local oRest         := Nil   
    Local oJBalance     := Nil
    Local oJResult      := Nil
    Local cEndPoint     := "/api/v3/clearbalance"
    Local cResult       := ""
    Local lRet          := .F.

    Default cTicket     := ""
    Default lAutomato   := .F.

    If !Empty( cTicket )    
        AR0->(DBSetOrder(1))    //AR0_FILIAL+AR0_TICKET
        SA1->(DBSetOrder(1))    //A1_FILIAL+A1_COD+A1_LOJA
                
        lRet := AR0->( DBSeek( xFilial("AR0") + cTicket ) )

        If lRet 
            lRet := SA1->( DBSeek( AR0->AR0_FILCLI + AR0->AR0_CODCLI + AR0->AR0_LOJCLI ) )
        EndIf

        If lRet  
            oJBalance := JsonObject():New()
            oJBalance["preAuthorizationCode"]   := AllTrim(AR0->AR0_TCKTRA)
            oJBalance["documentNumber"]         := AllTrim(SA1->A1_CGC)    
            
            IF !lAutomato
                cResult := RSKRestExec( RSKPOST, cEndPoint, @oRest, oJBalance, RISK, SERVICE, .T., .F. )   // POST ### 1=Risk ### 2=URL de autenticação de serviços
            Else
                cResult := RskADVPRData( 'RSKA010' )
            EndIf
                    
            If !Empty( cResult )
                oJResult := JSONObject():New()
                oJResult:FromJSON( cResult )    
                
                lRet := oJResult:GetJsonObject( "success" )

                If lRet
                    If oMdlTktAct == Nil
                        oMdlTktAct := FWLoadModel( "RSKA010" )
                    EndIf

                    oMdlTktAct:SetOperation( MODEL_OPERATION_UPDATE )
                    oMdlTktAct:Activate()  

                    If oMdlTktAct:IsActive()
                        oMdlAR0 := oMdlTktAct:GetModel( "AR0MASTER" )
                        oMdlAR0:SetValue("AR0_SALDO", 0)
                        If oMdlAR0:GetValue("AR0_STATUS") == AR0_STT_APPROVED   // 2=Aprovada
                            //------------------------------------------------------------------------------
                            // Deixa o status como cancelado pois não teve faturamento.
                            //------------------------------------------------------------------------------
                            oMdlAR0:SetValue("AR0_STATUS", AR0_STT_CANCELED )   // 4=Cancelado  
                        EndIf   
                        If oMdlTktAct:VldData()
                            oMdlTktAct:CommitData()  
                        Else
                            lRet := .F.
                            aErrorMd := oModel:GetErrorMessage()
                            LogMsg( "RSKClrTktBalance", 23, 6, 1, "", "", "RSKClrTktBalance -> " + aErrorMd[6] )
                        EndIf
                    Else
                        lRet := .F.    
                        aErrorMd := oModel:GetErrorMessage()
                        LogMsg( "RSKClrTktBalance", 23, 6, 1, "", "", "RSKClrTktBalance -> " + aErrorMd[6] )
                    EndIf  
                    oMdlTktAct:DeActivate()
                EndIf
            Else
                IF !lAutomato
                    LogMsg( "RSKClrTktBalance", 23, 6, 1, "", "", "RSKClrTktBalance -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "" ) )  
                EndIf
            EndIf
        EndIf
    EndIf
    
    RestArea(aAreaAR0)
    RestArea(aAreaSA1)
    RestArea(aArea)

    FWFreeArray( aErrorMd )
    FWFreeArray( aAreaAR0 )
    FWFreeArray( aAreaSA1 )
    FWFreeArray( aArea )
    FreeObj( oMdlAR0 )
    FreeObj( oRest )
    FreeObj( oJBalance )  
    FreeObj( oJResult )
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} RSKCLEARTKT
Rotina que irá realizar a limpeza do saldo do ticket na Supplier.

@param  cAlias, caracter, nome da tabela atrelado ao browse
@param  nReg, number, RECNO do registro
@param  nOpc, number, opção do aRotina que está semdo executada
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Rodrigo G. Soares
@since  06/10/2020
/*/
//-----------------------------------------------------------------------------
Function RSKCLEARTKT( cAlias, nReg, nOpc, lAutomato )
    Local aSvAlias      := GetArea()
    Local aAreaSC9      := SC9->( GetArea() )
    Local cTempAliasSC9 := ""
    Local cQuerySC9     := ""
    Local cTempAliasAR1 := ""
    Local cQueryAR1     := ""
    Local lRet          := .T.
    Local oModel        := Nil
    Local oMdlAR0       := Nil

    Default lAutomato := .F.

    If AR0->AR0_SALDO > 0 .And. AR0->AR0_STATUS $ ('"' + AR0_STT_APPROVED + '|' + AR0_STT_PARTIALLY + '"')     // 2=Aprovado ### 6=Faturado Parcialmente
        //------------------------------------------------------------------------------                    
        // Validação para não liberar o saldo quando a NF ainda não enviada
        //------------------------------------------------------------------------------
        cQueryAR1 := " SELECT AR1.AR1_COD, AR1.AR1_STATUS, AR0.AR0_TICKET" +;
                    " FROM " + RetSqlName("AR1") + " AR1 " +;
                        " INNER JOIN " + RetSqlName("AR0") + " AR0 " +;
                            " ON AR0_FILIAL = '" + xFilial("AR0") + "' " +;
                                " AND AR0.AR0_TICKET = '"+ AR0->AR0_TICKET + "'" + ;
                                " AND AR0.AR0_TKTRSK = AR1.AR1_TKTRSK " +;
                                " AND AR0.D_E_L_E_T_ = ' ' " + ;
                    " WHERE AR1_FILIAL = '" + xFilial("AR1") + "' " +;
                            " AND AR1.D_E_L_E_T_ = ' '"    

        cQueryAR1      := ChangeQuery( cQueryAR1 )  
        cTempAliasAR1  := MPSysOpenQuery( cQueryAR1 )

        If (cTempAliasAR1)->(!Eof()) 
            IF ( (cTempAliasAR1)->AR1_STATUS $ '"' + AR1_STT_AWAIT + '|' + AR1_STT_ANALYSIS + '"' )   // 0=Aguardando Envio ### 1=Em Análise   
                lRet := .F.
            ENDIF
            (cTempAliasAR1)->(DBSkip()) 
        ENDIF 
        (cTempAliasAR1)->( DBCloseArea() ) 
            
        IF lRet    
            cQuerySC9 := " SELECT SC9.C9_PEDIDO, SC9.C9_ITEM, SC9.R_E_C_N_O_ RECNO" +;
                        " FROM " + RetSqlName("SC9") + " SC9 " +;
                            " INNER JOIN " + RetSqlName("AR0") + " AR0 " +;
                                " ON AR0.AR0_FILPED = SC9.C9_FILIAL " +;
                                " AND AR0.AR0_NUMPED = SC9.C9_PEDIDO " +;
                                " AND AR0.AR0_TICKET = SC9.C9_TICKETC " +;
                                " AND AR0.D_E_L_E_T_ = ' ' " +;
                        " WHERE C9_FILIAL = '" + xFilial("SC9") + "' " +;
                                " AND C9_TICKETC = '"+ AR0->AR0_TICKET + "'" + ;   
                                " AND C9_NFISCAL = ' ' " +;
                                " AND C9_SERIENF = ' ' " +;
                                " AND SC9.D_E_L_E_T_ = ' ' " 
                            
            cQuerySC9      := ChangeQuery( cQuerySC9 )  
            cTempAliasSC9  := MPSysOpenQuery( cQuerySC9 )
            
            BEGIN TRANSACTION 
                If (cTempAliasSC9)->(!Eof())  
                    If !lAutomato
                        lRet := MsgYesNo(STR0033 + Chr(13) + Chr(10) + STR0034,STR0001) //"Existe liberação de pedido de venda apto à faturar associado a este ticket de crédito."###"Deseja estornar a liberação para limpar o saldo deste ticket de crédito?"###"Tickets de Crédito"  
                    Else 
                        lRet := .T.
                    EndIf

                    If lRet 
                        While (cTempAliasSC9)->(!Eof())    
                            SC9->( DBGoTo( (cTempAliasSC9)->RECNO ) )
                            If !lAutomato
                                FWMsgRun(, {|| lRet := A460Estorna() }, STR0037, I18N( STR0035, { AllTrim(SC9->C9_PEDIDO) , AllTrim(SC9->C9_ITEM) } ) ) //"Aguarde..."###"Estornando a liberação do Pedido: #1 Item: #2"
                            Else
                                lRet := A460Estorna()
                            EndIf

                            If !lRet
                                MsgAlert(STR0041,STR0001) //"Não foi possível estornar liberação do pedido de venda associado a este ticket de crédito"###"Tickets de Crédito" 
                                Exit
                            EndIf
                            (cTempAliasSC9)->(DBSkip())       
                        End  
                    EndIf
                EndIf
                ( cTempAlias )->( DbCloseArea() )

                If lRet
                    If !lAutomato
                        FWMsgRun(, {|| lRet := RSKClrTktBalance( AR0->AR0_TICKET ) }, STR0037, STR0038) //"Aguarde..."###"Liberando saldo do ticket de crédito."
                    Else
                        lRet := RSKClrTktBalance( AR0->AR0_TICKET ) 
                    EndIf

                    If lRet
                        oModel := FWLoadModel( "RSKA010" )  
                        oModel:SetOperation( MODEL_OPERATION_UPDATE )
                        oModel:Activate() 

                        If oModel:IsActive()     
                            oMdlAR0 := oModel:GetModel( "AR0MASTER" )

                            IF AR0->AR0_STATUS == AR0_STT_PARTIALLY     // 6=Faturado Parcialmente
                                oMdlAR0:SetValue("AR0_STATUS", AR0_STT_BILLED)      // 7=Faturado
                            Else
                                oMdlAR0:SetValue("AR0_STATUS", AR0_STT_CANCELED)    // 4=Cancelado
                            EndIf

                            oMdlAR0:SetValue("AR0_SALDO", 0)

                            If oModel:VldData()  
                                oModel:CommitData()
                            Else
                                lRet := .F.
                                MsgAlert(STR0039,STR0001) //"Não foi possível liberar o saldo deste ticket de crédito..."###"Tickets de Crédito"  
                            EndIf
                        EndIf 
                    Else 
                        MsgAlert(STR0039,STR0001) //"Não foi possível liberar o saldo deste ticket de crédito..."###"Tickets de Crédito"     
                    EndIf
                EndIf

                If !lRet
                    DisarmTransaction()   
                EndIf
            END TRANSACTION  
        Else
            MsgAlert(STR0054,STR0001) //"Existem NFs Mais Negócio em processo de implantação junto a Supplier. Aguardar por gentileza o término do processo e tente novamente mais tarde."
        ENDIF
    Else
        MsgAlert(STR0040,STR0001) //"Ticket de crédito sem saldo ou campo Status diferente de Aprovado ou Faturamento Parcial."###"Tickets de Crédito" 
    EndIF

    RestArea( aSvAlias )
    RestArea( aAreaSC9 )
 
    FWFreeArray( aSvAlias )
    FWFreeArray( aAreaSC9 )
    FreeObj( oModel )
    FreeObj( oMdlAR0 )     
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPedAdt
Valida a condição de pagamento para identificar se é Mais Negócios com Adiantamento

@author     Claudio Yoshio Muramatsu
@version    1.0
@since      23/08/2021
@param      cCondPgto, character, código da condição de pagamento
@return     logical, verdadeiro caso seja Adiantamento e Mais Negócios
/*/
//-----------------------------------------------------------------------------
Function RskPedAdt(cCondPgto As Character) As Logical

    Local aArea    As Array
    Local aAreaSE4 As Array
    Local lRet     As Logical
    Local lTpPay   As Logical

    Default cCondPgto := ""

    aArea    := GetArea()
    aAreaSE4 := SE4->(GetArea())
    lTpPay   := .F.

    If !Empty(cCondPgto)
        DbSelectArea("SE4")
        DbSetOrder(1) //E4_FILIAL+E4_CODIGO
        If SE4->(DbSeek(xFilial("SE4")+cCondPgto))
            lTpPay := SE4->E4_TPAY
        EndIF

        lRet := A410UsaAdi(cCondPgto) .And. lTpPay
    EndIf

    SE4->(RestArea(aAreaSE4))
    RestArea(aArea)

    FWFreeArray(aAreaSE4)
    FWFreeArray(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPedVlOri
Consulta o valor original liberado do pedido quando a condição de pagamento
possui adiantamento

@author     Claudio Yoshio Muramatsu
@version    1.0
@since      31/08/2021
@param      cFilPed, character, filial do pedido
@param      cNumPed, character, número do pedido de venda
@param      cCodCli, character, código do cliente
@param      cLojCli, character, loja do cliente
@return     number, valor original liberado do pedido de venda
/*/
//-----------------------------------------------------------------------------
Static Function RskPedVlOri( cFilPed As Character, cNumPed As Character, cCodCli As Character, cLojCli As Character) As Numeric

    Local aArea      As Array
    Local aAreaSC5   As Array
    Local cQrySC9    As Character
    Local cTempSC9   As Character
    Local nTotTicket As Numeric

    aArea      := GetArea()
    aAreaSC5   := SC5->(GetArea())
    cTempSC9   := GetNextAlias()
    nTotTicket := 0

    cQrySC9 := " SELECT SUM(SC9.C9_PRCVEN * SC9.C9_QTDLIB) VLRTOTLIB" + ;
            " FROM " + RetSqlName( "SC9" ) + " SC9 " + ;
            " INNER JOIN " + RetSQLName( "SC6" ) + " SC6 " + ;
            " ON SC6.C6_FILIAL = '" + xFilial("SC6")  + "' " + ;
            " AND SC6.C6_NUM = SC9.C9_PEDIDO " + ;
            " AND SC6.C6_ITEM = SC9.C9_ITEM " + ;
            " AND SC6.C6_PRODUTO = SC9.C9_PRODUTO " + ;
            " AND SC6.D_E_L_E_T_ = ' ' " + ;
            " INNER JOIN " + RetSQLName( "SF4" ) + " SF4 " + ;
            " ON SF4.F4_FILIAL  = '" + xFilial("SF4") + "' " + ;
            " AND SF4.F4_CODIGO = SC6.C6_TES " +;
            " AND SF4.F4_DUPLIC = 'S' " +;
            " AND SF4.D_E_L_E_T_ = ' ' " + ;
            " WHERE SC9.C9_FILIAL = '" + cFilPed + "' " + ;
                " AND SC9.C9_PEDIDO = '" + cNumPed +  "' " + ;
                " AND SC9.C9_CLIENTE = '" + cCodCli +  "' " + ;
                " AND SC9.C9_LOJA = '" + cLojCli +  "' " + ;
                " AND SC9.C9_NFISCAL = ' ' "  + ;
                " AND SC9.C9_SERIENF = ' ' " + ;
                " AND SC9.C9_BLCRED  IN ('80','92') "  + ;      // 80=Em análise RISK  ### 92=Reanálise Risk.   
                " AND SC9.D_E_L_E_T_ = ' ' "   

    cQrySC9	:= ChangeQuery(cQrySC9)

    DbUseArea( .T., "TOPCONN", TCGenQry( , , cQrySC9 ), cTempSC9, .F., .T. )

    If (cTempSC9)->VLRTOTLIB > 0
        nTotTicket := RskCalcLPed( cFilPed, cNumPed, (cTempSC9)->VLRTOTLIB )
    EndIf

    (cTempSC9)->(DbCloseArea())

    SC5->(RestArea(aAreaSC5))
    RestArea(aArea)

    FWFreeArray(aArea)
    FWFreeArray(aAreaSC5)

Return nTotTicket

//-------------------------------------------------------------------
/*/{Protheus.doc} FormAR6Struct()
Monta estrutura do tipo FWformModelStruct.

AddField([01] C Titulo do campo,;
		 [02] C ToolTip do campo,;
	     [03] C identificador (ID) do Field,;
         [04] C Tipo do campo,;
         [05] N Tamanho do campo,;
         [06] N Decimal do campo,;
         [07] B Code-block de validação do campo,;
         [08] B Code-block de validação When do campo,;
         [09] A Lista de valores permitido do campo,;
         [10] L Indica se o campo tem preenchimento obrigatório,;
         [11] B Code-block de inicializacao do campo,;
         [12] L Indica se trata de um campo chave,;
         [13] L Indica se o campo não pode receber valor em uma operação de update.,;
         [14] L Indica se o campo é virtual)

@author Daniel Moda
@since 09/02/2022
/*/
//-------------------------------------------------------------------
Static function FormAR6Struct(oStruct As Object)

Local aArea As Array

aArea := GetArea()

oStruct:AddField(FWX3Titulo("AR1_COD")   , FWX3Titulo("AR1_COD")   , "CODIGO"   , "C", TamSx3("AR1_COD")[1]   , 0                     , Nil, Nil, Nil, Nil, Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_DOC")   , FWX3Titulo("AR1_DOC")   , "DOCUMENTO", "C", TamSx3("AR1_DOC")[1]   , 0                     , Nil, Nil, Nil, Nil, Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_SERIE") , FWX3Titulo("AR1_SERIE") , "SERIE"    , "C", TamSx3("AR1_SERIE")[1] , 0                     , Nil, Nil, Nil, Nil, Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_STATUS"), FWX3Titulo("AR1_STATUS"), "STATUS" 	, "C", TamSx3("AR1_STATUS")[1],	0                     , Nil, Nil, Nil, Nil, Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_CHVNFE"), FWX3Titulo("AR1_CHVNFE"), "CHAVENFE" , "C", TamSx3("AR1_CHVNFE")[1], 0                     , Nil, Nil, Nil, Nil, Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_VLRNF") , FWX3Titulo("AR1_VLRNF") , "VLRNF"    , "N", TamSx3("AR1_VLRNF")[1] ,	TamSx3("AR1_VLRNF")[2],	Nil, Nil, Nil, Nil, Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_TCKTRA"), FWX3Titulo("AR1_TCKTRA"), "TKTRSK"   , "C", TamSx3("AR1_TCKTRA")[1],	0                 	  ,	Nil, Nil, Nil, Nil,	Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_NFEMIS"), FWX3Titulo("AR1_NFEMIS"), "NFEMIS"   , "D", TamSx3("AR1_NFEMIS")[1],	0               	  ,	Nil, Nil, Nil, Nil,	Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_NFELET"), FWX3Titulo("AR1_NFELET"), "NFELET"   , "C", TamSx3("AR1_NFELET")[1],	0                 	  ,	Nil, Nil, Nil, Nil, Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_EMINFE"), FWX3Titulo("AR1_EMINFE"), "EMINFE"   , "D", TamSx3("AR1_EMINFE")[1],	0              		  ,	Nil, Nil, Nil, Nil,	Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_HORNFE"), FWX3Titulo("AR1_HORNFE"), "HORNFE"   , "C", TamSx3("AR1_HORNFE")[1],	0               	  ,	Nil, Nil, Nil, Nil,	Nil, Nil, .T., .F.)
oStruct:AddField(FWX3Titulo("AR1_CODNFE"), FWX3Titulo("AR1_CODNFE"), "CODNFE"   , "C", TamSx3("AR1_CODNFE")[1],	0              		  , Nil, Nil, Nil, Nil,	Nil, Nil, .T., .F.)

RestArea( aArea )

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AddFieldAR6()
Adiciona os campos da estrutura do tipo FWFormViewStruct.
AddField(
        [01] C Nome do Campo
        [02] C Ordem
        [03] C Titulo do campo  
        [04] C Descrição do campo  
        [05] A Array com Help
        [06] C Tipo do campo
        [07] C Picture
        [08] B Bloco de Picture Var
        [09] C Consulta F3
        [10] L Indica se o campo é editável
        [11] C Pasta do campo
        [12] C Agrupamento do campo
        [13] A Lista de valores permitido do campo (Combo)
        [14] N Tamanho Maximo da maior opção do combo
        [15] C Inicializador de Browse
        [16] L Indica se o campo é virtual
        [17] C Picture Variáve
)

@return Nil

@author Daniel Moda
@since 09/02/2022
/*/
//-------------------------------------------------------------------
Static function AddFieldAR6(oStruct As Object)

oStruct:AddField("CODIGO"   , "01", FWX3Titulo("AR1_COD")   , FWX3Titulo("AR1_COD")   , {}, "C", "@"		        , /*bPictVar*/, /*cLookUp*/, .F.) 
oStruct:AddField("DOCUMENTO", "02", FWX3Titulo("AR1_DOC")   , FWX3Titulo("AR1_DOC")   , {}, "C", "@"		        , /*bPictVar*/, /*cLookUp*/, .F.) 
oStruct:AddField("SERIE"    , "03", FWX3Titulo("AR1_SERIE") , FWX3Titulo("AR1_SERIE") , {}, "C", "@"                , /*bPictVar*/, /*cLookUp*/, .F.) 
oStruct:AddField("STATUS"   , "04", FWX3Titulo("AR1_STATUS"), FWX3Titulo("AR1_STATUS"), {}, "C", "@"                , /*bPictVar*/, /*cLookUp*/, .F.) 
oStruct:AddField("CHAVENFE" , "05", FWX3Titulo("AR1_CHVNFE"), FWX3Titulo("AR1_CHVNFE"), {}, "C", "@"                , /*bPictVar*/, /*cLookUp*/, .F.) 
oStruct:AddField("VLRNF"    , "06", FWX3Titulo("AR1_VLRNF") , FWX3Titulo("AR1_VLRNF") , {}, "N", "@E 999,999,999.99", /*bPictVar*/, /*cLookUp*/, .F.) 
oStruct:AddField("TKTRSK"   , "07", FWX3Titulo("AR1_TCKTRA"), FWX3Titulo("AR1_TCKTRA"), {}, "C", "@E "              , /*bPictVar*/, /*cLookUp*/, .T.) 
oStruct:AddField("NFEMIS"   , "08", FWX3Titulo("AR1_NFEMIS"), FWX3Titulo("AR1_NFEMIS"), {}, "D", "@! "              , /*bPictVar*/, /*cLookUp*/, .T.) 
oStruct:AddField("NFELET"   , "09", FWX3Titulo("AR1_NFELET"), FWX3Titulo("AR1_NFELET"), {}, "C", "@"                , /*bPictVar*/, /*cLookUp*/, .T.) 
oStruct:AddField("EMINFE"   , "10", FWX3Titulo("AR1_EMINFE"), FWX3Titulo("AR1_EMINFE"), {}, "D", "@! "              , /*bPictVar*/, /*cLookUp*/, .T.) 
oStruct:AddField("HORNFE"   , "11", FWX3Titulo("AR1_HORNFE"), FWX3Titulo("AR1_HORNFE"), {}, "C", "@"                , /*bPictVar*/, /*cLookUp*/, .T.) 
oStruct:AddField("CODNFE"   , "12", FWX3Titulo("AR1_CODNFE"), FWX3Titulo("AR1_CODNFE"), {}, "C", "@"                , /*bPictVar*/, /*cLookUp*/, .T.) 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadAR6
Carga do modelo AR6 e AR1

@return aLoadAR6 , array, Retorna a carga do modelo AR6

@author Daniel Moda
@since  09/02/2022
/*/
//-------------------------------------------------------------------
Static Function LoadAR6() As Array

Local aLoadAR6  As Array
Local aAreaAR1  As Array
Local aAreaAR6  As Array
Local aNFiscal  As Array
Local cComboBox As Character
Local nItem     As Numeric
Local nPosNF    As Numeric

aLoadAR6  := {}
aAreaAR1  := AR1->(GetArea())
aAreaAR6  := AR6->(GetArea())
aNFiscal  := {}
cComboBox := ''
nItem     := 0
nPosNF    := 0

AR6->(DbSetOrder(2)) //AR6_FILIAL + AR6_TICKET
AR1->(DbSetOrder(1)) //AR1_FILIAL + AR1_COD

If AR6->(MsSeek(xFilial("AR6")+AR0->AR0_TICKET))
    While .Not. AR6->(EOF()) .And. AR6->AR6_TICKET == AR0->AR0_TICKET
        If AR1->(MsSeek(xFilial("AR1")+AR6->AR6_COD))
            nPosNF := aScan(aNFiscal, { |x| x[2] == AR6->AR6_COD })
            If nPosNF == 0
                cComboBox := AR1->AR1_STATUS
                AADD(aLoadAR6, {nItem, { AR1->AR1_COD, AR1->AR1_DOC, AR1->AR1_SERIE, X3CboxDesc("AR1_STATUS", cComboBox), AR1->AR1_CHVNFE, AR6->AR6_VALOR, AR1->AR1_TKTRSK, DToC(AR1->AR1_NFEMIS), AR1->AR1_NFELET, DToC(AR1->AR1_EMINFE), AR1->AR1_HORNFE, AR1->AR1_CODNFE }})
                nItem++
                AADD(aNFiscal, {nItem, AR6->AR6_COD})
            Else
                aLoadAR6[nPosNF,2,6] += AR6->AR6_VALOR
            EndIf
        EndIf
        AR6->(DbSkip())
    EndDo
Else
    AR1->(DbSetOrder(4)) //AR1_FILIAL + AR1_TKTRSK
    If AR1->(MsSeek(xFilial("AR1")+AR0->AR0_TKTRSK))
        While .Not. AR1->(EOF()) .And. AR1->AR1_TKTRSK == AR0->AR0_TKTRSK
            cComboBox := AR1->AR1_STATUS
            AADD(aLoadAR6, {nItem, { AR1->AR1_COD, AR1->AR1_DOC, AR1->AR1_SERIE, X3CboxDesc("AR1_STATUS", cComboBox), AR1->AR1_CHVNFE, AR1->AR1_VLRNF, AR1->AR1_TKTRSK, DToC(AR1->AR1_NFEMIS), AR1->AR1_NFELET, DToC(AR1->AR1_EMINFE), AR1->AR1_HORNFE, AR1->AR1_CODNFE }})
            nItem++
            AR1->(DbSkip())
        EndDo
    EndIf
EndIf

RestArea(aAreaAR1)
RestArea(aAreaAR6)

FwFreeArray(aAreaAR1)
FwFreeArray(aAreaAR6)
FwFreeArray(aNFiscal)

Return aLoadAR6

//------------------------------------------------------------------------------
/*/{Protheus.doc} MyRSKA010
Exemplo de rotina automatica de ticket de credito.

@author Squad NT TechFin
@since  06/10/2020
/*/
//-----------------------------------------------------------------------------
/*
User Function MyRSKA010()
    Local aArea     := GetArea()
    Local aAR0Auto  := {}
    Local cNumPed   := "000001"
    Local lRet      := .T.

    Private lMsErroAuto := .F.

    //RpcSetEnv("MyCompany","MyBranch")

    RpcSetEnv("T1","M SP 01 ")

    DBSelectArea("SC5")
    DBSetOrder(1)
  
    DBSelectArea("SE4")
    DBSetOrder(1)

    If SC5->( DBSeek(xFilial("SC5") + cNumPed ) )
        
        //Gera ticket de credito para condição TOTVS Mais Negócios
        If SE4->( DBSeek( xFilial("SE4") + SC5->C5_CONDPAG ) ) .And. SE4->E4_TPAY
            aAdd(aAR0Auto,{"AR0_FILCLI" ,xFilial("SA1")                 ,Nil})  //Filial do Cliente
            aAdd(aAR0Auto,{"AR0_CODCLI"	,SC5->C5_CLIENTE                ,Nil})  //Codigo do Cliente
            aAdd(aAR0Auto,{"AR0_LOJCLI"	,SC5->C5_LOJACLI                ,Nil})  //Loja do Cliente
            aAdd(aAR0Auto,{"AR0_FILPED"	,SC5->C5_FILIAL                 ,Nil})  //Filial do Pedido de Vendas
            aAdd(aAR0Auto,{"AR0_NUMPED"	,SC5->C5_NUM                    ,Nil})  //Numero do Pedido de Venda
            aAdd(aAR0Auto,{"AR0_DTSOLI" ,FWTimeStamp(1,Date(),Time())   ,Nil})  //Data e Hora da solicitação formato TimeStamp ***
            aAdd(aAR0Auto,{"AR0_TPAY"   ,SE4->E4_TPAY                   ,Nil})  //Ticket de credito integração Mais Negocio?
            aAdd(aAR0Auto,{"AR0_STATUS"	,"0"                            ,Nil})  //Status do ticket (0=Aguardando Envio;1=Em Análise;2=Aprovado;3=Reprovado;4=Cancelado;5=Vencido )
            aAdd(aAR0Auto,{"AR0_STARSK"	,"1"                            ,Nil})  //Controle de Envio para Plataforma Risk (1=Enviar;2=Enviado;3=Recebido;4=Confirmado;5=Cancelado)
            aAdd(aAR0Auto,{"AR0_FILORI"	,cFilAnt                        ,Nil})  //Filial de origem do ticket de credito.
            aAdd(aAR0Auto,{"AR0_VALOR"	,500000                         ,Nil})  //Valor do Ticket
        Else
            MsgAlert("Utilize um condição de pagamento Mais Negócio...")
            lRet := .F. 
        EndIf

        //Inclusão de Ticket 
        MSExecAuto({|x,y| RSKA010(x,y)},3,aAR0Auto)
        
		If lMsErroAuto 
			MostraErro()
            lRet := .F.
		EndIf

    Else    
        MsgAlert("Pedido de venda não encontrado...")
    EndIf

    RpcClearEnv()

    RestArea(aArea)
    FWFreeArray(aArea)
    FWFreeArray(aAR0Auto) 
Return lRet
*/
