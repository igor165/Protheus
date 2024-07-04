#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'LOCACAO.CH'
#INCLUDE 'TECA180.CH'

#DEFINE DF_DISP "2"
#DEFINE DF_SEPA "3"
#DEFINE DF_ALOC "4"
#DEFINE DF_MANU "5"
#DEFINE DF_RESE "6"

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA180
	Função para a consulta de equipamentos
@sample 	TECA180() 
@since		11/03/2013       
@version	P12
/*/
//------------------------------------------------------------------------------
Function TECA180( )

Local lContinua := .F.
Local lResumido := .F.
Local nOpc      := 1

FOPCRADIO( @nOpc,STR0001,STR0002,STR0003,STR0004) //"Atenção" ### "Qual formato de consulta deseja realizar" ### "Resumido" ### "Detalhado" 

lResumido := .F.

If nOpc == 0
	lContinua := .F.
Else
	
	lResumido := ( nOpc == 1 )
	
	// ----------------------------------------
	//  Verifica o tipo da consulta e chama o pergunte correspondente
	If lResumido .And. Pergunte('TECA180A',.T.)
		lContinua := .T.
	ElseIf !lResumido .And. Pergunte('TECA180', .T.) 
		lContinua := .T.
	EndIf
	
	If lContinua
		If lContinua
			MsgRun(STR0018,STR0006,; // 'Tem muito para carregar, mas vale a pena esperar' ### 'Carregando'
					{|| If( lResumido, At180Resum(), At180Detal() ) } )
		EndIf
	EndIf
EndIf
Return lContinua

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180Resum
	Função para criação do browse com os resultados do modelo resumido da consulta
@sample 	At180Resum() 
@since		11/03/2013       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180Resum()

Local lOk          := .F.
Local cQryFiltro   := ""
Local cError       := ''
Local xProd        := At180Parm( mv_par03, mv_par04 )
Local xEquip       := At180Parm( mv_par05, mv_par06 )
Local nCpos        := 0
Local aInfLeg      := { ; // Cor ,  Título,  cExpressao
						{ "RED"   , STR0007 , "AA3_XDISP==0" },;  // "Disponível"
						{ "GREEN" , STR0008 , "AA3_XDISP==1" } ;  // "Com Alocação ou Reserva no período"
						}
Local aCPosBrw    := {}
Local oBrwCons    := Nil
Local oDlg        := Nil
Local cQryAlias   := ""
Local aInteface    := FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.

lOk := At180xResumo( MODO_RET_STRING, @cQryFiltro, @cError, mv_par01, mv_par02, dDataBase, xProd, xEquip)

If lOk

	DEFINE DIALOG oDlg TITLE STR0009 FROM aInteface[1],aInteface[2] TO aInteface[3],aInteface[4] PIXEL  // 'Consulta'

	cQryAlias   := GetNextAlias()
	
	oBrwCons := FWFormBrowse():New() 
	oBrwCons:SetDataQuery(.T.)
	oBrwCons:SetAlias( cQryAlias )
	oBrwCons:SetQuery( cQryFiltro )
	oBrwCons:SetDescription( STR0010 )  // 'Consulta de Equipamentos - Resumo'
	oBrwCons:SetOwner(oDlg)
	oBrwCons:SetUseFilter( .T. )
	oBrwCons:DisableConfig()
	
	oBrwCons:AddButton(STR0011,{|a| oDlg:End() },,,,.F.,1)  // 'Sair'
	oBrwCons:AddButton(STR0019,{|a| At180ViEquip(oBrwCons:cAlias) },,,,.F.,1)  // "Visualizar Equipamento"
	oBrwCons:AddButton(STR0012,{|a| At180CallDet(oBrwCons) },,,,.F.,1)  // 'Visualizar Detalhe'
	oBrwCons:AddButton(STR0026,{|a| At180ViLoc(oBrwCons) },,,,.F.,1)  // "Visualizar Loc. Equip"
	
	aCPosBrw := At180GetSt( 3, .T. )  // carrega dados dos campos para o browse

	// -------------------------------------------
	// Status disponíveis
	For nCpos := 1 To Len(aInfLeg)
		oBrwCons:AddLegend(aInfLeg[nCpos,3],aInfLeg[nCpos,1],aInfLeg[nCpos,2])
	Next
	
	For nCpos := 1 To Len(aCPosBrw)
		oBrwCons:AddColumn( aCPosBrw[nCpos] )
	Next nCpos
	
	oBrwCons:DisableDetails()
	oBrwCons:Activate()
	
	ACTIVATE DIALOG oDlg CENTERED	
	
	oBrwCons:DeActivate()	
	At180CLose( oBrwCons:cAlias )
EndIf

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180Detal
  Rotina que executa a query e cria o browse para o formato de resultado detalhado
@sample 	At180Detal() 
@since		11/03/2013       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180Detal()

Local cQryAlias    := ''
Local cCaptError   := ''
Local oBrwCons     := Nil
Local lOk          := .F.
Local nCpos        := 1
Local aCpos        := {}

Local cFilt		   := ''
Local cPar		   := Alltrim(mv_par13)

Local oDlg         := Nil
Local aInteface    := FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.

Local aProd        := At180Parm( mv_par07, mv_par08 )
Local aEquip       := At180Parm( mv_par03, mv_par04 )
Local aCliLoj      := At180Parm( mv_par09+mv_par10, mv_par11+mv_par12 )
Local aLocais      := At180Parm( mv_par05, mv_par06 )
Local oGSTmpTbl	   := Nil

Local aInfLeg      := { ; // Cor ,  Título,  cExpressao
						{ "YELLOW", STR0022   , "Empty(TEW_CODMV) .And. !Empty(TJ_DTMPFIM) .And. X_DIA > TJ_DTMPFIM" } ,; // "Previsão Disponibilidade"
						{ "RED"   , STR0007   , "Empty(TEW_CODMV)" },;  // "Disponível"
						{ "ORANGE", STR0013   , "TEW_TIPO<>'2' .And. X_DIA >= TEW_DTSEPA .And. ( Empty(TEW_DTRINI) .Or. X_DIA < TEW_DTRINI " + ;  // "Separado"
																								".Or. (Empty(TEW_DTRINI) .And. TFI_PERINI >= dDatabase .And. X_DIA <= TFI_PERINI)" + ;
																								".Or. (Empty(TEW_DTRINI) .And. TFI_PERINI < dDatabase .And. X_DIA <= dDatabase) )" },;
						{ "GREEN" , STR0014   , "TEW_TIPO<>'2' .And. X_DIA >= TEW_DTRINI .And. (X_DIA <= TEW_DTRFIM " + ;  // "Alocado"
																								".Or. (Empty(TEW_DTRFIM) .And. TFI_PERFIM >= dDatabase .And. X_DIA <= TFI_PERFIM ) " + ;
																								".Or. (Empty(TEW_DTRFIM) .And. TFI_PERFIM < dDatabase .And. X_DIA <= dDatabase ) )" } ,;
						{ "BROWN" , STR0015   , "TEW_TIPO<>'2' .And. X_DIA > TEW_DTRFIM .And. AA3_MANPRE=='1' .And. " + ;  // "Manutenção"
																								"(!Empty(TEW_FECHOS) .And. X_DIA <= TEW_FECHOS " + ;
																								".Or. ( Empty(TEW_FECHOS) .And. X_DIA <= dDatabase )"+;
																								".Or. ( Empty(TEW_FECHOS) .And. X_DIA <= TJ_DTMPFIM ))"} ,;
						{ "BLUE"  , STR0016   , "TEW_TIPO=='2'" } ;  // "Reservado"
						}

Local oFiltro := Nil

lOk := At180Query( MODO_RET_TABELA, @cQryAlias, @cCaptError, mv_par01, mv_par02, aEquip/*Equip*/, aLocais/*Local*/,;
		aProd/*Produto*/, aCliLoj/*ClienteLoja*/, mv_par13, dDataBase,  @oGSTmpTbl)

If lOk
	
	DEFINE DIALOG oDlg TITLE STR0009 FROM aInteface[1],aInteface[2] TO aInteface[3],aInteface[4] PIXEL  // 'Consulta'

	oBrwCons := FWFormBrowse():New() 
	oBrwCons:SetDataQuery(.F.)
	oBrwCons:SetDataTable(.T.) 
	oBrwCons:SetAlias( cQryAlias )
	oBrwCons:SetTemporary()
	oBrwCons:SetDescription( STR0017 ) // 'Consulta de Equipamentos - Detalhe'
	oBrwCons:SetOwner(oDlg)
	oBrwCons:SetUseFilter( .T. )
	oBrwCons:DisableConfig()
	
	oBrwCons:AddButton(STR0011,{|a| oDlg:End() },,,,.F.,1)  // 'Sair'
	oBrwCons:AddButton(STR0020,{|a| At180ViRes(oBrwCons:cAlias) },,,,.F.,1)  // "Visualizar Reserva"
	oBrwCons:AddButton(STR0021,{|a| At180ViAloc(oBrwCons:cAlias) },,,,.F.,1)  // "Visualizar Alocação"
	oBrwCons:AddButton(STR0019,{|a| At180ViEquip(oBrwCons:cAlias) },,,,.F.,1)  // "Visualizar Equipamento"
	
	aCpos := At180GetSt( 3 )  // carrega dados dos campos para o browse
	
	If cPar $ DF_DISP //Disponivel
		cFilt := '(' + aInfLeg[val(DF_DISP),3] + ')'
	EndIf

	If cPar $ DF_SEPA //Separado
		cFilt += IIF(!Empty(cFilt),'.OR.','') + '(' + aInfLeg[val(DF_SEPA),3] + ')'
	EndIf

	If cPar $ DF_ALOC //Alocado
		cFilt += IIF(!Empty(cFilt),'.OR.','') + '(' + aInfLeg[val(DF_ALOC),3] + IIF( cPar $ DF_SEPA ,'',') .AND. !(' + aInfLeg[val(DF_SEPA),3] + ')')
	EndIf

	If cPar $ DF_MANU //Manutenção
		cFilt += IIF(!Empty(cFilt),'.OR.','') + '(' + aInfLeg[val(DF_MANU),3] + ')'
	EndIf

	If cPar $ DF_RESE //Reservado
		cFilt += IIF(!Empty(cFilt),'.OR.','') + '(' + aInfLeg[val(DF_RESE),3] + ')'
	EndIf
	
	If !Empty(cFilt)
		oBrwCons:SetFilterDefault(cFilt)
	EndIf
	
	// -------------------------------------------
	// Status disponíveis
	For nCpos := 1 To Len(aInfLeg)
		oBrwCons:AddLegend(aInfLeg[nCpos,3],aInfLeg[nCpos,1],aInfLeg[nCpos,2])
	Next
	
	For nCpos := 1 To Len(aCpos)
		oBrwCons:AddColumn( aCpos[nCpos] )
	Next nCpos
	
	oBrwCons:DisableDetails()
	oBrwCons:Activate()
	
	ACTIVATE DIALOG oDlg CENTERED	
	
	oBrwCons:DeActivate()
	oGSTmpTbl:Close()
	TecDestroy(oGSTmpTbl)

EndIf

Return lOk

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180CallDet
  Chama a rotina para visualização dos detalhes diários de status
@sample 	At180CallDet() 
@since		11/03/2013       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180CallDet(oBrwCons)

Local cTabBrw      := oBrwCons:cAlias
Local dDtIni       := mv_par01
Local dDtFim       := mv_par02

Pergunte('TECA180', .F.)  // carrega os dados do pergunte da janela de detalhe
//----------------------------------------
//  Preenche as variáveis do pergunte de detalhe 
mv_par01 := dDtIni
mv_par02 := dDtFim
mv_par03 := (cTabBrw)->AA3_NUMSER
mv_par04 := (cTabBrw)->AA3_NUMSER
mv_par05 := ''
mv_par06 := ''
mv_par07 := ''
mv_par08 := ''
mv_par09 := ''
mv_par10 := ''
mv_par11 := ''
mv_par12 := ''
//----------------------------------------

MsgRun(STR0018,STR0006,;  // 'Carregando dados, aguarde...' ### 'Carregando' 
					{|| At180Detal() } )// chama a rotina do detalhe
  

Pergunte('TECA180A',.F.)  // recarrega os dados do pergunte da tela de resumo

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180ViRes
  Visualização de Reservas
@sample 	At180ViRes() 
@since		11/03/2013       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180ViRes(cArqTemp)

Local aSave     := GetArea()
Local aSaveTFI  := TFI->( GetArea() )

DbSelectArea('TFI')
TFI->( DbSetOrder( 6 ) ) // TFI_FILIAL+TFI_RESERV

If (cArqTemp)->TEW_TIPO == '2' .And. ;
	!Empty((cArqTemp)->TEW_RESCOD) .And. ;
	TFI->( Dbseek( xFilial('TFI')+(cArqTemp)->TEW_RESCOD ) )
	
		FWExecView( STR0020,'VIEWDEF.TECA825C', MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // "Visualizar Reservas" 
										{||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ )
EndIf

RestArea(aSaveTFI)
RestArea(aSave)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180ViAloc
  Visualização de Alocações 
@sample 	At180ViAloc() 
@since		11/03/2013       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180ViAloc(cArqTemp)

Local aSave     := GetArea()
Local aSaveTEW  := TEW->( GetArea() )

DbSelectArea('TEW')
TEW->( DbSetOrder( 1 ) ) // TEW_FILIAL+TEW_CODMV

If (cArqTemp)->TEW_TIPO == '1' .And. ;
	TEW->( DbSeek( xFilial('TEW')+(cArqTemp)->TEW_CODMV ) )

		FWExecView( STR0021,'VIEWDEF.TECA800', MODEL_OPERATION_VIEW, /*oDlg*/, {||.T.} /*bCloseOk*/, ;  // "Visualizar Alocação" 
										{||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/ )

EndIf

RestArea(aSaveTEW)
RestArea(aSave)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180ViEquip
  Visualização de Equipamentos 
@sample 	At180ViEquip() 
@since		11/03/2013       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180ViEquip(cArqTemp)

Local aSave     := GetArea()
Local aSaveAA3  := AA3->( GetArea() )

Local lBkpInclui := Nil
Local lBkpAltera := Nil

DbSelectArea('AA3')
AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER

If AA3->( DbSeek( xFilial('AA3')+(cArqTemp)->AA3_NUMSER ) )
	lBkpInclui := If( Type('Inclui')<>'L', Nil, Inclui )
	lBkpAltera := If( Type('Altera')<>'L', Nil, Altera )
	
	Inclui := .F.
	Altera := .F.
	At040Visua('AA3',AA3->(Recno()),2)
	
	Inclui := lBkpInclui
	Altera := lBkpAltera
EndIf

RestArea(aSaveAA3)
RestArea(aSave)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180ViLoc
 	Visualização das locações de equipamentos.
@sample 	At180ViLoc() 
@since		28/04/2016       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180ViLoc(oBrwCons)
Local cTabBrw	:= oBrwCons:cAlias

MsgRun(STR0018,STR0006,;  // "Carregando dados, aguarde..." ### "Carregando" 
					{|| At180LcEqp((cTabBrw)->AA3_NUMSER,MV_PAR01,MV_PAR02)} )// chama a rotina do detalhe

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At180LcEqp
	Rotina que executa a query e cria o browse para a locações de equipamentos.
@sample 	At180LcEqp() 
@since		28/04/2016       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At180LcEqp(cNumSer,dDtDe,dDtAte)
Local cQryLoc 	   := ""
Local oBrwLoc      := Nil
Local lOk          := .F.
Local nCpos        := 0
Local aCpos        := {}
Local oDlgLoc      := Nil
Local aInteface    := FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local oGSTmpTbl	   := Nil
Default cNumSer    := ""
Default dDtDe	   := Stod("")
Default dDtAte	   := Stod("")


lOk := At180QryLc(@cQryLoc,cNumSer,dDtDe,dDtAte,@oGSTmpTbl)

If lOk
	
	DEFINE DIALOG oDlgLoc TITLE STR0009 FROM aInteface[1],aInteface[2] TO aInteface[3],aInteface[4] PIXEL  // "Consulta"

	oBrwLoc := FWFormBrowse():New() 
	oBrwLoc:SetDataQuery(.F.)
	oBrwLoc:SetDataTable(.T.)
	oBrwLoc:SetAlias( cQryLoc )
	oBrwLoc:SetTemporary()
	oBrwLoc:SetDescription( STR0023 ) // "Visualizar Locação de Equipamentos"
	oBrwLoc:SetOwner(oDlgLoc)
	oBrwLoc:SetUseFilter( .T. )
	oBrwLoc:DisableConfig()
	
	oBrwLoc:AddButton(STR0011,{|a| oDlgLoc:End() },,,,.F.,1)  // "Sair"
	
	aCpos := At180Stru(2) // carrega dados dos campos para o browse

	For nCpos := 1 To Len(aCpos)
		oBrwLoc:AddColumn( aCpos[nCpos] )
	Next nCpos
	
	oBrwLoc:DisableDetails()
	oBrwLoc:Activate()
	
	ACTIVATE DIALOG oDlgLoc CENTERED
	
	oBrwLoc:DeActivate()	
	oGSTmpTbl:Close()
	TecDestroy(oGSTmpTbl)
Else
	Help(,, "At180LcEqp",,STR0024,1,0,,,,,,{STR0025}) //"Não existe locação para o equipamento posicionado." ## "Posicione em um equipamento que existe locação."
EndIf

Return lOk
