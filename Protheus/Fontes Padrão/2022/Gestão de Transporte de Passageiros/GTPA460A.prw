#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA460A.CH"

/*/{Protheus.doc} GTPA460A
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA460A(cAgencia, dDataMov)
Local oModel := FwLoadModel('GTPA460A')

oModel:SetOperation(MODEL_OPERATION_UPDATE)
oModel:Activate()
oModel:GetModel('HEADER'):SetValue('CODAGE', cAgencia)
oModel:GetModel('HEADER'):SetValue('DATA', dDataMov)

Private aDados := {}

FwExecView(STR0001,"VIEWDEF.GTPA460A",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel) // "Bilhetes vendidos por depósito de terceiros"

Return aDados

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
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
Local bLoad		:= {|oModel| GA460ALoad(oModel)}
Local bCommit   := {|oModel| GA460ACommit(oModel)}

oModel := MPFormModel():New("GTPA460A",/*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

SetMdlStru(oStruCab, oStruGrd)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

oModel:SetDescription(STR0002)        				// "Seleção de Bilhetes"
oModel:GetModel("HEADER"):SetDescription(STR0003)  	// "Filtro"
oModel:GetModel("GRID"):SetDescription(STR0004)  	// "Bilhetes"
oModel:SetPrimaryKey({})

oModel:GetModel("GRID"):SetMaxLine(99999)	

oModel:GetModel('GRID'):SetNoDeleteLine(.T.)

oModel:SetCommit(bCommit)

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA460A")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruGrd	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0002)     // "Seleção de Bilhetes"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddGrid('VIEW_GRID' ,oStruGrd,'GRID')

oView:CreateHorizontalBox('HEADER', 35)
oView:CreateHorizontalBox('GRID', 65)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID','GRID')

oView:EnableTitleView("VIEW_HEADER", STR0003)	// "Filtro"
oView:EnableTitleView("VIEW_GRID", STR0004)		// "Bilhetes"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:AddUserButton(STR0005, "", {|oView| FwMsgRun(,{|| GA460APesq(oView)},,STR0006)},/*cToolTip*/ ,VK_F5/*nShortCut*/) // "Pesquisar <F5>", "Pesquisando bilhetes..."
oView:AddUserButton(STR0007, "", {|oView| SetMarkGrd(oView,.T.)},/*cToolTip*/ ,VK_F6/*nShortCut*/) //"Marcar Todos <F6>"
oView:AddUserButton(STR0008, "", {|oView| SetMarkGrd(oView,.F.)},/*cToolTip*/ ,VK_F7/*nShortCut*/) //"Desmarcar Todos <F7>"

oView:GetViewObj("VIEW_GRID")[3]:SetSeek(.T.)
oView:GetViewObj("VIEW_GRID")[3]:SetFilter(.T.)

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
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

		oStruCab:AddField(STR0009,STR0009,"CODAGE"		,"C", TamSx3('GIC_AGENCI')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	// "Agência"
		oStruCab:AddField(STR0022,STR0022,"DATA" 		,"D", 8, 0, {|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 						// "Data da Venda"
		oStruCab:AddField(STR0012,STR0012,"BILHETEINI"	,"C", TamSx3('GIC_BILHET')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	// "Bilhete De"
		oStruCab:AddField(STR0013,STR0013,"BILHETEFIM"	,"C", TamSx3('GIC_BILHET')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)	// "Bilhete Ate"
		oStruCab:AddField(STR0014,STR0014,"COLABINI"	,"C", TamSx3('GIC_COLAB')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.)  	// "Colab. De"
		oStruCab:AddField(STR0015,STR0015,"COLABFIM"	,"C", TamSx3('GIC_COLAB')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 	// "Colab. Até"
		oStruCab:AddField(STR0016,STR0016,"LINHAINI"	,"C", TamSx3('GIC_LINHA')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 	// "Linha De"
		oStruCab:AddField(STR0017,STR0017,"LINHAFIM"	,"C", TamSx3('GIC_LINHA')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 	// "Linha Até"
		oStruCab:AddField(STR0018,STR0018,"CCFINI"		,"C", TamSx3('GIC_CCF')[1], 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 	// "CCF De"
		oStruCab:AddField(STR0019,STR0019,"CCFFIM"		,"C", TamSx3('GIC_CCF')[1], 0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 		// "CCF Até"

        oStruCab:AddTrigger("DATA","DATA"	 			, { || .T. }, bFldTrig)
        oStruCab:AddTrigger("COLABINI","COLABINI"		, { || .T. }, bFldTrig)
        oStruCab:AddTrigger("LINHAINI","LINHAINI"		, { || .T. }, bFldTrig)
        oStruCab:AddTrigger("CCFINI","CCFINI"	 		, { || .T. }, bFldTrig)
        oStruCab:AddTrigger("BILHETEINI","BILHETEINI"	, { || .T. }, bFldTrig)
		
	Endif	

	If ValType(oStruGrd) == "O"

		oStruGrd:AddField("",		"",	  "GIC_MARK"	,"L",1,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.)
		oStruGrd:AddField(STR0020,STR0020,"GIC_CODIGO"	,"C",TamSx3('GIC_CODIGO')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Código"
		oStruGrd:AddField(STR0021,STR0021,"GIC_BILHET"	,"C",TamSx3('GIC_BILHET')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Num.Bilhete"
		oStruGrd:AddField(STR0022,STR0022,"GIC_DTVEND"	,"D",8,0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 							// "Dt Emissão"
		oStruGrd:AddField(STR0023,STR0023,"GIC_VALTOT"	,"N",TamSx3('GIC_VALTOT')[1],2,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Valor. Total"
		oStruGrd:AddField(STR0024,STR0024,"GIC_COLAB"	,"C",TamSx3('GIC_COLAB')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Cód. Colab."
		oStruGrd:AddField(STR0025,STR0025,"GIC_NCOLAB"	,"C",TamSx3('GIC_NCOLAB')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Nome Colab."
		oStruGrd:AddField(STR0026,STR0026,"GIC_LINHA"	,"C",TamSx3('GIC_LINHA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Cód. Linha"
		oStruGrd:AddField(STR0027,STR0027,"GIC_NLINHA"	,"C",TamSx3('GIC_NLINHA')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Nome Linha"
		oStruGrd:AddField(STR0028,STR0028,"GIC_CHVBPE"	,"C",TamSx3('GIC_CHVBPE')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 	// "Chave BPe"
		oStruGrd:AddField(STR0029,STR0029,"GIC_CCF"		,"C",TamSx3('GIC_CCF')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.T.,.T.) 		// "CCF"

	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruGrd)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("CODAGE" 		,"01",STR0009,STR0009,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 				// "Agência"
		oStruCab:AddField("DATA" 		,"02",STR0022,STR0022,{""},"GET","",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.) 				// "Data De"
		oStruCab:AddField("BILHETEINI"	,"03",STR0012,STR0012,{""},"GET","",NIL,"GICBIL",.T.,NIL,NIL,{},NIL,NIL,.F.)		// "Bilhete De"
		oStruCab:AddField("BILHETEFIM"	,"04",STR0013,STR0013,{""},"GET","",NIL,"GICBIL",.T.,NIL,NIL,{},	NIL,NIL,.F.)	// "Bilhete Até"
		oStruCab:AddField("COLABINI"	,"05",STR0014,STR0014,{""},"GET","",NIL,"GYG",.T.,NIL,NIL,{},NIL,NIL,.F.)			// "Colab. De"
		oStruCab:AddField("COLABFIM"	,"06",STR0015,STR0015,{""},"GET","",NIL,"GYG",.T.,NIL,NIL,{},	NIL,NIL,.F.) 		// "Colab. Até"
		oStruCab:AddField("LINHAINI"	,"07",STR0016,STR0016,{""},"GET","",NIL,"GI2",.T.,NIL,NIL,{},NIL,NIL,.F.)			// "Linha De"
		oStruCab:AddField("LINHAFIM"	,"08",STR0017,STR0017,{""},"GET","",NIL,"GI2",.T.,NIL,NIL,{},	NIL,NIL,.F.)		// "Linha Até"
		oStruCab:AddField("CCFINI"		,"09",STR0018,STR0018,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)				// "CCF De"
		oStruCab:AddField("CCFFIM"		,"10",STR0019,STR0019,{""},"GET","",NIL,"",.T.,NIL,NIL,{},	NIL,NIL,.F.)			// "CCF Até"

	Endif
	
	If ValType(oStruGrd) == "O"

		oStruGrd:AddField("GIC_MARK"	,"01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
		oStruGrd:AddField("GIC_CODIGO"	,"02",STR0020,STR0020,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Código"
		oStruGrd:AddField("GIC_BILHET"	,"03",STR0021,STR0021,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Num.Bilhete"
		oStruGrd:AddField("GIC_DTVEND"	,"04",STR0022,STR0022,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Dt Emissão"
		oStruGrd:AddField("GIC_VALTOT"	,"05",STR0023,STR0023,{""},"GET","@E 999,999.99",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)	// "Val. Total"
		oStruGrd:AddField("GIC_COLAB"	,"06",STR0024,STR0024,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Cód.Colab."
		oStruGrd:AddField("GIC_NCOLAB"	,"07",STR0025,STR0025,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Nome Colab"
		oStruGrd:AddField("GIC_LINHA"	,"08",STR0026,STR0026,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Cód.Linha"
		oStruGrd:AddField("GIC_NLINHA"	,"09",STR0027,STR0027,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Nome Linha"
		oStruGrd:AddField("GIC_CHVBPE"	,"10",STR0028,STR0028,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "Chave BPe"
		oStruGrd:AddField("GIC_CCF"		,"11",STR0029,STR0029,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)			// "CCF"

	Endif

Return

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
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

    Case cField == "COLABFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('COLABINI')
            lRet     := .F.
            cMsgErro := STR0032 // "Colaborador final não pode ser menor que o colaborador inicial"
            cMsgSol  := STR0033 // "Altere o colaborador final"
        Endif

    Case cField == "LINHAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('LINHAINI')
            lRet     := .F.
            cMsgErro := STR0034 // "Linha final não pode ser menor que a linha inicial"
            cMsgSol  := STR0035 // "Altere a linha final"
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
@since 01/02/2022
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl,cField,uVal)

Do Case
	Case cField == 'COLABINI'
	    oMdl:SetValue('COLABFIM', uVal)
	Case cField == 'LINHAINI'
    	oMdl:SetValue('LINHAFIM', uVal)
	Case cField == 'BILHETEINI'
    	oMdl:SetValue('BILHETEFIM', uVal)
EndCase

Return uVal

/*/{Protheus.doc} GA200BLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA460ALoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} GA460ACommit
(long_description)
@type  Static Function
@author flavio.martins
@since 01/02/2022
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA460ACommit(oModel)
Local oMdlGrid 	:= oModel:GetModel('GRID')
Local nX 		:= 0

For nX := 1 To oMdlGrid:Length()

	If oMdlGrid:GetValue('GIC_MARK', nX) 
		aadd(aDados,oMdlGrid:GetValue('GIC_CODIGO', nX))
	Endif

Next

Return .T.

/*/{Protheus.doc} GA460APesq
//TODO Descrição auto-gerada.
@author flavio.martins
@since 01/02/2022
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Static Function GA460APesq(oView)
Local lRet 			:= .T.
Local cAliasGIC		:= GetNextAlias()
Local oMdlHead		:= oView:GetModel():GetModel('HEADER')
Local oMdlGrid		:= oView:GetModel():GetModel('GRID')
Local cAgencia		:= oMdlHead:GetValue('CODAGE')
Local cData			:= oMdlHead:GetValue('DATA')
Local cColabIni		:= oMdlHead:GetValue('COLABINI')
Local cColabFim		:= oMdlHead:GetValue('COLABFIM')
Local cLinhaIni		:= oMdlHead:GetValue('LINHAINI')
Local cLinhaFim		:= oMdlHead:GetValue('LINHAFIM')
Local cCCFIni		:= oMdlHead:GetValue('CCFINI')
Local cCCFFim		:= oMdlHead:GetValue('CCFFIM')
Local cBilheteIni	:= oMdlHead:GetValue('BILHETEINI')
Local cBilheteFim	:= oMdlHead:GetValue('BILHETEFIM')
Local cDescLin		:= ""
Local cQuery		:= ""

If !Empty(cColabIni) .And. !Empty(cColabFim)
	cQuery += " AND GIC.GIC_COLAB BETWEEN '" + cColabIni + "' AND '" + cColabFim + "' "
Endif

If !Empty(cLinhaIni) .And. !Empty(cLinhaFim)
	cQuery += " AND GIC.GIC_LINHA BETWEEN '" + cLinhaIni + "' AND '" + cLinhaFim + "' "
Endif

If !Empty(cCCFIni) .And. !Empty(cCCFFim)
	cQuery += " AND GIC.GIC_CCF BETWEEN '" + cCCFIni + "' AND '" + cCCFFim + "' "
Endif

If !Empty(cBilheteIni) .And. !Empty(cBilheteFim)
	cQuery += " AND GIC.GIC_BILHET BETWEEN '" + cBilheteIni + "' AND '" + cBilheteFim + "' "
Endif

cQuery := "%" + cQuery + "%"

oMdlGrid:ClearData()

BeginSql  Alias cAliasGIC

	SELECT GIC_CODIGO,
		GIC_BILHET,
		GIC_COLAB,
		GIC_LINHA,
		GIC_DTVEND,
		GIC_VALTOT,
		GIC_CHVBPE,
		GIC_SENTID,
		GIC_CCF,
		GYG.GYG_NOME,
		GI2.GI2_NUMLIN,
		GI1ORI.GI1_DESCRI AS LOCORI,
		GI1DES.GI1_DESCRI AS LOCDES
	FROM %Table:GIC% GIC
	LEFT JOIN %Table:GYG% GYG ON GYG.GYG_FILIAL = %xFilial:GYG%
	AND GYG.GYG_CODIGO = GIC.GIC_COLAB
	AND GYG.%NotDel%
	LEFT JOIN %Table:GI2% GI2 ON GI2.GI2_FILIAL = %xFilial:GI2%
	AND GI2.GI2_COD = GIC.GIC_LINHA
	AND GI2.GI2_HIST ='2'
	AND GI2.%NotDel%
	LEFT JOIN %Table:GI1% GI1ORI ON GI1ORI.GI1_FILIAL = %xFilial:GI1%
	AND GI1ORI.GI1_COD= GI2.GI2_LOCINI
	AND GI1ORI.%NotDel%
	LEFT JOIN %Table:GI1% GI1DES ON GI1DES.GI1_FILIAL = %xFilial:GI1%
	AND GI1DES.GI1_COD = GI2.GI2_LOCFIM
	AND GI1DES.%NotDel%
	WHERE GIC.GIC_FILIAL = %xFilial:GIC%
	AND GIC.GIC_AGENCI = %Exp:cAgencia%
	AND GIC.GIC_DTVEND = %Exp:cData%
	AND GIC.GIC_STATUS = 'V'
	AND GIC.GIC_CODGYV = ''
	AND GIC.GIC_CONFER  = '1'
	%Exp:cQuery%
	AND GIC.%NotDel%

EndSql

If (cAliasGIC)->(!EoF())

	While !(cAliasGIC)->(Eof())

		If !(oMdlGrid:SeekLine({{"GIC_CODIGO",(cAliasGIC)->GIC_CODIGO}}))

			If !(oMdlGrid:IsEmpty())
				oMdlGrid:AddLine()
			Endif

			If (cAliasGIC)->GIC_SENTID == '1'
				cDescLin := AllTrim((cAliasGIC)->LOCORI) + '/' + AllTrim((cAliasGIC)->LOCDES)
			Else
				cDescLin := AllTrim((cAliasGIC)->LOCDES) + '/' + AllTrim((cAliasGIC)->LOCORI)
			Endif
			
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_MARK"})[1],.T.)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_CODIGO"})[1],(cAliasGIC)->GIC_CODIGO)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_BILHET"})[1],(cAliasGIC)->GIC_BILHET)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_DTVEND"})[1],StoD((cAliasGIC)->GIC_DTVEND))
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_VALTOT"})[1],(cAliasGIC)->GIC_VALTOT)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_COLAB"})[1],(cAliasGIC)->GIC_COLAB)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_NCOLAB"})[1],(cAliasGIC)->GYG_NOME)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_LINHA"})[1],(cAliasGIC)->GIC_LINHA)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_NLINHA"})[1], cDescLin)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_CHVBPE"})[1],(cAliasGIC)->GIC_CHVBPE)
			oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_CCF"})[1],(cAliasGIC)->GIC_CCF)
			
		Endif
			
		(cAliasGIC)->(dbSkip())

	End

Else 
    FwAlertHelp(STR0039, STR0040, STR0038) //"Não foram encontrados bilhetes com os parâmetros informados","Altere os parâmetros","Atenção"
Endif

oMdlGrid:GoLine(1)

(cAliasGIC)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} SetMarkGrd
//TODO Descrição auto-gerada.
@author flavio.martins
@since 01/02/2022
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
	oMdlGrid:LdValueByPos(oMdlGrid:GetStruct():GetArrayPos({"GIC_MARK"})[1], lMark)
Next

oMdlGrid:GoLine(1)

Return
