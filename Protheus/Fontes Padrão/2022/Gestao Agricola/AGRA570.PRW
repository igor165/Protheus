#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "AGRA570.ch"

Static __aTab1225 := {"NLN"}               //tabela inovação liberada na P12.1.25
Static __lLib1225 := AGRTABDIC(__aTab1225) //verifica se array de tabelas existe no dicionario de dados - para proteçao fonte

/*/{Protheus.doc} AGRA570
// Tela de solicitação de negociação de frete.
@author brunosilva
@since 13/06/2018
@version undefined
@param cInstEmb, characters, descricao
@type function
/*/
Function AGRA570()
	Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0003/*"Fechar"*/},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	Pergunte("AGRA570001", .F.)
	
	//carga inicial na coluna N7S_SALNEG
	AGRA570SLD()
	
	FwExecView(STR0001,'AGRA570', MODEL_OPERATION_UPDATE ,/*oDlg*/,/*bCloseOnOK*/,/*bOk*/,/*nPercReducao*/,aButtons,{|| bCancelOpe()}) //"Negociação de Frete"
	
Return
 
 
/*/{Protheus.doc} bCancelOpe
//Função acionada no botão FECHAR para desabilitar validações de preenchimento da view.
@author brunosilva
@since 18/06/2018
@version undefined

@type function
/*/
Static Function bCancelOpe()
	Local oView := FwViewActive()

	oView:oModel:lModify := .F.
	oView:lModify := .F.

Return .T.


/*/{Protheus.doc} ModelDef
@author brunosilva
@since 13/06/2018
@version undefined

@type function
/*/
Static Function ModelDef()
	Local oModel	:= NIL
	Local oStruN7Q 	:= FWFormStruct(1, "N7Q")
	Local oStruN7S 	:= FWFormStruct(1, "N7S")
	Local oStruN9R  := FWFormStruct(1, "N9R")
	Local oStruGXR  := FWFormStruct(1, "GXR")
	Local bLinePre  := {|oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue| AGRA570LEG(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)}
	Local bLoadGXR  := {|oGridModel, lCopy| AGR570Load(oGridModel, lCopy)}
	
	oModel := MpFormModel():New("AGRA570")
	oModel:SetDescription( STR0001 ) //'Negociação de frete'

	//-------------------------------------
	// Adiciona a estrutura da Field
	//-------------------------------------
	oModel:AddFields( "AGRA570_N7Q", ,oStruN7Q)
	
	//-------------------------------------
	// Adiciona a estrutura da Grid N7S
	//-------------------------------------
	oModel:AddGrid( "AGRA570_N7S", "AGRA570_N7Q", oStruN7S)
	oModel:GetModel("AGRA570_N7S"):SetOnlyQuery (.T.)
	oModel:SetRelation( 'AGRA570_N7S', { { 'N7S_FILIAL', 'FWXFilial( "N7S" )' } , { 'N7S_CODINE', 'N7Q_CODINE' }  }, N7S->( IndexKey( 1 )))
	oModel:GetModel( 'AGRA570_N7S'):SetLoadFilter( , A570FILTER())
	
	oStruN7S:SetProperty( 'N7S_QTDNEG', MODEL_FIELD_VALID , {|| AGRA570QTD()})
	
	//-------------------------------------
	// Adiciona a estrutura da Grid N9R
	//-------------------------------------
	oModel:AddGrid( "AGRA570_N9R", "AGRA570_N7S", oStruN9R)
	oModel:GetModel("AGRA570_N9R"):SetOnlyView(.T.)
	oModel:GetModel("AGRA570_N9R"):SetOnlyQuery (.T.)
	oModel:SetRelation( 'AGRA570_N9R', { { 'N9R_FILIAL', 'FWXFilial( "N9R" )' }, { 'N9R_CODINE', 'N7S_CODINE' } }, N9R->( IndexKey( 2 )))
	oModel:GetModel( "AGRA570_N9R" ):SetOptional(.T.)

	//-------------------------------------
	// Adiciona a estrutura da Grid GXR
	//-------------------------------------
	oModel:AddGrid( "AGRA570_GXR", "AGRA570_N9R", oStruGXR, bLinePre, /*<bLinePost>*/, /*<bPre>*/, /*<bLinePost>*/, bLoadGXR)
	oModel:GetModel("AGRA570_GXR"):SetOnlyView(.T.)
	oModel:GetModel("AGRA570_GXR"):SetOnlyQuery (.T.)
	oModel:SetRelation( 'AGRA570_GXR', { { 'GXR_FILIAL', 'FWXFilial( "GXR" )' }, { 'GXR_IDREQ', 'N9R_IDREQ' } }, GXR->( IndexKey( 1 )))
	oModel:GetModel( "AGRA570_GXR" ):SetOptional(.T.)

	//-----------------------------------------------
	// Adiciona estrutura da GRID o campo de legenda
	//-----------------------------------------------
	oStruGXR:AddField(STR0005 /*Status*/, STR0005 /*Status*/, 'GXR_STSLEG', 'BT' , 1 , 0, , NIL , NIL, NIL, NIL, NIL, .F., .F.) 

    //-----------------------------------------------
	// Adiciona estrutura descrição IE
	//-----------------------------------------------
	oStruN7S:AddField(STR0017 /*Instr. Emb.*/, STR0017 /*Instr. Emb.*/, 'N7S_DESINE', 'C' , 30 , 0, , NIL , NIL, NIL, NIL, NIL, .F., .F.)

    //-----------------------------------------------
	// Adiciona estrutura Incoterm
	//-----------------------------------------------
	oStruN7S:AddField(STR0020 /*Incoterm*/, STR0020 /*Incoterm*/, 'N7S_INCOTE', 'C' , 5 , 0, , NIL , NIL, NIL, NIL, NIL, .F., .F.)

	//------------------------------------------------
	// Inicializa legenda no GRID 
	//------------------------------------------------
	oStruGXR:SetProperty( 'GXR_STSLEG' , MODEL_FIELD_INIT , {|| AGRA570INL()})

	//------------------------------------------------
	// Inicializa descrição IE 
	//------------------------------------------------
	oStruN7S:SetProperty( 'N7S_DESINE' , MODEL_FIELD_INIT , {|| AGRA570DIE()})

	//------------------------------------------------
	// Inicializa incoterm 
	//------------------------------------------------
	oStruN7S:SetProperty( 'N7S_INCOTE' , MODEL_FIELD_INIT , {|| AGRA570INC()})

	oModel:GetModel('AGRA570_N7S'):SetNoInsertLine(.T.)
	oModel:GetModel('AGRA570_N7S'):SetNoDeleteLine(.T.)

	oModel:GetModel('AGRA570_GXR'):SetNoInsertLine(.T.)
	oModel:GetModel('AGRA570_GXR'):SetNoDeleteLine(.T.)
	
	oModel:SetActivate({|oModel| AGRA570ACT(oModel)})
	oModel:SetDeActivate({|oModel| AGRA570DCT(oModel)})

Return oModel


/*/{Protheus.doc} ViewDef
@author brunosilva
@since 13/06/2018
@version undefined

@type function
/*/
Static Function ViewDef()
	Local oModel 	:= FWLoadModel('AGRA570')
	Local oStrN7S	:= FWFormStruct(2, "N7S")
	Local oStrGXR	:= FWFormStruct(2, "GXR")
	Local oView		:= FWFormView():New()
	Local lSolFtAut := SuperGetMV("MV_AGRB004",.F.,.F.) 
	
	oView:SetModel(oModel)
	
	//-----------------------
	// Adiciona na View o botão de Legenda
	//-----------------------
	oStrGXR:AddField( "GXR_STSLEG" ,'01' , STR0005 /*Status*/, STR0005 /*Status*/ , {} , 'BT' ,'@BMP',NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )

	//-----------------------
	// Adiciona na View a descrição IE
	//-----------------------
	oStrN7S:AddField( "N7S_DESINE" ,'01' , STR0017 /*Instr. Emb.*/, STR0017 /*Instr. Emb.*/ , {} , 'C' ,'@!',NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )

	//-----------------------
	// Adiciona na View a descrição IE
	//-----------------------
	oStrN7S:AddField( "N7S_INCOTE" ,'01' , STR0020 /*Incoterm*/, STR0020 /*Incoterm*/ , {} , 'C' ,'@!',NIL, NIL, .T., NIL, NIL, NIL,    NIL, NIL, .T. )
		
	oStrN7S:SetProperty("N7S_OK"    ,MVC_VIEW_ORDEM,'01')
	oStrN7S:SetProperty("N7S_CODINE",MVC_VIEW_ORDEM,'02')
	oStrN7S:SetProperty("N7S_DESINE",MVC_VIEW_ORDEM,'03')
	oStrN7S:SetProperty("N7S_INCOTE",MVC_VIEW_ORDEM,'04')
	oStrN7S:SetProperty("N7S_QTDVIN",MVC_VIEW_ORDEM,'05')
	oStrN7S:SetProperty("N7S_QTDREM",MVC_VIEW_ORDEM,'06')
	oStrN7S:SetProperty("N7S_QTDNEG",MVC_VIEW_ORDEM,'07')
	oStrN7S:SetProperty("N7S_SALNEG",MVC_VIEW_ORDEM,'08')
	oStrN7S:SetProperty("N7S_FILORG",MVC_VIEW_ORDEM,'09')
	oStrN7S:SetProperty("N7S_CODCTR",MVC_VIEW_ORDEM,'10')
	oStrN7S:SetProperty("N7S_ITEM"  ,MVC_VIEW_ORDEM,'11')
	oStrN7S:SetProperty("N7S_DESCTR",MVC_VIEW_ORDEM,'12')
	oStrN7S:SetProperty("N7S_SEQPRI",MVC_VIEW_ORDEM,'13')	
	oStrN7S:SetProperty("N7S_CTREXT",MVC_VIEW_ORDEM,'14')
	oStrN7S:SetProperty("N7S_DATINI",MVC_VIEW_ORDEM,'15')
	oStrN7S:SetProperty("N7S_DATFIM",MVC_VIEW_ORDEM,'16')
	oStrN7S:SetProperty("N7S_CODFIN",MVC_VIEW_ORDEM,'17')
	oStrN7S:SetProperty("N7S_DESFIN",MVC_VIEW_ORDEM,'18')
	oStrN7S:SetProperty("N7S_OPEFIS",MVC_VIEW_ORDEM,'19')
	oStrN7S:SetProperty("N7S_TES"   ,MVC_VIEW_ORDEM,'20')
	oStrN7S:SetProperty("N7S_CODROM",MVC_VIEW_ORDEM,'21')
	
	oStrGXR:SetProperty("GXR_STSLEG",MVC_VIEW_ORDEM,'01')
	oStrGXR:SetProperty("GXR_IDREQ", MVC_VIEW_ORDEM,'02')
	oStrGXR:SetProperty("GXR_QTDET", MVC_VIEW_ORDEM,'03')
	oStrGXR:SetProperty("GXR_DTINI", MVC_VIEW_ORDEM,'04')
	oStrGXR:SetProperty("GXR_DTTER", MVC_VIEW_ORDEM,'05')
	oStrGXR:SetProperty("GXR_DTLIM", MVC_VIEW_ORDEM,'06')
	oStrGXR:SetProperty("GXR_CDREM", MVC_VIEW_ORDEM,'07')
	oStrGXR:SetProperty("GXR_NRCIDO",MVC_VIEW_ORDEM,'08')
	oStrGXR:SetProperty("GXR_UFO",   MVC_VIEW_ORDEM,'09')
	oStrGXR:SetProperty("GXR_CDDEST",MVC_VIEW_ORDEM,'10')
	oStrGXR:SetProperty("GXR_NRCIDD",MVC_VIEW_ORDEM,'11')
	oStrGXR:SetProperty("GXR_UFD",   MVC_VIEW_ORDEM,'12')
	oStrGXR:SetProperty("GXR_CDTPOP",MVC_VIEW_ORDEM,'13')
	oStrGXR:SetProperty("GXR_CDCLFR",MVC_VIEW_ORDEM,'14')
	oStrGXR:SetProperty("GXR_CODUSU",MVC_VIEW_ORDEM,'15')
	oStrGXR:SetProperty("GXR_FDADE", MVC_VIEW_ORDEM,'16')
	oStrGXR:SetProperty("GXR_MOTLIM",MVC_VIEW_ORDEM,'17')
	oStrGXR:SetProperty("GXR_OBSREQ",MVC_VIEW_ORDEM,'18')
	oStrGXR:SetProperty("GXR_DTREQ", MVC_VIEW_ORDEM,'19')
	oStrGXR:SetProperty("GXR_HRREQ", MVC_VIEW_ORDEM,'20')
	oStrGXR:SetProperty("GXR_USUNEG",MVC_VIEW_ORDEM,'21')
	oStrGXR:SetProperty("GXR_AVISO", MVC_VIEW_ORDEM,'22')
	oStrGXR:SetProperty("GXR_SITRES",MVC_VIEW_ORDEM,'23')
	oStrGXR:SetProperty("GXR_MOTREJ",MVC_VIEW_ORDEM,'24')
	oStrGXR:SetProperty("GXR_MOTCAN",MVC_VIEW_ORDEM,'25')
	
	oStrN7S:RemoveField("N7S_QTDDCD")
	oStrN7S:RemoveField("N7S_QTDSOL")
	oStrN7S:RemoveField("N7S_OPETRI")
	oStrN7S:RemoveField("N7S_OPEFUT")
	oStrN7S:RemoveField("N7S_INCAUT")

    oStrGXR:RemoveField("GXR_SIT")
	oStrGXR:RemoveField("GXR_NOMUSU")
	oStrGXR:RemoveField("GXR_NMREM")
	oStrGXR:RemoveField("GXR_NMCIDO")
	oStrGXR:RemoveField("GXR_NMDEST")
	oStrGXR:RemoveField("GXR_NMCIDD")
	oStrGXR:RemoveField("GXR_DSTPOP")
	oStrGXR:RemoveField("GXR_DSCLFR")
	oStrGXR:RemoveField("GXR_NMNEG")
	oStrGXR:RemoveField("GXR_EMAIL")
	oStrGXR:RemoveField("GXR_FONE")
	oStrGXR:RemoveField("GXR_DEPTO")
	oStrGXR:RemoveField("GXR_USUPER")
	oStrGXR:RemoveField("GXR_CC")
	oStrGXR:RemoveField("GXR_INFOAD")
	oStrGXR:RemoveField("GXR_IDENT")
	oStrGXR:RemoveField("GXR_TPIDEN")
	oStrGXR:RemoveField("GXR_PESOT")
	oStrGXR:RemoveField("GXR_UMPESO")
	oStrGXR:RemoveField("GXR_VALORT")
	oStrGXR:RemoveField("GXR_MOTLIM")
	oStrGXR:RemoveField("GXR_OBSREQ")
	oStrGXR:RemoveField("GXR_MOTREJ")
	oStrGXR:RemoveField("GXR_MOTCAN")
		
	oStrN7S:SetProperty("N7S_OK"         , MVC_VIEW_CANCHANGE ,.T.)
	oStrN7S:SetProperty("N7S_OK"         , MODEL_FIELD_INIT   ,{|| .F. })
	
	oStrN7S:SetProperty("N7S_CODINE"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_DESINE"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_INCOTE"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_QTDVIN"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_QTDREM"     , MVC_VIEW_CANCHANGE ,.F.)	
	oStrN7S:SetProperty("N7S_QTDNEG"     , MVC_VIEW_CANCHANGE ,.T.)
	oStrN7S:SetProperty("N7S_SALNEG"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_CODCTR"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_ITEM"       , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_DESCTR"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_SEQPRI"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_DATINI"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_DATFIM"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_CODFIN"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_DESFIN"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_OPEFIS"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_TES"        , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_FILORG"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_CTREXT"     , MVC_VIEW_CANCHANGE ,.F.)
	oStrN7S:SetProperty("N7S_CODROM"     , MVC_VIEW_CANCHANGE ,.F.)
	
	oView:AddGrid( 'VIEW_N7S',oStrN7S,'AGRA570_N7S')
	oView:AddGrid( 'VIEW_GXR',oStrGXR,'AGRA570_GXR')

	//---------------------------------------------	
	//Grid N7S
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'N7S_VIEW' , 50)
	oView:CreateVerticalBox( 'VIEW_VERT', 100, 'N7S_VIEW' )

	//---------------------------------------------	
	//Grid GXR
	//---------------------------------------------	
	oView:CreateHorizontalBox( 'GXR_VIEW' , 50)
	oView:CreateVerticalBox( 'VIEW_VERT', 100, 'GXR_VIEW' )
	
	oView:CreateFolder('FOLDER1','GXR_VIEW')
	oView:AddSheet('FOLDER1','ABAETAPA', STR0001 ) //Negociação de  Frete
	oView:CreateHorizontalBox( 'BOXETAPA', 100, , , 'FOLDER1', 'ABAETAPA')
	
	oView:SetOwnerView( 'VIEW_N7S', 'N7S_VIEW' )
	oView:SetOwnerView( 'VIEW_GXR', 'BOXETAPA' )
	
	If !(lSolFtAut)
	   oView:AddUserButton(STR0002, '', {|oModel,oView| AGRA570SFR(oModel,oView)}) //"Solicitar Negociação de Frete"
	EndIf   
	oView:AddUserButton(STR0018,'', {|oModel| AGRA570F12(oModel)},,,,.T.) //"Filtrar"
	
Return oView

/*/{Protheus.doc} AGRA570ACT
//Função executada ativação do modelo
@author marina.muller
@since 27/07/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function AGRA570ACT(oModel)
	Local lRet		:= .T.
	
	SetKey(VK_F4, nil) //Desabilita F4 do OGA710
	
Return lRet

/*/{Protheus.doc} AGRA570DCT
//Função executada na desativação do modelo
@author marina.muller
@since 27/07/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function AGRA570DCT(oModel)
	Local lRet		:= .T.
	
	SetKey(VK_F4, {|| OGA710F4()}) //Habilita F4 do OGA710
	
Return lRet

/*/{Protheus.doc} AGRA570F12
//Função acionada no botão filtro 
@author marina.muller
@since 01/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA570F12(oModel)
	Local aLines  	:= FwSaveRows()
	Local lRet		:= .T.
	
	If Pergunte( "AGRA570001", .T.)
		Processa({|| lRet := AG570LdFlt(oModel)}, STR0013, STR0014 ) //"Atualizando solicitação frete..."###"Aguarde"
	Endif	
	
	FwRestRows(aLines)
	
Return lRet

/*/{Protheus.doc} AGRA570QTD
//Função atuliza coluna N7S_SALNEG quando for alterado campo N7S_QTDNEG
@author marina.muller
@since 26/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA570QTD() 
	Local oModel	:= FWModelActive()
	Local aLines    := FwSaveRows()
	Local oStruN7S  := oModel:GetModel('AGRA570_N7S')
	Local lRet      := .T.
	Local nQtdNeg   := oStruN7S:GetValue('N7S_QTDNEG', oStruN7S:GetLine()) 
	Local nSalNeg   := oStruN7S:GetValue('N7S_SALNEG', oStruN7S:GetLine())
    
    If nSalNeg < nQtdNeg
	    oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", oModel:GetErrorMessage()[6], oModel:GetErrorMessage()[7] + STR0004, "", "") //"Quantidade Negociada deve ser menor que Saldo Negociado."
		lRet := .F.
    EndIf
     
	FwRestRows(aLines)

Return lRet

/*/{Protheus.doc} AGRA570SLD
//Função faz carga inicial da coluna N7S_SALNEG (qtidade instruida - qtidade remetida)
@author marina.muller
@since 26/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA570SLD()
	Local lRet		  := .T.
	Local aSaveArea   := GetArea()
	Local cAliasN7S   := GetNextAlias()	
	Local nSalNeg     := 0

	BeginSql Alias cAliasN7S
	SELECT N7S_FILIAL, N7S_CODINE, N7S_CODCTR, N7S_ITEM, N7S_SEQPRI, N7S_QTDVIN, N7S_QTDREM
	FROM %Table:N7S% N7S
	WHERE N7S.%NotDel%
	  AND N7S.N7S_SALNEG = 0 
	  AND N7S.N7S_QTDVIN > N7S.N7S_QTDREM
	  AND NOT EXISTS (SELECT N9R.N9R_CODINE
                        FROM %Table:N9R% N9R
                       WHERE N9R.%NotDel%
                         AND N9R.N9R_FILIAL = N7S.N7S_FILIAL
                         AND N9R.N9R_CODINE = N7S.N7S_CODINE
                         AND N9R.N9R_CODCTR = N7S.N7S_CODCTR  
                         AND N9R.N9R_ITEM   = N7S.N7S_ITEM)  
                         //VER SE PRECISA DO SEQPRI
	  
	EndSQL
    
    (cAliasN7S)->(dbGoTop())
    While (cAliasN7S)->(!Eof())
    	// calcula valor do saldo negociado
    	nSalNeg := (cAliasN7S)->N7S_QTDVIN - (cAliasN7S)->N7S_QTDREM
    	
    	//chama função que atualiza saldo na N7S
    	AGRA570ATU((cAliasN7S)->N7S_FILIAL, (cAliasN7S)->N7S_CODINE, (cAliasN7S)->N7S_CODCTR, (cAliasN7S)->N7S_ITEM, (cAliasN7S)->N7S_SEQPRI, nSalNeg, 0)
    	
    	(cAliasN7S)->(dbSkip())
    EndDo
    (cAliasN7S)->( dbCloseArea() )
    
    RestArea( aSaveArea )
	
Return lRet

/*/{Protheus.doc} AGRA570ATU
//Função atualiza coluna N7S_SALNEG quando for alterado coluna N7S_QTDNEG
@author marina.muller
@since 26/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA570ATU(cFilN7S, cCodIne, cCodCtr, cItem, cSeqPri, nSalNeg, nQtdNeg)
	Local lRet		:= .T.
	Local aLines    := FwSaveRows()

    dbSelectArea("N7S")
    dbSetOrder(1)
    If DbSeek(cFilN7S+cCodIne+cCodCtr+cItem+cSeqPri) //N7S_FILIAL+N7S_CODINE+N7S_CODCTR+N7S_ITEM+N7S_SEQPRI
	    If nQtdNeg > 0 
	        nSalNeg := nSalNeg - nQtdNeg
	   	Endif

	   	RecLock("N7S",.F.)
	   	N7S->N7S_SALNEG := nSalNeg 
	   	MsUnLock()
	EndIf	
	N7S->(dbCloseArea())
    	
	FwRestRows(aLines)
	
Return lRet


/*/{Protheus.doc} AG570LdFlt
//Responsável por carregar a query do filter pelo processa.
@author brunosilva
@since 19/02/2019
@version 1.0
@param oModel, object, descricao
@type function
/*/
Static Function AG570LdFlt(oModel)
	Local lRet := .T.	
		
	oModel:DeActivate()  
	oModel:GetModel( 'AGRA570_N7S'):SetLoadFilter( , A570FILTER())
	oModel:Activate()
		
Return lRet

/*/{Protheus.doc} A570FILTER
//Função faz filtro na GRID N7S para trazer apenas registros com saldo para negociação frete
@author marina.muller
@since 26/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function A570FILTER()
	Local cQry      := ""
	Local lFilt		:= FWISINCALLSTACK('AGRA570F12')
	//Local lVazio	:= (EMPTY(MV_PAR01)) .AND. (EMPTY(MV_PAR012)) .AND. (EMPTY(MV_PAR03)) .AND. (EMPTY(MV_PAR04)) .AND. (EMPTY(MV_PAR05)) .AND. (EMPTY(MV_PAR06)) .AND. (EMPTY(MV_PAR07)) .AND. (EMPTY(MV_PAR08)) 
	
	cQry := " 1 = 1 "
	
	if lFilt 
		cQry := cQry + " AND D_E_L_E_T_ = ' '"
		If !(EMPTY(MV_PAR01))
		   cQry := cQry + " AND N7S_FILORG >= '" + MV_PAR01 + "' "
		EndIf
		
		If !(EMPTY(MV_PAR02))
		   cQry := cQry + " AND N7S_FILORG <= '" + MV_PAR02 + "' "
		EndIf
	
		If !(EMPTY(MV_PAR03))
		   cQry := cQry + " AND N7S_CODINE >= '" + MV_PAR03 + "' "
		EndIf
	
		If !(EMPTY(MV_PAR05))
		   cQry := cQry + " AND N7S_CODINE <= '" + MV_PAR05 + "' "
		EndIf
	
		If !(EMPTY(MV_PAR07))
		   cQry := cQry + " AND N7S_CTREXT >= '" + MV_PAR07 + "' "
		EndIf
	
		If !(EMPTY(MV_PAR08))
		   cQry := cQry + " AND N7S_CTREXT <= '" + MV_PAR08 + "' "
		EndIf
	else //Primeira abertura
		cQry := cQry + " AND N7S_CODINE >= '" + N7Q->N7Q_CODINE + "' "
		cQry := cQry + " AND N7S_CODINE <= '" + N7Q->N7Q_CODINE + "' "
	endIf
	
Return cQry

/*/{Protheus.doc} AGRA570SFR
//Responsável pela chamada do GFE para Solicitação de Frete dos itens da IE marcada.
@author brunosilva / marina.muller
@since 16/06/2018
@version undefined

@type function
/*/
Static Function AGRA570SFR(oModel,oView)
	Local aSaveArea := GetArea()
	Local lRet		:= .T.
	Local oMdlN7S	:= Nil
	Local oMdlN7Q	:= Nil
	Local aSolicN7S := {}
	Local aSomaN7S  := {}
	Local cFilAtu   := ""
	Local nQtdSoma  := 0
	Local lMudouFil := .F.
	Local lFirst    := .T.
	Local nLinha    := 1
	Local nI
	Local cCodIne   := ""
	Local cFilOrg	:= ""
	Local cFilEnt	:= ""
	Local lMsg		:= .F.
	Local lAlert	:= .F.
	Local lYesNo	:= .F.
	Local cObserv   := ""
	Local cGU3Org	:= ""
	Local cGU3Ent	:= ""
	Local cCodClient:= ""	
	Local cCodLoja	:= ""
	Local cUnPrc	:= ""
	Local cUMOrig	:= ""
	Local lExterno	:= .f.
	Local lAlgodao  := .F.
	Local lVinRem	:= .f.
	Local aValAlg	:= []
	Local aVExAlg	:= []
	Local aValores	:= {}
	Local nQtdFrd	:= 0
	Local cVlt2Mo   := 0
	Local cCdClFr	:= ''
	Local dDtLimi   
	Local dDtInic
	Local dDtTerm

	If !(oModel:IsActive())
		oModel:Activate()
	EndIf
	
	oMdlN7S	:= oModel:GetModel('AGRA570_N7S')
	oMdlN7Q	:= oModel:GetModel('AGRA570_N7Q')
    
	//inclui array com os registros selecionados em tela
	For nI := 1 To oMdlN7S:Length()
		oMdlN7S:GoLine(nI)
		
		//verifica se registro está marcado em tela
		If oMdlN7S:GetValue('N7S_OK') == .T.

			//verifica se o saldo negociado é mario que a quantidade negociada
			If oMdlN7S:GetValue("N7S_QTDNEG") > oMdlN7S:GetValue("N7S_SALNEG")

				lAlert := .T.
				oMdlN7S:SetValue('N7S_OK', .F.)
				LOOP

			//verifica se o saldo negociado está zerado
			ElseIf oMdlN7S:GetValue("N7S_SALNEG") = 0

				lMsg := .T.
				oMdlN7S:SetValue('N7S_OK', .F.)
				LOOP

			Else
				DbSelectArea('N7Q')
				N7Q->(dbSetOrder(1))
				If N7Q->(dbSeek(FwxFilial('N7Q')+oMdlN7S:GetValue("N7S_CODINE")))
					lExterno	:= N7Q->N7Q_TPMERC = '2'
					lAlgodao  := iif(Posicione("SB5",1,fwxFilial("SB5")+N7Q->N7Q_CODPRO,"B5_TPCOMMO")== '2',.T.,.F.)
					lVinRem	:= (lExterno .AND. !lAlgodao/*GRAOS*/)
					cCdClFr := POSICIONE("GUK", 1, FWxFilial("GUK") + PADR(AllTrim(N7Q->N7Q_CODPRO), TamSX3("GUK_ITEM")[1]), "GUK_CDCLFR")
					
					If lExterno .AND. Empty(N7Q->N7Q_ENTENT)
						If .NOT. MsgYesNo(STR0023) //Entidade de entrega
							oMdlN7S:SetValue('N7S_OK', .F.)
							lYesNo := .T.
							LOOP
						Endif
					Endif
					
					//armazena primeira linha processada
					If lFirst
						nLinha := nI 
						lFirst := .F. 
					EndIf		
					
					//tipo mercado 2=Externo
					If N7Q->N7Q_TPMERC == '2'
						dDtLimi  := N7Q->N7Q_DDELDR
						dDtTerm  := ""
						dDtInic  := ""
					//tipo mercado 1=Interno
					Else
						dDtLimi  := oMdlN7S:GetValue("N7S_DATFIM")
						dDtTerm  := oMdlN7S:GetValue("N7S_DATFIM")
						dDtInic  := oMdlN7S:GetValue("N7S_DATINI")
					EndIf
					
					
					//ACHAR cFilOrg E cFilEnt na GU3
					cFilOrg 	:= POSICIONE('NJ0',5,FWxFilial('N7S') + oMdlN7S:GetValue("N7S_FILORG"), "NJ0_CGC" )  
					cFilEnt 	:= POSICIONE('NJ0',1,FWxFilial('N7Q') + IIF(EMPTY(N7Q->N7Q_ENTENT),N7Q->N7Q_IMPORT,N7Q->N7Q_ENTENT ) + IIF(EMPTY(N7Q->N7Q_LOJENT),N7Q->N7Q_IMLOJA ,N7Q->N7Q_LOJENT), "NJ0_CGC" ) 	
					cCodClient	:= POSICIONE('NJ0',5,FWxFilial('N7S') + oMdlN7S:GetValue("N7S_FILORG"), "NJ0_CODENT" )
					cCodLoja	:= POSICIONE('NJ0',5,FWxFilial('N7S') + oMdlN7S:GetValue("N7S_FILORG"), "NJ0_LOJENT" )
					
					cObserv := N7Q->N7Q_OBSERV
						
					cGU3Org := GETDATASQL("SELECT GU3_CDEMIT FROM " + RetSqlName("GU3") + " WHERE GU3_IDFED = '" + cFilOrg +"' ")
					cGU3Ent := GETDATASQL("SELECT GU3_CDEMIT FROM " + RetSqlName("GU3") + " WHERE GU3_IDFED = '" + cFilEnt +"' ")
					
					
					/*------ PEGAR O VALOR BASEADO NA REGRA FISCAL -------*/
					//GRAOS MERCADO INTERNO REMESSA ou EXTERNO
					//OGAX721 === PEGA O N8D_VALOR PARA USAR COMO TOTAL NA REQUISIÇÃO DA FRETE.
					aValores := OGAX721FAT(FWxFilial('N9A') , oMdlN7S:GetValue("N7S_CODCTR"), oMdlN7S:GetValue("N7S_ITEM") , oMdlN7S:GetValue("N7S_SEQPRI"), , oMdlN7S:GetValue("N7S_QTDVIN"), , cCodClient, cCodLoja, /*cFormCalc*/, /*nQtdConsum*/, /*nQtdUsTot*/, /*dDataVenc*/)
					
					if EMPTY(aValores)
						cVlt2Mo := Posicione('N9A',1,FWxFilial('N9A')+oMdlN7S:GetValue("N7S_CODCTR")+oMdlN7S:GetValue("N7S_ITEM")+oMdlN7S:GetValue("N7S_SEQPRI"),"N9A_VLUFPR")
					else
						//Valor unitário em REAL/SC
						cVlt2Mo := aValores[1][1]
						
						//Unidade de medida do contrato
						cUnPrc  := Posicione('NJR',1,FWxFilial('NJR')+ oMdlN7S:GetValue("N7S_CODCTR"),"NJR_UM1PRO")
						
						//Unidade de medida de preço do produto 
						cUMOrig := AGRUmPrc(N7Q->N7Q_CODPRO)
						
						//Converte o valor pra unidade de medida de preço do produto
						cVlt2Mo := AGRX001(cUnPrc, cUMOrig, cVlt2Mo, N7Q->N7Q_CODPRO)
					endIf				
					/*------ PEGAR O VALOR BASEADO NA REGRA FISCAL -------*/
					
					
					if lAlgodao										
						//Pega a quantidade instruida
						aValAlg :=  GetDataSqA("SELECT SUM(N83_QUANT), SUM(N83_PSBRUT) FROM " + RetSqlName('N83') + " " +;
											   "WHERE N83_FILIAL =    '" + oMdlN7S:GetValue("N7S_FILIAL") + "' " +;
											        "AND N83_CODCTR = '" + oMdlN7S:GetValue("N7S_CODCTR") + "' " +;
											        "AND N83_CODINE = '" + oMdlN7S:GetValue("N7S_CODINE") + "' " +; 
											        "AND N83_ITEM =   '" + oMdlN7S:GetValue("N7S_ITEM")   + "' " +;
											        "AND N83_ITEREF = '" + oMdlN7S:GetValue("N7S_SEQPRI") + "' " +;
											        "AND D_E_L_E_T_ = ' '" )
						//aValAlg[1] = QUANTIDADE DE FARDINHOS INSTRUIDOS
						//aValAlg[2] = PESO BRUTO DA INSTRUÇÃO
						if lExterno
							aVExAlg :=  GetDataSqA ("SELECT SUM(N9D.N9D_PESINI), SUM(DXI.DXI_PSTARA), COUNT(*) FROM " + RetSqlName('N9D') + " N9D " +;
													  "INNER JOIN " + RetSqlName('DXI') + " DXI ON DXI.D_E_L_E_T_ = ' ' " +;
													       "AND DXI.DXI_FILIAL = N9D.N9D_FILIAL " +;
													       "AND DXI.DXI_SAFRA = N9D.N9D_SAFRA " +;
													       "AND DXI.DXI_ETIQ = N9D.N9D_FARDO " +;
													  "INNER JOIN " + RetSqlName('N9D') + " N9D2 ON N9D2.D_E_L_E_T_ = ' ' " +;
														   "AND N9D2.N9D_FILIAL = N9D.N9D_FILIAL " +;
														   "AND N9D2.N9D_SAFRA = N9D.N9D_SAFRA " +;
														   "AND N9D2.N9D_FARDO = N9D.N9D_FARDO " +;
														   "AND N9D2.N9D_TIPMOV = '04' " +;
														   "AND N9D2.N9D_STATUS = '2' " +;
													  "WHERE N9D2.N9D_FILORG = '" + oMdlN7S:GetValue("N7S_FILIAL") + "' "    +;
													       "AND N9D2.N9D_CODINE = '" + oMdlN7S:GetValue("N7S_CODINE") + "' " +;
													       "AND N9D2.N9D_CODCTR = '" + oMdlN7S:GetValue("N7S_CODCTR") + "' " +;
													       "AND N9D2.N9D_ITEETG = '" + oMdlN7S:GetValue("N7S_ITEM") + "' "   +;
													       "AND N9D2.N9D_ITEREF = '" + oMdlN7S:GetValue("N7S_SEQPRI") + "' " +;
													       "AND N9D.N9D_STATUS = '2' "+;
													       "AND N9D.N9D_TIPMOV = '07' "+;
													       "AND N9D.D_E_L_E_T_ = ' '")
							//aVExAlg[1] = TOTAL LIQUIDO
							//aVExAlg[2] = TARA DE ACORDO COM A DXI
							//aVExAlg[3] = QUANTIDADE DE FARDINHOS
							
							//Pega a quantidade instruida e diminui a quantidade que já foi remetida(Que está no porto)
							aValAlg[2] := aValAlg[2] - (aVExAlg[1] + aVExAlg[2])
							//  quantidade instruida - quantidade remetida(que está no porto)
							aValAlg[1] := aValAlg[1] - aVExAlg[3]
						endIf
						
						//função da solicitação de frete (fonte AGRX570.prw)
						aAdd(aSolicN7S,{oMdlN7S:GetValue("N7S_FILORG"),;  //1 - filial origem
									oMdlN7S:GetValue("N7S_CODINE"),;  //2 - instrução embarque
									oMdlN7S:GetValue("N7S_ITEM")  ,;  //3 - ID entrega fiscal
									oMdlN7S:GetValue("N7S_CODROM"),;  //4 - romaneio
									aValAlg[2]					  ,;  //5 - quantidade instruída (negociada)
					                oMdlN7S:GetValue("N7S_SALNEG"),;  //6 - saldo negociado
									oMdlN7S:GetValue("N7S_CODCTR"),;  //7 - contrato  
									oMdlN7S:GetValue("N7S_SEQPRI"),;  //8 - sequencia
									dDtTerm,;                         //9 - Data término
									cGU3Org,;						  //10- Filial de origem
									cGU3Ent,;						  //11 - Filial destino
									N7Q->N7Q_UNIMED ,;				  //12- unidade de medida da IE
									dDtInic,;                         //13 - data ini
									Posicione('NJU',1,fwxFilial('NJU')+N7Q->N7Q_CODSAF,"NJU_OPELOG"),; // 14 - operacao logistica
			                        cVlt2Mo,;  	  					    // 15 - valor total fixação  
			                        N7Q ->N7Q_OBSERV ,;                 //16 - observação N7Q 
			                        aValAlg[1],;						//17 - Quantidade de fardos
			                        cCdClFr,;                           //18 - Codigo da Clas. Fret de acordo com produto na tabela de item com exceção  
			                        dDtLimi})						    //19 - data limite
					else  //GRAOS
						aAdd(aSolicN7S,{oMdlN7S:GetValue("N7S_FILORG"),;  //1 - filial origem
									oMdlN7S:GetValue("N7S_CODINE"),;  //2 - instrução embarque
									oMdlN7S:GetValue("N7S_ITEM")  ,;  //3 - ID entrega fiscal
									oMdlN7S:GetValue("N7S_CODROM"),;  //4 - romaneio
									oMdlN7S:GetValue("N7S_QTDNEG"),;  //5 - quantidade negociada
									oMdlN7S:GetValue("N7S_SALNEG"),;  //6 - saldo negociado
									oMdlN7S:GetValue("N7S_CODCTR"),;  //7 - contrato  
									oMdlN7S:GetValue("N7S_SEQPRI"),;  //8 - sequencia
									dDtTerm,;                         //9 - Data término
									cGU3Org,;						  //10- Filial de origem
									cGU3Ent,;						  //11 - Filial destino
									N7Q->N7Q_UNIMED ,;				  //12- unidade de medida da IE
									dDtInic,;                         //13 - data ini
									Posicione('NJU',1,fwxFilial('NJU')+N7Q->N7Q_CODSAF,"NJU_OPELOG"),; // 14 - operacao logistica
			                        cVlt2Mo,;  						  // 15 - valor total fixação  
			                        cObserv,;						  //16 - observação N7QA
			                        0,;							      //17 - Quantidade de fardos(0 p é grãos, só pra compatibilizar os arrays)
			                        cCdClFr,;                         //18 - Codigo da Class. Fret de acordo com produto na tabela de item com exceção
			                        dDtLimi})					      //19 - data limite
					endIf
				Endif
				N7Q->(dbCloseArea())
			Endif
		EndIf
	Next nI
	
	//Saldo zerado
	If lMsg	
		MsgAlert(STR0021) //O campo Saldo Negoc. não possue valor a ser negociado
		oMdlN7S:GoLine(1) //posiciona na 1º linha do GRID
		return
	Endif
	//Saldo menor que a quantidade negociada
	If lAlert	
		MsgAlert(STR0022) //O valor do campo Saldo Negoc. é inferior a Qtd Neg Fret
		oMdlN7S:GoLine(1) //posiciona na 1º linha do GRID
		return
	Endif
	//Nao gerar solicitação sem remetente
	If lYesNo	
		oMdlN7S:GoLine(1) //posiciona na 1º linha do GRID
		return
	Endif
	//Não encontrou registros marcados na GRID
	If Len(aSolicN7S) == 0
	   ApMsgAlert(STR0015) //"Não foram marcadas itens para processamento."
	   oMdlN7S:GoLine(1) //posiciona na 1º linha do GRID
	   Return
	EndIf
	
	//ordena array pelo campo N7S_FILORG
	ASORT(aSolicN7S, , , { | x,y | x[1] < y[1] } )
    
    //atribui valor da primeira linha e coluna
	cFilAtu := aSolicN7S[1][1]
	    
	//inclui array com quantidade acumulada por filial
	For nI := 1 To Len(aSolicN7S)
		//Se filial da posição do array for igual filial atual
		If aSolicN7S[nI][1] == cFilAtu
		    lMudouFil := .T.
		    cCodIne   := aSolicN7S[nI][2]

		    if lAlgodao
		    	nQtdFrd := nQtdFrd + aSolicN7S[nI][17]
		    endIf		    
			//se quantidade negociada for informada
			If aSolicN7S[nI][5] > 0 
			   //soma o valor da quantidade para mesma filial
			   nQtdSoma := nQtdSoma + aSolicN7S[nI][5] 
			//senão atribui valor do saldo negociado
			Else
			   //soma o valor da quantidade para mesma filial
			   nQtdSoma := nQtdSoma + aSolicN7S[nI][6]
			EndIf   
		Else
			aAdd(aSomaN7S,{cFilAtu, ;  //1 - filial origem
			               nQtdSoma,;  //2 - Peso acumulado por filial
			               cCodIne,;   //3 - instrução embarque (Ident Demand)
			               iif(lAlgodao,nQtdFrd,nQtdSoma)}) //4 - Qtd acumulado por filial          
			               				
			lMudouFil := .F.
			cCodIne   := ""
			cFilAtu   := aSolicN7S[nI][1]
			nQtdSoma  := 0
			nI := nI - 1
		EndIf
	Next nI
    
    //inclui último registro
    If lMudouFil
		aAdd(aSomaN7S,{cFilAtu, ;          //1 - filial origem
		               nQtdSoma,;          //2 - Peso acumulada por filial
		               cCodIne,;   		   //3 - instrução embarque (Ident Demand)
			           iif(lAlgodao,nQtdFrd,nQtdSoma)}) //4 - Qtd acumulado por filial      
	EndIf

	//-- INICIO TRANSACAO --//
	BEGIN TRANSACTION

		//função que irá gravar os registros
		Processa({|| lRet := AGRA570GRV(aSolicN7S, aSomaN7S)}, STR0013, STR0014 ) //"Atualizando solicitação frete..."###"Aguarde"

	    If !(lRet)
		   DisarmTransaction()
		EndIf

	END TRANSACTION
	//-- FINAL TRANSACAO --//

	//inicializa o GRID após processamento
	Processa({|| lRet := AGRA570LIM(oModel, oMdlN7S)}, STR0016, STR0014 ) //"Efetivando solicitação frete..."###"Aguarde"
    
    oMdlN7S:GoLine(nLinha) //posiciona na 1º linha processada
    
	If lRet 
       ApMsgAlert(STR0006) //"Solicitação frete realizada com sucesso."	   
	EndIf   
   	
	RestArea( aSaveArea )
	
Return lRet

/*/{Protheus.doc} AGRA570GRV
//Função grava/atualiza as tabelas N7S, N9R, GXR
@author marina.muller
@since 04/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function AGRA570GRV(aSolicN7S, aSomaN7S)
	Local lRet		  := .T.
	Local aSaveArea   := GetArea()
	Local nY          := 1
	Local nX 

	Private _aIdReGXR := {}	

	//neste for inclui registros GXR
	For nX := 1 To Len(aSomaN7S)
		lRet := AGRA570GXR(aSomaN7S, nX, aSolicN7S) 

		If !(lRet)
		   Exit
		Endif
	Next nX

	If lRet
        //atribui valor da primeira linha e coluna
        cFilAtu := aSolicN7S[1][1]

		//neste for inclui registros na N9R
		For nX := 1 To Len(aSolicN7S)
		    //se filial da posição do array for diferente da filial atual
		    If aSolicN7S[nX][1] <> cFilAtu
		       nY := nY + 1
		       cFilAtu := aSolicN7S[nX][1]
		    EndIf

		    //incluir tabela N9R
			lRet := AGRA570N9R(aSolicN7S, nX, _aIdReGXR[nY][2])

			If !(lRet)
			   Exit
			Endif
		Next nX
	EndIf

	If lRet
		//neste for atualiza saldo N7S
		For nX := 1 To Len(aSolicN7S)
			//verifica se quantidade negociada foi informada
			If aSolicN7S[nX][5] > 0
			   lRet := AGRA570ATU(FWxFilial("N7S"),;     //filial IE
			                      aSolicN7S[nX][2],;     //2 - instrução embarque
			                      aSolicN7S[nX][7],;     //7 - contrato
			                      aSolicN7S[nX][3],;     //3 - ID entrega fiscal
			                      aSolicN7S[nX][8],;     //8 - sequencia
			                      aSolicN7S[nX][6],;     //6 - saldo negociado
			                      aSolicN7S[nX][5])      //5 - quantidade negociada

		    //senão negociou todo saldo do frete
		    Else
			   lRet := AGRA570ATU(FWxFilial("N7S"),;     //filial IE
			                      aSolicN7S[nX][2],;     //2 - instrução embarque
			                      aSolicN7S[nX][7],;     //7 - contrato
			                      aSolicN7S[nX][3],;     //3 - ID entrega fiscal
			                      aSolicN7S[nX][8],;     //8 - sequencia
			                      0               ,;     //6 - saldo negociado
			                      0)                     //5 - quantidade negociada
		    EndIf
			
			If !(lRet)
			   Exit
			Endif
		Next nX
	EndIf

    RestArea( aSaveArea )
	
Return lRet

/*/{Protheus.doc} AGRA570N9R
//Função inclui registro na N9R
@author marina.muller
@since 04/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AGRA570N9R(aSolicN7S, nX, cIdReq)
	Local lRet		  := .T.
	Local aSaveArea   := GetArea()
	Local cCodN9R     := ""

	//-- Busca proxima numeração da tabela N9R 
	cCodN9R := GetSXENum("N9R","N9R_CODIGO")
	N9R->(dbSetOrder(1))
	While N9R->(dbSeek(FwXFilial("N9R")+cCodN9R))
		If ( __lSx8)
			//--Salva numeração
			ConfirmSX8()
		EndIf
		cCodN9R := GetSXENum("N9R","N9R_CODIGO")
	EndDo
	
    RecLock('N9R', .T.)
		N9R->N9R_FILIAL := FWxFilial("N9R")
		N9R->N9R_CODIGO := cCodN9R  
		N9R->N9R_FILORI := aSolicN7S[nX][1]
		N9R->N9R_CODINE := aSolicN7S[nX][2]
		N9R->N9R_ITEM   := aSolicN7S[nX][3]
		N9R->N9R_CODROM := aSolicN7S[nX][4]
		N9R->N9R_CODCTR := aSolicN7S[nX][7]
	
	IF  __lLib1225	
		N9R->N9R_SEQPRI := aSolicN7S[nX][8]
	ENDIF		
		//se quantidade negociada for informada
		If aSolicN7S[nX][5] > 0 
		   N9R->N9R_QTDCTR := aSolicN7S[nX][5]
		   
		//senão atribui valor do saldo negociado
		Else
		   N9R->N9R_QTDCTR := aSolicN7S[nX][6]
		EndIf
		
		N9R->N9R_IDREQ := cIdReq   
		
	N9R->(msUnLock())

	//Se a cópia for confirmada
	If !(lRet)
		//--Retorna numeração
		RollBackSx8()	
	EndIf
    	
    RestArea( aSaveArea )
	
Return lRet

/*/{Protheus.doc} AGRA570GXR
//Função inclui registro na GXR
@author marina.muller
@since 04/07/2018
@version 1.0
@return ${return}, ${return_description}
@param aSomaN7S, array, descricao
@param nX, numeric, descricao
@type function
/*/
Static Function AGRA570GXR(aSomaN7S, nX, aSolicN7S)
	Local aArea    := GetArea()
	Local lRet	   := .T.
	Local cFilLog  := ""

	//armazena valor da filial logada
	cFilLog := cFilAnt
	
	//recebe filial origem a IE
	cFilAnt := aSomaN7S[nX][1]

	//Instancia o Model do GFEA059 (Negociação Frete)
	oMdlGXR := FwLoadModel("GFEA059")
   
	//Seta operação de Inclusão
	oMdlGXR:SetOperation(MODEL_OPERATION_INSERT)
    
    //Ativa o modelo
	oMdlGXR:Activate()
	
	oMdlGXR:SetValue('GFEA059_GXR','GXR_FILIAL', cFilAnt)           //Filial origem IE 
	oMdlGXR:SetValue('GFEA059_GXR','GXR_CDREM ', aSolicN7S[nX][10]) //Código origem
	oMdlGXR:SetValue('GFEA059_GXR','GXR_CDDEST', aSolicN7S[nX][11]) //Código destino  
	oMdlGXR:SetValue('GFEA059_GXR','GXR_FDADE' , "2")               //Contratação
	oMdlGXR:SetValue('GFEA059_GXR','GXR_TPIDEN', "5")               //Tipo Identificador
	oMdlGXR:SetValue('GFEA059_GXR','GXR_SIT'   , "2")               //Tipo Identificador
	oMdlGXR:SetValue('GFEA059_GXR','GXR_QTDET' , aSomaN7S[nX][4])   //Qtde Total
	oMdlGXR:SetValue('GFEA059_GXR','GXR_PESOT' , aSomaN7S[nX][2])   //Peso Total
	oMdlGXR:SetValue('GFEA059_GXR','GXR_IDENT' , aSomaN7S[nX][3])   //Instrução embarque (Ident Demand)
	oMdlGXR:SetValue('GFEA059_GXR','GXR_DTTER' , aSolicN7S[nX][9])  //Data término
	oMdlGXR:SetValue('GFEA059_GXR','GXR_UMPESO', aSolicN7S[nX][12]) //Un. medida peso
	
	IF  __lLib1225
		oMdlGXR:SetValue('GFEA059_GXR','GXR_UNIMED', aSolicN7S[nX][12]) //Unidade de Medida qtde.
		oMdlGXR:SetValue('GFEA059_GXR','GXR_OBSCGA', aSolicN7S[nX][16]) //Observação carregamento
		oMdlGXR:SetValue('GFEA059_GXR','GXR_OBSDGA', aSolicN7S[nX][16]) //Observação descarregamento
		oMdlGXR:SetValue('GFEA059_GXR','GXR_CSTRES', "001")             //Responsável requisição
		oMdlGXR:SetValue('GFEA059_GXR','GXR_CDCLFR', aSolicN7S[nX][18]) //Classificação de frete
		oMdlGXR:SetValue('GFEA059_GXR','GXR_DTLIM' , aSolicN7S[nX][19]) //Data limite
	ENDIF
	
	oMdlGXR:SetValue('GFEA059_GXR','GXR_DTINI' , aSolicN7S[nX][13]) //Data Inicio
	oMdlGXR:SetValue('GFEA059_GXR','GXR_CDTPOP', aSolicN7S[nX][14]) //Operação Logistica
	oMdlGXR:SetValue('GFEA059_GXR','GXR_VALORT', ( aSomaN7S[nX][4] * aSolicN7S[nX][15] )) //Valor Total Fixação

	If ( lRet := oMdlGXR:VldData() )
		lRet := FWFormCommit(oMdlGXR)
		aAdd(_aIdReGXR,{aSomaN7S[nX][1],;        //filial origem IE
		                FWFLDGET('GXR_IDREQ')})  //ID requisição
	Else
		// Se os dados não foram validados obtemos a descrição do erro para gerar
		// LOG ou mensagem de aviso
		AutoGrLog(oMdlGXR:GetErrorMessage()[6])
		AutoGrLog(oMdlGXR:GetErrorMessage()[7])
		If !Empty(oMdlGXR:GetErrorMessage()[2]) .AND. !Empty(oMdlGXR:GetErrorMessage()[9]) .AND.;
			Valtype(oMdlGXR:GetErrorMessage()[2]) == "C" .AND. Valtype(oMdlGXR:GetErrorMessage()[9]) == "C" // estava apresentando erros de typemismatch, includo proteção caso venha nil
			AutoGrLog(oMdlGXR:GetErrorMessage()[2] + " = " + oMdlGXR:GetErrorMessage()[9])
		EndIf
	
		MostraErro()
   EndIf
   
   // Desativamos o Model
   oMdlGXR:DeActivate()
   
   //devolve o valor da filial logada 
   cFilAnt := cFilLog 
   
   RestArea(aArea)

Return lRet

/*/{Protheus.doc} AGRA570LIM
//Função limpa GRID após processamento
@author marina.muller
@since 04/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AGRA570LIM(oModel, oMdlN7S)
	Local aLines  	:= FwSaveRows()
	Local lRet		:= .T.
    
    //desativa e ativa o modelo para carregar os dados processados na solicitação de frete 
	oModel:DeActivate()
	dbselectarea('N7Q')
	oModel:Activate()
	
    FwRestRows(aLines)
	
Return lRet

/*/{Protheus.doc} AGR570Load
//Função carrega o GRID da GXR em tela
@author marina.muller
@since 04/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function AGR570Load(oGridModel, lCopy)
	Local aArea      := GetArea()
	Local cAliasGXR  := GetNextAlias()
	Local oModel     := FwModelActive() 
	Local oMdlN7S    := oModel:GetModel('AGRA570_N7S')
    Local aLoad      := {}
    Local cFilOri    := ""
    Local cCodIne    := ""
    Local cItem      := ""
    Local cCodCtr    := ""
    Local cValor     := ""
    Local nX         := 1
	Local nY         := 1
	Local aLoadStr	 := {}
	Local oStruGXR   := FWFormStruct(1,"GXR")
	Local aCamposGXR := oStruGXR:Getfields()
	Local cValor2	 := ""
	Local dValor2	 
	Local nValor2	 := 0 
	Local cIDAnt	 := ""
    
    cFilOri := oMdlN7S:GetValue(('N7S_FILORG'), oMdlN7S:GetLine())
    cCodIne := oMdlN7S:GetValue(('N7S_CODINE'), oMdlN7S:GetLine())
    cItem   := oMdlN7S:GetValue(('N7S_ITEM'),   oMdlN7S:GetLine())
    cCodCtr := oMdlN7S:GetValue(('N7S_CODCTR'), oMdlN7S:GetLine())   
    
    BeginSql Alias cAliasGXR
	SELECT GXR.*
	  FROM %Table:GXR% GXR
	 INNER JOIN %Table:N9R% N9R
	    ON N9R.N9R_FILORI = GXR.GXR_FILIAL
	   AND N9R.N9R_IDREQ  = GXR.GXR_IDREQ
	   AND N9R.%NotDel%
	   AND GXR.%NotDel%
	 WHERE N9R.N9R_FILORI = %Exp:cFilOri%
	   AND N9R.N9R_CODINE = %Exp:cCodIne%
	   AND N9R.N9R_ITEM   = %Exp:cItem%
	   AND N9R.N9R_CODCTR = %Exp:cCodCtr%
	EndSQL
	
	(cAliasGXR)->(dbGoTop())
    While (cAliasGXR)->(!Eof())
    	
    	//A query está trazendo registros duplicados porque eu posso ter várias N9R pra uma GXR.
    	//O DISTINCT não fuciona na query por causa do campos MEMO. Por isto esta tratativa abaixo.
    	if cIDAnt != (cAliasGXR)->GXR_IDREQ
    		
    		cIDAnt := (cAliasGXR)->GXR_IDREQ
    		
	        //busca o valor da legenda
	        cValor := AGRA570INL((cAliasGXR)->GXR_SIT)
	       
		   //acumula os campos conforme estrutura		
			aLoadStr := {}
			
			For nY := 1 TO Len(aCamposGXR)
				If aCamposGXR[nY][14] //se for virtual joga em branco
					aAdd(aLoadStr,"")
				Else
					If aCamposGXR[nY][4] == "D"
						dValor2 := &("(cAliasGXR)->"+AllTrim(aCamposGXR[nY][3]))
						aAdd(aLoadStr, SToD(dValor2))
					
					ElseIf aCamposGXR[nY][4] == "N"
						nValor2 := &("(cAliasGXR)->"+AllTrim(aCamposGXR[nY][3]))
						aAdd(aLoadStr, nValor2 )
					
					ElseIf aCamposGXR[nY][4] == "C"
						cValor2 := &("(cAliasGXR)->"+AllTrim(aCamposGXR[nY][3]))
						aAdd(aLoadStr, cValor2 )
					
					ElseIf aCamposGXR[nY][4] == "M" //campos MEMO
						aAdd(aLoadStr,"")
					EndIf
				EndIf
			Next
			aAdd(aLoadStr, cValor)
	
			aAdd(aLoad, {nX, aLoadStr})
	
	        ////inclui registro no GRID da tabela GXR
	        //aAdd(aLoad, {nX,{(cAliasGXR)->GXR_FILIAL, 		; //1
	        //                 (cAliasGXR)->GXR_IDREQ,  		; //2	 
	        //                 (cAliasGXR)->GXR_CODUSU, 		; //3
	        //                 " ",                     		; //4 - //GXR_NOMUSU, ; coluna virtual
	        //                 (cAliasGXR)->GXR_EMAIL,  		; //5
	        //                 (cAliasGXR)->GXR_FONE,   		; //6
	        //                 (cAliasGXR)->GXR_DEPTO,  		; //7
	        //                 (cAliasGXR)->GXR_CC,     		; //8
	        //                 (cAliasGXR)->GXR_FDADE,  		; //9
	        //                 (cAliasGXR)->GXR_IDENT,  		; //10
	        //                 (cAliasGXR)->GXR_TPIDEN, 		; //11
	        //                 (cAliasGXR)->GXR_CDREM,  		; //12
	        //                 " ",                     		; //13 - //GXR_NMREM,  ; coluna virtual
	        //                 (cAliasGXR)->GXR_NRCIDO, 		; //14
	        //                 " ",             		  		; //15 - //GXR_NMCIDO, ; coluna virtual
	        //                 (cAliasGXR)->GXR_UFO,    		; //16
	        //                 (cAliasGXR)->GXR_CDDEST, 		; //17
	        //                 " ",             		  		; //18 - //GXR_NMDEST, ; coluna virtual
	        //                 (cAliasGXR)->GXR_NRCIDD,       ; //19
	        //                 " ",             		        ; //20 //GXR_NMCIDD, ; coluna virtual
	        //                 (cAliasGXR)->GXR_UFD,          ; //21
	        //                 (cAliasGXR)->GXR_CDTPOP,       ; //22
	        //                 " ",             		        ; //23 //GXR_DSTPOP, ; coluna virtual
	        //                 (cAliasGXR)->GXR_CDCLFR,       ; //24
	        //                 " ",             		        ; //25 //GXR_DSCLFR, ; coluna virtual
	        //                 (cAliasGXR)->GXR_PESOT,        ; //26
	        //                 (cAliasGXR)->GXR_UMPESO,       ; //27
	        //                 (cAliasGXR)->GXR_QTDET,        ; //28
	        //                 (cAliasGXR)->GXR_VALORT,       ; //29
	        //                 " ",					        ; //30 //>GXR_INFOAD, ; coluna memo
	        //                 STOD((cAliasGXR)->GXR_DTINI),  ; //31
	        //                 STOD((cAliasGXR)->GXR_DTTER),  ; //32
	        //                 STOD((cAliasGXR)->GXR_DTLIM),  ; //33
	        //                 " ",					  		; //34 //GXR_MOTLIM, ; coluna memo
	        //                 " ",					  		; //35 //GXR_OBSREQ, ; coluna memo
	        //                 STOD((cAliasGXR)->GXR_DTREQ),  ; //36
	        //                 (cAliasGXR)->GXR_HRREQ,  		; //37
	        //                 (cAliasGXR)->GXR_SIT,    		; //38
	        //                 (cAliasGXR)->GXR_USUNEG, 		; //39
	        //                 " ",             		  		; //40 //GXR_NMNEG,  ; coluna virtual
	        //                 (cAliasGXR)->GXR_AVISO,  		; //41
	        //                 (cAliasGXR)->GXR_SITRES, 		; //42
	        //                 " ",					  		; //43 //GXR_MOTREJ, ; coluna memo
	        //                 " ",					  		; //44 //GXR_MOTCAN, ; coluna memo
	        //                 cValor}})          			  //45 //Legenda
	        //
	        nX := nX + 1
	    endIf
	    
	    (cAliasGXR)->(dbSkip())
	EndDo
    (cAliasGXR)->( dbCloseArea() ) 
    
	RestArea(aArea)

Return aLoad

/*/{Protheus.doc} AGRA570LEG
//Função mostra telinha com as legendas 
@author marina.muller
@since 04/07/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Function AGRA570LEG(oGridModel, nLine, cAction, cIDField, xValue, xCurrentValue)
	Local aLegenda 	:= {}
	Local lRet		:= .T.

	If cIDField == "GXR_STSLEG" .AND. cAction != "SETVALUE"
	    aLegenda := {{ "BR_BRANCO",   STR0007  },; //"Em Edição"
	                 { "BR_AZUL",     STR0008  },; //"Requisitada"
	                 { "BR_AMARELO",  STR0009  },; //"Em Negociação"
	                 { "BR_VERDE",    STR0010  },; //"Atendida"
	                 { "BR_VERMELHO", STR0011  }}  //"Cancelada"

		BrwLegenda(STR0012 /*Legenda*/, STR0012 /*Legenda*/, aLegenda)
	EndIf

Return lRet

/*/{Protheus.doc} AGRA570INL
//Função seta valor da legenda nas linhas do GRID da GXR
@author marina.muller
@since 04/07/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA570INL(cSit)
	Local aArea     := GetArea()
	Local cValor    := ""
	Default cSit    := ""
	
	If cSit == "1"        //"Em Edição"
	   cValor := "BR_BRANCO"
	
	ElseIf cSit == "2"   //"Requisitada"
	   cValor := "BR_AZUL"

	ElseIf cSit == "3"   //"Em Negociação"
	   cValor := "BR_AMARELO"

	ElseIf cSit == "4"   //"Atendida"
	   cValor := "BR_VERDE"

	ElseIf cSit == "5"   //"Cancelada"
	   cValor := "BR_VERMELHO"
	EndIf

	RestArea(aArea)

Return cValor

/*/{Protheus.doc} AGRA570DIE
//Função seta valor da descrição IE
@author marina.muller
@since 27/07/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA570DIE()
	Local aArea     := GetArea()
	Local cValor    := ""
	
	cValor := Posicione("N7Q",1,(FWXFilial("N7Q")+N7S->N7S_CODINE),"N7Q_DESINE")
    
	RestArea(aArea)

Return cValor

/*/{Protheus.doc} AGRA570INC
//Função seta valor da incoterm
@author marina.muller
@since 24/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function AGRA570INC()
	Local aArea     := GetArea()
	Local cValor    := ""
	
	cValor := Posicione("N7Q",1,(FWXFilial("N7Q")+N7S->N7S_CODINE),"N7Q_INCOTE")
    
	RestArea(aArea)

Return cValor

/*/{Protheus.doc} AGRA570IED
//Função valid da IE de acionada no pergunte
@author marina.muller
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA570IED()
	Local aArea := GetArea()
	Local lRet  := .T.
	
	If EMPTY(MV_PAR03)
	   MV_PAR04 := ""	
	
	ElseIf !(EMPTY(MV_PAR03))
		lRet := ExistCpo('N7Q',MV_PAR03,1)
		
		If lRet
		   MV_PAR04 := Posicione("N7Q",1,(FWXFilial("N7Q")+MV_PAR03),"N7Q_DESINE") 
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGRA570IED
//Função valid da IE até acionada no pergunte 
@author marina.muller
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA570IEA()
	Local aArea := GetArea()
	Local lRet  := .T.
	
	If EMPTY(MV_PAR05)
	   MV_PAR06 := ""	
	
	ElseIf !(EMPTY(MV_PAR05))
		lRet := ExistCpo('N7Q',MV_PAR05,1)
		
		If lRet
		   MV_PAR06 := Posicione("N7Q",1,(FWXFilial("N7Q")+MV_PAR05),"N7Q_DESINE") 
		EndIf
	EndIf
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} AGRA570INK
//Função valida se pode ou não ser marcado checkbox conforme parametrização incoterm
@author marina.muller
@since 24/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA570INK()
	Local aArea     := GetArea()
	Local oModel	:= FwViewActive()
	Local oMdlN7S   := oModel:GetModel('AGRA570_N7S')
    Local cCodIne   := oMdlN7S:GetValue(('N7S_CODINE'), oMdlN7S:GetLine())
    Local cIncoterm := SuperGetMV("MV_AGRO034",.F.,.F.)
    Local cIncoN7Q  := ""
	Local aIncoterm := {}
	Local nPosicao  := 0
	Local lMarca    := .T.
	
	// se parâmetro não estiver vazio
	IF !Empty(cIncoterm)
		// transforma string com os dados do parâmetro em array
		aIncoterm := StrTokArr(cIncoterm, ",")
		
		//busca incoterm na tabela pai da IE
	    dbSelectArea('N7Q')
		N7Q->(dbSetOrder(1))    	
		If N7Q->(dbSeek(FwxFilial("N7Q")+cCodIne)) //N7Q_FILIAL+N7Q_CODINE
			cIncoN7Q := N7Q->N7Q_INCOTE
		EndIf  
		N7Q->(dbCloseArea())
		
		If !Empty(cIncoN7Q)
			
			//verifica se incoterm da N7Q está dentro do array
			nPosicao := Ascan(aIncoterm,{|x| ALLTRIM(x) == ALLTRIM(cIncoN7Q)})
			If nPosicao == 0
				lMarca := .T.
			Else
				ApMsgAlert(STR0019) //"IE não parametrizada para calcular despesas logísticas."
				lMarca := .F.
			EndIf
		EndIf	
	EndIf
	
	//se coluna incoterm estiver vazia não permite negociação de frete
	If Empty(oMdlN7S:GetValue(('N7S_INCOTE'), oMdlN7S:GetLine()))
		ApMsgAlert(STR0019) //"IE não parametrizada para calcular despesas logísticas."
		lMarca := .F.
	EndIf
		
	RestArea(aArea)

Return lMarca
