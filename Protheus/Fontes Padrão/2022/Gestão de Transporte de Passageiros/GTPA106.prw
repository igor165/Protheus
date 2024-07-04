#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#Include 'GTPA106.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA106
BROWSE COM AS ALOCAÇÕES DOS DOCUMENTOS 
@sample		GTPA106()
@author		Inovação - Serviços
@since		15/09/15
@version	P12
/*///-------------------------------------------------------------------
Function GTPA106(lHist)
		
	Local oBrowse 	:= FWMBrowse():New()
	Default lHist := .F.
		oBrowse:SetAlias('GQH')
	If !lHist
		oBrowse:CleanFilter()
		oBrowse:SetFilterDefault ( "GQH_MOVTO == '1' .Or. GQH_MOVTO == '2' .Or. GQH_MOVTO == '3'")
		//--------------------------------------
		// Adiciona as legendas no browse - Status Alocação
		//--------------------------------------
		oBrowse:AddLegend( "GQH_MOVTO == '1'","GREEN"	,	OemToAnsi(STR0026))// "Alocação - Aberta"
		oBrowse:AddLegend( "GQH_MOVTO == '2'","BLUE"	,	OemToAnsi(STR0027))// "Alocação - Transferida"
		oBrowse:AddLegend( "GQH_MOVTO == '3'","RED"		,	OemToAnsi(STR0028))// "Alocação - Baixada"
		oBrowse:AddLegend( "GQH_MOVTO == '5'","ORANGE"	,	OemToAnsi(STR0030))// "Alocação - Devolvida"
		
	Else
		
		If GQH->GQH_MOVTO == '3'
			oBrowse:CleanFilter()
			oBrowse:SetFilterDefault ( "GQH_MOVTO == '4' .AND. GQH_LOTANT == " + "'" + GQH->GQH_LOTANT + "'" + ;
			".Or." + "'" + GQH->GQH_LOTE + "'" + " == GQH->GQH_LOTANT ")
		ElseIf GQH->GQH_MOVTO == '1' .OR. GQH->GQH_MOVTO == '2'
			oBrowse:CleanFilter()
			oBrowse:SetFilterDefault ( "GQH_MOVTO == '4' .AND. GQH_LOTANT == " + "'" + GQH->GQH_LOTE + "'")
		EndIf 
		 
	EndIf
	
	If !FwIsInCall('GTPA106HIS')	
		oBrowse:AddButton( STR0040, {|| GTPA106HIS(),GA106Filt(oBrowse)}) // "Historico"
	EndIf
	
	oBrowse:SetDescription(STR0001)//Alocação de Documentos
	oBrowse:Activate()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*///-------------------------------------------------------------------
Static Function ModelDef()
	
	Local oModel 	:= Nil
	Local oStruGQH	:= FWFormStruct(1,'GQH')
	Local bCommit	:= { |oModel|GA106Grv(oModel)}
	Local bPost		:= { |oModel|TP106TDOK(oModel)}
	Local bValid	:= { |oModel|GA106VldAg(oModel)}
	
		oStruGQH:SetProperty('GQH_AGENCI', MODEL_FIELD_VALID, bValid )
		oStruGQH:SetProperty('GQH_NUMINI', MODEL_FIELD_VALID , {|oMdlGQH,cField,xData,nLin,xOldData|TP106VldNum(oMdlGQH,cField,xData,nLin,xOldData)} )
		oStruGQH:SetProperty('GQH_NUMFIM', MODEL_FIELD_VALID , {|oMdlGQH,cField,xData,nLin,xOldData|TP106VldNum(oMdlGQH,cField,xData,nLin,xOldData)} )
		oStruGQH:SetProperty('GQH_COMPLE', MODEL_FIELD_VALID     , {|| .T.})
		oStruGQH:SetProperty("GQH_COMPLE", MODEL_FIELD_INIT , "")

		oModel := MPFormModel():New('GTPA106',/*PreValidacao*/,bPost,bCommit)
		oStruGQH:AddTrigger("GQH_AGENCI", "GQH_AGENCI"  ,{ || .T. }, { |oModel| TrgUlNum( oModel )  } )
		oStruGQH:AddTrigger("GQH_AGENCI", "GQH_AGENCI"  ,{ || .T. }, { |oModel| TrgSaldo( oModel )  } )
		oStruGQH:AddTrigger("GQH_TIPO", "GQH_TIPO"  ,{ || .T. }, { |oModel| TrgUlNum( oModel )  } )
		oStruGQH:AddTrigger("GQH_TIPO", "GQH_TIPO"  ,{ || .T. }, { |oModel| TrgSaldo( oModel )  } )		
		oStruGQH:AddTrigger("GQH_SERIE", "GQH_SERIE"  ,{ || .T. }, { |oModel| TrgUlNum( oModel )  } )
		oStruGQH:AddTrigger("GQH_SERIE", "GQH_SERIE"  ,{ || .T. }, { |oModel| TrgSaldo( oModel )  } )
		oStruGQH:AddTrigger("GQH_SUBSER", "GQH_SUBSER"  ,{ || .T. }, { |oModel| TrgUlNum( oModel )  } )
		oStruGQH:AddTrigger("GQH_SUBSER", "GQH_SUBSER"  ,{ || .T. }, { |oModel| TrgSaldo( oModel )  } )	
		oStruGQH:AddTrigger("GQH_NUMCOM", "GQH_NUMCOM"  ,{ || .T. }, { |oModel| TrgUlNum( oModel )  } )
		oStruGQH:AddTrigger("GQH_NUMCOM", "GQH_NUMCOM"  ,{ || .T. }, { |oModel| TrgSaldo( oModel )  } )		
		oStruGQH:AddTrigger("GQH_NUMCOM", "GQH_NUMCOM"  ,{ || .T. }, { |oModel| TrgUlNum( oModel )  } )
		oStruGQH:AddTrigger("GQH_NUMCOM", "GQH_NUMCOM"  ,{ || .T. }, { |oModel| TrgSaldo( oModel )  } ) 
		oStruGQH:SetProperty("GQH_SERIE",MODEL_FIELD_WHEN,{|oModel,cField| HabSerie( oModel )})
		oStruGQH:SetProperty("GQH_SUBSER",MODEL_FIELD_WHEN,{|oModel,cField| HabSubS( oModel )})		
		oStruGQH:SetProperty("GQH_NUMCOM",MODEL_FIELD_WHEN,{|oModel,cField| HabNumCp( oModel )})
		oStruGQH:SetProperty("GQH_NUMINI",MODEL_FIELD_WHEN,{|oModel,cField| HabNumIn( oModel )})
		oStruGQH:SetProperty("GQH_NUMFIM",MODEL_FIELD_WHEN,{|oModel,cField| HabNumIn( oModel )})
		
		oModel:AddFields('GQHMASTER',/*cOwner*/,oStruGQH)
		oModel:SetDescription(STR0001)//Alocação de Documentos

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@sample		ViewDef()
@return		oView		Retorna objeto da interface
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*///-------------------------------------------------------------------
Static Function ViewDef()
	
	Local oModel	:= FWLoadModel('GTPA106')
	Local cCpoVw	:=	"GQH_LOTE|GQH_DTALOC|GQH_AGENCI|GQH_NAGENC|GQH_TIPO|GQH_TPDESC|GQH_COMPLE|GQH_TIPPAS|" + ;
					    "GQH_SERIE|GQH_SUBSER|GQH_NUMCOM|GQH_NUMINI|GQH_NUMFIM|GQH_QUANT|GQH_SALDO|GQH_FUNPAS|GQH_NFUNPA|"
	Local oStruGQH	:= FWFormStruct(2,'GQH', {|cCampo| AllTrim(cCampo) + '|' $ cCpoVw })
	Local oView		:= Nil
	Local nX		:= 0
		
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
		oStruGQH:SetProperty( 'GQH_SALDO'	, MVC_VIEW_ORDEM,	'16')
		
		oStruGQH:SetProperty( 'GQH_FUNPAS'	, MVC_VIEW_ORDEM,	'21')
		oStruGQH:SetProperty( 'GQH_NFUNPA'	, MVC_VIEW_ORDEM,	'22')	
			
		// Crio os Agrupamentos de Campos
		oStruGQH:AddGroup( 'GRUPO1', ''            , '' , 1 )
		oStruGQH:AddGroup( 'GRUPO2', STR0020        , '' , 2 )//Lote
		oStruGQH:AddGroup( 'GRUPO3', STR0021     , '' , 3 )//Emissor
		
		
		For nX := 1 To Len(oStruGQH:aFields) // Campos da tabela GI8
						
			If oStruGQH:aFields[nX][VIEWS_VIEW_ID] $ "GQH_LOTE,GQH_DTALOC,GQH_AGENCI,GQH_NAGENC,GQH_TIPO,GQH_TPDESC,GQH_COMPLE,GQH_TIPPAS"
				oStruGQH:SetProperty( oStruGQH:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
			ElseIf oStruGQH:aFields[nX][VIEWS_VIEW_ID] $ "GQH_SERIE,GQH_SUBSER,GQH_NUMCOM,GQH_NUMINI,GQH_NUMFIM,GQH_QUANT|GQH_SALDO"
				oStruGQH:SetProperty( oStruGQH:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO2' )
			ElseIf oStruGQH:aFields[nX][VIEWS_VIEW_ID] $ "GQH_FUNPAS,GQH_NFUNPA"
				oStruGQH:SetProperty( oStruGQH:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO3' )
			EndIf
			
		Next nX
		
		oStruGQH:SetProperty("GQH_SALDO", MVC_VIEW_CANCHANGE, .F. )
				
		oView := FWFormView():New()
		oView:SetModel(oModel)
		oView:SetFieldAction('GQH_NUMINI', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )
		oView:SetFieldAction('GQH_NUMFIM', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )
		oView:AddField('VIEW',oStruGQH,'GQHMASTER')
		oView:CreateHorizontalBox('TELA',100)
		oView:SetOwnerView('VIEW','TELA')
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@sample		MenuDef()
@return		aRotina   Array contendo as opções do Menu
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*///-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	
		ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.GTPA106'  OPERATION 2 ACCESS 0 // #Visualizar
		If !FwIsInCall('GTPA106HIS')
			ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.GTPA106'  OPERATION 3 ACCESS 0 // #Incluir
			ADD OPTION aRotina TITLE STR0008 ACTION 'GTPA106B'  OPERATION 3 ACCESS 0 // #Transferir
			ADD OPTION aRotina TITLE STR0034 ACTION 'GTPA106D'  OPERATION 3 ACCESS 0 // #Devolução
			ADD OPTION aRotina TITLE STR0022 ACTION 'GTPA106C'  OPERATION 3 ACCESS 0 // #Baixa
			ADD OPTION aRotina TITLE STR0039 ACTION 'TP106EST'  OPERATION 3 ACCESS 0 // #Estornar Baixa
		EndIf
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} GA106Grv
Commit do Model
@sample		GA106Grv(oModel)
@param      oModel - Objeto - Modelo do Programa
@return		lRet   - Lógico - Retorno para o Commit
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*///-------------------------------------------------------------------
Static Function GA106Grv(oModel)

	Local aArea 	:= GetArea()
	Local aUpdate  	:= {}
	Local oMdlGQH  	:= oModel:GetModel('GQHMASTER')
	Local cLote		:= oMdlGQH:GetValue('GQH_LOTE')
	Local dDtLoc	:= oMdlGQH:GetValue('GQH_DTALOC')
	Local cTipo 	:= oMdlGQH:GetValue('GQH_TIPO')
	Local cComple	:= oMdlGQH:GetValue('GQH_COMPLE')
	Local cTipPas	:= oMdlGQH:GetValue('GQH_TIPPAS')
	Local cSerie	:= oMdlGQH:GetValue('GQH_SERIE')
	Local cSubSer	:= oMdlGQH:GetValue('GQH_SUBSER')
	Local cNumCom	:= oMdlGQH:GetValue('GQH_NUMCOM')
	Local cNumIni	:= oMdlGQH:GetValue('GQH_NUMINI')
	Local cNumFim	:= oMdlGQH:GetValue('GQH_NUMFIM')
	Local cCodCo	:= oMdlGQH:GetValue('GQH_FUNPAS')
	Local lRet		:= .T.

		Begin Transaction
				
			If oModel:VldData() .And. FwFormCommit(oModel)
		
				If oModel:GetOperation() == MODEL_OPERATION_INSERT
				
					AADD(aUpdate,{'GII_DTALOC',dDtLoc})
					AADD(aUpdate,{'GII_LOTALO' ,cLote})
					AADD(aUpdate,{'GII_CODFUN',cCodCo})
					AADD(aUpdate,{'GII_STALOC','1'})
					AADD(aUpdate,{'GII_STATUS','5'})
				
					If !( lRet := GA102ALot(cTipo, cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate) )
						DisarmTransaction()
					EndIf
				 
				EndIf
			Else
				JurShowErro( oModel:GetModel():GetErrorMessage() )
				DisarmTransaction()
				lRet	:= .F.
			EndIf
		
			RestArea(aArea)
	
		End Transaction

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TP106TDOK
Valida se está tudo ok para commit
@sample		GA106Grv(oModel)
@param      oModel - Objeto - Modelo do Programa
@return		lRet   - Lógico - Retorno para o Commit
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*///-------------------------------------------------------------------
Function TP106TDOK(oModel)

	Local oSubMdl		:= oModel:GetModel('GQHMASTER')
	Local cTpDoc		:= oSubMdl:GetValue('GQH_TIPO')
	Local cComple		:= oSubMdl:GetValue('GQH_COMPLE')
	Local cTipPas		:= oSubMdl:GetValue('GQH_TIPPAS')
	Local cSerie		:= oSubMdl:GetValue('GQH_SERIE')
	Local cSubSer		:= oSubMdl:GetValue('GQH_SUBSER')
	Local cNumCom		:= oSubMdl:GetValue('GQH_NUMCOM')
	Local cNumIni		:= oSubMdl:GetValue('GQH_NUMINI')
    Local cNumFim		:= oSubMdl:GetValue('GQH_NUMFIM')
    Local dDtEmiss		:= oSubMdl:GetValue('GQH_DTALOC')
	Local cStatus		:= "2,4"
	Local lRet			:= .T.

	//-- VALIDAÇÃO NA INSERÇÃO DE REGISTROS
		If oModel:GetOperation() == MODEL_OPERATION_INSERT
		
		//-- Valida se a numeração dos documentos da remessa foram cadastrados na rotina de entrada de documentos 
		//-- (Série + Subsérie + Número Complemento + Número Documento). GQHX x GI8
			If !TP106PESQ(cTpDoc,cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,oSubMdl )
				Help(" ",1,"TP106TDOK01",,STR0031,1,0) //"A numeração deste documento não foi encontrada na remessa de Documentos."
				lRet := .F.
			EndIf
		
		//-- VALIDA A DISPONIBILIDADE DO RANGE INFORMADO PARA ALOCAÇÃO DO DOCUMENTO.
			If lRet .And. !GTPDISPRANGE(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,cStatus)
				Help(" ",1,"TP106TDOK02",,STR0032,1,0)//"O range informado não está disponível para alocação."
				lRet := .F.
            EndIf
            
            If lRet .and. !G102DTVENC(cTpDoc, cSerie, cSubSer, cNumCom, cNumIni, cNumFim, dDtEmiss)
                lRet := .F.
                Help(" ",1,'G102DTVENC',,'Lote de documentos informados não se encontra dentro da validade dos registros',1,0) 
            Endif
		EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP106PESQ
@sample	  TPRetLote(cTipo,cComple, cTipPas,cSerie,cSubSer,cNumCom,cBilhet)
@param   
cTipDoc  - Caracter - Tipo do Documento  
cComple   - Caracter - Complemento
cTipPas   - Caracter - Tipo passagaeiro
cSerie   - Caracter - Serie do Documento
cSubSer  - Caracter - Subserie do Documento
cNumCom  - Caracter - Numero complemento do Documento
cBilhet  - Caracter - Numero do Documento
@return	 - Logico - lRet - Retorna .T. Se a numeração do Doc
está foi encontrada na Entrada de Lote. 
@author		Inovação
@since		09/03/2017
@version	P12
/*///-------------------------------------------------------------------
Static Function TP106PESQ(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim,oSubMdl)

	Local cAliasTemp	:= GetNextAlias()
	Local lRet 			:= .T.

		BeginSql Alias cAliasTemp
		
			SELECT GQG.GQG_FILIAL, GQG.GQG_LOTE, GQG.GQG_SERIE, GQG.GQG_SUBSER, GQG.GQG_NUMCOM, GQG.GQG_NUMINI,
			GQG.GQG_NUMFIM, GQG.GQG_TIPPAS, GQG.GQG_COMPLE
			FROM %Table:GQG% GQG
			WHERE
			GQG_FILIAL = %xFilial:GQG%
			AND GQG.GQG_TIPO  = %Exp:cTpDoc%
			AND GQG.GQG_COMPLE  = %Exp:cComple%
			AND GQG.GQG_TIPPAS  = %Exp:cTipPas%
			AND GQG.GQG_SERIE  = %Exp:cSerie%
			AND GQG.GQG_SUBSER  = %Exp:cSubSer%
			AND GQG.GQG_NUMCOM  = %Exp:cNumCom%
			AND ( 	%Exp:cNumIni% BETWEEN GQG.GQG_NUMINI AND GQG.GQG_NUMFIM
			AND %Exp:cNumFim% BETWEEN GQG.GQG_NUMINI AND GQG.GQG_NUMFIM)
			AND %NotDel%
			ORDER BY GQG_FILIAL, GQG_TIPO, GQG_SERIE, GQG_SUBSER, GQG_NUMCOM, GQG_NUMINI
		EndSql
		
		If !(cAliasTemp)->(EOF())
			oSubMdl:SetValue("GQH_LOTREM", (cAliasTemp)->GQG_LOTE )
		Else
			Help(" ",1,"TP106TDOK02",,STR0024,1,0)//"A numeração deste documento não foi encontrada na Entrada de Documentos ou complemento do documento não é PE(Passagem Estrada)"
			lRet := .F.
		EndIf
			
		(cAliasTemp)->(DbCloseArea())
	
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA106VldAg
@sample	  TPRetLote(cTipo,cComple, cTipPas,cSerie,cSubSer,cNumCom,cBilhet)
@param   
cTipDoc  - Caracter - Tipo do Documento  
cComple   - Caracter - Complemento
cTipPas   - Caracter - Tipo passagaeiro
cSerie   - Caracter - Serie do Documento
cSubSer  - Caracter - Subserie do Documento
cNumCom  - Caracter - Numero complemento do Documento
cBilhet  - Caracter - Numero do Documento
@return	 - Logico - lRet - Retorna .T. Se a numeração do Doc
está foi encontrada na Entrada de Lote. 		 
@author		Inovação
@since		09/03/2017
@version	P12
/*///-------------------------------------------------------------------
Function GA106VldAg(oModel)

	Local cAgenc	:= oModel:GetValue('GQH_AGENCI')
	Local cUserId	:= __cUserId
	Local aArea    	:= GetArea()
	Local aAreaG9X 	:= G9X->(GetArea())
	Local lRet := .T.
	
		dbSelectArea('G9X')//NUM. E MOVIMENTO DE BILHETES
		G9X->(DbSetOrder(2))
	
		If !(G9X->(DbSeek(xFilial("G9X") + cAgenc + cUserId)))
			Help(" ",1,"TP106VldAg01",,STR0025,1,0)//"Usuario não vinculado com agência"
			oModel:ClearField('GQH_AGENCI')
		EndIf
	
		RestArea(aArea)
		RestArea(aAreaG9X)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP106VldNum
Valida os campos do range Numero Inicial/Final.
@sample	TP106VldNum(oMdlGQG,cField,xData,nLin,xOldData)
@param oMdlGQG  Objeto    Modelo de Dados GQG
cField   Caracter  Nome do campo
xData    xValor    Valor dos dados
nLin     nLinha    Numero da Linha
xOldData xValor    Valor Anterior do Campos/
@author		Inovação - Serviços
@since		25/08/2015
@version	P12
/*///-------------------------------------------------------------------
Function TP106VldNum(oMdlGQH,cField,xData,nLin,xOldData)

	Local lRet 		:= .T.
		
		If cField == "GQH_NUMINI" .and. !Empty(oMdlGQH:GetValue('GQH_NUMFIM'))
			lRet := val(oMdlGQH:GetValue('GQH_NUMFIM')) >= val(xData)
		ElseIf cField == "GQH_NUMFIM".and. !Empty(oMdlGQH:GetValue('GQH_NUMINI'))
			lRet := val(xData) >= val(oMdlGQH:GetValue('GQH_NUMINI'))
		EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TP106EST
Valida e executa o estorno da baixa 
@sample	  TP107MNT(nOpc)
@param   
nOpc 	- Caracter - opção 
@return	 - Logico - lRet - Retorna .T. Valida Estorno 	 
@author		Inovação
@since		09/03/2017/
@version	P12
/*///-------------------------------------------------------------------
Function TP106EST(nOpc)

	Local cMsg	:= ""
	Local cMsg2 := ""
	Local lRet	:= .T.
	
		//-- Se há remessa
		If !Empty(GQH->GQH_LOTE)
		cMsg := STR0041 //"Tem certeza que deseja realizar o estorno da baixa?"
		cMsg2:= STR0039 //"Estorno da Baixa"
		//-----------------------------
		// VALIDA ESTORNO DA BAIXA
		//-----------------------------
			If ( lRet := FwAlertYesNo("",cMsg) )
				If GQH->GQH_MOVTO != "3"
				FwAlertWarning( STR0042, STR0039 ) //O estorno só é permitido para alocações de baixa."#"Estorno Baixa"
					lRet := .F.
				EndIf
	
			//-- PROCESSA MANUTENCAO DA REMESSA
				If lRet
					Processa({|lEnd| TPEXECEST()  },cMsg2)
				EndIf
			EndIf
		
		Else
			HELP(" ",1,"ARQVAZIO")
			lRet := .T.
		EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TPEXECEST
REALIZA O ESTORNO DA BAIXA - ALOCACAO
@sample	  TPEXECEST()
@return	- Logico - lRet - Retorna .T. Valida Estorno 	 
@author		Inovação
@since		09/03/2017/
@version	P12
/*///-------------------------------------------------------------------
Static Function TPEXECEST()

	Local cTipo 	:= GQH->GQH_TIPO
	Local cComple 	:= GQH->GQH_COMPLE
	Local cTipPas	:= GQH->GQH_TIPPAS
	Local cSerie	:= GQH->GQH_SERIE
	Local cSubSer	:= GQH->GQH_SUBSER
	Local cNumCom	:= GQH->GQH_NUMCOM
	Local cNumIni	:= GQH->GQH_NUMINI
	Local cNumFim	:= GQH->GQH_NUMFIM
	Local nQtdAtu	:= GQH->GQH_QUANT
	Local cLoteAnt	:= GQH->GQH_LOTANT  //Lote Anterior a BAIXA
	Local nRecAtu	:= GQH->(Recno())
	Local cStatusAnt:= ""
	Local aUpdate	:= {}
	Local nRecAnt	:= 0
	Local lRet		:= .T.
		
		DbSelectArea("GQH")
		DbSetOrder(1) // GII_FILIAL+GII_LOTREM
		// Posicione no lote anterior ao cancelamento
		If GQH->( DbSeek(xFilial("GQH") + cLoteAnt ) )
	
		//-- Atualiza Qtdade
			nQtdAtu += GQH->GQH_QUANT
		//-- Guarda dados do lote anterior
			nRecAnt	 := GQH->(Recno())
	
			If GQH->GQH_MOVTO == "4"
				If nQtdAtu > 0 .And. !Empty(GQH->GQH_COLORI)
					cStatusAnt	:= "4"
				ElseIf nQtdAtu > 0 .And. Empty(GQH->GQH_COLORI)
					cStatusAnt	:= "5"
				EndIf
			Else
			//------------------------------------------------------------------------------------------------		
			//Status do movimento Remessa GQH_MOVTO
			//1 = Alocacao 2 = Transferência da Alocacao		
			//Status Documento GII_STATUS
			//1=Abertura Lote; 2=Remessa; 3=Cancelamento;4=Tranferência; 5=Alocação; 6=Baixa Alocação
				cStatusAnt := IIF( GQH->GQH_MOVTO == "1","2","4")
			EndIf
		//-- Dados a serem atualizados na GII
			AADD(aUpdate,{'GII_LOTALO',cLoteAnt})
			AADD(aUpdate,{'GII_DTCANC',CTOD("")})
			AADD(aUpdate,{'GII_STATUS',cStatusAnt})
			lRet := GA102ALot(cTipo, cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate)
		//------------------------------------------------------------------------------------------------
		
		// NO ESTORNO DELETA A BAIXA DA ALOCACAOE RETORNA
		// A QUANTIDADE DA ALOCACAO DE ORIGEM
			If lRet
			//-- Forca o posicionamento da remessa anterior a baixa.
			//-- Caso tenha desposicionado
				If nRecAnt != GQH->(Recno())
					DbgoTo(nRecAnt)
				EndIf
			
				RecLock("GQH",.F.)
				GQH->GQH_QUANT := nQtdAtu
			
				If nQtdAtu > 0 .And. !Empty(GQH->GQH_COLORI)
					GQH->GQH_MOVTO	:= "2"
				ElseIf nQtdAtu > 0 .And. Empty(GQH->GQH_COLORI)
					GQH->GQH_MOVTO	:= "1"
				EndIf
					
				GQH->(MsUnlock())
			
			//-- Exclui alocacao baixada
				DbGoTo(nRecAtu)
				RecLock("GQH",.F.)
				GQH->GQH_MOVTO	:= "4" 
				GQH->(MsUnlock())
			EndIf
	
		EndIf

Return(lRet)

//------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} HabSerie
Habilita a edição do campo Série
@type function
@author cris
@since 26/12/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------------	
Static Function HabSerie( oModel )

	Local lHabilit	:= .F.
	
	If 	!Empty(oModel:GetValue("GQH_AGENCI")) .AND. !Empty(oModel:GetValue("GQH_TIPO"))		
		lHabilit	:= .T.
	EndIf
		
Return lHabilit

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HabSubS
Habilita a sub-serie
@type function
@author cris
@since 26/12/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------------
Static Function HabSubS( oModel )

	Local lHabilit	:= .F.
	
		if 	!Empty(oModel:GetValue("GQH_SERIE"))
			lHabilit	:= .T.
		EndIf
		
Return lHabilit

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HabNumCp
Habilita o campo Num.Comple.
@type function
@author cris
@since 26/12/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------------
Static Function HabNumCp( oModel )

	Local lHabilit	:= .F.
	
		if 	!Empty(oModel:GetValue("GQH_SERIE")) .AND. !Empty(oModel:GetValue("GQH_SUBSER"))
			lHabilit	:= .T.
		EndIf
		
Return lHabilit

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} HabNumIn
Habilita os campos Num.Inicial e Num.Final
@type function
@author cris
@since 26/12/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------------
Static Function HabNumIn( oModel )

	Local lHabilit	:= .F.
	
		if 	!Empty(oModel:GetValue("GQH_SERIE")) .AND. !Empty(oModel:GetValue("GQH_SUBSER")) 
			lHabilit	:= .T.
		EndIf
		
Return lHabilit

//------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} TrgUlNum
busca o primeiro bilhete que ainda não foi alocado.
@type function
@author cris
@since 26/12/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------------	
Static Function TrgUlNum( oModel )

	Local cTpDoc	:= oModel:GetValue("GQH_TIPO")
	Local cCompl	:= oModel:GetValue("GQH_COMPLE")
	Local cTpPas	:= oModel:GetValue("GQH_TIPPAS")
	Local cSerie	:= oModel:GetValue("GQH_SERIE")
	Local cSubSer	:= oModel:GetValue("GQH_SUBSER")
	Local cNumCpl	:= oModel:GetValue("GQH_NUMCOM")
	Local cAgenci	:= oModel:GetValue("GQH_AGENCI")
	Local cTmpGII	:= GetNextAlias()
	Local cProxBil	:= ''
	
		BeginSql Alias cTmpGII
			
			SELECT MIN(GII.GII_BILHET) BILHET
			FROM %Table:GII% GII
			WHERE GII.GII_FILIAL = %xFilial:GII%
			  AND GII.GII_AGENCI = %exp:cAgenci%
			  AND GII.GII_TIPO = %exp:cTpDoc%
			  AND GII.GII_COMPLE = %exp:cCompl%
			  AND GII.GII_TIPPAS = %exp:cTpPas%
			  AND GII.GII_SERIE  = %exp:cSerie%
			  AND GII.GII_SUBSER  = %exp:cSubSer%
			  AND GII.GII_NUMCOM  = %exp:cNumCpl%			  
			  AND GII.GII_DTALOC = ''
			  AND GII.%NotDel%
	
		EndSql
		
		if !(cTmpGII)->(Eof())
			cProxBil	:= (cTmpGII)->BILHET
		EndIf

		oModel:SetValue("GQH_NUMINI", cProxBil )
					
		(cTmpGII)->(dbCloseArea())
		 			
Return

//------------------------------------------------------------------------------------------------	
/*/{Protheus.doc} TrgSaldo
Carrega o saldo até o momento 
@type function
@author cris
@since 26/12/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///------------------------------------------------------------------------------------------------	
Static Function TrgSaldo( oModel )

	Local cTpDoc	:= oModel:GetValue("GQH_TIPO")
	Local cCompl	:= oModel:GetValue("GQH_COMPLE")
	Local cTpPas	:= oModel:GetValue("GQH_TIPPAS")
	Local cSerie	:= oModel:GetValue("GQH_SERIE")
	Local cSubSer	:= oModel:GetValue("GQH_SUBSER")
	Local cNumCpl	:= oModel:GetValue("GQH_NUMCOM")
	Local cAgenci	:= oModel:GetValue("GQH_AGENCI")
	Local cTmpGII	:= GetNextAlias()
	Local nSaldo	:= 0
	
		BeginSql Alias cTmpGII
			
			SELECT COUNT(GII.GII_BILHET) BILHET
			FROM %Table:GII% GII
			WHERE GII.GII_FILIAL = %xFilial:GII%
			  AND GII.GII_AGENCI = %exp:cAgenci%
			  AND GII.GII_TIPO = %exp:cTpDoc%
			  AND GII.GII_COMPLE = %exp:cCompl%
			  AND GII.GII_TIPPAS = %exp:cTpPas%
			  AND GII.GII_SERIE  = %exp:cSerie%
			  AND GII.GII_SUBSER  = %exp:cSubSer%
			  AND GII.GII_NUMCOM  = %exp:cNumCpl%			  
			  AND GII.GII_DTALOC = ''
			  AND GII.%NotDel%
	
		EndSql
		
		if !(cTmpGII)->(Eof())
			
			nSaldo	:= (cTmpGII)->BILHET
		
		EndIf

		oModel:SetValue("GQH_SALDO", nSaldo )
					
		(cTmpGII)->(dbCloseArea())
		 			
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA106His
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
Realiza chamada do browse com lista de todos historico
/*/
//-------------------------------------------------------------------
Function GTPA106His()
Return GTPA106(.t.)         

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA106Filt()
Realiza a limpeza do filtro e adiciona novo filtro
 
 
@return	oModel - Objeto do Model
 
@author	Inovação
@since		20/06/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA106Filt(oBrowse)	
oBrowse:CleanFilter()
oBrowse:SetFilterDefault ( "GQH_MOVTO == '1' .Or. GQH_MOVTO == '2' .Or. GQH_MOVTO == '3'")
oBrowse:Refresh()
RETURN   
