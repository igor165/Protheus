#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'CTBA750.CH'

#DEFINE MODEL_OPERATION_CONTABILIZAR 9
#DEFINE MODEL_OPERATION_ESTORNO 	10
#DEFINE MODEL_OPERATION_GERAP 		6
#DEFINE MODEL_OPERATION_ALTPONT 	7
#DEFINE MODEL_OPERATION_APURAR 		8

STATIC __nOper := 0

/*/{Protheus.doc} CTBA750
Definição do modelo de Dados
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function CTBA750()
	Local oBrowse := NIL
	Local lDefTop := IfDefTopCTB() // verificar se pode executar query (TOPCONN)
	// Incluido por causa da rotina MSDOCUMENT, o MVC não precisa de nenhuma variável private
	Private aRotina	:= MenuDef()
	
	If !lDefTop
		Help("  ",1,"CTBA750TOP",,STR0002 ,1,0) //"Função disponível apenas para ambientes TopConnect"
		Return
	EndIf
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('CQE')
	oBrowse:SetDescription(STR0001)
	oBrowse:AddLegend( "CQE_STATUS =='0'","WHITE", STR0003 )
	oBrowse:AddLegend( "CQE_STATUS =='1'","RED"	 , STR0004 )
	oBrowse:AddLegend( "CQE_STATUS =='2'","BLUE" , STR0038 )
	oBrowse:AddLegend( "CQE_STATUS =='3'","BLACK", STR0037)
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
Return NIL

/*/{Protheus.doc} MenuDef
Definição do modelo de Dados
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Static Function MenuDef()
	
	Local aRotina := {}
	
	ADD OPTION aRotina Title STR0006	Action 'PesqBrw'		OPERATION 1  ACCESS 0 // //"Pesquisar"
	ADD OPTION aRotina Title STR0007 	Action 'C750View("1")'	OPERATION 2  ACCESS 0 // //"Visualizar"
	ADD OPTION aRotina Title STR0008	Action 'C750View("3")'	OPERATION 3  ACCESS 0 // //"Incluir"
	ADD OPTION aRotina Title STR0009	Action 'C750View("4")'	OPERATION 4  ACCESS 0 // //"Alterar"
	ADD OPTION aRotina Title STR0010	Action 'C750View("5")'	OPERATION 5  ACCESS 0 // //"Excluir"
	ADD OPTION aRotina Title STR0011	Action 'C750Apont()'	OPERATION 6  ACCESS 0 //"Gerar Apontamentos"
	ADD OPTION aRotina Title STR0012	Action 'C750View("7")'	OPERATION 7  ACCESS 0 //"Alterar Apontamentos"
	ADD OPTION aRotina Title STR0013	Action 'C750Apurar()'	OPERATION 8  ACCESS 0 //"Apurar Resultados"
	ADD OPTION aRotina Title STR0014	Action 'C750Contab()'	OPERATION 9  ACCESS 0 //"Contabilizar"
	ADD OPTION aRotina Title STR0015	Action 'C750Estorno()'	OPERATION 10  ACCESS 0 //"Estorno"
	
Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Static Function ModelDef()
	Local oModel
	Local oStrCQE := FWFormStruct(1, 'CQE')
	Local oStrCQH := FWFormStruct(1, 'CQH')
	Local oStrCQF := FWFormStruct(1, 'CQF')
	Local oStrCQG := FWFormStruct(1, 'CQG')
	Local oStrCQI	:= FWFormStruct(1, 'CQI')
	Local bPosCQH := { |oModel| C750PosCQH(oModel) }
	Local bPosCQG := { |oModel| C750PosCQG(oModel) }
	Local aCampos := {"CQH_TPAPON","CQH_VALOR","CQH_PERCEN"}
	Local nX		:= 0
	
	oModel := MPFormModel():New('CTBA750',/*Pre-Validação*/,{|oModel| C750TudoOK(oModel)}, {|oModel| C750Grava(oModel)})
	oModel:SetDescription(STR0043)//Apuracao Contabil Projeto
	//
	oStrCQE:SetProperty('CQE_RECCON', MODEL_FIELD_VALID, {|oModel| C750DtVal(oModel,'CQE_RECCON') }  )
	oStrCQE:SetProperty('CQE_FIMCON', MODEL_FIELD_VALID, {|oModel| C750DtVal(oModel,'CQE_FIMCON') }  )
	oStrCQE:AddTrigger('CQE_INICON','CQE_INICON',{ || .T.},{ |oModel| C750GatDat(oModel:GetValue('CQE_INICON') ) })
	oStrCQH:AddTrigger('CQH_USER','CQH_DESUSE'  ,{ || .T.},{ |oModel| UsrFullName(oModel:GetValue('CQH_USER') ) })
	oStrCQH:AddTrigger('CQH_TPAPON','CQH_DESAPO',{ || .T.},{ |oModel| Substr(Posicione("SX5",1, xFilial('SX5') + 'U0' +;
		oModel:GetValue('CQH_TPAPON') ,"X5_DESCRI"),1,TAMSX3("CQH_DESAPO")[1])})
	//
	For nX := 1 To Len(aCampos)
		oStrCQH:AddTrigger(aCampos[nX] ,'CQH_ORIGEM',{ || __nOper == MODEL_OPERATION_ALTPONT},{||'1'})
	Next nX
	//
	oModel:addFields('CQEMASTER',/**/,oStrCQE)
	oModel:addGrid('CQFDETAIL','CQEMASTER',oStrCQF,)
	oModel:addGrid('CQGDETAIL','CQFDETAIL',oStrCQG,/**/,bPosCQG)
	oModel:addGrid('CQHDETAIL','CQGDETAIL',oStrCQH,/**/,bPosCQH)
	oModel:AddGrid('CQIDETAIL','CQGDETAIL',oStrCQI)
	//CQF -> CQE
	oModel:SetRelation('CQFDETAIL', { { 'CQF_FILIAL', 'xFilial("CQF")' }, { 'CQF_CODAPU', 'CQE_CODAPU' } }, CQF->(IndexKey(1)) )
	//CQH -> CQG
	oModel:SetRelation('CQHDETAIL', { { 'CQH_FILIAL', 'xFilial("CQH")' }, { 'CQH_CODAPU', 'CQE_CODAPU' }, { 'CQH_ITESAL', 'CQF_ITESAL' }, { 'CQH_ITEPER', 'CQG_ITEPER' } }, CQH->(IndexKey(1)) )
	oModel:GetModel('CQHDETAIL'):SetUniqueLine( { 'CQH_TPAPON' } )
	//CQG->CQF
	oModel:SetRelation('CQGDETAIL', { { 'CQG_FILIAL', 'xFilial("CQG")' }, { 'CQG_CODAPU', 'CQE_CODAPU' }, { 'CQG_ITESAL', 'CQF_ITESAL' } }, CQG->(IndexKey(1)) )
	oModel:GetModel('CQGDETAIL'):SetUniqueLine( { 'CQG_INIPER' } )
	oModel:GetModel('CQFDETAIL'):SetUniqueLine( { 'CQF_TPSALD' } )
	//CQI -> CQG
	oModel:SetRelation('CQIDETAIL', { { 'CQI_FILIAL', 'xFilial("CQI")' }, { 'CQI_CODAPU', 'CQE_CODAPU' }, { 'CQI_ITESAL', 'CQF_ITESAL' } ,;
		{ 'CQI_ITEPER', 'CQG_ITEPER'	 }}, CQI->(IndexKey(1)) )
	
	oModel:GetModel('CQEMASTER'):SetDescription(STR0019)
	oModel:GetModel('CQFDETAIL'):SetDescription(STR0016)
	oModel:GetModel('CQGDETAIL'):SetDescription(STR0017)
	oModel:GetModel('CQHDETAIL'):SetDescription(STR0018)
	oModel:GetModel('CQGDETAIL'):SetOptional(.T.)
	oModel:GetModel('CQHDETAIL'):SetOptional(.T.)
	oModel:GetModel('CQIDETAIL'):SetOptional(.T.)
	//
	If __nOper == MODEL_OPERATION_ALTPONT
		oModel:GetModel('CQFDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('CQGDETAIL'):SetNoInsertLine(.T.)
	EndIf
	
Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Static Function ViewDef()
	Local oView
	Local oModel  := ModelDef()
	Local oStrCQE := FWFormStruct(2, 'CQE')
	Local oStrCQH := FWFormStruct(2, 'CQH')
	Local oStrCQF := FWFormStruct(2, 'CQF')
	Local oStrCQG := FWFormStruct(2, 'CQG')
	Local oStrCQI := FWFormStruct(2, 'CQI')
	
	
	oView := FWFormView():New()
	//
	oView:SetModel(oModel)
	oView:AddField('CQEMASTER',oStrCQE,'CQEMASTER')
	oView:AddGrid('CQHDETAIL' ,oStrCQH,'CQHDETAIL')
	oView:AddGrid('CQFDETAIL' ,oStrCQF,'CQFDETAIL')
	oView:AddGrid('CQGDETAIL' ,oStrCQG,'CQGDETAIL')
	oView:AddGrid('CQIDETAIL' ,oStrCQI,'CQIDETAIL')
	
	oView:SetViewProperty("CQEMASTER","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP ,-1})
	oView:SetViewProperty("CQGDETAIL","CHANGELINE",{{||C750Folder(oModel)}})
	
	oView:CreateVerticalBox( 'ESQ',30)
	oView:CreateVerticalBox( 'DIR', 70)
	oView:CreateHorizontalBox( 'CQF', 15, 'DIR')
	oView:CreateHorizontalBox( 'CQG', 35, 'DIR')
	oView:CreateHorizontalBox( 'PASTA', 50, 'DIR')
	oView:CreateFolder('FOLDER','PASTA','DIR')
	oView:AddSheet('FOLDER','SHEET_CQH'       ,'Apontamentos')      //
	oView:AddSheet('FOLDER','SHEET_CQI'       ,'Movimentos')      //
	
	oView:CreateHorizontalBox('SHEETCQH',100,,,'FOLDER', 'SHEET_CQH' )
	oView:CreateHorizontalBox('SHEETCQI',100,,,'FOLDER', 'SHEET_CQI' )
	
	//
	oStrCQE:RemoveField( 'CQE_STATUS' )
	oStrCQH:RemoveField( 'CQH_ITEPER' )
	oStrCQH:RemoveField( 'CQH_ITESAL' )
	oStrCQH:RemoveField( 'CQH_USER'   )
	oStrCQH:RemoveField( 'CQH_CODAPU' )
	oStrCQF:RemoveField( 'CQF_CODAPU' )
	oStrCQG:RemoveField( 'CQG_ITESAL' )
	oStrCQG:RemoveField( 'CQG_CODAPU' )
	oStrCQI:RemoveField( 'CQI_ITESAL' )
	oStrCQI:RemoveField( 'CQI_ITEPER' )
	oStrCQI:RemoveField( 'CQI_ITEAPO' )
	oStrCQI:RemoveField( 'CQI_CODAPU' )
	//
	
	oView:SetOwnerView('CQEMASTER','ESQ')
	oView:SetOwnerView('CQFDETAIL','CQF')
	oView:SetOwnerView('CQGDETAIL','CQG')
	//oView:SetOwnerView('CQGDETAIL','DIR')
	oView:SetOwnerView('CQHDETAIL','SHEETCQH')
	oView:SetOwnerView('CQIDETAIL','SHEETCQI')
	
	//Só é possivel editar os apontamentos na opção de alterar apontamentos.
	oView:SetOnlyView('CQIDETAIL')
	If __nOper <> MODEL_OPERATION_ALTPONT
		oView:SetOnlyView('CQGDETAIL')
		oView:SetOnlyView('CQHDETAIL')
	EndIf
	//
	If __nOper == MODEL_OPERATION_INSERT .OR. __nOper == MODEL_OPERATION_UPDATE
		oView:SetOnlyView('CQGDETAIL')
		oView:SetOnlyView('CQHDETAIL')
	Else
		oView:SetOnlyView('CQFDETAIL')
	EndIf
	
	If !__nOper == MODEL_OPERATION_INSERT
		oView:SetOnlyView('CQEMASTER')
	EndIf
	oView:EnableTitleView('CQEMASTER')
	oView:EnableTitleView('CQFDETAIL')
	oView:EnableTitleView('CQGDETAIL')
	
	oView:AddIncrementField('CQHDETAIL' , 'CQH_ITEAPO' )
	oView:AddIncrementField('CQFDETAIL' , 'CQF_ITESAL' )
	oView:AddIncrementField('CQGDETAIL' , 'CQG_ITEPER' )
	
	oView:SetAfterViewActivate({|oModel|C750Folder(oModel)})
	
Return oView

/*/{Protheus.doc} C750DtVal()
Validação da data de inicio do reconhecimento dos resultados.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750DtVal(oSubCQE,cCampo)
	Local oModel := FWModelActive()
	Local lRet	 := .T.
	
	If     cCampo == 'CQE_RECCON'
		//Data deve ser maior ou igual.
		If oSubCQE:GetValue('CQE_INICON') > oSubCQE:GetValue('CQE_RECCON')
			lRet := .F.
			oModel:SetErrorMessage('CTBA750','CQE_RECCON',/**/,/**/,/**/,STR0020)
		EndIf
	ElseIf cCampo == 'CQE_FIMCON'
		//Data deve ser maior ou igual a data de reconhecimento.
		If oSubCQE:GetValue('CQE_RECCON') > oSubCQE:GetValue('CQE_FIMCON')
			lRet := .F.
			oModel:SetErrorMessage('CTBA750','CQE_RECCON',/**/,/**/,/**/,STR0021)
		EndIf
	EndIf
Return lRet

/*/{Protheus.doc} C750View()
Executa a view com base na operação.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750View(cOperation)
	__nOper := Val(cOperation)
	
	Do Case
		
	Case __nOper == MODEL_OPERATION_ALTPONT
		
		If CQE->CQE_STATUS == '2'
			FWExecView( STR0001 , 'CTBA750', MODEL_OPERATION_UPDATE )
		Else
			Help("  ",1,"CTBA750DELETE",,STR0036 ,1,0) //
		EndIf
		
	Case __nOper == MODEL_OPERATION_DELETE
		
		//Apenas status de gerado pode ser excluido.
		If CQE->CQE_STATUS == '0'
			FWExecView( STR0001 , 'CTBA750', __nOper )
		Else
			Help("  ",1,"CTBA750DELETE",,STR0035 ,1,0) //
		EndIf
		
	OtherWise
		
		// Visualizar, Incluir, Alterar
		FWExecView( STR0001 , 'CTBA750', __nOper )
	EndCase
	
Return

/*/{Protheus.doc} C750PreCQH().
Pré-Validação do CQH
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750PosCQH(oSubModel)
	Local oModel := FWModelActive()
	Local lRet   := .T.
	
	//Justificativa é obrigatoria
	If  __nOper == MODEL_OPERATION_ALTPONT
		
		If Empty(oSubModel:GetValue('CQH_JUSTIF')) .AND. oSubModel:GetValue('CQH_ORIGEM') == '1' //Manual
			lRet := .F.
			oModel:SetErrorMessage('CTBA750','CQH_JUSTIF',/**/,/**/,/**/,STR0034)
		EndIf
		
		If lRet .AND. oSubModel:GetValue('CQH_ORIGEM') == '1' //Manual
			oSubModel:SetValue('CQH_DATA', dDataBase)
			oSubModel:SetValue('CQH_HORA', Substr(Time(),1,TAMSX3('CQH_HORA')[1]))
			oSubModel:SetValue('CQH_USER', __cUserID )
		EndIf
		
	EndIf
	
Return lRet

/*/{Protheus.doc} C750GerAp().
Geração dos Apontamentos atraves da integração TOP x Protheus por mensagem unica.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750GerAp(oSelf)
	Local oModel 		:= FWLoadModel("CTBA750")
	Local oAuxCQG		:= Nil
	Local oAuxCQH		:= Nil
	Local oAuxCQF		:= Nil
	Local oAuxCQI		:= Nil
	Local cLvCusto	:= ""
	Local cLvFatur	:= ""
	Local aSetOfBook	:= {}
	Local lRet 		:= ""
	Local cArqTmp		:= ""
	Local lEnd			:= .F.
	Local dDataIni	:= CTOD("")
	Local dDataFim	:= CTOD("")
	Local aSelFil 	:= { cFilAnt }
	Local nX,nY		:= 0
	Local nValCusto	:= 0
	Local nValFatur	:= 0
	Local cItemCQG	:= ""
	Local cItem		:= ""
	Local cQuery 		:= ""
	Local cAliasAPU 	:= GetNextAlias()
	
	//-----------------------
	//MV_PAR01 - Apuração de
	//MV_PAR02 - Apuração Ate
	//MV_PAR03 - Data Final
	//MV_PAR04 - Reprocessa Apurações
	//-----------------------
	dbSelectArea('CQE')
	cQuery += "SELECT CQE_CODAPU FROM " + RetSqlName("CQE")
	cQuery += "WHERE CQE_CODAPU BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQuery += "AND CQE_FILIAL = '" + xFilial("CQE") + "'"
	If MV_PAR04 == 2
		cQuery += " AND CQE_STATUS = '0'  "
	EndIf
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAPU,.T.,.T.)
	dbSelectArea(cAliasAPU)
	dbGoTop()
	oSelf:SaveLog(STR0033)
	oSelf:SetRegua1((cAliasAPU)->(Recno()))
	oSelf:IncRegua1( "Processando..."  + cValToChar((cAliasAPU)->CQE_CODAPU ))
	//
	While (cAliasAPU)->(!Eof())
		
		CQE->(dbSeek( xFilial('CQE') + (cAliasAPU)->CQE_CODAPU ))
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		oAuxCQF 	:= oModel:GetModel('CQFDETAIL')
		oAuxCQG 	:= oModel:GetModel('CQGDETAIL')
		oAuxCQH 	:= oModel:GetModel('CQHDETAIL')
		oAuxCQI 	:= oModel:GetModel('CQIDETAIL')
		cLvCusto 	:= oModel:GetValue('CQEMASTER','CQE_VISCIN')
		cLvFatur 	:= oModel:GetValue('CQEMASTER','CQE_VISFAT')
		
		//No segundo periodo em diante, considera a data final do periodo anterior.
		If oAuxCQG:GetValue('CQG_STATUS', oAuxCQG:Length() ) == '2'  //Contabilizado.
			dDataIni := oAuxCQG:GetValue("CQG_FIMPER", oAuxCQG:Length()) + 1
		Else
			dDataIni := oModel:GetValue('CQEMASTER','CQE_INICON')
		EndIf
		//
		dDataFim := MV_PAR03
		
		For nY := 1 To oAuxCQF:Length() //Processa todos os tipos de saldos.
			oAuxCQF:SetLine( nY )//Posiciona na CQF.
			
			aSetOfBook := CTBSetOf(cLvCusto)
			CTGerPlan(	Nil, Nil, Nil, @lEnd,@cArqTmp,;
				dDataIni,dDataFim,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
				"",Repl("Z", Len(CTH->CTH_CLVL)),"01",	oAuxCQF:GetValue('CQF_TPSALD', nY),aSetOfBook, Space(2);
				, Space(20), Repl("Z", 20), Space(30),,,,, /*lImpAntLP*/, /*dDataLP*/;
				, ,.F.,,,,,,,,,,,,,,,,,,,,,,,,,,,aSelFil)
			DbSelectArea("cArqTmp")
			
			While cArqTmp->(!EOF())
				
				If cArqTmp->TOTVIS == '1'
					nValCusto := Abs(cArqTmp->MOVIMENTO)
					cArqTmp->(DbGoBottom())
				EndIf
				cArqTmp->(dbSkip())
			EndDo
			
			//Exclui arquivos.
			cArqTmp->(dbCloseArea())
			FErase(cArqTmp + GetDbExtension())
			aSize(aSetOfBook,0)
			aSetOfBook := {}
			
			aSetOfBook := CTBSetOf(cLvFatur)
			
			CTGerPlan(	Nil, Nil, Nil, @lEnd,@cArqTmp,;
				dDataIni,dDataFim,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
				"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
				"",Repl("Z", Len(CTH->CTH_CLVL)),"01",	oAuxCQF:GetValue('CQF_TPSALD', nY),aSetOfBook, Space(2);
				, Space(20), Repl("Z", 20), Space(30),,,,, /*lImpAntLP*/, /*dDataLP*/;
				, ,.F.,,,,,,,,,,,,,,,,,,,,,,,,,,,aSelFil)
			DbSelectArea("cArqTmp")
			
			While cArqTmp->(!EOF())
				
				If cArqTmp->TOTVIS == '1'
					nValFatur := Abs(cArqTmp->MOVIMENTO)
					cArqTmp->(DbGoBottom())
				EndIf
				cArqTmp->(dbSkip())
			EndDo
			
			//Exclui arquivos.
			cArqTmp->(dbCloseArea())
			FErase(cArqTmp + GetDbExtension())
			aSize(aSetOfBook,0)
			aSetOfBook := {}
			
			//Novo periodo de apuração
			If nValCusto > 0
				
				cItenCQG := Soma1(oAuxCQG:GetValue('CQG_ITEPER', oAuxCQG:Length()))
				If oAuxCQG:GetValue('CQG_STATUS', oAuxCQG:Length() ) == '2'  //Contabilizado.
					oAuxCQG:AddLine()	//Novos valores para periodo.
					oAuxCQG:SetValue('CQG_ITEPER', cItenCQG )
				Else
					
					//Reprocessa os valores.
					oAuxCQG:SetLine( oAuxCQG:Length() )
					If !oAuxCQH:IsEmpty()
						For nX := 1 To oAuxCQH:Length()
							oAuxCQH:SetLine(nX)
							oAuxCQH:DeleteLine()
						Next nX
						oAuxCQH:AddLine()
						//Reprocessa os movimentos.
						For nX := 1 To oAuxCQI:Length()
							oAuxCQI:SetLine(nX)
							oAuxCQI:DeleteLine()
						Next nX
					EndIf
				EndIf
				
				cItem := Soma1(oAuxCQH:GetValue('CQH_ITEAPO',oAuxCQH:Length()))
				//Períodos de Apuração.
				oAuxCQG:SetValue('CQG_INIPER', dDataIni )
				oAuxCQG:SetValue('CQG_FIMPER', dDataFim )
				oAuxCQG:SetValue('CQG_MARGEM', 0 )
				//Apontamentos do Período.
				oAuxCQH:SetValue('CQH_ITEAPO', cItem)
				oAuxCQH:SetValue('CQH_TPAPON', '01') //Custo Incorrido.
				oAuxCQH:SetValue('CQH_VALOR',  nValCusto )
				oAuxCQH:SetValue('CQH_ORIGEM', '2' ) //Automatico
				oAuxCQH:SetValue('CQH_DATA', dDataBase)
				oAuxCQH:SetValue('CQH_HORA', Substr(Time(),1,TAMSX3('CQH_HORA')[1]))
				oAuxCQH:SetValue('CQH_USER', __cUserID )
				
				If nValFatur > 0
					oAuxCQH:AddLine()
					oAuxCQH:SetValue('CQH_ITEAPO', Soma1(cItem))
					oAuxCQH:SetValue('CQH_TPAPON', '03') //Faturamentos do Contrato.
					oAuxCQH:SetValue('CQH_VALOR',  nValFatur )
					oAuxCQH:SetValue('CQH_ORIGEM', '2' ) //Automatico
					oAuxCQH:SetValue('CQH_DATA', dDataBase)
					oAuxCQH:SetValue('CQH_HORA', Substr(Time(),1,TAMSX3('CQH_HORA')[1]))
					oAuxCQH:SetValue('CQH_USER', __cUserID )
					
				EndIf
				
				oModel:SetValue('CQEMASTER','CQE_STATUS','2') //Apontamento pendente
				
				//-----DIFERENCA DO PERIODO PASSADO----------//
				If oAuxCQG:Length() > 1
					C750DifPer(oModel)
				EndIf
				
			EndIf
			
		Next nX
		
		If oModel:VldData()
			FWFormCommit( oModel )
		Else
			
			For nX := 1 To Len(oModel:GetErrorMessage())
				cLog += oModel:GetErrorMessage()[nX]
			Next nX
			
		EndIf
		
		oModel:DeActivate()
		(cAliasAPU)->(dbSkip())
		
	EndDo
	
	//Exclui arquivos.
	(cAliasAPU)->(dbCloseArea())
	FErase((cAliasAPU) + GetDbExtension())
	oModel:Destroy()
	oModel := Nil
	
Return lRet

/*/{Protheus.doc} C750Estorno().
Exclusão dos movimentos e geração do apontamento da ultima apuração.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750Estorno()
	Local oProcesso	:= Nil
	Local bProcess 	:= {|oSelf|C750CtbEst(oSelf)}
	
	oProcesso := tNewProcess():New("CTBA750",;
		STR0032,;
		bProcess,;
		STR0041,;
		"CTBA750C")
	
Return

/*/{Protheus.doc} C750Contab().
Realiza contabilização off-line dos movimentos gerados.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750Contab()
	Local oProcesso	:= Nil
	Local bProcess 	:= {|oSelf|C750CtbMov(oSelf)}
	
	oProcesso := tNewProcess():New("CTBA750",;
		STR0031,;
		bProcess,;
		STR0042,;
		"CTBA750C")
	
	
Return

/*/{Protheus.doc} C750Apurar().
Gera os movimentos de apuração de resultado do Contrato.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750Apurar()
	Local oProcesso	:= Nil
	Local bProcess 	:= {|oSelf|C750ApurCQI(oSelf)}
	
	oProcesso := tNewProcess():New("CTBA750B",;
		STR0030,;
		bProcess,;
		STR0039,;
		"CTBA750B")
	
	
Return

/*/{Protheus.doc} C750GatDat().
Gatilho para gravar data no campo de inicio do periodo.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750GatDat(dDataIni)
	Local oModel := FWModelActive()
	
	oModel:SetValue('CQGDETAIL','CQG_INIPER', dDataIni)
	
Return dDataIni

/*/{Protheus.doc} C750PreCQG().
Pós-Validação do submodelo CQG
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750PosCQG(oCQG)
	Local oModel := FWModelActive()
	Local lRet := .T.
	
	If oCQG:Length() > 1 .AND. oCQG:GetValue('CQG_STATUS', oCQG:Length() - 1 ) == '1'
		oModel:SetErrorMessage('CTBA750','CQG_STATUS',/**/,/**/,/**/,STR0029)
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} C750Apont.
Geração de apontamentos.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750Apont()
	Local oProcesso	:= Nil
	Local bProcess 	:= {|oSelf|C750GerAp(oSelf)}
	
	oProcesso := tNewProcess():New("CTBA750",;
		STR0028,;
		bProcess,;
		STR0040 ,;
		"CTBA750A")
	
Return

/*/{Protheus.doc} C750TudoOK.
Validação total do modelo de dados.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750TudoOK(oModel)
	Local oAuxCQH	:= oModel:GetModel('CQHDETAIL')
	Local oAuxCQG	:= oModel:GetModel('CQGDETAIL')
	Local lRet		:= .T.
	Local nValPrec:= 0
	Local nIncorrer:= 0
	Local nMargem	:= 0
	
Return lRet

/*/{Protheus.doc} C750Grava.
Gravação do Modelo de Dados.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750Grava(oModel)
	Local oAuxCQH	:= oModel:GetModel('CQHDETAIL')
	Local oAuxCQG	:= oModel:GetModel('CQGDETAIL')
	Local oAuxCQF	:= oModel:GetModel('CQFDETAIL')
	Local cItem		:= ""
	Local nValInco 	:= 0
	Local nIncorrer	:= 0
	Local nValOrc	:= 0
	Local lRet		:= .T.
	Local nValPOC 	:= 0
	Local nX,nY		:= 0
	Local nPorc		:= 0
	Local aTipos	:= {}
	
	Do Case
		
	Case __nOper == MODEL_OPERATION_ALTPONT
		
		For nX := 1 to oAuxCQF:Length()
			
			oAuxCQF:SetLine( nX )
			oAuxCQG:SeekLine({{'CQG_STATUS','1'}})
			//------------- CUSTO ORÇADO ------------------
			aAdd(aTipos, C750AddCO(oModel))
			//--------------- CUSTO A INCORRER -------------------
			aAdd(aTipos, C750AddCIR(oModel))
			//-------- POC - PERCENTUAL DO ESTAGIO DE EXECUÇÃO ---------------
			aAdd(aTipos, C750AddPOC(oModel))
			
			//Grava os tipos de apontamentos calculados.
			For nY := 1 To Len(aTipos)
				If aTipos[nY][2] > 0
					cItem := Soma1(oAuxCQH:GetValue('CQH_ITEAPO', oAuxCQH:Length() ) )
					oAuxCQH:AddLine()
					oAuxCQH:SetValue('CQH_ITEAPO', cItem )
					oAuxCQH:SetValue('CQH_TPAPON', aTipos[nY][1])
					If aTipos[nY][1] == '07'
						oAuxCQH:SetValue('CQH_PERCEN', aTipos[nY][2])
					Else
						oAuxCQH:SetValue('CQH_VALOR' , aTipos[nY][2])
					EndIf
					oAuxCQH:SetValue('CQH_ORIGEM', '2' ) //Automatico
					oAuxCQH:SetValue('CQH_DATA'  , dDataBase)
					oAuxCQH:SetValue('CQH_HORA'  , Substr(Time(),1,TAMSX3('CQH_HORA')[1]))
					oAuxCQH:SetValue('CQH_USER'  , __cUserID )
				EndIf
			Next nY
			
			//-----DIFERENCA DO PERIODO PASSADO----------//
			If oAuxCQG:Length() > 1
				C750DifPer(oModel)
			EndIf
			//------ATUALIZA VALOR DA MARGEM--------------
			If oAuxCQH:SeekLine({{"CQH_TPAPON","04"}}) .AND. oAuxCQG:GetValue('CQG_FIMPER') > oModel:GetValue('CQEMASTER','CQE_RECCON')//Preço Contrato
				nValPrec := oAuxCQH:GetValue("CQH_VALOR")
				If oAuxCQH:SeekLine({{"CQH_TPAPON","02"}}) //Incorrer
					nIncorrer := oAuxCQH:GetValue("CQH_VALOR")
					If oAuxCQH:SeekLine({{"CQH_TPAPON","01"}}) //Incorrido
						nMargem := (nValPrec - ( oAuxCQH:GetValue("CQH_VALOR") + nIncorrer)) / nValPrec
						oAuxCQG:SetValue("CQG_MARGEM", Round(nMargem * 100,2) )
					EndIf
				EndIf
			Else
				oAuxCQG:SetValue("CQG_MARGEM", 0 )
			EndIf
			
		Next nX
		
	Case __nOper == MODEL_OPERATION_INSERT .or. __nOper == MODEL_OPERATION_UPDATE
		
		For nX := 1 to oAuxCQF:Length()
			oAuxCQF:SetLine( nX )
			oAuxCQG:SeekLine({{'CQG_STATUS','1'}})
			oAuxCQG:SetValue('CQG_INIPER', oModel:GetValue('CQEMASTER','CQE_INICON') )
			oAuxCQG:SetValue('CQG_FIMPER', LastDay(oModel:GetValue('CQEMASTER','CQE_INICON')) )
		Next nX
		
	EndCase
	
	//Gravação do Modelo de Dados.
	FWFormCommit( oModel )
	
Return lRet

/*/{Protheus.doc} C750ApurCQI.
Gera movimentos de apuração na CQI.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750ApurCQI(oSelf)
	Local oModel	:= FWLoadModel('CTBA750')
	Local cQuery 	:= ""
	Local cLog		:= ""
	Local cAliasRes := GetNextAlias()
	Local lRet		:= .T.
	
	dbSelectArea('CQE')
	//
	cQuery += "SELECT CQE_CODAPU FROM " + RetSqlName("CQE")
	cQuery += "WHERE CQE_CODAPU BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	cQuery += "AND CQE_FILIAL = '" + xFilial("CQE") + "'"
	cQuery += "AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasRes,.T.,.T.)
	dbSelectArea(cAliasRes)
	dbGoTop()
	oSelf:SaveLog(STR0027)
	//
	While (cAliasRes)->(!Eof()) .AND. lRet
		
		oSelf:SetRegua1((cAliasRes)->(Recno()))
		oSelf:IncRegua1( "Processando..."  + cValToChar((cAliasRes)->CQE_CODAPU ))
		//
		CQE->(dbSeek( xFilial('CQE') + (cAliasRes)->CQE_CODAPU ))
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		
		If CValApur(oModel) //Retorna se todos os apontamentos estão corretos para a apuração
			
			cLog := C750GeraCQI(oModel)
			If !Empty(cLog)
				oSelf:SaveLog(cLog)
				lRet := .F.
			EndIf
			
		Else
			oSelf:SaveLog(STR0025 + cValToChar((cAliasRes)->CQE_CODAPU + STR0026) )
			lRet := .F.
		EndIf
		(cAliasRes)->(dbSkip())
		
	EndDo
	
	//Exclui arquivos.
	(cAliasRes)->(dbCloseArea())
	FErase((cAliasRes) + GetDbExtension())
	oModel:Destroy()
	oModel := Nil
	
Return lRet

/*/{Protheus.doc} CValApur.
Validação para apurar os apontamentos.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Static Function CValApur(oModel)
	Local lRet 	:= .T.
	Local nX		:= 1
	Local nY 		:= 0
	Local oAuxCQF := oModel:GetModel('CQFDETAIL')
	Local oAuxCQG := oModel:GetModel('CQGDETAIL')
	Local oAuxCQH := oModel:GetModel('CQHDETAIL')
	
	
	While nX <= oAuxCQF:Length() .AND. lRet
		
		oAuxCQF:SetLine( nX )
		If oAuxCQG:SeekLine( {{'CQG_STATUS','1'}} ) //Não Contabilizado.
			lRet := oAuxCQH:Length() >= 6  //Todos os tipos de apontamentos.
			If lRet
				//Apaga os movimentos e faz uma nova apuração.
				For nY := 1 To oModel:GetModel("CQIDETAIL"):Length()
					oModel:GetModel("CQIDETAIL"):SetLine(nY)
					oModel:GetModel("CQIDETAIL"):DeleteLine()
				Next nY
			EndIf
		Else
			lRet := .F. //Contabilizado.
		EndIf
		nX ++
		
	EndDo
	
Return lRet

/*/{Protheus.doc} C750GeraCQI.
Gravação dos valores de movimento para as apurações.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750GeraCQI(oModel)
	Local oAuxCQI	:= oModel:GetModel('CQIDETAIL')
	Local oAuxCQH	:= oModel:GetModel('CQHDETAIL')
	Local oAuxCQF	:= oModel:GetModel('CQFDETAIL')
	Local oAuxCQG	:= oModel:GetModel('CQGDETAIL')
	Local nLinAtu	:= 0
	Local lFirstAp:= .F.
	Local nValRec := 0 //Valor da Receita
	Local nValTot	:= 0
	Local nValPOC	:= 0
	Local cLog 	:= ""
	Local nZ		:= 1
	Local nC		:= 1
	Local nD		:= 1
	Local aValores:= {}
	Local nValFat	:= 0
	Local cItem	:= ""
	Local aRecCQI := {}
	Local nPos		:= 0
	
	For nZ := 1 To oAuxCQF:Length()
		
		oAuxCQF:SetLine( nZ )
		oAuxCQG:SeekLine({{'CQG_STATUS','1'}})
		nLinAtu := oAuxCQG:GetLine()
		lFirstAp := oAuxCQG:Length() == 1
		
		If !lFirstAp
			
			//Acumula valores de movimentos dos periodos anteriores.
			While nC <= oAuxCQG:Length() .AND. nC <> nLinAtu
				oAuxCQG:GoLine( nC )
				For nD := 1 To oAuxCQI:Length()
					If (nPos := AScan( aRecCQI, { |x| x[1] == oAuxCQI:GetValue('CQI_OCOR', nD) } ) ) > 0
						aRecCQI[nPos][2] += oAuxCQI:GetValue('CQI_VALOR', nD )
					Else
						aAdd(aRecCQI, { oAuxCQI:GetValue('CQI_OCOR' , nD ) , oAuxCQI:GetValue('CQI_VALOR', nD ) } )
					EndIf
				Next nD
				nC++
			EndDo
		EndIf
		//----------------- 01 - Receita auferida do contrato ------------------------//
		aAdd(aValores, C750RecAuf(oModel,lFirstAp,aRecCQI) )
		
		//----------------- 02 – Custo de Receitas Auferidas -------------------------//
		aAdd(aValores, C750CusAuf(oModel,lFirstAp,aRecCQI) )
		
		//----------------- 03 – Faturamento do período ------------------------------//
		aAdd(aValores, C750FatPer(oModel,nLinAtu,aRecCQI) )
		
		//----------------- 04 – Lucro Auferido do Periodo -------------------------//
		aAdd(aValores, C750LucAuf(aValores[1][2],aValores[2][2]) )
		
		//----------------- 05 – Prejuizo Auferido do Periodo -------------------------//
		aAdd(aValores, C750PrejAuf(aValores[1][2],aValores[2][2]) )
		
		//----------------- 06 – Ajustes contábil (Positivo) -------------------------//
		aAdd(aValores, C750AjCont(oModel,.T.) )
		
		//----------------- 07 – Ajustes contábil (Negativo) -------------------------//
		aAdd(aValores, C750AjCont(oModel,.F.) )
		//Posiciona CQG.
		oAuxCQG:GoLine( nLinAtu )
		For nC := 1 To Len(aValores)
			If !Empty( aValores[nC][2] )
				cItem := Soma1(oAuxCQI:GetValue('CQI_SEQMOV'))
				oAuxCQI:AddLine()
				oAuxCQI:SetValue('CQI_SEQMOV', cItem )
				oAuxCQI:SetValue('CQI_DTMOV' , dDataBase)
				oAuxCQI:SetValue('CQI_OCOR'  , aValores[nC][1])
				oAuxCQI:SetValue('CQI_VALOR' , aValores[nC][2])
			EndIf
		Next nC
		
		oModel:SetValue('CQEMASTER','CQE_STATUS', '1') //Efetivo.
		oAuxCQG:SetValue('CQG_DTEFET', dDatabase) //Data de efetivação.
		
	Next nZ
	//Gravação dos movimentos.
	If oModel:VldData()
		FWFormCommit( oModel )
	Else
		
		For nZ := 1 To Len(oModel:GetErrorMessage())
			cLog := oModel:GetErrorMessage( nZ ) + " - "
		Next nZ
		
	EndIf
	
	oModel:DeActivate()
	
Return cLog

/*/{Protheus.doc} C750RecAuf.
Calculo da receita auferida do contrato.
@param Modelo de dados.
@param Primeira Apuração.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750RecAuf(oModel, lFirstAp, aAux)
	Local aRet := {}
	Local nValCont := 0
	Local nValPOC  := 0
	Local nPos		 := 0
	Default lFirstAp := .T.
	aSize(aRet, 2)
	aRet[1] := '01'
	
	//
	If !Empty(oModel:GetValue('CQGDETAIL','CQG_MARGEM'))
		
		//Preço contrato.
		oModel:GetModel('CQHDETAIL'):SeekLine({{"CQH_TPAPON","04"}})
		nValCont := oModel:GetValue("CQHDETAIL","CQH_VALOR")
		//POC
		oModel:GetModel("CQHDETAIL"):SeekLine({{"CQH_TPAPON","07"}})
		nValPOC := oModel:GetValue("CQHDETAIL","CQH_PERCEN")
		If lFirstAp
			aRet[2] := nValCont * nValPOC
		Else
			//Valor total * Percentual de Execução - Total das receitas anteriores.
			If (nPos := AScan( aAux, { |x| x[1] == "01" } ) ) > 0
				aRet[2] := (nValCont * nValPOC) - aAux[nPos][2]
			EndIf
		EndIf
	Else
		//Se a margem for zero, a receita será igual ao custo incorrido.
		oModel:GetModel("CQHDETAIL"):SeekLine({{"CQH_TPAPON","01"}}) //Custo Incorrido.
		aRet[2] := oModel:GetValue('CQHDETAIL','CQH_VALOR')
	EndIf
	
Return aRet

/*/{Protheus.doc} C750RecAuf.
Calculo da Custo de Receitas Auferidas.
@param Modelo de dados.
@param Primeira Apuração.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750CusAuf(oModel, lFirstAp, aAux)
	Local aRet 		:= {}
	Local nValPOC 	:= 0
	Local nValCust	:= 0
	Local nPos			:= 0
	Default lFirstAp 	:= .T.
	aSize(aRet, 2)
	aRet[1] := '02'
	
	//Custo Orçado.
	oModel:GetModel("CQHDETAIL"):SeekLine({{"CQH_TPAPON","05"}})
	nValCust := oModel:GetValue("CQHDETAIL","CQH_VALOR")
	//POC
	oModel:GetModel("CQHDETAIL"):SeekLine({{"CQH_TPAPON","07"}})
	nValPOC := oModel:GetValue("CQHDETAIL","CQH_PERCEN")
	//Orçado * POC
	If lFirstAp
		aRet[2] := nValCust * nValPOC
	Else
		//Orçado * POC - Total das receitas anteriores.
		If (nPos := AScan( aAux, { |x| x[1] == "02" } ) ) > 0
			aRet[2] := (nValCust * nValPOC) - aAux[nPos][2]
		EndIf
	EndIf
	
Return aRet

/*/{Protheus.doc} C750FatPer.
Calculo  - Faturamento do período.
@param Modelo de dados.
@param Linha Atual da CQG
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750FatPer(oModel, nLinAtu, aAux)
	Local aRet 	:= {}
	Local nC   	:= 1
	Local nValFat	:= 0
	//
	aSize(aRet, 2)
	aRet[1] := '03'
	//Faturamentos anteriores.
	If (nPos := AScan( aAux, { |x| x[1] == "03" } ) ) > 0
		nValFat := aAux[nPos][2]
	EndIf
	
	oModel:GetModel('CQHDETAIL'):SeekLine({{"CQH_TPAPON","03"}})
	aRet[2] := oModel:GetValue("CQHDETAIL","CQH_VALOR") - nValFat
	
Return aRet

/*/{Protheus.doc} C750FatPer.
Calculo  - Lucro Auferido no Periodo.
@param Modelo de dados.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750LucAuf(nReceita, nCusto)
	Local aRet := {}
	//
	aSize(aRet, 2)
	
	aRet[1] := '04'
	//Verifica se Receita é maior que o custo.
	If nReceita > nCusto
		aRet[2] := nReceita - nCusto
	Else
		aRet[2] := 0
	EndIf
	
Return aRet

/*/{Protheus.doc} C750PrejAuf.
Calculo  - Prejuizo Auferido no Periodo.
@param Receita Auferida.
@param Custo Auferido.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750PrejAuf(nReceita, nCusto)
	Local aRet := {}
	//
	aSize(aRet, 2)
	
	aRet[1] := '05'
	//Verifica se Receita é maior que o custo.
	If nReceita < nCusto
		aRet[2] := nCusto - nReceita
	Else
		aRet[2] := 0
	EndIf
	
Return aRet

/*/{Protheus.doc} C750AjCont.
Calculo  - Ajuste Contabil.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750AjCont(oModel, lPositivo)
	local oAuxCQH	:= oModel:GetModel('CQHDETAIL')
	Local aRet 		:= {}
	//
	aSize(aRet, 2)
	If oModel:GetValue('CQFDETAIL','CQF_METPOC') == '2' //Medição do Trabalho Executado.
		
		If lPositivo
			oAuxCQH:SeekLine({{"CQH_TPAPON","01"}})
			aRet[2] := oAuxCQH:GetValue("CQH_VALOR")	
		Else
			oAuxCQH:SeekLine({{"CQH_TPAPON","02"}})
			aRet[2] := oAuxCQH:GetValue("CQH_VALOR") 
		EndIf
	EndIf
	aRet[1] := If(lPositivo,'06','07') //Ajuste Contabil Postitivo e Negativo.
	
Return aRet

/*/{Protheus.doc} C750ValidTP.
Valida o tipo de apontamento.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750ValidTP()
	Local oModel	:= FWModelActive()
	Local lRet 	:= .T.
	Local cTipo	:= &(ReadVar())
	Local cMetod 	:= oModel:GetModel('CQFDETAIL'):GetValue('CQF_METPOC')
	
	If 		cTipo == '06' .AND. cMetod == '1'
		oModel:SetErrorMessage('CTBA750','CQF_METPOC',/**/,/**/,/**/,STR0024)
		lRet := .F.
	EndIf
	
Return lRet


/*/{Protheus.doc} C750AddCO.
Calcula os valores para Custo Orçado.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750AddCO(oModel)
	Local oAuxCQF 	:= oModel:GetModel('CQFDETAIL')
	Local oAuxCQH 	:= oModel:GetModel('CQHDETAIL')
	Local nValInco	:= 0
	Local aRet		:= {0,0}
	
	//Calcula o custo Orçado para cassos em que não foi informado.
	If !oAuxCQH:SeekLine({{"CQH_TPAPON","05"}}) //Orçado.
		
		If oAuxCQH:SeekLine({{"CQH_TPAPON","01"}}) //Incorrido.
			nValInco := oAuxCQH:GetValue("CQH_VALOR")
			//
			If oAuxCQH:SeekLine({{"CQH_TPAPON","02"}}) //Incorrer.
				aRet[1] := '05'
				aRet[2] := oAuxCQH:GetValue("CQH_VALOR") + nValInco
			EndIf
		EndIf
	EndIf
	
Return aRet

/*/{Protheus.doc} C750AddCIR.
Calcula os valores para Custo Incorrer.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750AddCIR(oModel)
	Local oAuxCQF 	:= oModel:GetModel('CQFDETAIL')
	Local oAuxCQH 	:= oModel:GetModel('CQHDETAIL')
	Local nValOrc	:= 0
	Local aRet		:= {0,0}
	
	//Calcula o custo a incorrer, para casos em que orçado já foi informado.
	If !oAuxCQH:SeekLine({{"CQH_TPAPON","02"}}) //Incorrer.
		
		If oAuxCQH:SeekLine({{"CQH_TPAPON","05"}}) //Orçado.
			nValOrc := oAuxCQH:GetValue("CQH_VALOR")
			//
			If oAuxCQH:SeekLine({{"CQH_TPAPON","01"}}) //Incorrido.
				aRet[1] := '02'
				aRet[2] := nValOrc - oAuxCQH:GetValue("CQH_VALOR")
			EndIf
		EndIf
	EndIf
	
Return aRet

/*/{Protheus.doc} C750AddPOC.
Calcula os valores do POC.
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750AddPOC(oModel)
	Local oAuxCQF 	:= oModel:GetModel('CQFDETAIL')
	Local oAuxCQH 	:= oModel:GetModel('CQHDETAIL')
	Local nValOrc 	:= 0
	Local aRet		:= aRet := {0,0}
	
	//1 - Proporção do custo incorrido
	If 	oAuxCQF:GetValue("CQF_METPOC") == "1"
		
		If !oAuxCQH:SeekLine({{"CQH_TPAPON","07"}}) //POC
			
			If oAuxCQH:SeekLine({{"CQH_TPAPON","05"}}) //Orçado.
				nValOrc := oAuxCQH:GetValue("CQH_VALOR")
				
				If oAuxCQH:SeekLine({{"CQH_TPAPON","01"}}) //Incorrido.
					aRet[1] := '07'
					aRet[2] := (oAuxCQH:GetValue("CQH_VALOR") / nValOrc) * 100
				EndIf
			EndIf
		EndIf
	Else
		
		If oAuxCQH:SeekLine({{"CQH_TPAPON","06"}}) //POC
			aRet[1] := '07'
			aRet[2] := oAuxCQH:GetValue('CQH_PERCEN')
		EndIf
	EndIf
	
Return aRet

/*/{Protheus.doc} C750CtbMov.
Contabilização off-line dos movimentos gerados.
@param Objeto com dados da tela de processamento
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750CtbMov(oSelf)
	Local cPadrao 		:= '8B1'
	Local cLote			:= LoteCont('ATF')
	Local cRotina		:= 'CTBA750'
	Local cArquivo		:= ''
	Local nHdlPrv		:= 0
	Local nTotal		:= 0
	Local lMostra		:= MV_PAR03 == 1
	Local lAglutina 	:= MV_PAR04 == 1
	Local cQuery 		:= ''
	Local cAliasCTB		:= GetNextAlias()
	Local oModel		:= FWLoadModel('CTBA750')
	Local oAuxCQF		:= Nil
	Local oAuxCQG		:= Nil
	Local oAuxCQH		:= Nil
	Local oAuxCQI		:= Nil
	Local nX,nY	 		:= 0
	Local lRet			:= .T.
	
	//MV_PAR01 - Apuração de
	//MV_PAR02 - Apuração até
	//MV_PAR03 - Mostra Lançamentos
	//MV_PAR04 - Aglutina Lançamentos
	//MV_PAR05 - Data Inicial
	//MV_PAR06 - Data Final
	
	cQuery += "SELECT CQE_CODAPU FROM " + RetSqlName("CQE") + " CQE "
	cQuery += "INNER JOIN " + RetSqlName("CQF") + " ON CQE_CODAPU = CQF_CODAPU "
	cQuery += "INNER JOIN " + RetSqlName("CQG") + " ON CQF_CODAPU = CQG_CODAPU AND CQG_STATUS = '1' " //Não contabilizados.
	cQuery += "AND CQE.CQE_FILIAL = '" + xFilial("CQE") + "'"
	cQuery += "AND CQE.CQE_STATUS = '1' AND CQE.D_E_L_E_T_ = ' ' " //Efetivado.
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTB,.T.,.T.)
	dbSelectArea(cAliasCTB)
	(cAliasCTB)->(dbGoTop())
	
	oSelf:SaveLog(STR0022)
	
	While (cAliasCTB)->(!Eof())
		
		// Função que verifica se o lançamento padrão foi configurado pelo cliente
		If VerPadrao(cPadrao)
			// Rotina que abre o capa do lote contábil ( Inicio da Contabilização)
			nHdlPrv := HeadProva(cLote,cRotina,Substr(cUsername,1,6),@cArquivo)
		EndIf
		
		oSelf:SetRegua1((cAliasCTB)->(Recno()))
		oSelf:IncRegua1( STR0023  + cValToChar((cAliasCTB)->CQE_CODAPU ))
		//
		CQE->(dbSeek( xFilial('CQE') + (cAliasCTB)->CQE_CODAPU ))
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		oAuxCQF := oModel:GetModel('CQFDETAIL')
		oAuxCQG := oModel:GetModel('CQGDETAIL')
		oAuxCQH := oModel:GetModel('CQHDETAIL')
		oAuxCQI := oModel:GetModel('CQIDETAIL')
		
		For nX := 1 To oAuxCQF:Length() //Tipos de Saldo.
			
			oAuxCQG:SeekLine({{"CQG_STATUS"	,"1"}})
			oAuxCQG:SetValue('CQG_STATUS','2')
			//Movimentos
			For nY := 1 To oAuxCQI:Length()
				oAuxCQI:SetLine( nY )
				CQI->(dbGoto(oAuxCQI:GetDataId(nY)))
				If nHdlPrv > 0 .AND. Empty(oAuxCQI:GetValue('CQI_DTCTB'))
					// Função que interpreta todas as sequencias de lançamento configurada pelo usuário e cria as linhas de lançamento contábil
					// Executada uma vez para cada registro que quer ser contabilizado
					oAuxCQI:SetValue('CQI_DTCTB', dDataBase)
					nTotal += DetProva(nHdlPrv,cPadrao,cRotina,cLote,,,,,,,,/*@aFlagCTB*/)
				EndIf
			Next nY
			
		Next nX
		
		If nHdlPrv > 0 .And. ( nTotal > 0 )
			// Função que fecha o lote contábil
			RodaProva(nHdlPrv, nTotal)
			// Função que apresenta a tela de contabilização, realiza aglutinação caso necessária e grava o documento contábil ( CT2 )
			lRet := cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglutina)
		Else
			lRet := .F.
		EndIf
		
		(cAliasCTB)->(DbSkip())
		oModel:SetValue('CQEMASTER','CQE_STATUS','3')
		//
		If lRet
			FWFormCommit( oModel )
		EndIf
		oModel:DeActivate()
		
	EndDo
	
	//Exclui arquivos.
	(cAliasCTB)->(dbCloseArea())
	FErase((cAliasCTB) + GetDbExtension())
	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil
	
Return

/*/{Protheus.doc} C750CtbEst.
Exclusão dos movimentos e apontamentos.
@param Objeto com dados da tela de processamento
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750CtbEst(oSelf)
	Local cPadrao 		:= '8B2'
	Local cLote			:= LoteCont('ATF')
	Local cRotina		:= 'CTBA750'
	Local cArquivo		:= ''
	Local nHdlPrv		:= 0
	Local nTotal		:= 0
	Local lMostra		:= MV_PAR03 == 1
	Local lAglutina 	:= MV_PAR04 == 1
	Local cQuery 		:= ''
	Local cAliasCTB		:= GetNextAlias()
	Local oModel		:= FWLoadModel('CTBA750')
	Local oAuxCQF		:= Nil
	Local oAuxCQG		:= Nil
	Local oAuxCQH		:= Nil
	Local oAuxCQI		:= Nil
	Local nX,nY,nA 		:= 0
	Local lRet			:= .T.
	
	//MV_PAR01 - Apuração de
	//MV_PAR02 - Apuração até
	//MV_PAR03 - Mostra Lançamentos
	//MV_PAR04 - Aglutina Lançamentos
	//MV_PAR05 - Data Inicial
	//MV_PAR06 - Data Final
	
	cQuery += "SELECT CQE_CODAPU FROM " + RetSqlName("CQE") + " CQE "
	cQuery += "INNER JOIN " + RetSqlName("CQF") + " ON CQE_CODAPU = CQF_CODAPU "
	cQuery += "INNER JOIN " + RetSqlName("CQG") + " ON CQF_CODAPU = CQG_CODAPU AND CQG_STATUS = '2' " //Contabilizados.
	cQuery += "AND CQE.CQE_FILIAL = '" + xFilial("CQE") + "'"
	cQuery += "AND CQE.D_E_L_E_T_ = ' ' " //Efetivado.
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCTB,.T.,.T.)
	dbSelectArea(cAliasCTB)
	(cAliasCTB)->(dbGoTop())
	
	oSelf:SaveLog("Iniciando processo de contabilização off-line.")
	
	While (cAliasCTB)->(!Eof())
		
		oSelf:SetRegua1((cAliasCTB)->(Recno()))
		oSelf:IncRegua1( "Processando..."  + cValToChar((cAliasCTB)->CQE_CODAPU ))
		//
		CQE->(dbSeek( xFilial('CQE') + (cAliasCTB)->CQE_CODAPU ))
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		oModel:Activate()
		
		oAuxCQF := oModel:GetModel('CQFDETAIL')
		oAuxCQG := oModel:GetModel('CQGDETAIL')
		oAuxCQH := oModel:GetModel('CQHDETAIL')
		oAuxCQI := oModel:GetModel('CQIDETAIL')
		
		//Exclusão.
		If VerPadrao(cPadrao)
			// Rotina que abre o capa do lote contábil ( Inicio da Contabilização)
			nHdlPrv := HeadProva(cLote,cRotina,Substr(cUsername,1,6),@cArquivo)
		EndIf
		
		For nX := 1 To oAuxCQF:Length() //Tipos de Saldo.
			
			//Apenas o ultimo periodo contabilizados pode ser estornado
			If oAuxCQG:GetValue("CQG_STATUS",oAuxCQG:Length()) == "2" //Contabilizados
				
				oAuxCQG:GoLine( oAuxCQG:Length() )
				//Movimentos
				For nY := 1 To oAuxCQI:Length()
					oAuxCQI:SetLine( nY )
					CQI->(dbGoto(oAuxCQI:GetDataId(nY)))
					If nHdlPrv > 0 .AND. !Empty(oAuxCQI:GetValue('CQI_DTCTB'))
						// Função que interpreta todas as sequencias de lançamento configurada pelo usuário e cria as linhas de lançamento contábil
						// Executada uma vez para cada registro que quer ser contabilizado
						nTotal += DetProva(nHdlPrv,cPadrao,cRotina,cLote,,,,,,,,/*@aFlagCTB*/)
					EndIf
					
				Next nY
			EndIf
		Next nX
		
		If nHdlPrv > 0 .And. ( nTotal > 0 )
			// Função que fecha o lote contábil
			RodaProva(nHdlPrv, nTotal)
			// Função que apresenta a tela de contabilização, realiza aglutinação caso necessária e grava o documento contábil ( CT2 )
			lRet := cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglutina)
		Else
			lRet := .F.
		EndIf
		
		If lRet
			//Exclui os movimentos e apontamentos.
			For nA := 1 To oAuxCQH:Length()
				oAuxCQH:SetLine(nA)
				oAuxCQH:DeleteLine()
			Next nA
			//Exclui os movimentos e apontamentos.
			For nA := 1 To oAuxCQI:Length()
				oAuxCQI:SetLine(nA)
				oAuxCQI:DeleteLine()
			Next nA
			oModel:SetValue('CQEMASTER','CQE_STATUS','2') //Apontamento Pendente.
			//
			FWFormCommit( oModel )
			oModel:DeActivate()
		EndIf
		
		(cAliasCTB)->(DbSkip())
		
	EndDo
	
	//Exclui arquivos.
	(cAliasCTB)->(dbCloseArea())
	FErase((cAliasCTB) + GetDbExtension())
	oModel:DeActivate()
	oModel:Destroy()
	oModel := Nil
	
Return

/*/{Protheus.doc} C750DifPer.
Calcula diferenca dos valores para periodos passados.
@param Modelo de dados
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750DifPer(oModel)
	Local oAuxCQG := oModel:GetModel('CQGDETAIL')
	Local oAuxCQH := oModel:GetModel('CQHDETAIL')
	Local aValores:= {}
	Local nLinAtu := oAuxCQG:GetLine()
	Local nX	  := 0
	Local nPos	  := 0
	
	oAuxCQG:GoLine( oAuxCQG:GetLine() - 1 )
	For nX := 1 To oAuxCQH:Length()
		aAdd( aValores, { oAuxCQH:GetValue('CQH_TPAPON' , nX) , oAuxCQH:GetValue('CQH_VALOR' , nX) , oAuxCQH:GetValue('CQH_PERCEN' , nX) } )
	Next nX
	oAuxCQG:GoLine( nLinAtu )
	
	//Custo Incorrido.
	If oAuxCQH:SeekLine( {{'CQH_TPAPON','01'}} )
		
		If (nPos := AScan( aValores, { |x| x[1] == "01" } ) ) > 0
			oAuxCQH:SetValue('CQH_DIFPER', ((oAuxCQH:GetValue('CQH_VALOR') - aValores[nPos][2] ) / aValores[nPos][2]) * 100     )
		EndIf
		
	EndIf
	//Custo a Incorrer.
	If oAuxCQH:SeekLine({{'CQH_TPAPON','02'}})
		
		If (nPos := AScan( aValores, { |x| x[1] == "02" } ) ) > 0
			oAuxCQH:SetValue('CQH_DIFPER', ((oAuxCQH:GetValue('CQH_VALOR') - aValores[nPos][2] ) / aValores[nPos][2]) * 100     )
		EndIf
		
	EndIf
	//Faturamento do Contrato.
	If oAuxCQH:SeekLine({{'CQH_TPAPON','03'}})
		
		If (nPos := AScan( aValores, { |x| x[1] == "03" } ) ) > 0
			oAuxCQH:SetValue('CQH_DIFPER', ((oAuxCQH:GetValue('CQH_VALOR') - aValores[nPos][2] ) / aValores[nPos][2]) * 100     )
		EndIf
		
	EndIf
	//Preço do Contrato.
	If oAuxCQH:SeekLine({{'CQH_TPAPON','04'}})
		
		If (nPos := AScan( aValores, { |x| x[1] == "04" } ) ) > 0
			oAuxCQH:SetValue('CQH_DIFPER', ((oAuxCQH:GetValue('CQH_VALOR') - aValores[nPos][2] ) / aValores[nPos][2]) * 100     )
		EndIf
		
	EndIf
	//Custo Orçado.
	If oAuxCQH:SeekLine({{'CQH_TPAPON','05'}})
		
		If (nPos := AScan( aValores, { |x| x[1] == "05" } ) ) > 0
			oAuxCQH:SetValue('CQH_DIFPER', ((oAuxCQH:GetValue('CQH_VALOR') - aValores[nPos][2] ) / aValores[nPos][2]) * 100     )
		EndIf
		
	EndIf
	//Avanço Fisico.
	If oAuxCQH:SeekLine({{'CQH_TPAPON','06'}})
		
		If (nPos := AScan( aValores, { |x| x[1] == "06" } ) ) > 0
			oAuxCQH:SetValue('CQH_DIFPER', ((oAuxCQH:GetValue('CQH_VALOR') - aValores[nPos][2] ) / aValores[nPos][2]) * 100     )
		EndIf
		
	EndIf
	
	//POC.
	If oAuxCQH:SeekLine({{'CQH_TPAPON','07'}})
		
		If (nPos := AScan( aValores, { |x| x[1] == "07" } ) ) > 0
			oAuxCQH:SetValue('CQH_DIFPER', oAuxCQH:GetValue('CQH_PERCEN') - aValores[nPos][3] )
		EndIf
		
	EndIf
	
	//Limpa da Memoria.
	aSize(aValores,0)
	aValores := {}
	
Return

/*/{Protheus.doc} C750Folder.
Controle de exibição da aba de movimentos.
@param Modelo de dados
@author william.gundim
@since 12/02/2015
@version 1.0
/*/
Function C750Folder(oModel)
	Local oView	:= FWViewActive()
	
	//Movimentos para serem exibidos.
	If oModel:GetModel('CQIDETAIL'):IsEmpty()
		oView:HideFolder('FOLDER',2,2)
	Else
		oView:SelectFolder('FOLDER',2,2)
	EndIf
	oView:SelectFolder('FOLDER',1,2)
	
Return .T.
