#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPC300M.CH"

Static _cFldGYG	:= "GYG_CODIGO|GYG_NOME|GYG_FUNCIO|GYG_FILSRA|"
Static _cFldDet	:= "GQK_CODIGO|GQK_CODVIA|GQK_TCOLAB|GQK_DCOLAB|GQK_RECURS|GQK_DRECUR|GQK_DTREF|GQK_DTINI|GQK_HRINI|GQK_DTFIM|GQK_HRFIM|GQK_LOCORI|GQK_DESORI|GQK_LOCDES|GQK_DESDES|GQK_TPDIA|GQK_FUNCIO|GQK_CODGZS|GQK_CONF|GQK_STATUS|"
Static oTableTmp

/*/{Protheus.doc} GTPC300M
Função responsavel pela alocação de Colaboradores em viagens Especiais
@type function
@author jacomo.fernandes
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPC300M()

Local lMonitor	:= GC300GetMVC('IsActive')
Local oModel	:= NIL
 
If lMonitor
	oModel		:= GC300GetMVC('M')
	
	If oModel:GetModel('GYNDETAIL'):GetValue('GYN_TIPO') <> "2" //Viagem Especial
		FwAlertHelp(STR0002,STR0001) //"Alocação Viagem Especial" //"Esta rotina só funciona com viagens tipo extraordinária"
	ElseIf oModel:GetModel('GYNDETAIL'):GetValue('GYN_FINAL') <> "1" //Viagem Finalizada
		FwAlertHelp(STR0003,STR0001) //"Alocação Viagem Especial" //"Esta rotina só funciona com viagens finalizadas"
	Else
		FWExecView( STR0004, 'VIEWDEF.GTPC300M', MODEL_OPERATION_UPDATE, , { || .T. } ) //"Viagem Especial"
	Endif
Else
	FwAlertHelp(STR0005,STR0001) //"Alocação Viagem Especial" //"Esta rotina só funciona com monitor ativo"
Endif
	
Return



/*/{Protheus.doc} ModelDef
Função responsavel pela montagem do modelo de dados
@type function
@author jacomo.fernandes
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
Local oModel
Local oStrCab	:= FWFormModelStruct():New()
Local oStrGYG	:= FWFormStruct(1,"GYG",{|cCampo|Alltrim(cCampo)+"|" $ _cFldGYG}) //Alocações
Local oStrDet	:= FWFormStruct(1,"GQK",{|cCampo|Alltrim(cCampo)+"|" $ _cFldDet}) //Alocações
Local oStrTot 	:= FWFormModelStruct():New()
Local bLoad		:= {|oModel| GC300MLoad(oModel)}
Local bPreLine  := {|oModel,nLine,cAction,cField,uValue| Gc300mPreLine(oModel,nLine,cAction,cField,uValue)}

SetModelStruct(oStrCab,oStrDet,oStrTot)

oModel := MPFormModel():New("GTPC300M", , , )

oModel:AddFields("GQKMASTER"	,/*cOwner*/	, oStrCab,,,bLoad)
oModel:AddGrid("GYGDETAIL"		,"GQKMASTER", oStrGYG, , , , , bLoad)
oModel:AddGrid("GQKDETAIL"		,"GYGDETAIL", oStrDet,bPreLine , , , , /*bLoad*/)
oModel:AddFields("TOTALHORAS"	,"GYGDETAIL", oStrTot,,,bLoad)

oModel:SetRelation("GYGDETAIL"	, {{"GYG_FILIAL",'xFilial("GYG")'}}, GYG->(IndexKey(1)))//GYG_FILIAL, GYG_CODIGO
oModel:SetRelation("GQKDETAIL"	, {{"GQK_FILIAL",'xFilial("GQK")'},{"GQK_CODVIA","GQK_CODVIA"},{"GQK_RECURS","GYG_CODIGO"}}, GQK->(IndexKey(3)))//GQK_FILIAL, GQK_RECURS, GQK_DTREF, GQK_DTINI, GQK_HRINI
oModel:SetRelation("TOTALHORAS"	, {{"GYQ_COLCOD",'GYG_CODIGO'}}, GYQ->(IndexKey(1)))//GYQ_FILIAL, GYQ_CODIGO

oModel:SetDescription(STR0006)//STR0006 //"Alocações dos Recursos"

oModel:GetModel("GQKMASTER"):SetDescription(STR0007) //"Manutenção de Recurso"
oModel:GetModel("GYGDETAIL"):SetDescription("Recursos")
oModel:GetModel("GQKDETAIL"):SetDescription("Alocações")
oModel:GetModel("TOTALHORAS"):SetDescription("Totais")

oModel:GetModel("GQKMASTER"):SetOnlyQuery(.T.)
oModel:GetModel("GYGDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("TOTALHORAS"):SetOnlyQuery(.T.)

oModel:GetModel("GYGDETAIL"):SetOnlyView(.T.)
oModel:GetModel("TOTALHORAS"):SetOnlyView(.T.)

oModel:GetModel("GQKDETAIL"):SetOptional(.T.)

oModel:GetModel("GQKDETAIL"):SetNoInsertLine(.T.)

oModel:SetPrimaryKey({})

oModel:SetActivate({|oMdl| Gc300mAct(oMdl)})

oModel:lModify := .T.

Return oModel

/*/{Protheus.doc} SetModelStruct
Função responsavel pela customização da estrutura do modelo
@type function
@author jacomo.fernandes
@since 17/12/2018
@version 1.0
@param oStrCab, objeto, (Descrição do parâmetro)
@param oStrDet, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStrCab,oStrDet,oStrTot)
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|ValidaCampos(oMdl,cField,cNewValue,cOldValue) }
Local bTrig		:= {|oMdl,cField,xVal|GatilhoCampos(oMdl,cField,xVal)}

If ValType(oStrCab) == "O"
	
	CreateTmpStruct(oStrCab,oStrTot,.T.)
	
	oStrCab:SetProperty('GQK_DTINI'		,MODEL_FIELD_VALID,bFldVld)
	oStrCab:SetProperty('GQK_HRINI'		,MODEL_FIELD_VALID,bFldVld)
	oStrCab:SetProperty('GQK_HRFIM'		,MODEL_FIELD_VALID,bFldVld)
	
	oStrCab:SetProperty('*'				,MODEL_FIELD_OBRIGAT,.F.)
	
	oStrCab:AddTrigger("GQK_RECURS"		,"GQK_RECURS"		,{||.T.},bTrig)
	oStrCab:AddTrigger("GQK_TCOLAB"		,"GQK_TCOLAB"		,{||.T.},bTrig)
	oStrCab:AddTrigger("GQK_DTREF"		,"GQK_DTREF"		,{||.T.},bTrig)
	oStrCab:AddTrigger("GQK_HRINI"		,"GQK_HRINI"		,{||.T.},bTrig)
	oStrCab:AddTrigger("GQK_HRFIM"		,"GQK_HRFIM"		,{||.T.},bTrig)
	oStrCab:AddTrigger("GQK_LOCORI"		,"GQK_LOCORI"		,{||.T.},bTrig)
	oStrCab:AddTrigger("GQK_LOCDES"		,"GQK_LOCDES"		,{||.T.},bTrig)
	oStrCab:AddTrigger("TEMPOPERCURSO"	,"TEMPOPERCURSO"	,{||.T.},bTrig)
	
	
	oStrCab:SetProperty('GQK_DCOLAB'	,MODEL_FIELD_INIT,{|| ""})
	oStrCab:SetProperty('GYN_DSCORI'	,MODEL_FIELD_INIT,{|oMdl| Posicione('GI1',1,xFilial('GI1')+oMdl:GetValue('GYN_LOCORI'),'GI1_DESCRI')})
	oStrCab:SetProperty('GYN_DSCDES'	,MODEL_FIELD_INIT,{|oMdl| Posicione('GI1',1,xFilial('GI1')+oMdl:GetValue('GYN_LOCDES'),'GI1_DESCRI')})
	oStrCab:SetProperty('GQK_DESORI'	,MODEL_FIELD_INIT,{|oMdl| Posicione('GI1',1,xFilial('GI1')+oMdl:GetValue('GQK_LOCORI'),'GI1_DESCRI')})
	oStrCab:SetProperty('GQK_DESDES'	,MODEL_FIELD_INIT,{|oMdl| Posicione('GI1',1,xFilial('GI1')+oMdl:GetValue('GQK_LOCDES'),'GI1_DESCRI')})
	oStrCab:SetProperty('TEMPOPERCURSO'	,MODEL_FIELD_INIT,{|| "0000"})
	
Endif
	

If ValType(oStrDet) == "O"
	oStrDet:AddField(STR0008	,STR0008	,"GQK_ITEM"	,"C",4,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.) //STR0008 //"Item"
	oStrDet:AddField(STR0009	,STR0009	,"TEMPOPERCURSO"	,"C",4,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.) //STR0009 //"Tempo Percurso"
	
	oStrDet:SetProperty('GQK_CODIGO'	,MODEL_FIELD_OBRIGAT	,.F.)
	
	oStrDet:SetProperty('GQK_HRINI'		,MODEL_FIELD_VALID,bFldVld)
	oStrDet:SetProperty('GQK_HRFIM'		,MODEL_FIELD_VALID,bFldVld)
	oStrDet:SetProperty('GQK_DTFIM'		,MODEL_FIELD_VALID,bFldVld)

	oStrDet:SetProperty("GQK_CODIGO" 	, MODEL_FIELD_INIT		, {|| GTPXENUM('GQK','GQK_CODIGO') })
	oStrDet:SetProperty("GQK_TPDIA" 	, MODEL_FIELD_INIT		, {|| '1' } )//Trabalhado 
	
	oStrDet:SetProperty('GQK_CODGZS'	, MODEL_FIELD_INIT		,{|| GTPGetRules("TIPOESCEXT", .F., , "")}) 
    oStrDet:SetProperty('GQK_CONF'		, MODEL_FIELD_INIT		,{|| '1'})
    oStrDet:SetProperty('GQK_STATUS'	, MODEL_FIELD_INIT		,{|| '1'})
	

	oStrDet:AddTrigger("GQK_RECURS"		,"GQK_RECURS"			,{||.T.},bTrig)
	oStrDet:AddTrigger("GQK_TCOLAB"		,"GQK_TCOLAB"			,{||.T.},bTrig)
	oStrDet:AddTrigger("GQK_LOCORI"		,"GQK_LOCORI"			,{||.T.},bTrig)
	oStrDet:AddTrigger("GQK_LOCDES"		,"GQK_LOCDES"			,{||.T.},bTrig)
	oStrDet:AddTrigger("GQK_HRINI"		,"GQK_HRINI"			,{||.T.},bTrig)
	oStrDet:AddTrigger("GQK_HRFIM"		,"GQK_HRFIM"			,{||.T.},bTrig)
	
Endif

Return


/*/{Protheus.doc} CreateTmpStruct
(long_description)
@type function
@author jacomo.fernandes
@since 16/01/2019
@version 1.0
@param oStrCab, objeto, (Descrição do parâmetro)
@param lModel, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CreateTmpStruct(oStrCab,oStrTot,lModel)
Local aFldCab	:= {'GQK_CODVIA','GYN_LOCORI','GYN_DSCORI','GYN_DTINI','GYN_HRINI','GYN_LOCDES',;
					'GYN_DSCDES','GYN_DTFIM','GYN_HRFIM','GQK_TCOLAB','GQK_DCOLAB','GQK_LOCORI',;
					'GQK_DESORI','GQK_DTREF','GQK_DTINI','GQK_HRINI','GQK_DTFIM','GQK_HRFIM',;
					'GQK_LOCDES','GQK_DESDES'}

Local aFldTot	:= {'GYQ_COLCOD','GYQ_HRMENS','GYQ_HRTRAB','GYQ_HRADN','GYQ_HREXTR',;
					'GYQ_HRVOLA','GYQ_HRFVOL','GYQ_HRDESP'}
Default lModel	:= .F.


GTPxCriaCpo(oStrCab,aFldCab,lModel)

GTPxCriaCpo(oStrTot,aFldTot,lModel)

If lModel
	oStrCab:AddField(STR0009	,STR0009	,"TEMPOPERCURSO"	,"C",4,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.) //STR0009 //"Tempo Percurso"
Else
	oStrCab:AddField("TEMPOPERCURSO"	,StrZero(Len(aFldCab)+1, 2),STR0009	,STR0009	,{STR0009	},"Get","@R 99:99"	,NIL,"",.T.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.) //STR0009 //STR0009 //"Tempo Percurso"
Endif	

Return 

/*/{Protheus.doc} Gc300mAct
Função responsavel pela ativação do modelo
@type function
@author jacomo.fernandes
@since 24/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Gc300mAct(oModel)
Local oMdlGYG	:= oModel:GetModel('GYGDETAIL')
Local oMdlGQK	:= oModel:GetModel('GQKDETAIL')
Local n1		:= 0 
Local n2		:= 0
For n1 := 1 to oMdlGYG:Length()
	oMdlGYG:GoLine(n1)
	CalculaTotaisHoras(oModel)
	For n2 := 1 To oMdlGQK:Length()
		oMdlGQK:GoLine(n2)
		GC300mPerc(oMdlGQK)
	Next
	oMdlGQK:GoLine(1)
Next
oMdlGYG:GoLine(1)

Return 

/*/{Protheus.doc} ValidaCampos
(long_description)
@type function
@author jacomo.fernandes
@since 19/12/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param cNewValue, character, (Descrição do parâmetro)
@param cOldValue, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ValidaCampos(oMdl,cField,cNewValue,cOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()
Local cMsgErro	:= ""
Local cMsgSolu	:= ""

Do Case
	Case cField == "GQK_HRINI" .or. cField == "GQK_HRFIM"
	
		lRet	:= ValidaHora(cNewValue,@cMsgErro,@cMsgSolu)
	
		If lRet .and. oMdl:GetId() == "GQKDETAIL"
			lRet	:= VldAlocRecurso(oModel,"GQKDETAIL",@cMsgErro,@cMsgSolu)
		Endif
	Case cField == "GQK_DTINI"
		
		If cNewValue > oMdl:GetValue('GQK_DTREF')+1
			lRet	:= .F.
			cMsgErro:= STR0010 //"Data informada passa de dois dias da data da alocação"
			cMsgSolu:= STR0011 //"Informe uma data igual ou até 1 dia a mais que a data da alocação"
		Elseif cNewValue < oMdl:GetValue('GQK_DTREF')
			lRet	:= .F.
			cMsgErro:= STR0012 //"Data informada menor que a data da alocação"
			cMsgSolu:= STR0011 //"Informe uma data igual ou até 1 dia a mais que a data da alocação"
		Endif
	
	Case cField == "GQK_DTFIM"
		lRet	:= VldAlocRecurso(oModel,"GQKDETAIL",@cMsgErro,@cMsgSolu)
	Case cField == "TEMPOPERCURSO"
		lRet	:= ValidaHora(cNewValue,@cMsgErro,@cMsgSolu)

EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,'ValidaCampos',cMsgErro,cMsgSolu,cNewValue,cOldValue)
Endif


Return lRet

Static Function ValidaHora(cValue,cMsgErro,cMsgSolu)
Local lRet		:= .T.
Local lHelp		:= HelpInDark(.T.)

If !AtVldHora(cValue)
	lRet		:= .F.
	cMsgErro	:= STR0013 //"Formato da Hora inválido"
	cMsgSolu	:= STR0014 //"Informe uma hora entre 00:00 até 23:59"
Endif

HelpInDark(lHelp)

Return lRet

/*/{Protheus.doc} GatilhoCampos
(long_description)
@type function
@author jacomo.fernandes
@since 19/12/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GatilhoCampos(oMdl,cField,xVal)
Local oModel	:= oMdl:GetModel() 
Local oView		:= FwViewActive()
Local n1		:= 0


Do Case
	Case cField == 'GQK_RECURS'
		oMdl:SetValue('GQK_DRECUR',Posicione('GYG',1,xFilial('GYG')+xVal,'GYG_NOME'))
		
		
	Case cField == 'GQK_TCOLAB'
		oMdl:SetValue('GQK_DCOLAB',Posicione('GYK',1,xFilial('GYK')+xVal,'GYK_DESCRI'))
		
	Case cField == "GQK_DTREF"	
	 	oMdl:LoadValue("GQK_DTINI"		,xVal)
	 	oMdl:LoadValue('GQK_DTFIM'		,"")
	 	oMdl:LoadValue('GQK_HRINI'		,"")
	 	oMdl:LoadValue('GQK_DTFIM'		,StoD(''))
	 	oMdl:LoadValue('GQK_HRFIM'		,"")
	 	oMdl:LoadValue('TEMPOPERCURSO'	,"0000")
	 	
	
	Case cField == "GQK_HRINI" .and. oMdl:GetId() == 'GQKMASTER' 	
		oMdl:LoadValue('GQK_HRFIM'		,"")
	 	oMdl:LoadValue('TEMPOPERCURSO'	,"0000")
	 	
	Case cField == "GQK_HRINI" .and. oMdl:GetId() == 'GQKDETAIL' 	
		CalculaTotaisHoras(oModel)
		
	Case cField == "GQK_HRFIM"	.and. oMdl:GetId() == 'GQKMASTER' 	 	
		GC300mPerc(oMdl)
		
	Case cField == "GQK_HRFIM"	.and. oMdl:GetId() == 'GQKDETAIL'
		GC300mPerc(oMdl)
		CalculaTotaisHoras(oModel)
	 	
	Case cField == "GQK_LOCORI"	 	
		oMdl:LoadValue('GQK_DESORI'		,Posicione('GI1',1,xFilial('GI1')+xVal,'GI1_DESCRI'))
	Case cField == "GQK_LOCDES"	 	
		oMdl:LoadValue('GQK_DESDES'		,Posicione('GI1',1,xFilial('GI1')+xVal,'GI1_DESCRI'))
		
	Case cField == "TEMPOPERCURSO" 	
		CalculaHrFinal(oMdl)
	
EndCase

If !IsBlind() .and. ValType(oView) == 'O' .and. oView:IsActive() 
	oView:Refresh()
Endif

Return xVal

/*/{Protheus.doc} GC300mPerc
(long_description)
@type function
@author jacomo.fernandes
@since 19/12/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GC300mPerc(oMdl)
Local dDtInic	:= oMdl:GetValue('GQK_DTINI'	)
Local cHrInic	:= oMdl:GetValue('GQK_HRINI'	)
Local dDtFinal	:= oMdl:GetValue('GQK_DTFIM'	)
Local cHrFinal	:= oMdl:GetValue('GQK_HRFIM'	)
Local cPercurso	:= oMdl:GetValue('TEMPOPERCURSO'	)
Local nPercurso	:= 0

If !Empty(dDtInic) .and. !Empty(cHrInic) .and. !Empty(cHrFinal)
	
	dDtFinal := GetDtFinal(dDtInic,cHrInic,cHrFinal) 
	
	nPercurso	:= DataHora2Val(dDtInic,; //Dt Inicial
								 GTFormatHour(cHrInic, "99:99"),; //Hr Inicial
								 dDtFinal,; //Dt Final
								 GTFormatHour(cHrFinal, "99:99"),; //Hr Final
								 "H" )
	
	cPercurso	:= GTFormatHour(nPercurso, "9999")
	
	oMdl:LoadValue('TEMPOPERCURSO'	,cPercurso	)
	oMdl:LoadValue('GQK_DTFIM'		,dDtFinal)
	
Endif	

Return

/*/{Protheus.doc} CalculaHrFinal
(long_description)
@type function
@author jacomo.fernandes
@since 19/12/2018
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CalculaHrFinal(oMdl)
Local dDtInic	:= oMdl:GetValue('GQK_DTINI'	)
Local cHrInic	:= oMdl:GetValue('GQK_HRINI'	)
Local dDtFinal	:= StoD('')
Local cHrFinal	:= ''
Local cPercurso	:= oMdl:GetValue('TEMPOPERCURSO'	)
Local nHrAux	:= 0

If !Empty(dDtInic) .and. !Empty(cHrInic) .and. !Empty(cPercurso)
	
	nHrAux := HoraToInt(GTFormatHour(cHrInic, "99:99"))+HoraToInt(GTFormatHour(cPercurso, "99:99"))
	
	If nHrAux > HoraToInt("23:59")
		cHrFinal := GTFormatHour(IntToHora(nHrAux-24), "9999")
	Else
		cHrFinal := GTFormatHour(IntToHora(nHrAux), "9999")
	Endif
	
	dDtFinal := GetDtFinal(dDtInic,cHrInic,cHrFinal)
	
	oMdl:LoadValue('GQK_DTFIM'	,dDtFinal	)
	oMdl:LoadValue('GQK_HRFIM'	,cHrFinal	)	
	
Endif	

Return

/*/{Protheus.doc} ViewDef
Função responsavel pela montagem da tela do modelo de dados
@type function
@author jacomo.fernandes
@since 17/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
Local oView
Local oModel	:= FwLoadModel('GTPC300M')                            
Local oStrCab	:= FWFormViewStruct():New()
Local oStrGYG	:= FWFormStruct(2,"GYG",{|cCampo|Alltrim(cCampo)+"|" $ _cFldGYG})
Local oStrDet	:= FWFormStruct(2,"GQK",{|cCampo|Alltrim(cCampo)+"|" $ _cFldDet})
Local oStrTot	:= FWFormViewStruct():New()

SetViewStruct(oStrCab,oStrDet,oStrTot,oStrGYG)

oView := FWFormView():New()

oView:SetModel(oModel)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VW_GQKMASTER'	, oStrCab, 'GQKMASTER')
oView:AddGrid('VW_GYGDETAIL'	, oStrGYG, 'GYGDETAIL')
oView:AddGrid('VW_GQKDETAIL'	, oStrDet, 'GQKDETAIL')
oView:AddField('VW_TOTDETAIL'	, oStrTot, 'TOTALHORAS')

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('CABECALHO'	, 40)
oView:CreateHorizontalBox('ALOCACAO'	, 60)

oView:CreateVerticalBox( 'EMBAIXOESQ', 20, 'ALOCACAO' )
oView:CreateVerticalBox( 'EMBAIXOMEI', 65, 'ALOCACAO' )
oView:CreateVerticalBox( 'EMBAIXODIR', 15, 'ALOCACAO' )

oView:SetOwnerView('VW_GQKMASTER'	, 'CABECALHO'	)
oView:SetOwnerView('VW_GYGDETAIL'	, 'EMBAIXOESQ'	)
oView:SetOwnerView('VW_GQKDETAIL'	, 'EMBAIXOMEI'	)
oView:SetOwnerView('VW_TOTDETAIL'	, 'EMBAIXODIR'	)

oView:EnableTitleView('VW_GYGDETAIL')
oView:EnableTitleView('VW_GQKDETAIL')
oView:EnableTitleView('VW_TOTDETAIL')

oView:AddIncrementField( 'VW_GQKDETAIL', 'GQK_ITEM' )

oView:AddUserButton( STR0015, "", {|oView| IncluiAlocacao(oView)},,VK_F8 ) //"Inclui Alocação"

Return oView

/*/{Protheus.doc} SetViewStruct
Função responsavel pela customização da estrutura da View
@type function
@author jacomo.fernandes
@since 17/12/2018
@version 1.0
@param oStrCab, objeto, (Descrição do parâmetro)
@param oStrDet, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStrCab,oStrDet,oStrTot,oStrGYG)

CreateTmpStruct(oStrCab,oStrTot)

If ValType(oStrCab) == "O"
	
	oStrCab:SetProperty('GQK_LOCORI'	,MVC_VIEW_LOOKUP	,'G55ORI')
	oStrCab:SetProperty('GQK_LOCDES'	,MVC_VIEW_LOOKUP	,'G55DES')
	
	oStrCab:SetProperty('*'				,MVC_VIEW_CANCHANGE	,.F.)
	
	oStrCab:SetProperty('GQK_TCOLAB'	,MVC_VIEW_CANCHANGE	,.T.)
	oStrCab:SetProperty('GQK_DTREF'		,MVC_VIEW_CANCHANGE	,.T.)
	oStrCab:SetProperty('GQK_DTINI'		,MVC_VIEW_CANCHANGE	,.T.)
	oStrCab:SetProperty('GQK_HRINI'		,MVC_VIEW_CANCHANGE	,.T.)
	oStrCab:SetProperty('GQK_HRFIM'		,MVC_VIEW_CANCHANGE	,.T.)
	oStrCab:SetProperty('GQK_LOCORI'	,MVC_VIEW_CANCHANGE	,.T.)
	oStrCab:SetProperty('GQK_LOCDES'	,MVC_VIEW_CANCHANGE	,.T.)
	oStrCab:SetProperty('TEMPOPERCURSO'	,MVC_VIEW_CANCHANGE	,.T.)
	
	//-------------------------------------------------------------------
	oStrCab:AddGroup('GRP001', STR0016				,'', 2) //'Dados da Viagem'
	
	oStrCab:SetProperty('GQK_CODVIA'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_LOCORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_DSCORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_DTINI'		, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_HRINI'		, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_LOCDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_DSCDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_DTFIM'		, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	oStrCab:SetProperty('GYN_HRFIM'		, MVC_VIEW_GROUP_NUMBER, 'GRP001')
	//-------------------------------------------------------------------
	oStrCab:AddGroup('GRP002', STR0017				,'', 2) //'Dados do Recurso'
	oStrCab:SetProperty('GQK_TCOLAB'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_DCOLAB'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_DTREF'		, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_DTINI'		, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_HRINI'		, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_DTFIM'		, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_HRFIM'		, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_LOCORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_DESORI'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_LOCDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('GQK_DESDES'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	oStrCab:SetProperty('TEMPOPERCURSO'	, MVC_VIEW_GROUP_NUMBER, 'GRP002')
	
	oStrCab:SetProperty('GQK_LOCDES'	,MVC_VIEW_ORDEM		,'98')
	oStrCab:SetProperty('GQK_DESDES'	,MVC_VIEW_ORDEM		,'99')
	
	
Endif

If ValType(oStrDet) == "O"
	
	oStrDet:AddField("TEMPOPERCURSO"	,"07",STR0009	,STR0009	,{STR0009	},"Get","@R 99:99"	,NIL,"",.T.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.) //STR0009 //STR0009 //"Tempo Percurso"
	oStrDet:AddField("GQK_ITEM"			,'00',STR0008,STR0008	,{STR0008},"Get","",NIL,"",.T.,NIL,"",NIL,NIL,NIL,.T.,NIL,.F.) //STR0008 //STR0008 //"Item"
	
	oStrDet:RemoveField("GQK_CODVIA")
	oStrDet:RemoveField("GQK_CODIGO")
	oStrDet:RemoveField("GQK_TPDIA")
	oStrDet:RemoveField("GQK_FUNCIO")
	oStrDet:RemoveField("GQK_CODGZS")
	oStrDet:RemoveField("GQK_CONF")
	oStrDet:RemoveField("GQK_RECURS")
	oStrDet:RemoveField("GQK_DRECUR")
    oStrDet:RemoveField("GQK_STATUS")
    
	oStrDet:RemoveField("GQK_TCOLAB")
	oStrDet:RemoveField("GQK_LOCORI")
	oStrDet:RemoveField("GQK_LOCDES")
	
	oStrDet:SetProperty('*'				,MVC_VIEW_CANCHANGE	,.F.)
	oStrDet:SetProperty('GQK_HRINI'		,MVC_VIEW_CANCHANGE	,.T.)
	oStrDet:SetProperty('GQK_HRFIM'		,MVC_VIEW_CANCHANGE	,.T.)
	
	oStrDet:SetProperty('GQK_DCOLAB'	,MVC_VIEW_ORDEM		,'01')
	oStrDet:SetProperty('GQK_DTREF'		,MVC_VIEW_ORDEM		,'02')
	oStrDet:SetProperty('GQK_DTINI'		,MVC_VIEW_ORDEM		,'03')
	oStrDet:SetProperty('GQK_HRINI'		,MVC_VIEW_ORDEM		,'04')
	oStrDet:SetProperty('GQK_DTFIM'		,MVC_VIEW_ORDEM		,'05')
	oStrDet:SetProperty('GQK_HRFIM'		,MVC_VIEW_ORDEM		,'06')
	oStrDet:SetProperty('TEMPOPERCURSO'	,MVC_VIEW_ORDEM		,'07')
	oStrDet:SetProperty('GQK_DESORI'	,MVC_VIEW_ORDEM		,'08')
	oStrDet:SetProperty('GQK_DESDES'	,MVC_VIEW_ORDEM		,'09')
	                                                         
Endif

If ValType(oStrTot) == "O"
	oStrTot:RemoveField("GYQ_COLCOD")
	
Endif

If ValType(oStrGYG) == "O"
	oStrGYG:RemoveField("GYG_FUNCIO")
	oStrGYG:RemoveField("GYG_FILSRA")
Endif
Return


/*/{Protheus.doc} GC300MLoad
Função responsavel pela montagem dos dados do modelo 
@type function
@author jacomo.fernandes
@since 17/12/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GC300MLoad(oModel)
Local aRet		:= {}
Local aCampos	:= {}
Local cIdMdl	:= oModel:GetId()
Local aStrAux	:= oModel:GetStruct():GetFields()
Local cQry		:= ""
Local oMdlMnt	:= GC300GetMVC('M')

Local n1		:= 0
Local nPosFld	:= 0

If cIdMdl == "GQKMASTER"
	For n1	:= 1 To Len(aStrAux)
		If aStrAux[n1][4] == 'C'
			aAdd(aCampos,Space(aStrAux[n1][5]))
		Else
			aAdd(aCampos,GTPCastType(,aStrAux[n1][4]))
		Endif
	Next
	
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GQK_FILIAL" }) ) > 0
		aCampos[nPosFld] := xFilial('GQK')
	Endif 
	
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GQK_CODVIA" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_CODIGO')
	Endif 
	
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GQK_DTREF" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_DTINI')
	Endif
	
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GQK_DTINI" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_DTINI')
	Endif 

	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GYN_LOCORI" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_LOCORI')
	Endif 
		
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GYN_LOCDES" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_LOCDES')
	Endif 
	
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GQK_LOCORI" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_LOCORI')
	Endif 
		
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GQK_LOCDES" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_LOCDES')
	Endif 
	
	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GYN_DTINI" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_DTINI')
	Endif 

	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GYN_HRINI" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_HRINI')
	Endif 

	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GYN_DTFIM" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_DTFIM')
	Endif 

	If (nPosFld := aScan(aStrAux,{|x| AllTrim(x[3]) == "GYN_HRFIM" }) ) > 0
		aCampos[nPosFld] := oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_HRFIM')
	Endif 
	
	Aadd(aRet,aCampos)
	Aadd(aRet,0)
	
Elseif cIdMdl == "GYGDETAIL"
	
	cQry := "Select GYG_CODIGO,GYG_NOME,GYG_FUNCIO,GYG_FILSRA "
	cQry += "From "+RetSqlName('GYG')+" GYG "
	cQry += "	INNER JOIN "+RetSqlName('Gqe')+" GQE ON "
	cQry += "		GQE_FILIAL = '"+xFilial('GQE')+"' "
	cQry += "		AND GQE.GQE_RECURS = GYG_CODIGO "
	cQry += "		AND GQE_VIACOD = '"+oMdlMnt:GetModel('GYNDETAIL'):GetValue('GYN_CODIGO')+"' "
	cQry += "		AND GQE_TRECUR = '1' "
	cQry += "		AND GQE.D_E_L_E_T_ = ' ' "
	cQry += "Where "
	cQry += "	GYG_FILIAL = '"+xFilial('GYG')+"' "
	cQry += "	AND GYG.D_E_L_E_T_ = ' ' "
	cQry += "Group By GYG_CODIGO,GYG_NOME,GYG_FUNCIO,GYG_FILSRA "
	//RADU - JCA: DSERGTP-8012
	GTPNewTempTable(cQry,GetNextAlias(),{{"INDEX1",{"GYG_CODIGO"}}},,@oTableTmp)	//GTPTemporaryTable(cQry,GetNextAlias(),{{"INDEX1",{"GYG_CODIGO"}}},,@oTableTmp)
	
	(oTableTmp:GetAlias())->(DbGoTop())
	
	aRet := FWLoadByAlias(oModel, oTableTmp:GetAlias())
	
	//oTable:Delete()

Endif

Return aRet


/*/{Protheus.doc} IncluiAlocacao
(long_description)
@type function
@author jacomo.fernandes
@since 19/12/2018
@version 1.0
@param oView, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function IncluiAlocacao(oView)
Local lRet		:= .T.
Local oModel	:= oView:GetModel()
Local oMdlCab	:= oModel:GetModel('GQKMASTER')      
Local oMdlGYG	:= oModel:GetModel('GYGDETAIL')
Local oMdlDet	:= oModel:GetModel('GQKDETAIL')

Local oStrDet	:= oMdlDet:GetStruct()
Local aFldCab	:= oMdlCab:GetStruct():GetFields() 
Local aFldDet	:= oStrDet:GetFields() 

Local cRecurso	:= oMdlGYG:GetValue('GYG_CODIGO')
	
Local cMsgErro	:= ""
Local cSolucao	:= ""
Local n1		:= 0

If !VldFldObrigat(oMdlCab)
	lRet		:= .F.
	cMsgErro	:= STR0018 //'Um ou mais campos dos Dados do Recurso não foi preenchido'
	cSolucao	:= STR0019 //'Verifique se os campos estão preenchidos corretamente'
Endif

If lRet .and. oMdlGYG:IsEmpty()
	lRet		:= .F.
	cMsgErro	:= STR0020 //'Não existem recursos à serem incluidos'
	cSolucao	:= STR0021 //'Inclua primeiramente na rotina de inclusão de recurso'
Endif

If lRet .and. !VldLocaliViagem(oModel,@cMsgErro,@cSolucao)
	lRet		:= .F.
Endif

If lRet .and. !VldAlocRecurso(oModel,'GQKMASTER',@cMsgErro,@cSolucao)
	lRet		:= .F.
Endif

If lRet
	oMdlDet:SetNoInsertLine(.F.)
	If !oMdlDet:IsEmpty() .and. !Empty(oMdlDet:GetValue('GQK_RECURS'))
		lRet := oMdlDet:GetLine() < oMdlDet:AddLine()
	Endif
	
	If lRet
		lRet := oMdlDet:SetValue('GQK_RECURS', cRecurso)
	Endif
	
	If lRet
		For n1 := 1 To Len(aFldCab)
			
			If oStrDet:HasField(aFldCab[n1][3]) 
				If !oMdlDet:SetValue(aFldCab[n1][3]	,oMdlCab:GetValue(aFldCab[n1][3]))
					lRet := .F.
					Exit
				Endif
			Endif
		Next
	Endif
	If lRet
		lRet := oMdlDet:SetValue('GQK_TPDIA','1')
	Endif
	If lRet .and. Empty(oMdlDet:GetValue('GQK_CODIGO'))
		lRet := oMdlDet:SetValue('GQK_CODIGO',GTPXENUM('GQK','GQK_CODIGO'))
	Endif 
	If !lRet .or. !oMdlDet:VldLineData()
		lRet := .F.
		
		If oMdlDet:GetLine() > 1
			oMdlDet:DeleteLine(.T.,.T.)
		Else
			oMdlDet:ClearData()
		Endif
		
		JurShowError(oModel:GetErrorMessage())
		
	Else
		oMdlCab:ClearField('GQK_TCOLAB'	)
		oMdlCab:ClearField('GQK_DCOLAB'	)
		oMdlCab:ClearField('GQK_HRINI'	)
		oMdlCab:ClearField('GQK_DTFIM'	)
		oMdlCab:ClearField('GQK_HRFIM'	)
		oMdlCab:LoadValue('TEMPOPERCURSO','0000')
		
	Endif 
Endif

CalculaTotaisHoras(oModel)

oMdlDet:SetNoInsertLine(.T.)

If !lRet .and. !Empty(cMsgErro)
	FwAlertHelp(cMsgErro,cSolucao,'IncluiAlocacao')
Endif
oView:Refresh()

Return lRet

/*/{Protheus.doc} VldFldObrigat
Função para validar campos obrigatórios do cabeçalho
@type function
@author jacomo.fernandes
@since 15/01/2019
@version 1.0
@param oMdlCab, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldFldObrigat(oMdlCab)
Local lRet		:= .T.
Local aFldObrig	:= {'GQK_TCOLAB','GQK_DTREF','GQK_HRINI','GQK_HRFIM','GQK_LOCORI','GQK_LOCDES'}
Local n1		:= 0

For n1 := 1 To Len(aFldObrig)
	If Empty(oMdlCab:GetValue(aFldObrig[n1]))
		lRet := .F.
		Exit
	Endif
Next

Return lRet


/*/{Protheus.doc} VldAlocModelo
Função responsavel para validar o modelo de dados das alocações
@type function
@author jacomo.fernandes
@since 30/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cRecurso, character, (Descrição do parâmetro)
@param dDtIni, data, (Descrição do parâmetro)
@param cHrIni, character, (Descrição do parâmetro)
@param dDtFim, data, (Descrição do parâmetro)
@param cHrFim, character, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@param cSolucao, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldAlocModelo(oModel,cRecurso,dDtIni,cHrIni,dDtFim,cHrFim,cMsgErro,cSolucao)
Local lRet		:= .T.
Local oMdlDet	:= oModel:GetModel('GQKDETAIL')
Local aFldDet	:= oMdlDet:GetStruct():GetFields()	
Local aDataMdl	:= oMdlDet:GetData()

Local nPosDtIni	:= aScan(aFldDet,{|x| AllTrim(x[3]) == "GQK_DTINI" })
Local nPosHrIni	:= aScan(aFldDet,{|x| AllTrim(x[3]) == "GQK_HRINI" })
Local nPosDtFim	:= aScan(aFldDet,{|x| AllTrim(x[3]) == "GQK_DTFIM" })
Local nPosHrFim	:= aScan(aFldDet,{|x| AllTrim(x[3]) == "GQK_HRFIM" })
Local nPosItem	:= aScan(aFldDet,{|x| AllTrim(x[3]) == "GQK_ITEM" })

Local cItem		:= oMdlDet:GetValue('GQK_ITEM')
Local nLineMdl	:= 0

Local cDtIni	:= DtoS(dDtIni)
Local cDtFim	:= DtoS(dDtFim)
nLineMdl	:= aScan(aDataMdl,	{|x| (cItem == x[1,1,nPosItem]);
									.AND. (;
											(cDtIni+cHrIni < DtoS(x[1,1,nPosDtIni])+x[1,1,nPosHrIni] ;
											 	.AND. cDtFim+cHrFim <=  DtoS(x[1,1,nPosDtIni])+x[1,1,nPosHrIni]) ;
											 .OR.;
											 (cDtIni+cHrIni >= DtoS(x[1,1,nPosDtFim])+x[1,1,nPosHrFim] ;
											 	.AND. cDtFim+cHrFim >  DtoS(x[1,1,nPosDtFim])+x[1,1,nPosHrFim]) ;
										 );
										 	 .AND. !x[3] ; // Se a Linha não está deletada
								})
								
If nLineMdl == 0 .AND. !(EMPTY(cHrFim))
	nLineMdl	:= aScan(aDataMdl,	{|x| If(FwIsInCallStack('VALIDACAMPOS'), x[1,1,nPosItem] <> cItem,.T.) ;
										.AND. (;	
											(;
											 	(cDtIni+cHrIni <= DtoS(x[1,1,nPosDtIni])+x[1,1,nPosHrIni] ;
											 		.AND. cDtFim+cHrFim >= DtoS(x[1,1,nPosDtIni])+x[1,1,nPosHrIni]) ;
											 );	
											 .OR.(;
											 	(cDtIni+cHrIni <= DtoS(x[1,1,nPosDtIni])+x[1,1,nPosHrIni] ;
											 		.AND. cDtFim+cHrFim >= DtoS(x[1,1,nPosDtIni])+x[1,1,nPosHrIni]) ;
											 );		
											 .OR.(;
											 	(cDtIni+cHrIni >= DtoS(x[1,1,nPosDtIni])+x[1,1,nPosHrIni] ;
											 		.AND. cDtFim+cHrFim <= DtoS(x[1,1,nPosDtFim])+x[1,1,nPosHrFim]) ;
											 );			
											 .OR.(;
											 	(cDtIni+cHrIni <= DtoS(x[1,1,nPosDtFim])+x[1,1,nPosHrFim] ;
											 		.AND. cDtFim+cHrFim >= DtoS(x[1,1,nPosDtFim])+x[1,1,nPosHrFim]) ;
											 );
										 );	
										 .AND. !x[3] ; // Se a Linha não está deletada
									})
	
	If nLineMdl > 0
		cMsgErro := STR0022 //"O recurso escolhido já está alocado nesse periodo de data e horario."
		cSolucao := STR0023+ aDataMdl[nLineMdl,1,1,nPosItem] //"Verifique o Item: "
		lRet	:= .F.
	Endif
EndIf

Return lRet


/*/{Protheus.doc} CalculaTotaisHoras
Função responsavel pelo calculo de horas do colaborador
@type function
@author jacomo.fernandes
@since 24/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CalculaTotaisHoras(oModel)
Local oMdlCab	:= oModel:GetModel('GQKMASTER')
Local oMdlGYG	:= oModel:GetModel('GYGDETAIL')
Local oMdlDet	:= oModel:GetModel('GQKDETAIL')
Local oMdlTot	:= oModel:GetModel('TOTALHORAS')
Local n1		:= 0
Local nX		:= 0
Local nHrFV		:= 0
Local aTpColab	:= {}
Local nPosTpCol	:= 0
Local lMotorista:= .T.

Local dDtRef	:= StoD('')
Local dDtIni	:= StoD('')
Local cHrIni    := ""
Local dDtFim    := StoD('')
Local cHrFim    := ""

Local aSavHr	:= {}
Local aHrForaVol:= {}

Local nHrVolant	:= 0
Local nTorHrVol	:= 0

Local nHrFVolant:= 0
Local nTorHrFVol:= 0

Local nHrInterv	:= 0

Local nTotDias	:= DateDiffDay(oMdlCab:GetValue("GYN_DTINI"), oMdlCab:GetValue("GYN_DTFIM")) + 1
Local nHrDias	:= Posicione('SRA',1,oMdlGYG:GetValue("GYG_FILSRA") + oMdlGYG:GetValue("GYG_FUNCIO"), 'RA_HRSDIA')
Local nHrPeriod	:= Round(nHrDias * nTotDias,2)

Local nTotHrTrb	:= 0

Local nHrAdcNt	:= 0

Local nTotExtra	:= 0

Local nTotIntPag:= 0 

For n1	:= 1 to oMdlDet:Length()
	If oMdlDet:IsDeleted(n1)
		Loop
	Endif
	If (nPosTpCol := aScan(aTpColab,{|x| x[1] == oMdlDet:GetValue("GQK_TCOLAB",n1)  } ) ) == 0
		aAdd(aTpColab,{oMdlDet:GetValue("GQK_TCOLAB"),Posicione("GYK",1,xFilial("GYK")+oMdlDet:GetValue("GQK_TCOLAB",n1),"GYK_VALCNH") == "1"})
		nPosTpCol := Len(aTpColab)
	Endif
	
	lMotorista := aTpColab[nPosTpCol][2] 
	
	dDtRef	:= oMdlDet:GetValue("GQK_DTREF",n1)
	dDtIni	:= oMdlDet:GetValue("GQK_DTINI",n1)
	cHrIni	:= GTFormatHour(oMdlDet:GetValue("GQK_HRINI",n1), "99:99")
	dDtFim	:= oMdlDet:GetValue("GQK_DTFIM",n1)
	cHrFim	:= GTFormatHour(oMdlDet:GetValue("GQK_HRFIM",n1), "99:99")
	
	If lMotorista
		nHrVolant	:= HoraToInt(GTFormatHour(DataHora2Val(dDtIni,cHrIni,dDtFim,cHrFim,"H"), "99:99"))
		nTorHrVol	+= nHrVolant 
	Else
		nHrFVolant	:= HoraToInt(GTFormatHour(DataHora2Val(dDtIni,cHrIni,dDtFim,cHrFim,"H"), "99:99"))
		nTorHrFVol	+= nHrFVolant
	Endif
	
	If ( aScan(aSavHr,{|x| x[1] = DtoS(dDtRef)}) > 0 ) .OR. Empty(aSavHr)
		If !Empty(aSavHr)
					
			nHrInterv := HoraToInt(cHrIni)-HoraToInt(GTFormatHour(aSavHr[1][2], "99:99"))
			If nHrInterv > 0 
				If (nPos	:= aScan(aHrForaVol,{|x| x[1] = DtoS(dDtRef)})) = 0
					Aadd(aHrForaVol,{DtoS(dDtRef),{nHrInterv}})
				Else
					Aadd(aHrForaVol[nPos][2],nHrInterv)
				Endif
			Endif
			aSavHr	:=	{}
			aAdd(aSavHr,{DtoS(dDtRef),cHrFim})
		Else
			aAdd(aSavHr,{DtoS(dDtRef),cHrFim})
		EndIf
														
	Else
		aSavHr	:=	{}
		aAdd(aSavHr,{DtoS(dDtRef),cHrFim})
	Endif
	nHrAdcNt := SomaHoras(nHrAdcNt,TPTotHrAdic(cHrIni,cHrFim))
Next 

//Cálculo para Descontar o Maior Intervalo (Horas fora Volante)
aEval(aHrForaVol,{|z| ASORT(z[2],,, { |x, y| x > y } ) })

For nHrFV:= 1 To Len(aHrForaVol)
	For nX	:= 1 to Len(aHrForaVol[nHrFV][2])
		IF nX == 1
			If GTFormatHour(aHrForaVol[nHrFV][2][nX],"99.99") > '05.00'
				aHrForaVol[nHrFV][2][nX]:= SubHoras( GTFormatHour(aHrForaVol[nHrFV][2][nX],"99:99"),'05:00' )
			Else
				Loop
			Endif
		EndIF
		nTotIntPag	+= aHrForaVol[nHrFV][2][nX]
	Next
Next nHrFV

nTotHrTrb	:= nTorHrVol + nTorHrFVol + nTotIntPag
If nTotHrTrb > nHrPeriod
	nTotExtra := nTotHrTrb - nHrPeriod 
Endif

oMdlTot:LoadValue("GYQ_HRVOLA"	,GTFormatHour(GTPxHr2Str(IntToHora(nTorHrVol)	,"HHH:MM"), "99999") )
oMdlTot:LoadValue("GYQ_HRFVOL"	,GTFormatHour(GTPxHr2Str(IntToHora(nTorHrFVol)	,"HHH:MM"), "99999") )

oMdlTot:LoadValue("GYQ_HRMENS"	,GTFormatHour(GTPxHr2Str(IntToHora(nHrPeriod)	,"HHH:MM"), "99999") )
oMdlTot:LoadValue("GYQ_HRTRAB"	,GTFormatHour(GTPxHr2Str(IntToHora(nTotHrTrb)	,"HHH:MM"), "99999") )
oMdlTot:LoadValue("GYQ_HRADN" 	,GTFormatHour(GTPxHr2Str(IntToHora(nHrAdcNt)	,"HHH:MM"), "99999") )
oMdlTot:LoadValue("GYQ_HREXTR"	,GTFormatHour(GTPxHr2Str(IntToHora(nTotExtra)	,"HHH:MM"), "99999") )
oMdlTot:LoadValue("GYQ_HRDESP"	,GTFormatHour(GTPxHr2Str(IntToHora(nTotIntPag)	,"HHH:MM"), "99999") )

Return


/*/{Protheus.doc} Gc300mPreLine
(long_description)
@type function
@author jacomo.fernandes
@since 25/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uValue, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Gc300mPreLine(oModel,nLine,cAction,cField,uValue)
Local lRet		:= .T.
Local oView		:= FwViewActive()
Local cMdlId	:= oModel:GetId()
Local aDataMdl	:= nil
Local cMsgErro	:= ""
Local cSolucao	:= ""
If cMdlId == "GQKDETAIL"

	IF cAction == "UNDELETE"
		lRet := VldAlocRecurso(oModel:GetModel(),"GQKDETAIL",@cMsgErro,@cSolucao)
	Endif
	
	If lRet .and. (cAction == "DELETE" .or. cAction == "UNDELETE")
		aDataMdl := oModel:GetData()
		aDataMdl[nLine][3] := If(cAction == "DELETE",.T.,.F.)
		
		CalculaTotaisHoras(oModel:GetModel())	
	Endif

Endif

If !lRet .and. !Empty(cMsgErro)
	oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,oModel:GetId(),cField,'Gc300mPreLine',cMsgErro,cSolucao)
Endif


Return lRet

/*/{Protheus.doc} VldAlocRecurso
(long_description)
@type function
@author jacomo.fernandes
@since 30/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cMdlAux, character, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@param cSolucao, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldAlocRecurso(oModel,cMdlAux,cMsgErro,cSolucao)
Local lRet	:= .T.

Local oMdlGYG	:= oModel:GetModel('GYGDETAIL')

Local cRecurso	:= oMdlGYG:GetValue('GYG_CODIGO')
Local cTipo		:= '1' //Colaborador
Local dDtRef	:= StoD('')
Local dDtIni	:= StoD('')  
Local cHrIni	:= ""   
Local dDtFim	:= StoD('')  
Local cHrFim	:= ""
Local nRecGQK   := 0

Default cMdlAux	:= "GQKMASTER"
Default cMsgErro:= ""
Default cSolucao:= ""

dDtRef	:= oModel:GetModel(cMdlAux):GetValue("GQK_DTREF")
dDtIni	:= oModel:GetModel(cMdlAux):GetValue("GQK_DTINI") 
cHrIni	:= oModel:GetModel(cMdlAux):GetValue('GQK_HRINI') 
cHrFim	:= oModel:GetModel(cMdlAux):GetValue('GQK_HRFIM') 

dDtFim	:= GetDtFinal(dDtIni,cHrIni,cHrFim) //GQK_DTFIM
nRecGQK := oModel:GetModel(cMdlAux):GetDataId()

If lRet .and. !VldAlocModelo(oModel,cRecurso,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,@cSolucao)
	lRet		:= .F.
Endif

If lRet .and. !Gc300VldAloc(cRecurso,cTipo,dDtRef,dDtIni,cHrIni,dDtFim,cHrFim,@cMsgErro,nRecGQK) 
	lRet		:= .F.
	cSolucao	:= ""
Endif

Return lRet


/*/{Protheus.doc} GetDtFinal
(long_description)
@type function
@author jacomo.fernandes
@since 30/01/2019
@version 1.0
@param dDtInic, data, (Descrição do parâmetro)
@param cHrInic, character, (Descrição do parâmetro)
@param cHrFinal, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetDtFinal(dDtInic,cHrInic,cHrFinal)
Local dDtFinal	:= Stod('') 
	
	If cHrFinal <= cHrInic //Se hora final for menor que a hora inicial, quer dizer que o dia mudou
		If !(EMPTY(cHrFinal))
			dDtFinal	:= dDtInic + 1
		Else
			dDtFinal	:= dDtInic
		EndIf
	Else
		dDtFinal	:= dDtInic
	
	Endif
Return dDtFinal


/*/{Protheus.doc} VldLocaliViagem
Função responsavel para verificar se as localidades informadas compoem a viagem
@type function
@author jacomo.fernandes
@since 31/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cMsgErro, character, (Descrição do parâmetro)
@param cSolucao, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VldLocaliViagem(oModel,cMsgErro,cSolucao)
Local lRet		:= .T.
Local oMdlCab	:= oModel:GetModel('GQKMASTER')
Local cViagem	:= oMdlCab:GetValue('GQK_CODVIA')
Local cLocOri	:= oMdlCab:GetValue('GQK_LOCORI')
Local cLocDes	:= oMdlCab:GetValue('GQK_LOCDES') 
Local aAreaG55	:= G55->(GetArea())

G55->(DbOrderNickname('G55LOCORI'))
If !G55->(DbSeek(xFilial('G55')+cViagem+cLocOri))
	lRet := .F.
	cLocErro := STR0024 //"Origem"
Endif

G55->(DbOrderNickname('G55LOCDES'))
If lRet .and. !G55->(DbSeek(xFilial('G55')+cViagem+cLocDes))
	lRet := .F.
	cLocErro := STR0025 //"Destino"
Endif

If !lRet .and. !FwAlertYesNo(STR0027,STR0026) //"Atenção!!!" //"Itnerário selecionado não existe na viagem. Deseja continuar?"
	cMsgErro := I18n(STR0028,{cLocErro}) //"Localidade de #1 não existe na viagem"
	cSolucao := STR0029 //"Selecione uma Localidade válida"
Else
	lRet := .T.
Endif
RestArea(aAreaG55)

Return lRet 
