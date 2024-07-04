#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA106.ch'

Static nRecno106D	:= GQH->(Recno())
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA106D()
DEVOLUÇÃO DE DOCUMENTOS.
@sample		GTPA106D()
@param 	
@return		oBrowse  
 @author		Inovação
@since			10/02/2017
@version		P12
/*/

Function GTPA106D()
Local aCpoAux := {}
Local lRet		:= .T.

nRecno106D	:= GQH->(Recno())

If GQH->GQH_MOVTO $ '12'		
	lRet := FWExecView( STR0034, "VIEWDEF.GTPA106D", MODEL_OPERATION_INSERT, /*oDlg*/, ; //""Devolução" 
					{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
ElseIf GQH->GQH_MOVTO $ "345"
	Help(" ",1,"TPA108D01",,STR0035,1,0) //"O status da alocação não permite devolução" 
	lRet := .F.
Else 
	HELP(" ",1,"ARQVAZIO")	
	lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author		Inovação - Servços
@since		15/09/2014
@version	P12
/*/
Static Function ModelDef()
	
Local oModel := Nil
Local oStruGQH	:= FWFormStruct(1,'GQH')
Local bCommit	:= {|oModel|GA106Grv(oModel)}

oStruGQH:SetProperty('GQH_NUMINI', MODEL_FIELD_VALID , {|oMdlGQH,cField,xData,nLin,xOldData|TP106VldNum(oMdlGQH,cField,xData,nLin,xOldData)} )
oStruGQH:SetProperty('GQH_NUMFIM', MODEL_FIELD_VALID , {|oMdlGQH,cField,xData,nLin,xOldData|TP106VldNum(oMdlGQH,cField,xData,nLin,xOldData)} )

oModel := MPFormModel():New('GTPA106D',/*PreValidacao*/,{ |oModel|TP106DTDOK(oModel)},{|oModel|GA106Grv(oModel)})

oModel:AddFields('GQHMASTER',/*cOwner*/,oStruGQH)

oModel:SetActivate({|oModel| TP106DInit(oModel) })
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@sample		ViewDef()
@return		oView		Retorna objeto da interface
@author		Inovação - Servços
@since		15/09/2014
@version	P12
/*/
Static Function ViewDef()
	
Local oModel	:= FWLoadModel('GTPA106D')
Local cCpoVw	:=	"GQH_LOTE|GQH_DTALOC|GQH_AGENCI|GQH_NAGENC|GQH_TIPO|GQH_TPDESC|GQH_COMPLE|GQH_TIPPAS|" + ;
				    "GQH_SERIE|GQH_SUBSER|GQH_NUMCOM|GQH_NUMINI|GQH_NUMFIM|GQH_QUANT|GQH_FUNPAS|GQH_NFUNPA|"
Local oStruGQH	:= FWFormStruct(2,'GQH', {|cCampo| AllTrim(cCampo) + '|' $ cCpoVw })
Local oView
Local nOrderSer
Local nOrdEmi
Local nX	:= 0

oStruGQH:SetProperty( '*', MVC_VIEW_CANCHANGE ,.F.)

oStruGQH:SetProperty( 'GQH_NUMINI' , MVC_VIEW_CANCHANGE ,.T.)
oStruGQH:SetProperty( 'GQH_NUMFIM' , MVC_VIEW_CANCHANGE ,.T.)

oStruGQH:SetProperty("GQH_LOTE", MODEL_FIELD_INIT, {|| ""})

//Ordem dos campos
oStruGQH:SetProperty( 'GQH_LOTE'	, MVC_VIEW_ORDEM,	'01')
oStruGQH:SetProperty( 'GQH_DTALOC'	, MVC_VIEW_ORDEM,	'02')
oStruGQH:SetProperty( 'GQH_AGENCI'	, MVC_VIEW_ORDEM,	'03')
oStruGQH:SetProperty( 'GQH_NAGENC'	, MVC_VIEW_ORDEM,	'04')
oStruGQH:SetProperty( 'GQH_TIPO'	, MVC_VIEW_ORDEM,	'05')
oStruGQH:SetProperty( 'GQH_TPDESC'	, MVC_VIEW_ORDEM,	'06')
oStruGQH:SetProperty( 'GQH_COMPLE'	, MVC_VIEW_ORDEM,	'07')
oStruGQH:SetProperty( 'GQH_TIPPAS'	, MVC_VIEW_ORDEM,	'08')

oStruGQH:SetProperty( 'GQH_SERIE'	, MVC_VIEW_ORDEM,	'10')
oStruGQH:SetProperty( 'GQH_SUBSER'	, MVC_VIEW_ORDEM,	'11')
oStruGQH:SetProperty( 'GQH_NUMCOM'	, MVC_VIEW_ORDEM,	'12')
oStruGQH:SetProperty( 'GQH_NUMINI'	, MVC_VIEW_ORDEM,	'13')
oStruGQH:SetProperty( 'GQH_NUMFIM'	, MVC_VIEW_ORDEM,	'14')		
oStruGQH:SetProperty( 'GQH_QUANT'	, MVC_VIEW_ORDEM,	'15')

oStruGQH:SetProperty( 'GQH_FUNPAS'	, MVC_VIEW_ORDEM,	'21')
oStruGQH:SetProperty( 'GQH_NFUNPA'	, MVC_VIEW_ORDEM,	'22')	

// Crio os Agrupamentos de Campos
oStruGQH:AddGroup( 'GRUPO1', ''			, '' , 1 )
oStruGQH:AddGroup( 'GRUPO2', STR0002    , '' , 2 ) // Lote
oStruGQH:AddGroup( 'GRUPO3', STR0013	, '' , 3 ) // Destinatário

For nX := 1 To Len(oStruGQH:aFields) // Campos da tabela GI8
		
	If oStruGQH:aFields[nX][VIEWS_VIEW_ID] $ "GQH_LOTE,GQH_DTALOC,GQH_AGENCI,GQH_NAGENC,GQH_TIPO,GQH_TPDESC,GQH_COMPLE,GQH_TIPPAS"
		oStruGQH:SetProperty( oStruGQH:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
	ElseIf oStruGQH:aFields[nX][VIEWS_VIEW_ID] $ "GQH_SERIE,GQH_SUBSER,GQH_NUMCOM,GQH_NUMINI,GQH_NUMFIM,GQH_QUANT"
		oStruGQH:SetProperty( oStruGQH:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO2' )
	ElseIf oStruGQH:aFields[nX][VIEWS_VIEW_ID] $ "GQH_FUNPAS,GQH_NFUNPA"
		oStruGQH:SetProperty( oStruGQH:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO3' )
	EndIf
	
Next nX

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW',oStruGQH,'GQHMASTER')

oView:SetFieldAction('GQH_NUMINI', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )
oView:SetFieldAction('GQH_NUMFIM', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )

oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW','TELA')

oView:SetInsertMessage(STR0036,STR0037)//"Devolução Documentos"#"Devolução realizada com sucesso."	
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@sample		MenuDef()
@return		aRotina   Array contendo as opções do Menu
@author		Inovação
@since		13/03/2017
@version	P12
/*/
Static Function MenuDef()
	
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 	ACTION 'VIEWDEF.GTPA106D'  OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0034	ACTION 'VIEWDEF.GTPA106D'  OPERATION 3 ACCESS 0 // #Devolução

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} TP106DInit
Inicializa os valores dos campos na ativação do modelo.
@sample		TP106DInit()
@return		aRotina   Array contendo as opções do Menu
@author		Inovação
@since		13/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function TP106DInit(oModel)

Local oMldGQH  	:= oModel:GetModel('GQHMASTER')
Local aCpoAux		:= {}
Local nI			:= 0
Local lRet 		:= .T.
Local cAgAnt		:= nil

If oModel:GetOperation() == MODEL_OPERATION_INSERT 

	nRecno106D	:= GQH->(Recno())
	
	DbSelectArea("GQH")
	DbGoTo(nRecno106D)
	
	aCpoAux	:= GQH->( DbStruct())

	For nI:= 1 to Len(aCpoAux)
		If oMldGQH:HasField(aCpoAux[nI,1]) 
			If aCpoAux[nI,1] $ "GQH_LOTE"
				Loop
			EndIf

			If aCpoAux[nI,1] == "GQH_MOVTO"
				If ( lRet := oMldGQH:SetValue("GQH_MOVTO", "5") ) //-- Devolucao.
					Loop
				EndIf	
			EndIf
				 	
			If !( lRet := oMldGQH:SetValue(aCpoAux[nI,1], &(aCpoAux[nI,1]) ) )
				Loop
			EndIf
		EndIf
	Next nI
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP106DTDOK
Definição do Menu
@sample		
@return		aRotina   Array contendo as opções do Menu
@author		Inovação
@since		13/03/2017
@version	P12
/*/
Function TP106DTDOK(oModel)

Local nOperation	:= oModel:GetOperation()
Local cLoteAux		:= ""
Local aRet			:= {}
Local lRet			:= .T.
Local cLote			:= oModel:GetModel('GQHMASTER'):GetValue('GQH_LOTREM')
Local cTpDoc		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_TIPO')
Local cComple		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_COMPLE')
Local cTipPas		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_TIPPAS')
Local cSerie		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_SERIE')
Local cSubSer		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_SUBSER')
Local cNumCom		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_NUMCOM')
Local cNumIni		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_NUMINI')
Local cNumFim		:= oModel:GetModel('GQHMASTER'):GetValue('GQH_NUMFIM')
Local cStatus		:= "2,4,5,7"

//-- VALIDAÇÃO NA INSERÇÃO DE REGISTROS
If oModel:GetOperation() == MODEL_OPERATION_INSERT	
		
	//-- VERIFICA SE O RANGE INFORMADO ESTÁ DISPONIVEL PARA DEVOLUCAO.
	If !GTPDISPRANGE(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,cStatus,cLote)
		Help(" ",1,"TP106TDOK02",,STR0038,1,0)//"O Range Informado não está disponivel para devolução" 
		lRet := .F.
	EndIf	
	
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA106Grv
Commit do Model
@sample		GA106Grv(oModel)
@param      oModel - Objeto - Modelo do Programa
@return		lRet   - Lógico - Retorno para o Commit
@author		Inovação - Servços
@since		15/09/2014
@version	P12
/*/
Static Function GA106Grv(oModel)
	
Local aArea 	:= GetArea()
Local oMdlGQH  	:= oModel:GetModel('GQHMASTER')
Local cTipo    	:= oMdlGQH:GetValue('GQH_TIPO')
Local cSerie   	:= oMdlGQH:GetValue('GQH_SERIE')
Local cSubSer  	:= oMdlGQH:GetValue('GQH_SUBSER')
Local cNumCom  	:= oMdlGQH:GetValue('GQH_NUMCOM')
Local cNumIni  	:= oMdlGQH:GetValue('GQH_NUMINI')
Local cNumFim  	:= oMdlGQH:GetValue('GQH_NUMFIM')
Local cLote  	:= oMdlGQH:GetValue('GQH_LOTE')
Local cComple	:= oMdlGQH:GetValue('GQH_COMPLE') 
Local cTipPas  	:= oMdlGQH:GetValue('GQH_TIPPAS')
Local nQtdade	:= oMdlGQH:GetValue('GQH_QUANT')
Local cLotRem	:= oMdlGQH:GetValue('GQH_LOTREM')
Local aUpdate  	:= {}
Local lRet		:= .T.

Begin Transaction
	
	If oModel:VldData() .And. FwFormCommit(oModel)
		
		If oModel:GetOperation() == MODEL_OPERATION_INSERT 
			
			DBSelectArea("GQG")
			DbSetOrder(1)
			GQG->( DbSeek(xFilial("GQG") + cLotRem ) )
							
			AADD(aUpdate,{'GII_DTALOC',CTOD('')})
			AADD(aUpdate,{'GII_LOTALO',cLote}) //Lote Devolução da alocação
			AADD(aUpdate,{'GII_CODFUN',''})
			AADD(aUpdate,{'GII_STALOC',''})	
			AADD(aUpdate,{'GII_STATUS',IIF( GQG->GQG_MOVTO == "1", "2","4" )}) //Depara Remessa x Documentos
			
			If !( lRet := GA102ALot(cTipo, cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate) )		
				DisarmTransaction()		 
			EndIf
			
			//-------------------------------------------------------
			//-- ATUALIZA A QUANTIDADE E STATUS DA DEVOLUCAO
			//-------------------------------------------------------			
			DbSelectArea("GQH")
			DbGoTo(nRecno106D)
			
			If lRet .And. nRecno106D == GQH->(Recno())
				If ( GQH->GQH_QUANT - nQtdade ) = 0
					RecLock("GQH",.F.)
					GQH->GQH_QUANT := GQH->GQH_QUANT - nQtdade
					GQH->GQH_MOVTO := "4" //Finalizado sem saldo
					GQH->( MsUnlock() )	
				ElseIf ( GQH->GQH_QUANT - nQtdade ) >= 1 
					RecLock("GQH",.F.)
					GQH->GQH_QUANT := GQH->GQH_QUANT - nQtdade	
					GQH->( MsUnlock() )			
				EndIf		
			EndIf
		
		EndIf
	Else
		JurShowErro( oModel:GetModel():GetErrorMessage() )
		DisarmTransaction()
		lRet := .F.
	EndIf
	
End Transaction 
	
RestArea(aArea)
	
Return(lRet)