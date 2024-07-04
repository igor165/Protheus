#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.ch"

Static _lSubsPV		:= .F. //Identifica se a ação é de substiuir os lotes de PV.
static _nd5Subst	:= 0   //Recno do registor ND5 que esta sendo substiruido na opção substituir PV.

/**-------------------------------------------------------------------------------------
{Protheus.doc} UBSA020
Lotes Direcionados / PV

@param: Nil
@author: AgroIndustria
@since: 08/2020
@Uso: UBS
@type function
-------------------------------------------------------------------------------------**/
Function UBSA020()
	Local oBrowse 	:= Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "ND5" )
	oBrowse:SetDescription( 'Direcionamento de Lotes' )
	oBrowse:DisableDetails()
	oBrowse:SetMenuDef( "UBSA020")

	oBrowse:AddLegend( "ND5_STATUS=='1'", "GREEN"		, X3CboxDesc( "ND5_STATUS", "1" ) ) //" Ativo
	oBrowse:AddLegend( "ND5_STATUS=='2'", "BR_CANCEL"	, X3CboxDesc( "ND5_STATUS", "2" ) ) //"Cancelado"
	oBrowse:AddLegend( "ND5_STATUS=='3'", "BR_AZUL"		, X3CboxDesc( "ND5_STATUS", "3" ) ) //"Cancelado"
	oBrowse:SetAttach(.T.) //Habilita as visões do Browse
	oBrowse:Activate()

Return

/**-------------------------------------------------------------------------------------
{Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina

@param: Nil
@author: AgroIndustria
@since: Agosto/2020
@Uso: UBSA020
-------------------------------------------------------------------------------------**/
Static Function ModelDef()
	Local oModel	:= Nil
	Local oStruND5	:= FwFormStruct( 1, "ND5" ) // Direcionamento de Lotes
	Local oStruND6	:= FwFormStruct( 1, "ND6" ) // Itens direcionamento de lotes

	//--------------------------------
	// Instancia o modelo de dados
	//--------------------------------
	oModel := MpFormModel():New( "UBSA020",/*bPre*/ ,/*bPost*/{| oModel | fTudoOK( oModel )} ,{| oModel | FGRVMODELO( oModel ) }  /*bCommit  { | x | GrvModelo( x ) } */, /*bCancel*/ )
	oModel:SetDescription( "Modelo de Dados do Cadastro de Direcionamento" ) //"Modelo de Dados do Cadastro de Reserva"

	// Adiciona a field no modelo de dados
	oModel:AddFields( "OMDL_ND5", , oStruND5 )
	oModel:GetModel( "OMDL_ND5" ):SetDescription( 'Dados do Diecionamento' )
		
	//------------------------------------
	// Adciona a grid no modelo de dados
	//------------------------------------
	///oModel:AddGrid( "OMDL_ND6", "OMDL_ND5", oStruND6,{|oModelGrid, nLine,cAction,cField|PreValLin(oModelGrid, nLine, cAction, cField)}, /*{|x| PosLinha( x ) } */)
	///oModel:AddGrid( "OMDL_ND6", "OMDL_ND5", oStruND6,/*{|x| PreValLin( x ) } */, /*{|x| PosLinha( x ) } */)
    oModel:AddGrid( "OMDL_ND6", "OMDL_ND5", oStruND6,{|oModelGrid, nLine,cAction,cField,xVrNovo,xVrAnt|PreValLin(oModelGrid, nLine, cAction, cField,xVrNovo,xVrAnt)})

	oModel:GetModel( "OMDL_ND6" ):SetDescription( 'Lotes Direcionados' )

	//------------------
	// adiciona calculo 
	//------------------
	//oModel:AddCalc( 'UBSA020CALC' ,"OMDL_ND5" ,"OMDL_ND6", 'ND6_QT'  ,'TOTDIRECIONADO'  , 'SUM',{ |oModel| !Empty(oModel:GetValue('OMDL_ND6','ND6_LOTE')) },,'Qt.Direcionar' )
	///oModel:AddCalc( 'UBSA020CALC' ,"OMDL_ND6" ,"OMDL_ND6", 'ND6_QT'  ,'TOTDIRECIONADO'  , 'SUM',{ ||.t. },,'Qt.Direcionar' )

	oModel:AddCalc( 'UBSA020CALC' ,"OMDL_ND5" ,"OMDL_ND6", 'ND6_QT'  ,'TOTDIRECIONADO'  , 'FORMULA',{ |oModel| !Empty(oModel:GetValue('OMDL_ND6','ND6_LOTE')) },,'Qt.Direcionar',{|oModel,nVlrAtu,xValor,lSoma| FSomQTtot(oModel,nVlrAtu,xValor,lSoma,'ND6_QT')} )
	
	//------------------------------------
	// Faz o relacionamento Field x Grid
	//------------------------------------
	oModel:SetRelation( "OMDL_ND6", { { "ND6_FILIAL", "xFilial('ND6')" }, { "ND6_CODIGO", "ND5_CODIGO" } }, ND6->( IndexKey( 1 ) ) )

	//------------------
	// Seta linha unica
	//------------------
	oModel:GetModel( "OMDL_ND6" ):SetUniqueLine( { 'ND6_ITEM' } )
	oModel:GetModel( "OMDL_ND6" ):SetOptional( .t. )

	//------------------------------------
	// Seta validaÃ§Ã£o na ativaÃ§Ã£o do model
	//------------------------------------
	//oModel:SetVldActivate( { | oModel | fActvModel(oModel) } )

	//------------------------------------
	// ValidaÃ§Ã£o ApÃ³s Ativar do model
	//------------------------------------
	oModel:SetActivate( { | oModel | fActvModel(oModel) } )

    //seta campos que não deve ser copiado  no substituir
	oModel:GetModel( "OMDL_ND5" ):SetFldNoCopy( {'ND5_STATUS','ND5_JUSTIF','ND5_CTRCAN','ND5_USCANC','ND5_USCNOM','ND5_USAUTC','ND5_USACNM','ND5_DTDIR','ND5_DTCANC','' } ) // Na função Copiar nao copia os campos de retornados em array 

Return( oModel )

/**-------------------------------------------------------------------------------------
{Protheus.doc} ViewDef
Retorna a View (tela) da rotina

@param: Nil
@author: AgroIndustria
@since: 11/09/2012
@Uso: UBS
-------------------------------------------------------------------------------------**/
Static Function ViewDef()
	Local oStruND5 	:= FwFormStruct( 2, "ND5" ) 
	///Local oStruND6 	:= FWFormStruct( 2, "ND6", {|cCampo| !(AllTRim(cCampo) $ "DXQ_CODCTP|DXQ_SAFRA|DXQ_CODRES" )} )
	Local oStruND6 	:= FwFormStruct( 2, "ND6" ) 
		
	Local oModel	:= FwLoadModel( "UBSA020" )
	Local oView		:= FwFormView():New() // Instancia o modelo de dados
	Local oCalc		

	//Remove FIELDS
	oStruND6:RemoveField( "ND6_CODIGO" )
	oStruND6:RemoveField( "ND6_PRODUT" )
	oStruND6:RemoveField( "ND6_PEDIDO" )
	oStruND6:RemoveField( "ND6_ITEMPV" )
	
	oView:SetModel( oModel )
	oCalc := FWCalcStruct( oModel:GetModel( 'UBSA020CALC') ) // Instacia FwCalEstruct

	//-------------------------
	// Adciona a field na view
	//-------------------------
	oView:AddField( "VIEW_ND5" , oStruND5, "OMDL_ND5" )
	oView:AddGrid(  "VIEW_ND6" , oStruND6, "OMDL_ND6" )
	oView:AddField( 'VIEW_CALC', oCalc   , 'UBSA020CALC' )  

	oView:AddIncrementField( 'VIEW_ND6', 'ND6_ITEM' ) // seta campo incremental

	//------------------------------------------------
	// Cria box para parte superior e inferior da tela
	//------------------------------------------------
	oView:CreateHorizontalBox( "SUP", 35 )
	oView:CreateHorizontalBox( "MED", 55 )
	oView:CreateHorizontalBox( "RDP", 10 )

	//------------
	// Seta owner
	//------------ 
	oView:SetOwnerView( "VIEW_ND5"	,"SUP" )
	oView:SetOwnerView( "VIEW_ND6"	,"MED" )
	oView:SetOwnerView( "VIEW_CALC"	,"RDP" )

	//-----------------
	// Adiciona botÃµes
	//-----------------
	//IF oModel:GetOperation() == MODEL_OPERATION_INSERT
	//   oView:AddUserButton( 'Selecionar Lotes', 'CLIPS', {||  UBSA020A(oModel) } ) //"Selecionar Fardos"
	//EndIF

Return( oView )

/**-------------------------------------------------------------------------------------
{Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: AgroIndustria
@since: 11/09/2012
@Uso: UBSA020
-------------------------------------------------------------------------------------**/
Static Function MenuDef()
	Local aRotina := {}    

///	aAdd( aRotina, { 'Pesquisar', 'PesqBrw'			    , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { 'Visualizar', 'ViewDef.UBSA020'	, 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { 'Cancelar', 'UBSA020CAN()', 0, 4, 0, Nil } ) //"Cancelamento de direcionamento"
	aAdd( aRotina, { 'Lib.P/Cancelamento', 'UBSA020LBC()', 0, 4, 0, Nil } ) //"Liberação para Cancelamento"
	aAdd( aRotina, { 'Lib.P/Substituir PV', 'UBSA020LBD()', 0, 4, 0, Nil } ) //"Liberação para Substiruir o PV do Lote ( permitindo excluir o PV)
	aAdd( aRotina, { 'Substituir PV dos Lotes', "UBSA020SBS", 0, 4, 0, Nil } ) //"Liberação para Substiruir o PV do Lote ( permitindo excluir o PV)
	aAdd( aRotina, { 'Vis.Lotes Direcionados', 'UBSA020D()', 0, 5, 0, Nil } ) //"Visualisar Lotes Direcionados que não estão em Seleção de Lotes
	aAdd( aRotina, { 'Vis.Lotes Direcionados x Saldo Estoque', 'UBSA020G()', 0, 5, 0, Nil } ) //"Visualisar Lotes Direcionados que não estão em Seleção de Lotes
	aAdd( aRotina, { 'Imprimir', 'ViewDef.UBSA020'	, 0, 8, 0, Nil } ) //"Imprimir"
	
Return( aRotina )

/**-------------------------------------------------------------------------------------
{Protheus.doc} fActvModel
ValidaÃ§Ã£o apÃ³s ativaÃ§Ã£o do modelos de dados

@param: oModel - Modelo de dados
@author: AgroIndustria
@since: Agosto/2020
@Uso: Agro
-------------------------------------------------------------------------------------**/
Static Function fActvModel(oModel)

Local OMDL_ND5 := oModel:GetModel( "OMDL_ND5" )
Local lAlterar := .f.
Local oView
Local nOperation	:= oModel:GetOperation()

_lSubsPV 			:= .f. // Setando a Var static para seu default
 
IF FWIsInCallStack('UBSA020B') .and. ! FWIsInCallStack('UBSA020SBS') .and. nOperation == MODEL_OPERATION_INSERT

	OMDL_ND5:SetValue( "ND5_PEDIDO", 	(_oBrw:Alias())->C6_NUM	    )
	OMDL_ND5:SetValue( "ND5_ITEM", 		(_oBrw:Alias())->C6_ITEM    )
	OMDL_ND5:SetValue( "ND5_PRODUT", 	(_oBrw:Alias())->C6_PRODUTO )
	OMDL_ND5:SetValue( "ND5_UM", 		(_oBrw:Alias())->C6_UM      )
	OMDL_ND5:SetValue( "ND5_QT", 		(_oBrw:Alias())->C6_QTDVEN	)
	OMDL_ND5:SetValue( "ND5_CULTRA", 	(_oBrw:Alias())->C6_CULTRA  )
	OMDL_ND5:SetValue( "ND5_PENE", 		(_oBrw:Alias())->C6_PENE    )
	OMDL_ND5:SetValue( "ND5_CTVAR", 	(_oBrw:Alias())->C6_CTVAR   )
	OMDL_ND5:SetValue( "ND5_CODSAF",	(_oBrw:Alias())->C5_CODSAF  )
	OMDL_ND5:SetValue( "ND5_CATEG", 	(_oBrw:Alias())->C6_CATEG   )
	OMDL_ND5:SetValue( "ND5_CLI",		(_oBrw:Alias())->C5_CLIENTE )
	OMDL_ND5:SetValue( "ND5_LOJA", 		(_oBrw:Alias())->C5_LOJACLI )
    
	/*oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_PEDIDO',	MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_ITEM' ,	MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_PRODUT',	MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_UM' ,		MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_QT' ,		MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_CULTRA', 	MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_PENE',	MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_CTVAR',	MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_CODSAF',	MODEL_FIELD_WHEN, {||lAlterar} )
	oModel:GetModel("OMDL_ND5"):GetStruct():SetProperty( 'ND5_CATEG',	MODEL_FIELD_WHEN, {||lAlterar} )
	*/

EndIF

//Indica que esta entrando para substituir o PV do direcioamento...
IF  FWIsInCallStack('UBSA020SBS') .and. nOperation == MODEL_OPERATION_INSERT 

	_lSubsPV 	:= .t. //Indicando que é substiruição dos lotes para outro PV.
	_nd5Subst 	:= ND5->( Recno() )

	//Não permite mudar a QT.
	oModel:GetModel("OMDL_ND6"):GetStruct():SetProperty( 'ND6_QT' ,	MODEL_FIELD_WHEN, {||lAlterar} )

    //Como estes cpos stao na chave eles são limpos na ação copiar
	OMDL_ND5:SetValue( "ND5_PEDIDO", 	ND5->ND5_PEDIDO)
	OMDL_ND5:SetValue( "ND5_ITEM", 		ND5->ND5_ITEM  )

	oView			:= FwViewActive()
	IF 	oView != NIL
	   oView:AddUserButton( 'Selecionar novo PV', 'CLIPS', {||  UBSA020h( oModel ) } ) //"Selecionar PV"
	EndIF
ElseIF .not. nOperation == MODEL_OPERATION_VIEW //somentes vai mostar o campo de justif quanto for visualizar
    oView			:= FwViewActive()
	IF 	oView != NIL
		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_JUSTIF')

		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_CTRCAN')
		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_USCANC')
		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_USCNOM')
		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_USAUTC')
		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_USACNM')
		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_DTDIR' )
		oView:GetViewStruct('VIEW_ND5'):Removefield('ND5_DTCANC')

	   oView:AddUserButton( 'Selecionar Lotes', 'CLIPS', {||  UBSA020A(oModel) } ) //"Selecionar Fardos"

	EndIF
EndIF

Return(.t.)


/** {Protheus.doc} fTudoOk
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Equipe Agroindustria
@since: 	agosto/2020
@Uso: 		UBSA020 - Direcionamento de lotes
*/

Static Function fTudoOk( oModel )
	Local lRetorno		:= .t.
	Local nOperation	:= oModel:GetOperation()
	Local oModeLND5		:= oModel:GetModel("OMDL_ND5")
	Local oModelND6     := oModel:GetModel("OMDL_ND6")
	Local oModelCalc    := omodel:GetModel("UBSA020CALC")
	Local nX 			:= 0
	Local nSaldolote	:= 0
	Local lMsgLmtLot    := .t.
	Local cMsg			:= ''

	//EMERSON 

	IF _lSubsPV .and.  oModelND5:GetValue('ND5_PEDIDO') == ND5->ND5_PEDIDO
		oModel:SetErrorMessage('OMDL_ND5', 'OMDL_ND6' , 'OMDL_ND6' , 'ND6_QT' , 'Ajuda','o Pedido não foi substituido.', 'Favor informar um novo pedido para o direcionamento.')      
		lRetorno :=.f.
	EndIF
	
	IF nOperation == MODEL_OPERATION_INSERT .and. lRetorno
		// -- Valida as Qt. dos itens em OM, com  a Qtd. em SCs. do Ctrato de Compra -- //
		IF oModelCalc:GetValue("TOTDIRECIONADO") != FWFLDGET( "ND5_QT")
			oModel:SetErrorMessage('OMDL_ND5', 'OMDL_ND6' , 'OMDL_ND6' , 'ND6_QT' , 'Ajuda','QUantidade total a direcionar invalida.', 'A quantidade total a direcionar deve ser igual a quantidade total do Pedido.')      
			lRetorno :=.f.
		EndIF
		IF lRetorno   //Verificando saldo do Lote Altes de gravar...
			aSaveLines	:= FWSaveRows()
			For nX := 1 to oModelND6:Length() // Verificando se ja existe o lote no array
				oModelND6:GoLine( nX )

				IF ! oModelND6:IsDeleted()

					//Verificando Saldo do Lote
					nSaldoLote := fQtdLote(oModelND6:GetValue( "ND6_LOTE"),oModelND6:GetValue( "ND6_SUBLOT"),oModelND5:GetValue('ND5_PEDIDO'), oModelND5:GetValue('ND5_ITEM'))
                    
					IF nSaldolote <  oModelND6:GetValue( "ND6_QT")
					    cMsg := 'O Lote/Qtd informado para o item : '  + oModelND6:GetValue( "ND6_ITEM" ) + ', esta com saldo insuficiente.' + CRLF
						cMsg += 'Lote : ' + oModelND6:GetValue( "ND6_LOTE" ) + ' Saldo: ' + cvaltochar( nSaldoLOTE ) 
                    
						oModel:SetErrorMessage('OMDL_ND5', 'OMDL_ND6' , 'OMDL_ND6' , 'ND6_QT' , 'Ajuda', cMsg , 'Exclua o Lote  e selecione um lote diferente.')
						lRetorno :=.f.
						Exit
					EndIF

				EndIf
			nExt nX
			FWRestRows( aSaveLines )
		EndIf
	EndIF


Return( lRetorno )


/*/{Protheus.doc} UBSA020CAN()
@author   AgroIndustria
@version  P12
@since    05/11/2019
@obs      rotina para digitar o motivo de exc. de uma nf.
/*/
Function UBSA020CAN( cJustif )
LOCAL lRet 		:= .t.
Local oView		:= oView			:= FwViewActive()
Local lCancel	:= .f.

default cJustif :=''

IF ND5->ND5_STATUS != '1' .and.  ND5->ND5_STATUS != '3'  // Somente os direcionamentos ativos podem ser cancelados
   		Help(NIL, NIL, 'Ajuda', NIL, 'Cancelamento não permitido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Somente direcionamentos ativos podem ser cancelados.'})                  
		Return( Nil )
elseif (!ND5->ND5_CTRCAN = '2')  .OR. ( ND5->ND5_STATUS == '3' .and. Empty(ND5->ND5_USAUTC)) //Cancelamento não permitido
   		Help(NIL, NIL, 'Ajuda', NIL, 'Cancelamento não permitido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'É preciso efetuar a Liberação de cancelamento.'})                  
		Return( Nil )
EndIF

IF Empty(cJustif)
	lCancel := fGetMtv(@cJustif)
Else 
   IF !Empty(cJustif)
      lCancel :=.t.
   EndIF
EndIF

IF lCancel 
/*  Via modelo não estava gravando
	oModel 	:= FWLoadModel( "UBSA020" )
	IF ! oModel = nil
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		IF ! oModel:Activate() // Verificando se o VldActivate Falhou
			cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
			Help( ,,'Ajuda',,cMsg, 1, 0 ) //"Ajuda"
			lRet := .f.
		else
			oMdlND5 := oModel:GetModel( "OMDL_ND5" )
			oMdlND5:SetValue( "ND5_STATUS"  ,   '2' 		) //Cancelado (Indica que o direcionamento foi cancelado)
			oMdlND5:SetValue( "ND5_JUSTIF"  ,   cJustif 	) //Cancelado (Indica que o direcionamento foi cancelado)
			oMdlND5:SetValue( "ND5_USCANC"  ,   RetCodUsr() )
			oMdlND5:SetValue( "ND5_DTCANC"  ,   dDataBase 	)
			RetCodUsr()

			If (oMdlND5:VldData() )
				oModel:CommitData()
				lRet := .t.
			Else
				cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
				Help( ,,'Ajuda',,cMsg, 1, 0 ) //"Ajuda"
				lRet := .f.
			EndIf
			oModel:DeActivate()
		EndIF
	EndIF
*/
If RecLock( "ND5", .f. )
	ND5->ND5_STATUS := "2" //2=Cancelado
	ND5->ND5_JUSTIF := cJustif
	ND5->ND5_USCANC := RetCodUsr()
	ND5->ND5_DTCANC := dDataBase

	ND5->( msUnLock() )
EndIf

EndIF

Return( lRET )

/*/{Protheus.doc} UBSA020LBD()
@author   AgroIndustria
@version  P12
@since    05/11/2019
@obs      rotina para flagar que o direcionamento terá os substituidos de PV
          o Comercial irá excluir o PV, e colocará outro PV. e então vincular
		  esses lotes ao outro PV.
		  Criamos essa opção pois o cancelar Direcionamento Libera os lotes
		  e o time de carregamento pega-va o Lote antes do comercial ajustar
		  efetuar o procedimento completo.

		  Com o Substiruir permitimos o PV ser excluido, porem o Direcionamento continua
		  ativo impedindo o carregamento de carregar o lote para outro depto.
          
/*/
Function UBSA020LBD( )
LOCAL lRet 		:= .t.
Local oView		:= FwViewActive()
Local lSbstituir:=.f.
Local lFaturado := .f.

default cJustif :=''

IF ND5->ND5_STATUS == '3'   // Somente os direcionamentos ativos podem ser cancelados
   		Help(NIL, NIL, 'Ajuda', NIL, 'Substiuir não permitido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Direcionamento ja se encontra liberado para substituir.'})                  
		Return( Nil )
ElseIF ND5->ND5_STATUS != '1'   // Somente os direcionamentos ativos podem ser cancelados
   		Help(NIL, NIL, 'Ajuda', NIL, 'Substiuir não permitido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Somente direcionamentos ativos podem ser Liberados para cancelamento.'})                  
		Return( Nil )
EndIF

//Se o pedido ja tiver itens faturados não permite a liberação para substituir.
IF lFaturado := fFaturado(ND5->ND5_PEDIDO, ND5->ND5_ITEM,oView)
	Return( Nil )
EndIF

lSbstituir := FWAlertYesNo('Confirma a Liberação para  Substiruir, os Lotes de PV?', 'Atenção')

IF lSbstituir 
/*  Via modelo não estava gravando
	oModel 	:= FWLoadModel( "UBSA020" )
	IF ! oModel = nil
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		IF ! oModel:Activate() // Verificando se o VldActivate Falhou
			cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
			Help( ,,'Ajuda',,cMsg, 1, 0 ) //"Ajuda"
			lRet := .f.
		else
			oMdlND5 := oModel:GetModel( "OMDL_ND5" )
			oMdlND5:SetValue( "ND5_CTRCAN"  ,   '2' 	)			  //Indica que o direcionamento pode ser cancelado
			oMdlND5:SetValue( "ND5_USAUTC"  ,   RetCodUsr() )
			
			If (oMdlND5:VldData() )
				oModel:CommitData()
				lRet := .t.
			Else
				cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
				Help( ,,'Ajuda',,cMsg, 1, 0 ) //"Ajuda"
				lRet := .f.
			EndIf
			oModel:DeActivate()
		EndIF
	EndIF
*/
If RecLock( "ND5", .f. )
     ND5->ND5_STATUS := '3' ////3=Substituir permitido 
	///ND5->ND5_CTRCAN := '2' 
	///ND5->ND5_USAUTS := RetCodUsr()
	ND5->( msUnLock() )
EndIf

EndIF

Return( lRET )

/*/{Protheus.doc} UBSA020LBC()
@author   AgroIndustria
@version  P12
@since    05/11/2019
@obs      rotina para flagar que direcionamento pode ser cancelado
/*/
Function UBSA020LBC( )
LOCAL lRet 		:= .t.
Local oView		:= FwViewActive()
Local lCancel	:= .f.
Local lFaturado := .f.
Local lMVAGRO050 := SuperGetMv("MV_AGRO050", .F., .F. )     // .T. que o pode-se liberar o direcionamento para cancelmaneto mesmo que ja tenha faturamento do lote direcionado.
															// .f. não permite liberar para cancelmaneto o direcionamento que ja possui faturamento.
															

default cJustif :=''

IF ND5->ND5_STATUS != '1'  .and.   ND5->ND5_STATUS != '3'// Somente os direcionamentos ativos podem ser cancelados
   		Help(NIL, NIL, 'Ajuda', NIL, 'Liberação de Cancelamento não permitido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Somente direcionamentos ativos podem ser Liberados para cancelamento.'})                  
		Return( Nil )
EndIF

//Se o pedido ja tiver itens faturados não permite a exclusão
IF !lMVAGRO050 
	IF lFaturado := fFaturado(ND5->ND5_PEDIDO, ND5->ND5_ITEM,oView) 
		Return( Nil )
	EndIF
EndIf

lCancel := FWAlertYesNo('Confirma a Liberação de  Cancelamento?', 'Atenção')

IF lCancel 
/*  Via modelo não estava gravando
	oModel 	:= FWLoadModel( "UBSA020" )
	IF ! oModel = nil
		oModel:SetOperation( MODEL_OPERATION_UPDATE )
		IF ! oModel:Activate() // Verificando se o VldActivate Falhou
			cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
			Help( ,,'Ajuda',,cMsg, 1, 0 ) //"Ajuda"
			lRet := .f.
		else
			oMdlND5 := oModel:GetModel( "OMDL_ND5" )
			oMdlND5:SetValue( "ND5_CTRCAN"  ,   '2' 	)			  //Indica que o direcionamento pode ser cancelado
			oMdlND5:SetValue( "ND5_USAUTC"  ,   RetCodUsr() )
			
			If (oMdlND5:VldData() )
				oModel:CommitData()
				lRet := .t.
			Else
				cMsg := oModel:GetErrorMessage()[3] + oModel:GetErrorMessage()[6]
				Help( ,,'Ajuda',,cMsg, 1, 0 ) //"Ajuda"
				lRet := .f.
			EndIf
			oModel:DeActivate()
		EndIF
	EndIF
*/
If RecLock( "ND5", .f. )
	ND5->ND5_CTRCAN := "2" //2=Cancelamento permitido
	ND5->ND5_USAUTC := RetCodUsr()
	ND5->( msUnLock() )
EndIf

EndIF

Return( lRET )



/*/{Protheus.doc} fGetMtv
@author   AgroIndustria
@version  P12
@since    05/11/2019
@obs      rotina para digitar o motivo de exc. de uma nf.
/*/

Static Function fGetMtv(cJustif)
 Local lRet			:= .f.
 

oDlg := FWDialogModal():New()
oDlg:SetBackground(.F.)
oDlg:SetTitle('Cancelamento de direcionamento')
oDlg:SetEscClose(.f.)
oDlg:setSize(125,320)

oDlg:EnableFormBar(.T.)
oDlg:CreateDialog() 

oDlg:AddButton( "Continuar",{||IIF(lRet:=TdOK(cJustif),oDlg:Deactivate(),)}, "Continuar", , .T., .F., .T., )//"Sair"
oDlg:AddButton( "Sair",{||oDlg:Deactivate(),lret:=.f.}, "Sair", , .T., .F., .T., )//"Sair"
oDlg:createFormBar()//cria barra de botoes
						
    
    oLayer := FWLayer():new()
	oPanel := oDlg:getPanelMain()
    ////oLayer:Init(oDlg,.F.)
    oLayer:Init(oPanel,.F.)
    oLayer:addLine('LinhaSuperior',100,.F.,)
    
    oLayer:addColumn('ColSuperior',100,.F.,'LinhaSuperior')
    
    oLayer:addWindow('ColSuperior','C1_Win01',"Informe o Motivo de Cancelamento do direcionamento" ,100,.F.,.F.,,'LinhaSuperior',)
    
    oPanel   := oLayer:getwinpanel('ColSuperior','C1_Win01','LinhaSuperior')
    
    oFont := TFont():New('Arial',,15,.T.)    
    oSay1 := TSay():Create(oPanel,{||'Motivo:'},4 ,0,,oFont,,,,.T.,CLR_BLACK,CLR_RED,50,50)
    
    @ 02,20 GET oJustif VAR cJustif MEMO SIZE 275, 48 OF oPanel PIXEL // HASBUTTON

 odlg:activate()
    

    
Return ( lret )

/*/{Protheus.doc} TdOK
//TODO Valida se foi informado um  motivo de exc. de docto de saida
@author totvs
@since 06/11/2019
@version 1.0
@return Logico , .t. ( segue com a exclusão )

@type function
/*/
Static function TdOK( cJustif )
 
 Local lRet := .t.
 
   IF Empty(cJustif)
		Help(NIL, NIL, 'Cancelamento de direcionamento', NIL, 'Motivo de cancelamento invalido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Informe o motivo de cancelamento do direcionamento'})                  
		lRet := .f.
   EndIF                  

Return lRet


/*/{Protheus.doc} fQtdLote
//Função que retorna a qtidade do Lote abatendo possiveis QTs. Direcionadas - Qts.Reservadas( ERP ja abate no Saldosb8)
@Param  cProduto
		cLote
		cSubLote
		cPedido
		cItemPV
@author totvs
@since Agosto/2020
@version 1.0
@return Qt. do lote 

@type function
/*/

STatic function fQtdLote(cLote,cSubLote, cPedido, cItemPV)

Local oMdlUBA020    := FWModelActive()
Local cChaveSB8		:= ''
Local nSaldoLte		:= 0
Local nSldLteTot	:= 0
Local lEmpPrev		:= If(SuperGetMV("MV_QTDPREV") = "S",.T.,.F.)
Local cAliasQRY		:= GetNextAlias()
Local lRastros 		:= .t.
Local cChave		:=''
Local nQTPVRESER	:=0
Local nQtDirec		:=0
Local cUm           :=  oMdlUBA020:GetModel( "OMDL_ND5" ):GetValue( "ND5_UM    ") 
Local nQtPvLbEst	:= 0
Local cFiltro		:= ''


IF _lSubsPV //Indica que é a substituiçaõ dos lotes de um PV para Outro
            //Desconcidero a Qt. direcionada do Direcionamento
		    //Que estamos posicionado na substituição
   cFiltro := " AND (ND5.ND5_PEDIDO <> '" + ND5->ND5_PEDIDO + "' OR ND5.ND5_ITEM <> '" + ND5->ND5_ITEM + "' ) "
EndIF

If Empty(cFiltro)
	cFiltro := "%%"
Else
	cFiltro := "% " + cFiltro + " %"
Endif

//EndIF

	BeginSQL Alias cAliasQRY
		COLUMN B8_DTVALID AS DATE
		SELECT NP9.NP9_FILIAL,NP9.NP9_CODSAF, NP9.NP9_PROD,SB1.B1_UM, NP9.NP9_LOTE,NP9.NP9_TRATO,	NP9.NP9_TIPLOT,NP9.NP9_EMB,NP9.NP9_UM, NP9.NP9_2UM,	NP9.NP9_CULTRA,
		NP9.NP9_CTVAR,NP9.NP9_CATEG,NP9.NP9_PENE,SB8.B8_DTVALID,SB8.B8_LOCAL,B8_NUMLOTE,B8_LOTECTL,
	    ROW_NUMBER() OVER ( PARTITION BY NP9.NP9_LOTE ,SB8.B8_NUMLOTE ORDER BY NP9.NP9_LOTE ,SB8.B8_NUMLOTE) AS IDLine,
		(SELECT SUM(ND6.ND6_QT) FROM  %Table:ND5% ND5
			INNER JOIN  %Table:ND6% ND6
     			 ON ND6.%notDel%
	 			AND ND6.ND6_FILIAL = %xFilial:ND6% 
     			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')

			WHERE ND5.%notDel%
			AND ND5.ND5_STATUS = '1'
			AND ND5.ND5_FILIAL = %xFilial:ND5% 
			AND ND6.ND6_LOTE   = NP9.NP9_LOTE
			AND ND6.ND6_SUBLOT = SB8.B8_NUMLOTE
		)  AS QTDIRECIONADA,

		(SELECT SUM(ND6.ND6_QT) FROM  %Table:ND5% ND5
			INNER JOIN  %Table:ND6% ND6
     			 ON ND6.%notDel%
	 			AND ND6.ND6_FILIAL = %xFilial:ND6% 
     			AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
			WHERE ND5.%notDel%
			AND ND5.ND5_STATUS = '3' /// QT DIRECIONADA ONDE O DIRECIONAMENTO SE ENCONTRA EM TRANSFERENCIA DE UM PV PARA OUTRO
			AND ND5.ND5_FILIAL = %xFilial:ND5% 
			AND ND6.ND6_LOTE   = NP9.NP9_LOTE
			AND ND6.ND6_SUBLOT = SB8.B8_NUMLOTE
			%exp:cFiltro%
		)  AS QTDIRTRANSF,
	
		(SELECT SUM(NJ6.NJ6_QTDE) FROM %Table:NJ6%  NJ6
		     INNER JOIN %Table:ND5% ND5AUX3 
			     ON ND5AUX3.%notDel%
				AND ND5AUX3.ND5_FILIAL = %xFilial:ND5% 
				AND ND5AUX3.ND5_STATUS = '1'
				AND ND5AUX3.ND5_CODSAF = NP9.NP9_CODSAF
				AND ND5AUX3.ND5_PEDIDO = NJ6.NJ6_NUMPV
				AND ND5AUX3.ND5_ITEM   = NJ6.NJ6_ITEM
				AND ND5AUX3.ND5_UM	   = SB1.B1_UM
			INNER JOIN %Table:ND6%  ND6AUX3 
			    ON  ND6AUX3.%notDel%
				AND ND6AUX3.ND6_CODIGO = ND5AUX3.ND5_CODIGO 
				AND ND6AUX3.ND6_FILIAL = ND5AUX3.ND5_FILIAL 	
				AND ND6AUX3.ND6_PEDIDO = ND5AUX3.ND5_PEDIDO
				AND ND6AUX3.ND6_ITEMPV = ND5AUX3.ND5_ITEM
				AND ND6AUX3.ND6_CODSAF = ND5AUX3.ND5_CODSAF 
				AND ND6AUX3.ND6_LOTE   = NP9.NP9_LOTE
				AND ND6AUX3.ND6_SUBLOT = SB8.B8_NUMLOTE
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6AUX3.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')				
			WHERE NJ6.%notDel%
				AND NJ6.NJ6_LOTECT = %exp:cLote%
				AND NJ6.NJ6_NMLOTE = %exp:cSubLote%
				AND NJ6.NJ6_FILIAL = %xFilial:NJ6%
		) AS QTPVRESERV,

 		(SELECT SUM(C9_QTDLIB) QUANTIDADE
			FROM %Table:SC9%  SC9
			INNER JOIN %Table:ND5% ND5AUX4 
			    ON ND5AUX4.%notDel%
				AND ND5AUX4.ND5_FILIAL = %xFilial:ND5% 
				AND ND5AUX4.ND5_STATUS = '1'
				AND ND5AUX4.ND5_CODSAF = NP9.NP9_CODSAF
				AND ND5AUX4.ND5_PEDIDO = SC9.C9_PEDIDO
				AND ND5AUX4.ND5_ITEM   = SC9.C9_ITEM
				AND ND5AUX4.ND5_UM     = SB1.B1_UM
			INNER JOIN %Table:ND6%  ND6AUX4 
			    ON  ND6AUX4.%notDel%
				AND ND6AUX4.ND6_CODIGO = ND5AUX4.ND5_CODIGO 
				AND ND6AUX4.ND6_FILIAL = ND5AUX4.ND5_FILIAL 	
				AND ND6AUX4.ND6_PEDIDO = ND5AUX4.ND5_PEDIDO
				AND ND6AUX4.ND6_ITEMPV = ND5AUX4.ND5_ITEM
				AND ND6AUX4.ND6_CODSAF = ND5AUX4.ND5_CODSAF 
				AND ND6AUX4.ND6_LOTE   = NP9.NP9_LOTE
				AND ND6AUX4.ND6_SUBLOT = SB8.B8_NUMLOTE
			INNER JOIN %Table:SC5% SC5    //desconsideramos o direcionamento de pedidos Encerrados
    			ON SC5.%notDel%
    			AND SC5.C5_FILIAL = %xFilial:SC5%
    			AND SC5.C5_NUM = ND6AUX4.ND6_PEDIDO  
				AND NOT ( (SC5.C5_NOTA <> ' ' OR C5_LIBEROK = 'E') AND C5_BLQ = ' ')
			WHERE SC9.%notDel%
			AND SC9.C9_FILIAL = %xFilial:SC9% 
			AND SC9.C9_BLEST <> '02'
		    AND   //Disconsidero se existe sc9 com reserva referenciada  que ainda não foi deletada.
				( SELECT COUNT (SC0.C0_NUM) FROM  %Table:SC0% SC0
				WHERE SC0.%notDel%
				AND   SC0.C0_NUM = SC9.C9_RESERVA
				AND   SC0.C0_FILIAL = %xFilial:SC0% 
				) = 0 
			) AS QtPvLbEst

		FROM %Table:SB8% SB8
			INNER JOIN %table:NP9% NP9 ON NP9.%notDel%
				AND NP9.NP9_FILIAL = %xFilial:NP9%  
				AND  NP9.NP9_LOTE = SB8.B8_LOTECTL 
				AND NP9.NP9_PROD = SB8.B8_PRODUTO
				
			//Adicionado a Inner join na SB1 para demonstrar somente os produtos que tenha a mesma 
			//Und. Medida do Item do pedido de venda.
			INNER JOIN %table:SB1% SB1 ON SB1.%notDel%
				AND SB1.B1_FILIAL = %xFilial:SB1%  
				AND SB1.B1_COD     =  SB8.B8_PRODUTO
				AND SB1.B1_UM      = %exp:cUM%

		WHERE
			SB8.B8_FILIAL=%xFilial:SB8%    
			AND NP9.NP9_LOTE 	= %exp:cLote%
			AND SB8.B8_NUMLOTE	= %exp:cSubLote%
			AND NP9_STATUS  = '2'    //Somente lotes aprovados

			AND SB8.%NotDel% 

			ORDER BY NP9_LOTE,B8_NUMLOTE,NP9_PROD
	EndSQL

	//EECVIEW(getLastQuery()[2],'validando qtd dos itens')
	
	nSldLteTot	:= 0
	
	While (cAliasQRY)->( !Eof() )


		nIndice := If(lRastroS,2,3)

		cChave := IIf(lRastroS,(cAliasQRY)->(B8_NUMLOTE+NP9_LOTE+NP9_PROD+B8_LOCAL ),(cAliasQRY)->(NP9_PROD + B8_LOCAL+NP9_LOTE))

		SB8->( dbSetOrder( nIndice ) )
		IF SB8->( dbSeek( xFilial( "SB8" ) + cChave ) )
			
			nSaldoLte  := SB8Saldo(.F.,!Empty((cAliasQRY)->NP9_LOTE),NIL,NIL,NIL,lEmpPrev,NIL,ddatabase,)
			//Como a qtidade Reservada/Direcionada é uma soma por lote e a b8 traz o mesmo lote e safra n vezes
			//Faço esse tratamento para não considerar a qtidade reservada em duplicidade.
			//Não fiz um sql separado da qtd. reservada do lote para evitar ter que ficar abrindo e fechando
			//query a cada item da sb8 .

		    IF (cAliasQRY)->IDLine == 1  // Indica que é a 1a. vez que o lote aparece então eu faço adiciono a Qt. ao cpo QT Reservada
			    nQtPvLbEst  :=  (cAliasQRY)->QtPvLbEst
				nQTPVRESER 	:=  (cAliasQRY)->QTPVRESERV
				nQtDirec	:= 	(cAliasQRY)->QTDIRECIONADA + (cAliasQRY)->QTDIRTRANSF
			EndIF

  			IF  (nQtDirec > (nQTPVRESER + nQtPvLbEst)  )     // as Reservas do PV e possiveis, liberações de estoque (sc9) devem ser subtraidas da qt direcionada...
			    nSldLteTot := nSaldoLte - (nQtDirec - (nQTPVRESER + nQtPvLbEst) )
			Else
			   nSldLteTot += nSaldoLte
			EndIF

			nQtDirec 	:= 0
			nQTPVRESER	:= 0
			nQtPvLbEst  := 0

		EndIF
		(cAliasQRY)->(dbSkip())		
	EndDo

	If nSldLteTot < 0
	    nSldLteTot := 0
	EndIF
	
	( cAliasQRY )->( DbCloseArea() )

Return ( nSldLteTot )


//-------------------------------------------------------------------
/*/{Protheus.doc} FSomQTtot
Fornula do Total de QT dos lotes selecionados

@author Agroindustria

@since agosto/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Function FSomQTtot(oModel,nVlrAtu,xValor,lSoma,cCampo)

///Local nRet		:= 0
Local oModelND6	:= oModel:GetModel("OMDL_ND6")

	If xValor > 0
		nVlrAtu += xValor * Iif(lSoma,1,-1)
	ElseIF xValor == 0 .and. omodelnd6:length() == 1 //força a limpar a soma pois no ubsa020a cleardata não funciona
       nVlrAtu:=0
	EndIF
	
Return nVlrAtu


	/*/{Protheus.doc} PreValLin(oModelGrid, nLinha, cAcao, cCampo,xVrNovo,xVrNovo)
	@author Agro
	@param oModelGrid Modelo
	@param nLinha Linha corrente
	@param cAcao  Ação ("DELETE", "SETVALUE", e etc)
	@param cCampo Campo atualizado
	@param Vr. inserido no Campo
	@param Vr. que do Cpos antes da Inserção do novo vr.
	@return lRet
	@since Setembro/2020
	@version 1.1
	/*/
//------------------------------------------------------------------
Static Function PreValLin(oModelND6, nLinha, cAcao, cCampo,xVrNovo,xVrAnt)
	Local oModel        	:= FWModelActive()
	Local nOperation 		:= oModel:GetOperation()
	Local aSaveLines     	:= FWSaveRows()
	Local oView				:= FwViewActive()
	Local lContinua			:=.t.
	Local nPercPermi        := 50
	Local nQtProdzLt	    := fGetQTLote(FWFLDGET('ND6_LOTE'),FWFLDGET('ND6_SUBLOT'),FWFLDGET('ND6_CODSAF'),FWFLDGET('ND5_UM')  )
	Local nPerctDir			:=0

	//--Verifica se a Qtd. informada do Lote não ultrapassa os 50% do Lote produzido (limpo)
	IF lContinua .and. cAcao == 'SETVALUE' .and. cCampo == 'ND6_QT' .and. xVrNovo > 0
	   nPercDir = Round( (xVrNovo / nQtProdzLt) * 100, 3 )
       IF nPercDir > nPercPermi
		  //Help não dispara a menssagem na tela
	      //Help(NIL, NIL, 'Ajuda', NIL, 'Direcionado mais de ' + cvaltochar( nPercPermi ) + '% da Qtd. referente ao lote limpo.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'Verifique a quantidade selecionada.'})                  
   		If ! oview = nil
	  		FWAlertWarning ('Direcionado mais de ' + cvaltochar( nPercPermi ) + '% da Qtd. referente ao lote limpo.','Atenção')
   		EndIf

	   EndIF
    	lContinua := .t.
	EndIF

	FWRestRows(aSaveLines)
   If oview == nil
	  oview:refresh()
   EndIf

Return (lContinua)


	/*/{Protheus.doc} fGetQtLt()
	@author Agro
	@param Lote, SubLote, Safra, UM
	@return Quantidade do Lote
	@since Setembro/2020
	@version 1.1
	/*/
//------------------------------------------------------------------
Static function fGetQTLote(cLote,cSubLote,cCodSaf,cUM  )

Local cAliasQRY := GetNextAlias()

	BeginSql Alias cAliasQRY
		SELECT SUM(NP9.NP9_QUANT) QTDPRODUZIDA
		FROM %Table:NP9% NP9
		WHERE NP9.%notDel%
		AND NP9.NP9_FILIAL = %xFilial:NP9% 
		AND NP9.NP9_LOTE = %Exp:cLote%
		//AND NP9.NP9_SUBLOTE  -> NP9 não tem sub LOTE
		AND NP9.NP9_CODSAF 	= %Exp:cCodSaf%
		AND NP9.NP9_UM     	= %Exp:cUM%
		AND NP9_TRATO 		= '2'    //Considera somente lotes não tratados pois é onde tem Qtd. Original o Lote.
	EndSql

    nQtLote := (cAliasQRY)->QTDPRODUZIDA

	(cAliasQry)->( dBClosearea() )



Return ( nQtLote )



//Identifica se existem itens do direcionamento do pedido Faturado ou em processo de faturamento

Static Function fFaturado(cPedido, cItemPV,oVIEW)
Local lRet := .f.
Local cAliasQRY 	:= GetNextAlias()
Local aLtesEmFat	:= {}
Local cMsgErro		:= ''

	BeginSql Alias cAliasQRY
		SELECT 
			(SELECT SUM(SC0.C0_QUANT) FROM %Table:SC0% SC0
				INNER JOIN %Table:NJ6% NJ6
					ON NJ6.NJ6_RESERV  = SC0.C0_NUM 
					AND NJ6.NJ6_NMLOTE = SC0.C0_NUMLOTE
					AND NJ6.NJ6_LOTECT = SC0.C0_LOTECTL
					AND NJ6.NJ6_NUMPV = ND6.ND6_PEDIDO
     				AND NJ6.NJ6_ITEM   = ND6.ND6_ITEMPV
					AND NJ6.NJ6_FILIAL = %xFilial:NJ6% 
					AND NJ6.%notDel%
				WHERE SC0.C0_LOTECTL   = ND6_LOTE
				AND SC0.C0_NUMLOTE    = ND6_SUBLOT
				AND SC0.C0_FILIAL     = %xFilial:SC0% 
				AND SC0.%notDel%
			) AS QTPVRESERV,

			(SELECT SUM(C9_QTDLIB) QUANTIDADE FROM %Table:SC9% SC9
				WHERE SC9.%notDel%
				AND SC9.C9_FILIAL = %xFilial:SC9%
				AND SC9.C9_BLEST <> '02'
				AND SC9.C9_PEDIDO = ND6.ND6_PEDIDO
				AND SC9.C9_ITEM = ND6.ND6_ITEMPV
				AND SC9.C9_LOTECTL = ND6.ND6_LOTE
				AND SC9.C9_NUMLOTE = ND6.ND6_SUBLOT
				AND   
					( SELECT COUNT (SC0.C0_NUM) FROM  %Table:SC0% SC0
					WHERE SC0.%notDel%
					AND   SC0.C0_NUM = SC9.C9_RESERVA
					AND   SC0.C0_FILIAL = %xFilial:SC0%
					) = 0 
			) AS QtPvLbEst,
		ND6.ND6_PEDIDO, ND6.ND6_ITEMPV, ND6.ND6_LOTE, ND6.ND6_SUBLOT
	FROM %Table:ND6% ND6

	INNER JOIN %Table:ND5% ND5
		ON ND5.%notDel%
		AND ND5.ND5_FILIAL = %xFilial:ND5% 
		AND ND5.ND5_STATUS = '1'
		AND ND6.ND6_CODIGO = ND5.ND5_CODIGO
		AND ND5.ND5_CODSAF = ND6.ND6_CODSAF
		AND ND5.ND5_PEDIDO = ND6.ND6_PEDIDO
		AND ND5.ND5_ITEM   = ND6.ND6_ITEMPV
	WHERE ND6_PEDIDO = %Exp:cPedido% 
	AND   ND6_ITEMPV = %Exp:cItemPv%
	AND   ND6.%notDel%
EndSql

cMsgErro := ''
( cAliasQRY )->( dbGoTop() )
While (cAliasQRY)->( !Eof() )
    IF (cAliasQRY)->QTPVRESERV + (cAliasQRY)->QtPvLbEst > 0
	   cMsgErro += "Lote / Sublote .........: "  + (cAliasQRY)->ND6_LOTE + (cAliasQRY)->ND6_SUBLOT + CRLF
	   cMsgErro += "   Qt.Reservada.........: "  + cValtoChar( (cAliasQRY)->QTPVRESERV ) + CRLF
	   cMsgErro += "   Qt.Fat/Em Faturamento: "  + cValToChar( (cAliasQRY)->QtPvLbEst )	 + CRLF
	EndIF

(cAliasQRY)->(dbSkip())		
EndDo


(cAliasQry)->( dBClosearea() )

IF !Empty(cMsgErro)
   lRet := .t.
	MsgDtlhe("Cancelamento não permitido", "Pedido/item Está Faturado ou possui itens em  processo de expedição."+CRLF+;
			"Clique em 'Detalhes' para visualizar as informações.", cMsgErro)
EndIF

Return(lRet)


//Função para disparar mensagem com detalhes.
//cTitulo - Titulo da Tela de Abertura
//cMensagem - Mensagem que será apresentada na tela sem o detalhe
//cDetalhe - Mensagem que será apresentada ao clicar em detalhe, geralmente será um bloco de texto.
Static Function MsgDtlhe(cTitulo, cMensagem, cDetalhe)
	Local oDlgII				:= Nil
	Local oFntTit				:= Nil
	Local oFntMsg				:= Nil
	Local oMsgDet				:= Nil
	Local lTelaDetalhe			:= .F.
	Local lExibeBotaoDetalhe	:= .T.

	Default cTitulo		:= 'Mensagem de Integração' 
	Default cMensagem 	:= ''
	Default cDetalhe 	:= ''

	If Empty(cDetalhe)
		lExibeBotaoDetalhe := .F.
	EndIf

	DEFINE MSDIALOG oDlgII TITLE cTitulo FROM 0,0 TO 130,600 PIXEL 

	DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
	DEFINE FONT oFntMsg NAME "Courier new"  SIZE 7,15

	//@ 0,0  BITMAP oBmp RESNAME "LOGIN" oF oDlgII SIZE 100,600 NOBORDER WHEN .F. PIXEL 
	@05,03 TO 45,295 PROMPT 'Informação' PIXEL
	@13,05 GET cMensagem FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 288,30 PIXEL

	@50,200 BUTTON 'OK' PIXEL ACTION oDlgII:End() // "OK"

	If lExibeBotaoDetalhe
		@50,230 BUTTON 'Detalhes' PIXEL ACTION If(	!lTelaDetalhe,;  // "Detalhes"
		(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight+165,,.T.),lTelaDetalhe:=.T.),;
		(oDlgII:ReadClientCoors(.T.),oDlgII:Move(oDlgII:nTop,oDlgII:nLeft,oDlgII:nWidth,oDlgII:nHeight-165,,.T.),lTelaDetalhe:=.F.))		
		@ 67,03 TO 140,295 PROMPT "Detalhes da informação:" PIXEL
		@ 75,05 GET oMsgDet VAR cDetalhe FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 288,63 PIXEL
	EndIf

	oDlgII:lEscClose	:= .F. //Nao permite sair ao se pressionar a tecla ESC.
	oDlgII:lCentered	:= .T.
	oDlgII:Activate(,,,.T.)
	//ACTIVATE MSDIALOG oDlgII CENTERED

Return .T.



//Função que permite substituir o PV. do direcionamento.
Function UBSA020SBS( )

Local nRet 			:= 1
Local lConfirmou	:= .f.

Local nOperation 	:= 9 //MODEL_OPERATION_INSERT
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil}/*Salvar*/,{.T.,Nil/*"Cancelar"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
Local cPedido   := ''
Local cItemPV   := ''


IF ND5->ND5_STATUS != '3'   // Somente os direcionamentos que foram liberados para substituir podem ter
							// o seu PV substituido.
   		Help(NIL, NIL, 'Ajuda', NIL, 'Substiuir não permitido.', 1, 0, NIL, NIL, NIL, NIL, NIL, {'É necessario liberar o direcionamento para substituir.'})
		Return( Nil )
EndIF

nRet := FWExecView('Substituição de Pvs do direcionamento',"UBSA020",nOperation,,{ || lConfirmou := .T. },,,aButtons)

Return()





/** {Protheus.doc} FGRVMODELO
Funcao para gravar dados adicionais e o modelo de dados

@param: 	oModel - Modelo de Dados
@return:	lRetorno - .t.
@author: 	AGROINDUSTRIA
@since: 	29/11/2014
@Uso: 		UBSA020
*/

Static Function FGRVMODELO (oModel)
	Local lRetorno 		:= .T.

	IF _lSubsPV // Indica que estamos substituindo o PV
		lRetorno := FWFormCommit(oModel, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/, {||FCANCDIR( oModel)}, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
	Else
		FWFormCommit(oModel)
		//, /*[bBefore]*/, /*[bAfter]*/, /*[bAfterSTTS]*/,, /*[bABeforeTTS]*/, /*<bIntegEAI >*/)
	EndIF
Return( lRetorno )

/** {Protheus.doc} fcancDir
Funcao que cancela o direcionamento do PV que esta sendo substituido

@param: 	oModel - Modelo de Dados
@return:	lRetorno - .t.
@author: 	AGROINDUSTRIA
@since: 	29/11/2014
@Uso: 		UBSA020
*/
Static Function FCANCDIR (oModel)
	Local lRetorno 		:= .T.
	Local cMtv			:= ""
	Local OMDL_ND5 := oModel:GetModel( "OMDL_ND5" )
	
	cMtv 	:= "Direcionamento transf. Para o PV: "
	cMtv 	+= OMDL_ND5:GETVALUE('ND5_PEDIDO') + "/" + OMDL_ND5:GETVALUE('ND5_ITEM')
	cMtv 	+= " e direcionamneto codigo: " + OMDL_ND5:GETVALUE('ND5_CODIGO')

	IF _lSubsPV // Indica que estamos substituindo o PV
	   
	    ND5->(DBGoTo( _nd5Subst ))  //posiciono no registro a substituir pois 
									//pois neste momento ja éo registro novo que esta posicionado
	    If RecLock( "ND5", .f. )
			ND5->ND5_STATUS := "2" //2=Cancelado
			ND5->ND5_JUSTIF := cMtv
			ND5->ND5_USCANC := RetCodUsr()
			ND5->ND5_DTCANC := dDataBase
			ND5->( msUnLock() )
		else
			lRetorno := .f.
		EndIF
	EndIf
		
	
Return( lRetorno )



