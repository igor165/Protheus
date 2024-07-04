#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE "fina050VA.ch"

Static __lFAPodeTVA	:= ExistFunc("FAPodeTVA")
Static __lFWHasEAI  := FWHasEAI("FINA050", .T.,, .T.)

/*/{Protheus.doc}FINA050VA
Valores Acessórios.
@author  Marcos Gomes
@since   26/04/2018
@version 12.1.22
/*/
Function FINA050VA()

	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	Local cProdRM := GETNEWPAR( "MV_RMORIG", "" )
	Local lRet := .T.

	//Se veio através da integracao Protheus X Classis, não pode ser alterado
	If Upper( AllTrim( SE2->E2_ORIGEM ) ) $ cProdRM
		FWExecView( STR0003 + " - " + STR0011,"FINA050VA", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )			//"Valores Acessórios"###"Visualizar"
		lRet := .F.
	Endif

	If lRet
		If SE2->E2_SALDO <= 0 .OR. (Alltrim(SE2->E2_ORIGEM) $ Alltrim(GetNewPar("MV_RMORIG","")))
			FWExecView( STR0003 + " - " + STR0011,"FINA050VA", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )			//"Valores Acessórios"###"Visualizar"
		Else
			FWExecView( STR0003 + " - " + STR0001,"FINA050VA", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons )		//"Valores Acessórios"###"Alteração"
		Endif
	EndIf

Return lRet

/*/{Protheus.doc}ViewDef
Interface.
@author  Marcos Gomes
@since   26/04/2018
@version 12.1.22
/*/
Static Function ViewDef()

Local oView  := FWFormView():New()
Local oModel := FWLoadModel('FINA050VA')
Local oFK7	 := FWFormStruct(2,'FK7')
Local oSE2	 := FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMCLI, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR, E2_NATUREZ' } )
Local oFKD	 := FWFormStruct(2,'FKD', { |x| ALLTRIM(x) $ 'FKD_CODIGO, FKD_DESC, FKD_TPVAL,FKD_ACAO,FKD_VALOR' })

	oSE2:AddField("E2_DESCNAT", "10", STR0012, STR0012, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"

	oSE2:SetProperty( 'E2_NATUREZ'	, MVC_VIEW_ORDEM,	'11')
	oSE2:SetProperty( 'E2_DESCNAT'	, MVC_VIEW_ORDEM,	'12')

	oSE2:SetNoFolder()

	oFKD:SetProperty( 'FKD_CODIGO'	, MVC_VIEW_LOOKUP,	'FKCP')
	oFKD:SetProperty( 'FKD_TPVAL'	, MVC_VIEW_ORDEM,	'06')
	oFKD:SetProperty( 'FKD_VALOR'	, MVC_VIEW_ORDEM,	'07')
	oFKD:SetProperty( 'FKD_ACAO'	, MVC_VIEW_ORDEM,	'08')

	oView:SetModel( oModel )
	oView:AddField("VIEWSE2",oSE2,"SE2MASTER")
	oView:AddGrid("VIEWFKD" ,oFKD,"FKDDETAIL")
	//
	oView:SetViewProperty("VIEWSE2","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})
	//
	oView:CreateHorizontalBox( 'BOXSE2', 027 )
	oView:CreateHorizontalBox( 'BOXFKD', 073 )
	//
	oView:SetOwnerView('VIEWSE2', 'BOXSE2')
	oView:SetOwnerView('VIEWFKD', 'BOXFKD')
	//
	oView:EnableTitleView('VIEWSE2' , STR0002 /*'Contas a Pagar'*/ )
	oView:EnableTitleView('VIEWFKD' , STR0003/*'Valores Acessórios'*/ )
	//
	oView:SetViewCanActivate({|| F050VAView()})
	//
	oView:SetOnlyView('VIEWSE2')

Return oView

/*/{Protheus.doc}ModelDef
Modelo de dados.
@author  Marcos Gomes
@since   26/04/2018
@version 12.1.22
/*/
Static Function ModelDef()

Local oModel	:= MPFormModel():New('FINA050VA',/*Pre*/,/*Pos*/,{|oModel| F050VAGRV( oModel )}/*Commit*/)
Local oSE2		:= FWFormStruct(1, 'SE2')
Local oFKD		:= FWFormStruct(1, 'FKD')
Local oFK7		:= FWFormStruct(1, 'FK7')
Local bFKDLP	:= { |oModel, nLine, cAction| F050VALP( oModel, nLine, cAction ) }
Local aAuxFK7	:= {}
Local aAuxFKD	:= {}
Local bInitDesc	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_DESC"),"")')
Local bInitVal	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_TPVAL"),"")')
Local bInitPer	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_PERIOD"),"")')
Local bInitAcao	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_ACAO"),"")')
Local nTamDNat 	:= TamSx3("ED_DESCRIC")[1]

	oSE2:AddField(			  ;
	STR0009					, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	STR0009					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"E2_DESCNAT"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SE2->E2_NATUREZ,'ED_DESCRIC')") ,,,;// [11] Inicializador Padrão do campo
	.T.)						// [14] Virtual


	oSE2:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

	oFKD:AddTrigger( "FKD_CODIGO", "FKD_TPVAL" , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_TPVAL")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_DESC"  , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_DESC")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_PERIOD", {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_PERIOD")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_ACAO"  , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_ACAO")})
	oFKD:AddTrigger( "FKD_VALOR" , "FKD_VLCALC", {|| .T. },{|oModel| oModel:GetValue("FKD_VALOR")})
	oFK7:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFKD:SetProperty('FKD_CODIGO'	, MODEL_FIELD_OBRIGAT, .T. )
	oFKD:SetProperty('FKD_DESC'		, MODEL_FIELD_INIT, bInitDesc )
	oFKD:SetProperty('FKD_PERIOD'	, MODEL_FIELD_INIT, bInitPer  )
	oFKD:SetProperty('FKD_TPVAL'	, MODEL_FIELD_INIT, bInitVal  )
	oFKD:SetProperty('FKD_ACAO'		, MODEL_FIELD_INIT, bInitAcao )

	//
	oModel:AddFields("SE2MASTER",/*cOwner*/	, oSE2)
	oModel:AddGrid("FK7DETAIL"  ,"SE2MASTER", oFK7)
	oModel:AddGrid("FKDDETAIL"  ,"SE2MASTER", oFKD, bFKDLP,{||F050ValCod(oModel )})
	//
	oModel:SetPrimaryKey({'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA'})
	//
	oModel:GetModel( 'FKDDETAIL' ):SetUniqueLine( { 'FKD_CODIGO' } )
	aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
	aAdd( aAuxFK7, {"FK7_ALIAS","'SE2'"})
	aAdd( aAuxFK7, {"FK7_CHAVE","E2_FILIAL + '|' + E2_PREFIXO + '|' + E2_NUM + '|' + E2_PARCELA + '|' + E2_TIPO + '|' + E2_FORNECE + '|' + E2_LOJA"})
	oModel:SetRelation("FK7DETAIL", aAuxFK7 , FK7->(IndexKey(2) ) )
	//
	aAdd(aAuxFKD, {"FKD_FILIAL", "xFilial('FKD')"})
	aAdd(aAuxFKD, {"FKD_IDDOC", "FK7_IDDOC"})
	oModel:SetRelation("FKDDETAIL", aAuxFKD , FKD->(IndexKey(1) ) )
	//
	oModel:GetModel( 'FKDDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK7DETAIL' ):SetOnlyQuery( .T. ) //Gravação é realizada pela função FINGRVFK7

Return oModel

/*/{Protheus.doc}F050VAView
Validação para ativar a view.
@author  Marcos Gomes
@since   26/04/2018
@version 12.1.22
/*/
Static Function F050VAView()
Local lRet := .T.

	If __lFAPodeTVA .And. !FAPodeTVA(SE2->E2_TIPO,SE2->E2_NATUREZ,.T.,"P")
		lRet := .F.
	Endif

Return lRet

/*/{Protheus.doc}F050VALP
Pré-Validação para o sub modelo FKD.
@param   oModel - Sub modelo do FKD.
@param   nLine - Linha posicionada.
@param   cAction - DELETE|UNDELETE|INSERT|CANSETVALUE
@author  Marcos Gomes
@since   26/04/2018
@version 12.1.22
/*/
Function F050VALP( oModel, nLine, cAction )
Local lRet	:= .T.

	If cAction == "DELETE"
		//Podem ser apagados se FKC_DTBAIX estiver vazio.
		If !Empty(oModel:GetValue("FKD_DTBAIX", nLine))
			lRet := .F.
			Help(,,"F050VADTBAIXA",,STR0007/*"Valores acessórios baixados não podem ser deletados."*/,1,0)
		EndIf
	EndIf

	//AJUSTADO PARA TRATAR CANSETVALUE E SETVALUE por que em execucao do Model nao passa por CANSETVALUE
	If cAction $ "CANSETVALUE"
		//Podem ser apagados se FKC_DTBAIX estiver vazio.
		If !Empty(oModel:GetValue("FKD_DTBAIX", nLine))
			lRet := .F.
			Help(,,"F050VAALT",,STR0008,1,0)	//"Valores acessórios baixados não podem ser alterados." /// ALTERAR PARA CONTAS A PAGAR
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc}F050VAGRV
Gravação do modelo de dados.
@param   oModel - Modelo FINA050VA.
@author  Marcos Gomes
@since   26/07/2015
@version 12
/*/
Function F050VAGRV( oModel )

Local lRet    := .F.
Local cChave  := ""
Local cIdDoc  := ""
Local aEaiRet := {}
Local cLog    := ""

cChave := xFilial("SE2", SE2->E2_FILORIG) + "|" + SE2->E2_PREFIXO + "|" + SE2->E2_NUM + "|" + SE2->E2_PARCELA + "|" + SE2->E2_TIPO + "|" + SE2->E2_FORNECE + "|" + SE2->E2_LOJA
cIdDoc := FINGRVFK7('SE2', cChave)
oModel:LoadValue("FK7DETAIL", "FK7_IDDOC", cIdDoc)

If oModel:VldData() .and. FWFormCommit(oModel)
	lRet := .T.

	// Executa a integração de título a pagar.
	If __lFWHasEAI
		aEaiRet := FwIntegDef('FINA050',,,, 'FINA050')
		If !aEaiRet[1]
			Help(" ", 1, "HELP", STR0013, STR0014 + CRLF + aEAIRET[2], 3, 1)  // "Erro EAI" / "Problemas na integração EAI. Transação não executada."
			DisarmTransaction()
		EndIf
	Endif
Else
	cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
	cLog += cValToChar(oModel:GetErrorMessage()[6])
	Help( ,,"M050VLDPOS",,cLog, 1, 0 )
Endif

Return lRet


/*/{Protheus.doc}F050ValCod
Valida o codigo do VA digitado
@param   oModel - Modelo F050VACod
@author  Marcos Gomes
@since   26/07/2015
@version 12
/*/
Function F050ValCod(oModel)

Local lRet			:= .T.

	FKC->(dbSetOrder(1))
	If FKC->(DbSeek(xFilial("FKC")+ oModel:GetValue("FKDDETAIL","FKD_CODIGO")))
		If !(FKC->FKC_RECPAG $ ("1/3") )
			lRet	:= .F.
			Help(,,"F050VALCOD",,STR0009,1,0)// ###STR009 "Este valor acessorio é da carteira a receber. Somente são aceitos valores acessórios da carteira Pagar ou Ambas"
		EndIf
	Else
		lRet	:= .F.
		Help(,,"F050NOCOD",,STR0010,1,0)	// ###STR010 "Código de Valor Acessório Informado não cadastrado. Por favor, verifique."
	EndIf

Return(lRet)
