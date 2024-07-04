#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'GTPA102.CH'

Static cSXBGI8RET	:= ""

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA102
@Requisito Controle de Documentos
@Rotina Entrada de Documentos
@Tabelas GI8 / GII
@sample		GTPA102()
@author		Inovação - Serviços

@since		01/04/2014
@version	P12
/*/
Function GTPA102()
	
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('GI8')
oBrowse:SetMenuDef('GTPA102')
oBrowse:SetDescription(STR0001)	//'Entrada de Documentos'
oBrowse:Activate()
		
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@sample		ModelDef()
@return		oModel 		Objeto do Model
@author		Inovação - Serviços
@since		01/04/2014
@version	P12
/*/
Static Function ModelDef()
Local oModel    := Nil
Local oStrGI8   := FWFormStruct(1,'GI8')
Local bCommit   := {|oModel| TP102Commit(oModel)}
Local bVldMdl   := {|oModel| TP102TdOK(oModel)}

SetModelStruct(oStrGI8)

oModel := MPFormModel():New('GTPA102',,bVldMdl,bCommit)

oModel:AddFields('GI8MASTER',/*cOwner*/,oStrGI8)

oModel:SetPrimaryKey({"GI8_FILIAL","GI8_TPDOC","GI8_COMPLE","GI8_TIPPAS","GI8_SERIE","GI8_SUBSER","GI8_NUMCOM","GI8_NUMINI","GI8_NUMFIM"})
	
oModel:SetDescription(STR0001)	//'Entrada de Documentos'
	
Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct
Função responsavel pela estrutura do modelo
@type Static Function
@author jacomo.fernandes
@since 12/08/2019
@version 1.0
@param oStrGI8, object, (Descrição do parâmetro)
@return nil, Retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrGI8)
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldVld   := {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

oStrGI8:AddTrigger("GI8_TPDOC" , "GI8_TPDOC" , {||.T.}, bFldTrig)
oStrGI8:AddTrigger("GI8_NUMCOM", "GI8_NUMCOM", {||.T.}, bFldTrig)	 
oStrGI8:AddTrigger("GI8_NUMINI", "GI8_NUMINI", {||.T.}, bFldTrig)	 
oStrGI8:AddTrigger("GI8_NUMFIM", "GI8_NUMFIM", {||.T.}, bFldTrig)	 
oStrGI8:AddTrigger("GI8_SERIE" , "GI8_SERIE" , {||.T.}, bFldTrig)	 
oStrGI8:AddTrigger("GI8_SUBSER", "GI8_SUBSER", {||.T.}, bFldTrig)	 

oStrGI8:SetProperty('GI8_NUMINI', MODEL_FIELD_VALID, bFldVld)
oStrGI8:SetProperty('GI8_NUMFIM', MODEL_FIELD_VALID, bFldVld)
oStrGI8:SetProperty('GI8_DTINI'	, MODEL_FIELD_VALID, bFldVld)
oStrGI8:SetProperty('GI8_DTFIM'	, MODEL_FIELD_VALID, bFldVld)

Return nil

//------------------------------------------------------------------------------
/* /{Protheus.doc} FieldTrigger
Função responsavel pelas trigger do modelo
@type Static Function
@author jacomo.fernandes
@since 12/08/2019
@version 1.0
@param oMdl, object, (Descrição do parâmetro)
@return nil, Retorno nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
    Case cField == "GI8_NUMCOM"
		uVal := cValToChar(Val(uVal))
		oMdl:LoadValue(cField,uVal)
        oMdl:SetValue('GI8_NUMINI',TP102Prox())
    Case cField == "GI8_NUMINI" .or. cField == "GI8_NUMFIM"
        uVal    := StrZero(Val(uVal), TamSx3(cField)[1])
        oMdl:LoadValue(cField,uVal)
	Case cField == "GI8_TPDOC"
		oMdl:LoadValue('GI8_SERIE' , '')
		oMdl:LoadValue('GI8_SUBSER', '')
		oMdl:LoadValue('GI8_NUMCOM', '')
		oMdl:LoadValue('GI8_NUMINI', '')
		oMdl:LoadValue('GI8_NUMFIM', '')
		oMdl:LoadValue('GI8_QUANT ',  0)
	Case cField == "GI8_SERIE"
		uVal 	:= AllTrim(uVal)
		oMdl:LoadValue(cField,uVal)			
	Case cField == 'GI8_SUBSER'
		uVal := cValToChar(Val(uVal))
		oMdl:LoadValue(cField,uVal)

EndCase

Return uVal

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
    Case cField == "GI8_NUMINI" .or. cField == "GI8_NUMFIM"
        If Val(uNewValue) < 1
            lRet        := .F.
            cMsgErro    := STR0029 //"Numero informado não é valido"
            cMsgSol     := STR0030 //"Informe um numero acima de 1"
        Endif
        IF !Empty(oMdl:GetValue('GI8_NUMINI')) .and. !Empty(oMdl:GetValue('GI8_NUMFIM'))
            IF Val(oMdl:GetValue('GI8_NUMINI')) >  Val(oMdl:GetValue('GI8_NUMFIM'))
                lRet        := .F.
                cMsgErro    := STR0031 //"Numero inicial informado é maior que o numero final"
                cMsgSol     := STR0032 //"Informe um numero final maior que o numero inicial"
            Endif
        Endif
    Case cField == "GI8_DTINI" .or. cField == "GI8_DTFIM"
        IF !Empty(oMdl:GetValue('GI8_DTINI')) .and. !Empty(oMdl:GetValue('GI8_DTFIM'))
            If oMdl:GetValue('GI8_DTINI') > oMdl:GetValue('GI8_DTFIM')
                lRet        := .F.
                cMsgErro    := STR0033//"Data inicial maior que a Data Final de Vencimento"
                cMsgSol     := STR0034//"Informe uma data final maior que a data inicial"
            Endif
            If lRet .and. cField == "GI8_DTFIM"
                If dDataBase > uNewValue
                    lRet        := .F.
                    cMsgErro    := STR0035 //"Data Final de Vencimento menor que a data de hoje"
                    cMsgSol     := STR0036 //"Informe uma data maior que a data de hoje"
                Endif
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
@sample		ViewDef()
@return		oView		Retorna objeto da interface
@author		Inovação - Serviços
@since		01/04/2014
@version	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	
Local oView		:= FWFormView():New()
Local oModel	:= FWLoadModel('GTPA102')
Local oStrGI8	:= FWFormStruct(2,'GI8', {|cCampo| AllTrim(cCampo) + '|' $ "GI8_DATA|GI8_DTINI|GI8_DTFIM|GI8_SERIE|GI8_SUBSER|GI8_NUMCOM|GI8_NUMINI|GI8_NUMFIM|GI8_QUANT|GI8_TPDOC|GI8_DOCUME|GI8_COMPLE|GI8_TIPPAS|"})

SetViewStruct(oStrGI8)

oView:SetModel(oModel)
oView:AddField('VIEW',oStrGI8,'GI8MASTER')

oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW','TELA')
	
Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct(oStrGI8)

@type function
@author jacomo.fernandes
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return nil, nulo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrGI8)

oStrGI8:SetProperty( 'GI8_DATA'     , MVC_VIEW_ORDEM, "01" )
oStrGI8:SetProperty( 'GI8_DTINI'    , MVC_VIEW_ORDEM, "02" )
oStrGI8:SetProperty( 'GI8_DTFIM'    , MVC_VIEW_ORDEM, "03" )
oStrGI8:SetProperty( 'GI8_TPDOC'    , MVC_VIEW_ORDEM, "04" )
oStrGI8:SetProperty( 'GI8_DOCUME'   , MVC_VIEW_ORDEM, "05" )
oStrGI8:SetProperty( 'GI8_SERIE'    , MVC_VIEW_ORDEM, "06" )
oStrGI8:SetProperty( 'GI8_SUBSER'   , MVC_VIEW_ORDEM, "07" )
oStrGI8:SetProperty( 'GI8_NUMCOM'   , MVC_VIEW_ORDEM, "08" )
oStrGI8:SetProperty( 'GI8_NUMINI'   , MVC_VIEW_ORDEM, "09" )
oStrGI8:SetProperty( 'GI8_NUMFIM'   , MVC_VIEW_ORDEM, "10" )
oStrGI8:SetProperty( 'GI8_QUANT'    , MVC_VIEW_ORDEM, "11" )
oStrGI8:GetProperty( 'GI8_COMPLE'   , MVC_VIEW_ORDEM, "12" )
oStrGI8:GetProperty( 'GI8_TIPPAS'   , MVC_VIEW_ORDEM, "13" )

// Crio os Agrupamentos de Campos
oStrGI8:AddGroup('GRUPO1', STR0025, '', 2 ) // 'Dados do documento'
oStrGI8:AddGroup('GRUPO2', STR0026, '', 2 ) // 'Informações Complementares'

oStrGI8:SetProperty("*" , MVC_VIEW_GROUP_NUMBER, 'GRUPO2' )

oStrGI8:SetProperty("GI8_DATA"  , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_DTINI" , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_DTFIM" , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_TPDOC" , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_DOCUME", MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_SERIE" , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_SUBSER", MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_NUMCOM", MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_NUMINI", MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_NUMFIM", MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
oStrGI8:SetProperty("GI8_QUANT" , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )

oStrGI8:SetProperty("GI8_NUMCOM", MVC_VIEW_PICT, '@R 999')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu
@sample		MenuDef()
@return		aRotina   Array contendo as opções do Menu
@author		Inovação - Serviços
@since		01/04/2014
@version	P12
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.GTPA102' OPERATION 2 ACCESS 0 // #Visualizar
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.GTPA102' OPERATION 3 ACCESS 0 // #Incluir
ADD OPTION aRotina TITLE STR0037 ACTION 'VIEWDEF.GTPA102' OPERATION 4 ACCESS 0 // #Alterar
ADD OPTION aRotina TITLE STR0019 ACTION 'VIEWDEF.GTPA102' OPERATION 5 ACCESS 0 // #Excluir

Return aRotina

//-----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP102TdOK()
Realiza a validação do modelo de daddos.
@sample		TP102TdOK(oModel)
@param		oModel		Modelo Principal
@return		lLogico 	Retorna um valor lógico
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*/
Static Function TP102TdOK(oModel)
Local lRet      := .T.
Local nOpc      := oModel:GetOperation()
Local oMdlGI8   := oModel:GetModel("GI8MASTER")

If !TPDISPRANGE(oMdlGI8,nOpc)
    lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP102Commit()
Faz a chamada para da rotina de gravação do lote
@sample		TP102TdOK(oModel)
@param		oModel		Modelo Principal
@return		lLogico 	Retorna um valor lógico
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*/
Static Function TP102Commit(oModel)

Local lRet := .T.
Local lExclui  := oModel:GetOperation() == MODEL_OPERATION_DELETE

Begin Transaction
    If oModel:VldData() .and. FwFormCommit(oModel)
        Processa( {|| lRet := GA102Grv(oModel) },I18n(STR0038,{ If(!lExclui,STR0039,STR0040) } ) ,STR0022 )//"#1 lote de Documentos"##"Gerando"##"Excluindo"##"Aguarde..."

    Else
        lRet    :=  .F.
    Endif
 
    If !lRet
        DisarmTransaction()
    Endif

End Transaction
   
    
If !lRet
    JurShowErro( oModel:GetModel():GetErrorMessage() )
EndIf


Return lRet

//-----------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA102Grv()
Commit do Modelo de Dados
@sample		GA102Grv(oModel)
@param		oModel		Modelo Principal
@return		lLogico 	Retorna um valor lógico
@author		Inovação - Serviços
@since		27/03/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------------------------------
Static Function GA102Grv(oModel)
Local lRet		:= .T.
Local aArea 	:= GetArea()
Local nOpc      := oModel:GetOperation()
Local n1		:= 0
Local lSeek		:= .T.
Local aErro     := {}

Local oMdl102b	:= FwLoadModel('GTPA102B')
Local oMdlGII	:= oMdl102b:GetModel('GIIMASTER')

Local oMdlGI8	:= oModel:GetModel('GI8MASTER')
Local cNumIni 	:= oMdlGI8:GetValue('GI8_NUMINI')
Local cNumFim 	:= oMdlGI8:GetValue('GI8_NUMFIM')
Local cBilhet	:= ""

Local cTipo		:= oMdlGI8:GetValue('GI8_TPDOC')
Local cComple   := oMdlGI8:GetValue('GI8_COMPLE')
Local cTipPas   := oMdlGI8:GetValue('GI8_TIPPAS')
Local cSerie  	:= oMdlGI8:GetValue('GI8_SERIE')
Local cSubSer 	:= oMdlGI8:GetValue('GI8_SUBSER')
Local cNumCom 	:= oMdlGI8:GetValue('GI8_NUMCOM')

Local dData   	:= oMdlGI8:GetValue('GI8_DATA')
Local cNumMov	:= oMdlGI8:GetValue('GI8_NUMMOV')
Local dDtIni	:= oMdlGI8:GetValue('GI8_DTINI')
Local dDtFim	:= oMdlGI8:GetValue('GI8_DTFIM')

DbSelectArea('GII')
GII->(dbSetOrder(1))	  // "GII_FILIAL+GII_TIPO+GII_COMPLE+GII_TIPPAS+GII_SERIE+GII_SUBSER+GII_NUMCOM+GII_BILHET+GII_AGENCI"

ProcRegua( (Val(cNumFim) - Val(cNumIni))+ 1 )

For n1 := Val(cNumIni) to Val(cNumFim)
	cBilhet	:= StrZero(n1,TamSX3('GII_BILHET')[01])
	
	IncProc( cBilhet  )

	If nOpc <> MODEL_OPERATION_INSERT
		lSeek	:= GII->(dbSeek(xFilial('GII') + cTipo + cComple + cTipPas + cSerie + cSubSer + cNumCom + cBilhet ))
	else
		lSeek	:= .T.
	Endif
	
	oMdl102b:SetOperation(nOpc)
	If lSeek .and. oMdl102b:Activate()
		If nOpc <> MODEL_OPERATION_DELETE

			If nOpc == MODEL_OPERATION_INSERT
				oMdlGII:SetValue('GII_FILIAL'   , xFilial("GII") )	// – Filial corrente do sistema.
				oMdlGII:SetValue('GII_TIPO'     , cTipo     ) 
				oMdlGII:SetValue('GII_NUMMOV'   , cNumMov   )
				oMdlGII:SetValue('GII_COMPLE'   , cComple   )
				oMdlGII:SetValue('GII_TIPPAS'   , cTipPas   )
				oMdlGII:SetValue('GII_SERIE'    , cSerie    )
				oMdlGII:SetValue('GII_SUBSER'   , cSubSer   )
				oMdlGII:SetValue('GII_NUMCOM'   , cNumCom   )
				oMdlGII:SetValue('GII_BILHET'   , cBilhet   )
				oMdlGII:SetValue('GII_DATA'     , dData     )
				oMdlGII:SetValue('GII_DTINI'    , dDtIni    )
				oMdlGII:SetValue('GII_STATUS'   , '1'       )
				oMdlGII:SetValue('GII_UTILIZ'   , .F.       )
			Endif

            oMdlGII:SetValue('GII_DTFIM',dDtFim )
            
		Endif

		If oMdl102b:VldData()
			oMdl102b:CommitData()
		Else
			lRet	:= .F.
			aErro	:= oMdl102b:GetModel():GetErrormessage()
			Exit
		EndIf
	else
        lRet := .F.
	Endif
    oMdl102b:DeActivate()
Next

If !lRet
	oModel:SetErrorMessage(aErro[1],aErro[2],aErro[3],aErro[4],aErro[5],aErro[6],aErro[7],aErro[8],aErro[9])
Endif


oMdl102b:Destroy()

GTPDestroy(aErro)

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TP102Prox
Função para criar uma sugestão do numero do inicio do documento
seguindo a sequência do ultimo numero do tipo do documento
@sample	TP102Prox(cTpDoc)
@param 	cTpDoc    Caracter Tipo do Documento

@author		Inovação
@since		07/03/2017
@version	P12
/*/
Static Function TP102Prox()
Local oModel	:= FwModelActive()
Local oMdlGI8 	:= oModel:GetModel('GI8MASTER')
Local cSerie	:= oMdlGI8:GetValue('GI8_SERIE')
Local cSubSer	:= oMdlGI8:GetValue('GI8_SUBSER')
Local cNumCom	:= oMdlGI8:GetValue('GI8_NUMCOM')
Local cTpDoc    := oMdlGI8:GetValue('GI8_TPDOC')
Local cAliasTmp	:= GetNextAlias()
Local cNum		:= ""

If Select(cAliasTmp) > 0
	(cAliasTmp)->(DbCloseArea())
Endif

BeginSql Alias cAliasTmp
	SELECT 
		MAX(GI8_NUMFIM) AS GI8_NPROX 
	FROM 
		%Table:GI8% GI8 
	WHERE 
		GI8.GI8_FILIAL = %xFilial:GI8% 
		AND GI8_SERIE  = %Exp:cSerie% 
		AND GI8_SUBSER = %Exp:cSubSer%		
		AND GI8_NUMCOM = %Exp:cNumCom%
		AND GI8_TPDOC  = %Exp:cTpDoc%	 	
		AND GI8.%NotDel% 
EndSql

If !(cAliasTmp)->(EOF())
	cNum := (cAliasTmp)->GI8_NPROX 
	cNum := SOMA1(cNum)
EndIf

(cAliasTmp)->(DbCloseArea())

Return(cNum)

//-------------------------------------------------------------------
/*/{Protheus.doc} TPDISPRANGE
COM BASE NAS INFORMACOES DO LOTE (ENTRADA DOCUMENTO) REALIZA BUSCA 
NA TABELA DE DOCUMENTOS GII
@Requisito Controle de Documentos
@Rotina Entrada de Documentos
@Tabelas GI8 / GII
@sample		TPDISPRANGE()
@author		Inovação
@since		27/03/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function TPDISPRANGE( oMdlGI8,nOpc)
Local lRet 		 := .T.
Local cTpDoc     := oMdlGI8:GetValue('GI8_TPDOC')
Local cAliasTemp := GetNextAlias()

BeginSql Alias cAliasTemp	
    SELECT 
		Count(*) TOTAL
    FROM 
		%Table:GII% GII
    WHERE 
        GII_FILIAL = %xFilial:GII%
        AND GII_SERIE  = %Exp:oMdlGI8:GetValue('GI8_SERIE')%
        AND GII_SUBSER = %Exp:oMdlGI8:GetValue('GI8_SUBSER')%
        AND GII_NUMCOM = %Exp:oMdlGI8:GetValue('GI8_NUMCOM')%
        AND GII_BILHET Between %Exp:oMdlGI8:GetValue('GI8_NUMINI')% AND %Exp:oMdlGI8:GetValue('GI8_NUMFIM')% 
		AND GII_TIPO   = %Exp:cTpDoc%
        AND %NotDel%        
EndSql

If nOpc == MODEL_OPERATION_INSERT .And. (cAliasTemp)->TOTAL  > 0
    Help( ,, 'Help',"TP102TdOK01", STR0006, 1, 0 )//#TP102TdOK, '"Parte ou total do lote informado já foi incluído!"'
    lRet := .F.
ElseIf nOpc == MODEL_OPERATION_DELETE .And. (cAliasTemp)->TOTAL  <> ( ( Val(oMdlGI8:GetValue('GI8_NUMFIM')) - Val(oMdlGI8:GetValue('GI8_NUMINI')) ) + 1 ) 
    Help( ,, 'Help',"TP102TdOK02", STR0021, 1, 0 )//#'Lote em movimento não pode ser excluído.'
    lRet := .F.
Endif
	
(cAliasTemp)->(DbCloseArea())

Return(lRet)


/*/{Protheus.doc} GA102GTSXB
(long_description)
@type function
@author jacomo.fernandes
@since 12/02/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GA102GTSXB()
Local lRet		:= .F.
Local nOpc		:= 0
Local oLookUp  	:= Nil
Local aIndice  	:= {}
Local aRetorno 	:= {}
Local cFldVar	:= AllTrim(StrTran(ReadVar(),'M->',''))
Local cQuery   	:= ""          

Local oModel	:= Nil

Local cAgenci	:= ""
Local cTpDoc	:= ""
Local cSerie	:= ""
Local cSubSer	:= ""
Local cNumCom	:= ""
 
Local n1		:= 0

If FwIsInCallStack('GTPA117')
	oModel	:= FwModelActive()
	
	cAgenci	:= oModel:GetValue('G57MASTER','G57_AGENCI')
	cTpDoc	:= oModel:GetValue('G57MASTER','G57_TIPO')
	
	If cFldVar == "G57_SERIE"
		nOpc	:= 1
	ElseIf cFldVar == "G57_SUBSER"
		nOpc	:= 2
		cSerie	:= oModel:GetValue('G57MASTER','G57_SERIE')
	ElseIf cFldVar == "G57_NUMCOM"
		nOpc	:= 3
		cSerie	:= oModel:GetValue('G57MASTER','G57_SERIE')
		cSubSer	:= oModel:GetValue('G57MASTER','G57_SUBSER')
	ElseIf cFldVar == "G57_CODIGO"
		nOpc	:= 4
		cSerie	:= oModel:GetValue('G57MASTER','G57_SERIE')
		cSubSer	:= oModel:GetValue('G57MASTER','G57_SUBSER')
		cNumCom	:= oModel:GetValue('G57MASTER','G57_NUMCOM')
	Endif
	
Endif


Do Case
	Case nOpc == 1
		cFields := "GII_SERIE"
		
		aAdd(aIndice,{"Série", "GII_SERIE"})
		
	Case nOpc == 2
		cFields := "GII_SERIE,GII_SUBSER"
		
		aAdd(aIndice,{"Série"		, "GII_SERIE"})
		aAdd(aIndice,{"Sub-Série"	, "GII_SUBSER"})
	Case nOpc == 3
		cFields := "GII_SERIE,GII_SUBSER,GII_NUMCOM"
		
		aAdd(aIndice,{"Série"			, "GII_SERIE"})
		aAdd(aIndice,{"Sub-Série"		, "GII_SUBSER"})
		aAdd(aIndice,{"Nr. Complemento"	, "GII_NUMCOM"})
		
	Case nOpc == 4
		cFields := "GII_SERIE,GII_SUBSER,GII_NUMCOM,GII_BILHET"
		
		aAdd(aIndice,{"Série"			, "GII_SERIE"})
		aAdd(aIndice,{"Sub-Série"		, "GII_SUBSER"})
		aAdd(aIndice,{"Nr. Complemento"	, "GII_NUMCOM"})
		aAdd(aIndice,{"Código"			, "GII_BILHET"})
EndCase	

cQuery := ""

cQuery += " SELECT DISTINCT " +cFields  
cQuery += " FROM "+RetSqlName("GII")+" GII "
cQuery += " WHERE "
cQuery += " 	GII.GII_FILIAL = '"+xFilial('GII')+"' "
cQuery += " 	AND GII.D_E_L_E_T_ = ' ' "
cQuery += " 	AND GII.GII_UTILIZ = 'F' "

If !Empty(cAgenci)
	cQuery += " 	AND GII.GII_AGENCI = '"+cAgenci+"' "
Endif
If !Empty(cTpDoc)
	cQuery += " 	AND GII.GII_TIPO = '"+cTpDoc+"' "
Endif
If !Empty(cSerie)
	cQuery += " 	AND GII.GII_SERIE = '"+cSerie+"' "
Endif
If !Empty(cSubSer)
	cQuery += " 	AND GII.GII_SUBSER = '"+cSubSer+"' "
Endif
If !Empty(cNumCom) 
	cQuery += " 	AND GII.GII_NUMCOM = '"+cNumCom+"' "
Endif
	
oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), Separa(cFields,","))

For n1 := 1 To Len(aIndice)
	oLookUp:AddIndice(aIndice[n1][1]	, aIndice[n1][2])
Next

If oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	cSXBGI8RET := aRetorno[nOpc]
EndIf   

FreeObj(oLookUp)

Return lRet

/*/{Protheus.doc} GA422RTSXB
(long_description)
@type function
@author jacomo.fernandes
@since 12/02/2019
@version 1.0
@param nOpc, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GA102RTSXB(nOpc)
Return cSXBGI8RET


//------------------------------------------------------------------------------
/* /{Protheus.doc} G102DTVENC

@type Function
@author jacomo.fernandes
@since 12/08/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function G102DTVENC(cTpDoc, cSerie, cSubSer, cNumCom, cNumIni, cNumFim, dDtEmiss)
Local lRet          := .T.
Local cAliasTmp     := GetNextAlias()
Default dDtEmiss    := dDataBase

BeginSql Alias cAliasTmp
    COLUMN GII_DTINI AS DATE
    COLUMN GII_DTFIM AS DATE
    Select 
        MIN(GII_DTINI) AS GII_DTINI,
        MIN(GII_DTFIM) AS GII_DTFIM
    From %Table:GII% GII
    Where
        GII.GII_FILIAL = %xFilial:GII%
        AND GII_TIPO = %Exp:cTpDoc%
        AND GII_SERIE = %Exp:cSerie%
        AND GII_SUBSER = %Exp:cSubSer%
        AND GII_NUMCOM = %Exp:cNumCom%
        AND GII_BILHET BETWEEN %Exp:cNumIni% AND %Exp:cNumFim%
        AND GII.%NotDel%
EndSql

If (cAliasTmp)->(!EOF())
    If !Empty((cAliasTmp)->GII_DTINI) .and. !Empty((cAliasTmp)->GII_DTFIM)
        //Se a data de emissão não estiver dentro da data de vigencia, retorna erro
        If !( (cAliasTmp)->GII_DTINI <= dDtEmiss .and. (cAliasTmp)->GII_DTFIM >= dDtEmiss )
            lRet := .F.
        Endif
    Endif
Else
    lRet := .F.
Endif

(cAliasTmp)->(DbCloseArea())


Return lRet
