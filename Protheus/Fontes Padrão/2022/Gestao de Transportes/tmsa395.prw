#INCLUDE "TMSA395.ch"
#Include "PROTHEUS.ch"  
#INCLUDE "FWMVCDEF.CH" 

Static lBloqueia := .F.

/*{Protheus.doc} TMSA395
    Prazos de Regiões por Cliente
    @type Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Function TMSA395(aRotAuto,nOpcAuto)

Private l395Auto := (ValType(aRotAuto) == "A")           

If l395Auto
    FwMvcRotAuto(ModelDef(),"DVN",nOpcAuto,{{"MdFieldDVN",aRotAuto}},.T.,.T.)	 //-- Chamada da rotina automatica atraves do MVC
Else
	oBrowse:= FwMBrowse():New()
	oBrowse:SetAlias("DVN")
	oBrowse:SetDescription(OemToAnsi(STR0008))	//-- "Prazos de Regioes por Cliente"
	oBrowse:AddLegend("DVN_STATUS == '1'","RED"  ,STR0021)	//-- Bloqueado
	oBrowse:AddLegend("DVN_STATUS != '1'","GREEN",STR0022)	//-- Liberado
	oBrowse:Activate()
EndIf

Return NIL

/*{Protheus.doc} Menudef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRet	:= {}

Private aRotina:= { {STR0002,"AxPesqui"       ,0, 1,,.F.},;	//-- "Pesquisar"
					{STR0003,"VIEWDEF.TMSA395",0, 2},;  	//-- "Visualizar"
					{STR0004,"VIEWDEF.TMSA395",0, 3},;  	//-- "Incluir"
					{STR0005,"VIEWDEF.TMSA395",0, 4},;  	//-- "Alterar"
					{STR0006,"VIEWDEF.TMSA395",0, 5},;  	//-- "Excluir"
					{STR0019,"TMSA395Lib"     ,0,11}}	  	//-- "Liberar"

If ExistBlock("TMA395MNU")
	aRet := ExecBlock("TMA395MNU",.F.,.F.,{aRotina})
	If (ValType(aRet)=="A")
		aRotina := AClone(aRet)
	EndIf
EndIf

Return (aRotina)

/*{Protheus.doc} Modeldef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel   := Nil
Local oStruDVN := FwFormStruct(1,"DVN")
Local oStruDMP := Nil

//-- Cria a Model
oModel:= MpFormModel():New("TMSA395",/*bPre*/,{|oModel| PosVldMdl(oModel)},{|oModel| TMSA395Grv(oModel)},/*bCancel*/)
oModel:SetDescription(OemToAnsi(STR0008))	//-- Prazos de Regioes por Cliente

//-- Adiciona Field
oModel:AddFields("MdFieldDVN",Nil,oStruDVN)
oModel:GetModel("MdFieldDVN"):SetDescription(STR0008)	//-- Prazos de Regioes por Cliente
oModel:SetPrimaryKey({"DVN_FILIAL","DVN_CODCLI","DVN_LOJCLI","DVN_CDRORI","DVN_CDRDES","DVN_TIPTRA"})

//-- Prazos de Clientes x Serviço
If AliasIndic("DMP")
	oStruDMP := FwFormStruct(1,"DMP")

	//-- Adiciona o Grid
	oModel:AddGrid("MdGridDMP","MdFieldDVN",oStruDMP,/*bLinPre*/,/*bLinPos*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("MdGridDMP",{{"DMP_FILIAL","xFilial('DMP')"},;
									{"DMP_CODCLI","DVN_CODCLI"},;
									{"DMP_LOJCLI","DVN_LOJCLI"},;
									{"DMP_CDRORI","DVN_CDRORI"},;
									{"DMP_CDRDES","DVN_CDRDES"},;
									{"DMP_TIPTRA","DVN_TIPTRA"}},;
									DMP->(IndexKey(1)))
	oModel:GetModel("MdGridDMP"):SetDescription(STR0023)	//-- Prazos de Clientes x Serviço
	oModel:GetModel("MdGridDMP"):SetUniqueLine({"DMP_SERVIC"})
	oModel:GetModel("MdGridDMP" ):SetOptional( .T. )
EndIf

Return (oModel)

/*{Protheus.doc} Viewdef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()
Local oView      := Nil
Local oModel     := FwLoadModel("TMSA395")
Local oStruDVN   := FwFormStruct(2,"DVN")
Local oStruDMP   := Nil

//-- Cria a View                                 
oView:= FwFormView():New()   
oView:SetModel(oModel)

//-- Adiciona o Field
oView:AddField("VwFieldDVN",oStruDVN,"MdFieldDVN")

//-- Define a tela principal
oView:CreateHorizontalBox("Tela",Iif(AliasInDic("DMP"),050,100))
oView:EnableTitleView("VwFieldDVN",STR0008)	//-- Prazos de Regioes por Cliente
oView:SetOwnerView("VwFieldDVN","Tela")

//-- Cria Botão em Outras Ações
oView:AddUserButton(STR0018,"",{|oModel| TMSA395UF(oModel)})	//-- "Praz.Reg"

If AliasIndic("DMP")
	oStruDMP := FwFormStruct(2,"DMP")

	//-- Define o Box da tela de automatizações
	oView:CreateHorizontalBox("Inferior",050)

	oView:AddGrid("VwGridDMP",oStruDMP,"MdGridDMP")
	oView:SetOwnerView("VwGridDMP","Inferior")
EndIf

Return (oView)

/*{Protheus.doc} TMSA395Grv
	Gravação do Registro
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Static Function TMSA395Grv(oModel)
Local nOperation  := oModel:GetOperation()
Local oMdFieldDVN := oModel:GetModel("MdFieldDVN")
Local lRet        := .T.

Begin Transaction

	If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

		If lBloqueia			
			oMdFieldDVN:LoadValue("DVN_STATUS","1")	//-- Bloqueado
		Else
			oMdFieldDVN:LoadValue("DVN_STATUS","2")	//-- Liberado
		EndIf

	EndIf

	lRet:= FwFormCommit(oModel)

	If !lRet	
		DisarmTransaction()
		Break
	EndIf
		
End Transaction

Return lRet

/*{Protheus.doc} PosVldMdl
	Validação Antes da Gravação (TudoOk)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Static Function PosVldMdl(oModel)
Local lRet        := .T.
Local nOperation  := oModel:GetOperation()
Local aAreas      := {DTD->(GetArea()),GetArea()}

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	DTD->(DbSetOrder(1))
	If DTD->(!MsSeek(xFilial("DTD") + FwFldGet("DVN_CDRORI") + FwFldGet("DVN_CDRDES") + FwFldGet("DVN_TIPTRA")))
		Help("",1,"TMSA39503")	//-- "Este prazo de cliente nao existe na tabela de prazo de regiao"
		lRet := .F.
	EndIf

	If lRet 
		If Val(FwFldGet("DVN_TMCLII")) == 0 .And. Val(FwFldGet("DVN_TMCLIF")) == 0
			Help("",1,"TMSA39507")	//-- "Os campos 'Tempo De' e 'Tempo Ate' nao podem estar zerados"
			lRet := .F.
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSA395Vld
	Validação de Campos
    @type Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Function TMSA395Vld()
Local aAreas      := {DVN->(GetArea()),DTD->(GetArea()),GetArea()}
Local lRet        := .T.
Local cCampo      := ReadVar()
Local cTempo      := ""
Local nTamTmp     := TamSx3("DVN_TMCLII")[1] - 2	//-- Tamanho Horas menos Minutos

//-- Posiciona no prazo de regioes
DTD->(DbSetOrder(1))
If DTD->(MsSeek(xFilial("DVN") + FwFldGet("DVN_CDRORI") + FwFldGet("DVN_CDRDES") + FwFldGet("DVN_TIPTRA")))
	If cCampo $ "M->DVN_CODCLI:M->DVN_LOJCLI:M->DVN_CDRORI:M->DVN_CDRDES:M->DVN_CODNEG:M->DVN_SERVIC:M->DVN_TIPTRA"
		lRet := ExistChav("DVN",M->(DVN_CODCLI + DVN_LOJCLI + DVN_CDRORI + DVN_CDRDES + DVN_TIPTRA),,"EXISTCLI")
	ElseIf cCampo $ "M->DVN_TMCLII"
		//-- Tempo inicial de embarque, trafego e distribuicao informado no prazo de regioes
		cTempo := StrTran(IntToHora(TmsHrToInt(DTD->DTD_TMEMBI) + TmsHrToInt(DTD->DTD_TMTRAI) + TmsHrToInt(DTD->DTD_TMDISI),nTamTmp),":","")
		//-- Nao permite que tempo minimo de entrega de um cliente, seja menor que o informado no prazo de regioes
		If FwFldGet("DVN_TMCLII") < cTempo
			Help("",1,"TMSA39502",,STR0011 + Transf(Val(cTempo),PesqPict("DTD","DTD_TMEMBI")),4,1)	//-- "Tempo minimo de entrega do cliente esta menor que o informado no prazo de regioes"###"Prazo de Regioes: "
			lBloqueia := .T.
		Else
			lBloqueia := .F.
		EndIf
	ElseIf cCampo $ "M->DVN_TMCLIF"
		//-- Tempo final de embarque, trafego e distribuicao informado no prazo de regioes
		cTempo := StrTran(IntToHora(TmsHrToInt(DTD->DTD_TMEMBF) + TmsHrToInt(DTD->DTD_TMTRAF) + TmsHrToInt(DTD->DTD_TMDISF),nTamTmp),":","")
		//-- Nao permite que tempo maximo de entrega de um cliente, seja maior que o informado no prazo de regioes
		If FwFldGet("DVN_TMCLIF") < cTempo 
			Help("",1,"TMSA39504",,STR0011 + Transf(Val(cTempo),PesqPict("DTD","DTD_TMEMBF")),4,1)	//-- "Tempo maximo de entrega do cliente esta maior que o informado no prazo de regioes"###"Prazo de Regioes: "
			lBloqueia := .T.
		Else
			lBloqueia := .F.
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return lRet

/*{Protheus.doc} TMSA395Lib
	Liberação do Registro
    @type Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Function TMSA395Lib()
Local aDadosDVN   := {}

If DVN->DVN_STATUS == StrZero(1,Len(DVN->DVN_STATUS))

	lBloqueia := .F.
	
	//-- Carrega vetor com os campos para liberação
	Aadd(aDadosDVN,{"DVN_USRAPV",RetCodUsr()})
	Aadd(aDadosDVN,{"DVN_DATLIB",dDataBase})
	Aadd(aDadosDVN,{"DVN_HORLIB",Left(Time(),5)})

	TMSA395Ins(Aclone(aDadosDVN),4)

Else

	Help("",1,"TMSA39509")	//-- "Somente registros bloqueados podem ser liberados."

EndIf

Return

/*{Protheus.doc} TMSA395Ins
	Função que Instancia o Modelo
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Static Function TMSA395Ins(aVetDados,nOperation)
Local oModel      := Nil
Local oMdFieldDVN := Nil
Local oStruDVN    := Nil
Local aCamposDVN  := {}
Local nCntFor1    := 0
Local lCont       := .T.

Default aVetDados  := {}
Default nOperation := 0

//-- Carrega o Modelo
oModel := FWLoadModel("TMSA395")
oModel :SetOperation(nOperation)

//-- Ativa o Modelo
oModel:Activate()

//-- Carrega o Modelo dos Prazos
oMdFieldDVN := oModel:GetModel("MdFieldDVN")
oStruDVN    := oMdFieldDVN:GetStruct()
aCamposDVN  := oStruDVN:GetFields()

//-- Preenche os Valores dos Prazos
For nCntFor1 := 1 To Len(aVetDados)
	If AScan(aCamposDVN,{|x| AllTrim(x[3]) == AllTrim(aVetDados[nCntFor1,1])}) > 0
		If !oMdFieldDVN:SetValue(aVetDados[nCntFor1,1],aVetDados[nCntFor1,2])
			lCont := .F.
			Exit
		EndIf
	EndIf
Next nCntFor1

//-- Grava os Dados
If lCont
	If (lCont := oModel:VldData())
		oModel:CommitData()
	EndIf
EndIf

//-- Se Ocorreu Algum Erro Exibe Mensagem
If !lCont
	//-- Monta mensagem de erro
	TF67MntErr(oModel)

	MostraErro()
EndIf

//-- Desativa o Modelo
oModel:DeActivate()

Return

/*{Protheus.doc} TMSA395UF
	Monta uma Parambox contendo todos os Estados em que o Prazo de Regioes podera ser criado
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Static Function TMSA395UF(oModel)
Local aEstados    := {}
Local aRet        := {}
Local aSX512      := {}
Local aDadosTela  := {}
Local aCamposDVN  := {}
Local aEst        := {}
Local lCkb        := .T.
Local lInv        := .F.
Local nCntFor1    := 0
Local nCntFor2    := 0
Local nOperation  := oModel:GetOperation()
Local oMdFieldDVN := oModel:GetModel("MdFieldDVN")
Local oStruDVN    := Nil

If nOperation == MODEL_OPERATION_INSERT
	aSX512 := FwGetSX5("12",)
	
	For nCntFor1 := 1 to Len(aSX512)
		lCkb := .F.
		Aadd(aEstados,{4,"",lCkb,AllTrim(aSX512[nCntFor1,3]) + " - " + aSX512[nCntFor1,4],80,,.F.})
	Next nCntFor1	
	
	If ParamBox(aEstados,STR0013,@aRet,,{{5,{|oPanel| TMSA395Marc(aEstados,@aRet,@lInv),oPanel:Refresh()},STR0014}},.T.)	//-- "Tabela de Estados" # "Marca/Desmarca Todos"
		For nCntFor1 := 1 To Len(aRet)
			If aRet[nCntFor1]
				Aadd(aEst,SubStr(aEstados[nCntFor1,4],1,2))
			EndIf
		Next nCntFor1

		oStruDVN   := oMdFieldDVN:GetStruct()
		aCamposDVN := oStruDVN:GetFields()
		
		For nCntFor2 := 1 To Len(aCamposDVN)
			Aadd(aDadosTela,{aCamposDVN[nCntFor2,3],FwFldGet(aCamposDVN[nCntFor2,3])})
		Next nCntFor2
		
		TMA395RegDes(aEst,Aclone(aDadosTela))
	EndIf
Else
	Help("",1,"TMSA39508")	//-- "Função somente válida para inclusão."
EndIf

Return

/*{Protheus.doc} TMSA395Mar
	Marca/Desmarca todos os CheckBox do PARAMBOX
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Static Function TMSA395Marc(aEstados,aRet,lInv)
Local nCntFor1 := 0

For nCntFor1 := 1 To Len(aEstados)
	Aadd(aRet,If(lInv,.F.,.T.))
	&("MV_PAR" + StrZero(nCntFor1,2)) := If(lInv,.F.,.T.)
Next nCntFor1

lInv := !lInv

Return

/*{Protheus.doc} TMA395RegD
	Gera Prazo de Regioes  para as Regioes pertencentes aos Estados Informados no Botao de Estados (Enchoice)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA395()
    (examples)
    @see (links_or_references)
*/
Static Function TMA395RegDes(aEst,aDadosBase)
Local aAreas      := {GetArea()}
Local aMsgErr     := {}
Local aVisErr     := {}
Local nCntFor1    := 0
Local nPosTmCliI  := 0
Local nPosTmCliF  := 0
Local nPosCdrOri  := 0
Local nPosCdrDes  := 0
Local nPosStatus  := 0
Local cTempoI     := ""
Local cTempoF     := ""
Local cAliasDUY   := ""
Local cQuery      := ""
Local cEst        := ""

Default aEst       := {}
Default aDadosBase := {}

nPosTmCliI := AScan(aDadosBase,{|x| AllTrim(x[1]) == "DVN_TMCLII"})
nPosTmCliF := AScan(aDadosBase,{|x| AllTrim(x[1]) == "DVN_TMCLIF"})
nPosCdrOri := AScan(aDadosBase,{|x| AllTrim(x[1]) == "DVN_CDRORI"})
nPosCdrDes := AScan(aDadosBase,{|x| AllTrim(x[1]) == "DVN_CDRDES"})
nPosStatus := AScan(aDadosBase,{|x| AllTrim(x[1]) == "DVN_STATUS"})

If !Empty(aEst)

	For nCntFor1 := 1 To Len(aEst)
		cEst += "'" + aEst[nCntFor1] + "',"
	Next nCntFor1
	cEst := Substr(cEst,1,Len(cEst) - 1)

	cAliasDUY := GetNextAlias()
	cQuery := " SELECT DISTINCT DUY_GRPVEN,DTD_TMEMBI,DTD_TMTRAI,DTD_TMDISI,DTD_TMEMBF,DTD_TMTRAF,DTD_TMDISF "
	cQuery += "   FROM " + RetSqlname("DUY") + " DUY "

	cQuery += "   JOIN " + RetSqlName("DTD") + " DTD "
	cQuery += "     ON DTD_FILIAL = '" + xFilial("DTD") + "' "
	cQuery += "    AND DTD_CDRORI = '" + FwFldGet("DVN_CDRORI") + "' "
	cQuery += "    AND DTD_CDRDES = DUY_GRPVEN "
	cQuery += "    AND DTD_TIPTRA = '" + FwFldGet("DVN_TIPTRA") + "' "
	cQuery += "    AND DTD.D_E_L_E_T_ = ' ' "

	cQuery += "  WHERE DUY_FILIAL = '" + xFilial("DUY") + "' "
	cQuery += "    AND DUY_EST IN (" + cEst + ") "

	cQuery += "    AND NOT EXISTS (SELECT * "
	cQuery += "                      FROM " + RetSqlName("DVN") + " DVN "
	cQuery += "                     WHERE DVN_FILIAL = '" + xFilial("DVN") + "' "
	cQuery += "                       AND DVN_CODCLI = '" + FwFldGet("DVN_CODCLI") + "' "
	cQuery += "                       AND DVN_LOJCLI = '" + FwFldGet("DVN_LOJCLI") + "' "
	cQuery += "                       AND DVN_CDRORI = '" + FwFldGet("DVN_CDRORI") + "' "
	cQuery += "                       AND DVN_CDRDES = DUY_GRPVEN "
	cQuery += "                       AND DVN_TIPTRA = '" + FwFldGet("DVN_TIPTRA") + "' "
	cQuery += "                       AND DVN.D_E_L_E_T_ = ' ' ) "

	cQuery += "    AND DUY.D_E_L_E_T_ = ' ' "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasDUY,.T.,.T.)

	While (cAliasDUY)->(!Eof())

		aDadosBase[nPosStatus,2] := StrZero(2,Len(DVN->DVN_STATUS))	//-- Status de não Bloqueado
		aDadosBase[nPosCdrDes,2] := (cAliasDUY)->DUY_GRPVEN

		aMsgErr       := {}
		//-- Nao permite que tempo minimo de entrega de um cliente, seja menor que o informado no prazo de regioes
		cTempoI := StrTran(IntToHora(TmsHrToInt((cAliasDUY)->DTD_TMEMBI) + TmsHrToInt((cAliasDUY)->DTD_TMTRAI) + TmsHrToInt((cAliasDUY)->DTD_TMDISI),3),":","")
		//-- Tempo final de embarque, trafego e distribuicao informado no prazo de regioes
		cTempoF := StrTran(IntToHora(TmsHrToInt((cAliasDUY)->DTD_TMEMBF) + TmsHrToInt((cAliasDUY)->DTD_TMTRAF) + TmsHrToInt((cAliasDUY)->DTD_TMDISF),3),":","")

		If Val(aDadosBase[nPosTmCliI,2]) < Val(cTempoI)
			AAdd(aMsgErr,{STR0015 + aDadosBase[nPosCdrOri,2] + " / " + STR0016 + aDadosBase[nPosCdrDes,2],"01","TMSA390()"})
			AaddMsgErr(aMsgErr,@aVisErr)
			aDadosBase[nPosStatus,2] := StrZero(1,Len(DVN->DVN_STATUS))	//-- Status de Bloqueado
		ElseIf Val(aDadosBase[nPosTmCliF,2]) < Val(cTempoF)
			AAdd(aMsgErr,{STR0017 + aDadosBase[nPosCdrOri,2] + " / " + STR0016 + aDadosBase[nPosCdrDes,2],"01","TMSA390()"})
			AaddMsgErr(aMsgErr,@aVisErr)
			aDadosBase[nPosStatus,2] := StrZero(1,Len(DVN->DVN_STATUS))	//-- Status de Bloqueado
		EndIf

		TMSA395Ins(Aclone(aDadosBase),3)

		(cAliasDUY)->(DbSkip())

	EndDo
	
	(cAliasDUY)->( DbCloseArea() )

EndIf

If !Empty(aVisErr)
	TmsMsgErr(aVisErr)
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return Nil
