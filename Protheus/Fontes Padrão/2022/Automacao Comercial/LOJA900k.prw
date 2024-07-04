#Include 'Protheus.ch'
#Include "TCBROWSE.CH"
#Include "Font.ch"
#Include "LOJA900k.ch"

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900K
Função para envio e gravação dados do rastreio 
CiaShop integracao Protheus e-commerce CiaShop 
@param   sem parâmetros
@author  Varejo
@version 	P11.8
@since   	07/08/2016
@sample LOJA900k()
/*/
//-------------------------------------------------------------------
Function LOJA900k()

	Local lRet	  := .T.
	Local cPerg	  := "LJ900K"
	Local lVldMH6 := AliasIndic("MH6")

	If !Pergunte(cPerg, .T.)
		MsgStop(STR0031 + CRLF + STR0032)	//"Perguntas não cadastradas" / "Programa será finalizado"
		lRet := .F.
	EndIf
	
	If lRet .And. !lVldMH6
		MsgStop(STR0033)	 //"Nesta Versão de Fonte é necessário criar a Tabela MH6 e MH8" / " ou aplique o compatibilizador 'UPDLOJ148' superior a Data de 16/12/2016"
		lRet := .F.
	EndIf
	
	If lRet
		Processa( {|| CarPedidos()}, STR0009, STR0057)	//"Relação de Pedidos - Rastreio"   //"Carrregando Pedidos"
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CarPedidos
Carrega pedidos para alteração de status 
 
@author  	Varejo
@version	12.1.23
@since   	01/11/2018
/*/
//-------------------------------------------------------------------
Static Function CarPedidos()

	Local aTrabStru  := {}
	Local aTrabIdx	 := {}
	Local oSay     	 := NIL
	Local cArqTemp	 := GetNextAlias()
	Local cTabela	 := GetNextAlias()
	Local aColunas	 := {}
	Local bDoubleCli := { || IIF( !((cArqTemp)->PED_STATUS $ "90|91"), TelaRastro(cArqTemp, oBrowse), Nil) }
	Local oBrowse 	 := NIL
	Local oDlg     	 := NIL
	Local cStatusPed := SuperGetMv("MV_LJECST1", .F., "30")                                  //Valor do Status a ser enviado para o site da Ciashop ao realizar a gravacao do documento fiscal
	Local oTabTemp	 := NIL
	Local lEcommeAnt := SuperGetMV("MV_LJECOMO", , .F.) .Or. SuperGetMV("MV_LJECOMM", , .F.) //Indica se é e-commerce CiaShop - (INTEGRAÇÃO ANTIGA)

	ProcRegua(0)
	IncProc()
  
	//Define estrutura arquivo de trabalho para apresentação na Browse
	AADD( aTrabStru , { "PED_RASTR"		, "C" , TamSX3("C5_RASTR")[1]	, 00 })
	AADD( aTrabStru , { "PED_FILIAL"	, "C" , TamSX3("C5_FILIAL")[1] 	, 00 })		
	AADD( aTrabStru , { "PED_NOTA" 		, "C" , TamSX3("C5_NOTA")[1] 	, 00 })		
	AADD( aTrabStru , { "PED_SERIE"	 	, "C" ,	TamSX3("C5_SERIE")[1] 	, 00 })		
	AADD( aTrabStru , { "PED_CLIE" 		, "C" , TamSX3("C5_CLIENTE")[1] , 00 })		
	AADD( aTrabStru , { "PED_LOJA"		, "C" , TamSX3("C5_LOJACLI")[1]	, 00 })		
	AADD( aTrabStru , { "PED_NUM"		, "C" , TamSX3("C5_NUM")[1] 	, 00 })		
	AADD( aTrabStru , { "PED_PEDECO"	, "C" , TamSX3("C5_PEDECOM")[1] , 00 })		
    AADD( aTrabStru , { "PED_TRANSP"	, "C" , TamSX3("C5_TRANSP")[1] , 00 })	
	AADD( aTrabStru , { "PED_TIPO" 		, "C" , TamSX3("C5_TIPO")[1] 	, 00 })		
	AADD( aTrabStru , { "PED_STATUS"	, "C" , TamSX3("C5_STATUS")[1] 	, 00 })		
	AADD( aTrabStru , { "PED_EMISSA"	, "D" , TamSX3("C5_EMISSAO")[1]	, 00 })		
	AADD( aTrabStru , { "PED_DTRAST"	, "D" , TamSX3("MH6_DTRAST")[1]	, 00 })		
	AADD( aTrabStru , { "PED_HRRAST"	, "C" , TamSX3("MH6_HRRAST")[1]	, 00 })		
    AADD( aTrabStru , { "PED_NSUTEF"	, "C" , TamSX3("L4_NSUTEF")[1]	, 00 })	
	
	Aadd(aTrabIdx , "PED_FILIAL+PED_EMISSA+PED_CLIE+PED_LOJA+PED_NUM")
	
	oTabTemp := LjCrTmpTbl(cArqTemp, aTrabStru, aTrabIdx)
	(cArqTemp)->( DbSetOrder(1) )
	
	//Monta condição sql
	_cQuery := " SELECT C5_FILIAL, C5_CLIENTE, C5_LOJACLI, C5_NUM, C5_PEDECOM, C5_TIPO, C5_STATUS, C5_EMISSAO, C5_NOTA, C5_SERIE, C5_RASTR , C5_TRANSP 	,L1.L1_NUM, L4.L4_NSUTEF"
	
   	_cQuery += " FROM " + RetSqlName("SC5") + " C5 INNER JOIN " + RetSqlName("SF2") + " F2"
    _cQuery += " ON C5_FILIAL = F2_FILIAL AND C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE AND C5.D_E_L_E_T_ = F2.D_E_L_E_T_"

    _cQuery += " INNER JOIN " + RetSqlName("SL1") + " L1" 
    _cQuery += " ON C5_FILIAL = L1_FILIAL AND C5_NUM = L1_PEDRES AND C5.D_E_L_E_T_ = L1.D_E_L_E_T_"

    _cQuery += " INNER JOIN " + RetSqlName("SL4") + " L4" 
    _cQuery += " ON C5_FILIAL = L4_FILIAL AND L1.L1_NUM = L4.L4_NUM AND C5.D_E_L_E_T_ = L4.D_E_L_E_T_"

	_cQuery += " WHERE C5.D_E_L_E_T_ = ' '"
	_cQuery += 	 " AND C5_FILIAL = '"  + xFilial("SC5") + "'"
	_cQuery += 	 " AND C5_NOTA 	<> '"  + Space(TamSx3("C5_NOTA")[1]) + "'"			//Somente pedidos faturados
    _cQuery += 	 " AND F2_CHVNFE <> '" + Space(TamSx3("F2_CHVNFE")[1]) + "'"        //Somente notas ficais transmitidas
	
	If !Empty(MV_PAR01)
		_cQuery += " AND C5_NOTA = '" + MV_PAR01 + "'"
	EndIf
	
	If !Empty(MV_PAR02)
		_cQuery += " AND C5_SERIE = '" + MV_PAR02 + "'"
	EndIf
	
	If !Empty(MV_PAR03)
		_cQuery += " AND C5_CLIENTE = '" + MV_PAR03 + "'"
	EndIf
	
	If !Empty(MV_PAR04)
		_cQuery += " AND C5_LOJACLI = '" + MV_PAR04 + "'"
	EndIf
	
	If !Empty(MV_PAR05)
		_cQuery += " AND C5_NUM = '" + MV_PAR05 + "'"
	EndIf

    //Indica se é e-commerce CiaShop - (INTEGRAÇÃO ANTIGA)
   	If lEcommeAnt
		_cQuery += " AND C5_STATUS	=  '" + AllTrim(cStatusPed) + "'"				//Somente pedidos Enviados / Empacotado	- 1=Volta passo; 05=Em analise; 10=Pagamento confirmado; 15=Empacotado; 21=Parcialmente enviado; 30=Enviado; 90=cancelado; 91=Devolvido       
    Else
    	If !Empty(MV_PAR10)
		    _cQuery += " AND L4.L4_NSUTEF = '" + MV_PAR10 + "'"
	    EndIf    
	EndIf
    
	If !Empty(MV_PAR09)
		_cQuery += " AND C5_TRANSP = '" + MV_PAR09 + "'"
	EndIf

    _cQuery += " AND C5_PEDECOM <> '" + Space(TamSx3("C5_PEDECOM")[1]) + "'"	//Somente pedidos Ecommerce

    If !Empty(MV_PAR06)
        _cQuery += " AND C5_PEDECOM = '" + MV_PAR06 + "'"
    EndIf

	CursorWait()
	
	IncProc(STR0057)    //"Carrregando Pedidos"	
	_cQuery := ChangeQuery(_cQuery)
	DbUseArea(.T., "TOPCONN", TcGenQry( , , _cQuery), cTabela, .T., .T.)
	
	While !(cTabela)->( Eof() )
	
		IncProc(STR0008 + (cTabela)->C5_NUM)	//"Processando Pedido "
	
		//Grava no arquivo temporario os pedidos que serão processados
		RecLock(cArqTemp, .T.)
			(cArqTemp)->PED_FILIAL  := (cTabela)->C5_FILIAL
			(cArqTemp)->PED_CLIE	:= (cTabela)->C5_CLIENTE
			(cArqTemp)->PED_LOJA	:= (cTabela)->C5_LOJACLI
			(cArqTemp)->PED_NUM	    := (cTabela)->C5_NUM
			(cArqTemp)->PED_PEDECO	:= (cTabela)->C5_PEDECOM
            (cArqTemp)->PED_TRANSP	:= (cTabela)->C5_TRANSP
			(cArqTemp)->PED_TIPO	:= (cTabela)->C5_TIPO
			(cArqTemp)->PED_STATUS	:= (cTabela)->C5_STATUS
			(cArqTemp)->PED_EMISSA	:= Stod((cTabela)->C5_EMISSAO)
			(cArqTemp)->PED_NOTA	:= (cTabela)->C5_NOTA
			(cArqTemp)->PED_SERIE	:= (cTabela)->C5_SERIE
			(cArqTemp)->PED_DTRAST	:= IIF( Empty(MV_PAR07), dDataBase	,MV_PAR07 )
			(cArqTemp)->PED_HRRAST	:= IIF( Empty(MV_PAR08), Time()		,MV_PAR08 )
			(cArqTemp)->PED_RASTR	:= (cTabela)->C5_RASTR
            (cArqTemp)->PED_NSUTEF	:= (cTabela)->L4_NSUTEF


            
		(cArqTemp)->( MsUnlock() )
		
		(cTabela)->( DbSkip() )
	EndDo
	(cTabela)->( DbCloseArea() )
	
	CursorArrow()
	
	//Mostra os registros do arquivo temporaria
	(cArqTemp)->( DbGoTop() )
	If !(cArqTemp)->( Eof() )
	  	
		//Instancia a classe
		oBrowse:= FWMBrowse():New()
		
		//Descrição do browse
		oBrowse:SetDescription(STR0009)	//"Relação de Pedidos - Rastreio"
		
		//Tabela temporaria
		oBrowse:SetAlias(cArqTemp)
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
        aColunas[nCol]:SetData( {|| LjxjStaPed((cArqTemp)->PED_STATUS) })
		aColunas[nCol]:SetTitle( RetTitle("C5_STATUS") )
		aColunas[nCol]:SetSize( aTrabStru[10, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)

		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_RASTR })
		aColunas[nCol]:SetTitle( RetTitle("C5_RASTR")  )
		aColunas[nCol]:SetSize(  aTrabStru[01, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)                         

		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_FILIAL })
		aColunas[nCol]:SetTitle( RetTitle("C5_FILIAL")  )
		aColunas[nCol]:SetSize(  aTrabStru[02, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)		
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_NOTA })
		aColunas[nCol]:SetTitle( RetTitle("C5_NOTA") )
		aColunas[nCol]:SetSize( aTrabStru[03, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_SERIE })
		aColunas[nCol]:SetTitle(  RetTitle("C5_SERIE") )
		aColunas[nCol]:SetSize( aTrabStru[04, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_CLIE })
		aColunas[nCol]:SetTitle(  RetTitle("C5_CLIENTE"))
		aColunas[nCol]:SetSize( aTrabStru[05, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)		
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_LOJA })
		aColunas[nCol]:SetTitle( RetTitle("C5_LOJACLI"))
		aColunas[nCol]:SetSize( aTrabStru[06, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_NUM })
		aColunas[nCol]:SetTitle( RetTitle("C5_NUM") )
		aColunas[nCol]:SetSize( aTrabStru[07, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)
		
        aAdd(aColunas, FWBrwColumn():New())
        nCol := Len(aColunas)
        aColunas[nCol]:SetData( {|| (cArqTemp)->PED_PEDECO })
        aColunas[nCol]:SetTitle( RetTitle("C5_PEDECOM"))
        aColunas[nCol]:SetSize( aTrabStru[08, 03] )
        aColunas[nCol]:SetDecimal( 0 )
        aColunas[nCol]:SetPicture( "@!" )
        aColunas[nCol]:SetAutoSize(.T.)	

        aAdd(aColunas, FWBrwColumn():New())
        nCol := Len(aColunas)
        aColunas[nCol]:SetData( {|| (cArqTemp)->PED_TRANSP })
        aColunas[nCol]:SetTitle( RetTitle("C5_TRANSP"))
        aColunas[nCol]:SetSize( aTrabStru[08, 03] )
        aColunas[nCol]:SetDecimal( 0 )
        aColunas[nCol]:SetPicture( "@!" )
        aColunas[nCol]:SetAutoSize(.T.)		
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
        aColunas[nCol]:SetData( {|| ComboBox("C5_TIPO", (cArqTemp)->PED_TIPO) })
		aColunas[nCol]:SetTitle( RetTitle("C5_TIPO") )
		aColunas[nCol]:SetSize( aTrabStru[09, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)
		
		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_EMISSA })
		aColunas[nCol]:SetTitle( RetTitle("C5_EMISSAO") )
		aColunas[nCol]:SetSize( aTrabStru[11, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@D" )
		aColunas[nCol]:SetAutoSize(.T.)		

		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_DTRAST })
		aColunas[nCol]:SetTitle( "Dt.Rastr." )
		aColunas[nCol]:SetSize( aTrabStru[12, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@D" )
		aColunas[nCol]:SetAutoSize(.T.)		

		aAdd(aColunas, FWBrwColumn():New())
		nCol := Len(aColunas)
		aColunas[nCol]:SetData( {|| (cArqTemp)->PED_HRRAST })
		aColunas[nCol]:SetTitle( "Hr.Rastr." )
		aColunas[nCol]:SetSize( aTrabStru[13, 03] )
		aColunas[nCol]:SetDecimal( 0 )
		aColunas[nCol]:SetPicture( "@!" )
		aColunas[nCol]:SetAutoSize(.T.)		

        aAdd(aColunas, FWBrwColumn():New())
        nCol := Len(aColunas)
        aColunas[nCol]:SetData( {|| (cArqTemp)->PED_NSUTEF })
        aColunas[nCol]:SetTitle( RetTitle("L4_NSUTEF"))
        aColunas[nCol]:SetSize( aTrabStru[08, 03] )
        aColunas[nCol]:SetDecimal( 0 )
        aColunas[nCol]:SetPicture( "@!" )
        aColunas[nCol]:SetAutoSize(.T.)	
		
		oBrowse:AddLegend( {|| (cArqTemp)->PED_STATUS == '10'}, "BR_VERDE"	 , STR0050 )	//"Aprovado"
		oBrowse:AddLegend( {|| (cArqTemp)->PED_STATUS == '11'}, "BR_AMARELO" , STR0058 )	//"Faturado"
		oBrowse:AddLegend( {|| (cArqTemp)->PED_STATUS == '15'}, "BR_AZUL"	 , STR0053 )	//"Empacotado"
		oBrowse:AddLegend( {|| (cArqTemp)->PED_STATUS == '30'}, "BR_LARANJA" , STR0052 )	//"Enviado"
		oBrowse:AddLegend( {|| (cArqTemp)->PED_STATUS == '31'}, "BR_CINZA"   , STR0059 )	//"Entrege"
		oBrowse:AddLegend( {|| (cArqTemp)->PED_STATUS == '90'}, "BR_VERMELHO", STR0051 )	//"Cancelado"
		oBrowse:AddLegend( {|| (cArqTemp)->PED_STATUS == '91'}, "BR_PRETO"	 , STR0060 )	//"Devolvido"
		
		oBrowse:SetColumns(aColunas)
		
		oBrowse:AddButton(STR0010, bDoubleCli)  //"Rastreio"
        oBrowse:SetDoubleClick(bDoubleCli)
		
		oBrowse:Activate()
	Else
	
		MsgAlert(STR0001)	//"Não existem pedidos para enviar"
	EndIf
	
	//Fecha arquivo temporarios
	(cArqTemp)->( DbCloseArea() )
	oTabTemp:Delete()
	FwFreeObj(oTabTemp)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} TelaRastro
Função TelaRastro
@param   pedido
@author  Varejo
@version P11.8
@since   07/08/2016
/*/
//-------------------------------------------------------------------
Static Function TelaRastro(cArqTemp, oBrowse)

	Local oDlg	  	 := Nil
	Local oSay	   	 := Nil
	Local oRastr  	 := Nil
	Local oCheck  	 := Nil
	Local lCheck  	 := .T.
	Local cRastro 	 := (cArqTemp)->PED_RASTR
	Local oCbxStatus := Nil 
    Local aCbxStatus := {"30=" + STR0052, "31=" + STR0059}                                      //30=Enviado 31=Entregue
    Local cStatus    := SuperGetMv("MV_LJECSTF", , "30")                                        //Status após o faturamento - 30=Enviado
	Local lEcommeAnt := SuperGetMV("MV_LJECOMO", , .F.) .Or. SuperGetMV("MV_LJECOMM", , .F.)    //Indica se é e-commerce CiaShop - (INTEGRAÇÃO ANTIGA)
    Local nCont      := 0
    	
    For nCont:=1 To Len(aCbxStatus)
        aCbxStatus[nCont] := AllTrim(aCbxStatus[nCont])
    Next nCont

	//Define a janela parâmetros
	Define MSDialog  oDlg Title STR0010 From 0, 0 To /*360*/ 200, /*496*/400 Pixel	//"Rastreio"
	
	//Marca/Desmarca por mascara
	@ 020, 010 Say   oSay Prompt STR0011 + (cArqTemp)->PED_NUM + ": " Size 110, 08 Of oDlg Pixel	//"Digite o Rastreio para o Pedido "
	@ 020, 120 MSGet oRastr Var cRastro Size 70, 08 Pixel Picture("@S20!")
	
    //Integração via MSU, permite selecionar o Status
	If !lEcommeAnt
		cStatus := (cArqTemp)->PED_STATUS
		
		@ 040, 010 Say oSay Prompt STR0061 Size 110, 08 Of oDlg Pixel	//"Status"
		oCbxStatus := TComboBox():New(040, 120, {|u| IF( PCount() > 0, cStatus:=u, cStatus) }, aCbxStatus, 70, 10, oDlg, , {|| }, , , , .T., , , , , , , , , "cStatus")
	Else
		oCheck := TCheckBox():New(060, 010, STR0012, {|u| if(PCount()>0, lCheck:=u, lCheck)} , oDlg, 150, 210,,,,,,,,.T.,,,)	//"Enviar status (enviado) de pedido para CiaShop"	
	EndIf	
	
	
	Define SButton From 080, 130 Type 1 Action ( Grava(lCheck, cArqTemp, cRastro, cStatus), oDlg:End() ) OnStop STR0013 Enable Of oDlg	//"Confirma"
	Define SButton From 080, 160 Type 2 Action ( oDlg:End() ) 								 			 OnStop STR0014 Enable Of oDlg 	//"Cancela"
	
	Activate MSDialog  oDlg Center
	
	oBrowse:Refresh()

Return cRastro

//-------------------------------------------------------------------
/*/{Protheus.doc} Grava
Função grava rastreio na tabela temporaria
@param      cPerg - Pergunta
@author     Varejo
@version 	P11.8
@since   	28/10/2014
/*/
//-------------------------------------------------------------------
Static Function Grava(lCheck, cArqTemp, cRastro, cStatus)
    
    Local aArea    := GetArea()
    Local aAreaSC5 := SC5->( GetArea() )
    Local cErro    := ""

    If Empty(cStatus)
        cErro := STR0055    //"Status não preenchido, pedido não será atualizado"
    EndIf

    If Empty(cErro) .And. (cArqTemp)->PED_STATUS > cStatus
        cErro := STR0062    //"Não é permitido voltar o Status do Pedido"
    EndIf

    //Envia caso tenha alguma alteração
    If Empty(cErro) .And. ( (cArqTemp)->PED_STATUS <> cStatus .Or. (cArqTemp)->PED_RASTR <> cRastro )

        //Atualiza arquivo temporario
        RecLock(cArqTemp, .F.)
            (cArqTemp)->PED_STATUS := cStatus	
            (cArqTemp)->PED_RASTR  := cRastro
        (cArqTemp)->( MsUnLock() )
        
        If lCheck
            
            CursorWait()
            
            IncProc(STR0054 + (cArqTemp)->PED_NUM)	//"Enviando pedido => "
            
            SC5->( DbSetOrder(1) )      //C5_FILIAL+C5_NUM
            If !SC5->( DbSeek(xFilial("SC5") + (cArqTemp)->PED_NUM) )
                cErro := I18n( STR0003, {xFilial("SC5") + (cArqTemp)->PED_NUM} )    //"Pedido #1 não foi localizado"
            Else
        
                //Atualiza status
                RecLock("SC5", .F.)
                    SC5->C5_STATUS 	:= cStatus
                    SC5->C5_RASTR	:= cRastro
                SC5->( MsUnLock() )

                //Grava dados complementares pedido de venda
                If !Empty(SC5->C5_PEDECOM)
                
                    MH6->( DbSetOrder(1) )	//MH6_FILIAL+MH6_PDECOM
                    If MH6->( DbSeek(xFilial("MH6") + SC5->C5_PEDECOM) )
                        RecLock("MH6", .F.)
                    Else
                        RecLock("MH6", .T.)
                        MH6->MH6_FILIAL := xFilial("MH6")
                        MH6->MH6_PDECOM := SC5->C5_PEDECOM						
                    EndIf
                    
                    MH6->MH6_NUM    := SC5->C5_NUM
                    MH6->MH6_STATUS := SC5->C5_STATUS
                    MH6->MH6_RASTRE	:= SC5->C5_RASTR
                    MH6->MH6_HRRAST	:= (cArqTemp)->PED_HRRAST
                    MH6->MH6_DTRAST	:= (cArqTemp)->PED_DTRAST
                    
                    MH6->( MsUnLock() )
                EndIf
                
                //Envia rastreabilidade de pedido
                If FWHasEAI("MATA410B",.T., , .T.)
                    FwIntegDef("MATA410B")
                EndIf
				//Envia rastreabilidade de pedido - SMARTHUB
				If cStatus == "31" .AND. AliasInDic("MHQ").AND. ExistFunc("RmiExeGat") .AND. ExistFunc("SHPStatus")
					SL1->( DbSetOrder(2) ) 
					If SL1->( DbSeek(xFilial("SL1") + (cArqTemp)->PED_SERIE + (cArqTemp)->PED_NOTA) )

						DbSelectArea("MHQ")
						If (!Empty(SL1->L1_UMOV) .AND. !Empty(Posicione("MHQ",7,xFilial("MHQ")+SL1->L1_UMOV,"MHQ_CHVUNI")) )
							SL1->(DbSetOrder(1)) //L1_FILIAL + L1_NUM
							If SL1->(DBSeek(SL1->L1_FILIAL+SL1->L1_ORCRES))
								SHPStatus("order_delivered")
							EndIf
						EndIf
						MHQ->(DBCLOSEAREA())

					EndIf
				EndIf
                //Grava o log de alteração armazem
                LjGrvLog(SC5->C5_NUM, STR0002)  //"Status do pedido Protheus alterado e enviado "
                
                ApMsgInfo(STR0004, STR0049)	//"Pedidos enviados com Sucesso!"	"Atenção!"
            EndIf
            
            CursorArrow()
        EndIf
    EndIf

    //Apresenta erro
    If !Empty(cErro)
        LjxjMsgErr(cErro, /*cSolucao*/)
    EndIf

    RestArea(aAreaSC5)
    RestArea(aArea)

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ComboBox
Retorna a descrição contida no combobox do campo.

@param  cCampo - Nome do campo
@param  cValeu - Conteudo
@author Varejo
@since  05/04/2019
/*/
//-------------------------------------------------------------------
Static Function ComboBox(cCampo, cValue)

    Local cValor := ""
    Local aTemp  := {}
    Local nCti   := 0
    Local cCbox  := AllTrim( StrTran( Posicione("SX3", 2, cCampo, "X3_CBOX"), "&") )

    If !Empty(cCbox)

        aTemp := StrTokArr(cCbox, ";")

        if (Len(aTemp) > 0)
            For nCti := 1 To Len(aTemp)
                aTemp[nCti] := StrTokArr(aTemp[nCti], "=")
            Next nCti
        
            nI := aScan( aTemp, {|aX| aX[1] == cValue})     //Resgata a informação de campos combo
        
            If nI > 0
                cValor := aTemp[nI][2]
            Else
                cValor := cValue
            Endif
        Endif

    EndIf

    //Limpa o array
    FwFreeObj(aTemp)

Return cValor