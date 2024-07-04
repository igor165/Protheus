#INCLUDE "tmsa630.ch"
#Include "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSA630
    Bloqueios dos Clientes
    @type Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA630()
    (examples)
    @see (links_or_references)
*/
Function TMSA630(aRotAuto,nOpcAuto)

Private l630Auto := (ValType(aRotAuto) == "A")           

If l630Auto
    FwMvcRotAuto(ModelDef(),"DV5",nOpcAuto,{{"MdFieldDV5",aRotAuto}},.T.,.T.)	 //-- Chamada da rotina automatica atraves do MVC
Else
	oBrowse:= FwMBrowse():New()
	oBrowse:SetAlias("DV5")
	oBrowse:SetDescription(OemToAnsi(STR0001))	//-- Bloqueio de Clientes
	oBrowse:Activate()
EndIf

Return Nil

/*{Protheus.doc} Menudef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA630()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()

Private aRotina:= { {STR0002,"AxPesqui"       ,0,1,,.F.},; 	//"Pesquisar"
					{STR0003,"VIEWDEF.TMSA630",0,2},;  		//"Visualizar"
					{STR0004,"VIEWDEF.TMSA630",0,3},;  		//"Incluir"
					{STR0005,"VIEWDEF.TMSA630",0,4},;  		//"Alterar"
					{STR0006,"VIEWDEF.TMSA630",0,5}}  		//"Excluir"

Return (aRotina)

/*{Protheus.doc} Modeldef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA630()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel   := Nil
Local oStruDV5 := FwFormStruct(1,"DV5")

oModel:= MpFormModel():New("TMSA630",/*bPre*/,{|oModel| PosVldMdl(oModel)},/*bCommit*/,/*bCancel*/)

oModel:SetDescription(OemToAnsi(STR0001))	//-- Bloqueio de Clientes

oModel:AddFields("MdFieldDV5",Nil,oStruDV5)

oModel:GetModel("MdFieldDV5"):SetDescription(STR0001)	//-- Bloqueio de Clientes

oModel:SetPrimaryKey({"DV5_FILIAL","DV5_CODCLI","DV5_LOJCLI","DV5_SEQUEN"})

Return (oModel)

/*{Protheus.doc} Viewdef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA630()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()                  
Local oView    := Nil
Local oModel   := FwLoadModel("TMSA630")
Local oStruDV5 := FwFormStruct(2,"DV5")
                                 
oView:= FwFormView():New()   

oView:SetModel(oModel)

oView:AddField("VwFieldDV5",oStruDV5,"MdFieldDV5") 

oView:CreateHorizontalBox("Field",100)

oView:EnableTitleView("VwFieldDV5",STR0001)	//-- Bloqueio de Clientes

oView:SetOwnerView("VwFieldDV5","Field")

Return (oView)

/*{Protheus.doc} TMSA630Vld
    @type Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA630()
    (examples)
    @see (links_or_references)
*/
Function TMSA630Vld()
Local cCampo := ReadVar()
Local lRet   := .T.
Local aAreas := {DV5->(GetArea()),GetArea()}

If cCampo == "M->DV5_CODCLI" .Or. cCampo == "M->DV5_LOJCLI"
	If !Empty(FwFldGet("DV5_CODCLI")) .And. !Empty(FwFldGet("DV5_LOJCLI"))
		DV5->(dbSetOrder(1))
		If DV5->(MsSeek(xFilial("DV5") + FwFldGet("DV5_CODCLI") + FwFldGet("DV5_LOJCLI")))
			Help("",1,"TMSA63002")	//-- "Nao e permitido mais de um bloqueio para o mesmo cliente."
			lRet := .F.
		EndIf
	EndIf
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return(lRet)

/*{Protheus.doc} PosVldMdl
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 22/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA630()
    (examples)
    @see (links_or_references)
*/
Static Function PosVldMdl(oModel)
Local lRet       := .T.
Local nOperation := oModel:GetOperation()

//-- Verifica se o usuario tem permissao para Alterar/Excluir o registro.
If !(Upper("Administrador") $ Upper(cUsuario))
	If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_DELETE
		If RetCodUsr() != DV5->DV5_USER
			Help("",1,"TMSA63001")	//-- "Usuario sem permissao para alterar esse registro."
			lRet := .F.
		EndIf			
	EndIf		
EndIf

Return lRet
