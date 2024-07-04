#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#INCLUDE "FINA024TIT.CH"

Static cTblBrowse    := "FKL"
Static __nOper       := 0
Static __lConfirmou  := .F.
Static __lFirst      := .T.
Static __lAltAll     := .F.
Static __oPrepFKL    := Nil

#DEFINE OPER_ATIVAR	  11
#DEFINE OPER_COPIAR	  12

//---------------------------------
/*/{Protheus.doc} FINA024TIT
Regras de Titulos

@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Function FINA024TIT(aRotAut As Array, nOpcAut)
	Local aLegenda As Array
	
	Default aRotAut := {} 
	Default nOpcAut := 0
	
	//Inicializa variáveis
	aLegenda := {}
	
	If Len(aRotAut) > 0
		FWMVCRotAuto(FWLoadModel("FINA024TIT"), cTblBrowse, nOpcAut, {{"FKLMASTER", aRotAut}}, , .T.)
	Else
		FxBrowse(cTblBrowse, 2, STR0001, aLegenda) //Regra de Título
	EndIf
Return
 
//---------------------------------
/*/{Protheus.doc} MenuDef
Menu
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function MenuDef() As Array
	Local aRotina  As Array
	Local aTitMenu As Array
	Local aActions As Array
	
	//Inicializa variáveis
	aTitMenu := { {STR0006, "F24TITCOP", OP_COPIA} }
	aActions := { {STR0005, "F24TITVIS"}, {STR0002, "F24TITINC"}, {STR0003, "F24TITALT"}, {STR0004, "F24TITEXC"} }
	aRotina := FxMenuDef(.T., aTitMenu, aActions)
Return aRotina

//---------------------------------
/*/{Protheus.doc} ModelDef
Modelo dados da regra de título
@author  Sivaldo Oliveira
@since 21/08/25/08/2018
@version 12
/*/
//---------------------------------
Static Function ModelDef() As Object
	Local oModel  As Object
	Local oFKL    As Object
	Local aRelFKL As Array
	
	//Inicializa variáveis.
	oModel  := Nil
	aRelFKL := {}
	oFKL    := FxStruct(1, cTblBrowse)
	
	//Instacia o objeto 
	oModel := MPFormModel():New("FINA024TIT", Nil, {||F24TITOK()}, Nil, Nil)
	
	//Adiciona uma um submodel editável/fields
	oModel:AddFields("FKLMASTER", Nil, oFKL, Nil, Nil, Nil)
	
	//Relacionamento do modelo de dados
	aAdd(aRelFKL, {"FKL_FILIAL", "xFilial('FKL')"})
	
	//Define a chave primária do modelo
	oModel:SetPrimaryKey({"FKL_FILIAL", "FKL_IDRET"})	
	
	//Inicializa o campo IDRET
	If (__nOper != MODEL_OPERATION_UPDATE .Or. __nOper == OPER_COPIAR) 
		oFKL:SetProperty("FKL_IDRET",   MODEL_FIELD_INIT, {||F24TITIDR()})
	EndIf
	
	//When dos campos
	oFKL:SetProperty("FKL_PARTIC", MODEL_FIELD_WHEN, {||F24TITWhe("FKL_RTPART")})
	oFKL:SetProperty("FKL_LOJA",   MODEL_FIELD_WHEN, {||F24TITWhe("FKL_RTPART")})	
	
	If __nOper == MODEL_OPERATION_UPDATE	
		If __lAltAll
			oFKL:SetProperty("*", MODEL_FIELD_WHEN, {||.T.})
			oFKL:SetProperty("FKL_CODIGO",  MODEL_FIELD_WHEN, {||.F.})
		Else
			oFKL:SetProperty("*", MODEL_FIELD_WHEN, {||.F.})
			oFKL:SetProperty("FKL_DESCR",  MODEL_FIELD_WHEN, {||.T.})
		EndIf
	EndIf
	
	//Ativa o modelo
	oModel:SetActivate()
Return oModel

//---------------------------------
/*/{Protheus.doc} ViewDef
Criação da View
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Static Function ViewDef() As Object
	Local oModel As Object
	Local oView  As Object
	Local oFKL   As Object
	
	//Inicializa as variáveis
	oModel := FWLoadModel("FINA024TIT")
	oView  := FWFormView():New()
	oFKL   := FxStruct(2, cTblBrowse, Nil, Nil, {"FKL_IDRET"}, Nil)
	
	//Seta o modelo de dados a ser usado na view
	oView:SetModel(oModel)
	
	//Adiciona na grid um controle de FormFields
	oView:AddField("VIEW_FKL", oFKL, "FKLMASTER")
	oView:SetDescription(STR0001) //Regra de Título
	
	//Ordem de exibição dos campos na view
	oFKL:SetProperty("FKL_CARTMV", MVC_VIEW_ORDEM, "11")
	oFKL:SetProperty("FKL_NATUR",  MVC_VIEW_ORDEM, "12")	
	oFKL:SetProperty("FKL_TIPO",   MVC_VIEW_ORDEM, "14")
	oFKL:SetProperty("FKL_PREFIX", MVC_VIEW_ORDEM, "15")
	
	//Consulta F3
	oFKL:SetProperty("FKL_PARTIC", MVC_VIEW_LOOKUP, {||F24TITCF3("FKL_PARTIC")})
	oFKL:SetProperty("FKL_TIPO"	 , MVC_VIEW_LOOKUP, {||F24TITCF3("FKL_TIPO")})
	
	If (__nOper == MODEL_OPERATION_UPDATE .Or. __nOper == OPER_COPIAR)  
		oView:SetAfterViewActivate({|oView|F024TITREF(oView)})
	EndIf
Return oView


//---------------------------------
/*/{Protheus.doc} F024TITVIS
Define a operação de VISUALIZAÇÃO
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12	
/*/
//---------------------------------
Function F24TITVIS()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	__nOper := MODEL_OPERATION_VIEW
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel   := FwLoadModel("FINA024TIT")
	oModel:SetOperation(MODEL_OPERATION_VIEW)
	oModel:Activate()

	FWExecView(STR0005, "FINA024TIT", MODEL_OPERATION_VIEW,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return




//---------------------------------
/*/{Protheus.doc} F024TITINC
Define a operação de inclusão
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12	
/*/
//---------------------------------
Function F24TITINC()
	Local oModel   As Object
	Local aButtons As Array

	//Inicializa variáveis
	oModel   := Nil
	__nOper := MODEL_OPERATION_INSERT
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	oModel   := FwLoadModel("FINA024TIT")
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()

	FWExecView(STR0002, "FINA024TIT", MODEL_OPERATION_INSERT,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )

	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
Return

//---------------------------------
/*/{Protheus.doc} F24TITALT
Define a operação de alteração
@author  Sivaldo Oliveira
@since 10/09//2018
@version 12
/*/
//---------------------------------
Function F24TITALT()
	Local aButtons As Array
	Local oModel   As Object
	Local cCodigo  As Character
	Local cIdRet   As Character
	
	__nOper := MODEL_OPERATION_UPDATE	
	//Carrega o modelo de dados
	oModel := FwLoadModel("FINA024TIT")
	oModel:Activate()
	
	//Inicializa variáveis
	cIdRet    := oModel:GetValue("FKLMASTER", "FKL_IDRET")
	cCodigo   := oModel:GetValue("FKLMASTER", "FKL_CODIGO")
	__lAltAll := FinVldExc("FKK", "FKL", cIdRet, cCodigo) 
	aButtons  := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	
	FWExecView(STR0003, "FINA024TIT", MODEL_OPERATION_UPDATE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )
	
	__nOper := 0
	__lAltAll := .F.
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKL->(DbSetOrder(2)) //FKL_FILIAL+FKL_CODIGO
Return Nil

//---------------------------------
/*/{Protheus.doc} F24TITEXC
Define a operação de exclusão
@author  Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function F24TITEXC()
	Local oModel   As Object
	Local aButtons As Array
	Local lExclui  As Logical
	Local cCodigo  As Character
	Local cIdRet   As Character	
	
	//Carrega o modelo
	oModel   := FwLoadModel("FINA024TIT")
	oModel:SetOperation(MODEL_OPERATION_DELETE)
	oModel:Activate()
	
	//Inicializa variáveis
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	cIdRet   := oModel:GetValue("FKLMASTER", "FKL_IDRET")
	cCodigo  := oModel:GetValue("FKLMASTER", "FKL_CODIGO")	
	lExclui  := FinVldExc("FKK", "FKL", cIdRet, cCodigo) 
	
	If lExclui
		FWExecView(STR0004, "FINA024TIT", MODEL_OPERATION_DELETE,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, oModel )
	Else
		Help(" ", 1, "FA024EXC", Nil, STR0007, 2, 0,,,,,, {}) //Não é permitido excluir regras de títulos que estejam vinculadas a uma regra financeira
	Endif
	
	oModel:Deactivate()
	oModel:Destroy()
	oModel:= Nil
	
	FKL->(DbSetOrder(2)) //FKL_FILIAL+FKL_CODIGO
Return

//---------------------------------
/*/{Protheus.doc} F024CODFKL()
Pos Validacao de preenchimento do código do registro de retenção
@author Sivaldo Oliveira
@since 10/09/2018
@version 12
/*/
//---------------------------------
Function F024CODFKL() As Logical
	Local lRet    	As Logical
	Local oModel  	As Object
	Local oFKL    	As Object
	Local cCodigo 	As Character
	Local lAchou  	As Logical
	Local cCab    	As Character
	Local cDes    	As Character
	Local cSol    	As Character
	Local aArea		As Array
	
	//Inicializa variáveis
	oModel  := FWModelActive()
	oFKL    := oModel:GetModel("FKLMASTER")
	cCodigo := oFKL:GetValue("FKL_CODIGO")
	cCab	:= ""
	cDes	:= ""
	cSol	:= ""
	
	lRet	:= .F.
	lAchou	:= .F.
	aArea	:= {}  

	If !Empty(cCodigo)
		aArea  := FKL->(GetArea())
		FKL->(DbSetOrder(2))
		If FKL->(MSSeek(xFilial("FKL") + cCodigo))
			lAchou := .T.
		Endif
		FKL->(RestArea(aArea))
	EndIf
	
	If __nOper != MODEL_OPERATION_INSERT .And. __nOper != OPER_COPIAR
		cCab := STR0008 //Código
		cDes := STR0009 //Operação não permitida
		cSol := STR0010 //Este campo não pode ser alterado
	ElseIf !FreeForUse("FKL", "FKL_CODIGO" + xFilial("FKL") + cCodigo)
		cCab := STR0008 //Código
		cDes := STR0014 +": " + cCodigo + " " + STR0011 //O código encontra - se em uso
		cSol := STR0012 //Código se encontra reservado
	ElseIf lAchou
		cCab := STR0008 //Código
		cDes := STR0014 + ": " + cCodigo + " " + STR0013 //O código já se encontra cadastrado
		cSol := STR0015 //Digite um novo código
	Else
		lRet := .T.
	EndIf

	If !Empty(cCab+cDes+cSol)
		HELP(' ',1, cCab ,, cDes ,2,0,,,,,, {cSol} )
	EndIf
Return lRet

//---------------------------------
/*/{Protheus.doc} F24TITPAR()
Validação do Fornecedor/Cliente

@author Sivalo Oliveira
@since	10/09/2017
@version 12
/*/
//---------------------------------
Function F24TITPAR() As Logical
	Local cCodigo  As Character 
	Local cLoja    As Character
	Local oModel   As Object
	Local oFKL     As Object
	Local lRet     As Logical
	Local cAlias   As Character
	
	//Inicializa variáveis
	lRet      := .T.
	oModel    := FWModelActive()
	oFKL      := oModel:GetModel("FKLMASTER")
	cCodigo	  := oFKL:GetValue("FKL_PARTIC")
	cLoja	  := oFKL:GetValue("FKL_LOJA")
	cParticip := oFKL:GetValue("FKL_RTPART")
	
	If !Empty(cCodigo) .And. !Empty(cLoja) .And. !Empty(cParticip)
		cAlias := If(cParticip == "1", "SA2", "SA1")
		(cAlias)->(dbSetOrder(1))
		
		If (cAlias)->(DbSeek(xFilial(cAlias) + cCodigo + cLoja))
			If cAlias == "SA2"
				oFKL:LoadValue("FKL_LOJA", SA2->A2_LOJA)
			Else
				oFKL:LoadValue("FKL_LOJA",SA1->A1_LOJA)
			EndIF
		Else
			HELP(' ',1,"F024FORNECE" ,,STR0032,2,0,,,,,, {STR0033})
			lRet := .F.
		EndIf
	ElseIf Empty(cParticip)
		oModel:LoadValue("FKLMASTER", "FKL_PARTIC", "  ")
		oModel:LoadValue("FKLMASTER", "FKL_LOJA", "  ")
		oModel:LoadValue("FKLMASTER", "FKL_DSCNAT", "  ")
	EndIf
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24TITCF3()
Consulta Padrao F3

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Static Function F24TITCF3(cCampo As Character) AS Character
	Local oModel    As Object
	Local oFKL      As Object
	Local cParticip As Character
	Local cF3       As Character
	
	Default cCampo := "" 
	
	//Inicializa variáveis
	oModel    := FWModelActive()
	oFKL      := oModel:GetModel("FKLMASTER")
	cParticip := oFKL:GetValue("FKL_RTPART")
	cF3       := ""	
	
	cCampo := AllTrim(cCampo)
	
	If cCampo == "FKL_TIPO"
		cF3 := "FKMTIP"
	ElseIf cCampo == "FKL_PARTIC" .And. !Empty(cParticip) 
		cF3 := If(cParticip == "1", "FOR", "SA1")  
	EndIf 
Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F24TITNAT()
Validação do código de natureza

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//-------------------------------------------------------------------
Function F24TITNAT() As Logical	
	Local lRet    As Logical
	Local oModel  As Object
	Local oFKL    As Object
	Local cNatur  As Character	
	
	//Inicializa variáveis
	lRet   := .T.     
	oModel := FWModelActive()
	oFKL   := oModel:GetModel("FKLMASTER")
	cNatur := oFKL:GetValue("FKL_NATUR")

	If !Empty(cNatur)
		SED->(dbSetOrder(1))
		
		If SED->(DbSeek(xFilial("SED")+cNatur)) .And. SED->ED_MSBLQL != "1"  
			lRet := If(oFKL:GetValue("FKL_CARTMV") == "1", SED->ED_USO $ "0|2| ", SED->ED_USO $ "0|1| ")
			
			If !lRet
				Help(' ', 1, "USO_NATUREZA" ,,STR0016, 2, 0,,,,,, {STR0017}) //O uso da natureza é incompatível com a carteira do tipo de retenção.
			Endif
		Else
			Help(' ',1, "COD_NATUREZA" ,,STR0018, 2, 0,,,,,, {STR0019}) //O código da natureza informado não se encontra cadastrado ou se encontra bloqueado para uso.
			lRet := .F.
		Endif
	EndIf
Return lRet

//---------------------------------------
/*/{Protheus.doc} F24TITTIP()
Valida o típo de título a ser gerado
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24TITTIP() As Logical
	
	Local lRet      As Logical
	Local oModel    As Object
	Local oFKL      As Object
	Local cTipo     As Character
	Local cTipoMov  As Character
	Local cTiposImp As Character


	//Inicializa variáveis
	lRet	:= .T.
	oModel	:= FWModelActive()
	oFKL	:= oModel:GetModel("FKLMASTER")   
	cTipo	:= oFKL:GetValue("FKL_TIPO")
	cTipoMov := oFKL:GetValue("FKL_TIPMOV")
	cTiposImp := SuperGetMv("MV_TIPIMP",.T.,"ISS|INS|IRF|PIS|TX |COF|CSL")
	cTiposImp += '|'+ MVTXA + '|INA'
	
	If !Empty(cTipo)
		If !SX5->(MsSeek(xFilial("SX5") + "05"+ cTipo))
			lRet := ExibeHelp("COD_TIPO", STR0034, STR0035)
		EndIf
	EndIf

	IF lRet
		If cTipoMov == '1'		//Abatimento
			lRet := (cTipo $ MVABATIM .and. ctipo != "AB-")
		Else					//Impostos
			lRet := (cTipo $ cTiposImp )
		EndIF
	EndIF

Return lRet

//---------------------------------------
/*/{Protheus.doc} FIN024TFI()
Filtro da consulta FKMTIP (SXB)

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function FIN024TFI() As Character
	Local cTipMov   As Character
	Local cFiltro   As Character
	Local cMvTxa    As Character
	Local cAbtim    As Character
	Local cTiposImp As Character
	Local oModel    As Object
	Local oFKL      As Object
	Local nX        As Numeric
	Local aTiposImp As Array
	Local aMvTxa    As Array
	Local aAbtim    As Array
	
	//Inicializa variáveis
	cFiltro   := ""
	cMvTxa    := ""
	cAbtim    := ""
	cTiposImp := SuperGetMv("MV_TIPIMP",.T.,"ISS|INS|IRF|PIS|TX |COF|CSL")
	oModel    := FWModelActive()
	oFKL      := oModel:GetModel("FKLMASTER")
	nX		  := 0
	cTipMov   := oFKL:GetValue("FKL_TIPMOV")
	aMvTxa    := {}
	aAbtim    := {} 
	
	If !Empty(cTiposImp)
		aTiposImp := Strtokarr2( cTiposImp, "|", .F.)
		cTiposImp := ""
		
		For nX := 1 to Len(aTiposImp)
			cTiposImp += If(nX < Len(aTiposImp), Padr(aTiposImp[nX], 6)+ '|', Padr(aTiposImp[nX], 6))
		Next
	EndIf
	
	If cTipMov == "2"
		aMvTxa := Strtokarr2( MVTXA, "|", .F.)
		nMvTxa := Len(aMVTXA)
		
		For nX := 1 to nMvTxa
			cMVTXA += If(nX < nMvTxa, Padr(aMvTxa[nX], 6) +'|', Padr(aMvTxa[nX], 6))
		Next nX
		
		cFiltro += cTiposImp + cMVTXA + '|INA   '
	Else
		aAbtim  := Strtokarr2(MVABATIM, "|", .F.)
		nAbatim := Len(aAbtim)
		
		For nX := 1 to nAbatim 
			If AllTrim(aAbtim[nX]) == "AB-"
				Loop
			EndIf 
			
			cAbtim += If(nX < nAbatim, Padr(aAbtim[nX], 6) + "|", Padr(aAbtim[nX], 6))
		Next  	
		
		cFiltro += cAbtim
	EndIf
	
Return cFiltro

//---------------------------------------
/*/{Protheus.doc} F24TITWhe()
Define se campos: Cód. Partic e Loja
serão habilitados para edição

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24TITWhe() As Logical
	Local lRet As Logical
	Local oModel As Object
	Local oFKL As Object
		
	oModel := FWModelActive()
	oFKL   := oModel:GetModel("FKLMASTER")
	lRet   := !Empty(oFKL:GetValue("FKL_RTPART"))
	
	If Empty(oFKL:GetValue("FKL_RTPART")) 		
		oModel:LoadValue("FKLMASTER", "FKL_PARTIC", " ")
		oModel:LoadValue("FKLMASTER", "FKL_LOJA", " ")
	ElseIf __nOper == OPER_COPIAR .And. __lFirst
		oModel:LoadValue("FKLMASTER", "FKL_CODIGO", " ")
		oModel:LoadValue("FKLMASTER", "FKL_DESCR",  " ")
		__lFirst := .F.
	EndIf 

Return lRet

//---------------------------------------
/*/{Protheus.doc} F24TITINI()
Inicicia padrão campo virtual FKL_DSCPAR

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24TITINI(cCampo As Character)
	Local oModel  As Object
	Local oFKL    As Object
	Local cCodigo As Character
	Local cLoja   As Character
	Local cPartic As Character
	Local cRet    As Character
	
	Default cCampo := "" 
	
	//Inicializa variáveis
	oModel  := FWModelActive()
	oFKL    := oModel:GetModel("FKLMASTER")
	cPartic := oFKL:GetValue("FKL_RTPART")
	cRet    := "" 
	
	If !Empty(cPartic)
		cCampo  := AllTrim(cCampo)
		cCodigo := oFKL:GetValue("FKL_PARTIC")
		cLoja   := oFKL:GetValue("FKL_LOJA")  
		
		If cCampo == "FKL_DSCPAR"
			If !Empty(cCodigo) .And. !Empty(cLoja) 
				If cPartic == "1" 
					cRet := Posicione("SA2", 1, xFilial("SA2") + cCodigo + cLoja, "A2_NOME")
				Else
					cRet := Posicione("SA1", 1, xFilial("SA1") + cCodigo + cLoja, "A1_NOME")
				EndIf
			EndIf
		EndIf
		cRet := AllTrim(cRet)
	EndIf
	If cCampo == "FKL_DSCNAT"
		cCodigo := oFKL:GetValue("FKL_NATUR")
		cRet	:= Iif(Empty(AllTrim(cCodigo)), "", Posicione("SED", 1, xFilial("SED") + cCodigo, "ED_DESCRIC") )
	EndIf

Return cRet

//---------------------------------------
/*/{Protheus.doc} F24TITIDR()
Inicializador do campo FKL_IDRET
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24TITIDR(oModel As Object)
	Local cRet   As Character
	Local aArea  As Array
	Local cChave As Character
	
	//Inicializa variáveis
	cRet   := ""
	cChave := ""
	
	If (__nOper == MODEL_OPERATION_INSERT .OR. __nOper == MODEL_OPERATION_UPDATE .OR. __nOper == OPER_COPIAR)
		aArea  := FKL->(GetArea())
		
		While .T.
			cRet := FWUUIDV4()
			FKL->(DbSetOrder(1))
			cChave := (xFilial("FKL") + cRet)  
			If !(FKL->(MsSeek(cChave))) .And. FreeForUse("FKL", cRet)
				FKL->(RestArea(aArea))
				Exit	
			EndIf
		EndDo
		
		RestArea(aArea)
	Else
		cRet := FKL->FKL_IDRET
	EndIf

Return cRet

//---------------------------------------
/*/{Protheus.doc} F24TITCOP()
Define operacao de Cópia de 

@author  Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24TITCOP()
	Local aButtons As Array
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
	__nOper  := OPER_COPIAR
	__lFirst := .T.
	
	FWExecView(STR0006, "FINA024TIT", OP_COPIA,/*oDlg*/,/*bCloseOnOk*/,/*bOk*/,,aButtons,/*bCancel*/,/*cOperatId*/,/*cToolBar*/, /*oModel*/ )
	
	__nOper  := 0
	__lFirst := .F.
	
	FKL->(DbSetOrder(2)) //FKL_FILIAL+FKL_CODIGO
Return

//---------------------------------------
/*/{Protheus.doc} F24TITOK()
Pos validação do modelo de dados

@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F24TITOK() As Logical
	Local lRet    As Logical
	Local oModel  As Object
	Local oFKL    As Object
	Local cTipMov As Character
	Local cCart   As Character
	Local cPartic As Character
	
	//Inicializa variáveis
	lRet   := .T.
	oModel 	:= FWModelActive()
	oFKL   	:= oModel:GetModel("FKLMASTER")
	cTipMov := oFKL:GetValue("FKL_TIPMOV")
	cCart   := oFKL:GetValue("FKL_CARTMV")
	cPartic := oFKL:GetValue("FKL_RTPART")
	
	If lRet .And. Empty(oFKL:GetValue("FKL_TIPO"))
		lRet := ExibeHelp("FKLTIPO", STR0020, STR0021) //O campo tipo de título não foi preenchido.
	EndIf	
	
	If lRet .And. Empty(cTipMov)
		lRet := ExibeHelp("FKLTIPMOV", STR0022, STR0023) //O Campo tipo de movimento não foi preenchido.
	EndIf
	
	If lRet .And. cTipMov == "1" .And. (cPartic != "2" .Or. cCart != "2") 
		lRet := ExibeHelp("FKLCARTMV", STR0024, STR0025) //A carteira não pode ser pagamento quando o tipo de movimento é abatimento.
	EndIf	
	
	If lRet .And. cTipMov == "2" .And. cPartic == "2" .And. cCart != "2"
		lRet := ExibeHelp("FKLCARTMV", STR0026, STR0027) //A carteira não pode ser recebimento quando o tipo de movimento é imposto.
	EndIf	
	
	If lRet .And. cTipMov == "2" .And. cPartic == "1" .And. cCart != "1" 
		lRet := ExibeHelp("FKLCARTMV", STR0030, STR0031)
	EndIf
	
	__lConfirmou := lRet 	
Return lRet

//---------------------------------------
/*/{Protheus.doc} F024TITREF()
Atualiza a visualização dos dados na view
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function F024TITREF(oView As Object)
	oView:Refresh()
Return .T.

//---------------------------------------
/*/{Protheus.doc} ExibeHelp()
Função generica para mostrar help
@author Sivaldo Oliveira
@since	10/09/2018
@version 12
/*/
//---------------------------------------
Function ExibeHelp(cNomeHelp As Character, cInfoHelp As Character, cSoluHelp As Character) As Logical
	Local lRet As Logical
	
	//Inicializa variáveis
	lRet := .F.
	Default cNomeHelp := ""
	Default cInfoHelp := ""
	Default cSoluHelp := ""
	
	Help(" ", 1, cNomeHelp, Nil, cInfoHelp, 2, 0,,,,,, {cSoluHelp})
Return lRet