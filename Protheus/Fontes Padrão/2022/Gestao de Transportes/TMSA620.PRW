#INCLUDE "TMSA620.ch"
#Include "PROTHEUS.ch"  
#INCLUDE "FWMVCDEF.CH" 

/*{Protheus.doc} TMSA620
    Inscrições Estaduais dos Clientes
    @type Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Function TMSA620(aRotAuto,nOpcAuto)

Private l620Auto := (ValType(aRotAuto) == "A")           

If l620Auto
    FwMvcRotAuto(ModelDef(),"DV3",nOpcAuto,{{"MdFieldDV3",aRotAuto}},.T.,.T.)	 //-- Chamada da rotina automatica atraves do MVC
Else
	oBrowse:= FwMBrowse():New()
	oBrowse:SetAlias("DV3")
	oBrowse:SetDescription(OemToAnsi(STR0001))	//-- Inscrições Estaduais dos Clientes
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
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()

Private aRotina:= { {STR0002,"AxPesqui"       ,0,1,,.F.},; 	//"Pesquisar"
					{STR0003,"VIEWDEF.TMSA620",0,2},;  		//"Visualizar"
					{STR0004,"VIEWDEF.TMSA620",0,3},;  		//"Incluir"
					{STR0005,"VIEWDEF.TMSA620",0,4},;  		//"Alterar"
					{STR0006,"VIEWDEF.TMSA620",0,5}}  		//"Excluir"

Return (aRotina)

/*{Protheus.doc} Modeldef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Static Function ModelDef()
Local oModel   := Nil
Local oStruDV3 := FwFormStruct(1,"DV3")

oModel:= MpFormModel():New("TMSA620",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)

oModel:SetDescription(OemToAnsi(STR0001))	//-- Inscrições Estaduais dos Clientes

oModel:AddFields("MdFieldDV3",Nil,oStruDV3)

oModel:GetModel("MdFieldDV3"):SetDescription(STR0001)	//-- Inscrições Estaduais dos Clientes

oModel:SetPrimaryKey({"DV3_FILIAL","DV3_CODCLI","DV3_LOJCLI","DV3_SEQUEN"})

Return (oModel)

/*{Protheus.doc} Viewdef
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Static Function ViewDef()                  
Local oView    := Nil
Local oModel   := FwLoadModel("TMSA620")
Local oStruDV3 := FwFormStruct(2,"DV3")
                                 
oView:= FwFormView():New()   

oView:SetModel(oModel)

oView:AddField("VwFieldDV3",oStruDV3,"MdFieldDV3") 

oView:CreateHorizontalBox("Field",100)

oView:EnableTitleView("VwFieldDV3",STR0001)	//-- Inscrições Estaduais dos Clientes

oView:SetOwnerView("VwFieldDV3","Field")

Return (oView)

/*{Protheus.doc} TMSA620Vld
    @type Function
    @author Valdemar Roberto Mognon
    @since 20/07/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example TMSA620()
    (examples)
    @see (links_or_references)
*/
Function TMSA620Vld()
Local lRet   := .T.
Local cCampo := AllTrim(ReadVar())
Local aAreas := {DV3->(GetArea()),GetArea()}

If cCampo == "M->DV3_CODCLI" .Or. cCampo == "M->DV3_LOJCLI"
	DV3->(DbSetOrder(1))
	DV3->(DbSeek(xFilial("DV3") + FwFldGet("DV3_CODCLI") + FwFldGet("DV3_LOJCLI") + Replicate("Z",Len(DV3->DV3_SEQUEN)),.T.))
	DV3->(DbSkip(-1))
	If DV3->(DV3_CODCLI + DV3_LOJCLI) == M->(DV3_CODCLI + DV3_LOJCLI)
		M->DV3_SEQUEN := Soma1(DV3->DV3_SEQUEN)
	Else
		M->DV3_SEQUEN := StrZero(1,Len(DV3->DV3_SEQUEN))
	EndIf		
EndIf

AEval(aAreas,{|x,y| RestArea(x),FwFreeArray(x)})

Return(lRet)
