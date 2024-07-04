#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA667.ch'

STATIC aUser 		:= {}
STATIC lUserIn 		:= nil		//Controle de solicitante que é participante da viagem
STATIC lUserSolVg 	:= nil		//Controle de solicitante que é participante da viagem
STATIC aPartic		:= {}
STATIC lAuto		:= .F.		//Controle de rotina automatica

//Static para contingência do uso da função MTFLUIGATV
Static __lMTFLUIGATV := FindFunction("MTFLUIGATV")

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA667A
Solicitação de adiantamento de viagem

@author pequim
@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function FINA667A()

Local aArea		As Array
Local lOutros	As Logical

lOutros := .F.

If FL5->FL5_STATUS == '2'	// Status 'Conferida'
	If !Empty(AllTrim(FL5->FL5_IDSOL))
		aArea := GetArea()

		dbSelectArea("FW3")
		FW3->(dbSetOrder(1))
		If FW3->(dbSeek(xFilial("FW3")+FL5->FL5_IDSOL)) .and. FindFunction("FW4IsType6")
			lOutros :=  FW4IsType6()
		EndIf
		
		RestArea(aArea)
	EndIf

	If lOutros	// Excecao para tipo de servico Outros
		FWExecView(STR0065, 'FINA667A', MODEL_OPERATION_UPDATE)
	Else
		Alert(STR0110)
	EndIf

ElseIf !FL5->FL5_STATUS $ '3|5'
	FWExecView(STR0065, 'FINA667A', MODEL_OPERATION_UPDATE) //'Solicitação de Adiantamentos'
Else
	Alert(STR0110) //"Não é possível solicitar adiantamento para viagem conferida, fechada ou Aguardando Aprovação."
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr4:= FWFormStruct(2, 'FL5')
Local oStr5:= FWFormStruct(2, 'FLC')
Local oStr6:= FWFormStruct(2, 'FLD')

oView := FWFormView():New()

oView:SetModel(oModel)

oView:CreateHorizontalBox( 'BOXFORM1', 20)
oView:CreateHorizontalBox( 'BOXFORM3', 40)
oView:CreateHorizontalBox( 'BOXFORM5', 40)


oView:AddField('FORM1' , oStr4,'FL5MASTER' )
oView:AddField('FORM5' , oStr6,'FLDDETAIL' ) 
oView:AddGrid ('FORM3' , oStr5,'FLCDETAIL' )  

oStr4:SetProperty('FL5_DESORI',MVC_VIEW_CANCHANGE,.F.)
oStr4:SetProperty('FL5_DESDES',MVC_VIEW_CANCHANGE,.F.)
oStr4:SetProperty('FL5_DTINI' ,MVC_VIEW_CANCHANGE,.F.)
oStr4:SetProperty('FL5_DTFIM' ,MVC_VIEW_CANCHANGE,.F.)
oStr4:SetProperty('FL5_NACION',MVC_VIEW_CANCHANGE,.F.)
oStr4:SetProperty('FL5_NOME'  ,MVC_VIEW_CANCHANGE,.F.)
oStr5:SetProperty('FLC_NOME'  ,MVC_VIEW_CANCHANGE,.F.)
oStr5:SetProperty('FLC_PARTIC',MVC_VIEW_CANCHANGE,.F.)

oStr5:AddField( 'OK','01',' ','Ok',, 'Check',,,,.T. )

oStr4:RemoveField( 'FL5_CODDES' )
oStr4:RemoveField( 'FL5_CODORI' )
oStr4:RemoveField( 'FL5_ADIANT' )
oStr4:RemoveField( 'FL5_CC'     )
oStr4:RemoveField( 'FL5_LOJA'   )
oStr4:RemoveField( 'FL5_CLIENT' )
oStr4:RemoveField( 'FL5_OBS'    )
oStr4:RemoveField( 'FL5_STATUS' )
oStr4:RemoveField( 'FL5_LICRES' )
oStr4:RemoveField( 'FL5_IDRESE' )

oStr5:RemoveField( 'FLC_VIAGEM' )
oStr5:RemoveField( 'FLC_BILHET' )
oStr5:RemoveField( 'FLC_IDRESE' )
oStr5:RemoveField( 'FLC_ITEM'   )

oStr6:RemoveField( 'FLD_PARCEL' )
oStr6:RemoveField( 'FLD_TITULO' )
oStr6:RemoveField( 'FLD_TIPO'   )
oStr6:RemoveField( 'FLD_PREFIX' )
oStr6:RemoveField( 'FLD_FORNEC' )
oStr6:RemoveField( 'FLD_LOJA'   )
oStr6:RemoveField( 'FLD_DTPAGT' )
oStr6:RemoveField( 'FLD_NOMEPA' )
oStr6:RemoveField( 'FLD_PARTIC' )
oStr6:RemoveField( 'FLD_ITEM'   )
oStr6:RemoveField( 'FLD_VIAGEM' )
oStr6:RemoveField( 'FLD_ADIANT' )
oStr6:RemoveField( 'FLD_VALAPR' )
oStr6:RemoveField( 'FLD_APROV'  )
oStr6:RemoveField( 'FLD_DTAPRO' )
oStr6:RemoveField( 'FLD_OBSAPR' )
oStr6:RemoveField( 'FLD_NOMEAP' )
oStr6:RemoveField( 'FLD_STATUS' )

oStr6:SetProperty('FLD_VALOR' ,MVC_VIEW_ORDEM,'01')
oStr6:SetProperty('FLD_MOEDA' ,MVC_VIEW_ORDEM,'02')
oStr6:SetProperty('FLD_TAXA'  ,MVC_VIEW_ORDEM,'03')
oStr6:SetProperty('FLD_DTSOLI',MVC_VIEW_ORDEM,'04')
oStr6:SetProperty('FLD_DTPREV',MVC_VIEW_ORDEM,'05')
oStr6:SetProperty('FLD_SOLIC' ,MVC_VIEW_ORDEM,'06')
oStr6:SetProperty('FLD_NOMESO',MVC_VIEW_ORDEM,'07')
oStr6:SetProperty('FLD_JUSTIF',MVC_VIEW_ORDEM,'08')

oView:SetOwnerView('FORM1','BOXFORM1')
oView:SetOwnerView('FORM3','BOXFORM3')
oView:SetOwnerView('FORM5','BOXFORM5')

oView:EnableTitleView('FORM5' , STR0001 ) 		//'Adiantamento de Viagem'
oView:EnableTitleView('FORM3' , STR0086 ) 		//'Participantes'
oView:EnableTitleView('FORM1' , STR0087 ) 		//'Viagem'

oView:SetCloseOnOk({||.T.})

oModel:SetVldActivate( {|oModel| F667AVLMod(oModel) } )
oModel:SetActivate( {|oModel| F667ALoadMod(oModel) } )

Return oView
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
 
Local oStr1:= FWFormStruct(1,'FL5')
Local oStr2:= FWFormStruct(1,'FLC')
Local oStr4:= FWFormStruct(1,'FLD')

oModel := MPFormModel():New('FINA667A', /*bPreValidacao*/, { |oModel| F667APOSVL(oModel) },  { |oModel| F667AGRVMD( oModel ) }, /*bCancel*/ )
oModel:SetDescription(STR0065)		//'Solicitação de Adiantamentos'

oModel:addFields('FL5MASTER',,oStr1)
oModel:addGrid('FLCDETAIL','FL5MASTER',oStr2)
oModel:Addfields('FLDDETAIL','FL5MASTER',oStr4)

oStr2:AddField(' ','Seleção' , 'OK', 'L',1,,FWBuildFeature(STRUCT_FEATURE_VALID  ,"F667VldOk()"),,,,{||.F.} )

oStr4:SetProperty( 'FLD_TAXA', MODEL_FIELD_WHEN, {|oModel| !(oModel:GetValue('FLD_MOEDA') $ ' |1')})

oModel:GetModel( 'FLCDETAIL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'FLCDETAIL' ):SetNoDeleteLine( .T. )

oModel:SetRelation('FLCDETAIL', { { 'FLC_FILIAL', 'xFilial("FLC")' }, { 'FLC_VIAGEM', 'FL5_VIAGEM' } }, FLC->(IndexKey(1)) )

dbSelectArea( "FLD" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} F667VldOk
Validacao do campo OK (FLC)

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F667VldOk()

Local lRet		:= .T.
Local oModelAtv := FWModelActive()
Local aArea		:= GetArea()
Local cViagem	:= oModelAtv:GetValue("FL5MASTER","FL5_VIAGEM") 
Local lOk		:= oModelAtv:GetValue("FLCDETAIL","OK")
Local cPartic	:= oModelAtv:GetValue("FLCDETAIL","FLC_PARTIC")
Local cSolic	:= oModelAtv:GetValue("FLDDETAIL","FLD_SOLIC")


If lOk

	//Usuário com pendência quanto a 
	// - Prestação de contas em atraso
	// - Excesso de prestação de contas
	lRet := FinXValPC(cPartic,.T.,,,cViagem)
	
	If lRet 
		//Verifica se o solicitante do adiantamento é solicitante de algum item da viagem
		If lUserSolVg == NIL 
			dbSelectArea("FL6")
			dbSetOrder(2)	//FL6_FILIAL + FL6_VIAGEM + FL6_PARTIC
			If MsSeek(xFilial("FL6")+cViagem+cPartic) 
				lUserSolVg := .T.
			Else
				lUserSolVg := .F.
			EndIf
		EndIf
	
		//Verifico se o solicitante é também participante da viagem	
		//Apenas se ele não for solicitante de um dos itens da viagem pois neste caso ele tem direito a selecionar qualquer participante 
		IF !lUserSolvg
			If lUserIn == NIL 
				dbSelectArea("FLC")
				dbSetOrder(1)	//FLC_FILIAL + FLC_VIAGEM + FLC_PARTIC
				If MsSeek(xFilial("FLC")+cViagem+cSolic)
					lUserIn := .T.
				Else
					lUserIn := .F.
				Endif
			Endif
			
			//Se o solicitante for participante da viagem, so pode marcar a ele mesmo
			If lUserIn .and. cPartic != cSolic
				Help("  ",1,"SOLISPAR",,STR0066,1,0)	//"O solicitante, por ser participante da viagem, somente poderá solicitar adiantamento para si mesmo"
				lRet := .F.
			Endif	
		Else
			lUserIn := .F.		//Permite que selecione qualquer participante para a solicitacao de adiantamento
		Endif
	Endif

	If lRet
		//Verifica se o participante está bloqueado para receber adiantamento de viagem
		dbSelectArea("FLF")
		dbSetOrder(2)	//FLF_FILIAL+FLF_VIAGEM+FLF_PARTIC
		If MsSeek(xFilial("FLF")+ cViagem + cPartic) .and. FLF->FLF_STATUS != "1"
			Help("  ",1,"PARTICPCI",,STR0067,1,0)		//"O participante possui prestação de contas iniciada, estando bloqueado para receber adiantamentos."
			lRet := .F.
		Endif				
	Endif

	If lRet
		//Verifica se o participante está bloqueado para receber adiantamento de viagem
		dbSelectArea("RD0")
		dbSetOrder(1)	//RD0_FILIAL+RD0_CODIGO
		If MsSeek(xFilial("RD0")+cPartic) 
			If RD0->RD0_PERMAD != "1"
				Help("  ",1,"PARTICBLQ",,STR0068,1,0)		//"O solicitante se encontra bloqueado para receber adiantamentos."
				lRet := .F.
			ElseIf Empty(RD0->RD0_APROPC) .AND. Empty(RD0->RD0_APSUBS) 
				lRet := .F. //Participante não tem aprovador cadastrado. 
				Help(" ",1,"FINA667APR",,STR0073,1,0) //"Participante não possui aprovador cadastrado. Verifique o cadastro do participante."
			EndIf
		Endif				
	Endif
Endif	

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667AVLMod
Inicializador do Model

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function  F667AVLMod(oModel)

Local lRet		:= .T.
Local cRespera	:=  SuperGetMv("MV_RESPERA",.T.,"0")    

If Empty(aUser)
	lRet := FINXUser(__cUserId,aUser,.T.)
EndIf

//Status da viagem não permite adiantamentos
If lRet .and. FL5->FL5_STATUS $ "E|K"
	Help("  ",1,"VIAGEMBLQ1",,STR0069,1,0)	//"Esta viagem encontra-se Finalizada ou Cancelada, não podendo receber solicitação de adiantamentos"
	lRet := .F.
EndIf

//Permissao de adiantamento de viagem (MV_RESPERA)
If lRet .and. cRespera != "1"  //1 = Todas, 2 = Nacional, 3 = Internacional
	If (FL5->FL5_NACION == "1" .and. cRespera != "2") .or. (FL5->FL5_NACION == "2" .and. cRespera != "3")  
		Help("  ",1,"VIAGEMBLQ2",,STR0070,1,0)	//"Esta viagem, de acordo com a parametrização, não permite adiantamentos de viagem."
		lRet := .F.
	EndIf
EndIf

//Verifica se o solicitante do adiantamento é solicitante de algum item da viagem
If lRet .and. lUserSolVg == NIL 
	dbSelectArea("FL6")
	dbSetOrder(2)	//FL6_FILIAL + FL6_VIAGEM + FL6_PARTIC
	If MsSeek(xFilial("FL6")+FL5->FL5_STATUS+aUser[1]) 
		lUserSolVg := .T.
	Else
		lUserSolVg := .F.
	EndIf
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667ALoadMod
Inicializador de valores da View

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F667ALoadMod(oModel)

Local nTamSol 	:= TamSx3("FLD_NOMESO")[1]
Local lRet		:= .T.
Local nDiasPrev := SuperGetMv("MV_RESADDU",.T.,0)  

Local dDataPrev	:= dDataBase
local nUtiOco		:= SuperGetMV('MV_RESUTCO',.F.,1)//"1" = útil
local nAdUrg		:= SuperGetMV('MV_RESPURG',.F.,3)
local nBaCalc		:= SuperGetMV('MV_RESCALC',.F.,1)//"1" = pedido
Local nX 			:= 0
Local dDataIni	:= Date()
Local dDataAux	:= Date()

If nBaCalc == 1
	dDataIni := dDatabase
Else
	dDataIni := FL5->FL5_DTINI
Endif
 
If dDataIni <= dDataBase .And. nBaCalc == 1 //Por pedido soma na data inicio
	dDataIni := dDataBase
EndIf

//Processo para permitir informar a quantidade mínima de dias para o vencimento dos adiantamentos de viagens
dDataPrev := dDataAux := dDataIni

//Cálculo
If nUtiOco == 1 //Util
	For nX = 1 to nDiasPrev
		If nBaCalc == 1  //Pedido
			dDataAux := (dDataPrev + 1)
			dDataPrev	:= DataValida(dDataAux)
		Else //Inicio da Viagem
			dDataAux := (dDataPrev - 1) 
			dDataPrev	:= DataValida(dDataAux,.F.)
		EndIf	
	Next nX
Else //Corrido
	If nBaCalc == 1  //Pedido
		dDataPrev := DataValida(dDataIni + nDiasPrev)
	Else //Inicio da Viagem
		dDataPrev := DataValida(dDataIni - nDiasPrev,.F.)
	EndIf
EndIf

//Verificar se o add é maior que a data base - add urgente
If dDataPrev <= dDatabase
	If nUtiOco == 1 //Util
		dDataPrev := dDatabase
		For nX = 1 to nAdUrg
			dDataAux := (dDataPrev + 1)
			dDataPrev	:= DataValida(dDataAux)	
		Next nX
	Else //Corrido
		dDataPrev := DataValida(dDataBase + nAdUrg)
	EndIf	
EndIf

If !Empty(aUser)
	oModel:LoadValue("FLDDETAIL","FLD_VALOR"  , 0 )	
	oModel:LoadValue("FLDDETAIL","FLD_MOEDA"  , "1")
	oModel:LoadValue("FLDDETAIL","FLD_DTSOLI" , dDatabase )	
	oModel:LoadValue("FLDDETAIL","FLD_DTPREV" , dDataPrev )	
	oModel:LoadValue("FLDDETAIL","FLD_SOLIC"  , aUser[1])
	oModel:LoadValue("FLDDETAIL","FLD_NOMESO" , PadR(aUser[2],nTamSol))
	oModel:LoadValue("FLDDETAIL","FLD_JUSTIF"  , "")
	oModel:LoadValue("FLDDETAIL","FLD_TAXA"   , 0 )
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} F667APOSVL
Validação final do model

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------

Function F667APOSVL(oModel)
Local lRet			:= .T.
Local oModelFLC		:= oModel:GetModel("FLCDETAIL")
Local cNacional		:= oModel:GetValue("FL5MASTER","FL5_NACION") 
Local cMoeda		:= oModel:GetValue("FLDDETAIL","FLD_MOEDA")
Local nValor		:= oModel:GetValue("FLDDETAIL","FLD_VALOR")
Local nTaxaMoeda	:= oModel:GetValue("FLDDETAIL","FLD_TAXA")
Local nAdiTxMe		:= SuperGetMV("MV_ADITXME",.T.,1)
Local aAprv 		:= FResAprov("1")  //"1" = Adiantamentos

If cNacional == "1" .and. cMoeda != "1"
	Help("  ",1,"MOEDANAC",,STR0071,1,0)	//"Por ser uma viagem nacional, a moeda deve ser a moeda corrente do país"
	lRet := .F.
Endif

If !lAuto
	If lRet .and. cNacional == "2" .and. Empty(cMoeda)
		Help("  ",1,"MOEDA_ADT",,STR0100,1,0)		//"O campo Moeda não foi preenchido."
		lRet := .F.
	Endif
	If lRet .and. nValor <= 0
		Help("  ",1,"VALOR_ADT",,STR0101,1,0)		//"O campo Valor não foi preenchido."
		lRet := .F.
	Endif
Endif

aPartic := F667AGetFLC(oModelFLC)

If Empty(aPartic)
	Help("  ",1,"NOSELPARTIC",,STR0072,1,0)		//"É necessário selecionar ao menos um participante para a solicitação de adiantmamento."
	lRet := .F.
Endif

If lRet	
	If nAdiTxMe == 1 .and. cMoeda != '1'.and. nTaxaMoeda == 0
		If  !aAprv[3] .AND. !aAprv[1]
			If FResAprov("4")[1] 
				Help("  ",1,"NO_COTACAO",,STR0126,1,0)		//"Para efetivação da liberação é necessário informar a cotação da moeda para este adiantamento."
				lRet := .F.
			Else
				lRet := .F.
			Endif
		Endif
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F667AGRVMD
Gravação do adiantamento (FLD) para cada participante selecionado 

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function F667AGRVMD( oModel )

Local oModelFLC		:= oModel:GetModel("FLCDETAIL")
Local nX			:= 0
Local aDados		:= {}
Local aAux			:= {}
Local nPosViagem	:= 0
Local nPosPartic	:= 0
Local nPosNome		:= 0
Local cItem			:= ""
Local cAdiant		:= ""
Local cSolic		:= oModel:GetValue("FLDDETAIL","FLD_SOLIC") 
Local dDataPrv		:= oModel:GetValue("FLDDETAIL","FLD_DTPREV")
Local nValor		:= oModel:GetValue("FLDDETAIL","FLD_VALOR")
Local cMoeda		:= oModel:GetValue("FLDDETAIL","FLD_MOEDA")
Local cJustif		:= oModel:GetValue("FLDDETAIL","FLD_JUSTIF")
Local nTaxaMoeda	:= oModel:GetValue("FLDDETAIL","FLD_TAXA")
Local cViagem		:= ""
Local cPartic		:= ""
Local cNomePart		:= ""
Local lAprov		:= .F.
Local lAproViagem	:= GetMV("MV_RESAPRT") == '1'
Local aAprv 		:= FResAprov("1")//"1" = Adiantamentos
Local lPEApr		:= ExistBlock("F667STRAPR") 
/*
	PCREQ-3829 Aprovação Automática
	
	aAprv[1] - Aprovação de Solicitação (.T. or .F.)
	aAprv[2] - Avaliação do Gestor (.T. or .F.)
	aAprv[3] - Lib. do Pagamento (.T. or .F.)
*/
Local cUser		:= ""
Local aUsers		:= {}
Local cProcWF		:= "SOLADIANTA"

dbSelectArea('FLJ') //Tabela de Aprovadores.
dbSelectArea('RD0') //Tabela de Participantes.

aDados := aClone(aPartic[1,1])

nPosViagem	:= aScan( aDados, { |x| AllTrim( x[1] ) ==  "FLC_VIAGEM" } )
nPosPartic	:= aScan( aDados, { |x| AllTrim( x[1] ) ==  "FLC_PARTIC" } )
nPosNome	:= aScan( aDados, { |x| AllTrim( x[1] ) ==  "FLC_NOME"   } )

For nX := 1 to Len(aPartic)

	aAux := aClone(aPartic[nX,1])

	//acho a sequencia da viagem do participante 
	dbSelectArea("FLU")
	dbSetOrder(2)		//FLU_FILIAL+FLU_VIAGEM+FLU_PARTIC
	If MsSeek(xfilial("FLU")+ aAux[nPosViagem,2] +aAux[nPosPartic,2])
		cItem := FLU->FLU_ITEM
	Else
		cItem := '01'	
	Endif

	cViagem 	:= aAux[nPosViagem][2]
	cPartic 	:= aAux[nPosPartic][2]
	cNomePart	:= aAux[nPosNome][2]
	cAdiant		:= FINA667NEW(cViagem, cPartic)
	
	Reclock("FLD",.T.)
	FLD->FLD_FILIAL := xFilial("FLD")
	FLD->FLD_VIAGEM := cViagem 
	FLD->FLD_ITEM	:= cItem  
	FLD->FLD_PARTIC	:= cPartic
	FLD->FLD_ADIANT	:= cAdiant
	FLD->FLD_SOLIC	:= cSolic 
	FLD->FLD_DTSOLI := dDataBase
	FLD->FLD_DTPREV	:= dDataPrv
	FLD->FLD_VALOR	:= nValor
	FLD->FLD_MOEDA	:= cMoeda
	FLD->FLD_TAXA	:= nTaxaMoeda
	
	If lAproViagem
		
		//Monta validação customizada para desligar a aprovação do próprio viajante
		If ExistBlock("F667APROP") 
			lAprov := ExecBlock("F667APROP",.F.,.F.)
		Else	
			//Busca aprovadores na FLJ
			FLJ->(dbSeek( xFilial('FLJ') +  cViagem + cItem))
			While FLJ->FLJ_FILIAL + FLJ->FLJ_VIAGEM + FLJ->FLJ_ITEM == xFilial('FLJ') +  cViagem + cItem .AND. !lAprov
				
				If cPartic == FLJ->FLJ_PARTIC
					lAprov := .T.
					FLD->FLD_STATUS := '2' //Aprovado.	
					FLD->FLD_APROV  := cPartic
					FLD->FLD_DTAPRO := dDataBase
					FLD->FLD_VALAPR := nValor
				EndIf
				FLJ->(dbSkip())
				
			EndDo
			If !lAprov
			
				//Busca na RD0 se o participante é aprovador dele mesmo.
				RD0->(dbSeek( xFilial('RD0') + cPartic))
				If cPartic == RD0->RD0_APROPC .OR. cPartic == RD0->RD0_APSUBS 
					lAprov := .T.
					FLD->FLD_STATUS := '2' //Aprovado.	
					FLD->FLD_APROV  := cPartic
					FLD->FLD_DTAPRO := dDataBase
					FLD->FLD_VALAPR := nValor
				EndIf
				
			EndIf
		EndIf	
	EndIf
	
	If !lAprov
		FLD->FLD_STATUS	:= '8' //Em avaliação pelo gestor
	Else
		FLD->FLD_STATUS := '2' //Aprovado.	
		FLD->FLD_APROV  := cPartic
		FLD->FLD_DTAPRO := dDataBase
		FLD->FLD_VALAPR := nValor
	EndIf
	
	//PE - Manipula os processos de aprovação para exceções
	If lPEApr
		
		//aAprv[1] - Aprovação de Solicitação (.T. or .F.)
		//aAprv[2] - Avaliação do Gestor (.T. or .F.)
		//aAprv[3] - Lib. do Pagamento (.T. or .F.)
		
		aAprv := ExecBlock("F667STRAPR",.F.,.F.,{aAprv})
	EndIf
	
	If FunName() == "FINA666"
		FLD->FLD_STATUS := '1' //Solicitado
		FLD->FLD_APROV  := cPartic
		FLD->FLD_DTAPRO := CToD("  /  /    ")
		FLD->FLD_VALAPR := 0
	Else
		//PCREQ-3829 Aprovação Automática
		If aAPrv[2]
			FLD->FLD_STATUS := '1' //Solicitado	
			FLD->FLD_APROV  := cPartic
			FLD->FLD_DTAPRO := CToD("  /  /    ")
			FLD->FLD_VALAPR := 0
		ElseIf !aAPrv[2] .AND. aAprv[3]
			FLD->FLD_STATUS := '2' //Aprovado
			FLD->FLD_APROV  := cPartic
			FLD->FLD_DTAPRO := dDataBase
			FLD->FLD_VALAPR := nValor
		ElseIf !aAPrv[2] .AND. !aAprv[3] .AND. (lAprov .OR. !aAprv[1])
			FLD->FLD_STATUS := '2' //Liberado
			FLD->FLD_APROV  := cPartic
			FLD->FLD_DTAPRO := dDataBase
			FLD->FLD_VALAPR := nValor
			If FResAprov("4")[1]
				FLD->(MsUnLock())
				MsgRun( STR0051,, {|| F667GeraLib(1,FLD->(RECNO()),.T.) } ) //"Processando liberação de pagamento..."
				RecLock("FLD",.F.)
			Else
				FLD->FLD_STATUS := '9' //Cancelado
			EndIf	
		EndIf
	EndIf
	
	FLD->FLD_JUSTIF	:= cJustif
	FLD->(MsUnLock())
	
	If aAprv[1]
		//Grava hierarquia de aprovadores
		//	cViagem = Codigo da viagem
		//	cPartic = Codigo do participante
		//	cAdiant = Codigo do Adiantamento
		//	cItem	= Item do adiantamento
	
		FINA667LIB(cViagem, cPartic, cAdiant, cItem)
		
		If FLD->FLD_STATUS == "8" //Avaliação do Gestor
			If __lMTFLUIGATV
				If MTFluigAtv("WFFINA667", cProcWF, "WFFIN667")
					
					FI667WF(cViagem, cPartic , cAdiant , cUser, aUsers)
									
				EndIf
			EndIf
		EndIf
	EndIf

Next 

//Limpa valores da memoria.
aSize(aPartic, 0)
aPartic := {} 

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F667AGetFLC
Obtem os participantes selecionados para receber o adiantamento

@author pequim

@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function F667AGetFLC(oModel)

Local aStrFLC := oModel:GetStruct():aFields
Local nX      := 0
Local nY      := 0
Local aAux    := {}
Local cAux    := ""
Local cCampoExc := 'FLC_FILIAL|FLC_ITEM|FLC_IDRESE|FNE_ETAPA|FLC_BILHET' 

For nX := 1 to oModel:Length()
	oModel:GoLine( nX )
	lOk := oModel:GetValue("OK")
	If lOk
	   aAux := {}
	   For nY := 1 to Len(aStrFLC)
			If !( Alltrim(aStrFLC[nY][3]) $ cCampoExc ) 
				cAux := oModel:GetValue(aStrFLC[nY][3])
				aAdd(aAux,{aStrFLC[nY][3],cAux})
			Endif
		Next nY

	   aAdd(aPartic, { aClone(aAux) } )
	Endif
Next nX

Return aPartic

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA667NEW
Obtem o próximo item para o participante de uma determinada viagem
@author pequim
@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------                                                                                                                            
Function FINA667NEW(cViagem, cPartic)

Local aArea		:= GetArea()
Local cNewItem	:= STRZERO(0,TamSx3("FLD_ADIANT")[1])

Default cViagem	:= ""
Default cPartic	:= ""

If !Empty(cViagem) .and. !Empty(cPartic)

	cQry := " SELECT " 
	cQry += " MAX(FLD_ADIANT) ADIANT " 
	cQry += " FROM "+RetSQlName("FLD")+ " FLD " 
	cQry += " WHERE FLD_FILIAL = '"+xFilial("FLD")+"'" 		
	cQry += " AND FLD_VIAGEM = '"+cViagem+"'"
	cQry += " AND FLD_PARTIC = '"+cPartic+"'"
	cQry += " AND FLD.D_E_L_E_T_ <> '*' "	
	
	cQry := ChangeQuery(cQry) 
	
	If Select("FLDADIANT") > 0
		FLDADIANT->(DbCloseArea())
	Endif
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry), "FLDADIANT", .T., .F.)	
	If Empty(FLDADIANT->ADIANT)
		cNewItem := Soma1(Alltrim(cNewItem))
	Else
		cNewItem := Soma1(Alltrim(FLDADIANT->ADIANT))
	EndIf
	FLDADIANT->(DbCloseArea())

EndIf            

RestArea(aArea)

Return cNewItem

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA667LIB
Grava a estrutura de aprovacao da solicitacao de adiantamento

@author pequim
@since 23/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------                                                                                                                            
                                                                                                                             
Function FINA667LIB(cViagem, cPartic, cAdiant, cPedido)

Local aArea		:= GetArea()
Local cAliasTrb	:= GetNextAlias()
Local lRet		:= .T.
Local cSeq		:= '0'
Local cAprov	:= ""
Local lAlc		:= ExistBlock("F667ALCAPR")

Default cViagem	:= ""
Default cAdiant	:= ""
Default cPartic	:= ""
Default cPedido	:= ""
	
If !Empty(cViagem) .And.  !Empty(cPartic) .And. !Empty(cAdiant) .And. !Empty(cPedido)

	DbSelectArea("FLM")
	FLM->(DbSetOrder(1))
	If FLM->(!DbSeek(xFilial("FLM")+cViagem+cPartic+cAdiant))
	
		DbSelectArea("FLJ")
		BeginSql Alias cAliasTrb
			SELECT FLJ_PARTIC, RD0_NOME, FLJ_SUBITM
			FROM %table:FLJ% FLJ
			INNER JOIN %table:RD0% RD0
			ON FLJ.FLJ_PARTIC = RD0.RD0_CODIGO
			AND  RD0.%notDel% 
		   WHERE FLJ_FILIAL = %xFilial:FLJ%
		   			AND FLJ_VIAGEM = %exp:cViagem%
		   			AND FLJ_ITEM =  %exp:cPedido%
		   			AND FLJ.%notDel%
		   	ORDER BY FLJ_SUBITM DESC
		EndSql
		
		If (cAliasTrb)->(!Eof())			
			cSeq := "1"
			While (cAliasTrb)->(!Eof()) 
				RecLock("FLM",.T.)
					FLM_FILIAL	:= xFilial("FLM")
					FLM_VIAGEM	:= cViagem
					FLM_PARTIC	:= cPartic
					FLM_ADIANT	:= cAdiant
					FLM_SEQ		:= cSeq
					FLM_TIPO	:= "1"
					If lAlc .And. !IsInCallStack("FINA661PRO")//Diferente de Migracao.
						cAprov := ExecBlock("F667ALCAPR",.F.,.F.,{cPartic,cViagem})
					EndIf
					If ValType(cAprov) == "C" .and. !Empty(cAprov)
						FLM_APROV	:= cAprov
					Else
						FLM_APROV	:= (cAliasTrb)->FLJ_PARTIC
					EndIf
					FLM_NOMEAP	:= (cAliasTrb)->RD0_NOME
					FLM_STATUS	:= IIf(cSeq == "1","1","0")
				FLM->(MsUnLock())
				
				If cSeq == "1"
					//Mandar email para o proximo aprovador (Gestor)
					F667MsgMail(1,,,FLM->FLM_APROV,FLM->FLM_VIAGEM,cPedido,cPartic)
                Endif

				cSeq := Soma1(cSeq,1)
				(cAliasTrb)->(DbSkip()) 	
			EndDo
		Else
			//Pegar o aprovador da RD0
			DbSelectArea("RD0")
			RD0->(DbSetOrder(1))
			If RD0->(MsSeek(xFilial("RD0")+cPartic)) 
				RecLock("FLM",.T.)
				FLM_FILIAL	:= xFilial("FLM")
				FLM_VIAGEM	:= cViagem
				FLM_PARTIC	:= cPartic
				FLM_ADIANT	:= cAdiant
				FLM_SEQ	:= cSeq
				FLM_TIPO	:= "1"
				If lAlc .And. !IsInCallStack("FINA661PRO")//Diferente de Migracao.
					cAprov := ExecBlock("F667ALCAPR",.F.,.F.,{cPartic,cViagem})
				EndIf				
				If ValType(cAprov) == "C" .and. !Empty(cAprov)
					FLM_APROV	:= cAprov
				Else
					FLM_APROV	:= If ( !Empty(RD0->RD0_APROPC), RD0->RD0_APROPC, RD0->RD0_APSUBS )
				EndIf
				FLM_NOMEAP	:= RD0->RD0_NOME
				FLM_STATUS	:= "1"
				FLM->(MsUnLock())

				//Mandar email para o proximo aprovador (Gestor)
				F667MsgMail(1,,,FLM->FLM_APROV,FLM->FLM_VIAGEM,cPedido,cPartic)
			EndIf
		EndIf
		If !Empty(cAprov)
			FLD->(DbSetOrder(1))
			If FLD->(DbSeek(xFilial("FLD")+cViagem+cPartic+cAdiant))
				RecLock("FLD",.F.)
				FLD->FLD_APROV := cAprov
				FLD->(MsUnLock())
			EndIf
		EndIf
	Else
		lRet := .F. 
		Help(" ",1,"FINA667JA",,STR0074,1,0) //Aprovações já geradas.
	EndIf
Else
	lRet := .F. 
	Help(" ",1,"FINA667PAR",,STR0075,1,0) //Parâmetros inválidos.
EndIf	

If ( Select( cAliasTrb ) > 0 )
	DbSelectArea(cAliasTrb)
	DbCloseArea()
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------  
Function FN667ODesc()
Local oModel		:= FWModelActive()
Local cNmPartic	:= ""
//Local cNumAdian	:= ""

//oModel:GetModel('FLDDETAIL')
cNmPartic := oModel:GetValue('FLDMASTER'/*FLDDETAIL*/, 'FLD_NOMEPA')
//cNumAdian := oModel:GetValue('APROVA', 'FLD_ADIANT')

Return cNmPartic
