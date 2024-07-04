#Include "Protheus.ch"
#Include "FwMVCDEF.ch"
#Include "TECA998.ch"

Static oFWSheet
Static oModel740

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECA998
Planilha de cálculo no orçamento de serviços
@sample 	TECA998() 
@param		oModel -> Objeto do modelo
@since		22/10/2013       
@version	P11.9
/*/
//------------------------------------------------------------------------------
Function TECA998(oModel,oView)

Local oMdlRh	:= Nil 
Local oMdlLE	:= Nil
Local cManip	:= ""
Local cRet		:= ""
Local cModelo	:= ""
Local oDlg
Local oOpcao
Local oBtn
Local nOpcao	:= 1
Local nOpcOk	:= 0
Local lLocEq	:= .F. 
Local lOk := .T.
Local lFacilit := IsInCallStack("At984aPlPc")
Local aModPla := {.F.,""}
Local lRet	:= .F.
Local lOrcSrv := At998Orc()
Default oView := Nil

If lFacilit
	oMdlRh	:= oModel:GetModel("TXSDETAIL")
Else
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	If isInCallStack("At870GerOrc")
		If oMdlRh:GetValue("TFF_COBCTR") != "2"
			//Manipular Planilha de item cobrado dentro da rotina de Item Extra
			lOk := .F.
			Help(,, "AT998COBCTR1",,STR0016,1,0,,,,,,{STR0017}) //"Não é possível modificar itens que são cobrados no contrato através da rotina Item Extra" ## "Para alterar este item, realize uma Revisão do Contrato"
		EndIf
	Else
		If oMdlRh:GetValue("TFF_COBCTR") == "2"
			//Manipular Planilha de item não-cobrado fora da rotina de Item Extra
			lOk := .F.
			Help(,, "AT998COBCTR2",,STR0018,1,0,,,,,,{STR0019}) //"Não é possível modificar itens que não são cobrados no contrato nesta rotina" ## "Para alterar este item, acesse a opção Item Extra dentro da Gestão dos Contratos (TECA870)" 
		EndIf
	EndIf
Endif

If lOk

	If oView <> Nil .And. !lFacilit
		lLocEq := Upper(oView:GetFolderActive('ABAS', 2)[2]) == STR0014 // 'LOCAÇÃO DE EQUIPAMENTOS'
	EndIf
	
	If !lLocEq
		If lFacilit
			cManip := oMdlRh:GetValue("TXS_CALCMD")
			cRet := oMdlRh:GetValue("TXS_PLACOD") + oMdlRh:GetValue("TXS_PLAREV")
		Else
			cManip := oMdlRh:GetValue("TFF_CALCMD")
			cRet := oMdlRh:GetValue("TFF_PLACOD") + oMdlRh:GetValue("TFF_PLAREV")
		Endif
	Else	
		cManip		:= oMdlLE:GetValue("TFI_CALCMD")
		cRet 		:= oMdlLE:GetValue("TFI_PLACOD") + oMdlLE:GetValue("TFI_PLAREV")
	EndIf
	
	oModel740 := oModel
	
	DEFINE DIALOG oDlg TITLE STR0001 FROM 00,00 TO 110,130 PIXEL //"Planilha"
		oDlg:LEscClose	:= .F.
		oOpcao				:= TRadMenu():New(05,05,{STR0002,STR0003,STR0004},,oDlg,,,,,,,,45,40,,,,.T.) //'Manipular'#'Executar'#'Novo Modelo'
		oOpcao:bSetGet	:= {|x|IIf(PCount()==0,nOpcao,nOpcao:=x)}
		oBtn				:= TButton():New(35,05,STR0005,oDlg,{|| nOpcOk := 1, nOpcao, oDlg:End()},60,15,,,.F.,.T.,.F.,,.F.,,,.F. ) //'Confirmar'
	ACTIVATE DIALOG oDlg CENTERED
	
	If	nOpcOk == 1
		If Empty(cManip) .OR. nOpcao == 3 .OR. nOpcao == 2

			If (lFacilit .And. nOpcao == 3) .Or. (nOpcao == 3 .And. lOrcSrv)
				aModPla	:= At998InPl()
			Else
				aModPla	:= At998ConsP(cRet)
			Endif
			lRet := aModPla[1]
			cRet := aModPla[2]
			If lRet
				DbSelectArea("ABW")
				DbSetOrder(1) // ABW_FILIAL+ABW_CODIGO+ABW_REVISA
				If ABW->(DbSeek(xFilial("ABW")+cRet))
					cModelo := ABW->ABW_INSTRU
					If nOpcao == 1 .OR. nOpcao == 3
						At998MdPla(cModelo,oModel,lLocEq, cRet)
					Else
						At998ExPla(cModelo,oModel,lLocEq, cRet)
					EndIf	
				EndIf
			EndIf
		Else
			If nOpcao == 1
				At998MdPla(cManip,oModel,lLocEq, cRet)
			Else
				At998ExPla(cManip,oModel,lLocEq, cRet)
			EndIf
		EndIf	
	EndIf
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998MdPla()

Monta a Planilha de cálculo para manipulação. 

@sample 	At998MdPla() 

@param		cXml, Caracter, Conteúdo do XML
			oModel, Object, Classe do modelo de dados MpFormModel   
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998MdPla(cXml,oModel,lLocEq, cCodRev)

Local oFWLayer 
Local oDlg
Local aSize	 		:= FWGetDialogSize( oMainWnd ) 	
Local oWinPlanilha
Local aCelulasBlock := At998Atrib()
Local cTpModelo		:= ABW->ABW_TPMODP
Local aNickBloq		:= {"TOTAL_RH","TOTAL_MAT_CONS","TOTAL_MAT_IMP","LUCRO", "TOTAL_ABATE_INS"}
Local oMdlRh		:= Nil 
Local nTotMI		:= 0 
Local nTotMC		:= 0
Local nTotUnif		:= 0
Local nTotArma		:= 0
Local bExpor		:= {|| TECA997(oFWSheet) }
Local lFacilit 		:= IsInCallStack("At984aPlPc")
Local lOrcSrv 		:= At998Orc()
Local nTamCpoCod 	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev 	:= TamSX3("TFF_PLAREV")[1]

Default cCodRev 	:= ""

If lFacilit
	oMdlRh	:= oModel:GetModel("TXSDETAIL")
	nTotMI	:= oMdlRh:GetValue("TXS_TOTMI")
	nTotMC	:= oMdlRh:GetValue("TXS_TOTMC")	
	nTotUnif:= oMdlRh:GetValue("TXS_TOTUNI")
	nTotArma:= oMdlRh:GetValue("TXS_TOTARM")	
Else
	oMdlRh		:= oModel:GetModel("TFF_RH")
	nTotMI		:= oMdlRh:GetValue("TFF_TOTMI")
	nTotMC		:= oMdlRh:GetValue("TFF_TOTMC")
	If lOrcSrv
		nTotUnif:= oMdlRh:GetValue("TFF_TOTUNI")
		nTotArma:= oMdlRh:GetValue("TFF_TOTARM")		
	Endif
Endif
DEFINE DIALOG oDlg TITLE STR0006 FROM aSize[1],aSize[2] TO aSize[3],aSize[4] PIXEL //"Planilha Preço"

	oFWLayer := FWLayer():New()
	oFWLayer:init( oDlg, .T. )
	oFWLayer:addLine( "Lin02", 100, .T. )
	oFWLayer:setLinSplit( "Lin02", CONTROL_ALIGN_BOTTOM, {|| } )
	oFWLayer:addCollumn("Col01", 100, .T., "Lin02" )
	oFWLayer:addWindow("Col01", "Win02", STR0001, 100,.F., .f., {|| Nil },"Lin02" ) //'Planilha'
	
	oWinPlanilha := oFWLayer:getWinPanel("Col01"	, "Win02" ,"Lin02")

//---------------------------------------
// PLANILHA
//---------------------------------------
oFWSheet := FWUIWorkSheet():New(oWinPlanilha)
IF At680Perm(NIL, __cUserId, "067", .T.)
	oFWSheet:AddItemMenu(STR0007,bExpor) //'Exportar para Excel'
Endif
oFwSheet:SetMenuVisible(.T.,STR0008,50) //"Ações"

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

If !Empty(cXml) 
	If isBlind()
		oFWSheet:LoadXmlModel(cXml)
	Else
		FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cXml)}, Nil, STR0020)//"Carregando..."
	EndIf
EndIf
If lFacilit .Or. lOrcSrv

	If oFWSheet:CellExists("TOTAL_MI")
		oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MC")
		oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
	EndIf
	If oFWSheet:CellExists("TOTAL_UNIF")
		oFWSheet:SetCellValue("TOTAL_UNIF", nTotUnif)
	EndIf
	If oFWSheet:CellExists("TOTAL_ARMA")
		oFWSheet:SetCellValue("TOTAL_ARMA", nTotArma)
	EndIf
	If !Empty(cCodRev)
		If lOrcSrv
			At998VlBnf(oFWSheet,oMdlRh:GetValue("TFF_ESCALA"),;
								oMdlRh:GetValue("TFF_TURNO"),;
								SubString(cCodRev,1,nTamCpoCod),;
								SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		Else
			At998VlBnf(oFWSheet,oMdlRh:GetValue("TXS_ESCALA"),;
								oMdlRh:GetValue("TXS_TURNO"),;
								SubString(cCodRev,1,nTamCpoCod),;
								SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		Endif
	Endif
Else
	If oFWSheet:CellExists("TOTAL_MAT_IMP")
		oFWSheet:SetCellValue("TOTAL_MAT_IMP", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MAT_CONS")
		oFWSheet:SetCellValue("TOTAL_MAT_CONS", nTotMC)
	EndIf	
Endif
//.T. serão bloqueadas as celulas que NÃO estão no array passado aCells 
//.F. serão bloqueadas as celulas que estão no array passado aCells 
If cTpModelo == "1"
	oFWSheet:SetCellsBlock(aCelulasBlock, .T.) //'Lista Liberada'
Else
	oFWSheet:SetCellsBlock(aCelulasBlock, .F.) //'Lista bloqueada' 
EndIf

oFwSheet:SetNamesBlock(aNickBloq)

oFWSheet:Refresh(.T.)

ACTIVATE DIALOG oDlg ON INIT EnchoiceBar(oDlg,{||At998Grv(oModel,lLocEq,cCodRev),oDlg:End()},{||oDlg:End()})
	
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Atrib()

Atribui as células gravadas na lista do modelo da planilha 

@sample 	At998Atrib() 

@return	aCel-> Array, Contém células gravadas na lista. 

@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998Atrib()

Local aArea := GetArea()
Local aCell := {}

DbSelectArea("ABW")
DbSetOrder(1)

If ABW->(DbSeek(xFilial("ABW")+ABW->(ABW_CODIGO+ABW_REVISA)))
	aCell := StrTokArr(ABW->ABW_LISTA,";")
EndIf

RestArea(aArea)

Return aCell

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Grv()

Gravação do xml e do cálculo na planilha do item selecionado.

@sample 	At998Grv() 

@param		oModel, Object, Classe do modelo de dados MpFormModel  
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998Grv(oModel,lLocEq, cCodRev)

Local oMdlRh		:= Nil 
Local oMdlLE		:= Nil 
Local oMdlLEa		:= Nil 
Local cManip		:= ""
Local nTamCpoCod 	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev 	:= TamSX3("TFF_PLAREV")[1]
Local cTotAbINS		:= ""
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lFacilit  	:= IsInCallStack("At984aPlPc")
Local nTotRh 		:= 0
Local nTotPlan		:= 0
Local lOrcSrv		:= At998Orc()
Default lLocEq		:= .F.
Default cCodRev 	:= ""

Default lLocEq 		:= .F.

cManip := oFwSheet:GetXmlModel(,,,,.F.,.T.,.F.)

If lFacilit
	oMdlRh := oModel:GetModel("TXSDETAIL")
	If oFWSheet:CellExists("TOTAL_CUSTOS")
		nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTOS")
	Endif
	If oFWSheet:CellExists("TOTAL_BRUTO")
		nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
	Endif
Else
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	oMdlLEa := oModel:GetModel("TEV_ADICIO")
	If lOrcSrv
		If oFWSheet:CellExists("TOTAL_CUSTOS")
			nTotRh := oFwSheet:GetCellValue("TOTAL_CUSTOS")
		Endif
	Else
		If oFWSheet:CellExists("TOTAL_RH")
			nTotRh := oFwSheet:GetCellValue("TOTAL_RH")	
		Endif
	Endif
	If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
		cTotAbINS := oFwSheet:GetCellValue("TOTAL_ABATE_INS")
	EndIf
Endif

If !Empty(cManip) .AND. oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW .And. !lLocEq
	If lFacilit
		oMdlRh:SetValue("TXS_CALCMD",cManip)
		oMdlRh:SetValue("TXS_VLUNIT",Round(nTotRh, TamSX3("TXS_VLUNIT")[2]))
		oMdlRh:SetValue("TXS_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlRh:SetValue("TXS_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))	
		oMdlRh:SetValue("TXS_TOTPLA",Round(nTotPlan, TamSX3("TXS_TOTPLA")[2]))
	Else
		oMdlRh:SetValue("TFF_CALCMD",cManip)
		oMdlRh:SetValue("TFF_PRCVEN",ROUND(nTotRh, TamSX3("TFF_PRCVEN")[2]))
		oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
	Endif
EndIf

If !lFacilit
	If !Empty(cManip) .AND. lAbtInss
		oMdlRh:SetValue("TFF_ABTINS", cTotAbINS)
	EndIf

	If !Empty(cManip) .AND. oMdlLE:GetOperation() <> MODEL_OPERATION_VIEW .And. lLocEq .And. !Empty(oMdlLE:GetValue("TFI_PRODUT"))
		oMdlLE:SetValue("TFI_CALCMD",cManip)
		oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
		oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		If oFWSheet:CellExists("TOTAL_LE_COB")
			oMdlLEa:SetValue("TEV_MODCOB",if(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
		EndIf
		
		If oFWSheet:CellExists("TOTAL_LE_QUANT")
			oMdlLEa:SetValue("TEV_QTDE", if(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
		EndIf
		
		If oFWSheet:CellExists("TOTAL_LE_VUNIT")
			oMdlLEa:SetValue("TEV_VLRUNI", if(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
		EndIf
	EndIf
Endif

If lCpoCustom
	ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
EndIf

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998ExPla()

Executa o cálculo do modelo da planilha sem visualizar a mesma. 

@sample 	At998ExPla() 

@param		cXml, Caracter, Conteúdo do XML
			oModel, Object, Classe do modelo de dados MpFormModel  
	
@since		22/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Function At998ExPla(cXml, oModel, lLocEq, cCodRev, lReplica)
Local oMdlLA		:= Nil
Local oMdlRh		:= Nil
Local oMdlLE		:= Nil
Local oMdlLEa		:= Nil
Local oMdlTWO		:= Nil
Local nTotMI		:= 0 
Local nTotMC		:= 0
Local nTotUnif		:= 0
Local nTotArma		:= 0
Local nTotal		:= 0
Local nX			:= 0
Local nY			:= 0
Local nTamCpoCod	:= TamSX3("TFF_PLACOD")[1]
Local nTamCpoRev	:= TamSX3("TFF_PLAREV")[1]
Local cTotAbINS 	:= ""
Local lAbtInss		:= TFF->( ColumnPos('TFF_ABTINS') ) > 0 .AND. SuperGetMv("MV_GSDSGCN",,"2") == "1"
Local lCpoCustom	:= ExistBlock('A998CPOUSR')
Local lFacilit   	:= IsInCallStack("At984aPlPc")
Local nTotPlan		:= 0
Local lOrcSrv		:= At998Orc()
Default lLocEq		:= .F.
Default cCodRev 	:= ""
Default lReplica 	:= .F.

oFWSheet := FWUIWorkSheet():New(,.F. ) //instancia a planilha sem exibição

If MethIsMemberOf(oFWSheet,"ShowAllErr")
	oFWSheet:ShowAllErr(.F.)
EndIf

If isBlind()
	oFwSheet:LoadXmlModel(cXml)
Else
	FwMsgRun(Nil,{|| oFWSheet:LoadXmlModel(cXml)}, Nil, STR0020)//"Carregando..."
EndIf
If lFacilit 

	oMdlRh := oModel:GetModel("TXSDETAIL")
	nTotMI := oMdlRh:GetValue("TXS_TOTMI")
	nTotMC := oMdlRh:GetValue("TXS_TOTMC")
	nTotUnif:= oMdlRh:GetValue("TXS_TOTUNI")
	nTotArma:= oMdlRh:GetValue("TXS_TOTARM")

	If oFWSheet:CellExists("TOTAL_MI")
		oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
	EndIf	
	If oFWSheet:CellExists("TOTAL_MC")
		oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
	EndIf
	If oFWSheet:CellExists("TOTAL_UNIF")
		oFWSheet:SetCellValue("TOTAL_UNIF", nTotUnif)
	EndIf
	If oFWSheet:CellExists("TOTAL_ARMA")
		oFWSheet:SetCellValue("TOTAL_ARMA", nTotArma)
	EndIf
	If !Empty(cCodRev)
		At998VlBnf(oFWSheet,oMdlRh:GetValue("TXS_ESCALA"),;
							oMdlRh:GetValue("TXS_TURNO"),;
							SubString(cCodRev,1,nTamCpoCod),;
							SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
	Endif
Else
	oMdlLA := oModel:GetModel("TFL_LOC")
	oMdlRh := oModel:GetModel("TFF_RH")
	oMdlLE := oModel:GetModel("TFI_LE")
	oMdlLEa := oModel:GetModel("TEV_ADICIO")
	oMdlTWO := oModel:GetModel("TWODETAIL")
	nTotMI := oMdlRh:GetValue("TFF_TOTMI")
	nTotMC := oMdlRh:GetValue("TFF_TOTMC")
	If lOrcSrv
		If oFWSheet:CellExists("TOTAL_MI")
			oFWSheet:SetCellValue("TOTAL_MI", nTotMI)
		EndIf	
		If oFWSheet:CellExists("TOTAL_MC")
			oFWSheet:SetCellValue("TOTAL_MC", nTotMC)
		EndIf
		If oFWSheet:CellExists("TOTAL_UNIF")
			oFWSheet:SetCellValue("TOTAL_UNIF", oMdlRh:GetValue("TFF_TOTUNI"))
		EndIf
		If oFWSheet:CellExists("TOTAL_ARMA")
			oFWSheet:SetCellValue("TOTAL_ARMA", oMdlRh:GetValue("TFF_TOTARM"))
		EndIf
		If !Empty(cCodRev)
			At998VlBnf(oFWSheet,oMdlRh:GetValue("TFF_ESCALA"),;
								oMdlRh:GetValue("TFF_TURNO"),;
								SubString(cCodRev,1,nTamCpoCod),;
								SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
		Endif
	Else
		If oFWSheet:CellExists("TOTAL_MAT_IMP")
			oFWSheet:SetCellValue("TOTAL_MAT_IMP", nTotMI)
		EndIf
		If oFWSheet:CellExists("TOTAL_MAT_CONS")
			oFWSheet:SetCellValue("TOTAL_MAT_CONS", nTotMC)
		EndIf
		If lAbtInss .AND. oFWSheet:CellExists("TOTAL_ABATE_INS")
			cTotAbINS := oFwSheet:GetCellValue("TOTAL_ABATE_INS")
		EndIf
	Endif
Endif
oFWSheet:Refresh(.T.)

If lFacilit .Or. lOrcSrv
	If oFWSheet:CellExists("TOTAL_CUSTOS")
		nTotal := oFwSheet:GetCellValue("TOTAL_CUSTOS")
	Endif	
	If oFWSheet:CellExists("TOTAL_BRUTO")
		nTotPlan := oFwSheet:GetCellValue("TOTAL_BRUTO")
	Endif
Else
	If oFWSheet:CellExists("TOTAL_RH")
		nTotal := oFwSheet:GetCellValue("TOTAL_RH")
	Endif
Endif

If oMdlRh:GetOperation() <> MODEL_OPERATION_VIEW
	//Executar Planilha para item de RH
	If !( lLocEq )
		//Verifica se tem um facilitador vinculado
		If !lFacilit .And. !lReplica .AND. !( Empty(oMdlRh:GetValue('TFF_CHVTWO')) ) .And. oMdlLA:Length(.T.) > 1 .And. MsgYesNo(STR0015) // "Replicar a execução da Planilha para todos locais de atendimento que utilizam este mesmo facilitador? "
			For nX := 1 To oMdlLA:Length()
				oMdlLA:GoLine(nX)
				For nY := 1 To oMdlRh:Length()
					oMdlRh:GoLine(nY)
					If !( Empty(oMdlRh:GetValue('TFF_CHVTWO')) ) .And. SubStr(oMdlRh:GetValue('TFF_CHVTWO'),1,15) == oMdlTWO:GetValue('TWO_CODFAC')
						oMdlRh:SetValue("TFF_PRCVEN",ROUND(nTotal, TamSX3("TFF_PRCVEN")[2]))
						oMdlRh:SetValue("TFF_CALCMD",cXml)
						oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
						oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
						If lAbtInss
							oMdlRh:SetValue("TFF_ABTINS",cTotAbINS)
						EndIf
					EndIf
				Next nY
			Next nX
		Else
			If lFacilit
				oMdlRh:SetValue("TXS_VLUNIT", ROUND(nTotal, TamSX3("TXS_VLUNIT")[2]))
				oMdlRh:SetValue("TXS_CALCMD", cXml)
				oMdlRh:SetValue("TXS_PLACOD", SubString(cCodRev,1,nTamCpoCod))
				oMdlRh:SetValue("TXS_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
				oMdlRh:SetValue("TXS_TOTPLA", ROUND(nTotPlan, TamSX3("TXS_TOTPLA")[2]))
			Else
				oMdlRh:SetValue("TFF_PRCVEN", ROUND(nTotal, TamSX3("TFF_PRCVEN")[2]))
				oMdlRh:SetValue("TFF_CALCMD", cXml)
				oMdlRh:SetValue("TFF_PLACOD", SubString(cCodRev,1,nTamCpoCod))
				oMdlRh:SetValue("TFF_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
				If TFF->( ColumnPos('TFF_TOTPLA') ) > 0
					oMdlRh:SetValue("TFF_TOTPLA", ROUND(nTotPlan, TamSX3("TFF_TOTPLA")[2]))
				Endif
				If lAbtInss
					oMdlRh:SetValue("TFF_ABTINS",cTotAbINS)
				EndIf
			Endif
			If lCpoCustom
				ExecBlock('A998CPOUSR', .F., .F., {oMdlRh,oFwSheet} )
			EndIf
		EndIf
	//Executar Planilha para item de Locação de Equipamento
	ElseIf !( Empty(oMdlLE:GetValue("TFI_PRODUT")) )
		//Verifica se tem um facilitador vinculado
		If !( Empty(oMdlLE:GetValue('TFI_CHVTWO')) ) .AND. oMdlLA:Length(.T.) > 1 .AND. MsgYesNo(STR0015) // "Replicar a execução da Planilha para todos locais de atendimento que utilizam este mesmo facilitador? "
			For nX := 1 To oMdlLA:Length()
				oMdlLA:GoLine(nX)
				For nY := 1 To oMdlLE:Length()
					oMdlLE:GoLine(nY)
					If  !( Empty(oMdlLE:GetValue('TFI_CHVTWO')) ) .And. SubStr(oMdlLE:GetValue('TFI_CHVTWO'),1,15) == oMdlTWO:GetValue('TWO_CODFAC')
						oMdlLE:SetValue("TFI_CALCMD", cXml)
						oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
						oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
						If oFWSheet:CellExists("TOTAL_LE_COB")
							oMdlLEa:SetValue("TEV_MODCOB",If(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
						EndIf
						If oFWSheet:CellExists("TOTAL_LE_QUANT")
							oMdlLEa:SetValue("TEV_QTDE", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
						EndIf
						If oFWSheet:CellExists("TOTAL_LE_VUNIT")
							oMdlLEa:SetValue("TEV_VLRUNI", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
						EndIf
					EndIf
				Next nY
			Next nX
		Else
			oMdlLE:SetValue("TFI_CALCMD", cXml)
			oMdlLE:SetValue("TFI_PLACOD", SubString(cCodRev,1,nTamCpoCod))
			oMdlLE:SetValue("TFI_PLAREV", SubString(cCodRev,nTamCpoCod+1,nTamCpoRev))
			If oFWSheet:CellExists("TOTAL_LE_COB")
				oMdlLEa:SetValue("TEV_MODCOB",If(valtype(oFwSheet:GetCellValue("TOTAL_LE_COB")) == 'N',AllTrim(str(oFwSheet:GetCellValue("TOTAL_LE_COB"))),oFwSheet:GetCellValue("TOTAL_LE_COB")))
			EndIf
			If oFWSheet:CellExists("TOTAL_LE_QUANT")
				oMdlLEa:SetValue("TEV_QTDE", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_QUANT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_QUANT")))
			EndIf
			If oFWSheet:CellExists("TOTAL_LE_VUNIT")
				oMdlLEa:SetValue("TEV_VLRUNI", If(valtype(oFwSheet:GetCellValue("TOTAL_LE_VUNIT")) <> 'N', 0 ,oFwSheet:GetCellValue("TOTAL_LE_VUNIT")))
			EndIf
		EndIf
	EndIf
EndIf
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998ConsP()

Construção da consulta padrão da tabela ABW - MODELO PLANILHA PREC. SERVICOS

@sample 	At998ConsP() 

@return	lRet, Retorna qual botão foi selecionado .T. Confirmar, .F. Sair 
			cRet, Retorna o codigo+revisão do modelo selecionado

@since		23/10/2013       
@version	P11.9   
/*/
//------------------------------------------------------------------------------
Static Function At998ConsP(cCodPlan)

Local oDlg
Local aBrowse	:= {}   
Local lRet		:= .F. 
Local cRet		:= ""
Local cFilABW 	:= xFilial("ABW")
Local nPos 		:= 0
Local lFacilit   := IsInCallStack("At984aPlPc")
Local lCCT := FindFunction("At999CpCCT") .And. At999CpCCT()

Default cCodPlan := ""

DEFINE MSDIALOG oDlg FROM 180,180 TO 550,700 PIXEL TITLE STR0009 //'Consulta Padrão'

oBrowse := TWBrowse():New( 01 , 01,261, 160,,{STR0010,STR0011,STR0012},{30,40,10}, oDlg, ,,,,{||},,,,,,,.F.,,.T.,,.F.,,, ) //"Código"#"Descrição"#"Revisão"

DbSelectArea("ABW")
DbSetOrder(1) //ABW_FILIAL+ABW_CODIGO+ABW_REVISA
ABW->( DbSeek( cFilABW ) ) // posiciona no primeiro registro da filial

While ABW->(!EOF()) .And. ABW->ABW_FILIAL == cFilABW
	If ABW->(FieldPos("ABW_MSBLQL")) <= 0 .OR. ABW->ABW_MSBLQL != "1"
		If lFacilit .Or. (At998Orc())
			If lCCT .And. !Empty(ABW->ABW_CODTCW)
				aAdd(aBrowse,{ABW->ABW_CODIGO,ABW->ABW_DESC,ABW->ABW_REVISA})
				If !Empty(cCodPlan) .AND. cCodPlan  == ABW->ABW_CODIGO+ABW->ABW_REVISA
					nPos := Len(aBrowse)
				EndIf
			Endif
		Else
			aAdd(aBrowse,{ABW->ABW_CODIGO,ABW->ABW_DESC,ABW->ABW_REVISA})
			If !Empty(cCodPlan) .AND. cCodPlan  == ABW->ABW_CODIGO+ABW->ABW_REVISA
				nPos := Len(aBrowse)
			EndIf
		Endif
	EndIf
	ABW->(DbSkip())
End

If Len(aBrowse) > 0
	oBrowse:SetArray(aBrowse)
	If nPos > 0
		//Posiciona na planilha selecionada
		oBrowse:GoPosition(nPos)
	EndIf
	oBrowse:bLine := {||{aBrowse[oBrowse:nAt,01],aBrowse[oBrowse:nAt,02],aBrowse[oBrowse:nAt,03]} }
	oBrowse:bLDblClick := {|| lRet := .T., cRet := aBrowse[oBrowse:nAt,01]+aBrowse[oBrowse:nAt,03] ,oDlg:End()}

	TButton():New(168,150,STR0005,oDlg,{|| lRet := .T., cRet := aBrowse[oBrowse:nAt,01]+aBrowse[oBrowse:nAt,03] ,oDlg:End() },50,13,,,,.T.) //'Confirmar'
EndIf
	
TButton():New(168,205,STR0013,oDlg,{|| lRet := .F. ,oDlg:End() },50,13,,,,.T.) //'Sair'

ACTIVATE MSDIALOG oDlg CENTERED 

Return {lRet,cRet}
//------------------------------------------------------------------------------
/*/{Protheus.doc} TECGetValue()

Função para retornar qualquer valor do Orçamento de serviços, com o modelo instanciado


@return	xValue

@since		10/10/2016       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function TECGetValue(cAba,cCampo,nLinha,cErro)
Local aSaveLines	:= FWSaveRows()
Local xRet			:= Nil
Default nLinha := 0
Default cErro := ""

If Valtype(oModel740) == 'O'
	cAba := Upper(Alltrim(cAba)) 
	
	Do Case
		Case cAba == 'OR' //-- Cabeçalho Orçamento
			xRet := oModel740:GetValue('TFJ_REFER',cCampo) 
				
			
		Case cAba == 'LA' //-- Local de atendimento
			nlinha := If(nLinha == 0,oModel740:GetModel('TFL_LOC'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFL_LOC'):Length()
				cErro := 'Aba: LA ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida'
			Else
				xRet 	:= oModel740:GetValue('TFL_LOC',cCampo,nLinha)
			EndIf			
			
		
		Case cAba == 'RH' //-- Recursos humanos
			nlinha := If(nLinha == 0,oModel740:GetModel('TFF_RH'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFF_RH'):Length()
				cErro := 'Aba: RH ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFF_RH',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'MI' //-- Material de implantação
			nLinha := If(nLinha == 0,oModel740:GetModel('TFG_MI'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFG_MI'):Length()
				cErro := 'Aba: MI ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFG_MI',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'MC' //-- Material de consumo
			nlinha := If(nLinha == 0,oModel740:GetModel('TFH_MC'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFH_MC'):Length()
				cErro := 'Aba: MC ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFH_MC',cCampo,nLinha)
			EndIf			
		
		Case cAba == 'LE' //-- Locação de equipamento
			nlinha := If(nLinha == 0,oModel740:GetModel('TFI_LE'):GetLine(),nLinha)
			If nLinha > oModel740:GetModel('TFI_LE'):Length()
				cErro := 'Aba: LE ' + CRLF +  'Linha ' + Str(nLinha) + ' inválida' 
			Else
				xRet 	:= oModel740:GetValue('TFI_LE',cCampo,nLinha)
			EndIf			
		
	EndCase
EndIf
FwRestRows( aSaveLines )
Return xRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998InPl()
 Realiza a inclusão de uma Planilha de preço
@author	Kaique Schiller
@since	11/08/2022       
/*/
//------------------------------------------------------------------------------
Static Function At998InPl()
Local lRet := .F.
Local aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},;
					{.T.,STR0021},{.T.,STR0022},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil},{.T.,Nil}} //"Salvar"#"Cancelar"
Local nRet := FWExecView(STR0023, "TECA999", MODEL_OPERATION_INSERT,, {||.T.},,, aButtons ) //"Planilha de Preço"
Local cCodPlan := ""

If nRet == 0
	lRet := .T.
	cCodPlan := ABW->(ABW_CODIGO+ABW_REVISA)
Endif

Return {lRet,cCodPlan}

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998VlBnf()
 Calculo do Valor de beneficio conforme a quantidade de dias trabalhados por mês no turno ou na escala
@author	Kaique Schiller
@since	11/08/2022       
/*/
//------------------------------------------------------------------------------
Static Function At998VlBnf(oFWSheet,cEscala,cTurno,cCodPla,cRevPla)
Local cTabTemp := ""
Local aTabPadrao := {}
Local aCalend := {}
Local nX := 0
Local lProxAgd := .F.
Local nDiaTrab := 0
Default oFWSheet := Nil
Default cEscala := ""
Default cTurno := ""
Default cCodPla := ""
Default cRevPla := ""

If !Empty(cEscala)
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TDX.TDX_TURNO
		FROM %Table:TDX% TDX
		WHERE TDX.TDX_FILIAL = %xFilial:TDX%
			AND TDX.TDX_CODTDW = %Exp:cEscala% 
			AND TDX.%NotDel%
	EndSql
	If !(cTabTemp)->(EOF())
		cTurno := (cTabTemp)->TDX_TURNO
	Endif
	(cTabTemp)->(DbCloseArea())
Endif

If !Empty(cTurno)
	If ( CriaCalend(dDataBase,dDataBase+29,cTurno,"01",@aTabPadrao,@aCalend,xFilial("SRA")) )
		For nX := 1 To Len(aCalend)
			If aCalend[nX][4] == "1E" 
				lProxAgd := .T.
			Endif
			If lProxAgd .And. aCalend[nX][6] == "S"
				nDiaTrab++		
				lProxAgd := .F.
			Endif
		Next nX
	Endif
Endif

If nDiaTrab > 0
	cTabTemp := GetNextAlias()
	BeginSql Alias cTabTemp
		SELECT TDZ_ITEM,
			TDZ_CODSLY,
			TDZ_TIPBEN,
			TDZ_VLRDIF
		FROM %Table:TDZ% TDZ
		INNER JOIN %Table:TCW% TCW ON TCW_FILIAL = %xFilial:TCW%
								AND TCW.TCW_CODIGO = TDZ.TDZ_CODTCW
								AND TCW.%NotDel%
		INNER JOIN %Table:ABW% ABW ON ABW_FILIAL = %xFilial:ABW%
								AND ABW.ABW_CODTCW = TCW_CODIGO
								AND ABW.%NotDel%
		WHERE TDZ.TDZ_FILIAL = %xFilial:TDZ%
			AND TDZ.%NotDel%
			AND ABW.ABW_CODIGO = %Exp:cCodPla% 
			AND ABW.ABW_REVISA = %Exp:cRevPla%
	EndSql
	
	While !(cTabTemp)->(EOF())
		If Alltrim((cTabTemp)->TDZ_TIPBEN) == "VA" .Or. Alltrim((cTabTemp)->TDZ_TIPBEN) == "VR"
			If oFWSheet:CellExists(Alltrim((cTabTemp)->TDZ_ITEM+"_"+(cTabTemp)->TDZ_TIPBEN))
				oFwSheet:SetCellValue(Alltrim((cTabTemp)->TDZ_ITEM+"_"+(cTabTemp)->TDZ_TIPBEN),((cTabTemp)->TDZ_VLRDIF*nDiaTrab))	
			Endif
		Endif
		(cTabTemp)->(DbSkip())
	EndDo
	(cTabTemp)->(DbCloseArea())
Endif

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} At998Orc()
 Verificar se foi feita a chamada pelo orçamento e orçamento simplificado
@author	Kaique Schiller
@since	11/08/2022       
/*/
//------------------------------------------------------------------------------
Static Function At998Orc()
Return SuperGetMv("MV_GSITORC",,"2") == "1" .And. (Isincallstack("TECA740") .Or. Isincallstack("TECA745"))
