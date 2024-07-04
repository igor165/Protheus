#INCLUDE "PROTHEUS.CH" 
#INCLUDE "GTPA290.CH" 
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA290
Rotina responsavel pela workarea do monitor operacional
@type Function
@author jacomo.fernandes
@since 11/07/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Function GTPA290()

Private INCLUI      := .T.
Private cCadastro   := STR0039//"Monitor Operacional"

FWMsgRun(/*oComponent*/, { ||  CreateWorkArea() }, STR0037, STR0038 )		// "Aguarde"		"Carregando Área de Trabalho..."   

Return Nil

//------------------------------------------------------------------------------
/* /{Protheus.doc} CreateWorkArea
Função responsavel pela criação workarea do monitor operacional
@type Function
@author jacomo.fernandes
@since 11/07/2019
@version 1.0
/*/
//------------------------------------------------------------------------------
Static Function CreateWorkArea()
Local oDlgWA        := Nil
Local cMenuItem     := Nil
Local oMenu         := Nil
Local oMenuItem     := Nil
Local oWorkarea     := Nil
Local aSize         := FWGetDialogSize( oMainWnd )

oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0039, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. )    // "Monitor Operacional"

oWorkarea := FWUIWorkArea():New( oDlgWA )
oWorkarea:SetMenuWidth( 200 )

oMenu := FWMenu():New()
oMenu:Init()

    //------------------------------------------------------------------------------------------------------
    //  MENU Operacional 
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0002, "A") //"Operacional"
    oMenuItem := oMenu:GetItem( cMenuItem )

    oMenuItem:AddContent( STR0003	, "E", { || GTPC300(oWorkarea) } )				// "+ Monitor"  
    oMenuItem:AddContent( STR0004	, "E", { || GC300Commit(GC300GetMVC("M")) } )	// "+ Salvar Dados" 
    oMenuItem:AddContent( STR0005	, "E", { || GTPC300A()} )						// "+ Incluir Recurso"
    oMenuItem:AddContent( STR0006	, "E", { || GTPC300B()} )						// "+ Substituir Recurso"
    oMenuItem:AddContent( STR0024	, "E", { || GTPC300M()} )						// "+ Alocação Viagem Espeicial"
    oMenuItem:AddContent( STR0025	, "E", { || GTPC300I()} )						// "+ Remover Recurso"
    oMenuItem:AddContent( STR0026 	, "E", { || GTPC300K()} )						// "+ Confirmar Recurso"
    oMenuItem:AddContent( STR0007	, "E", { || GTPC300C()} )						// "+ Histórico do Monitor"
    oMenuItem:AddContent( STR0020	, "E", { || GTPC300G('1')} )					// "+ Finalizar Viagens"
    oMenuItem:AddContent( STR0021	, "E", { || GTPC300G('2')} )					// "+ Reabrir Viagens Finalizadas"
    oMenuItem:AddContent( STR0040	, "E", { || GTPC300P()} )						// "+ Ocorrências"
    If GYN->(FieldPos("GYN_STSOCR")) > 0 
        oMenuItem:AddContent( STR0041	, "E", { || GTPC300Q()} )						// "+ Finalizar Ocorrências"
    EndIF
    oMenuItem:AddContent( STR0019	, "E", { || GC300ScreenLeg()}) 					// "+ Legenda"
    
    //------------------------------------------------------------------------------------------------------
    //  MENU Consulta
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0027, "A") //"Consulta"
    oMenuItem := oMenu:GetItem( cMenuItem )
	
	oMenuItem:AddContent( STR0028, "E", { ||GTPC300E()} )		// "+ Alocações"  			
    oMenuItem:AddContent( STR0029, "E", { ||GTPC300F()} )		// "+ Recursos" 				
    oMenuItem:AddContent( STR0030, "E", { ||GTPC300J()} )		// "+ Recurso Por Localidade"
    oMenuItem:AddContent( STR0031, "E", { ||GTPC300L()} )		// "+ Veiculo em Manutenção" 
    oMenuItem:AddContent( STR0043, "E", { ||GTPC300T()} )		// "+ Div. de viagens x horários"
    //RADU: PROJETO JCA -DSERGTP-8012
    oMenuItem:AddContent( "+ Viagens com pendências financeiras", "E", { ||GTPC300R()} )		// "+ Div. de viagens x horários"
	
	//------------------------------------------------------------------------------------------------------
    //  MENU MANUTENÇÃO 
    //------------------------------------------------------------------------------------------------------	
	cMenuItem := oMenu:AddFolder(STR0022, "A") //"Painel"
    oMenuItem := oMenu:GetItem( cMenuItem )
    oMenuItem:AddContent( STR0023	, "E", { || GTPC300O() } )		// 'Ajusta KM Realizado'
    
    //------------------------------------------------------------------------------------------------------
    //  MENU PLANEJAMENTO 
    //------------------------------------------------------------------------------------------------------
    cMenuItem := oMenu:AddFolder(STR0032, "A") //"Planejamento"
    oMenuItem := oMenu:GetItem( cMenuItem )

    oMenuItem:AddContent( STR0008	, "E", { || GTPA302() } )		// "+ Escala Colaborador" 
    oMenuItem:AddContent( STR0009	, "E", { || GTPA408() } )		// "+ Escala Veiculo" 	
    oMenuItem:AddContent( STR0010	, "E", { || GTPA303() } )		// "+ Alocação Colaborador"
    oMenuItem:AddContent( STR0033	, "E", { || GA290x313() } )		// "+ Escalas Extraordinárias"
    //------------------------------------------------------------------------------------------------------
    //  Cadastros 
    //------------------------------------------------------------------------------------------------------

    cMenuItem := oMenu:AddFolder(STR0011, "A") //"Painel"
    oMenuItem := oMenu:GetItem( cMenuItem )

    oMenuItem:AddContent( STR0012	, "E", { || GTPA002() } )		// "+ Linhas"
    oMenuItem:AddContent( STR0013	, "E", { || GTPA004() } )		// "+ Horários"
    oMenuItem:AddContent( STR0014	, "E", { || GTPA008() } )		// "+ Colaboradores"
    oMenuItem:AddContent( STR0015	, "E", { || GTPA312() } )		// "+ Esquema de Escala" 
    oMenuItem:AddContent( STR0016	, "E", { || GTPA301() } )		// "+ Grupo de Escala"
	oMenuItem:AddContent( STR0034	, "E", { || GTPC300N() } )		//"+ Recursos Terceiros"	
	oMenuItem:AddContent( STR0035	, "E", { || GTPA316VEI() } )	//"+ Documentos Veículo"	
	oMenuItem:AddContent( STR0036	, "E", { || GTPA316COL() } )	//"+ Documentos Colaboradores"
    oMenuItem:AddContent( STR0042	, "E", { || GTPA902() } )	//"+ Etilômetro" 

oWorkarea:SetMenu( oMenu )

oWorkarea:CreateHorizontalBox( "LINE01" ,aSize[3], .T. )
oWorkarea:SetBoxCols( "LINE01", { "WDGT01" } )

oWorkarea:Activate()

oDlgWA:lEscClose := .F.	
oDlgWA:Activate( , , , , , , EnchoiceBar( oDlgWA, {|| }, { || oDlgWA:End(), GC300Destroy() }, , {}, , , , , .F., .F. ) ) //ativa a janela criando uma enchoicebar

Return

//-----------------------------------------------------------------
/*/{Protheus.doc} GA290x313
(long_description)
@type static function
@author jacomo.fernandes
@since 15/04/2018
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function GA290x313()
Local oViewMonitor	:= GC300GetMVC('V')
Local cFiltDefault	:= ""
Local aArea			:= GetArea()

	GYH->(DbSetOrder(2))//GYH_FILIAL+GYH_USRCOD
	If GYH->(DbSeek(xFilial('GYH')+__cUserId))
		cFiltDefault += '(GQK_RECURS $ "'+GetCodColab()+'" )'
	Endif
	If ValType(oViewMonitor) == 'O' .AND. oViewMonitor:IsActive()
		cFiltDefault += IF(!Empty(cFiltDefault), " .and. " , '')
		Pergunte("GTPC300",.F.)
		
		cFiltDefault += ' (GQK_DTINI >= "'+DtoS(MV_PAR01)+'") '
		cFiltDefault += " .AND. "
		cFiltDefault += ' ("'+DtoS(MV_PAR02)+'" >= GQK_DTINI '
		cFiltDefault += ' .and. "'+DtoS(MV_PAR02)+'" <= GQK_DTFIM ) '
	Endif
	
	GTPA313(cFiltDefault)
RestArea(aArea)
Return
//-----------------------------------------------------------------
/*/{Protheus.doc} GetCodColab
(long_description)
@type function
@author jacomo.fernandes
@since 15/04/2018
@version 1.0
/*/
//-----------------------------------------------------------------
Static Function GetCodColab()
Local cRet			:= ""
Local cTmpAlias		:= GetNextAlias()
Local oViewMonitor	:= GC300GetMVC('V')
Local cInnerGQK		:= "%%"

If ValType(oViewMonitor) == 'O' .AND. oViewMonitor:IsActive()
	Pergunte("GTPC300",.F.)
	cInnerGQK := "%"
	cInnerGQK += " AND "
	cInnerGQK += " (GQK_DTINI >= '"+DtoS(MV_PAR01)+"') "
	cInnerGQK += " AND "
	cInnerGQK += " ('"+DtoS(MV_PAR02)+"' Between GQK_DTINI and GQK_DTFIM ) "
	cInnerGQK += "%"
Endif

BeginSql Alias cTmpAlias
	SELECT
		 DISTINCT GQK_RECURS
	FROM %Table:GYH% GYH
		INNER JOIN %Table:GY2% GY2 ON
			GY2.GY2_FILIAL = GYH.GYH_FILIAL
			AND GY2.GY2_SETOR = GYH_CODIGO
			AND GY2.%NotDel%
		INNER JOIN %Table:GQK% GQK ON
			GQK.GQK_FILIAL = %xFilial:GQK%
			AND GQK.GQK_RECURS = GY2.GY2_CODCOL
			%Exp:cInnerGQK%
			AND GQK.%NotDel%
	WHERE 
		GYH.GYH_FILIAL = %xFilial:GYH%
		AND GYH_USRCOD = %Exp:__cUserId%
		AND GYH.%NotDel%

EndSql

While (cTmpAlias)->(!Eof())
	cRet+= (cTmpAlias)->GQK_RECURS+'|'
	(cTmpAlias)->(DbSkip())
EndDo

(cTmpAlias)->(DbCloseArea())

Return cRet
