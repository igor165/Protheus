#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function GTPX300A(lAut)
Local cDescri	:= 'Alteração da Data da Viagem'
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., 'Confirmar' },{.T., 'Fechar'},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}	//"Confirmar"###"Fechar"

Default lAut := .F.

ADY->(DbSetOrder(1)) //ADY_FILIAL+ADY_PROPOS
//If ADY->(DbSeek(xFilial("ADY")+ AD1->AD1_NROPOR + AD1->AD1_REVISA + AD1->AD1_PROPOS))
If ADY->(DbSeek(xFilial("ADY")+ AD1->AD1_PROPOS))
	If !lAut
		FWExecView( cDescri , "VIEWDEF.GTPX300A", 4,  /*oDlgKco*/, {|| .T. } , /*bOk*/ , 50/*nPercReducao*/, aEnableButtons, /*bCancel*/, /*cOperatId*/ , /*cToolBar*/ , /*oModel*/ )
	EndIf
Else
	FwAlertHelp('Não foi encontrada nenhuma proposta para essa oportunidade ou oportunidade não está como ganha','Verifique se exista alguma proposta criada ou se a proposta já se encontra como ganha')
Endif

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
Local oStrADY		:= FWFormStruct( 1, "ADY")
Local oStrGIN		:= FWFormStruct( 1, "GIN")
Local oStrGYN		:= FWFormStruct( 1, "GYN")


SetModelStruct(oStrADY,oStrGIN,oStrGYN)

oModel := MPFormModel():New('GTPX300A',/*bPreValid*/, /*bPosValid*/,/*bCommit*/ , /*bCancel*/)

oModel:AddFields("ADYMASTER",/*PAI*/		, oStrADY)//,,,/*bLoadCab*/)
                                                      //
oModel:AddGrid("GINDETAIL"	, "ADYMASTER"	, oStrGIN)//,,,,, /*(bLoadGrid1)*/)
oModel:AddGrid("GYNDETAIL"	, "GINDETAIL"	, oStrGYN)//,,,,, /*(bLoadGrid1)*/)


oModel:SetRelation('GINDETAIL',{{'GIN_FILIAL','xFilial("GIN")'},{"GIN_PROPOS","ADY_PROPOS"}},GIN->( IndexKey(1)))
oModel:SetRelation('GYNDETAIL',{{'GYN_FILIAL','xFilial("GYN")'},{"GYN_PROPOS","ADY_OPORTU"},;
								{"GYN_LOCORI","GIN_LOCOR"},{"GYN_LOCDES","GIN_LOCDES"},;
								{"GYN_DTINI","GIN_DSAIDA"},{"GYN_HRINI","GIN_HSAIDA"},;
								{"GYN_DTFIM","GIN_DCHEGA"},{"GYN_HRFIM","GIN_HCHEGA"},;
								{"GYN_TIPO","'2'"}},GYN->( IndexKey(1)))


oModel:SetOptional("GYNDETAIL", .T. )
oModel:SetOptional("GINDETAIL", .T. )

oModel:GetModel("ADYMASTER"):SetOnlyView(.T.)
oModel:GetModel("ADYMASTER"):SetOnlyQuery(.T.)


oModel:SetVldActivate({|oModel| SetVldActivate(oModel)})

//Definicao da Chave unica
oModel:SetPrimaryKey({})


Return oModel

/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 23/07/2018
@version 1.0
@param oStrADY, objeto, (Descrição do parâmetro)
@param oStrGIN, objeto, (Descrição do parâmetro)
@param oStrGYN, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStrADY,oStrGIN,oStrGYN)

	/*If ValType( oStrADY ) == "O"
		
	Endif			
	
	If ValType( oStrGIN ) == "O"
		
	Endif	
	
	If ValType( oStrGYN ) == "O"
		
	Endif	*/
	
Return 

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
Local oModel		:= FwLoadModel('GTPX300A')
Local oStrADY		:= FWFormStruct( 2, "ADY")
Local oStrGIN		:= FWFormStruct( 2, "GIN")
Local oStrGYN		:= FWFormStruct( 2, "GYN")


SetViewStruct(oStrADY,oStrGIN,oStrGYN)

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

oView:AddGrid("VIEW_GIN"	, oStrGIN, 'GINDETAIL')

oView:CreateHorizontalBox("GRIDGIN",100)

oView:SetOwnerView("VIEW_GIN", "GRIDGIN")

oView:EnableTitleView("GINDETAIL")

Return oView

/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 23/07/2018
@version 1.0
@param oStrADY, objeto, (Descrição do parâmetro)
@param oStrGIN, objeto, (Descrição do parâmetro)
@param oStrGYN, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStrADY,oStrGIN,oStrGYN)

	If ValType( oStrGIN ) == "O"
		//oStrGIN:SetProperty('GIN_ITEM'		,MVC_VIEW_ORDEM,'01')
		oStrGIN:SetProperty('GIN_LOCOR'		,MVC_VIEW_ORDEM,'02')
		oStrGIN:SetProperty('GIN_DESLO'		,MVC_VIEW_ORDEM,'03')
		oStrGIN:SetProperty('GIN_DSAIDA'	,MVC_VIEW_ORDEM,'04')
		oStrGIN:SetProperty('GIN_HSAIDA'	,MVC_VIEW_ORDEM,'05')
		oStrGIN:SetProperty('GIN_LOCDES'	,MVC_VIEW_ORDEM,'06')
		oStrGIN:SetProperty('GIN_DESLD'		,MVC_VIEW_ORDEM,'07')
		oStrGIN:SetProperty('GIN_DCHEGA'	,MVC_VIEW_ORDEM,'08')
		oStrGIN:SetProperty('GIN_HCHEGA'	,MVC_VIEW_ORDEM,'09')
		
		oStrGIN:SetProperty('GIN_LOCOR'		,MVC_VIEW_CANCHANGE,.F.)
		oStrGIN:SetProperty('GIN_LOCDES'	,MVC_VIEW_CANCHANGE,.F.)
		oStrGIN:SetProperty('GIN_HSAIDA'	,MVC_VIEW_CANCHANGE,.F.)
		oStrGIN:SetProperty('GIN_HCHEGA'	,MVC_VIEW_CANCHANGE,.F.)
	
		oStrGIN:RemoveField('GIN_ENDEM')
		oStrGIN:RemoveField('GIN_ENDDE')
		oStrGIN:RemoveField('GIN_HORAS')
		oStrGIN:RemoveField('GIN_PEDIDA')
		oStrGIN:RemoveField('GIN_PEDVOL')
		oStrGIN:RemoveField('GIN_QTDHRS')
		oStrGIN:RemoveField('GIN_DIARIA')
		
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

If lRet .and. !VldViagem(oModel)
	lRet := .F.
Endif

If lRet .and. !VldCTEOS(oModel)
	lRet := .F.
Endif

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
		ADY_FILIAL,
		ADY_OPORTU,
		ADY_PROPOS,
		GIN_ITEM,
		GYN_CODIGO,
		GYN_CANCEL,
		GYN_FINAL,
		GQE_SEQ,
		GQE_ITEM,
		GQE_TRECUR,
		GQE_RECURS,
		GQE_CONF,
		GQE_CANCEL
	FROM %TABLE:ADY% ADY
	
		INNER JOIN %TABLE:GIN% GIN ON
			GIN.GIN_FILIAL		= ADY.ADY_FILIAL
			AND GIN.GIN_PROPOS	= ADY.ADY_PROPOS
			AND GIN.%NOTDEL%
			
		INNER JOIN %TABLE:GYN% GYN ON
			GYN.GYN_FILIAL		= %XFILIAL:GYN%
			AND GYN.GYN_PROPOS	= ADY.ADY_OPORTU
			AND GYN.GYN_LOCORI	= GIN.GIN_LOCOR
			AND GYN.GYN_LOCDES	= GIN.GIN_LOCDES
			AND GYN.GYN_DTINI	= GIN_DSAIDA
			AND GYN_HRINI		= GIN_HSAIDA
			AND GYN_DTFIM		= GIN_DCHEGA
			AND GYN_HRFIM		= GIN_HCHEGA
			AND GYN.GYN_TIPO	= '2'
			AND GYN.%NOTDEL%
		LEFT JOIN %TABLE:GQE% GQE ON
			GQE.GQE_FILIAL = GYN.GYN_FILIAL
			AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
			AND GQE.%NOTDEL%
	WHERE
		ADY.ADY_FILIAL = %XFILIAL:ADY%
		AND ADY.ADY_OPORTU = %EXP:AD1->AD1_NROPOR%
		//AND ADY.ADY_REVISA = %EXP:AD1->AD1_REVISA%
		AND ADY.ADY_PROPOS = %EXP:AD1->AD1_PROPOS%
		AND ADY.%NOTDEL%

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
	If oModel != nil
		oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","VLDVIAGEM","Não foi possivel encontrar nenhuma viagem conforme oportunidade selecionada","Selecione uma oportunidade valida ou verifique se a viagem foi criada")
	EndIf
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
		AD1.AD1_FILIAL = %XFILIAL:ADY%
		AND AD1.AD1_NROPOR = %EXP:AD1->AD1_NROPOR%
		AND AD1.AD1_REVISA = %EXP:AD1->AD1_REVISA%
		AND AD1.AD1_PROPOS = %EXP:AD1->AD1_PROPOS%
		AND AD1.%NOTDEL%
EndSql

If (cAliasTmp)->(!Eof())
	lRet	:= .F.
	oModel:SetErrorMessage(oModel:GetID(),"",oModel:GetID(),"","VldCTEOS","Não é possivel alterar a data da viagem devido a existência do documento CTE-OS","Verifique o cadastro de CTE-OS")
Endif

(cAliasTmp)->(DbCloseArea())

Return lRet


