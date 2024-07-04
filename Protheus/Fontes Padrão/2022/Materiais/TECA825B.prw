#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'LOCACAO.CH'
#INCLUDE 'TECA825B.CH'
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Definição do modelo de dados para a criação de movimento a movimento de reserva
na tabela TEW
@sample 	ModelDef()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel   := Nil
Local oStr1    := FWFormStruct(1,'TEW')

oModel := MPFormModel():New('TECA825B')
oModel:SetDescription(STR0001)  // 'Reserva de Equipamentos'

oStr1:SetProperty('TEW_ORCSER',MODEL_FIELD_OBRIGAT,.F.)
oStr1:SetProperty('TEW_CODEQU',MODEL_FIELD_OBRIGAT,.F.)
oStr1:SetProperty('TEW_RESCOD',MODEL_FIELD_OBRIGAT,.T.)

oStr1:SetProperty('TEW_TIPO',MODEL_FIELD_INIT,{||'2'})

oModel:AddFields('MAIN',,oStr1)
oModel:GetModel('MAIN'):SetDescription(STR0002)  // 'Reserva'

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825AtuOp
	Atualiza as reservas vinculadas após a finalização de uma oportunidade de venda
@sample 	At825AtuOp()
@since		11/03/2014       
@version	P12
@param		oMVCAD1, Objeto, objeto do modelo da oportunidade de venda
/*/
//------------------------------------------------------------------------------
Function At825AtuOp( oMVCAD1 )

Local lHasSucess     := ( oMVCAD1:GetValue("AD1_STATUS") == '9' )
Local cTabDadosAtu   := At825QryLoc( oMVCAD1:GetValue("AD1_NROPOR"), oMVCAD1:GetValue("AD1_REVISA"), If( lHasSucess, oMVCAD1:GetValue("AD1_PROPOS"), '' ) )
Local oMdlReserva    := FwLoadModel('TECA825C')
Local lGravacao      := .T.

Local aSave          := GetArea()
Local aSaveTFI       := TFI->( GetArea() )
Local aSaveTEW       := TEW->( GetArea() )

DbSelectArea('TFI')

DbSelectArea('TEW')

While (cTabDadosAtu)->(!EOF() )

	If (cTabDadosAtu)->STATUS == 0
		
		TFI->( DbSetOrder( 1 ) ) // TFI_FILIAL+TFI_COD
		TEW->( DbSetOrder( 13 ) ) // TEW_FILIAL+TEW_RESCOD
		
		lGravacao := .T.
		oMdlReserva:SetOperation(MODEL_OPERATION_UPDATE)
		
		If TFI->( DbSeek( xFilial('TFI')+(cTabDadosAtu)->TFI_COD ) ) .And. ;
			TEW->( DbSeek( xFilial('TEW')+(cTabDadosAtu)->TFI_RESERV ) )
			
			// adiciona os dados que serão utilizados para a gravação das informações
			At825CText( STR0003 )  // 'Finalização da oportunidade'
			At825CTipo( DEF_RES_CANCELADA )
			
			lGravacao := oMdlReserva:Activate()
			lGravacao := oMdlReserva:VldData()
			lGravacao := oMdlReserva:CommitData()
			
			If lGravacao
				oMdlReserva:CancelData()
			EndIf
			
			oMdlReserva:DeActivate()
			
		EndIf
		
	EndIf

	(cTabDadosAtu)->( DbSkip() )
End

oMdlReserva:Destroy()

RestArea(aSaveTEW)
RestArea(aSaveTFI)
RestArea(aSave)

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825QryLoc
	Realiza a consulta aos itens de locação com reserva associada
@sample 	At825QryLoc()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At825QryLoc( cOpVe, cOpRev, cProp, lPropWhere )

Local cQryTab    := ''
Local cWhereProp := '%%'
Local aSave      := GetArea()
Local aSaveAD1   := AD1->( GetArea() )
Local aSaveADY   := ADY->( GetArea() )
Local aSaveTFJ   := TFJ->( GetArea() )
Local aSaveTFL   := TFL->( GetArea() )
Local aSaveTFI   := TFI->( GetArea() )

DEFAULT cOpVe    := ''
DEFAULT cOpVe    := ''
DEFAULT cProp    := ''
DEFAULT lPropWhere    := .F.

If !Empty(cOpVe) .And. !Empty(cOpVe)

	If lPropWhere
		cWhereProp := "% AND ADY.ADY_PROPOS = '"+cProp+"' %"
	EndIf

	cQryTab := GetNextAlias()
	
	BeginSql Alias cQryTab
	
		SELECT 
			ADY.ADY_OPORTU
			, ADY.ADY_REVISA
			, ADY.ADY_PROPOS
			, ADY.ADY_PREVIS
			, TFI.TFI_COD
			, TFI.TFI_PRODUT
			, TFI.TFI_QTDVEN
			, TFI.TFI_RESERV
			, ( CASE WHEN ADY.ADY_PROPOS = %Exp:cProp%
				THEN 1
				ELSE 0 END ) STATUS
		FROM %Table:ADY% ADY
			INNER JOIN %Table:TFJ% TFJ ON TFJ.TFJ_FILIAL = %xFilial:TFJ% AND TFJ.TFJ_PROPOS = ADY.ADY_PROPOS AND TFJ.TFJ_PREVIS = ADY.ADY_PREVIS
					AND TFJ.%NotDel%
			INNER JOIN %Table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL% AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO AND TFL.%NotDel%
			INNER JOIN %Table:TFI% TFI ON TFI.TFI_FILIAL = %xFilial:TFI% AND TFI.TFI_CODPAI = TFL.TFL_CODIGO AND TFI.%NotDel%
					AND TFI.TFI_RESERV <> ' '
		WHERE 
			ADY.ADY_FILIAL = %xFilial:ADY% AND ADY.ADY_OPORTU = %Exp:cOpVe% AND ADY.ADY_REVISA = %Exp:cOpRev% AND ADY.%NotDel%
			%Exp:cWhereProp%
	EndSql
EndIf

RestArea( aSaveTFI )
RestArea( aSaveTFL )
RestArea( aSaveTFJ )
RestArea( aSaveADY )
RestArea( aSaveAD1 )
RestArea( aSave )

Return cQryTab

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825Ctr
	Atualiza as reservas na finalização da geração do contrato 
@sample 	At825Ctr()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At825Ctr(lParOrcSim,cCodTFJ)

Local cTabDadosAtu   := ''
Local oMdlReserva    := FwLoadModel('TECA825C')
Local lGravacao      := .T.

Local aSave          := GetArea()
Local aSaveTFI       := TFI->( GetArea() )
Local aSaveTEW       := TEW->( GetArea() )
Local lVersion23	:= HasOrcSimp()

If lVersion23
	Default lParOrcSim	:= SuperGetMv("MV_ORCSIMP",,'2') == '1'
	Default cCodTFJ		:= TFJ->TFJ_CODIGO
EndIf

If lVersion23
	If !lParOrcSim
		cTabDadosAtu := At825QryLoc( ADY->ADY_OPORTU, ADY->ADY_REVISA, ADY->ADY_PROPOS, .T. ) // Filtra por oportunidade
	Else	
		cTabDadosAtu := At825QryOSm(cCodTFJ)	// Filtra por Orçamento Simplificado
	EndIf
Else
	cTabDadosAtu := At825QryLoc( ADY->ADY_OPORTU, ADY->ADY_REVISA, ADY->ADY_PROPOS, .T. ) // Filtra por oportunidade
EndIf

DbSelectArea('TFI')
DbSelectArea('TEW')

While (cTabDadosAtu)->(!EOF() )

	If (cTabDadosAtu)->STATUS == 1
		
		TFI->( DbSetOrder( 1 ) ) // TFI_FILIAL+TFI_COD
		TEW->( DbSetOrder( 13 ) ) // TEW_FILIAL+TEW_RESCOD
		
		lGravacao := .T.
		oMdlReserva:SetOperation(MODEL_OPERATION_UPDATE)
		
		If TFI->( DbSeek( xFilial('TFI')+(cTabDadosAtu)->TFI_COD ) ) .And. ;
			TEW->( DbSeek( xFilial('TEW')+(cTabDadosAtu)->TFI_RESERV ) )
			
			// adiciona os dados que serão utilizados para a gravação das informações
			At825CText( STR0004 ) // 'Geração do contrato'
			At825CTipo( DEF_RES_EFETIVADA )
			
			lGravacao := oMdlReserva:Activate()
			lGravacao := oMdlReserva:VldData()
			lGravacao := oMdlReserva:CommitData()
			
			If lGravacao
				oMdlReserva:CancelData()
			EndIf
			
			oMdlReserva:DeActivate()
			
		EndIf
		
	EndIf

	(cTabDadosAtu)->( DbSkip() )
End

oMdlReserva:Destroy()

(cTabDadosAtu)->(DBCloseArea())

RestArea(aSaveTEW)
RestArea(aSaveTFI)
RestArea(aSave)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825BEnc
	Executa o cancelamento das reservas vencidas  
@sample 	At825BEnc()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At825BEnc( cAlias, nReg, nOpc )

Local cTabQry    := ''
Local oBrwResult := Nil
Local cQryAlias  := Nil
Local oDlg       := Nil
Local aInfos	 := FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local aCpos      := {}
Local nX         := 0

If Pergunte('TEC825A',.T.) .And. !Empty( mv_par01 )
	
	cTabQry   := At825BQryProc( .F. )
	cQryAlias := GetNextAlias()
	aCpos     := AtGetCpos()
	
	DEFINE DIALOG oDlg TITLE STR0005 FROM aInfos[1],aInfos[2] TO aInfos[3],aInfos[4] PIXEL  // 'Encerramento de Reservas'
	
	oBrwResult := FWFormBrowse():New() 
	oBrwResult:SetDataQuery(.T.)
	oBrwResult:SetAlias( cQryAlias )
	oBrwResult:SetQuery( cTabQry )
	oBrwResult:SetDescription( STR0005 ) // 'Encerramento de Reservas'
	oBrwResult:SetOwner( oDlg )

	For nX := 1 To Len(aCpos)
		oBrwResult:AddColumn( aCpos[nX] )
	Next nCpos
	
	oBrwResult:AddButton(STR0006,{|a| oDlg:End() },,,,.F.,1) // 'Sair'
	oBrwResult:AddButton(STR0007,{|a| At825BGrEnc(oBrwResult), oDlg:End() },,,,.F.,1)  // 'Prosseguir'
	
	oBrwResult:DisableDetails()
	oBrwResult:Activate()
	
	ACTIVATE DIALOG oDlg CENTERED
	
	oBrwResult:DeActivate()
	
EndIf

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825BFor
	Força o cancelamento de todas as reservas contidas no filtro
somente as reserva com o motivo igual a Reserva são afetadas (TEW_MOTIVO == DEF_RESERVA )  
@sample 	At825BFor()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------ 
Function At825BFor( cAlias, nReg, nOpc )

Local cTabQry    := ''
Local oBrwResult := Nil
Local cQryAlias  := Nil
Local oDlg       := Nil
Local aInfos	 := FWGetDialogSize( oMainWnd ) 	// Array com tamanho da janela.
Local aCpos      := {}
Local nX         := 0

If Pergunte('TEC825B',.T.) .And. !Empty( mv_par01 ) .And. !Empty( mv_par02 )

	cTabQry   := At825BQryProc( .T. )
	cQryAlias := GetNextAlias()
	aCpos     := AtGetCpos()
	
	DEFINE DIALOG oDlg TITLE STR0008 FROM aInfos[1],aInfos[2] TO aInfos[3],aInfos[4] PIXEL  // 'Liberação Forçada de Reservas'
	
	oBrwResult := FWFormBrowse():New() 
	oBrwResult:SetDataQuery(.T.)
	oBrwResult:SetAlias( cQryAlias )
	oBrwResult:SetQuery( cTabQry )
	oBrwResult:SetDescription( STR0008 )  // 'Liberação Forçada de Reservas'
	oBrwResult:SetOwner( oDlg )

	For nX := 1 To Len(aCpos)
		oBrwResult:AddColumn( aCpos[nX] )
	Next nCpos
	
	oBrwResult:AddButton(STR0006,{|a| oDlg:End() },,,,.F.,1)  // 'Sair'
	oBrwResult:AddButton(STR0007,{|a| At825BGrFor(oBrwResult), oDlg:End() },,,,.F.,1)  // 'Prosseguir
	
	oBrwResult:DisableDetails()
	oBrwResult:Activate()
	
	ACTIVATE DIALOG oDlg CENTERED
	
	oBrwResult:DeActivate()

EndIf

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825BQryProc
	Filtra os dados para realizar os cancelamentos via processamento  
@sample 	At825BQryProc()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------ 
Function At825BQryProc( lForcado )

Local cQryTemp     	:= ""
Local cFiltProd    	:= ""
Local cFiltCliLoj  	:= ""
Local cFiltEquip   	:= ""
Local cFiltDtRef   	:= ""
Local nX			:= 0
Local aStruct		:= {}
Local cCmpQry		:= ""

DEFAULT lForcado   := .T.

If lForcado
	//--------------------------------------------
	//  constrói as condições conforme o preenchimento 
	// do Pergunte quando chamado o processamento de 
	// cancelamento dos itens já vencidos
	If !Empty( mv_par01 ) .And. !Empty( mv_par02 )
		
		If mv_par01 == mv_par02
			cFiltDtRef := "AND TEW.TEW_DTRFIM = '"+DTOS(mv_par01)+"' "
		Else
			cFiltDtRef := "AND TEW.TEW_DTRFIM BETWEEN '"+DTOS(mv_par01)+"' AND '"+DTOS(mv_par02)+"' "
		EndIf
		
	EndIf
	
	If !Empty( mv_par03 )
		cFiltProd := "AND TEW.TEW_PRODUT = '"+mv_par03+"' "
	EndIf
	
	If !Empty(mv_par04) .And.  !Empty(mv_par05)
		cFiltCliLoj := " AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT = '"+mv_par04+"'+ AND TFJ.TFJ_LOJA = '"+mv_par05+"' "
	EndIf
	
	If !Empty(mv_par06) .And.  !Empty(mv_par07)
		
		If mv_par06 == mv_par07
			cFiltEquip := "AND TEW.TEW_BAATD = '"+mv_par06+"' "
		Else
			cFiltEquip := "AND TEW.TEW_BAATD BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
		EndIf
		
	EndIf
	
	//Carrega os campos da tabela TEW
	aStruct := TxStrAlias("TEW")
	For nX := 1 To Len(aStruct)
		If nX <> 1
			cCmpQry += ' , '
		EndIf
		cCmpQry += "TEW." + aStruct[nX][1]
	Next nX
	
	//--------------------------------------------
	//  constrói as condições conforme o preenchimento 
	// do Pergunte quando chamado o processamento de 
	// cancelamento será forçado considerando o final 
	// entre períodos
	cQryTemp += "SELECT "
	cQryTemp +=     cCmpQry 
	cQryTemp += 	",TFJ_ENTIDA"
	cQryTemp += 	",TFJ_CODENT"
	cQryTemp += 	",TFJ_LOJA "
	cQryTemp += 	",A1_NOME "
	cQryTemp += "FROM "
	cQryTemp += 	RetSqlName("TEW") + " TEW "
	cQryTemp += 	"INNER JOIN "+RetSqlName("TFI")+" TFI ON TFI.TFI_FILIAL = '"+xFilial("TFI")+"' AND TFI.TFI_RESERV = TEW.TEW_RESCOD "
	cQryTemp += 	"INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL.TFL_FILIAL = '"+xFilial("TFL")+"' AND TFL.TFL_CODIGO = TFI.TFI_CODPAI "
	cQryTemp += 	"INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial("TFJ")+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQryTemp +=     "LEFT JOIN "+RetSqlName("SA1")+" SA1  ON SA1.A1_FILIAL =  '"+xFilial("SA1")+"' AND SA1.A1_COD = TFJ.TFJ_CODENT "
	cQryTemp +=     	"AND SA1.A1_LOJA = TFJ.TFJ_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQryTemp += "WHERE "
	cQryTemp += 	"TEW.TEW_FILIAL = '"+xFilial("TEW")+"' AND TEW.D_E_L_E_T_ = ' ' AND TEW.TEW_TIPO = '2' AND TEW.TEW_MOTIVO = '5' "
	cQryTemp += 	cFiltDtRef  
	cQryTemp += 	cFiltProd
	cQryTemp += 	cFiltEquip
	
Else
	
	If !Empty( mv_par01 )
		cFiltDtRef := "AND TEW.TEW_DTRFIM <= '"+DTOS(mv_par01)+"' "
	EndIf
	
	If !Empty( mv_par02 )
		cFiltProd := "AND TEW.TEW_PRODUT = '"+mv_par02+"' "
	EndIf
	
	If !Empty(mv_par03) .And.  !Empty(mv_par04)
		cFiltCliLoj := " AND TFJ.TFJ_ENTIDA = '1' AND TFJ.TFJ_CODENT = '"+mv_par03+"'+ AND TFJ.TFJ_LOJA = '"+mv_par04+"' "
	EndIf
	
	If !Empty(mv_par05) .And.  !Empty(mv_par06)
		
		If mv_par05 == mv_par06
			cFiltEquip := "AND TEW.TEW_BAATD = '"+mv_par05+"' "
		Else
			cFiltEquip := "AND TEW.TEW_BAATD BETWEEN '"+mv_par05+"' AND '"+mv_par06+"' "
		EndIf
		
	EndIf
	
	//Carrega os campos da tabela TEW
	aStruct := TxStrAlias("TEW")
	For nX := 1 To Len(aStruct)
		If nX <> 1
			cCmpQry += ' , '
		EndIf
		cCmpQry += "TEW." + aStruct[nX][1]
	Next nX
	
	//--------------------------------------------
	//  constrói as condições conforme o preenchimento 
	// do Pergunte quando chamado o processamento de 
	// cancelamento será forçado considerando o final 
	// entre períodos
	cQryTemp += "SELECT "
	cQryTemp +=     cCmpQry
	cQryTemp += 	",TFJ_ENTIDA"
	cQryTemp += 	",TFJ_CODENT"
	cQryTemp += 	",TFJ_LOJA "
	cQryTemp += 	",A1_NOME "
	cQryTemp += "FROM "
	cQryTemp += 	RetSqlName("TEW") + " TEW "
	cQryTemp += 	"INNER JOIN "+RetSqlName("TFI")+" TFI ON TFI.TFI_FILIAL = '"+xFilial("TFI")+"' AND TFI.TFI_RESERV = TEW.TEW_RESCOD "
	cQryTemp += 	"INNER JOIN "+RetSqlName("TFL")+" TFL ON TFL.TFL_FILIAL = '"+xFilial("TFL")+"' AND TFL.TFL_CODIGO = TFI.TFI_CODPAI "
	cQryTemp += 	"INNER JOIN "+RetSqlName("TFJ")+" TFJ ON TFJ.TFJ_FILIAL = '"+xFilial("TFJ")+"' AND TFJ.TFJ_CODIGO = TFL.TFL_CODPAI "
	cQryTemp +=     "LEFT JOIN "+RetSqlName("SA1")+" SA1  ON SA1.A1_FILIAL =  '"+xFilial("SA1")+"' AND SA1.A1_COD = TFJ.TFJ_CODENT "
	cQryTemp +=     	"AND SA1.A1_LOJA = TFJ.TFJ_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQryTemp += "WHERE "
	cQryTemp += 	"TEW.TEW_FILIAL = '"+xFilial("TEW")+"' AND TEW.D_E_L_E_T_ = ' ' AND TEW.TEW_TIPO = '2' AND TEW.TEW_MOTIVO = '5' "
	cQryTemp += 	cFiltDtRef  
	cQryTemp += 	cFiltProd
	cQryTemp += 	cFiltEquip
	
EndIf

Return cQryTemp

//------------------------------------------------------------------------------
/*/{Protheus.doc} AtGetCpos
	Função para construir a estrutura dos campos  
@sample 	AtGetCpos()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------ 
Static Function AtGetCpos()

Local aCampos   := {'TEW_FILIAL','TEW_CODMV','TEW_RESCOD','TFJ_ENTIDA','TFJ_CODENT','TFJ_LOJA','A1_NOME','TEW_PRODUT','TEW_DTSEPA',;
					'TEW_DTRINI','TEW_TEW_DTRFIM','TEW_MOTIVO','TEW_DTAMNT'}
Local nX        := 0
Local aEstrut   := {}
Local aSave     := GetArea()
Local aSaveSX3  := SX3->( GetArea() )

DbSelectArea('SX3')

For nX := 1 To Len(aCampos)

	DbSetOrder(2) // X3_CAMPO

	If SX3->( DbSeek( PadR( aCampos[nX], 10 ) ) )
	
		aAdd( aEstrut, { X3Titulo(), ;
						 If(SX3->X3_TIPO=='D',&('{|| STOD('+aCampos[nX]+')}'),&('{||'+aCampos[nX]+'}')),;
						 SX3->X3_TIPO,;
						 X3Picture(aCampos[nX]),;
						 1 ,;
						 TamSX3(aCampos[nX])[1],;
						 TamSX3(aCampos[nX])[2],;
						 .F. ,;
						 {|| .F.},;
						 .F. } )
	
	EndIf

Next nX

RestArea( aSaveSX3 )
RestArea( aSave )

Return aEstrut

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825BGrEnc
	Realiza o encerramento das reservas : encerramento por validade
@sample 	At825BGrEnc()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------ 
Function At825BGrEnc(oBrw)

Local aSave       := GetArea()
Local aSaveTFI    := TFI->( GetArea() )
Local aSaveTEW    := TEW->( GetArea() )
Local oMdlCancRes := FwLoadModel('TECA825C')
Local lStatus     := .T.
Local cBrwAlias   := oBrw:cAlias

(cBrwAlias)->( DbGoTop() )

DbSelectArea('TFI')
DbSelectArea('TEW')

While (cBrwAlias)->( !EOF() )
	
	TFI->( DbSetOrder( 6 ) ) // TFI_FILIAL+TFI_RESERV
	TEW->( DbSetOrder( 1 ) ) // TEW_FILIAL+TEW_CODMV
	
	If TEW->( DbSeek( xFilial('TEW')+(cBrwAlias)->TEW_CODMV ) ) .And. ;
		TEW->TEW_MOTIVO == DEF_RESERVA .And. ;
		TFI->( DbSeek( xFilial('TFI')+TEW->TEW_RESCOD ) ) 
		
		oMdlCancRes:SetOperation(MODEL_OPERATION_UPDATE)
		
		// adiciona os dados que serão utilizados para a gravação das informações
		At825CText( STR0009 ) // 'Processamento: Encerramento'
		At825CTipo( DEF_RES_CANCELADA )
		
		lStatus := oMdlCancRes:Activate()
		
		lStatus := ( oMdlCancRes:VldData() .And. ;
						oMdlCancRes:CommitData() )
		
		If !lStatus
			AtErroMvc( oMdlCancRes ) 
			MostraErro()
			oMdlCancRes:CancelData()
		EndIf
		
		oMdlCancRes:DeActivate()
		
	EndIf
	
	(cBrwAlias)->( DbSkip() )
End

oMdlCancRes:Destroy()

RestArea(aSaveTEW)
RestArea(aSaveTFI)
RestArea(aSave)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825BGrEnc
	Realiza o encerramento das reservas : encerramento forçado
@sample 	At825BGrEnc()
@since		11/03/2014       
@version	P12
/*/
//------------------------------------------------------------------------------ 
Function At825BGrFor(oBrw)

Local aSave       := GetArea()
Local aSaveTFI    := TFI->( GetArea() )
Local aSaveTEW    := TEW->( GetArea() )
Local oMdlCancRes := FwLoadModel('TECA825C')
Local lStatus     := .T.
Local cBrwAlias   := oBrw:cAlias

(cBrwAlias)->( DbGoTop() )

DbSelectArea('TFI')
DbSelectArea('TEW')

While (cBrwAlias)->( !EOF() )
	
	TFI->( DbSetOrder( 6 ) ) // TFI_FILIAL+TFI_RESERV
	TEW->( DbSetOrder( 1 ) ) // TEW_FILIAL+TEW_CODMV
	
	If TEW->( DbSeek( xFilial('TEW')+(cBrwAlias)->TEW_CODMV ) ) .And. ;
		TEW->TEW_MOTIVO == DEF_RESERVA .And. ;
		TFI->( DbSeek( xFilial('TFI')+TEW->TEW_RESCOD ) ) 
		
		oMdlCancRes:SetOperation(MODEL_OPERATION_UPDATE)
		
		// adiciona os dados que serão utilizados para a gravação das informações
		At825CText( STR0010 )  // 'Cancelamento/Liberação'
		At825CTipo( DEF_RES_CANCELADA )
		
		lStatus := oMdlCancRes:Activate()
		
		lStatus := ( oMdlCancRes:VldData() .And. ;
						oMdlCancRes:CommitData() )
		
		If !lStatus
			AtErroMvc( oMdlCancRes ) 
			MostraErro()
			oMdlCancRes:CancelData()
		EndIf
		
		oMdlCancRes:DeActivate()
		
	EndIf
	
	(cBrwAlias)->( DbSkip() )
End

oMdlCancRes:Destroy()

RestArea(aSaveTEW)
RestArea(aSaveTFI)
RestArea(aSave)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At825QryOSm
	Realiza a consulta aos itens de locação com reserva associada

@sample 	At825QryOSm()
@author		rebeca.asuncao
@since		24/04/2018       
@version	P12
/*/
//------------------------------------------------------------------------------
Function At825QryOSm(cTFJOrcSim)

Local cQryTab		:= ''
Local aSave			:= GetArea()
Local aSaveTFJ		:= TFJ->( GetArea() )
Local aSaveTFL		:= TFL->( GetArea() )
Local aSaveTFI		:= TFI->( GetArea() )

DEFAULT cTFJOrcSim	:= ''

If !Empty(cTFJOrcSim)

	cQryTab := GetNextAlias()
	
	BeginSql Alias cQryTab
	
		SELECT 
			TFI.TFI_COD, 
			TFI.TFI_PRODUT, 
			TFI.TFI_QTDVEN, 
			TFI.TFI_RESERV,
			1 STATUS 
			FROM %Table:TFJ% TFJ
			INNER JOIN %Table:TFL% TFL ON TFL.TFL_FILIAL = %xFilial:TFL%			 
			AND TFL.TFL_CODPAI = TFJ.TFJ_CODIGO
			INNER JOIN %Table:TFI% TFI ON TFI.TFI_FILIAL = %xFilial:TFI% 
			AND TFI.TFI_CODPAI = TFL.TFL_CODIGO
			AND TFI.TFI_RESERV <> ' '
		WHERE 
			TFJ.TFJ_FILIAL = %xFilial:TFJ%
			AND TFJ.TFJ_CODIGO = %Exp:cTFJOrcSim%
			AND TFJ.TFJ_STATUS = '1'
			AND TFJ.%NotDel%
			AND TFL.%NotDel%
			AND TFI.%NotDel%			
	EndSql
EndIf

RestArea( aSaveTFI )
RestArea( aSaveTFL )
RestArea( aSaveTFJ )
RestArea( aSave )

Return cQryTab