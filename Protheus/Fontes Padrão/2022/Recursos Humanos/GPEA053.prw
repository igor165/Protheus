#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GPEA053.CH'

/*/{Protheus.doc} GPEA053
	ROTINA RESPONSÁVEL PELA GERAÇÃO DE FÉRIAS PROGRAMADAS EM LOTE
@author PHILIPE.POMPEU
@since 30/03/2016
@version P11
@return Nil, Sem retorno
/*/
Function GPEA053()
	Local nPercReduc:= 15
	Local cPergunte	:= "GPEA053"
	Local oModelAct	:= Nil
	Private lCanEdit:= .T.
	
	if(Pergunte(cPergunte,.T.))

		oModelAct	:= ModelDef() 
		oModelAct:SetOperation(MODEL_OPERATION_INSERT)
		oModelAct:Activate()

		if(OnLoad(oModelAct:GetModel('SRADETAIL')))
			lCanEdit := .F.				
			oModelAct:LoadValue('GPEA050_SRF','RF_DATAINI',Date())
			oModelAct:LoadValue('GPEA050_SRF','RF_DATAINI',cToD("//"))
			oModelAct:GetModel("SRADETAIL"):lInsertLine := .F.	
			FWExecView(OemToAnsi(STR0002),'GPEA053', MODEL_OPERATION_INSERT,/*oDlg*/,{||.T.},/*bOk*/,nPercReduc,/*aEnableButtons*/,;
			/*bCancel*/,/*cOperatId*/,/*cToolBar*/,oModelAct)
		else
			/*Filtro invalido. Não há dados à serem exibidos.*/
			Help( ,, OemToAnsi(STR0004),, OemToAnsi(STR0005), 1, 0 )
		endIf
	endIf
Return

/*/{Protheus.doc} ModelDef
	Definição do modelo de dados da rotina
@author philipe.pompeu
@since 30/03/2016
@version P11
@return oModel, instância da classe MPFormModel
/*/
Static Function ModelDef()
	Local cCampos		:= 'RF_DATAINI|RF_DFEPRO1|RF_DABPRO1|RF_DATINI2|RF_DFEPRO2|RF_DABPRO2|RF_DATINI3|RF_DFEPRO3|RF_DABPRO3|RF_TEMABPE|RF_ABOPEC'
	Local oStructMst	:= FWFormStruct( 1, 'SRF',{|x| Alltrim(x) $ cCampos}, /*lViewUsado*/ )
	Local oStructGrd 	:= FWFormStruct( 1, 'SRA',{|x|Alltrim(x) $ 'RA_FILIAL|RA_MAT|RA_NOME|RA_CC|RA_DEPTO'})
	Local oModel := Nil
	Local bCommit := {|x|OnCommit(x)}

	oStructGrd:SetProperty( '*' , MODEL_FIELD_WHEN,{||CanEdit()})

	oStructGrd:AddField(STR0006, STR0006, "RA_DESCCC", "C", TamSx3("CTT_DESC01")[1], 0, {||.T.},;
						 /*bWhen*/, /*aValues*/, /*lObrigat*/, /*bInit*/, /*lKey*/, .T., .T.)
	oStructGrd:AddField(STR0007, STR0007, "RA_DDEPTO", "C", TamSx3("QB_DESCRIC")[1], 0, {||.T.},;
						 {||}, /*aValues*/, /*lObrigat*/, /*bInit*/, /*lKey*/, .T., .T.)

	oModel := MPFormModel():New('GPEA053', /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )
	oModel:AddFields('GPEA050_SRF', /*cOwner*/,oStructMst)
	oModel:AddGrid('SRADETAIL', 'GPEA050_SRF', oStructGrd, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*bLoad*/)
	oModel:SetRelation('SRADETAIL', {{'RA_FILIAL','RF_FILIAL' },{'RA_MAT','RF_MAT'}}, SRA->(IndexKey(1))) //relacao generica. A carga dos registro eh feita pelo grupo de perguntas
	oModel:SetPrimaryKey({})

	oModel:SetDescription(OemToAnsi(STR0001))
Return (oModel)

/*/{Protheus.doc} ViewDef
	Definição da interface visual da rotina
@author philipe.pompeu
@since 30/03/2016
@version P11
@return oView, instância da classe FWFormView
/*/
Static Function ViewDef()
	Local cCampos		:= 'RF_DATAINI|RF_DFEPRO1|RF_DABPRO1|RF_DATINI2|RF_DFEPRO2|RF_DABPRO2|RF_DATINI3|RF_DFEPRO3|RF_DABPRO3|RF_TEMABPE|RF_ABOPEC'
	Local oStructMst 	:= FWFormStruct( 2, 'SRF' ,{|x| Alltrim(x) $ cCampos})
	Local oModel		:= FWLoadModel( 'GPEA053' )
	Local oView			:= Nil
	Local oStructGrd	:= Nil

	oView := FWFormView():New()
	oView:SetModel(oModel)


	oStructGrd 	:= FWFormStruct(2, 'SRA',{|x|Alltrim(x) $ 'RA_FILIAL|RA_MAT|RA_NOME|RA_CC|RA_DEPTO'})

	oStructGrd:AddField('RA_FILIAL'	,'01'	,STR0008, STR0008 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStructGrd:AddField('RA_DESCCC'	,'05'	,STR0006, STR0006 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStructGrd:AddField('RA_DDEPTO'	,'06'	,STR0007, STR0007 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)

	oStructGrd:SetProperty('RA_FILIAL' 	, MVC_VIEW_ORDEM,'01')
	oStructGrd:SetProperty('RA_MAT' 	, MVC_VIEW_ORDEM,'02')
	oStructGrd:SetProperty('RA_NOME' 	, MVC_VIEW_ORDEM,'03')
	oStructGrd:SetProperty('RA_CC' 		, MVC_VIEW_ORDEM,'04')
	oStructGrd:SetProperty('RA_DESCCC'	, MVC_VIEW_ORDEM,'05')
	oStructGrd:SetProperty('RA_DEPTO'	, MVC_VIEW_ORDEM,'06')
	oStructGrd:SetProperty('RA_DDEPTO'	, MVC_VIEW_ORDEM,'07')

	oView:AddField( 'VIEW_MASTER', oStructMst, 'GPEA050_SRF' )
	oView:AddGrid(  'VIEW_GRID'	 , oStructGrd, 'SRADETAIL' )
	oView:EnableTitleView('VIEW_GRID',OemToAnsi(STR0003))

	oView:CreateHorizontalBox( 'SUPERIOR'	, 30 )
	oView:CreateHorizontalBox( 'INFERIOR'	, 70 )
	oView:SetOwnerView( 'VIEW_MASTER', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_GRID', 'INFERIOR' )
Return (oView)

/*/{Protheus.doc} OnLoad
	Carrega os registros no Grid do Modelo
@author philipe.pompeu
@since 30/03/2016
@version P11
@param oGridModel, objeto, instância da classe FwFormGridModel
@return lResult, .T. se carregado com sucesso
/*/
Static Function OnLoad(oGridModel)
	Local aArea		:= GetArea()
	Local cMyAlias	:= GetNextAlias()
	Local cQuery	:= ""
	Local nLine		:= 0
	Local lResult	:= .T.
	Local nI 		:= 0
	Local cIn		:=	''
	Local nTam		:= 1

	cQuery	:= "SELECT RA_FILIAL,RA_MAT,RA_NOME,RA_CC,RA_DEPTO,CTT_DESC01 AS RA_DESCCC,QB_DESCRIC AS RA_DDEPTO FROM " + RetSqlName("SRA") + " SRA" 
	cQuery	+= " INNER JOIN "+ RetSqlName("CTT") + " CTT ON(" + FWJoinFilial("CTT", "SRA") + " AND CTT_CUSTO = SRA.RA_CC AND CTT.D_E_L_E_T_ = '')" 
	cQuery	+= " LEFT  JOIN "+ RetSqlName("SQB") + " SQB ON(" + FWJoinFilial("SQB", "SRA") + " AND QB_DEPTO = SRA.RA_DEPTO AND SQB.D_E_L_E_T_ = '')"
	cQuery	+= " WHERE SRA.D_E_L_E_T_ = ''"

	if!(Empty(MV_PAR01) .And. Empty(MV_PAR02))	
		cQuery	+= " AND RA_FILIAL BETWEEN '"+ MV_PAR01 + "' AND '" + MV_PAR02 + "'"
	endIf

	if!(Empty(MV_PAR03) .And. Empty(MV_PAR04))	
		cQuery	+= " AND RA_CC BETWEEN '"+ MV_PAR03 + "' AND '" + MV_PAR04 + "'"
	endIf

	if!(Empty(MV_PAR05) .And. Empty(MV_PAR06))	
		cQuery	+= " AND RA_DEPTO BETWEEN '"+ MV_PAR05 + "' AND '" + MV_PAR06 + "'"	
	endIf

	if!(Empty(MV_PAR07) .And. Empty(MV_PAR08))	
		cQuery	+= " AND RA_MAT BETWEEN '"+ MV_PAR07 + "' AND '" + MV_PAR08 + "'"
	endIf

	cIn := ""
	nTam := TamSx3('RA_CATFUNC')[1]
	for nI:= 1 to Len(MV_PAR09)
		cIn += "'"+ SubStr(MV_PAR09,nI,nTam) + "'"
		if(nI < Len(MV_PAR09))
			cIn += ","
		endIf
	next nI

	cQuery += " AND RA_CATFUNC IN(" + cIn + ")"

	cIn := ""
	nTam := TamSx3('RA_SITFOLH')[1]
	for nI:= 1 to Len(MV_PAR10)
		cIn += "'"+ SubStr(MV_PAR10,nI,nTam) + "'"
		if(nI < Len(MV_PAR10))
			cIn += ","	
		endIf
	next nI

	cQuery += " AND RA_SITFOLH IN(" + cIn + ")"

	cQuery	+= " ORDER BY RA_FILIAL,RA_MAT,RA_CC"

	cQuery	:= ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cMyAlias, .F., .T.)

	if((cMyAlias)->(! Eof()))

		while ( (cMyAlias)->(!Eof()) )

			if(nLine == 0)
				nLine++
			Else
				nLine := oGridModel:AddLine()
			endIf
			oGridModel:GoLine(nLine)

			if(nLine > 0)
				oGridModel:GoLine(nLine)
				oGridModel:LoadValue('RA_FILIAL',(cMyAlias)->RA_FILIAL)
				oGridModel:LoadValue('RA_MAT'	,(cMyAlias)->RA_MAT)
				oGridModel:LoadValue('RA_NOME'	,(cMyAlias)->RA_NOME)
				oGridModel:LoadValue('RA_CC'	,(cMyAlias)->RA_CC)
				oGridModel:LoadValue('RA_DEPTO'	,(cMyAlias)->RA_DEPTO)
				oGridModel:LoadValue('RA_DESCCC',(cMyAlias)->RA_DESCCC)
				oGridModel:LoadValue('RA_DDEPTO',(cMyAlias)->RA_DDEPTO)
			endIf

			(cMyAlias)->(dbSkip())
		End

	Else 
		lResult := .F.
	EndIf		
	(cMyAlias)->(dbCloseArea())	

	RestArea(aArea)
Return (lResult)

/*/{Protheus.doc} OnCommit
	Salva as alterações no banco de dados
@author PHILIPE.POMPEU
@since 30/03/2016
@version P11
@param oModel, objeto, instância da classe MPFormModel
@return lResult, .T. se salvo com sucesso.
/*/
Static Function OnCommit(oModel)
	Local aArea		:= GetArea()
	Local oGrid		:= oModel:GetModel("SRADETAIL")
	Local nI 		:= 0
	Local lResult	:= .T.
	Local cChave	:= ""
	Local oHead		:= oModel:GetModel("GPEA050_SRF")
	Local aCampos	:= {}
	Local aLogErros := {}
	Local aLog		:= {}
	Local aTitleLog := {}
	Local nX		:= 0
	Local lGrava    := .T.
	Local lProg1	:= .T.
	Local lProg2	:= .T.
	Local lProg3 	:= .T.
	Local lNsobrepoe := valtype(MV_PAR11) <> "N" .or. (valtype(MV_PAR11) == "N" .and. MV_PAR11 == 2)

	aCampos := oHead:GetStruct()
	aCampos := aCampos:GetFields()

	SRF->(dbSetOrder(1))
	for nI:= 1 to oGrid:Length()
		oGrid:GoLine(nI)		
		if(!oGrid:IsDeleted())
			cChave := oGrid:GetValue('RA_FILIAL')
			cChave += oGrid:GetValue('RA_MAT') 
			
			if(SRF->(dbSeek(cChave))) 
				While SRF->( !EoF() ) .And. cChave == SRF->RF_FILIAL + SRF->RF_MAT 
					if SRF->RF_STATUS == "1"
						lProg1 := .T.
						lProg2 := .T.
						lProg3 := .T.
						lGrava := .T.
					
						if lNsobrepoe // não sobrepoe
							//Se a data da nova programação confrontar com a programação existente, 
							//não deve realizar a nova programação.
							if !empty(SRF->RF_DATAINI ) .and. !empty(oHead:GetValue('RF_DATAINI'))
								aAdd( aLogErros,SRF->RF_MAT  + chr(13) + chr(10) + OemToAnsi(STR0014) + chr(13) + chr(10) + OemToAnsi(STR0013) + chr(13) + chr(10) ) 
								lProg1 := .F.
							endif

							if !empty(SRF->RF_DATINI2 )  .and. !empty(oHead:GetValue('RF_DATINI2'))
								aAdd( aLogErros,SRF->RF_MAT  + chr(13) + chr(10) + OemToAnsi(STR0015) + chr(13) + chr(10) + OemToAnsi(STR0013) + chr(13) + chr(10) ) 
								lProg2 := .F.
							endif

							if !empty(SRF->RF_DATINI3 ) .and. !empty(oHead:GetValue('RF_DATINI3'))
								aAdd( aLogErros,SRF->RF_MAT  + chr(13) + chr(10) + OemToAnsi(STR0016) + chr(13) + chr(10) + OemToAnsi(STR0013) + chr(13) + chr(10) ) 
								lProg3 := .F.
							endif
						endif

						If lProg1 .OR. lProg2 .OR. lProg3
							lGrava := .T.
						else
							lGrava	:= .F.
						Endif

						If oHead:GetValue('RF_DATAINI') <= SRF->RF_DATABAS  
							//A Data de Inicio da programacao deve ser maior que a Data de Inicio do Periodo
							aAdd( aLogErros,SRF->RF_MAT + chr(13) + chr(10) + OemToAnsi(STR0009) + chr(13) + chr(10) ) 
							lGrava := .F.
						Endif

						If (oHead:GetValue('RF_DFEPRO1') + oHead:GetValue('RF_DABPRO1') + oHead:GetValue('RF_DFEPRO2') + oHead:GetValue('RF_DABPRO2') + oHead:GetValue('RF_DFEPRO3') + oHead:GetValue('RF_DABPRO3')) + SRF->RF_DFERANT > 30
								//"A quantidade de dias de férias e dias de abono das três programações ultrapassam 30 dias."
							aAdd( aLogErros,SRF->RF_MAT + chr(13) + chr(10) + OemToAnsi(STR0010) + chr(13) + chr(10) ) 
							lGrava := .F.
						EndIf

						If lGrava
							RecLock("SRF",.F.)
								for nX := 1 to len( aCampos )
									if (aCampos[nX][3] == "RF_DATAINI" .or. aCampos[nX][3] == "RF_DFEPRO1") 
										if lProg1
											SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nx][3])
										endif
									elseif (aCampos[nX][3] == "RF_DATINI2" .or. aCampos[nX][3] == "RF_DFEPRO2")  
										if lProg2
											SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nx][3])
										endif
									elseif (aCampos[nX][3] == "RF_DATINI3" .or. aCampos[nX][3] == "RF_DFEPRO3")
										if lProg3
											SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nx][3])
										endif
									else
										SRF->&(aCampos[nX][3]) := oHead:GetValue(aCampos[nx][3])
									EndIF
								next nx
							SRF->(MsUnLock())
						EndIf

						Exit

					Endif
					SRF->( dbSkip() )
				End While
			endIf	
		endIf
	next nI
	
	
	If Len( aLogErros ) > 0
		If Empty( aLog )
			aAdd( aTitleLog, OemToAnsi(STR0011) ) // 'Matrículas não alteradas:'
			aAdd( aLog, {} )
		EndIf
	
		nPosLog := Len( aLog )
		For nX := 1 To Len( aLogErros )
			aAdd( aLog[ nPosLog ], aLogErros[ nX ] )
		Next nX
	EndIf
		
	If !Empty( aLog )
		MsAguarde( { || fMakeLog( aLog , aTitleLog , "GPEA053" , NIL , FunName() ,STR0001  ) }  )
	EndIf
	
	RestArea(aArea)
Return lResult

/*/{Protheus.doc} CanEdit
	Avalia se é possível alterar as células do grid ou não
@author PHILIPE.POMPEU
@since 30/03/2016
@version P11
@return lResult, Verdadeiro se é possível editar
/*/
Static Function CanEdit()
	Local lResult := .T.	
	if!(ValType("lCanEdit") == "U")/*Caso o modelo seja chamado de outro lugar!*/
		lResult := lCanEdit
	endIf
Return lResult
