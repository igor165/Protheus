#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'FINA960.ch'

#DEFINE OPER_APURAR			10
#DEFINE OPER_TITULO			11
#DEFINE OPER_EXCTITULO		12


Static __lConfirmar		:= .F.
Static __nOper     		:= 0
Static __lBTNConfirma	:= .F.

//-------------------------------------------------------------------
/* {Protheus.doc} FINA960

Apuração de IRPJ/CSLL lucro real

@author Alvaro Camillo Neto
   
@version P12
@since   19/09/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function FINA960()
Local oBrowse
Local lFilTit := FR7->(ColumnPos("FR7_FILTIT") ) > 0
Local lLAFR4  := FR4->(ColumnPos("FR4_LA") ) > 0
Local lLAFR5  := FR5->(ColumnPos("FR5_LA") ) > 0

If lFilTit .And. lLAFR4 .And. lLAFR5
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('FR4')
	oBrowse:SetDescription(STR0001)//'Apuração IRPJ/CSLL Lucro Real'
	oBrowse:AddLegend( "FR4_STATUS == '1' ", "GREEN"	, STR0002 )//"Aberto"	
	oBrowse:AddLegend( "FR4_STATUS == '2' ", "YELLOW"	, STR0003 )//"Apurado"
	oBrowse:AddLegend( "FR4_STATUS == '3' ", "BLUE"		, STR0004 )//"Titulo Gerado"
	oBrowse:AddLegend( "FR4_STATUS == '4' ", "RED"		, STR0005 )//"Contabilizado"
	oBrowse:Activate()
Else
	MsgNextRel()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Menu de Ativos Imobilizados
@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Static Function MenuDef()
Local aRotina 	:= {}	

ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FINA960' 	OPERATION 2 ACCESS 0//'Visualizar'
ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FINA960' 	OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FINA960'	OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0009 ACTION 'FINA960APU'		OPERATION 4 ACCESS 0 //'Apuração'
ADD OPTION aRotina TITLE STR0036 ACTION 'FINA960TIT'		OPERATION 4 ACCESS 0 //'Gerar Título'
ADD OPTION aRotina TITLE STR0042 ACTION 'FI960ESTIT'		OPERATION 4 ACCESS 0 //'Estorno Geração Título'
ADD OPTION aRotina TITLE STR0048 ACTION 'FINA960CTB'		OPERATION 4 ACCESS 0 //'Contabilização'
ADD OPTION aRotina TITLE STR0049 ACTION 'FI960ESEST'		OPERATION 4 ACCESS 0 //'Estorno Contabilização'
ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.FINA960' 	OPERATION 5 ACCESS 0 //'Excluir'


Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStr1	:= FWFormStruct(1,'FR4') 
Local oStr2	:= FI960Struct('1')
Local oStr3	:= FI960Struct('2')
Local oStr4	:= FI960Struct('3')
Local oStr5	:= FI960Struct('4')
Local oStr6	:= FI960Struct('5')
Local oStr8	:= FWFormStruct(1,'FR6')
Local oStr9	:= FWFormStruct(1,'FR7')
Local bPreLin	:= { |oModelGrid,  nLine, cAction,cField| FR5LINPRE(oModelGrid,cAction) }

oStr1:SetProperty('FR4_STATUS'	,MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "'1'"))

oModel := MPFormModel():New( 'FINA960', /*bPreValidacao*/, { |oModel| FI960POSVL(oModel) },  /* bCommit */, /*bCancel*/ )

oModel:SetDescription(STR0012)//'Apuração IRPJ/CSLL Lucro Real'

oModel:addFields('FR4MASTER',,oStr1)
oModel:addGrid('FR5RESCTB'	,'FR4MASTER',oStr2, bPreLin, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:addGrid('FR5ADI'		,'FR4MASTER',oStr3, bPreLin, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:addGrid('FR5EXC'		,'FR4MASTER',oStr4, bPreLin, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:addGrid('FR5COMP'		,'FR4MASTER',oStr5, bPreLin, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:addGrid('FR5DED'		,'FR4MASTER',oStr6, bPreLin, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:addGrid('FR6DETAIL'	,'FR4MASTER',oStr8, bPreLin, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
oModel:addGrid('FR7DETAIL'	,'FR4MASTER',oStr9, bPreLin, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)

oModel:SetRelation('FR5RESCTB'	, { { 'FR5_FILIAL', 'xFilial("FR5")' }, { 'FR5_CODAPU', 'FR4_CODAPU' }, { 'FR5_TIPO', "'1'" } }, FR5->(IndexKey(1)) )
oModel:SetRelation('FR5ADI'   	, { { 'FR5_FILIAL', 'xFilial("FR5")' }, { 'FR5_CODAPU', 'FR4_CODAPU' }, { 'FR5_TIPO', "'2'" } }, FR5->(IndexKey(1)) )
oModel:SetRelation('FR5EXC' 	, { { 'FR5_FILIAL', 'xFilial("FR5")' }, { 'FR5_CODAPU', 'FR4_CODAPU' }, { 'FR5_TIPO', "'3'" } }, FR5->(IndexKey(1)) )
oModel:SetRelation('FR5COMP' 	, { { 'FR5_FILIAL', 'xFilial("FR5")' }, { 'FR5_CODAPU', 'FR4_CODAPU' }, { 'FR5_TIPO', "'4'" } }, FR5->(IndexKey(1)) )
oModel:SetRelation('FR5DED' 	, { { 'FR5_FILIAL', 'xFilial("FR5")' }, { 'FR5_CODAPU', 'FR4_CODAPU' }, { 'FR5_TIPO', "'5'" } }, FR5->(IndexKey(1)) )
oModel:SetRelation('FR6DETAIL'	, { { 'FR6_FILIAL', 'xFilial("FR6")' }, { 'FR6_CODAPU', 'FR4_CODAPU' } 	}, FR6->(IndexKey(1)) )
oModel:SetRelation('FR7DETAIL'	, { { 'FR7_FILIAL', 'xFilial("FR7")' }, { 'FR7_CODAPU', 'FR4_CODAPU' } 	}, FR7->(IndexKey(1)) )

oModel:getModel('FR4MASTER'):SetDescription(STR0013)

oModel:GetModel( 'FR5RESCTB'	):SetUniqueLine( { 'FR5_ENTID' } )
oModel:GetModel( 'FR5ADI' 		):SetUniqueLine( { 'FR5_ENTID' } )
oModel:GetModel( 'FR5EXC'		):SetUniqueLine( { 'FR5_ENTID' } )
oModel:GetModel( 'FR5COMP' 		):SetUniqueLine( { 'FR5_ENTID' } )
oModel:GetModel( 'FR5DED' 		):SetUniqueLine( { 'FR5_ENTID' } )


oModel:getModel('FR5RESCTB'):SetOptional(.T.)
oModel:getModel('FR5ADI'):SetOptional(.T.)
oModel:getModel('FR5EXC'):SetOptional(.T.)
oModel:getModel('FR5COMP'):SetOptional(.T.)
oModel:getModel('FR5DED'):SetOptional(.T.)
oModel:getModel('FR6DETAIL'):SetOptional(.T.)
oModel:getModel('FR7DETAIL'):SetOptional(.T.)

oModel:GetModel( 'FR5RESCTB' ):SetNoInsertLine( .T. )
oModel:GetModel( 'FR5RESCTB' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FR5RESCTB' ):SetNoUpdateLine( .T. )

oModel:GetModel( 'FR6DETAIL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'FR6DETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FR6DETAIL' ):SetNoUpdateLine( .T. )

oModel:GetModel( 'FR7DETAIL' ):SetNoInsertLine( .T. )
oModel:GetModel( 'FR7DETAIL' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'FR7DETAIL' ):SetNoUpdateLine( .T. )

oModel:SetVldActivate( {|oModel| FI960VLMod(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} FI960POSVL
Pós validação do modelo

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FI960VLMod(oModel)
Local nOperation := oModel:GetOperation()
Local lRet := .T.

If lRet .And. (nOperation == MODEL_OPERATION_UPDATE ) .And. !(FR4->FR4_STATUS $ "1/2") 
	Help(" ",1,"FI960STAALT",,STR0014 ,1,0)//"Não é possível alterar apuração com esse status"

	lRet := .F.
EndIf

If lRet .And. (nOperation == MODEL_OPERATION_DELETE ) .And. !(FR4->FR4_STATUS $ "1/2")
	Help(" ",1,"FI960STADEL",,STR0015 ,1,0)//"Não é possível excluir apuração com esse status"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FI960POSVL
Pós validação do modelo

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FI960POSVL(oModel)
Local lRet 			:= .T.
Local nOperation 		:= oModel:GetOperation()
Local oView	 		:= FWViewActive()
Local lNaoAlt		:= .T.
Local oModelFR4		:= oModel:GetModel('FR4MASTER')
Local oModelRes		:= oModel:GetModel('FR5RESCTB')
Local oModelAdi		:= oModel:GetModel('FR5ADI')
Local oModelExc		:= oModel:GetModel('FR5EXC')
Local oModelCom		:= oModel:GetModel('FR5COMP')
Local oModelDed		:= oModel:GetModel('FR5DED')
Local aAlter			:= {}
Local nX				:= 0

aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_TIPAPU") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_DTINI") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_DTFIM") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_TPVAL") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_LIVRES") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_LIVADI") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_LIVEXC") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_LIVCOM") } )
aAdd(aAlter , {|| !oModelFR4:IsFieldUpdated("FR4_LIVDED") } )

If __nOper == 0
	If nOperation == MODEL_OPERATION_UPDATE
	
		If oView != Nil .And. oModelFR4:GetValue("FR4_STATUS") == '2'
			
			lNaoAlt := lNaoAlt .And. FI960AltCom(oModelRes)
			lNaoAlt := lNaoAlt .And. FI960AltCom(oModelAdi)
			lNaoAlt := lNaoAlt .And. FI960AltCom(oModelExc)
			lNaoAlt := lNaoAlt .And. FI960AltCom(oModelCom)
			lNaoAlt := lNaoAlt .And. FI960AltCom(oModelDed)
			
			If lNaoAlt
				For nX:= 1 to Len(aAlter)
					lNaoAlt := Eval(aAlter[nX])
					If !lNaoAlt
						Exit
					EndIf
				Next nX
			EndIf
			If !lNaoAlt 
				lRet := MsgYesNo(STR0016)//"Após realizar a alteração a opção de Apuração deve ser realizada novamente. Confirma ?"
				If !lRet
					Help( " ", 1, "FI960CANC",, STR0017, 1, 0 )//"Operação cancelada" 
				Else
					oModelFR4:LoadValue("FR4_STATUS","1")
				EndIf
			EndIf
		EndIf
	
	EndIf
EndIf



Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FI960AltCom
Retorna se o componente não foi alterado

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function FI960AltCom(oModel)
Local lRet  := .T.
Local nLine := 0
Local aSaveLines 	:= FWSaveRows()

For nLine := 1 to oModel:Length()
	oModel:GoLine(nLine)
	If oModel:IsDeleted() .Or. oModel:IsInserted() .Or. oModel:IsUpdated()
		lRet := .F.
		Exit
	EndIf
Next nLine

FWRestRows(aSaveLines)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FR5LINPRE
Pré validação de linha

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FR5LINPRE(oModelGrid,cAction)

Local lRet    := .T.
Local cTipReg := oModelGrid:GetValue("FR5_TPREG")

If cTipReg == '1'
	lRet := .F.
EndIf  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FI960Struct
Definição de estrutura dos componentes do cálculo

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function FI960Struct(cTipo)
Local oStruct		:= FWFormStruct( 1, "FR5" , /*bAvalCampo*/, /*lViewUsado*/ )
Local cNomeModel	:= ""

If cTipo == '1'
	cNomeModel := 'FR5RESCTB'
ElseIf cTipo == '2'
	cNomeModel := 'FR5ADI'
ElseIf cTipo == '3'
	cNomeModel := 'FR5EXC'
ElseIf cTipo == '4'
	cNomeModel := 'FR5COMP'
ElseIf cTipo == '5'
	cNomeModel := 'FR5DED'
EndIf

oStruct:SetProperty('FR5_TIPO'	,MODEL_FIELD_INIT,FWBuildFeature( STRUCT_FEATURE_INIPAD, "'"+cTipo+"'"))

oStruct:AddTrigger( "FR5_ENTID"	, "FR5_ENTID" , {|| .T. } , {|| FI960GAT("FR5_ENTID",cNomeModel) }  )
oStruct:AddTrigger( "FR5_DESC"	, "FR5_DESC"	, {|| .T. } , {|| FI960GAT("FR5_DESC",cNomeModel) }  )
oStruct:AddTrigger( "FR5_VALOR"	, "FR5_VALOR" , {|| .T. } , {|| FI960GAT("FR5_VALOR",cNomeModel) }  )
oStruct:AddTrigger( "FR5_DC"	, "FR5_DC" 	, {|| .T. } , {|| FI960GAT("FR5_DC",cNomeModel) }  )



Return oStruct
//-------------------------------------------------------------------
/*/{Protheus.doc} FI960GAT
Gatilho dos componentes de calculo

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FI960GAT(cCpoAux,cNomeModel)
Local oModel    	:= FWModelActive()
Local xRet      	:= ""
Local oModelDet	:= oModel:GetModel(cNomeModel)
Local cUser		:= RetCodUsr()
Local cNome		:= Left(Alltrim(UsrRetName(cUser)) , TamSX3("FR5_NOMEUS")[1] )
		
xRet := oModelDet:GetValue(cCpoAux)

oModelDet:LoadValue("FR5_TPREG",'2')
oModelDet:LoadValue("FR5_USER",cUser)
oModelDet:LoadValue("FR5_NOMEUS",cNome)
oModelDet:LoadValue("FR5_DTALT",MsDate())

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2, 'FR4')
Local oStr2:= FWFormStruct(2, 'FR5')
Local oStr3:= FWFormStruct(2, 'FR5')
Local oStr4:= FWFormStruct(2, 'FR5')
Local oStr5:= FWFormStruct(2, 'FR5')
Local oStr6:= FWFormStruct(2, 'FR5')
Local oStr7:= FWFormStruct(2, 'FR6')
Local oStr8:= FWFormStruct(2, 'FR7')

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField('FORM1' , oStr1,'FR4MASTER' )
oView:AddGrid('FORM5' , oStr2,'FR5RESCTB')
oView:AddGrid('FORM7' , oStr3,'FR5ADI')
oView:AddGrid('FORM9' , oStr4,'FR5EXC')
oView:AddGrid('FORM11' , oStr5,'FR5COMP')
oView:AddGrid('FORM13' , oStr6,'FR5DED')
oView:AddGrid('FORM15' , oStr7,'FR6DETAIL')
oView:AddGrid('FORM17' , oStr8,'FR7DETAIL')        

oStr1:RemoveField( 'FR4_STATUS' )
oView:CreateHorizontalBox( 'BOXFORM1', 40)
oView:CreateHorizontalBox( 'BOX3', 60)
oView:CreateFolder( 'FOLDER4', 'BOX3')

oView:AddSheet('FOLDER4','SHEET10',STR0019)//'Resultado Contábil'
oView:AddSheet('FOLDER4','SHEET9',STR0020)//'Adição'
oView:AddSheet('FOLDER4','SHEET8',STR0021)//'Exclusão'
oView:AddSheet('FOLDER4','SHEET7',STR0022)

oView:AddSheet('FOLDER4','SHEET6',STR0023)//'Dedução'
oView:AddSheet('FOLDER4','SHEET5',STR0024)
oView:AddSheet('FOLDER4','SHEET17',STR0052)//"Filial da Apuração"

oView:CreateHorizontalBox( 'BOXFORM17', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET17')
oView:SetOwnerView('FORM17','BOXFORM17')

oView:CreateHorizontalBox( 'BOXFORM15', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET5')
oView:SetOwnerView('FORM15','BOXFORM15')
oView:CreateHorizontalBox( 'BOXFORM13', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET6')
oView:SetOwnerView('FORM13','BOXFORM13')
oView:CreateHorizontalBox( 'BOXFORM11', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET7')
oView:SetOwnerView('FORM11','BOXFORM11')
oView:CreateHorizontalBox( 'BOXFORM9', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET8')
oView:SetOwnerView('FORM9','BOXFORM9')

oView:CreateHorizontalBox( 'BOXFORM7', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET9')
oView:SetOwnerView('FORM7','BOXFORM7')

oStr2:RemoveField( 'FR5_TIPO' )
oStr2:RemoveField( 'FR5_CODAPU' )
oStr2:RemoveField( 'FR5_DTALT' )
oStr2:RemoveField( 'FR5_NOMEUS' )
oStr2:RemoveField( 'FR5_USER' )

oStr3:RemoveField( 'FR5_TIPO' )
oStr3:RemoveField( 'FR5_CODAPU' )
oStr3:RemoveField( 'FR5_TOTVIS' )

oStr4:RemoveField( 'FR5_TIPO' )
oStr4:RemoveField( 'FR5_CODAPU' )
oStr4:RemoveField( 'FR5_TOTVIS' )

oStr5:RemoveField( 'FR5_TIPO' )
oStr5:RemoveField( 'FR5_CODAPU' )
oStr5:RemoveField( 'FR5_TOTVIS' )

oStr6:RemoveField( 'FR5_TIPO' )
oStr6:RemoveField( 'FR5_CODAPU' )
oStr6:RemoveField( 'FR5_TOTVIS' )

oStr7:RemoveField( 'FR6_CODAPU' )

oStr8:RemoveField( 'FR7_CODAPU' )


oView:CreateHorizontalBox( 'BOXFORM5', 100, /*owner*/, /*lUsePixel*/, 'FOLDER4', 'SHEET10')
oView:SetOwnerView('FORM5','BOXFORM5')
oView:SetOwnerView('FORM1','BOXFORM1')

oView:EnableTitleView('FORM5' ,STR0019)//'Resultado Contábil'
oView:EnableTitleView('FORM7' ,STR0020)//'Adição'
oView:EnableTitleView('FORM9' ,STR0021)//'Exclusão'
oView:EnableTitleView('FORM11' ,STR0022)//'Compensação'
oView:EnableTitleView('FORM13' ,STR0023)//'Dedução' 
oView:EnableTitleView('FORM15' ,STR0024)//'Títulos Financeiros'
oView:EnableTitleView('FORM17' ,STR0052)//"Filial da Apuração"

oView:EnableTitleView('FORM1' , STR0025 )//'Configuração' 

oView:SetViewProperty('FORM15' , 'ONLYVIEW' )
oView:SetViewProperty('FORM17' , 'ONLYVIEW' )

oView:AddIncrementField('FORM5'		, 'FR5_ITEM' ) 
oView:AddIncrementField('FORM7'		, 'FR5_ITEM' ) 
oView:AddIncrementField('FORM9'		, 'FR5_ITEM' ) 
oView:AddIncrementField('FORM11'	, 'FR5_ITEM' ) 
oView:AddIncrementField('FORM13'	, 'FR5_ITEM' ) 
oView:AddIncrementField('FORM15'	, 'FR6_ITEM' ) 
oView:AddIncrementField('FORM17'	, 'FR7_ITEM' ) 

oView:SetViewProperty('FORM5' , 'ONLYVIEW' )

If  __lBTNConfirma 
	oView:AddUserButton( STR0034, 'OK', {|oView| F960CancVs(oView) } )	//"Cancelar"
EndIf

oView:SetCloseOnOK( {|| .T.} )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} F960VlData
Validação campo data

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function F960VlData() 
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local dDataIni	:= oModel:GetValue("FR4MASTER","FR4_DTINI")
Local dDataFim	:= oModel:GetValue("FR4MASTER","FR4_DTFIM")


If !Empty(dDataIni) .And. !Empty(dDataFim) .And. dDataFim < dDataIni
	Help(" ",1,"FIN960DATA",,STR0035 ,1,0)//"Data inicial deve ser menor que a data final."
	lRet := .F.
EndIf  

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F960ValTit
Validação dos campos de título

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function F960ValTit()
Local lRet			:= .T.
Local oModel		:= FWModelActive()
Local cPrefix		:= oModel:GetValue("FR4MASTER","FR4_PREFIX")
Local cNum			:= oModel:GetValue("FR4MASTER","FR4_NUM")
Local aArea			:= GetArea()

dbSelectArea("SE2")
SE2->(dbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

If !Empty(cPrefix) .And. !Empty(cNum) 	
	If SE2->(dbSeek( xFilial("SE2") + cPrefix + cNum ))
		Help(" ",1,"FIN960NUM",,STR0047 ,1,0)//"Prefixo e número já estão sendo utilizados."
		lRet := .F.
	EndIf
EndIf  

RestArea(aArea)
Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} F960CancVs
Botão de cancelar para operações

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Static Function F960CancVs(oView)

oView:ButtonCancelAction()

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} F960ConfVs
Botão de confirmar para operações

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function F960ConfVs()
Local cMensagem := ""
Local lRet		:= .F.

If __nOper == OPER_APURAR
	cMensagem := STR0027 //"Deseja realizar a apuração ?"
ElseIf __nOper == OPER_TITULO
	cMensagem := STR0041 //"Deseja realizar a geração de título ?"
ElseIf __nOper == OPER_EXCTITULO
	cMensagem := STR0046 //"Deseja realizar a exclusão de títulos ?"
EndIf

If MsgYesNo(cMensagem)
	__lConfirmar := .T.
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FI960ESTIT
Rotina de estorno de títulos a partir da apuração
@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Function FI960ESTIT(cAlias,nReg,nOpc)
Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 		:= ""
Local nOperation 		:= MODEL_OPERATION_VIEW
Local cCodApu			:= FR4->FR4_CODAPU
Local lRet				:= .T.
Local aButtons			:= {}
Local bCancel			:= {|| F960ConfVs() }

If lRet .And. !(FR4->FR4_STATUS $ '3' )
	Help(" ",1,"FIN960TIT4",,STR0043 ,1,0)// "Essa operação somente é possivel com o status - Titulo Gerado."
	lRet := .F.
EndIf

If lRet
	cTitulo 			:= STR0044 //'Estornar Título'
	cPrograma 			:= 'FINA960'
	nOperation 			:= MODEL_OPERATION_VIEW // Visualizar
	__lConfirmar		:= .F.
	__nOper     		:= OPER_EXCTITULO
	__lBTNConfirma	:= .T.

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0037},{.T.,STR0026},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"//"Salvar"
		
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
	
	If __lConfirmar
		MsgRun( STR0045 ,, {||	lRet := FI960ExcTit(cCodApu) } )//"Excluindo Títulos de Imposto..." 
	EndIf
EndIf


__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA960TIT
Rotina de geração de títulos a partir da apuração
@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Function FINA960TIT(cAlias,nReg,nOpc)
Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 		:= ""
Local nOperation 		:= MODEL_OPERATION_VIEW
Local cCodApu			:= FR4->FR4_CODAPU
Local lRet				:= .T.
Local aButtons			:= {}
Local bCancel			:= {|| F960ConfVs() }

If lRet .And. !(FR4->FR4_STATUS $ '2' )
	Help(" ",1,"FIN960TIT1",,STR0038 ,1,0)// "Essa operação somente é possivel com o status - Apurado."
	lRet := .F.
EndIf

If lRet .And. ( Empty(FR4->FR4_PREFIX) .Or. Empty(FR4->FR4_NUM) .Or. Empty(FR4->FR4_COND) .Or. Empty(FR4-> FR4_CODRET)  .Or. Empty(FR4-> FR4_EMISSA) )
	Help(" ",1,"FIN960TIT2",,STR0040 ,1,0)// "Para realizar essa operação, as informações da aba - Títulos Financeiros - devem ser preenchidas corretamente "
	lRet := .F.
EndIf

If lRet .And. FR4->FR4_TIPAPU == "1" .And. FR4->FR4_IRPAG <= 0
	lRet := .F.
	Help(" ",1,"FIN960TIT3",,STR0053,1,0) //"Não há valor a ser pago para geração do titulo. Confira a aba IRPJ."
EndIf

If lRet .And. FR4->FR4_TIPAPU == "2" .And. FR4->FR4_CSLP <= 0
	lRet := .F.
	Help(" ",1,"FIN960TIT4",,STR0054,1,0) //"Não há valor a ser pago para geração do titulo. Confira a aba CSLL."
EndIf

If lRet
	cTitulo 			:= STR0036 //'Gerar Título'
	cPrograma 			:= 'FINA960'
	nOperation 			:= MODEL_OPERATION_VIEW // Visualizar
	__lConfirmar		:= .F.
	__nOper     		:= OPER_TITULO
	__lBTNConfirma	:= .T.

	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0037},{.T.,STR0026},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"//"Salvar"
		
	FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
	
	If __lConfirmar
		MsgRun( STR0039 ,, {||	lRet := FI960PrTit(cCodApu) } )//"Gerando Títulos de Imposto..." 
	EndIf
EndIf


__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA960APU
Rotina de apuração de IRPJ/CSLL processando as visões gerenciais e preenchendo os componentes do calculo

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FINA960APU(cAlias,nReg,nOpc)
Local aArea			:= GetArea()
Local lConfirma		:= .F.
Local lCancela		:= .F.
Local cTitulo 		:= ""
Local cPrograma 		:= ""
Local nOperation 		:= MODEL_OPERATION_VIEW
Local cCodApu			:= FR4->FR4_CODAPU
Local lRet				:= .T.
Local aButtons		:= {}
Local bCancel			:= {|| F960ConfVs() }
Local aSelFil			:= {} 
If lRet .And. !(FR4->FR4_STATUS $ '1/2' )
	Help(" ",1,"FIN960APU1",,STR0028 ,1,0)//"Não é possível realizar a operação com esse status"
	lRet := .F.
EndIf

If lRet
	cTitulo 			:= STR0030//"Apuração"
	cPrograma 			:= 'FINA960'
	nOperation 			:= MODEL_OPERATION_VIEW // Visualizar
	__lConfirmar		:= .F.
	__nOper     		:= OPER_APURAR
	__lBTNConfirma	:= .T.
	
	aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0037},{.T.,STR0026},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"
	
	If Pergunte("FINA960A",.T.)
		
		If MV_PAR01 == 1 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
			aSelFil := AdmGetFil()
			If Len( aSelFil ) <= 0
				lRet := .F.
			EndIf
		Else
			aSelFil := { cFilAnt }
		EndIf
		
		If lRet
			FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. }/*bCloseOnOk*/,/*bOk*/, /*nPercReducao*/, aButtons , bCancel )
			
			If __lConfirmar
				MsgRun( STR0029 ,, {||	lRet := FI960PrApu(cCodApu,aSelFil,MV_PAR02==1,MV_PAR03) } )//"Processando apuração..."
			EndIf
		EndIf
	EndIf
EndIf



__lConfirmar:= .F.
__lBTNConfirma  := .F.
__nOper     := 0

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FI960ExcTit
Realiza o processamento da exclusao de título de imposto

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Function FI960ExcTit(cCodApu)
Local lRet			:= .T.
Local aTit			:= {}
Local nLenTit 		:= TamSx3("E2_NUM")[1]
Local nLenPar 		:= TamSx3("E2_PARCELA")[1]
Local nLenFor 		:= TamSx3("E2_FORNECE")[1]
Local nLenLoj 		:= TamSx3("E2_LOJA")[1]
Local nLenTipo 		:= TamSx3("E2_TIPO")[1]
Local nLenPref		:= TamSx3("E2_PREFIXO")[1]

Private lMsHelpAuto := .T. 
Private lMsErroAuto := .F. 

FR4->(dbSetOrder(1)) //FR4_FILIAL + FR4_CODAPU
FR6->(dbSetOrder(1)) //FR6_FILIAL+FR6_CODAPU+FR6_ITEM

If FR4->(!dbSeek(xFilial("FR4") + cCodApu))
	lRet := .F.
EndIf


If lRet
	BEGIN TRANSACTION
		If FR6->(dbSeek(xFilial("FR6") + cCodApu))
			While FR6->(!EOF()) .And. FR6->(FR6_FILIAL+FR6_CODAPU) == xFilial("FR6") + cCodApu
				aTit := {}
				AADD(aTit , {"E2_NUM"    ,Padr(FR6->FR6_NUM,nLenTit)		,NIL})
				AADD(aTit , {"E2_PREFIXO",Padr(FR6->FR6_PREFIX,nLenPref)	,NIL})
				AADD(aTit , {"E2_PARCELA",Padr(FR6->FR6_PARC,nLenPar)		,NIL})
				AADD(aTit , {"E2_TIPO"   ,Padr(FR6->FR6_TIPO,nLenTipo)		,NIL})
				AADD(aTit , {"E2_FORNECE",Padr(FR6->FR6_FORNEC,nLenFor)		,NIL})
				AADD(aTit , {"E2_LOJA"   ,Padr(FR6->FR6_LOJA,nLenLoj)		,NIL})
								
				MSExecAuto({|x,y,z| FINA050(x,y,z)}, aTit,5,5)
								
				If  lMsErroAuto
					MOSTRAERRO()
					DisarmTransaction()
					lRet := .F.
					Exit
				Else
					RecLock("FR6",.F.)
					dbDelete()
					MsUnLock()
				EndIf
				FR6->(dbSkip())
			EndDo
		Endif
		
		
		If lRet		
			FR4->(dbSeek(xFilial("FR4") + cCodApu))
			RecLock("FR4",.F.)
			FR4->FR4_STATUS	:= '2'
			MsUnLock()
		EndIf
	END TRANSACTION
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FI960PrTit
Realiza o processamento da geração de título de imposto

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Function FI960PrTit(cCodApu)
Local lRet			:= .T.
Local dDataEm		:= CTOD("")
Local cPrefix		:= ""
Local cNumTit		:= ""
Local cCond			:= ""
Local cCodRet		:= ""
Local cFornec		:= ""
Local cLoja			:= ""
Local cParc			:= ""	
Local cNatureza		:= ""
Local nValorTot		:= 0
Local aParc			:= {}
Local cTipo			:= ""
Local nX			:= 0
Local aTit			:= {}
Local aTitFR6		:= {}
Local cRotina		:= "FINA960"
Local nLenTit 		:= TamSx3("E2_NUM")[1]
Local nLenPar		:= TamSx3("E2_PARCELA")[1]
Local nLenFor 		:= TamSx3("E2_FORNECE")[1]
Local nLenLoj 		:= TamSx3("E2_LOJA")[1]
Local nLenNat 		:= TamSx3("E2_NATUREZ")[1]
Local nLenIt  		:= TamSx3("FR6_ITEM")[1]
Local cItem			:= ""
Local lF960TIT		:= ExistBlock( "FI960TIT" )
Local aTitAux		:= {}
Local nY			:= 0

Private lMsHelpAuto := .T. 
Private lMsErroAuto := .F. 

FR4->(dbSetOrder(1)) //FR4_FILIAL + FR4_CODAPU

Fi960Forn()

If FR4->(dbSeek(xFilial("FR4") + cCodApu))
	dDataEm			:= FR4->FR4_EMISSA
	cPrefix			:= FR4->FR4_PREFIX
	cNumTit			:= FR4->FR4_NUM
	cCond			:= FR4->FR4_COND
	cCodRet			:= FR4->FR4_CODRET
	cFornec			:= PadR(GetMV("MV_UNIAO"),nLenFor)
	cLoja			:= PadR( "00", nLenLoj , "0" )
	cParc			:= PadR( "00", nLenPar , "0" )
	cNatureza		:= IIF(FR4->FR4_TIPAPU == '1',GetMv("MV_FINNIR"),GetMv("MV_FINNCS") )
	nValorTot		:= IIF(FR4->FR4_TIPAPU == '1',FR4->FR4_IRPAG,FR4->FR4_CSLP )
	aParc			:= Condicao(nValorTot,FR4->FR4_COND,,dDataEm)
	cTipo			:= "TX"
Else
	lRet := .F.
EndIf


If lRet
	BEGIN TRANSACTION
		For nX := 1 to Len(aParc)
			aTit := {}
			cParc := Soma1(cParc)
			
			AADD(aTit , {"E2_NUM"    ,Padr(cNumTit,nLenTit)				,NIL})
			AADD(aTit , {"E2_PREFIXO",cPrefix							,NIL})
			AADD(aTit , {"E2_PARCELA",Padr(cParc,nLenPar)				,NIL})
			AADD(aTit , {"E2_TIPO"   ,cTipo								,NIL})
			AADD(aTit , {"E2_NATUREZ",cNatureza							,NIL})
			AADD(aTit , {"E2_FORNECE",cFornec							,NIL})
			AADD(aTit , {"E2_LOJA"   ,cLoja								,NIL})
			AADD(aTit , {"E2_EMISSAO",dDataEm							,NIL})
			AADD(aTit , {"E2_VENCTO" ,aParc[nX][1]						,NIL})
			AADD(aTit , {"E2_VENCREA",DataValida(aParc[nX][1] ,.T.)		,NIL})
			AADD(aTit , {"E2_VENCORI",DataValida(aParc[nX][1] ,.T.)		,NIL})
			AADD(aTit , {"E2_VALOR"  ,aParc[nX][2]						,NIL})
			AADD(aTit , {"E2_EMIS1"  ,dDataEm							,NIL})
			AADD(aTit , {"E2_VLCRUZ" ,aParc[nX][2]						,NIL})
			AADD(aTit , {"E2_MOEDA"  ,1									,NIL})
			AADD(aTit , {"E2_ORIGEM" ,cRotina                   	    ,NIL})
			AADD(aTit , {"E2_CODRET" ,cCodRet                  	        ,NIL})
			
			If lF960TIT
				aTitAux := ExecBlock("FI960TIT",.F.,.F.)
				If Valtype(aTitAux) == "A"
					For nY:= 1 to Len(aTitAux)
						AADD(aTit , aTitAux[nY] )
					Next nY
				EndIf
			EndIf
			
			//3 = Inclusao
			MSExecAuto({|x, y| FINA050(x, y)}, aTit, 3)
			
			If  lMsErroAuto
				MOSTRAERRO()
				DisarmTransaction()
				lRet := .F.
				Exit
			Else
				aAdd(aTitFR6,{xFilial("SE2"), cPrefix ,cNumTit,cParc,cTipo,cFornec,cLoja,dDataEm,aParc[nX][1],aParc[nX][2] })
			EndIf
		Next nX
		
		If lRet
			For nX:= 1 to Len(aTitFR6)
				cItem := StrZero(nX, nLenIt)
				RecLock("FR6",.T.)
				FR6_FILIAL		:= xFilial("FR6")
				FR6_CODAPU		:= cCodApu
				FR6_ITEM		:= cItem
				FR6_FILTIT  	:= aTitFR6[nX][1]
				FR6_PREFIX   	:= aTitFR6[nX][2]
				FR6_NUM		:= aTitFR6[nX][3]
				FR6_PARC		:= aTitFR6[nX][4]
				FR6_TIPO		:= aTitFR6[nX][5]
				FR6_FORNEC		:= aTitFR6[nX][6]
				FR6_LOJA		:= aTitFR6[nX][7]
				FR6_EMISSA		:= aTitFR6[nX][8]
				FR6_VENCTO		:= aTitFR6[nX][9]
				FR6_VALOR		:= aTitFR6[nX][10]
				
				MsUnLock()
			Next nX
			
			FR4->(dbSeek(xFilial("FR4") + cCodApu))
			RecLock("FR4",.F.)
			FR4->FR4_STATUS	:= '3'
			MsUnLock()
			
		EndIf
	END TRANSACTION
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Fi960Forn
Realiza a criação do fornecedor União caso não exista

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function Fi960Forn()
Local aArea := GetArea()
Local cLojaImp := PadR( "00", TamSx3("E2_LOJA")[1] , "0" )

DbSelectArea("SA2")
DbSetOrder(1)
If !DbSeek(xFilial("SA2")+GetMv("MV_UNIAO")+Space(Len(A2_COD)-Len(GetMv("MV_UNIAO")))+cLojaImp)
	Reclock("SA2",.T.)
	SA2->A2_FILIAL	:= xFilial("SA2")
	SA2->A2_COD		:= GetMv("MV_UNIAO")
	SA2->A2_LOJA	:= cLojaImp
	SA2->A2_NOME	:= "UNIAO"
	SA2->A2_NREDUZ	:= "UNIAO"
	SA2->A2_BAIRRO	:= "."
	SA2->A2_MUN		:= "."
	SA2->A2_EST 	:= SuperGetMv("MV_ESTADO")
	SA2->A2_END		:= "."
	SA2->A2_TIPO	:= "."
	MsUnlock()
	FkCommit()
EndIf
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FI960PrApu
Realiza o processamento da apuração de IRPJ/CSLL

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FI960PrApu(cCodApu,aSelFil,lImpAntLP,dDataLP)
Local lRet			:= .T.
Local dDataIni	:= CTOD("")
Local dDataFim	:= CTOD("")
Local cTipMov		:= ""
Local cLivRc		:= ""
Local cLivAdi		:= ""
Local cLivExc		:= ""
Local cLivComp	:= ""
Local cLivDed		:= ""
Local nResCTB		:= 0
Local nAdicao		:= 0
Local nExclusao	:= 0
Local nCompensa	:= 0
Local nDeducao	:= 0
Local nBAComp		:= 0
Local nResTrib	:= 0
Local nQuantMes	:= 0
Local nAliNor		:= 0
Local nAliAdi		:= 0
Local nPIsenta	:= 0
Local nIRNormal	:= 0
Local nBaseAdi	:= 0
Local nIRAdic		:= 0
Local nIRTotal	:= 0
Local nIRPagar	:= 0
Local nAliCSSL	:= 0
Local nCSLLTot	:= 0
Local nCSLLPag	:= 0		

Local cTipImp		:= ""

Default aSelFil	:= { cFilAnt }
Default lImpAntLP	:= .F.
Default dDataLP	:= CTOD("")

FR4->(dbSetOrder(1)) //FR4_FILIAL + FR4_CODAPU

If FR4->(dbSeek(xFilial("FR4") + cCodApu))
	cLivRc			:= FR4->FR4_LIVRES
	cLivAdi		:= FR4->FR4_LIVADI
	cLivExc		:= FR4->FR4_LIVEXC
	cLivComp		:= FR4->FR4_LIVCOM
	cLivDed		:= FR4->FR4_LIVDED
	dDataIni		:= FR4->FR4_DTINI
	dDataFim		:= FR4->FR4_DTFIM
	cTipMov		:= FR4->FR4_TPVAL
	cTipImp		:= FR4->FR4_TIPAPU
Else
	lRet := .F.
EndIf

If lRet
	
	FIN960FIL(cCodApu,aSelFil)
	
	// Recuperação do Resultado Contábil
	FIN960Comp(cCodApu,cLivRc,dDataIni,dDataFim,'1',cTipMov,aSelFil,lImpAntLP,dDataLP)
	
	// Recuperação das adições
	FIN960Comp(cCodApu,cLivAdi,dDataIni,dDataFim,'2',cTipMov,aSelFil,lImpAntLP,dDataLP)
	
	// Recuperação das exclusões
	FIN960Comp(cCodApu,cLivExc,dDataIni,dDataFim,'3',cTipMov,aSelFil,lImpAntLP,dDataLP)
	
	// Recuperação das compensações
	FIN960Comp(cCodApu,cLivComp,dDataIni,dDataFim,'4',cTipMov,aSelFil,lImpAntLP,dDataLP)
	
	// Recuperação das deduções
	FIN960Comp(cCodApu,cLivDed,dDataIni,dDataFim,'5',cTipMov,aSelFil,lImpAntLP,dDataLP)
	
	nResCTB			:= F960Tot(cCodApu	,'1') //Resultado Contábil
	nAdicao			:= F960Tot(cCodApu	,'2') //Adições
	nExclusao		:= F960Tot(cCodApu	,'3') //Exclusões
	nCompensa		:= F960Tot(cCodApu	,'4') //Compensações
	nDeducao		:= F960Tot(cCodApu	,'5') //Deduções
	nBAComp			:= nResCTB + nAdicao - nExclusao  //Base de Cálculo antes da Compensação
	nResTrib		:= nBAComp - nCompensa // Resultado Tributável
	nQuantMes		:= F960QtMes(dDataIni,dDataFim)
	
	If cTipImp == '1' //IRPJ
		nAliNor		:= SuperGetMv("MV_FINAIRN",.F.,15)					// Aliquota IRPJ Normal
		nAliAdi		:= SuperGetMv("MV_FINAIRA",.F.,10)					// Aliquota IRPJ Normal
		nPIsenta	:= SuperGetMv("MV_FINPIR",.F.,20000) * nQuantMes	// Parcela Isenta
		If nResTrib > 0
			nIRNormal	:= nResTrib * (nAliNor/100)			// IR Normal
			nBaseAdi	:= nResTrib - nPIsenta				// Base IR Adicional
			nBaseAdi	:= If( nBaseAdi < 0, 0, nBaseAdi )	// Se negativar zera o valor base adicional
			nIRAdic		:= nBaseAdi * (nAliAdi/100)			// IR Adicional
			nIRTotal	:= nIRNormal + nIRAdic				// IR Total
			nIRPagar	:= nIRTotal - nDeducao				// IR a Pagar
		EndIf
	ElseIf cTipImp == '2' //CSLL
		nAliCSSL	:= SuperGetMv("MV_FINACS",.F.,9)  // Aliquota CSLL Normal
		If nResTrib > 0
			nCSLLTot	:= nResTrib * (nAliCSSL/100) // CSLL Total
			nCSLLPag	:= nCSLLTot - nDeducao // CSLL Pagar
		EndIf
	EndIf
	
	RecLock("FR4",.F.)
		FR4->FR4_QTMES	:= nQuantMes
		FR4->FR4_RESCTB	:= nResCTB
		FR4->FR4_ADICAO	:= nAdicao
		FR4->FR4_EXCLUS	:= nExclusao
		FR4->FR4_BACOMP	:= nBAComp
		FR4->FR4_COMP	:= nCompensa
		FR4->FR4_RECTRI	:= nResTrib
		FR4->FR4_DEDUC	:= nDeducao
		FR4->FR4_IRNORM	:= nIRNormal
		FR4->FR4_ALINOR	:= nAliNor
		FR4->FR4_PISENT	:= nPIsenta
		FR4->FR4_ALIADI	:= nAliAdi
		FR4->FR4_BASADI	:= nBaseAdi
		FR4->FR4_IRADIC	:= nIRAdic
		FR4->FR4_IRTOT	:= nIRTotal
		FR4->FR4_IRPAG	:= nIRPagar
		FR4->FR4_ALICSL	:= nAliCSSL
		FR4->FR4_CSLL	:= nCSLLTot
		FR4->FR4_CSLP	:= nCSLLPag
		FR4->FR4_STATUS	:= '2'
	MsUnLock()
EndIf



Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F960QtMes
Retorna a quantidade de meses entre duas datas. Essa quantidade é independente do dia.
Exemplo 31/01/14 - 01/02/14 = 2 meses.

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function F960QtMes(dDataIni,dDataFim)
Local nMes		:= 0
Local dData		:= Lastday(dDataIni)
Local dDataF	:= Lastday(dDataFim)


While dData <= dDataF
	nMes++
	dData := Lastday(dData+1)
EndDo 

Return nMes 


//-------------------------------------------------------------------
/*/{Protheus.doc} F960Tot
Retorna o total do componente.

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Static Function F960Tot(cCodApu,cTipo)
Local nTotal		:= 0
Local nCred		:= 0
Local nDeb			:= 0
Local nValor		:= 0 
Local cQuery		:= ""
Local cTRB			:= GetNextAlias()

cQuery += " SELECT " + CRLF 
cQuery += "     SUM(FR5_VALOR) FR5_VALOR, " + CRLF 
cQuery += "     FR5_DC  " + CRLF 
cQuery += " FROM "+RetSqlName("FR5") + CRLF 
cQuery += " WHERE " + CRLF 
cQuery += "     FR5_FILIAL = '"+xFilial("FR5")+"' AND " + CRLF 
cQuery += "     FR5_CODAPU = '"+cCodApu+"' AND " + CRLF 
cQuery += "     FR5_TIPO   = '"+cTipo+"' AND " + CRLF 
cQuery += "     D_E_L_E_T_ = ' '  " + CRLF 

If cTipo == '1'
	cQuery += "     AND FR5_TOTVIS = '1' " + CRLF
EndIf 

cQuery += " GROUP BY FR5_DC " + CRLF 

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRB,.T.,.T.)

If (cTRB)->(!EOF())
	While (cTRB)->(!EOF()) 
		cDC		:= (cTRB)->FR5_DC
		nValor := (cTRB)->FR5_VALOR
		
		If cTipo == '1' // Resultado Contábil
			nTotal := IIF( cDC == '1' , -(nValor),nValor)
		Else
			If cDC == '1' // Debito
				nDeb	:= nValor
			Else //Crédito
				nCred	:= nValor
			EndIf
		EndIf
		(cTRB)->(dbSkip())
	EndDo
	
	If cTipo == '2' //Adição
		nTotal := nDeb - nCred
	ElseIf cTipo == '3' //Exclusão
		nTotal := nCred - nDeb
	ElseIf cTipo == '4' //Compensação
		nTotal := nDeb - nCred
	ElseIf cTipo == '5' //Dedução
		nTotal := nDeb - nCred
	EndIf
EndIf

(cTRB)->(dbCloseArea())

Return nTotal

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN960Comp
Realiza o processamento da apuração de IRPJ/CSLL

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function FIN960Comp(cCodApu,cLivro,dDataIni,dDataFim,cTipo,cTpValor,aSelFil,lImpAntLP,dDataLP)
Local aSetOfBook	:= CTBSetOf(cLivro)
Local aArea			:= GetArea()
Local cArqTmp	
Local lEnd		
Local cItem			:= "0000"	
Local nValor		:= 0

//Exclui os movimentos gerados pelo sistema do componente e reorganiza a numeração.
FR5->(dbSetOrder(1))//FR5_FILIAL+FR5_CODAPU+FR5_TIPO+FR5_ITEM+FR5_ENTID
If FR5->(MsSeek(xFilial("FR5")+cCodApu+cTipo))
	While FR5->(!EOF()) .AND. FR5->(FR5_FILIAL+FR5_CODAPU+FR5_TIPO) == xFilial("FR5")+cCodApu+cTipo
		If FR5->FR5_TPREG == '1'
			RecLock("FR5",.F.)
			dbDelete()
			MsUnLock()
		EndIf
		FR5->(dbSkip())
	EndDo
EndIf

If FR5->(MsSeek(xFilial("FR5")+cCodApu+cTipo))
	While FR5->(!EOF()) .AND. FR5->(FR5_FILIAL+FR5_CODAPU+FR5_TIPO) == xFilial("FR5")+cCodApu+cTipo
		cItem := Soma1(cItem)
		RecLock("FR5",.F.)
		FR5->FR5_ITEM := cItem
		MsUnLock()
		FR5->(dbSkip())
	EndDo
EndIf

If !Empty(cLivro)
	CTGerPlan(	Nil, Nil, Nil, @lEnd,@cArqTmp,;
		dDataIni,dDataFim,"","","",Repl("Z", Len(CT1->CT1_CONTA)),;
		"",Repl("Z", Len(CTT->CTT_CUSTO)),"",Repl("Z", Len(CTD->CTD_ITEM)),;
		"",Repl("Z", Len(CTH->CTH_CLVL)),"01",	'1',aSetOfBook, Space(2);
		, Space(20), Repl("Z", 20), Space(30),,,,, lImpAntLP, dDataLP;
		, ,.F.,,,,,,,,,,,,,,,,,,,,,,,,,,,aSelFil)
	DbSelectArea("cArqTmp")
	
	While cArqTmp->(!EOF())
		If cArqTmp->TIPOCONTA == '2'
			cItem := Soma1(cItem)
			RecLock("FR5",.T.)
			FR5->FR5_FILIAL	:= xFilial("FR5")
			FR5->FR5_CODAPU	:= cCodApu
			FR5->FR5_TIPO		:= cTipo
			FR5->FR5_ITEM		:= cItem
			FR5->FR5_ENTID	:= cArqTmp->CONTA
			FR5->FR5_DESC		:= cArqTmp->DESCCTA
			If cTpValor == '1' //Movimento do Periodo
				nValor :=  cArqTmp->MOVIMENTO
			Else // Saldo Acumulado
				nValor := cArqTmp->SALDOATU
			EndIf
			
			FR5->FR5_VALOR	:= Abs(nValor)
			FR5->FR5_DC		:= IIf( nValor > 0,'2','1')
			FR5->FR5_TPREG	:= '1'
			
			If cTipo == '1'
				FR5->FR5_TOTVIS	:= cArqTmp->TOTVIS
			EndIf
			
			MsUnLock()
		EndIf
		cArqTmp->(dbSkip())
	EndDo
	
	cArqTmp->(dbCloseArea())
	CTBGerClean()
EndIf



RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} F960ValLiv
Validação dos campos de livros contábeis.

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function F960ValLiv(lResCTB)
Local lRet 		:= .T.
Local cLivro		:= &(ReadVar())
Local aSetOfBook	:= {}
Local aArea		:= GetArea()
Local cVisao		:= ""
Local cQuery		:= ""
Local cTrb			:= GetNextAlias()

CTN->(dbSetOrder(1))//CTN_FILIAL+CTN_CODIGO
CTS->(dbSetOrder(1))//CTS_FILIAL+CTS_CODPLA+CTS_ORDEM+CTS_LINHA

If !Empty(cLivro)
	If CTN->(dbSeek(xFilial("CTN") + cLivro))
		aSetOfBook	:= CTBSetOf(cLivro)
		cVisao		:= aSetOfBook[5]
		If CTS->(dbSeek(xFilial("CTS") + cVisao ))
			If lResCTB
				cQuery += " SELECT " + CRLF
				cQuery += " COUNT(*) CONTVIS " + CRLF
				cQuery += " FROM " + RetSqlName("CTS") + CRLF
				cQuery += " WHERE " + CRLF
				cQuery += " CTS_FILIAL = '"+xFilial("CTS")+"' AND " + CRLF
				cQuery += " CTS_CODPLA = '"+cVisao+"' AND " + CRLF
				cQuery += " D_E_L_E_T_ = ' ' AND " + CRLF
				cQuery += " CTS_TOTVIS = '1' " + CRLF
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRB,.T.,.T.)
				
				If (cTRB)->(EOF()) .Or. (cTRB)->CONTVIS <= 0
					Help("  ",1,"FI960LIV1",,STR0031 ,1,0)//"A visão gerencial utilizada para o resultado contábil deve ter uma entidade como Resultado da Visão"
					lRet := .F.
				EndIf
				
				(cTRB)->(dbCloseArea())
			EndIf
		Else
			Help("  ",1,"FI960LIV2",,STR0032 ,1,0)//"Livro contábil não possui visão gerencial válida"
			lRet := .F.
		EndIf
	Else
		Help("  ",1,"FI960LIV3",,STR0033 ,1,0)//"Livro contábil não encontrado"
		lRet := .F.
	EndIf
EndIf




RestArea(aArea)
Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc}FINA960CTB
Contabilização da apuração.

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FINA960CTB()

FI960CTB(1)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}FI960ESEST
Estorno da contabilização da apuração.

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Function FI960ESEST()

FI960CTB(2)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}FI960CTB
Processamento da contabilização da apuração.

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------

Static Function FI960CTB(nOpc)
Local aArea			:= GetArea()
Local cPerg			:= "FINA960C"
Local lMostra   	:= .F.
Local lAglutina 	:= .F.
Local cApuraIni  	:= ""
Local cApuraFim  	:= ""
Local lRet			:= .T.
Local lSelecao		:= .F.
Local cMsg			:= ""

Default nOpc		:= 1

If lRet
	If Pergunte( cPerg , .T. )	
		lMostra    := MV_PAR01 == 1
		lAglutina  := MV_PAR02 == 1
		cApuraIni  := MV_PAR03
		cApuraFim  := MV_PAR04

		If nOpc == 1 //Contabilização
			cMsg := STR0050 //"Processando contabilização das apurações"
		Else
			cMsg := STR0051//"Processando estorno da contabilização das apurações"
		EndIf
		
		MsgRun( cMsg ,, {|| lRet := FI960CtbMv(nOpc,lMostra,lAglutina,cApuraIni,cApuraFim) } )
	EndIf

EndIf

If !lRet
	Help(" ",1,"FI960CTB",,STR0055 ,1,0)//"Nenhum registro foi contabilizado, verifique seleção ou lançamentos padrão"
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}FI960CtbMv
Processamento da contabilização da apuração.

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Function FI960CtbMv(nOpc,lMostra,lAglutina,cApuraIni,cApuraFim) 
Local lUsaFlag 	:= GetMV( "MV_CTBFLAG" ,, .F.)
Local aArea		:= GetArea()
Local cPadCab	:= ""
Local cPadItem	:= ""
Local aFlagCTB	:= {}
Local cFlag		:= ""
Local cLote		:= LoteCont("FIN")
Local cRotina	:= "FINA960"
Local cArquivo	:= ""
Local nHdlPrv	:= 0
Local nTotal 	:= 0
Local lPadCab	:= .F.
Local lPadItem	:= .F.
Local cFlagCom	:= ""
Local cStatus	:= ""
Local cStaComp	:= ""

If nOpc == 1
	cPadCab		:= "5C4"
	cPadItem	:= "5C5"
	cFlag		:= "S"
	cFlagCom	:= " N"
	cStatus		:= "4"
	cStaComp	:= "3"
Else
	cPadCab		:= "5C6"
	cPadItem	:= "5C7"
	cFlag		:= "N"
	cFlagCom	:= "S"
	cStatus		:= "3"
	cStaComp	:= "4"
EndIf

lPadCab		:= VerPadrao(cPadCab)
lPadItem	:= VerPadrao(cPadItem)

FR4->(dbSetOrder(1)) //FR4_FILIAL + FR4_CODAPU
FR5->(dbSetOrder(1))//FR5_FILIAL+FR5_CODAPU+FR5_TIPO+FR5_ITEM+FR5_ENTID

FR4->(dbSeek(xFilial("FR4") + cApuraIni , .T. ))

If lPadCab .Or. lPadItem
	nHdlPrv := HeadProva(cLote,cRotina,Substr(cUsername,1,6),@cArquivo)
EndIf

While FR4->(!EOF()) .And. FR4->(FR4_FILIAL + FR4_CODAPU) <= xFilial("FR4") + cApuraFim
	
	If FR4->FR4_STATUS == cStaComp
		//Contabilização do cabeçalho
		If nHdlPrv > 0 .And. lPadCab  .And. FR4->FR4_LA $ cFlagCom
			
			If lUsaFlag
				aAdd(aFlagCTB,{"FR4_LA",cFlag,"FR4",FR4->(Recno()),0,0,0})
			Else
				RecLock("FR4",.F.)
				FR4->FR4_LA := cFlag
				MsUnLock()
			EndIf
			
			nTotal += DetProva(nHdlPrv,cPadCab,cRotina,cLote,,,,,,,,@aFlagCTB)
			
		Endif
		
		If FR5->(dbSeek( FR4->(FR4_FILIAL + FR4_CODAPU) ) )
			While FR5->(!EOF()) .And. FR5->(FR5_FILIAL + FR5_CODAPU) == FR4->(FR4_FILIAL + FR4_CODAPU)
				
				//Contabilização do Item
				If nHdlPrv > 0 .And. lPadItem  .And. FR5->FR5_LA $ cFlagCom
					
					If lUsaFlag
						aAdd(aFlagCTB,{"FR5_LA",cFlag,"FR5",FR5->(Recno()),0,0,0})
					Else
						RecLock("FR5",.F.)
						FR5->FR5_LA := cFlag
						MsUnLock()
					EndIf
					
					nTotal += DetProva(nHdlPrv,cPadItem,cRotina,cLote,,,,,,,,@aFlagCTB)
					
				Endif
				
				FR5->(dbSkip())
			EndDo
			
		EndIf
		If nHdlPrv > 0 .And. nTotal > 0
			RecLock("FR4",.F.)
			FR4->FR4_STATUS := cStatus
			MsUnLock()
		EndIf
		
	EndIf
	
	FR4->(dbSkip())
EndDo

If nHdlPrv > 0 .And. nTotal > 0
	RodaProva(nHdlPrv, nTotal)
	cA100Incl(cArquivo,nHdlPrv,3,cLote,lMostra,lAglutina,,,, @aFlagCTB )	
Endif



RestArea(aArea)
Return (!Empty(nTotal)) 

//-------------------------------------------------------------------
/*/{Protheus.doc}FIN960FIL
Grava a tabela de filiais da entidade

@author Alvaro Camillo Neto
@since   19/09/2014

/*/
//-------------------------------------------------------------------
Static Function FIN960FIL(cCodApu,aSelFil)
Local nX	:= 0
Local nTam	:= TamSX3("FR7_ITEM")[1]
Local aFil	:= {}
//Exclui as filiais da apuração
FR7->(dbSetOrder(1))//FR7_FILIAL+FR7_CODAPU+FR7_ITEM
If FR7->(MsSeek(xFilial("FR7")+cCodApu))
	While FR7->(!EOF()) .AND. FR7->(FR7_FILIAL+FR7_CODAPU) == xFilial("FR7")+cCodApu
		
		RecLock("FR7",.F.)
		dbDelete()
		MsUnLock()
		
		FR7->(dbSkip())
	EndDo
EndIf

For nX:= 1 to Len(aSelFil)
	aFil := FWArrFilAtu(cEmpAnt,aSelFil[nX])
	RecLock("FR7",.T.)
	FR7->FR7_FILIAL	:= xFilial("FR7")
	FR7->FR7_CODAPU	:= cCodApu
	FR7->FR7_ITEM		:= STRZERO(nX,nTam)
	FR7->FR7_GRUEMP	:= cEmpAnt
	FR7->FR7_GRUDES	:= aFil[6]
	FR7->FR7_FILTIT	:= aFil[2]
	FR7->FR7_FILDES	:= aFil[7]
	FR7->FR7_CNPJ		:= aFil[18]
	MsUnLock()
Next nX


Return


