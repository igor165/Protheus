#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "RSKDefs.ch"
#INCLUDE "RSKA020.CH"

Static oBrowse   := Nil
Static __oQryAR6 := Nil
Static __oQrySD2 := Nil

#DEFINE BANKSLIP_MESSAGE    1   // Mensagem de retorno
#DEFINE BANKSLIP_CONTENT    2   // Boleto
#DEFINE BANKSLIP_DATE       3   // Data do retorno

#DEFINE CANCEL_APPROVED     '2' // Aprovado
#DEFINE CANCEL_REPROVED     '3' // ReAprovado

#DEFINE PARTIAL_INVOICE    .F.  // Fatura Parcial
#DEFINE TOTAL_INVOICE      .T.  // Fatura Total

#DEFINE CREDIT_TICKET_ID       1  // Ticket de Crédito
#DEFINE SALES_ORDER_NUMBER     2  // Pedido de Venda
#DEFINE BILLED_AMOUNT          3  // Valor da Nota Fiscal
//-------------------------------------------------------------------
/*/{Protheus.doc} RSKA020
Rotina MVC para Controle de Documentos de Saída OFF Balance

@author Rodrigo G. Soares
@since 21/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RSKA020( nOpcAuto, uAR1Auto, lAutomato )
	Local aAuto     := {}
	Local oModel    := Nil

	Private aRotina := MenuDef()

	Default uAR1Auto    := Nil
	Default nOpcAuto    := 0
	Default lAutomato   := .F.

	If uAR1Auto == Nil
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias( 'AR1' )
		oBrowse:SetDescription( STR0001 )   //"Documento de Saída TOTVS Mais Negócios"
		oBrowse:SetMenuDef( "RSKA020" )
		oBrowse:AddLegend( "AR1_STATUS=='0'", "BR_BRANCO"     , STR0034 )     //"Aguardando Envio"
		oBrowse:AddLegend( "AR1_STATUS=='1'", "BR_AMARELO"    , STR0002 )     //"Em Análise"
		oBrowse:AddLegend( "AR1_STATUS=='2'", "BR_VERDE"      , STR0003 )     //"Aprovada"
		oBrowse:AddLegend( "AR1_STATUS=='3'", "BR_VERMELHO"   , STR0004 )     //"Rejeitada"
		oBrowse:AddLegend( "AR1_STATUS=='4'", "BR_PRETO"      , STR0005 )     //"Cancelada"
		oBrowse:AddLegend( "AR1_STATUS=='5'", "BR_VIOLETA"    , STR0006 )     //"Inconsistente"
		oBrowse:AddLegend( "AR1_STATUS=='6'", "BR_CINZA"      , STR0044 )     //"Em Cancelamento"
		oBrowse:AddLegend( "AR1_STATUS=='7'", "BR_AZUL_CLARO" , STR0062 )     //"Em Cancelamento Sefaz"
		oBrowse:AddLegend( "AR1_STATUS=='8'", "BR_AZUL"       , STR0063 )     //"Em Cancelamento Supplier"
		oBrowse:AddLegend( "AR1_STATUS=='9'", "BR_LARANJA"    , STR0064 )     //"Erro no Cancelamento ERP"
		oBrowse:AddLegend( "AR1_STATUS=='A'", "BR_MARROM"     , STR0065 )     //"Cancelamento Recusado Supplier"
		oBrowse:AddLegend( "AR1_STATUS=='B'", "BR_CINZA_OCEAN", STR0075 )     //"Negada"
		oBrowse:AddLegend( "AR1_STATUS=='C'", "BR_PINK"       , STR0079 )     //"NF Cancelada na Supplier"

		oBrowse:Activate()

		FreeObj( oBrowse )
	Else
		oModel  := FWLoadModel( "RSKA020" )
		aAuto   := { { "AR1MASTER" ,uAR1Auto} }
		FWMVCRotAuto( oModel, "AR1", nOpcAuto, aAuto, /*lSeek*/, .T. )
		FreeObj( oModel )
	EndIf

	FWFreeArray( aAuto )
	FWFreeArray( uAR1Auto )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina.

@author Rodrigo G. Soares
@since 21/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.RSKA020' OPERATION MODEL_OPERATION_VIEW     ACCESS 0  //'Visualizar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'Rsk020RBrw'      OPERATION MODEL_OPERATION_UPDATE   ACCESS 0  //'Atualizar'
	ADD OPTION aRotina TITLE STR0009 ACTION 'RskViewBSlip'    OPERATION MODEL_OPERATION_UPDATE   ACCESS 0  //'Boleto'
	ADD OPTION aRotina TITLE STR0037 ACTION 'RskReANF'        OPERATION MODEL_OPERATION_UPDATE   ACCESS 0  //'Reanálise'
	ADD OPTION aRotina TITLE STR0040 ACTION 'Rsk020Cancel'    OPERATION MODEL_OPERATION_UPDATE   ACCESS 0  //'Cancelamento'
	ADD OPTION aRotina TITLE STR0080 ACTION 'Rsk020CanSup'    OPERATION MODEL_OPERATION_UPDATE   ACCESS 0  //'Cancelar na Supplier
	ADD OPTION aRotina TITLE STR0010 ACTION 'Rsk020Leg'       OPERATION 6   ACCESS 0                       //'Legenda'
Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados

@author Rodrigo G. Soares
@since 21/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oStruAR1  := FWFormStruct( 1, 'AR1' )
	Local oStruAR2  := FWFormStruct( 1, 'AR2' )
	Local oStruAR6  := Nil
	Local oModel    := Nil

	oModel := MPFormModel():New( 'RSKA020' )
	oModel:AddFields( 'AR1MASTER', /*cOwner*/, oStruAR1 )
	oModel:SetDescription( STR0001 )    //"Documento de Saída TOTVS Mais Negócios"
	oModel:SetPrimaryKey( {'AR1_FILIAL', 'AR1_COD'} )

	oModel:AddGrid( 'AR2DETAIL', 'AR1MASTER', oStruAR2 )
	oModel:SetRelation( 'AR2DETAIL', { { 'AR2_FILIAL', 'xFilial( "AR2" )' }, { 'AR2_COD', 'AR1_COD' } }, AR2->( IndexKey( 1 ) ) )
	oModel:GetModel( 'AR2DETAIL' ):SetUniqueLine( { 'AR2_ITEM' } )
	oModel:GetModel( 'AR2DETAIL' ):SetDescription( STR0011 )    //'Itens do Documento'
	oModel:GetModel( 'AR2DETAIL' ):SetOptional( .T. )

	If FWAliasInDic( "AR6" )
		oStruAR6 := FWFormStruct( 1, 'AR6' )
		oModel:AddGrid( 'AR6DETAIL', 'AR1MASTER', oStruAR6 )
		oModel:SetRelation( 'AR6DETAIL', { { 'AR6_FILIAL', 'xFilial( "AR6" )' }, { 'AR6_COD', 'AR1_COD' } }, AR6->( IndexKey( 1 ) ) )
		oModel:GetModel( 'AR6DETAIL' ):SetUniqueLine( { 'AR6_ITEM' } )
		oModel:GetModel( 'AR6DETAIL' ):SetOptional( .T. )
	EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Modelo de interface

@author Rodrigo G. Soares
@since 21/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel    := FWLoadModel( 'RSKA020' )
	Local oStruAR1  := FWFormStruct( 2, 'AR1' )
	Local oStruAR2  := FWFormStruct( 2, 'AR2' )
	Local oStruAR6  := Nil
	Local oView     := Nil

	oStruAR1:RemoveField( "AR1_FILNF" )
	oStruAR1:RemoveField( "AR1_FILCLI" )
	oStruAR1:RemoveField( "AR1_FILPAR" )
	oStruAR1:RemoveField( "AR1_FILORI" )
	oStruAR1:RemoveField( "AR1_TKTRSK" )
	oStruAR1:RemoveField( "AR1_CMDINV" )
	oStruAR1:RemoveField( "AR1_DTSOLI" )
	oStruAR1:RemoveField( "AR1_DTAVAL" )
	oStruAR1:RemoveField( "AR1_RCOUNT" )
	oStruAR1:RemoveField( "AR1_STARSK" )

	oStruAR2:RemoveField( "AR2_COD" )
	oStruAR2:RemoveField( "AR2_IDTITP" )
	oStruAR2:RemoveField( "AR2_FILNFD" )
	oStruAR2:RemoveField( "AR2_NEWVEN" )
	oStruAR2:RemoveField( "AR2_OLDVEN" )
	oStruAR2:RemoveField( "AR2_CLIENT" )
	oStruAR2:RemoveField( "AR2_LOJA" )
	oStruAR2:RemoveField( "AR2_FORNEC" )
	oStruAR2:RemoveField( "AR2_LOJFOR" )

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_AR1', oStruAR1, 'AR1MASTER' )
	oView:AddGrid(  'VIEW_AR2', oStruAR2, 'AR2DETAIL' )

	If FWAliasInDic( "AR6" )
		oStruAR6  := FWFormStruct( 2, 'AR6' )
		oStruAR6:RemoveField( "AR6_COD" )
		oStruAR6:RemoveField( "AR6_ITEM" )
		oStruAR6:RemoveField( "AR6_TKTRSK" )
		oView:AddGrid( 'VIEW_AR6', oStruAR6, 'AR6DETAIL' )
		oView:CreateHorizontalBox( 'SUPERIOR', 50 )
		oView:CreateHorizontalBox( 'INFERIOR', 30 )
		oView:CreateHorizontalBox( 'TICKETS' , 20 )
		oView:SetOwnerView( 'VIEW_AR6', 'TICKETS' )
		oView:SetViewProperty( 'VIEW_AR6', "ENABLENEWGRID" )
	Else
		oView:CreateHorizontalBox( 'SUPERIOR', 60 )
		oView:CreateHorizontalBox( 'INFERIOR', 40 )
	EndIf

	oView:SetOwnerView( 'VIEW_AR1', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_AR2', 'INFERIOR' )
	oView:AddIncrementField( 'VIEW_AR2', 'AR2_ITEM' )
	oView:SetViewProperty( 'VIEW_AR2', "ENABLENEWGRID" )
	oView:SetViewProperty( 'VIEW_AR2', "GRIDSEEK", { .T. } )
	oView:SetViewProperty( 'VIEW_AR2', "GRIDFILTER", { .T. } )

	oView:addUserButton( STR0012, '', {|| Rsk20DiaB() },,, )   //'Emissão do Boleto'
	oView:addUserButton( STR0041, '', {|| RSK20TIT() },,, )   //'Títulos enviados a Supplier'
	oView:ShowUpdateMsg( .T. )
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Rsk020Leg
legenda

@author Rodrigo G. Soares
@since 21/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Rsk020Leg()
	Local aLegenda := {}

	aAdd( aLegenda, { "BR_BRANCO"     , STR0034 } )    //"Aguardando Envio"
	aAdd( aLegenda, { "BR_AMARELO"    , STR0002 } )    //"Em Análise"
	aAdd( aLegenda, { "BR_VERDE"      , STR0003 } )    //"Aprovada"
	aAdd( aLegenda, { "BR_VERMELHO"   , STR0004 } )    //"Rejeitada"
	aAdd( aLegenda, { "BR_PRETO"      , STR0005 } )    //"Cancelada"
	aAdd( aLegenda, { "BR_VIOLETA"    , STR0006 } )    //"Inconsistente"
	aAdd( aLegenda, { "BR_CINZA"      , STR0044 } )    //Em Cancelamento"
	aAdd( aLegenda, { "BR_AZUL_CLARO" , STR0062 } )    //"Em Cancelamento Sefaz"
	aAdd( aLegenda, { "BR_AZUL"       , STR0063 } )    //"Em Cancelamento Supplier"
	aAdd( aLegenda, { "BR_LARANJA"    , STR0064 } )    //"Erro Cancelamento ERP"
	aAdd( aLegenda, { "BR_MARROM"     , STR0065 } )    //"Cancelamento Recusado Supplier"
	aAdd( aLegenda, { "BR_CINZA_OCEAN", STR0075 } )    //"Negada"
	aAdd( aLegenda, { "BR_PINK"       , STR0079 })     //"NF Cancelada na Supplier"


	BrwLegenda( STR0013, STR0013, aLegenda ) //"Legenda"

	FWFreeArray( aLegenda )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RskNFSInsert
Função responsavel para gravar os dados do Documento de Saída, na
tabela AR1.

@param cChaveF2 - Chave da tabela SF2, indice 1.

@return boolean, indica se conseguiu gravar o registro na AR1.
@author Rodrigo G. Soares
@since 21/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RskNFSInsert( cChaveF2 )
	Local aArea      := GetArea()
	Local aAreaSF2   := SF2->( GetArea() )
	Local aAreaSE4   := SE4->( GetArea() )
	Local aAreaSM0   := SM0->( GetArea() )
	Local aAreaAR1   := AR1->( GetArea() )
	Local aCliente   := {}
	Local aErrorMd   := {}
	Local oModel     := Nil
	Local oMdlAR1    := Nil
	Local oMdlAR6    := Nil
	Local lRet       := .T.
	Local lNfsNg  	 := SuperGetMV("MV_RSKNNFS",,.T.)
	Local cItem      := ""
	Local cQuery     := ""
	Local cTemp      := ""
	Local lTicket    := FWAliasInDic( "AR6" )
	Local lRejeitado := .F.

	SF2->( DBSetOrder(1) )  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	SE4->( DBSetOrder(1) )  //E4_FILIAL+E4_CODIGO
	SM0->( DBSetOrder(1) )  //M0_CODIGO+M0_CODFIL
	AR1->( DbSetOrder(2) )  //AR1_FILIAL+AR1_FILNF+AR1_DOC+AR1_SERIE+AR1_CLIENT+AR1_LOJA

	If lNfsNg
		aCliente := StrTokArr2( Alltrim( SuperGetMv( 'MV_RSKCPAY' ) ), '|', )
		If !Empty( aCliente )
			If ( SF2->( MSSeek( cChaveF2 ) ) .And. !Empty( SF2->F2_DUPL ) )
				If ( SE4-> ( MSSeek( xFilial( "SE4" ) + SF2->F2_COND ) ) .And. SE4->E4_TPAY )
					If !AR1->( MsSeek( xFilial("AR1") + SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )
                        oModel := FWLoadModel( "RSKA020" )
                        oModel:SetOperation( MODEL_OPERATION_INSERT )
                        oMdlAR1 := oModel:GetModel( "AR1MASTER" )

                        If oModel:Activate()
                            oMdlAR1:SetValue( "AR1_FILNF"     , SF2->F2_FILIAL )
                            oMdlAR1:SetValue( "AR1_DOC"       , SF2->F2_DOC )
                            oMdlAR1:SetValue( "AR1_SERIE"     , SF2->F2_SERIE )
                            oMdlAR1:SetValue( "AR1_PREFIX"    , SF2->F2_PREFIXO )
                            oMdlAR1:SetValue( "AR1_FILCLI"    , xFilial("SA1") )
                            oMdlAR1:SetValue( "AR1_CLIENT"    , SF2->F2_CLIENTE )
                            oMdlAR1:SetValue( "AR1_LOJA"      , SF2->F2_LOJA )
                            oMdlAR1:SetValue( "AR1_FILPAR"    , xFilial("SA1") )
                            oMdlAR1:SetValue( "AR1_CLIPAR"    , aCliente[1] )
                            oMdlAR1:SetValue( "AR1_LJPARC"    , aCliente[2] )
                            oMdlAR1:SetValue( "AR1_NFEMIS"    , SF2->F2_EMISSAO )
                            oMdlAR1:SetValue( "AR1_FILORI"    , cFilAnt )
                            oMdlAR1:SetValue( "AR1_CGCCLI"    , SA1->A1_CGC )
                            oMdlAR1:SetValue( "AR1_VLRNF"     , SF2->F2_VALBRUT )
                            oMdlAR1:SetValue( "AR1_CONDPG"    , SF2->F2_COND )
                            oMdlAR1:SetValue( "AR1_DTSOLI"    , FWTimeStamp( 1, Date(), Time() ) )

                            If SM0->( MSSeek( cEmpAnt + cFilAnt ) )
                                oMdlAR1:SetValue( "AR1_CGCPAR", SM0->M0_CGC )
                            EndIf

                            If __oQryAR6 == Nil
                                cQuery :=   "SELECT AR0_TICKET, AR0_TKTRSK, AR0_STATUS, D2_PEDIDO, D2_ITEMPV, D2_VALBRUT " + ;
                                    "FROM ? SC9 " + ;
                                    "INNER JOIN ? AR0 " + ;
                                    "ON AR0_FILIAL = ? " + ;
                                    "AND AR0_TICKET = C9_TICKETC " + ;
                                    "AND AR0.D_E_L_E_T_ = ' ' " + ;
                                    "INNER JOIN ? SD2 " + ;
                                    "ON D2_FILIAL = ? " + ;
                                    "AND D2_DOC = C9_NFISCAL " + ;
                                    "AND D2_SERIE = C9_SERIENF " + ;
                                    "AND D2_CLIENTE = C9_CLIENTE " + ;
                                    "AND D2_LOJA = C9_LOJA " + ;
                                    "AND D2_COD = C9_PRODUTO " + ;
                                    "AND D2_PEDIDO = C9_PEDIDO " + ;
                                    "AND D2_ITEMPV = C9_ITEM " + ;
                                    "AND D2_NUMSEQ = C9_NUMSEQ " + ;
                                    "AND SD2.D_E_L_E_T_ = ' ' " + ;
                                    "WHERE C9_FILIAL = ? " + ;
                                    "AND C9_NFISCAL = ? " + ;
                                    "AND C9_SERIENF = ? " + ;
                                    "AND SC9.D_E_L_E_T_ = ' ' " + ;
                                    "ORDER BY AR0_TICKET "
                                cQuery := ChangeQuery( cQuery )
                                __oQryAR6 := FWPreparedStatement():New(cQuery)
                            EndIf

                            __oQryAR6:SetUnsafe(1, RetSqlName( "SC9" ))
                            __oQryAR6:SetUnsafe(2, RetSqlName( "AR0" ))
                            __oQryAR6:SetString(3, xFilial( "AR0" ))
                            __oQryAR6:SetUnsafe(4, RetSqlName( "SD2" ))
                            __oQryAR6:SetString(5, xFilial( "SD2" ))
                            __oQryAR6:SetString(6, xFilial( "SC9" ))
                            __oQryAR6:SetString(7, SF2->F2_DOC)
                            __oQryAR6:SetString(8, SF2->F2_SERIE)

                            cQuery := __oQryAR6:GetFixQuery()
                            cTemp  := MPSysOpenQuery( cQuery )
                            If (cTemp)->(!EOF())
                                oMdlAR1:SetValue( "AR1_TKTRSK" , (cTemp)->AR0_TKTRSK )
                                If lTicket
                                    oMdlAR6 := oModel:Getmodel( "AR6DETAIL" )
                                    cItem   := StrZero( 0, TAMSX3( "AR6_ITEM" )[1] )
                                    While .Not. (cTemp)->(EOF())

                                        If !lRejeitado
                                            lRejeitado := (!(cTemp)->AR0_STATUS == AR0_STT_APPROVED .And. !(cTemp)->AR0_STATUS == AR0_STT_PARTIALLY)
                                        EndIf

                                        cItem := Soma1( cItem )
                                        oMdlAR6:SetValue( "AR6_FILIAL"  , AR1->AR1_FILIAL )
                                        oMdlAR6:SetValue( "AR6_COD"     , AR1->AR1_COD )
                                        oMdlAR6:SetValue( "AR6_ITEM"    , cItem )
                                        oMdlAR6:SetValue( "AR6_TICKET"  , (cTemp)->AR0_TICKET )
                                        oMdlAR6:SetValue( "AR6_TKTRSK"  , (cTemp)->AR0_TKTRSK )
                                        oMdlAR6:SetValue( "AR6_NUMPED"  , (cTemp)->D2_PEDIDO )
                                        oMdlAR6:SetValue( "AR6_ITEMPV"  , (cTemp)->D2_ITEMPV )
                                        oMdlAR6:SetValue( "AR6_VALOR"   , (cTemp)->D2_VALBRUT )
                                        oMdlAR6:AddLine()

                                        (cTemp)->(DbSkip())
                                    EndDo
                                Else
                                    lRejeitado := (!(cTemp)->AR0_STATUS == AR0_STT_APPROVED .And. !(cTemp)->AR0_STATUS == AR0_STT_PARTIALLY)
                                EndIf

                            Else
                                lRejeitado := .T.
                            EndIf

                            If lRejeitado
                                oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_REJECTED )  // 3=Rejeitada
                                oMdlAR1:SetValue( "AR1_STARSK", STARSK_CANCELED )   // 5=Cancelado
                            Else
                                oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_AWAIT )     // 0=Aguardando Envio
                                oMdlAR1:SetValue( "AR1_STARSK", STARSK_SUBMIT )     // 1=Enviar
                            EndIf

                            If oModel:VldData()
                                oModel:CommitData()
                            Else
                                lRet := .F.
                                aErrorMd := oModel:GetErrorMessage()
                                LogMsg( "RskNFSInsert", 23, 6, 1, "", "", "RskNFSInsert -> " + aErrorMd[6] )
                            EndIf
                        Else
                            lRet := .F.
                            aErrorMd := oModel:GetErrorMessage()
                            LogMsg( "RskNFSInsert", 23, 6, 1, "", "", "RskNFSInsert -> " + aErrorMd[6] )
                        EndIf
                        oModel:Destroy()
					Else
						lRet := .F.
						Help( "", 1, "RskNFSInsert", , STR0082, 1, 0,,,,,, { STR0083 } )     //"Numeração de Nota Fiscal já integrada com a Supplier."###"Nota Fiscal integrada."
					EndIf
				EndIf
			EndIf
		else
			lRet := .F.
			Help( "", 1, "RskNFSInsert", , STR0060, 1, 0,,,,,, { STR0061 } )     //"Dados do parceiro Supplier não foram informados."###"Verifique se os dados do cliente parceiro foram preenchidos."
		EndIf
	EndIf

	RestArea( aArea )
	RestArea( aAreaSF2 )
	RestArea( aAreaSM0 )
	RestArea( aAreaSE4 )
	RestArea( aAreaAR1 )

	FWFreeArray( aArea )
	FWFreeArray( aCliente )
	FWFreeArray( aAreaSM0 )
	FWFreeArray( aAreaSE4 )
	FWFreeArray( aAreaSF2 )
	FWFreeArray( aAreaAR1 )
	FWFreeArray( aErrorMd )
	FreeObj( oModel )
	FreeObj( oMdlAR1 )
	FreeObj( oMdlAR6 )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RskNFSMovFin
Função responsavel para gravar os Titulos na tabela AR2.

@param aDoc - Array com os dados do documento.
    [1]-Filial do documento
    [2]-Numero do documento
    [3]-id
    [4]-Codigo do Retorno
    [5]-Mensagem do Retorno
    [6]-Codigo da transacao
    [7]-Boleto em base64
    [8]-Valor total de taxas
    [9]-Valor total das parcelas
    [10]-Data de pagamento
    [11]-informações das parcelas
@param aTitulos - Array com os Titulos
    [1]-Tipo do título gerado
    [2]-Filial
    [3]-Prefixo do documento
    [4]-Numero do titulo
    [5]-Parcela do título
    [6]-Tipo do título
    [7]-Código do cliente
    [8]-Loja do cliente
    [9]-Valor do título
    [10]-Data de vencimento do título

@return boolean, indica se conseguiu gravar os registros financeiros na AR2.
@author Rodrigo G. Soares
@since 25/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RskNFSMovFin( aDoc, aTitulos )
	Local aAreaAnt  := GetArea()
	Local aAreaAR1  := AR1->( GetArea() )
	Local aErrorMd  := {}
	Local oModel    := Nil
	Local oMdlAR2   := Nil
	Local nElem     := 0
	Local cItem     := ""
	Local lRet      := .T.

	AR1->( DBSetOrder(1) )    //AR1_FILIAL + AR1_COD

	If AR1->( MsSeek( xFilial("AR1") + aDoc[ UPD_I_INVOICE ] ) )    // [2]-Numero do documento
		oModel := FWLoadModel( 'RSKA020' )
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		If oModel:Activate()
			oModel:SetValue( "AR1MASTER", "AR1_TXNEG"  , aDoc[ UPD_I_TOTAL_FEE ] )              // [8]-Valor total das taxas
			oModel:SetValue( "AR1MASTER", "AR1_VLRREC" , aDoc[ UPD_I_TOTAL_PARC] )              // [9]-Valor total das parcelas
			oModel:SetValue( "AR1MASTER", "AR1_DTPGTO" , sTod( aDoc[ UPD_I_RECEIPT_DT ] ) )     // [10]-Data recebimento parceiro

			oMdlAR2     := oModel:Getmodel( "AR2DETAIL" )
			oMdlAR2:GoLine( oMdlAR2:Length() )

			If oMdlAR2:IsEmpty()
				cItem := StrZero( 0, TAMSX3( "AR2_ITEM" )[1] )
			Else
				cItem := oMdlAR2:GetValue( "AR2_ITEM" )
			EndIf

			For nElem := 1 To Len( aTitulos )
				cItem := Soma1( cItem )

				oMdlAR2:SetValue( "AR2_FILIAL"  , xFilial( "AR2", aDoc[ UPD_I_BRANCH ] ) )       // [1]-Filial
				oMdlAR2:SetValue( "AR2_COD"     , AR1->AR1_COD )
				oMdlAR2:SetValue( "AR2_ITEM"    , cItem )
				oMdlAR2:SetValue( "AR2_MOV"     , aTitulos[nElem][ BILL_OPERATION ] )            // [1]-Tipo do título gerado
				oMdlAR2:SetValue( "AR2_FILTIT"  , aTitulos[nElem][ BILL_BRANCH ] )               // [2]-Filial
				oMdlAR2:SetValue( "AR2_PREFIX"  , aTitulos[nElem][ BILL_PREFIX ] )               // [3]-Prefixo do documento
				oMdlAR2:SetValue( "AR2_NUMTIT"  , aTitulos[nElem][ BILL_NUMBER ] )               // [4]-Numero do titulo
				oMdlAR2:SetValue( "AR2_PARC"    , aTitulos[nElem][ BILL_INSTALLMENT ] )          // [5]-Parcela do título
				oMdlAR2:SetValue( "AR2_TIPO"    , aTitulos[nElem][ BILL_TYPE ] )                 // [6]-Tipo do título

				If aTitulos[nElem][ BILL_OPERATION ] == BILL_MAIN               // 1=Título principal
					oMdlAR2:SetValue( "AR2_CLIENT"  , aTitulos[nElem][ BILL_CUSTOMER ] )         // [7]-Código do cliente
					oMdlAR2:SetValue( "AR2_LOJA"    , aTitulos[nElem][ BILL_CUST_UNIT ] )        // [8]-Loja do cliente
				Else
					oMdlAR2:SetValue( "AR2_FORNEC"  , aTitulos[nElem][ BILL_CUSTOMER ] )         // [7]-Código do cliente
					oMdlAR2:SetValue( "AR2_LOJFOR"  , aTitulos[nElem][ BILL_CUST_UNIT ] )        // [8]-Loja do cliente
				EndIf

				oMdlAR2:SetValue( "AR2_VALOR"   , aTitulos[nElem][ BILL_VALUE ] )                // [9]-Valor do título
				oMdlAR2:SetValue( "AR2_DATATI"  , aTitulos[nElem][ BILL_DUEDATA ] )              // [10]-Data de vencimento do título

				If (nElem != Len( aTitulos ) )
					oMdlAR2:AddLine()
				EndIf
			Next nElem

			If oModel:VldData()
				oModel:CommitData()
			Else
				lRet := .F.
				aErrorMd := oModel:GetErrorMessage()
				LogMsg( "RskNFSMovFin", 23, 6, 1, "", "", "RskNFSMovFin -> " + aErrorMd[6] )
			EndIf
		Else
			lRet     := .F.
			aErrorMd := oModel:GetErrorMessage()
			LogMsg( "RskNFSMovFin", 23, 6, 1, "", "", "RskNFSMovFin -> " + aErrorMd[6] )
		EndIf

		oModel:Destroy()
	EndIf

	RestArea( aAreaAnt )
	RestArea( aAreaAR1 )

	FWFreeArray( aAreaAnt )
	FWFreeArray( aAreaAR1 )
	FWFreeArray( aErrorMd )
	FreeObj( oModel )
	FreeObj( oMdlAR2 )
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RskNFSDelete
Função responsavel por deletar os registros das tabelas AR1 2 AR2,
vinculados a Nota Fiscal.
tabela do Risco.

@param chaveAR1 - Chave da tabela AR1, indice 1.
@param lSupplier - Cancelamento Supplier , Logical

@author Rodrigo G. Soares
@since 25/05/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RskNFSDelete( cChaveF2, lSupplier)
	Local aAreaAnt   := GetArea()
	Local aAreaAR1   := AR1->( GetArea() )
	Local oModel     := Nil
	Local oModelAR1  := Nil
	Local cObs       := ''
	Local lRet       := .T.
	Local lRskEstFat := IsInCallStack("RskEstFat")
	Default lSupplier := .F.

	AR1->( DBSetOrder(2) )    //AR1_FILIAL+AR1_FILNF+AR1_DOC+AR1_SERIE+AR1_CLIENT+AR1_LOJA

	If AR1->( MSSeek( xFilial("AR1") + cChaveF2 ) ) .And. AR1->AR1_STATUS <> AR1_STT_CANSUPOK // C = NF Cancelada na Supplier.

        oModel := FwLoadModel ( "RSKA020" )
        If AR1->AR1_STATUS == AR1_STT_AWAIT .Or. AR1->AR1_STATUS == AR1_STT_REJECTED
			lRet := RskDelFin(AR1->AR1_FILIAL, AR1->AR1_COD)

			oModel:SetOperation( MODEL_OPERATION_DELETE )
			oModel:Activate()
			If lRet .And. oModel:VldData()
				oModel:CommitData()
			EndIf
            oModel:DeActivate()
		Else
            oModel:SetOperation( MODEL_OPERATION_UPDATE )
            oModel:Activate()

            If oModel:IsActive()
                oModelAR1 := oModel:GetModel( "AR1MASTER" )

                //------------------------------------------------------------------------------
                // Não exclui os titulos mais negocios quando a NF é cancelanda pela integração.
                //------------------------------------------------------------------------------
                If !lRskEstFat
                    If lSupplier
                        oModelAR1:SetValue( "AR1_STATUS", AR1_STT_CANSUPOK ) // C = NF Cancelada na Supplier.
                        cObs := AR1->AR1_OBSPAR + CRLF + STR0086 + ': ' + cValtochar(Date()) + ' - ' + cValtochar(Time()) //'Nota Fiscal Mais Negocio Cancelada na Supplier.' ### data ### hora
                    Else
                        If AR1->AR1_STATUS <> AR1_STT_DENIED
                            oModelAR1:SetValue( "AR1_STATUS", AR1_STT_CANCELED ) // 4 = Cancelada
                        EndIf
                        cObs := AR1->AR1_OBSPAR + CRLF + STR0042 //'Nota Fiscal Mais Negocio Cancelada por exclusão da NF de origem.'
                        lRet := RskDelFin(AR1->AR1_FILIAL, AR1->AR1_COD)
                    Endif
                    oModelAR1:SetValue( "AR1_OBSPAR", cObs)
                EndIf

                If lRet .And. oModel:VldData()
                    oModel:CommitData()
                EndIf
            EndIf
        EndIf
		oModel:Destroy()
	EndIf

	RestArea( aAreaAnt )
	RestArea( aAreaAR1 )

	FWFreeArray( aAreaAnt )
	FWFreeArray( aAreaAR1 )
	FreeObj( oModel )
	FreeObj( oModelAR1 )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RskViewBSlip
Visualiza o boleto gerado.

@author jose.delmondes
@since 04/06/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RskViewBSlip()
	Local aArea     := GetArea()
	Local aAreaAC9  := AC9->( GetArea() )
	Local aAreaACB  := ACB->( GetArea() )
	Local cFileDoc  := ""
	Local nRet      := 0

	AC9->( DBSetOrder(2) )    //AC9_FILIAL+AC9_ENTIDA+AC9_FILENT+AC9_CODENT+AC9_CODOBJ
	ACB->( DBSetOrder(1) )    //ACB_FILIAL+ACB_CODOBJ

	If AR1->AR1_STATUS == "2"
		If AC9->( DBSeek( xFilial( "AC9" ) + "AR1" + xFilial( "AR1" ) + xFilial( "AR1" ) + AR1->AR1_COD ) )
			If ACB->( DBSeek( xFilial( "ACB" ) + AC9->AC9_CODOBJ ) ) .And. AllTrim( Upper( ACB->ACB_DESCRI ) ) == "BOLETO"
				If GetRemoteType() == 5
					cFileDoc := Lower( Alltrim( MsDocPath() + "/" + ACB->ACB_OBJETO ) )
					nRet := CpyS2TW( cFileDoc, .T. )
					If nRet < 0
						MsgAlert( STR0014 ) //"Falha ao baixar o boleto bancário."
					Endif
				Else
					MsDocView( ACB->ACB_OBJETO )
				Endif
			Else
				Help( "", 1, "RskVBnkSlip", , STR0015, 1, 0,,,,,, { STR0016 } ) //"Boleto bancário não disponível"###"Solicite a emissão do boleto com parceiro de crédito."
			EndIf
		Else
			Help( "", 1, "RskVBnkSlip", , STR0015, 1, 0,,,,,, { STR0016 } )    //"Boleto bancário não disponível."###"Solicite a emissão do boleto com parceiro de crédito."
		EndIf
	Else
		Help( "", 1, "RskVBnkSlip", , STR0015, 1, 0,,,,,, { STR0017 } )    //"Boleto bancário não disponível."###"Verifique se o status do documento de saída está aprovado."
	EndIf

	RestArea( aArea )
	RestArea( aAreaAC9 )
	RestArea( aAreaACB )

	FWFreeArray( aArea )
	FWFreeArray( aAreaAC9 )
	FWFreeArray( aAreaACB )
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} RskPostNFS
Funcao que envia as NFS Mais Negócios diretamente para plataforma risk.

@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Squad NT TechFin
@since  24/08/2020
/*/
//-----------------------------------------------------------------------------
Function RskPostNFS( lAutomato )
	Local aArea             := GetArea()
	Local aAreaAR0          := AR0->( GetArea() )
	Local aAreaAR1          := AR1->( GetArea() )
	Local aAreaSF2          := SF2->( GetArea() )
	Local aAreaSD2          := SD2->( GetArea() )
	Local aAreaSE1          := SE1->( GetArea() )
	Local aAreaSF3          := SF3->( GetArea() )
	Local cCodDene          := If(FindFunction("RetCodDene"),RetCodDene(),"110|205|301|302|303|304")
	Local aJItems           := {}
	Local aData             := {}
	Local aJPCondItems      := {}
	Local aErrorMd          := {}
	Local aCreditTickets    := {}
	Local aTktCrd           := {}
	Local cTempNFS          := ""
	Local cTempSE1          := ""
	Local cHost             := ""
	Local cEndPoint         := ""
	Local cInvNumber        := ""
	Local cInvSerie         := ""
	Local cInvIssue         := ""
	Local cSrvInvNum        := ""
	Local cSrvInvIssue      := ""
	Local cNumPedido        := ""
	Local cQryNFS           := ""
	Local cQrySE1           := ""
	Local cErpId            := ""
	Local cBody             := ""
	Local cDescription      := ""
	Local cNFeKey           := ""
	Local lRskPedAdt        := .F.
	Local lF3DescRet        := SF3->(FieldPos("F3_DESCRET")) > 0
	Local nCount            := 0
	Local nRecProc          := 0
	Local nLimit            := 10
	Local nRetryCount       := 99
	Local nX                := 0
	Local nY                := 0
	Local nQtdCredit        := 0
	Local nPosTktCrd        := 0
	Local nPosErpId         := 0
	Local nInstallment      := 0
	Local nNfeType          := 0
	Local nValNF            := 0
	Local oJResult          := Nil
	Local oJItem            := Nil
	Local oRest             := Nil
	Local oModel            := Nil
	Local oMdlAR1           := Nil
	Local oJPCondItem       := Nil
	Local oJPCreditTickets  := Nil
	Local oQrySE1           := NIL
	Local dDataBase         := Date()
	Local lAPIV3            := .F.
	Local lLockByFil	    := !Empty(xFilial("AR1"))
	Local lFirstInstallment := .T.
	Local lTicket           := FWAliasInDic( "AR6" )
	Local lDenegado         := .F.
	Local lTktRejeit        := .F.

	Default lAutomato := .F.

	If LockByName("RskPostNFS", .T., lLockByFil )
		cHost       := GetRSKPlatform( .F. )
		cEndPoint   := "/api/v3/invoice"
		lAPIV3      := AR1->( ColumnPos("AR1_CODNFE") ) > 0

		If !Empty( cHost ) .Or. lAutomato
			cTempNFS    := GetNextAlias()
			cTempSE1    := GetNextAlias()

			AR1->( DBSetOrder(1) )  //AR1_FILIAL+AR1_COD
			SE1->( DBSetOrder(2) )  //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			SD2->( DBSetOrder(3) )  //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			If lTicket
				AR6->( DbSetOrder(1) )  //AR6_FILIAL+AR6_COD+AR6_ITEM
				AR0->( dbSetOrder(1) )  //AR0_FILIAL+AR0_TICKET
			Else
				AR0->( dbSetOrder(4) )  //AR0_FILIAL + AR0_TKTRSK
			EndIf

			cQrySE1  := " SELECT R_E_C_N_O_  RECNO" + ;
				" FROM " + RetSqlName( "SE1" ) + " SE1 " + ;
				" WHERE E1_FILIAL = '" + xFilial( "SE1" ) + "' " + ;
				" AND E1_CLIENTE = ? " + ;
				" AND E1_LOJA = ? " + ;
				" AND E1_NUM = ? " + ;
				" AND E1_SERIE = ? " + ;
				" AND E1_ORIGEM = 'MATA460' " + ;
				" AND E1_TIPO = 'NF' " + ;
				" AND SE1.D_E_L_E_T_  = ' ' " + ;
				" ORDER BY " + SqlOrder( SE1->( IndexKey() ) )

			cQrySE1  := ChangeQuery( cQrySE1 )
			oQrySE1 := FWPreparedStatement():New( cQrySE1 )

			cQryNFS := " SELECT AR1.AR1_FILIAL, AR1.AR1_COD, AR1.AR1_FILNF, AR1.AR1_DOC, AR1.AR1_SERIE,  AR1.AR1_FILCLI, " + ;
				" AR1.AR1_CLIENT, AR1.AR1_LOJA, AR1.AR1_STATUS, AR1.AR1_VLRNF, AR1.AR1_NFEMIS, AR1.AR1_TKTRSK, " + ;
				" AR1.AR1_RCOUNT, AR1.AR1_CONDPG, AR1.R_E_C_N_O_  AR1RECNO, SF2.F2_CHVNFE, SF2.F2_NFELETR, SF2.F2_CODNFE, " + ;
				" SF2.F2_EMINFE, SF2.F2_HORNFE, SF2.F2_ESPECIE, SF2.R_E_C_N_O_  SF2RECNO  " + ;
				" FROM " + RetSqlName( "AR1" ) + " AR1 " + ;
				" INNER JOIN " + RetSqlName( "SF2" ) + " SF2 " + ;
				" ON SF2.F2_FILIAL = AR1.AR1_FILNF " + ;
				" AND SF2.F2_DOC = AR1.AR1_DOC " + ;
				" AND SF2.F2_SERIE = AR1.AR1_SERIE " + ;
				" AND ( SF2.F2_CHVNFE <> ' ' OR ( SF2.F2_CODNFE <> ' ' AND SF2.F2_NFELETR <> ' ' ) ) " + ;
				" AND SF2.D_E_L_E_T_ = ' ' " + ;
				" WHERE AR1.AR1_FILIAL = '" + xFilial( "AR1" ) + "' " + ;
				" AND AR1.AR1_STARSK = '" + STARSK_SUBMIT + "' " + ;   // 1=Enviar
			" AND AR1.D_E_L_E_T_ = ' ' " + ;
				" ORDER BY " + SqlOrder( AR1->( IndexKey() ) )

			cQryNFS  := ChangeQuery( cQryNFS )

			DbUseArea( .T., "TOPCONN", TCGenQry( , , cQryNFS ), cTempNFS, .F., .T. )

			If ( cTempNFS )->( !Eof() )
				//-----------------------------------------------------------------------------------
				// Identifica a quantidade de registro no alias temporário para processamento.
				//-----------------------------------------------------------------------------------
				COUNT TO nRecProc

				//-------------------------------------------------------------------
				// Posiciona no primeiro registro.
				//-------------------------------------------------------------------
				( cTempNFS )->( DBGoTop() )

				//------------------------------------------------------------------
				// Ajusta o pagesize, caso o numero de registros de envio for menor.
				//------------------------------------------------------------------
				If nLimit > nRecProc
					nLimit := nRecProc
				EndIf

				oModel  := FWLoadModel( "RSKA020" )
				While ( cTempNFS )->( !Eof() )
					nCount    += 1
					lDenegado := .F.
					lTktRejeit := .F.
					If AllTrim( ( cTempNFS )->F2_ESPECIE ) == "SPED"
						SF3->( DbSetOrder(4) ) //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
						If SF3->( DbSeek(( cTempNFS )->AR1_FILNF + ( cTempNFS )->AR1_CLIENT + ( cTempNFS )->AR1_LOJA + ( cTempNFS )->AR1_DOC + ( cTempNFS )->AR1_SERIE) )
							If AllTrim(SF3->F3_CODRSEF) $ cCodDene
								lDenegado := .T.

								AR1->( DBGoTo( ( cTempNFS )->AR1RECNO ) )

								oModel:SetOperation( MODEL_OPERATION_UPDATE )
								oModel:Activate()

								If oModel:IsActive()
									oMdlAR1 := oModel:GetModel( "AR1MASTER" )
									oMdlAR1:SetValue( "AR1_STATUS", "B" ) //"0=Aguardando Envio;1=Em Análise;2=Aprovada;3=Rejeitada;4=Cancelada;5=Inconsistente;6=Em Cancelamento;7=Em Cancelamento Sefaz;8=Em Cancelamento Supplier;9=Erro no Cancelamento ERP;A=Cancelamento Recusado Supplier;B=Negada"
									oMdlAR1:SetValue( "AR1_STARSK", "5" ) //1=Enviar;2=Enviado;3=Recebido;4=Confirmado;5=Cancelado
									oMdlAR1:SetValue( "AR1_CHVNFE", ( cTempNFS )->F2_CHVNFE )
									cDescription +=  STR0076 //"Nota Fiscal de Saída não enviada para a plataforma Risk pois foi denegada pela Sefaz."
									If lF3DescRet .And. !Empty(SF3->F3_DESCRET)
										cDescription += Space(1) + AllTrim(SF3->F3_DESCRET)
									EndIf
									oMdlAR1:SetValue( "AR1_OBSPAR", cDescription )

									If oModel:VldData()
										oModel:CommitData()
									Else
										aErrorMd := oModel:GetErrorMessage()
										LogMsg( "RskPostNFS", 23, 6, 1, "", "", "RskPostNFS -> " + aErrorMd[6] )
									EndIf

									oModel:DeActivate()
								EndIf
							EndIf
						EndIf
					EndIf

					If !Empty((cTempNFS)->AR1_TKTRSK)

						If lTicket
							If AR6->( MsSeek( ( cTempNFS )->AR1_FILIAL + ( cTempNFS )->AR1_COD ) )
								While .Not. AR6->(EOF()) .And. AR6->AR6_FILIAL + AR6->AR6_COD == ( cTempNFS )->AR1_FILIAL + ( cTempNFS )->AR1_COD
									If AR0->(msSeek(AR6->(AR6_FILIAL + AR6_TICKET)))
										If AR0->AR0_STATUS <> AR0_STT_APPROVED .and. AR0->AR0_STATUS <> AR0_STT_PARTIALLY
											lTktRejeit := .T.
											Exit
										EndIf
									EndIf
									AR6->(dbSkip())
								EndDo
							EndIf
						Else
							If AR0->(msSeek(( cTempNFS )->AR1_FILIAL + ( cTempNFS )->AR1_TKTRSK))
								If AR0->AR0_STATUS <> AR0_STT_APPROVED .and. AR0->AR0_STATUS <> AR0_STT_PARTIALLY
									lTktRejeit := .T.
								EndIf
							EndIf
						EndIf

					Else
						lTktRejeit := .T.
					EndIf


					If lTktRejeit

						AR1->( DBGoTo( ( cTempNFS )->AR1RECNO ) )

						oModel:SetOperation( MODEL_OPERATION_UPDATE )
						oModel:Activate()

						If oModel:IsActive()

							oMdlAR1 := oModel:GetModel( "AR1MASTER" )
							oMdlAR1:SetValue("AR1_STATUS", AR1_STT_REJECTED)  // 3=Rejeitada
							oMdlAR1:SetValue("AR1_STARSK", STARSK_CANCELED)   // 5=Cancelado

							If oModel:VldData()
								oModel:CommitData()
							Else
								aErrorMd := oModel:GetErrorMessage()
								LogMsg( "RskPostNFS", 23, 6, 1, "", "", "RskPostNFS -> " + aErrorMd[6] )
							EndIf

							oModel:DeActivate()
						EndIf

					EndIf

					If !lDenegado .and. !lTktRejeit

						cErpId          := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTempNFS )->AR1_FILIAL ) + "|" + AllTrim( ( cTempNFS )->AR1_COD )
						nInstallment    := 0
						aJPCondItems    := {}
						aCreditTickets  := {}
						aTktCrd         := {}
						nNfeType        := 0
						cSrvInvNum      := ""
						cSrvInvIssue    := ""
						cNumPedido      := ""
						cInvNumber      := AllTrim(( cTempNFS )->AR1_DOC)
						cInvSerie       := AllTrim(( cTempNFS )->AR1_SERIE)
						cInvIssue       := RskDTimeUTC(( cTempNFS )->AR1_NFEMIS)
						cNFeKey         := AllTrim(( cTempNFS )->F2_CHVNFE)
						lRskPedAdt      := .F.

						If !Empty( ( cTempNFS )->F2_CHVNFE )
							//------------------------------------------------------------------------------
							// Nota de produto
							//------------------------------------------------------------------------------
							cNFeKey := AllTrim(( cTempNFS )->F2_CHVNFE)
						Else
							//------------------------------------------------------------------------------
							// Nota de serviço
							//------------------------------------------------------------------------------
							cSrvInvNum      := AllTrim(( cTempNFS )->F2_NFELETR)
							cSrvInvIssue    := RskDTimeUTC(( cTempNFS )->F2_EMINFE)
							cNFeKey         := AllTrim(( cTempNFS )->F2_CODNFE)
							nNfeType        := 1
						EndIf

						aAdd( aData, { cErpId, ( cTempNFS )->AR1RECNO, ( cTempNFS )->SF2RECNO } )

						oQrySE1:SetString( 1, ( cTempNFS )->AR1_CLIENT )
						oQrySE1:SetString( 2, ( cTempNFS )->AR1_LOJA )
						oQrySE1:SetString( 3, ( cTempNFS )->AR1_DOC )
						oQrySE1:SetString( 4, ( cTempNFS )->AR1_SERIE )

						cQrySE1     := oQrySE1:GetFixQuery()
						DbUseArea( .T., "TOPCONN", TCGenQry( , , cQrySE1 ), cTempSE1, .F., .T. )

						nAmount := 0
						//------------------------------------------------------------------------------
						// Verifica se a condição de pagamento é Mais Negócios com Adiantamento
						//------------------------------------------------------------------------------
						lRskPedAdt        := RskPedAdt( ( cTempNFS )->AR1_CONDPG )
						lFirstInstallment := .T.

						While ( cTempSE1 )->( !Eof() )
							SE1->( DBGoTo( ( cTempSE1 )->RECNO ) )

							//------------------------------------------------------------------------------
							// Condição de pagamento com adiantamento desconsidera a primeira parcela que é compensada com o RA
							//------------------------------------------------------------------------------
							If lFirstInstallment .And. lRskPedAdt
								lFirstInstallment := .F.
								( cTempSE1 )->( DBSkip() )
								Loop
							EndIf

							nInstallment    += 1

							//------------------------------------------------------------------------------
							// Busca o valor de abatimentos dos Impostos.
							//------------------------------------------------------------------------------
							nAbatement  := 0
							nAbatement  := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", SE1->E1_MOEDA, dDataBase, SE1->E1_CLIENTE, SE1->E1_LOJA,,,SE1->E1_TIPO)
							nAmount     += ( SE1->E1_VALOR - nAbatement )

							oJPCondItem                     := JsonObject():New()
							oJPCondItem["dueDate"]          := RskDTimeUTC( dTos(SE1->E1_VENCTO) )
							oJPCondItem["installmentValue"] := ( SE1->E1_VALOR - nAbatement)
							oJPCondItem["installment"]      := nInstallment

							aAdd( aJPCondItems, oJPCondItem )
							( cTempSE1 )->( DBSkip() )
						EndDo

						( cTempSE1 )->( DBCloseArea() )
						//------------------------------------------------------------------------------
						// Busca os Pedidos de Vendas que fazem parte do Faturamento (Ticket).
						//------------------------------------------------------------------------------
						If lTicket .And. AR6->( MsSeek( ( cTempNFS )->AR1_FILIAL + ( cTempNFS )->AR1_COD ) )
							While .Not. AR6->(EOF()) .And. AR6->AR6_FILIAL + AR6->AR6_COD == ( cTempNFS )->AR1_FILIAL + ( cTempNFS )->AR1_COD
								nPosTktCrd := aScan( aTktCrd, {|x| x[SALES_ORDER_NUMBER] == AR6->AR6_NUMPED } )
								If nPosTktCrd == 0
									AADD(aTktCrd, {AllTrim(AR6->AR6_TKTRSK), AR6->AR6_NUMPED, AR6->AR6_VALOR})
								Else
									aTktCrd[nPosTktCrd,03] += AR6->AR6_VALOR
								EndIf
								AR6->( DBSkip() )
							EndDo
						Else
							If SD2->( MsSeek( ( cTempNFS )->AR1_FILNF + ( cTempNFS )->AR1_DOC + ( cTempNFS )->AR1_SERIE + ( cTempNFS )->AR1_CLIENT + ( cTempNFS )->AR1_LOJA) )
								cNumPedido := SD2->D2_PEDIDO
							EndIf
							AADD(aTktCrd, {AllTrim(( cTempNFS )->AR1_TKTRSK), cNumPedido, ( cTempNFS )->AR1_VLRNF})
						EndIf

						nQtdCredit := Len(aTktCrd)
						nValNF     := 0
						For nY := 01 To nQtdCredit
							oJPCreditTickets                           := JsonObject():New()
							oJPCreditTickets["creditTicketId"]         := aTktCrd[nY,CREDIT_TICKET_ID]               // [1] Ticket de Crédito
							oJPCreditTickets["salesOrderNumber"]       := aTktCrd[nY,SALES_ORDER_NUMBER]             // [2] Pedido de Venda
							If lRskPedAdt
								oJPCreditTickets["billedAmount"]       := aTktCrd[nY,BILLED_AMOUNT]-CalcValNF((cTempNFS)->AR1_FILNF, (cTempNFS)->AR1_DOC, (cTempNFS)->AR1_SERIE, aTktCrd[nY,SALES_ORDER_NUMBER], (cTempNFS)->AR1_CONDPG)  // [3] Valor da Nota Fiscal
								nValNF += oJPCreditTickets["billedAmount"]
								If nY == nQtdCredit .And. nValNF <> nAmount
									oJPCreditTickets["billedAmount"] += nAmount - nValNF
								EndIf
							else
								oJPCreditTickets["billedAmount"]       := aTktCrd[nY,BILLED_AMOUNT]                  // [3] Valor da Nota Fiscal
							EndIf
							oJPCreditTickets["cancelRemainingBalance"] := Iif( !SeekRelease( aTktCrd[nY,CREDIT_TICKET_ID] ), PARTIAL_INVOICE, TOTAL_INVOICE )  // 1=Fatura Parcial ### 2=Fatura Total
							aAdd( aCreditTickets, oJPCreditTickets )
						Next

						oJItem                            := JsonObject():New()
						oJItem["customerId"]              := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTempNFS )->AR1_FILCLI ) + "|" + AllTrim( ( cTempNFS )->AR1_CLIENT ) + "|" + AllTrim( ( cTempNFS )->AR1_LOJA )
						oJItem["erpId"]                   := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTempNFS )->AR1_FILIAL ) + "|" + AllTrim( ( cTempNFS )->AR1_COD )
						oJItem["amount"]                  := nAmount
						oJItem["invoiceId"]               := AllTrim( cEmpAnt ) + "|" + AllTrim( ( cTempNFS )->AR1_FILNF ) + "|" + AllTrim( ( cTempNFS )->AR1_DOC ) + "|" + AllTrim( ( cTempNFS )->AR1_SERIE )
						oJItem["nfeKey"]                  := cNFeKey
						oJItem["nfeType"]                 := nNfeType // Tipo da Nota Fiscal (0-Produto, 1-Serviço)
						oJItem["issueDate"]               := cInvIssue
						oJItem["status"]                  := Val( AR1_STT_ANALYSIS ) // 1=Em análise
						oJItem["deleted"]                 := 'false'
						oJItem["retryCount"]              := ( cTempNFS )->AR1_RCOUNT
						oJItem["invoiceNumber"]           := cInvNumber
						oJItem["invoiceSerie"]            := cInvSerie
						oJItem["serviceInvoiceNumber"]    := cSrvInvNum
						oJItem["serviceInvoiceIssueDate"] := cSrvInvIssue
						oJItem["paymentConditions"]       := aJPCondItems
						oJItem["creditTickets"]           := aCreditTickets
						oJItem["errorMessage"]            := ""

						aAdd( aJItems, oJItem )

						If nCount == nLimit
							IF !lAutomato
								cBody := RSKRestExec( RSKPOST, cEndPoint, @oRest, aJItems, RISK, SERVICE, .F. , .F. )   // POST ### 1=Risk ### 2=URL de autenticação de serviços
							ELSE
								cBody := RskADVPRData( 'RSKA020' )
							EndIf

							If !Empty( cBody )
								oJResult    := JSONObject():New()
								oJResult:FromJSON( cBody )

								For nX := 1 To Len( oJResult )
									oJItem      := oJResult[nX]
									nPosErpId   := aScan( aData, {|x| x[1] == oJItem["erpId"] } )
									If nPosErpId > 0
										AR1->( DBGoTo( aData[nX][2] ) )
										SF2->( DBGoTo( aData[nX][3] ) )

										oModel:SetOperation( MODEL_OPERATION_UPDATE )
										oModel:Activate()

										If oModel:IsActive()
											oMdlAR1 := oModel:GetModel( "AR1MASTER" )

											oMdlAR1:SetValue( "AR1_RCOUNT", oJItem["retryCount"] )

											If !Empty(SF2->F2_CHVNFE)
												oMdlAR1:SetValue( "AR1_CHVNFE", SF2->F2_CHVNFE )
											EndIf

											If lAPIV3 .And. !Empty(SF2->F2_CODNFE)
												oMdlAR1:SetValue( "AR1_NFELET" , SF2->F2_NFELETR )
												oMdlAR1:SetValue( "AR1_CODNFE" , SF2->F2_CODNFE )
												oMdlAR1:SetValue( "AR1_EMINFE" , SF2->F2_EMINFE )

												If AR1->(FieldPos("AR1_HORNFE")) > 0
													oMdlAR1:SetValue( "AR1_HORNFE" , SF2->F2_HORNFE )
												EndIf
											EndIf

											If oJItem["statusProcess"] == 1
												oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_ANALYSIS )  // 1=Em análise
												oMdlAR1:SetValue( "AR1_STARSK", STARSK_SENT )       // 2=Enviado
												cDescription := " "
											Else
												cDescription := DecodeUTF8( oJItem["description"] ) + Chr(10)
												If oJItem["retryCount"] >= nRetryCount
													oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_CANCELED )  // 4=Cancelado
													oMdlAR1:SetValue( "AR1_STARSK", STARSK_CANCELED )   // 5=Cancelado
													cDescription += STR0025 //"Nota Fiscal de Saída não enviada para plataforma Risk."
												Else
													cDescription += STR0025 + Chr(10) + STR0026 //"Nota Fiscal de Saída não enviada para plataforma Risk."###"Será realizado uma nova tentativa dentro de instantes..."
												EndIf
											EndIf

											oMdlAR1:SetValue( "AR1_OBSPAR", cDescription )

											If oModel:VldData()
												oModel:CommitData()
											Else
												aErrorMd := oModel:GetErrorMessage()
												LogMsg( "RskPostNFS", 23, 6, 1, "", "", "RskPostNFS -> " + aErrorMd[6] )
											EndIf
										Else
											aErrorMd := oModel:GetErrorMessage()
											LogMsg( "RskPostNFS", 23, 6, 1, "", "", "RskPostNFS -> " + aErrorMd[6] )
										EndIf
										oModel:DeActivate()
									EndIf
								Next nX
							Else
								If !lAutomato
									LogMsg( "RskPostNFS", 23, 6, 1, "", "", "RskPostNFS -> " + oRest:GetLastError() + " " + IIF( oRest:GetResult() != Nil, oRest:GetResult(), "") )
								Endif
							EndIf

							aJItems     := {}
							aData       := {}
							nCount      := 0
							nRecProc    -= nLimit

							//------------------------------------------------------------------
							// Ajusta o pagesize para enviar os registros restantes.
							//------------------------------------------------------------------
							If nLimit > nRecProc
								nLimit := nRecProc
							EndIf
						EndIf
					EndIf
					( cTempNFS )->( DBSkip() )
				End
			EndIf

			( cTempNFS )->( DBCloseArea() )
		Else
			LogMsg( "RskPostNFS", 23, 6, 1, "", "", "RskPostNFS -> " + STR0027 )  //"Host da plataforma risk não informado."
		EndIf

		If oModel != Nil
			oModel:Destroy()
		EndIf

		UnLockByName( "RskPostNFS", .T., lLockByFil )
	Else
		LogMsg( "RskPostNFS", 23, 6, 1, "", "", "RskPostNFS -> " + STR0052 ) //"Existe um processamento de envio de NFS Mais Negócios em outra instancia..."
	EndIf

	RestArea( aArea )
	RestArea( aAreaSF2 )
	RestArea( aAreaSF3 )
	RestArea( aAreaSD2 )
	RestArea( aAreaSE1 )
	RestArea( aAreaAR1 )
	RestArea( aAreaAR0 )

	FWFreeArray( aArea )
	FWFreeArray( aAreaSF2 )
	FWFreeArray( aAreaSF3 )
	FWFreeArray( aAreaSD2 )
	FWFreeArray( aAreaSE1 )
	FWFreeArray( aAreaAR1 )
	FWFreeArray( aAreaAR0 )
	FWFreeArray( aJItems )
	FWFreeArray( aData )
	FWFreeArray( aJPCondItems )
	FWFreeArray( aCreditTickets )
	FWFreeArray( aTktCrd )
	FWFreeArray( aErrorMd )

	FreeObj( oJResult )
	FreeObj( oJItem )
	FreeObj( oRest )
	FreeObj( oModel )
	FreeObj( oMdlAR1 )
	FreeObj( oJPCondItem )
	FreeObj( oJPCreditTickets )
	FreeObj( oQrySE1 )
Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Rsk20DiaB
Dialog para geração do Boleto

@author Rodrigo G. Soares
@since 11/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Rsk20DiaB()
	LOCAL cParcela := SPACE(2)

	oDlg := MSDialog():New( 180, 180, 280, 500, STR0028,,,,, CLR_BLACK, CLR_WHITE,,, .T. )  //"2ª via do Boleto"

	oSay := TSay():New( 14, 14, {|| STR0029 }, oDlg, , , , , , .T., , , 200, 20 )    //"Número da Parcela:"

	@ 13,80 GET oGet VAR cParcela SIZE 10,10 OF oDlg PIXEL

	@ 30,100 BUTTON STR0030 SIZE 50, 10 PIXEL OF oDlg ACTION ( MsgRun( STR0028, STR0031, {|| RskVBankSplip( cParcela ) } ) , oDlg:End() ) //"Gerar boleto"###"2 Via de Boleto"###"Processando"

	ACTIVATE MSDIALOG oDlg CENTERED

RETURN NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RskVBankSplip
Abertura do Boleto

@param cParc, caracter, número da parcela

@author Rodrigo G. Soares
@since 26/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RskVBankSplip( cParc )
	Local cDirDocs 	:= MsDocPath()
	Local cName := StrTran( xFilial( 'AR1' ) + ALLTRIM( AR1->AR1_TCKTRA ), ' ', '_' )
	Local cFile := ''
	Local aInfo := {}

	Default cParc := ''

	if (len(alltrim(cParc)) == 0 .or. VAL(cParc) > 0)
		cParc := val( cParc )

		if ( cParc > 0 )
			cName += '_' + cvaltochar( cParc ) + '_boleto.pdf'
		else
			cName += '_boleto.pdf'
		EndIf

		aInfo  := RSKBankV1( ALLTRIM( AR1->AR1_CGCCLI ), ALLTRIM( AR1->AR1_TCKTRA ), cvaltochar( cParc ) )

		if ( len( aInfo ) > 0 ) .and. !empty(aInfo[ BANKSLIP_CONTENT ])     // [2]-Boleto
			cFile := alltrim( cDirDocs ) + '\' + cName

			//------------------------------------------------------------------------------
			// Cria o documento no diretorio do banco de conhecimento
			//------------------------------------------------------------------------------
			nHandle := FCREATE( cFile )

			If nHandle == -1
				lRet := .F.
			else
				FWRITE( nHandle, Decode64( aInfo[ BANKSLIP_CONTENT ] ) )    // [2]-Boleto

				If FCLOSE( nHandle ) .And. File( cFile )
					//------------------------------------------------------------------------------
					// Apresenta o boleto ao usuário
					//------------------------------------------------------------------------------
					MsDocView( cName )
				Endif
			Endif
		else
			if ( len( aInfo ) > 0 ) .and. !Empty( aInfo[ BANKSLIP_MESSAGE ] )     // [1]-Mensagem de retorno
				Help( "", 1, "RSK020BOL",, STR0032, 1, 0,,,,,, { aInfo[ BANKSLIP_MESSAGE ] } )   //"Não foi possivel gerar o boleto."
			else
				Help( "", 1, "RSK020BOL",, STR0032, 1, 0,,,,,, { STR0033 } )   //"Não foi possivel gerar o boleto."###"Verifique se a parcela e o título são válidos."
			Endif
		EndIf
	else
		Help( "", 1, "RSK020BOL",, STR0032, 1, 0,,,,,, { STR0035 } )   //"Não foi possivel gerar o boleto."###"A geração do boleto aceita apenas númerico ou vazio (todos)."
	Endif

	FWFreeArray( aInfo )

RETURN NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} RskDelFin
Função responsavel por deletar os registros vinculados a NFs Mais Negócio.
tabela do Risco.

@param cFil - Filial da Tabela AR1, AR1_FILIAL.
@param cCod - Código da tabela AR1, AR1_COD.

@return lRet - Validação do processo realizado.
@author Rodrigo G. Soares
@since 08/03/2021
@version P12
/*/
//-------------------------------------------------------------------
Function RskDelFin(cFil, cCod)
	Local aSvAlias  := GetArea()
	Local aArray    := {}
	Local lRet      := .T.
	Local cTmp      := GetNextAlias()
	Local cQuery    := ''

	Private lMsErroAuto := .F.

	BEGIN TRANSACTION
		cQuery := " SELECT E1.E1_FILIAL, E1.E1_PREFIXO, E1.E1_NUM, E1.E1_TIPO, E1.E1_PARCELA " + ;
			" FROM " + RetSqlName( "SE1" ) + " E1 " + ;
			" INNER JOIN " + RetSqlName( "AR2" ) + " AR2 " + ;
			" ON AR2.AR2_NUMTIT = E1.E1_NUM " + ;
			" AND AR2.AR2_FILTIT = E1.E1_FILORIG " + ;
			" AND AR2.AR2_PREFIX = E1.E1_PREFIXO " + ;
			" AND AR2.AR2_MOV = '" + AR2_MOV_RECEIVE + "' " + ;     // 1=Receber
		" AND AR2.D_E_L_E_T_ = ' ' " + ;
			" INNER JOIN " + RetSqlName( "AR1" ) + " AR1 " + ;
			" ON AR1.AR1_COD = AR2.AR2_COD " + ;
			" AND AR1.AR1_FILIAL = AR2.AR2_FILIAL " + ;
			" AND AR1.AR1_COD = '"+cCod+"' " + ;
			" AND AR1.AR1_FILIAL = '"+cFil+"' " + ;
			" AND AR1.D_E_L_E_T_ = ' ' " + ;
			" WHERE E1.D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery( cQuery )
		MPSysOpenQuery( cQuery, cTmp )

		While !( cTmp )->( Eof() ) .And. lRet
			aArray := { {"E1_PREFIXO"  , ( cTmp )->E1_PREFIXO    , NIL },;
				{"E1_NUM"      , ( cTmp )->E1_NUM        , NIL },;
				{"E1_TIPO"     ,( cTmp )->E1_TIPO        , Nil },;
				{"E1_PARCELA"  ,( cTmp )->E1_PARCELA     , Nil }}

			MsExecAuto( { |x,y| FINA040(x,y)}, aArray,5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

			If lMsErroAuto
				lRet := .F.
			Endif

			aArray  := {}
			( cTmp ) ->( DbSkip())
		EndDo
		( cTmp )->( DBCloseArea() )

		If lRet
			cQuery := " SELECT E2.E2_FILIAL, E2.E2_PREFIXO, E2.E2_NUM, E2.E2_TIPO, E2.E2_PARCELA " + ;
				" FROM " + RetSqlName( "SE2" ) + " E2 " + ;
				" INNER JOIN " + RetSqlName( "AR2" ) + " AR2 " + ;
				" ON AR2.AR2_NUMTIT = E2.E2_NUM " + ;
				" AND AR2.AR2_FILTIT = E2.E2_FILORIG " + ;
				" AND AR2.AR2_PREFIX = E2.E2_PREFIXO " + ;
				" AND AR2.AR2_MOV = '" + AR2_MOV_FEE + "' " + ;       // 2=Taxa
			" AND AR2.D_E_L_E_T_ = ' ' " + ;
				" INNER JOIN " + RetSqlName( "AR1" ) + " AR1 " + ;
				" ON AR1.AR1_COD = AR2.AR2_COD " + ;
				" AND AR1.AR1_FILIAL = AR2.AR2_FILIAL " + ;
				" AND AR1.AR1_COD = '" + cCod + "' " + ;
				" AND AR1.AR1_FILIAL = '" + cFil + "' " + ;
				" AND AR1.D_E_L_E_T_ = ' ' " + ;
				" WHERE E2.D_E_L_E_T_ = ' ' "

			cQuery := ChangeQuery( cQuery )
			MPSysOpenQuery( cQuery, cTmp )

			While !( cTmp )->( Eof() ) .And. lRet
				aArray := { {"E2_PREFIXO" , ( cTmp )->E2_PREFIXO    , NIL },;
					{"E2_NUM"     , ( cTmp )->E2_NUM        , NIL },;
					{"E2_TIPO"     ,( cTmp )->E2_TIPO        , Nil },;
					{"E2_PARCELA"  ,( cTmp )->E2_PARCELA     , Nil }}

				MsExecAuto( { |x,y,z| FINA050(x,y,z)},aArray,,5)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão

				If lMsErroAuto
					lRet := .F.
				Endif

				aArray  := {}
				( cTmp ) ->( DbSkip())
			EndDo
			( cTmp )->( DBCloseArea() )
		EndIf

		If !lRet
			DisarmTransaction()
		EndIF
	END TRANSACTION

	RestArea( aSvAlias )

	FWFreeArray( aSvAlias )
	FWFreeArray( aArray)
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk020RBrw
Botão de atualização do browse para o usuário.

@author Squad NT TechFin
@since  17/09/2020
/*/
//-----------------------------------------------------------------------------
Function Rsk020RBrw()
	If oBrowse := Nil
		oBrowse:Refresh()
	EndIf
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MyRSKA020
Exemplo de rotina automatica NFS Mais Negócios.

@param  Nenhum
@return Nenhum
@author Squad NT TechFin
@since  06/10/2020
/*/
//-----------------------------------------------------------------------------
/*
User Function MyRSKA020()

    Local aArea     := {}
    Local aAreaSF4  := {}
    Local aAreaSM0  := {}
    Local aAreaAR1  := {}
    Local aAR1Auto  := {}
    Local lRet      := .T.
    Local cTicket   := "" //Guid da transacao do ticket.
    Local cSF2Key   := "" //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO                                                                                                  

    Private lMsErroAuto := .F.

    //RpcSetEnv("MyCompany","MyBranch")  

    RpcSetEnv("T1","M SP 01 ") 

    cTicket     := "" //Guid da transacao do ticket.
    cSF2Key     := xFilial("SF2") + PadR("850076",TamSX3("F2_DOC")[1]) + "DV"  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
    aArea       := GetArea()
    aAreaSF4    := SF4->(GetArea())
    aAreaSM0    := SM0->(GetArea()) 
    aAreaAR1    := AR1->(GetArea())  

    DBSelectArea("SF2")
    DBSetOrder(1)

    If DBSeek(cSF2Key)   

        DBSelectArea("SE4")
        DBSetOrder(1)

        If ( DBSeek(xFilial("SE4")+SF2->F2_COND) .And. SE4->E4_TPAY )
        
            aCliente := StrTokArr2( SuperGetMv('MV_RSKCPAY'), '|', )

            If !Empty(aCliente) 
                aAdd(aAR1Auto,{"AR1_FILNF"  ,SF2->F2_FILIAL                 ,Nil})  //Filial da NFS 
                aAdd(aAR1Auto,{"AR1_DOC"	,SF2->F2_DOC                    ,Nil})  //Numero da NFS
                aAdd(aAR1Auto,{"AR1_SERIE"	,SF2->F2_SERIE                  ,Nil})  //Serie NFS
                aAdd(aAR1Auto,{"AR1_PREFIX"	,SF2->F2_PREFIXO                ,Nil})  //Prefixo NFS
                aAdd(aAR1Auto,{"AR1_FILCLI"	,xFilial("SA1")                 ,Nil})  //Filial Cliente
                aAdd(aAR1Auto,{"AR1_CLIENT" ,SF2->F2_CLIENTE                ,Nil})  //Codigo do Cliente
                aAdd(aAR1Auto,{"AR1_LOJA"   ,SF2->F2_LOJA                   ,Nil})  //Loja do Cliente
                aAdd(aAR1Auto,{"AR1_FILPAR"	,xFilial("SA1")                 ,Nil})  //Filial do Parceiro (Cliente)
                aAdd(aAR1Auto,{"AR1_CLIPAR"	,aCliente[1]                    ,Nil})  //Codigo do Parceiro (Cliente)
                aAdd(aAR1Auto,{"AR1_LJPARC"	,aCliente[2]                    ,Nil})  //Loja do Parceiro (Cliente)
                aAdd(aAR1Auto,{"AR1_STATUS"	,"0"                            ,Nil})  //Status da NFS Mais Negocio //0=Aguardando Envio;1=Em Análise;2=Aprovada;3=Rejeitada;4=Cancelada;5=Inconsistente
                aAdd(aAR1Auto,{"AR1_NFEMIS"	,SF2->F2_EMISSAO                ,Nil})  //Emissao da NFS
                aAdd(aAR1Auto,{"AR1_FILORI"	,cFilAnt                        ,Nil})  //Filial de Origem
                aAdd(aAR1Auto,{"AR1_CGCCLI"	,SA1->A1_CGC                    ,Nil})  //CNPJ/CPF do Cliente
                aAdd(aAR1Auto,{"AR1_VLRNF"	,SF2->F2_VALBRUT                ,Nil})  //Valor Bruto da NFS
                aAdd(aAR1Auto,{"AR1_CONDPG"	,SF2->F2_COND                   ,Nil})  //Valor do Ticket
                aAdd(aAR1Auto,{"AR1_DTSOLI"	,FWTimeStamp(1, Date(), Time()) ,Nil})  //Data de solicitacao
                aAdd(aAR1Auto,{"AR1_STARSK"	,"1"                            ,Nil})  //Status Risk //1=Enviar;2=Enviado;3=Recebido;4=Confirmado;5=Cancelado

                SM0->(DBSetOrder(1))
                If SM0->(MSSeek(cEmpAnt+cFilAnt))
                    aAdd(aAR1Auto,{"AR1_CGCPAR",SM0->M0_CGC,Nil})  //CNPJ/CPF do parceiro.
                EndIf
          
                aAdd(aAR1Auto,{"AR1_TKTRSK", cTicket , Nil})  //Ticket de credito.
                
                //Inclusão da NFS Mais Negócio.
                MSExecAuto({|x,y| RSKA020(x,y)},3,aAR1Auto)
                
                If lMsErroAuto 
                    MostraErro()
                    lRet := .F.
                EndIf
            Else
                lRet := .F.
                Help("",1,"MyRSKA020",,"Cliente parceiro não encontrado...." , 1, 0,,,,,,{"Verifique o conteudo do parametro MV_RSKCPAY."}) 
            EndIf  

        EndIf

    EndIf

    RpcClearEnv()

    RestArea(aAreaAR1)  
    RestArea(aAreaSM0)   
    RestArea(aAreaSF4)   
    RestArea(aArea)
    FWFreeArray(aAreaAR1)
    FWFreeArray(aAreaSM0)
    FWFreeArray(aAreaSF4)
    FWFreeArray(aArea)

Return lRet*/

//-------------------------------------------------------------------
/*/{Protheus.doc} RSK20TIT
Função responsável por mostrar ao usuário os títulos financeiros gerados
pela NFS Mais Negócios.

@param cCod, caracter, Número do documento da nota fiscal
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, Vetor com os títulos financeiros
@author Rodrigo G. Soares
@since 09/12/2020
@version P12
/*/
//-------------------------------------------------------------------
Function RSK20TIT( cCod, lAutomato )
    Local aArea      := GetArea()
    Local aFields  := { "E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_EMISSAO", "E1_VENCTO", "E1_VALOR" }
    Local aTRB       := {}
    Local aHeadTrb   := {}
    Local aStruTrb   := {}
    Local aBill      := {}
    Local cAliasTRB  := ""
    Local oTempTable := NIL

    DEFAULT cCod := AR1->AR1_DOC
    Default lAutomato := .F.

    If !Empty( cCod ) 
        aTRB := RSKTRBFields( aFields )
        aHeadTrb := aTRB[ TRBHEADER ]       // [1]-Informações no modelo aHeader
        aStruTrb := aTRB[ TRBSTRUCT ]       // [2]-Informações no modelo Struct

        cAliasTRB := GetNextAlias()
        oTempTable := FWTemporaryTable():New( cAliasTRB )
        oTempTable:SetFields( aStruTRB )
        oTempTable:AddIndex( "indice1", { "E1_PREFIXO", "E1_NUM" } )
        oTempTable:Create()
        
        aBill := MakeTRBContent( cAliasTRB, AR1->AR1_DOC, AR1->AR1_SERIE, AR1->AR1_STATUS, AR1->AR1_CONDPG, lAutomato )

        If !( cAliasTRB )->( Eof() )
            If !lAutomato
                ShowTRBDialog( cAliasTRB, aHeadTRB, lAutomato )
            EndIf
        EndIf
        
        ( cAliasTRB )->( DBCloseArea() )
    EndIf
    RestArea( aArea )

    FWFreeArray( aArea )
    FWFreeArray( aFields )
    FWFreeArray( aHeadTrb )
    FWFreeArray( aStruTrb )
    FWFreeArray( aTRB )
    FreeObj( oTempTable )
RETURN aBill

//----------------------------------------------------------------------------------
/*/{Protheus.doc} MakeTRBContent
Função responsável por buscar os títulos atrelados a nota e alimentar a tabela
temporária.

@param cAliasTRB, caracter, Alias temporário
@param cDoc, caracter, número da NFS Mais Negócio
@param cSerie, caracter, série da NFS Mais Negócio
@param cStatus, caracter, status da nota
@param cCondPgto, caracter, condição de pagamento
@param lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@return array, vetor com os títulos financeiros que compõem a tabela temporária.
@author Marcia Junko
@since 24/02/2021
/*/
//----------------------------------------------------------------------------------
Static Function MakeTRBContent( cAliasTRB, cDoc, cSerie, cStatus, cCondPgto, lAutomato )
    Local aStru     := {}
    Local aItems    := {}
    Local aData     := {}
    Local cQuery    := ""
    Local cTmp      := GetNextAlias()
    Local nX        := 0
    Local lConsulta   := RskPedAdt(cCondPgto) .And. IsInCallStack("RSK20TIT")
    Local lFirstInstallment := .T.

    Default lAutomato := .F.

    aStru := ( cAliasTRB )->( DBStruct() )

    cQuery := " SELECT E1.E1_FILIAL, E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA, E1.E1_CLIENTE, " + ;
        " E1.E1_TIPO, E1.E1_EMISSAO, E1.E1_VENCTO, E1.E1_VALOR, E1.E1_SALDO " + ; 
        " FROM " + RetSqlName( "SE1" ) + " E1 " + ;
        " INNER JOIN " + RetSqlName( "AR1" ) + " AR1 " + ;
            " ON E1.E1_NUM = AR1.AR1_DOC " + ;
            " AND E1.E1_FILORIG = AR1.AR1_FILORI " + ;  
            " AND E1.E1_CLIENTE = AR1.AR1_CLIENT " + ;
            " AND E1.E1_SERIE = AR1.AR1_SERIE " + ;
            " AND E1.D_E_L_E_T_ = ' ' " + ;
        " WHERE AR1.AR1_FILIAL = '" + xFilial( "AR1" ) + "' " + ;
            " AND AR1.AR1_DOC = '"+ cDoc + "' " + ;
            " AND AR1.AR1_SERIE = '"+ cSerie + "' " + ;
            " AND AR1.AR1_STATUS = '"+ cStatus + "' " + ;
            " AND AR1.D_E_L_E_T_ = ' ' " + ;    
        " ORDER BY " + SqlOrder( SE1->( IndexKey(1) ) )

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmp )

    While !( cTmp )->( Eof() )
        aData := {}

        //----------------------------------------------------------------------------------
        //Na tela de consulta de parcelas enviadas despreza a primeira parcela compensada com o RA
        //----------------------------------------------------------------------------------
        If lConsulta .And. lFirstInstallment
            lFirstInstallment := .F.
            ( cTmp )->( dbSkip() )
            Loop
        EndIf

        RecLock( cAliasTRB, .T. )
            For nX := 1 To Len( aStru )
                (cAliasTRB)->( FieldPut( nX, ( cTmp )->( FieldGet( FieldPos( aStru[nX][1] ) ) ) ) )
                
                Aadd( aData, ( cTmp )->( FieldGet( FieldPos( aStru[nX][1] ) ) ) )
            Next nX
        MsUnlock()

        //----------------------------------------------------------------------------------
        // Adiciona os dados do título para retorno
        //----------------------------------------------------------------------------------
        Aadd( aItems, aClone( aData ) )

        ( cTmp )->( dbSkip() )  
    EndDo
    ( cTmp )->( DbCloseArea() )

    (cAliasTRB)->(DBGoTop())

    FWFreeArray( aStru )
    FWFreeArray( aData )
Return aItems

//----------------------------------------------------------------------------------
/*/{Protheus.doc} ShowTRBDialog
Função responsável por montar a tela de apresentação dos títulos.

@param cAliasTRB, caracter, Alias temporário
@param aHeadTRB, array, lista com os cabeçalhos dos campos da GetDB
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Marcia Junko
@since 24/02/2021
/*/
//----------------------------------------------------------------------------------
Static Function ShowTRBDialog( cAliasTRB, aHeadTrb, lAutomato )
    Local aSize := {}
    Local aObjects := {}
    Local aInfo := {}
    Local aPosObj := {}
    Local oDlg := NIL
    Local oGetDB := NIL

    PRIVATE aHeader := aHeadTRB

    aSize := MsAdvSize( .F. )
    
    //Calcula dimensoes da tela
    aSize[1] /= 1.8
    aSize[2] /= 1.8
    aSize[3] /= 1.8
    aSize[4] /= 1.5
    aSize[5] /= 1.8
    aSize[6] /= 1.5
    aSize[7] /= 1.8
    
    AAdd( aObjects, { 100, 020,.T.,.F.,.T.} )
    AAdd( aObjects, { 100, 060,.T.,.T.} )
    AAdd( aObjects, { 100, 020,.T.,.F.} )
    aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
    aPosObj := MsObjSize( aInfo, aObjects, .T.)
    
    DEFINE MSDIALOG oDlg TITLE STR0036 FROM aSize[7], 000 TO aSize[6], aSize[5] OF oMainWnd PIXEL //"Títulos enviados a Supplier"

    oGetDb := MsGetDB():New( aPosObj[2, 1], aPosObj[2, 2], aPosObj[2, 3], aPosObj[2, 4], 1, "Allwaystrue", "allwaystrue", "", .F., , ,.F., , cAliasTRB )
    
    DEFINE SBUTTON FROM aPosObj[3, 1]+000, aPosObj[3, 4]-030 TYPE 1 ACTION ( oDlg:End() ) ENABLE OF oDlg
    
    ACTIVATE MSDIALOG oDlg CENTERED

    FWFreeArray( aSize )
    FWFreeArray( aObjects )
    FWFreeArray( aInfo )
    FWFreeArray( aPosObj )
    FreeObj( oDlg )
    FreeObj( oGetDB )
Return NIL

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} RskReANF
Função para reanalizar o NF junto a Supplier.

@param  cAlias, caracter, nome da tabela atrelado ao browse
@param  nReg, number, RECNO do registro
@param  nOpc, number, opção do aRotina que está semdo executada
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Rodrigo G. Soares
@since 21/01/2021
/*/
//-------------------------------------------------------------------
Function RskReANF( cAlias, nReg, nOpc, lAutomato )
    Local oModel    := FwLoadModel( "RSKA020" )
    Local aError    := {}
    Local oMdlAR1   := Nil

    Default lAutomato := .F.

    //------------------------------------------------------------------------------
    // Pede reanálise somente para notas rejeitadas ou inconsistentes
    //------------------------------------------------------------------------------
    If AR1->AR1_STATUS == AR1_STT_REJECTED .or. AR1->AR1_STATUS == AR1_STT_FLIMSY   // 3=Rejeitada ### 5=Inconsistente
        BEGIN TRANSACTION 
            oModel:SetOperation( MODEL_OPERATION_UPDATE )
            oModel:Activate()
            If oModel:IsActive()
                oMdlAR1 := oModel:GetModel( "AR1MASTER" )
                oMdlAR1:SetValue( "AR1_RCOUNT", 0 )                                                    
                oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_AWAIT )     // 0=Aguardando Envio
                oMdlAR1:SetValue( "AR1_STARSK", STARSK_SUBMIT )     // 1=Enviar
                oMdlAR1:SetValue( "AR1_OBSPAR", " " )
                oMdlAR1:SetValue( "AR1_DTSOLI", FWTimeStamp( 1, Date(), Time() ) )
                oMdlAR1:SetValue( "AR1_DTAVAL", " ")
                If oModel:VldData() 
                    oModel:CommitData()
                    RSKConfirm( AR1->AR1_CMDINV, UPDARINVOICE, lAutomato )      // 3=Atualiza fatura   
                Else
                    aError := oModel:GetErrorMessage()
                    Help( "", 1, "RSK020ReaNF", , aError[6], 1 )
                EndIf
            Else
                aError := oModel:GetErrorMessage()
                Help( "", 1, "RSK020ReaNF", , aError[6], 1 )
            EndIf
            oModel:DeActivate()
            oModel:Destroy()
        END TRANSACTION
    Else
        Help( "", 1, "RSK020ReaNF", , STR0038, 1, 0,,,,,, { STR0039 } )  //"Não será possível solicitar uma reanálise para esta Nota Fiscal."###"Somente Notas Fiscais com status reprovado e inconsistente poderão ser reavaliados pela plataforma Risk."
    EndIf     

    FWFreeArray( aError )
    FreeObj( oModel )
    FreeObj( oMdlAR1 )   
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} Rsk020Cancel
Funcao que envia o pedido de cancelamento das NFS Mais Negócios diretamente para a
plataforma risk.

@param  cAlias, caracter, nome da tabela atrelado ao browse
@param  nReg, number, RECNO do registro
@param  nOpc, number, opção do aRotina que está semdo executada
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Marcia Junko
@since 23/02/2021
/*/
//----------------------------------------------------------------------------------
Function RSK020Cancel( cAlias, nReg, nOpc, lAutomato )
    Local aArea             := GetArea()
    Local aAreaAR1          := AR1->( GetArea() )
    Local aAreaSF2          := SF2->( GetArea() )
    Local lApproved         := AR1->AR1_STATUS == AR1_STT_APPROVED      // 2=Aprovada
    Local lErrorCancErp     := AR1->AR1_STATUS == AR1_STT_ERRORCANCERP  // 9=Erro no Cancelamento ERP
    Local lRejected         := AR1->AR1_STATUS == AR1_STT_REJECTED      // 3=Rejeitada
    Local lFlimsy           := AR1->AR1_STATUS == AR1_STT_FLIMSY        // 5=Inconsistente
    Local lDenied           := AR1->AR1_STATUS == AR1_STT_DENIED        // B=Negada
    Local lAguarda          := AR1->AR1_STATUS == AR1_STT_AWAIT         // 0=Aguardando Envio
    Default lAutomato := .F.

    //------------------------------------------------------------------------------------------------------------------
    // Foi removido o trecho do tratamento de data/hora para o cancelamento pois será feito pelo cancelamento  
    // da NF (MATA520), de acordo com o parâmetro MV_CANCNFE
    //------------------------------------------------------------------------------------------------------------------
        IF lApproved .Or. lRejected .Or. lFlimsy .Or. lErrorCancErp .Or. lDenied .Or. lAguarda
            SF2->( DBSetOrder(1) )  //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

            IF ( SF2->( MSSeek( AR1->AR1_FILNF + AR1->AR1_DOC + AR1->AR1_SERIE + AR1->AR1_CLIENT + AR1->AR1_LOJA ) ) )  
                IF lAutomato .Or. MsgYesNo(STR0053,STR0054) //'Deseja realizar o processo de cancelamento da NF Mais Negócio? Este processo pode acarretar taxas conforme o contrato.'#'Cancelamento da NF Mais Negócio'
                    //------------------------------------------------------------------------------------------------------------------
                    //Estorna baixas, cancela NF, envia solicitação de cancelamento para a Sefaz e Supplier
                    //------------------------------------------------------------------------------------------------------------------
                    RskEstFat( lAutomato )

                    //------------------------------------------------------------------------------------------------------------------
                    // Foi removido o trecho do tratamento de data/hora para o cancelamento pois será feito pelo cancelamento  
                    // da NF (MATA520), de acordo com o parâmetro MV_CANCNFE
                    //------------------------------------------------------------------------------------------------------------------

                    //------------------------------------------------------------------------------------------------------------------
                    // O trecho que faz o envio da solicitação de cancelamento para a Supplier foi movido para a funçao RskCancSup
                    // devido a alteração do fluxo, no qual a comunicação com a Supplier é feita somente após a exclusão da NF na Sefaz
                    //------------------------------------------------------------------------------------------------------------------
                Else
                    If lDenied
                        MsgAlert( STR0074 ) //"Nota Fiscal denegada já foi excluída do Faturamento"
                    EndIf
                EndIf
            Else
                MsgAlert( STR0047 ) //"Nota Fiscal não localizada."
            EndIf
        Else
            MsgAlert( STR0048 ) //"O status desta NFS Mais Negócio não permite a ação de cancelamento."
        EndIf

    RestArea( aArea ) 
    RestArea( aAreaSF2 ) 
    RestArea( aAreaAR1 ) 
    
    FWFreeArray( aArea ) 
    FWFreeArray( aAreaAR1 ) 
    FWFreeArray( aAreaSF2 ) 
Return NIL

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RSKConfCanc
Funcao que efetiva o cancelamento das NFS Mais Negócios com base na resposta do 
callback da Supplier.

@param aRecords , array, lista com as NFS Mais Negócios canceladas
    [1] - Chave da empresa/filial
    [2] - Código da NF Mais Neg.
    [3] - Guide do Cancelamento
    [4] - Status do cancelamento (2=aprovado;3=reprovado)
    [5] - Observação
    [6] - Valor da Taxa
    [7] - Saldo do ticket
    [8] - Número da Parcela
    [9] - Data de Pagamento da taxa.
    [10] - Valor do Devolvido por parcela.
    [11] - Valor da parcela.
    [12] - Estorno da taxa.
@obs A estrutura do array aRecords é baseada na função GetRSKItems - Tipo 7 ( Cancelamento de NFS Mais Negócios )
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Rodrigo Soares
@since 05/03/2021
/*/
//----------------------------------------------------------------------------------
Function RSKConfCanc(aRecords, lAutomato )
    Local aArea             := GetArea()
    Local aAreaAR1          := AR1->( GetArea() )
    Local aItem             := {}
    Local aSupplier         := {}
    Local aNFSGroup         := {}
    Local aFee              := {}
    Local aItens            := {}
    Local aConfirmNF        := {}
    Local aInstallments     := RskInstallments(100)
    Local cNumSE2           := ""  
    Local cHist             := ""
    Local cKey              := ""  
    Local cInstallment      := ""
    Local cTitIdOri         := ""
    Local oModel            := FWLoadModel( "RSKA020" )  
    Local oMdlAR1           := Nil
    Local oMdlAR2           := Nil
    Local cFilSE2 		    := xFilial( "SE2" )
    Local cIdNatExp		    := RskSeekNature( EXPENSE_NATURE )
    Local dDebitDate	    := cTod("//")
    Local aAreaSF2          := SF2->( GetArea() )
    Local aAreaSC9          := SC9->( GetArea() )
    Local nPosFind          := 0
    Local nRecord           := 0
    Local nConfirm          := 0
    Local nLenItens         := 0
    Local nGroup            := 0
    Local nItem             := 0
    Local nAmount           := 0
    Local nFee              := 0
    Local nFeeAmtOri        := 0    
    Local lRet              := .T.

    Default lAutomato := .F.

    AR1->( DBSetOrder(1) )   //AR1_FILIAL+AR1_COD

    //------------------------------------------------------------------------------
    // Ordena as notas por parcela
    //------------------------------------------------------------------------------
    aSort(aRecords,,,{ |x, y| ( x[1] + x[2] + x[8]  < y[1] + y[2] + y[8]  ) } )   

    For nRecord := 1 To Len(aRecords)
        cKey        := aRecords[nRecord][ CANCEL_COMPANY ] + aRecords[nRecord][ CANCEL_CODE ]   // [1]-Chave da empresa/filial ### [2]-Código da NF Mais Neg
        nPosFind    := aScan(aNFSGroup, {|x| x[1] == cKey })  
        If nPosFind == 0  
            aAdd(aNFSGroup,{cKey, {aRecords[nRecord]} })
        Else
            aAdd(aNFSGroup[nPosFind][2],aRecords[nRecord])
        EndIf  
    Next        

    For nGroup := 1 To Len(aNFSGroup)
        If AR1->(DBSeek( aNFSGroup[nGroup][1] )) .And. AR1->AR1_STATUS == AR1_STT_CANCELINGSUP  // 8=Em cancelamento Supplier
            aItens      := aNFSGroup[nGroup][2]
            nLenItens   := Len(aItens)
            cNumSE2     := ProxTitulo( "SE2", "CAN" )
            aSupplier   := RskGetSupplier(AR1->AR1_CLIPAR, AR1->AR1_LJPARC)
            lRet        := .T.    
            aConfirmNF  := {} 

            BEGIN TRANSACTION  

                cAliasTRB   := GetNextAlias()
                For nItem := 1 To nLenItens
                    aItem       := aItens[nItem]  

                    If aItem[4] == "2"     
                        //-------------------------------------------------------------------------
                        // Trecho de estorno das baixas e exclusão da NF movido para a função
                        // RskEstFat devido à alteração de fluxo
                        //-------------------------------------------------------------------------
                        
                        If nItem == 1                            
                            If oModel:IsActive()
                                oModel:DeActivate()
                            EndIf

                            oModel:SetOperation( MODEL_OPERATION_UPDATE )
                            oModel:Activate()
                            lRet := oModel:IsActive()
                        EndIf 

                        If lRet
                            If !Empty(aSupplier)   
                                oMdlAR2         := oModel:GetModel("AR2DETAIL")
                                cInstallment    := aInstallments[aScan(aInstallments, {|x| x[1] == aItem[8]})][2]
                                cHist           := STR0057 + AllTrim(AR1->AR1_DOC) + " / " + AllTrim(AR1->AR1_SERIE) + IIF(!Empty(cInstallment), STR0058 + AllTrim(cInstallment),"") // "NF Mais Neg.: "#" Parc.: "
                                cTitIdOri       := (AllTrim(AR1->AR1_FILNF) + '|' + AllTrim(AR1->AR1_PREFIX) + '|' + AllTrim(AR1->AR1_DOC) + '|' + cInstallment + '|' + AllTrim(MVNOTAFIS))                                    
                                nFee            := Val(aItem[ CANCEL_FEEVALUE ])    // [6]-Valor da Taxa 
                                nAmount         := Val(aItem[ CANCEL_INSTVALUE ])       // [11]-Valor da parcela  
                                nFeeAmtOri      := Abs(Val(aItem[ CANCEL_REVERSAL ]))   // [12]-Estorno da taxa
                                dDebitDate      := cTod(SubStr(aItem[ CANCEL_PAYDATE ], 9,2) +'/'+ SubStr(aItem[ CANCEL_PAYDATE ], 6,2) +'/'+ SubStr(aItem[ CANCEL_PAYDATE ], 1,4)) // [9]-Data de Pagamento da taxa.                                
                                
                                aFee := RSKTaxa(cFilSE2, "CAN", cNumSE2, cInstallment, "DP", nAmount, dDebitDate, cHist, cIdNatExp)  

                                //------------------------------------------------------------------------------
                                // Gera duplicata com valor da parcela.
                                //------------------------------------------------------------------------------
                                If Len(aFee) > 0
                                    If !oMdlAR2:SeekLine({{"AR2_MOV", "A" },{"AR2_PREFIX", "CAN" }, {"AR2_TIPO", "DP" }, {"AR2_TITORI", cTitIdOri}})     
                                        lRet := RskAddAR2(oMdlAR2, "A", cFilSE2, "CAN", cNumSE2, cInstallment, "DP", , ,;
                                                            nAmount, dDebitDate, cTitIdOri , , , , ,aSupplier[1], aSupplier[2])
                                    EndIf
                                Else  
                                    lRet := .F.      
                                EndIf

                                //------------------------------------------------------------------------------
                                // Gera abatimento para parcela.
                                //------------------------------------------------------------------------------
                                If lRet     
                                    aFee := RSKTaxa(cFilSE2, "CAN", cNumSE2, cInstallment, "MN-", nFeeAmtOri, dDebitDate, cHist, cIdNatExp)

                                    If Len(aFee) > 0
                                        If !oMdlAR2:SeekLine({{"AR2_MOV", "A"},{"AR2_PREFIX", "CAN"}, {"AR2_TIPO", "MN-"}, {"AR2_TITORI", cTitIdOri}})    
                                            lRet := RskAddAR2(oMdlAR2, "A", cFilSE2, "CAN", cNumSE2, cInstallment, "MN-", , ,;
                                                                nFeeAmtOri, dDebitDate, cTitIdOri , , , , ,aSupplier[1], aSupplier[2])   
                                        EndIf
                                    Else
                                        lRet := .F.       
                                    EndIf
                                EndIf
                                
                                If nFee > 0  
                                    //------------------------------------------------------------------------------
                                    // Gera taxa de cancelamento.
                                    //------------------------------------------------------------------------------
                                    If lRet
                                        aFee := RSKTaxa(cFilSE2, "CAN", cNumSE2, cInstallment, "MN+", nFee, dDebitDate, cHist, cIdNatExp)   

                                        If Len(aFee) > 0                 
                                            If !oMdlAR2:SeekLine({{"AR2_MOV", "A"}, {"AR2_PREFIX", "CAN"}, {"AR2_TIPO", "MN+"}, {"AR2_TITORI", cTitIdOri}}) 
                                                lRet := RskAddAR2(oMdlAR2, "A", cFilSE2, "CAN", cNumSE2, cInstallment, "MN+", , ,;
                                                                    nFee, dDebitDate, cTitIdOri , , , , ,aSupplier[1], aSupplier[2])   
                                            EndIf  
                                        Else      
                                            lRet := .F.     
                                        EndIf
                                    EndIf  
                                EndIf
                            Else
                                oModel:GetModel():SetErrorMessage(,, oModel:GetId(),, "RSK020FOR",STR0049,STR0050) //"Código / Loja do fornecedor não encontrado..." - "Verifique no cadastro de  Fornecedor se os campos Cód. Cliente / Loja Cliente está associado ao cliente Supplier."
                                lRet := .F.  
                            EndIf   
                        EndIf 

                        If lRet
                            aAdd(aConfirmNF, aItem[ CANCEL_GUIDE ])     // [3]-Guide do Cancelamento
                        Else
                            Exit   
                        EndIf  
                        
                        If nLenItens == nItem .And. lRet  
                            oMdlAR1 := oModel:GetModel( "AR1MASTER" )
                            
                            SF2->(DBSetOrder(1))
                            If SF2->(MsSeek( AR1->AR1_FILNF + AR1->AR1_DOC + AR1->AR1_SERIE + AR1->AR1_CLIENT + AR1->AR1_LOJA ))                                
                                RskEstFat( lAutomato, .T. )
                                RskNFSDelete( SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_FORMUL+SF2->F2_TIPO, .T. )
                                
                                SC9->( DBSetOrder(6) ) //C9_FILIAL+C9_SERIENF+C9_NFISCAL+C9_CARGA+C9_SEQCAR
                                If SC9->( MsSeek( xFilial( "SC9" ) + SF2->F2_SERIE + SF2->F2_DOC) )
                                    While SC9->(!Eof()) .And. xFilial( "SC9" ) == SC9->C9_FILIAL .And. SC9->C9_SERIENF+SC9->C9_NFISCAL == SF2->F2_SERIE+SF2->F2_DOC
                                        RecLock("SC9",.F.)
                                            SC9->C9_TICKETC := " "                            
                                        SC9->(MsUnLock())
                                        SC9->(DbSkip())
                                    EndDo
                                Endif 
                                oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_CANSUPOK ) // C = NF Cancelada na Supplier
                            Else                   
                                oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_CANCELED )  // 4=Cancelada
                                oMdlAR1:SetValue( "AR1_OBSPAR", AR1->AR1_OBSPAR + CRLF + STR0042) //'Nota Fiscal Mais Negocio Cancelada por exclusão da NF de origem.'
                            EndIf

                            If lRet .And. oModel:VldData()
                                oModel:CommitData()
                            EndIf
                            oModel:DeActivate()
                        EndIf
                    Else  
                        If nItem == 1 
                            oModel:SetOperation( MODEL_OPERATION_UPDATE )
                            oModel:Activate()
                            If oModel:IsActive()
                                oMdlAR1 := oModel:GetModel( "AR1MASTER" )
                                oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_CANCREPROSUP)   // A=Cancelamento Reprovado Supplier
                                oMdlAR1:SetValue( "AR1_OBSPAR", AR1->AR1_OBSPAR + CRLF + STR0043 + aItem[5]) //'Cancelamento Negado: '
                                If oModel:VldData()  
                                    oModel:CommitData()
                                EndIf
                            EndIf  
                            oModel:DeActivate()
                        EndIf
                        aAdd(aConfirmNF, aItem[ CANCEL_GUIDE ])     // [3]-Guide do Cancelamento  
                    EndIf

                    If !lRet
                        DisarmTransaction()  
                        aConfirmNF := {}
                    EndIf
                Next

                For nConfirm := 1 To Len(aConfirmNF)
                    lRet := RSKConfirm( aConfirmNF[nConfirm], NFSCANCEL )
                    If !lRet
                        DisarmTransaction()
                        Exit
                    EndIf  
                Next   

            END TRANSACTION
        EndIf
    Next  

    RestArea(aArea)
    RestArea( aAreaAR1 )
    RestArea( aAreaSF2 ) 
    RestArea( aAreaSC9 )  
  
    FWFreeArray(aArea)
    FWFreeArray(aAreaAR1)
    FWFreeArray( aAreaSC9 )
    FWFreeArray( aAreaSF2 ) 
    FWFreeArray(aItem)
    FWFreeArray(aInstallments)
    FWFreeArray(aSupplier)
    FWFreeArray(aNFSGroup)
    FWFreeArray(aFee)
    FWFreeArray(aItens)
    FWFreeArray(aConfirmNF)
    FreeObj( oModel )
    FreeObj( oMdlAR1 )
    FreeObj( oMdlAR2 )
Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} SeekRelease
Função responsável por verificar se ainda existem item a faturar de determinado pedido.

@param cTktRisk, caracter, Número do ticket para pesquisa

@author Marcia Junko
@since 15/03/2021
/*/
//----------------------------------------------------------------------------------
Static Function SeekRelease( cTktRisk )
    Local aSvAlias := GetArea()
    Local cQuery := ""
    Local cTmp := GetNextAlias()
    Local lTotal := .F.

    cQuery := "SELECT C9_QTDLIB FROM " + RetSQLName("AR0") + " AR0 " + ;
        "INNER JOIN " + RetSQLName("SC9") + " SC9 " + ;
            "ON C9_FILIAL = AR0_FILPED " + ;
            "AND C9_TICKETC = AR0_TICKET " + ;
            "AND C9_NFISCAL = ' ' " + ;
            "AND C9_SERIENF = ' ' " + ;
            "AND SC9.D_E_L_E_T_= ' ' " + ;
        "WHERE AR0_FILIAL = '" + xFilial("AR0") + "' " + ;
            "AND AR0_TKTRSK = '" + cTktRisk + "' " + ;
            "AND AR0.D_E_L_E_T_= ' ' "

    cQuery := ChangeQuery( cQuery )
    MPSysOpenQuery( cQuery, cTmp )

    If ( cTmp )->( Eof() )
        lTotal := .T.
    EndIf 

    ( cTmp )->( DBCloseArea() )

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
Return lTotal

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RskEstComiss
Função responsável por realizar o estorno de todas as comissões da nota fiscal
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author     Claudio Yoshio Muramatsu
@since      16/07/2021
@version    P12.1.27
@return     logical, retorna se houve problema ao estornar algum registro de comissão
/*/
//----------------------------------------------------------------------------------
Static Function RskEstComiss( lAutomato As Logical )
    Local aArea       As Array
    Local aAreaSE1    As Array
    Local aAreaSE3    As Array
    Local aAutoSE3    As Array
    Local cAliasTmp   As Character
    Local cCliente	  As Character
    Local cLoja 	  As Character
    Local cPrefDef    As Character
    Local cQuery      As Character
    Local cTipDef     As Character
    Local cVendedor   As Character
    Local lRet        As Logical
    Local nCntVen     As Numeric
    Local nQtdVend    As Numeric
    Local cNumVend	  As Character

    Default lAutomato := .F.

    Private lMsErroAuto As Logical
    
    aArea       := GetArea()
    aAreaSE1    := SE1->(GetArea())
    aAreaSE3    := SE3->(GetArea())
    aAutoSE3    := {}
    cAliasTmp   := GetNextAlias()
    cCliente    := SuperGetMV( "MV_RSKCPAY", .T., "" )
    cLoja       := ""
    cPrefDef    := "OFF"
    cQuery      := ""
    cTipDef     := "DP"
    lRet        := .T.
    nCntVen     := 0
    nQtdVend    := fa440CntVen()
    lMsErroAuto := .F.
    
    cLoja     := SubStr( cCliente, TamSX3( 'A1_COD' )[1] + 2, TamSX3( 'A1_LOJA' )[1] )
    cCliente  := SubStr( cCliente, 1, TamSX3( 'A1_COD' )[1] )

    //------------------------------------------------------------------------------
    // Busca os dados do título Supplier
    //------------------------------------------------------------------------------
    cQuery := " SELECT AR2_FILTIT, AR2_PREFIX, AR2_NUMTIT, AR2_PARC, AR2_TIPO, AR2_CLIENT, AR2_LOJA "
    cQuery += " FROM " + RetSqlName("AR2")
    cQuery += " WHERE D_E_L_E_T_ = ' ' "
    cQuery += "    AND AR2_FILIAL = '" + xFilial("AR2") + "' "
    cQuery += "    AND AR2_COD = '" + AR1->AR1_COD + "' "
    cQuery += "    AND AR2_PREFIX = '" + cPrefDef + "' "
    cQuery += "    AND AR2_TIPO = '" + cTipDef + "' "
    cQuery += "    AND AR2_CLIENT = '" + cCliente + "' "
    cQuery += "    AND AR2_LOJA = '" + cLoja + "' "

    cQuery := ChangeQuery(cQuery)
    MPSysOpenQuery(cQuery,cAliasTmp)

    (cAliasTmp)->(DbGoTop())
    If (cAliasTmp)->(!Eof())

        DbSelectArea("SE1")
        SE1->(DbSetOrder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
        If SE1->(DbSeek((cAliasTmp)->AR2_FILTIT + (cAliasTmp)->AR2_PREFIX + (cAliasTmp)->AR2_NUMTIT + (cAliasTmp)->AR2_PARC + (cAliasTmp)->AR2_TIPO))
            For nCntVen := 1 To nQtdVend

                If nCntVen > 9 
					cNumVend := RetAsc( nCntVen, 1, .T. )
				Else
					cNumVend := cValToChar(nCntVen)
				EndIf

                cVendedor := SE1->(FieldGet(FieldPos("E1_VEND"+ cNumVend)))
                If !Empty(cVendedor)

                    DbSelectArea("SE3")
                    SE3->(DbSetOrder(3)) //E3_FILIAL+E3_VEND+E3_CODCLI+E3_LOJA+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_TIPO+E3_SEQ
                    If SE3->(DbSeek(xFilial("SE3") + cVendedor + (cAliasTmp)->AR2_CLIENT + (cAliasTmp)->AR2_LOJA + (cAliasTmp)->AR2_PREFIX + (cAliasTmp)->AR2_NUMTIT + (cAliasTmp)->AR2_PARC + (cAliasTmp)->AR2_TIPO))                     
                        If AllTrim(SE3->E3_BAIEMI) == "B"                          
                            If Empty(SE3->E3_DATA)
                                aAutoSE3 := {}
                                aAdd(aAutoSE3,{"E3_VEND"    ,SE3->E3_VEND       ,Nil})
                                aAdd(aAutoSE3,{"E3_CODCLI"  ,SE3->E3_CODCLI     ,Nil})
                                aAdd(aAutoSE3,{"E3_LOJA"    ,SE3->E3_LOJA       ,Nil})
                                aAdd(aAutoSE3,{"E3_PREFIXO" ,SE3->E3_PREFIXO    ,Nil})
                                aAdd(aAutoSE3,{"E3_NUM"     ,SE3->E3_NUM        ,Nil})
                                aAdd(aAutoSE3,{"E3_PARCELA" ,SE3->E3_PARCELA    ,Nil})
                                aAdd(aAutoSE3,{"E3_TIPO"    ,SE3->E3_TIPO       ,Nil})
                                aAdd(aAutoSE3,{"E3_SEQ"     ,SE3->E3_SEQ        ,Nil})

                                lMsErroAuto := .F.
                                MSExecAuto({|x,y| Mata490(x,y)},aAutoSE3,5)

                                If lMsErroAuto
                                    lRet := .F.
                                Endif                               
                            Else                                                   
                                lRet := .F.
                            EndIf                       
                        EndIf
                    EndIf
                EndIf
            Next nCntFor
        EndIf
    EndIf

    If Select(cAliasTmp) > 0
        (cAliasTmp)->(DbCloseArea())
    Endif

    SE1->(RestArea(aAreaSE1))
    SE3->(RestArea(aAreaSE3))
    RestArea(aArea)

    FWFreeArray(aAreaSE1)
    FWFreeArray(aAreaSE3)
    FWFreeArray(aAutoSE3)
    FWFreeArray(aArea)
Return lRet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} RskEstFat
Função responsável por estornar baixas e excluir a nota fiscal
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
@param  lSupplier, boolean, Indica que a origem da chamada será Cancelamento Supplier

@author Claudio Yoshio Muramatsu
@since 13/09/2021
/*/
//----------------------------------------------------------------------------------
Function RskEstFat( lAutomato As Logical, lSupplier As Logical  )
    Local aArea             As Array
    Local aAreaSE1          As Array
    Local aAreaSF2          As Array
    Local aBaixa            As Array
    Local aErroAuto         As Array
    Local aFields           As Array
    Local aNFSDel           As Array
    Local aRskMonTss        As Array
    Local aStruTRB          As Array
    Local aTRB              As Array
    Local cAliasTRB         As Character
    Local cLogMsg           As Character
    Local cStatusAR1        As Character
    Local cEspecie          As Character
    Local lCancSefaz        As Logical
    Local lFirstInstallment As Logical
    Local lNFeCancel        As Logical
    Local lRejected         As Logical
    Local lAguarda          As Logical
    Local lDenied           As Logical
    Local lRet              As Logical
    Local lRskPedAdt        As Logical
    Local lSefazAut         As Logical
    Local lSefazNeg         As Logical
    Local lSefazPen         As Logical
    Local oModel            As Object
    Local oModelAR1         As Object
    Local oTempTable        As Object  

    Default lAutomato := .F.
    Default lSupplier := .F.

    Private lAutoErrNoFile As Logical
    Private lMsHelpAuto    As Logical
    Private lMsErroAuto	   As Logical

    aArea             := GetArea()
    aAreaSE1          := SE1->(GetArea())
    aAreaSF2          := SF2->(GetArea())
    aBaixa            := {}
    aErroAuto         := {}
    aFields           := { "E1_FILIAL", "E1_PREFIXO", "E1_NUM", "E1_PARCELA", "E1_TIPO", "E1_CLIENTE", "E1_EMISSAO", "E1_VENCTO", "E1_VALOR", "E1_SALDO" }
    aNFSDel           := {}
    aRskMonTss        := {}
    aStruTRB          := {}
    aTRB              := {}
    cAliasTRB         := ""
    cLogMsg           := ""
    cStatusAR1        := AR1->AR1_STATUS
    cEspecie          := AllTrim(Posicione('SF2', 1, xFilial("SF2") + AR1->AR1_DOC + AR1->AR1_SERIE + AR1->AR1_CLIENT + AR1->AR1_LOJA, 'F2_ESPECIE'))
    lCancSefaz        := .T.
    lFirstInstallment := .T.
    lNFeCancel        := SuperGetMV('MV_CANCNFE',.F.,.F.)
    lRejected         := AR1->AR1_STATUS == AR1_STT_REJECTED
    lDenied           := AR1->AR1_STATUS == AR1_STT_DENIED
    lAguarda          := AR1->AR1_STATUS == AR1_STT_AWAIT
    lRet              := .T.
    lRskPedAdt        := RskPedAdt( AR1->AR1_CONDPG )
    lSefazAut         := .F.
    lSefazNeg         := .F.
    lSefazPen         := .F.
    oModel            := FWLoadModel( "RSKA020" )
    oModelAR1         := Nil
    oTempTable        := Nil

    lAutoErrNoFile    := .T.
    lMsHelpAuto       := .T.
    lMsErroAuto       := .F.
    
    aTRB        := RSKTRBFields( aFields )
    aStruTrb    := aTRB[2]

    cAliasTRB   := GetNextAlias()
    oTempTable  := FWTemporaryTable():New( cAliasTRB )
    oTempTable:SetFields( aStruTRB )
    oTempTable:AddIndex( "indice1", { "E1_PREFIXO", "E1_NUM" } )
    oTempTable:Create()
    
    MakeTRBContent( cAliasTRB, AR1->AR1_DOC, AR1->AR1_SERIE, AR1->AR1_STATUS, AR1->AR1_CONDPG )

    BEGIN TRANSACTION

        While !( cAliasTRB )->( Eof() )  
            //------------------------------------------------------------------------------
            // Pedidos com adiantamento faz o tratamento diferenciado da primeira parcela pois a baixa é por compensação
            //------------------------------------------------------------------------------
            If lFirstInstallment .And. lRskPedAdt
                lFirstInstallment := .F.
                ( cAliasTRB )->( DbSkip() )
                Loop
            EndIf

            If ( cAliasTRB )->E1_SALDO == 0
                aBaixa := {{"E1_PREFIXO" ,( cAliasTRB )->E1_PREFIXO   ,Nil    },;
                            {"E1_NUM"    ,( cAliasTRB )->E1_NUM       ,Nil    },;
                            {"E1_TIPO"   ,( cAliasTRB )->E1_TIPO      ,Nil    },;
                            {"E1_PARCELA",( cAliasTRB )->E1_PARCELA   ,Nil    }}
                
                MSExecAuto({|x,y| Fina070(x,y)},aBaixa,5) //Exclusão da baixa.

                If lMsErroAuto
                    lRet      := .F.
                    If Empty(cLogMsg)
                        cLogMsg := CRLF + STR0066 //"Não foi possível estornar as baixas dos títulos da nota fiscal. Por favor verificar."
                    EndIf

                    aErroAuto := GetAutoGRLog()
                    If Len(aErroAuto) > 0
                        cLogMsg += CRLF
                        aEval( aErroAuto, {|x| cLogMsg += x } )
                    EndIf                    
                EndIF              
            EndIf

            (cAliasTRB)->( DBSkip() ) 
        EndDo

        oTempTable:Delete()
        
        If !lSupplier
            If lRet  
                aNFSDel := {{"F2_DOC"      , AR1->AR1_DOC   ,Nil},; //numero da nota
                            {"F2_SERIE"    , AR1->AR1_SERIE ,Nil} }  //serie
                    
                MSExecAuto({|x| MATA520(x)},aNFSDel)  

                If lMsErroAuto            
                    lRet      := .F.
                    //------------------------------------------------------------------------------
                    // Já houve uma tentativa de cancelamento
                    //------------------------------------------------------------------------------
                    cLogMsg += CRLF + STR0068 //"Não foi possível excluir a nota fiscal. Verifique o erro e tente excluir novamente."

                    aErroAuto := GetAutoGRLog()
                    If Len(aErroAuto) > 0
                        cLogMsg += CRLF + Replicate("-",20) + CRLF
                        aEval( aErroAuto, {|x| cLogMsg += x } )
                        cLogMsg += CRLF + Replicate("-",20)
                    EndIf
                EndIf  

                SF2->(DBSetOrder(1))
                //------------------------------------------------------------------------------
                // Valida se NFS foi excluida. 
                //------------------------------------------------------------------------------
                If SF2->(DBSeek(xFilial("SF2") + AR1->AR1_DOC + AR1->AR1_SERIE + AR1->AR1_CLIENT + AR1->AR1_LOJA))                    
                    If lRet
                        cLogMsg += CRLF + STR0068 //"Não foi possível excluir a nota fiscal. Verifique o erro e tente excluir novamente."
                    EndIf
                    
                    lRet       := .F.
                    lCancSefaz := lNFeCancel .And. !Empty(SF2->F2_STATUS)
                EndIf

                If lNFeCancel .And. cEspecie == "SPED" .And. !lDenied

                    If .Not. lAutomato
                        aRskMonTss := RskMonTSS( {AR1->AR1_SERIE , AR1->AR1_DOC , AR1->AR1_DOC} )
                    Else
                        aRskMonTss := RskADVPRData( "RSKA020", "RskMonTSS", {AR1->AR1_SERIE , AR1->AR1_DOC , AR1->AR1_DOC} )
                    EndIf
                    
                    lSefazAut := aRskMonTss[1] == "1"       // 1=Autorizado
                    lSefazNeg := aRskMonTss[1] == "2"       // 2=Negado
                    lSefazPen := aRskMonTss[1] == "3" .Or. Empty(aRskMonTss[1])     // 3=Pendente
                    
                    If lSefazAut .And. lRet
                        cLogMsg    += CRLF + aRskMonTss[2]
                    ElseIf lSefazAut .And. !lRet
                        lRet       := .F.
                        cStatusAR1 := AR1_STT_ERRORCANCERP
                        cLogMsg    += CRLF + STR0072 //"Cancelamento da Nota Fiscal aprovado na Sefaz, porém com erro no ERP. Por favor verificar."
                    ElseIf lSefazNeg
                        lRet       := .F.
                        cStatusAR1 := AR1_STT_ERRORCANCERP
                        cLogMsg    += CRLF + aRskMonTss[2]
                    ElseIf lSefazPen
                        lRet       := .F.
                        If lCancSefaz
                            cStatusAR1 := AR1_STT_CANCELINGSEF
                            cLogMsg    += CRLF + aRskMonTss[2]
                        Else
                            cStatusAR1 := AR1_STT_ERRORCANCERP
                        EndIf
                    EndIf
                EndIf
                
                If lRet
                    If !RskEstComiss( lAutomato )
                        cLogMsg += CRLF + STR0059 //"Não foi possível efetuar o estorno da comissão. Será necessário realizar o ajuste manualmente."
                    EndIf
                EndIf
            EndIf

            If !lRet 
                DisarmTransaction()
            Else

                If lRejected .Or. lAguarda
                    oModel:SetOperation( MODEL_OPERATION_DELETE )
		            oModel:Activate()
                    If oModel:VldData()
	                    oModel:CommitData()
                    EndIf
                    oModel:DeActivate()
                Else
                    If lDenied
                        cLogMsg += CRLF + STR0077 //"Nota Fiscal denegada excluída do faturamento."
                    Else
                        //------------------------------------------------------------------------------
                        // Envia a solicitação de cancelamento para Supplier
                        //------------------------------------------------------------------------------
                        RskCancSup( lAutomato )
                        cStatusAR1 := AR1_STT_CANCELINGSUP
                    EndIf

                    oModel:SetOperation( MODEL_OPERATION_UPDATE )
                    oModel:Activate()
                    If oModel:IsActive() 
                        oMdlAR1 := oModel:GetModel( "AR1MASTER" )
                        oMdlAR1:SetValue( "AR1_STATUS", cStatusAR1 ) //8=Em cancelamento Supplier
                        
                        If !Empty(cLogMsg)
                            cLogMsg := oMdlAR1:GetValue( "AR1_OBSPAR" ) + cLogMsg
                            oMdlAR1:SetValue( "AR1_OBSPAR", cLogMsg )
                        EndIf

                        If oModel:VldData()
                            oModel:CommitData()
                        Else
                            aErrorMd := oModel:GetErrorMessage()
                            LogMsg( "RskEstFat", 23, 6, 1, "", "", "RskEstFat -> " + aErrorMd[6] )  
                        EndIf 
                    Else
                        aErrorMd := oModel:GetErrorMessage()
                        LogMsg( "RskEstFat", 23, 6, 1, "", "", "RskEstFat -> " + aErrorMd[6] )   
                    EndIf
                EndIf
            EndIf
        Else
            If !RskEstComiss( lAutomato )
                cLogMsg += CRLF + STR0059 //"Não foi possível efetuar o estorno da comissão. Será necessário realizar o ajuste manualmente."
            EndIf
        EndIf
    END TRANSACTION
        
    If !lRet .And. !lRejected .And. !lAguarda .Or. ( lSupplier .And. !Empty( cLogMsg ) )
        If !oModel:IsActive()
            oModel:SetOperation( MODEL_OPERATION_UPDATE )
            oModel:Activate()
        EndIf

        oMdlAR1 := oModel:GetModel( "AR1MASTER" )
        
        If !lSupplier .And. lNFeCancel .And. !lDenied
            oMdlAR1:SetValue( "AR1_STATUS", cStatusAR1 )
        EndIf

        If !Empty(cLogMsg)
            cLogMsg := oMdlAR1:GetValue( "AR1_OBSPAR" ) + cLogMsg
            oMdlAR1:SetValue( "AR1_OBSPAR", cLogMsg )
        EndIf

        If oModel:VldData()
            oModel:CommitData()
        Else
            aErrorMd := oModel:GetErrorMessage()
            LogMsg( "RskEstFat", 23, 6, 1, "", "", "RskEstFat -> " + aErrorMd[6] )  
        EndIf 
    Else
        aErrorMd := oModel:GetErrorMessage()
        LogMsg( "RskEstFat", 23, 6, 1, "", "", "RskEstFat -> " + aErrorMd[6] )   
    EndIf
    oModel:DeActivate()

    SE1->(RestArea(aAreaSE1))
    SF2->(RestArea(aAreaSF2))
    RestArea(aArea)

    FwFreeArray(aArea)
    FwFreeArray(aAreaSE1)
    FwFreeArray(aAreaSF2)
    FwFreeArray(aErroAuto)
    FwFreeArray(aFields)
    FwFreeArray(aRskMonTss)
    FwFreeArray(aStruTRB)
    FwFreeArray(aTRB)
    FwFreeArray(aBaixa)
    FwFreeArray(aNFSDel)

    FwFreeObj(oModel)
    FwFreeObj(oModelAR1)
    FwFreeObj(oTempTable)
Return

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskMonTSS
Funcao que consulta o status do cancelamento da NFE na Sefaz

@param aRecords, array, identificação da nota fiscal para consulta na Sefaz
@return array, [1] status na Sefaz
               [2] descrição do status

@author Claudio Yoshio Muramatsu
@since 17/09/2021
/*/
//-----------------------------------------------------------------------------
Static Function RskMonTSS(aNFeCancel As Array) As Array
    Local aArea      As Array
    Local aInfRet    As Array
    Local aInfMonNFe As Array

    aArea      := GetArea()
    aInfMonNFe := {}
    aInfRet    := ChamaMonit(aNFeCancel)
    cRet       := {}
    
    If Len(aInfRet)> 0
        //------------------------------------------------------------------------------            
        // Qual foi o codigo de retorno?
        //	015 = Foi autorizado a solicitacao de cancelamento da NFe
        //	026 - não foi autorizado a solicitacao de cancelamento da NFe
        //	030 = Inutilização de numeração autorizada.
        //	036 = Cancelamento autorizado fora do prazo.
        //------------------------------------------------------------------------------
        If ("015" $ aInfRet[1,6]) .Or. ("036" $ aInfRet[1,6]) .Or. ("030" $ aInfRet[1,6])
            aAdd(aInfMonNFe,"1") // foi aprovado
            aAdd(aInfMonNFe,STR0070) //"Cancelamento da Nota Fiscal aprovado na Sefaz"
        ElseIf ("026" $ aInfRet[1,6])
            aAdd(aInfMonNFe,"2") // Não foi aprovado
            aAdd(aInfMonNFe,STR0071) //"Cancelamento da Nota Fiscal negado pela Sefaz"
        Else
            aAdd(aInfMonNFe,"3") // Pendente (Aguardando do TSS)
            aAdd(aInfMonNFe,STR0069) //"Aguardando o status do cancelamento da Nota Fiscal na Sefaz."
        EndIf
    Else
        aAdd(aInfMonNFe,"")
        aAdd(aInfMonNFe,"")
    EndIf

    RestArea(aArea)

    FwFreeArray(aArea)
    FwFreeArray(aInfRet)
Return aInfMonNFe

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RSKCancNf
Funcao que realiza o cancelamento da nota fiscal no Protheus e Sefaz pelo Job

@param aRecords, array, identificação dos registros da AR1 para processamento
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Claudio Yoshio Muramatsu
@since 14/09/2021
/*/
//-----------------------------------------------------------------------------
Function RSKCancNf( aRecords As Array, lAutomato As Logical )  
    Local aArea       As Array
    Local aAreaSF2    As Array
    Local aErrorMd    As Array
    Local aRskMonTss  As Array
    Local cCodAR1     As Character
    Local cFilAR1     As Character
    Local lLockByFil  As Logical
    Local nItem       As Numeric    
    Local oMdlAR1     As Object
    Local oModel      As Object

    Default lAutomato := .F. 

    aArea       := GetArea()
    aAreaSF2    := SF2->(GetArea())
    aErrorMd    := {}
    aRskMonTss  := {}
    cCodAR1     := ""
    cFilAR1     := ""
    lLockByFil	:= !Empty(xFilial("AR1"))
    nItem       := 0
    oMdlAR1     := Nil
    oModel      := Nil

    If LockByName("RSKCancNf", .T., lLockByFil )
        For nItem := 1 to Len(aRecords)        
            cFilAR1 := aRecords[nItem][1]
            cCodAR1 := aRecords[nItem][2]
            
            DbSelectArea("AR1")
            AR1->( DbSetOrder(1) ) //AR1_FILIAL + AR1_COD
            If AR1->(DbSeek( cFilAR1 + cCodAR1 ))
                DbSelectArea("SF2")
                SF2->( DbSetOrder(1) ) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
                If SF2->( DbSeek(xFilial("SF2") + AR1->AR1_DOC + AR1->AR1_SERIE) )
                    aRskMonTss := RskMonTSS( {AR1->AR1_SERIE , AR1->AR1_DOC , AR1->AR1_DOC} )
                        
                    If aRskMonTss[1] == "1" //1-Autorizado
                        RskEstFat( lAutomato )
                    ElseIf aRskMonTss[1] == "2" //2-Negado                        
                        oModel  := FWLoadModel( "RSKA020" )
                        oModel:SetOperation( MODEL_OPERATION_UPDATE )
                        oModel:Activate()
                        
                        If oModel:IsActive() 
                            oMdlAR1 := oModel:GetModel( "AR1MASTER" )
                            oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_ERRORCANCERP ) //9=Erro no Cancelamento ERP

                            If oModel:VldData()
                                oModel:CommitData()
                            Else
                                aErrorMd := oModel:GetErrorMessage()
                                LogMsg( "RskEstFat", 23, 6, 1, "", "", "RskEstFat -> " + aErrorMd[6] )  
                            EndIf 
                        Else
                            aErrorMd := oModel:GetErrorMessage()
                            LogMsg( "RskEstFat", 23, 6, 1, "", "", "RskEstFat -> " + aErrorMd[6] )   
                        EndIf
                        oModel:DeActivate()                        
                    EndIf                
                Else                    
                    RskCancSup( lAutomato )
                EndIf
            EndIf
        Next nItem
        UnLockByName("RSKCancNf", .T., lLockByFil ) 
    Else
        LogMsg( "RSKCancNf", 23, 6, 1, "", "", "RskNewTicket -> " + STR0067 ) //"Existe um processamento de cancelamento de nota fiscal em outra instancia..."
    EndIf 
    
    RestArea(aArea)
    SF2->(RestArea(aAreaSF2))

    FWFreeArray(aArea)
    FWFreeArray(aAreaSF2)
    FWFreeArray(aErrorMd) 
    FWFreeArray(aRskMonTss) 
    
    FreeObj(oMdlAR1)
    FreeObj(oModel)

Return Nil

//-------------------------------------------------------------------------------
/*/{Protheus.doc} RskCancSup
Função para enviar a solicitação de cancelamento da NF para a Supplier após a
confirmação do cancelamento na Sefaz.
@param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR

@author Claudio Yoshio Muramatsu
@since  14/09/2021
/*/
//-----------------------------------------------------------------------------
Function RskCancSup( lAutomato As Logical )
    Local aArea          As Array
    Local aAreaAR0       As Array
    Local aAreaAR1       As Array
    Local aData          As Array
    Local aErrorMd       As Array
    Local cErrorMsg      As Character
    Local cErpId         As Character
    Local cERPCustomerID As Character
    Local cERPIdInvoice  As Character
    Local cResult        As Character
    Local cTempSE1       As Character
    Local cMessage       As Character
    Local oModel         As Object
    Local oMdlAR1        As Object
    Local oJItem         As Object
    Local oJResult       As Object
    Local oRest          As Object

    Default lAutomato := .F.

    aArea             := GetArea()
    aAreaAR0          := AR0->( GetArea() )
    aAreaAR1          := AR1->( GetArea() )
    aData             := {}
    aErrorMd          := {}
    cErpId            := ''
    cERPCustomerID    := ''
    cERPIdInvoice     := ''
    cErrorMsg         := ''
    cMessage          := ''
    cResult           := ''
    cTempSE1          := GetNextAlias()
    oMdlAR1           := NIL
    oModel            := NIL
    oJItem            := NIL
    oJResult          := NIL
    oRest             := NIL
    
    oModel  := FWLoadModel( "RSKA020" ) 

    cErpId         := AllTrim( cEmpAnt ) + "|" + AllTrim( AR1->AR1_FILIAL ) + "|" + AllTrim( AR1->AR1_COD )
    cERPCustomerID := AllTrim( cEmpAnt ) + "|" + AllTrim( AR1->AR1_FILCLI ) + "|" + AllTrim( AR1->AR1_CLIENT ) + "|" + AllTrim( AR1->AR1_LOJA ) 
    cERPIdInvoice  := AllTrim( cEmpAnt ) + "|" + AllTrim( AR1->AR1_FILNF ) + "|" + AllTrim( AR1->AR1_DOC ) + ;
            "|" + AllTrim( AR1->AR1_SERIE ) + "|" + AllTrim( AR1->AR1_CLIENT ) + "|" + AllTrim( AR1->AR1_LOJA ) 

    aAdd( aData, { cErpId, AR1->( RECNO() ) } )
            
    oJItem := JsonObject():New()
    oJItem[ "erpId" ]          := cErpId    
    oJItem[ "erpCustomerId" ]  := cERPCustomerID 
    oJItem[ "erpIdInvoice" ]   := cERPIdInvoice
    oJItem[ "invoiceId" ]      := AR1->AR1_CMDINV 
    oJItem[ "documentNumber" ] := AR1->AR1_CGCCLI
    oJItem[ "transactionId" ]  := AR1->AR1_TCKTRA

    If RskPedAdt( AR1->AR1_CONDPG )
        oJItem[ "Amount" ] := AR1->AR1_VLRREC + AR1->AR1_TXNEG
    Else
        oJItem[ "Amount" ] := AR1->AR1_VLRNF
    EndIf

    DbSelectArea('AR0')
    DbSetOrder(4) //AR0_FILIAL+AR0_TKTRSK
    If DbSeek(xFilial('AR0') + AR1->AR1_TKTRSK)
        oJItem[ "PartnerTransactionId" ] := AR0->AR0_TCKTRA
    EndIf

    IF !lAutomato
        cResult := RSKRestExec( RSKPOST, "/api/v1/invoicecancelation", @oRest, oJItem, RISK, SERVICE, .F. , .F. )   // POST ### 1=Risk ### 2=URL de autenticação de serviços
    ELSE
        cResult := RskADVPRData( 'RSKA020' )
    EndIf

    If !Empty( cResult )                        
        oJResult := JSONObject():New()
        oJResult:FromJSON( cResult ) 

        oJItem      := oJResult
        nPosErpId   := aScan( aData, {|x| x[1] == oJItem["erpId"] } )
        If nPosErpId > 0
            AR1->( DBGoTo( aData[1][2] ) )

            oModel:SetOperation( MODEL_OPERATION_UPDATE )
            oModel:Activate() 

            If oModel:IsActive() 
                oMdlAR1 := oModel:GetModel( "AR1MASTER" ) 

                cMessage := oMdlAR1:GetValue( "AR1_OBSPAR" ) + CRLF

                If oJItem["statusProcess"] == 1
                    cMessage += STR0045 //'Solicitação de cancelamento efetuada com sucesso.'
                    oMdlAR1:SetValue( "AR1_STATUS", AR1_STT_CANCELINGSUP ) //8=Em Cancelamento Supplier
                Else
                    cMessage += STR0046 + DecodeUTF8( oJItem["description"] ) + Chr(10) //'Falha na solicitação de cancelamento da NFS Mais Negócios: '
                EndIf
                oMdlAR1:SetValue( "AR1_OBSPAR", cMessage )   
                
                If oModel:VldData()
                    oModel:CommitData()
                Else
                    aErrorMd := oModel:GetErrorMessage()
                    LogMsg( "RskCancSup", 23, 6, 1, "", "", "RskCancSup -> " + aErrorMd[6] )  
                EndIf  
            Else
                aErrorMd := oModel:GetErrorMessage()
                LogMsg( "RskCancSup", 23, 6, 1, "", "", "RskCancSup -> " + aErrorMd[6] )   
            EndIf
            oModel:DeActivate() 
        EndIf

    Else
        If !lAutomato 
            LogMsg( "RskCancSup", 23, 6, 1, "", "", "RskCancSup -> " + oRest:GetLastError() ) 
        EndIf 
    EndIf
    
    RestArea( aAreaAR0 ) 
    RestArea( aAreaAR1 ) 
    RestArea( aArea ) 

    FWFreeArray( aArea ) 
    FWFreeArray( aAreaAR0 ) 
    FWFreeArray( aAreaAR1 ) 
    FWFreeArray( aData )
    FWFreeArray( aErrorMd)
    
    FreeObj( oJItem ) 
    FreeObj( oModel ) 
    FreeObj( oMdlAR1 ) 
    FreeObj( oJResult )
    FreeObj( oRest )
Return

/*/
    {Protheus.doc} CalcValNF
    Rotina para calcular o valor da primeira parcela da Nota Fiscal para envio a Plataforma
    @type Static Function
    @author Daniel Moda
    @since 17/05/2022
    @version P12
    @param cFilialNF, Character, Filial da Nota Fiscal de Saida Mais Negocios
    @param cNumNF, Character, Numero da Nota Fiscal de Saida Mais Negocios
    @param cSerieNF, Character, Serie da Nota Fiscal de Saida Mais Negocios
    @param cPedVenda, Character, Numero do Pedido de Venda
    @param cCondPag, Character, Condicao de Pagamento utilizado no Faturamento
    @return nVlrParc, Numeric, retorna o valor da primeira parcela da Nota Fiscal
/*/
Static Function CalcValNF(cFilialNF As Character, cNumNF As Character, cSerieNF As Character, cPedVenda As Character, cCondPag As Character) As Numeric

Local aAreaFR3  As Array
Local aPayCond  As Array
Local cQuerySD2 As Character
Local cTempSD2  As Character
Local nVlrParc  As Numeric

Default cFilialNF := ''
Default cNumNF    := ''
Default cSerieNF  := ''
Default cPedVenda := ''
Default cCondPag  := ''

aAreaFR3 := FR3->(GetArea())
nVlrParc := 0

FR3->(DbSetOrder(1)) // FR3_FILIAL+FR3_CART+FR3_DOC+FR3_SERIE+FR3_PEDIDO

If FR3->(MsSeek(cFilialNF + 'R' + cNumNF + cSerieNF + cPedVenda))

    If __oQrySD2 == Nil
        cQuerySD2 := "SELECT SUM(D2_VALBRUT) TOTAL " + ;
                        "FROM " + RetSqlName( "SD2" ) + " SD2 " + ;
                        "WHERE D2_FILIAL = ? " + ; 
                        "AND D2_DOC = ? " + ; 
                        "AND D2_SERIE = ? " + ; 
                        "AND D2_PEDIDO = ? " + ; 
                        "AND SD2.D_E_L_E_T_ = ' ' "
        cQuerySD2 := ChangeQuery( cQuerySD2 )
        __oQrySD2 := FWPreparedStatement():New(cQuerySD2)
    EndIf
    
    __oQrySD2:SetString(1,cFilialNF)
    __oQrySD2:SetString(2,cNumNF)
    __oQrySD2:SetString(3,cSerieNF)
    __oQrySD2:SetString(4,cPedVenda)

    cQuerySD2 := __oQrySD2:GetFixQuery()
    cTempSD2  := MPSysOpenQuery( cQuerySD2 )

    aPayCond := Condicao( (cTempSD2)->TOTAL, cCondPag )
    If Len(aPayCond) > 0
        nVlrParc := aPayCond[1,2]
    EndIf        

EndIf

RestArea(aAreaFR3)

FwFreeArray(aAreaFR3)
FwFreeArray(aPayCond)

Return nVlrParc

//-------------------------------------------------------------------
/*/{Protheus.doc} Rsk020StCBox
Função para retornar a lista de opções do combo do campo AR1_STATUS

@return caracter, lista de opções para o combobox

@author Claudio Yoshio Muramatsu
@since 15/09/2021
@version P12
/*/
//-------------------------------------------------------------------
Function Rsk020StCBox
    Local cCombo := STR0073 //"0=Aguardando Envio;1=Em Análise;2=Aprovada;3=Rejeitada;4=Cancelada;5=Inconsistente;6=Em Cancelamento;7=Em Cancelamento Sefaz;8=Em Cancelamento Supplier;9=Erro no Cancelamento ERP;A=Cancelamento Recusado Supplier;B=Negada;C=NF Cancelada na Supplier"
Return cCombo

/*/{Protheus.doc} Rsk020CanSup
    Função que realiza o cancelamento na Supplier
    @type Function
    @author Lucas Silva Vieira
    @since 16/08/2022
    @param  lAutomato, boolean, Indica que a função foi chamada por um script ADVPR
    @return nil
/*/
Function Rsk020CanSup(lAutomato As Logical)
    Local aArea      As Array
    Local lBxDtFin   As Logical
    Local lDate      As Logical
    Local dToday     As Date
    Local cStatusAR1 As Character

    Default lAutomato := .F.  

    aArea      := GetArea()
    cStatusAR1 := AR1->AR1_STATUS

    If cStatusAR1 == AR1_STT_APPROVED .Or. cStatusAR1 == AR1_STT_FLIMSY .Or. cStatusAR1 == AR1_STT_ERRORCANCERP // 2 = Aprovada ### 5 = Inconsistente ### 9 = Erro no Cancelamento ERP
        IF lAutomato .Or. MsgYesNo( STR0088, STR0089 ) // 'Deseja realizar o processo de cancelamento da NF Mais Negócio na Supplier? Este processo pode acarretar taxas conforme o contrato.' ### 'Cancelamento da NF Mais Negócio com a Supplier'
            If ValidCanSup(AR1->AR1_FILIAL, AR1->AR1_COD)
                lBxDtFin := SuperGetMv("MV_BXDTFIN",,"1") == '2'
                dToday   := Date()
                lDate    := Iif(lBxDtFin, DtMovFin(dToday,.F.,"1"), .F.)
                If lDate
                    FWMsgRun(, {|| RskCancSup( lAutomato ) }, STR0031, STR0078) //Processando # Aguarde processando cancelamento na Supplier
                Else
                    Help( "", 1, "Rsk020CanSup", , STR0087, 1, 0,,,,,, { STR0085 } ) //Não é possível realizar esta movimentação pois o período está fechado. # Não é possível cancelar
                Endif
            Else
                Help( "", 1, "Rsk020CanSup", , STR0084, 1, 0,,,,,, { STR0085 } ) //NF possui devolução ou bonificação. # Não é possível cancelar
            EndIf
        Endif 
    ElseIf cStatusAR1 == AR1_STT_CANSUPOK // C = NF Cancelada na Supplier
        Help( "", 1, "Rsk020CanSup", , STR0081, 1, 0,,,,,, { STR0079 } ) //NF Cancelada na Supplier
    Else
        Help( "", 1, "Rsk020CanSup", , STR0046, 1, 0,,,,,, { STR0048 } ) //O status desta NFS Mais Negócio não permite a ação de cancelamento.
    Endif

    RestArea(aArea)
    FwFreeArray(aArea)    
Return 

/*/{Protheus.doc} ValidCanSup
    Valida se movimentos de devolução e bonificação.
    @type Static Function
    @author lucas Silva Vieira
    @since 24/08/2022
    @param cFilialAr2, Character, Filial
    @param cCodAr2, Character, Codigo 
    @return lValidCan, logical 
/*/
Static Function ValidCanSup(cFilialAr2 As Character, cCodAr2 As Character) As Logical
    Local aArea         As Array
    Local aAreaAr2      As Array
    local lValidCan     As Logical
    Local cChaveAr2     As Character

    Default cFilialAr2 := ""
    Default cCodAr2    := ""    
    
    lValidCan := .T.
    aArea     := GetArea()
    aAreaAr2  := AR2->(GetArea())
    cChaveAr2 := cFilialAr2 + cCodAr2

    If !Empty(cChaveAr2)
        AR2->(DbSetOrder(1)) // AR2_FILIAL + AR2_COD + AR2_ITEM
        If AR2->(MsSeek(cChaveAr2))
            While AR2->(!EOF()) .And. AR2->AR2_FILIAL + AR2->AR2_COD == cChaveAr2
                If AR2->AR2_MOV == AR2_MOV_BONUS .Or. AR2->AR2_MOV == AR2_MOV_DEVOLUTION .Or. AR2->AR2_MOV == AR2_MOV_BLOCK_NCC // 3 - Bonificação # 5 - Devolução # 6 - Bloqueia NCC
                    lValidCan := .F.
                    Exit
                EndIf
                AR2->( DbSkip() )
            EndDo
        Endif
    EndIf       

    RestArea(aAreaAr2)
    RestArea(aArea)
    FwFreeArray(aAreaAr2)
    FwFreeArray(aArea)

Return lValidCan
