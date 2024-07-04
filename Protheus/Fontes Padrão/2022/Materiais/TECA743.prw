#Include "Protheus.ch"
#Include "FWMVCDef.ch"
#Include "TECA743.ch"

Static cProdFil 
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Kaique Schiller
@since 24/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStruTFJ	:= Nil
Local oStruTFI	:= Nil

oModel 	 := MPFormModel():New("TECA743",,,{|oModel| At743Cmt( oModel ) })
oStruTFJ := FWFormStruct(1,"TFJ",{|cCampo| AllTrim(cCampo) $ "TFJ_CODIGO#TFJ_PROPOS#TFJ_CODENT#TFJ_LOJA#TFJ_TPFRET" })
oStruTFI := FWFormStruct(1,"TFI",{|cCampo| AllTrim(cCampo) $ "TFI_ITEM#TFI_CONENT#TFI_ENTEQP#TFI_CONCOL#TFI_COLEQP#TFI_PERINI#TFI_PERFIM#TFI_PRODUT#TFI_LOCAL#TFI_COD#TFI_CODPAI"})

oStruTFJ:AddField(  STR0001,;               	       // cTitle	//"Nr. Contrato"
	                STR0001,;             		       // cToolTip	//"Nr. Contrato"
	                "TFJ_CONTRT",;                     // cIdField
	                "C",;                              // cTipo
	                TamSX3("TFJ_CONTRT")[1],;          // nTamanho
	                0,;                                // nDecimal
	                NIL,;                              // bValid
	                NIL,;                              // bWhen
	                NIL,;                              // aValues
	                .F.,;                              // lObrigat
	                NIL,;                              // bInit
	                .F.,;                              // lKey
	                Nil,;                              // lNoUpd
	                .T.)                               // lVirtual

oStruTFJ:AddField(  STR0002,;            		       // cTitle	//"Nome Entidade"
	                STR0002,;                  		   // cToolTip	//"Nome Entidade"
	                "TFJ_NOMENT",;                     // cIdField
	                "C",;                              // cTipo
	                TamSX3("A1_NOME")[1],;             // nTamanho
	                0,;                                // nDecimal
	                NIL,;                              // bValid
	                NIL,;                              // bWhen
	                NIL,;                              // aValues
	                .F.,;                              // lObrigat
	                NIL,;                              // bInit
	                .F.,;                              // lKey
	                Nil,;                              // lNoUpd
	                .T.)                               // lVirtual

oStruTFI:AddField( 	STR0003,;                    	   // cTitle	//"Desc. Prod."
	                STR0003,;                    	   // cToolTip	//"Desc. Prod."
	                "TFI_DESCRI",;                     // cIdField
	                "C",;                              // cTipo
	                TamSX3("B1_DESC")[1],;             // nTamanho
	                0,;                                // nDecimal
	                NIL,;                              // bValid
	                NIL,;                              // bWhen
	                NIL,;                              // aValues
	                .F.,;                              // lObrigat
	                NIL,;                              // bInit
	                .F.,;                              // lKey
	                Nil,;                              // lNoUpd
	                .T.)                               // lVirtual

oStruTFI:AddField(  STR0004,;                    	   // cTitle	//"Desc. Local"
	                STR0004,;                    	   // cToolTip	//"Desc. Local"
	                "TFI_LOCDSC",;                     // cIdField
	                "C",;                              // cTipo
	                TamSX3("ABS_DESCRI")[1],;          // nTamanho
	                0,;                                // nDecimal
	                NIL,;                              // bValid
	                NIL,;                              // bWhen
	                NIL,;                              // aValues
	                .F.,;                              // lObrigat
	                NIL,;                              // bInit
	                .F.,;                              // lKey
	                Nil,;                              // lNoUpd
	                .T.)                               // lVirtual

oStruTFJ:SetProperty( "TFJ_CODIGO" , MODEL_FIELD_OBRIGAT,.F.)

oStruTFI:SetProperty( "TFI_ENTEQP", MODEL_FIELD_WHEN, {|| FwFldGet("TFI_CONENT") == "1" } )
oStruTFI:SetProperty( "TFI_COLEQP", MODEL_FIELD_WHEN, {|| FwFldGet("TFI_CONCOL") == "1" } )

oModel:Addfields("TFJMASTER",/*cOwner*/,oStruTFJ,/*bPreVld*/,/*bPosVld*/,{|oModel| At743TFJ(oModel)})
oModel:AddGrid("TFIDETAIL","TFJMASTER" ,oStruTFI, /*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,{|oModel| At743TFI(oModel)})

oModel:GetModel('TFIDETAIL'):SetNoInsertLine()
oModel:GetModel('TFIDETAIL'):SetNoDeleteLine()

oModel:SetPrimaryKey({"TFJ_FILIAL", "TFJ_CODIGO"})

AjustaTEC("TECA743")

oModel:SetVldActivate( {|oModel| At743VlIni(oModel)} ) 

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Kaique Schiller
@since 24/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel	:= Nil
Local oStruTFJ	:= Nil
Local oStruTFI	:= Nil
Local oView		:= Nil

oModel		:= FWLoadModel("TECA743")
oStruTFJ	:= FWFormStruct( 2, "TFJ",{|cCampo| AllTrim(cCampo) $ "TFJ_CODIGO#TFJ_PROPOS#TFJ_CODENT#TFJ_LOJA#TFJ_TPFRET"})
oStruTFI	:= FWFormStruct( 2, "TFI",{|cCampo| AllTrim(cCampo) $ "TFI_ITEM#TFI_CONENT#TFI_ENTEQP#TFI_CONCOL#TFI_COLEQP#TFI_PERINI#TFI_PERFIM#TFI_PRODUT#TFI_LOCAL"})

oStruTFJ:AddField(	"TFJ_CONTRT",;           		 // cIdField
					"01",;                		     // cOrdem
					STR0001,;     		  		     // cTitulo //"Nr. Contrato"
					STR0001,;     			  		 // cDescric //"Nr. Contrato"
					NIL,;          					 // aHelp
					"GET",;                   		 // cType
					"@!",; 						     // cPicture
					NIL,;   	 	                 // nPictVar
					"",;            		         // Consulta F3
					.F.,;              		         // lCanChange
					NIL,;                    		 // cFolder
					NIL,;                    		 // cGroup
					{},; 							 // aComboValues
					NIL,;                    		 // nMaxLenCombo
					NIL,;                    		 // cIniBrow
					.T.)                     		 // lVirtual

oStruTFJ:AddField(	"TFJ_NOMENT",;           		 // cIdField
					"06",;                		     // cOrdem
					STR0002,;     				     // cTitulo //"Nome Entidade"
					STR0002,;     			  		 // cDescric //"Nome Entidade"
					NIL,;          					 // aHelp
					"GET",;                   		 // cType
					"@!",; 						     // cPicture
					NIL,;   	 	                 // nPictVar
					"",;            		         // Consulta F3
					.F.,;              		         // lCanChange
					NIL,;                    		 // cFolder
					NIL,;                    		 // cGroup
					{},; 							 // aComboValues
					NIL,;                    		 // nMaxLenCombo
					NIL,;                    		 // cIniBrow
					.T.)                     		 // lVirtual

oStruTFI:AddField(	"TFI_DESCRI",;           		 // cIdField
					"09",;                		     // cOrdem
					STR0003,;     				     // cTitulo //"Desc. Prod."
					STR0003,;     			  		 // cDescric //"Desc. Prod."
					NIL,;          					 // aHelp
					"GET",;                   		 // cType
					"@!",; 						     // cPicture
					NIL,;   	 	                 // nPictVar
					"",;            		         // Consulta F3
					.F.,;              		         // lCanChange
					NIL,;                    		 // cFolder
					NIL,;                    		 // cGroup
					{},; 							 // aComboValues
					NIL,;                    		 // nMaxLenCombo
					NIL,;                    		 // cIniBrow
					.T.)                     		 // lVirtual

oStruTFI:AddField(	"TFI_LOCDSC",;           		 // cIdField
					"11",;                		     // cOrdem
					STR0004,;     				     // cTitulo //"Desc. Local"
					STR0004,;     	  				 // cDescric //"Desc. Local"
					NIL,;          					 // aHelp
					"GET",;                   		 // cType
					"@!",; 						     // cPicture
					NIL,;   	 	                 // nPictVar
					"",;            		         // Consulta F3
					.F.,;              		         // lCanChange
					NIL,;                    		 // cFolder
					NIL,;                    		 // cGroup
					{},; 							 // aComboValues
					NIL,;                    		 // nMaxLenCombo
					NIL,;                    		 // cIniBrow
					.T.)                     		 // lVirtual
					
oStruTFJ:SetProperty( "TFJ_CODIGO", MVC_VIEW_ORDEM, "02" )
oStruTFJ:SetProperty( "TFJ_PROPOS", MVC_VIEW_ORDEM, "03" )
oStruTFJ:SetProperty( "TFJ_CODENT", MVC_VIEW_ORDEM, "04" )
oStruTFJ:SetProperty( "TFJ_LOJA"  , MVC_VIEW_ORDEM, "05" )
oStruTFJ:SetProperty( "TFJ_TPFRET", MVC_VIEW_ORDEM, "07" )

oStruTFI:SetProperty( "TFI_ITEM"  , MVC_VIEW_ORDEM, "01" )
oStruTFI:SetProperty( "TFI_CONENT", MVC_VIEW_ORDEM, "02" )
oStruTFI:SetProperty( "TFI_ENTEQP", MVC_VIEW_ORDEM, "03" )
oStruTFI:SetProperty( "TFI_CONCOL", MVC_VIEW_ORDEM, "04" )
oStruTFI:SetProperty( "TFI_COLEQP", MVC_VIEW_ORDEM, "05" )
oStruTFI:SetProperty( "TFI_PERINI", MVC_VIEW_ORDEM, "06" )
oStruTFI:SetProperty( "TFI_PERFIM", MVC_VIEW_ORDEM, "07" )
oStruTFI:SetProperty( "TFI_PRODUT", MVC_VIEW_ORDEM, "08" )
oStruTFI:SetProperty( "TFI_LOCAL" , MVC_VIEW_ORDEM, "10" )

oStruTFJ:SetProperty("*",			MVC_VIEW_CANCHANGE,.F.)
oStruTFI:SetProperty("TFI_ITEM",	MVC_VIEW_CANCHANGE,.F.)
oStruTFI:SetProperty("TFI_PERINI",	MVC_VIEW_CANCHANGE,.F.)
oStruTFI:SetProperty("TFI_PERFIM",	MVC_VIEW_CANCHANGE,.F.)
oStruTFI:SetProperty("TFI_PRODUT",	MVC_VIEW_CANCHANGE,.F.)
oStruTFI:SetProperty("TFI_LOCAL",	MVC_VIEW_CANCHANGE,.F.)

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_TFJ", oStruTFJ, "TFJMASTER")
oView:AddGrid( "VIEW_TFI", oStruTFI, "TFIDETAIL")

oView:CreateHorizontalBox("PAI"  , 30)
oView:CreateHorizontalBox("FILHO", 70)

oView:SetOwnerView("VIEW_TFJ", "PAI")
oView:SetOwnerView("VIEW_TFI", "FILHO")

oView:SetDescription( STR0005 ) // "Confirmação de Entrega e Coleta"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TECA743
FWExecView como alteração - Confirmação de Entrega e Coleta.

@return	Nil

@author Kaique Schiller
@since 24/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Function TECA743(cProd)
Default cProd := ""
cProdFil := cProd 

FWExecView(,"VIEWDEF.TECA743", MODEL_OPERATION_UPDATE,/*oDlg*/,{||.T.}/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/) // "Confirmação de Entrega e Coleta"

cProdFil := ""

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} At743TFJ
Realiza a carga de dados do orçamento de serviço.

@param  oMdl , objeto, Objeto com o modelo.
@return	aRet , array , Array com os dados.

@author Kaique Schiller
@since 24/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function At743TFJ(oMdl)
Local aRet		:= {}
Local cTmpQry	:= ""

cTmpQry	:= GetNextAlias()

BeginSql Alias cTmpQry

	SELECT 	TFJ_CODIGO
		   ,TFJ_PROPOS
		   ,TFJ_CONTRT
		   ,TFJ_CODENT
		   ,TFJ_LOJA
		   ,A1_NOME TFJ_NOMENT
		   ,TFJ_TPFRET
	FROM %Table:TFJ% TFJ
	INNER JOIN %Table:SA1% SA1
		ON  TFJ_FILIAL = %xFilial:TFJ%
		AND	TFJ_CODENT = A1_COD
		AND	TFJ_LOJA   = A1_LOJA
		AND TFJ.%NotDel%
	WHERE A1_FILIAL 	= %xFilial:SA1%
		AND TFJ_CODIGO	= %Exp:TFJ->TFJ_CODIGO%
		AND	SA1.%NotDel%
EndSql

aRet := FwLoadByAlias( oMdl, cTmpQry )

(cTmpQry)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At743TFI
Realiza a carga de dados das locações.

@param  oMdl , objeto, Objeto com o modelo.
@return	aRet , array , Array com os dados.

@author Kaique Schiller
@since 24/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function At743TFI(oMdl)
Local aRet		:= {}
Local cTmpQry	:= ""
Local oMod		:= Nil
Local oFieldTFJ := Nil
Local cCodTFJ	:= ""
Local cFiltro := "%%"

cTmpQry		:= GetNextAlias()
oMod		:= oMdl:GetModel()
oFieldTFJ 	:= oMod:GetModel("TFJMASTER")
cCodTFJ		:= oFieldTFJ:GetValue("TFJ_CODIGO")

If !Empty(cProdFil)
	cFiltro := "% AND TFI_PRODUT = '"+ cProdFil + "'%"
EndIf

BeginSql Alias cTmpQry
	
	COLUMN TFI_ENTEQP AS DATE
	COLUMN TFI_COLEQP AS DATE
	COLUMN TFI_PERINI AS DATE
	COLUMN TFI_PERFIM AS DATE
	
	SELECT  TFI_ITEM
		   ,TFI_CONENT
		   ,TFI_CONCOL
		   ,TFI_ENTEQP
		   ,TFI_COLEQP
		   ,TFI_PERINI
		   ,TFI_PERFIM
		   ,TFI_PRODUT
		   ,B1_DESC    TFI_DESCRI
		   ,TFI_LOCAL
		   ,ABS_DESCRI TFI_LOCDSC
		   ,TFI_COD
		   ,TFI_CODPAI
	FROM %Table:TFL% TFL
	INNER JOIN %Table:TFI% TFI
		ON 	TFI_FILIAL	= %xFilial:TFI%
		AND TFI_CODPAI	= TFL_CODIGO
		%Exp:cFiltro%
		AND TFI.%NotDel%
	INNER JOIN %Table:SB1% SB1
		ON 	B1_FILIAL 	= %xFilial:SB1%
		AND B1_COD   	= TFI_PRODUT
		AND SB1.%NotDel%
	INNER JOIN %Table:ABS% ABS
		ON 	ABS_FILIAL 	= %xFilial:ABS%
		AND ABS_LOCAL 	= TFI_LOCAL
		AND ABS.%NotDel%
	WHERE TFL_FILIAL	= %xFilial:TFL%
		AND TFL_CODPAI 	= %Exp:cCodTFJ%
		AND TFL.%NotDel%
EndSql

aRet := FwLoadByAlias( oMdl, cTmpQry )

(cTmpQry)->(DbCloseArea())

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At743Cmt
Gravação dos dados alterados na tela de confirmação de entrega e coleta.

@param oModel, objeto, Objeto com o modelo.
@return	lRet , logico, Se procegue ou não com a gravação.

@author Kaique Schiller
@since 24/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function At743Cmt(oModel)
Local oMdlTmp	:= Nil
Local oTmpTFL 	:= Nil
Local oTmpTFI	:= Nil
Local oHeadTFJ	:= Nil
Local oGridTFI	:= Nil
Local aArea		:= {}
Local cCodTFJ	:= ""
Local nK		:= 0
Local nGridTFI	:= 0
Local nTmpTFL	:= 0
Local nTmpTFI	:= 0
Local lEnt		:= .F.
Local lCol		:= .F.
Local lRet 		:= .T.

aArea := GetArea()

oHeadTFJ 	:= oModel:GetModel("TFJMASTER")
oGridTFI	:= oModel:GetModel("TFIDETAIL")
cCodTFJ 	:= oHeadTFJ:GetValue("TFJ_CODIGO")

nGridTFI := oGridTFI:Length()

oMdlTmp	:= FWLoadModel("TECA740")
oMdlTmp:SetOperation(MODEL_OPERATION_UPDATE)
DbSelectArea("TFJ")
TFJ->(DbSetOrder(1)) //TFJ_FILIAL+TFJ_CODIGO
TFJ->(DbSeek(xFilial("TFJ")+cCodTFJ))
oMdlTmp:Activate()

For nK := 1 To nGridTFI
	oGridTFI:GoLine(nK)
	oTmpTFL := oMdlTmp:GetModel("TFL_LOC")
	If oTmpTFL:SeekLine({{"TFL_CODIGO",oGridTFI:GetValue("TFI_CODPAI")}})
		oTmpTFI := oMdlTmp:GetModel("TFI_LE")
		If oTmpTFI:SeekLine({{"TFI_COD",oGridTFI:GetValue("TFI_COD")}})
			oTmpTFI:SetValue("TFI_CONENT",oGridTFI:GetValue("TFI_CONENT"))
			If oGridTFI:GetValue("TFI_CONENT") == "1"
				oTmpTFI:SetValue("TFI_ENTEQP",oGridTFI:GetValue("TFI_ENTEQP"))
			Endif
			oTmpTFI:SetValue("TFI_CONCOL",oGridTFI:GetValue("TFI_CONCOL"))
			If oGridTFI:GetValue("TFI_CONCOL") == "1"
				oTmpTFI:SetValue("TFI_COLEQP",oGridTFI:GetValue("TFI_COLEQP"))
			Endif
		Endif
	Endif
Next nK

If oMdlTmp:VldData()
	FWFormCommit(oMdlTmp)
	oMdlTmp:DeActivate()
	oMdlTmp:Destroy()
	lRet := .T.
Else
	JurShowErro( oMdlTmp:GetModel():GetErrormessage() )
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} At743VlIni
Realiza a validação para que não abra a tela se não houver locações.

@param oModel, objeto, Objeto com o modelo.
@return	lRet , logico, Se procegue ou não com a abertura da tela.

@author Kaique Schiller
@since 24/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function At743VlIni(oModel)
Local lRet := .F.
Local cNewAlias	 := GetNextAlias()

BeginSql Alias cNewAlias

	SELECT TFI_COD 
	FROM %Table:TFJ% TFJ
	INNER JOIN %Table:TFL% TFL
		ON TFL_FILIAL = %xFilial:TFL%
		AND TFL_CODPAI = TFJ_CODIGO  
		AND TFL.%NotDel%
	INNER JOIN %Table:TFI% TFI
		ON TFI_FILIAL = %xFilial:TFI%
		AND TFI_CODPAI = TFL_CODIGO
		AND TFI.%NotDel%
	WHERE TFJ_FILIAL = %xFilial:TFJ%
		AND TFJ_CODIGO = %Exp:TFJ->TFJ_CODIGO%
		AND TFJ.%NotDel%
	
EndSql

DbSelectArea(cNewAlias)

If (cNewAlias)->(!Eof())
	lRet := .T.
Else
	Help(,,"At743VlIni",,STR0006,1,0,,,,,,{STR0007}) //"Não existe locações." ## "Posicione em um registro que contenha locações." 
Endif
	
(cNewAlias)->(dbCloseArea())

Return lRet