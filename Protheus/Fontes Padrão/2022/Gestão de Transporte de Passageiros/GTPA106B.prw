#Include 'Protheus.ch' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA106b.ch'

Static nRecno106B	:= GQH->(Recno())

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA106B()
TRANSFERE ALOCAÇÃO DE DOCUMENTOS ENTRE OS COLABORADORES.
@sample		GTPA106B()
@param 	
@return		oBrowse  
 @author		Inovação
@since			10/02/2017
@version		P12
/*/
Function GTPA106B()
Local lRet		:= .T.

DbSelectArea("GQH")
DbGoTo(Recno())

If GQH->GQH_MOVTO == '3'		
	Help(" ",1,STR0018,,STR0005,1,0) //"Nao pode transferir uma alocação com status baixada" 
ElseIf vazio(GQH->GQH_MOVTO)
	Help(" ",1,STR0018,,STR0017,1,0)//"Nao possui nenhum documento para transferencia"	
Else
	lRet := FWExecView( STR0006 , "VIEWDEF.GTPA106B", MODEL_OPERATION_INSERT, /*oDlg*/, ; //"Transferencia "
					{|| .T. } ,/*bOk*/, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/ )
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
//-------------------------------------------------------------------
Static Function ModelDef()
	
Local oModel := Nil
Local oStruGQH	:= FWFormStruct(1,'GQH')

oStruGQH:SetProperty('GQH_FUNPAS', MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, " Vazio() .Or. ExistCpo('GYG') .And. TP106BVldCpo() " ) )  
oStruGQH:SetProperty('GQH_NUMINI', MODEL_FIELD_VALID , {|oMdlGQH,cField,xData,nLin,xOldData|TP106VldNum(oMdlGQH,cField,xData,nLin,xOldData)} )
oStruGQH:SetProperty('GQH_NUMFIM', MODEL_FIELD_VALID , {|oMdlGQH,cField,xData,nLin,xOldData|TP106VldNum(oMdlGQH,cField,xData,nLin,xOldData)} )

oModel := MPFormModel():New('GTPA106B',/*PreValidacao*/,{ |oModel|TP106BTDOK(oModel)},{|oModel|GA106Grv(oModel)})

oModel:AddFields('GQHMASTER',/*cOwner*/,oStruGQH)
oModel:SetDescription(STR0006)
oModel:SetActivate({|oModel| TP106BInit(oModel) })

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
//-------------------------------------------------------------------
Static Function ViewDef()
	
Local oModel	:= FWLoadModel('GTPA106B')
Local oStruGQH	:= FWFormStruct(2,'GQH')
Local oView
Local nX	:= 0

oStruGQH:SetProperty( '*', MVC_VIEW_CANCHANGE ,.F.)

oStruGQH:SetProperty( 'GQH_NUMINI' , MVC_VIEW_CANCHANGE ,.T.)
oStruGQH:SetProperty( 'GQH_NUMFIM' , MVC_VIEW_CANCHANGE ,.T.)
oStruGQH:SetProperty( 'GQH_FUNPAS' , MVC_VIEW_CANCHANGE ,.T.)
oStruGQH:SetProperty( 'GQH_NFUNPA' , MVC_VIEW_CANCHANGE ,.T.)

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
oStruGQH:AddGroup( 'GRUPO1', '', '' , 1 )
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

//Removendo campos da view
oStruGQH:RemoveField('GQH_USRALO')
oStruGQH:RemoveField('GQH_USRBXA')
oStruGQH:RemoveField('GQH_MOVTO')
oStruGQH:RemoveField('GQH_DTOPE')
oStruGQH:RemoveField('GQH_COLORI')
oStruGQH:RemoveField('GQH_DESCOR')

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW',oStruGQH,'GQHMASTER')

oView:SetFieldAction('GQH_NUMINI', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )
oView:SetFieldAction('GQH_NUMFIM', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )

oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW','TELA')
	
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
//-------------------------------------------------------------------
Static Function MenuDef()
	
Local aRotina := {}

ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA106B'  OPERATION 3 ACCESS 0 // #Transferir
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GTPA106B'  OPERATION 2 ACCESS 0 // #Visualizar

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} TP106BInit
Inicializa os valores dos campos na ativação do modelo.
@sample		TP106BInit()
@return		aRotina   Array contendo as opções do Menu
@author		Inovação
@since		13/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function TP106BInit(oModel)

Local oMldGQH  	:= oModel:GetModel('GQHMASTER')
Local aCpoAux		:= {}
Local nI			:= 0
Local lRet 		:= .T.
Local cAgAnt		:= nil

If oModel:GetOperation() == 3 

	nRecno106B	:= GQH->(Recno())

	DbSelectArea("GQH")
	DbGoTo(nRecno106B)
	
	aCpoAux	:= GQH->( DbStruct())

	For nI:= 1 to Len(aCpoAux)
		If oMldGQH:HasField(aCpoAux[nI,1]) 
			If aCpoAux[nI,1] $ "GQH_LOTE"
				Loop
			EndIf
			If aCpoAux[nI,1] $ "GQH_FUNPAS"
				cAgAnt		:= &(aCpoAux[nI,1])
				Loop
			EndIf
			If aCpoAux[nI,1] == "GQH_MOVTO"
				If ( lRet := oMldGQH:SetValue("GQH_MOVTO", "2") ) //-- Transferencia.
					Loop
				EndIf	
			EndIf
			
			If aCpoAux[nI,1] == "GQH_COLORI"
				If ( lRet := oMldGQH:SetValue("GQH_COLORI", cAgAnt) )
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
/*/{Protheus.doc} TP106BTDOK
Definição do Menu

@sample		

@return		aRotina   Array contendo as opções do Menu

@author		Inovação
@since		13/03/2017
@version	P12

/*/
//-------------------------------------------------------------------
Function TP106BTDOK(oModel)

Local oMdlGQH       := oModel:GetModel('GQHMASTER')
Local lRet			:= .T.
Local cTpDoc		:= oMdlGQH:GetValue('GQH_TIPO')
Local cComple		:= oMdlGQH:GetValue('GQH_COMPLE')
Local cTipPas		:= oMdlGQH:GetValue('GQH_TIPPAS')
Local cSerie		:= oMdlGQH:GetValue('GQH_SERIE')
Local cSubSer		:= oMdlGQH:GetValue('GQH_SUBSER')
Local cNumCom		:= oMdlGQH:GetValue('GQH_NUMCOM')
Local cNumIni		:= oMdlGQH:GetValue('GQH_NUMINI')
Local cNumFim		:= oMdlGQH:GetValue('GQH_NUMFIM')
Local cStatus		:= "2,4,5"

//-- VALIDAÇÃO NA INSERÇÃO DE REGISTROS
If oModel:GetOperation() == MODEL_OPERATION_INSERT	
	
	//-- Valida se a numeração dos documentos da remessa foram cadastrados na rotina de entrada de documentos 
	//-- (Série + Subsérie + Número Complemento + Número Documento). GQHX x GI8
	If !TP106PESQ(cTpDoc,cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim )
		lRet := .F.
	EndIf
	
	//-- VALIDA A DISPONIBILIDADE DO RANGE INFORMADO PARA ALOCAÇÃO DO DOCUMENTO.
	If lRet .And. !GTPDISPRANGE(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,cStatus)
		Help(" ",1,"TP106TDOK02",,STR0022,1,0)//"O Range Informado não está disponivel para transferência" 
		lRet := .F.
	EndIf	
    
    If lRet .and. !G102DTVENC(cTpDoc, cSerie, cSubSer, cNumCom, cNumIni, cNumFim)
        lRet := .F.
        Help(" ",1,'TP107BTDOK',,'Lote de documentos informados não se encontra dentro da validade dos registros',1,0) 
    Endif
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
//-------------------------------------------------------------------
Static Function GA106Grv(oModel)
	
Local aArea 	:= GetArea()
Local oMdlGQH  	:= oModel:GetModel('GQHMASTER')
Local cTipo    	:= oMdlGQH:GetValue('GQH_TIPO')
Local cSerie   	:= oMdlGQH:GetValue('GQH_SERIE')
Local cSubSer  	:= oMdlGQH:GetValue('GQH_SUBSER')
Local cNumCom  	:= oMdlGQH:GetValue('GQH_NUMCOM')
Local cNumIni  	:= oMdlGQH:GetValue('GQH_NUMINI')
Local cNumFim  	:= oMdlGQH:GetValue('GQH_NUMFIM')
Local cFunPas  	:= oMdlGQH:GetValue('GQH_FUNPAS')
Local cLote  		:= oMdlGQH:GetValue('GQH_LOTE')
Local cComple		:= oMdlGQH:GetValue('GQH_COMPLE') 
Local cTipPas  	:= oMdlGQH:GetValue('GQH_TIPPAS')
Local nQtdade		:= oMdlGQH:GetValue('GQH_QUANT')
Local aUpdate  	:= {}
Local lRet			:= .T.

Begin Transaction
	
	If oModel:VldData() .And. FwFormCommit(oModel)
		If oModel:GetOperation() == MODEL_OPERATION_INSERT 
			AADD(aUpdate,{'GII_DTALOC',DDATABASE})
			AADD(aUpdate,{'GII_LOTALO',cLote}) 
			AADD(aUpdate,{'GII_CODFUN',cFunPas})
			AADD(aUpdate,{'GII_STALOC','1'})	
			AADD(aUpdate,{'GII_STATUS','7'}) //Transferencia Alocação
			
			If !( lRet := GA102ALot(cTipo, cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate) )		
				DisarmTransaction()		 
			EndIf
			
			//-------------------------------------------------------
			//-- ATUALIZA A QUANTIDADE E STATUS DA Alocaçãp
			//-------------------------------------------------------			
			DbSelectArea("GQH")
			DbGoTo(nRecno106B)
			If lRet .And. nRecno106B == GQH->(Recno())
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
	
	RestArea(aArea)

End Transaction
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} TP106PESQ

@sample	  TPRetLote(cTipo,cComple, cTipPas,cSerie,cSubSer,cNumCom,cBilhet)

@param   
cTipDoc  - Caracter - Tipo do Documento  
cComple   - Caracter - Complemento
cTipPas   - Caracter - Tipo passagaeiro
cSerie   - Caracter - Serie do Documento
cSubSer  - Caracter - Subserie do Documento
cNumCom  - Caracter - Numero complemento do Documentoadmin
cBilhet  - Caracter - Numero do Documento

@return	 - Logico - lRet - Retorna .T. Se a numeração do Doc
está foi encontrada na Entrada de Lote. 		 
		 
@author		Inovação
@since		09/03/2017
@version	P12

/*/
//-------------------------------------------------------------------
Static Function TP106PESQ(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim)

Local cAliasTemp := GetNextAlias()
Local lRet := .F.
Local aQuery
	BeginSql Alias cAliasTemp
	
		SELECT GQH.GQH_FILIAL, GQH.GQH_SERIE, GQH.GQH_SUBSER, GQH.GQH_NUMCOM, 
				GQH.GQH_NUMINI, GQH.GQH_NUMFIM, GQH.GQH_TIPPAS, GQH.GQH_COMPLE
			FROM %Table:GQH% GQH
			WHERE 
				GQH.GQH_FILIAL = %xFilial:GQH% 
			 	AND GQH.GQH_TIPO  = %Exp:cTpDoc%
			 	AND GQH.GQH_COMPLE  = %Exp:cComple%
			 	AND GQH.GQH_TIPPAS  = %Exp:cTipPas%
			 	AND GQH.GQH_SERIE  = %Exp:cSerie%
			 	AND GQH.GQH_SUBSER  = %Exp:cSubSer%
			 	AND GQH.GQH_NUMCOM  = %Exp:cNumCom%
			 	AND ( 	%Exp:cNumIni% BETWEEN GQH.GQH_NUMINI AND GQH.GQH_NUMFIM 
			  			AND %Exp:cNumFim% BETWEEN GQH.GQH_NUMINI AND GQH.GQH_NUMFIM )
			 	AND %NotDel%
			ORDER BY GQH.GQH_FILIAL, GQH.GQH_TIPO, GQH.GQH_SERIE, 
				GQH.GQH_SUBSER, GQH.GQH_NUMCOM, GQH.GQH_NUMINI 
	EndSql
aQuery	:= GetLastQuery()
	DbSelectArea(cAliasTemp)
	lRet := .T.
	If (cAliasTemp)->(EOF())
		Help(" ",1,STR0016,,STR0009,1,0)//"A numeração deste documento não foi encontrada na Entrada de Documentos ou complemento do documento não é PE(Passagem Estrada)" 
		lRet := .F.
	EndIf
		
	(cAliasTemp)->(DbCloseArea())
	
Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TP106BVldCpo
Validação do campo Colaborador.
@sample		TP106BVldCpo()
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*/
Function TP106BVldCpo()

Local lRet := .T.

	If  AllTrim(&(ReadVar())) == AllTrim(GQH->GQH_FUNPAS)
		Help(" ",1,STR0021,,STR0020,1,0)//"Transfererir Alocação"#"Está alocação já se encontra em poder deste colaborador"
		lRet := .F.
	EndIf


Return(lRet)