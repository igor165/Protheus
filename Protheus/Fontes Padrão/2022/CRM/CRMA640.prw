#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA640.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640

Rotina para cadastro de territ�rio   

@sample     CRMA640()

@param      cFunction  - Fun��o que ser� chamada 
             cEntidade  - Alias correnpondente a fun��o

@return     Nenhum

@author     Ronaldo Robes
@since      12/05/2015
@version    12.1.5
/*/
//------------------------------------------------------------------------------
Function CRMA640()

Local oBrowse := FwMBrowse():New()

oBrowse:SetCanSaveArea(.T.) 
oBrowse:SetAlias("AOY")
oBrowse:SetDescription( STR0001 ) //Cadastro de Dimens�es Territoriais
oBrowse:DisableDetails()
oBrowse:DisableReport()
oBrowse:Activate()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Fun��o que cria estrutura de menus do browse   

@sample	ModelDef()

@param		Nenhum
             
@return	aRotina - Array com fun��es do menu

@author	Ronaldo Robes
@since		12/05/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
Local aRotExc	:= {}

//-----------------------------
// Cria sub menus de exclus�o
//-----------------------------
ADD OPTION aRotExc TITLE STR0017 ACTION "VIEWDEF.CRMA640" OPERATION 5	ACCESS 0 // Excluir Territ�rio
ADD OPTION aRotExc TITLE STR0018 ACTION "CRMA640Rdz(5)"   OPERATION 5	ACCESS 0 // Excluir Rod�zio

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CRMA640" OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CRMA640" OPERATION 3 ACCESS 0 //"Incluir" 
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CRMA640" OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION aRotExc           OPERATION 5 ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0015 ACTION "CRMA640Rdz()"    OPERATION 6 ACCESS 0 //"Rod�zio"

Return (aRotina)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Fun��o que cria modelo de dados   

@sample	ModelDef()

@param		Nenhum
             
@return	oModel - Objeto com estrutura do modelo de dados

@author	Ronaldo Robes
@since		12/05/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel		:= Nil
Local oStruAOY	:= Nil
Local oStruA09	:= Nil
Local oStruA00	:= Nil
Local oStruAOZ  	:= Nil
Local bPos			:= {|oModel| CRM640VGrd(oModel)}
Local bCommit  	:= {|oModel| FWFormCommit(oModel,,,, {|oModel| CRM930GENR(oModel) },,) }

// Cria estruturas para o modelo
oStruAOY 	:= FWFormStruct(1,"AOY")
oStruA09 	:= FWFormStruct(1,"A09")
oStruA00 	:= FWFormStruct(1,"A00")
oStruAOZ	:= FWFormStruct(1,"AOZ")

//-------------------------------------------------------------------
// Define os gatilhos.  
//-------------------------------------------------------------------
oStruA00:AddTrigger( "A00_NIVAGR", "A00_IDINT",, {| oModel, cField, cValue | CRM640Trigger( oModel, cField, cValue ) } )

// Cria valida��o no campo de territ�rio pai
oStruAOY:SetProperty("AOY_SUBTER",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"CRMA640VldPai(FwFldGet('AOY_CODTER'),FwFldGet('AOY_SUBTER'))"))

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New("CRMA640",/*bPre*/, bPos, bCommit,/*bCancel*/)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields("AOYMASTER",,oStruAOY)

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
oModel:AddGrid("A09DETAIL","AOYMASTER",oStruA09,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
oModel:AddGrid("AOZDETAIL","AOYMASTER",oStruAOZ,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)
oModel:AddGrid("A00DETAIL","AOZDETAIL",oStruA00,/*bLinePre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVal*/,/*BLoad*/)

// Relacionamentos
oModel:SetRelation("A09DETAIL",{{"A09_FILIAL", "xFilial('A09')"},{"A09_CODTER", "AOY_CODTER"}},A09->(IndexKey(1)))
oModel:SetRelation("AOZDETAIL",{{"AOZ_FILIAL", "xFilial('AOZ')"},{"AOZ_CODTER", "AOY_CODTER"}},AOZ->(IndexKey(1)))
oModel:SetRelation("A00DETAIL",{{"A00_FILIAL", "xFilial('A00')"},{"A00_CODTER", "AOY_CODTER"},{"A00_CODAGR","AOZ_CODAGR"}},A00->(IndexKey(1)))

// Bloqueia linha duplicada
oModel:GetModel("A09DETAIL"):SetUniqueLine({"A09_TPMBRO","A09_CODMBR"})
oModel:GetModel("AOZDETAIL"):SetUniqueLine({"AOZ_CODAGR"})
oModel:GetModel("A00DETAIL"):SetUniqueLine({"A00_NIVAGR"})

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0001 ) //Cadastro de Dimens�es Territoriais

// Adiciona Chave Primaria 
oModel:SetPrimarykey({"AOY_CODTER"})

oModel:GetModel( "A09DETAIL" ):SetLPre( { || CRM640LookUp() } )
Return(oModel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Fun��o que estrutura visual do modelo   

@sample	ViewDef()

@param		Nenhum
             
@return	oView - Objeto com estrutura de visualiza��o

@author	Ronaldo Robes
@since		12/05/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oView		:= Nil
Local oStruAOY	:= FWFormStruct(2,"AOY")
Local oStruA09 	:= FWFormStruct(2,"A09")
Local oStruA00	:= FWFormStruct(2,"A00")
Local oStruAOZ	:= FWFormStruct(2,"AOZ")
Local oModel		:= FWLoadModel("CRMA640")

// Cria o objeto de View
oView := FWFormView():New()

// Retira Campos nao utilizados	da visualiza��o
oStruA09:RemoveField("A09_CODTER")
oStruAOZ:RemoveField("AOZ_CODTER")
oStruA00:RemoveField("A00_CODTER")
oStruA00:RemoveField("A00_CODAGR")
oStruA00:RemoveField("A00_IDINT")

// Define qual o Modelo de dados ser� utilizado
oView:SetModel(oModel)

// Cria visualiza��o do cabe�alho
oView:AddField("VIEW_AOY",oStruAOY,"AOYMASTER")

// Cria visualiza��o dos grids
oView:AddGrid("VIEW_A00",oStruA00,"A00DETAIL")
oView:AddGrid("VIEW_A09",oStruA09,"A09DETAIL")
oView:AddGrid("VIEW_AOZ",oStruAOZ,"AOZDETAIL")

// Criar "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox("CORPO",100)

// Cria Folder na view
oView:CreateFolder("PASTAS","CORPO") 

// Cria pastas nas folders 
oView:AddSheet("PASTAS","ABA01", STR0006 ) // Territ�rio 
oView:AddSheet("PASTAS","ABA02", STR0007 )  // Dimens�es

oView:CreateHorizontalBox("FOL_AOY",30,,,"PASTAS","ABA01")
oView:CreateHorizontalBox("FOL_A09",70,,,"PASTAS","ABA01")
oView:CreateHorizontalBox("FOL_AOZ",40,,,"PASTAS","ABA02")
oView:CreateHorizontalBox("FOL_A00",50,,,"PASTAS","ABA02")

// Relaciona o ID da View com o "box" para exibicao 
oView:SetOwnerView("VIEW_AOY","FOL_AOY")
oView:SetOwnerView("VIEW_A09","FOL_A09")
oView:SetOwnerView("VIEW_A00","FOL_A00")
oView:SetOwnerView("VIEW_AOZ","FOL_AOZ")

// Habilita T�tulo da view
oView:EnableTitleView("VIEW_AOY", STR0006 )	// Territ�rio
oView:EnableTitleView("VIEW_A09", STR0008 )   // Membro x Territ�rio
oView:EnableTitleView("VIEW_AOZ", STR0009 )	// Agrupadores
oView:EnableTitleView("VIEW_A00", STR0010 )	// N�veis do Agrupador  

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM640RTer
                                   
Fun��o que filtra os agrupadores quando existe subterrit�rio

@sample	CRM640RTer()

@param	  	Nenhum

@return	cFiltro - Express�o de retorno do filtro

@author	Anderson Silva
@since		25/05/2015
@version	12
@Obs		Fun��o utilizada no filtro da consulta padr�o AOZ
/*/ 
//-----------------------------------------------------------------------------
Function CRM640RTer()

Local oModel 	:= FwModelActive()
Local cCodTer	:= ""
Local cFiltro := "@#.T.@#"

If ValType(oModel) == "O"
	If oModel:GetId() == "CRMA640"
		cCodTer := FwFldGet("AOY_SUBTER")
		If !Empty(cCodTer)
			cFiltro := "@#AOZ->AOZ_CODTER == " + cCodTer + "@#"
		EndIf
	EndIf
EndIf

Return(cFiltro)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM640Resp
                                   
Fun��o que valida se o foi selecionado um membro respons�vel pelo territ�rio

@sample	CRM640Resp()

@param	  	Nenhum

@return	lRet - L�gico .T.

@author	Jonatas Martins
@since		25/05/2015
@version	12
@Obs		Fun��o utilizada na valida��o padr�o (X3_RELACAO) do campo A09_RESTER
/*/ 
//-----------------------------------------------------------------------------
Function CRM640Resp()

Local oModel		:= FwModelActive()
Local oMdlGrdA09	:= oModel:GetModel("A09DETAIL")
Local oView		:= FwViewActive()
Local nLinAtu		:= 0
Local nX			:= 0

// Guarda posi��o da linha inicial do grid
nLinAtu := oMdlGrdA09:GetLine()

For nX := 1 To oMdlGrdA09:Length()
	
	oMdlGrdA09:GoLine(nX)
	
	If nX <> nLinAtu .And. oMdlGrdA09:GetValue("A09_RESTER")
		If MsgYesNo( STR0011, STR0012 ) //"O territ�rio j� possui um respons�vel, deseja alterar ?"###"Alterar Repons�vel"
			oMdlGrdA09:LoadValue("A09_RESTER",.F.)
			
			//Restaura posi��o original da grid
			oMdlGrdA09:GoLine(nLinAtu)			
			oView:Refresh()
			Exit
		Else
			oMdlGrdA09:GoLine(nLinAtu)
			oMdlGrdA09:LoadValue("A09_RESTER",.F.)
			Exit
		EndIf
	EndIf

Next nX

Return .T.

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM640VGrd
                                   
Fun��o que valida o preenchimento do campo A09_RESTER no grid

@sample	CRM640VGrd()

@param	  	Nenhum

@return	lRet - Retorna .T. se o campo A09_RESTER no grid estiver selecionado 

@author	Jonatas Martins
@since		25/05/2015
@version	12
@Obs		Fun��o utilizada na valida��o padr�o (X3_RELACAO) do campo A09_RESTER
/*/ 
//-----------------------------------------------------------------------------
Static Function CRM640VGrd(oModel)

Local oMdlGrdA09	:= oModel:GetModel("A09DETAIL")
Local lRet			:= .F.
Local nX			:= 0
Local nLinAtu		:= 0

// Guarda posi��o da linha inicial do grid
nLinAtu := oMdlGrdA09:GetLine()

For nX := 1 To oMdlGrdA09:Length()
	oMdlGrdA09:GoLine(nX)
	If oMdlGrdA09:GetValue("A09_RESTER")
		lRet := .T.
		Exit
	EndIf
Next nX

If !lRet
	Help("",1,"HELP","CRMA640",STR0013,1) // N�o foi selecionado um membro respons�vel para o territ�rio
EndIf

// Restaura posi��o da linha do grid
oMdlGrdA09:GoLine(nLinAtu)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM640LookUp
Define o LookUp do campo A09_CODMBR em tempo de execu��o.

@return .T. 	Indica que o campo pode ser editado.  

@author     Valdiney V GOMES
@version    12
@since      15/06/2015
/*/
//------------------------------------------------------------------------------
Function CRM640LookUp()
Local oView		:= FWViewActive()
Local oGrid 	:= oView:GetSubView("VIEW_A09") 
Local cValue 	:= FWFldGet("A09_TPMBRO")
Local cLookUp	:= ""

If ( cValue == "1" )
	cLookUp := "ADK"
ElseIf ( cValue == "2" )
	cLookUp := If(SuperGetMv("MV_CRMUAZS",, .F.), "USRPAP", "AO3")
ElseIf ( cValue == "3" )
	cLookUp := "ACA"
EndIf

oGrid:SetLookup( "A09_CODMBR", cLookUp ) 
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640Gat

Fun��o para acionar gatilho de prenchimento campo Descri�ao 

@sample	CRMA640Gat(cTpMemb, cCodMem)

@param		cTpMemb	-	Tipo do Membro
@param		cCodMem	- 	C�digo do Membro

@return	cDescricao	-	Decri��o do Membro

@author	Ronaldo Robes 

@since		12/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA640Gat(cTpMemb, cCodMem)

Local cDescri	:= ""

Default cTpMemb   := ""
Default cCodMem   := ""

If !Empty(cTpMemb) .And. !Empty(cCodMem)
	cCodMem := AllTrim(cCodMem) 
	Do Case
  		Case cTpMemb == "1" //Unidade de Neg�cio
  			cDescri := AllTrim( Posicione("ADK",1,xFilial("ADK")+cCodMem,"ADK_NOME") )
  		Case cTpMemb == "2" //Papeis do Usu�rio
            If FindFunction("CRM210NUPAP")
            	cDescri := CRM210NUPap( cCodMem )
            Else
            	cDescri := AllTrim(UsrRetName(cCodMem))
            EndIf
      	Case cTpMemb == "3" //Equipe de Vendas
          	cDescri	:= AllTrim( Posicione("ACA",1,xFilial("ACA")+cCodMem,"ACA_DESCRI") )
	EndCase
EndIf 

Return( cDescri )

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640STer

Fun��o que valida o campo AOY_SUBTER para n�o adicionar o mesmo c�digo do territ�rio no campo  

@sample	CRMA640STer()

@param		Nenhum

@return	lRetorno	- 	Retorna .T. se o c�digo inserido for diferente do c�digo do territ�rio

@author	Jonatas Martins

@since		23/06/2015
@version	12.1.6
@obs		Fun��o chamada no configurador na valida��o do campo AOY_SUBTER 
/*/
//------------------------------------------------------------------------------------------------
Function CRMA640STer()

Local oModel 		:= FwModelActive()
Local lRetorno 	:= .T.

If ValType(oModel) == "O" .And. oModel:GetOperation() <> MODEL_OPERATION_INSERT
	If oModel:GetValue("AOYMASTER","AOY_CODTER") == FwFldGet("AOY_SUBTER")
		lRetorno := .F.
		Help("",1,"HELP","CRMA640",STR0014,1) // O c�digo do subterrit�rio n�o pode ser igual ao c�digo do territ�rio
	EndIf
EndIf

Return (lRetorno)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640Rdz

Fun��o para chamada da tela de rod�zio do territ�rio

@sample	CRMA640Rdz()

@param		nOperDelet, numerico, Tipo da opera��o

@return	Nenhum

@author	Jonatas Martins

@since		02/07/2016
@version	12.1.6
/*/
//------------------------------------------------------------------------------------------------
Function CRMA640Rdz(nOperDelet)

Local oModel	:= FwLoadModel("CRMA640")

oModel:SetOperation( MODEL_OPERATION_UPDATE )
oModel:Activate()

CRMA930(oModel, nOperDelet)

Return Nil

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA640VldPai()

Fun��o para validar a hierarquia de pai e evitar duplicidade

@sample	CRMA640VldPai()

@param		cCodTer, caracter, C�digo do territ�rio

@return	lRetorno, logico, Se .T. permite o vinculo com o pai

@author	Jonatas Martins

@since		23/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------------------------
Function CRMA640VldPai(cCodTer,cCodTerPai)

Local aSon	 := {}
Local lRetorno := .T.

Default cCodTer		:= ""
Default cCodTerPai	:= ""

If !Empty(cCodTer)
	//--------------------------------------
	// Obtem a estrutura de territ�rios pai
	//--------------------------------------
	aSon := CRMA640ASon(cCodTer)
	
	//---------------------------------------------
	// Verifica se o territ�rio j� est� vinculado
	//---------------------------------------------
	nPos := aScan(aSon, {|x| x == cCodTerPai})
	
	If nPos > 0
		lRetorno := .F.
	EndIf
Else
	lRetorno := .F.
EndIf

//------------------------
// Exibe mesnagem de help 
//------------------------
If !lRetorno
	Help("",1,"HELP","CRMA640VLDPAI",STR0016,1) // O territ�rio escolhido � um territ�rio filho!
EndIf 

Return (lRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM640Trigger
Trigger do campo A00_IDINT. 

@param oModel, objeto, Modelo de dados. 
@param cField, caracter, Campo a ser pesquisado. 
@param cValue, caracter, Conte�do do campo a ser pesquisado. 
@return cReturn, caracter, Descri��o do campo. 

@author     Valdiney V GOMES
@version    12
@since      18/11/2015
/*/
//------------------------------------------------------------------------------
Static Function CRM640Trigger( oMdlA00, cField, cValue )
	Local cReturn 	:= ""
	Local oModel 		:= Nil
	Local oMdlAOZ		:= Nil

	Default oMdlA00		:= Nil 
	Default cField		:= ""
	Default cValue		:= ""
	
	If oMdlA00 <> Nil
		oModel		:= oMdlA00:GetModel()
		oMdlAOZ	:= oModel:GetModel("AOZDETAIL")
		If ( cField == "A00_NIVAGR" )	
			//-------------------------------------------------------------------
			// Recupera o ID inteligente do n�vel do agrupador. 
			//-------------------------------------------------------------------
			cReturn := Posicione( "AOM", 1, xFilial("AOM") + oMdlAOZ:GetValue("AOZ_CODAGR") + cValue, "AOM_IDINT" )
		EndIf 
	EndIf
Return cReturn 