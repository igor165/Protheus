#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#Include 'FINA694A.CH'

Static _FINA694A1

/*/{Protheus.doc} ViewDef
Inteface do modelo de dados.
@author William Matos
@since 30/10/15
/*/
Static Function ViewDef()
Local oView 	:= FWLoadView("FINA694")
Local oStr  	:= oView:GetViewStruct("VIEW_FWN")
Local nPos		:= Val(oStr:GetProperty("SEPCOL", MVC_VIEW_ORDEM))
Local oModel	:= ModelDef()
Local aCpos 	:= {"FLH_CC","FWN_IDRESE","FWN_CCUSTO","FWN_NUMFAT"}
Local nA 		:= 0 

	oView:SetModel(oModel)
	oStr:SetProperty("FL6_TOTAL", MVC_VIEW_ORDEM, AllTrim(Str(++nPos)) )			   
	oStr:SetProperty("FL6_IDRESE"	,MVC_VIEW_LOOKUP,"RESHTL")
	//

	For nA := 1 To Len(aCpos)
	
		oStr:RemoveField(aCpos[nA])
		
	Next nA
	aSize(aCpos, 0)
	
Return oView

/*/{Protheus.doc} ModelDef
Modelo de dados.
@author William Matos
@since 30/10/15
/*/
Static Function ModelDef()
Local oModel := FWLoadModel("FINA694")
Local oStr	 := oModel:GetModel("FWNDETAIL"):GetStruct()

	//Campo memo XML.							
	oStr:AddField(			 "";
							,"";
							,"FWN_XML";
							,"M";
							,10;
							,0;
							,{|| .T.};
							,NIL;
							,{};
							,NIL;
							,FwBuildFeature(STRUCT_FEATURE_INIPAD,"' '");
							,NIL;
							,NIL;
							,.T.)
								
	
Return oModel

/*/{Protheus.doc} FN694TmpHosp
Arquivo temporario com os pedidos de hoteis.
@author William Matos
@since 30/10/15
/*/
Function  FN694TmpHosp(cNomeArq,cAliasTmp)
Local cQuery	:= ""
Local aEstr		:= {}
Local lRet		:= .F.
Local cAliasFL6	:= GetNextAlias()

	AAdd(aEstr,{"FL9_NOME"  ,"C",TamSX3("FL9_NOME")[1],0})
	AAdd(aEstr,{"FL9_CIDADE","C",TamSX3("FL9_CIDADE")[1],0})
	AAdd(aEstr,{"FL9_DCHKIN","C",TamSX3("FL9_DCHKIN")[1],0})
	AAdd(aEstr,{"FL6_NOMESO","C",TamSX3("FL6_NOMESO")[1],0})
	AAdd(aEstr,{"FL6_VIAGEM","C",TamSX3("FL6_VIAGEM")[1],0})
	AAdd(aEstr,{"FL6_NRCART","C",TamSX3("FL6_NRCART")[1]})
	AAdd(aEstr,{"FL6_IDRESE","C",TamSX3("FL6_IDRESE")[1]})
	AAdd(aEstr,{"FL6_TOTAL" ,"N",TamSX3("FL6_TOTAL")[1],TamSX3("FL6_TOTAL")[2]})	
	AAdd(aEstr,{"RECNO","N",10,0})
	
	cAliasTmp := GetNextAlias()
		
	//Deleta a tabela temporária no banco, caso já exista
	If(_FINA694A1 <> NIL)
		_FINA694A1:Delete()
		_FINA694A1 := NIL
	EndIf
	
	//Cria tabela temporária no banco de dados 
	_FINA694A1 := FwTemporaryTable():New(cAliasTmp)
	_FINA694A1:SetFields(aEstr)
	_FINA694A1:AddIndex("1", {aEstr[1][1]})
	_FINA694A1:Create()
	
	dbSetOrder(0) //ordem natural de inserção
		
	cQuery := "SELECT FL9_NOME, FL9_CIDADE, FL9_DCHKIN, FL6_NOMESO, FL6_IDRESE,FL6_VIAGEM,FL6_NRCART, FL6_TOTAL,FL6.R_E_C_N_O_ RECNO FROM " + RetSQLName("FL6") + " FL6"
	cQuery += " LEFT JOIN " + RetSQLName("FL9") + " FL9 ON "
	cQuery += " FL9_VIAGEM = FL6_VIAGEM "
	cQuery += " AND FL9_FILIAL = '" + xFilial("FL9") + "'"
	cQuery += " AND FL9_CODHOT <> '' "
	cQuery += " WHERE FL6_FILIAL = '" + xFilial("FL6") + "'"
	cQuery += " AND FL6_STATUS != '2'" //Conferida totalmente.
	cQuery += " AND FL6_TIPO = '2'" //Hotel
	cQuery += " AND FL6_NRCART != '' "
	cQuery += " AND FL6.D_E_L_E_T_= ' '"
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasFL6,.F.,.T.)
	While !((cAliasFL6)->(Eof()))
		RecLock(cAliasTmp,.T.)
		Replace (cAliasTmp)->FL9_NOME	With (cAliasFL6)->FL9_NOME
		Replace (cAliasTmp)->FL9_CIDADE	With (cAliasFL6)->FL9_CIDADE
		Replace (cAliasTmp)->FL9_DCHKIN	With (cAliasFL6)->FL9_DCHKIN
		Replace (cAliasTmp)->FL6_NOMESO	With (cAliasFL6)->FL6_NOMESO
		Replace (cAliasTmp)->FL6_IDRESE	With (cAliasFL6)->FL6_IDRESE
		Replace (cAliasTmp)->FL6_VIAGEM	With (cAliasFL6)->FL6_VIAGEM
		Replace (cAliasTmp)->FL6_NRCART	With (cAliasFL6)->FL6_NRCART
		Replace (cAliasTmp)->FL6_TOTAL 	With (cAliasFL6)->FL6_TOTAL
		Replace (cAliasTmp)->RECNO		With (cAliasFL6)->RECNO
		MsUnLock()
		(cAliasFL6)->(DbSkip())
	Enddo

(cAliasTmp)->(dbGoTop())
Return

/*/{Protheus.doc} FN694SelH
Consulta especifica para selecionar os hoteis disponiveis para conferencia.
@author William Matos
@since 30/10/15
/*/
Function FN694SelH()
Local cAliasTmp	:= ""
Local cNomeArq	:= ""
Local nReg		:= 0
Local lRet		:= .F.
Local aArea		:= {}
Local oBrwViag	:= Nil
Local oSize		:= Nil
Local oDlg		:= Nil

	aArea := GetArea()
	MsgRun(STR0001,STR0002,{|| FN694TmpHosp(@cNomeArq,@cAliasTmp)}) 
	oSize := FwDefSize():New(.T.)	
	oSize:lLateral := .F.
	oSize:AddObject("MASTER",100,100,.T.,.T.)
	oSize:lProp := .T.
	oSize:Process()
	DEFINE MSDIALOG oDlg TITLE STR0005 From oSize:aWindSize[1]*0.5,oSize:aWindSize[2]*0.5 To oSize:aWindSize[3]*0.5,oSize:aWindSize[4]*0.5 OF oMainWnd PIXEL //"Viagens"
		oBrwViag:= TCBrowse():New(0,0,10,10,,,,oDlg,,,,,,,,,,,,,cAliasTmp,.T.,,,,.T.,)
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL9_NOME"))  ,{|| (cAliasTmp)->FL9_NOME},,,,,040,.F.,.F.,,,,,))
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL9_CIDADE")),{|| (cAliasTmp)->FL9_CIDADE},,,,,040,.F.,.F.,,,,,))
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL9_DCHKIN")),{|| (cAliasTmp)->FL9_DCHKIN},,,,,040,.F.,.F.,,,,,))
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL6_TOTAL")) ,{|| (cAliasTmp)->FL6_TOTAL},PesqPict("FL6","FL6_TOTAL"),,,,040,.F.,.F.,,,,,))	
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL6_NOMESO")),{|| (cAliasTmp)->FL6_NOMESO},,,,,040,.F.,.F.,,,,,))
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL6_IDRESE")),{|| (cAliasTmp)->FL6_IDRESE},,,,,040,.F.,.F.,,,,,))
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL6_VIAGEM")),{|| (cAliasTmp)->FL6_VIAGEM},,,,,040,.F.,.F.,,,,,))
		oBrwViag:AddColumn(TCColumn():New(SX3->(RetTitle("FL6_NRCART")),{|| (cAliasTmp)->FL6_NRCART},,,,,050,.F.,.F.,,,,,))	
		oBrwViag:Align := CONTROL_ALIGN_ALLCLIENT
		oBrwViag:bLDblClick := {|| nReg := (cAliasTmp)->RECNO,lRet := .T.,oDlg:End()} 
		oBrwViag:Refresh()
	ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nReg := (cAliasTmp)->RECNO,lRet := .T.,oDlg:End()},{|| lRet := .F.,oDlg:End()},,) CENTERED 
	DbSelectArea(cAliasTmp)
	DbCloseArea()
	FErase(cNomeArq + GetDBExtension())
	oDlg := Nil
	oBrwViag := Nil
	oSize := Nil
	If lRet 
		FL6->(DbGoTo(nReg))
	Endif
	RestArea(aArea)
	Asize(aArea,0)
	aArea := Nil

Return(lRet)

/*/{Protheus.doc} FN694BUT
Cria botão na inteface para relacionar n viagens a um item do extrato.
@author William Matos
@since 30/10/15
/*/
Function FN694BUT(oPanel)
Local oButton := Nil
	
	@10,2 BUTTON oButton PROMPT STR0003 SIZE 080,012 FONT oPanel:oFont ACTION FN694B() OF oPanel PIXEL

Return 


/*/{Protheus.doc} FN694B
Função cria a view da rotina FINA694B.
@author William Matos
@since 30/10/15
/*/
Function FN694B()
Local oModel		 := FWModelActive()
Local nRet 			 := 0
Local oModelXML		 := Nil
Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	If !Empty(oModel:GetValue("FWNDETAIL","FWN_XML"))
		nRet := FWExecView( STR0004,"FINA694B", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,65, aEnableButtons,/*bCancel*/,/**/,/*cToolBar*/, oModelXML )
	Else
		nRet := FWExecView( STR0004,"FINA694B", MODEL_OPERATION_UPDATE,/**/,/**/,/**/,65, aEnableButtons)
	EndIf
	
Return 
