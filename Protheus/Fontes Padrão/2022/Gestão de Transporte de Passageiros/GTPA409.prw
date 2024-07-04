#include "GTPA409.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE MAXGETDAD 99999

Static oTblEscala
Static oTblRodagem
Static oTblViagens

Static aMinMaxDia	:= {}
Static aCboxDia		:= {}
Static lEmulaOracle	:= .F.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA409
Alocação de Veículos V 2.0
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 2.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function GTPA409()
Local lOk		:= .T.

Local cEscala	:= ""
Local dDtIni	:= StoD('')
Local dDtFim	:= StoD('')

Local cMsgError	:= ''
Local cMsgSoluc	:= '' 
Local cTitulo	:= ''

IF Pergunte("GTPA409",.T.)
	dDtIni	:= MV_PAR01
	dDtFim	:= MV_PAR02
	cEscala	:= Padr( MV_PAR03 ,TamSx3('G52_CODIGO')[1])
	
	G52->(DbSetOrder(1))
	If Empty(dDtIni) .or. Empty(dDtFim) 
		lOk := .F.
		cMsgError	:= STR0053//'Data Inicial ou Final não podem estar vazias'
		cMsgSoluc	:= STR0054//'Preencha a Data Inicial e Final' 
		cTitulo		:= 'GTPA409_DtVazia'
	ElseIf dDtIni > dDtFim
		lOk := .F.
		cMsgError	:= STR0055//'Data Inicial não pode ser maior que a Data Final'
		cMsgSoluc	:= STR0056//'Informe uma data inicial menor que a data final' 
		cTitulo		:= 'GTPA409_DtMaior'

	ElseIf !G52->(DbSeek(xFilial("G52")+ cEscala ))
		lOk := .F.
		cMsgError	:= STR0057//'Código da Escala informada não encontrada'
		cMsgSoluc	:= STR0058//'Utilize uma escala existente' 
		cTitulo		:= 'GTPA409_EscalaInvalida'
	
	Endif

	FwMsgRun( , {|oMessage| lRet := CriaTabelas(oMessage,cEscala,dDtIni,dDtFim)}, STR0059 , STR0060 )//"Criando tabelas temporarias"#"Aguarde..."

	
	If lOk
		FWExecView( STR0001 , "VIEWDEF.GTPA409", MODEL_OPERATION_UPDATE, /*oDlg*/, {|| .T. })//"Alocação de Veículos"	
	Else
		FwAlertHelp(cMsgError, cMsgSoluc,cTitulo)
	Endif
	
	GA409Destroy()		

EndIF

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabelas
(long_description)
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 1.0
@param oMessage, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function CriaTabelas(oMessage,cEscala,dDtIni,dDtFim)
Local lRet	:= .T.
	
	oMessage:SetText(STR0061)//"Criando Tabela de Escala..."	 
	ProcessMessages()
	GetTableEscala(cEscala)	//oTblEscala	:= GetTableEscala(cEscala)
	
	aMinMaxDia	:= GetMinMaxDia()
	aCboxDia	:= GetCboxDia(aMinMaxDia)
	
	oMessage:SetText(STR0062)//"Criando Tabela de Rodagem..." 
	ProcessMessages()
	GetTableRodagem(cEscala,dDtIni,dDtFim)	//oTblRodagem := GetTableRodagem(cEscala,dDtIni,dDtFim)
	
	oMessage:SetText(STR0063)//"Buscando Viagens..."	 
	ProcessMessages()
	GetTableViagem()	//oTblViagens	:= GetTableViagem()
	
		
Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} GA409Destroy
(long_description)
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Function GA409Destroy()

// If ( ValType(oTblEscala) == "O" )
// 	oTblEscala:Delete()
// EndIf

// If ( ValType(oTblRodagem) == "O" )
// 	oTblRodagem:Delete()
// EndIf	

// If ( ValType(oTblViagens) == "O" )
// 	oTblViagens:Delete()
// EndIf


// GTPDestroy(oTblEscala)
// GTPDestroy(oTblRodagem)
// GTPDestroy(oTblViagens)
GTPDestroy(aMinMaxDia)
GTPDestroy(aCboxDia)

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author jacomo.fernandes
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel   	:= Nil
	
	Local oStruG52 	:= FWFormStruct(1,"G52",{ |cCampo| Alltrim(cCampo)+'|' $ 'G52_CODIGO|G52_DESCRI|'})
	Local oStruGQA  := FWFormStruct(1,"GQA")
	Local oStruGYN  := FWFormStruct(1,"GYN",{ |cCampo| Alltrim(cCampo)+'|' $	'GYN_FILIAL|GYN_CODIGO|GYN_LINCOD|GYN_DTINI|GYN_HRINI|GYN_DTFIM|'+;
																				'GYN_HRFIM|GYN_LOCORI|GYN_LOCDES|GYN_KMPROV|GYN_CODGID|GYN_NUMSRV|'})
	Local oStruTot 	:= FWFormModelStruct():New()
	
	Local bPosValid	:= {|oModel| TPA409TdOk(oModel)}
	Local bCommit	:= {|oModel| TPA409Commit(oModel)}
	
	
	SetModelStruct(oStruG52,oStruGQA,oStruGYN,oStruTot)
	
	oModel := MPFormModel():New('GTPA409',/*bPreValid*/, bPosValid ,)

	oModel:SetCommit(bCommit)
	oModel:SetDescription(STR0001)	//'Alocação de Veículos'
	
	oModel:AddFields("G52MASTER",, oStruG52)//,/*bPre */, /*bPost*/ , /*bLoad*/ )
	oModel:AddGrid("GQADETAIL", "G52MASTER",oStruGQA, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, {|oSubMdl| GA409Load(oSubMdl)} )
	oModel:AddGrid("GYNDETAIL", "GQADETAIL",oStruGYN, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, {|oSubMdl| GA409Load(oSubMdl)} )
	oModel:AddFields("TOTALIZA","GQADETAIL",oStruTot,/*bPre */, /*bPost*/ , {|oSubMdl| GA409Load(oSubMdl)} )
	
	oModel:GetModel( "G52MASTER" ):SetOnlyView(.t.)
	
	oModel:GetModel( "GQADETAIL" ):SetOnlyQuery(.t.)
	oModel:GetModel( "GYNDETAIL" ):SetOnlyQuery(.t.)
	
	oModel:GetModel( "GQADETAIL" ):SetOptional( .T. )
	oModel:GetModel( "GYNDETAIL" ):SetOptional( .T. )
	
	oModel:SetRelation("GQADETAIL",{ {"GQA_FILIAL","xFilial('GQA')"},{"GQA_CODESC","G52_CODIGO"}},GQA->(IndexKey(1)))
	oModel:SetRelation("GYNDETAIL",{ {"GYN_SEQALO","GQA_SEQALO"}},"GYN_CODIGO")
	oModel:SetRelation("TOTALIZA",{ {"TOT_VEIC","GQA_CODVEI"}},"GQA_CODVEI")
	
	oModel:GetModel('GQADETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GQADETAIL'):SetNoDeleteLine(.T.)
	
	oModel:GetModel('GYNDETAIL'):SetNoInsertLine(.T.)
	oModel:GetModel('GYNDETAIL'):SetNoDeleteLine(.T.)
	
	oModel:GetModel("G52MASTER"):SetPrimaryKey({})
	
	//Define o numero maximo de linhas, de acordo com a define MAXGETDAD
	oModel:GetModel( 'GYNDETAIL' ):SetMaxLine(MAXGETDAD)
	
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'G52MASTER' ):SetDescription( STR0008 )
	oModel:GetModel( 'GQADETAIL' ):SetDescription( STR0009 )
	oModel:GetModel( 'GYNDETAIL' ):SetDescription( STR0010 )
	oModel:GetModel( 'TOTALIZA' ):SetDescription( STR0064 )//"Totalizador"
	
Return oModel
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetModelStruct
(long_description)
@type function
@author jacomo.fernandes
@since 03/05/2019
@version 1.0
@param oStruG52, objeto, (Descrição do parâmetro)
@param oStruGQA, objeto, (Descrição do parâmetro)
@param oStruGYN, objeto, (Descrição do parâmetro)
@param oStruTot, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetModelStruct(oStruG52,oStruGQA,oStruGYN,oStruTot)
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|GTPA409Vld(oMdl,cField,cNewValue,cOldValue) }
Local bTrig		:= {|oMdl,cField,xVal|GTPA409TRG(oMdl,cField,xVal)}

If ValType(oStruGQA) == "O"
	//Definições da estrutura do model GQADETAIL
	oStruGQA:SetProperty('*'         ,MODEL_FIELD_WHEN	,{|| .F. } )
	oStruGQA:SetProperty('*'         ,MODEL_FIELD_INIT	,{||})
	oStruGQA:SetProperty('*'         ,MODEL_FIELD_VALID	,{|| .T.})
	
	oStruGQA:AddField(""     ,""     ,"GQA_MARK"  ,"L",01,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)
	oStruGQA:AddField(STR0034,STR0034,"GQA_HODOME","N",15,8,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)//"Hodômetro"
	oStruGQA:AddField(STR0019,STR0019,"GQA_KMMAN" ,"N",15,8,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)//"Limite KM Manutenção"
	oStruGQA:AddField(STR0032,STR0032,"GQA_SEQALO","C",02,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)//"Seq. Alocação"
	
	oStruGQA:SetProperty('*'			,MODEL_FIELD_VALID	,{|| .T.})
	
	oStruGQA:SetProperty("GQA_SEQALO"	,MODEL_FIELD_VALUES,aCboxDia)
	
	oStruGQA:AddTrigger("GQA_MARK"		,"GQA_MARK"			,{||.T.},bTrig)
	oStruGQA:AddTrigger("GQA_SEQALO"	,"GQA_SEQALO"		,{||.T.},bTrig)
	
	oStruGQA:SetProperty("GQA_MARK"		,MODEL_FIELD_VALID	,bFldVld)
	oStruGQA:SetProperty("GQA_SEQALO"	,MODEL_FIELD_VALID	,bFldVld)
	
Endif

If ValType(oStruGYN) == "O"
	
	oStruGYN:AddField(""     ,""     ,"GYN_LEGEND",'BT',01                         ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
	oStruGYN:AddField(""     ,""     ,"GYN_MARK"  ,"L",01                          ,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)
	oStruGYN:AddField(STR0032,STR0032,"GYN_ITEM"  ,"C",04                          ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Seq. Alocação"
	oStruGYN:AddField(""     ,""     ,"GYN_SEQALO","C",02                          ,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)
	oStruGYN:AddField(STR0020,STR0021,"GYN_VEIC"  ,"C",TamSx3("T9_CODBEM")[1]      ,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)//Veiculo
	oStruGYN:AddField(STR0025,STR0025,"GYN_PMANUT","C",01                          ,0,Nil,Nil,Nil,.F.,Nil,.F.,.F.,.T.)//"Ponto de Parada"//"1=Sim"#"2=Não"
	oStruGYN:AddField(STR0030,STR0030,"GYN_ORIDES","C",(TamSx3("GI1_DESCRI")[1]*2)+3,0,NIL,NIL,Nil,.F.,NIL,.F.,.F.,.T.) //"Origem/Destino"
	oStruGYN:AddField(STR0065,STR0065,"GYN_HRSDGR","C",TamSx3("GYN_HRINI")[1]      ,0,NIL,NIL,Nil,.F.,NIL,.F.,.F.,.T.) //"Saida Gar"
	oStruGYN:AddField(STR0066,STR0066,"GYN_HRCHGR","C",TamSx3("GYN_HRINI")[1]      ,0,NIL,NIL,Nil,.F.,NIL,.F.,.F.,.T.) //"Chega Gar"
	oStruGYN:AddField(STR0067,STR0067,"ROD_RECNO","N",8      ,0,NIL,NIL,Nil,.F.,NIL,.F.,.F.,.T.) //"Rod. Recno"
	oStruGYN:AddField(STR0068,STR0068,"GYN_SEC","C",1      ,0,NIL,NIL,Nil,.F.,NIL,.F.,.F.,.T.) //"Seccion."
	oStruGYN:AddField(STR0069,STR0069,"GYN_SEQSER","C",TamSx3("GZQ_SEQSER")[1]      ,0,NIL,NIL,Nil,.F.,NIL,.F.,.F.,.T.) //"Seq Serv"
	
	oStruGYN:SetProperty('*'			,MODEL_FIELD_WHEN	, {|| .F. } )
	oStruGYN:SetProperty('GYN_MARK'		,MODEL_FIELD_WHEN	, {|| .T. } )
	oStruGYN:SetProperty('GYN_SEQALO'	,MODEL_FIELD_WHEN	, {|| .T. } )
	oStruGYN:SetProperty('GYN_VEIC'		,MODEL_FIELD_WHEN	, {|| .T. } )
	oStruGYN:SetProperty('GYN_LEGEND'	,MODEL_FIELD_WHEN	, {|| .T. } )
	
	oStruGYN:SetProperty("*"			,MODEL_FIELD_OBRIGAT, .F. )
	
	oStruGYN:AddTrigger("GYN_MARK"	,"GYN_MARK"		,{||.T.},bTrig)
	
	oStruGYN:SetProperty("GYN_PMANUT", MODEL_FIELD_VALUES,{STR0026,STR0027} )//"1=Sim"#"2=Não"
	
Endif

If ValType(oStruTot) == "O"
	oStruTot:AddTable("ZZZ",{},STR0070)//"Totalizadores"
	
	oStruTot:AddField(STR0020,STR0020,"TOT_VEIC"  ,"C",TamSx3("GQA_CODVEI")[1],0,{||.T.},{||.T.},{},.F.,Nil,.F.,.F.,.T.)//"Veículo"
	oStruTot:AddField(STR0034,STR0035,"TOT_HODOME","N",12                     ,0,{||.T.},{||.T.},{},.F.,Nil,.F.,.F.,.T.)//"Hodômetro"
	oStruTot:AddField(""     ,""     ,"TOT_KMVIAG","N",06                     ,0,{||.T.},{||.T.},{},.F.,Nil,.F.,.F.,.T.)//"Km Total Viagem"
	oStruTot:AddField(STR0036,STR0036,"TOT_KMTOT" ,"N",12                     ,0,{||.T.},{||.T.},{},.F.,Nil,.F.,.F.,.T.)//"KM Total Planejado"
	oStruTot:AddField(STR0071,STR0071,"TOT_KMVMAX","N",12                     ,0,{||.T.},{||.T.},{},.F.,Nil,.F.,.F.,.T.)//"KM máximo à realizar"

Endif

Return 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author jacomo.fernandes
@since 04/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel 	:= FWLoadModel('GTPA409' )
	Local oStruG52 	:= FWFormStruct(2,"G52",{ |cCampo| Alltrim(cCampo)+'|' $ 'G52_CODIGO|G52_DESCRI|'})
	Local oStruGQA  := FWFormStruct(2,"GQA",{ |cCampo| Alltrim(cCampo)+'|' $ 'GQA_CODVEI|GQA_DESVEI|'})
	Local oStruGYN  := FWFormStruct(2,"GYN",{ |cCampo| Alltrim(cCampo)+'|' $ 'GYN_FILIAL|GYN_CODIGO|GYN_LINCOD|GYN_DTINI|GYN_HRINI|GYN_DTFIM|GYN_HRFIM|GYN_LOCORI|GYN_LOCDES|GYN_KMPROV|GYN_CODGID|GYN_NUMSRV|'})
	Local oStruTot 	:= FWFormViewStruct():New()
	
	SetViewStruct(oStruG52,oStruGQA,oStruGYN,oStruTot)
	
	oView := FWFormView():New()
	
	oView:SetModel(oModel)
	
	oView:AddField('VW_G52MASTER'	, oStruG52	,'G52MASTER')
	oView:AddGrid('VW_GQADETAIL'	, oStruGQA	,'GQADETAIL')
	oView:AddGrid('VW_GYNDETAIL'	, oStruGYN	,'GYNDETAIL')
	oView:AddField('VW_GYNTOT' 		, oStruTot	,'TOTALIZA')
	
	oView:CreateHorizontalBox('SUPERIOR'	, 15)
	oView:CreateHorizontalBox('MEIO'		, 20)
	oView:CreateHorizontalBox('INFERIOR'	, 50)
	oView:CreateHorizontalBox('TOTAL'		, 15)
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0001 )//'Alocação de Veículos'

	oView:SetOwnerView('VW_G52MASTER'	 ,'SUPERIOR')
	oView:SetOwnerView('VW_GQADETAIL'	 ,'MEIO')
	oView:SetOwnerView('VW_GYNDETAIL'	 ,'INFERIOR')
	oView:SetOwnerView('VW_GYNTOT'	 	 ,'TOTAL')
	
	oView:AddIncrementField( 'VW_GYNDETAIL', 'GYN_ITEM' )
	
	oView:EnableTitleView('VW_G52MASTER' , STR0008 )
	oView:EnableTitleView('VW_GQADETAIL' , STR0009 )
	oView:EnableTitleView('VW_GYNDETAIL' , STR0010 )
	oView:EnableTitleView('VW_GYNTOT' 	 , STR0011 )
	
	oView:GetViewObj("GYNDETAIL")[3]:SetFilter(.t.)
	
	oView:AddUserButton(STR0017, 'PRINT', {|oView| GA409PrintViag(oView) } )	//"Imprimir Viagens Listadas"
	oView:AddUserButton(STR0072,"", {|oView| Gtpa409Leg() })//Legenda
	
	oView:SetViewProperty("VW_GYNDETAIL", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| Ga409DbClk(oGrid,cField,nLineGrid,nLineModel)}})
	
Return oView

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetViewStruct
(long_description)
@type function
@author jacomo.fernandes
@since 03/05/2019
@version 1.0
@param oStruG52, objeto, (Descrição do parâmetro)
@param oStruGQA, objeto, (Descrição do parâmetro)
@param oStruGYN, objeto, (Descrição do parâmetro)
@param oStruTot, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetViewStruct(oStruG52,oStruGQA,oStruGYN,oStruTot)

If ValType(oStruG52) == 'O'

Endif

If ValType(oStruGQA) == 'O'
	oStruGQA:AddField("GQA_MARK" 	,"01",""     ,STR0018,{STR0018},"CHECK","@!"                ,Nil,"",.T., Nil, Nil, Nil, Nil, Nil, .T.)//"Seleciona"
	
	oStruGQA:AddField("GQA_HODOME"	,"04",STR0034,STR0034,{STR0034},"GET"  ,"@E 999,999,999,999",Nil,"",.T., Nil, Nil, Nil, Nil, Nil, .T.)//"Hodômetro"
	oStruGQA:AddField("GQA_KMMAN"	,"05",STR0019,STR0019,{STR0019},"GET"  ,"@E 999,999,999,999",Nil,"",.T., Nil, Nil, Nil, Nil, Nil, .T.)//"Limite KM Manutenção"
	oStruGQA:AddField("GQA_SEQALO"	,"06",STR0032,STR0032,{STR0032},"COMBO"  ,"@!",Nil,"",.T., Nil, Nil, Nil, Nil, Nil, .T.)//"Seq. Alocação"

	oStruGQA:SetProperty('GQA_MARK'		, MVC_VIEW_ORDEM,'01')
	oStruGQA:SetProperty('GQA_CODVEI'	, MVC_VIEW_ORDEM,'02')
	oStruGQA:SetProperty('GQA_DESVEI'	, MVC_VIEW_ORDEM,'03')
	oStruGQA:SetProperty('GQA_HODOME'	, MVC_VIEW_ORDEM,'04')
	oStruGQA:SetProperty('GQA_KMMAN'	, MVC_VIEW_ORDEM,'05')
	oStruGQA:SetProperty('GQA_SEQALO'	, MVC_VIEW_ORDEM,'06')
	
	oStruGQA:SetProperty("GQA_SEQALO"	, MVC_VIEW_COMBOBOX,aCboxDia)
Endif

If ValType(oStruGYN) == 'O'
	oStruGYN:AddField("GYN_LEGEND","01",""     ,""      ,NIL,"BT"   ,""  ,Nil,"",.F., NIL, Nil, Nil, Nil, Nil, .T.)//Legenda
	oStruGYN:AddField("GYN_MARK"  ,"01",""     ,""      ,Nil,"CHECK","@!",Nil,"",.T., Nil, Nil, Nil, Nil, Nil, .T.)//"Seleciona"
	oStruGYN:AddField("GYN_ITEM"  ,"02",STR0032,STR0032 ,Nil,"GET"  ,"@!",Nil,"",.T., Nil, Nil, Nil, Nil, Nil, .T.)//"Seq. Alocação"
	oStruGYN:AddField("GYN_VEIC"  ,"03",STR0020,STR0021 ,Nil,"GET"  ,"@!",Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"Veículo"##"Veículo Selecionado"
	oStruGYN:AddField("GYN_ORIDES","04",STR0030,STR0030 ,Nil,"GET"  ,"@!",Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"Origem/Destino"
	oStruGYN:AddField("GYN_PMANUT","99",STR0025,STR0025 ,Nil,"COMBO","@!",Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"Ponto de Parada"
	
	oStruGYN:AddField("GYN_HRSDGR","04",STR0065,STR0065 ,Nil,"GET"  ,"@R 99:99",Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"Origem/Destino"
	oStruGYN:AddField("GYN_HRCHGR","04",STR0066,STR0066 ,Nil,"GET"  ,"@R 99:99",Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"Origem/Destino"
	
	oStruGYN:SetProperty("GYN_PMANUT", MVC_VIEW_COMBOBOX,{STR0026,STR0027} )//"1=Sim"#"2=Não"
	
	oStruGYN:SetProperty('GYN_LEGEND', MVC_VIEW_ORDEM,'00')
	oStruGYN:SetProperty('GYN_MARK'  , MVC_VIEW_ORDEM,'01')
	oStruGYN:SetProperty('GYN_ITEM'  , MVC_VIEW_ORDEM,'02')
	oStruGYN:SetProperty('GYN_VEIC'  , MVC_VIEW_ORDEM,'03')
	oStruGYN:SetProperty('GYN_NUMSRV', MVC_VIEW_ORDEM,'04')
	oStruGYN:SetProperty('GYN_ORIDES', MVC_VIEW_ORDEM,'05')
	oStruGYN:SetProperty('GYN_DTINI' , MVC_VIEW_ORDEM,'06')
	oStruGYN:SetProperty('GYN_HRSDGR', MVC_VIEW_ORDEM,'07')
	oStruGYN:SetProperty('GYN_HRINI' , MVC_VIEW_ORDEM,'08')
	oStruGYN:SetProperty('GYN_DTFIM' , MVC_VIEW_ORDEM,'09')
	oStruGYN:SetProperty('GYN_HRFIM' , MVC_VIEW_ORDEM,'10')
	oStruGYN:SetProperty('GYN_HRCHGR', MVC_VIEW_ORDEM,'11')
	oStruGYN:SetProperty('GYN_KMPROV', MVC_VIEW_ORDEM,'12')
	oStruGYN:SetProperty('GYN_PMANUT', MVC_VIEW_ORDEM,'13')
	oStruGYN:SetProperty('GYN_LOCORI', MVC_VIEW_ORDEM,'14')
	oStruGYN:SetProperty('GYN_LOCDES', MVC_VIEW_ORDEM,'15')
	oStruGYN:SetProperty('GYN_LINCOD', MVC_VIEW_ORDEM,'16')
	oStruGYN:SetProperty('GYN_CODGID', MVC_VIEW_ORDEM,'17')
	oStruGYN:SetProperty('GYN_CODIGO', MVC_VIEW_ORDEM,'18')
	
Endif

If ValType(oStruTot) == 'O'
		
	oStruTot:AddField("TOT_HODOME","01",STR0038,STR0038 ,Nil,"GET","@E 999,999"			,Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"Hodômetro Atual"
	oStruTot:AddField("TOT_KMVIAG","02",STR0037,STR0037 ,Nil,"GET","@E 999,999,999,999" ,Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"Total KM Viagem"
	oStruTot:AddField("TOT_KMTOT" ,"03",STR0036,STR0036 ,Nil,"GET","@E 999,999,999,999" ,Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"KM Total Planejado"
	oStruTot:AddField("TOT_KMVMAX","04",STR0071,STR0071 ,Nil,"GET","@E 999,999,999,999"	,Nil,"",.F., Nil, Nil, Nil, Nil, Nil, .T.)//"KM máximo à realizar"

Endif

Return 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GA409Load
(long_description)
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 1.0
@param oSubMdl, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GA409Load(oSubMdl)
Local aRet			:= {}
Local cMdlId		:= oSubMdl:GetId()
Local cTmpAlias		:= GetNextAlias()
Local cTblViagens	:= "%" + oTblViagens:GetRealName() + "%"
Local cFields		:= "" 
Local cEscala		:= oSubMdl:GetModel():GetModel('G52MASTER'):GetValue('G52_CODIGO')
Local cCodVeic		:= ""
Local cSeqAloc		:= ""
Local cTpSrvMnt		:= GtpGetRules('TPSRVMNT', .F., , "REV")

If cMdlId == "GQADETAIL"
	
	BeginSql Alias cTmpAlias
		COLUMN GQA_MARK AS Logical
		SELECT
			GQA.GQA_FILIAL,
			GQA.GQA_CODESC,
			GQA.GQA_CODVEI,
			ST9.T9_NOME  GQA_DESVEI,
			(CASE
				WHEN SEQALOC.GYN_SEQALO IS NOT NULL THEN 'T'
				ELSE 'F'
			END)  GQA_MARK,
			ST9.T9_POSCONT  GQA_HODOME,
			(TF_CONMANU + TF_INENMAN )  GQA_KMMAN,
			Coalesce(SEQALOC.GYN_SEQALO,'00')  GQA_SEQALO
		FROM %Table:GQA% GQA
			LEFT JOIN %Table:ST9% ST9 ON 
				ST9.T9_FILIAL = %xFilial:ST9%
				AND ST9.T9_CODBEM = GQA.GQA_CODVEI
				AND ST9.%NotDel%
			LEFT JOIN %Table:STF% STF ON 
				STF.TF_FILIAL = %xFilial:STF%
				AND STF.TF_CODBEM = GQA.GQA_CODVEI
				AND STF.TF_SERVICO = %Exp:cTpSrvMnt%
				AND STF.TF_ATIVO IN ('S', ' ')
				AND STF.%NotDel%
			LEFT JOIN (SELECT
							GYN_VEIC,
							GYN_SEQALO,
							COUNT(*) TOTAL,
							DENSE_RANK() OVER (PARTITION BY GYN_VEIC ORDER BY COUNT(*) DESC) RANK
						FROM %Exp:cTblViagens%
						WHERE 
							GYN_VEIC <> ' '
						GROUP BY GYN_VEIC, GYN_SEQALO
				)  SEQALOC ON 
					SEQALOC.GYN_VEIC = GQA.GQA_CODVEI
					AND SEQALOC.RANK = 1
		WHERE 
			GQA_FILIAL = %xFilial:GQA%
			AND GQA_CODESC = %Exp:cEscala%
			AND GQA.%NotDel%	
	
	EndSql
	
ElseIf cMdlId == "GYNDETAIL"
	
	cTmpAlias	:= GetNextAlias()
	cSeqAloc	:= oSubMdl:GetModel():GetModel('GQADETAIL'):GetValue('GQA_SEQALO')
	cCodVeic	:= oSubMdl:GetModel():GetModel('GQADETAIL'):GetValue('GQA_CODVEI')
	
	cFields		:= "%" + GTPFld2Str(oSubMdl:GetStruct(),.F.) + "%" 
	cFields		:= StrTran(cFields,"GYN_MARK","(Case GYN_VEIC WHEN '"+cCodVeic+"' THEN 'T' ELSE 'F' END) AS GYN_MARK")
	cFields		:= StrTran(cFields,"GYN_LEGEND", "(Case "+; 
														"when GYN_LEGEND = 'BR_VERMELHO' OR GYN_LEGEND = 'BR_CINZA' THEN GYN_LEGEND "+; 
														"WHEN GYN_VEIC  = '"+cCodVeic+"' THEN 'BR_VERDE' "+;
														"WHEN GYN_VEIC <> '"+Space(TamSx3('GQE_RECURS')[1])+"' THEN 'BR_LARANJA' "+;
														"ELSE 'BR_AMARELO' "+; 
													"END) AS GYN_LEGEND" )
	
	BeginSql Alias cTmpAlias
		COLUMN GYN_DTINI AS DATE
		COLUMN GYN_DTFIM AS DATE
		COLUMN GYN_MARK AS LOGICAL	
		
		SELECT %Exp:cFields%
		FROM %Exp:cTblViagens%
		WHERE 
			GYN_SEQALO = %Exp:cSeqAloc%
	EndSql
ElseIf cMdlId == 'TOTALIZA'
		
	cSeqAloc := oSubMdl:GetModel():GetModel('GQADETAIL'):GetValue('GQA_SEQALO')
	cCodVeic := oSubMdl:GetModel():GetModel('GQADETAIL'):GetValue('GQA_CODVEI')

	BeginSql Alias cTmpAlias
		
		SELECT 
			TOT_VEIC,
			TOT_HODOME,
			TOT_KMVIAG,
			TOT_HODOME+TOT_KMVIAG TOT_KMTOT,
			LIMITEKM-(TOT_HODOME+TOT_KMVIAG) TOT_KMVMAX
		FROM(
			SELECT 
				GQA_CODVEI TOT_VEIC, 
				ST9.T9_POSCONT TOT_HODOME,
				Coalesce((select SUM(GYN_KMPROV) 
					from %Exp:cTblViagens%
					where
						GYN_VEIC = GQA.GQA_CODVEI
						AND GYN_SEQALO = %Exp:cSeqAloc%
						AND GYN_MARK = 'T'
				),0) TOT_KMVIAG,
				TF_CONMANU+TF_INENMAN LIMITEKM
			FROM %Table:GQA% GQA
				LEFT JOIN %Table:ST9% ST9 ON 
					ST9.T9_FILIAL = %xFilial:ST9%
					AND ST9.T9_CODBEM = GQA.GQA_CODVEI
					AND ST9.%NotDel%
				LEFT JOIN %Table:STF% STF ON 
					STF.TF_FILIAL = %xFilial:STF%
					AND STF.TF_CODBEM = GQA.GQA_CODVEI
					AND STF.TF_SERVICO = %Exp:cTpSrvMnt%
					AND STF.TF_ATIVO IN ('S', ' ')
					AND STF.%NotDel%
			WHERE
				GQA.GQA_FILIAL = %xFilial:GQA%
				AND GQA.GQA_CODESC = %Exp:cEscala%
				AND GQA.GQA_CODVEI = %Exp:cCodVeic%
				AND GQA.%NotDel%
		) T

	EndSql

Endif

aRet := FWLoadByAlias(oSubMdl, cTmpAlias)

(cTmpAlias)->(DbCloseArea())

Return(aRet)

//------------------------------------------------------------------------------
/*/{Protheus.doc} GA409PrintViag()
                                   
Executa a impressão do Grid de Viagens.

@example 	GA409PrintViag(oView)

@param		oView	Objeto. Instância da Classe FwFormView

@return     Nil

@author     Fernando Radu Muscalu
@since      02/02/2018
@version    12                
/*/
//------------------------------------------------------------------------------
Static Function GA409PrintViag(oView)

Local nLine 	:= oView:GetModel("GYNDETAIL"):GetLine()
Local oModel	:= oView:GetModel()
Local aReportFld:= GTPxFldRpt(oView:GetViewStruct('VW_GYNDETAIL'),'GYNDETAIL',/*aNoFld*/)
Local oReport	:= oModel:ReportDef(,,aReportFld)

oReport:PrintDialog()

oView:GetModel("GYNDETAIL"):GoLine(nLine) 

Return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTableEscala
(long_description)
@type function
@author jacomo.fernandes
@since 04/05/2019
@version 1.0
@param cEscala, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetTableEscala(cEscala)
Local cQuery	:= ""
Local aFlds		:= {'G52_CODIGO','G52_NUMSRV','G52_SERVIC','G52_LINHA','G52_DIA','G52_SEQUEN',;
					'G52_LOCORI','G52_DESORI','G52_LOCDST','G52_DESDES','G52_HRSDGR','G52_HRSDRD',;
					'G52_HRCHRD','G52_HRCHGR','G52_HRGRIN','G52_HRGRFI','G52_DIAPAR','G52_SEGUND',;
					'G52_TERCA','G52_QUARTA','G52_QUINTA','G52_SEXTA','G52_SABADO','G52_DOMING',;
					'G52_PMANUT','G52_SEC','GZQ_SEQSER'}
Local aTmpFld	:= {}
Local cFields	:= GTPxAr2Txt(aFlds,',')

If ( ValType(oTblEscala) <> "O" )
	
	aTmpFld	:= GTPXTmpFld(aFlds)

	ChangeArrTmpFld(aTmpFld,"G52_DESORI",3,TamSx3('GI1_DESCRI')[1])
	ChangeArrTmpFld(aTmpFld,"G52_DESDES",3,TamSx3('GI1_DESCRI')[1])

	oTblEscala := FWTemporaryTable():New(GetNextAlias())
	oTblEscala:SetFields(aTmpFld)
	oTblEscala:AddIndex("IDX",{"G52_CODIGO","G52_SEQUEN" } )
	oTblEscala:Create()

Else
	TcSqlExec('TRUNCATE TABLE '+ oTblEscala:GetRealName())
EndIf

cFields := StrTran(cFields,"G52_LOCORI","(Case G52_SEC WHEN '1' THEN GIE_IDLOCP ELSE GI2.GI2_LOCINI END) AS G52_LOCORI")
cFields := StrTran(cFields,"G52_LOCDST","(Case G52_SEC WHEN '1' THEN GIE_IDLOCD ELSE GI2.GI2_LOCFIM END) AS G52_LOCDST")
cFields := StrTran(cFields,"G52_DESORI","GI1ORI.GI1_DESCRI AS G52_DESORI")
cFields := StrTran(cFields,"G52_DESDES","GI1DES.GI1_DESCRI AS G52_DESDES")
cFields := StrTran(cFields,"GZQ_SEQSER","Coalesce(GZQ_SEQSER,'"+Space(TamSx3('GZQ_SEQSER')[1])+"') as GZQ_SEQSER")

cQuery	+= "Select "
cQuery	+= "	" + cFields + " "
cQuery	+= "From "+RetSqlName("G52")+" G52 "
cQuery	+= "	LEFT JOIN "+RetSqlName("GZQ")+" GZQ ON "
cQuery	+= "		GZQ_FILIAL = G52.G52_FILIAL "
cQuery	+= "		AND GZQ_ESCALA = G52.G52_CODIGO "
cQuery	+= "		AND GZQ_SEQESC = G52.G52_SEQUEN "
cQuery	+= "		AND GZQ.D_E_L_E_T_ = ' ' "
cQuery	+= "	INNER JOIN "+RetSqlName("GI2")+" GI2 ON "
cQuery	+= "		GI2_FILIAL = '"+xFilial('GI2')+"' "
cQuery	+= "		AND GI2_COD = G52.G52_LINHA "
cQuery	+= "		AND GI2_HIST = '2' "
cQuery	+= "		AND GI2.D_E_L_E_T_ = ' ' "
cQuery	+= "	LEFT JOIN "+RetSqlName("GIE")+" GIE ON "
cQuery	+= "		GIE_FILIAL = GI2.GI2_FILIAL "
cQuery	+= "		AND GIE_CODGID = G52.G52_SERVIC "
cQuery	+= "		AND GIE_HIST = '2' "
cQuery	+= "		AND GIE.GIE_SEQ = GZQ.GZQ_SEQSER "
cQuery	+= "		AND GIE.D_E_L_E_T_ = ' ' "
cQuery	+= "	INNER JOIN "+RetSqlName("GI1")+" GI1ORI ON "
cQuery	+= "		GI1ORI.GI1_FILIAL = '"+xFilial('GI1')+"' "
cQuery	+= "		AND GI1ORI.GI1_COD = (Case G52_SEC  "
cQuery	+= "									WHEN '1'  "
cQuery	+= "										THEN GIE_IDLOCP "
cQuery	+= "									ELSE "
cQuery	+= "										GI2.GI2_LOCINI "
cQuery	+= "								END) "
cQuery	+= "		AND GI1ORI.D_E_L_E_T_ = ' ' "
cQuery	+= "	INNER JOIN "+RetSqlName("GI1")+" GI1DES ON "
cQuery	+= "		GI1DES.GI1_FILIAL = '"+xFilial('GI1')+"' "
cQuery	+= "		AND GI1DES.GI1_COD = (Case G52_SEC  "
cQuery	+= "									WHEN '1'  "
cQuery	+= "										THEN GIE_IDLOCD "
cQuery	+= "									ELSE "
cQuery	+= "										GI2.GI2_LOCFIM "
cQuery	+= "								END) "
cQuery	+= "		AND GI1DES.D_E_L_E_T_ = ' ' "

cQuery	+= "Where " 
cQuery	+= "	G52.G52_FILIAL = '"+xFilial('G52')+"' "
cQuery	+= "	AND G52_CODIGO = '"+cEscala+"' "
cQuery	+= "	and G52.D_E_L_E_T_ = ' '       "

cQuery := ChangeQuery(cQuery)

If 'ORACLE' $ Trim(TcGetDb()) .Or. lEmulaOracle
    oTblEscala:InsertSelect('('+cQuery+') ORDER BY G52_SEQUEN',aFlds)
Else
    oTblEscala:InsertSelect('('+cQuery+') t ORDER BY t.G52_SEQUEN',aFlds)
Endif

Return

/*/{Protheus.doc} TPA409Commit
(long_description)
@type function
@author henrique.toyada
@since 15/05/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TPA409Commit(oModel)

Local oMdlGQA := oModel:GetModel("GQADETAIL")
Local oMdlGYN := oModel:GetModel("GYNDETAIL")

Local oMdl300 := FwLoadModel("GTPA300")

Local lRet := .T.

Local nX := 0
Local nY := 0
Local nG55 := 0

Begin Transaction

DbSelectArea("GYN")
GYN->(DbSetOrder(1))

For nX := 1 To oMdlGQA:length()
	oMdlGQA:GoLine(nX)
	If oMdlGQA:GetValue("GQA_SEQALO",nX) != "00"
		For nY := 1 To oMdlGYN:length()
			If oMdlGYN:GetValue("GYN_VEIC",nY) == oMdlGQA:GetValue("GQA_CODVEI",nX) .OR. EMPTY(oMdlGYN:GetValue("GYN_VEIC",nY))
				If GYN->(DbSeek(xFilial("GYN") + oMdlGYN:GetValue("GYN_CODIGO",nY)))
					oMdl300:SetOperation(MODEL_OPERATION_UPDATE)
			
					INCLUI := .F.
					IF oMdl300:Activate()
						oGridG55 := oMdl300:GetModel("G55DETAIL")
						oGridGQE := oMdl300:GetModel("GQEDETAIL")
				
						For nG55 := 1 To oGridG55:Length()
							oGridG55:GoLine(nG55)
							If oMdlGYN:GetValue("GYN_SEC",nY) != "1"
								If !(oMdlGYN:GetValue("GYN_MARK",nY))
									IF oGridGQE:SeekLine({	{"GQE_TRECUR",'2'};
															,{"GQE_RECURS",oMdlGQA:GetValue("GQA_CODVEI",nX)}	})
										oGridGQE:DeleteLine()
									EndIf
								Else
									IF oGridGQE:SeekLine({	{"GQE_TRECUR",'2'}	})
										oGridGQE:SetValue("GQE_RECURS",oMdlGYN:GetValue("GYN_VEIC",nY)  )
									Else
									
										oGridGQE:AddLine()
										oGridGQE:LoadValue("GQE_TRECUR",'2')
										oGridGQE:LoadValue("GQE_RECURS",oMdlGYN:GetValue("GYN_VEIC",nY))
										
										If oGridGQE:Length() > 1
											oGridGQE:SetValue("GQE_ITEM"  ,Strzero(Val( oGridGQE:GetValue("GQE_ITEM",oGridGQE:Length() -1 ))+1 ,TamSx3("GQE_ITEM")[1]  ))
										Else
											oGridGQE:SetValue("GQE_ITEM"  ,'001'  )
										Endif
									
									EndIf
									
									oGridGQE:LoadValue("GQE_USRALO",cUserName)
									oGridGQE:LoadValue("GQE_DTALOC", FwTimeStamp(2))
									
					  			EndIf
							Else
								If !(oMdlGYN:GetValue("GYN_MARK",nY))
									IF oGridGQE:SeekLine({	{"GQE_TRECUR",'2'};
															,{"GQE_RECURS",oMdlGQA:GetValue("GQA_CODVEI",nX)};
															,{"GQE_SEQ",oMdlGYN:GetValue("GYN_SEQSER",nY)}	})
										oGridGQE:DeleteLine()
									EndIf
								Else
									IF oGridGQE:SeekLine({	{"GQE_TRECUR",'2'};
															,{"GQE_SEQ",oMdlGYN:GetValue("GYN_SEQSER",nY)}	})
										oGridGQE:SetValue("GQE_RECURS",oMdlGYN:GetValue("GYN_VEIC",nY)  )
									Else
									
										oGridGQE:AddLine()
										oGridGQE:LoadValue("GQE_TRECUR",'2')
										oGridGQE:LoadValue("GQE_RECURS",oMdlGYN:GetValue("GYN_VEIC",nY))
										oGridGQE:LoadValue("GQE_SEQ",   oMdlGYN:GetValue("GYN_SEQSER",nY))
										
										If oGridGQE:Length() > 1
											oGridGQE:SetValue("GQE_ITEM"  ,Strzero(Val( oGridGQE:GetValue("GQE_ITEM",oGridGQE:Length() -1 ))+1 ,TamSx3("GQE_ITEM")[1]  ))
										Else
											oGridGQE:SetValue("GQE_ITEM"  ,'001'  )
										Endif
									
									EndIf
									
									oGridGQE:LoadValue("GQE_USRALO",cUserName)
									oGridGQE:LoadValue("GQE_DTALOC", FwTimeStamp(2))
									
					  			EndIf
					  		EndIf
						Next nG55
			
						If oMdl300:VldData()
							oMdl300:CommitData()
						Else
							lRet := .F.
							DisarmTransaction()
						EndIf
						oMdl300:DeActivate()
					EndIf
			
				EndIf
			EndIf
		Next nY
	EndIf
Next nX

End Transaction

Return(lRet)

/*/{Protheus.doc} TPA409TdOk
(long_description)
@type function
@author henrique.toyada
@since 15/05/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function TPA409TdOk(oModel)

Local oModelGQA	:= oModel:GetModel("GQADETAIL")
Local oModelGYN	:= oModel:GetModel("GYNDETAIL")
Local oGTPLog	:= GTPLog():New(STR0073)//"Registros não processados - Alocação de veículos"
Local lRet		:= .T.
Local lMark     := .T.
Local cMsgErr1	:= ""
Local cMsgErr2	:= ""
Local nQA		:= 0
Local nYn		:= 0
Local nVig		:= 0

Local aViagem	:= {}

//Valida para que não possa ser selecionado o Mesmo Veiculo para Viagens Diferentes
For nQA :=1 To oModelGQA:Length()
	oModelGQA:GoLine(nQA)
	If !(oModelGQA:GetValue("GQA_MARK",nQA)) .AND. oModelGQA:GetValue("GQA_SEQALO",nQA) != "00"
		oGTPLog:SetText(I18N( STR0076,{oModelGQA:GetValue("GQA_CODVEI",nQA),oModelGQA:GetValue("GQA_DESVEI",nQA),oModelGQA:GetValue("GQA_SEQALO",nQA)}))//"Veiculo  #1 - #2 Seq. #3"
	EndIf
	If oModelGQA:GetValue("GQA_MARK",nQA) .AND. oModelGQA:GetValue("GQA_SEQALO",nQA) == "00"
		oGTPLog:SetText(I18N( STR0076,{oModelGQA:GetValue("GQA_CODVEI",nQA),oModelGQA:GetValue("GQA_DESVEI",nQA),oModelGQA:GetValue("GQA_SEQALO",nQA)}))//"Veiculo  #1 - #2 Seq. #3"
		lMark := .F.
		cMsgErr1	:= STR0074//"Viagens carregadas sem sequencia de alocação."
		cMsgErr2	:= STR0075//"Validar se existe veículo e viagem para ser marcada, se não fechar."
	EndIf
	If lMark
		For nYn :=1 To oModelGYN:Length()
			
			oModelGYN:GoLine(nYn)

			IF oModelGYN:GetValue("GYN_MARK",nYn)

				aAdd(aViagem,{	oModelGYN:GetValue("GYN_CODIGO"	,nYn),; //01 - Código da viagem
								oModelGYN:GetValue("GYN_VEIC"	,nYn),;	//02 - Id do Veículo
								oModelGYN:GetValue("GYN_DTINI"	,nYn),;	//03 - Data de início da viagem
								oModelGYN:GetValue("GYN_DTFIM"	,nYn),;	//04 - Data final da viagem
								oModelGYN:GetValue("GYN_HRINI"	,nYn),;	//05 - Hora inicial da viagem
								oModelGYN:GetValue("GYN_HRFIM"	,nYn),;	//06 - Hora final da viagem
								oModelGYN:GetValue("GYN_LINCOD"	,nYn)})	//07 - Identificador da Linha da viagem
			
			Else
				oGTPLog:SetText(I18N( STR0077,{oModelGYN:GetValue("GYN_CODIGO",nYn),oModelGYN:GetValue("GYN_DTINI",nYn),oModelGYN:GetValue("GYN_DTFIM",nYn)}))//"Viagem  #1 Data de #2 até #3"
			EndIf
			
		Next nYn
	EndIf
Next nQA

//Valida se o Veiculo Roda (Frequencia) nos dias em que será a Viagem.
IF lRet .AND. Len(aViagem) > 0

	For nVig:= 1 To Len(aViagem)
	
		//Valida se o Veiculo está disponivel e Apto para a Viagem.
		//Alterado por Fernando Radu em 01/08/2022 
		//- Ajuste efetuado para passar parâmetro aViagem[nVig][07] que é cLinha
		IF !GTP409ConfVei(aViagem[nVig][02],aViagem[nVig][03],aViagem[nVig][04],@cMsgErr1,aViagem[nVig][05],aViagem[nVig][06],aViagem[nVig][07],@cMsgErr2,.f.)
			lRet := .F.
			cMsgErr1	:= IIf(Empty(cMsgErr1),STR0006,cMsgErr1) //"O veículo não está apto para realizar viagem! "
			cMsgErr2	:= IIf(Empty(cMsgErr2),STR0007,cMsgErr2) //"Verificar se o veículo já está alocado ou se possuí problemas de manutenção ou documentação."
			Exit
		EndIf
	Next nVig
Else
	lRet := .F.
	cMsgErr1	:= STR0078//"Nenhuma viagem marcada."
	cMsgErr2	:= STR0079//"Validar se existe viagem marcada, se não fechar."
EndIf

If oGTPLog:HasInfo()
	oGTPLog:ShowLog()
Endif
		
oGTPLog:Destroy()
If !lRet .OR. !lMark
	Help("",1,"HELP",'TPA409TdOk',cMsgErr1,1,,,,,,,{cMsgErr2})
EndIf

Return( lRet )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTableRodagem
(long_description)
@type function
@author jacomo.fernandes
@since 05/05/2019
@version 1.0
@param cEscala, character, (Descrição do parâmetro)
@param dDtIni, data, (Descrição do parâmetro)
@param dDtFim, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetTableRodagem(cEscala,dDtIni,dDtFim)
Local aFldsRod  := {}
Local cFldsRod  := ""
Local cTmpEscala:= ""
Local nQtdVeic	:= GetQtdVeicEsc(cEscala)
Local nVeic		:= 0
Local dDtAux	:= dDtIni
Local cFldFreq	:= ""
Local nDiaEsc	:= 0 
Local cLocIni	:= ""
Local cHrSaiRdv	:= "" 
Local cHrChegRdv:= ""
Local cHrChegGrg:= ""
Local cHrSaiGrg	:= ""
Local nDiaBkp	:= 0
Local lReset	:= .F.

CriaTblRodagem(aFldsRod,@cFldsRod)
cTmpEscala:= oTblRodagem:GetAlias()

For nVeic := 1 To nQtdVeic 
	nDiaEsc		:= nVeic
	dDtAux		:= dDtIni
	cFldFreq	:= GtpxDoW(dDtAux,3,.T.) //Retorna SEG,TER,QUA,QUI,SEX,SAB,DOM
	nDiaBkp		:= nDiaEsc
	
	nRecno		:= GetFirstDay(nDiaEsc,dDtAux,dDtFim)
	
	While nRecno <> 0 .and. dDtAux <= dDtFim
		
		(cTmpEscala)->(DbGoTo(nRecno))
		
		SetRodagem(aFldsRod,cFldsRod,nRecno,dDtAux,nVeic)
		
		lReset		:= .F.
		nDiaBkp		:= nDiaEsc
		cLocIni		:= (cTmpEscala)->G52_LOCDST
		cHrSaiRdv	:= (cTmpEscala)->G52_HRSDRD
		cHrChegRdv	:= (cTmpEscala)->G52_HRCHRD
		cHrChegGrg	:= (cTmpEscala)->G52_HRCHGR
		cHrSaiGrg	:= (cTmpEscala)->G52_HRGRFI
		
		
		
		If (Val(cHrSaiRdv) > Val(cHrChegRdv) .Or. Val(cHrSaiRdv) > Val(cHrSaiGrg) .or. Val(cHrChegGrg) > Val(cHrSaiGrg))
			dDtAux++
			nDiaEsc := GetNextDiaEscala(@nDiaEsc)
		Endif
		
		If (cTmpEscala)->G52_DIAPAR > 0
			dDtAux	:= dDtAux+(cTmpEscala)->G52_DIAPAR
			//nDiaEsc := GetNextDiaEscala(nDiaEsc,@lReset) 
		Endif

		If !lReset .or. (lReset .and. nDiaEsc <= nDiaBkp .and. aMinMaxDia[1] <> aMinMaxDia[2])
			nRecno := GetNextEscala(@dDtAux,cLocIni,cHrSaiGrg,@nDiaEsc,nDiaBkp,@lReset)
		Endif

		If lReset .and. nRecno == 0 ;
            .and. !(Val(cHrSaiRdv) > Val(cHrChegRdv) .Or. Val(cHrSaiRdv) > Val(cHrSaiGrg) .or. Val(cHrChegGrg) > Val(cHrSaiGrg))
            
            lReset  := .F.
            dDtAux++
            nRecno := GetNextEscala(@dDtAux,cLocIni,cHrSaiGrg,@nDiaEsc,nDiaBkp,@lReset)
        Endif
	End

Next
Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTblRodagem
(long_description)
@type function
@author jacomo.fernandes
@since 05/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function CriaTblRodagem(aFlds,cFldsRod)

Local aTmpFld	:= {}

aFlds   := {'G52_CODIGO','G52_NUMSRV','G52_SERVIC','G52_LINHA','G52_DIA','G52_SEQUEN',;
            'G52_LOCORI','G52_DESORI','G52_LOCDST','G52_DESDES','G52_HRSDGR','G52_HRSDRD',;
            'G52_HRCHRD','G52_HRCHGR','G52_HRGRIN','G52_HRGRFI','G52_DIAPAR','G52_SEGUND',;
            'G52_TERCA','G52_QUARTA','G52_QUINTA','G52_SEXTA','G52_SABADO','G52_DOMING',;
            'G52_PMANUT','G52_SEC','GZQ_SEQSER','G52_SEQALO','GYN_DTINI'}

If ( ValType(oTblRodagem) <> "O" )
	
	oTblRodagem := FWTemporaryTable():New(GetNextAlias() )
	aTmpFld := GTPXTmpFld(aFlds)

	ChangeArrTmpFld(aTmpFld,"G52_DESORI",3,TamSx3('GI1_DESCRI')[1])
	ChangeArrTmpFld(aTmpFld,"G52_DESDES",3,TamSx3('GI1_DESCRI')[1])
	ChangeArrTmpFld(aTmpFld,"G52_SEQALO",3,2)

	cFldsRod := GTPxAr2Txt(aFlds,',')

	oTblRodagem:SetFields(aTmpFld)
	oTblRodagem:AddIndex("IDX02",{"G52_SEQALO",'GYN_DTINI','G52_HRSDGR' } )
	oTblRodagem:Create()

Else
	TcSqlExec('TRUNCATE TABLE '+ oTblRodagem:GetRealName())
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetTableViagem
(long_description)
@type function
@author jacomo.fernandes
@since 05/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetTableViagem()
Local cTblRodagem	:= oTblRodagem:GetRealName()
Local aFlds			:= {'GYN_FILIAL','GYN_CODIGO','GYN_LINCOD','GYN_DTINI','GYN_HRSDGR','GYN_HRINI','GYN_DTFIM',;
						'GYN_HRFIM','GYN_HRCHGR','GYN_LOCORI','GYN_LOCDES','GYN_KMPROV','GYN_CODGID','GYN_NUMSRV',;
						'GYN_SEQALO','GYN_VEIC','GYN_PMANUT','GYN_ORIDES','ROD_RECNO','GYN_MARK','GYN_ITEM','GYN_SEC','GYN_SEQSER','GYN_LEGEND'}
Local aTmpFld		:= {}
Local cQuery		:= ""

If ( ValType(oTblViagens) <> "O" )

	aTmpFld		:= GTPXTmpFld(aFlds)

	ChangeArrTmpFld(aTmpFld,"GYN_HRSDGR",3,4)
	ChangeArrTmpFld(aTmpFld,"GYN_HRCHGR",3,4)
	ChangeArrTmpFld(aTmpFld,"GYN_MARK",2,'L')
	ChangeArrTmpFld(aTmpFld,"GYN_ITEM",3,4)
	ChangeArrTmpFld(aTmpFld,"GYN_SEQALO",3,2)
	ChangeArrTmpFld(aTmpFld,"GYN_VEIC",3,TamSx3("T9_CODBEM")[1]  )
	ChangeArrTmpFld(aTmpFld,"GYN_ORIDES",3,(TamSx3("GI1_DESCRI")[1]*2)+3)
	ChangeArrTmpFld(aTmpFld,"ROD_RECNO",2,'N')
	ChangeArrTmpFld(aTmpFld,"ROD_RECNO",3,8)
	ChangeArrTmpFld(aTmpFld,"GYN_SEC",3,TamSx3("G52_SEC")[1])
	ChangeArrTmpFld(aTmpFld,"GYN_SEQSER",3,TamSx3("GZQ_SEQSER")[1])
	ChangeArrTmpFld(aTmpFld,"GYN_LEGEND",3,15)

	oTblViagens := FWTemporaryTable():New(GetNextAlias() )

	oTblViagens:SetFields(aTmpFld)
	oTblViagens:AddIndex("IDX",{"GYN_DTINI","GYN_HRSDGR" } )
	oTblViagens:Create()

Else
	TcSqlExec('TRUNCATE TABLE '+ oTblViagens:GetRealName())
EndIf

cQuery += "	SELECT "
cQuery += "		GYN_FILIAL,"
cQuery += "		GYN_CODIGO,"
cQuery += "		GYN_LINCOD,"
cQuery += "		GYN_DTINI,"
cQuery += "		GYN_HRSDGR,"
cQuery += "		GYN_HRINI,"
cQuery += "		GYN_DTFIM,"
cQuery += "		GYN_HRFIM,"
cQuery += "		GYN_HRCHGR,"
cQuery += "		GYN_LOCORI,"
cQuery += "		GYN_LOCDES,"
cQuery += "		GYN_KMPROV,"
cQuery += "		GYN_CODGID,"
cQuery += "		GYN_NUMSRV,"
cQuery += "		GYN_SEQALO,"
cQuery += "		GYN_VEIC,"
cQuery += "		GYN_PMANUT,"
cQuery += "		GYN_ORIDES,"
cQuery += "		ROD_RECNO,"
cQuery += "		GYN_MARK,"
cQuery += "		GYN_ITEM,"
cQuery += "		GYN_SEC,"
cQuery += "		GYN_SEQSER,"
cQuery += "		(Case "
cQuery += "			WHEN T.GYN_CODIGO = ' ' THEN 'BR_CINZA' "
cQuery += "			WHEN T.GYN_SEC  = '1' AND EXISTS( SELECT 1 " 
cQuery += "											FROM "+RetSqlName('GIE')+" GIE "
cQuery += "											WHERE  "
cQuery += "												GIE.GIE_FILIAL = T.GYN_FILIAL "
cQuery += "												AND GIE.GIE_CODGID = T.GYN_CODGID "
cQuery += "												AND GIE.GIE_SEQ = T.GYN_SEQSER "
cQuery += "												AND GIE.GIE_HIST = '2' "
cQuery += "												AND GIE.D_E_L_E_T_ = ' ' "
cQuery += "												AND (GIE_IDLOCP <> T.GYN_LOCORI "
cQuery += "													OR GIE.GIE_IDLOCD <> T.GYN_LOCDES "
cQuery += "													OR GIE_HORLOC <> T.GYN_HRINI "
cQuery += "													OR GIE_HORDES <> T.GYN_HRFIM "
cQuery += "												) "
cQuery += "											) "
cQuery += "				then 'BR_VERMELHO' "
cQuery += "			WHEN T.GYN_SEC  = '2' AND EXISTS( SELECT 1 " 
cQuery += "											FROM "+RetSqlName('GIE')+" GIE "
cQuery += "											WHERE  "
cQuery += "												GIE.GIE_FILIAL = T.GYN_FILIAL "
cQuery += "												AND GIE.GIE_CODGID = T.GYN_CODGID "
cQuery += "												AND GIE.GIE_HIST = '2' "
cQuery += "												AND GIE.D_E_L_E_T_ = ' ' "
cQuery += "												AND (	 "
cQuery += "													(GIE.GIE_SEQ = (SELECT " 
cQuery += "																		MIN(G55_SEQ) " 
cQuery += "																	FROM "+RetSqlName('G55')+" G55  "
cQuery += "																	WHERE " 
cQuery += "																		G55_FILIAL = T.GYN_FILIAL " 
cQuery += "																		AND G55_CODVIA = T.GYN_CODIGO " 
cQuery += "																		AND G55.D_E_L_E_T_ = ' ' "
cQuery += "																	) "
cQuery += "														AND (GIE_IDLOCP <> GYN_LOCORI OR GIE_HORLOC <> T.GYN_HRINI)) "
cQuery += "													OR (GIE.GIE_SEQ = (SELECT  "
cQuery += "																			MAX(G55_SEQ) " 
cQuery += "																		FROM "+RetSqlName('G55')+" G55  "
cQuery += "																		WHERE  "
cQuery += "																			G55_FILIAL = T.GYN_FILIAL " 
cQuery += "																			AND G55_CODVIA = T.GYN_CODIGO " 
cQuery += "																			AND G55.D_E_L_E_T_ = ' ') "
cQuery += "														AND (GIE_IDLOCD <> T.GYN_LOCDES OR GIE_HORDES <> T.GYN_HRFIM)) "
cQuery += "													) "
cQuery += "											) "
cQuery += "				then 'BR_VERMELHO' "				
cQuery += "			ELSE 'BR_AMARELO' "
cQuery += "		End) GYN_LEGEND "
cQuery += "	FROM ( "
cQuery += "		Select "
cQuery += "			'"+xFilial('GYN')+"' GYN_FILIAL, "
cQuery += "			Coalesce((CASE RODAGEM.G52_SEC WHEN '2' THEN GYN_CODIGO ELSE G55_CODVIA END),'"+Space(TamSx3('GYN_CODIGO')[1])+"') GYN_CODIGO, "
cQuery += "			G52_LINHA GYN_LINCOD, "
cQuery += "			GYN.GYN_DTINI  GYN_DTINI, "
cQuery += "			RODAGEM.G52_HRSDGR  GYN_HRSDGR, "
cQuery += "			RODAGEM.G52_HRSDRD  GYN_HRINI , "
cQuery += "			Coalesce((CASE G52_SEC WHEN '2' THEN GYN_DTFIM ELSE G55_DTCHEG END),'"+Space(TamSx3('GYN_DTFIM')[1])+"')  GYN_DTFIM , "
cQuery += "			Coalesce((CASE G52_SEC WHEN '2' THEN GYN_HRFIM ELSE G55_HRFIM END),'"+Space(TamSx3('GYN_HRFIM')[1])+"')  GYN_HRFIM , "
cQuery += "			RODAGEM.G52_HRCHGR  GYN_HRCHGR, "
cQuery += "			RODAGEM.G52_LOCORI  GYN_LOCORI, "
cQuery += "			RODAGEM.G52_LOCDST  GYN_LOCDES, "
cQuery += "			GYN.GYN_KMPROV  GYN_KMPROV, "
cQuery += "			RODAGEM.G52_SERVIC  GYN_CODGID, "
cQuery += "			RODAGEM.G52_NUMSRV  GYN_NUMSRV, "
cQuery += "			G52_SEQALO  GYN_SEQALO , "

cQuery += "			Coalesce( "
cQuery += "			    (SELECT "
cQuery += "			        GQE.GQE_RECURS "
cQuery += "			    FROM "+RetSqlName('GQE')+" GQE "
cQuery += "			        INNER JOIN (SELECT "
cQuery += "			                        GQE.GQE_FILIAL, "
cQuery += "			                        GQE.GQE_VIACOD, "
cQuery += "			                        MIN(GQE.GQE_SEQ) GQE_SEQ "
cQuery += "			                    FROM "+RetSqlName('GQE')+" GQE "
cQuery += "			                    WHERE  "
cQuery += "			                        GQE.GQE_FILIAL = '"+xFilial('GQE')+"' "
cQuery += "			                        AND GQE_VIACOD = (CASE RODAGEM.G52_SEC "
cQuery += "			                                            WHEN '2' THEN GYN_CODIGO "
cQuery += "			                                            ELSE G55_CODVIA "
cQuery += "			                                        END) "
cQuery += "			                        AND GQE_TRECUR = '2' "
cQuery += "			                        AND GQE.D_E_L_E_T_ = ' ' "
cQuery += "			                        AND 1 = (CASE RODAGEM.G52_SEC "
cQuery += "			                                    WHEN '2' THEN 1 "
cQuery += "			                                    ELSE (CASE "
cQuery += "			                                                WHEN GZQ_SEQSER = GQE_SEQ THEN 1 "
cQuery += "			                                                ELSE 0 "
cQuery += "			                                        END) "
cQuery += "			                                END) "
cQuery += "			                    GROUP BY GQE.GQE_FILIAL,GQE.GQE_VIACOD "
cQuery += "			        ) MINSEQ ON  "
cQuery += "			            GQE.GQE_FILIAL = MINSEQ.GQE_FILIAL "
cQuery += "			            AND GQE.GQE_VIACOD = MINSEQ.GQE_VIACOD "
cQuery += "			            AND GQE.GQE_SEQ = MINSEQ.GQE_SEQ "
cQuery += "			    WHERE 
cQuery += "			        GQE.GQE_FILIAL = '"+xFilial('GQE')+"' "
cQuery += "			        AND GQE.GQE_TRECUR = '2'"
cQuery += "			        AND GQE.D_E_L_E_T_ = ' '"
cQuery += "             ) "
cQuery += "			, ' ') GYN_VEIC, "

cQuery += "			RODAGEM.G52_PMANUT GYN_PMANUT, "
cQuery += "			RTRIM(RODAGEM.G52_DESORI)||' / '||RTRIM(RODAGEM.G52_DESDES) GYN_ORIDES, "
cQuery += "			RODAGEM.R_E_C_N_O_  ROD_RECNO, "
cQuery += "			'F'  GYN_MARK, "
cQuery += "			' '  GYN_ITEM, "
cQuery += "			RODAGEM.G52_SEC  GYN_SEC, "
cQuery += "			RODAGEM.GZQ_SEQSER  GYN_SEQSER "
cQuery += "		From "+cTblRodagem+"  RODAGEM "
cQuery += "			LEFT JOIN "+RetSqlName('GYN')+" GYN ON "
cQuery += "				GYN.GYN_FILIAL = '"+xFilial('GYN')+"' "
cQuery += "				AND RODAGEM.G52_SEC = '2' "
cQuery += "				AND GYN.GYN_DTINI BETWEEN " + DTOS(MV_PAR01) + " AND " + DTOS(MV_PAR02) + " "
cQuery += "				AND GYN.GYN_CODGID = RODAGEM.G52_SERVIC "
cQuery += "				AND GYN.GYN_EXTRA = 'F' "
cQuery += "				AND GYN.D_E_L_E_T_ = ' ' "
cQuery += "			LEFT JOIN "+RetSqlName('G55')+" G55 ON "
cQuery += "				G55.G55_FILIAL = '"+xFilial('G55')+"' "
cQuery += "				AND RODAGEM.G52_SEC = '1' "
cQuery += "				AND G55.G55_SEQ = RODAGEM.GZQ_SEQSER "
cQuery += "				AND G55.G55_CODGID = RODAGEM.G52_SERVIC "
cQuery += "				AND G55.G55_DTPART BETWEEN " + DTOS(MV_PAR01) + " AND " + DTOS(MV_PAR02) + " "
cQuery += "				AND G55.D_E_L_E_T_ = ' ' "
cQuery += "			INNER JOIN "+RetSqlName('GI4')+" GI4 ON "
cQuery += "				GI4_FILIAL = '"+xFilial('GI4')+"' "
cQuery += "				AND GI4_LINHA = RODAGEM.G52_LINHA "
cQuery += "				AND GI4_LOCORI = RODAGEM.G52_LOCORI "
cQuery += "				AND GI4_LOCDES = RODAGEM.G52_LOCDST "
cQuery += "				AND GI4.GI4_HIST = '2' "
cQuery += "				AND GI4.D_E_L_E_T_ = ' ' "
cQuery += "	) T "

cQuery := ChangeQuery(cQuery)

If Trim(TcGetDb()) == 'ORACLE' .Or. lEmulaOracle
    oTblViagens:InsertSelect("("+cQuery+") ORDER BY GYN_SEQALO,GYN_DTINI,GYN_HRSDGR",aFlds)
Else
    oTblViagens:InsertSelect("("+cQuery+") t ORDER BY t.GYN_SEQALO,t.GYN_DTINI,t.GYN_HRSDGR",aFlds)
Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetQtdVeicEsc
(long_description)
@type function
@author jacomo.fernandes
@since 05/05/2019
@version 1.0
@param cEscala, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetQtdVeicEsc(cEscala)
Local cTmpAlias		:= GetNextAlias()
Local nQtdVeic 		:= 0

BeginSQL Alias cTmpAlias

	SELECT 
		COUNT(GQA_CODVEI) QTD_VEIC
	FROM %Table:GQA% GQA		
	WHERE
		GQA.GQA_FILIAL = %xFilial:GQA%
		AND GQA.GQA_CODESC = %Exp:cEscala%
		AND GQA.%NotDel%

EndSQL

nQtdVeic := (cTmpAlias)->QTD_VEIC

(cTmpAlias)->(DbCloseArea())

Return(nQtdVeic)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChangeArrTmpFld
(long_description)
@type function
@author jacomo.fernandes
@since 05/05/2019
@version 1.0
@param aTmpFld, array, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param nPosAltera, numérico, (Descrição do parâmetro)
@param uNewValue, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function ChangeArrTmpFld(aTmpFld,cField,nPosAltera,uNewValue)
Local nPosFld	:= 0

If (nPosFld := aScan(aTmpFld,{|x| AllTrim(x[1]) == cField})) > 0
	aTmpFld[nPosFld][nPosAltera] := uNewValue
Endif

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetFldFrequencia
(long_description)
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 1.0
@param dDtAux, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function RetFldFrequencia(dDtAux)
Local cFldRet := ""
Local cFreq	:= GtpxDoW(dDtAux,3,.T.) //Retorna SEG,TER,QUA,QUI,SEX,SAB,DOM

Do Case
	Case cFreq == 'DOM'
		cFldRet	:= "G52_DOMING"
		 
	Case cFreq == 'SEG'
		cFldRet	:= "G52_SEGUND"
		 
	Case cFreq == 'TER'
		cFldRet	:= "G52_TERCA"
		 
	Case cFreq == 'QUA'
		cFldRet	:= "G52_QUARTA"
		 
	Case cFreq == 'QUI'
		cFldRet	:= "G52_QUINTA"
		 
	Case cFreq == 'SEX'
		cFldRet	:= "G52_SEXTA"
		 
	Case cFreq == 'SAB'
		cFldRet	:= "G52_SABADO"

EndCase	


Return cFldRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetFirstDay
(long_description)
@type function
@author jacomo.fernandes
@since 06/05/2019
@version 1.0
@param nDiaEsc, numérico, (Descrição do parâmetro)
@param dDtAux, data, (Descrição do parâmetro)
@param dDtFim, data, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetFirstDay(nDiaEsc,dDtAux,dDtFim)
Local cFldFreq	:= ""
Local nRecno	:= 0
Local cWhere	:= ""

While nRecno == 0 .and. dDtAux <= dDtFim
	cFldFreq	:=	RetFldFrequencia(dDtAux)
	 
	cWhere	:= "G52_DIA = "+cValToChar(nDiaEsc)+" "
	cWhere	+= "and "+cFldFreq+" = 'T' "
	
	
	nRecno := GetInfoEscala(cWhere)
	
	If nRecno == 0
		dDtAux++
	Endif
	
	
End

Return nRecno


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetInfoEscala
(long_description)
@type function
@author jacomo.fernandes
@since 06/05/2019
@version 1.0
@param cWhere, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetInfoEscala(cWhere)

Local cTmpAlias	:= GetNextAlias()
Local cTblEscala:= '%'+oTblEscala:GetRealName()+'%'
Local nRecno	:= 0

cWhere := "% "+cWhere+" %"
	
BeginSql Alias cTmpAlias
	Select R_E_C_N_O_ AS G52RECNO
	FROM %Exp: cTblEscala %
	Where
		%Exp:cWhere%
	ORDER BY G52_SEQUEN	
EndSql

If (cTmpAlias)->(!Eof())
	nRecno := (cTmpAlias)->G52RECNO
Endif

(cTmpAlias)->(DbCloseArea())


Return nRecno

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetRodagem
(long_description)
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 1.0
@param cTmpRodag, character, (Descrição do parâmetro)
@param cTmpEscala, character, (Descrição do parâmetro)
@param dDtAux, data, (Descrição do parâmetro)
@param nVeic, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function SetRodagem(aFlds,cFields,nRecno,dDtAux,nVeic)
Local cQuery   := ""

cFields := StrTran(cFields,"G52_SEQALO","'"+StrZero(nVeic,2)+"' AS G52_SEQALO")
cFields := StrTran(cFields,"GYN_DTINI","'"+DtoS(dDtAux)+"' AS GYN_DTINI")

cQuery += "Select " + cFields + " "
cQuery += "From " + oTblEscala:GetRealName()
cQuery += "Where "
cQuery += " R_E_C_N_O_ = " + cValToChar(nRecno)

cQuery := ChangeQuery(cQuery)

If 'ORACLE' $ Trim(TcGetDb()) .Or. lEmulaOracle
    oTblRodagem:InsertSelect('('+cQuery+') ORDER BY G52_SEQUEN',aFlds)
Else
    oTblRodagem:InsertSelect('('+cQuery+') t ORDER BY t.G52_SEQUEN',aFlds)
Endif

Return		

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextEscala
(long_description)
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 1.0
@param dDtAux, data, (Descrição do parâmetro)
@param cLocIni, character, (Descrição do parâmetro)
@param cHrSaiGrg, character, (Descrição do parâmetro)
@param nDiaEsc, numérico, (Descrição do parâmetro)
@param nDiaBkp, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetNextEscala(dDtAux,cLocIni,cHrSaiGrg,nDiaEsc,nDiaBkp,lReset)
Local nRecno	:= 0
Local cWhere	:= ""
Local cFldFreq	:= RetFldFrequencia(dDtAux) 

cWhere	+= "G52_DIA = "+cValToChar(nDiaEsc)+" "
cWhere	+= "and G52_LOCORI = '"+cLocIni+"' "
cWhere	+= "and G52_HRSDGR = '"+cHrSaiGrg+"' "
cWhere	+= "and "+cFldFreq+" = 'T' "

If (nRecno := GetInfoEscala(cWhere)) == 0
	nDiaEsc := GetNextDiaEscala(nDiaEsc,@lReset)

	If !lReset .or. (lReset .and. nDiaEsc <= nDiaBkp .and. aMinMaxDia[1] <> aMinMaxDia[2])
		nRecno  := GetNextEscala(dDtAux,cLocIni,cHrSaiGrg,@nDiaEsc,nDiaBkp,@lReset)
	Endif

Endif 

Return nRecno

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextDiaEscala
(long_description)
@type function
@author jacomo.fernandes
@since 06/05/2019
@version 1.0
@param nDiaEsc, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetNextDiaEscala(nDiaEsc,lReset)

nDiaEsc++
	
If ( nDiaEsc > aMinMaxDia[2] ) //Se nDiaEsc maior que o dia maximo da escala, pega o primeiro dia novamente
	lReset	:= .T.
EndIf

Return nDiaEsc


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetMinMaxDia
(long_description)
@type function
@author jacomo.fernandes
@since 06/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetMinMaxDia()
Local cTmpAlias	:= GetNextAlias()
Local cTblEscala:= '%'+oTblEscala:GetRealName()+'%'
Local aRet		:= {}

BeginSql Alias cTmpAlias
	Select 
		Min(G52_DIA) AS MINIMO,
		Max(G52_DIA) AS MAXIMO
	From %Exp:cTblEscala%
	
EndSql	

aAdd(aRet,(cTmpAlias)->MINIMO)
aAdd(aRet,(cTmpAlias)->MAXIMO)

(cTmpAlias)->(DbCloseArea())

Return aRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCboxDia
(long_description)
@type function
@author jacomo.fernandes
@since 07/05/2019
@version 1.0
@param aMinMaxDia, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function GetCboxDia(aMinMaxDia)
Local aRet	:= {}
Local n1	:= 0
aAdd(aRet, '00=Sem definição')
For n1 := aMinMaxDia[1] to aMinMaxDia[2]
	aAdd(aRet, I18n('#1=#1º Sequência',{StrZero(n1,2)}))
Next

Return aRet


/*/{Protheus.doc} GTPA409TRG
(long_description)
@type function
@author jacomo.fernandes
@since 09/05/2019
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPA409TRG(oMdl,cField,xVal)
Local oModel	:= oMdl:GetModel()
Local oView		:= FwViewActive()

Do Case
	Case cField == "GQA_MARK"
		SetMarcacaoVeiculo(oModel,xVal)
	Case cField == "GQA_SEQALO"
		SetGridViagens(oModel,xVal)
	Case cField == "GYN_MARK"
		MarcVeiNaViag(oModel,xVal)
EndCase

If !IsBlind() 
	oView:Refresh()
Endif

Return xVal

/*/{Protheus.doc} MarcVeiNaViag
(long_description)
@type function
@author henrique.toyada
@since 15/05/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param lMark, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function MarcVeiNaViag(oModel,lMark)
Local oMdlGQA	:= oModel:GetModel('GQADETAIL')
Local oMdlGYN	:= oModel:GetModel('GYNDETAIL')
Local oMdlTOT	:= oModel:GetModel('TOTALIZA')
Local cCodVeic	:= oMdlGQA:GetValue('GQA_CODVEI') 
Local nHodoAtu	:= oMdlGQA:GetValue('GQA_HODOME')
Local nKmMax	:= oMdlGQA:GetValue('GQA_KMMAN')
Local nLineAtu  := 1
Local nIni		:= 0
Local nAte		:= 0

Local nKMViag	:= 0
Local nKmBkp	:= 0

Local lOk		:= .T.
Local lAltera   := .T.

If !isincallstack("SetMarcacaoVeiculo")
	If lMark .AND. !oMdlGQA:GetValue('GQA_MARK')
	
		nLineAtu := oMdlGYN:GetLine()
		If !(EMPTY(oMdlGYN:GetValue('GYN_VEIC',nLineAtu))) .AND. oMdlGYN:GetValue('GYN_VEIC',nLineAtu) != cCodVeic
			lAltera := .F.
			If MsgYesNo( STR0080, STR0081 )//"Deseja alterar o veiculo?"#"Alterar veiculo"
				lAltera := .T.
			EndIf
		EndIf
		
		If lAltera
			nKMViag += oMdlTOT:GetValue("TOT_KMVIAG")
			nKMViag += oMdlGYN:GetValue('GYN_KMPROV',nLineAtu)
			If nKMViag > nKmMax
				lOk := .F.
			Endif
			
			//Se For Ponto de Manutenção ou ultimo registro, guarda a ultima posição
			If lOk
				nAte	:= nLineAtu
				nKmBkp	:= nKMViag 	
				oMdlGQA:LoadValue('GQA_MARK',.T.)
				oMdlGYN:LoadValue('GYN_VEIC',cCodVeic)
				oMdlGYN:LoadValue('GYN_LEGEND',"BR_VERDE")		
			Endif
			
			oMdlTOT:SetValue("TOT_KMVIAG",nKmBkp)
			oMdlTOT:SetValue("TOT_KMTOT" ,nHodoAtu+nKmBkp)
			oMdlTOT:SetValue("TOT_KMVMAX",nKmMax-(nHodoAtu+nKmBkp))
		Else
			oMdlGYN:LoadValue('GYN_MARK',lAltera)
		EndIf 
	Else
		nLineAtu := oMdlGYN:GetLine()
		If !(EMPTY(oMdlGYN:GetValue('GYN_VEIC',nLineAtu))) .AND. oMdlGYN:GetValue('GYN_VEIC',nLineAtu) != cCodVeic
			lAltera := .F.
			If MsgYesNo( STR0080, STR0081 + ": " + oMdlGYN:GetValue('GYN_VEIC',nIni) )//"Deseja alterar o veiculo?"#"Alterar veiculo"
				lAltera := .T.
			EndIf
		EndIf
		
		If lAltera
			For nIni := 1 To oMdlGYN:Length()
				If oMdlGYN:GetValue('GYN_MARK',nIni) .AND. nIni != nLineAtu
					lOk := .F.
				Endif
			Next
			
			If lOk
				oMdlGQA:SetValue('GQA_MARK',.F.)
			EndIf
			
			If oMdlGYN:GetValue('GYN_VEIC',nLineAtu) == cCodVeic
				oMdlGYN:LoadValue('GYN_VEIC',"")
				oMdlTOT:SetValue("TOT_KMVIAG",0)
				oMdlTOT:SetValue("TOT_KMTOT" ,nHodoAtu)
				oMdlTOT:SetValue("TOT_KMVMAX",nKmMax-nHodoAtu)
			EndIf
			
		EndIf
		
	Endif
	oMdlGYN:GoLine(nLineAtu)
EndIf
Return

/*/{Protheus.doc} SetMarcacaoVeiculo
(long_description)
@type function
@author jacomo.fernandes
@since 10/05/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param lMark, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetMarcacaoVeiculo(oModel,lMark)
Local oMdlGQA	:= oModel:GetModel('GQADETAIL')
Local oMdlGYN	:= oModel:GetModel('GYNDETAIL')
Local oMdlTOT	:= oModel:GetModel('TOTALIZA')
Local cCodVeic	:= oMdlGQA:GetValue('GQA_CODVEI') 
Local nHodoAtu	:= oMdlGQA:GetValue('GQA_HODOME')
Local nKmMax	:= oMdlGQA:GetValue('GQA_KMMAN')
Local cAuxVeic  := ""

Local n1		:= 0
Local nIni		:= 0
Local nAte		:= 0

Local nKMViag	:= 0
Local nKmBkp	:= 0

Local lOk		:= .T.
Local lAltera   := .T.

If lMark
	For n1 := 1 To oMdlGYN:Length()
		If !(EMPTY(oMdlGYN:GetValue('GYN_CODIGO',n1)))
			nKMViag += oMdlGYN:GetValue('GYN_KMPROV',n1)
			
			If nKMViag > nKmMax
				lOk := .F.
				Exit
			Endif
		EndIf
		//Se For Ponto de Manutenção ou ultimo registro, guarda a ultima posição
		If (oMdlGYN:GetValue('GYN_PMANUT',n1) == '1' .or. n1 == oMdlGYN:Length()) .and. lOk
			nAte	:= n1
			nKmBkp	:= nKMViag 		
		Endif
	
	Next
	
	For nIni := 1 To nAte
		If !(EMPTY(oMdlGYN:GetValue('GYN_VEIC',nIni))) ;
				.AND. oMdlGYN:GetValue('GYN_VEIC',nIni) != cCodVeic ;
					.AND. oMdlGYN:GetValue('GYN_VEIC',nIni) != cAuxVeic
			
			If MsgYesNo( STR0080, STR0081 + ": " + oMdlGYN:GetValue('GYN_VEIC',nIni))//"Deseja alterar o veiculo?"#"Alterar veiculo"
				lAltera := .T.
			ELse
				lAltera := .F.
				cAuxVeic := oMdlGYN:GetValue('GYN_VEIC',nIni)
			EndIf
		Else
			If oMdlGYN:GetValue('GYN_VEIC',nIni) != cAuxVeic
				lAltera := .T.
			Else
				lAltera := .F.
			EndIf
		EndIf
		
		If !oMdlGYN:GetValue('GYN_MARK',nIni) .AND. lAltera
			If !(EMPTY(oMdlGYN:GetValue('GYN_CODIGO',nIni)))
				oMdlGYN:GoLine(nIni)
				oMdlGYN:SetValue('GYN_MARK',.T.)
				oMdlGYN:SetValue('GYN_VEIC',cCodVeic)
				oMdlGYN:SetValue('GYN_LEGEND',"BR_VERDE")
			EndIf
		Endif
		
	Next
	
	oMdlTOT:SetValue("TOT_KMVIAG",nKmBkp)
	oMdlTOT:SetValue("TOT_KMTOT" ,nHodoAtu+nKmBkp)
	oMdlTOT:SetValue("TOT_KMVMAX",nKmMax-(nHodoAtu+nKmBkp)) 
Else
	For nIni := 1 To oMdlGYN:Length()
		If oMdlGYN:GetValue('GYN_MARK',nIni)
			oMdlGYN:GoLine(nIni)
			oMdlGYN:SetValue('GYN_MARK',.F.)
			oMdlGYN:SetValue('GYN_VEIC','')
			oMdlGYN:SetValue('GYN_LEGEND',"BR_AMARELO")
		Endif
	Next
	
	oMdlTOT:SetValue("TOT_KMVIAG",0)
	oMdlTOT:SetValue("TOT_KMTOT" ,nHodoAtu)
	oMdlTOT:SetValue("TOT_KMVMAX",nKmMax-nHodoAtu)
	
Endif
oMdlGYN:GoLine(1)
Return

/*/{Protheus.doc} SetGridViagens
(long_description)
@type function
@author jacomo.fernandes
@since 09/05/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param cSeqAloc, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetGridViagens(oModel,cSeqAloc)
Local oMdlGYN		:= oModel:GetModel('GYNDETAIL')
Local oStrGYN		:= oMdlGYN:GetStruct()
Local aFldGYN		:= {} 
Local cFields		:= "%" + GTPFld2Str(oStrGYN,.F.) + "%" 
Local cCodVeic		:= oModel:GetModel('GQADETAIL'):GetValue('GQA_CODVEI')
Local cTblViagens	:= "%"+oTblViagens:GetRealName()+"%" 
Local cTmpAlias		:= GetNextAlias()
Local n1			:= 0
Local lFirst		:= .T.

Local lNoInsert		:= !oMdlGYN:CanInsertLine()	
Local lNoDelete		:= !oMdlGYN:CanDeleteLine()

oMdlGYN:SetNoInsertLine(.F.)
oMdlGYN:SetNoDeleteLine(.F.)

GTPxClearData(oMdlGYN)



cFields		:= StrTran(cFields,"GYN_LEGEND", "(Case "+; 
													"when GYN_LEGEND = 'BR_VERMELHO' OR GYN_LEGEND = 'BR_CINZA' THEN GYN_LEGEND "+; 
													"WHEN GYN_VEIC  = '"+cCodVeic+"' THEN 'BR_VERDE' "+;
													"WHEN  GYN_VEIC <> '"+Space(TamSx3('GQE_RECURS')[1])+"' THEN 'BR_LARANJA' "+;
													"ELSE 'BR_AMARELO' "+; 
												"END) AS GYN_LEGEND" )

If cSeqAloc <> '00'
	BeginSql Alias cTmpAlias
		COLUMN GYN_DTINI AS DATE
		COLUMN GYN_DTFIM AS DATE
		COLUMN GYN_MARK AS LOGICAL	
		
		Select %Exp:cFields%
		From %Exp:cTblViagens%
		Where
			GYN_SEQALO = %Exp:cSeqAloc%
		Order By GYN_DTINI,GYN_HRSDGR
	EndSql
	
	
	aFldGYN := (cTmpAlias)->(DbStruct())
	
	While (cTmpAlias)->(!Eof())
		If !lFirst
			oMdlGYN:AddLine()
		Endif
		
		For n1	:= 1 To Len(aFldGYN)
			If oStrGYN:HasField(aFldGYN[n1][1])
				oMdlGYN:LoadValue(aFldGYN[n1][1],(cTmpAlias)->&(aFldGYN[n1][1]))
			Endif
		Next
		
		lFirst := .F.
		
		(cTmpAlias)->(DbSkip())
	End
	
	(cTmpAlias)->(DbCloseArea())

Endif

oMdlGYN:GoLine(1)
oMdlGYN:SetNoInsertLine(lNoInsert)
oMdlGYN:SetNoDeleteLine(lNoDelete)

Return


/*/{Protheus.doc} GTPA409Vld
(long_description)
@type function
@author jacomo.fernandes
@since 09/05/2019
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
Static Function GTPA409Vld(oMdl,cField,cNewValue,cOldValue)
Local lRet		:= .T.
Local oModel	:= oMdl:GetModel()

Local cSeek		:= ""

Local cTitErro	:= ""
Local cMsgErro	:= ""
Local cMsgSolu	:= ""

Do Case
	Case cField == "GQA_MARK"

	Case cField == "GQA_SEQALO"
		
		cSeek	:= "#1 == '"+cNewValue+"' .and. #2 <> '"+oMdl:GetValue('GQA_CODVEI')+"' "
		
		If cNewValue <> "00" .and. GTPxSeekLine(oMdl,cSeek,{"GQA_SEQALO","GQA_CODVEI"},.F.,.F.) //Não Posicionar
			lRet		:= .F.
			cTitErro	:= "SEQ_UTILIZADA"
			cMsgErro	:= STR0082//"Sequência informada já utilizada em outro veículo"
			cMsgSolu	:= STR0083//"Informe uma outra Sequência ou realize a manutenção da Sequência selecionada no outro veículo"
		Endif	
		
EndCase

If !lRet
	oModel:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,cTitErro,cMsgErro,cMsgSolu,cNewValue,cOldValue)
Endif

Return lRet
/*/{Protheus.doc} GTPA409Leg
(long_description)
@type function
@author jacomo.fernandes
@since 16/05/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPA409Leg()

oLegenda := FwLegend():New()

oLegenda:Add( "", "BR_VERDE"	,STR0084 ) //"Alocado"
oLegenda:Add( "", "BR_AMARELO"	,STR0085 ) //"Sem Alocação"
oLegenda:Add( "", "BR_CINZA"	,STR0086 ) //"Sem viagem cadastrada"
oLegenda:Add( "", "BR_LARANJA"	,STR0087 ) //"Conflito de Veículo"
oLegenda:Add( "", "BR_VERMELHO"	,STR0088 ) //"Conflito de Serviço"


oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

GTPDestroy(oLegenda)

Return(Nil)
 
 
/*/{Protheus.doc} Ga409DbClk
(long_description)
@type function
@author jacomo.fernandes
@since 16/05/2019
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param nLineGrid, numérico, (Descrição do parâmetro)
@param nLineModel, numérico, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga409DbClk(oGrid,cField,nLineGrid,nLineModel)
If cField == "GYN_LEGEND"
	GTPA409Leg()
Endif
Return .T. 

Function EmulaOraOnOff(lReset)
	Default lReset := .f.
	
	lEmulaOracle := IIf(lReset,.F.,!lEmulaOracle)
Return()
