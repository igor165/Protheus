#Include 'Protheus.ch' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA107.CH'

Static nRecno107 := GQG->(Recno())

/*/{Protheus.doc} GTPA102D
@GTPA107D - Devolução da Remessa
@Requisito Controle de Documentos
@Rotina Devolução
@Tabelas GQG / GII
/*/

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample	ModelDef()
@return	oModel 		Objeto do Model
@author		Inovação - Serviços
@since		
@version	P12
/*/
Static Function ModelDef()
	
Local oModel := Nil
Local oStruGQG	:= FWFormStruct(1,'GQG')
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
	
oStruGQG:SetProperty('GQG_NUMINI'    ,MODEL_FIELD_VALID  ,bFldVld)
oStruGQG:SetProperty('GQG_NUMFIM'    ,MODEL_FIELD_VALID  ,bFldVld)
	
oModel := MPFormModel():New('GTPA107D',/*PreValidacao*/,{ |oModel|TP107DTDOK(oModel)},{|oModel|TP107DGRV(oModel)})

oModel:AddFields('GQGMASTER',/*cOwner*/,oStruGQG)
oModel:SetPrimaryKey({"GQG_FILIAL","GQG_DATA"})
oModel:SetDescription(STR0098) // "Devolução de Remessa"

oModel:SetVldActivate( {|| TP107DVLDACT() } )
oModel:SetActivate({|oModel| TP107DInit(oModel) })
	
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
	Case cField == "GQG_NUMINI" .or. cField == "GQG_NUMFIM"
		If Val(uNewValue) < 1
			lRet        := .F.
			cMsgErro    := "Numero informado não é valido"
			cMsgSol     := "Informe um numero acima de 1"
		Endif
		IF !Empty(oMdl:GetValue('GQG_NUMINI')) .and. !Empty(oMdl:GetValue('GQG_NUMFIM'))
			IF Val(oMdl:GetValue('GQG_NUMINI')) >  Val(oMdl:GetValue('GQG_NUMFIM'))
				lRet        := .F.
				cMsgErro    := "Numero inicial informado é maior que o numero final"
				cMsgSol     := "Informe um numero final maior que o numero inicial"
			Endif
		Endif
EndCase


If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@sample	ViewDef()
@return	oView		Retorna objeto da interface
@author		Inovação - Serviços
@since		
@version	P12
/*/
Static Function ViewDef()
	
Local oView		:= Nil
Local oModel	:= FWLoadModel('GTPA107D')
Local oStruGQG	:= FWFormStruct(2,'GQG', {|cCampo| AllTrim(cCampo) + '|' $ "GQG_LOTE|GQG_DTREM|GQG_TIPO|GQG_TPDESC|GQG_COMPLE|GQG_TIPPAS|GQG_PROTOC|" + ;
					"GQG_DTBXP|GQG_SERIE|GQG_SUBSER|GQG_NUMCOM|GQG_NUMINI|GQG_NUMFIM|GQG_QUANT|GQG_AGENCI|GQG_NAGENC|"})
Local nX		:= 0


oStruGQG:SetProperty( 'GQG_LOTE'	, MVC_VIEW_ORDEM,	'01')
oStruGQG:SetProperty( 'GQG_DTREM'	, MVC_VIEW_ORDEM,	'02')
oStruGQG:SetProperty( 'GQG_TIPO'	, MVC_VIEW_ORDEM,	'03')
oStruGQG:SetProperty( 'GQG_TPDESC'	, MVC_VIEW_ORDEM,	'04')
oStruGQG:SetProperty( 'GQG_COMPLE'	, MVC_VIEW_ORDEM,	'05')
oStruGQG:SetProperty( 'GQG_TIPPAS'	, MVC_VIEW_ORDEM,	'06')
oStruGQG:SetProperty( 'GQG_PROTOC'	, MVC_VIEW_ORDEM,	'07')
oStruGQG:SetProperty( 'GQG_DTBXP'	, MVC_VIEW_ORDEM,	'08')
oStruGQG:SetProperty( 'GQG_SERIE'	, MVC_VIEW_ORDEM,	'10')
oStruGQG:SetProperty( 'GQG_SUBSER'	, MVC_VIEW_ORDEM,	'11')
oStruGQG:SetProperty( 'GQG_NUMCOM'	, MVC_VIEW_ORDEM,	'12')
oStruGQG:SetProperty( 'GQG_NUMINI'	, MVC_VIEW_ORDEM,	'13')
oStruGQG:SetProperty( 'GQG_NUMFIM'	, MVC_VIEW_ORDEM,	'14')		
oStruGQG:SetProperty( 'GQG_QUANT'	, MVC_VIEW_ORDEM,	'15')
oStruGQG:SetProperty( 'GQG_AGENCI'	, MVC_VIEW_ORDEM,	'22')
oStruGQG:SetProperty( 'GQG_NAGENC'	, MVC_VIEW_ORDEM,	'23')	

// Crio os Agrupamentos de Campos
oStruGQG:AddGroup( 'GRUPO1', '', '', 1 )
oStruGQG:AddGroup( 'GRUPO2', STR0099, '', 2 ) // 'Lote'
oStruGQG:AddGroup( 'GRUPO3', STR0100, '', 3 ) // Agência

For nX := 1 To Len(oStruGQG:aFields) // Campos da tabela GQG
	
	//-- Define os campos para determinado grupo
	If oStruGQG:aFields[nX][VIEWS_VIEW_ID] $ "GQG_LOTE,GQG_DTREM,GQG_TIPO,GQG_TPDESC,GQG_COMPLE,GQG_TIPPAS,GQG_PROTOC,GQG_DTBXP"
		oStruGQG:SetProperty( oStruGQG:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
	ElseIf oStruGQG:aFields[nX][VIEWS_VIEW_ID] $ "GQG_SERIE,GQG_SUBSER,GQG_NUMCOM,GQG_NUMINI,GQG_NUMFIM,GQG_QUANT"
		oStruGQG:SetProperty( oStruGQG:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO2' )
	ElseIf oStruGQG:aFields[nX][VIEWS_VIEW_ID] $ "GQG_AGENCI|GQG_NAGENC|"
		oStruGQG:SetProperty( oStruGQG:aFields[nX][VIEWS_VIEW_ID] , MVC_VIEW_GROUP_NUMBER, 'GRUPO3' )
	EndIf
	
	oStruGQG:SetProperty( oStruGQG:aFields[nX][VIEWS_VIEW_ID], MVC_VIEW_CANCHANGE , .F.)
		
Next nX

oStruGQG:SetProperty( 'GQG_NUMINI' 	, MVC_VIEW_CANCHANGE ,.T.)
oStruGQG:SetProperty( 'GQG_NUMFIM' 	, MVC_VIEW_CANCHANGE ,.T.)

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('VIEW',oStruGQG,'GQGMASTER')
oView:SetFieldAction('GQG_NUMINI', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )
oView:SetFieldAction('GQG_NUMFIM', { |oView, cIDView, cField, xValue| TPStrZeroCp(oView, cIDView, cField, xValue)  } )
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW','TELA')
oView:SetInsertMessage(STR0101, STR0102) // "Devolução" / "A devolução da Remessa foi realizada com sucesso"
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} TP107DVLDACT
Validação do modelo de dados
@sample		TP107DVLDACT
@return		lRet   Logico operação foi ativação
@author		Inovação
@since		14/04/2018
@version	P12
/*/
Static Function TP107DVLDACT()
Local lRet := .T.

//BARRA TRANSFERENCIA PARA REGISTROS CANCELADOS.
If GQG->GQG_MOVTO == "3" //MOVTO CANCELADO.
	Help(" ",1,"TP107DVLDACT",,STR0103,1,0)//#"Remessa cancelada não permite a devolução." 
	lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP107DInit
Faz a carga dos campos na ativação do modelo.
@sample		TP107DInit
@return		lRet   Logico operação foi realizada com sucesso
@author		Inovação
@since		14/04/2018
@version	P12
/*/
Static Function TP107DInit(oModel)
Local oMldGQG  	:= oModel:GetModel('GQGMASTER')
Local aCpoAux		:= {}
Local nI			:= 0
Local cAgencia	:= ""
Local cDescAge	:= ""
Local lRet 		:= .T.

If oModel:GetOperation() == MODEL_OPERATION_INSERT 

	nRecno107 := GQG->(Recno())
	
	DbSelectArea("GQG")
	DbGoTo(nRecno107)
	
	//Agencia atual Antes da trasnf.	
	cAgencia	:= GQG->GQG_AGENCI 
	cDescAge	:= POSICIONE('GI6',1,XFILIAL('GI6')+ GQG->GQG_AGENCI ,'GI6_DESCRI')
		
	aCpoAux	:= GQG->( DbStruct())
		
	For nI:= 1 to Len(aCpoAux)
		If oMldGQG:HasField(aCpoAux[nI,1])
			If aCpoAux[nI,1] $ "GQG_LOTE|GQG_COLABO"
				Loop
			EndIf
			If aCpoAux[nI,1] == "GQG_AGENCI"
				If !( lRet := 	oMldGQG:SetValue("GQG_AGENCI", cAgencia) .And. ;
								oMldGQG:SetValue("GQG_NAGENC", cDescAge )  ) 
					Exit					
				EndIf				
			ElseIf aCpoAux[nI,1] == "GQG_MOVTO"
				If !( lRet := oMldGQG:SetValue("GQG_MOVTO", "5") ) // Devolução
					Exit					
				EndIf	
			ElseIf !( lRet := oMldGQG:SetValue(aCpoAux[nI,1], &(aCpoAux[nI,1]))  )
				Exit	
			EndIf
		EndIf
	Next nI	

EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP107DTDOK
Verifica se está ok antes de realizar o commit
@sample		TP107DInit
@return		lRet   Logico operação foi realizada com sucesso
@author		Inovação
@since		14/04/2018
@version	P12
/*/
Static Function TP107DTDOK(oModel)

Local cTpDoc		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_TIPO')
Local cComple		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_COMPLE')
Local cTipPas		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_TIPPAS')
Local cSerie		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_SERIE')
Local cSubSer		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_SUBSER')
Local cNumCom		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_NUMCOM')
Local cNumIni		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_NUMINI')
Local cNumFim		:= oModel:GetModel('GQGMASTER'):GetValue('GQG_NUMFIM')
Local cLote			:= GQG->GQG_LOTE
Local cStatus		:= GQG->GQG_MOVTO
Local lRet			:= .T.

//---------------------------------------------------	
// SÓ PERMITE TRANSFERENCIA PARA RANGE DOCUMENTOS (STATUS = 2 REMESSA)
//---------------------------------------------------	
	//-- DEPARA STATUS GQG x GII
	IF cStatus == "1"
		cStatus := "2" //-- Remessa
	ElseIf cStatus == "2"
		cStatus := "4"//-- Transf
	EndIf
	
	If cStatus $ "2|4" .And. !GTPDISPRANGE(cTpDoc, cComple, cTipPas, cSerie, cSubSer, cNumCom, cNumIni, cNumFim, cStatus,cLote)
		Help(" ",1,"TP107DTDOK01",,STR0104,1,0) // "O intervalo selecionado deve estar totalmente disponível"
		lRet := .F.
	EndIf
	
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP107DGRV
GRAVAÇÃO DO MODELO DE DADOS - DEVOLUÇÃO.
CRIA-SE NOVO LOTE GQG 
@sample	TP107DGRV(oModel)
@return	lRet   Logico operação foi realizada com sucesso
@param	oModel oBjeto Model do Programa
@author		Inovação - Serviços
@since		
@version	P12
/*/
Static Function TP107DGRV(oModel)
	
Local aArea		:= GetArea()
Local oMdlGQG 	:= oModel:GetModel('GQGMASTER')
Local cTipo		:= oMdlGQG:GetValue('GQG_TIPO')
Local cComple		:= oMdlGQG:GetValue('GQG_COMPLE')
Local cTipPas		:= oMdlGQG:GetValue('GQG_TIPPAS')
Local cSerie  	:= oMdlGQG:GetValue('GQG_SERIE')
Local cSubSer 	:= oMdlGQG:GetValue('GQG_SUBSER')
Local cNumCom 	:= oMdlGQG:GetValue('GQG_NUMCOM')
Local cNumIni 	:= oMdlGQG:GetValue('GQG_NUMINI')
Local cNumFim 	:= oMdlGQG:GetValue('GQG_NUMFIM')
Local dDtRem   	:= oMdlGQG:GetValue('GQG_DTREM')
Local cLotRem 	:= oMdlGQG:GetValue('GQG_LOTE')
Local nQtdade 	:= oMdlGQG:GetValue('GQG_QUANT')
Local aUpdate  	:= {}
Local lRet			:= .T.	
Local cAliasGII 	:= GetNextAlias()

Begin Transaction
	
	If oModel:VldData() .And. FwFormCommit(oModel)
		If oModel:GetOperation() == MODEL_OPERATION_INSERT
		
			//-- Dados a serem atualizados na GII
			AADD(aUpdate,{'GII_AGENCI',""})
			AADD(aUpdate,{'GII_LOTREM',cLotRem})
			AADD(aUpdate,{'GII_DTTRAN' ,dDtRem})
			AADD(aUpdate,{'GII_STATUS','8'}) //--"8=Devolução"
				
			If !( lRet := GA102ALot(cTipo, cComple, cTipPas, cSerie,cSubSer,cNumCom,cNumIni,cNumFim,aUpdate) )		
				DisarmTransaction()		 
			EndIf
			
			//-------------------------------------------------------
			//-- ATUALIZA A QUANTIDADE E STATUS DA REMESSA
			//-------------------------------------------------------			
			DbSelectArea("GQG")
			DbGoTo(nRecno107)
			
			If lRet .And. nRecno107 == GQG->(Recno())
				If ( GQG->GQG_QUANT - nQtdade ) = 0
					RecLock("GQG",.F.)
					GQG->GQG_QUANT := GQG->GQG_QUANT - nQtdade
					GQG->GQG_MOVTO := "4" //Finalizado sem saldo
					GQG->( MsUnlock() )	
				ElseIf ( GQG->GQG_QUANT - nQtdade ) >= 1 
				
					//Busca bilhete
					BeginSQL alias cAliasGII
								
					 SELECT MAX(GII.GII_BILHET) as Maximo,
					 	MIN(GII.GII_BILHET)	as Minimo
						FROM %Table:GII% GII
						WHERE 
							GII.GII_FILIAL = %xFilial:GIC%
							AND GII.GII_LOTREM = %Exp:GQG->GQG_LOTE%
							AND GII.%NotDel%
								 
					EndSQL
					
					RecLock("GQG",.F.)
					GQG->GQG_QUANT := GQG->GQG_QUANT - nQtdade	
					GQG->GQG_NUMINI := (cAliasGII)->Minimo
					GQG->GQG_NUMFIM := (cAliasGII)->Maximo	
					GQG->( MsUnlock() )		
					(cAliasGII)->(DbCloseArea())	
						
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
	
Return(lRet)
