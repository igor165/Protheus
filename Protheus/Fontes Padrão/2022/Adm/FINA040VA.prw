#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE "fina040VA.ch"

Static __lFAPodeTVA	:= ExistFunc("FAPodeTVA")
Static __lFWHasEAI  := FWHasEAI("FINA040", .T.,, .T.)

/*/{Protheus.doc}FINA040
Valores Acessórios.
@author Simone Mie Sato Kakinoana
@since  26/07/2016
@version 12
/*/
Function FINA040VA()
	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	Local cProdRM := GETNEWPAR( "MV_RMORIG", "" )
	Local lRet := .T.

	If SE1->E1_SALDO > 0
		//Bloqueio por situação de cobrança
		//Se veio através da integracao Protheus X Classis, não pode ser alterado
		If !F023VerBlq("1","0001",SE1->E1_SITUACA,.T.) .or. Upper( AllTrim( SE1->E1_ORIGEM ) ) $ cProdRM 
			lRet := .F.
		Endif
	Endif

	If SE1->E1_SALDO <= 0 .OR. (SE1->E1_IDLAN == 1 .AND. Alltrim(SE1->E1_ORIGEM) $ Alltrim(GetNewPar("MV_RMORIG",""))) .Or. !lRet
			FWExecView( STR0003 + " - " + STR0007,"FINA040VA", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )			//"Valores Acessórios"###"Visualizar"
	Else
			FWExecView( STR0003 + " - " + STR0001,"FINA040VA", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,,aEnableButtons )		//"Valores Acessórios"###"Alteração"
	EndIf

	Return lRet

	/*/{Protheus.doc}ViewDef
	Interface.
	@author Simone Mie Sato Kakinoana
	@since  26/07/2016
	@version 12
	/*/
Static Function ViewDef()
	Local oView  := FWFormView():New()
	Local oModel := FWLoadModel('FINA040VA')
	Local oFK7	 := FWFormStruct(2,'FK7')
	Local oSE1	 := FWFormStruct(2,'SE1', { |x| ALLTRIM(x) $ 'E1_NUM, E1_PARCELA, E1_PREFIXO, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_SALDO, E1_VALOR, E1_NATUREZ' } )
	Local oFKD	 := FWFormStruct(2,'FKD', { |x| ALLTRIM(x) $ 'FKD_CODIGO, FKD_DESC, FKD_TPVAL,FKD_ACAO,FKD_VALOR' })

	oSE1:AddField("E1_DESCNAT", "10", STR0009, STR0009, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"

	oSE1:SetProperty( 'E1_NATUREZ'	, MVC_VIEW_ORDEM,	'11')
	oSE1:SetProperty( 'E1_DESCNAT'	, MVC_VIEW_ORDEM,	'12')

	oSE1:SetNoFolder()

	oFKD:SetProperty( 'FKD_TPVAL'	, MVC_VIEW_ORDEM,	'06')
	oFKD:SetProperty( 'FKD_VALOR'	, MVC_VIEW_ORDEM,	'07')
	oFKD:SetProperty( 'FKD_ACAO'	, MVC_VIEW_ORDEM,	'08')

	oView:SetModel( oModel )
	oView:AddField("VIEWSE1",oSE1,"SE1MASTER")
	oView:AddGrid("VIEWFKD" ,oFKD,"FKDDETAIL")
	//
	oView:SetViewProperty("VIEWSE1","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1})
	//
	oView:CreateHorizontalBox( 'BOXSE1', 027 )
	oView:CreateHorizontalBox( 'BOXFKD', 073 )
	//
	oView:SetOwnerView('VIEWSE1', 'BOXSE1')
	oView:SetOwnerView('VIEWFKD', 'BOXFKD')
	//
	oView:EnableTitleView('VIEWSE1' , STR0002 /*'Contas a Receber'*/ )
	oView:EnableTitleView('VIEWFKD' , STR0003/*'Valores Acessórios'*/ )
	//
	oView:SetViewCanActivate({|| F040VAView()})
	//
	oView:SetOnlyView('VIEWSE1')

	Return oView

	/*/{Protheus.doc}ModelDef
	Modelo de dados.
	@author Simone Mie Sato Kakinoana
	@since  26/07/2016
	@version 12
	/*/
Static Function ModelDef()
	Local oModel	:= MPFormModel():New('FINA040VA',/*Pre*/,/*Pos*/,{|oModel|F040VAGRV( oModel )}/*Commit*/)
	Local oSE1		:= FWFormStruct(1, 'SE1')
	Local oFKD		:= FWFormStruct(1, 'FKD')
	Local oFK7		:= FWFormStruct(1, 'FK7')
	Local bFKDLP	:= { |oModel, nLine, cAction| F040VALP( oModel, nLine, cAction ) }
	Local aAuxFK7	:= {}
	Local aAuxFKD	:= {}
	Local aTamAcao	:= TamSx3("FKC_ACAO")
	Local bInitDesc	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_DESC"),"")')
	Local bInitVal	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_TPVAL"),"")')
	Local bInitPer	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_PERIOD"),"")')
	Local bInitAcao	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'IIF(!INCLUI,Posicione("FKC",1, xFilial("FKC") + FKD->FKD_CODIGO,"FKC_ACAO"),"")')
	Local bInitID	:= FWBuildFeature( STRUCT_FEATURE_INIPAD, 'FWUUIDV4()')
	Local nTamDNat 	:= TamSx3("ED_DESCRIC")[1]

	oSE1:AddField(			  ;
		STR0009					, ;	// [01] Titulo do campo	//"Descrição da Natureza"
	STR0009					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"E1_DESCNAT"				, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat					, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
	, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "Posicione('SED',1,xFilial('SED')+SE1->E1_NATUREZ,'ED_DESCRIC')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oSE1:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

	oFKD:AddTrigger( "FKD_CODIGO", "FKD_TPVAL" , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_TPVAL")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_DESC"  , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_DESC")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_PERIOD", {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_PERIOD")})
	oFKD:AddTrigger( "FKD_CODIGO", "FKD_ACAO"  , {|| .T. },{|oModel| Posicione("FKC",1,xFilial("FKC")+oModel:GetValue("FKD_CODIGO"),"FKC_ACAO")})
	oFKD:AddTrigger( "FKD_VALOR" , "FKD_VLCALC", {|| .T. },{|oModel| oModel:GetValue("FKD_VALOR")})

	//oFKD:AddField("Ação View","Ação View", "FKC_ACAO", "C", aTamAcao[1], aTamAcao[2], {||.T.}, {||.F.}, {}, .F.)

	oFK7:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFKD:SetProperty('FKD_CODIGO'	, MODEL_FIELD_OBRIGAT, .T. )
	oFKD:SetProperty('FKD_DESC'		, MODEL_FIELD_INIT, bInitDesc )
	oFKD:SetProperty('FKD_PERIOD'	, MODEL_FIELD_INIT, bInitPer  )
	oFKD:SetProperty('FKD_TPVAL'	, MODEL_FIELD_INIT, bInitVal  )
	oFKD:SetProperty('FKD_ACAO'		, MODEL_FIELD_INIT, bInitAcao )
	If oFKD:HasField( 'FKD_IDFKD' )
		oFKD:SetProperty('FKD_IDFKD'	, MODEL_FIELD_INIT	, bInitID )
	EndIf
	//
	oModel:AddFields("SE1MASTER",/*cOwner*/	, oSE1)
	oModel:AddGrid("FK7DETAIL"  ,"SE1MASTER", oFK7)
	oModel:AddGrid("FKDDETAIL"  ,"SE1MASTER", oFKD, bFKDLP,{||F040ValCod(oModel)})
	//
	oModel:SetPrimaryKey({'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_CLIENTE','E1_LOJA'})
	//
	If !oModel:GetModel( 'FKDDETAIL' ):HasField( 'FKD_IDFKD' )
		oModel:GetModel( 'FKDDETAIL' ):SetUniqueLine( { 'FKD_CODIGO' } )
	EndIf

	aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
	aAdd( aAuxFK7, {"FK7_ALIAS","'SE1'"})
	aAdd( aAuxFK7, {"FK7_CHAVE","E1_FILIAL + '|' + E1_PREFIXO + '|' + E1_NUM + '|' + E1_PARCELA + '|' + E1_TIPO + '|' + E1_CLIENTE + '|' + E1_LOJA"})
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

	/*/{Protheus.doc}F040VAView
	Validação para ativar a view.
	@author Simone Mie Sato Kakinoana
	@since  26/07/2016
	@version 12
	Transformada em static para cobertura da automacao - Tiago Dantas da Cruz
	/*/
Static Function F040VAView()
	Local lRet := .T.

	If __lFAPodeTVA .And. !FAPodeTVA(SE1->E1_TIPO,SE1->E1_NATUREZ,.T.,"R")
		lRet := .F.
	Endif

	Return lRet

	/*/{Protheus.doc}F040VALP
	Pré-Validação para o sub modelo FKD.
	@param oModel - Sub modelo do FKD.
	@param nLine - Linha posicionada.
	@param cAction - DELETE|UNDELETE|INSERT|CANSETVALUE
	@author Simone Mie Sato Kakinoana
	@since  26/07/2016
	@version 12
	/*/
Function F040VALP( oModel, nLine, cAction )
	Local lRet	:= .T.

	If cAction == "DELETE"
		//Podem ser apagados se FKC_DTBAIX estiver vazio.
		If !Empty(oModel:GetValue("FKD_DTBAIX", nLine))
			lRet := .F.
			Help(,,"F040VADTBAIXA",,STR0005/*"Valores acessórios baixados não podem ser deletados."*/,1,0)
		EndIf
	EndIf

	//AJUSTADO PARA TRATAR CANSETVALUE E SETVALUE por que em execucao do Model nao passa por CANSETVALUE
	If cAction $ "CANSETVALUE"
		//Podem ser apagados se FKC_DTBAIX estiver vazio.
		If !Empty(oModel:GetValue("FKD_DTBAIX", nLine))
			lRet := .F.
			Help(,,"F040VAALT",,STR0006,1,0)	//"Valores acessórios baixados não podem ser alterados."
		EndIf
	EndIf

	Return lRet

	/*/{Protheus.doc}F040VAGRV
	Gravação do modelo de dados.
	@param oModel - Modelo FINA040VA.
	@author Simone Mie Sato Kakinoana
	@since  26/07/2015
	@version 12
	/*/
Function F040VAGRV( oModel )

	Local lRet    := .T.
	Local cChave  := ""
	Local cIdDoc  := ""
	Local aEaiRet := {}
	Local cLog    := ""

	cChave := xFilial("SE1", SE1->E1_FILORIG) + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + "|" + SE1->E1_CLIENTE + "|" + SE1->E1_LOJA
	cIdDoc := FINGRVFK7('SE1', cChave)
	oModel:LoadValue("FK7DETAIL", "FK7_IDDOC", cIdDoc)

	If oModel:VldData() 
		// Executa a integração de título a receber.
		If __lFWHasEAI
			aEaiRet := FwIntegDef('FINA040',,,, 'FINA040')
			If !aEaiRet[1]
				lRet := .F.
				Help(" ", 1, "HELP", STR0013, STR0014 + CRLF + aEAIRET[2], 3, 1)  // "Erro EAI" / "Problemas na integração EAI. Transação não executada."
				DisarmTransaction()
			EndIf
		Endif
		If lRet
			FWFormCommit(oModel)
		EndIf
	Else
		lRet := .F.
		cLog := cValToChar(oModel:GetErrorMessage()[4]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[5]) + ' - '
		cLog += cValToChar(oModel:GetErrorMessage()[6])
		Help( ,,"M040VLDPOS",,cLog, 1, 0 )
	Endif

Return lRet

	/*/{Protheus.doc}F040VACod
	Valida o codigo do VA digitado
	@param oModel - Modelo F040VACod
	@author Simone Mie Sato Kakinoana
	@since  26/07/2015
	@version 12
	/*/
Function F040ValCod(oModel)

	Local lRet			:= .T.
	Local nX			:= 0
	Local nAux			:= 0
	Local oSubFKD		:= oModel:GetModel( 'FKDDETAIL' )
	Local cCodVa		:= oModel:GetValue("FKDDETAIL","FKD_CODIGO")
	Local lVaSld 		:= oModel:HasField( 'FKDDETAIL','FKD_IDFKD' )

	FKC->(dbSetOrder(1))
	If FKC->(DbSeek(xFilial("FKC")+ cCodVa))
		If !(FKC->FKC_RECPAG $ ("2/3") )

			lRet	:= .F.
			Help(,,"F040VALCOD",,STR0008,1,0)//"Valor acessorio do tipo a pagar, só sao aceitos do tipo ambos ou a receber"

		EndIf
	Else
		lRet	:= .F.
		Help(,,"F040NOCOD",,STR0010,1,0)	//"Código de Valor Acessório Informado não cadastrado. Por favor, verifique."
	EndIf

	If lVaSld .AND. lRet
		For nX := 1 to oSubFKD:Length()
			oSubFKD:GoLine( nX )
			if !oSubFKD:IsDeleted() .And. oSubFKD:GetValue('FKD_CODIGO') $ cCodVa
				If oSubFKD:GetValue('FKD_TPVAL') == '2' .And. oSubFKD:GetValue('FKD_PERIOD')  == '1'
					If ABS(oSubFKD:GetValue('FKD_SALDO')) < oSubFKD:GetValue('FKD_VALOR')  //FKD_SALDO está armazenando o valor já baixado.
						nAux ++
					EndIf
				Else
					nAux ++
				EndIf
			EndIf
		Next

		If nAux > 1
			lRet := .F.
			Help(,,"F040VACOD",,STR0015,1,0)	//"Já existe um valor acessório com o mesmo código ativo."
		EndIf
	EndIf

	Return(lRet)

	/*/{Protheus.doc} FN040VAID
	Localiza os ID's dos Valores Acessório FKD
	@type  Function
	@author Renato.ito
	@since 07/06/2019
	@version 12
	@param	cIdDoc, Character, ID do título (FK7_IDDOC,FKD_IDDOC)
	cCodVa, Character, Código do VA
	lVASld, Logical, Retornar somente os Ids com saldo
	@return aRet, array,
	aRet [1] = Se o VA controla saldo
	aRet [2] = {Recno,FKD->FKD_IDFKD}
	aRet [3] = Valor total do VA
	/*/

Function FN040VAID(cIdDoc As Character, cCodVa As Character, lVASld As Logical ) As Array

	Local aRet		As Array
	Local aAux		As Array
	Local aArea		As Array
	Local aAreaFKD	As Array
	Local aAreaFKC	As Array
	Local lTpFixo	As Logical
	Local nTotVA	As Numeric

	Default lVASld := .F.

	aAux		:= {}
	aRet		:= {}
	aArea		:= GetArea()
	aAreaFKD	:= FKD->(GetArea())
	aAreaFKC	:= FKC->(GetArea())
	lTpFixo		:= .F.
	nTotVA		:= 0

	DbSelectArea( "FKC" )
	FKC->( DbSetOrder(1) ) //FKC_FILIAL+FKC_CODIGO
	If FKC->( MsSeek( xFilial( "FKC" ) + cCodVa ) )
		If FKC->FKC_TPVAL == '2' .And. FKC->FKC_PERIOD == '1' //Saldo só é controlado para FKC_TPVAL = 2 e FKC_PERIOD = 1
			lTpFixo := .T.
		EndIf
	EndIf

	DbSelectArea( "FKD" )
	FKD->( DbSetOrder(2) )  //FKD_FILIAL+FKD_IDDOC+FKD_CODIGO
	If FKD->( MsSeek( xFilial( "FKD" ) + cIdDoc + cCodVa ) )
		While FKD->( !Eof() ) .And. FKD->FKD_FILIAL == xFilial( "FKD" ) .And. FKD->FKD_IDDOC == cIdDoc .And. FKD->FKD_CODIGO == cCodVa
			nTotVA += FKD->FKD_VALOR
			If lVASld
				If FKC->FKC_ACAO == '1' // Soma
					If FKD->FKD_SALDO <> FKD->FKD_VALOR // FKD_SALDO está armazenando o valor já baixado.
						aAdd( aAux, { FKD->( RECNO() ), FKD->FKD_IDFKD })
					EndIf
				Else // Subtração o FKD_SALDO fica negativo
					If Abs(FKD->FKD_SALDO) <> FKD->FKD_VALOR // FKD_SALDO está armazenando o valor já baixado.
						aAdd( aAux, { FKD->( RECNO() ), FKD->FKD_IDFKD })
					EndIf
				EndIf			
			Else
				aAdd( aAux, { FKD->( RECNO() ), FKD->FKD_IDFKD })
			EndIf
			FKD->( DbSkip() )
		EndDo
	EndIf

	aRet := {lTpFixo,aAux,nTotVA}

	RestArea( aAreaFKD )
	RestArea( aAreaFKC )
	RestArea( aArea )

	Return aRet
