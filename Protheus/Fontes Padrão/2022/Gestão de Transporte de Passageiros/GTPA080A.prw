#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA080A.CH"


/*/{Protheus.doc} GTPA080A()
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA080A()
Local oModel := FwLoadModel('GTPA080A')

oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()

Private aDados := {}


FwExecView(STR0001, "VIEWDEF.GTPA080A",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,20/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel) // "Seleção de Agências"

Return aDados

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@sinc e06/07/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCab	:= FwFormModelStruct():New() 
Local oStruGrd  := FwFormModelStruct():New()
Local bLoad		:= {|oModel| GA080ALoad(oModel)}
Local bCommit   := {|oModel| GA080ACommit(oModel)}

oModel := MPFormModel():New("GTPA080A",/*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStruct(oStruCab, oStruGrd)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

oModel:SetDescription(STR0001) 						// "Seleção de Agências"
oModel:GetModel("HEADER"):SetDescription(STR0002) 	// "Filtro"
oModel:GetModel("GRID"):SetDescription(STR0003) 	// "Agências"
oModel:SetPrimaryKey({})

oModel:GetModel("GRID"):SetMaxLine(99999)	

oModel:GetModel('GRID'):SetNoDeleteLine(.T.)

oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel("GTPA080A")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruGrd	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Seleção de Agências"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddGrid('VIEW_GRID' ,oStruGrd,'GRID')

oView:CreateHorizontalBox('HEADER', 35)
oView:CreateHorizontalBox('GRID', 65)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID','GRID')

oView:EnableTitleView("VIEW_HEADER", STR0002)	// "Filtro"
oView:EnableTitleView("VIEW_GRID", STR0003)		// "Agências"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0004, "", {|oView| FwMsgRun(,{|| GA080APesq(oView)},, STR0007)},/*cToolTip*/ ,VK_F5/*nShortCut*/) 	// ""Pesquisar <F5>", " "Pesquisando agências..."
oView:AddUserButton(STR0005, "", {|oView| SetMarkGrd(oView,.T.)},/*cToolTip*/ ,VK_F6/*nShortCut*/)  						// "Marcar Todos <F6>"
oView:AddUserButton(STR0006, "", {|oView| SetMarkGrd(oView,.F.)},/*cToolTip*/ ,VK_F7/*nShortCut*/) 							// "Desmarcar Todos <F7>"

oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0
@param oStruct, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMdlStru(oStruCab, oStruGrd)
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }
Local bFldTrig  := {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}

	If ValType(oStruCab) == "O"

		oStruCab:AddField(STR0008, STR0008,"AGEINI"		,"C", TamSx3('GI6_CODIGO')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	// "Agência De"
		oStruCab:AddField(STR0009, STR0009,"AGEFIM"		,"C", TamSx3('GI6_CODIGO')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	// "Agência Até"
		oStruCab:AddField("Tipo de Agência", "Tipo de Agência","TIPO"		,"C", TamSx3('GI6_TIPO')[1], 0,{|| .T.},{|| .T.},{},.F.,{|| "3"},.F.,.F.,.T.)	// "Tipo de Agência"

        oStruCab:AddTrigger("AGEINI","AGEFIM", { || .T. }, bFldTrig)
	    oStruCab:SetProperty("AGEFIM", MODEL_FIELD_VALID, bFldVld)
		
	Endif	

	If ValType(oStruGrd) == "O"

		oStruGrd:AddField("",		"",	  "GI6_MARK"	,"L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
		oStruGrd:AddField(STR0010, STR0010,"GI6_CODIGO"	,"C",TamSx3('GI6_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Código"
		oStruGrd:AddField(STR0011, STR0011,"GI6_DESCRI"	,"C",TamSx3('GI6_DESCRI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Descrição"
		oStruGrd:AddField(STR0012, STR0012,"GI6_TIPO"	,"C",TamSx3('GI6_TIPO')[1],0,{|| .T.},{|| .T.},{"1=Própria","2=Terceirizada","3=Todas"},.F.,NIL,.F.,.T.,.T.)		// "Tipo"
		oStruGrd:AddField("Cód. Local.", "Cód. Local.","GI6_LOCALI"	,"C",TamSx3('GI6_LOCALI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		// "Cód. Local."
		oStruGrd:AddField("Descr. Local.", "Descr. Local.","GI6_DESLOC"	,"C",TamSx3('GI6_DESLOC')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)		// "Descr. Local."


	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruGrd)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("AGEINI" 		,"01",STR0008,STR0008,{""},"GET","",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Agência De"
		oStruCab:AddField("AGEFIM"  	,"02",STR0009,STR0009,{""},"GET","",NIL,"GI6",.T.,NIL,NIL,{},NIL,NIL,.F.) 	// "Agência Até"
		oStruCab:AddField("TIPO"  	,"03","Tipo de Agência","Tipo de Agência",{""},"COMBO","",NIL,"",.T.,NIL,NIL,{"1=Própria","2=Terceirizada","3=Todas"},NIL,NIL,.F.) 	// "Tipo de Agência"

	Endif
	
	If ValType(oStruGrd) == "O"

		oStruGrd:AddField("GI6_MARK"	,"01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
		oStruGrd:AddField("GI6_CODIGO"	,"02",STR0010,STR0010,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				// "Código"
		oStruGrd:AddField("GI6_DESCRI"	,"03",STR0011,STR0011,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)				// "Descrição"
		oStruGrd:AddField("GI6_TIPO"	,"04",STR0012,STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{STR0020,STR0021},NIL,NIL,.F.)	// "Tipo", "1=Propria", "2=Terceirizada"
		oStruGrd:AddField("GI6_LOCALI"	,"05","Cód. Local.","Cód. Local.",{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	// "Cód. Local."
		oStruGrd:AddField("GI6_DESLOC"	,"06","Descr. Local.","Descr. Local.",{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	// "Descr. Local."

	Endif

Return

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue) 
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
		lRet := .T.
    
    Case cField == "AGEFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('AGEINI')
            lRet     := .F.
            cMsgErro := STR0013 // "Agência final não pode ser menor que a agência inicial"
            cMsgSol  := STR0014 // "Altere a agência final" 
        Endif

EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet

/*/{Protheus.doc} FieldTrigger
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
	Case cField == 'AGEINI' 
		oMdl:SetValue('AGEFIM', uVal)	
EndCase

Return uVal

/*/{Protheus.doc} GA200BLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA080ALoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} GA080ACommit
(long_description)
@type  Static Function
@author flavio.martins
@since 06/07/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA080ACommit(oModel)
Local oMdlGrid 	:= oModel:GetModel('GRID')
Local nX 		:= 0

For nX := 1 To oMdlGrid:Length()

	If oMdlGrid:GetValue('GI6_MARK', nX) 
		aadd(aDados,oMdlGrid:GetValue('GI6_CODIGO', nX))
	Endif

Next

Return .T.

/*/{Protheus.doc} GA080APesq
//TODO DescriÃ§Ã£o auto-gerada.
@author flavio.martins
@since 06/07/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA080APesq(oView)
Local lRet 			:= .T.
Local cAliasGI6		:= GetNextAlias()
Local oMdlHead		:= oView:GetModel():GetModel('HEADER')
Local oMdlGrid		:= oView:GetModel():GetModel('GRID')
Local cAgeIni		:= oMdlHead:GetValue('AGEINI')
Local cAgeFim		:= oMdlHead:GetValue('AGEFIM')
Local cTipoAg		:= oMdlHead:GetValue('TIPO')
Local cQuery 		:= ''

If Empty(cAgeIni) .Or. Empty(cAgeFim)
	FwAlertHelp(STR0015, STR0016, STR0017) // "Intervalo de agências não informado", "Informe um intervalo para pesquisa das agências", "Atenção"
	Return
Endif

oMdlGrid:ClearData()

If cTipoAg $ '1|2'
	cQuery := " AND GI6.GI6_TIPO = '" + cTipoAg + "' "
Endif

cQuery := "%" + cQuery + "%"

BeginSql  Alias cAliasGI6

	SELECT GI6_CODIGO,
		GI6_DESCRI,
		GI6_TIPO,
		GI6_LOCALI,
        GI1_DESCRI
	FROM %Table:GI6% GI6
	LEFT JOIN %Table:GI1% GI1 ON GI1.GI1_FILIAL = %xFilial:GI1%
	AND GI1.GI1_COD= GI6.GI6_LOCALI
	AND GI1.%NotDel%
	WHERE GI6.GI6_FILIAL = %xFilial:GI6%
	AND GI6.GI6_CODIGO BETWEEN %Exp:cAgeIni% AND %Exp:cAgeFim%
	AND GI6.GI6_MSBLQL = '2'
    AND GI6.GI6_CODH63 = ''
	%Exp:cQuery%
	AND GI6.%NotDel%

EndSql

If (cAliasGI6)->(!EoF())

	While !(cAliasGI6)->(Eof())

		If !(oMdlGrid:SeekLine({{"GI6_CODIGO",(cAliasGI6)->GI6_CODIGO}}))

			If !(oMdlGrid:IsEmpty())
				oMdlGrid:AddLine()
			Endif

			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_MARK"})[1],.T.)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_CODIGO"})[1],(cAliasGI6)->GI6_CODIGO)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_DESCRI"})[1],(cAliasGI6)->GI6_DESCRI)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_TIPO"})[1],(cAliasGI6)->GI6_TIPO)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_LOCALI"})[1],(cAliasGI6)->GI6_LOCALI)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_DESLOC"})[1],(cAliasGI6)->GI1_DESCRI)
			
		Endif
			
		(cAliasGI6)->(dbSkip())

	End

Else 
    FwAlertHelp(STR0018, STR0019, STR0017) // "Não foram encontradas agências com os parâmetros informados", "Altere os parâmetros", "Atenção"
Endif

oMdlGrid:GoLine(1)

(cAliasGI6)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} SetMarkGrd
//TODO DescriÃ§Ã£o auto-gerada.
@author flavio.martins
@since 06/07/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function SetMarkGrd(oView, lMark)
Local oMdlGrid	:= oView:GetModel():GetModel('GRID')
Local nX		:= 0

For nX := 1 To oMdlGrid:Length()
	oMdlGrid:GoLine(nX)
	oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GI6_MARK"})[1], lMark)
Next

oMdlGrid:GoLine(1)

Return
