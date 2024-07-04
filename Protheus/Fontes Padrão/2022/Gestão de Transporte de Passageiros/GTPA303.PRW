#include "GTPA303.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "PARMTYPE.CH"


// ----------------------+
// CONSTANTES - COMBOBOX |
// ----------------------+

// CBOX GYE_SITRH - SITUAÇÃO RECURSO
#DEFINE DISPONIVEL	'1'
#DEFINE FERIAS		'2'
#DEFINE AFASTADO		'3'
#DEFINE DEMITIDO		'4'
#DEFINE NAOADIMITIDO '0'

// CBOX GYE_TPDIA - TIPO DO DIA
#DEFINE TRABALHADO		'1'
#DEFINE NAO_TRABALHADO	'2'
#DEFINE FOLGA				'3'
#DEFINE DSR				'4'

// SELECAO DOS CAMPOS TOTALIZADORES
#DEFINE GYQTOTAL 'GYQ_HRTRAB|GYQ_HRADN|GYQ_HREXTR|GYQ_HRPLAN|GYQ_HRVOLA|GYQ_HRFVOL|GYQ_DSRUTI|GYQ_HRDESP|'

STATIC __uRetBrw	:= ""
static __oBrw1 := nil
static __oBrw2 := nil

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA303()
Cadastro de Alocação de Motoristas

@sample	GTPA303()

@return	oBrowse  Retorna o Cadastro de Alocação de Motoristas

@author		Lucas.brustolin
@author		Mick William da Silva
@since		25/08/2017
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function GTPA303()
	
	Local oBrowse 		:= Nil
	Local cSetor		:= ""
	Local cFiltro		:= ""
				
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("GYQ")
	oBrowse:SetDescription(STR0001) //"Alocação"
	oBrowse:SetMenuDef('GTPA303')	
	
	If __cUserId <> "000000"
	
		cSetor	:= Posicione("GYH",2,xFilial("GYH") + __cUserId, "GYH_CODIGO" )
		If !Empty(cSetor)
			cFiltro := "GYQ->GYQ_SETOR == '"+cSetor+"' "
			oBrowse:SetFilterDefault(cFiltro)
		Endif
		
	
	EndIf 
	
	// ---------------------------------+
	// Adiciona as legendas no browse.  |
	// ---------------------------------+
	
	oBrowse:AddLegend("GYQ->GYQ_STATUS == '1'", "BR_VERDE"	,"Em Aberto")//Em Aberto
	oBrowse:AddLegend("GYQ->GYQ_STATUS == '2'", "BR_AZUL"	,"Finalizado")//Finalizado
	
	oBrowse:Activate()
	
Return ( oBrowse )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@sample	ModelDef()

@return	oModel - Objeto do Model

@author		Lucas.brustolin 
@author		Mick William da Silva

@since		20/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ModelDef()
	
	Local oModel		:= Nil
	Local oStruGYQ	:= FWFormStruct( 1,"GYQ" , {|cCampo| AllTrim(cCampo)+ "|" $ "GYQ_FILIAL|GYQ_CODIGO|GYQ_COLCOD|GYQ_COLDES|GYQ_FUNCIO|GYQ_HRMENS|GYQ_QTDDSR|GYQ_DTINI|GYQ_DTFIM|GYQ_HRTRAB|GYQ_HRADN|GYQ_HREXTR|GYQ_HRPLAN|GYQ_HRVOLA|GYQ_HRFVOL|GYQ_DSRUTI|GYQ_STATUS|GYQ_SETOR|GYQ_DSCSET|GYQ_GRPSET|GYQ_GRPDSC|GYQ_ESQUEM|GYQ_ESQSEQ|GYQ_HRDESP|"})
	Local oStruGYE	:= FWFormStruct( 1,"GYE" )
	Local oStruGYP	:= FWFormStruct( 1,"GYP" )
	Local oStruTot  := FWFormStruct( 1,'GYQ', {|cCampo| AllTrim(cCampo)+ "|" $ GYQTOTAL })
	Local bCommit	:= {|oModel| TP303Commit(oModel) }
	Local bValid	:= {|oModel| TP303TudOk(oModel)}
	
	
	// ---------------------------------------------------+
	// Cria tabelas/campos virtuais para os totalizadores |
	// ---------------------------------------------------+
	LoadStructTable( oStruGYQ, oStruGYE,oStruGYP, .F.)
	
	oModel := MPFormModel():New(STR0002,/*bPreValid*/,bValid, bCommit  ) //GTPA303
	
	oModel:AddFields('FIELDGYQ'	,/*cOwner*/	, oStruGYQ)
	oModel:AddGrid('GRIDGYE'	,'FIELDGYQ'	, oStruGYE, { |oModel, nLine, cAction,cField| GA303LNPRE(oModel,nLine,cAction,cField) }/*bLinePre*/)
	oModel:AddGrid('GRIDGYP'	,'GRIDGYE'	, oStruGYP)
	oModel:AddFields('FIELDTOT'	,'FIELDGYQ'	, oStruTot)

	oModel:SetRelation( 'GRIDGYE', { { 'GYE_FILIAL', 'xFilial( "GYE") ' },{'GYE_CODGYQ', 'GYQ_CODIGO'} ,{'GYE_COLCOD', 'GYQ_COLCOD'} }, GYE->(IndexKey(4) ) )
	oModel:SetRelation( 'GRIDGYP', { { 'GYP_FILIAL', 'xFilial( "GYP") ' },{'GYP_ESCALA', 'GYE_ESCALA'} }, GYP->(IndexKey(1) ) )
	oModel:SetRelation( 'FIELDTOT',{ { 'GYQ_FILIAL', 'xFilial( "GYQ") ' },{'GYQ_CODIGO', 'GYQ_CODIGO'} }, GYP->(IndexKey(1) ) )
		
	oModel:GetModel('GRIDGYE'):SetNoInsertLine()	// Nao Permite inclusao no grid
	oModel:GetModel('GRIDGYE'):SetNoUpdateLine(.F.)	// Permite Alteração no grid
	oModel:GetModel('GRIDGYE'):SetNoDeleteLine(.T.)	// Nao Permite exclusao no grid
	
	oModel:SetPrimaryKey({"GYE_FILIAL","GYE_COLCOD","GYE_DTREF"})
	
	oModel:GetModel( 'GRIDGYE' ):SetUniqueLine( { 'GYE_FILIAL','GYE_DTREF','GYE_COLCOD'} )
	
	//Desabilita a Gravação automatica do Model FIELDZTP
	oModel:GetModel( 'FIELDGYQ'):SetOnlyQuery( .F. )
	oModel:GetModel( 'GRIDGYP' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'FIELDTOT' ):SetOnlyQuery( .T. )

	oModel:GetModel( 'GRIDGYP' ):SetOptional( .T. )
	oModel:GetModel( 'FIELDTOT' ):SetOptional( .T. )

	oModel:SetDescription( STR0001 )
	oModel:GetModel( 'FIELDGYQ'):SetDescription( STR0001 )
	
	oModel:SetActivate({|oModel| Ga303Activ(oModel)})
Return ( oModel )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface

@sample	ViewDef()

@return	oView - Objeto View

@author		Lucas.brustolin
@author		Mick William da Silva
@since		20/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel		:= FwLoadModel('GTPA303')
Local oView			:= FWFormView():New()
Local oStruGYQ		:= FWFormStruct(2,'GYQ', {|cCampo| AllTrim(cCampo)+ "|" $ "GYQ_STATUS|GYQ_COLCOD|GYQ_COLDES|GYQ_FUNCIO|GYQ_HRMENS|GYQ_QTDDSR|GYQ_DTINI|GYQ_DTFIM|GYQ_SETOR|GYQ_DSCSET|GYQ_GRPSET|GYQ_GRPDSC|GYQ_ESQUEM|GYQ_ESQSEQ|" })
Local oStruGYE		:= FWFormStruct(2,'GYE')
Local oStruGYQTot  	:= FWFormStruct(2,'GYQ', {|cCampo| AllTrim(cCampo)+ "|" $ GYQTOTAL })


//ATUALIZA A ESTRUTURA DA VIEW
LoadStructTable( oStruGYQ, oStruGYE,, .T.)

oView:SetModel(oModel)
oView:SetDescription(STR0003)//"Alocação - Colaborador"

oView:AddField('VIEW_GYQ'	, oStruGYQ,'FIELDGYQ' )
oView:AddGrid('VIEW_GYE'		, oStruGYE,'GRIDGYE')
oView:AddField('VIEW_GYQTOT', oStruGYQTot,'FIELDTOT')

oView:CreateHorizontalBox('SUPERIOR'	,30)
oView:CreateHorizontalBox('MEIO'		,50)
oView:CreateHorizontalBox('INFERIOR'	,20)
	
oView:SetOwnerView('VIEW_GYQ'		,'SUPERIOR')
oView:SetOwnerView('VIEW_GYE'		,'MEIO' )
oView:SetOwnerView('VIEW_GYQTOT'	,'INFERIOR')

oView:EnableTitleView('VIEW_GYE'	,"Alocação")
oView:EnableTitleView('VIEW_GYQTOT',"Totalizadores")


oView:AddUserButton( STR0023, '', {|| TP008EXEC()} ) //'Consultar Colaborador'
oView:AddUserButton( STR0051, '', {|oView| GA303DetEsc(oView) } ) // 'Detalhes Escala'
oView:AddUserButton("Legenda","", {|oView| Ga303Legend(oView,.T.,"GYE") }) 
oView:AddUserButton( 'Atualiza Total', '', {|| TP303Totaliza()},,, {MODEL_OPERATION_INSERT, MODEL_OPERATION_UPDATE} ) //'Atualiza Total'	
oView:AddUserButton(STR0124,"", {|oView| Ga303Escala(oView) })//"Escalar"

oView:SetViewProperty("VIEW_GYE", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| Ga303DbClk(oGrid,cField,nLineGrid,nLineModel)}})

Return ( oView )

/*/{Protheus.doc} LoadStructTable
(long_description)
@type function
@author jacomo.fernandes
@since 30/10/2017
@version 1.0
@param oStruGYQ, objeto, (Descrição do parâmetro)
@param oStruGYE, objeto, (Descrição do parâmetro)
@param oStruGYP, objeto, (Descrição do parâmetro)
@param lView, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadStructTable( oStruGYQ, oStruGYE, oStruGYP, lView)
Local bFldVld	:= {|oMdl,cField,cNewValue,cOldValue|GTPA303Vld(oMdl,cField,cNewValue,cOldValue) }
Local bWhen		:= {|oMdl,cField,xVal| GTPA303WHEN(oMdl,cField,xVal)}
Local bTrig		:= {|oMdl,cField,xVal|GTPA303TRG(oMdl,cField,xVal)}
Local bInit		:= {|oMdl,cField,xVal,nLine,xOldValue| GTPA303INIT(oMdl,cField,xVal,nLine,xOldValue)}
DEFAULT lView := .F.
	
	//-------------------------------+
	// lView = .F. - Estrutura Model |
	//-------------------------------+
	If !lView
		// GYQ
		If ValType(oStruGYQ) == "O"
			//oStruGYQ:AddField("Nome Colab","Nome do Colaborador","DESCOLAB","C",30,,,,,,,,,.T.,)
			oStruGYQ:AddField("Loc. Colab","Cód Loc. Colab","CODLOCPAD","C",TAMSX3("GYG_LOCPAD")[1],,,,,,,,,.T.,)
			oStruGYQ:AddField(STR0059,"Desc. Local.","DESLOCPAD","C",TAMSX3("GI1_DESCRI")[1],,,,,,,,,.T.,)
					
			oStruGYQ:SetProperty("GYQ_DTINI"	, MODEL_FIELD_VALID	, bFldVld )
			oStruGYQ:SetProperty("GYQ_DTFIM"	, MODEL_FIELD_VALID	, bFldVld )
			oStruGYQ:SetProperty("GYQ_ESQUEM"	, MODEL_FIELD_VALID	, bFldVld )
			oStruGYQ:SetProperty("GYQ_ESQSEQ"	, MODEL_FIELD_VALID	, bFldVld )
			oStruGYQ:SetProperty("GYQ_SETOR"	, MODEL_FIELD_VALID	, bFldVld )
			oStruGYQ:SetProperty("GYQ_GRPSET"	, MODEL_FIELD_VALID	, bFldVld )
			oStruGYQ:SetProperty("GYQ_COLCOD"	, MODEL_FIELD_VALID	, bFldVld )
			
			oStruGYQ:SetProperty("GYQ_COLCOD"	, MODEL_FIELD_WHEN	, bWhen )
			oStruGYQ:SetProperty("GYQ_GRPSET"	, MODEL_FIELD_WHEN	, bWhen )
			oStruGYQ:SetProperty("GYQ_DTINI"	, MODEL_FIELD_WHEN	, bWhen )
			oStruGYQ:SetProperty("GYQ_DTFIM"	, MODEL_FIELD_WHEN	, bWhen )
			oStruGYQ:SetProperty("GYQ_ESQUEM"	, MODEL_FIELD_WHEN	, bWhen )
			oStruGYQ:SetProperty("GYQ_ESQSEQ"	, MODEL_FIELD_WHEN	, bWhen )
			
			oStruGYQ:SetProperty("GYQ_COLDES"	, MODEL_FIELD_INIT	, bInit )
			oStruGYQ:SetProperty("CODLOCPAD"	, MODEL_FIELD_INIT	, bInit )
			oStruGYQ:SetProperty("DESLOCPAD"	, MODEL_FIELD_INIT	, bInit )
			
			oStruGYQ:SetProperty("GYQ_COLCOD"	, MODEL_FIELD_OBRIGAT, .T.)
		
			oStruGYQ:AddTrigger("GYQ_DTINI"		,"GYQ_DTINI"			,{||.T.},bTrig)
			oStruGYQ:AddTrigger("GYQ_DTFIM"		,"GYQ_DTFIM"			,{||.T.},bTrig)
			oStruGYQ:AddTrigger("GYQ_SETOR"		,"GYQ_SETOR"			,{||.T.},bTrig)
			oStruGYQ:AddTrigger("GYQ_GRPSET"	,"GYQ_GRPSET"			,{||.T.},bTrig)
			oStruGYQ:AddTrigger("GYQ_COLCOD"	,"GYQ_COLCOD"			,{||.T.},bTrig)
			oStruGYQ:AddTrigger("CODLOCPAD"		,"CODLOCPAD"			,{||.T.},bTrig)
			oStruGYQ:AddTrigger("GYQ_ESQUEM"	,"GYQ_ESQUEM"			,{||.T.},bTrig)
			oStruGYQ:AddTrigger("GYQ_ESQSEQ"	,"GYQ_ESQSEQ"			,{||.T.},bTrig)
		Endif			
		// GYE
		If ValType(oStruGYE) == "O"
			oStruGYE:AddField('','','GYE_LEGEND','BT',1,,,,,,,,,.T.,)
			
			oStruGYE:SetProperty("GYE_LEGEND"	, MODEL_FIELD_INIT	, bInit )
			
			oStruGYE:SetProperty("GYE_ESCALA"	, MODEL_FIELD_VALID	, bFldVld )
			
			oStruGYE:SetProperty("GYE_ESCALA"	, MODEL_FIELD_WHEN	, bWhen )
			oStruGYE:SetProperty("GYE_TPDIA"	, MODEL_FIELD_WHEN	, bWhen )
			
			oStruGYE:AddTrigger("GYE_TPDIA"		,"GYE_TPDIA"			,{||.T.},bTrig)
			oStruGYE:AddTrigger("GYE_ESCALA"	,"GYE_ESCALA"			,{||.T.},bTrig)
			oStruGYE:AddTrigger("GYE_STATUS"	,"GYE_STATUS"			,{||.T.},bTrig)
		Endif
		// GYP
		If ValType(oStruGYP) == "O"
			oStruGYP:AddField("Dt Ref"			,"Data Referencia"	,"GYP_DTREF"	,"D",08,,,,,,,,,.T.,)
			oStruGYP:AddField("Viagem/Aloc"		,"Cód. Viagem/Aloc"	,"GYN_CODIGO"	,"C",TAMSX3('GYN_CODIGO')[1],,,,,,,,,.T.,)
			oStruGYP:AddField("Nr Serviço"		,"Nr Serviço"		,"GID_NUMSRV"	,"C",TAMSX3('GID_NUMSRV')[1],,,,,,,,,.T.,)
			oStruGYP:AddField("Colaborador"		,"Colaborador"		,"GQE_RECURS"	,"C",TAMSX3('GQE_RECURS')[1],,,,,,,,,.T.,)
			oStruGYP:AddField("Status"			,"Status"			,"GYP_STATUS"	,"C",01,,,,,,,,,.T.,)
			oStruGYP:AddField(''				,''					,'GYP_LEGEND'	,'BT',1,,,,,,,,,.T.,)
			oStruGYP:AddField("Dt Inicial"		,"Data Inicial"		,"GYP_DTINI"	,"D",08,,,,,,,,,.T.,)
			oStruGYP:AddField("Dt Final"		,"Data Final"		,"GYP_DTFIM"	,"D",08,,,,,,,,,.T.,)
			oStruGYP:AddField("Tipo Dia"		,"Tipo Dia"			,"GQK_TPDIA"	,"C",01,,,,,,,,,.T.,)
			oStruGYP:AddField("Nome Srv Ext"	,"Nome Srv Ext"		,"GZS_DESCRI"	,"C",TAMSX3('GZS_DESCRI')[1],,,,,,,,,.T.,)
			If GQK->(FieldPos("GQK_INTERV")) > 0
				oStruGYP:AddField("Intervalo"	    ,"Intervalo"		,"GYP_INTERV"	,"C",TAMSX3('GQK_INTERV')[1],,,,Nil,,,,,.T.,)
			EndIf
			oStruGYP:SetProperty("*"	, MODEL_FIELD_WHEN		, {|| .T.} )
			oStruGYP:SetProperty("*"	, MODEL_FIELD_OBRIGAT	, .F. )
			
			
			oStruGYP:AddTrigger("GYP_STATUS"	,"GYP_STATUS"		,{||.T.},bTrig)
			
			oStruGYP:SetProperty("GZS_DESCRI"	, MODEL_FIELD_INIT	, bInit )
			If GQK->(FieldPos("GQK_INTERV")) > 0
				oStruGYP:SetProperty("GYP_INTERV"	, MODEL_FIELD_INIT, {|| LoadTipo()})
				oStruGYP:SetProperty("GYP_INTERV"	, MODEL_FIELD_VALUES, {'1=Sim', '2=Não'})
			EndIf
		Endif
	Else
	
		//GYQ
		If ValType(oStruGYQ) == "O"
			oStruGYQ:AddField("CODLOCPAD"	,"11","Loc. Colab"		,"Loc. Colab"  			,Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)//"Código do Local do Colaborador"
			oStruGYQ:AddField("DESLOCPAD"	,"12","Desc. Local."	,"Desc. Local."			,Nil,"C","@!",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)//"Descrição do Local do Colaborador"					
			
			oStruGYQ:SetProperty("GYQ_SETOR"	, MVC_VIEW_ORDEM, '01')
			oStruGYQ:SetProperty("GYQ_DSCSET"	, MVC_VIEW_ORDEM, '02')
			oStruGYQ:SetProperty("GYQ_GRPSET"	, MVC_VIEW_ORDEM, '03')
			oStruGYQ:SetProperty("GYQ_GRPDSC"	, MVC_VIEW_ORDEM, '04')
			oStruGYQ:SetProperty("GYQ_COLCOD"	, MVC_VIEW_ORDEM, '05')
			oStruGYQ:SetProperty("GYQ_COLDES"	, MVC_VIEW_ORDEM, '06')
			oStruGYQ:SetProperty("GYQ_FUNCIO"	, MVC_VIEW_ORDEM, '07')
			oStruGYQ:SetProperty("GYQ_DTINI"	, MVC_VIEW_ORDEM, '08')
			oStruGYQ:SetProperty("GYQ_DTFIM"	, MVC_VIEW_ORDEM, '09')
			oStruGYQ:SetProperty("GYQ_ESQUEM"	, MVC_VIEW_ORDEM, '10')
			oStruGYQ:SetProperty("GYQ_ESQSEQ"	, MVC_VIEW_ORDEM, '11')
			oStruGYQ:SetProperty("CODLOCPAD"	, MVC_VIEW_ORDEM, '12')
			oStruGYQ:SetProperty("DESLOCPAD"	, MVC_VIEW_ORDEM, '13')
			oStruGYQ:SetProperty("GYQ_HRMENS"	, MVC_VIEW_ORDEM, '14')
			oStruGYQ:SetProperty("GYQ_QTDDSR"	, MVC_VIEW_ORDEM, '15')
			oStruGYQ:SetProperty("GYQ_STATUS"	, MVC_VIEW_ORDEM, '16')

			//Caso o usuário for o admin, permitir que ele veja todos os colaboradores
			IF __cUserId == "000000"
				oStruGYQ:SetProperty("GYQ_COLCOD",MVC_VIEW_LOOKUP,"GYG")
			EndIf
		Endif	
		
		//GYE
		If ValType(oStruGYE) == "O"
			oStruGYE:AddField("GYE_LEGEND","01","","",{},"BT","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)
			
			//---- Remove campos da grid na view
			oStruGYE:RemoveField("GYE_COLCOD")
			oStruGYE:RemoveField("GYE_CODIGO")
			oStruGYE:RemoveField("GYE_CODGYQ")
			oStruGYE:RemoveField("GYE_STATUS")
		Endif
		//GYP
		If ValType(oStruGYP) == "O"
			oStruGYP:AddField("GYP_LEGEND"	,"01",""			,""					,{} ,"BT","",Nil,Nil,.F.,"",Nil,Nil,Nil,Nil,.T.,Nil)
			oStruGYP:AddField("GYP_DTREF"	,"02","Dt Ref"		,"Data Referencia"	,Nil,"D","@D",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GYN_CODIGO"	,"05","Viagem/Aloc"	,"Cód. Viagem/Aloc"	,Nil,"C","@!",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GQE_RECURS"	,"00","Colaborador"	,"Colaborador"		,Nil,"C","@!",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GYP_STATUS"	,"21","Status"		,"Status"			,Nil,"C","@!",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GID_NUMSRV"	,"22","Nr Serviço"	,"Nr Serviço"		,Nil,"C","@!",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			
			oStruGYP:AddField("GYP_DTINI"	,"02","Dt Inicial"	,"Dt Inicial"		,Nil,"D","@D",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GYP_DTFIM"	,"02","Dt Final"	,"Dt Final"			,Nil,"D","@D",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GQK_TPDIA"	,"23","Tipo Dia"	,"Tipo Dia"			,Nil,"C","@!",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GQK_TPDIA"	,"23","Tipo Dia"	,"Tipo Dia"			,Nil,"C","@!",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			oStruGYP:AddField("GZS_DESCRI"	,"19","Nome Srv Ext","Nome Srv Ext"		,Nil,"C","@!",NIL,NIL,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			If GQK->(FieldPos("GQK_INTERV")) > 0
				oStruGYP:AddField("GYP_INTERV"	,"39","Intervalo"   ,"Intervalo"  		,Nil,"C","@!",NIL,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.T.)
			EndIf
			oStruGYP:SetProperty("GYP_LEGEND"	, MVC_VIEW_ORDEM, '01')
			oStruGYP:SetProperty("GYP_DTREF"	, MVC_VIEW_ORDEM, '02')
			oStruGYP:SetProperty("GYP_ESCALA"	, MVC_VIEW_ORDEM, '03')
			oStruGYP:SetProperty("GYP_ITEM"		, MVC_VIEW_ORDEM, '04')
			oStruGYP:SetProperty("GYN_CODIGO"	, MVC_VIEW_ORDEM, '05')
			oStruGYP:SetProperty("GYP_CODGID"	, MVC_VIEW_ORDEM, '06')
			oStruGYP:SetProperty("GYP_LINCOD"	, MVC_VIEW_ORDEM, '07')
			oStruGYP:SetProperty("GYP_TIPO"		, MVC_VIEW_ORDEM, '08')
			oStruGYP:SetProperty("GYP_SEQ"		, MVC_VIEW_ORDEM, '09')
			oStruGYP:SetProperty("GYP_SRVORI"	, MVC_VIEW_ORDEM, '10')
			oStruGYP:SetProperty("GYP_DESORI"	, MVC_VIEW_ORDEM, '11')
			oStruGYP:SetProperty("GYP_SRVDES"	, MVC_VIEW_ORDEM, '12')
			oStruGYP:SetProperty("GYP_DESDES"	, MVC_VIEW_ORDEM, '13')
			oStruGYP:SetProperty("GYP_HRINIT"	, MVC_VIEW_ORDEM, '14')
			oStruGYP:SetProperty("GYP_HORORI"	, MVC_VIEW_ORDEM, '15')
			oStruGYP:SetProperty("GYP_HORDES"	, MVC_VIEW_ORDEM, '16')
			oStruGYP:SetProperty("GYP_HRFIMT"	, MVC_VIEW_ORDEM, '17')
			oStruGYP:SetProperty("GYP_SRVEXT"	, MVC_VIEW_ORDEM, '18')
			oStruGYP:SetProperty("GZS_DESCRI"	, MVC_VIEW_ORDEM, '19')
			oStruGYP:SetProperty("GYP_PFUNC"	, MVC_VIEW_ORDEM, '20')
			oStruGYP:SetProperty("GYP_PASSAG"	, MVC_VIEW_ORDEM, '21')
			oStruGYP:SetProperty("GYP_STATUS"	, MVC_VIEW_ORDEM, '22')
			oStruGYP:SetProperty("GID_NUMSRV"	, MVC_VIEW_ORDEM, '23')
			If GQK->(FieldPos("GQK_INTERV")) > 0
				oStruGYP:SetProperty("GYP_INTERV"	, MVC_VIEW_ORDEM, '24')
			EndIf
			oStruGYP:RemoveField("GYP_LINSTD")
			oStruGYP:RemoveField("GQE_RECURS")
			
			oStruGYP:SetProperty("GYP_STATUS"	, MVC_VIEW_COMBOBOX,{"1=Pendente alocação","2=Alocado","3=Escalado","4=Remanejado operacionalmente"} )
			oStruGYP:SetProperty("GQK_TPDIA"	, MVC_VIEW_COMBOBOX,GTPxCbox("GQK_TPDIA") )
			If GQK->(FieldPos("GQK_INTERV")) > 0
				oStruGYP:SetProperty("GYP_INTERV"	, MVC_VIEW_COMBOBOX, {'1=Sim', '2=Não'})		
			EndIf
		Endif
		
	EndIf
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do Menu

@sample	MenuDef()

@return	aRotina - Array com opções do menu

@author		Mick William da Silva
@since		07/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function MenuDef()
	
	Local  aRotina	:= {}
	
	ADD OPTION aRotina TITLE 'VISUALIZAR' 			ACTION 'VIEWDEF.GTPA303' 	OPERATION 2 ACCESS 0 //'VISUALIZAR'
	ADD OPTION aRotina TITLE "Alocação" 			ACTION 'VIEWDEF.GTPA303'	OPERATION 3 ACCESS 0 //'Alocação'
	ADD OPTION aRotina TITLE STR0006 				ACTION 'VIEWDEF.GTPA303'	OPERATION 4 ACCESS 0//"Manutenção da Alocação"
	ADD OPTION aRotina TITLE "Exclusão de Alocação" ACTION 'VIEWDEF.GTPA303'	OPERATION 5 ACCESS 0//"Exclusão de Alocação"
	ADD OPTION aRotina TITLE "Imp Agenda Programada"ACTION 'GTPR302A()'			OPERATION 8 ACCESS 0  //"Impressão"		
Return ( aRotina )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA303DTF()
Rotina responsavel em carregar a grid com as alocaçoes/dias para alocação.

@sample	GTPA303DTF()
@author	jacomo.fernandes
@since		24/10/17
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GTPA303DTF(oModel)
Local oModelGYQ	:= oModel:GetModel("FIELDGYQ")
Local oModelGYE	:= oModel:GetModel("GRIDGYE")

Local cColab		:= oModelGYQ:GetValue("GYQ_COLCOD")
Local dDiaRef		:= oModelGYQ:GetValue("GYQ_DTINI")
Local cSetor		:= oModelGYQ:GetValue("GYQ_SETOR")

Local cDiaSemana	:= ""
Local cSitRh		:= ""
Local nQtdDias 	:= 0
Local n1			:= 0
Local aRetLog		:= {}

oModelGYE:SetNoInsertLine(.F.)
oModelGYE:SetNoDeleteLine(.F.)

If !Empty( oModelGYQ:GetValue("GYQ_DTFIM") )	
	nQtdDias := DateDiffDay(oModelGYQ:GetValue("GYQ_DTINI"), oModelGYQ:GetValue("GYQ_DTFIM")) + 1
		
	For n1:= 1 to nQtdDias
		
		// --------------------------------------------------+
		// 	Verifica se há inconsistência para o colaborador |
		// --------------------------------------------------+
		//Radu -Ajustado para a issue DSERGTP-7935 em 08/08/2022
		If !GTP409ColConf(cColab,dDiaRef,GYP->GYP_LINCOD,{"1","2","3"},@aRetLog )
			cSitRh := DeParaSitRh( aRetLog[1] )	
			cTpDia := NAO_TRABALHADO	
		Else	
			cSitRh := DISPONIVEL
			cTpDia := TRABALHADO
		EndIf
					
		//-- Retorna dia da Semana e/ou Feriado
		cDiaSemana :=  GetDiaSemana(cColab,dDiaRef,cSetor )

		IF n1 > 1
			oModelGYE:AddLine()
		EndIf
		
		//oModelGYE:LoadValue('GYE_STATUS'	,"1"			)
		oModelGYE:SetValue('GYE_COLCOD'	,cColab		)
		oModelGYE:SetValue('GYE_DTREF'	,dDiaRef		)
		oModelGYE:SetValue('GYE_DIASEM'	,cDiaSemana	)
		oModelGYE:SetValue('GYE_SITRH'	,cSitRh		)
		oModelGYE:SetValue('GYE_TPDIA'	,cTpDia		)					
		oModelGYE:SetValue('GYE_LEGEND'	,Ga303Legend(oModelGYE,.F.,'GYE')		)
		LoadGYP(oModel)
		dDiaRef++
	Next	
Endif	

If Len(aRetLog) == 2
	If !(Empty(aRetLog[2]))
		FWAlertHelp(aRetLog[2] )
	EndIf
EndIf
oModelGYE:GoLine(1)	

oModelGYE:SetNoInsertLine(.T.)
oModelGYE:SetNoDeleteLine(.T.)

TP303Totaliza()

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP303Totaliza()

Rotina responsavel em alimentar os campos totalizadores da alocação. A escala de linha da alocação 
é utilizada para buscar os sub-totalizadores.

@sample	TP303Totaliza()
@author	Inovação
@since		10/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP303Totaliza()

Local oModel     := FwModelActive()
Local oFieldGYQ  := oModel:GetModel("FIELDGYQ")
Local oFieldTOT  := oModel:GetModel("FIELDTOT")
Local cColab     := oFieldGYQ:GetValue("GYQ_COLCOD")
Local cFilMat    := Posicione("GYG",1,xFilial("GYG") + cColab, "GYG_FILSRA" )
Local oModelGYE  := oModel:GetModel("GRIDGYE")
Local nLinAtu    := oModelGYE:GetLine()
Local nHrExtra   := 0
Local nDSRUtiliz := 0
Local nHrsDia    := 0
Local nDSR       := 0
Local nCalc      := 0
Local nImpossib  := 0
Local nI         := 0
Local cMatric    := ""
Local cHrMensal  := ""
Local cIniHrVol  := "00000" 
Local nIniHrVol  := 0
Local cIniHrFVol := "00000"
Local nIniHrFVol := 0 
Local cIniHrPaga := "00000" 
Local nIniHrPaga := 0
Local cIniHrPlan := "00000" 
Local nIniHrPlan := 0
Local cIniHrADN  := "00000" 
Local nIniHrADN  := 0
Local cIniHrItPg := "00000"
Local nIniHrItPg := 0 

DbSelectArea("GYO") // Escala/Calendario/Agenda      
DbSetOrder(1) // GYO_FILIAL+GYO_CODIGO

	For nI := 1 To oModelGYE:Length()
	
		oModelGYE:GoLine(nI)

		// ------------------------------+
		// TOTALIZA QTDADE DSR UTILIZADOS|
		// ------------------------------+
		If oModelGYE:GetValue("GYE_SITRH") == DISPONIVEL .AND. (oModelGYE:GetValue("GYE_DIASEM") == "DOM" .Or. oModelGYE:GetValue("GYE_DIASEM") == "FER")
			nDSR += 1				
		EndIf
		//-- Retorna a Qtdade de DSR utilizado (Folga)
		If oModelGYE:GetValue("GYE_TPDIA") == DSR 
			nDSRUtiliz += 1					
		EndIf			
		//--Retorna a quantidade de dias impossibilitado de trabalhar
		If oModelGYE:GetValue("GYE_SITRH") <> DISPONIVEL
			nImpossib++
		Endif
		
		
		If GYO->( DbSeek(xFilial("GYO") + oModelGYE:GetValue("GYE_ESCALA") ) )
						
		// -----------------------+
		// TOTALIZA HORAS VOLANTE |
		// -----------------------+
			
			nIniHrVol := SomaHoras(Transform(GYO->GYO_HRVOL, "@R 99:99"),cIniHrVol)
			cIniHrVol := IIF(At(".",cValToChar(nIniHrVol)) > 0, StrTran(cValToChar(nIniHrVol),".",":"),cValToChar(nIniHrVol) + ":00")
		// -------------------------------+
		// TOTALIZA HORAS FORA DO VOLANTE |
		// -------------------------------+			
			
			nIniHrFVol := SomaHoras(Transform(GYO->GYO_HRFVOL, "@R 99:99"),cIniHrFVol)
			cIniHrFVol := IIF(At(".",cValToChar(nIniHrFVol)) > 0, StrTran(cValToChar(nIniHrFVol),".",":"),cValToChar(nIniHrFVol) + ":00")
		// -----------------------------------+
		// TOTALIZA HORAS TRABALHADAS/ PAGAS  |
		// -----------------------------------+			
			
			nIniHrPaga := SomaHoras(Transform(GYO->GYO_HORPAG, "@R 99:99"),cIniHrPaga)
			cIniHrPaga := IIF(At(".",cValToChar(nIniHrPaga)) > 0, StrTran(cValToChar(nIniHrPaga),".",":"),cValToChar(nIniHrPaga) + ":00")
		// ------------------------+
		// TOTALIZA HORAS PANTAO   |
		// ------------------------+			
			
			nIniHrPlan := SomaHoras(Transform(GYO->GYO_RHPLAN, "@R 99:99"),cIniHrPlan)
			cIniHrPlan := IIF(At(".",cValToChar(nIniHrPlan)) > 0, StrTran(cValToChar(nIniHrPlan),".",":"),cValToChar(nIniHrPlan) + ":00")
		// -----------------------------------+
		// TOTALIZA HORAS ADICIONAL/NOTURNO   |
		// -----------------------------------+			
			
			nIniHrADN := SomaHoras(Transform(GYO->GYO_HORAAD, "@R 99:99"),cIniHrADN)
			cIniHrADN := IIF(At(".",cValToChar(nIniHrADN)) > 0, StrTran(cValToChar(nIniHrADN),".",":"),cValToChar(nIniHrADN) + ":00")
			
		// -----------------------------------+
		// TOTALIZA HORAS INTERVALO PAGO   |
		// -----------------------------------+			
			
			nIniHrItPg := SomaHoras(Transform(GYO->GYO_HRDESP, "@R 99:99"),cIniHrItPg)
			cIniHrItPg := IIF(At(".",cValToChar(nIniHrItPg)) > 0, StrTran(cValToChar(nIniHrItPg),".",":"),cValToChar(nIniHrItPg) + ":00")
		EndIf
	Next

	oFieldGYQ:LoadValue("GYQ_DSRUTI", nDSRUtiliz )
	oFieldGYQ:LoadValue("GYQ_QTDDSR", nDSR)
	
	oFieldTOT:LoadValue("GYQ_DSRUTI", nDSRUtiliz )
	
	IF Val(cIniHrVol) > 1
		cIniHrVol	:= PADL(STRTRAN(cIniHrVol, ":", "") + If(Len(RIGHT(cIniHrVol,(Len(cIniHrVol) - At(":",cIniHrVol)))) < 2,"0",""),5,"0")
		oFieldGYQ:LoadValue("GYQ_HRVOLA", cIniHrVol)
		oFieldTOT:LoadValue("GYQ_HRVOLA", cIniHrVol)
	Else
		cIniHrVol := "00000"
		oFieldGYQ:LoadValue("GYQ_HRVOLA", cIniHrVol)
		oFieldTOT:LoadValue("GYQ_HRVOLA", cIniHrVol)
	EndIf

	IF Val(cIniHrFVol) > 1
		cIniHrFVol	:= PADL(STRTRAN(cIniHrFVol, ":", "") + If(Len(RIGHT(cIniHrFVol,(Len(cIniHrFVol) - At(":",cIniHrFVol)))) < 2,"0",""),5,"0")
		oFieldGYQ:LoadValue("GYQ_HRFVOL", cIniHrFVol )
		oFieldTOT:LoadValue("GYQ_HRFVOL", cIniHrFVol )
	Else
		cIniHrFVol := "00000"
		oFieldGYQ:LoadValue("GYQ_HRFVOL", cIniHrFVol )
		oFieldTOT:LoadValue("GYQ_HRFVOL", cIniHrFVol )
	EndIf

	IF Val(cIniHrPaga) > 1
		cIniHrPaga	:= PADL(STRTRAN(cIniHrPaga, ":", "") + If(Len(RIGHT(cIniHrPaga,(Len(cIniHrPaga) - At(":",cIniHrPaga)))) < 2,"0",""),5,"0")
		oFieldGYQ:LoadValue("GYQ_HRTRAB", cIniHrPaga)
		oFieldTOT:LoadValue("GYQ_HRTRAB", cIniHrPaga)
	Else
		cIniHrPaga := "00000"
		oFieldGYQ:LoadValue("GYQ_HRTRAB", cIniHrPaga)
		oFieldTOT:LoadValue("GYQ_HRTRAB", cIniHrPaga)
	EndIf

	IF Val(cIniHrPlan) > 1
		cIniHrPlan	:= PADL(STRTRAN(cIniHrPlan, ":", "") + If(Len(RIGHT(cIniHrPlan,(Len(cIniHrPlan) - At(":",cIniHrPlan)))) < 2,"0",""),5,"0")
		oFieldGYQ:LoadValue("GYQ_HRPLAN", cIniHrPlan )
		oFieldTOT:LoadValue("GYQ_HRPLAN", cIniHrPlan )
	Else
		cIniHrPlan := "00000"
		oFieldGYQ:LoadValue("GYQ_HRPLAN", cIniHrPlan )
		oFieldTOT:LoadValue("GYQ_HRPLAN", cIniHrPlan )
	EndIf
 
	IF Val(cIniHrADN) > 1
		cIniHrADN	:= PADL(STRTRAN(cIniHrADN, ":", "") + If(Len(RIGHT(cIniHrADN,(Len(cIniHrADN) - At(":",cIniHrADN)))) < 2,"0",""),5,"0")
		oFieldGYQ:LoadValue("GYQ_HRADN", cIniHrADN )
		oFieldTOT:LoadValue("GYQ_HRADN", cIniHrADN )
	Else
		cIniHrADN:= "00000"
		oFieldGYQ:LoadValue("GYQ_HRADN", cIniHrADN )
		oFieldTOT:LoadValue("GYQ_HRADN", cIniHrADN )
	EndIf

	//----------------------------------
	// TOTALIZADOR HRS MENSAIS         |
	//----------------------------------
	//-- Formula de calculo | Hrs de trabalho (Estimada) proporcional ao Nº de dias do Filtro
	// nQtdDias = Numero de dias aplicado pelo filtro.
	// nDSR = Numero de descanso equivalente ao nQtdDias.
	cMatric	:= Posicione('GYG',1,xFilial('GYG') + cColab, 'GYG_FUNCIO') 
	nHrsDia	:= Posicione('SRA',1,cFilMat + cMatric, 'RA_HRSDIA')
	If !Empty(oFieldGYQ:GetValue("GYQ_DTINI")) .or. !Empty(oFieldGYQ:GetValue("GYQ_DTFIM"))
		nQtdDias	:= DateDiffDay(oFieldGYQ:GetValue("GYQ_DTINI"), oFieldGYQ:GetValue("GYQ_DTFIM")) + 1
	Else
		nQtdDias	:= 0 
	Endif
	nDSR  := oFieldGYQ:GetValue("GYQ_QTDDSR")
	//Calcula a quantidade de horas * pelos dias trabalhados
	nCalc := IntToHora(Round(nHrsDia*(nQtdDias - nDSR - nImpossib),2))
	
	nCalc := PADL(STRTRAN(nCalc, ":", "") + If(Len(RIGHT(nCalc,(Len(nCalc) - At(":",nCalc)))) < 2,"0",""),5,"0")
	oFieldGYQ:LoadValue("GYQ_HRMENS", nCalc)

	cHrMensal := FwFldGet("GYQ_HRMENS")
	
	nHrExtra := SubHoras( Transform(cIniHrPaga, "@R 999:99"), Transform(cHrMensal, "@R 999:99"))
	
	If nHrExtra < 0 
		nHrExtra := 0
	EndIf
	
	//Valida se é necessário adicionar ":00" para formar a hora inteira
	nHrExtra := IIF(At(".",cValToChar(nHrExtra)) > 0, StrTran(cValToChar(nHrExtra),".",":"),cValToChar(nHrExtra) + ":00")
	//Adiciona um zero a direita nos minuto quando necessário e retira a string ":"
	nHrExtra := PADL(STRTRAN(nHrExtra, ":", "") + If(Len(RIGHT(nHrExtra,(Len(nHrExtra) - At(":",nHrExtra)))) < 2,"0",""),5,"0")
	oFieldGYQ:LoadValue("GYQ_HREXTR", nHrExtra )
	oFieldTOT:LoadValue("GYQ_HREXTR", nHrExtra )

	IF Val(cIniHrItPg) > 1
		cIniHrItPg	:= PADL(STRTRAN(cIniHrItPg, ":", "") + If(Len(RIGHT(cIniHrItPg,(Len(cIniHrItPg) - At(":",cIniHrItPg)))) < 2,"0",""),5,"0")
		oFieldGYQ:LoadValue("GYQ_HRDESP", cIniHrItPg )
		oFieldTOT:LoadValue("GYQ_HRDESP", cIniHrItPg )
	Else
		cIniHrItPg:= "00000"
		oFieldGYQ:LoadValue("GYQ_HRDESP", cIniHrItPg )
		oFieldTOT:LoadValue("GYQ_HRDESP", cIniHrItPg )
	EndIf
	
	oModelGYE:GoLine(nLinAtu)	

	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tp303AF3
Rotina que gera a tela da consulta específica GYOESC

@sample	Tp303AF3()

@return	Variável do tipo lógica, se a rotina consulta foi bem sucedida ou não

@author		Lucas.brustolin 
@author		Mick William da Silva
@version	P12
@since		09/10/2014
/*/
//------------------------------------------------------------------------------------------
Function Tp303AF3()

Local oModel 		:= FWModelActive()
Local oModelGYQ 	:= oModel:GetModel("FIELDGYQ")
Local oModelGYE 	:= oModel:GetModel( 'GRIDGYE' )
Local cColab		:= oModelGYQ:GetValue("GYQ_COLCOD")
Local dDtRef		:= oModelGYE:GetValue("GYE_DTREF")
Local oDlg			:= Nil
Local lRet			:=.T.
Local cTitulo		:= STR0009//"Selecione Escala"
Local cEscala		:=''
Local bOK			:= {||  __uRetBrw := IIF( Empty(aDadosCab[__oBrw1:nAt,1]) , "", aDadosCab[__oBrw1:nAt,1]) , oDlg:End() }
Local bCancel		:= {||  __uRetBrw := '', oDlg:End() }
Local nLarg			:= 0
Local nAltu			:= 0
Local aResolucao	:= FWGetDialogSize(oMainWnd)	
Local oLayer		:= FWLayer():new()
Local oPanel1		:= Nil
Local oPanel2		:= Nil

STATIC aTamGYO		:= {}
STATIC aTitGYO		:= {}
STATIC aTamGYP		:= {}
STATIC aTitGYP		:= {}
STATIC aDadosCab	:= {}
STATIC aDadosItm	:= {}

			
DEFINE MSDIALOG oDlg From aResolucao[1],aResolucao[2] TO aResolucao[3]* 1.0 ,aResolucao[4] * 1.0 PIXEL of oMainWnd TITLE cTitulo STYLE nOr(WS_VISIBLE,WS_POPUP)
	

oLayer:init(oDlg,.F.)

oLayer:addCollumn('Col01',25,.F.)
oLayer:addCollumn('Col02',75,.F.)
oLayer:addWindow('Col01','C1_Win01','Escala',90,.T.,.T.,Nil,,Nil) //'Alocação em Ocorrência'
oLayer:addWindow('Col02','C1_Win02','Det. Escala',90,.T.,.T.,Nil,,Nil) //'Alocação em Ocorrência'

oPanel1 := oLayer:GetWinPanel ('Col01', 'C1_Win01' ) 
oPanel2 := oLayer:GetWinPanel ('Col02', 'C1_Win02' ) 
		
RunProcGYO(aDadosCab,aTamGYO,aTitGYO,dDtRef,cColab)
		
nLarg := 135
nAltu := 150
		
__oBrw1 := TWBrowse():New( 035,010,Nil,Nil,,aTitGYO,,oPanel1,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)
__oBrw1:Align := CONTROL_ALIGN_ALLCLIENT
	
__oBrw1:SetArray(aDadosCab)
__oBrw1:aColSizes := aTamGYO
	
__oBrw1:lMChange := .F. // Nao deixar mudar tamanho das colunas.
__oBrw1:bLine :={|| aEval( aDadosCab[__oBrw1:nAt],{|z,w| aDadosCab[__oBrw1:nAt,w]})}
	
__oBrw1:bLDblClick := {||(__uRetBrw := aDadosCab[__oBrw1:nAt,1],oDlg:End())}
__oBrw1:bChange  := { ||(ChangeCab(aDadosItm,aTamGYP,aTitGYP,aDadosCab[__oBrw1:nAt,1]))}
__oBrw1:Refresh()
	
If len(aDadosCab) > 0
	cEscala	:= aDadosCab[__oBrw1:nAt,1]
EndIf
	
	
RunProcGYP(aDadosItm,aTamGYP,aTitGYP,cEscala)
		
nLarg := 400
nAltu := 150

__oBrw2 := TWBrowse():New( 035,150,Nil,Nil,,aTitGYP,,oPanel2,,,,,,,,,,,,.F.,,.T.,,.F.,,.T.,.T.)

__oBrw2:Align := CONTROL_ALIGN_ALLCLIENT

__oBrw2:SetArray(aDadosItm)
__oBrw2:aColSizes	:= aTamGYP
__oBrw2:bLine 		:= {|| aEval( aDadosItm[__oBrw2:nAt],{|z,w| aDadosItm[__oBrw2:nAt,w]})}
__oBrw2:bLDblClick	:= {||(__uRetBrw := IIF (Empty(aDadosCab[__oBrw1:nAt,1]),'',aDadosCab[__oBrw1:nAt,1]),oDlg:End())}
__oBrw2:lHScroll 	:= .T.
__oBrw2:lVScroll 	:= .T.
__oBrw2:Refresh()
	
	
oDlg:Refresh()

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , bOK , bCancel )
		

Return lRet

/*/{Protheus.doc} RunProcGYO
(long_description)
@type function
@author Mick William da Silva
@author Lucas.brustolin
@since 15/08/2017
@version 1.0
@param aDadosCab, array, Array onde serão inseridos os valores referentes à escala
@param aTamGYO, array, Array onde serão carregados os tamanhos dos campos
@param aTitGYO, array, Array onde serão carregados os títulos dos campos
@param dDtRef, data, (Descrição do parâmetro)
@param cColab, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function RunProcGYO(aDadosCab,aTamGYO,aTitGYO,dDtRef,cColab)
	
Local aArea         := GetArea()
Local oModel        := FWModelActive()
Local oModelGYE     := oModel:GetModel( 'GRIDGYE' )
Local aCpo          := {}
Local aPict         := {}
Local ni            := 0
Local nCpo          := 0
Local cAliasQry     := GetNextAlias()
Local uFieldValue   := nil
Local cQuery        := ""
Local cGrupoUsr     := ""
Local cTpRecur      := ""
Local aTamSx3       := {}

// DEFAULT cEscalOri := ""

cTpRecur	:= Posicione('GYG',1,xFilial('GYG') + cColab, 'GYG_RECCOD')
	
	cGrupoUsr := oModel:GetModel('FIELDGYQ'):GetValue('GYQ_GRPSET') 
	
	aDadosCab:={}
	aCpo	:= {"GYO_CODIGO","GYO_DESCRI"}
		
	ProcRegua(0)
	
	// Dados do Dicionario
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	
	For nI:=1 To Len(aCpo)
		IncProc(STR0029)//"Dados do Dicionário"
		If SX3->(dbSeek( aCpo[nI] ) )
            aTamSx3 := TamSx3(aCpo[nI])
			aAdd(aTitGYO    ,AllTrim(FWX3Titulo(aCpo[nI])))
            aAdd(aPict      ,AllTrim(GetSx3Cache(aCpo[nI], "X3_PICTURE") ))
		    aAdd(aTamGYO    ,CalcFieldSize(aTamSx3[3],aTamSx3[1],aTamSx3[2],GetSx3Cache(aCpo[nI], "X3_PICTURE") ,FWX3Titulo(aCpo[nI])))
		EndIf
	Next nI
	
	cQuery :=" SELECT DISTINCT GYO_CODIGO,GYO_DESCRI "
	cQuery += " FROM " + RetSQLName("GYO") + "  GYO "
	cQuery += " WHERE GYO.GYO_FILIAL = '"+xFilial('GYO')+"' AND GYO.D_E_L_E_T_=' ' "
	cQuery += " AND GYO.GYO_SETOR = '"+oModel:GetModel('FIELDGYQ'):GetValue('GYQ_SETOR')+"'"
	// Usuario ADM exibe todas as escalas independente do GRUPO 
	If __cUserID <> "000000" .AND. !Empty(cGrupoUsr)
		cQuery += " AND GYO.GYO_CODIGO IN( SELECT GZB_ESCALA FROM " + RetSQLName("GZB") + ""   
		cQuery += " GZB WHERE GZB.D_E_L_E_T_=' ' AND GZB_GRPCOD ='" + cGrupoUsr + "')  " 
	EndIf 
	
	dbUseArea (.T., "TOPCONN", TcGenQry (,,cQuery),cAliasQry, .T., .T.)
	
	If (cAliasQry)->(Eof())
		aAdd(aDadosCab,Array(Len(aCpo)))
		For nI := 1 To Len(aDadosCab)
			aDadosCab[1,nI] := TransForm(uFieldValue,aPict[nI])
		Next nI
	Else
		
		
		While (cAliasQry)->(!Eof())
			IncProc(STR0030)//"Preenchendo a grade"
			
			IF (TP303VlDia((cAliasQry)->GYO_CODIGO) .AND. ;
					 oModelGYE:GetValue("GYE_TPDIA") == TRABALHADO)	
							
				aAdd(aDadosCab,Array(Len(aCpo)))
				nCpo++
			
				For nI := 3 To Len(aDadosCab[nCpo])
					aDadosCab[nCpo,nI] := MsPadL(LTrim(TransForm(0.00,aPict[nI])),100)
				Next nI
			
			
			// Atribuição dos Valores aos Campos
			
				nI := 1 // Código da Escala
				uFieldValue := (cAliasQry)->(FieldGet(FieldPos(aCpo[nI])))
				aDadosCab[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
			
				nI := 2 // Descrição da Escala
				uFieldValue := (cAliasQry)->(FieldGet(FieldPos(aCpo[nI])))
				aDadosCab[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
			
				(cAliasQry)->(dbSkip())
			Else
			
				(cAliasQry)->(dbSkip())
			EndIf
		End
	EndiF
	
	(cAliasQry)->(dbCloseArea())
	
	IF EMPTY(aDadosCab)
		aAdd(aDadosCab,Array(Len(aCpo)))
		aDadosCab[1,1] := TransForm(uFieldValue,aPict[1])
		aDadosCab[1,2] := TransForm(uFieldValue,aPict[2])
	EndIf
	
	RestArea(aArea)
	GtpDestroy(aTamSx3)
Return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} RunProcGYP
Rotina que gera a estrutura e carrega os dados utilizados referêntes aos itens da escala.

@sample	RunProcGYP()
@param 	aDadosItm ,array,Array onde serão inseridos os valores referentes aos itens da escala
@param aTamGYP,array,  Array onde serão carregados os tamanhos dos campos - Itens
@param aTitGYP,array, Array onde serão carregados os títulos dos campos - Itens
@param cEscala,caracter,Código da Escala
@author		Lucas.brustolin
@author		Mick William da Silva
@since		20/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function RunProcGYP(aDadosItm,aTamGYP,aTitGYP,cEscala)
	
Local aArea			:= GetArea()
Local aCpo			:= {}
Local aPict		:= {}
Local ni			:= 0
Local nCpo			:= 0
Local cAliasQry2	:= GetNextAlias()
Local uFieldValue	:= nil

Default __oBrw2 		:= Nil
	
	aDadosItm	:= {}
	aTamGYP 	:= {}
	aTitGYP		:= {}
	
	aCpo	:= {"GYP_LINCOD","GYP_DESORI","GYP_HRINIT","GYP_HORORI","GYP_DESDES","GYP_HORDES","GYP_HRFIMT"}
		
	ProcRegua(0)
	
	// Dados do Dicionario
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	
	For nI:=1 To Len(aCpo)
		IncProc(STR0029)//Dados do Dicionário
		If SX3->(dbSeek( aCpo[nI] ) ) 
            aTamSx3 := TamSx3(aCpo[nI])
			aAdd(aTitGYP    ,AllTrim(FWX3Titulo(aCpo[nI])))
            aAdd(aPict      ,AllTrim(GetSx3Cache(aCpo[nI], "X3_PICTURE") ))
		    aAdd(aTamGYP    ,CalcFieldSize(aTamSx3[3],aTamSx3[1],aTamSx3[2],GetSx3Cache(aCpo[nI], "X3_PICTURE") ,FWX3Titulo(aCpo[nI])))
		EndIf
	Next nI
		
	BeginSQL Alias cAliasQry2	
		SELECT	GYP.GYP_FILIAL, 
				GYP.GYP_ESCALA, 
				GYP_ITEM, 
				GYP.GYP_LINCOD,
				GYP.GYP_SRVORI, 
				GI1ORI.GI1_DESCRI AS GYP_DESORI, 
				GYP.GYP_HRINIT,
				GYP.GYP_HORORI, 
				GI1DES.GI1_DESCRI AS GYP_DESDES,
				GYP.GYP_HORDES,
				GYP.GYP_HRFIMT
		FROM %Table:GYP% GYP
			LEFT JOIN %Table:GI1% GI1ORI ON 
				GI1ORI.GI1_FILIAL = %xFilial:GI1%
				AND GI1ORI.GI1_COD = GYP.GYP_SRVORI
				AND GI1ORI.%NotDel%
			LEFT JOIN %Table:GI1% GI1DES ON 
				GI1DES.GI1_FILIAL = %xFilial:GI1%
				AND GI1DES.GI1_COD = GYP.GYP_SRVDES
				AND GI1DES.%NotDel%
		WHERE 
			GYP.GYP_FILIAL = %xFilial:GYP%
			AND GYP.GYP_ESCALA = %Exp:cEscala%
			AND GYP.%NotDel%
		ORDER BY GYP_FILIAL,
			GYP.GYP_ESCALA,
			GYP.GYP_ITEM			
	EndSQL 
	
	If (cAliasQry2)->(Eof())
		aAdd(aDadosItm,Array(Len(aCpo)))
		For nI := 1 To Len(aDadosItm)
			aDadosItm[1,nI] := TransForm(uFieldValue,aPict[nI])
		Next nI
	EndIf	
	
	While (cAliasQry2)->(!Eof())
		IncProc(STR0030)//"Preenchendo a grade"
			
		aAdd(aDadosItm,Array(Len(aCpo)))
		nCpo++
		For nI := 6 To Len(aDadosItm[nCpo])
			aDadosItm[nCpo,nI] := MsPadL(LTrim(TransForm(0.00,aPict[nI])),100)
		Next nI
				
		// Atribuição dos Valores aos Campos
		
		nI := 1	// Código da linha
		uFieldValue := (cAliasQry2)->(FieldGet(FieldPos(aCpo[nI])))
		aDadosItm[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
		
		nI := 2 // Descricao da Origem
		uFieldValue := (cAliasQry2)->(FieldGet(FieldPos(aCpo[nI])))
		aDadosItm[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
		
		nI := 3 // Hora Inicio Trabalho
		uFieldValue := (cAliasQry2)->(FieldGet(FieldPos(aCpo[nI])))
		aDadosItm[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
		
		nI := 4 // Hora Origem
		uFieldValue := (cAliasQry2)->(FieldGet(FieldPos(aCpo[nI])))
		aDadosItm[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
		
		nI := 5 // Descrição Destino
		uFieldValue := (cAliasQry2)->(FieldGet(FieldPos(aCpo[nI])))
		aDadosItm[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
		
		nI := 6 // Hora Destino
		uFieldValue := (cAliasQry2)->(FieldGet(FieldPos(aCpo[nI])))
		aDadosItm[nCpo,nI] := TransForm(uFieldValue,aPict[nI])
		
		nI := 7 // Hora Final Trabalho
		uFieldValue := (cAliasQry2)->(FieldGet(FieldPos(aCpo[nI])))
		aDadosItm[nCpo,nI] := TransForm(uFieldValue,aPict[nI])

		(cAliasQry2)->(dbSkip())
	End
	(cAliasQry2)->(dbCloseArea())	
	
	RestArea(aArea)
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ChangeCab
Rotina que atualiza os itens da escala na consulta específica no momento em que troca de
linha na janela de escalas.

@sample		ChangeCab()

@author		Lucas.brustolin 
@author		Mick William da Silva
@since		20/08/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function ChangeCab(aDadosItm,aTamGYP,aTitGYP,cEscala)
	
	RunProcGYP(aDadosItm,aTamGYP,aTitGYP,cEscala)
	
	__oBrw2:SetArray(aDadosItm)
	__oBrw2:aColSizes := aTamGYP
						//"GYP_LINCOD"			  ,"GYP_DESORI"			   ,"GYP_HRINIT"			,"GYP_HORORI"			 ,"GYP_DESDES"				,"GYP_HORDES"			  ,"GYP_HRFIMT"			
	__oBrw2:bLine := { || { aDadosItm[ __oBrw2:nAT,1 ],aDadosItm[ __oBrw2:nAT,2 ],aDadosItm[ __oBrw2:nAT,3 ],aDadosItm[ __oBrw2:nAT,4 ], aDadosItm[ __oBrw2:nAT, 5 ],aDadosItm[ __oBrw2:nAT, 6 ],aDadosItm[ __oBrw2:nAT, 7 ]} }
	__oBrw2:Refresh()
		
Return .T.

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tp303ARtF3()
Rotina de retorno da consulta específica GYOESC

@sample	Tp303ARtF3()

@return	__uRetBrw - Retorno da consulta específica GYOESC

@author		Lucas.brustolin 
@author		Mick William da Silva
@since		20/08/2018
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function TP303ARTF3()
	
Return __uRetBrw


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDiaSemana
Rotina que verifica se o dia é feriado.

@author		Lucas.brustolin 
@author		Mick William da Silva
@since		24/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function GetDiaSemana(cColCod,dData, cSetor)
	
Local cDiaSemana 	:=	""
Local cFilSRA		:= Posicione("GYG",1,xFilial("GYG") + cColCod, "GYG_FILSRA" )
Local aFeriado		:= GTPxGetFer(dData, dData, cSetor,cFilSRA)
	
	If Len(aFeriado) == 0		
		cDiaSemana:= UPPER(substr(DIASEMANA(dData),1,3))
	Else
		cDiaSemana:= "FER"
	EndIf

GTPDestroy(aFeriado)	
Return( cDiaSemana )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPVLDPERF
Função que realiza as validações do colaborador de acordo com a Escala Informada.

@sample	GTPVLDPERF()
@param 	cEscala,caracter,Código de escala

@author		Mick William da SIlva
@since		18/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPVLDPERF(cEscala,cColab,cLocOri,cLocdes,cDtRefGYE)

Local cAliasGYE 	:= ''
Local cAliasGYP 	:= ''
Local cTpRecur		:= Posicione('GYG',1,xFilial('GYG') + cColab, 'GYG_RECCOD')
Local lRet 			:= .T.
Local aRetLog		:= {}

Default cLocOri 	:= ''
Default cLocdes 	:= ''
Default cDtRefGYE	:= ''



	// ----------------------------------------------------------------------------------+
	// Verifica se o Tipo de Recurso do usuário é o mesmo definido na Escala selecionada |
	// ----------------------------------------------------------------------------------+					
	If lRet .And. !Empty(cTpRecur)
		If cTpRecur <> Posicione("GYO",1,FwxFilial("GYO") + cEscala,"GYO_RECCOD")
			FwAlertHelp(STR0098) // "O tipo de recurso deste usuário não corresponde com o da escala."				
			lRet := .F.
		EndIf		
	EndIf

	
	// -------------------------------------------------------------------------------+
	// Validar se a escala já foi alocada para outro Colaborador na mesma Data. 	  |
	// -------------------------------------------------------------------------------+		
	IF lRet
		
		cAliasGYE 	:= GetNextAlias()
		
		BeginSQL Alias cAliasGYE
			SELECT GYE_ESCALA
			FROM %Table:GYE% GYE
			WHERE GYE_FILIAL = %xFilial:GYE%
			AND GYE_ESCALA = %Exp:cEscala%
			AND GYE_COLCOD <> %Exp:cColab%
			AND GYE_DTREF = %Exp:cDtRefGYE%
			AND %NotDel%
		EndSQL
									
		IF !(cAliasGYE)->(EOF())
		
			FWAlertHelp(STR0101)//"Escala já alocada para outro Colaborador na mesma Data."
			lRet := .F.
			
		EndIf			
		(cAliasGYE)->(DbCloseArea())
		
	EndIf
	
	// ---------------------------------------------------------------------------------------------------------------------+
	// Valida se o colaborador/ funcionário possui todos os requisitos obrigatórios (GYM_OBG = 1) para a execução da linha; |
	// BLOCO DE VALIDAÇÃO DO PERFIL DE ALOCAÇÃO - CURSO/TURNO/CARGO/FUNÇÃO/HABILIDADE                                       | 
	// ---------------------------------------------------------------------------------------------------------------------+		
	
	IF lRet
		cAliasGYP 	:= GetNextAlias()
		
		BeginSQL Alias cAliasGYP
			SELECT 
				DISTINCT GYP_LINCOD
			FROM 
				%Table:GYP% GYP
			INNER JOIN 
				%Table:GYM% GYM
			ON
				GYP_FILIAL = GYM_FILIAL
				AND GYM_CODENT = GYP_LINCOD
				AND GYM_OBG = '1'
				AND GYM_RECCOD = %Exp:cTpRecur%
				AND GYM.%NotDel%
			WHERE 
				GYP_FILIAL = %xFilial:GYP%
				AND GYP_ESCALA	= %Exp:cEscala%
				AND GYP.%NotDel%
		EndSQL
		
		While !(cAliasGYP)->(EOF())
		
			IF !GTP409ColConf(cColab,,(cAliasGYP)->GYP_LINCOD,,@aRetLog)
				FWAlertHelp(aRetLog[2], aRetLog[3] )
				lRet := .F.
			EndIf
				
			(cAliasGYP)->(dbSkip())
		EndDo			
			
		
	EndIf
						
		
Return (lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP303VlDia
Rotina que valida se o dia selecionado está compatível com os dias disponíveis
na tabela de escalas e horários

@sample	TP303VlDia()

@return	retorna um valor lógico conforme disponibilidade do dia

@author		Lucas.brustolin 
@author		Mick William da Silva
@since		06/08/2017
@version	P12
/*/
//-------------------------------------------------------------------------------------------
Function TP303VlDia(cEscala,oModel)

Local oModelGYE 		:= nil
Local cDiaSemana 		:= ""
Local lRet				:= .T.

Default oModel			:= FWModelActive()
	oModelGYE 		:= oModel:GetModel( 'GRIDGYE' )
	cDiaSemana := UPPER(substr(DIASEMANA(oModelGYE:GetValue('GYE_DTREF')),1,3)) 	
	
	lRet := Posicione("GYO",1,xFilial('GYO')  + cEscala ,'GYO_'+cDiaSemana) 
	
Return (lRet)

//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TPValidEscala
Valida o preenchimento do campo escala.
@sample		TPValidEscala()
@author		Lucas.brustolin
@since		20/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function TPValidEscala(oModel)

Local oModelGYE 	:= oModel:GetModel( 'GRIDGYE' )
Local oModelGYQ 	:= oModel:GetModel( 'FIELDGYQ' )
Local cColab	 	:= oModelGYQ:GetValue("GYQ_COLCOD")
Local cDtRefGYE		:= DtoS(oModelGYE:GetValue('GYE_DTREF'))

Local lRet 			:= .T.
		
		
	If (lRet := ExistCpo("GYO", oModelGYE:GetValue('GYE_ESCALA')  ))
			
		// Valida se os dias estão disponíveis p/ essa escala e se o perfil do colaborador é compatível
		If !TP303VlDia(oModelGYE:GetValue('GYE_ESCALA'),oModel) 
			oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","TPValidEscala", STR0102)//"A data referência não confere com a frequência da escala!"
			lRet := .F.
		EndIf
		If lRet .And. !GTPVLDPERF( oModelGYE:GetValue('GYE_ESCALA') ,cColab,,,cDtRefGYE) 
			oModelGYE:ClearField('GYE_ESCALA')
		EndIf
			
	EndIf

	
	
Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP303XBFL()
Filtro para Grupo de Escala.
O Usuário logado só poderá ver os colaboradores que fazem parte do seu Grupo de Escala
@sample	TP303XBFL()
@return cYGFilter - Retorna o(s) Código(s) dos Colaboradores para o Filtro em sql
@author		Mick William da Silva
@since		08/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function TP303XBFL()
Local oModel	:= FwModelActive()
Local cMdlId	:= oModel:GetId()
Local cRet  	:= "@"
Local cCampo	:= ""
Local cCpoWhere	:= ""
Local cCpoFil   := ""
Local cAliasAux	:= ""
	
If cMdlId == 'GTPA303'
	If !Empty(oModel:GetModel('FIELDGYQ'):GetValue('GYQ_GRPSET'))
		cAliasAux := "GYI"
		cCampo	  := cAliasAux+".GYI_COLCOD"
		cCpoFil	  := cAliasAux+".GYI_FILIAL"
		cCpoWhere := cAliasAux+".GYI_GRPCOD"
		cConteudo := oModel:GetModel('FIELDGYQ'):GetValue('GYQ_GRPSET')
	Else
		cAliasAux := "GY2"
		cCampo	  := cAliasAux+".GY2_CODCOL"
		cCpoFil	  := cAliasAux+".GY2_FILIAL"
		cCpoWhere := cAliasAux+".GY2_SETOR"
		cConteudo := oModel:GetModel('FIELDGYQ'):GetValue('GYQ_SETOR')
	Endif
	
	cRet += "GYG_CODIGO IN ("
	cRet += "SELECT "+cCampo+" "
	cRet += "FROM "+RetSqlName(cAliasAux)+" "+cAliasAux+" "
	cRet += "WHERE "+cCpoFil+" = '"+xFilial(cAliasAux)+"' and "
	cRet += cCpoWhere+" = '"+cConteudo+"' and "
	cRet += cAliasAux+".D_E_L_E_T_ = ' '"	
	cRet += ")"
Endif

Return(cRet)


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP303GY8FIL()
Filtro para Sequencia de Esquema.
Só poderá ser visualizado a Sequencia de acordo com o código do Esquema informado.

@sample	TP303GY8FIL()


@return lRet - Retorna True ou False.

@author		Mick William da Silva
@since		10/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Function TP303GY8FIL()

Local oModel	:= FWModelActive()
Local oModelGYQ	:= oModel:GetModel("FIELDGYQ")
Local cCodEsq	:= oModelGYQ:GetValue("GYQ_ESQUEM")
Local lRet 		:= .T.

	
	IF GY8->GY8_CODIGO == cCodEsq
		lRet := .T.
	Else
		lRet := .F.
	EndIf

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeParaSitRh()

Realiza o DePara do do código do conflito x GYE_SITRH - Situação do colaborador no RH
Retornando a opção correspondente.

@sample	DeParaSitRh()
@author		Lucas.Brustolin
@since		10/08/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function DeParaSitRh(cCodErro)

Local cSitRh := "" // CBOX GYE_SITRH
Do Case
		Case cCodErro == "0" //DEMITIDO
			cSitRh := NAOADIMITIDO	
		Case cCodErro == "1" //DEMITIDO
			cSitRh := DEMITIDO	
		Case cCodErro == "2" //AFASTADO
			cSitRh := AFASTADO
		Case cCodErro == "3" //FERIAS
			cSitRh := FERIAS	
		Otherwise
			cSitRh := DISPONIVEL
EndCase

Return(cSitRh)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP303TudOk()
Rotina de validação do modelo

@sample	TP303TudOk(oModel)

@param oModel 	Objeto Model

@return		 lRet = .T. ou .F.
@Author		lucas.brustolin
@author		Mick William da Silva
@since		21/08/2017
@version	P12
/*/
//-------------------------------------------------------------------------------------------

Static Function TP303TudOk(oModel)
 
Local nOperation:= oModel:GetOperation()
Local oModelGYE	:= oModel:GetModel("GRIDGYE")
Local dDtRef	:= CTOD("  /  /    ")
Local n1 		:= 0
Local lRet		:= .T.
	
	
If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 
	
	//Valida se o periodo informado é valido
	lRet := Ga303VldDt(oModel)
	
	//------------------------------------------+
	// CONSISTE OS TRECHOS DA ESCALA X HORÁRIOS |
	//------------------------------------------+	
	If lRet  
		For n1 := 1 To oModelGYE:Length()
			dDtRef		:= oModelGYE:GetValue("GYE_DTREF",n1) 
			cEscalaAtu	:= oModelGYE:GetValue("GYE_ESCALA", n1)
			If !Empty( cEscalaAtu )
				If !VLDGYPTOGIE(dDtRef, cEscalaAtu)
					//oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","TP303TOK02",STR0111,STR0112 + cEscalaAtu )//"Foi encontrado inconsistência entre os trechos Escala x Horários." "Atualize a escala: "
					Help( ,, 'TP303TOK02','',STR0111+chr(13)+Chr(10)+STR0112+ cEscalaAtu +" do dia: "+DtoC(dDtRef), 1, 0 )
					lRet := .F.
					Exit
				EndIf
				If	GTPX3CON(,,,,dDtRef,.F. /*lShow*/,cEscalaAtu) 
					//oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","TP303TOK03",STR0113,STR0114 + cEscalaAtu)//"Foi encontrado inconsistência entre os trechos Horário x Viagem." "Atualize a viagem para a escala: "
					Help( ,, 'TP303TOK03','',STR0113+chr(13)+Chr(10)+STR0114, 1, 0 )
					lRet := .F.
					Exit
				EndIf 
			EndIf 
		Next n1
	EndIf 

	//------------------------------------------+
	// CONSISTE AS LOCALIDADES ENTRE AS ESCALAS |
	//------------------------------------------+		
	If lRet .And. !VldLocToEsc(oModel)
		//oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","TP303TOK04",STR0115,STR0116)//"Localidade final da escala é diferente à localidade inicial da escala do dia a ser atribuído!." "Corrigir a Escala do Colaborador."
		Help( ,, 'TP303TOK04','',STR0115+chr(13)+Chr(10)+STR0116, 1, 0 )//"Localidade final da escala é diferente à localidade inicial da escala do dia a ser atribuído!." "Corrigir a Escala do Colaborador."
		lRet := .F.
	EndIF

EndIf 

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VldLocToEsc()
Validar se a localidade final da escala do dia anterior (GYP_SRVDES) é igual à 
localidade inicial escala a ser atribuída (GYP_SRVORI)

@Return lRet
@author		Mick William da Silva
@since		11/08/2017
@version	P12

/*/
//------------------------------------------------------------------------------------------
Static Function VldLocToEsc(oModel)

Local oModelGYQ	:= oModel:GetModel("FIELDGYQ")
Local oModelGYE	:= oModel:GetModel("GRIDGYE")
Local cColab	:= oModelGYQ:GetValue("GYQ_COLCOD")
Local dDtIni	:= oModelGYQ:GetValue("GYQ_DTINI")
Local nOperation:= oModel:GetOperation()
Local cAliasQry	:= ""
Local cAliasEsc	:= ""
Local cAliasAnt	:= ""
Local cAliasGQE	:= ""
Local cPriEsc	:= ""
Local cEscOri	:= ""
Local cORIEsc	:= ""
Local cDESEsc	:= ""
Local lRet		:= .T.
Local lPrim 	:= .T.
Local lVerif	:= .T.
Local nM		:= 0

	For nM := 1 To oModelGYE:Length()
		oModelGYE:GoLine(nM)
		IF !Empty(	oModelGYE:GetValue("GYE_ESCALA")	) .and. lPrim
			lPrim := .F.
			
			cAliasEsc := GetNextAlias()
			BeginSQL Alias cAliasEsc
			
				SELECT 
					GYPORI.GYP_SRVORI AS GYP_SRVORI,
					GYPDES.GYP_SRVDES AS GYP_SRVDES
				FROM (SELECT 
						GYP.GYP_FILIAL,
						GYP.GYP_ESCALA,
						MIN(GYP.GYP_ITEM) AS MINITEM,
						MAX(GYP.GYP_ITEM) AS MAXITEM
					FROM %Table:GYP% GYP
					WHERE
						GYP.GYP_FILIAL = %xFilial:GYP%
						AND GYP.GYP_ESCALA = %Exp:oModelGYE:GetValue("GYE_ESCALA")%   
						AND GYP.%NotDel%
					GROUP BY GYP.GYP_FILIAL,GYP.GYP_ESCALA
					) MINMAX 
					INNER JOIN %Table:GYP% GYPORI ON
						GYPORI.GYP_FILIAL = MINMAX.GYP_FILIAL
						AND GYPORI.GYP_ESCALA= MINMAX.GYP_ESCALA
						AND GYPORI.GYP_ITEM = MINMAX.MINITEM
						AND GYPORI.%NotDel%
					INNER JOIN %Table:GYP% GYPDES ON
						GYPDES.GYP_FILIAL = MINMAX.GYP_FILIAL
						AND GYPDES.GYP_ESCALA= MINMAX.GYP_ESCALA
						AND GYPDES.GYP_ITEM = MINMAX.MAXITEM
						AND GYPDES.%NotDel%
			EndSql
			
			IF !(cAliasEsc)->(EOF())
				cPriEsc := (cAliasEsc)->GYP_SRVDES
				cEscOri := (cAliasEsc)->GYP_SRVORI
			EndIf
					
			(cAliasEsc)->(DbCloseArea())
			
			//Verifica se já existe alocação, e pega a Escala da Ultima data informado. Será necessário Começar a partir da destino da alocação anterior.  
			IF lVerif .AND. nOperation<>MODEL_OPERATION_UPDATE
				cAliasAnt := GetNextAlias()
				BeginSQL Alias cAliasAnt
					SELECT 
						GYE_ESCALA, 
						GYE_DTREF
					FROM %Table:GYE% GYE
						INNER JOIN (SELECT
										MAX(GYE_DTREF) DT
									FROM %Table:GYE% GYE
									WHERE
										GYE_FILIAL = %xFilial:GYE%
										AND GYE_COLCOD = %Exp:cColab%
										AND GYE_DTREF < %Exp:dDtIni%
										AND GYE.%NotDel%
						) AS DTMAX ON
							GYE.GYE_DTREF = DTMAX.DT
					WHERE
						GYE_FILIAL = %xFilial:GYE%
						AND GYE_COLCOD = %Exp:cColab%
						AND GYE.GYE_ESCALA <> %Exp:Space(TamSx3('GYE_ESCALA')[1])%
						AND GYE.%NotDel%

				EndSql
				
				IF !(cAliasAnt)->(EOF()) .and. !Empty((cAliasAnt)->GYE_ESCALA)
					//Maior Sequencia, Destino da Viagem
					cAliasQry := GetNextAlias()
						
					BeginSQL Alias cAliasQry
						SELECT 
							GYP_SRVDES 
						FROM %Table:GYP% GYP
							Inner Join (SELECT MAX(GYP_ITEM) AS MAXITEM
										FROM %Table:GYP% GYP 
										WHERE
											GYP.GYP_FILIAL = %xFilial:GYP%
											AND GYP.GYP_ESCALA =  %Exp:(cAliasAnt)->GYE_ESCALA%
											AND GYP.%NotDel%
							) MAXITEM ON
								MAXITEM.MAXITEM = GYP.GYP_ITEM
								
						WHERE
							GYP.GYP_FILIAL = %xFilial:GYP%
							AND GYP_ESCALA =  %Exp:(cAliasAnt)->GYE_ESCALA%
							AND GYP.%NotDel%
						
					EndSql
					
					IF !(cAliasQry)->(EOF())
						
						cAliasGQE := GetNextAlias()
						
						BeginSQL Alias cAliasGQE
							Select G55_LOCDES
							From %Table:G55% G55
								INNER JOIN (
											SELECT 
												GQE_FILIAL,
												GQE_VIACOD,
												MAX(GQE_SEQ) AS MAXSEQ
											FROM %Table:GQE% GQE  
												INNER JOIN %Table:G55% G55 ON
													G55.G55_FILIAL = GQE.GQE_FILIAL
													AND G55.G55_CODVIA 	= GQE.GQE_VIACOD
													AND G55.G55_SEQ  = GQE.GQE_SEQ							
													AND G55.%NotDel%
												INNER JOIN %Table:GYN% GYN ON
													GYN.GYN_FILIAL = GQE.GQE_FILIAL
													AND GYN.GYN_CODIGO 	= GQE.GQE_VIACOD
													AND GYN.GYN_FINAL = '1'
													AND GYN.%NotDel%
											WHERE  
												GQE.GQE_FILIAL = %xFilial:GQE%
												AND GQE.GQE_RECURS = %Exp:cColab%
												AND GQE.GQE_DTREF >	%Exp:(cAliasAnt)->GYE_DTREF%
												AND GQE.GQE_TRECUR = '1'					
												AND GQE.%NotDel% 
											Group by GQE_FILIAL,GQE_VIACOD
								) AS MAXSEQ ON
									G55.G55_FILIAL = MAXSEQ.GQE_FILIAL
									AND G55.G55_CODVIA = MAXSEQ.GQE_VIACOD
									AND G55.G55_SEQ = MAXSEQ.MAXSEQ
							WHERE
								G55.G55_FILIAL = %xFilial:GQE%
								AND G55.%NotDel% 			
						EndSql
						
						IF !(cAliasGQE)->(EOF())
							IF  (cAliasGQE)->G55_LOCDES <> (cAliasQry)->GYP_SRVDES .AND. (cAliasGQE)->G55_LOCDES <> cEscOri
														
								IF  (cAliasQry)->GYP_SRVDES <> cEscOri
									lRet := .F. 
									Exit
								EndIf	
							EndIf
						Else
							IF  (cAliasQry)->GYP_SRVDES <> cEscOri
								lRet := .F. 
								Exit
							EndIf	
						
						Endif
						(cAliasGQE)->(DbCloseArea())
						
					EndIF
					(cAliasQry)->(DbCloseArea())
				EndIf
				
				lVerif := .F. 
				(cAliasAnt)->(DbCloseArea())
			EndIF
			
		ElseIF !Empty(	oModelGYE:GetValue("GYE_ESCALA")	)
			
			//Maior Sequencia, Destino da Viagem
			cAliasQry := GetNextAlias()
				
			BeginSQL Alias cAliasQry
				
				SELECT 
					GYPORI.GYP_SRVORI AS GYP_SRVORI,
					GYPDES.GYP_SRVDES AS GYP_SRVDES
				FROM (SELECT 
						GYP.GYP_FILIAL,
						GYP.GYP_ESCALA,
						MIN(GYP.GYP_ITEM) AS MINITEM,
						MAX(GYP.GYP_ITEM) AS MAXITEM
					FROM %Table:GYP% GYP
					WHERE
						GYP.GYP_FILIAL = %xFilial:GYP%
						AND GYP.GYP_ESCALA = %Exp:oModelGYE:GetValue("GYE_ESCALA")%   
						AND GYP.%NotDel%
					GROUP BY GYP.GYP_FILIAL,GYP.GYP_ESCALA
					) MINMAX 
					INNER JOIN %Table:GYP% GYPORI ON
						GYPORI.GYP_FILIAL = MINMAX.GYP_FILIAL
						AND GYPORI.GYP_ESCALA= MINMAX.GYP_ESCALA
						AND GYPORI.GYP_ITEM = MINMAX.MINITEM
						AND GYPORI.%NotDel%
					INNER JOIN %Table:GYP% GYPDES ON
						GYPDES.GYP_FILIAL = MINMAX.GYP_FILIAL
						AND GYPDES.GYP_ESCALA= MINMAX.GYP_ESCALA
						AND GYPDES.GYP_ITEM = MINMAX.MAXITEM
						AND GYPDES.%NotDel%
			EndSql
			
			IF !(cAliasQry)->(EOF())
				IF !Empty(cPriEsc) .And. cPriEsc <> (cAliasQry)->GYP_SRVORI				
					IF !Empty( oModelGYE:GetValue("GYE_ESCALA",nM-1) ) .Or. oModelGYE:GetValue("GYE_TPDIA",nM-1) <> '1'
						lRet := .F. 
						Exit
					EndIf
				Else
					cPriEsc:= ''
					IF !Empty(cDESEsc) .And. (cAliasQry)->GYP_SRVORI <> cDESEsc
						IF !Empty( oModelGYE:GetValue("GYE_ESCALA",nM-1) ) .Or. oModelGYE:GetValue("GYE_TPDIA",nM-1) <> '1'
							lRet := .F. 
							Exit
						EndIf
					EndIf
				
				EndIf
				cORIEsc := (cAliasQry)->GYP_SRVORI
				cDESEsc := (cAliasQry)->GYP_SRVDES
			EndIf
			(cAliasQry)->(DbCloseArea())
		EndIf
	Next nM

Return(lRet)


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VLDGYPTOGIE
Rotina responsavél em avaliar se os trechos da escala estão desatualizados comparado 
aos trechos do cadastro de horários;
Verifica a frequência (Se o dia da semana (dDtRef) em que está sendo alocado é permitido pela frequencia.)
Verifica a localidade e horário entre os trechos.
@param		dDtRef - Data de alocação, usada para avaliar o dia da semana(seg/ter/qua...)
@param		cEscala - Código da escala para avaliar os trechos.
@return		lPlanejOk .T. Se planejamento está valido ou .F. caso contrário.
@sample		VLDGYPTOGIE()
@author		Lucas.brustolin
@since		20/08/2017
@version	P12
/*/
//--------------------------------------------------------------------------------------------------------

Static Function VLDGYPTOGIE(dDtRef, cEscala )  

Local cAliasTmp	:= ""
Local cDiaSemana	:= "GID_"+UPPER(SubStr( DiaSemana(dDtRef), 1, 3) )
Local cDiaRef		:= ""
Local lRet			:= .T.

If !Empty( cEscala )
	
	cAliasTmp := GetNextAlias()
	
	BeginSql alias cAliasTmp
	
		SELECT GID_SEG,
				GID_TER,
				GID_QUA,
				GID_QUI,
				GID_SEX,
				GID_SAB,
				GID_DOM,
				GIE_SEQ,
				GIE_DIA,
				GIE_HORLOC,
			 	GIE_IDLOCP,
			 	GIE_IDLOCD,
			 	GIE_HORDES,
			 	GYP_HORORI,
			 	GYP_SRVORI,
			 	GYP_SRVDES,
			 	GYP_HORDES 
		FROM %Table:GYP% GYP
			INNER JOIN %Table:GID% GID ON
				GID.GID_FILIAL = %xFilial:GID% AND
				GID.%NotDel% AND
				GID.GID_HIST = '2' AND
				GID.GID_COD = GYP.GYP_CODGID
			INNER JOIN %Table:GIE% GIE ON
				GIE.GIE_FILIAL = %xFilial:GIE% AND
				GIE.%NotDel% AND
				GIE.GIE_HIST = '2' AND
				GIE.GIE_CODGID = GID.GID_COD AND
				GIE.GIE_SEQ = GYP.GYP_SEQ
				
		WHERE
			GYP.GYP_FILIAL = %xFilial:GYP% AND
			GYP.%NotDel% AND
			GYP.GYP_ESCALA = %Exp:cEscala%

	EndSql
	
	(cAliasTmp)->(dbGotop())
	
	While (cAliasTmp)->(!Eof())
	
		cDiaRef	:= "GID_"+UPPER(SubStr( DiaSemana(dDtRef - (cAliasTmp)->GIE_DIA), 1, 3) )		
		
		lRet := ((cAliasTmp)->GIE_HORLOC == (cAliasTmp)->GYP_HORORI .And.;
				 (cAliasTmp)->GIE_IDLOCP == (cAliasTmp)->GYP_SRVORI .And.;
				 (cAliasTmp)->GIE_IDLOCD == (cAliasTmp)->GYP_SRVDES .And.;
				 (cAliasTmp)->GIE_HORDES == (cAliasTmp)->GYP_HORDES)
				 
		If lRet
		
			If (cAliasTmp)->GIE_SEQ == '0001' .And. (cAliasTmp)->&(cDiaSemana) == 'F'
			
				lRet := .F.
				
				Exit
				
			Endif
		
		Endif		
		
		
		If lRet
		
			If (cAliasTmp)->GIE_SEQ > '0001' .And. ((cAliasTmp)->&(cDiaSemana) == 'F' .And. (cAliasTmp)->&(cDiaRef) == 'F')
			
				lRet := .F.
				
				Exit
				
			Endif
		
		Endif 
				  
		If !lRet
			Exit
		Endif	

		(cAliasTmp)->( DbSkip())
	
	EndDo
	
	(cAliasTmp)->( DbCloseArea() )

EndIf
			
Return( lRet )


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP303Commit()
Realiza a gravação das escalas.

@sample	TP303Commit(cCkb)

@param	oModel		Objeto Model	
@return	

@author		Lucas.brustolin 
@since		15/08/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------
Static Function TP303Commit(oModel)

Local nOperation	:= oModel:Getoperation()
Local cMsg			:= "" 
Local lOk			:= .T.

If nOperation == MODEL_OPERATION_INSERT
	cMsg := "Aplicando alocação..."
ElSeIf nOperation == MODEL_OPERATION_UPDATE
	cMsg := "Atualizando alocação..."
ElseIf nOperation == MODEL_OPERATION_DELETE
	cMsg := "Excluindo alocação..."
EndIf 

	Processa( { || lOk := TP303GRAVA( oModel, nOperation ) } , 'Aguarde', cMsg, .F. )

Return (lOk) 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP303GRAVA
Efetiva a gravação da alocação relacionando (Inclui/Alterando/Deletando)
o recurso (Colaborador) aos trechos da viagem.
@sample	TP303GRAVA(oModel)
@param	oModel		Objeto Model	
@return	
@author		Lucas.brustolin 
@since		15/08/2017
@version	P12
/*/
//-----------------------------------------------------------------------------------------

Static Function TP303GRAVA(oModel,nOperation)

Local oMdlGYQ		:= oModel:GetModel("FIELDGYQ")
Local oMdlGYE		:= oModel:GetModel("GRIDGYE")
Local oMdlGYP		:= oModel:GetModel("GRIDGYP")
Local oModel303a	:= FwLoadModel('GTPA303A')
Local oModel313		:= FwLoadModel('GTPA313')
Local oGTPLog		:= GTPLog():New("Alocação de Colaboradores")
Local lAlocado		:= .F.
Local lEscalado		:= .F.
Local lForce		:= .F.
Local n1			:= 0
Local n2			:= 0
Local lFinalizado	:= .T.
Local lRet 		:= .T.
Local aArea		:= GetArea()

Begin Transaction 
	
	
	If oMdlGYE:Length() > 0	
	
		ProcRegua( oMdlGYE:Length() )
		For n1 := 1 To oMdlGYE:Length()
			lAlocado	:= .F.
			lEscalado	:= .F.
			oMdlGYE:GoLine(n1)
			IncProc()
			//Não realocar caso a alocação estiver efetivada, em qualquer outro cenário pode ser que possua escalas deletadas ou é uma exclusão da alocação
			If oMdlGYE:GetValue('GYE_STATUS') <> '2' .OR. oModel:GetOperation() == MODEL_OPERATION_DELETE .or. oMdlGYP:IsDeleted()
				For n2 := 1 to oMdlGYP:Length()
					oMdlGYP:GoLine(n2)
					If !Empty(oMdlGYP:GetValue('GYP_ITEM'))
						If oMdlGYP:GetValue('GQK_TPDIA') == TRABALHADO .AND. oMdlGYP:GetValue('GYP_TIPO') <> '2'
							IF !Empty(oMdlGYP:GetValue('GYN_CODIGO')) //Caso a Viagem exista, alocar o colaborador para essa viagem
								//Caso Remanejado Operacionalmente, não fará nada, se não, efetua a alocação
								If oMdlGYP:GetValue('GYP_STATUS') == '4' .Or. CommitAloc(oMdlGYP,oModel303a,oGTPLog)
									lAlocado := .T.
								Else
									If oModel:GetOperation() == MODEL_OPERATION_DELETE .or. oMdlGYP:IsDeleted()
										lForce := .T.
									Endif
									
									lEscalado:= .T.
								Endif 
							ENDIF
						ELSE
							//Caso Remanejado Operacionalmente, não fará nada, se não, efetua a alocação
							If oMdlGYP:GetValue('GYP_STATUS') == '4' .Or. CommitPlan(oModel,oModel313,oGTPLog)
								lAlocado := .T.
							Else
								If oModel:GetOperation() == MODEL_OPERATION_DELETE .or. oMdlGYP:IsDeleted()
									lForce := .T.
								Endif
								
								lEscalado:= .T.
							Endif 
						ENDIF
					Endif
					If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE 	
						//Conforme os dados da GYP, Atualiza o status da gye
						If oMdlGYE:GetValue('GYE_STATUS') $ "3/4"
							If lAlocado .and. !lEscalado
								oMdlGYE:SetValue('GYE_STATUS','2') //Efetivado
							Elseif lAlocado .and. lEscalado
								oMdlGYE:SetValue('GYE_STATUS','3') //Alocado parcialmente
							Else
								oMdlGYE:SetValue('GYE_STATUS','4') //Escalado
							Endif
						Endif
						If oMdlGYE:GetValue('GYE_STATUS') $ "1/3/4"
							lFinalizado := .F.
						Endif
					Endif
				
				Next
			Endif
		Next
		If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. oModel:GetOperation() == MODEL_OPERATION_UPDATE
			If lFinalizado
				oMdlGYQ:SetValue('GYQ_STATUS','2')
			Else
				oMdlGYQ:SetValue('GYQ_STATUS','1')
			Endif
		Endif
		
		
		If oGTPLog:HasInfo()
			oGTPLog:ShowLog()
			If !lForce .and. FwAlertYesNo('Houve erros em alguma alocação, deseja salvar mesmo assim? ',"Atenção!!")
				lRet := .T.
			Else
				oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,"TP303GRAVA","Processo interrompido com sucesso")
				lRet := .F.
			Endif
		Endif
		
		oGTPLog:Destroy()

		//---------------------------------------------------+
		// EFETIVA O PROCESSO DE ALOCAO DO RECURSO           |
		// Caso tenha tido falha em alguma alocação          |
		// o usuário poderá aceitar se deve continuar ou não |
		// o processo de finalização                         |
		//---------------------------------------------------+	
		If lRet 
			If oModel:Vlddata()
				FwFormCommit(oModel)			
			Else
				JurShowErro( oModel:GetModel():GetErrormessage() )
				DisarmTransaction()
				lRet := .F.
			EndIf
		Else
			DisarmTransaction()
		Endif
	EndIf 
End Transaction
oModel303a:Destroy()
oModel313:Destroy()
RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} CommitAloc
(long_description)
@type function
@author jacomo.fernandes
@since 01/11/2017
@version 1.0
@param oMdlGYP, objeto, (Descrição do parâmetro)
@param oModel303a, objeto, (Descrição do parâmetro)
@param oGTPLog, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CommitAloc(oMdlGYP,oModel303a,oGTPLog)
Local oModel	:= oMdlGYP:GetModel()
Local oMdlGQE	:= oModel303a:GetModel('FIELD_GQE')
Local lRet		:= .T.
Local cErro		:= ""
Local cViagem	:= oMdlGYP:GetValue('GYN_CODIGO')
Local cSeq		:= oMdlGYP:GetValue('GYP_SEQ')
Local cColab	:= oModel:GetModel('FIELDGYQ'):GetValue("GYQ_COLCOD") 
Local cTpRec	:= Posicione('GYO', 1,xFilial('GYO') + oModel:GetModel('GRIDGYE'):GetValue("GYE_ESCALA"), 'GYO_RECCOD') // Buscar o tipo de Recurso da tabela de Escalas
Local lFinaliza	:= Posicione('GYN', 1,xFilial('GYN') + cViagem, 'GYN_FINAL') == '1'
Local nOpc		:= 0
Local cPassag	:= oMdlGYP:GetValue('GYP_PASSAG')

If lFinaliza
	lRet	:= .F.
	cErro	:= "Viagem se encontra finalizada e não é possivel manipular o recurso selecionado"+chr(13)+chr(10)
	cErro	+= "Para realizar a manipulação desta viagem, realize a reabertura da viagem antes de concluir o processo"
Endif

If lRet
	GQE->(DbSetOrder(1))//GQE_FILIAL+GQE_VIACOD+GQE_SEQ+GQE_TRECUR+GQE_RECURS
	oMdlGQE:GetStruct():SetProperty('GQE_DRECUR', MODEL_FIELD_INIT,{|| "" } )
	//Se o recurso está alocado e foi deletado ou exclusão da alocação 
	If oMdlGYP:IsDeleted() .Or. oMdlGYP:GetOperation() == MODEL_OPERATION_DELETE
		nOpc := MODEL_OPERATION_DELETE
		If !GQE->(DbSeek(xFilial('GQE')+cViagem+cSeq+'1'+cColab))
			lRet	:= .F.
			cErro	:= "Não existe alocação para essa viagem"
		Endif 
	Else
		If !GQE->(DbSeek(xFilial('GQE')+cViagem+cSeq+'1'+cColab))
			nOpc := MODEL_OPERATION_INSERT
		Else
			nOpc := MODEL_OPERATION_UPDATE
		Endif
	Endif
	oModel303a:SetOperation(nOpc)
Endif

If lRet .AND. oModel303a:Activate()
	If nOpc <> MODEL_OPERATION_DELETE
	
		If nOpc == MODEL_OPERATION_INSERT
			lRet := lRet .AND. oMdlGQE:SetValue('GQE_VIACOD'	,cViagem)
			lRet := lRet .AND. oMdlGQE:SetValue('GQE_SEQ'		,cSeq)
		Endif
		
		// Se na escala estiver Sim na opção Motorista Passageiro gravar '04' no campo GQE_TCOLAB (Tipo de Colaborador)
		If cPassag == '1'
			If cTpRec == StrZero(1,TamSx3('GQE_TCOLAB')[1]) //Se Motorista
				cTpRec := StrZero(4,TamSx3('GQE_TCOLAB')[1])//Motorista Passageiro
			Else //Se Cobrador
				cTpRec := StrZero(5,TamSx3('GQE_TCOLAB')[1]) //Cobrador Passageiro
			Endif
		Endif
		
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_TRECUR' ,'1')
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_TCOLAB' ,cTpRec)
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_RECURS' ,cColab)
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_HRINTR' ,oMdlGYP:GetValue('GYP_HRINIT'))
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_HRFNTR' ,oMdlGYP:GetValue('GYP_HRFIMT'))
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_ESCALA' ,oMdlGYP:GetValue('GYP_ESCALA'))
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_ESCITE' ,oMdlGYP:GetValue('GYP_ITEM'))
		lRet := lRet .AND. oMdlGQE:SetValue('GQE_DTREF'	 ,oMdlGYP:GetValue('GYP_DTREF'))
		If GQK->(FieldPos("GQK_INTERV")) > 0
			lRet := lRet .AND. oMdlGQE:SetValue('GQE_INTERV' ,oMdlGYP:GetValue('GYP_INTERV'))
		EndIf
	Endif
Endif

If lRet .and. oModel303a:Vlddata()
	FwFormCommit(oModel303a)			
ElseIf !lRet .and. nOpc == MODEL_OPERATION_DELETE
	lRet := .T.
Else
	oGTPLog:SetText(I18N( "Houve o seguinte erro na (Des)Alocação da seguinte viagem #1 da data #2",{oMdlGYP:GetValue('GYN_CODIGO'),oMdlGYP:GetValue('GYP_DTREF')}))
	If Empty(cErro)
		oGTPLog:SetText(GTPGetErrorMsg(oModel303a))
	Else
		oGTPLog:SetText(cErro)
	Endif
	lRet := .F.
EndIf

oModel303a:DeActivate()

Return lRet


/*/{Protheus.doc} CommitPlan
(long_description)
@type function
@author jacomo.fernandes
@since 01/11/2017
@version 1.0
@param oMdlGYP, objeto, (Descrição do parâmetro)
@param oModel303a, objeto, (Descrição do parâmetro)
@param oGTPLog, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function CommitPlan(oModel,oModel313,oGTPLog)
Local oMdlGQK	:= oModel313:GetModel('GQKMASTER')
Local oMdlGYE	:= oModel:GetModel('GRIDGYE')
Local oMdlGYP	:= oModel:GetModel('GRIDGYP')
Local lRet		:= .T.
Local cErro	:= ""
Local cColab	:= oModel:GetModel('FIELDGYQ'):GetValue("GYQ_COLCOD")
Local cTpRec	:= Posicione('GYG',1,xFilial('GYG') + cColab, 'GYG_RECCOD')
Local dDtRef	:= oMdlGYE:GetValue('GYE_DTREF')
Local cTpDia	:= oMdlGYP:GetValue('GQK_TPDIA')
Local cLocOri	:= oMdlGYP:GetValue('GYP_SRVORI')
Local cLocDes	:= oMdlGYP:GetValue('GYP_SRVDES')
Local cCodigo	:= oMdlGYP:GetValue('GYN_CODIGO')
Local dDtIni	:= oMdlGYP:GetValue('GYP_DTINI')
Local cHrIni	:= oMdlGYP:GetValue('GYP_HRINIT')
Local dDtFim	:= oMdlGYP:GetValue('GYP_DTFIM')
Local cHrFim	:= oMdlGYP:GetValue('GYP_HRFIMT')
Local nOpc		:= 0
Local cPassag	:= oMdlGYP:GetValue('GYP_PASSAG')
Local cSrvExt	:= oMdlGYP:GetValue('GYP_SRVEXT')

GQK->(DbSetOrder(1)) //GQK_FILIAL, GQK_CODIGO, GQK_RECURS, GQK_TCOLAB, GQK_DTREF, GQK_DTINI, GQK_HRINI, R_E_C_N_O_, D_E_L_E_T_

//Se o recurso está alocado e foi deletado ou exclusão da alocação 
If oModel:GetOperation() == MODEL_OPERATION_DELETE .or. oMdlGYP:IsDeleted()   
	nOpc := MODEL_OPERATION_DELETE
	If !GQK->(DbSeek(xFilial('GQK')+cCodigo+cColab))
		lRet	:= .F.
		cErro	:= "Não existe plantão para esse colaborador"
	Endif 
Else
	If !GQK->(DbSeek(xFilial('GQK')+cCodigo+cColab))
		nOpc := MODEL_OPERATION_INSERT
	Else
		nOpc := MODEL_OPERATION_UPDATE
	Endif
Endif


oMdlGQK:GetStruct():SetProperty('GQK_LOCORI',MODEL_FIELD_OBRIGAT, .F.)
oMdlGQK:GetStruct():SetProperty('GQK_LOCDES',MODEL_FIELD_OBRIGAT, .F.)

oModel313:SetOperation(nOpc)
If lRet .AND. oModel313:Activate()
	If nOpc <> MODEL_OPERATION_DELETE
		If nOpc == MODEL_OPERATION_INSERT
		
			// Se na escala estiver Sim na opção Motorista Passageiro gravar '04' no campo GQE_TCOLAB (Tipo de Colaborador)
			If cPassag == '1'
				cTpRec := '04'
			Endif
			
			lRet := lRet .AND. oMdlGQK:SetValue('GQK_RECURS' ,cColab)
			lRet := lRet .AND. oMdlGQK:SetValue('GQK_TCOLAB' ,cTpRec)
			lRet := lRet .AND. oMdlGQK:SetValue('GQK_DTREF'	 ,dDtRef)
			lRet := lRet .AND. oMdlGQK:SetValue('GQK_DTINI'	 ,dDtIni)
			lRet := lRet .AND. oMdlGQK:SetValue('GQK_HRINI'	 ,cHrIni)
			lRet := lRet .AND. oMdlGQK:SetValue('GQK_CODGZS' ,cSrvExt)
		Endif
		lRet := lRet .AND. oMdlGQK:SetValue('GQK_TPDIA'	 ,cTpDia)
		lRet := lRet .AND. oMdlGQK:SetValue('GQK_LOCORI' ,cLocOri)
		lRet := lRet .AND. oMdlGQK:SetValue('GQK_LOCDES' ,cLocDes)
		lRet := lRet .AND. oMdlGQK:SetValue('GQK_DTFIM'	 ,dDtFim)
		lRet := lRet .AND. oMdlGQK:SetValue('GQK_HRFIM'	 ,cHrFim)
		lRet := lRet .AND. oMdlGQK:SetValue('GQK_CODGYQ' ,oModel:GetModel('FIELDGYQ'):GetValue("GYQ_CODIGO"))
		lRet := lRet .AND. oMdlGQK:SetValue('GQK_STATUS' , "1" ) //Confirmado
		If GQK->(FieldPos("GQK_INTERV")) > 0
			lRet := lRet .AND. oMdlGQK:SetValue('GQK_INTERV' , oMdlGYP:GetValue('GYP_INTERV'))
		EndIf
	Endif
Endif

If lRet .and. oModel313:Vlddata()
	FwFormCommit(oModel313)			
ElseIf !lRet .and. nOpc == MODEL_OPERATION_DELETE
	lRet := .T.
Else
	oGTPLog:SetText(I18N( "Houve o seguinte erro na (Des)Alocação do seguinte plantão #1 da data #2",{GQK->GQK_CODIGO,GQK->GQK_DTREF}))
	If Empty(cErro)
		oGTPLog:SetText(GTPGetErrorMsg(oModel313))
	Else
		oGTPLog:SetText(cErro)
	Endif
	lRet := .F.
EndIf

oModel313:DeActivate()

Return lRet


//--------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TP008EXEC
Rotina que consulta o cadastro do colaborador em modo Visualização.

@sample		TP008EXEC()
@author		Lucas.brustolin

@since			10/07/2017
@version		P12
/*/
//--------------------------------------------------------------------------------------------------------
Static Function TP008EXEC()
	
Local oModel 	:= FWModelActivate()
Local oModelGYQ := oModel:GetModel("FIELDGYQ")
Local aArea 	:= GetArea()

DbSelectArea("GYG") // Cad. Colaboradores
DbSetOrder(2) // GYG_FILIAL+GYG_COLCOD + ...

IF GYG->( DbSeek(xFilial("GYG") + oModelGYQ:GetValue('GYQ_COLCOD')  ) )
	FWExecView( STR0023 , "GTPA008", MODEL_OPERATION_VIEW, /*oDlg*/, {|| .T. } , , 10, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )//"Consulta Colaborador"
Else
	FWAlertHelp(STR0117)//"Colaborador não informado."
EndIf

RestArea(aArea)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GA303DetEsc
Realiza a chamada na Tela  - Detalhes da Escala.
@sample	GA303DetEsc()
@author	Jacomo Lisa
@since		10/07/2017
@version	P12
/*/
//-------------------------------------------------------------------
Static Function GA303DetEsc(oViewAux)
Local oView		:= Nil
Local oModel	:= oViewAux:GetModel()
Local oStruGYP	:= nil
Local oExecView	:= nil
Local aArea 	:= GetArea()		   
Local lRet 		:= .T.

Local aButtons	:= {	{.F., Nil}, {.F., Nil}    		, {.F., Nil}    	, {.F., Nil}, {.F., Nil}, ;
                    	{.F., Nil}, {.T., "Confirmar"}	, {.T., "Cancelar"}	, {.F., Nil}, {.F., Nil}, ;	// "Confirmar"##"Cancelar"
                    	{.F., Nil}, {.F., Nil}    		, {.F., Nil}    	, {.F., Nil}	}

oStruGYP	:= FWFormStruct(2,'GYP')
oExecView	:= FWViewExec():New()

LoadStructTable( , ,oStruGYP, .T.)

oView := FWFormView():New(oViewAux)
oView:SetModel(oModel)
oView:SetOperation(MODEL_OPERATION_VIEW)

oView:AddGrid('VIEW_GYP' , oStruGYP,'GRIDGYP')
oView:CreateHorizontalBox( 'BOX', 100)
oView:SetOwnerView('VIEW_GYP','BOX')
 
oView:EnableTitleView('VIEW_GYP' , 'Detalhes da Escala')

oView:GetModel('GRIDGYP'):SetNoInsertLine(.T.)
oView:GetModel('GRIDGYP'):SetNoUpdateLine(.T.)
oView:GetModel('GRIDGYP'):SetNoDeleteLine(.T.)

oView:SetViewProperty("VIEW_GYP", "GRIDDOUBLECLICK", {{|oGrid,cField,nLineGrid,nLineModel| Ga303DbClk(oGrid,cField,nLineGrid,nLineModel)}}) 

//Proteção para execução com View ativa.
If oModel != Nil .And. oModel:isActive()
	oExecView:SetModel(oModel)
	oExecView:SetView(oView)
	oExecView:SetTitle('Detalhe - Escala.')
	oExecView:SetOperation(MODEL_OPERATION_VIEW)
	oExecView:setReduction(50)
	oExecView:SetCloseOnOk({|| .t.})
	oExecView:SetButtons(aButtons)
	oExecView:openView(.F.)
	If oExecView:getButtonPress() == VIEW_BUTTON_OK
		lRet := .T.
	Endif
EndIf
oView:GetModel('GRIDGYP'):SetNoInsertLine(.F.)
oView:GetModel('GRIDGYP'):SetNoUpdateLine(.F.)
oView:GetModel('GRIDGYP'):SetNoDeleteLine(.F.)

RestArea(aArea)

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ga303Legend
(long_description)
@type function
@author jacomo.fernandes
@since 25/10/2017
@version 1.0
@param oObj, objeto, Podendo ser View ou Model
@param lTela, booleano, informa se cria tela ou não
@return cRet, retorna qual legenda será
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------------------
Static Function Ga303Legend(oObj,lTela,cAliLeg)

Local oLegenda	:= FWLegend():New()
Local cRet			:= ""
Local oModel		:= oObj:GetModel()
Local oMdlAux		:= NIL
Local aLegend		:= {}
Local n1			:= 0
Local lModel		:= .F.

Default lTela		:= .F.
Default cAliLeg	:= 'GYE'

oMdlAux	:= oModel:GetModel('GRID'+cAliLeg)

lModel := !lTela .and. oMdlAux:GetLine() > 0 

	If cAliLeg == 'GYE'
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYE_STATUS') == '1', GYE->GYE_STATUS == '1' ) } ,"RED"		, "Não Escalado"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYE_STATUS') == '2', GYE->GYE_STATUS == '2' ) } ,"GREEN"	, "Alocação Efetivada"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYE_STATUS') == '3', GYE->GYE_STATUS == '3' ) } ,"YELLOW"	, "Alocação Parcialmente Efetivada"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYE_STATUS') == '4', GYE->GYE_STATUS == '4' ) } ,"BLUE"		, "Escalado"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYE_STATUS') == '5', GYE->GYE_STATUS == '5' ) } ,"BLACK"	, "Impossibilitado"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYE_STATUS') == '6', GYE->GYE_STATUS == '6' ) } ,"ORANGE"	, "Não trabalhado"    })
		
	Else
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYP_STATUS') == '1', GYP->GYP_STATUS == '1' ) } ,"YELLOW"	, "Pendente alocação"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYP_STATUS') == '2', GYP->GYP_STATUS == '2' ) } ,"GREEN"	, "Alocado"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYP_STATUS') == '3', GYP->GYP_STATUS == '3' ) } ,"BLUE"		, "Escalado"    })
		aAdd(aLegend,{{|| If(lModel,oMdlAux:GetValue('GYP_STATUS') == '4', GYP->GYP_STATUS == '4' ) } ,"BLACK"	, "Remanejado operacionalmente"    })	

	Endif


For n1 := 1 To Len(aLegend)
	oLegenda:Add(aLegend[n1][1]	,aLegend[n1][2]		,aLegend[n1][3])
Next

oLegenda:Activate()

If lTela
	oLegenda:View()
Else
	cRet := oLegenda:Execute()
Endif

oLegenda:DeActivate()

GTPDestroy(oLegenda) //Destroi o objeto
GTPDestroy(aLegend)	//Destroi o array
Return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA303WHEN(oModel,cField,xVal)
Função para validação do When

@sample	

@author	jacomo.fernandes
@since		14/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function GTPA303WHEN(oModel,cField,xVal)
Local lRet		:= .T.
Local nOpc		:= oModel:GetOperation()
Local lTrig	:= FwIsInCallStack('GTPA303TRG')
Do Case
	Case cField == "GYQ_ESQUEM" .OR. cField == "GYQ_ESQSEQ"
		lRet := !Empty(oModel:GetValue('GYQ_DTINI')) .And. !Empty(oModel:GetValue('GYQ_DTFIM')) .Or. lTrig
		
	Case cField == "GYQ_GRPSET"
		lRet := nOpc == MODEL_OPERATION_INSERT .AND. !Empty(oModel:GetValue('GYQ_SETOR')) .Or. lTrig
		
	Case cField == "GYQ_COLCOD"
		lRet := nOpc == MODEL_OPERATION_INSERT .AND. !Empty(oModel:GetValue('GYQ_SETOR')) .Or. lTrig
		 
	Case cField == "GYQ_DTINI"
		lRet := nOpc == MODEL_OPERATION_INSERT .AND. !Empty(oModel:GetValue('GYQ_COLCOD')) .Or. lTrig
		
	Case cField == "GYQ_DTFIM"
		lRet := nOpc == MODEL_OPERATION_INSERT .AND. !Empty(oModel:GetValue('GYQ_DTINI')) .Or. lTrig
		
	Case cField == 'GYE_ESCALA'
		lRet := oModel:GetValue('GYE_TPDIA') == "1"  .Or. lTrig	
		
	Case cField == 'GYE_TPDIA'
		lRet := oModel:GetValue('GYE_SITRH') == "1"  .Or. lTrig
		
EndCase

Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA303Vld(oMdl,cField,cNewValue,cOldValue)
Função para validação de campos

@sample	

@author	jacomo.fernandes
@since		14/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function GTPA303Vld(oMdl,cField,cNewValue,cOldValue)
Local lRet		:= .T.
Local aArea	:= GetArea()
Local oModel	:= oMdl:GetModel()
Local cMdlId	:= oMdl:GetId()
Local aRetLog	:= {}
Local cColab   := ""
Local dDataDia 
	
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE
		cColab   := oModel:GetModel('GRIDGYE'):GetValue('GYE_COLCOD') //oMdl:GetValue("GYE_COLCOD")
		dDataDia := oModel:GetModel('GRIDGYE'):GetValue("GYE_DTREF")
		 
		If !(Empty(oModel:GetModel('GRIDGYE'):GetValue("GYE_ESCALA")))
			IF !GTP409ColConf(cColab,dDataDia,/*Linha*/,{'1','2','3'},@aRetLog)
				FWAlertHelp(aRetLog[2] )
				lRet := .F.
			EndIf
		EndIf
	EndIf
	If lRet
	
		Do Case
			Case Empty(cNewValue)
				lRet := .T.
			Case cField == "GYQ_SETOR"
				GYT->(DbSetOrder(1))//GYT_FILIAL+GYT_CODIGO+GYT_LOCALI
				If GYT->(DbSeek(xFilial('GYT')+cNewValue))
					IF __cUserId <> "000000"
						GYH->(DbSetOrder(1))//GYH_FILIAL+GYH_CODIGO+GYH_USRCOD
						If !GYH->(DbSeek(xFilial('GYH')+cNewValue+__cUserId))
							lRet := .F.
							oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld","Usuário logado não pertence à escala informada","Selecione o Setor correspondente ao seu usuário",cNewValue,cOldValue)
						Endif
					Endif		
				Else
					lRet := .F.
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld","Não existe o Setor Informado","Informe outro registro",cNewValue,cOldValue)
				Endif
			Case cField == "GYQ_GRPSET" 
				GZA->(DbSetOrder(1))//GZA_FILIAL+GZA_CODIGO
				If GZA->(DbSeek(xFilial('GZA')+cNewValue))
					If GZA->GZA_SETOR <> oMdl:GetValue('GYQ_SETOR')
						oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld","Grupo informado não pertence ao setor selecionado","Informe outro registro",cNewValue,cOldValue)
						lRet := .F.
					Endif
				Else
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld","Grupo informado não existe","Informe outro registro",cNewValue,cOldValue)
					lRet := .F.
				Endif
			Case cField == "GYQ_COLCOD" 
				GYG->(DbSetOrder(1))//GYG_FILIAL+GYG_CODIGO
				If GYG->(DbSeek(xFilial('GYG')+cNewValue))
					SRA->(DbSetOrder(1))//RA_FILIAL+RA_MAT
					If SRA->(DbSeek(GYG->GYG_FILSRA + GYG->GYG_FUNCIO ))
						IF __cUserId <> "000000"
							If !Empty(oMdl:GetValue('GYQ_GRPSET'))
								GYI->(DbSetOrder(2)) // GYI_FILIAL+GYI_COLCOD+GYI_GRPCOD
								If !GYI->(DbSeek(xFilial('GYI')+cNewValue+oMdl:GetValue('GYQ_GRPSET')))
									lRet := .F.
									oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld",STR0103,STR0104)//"Usuário não Pertence a nenhum Grupo de Escala!"  #"Verifique o Cadastro de Grupo de Escalas"
								Endif
							Else
								GY2->(DbSetOrder(1)) //GY2_FILIAL+GY2_SETOR+GY2_CODCOL
								If !GY2->(DbSeek(xFilial('GY2')+oMdl:GetValue('GYQ_SETOR')+cNewValue))
									lRet := .F.
									oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld","Colaborador não pertence ao setor informado","Verifique o cadastro de Setor")
								Endif
							Endif
						Endif
						//-- Verifica se o colaborador não está demitido.
						//Radu: Alterado para atender a issue DSERGTP-7935
						If lRet .And. !GTP409ColConf( cNewValue,/*dDtIni*/,/*cLinha*/,{"1"}, @aRetLog)
							oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld", aRetLog[2])
							lRet := .F.
						EndIf
					Else
						oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld", STR0105)//"Colaborador informado não é um funcionário!"
						lRet := .F.
					Endif
				Else
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld","Colaborador informado não existe","Informe outro registro",cNewValue,cOldValue)
					lRet := .F.
				Endif
			Case cField == "GYQ_ESQUEM"
				GY8->(DbSetOrder(1))
				If GY8->(DbSeek(xFilial("GY8") + cNewValue))
					If GY8->GY8_SETOR <> oMdl:GetValue('GYQ_SETOR')
						oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld","Esquema de Escala não pertence ao Setor informado","Verifique o cadastro de Esquema de Escala")
						lRet := .F.
					Endif
				Else 
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld",STR0106,STR0107)//"O Código de Esquema de Escala Informando é Inválido!" "Verifique o Cadastro de Esquema de Escalas."
					lRet:= .F.
				EndIf	
			Case cField == "GYQ_ESQSEQ"
				If !GY8->(DbSeek(xFilial("GY8") + oMdl:GetValue('GYQ_ESQUEM') + cNewValue))
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld",STR0108,STR0107)//"O Código de Sequência de Escala Informando é Inválido!" #"Verifique o Cadastro de Esquema de Escalas."
					lRet:= .F.
				EndIf
			Case cField == "GYQ_DTINI" 
				If (cNewValue > oMdl:GetValue("GYQ_DTFIM")) .And. !Empty( oMdl:GetValue("GYQ_DTFIM") )
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld",STR0096,STR0097)//"GTPA303","Data Inicial ou Final Inválida"#"Corrija a Data Inicial/Final."
					lRet := .F.
				EndIf
	
			Case cField == "GYQ_DTFIM"
				If (cNewValue < oMdl:GetValue("GYQ_DTINI")) .And. !Empty( oMdl:GetValue("GYQ_DTINI") )
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld",STR0096,STR0097)//"GTPA303","Data Inicial ou Final Inválida"#"Corrija a Data Inicial/Final."
					lRet := .F.
				EndIf
				If !Ga303VldDt(oModel)
					lRet := .F.
				Endif
			Case cField == 'GYE_ESCALA'
				If !TPValidEscala(oModel)
					lRet :=  .F.
				Endif
				If lRet .and. !VLDGYPTOGIE(oMdl:GetValue("GYE_DTREF"), cNewValue)
					lRet := .F.
					oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"GTPA303Vld",STR0111,STR0112 + cNewValue )//"Foi encontrado inconsistência entre os trechos Escala x Horários." "Atualize a escala: "
				Endif
		EndCase
	
	EndIf
	RestArea(aArea)
Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA303TRG(oMdl,cField,xVal)
Função de Gatilhos

@sample	

@author	jacomo.fernandes
@since		14/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------

Static Function GTPA303TRG(oMdl,cField,xVal)
	Local oModel:= oMdl:GetModel() 
	Local oView	:= FwViewActive()
	Local n1	:= 0
	Do Case
		/*-----------*\
		|Gatilhos GYE |
		\*-----------*/
		Case cField == 'GYQ_SETOR'
			oMdl:SetValue("GYQ_GRPSET"	,'')
			oMdl:SetValue("GYQ_COLCOD"	,'')
			oMdl:SetValue("GYQ_DSCSET"	,POSICIONE("GI1",1,XFILIAL("GI1")+ POSICIONE("GYT",1,XFILIAL("GYT")+xVal,"GYT_LOCALI") ,"GI1_DESCRI"))
			
		Case cField == 'GYQ_GRPSET'
			oMdl:SetValue("GYQ_COLCOD"	,'')
			oMdl:SetValue("GYQ_GRPDSC"	,POSICIONE('GZA',1,xFilial('GZA') + xVal,'GZA_DESCRI') )
			
		Case cField == 'GYQ_COLCOD'
			oMdl:SetValue("GYQ_DTINI"	,StoD(''))
			oMdl:SetValue("GYQ_ESQUEM"	,'')
			oMdl:SetValue("GYQ_COLDES"	,POSICIONE('GYG',1,xFilial('GYG') + xVal,'GYG_NOME'))
			oMdl:SetValue("GYQ_FUNCIO"	,POSICIONE('GYG',1,xFilial('GYG') + xVal,'GYG_FUNCIO'))
			oMdl:SetValue("CODLOCPAD"	,POSICIONE('GYG',1,xFilial('GYG') + xVal,'GYG_LOCPAD'))
		
		Case cField == "CODLOCPAD" 		
			oMdl:SetValue("DESLOCPAD"	,POSICIONE('GI1',1,xFilial('GI1') + xVal,'GI1_DESCRI'))
			
		Case cField == 'GYQ_ESQUEM'
			oMdl:SetValue('GYQ_ESQSEQ'	,'')
			
		Case cField == 'GYQ_ESQSEQ' 
			LimpaEsquema(oModel)
			If !Empty(xVal)
				ExecEsquema(oModel)
			Endif
			
		Case cField == 'GYQ_DTINI' 
			oMdl:SetValue('GYQ_DTFIM'	,StoD(''))
			
		Case cField == 'GYQ_DTFIM' 
			oModel:GetModel('GRIDGYE'):ClearData()	//Deleta a grid de dias da alocação
			oMdl:SetValue('GYQ_ESQUEM'	,'')
			
			oView:Refresh('VIEW_GYE')
			
			GTPA303DTF(oModel)	//Preenche os dias conforme a data informada
			
			
		/*-----------*\
		|Gatilhos GYE |
		\*-----------*/
		Case cField == "GYE_SITRH"
			SetStatus(oMdl)
		Case cField == "GYE_TPDIA"
			If !Empty(oMdl:GetValue('GYE_ESCALA'))	
				oMdl:SetValue('GYE_ESCALA'	,'')
				oMdl:SetValue('GYE_ESCDES'	,'')
			ElseIF !FwIsInCallStack('GTPA303DTF')
				LoadGYP(oModel) //Função responsavel para carregar a GYP
			Endif
			SetStatus(oMdl)
			
			If !FwIsInCallStack('GTPA303DTF')
				TP303Totaliza()
			Endif
			
		Case cField == 'GYE_ESCALA'
			SetStatus(oMdl)
			
			LoadGYP(oModel) //Função responsavel para carregar a GYP
			
			If !Empty(oMdl:GetValue('GYE_ESCALA'))
				SetGYPDates(oModel,.T.)//Função responsavel para preencher as datas da GYP (Inicial/Final)
				For n1 := 1 To oModel:GetModel('GRIDGYP'):Length()
					If !oModel:GetModel('GRIDGYP'):IsDeleted(n1)
						oModel:GetModel('GRIDGYP'):GoLine(n1)	
						SetGYP(oModel) //Função responsavel para preencher as informações de alocações da GYP
					Endif
				Next
			Endif
			
			
			If !FwIsInCallStack('GTPA303DTF')
				TP303Totaliza()
			Endif
		Case cField == "GYE_STATUS"
			oMdl:SetValue("GYE_LEGEND",Ga303Legend(oMdl,.F.,'GYE'))
		/*-----------*\
		|Gatilhos GYP |
		\*-----------*/
		Case cField == "GYP_STATUS"
			oMdl:SetValue("GYP_LEGEND",Ga303Legend(oMdl,.F.,"GYP"))
		
	EndCase
Return xVal


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LimpaEsquema()
Gatilho para Limpeza do Grid com o código da Escala

@sample	LimpaEsquema(oModel)

@author	jacomo.fernandes
@since		14/10/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Static Function LimpaEsquema(oModel)

Local oView		:= FwViewActive()
Local oModelGYE	:= oModel:GetModel("GRIDGYE")
Local nI			:= 0

	IF oModelGYE:Length() > 0 
		For nI := 1 To oModelGYE:Length()
			oModelGYE:GoLine(nI)
			If oModelGYE:GetValue("GYE_SITRH") == DISPONIVEL
				oModelGYE:SetValue("GYE_TPDIA"	,TRABALHADO)
			Else
				oModelGYE:SetValue("GYE_TPDIA"	,NAO_TRABALHADO)
			Endif
			oModelGYE:SetValue("GYE_ESCALA"	,'')
		Next nI	
	EndIf
	
	oModelGYE:GoLine(1)
	
	If !IsBlind()
		oView:Refresh('VIEW_GYE')
	Endif

Return()
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ExecEsquema(oModel)
Função de gatilho para preencher as escalas com base no esquema de escalas.
@Return 	Nulo	
@author	jacomo.fernandes 
@since		11/08/2017
@version	P12

/*/
//------------------------------------------------------------------------------------------
Static Function ExecEsquema(oModel)

Local oView         := FwViewActive()
Local oFieldGYQ     := oModel:GetModel("FIELDGYQ")
Local oModelGYE     := oModel:GetModel("GRIDGYE")
Local cEsquema      := oFieldGYQ:GetValue("GYQ_ESQUEM")
Local cSequencia    := oFieldGYQ:GetValue("GYQ_ESQSEQ")
Local nTotSeq       := 0
Local nI            := 0
Local nX            := 0
Local nCount        := 1
Local oGTPLog       := GTPLog():New("Aplicação de Esquema de Escala")

	cAliasQry := GetNextAlias()

	BeginSql Alias cAliasQry

		SELECT
			GY8_SEQ, GY8_TPDIA, GY8_ESCALA
		FROM
			%Table:GY8% GY8
		WHERE
			GY8.GY8_FILIAL = %xFilial:GY8% AND 
	 		GY8.GY8_CODIGO = %Exp:cEsquema % AND
			GY8.%notDel%
		ORDER BY
			GY8_SEQ
	EndSql
	
	
	nTotSeq := (cAliasQry)->(ScopeCount())
	(cAliasQry)->(DbGoTop())
	
	oModelGYE:GoLine(1)
	
	For nI := 1 To oModelGYE:Length()
		oModelGYE:GoLine(nI)
		If oModelGYE:GetValue('GYE_SITRH') <> DISPONIVEL
			Loop
		Endif
		
		If nI == 1
			For nX := 1 To nTotSeq 
				If cSequencia == (cAliasQry)->GY8_SEQ
					nCount := nX
					Exit
				Endif
				(cAliasQry)->(DbSkip())
			Next
		Endif 
		
		oModelGYE:SetValue("GYE_TPDIA"	,(cAliasQry)->GY8_TPDIA	)
		If (cAliasQry)->GY8_TPDIA == '1'
			If !oModelGYE:SetValue('GYE_ESCALA'	,(cAliasQry)->GY8_ESCALA	)
				oGTPLog:SetText("Escala: "+(cAliasQry)->GY8_ESCALA+" do dia: "+DtoC(oModelGYE:GetValue("GYE_DTREF"))+" possui o(s) seguinte erro:"+chr(13)+Chr(10)+ GTPGetErrorMsg(oModel))				
			Endif
		Endif
		nCount++
		If nCount <= nTotSeq	
			(cAliasQry)->(DbSkip())
		Else
			nCount := 1
			(cAliasQry)->(DbGoTop())
		Endif
	Next nI	

	(cAliasQry)->(DbCloseArea())
	
	If oGTPLog:HasInfo()
		oGTPLog:ShowLog()
	Endif
	
	oGTPLog:Destroy()
	
	oModel:GetErrorMessage(.T.)
	
	oModelGYE:GoLine(1)
	oView:Refresh('VIEW_GYE')

Return


/*/{Protheus.doc} GTPA303INIT
(long_description)
@type function
@author jacomo.fernandes
@since 23/10/2017
@version 1.0
@param oMdl, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param xVal, variável, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param xOldValue, variável, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GTPA303INIT(oMdl,cField,xVal,nLine,xOldValue)
Local xRet		:= ""
Local lInsert := oMdl:GetOperation() == MODEL_OPERATION_INSERT
 
Do Case 
	Case cField == "GYQ_COLDES"
		xRet := If(!lInsert,POSICIONE('GYG',1,xFilial('GYG') + GYQ->GYQ_COLCOD,'GYG_NOME'),"") 
	Case cField == "CODLOCPAD"
		xRet := If(!lInsert,POSICIONE('GYG',1,xFilial('GYG') + GYQ->GYQ_COLCOD,'GYG_LOCPAD'),"")
	Case cField == "DESLOCPAD"
		xRet := If(!lInsert,POSICIONE('GI1',1,xFilial('GI1') + (POSICIONE('GYG',1,xFilial('GYG') + GYQ->GYQ_COLCOD,'GYG_LOCPAD')),'GI1_DESCRI'),"")
	Case cField == "GYE_LEGEND"
		xRet := Ga303Legend(oMdl,.F.,'GYE')
	Case cField == "GZS_DESCRI"
		xRet := If(!lInsert,POSICIONE('GZS',1,xFilial('GZS') + GYP->GYP_SRVEXT,'GZS_DESCRI'),"")
	
EndCase

Return xRet

/*/{Protheus.doc} Ga303DbClk
(long_description)
@type function
@author jacomo.fernandes
@since 23/10/2017
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
Static Function Ga303DbClk(oGrid,cField,nLineGrid,nLineModel)
If cField == "GYE_LEGEND"
	Ga303Legend(oGrid,.T.,'GYE')
ElseIf  cField == "GYP_LEGEND"
	Ga303Legend(oGrid,.T.,'GYP')	
Endif
Return .T. 

/*/{Protheus.doc} SetStatus
(long_description)
@type function
@author jacomo.fernandes
@since 25/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
Static Function SetStatus(oMdl,lInit)
Local oModel	:= oMdl:GetModel()
Local cStatus	:= ""
Default lInit := .F.
If oMdl:GetID() == 'GRIDGYE'
	If oMdl:GetValue('GYE_SITRH') == '1'//Disponivel
		If oMdl:GetValue('GYE_TPDIA') == '1' 
			IF Empty(oMdl:GetValue('GYE_ESCALA')) //Trabalhado
				cStatus := '1' //Não Escalado
			Else
				cStatus := '4' //Escalado
			Endif
		Else
			cStatus := '6'//Não trabalhado
		Endif
	Else
		cStatus := '5'//Impossibilitado
	Endif 
	oMdl:SetValue('GYE_STATUS',cStatus)
Else
	If oModel:GetModel('GRIDGYE'):GetValue('GYE_STATUS') == '2' //Alocação efetivada
		If !Empty(oMdl:GetValue('GQE_RECURS')) .or. oMdl:GetValue('GYP_TIPO') == '3'  
			cStatus := '2'//"2=Alocado"
		Else
			cStatus := '4' //"4=Remanejado operacionalmente"
		Endif
	Else
		If !Empty(oMdl:GetValue('GYN_CODIGO'))
			If !Empty(oMdl:GetValue('GQE_RECURS'))
				cStatus := '2'//"2=Alocado"
			Else
				cStatus := '1'//"1=Pendente alocação"
			Endif
		Else
			cStatus := '3'//"3=Escalado"
		Endif
	Endif
Endif
Return cStatus

/*/{Protheus.doc} LoadGYP
Função responsavel para carregar a grid de trechos
@type function
@author jacomo.fernandes
@since 27/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadGYP(oModel,lActivate)
Local oModelGYE		:= oModel:GetModel('GRIDGYE')
Local oModelGYP		:= oModel:GetModel('GRIDGYP')
Local cTpDia		:= RetTipoDiaAloc(oModelGYE)
Local cEscala		:= oModelGYE:GetValue('GYE_ESCALA')
Local dDtRef		:= oModelGYE:GetValue('GYE_DTREF')
Local cTmpAlias		:= GetNextAlias()
Local n1			:= 0
Local aFields		:= {}
Local cSelect       := ""

If !oModelGYP:IsEmpty()
	oModelGYP:DelAllLine()
Endif
If GQK->(FieldPos("GQK_INTERV")) > 0
	cSelect := "% , (CASE GYP_TIPO WHEN '4' THEN '1' ELSE '2'END) as GYP_INTERV %"
EndIf
//Se tipo de Dia for trabalhado
IF cTpDia == TRABALHADO .and. !Empty(cEscala)
	BeginSql Alias cTmpAlias
		Select
			GYP.*
			, GI1ORI.GI1_DESCRI AS GYP_DESORI
			, GI1DES.GI1_DESCRI AS GYP_DESDES
			, GZS.GZS_DESCRI
			, (CASE GYP_TIPO
				WHEN '3' THEN '2'
				ELSE '1'
			END) as GQK_TPDIA
			%Exp:cSelect%
		From %Table:GYP% GYP
			INNER JOIN %Table:GI1% GI1ORI ON
				GI1ORI.GI1_FILIAL	= %xFilial:GI1%	
				AND GI1ORI.GI1_COD	= GYP.GYP_SRVORI		
				AND GI1ORI.%NotDel% 
				
			INNER JOIN %Table:GI1% GI1DES ON
				GI1DES.GI1_FILIAL	= %xFilial:GI1%	
				AND GI1DES.GI1_COD	= GYP.GYP_SRVDES		
				AND GI1DES.%NotDel% 
				
			LEFT JOIN %Table:GZS% GZS ON
				GZS.GZS_FILIAL = %xFilial:GI1%
				AND GZS.GZS_CODIGO = GYP.GYP_SRVEXT 	
				AND GZS.%NotDel%        
		Where
			GYP.GYP_FILIAL = %xFilial:GYP%
			AND GYP.GYP_ESCALA = %Exp:cEscala%
			AND GYP.%NotDel%
		ORDER BY
			GYP.GYP_ITEM
	EndSql
	
	aFields := (cTmpAlias)->(DbStruct())

	While (cTmpAlias)->(!Eof())
		
		If !oModelGYP:IsEmpty() .and. !( oModelGYP:Length() == 1 .and. Empty(oModelGYP:GetValue( 'GYP_ITEM' )))
			oModelGYP:AddLine()
		Endif
		
		For n1 := 1 to Len(aFields) 	
			If oModelGYP:HasField(aFields[n1][1])
				oModelGYP:SetValue(aFields[n1][1],(cTmpAlias)->&(aFields[n1][1]))
			Endif
		Next
		
		(cTmpAlias)->(DbSkip())
	End
	
	(cTmpAlias)->(DbCloseArea())
	
ElseIf cTpDia <> TRABALHADO
	If !oModelGYP:IsEmpty() .and. !( oModelGYP:Length() == 1 .and. Empty(oModelGYP:GetValue( 'GYP_ITEM' )))
		oModelGYP:AddLine()
	Endif
	If !lActivate
		oModelGYP:SetValue('GYP_ITEM'	,StrZero(1,TamSx3('GYP_ITEM')[1]))
		oModelGYP:SetValue('GYP_DTREF'	,dDtRef)
		oModelGYP:SetValue('GYP_DTINI'	,dDtRef)
		oModelGYP:SetValue('GYP_HRINIT'	,'0000')
		oModelGYP:SetValue('GYP_DTFIM'	,dDtRef)
		oModelGYP:SetValue('GYP_HRFIMT'	,'2359')
		oModelGYP:SetValue('GQK_TPDIA'	,cTpDia)
		oModelGYP:SetValue('GYP_SEQ'	,StrZero(1,TamSx3('GYP_SEQ')[1]))
		oModelGYP:SetValue('GYP_STATUS','1')//Pendente Alocação
	Else
		oModelGYP:ForceValue('GYP_ITEM'		,StrZero(1,TamSx3('GYP_ITEM')[1]))
		oModelGYP:ForceValue('GYP_DTREF'	,dDtRef)
		oModelGYP:ForceValue('GYP_DTINI'	,dDtRef)
		oModelGYP:ForceValue('GYP_HRINIT'	,'0000')
		oModelGYP:ForceValue('GYP_DTFIM'	,dDtRef)
		oModelGYP:ForceValue('GYP_HRFIMT'	,'2359')
		oModelGYP:ForceValue('GQK_TPDIA'	,cTpDia)
		oModelGYP:ForceValue('GYP_SEQ'		,StrZero(1,TamSx3('GYP_SEQ')[1]))
		oModelGYP:ForceValue('GYP_STATUS'	,'1')//Pendente Alocação  
	Endif
Endif
oModelGYP:GoLine(1)


Return 


/*/{Protheus.doc} SetGYPDates
Função responsavel para preencher as datas iniciais e finais de cada trecho
@type function
@author jacomo.fernandes
@since 07/11/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param lActivate, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetGYPDates(oModel,lActivate)
Local oModelGYE	:= oModel:GetModel('GRIDGYE')
Local oModelGYP	:= oModel:GetModel('GRIDGYP')
Local dDtRef	:= oModelGYE:GetValue('GYE_DTREF')
Local dDtIni	:= nil
Local dDtFim	:= nil
Local cNumSrv	:= ""
Local cTpDia	:= ""
Local n1		:= 0

Default lActivate := .F.

For n1 := 1 to oModelGYP:Length()
	If !oModelGYP:IsDeleted(n1)
		oModelGYP:GoLine(n1)
		dDtIni	:= oModelGYP:GetValue('GYP_DTINI')
		dDtFim	:= oModelGYP:GetValue('GYP_DTFIM')
		cTpDia	:= IF(oModelGYP:GetValue('GYP_TIPO') <> '3','1','2')
		cNumSrv := ""
		
		If Empty(dDtIni)
			dDtIni	:= dDtRef
			
			If n1 > 1 .and. !oModelGYP:IsDeleted(n1-1)
				If oModelGYP:GetValue('GYP_DTFIM',n1-1) == dDtRef .and. oModelGYP:GetValue('GYP_DIA') <> 0
					If oModelGYP:GetValue('GYP_HRFIMT') < oModelGYP:GetValue('GYP_HRINIT')
						dDtIni	:= 	oModelGYP:GetValue('GYP_DTFIM',n1-1)
					Else
						dDtIni	:= 	oModelGYP:GetValue('GYP_DTFIM',n1-1) + oModelGYP:GetValue('GYP_DIA')
					Endif 
				Else
				 	dDtIni	:= 	oModelGYP:GetValue('GYP_DTFIM',n1-1)			
				Endif
			
			Endif
		Endif		
		
		If Empty(dDtFim)
			dDtFim	:= dDtRef
			
			If n1 > 1 .and. !oModelGYP:IsDeleted(n1-1)
				If oModelGYP:GetValue('GYP_DTFIM',n1-1) == dDtRef .and.  oModelGYP:GetValue('GYP_DIA') <> 0
					dDtFim	:= 	oModelGYP:GetValue('GYP_DTFIM',n1-1) + oModelGYP:GetValue('GYP_DIA')
				Else
					dDtFim	:= 	dDtIni
				Endif
			
			ElseIf oModelGYP:GetValue('GYP_HRFIMT') < oModelGYP:GetValue('GYP_HRINIT')
			  	dDtFim	:= 	dDtIni + oModelGYP:GetValue('GYP_DIA')
			Else
				dDtFim	:= 	dDtIni
			Endif
		Endif
		
		If !Empty(oModelGYP:GetValue('GYP_CODGID'))
			cNumSrv := Posicione('GID',4,xFilial('GID')+oModelGYP:GetValue('GYP_CODGID')+'2','GID_NUMSRV')
		Endif
		
		If !lActivate
			oModelGYP:SetValue('GYP_DTREF'	,dDtRef)
			oModelGYP:SetValue('GYP_DTINI'	,dDtIni)
			oModelGYP:SetValue('GYP_DTFIM'	,dDtFim)
			oModelGYP:SetValue('GID_NUMSRV'	,cNumSrv)
			oModelGYP:SetValue('GQK_TPDIA'	,cTpDia)
			
		Else
			oModelGYP:ForceValue('GYP_DTREF'	,dDtRef)
			oModelGYP:ForceValue('GYP_DTINI'	,dDtIni)
			oModelGYP:ForceValue('GYP_DTFIM'	,dDtFim)
			oModelGYP:ForceValue('GID_NUMSRV'	,cNumSrv)
			oModelGYP:ForceValue('GQK_TPDIA'	,cTpDia)
		Endif
	Endif

Next 
	
	
Return

/*/{Protheus.doc} SetGYP
Função responsavel para verificar as alocações de cada trecho
@type function
@author jacomo.fernandes
@since 07/11/2018
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param lActivate, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function SetGYP(oModel,lActivate)
Local cAliasQry		:= QryAlocacao(oModel)
Local oModelGYP		:= oModel:GetModel('GRIDGYP')
Local aQryStruct	:= nil	
Local n1			:= 0

Default lActivate	:= .F.

If (cAliasQry)->(!EoF())
	aQryStruct := (cAliasQry)->(DbStruct())
	(cAliasQry)->(DbGoTop())
		
	For n1 := 1 to Len(aQryStruct) 	
		If oModelGYP:HasField(aQryStruct[n1][1])
			If !lActivate
				oModelGYP:SetValue(aQryStruct[n1][1],(cAliasQry)->&(aQryStruct[n1][1]))
			Else
				oModelGYP:ForceValue(aQryStruct[n1][1],(cAliasQry)->&(aQryStruct[n1][1]))
			Endif
		Endif
	Next
		
	If !lActivate
		oModelGYP:SetValue('GYP_STATUS',SetStatus(oModelGYP))
	Else
		oModelGYP:ForceValue('GYP_STATUS',SetStatus(oModelGYP))
		oModelGYP:ForceValue("GYP_LEGEND",Ga303Legend(oModelGYP,.F.,"GYP"))
	Endif
	
Endif

(cAliasQry)->(DbCloseArea())

Return 



/*/{Protheus.doc} QryAlocacao
Função responsavel para verificar as alocações do recurso
@type function
@author jacomo.fernandes
@since 01/11/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param lActivate, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function QryAlocacao(oModel)
Local cAliasQry		:= GetNextAlias()
Local oModelGYE		:= oModel:GetModel('GRIDGYE')
Local oModelGYP		:= oModel:GetModel('GRIDGYP')
Local cColab		:= oModel:GetModel('FIELDGYQ'):GetValue('GYQ_COLCOD')
Local dDtRef		:= oModelGYE:GetValue('GYE_DTREF')
Local dDtIni		:= oModelGYP:GetValue('GYP_DTINI')
Local dDtFim		:= oModelGYP:GetValue('GYP_DTFIM')
Local cTerceiro 	:= "%'2',' '%"

If (oModelGYP:GetValue('GQK_TPDIA') <> TRABALHADO) ;
	.OR. (oModelGYP:GetValue('GYP_TIPO') == '2' .AND. !Empty(oModelGYP:GetValue('GYP_SRVEXT')))
	BeginSql Alias cAliasQry
		Select 
			GQK.GQK_RECURS as GQE_RECURS,
			GQK.GQK_CODIGO AS GYN_CODIGO
		From %Table:GQK% GQK
		Where
			GQK.GQK_FILIAL = %xFilial:GQK%
			AND GQK.GQK_RECURS	= %Exp:cColab%	
			AND GQK.GQK_TERC IN (%Exp:cTerceiro%)	
			AND GQK.GQK_DTREF	= %Exp:DtoS(dDtRef)%
			AND GQK.GQK_HRINI	= %Exp:oModelGYP:GetValue('GYP_HRINIT')%
			AND GQK.GQK_TPDIA	= %Exp:oModelGYP:GetValue('GQK_TPDIA')%
			AND GQK.GQK_CODGZS	= %Exp:oModelGYP:GetValue('GYP_SRVEXT')%
			AND GQK.%NotDel%		
	EndSql
	
Else //Caso Normal
	BeginSql Alias cAliasQry
		Select 
			GQE.GQE_RECURS,
			GYN.GYN_CODIGO
		From %Table:GYN% GYN 
			Inner Join %Table:G55% G55 On
				G55.G55_FILIAL		= GYN.GYN_FILIAL	
				AND G55.G55_CODVIA	= GYN.GYN_CODIGO
				
				AND G55.G55_SEQ		= %Exp:oModelGYP:GetValue('GYP_SEQ')% 
				AND G55.G55_DTPART	= %Exp:DtoS(dDtIni)% 
				AND G55.G55_HRINI 	= %Exp:oModelGYP:GetValue('GYP_HORORI')%	 
				AND G55.G55_LOCORI 	= %Exp:oModelGYP:GetValue('GYP_SRVORI')% 
				AND G55.G55_DTCHEG	= %Exp:DtoS(dDtFim)% 
				AND G55.G55_HRFIM 	= %Exp:oModelGYP:GetValue('GYP_HORDES')%	 
				AND G55.G55_LOCDES 	= %Exp:oModelGYP:GetValue('GYP_SRVDES')%
				AND G55.%NotDel% 
				
			Left Join %Table:GQE% GQE ON
				GQE.GQE_FILIAL		= GYN.GYN_FILIAL	
				AND GQE.GQE_VIACOD	= G55.G55_CODVIA	
				AND GQE.GQE_SEQ		= G55.G55_SEQ		
				AND GQE.GQE_TRECUR	= '1'			
				AND GQE.GQE_RECURS	= %Exp:cColab%	
				AND GQE.GQE_TERC IN (%Exp:cTerceiro%)
				AND GQE.%NotDel%	
		Where
			GYN.GYN_FILIAL	= %xFilial:GYN%
			and GYN.GYN_CODGID	= %Exp:oModelGYP:GetValue('GYP_CODGID')% 
			and GYN.GYN_SRVEXT	= %Exp:oModelGYP:GetValue('GYP_SRVEXT')% 
			and GYN.GYN_TIPO = '1' 
			
			AND GYN.%NotDel%
	EndSql
Endif


Return cAliasQry


/*/{Protheus.doc} Ga303VldDt
(long_description)
@type function
@author jacomo.fernandes
@since 30/10/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga303VldDt(oModel)
 
Local oModelGYQ	:= oModel:GetModel("FIELDGYQ")
Local dDtIni		:= oModelGYQ:GetValue("GYQ_DTINI")
Local dDtFim		:= oModelGYQ:GetValue("GYQ_DTFIM")
Local cColab		:= oModelGYQ:GetValue("GYQ_COLCOD")
Local cCodGYQ		:= oModelGYQ:GetValue('GYQ_CODIGO')
Local cAliasGYE	:= GetNextAlias()
Local lRet		:= .T.

	cAliasGYE := GetNextAlias()
	//----------------------------------------------------------------+
	// VALIDA SE ALOCAÇÃO JÁ FOI REALIZADA PARA O PERIODO SELECIONADO |
	//----------------------------------------------------------------+	
	BeginSQL Alias cAliasGYE				
		SELECT GYE_DTREF
		FROM %Table:GYE% GYE
		WHERE GYE_FILIAL = %xFilial:GYE%
			AND GYE_COLCOD = %Exp:cColab%
			AND GYE_DTREF Between %Exp:dDtIni% AND %Exp:dDtFim%
			AND GYE_CODGYQ <> %Exp:cCodGYQ%
			AND %NotDel%
	EndSQL
			
	IF (cAliasGYE)->(!EOF())
		If FwIsInCallStack('GTPA303VLD')
			oModel:SetErrorMessage(oModel:GetId(),"",oModel:GetId(),"","Ga303VldDt",STR0109,STR0110)//"Datas já alocadas para o Colaborador informado!." "Utilize a Rotina de Manutenção de Alocação"
		Else
			Help(,,'Ga303VldDt',,STR0109,1,0,,,,,,{STR0110})//"Datas já alocadas para o Colaborador informado!." "Utilize a Rotina de Manutenção de Alocação"
		Endif
		lRet := .F.
	EndIf
	(cAliasGYE)->(DbCloseArea())

Return lRet


/*/{Protheus.doc} Ga303Activ
(long_description)
@type function
@author jacomo.fernandes
@since 01/11/2017
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function Ga303Activ(oModel) 
Local oModelGYE	:= oModel:GetModel('GRIDGYE')
Local oModelGYP	:= oModel:GetModel('GRIDGYP')
Local n1,n2

If oModel:GetOperation() <> MODEL_OPERATION_INSERT
	For n1 := 1 To oModelGYE:Length() 
		oModelGYE:GoLine(n1)
		If oModelGYE:GetValue('GYE_TPDIA') == TRABALHADO .and. !Empty(oModelGYE:GetValue('GYE_ESCALA'))
			SetGYPDates(oModel,.T.)//Função responsavel para preencher as datas da GYP (Inicial/Final)
			For n2 := 1 To oModelGYP:Length()
				oModelGYP:GoLine(n2)	
				SetGYP(oModel,.T.) //Função responsavel para preencher as informações de alocações da GYP
			Next
		Else
			LoadGYP(oModel,.T.)
			SetGYP(oModel,.T.) //Função responsavel para preencher as informações de alocações da GYP
		Endif
	Next	

	oModelGYE:GoLine(1)
Endif

If 	oModel:GetOperation() == MODEL_OPERATION_UPDATE
	oModel:lModify := .T.
Endif 
Return 

/*/{Protheus.doc} GA303LNPRE
(long_description)
@type function
@author jacomo.fernandes
@since 09/01/2019
@version 1.0
@param oModel, objeto, (Descrição do parâmetro)
@param nLine, numérico, (Descrição do parâmetro)
@param cAction, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GA303LNPRE(oModel,nLine,cAction,cField)
Local lRet := .T.

If cAction == 'CANSETVALUE' .and. !(cField $ "GYE_STATUS/GYE_LEGEND") 
	If oModel:GetValue('GYE_DTREF') <= dDataBase
		oModel:GetModel():SetErrorMessage(oModel:GetId(),cField,oModel:GetId(),cField,"GA303LNPRE","Não é possivel manipular a alocação do que ja foi planejado","Altere o planejamento somente dos dias futuros")
		lRet := .F.
	Endif
Endif
Return lRet 


/*/{Protheus.doc} RetTipoDiaAloc
Retorna o Tipo de Dia referente à Alocação
@type function
@author jacomo.fernandes
@since 11/01/2019
@version 1.0
@param oModelGYE, objeto, (Descrição do parâmetro)
@param lPlantao, ${param_type}, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function RetTipoDiaAloc(oModelGYE,lPlantao)
Local cRet		:= "1" //Trabalhado
Local cSituaRH	:= oModelGYE:GetValue('GYE_SITRH') //0=Indisponivel RH;1=Disponivel;2=Ferias;3=Afastado;4=Demitido
Local cTpDia	:= oModelGYE:GetValue('GYE_TPDIA')//1=Trabalhado;2=Não Trabalhado;3=Folga;4=D.S.R.
Default lPlantao:= .F.

If cSituaRH == DISPONIVEL //Disponivel pelo RH
	If cTpDia == TRABALHADO
		If lPlantao
			cRet := '2' //Plantão
		Else
			cRet := '1' //Trabalhado
		Endif
	Elseif cTpDia == NAO_TRABALHADO
		cRet := '4'//Não trabalhado
	Elseif cTpDia == DSR
		cRet := '6' //DSR
	Else
		cRet	:= '3' //Folga
	Endif 
Else
	cRet := '5'//Indisponivel rh (2=Ferias;3=Afastado;4=Demitido)
Endif
 
Return cRet

/*/
 * {Protheus.doc} commitDtc()
 * Retorna se o tipo de parada é intervalo
 * type    Static Function
 * author  Eduardo Ferreira
 * since   17/09/2019
 * version 12.25
 * param   Não há
 * return  cInterv
/*/
Static Function LoadTipo()
Local cInterv  := ""

IF GYP->GYP_TIPO == "4"
	cInterv := "1"
ELSE
	cInterv := "2"
ENDIF

Return cInterv


/*/
 * {Protheus.doc} Ga303Escala()
 * Retorna se o tipo de parada é intervalo
 * type    Static Function
 * author  
 * since   17/09/2019
 * version 12.25
 * param   Não há
 * return  
/*/
Static Function Ga303Escala(oView)
Local oModel	:= FwModelActive()
	If oModel:GetModel("GRIDGYE"):GetValue('GYE_TPDIA') == "1" 		
		Tp303AF3()
		oModel:GetModel("GRIDGYE"):SetValue('GYE_ESCALA',__uRetBrw)
		If !IsBlind()
			oView:Refresh('VIEW_GYE')
		Endif
	EndIf
Return 
