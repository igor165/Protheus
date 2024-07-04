#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"


Function GTPA600A()
Local cDescri	:= 'Alteração da Data da Viagem'
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., 'Confirmar' },{.T., 'Fechar'},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Confirmar"###"Fechar"


FWExecView( cDescri , "VIEWDEF.GTPA600A", 4,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , 50/*nPercReducao*/, aEnableButtons, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/ )

Return



/*/{Protheus.doc} ModelDef
Função que define o modelo de dados para a alteração da Data de viagem
@type function
@author jacomo.fernandes
@since 23/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel		:= nil
Local oStrG6R		:= FWFormStruct( 1, "G6R")
Local oStrGYN		:= FWFormStruct( 1, "GYN")
Local oStrG55		:= FWFormStruct( 1, "G55")
Local oStrG9C		:= FWFormStruct( 1, "G9C")
Local oStrGIN		:= FWFormStruct( 1, "GIN")


SetModelStruct(oStrG6R)

oModel := MPFormModel():New('GTPA600A',/*bPreValid*/,{|oModel| Ga600aPosVld(oModel)}/*bPosValid*/,/*bCommit*/ , /*bCancel*/)

oModel:AddFields("G6RMASTER",/*PAI*/		, oStrG6R)//,,,/*bLoadCab*/)
                                                      //
oModel:AddGrid("GYNDETAIL"	, "G6RMASTER"	, oStrGYN)//,,,,, /*(bLoadGrid1)*/)
oModel:AddGrid("G55DETAIL"	, "GYNDETAIL"	, oStrG55)//,,,,, /*(bLoadGrid1)*/)
oModel:AddGrid("G9CDETAIL"	, "G6RMASTER"	, oStrG9C)//,,,,, /*(bLoadGrid1)*/)
oModel:AddGrid("GINDETAIL"	, "G6RMASTER"	, oStrGIN)//,,,,, /*(bLoadGrid1)*/)



oModel:SetRelation('GYNDETAIL',{{'GYN_FILIAL','xFilial("GYN")'},{"GYN_TIPO","'2'"},{"GYN_FILPRO","G6R_FILIAL"},;
								{"GYN_OPORTU","G6R_NROPOR"},{"GYN_PROPOS","G6R_PROPOS"}},GYN->( IndexKey(1)))

oModel:SetRelation('G55DETAIL',{{ 'G55_FILIAL', 'xFilial("G55")'}, {'G55_CODVIA', 'GYN_CODIGO'}},G55->(IndexKey(2))) 
oModel:SetRelation("G9CDETAIL",{{ "G9C_FILIAL", "xFilial('G9C')"}, {"G9C_CODIGO", "G6R_CODIGO"}},G9C->(IndexKey(1)))
oModel:SetRelation("GINDETAIL",{{ "GIN_FILIAL", "xFilial('GIN')"}, {"GIN_PROPOS", "G6R_PROPOS"}},GIN->(IndexKey(1)))

oModel:SetOptional("GYNDETAIL", .T. )
oModel:SetOptional("G55DETAIL", .T. )

oModel:SetVldActivate({|oModel| SetVldActivate(oModel)})

//Definicao da Chave unica
oModel:SetPrimaryKey({})


Return oModel

/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 14/12/2018
@version 1.0
@param oStrG6R, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStrG6R)
Local bTrig		:= {|oMdl,cField,xVal|GTPA600TRG(oMdl,cField,xVal)}

If ValType( oStrG6R ) == "O"
	oStrG6R:AddTrigger("G6R_DTIDA"		,"G6R_DTIDA"			,{||.T.},bTrig)
	
	oStrG6R:AddField("Dias","Dias","DIFDIAS","N",3,0,Nil,Nil,Nil,.F.,NIL,.F.,.F.,.T.)

Endif

Return 

/*/{Protheus.doc} GTPA600TRG
Função de Gatilhos
@type function
@author jacomo.fernandes
@since 19/07/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@exampl
(examples)
@see (links_or_references)
/*/
Static Function GTPA600TRG(oMdl,cField,xVal)
Local oModel	:= oMdl:GetModel()
Local oMdlG6R	:= oModel:GetModel('G6RMASTER')

If cField == "G6R_DTIDA"
	If xVal > G6R->G6R_DTIDA
		oMdlG6R:SetValue('DIFDIAS',xVal-G6R->G6R_DTIDA )
	Else
		oMdlG6R:SetValue('DIFDIAS',(G6R->G6R_DTIDA-xVal)*-1 )
	Endif
	oMdlG6R:SetValue('G6R_DTVLTA',oMdlG6R:GetValue('G6R_DTVLTA')+oMdlG6R:GetValue('DIFDIAS'))
Endif

Return xVal
/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author jacomo.fernandes
@since 23/07/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView			:= nil
Local oModel		:= FwLoadModel('GTPA600A')
Local oStrG6R		:= FWFormStruct( 2, "G6R", {|cCampo| AllTrim(cCampo)+ "|" $ 'G6R_DTIDA|G6R_HRIDA|G6R_LOCORI|G6R_DESORI|G6R_ENDEMB|G6R_DTVLTA|'+;
																				'G6R_HRVLTA|G6R_LOCDES|G6R_DESDES|G6R_ENDDES|'})

SetViewStruct(oStrG6R)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddField("VIEW_G6R"	, oStrG6R, 'G6RMASTER')

oView:CreateHorizontalBox("VIEW_BOX_G6R",100)

oView:SetOwnerView("VIEW_G6R", "VIEW_BOX_G6R")

Return oView

/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 23/07/2018
@version 1.0
@param oStrG6R, objeto, (Descrição do parâmetro)
@param oStrG6R, objeto, (Descrição do parâmetro)
@param oStrGYN, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStrG6R)

If ValType( oStrG6R ) == "O"
	
	oStrG6R:SetProperty('*'			,MVC_VIEW_CANCHANGE,.F.)
	oStrG6R:SetProperty('G6R_DTIDA'	,MVC_VIEW_CANCHANGE,.T.)
	
	//-------------------------------------------------------------------
	oStrG6R:AddGroup('GRP001', 'Itinerário Ida'		,'', 2)
	
	oStrG6R:SetProperty( 'G6R_DTIDA'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrG6R:SetProperty( 'G6R_HRIDA'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrG6R:SetProperty( 'G6R_LOCORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrG6R:SetProperty( 'G6R_DESORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrG6R:SetProperty( 'G6R_ENDEMB'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	
	
	//-------------------------------------------------------------------
	oStrG6R:AddGroup('GRP002', 'Itinerário Volta'		,'', 2) 
	
	oStrG6R:SetProperty( 'G6R_DTVLTA'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrG6R:SetProperty( 'G6R_HRVLTA'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrG6R:SetProperty( 'G6R_LOCDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrG6R:SetProperty( 'G6R_DESDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrG6R:SetProperty( 'G6R_ENDDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	
Endif	

Return 

/*/{Protheus.doc} SetVldActivate
(long_description)
@type function
@author jacomo.fernandes
@since 24/07/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetVldActivate(oModel)
Local lRet	:= .T.

If __CUSERID != "000000"
	If G6R->G6R_STATUS <> '2'
		lRet := .F.
		oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","SetVldActivate","Essa funcionalidade só é realizada para orçamentos ganhos")
	Endif

	If lRet .and. !VldViagem(oModel)
		lRet := .F.
	Endif

	If lRet .and. !VldCTEOS(oModel)
		lRet := .F.
	Endif
EndIf
Return lRet


/*/{Protheus.doc} VldViagem
Função para verificar se a viagem ainda não foi confirmada ou se existe algum recurso alocado
@type function
@author jacomo.fernandes
@since 24/07/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldViagem(oModel)
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()


BeginSql Alias cAliasTmp
	
	SELECT 
		G6R_FILIAL,
		G6R_NROPOR,
		G6R_PROPOS,
		GYN_CODIGO,
		GYN_CANCEL,
		GYN_FINAL,
		GQE_SEQ,
		GQE_ITEM,
		GQE_TRECUR,
		GQE_RECURS,
		GQE_CONF,
		GQE_CANCEL
	FROM %TABLE:G6R% G6R
		INNER JOIN %TABLE:GYN% GYN ON
			GYN.GYN_FILIAL		= %XFILIAL:GYN%
			AND GYN.GYN_FILPRO	= G6R.G6R_FILIAL
			AND GYN.GYN_OPORTU	= G6R.G6R_NROPOR
			AND GYN.GYN_PROPOS	= G6R.G6R_PROPOS
			AND GYN.GYN_TIPO	= '2'
			AND GYN.%NOTDEL%
		LEFT JOIN %TABLE:GQE% GQE ON
			GQE.GQE_FILIAL = GYN.GYN_FILIAL
			AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
			AND GQE.%NOTDEL%
	WHERE
		G6R.G6R_FILIAL = %XFILIAL:G6R%
		AND G6R.G6R_CODIGO = %EXP:G6R->G6R_CODIGO%
		AND G6R.%NOTDEL%

EndSql

If (cAliasTmp)->(!Eof())
	While (cAliasTmp)->(!Eof())
		If (cAliasTmp)->GYN_FINAL == '1'
			lRet	:= .F.
			oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","VLDVIAGEM",I18n("Foi encontrado uma viagem Finalizada: #1 ",{(cAliasTmp)->GYN_CODIGO}),"Verificar a viagem antes de alterar a data da viagem")
			Exit
		ElseIf !Empty((cAliasTmp)->GQE_RECURS).and. (cAliasTmp)->GQE_CANCEL == '1' //não cancelado 
			lRet	:= .F.
			oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","VLDVIAGEM",I18n("Foi encontrado um recurso alocado na Viagem: #1 Seq: #2 Item: #3 Recurso: #4",{(cAliasTmp)->GYN_CODIGO,(cAliasTmp)->GQE_SEQ,(cAliasTmp)->GQE_ITEM,(cAliasTmp)->GQE_RECURS}),"Remover a alocação do recurso antes de alterar a data da viagem")
			Exit
		Endif
		(cAliasTmp)->(DbSkip())
	End
Else
	lRet	:= .F.
	oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","VLDVIAGEM","Não foi possivel encontrar nenhuma viagem conforme oportunidade selecionada","Selecione uma oportunidade valida ou verifique se a viagem foi criada")
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} VldCTEOS
Função criadapara validar se ja existe a CTEOS criada 
@type function
@author jacomo.fernandes
@since 24/07/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldCTEOS(oModel)
Local lRet		:= .T.
Local cAliasTmp	:= GetNextAlias()

BeginSql Alias cAliasTmp
	SELECT 
		GZH.* 
	FROM %TABLE:AD1% AD1
		INNER JOIN %TABLE:SCJ% SCJ ON
			SCJ.CJ_FILIAL = AD1.AD1_FILIAL
			AND SCJ.CJ_NROPOR = AD1.AD1_NROPOR
			AND SCJ.%NOTDEL%
		INNER JOIN %TABLE:SCK% SCK ON
			SCK.CK_FILIAL = SCJ.CJ_FILIAL
			AND SCK.CK_NUM = SCJ.CJ_NUM
			AND SCK.CK_PROPOST = SCJ.CJ_PROPOST
			AND SCK.%NOTDEL%
		INNER JOIN %TABLE:SC5% SC5 ON
			SC5.C5_FILIAL = SCK.CK_FILIAL
			AND SC5.C5_NUM = SCK.CK_NUMPV
			AND SC5.C5_ORIGEM IN('GTPA600', 'GTPA300')
			AND SC5.%NOTDEL%
		INNER JOIN %TABLE:GZH% GZH ON
			GZH.GZH_FILIAL = SC5.C5_FILIAL
			AND GZH.GZH_NOTA = SC5.C5_NOTA
			AND GZH.GZH_SERIE = SC5.C5_SERIE
			AND GZH.%NOTDEL%
			
	WHERE
		AD1.AD1_FILIAL = %XFILIAL:G6R%
		AND AD1.AD1_NROPOR = %EXP:G6R->G6R_NROPOR%
		AND AD1.AD1_REVISA = %EXP:G6R->G6R_OPOREV%
		AND AD1.AD1_PROPOS = %EXP:G6R->G6R_PROPOS%
		AND AD1.%NOTDEL%
EndSql

If (cAliasTmp)->(!Eof())
	lRet	:= .F.
	oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","VldCTEOS","Não é possivel alterar a data da viagem devido a existência do documento CTE-OS","Verifique o cadastro de CTE-OS")
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} Ga600aPosVld
(long_description)
@type function
@author jacomo.fernandes
@since 14/12/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga600aPosVld(oModel)
Local lRet		:= .T.
Local oMdlG6R	:= oModel:GetModel("G6RMASTER")
Local oMdlGYN	:= oModel:GetModel("GYNDETAIL")
Local oMdlG55	:= oModel:GetModel("G55DETAIL")
Local oMdlG9C	:= oModel:GetModel("G9CDETAIL")
Local oMdlGIN	:= oModel:GetModel("GINDETAIL")

Local nDiasDif	:= oMdlG6R:GetValue('DIFDIAS') 

Local n1,n2


For n1 := 1 To oMdlGYN:Length()
	oMdlGYN:GoLine(n1)
	oMdlGYN:LoadValue('GYN_DTINI',oMdlGYN:GetValue('GYN_DTINI')+nDiasDif )
	oMdlGYN:LoadValue('GYN_DTFIM',oMdlGYN:GetValue('GYN_DTFIM')+nDiasDif )
	For n2 := 1 to oMdlG55:Length()
		oMdlG55:GoLine(n2)
		oMdlG55:LoadValue('G55_DTPART',oMdlG55:GetValue('G55_DTPART')+nDiasDif )
		oMdlG55:LoadValue('G55_DTCHEG',oMdlG55:GetValue('G55_DTCHEG')+nDiasDif )
	Next

Next

For n1 := 1 To oMdlG9C:Length()
	oMdlG9C:GoLine(n1)
	oMdlG9C:LoadValue('G9C_DTORIG',oMdlG9C:GetValue('G9C_DTORIG')+nDiasDif )
	oMdlG9C:LoadValue('G9C_DTDEST',oMdlG9C:GetValue('G9C_DTDEST')+nDiasDif )
Next

For n1 := 1 To oMdlGIN:Length()
	oMdlGIN:GoLine(n1)
	oMdlGIN:LoadValue('GIN_DSAIDA',oMdlGIN:GetValue('GIN_DSAIDA')+nDiasDif )
	oMdlGIN:LoadValue('GIN_DCHEGA',oMdlGIN:GetValue('GIN_DCHEGA')+nDiasDif )
Next

Return lRet
