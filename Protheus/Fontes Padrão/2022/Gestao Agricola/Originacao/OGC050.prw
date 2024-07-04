#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TOTVS.CH"
#include 'OGC050.ch'

/*{Protheus.doc} OGC050
Exibe as Fixações de Componente e de Preço para Determinado Contrato
@author jean.schulze
@since 12/10/2017
@version undefined
@param pcFilial, , descricao
@param pcCodCtr, , descricao
@param pcCodCad, , descricao
@type function
*/
Function OGC050(pcFilial, pcCodCtr, pcCodCad, pcCodNgc, pcVersao)
	Local aArea		  := GetArea()
	Local aCoors      := FWGetDialogSize( oMainWnd )
	Local oSize       := {}
	Local oFWL        := ""
	Local oDlg		  := Nil
	Local oPnl1       := Nil
	Local oPnlWnd1    := Nil
	Local oPnlWnd2	  := Nil 
	Local aButtons    := {}
	Local cFiltroN7C  := ""
	Local cFiltroNN8  := ""
	
	Local oBrowse1  := Nil
	Local oBrowse2	 := Nil
	
	Default pcFilial := ""
	Default pcCodCtr := ""
	Default pcCodCad := ""
	Default pcCodNgc := ""
	Default pcVersao := ""

	//tamanho da tela principal
	oSize := FWDefSize():New(.t.) //considerar o enchoice
	oSize:AddObject('DLG',100,100,.T.,.T.)
	oSize:SetWindowSize(aCoors)
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()
	
	oDlg := MsDialog():New(  oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .t. ) //Consulta Blocos e Fardos
	
	oPnl1:= tPanel():New(oSize:aPosObj[1,1],oSize:aPosObj[1,2],,oDlg,,,,,,oSize:aPosObj[1,4],oSize:aPosObj[1,3] -30)
        
	// Instancia o layer
	oFWL := FWLayer():New()

	// Inicia o Layer
	oFWL:init( oPnl1, .F. )
	
	// Cria as divisões horizontais
	oFWL:addLine('TOP'   , 50, .F.)
	oFWL:addLine('BOTTOM', 50, .F.)
	oFWL:addCollumn( 'CENTRAL-TOP', 100,.F., 'TOP' )
	oFWL:addCollumn( 'CENTRAL-BOT', 100,.F., 'BOTTOM' )
			
	//cria as janelas
	oFWL:addWindow( 'CENTRAL-TOP', 'Wnd1', STR0002,  100 /*tamanho*/, .F., .T.,, 'TOP' )
	oFWL:addWindow( 'CENTRAL-BOT', 'Wnd2', STR0003,  100 /*tamanho*/, .F., .T.,, 'BOTTOM' )
		
	// Recupera os Paineis das divisões do Layer
	oPnlWnd1:= oFWL:getWinPanel( 'CENTRAL-TOP' , 'Wnd1', 'TOP' )
	oPnlWnd2:= oFWL:getWinPanel( 'CENTRAL-BOT', 'Wnd2', 'BOTTOM' )
	
		
	/****************** Fixações de Componente ********************************/
	cFiltroN7C := fGetFiltN7C(pcFilial, pcCodCtr, pcCodCad, pcCodNgc, pcVersao)

	//adicionando os widgets de tela
	oBrowse1 := FWMBrowse():New()    
    oBrowse1:SetAlias("N7C")
    oBrowse1:DisableDetails()
    oBrowse1:SetMenuDef( "" )    
    oBrowse1:DisableReport(.T.) 
    oBrowse1:SetProfileID("OGC050N7C")
    oBrowse1:SetFilterDefault( cFiltroN7C )
    oBrowse1:SetDoubleClick({||  OGC050VIEW(N7C->N7C_CODNGC, N7C->N7C_VERSAO) }) 
	
    //legenda
    oBrowse1:AddLegend("N7C_TPCALC == 'C'", OGX700LEG('C'),OGX700DLGC('C')) 
	oBrowse1:AddLegend("N7C_TPCALC == 'P'", OGX700LEG('P'),OGX700DLGC('P')) 
	oBrowse1:AddLegend("N7C_TPCALC == 'I'", OGX700LEG('I'),OGX700DLGC('I')) 
	oBrowse1:AddLegend("N7C_TPCALC == 'T'", OGX700LEG('T'),OGX700DLGC('T')) 
	oBrowse1:AddLegend("N7C_TPCALC == 'M'", OGX700LEG('M'),OGX700DLGC('M')) 
	oBrowse1:AddLegend("N7C_TPCALC == 'R'", OGX700LEG('R'),OGX700DLGC('R')) 
	
    oBrowse1:Activate(oPnlWnd1)   

	
	/****************** Fixações de Preço ********************************/
	cFiltroNN8 := fGetFiltNN8(pcFilial, pcCodCtr, pcCodCad, pcCodNgc, pcVersao)

	oBrowse2 := FWMBrowse():New()
    oBrowse2:DisableReport(.T.) 
    oBrowse2:DisableDetails()
    oBrowse2:SetAlias("NN8")
    oBrowse2:SetMenuDef( "" )
    oBrowse2:DisableReport(.T.) 
    oBrowse2:SetProfileID("OGC050NN8") 
    oBrowse2:SetFilterDefault(cFiltroNN8)
    oBrowse2:SetDoubleClick({|| OGC050VFIX()})
    
    //legenda			
	oBrowse2:AddLegend( "NN8_QTDFIX >  NN8_QTDENT  .AND. NN8_QTDAGL == 0 ", "GREEN", STR0006) 	//Fixação com Saldo à Entregar
	oBrowse2:AddLegend( "NN8_QTDFIX <= NN8_QTDENT  .AND. NN8_QTDENT  > 0 ", "GRAY", STR0007) 	//Fixação Entregue
	oBrowse2:AddLegend( "NN8_QTDFIX == 0 .AND. NN8_QTDAGL  > 0 ", "BLUE", STR0010)				//Aglutinada
	oBrowse2:AddLegend( "NN8_QTDFIX == 0 .AND. NN8_QTDAGL == 0 ", "BR_CANCEL", STR0011)		//Cancelada
    
	oBrowse2:Activate(oPnlWnd2)
    
    //cria os botões adicionais
    Aadd( aButtons, {STR0008, {|| OGC050VIEW(N7C->N7C_CODNGC, N7C->N7C_VERSAO)}, STR0008, STR0008, {|| .T.}} )     		
    Aadd( aButtons, {STR0009, {|| OGC050VFIX()}, STR0009, STR0009, {|| .T.}} )     		
            
	oDlg:Activate( , , , .t., , ,  EnchoiceBar(oDlg, , {||  oDlg:End() } /*Fechar*/,,@aButtons,,,.f.,.f.,.f.,.f.,.f.) ) //ativa a tela
	
	N7C->( dbCloseArea() )
	NN8->( dbCloseArea() )
	
	RestArea(aArea)	
return .t.

/*/{Protheus.doc} fGetFiltN7C
Cria o filtro dos dados da grid de fixação de componentes
@type function
@version  P12
@author claudineia.reinert
@since 24/09/2021
@param pcFilial, variant, filial do contrato
@param pcCodCtr, variant, codigo do contrato
@param pcCodCad, variant, cadencia
@param pcCodNgc, variant, codigo do negocio
@param pcVersao, variant, versaõ do negocio
@return variant, String com o filtro 
/*/
Static Function fGetFiltN7C(pcFilial, pcCodCtr, pcCodCad, pcCodNgc, pcVersao)
	Local cFiltro := ""
	Local cQuery 	:= ""
	Local cAliasQry := GetNextAlias()
	Local cFiltNGC := ""

	cQuery := " SELECT N7M_CODNGC, N7M_VERSAO,  N7M_CODCAD "
	cQuery += "   FROM " + RetSqlName('N7M') + " N7M "
	cQuery += "  WHERE N7M_FILIAL = '"+pcFilial + "' AND N7M_CODCTR = '"+pcCodCtr+"' "
	If !Empty(pcCodCad)
		cQuery += " AND N7M_CODCAD = '"+pcCodCad+"' "
	EndIf
	If !Empty(pcCodNgc)
		cQuery += " AND N7M_CODNGC = '"+pcCodNgc+"' "
	EndIf
	If !Empty(pcVersao)
		cQuery += " AND N7M_VERSAO = '"+pcVersao+"' "
	EndIf
	
	If IsInCallStack("OGA290") .OR. IsInCallStack("OGA280") //via contrato
		//FILTRA SOMENTE PELOS COMPONENTES FIXADOS, NÃO TRAZ OS CANCELADOS 
		cQuery += "    AND N7M_QTDFIX > 0 AND N7M_QTDALO > 0 "
	EndIf
	cQuery += "    AND N7M.D_E_L_E_T_  = ' ' "
	cQuery += "    GROUP BY N7M_CODNGC, N7M_VERSAO, N7M_CODCAD  "
	cQuery := ChangeQuery( cQuery )	
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	dbSelectArea(cAliasQry)
	(cAliasQry)->(dbGoTop())
	While (cAliasQry)->(!Eof())
		
		If !Empty(cFiltNGC) //ja foi atribuido valor e tem mais de um negocio ou versao, se a fixar pode ter mais fixações
			cFiltNGC += " .OR. "
		EndIf
		cFiltNGC += "( N7C_CODNGC = '"+ (cAliasQry)->(N7M_CODNGC) +"' .AND. N7C_VERSAO = '"+ (cAliasQry)->(N7M_VERSAO) +"' .AND. N7C_CODCAD = '"+ (cAliasQry)->(N7M_CODCAD) +"'  ) "
		(cAliasQry)->(dbSkip())
	EndDo
	(cAliasQry)->(dbCloseArea())

	If !Empty(cFiltNGC) 
		cFiltro := " N7C_FILIAL = '"+pcFilial + "' .AND. ( "+ cFiltNGC +" ) "
	Else 
		DbSelectArea("N79")
		N79->(DbSetOrder(1))		
		If N79->(DbSeek(xFilial("N79")+pcCodNgc+pcVersao))
			cTipoNGC := N79->N79_TIPO 
		endif

		If cTipoNGC == "1" .OR. IsInCallStack("OGA290") .OR. IsInCallStack("OGA280") //via contrato
			//se não encontrou dados na consulta retorna filtro com dados vazio para não mostrar nada na tela
			cFiltro := " N7C_FILIAL = '' .AND. N7C_CODNGC = '' .AND. N7C_VERSAO = '' .AND. N7C_CODCAD = '' "
		Else
			cFiltro := " N7C_FILIAL = '"+pcFilial + "' .AND. N7C_CODNGC = '"+pcCodNgc+"' .AND. N7C_CODCAD = '"+pcCodCad+"' .AND. N7C_VERSAO = '"+pcVersao+"' " //valor padrão
		EndIf
	
	EndIF

Return cFiltro

/*/{Protheus.doc} fGetFiltNN8
Cria o filtro dos dados da grid de fixação de preço
@type function
@version  P12
@author claudineia.reinert
@since 24/09/2021
@param pcFilial, variant, filial do contrato
@param pcCodCtr, variant, codigo do contrato
@param pcCodCad, variant, cadencia
@param pcCodNgc, variant, codigo do negocio
@param pcVersao, variant, versaõ do negocio
@return variant, String com o filtro 
/*/
Static Function fGetFiltNN8(pcFilial, pcCodCtr, pcCodCad, pcCodNgc, pcVersao)
	Local cFiltro := ""

	cFiltro := "NN8_FILIAL = '"+pcFilial+"' .AND. NN8_CODCTR = '"+pcCodCtr+"' " + IIF(!Empty(pcCodNGC)," .AND. NN8_CODNGC = '"+pcCodNGC+"' ","") + IIF(!empty(pcCodCad), " .AND. NN8_CODCAD = '"+pcCodCad+"'", "") 

	If IsInCallStack("OGA290") .OR. IsInCallStack("OGA280") //via contrato
		//não traz as fixações conceladas, sem saldo de fixação
		cFiltro += " .AND. (NN8_QTDFIX > 0 .OR. NN8_QTDAGL > 0) " 
	EndIf


Return cFiltro

/*{Protheus.doc} OGC050VIEW
Função para visualizar o registro de negócio
@author jean.schulze
@since 12/10/2017
@version undefined
@param cCodNgc, characters, descricao
@param cVersao, characters, descricao
@type function
*/
Static Function OGC050VIEW(cCodNgc, cVersao)
	
	DbSelectArea("N79")
	DbSetOrder(1)
	
	If DbSeek(xFilial("N79")+cCodNgc+cVersao)
		OGA700VISU() // função de visualização do OGA700
	endif
	
return .t.

/*{Protheus.doc} OGC050VFIX
Função para validar a versão da fixação para visualizar o negocio
@author claudineia.reinert
@since 22/09/2021
@version p12
@type function
*/
Static Function OGC050VFIX()
	Local cVersao := NN8->NN8_VERSAO //VERSAO PADRÃO A QUE ESTA POSICIONADA

	If NN8->NN8_QTDFIX = 0 .AND. NN8->NN8_QTDAGL = 0 //SE FIXAÇÃO CANCELADA 
		cVersao := PadR(alltrim(str(OGX700N79S(xFilial("N79"), NN8->NN8_CODNGC))),TamSX3("N79_VERSAO")[1], " ") //BUSCA ULTIMA VERSÃO DO REGISTRO DE NEGOCIO
	EndIf 
	
	OGC050VIEW(NN8->NN8_CODNGC, cVersao)
	
return .T.



