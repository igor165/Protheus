#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'RSKDEFS.CH'
#INCLUDE 'RSKA050.CH' 

//-------------------------------------------------------------------
/*/{Protheus.doc} RSKA050
Modelo e interface da tabela em AR4 - Controle de Devolu��es, Bonificacoes e Prorroga��es

@author Wagner Serrano - Squad NT / TechFin
@since 05/06/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RSKA050()
    Local oBrowse := Nil 

    Private aRotina := MenuDef()

    If !RskIsActive()
        Alert( STR0001 )   //"Esta rotina est� dispon�vel somente quando o TOTVS Mais Neg�cios est� habilitado."
        Return NIL
    EndIf
    oBrowse := FWMBrowse():New() 
    oBrowse:SetAlias( "AR4" ) 
    oBrowse:SetDescription( STR0002 )   //"Concilia��o financeira Mais Neg�cios"
    oBrowse:SetMenuDef( "RSKA050" )
    oBrowse:AddLegend( "AR4->AR4_STATUS=='" + AR4_STT_RECEPTION + "'", "BR_AMARELO", STR0003 )  // 1=Recepcionado
    oBrowse:AddLegend( "AR4->AR4_STATUS=='" + AR4_STT_MOVED + "'", "BR_VERDE", STR0004 )        // 2=Movimentado
    oBrowse:AddLegend( "AR4->AR4_STATUS=='" + AR4_STT_SCHED + "'", "BR_AZUL", STR0052 )         // 5=Agendado
    oBrowse:AddLegend( "AR4->AR4_STATUS=='" + AR4_STT_ERROR + "'", "BR_VERMELHO", STR0005 )     // 3=Corrigir
    oBrowse:AddLegend( "AR4->AR4_STATUS=='" + AR4_STT_CANCEL + "'", "BR_VIOLETA", STR0006 )     // 4=Cancelado
    oBrowse:AddLegend( "AR4->AR4_STATUS=='" + AR4_STT_CUSTOM + "'", "BR_MARROM", STR0054 )      // 6=Customizado
    oBrowse:Activate()
Return NIL  

//-------------------------------------------------------------------
Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.RSKA050' OPERATION 2 ACCESS 0  //'Visualizar'
    ADD OPTION aRotina TITLE STR0008 ACTION 'RSKA050LEG' OPERATION 6 ACCESS 0    //'Legenda'
Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
    Local oStruAR4 := FWFormStruct( 1, 'AR4' )
    Local oModel

    oModel := MPFormModel():New( 'RSKA050' )
    oModel:AddFields( 'AR4MASTER', , oStruAR4 )
    oModel:SetPrimarykey( { 'AR4_FILIAL', 'AR4_IDPROC', 'AR4_ITEM' } )
    oModel:SetDescription( STR0002 )    //'Controle de Concilia��es e P�s-Venda' 
    oModel:GetModel( 'AR4MASTER' ):SetDescription( STR0009 )    //'Dados de Concilia��es e P�s-Venda'
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
    Local oModel   := FWLoadModel( 'RSKA050' )
    Local oStruAR4 := FWFormStruct( 2, 'AR4' )
    Local oView

    oStruAR4:RemoveField( 'AR4_STARSK' )

    oView := FWFormView():New()
    oView:SetModel( oModel )
    oView:AddField( 'VIEW_AR4', oStruAR4, 'AR4MASTER' )
    oView:CreateHorizontalBox( 'TELA' , 100 )
    oView:SetOwnerView( 'VIEW_AR4', 'TELA' )
Return oView

//-------------------------------------------------------------------
Function RSKA050LEG()
    Local aLegTkt := {}

    AAdd(aLegTkt, { "BR_AMARELO", STR0003 } )   //"Recepcionado"
    AAdd(aLegTkt, { "BR_VERDE", STR0004 } )     //"Movimentado"
    AAdd(aLegTkt, { "BR_AZUL", STR0052 } )     //"Agendado"
    AAdd(aLegTkt, { "BR_VERMELHO", STR0005 } )  //"Corrigir"
    AAdd(aLegTkt, { "BR_VIOLETA", STR0006 } )   //"Cancelado"
    AAdd(aLegTkt, { "BR_MARROM", STR0054 } )   //"Customizado"

    BrwLegenda( STR0010, "Risk", aLegTkt )  //"Controle de Devolu��es, Bonificacoes e Prorroga��es"
Return

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKAR4MakeLog
Fun��o para gravar Logs e Transa��es gen�ricas na tabela AR4 - Logs

@param aIten, array, registro de P�s-Venda (TOTVS antecipa) ou concilia��o para gera��o de log. Para mais detalhes
        sobre os elementos do array, consulte a documenta��o da fun��o GetRSKItems.
@param nType, number, tipo de log a ser gravado
@param cIDLog, caracter, ID do processo
@param nSeq, number, n�mero da sequencia
@param cMessage, caracter, mensagem do processo.
@param cStatus, caracter, Status do Log.(1=Recepcionado;2=Movimentado;3=Corrigir;4=Cancelado;5=Agendado;6=Customizado)
@param lContraVencto, l�gico, indica se o tipo de recebimento parceiro � contra vencimento
@param nRecAR4, number, recno da AR4 com o mesmo Id do lan�amento (guide)

@author  Marcia Junko
@since   30/10/2020
/*/
//------------------------------------------------------------------------------------------------------------
Function RSKAR4MakeLog( aItem, nType, cIDLog, nSeq, cMessage, cStatus, lContraVencto, nRecAR4 )
    Local aArea 	  := GetArea()
    Local aAreaAR4 	  := AR4->( GetArea() )
    Local aDeserItm   := {}
    Local aERPId      := {}
    Local aCreditUnit := {}
    Local oModel      := Nil
    Local nSizeItem   := 0
    Local cContent    := ''
    Local cIdRisk     := ''
    Local cResPrc     := ''
    Local cSequence   := ''
    Local cMovType    := ''
    Local cType       := ''
    Local cErpIDType  := ''
    Local cPrefix     := ''
    Local cBranch     := ''
    Local cBranchAR4  := xFilial("AR4")
    Local cInvoice    := ''
    Local cParcel     := ''
    Local cSpecific   := ''
    Local lInsertAR4  := .F.

    Default cStatus       := ""
    Default lContraVencto := .F.
    Default nRecAR4       := 0

    dbSelectArea( "AR4" )
    dbSetOrder(2)   //AR4_FILIAL+AR4_IDORIG

    nSizeItem := TamSX3( "AR4_ITEM" )[1]

    cSequence := StrZero( nSeq, nSizeItem )

    If Empty(cStatus)
        cStatus := AR4_STT_RECEPTION  // 1=Recepcionado
    EndIf 

    If nType == CONCILIATION    // 9=Concilia��o
        cType    := LOG_MOV_CONCILIATION    // 8=Concilia��o
        cIdRisk  := aItem[ BANK_ENTRY_ID ]  // [32]-Id do lan�amento (guide)
        cContent += STR0015 + " | " + aItem[ BANK_CODE ] + CRLF         // [5]-Banco
        
        aDeserItm := StrToKArr( aItem[ BANK_AGENCY ], "-" )             // [6]-Agencia
        cContent += STR0016 + " | " + aDeserItm[1] + CRLF               //"Ag�ncia"
        
        aDeserItm := StrToKArr( aItem[ BANK_ACCOUNT�], "-" )            // [7]-Conta corrente     
        cContent += STR0017 + " | " + aDeserItm[1] + CRLF               //"Conta�corrente"
        
        cContent += STR0018 + " | " + aItem[ BANK_EVENT_TYPE ] + CRLF   //"Tipo�de�evento" ### [12]-Tipo de evento 
        cContent += STR0019 + " | " + aItem[ BANK_INVOICE ] + CRLF      //"N�mero�da�nota�fiscal" ### [10]-N�mero da nota fiscal
        cContent += STR0020 + "�| " + aItem[ BANK_ENTRY_TYPE ] + CRLF   //"Tipo�de�lan�amento" ### [14]-Tipo de lan�amento
        cContent += STR0021 + " | " + aItem[ BANK_PARCEL ] + CRLF       //"Parcela" ### [8]-Parcela 
        cContent += STR0022 + " | " + aItem[ BANK_PARCEL_NUM ] + CRLF   //"N�mero�de�parcelas" ### [9]-N�mero de parcelas 
        cContent += STR0023 + " | " + aItem[ BANK_TRANS_TYPE ] + CRLF   //"Tipo de transa��o" ###  [15]-Tipo de transa��o 
        cContent += STR0024 + "�| " + DToC( SToD( aItem[ BANK_ENTRY_DATE ] ) ) + CRLF   //"Data�do�lan�amento" ### [18]-Data do lan�amento 
        cContent += STR0025 + " | " + cValToChar( aItem[ BANK_TRANS_MAIN ] ) + CRLF     //"Valor�principal�da�transa��o" ### [22]-Valor principal da transa��o 
        cContent += STR0026 + " | " + cValToChar( aItem[ BANK_TRANS_TOTAL ] ) + CRLF    //"Valor�total�da�transa��o" ### [23]-Valor total da transa��o 
        cContent += STR0027 + " | " + cValToChar( aItem[ BANK_PARC_MAIN ] ) + CRLF      //"Valor�principal�da�parcela" ### [24]-Valor principal da parcela 
        cContent += STR0028 + " | " + cValToChar( aItem[ BANK_PARC_TOTAL ] ) + CRLF     //"Valor�total�da�parcela" ### [25]-Valor total da parcela 
        cContent += STR0029�+ " | " + DToC(SToD( aItem[ BANK_ORI_MAT_DATE ] ) ) + CRLF  //"Data�do�vencimento�original�da�parcela" ### [20]-Data do vencimento original da parcela 
        cContent += STR0030 + "�| " + DToC(SToD( aItem[ BANK_ACT_MAT_DATE ] ) ) + CRLF  //Data�do�vencimento�atual�da�parcela" ### [21]-Data do vencimento atual da parcela
        cContent += STR0031 + " | " + cValToChar( aItem[ BANK_PARC_COST ] ) + CRLF      //"Custo�de�antecipa��o�da�parcela ### [27]-Custo de antecipa��o da parcela 
        cContent += STR0032 + "�| " + cValToChar( aItem[ BANK_ENTRY_VALUE ] ) + CRLF    //"Valor�do�lan�amento" ### [26]-Valor do lan�amento

        If !Empty( cMessage )
            If cStatus != AR4_STT_CUSTOM    // 6=Customizado
                If aItem[ BANK_FUTURE ] == "S"
                    cStatus := AR4_STT_SCHED    // 5=Agendado
                Else
                    cStatus := AR4_STT_ERROR    // 3=Corrigir
                EndIf
            EndIf
            cResPrc := cMessage 
        Else
            If ( aItem[ BANK_EVENT_TYPE ] == "IMPL" .And.  aItem[ BANK_PARCEL ] != "1" .And. .Not. lContraVencto )      // [12]-Tipo de evento ### [8]-Parcela
                cResPrc := STR0053      //"Concilia��o autom�tica foi realizada na primeira parcela deste t�tulo."
                cStatus := AR4_STT_MOVED    // 2=Movimentado 
            ElseIf aItem[ BANK_EVENT_TYPE ] $ "BXSLDN|CRESUB|DEBFLO|DEBNF|DEBSUB|DEPCLI|ERFSUB|FTLOSS|LRFSUB|PGASUB|RCREDI|SLDAN"   // [12]-Tipo de evento
                cResPrc := STR0051          //"Registro integrado com sucesso!"    
                cStatus := AR4_STT_RECEPTION    // 1=Recepcionado  
            EndIf        
        EndIf       
    Else        // P�s-Venda
        cType := LOG_MOV_NI     // 9=N�o Integrado
        cMovType := aItem[ AFTER_MOVTYPE ]      // [5]-tipo de opera��o
        cIdRisk  := aItem[ AFTER_PLATFORMID ]   // [2]-PK da plataforma posteriormente enviada no POST para conclus�o da sincronia da parcela
        
        aERPId := StrToKArr( aItem[ AFTER_ERPID ], "|" )    // [3]-Id de identifica��o do Titulo
        cBranch := aERPId[ ERPID_BRANCH ]       // [2]-Filial
        cPrefix := aERPId[ ERPID_PREFIX ]       // [3]-Prefixo
        cInvoice := aERPId[ ERPID_INVOICE ]     // [4]-N�mero do t�tulo

        If Len( aERPId ) >= 5  
            cParcel := aERPId[ ERPID_PARCEL ]   // [5]-Parcela
        EndIf     

        If Len( aERPId ) >= 6
            cErpIDType := aERPId[ ERPID_TYPE ]  // [6]-Tipo
        EndIf

        If cMovType == PV_PRO       // 11=Prorroga��o de vencimentos
            cType := LOG_MOV_EXTENSION      // 4=Prorroga��o             

            cSpecific += STR0033 + " | " + cValToChar( aItem[ AFTER_MOVDATE ] ) + CRLF    //"Nova data de vencimento" ### [4]-Data do movimento
            cSpecific += STR0034 + " | " + cValToChar( aItem[ AFTER_FEEAMOUNT ] ) + CRLF  //"Valor do custo da opera��o de prorroga��o" ### [8]-Valor do custo da opera��o
            cSpecific += STR0035 + " | " + aItem[ AFTER_DEBITDATE ] + CRLF    //"Data do d�bito do parceiro" ### [9]-data do d�bito do parceiro
        ElseIf cMovType == PV_BON   // 12=Bonifica��o
            cType := LOG_MOV_BONUS      // 3=Bonifica��o
            
            // cSpecific += "Valor a ser compensado utilizando a nota de cr�dito| " + cValToChar( cValue ) + CRLF 
            cSpecific += STR0036 + " | " + cValToChar( aItem[ AFTER_LOCALAMOUNT ] ) + CRLF    //"Valor total a ser bonificado, soma das NCCs com o desconto" ### [7]-Valor bruto da opera��o
            cSpecific += STR0037 + " | " + cValToChar( aItem[ AFTER_CREDITAMOUNT ] ) + CRLF   //"Valor da soma das NCCs utilizadas nessa opera��o" ### [11]-Valor da soma das NCCs utilizadas nessa opera��o
            cSpecific += STR0038 + " | " + cValToChar( aItem[ AFTER_DISCOUNTAMOUNT ] ) + CRLF     //"Valor do desconto a ser aplicado" ### [12]-Valor do desconto a ser aplicado
            cSpecific += STR0039 + " | " + cValToChar( aItem[ AFTER_FEEAMOUNT ] ) + CRLF      //"Valor do custo da opera��o de bonifica��o" ### [8]-Valor do custo da opera��o
        ElseIf cMovType == PV_DEV   // 13=Devolu��o   
            cType := LOG_MOV_DEVOLUTION     // 7=Devolu��o

            // cSpecific += "Valor a ser compensado utilizando a nota de cr�dito | " + cValToChar( cValue ) + CRLF 
            cSpecific += STR0040 + " | " + cValToChar( aItem[ AFTER_LOCALAMOUNT ] ) + CRLF    //"Valor total a ser devolvido, soma da NCC com a devolu��o" ### [7]-Valor bruto da opera��o
            cSpecific += STR0041 + " | " + cValToChar( aItem[ AFTER_FEEAMOUNTORIGIN ] ) + CRLF    //"Valor do custo de opera��o original da antecipa��o para estorno" ### [13]-Estorno da taxa de antecipa��o
            cSpecific += STR0042 + " | " + cValToChar( aItem[ AFTER_FEEAMOUNT ] ) + CRLF      //"Valor do custo de opera��o da devolu��o" ### [8]-Valor do custo da opera��o
        ElseIf cMovType == PV_LIB_NCC   // 14=Libera��o de NCC        
            cType := LOG_MOV_RELEASE_NCC    // 5=Libera NCC             
        
            cSpecific += STR0043 + " | " + cValToChar( aItem[ AFTER_LOCALAMOUNT ] ) + CRLF    //"Saldo da NCC ap�s devolu��es confirmadas no ERP" ### [7]-Valor bruto da opera��o
        Else 
            cStatus := AR4_STT_CANCEL      // 4=Cancelado
            cResPrc += I18N( STR0044, { cMovType } )  + CRLF //"Opera��o #1 n�o reconhecida"
        EndIf             

        cContent += STR0045 + " | " + cBranch + CRLF    //'Filial"
        cContent += STR0046 + " | " + cInvoice + CRLF   //"N�mero da nota"
        cContent += STR0047 + " | " + cPrefix + CRLF    //"Prefixo"
        cContent += STR0048 + " | " + cParcel + CRLF    //"Parcela"
        If !Empty( cErpIDType ) 
            cContent += STR0049 + " | " + cErpIDType + CRLF //"Tipo"
        EndIf         
        cContent += STR0050 + " | " + cValToChar( aItem[ AFTER_MOVDATE ] ) + CRLF //"Data do movimento" ### [4]-Data do movimento
        IF !Empty( cSpecific )
            cContent += cSpecific
        EndIf
    EndIf

    If Empty( cResPrc )
        If !Empty( cMessage )
            cStatus := AR4_STT_ERROR    // 3=Corrigir
            cResPrc := cMessage 
        Else
            cStatus := AR4_STT_MOVED    // 2=Movimentado
            cResPrc := STR0051      //"Registro integrado com sucesso!"    
        EndIf
    EndIf
    cResPrc := I18N( STR0055, { DToC( Date() ), Time() } ) + CRLF + cResPrc //"Processamento executado em #1 as #2."

    oModel := FWLoadModel( "RSKA050" )   
        
    If !Empty( cIdRisk )
        If nRecAR4 > 0 .And. nType == CONCILIATION
            AR4->( DbGoTo(nRecAR4) )
            oModel:SetOperation( MODEL_OPERATION_UPDATE )
            cResPrc := AR4->AR4_RESULT + CRLF + Replicate("-",30) + CRLF + cResPrc
        ElseIf AR4->( MsSeek( cBranchAR4 + cIdRisk ) )
            oModel:SetOperation( MODEL_OPERATION_UPDATE )
            cResPrc := AR4->AR4_RESULT + CRLF + Replicate("-",30) + CRLF + cResPrc
        Else
            lInsertAR4 := .T.
            oModel:SetOperation( MODEL_OPERATION_INSERT )
        EndIf
        
        oModel:Activate()
        If lInsertAR4
            oModel:SetValue( 'AR4MASTER', "AR4_IDPROC", cIdLog ) 
            oModel:SetValue( 'AR4MASTER', "AR4_ITEM"  , cSequence ) 
            oModel:SetValue( 'AR4MASTER', "AR4_TIPMOV", cType ) 
            oModel:SetValue( 'AR4MASTER', "AR4_ORIGEM", cContent )
            oModel:SetValue( 'AR4MASTER', "AR4_IDORIG", cIdRisk )
        EndIf
        oModel:SetValue( 'AR4MASTER', "AR4_STATUS", cStatus ) 
        oModel:SetValue( 'AR4MASTER', "AR4_RESULT", cResPrc )

        If cStatus != AR4_STT_CUSTOM    // 6=Customizado
            oModel:SetValue( 'AR4MASTER', "AR4_STARSK", STT_RSK_CONFIRMED )     // 1=Confirmado
        EndIf      
        If oModel:VldData()  
            oModel:CommitData()    
        EndIf
        oModel:DeActivate()
    EndIf

    If oModel != Nil 
        oModel:Destroy()    
    EndIf
    RestArea( aArea )  
    RestArea( aAreaAR4 )  

    FWFreeArray( aArea ) 
    FWFreeArray( aAreaAR4 ) 
    FWFreeArray( aERPId )
    FWFreeArray( aCreditUnit ) 
    FWFreeArray( aDeserItm ) 
    FreeObj( oModel )
Return

//------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RSKAR4IDLog
Fun��o que gera o ID do lote de logs.

@return caracter, ID do processo

@author  Marcia Junko
@since   30/10/2020
/*/
//------------------------------------------------------------------------------------------------------------
Function RSKAR4IDLog()
    Local aArea := GetArea()
    Local aAreaAR4 := AR4->( GetArea() )
    Local nExecs := 0
    Local cIdProc := ''
    Local lContinue := .T.

    dbSelectArea( "AR4" ) 
    dbSetOrder(1)   //AR4_FILIAL+AR4_IDPROC+AR4_ITEM                                                         
    While lContinue
        nExecs++
        //------------------------------------------------------------------------------
        // Trata para que o processo n�o fique em loop
        //------------------------------------------------------------------------------
        IF nExecs > 30
            lContinue := .F.
        Else
            cIdProc := FWTimeStamp( 1, Date(), Time() ) 
            If AR4->( MSSeek( xFilial( "AR4" ) + cIdProc ) ) 
                Sleep( 2000 ) 
                cIdProc := FWTimeStamp( 1, Date(), Time() )
            Else
                lContinue := .F.
            EndIf
        EndIf
    End

    RestArea( aArea )
    RestArea( aAreaAR4 )

    FWFreeArray( aArea )
    FWFreeArray( aAreaAR4 )
Return cIdProc
