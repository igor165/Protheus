#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA004.CH'

STATIC lRevisao := .F.
STATIC __lTP004COPIA	:= .F.
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA004()
Cadastro de Horários/Servicos 
 
@sample		GTPA004()

@return		oBrowse  Cadastro de Horários por Seção
 
@author		Lucas.Brustolin
@since			25/03/2015
@version		P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA004(lHist)

Local oBrowse
Default lHist	:= .F.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GID') 
oBrowse:SetMenuDef('GTPA004')
//Seleção do filtro no carregamento do historico
If !lHist 
	oBrowse:SetFilterDefault( "GID_HIST == '2'" ) //Registros Ativos
Else
	oBrowse:SetFilterDefault( "GID_HIST == '1'" ) // Registro Historico
	oBrowse:AddLegend( "GID_DEL == '2'","YELLOW"	,	OemToAnsi(STR0053))//Legenda Alteração
	oBrowse:AddLegend( "GID_DEL == '1'","RED"	,	OemToAnsi(STR0054))//Legenda Exclusão
EndIf

//Criação do botão de historico para browse dos registros ativo
If !FwIsInCall('GTPA004HIS')
	oBrowse:AddButton(STR0055, {|| GTPA004His(),GA004Filt(oBrowse)} ) //Criando botão do historico
EndIf

oBrowse:SetDescription(STR0003)// "Horários"
oBrowse:SetMenudef('GTPA004')
oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA004Filt()
Realiza a limpeza do filtro e adiciona novo filtro
 
@sample	ModelDef()
 
@return	oModel - Objeto do Model
 
@author	Inovação
@since		20/06/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GA004Filt(oBrowse)	
oBrowse:CleanFilter()
oBrowse:SetFilterDefault ( "GID_HIST == '2'")
RETURN

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do menu
 
@sample		MenuDef()
 
@return		aRotina - Array de opções do menu
 
@author		Gislaine Sabino - Consultir
@since		26/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
  
Local aRotina := {}
ADD OPTION aRotina TITLE STR0001  	ACTION 	'VIEWDEF.GTPA004'	OPERATION 2 ACCESS 0 //#Visualizar

If !FwIsInCall('GTPA004HIS')
	ADD OPTION aRotina TITLE STR0020 	ACTION 	'VIEWDEF.GTPA004'	OPERATION 3 ACCESS 0 //#Incluir
	ADD OPTION aRotina TITLE STR0021	ACTION 	'TP004Revisa'	OPERATION 9  ACCESS 0 //#Alterar
	ADD OPTION aRotina TITLE STR0022	ACTION 	'VIEWDEF.GTPA004'	OPERATION 5 ACCESS 0 //#Excluir

EndIf
Return aRotina

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definição do modelo de Dados
 
@sample		ModelDef()
 
@return		oModel - Retorna o Modelo de Dados
 
@author		Gislaine Sabino - Consultir
@since		26/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
		
Local oStruCab 	:= FWFormStruct( 1,"GID" )
Local oStruItem 	:= FWFormStruct( 1,"GIE" )

Local bCommit		:= {|oModel|TP04Commit(oModel)}
Local bPosValid	:= {|oModel|TP004TdOK(oModel)}		
Local bInitDado	:= {|oModel|TP004Init(oModel)}			
Local aRelacao	:= {}
Local aAux		:= {}
//Validação para data de vigencia
oStruCab:SetProperty('GID_INIVIG'	, MODEL_FIELD_VALID, {||GA004VldDt('GID_INIVIG','GID_FINVIG')})
oStruCab:SetProperty('GID_FINVIG'	, MODEL_FIELD_VALID, {||GA004VldDt('GID_INIVIG','GID_FINVIG')})

oStruCab:SetProperty('GID_SENTID'	, MODEL_FIELD_INIT,	{|| ''})
oStruCab:SetProperty('GID_HORCAB'	, MODEL_FIELD_VALID, { |oModel|	LoadCabec() } )

oStruItem:SetProperty( '*', MODEL_FIELD_OBRIGAT, .F. )
oStruItem:SetProperty('GIE_HIST'	, MODEL_FIELD_INIT,	{|| '2'})

If FwIsInCallStack('GI004Receb')
	oStruCab:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruCab:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruCab:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})

	oStruItem:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruItem:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruItem:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
ElseIf FwIsInCallStack('GTPIRJ004') .Or. FwIsInCallStack('GI004Job')
	oStruCab:SetProperty('GID_LOTACA', MODEL_FIELD_OBRIGAT, .F.)
	oStruCab:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruCab:SetProperty('GID_LINHA' , MODEL_FIELD_VALID, {||ExistCpo('GI2')})
Else
	oStruItem:SetProperty( 'GIE_HORLOC', MODEL_FIELD_VALID, {|oMdl,cField,cNewValue| GxVldHora(cNewValue) } )
	aAux := FwStruTrigger("GIE_HORDES", "GIE_TPTR", "GA004CalcHr()",NIL,NIL,NIL,NIL,"!IsInCallStack('GTPA004A')")
	oStruItem:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])

	aAux := FwStruTrigger("GIE_TEMPO", "GIE_TEMPO", "GA004LinGIE()",NIL,NIL,NIL,NIL,"!IsInCallStack('GTPA004A')")
	oStruItem:AddTrigger(aAux[1],aAux[2],aAux[3],aAux[4])
EndIf

oModel := MPFormModel():New('GTPA004',/*bPreValid */, bPosValid,bCommit, /*bCancel*/)

oModel:AddFields('GIDMASTER',/*cPai*/,oStruCab,/*{|a,b,c,d,e,f | TPFieldPre(a,b,c,d,e,f) }*/ , /*bPost*/,/*bLoad*/)
oModel:AddGrid('GIEDETAIL','GIDMASTER', oStruItem,/*bLinePre*/,/*bPosValid*/,/*bPreVal*/,/*bPosVal*/,/*bLoad*/)

aAdd(aRelacao,{'GIE_FILIAL'	, 'xFilial( "GID" )'})
aAdd(aRelacao,{'GIE_CODGID'	, 'GID_COD'})
aAdd(aRelacao,{'GIE_LINHA'	, 'GID_LINHA'})
aAdd(aRelacao,{'GIE_VIA'	, 'GID_VIA'})
aAdd(aRelacao,{'GIE_SENTID'	, 'GID_SENTID'})
aAdd(aRelacao,{'GIE_HORCAB'	, 'GID_HORCAB'})
aAdd(aRelacao,{'GIE_REVISA'	, 'GID_REVISA'})
aAdd(aRelacao,{'GIE_NUMSRV'	, 'GID_NUMSRV'})
oModel:SetRelation( 'GIEDETAIL', aRelacao, GIE->(IndexKey(1))) // Adiciona Relacionamento

oModel:GetModel( 'GIEDETAIL' ):SetMaxLine(999999)
If !FwIsInCallStack('GTPIRJ004') .OR. !FwIsInCallStack('GI004Job') .OR. !FwIsInCallStack('GI004Receb')
	oModel:GetModel( 'GIEDETAIL' ):SetNoInsertLine(.T.)// Não permite inclusao no grid
	oModel:GetModel( 'GIEDETAIL' ):SetNoDeleteLine(.T.)// Não permite deletar a linha
Else
	oModel:GetModel( 'GIEDETAIL' ):SetNoInsertLine(.F.)// Não permite inclusao no grid
	oModel:GetModel( 'GIEDETAIL' ):SetNoDeleteLine(.F.)// Não permite deletar a linha
EndIf

If FwIsInCallStack('GTPI004_01')
	oStruCab:SetProperty('*', MODEL_FIELD_OBRIGAT, .F.)
	oStruCab:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
	oStruCab:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruItem:SetProperty('*' , MODEL_FIELD_WHEN, {||.T.})
	oStruItem:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oModel:GetModel('GIEDETAIL'):SetOptional(.T.)
EndIf
oModel:SetDescription(STR0003) // "Horários/Serviços"
oModel:GetModel('GIDMASTER'):SetDescription(STR0006) // "Linha"
oModel:SetActivate(bInitDado)

Return oModel

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definição da interface
 
@sample		ViewDef()
 
@return		oView - Objeto do interface
 
@author	Inovação
@since		26/03/2014
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= FWFormView():New()
Local oModel	:= FWLoadModel('GTPA004')
Local oStruCab	:= FWFormStruct(2,'GID')
Local oStruItem	:= FWFormStruct(2,'GIE')

oStruCab:RemoveField("GID_HIST")
oStruCab:RemoveField("GID_DEL")

oStruItem:SetProperty( '*'			, MVC_VIEW_CANCHANGE, .F. )
oStruItem:SetProperty('GIE_TEMPO', MVC_VIEW_CANCHANGE , .T. )
oStruItem:SetProperty('GIE_HORDES', MVC_VIEW_CANCHANGE , .T. )

oStruItem:RemoveField('GIE_SENTID')
oStruItem:RemoveField('GIE_ITEM')
oStruItem:RemoveField('GIE_REVISA')
oStruItem:RemoveField('GIE_HIST')
oStruItem:RemoveField('GIE_DTALT')
oStruItem:RemoveField('GIE_HRATU')
oStruItem:RemoveField('GIE_CODGID')
oStruItem:RemoveField('GIE_NUMSRV')


If __lTP004COPIA
	oStruCab:SetProperty('GID_COD'		, MVC_VIEW_CANCHANGE , .F. )
	oStruCab:SetProperty('GID_SENTID'		, MVC_VIEW_CANCHANGE , .F. )
	__lTP004COPIA	:= .F.
EndIf

If FwIsInCallStack('GTPIRJ004') .OR. FwIsInCallStack('GI004Job') .OR. FwIsInCallStack('GI004Receb')
	oStruCab:SetProperty('GID_LOTACA', MODEL_FIELD_OBRIGAT, .F.)
	oStruCab:SetProperty('*' , MODEL_FIELD_VALID, {||.T.})
	oStruCab:SetProperty('GID_LINHA' , MODEL_FIELD_VALID, {||ExistCpo('GI2')})
EndIf

oView:SetModel(oModel) 

oView:AddField('VIEW_GID',oStruCab,'GIDMASTER') 
oView:AddGrid('VIEW_GIE',oStruItem,'GIEDETAIL')

oView:AddUserButton( STR0056, "", {|oModel| GTPA004A(oModel)},,,{ MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE } ) 

oView:CreateHorizontalBox('SUPERIOR',40) 
oView:CreateHorizontalBox('INFERIOR',60)
oView:SetOwnerView('VIEW_GID','SUPERIOR')
oView:SetOwnerView('VIEW_GIE','INFERIOR')

oView:SetDescription(STR0003) 

Return (oView)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LoadCabec()
Validação campo GID_HORCAB 
 
@sample		LoadCabec()
 
@param		
 
@return		lRet - validação da hora cabeceira
 
@author		Gislaine Sabino -
@since		26/03/2014  
@version	P12
@history  Convertido P/ (MVC) em 23/09/2014 
/*/
//------------------------------------------------------------------------------------------
Static Function LoadCabec()

Local oModel		:= FwModelActive()
Local oView		:= FwViewActive()
Local oFieldGID	:= oModel:GetModel("GIDMASTER")
Local oGridGIE  	:= oModel:GetModel("GIEDETAIL")
Local cHorCab1	:= oFieldGID:GetValue('GID_HORCAB')
Local cHor 		:= SUBSTR (cHorCab1,1,2)
Local cMin 		:= SUBSTR (cHorCab1,3,2)
Local nX 			:= 0
Local nSomaHr	:= 0
Local cTmpTot	:= ''
Local oGTPA002	:= Nil
Local oGridG5I	:= Nil
Local cHrAux	:= ''
Local lRet 		:= .T.
Local nDiaDec	:= 0
Local xData	:= dDataBase
Local cHorExc	:= ''
Local cHrOri	:= oFieldGID:GetValue('GID_HORCAB')
Local cDeltHr	:= ''

oModel:GetModel('GIEDETAIL'):SetNoInsertLine(.F.)// Permite inclusao no grid

If !( Val(cHor) >= 00 .And. Val(cHor) <= 23 ) .Or.  !( Val(cMin) >= 00 .And. Val(cMin) <= 59 )
	lRet := .F.
EndIf

If lRet .And. Len(Alltrim(cHorCab1)) <> TamSx3("GID_HORCAB")[1]
	lRet := .F.
EndIf

//A Picture 
If lRet .And. At( "-", cHorCab1 ) > 0
	lRet := .F.
EndIf
	
If lRet 	
	
	oGridGIE:GoLine(1)
	
	oGridGIE:SetValue('GIE_HORLOC', cHorCab1 )	//Insere no campo GIE_HORCAB o conteúdo do campo GID_HORCAB
	
	
	oGTPA002	:= FwLoadModel("GTPA002")
	oGTPA002:Activate()
	oGridG5I	:= oGTPA002:GetModel('GRIDG5I')
	
	oGridG5I:Activate()
	cHrAux	:= GTFormatHour(cHorCab1,'99:99')
	
	//Ajusta todos horario Origem e Horario Destino case seja alterado horario de inicio
	For nX := 1 To oGridGIE:Length() 		
		If !oGridGIE:IsDeleted(nX)
			oGridGIE:GoLine(nX)
			
			oGridGIE:LoadValue('GIE_HORCAB', cHorCab1)
			If !Empty(oGridGIE:GetValue('GIE_HORDES')) 
				
				cDeltHr	:= GTFormatHour(oGridGIE:GetValue('GIE_TPTR'),'99:99')
				cHrAux		:= GTFormatHour(cHrOri,'99:99')
				cHorExc 	:= GTFormatHour(oGridGIE:GetValue('GIE_TEMPO'),'99:99')  
				nSomaHr	:= SomaHoras(cHrAux,cDeltHr)
				nSomaHr	:= SomaHoras(GTFormatHour(nSomaHr,'99:99'),cHorExc)
				
				cTime	:= SomaHoras(GTFormatHour(cHorExc,'99:99'),GTFormatHour(cDeltHr,'99:99'))
				//Realiza calculo da horas e dias decorrido
				aData	:= GTTimeNextDay(cHrAux, xData, cTime)		
				nDiaDec	:= aData[2] - dDatabase
				xData	:= aData[2]
				
				cTmpTot :=  GTFormatHour(aData[1],'9999')
				oGridGIE:LoadValue('GIE_HORDES',cTmpTot)
				oGridGIE:LoadValue('GIE_HORLOC',cHrOri)
				oGridGIE:LoadValue('GIE_DIA',nDiaDec)
				cHrOri	:= cTmpTot
				If nX = oGridGIE:Length() 	
					oFieldGID:SetValue('GID_HORFIM',oGridGIE:GetValue('GIE_HORDES'))
				EndIf
			EndIf
		EndIf
	Next nX
	
	oGridGIE:GoLine(1)
	If !IsBlind()
		oView:Refresh()	
	Endif
EndIf

oModel:GetModel('GIEDETAIL'):SetNoInsertLine()// Nao Permite inclusao no grid
FwModelActive(oModel)
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PreLinGIE()
 
@sample	PreLinGIE(oModel)
 
@param		oModel - Modelo de dados
 
@return	
 
@author	Inovação - 
@since		20/02/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GA004LinGIE()
Local oModel	:= FwModelActive()
Local oView     := FWViewActive()
Local oMdlGIE	:= oModel:GetModel('GIEDETAIL')
Local nI		:= 0
Local cHrOri	:= oMdlGIE:GetValue('GIE_HORLOC',1)
Local cHrAux	:= ''
Local nSomaHr	:= 0
Local cTmpTot	:= ''
Local cHorExc	:= ''
Local cDeltHr	:= ''
Local aData	:= {}
Local cTime	:= ''
Local nDiaDec	:= 0
Local xData	:= dDataBase
Local nLinha	:= oMdlGIE:GETLINE()

For nI := 1 to oMdlGIE:Length()
	If !oMdlGIE:IsDeleted(nI)
	
		oMdlGIE:GoLine(nI)
		cHrAux		:= GTFormatHour(cHrOri,'99:99')
		cDeltHr	:= GTFormatHour(oMdlGIE:GetValue('GIE_TPTR'),'99:99')
		cHorExc 	:= GTFormatHour(oMdlGIE:GetValue('GIE_TEMPO'),'99:99')  
		nSomaHr	:= SomaHoras(cHrAux,cDeltHr)
		nSomaHr	:= SomaHoras(GTFormatHour(nSomaHr,'99:99'),cHorExc)
		
		cTime	:= SomaHoras(GTFormatHour(cHorExc,'99:99'),GTFormatHour(cDeltHr,'99:99'))
		aData	:= GTTimeNextDay(cHrAux, xData, cTime)		
		nDiaDec	:= aData[2] - dDatabase
		xData	:= aData[2]
		
		cTmpTot :=  GTFormatHour(aData[1],'9999')
		oMdlGIE:LoadValue('GIE_HORDES',cTmpTot)
		oMdlGIE:LoadValue('GIE_HORLOC',cHrOri)
		oMdlGIE:LoadValue('GIE_DIA',nDiaDec)
		cHrOri	:= cTmpTot
	EndIf
Next nI
oModel:GetModel("GIDMASTER"):SetValue('GID_HORFIM',oMdlGIE:GetValue('GIE_HORDES'))
oMdlGIE:GoLine(nLinha)

If !IsBlind()
	oView:Refresh()	
Endif
Return (GTFormatHour(oMdlGIE:GetValue('GIE_TEMPO',nLinha),'99:99'))

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA004CalcHr()
 
@sample	GA004CalcHr()
 
@param		
 
@return	
 
@author	Inovação - 
@since		28/04/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function GA004CalcHr()
Local oModel	:= FwModelActive()
Local oView     := FWViewActive()
Local oGridModel	:= oModel:GetModel('GIEDETAIL')
Local oMdlGID		:= oModel:GetModel('GIDMASTER')
Local cTime	:= '0000'
Local nY		:= 0
Local nX		:= 0
Local nGoLine	:= oGridModel:GetLine()
Local nDiasDec := 0
Local cDeltNv		:= ''
Local cHrOri		:= GTFormatHour(oGridModel:GetValue('GIE_HORLOC'),'99:99')
Local cHorExc		:= '0000'
Local xDataCalc	:= dDatabase	
Local cTmpTot	:= '0000'
Local cHrDes	:= '0000'

For nY	:= oGridModel:GetLine() to oGridModel:Length() 
	
	oGridModel:GoLine(nY)

	If !oGridModel:IsDeleted(nY)
		
		
		//Verifica se foi selecionando a ultima linha
		If (nY  <= oGridModel:Length())
			If nY == nGoLine
				
				cHrAux		:= GTFormatHour(cHrOri,'99:99')
				cHrDes		:= GTFormatHour(oGridModel:GetValue('GIE_HORDES'),'99:99')  
				cHorExc 	:= GTFormatHour(oGridModel:GetValue('GIE_TEMPO'),'99:99')  
				
				If cHrAux > cHrDes
					cDeltNv	:= GTDeltaTime(dDatabase + 1,cHrDes,dDatabase,cHrAux)
				Else
					cDeltNv	:= GTDeltaTime(dDatabase,cHrDes,dDatabase,cHrAux)
				EndIf
				
				cTime	:= SomaHoras(GTFormatHour(cHorExc,'99:99'),GTFormatHour(cDeltNv,'99:99'))
				aData	:= GTTimeNextDay(cHrAux, xDataCalc, cTime)		
				xDataCalc	:= aData[2]
				
				cTmpTot :=  GTFormatHour(aData[1],'9999')
				oGridModel:LoadValue('GIE_HORDES',cTmpTot)
				oGridModel:LoadValue('GIE_HORLOC',GTFormatHour(cHrOri,'9999'))
				oGridModel:LoadValue('GIE_TPTR',GTFormatHour(cDeltNv,'9999'))
				cHrOri	:= cTmpTot
			Else
				cHrAux		:= GTFormatHour(cHrOri,'99:99')
				cHrDes		:= GTFormatHour(oGridModel:GetValue('GIE_HORDES'),'99:99')  
				cHorExc 	:= GTFormatHour(oGridModel:GetValue('GIE_TEMPO'),'99:99')  
				
				cTime	:= SomaHoras(GTFormatHour(cHorExc,'99:99'),GTFormatHour(oGridModel:GetValue('GIE_TPTR'),'99:99') )
				aData	:= GTTimeNextDay(cHrAux, xDataCalc, cTime)		
				xDataCalc	:= aData[2]
				
				cTmpTot :=  GTFormatHour(aData[1],'9999')
				oGridModel:LoadValue('GIE_HORDES',cTmpTot)
				oGridModel:LoadValue('GIE_HORLOC',GTFormatHour(cHrOri,'9999'))
				cHrOri	:= cTmpTot
			EndIf
		EndIf
	EndIf
Next 
xDataCalc	:= dDatabase
For nX := 1 to oGridModel:Length()
	If !oGridModel:IsDeleted(nX)
		oGridModel:GoLine(nX)
		cTime	:= SomaHoras(GTFormatHour(oGridModel:GetValue('GIE_TEMPO'),'99:99'),GTFormatHour(oGridModel:GetValue('GIE_TPTR'),'99:99') )
		aData	:= GTTimeNextDay(GTFormatHour(oGridModel:GetValue('GIE_HORLOC'),'99:99'), xDataCalc, cTime)	
		nDiasDec	:= aData[2] - dDatabase
		xDataCalc	:= aData[2]
		oGridModel:LoadValue('GIE_DIA',nDiasDec)
	EndIf
Next nX
oMdlGID:SetValue('GID_HORFIM',oGridModel:GetValue('GIE_HORDES',oGridModel:Length()))
oGridModel:GoLine(nGoLine)

If !IsBlind()
	oView:Refresh()
Endif
Return GTFormatHour(cDeltNv,"9999")

//-------------------------------------------------------------------
/*/{Protheus.doc} GA004VldDt

Validação de data de vigencia

@param	cDataIni, cDataFim

@author Yuki Shiroma
@since 15/03/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Function GA004VldDt(cDataIni, cDataFim)
Local lRet := .T.
Local oModel	:= FwModelActive()
Local cDtIni	:= DtoS(oModel:GetModel('GIDMASTER'):GetValue(cDataIni))
Local cDtFim	:= DtoS(oModel:GetModel('GIDMASTER'):GetValue(cDataFim))

If !(cDtIni <= cDtFim) .And. !Empty(cDtFim)
	lRet	:= .F.
EndIf

Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao para chamar o Adapter para integracao via Mensagem Unica 

@sample 	IntegDef( cXML, nTypeTrans, cTypeMessage )
@param		cXml - O XML recebido pelo EAI Protheus
			cType - Tipo de transacao
				'0'- para mensagem sendo recebida (DEFINE TRANS_RECEIVE)
				'1'- para mensagem sendo enviada (DEFINE TRANS_SEND) 
			cTypeMessage - Tipo da mensagem do EAI
				'20' - Business Message (DEFINE EAI_MESSAGE_BUSINESS)
				'21' - Response Message (DEFINE EAI_MESSAGE_RESPONSE)
				'22' - Receipt Message (DEFINE EAI_MESSAGE_RECEIPT)
				'23' - WhoIs Message (DEFINE EAI_MESSAGE_WHOIS)
			cVersão - Versão da mensagem
@return  	aRet[1] - Variavel logica, indicando se o processamento foi executado com sucesso (.T.) ou nao (.F.)
			aRet[2] - String contendo informacoes sobre o processamento
			aRet[3] - String com o nome da mensagem Unica deste cadastro                        
@author  	Jacomo Lisa
@since   	15/02/2017
@version  	P12.1.8
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage,cVersao )
Return GTPI004( cXml, nTypeTrans, cTypeMessage,cVersao )

//-------------------------------------------------------------------
/*/{Protheus.doc} TP004TdOK

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Static Function TP004TdOK(oModel)
Local lRet 	:= .T.
Local oMdlGID	:= oModel:GetModel('GIDMASTER')
Local oMdlGIE	:= oModel:GetModel('GIEDETAIL')
Local nI		:= 1
Local lVersi	:= .T.
// Se já existir a chave no banco de dados no momento do commit, a rotina 
If (oMdlGID:GetOperation() == MODEL_OPERATION_INSERT) .And. !lRevisao
	If (!ExistChav("GID", oMdlGID:GetValue("GID_COD")))
		Help( ,, 'Help',"TP004TdOK", STR0052, 1, 0 )//Chave duplicada!
       lRet := .F.
    EndIf
EndIf

If oModel:GetOperation() <> MODEL_OPERATION_DELETE
	oMdlGID:SetValue('GID_DTALT', DDATABASE)
	oMdlGID:SetValue('GID_HRATU', SubStr(TIME(),1,2) + SubStr(TIME(),4,2) )
	oMdlGID:SetValue('GID_HIST', '2')
	oMdlGID:SetValue('GID_DEL','2')
	For nI	:= 1 to oMdlGIE:Length()
		
		oMdlGIE:GoLine(nI)
		oMdlGIE:SetValue('GIE_DTALT', DDATABASE)
		oMdlGIE:SetValue('GIE_HRATU', SubStr(TIME(),1,2) + SubStr(TIME(),4,2))
		oMdlGIE:SetValue('GIE_REVISA',oMdlGID:GetValue('GID_REVISA'))
		oMdlGIE:SetValue('GIE_HIST', '2')
	
	Next nI
	
ElseIf oModel:GetOperation() == MODEL_OPERATION_DELETE
	If SuperGetMv('MV_TPREV') == '1'
		If IsBlind() .or. MsgYesNo(STR0057,STR0037) //" Deseja Versionar o registro?""Atenção"
			lVersi		:= .T.
		Else
			lVersi		:= .F.
		Endif
	ElseIf SuperGetMv('MV_TPREV') == '2'
		lVersi		:= .T.
	ElseIf SuperGetMv('MV_TPREV') == '3'
		lVersi		:= .F.
	EndIf
	
	
	If 	lVersi
		oModel:DeActivate()
		oModel:SetOperation(4)
		oModel:Activate()
		oMdlGID:SetValue('GID_DTALT', DDATABASE)
		oMdlGID:SetValue('GID_HRATU', SubStr(TIME(),1,2) + SubStr(TIME(),4,2) )
		oMdlGID:SetValue('GID_HIST', '1')
		oMdlGID:SetValue('GID_DEL','1')
		For nI	:= 1 to oMdlGIE:Length()
			
			oMdlGIE:GoLine(nI)
			oMdlGIE:SetValue('GIE_DTALT', DDATABASE)
			oMdlGIE:SetValue('GIE_HIST', '1')
			oMdlGIE:SetValue('GIE_HRATU', SubStr(TIME(),1,2) + SubStr(TIME(),4,2))
		
		Next nI
	EndIf
EndIf

Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TP04Commit

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------

Static Function TP04Commit(oModel)
Local lRet			:= .T.
Local oMdlGID		:= oModel:GetModel('GIDMASTER')
Local cRevisa		:= oMdlGID:GetValue('GID_REVISA')
Local cCod			:= oMdlGID:GetValue('GID_COD')
Local cLinha		:= oMdlGID:GetValue('GID_LINHA')

FwFormCommit(oModel)// Realizando commite no GI4

If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. lRevisao == .T.
	
	If cRevisa != '000'
		cRevisa := StrZero(Val(cRevisa)-1,tamsx3('GID_REVISA')[1])
	EndIf			
	
	dbSelectArea("GID")
	GID->(dbSetOrder(1))//GI4_FILIAL+GI4_COD+GI4_REVISA  
	If GID->(dbSeek(xFilial("GID")+cCod+cLinha+cRevisa))
		GID->(RecLock(("GID"),.F.))
		GID->GID_HIST:= "1"
		GID->(MsUnlock())
		GID->(dbSkip())
	EndIf
	dbSelectArea("GIE")
	GIE->(DBOrderNickname("GIE004"))//GI4_FILIAL+GI4_COD+GI4_REVISA  
	If GIE->(dbSeek(xFilial("GIE")+cCod+cRevisa))
		While GIE->(!Eof()) .AND. GIE->GIE_CODGID == cCod .AND. GIE->GIE_REVISA == cRevisa
			GIE->(RecLock(("GIE"),.F.))
			GIE->GIE_HIST:= "1"
			GIE->(MsUnlock())
			GIE->(dbSkip())
		EndDo
	EndIF
	
EndIf
	
lRevisao	:= .F.
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TP04Commit

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------

Static Function TP004Init(oModel)
Local oMdlGID	:= oModel:GetModel('GIDMASTER')
Local cNewRev		:= StrZero(Val(GID -> GID_REVISA)+1,tamsx3('GID_REVISA')[1])

If oModel:GetOperation() == MODEL_OPERATION_INSERT .And. !lRevisao
	
	cNewRev	:= Replicate('0',tamsx3('GID_REVISA')[1]) 
	oMdlGID:LoadValue('GID_HIST', '2')
	oMdlGID:LoadValue('GID_REVISA', cNewRev)

ElseIf oModel:GetOperation() != MODEL_OPERATION_DELETE .And. lRevisao 
	oMdlGID:LoadValue('GID_HIST', '2')
	oMdlGID:LoadValue('GID_REVISA', cNewRev)
	oMdlGID:LoadValue('GID_COD', GID->GID_COD)

EndIF
return	


//-------------------------------------------------------------------
/*/{Protheus.doc} TP04Commit

Realiza validação se nao possui chave duplicada antes do commit

@param	oModel

@author Inovação
@since 11/04/2017
@version 12.0
/*/
//-------------------------------------------------------------------
Function TP004Revisa()
Local lver	:= .T.
If SuperGetMv('MV_TPREV') == '1'
	If IsBlind() .or. MsgYesNo(STR0057,STR0037) //" Deseja versionar o registro?""Atenção"
		lver		:= .T.
	Else
		lver		:= .F.
	Endif
ElseIf SuperGetMv('MV_TPREV') == '2'
	lver		:= .T.
ElseIf SuperGetMv('MV_TPREV') == '3'
	lver		:= .F.
EndIf

If lver	
	lRevisao  := .T.
	__lTP004COPIA	:= .T.
	FWExecView(STR0021,"VIEWDEF.GTPA004",OP_COPIA,,{|| .T.}) //"Revisão" //'Alterar'
Else
	FWExecView(STR0021,"VIEWDEF.GTPA004",MODEL_OPERATION_UPDATE,,{|| .T.}) //"Alteração" //'Alterar'
EndIf
lRevisao  := .F.
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA004His
@author Inovação 
@since 11/04/2017
@version undefined
@param oModel
@type function
Realiza chamada do browse com lista de todos historico
/*/
//-------------------------------------------------------------------
Function GTPA004His()
Return GTPA004(.T.) 

//------------------------------------------------------------------------------
/*/{Protheus.doc} GA004SETSTATIC

@type function
@author jacomo.fernandes
@since 07/06/2019
@version 1.0
@param cVariavel, character, (Descrição do parâmetro)
@param uValor, undefined, (Descrição do parâmetro)
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GA004SetStatic(cVariavel,uValor)
&(cVariavel) := uValor
Return
