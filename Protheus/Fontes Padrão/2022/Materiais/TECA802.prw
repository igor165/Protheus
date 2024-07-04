#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWBROWSE.CH'
#INCLUDE 'TECA802.CH'

Static lGravou := .F.

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA802
	Browse para Visualizar os registros substituídos
		Executa o browse do Teca800 configurando o filtro da rotina
@sample 	TECA802() 
@since		04/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function TECA802()

TECA800( ' TEW->TEW_DTRINI <> CTOD("") .And. TEW->TEW_DTRFIM == CTOD("") .And. TEW->TEW_DTAMNT == CTOD("") ' )

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At802Canc
	Chama a view do processo de cancelamento da locação
		
@sample 	At802Canc() 
@since		04/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Function At802Canc( cTab, nOpc, nRecno )

Local lConfirm  := .F.
Local lContinua := .T.

If TEW->TEW_DTRINI <> CTOD("") .And. TEW->TEW_DTRFIM == CTOD("") .And. TEW->TEW_DTAMNT == CTOD('')

	If !Empty( TEW->TEW_CODKIT ) .And. !IsBlind()
		lContinua := ( MsgYesNo( STR0001, STR0002 ) ) // 'Todos os componentes do Kit serão cancelados. Deseja prosseguir?' ### 'Cancelamento de Kit' 
	EndIf

	If lContinua
		lGravou := .F.
		If !IsBlind()
			lConfirm := ( FWExecView( STR0003,'VIEWDEF.TECA802', MODEL_OPERATION_UPDATE,/*oDlg*/,; // 'Cancelamento Equipamento Locado'
				{||.T.}/*bCloseOk*/,/*bOk*/,30/*nPercRed*/,/*aButtons*/,/*bCancel*/ ) == 0 )
		EndIf
	EndIf
	
Else
	Help(,,'AT802NOITEM',,STR0004,1,0) // 'Item não pode sofrer o cancelamento' 
EndIf

Return lConfirm

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA802
	Browse para Visualizar os registros substituídos
		Executa o browse do Teca800 configurando o filtro da rotina
@sample 	TECA802() 
@since		04/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function Modeldef()

Local oModel      := Nil
Local oStruTew    := FWFormStruct(1,'TEW')

oModel := MPFormModel():New('TECA802', , , {|oMdl| At802Grv( oMdl ) } )

// ----------------------------------------------
//   Campo para receber qual status será inserido para o equipamento
//  que teve o movimento cancelado
oStruTew:AddField(STR0005, ; // cTitle // 'Status Equipamento'
				STR0005 , ; // cToolTip  // 'Status Equipamento'
				'TEW_STATUS', ; // cIdField
				'C', ; // cTipo
				2, ; // nTamanho
				0, ; // nDecimal
				{|oMdl, cCampo, xValueNew, nLine, xValueOld| ( xValueNew $ '03+05+06' ) }, ; // bValid
				{||.T.}, ; // bWhen
				{ 	'03='+ STR0006 , ; // 'Manutenção'
					'05='+ STR0007 , ; // 'Extraviado'
					'06='+ STR0008 ; // 'Deteriorado'
				}, ; // aValues
				.T., ; // lObrigat
				{||'03'}, ; // bInit - inicia conteúdo como manutenção
				Nil, ; // lKey
				.F., ; // lNoUpd
				.T. ) // lVirtual

oModel:AddFields('CANC_TEW',/*Id Superior*/,oStruTew)

oModel:SetDescription(STR0009) // 'Cancelamento de Eq. de Locação'
oModel:GetModel('CANC_TEW'):SetDescription(STR0009) // 'Cancelamento de Eq. de Locação'

oModel:SetActivate({|oMdlGeral| At802Init(oMdlGeral)})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} Viewdef
	Interface para substituição de equipamento
@sample 	Viewdef() 
@since		05/11/2013       
@version	P11.90
@return  	oRet, objeto, objeto da view
/*/
//------------------------------------------------------------------------------
Static Function Viewdef()

Local oObjView   := Nil
Local oObjMdl    := FwLoadModel('TECA802')

Local oStrTEW  := FWFormStruct(2, 'TEW',{|cCpo| SelecCpos( cCpo ) } )

oStrTEW:SetProperty( '*', MVC_VIEW_CANCHANGE, .F. )
oStrTEW:SetProperty( 'TEW_OBSMNT', MVC_VIEW_CANCHANGE, .T. )

// ----------------------------------------------
//   Campo para receber qual status será inserido para o equipamento
//  que teve o movimento cancelado
oStrTEW:AddField( 'TEW_STATUS', ; // cIdField
				'zz', ; // cOrdem
				STR0005, ; // cTitulo // 'Status Equipamento'
				STR0005 , ; // cDescric // 'Status Equipamento'
				{STR0010, STR0011}, ; // aHelp // 'Selecione o status a ser inserido    ' ### 'para o equipamento       ' 
				'C', ; // cType  // COMBO
				'', ; // cPicture
				Nil, ; // nPictVar
				Nil, ; // Consulta F3
				.T., ; // lCanChange
				'01', ; // cFolder
				Nil, ; // cGroup
				{ 	'03='+ STR0006 , ; // 'Manutenção'
					'05='+ STR0007 , ; // 'Extraviado'
					'06='+ STR0008 ; // 'Deteriorado'
				}, ; // aComboValues
				15, ; // nMaxLenCombo
				Nil, ; // cIniBrow
				.T., ; // lVirtual
				Nil ) // cPictVar

oObjView := FWFormView():New()
oObjView:SetModel(oObjMdl)

oObjView:AddField('CANC_VIEW', oStrTEW,'CANC_TEW' )

oObjView:CreateHorizontalBox( 'VIEW', 100)

oObjView:SetOwnerView('CANC_VIEW','VIEW')

oObjView:EnableTitleView('CANC_VIEW', STR0012 ) // 'Cancelamento Locação'

Return oObjView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SelecCpos
	Interface para substituição de equipamento
@sample 	Viewdef() 
@since		04/11/2013       
@version	P11.90
@return  	oRet, objeto, objeto da view
/*/
//------------------------------------------------------------------------------
Static Function SelecCpos( cCpo )

Local lRet := ( Alltrim(cCpo) $ 'TEW_CODMV+TEW_CODEQU+TEW_PRODUT+TEW_BAATD+TEW_DTSEPA+TEW_DTRINI+TEW_EQ3' )

lRet := lRet .Or. ( Alltrim( cCpo ) $ 'TEW_OBSMNT+TEW_DTAMNT+TEW_ORCSER+TEW_NFSAI+TEW_SERSAI+TEW_ITSAI+TEW_CODKIT+TEW_KITSEQ' )

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At802Init
	Inicia as informações no segundo modelo
		
@sample 	At802Init() 
@since		05/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At802Init( oMdl )

If !lGravou
	oMdl:SetValue('CANC_TEW', 'TEW_MOTIVO', '2' ) // Motivo intervenção = '2 - Cancelamento'
	oMdl:SetValue('CANC_TEW', 'TEW_DTAMNT', dDatabase ) // data da intervenção
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At801Grv
	Executa a gravação dos dados da movimentação e atualiza as informações do 
equipamento
		
@sample 	At801Grv()
@since		05/11/2013       
@version	P11.90
/*/
//------------------------------------------------------------------------------
Static Function At802Grv( oMdl )

Local lRet 			:= .T.
Local oMdlDados 	:= oMdl:GetModel('CANC_TEW')
Local xDados 		:= {}
Local cDescErro 	:= ''
Local aSave 		:= GetArea()
Local lProdKit  	:= ( !Empty( oMdlDados:GetValue('TEW_KITSEQ') ) )
Local aCposRepl 	:= {'TEW_OBSMNT', 'TEW_MOTIVO', 'TEW_DTAMNT'}
Local cQryKit 		:= ''
Local oMdlKit 		:= Nil
Local nX 			:= 0
Local nRecnoTEW 	:= TEW->( Recno() )
Local nRecnoAA3 	:= 0
Local cPrdAA3 		:= ""

DbSelectArea('AA3')
AA3->( DbSetOrder( 6 ) ) // AA3_FILIAL+AA3_NUMSER

//  só executa a gravação dos dados 1 vez
// pois o MVC continua com a janela aberta
If !lGravou 
	// -----------------------------------------------------------------
	//   Atualiza as informações do equipamento
	cPrdAA3 := At820FilPd( oMdlDados:GetValue('TEW_PRODUT'), oMdlDados:GetValue('TEW_FILIAL'), oMdlDados:GetValue('TEW_FILBAT') )
	If ( AtPosAA3( oMdlDados:GetValue('TEW_FILBAT')+oMdlDados:GetValue('TEW_BAATD'), cPrdAA3 ) )
		
		Begin Transaction
		
		nRecnoAA3 := AA3->( Recno() )
		aAdd( xDados, { 'AA3_STATUS', oMdlDados:GetValue('TEW_STATUS') } )
		
		lRet := At800Status( @cDescErro, xDados )
		aSize( xDados, 0)
		
		If lProdKit
		
			cQryKit := GetNextAlias()
			
			//-----------------------------------------------
			//   Consulta para identificar os recnos das bases de atendimento e 
			// dos movimentos gerados para esse agrupamento de kit
			//  Filtro:
			//      - Não considerar o registro atual (que já vai sofrer a atualizaçaõ)
			//      - Campo TEW_KITSEQ = código de agrupamento deste kit
			BeginSql Alias cQryKit
			
				SELECT 
					TEW.R_E_C_N_O_ TEW_RECNO,
					AA3.R_E_C_N_O_ AA3_RECNO
				FROM
					%Table:TEW% TEW 
					INNER JOIN %Table:AA3% AA3 ON AA3_FILIAL = %xFilial:AA3% AND AA3_NUMSER = TEW.TEW_BAATD
				WHERE 
					NOT TEW.R_E_C_N_O_ = %Exp:nRecnoTEW% AND TEW.%NotDel% AND AA3.%NotDel% AND TEW.TEW_FILIAL = %xFilial:TEW% AND 
					TEW.TEW_KITSEQ = %Exp:oMdlDados:GetValue('TEW_KITSEQ')%
			EndSql
			
			oMdlKit := FwLoadModel( 'TECA800' )
			
			While lRet .And. (cQryKit)->( !EOF() )
				// Posiciona nos itens que sofrerão as atualizações
				TEW->( DbGoTo( (cQryKit)->TEW_RECNO ) )
				AA3->( DbGoTo( (cQryKit)->AA3_RECNO ) )
				
				oMdlKit:SetOperation( MODEL_OPERATION_UPDATE )
				
				lRet := oMdlKit:Activate()
				
				If lRet
					For nX := 1 To Len( aCposRepl )
					
						lRet := lRet .And. oMdlKit:SetValue( 'MOVIM', aCposRepl[nX], oMdlDados:GetValue(aCposRepl[nX]) )
					
					Next nX
				EndIf
				
				lRet := lRet .And. oMdlKit:VldData() .And. oMdlKit:CommitData()
				
				//--------------------------------------------------------
				//  Atualiza a base de atendimento
				If lRet
				
					aAdd( xDados, { 'AA3_STATUS', oMdlDados:GetValue('TEW_STATUS') } )
					
					lRet := At800Status( @cDescErro, xDados )
					aSize( xDados, 0)
				
				EndIf
				
				oMdlKit:DeActivate()
				(cQryKit)->( DbSkip() )
			End
			
			(cQryKit)->( DbCloseArea() )
			oMdlKit:Destroy()
			oMdlKit := Nil
			
			TEW->( DbGoTo( nRecnoTEW ) )
			AA3->( DbGoTo( nRecnoAA3 ) )
			
		EndIf
		
		// --------------------------------------------
		//  Persiste as informações do 
		If !lRet
			DisarmTransaction()
			Break
		EndIf
		
		lRet := lRet .And. FwFormCommit( oMdl )
		
		End Transaction
	Else
		oMdl:SetErrorMessage( oMdl:GetId() ,;
								"" ,;
								oMdl:GetId() ,;
								"" ,;
								'AT802NOGRV' ,;
								STR0014,;  // "Base de atendimento não encontrada para a atualização"
								"",; 
								"",;
								"" )
		lRet := .F.
	EndIf
	
	If lRet
		lGravou := .T.
		If !IsBlind()
			MsgInfo(STR0013) // 'Atualização Concluída!'
		EndIf
	EndIf

	RestArea( aSave )
EndIf

Return lRet 