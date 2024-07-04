#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA300C.CH"

/*/{Protheus.doc} GTPA300C
(long_description)
@type  Static Function
@author flavio.martins
@since 07/10/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function GTPA300C(oModel)

FwExecView(STR0001,"VIEWDEF.GTPA300C",MODEL_OPERATION_UPDATE, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModel) // ""Viagens Extras"

Return

/*/{Protheus.doc} ModelDef
(long_description)
@type  Static Function
@author flavio.martins
@since 07/10/2020
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
Local bLoad		:= {|oModel| GA300CLoad(oModel)}
Local bCommit   := {|oModel| GA300CCommit(oModel)}

oModel := MPFormModel():New("GTPA300C",/*bPreValidacao*/, /*bPosValid*/, bCommit, /*bCancel*/ )

SetMdlStruct(oStruCab, oStruGrd)

oModel:AddFields("HEADER", /*cOwner*/, oStruCab,,,bLoad)
oModel:AddGrid("GRID", "HEADER", oStruGrd,,,,,)

oModel:SetDescription(STR0001) // "Viagens Extras"
oModel:GetModel("HEADER"):SetDescription(STR0002)   // "Dados da Viagem"
oModel:GetModel("GRID"):SetDescription(STR0003)   // "Itinerário"
oModel:SetPrimaryKey({})

oModel:GetModel('GRID'):SetNoDeleteLine(.T.)

Return(oModel)

/*/{Protheus.doc} ViewDef
(long_description)
@type  Static Function
@author flavio.martins
@since 07/10/2020
@version 1.0
@param , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView		:= nil
Local oModel	:= FwLoadModel("GTPA300C")
Local oStruCab	:= FwFormViewStruct():New()
Local oStruGrd	:= FwFormViewStruct():New()

// Cria o objeto de View
oView := FWFormView():New()

SetViewStru(oStruCab, oStruGrd)

// Define qual o Modelo de dados a ser utilizado
oView:SetModel(oModel)

oView:SetDescription(STR0001) // "Viagens Extras"

oView:AddField('VIEW_HEADER' ,oStruCab,'HEADER')
oView:AddGrid('VIEW_GRID' ,oStruGrd,'GRID')

oView:CreateHorizontalBox('HEADER', 30)
oView:CreateHorizontalBox('GRID', 70)

oView:SetOwnerView('VIEW_HEADER','HEADER')
oView:SetOwnerView('VIEW_GRID','GRID')

oView:EnableTitleView("VIEW_HEADER",STR0002)	//"Dados da Viagem"
oView:EnableTitleView("VIEW_GRID",STR0003)		//"Itinerário"

oView:AddIncrementalField('VIEW_GRID','SEQ')

oView:SetViewAction("ASKONCANCELSHOW",{||.F.})

oView:ShowUpdateMsg(.F.)

Return(oView)

/*/{Protheus.doc} SetMdlStru
(long_description)
@type  Static Function
@author flavio.martins
@since 07/10/2020
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
Local bFldWhen  := {|oMdl,cField,uVal|FieldWhen(oMdl,cField,uVal)} 

	If ValType(oStruCab) == "O"
	
		oStruCab:AddField(STR0004,STR0004,"OPCAO"   ,"N", 1, 0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 						//"Opção"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0005,STR0005,"TPVIAGEM","C", 1, 0,{|| .T.},{|| .T.},{STR0021,STR0022,STR0023},.T.,NIL,.F.,.F.,.T.) //"Tipo de Viagem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0006,STR0006,"CONTRATO","C",TamSx3('GY0_NUMERO')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 	//"Contrato"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0007,STR0007,"DATAINI" ,"D", 8, 0, {|| .T.},{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 						//"Data De"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0008,STR0008,"DATAFIM" ,"D", 8, 0, bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 						//"Data Até"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0009,STR0009,"LOTACAO"	,"N", 3, 0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 						//"Lotação"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0010,STR0010,"QTDVEIC" ,"N", 3, 0,bFldVld,{|| .T.},{},.T.,{|| 1},.F.,.F.,.T.) 						//"Qtd. Veículos"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruCab:AddField(STR0011,STR0011,"LINHA"	,"C",TamSx3('GYN_LINCOD')[1],0,bFldVld,{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 	//"Linha"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

        oStruCab:AddTrigger("DATAINI","DATAINI",{ || .T. }, bFldTrig)
        oStruCab:AddTrigger("CONTRATO","CONTRATO",{ || .T. }, bFldTrig)
        oStruCab:AddTrigger("LINHA","LINHA",{ || .T. }, bFldTrig)
		
	Endif	

	If ValType(oStruGrd) == "O"

		oStruGrd:AddField(STR0012,STR0012,"SEQ","C",TamSx3('G55_SEQ')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) 		//"Seq."                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruGrd:AddField(STR0013,STR0013,"LOCORI","C",TamSx3('G55_LOCORI')[1],0,bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 	//"Loc. Origem"
		oStruGrd:AddField(STR0014,STR0014,"DESCORI","C",TamSx3('G55_DESORI')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Descr. Origem"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruGrd:AddField(STR0015,STR0015,"LOCDES","C",TamSx3('G55_LOCDES')[1],0,bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 	//"Loc. Destino"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruGrd:AddField(STR0016,STR0016,"DESCDES","C",TamSx3('G55_DESDES')[1],0,{|| .T.},{|| .T.},{},.F.,NIL,.F.,.F.,.T.) //"Descr. Destino"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
		oStruGrd:AddField(STR0017,STR0017,"DATAPAR" ,"D", 8, 0, bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 					//"Data Partida"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
        oStruGrd:AddField(STR0018,STR0018,"HORAPAR","C",TamSx3('G55_HRINI')[1],0,{|| .T.},{|| .T.},{},.T.,NIL,.F.,.T.,.T.)	//"Hora Partida"
		oStruGrd:AddField(STR0019,STR0019,"DATACHG" ,"D", 8, 0, bFldVld,{|| .T.},{},.T.,NIL,.F.,.F.,.T.) 					//"Data Chegada"
		oStruGrd:AddField(STR0020,STR0020,"HORACHG","C",TamSx3('G55_HRFIM')[1],0,bFldVld,{|| .T.},{},.T.,NIL,.F.,.T.,.T.)	//"Hora Chegada"

		oStruGrd:AddTrigger("LOCORI","LOCORI",{ || .T. }, bFldTrig)
        oStruGrd:AddTrigger("LOCDES","LOCDES",{ || .T. }, bFldTrig)
        oStruGrd:AddTrigger("DATAPAR","DATAPAR",{ || .T. }, bFldTrig)
        oStruGrd:AddTrigger("HORAPAR","HORAPAR",{ || .T. }, bFldTrig)

		oStruGrd:SetProperty("DATAPAR", MODEL_FIELD_WHEN, bFldWhen)

	Endif	
	
Return

/*/{Protheus.doc} SetViewStru
(long_description)
@type  Static Function
@author flavio.martins
@since 07/10/2020
@version 1.0
@param oStruct , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStru(oStruCab, oStruGrd)

	If ValType(oStruCab) == "O"

		oStruCab:AddField("TPVIAGEM","01",STR0005,STR0005,{""},"GET","@!",NIL,"",.T.,NIL,NIL,{STR0021,STR0022,STR0023},NIL,NIL,.F.) //"Tipo de viagem"
		oStruCab:AddField("CONTRATO","02",STR0006,STR0006,{""},"GET","@!",NIL,"GY0",.T.,NIL,NIL,{},NIL,NIL,.F.)						//"Contrato"
		oStruCab:AddField("DATAINI" ,"03",STR0007,STR0007,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)							//"Data De"
		oStruCab:AddField("DATAFIM" ,"04",STR0008,STR0008,{""},"GET","",NIL,"",.T.,NIL,NIL,{},	NIL,NIL,.F.)						//"Data Até"
		oStruCab:AddField("LOTACAO" ,"05",STR0009,STR0009,{""},"GET","999",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 						//"Lotação"
		oStruCab:AddField("QTDVEIC" ,"06",STR0010,STR0010,{""},"GET","999",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.) 						//"Qtd. Veículos"
		oStruCab:AddField("LINHA"   ,"07",STR0011,STR0011,{""},"GET","@!",NIL,"GYDLIN",.T.,NIL,NIL,{},NIL,NIL,.F.)					//"Linha"

	Endif

	If ValType(oStruGrd) == "O"

		oStruGrd:AddField("SEQ"		,"01",STR0012,STR0012,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Seq."
		oStruGrd:AddField("LOCORI"	,"02",STR0013,STR0013,{""},"GET","@!",NIL,"GI1",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Loc. Origem"
		oStruGrd:AddField("DESCORI"	,"03",STR0014,STR0014,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Descr. Origem"
		oStruGrd:AddField("LOCDES"	,"04",STR0015,STR0015,{""},"GET","@!",NIL,"GI1",.T.,NIL,NIL,{},NIL,NIL,.F.)		//"Loc. Destinoo"
		oStruGrd:AddField("DESCDES"	,"05",STR0016,STR0016,{""},"GET","@!",NIL,"",.F.,NIL,NIL,{},NIL,NIL,.F.)		//"Descr. Destino"
		oStruGrd:AddField("DATAPAR"	,"06",STR0017,STR0017,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			//"Data Partida"
		oStruGrd:AddField("HORAPAR"	,"07",STR0018,STR0018,{""},"GET","@R 99:99",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)	//"Hora Partida"
		oStruGrd:AddField("DATACHG" ,"08",STR0019,STR0019,{""},"GET","",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)			//"Data Chegada"
		oStruGrd:AddField("HORACHG"	,"09",STR0020,STR0020,{""},"GET","@R 99:99",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)	//"Hora Chegada"

	Endif

Return

/*/{Protheus.doc} FieldValid
(long_description)
@type  Static Function
@author flavio.martins
@since 08/10/2020
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
    
    Case cField == "DATAPAR"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := STR0035 //"Data de partida não pode ser menor que a data inicial"
            cMsgSol  := STR0036 //"Altere a data de partida"
        Endif
    Case cField == "DATAFIM"
        If uNewValue < oModel:GetModel('HEADER'):GetValue('DATAINI')
            lRet     := .F.
            cMsgErro := STR0025 //"Data final não pode ser menor que a data inicial"
            cMsgSol  := STR0026 //"Altere a data final"
        Endif

    Case cField == 'LOCORI'
        If uNewValue == oMdl:GetValue('LOCDES')
            lRet     := .F.
            cMsgErro := STR0027 //"Localidades inicial e final não podem ser iguais"
            cMsgSol  := STR0028 //"Altere a localidade"
        Endif
    Case cField == 'LOCDES'
        If uNewValue == oMdl:GetValue('LOCORI')
            lRet     := .F.
            cMsgErro := STR0027 //"Localidades inicial e final não podem ser iguais"
            cMsgSol  := STR0028 //"Altere a localidade"
        Endif
	Case cField == 'LINHA'
			If !(VldLinha(uNewValue, oModel:GetModel('HEADER'):GetValue('CONTRATO')))
				lRet := .F.
	            cMsgErro := STR0029 //"Linha não pertence ao contrato selecionado"
    	        cMsgSol  := STR0030 //"Selecione outra linha"
			Endif

			If lRet .And. (Empty(oModel:GetModel('HEADER'):GetValue('DATAINI')) .Or. ;
			   Empty(oModel:GetModel('HEADER'):GetValue('DATAINI')))
				lRet := .F.
	            cMsgErro := STR0031 //"As datas iniciais e finais devem estar preenchidas"
    	        cMsgSol  := STR0032 //"Preencha as datas"
			Endif
	Case cField == 'QTDVEIC'
			IF uNewValue < 1 
				lRet := .F.
	            cMsgErro := STR0037 //"Quantidade de veículos não pode ser menor que 1"
    	        cMsgSol  := STR0038 //"Altere a quantidade de veículos"
			Endif
	Case cField == "DATACHG"
			If uNewValue < oModel:GetModel('GRID'):GetValue('DATAPAR')
				lRet     := .F.
				cMsgErro := STR0033 //"Data de chegada não pode ser menor que a data de partida"
				cMsgSol  := STR0034 //"Altere a data de chegada"
			Endif
	Case cField == "HORACHG"
			If oMdl:GetValue('DATACHG') == oMdl:GetValue('DATAPAR') .And. uNewValue <= oMdl:GetValue('HORAPAR')
				lRet     := .F.
				cMsgErro := STR0039 //"Hora de chegada não pode ser menor ou igual a hora de partida"
				cMsgSol  := STR0040 //"Altere a hora de chegada"
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
@since 07/10/2020
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldTrigger(oMdl,cField,uVal)
Local oModel := oMdl:GetModel()

Do Case
	Case cField == 'DATAINI' 
		oModel:GetModel('GRID'):LoadValue('DATAPAR', uVal)	
	Case cField == 'LOCORI'
	    oMdl:SetValue('DESCORI', Posicione("GI1",1,xFilial("GI1")+uVal,"GI1_DESCRI"))
	Case cField == 'LOCDES'
    	oMdl:SetValue('DESCDES', Posicione("GI1",1,xFilial("GI1")+uVal,"GI1_DESCRI"))
	Case cField == 'CONTRATO'
		oMdl:ClearField('LINHA')
	Case cField == 'LINHA'
		AddTrechos(oMdl)
	Case cField == 'DATAPAR'
		oMdl:ClearField('DATACHG')
	Case cField == 'HORAPAR'
		oMdl:ClearField('HORACHG')
EndCase

Return uVal

/*/{Protheus.doc} FieldWhen
(long_description)
@type  Static Function
@author flavio.martins
@since 13/10/2020
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FieldWhen(oMdl,cField,uVal)
Local lRet := .T.

Do Case
    Case cField == "DATAPAR"
        lRet := oMdl:GetValue("SEQ") != '0001'
    EndCase

Return lRet

/*/{Protheus.doc} GA200BLoad
(long_description)
@type  Static Function
@author flavio.martins
@since 07/10/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA300CLoad(oModel)
Local oMdlCab := oModel:GetModel('HEADER')

Return

/*/{Protheus.doc} GA300CCommit
(long_description)
@type  Static Function
@author flavio.martins
@since 07/10/2020
@version 1.0
@param oModel, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GA300CCommit(oModel)
Local lRet := .T.

    Begin Transaction
	
	FwMsgRun( ,{|| lRet := GeraViagens(oModel)},, STR0024) //"Gerando Viagens..."

	If !(lRet)
		DisarmTransaction()
	Endif

	End Transaction

	If lRet 
	    GTPA300A(oModel)
	Endif

Return lRet

/*/{Protheus.doc} GeraViagens
(long_description)
@type  Static Function
@author flavio.martins
@since 08/10/2020
@version 1.0
@param oModel , param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraViagens(oModel)
Local lRet      := .T.
Local oMdl300   := FwLoadModel('GTPA300')
Local n1        := 0
Local n2		:= 0
Local n3		:= 0
Local nDias		:= 1
Local dDataIni	:= oModel:GetModel('HEADER'):GetValue('DATAINI')
Local dDataFim	:= oModel:GetModel('HEADER'):GetValue('DATAFIM')
Local nQtdVeic	:= oModel:GetModel('HEADER'):GetValue('QTDVEIC')
Local dDataRef	:= dDataIni
Local dDataPar	
Local dDataChg

nDias += (dDataFim - dDataIni)

For n1 := 1 To nDias

	For n2 := 1 To nQtdVeic

		oMdl300:SetOperation(MODEL_OPERATION_INSERT)

		oMdl300:Activate()

		oMdl300:GetModel('GYNMASTER'):SetValue('GYN_TIPO'   , oModel:GetModel('HEADER'):GetValue('TPVIAGEM'))
		oMdl300:GetModel('GYNMASTER'):SetValue('GYN_EXTRA'  , .T.)
		oMdl300:GetModel('GYNMASTER'):LoadValue('GYN_DTINI'  , dDataRef)
		oMdl300:GetModel('GYNMASTER'):SetValue('GYN_DTGER'  , dDataBase)
		oMdl300:GetModel('GYNMASTER'):SetValue('GYN_HRGER'  , SubStr(Time(),1,2) + SubStr(Time(),4,2))
		oMdl300:GetModel('GYNMASTER'):SetValue('GYN_MSBLQL' , '2')
		oMdl300:GetModel('GYNMASTER'):SetValue('GYN_LOTACA' , oModel:GetModel('HEADER'):GetValue('LOTACAO'))

		If GYN->(FieldPos('GYN_CODGY0')) > 0
			oMdl300:GetModel('GYNMASTER'):SetValue('GYN_CODGY0', oModel:GetModel('HEADER'):GetValue('CONTRATO'))
		Endif 

		For n3 := 1 To oModel:GetModel('GRID'):Length()

			If !(oMdl300:GetModel('G55DETAIL'):IsEmpty())
				oMdl300:GetModel('G55DETAIL'):AddLine()
			Endif

			If n1 == 1
				dDataPar := oModel:GetModel('GRID'):GetValue('DATAPAR', n3)
				dDataChg := oModel:GetModel('GRID'):GetValue('DATACHG', n3)
			Else
				dDataPar++ 
				dDataChg++ 
			Endif

			oMdl300:GetModel('G55DETAIL'):SetValue('G55_SEQ'   , oModel:GetModel('GRID'):GetValue('SEQ'	  ,	n3))
			oMdl300:GetModel('G55DETAIL'):SetValue('G55_LOCORI', oModel:GetModel('GRID'):GetValue('LOCORI', n3))
			oMdl300:GetModel('G55DETAIL'):SetValue('G55_LOCDES', oModel:GetModel('GRID'):GetValue('LOCDES', n3))
			oMdl300:GetModel('G55DETAIL'):SetValue('G55_DTPART', dDataPar)
			oMdl300:GetModel('G55DETAIL'):SetValue('G55_HRINI' , oModel:GetModel('GRID'):GetValue('HORAPAR',n3))
			oMdl300:GetModel('G55DETAIL'):SetValue('G55_DTCHEG', dDataChg)
			oMdl300:GetModel('G55DETAIL'):SetValue('G55_HRFIM' , oModel:GetModel('GRID'):GetValue('HORACHG',n3))

		Next

		If oMdl300:VldData()
			oMdl300:CommitData()
		Else
			lRet := .F.
			Exit
		Endif

		oMdl300:DeActivate()

	Next

	If lRet
		dDataRef++
	Else
		Exit
	Endif

Next

Return lRet

/*/{Protheus.doc} VldLinha
(long_description)
@type  Static Function
@author flavio.martins
@since 13/10/2020
@version 1.0
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function VldLinha(cLinha, cContrato)
Local lRet 		:= .T.
Local cAliasGYD := GetNextAlias()

BeginSql Alias cAliasGYD

	SELECT GYD_CODGI2 FROM %Table:GYD% GYD
	WHERE
	GYD.GYD_FILIAL = %xFilial:GYD%
	AND GYD.GYD_CODGI2 = %Exp:cLinha%
	AND GYD.GYD_NUMERO = %Exp:cContrato%
	AND GYD.%NotDel%

EndSql

If (cAliasGYD)->(Eof())
	lRet := .F.
Endif

(cAliasGYD)->(dbCloseArea())

Return lRet

/*/{Protheus.doc} AddTrechos
(long_description)
@type  Static Function
@author flavio.martins
@since 13/10/2020
@version 1.0
@param oMdl, param_type, param_descr
@return nil, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AddTrechos(oMdl)
Local oModel	:= oMdl:GetModel()
Local oView		:= FwViewActive()
Local cAliasGI2 := GetNextAlias()
Local cLinha	:= oModel:GetModel('HEADER'):GetValue('LINHA')
Local dDataIni	:= oModel:GetModel('HEADER'):GetValue('DATAINI')
Local dDataFim	:= oModel:GetModel('HEADER'):GetValue('DATAFIM')

oModel:GetModel('GRID'):ClearData(.F.,.T.)

If !FwIsInCallStack('GTPA300C_01')
	oView:Refresh('VIEW_GRID')
EndIF

BeginSql Alias cAliasGI2

	SELECT GIE.GIE_SEQ,
		GIE.GIE_IDLOCP,
		GIE.GIE_IDLOCD,
		GIE.GIE_HORLOC,
		GIE.GIE_HORDES,
		GIE.GIE_DIA
	FROM %Table:GI2% GI2
	INNER JOIN %Table:GID% GID ON GID.GID_LINHA = GI2.GI2_COD
	AND GID.GID_HIST = '2'
	AND GID.%NotDel%
	INNER JOIN %Table:GIE% GIE ON GIE.GIE_CODGID = GID.GID_COD
	AND GIE.GIE_HIST = '2'
	AND GIE.%NotDel%
	WHERE GI2.GI2_FILIAL = GI2.GI2_FILIAL
	AND GI2.GI2_COD = %Exp:cLinha%
	AND GI2.GI2_HIST = '2'
	AND GI2.%NotDel%
	ORDER BY GIE.GIE_SEQ	

EndSql

oModel:GetModel('GRID'):SetNoInsertLine(.F.)
oModel:GetModel('GRID'):SetNoUpdateLine(.F.)

While (cAliasGI2)->(!(Eof()))

	oModel:GetModel('GRID'):AddLine()

	oModel:GetModel('GRID'):SetValue('LOCORI', (cAliasGI2)->GIE_IDLOCP)
	oModel:GetModel('GRID'):SetValue('LOCDES', (cAliasGI2)->GIE_IDLOCD)
	oModel:GetModel('GRID'):LoadValue('DATAPAR', dDataIni)
	oModel:GetModel('GRID'):SetValue('DATACHG', dDataIni + (cAliasGI2)->GIE_DIA)
	oModel:GetModel('GRID'):SetValue('HORAPAR', (cAliasGI2)->GIE_HORLOC)
	oModel:GetModel('GRID'):SetValue('HORACHG', (cAliasGI2)->GIE_HORDES)

	(cAliasGI2)->(dbSkip())

End

If !(Empty(oModel:GetModel('GRID'):GetValue('LOCORI', 1)))
	oModel:GetModel('GRID'):GoLine(1)
	oModel:GetModel('GRID'):SetNoInsertLine(.T.)
	oModel:GetModel('GRID'):SetNoUpdateLine(.T.)
Endif

(cAliasGI2)->(dbCloseArea())


Return
