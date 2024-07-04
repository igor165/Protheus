#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE 'FWEDITPANEL.CH'
#Include 'FWBrowse.ch'
#Include 'FINA761.ch'


#DEFINE ABA_DADOS_BASICOS		"000001"
#DEFINE ABA_PCO					"000002"
#DEFINE ABA_PSO					"000003"
#DEFINE ABA_OUTROS_LANCAMENTOS	"000005"
#DEFINE ABA_DEDUCAO				"000006"
#DEFINE ABA_ENCARGOS				"000007"
#DEFINE ABA_DESPESAS_ANULAR		"000008"
#DEFINE ABA_DADOS_PAGAMENTO		"000010"

#DEFINE OPER_ENVIAR				10
#DEFINE OPER_REALIZAR			11
#DEFINE OPER_REALLOTE			7
#DEFINE OPER_CANCELAR			13
#DEFINE OPER_ESTORNAR			14
#DEFINE DH_TRANS_INCLUSAO		1
#DEFINE DH_TRANS_CANCELAMENTO	2
#DEFINE DH_TRANS_REALIZACAO		3
#DEFINE DH_TRANS_ESTORNO			4


Static __cProcPrinc		:= "FINA761"
//Controle
Static __cTpDocAnt		:= ""
Static __cTpForAnt		:= ""
Static __cTpLojAnt		:= ""
Static __cTpUpgAnt		:= ""

Static __aModels		:= {}
Static __cAliasTMP		:= ""
Static __cArqTrab		:= ""
Static __cArqTit		:= ""
Static __cIndTMP		:= ""
Static __cIndTMP2		:= ""
Static __cIndTit		:= ""
Static __aFolder		:= {}
Static __FV0_FORNEC		:= ""
Static __lDeducoes		:= .F.
Static __lPrePag		:= .F.
Static __oViewDynamic	:= Nil
Static __nOper			:= 0
Static cRet761F3		:= ""
Static __aF761Ctrl		:= {}
Static cRetContaF3		:= ""
Static cRetCCBenF3		:= ""
Static __oMdlPrinc		:= Nil
Static cRetNotaF3		:= ""
Static __cArqEmp		:= ""
Static __cIndEmp		:= ""
Static __lVlEmp			:= .T.
Static _oFINA761A
Static _oFINA761B
Static _oFINA761C
Static _oFINA761D
Static lFa761Rot		:= ExistBlock("FA761ROT")

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA761
Rotina responsável pela manutencao de Documentos Hábeis

@author Marylly Araújo Silva
@since 25/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function FINA761()
Local oBrowse	:= Nil
Local oDlg		:= Nil

oBrowse := FWMBrowse():New()
oBrowse:setAlias("FV0") // Tabela de Documento Hábil
oBrowse:SetDescription(STR0001) // "Cadastro de Documento Hábil"

ADD LEGEND DATA {|| FV0_STATUS  == '1'} COLOR "BLUE"			TITLE	STR0002 Of oBrowse // "Aguardando Envio"
ADD LEGEND DATA {|| FV0_STATUS  == '2'} COLOR "YELLOW"		TITLE	STR0003 Of oBrowse // "Aguardando Realização"
ADD LEGEND DATA {|| FV0_STATUS  == '3'} COLOR "GREEN"		TITLE	STR0004 Of oBrowse // "Realizado"
ADD LEGEND DATA {|| FV0_STATUS  == '4'} COLOR "RED"			TITLE	STR0005 Of oBrowse // "Cancelado"
ADD LEGEND DATA {|| FV0_STATUS  == '5'} COLOR "ORANGE"		TITLE	STR0006 Of oBrowse // "Estornado"
ADD LEGEND DATA {|| FV0_STATUS  == '6'} COLOR "PINK"			TITLE	STR0007 Of oBrowse // "Com erro no envio" 
ADD LEGEND DATA {|| FV0_STATUS  == '7'} COLOR "WHITE"		TITLE	STR0146 Of oBrowse // "Com erro na realização" 
ADD LEGEND DATA {|| FV0_STATUS  == '8'} COLOR "GRAY"			TITLE	STR0147 Of oBrowse // "Com erro no cancelamento"
ADD LEGEND DATA {|| FV0_STATUS  == '9'} COLOR "BR_VIOLETA"	TITLE	STR0148 Of oBrowse // "Com erro no estorno"
ADD LEGEND DATA {|| FV0_STATUS  == 'A'} COLOR "BLACK"		TITLE	STR0161 Of oBrowse // "Expirado"

oBrowse:SetMenuDef("FINA761")

If !GetHlpLGPD({"A2_NOME"})
	oBrowse:Activate()
Endif

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcão responsável pela geração do modelo de dados da rotina.

@author Marylly Araújo Silva
@since 25/11/2014
@version 1.0
@return oModel Retorna o objeto do modelo de dados do cadastro de documento habéis

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel		:= MPFormModel():New('FINA761',/*bPre*/,{||F761ValDH()},{|oModel| F761Grava(oModel) }/*bCommit*/, {||LimpaTMP( .T. )}/*bCancel*/)
Local oStruDI		:= EstrCabDI()
Local oStruDO		:= EstrDO()
Local oStruSit		:= EstrSitua()
Local oStruEmp		:= EstrEmpenh()
Local oStruFav		:= EstrFav()
Local oStruFV8		:= F761EstFV8() 
Local oStruFV9		:= F761EstFV9() 
Local oStruFVD		:= F761EstFVD()
Local oStruFVL		:= F761EstFVL()
Local oStruFVM		:= F761EstFVM()
Local oStruFVB		:= F761EstFVB()
Local oStruFVA		:= F761EstFVA()
Local oStruFVE		:= F761EstFVE()
Local oStruFVF		:= F761EstFVF()	
Local oStruFVN		:= FWFormStruct( 1, 'FVN' )		
Local oStruFV7		:= F761EstFV7()
Local oStruFVP		:= FWFormStruct( 1, 'FVP' )
Local oStruFVQ		:= FWFormStruct( 1, 'FVQ' )
Local bFV1LinPre	:= { |oModel, nLine, cAction| FV1LinPre( oModel, nLine, cAction ) }
Local bFVDLinPre	:= { |oModel, nLine, cAction| FVDLinPre( oModel, nLine, cAction ) }
Local bVldLinPre	:= { |oModel, nLine, cAction, cField, xValue, xOldValue| FVldLinPre( oModel, nLine, cAction, cField, xValue, xOldValue ) }
Local bVldLinSit	:= { |oModel, nLine, cAction, cField, xValue, xOldValue| VldLinSit( oModel, nLine, cAction, cField, xValue, xOldValue ) }
Local bFV0FrmPre	:= { |oModel, cAction, cField, xValue| FV0FrmPre( oModel, cAction, cField, xValue ) }
Local nIndFV5       := Iif(FWSIXUtil():ExistIndex('FV5' , '3'), 3,1)
Local nIndFVE       := Iif(FWSIXUtil():ExistIndex('FVE' , '3'), 3,1)

oModel:SetDescription(STR0013) // "Rotina de Manutenção do Documento Hábil"
//
oStruDI:SetProperty( "FV0_UGEMIT", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "F761IniPad()" ) )
oStruDI:SetProperty( "FV0_UGDESC", MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "POSICIONE('CPA', 1, xFilial('CPA') + F761IniPad(),'CPA_DESORG')" ) )

//Define as validações dos campos de Situação, para não deixar digitar uma situação que não está relaciona a aba em questão na FVK
oStruSit:SetProperty( "FV2_SITUAC", MODEL_FIELD_VALID, {|oModelSit, cCampo, cSituac, nLinha| VldSituac( oModelSit, cCampo, cSituac, nLinha, ABA_PCO ) } )
oStruFV8:SetProperty( "FV8_SITUAC", MODEL_FIELD_VALID, {|oModelSit, cCampo, cSituac, nLinha| VldSituac( oModelSit, cCampo, cSituac, nLinha, ABA_PSO ) } )
oStruFVA:SetProperty( "FVA_SITUAC", MODEL_FIELD_VALID, {|oModelSit, cCampo, cSituac, nLinha| VldSituac( oModelSit, cCampo, cSituac, nLinha, ABA_OUTROS_LANCAMENTOS ) } )
oStruFVB:SetProperty( "FVB_SITUAC", MODEL_FIELD_VALID, {|oModelSit, cCampo, cSituac, nLinha| VldSituac( oModelSit, cCampo, cSituac, nLinha, ABA_ENCARGOS ) } )
oStruFVD:SetProperty( "FVD_SITUAC", MODEL_FIELD_VALID, {|oModelSit, cCampo, cSituac, nLinha| VldSituac( oModelSit, cCampo, cSituac, nLinha, ABA_DEDUCAO ) } )
oStruFVL:SetProperty( "FVL_SITUAC", MODEL_FIELD_VALID, {|oModelSit, cCampo, cSituac, nLinha| VldSituac( oModelSit, cCampo, cSituac, nLinha, ABA_DESPESAS_ANULAR ) } )

oModel:Addfields("CABDI",/*cOwner*/,oStruDI /*oStruct*/, bFV0FrmPre /*bPre*/,/*bPost*/,/*bLoad*/)
oModel:GetModel("CABDI"):SetDescription(STR0014) // "Cabeçalho do Documento Hábil"
//
oModel:AddGrid("DOCORI","CABDI",oStruDO,bFV1LinPre,{||F761ValDoc()})
oModel:GetModel("DOCORI"):SetDescription(STR0016) // "Documentos de Origem"
//
oModel:AddGrid("PCOSITUACA","CABDI",oStruSit,bVldLinPre)
oModel:GetModel("PCOSITUACA"):SetDescription(STR0017) // "Situações da Seção 'Principal com Orçamento'"
//
oModel:AddGrid("PCOEMPENHO","PCOSITUACA",oStruEmp,,{|oModelNEmp| F761VLinEm(oModelNEmp)  })
oModel:GetModel("PCOEMPENHO"):SetDescription(STR0018) // "Relação de Empenhos do Documento Hábil"
//
oModel:AddGrid("DADOPAGFAV","CABDI",oStruFav)
oModel:GetModel("DADOPAGFAV"):SetDescription(STR0020) // "Dados de Pagamento dos Favorecidos do Documento Hábil"

//Acrescimos - Aba Principal com Orçamento
oModel:AddGrid("DETFVFPCO","PCOSITUACA",oStruFVF)

//Principal sem Orçamento
oModel:AddGrid("DETFV8","CABDI",oStruFV8,bVldLinSit) 
oModel:AddGrid("DETFV9","DETFV8",oStruFV9)

//Acrescimos - Aba Principal com Orçamento
oModel:AddGrid("DETFVFPSO","DETFV8",oStruFVF)

//Deduções
oModel:AddGrid("DETFVD","CABDI", oStruFVD,bFVDLinPre)

//Acrescimos - Aba Deduções
oModel:AddGrid("DETFVF","DETFVD",oStruFVF)

//Recolhedores - Aba Deduções
oModel:AddGrid("DETFVE","DETFVD",oStruFVE)
	
//Despesas a Anular
oModel:AddGrid("DETFVL","CABDI", oStruFVL)
oModel:AddGrid("DETFVM","DETFVL",oStruFVM) 

//Encargos
oModel:AddGrid("DETFVB","CABDI", oStruFVB)

//Acrescimos - Aba Encargos
oModel:AddGrid("DETFVFEN","DETFVB",oStruFVF)

//Recolhedores - Aba Encargos
oModel:AddGrid("DETFVEEN","DETFVB",oStruFVE)

//Outros Lançamentos.
oModel:AddGrid("DETFVA","CABDI", oStruFVA)

//Campos Variaveis
oModel:AddGrid("DETFVN","CABDI", oStruFVN)

//Pré-Documento
oModel:AddGrid("DETFV7","CABDI",oStruFV7)

//Situações x Titulos com Impostos
oModel:AddGrid("DETFVP","DETFVD",oStruFVP)

//Cabeçalho do Documento Hábil x Ordens Bancárias
oModel:AddGrid('DETFVQ','CABDI',oStruFVQ)

//Deixa o preenchimento como opcional e as validações serão feitas no pós
oModel:GetModel( 'DOCORI' ):SetOptional( .T. )		//FV1
oModel:GetModel( 'PCOSITUACA' ):SetOptional( .T. )	//FV2
oModel:GetModel( 'PCOEMPENHO' ):SetOptional( .T. )	//FV5
oModel:GetModel( 'DADOPAGFAV' ):SetOptional( .T. )	//FV6
oModel:GetModel( 'DETFV8' ):SetOptional( .T. )
oModel:GetModel( 'DETFV9' ):SetOptional( .T. )
oModel:GetModel( 'DETFVD' ):SetOptional( .T. )
oModel:GetModel( 'DETFVL' ):SetOptional( .T. )
oModel:GetModel( 'DETFVM' ):SetOptional( .T. )
oModel:GetModel( 'DETFVB' ):SetOptional( .T. )
oModel:GetModel( 'DETFVA' ):SetOptional( .T. )
oModel:GetModel( 'DETFVE' ):SetOptional( .T. )
oModel:GetModel( 'DETFVF' ):SetOptional( .T. )
oModel:GetModel( 'DETFVN' ):SetOptional( .T. )		
oModel:GetModel( 'DETFVP' ):SetOptional( .T. )		
oModel:GetModel( 'DETFV7' ):SetOptional( .T. )	//predoc
oModel:GetModel( 'DETFVFEN' ):SetOptional( .T. )		
oModel:GetModel( 'DETFVEEN' ):SetOptional( .T. )
oModel:GetModel( 'DETFVFPCO' ):SetOptional( .T. )
oModel:GetModel( 'DETFVFPSO' ):SetOptional( .T. )
oModel:GetModel( 'DETFVQ' ):SetOptional( .T. )

//Totalizadores
oModel:AddCalc( 'TOTDBA', 'CABDI', 'DOCORI', 'FV1_VALOR', 'TOT_DBA', 'SUM',,, STR0062 ) // Documentos de Origem'
oModel:AddCalc( 'TOTPSC', 'PCOSITUACA', 'PCOEMPENHO', 'FV5_EVALOR', 'TOT_PSC', 'SUM',,,STR0064) // 'Notas de Empenho' 
oModel:AddCalc( 'TOTPSO', 'DETFV8', 'DETFV9', 'FV9_VALOR', 'TOT_PSO', 'SUM',,, STR0069 ) //'Itens sem Orçamento'
oModel:AddCalc( 'TOTOLS', 'CABDI', 'DETFVA', 'FVA_VALOR', 'TOT_OLS', 'SUM',,,STR0026 ) // 'Outros Lançamentos'
oModel:AddCalc( 'TOTENC', 'CABDI', 'DETFVB', 'FVB_VALOR', 'TOT_ENC', 'SUM',,,STR0027 ) // 'Encargos'
oModel:AddCalc( 'TOTDED', 'CABDI', 'DETFVD', 'FVD_VALOR', 'TOT_DED', 'SUM',,,STR0028 ) // 'Deduções'
oModel:AddCalc( 'TOTACR', 'DETFVD', 'DETFVF', 'FVF_VALOR', 'TOT_ACR', 'SUM',,,STR0070,{ |oModel| TotAcres(oModel)} ) // 'Acréscimos'
oModel:AddCalc( 'TOTREC', 'DETFVD', 'DETFVE', 'FVE_VLRINS', 'TOT_REC', 'SUM',,,STR0071) // 'Recolhedores' 
oModel:AddCalc( 'TOTDSP', 'DETFVL', 'DETFVM', 'FVM_VALOR', 'TOT_DSP', 'SUM',,, STR0072 ) // 'Itens'
oModel:AddCalc( 'TOTDPG', 'CABDI', 'DADOPAGFAV', 'FV6_VALOR', 'TOT_DPG', 'SUM',,, STR0066) // 'Dados do Favorecido' 

oModel:SetPrimaryKey({})

oModel:SetRelation('DOCORI'		,{ {'FV1_FILIAL','XFILIAL("FV1")'}, {'FV1_CODPRO','FV0_CODIGO'}  }, FV1->(IndexKey(1)) )
oModel:SetRelation('PCOSITUACA'	,{ {'FV2_FILIAL','XFILIAL("FV2")'} ,{'FV2_CODPRO','FV0_CODIGO'} }, FV2->(IndexKey(1)) )
oModel:SetRelation('PCOEMPENHO'	,{ {'FV5_FILIAL','XFILIAL("FV5")'} ,{'FV5_CODPRO','FV0_CODIGO'}, {'FV5_SITUAC','FV2_SITUAC'},{'FV5_ITEFV2','FV2_ITEM'} }, FV5->(IndexKey(nIndFV5)) )
oModel:SetRelation('DADOPAGFAV'	,{ {'FV6_FILIAL','XFILIAL("FV6")'} ,{'FV6_CODPRO','FV0_CODIGO'} }, FV6->(IndexKey(1)) )

//FVF -> FV2
oModel:SetRelation('DETFVFPCO'		,{ {'FVF_FILIAL','XFILIAL("FVF")'} ,{'FVF_CODPRO','FV0_CODIGO'} ,;
										{'FVF_SECAO',"'000002'"},{'FVF_SITUAC','FV2_SITUAC'},;
										{'FVF_ITETAB','FV2_ITEM'} } ,FVF->(IndexKey(1)) )
										
//FV8 -> FV0
oModel:SetRelation('DETFV8'		,{ {'FV8_FILIAL','XFILIAL("FV8")'} ,{'FV8_CODPRO','FV0_CODIGO'} }, FV8->(IndexKey(1)) )
//FV9 -> FV8
oModel:SetRelation('DETFV9'		,{ {'FV9_FILIAL','XFILIAL("FV9")'} ,{'FV9_CODPRO','FV0_CODIGO'} ,;
									   {'FV9_SITUAC','FV8_SITUAC'} 		,{'FV9_ITEFV8','FV8_ITEM'  }}, FV9->(IndexKey(1)) )
									   
//FVF -> FV8
oModel:SetRelation('DETFVFPSO'		,{ {'FVF_FILIAL','XFILIAL("FVF")'} ,{'FVF_CODPRO','FV0_CODIGO'} ,;
										{'FVF_SITUAC','FV8_SITUAC'}		,{'FVF_ITETAB','FV8_ITEM'} ,;
										{'FVF_SECAO',"'000003'"}} ,FVF->(IndexKey(1)) )		 
//FVA -> FV0
oModel:SetRelation('DETFVA'		,{ {'FVA_FILIAL','XFILIAL("FVA")'} ,{'FVA_CODPRO','FV0_CODIGO'}}, FVA->(IndexKey(1)) ) 
//FVB -> FV0
oModel:SetRelation('DETFVB'		,{ {'FVB_FILIAL','XFILIAL("FVB")'} ,{'FVB_CODPRO','FV0_CODIGO'}}, FVB->(IndexKey(1)) )
//FVD -> FV0
oModel:SetRelation('DETFVD'		,{ {'FVD_FILIAL','XFILIAL("FVD")'} ,{'FVD_CODPRO','FV0_CODIGO'}}, FVD->(IndexKey(1)) )
//FVE -> FVD
oModel:SetRelation('DETFVE'		,{ {'FVE_FILIAL','XFILIAL("FVE")'} ,{'FVE_CODPRO','FV0_CODIGO'} ,;
										{'FVE_SITUAC','FVD_SITUAC'}		,{'FVE_ITETAB','FVD_ITEM'},;
										{'FVE_TABREL',"'FVD'"}} ,FVE->(IndexKey(nIndFVE)) )									
//FVE -> FVB
oModel:SetRelation('DETFVEEN'		,{ {'FVE_FILIAL','XFILIAL("FVE")'} ,{'FVE_CODPRO','FV0_CODIGO'} ,;
										{'FVE_SITUAC','FVB_SITUAC'}		,{'FVE_ITETAB','FVB_ITEM'},;
										{'FVE_TABREL',"'FVB'"}} ,FVE->(IndexKey(nIndFVE)) )
//FVF -> FVD
oModel:SetRelation('DETFVF'		,{ {'FVF_FILIAL','XFILIAL("FVF")'} ,{'FVF_CODPRO','FV0_CODIGO'} ,;
										{'FVF_SECAO',"'000006'"} ,{'FVF_SITUAC','FVD_SITUAC'},;
										{'FVF_ITETAB','FVD_ITEM'}} ,FVF->(IndexKey(1)) )	
//FVF -> FVB
oModel:SetRelation('DETFVFEN'		,{ {'FVF_FILIAL','XFILIAL("FVF")'} ,{'FVF_CODPRO','FV0_CODIGO'} ,;
										{'FVF_SECAO',"'000007'"}, {'FVF_SITUAC','FVB_SITUAC'},;
										{'FVF_ITETAB','FVB_ITEM'}} ,FVF->(IndexKey(1)) )
//FVL -> FV0
oModel:SetRelation('DETFVL'		,{ {'FVL_FILIAL','XFILIAL("FVL")'} ,{'FVL_CODPRO','FV0_CODIGO'}} , FVL->(IndexKey(1)) )
//FVM -> FVL
oModel:SetRelation('DETFVM'		,{ {'FVM_FILIAL','XFILIAL("FVM")'} ,{'FVM_CODPRO','FV0_CODIGO'},{'FVM_ITEFVL','FVL_ITEM'},{'FVM_SITUAC','FVL_SITUAC'}}, FVM->(IndexKey(2)) )
									
//FVN -> FV2
oModel:SetRelation('DETFVN'		,{ {'FVN_FILIAL','XFILIAL("FVN")'} ,{'FVN_CODPRO','FV0_CODIGO'}}, FVN->(IndexKey(1)) )

//FV7 -> FV0
oModel:SetRelation('DETFV7'		,{ {'FV7_FILIAL','XFILIAL("FV7")'} ,{'FV7_CODPRO','FV0_CODIGO'}}, FV7->(IndexKey(1)) )

//FVP -> FVD
oModel:SetRelation('DETFVP'		,{ {'FVP_FILIAL','XFILIAL("FVP")'} ,{'FVP_CODPRO','FV0_CODIGO'}, ;
{'FVP_SITUAC','FVD_SITUAC'} ,{'FVP_ITEM','FVD_ITEM'}	}, FVP->(IndexKey(1)))

//FVQ -> FV0
oModel:SetRelation( 'DETFVQ', { { 'FVQ_FILIAL' ,'xFilial("FVQ")' }, { 'FVQ_CODPRO' ,'FV0_CODIGO' } }, FVQ->( IndexKey(1) ) )

oModel:GetModel("DOCORI"):SetUniqueLine({'FV1_PREFIX','FV1_NUMERO','FV1_PARCEL','FV1_TIPO'},{||Help(" ",1,"DOCUMENTO",,STR0097,3,1)}) //"Documento ja selecionado."	

oModel:GetModel('DETFVE'):SetDescription(STR0071) //'Recolhedores' 
oModel:GetModel('DETFVF'):SetDescription(STR0070) //'Acrescimos' 

oModel:SetVldActivate( {|oModel| F761VLMod(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao reponsavel pela View

@author Marylly Araújo Silva
@since 25/11/2014
@version 1.0
@return oView Retorna o objeto da interface do cadastro de documento hábil.

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel	:= FWLoadModel('FINA761')
Local oStruDI	:= VStrucDI()
Local oStrDba	:= FWCalcStruct(oModel:GetModel('TOTDBA'))

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VCABDI",oStruDI,"CABDI")
oView:AddOtherObject("DYNAMIC",{|x|DynaActiv(x,oView)},{|x|DynaDectiv(x)})
oView:AddField("VTOTVLR",oStrDba,'TOTDBA')

oView:CreateHorizontalBox( 'SUPERIOR' , 31 )
oView:CreateHorizontalBox( 'OUTRAVIEW' , 61 )
oView:CreateHorizontalBox( 'TVLRDOC' , 8 )

oView:EnableTitle('VCABDI'		, STR0061) // 'Cabeçalho do DH'

oView:SetOwnerView( 'VCABDI'	, 'SUPERIOR'  )
oView:SetOwnerView( 'DYNAMIC'	, 'OUTRAVIEW'  )
oView:SetOwnerView('VTOTVLR','TVLRDOC')

oView:SetFieldAction("FV0_TIPODC"	,{ |oView, cIDView, cField, xValue| F761FdAct(oView, cIDView, cField, xValue)	} )
oView:SetFieldAction("FV0_FORNEC"	,{ |oView, cIDView, cField, xValue| F761FdAct(oView, cIDView, cField, xValue)	} )
oView:SetFieldAction("FV0_LOJA"		,{ |oView, cIDView, cField, xValue| F761FdAct(oView, cIDView, cField, xValue)	} )
oView:SetFieldAction("FV0_UGPAGA"	,{ |oView, cIDView, cField, xValue| F761FdAct(oView, cIDView, cField, xValue)	} )

oView:AddUserButton( STR0276, '', { | oView | FINA761OBR( oView ) }, , , { MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE, MODEL_OPERATION_DELETE } )

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} DynaActiv
Ativação dinâmica das abas do documento hábil de acordo com o tipo de documento informado no cabeçalho.

@author Marylly Araújo Silva
@since 10/02/2015
@version 1.0

@param oPanel 		Objeto do Painel onde ficará disponível a View Filha para exibição das abas do documento hábil.
@param oViewPai		View da interface do cabeçalho do documento hábil.

/*/
//-------------------------------------------------------------------
Static Function DynaActiv(oPanel,oViewPai)
Local oView 
Local oModelPai := oViewPai:GetModel()
@assume oView as FWFormView
oView := ViewDefDynamic(oViewPai)
oView:SetOwner(oPanel)
oView:SetOperation(oModelPai:GetOperation())
oView:Activate()
__oViewDynamic := oView 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DynaDectiv
Desativação e desalocação da mémoria ocupada pela View de Abas do documento hábil.

@author Marylly Araújo Silva
@since 10/02/2015
@version 1.0
@param oPanel		Objeto do Painel onde ficará disponível a View Filha para exibição das abas do documento hábil.

/*/
//-------------------------------------------------------------------
Static Function DynaDectiv(oPanel)
__oViewDynamic:Destroy() 
If oPanel != Nil
	oPanel:FreeChildren()
EndIf
__oViewDynamic := Nil
__aFolder := aSize(__aFolder,0)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DynaDectiv
Desativação e desalocação da mémoria ocupada pela View de Abas do documento hábil.

@author Marylly Araújo Silva
@since 10/02/2015
@version 1.0

@param	oViewPai	View da interface do cabeçalho do documento hábil.
@return	oView	Objeto da View pendurada no OtherObject da View Principal 

/*/
//-------------------------------------------------------------------
Static Function ViewDefDynamic(oViewPai)
Local oView		:=	Nil
Local oModel		:=	oViewPai:GetModel()
Local cTipoDoc	:=	oModel:GetModel("CABDI"):GetValue("FV0_TIPODC")
Local cFVHChv		:=	FWXFILIAL("FVH") + cTipoDoc
Local aArea		:=	GetArea()
Local aFVHArea	:=	{}
//Estrutura de Models dos Totalizadores da Aba de Resumo
Local oStrDba	:=	FWCalcStruct(oModel:GetModel('TOTDBA'))
Local oStrPsc	:=	FWCalcStruct(oModel:GetModel('TOTPSC'))
Local oStrPso	:=	FWCalcStruct(oModel:GetModel('TOTPSO'))
Local oStrOls	:=	FWCalcStruct(oModel:GetModel('TOTOLS'))
Local oStrEnc	:=	FWCalcStruct(oModel:GetModel('TOTENC'))
Local oStrDed	:=	FWCalcStruct(oModel:GetModel('TOTDED'))
Local oStrAcr	:=	FWCalcStruct(oModel:GetModel('TOTACR'))
Local oStrRec	:=	FWCalcStruct(oModel:GetModel('TOTREC'))
Local oStrDsp	:=	FWCalcStruct(oModel:GetModel('TOTDSP'))
Local oStrDpg	:=	FWCalcStruct(oModel:GetModel('TOTDPG'))

oView := FWFormView():New(oViewPai)
oView:SetModel(oModel)
oView:CreateHorizontalBox( 'TELA', 100 )
oView:CreateFolder( 'PRINCIPAL','TELA')

DbSelectArea("FVH")
aFVHArea := FVH->(GetArea())
FVH->(DbSetOrder(1))  // Filial + Tipo de Documento + Seção
FVH->(DbSeek( cFVHChv ))
While FVH->(!Eof()) .AND. cFVHChv == FVH->FVH_FILIAL + FVH->FVH_TIPODC
	GetAbaView(oView,oViewPai,FVH->FVH_SECAO)
	If FVH->FVH_SECAO == ABA_DADOS_BASICOS
		oView:AddSheet( 'PRINCIPAL', 'DADOSBASIC'	,STR0022) // 'Dados Básicos'
	ElseIf FVH->FVH_SECAO == ABA_PCO
		oView:AddSheet( 'PRINCIPAL', 'PRINCORCA'	,STR0023) // 'Principal com Orçamento'
	ElseIf FVH->FVH_SECAO == ABA_PSO
		oView:AddSheet( 'PRINCIPAL', 'PRINSORCA'	,STR0024) // 'Principal sem Orçamento'
	ElseIf FVH->FVH_SECAO == ABA_OUTROS_LANCAMENTOS
		oView:AddSheet( 'PRINCIPAL', 'OUTROS'		,STR0026) // 'Outros Lançamentos'
	ElseIf FVH->FVH_SECAO == ABA_DEDUCAO
		oView:AddSheet( 'PRINCIPAL', 'DEDUCOES'		,STR0028) // 'Deduções'
	ElseIf FVH->FVH_SECAO == ABA_ENCARGOS
		oView:AddSheet( 'PRINCIPAL', 'ENCARGOS'		,STR0027) // 'Encargos'
	ElseIf FVH->FVH_SECAO == ABA_DESPESAS_ANULAR
		oView:AddSheet( 'PRINCIPAL', 'ANULAR'		,STR0029) // 'Despesas a Anular'
	ElseIf FVH->FVH_SECAO == ABA_DADOS_PAGAMENTO
		oView:AddSheet( 'PRINCIPAL', 'DADOSPAG'		,STR0031) // 'Dados de Pagamento'
	EndIf

	FVH->(DbSkip())
EndDo
oView:AddSheet( 'PRINCIPAL', 'RESUMO'		,STR0032) // 'Resumo'
oView:SelectFolder( 'PRINCIPAL', STR0022 ,2) // 'Dados Básicos'
RestArea(aFVHArea)
RestArea(aArea)

oView:CreateHorizontalBox( 'MSTBOX', 100, /**/, /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')

oView:CreateVerticalBox( '1STBOX', 20,"MSTBOX" /**/, /**/, 'PRINCIPAL', 'RESUMO')
oView:CreateVerticalBox( '2NDBOX', 20,"MSTBOX" /**/, /**/, 'PRINCIPAL', 'RESUMO')
oView:CreateVerticalBox( '3RDBOX', 20,"MSTBOX" /**/, /**/, 'PRINCIPAL', 'RESUMO')
oView:CreateVerticalBox( '4THBOX', 20,"MSTBOX" /**/, /**/, 'PRINCIPAL', 'RESUMO')
oView:CreateVerticalBox( '5THBOX', 20,"MSTBOX" /**/, /**/, 'PRINCIPAL', 'RESUMO')

oView:CreateHorizontalBox( 'RESUMODBC', 50, '1STBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMOPSC', 50, '1STBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMOPSO', 50, '2NDBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMOOLS', 50, '2NDBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMOENC', 50, '3RDBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMODED', 25, '3RDBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMOREC', 25, '3RDBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMODSP', 50, '4THBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMODPG', 50, '4THBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')
oView:CreateHorizontalBox( 'RESUMOACR', 50, '5THBOX', /*lUsePixel*/, 'PRINCIPAL', 'RESUMO')

oView:AddField('RESDBA',oStrDba,'TOTDBA')
oView:SetViewProperty('RESDBA','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESPSC',oStrPsc,'TOTPSC')
oView:SetViewProperty('RESPSC','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESPSO',oStrPso,'TOTPSO')
oView:SetViewProperty('RESPSO','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESOLS',oStrOls,'TOTOLS')
oView:SetViewProperty('RESOLS','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESENC',oStrEnc,'TOTENC')
oView:SetViewProperty('RESENC','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESDED',oStrDed,'TOTDED')
oView:SetViewProperty('RESDED','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESACR',oStrAcr,'TOTACR')
oView:SetViewProperty('RESACR','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESREC',oStrRec,'TOTREC')
oView:SetViewProperty('RESREC','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESDSP',oStrDsp,'TOTDSP')
oView:SetViewProperty('RESDSP','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:AddField('RESDPG',oStrDpg,'TOTDPG')
oView:SetViewProperty('RESDPG','SETLAYOUT',{FF_LAYOUT_VERT_DESCR_TOP ,-1})
oView:EnableTitleView('RESDBA' , STR0022) //'Dados Básicos'
oView:SetOwnerView('RESDBA','RESUMODBC')
oView:EnableTitleView('RESDBA' , STR0022) //'Dados Básicos'
oView:SetOwnerView('RESPSC','RESUMOPSC')
oView:EnableTitleView('RESPSC' , STR0023) //'Principal com Orçamento'
oView:SetOwnerView('RESPSO','RESUMOPSO')
oView:EnableTitleView('RESPSO' , STR0024) //'Principal sem Orçamento'
oView:SetOwnerView('RESOLS','RESUMOOLS')
oView:EnableTitleView('RESOLS' , STR0026) //'Outros Lançamentos'
oView:SetOwnerView('RESENC','RESUMOENC')
oView:EnableTitleView('RESENC' , STR0027) //'Encargos'
oView:SetOwnerView('RESDED','RESUMODED')
oView:EnableTitleView('RESDED' , STR0028) //'Deduções'
oView:SetOwnerView('RESACR','RESUMOACR')
oView:EnableTitleView('RESACR' , STR0070) //'Acréscimos'
//Recolhedores
oView:SetOwnerView('RESREC','RESUMOREC')
oView:SetOwnerView('RESDSP','RESUMODSP')
oView:EnableTitleView('RESDSP' , STR0029) //'Despesas a Anular'
oView:SetOwnerView('RESDPG','RESUMODPG')
oView:EnableTitleView('RESDPG' , STR0031) //'Dados de Pagamento'

oView:SetVldFolder({|cFolderID, nOldSheet, nSelSheet| F761VldPasta(cFolderID, nOldSheet, nSelSheet,oView,oViewPai)})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definição do menu da tela de cadastro do Documento Hábil

@author Pedro Alencar	
@since 08/01/2015	
@version 12.1.3
@return aRotina Array com as configurações das opções do menu da rotina
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina    := {}
	
	ADD OPTION aRotina TITLE OemToAnsi(STR0008) ACTION "FINA761MAN(1)"	OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0009) ACTION "FINA761MAN(2)"	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE OemToAnsi(STR0010) ACTION "FINA761MAN(3)"	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0012) ACTION "FINA761MAN(4)"	OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE OemToAnsi(STR0011) ACTION "VIEWDEF.FINA761"	OPERATION 8 ACCESS 0 //"Imprimir"
	ADD OPTION aRotina TITLE OemToAnsi(STR0055) ACTION "Fina761Env(1)"		OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Enviar" 
	ADD OPTION aRotina TITLE OemToAnsi(STR0056) ACTION "Fina761Env(3)"		OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Realizar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0057) ACTION "Fina761Env(7)"		OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Realizar por Lote"
	ADD OPTION aRotina TITLE OemToAnsi(STR0058) ACTION "Fina761Env(2)"		OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Cancelar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0059) ACTION "Fina761Env(4)"		OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Estornar"
	ADD OPTION aRotina TITLE OemToAnsi(STR0060) ACTION "F761LOG()"			OPERATION 9 ACCESS 0 //"Transações"	 
	
	//---------------------------------------------------------------
	// Ponto de entrada para inclusão de novos itens no menu aRotina
	//---------------------------------------------------------------
	If lFa761Rot
		aRotina := ExecBlock("FA761ROT", .F., .F., aRotina)
	EndIf

Return aRotina

/*/{Protheus.doc} F761EstFV9
Estrutura da tabela FV9
@author William Matos
@since 19/12/2014
@version P12
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
Function F761EstFV9()
Local oStruct := FWFormStruct(1, 'FV9')

oStruct:AddTrigger('FV9_CATGAS','FV9_NCATGA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, FWxFilial('SX5') +'NX'+ oModel:GetValue('FV9_CATGAS') , 'X5_DESCRI')})
oStruct:SetProperty('FV9_NCATGA', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "IIF(!INCLUI,POSICIONE('SX5', 1, xFilial('SX5') + 'NX' + FV9->FV9_CATGAS, 'X5_DESCRI'),'')" ))

oStruct:AddTrigger('FV9_FONREC','FV9_NFONRE',{ || .T.}/*bPre*/,{ |oModel| F761GatFRec( oModel:GetValue('FV9_FONREC') ) })
oStruct:AddTrigger('FV9_NEMPE','FV9_FONREC',{ || .T.}/*bPre*/,{ |oModel| F761GatNE(FWxFilial("FV9"),oModel:GetValue('FV9_NEMPE'),"FV9_NFONRE",'DETFV9') })
oStruct:SetProperty('FV9_NFONRE', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "F761GatFRec( FV9->FV9_FONREC )" ))

Return oStruct

/*/{Protheus.doc} F761EstFV8
Estrutura da tabela FV8
@author William Matos
@since 19/12/2014
@version P12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados

/*/
Function F761EstFV8()
Local oStruct		:= FWFormStruct(1, 'FV8')

oStruct:AddTrigger('FV8_SITUAC','FV8_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetValue("FV8_SITUAC"), 'FVJ_DESCRI')})

Return oStruct

/*/{Protheus.doc} F761EstFVA
Estrutura da tabela FVA
@author William Matos
@since 19/12/2014
@version P12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
Function F761EstFVA()
Local oStruct := FWFormStruct(1, 'FVA')

oStruct:AddTrigger('FVA_SITUAC','FVA_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetValue("FVA_SITUAC"), 'FVJ_DESCRI')})
Return oStruct

/*/{Protheus.doc} F761EstFVB
Estrutura da tabela FVB
@author William Matos
@since 19/12/2014
@version P12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
Function F761EstFVB()
Local oStruct := FWFormStruct(1, 'FVB')

oStruct:AddTrigger('FVB_SITUAC','FVB_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetValue("FVB_SITUAC"), 'FVJ_DESCRI')})
oStruct:AddTrigger('FVB_UGEMPE','FVB_NUGEMP',{ || .T.}/*bPre*/,{ |oModel| Posicione('CPA', 1, xFilial('CPA') + oModel:GetValue("FVB_UGEMPE"),'CPA_DESORG')})

oStruct:AddTrigger('FVB_FONREC','FVB_NFONRE',{ || .T.}/*bPre*/,{ |oModel| F761GatFRec( oModel:GetValue('FVB_FONREC') ) })
oStruct:AddTrigger('FVB_NEMPE','FVB_FONREC',{ || .T.}/*bPre*/,{ |oModel| F761GatNE(FWxFilial("FVB"),oModel:GetValue('FVB_NEMPE'),"FVB_NFONRE",'DETFVB') })
oStruct:SetProperty('FVB_NFONRE', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "F761GatFRec( FVB->FVB_FONREC )" ))

Return oStruct

/*/{Protheus.doc} F761EstFVD
Estrutura da tabela FVD
@author William Matos
@since 19/12/2014
@version P12.1.4
@return oStruct Objeto com as definições de estrutura de modelo de dados
/*/
Function F761EstFVD()
Local oStruct := FWFormStruct(1, 'FVD')

oStruct:AddTrigger('FVD_SITUAC','FVD_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetValue("FVD_SITUAC"), 'FVJ_DESCRI')})

Return oStruct

/*/{Protheus.doc} F761EstFVE
Estrutura da tabela FVE
@author Marylly Araújo Silva
@since 09/02/2015
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
Function F761EstFVE()
Local oStruct := FWFormStruct(1, 'FVE')

oStruct:AddTrigger('FVE_FORNEC','FVE_FORNEC',/*bPre*/,{ |oModel| F761FVEGAT(oModel) })

Return oStruct

/*/{Protheus.doc} F761EstFVF
Estrutura da tabela FVF
@author Marylly Araújo Silva
@since 23/02/2015
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
Function F761EstFVF()
Local oStruct := FWFormStruct(1, 'FVF')

oStruct:AddTrigger('FVF_FONREC','FVF_NFONRE',{ || .T.}/*bPre*/,{ |oModel| F761GatFRec( oModel:GetValue('FVF_FONREC') ) })
oStruct:AddTrigger('FVF_NEMPE','FVF_FONREC',{ || .T.}/*bPre*/,{ |oModel| F761GatNE(FWxFilial("FVF"),oModel:GetValue('FVF_NEMPE'),"FVF_NFONRE",'DETFVF') })
oStruct:SetProperty('FVF_NFONRE', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "F761GatFRec( FVF->FVF_FONREC )" ))

Return oStruct

/*/{Protheus.doc} F761EstFVK
Estrutura da tabela FVK
@author William Matos
@since 19/12/2014
@version P12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
Function F761EstFVK()
Local oStruct := FWFormStruct(1, 'FVK')

oStruct:AddTrigger('FVK_SITUAC','FVK_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetValue("FVK_SITUAC"), 'FVJ_DESCRI')})

Return oStruct

/*/{Protheus.doc} F761EstFVL
Estrutura da tabela FV8
@author William Matos
@since 19/12/2014
@version P12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados

/*/
Function F761EstFVL()
Local oStruct := FWFormStruct(1, 'FVL')

oStruct:AddTrigger('FVL_SITUAC','FVL_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetValue("FVL_SITUAC"), 'FVJ_DESCRI')})
oStruct:AddTrigger('FVL_UGEMPE','FVL_NUGEMP',{ || .T.}/*bPre*/,{ |oModel| Posicione('CPA', 1, xFilial('CPA') + oModel:GetValue("FVL_UGEMPE"),'CPA_DESORG')})

Return oStruct

/*/{Protheus.doc} F761EstFVM
Estrutura da tabela FVM
@author Marylly Araújo Silva
@since 23/02/2015
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
Function F761EstFVM()
Local oStruct := FWFormStruct(1, 'FVM')

oStruct:AddTrigger('FVM_FONREC','FVM_NFONRE',{ || .T.}/*bPre*/,{ |oModel| F761GatFRec( oModel:GetValue('FVM_FONREC') ) })
oStruct:AddTrigger('FVM_NEMPE','FVM_FONREC',{ || .T.}/*bPre*/,{ |oModel| F761GatNE(FWxFilial("FVM"),oModel:GetValue('FVM_NEMPE'),"FVM_NFONRE",'DETFVM') })
oStruct:SetProperty('FVM_NFONRE', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "F761GatFRec( FVM->FVM_FONREC )" ))

Return oStruct

/*/{Protheus.doc} F761EstFV7
Estrutura da tabela FV7
@author William Matos
@since 19/12/2014
@version P12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados

/*/
Function F761EstFV7()
Local oStruct := FWFormStruct(1, 'FV7')

Return oStruct

/*/{Protheus.doc} F761VldPasta
Validação no momento da troca de aba do documento hábil
@author William Matos
@since 26/01/2015
@version P12.1.4
@param cFolderID	Identificador da aba que está chamando a validação de abas
@param nOldSheet	Posição da Aba de Origem antes da seleção da nova aba
@param nSelSheet	Posição da Aba Selecionada que chamou a validação de abas
@param oView		Objeto do tipo FWFormView com a interface da view pendurada no OtherObjects da View Principal
@param oViewPai	Objeto do tipo FWFormView com a interface da view Principal
@return lRet		Retorno lógico se a validação concluída com êxito ou não
/*/
Function F761VldPasta(cFolderID,nOldSheet,nSelSheet,oView,oViewPai)
Local oModel		:= oView:GetModel()
Local lRet		:= .T.
Local cIDModel	:= F761AbaAtiva(nSelSheet,oView,oViewPai)
//------------------------------
// 1 - Dados Basicos
// 2 - Principal com Orçamento
// 3 - Principal sem Orçamento
// 4 - Outros lançamentos
// 5 - Encargos
// 6 - Deduções
// 7 - Despesas a Anular
// 8 - Dados do Pagamento 
//-----------------------------

If cFolderID == 'PRINCIPAL' 
	Do Case 
	
		Case cIDModel == 'DETFVD' 	
			If oModel:GetModel('PCOSITUACA'):IsEmpty() .AND. oModel:GetModel('DETFV8'):IsEmpty()
				Help(" ",1,"DOCUMENTO",,STR0073,3,1) //"Para acessar a aba de deduções é necessario informar os dados na aba Principal sem Orçamento ou na aba Principal com Orçamento"
				lRet := .F.
			EndIf
			
		Case cIDModel == 'DETFVL'		
			If oModel:GetModel('PCOSITUACA'):IsEmpty() .AND. oModel:GetModel('DETFVB'):IsEmpty()	
				Help(" ",1,"DOCUMENTO",,STR0074,3,1) // "Para acessar a aba de Despesas a Anular é necessario informar os dados na aba Principal com Orçamento ou na aba de Encargos"
				lRet := .F.
			EndIf
	End Case
EndIf	

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} EstrCabDI

Estrutura de dados para armazenar no modelo dos campos essenciais cadastro do Documen to Hábil

@author marylly.araujo
@since 05/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------
Static Function EstrCabDI()
Local oStruDI	:= FWFormStruct(1,'FV0')

oStruDI:AddField( ;
STR0075							, ;	// [01] Titulo do campo // "Carrega Doc. Relacionados"
STR0076							, ;	// [02] ToolTip do campo // "Carrega Documentos Relacionados"
'BOTAO'          					, ;	// [03] Id do Field
'BT'             					, ;	// [04] Tipo do campo
1               					, ;	// [05] Tamanho do campo
0                					, ;	// [06] Decimal do campo
{ || Iif( FSIFWMarkB( ,'SE2'), VerificaAbas(), ), .T. }			, ;
/*bWhen*/						, ;
/*aValues*/						, ;
.F.								, ;
/*bInit*/						, ;
.F.)

oStruDI:AddField(			  ;
STR0085						, ;	// [01] Titulo do campo			//"UG Pagadora"
STR0086						, ; // [02] ToolTip do campo 	//"Unidade Gestora Pagadora"
"UGPAGA"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
6							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ; // [10] Indica se o campo tem preenchimento obrigatório
FWBuildFeature( STRUCT_FEATURE_INIPAD,"FV0->FV0_UGPAGA"),,,;// [11] Inicializador Padrão do campo
.T.)							//[14] Virtual


oStruDI:AddField(			  ;
STR0087			 			, ;	// [01] Titulo do campo			//"Descrição UG"
STR0088						, ;	// [02] ToolTip do campo	//"Descrição Unidade Gestora"
"UGDESC"						, ;	// [03] Id do Field
"C"							, ;	// [04] Tipo do campo
30							, ;	// [05] Tamanho do campo
0							, ;	// [06] Decimal do campo
{ || .T. }					, ;	// [07] Code-block de validação do campo
{ || .T. }					, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
.F.							, ; // [10] Indica se o campo tem preenchimento obrigatório
{|oModel| Iif(!INCLUI,Posicione('CPA',1,xFilial('CPA') + FV0->FV0_UGPAGA,'CPA_DESORG'),'')},,,;// [11] Inicializador Padrão do campo
.T.)							//[14] Virtual

oStruDI:SetProperty( 'FV0_NTIPDC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,POSICIONE('SX5', 1, xFilial('SX5') + 'NL' + FV0->FV0_TIPODC, 'X5_DESCRI'),'')" ) )
oStruDI:SetProperty( 'FV0_UGDESC', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Posicione('CPA',1,xFilial('CPA') + FV0->FV0_UGEMIT,'CPA_DESORG'),'')" ) )
oStruDI:SetProperty( 'FV0_NFORNE', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Posicione('SA2',1,xFilial('SA2') + FV0->FV0_FORNEC,'A2_NOME'),'')" ) )
oStruDI:SetProperty( 'FV0_UGDSPG', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Posicione('CPA',1,xFilial('CPA') + FV0->FV0_UGPAGA,'CPA_DESORG'),'')" ) )
oStruDI:SetProperty( 'FV0_TIPODC', MODEL_FIELD_NOUPD, .T.)
oStruDI:SetProperty( 'FV0_FORNEC', MODEL_FIELD_NOUPD, .T.)
oStruDI:SetProperty( 'FV0_LOJA'	 , MODEL_FIELD_NOUPD, .T.)
oStruDI:SetProperty( 'FV0_UGPAGA', MODEL_FIELD_NOUPD, .T.)
oStruDI:SetProperty( 'BOTAO'     , MODEL_FIELD_WHEN, {|oModel| !Empty(oModel:GetValue('FV0_FORNEC')) .AND. !Empty(oModel:GetValue('FV0_TIPODC'))})	

oStruDI:AddTrigger('FV0_TIPODC','FV0_NTIPDC',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('SX5', 1, xFilial('SX5') + 'NL' + oModel:GetModel("CABDI"):GetValue("CABDI","FV0_TIPODC"), 'X5_DESCRI')})
oStruDI:AddTrigger('FV0_UGEMIT','FV0_UGDESC',{ || .T.}/*bPre*/,{ |oModel| Posicione('CPA',1,xFilial('CPA') + oModel:GetModel("CABDI"):GetValue("CABDI","FV0_UGEMIT"),'CPA_DESORG')})
oStruDI:AddTrigger('FV0_UGPAGA','FV0_UGPAGA',{ || .T.}/*bPre*/,{ |oModel| F761UGGAT(oModel) })
oStruDI:AddTrigger('FV0_FORNEC','FV0_NFORNE',{ || .T.}/*bPre*/,{ |oModel| Posicione("SA2",1,xFilial("SA2")+oModel:GetModel("CABDI"):GetValue("CABDI","FV0_FORNEC","A2_NOME"),'A2_NOME')})
oStruDI:AddTrigger('FV0_FORNEC','FV0_LOJA'  ,{ || .T.}/*bPre*/,{ |oModel| GatForn("E2_LOJA")}) 	

Return oStruDI

//------------------------------------------------------------------- 
/*/{Protheus.doc} VStrucDI

Estrutura de interface para as informações essenciais do cadastro do Documento Hábil.

@author marylly.araujo
@since 05/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------

Static Function VStrucDI()
/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruDI	:= FWFormStruct(2,'FV0', { |x| ALLTRIM(x) $ 'FV0_FILIAL, FV0_UGEMIT, FV0_UGDESC, FV0_TIPODC, FV0_NTIPDC, FV0_CODSIA, FV0_FORNEC, FV0_NFORNE, FV0_LOJA,FV0_UGPAGA,FV0_UGDSPG' })

oStruDI:AddField(	 				  ;
'BOTAO'							, ;		// [01] Campo
"99"								, ;		// [02] Ordem
STR0075							, ;		// [03] Titulo // "Carrega Doc. Relacionados"
STR0076							, ;		// [04] Descricao // "Carregar Documentos Relacionados"
NIL             					, ;		// [05] Help
'BT'            					)		// [06] Tipo do campo   COMBO, Get ou CHECK

Return oStruDI

//------------------------------------------------------------------- 
/*/{Protheus.doc} VStrucDH

Estrutura de interface para armazenar no modelo dos campos do cabeçalho do cadastro do Documento Hábil.

@author marylly.araujo
@since 05/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------
Static Function VStrucDH()
/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruDH	:= FWFormStruct(2,'FV0', { |x| !ALLTRIM(x) $ 'FV0_FILIAL, FV0_UGEMIT, FV0_UGDESC, FV0_TIPODC, FV0_NTIPDC, FV0_CODSIA, FV0_CODIGO, FV0_FORNEC, FV0_NFORNE, FV0_STATUS, FV0_LOJA, FV0_ATESTE, FV0_DATPAG, FV0_VLRDOC ,FV0_UGPAGA,FV0_UGDSPG' })

Return oStruDH

//-------------------------------------------------------------------
/*/{Protheus.doc} EstrDO

Estrutura de dados para armazenar no modelo os documentos de origem (NFs) do Documento Hábil

@author marylly.araujo
@since 07/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
//-------------------------------------------------------------------

Static Function EstrDO()

Local oStruDocOr:= Nil

oStruDocOr	:= FWFormStruct(1,'FV1',{ |x| !ALLTRIM(x) $ 'FV1_CODPRO'})

oStruDocOr:AddField( ;
"FV1_RECNO"					, ;	// [01] Titulo do campo
"FV1_RECNO"					, ;	// [02] ToolTip do campo
'FV1_RECNO'     				, ;	// [03] Id do Field
'N'             				, ;	// [04] Tipo do campo
10               				, ;	// [05] Tamanho do campo
0                				, ;	// [06] Decimal do campo
/**/							, ;
/*bWhen*/					, ;
/*aValues*/					, ;
.F.							, ;
/*bInit*/					, ;
.F.)


oStruDocOr:AddTrigger('FV1_PREFIX'	,'FV1_PREFIX'	,{ || .T.}/*bPre*/,{ |oModel| F761CargDoc()}) 		
oStruDocOr:AddTrigger('FV1_NUMERO'	,'FV1_NUMERO'	,{ || .T.}/*bPre*/,{ |oModel| F761CargDoc()})
oStruDocOr:AddTrigger('FV1_PARCEL'	,'FV1_PARCEL'  ,{ || .T.}/*bPre*/,{ |oModel| F761CargDoc()})
oStruDocOr:AddTrigger('FV1_TIPO'	,'FV1_TIPO'		,{ || .T.}/*bPre*/,{ |oModel| F761CargDoc()})

Return oStruDocOr

//-------------------------------------------------------------------
/*/{Protheus.doc} VEstrDO

Estrutura de dados para armazenar no modelo de dados dos campos de documentos de origens (NFs) do Documento Hábil

@author marylly.araujo
@since 07/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
//-------------------------------------------------------------------

Static Function VEstrDO()

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruDO	:= FWFormStruct(2,'FV1',{ |x| !ALLTRIM(x) $ 'FV1_CODPRO,FV1_DOCORI'})

Return oStruDO

//-------------------------------------------------------------------
/*/{Protheus.doc} EstrSitua

Estrutura de dados para armazenar no modelo dos campos essenciais cadastro do Documento Hábil

@author marylly.araujo
@since 05/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
//-------------------------------------------------------------------

Static Function EstrSitua()

Local oStruSit	:= Nil

oStruSit	:= FWFormStruct(1,'FV2')
					
oStruSit:SetProperty('FV2_NSITUA', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,POSICIONE('FVJ', 1, FWxFilial('FVJ') + FV2->FV2_SITUAC, 'FVJ_DESCRI'),'')" ) )
oStruSit:SetProperty('FV2_NUGEMP', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,Posicione('CPA',1,xFilial('CPA') +  FV2->FV2_UGEMPE,'CPA_DESORG'),'')" ) )

oStruSit:AddTrigger('FV2_SITUAC','FV2_NSITUA',{ || .T.}/*bPre*/,{ |oModel| POSICIONE('FVJ', 1, FWxFilial('FVJ') + oModel:GetModel("PCOSITUACA"):GetValue("PCOSITUACA","FV2_SITUAC"), 'FVJ_DESCRI')})
oStruSit:AddTrigger('FV2_UGEMPE','FV2_NUGEMP',{ || .T.}/*bPre*/,{ |oModel| Posicione('CPA',1,xFilial('CPA') + oModel:GetModel("PCOSITUACA"):GetValue("PCOSITUACA","FV2_UGEMPE"),'CPA_DESORG') })

Return oStruSit

//-------------------------------------------------------------------
/*/{Protheus.doc} VEstrSitua

Estrutura de dados para armazenar no modelo de dados dos campos de documentos de origens (NFs) do Documento Hábil

@author marylly.araujo
@since 07/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------

Static Function VEstrSitua()

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruSit	:= FWFormStruct(2,'FV2',{ |x| !ALLTRIM(x) $ 'FV2_CODPRO'})

Return oStruSit

//-------------------------------------------------------------------
/*/{Protheus.doc} EstrEmpenh

Estrutura de dados para armazenar no modelo dos campos essenciais cadastro do Documento Hábil

@author marylly.araujo
@since 05/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
//-------------------------------------------------------------------

Static Function EstrEmpenh()

Local oStruEmp	:= Nil

oStruEmp := FWFormStruct(1,'FV5',{ |x| !ALLTRIM(x) $ 'FV5_CODPRO|FV5_SITUAC'})
oStruEmp:AddTrigger('FV5_FONREC','FV5_NFONRE',{ || .T.}/*bPre*/,{ |oModel| F761GatFRec( oModel:GetValue('FV5_FONREC') ) })
oStruEmp:AddTrigger('FV5_NEMPE','FV5_FONREC',{ || .T.}/*bPre*/,{ |oModel| F761GatNE(FWxFilial("FV5"),oModel:GetValue('FV5_NEMPE'),"FV5_NFONRE",'PCOEMPENHO') })
oStruEmp:SetProperty('FV5_NFONRE', MODEL_FIELD_INIT, FWBuildFeature( STRUCT_FEATURE_INIPAD, "F761GatFRec( FV5->FV5_FONREC )" ))
oStruEmp:SetProperty('FV5_EVALOR', MODEL_FIELD_OBRIGAT, .F. )

Return oStruEmp

//-------------------------------------------------------------------
/*/{Protheus.doc} VEstrEmpen

Estrutura de dados para armazenar no modelo de dados dos campos de documentos de origens (NFs) do Documento Hábil

@author marylly.araujo
@since 07/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------

Static Function VEstrEmpen()

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruEmp	:= FWFormStruct(2,'FV5',{ |x| !ALLTRIM(x) $ 'FV5_CODPRO|FV5_SITUAC|FV5_ITEFV2'})

Return oStruEmp



//-------------------------------------------------------------------
/*/{Protheus.doc} VEstrGrpPr

Estrutura de dados para armazenar no modelo de dados dos campos de documentos de origens (NFs) do Documento Hábil

@author marylly.araujo
@since 07/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------

Static Function VEstrGrpPr()

/*
 * Cria a estrutura de dados que será utilizada na View
 */
Local oStruGrpP	:= FWFormStruct(2,'FV0', { |x| ALLTRIM(x) $ 'FV0_DATPAG' })

oStruGrpP:AddField(			;
"UGPAGA"						, ;	// [01] Id do Field
"01"							, ;	// [02] Ordem
STR0085						, ;	// [03] Titulo do campo		//"UG Pagadora"
STR0086						, ;	// [04] ToolTip do campo	//"Unidade Gestora Pagadora"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
							)	// [09] F3

oStruGrpP:AddField(	 		;
"UGDESC"						, ;	// [01] Id do Field
"02"							, ;	// [02] Ordem
STR0087						, ;	// [03] Titulo do campo			//"Descrição UG"
STR0088						, ; // [04] ToolTip do campo			//"Descrição da Unidade Gestora"
							, ;	// [05] Help
"G"							, ;	// [06] Tipo do campo
"@!"							, ;	// [07] Picture
							, ;	// [08] PictVar
''	            				)	// [09] F3

Return oStruGrpP

//-------------------------------------------------------------------
/*/{Protheus.doc} EstrFav

Estrutura de dados para armazenar no modelo dos campos essenciais cadastro do Documento Hábil

@author marylly.araujo
@since 05/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de modelo de dados
/*/
//-------------------------------------------------------------------

Static Function EstrFav()

Local oStruFav	:= Nil

oStruFav := FWFormStruct(1,'FV6',{ |x| !ALLTRIM(x) $ 'FV6_CODPRO'})

oStruFav:AddTrigger('FV6_FAVORE','FV6_FAVORE'	,/*bPre*/,{ |oModel| F761FV6GAT(oModel,'FV6_FAVORE') })
oStruFav:AddTrigger('FV6_LOJA'	,'FV6_LOJA'		,/*bPre*/,{ |oModel| F761FV6GAT(oModel,'FV6_LOJA') })
				
Return oStruFav

//-------------------------------------------------------------------
/*/{Protheus.doc} VEstrFav

Estrutura de dados para armazenar no modelo de dados dos campos de documentos de origens (NFs) do Documento Hábil

@author marylly.araujo
@since 07/08/2014
@version 12.1.4
@return oStruct Objeto do tipo FWFormStruct com as definições de estrutura de interface
/*/
//-------------------------------------------------------------------

Static Function VEstrFav()

Local oStruFav	:= Nil
/*
 * Cria a estrutura de dados que será utilizada na View
 */
oStruFav := FWFormStruct(2,'FV6',{ |x| !ALLTRIM(x) $ 'FV6_CODPRO'})

Return oStruFav

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FdAct

Função para chamada correta do FieldAction dos campos do Documento Hábil.

@author	marylly.araujo
@since	28/04/2015
@version	12.1.4
@param	oNaoUsado Objeto da View que chama o FieldAction, não utilizado por ser a View Principal
@param	cIDView Identificação da View onde a função está sendo chamada.
@param	cField Nome do campo ao qual a validação foi chamada.
@param	xValue Valor digitado no campo que chamou o SetFieldAction()
/*/
//-------------------------------------------------------------------
Function F761FdAct(oNaoUsado, cIDView, cField, xValue)

If AllTrim(cField) == "FV0_TIPODC"
	MsgRun( OemToAnsi(STR0230), OemToAnsi(STR0136), { || VerificaAbas(oNaoUsado, cIDView, cField, xValue)} ) //"Carregando tela...", "Aguarde"
ElseIf AllTrim(cField) == "FV0_FORNEC" 
 	MsgRun( OemToAnsi(STR0230), OemToAnsi(STR0136), { || VerificaAbas(oNaoUsado, cIDView, cField, xValue)} ) //"Carregando tela...", "Aguarde"
ElseIf AllTrim(cField) == "FV0_LOJA" 
 	MsgRun( OemToAnsi(STR0230), OemToAnsi(STR0136), { || VerificaAbas(oNaoUsado, cIDView, cField, xValue)} ) //"Carregando tela...", "Aguarde"
ElseIf AllTrim(cField) == "FV0_UGPAGA" 
 	MsgRun( OemToAnsi(STR0230), OemToAnsi(STR0136), { || VerificaAbas(oNaoUsado, cIDView, cField, xValue)} ) //"Carregando tela...", "Aguarde"
EndIf
Return Nil
		
//-------------------------------------------------------------------
/*/{Protheus.doc} VerificaAbas

Função que verifica as abas que devem ser exibidas para o tipo de documento informado no formulário
da manutenção do cadastro de documento hábil.

@author	marylly.araujo
@since	06/10/2014
@version	12.1.4
@param	cIDView Identificação da View onde a função está sendo chamada.
@param	cField Nome do campo ao qual a validação foi chamada.
/*/
//-------------------------------------------------------------------
Static Function VerificaAbas(oNaoUsado, cIDView, cField, xValue)
Local oModel
Local oOtherObject
Local oView
Local oSubView
oView := GetViewCorreto( 1 )
oModel := oView:GetModel()
	

If oModel:GetOperation() == MODEL_OPERATION_INSERT
	If cField == "FV0_TIPODC"
		If ! Empty( __cTpDocAnt ) .AND. __cTpDocAnt <> xValue
			MsgRun( OemToAnsi(STR0135), OemToAnsi(STR0136), {|| LimpaDH( oModel ) } ) //"Limpando os dados...", "Aguarde"
			__cTpDocAnt := xValue
			oModel:SetValue( "CABDI", "FV0_TIPODC", xValue )
			oView:Refresh()
		ElseIf Empty( __cTpDocAnt )
			__cTpDocAnt := xValue
		EndIf
	EndIf

	If cField == "FV0_FORNEC"
		If ! Empty( __cTpForAnt ) .AND. __cTpForAnt <> xValue
			MsgRun( OemToAnsi(STR0135), OemToAnsi(STR0136), {|| LimpaDH( oModel ) } ) //"Limpando os dados...", "Aguarde"
			__cTpForAnt := xValue
			oModel:SetValue( "CABDI", "FV0_FORNEC", __cTpForAnt )
			oView:Refresh()
		ElseIf Empty( __cTpForAnt )
			__cTpForAnt := xValue
		EndIf
	EndIf

	If cField == "FV0_LOJA"
		If ! Empty( __cTpLojAnt ) .AND. __cTpLojAnt <> xValue
			MsgRun( OemToAnsi(STR0135), OemToAnsi(STR0136), {|| LimpaDH( oModel ) } ) //"Limpando os dados...", "Aguarde"
			__cTpLojAnt := xValue
			oModel:SetValue( "CABDI", "FV0_LOJA", __cTpLojAnt )
			oView:Refresh()
		ElseIf Empty( __cTpLojAnt )
			__cTpLojAnt := xValue
		EndIf
	EndIf

	If cField == "FV0_UGPAGA"
		If ! Empty( __cTpUpgAnt ) .AND. __cTpUpgAnt <> xValue
			MsgRun( OemToAnsi(STR0135), OemToAnsi(STR0136), {|| LimpaDH( oModel ) } ) //"Limpando os dados...", "Aguarde"
			__cTpUpgAnt := xValue
			oModel:SetValue( "CABDI", "FV0_UGPAGA", __cTpUpgAnt )
			oView:Refresh()
		ElseIf Empty( __cTpUpgAnt )
			__cTpUpgAnt := xValue
		EndIf
	EndIf

Endif

__lDeducoes := .F.
oSubView := oView:GetViewObj("DYNAMIC")[3]
oSubView:Deactivate()
oSubView:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} F761LOG

Função de consulta do log de processamento do documento hábil.

@author marylly.araujo
@since 25/11/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function F761LOG()

ProcLogView( cFilAnt, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO )

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F761Grava

Função de gravação dos dados do documento hábil

@author marylly.araujo
@since 25/11/2014
@version 12.1.4
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
//-------------------------------------------------------------------
Function F761Grava( oModel )
Local lRet		:= .T.
Local aArea		:= GetArea()
Local aFV0Area	:= FV0->( GetArea() )
Local aSE2Area	:= {}
Local oFV1		:= oModel:GetModel( "DOCORI" )
Local nX		:= 0
Local cIdCV8	:= ""
Local cPrefixo	:= ""
Local nTamPref	:= TamSX3( "E2_PREFIXO" )[1]
Local cNumero	:= ""
Local nTamNum	:= TamSX3( "E2_NUM" )[1]
Local cParcela	:= ""
Local nTamParc	:= TamSX3("E2_PARCELA" )[1]
Local cTipo		:= ""
Local cChave	:= ""
Local cFornec	:= oModel:GetValue( "CABDI", "FV0_FORNEC" )
Local cLoja		:= oModel:GetValue( "CABDI", "FV0_LOJA" )
Local nOperation:= oModel:GetOperation()
Local cTit		:= ""
Local cMsg		:= ""
Local aRet		:= {}
Local cError	:= ""
	
BEGIN TRANSACTION
	
	If nOperation != MODEL_OPERATION_DELETE
		oModel:GetModel("CABDI"):LoadValue("FV0_VLRDOC", oModel:GetModel("TOTDBA"):GetValue("TOT_DBA") + oModel:GetModel("TOTPSO"):GetValue("TOT_PSO") )
	Endif

	If ( nOperation == MODEL_OPERATION_INSERT )  
		//Gravação dos Dados do Cabeçalho do Documento Hábil e do cabeçalho da seção "Dados Básicos"
		lRet := FWFormCommit( oModel )
	EndIf

	//Se gravou com sucesso
	If lRet
		aSE2Area := SE2->( GetArea() )
			
		//Define a mensagem que será gravada no log de processamento
		If nOperation == MODEL_OPERATION_INSERT
			cTit := STR0033 //"Inclusão do Documento Hábil"
			cMsg := STR0034 //"Inclusão do Documento Hábil realizada com sucesso!"
		ElseIf nOperation == MODEL_OPERATION_UPDATE
			cTit := STR0137 //"Alteração do Documento Hábil"
			cMsg := STR0138 //"Alteração do Documento Hábil realizada com sucesso!"
		ElseIf nOperation == MODEL_OPERATION_DELETE
			cTit := STR0139 //"Exclusão do Documento Hábil"
			cMsg := STR0140 //"Exclusão do Documento Hábil realizada com sucesso!"
		Endif
		
		//Registro no log a gravação/alteração do registro do documento hábil
		ProcLogIni( {}, "DH" + FV0->FV0_CODIGO, "DH" + FV0->FV0_CODIGO, @cIdCV8 )
		ProcLogAtu( "MENSAGEM", cTit, cMsg, , .T. )
		
		//Seleciona os títulos que estão associados ao DH em questão e limpa o campo DOCHAB para atualizar em seguida
		If nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_UPDATE
			F761LibTit(FV0->FV0_CODIGO)
		Endif
		
		//Caso seja Inclusão ou Alteração, grava o campo E2_DOCHAB para cada título associado ao DH		
		If nOperation != MODEL_OPERATION_DELETE
			SE2->( dbSetOrder( 1 ) ) //E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO + E2_FORNECE + E2_LOJA
			For nX := 1 To oFV1:Length()
				cPrefixo := PadR( oFV1:GetValue( "FV1_PREFIX", nX), nTamPref )
				cNumero := PadR( oFV1:GetValue( "FV1_NUMERO", nX), nTamNum )
				cParcela := PadR( oFV1:GetValue( "FV1_PARCEL", nX), nTamParc )
				cTipo := oFV1:GetValue( "FV1_TIPO", nX )
				
				cChave := FWxFilial("SE2") + cPrefixo + cNumero + cParcela + cTipo + cFornec + cLoja
				If SE2->( msSeek( cChave ) )
					If Empty(SE2->E2_DOCHAB)
						RecLock( "SE2", .F. )
						SE2->E2_DOCHAB := FV0->FV0_CODIGO
						SE2->( msUnlock() )
					Endif
				Endif
			Next nX
		EndIf
		
		RestArea( aSE2Area )
	 	
	 	//Inicializa integração com o módulo SIGAPCO
		PcoIniLan("000340")
	
		//Lançamentos de inclusão na Inclusão/Atualização do documento hábil
		PcoDetLan("000340","01","FINA761")
	
		//Finaliza a integração com o módulo SIGAPCO
		PcoFinLan("000340")
	
		LimpaTMP( .T. )
		
		/*
		 * Movimentação e Atualização dos Saldos de Nota de Empenho
		 */
		aRet := F761AtuNE(oModel,Iif(nOperation == MODEL_OPERATION_INSERT,1,__nOper))
		
		If !aRet[1]
			For nX := 1 To Len(aRet[2])
				cError += aRet[2][nX] + CRLF
			Next nX
			
			Help(" ",1,"F761GRVDH",, STR0253  + CRLF +; //"Não foi possível atualizar as notas de empenho utilizadas neste documento hábil:"
			cError +  STR0254 ,3,1) //"Não será possível concluir o envio do documento hábil."
			lRet := aRet[1]
		EndIf

		If lRet .and. ( nOperation == MODEL_OPERATION_DELETE .OR. nOperation == MODEL_OPERATION_UPDATE )  
			//Gravação dos Dados do Cabeçalho do Documento Hábil e do cabeçalho da seção "Dados Básicos"
			lRet := FWFormCommit( oModel )
		EndIf
	
		If lRet .AND. nOperation == MODEL_OPERATION_INSERT
			If MsgYesNo(STR0173) //"Deseja enviar o documento hábil para SIAFI agora?"
				Fina761Env(1)
			EndIf
		EndIf
		
	EndIf

	If !lRet
		DisarmTransaction()
		MsUnLockAll()
	EndIf
	
END TRANSACTION
		
RestArea( aArea )
RestArea( aFV0Area )

Return lRet

/*/{Protheus.doc} FSIFWMarkB
Tela de seleção de documentos relacionado ao DH
@author William Matos Gundim Junior
@since 26/11/2014
@version 1.0
/*/
Function FSIFWMarkB(aCampos, cAliasMrk)
Local oView		:= GetViewCorreto(2)
Local oViewPai	:= GetViewCorreto(1)
Local oDlg 		:= Nil
Local nX 			:= 0
Local nZ 			:= 0
Local aColumns 	:= {}
Local aSizeMrk 	:= {}
Local aStruct 	:= &(cAliasMrk)->(dbStruct())
Local aStrMrk 	:= {}
Local nRet 		:= 0
Local bOk 			:= {||((nRet := 1, oMrkBrowse:Deactivate(), oDlg:End()))}
Local cQuery 		:= ""
Local cRecnos 	:= ""
Local aArea 		:= GetArea()
Local cPrefixo 	:= "" 
Local lRet 		:= .F.
Local nPos 		:= 0
Local oModel 		:= oView:GetModel()
Local oModelDocOri:= oModel:GetModel("DOCORI")
Local oModelCabDH	:= oModel:GetModel("CABDI")
Local cCampos 	:= ""
Local cPrefTit 	:= ""
Local cNumTit	 	:= ""
Local cParcela 	:= ""
Local cTipoTit 	:= ""
Local cChave 		:= ""
Local aMarkAnt	:= {} 
Local bAfterMark	:= {|| GuardaMark( @aMarkAnt ) }
Local aAreaTMP 	:= {}
Local oMrkBrowse	:= Nil 
Local cSepNeg 	:= Iif( "|" $ MV_CPNEG, "|", "," )
Local cSepProv 	:= Iif( "|" $ MVPROVIS, "|", "," )
Local cSepPag 	:= Iif( "|" $ MVPAGANT, "|", "," )
Local cSepTxa 	:= Iif( "|" $ MVTXA, "|", "," )
Local cSepTx 		:= Iif( "|" $ MVTAXA, "|", "," )
Local nTamDoc 	:= TamSX3("FV1_DOCORI")[1]
Local cUnidaPag	:= oModelCabDH:GetValue("UGPAGA")
Local cTipoDB		:= Alltrim(Upper(TCGetDB()))
Local cIsNull		:= " IsNull"

Default cAliasMrk := "SE2"
Default aCampos := {'E2_PREFIXO', 'E2_NUM', 'E2_PARCELA', 'E2_TIPO', 'E2_VALOR', 'E2_EMISSAO','E2_NATUREZ'}

//+-----------------------------------------------------------------------+
//| Avalia qual expressao IsNull a rotina irá usar                        |
//+-----------------------------------------------------------------------+

If ("INFORMIX" $ cTipoDB) .Or. ("ORACLE"   $ cTipoDB)
	cIsNull  := " NVL"
ElseIf ("DB2" $ cTipoDB)  .Or. ("POSTGRES"   $ cTipoDB)
	cIsNull := " COALESCE"
Else
	cIsNull := " IsNull"
EndIf

If oMrkBrowse != Nil
	oMrkBrowse:DeActivate()
EndIf

Aadd(aStrMrk, {"RECNO","N",10,0})
Aadd(aStrMrk, {"CX0_UGEMIT","C",TamSx3("CX0_UGEMIT")[1],0})
Aadd(aStrMrk, {"CPA_DESORG","C",TamSx3("CPA_DESORG")[1],0})
cPrefixo := If(Substr(cAliasMrk,0,1) == "S", Substr(cAliasMrk,2,2),cAliasMrk)

For nX := 1 To Len(aCampos)
	cCampos += aCampos[nX] + "," + CRLF
	
	If ( nPos := aScan( aStruct, { |x| AllTrim( x[1] ) ==  AllTrim( aCampos[nX] ) } ) ) > 0
		Do Case
			Case aStruct[nPos][2] == "C"
				aAdd(aStrMrk, {aCampos[nX], "C", TamSx3(aCampos[nX])[1],0})				
			Case aStruct[nPos][2] == "D"
				aAdd(aStrMrk, {aCampos[nX], "D", TamSx3(aCampos[nX])[1],0})	
			Case aStruct[nPos][2] == "N"
				aAdd(aStrMrk, {aCampos[nX], "N", TamSx3(aCampos[nX])[1],TamSx3(aCampos[nX])[2]})
		EndCase
	EndIf
Next nX

//Cria o arquivo temporário, caso o mesmo já não tenha sido criado
If __cArqTrab == ""
	cQuery := "SELECT * FROM ( " + CRLF
	cQuery += "SELECT DISTINCT " + cAliasMrk + ".R_E_C_N_O_," + CRLF
	cQuery += " "+cIsNull+"(CX0_UGEMIT,'') CX0_UGEMIT	," + CRLF
	cQuery += " "+cIsNull+"(CPA_DESORG,'') CPA_DESORG	," + CRLF
	cQuery += cCampos + CRLF
	cQuery += " ED_DESCRIC, " + CRLF
	cQuery += " '  ' " + cPrefixo + "_OK " + CRLF
	cQuery += " FROM " + RetSqlName(cAliasMrk) + " " + cAliasMrk + " " + CRLF
	cQuery += " INNER JOIN " + RetSqlName("SED") + " SED ON " + CRLF
	cQuery += " ED_FILIAL = '"+xFilial("SED")+"' " + CRLF
	cQuery += " AND " +  cPrefixo + "_NATUREZ = ED_CODIGO " + CRLF

	cQuery += " LEFT JOIN " + RetSqlName("SF1") + " SF1 ON " + CRLF
	cQuery += " 	E2_FILIAL  = F1_FILIAL AND " + CRLF
	cQuery += " 	E2_FORNECE = F1_FORNECE AND " + CRLF
	cQuery += " 	E2_LOJA    = F1_LOJA	AND " + CRLF
	cQuery += " 	E2_PREFIXO = F1_PREFIXO AND " + CRLF
	cQuery += " 	E2_NUM     = F1_DOC		AND " + CRLF
	cQuery += " 	SF1.D_E_L_E_T_ = ' ' " + CRLF

	cQuery += " LEFT JOIN " + RetSqlName("SD1") + " SD1 ON " + CRLF
	cQuery += " 	F1_FILIAL = D1_FILIAL AND " + CRLF
	cQuery += " 	F1_DOC = D1_DOC AND " + CRLF
	cQuery += " 	F1_SERIE = D1_SERIE AND " + CRLF
	cQuery += " 	F1_FORNECE = D1_FORNECE AND " + CRLF
	cQuery += " 	F1_LOJA = D1_LOJA AND " + CRLF
	cQuery += " 	SD1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " LEFT JOIN " + RetSqlName("CX0") + " CX0 ON " + CRLF
	cQuery += " 	D1_FILIAL = CX0_FILIAL AND " + CRLF
	cQuery += " 	D1_CODNE  = CX0_CODNE AND " + CRLF
	cQuery += " 	CX0.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " LEFT JOIN " + RetSqlName("CPA") + " CPA ON " + CRLF
	cQuery += " 	CPA_FILIAL = '"+xFilial("CPA")+"' AND " + CRLF
	cQuery += " 	CPA_CODORG  = CX0_UGEMIT AND " + CRLF
	cQuery += " 	CPA.D_E_L_E_T_ = ' ' " + CRLF
	
	cQuery += " WHERE " + CRLF
	cQuery += cPrefixo + "_FILIAL = " + "'" + FWxFilial(cAliasMrk) + "' AND " + CRLF
	cQuery += cPrefixo + "_SALDO > 0 AND " + CRLF
	cQuery += cPrefixo + "_MOEDA = 1 AND " + CRLF
	cQuery += cPrefixo + "_FORNECE = '" + oModelCabDH:GetValue("FV0_FORNEC") + "' AND "	+ CRLF
	cQuery += cPrefixo + "_LOJA = '" 	+ oModelCabDH:GetValue("FV0_LOJA") + "' AND "	+ CRLF
	cQuery += cPrefixo + "_TIPO NOT IN " + FormatIn( MVABATIM, "|" ) + " AND "	 + CRLF
	cQuery += cPrefixo + "_TIPO NOT IN " + FormatIn( MV_CPNEG, cSepNeg ) + " AND " + CRLF
	cQuery += cPrefixo + "_TIPO NOT IN " + FormatIn( MVPROVIS, cSepProv ) + " AND " + CRLF
	cQuery += cPrefixo + "_TIPO NOT IN " + FormatIn( MVPAGANT, cSepPag ) + " AND " + CRLF
	cQuery += cPrefixo + "_TIPO NOT IN " + FormatIn( MVTXA, cSepTxa ) + " AND " + CRLF
	cQuery += cPrefixo + "_TIPO NOT IN " + FormatIn( MVTAXA, cSepTx ) + " AND " + CRLF
	cQuery += "( " + cPrefixo + "_DOCHAB = '" + Space(TamSX3('FV0_CODIGO')[1]) + "' OR " + cPrefixo + "_DOCHAB = '" + oModelCabDH:GetValue("FV0_CODIGO") + "') AND "
	cQuery += cAliasMrk + ".D_E_L_E_T_ = ' ' AND " + CRLF
		
	/*
	 * Se aba de Deduções não for utilizada, não trazer os títulos com impostos para seleção.
	 */
	If !__lDeducoes
		cQuery += cPrefixo + "_ISS = 0 AND " + cPrefixo + "_IRRF = 0 AND " + cPrefixo + "_INSS = 0 AND " + CRLF
		cQuery += cPrefixo + "_COFINS = 0 AND " + cPrefixo + "_PIS = 0 AND " + cPrefixo + "_CSLL = 0 AND "
	EndIf
	
	cQuery += RetSqlCond("SED")

	cQuery += ") TIT WHERE ( CX0_UGEMIT  = '"+oModelCabDH:GetValue("FV0_UGPAGA")+"' OR CX0_UGEMIT = ' ' ) " + CRLF

	cQuery := ChangeQuery( cQuery )
	__cAliasTMP := GetNextAlias()
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), __cAliasTMP, .T., .T. )
	
	Aadd(aStrMrk, {cPrefixo + "_OK","C",1,0})
	Aadd(aStrMrk, {"ED_DESCRIC","C",30,0})

	If(_oFINA761A <> NIL)
		_oFINA761A:Delete()
		_oFINA761A := NIL
	EndIf

	__cArqTrab := GetNextAlias()

	//Criando o objeto FwTemporaryTable
	_oFINA761A := FwTemporaryTable():New(__cArqTrab)

	//Setando a estrutura da tabela temporaria
	_oFINA761A:SetFields(aStrMrk)

	aChave := {"E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO"}

	//Criando o indicie da tabela temporaria
	_oFINA761A:AddIndex("1", aChave )
	_oFINA761A:AddIndex("2", {"RECNO"} )

	//Criando a tabela temporaria
	_oFINA761A:Create()
	
	//Preenche Tabela TMP com as informações filtradas
	While !(__cAliasTMP)->(Eof())
		RecLock( __cArqTrab, .T. )
		
		For nX := 1 To Len(aStrMrk)
		
			If ( nPos := aScan( aStruct, { |x| AllTrim( x[1] ) ==  AllTrim( aStrMrk[nX][1] ) } ) ) > 0
				Do Case
				Case aStruct[nPos][2] == "C"
					(__cArqTrab)->&(aStrMrk[nX][1]) := (__cAliasTMP)->&(aStrMrk[nX][1])
				Case aStruct[nPos][2] == "D"
					(__cArqTrab)->&(aStrMrk[nX][1]) := STOD((__cAliasTMP)->&(aStrMrk[nX][1]))
				Case aStruct[nPos][2] == "N"
					(__cArqTrab)->&(aStrMrk[nX][1]) := (__cAliasTMP)->&(aStrMrk[nX][1])
				EndCase
			EndIf
		
		Next nX
		
		(__cArqTrab)->RECNO := (__cAliasTMP)->R_E_C_N_O_
		(__cArqTrab)->ED_DESCRIC := (__cAliasTMP)->ED_DESCRIC
		(__cArqTrab)->CX0_UGEMIT := (__cAliasTMP)->CX0_UGEMIT
		(__cArqTrab)->CPA_DESORG := (__cAliasTMP)->CPA_DESORG
	
		//Caso já tenha algum documento na grid, já marca no arq temporario
		cPrefTit := (__cArqTrab)->E2_PREFIXO
		cNumTit  := (__cArqTrab)->E2_NUM
		cParcela := (__cArqTrab)->E2_PARCELA
		cTipoTit := (__cArqTrab)->E2_TIPO
		If oModelDocOri:SeekLine( { {"FV1_PREFIX", cPrefTit}, {"FV1_NUMERO", cNumTit}, ;
				{"FV1_PARCEL", cParcela}, {"FV1_TIPO", cTipoTit} } )
			(__cArqTrab)->&(cPrefixo + "_OK") := "X"
		Endif
			
		(__cArqTrab)->( MsUnlock() )
		(__cAliasTMP)->( dbSkip() )
	EndDo
Endif
	
//----------------MarkBrowse----------------------------------------------------
For nX := 1 To Len(aStrMrk)
	If !aStrMrk[nX][1] $ cPrefixo + "_OK|RECNO"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStrMrk[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStrMrk[nX][1])) 
		aColumns[Len(aColumns)]:SetSize(aStrMrk[nX][3]) 
		aColumns[Len(aColumns)]:SetDecimal(aStrMrk[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict(cAliasMrk,aStrMrk[nX][1])) 
	EndIf	
Next nX 

aSize( aMarkAnt, 0 ) 
aSizeMrk := MsAdvSize()
DEFINE MSDIALOG oDlg TITLE OemTOAnsi(STR0048) From aSizeMrk[7],0 to aSizeMrk[6],aSizeMrk[5] OF oMainWnd PIXEL //"Seleção de Títulos"
oDlg:lMaximized := .T.

oMrkBrowse := FWMarkBrowse():New()
oMrkBrowse:SetFieldMark( cPrefixo + "_OK" )
oMrkBrowse:SetOwner( oDlg )
oMrkBrowse:SetAlias( __cArqTrab )
oMrkBrowse:AddButton( OemTOAnsi(STR0046), bOk,, 2 ) //"Confirmar"
oMrkBrowse:bAllMark := {|| SIAFMark( oMrkBrowse, __cArqTrab, cPrefixo, @aMarkAnt ) }
oMrkBrowse:SetMark( 'X', __cArqTrab, cPrefixo + "_OK" )
oMrkBrowse:SetAfterMark( bAfterMark ) 
oMrkBrowse:SetDescription( OemTOAnsi(STR0047) + oModel:GetValue( "CABDI", "FV0_NFORNE" ) ) //"Seleção de Títulos a Pagar - Fornecedor: "
oMrkBrowse:SetColumns( aColumns )
oMrkBrowse:SetMenuDef("")
oMrkBrowse:Activate()
ACTIVATE MSDIALOg oDlg CENTERED

//Se a markbrowse for confirmada
If nRet == 1
	lRet := .T.
	//Retorna os itens selecionados.
	(__cArqTrab)->(dbGoTop())
	While !(__cArqTrab)->(Eof())
	
		cPrefTit := (__cArqTrab)->E2_PREFIXO
		cNumTit  := (__cArqTrab)->E2_NUM
		cParcela := (__cArqTrab)->E2_PARCELA
		cTipoTit := (__cArqTrab)->E2_TIPO
	
		If (__cArqTrab)->&(cPrefixo + "_OK") == oMrkBrowse:Mark()			
			//Verifica se o título já está na FV1 
			If !oModelDocOri:SeekLine( { {"FV1_PREFIX", cPrefTit}, {"FV1_NUMERO", cNumTit}, ;
	   			                        	 {"FV1_PARCEL", cParcela}, {"FV1_TIPO", cTipoTit} } )
			
				cPrefTit := AllTrim(cPrefTit)
				cNumTit  := AllTrim(cNumTit)
				cParcela := AllTrim(cParcela)
				cTipoTit := AllTrim(cTipoTit)
				
				//Adiciona documentos selecionados a FV1.
				If !oModelDocOri:IsEmpty()
					oModelDocOri:AddLine()
				Endif
				oModelDocOri:LoadValue('FV1_RECNO' , (__cArqTrab)->RECNO)
				oModelDocOri:LoadValue('FV1_EMISSA', (__cArqTrab)->E2_EMISSAO)
				oModelDocOri:SetValue('FV1_VALOR' , (__cArqTrab)->E2_VALOR)
				oModelDocOri:LoadValue('FV1_PREFIX', cPrefTit)
				oModelDocOri:LoadValue('FV1_NUMERO', cNumTit)
				oModelDocOri:LoadValue('FV1_PARCEL', cParcela)
				oModelDocOri:LoadValue('FV1_TIPO'  , cTipoTit)
				oModelDocOri:SetValue ('FV1_EMISSA', (__cArqTrab)->E2_EMISSAO)
				oModelDocOri:LoadValue('FV1_DOCORI', SUBSTR(cPrefTit + cNumTit + cParcela + cTipoTit,0,nTamDoc))
			Endif
		Else
			//Se o título não estiver selecionado e estiver na FV1, deleta o mesmo da FV1
			If oModelDocOri:SeekLine( { {"FV1_PREFIX", cPrefTit}, {"FV1_NUMERO", cNumTit}, ;
				                       	{"FV1_PARCEL", cParcela}, {"FV1_TIPO", cTipoTit} } )
				If !oModelDocOri:IsDeleted()
					oModelDocOri:DeleteLine()
				Endif
			Endif	
		EndIf
		(__cArqTrab)->(DbSkip())
	EndDo
	
	FCriaTbImp() //Cria tabela tmp com titulos que tem impostos relacionados.
	oModelDocOri:SetLine(1)
Else //Se a markbrowse for fechada ao invés de confirmada
	lRet := .F.
	//Desfaz as alterações de marcações, pois a marcação não foi confirmada
	aAreaTMP := ( __cArqTrab )->( GetArea() )
	For nX := 1 To Len( aMarkAnt )
		If __cArqTrab != ""												
			//Procura o título no arquivo temporário				 
			( __cArqTrab )->( dbSetOrder( 2 ) ) //R_E_C_N_O_
			If ( __cArqTrab )->( msSeek( aMarkAnt[nX][1] ) )
				RecLock( __cArqTrab, .F. )			
				(__cArqTrab)->E2_OK := aMarkAnt[nX][2]		
				( __cArqTrab )->( msUnlock() )
			Endif						
		Endif			
	Next nX
	
	( __cArqTrab )->( RestArea( aAreaTMP) )
	aSize( aMarkAnt, 0 ) 
	aMarkAnt := Nil
Endif

oViewPai:Refresh("TOTDBA")

RestArea(aArea)
Return lRet

/*/{Protheus.doc} SIAFMark
Função para marcar todos os itens da markbrowse.
@author William Matos Gundim Junior
@since 26/11/2014
@version 1.0
/*/
Function SIAFMark(oMrkBrowse,cArqTrab,cPrefixo,aMarkAnt)
Local nRecno := 0

(cArqTrab)->(dbGoTop())
While !(cArqTrab)->(Eof())
	nRecno := (__cArqTrab)->RECNO
	RecLock(cArqTrab, .F.)
	If (cArqTrab)->&(cPrefixo + "_OK") == oMrkBrowse:Mark()		
		(cArqTrab)->&(cPrefixo + "_OK") := ' '		
		//Guarda o estado da marcação para desfazer caso a tela não seja confirmada		
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
			aAdd( aMarkAnt, { nRecno, "X" } )		
		Endif		
	Else
		(cArqTrab)->&(cPrefixo + "_OK") := oMrkBrowse:Mark()
		//Guarda o estado da marcação para desfazer caso a tela não seja confirmada		
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0			
			aAdd( aMarkAnt, { nRecno, " " } )		
		Endif
	EndIf
	MsUnlock()
	(cArqTrab)->(DbSkip())	
End

oMrkBrowse:oBrowse:Refresh(.T.)
Return .T.

/*/{Protheus.doc} F761ValPreDc
Valida se todos os pré-documentos foram preenchidos.
@author William Matos Gundim Junior
@since 12/01/2014
@version 12.1.4
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
Function F761ValPreDc(oModel,lValid)
Local cTipo	   := oModel:GetModel('CABDI'):GetValue('FV0_TIPODC')
Local lRet 	   := .T.
Local nX   	   := 0
Local nPos		:= 0
Local cSituac	   := ''
Local cAba		   := ""
Local cDesc		:= ""
Local cPreDoc	:= LoadPreDoc(cSituac)
Default lValid   := .F.

If lRet
	//Principal Sem Orçamento
	For nX := 1 To oModel:GetModel('DETFV8'):Length() .AND. !oModel:GetModel('DETFV8'):IsEmpty() .AND. lRet
		If !EMPTY(LoadPreDoc(oModel:GetModel('DETFV8'):GetValue('FV8_SITUAC', nX)))
			If !oModel:GetModel('DETFV8'):IsDeleted(nX)
				If !oModel:GetModel('DETFV7'):SeekLine({ {'FV7_IDTAB','5'},{'FV7_SITUAC',oModel:GetModel('DETFV8'):GetValue('FV8_SITUAC', nX)} })
				 	cDesc := STR0113 + STR0024 + CRLF + STR0114 + oModel:GetModel('DETFV8'):GetValue('FV8_ITEM', nX)
				 	lRet := .F.
				EndIf
			EndIf
		EndIf	
	Next nX
EndIf

If lRet
	//Deduções
	For nX := 1 To oModel:GetModel('DETFVD'):Length() .AND. !oModel:GetModel('DETFVD'):IsEmpty() .AND. lRet		
		If !EMPTY(LoadPreDoc(oModel:GetModel('DETFVD'):GetValue('FVD_SITUAC', nX)))
			If !oModel:GetModel('DETFVD'):IsDeleted(nX)
				If !oModel:GetModel('DETFV7'):SeekLine({ {'FV7_IDTAB','3'},{'FV7_ITEDOC',oModel:GetModel('DETFVD'):GetValue('FVD_ITEM', nX)} }) .AND. !oModel:GetModel('DETFV7'):IsDeleted(nX)
				 	cDesc := STR0113 + STR0028 + CRLF + STR0114 + oModel:GetModel('DETFVD'):GetValue('FVD_ITEM', nX)
				 	lRet := .F.
				EndIf
			EndIf		
		EndIf	
	Next nX
EndIf

If lRet
	//Encargos
	For nX := 1 To oModel:GetModel('DETFVB'):Length() .AND. !oModel:GetModel('DETFVB'):IsEmpty() .AND. lRet
		If !EMPTY(LoadPreDoc(oModel:GetModel('DETFVB'):GetValue('FVB_SITUAC', nX)))
			If !oModel:GetModel('DETFVB'):IsDeleted(nX)
				If !oModel:GetModel('DETFV7'):SeekLine({ {'FV7_IDTAB','1'},{'FV7_ITEDOC',oModel:GetModel('DETFVB'):GetValue('FVB_ITEM', nX)} })
					cDesc := STR0113 + STR0027 + CRLF + STR0114 + oModel:GetModel('DETFVB'):GetValue('FVB_ITEM', nX)
				 	lRet := .F.
				EndIf
			EndIf
		EndIf	
	Next nX
EndIf

If !lRet
	Help(" ",1,STR0081,, STR0121 + CRLF + cDesc +"",3,1) 		
EndIf

Return lRet


/*/{Protheus.doc} F761CargDoc
Função para carregar os dados do documento que será relacionado.
@author William Matos Gundim Junior
@since 07/12/2014
@version 12
/*/
Function F761CargDoc()
Local oModel	:= FWModelActive()
Local oModelCabDH:= oModel:GetModel("CABDI")
Local oAux		:= oModel:GetModel('DOCORI')
Local nLine		:= oAux:GetLine() 
Local aArea		:= GetArea()
Local cPrefixo	:= PadR( oAux:GetValue('FV1_PREFIX', nLine), TamSX3('E2_PREFIXO')[1] )
Local cNumero	:= PadR( oAux:GetValue('FV1_NUMERO' , nLine), TamSX3('E2_NUM')[1] )
Local cParcela	:= PadR( oAux:GetValue('FV1_PARCEL', nLine), TamSX3('E2_PARCELA')[1] )
Local cTipo		:= oAux:GetValue( 'FV1_TIPO', nLine)
Local cFornec	:= oModel:GetValue( 'CABDI', 'FV0_FORNEC' )
Local cLoja		:= oModel:GetValue( 'CABDI', 'FV0_LOJA' )
Local cChave	:= ""
Local oView		:= FWViewActive()

cChave := cPrefixo + cNumero + cParcela + cTipo
DbSelectArea('SE2')
SE2->( dbSetOrder(1) ) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
If !Empty(cNumero) .AND. !Empty(cTipo)
	If SE2->( msSeek( FWxFilial('SE2') + cChave + cFornec + cLoja ) ) 
		//Adiciona documentos selecionados a FV1.
		oAux:SetValue( 'FV1_VALOR', SE2->E2_VALOR )
		oAux:LoadValue( 'FV1_EMISSA', SE2->E2_EMISSAO )
		oAux:LoadValue( 'FV1_DOCORI', cChave )
		
		//Se o arquivo temporário já estiver criado, marca o título adicionado manualmente através da grid  
		If __cArqTrab != ""
			( __cArqTrab )->( dbSetOrder( 1 ) ) //E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
			If ( __cArqTrab )->( msSeek( cChave ) )
				RecLock( __cArqTrab, .F. )
				(__cArqTrab)->E2_OK := "X"
				( __cArqTrab )->( msUnlock() )
			Endif
		Endif
	EndIf
EndIf

oModel	:= Nil
RestArea(aArea)
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} F761Lote

Função de envio/realização do documento hábil.
@author Pedro Pereira Lima
@since 11/12/2014
@version 12.1.4
/*/
//-------------------------------------------------------------------
Function F761Lote()
Local cNumLote	:= "" // <---- Número/Identificador do lote
Local cIdCV8		:= ""
Local cQry		:= ""
Local cArqTrab	:= GetNextAlias()
Local aSize		:= {} 
Local aColumns	:= {}
Local aFields	:= {}
Local bOk		:= {|| lConfirma := .T., oMrkBrowse:Deactivate(), oDlg:End() }
Local aStru		:= FV0->(dbStruct())
Local cMarca		:= GetMark(,"FV0","FV0_OK")					
Local oDlg
Local nX
Local aChave := {}
Local lConfirma	:= .F.
Local oMrkBrowse

__nOper := OPER_REALLOTE

If oMrkBrowse != Nil
	oMrkBrowse:DeActivate()
EndIf

//Seleciono os registros que serão exibidos na MarkBrowse
cQry += " SELECT "
For nX:= 1 to Len(aStru)
	cQry += aStru[nX,1]+", "
	aAdd(aFields,aStru[nX,1])
Next
cQry += " R_E_C_N_O_ RECNO "
cQry += " FROM " + RetSqlName("FV0") + " WHERE "
cQry += " FV0_STATUS IN ('2','7') AND "
cQry += " FV0_CODSIA <> '' "
cQry += " AND D_E_L_E_T_ = ' ' "   

aAdd(aStru,{"RECNO","N",10,0})
aAdd(aFields,"RECNO")

If(_oFINA761D <> NIL)
	_oFINA761D:Delete()
	_oFINA761D := NIL
EndIf

//Criando o objeto FwTemporaryTable
_oFINA761D := FwTemporaryTable():New(cArqTrab)

//Setando a estrutura da tabela temporaria
_oFINA761D:SetFields(aStru)

aChave := &("{'" + StrTran(FV0->(IndexKey()),"+","','") + "'}")

//Criando o indicie da tabela temporaria
_oFINA761D:AddIndex("1", aChave )

//Criando a tabela temporaria
_oFINA761D:Create()

_oFINA761D:InsertSelect( RetSqlName("FV0"), aFields ) // Carrega arquivo

//------------------------------------
//Executa query para leitura da tabela
//------------------------------------
Processa({||SqlToTrb(cQry, aStru, cArqTrab)})
DbSelectArea(cArqTrab)

For nX := 1 To Len(aStru)
	If aStru[nX][01] $ "FV0_CODIGO|FV0_CODSIA|FV0_UGEMIT|FV0_TIPODC|FV0_FORNEC|FV0_LOJA|FV0_UGPAGA|FV0_SISORI|FV0_DTEMIS|FV0_DTVENC|FV0_VLRDOC|FV0_ADICIO|FV0_OBS"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||" + aStru[nX][01] + "}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][01])) 
		aColumns[Len(aColumns)]:SetSize(aStru[nX][03]) 
		aColumns[Len(aColumns)]:SetDecimal(aStru[nX][04])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("FV0",aStru[nX][01]))
	EndIf 	
Next nX

//Faz o calculo automatico de dimensoes de objetos
aSize := MSADVSIZE()	

DEFINE MSDIALOG oDlg TITLE STR0044 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL //Realização em Lote
oDlg:lMaximized := .T.

oMrkBrowse := FWMarkBrowse():New()
oMrkBrowse:AddLegend("FV0->FV0_STATUS == '1'", "BR_AZUL", STR0045)
oMrkBrowse:SetFieldMark("FV0_OK")
oMrkBrowse:SetOwner(oDlg)
oMrkBrowse:SetAlias(cArqTrab)
oMrkBrowse:AddButton( OemTOAnsi(STR0046), bOk,, 2 ) //"Confirmar"
oMrkBrowse:bMark	:= {||}
oMrkBrowse:bAllMark	:= {|| InvertMrk(oMrkBrowse,cArqTrab,"FV0_OK")}
oMrkBrowse:SetDescription(STR0044)
oMrkBrowse:SetColumns(aColumns)
oMrkBrowse:SetMenuDef("")
oMrkBrowse:Activate()

ACTIVATE MSDIALOG oDlg CENTERED

__nOper := 0

Return {lConfirma,cArqTrab,oMrkBrowse:Mark()}

//-------------------------------------------------------------------
/*/{Protheus.doc} InvertMrk()
Faz gravação no campo FV0_OK com a marcação.
@author Pedro Pereira Lima
@since  23/12/2014
@version 12.1.4
/*/
//-------------------------------------------------------------------
Static Function InvertMrk(oMrkBrowse,cArqTrab,cCampo)
Local cMarca := oMrkBrowse:Mark()

dbSelectArea(cArqTrab)
(cArqTrab)->(DbGoTop())

While !(cArqTrab)->(Eof())
	
	RecLock(cArqTrab, .F.)
	If (cArqTrab)->&cCampo == cMarca
		(cArqTrab)->&cCampo := ' '
	Else
		(cArqTrab)->&cCampo := cMarca
	EndIf
	MsUnlock()
	(cArqTrab)->(DbSkip())	
EndDo

oMrkBrowse:oBrowse:Refresh(.T.)

Return .T.

/*/{Protheus.doc} F761AbaAtiva()
Função para retornar o id do submodelo da aba ativa.
@author William Matos
@since  23/12/2014
@version 12
@param oView		Objeto do tipo FWFormView com a interface da view pendurada no OtherObjects da View Principal
@param oViewPai	Objeto do tipo FWFormView com a interface da view Principal
/*/
Function F761AbaAtiva(nFolder,oView,oViewPai)
Local aFolder	:= {}
Local cRet		:= ""
Local nPos		:= 0

Default nFolder	:= 0


aFolder := oView:GetFolderActive("PRINCIPAL", 2)
 
nFolder := If (nFolder = 0, aFolder[1], nFolder)

If (nPos := aScan( __aFolder, { |x| AllTrim( x[1] ) ==  AllTrim( cValToChar(nFolder) ) } ) )

	cRet := __aFolder[nPos][2]

EndIf 

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaBotao

Montagem do botão de campos variáveis 

@author Pequim
@since 06/01/2015
@version 1.0
@param oView		Objeto do tipo FWFormView com a interface da view pendurada no OtherObjects da View Principal
@param oViewPai	Objeto do tipo FWFormView com a interface da view Principal
/*/
//-------------------------------------------------------------------
Static function MontaBotao(oPainel,oView,lPreDOC,lTitulos,lCposVar,cTabModel,oViewPai,cModelID,cWhen,lEmpenho)
Local nLin	:= 0 
Local oModel	:= FWModelActive()

DEFAULT lCposVar	:= .T.
Default lEmpenho	:= .F.
DEFAULT cWhen		:= ".T."

	If lCposVar
		nLin += 15
		@  nLin, 4  BUTTON oButPrev PROMPT STR0090 SIZE 50,012 FONT oPainel:oFont ACTION F761ModFVN(cTabModel,oView,cModelID) OF oPainel PIXEL     // "Complemento"
	Endif	
	//
	If lPreDOC
		nLin += 15
		@  nLin, 4  BUTTON oButPrev PROMPT STR0094    SIZE 50,012 FONT oPainel:oFont ACTION F761PreDC(oView,oViewPai)  WHEN &(cWhen) OF oPainel PIXEL     // "Pré-Documento"	
	EndIf

	If lTitulos
		nLin += 15
		@  nLin, 4  BUTTON oButPrev PROMPT STR0091    SIZE 50,012 FONT oPainel:oFont ACTION F761ImpMark(oView,oViewPai)  OF oPainel PIXEL     // "Titulos Relac."		
	EndIf

	If lEmpenho
		nLin += 15
		@  nLin, 4  BUTTON oButPrev PROMPT STR0262    SIZE 50,012 FONT oPainel:oFont ACTION F761EmpMk(oView,oViewPai)  OF oPainel PIXEL     // "Nota de Empenho"		
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DesmontaBotao

Desmontagem do botão de campos variáveis

@author Pequim
@since 06/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function DesmontaBotao(oPainel)

oPainel:FreeChildren()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} F761ModFVN

Tela dos campos variáveis

@author pequim

@since 05/01/2015
@version 1.0
@param oView		Objeto do tipo FWFormView com a interface da view
/*/
//-------------------------------------------------------------------
FUNCTION F761ModFVN(cTabModel,oView,cModelID)

Local oModel	:= oView:GetModel() //FwModelActive()
Local cAbaAtiva := F761AbaAtiva(,oView)
Local oModelAtu := oModel:GetModeL(cAbaAtiva)
Local oModelFVN := oModel:GetModel("DETFVN")
Local cTipoDoc	:= oModel:GetModel("CABDI"):GetValue("FV0_TIPODC")
Local nLine		:= 0
Local cPosFix   := "_SITUAC"
Local cCpoAux   := ""
Local cSituacao := ""
Local cTabela	:= ""
Local nPos		:= 0
Local lRet		:= .T.
Local lModified := .F.
Local nOperation:= oModel:GetOperation()
Local oViewPai	:= GetViewCorreto(1)

If Empty(__aModels)
	aadd(__aModels,{'FV2','PCOSITUACA'} )
	aadd(__aModels,{'FV8','DETFV8'} )
	aadd(__aModels,{'FVA','DETFVA'} )
	aadd(__aModels,{'FVD','DETFVD'} )
	aadd(__aModels,{'FVB','DETFVB'} )
	aadd(__aModels,{'FVK','DETFVK'} )
	aadd(__aModels,{'FVL','DETFVL'} )
Endif

If ( nPos := AScan( __aModels, { |x| x[2] == cAbaAtiva } ) ) > 0
	nLine	:= oModelAtu:Getline()
	cTabela := __aModels[nPos][1]
	cCpoAux := cTabela+cPosFix
	cSituacao := oModelAtu:GetValue(cCpoAux,nLine)

	If !Empty(cSituacao) .and. !(oModelAtu:IsDeleted())
		Fina761Var(cSituacao,cTabela,oModelAtu,cAbaAtiva,cTabModel,@lModified,oModel,cModelID,__aF761Ctrl)
		
		//Seta o model como modificado caso um dos campos do model de campos variáveis tenha sido modificado
		If lModified
			oViewPai:SetModified(.T.)
		Endif
				
	ElseIf !(oModelAtu:IsDeleted())
		Help(" ",1,"DH_SITUACAO",,STR0092,3,1) // "Por favor, preencha o código da situação antes da digitação dos campos variáveis."
		lRet := .F.
	Endif		
Endif

Return lRet

/*/{Protheus.doc} LimpaTMP()
Função para deletar o arquivo temporário de seleção de títulos,
o índice temporário e limpar as variáveis estáticas utilizadas
para estes fins.
@param lClose, indica se a função ta sendo chamada ao fechar uma
        tela de inclusão/alteração. 

@author Pedro Alencar
@since  05/01/2015
@version 12.1.3
/*/
Static Function LimpaTMP( lClose )
	Default lClose := .F.
	
	If __cArqTrab != ""
		If Select(__cArqTrab) > 0
			( __cArqTrab )->( dbCloseArea() )
			FErase( ( __cArqTrab ) + GetDBExtension() )
			__cArqTrab := ""
		EndIf
		
		If Select(__cAliasTMP) > 0	
			( __cAliasTMP )->( dbCloseArea() )
			__cAliasTMP := ""
		
			If __cIndTMP != ""
				FErase( __cIndTMP + OrdBagExt() )
				__cIndTMP := ""
			Endif
		
			If __cIndTMP2 != ""
				FErase( __cIndTMP2 + OrdBagExt() )
				__cIndTMP2 := ""
			Endif
		EndIf
		
		If __cArqTit != "" .AND. Select(__cArqTit) > 0
			( __cArqTit )->( dbCloseArea() )
			
			FErase( ( __cArqTit ) + GetDBExtension() )
			__cArqTit := ""
		EndIf	
		
		If __cArqEmp != "" .AND. Select(__cArqEmp) > 0
			( __cArqEmp )->( dbCloseArea() )
			
			FErase( ( __cArqEmp ) + GetDBExtension() )
			__cArqEmp := ""
		EndIf	
		
	Endif
	
	If lClose
		__cTpDocAnt := ""
		__cTpForAnt		:= ""
		__cTpLojAnt		:= ""
		__cTpUpgAnt		:= ""
		__FV0_FORNEC := ""
	Endif
	
Return .T.

/*/{Protheus.doc} FV1LinPre()
Pré validação de linha da FV1 (grid de Documentos Relacionados)

@author Pedro Alencar
@since  06/01/2015
@version 12.1.4
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário

/*/
Static Function FV1LinPre(oModel, nLinha, cAction)
Local lRet		:= .T.
Local cPrefixo	:= ""
Local cNumero	:= ""
Local cParcela	:= ""
Local cTipo		:= ""
Local cItem		:= ""
Local aSaveLines:= FWSaveRows()
Local oModelPrin:= oModel:GetModel()
Local oFVP		:= oModelPrin:GetModel('DETFVP')
	
	If cAction == "DELETE" .OR. cAction == "UNDELETE"
		cPrefixo := PadR( oModel:GetValue('FV1_PREFIX', nLinha), TamSX3('E2_PREFIXO')[1] )
		cNumero := PadR( oModel:GetValue('FV1_NUMERO' , nLinha), TamSX3('E2_NUM')[1] )
		cParcela := PadR( oModel:GetValue('FV1_PARCEL', nLinha), TamSX3('E2_PARCELA')[1] )
		cTipo := oModel:GetValue( 'FV1_TIPO', nLinha )
	
		//Se desfizer a deleção do registro, verifica se a linha ficaria duplicada e, caso fique, não permite desfazer a deleção (para não dar problema com a seleção de registros na markbrowse)
		If cAction == "UNDELETE"
			If oModel:SeekLine( { {"FV1_PREFIX", cPrefixo}, {"FV1_NUMERO", cNumero}, {"FV1_PARCEL", cParcela}, {"FV1_TIPO", cTipo} }, .F. )
				cItem := oModel:GetValue('FV1_ITEM')
				Help( "", 1, "FV1LinPre", , OemToAnsi(STR0054) + cItem, 3, 1 ) //"Documento já selecionado na linha "
				lRet := .F.
			Endif
		Endif
	
		If lRet 
			//Se o arquivo temporário já estiver criado, desmarca o título deletado manualmente através da grid e remarca ao desfazer a deleção de linha  
			If __cArqTrab != ""												
				//Procura o título no arquivo temporário	
				( __cArqTrab )->( dbSetOrder( 1 ) ) //E2_PREFIXO + E2_NUM + E2_PARCELA + E2_TIPO
				If ( __cArqTrab )->( msSeek( cPrefixo + cNumero + cParcela + cTipo ) )
					RecLock( __cArqTrab, .F. )			
					If cAction == "DELETE"
						//Se o registro foi apagado, remove a seleção do campo no arquivo temporário
						(__cArqTrab)->E2_OK := " "
					Else
						//Se a deleção da linha foi desfeita, adiciona novamente a seleção do campo no arquivo temporário
						(__cArqTrab)->E2_OK := "X"
					EndIf
					( __cArqTrab )->( msUnlock() )
				EndIf

				FCriaTbImp(nLinha,cAction)
			EndIf			
		EndIf
	Endif
	
	FWRestRows(aSaveLines)
Return lRet

/*/{Protheus.doc} GuardaMark()
Função para guardar as marcações, antes de serem alteradas,
com o proposito de recuperá-las caso a tela não seja confirmada
@param aMarkAnt, Vetor que guardará o recno e a marcação inicial

@author Pedro Alencar
@since  07/01/2015
@version 12.1.4
/*/
Static Function GuardaMark( aMarkAnt )
	Local lRet := .T.
	Local nRecno := 0
	Local lMarcado := .F.  
	
	If __cArqTrab != "" 
		nRecno := (__cArqTrab)->RECNO
		If aScan( aMarkAnt, { |aVet| aVet[1] == nRecno } ) <= 0
			//Se está marcado, então guarda o estado anterior que era desmarcado e vice-versa 
			lMarcado := Iif( (__cArqTrab)->E2_OK == "X", .T., .F. )
			aAdd( aMarkAnt, { nRecno, Iif( lMarcado, " ", "X" ) } )		
		Endif
	Endif
Return lRet


/*/{Protheus.doc} F761PreDC
Modelo de dados com os pré-documentos.
@author pequim
@since 05/01/2015
@version 12.1.4
@param oView		Objeto do tipo FWFormView com a interface da view pendurada no OtherObjects da View Principal
@param oViewPai	Objeto do tipo FWFormView com a interface da view Principal
/*/
Function F761PreDC(oView,oViewPai)
Local cAbaAtiva	:= F761AbaAtiva(,oView,oViewPai)
Local oModel		:= oView:GetModel()
Local oAuxFV7		:= oModel:GetModel('DETFV7')
Local cTipoDC		:= oModel:GetModel('CABDI'):GetValue('FV0_TIPODC')
Local cSituacao		:= ""
Local cTabela		:= ""
Local cCpoAux		:= ""
Local cPosFix		:= ""
Local lPreDoc		:= .F.
Local nX			:= 0	
Local lModified		:= .F.

cCpoAux := FinConsSitua(cAbaAtiva)

If cAbaAtiva <> 'DETFV6'
	cSituacao := oModel:GetModel(cAbaAtiva):GetValue(cCpoAux, oModel:GetModel(cAbaAtiva):GetLine()) 
EndIf

Do Case
	Case cAbaAtiva == 'DETFV8' //Principal sem orçamento
		If AllTrim(cTipoDC) $ 'DT' .And. !oModel:GetModel(cAbaAtiva):IsDeleted() .AND. !Empty(cSituacao)
			lPreDoc := .T.
		Else
			lPreDoc := .F.
		EndIf
	Case cAbaAtiva == 'DETFVB' //Encargos
		If AllTrim(cTipoDC) $ 'NP|DT|FL' .And. !oModel:GetModel(cAbaAtiva):IsDeleted() .AND. !Empty(cSituacao)
			lPreDoc := .T.
		Else
			lPreDoc := .F.
		EndIf
	Case cAbaAtiva == 'DETFVD' //Deduções
		If AllTrim(cTipoDC) $ 'NP|FL|RP' .And. !oModel:GetModel(cAbaAtiva):IsDeleted() .AND. !Empty(cSituacao)
			lPreDoc := .T.
		Else
			lPreDoc := .F.
		EndIf
	Case cAbaAtiva == 'DETFV6' //Dados de Pagamento
		If AllTrim(cTipoDC) $ 'DT|FL|RB|PC|NP|RP' .AND. !oModel:GetModel("DADOPAGFAV"):IsDeleted() 
			lPreDoc := .T.
		EndIf
EndCase

If lPreDoc
	__oMdlPrinc := oViewPai:GetModel()
	
	FINA761PDC(cAbaAtiva, cTipoDC, cSituacao, oView, oViewPai, @lModified)
	//Seta o model como modificado caso um dos campos do model de campos variáveis tenha sido modificado
	If lModified
		oViewPai:SetModified(.T.)
	Endif

Else
	If cAbaAtiva <> 'DETFV6'
		If EMPTY(cSituacao)
			Help(" ",1,STR0095,,STR0096,3,1)//"PRE_DOCUMENTO"//"Para inclusão do pré documento é necessário que seja preenchida a situação."
		Else
			Help(" ",1,STR0095,,STR0231,3,1)//"PRE_DOCUMENTO"//"O Pré-documento para esta situação deve ser preenchido na Aba de Dados de Pagamento."
		EndIf
	Endif
EndIf

Return 

/*/{Protheus.doc} FinConsSitua
Retorna a nome do campo conforme a aba ativa.
@author pequim
@since 05/01/2015
@version 1.0
/*/
Function FinConsSitua(cAbaAtiva)
Local cPosFix   	:= "_SITUAC"
Local cCpoAux   	:= ""
Local cSituacao 	:= ""
Local cTabela		:= ""
Local nPos			:= 0
Default cAbaAtiva := ""

If Empty(__aModels)
	aadd(__aModels,{'FV2','PCOSITUACA'} )
	aadd(__aModels,{'FV8','DETFV8'} )
	aadd(__aModels,{'FVA','DETFVA'} )
	aadd(__aModels,{'FVB','DETFVB'} )
	aadd(__aModels,{'FVD','DETFVD'} )
	aadd(__aModels,{'FVK','DETFVK'} )
	aadd(__aModels,{'FVL','DETFVL'} )
Endif

If ( nPos := AScan( __aModels, { |x| x[2] == cAbaAtiva } ) ) > 0
	cTabela := __aModels[nPos][1]
	cCpoAux := cTabela + cPosFix
EndIf

Return cCpoAux

//-----------------------------------------------------------------------
/*/{Protheus.doc} FVldLinPre
Pre-validação dos models que possuam campo de situação ou 
sejam filhos de um que possua este campo

@author	pequim
@since	05/01/2015
@version	12.1.4
@param	oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário.
@param	cField Nome do campo ao qual a validação foi chamada.
/*/
//-----------------------------------------------------------------------
Function FVldLinPre(oModel,nLine,cAction,cField,xValue,xOldValue)

Local oView		:= GetViewCorreto(2) //FWViewActive()
Local oModelAux	:= NIL
Local oModelATV	:= oView:GetModel() // FWModelActive()
Local oModelFVN	:= oModelATV:GetModel("DETFVN")
Local nTamFVN		:= oModelFVN:Length()
Local nX			:= 0
Local cCpoItem	:= "_ITEM"
Local cItem		:= ""
Local lRet		:= .T.
Local lOk		:= .T.
Local lPerg		:= .F.
Local cTabela		:= ""
Local cAbaAtiva	:= F761AbaAtiva(,oView,GetViewCorreto(1))
Local lGrid		:= .F.

If xValue != NIL .and. !Empty(xOldValue) .and. xValue != xOldValue

	If "SETVALUE" $ cAction 
		cTabela	:= Substr(cField,1,3)
		lGrid		:= (cTabela $ "FVD|FVL")
		
		cCpoItem	:= cTabela+cCpoItem
		cItem		:= oModel:GetValue(cCpoItem,nLine)
		
		//Alterou o campo _SITUAC
		If ("_SITUAC" $ cField) 
			lOk := MsgYesNo( STR0082 )		//"Ao alterar a situação, todos os dados variáveis deste item serão apagados. Confirma a alteração?"
			lPerg := .T.
		//Alterou o campo contrato para Não na FV2 	
		ElseIf cAbaAtiva == "PCOSITUACA" .and. "FV2_CONTRA" == cField  
			lOk := MsgYesNo( STR0083 )		//"Ao alterar a informação de contrato, todos os dados variáveis deste item serão apagados. Confirma a alteração?"
			lPerg := .T.
		EndIf
	Endif

	If cAction == "DELETE"
		lOk := .T.
		lPerg := .T.
	Endif

	If cAction == "UNDELETE" 
		//Desdeletou a linha
		lOk := MsgYesNo( STR0084 )	//"Ao reativar a linha, todos os dados variáveis deste item deverão ser reinformados. Confirma a alteração?"
		lPerg := .T.
	Endif

	If lOk .and. lPerg
		For nX := 1 to nTamFVN
			oModelFVN:GoLine(nX)
			If !oModelFVN:IsDeleted() .and. ;
				((oModelFVN:GetValue('FVN_TABELA',nX) == cTabela .and. oModelFVN:GetValue('FVN_ITETAB',nX) == cItem) .or. ;
				(lGrid .and. oModelFVN:GetValue('FVN_TABPAI',nX) == cTabela .and. oModelFVN:GetValue('FVN_ITEPAI',nX) == cItem))
				
				oModelFVN:DeleteLine()
			Endif
		Next nX					
	ElseIf !lOk
		lRet := .f.
		Help(" ",1,"NOALTER",,STR0093,1,1)	//"Nenhuma informação foi alterada."
	Endif

Endif

Return lRet

/*/{Protheus.doc} F761ImpMark
MarkBrowse para selecionar os títulos com impostos relacionados aos títulos marcados
@author william.gundim
@since 14/01/2015
@param oView		Objeto do tipo FWFormView com a interface da view pendurada no OtherObjects da View Principal
@param oViewPai	Objeto do tipo FWFormView com a interface da view Principal
/*/
Function F761ImpMark(oView,oViewPai)
Local cNumLote	:= "" 
Local cIdCV8		:= ""
Local cQry		:= ""
Local aSize		:= {} 
Local aColumns	:= {}
Local nRet		:= 0
Local bOk 		:= {||((nRet := 1, oMrkBrowse:Deactivate(), oDlg:End()))}
Local aStru		:= SE2->(dbStruct())
Local oDlg		:= Nil
Local nX			:= 0
Local cChave		:= ""
Local oMrkBrowse	:= Nil
Local oModel		:= oViewPai:GetModel()
Local oAux		:= oModel:GetModel('DOCORI')
Local oFVP		:= oModel:GetModel('DETFVP')
Local cAux		:= ""
Local nValor		:= 0

If Empty(__cArqTit)
	FCriaTbImp()
EndIf

If !oModel:GetModel('DOCORI'):IsEmpty() .AND. !Empty(oModel:GetValue('DETFVD','FVD_SITUAC')) .AND. !oModel:GetModel("DETFVD"):IsDeleted()

	For nX := 1 To Len(aStru)
		If aStru[nX][1] $ "E2_PREFIXO,E2_NUM,E2_PARCELA,E2_TIPO,E2_VALOR,E2_NATUREZ"
			AAdd(aColumns,FWBrwColumn():New())
			aColumns[Len(aColumns)]:SetData( &("{||" + aStru[nX][01] + "}") )
			aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][01])) 
			aColumns[Len(aColumns)]:SetSize(aStru[nX][03]) 
			aColumns[Len(aColumns)]:SetDecimal(aStru[nX][04])
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SE2",aStru[nX][1]))
		EndIf	
	Next nX
	
	//Faz o calculo automatico de dimensoes de objetos
	aSize := MSADVSIZE()	
	
	DEFINE MSDIALOG oDlg TITLE STR0048 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
	oDlg:lMaximized := .T.
	oMrkBrowse := FWMarkBrowse():New()
	oMrkBrowse:SetFieldMark("E2_OK")
	oMrkBrowse:SetOwner(oDlg)
	oMrkBrowse:SetAlias(__cArqTit)
	oMrkBrowse:SetValid({|| ValidMrk(oMrkBrowse,oModel)})
	oMrkBrowse:AddButton( OemTOAnsi(STR0046), bOk,, 2 ) //"Confirmar"
	oMrkBrowse:bMark := {|| F761MrkItem(oMrkBrowse,oModel) }
	oMrkBrowse:bAllMark	:= {|| InvertMrk(oMrkBrowse,__cArqTit,"E2_OK"),F761MrkAll(oMrkBrowse,oModel)}
	oMrkBrowse:SetMark( 'C ', __cArqTit, "E2_OK" )
	oMrkBrowse:SetDescription(STR0123) // "Seleção de títulos de impostos."
	oMrkBrowse:SetColumns(aColumns)
	oMrkBrowse:SetMenuDef("")
	oMrkBrowse:Activate()
	
	ACTIVATE MSDIALOG oDlg CENTERED

	If nRet == 1 //Confirmou

		//Atualiza FVP
		dbSelectArea(__cArqTit)
		(__cArqTit)->(DbGoTop())
		
		While !(__cArqTit)->(Eof())
			
			If !oFVP:IsEmpty()
				oFVP:Addline()		
			EndIf
			//
			If (__cArqTit)->&("E2_OK") == oMrkBrowse:Mark()
			
				If (__cArqTit)->MRK_ITEM == oModel:GetValue('DETFVD','FVD_ITEM')	
					nValor +=  (__cArqTit)->E2_VALOR
				EndIf
				//Caso registro não exista, inclui.
				If !oFVP:SeekLine( {{'FVP_PREFIXO' , (__cArqTit)->E2_PREFIXO  },;
									  {'FVP_NUMERO'	, (__cArqTit)->E2_NUM      },;
									  {'FVP_PARCEL'	, (__cArqTit)->E2_PARCELA  },;
									  {'FVP_TIPO'	 	, (__cArqTit)->E2_TIPO     }})
									  
					oFVP:SetValue('FVP_SITUAC', oModel:GetValue('DETFVD','FVD_SITUAC'))
					oFVP:SetValue('FVP_VALOR' , (__cArqTit)->E2_VALOR )
					oFVP:SetValue('FVP_PREFIX', (__cArqTit)->E2_PREFIXO )
					oFVP:SetValue('FVP_NUMERO', (__cArqTit)->E2_NUM)
					oFVP:SetValue('FVP_PARCEL', (__cArqTit)->E2_PARCELA)
					oFVP:SetValue('FVP_TIPO'  , (__cArqTit)->E2_TIPO)
					oFVP:SetValue('FVP_SUBITE', StrZero(oFVP:Length(), TAMSX3('FVP_SUBITE')[1]))
				EndIf	
			Else

				//Caso encontre o registro, apaga.
				If oFVP:SeekLine( {{'FVP_PREFIXO' , (__cArqTit)->E2_PREFIXO  },;
					  {'FVP_NUMERO'	, (__cArqTit)->E2_NUM      },;
					  {'FVP_PARCEL'	, (__cArqTit)->E2_PARCELA  },;
					  {'FVP_TIPO'	 	, (__cArqTit)->E2_TIPO     }})
					
					If !oFVP:IsDeleted()
						oFVP:DeleteLine()
					Endif
					
				EndIf
			EndIf
			(__cArqTit)->(DbSkip())	
		EndDo
		
		oModel:GetModel("DETFVD"):SetValue('FVD_VALOR', nValor )
	
	EndIf
Else
	Help(" ",1,"DOCUMENTO",,STR0100,3,1) //"Verifique se os titulos de impostos foram selecionados e se a situação foi preenchida na Aba Deduções."
EndIf

oView:Refresh()
oViewPai:Refresh()

Return 

/*/{Protheus.doc} FVDLinPre
MarkBrowse para selecionar os títulos com impostos relacionados aos títulos marcados
@author william.gundim
@since 14/01/2015
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário.
/*/
Function FVDLinPre( oModel, nLine, cAction )
Local oModel761 := FWModelActive()
Local oFV7		:= oModel761:GetModel('DETFV7')
Local oFVD		:= oModel761:GetModel('DETFVD')
Local oFVP		:= oModel761:GetModel('DETFVP')
Local nX		:= 0
Local lArqTemp	:= !EMPTY(__cArqTit) .AND. Select(__cArqTit) > 0 

If !oModel:IsEmpty()
	If cAction == 'DELETE'
		If lArqTemp
			dbSelectArea(__cArqTit)
		EndIf
		
		For nX := 1 To oFVP:Length()
			oFVP:SetLine(nX)
			If oFVP:GetValue("FVP_SUBITE") == oModel:GetValue('FVD_ITEM')
				
				If lArqTemp
					//Atualiza FVP
					(__cArqTit)->(DbGoTop())
					
					While !(__cArqTit)->(Eof())
						If (__cArqTit)->MRK_ITEM == oModel:GetValue('FVD_ITEM')
							If !EMPTY((__cArqTit)->E2_OK)
								RecLock(__cArqTit, .F.)
								(__cArqTit)->E2_OK	:= " "
								(__cArqTit)->MRK_ITEM	:= " "
								MsUnlock()
							EndIf
						EndIf
						(__cArqTit)->(DbSkip())
					EndDo
				EndIf
				oFVP:DeleteLine()
			EndIf
		Next nX
		oModel:LoadValue('FVD_VALOR',0)
		
		For nX := 1 To oFV7:Length()
			oFV7:SetLine(nX)
			oFV7:DeleteLine()
		Next nX
	ElseIf cAction == 'UNDELETE' 

		For nX := 1 To oFV7:Length()
			oFV7:SetLine(nX)
			oFV7:UnDeleteLine()
		Next nX

	EndIf
EndIf

Return .T.

/*/{Protheus.doc} FCriaTbImp
Cria arquivo de trabalho para titulos com impostos relacionados.
@author william.gundim
@since 14/01/2015
/*/
Static Function FCriaTbImp(nLinha,cAction)
Local aStru		:= SE2->(dbStruct())
Local nX		:= 0
Local aChave	:= {"E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO"}
Local oModel	:= FWModelActive()
Local oAux		:= oModel:GetModel('DOCORI')
Local oFVP		:= oModel:GetModel('DETFVP')
Local cSE2Als	:= ""
Local cSE2Qry	:= ""
Local cFilSE2	:= FWxFilial("SE2")

DEFAULT nLinha := 0
DEFAULT cAction := ''

Aadd(aStru,{"MRK_ITEM","C",4,0})

If !Empty(__cArqTit) 
	( __cArqTit )->( dbCloseArea() )
	FErase( ( __cArqTit ) + GetDBExtension() )
	__cArqTit := ""	
EndIf

Aadd(aStru,{"RECNO","N",10,0})
__cArqTit := GetNextAlias()

If(_oFINA761B <> NIL)
	_oFINA761B:Delete()
	_oFINA761B := NIL
EndIf

//Criando o objeto FwTemporaryTable
_oFINA761B := FwTemporaryTable():New(__cArqTit)

//Setando a estrutura da tabela temporaria
_oFINA761B:SetFields(aStru)

//Criando o indicie da tabela temporaria
_oFINA761B:AddIndex("1", aChave )

//Criando a tabela temporaria
_oFINA761B:Create()

//Alimenta arquivo temporario
For nX := 1 To oAux:Length()

	cSE2Als := GetNextAlias()
	cSE2Qry := " SELECT " + CRLF
	cSE2Qry += " SE2.E2_PREFIXO, " + CRLF
	cSE2Qry += " SE2.E2_NUM, " + CRLF
	cSE2Qry += " SE2.E2_PARCELA, " + CRLF
	cSE2Qry += " SE2.E2_TIPO, " + CRLF
	cSE2Qry += " SE2.E2_VALOR, " + CRLF
	cSE2Qry += " SE2.E2_TITPAI, " + CRLF
	cSE2Qry += " SE2.E2_NATUREZ " + CRLF
	cSE2Qry += " FROM " +  RetSqlName("SE2") + " SE2 " + CRLF
	cSE2Qry += " WHERE " + RetSqlCond("SE2") + CRLF
	cSE2Qry += " AND SE2.E2_TITPAI = '" + oAux:GetValue('FV1_PREFIX', nX) + oAux:GetValue('FV1_NUMERO', nX) + oAux:GetValue('FV1_PARCEL', nX) + ;
					oAux:GetValue('FV1_TIPO'  , nX) + oModel:GetValue('CABDI','FV0_FORNEC') + ; 
					oModel:GetValue('CABDI','FV0_LOJA') + "'"
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSE2Qry),cSE2Als,.T.,.T.)
	
	While (cSE2Als)->(!Eof()) .AND. AllTrim(oAux:GetValue('FV1_PREFIX', nX) + oAux:GetValue('FV1_NUMERO', nX) + oAux:GetValue('FV1_PARCEL', nX) + ;
         oAux:GetValue('FV1_TIPO'  , nX) + oModel:GetValue('CABDI','FV0_FORNEC') + ; 
		   oModel:GetValue('CABDI','FV0_LOJA')) == AllTrim((cSE2Als)->E2_TITPAI)					   	
		
		If nX == nLinha .AND. cAction == 'DELETE'
			If (__cArqTit)->(DbSeek( (cSE2Als)->E2_PREFIXO + (cSE2Als)->E2_NUM + (cSE2Als)->E2_PARCELA + (cSE2Als)->E2_TIPO ) )
				Reclock( (__cArqTit) , .F.)
				(__cArqTit)->(dbDelete())
				(__cArqTit)->(MsUnlock())
				
				If oFVP:SeekLine( {{'FVP_PREFIXO', (cSE2Als)->E2_PREFIXO  },;
								  {'FVP_NUMERO'	, (cSE2Als)->E2_NUM      },;
								  {'FVP_PARCEL'	, (cSE2Als)->E2_PARCELA  },;
								  {'FVP_TIPO'	, (cSE2Als)->E2_TIPO     }})
					oFVP:DeleteLine()
				EndIf				
			EndIf
		Else	
			Reclock( (__cArqTit) , .T.)
			(__cArqTit)->E2_PREFIXO	 := (cSE2Als)->E2_PREFIXO		 
			(__cArqTit)->E2_NUM		 :=	(cSE2Als)->E2_NUM
			(__cArqTit)->E2_PARCELA  :=	(cSE2Als)->E2_PARCELA  
			(__cArqTit)->E2_TIPO     :=	(cSE2Als)->E2_TIPO 
			(__cArqTit)->E2_VALOR	 :=	(cSE2Als)->E2_VALOR
			(__cArqTit)->E2_NATUREZ	 :=	(cSE2Als)->E2_NATUREZ

			If oFVP:SeekLine( {{'FVP_PREFIXO'	, (cSE2Als)->E2_PREFIXO  },;
								  {'FVP_NUMERO'	, (cSE2Als)->E2_NUM      },;
								  {'FVP_PARCEL'	, (cSE2Als)->E2_PARCELA  },;
								  {'FVP_TIPO'	, (cSE2Als)->E2_TIPO     }})
			
				(__cArqTit)->E2_OK    := 'C '
				(__cArqTit)->MRK_ITEM := oFVP:GetValue('FVP_ITEM')
				oFVP:unDeleteLine()
			EndIf
				
			(__cArqTit)->(MsUnlock())
		EndIf
		(cSE2Als)->(dbSkip())
	EndDo
Next nX

Return 

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761IniPad
Inicializador Padrão do campo de Unidade Gestora Emitente do Documento Hábil

@author Marylly Araújo Silva
@since 14/01/2015
@version 1.0
/*/
//-----------------------------------------------------------------------
Function F761IniPad()

Local cRet		:= ""
Local cCPAQry	:= ""
Local cCPAAls	:= GetNextAlias()

cCPAQry := "SELECT "
cCPAQry += " CPA.CPA_CODORG "
cCPAQry += " FROM " + RetSqlName("CPA") + " CPA "
cCPAQry += " WHERE " + RetSqlCond("CPA") + " "
cCPAQry += " AND CPA.CPA_SISFIL = '" + cFilAnt  + "' "
cCPAQry := ChangeQuery(cCPAQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cCPAQry),cCPAAls,.T.,.T.)

cRet := (cCPAAls)->CPA_CODORG

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761GatUGP
Gatilhos dos campos virtuais de UG Pagadora da Aba Dados de Pagamento

@author Marylly Araújo Silva
@since 15/01/2015
@version 1.0
/*/
//-----------------------------------------------------------------------
Function F761GatUGP()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oMdlCabDI	:= oModel:GetModel("CABDI")

oMdlCabDI:LoadValue("UGPAGA",oMdlCabDI:GetValue("FV0_UGPAGA"))
oMdlCabDI:LoadValue("UGDESC",POSICIONE('CPA', 1, xFilial('CPA') + oMdlCabDI:GetValue("FV0_UGPAGA"),'CPA_DESORG'))

Return lRet

/*/{Protheus.doc} ValidMrk
Valida a marcação dos dados na markbrowse.
@author Marylly Araújo Silva
@since 15/01/2015
@version 12.1.4
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
Static Function ValidMrk(oMrkBrowse,oModel,cModelo,cCampo,cArq)
Local cMarca	:= oMrkBrowse:Mark()
Local lRet		:= .T.	   

Default cModelo := 'DETFVD'
Default cCampo := 'FVD_ITEM'
Default cArq :=__cArqTit


If !Empty((cArq)->MRK_ITEM) .AND. (cArq)->MRK_ITEM <> oModel:GetValue(cModelo , cCampo)
	lRet := .F.			
EndIf	

Return lRet

/*/{Protheus.doc} F761MrkItem
Valida a marcação dos dados na markbrowse.
@author william.gundim
@since 15/01/2015
@version 12.1.4
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
Static Function F761MrkItem(oMrkBrowse,oModel,cModel,cCampo,cArq)
Local cMarca	:= oMrkBrowse:Mark()

Default cModel	:= 'DETFVD'
Default cCampo	:= 'FVD_ITEM'
Default cArq		:= __cArqTit
 

If (cArq)->E2_OK == cMarca
	(cArq)->MRK_ITEM := oModel:GetValue(cModel , cCampo)
ElseIf (cArq)->MRK_ITEM == oModel:GetValue(cModel , cCampo)
	(cArq)->MRK_ITEM	:= " "
EndIf

Return

/*/{Protheus.doc} F761MrkAll
Função de marcação e inversão de marcação de todos os registros do MarkBrowse.
@author Marylly Araújo Silva
@since 09/02/2015
@version 12.1.4
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
Static Function F761MrkAll(oMrkBrowse,oModel,cModelo,cCampo,cArq)
Local cMarca	:= oMrkBrowse:Mark()

Default cArq		:= __cArqTit
Default cModelo	:= 'DETFVD'
Default cCampo	:= 'FVD_ITEM'

dbSelectArea(cArq)
(cArq)->(DbGoTop())

While !(cArq)->(Eof())
	
	If (cArq)->E2_OK == cMarca .AND. EMPTY((cArq)->MRK_ITEM)
		(cArq)->MRK_ITEM := oModel:GetValue(cModelo , cCampo)
	ElseIf (cArq)->MRK_ITEM == oModel:GetValue(cModelo , cCampo)
		(cArq)->MRK_ITEM := ""
	EndIf
	(cArq)->(DbSkip())
EndDo

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761GatFRec
Gatilho do campo de Fonte de Recurso do Documento Hábil

@author Marylly Araújo Silva
@since 20/01/2015
@version 1.0
@Param cConta Número da conta bancária para buscar a descrição da conta bancária da fonte de recurso.
@return cRet Descrição da conta bancária da fonte de recurso informada.
/*/
//-----------------------------------------------------------------------
Function F761GatFRec(cConta)

Local cRet		:= ""
Local cSA6Qry		:= ""
Local cSA6Als		:= GetNextAlias()

cSA6Qry := "SELECT " + CRLF
cSA6Qry += " SA6.A6_NOME " + CRLF
cSA6Qry += " FROM " + RetSqlName("SA6") + " SA6 " + CRLF
cSA6Qry += " WHERE " + RetSqlCond("SA6") + " " + CRLF
cSA6Qry += " AND SA6.A6_NUMCON = '" + cConta  + "' "
cSA6Qry := ChangeQuery(cSA6Qry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSA6Qry),cSA6Als,.T.,.T.)

If (cSA6Als)->(!Eof())
	cRet := (cSA6Als)->A6_NOME
Else
	cRet := " "
EndIf

Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761VldBco
Validação do campo de Fonte de Recurso do Documento Hábil

@author Marylly Araújo Silva
@since 22/01/2015
@version 12.1.5
/*/
//-----------------------------------------------------------------------
Function F761VldBco(cConta)

Local lRet		:= .T.
Local cSA6Qry	:= ""
Local cSA6Als	:= GetNextAlias()

cSA6Qry := "SELECT " + CRLF
cSA6Qry += " SA6.A6_NOME " + CRLF
cSA6Qry += " FROM " + RetSqlName("SA6") + " SA6 " + CRLF
cSA6Qry += " WHERE " + RetSqlCond("SA6") + " " + CRLF
cSA6Qry += " AND SA6.A6_NUMCON = '" + cConta  + "' "
cSA6Qry := ChangeQuery(cSA6Qry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSA6Qry),cSA6Als,.T.,.T.)

lRet := !(cSA6Als)->(Eof())

Return lRet

//-----------------------------------------------------------------------	
/*/{Protheus.doc} F761ValDoc
Função para validar o documento que será relacionado.
@author William Matos Gundim Junior
@since 07/12/2014
@version 12
/*/
//-----------------------------------------------------------------------
Static Function F761ValDoc()

Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oAuxFV1	:= oModel:GetModel('DOCORI') 
Local oAuxFV0	:= oModel:GetModel('CABDI' )
Local nX := 0
Local nOperation:= oModel:GetOperation()
Local cCodDocHab:= oAuxFV0:GetValue('FV0_CODIGO') 

dbSelectArea('SE2')
SE2->(dbSetOrder(1))
	
If !oAuxFV1:IsDeleted() .AND. nOperation != MODEL_OPERATION_DELETE
	If SE2->( msSeek( FWxFilial('SE2') + oAuxFV1:GetValue('FV1_PREFIX') + oAuxFV1:GetValue('FV1_NUMERO') + oAuxFV1:GetValue('FV1_PARCEL') +;
		oAuxFV1:GetValue('FV1_TIPO') + oAuxFV0:GetValue('FV0_FORNEC') + oAuxFV0:GetValue('FV0_LOJA') ) ) 
	
		If SE2->E2_SALDO <= 0
			Help( " ", 1, OemTOAnsi(STR0081), , OemTOAnsi(STR0049), 3, 1 ) //"DOCUMENTO" //"Esse documento não pode ser selecionado pois não possui saldo."
			lRet := .F.
		ElseIf !EMPTY(SE2->E2_DOCHAB) .and. SE2->E2_DOCHAB != cCodDocHab
			Help( " ", 1, OemTOAnsi(STR0081), , OemTOAnsi(STR0050), 3, 1 ) //"DOCUMENTO" //"Esse documento não pode ser selecionado pois já esta relacionado a outro Documento Hábil."
			lRet := .F.	
		ElseIf  SE2->E2_TIPO $ ( MVABATIM + "|" + MV_CPNEG + "|" + MVPROVIS + "|" + MVPAGANT + "|" + MVTXA + "|" + MVTAXA )
			Help( " ", 1, OemTOAnsi(STR0081), , OemTOAnsi(STR0080), 3, 1 ) //"DOCUMENTO" //"O tipo do documento informado é inválido."
			lRet := .F.
		ElseIf SE2->E2_MOEDA <> 1
			Help( " ", 1, OemTOAnsi(STR0081), , OemTOAnsi(STR0051), 3, 1 ) //"DOCUMENTO" //"Documento não localizado"
			lRet := .F.
		EndIf	
	Else
		Help( " ", 1, OemTOAnsi(STR0081), , OemTOAnsi(STR0051), 3, 1 ) //"DOCUMENTO" //"Documento não localizado"
		lRet := .F.
	Endif
Endif

Return lRet


//-----------------------------------------------------------------------
/*/{Protheus.doc} F761ValDH
Função para validar o Documento Hábil (TudoOk)
@author William Matos Gundim Junior
@since 07/12/2014
@version 12
/*/
//-----------------------------------------------------------------------
Function F761ValDH()
Local lRet		:= .T.
Local oModel		:= FWModelActive()
Local oAuxFV1		:= oModel:GetModel('DOCORI') 
Local oAuxFV0		:= oModel:GetModel('CABDI' )
Local oAuxFV2		:= oModel:GetModel('PCOSITUACA' )
Local oAuxFV5		:= oModel:GetModel('PCOEMPENHO')
Local oAuxFV8		:= oModel:GetModel('DETFV8' )
Local oAuxFV9		:= oModel:GetModel('DETFV9' )
Local nX			:= 0
Local nOperation	:= oModel:GetOperation()
Local cDescricao	:= ""
Local cTipoDoc		:= Alltrim(oAuxFV0:GetValue('FV0_TIPODC'))
Local nAte			:= 0
Local aRet			:= {}

//Valida se todos os campos variaveis estão preenchidos
If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

	//Valida se foram relacionados titulos a DH. 
	//A unica exceção é o Tipo de Documento "SF" e "DT" que não exige titulos
	If lRet .and. !(cTipoDoc $ "SF|DT") .and. (oAuxFV1:IsEmpty())
		Help( " ", 1, OemTOAnsi(STR0081), , STR0108 + CRLF + STR0109 + CRLF +;	//"Nenhum documento de origem foi relacionado ao documento hábil."###"Verifique o preenchimento das informações:"
											STR0110 + CRLF + STR0111, 3, 1 ) //"Aba: Dados Básicos"###"Item: Documentos de Origem"
		lRet := .F.
	Endif	

	If lRet .AND. !(oAuxFV2:IsEmpty())
		If oAuxFV5:IsEmpty()
			Help( " ", 1, OemTOAnsi(STR0081), , STR0125 + CRLF + STR0126 + CRLF + STR0127, 1, 1 )	//"É obrigatório o preenchimento das Notas de Empenho."# "Acesse a Aba: Principal com Orçamento."#"Seção: Notas de Empenho."
			lRet := .F.		
		EndIf	
	EndIf
	
	If lRet .AND. !(oAuxFV8:IsEmpty())
		If oAuxFV9:IsEmpty()
			Help( " ", 1, OemTOAnsi(STR0081), , STR0128 + CRLF + STR0129 + CRLF + STR0130, 1, 1 )	//"É obrigatório o preenchimento dos itens Sem Orçamento."#"Acesse a Aba: Principal sem Orçamento."#"Seção: Itens sem Orçamentos."
			lRet := .F.		
		EndIf	
	EndIf
	
	If lRet .AND. !(F761VldCpVar(oModel,@cDescricao))
		Help( " ", 1, OemTOAnsi(STR0081), , STR0112 + CRLF + cDescricao , 1, 1 )	//"É obrigatório o preenchimento dos complementos:"
		lRet := .F.		
	Endif
	
	//Valida se todos os pré-documentos estão preenchidos, teste
	If lRet .and. !(F761ValPreDc(oModel))
		lRet := .F.
	Endif
	
	//Valida os documentos (titulos) relacionados a DH
	If lRet .AND. !(oAuxFV1:IsEmpty())
		nAte := oAuxFV1:Length()
		For nX := 1 to nAte
			If !(oAuxFV1:IsDeleted())
				oAuxFV1:GoLine(nX)						
				lRet := F761ValDoc()
				If !lRet
					Exit
				Endif
			Endif
		Next
	EndIf
	
	If lRet .and. !Empty(__cArqTit)
	
		(__cArqTit)->(dbGoTop())
		While (__cArqTit)->(!Eof()) .AND. lRet
			lRet := (__cArqTit)->E2_OK == 'C '
			(__cArqTit)->(dbSkip())
		EndDo	
		
		If !lRet
			Help( " ", 1, OemTOAnsi(STR0081), , STR0099 , 3, 1 ) //"DOCUMENTO" //'Existem títulos de impostos que não foram selecionados na Aba Deduções.'	
		EndIf
		
	EndIf
	
	If lRet
		aRet := F761ValNE(oModel)
		If !EMPTY(aRet) 
			lRet := .F.
			For nAte := 1 To Len(aRet)
				Help( " ", 1, OemTOAnsi(STR0081), ,;
				STR0245 + CRLF +; // "Total de valores informados para nota de empenho superou o saldo disponível: "
				STR0246 + aRet[nAte][1] + CRLF + ; //"Nota de Empenho: "
				STR0247 + aRet[nAte][2] + CRLF + ; //"Sub-Item: "
				STR0248 + TRANSFORM(aRet[nAte][3],"@E 999,999,999,999,999.999") + CRLF + ; // "Saldo Disponível NE: "
				STR0249 + TRANSFORM(aRet[nAte][4],"@E 999,999,999,999,999.999") + CRLF , 3, 1 ) // "Total informado DH: "
			Next nAte
		EndIf	
	EndIf
EndIf

If lRet .and. nOperation == MODEL_OPERATION_DELETE
	If oAuxFV0:GetValue("FV0_STATUS") != '1'
		lRet := .F.
		Help( " ", 1, OemTOAnsi("EXCDH"), , STR0101 , 3, 1 ) //"DOCUMENTO" //'Existem títulos de impostos que não foram selecionados na Aba Deduções.'
	EndIf
EndIf

oModel	 := Nil
Return lRet


/*/{Protheus.doc} F761VldCpVar
Valida se todos os campos variáveis foram preenchidos.
@author Mauricio Pequim Junior
@since 22/01/2014
@version 12.1.4
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
Function F761VldCpVar(oModel,cDescricao)

Local cTipo		:= oModel:GetModel('CABDI'):GetValue('FV0_TIPODC')
Local lRet		:= .T.
Local nX		:= 0
Local nY		:= 0
Local nZ		:= 0
Local nPos		:= 0
Local cSituac	:= ''
Local cAba		:= ""
Local cTabela 	:= ""
Local cItem		:= ""
Local cItemPai	:= ""
Local cSituacao	:= ""
Local nPosTab	:= 0
Local lValFVN	:= .F.

DEFAULT cDescricao := ""

FV4->(dbSetOrder(1))	//FV4_FILIAL+FV4_SITUAC+FV4_IDCAMP

//Principal com Orçamento
If !oModel:GetModel('PCOSITUACA'):IsEmpty()
	For nX := 1 To oModel:GetModel('PCOSITUACA'):Length()
		If !(oModel:GetModel('PCOSITUACA'):IsDeleted(nX))
			cSituacao	:= oModel:GetModel('PCOSITUACA'):GetValue('FV2_SITUAC', nX)
			cItemPai	:= oModel:GetModel('PCOSITUACA'):GetValue('FV2_ITEM'	, nX)
			
			//Verifico se a situação tem 
			If FV4->(MsSeek(xFilial("FV4")+cSituacao))
				While FV4->(!Eof()) .AND. FV4->(FV4_FILIAL+FV4_SITUAC) == xFilial("FV4")+cSituacao .AND. FV4->FV4_STATUS == '1'
					If FV4->FV4_LOCAL == '1'
						cTabela 	:= "FV2"
						nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
						If nPosTab > 0
							lValFVN :=  __aF761Ctrl[nPosTab][2]
						EndIf
						cItem	:= oModel:GetModel('PCOSITUACA'):GetValue('FV2_ITEM', nX)
						//Verifico se foram preenchidos os campos variáveis
						If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItem} }) 
							cDescricao := STR0113 + STR0023 + CRLF + STR0114 + cItem + CRLF	//"Aba: "###'Principal com Orçamento'###"Linha : "
							cDescricao += STR0115	//"Verifique o botão [Complementos]." 
						 	lRet := .F.
							Exit
							Exit
						EndIf
					ElseIf FV4->FV4_LOCAL == '2'
						For nZ := 1 To oModel:GetModel('PCOEMPENHO'):Length()
							If !oModel:GetModel('PCOEMPENHO'):IsEmpty() .AND. !oModel:GetModel('PCOEMPENHO'):IsDeleted(nZ)
								cTabela 	:= "FV5"
								nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
								If nPosTab > 0
									lValFVN :=  __aF761Ctrl[nPosTab][2]
								EndIf
								cItem	:= oModel:GetModel('PCOEMPENHO'):GetValue('FV5_ITEM', nZ)
								//Verifico se foram preenchidos os campos variáveis
								If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItem} }) 
									cDescricao := STR0113 + STR0023 + CRLF + STR0116 + STR0024 + CRLF + STR0114 + cItemPai + CRLF + CRLF	//"Aba: "###" Grupo: "### "Linha : " 
									cDescricao += STR0117 + CRLF	//"Verifique:" 
									cDescricao += "....." + STR0118 + STR0064 + CRLF + "....." + STR0119 + cItem + CRLF	//"Sub-Grupo: "###'Itens sem Orçamento'###"Item: "
									cDescricao += STR0115	//"Verifique o botão [Complementos]."
								 	lRet := .F.
									Exit
									Exit
								EndIf
							EndIf
						Next nZ
					EndIf
					FV4->(DbSkip())
				EndDo
			EndIf
		Endif
	Next nX
Endif

//Principal Sem Orçamento
If lRet .and. !oModel:GetModel('DETFV8'):IsEmpty()
	For nX := 1 To oModel:GetModel('DETFV8'):Length()  

		//Principal Sem Orçamento
		If !(oModel:GetModel('DETFV8'):IsDeleted(nX))
			cSituacao	:= oModel:GetModel('DETFV8'):GetValue('FV8_SITUAC', nX)
			cItemPai	:= oModel:GetModel('DETFV8'):GetValue('FV8_ITEM', nX)
	
			//Verifico se a situação tem campos variáveis 
			If FV4->(MsSeek(xFilial("FV4")+cSituacao))
				For nY := 1 To oModel:GetModel('DETFV9'):Length()
					If !(oModel:GetModel('DETFV9'):IsDeleted(nY))
						cTabela	:= "FV9"
						cItem	:= oModel:GetModel('DETFV9'):GetValue('FV9_ITEM', nY)		
						nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
						If nPosTab > 0
							lValFVN :=  __aF761Ctrl[nPosTab][2]
						EndIf
						//Verifico se foram preenchidos os complementos dos Itens Sem Orçamento
						If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItem} }) 
							cDescricao := STR0113 + STR0024 + CRLF + STR0116 + STR0024 + CRLF + STR0114 + cItemPai + CRLF + CRLF	//"Aba: "###"Grupo: "###"Linha : " 
							cDescricao += STR0117 + CRLF	//"Verifique:" 
							cDescricao += "....." + STR0118 + STR0069 + CRLF + "....." + STR0119 +cItem + CRLF	//"Sub-Grupo: "###'Itens sem Orçamento'###"Item: "
							cDescricao += STR0115	//"Verifique o botão [Complementos]."					
						 	lRet := .F.
							Exit
						EndIf
					Endif
				Next nY
			EndIf	
		Endif
	Next nX
EndIf

//Outros Lançamentos
If lRet .and. !oModel:GetModel('DETFVA'):IsEmpty()
	For nX := 1 To oModel:GetModel('DETFVA'):Length()
		If !(oModel:GetModel('DETFVA'):IsDeleted(nX))
			cSituacao	:= oModel:GetModel('DETFVA'):GetValue('FVA_SITUAC', nX)
			//Verifico se a situação tem 
			If FV4->(MsSeek(xFilial("FV4")+cSituacao))
				cTabela 	:= "FVA"
				cItem	:= oModel:GetModel('DETFVA'):GetValue('FVA_ITEM', nX)
				nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
				If nPosTab > 0
					lValFVN :=  __aF761Ctrl[nPosTab][2]
				EndIf
				//Verifico se foram preenchidos os campos variáveis
				If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItem} }) 
					cDescricao := STR0113 + STR0026 +CRLF+ STR0114 + cItem + CRLF	//"Aba: "###'Outros Lançamentos''###"Linha : "
					cDescricao += STR0115	//"Verifique o botão [Complementos]." 
				 	lRet := .F.
					Exit
				EndIf
			EndIf
		Endif
	Next nX
Endif

//Encargos
If lRet .and. !oModel:GetModel('DETFVB'):IsEmpty()
	For nX := 1 To oModel:GetModel('DETFVB'):Length()
		If !(oModel:GetModel('DETFVB'):IsDeleted(nX))
			cSituacao	:= oModel:GetModel('DETFVB'):GetValue('FVB_SITUAC', nX)
			//Verifico se a situação tem 
			If FV4->(MsSeek(xFilial("FV4")+cSituacao))
				cTabela 	:= "FVB"
				cItem	:= oModel:GetModel('DETFVB'):GetValue('FVB_ITEM', nX)
				nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
				If nPosTab > 0
					lValFVN :=  __aF761Ctrl[nPosTab][2]
				EndIf
				//Verifico se foram preenchidos os campos variáveis
				If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItem} }) 
					cDescricao := STR0113 + STR0027 +CRLF+ STR0114 + cItem + CRLF	//"Aba: "###'Outros Lançamentos''###"Linha : "
					cDescricao += STR0115	//"Verifique o botão [Complementos]." 
				 	lRet := .F.
					Exit
				EndIf
			EndIf
		Endif
	Next nX
Endif

//Deduções
If lRet .and. !oModel:GetModel('DETFVD'):IsEmpty()
	For nX := 1 To oModel:GetModel('DETFVD'):Length()  

		//Deduções
		If !(oModel:GetModel('DETFVD'):IsDeleted(nX))
			cSituacao	:= oModel:GetModel('DETFVD'):GetValue('FVD_SITUAC', nX)
	
			//Verifico se a situação tem campos variáveis 
			If FV4->(MsSeek(xFilial("FV4")+cSituacao))
				cTabela 	:= "FVD"
				cItemPai	:= oModel:GetModel('DETFVD'):GetValue('FVD_ITEM', nX)
				nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
				If nPosTab > 0
					lValFVN :=  __aF761Ctrl[nPosTab][2]
				EndIf

				//Verifico se foram preenchidos os complementos de Deduções
				If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItemPai} }) 
					cDescricao := STR0113 + STR0028 + CRLF + STR0116 + STR0028 + CRLF + STR0114 + cItemPai + CRLF + CRLF	//"Aba: "###"Acréscimos"###"Grupo: "###"Linha : " 
					cDescricao += STR0115	//"Verifique o botão [Complementos]."					
				 	lRet := .F.
					Exit
				EndIf

				For nY := 1 To oModel:GetModel('DETFVF'):Length()
					If !(oModel:GetModel('DETFVF'):IsEmpty(nY)) .AND. !(oModel:GetModel('DETFVF'):IsDeleted(nY)) 
						cTabela := "FVF"
						cItem	:= oModel:GetModel('DETFVF'):GetValue('FVF_ITEM', nY)		
						nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
						If nPosTab > 0
							lValFVN :=  __aF761Ctrl[nPosTab][2]
						EndIf
						//Verifico se foram preenchidos os complementos dos Acréscimos
						If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItem} }) 
							cDescricao := STR0113 + STR0028 + CRLF + STR0116 + STR0028 + CRLF + STR0114 + cItemPai + CRLF + CRLF	//"Aba: "###"Acréscimos"###"Grupo: "###"Linha : " 
							cDescricao += STR0117 + CRLF	//"Verifique:" 
							cDescricao += "....." + STR0118 + STR0070 + CRLF + "....." + STR0119 +cItem + CRLF	//"Sub-Grupo: "###'Acréscimos'###"Item: "
							cDescricao += STR0115	//"Verifique o botão [Complementos]."					
						 	lRet := .F.
							Exit
						EndIf
					Endif
				Next nY
			EndIf	
		Endif
	Next nX
EndIf

//Despesas a Anular
If lRet .and. !oModel:GetModel('DETFVL'):IsEmpty()
	For nX := 1 To oModel:GetModel('DETFVL'):Length()  

		//Despesas a Anular
		If !(oModel:GetModel('DETFVL'):IsDeleted(nX))
			cSituacao	:= oModel:GetModel('DETFVL'):GetValue('FVL_SITUAC', nX)
	
			//Verifico se a situação tem campos variáveis 
			If FV4->(MsSeek(xFilial("FV4")+cSituacao))

				cTabela 	:= "FVL"
				cItemPai	:= oModel:GetModel('DETFVL'):GetValue('FVL_ITEM', nX)
				nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
				If nPosTab > 0
					lValFVN :=  __aF761Ctrl[nPosTab][2]
				EndIf
				//Verifico se foram preenchidos os complementos de Despesas a Anular
				If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItemPai} }) 
					cDescricao := STR0113 + STR0029 + CRLF + STR0116 + STR0024 + CRLF + STR0114 + cItemPai + CRLF + CRLF	//"Aba: "###"Despesas a Anular"###"Grupo: "###"Linha : " 
					cDescricao += STR0115	//"Verifique o botão [Complementos]."					
				 	lRet := .F.
					Exit
				EndIf

				For nY := 1 To oModel:GetModel('DETFVM'):Length()
					If !(oModel:GetModel('DETFVM'):IsDeleted(nY))
						cTabela := "FVM"
						cItem	:= oModel:GetModel('DETFVM'):GetValue('FVM_ITEM', nY)		
						nPosTab		:= aScan(__aF761Ctrl,{ |cTab| cTab[1] == cTabela})
						If nPosTab > 0
							lValFVN :=  __aF761Ctrl[nPosTab][2]
						EndIf
						//Verifico se foram preenchidos os complementos dos Itens
						If lValFVN .AND. !oModel:GetModel('DETFVN'):SeekLine({ {'FVN_TABELA',cTabela},{'FVN_ITETAB',cItem} }) 
							cDescricao := STR0113 + STR0029 + CRLF + STR0116 + STR0024 + CRLF + STR0114 + cItemPai + CRLF + CRLF	//"Aba: "###"Despesas a Anular"###"Grupo: "###"Linha : " 
							cDescricao += STR0117 + CRLF	//"Verifique:" 
							cDescricao += "....." + STR0118 + STR0072 + CRLF + "....." + STR0119 +cItem + CRLF	//"Sub-Grupo: "###'Itens'###"Item: "
							cDescricao += STR0115	//"Verifique o botão [Complementos]."					
						 	lRet := .F.
							Exit
						EndIf
					Endif
				Next nY
			EndIf	
		Endif
	Next nX
EndIf

Return lRet


//-------------------------------------------------------------------
/*/
{Protheus.doc} FaGetCodFv0
obtém o código para chave única da tabela Fv0 

@author pequim

@since 23/01/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Function FaGetCodFV0()

Local cCodFV0	:="" 
Local cQuery	:= ""	
Local aArea	:= GetArea()
Local cTab	:= ""
Local cTabela	:= RetSQLTab("FV0")
Local cFilTab	:= xFilial("FV0")

While .T.

	cTab	:= GetNextAlias()
	cCodFV0 := GetSx8Num("FV0","FV0_CODIGO","FV0_CODIGO"+cEmpAnt)
	
	cQuery   := " SELECT "
	cQuery   += " FV0_CODIGO "
	cQuery   += " FROM " + cTabela 
	cQuery   += " WHERE "
	cQuery   += " FV0_FILIAL = '" + cFilTab + "' AND "
	cQuery   += " FV0_CODIGO = '" + cCodFV0 + "' AND "
	cQuery   += " D_E_L_E_T_ = ' ' "

	If Select(cTab) > 0
		(cTab)->(dbCloseArea())
	EndIf
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTab, .T., .T.)
	
	ConfirmSx8()
	If (cTab)->(!EOF())
		(cTab)->(dbCloseArea())
		Loop
	Else
		Exit
	EndIf

EndDo

(cTab)->(dbCloseArea())

RestArea(aArea)

Return cCodFV0


/*/{Protheus.doc} FV8LinPre
Pré-Validação para registros de principal sem orçamento
@author William Matos Gundim Junior
@since 22/01/2014
@version 12
/*/
Function FV8LinPos()
Local oModel	:= FWModelActive()
Local oAux	:= oModel:GetModel('DETFV8')
Local nLine	:= oAux:GetLine()
Local lRet	:= .T.

If oAux:GetValue('FV8_SITUAC', nLine) == 'PSO001' .OR. oAux:GetValue('FV8_SITUAC', nLine) == 'PSO006' 
	If oAux:SeekLine( {{'FV8_SITUAC','PSO002'}} )
		Help(" ",1,"DOCUMENTO",,STR0122,3,1)
		lRet := .F.
	EndIf
Else
	If oAux:SeekLine( {{'FV8_SITUAC','PSO001'}} ) .OR. oAux:SeekLine( {{'FV8_SITUAC','PSO006'}} )
		Help(" ",1,"DOCUMENTO",,STR0122,3,1)
		lRet := .F.
	EndIf	
EndIf

//Restaura
oAux:SetLine( nLine )

Return lRet

/*/{Protheus.doc} VldSituac
Função para validar a situação e só deixar digitar uma situação
válida, de acordo com o relacionamento com a FVK (TpDoc x Seção x Sit)

@param cSecao, Código da seção de onde a validação está sendo chamada 
@author Pedro Alencar	
@since 04/02/2015	
@version P12.1.4
@param oModelSit Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
Static Function VldSituac( oModelSit, cCampo, cSituac, nLinha, cSecao )
	Local lRet := .F.
	Local aAreaFVK := FVK->( GetArea() )
	Local oModelDH := FWModelActive()
	Local oCabecDH := oModelDH:GetModel( "CABDI" )
	Local cTipoDoc := oCabecDH:GetValue( "FV0_TIPODC" ) 			
	
	If ExistCpo( "FVJ", cSituac )
		FVK->( dbSetOrder( 1 ) ) //Filial + Tipo Doc + Seção + Situação
		If FVK->( msSeek( FWxFilial("FVK") + cTipoDoc + cSecao + cSituac ) )  
			lRet := .T.
		Else
			lRet := .F.
			Help( "", 1, "VldSituac", , OemToAnsi( STR0124 ), 1, 0 ) //"Situação inválida para esse tipo de documento ou seção."
		Endif
	Else	
		lRet := .F.
	Endif
	
	FVK->( RestArea( aAreaFVK ) )
Return lRet

/*/{Protheus.doc} VldLinSit
Função de pré-validação do grid para validação da informação de situação.
Se a situação de uma linha já informada for alterada, os campos complementares do registro serão apagados.

@author	Marylly Araújo Silva	
@since	06/02/2015	
@version	P12.1.4
@param	oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
@param	cField Nome do campo ao qual a validação foi chamada.

/*/
Function VldLinSit( oModel, nLine, cAction, cField, xValue, xOldValue )

Local lRet		:= .T.
Local cTabela		:= ""
Local lOk		:= .T.
Local lPerg		:= .T.
Local cCpoItem	:= "_ITEM"
Local cItem		:= ""
Local oModelAux	:= NIL
Local oModelATV	:= FWModelActive()
Local oModelFVN	:= oModelATV:GetModel("DETFVN")
Local nTamFVN	:= oModelFVN:Length()
Local nX		:= 0

If "SETVALUE" == AllTrim(cAction) .AND. !EMPTY(xOldValue) .AND. xValue <> xOldValue
	cTabela		:= Substr(cField,1,3)
	
	cCpoItem	:= cTabela+cCpoItem
	cItem		:= oModel:GetValue(cCpoItem,nLine)
	
	//Alterou o campo _SITUAC
	If ("_SITUAC" $ cField) 
		lOk := MsgYesNo( STR0082 )		//"Ao alterar a situação, todos os dados variáveis deste item serão apagados. Confirma a alteração?"
		lPerg := .T.
	EndIf
Endif

If cAction == "DELETE"
	lOk := .T.
	lPerg := .T.
Endif

If cAction == "UNDELETE" 
	//Desdeletou a linha
	lOk := MsgYesNo( STR0084 )	//"Ao reativar a linha, todos os dados variáveis deste item deverão ser reinformados. Confirma a alteração?"
	lPerg := .T.
Endif

If lOk .and. lPerg
	For nX := 1 to nTamFVN
		oModelFVN:GoLine(nX)
		If !oModelFVN:IsDeleted() .AND. oModelFVN:GetValue('FVN_TABPAI',nX) == cTabela .AND. oModelFVN:GetValue('FVN_ITEPAI',nX) == cItem
			oModelFVN:DeleteLine()
		Endif
	Next nX					
ElseIf !lOk
	lRet := .f.
	Help(" ",1,"NOALTER",,STR0093,1,1)	//"Nenhuma informação foi alterada."
EndIf
	
Return lRet

/*/{Protheus.doc} GetAbaView
Função para geração do conteúdo da interface de cada aba do formulário do documeno hábil.
@param oView Objeto do Tipo FWFormView
@param oViewPai Objeto do Tipo FWFormView
@param cAba Identificação da aba para geração da interface da mesma
@author Marylly Araújo Silva
@since 12/02/2014
@version 12.1.4
/*/
Function GetAbaView(oView,oViewPai,cAba)
Local oModel	:= oView:GetModel()
Local oStruDH	:= VStrucDH()
Local oStruDO	:= VEstrDO()
Local oStruSit	:= VEstrSitua()
Local oStruEmp	:= VEstrEmpen()
Local oStruGrpP	:= VEstrGrpPr()
Local oStruFav	:= VEstrFav()
Local oStruFV8	:= FWFormStruct(2, 'FV8',{ |x| !(ALLTRIM(x) $ 'FV8_CODPRO')})
Local oStruFV9	:= FWFormStruct(2, 'FV9',{ |x| !(ALLTRIM(x) $ 'FV9_CODPRO, FV9_ITEFV8,FV9_SITUAC')})
Local oStruFVD	:= FWFormStruct(2, 'FVD',{ |x| !(ALLTRIM(x) $ 'FVD_CODPRO')})
Local oStruFVL	:= FWFormStruct(2, 'FVL',{ |x| !(ALLTRIM(x) $ 'FVL_CODPRO')})
Local oStruFVM	:= FWFormStruct(2, 'FVM',{ |x| !(ALLTRIM(x) $ 'FVM_CODPRO, FVM_ITEFVL,FVM_SITUAC')})
Local oStruFVB	:= FWFormStruct(2, 'FVB',{ |x| !(ALLTRIM(x) $ 'FVB_CODPRO, FVB_ITETAB,FVB_IDFK5') })
Local oStruFVA	:= FWFormStruct(2, 'FVA',{ |x| !(ALLTRIM(x) $ 'FVA_CODPRO')})
Local oStruFVF	:= FWFormStruct(2, 'FVF',{ |x| !(ALLTRIM(x) $ 'FVF_CODPRO,FVF_SECAO, FVF_ITETAB,FVF_SITUAC')})
Local oStruFVE	:= FWFormStruct(2, 'FVE',{ |x| !(ALLTRIM(x) $ 'FVE_CODPRO,FVE_SITUAC,FVE_ITETAB,FVE_TABREL')})	
Local oStrDba	:= FWCalcStruct(oModel:GetModel('TOTDBA')) 

If cAba == ABA_DADOS_BASICOS
	/* Partes da Aba 'Dados Básicos'*/
	oView:CreateHorizontalBox( 'ABA01CAB'	, 30	,/*cOwner*/	,/*lUsePixel*/,'PRINCIPAL','DADOSBASIC' )
	oView:CreateHorizontalBox( 'NFS'		, 70	,/*cOwner*/	,/*lUsePixel*/,'PRINCIPAL','DADOSBASIC' )
	
	/*
	 * Formulário da Aba Dados Básicos
	 */
	oView:AddField("VCABDH",oStruDH,"CABDI")
	oView:SetViewProperty("VCABDH","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,5})
	oView:SetOwnerView( 'VCABDH', 'ABA01CAB'  )
	
	/*
 	 * Grid de Documentos de Origem localizado na Aba Dados Básicos
	 */      
	oView:AddGrid("VDOCORI",oStruDO,"DOCORI")
	oView:AddIncrementField( 'VDOCORI', 'FV1_ITEM')
	oView:SetOwnerView( 'VDOCORI'	, 'NFS'  )
	oView:EnableTitle('VDOCORI'		, STR0062) // 'Documentos de Origem'
	
	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'CABDI'})
ElseIf cAba == ABA_PCO

	/*
	 * Partes da Aba 'Principal com Orçamento'
	 */
	oView:CreateHorizontalBox( 'ABA01EMP', 50, /*owner*/, /*lPixel*/   , 'PRINCIPAL', 'PRINCORCA')
	oView:CreateHorizontalBox( 'ABA02EMP', 50, /*owner*/, /*lUsePixel*/, 'PRINCIPAL', 'PRINCORCA')
	oView:CreateVerticalBox( 'ABA02CAB' , 90, 'ABA01EMP', /*lUsePixel*/, 'PRINCIPAL', 'PRINCORCA')
	
	/*
	 * Grid de Situações da Aba Principal com Orçamento.
	 */
	oView:AddGrid("INFOSITUAC",oStruSit,"PCOSITUACA")
	oView:AddIncrementField('INFOSITUAC', 'FV2_ITEM')
	oView:EnableTitle('INFOSITUAC'	, STR0063) // 'Situações'
	oView:SetOwnerView("INFOSITUAC"	,'ABA02CAB')

	/*
	 * Grid de Notas de Empenho
	 */
	oView:AddGrid("SITUACEMPE",oStruEmp,"PCOEMPENHO")
	oView:AddIncrementField( 'SITUACEMPE', 'FV5_ITEM')
	
	/*
	 * Acréscimos - Aba Principal com Orçamento
	 */
	oView:AddGrid("VDETFVFPCO",oStruFVF,"DETFVFPCO")
	oView:AddIncrementField( 'VDETFVFPCO', 'FVF_ITEM')

	/*
	 * Other objects (botões)
	 */	
	oView:AddOtherObject('BTVARFV2',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FV2",oViewPai,/*cModelID*/,/*cWhen*/,.T.)},{|oPainel|DesmontaBotao(oPainel)} )
													
	/*
	 * Botão dos campos variáveis das situações da Aba Principal com Orçamento
	 */
	oView:CreateVerticalBox( 'BOXBUT01' , 10, 'ABA01EMP', /*lUsePixel*/, 'PRINCIPAL', 'PRINCORCA')
	oView:SetOwnerView('BTVARFV2','BOXBUT01')
	
	/*
	 * SubAbas da Aba Principal com Orçamento 
	 */ 
	oView:CreateFolder( 'TIPOSPCO','ABA02EMP')
	oView:AddSheet('TIPOSPCO', 'FV2NES', STR0064) //'Notas de Empenho'
	oView:AddSheet('TIPOSPCO', 'FV2ACRES', STR0070) //'Acréscimos'
	
	oView:CreateVerticalBox('DETFV2ACR',100,/*owner*/,/*lUsePixel*/,'TIPOSPCO', 'FV2ACRES')
	oView:CreateVerticalBox('DETFV2NES',90,/*owner*/,/*lUsePixel*/,'TIPOSPCO', 'FV2NES')
	
	oView:SetOwnerView("VDETFVFPCO",'DETFV2ACR')
	oView:SetOwnerView("SITUACEMPE",'DETFV2NES')
	
	/*
	 * Other objects (botões)
	 */	
	oView:AddOtherObject('BTVARFV5',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FV5",oViewPai,"PCOEMPENHO")},{|oPainel|DesmontaBotao(oPainel)} )
	oView:CreateVerticalBox('DETFV5NES',10,/*owner*/,/*lUsePixel*/,'TIPOSPCO', 'FV2NES')
		
	oView:SetOwnerView("BTVARFV5",'DETFV5NES')
	
	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'PCOSITUACA'})
ElseIf cAba == ABA_PSO

	/*
	 * Partes da Aba 'Principal sem Orçamento'
	 */
	oView:CreateHorizontalBox( 'BOXFV8', 45, /*owner*/, /*lPixel*/, 'PRINCIPAL', 'PRINSORCA')
	oView:CreateVerticalBox( 'ABA03CAB', 90, 'BOXFV8', /*lUsePixel*/, 'PRINCIPAL', 'PRINSORCA')
	
	oView:CreateHorizontalBox( 'BOXFV9', 55, /*owner*/, /*lPixel*/, 'PRINCIPAL', 'PRINSORCA')
	oView:CreateVerticalBox( 'ABA03CPO', 100, 'BOXFV9', /*lUsePixel*/, 'PRINCIPAL', 'PRINSORCA')
	
	oView:CreateFolder( 'TIPOSPSO','ABA03CPO')
	oView:AddSheet('TIPOSPSO', 'FV8CPO', STR0069) //'Itens sem Orçamento'
	oView:AddSheet('TIPOSPSO', 'FV8ACRES', STR0070) //'Acréscimos'
	
	oView:CreateVerticalBox('DETFV8ACR',100,/*owner*/,/*lUsePixel*/,'TIPOSPSO', 'FV8ACRES')
	oView:CreateVerticalBox('DETFV8CPO',90,/*owner*/,/*lUsePixel*/,'TIPOSPSO', 'FV8CPO')
	
	/*
	 * Principal sem Orçamento (Situações).
	 */
	oView:AddGrid("VDETFV8",oStruFV8,"DETFV8")
	oView:AddIncrementField( 'VDETFV8','FV8_ITEM')
	oView:SetOwnerView('VDETFV8','ABA03CAB')
	oView:EnableTitle('VDETFV8', STR0068) // 'Principal sem Orçamento'
	
	/*
	 * Grid Itens sem Orçamento
	 */
	oView:AddGrid("VDETFV9",oStruFV9,"DETFV9")
	oView:AddIncrementField( 'VDETFV9','FV9_ITEM')
	oView:SetOwnerView('VDETFV9','DETFV8CPO')
	
	/*
	 * Acréscimos - Aba Principal sem Orçamento
	 */
	oView:AddGrid("VDETFVFPSO",oStruFVF,"DETFVFPSO")
	oView:SetOwnerView("VDETFVFPSO",'DETFV8ACR')
	oView:AddIncrementField( 'VDETFVFPSO','FVF_ITEM')
	
	/*
	 * Botões do Grid de Situações da Aba Principal sem Orçamento
	 */
	oView:AddOtherObject('BTVARFV8',{|oPainel|MontaBotao(oPainel,oView,.T.,.F.,.F.,"FV8",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )
	oView:CreateVerticalBox( 'BOXFORMV8', 10, 'BOXFV8', /*lUsePixel*/, 'PRINCIPAL', 'PRINSORCA')
	oView:SetOwnerView('BTVARFV8','BOXFORMV8')
	oView:EnableTitleView('BTVARFV8' , '' )
	
	/*
	 * Botões do Grid de Itens sem Orçamento da Aba Principal sem Orçamento
	 */
	oView:AddOtherObject('BTVARFV9',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FV9",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )
	oView:CreateVerticalBox( 'BOXFORMV9', 10, /*cOwner*/, /*lUsePixel*/, 'TIPOSPSO', 'FV8CPO')
	oView:SetOwnerView('BTVARFV9','BOXFORMV9')
	oView:EnableTitleView('BTVARFV9' , '' )
	
	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'DETFV8'})
ElseIf cAba == ABA_OUTROS_LANCAMENTOS
	//Outros Lançamentos
	oView:AddGrid("VDETFVA",oStruFVA,"DETFVA")
	oView:AddIncrementField( "VDETFVA", "FVA_ITEM" )
	
	/*
	 * Botões de Campos Complementares
	 */
	oView:AddOtherObject('BTVARFVA',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FVA",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )
	
	/*
	 * Partes da Aba 'Outros Lançamentos'
	 */
	oView:CreateHorizontalBox( 'BOXFVA', 100, /*owner*/, /*lPixel*/, 'PRINCIPAL', 'OUTROS')
	oView:CreateVerticalBox( 'ABA07CAB', 90, 'BOXFVA', /*lUsePixel*/, 'PRINCIPAL', 'OUTROS')
	oView:CreateVerticalBox( 'BOXFORMVA', 10, 'BOXFVA', /*lUsePixel*/, 'PRINCIPAL', 'OUTROS')

	// Seção - Outros Lançamentos.
	oView:SetOwnerView('VDETFVA','ABA07CAB')
	oView:SetOwnerView('BTVARFVA','BOXFORMVA')
	oView:EnableTitle('VDETFVA' , STR0026) // 'Outros Lançamentos'

	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'DETFVA'})
ElseIf cAba == ABA_DEDUCAO
	//Deduções
	oView:AddGrid("VDETFVD",oStruFVD,"DETFVD")
	oView:AddIncrementField( 'VDETFVD','FVD_ITEM')
	
	//Acrescimos - Aba Deduções
	oView:AddGrid("VDETFVF",oStruFVF,"DETFVF")
	oView:AddIncrementField( 'VDETFVF', 'FVF_ITEM')
	
	//Recolhedores - Aba Deduções
	oView:AddGrid("VDETFVE",oStruFVE,"DETFVE")
	oView:AddIncrementField( 'VDETFVE','FVE_ITEM')
	
	/*
	 * Botões de Campos Complementares
	 */
	oView:AddOtherObject('BTVARFVD',{|oPainel|MontaBotao(oPainel,oView,.T.,.T.,.T.,"FVD",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )
	oView:AddOtherObject('BTVARFVF',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FVF",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )
	
	/*
	 * Partes da Aba 'Deduções'
	 */
	oView:CreateHorizontalBox( 'BOXFVD', 48, /*owner*/, /*lPixel*/, 'PRINCIPAL', 'DEDUCOES')
	oView:CreateHorizontalBox( 'ABA06ACR',52,/*cOwner*/	,/*lUsePixel*/,'PRINCIPAL','DEDUCOES' )
	oView:CreateVerticalBox( 'ABA06CAB', 90, 'BOXFVD', /*lUsePixel*/, 'PRINCIPAL', 'DEDUCOES')

	//Pasta dentro da aba de deduções.
	oView:CreateFolder( 'TIPOSDEDUCOES','ABA06ACR')
	oView:AddSheet('TIPOSDEDUCOES', 'RECOLHEDORES', STR0071) //'Recolhedores'
	oView:AddSheet('TIPOSDEDUCOES', 'ACRESCIMOS'  , STR0070) // 'Acréscimos'
	
	oView:CreateHorizontalBox('DETAILREC'  ,100,,,'TIPOSDEDUCOES', 'RECOLHEDORES')
	oView:CreateVerticalBox( 'BOXFORMVD', 10, 'BOXFVD', /*lUsePixel*/, 'PRINCIPAL', 'DEDUCOES')
	oView:CreateHorizontalBox( 'BOXFVF', 100, /*owner*/, /*lPixel*/, 'TIPOSDEDUCOES', 'ACRESCIMOS')
	oView:CreateVerticalBox( 'DETAILACRES', 90, 'BOXFVF', /*lUsePixel*/, 'TIPOSDEDUCOES', 'ACRESCIMOS')
	oView:CreateVerticalBox( 'BOXFORMVF', 10, 'BOXFVF', /*lUsePixel*/, 'TIPOSDEDUCOES', 'ACRESCIMOS')
	oView:SetOwnerView('BTVARFVD','BOXFORMVD')
	oView:SetOwnerView('BTVARFVF','BOXFORMVF')
	
	/*Seção - 'Deduções' */
	oView:SetOwnerView('VDETFVD'	,'ABA06CAB')
	oView:SetOwnerView('VDETFVF'	,'DETAILACRES')
	oView:SetOwnerView('VDETFVE'	,'DETAILREC')
	oView:EnableTitle('VDETFVD'		,STR0028)	//'Deduções'
	oView:EnableTitleView( 'VDETFVF' )
	oView:EnableTitleView( 'VDETFVE' )
	oView:EnableTitleView( 'BTVARFVF' , '' )

	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'DETFVD'})
	__lDeducoes := .T.
ElseIf cAba == ABA_ENCARGOS
	/*
	 * Partes da Aba 'Encargos'
	 */
	oView:CreateHorizontalBox( 'ABA08CAB', 50 ,/*cOwner*/, /*lUsePixel*/, 'PRINCIPAL', 'ENCARGOS')
	oView:CreateVerticalBox( 'BOXACRES01', 90, 'ABA08CAB', /*lUsePixel*/, 'PRINCIPAL', 'ENCARGOS')
	oView:CreateVerticalBox( 'BOXFORMVB' , 10, 'ABA08CAB', /*lUsePixel*/, 'PRINCIPAL', 'ENCARGOS')
	
	oView:CreateHorizontalBox('ABA08ITE',50 ,/*cOwner*/, /*lUsePixel*/, 'PRINCIPAL', 'ENCARGOS')
	oView:CreateVerticalBox('ABASENCARG',100 ,'ABA08ITE', /*lUsePixel*/, 'PRINCIPAL', 'ENCARGOS')
				
	oView:CreateFolder( 'TIPOSENCARGOS','ABASENCARG')
	oView:AddSheet('TIPOSENCARGOS', 'FVBRECOL', STR0071) // 'Recolhedores'
	oView:AddSheet('TIPOSENCARGOS', 'FVBACRES', STR0070) // 'Acréscimos'
	
	oView:CreateVerticalBox('DETREC',100,/*cOwner*/,/*lUsePixel*/,'TIPOSENCARGOS', 'FVBRECOL')
	oView:CreateVerticalBox('DETACR',90,/*cOwner*/,/*lUsePixel*/,'TIPOSENCARGOS', 'FVBACRES')
	oView:CreateVerticalBox('BOXFMVBFVF',10,/*cOwner*/,/*lUsePixel*/,'TIPOSENCARGOS', 'FVBACRES')
		
	//Encargos
	oView:AddGrid("VDETFVB",oStruFVB,"DETFVB")
	oView:AddIncrementField( 'VDETFVB', 'FVB_ITEM')
	oView:SetOwnerView("VDETFVB",'BOXACRES01')
	oView:EnableTitle('VDETFVB',STR0027) //'Encargos'
	
	//Acrescimos - Aba Encargos
	oView:AddGrid("VDETFVFEN",oStruFVF,"DETFVFEN")
	oView:AddIncrementField( 'VDETFVFEN', 'FVF_ITEM')
	oView:SetOwnerView("VDETFVFEN",'DETACR')
	
	//Recolhedores - Aba Encargos
	oView:AddGrid("VDETFVEEN",oStruFVE,"DETFVEEN")
	oView:AddIncrementField( 'VDETFVEEN', 'FVE_ITEM')
	oView:SetOwnerView("VDETFVEEN",'DETREC')
	
	/*
	 * Botões de Campos Complementares
	 */
	oView:AddOtherObject('BTVARFVB',{|oPainel|MontaBotao(oPainel,oView,.T.,.F.,.T.,"FVB",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )
	oView:SetOwnerView('BTVARFVB','BOXFORMVB')
	
	oView:AddOtherObject('BTVRFVBFVF',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FVF",oViewPai,"DETFVFEN")},{|oPainel|DesmontaBotao(oPainel)} )
	oView:SetOwnerView('BTVRFVBFVF','BOXFMVBFVF')

	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'DETFVB'})
ElseIf cAba == ABA_DESPESAS_ANULAR

	/*
	 * Partes da Aba 'Despesa a Anular'
	 */
	oView:CreateHorizontalBox( 'BOXFVL'	 , 50  , /*owner*/, /*lPixel*/    ,'PRINCIPAL', 'ANULAR')
	oView:CreateVerticalBox( 'ABA10CAB' , 90, 'BOXFVL', /*lUsePixel*/, 'PRINCIPAL', 'ANULAR')
	
	//Despesas a Anular
	oView:AddGrid("VDETFVL",oStruFVL,"DETFVL")
	oView:AddIncrementField( 'VDETFVL', 'FVL_ITEM')
	oView:SetOwnerView("VDETFVL",'ABA10CAB')
	
	oView:CreateHorizontalBox( 'BOXFVM', 50, /*owner*/, /*lPixel*/, 'PRINCIPAL', 'ANULAR')
	oView:CreateVerticalBox( 'ABA10ITE', 90, 'BOXFVM', /*lUsePixel*/, 'PRINCIPAL', 'ANULAR')
	/*
 	 * Itens de Despesa a Anular
	 */
	oView:AddGrid("VDETFVM",oStruFVM,"DETFVM")
	oView:AddIncrementField( 'VDETFVM','FVM_ITEM')
	oView:SetOwnerView("VDETFVM",'ABA10ITE')
	
	/*
	 * Botões de Campos Complementares
	 */
	oView:AddOtherObject('BTVARFVL',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FVL",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )
	oView:AddOtherObject('BTVARFVM',{|oPainel|MontaBotao(oPainel,oView,.F.,.F.,.T.,"FVM",oViewPai)},{|oPainel|DesmontaBotao(oPainel)} )

	oView:CreateVerticalBox( 'BOXFORMVL', 10, 'BOXFVL', /*lUsePixel*/, 'PRINCIPAL', 'ANULAR')
	oView:CreateVerticalBox( 'BOXFORMVM', 10, 'BOXFVM', /*lUsePixel*/, 'PRINCIPAL', 'ANULAR')
	
	// Seção - Despesas a Anular
	
	oView:SetOwnerView('BTVARFVL'   ,'BOXFORMVL')
	oView:SetOwnerView('BTVARFVM','BOXFORMVM')
	oView:EnableTitleView('BTVARFVM' , '' )
	 
	oView:EnableTitle("VDETFVL"		,STR0029) // 'Despesas a Anular'
	oView:EnableTitle("VDETFVM"		,STR0072) // 'Itens'

	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'DETFVL'})
ElseIf cAba == ABA_DADOS_PAGAMENTO
	/*
	 * Formulário da Aba Dados de Pagamento
	 */
	oView:CreateHorizontalBox( 'ABA04GRL', 25, /*owner*/, /*lPixel*/, 'PRINCIPAL', 'DADOSPAG')
	oView:AddField("GRUPOPRIN",oStruGrpP,"CABDI")
	oView:SetOwnerView("GRUPOPRIN"	,'ABA04GRL')
	oView:EnableTitle('GRUPOPRIN'	, STR0065) // 'Grupo Principal'
	
	/*
	 * Grid de Favorecidos da Aba de Dados de Pagamento
	 */
	oView:AddGrid("DADOSFAV",oStruFav,"DADOPAGFAV")
	oView:AddIncrementField( 'DADOSFAV', 'FV6_ITEM')
	oView:CreateHorizontalBox( 'DADOSFAVOR', 75, /*owner*/, /*lUsePixel*/, 'PRINCIPAL', 'DADOSPAG')
	oView:CreateVerticalBox( 'GRIDFAV', 90, 'DADOSFAVOR', /*lUsePixel*/, 'PRINCIPAL', 'DADOSPAG')
	oView:SetOwnerView("DADOSFAV"	,'GRIDFAV')
	oView:EnableTitle('DADOSFAV'	, STR0066) // 'Dados do Favorecidos'
	
	/*
	 * Botão de Pré-Doc da Aba Dados de Pagamento
	 */
	oView:CreateVerticalBox( 'BOXPREDC', 10, 'DADOSFAVOR', /*lUsePixel*/, 'PRINCIPAL', 'DADOSPAG')
	oView:AddOtherObject('BOXPREFV6',{|oPainel|MontaBotao(oPainel,oView,.T.,.F.,.F.,"FV6",oViewPai,,"AllTrim(oModel:GetModel('CABDI'):GetValue('FV0_TIPODC')) $ 'DT|FL|RB|PC|NP|RP'")},{|oPainel|DesmontaBotao(oPainel)} )
	oView:SetOwnerView('BOXPREFV6','BOXPREDC')
	
	aAdd(__aFolder, {CVALTOCHAR(Len(__aFolder)+1),'DETFV6'})
EndIf
		
Return

/*/{Protheus.doc} TotAcres
Método para cálculo do totalizador de Acréscimos do documento hábil
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário para criar o totalizador.
@return nTotal Valor totalizado de acréscimos do documento hábil.
@author Marylly Araújo Silva
@since 12/02/2014
@version 12.1.4
/*/
Static Function TotAcres(oModel)
Local nTotal	:= 0
Local aSaveLines:= FWSaveRows()
Local nAcrescimo:= 0

oModel:Activate()

For nAcrescimo := 0 To oModel:GetModel("DETFVF"):Length()
	nTotal += oModel:GetModel("DETFVF"):GetValue("FVF_VALOR")
Next nAcrescimo

For nAcrescimo := 0 To oModel:GetModel("DETFVFEN"):Length()
	nTotal += oModel:GetModel("DETFVFEN"):GetValue("FVF_VALOR")
Next nAcrescimo

oModel:DeActivate()

FWRestRows(aSaveLines)
Return nTotal

/*/{Protheus.doc} GetViewCorreto
Retorna o View correto baseado no tipo
@param nTipo Tipo de view tipo == 1 retorna o View Principal, Tipo == 2 Retorna o Dinamico
@return oView Objeto do Tipo FWFormView desejada de acordo com o parâmetro nTipo
@author Marylly Araújo Silva
@since 12/02/2014
@version 12.1.4
/*/
Static Function GetViewCorreto(nTipo)
Local oView
Local oOther
oView := fwviewactive()
IF nTipo == 1
	if oView:oViewOwner != Nil
		oView := oView:oViewOwner
	endif
Else //O dinamico
	If oView:oViewOwner == Nil
		oView := __oViewDynamic
	Endif
Endif
Return oView

/*/{Protheus.doc} FV0FrmPre
Pré-validação da formfield dos dados básicos do DH
 	
@author	Pedro Alencar	
@since	04/02/2015	
@version	P12.1.4
@param	oFrmModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
@param	cField Nome do campo ao qual a validação foi chamada.
/*/
Static Function FV0FrmPre( oFrmModel, cAction, cField, xValue )
	Local lRet := .T.
								
	If cAction == "SETVALUE" .AND. cField == "FV0_TIPODC"
			
		If oFrmModel:GetOperation() == MODEL_OPERATION_INSERT
			If ! Empty( __cTpDocAnt ) .AND. __cTpDocAnt <> xValue 
				If ! MsgYesNo( OemToAnsi(STR0053) ) //"Ao alterar o tipo de documento, todos os dados serão apagados. Confirma a alteração?"
					lRet := .F.							
					Help( "", 1, "FV0FrmPre1", , OemToAnsi( STR0134 ), 1, 0 ) //"Alteração cancelada."
				EndIf	
			Endif
		Endif
		
	EndIf

	If cAction == "SETVALUE" .AND. (cField == "FV0_FORNEC")
			
		If oFrmModel:GetOperation() == MODEL_OPERATION_INSERT
			If ! Empty( __cTpForAnt ) .AND. __cTpForAnt <> xValue 
				If ! MsgYesNo( OemToAnsi("Ao alterar o fornecedor, todos os dados serão apagados. Confirma a alteração?") ) //"Ao alterar o tipo de documento, todos os dados serão apagados. Confirma a alteração?"
					lRet := .F.							
					Help( "", 1, "FV0FrmPre1", , OemToAnsi( STR0134 ), 1, 0 ) //"Alteração cancelada."
				EndIf	
			Endif
		Endif
		
	EndIf

	If cAction == "SETVALUE" .AND. (cField == "FV0_LOJA") 
			
		If oFrmModel:GetOperation() == MODEL_OPERATION_INSERT
			If ! Empty( __cTpLojAnt ) .AND. __cTpLojAnt <> xValue 
				If ! MsgYesNo( OemToAnsi("Ao alterar o fornecedor, todos os dados serão apagados. Confirma a alteração?") ) //"Ao alterar o tipo de documento, todos os dados serão apagados. Confirma a alteração?"
					lRet := .F.							
					Help( "", 1, "FV0FrmPre1", , OemToAnsi( STR0134 ), 1, 0 ) //"Alteração cancelada."
				EndIf	
			Endif
		Endif
		
	EndIf

	If cAction == "SETVALUE" .AND. cField == "FV0_UGPAGA"
			
		If oFrmModel:GetOperation() == MODEL_OPERATION_INSERT
			If ! Empty( __cTpUpgAnt ) .AND. __cTpUpgAnt <> xValue 
				If ! MsgYesNo( OemToAnsi("Ao alterar a unidade, todos os dados serão apagados. Confirma a alteração?") ) //"Ao alterar o tipo de documento, todos os dados serão apagados. Confirma a alteração?"
					lRet := .F.							
					Help( "", 1, "FV0FrmPre1", , OemToAnsi( STR0134 ), 1, 0 ) //"Alteração cancelada."
				EndIf	
			Endif
		Endif
		
	EndIf
			
Return lRet

/*/{Protheus.doc} LimpaDoc
Limpa a grid de documentos relacionados, ao mudar o fornecedor
 
@author	Pedro Alencar	
@since	16/02/2015	
@version	P12.1.4
@param	cIDView Identificação da View onde a função está sendo chamada.
@param	cField Nome do campo ao qual a validação foi chamada.
/*/
Static Function LimpaDoc(oNaoUsado, cIDView, cField, xValue)
Local oModel
Local oSubView
Local oFV1
Local nX := 0
	
oView := GetViewCorreto( 1 )
oSubView := oView:GetViewObj("DYNAMIC")[3]
oModel := oView:GetModel()
oFV1 := oModel:GetModel( "DOCORI" )
	
If __FV0_FORNEC <> xValue
	If ! Empty( __cArqTrab )
		LimpaTMP()
	Endif
		
		//Deleta os documentos de origem na grid 
	If ! oFV1:IsEmpty()
		For nX := 1 To oFV1:Length()
			oFV1:GoLine( nX )
			If !oFV1:IsDeleted()
				oFV1:DeleteLine()
			Endif
		Next nX
	Endif
		
	oSubView:Refresh()
	oSubView:Deactivate()
	oSubView:Activate()
Endif
	
__FV0_FORNEC := xValue

Return Nil

/*/{Protheus.doc} LimpaDH
Limpa todos os dados do DH ao trocar o tipo de documento
 
@author	Pedro Alencar	
@since	16/02/2015	
@version	P12.1.4
@param	oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário

/*/
Static Function LimpaDH( oModel )
	Local aModels := {}
	Local nX := 0
	
	aModels := oModel:GetModelIds()
	For nX := 1 To Len( aModels )
		oModel:GetModel( aModels[nX] ):ClearData( .T. )
	Next nX
	LimpaTMP()
Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} F761VLMod

Validação do carregamento do modelo de dados 

@author Pequim
@since 25/02/2015
@version 1.0
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
//-------------------------------------------------------------------

Function F761VLMod(oModel)

Local nOperation 	:= oModel:GetOperation()
Local lRet			:= .T.
Local cDescricao	:= ""

//Valida se o DH pode ser excluido. 
If (nOperation == MODEL_OPERATION_DELETE ) .And. FV0->FV0_STATUS != "1"
	Help(" ",1,"F761DELDH",,STR0144 + CRLF + STR0145,1,0) //"Não é permitida a exclusão deste documento hábil. "###"Apenas documentos hábeis com status [Aguardando Envio] podem ser excluidos."
	lRet := .F.
EndIf

//Valida se o DH pode ser alterado
//Poderão ser alteradas apenas DHs com os seguintes status: 
//	1 (Aguardando Envio) ou 
//	6 (Com Erros) e sem codigo de SIAFI
If lRet .And. nOperation == MODEL_OPERATION_UPDATE .AND. __nOper == 0 .and. (FV0->FV0_STATUS != "1" .OR. (FV0->FV0_STATUS == "6" .and. !Empty(FV0->FV0_CODSIA)))  
	Help(" ",1,"F761ALTDH",,STR0149 + CRLF + STR0150,1,0) //"Não é permitida a alteração deste documento hábil."###"Apenas documentos hábeis com status [Aguardando Envio] ou [Com erro no envio] podem ser alterados."	
	lRet := .F.
Endif

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Fina761Env

Processos de validação e ativação do WS do SIAFI 

@author Pequim
@since 25/02/2015
@version 1.0
@param nOper	Tipo da operação que está se realizando
/*/
//-------------------------------------------------------------------
Function Fina761Env(nOper)

Local lRet 		:= .T.
Local cMens01 	:= ""
Local cMens02 	:= ""
Local aLoteRet	:= {}
Local lLote		:= .F.
Local cArqTra	:= ""
Local cMarca	:= ""

DEFAULT nOper := 0

If nOper == 1  //Envio DH
	__nOper := OPER_ENVIAR

	If !(FV0->FV0_STATUS $ "1|6") 
		cMens01 := STR0151	//"Este documento hábil não pode ser enviado." 
		cMens02 := STR0152	//"Apenas documentos hábeis com status [Aguardando Envio] ou [Com erro no envio] podem ser enviados para integração no SIAFI."
		lRet := .F.
	Else	
		WsSendDH( DH_TRANS_INCLUSAO )
	EndIf

ElseIf nOper == 2 // Cancelamento DH

	__nOper := OPER_CANCELAR

	If !(FV0->FV0_STATUS $ "2|8") 
		cMens01 := STR0153	//"Este documento hábil não pode ser cancelado." 
		cMens02 := STR0154	//"Apenas documentos hábeis com status [Aguardando Realização] ou [Com erro no cancelamento] podem ser enviados para integração no SIAFI."
		lRet := .F.
	Else	
		WsSendDH( DH_TRANS_CANCELAMENTO )
	Endif

ElseIf nOper == 3 // Realização

	__nOper := OPER_REALIZAR
	
	If !(FV0->FV0_STATUS $ "2|7") 
		cMens01 := STR0155	//"Este documento hábil não pode ser realizado." 
		cMens02 := STR0156	//"Apenas documentos hábeis com status [Aguardando Realização] ou [Com erro na realização] podem ser enviados para integração no SIAFI."
		lRet := .F.
	Else	
		WsSendDH( DH_TRANS_REALIZACAO )
	Endif

ElseIf nOper == 4 // Estorno

	__nOper := OPER_ESTORNAR

	If !(FV0->FV0_STATUS $ "3|9") 
		cMens01 := STR0157	//"Este documento hábil não pode ser estornado." 
		cMens02 := STR0158	//"Apenas documentos hábeis com status [Realizado] ou [Com erro no estorno] podem ser enviados para integração no SIAFI."
		lRet := .F.
	Else	
		WsSendDH( DH_TRANS_ESTORNO )
	Endif

ElseIf nOper == OPER_REALLOTE
	__nOper := OPER_REALLOTE
	
	aLoteRet:= F761Lote()
	lLote	:= aLoteRet[1]
	cArqTra	:= aLoteRet[2]
	cMarca	:= aLoteRet[3]
	If lLote
		WsSendDH( OPER_REALLOTE, lLote, cArqTra, cMarca)	
	EndIf

Endif

If !lRet 
	Help(" ",1,"F761WSDH",,cMens01 + CRLF + cMens02 ,1,0)
Endif

If(_oFINA761A <> NIL)
	_oFINA761A:Delete()
	_oFINA761A := NIL
EndIf

If(_oFINA761B <> NIL)
	_oFINA761B:Delete()
	_oFINA761B := NIL
EndIf

If(_oFINA761C <> NIL)
	_oFINA761C:Delete()
	_oFINA761C := NIL
EndIf

If(_oFINA761D <> NIL)
	_oFINA761D:Delete()
	_oFINA761D := NIL
EndIf

__nOper := 0

Return .t.

//-------------------------------------------------------------------
/*/{Protheus.doc} F761Status()
X3Combo do campo FV0_STATUS

@author Mauricio Pequim Jr
@since 26/02/2015
@version P12.1.4
/*/
//-------------------------------------------------------------------
Function F761Status()

Local cOpcoes := ""

cOpcoes := "1="+STR0002+";" //"Aguardando Envio"
cOpcoes += "2="+STR0003+";" //"Aguardando Realização"
cOpcoes += "3="+STR0004+";" //"Realizado"
cOpcoes += "4="+STR0005+";" //"Cancelado"
cOpcoes += "5="+STR0006+";" //"Estornado"
cOpcoes += "6="+STR0007+";" //"Com erro no envio" 
cOpcoes += "7="+STR0146+";" //"Com erro na realização" 
cOpcoes += "8="+STR0147+";" //"Com erro no cancelamento"
cOpcoes += "9="+STR0148+";" //"Com erro no estorno"
cOpcoes += "A="+STR0161	 //"Expirado"

Return cOpcoes

//-------------------------------------------------------------------
/*/{Protheus.doc} F761LibTit()
Liberação do título a pagar quando o documento hábil é atualizado, excluído, cancelado ou estornado.

@author Marylly Araújo Silva
@since 26/02/2015
@version P12.1.4
@param cNumDoc Número do Documento Hábil
/*/
//-------------------------------------------------------------------
Function F761LibTit(cNumDoc)
Local cSE2Als		:= ""
Local cSE2Qry		:= ""

cSE2Als := GetNextAlias()
cSE2Qry := "SELECT " + CRLF
cSE2Qry += " SE2.R_E_C_N_O_ " + CRLF
cSE2Qry += " FROM " + RetSqlName("SE2") + " SE2 " + CRLF
cSE2Qry += " WHERE " + CRLF
cSE2Qry += RetSqlCond("SE2") + CRLF
cSE2Qry += " AND SE2.E2_DOCHAB = '" + cNumDoc + "' "

dbUseArea( .T., "TOPCONN", TcGenQry( , , cSE2Qry ), cSE2Als, .T., .T. )

While !( cSE2Als )->( Eof() )
	SE2->( DbGoTo( ( cSE2Als )->R_E_C_N_O_ ) )
	RecLock( "SE2", .F. )
	SE2->E2_DOCHAB := Space( Len( cNumDoc ) )
	SE2->( MsUnLock() )
	( cSE2Als )->( DbSkip() )
EndDo

( cSE2Als )->( dbCloseArea() )
cSE2Als := ""

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F761Load
inicializador padrão dos campos UGPAG e UGDESC em caso de Alteração

@author Mauricio Pequim Jr
@since 14/05/2015
@version 1.0

/*/
//-------------------------------------------------------------------

Function F761Load(oModel)
Local nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE

	oModel:GetModel("CABDI"):LoadValue("FV0_UGPAGA",Iif(!INCLUI,FV0->FV0_UGPAGA,'') )
	oModel:GetModel("CABDI"):LoadValue("FV0_UGDSPG",Iif(!INCLUI,Posicione('CPA',1,xFilial('CPA') + FV0->FV0_UGPAGA,'CPA_DESORG'),'') )
	oModel:GetModel("CABDI"):LoadValue("UGPAGA",Iif(!INCLUI,FV0->FV0_UGPAGA,'') )
	oModel:GetModel("CABDI"):LoadValue("UGDESC",Iif(!INCLUI,Posicione('CPA',1,xFilial('CPA') + FV0->FV0_UGPAGA,'CPA_DESORG'),'') )

Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F761UGGAT
Gatilho para os campos UGPAG e UGDESC

@author Mauricio Pequim Jr
@since 14/05/2015
@version 1.0
@return Código da UG Pagadora

/*/
//-------------------------------------------------------------------

Function F761UGGAT(oModel)

Local cCodUgPaga := oModel:GetValue("FV0_UGPAGA")
Local cDescUgPaga := Posicione('CPA',1,xFilial('CPA') + cCodUgPaga,'CPA_DESORG')
Local oView := FWViewActivate()

oModel:setValue("UGPAGA"    , cCodUgPaga  ) 
oModel:LoadValue("UGDESC"    , cDescUgPaga )
oModel:LoadValue("FV0_UGDSPG", cDescUgPaga )
 
if oView != Nil
	oView:Refresh()
Endif

Return cCodUgPaga

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761GatNE
Gatilho do campo de Nota de Empenho para preenchimento da Fonte de Recurso do Documento Hábil

@author Marylly Araújo Silva
@since 07/05/2015
@version 12.1.5
@param 	cFilNE	Filial do documento hábil para busca da nota de empenho para o documento hábil
@param	cNE		Número de identificação da nota de empenho do documento hábil.
@return cRet	Número de identificação da fonte de recurso encontrada a partir da nota de empenho informada no documento hábil.
/*/
//-----------------------------------------------------------------------
Function F761GatNE(cFilNE,cNE,cCpoDsc,cIdModel)

Local cRet			:= ""
Local cNEQry		:= ""
Local cNEAls		:= GetNextAlias()
Local oModel		:= FWModelActive()
Local oMdlFonRec	:= Nil

oMdlFonRec := oModel:GetModel(cIdModel)

cNEQry := "SELECT " + CRLF
cNEQry += " SA6.A6_NUMCON " + CRLF
cNEQry += ", SA6.A6_NOME " + CRLF
cNEQry += " FROM " + RetSqlName("CX0") + " CX0 " 
cNEQry += " INNER JOIN " + RetSqlName("SA6") + " SA6 ON SA6.A6_NUMCON = CX0.CX0_FONREC " + CRLF
cNEQry += " WHERE " + RetSqlCond("SA6") + " " + CRLF
cNEQry += " AND CX0.CX0_FILIAL = '" + xFilial("CX0",cFilNE) + "' "
cNEQry += " AND CX0.CX0_CODNE = '" + cNE  + "' "
cNEQry := ChangeQuery(cNEQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cNEQry),cNEAls,.T.,.T.)

If (cNEAls)->(!Eof())
	cRet := (cNEAls)->A6_NUMCON
Else
	cRet := " "
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FltNE

Construção de Browse de Consulta Padrão do tipo Especifíca para as Notas de Empenho disponíveis com saldo para o documento hábil.

@return lRet - Retorna se o campo onde a consulta padrão foi chamada será preecnhido.
 
@author Marylly Araújo Silva
@since 11/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F761FltNE()

Local oMdl			:= FWModelActive()
Local lRet			:= .T.
Local oBrowse		:= Nil
Local cNEAls		:= GetNextAlias()
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgTela		:= Nil
Local cNEQry		:= ""
Local cFornec		:= oMdl:GetModel("CABDI"):GetValue("FV0_FORNEC")
Local cForLoj		:= oMdl:GetModel("CABDI"):GetValue("FV0_LOJA")
Local cTabGrid		:= SUBSTR(ReadVar(),4,3)
Local oMdlGrid		:= ""
Local cCpoFonR		:= cTabGrid + "_NEMPE"
Local cValNE		:= ""
/*
 * Definição do índice da Consulta Padrão
 */
Local aIndex		:= {"CX0_CODNE"}
/*
 * Definição da Descrição da Chave de Pesquisa da Consulta Padrão
 */
Local aSeek			:= {{ STR0233, {{"","C",15,0,STR0233,,}} }} //"Nota de Empenho"#"Nota de Empenho"
Local lEdital		:= .F.

cRet761F3 := ""

If EMPTY(cFornec+cForLoj)
	Help(" ",1,"CONSNES",, STR0232 ,3,1) //"Informe um fornecedor/loja para o documento hábil"
	lRet := .F.
Else
	cNEQry := " SELECT " + CRLF
	cNEqRY += " CX0.CX0_FILIAL, " + CRLF
	cNEQry += " CX0.CX0_CODNE, 	" + CRLF
	cNEQry += " SUM(CX1.CX1_VLRCON) VALORCON, " + CRLF
	cNEQry += " SUM(CX1.CX1_VLRDIS) VALORDIS " + CRLF
	cNEQry += " FROM " + RetSqlName("CX0") + " CX0 " + CRLF
	cNEQry += " INNER JOIN " + RetSqlName("CX1") + " CX1 " + CRLF
	cNEQry += " ON CX0.CX0_CODNE = CX1.CX1_CODNE " + CRLF
	cNEQry += " WHERE " + RetSqlCond("CX0") + CRLF
	cNEQry += " AND " + RetSqlCond("CX1") + CRLF
	cNEQry += " AND CX0.CX0_CODFOR = '" + cFornec + "' " + CRLF
	cNEQry += " AND CX0.CX0_LOJFOR = '" + cForLoj + "' " + CRLF
	cNEQry += " AND (CX1.CX1_VLRCON > 0 OR CX1.CX1_VLRDIS > 0) " + CRLF
	cNEQry += " GROUP BY CX0.CX0_FILIAL, CX0.CX0_CODNE "
	
	nSuperior := 0
	nEsquerda := 0
	nInferior := 460
	nDireita  := 800
	
	DEFINE MSDIALOG oDlgTela TITLE STR0233 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"Nota de Empenho"
	
	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription(STR0233) // "Notas de Empenho"
	oBrowse:SetAlias(cNEAls)
	oBrowse:SetDataQuery()
	oBrowse:SetQuery(cNEQry)
	oBrowse:SetOwner(oDlgTela)
	oBrowse:SetDoubleClick({ || cRet761F3 := (oBrowse:Alias())->CX0_CODNE, oDlgTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0046)	, {|| cRet761F3 := (oBrowse:Alias())->CX0_CODNE, oDlgTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0058), {|| cRet761F3 := "", lRet := .F., oDlgTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek({||.T.},aSeek)
	
	ADD COLUMN oColumn DATA { ||  CX0_FILIAL } TITLE STR0234 SIZE 15 OF oBrowse //"Filial"
	ADD COLUMN oColumn DATA { ||  CX0_CODNE  } TITLE STR0236 SIZE 15 OF oBrowse //"Código"
	ADD COLUMN oColumn DATA { ||  TRANSFORM(Iif(VALORCON > 0,VALORCON,VALORDIS),"@E 999,999,999,999,999.999")  	 } TITLE STR0218 SIZE 17 OF oBrowse //"Valor"
			
	oBrowse:Activate()
	
	ACTIVATE MSDIALOG oDlgTela CENTERED
	
	If cTabGrid == "FV2"
		oMdlGrid := oMdl:GetModel("PCOSITUACA")
	ElseIf cTabGrid == "FV5"
		oMdlGrid := oMdl:GetModel("PCOEMPENHO")
	Else
		oMdlGrid := oMdl:GetModel("DET"+cTabGrid)
	EndIf
	
	cValNE := oMdlGrid:GetValue(cCpoFonR)
	
	If cValNE <> cRet761F3
		oMdlGrid:SetValue(cTabGrid + "_SUBEMP","  ")
	EndIf
	
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} F761RetNE

Retorna a nota de empenho selecionada na consulta padrão especifíca e preenche o campo.

@return cRet761F3 - Retorno da consulta padrão de nota de empenho
@author Marylly Araújo Silva
@since 11/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F761RetNE()

Return( cRet761F3 )

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FltSB

Construção de Browse de Consulta Padrão do tipo Especifíca para as Notas de Empenho disponíveis com saldo para o documento hábil.

@return lRet - Retorna se o campo onde a consulta padrão foi chamada será preecnhido.
 
@author Marylly Araújo Silva
@since 21/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F761FltSB()

Local oMdl			:= FWModelActive()
Local lRet			:= .T.
Local oBrowse		:= Nil
Local cNEAls		:= GetNextAlias()
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgTela		:= Nil
Local cNEQry		:= ""
Local cFornec		:= oMdl:GetModel("CABDI"):GetValue("FV0_FORNEC")
Local cForLoj		:= oMdl:GetModel("CABDI"):GetValue("FV0_LOJA")
Local cTabGrid		:= SUBSTR(ReadVar(),4,3)
Local oMdlGrid		:= ""
Local cCpoFonR		:= cTabGrid + "_NEMPE"
Local cValNE		:= ""
/*
 * Definição do índice da Consulta Padrão
 */
Local aIndex		:= {"CX1_SUBITE"}
/*
 * Definição da Descrição da Chave de Pesquisa da Consulta Padrão
 */
Local aSeek			:= {{STR0237, {{"","C",15,0,STR0237,,}} }} //"Sub-Item"#//"Sub-Item"

cRet761F3 := ""

If cTabGrid == "FV2"
	oMdlGrid := oMdl:GetModel("PCOSITUACA")
ElseIf cTabGrid == "FV5"
	oMdlGrid := oMdl:GetModel("PCOEMPENHO")
Else
	oMdlGrid := oMdl:GetModel("DET"+cTabGrid)
EndIf

cValNE := oMdlGrid:GetValue(cCpoFonR)
	
If EMPTY(cFornec+cForLoj)
	Help(" ",1,"CONSNES",, STR0232 ,3,1) //"Informe um fornecedor/loja para o documento hábil"
	lRet := .F.
ElseIf EMPTY(cValNE)
	Help(" ",1,"CONSNES",, STR0238 ,3,1) //"Informe uma nota de empenho para consulta dos subitens disponíveis."
	lRet := .F.
Else
	cNEQry := " SELECT " + CRLF
	cNEqRY += " CX1.CX1_FILIAL, " + CRLF
	cNEQry += " CX1.CX1_SUBITE, " + CRLF
	cNEQry += " SUM(CX1.CX1_VLRCON) VALORCON, " + CRLF
	cNEQry += " SUM(CX1.CX1_VLRDIS) VALORDIS " + CRLF
	cNEQry += " FROM " + RetSqlName("CX0") + " CX0 " + CRLF
	cNEQry += " INNER JOIN " + RetSqlName("CX1") + " CX1 " + CRLF
	cNEQry += " ON CX0.CX0_CODNE = CX1.CX1_CODNE " + CRLF
	cNEQry += " WHERE " + RetSqlCond("CX0") + CRLF
	cNEQry += " AND " + RetSqlCond("CX1") + CRLF
	cNEQry += " AND CX0.CX0_CODFOR	= '" + cFornec	+ "' " + CRLF
	cNEQry += " AND CX0.CX0_LOJFOR	= '" + cForLoj	+ "' " + CRLF
	cNEQry += " AND CX0.CX0_CODNE	= '" + cValNE	+ "' " + CRLF
	cNEQry += " AND (CX1.CX1_VLRCON > 0 OR CX1.CX1_VLRDIS > 0) " + CRLF
	cNEQry += " GROUP BY CX1.CX1_FILIAL, CX0.CX0_CODNE, CX1.CX1_SUBITE "
	
	nSuperior := 0
	nEsquerda := 0
	nInferior := 460
	nDireita  := 800
	
	DEFINE MSDIALOG oDlgTela TITLE STR0235 FROM nSuperior,nEsquerda TO nInferior,nDireita PIXEL //"SubItens de Nota de Empenho"
	
	oBrowse := FWFormBrowse():New()
	oBrowse:SetDescription(STR0235) // "SubItens de Nota de Empenho"
	oBrowse:SetAlias(cNEAls)
	oBrowse:SetDataQuery()
	oBrowse:SetQuery(cNEQry)
	oBrowse:SetOwner(oDlgTela)
	oBrowse:SetDoubleClick({ || cRet761F3 := (oBrowse:Alias())->CX1_SUBITE, oDlgTela:End()})
	oBrowse:AddButton( OemTOAnsi(STR0046)	, {|| cRet761F3 := (oBrowse:Alias())->CX1_SUBITE, oDlgTela:End() } ,, 2 ) //"Confirmar"
	oBrowse:AddButton( OemTOAnsi(STR0058), {|| cRet761F3 := "", lRet := .F., oDlgTela:End() } ,, 2 ) //"Cancelar"
	oBrowse:DisableDetails()
	oBrowse:SetQueryIndex(aIndex)
	oBrowse:SetSeek({||.T.},aSeek)
	
	ADD COLUMN oColumn DATA { ||  CX1_FILIAL } TITLE STR0234 SIZE 15 OF oBrowse //"Filial"
	ADD COLUMN oColumn DATA { ||  CX1_SUBITE } TITLE STR0237 SIZE 15 OF oBrowse //"Sub-Item"
	ADD COLUMN oColumn DATA { ||  TRANSFORM(Iif(VALORCON > 0,VALORCON,VALORDIS),"@E 999,999,999,999,999.999")  } TITLE STR0218 SIZE 17 OF oBrowse //"Valor"
			
	oBrowse:Activate()
	
	ACTIVATE MSDIALOG oDlgTela CENTERED
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} F761AtuNE

Função de gravação das movimentações de nota de empenho

@author Marylly Araújo Silva
@since 21/05/2015
@version 12.1.6
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
@param nOper Operação de edição do documento hábil
/*/
//-------------------------------------------------------------------
Function F761AtuNE( oModel , nOper )
Local aRet			:= {}
Local oMdlFV0		:= oModel:GetModel("CABDI")
Local oMdlFV5		:= oModel:GetModel("PCOEMPENHO")	// Notas de Empenhos
Local oMdlFVB		:= oModel:GetModel("DETFVB")		// Acréscimos do Documento Hábil
Local oMdlFVF		:= oModel:GetModel("DETFVF")		// Acréscimos do Documento Hábil
Local nCntEmp		:= 0
Local aDados		:= {}
Local aDocs			:= {}
Local oView			:= FWViewActive()
Local lMostraHLP	:= oView:GetModel():GetId() != "FINA761"
Local aMov			:= {}
Local lExcluiMov	:= MODEL_OPERATION_DELETE == oModel:GetOperation()
Local cDebCred		:= ""
Local cTipMov		:= "0"
Local cHist			:= ""
Local aMdlInfo		:= {}
Local nTabela		:= 0
Local oMdlAux		:= Nil
Local lEdital		:= .F.

Aadd(aMdlInfo,{"FV5","FV5_NEMPE","FV5_SUBEMP","FV5_EVALOR"})
Aadd(aMdlInfo,{"FVB","FVB_NEMPE","FVB_SUBEMP","FVB_VALOR"})
Aadd(aMdlInfo,{"FVF","FVF_NEMPE","FVF_SUBEMP","FVF_VALOR"})

/*
Definição do aDados 
	aDados[1] = Código da Nota de Empenho
	aDados[2] = Tipo do Documento
				1= Pedido de Compra
				2= Documento de Entrada
				3= Documento Habil
				4= NE Reforço								
				5= NE Cancelamento				
				6= NE Contrato Continuado				
			    7= NE Resto a Pagar
	aDados[3] = Código do Documento
	aDados[4] = Evento
				1=Inclusao
				2=Estorno
				3=Exclusao
	aDados[5] = Tipo de Movimentação
				1=Debito
				2=Credito
	aDados[6] = Valores de Movimentação
				 {{Item, Valor}}
	aDados[7] = Observação	 
	lDelCX2   = Indica se será processado a deleção das linhas do histório com 
				 o valor zerado
*/

For nTabela := 1 To Len(aMdlInfo)
	oMdlAux := &("oMdl" + aMdlInfo[nTabela][1])
	For nCntEmp := 1 To oMdlAux:Length()
		aMov	:= {}
		aDados	:= {}
		
		If oMdlAux:GetValue(aMdlInfo[nTabela][4],nCntEmp) > 0
			lEdital	:= !EMPTY(Posicione('CX0',1,xFilial('CX0') + oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp),'CX0_CODEDT'))
			
			aMov := F761MovNE(oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp),oMdlAux:GetValue(aMdlInfo[nTabela][3],nCntEmp),oMdlAux:GetValue(aMdlInfo[nTabela][4],nCntEmp))
			
			If oModel:GetOperation() == MODEL_OPERATION_INSERT
				cTipMov	:= "1" // Inclusão de Movimento de Notas de Empenho
				cDebCred:= "1" // Débito
				cHist	:= STR0239 //"Inclusão Documento Hábil"
			ElseIf oModel:GetOperation() == MODEL_OPERATION_UPDATE 
				cTipMov	:= "2" // Estorno de Movimento de Notas de Empenho
				cDebCred	:= "2" // Crédito
				If nOper == OPER_CANCELAR
					cHist := STR0240 //"Estorno Cancelamento Documento Hábil"
				Else
					cHist := STR0241 //"Estorno Atualização Documento Hábil"
				EndIf
				Aadd(aDados, oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp))
				Aadd(aDados, '3') // Movimentação de Nota de Empenho através do Documento Hábil
				Aadd(aDados, oMdlFV0:GetValue("FV0_CODIGO"))
				Aadd(aDados, cTipMov)
				Aadd(aDados, cDebCred) // 1-Débito; 2-Crédito;	
				Aadd(aDados, aMov)	
				Aadd(aDados, cHist)
				Aadd(aDocs, aDados)
				
				aDados		:= {}
				cTipMov	:= "1" // Estorno de Movimento de Notas de Empenho
				cDebCred	:= "1" // Crédito
				If nOper == OPER_CANCELAR
					cHist	:= STR0242 //"Crédito Cancelamento de Documento Hábil"
				Else
					cHist	:= STR0243 //"Atualização de Documento Hábil"
				EndIf
			ElseIf lExcluiMov
				cTipMov	:= "3" // Exclusão de Movimento de Notas de Empenho
				cDebCred:= "2" // Debito
				cHist	:= STR0244 //"Exclusão de Documento Hábil"
			EndIf
			
			Aadd(aDados, oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp))
			Aadd(aDados, '3') // Movimentação de Nota de Empenho através do Documento Hábil
			Aadd(aDados, oMdlFV0:GetValue("FV0_CODIGO"))
			Aadd(aDados, cTipMov)
			Aadd(aDados, cDebCred) // 1-Débito; 2-Crédito;	
			Aadd(aDados, aMov)	
			Aadd(aDados, cHist)
			Aadd(aDocs, aDados)
		EndIf		
	Next nCntEmp
Next nTabela

aRet := GCPGrHistNE(aDocs,lExcluiMov,!lEdital,Nil,oModel,lMostraHlp)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761MovNE

Função de geração de dados de movimentos e cálculo de valor para atualização e geração do histórico de nota de empenho

@author Marylly Araújo Silva
@since 21/05/2015
@version 12.1.6
@param cNe Código de Identificação da Nota de Empenho
@param cSubItem Código do SubItem da Nota de Empenho
@param nValor Valor da movimentação que será atualizada na nota de empenho
/*/
//-------------------------------------------------------------------
Function F761MovNE(cNe,cSubItem,nValor)
Local aMov		:= {}
Local cNEQry	:= ""
Local cNEAls	:= GetNextAlias()
Local nValProp	:= 0
Local nVlrTotal	:= 0
Local lEdital	:= !EMPTY(Posicione('CX0',1,xFilial('CX0') + cNE,'CX0_CODEDT'))

cNEQry := "SELECT " + CRLF
If lEdital
	cNEQry += " SUM(CX1.CX1_VLRCON) VALORNE " + CRLF
Else
	cNEQry += " SUM(CX1.CX1_VLRDIS) VALORNE " + CRLF
EndIf
cNEQry += " FROM " + RetSqlName("CX1") + " CX1 " + CRLF
cNEQry += " WHERE " + RetSqlCond("CX1") + " " + CRLF
cNEQry += " AND CX1.CX1_CODNE = '" + cNe + "' " + CRLF
cNEQry += " AND CX1.CX1_SUBITE = '" + cSubItem + "' " + CRLF
If lEdital
	cNEQry += " AND CX1.CX1_VLRCON > 0 " + CRLF
Else
	cNEQry += " AND CX1.CX1_VLRDIS > 0 " + CRLF
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cNEQry),cNEAls,.T.,.T.)

While (cNEAls)->(!Eof())
	nVlrTotal := (cNEAls)->VALORNE
	(cNEAls)->(DbSkip())
EndDo

(cNEAls)->(DbCloseArea())

cNEAls	:= GetNextAlias()
cNEQry := "SELECT " + CRLF
cNEQry += " CX1.CX1_ITEM " + CRLF
If lEdital
	cNEQry += " ,CX1.CX1_VLRCON VALORNE " + CRLF
Else
	cNEQry += " ,CX1.CX1_VLRDIS VALORNE " + CRLF
EndIf
cNEQry += " FROM " + RetSqlName("CX1") + " CX1 " + CRLF
cNEQry += " WHERE " + RetSqlCond("CX1") + " " + CRLF
cNEQry += " AND CX1.CX1_CODNE = '" + cNe + "' " + CRLF
cNEQry += " AND CX1.CX1_SUBITE = '" + cSubItem + "' " + CRLF
If lEdital
	cNEQry += " AND CX1.CX1_VLRCON > 0 " + CRLF
Else
	cNEQry += " AND CX1.CX1_VLRDIS > 0 " + CRLF
EndIf

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cNEQry),cNEAls,.T.,.T.)

While (cNEAls)->(!Eof())
	nValProp := ((cNEAls)->VALORNE/nVlrTotal) * nValor
	Aadd(aMov,{(cNEAls)->CX1_ITEM,nValProp})
	(cNEAls)->(DbSkip())
EndDo

(cNEAls)->(DbCloseArea())

Return aMov


//-------------------------------------------------------------------
/*/{Protheus.doc} F761ValNE

Função de validação dos dados de movimentos de nota de empenho

@author Marylly Araújo Silva
@since 27/05/2015
@version 12.1.6
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
/*/
//-------------------------------------------------------------------
Function F761ValNE(oModel)
Local cNEQry	:= ""
Local cNEAls	:= ""
Local nVlrTotal	:= 0
Local aVlrTotal	:= {}
Local aDHTotal	:= {}
Local aRet		:= {}
Local oMdlFV5	:= oModel:GetModel("PCOEMPENHO")	// Notas de Empenhos
Local oMdlFVB	:= oModel:GetModel("DETFVB")		// Acréscimos do Documento Hábil
Local oMdlFVF	:= oModel:GetModel("DETFVF")		// Acréscimos do Documento Hábil
Local oMdlAux	:= Nil
Local aMdlInfo	:= {}
Local nTabela	:= 0
Local nCntEmp	:= 0
Local nPosNE	:= 0
Local cChvNe	:= ""
Local lEdital	:= .F.

Aadd(aMdlInfo,{"FV5","FV5_NEMPE","FV5_SUBEMP","FV5_EVALOR"})
Aadd(aMdlInfo,{"FVB","FVB_NEMPE","FVB_SUBEMP","FVB_VALOR"})
Aadd(aMdlInfo,{"FVF","FVF_NEMPE","FVF_SUBEMP","FVF_VALOR"})

For nTabela := 1 To Len(aMdlInfo)
	oMdlAux := &("oMdl" + aMdlInfo[nTabela][1])
	For nCntEmp	:= 1 To oMdlAux:Length()
		cChvNe := oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp) + oMdlAux:GetValue(aMdlInfo[nTabela][3],nCntEmp)
		
		lEdital	:= !EMPTY(Posicione('CX0',1,xFilial('CX0') + oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp),'CX0_CODEDT'))
		
		/*
		 * Acumulando os valores de notas de empenhos
		 */
		If !EMPTY(cChvNe)
			If aScan(aVlrTotal,{|aDados| aDados[1]+aDados[2] == cChvNe}) == 0 
				cNEAls	:= GetNextAlias()
				cNEQry := "SELECT " + CRLF
				cNEQry += " CX1.CX1_CODNE " + CRLF
				cNEQry += " ,CX1.CX1_SUBITE " + CRLF
				If lEdital
					cNEQry += ", SUM(CX1.CX1_VLRCON) VALORNE " + CRLF
				Else
					cNEQry += ", SUM(CX1.CX1_VLRDIS) VALORNE " + CRLF
				EndIf
				cNEQry += " FROM " + RetSqlName("CX1") + " CX1 " + CRLF
				cNEQry += " WHERE " + RetSqlCond("CX1") + " " + CRLF
				cNEQry += " AND CX1.CX1_CODNE = '" + oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp)  + "' " + CRLF
				cNEQry += " AND CX1.CX1_SUBITE = '" + oMdlAux:GetValue(aMdlInfo[nTabela][3],nCntEmp) + "' " + CRLF
				If lEdital
					cNEQry += " AND CX1.CX1_VLRCON > 0 " + CRLF
				Else
					cNEQry += " AND CX1.CX1_VLRDIS > 0 " + CRLF
				EndIf
				cNEQry += " GROUP BY CX1.CX1_CODNE, CX1.CX1_SUBITE " + CRLF
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cNEQry),cNEAls,.T.,.T.)
				nVlrTotal := 0
				While (cNEAls)->(!Eof())
					nVlrTotal += (cNEAls)->VALORNE
					(cNEAls)->(DbSkip())
				EndDo
				
				(cNEAls)->(DbCloseArea())
				Aadd(aVlrTotal,{oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp),oMdlAux:GetValue(aMdlInfo[nTabela][3],nCntEmp),nVlrTotal})
			EndIf
		
			/*
			 * Acumulando o saldo a consumir de Nota de Empenho informado no Documento Hábil
			 */
			If (nPosNE := aScan(aDHTotal,{|aDados| aDados[1]+aDados[2] == cChvNe})) == 0 
				Aadd(aDHTotal,{oMdlAux:GetValue(aMdlInfo[nTabela][2],nCntEmp),oMdlAux:GetValue(aMdlInfo[nTabela][3],nCntEmp),oMdlAux:GetValue(aMdlInfo[nTabela][4],nCntEmp)})
			Else
				aDHTotal[nPosNE][3] += oMdlAux:GetValue(aMdlInfo[nTabela][4],nCntEmp)
			EndIf
		EndIf
	Next nCntEmp
Next nTabela

/*
 * Verificação se o total da nota de empenho é suficiente para o total informado no DH
 */
For nCntEmp	:= 1 To Len(aVlrTotal)
	If (nPosNE := aScan(aDHTotal,{|aDados| aDados[1]+aDados[2] == aVlrTotal[nCntEmp][1] + aVlrTotal[nCntEmp][2]})) > 0 
		If aDHTotal[nPosNE][3] > aVlrTotal[nCntEmp][3]
			Aadd(aRet,{aVlrTotal[nCntEmp][1],aVlrTotal[nCntEmp][2],aVlrTotal[nCntEmp][3],aDHTotal[nPosNE][3]})
			Exit 
		EndIf
	EndIf
Next nCntEmp

Return aRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761VldNE
Validação do campo de Nota de Empenho e SubItem para o fornecedor do documento hábil.

@author Marylly Araújo Silva
@since 27/05/2015
@version 12.1.6
/*/
//-----------------------------------------------------------------------
Function F761VldNE(lVldSaldo)

Local lRet			:= .T.
Local oMdl			:= FWModelActive()
Local oBrowse		:= Nil
Local cNEAls		:= GetNextAlias()
Local cNEQry		:= ""
Local cFornec		:= oMdl:GetModel("CABDI"):GetValue("FV0_FORNEC")
Local cForLoj		:= oMdl:GetModel("CABDI"):GetValue("FV0_LOJA")
Local cTabGrid		:= SUBSTR(ReadVar(),4,3)
Local cCpoVld		:= AllTrim(SUBSTR(ReadVar(),4))
Local oMdlGrid		:= ""
Local cCpoFonR		:= cTabGrid + "_NEMPE"
Local cValNE		:= ""
Local lEdital		:= .F.

Default lVldSaldo := .F.

If cTabGrid == "FV2"
	oMdlGrid := oMdl:GetModel("PCOSITUACA")
ElseIf cTabGrid == "FV5"
	oMdlGrid := oMdl:GetModel("PCOEMPENHO")
Else
	oMdlGrid := oMdl:GetModel("DET"+cTabGrid)
EndIf

cValNE := Iif(!EMPTY(oMdlGrid:GetValue(cCpoFonR)),oMdlGrid:GetValue(cCpoFonR),M->&(cCpoFonR))
	
If EMPTY(cFornec+cForLoj)
	Help(" ",1,"VALIDNES",, STR0232 ,3,1) //"Informe um fornecedor/loja para o documento hábil"
	lRet := .F.
ElseIf EMPTY(cValNE) .AND. cCpoVld == cTabGrid + "_SUBEMP"
	Help(" ",1,"VALIDNES",, STR0251 ,3,1) //"Informe uma nota de empenho para validação do subitem informado."
	lRet := .F.
Else
	lEdital	:= !EMPTY(Posicione('CX0',1,xFilial('CX0') + cValNE,'CX0_CODEDT'))
	cNEQry := " SELECT " + CRLF
	If lEdital
		cNEQry += " SUM(CX1.CX1_VLRCON) VALORNE " + CRLF
	Else
		cNEQry += " SUM(CX1.CX1_VLRDIS) VALORNE " + CRLF
	EndIf
	cNEQry += " FROM " + RetSqlName("CX0") + " CX0 " + CRLF
	cNEQry += " INNER JOIN " + RetSqlName("CX1") + " CX1 " + CRLF
	cNEQry += " ON CX0.CX0_CODNE = CX1.CX1_CODNE " + CRLF
	cNEQry += " WHERE " + RetSqlCond("CX0") + CRLF
	cNEQry += " AND " + RetSqlCond("CX1") + CRLF
	cNEQry += " AND CX0.CX0_CODFOR	= '" + cFornec	+ "' " + CRLF
	cNEQry += " AND CX0.CX0_LOJFOR	= '" + cForLoj	+ "' " + CRLF
	cNEQry += " AND CX0.CX0_CODNE	= '" + cValNE	+ "' " + CRLF
	If lEdital
		cNEQry += " AND CX1.CX1_VLRCON > 0 " + CRLF
	Else
		cNEQry += " AND CX1.CX1_VLRDIS > 0 " + CRLF
	EndIf
	If cCpoVld == cTabGrid + "_SUBEMP"
		cNEQry += " AND CX1.CX1_SUBITE	= '" + oMdlGrid:GetValue(cCpoVld)	+ "' " + CRLF
	EndIf
	cNEQry += " GROUP BY CX1.CX1_FILIAL, CX0.CX0_CODNE " + CRLF
	If cCpoVld == cTabGrid + "_SUBEMP"
		cNEQry += ", CX1.CX1_SUBITE "
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cNEQry),cNEAls,.T.,.T.)

	lRet := !(cNEAls)->(Eof())
	
	If !lRet .AND. cCpoVld == cTabGrid + "_SUBEMP"
		Help(" ",1,"VALIDNES",, STR0250 ,3,1) //"Sub-Item inválido para nota de empenho informada."
	EndIf
	
	If lRet .AND. lVldSaldo .AND. (cNEAls)->VALORNE <= 0
		Help(" ",1,"VALIDNES",, STR0252 ,3,1) //"Informe uma nota de empenho válida com saldo disponível."
		lRet := .F.	
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761BxTit

Função de gravação da baixas dos títulos a pagar relacionados no documento hábil.

@author Marylly Araújo Silva
@since 10/06/2015
@version 12.1.6
@param oModel Objeto do Tipo FWFormModel com as informações necessárias preenchidas no formulário
@param nOper Operação de edição do documento hábil
/*/
//-------------------------------------------------------------------
Function F761BxTit( oModel , nOper )
Local lRet			:= .T.
Local aRet			:= {}
Local oMdlFV0		:= oModel:GetModel("CABDI")
Local oMdlFV1		:= oModel:GetModel("DOCORI")	// Situações Principal com Orçamento
Local oMdlFV2		:= oModel:GetModel("PCOSITUACA")	// Situações Principal com Orçamento
Local oMdlFV5		:= oModel:GetModel("PCOEMPENHO")	// Notas de Empenhos
Local oMdlFVB		:= oModel:GetModel("DETFVB")		// Acréscimos do Documento Hábil
Local oMdlFVD		:= oModel:GetModel("DETFVD")		// Acréscimos do Documento Hábil
Local oMdlFVF		:= oModel:GetModel("DETFVF")		// Acréscimos do Documento Hábil
Local oMdlFVP		:= oModel:GetModel("DETFVP")		// Acréscimos do Documento Hábil
Local nCntEmp		:= 0
Local nFV1Doc		:= 0
Local nFV2Situac	:= 0
Local nFV5TotEmp	:= 0
Local aFV5Perc		:= {}
Local nFV5Emp		:= 0
Local nFVBEnc		:= 0
Local nUltimo		:= 0
Local aVlrBaixa		:= {}
Local nPerc			:= 0
Local cDocHabil		:= oMdlFV0:GetValue("FV0_CODSIA")
Local cSE2Fil		:= FWxFilial("SE2")
Local cTitPai		:= ""
Local cChave		:= ""
Local aBanco		:= {}
Local nFVDDed		:= 0
Local nImp			:= 0
Local cCarteira		:= ""
Local cFVBFilial	:= FWxFilial("FVB")

DbSelectArea("SE2")
SE2->(DbSetOrder(17)) // Filial + Chave Título Pai

DbSelectArea("FVB")
FVB->(DbSetOrder(2)) // Filial + Código DH + Situação + Item

/*
 * Totalizando o valor de todas as notas de empenhos que foram informadas no documento hábil
 */
For nFV2Situac := 1 To oMdlFV2:Length()
	oMdlFV2:GoLine(nFV2Situac)
	For nFV5Emp	:= 1 To oMdlFV5:Length()
		If oMdlFV5:GetValue("FV5_EVALOR",nFV5Emp) != 0
			nFV5TotEmp += oMdlFV5:GetValue("FV5_EVALOR",nFV5Emp)
		EndIf
	Next nFV5Emp
Next nFV2Situac

/*
 * Gerando os percentuais para proporcionalização das baixas de título no documento hábil
 */
For nFV2Situac := 1 To oMdlFV2:Length()
	oMdlFV2:GoLine(nFV2Situac)
	For nFV5Emp	:= 1 To oMdlFV5:Length()
		If oMdlFV5:GetValue("FV5_EVALOR",nFV5Emp) != 0
			Aadd(aFV5Perc,oMdlFV5:GetValue("FV5_EVALOR",nFV5Emp)/nFV5TotEmp)
			Aadd(aBanco,{"999","99999",oMdlFV5:GetValue("FV5_FONREC",nFV5Emp)})
		EndIf
	Next nFV5Emp
Next nFV2Situac
nUltimo := Len(aFV5Perc)

/*
 * Calculando os valores de baixa de um título a pagar com pelos percentuais proporcionalizados
 * das notas de empenhos informadas no documento hábil
 */
For nFV1Doc := 1 To oMdlFV1:Length()
	If oMdlFV1:GetValue("FV1_VALOR",nFV1Doc) != 0
		cTitPai := cSE2Fil + oMdlFV1:GetValue("FV1_PREFIX",nFV1Doc) + oMdlFV1:GetValue("FV1_NUMERO",nFV1Doc) + oMdlFV1:GetValue("FV1_PARCEL",nFV1Doc) + oMdlFV1:GetValue("FV1_TIPO",nFV1Doc) + oMdlFV0:GetValue("FV0_FORNEC") + oMdlFV0:GetValue("FV0_LOJA")
		
		SE2->(DbSeek(cTitPai))
		While SE2->(!Eof()) .AND. AllTrim(SE2->E2_FILIAL + SE2->E2_TITPAI) == cTitPai
			For nPerc := 1 To nUltimo
				aVlrBaixa := {}
				If nUltimo == nPerc
					Aadd(aVlrBaixa,0)
				Else
					Aadd(aVlrBaixa,aFV5Perc[nPerc] * SE2->E2_SALDO)
				EndIf
				Aadd(aVlrBaixa,0)
				Aadd(aVlrBaixa,0)
				Aadd(aVlrBaixa,0)
				cChave := SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM + SE2->E2_PARCELA + SE2->E2_TIPO
				lRet := FinGrvBx(2, cDocHabil, cChave, nOper, aBanco[nPerc], aVlrBaixa, ,cTitPai)
				
				If !lRet
					Exit
					Exit
				EndIf
			Next nPerc
			SE2->(DbSkip())
		EndDo
			
		If lRet
			For nPerc := 1 To nUltimo
				aVlrBaixa := {}
				If nUltimo == nPerc
					Aadd(aVlrBaixa,0)
				Else
					Aadd(aVlrBaixa,aFV5Perc[nPerc] * oMdlFV1:GetValue("FV1_VALOR",nFV1Doc))
				EndIf
				Aadd(aVlrBaixa,0)
				Aadd(aVlrBaixa,0)
				Aadd(aVlrBaixa,0)
				
				cChave := cSE2Fil + oMdlFV1:GetValue("FV1_PREFIX",nFV1Doc) + oMdlFV1:GetValue("FV1_NUMERO",nFV1Doc) + oMdlFV1:GetValue("FV1_PARCEL",nFV1Doc) + oMdlFV1:GetValue("FV1_TIPO",nFV1Doc) + oMdlFV0:GetValue("FV0_FORNEC") + oMdlFV0:GetValue("FV0_LOJA")
				lRet := FinGrvBx(2, cDocHabil, cChave, nOper, aBanco[nPerc], aVlrBaixa)
				
				If !lRet
					Exit
					Exit
				EndIf
			Next nPerc
		EndIf
	EndIf
Next nFV1Doc

If lRet
	For nFVBEnc := 1 To oMdlFVB:Length()
		If nOper == MODEL_OPERATION_INSERT
			cCarteira := "P"
		Else
			cCarteira := "R"
		EndIf
		
		aRet := FinGrvMov(dDatabase, oMdlFVB:GetValue("FVB_DTPAGA",nFVBEnc), oMdlFVB:GetValue("FVB_VALOR",nFVBEnc), cCarteira, oMdlFVB:GetValue("FVB_FONREC",nFVBEnc), cDocHabil, nOper, oMdlFVB:GetValue("FVB_IDFK5",nFVBEnc))
		
		lRet := aRet[1]
			
		If !lRet
			Exit
			Exit
		ElseIf nOper == MODEL_OPERATION_INSERT
			oMdlFVB:SetValue("FVB_IDFK5",aRet[2])
		EndIf
	Next nFVBEnc
EndIf

lRet := FWFormCommit( oModel )

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} F761FV6W

Função de when dos campos da tabela FV6

@author Alvaro Camillo Neto
@since 10/06/2015
/*/
//-------------------------------------------------------------------
Function F761FV6W()
Local oModel		:= FWModelActive(Nil,.T.)
Local cFornec		:= oModel:GetValue("FV6_FAVORE")
Local lRet			:= Empty(cFornec)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} F761FVEW

Função de when dos campos da tabela FVE

@author Alvaro Camillo Neto
@since 10/06/2015
/*/
//-------------------------------------------------------------------
Function F761FVEW()
Local oModel		:= FWModelActive(Nil,.T.)
Local cFornec		:= oModel:GetValue("FVE_FORNEC")
Local lRet			:= Empty(cFornec)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FV6GAT

Função de gatilho dos campos da tabela FV6

@author Alvaro Camillo Neto
@since 10/06/2015
/*/
//-------------------------------------------------------------------
Function F761FV6GAT(oModel,cCampo)
Local cRet		:= oModel:GetValue(cCampo)
Local cForn		:= oModel:GetValue('FV6_FAVORE')
Local cLoja		:= oModel:GetValue('FV6_LOJA')
Local aArea		:= GetArea()
Local aAreaSA2	:= SA2->(GetArea())
Local cTipo		:= ""

SA2->(dbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA

If Empty(cForn) .Or. SA2->( !DbSeek(xFilial("SA2") + cForn + Alltrim(cLoja) ))
	oModel:LoadValue("FV6_NFAVOR","")
	If cCampo == 'FV6_FAVORE'
		oModel:LoadValue("FV6_LOJA","")
	Endif
	oModel:LoadValue("FV6_CGC","")
	oModel:LoadValue("FV6_TIPO","")
Else
	If Empty(cLoja)
		oModel:LoadValue("FV6_LOJA"		,	SA2->A2_LOJA	)
	EndIf
	oModel:LoadValue("FV6_NFAVOR"	,	LEFT(SA2->A2_NOME,TamSX3("FV6_NFAVOR")[1])	)
	oModel:LoadValue("FV6_CGC"		,	SA2->A2_CGC		)
	If SA2->A2_TIPO == 'F'
		cTipo := '1'
	ElseIf SA2->A2_TIPO == 'J'
		cTipo := '2'
	Else
		cTipo := '3'
	EndIf
		
	oModel:LoadValue("FV6_TIPO"		,	cTipo	)
EndIf


RestArea(aAreaSA2)
RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FVEGAT

Função de gatilho dos campos da tabela FVE

@author Alvaro Camillo Neto
@since 10/06/2015
/*/
//-------------------------------------------------------------------
Function F761FVEGAT(oModel)
Local cRet			:= oModel:GetValue('FVE_FORNEC')
Local aArea		:= GetArea()
Local aAreaSA2	:= SA2->(GetArea())
Local cTipo		:= ""

SA2->(dbSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA

If Empty(cRet) .Or. SA2->( !MSSeek(xFilial("SA2") + cRet ))
	oModel:LoadValue("FVE_NFORNE","")
	oModel:LoadValue("FVE_LOJA","")
	oModel:LoadValue("FVE_CGC","")
	oModel:LoadValue("FVE_TIPO","")
Else
	oModel:LoadValue("FVE_NFORNE"	,	LEFT(SA2->A2_NOME,TamSX3("FVE_NFORNE")[1])	)
	oModel:LoadValue("FVE_LOJA"		,	SA2->A2_LOJA	)
	oModel:LoadValue("FVE_CGC"		,	SA2->A2_CGC	)
	If SA2->A2_TIPO == 'F'
		cTipo := '1'
	ElseIf SA2->A2_TIPO == 'J'
		cTipo := '2'
	Else
		cTipo := '3'
	EndIf
		
	oModel:LoadValue("FVE_TIPO"		,	cTipo	)
EndIf


RestArea(aAreaSA2)
RestArea(aArea)

Return cRet


//-------------------------------------------------------------------
/*/{Protheus.doc} FINA761MAN

Função de tela do documento hábil

@author Alvaro Camillo Neto
@since 10/06/2015
/*/
//-------------------------------------------------------------------
Function FINA761MAN(nOPC)
Local aArea		:= GetArea()
Local cTitulo		:= STR0001 //"Cadastro de Documento Hábil"
Local cPrograma	:= "FINA761"
Local nOperation	:= MODEL_OPERATION_UPDATE
Local nOk			:= 0
Local lRet			:= .T.

If nOPC == 1 //Visualizar
	nOperation	:= MODEL_OPERATION_VIEW
ElseIf nOPC == 2 //Incluir
	nOperation	:= MODEL_OPERATION_INSERT
ElseIf nOPC == 3 //Alterar
	nOperation	:= MODEL_OPERATION_UPDATE
ElseIf nOPC == 4 //Exclusão
	nOperation	:= MODEL_OPERATION_DELETE
Endif


MsgRun( STR0260, STR0261, {|| FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, /*{|| .T. }*/) } )//"Montando documento hábil"##"Processamento"

If(_oFINA761A <> NIL)
	_oFINA761A:Delete()
	_oFINA761A := NIL
EndIf

If(_oFINA761B <> NIL)
	_oFINA761B:Delete()
	_oFINA761B := NIL
EndIf

If(_oFINA761C <> NIL)
	_oFINA761C:Delete()
	_oFINA761C := NIL
EndIf

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FV6PIC

Picture variável do campo de CPF/CNPJ

@author Alvaro Camillo Neto
@since 10/06/2015
/*/
//-------------------------------------------------------------------
Function F761FV6PIC()
Local oModel		:= FWModelActive(Nil,.T.)
Local cTipo		:= oModel:GetValue("FV6_TIPO")
Local cPicture	:= "@R 999.999.999-99"

If Upper(Alltrim(cTipo)) == "2" // Pessoa Juridica
	cPicture := "@R 99.999.999/9999-99 "
Endif

Return cPicture

//-------------------------------------------------------------------
/*/{Protheus.doc} F761FVEPIC

Picture variável do campo de CPF/CNPJ

@author Alvaro Camillo Neto
@since 10/06/2015
/*/
//-------------------------------------------------------------------
Function F761FVEPIC()
Local oModel		:= FWModelActive(Nil,.T.)
Local cTipo		:= oModel:GetValue("FVE_TIPO")
Local cPicture	:= "@R 999.999.999-99"

If Upper(Alltrim(cTipo)) == "2" // Pessoa Juridica
	cPicture := "@R 99.999.999/9999-99 "
Endif

Return cPicture


//-------------------------------------------------------------------
/*/{Protheus.doc} F761CtaBco

Construção de Browse de Consulta Padrão das contas bancárias dos favorecidos e Beneficiários do Documento Hábil

@return lRet - Retorna se o campo onde a consulta padrão foi chamada será preecnhido.
 
@author Marylly Araújo Silva
@since 10/05/2016
@version 12.1.11 
/*/
//-------------------------------------------------------------------
Function F761CtaBco()

Local lRet				:= .F.
Local oBrowse			:= Nil
Local cContaAls		:= GetNextAlias()
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgTela		:= Nil
Local cContaQry		:= ""
Local oPreDoc			:= FWModelActive()
Local oMdlPreDoc		:= oPreDoc:GetModel("PREDOC")
Local oMdlGrid		:= __oMdlPrinc:GetModel("DADOPAGFAV")
Local cFornec			:= oMdlGrid:GetValue("FV6_FAVORE")
Local cLoja			:= oMdlGrid:GetValue("FV6_LOJA")
Local cBcoAux 		:= ""
Local cAgenciaAux		:= ""
Local cContaAux		:= ""
/*
 * Definição do índice da Consulta Padrão
 */
Local aIndex		:= {"BANCO"}

/*
 * Definição da Descrição da Chave de Pesquisa da Consulta Padrão
 */
Local aSeek			:= {{ "Banco", {{"","C",15,0,"Banco",,}} }} //"Banco"#"Banco"

If Select(cContaAls) > 0
	(cContaAls)->(dbclosearea())
EndIf

cBcoAux 		:= oMdlPreDoc:GetValue("FV7_BCOFAV")
cAgenciaAux	:= oMdlPreDoc:GetValue("FV7_AGEFAV")
cContaAux		:= oMdlPreDoc:GetValue("FV7_CTAFAV")

oMdlPreDoc:LoadValue("FV7_BCOFAV","")
oMdlPreDoc:LoadValue("FV7_AGEFAV","")
oMdlPreDoc:LoadValue("FV7_CTAFAV","")

cRetContaF3 := ""
cContaQry := "SELECT " + CRLF
cContaQry += " SA2.A2_BANCO 	BANCO	" + CRLF
cContaQry += " ,SA2.A2_AGENCIA	AGENCIA	" + CRLF
cContaQry += " ,SA2.A2_NUMCON	CONTA	" + CRLF
cContaQry += " FROM " + RetSqlName("SA2") + " SA2 " + CRLF
cContaQry += " WHERE " + CRLF
cContaQry += " SA2.D_E_L_E_T_ = ' ' " + CRLF
cContaQry += " AND SA2.A2_BANCO <> ' ' " + CRLF
cContaQry += " AND SA2.A2_FILIAL = '"+xFilial("SA2")+"' " + CRLF
cContaQry += " AND SA2.A2_COD = '" + cFornec + "' " + CRLF
cContaQry += " AND SA2.A2_LOJA = '" + cLoja + "' " + CRLF
cContaQry += " UNION " + CRLF
cContaQry += " SELECT " + CRLF
cContaQry += " FIL.FIL_BANCO	BANCO	" + CRLF
cContaQry += " ,FIL.FIL_AGENCI	AGENCIA	" + CRLF
cContaQry += " ,FIL.FIL_CONTA	CONTA	" + CRLF
cContaQry += " FROM " + RetSqlName("FIL") + " FIL " + CRLF
cContaQry += " WHERE " + CRLF
cContaQry += " FIL.D_E_L_E_T_ = ' ' " + CRLF
cContaQry += " AND FIL.FIL_FILIAL = '"+xFilial("FIL")+"' " + CRLF
cContaQry += " AND FIL.FIL_FORNEC = '" + cFornec + "' " + CRLF
cContaQry += " AND FIL.FIL_LOJA = '" + cLoja + "' " + CRLF
cContaQry += " AND FIL.FIL_TIPO <> '1' " + CRLF

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE STR0255 FROM nSuperior, nEsquerda TO nInferior, nDireita PIXEL //"Contas Bancárias Favorecidos"

oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0255) // "Contas Bancárias Favorecidos"
oBrowse:SetAlias(cContaAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cContaQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || lRet := .T. , cRetContaF3 := (oBrowse:Alias())->BANCO, oMdlPreDoc:SetValue("FV7_AGEFAV",(oBrowse:Alias())->AGENCIA),oMdlPreDoc:SetValue("FV7_CTAFAV",(oBrowse:Alias())->CONTA), oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0046)	, {||  lRet := .T. , cRetContaF3 := (oBrowse:Alias())->BANCO, oMdlPreDoc:SetValue("FV7_AGEFAV",(oBrowse:Alias())->AGENCIA),oMdlPreDoc:SetValue("FV7_CTAFAV",(oBrowse:Alias())->CONTA), oDlgTela:End() } ,, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0058), {|| cRetContaF3 := "", lRet := .F., oDlgTela:End() } ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)

ADD COLUMN oColumn DATA { ||  BANCO		} TITLE STR0256		SIZE 15 OF oBrowse //"Banco"
ADD COLUMN oColumn DATA { ||  AGENCIA	} TITLE STR0257		SIZE 15 OF oBrowse //"Agência"
ADD COLUMN oColumn DATA { ||  CONTA 	} TITLE STR0258		SIZE 17 OF oBrowse //"Conta"
		
oBrowse:Activate()

ACTIVATE MSDIALOG oDlgTela CENTERED

If !lRet
	oMdlPreDoc:LoadValue("FV7_BCOFAV",cBcoAux)
	oMdlPreDoc:LoadValue("FV7_AGEFAV",cAgenciaAux)
	oMdlPreDoc:LoadValue("FV7_CTAFAV",cContaAux)
EndIf

If Select(cContaAls) > 0
	(cContaAls)->(dbclosearea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761RetCC

Retorna a conta bancária do favorecido do documento hábil

@return cRetContaF3 - Retorno da consulta padrão de conta bancária do favorecido
@author Marylly Araújo Silva
@since 11/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F761RetCC()

Return cRetContaF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F761CtaBen

Construção de Browse de Consulta Padrão das contas bancárias dos Beneficiários do Documento Hábil

@return lRet - Retorna se o campo onde a consulta padrão foi chamada será preecnhido.
 
@author Marylly Araújo Silva
@since 12/05/2016
@version 12.1.11
/*/
//-------------------------------------------------------------------
Function F761CtaBen()

Local lRet				:= .F.
Local oBrowse			:= Nil
Local cContaAls		:= GetNextAlias()
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgTela		:= Nil
Local cContaQry		:= ""
Local oPreDoc			:= FWModelActive()
Local oMdlPreDoc		:= oPreDoc:GetModel("PREDOC")
Local cBcoAux 		:= ""
Local cAgenciaAux 	:= ""
Local cContaAux 		:= ""

/*
 * Definição do índice da Consulta Padrão
 */
Local aIndex		:= {"BANCO"}

/*
 * Definição da Descrição da Chave de Pesquisa da Consulta Padrão
 */
Local aSeek			:= {{ "Banco", {{"","C",15,0,"Banco",,}} }} //"Banco"#"Banco"

If Select(cContaAls) > 0
	(cContaAls)->(dbclosearea())
EndIf


cBcoAux 		:= oMdlPreDoc:GetValue("FV7_BCOUG")
cAgenciaAux	:= oMdlPreDoc:GetValue("FV7_AGEUG")
cContaAux		:= oMdlPreDoc:GetValue("FV7_CTAUG")

oMdlPreDoc:LoadValue("FV7_BCOUG","")
oMdlPreDoc:LoadValue("FV7_AGEUG","")
oMdlPreDoc:LoadValue("FV7_CTAUG","")

cRetCCBenF3 := ""

cContaQry := "SELECT " + CRLF
cContaQry += " SA6.A6_COD 	BANCO	" + CRLF
cContaQry += " ,SA6.A6_AGENCIA	AGENCIA	" + CRLF
cContaQry += " ,SA6.A6_NUMCON	CONTA	" + CRLF
cContaQry += " FROM " + RetSqlName("SA6") + " SA6 " + CRLF
cContaQry += " WHERE " + CRLF
cContaQry += " " + RetSqlCond("SA6") + " " + CRLF 

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE STR0259 FROM nSuperior, nEsquerda TO nInferior, nDireita PIXEL //"Contas Bancárias Beneficiário"

oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0259) // "Contas Bancárias Unidade Gestora"
oBrowse:SetAlias(cContaAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cContaQry)
oBrowse:SetOwner(oDlgTela)
oBrowse:SetDoubleClick({ || lRet := .T. , cRetCCBenF3 := (oBrowse:Alias())->BANCO, oMdlPreDoc:SetValue("FV7_AGEUG",(oBrowse:Alias())->AGENCIA),oMdlPreDoc:SetValue("FV7_CTAUG",(oBrowse:Alias())->CONTA), oDlgTela:End()})
oBrowse:AddButton( OemTOAnsi(STR0046)	, { || lRet := .T. , cRetCCBenF3 := (oBrowse:Alias())->BANCO, oMdlPreDoc:SetValue("FV7_AGEUG",(oBrowse:Alias())->AGENCIA),oMdlPreDoc:SetValue("FV7_CTAUG",(oBrowse:Alias())->CONTA), oDlgTela:End()} ,, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0058), {|| cRetCCBenF3 := "", lRet := .F., oDlgTela:End() } ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)

ADD COLUMN oColumn DATA { ||  BANCO		} TITLE STR0256		SIZE 15 OF oBrowse //"Banco"
ADD COLUMN oColumn DATA { ||  AGENCIA	} TITLE STR0257		SIZE 15 OF oBrowse //"Agência"
ADD COLUMN oColumn DATA { ||  CONTA 	} TITLE STR0258		SIZE 17 OF oBrowse //"Conta"
		
oBrowse:Activate()

ACTIVATE MSDIALOG oDlgTela CENTERED

If !lRet
	oMdlPreDoc:LoadValue("FV7_BCOUG",cBcoAux)
	oMdlPreDoc:LoadValue("FV7_AGEUG",cAgenciaAux)
	oMdlPreDoc:LoadValue("FV7_CTAUG",cContaAux)
EndIf

If Select(cContaAls) > 0
	(cContaAls)->(dbclosearea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761RetCCB

Retorna o banco da conta bancária do beneficiário do documento hábil e preenche o campo.

@return cRetCCBenF3 - Retorno da consulta padrão de nota de empenho
@author Marylly Araújo Silva
@since 12/05/2016
@version 12.1.11
/*/
//-------------------------------------------------------------------
Function F761RetCCB()

Return cRetCCBenF3

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761VldBFI
Validação do campo conta do fornecedor

@author Alvaro Camillo Neto
@since 22/01/2015
@version 12.1.5
/*/
//-----------------------------------------------------------------------
Function F761VldBFI()
Local oMdlGrid	:= __oMdlPrinc:GetModel("DADOPAGFAV")
Local oPreDoc		:= FWModelActive()
Local oMdlPreDoc	:= oPreDoc:GetModel("PREDOC")
Local lRet			:= .T.
Local cContaQry	:= ""
Local cSA6Als		:= GetNextAlias()
Local cFornec		:= oMdlGrid:GetValue("FV6_FAVORE")
Local cLoja		:= oMdlGrid:GetValue("FV6_LOJA")
Local cBanco		:= ""
Local cAgencia	:= ""
Local cConta		:= ""

If oMdlPreDoc != Nil
	cBanco		:= oMdlPreDoc:GetValue("FV7_BCOFAV")
	cAgencia	:= oMdlPreDoc:GetValue("FV7_AGEFAV")
	cConta		:= oMdlPreDoc:GetValue("FV7_CTAFAV")
	If !Empty(cFornec) .And. !Empty(cLoja)
		cContaQry := "SELECT " + CRLF
		cContaQry += " SA2.A2_BANCO   	BANCO	" + CRLF
		cContaQry += " ,SA2.A2_AGENCIA	AGENCIA	" + CRLF
		cContaQry += " ,SA2.A2_NUMCON	CONTA	" + CRLF
		cContaQry += " FROM " + RetSqlName("SA2") + " SA2 " + CRLF
		cContaQry += " WHERE " + CRLF
		cContaQry += " SA2.D_E_L_E_T_ 		= ' ' " + CRLF
		cContaQry += " AND SA2.A2_FILIAL 	= '"+xFilial("SA2")+"' " + CRLF
		cContaQry += " AND SA2.A2_COD 		= '" + cFornec + "' " + CRLF
		cContaQry += " AND SA2.A2_LOJA		= '" + cLoja + "' " + CRLF
		If !Empty(cBanco)
			cContaQry += " AND SA2.A2_BANCO 	= '" + cBanco + "' " + CRLF
		Endif
		If !Empty(cAgencia)
			cContaQry += " AND SA2.A2_AGENCIA 	= '" + cAgencia + "' " + CRLF
		EndIf
		If !Empty(cConta)
			cContaQry += " AND SA2.A2_NUMCON 	= '" + cConta + "' " + CRLF
		Endif
		cContaQry += " UNION " + CRLF
		cContaQry += " SELECT " + CRLF
		cContaQry += " FIL.FIL_BANCO	BANCO	" + CRLF
		cContaQry += " ,FIL.FIL_AGENCI	AGENCIA	" + CRLF
		cContaQry += " ,FIL.FIL_CONTA	CONTA	" + CRLF
		cContaQry += " FROM " + RetSqlName("FIL") + " FIL " + CRLF
		cContaQry += " WHERE " + CRLF
		cContaQry += " FIL.D_E_L_E_T_ = ' ' " + CRLF
		cContaQry += " AND FIL.FIL_FILIAL 	= '"+xFilial("FIL")+"' " + CRLF
		cContaQry += " AND FIL.FIL_FORNEC	= '" + cFornec + "' " + CRLF
		cContaQry += " AND FIL.FIL_LOJA  	= '" + cLoja + "' " + CRLF
		If !Empty(cBanco)
			cContaQry += " AND FIL.FIL_BANCO 	= '" + cBanco + "' " + CRLF
		Endif
		If !Empty(cAgencia)
			cContaQry += " AND FIL.FIL_AGENCI 	= '" + cAgencia + "' " + CRLF
		EndIf
		If !Empty(cConta)
			cContaQry += " AND FIL.FIL_CONTA 	= '" + cConta + "' " + CRLF
		Endif
	
		cContaQry := ChangeQuery(cContaQry)

		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cContaQry),cSA6Als,.T.,.T.)

		lRet := !(cSA6Als)->(Eof())
	EndIf
EndIf

If !lRet
	Help(" ",1,"RECNO")
EndIf

If Select(cSA6Als) > 0
	(cSA6Als)->(dbclosearea())
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761VlBGI
Validação do campo conta da AG

@author Alvaro Camillo Neto
@since 22/01/2015
@version 12.1.5
/*/
//-----------------------------------------------------------------------
Function F761VlBGI()
Local oPreDoc		:= FWModelActive()
Local oMdlPreDoc	:= oPreDoc:GetModel("PREDOC")
Local lRet			:= .T.
Local cContaQry	:= ""
Local cSA6Als		:= GetNextAlias()
Local cBanco		:= ""
Local cAgencia	:= ""
Local cConta		:= ""

If oMdlPreDoc != Nil
	cBanco		:= oMdlPreDoc:GetValue("FV7_BCOUG")
	cAgencia	:= oMdlPreDoc:GetValue("FV7_AGEUG")
	cConta		:= oMdlPreDoc:GetValue("FV7_CTAUG")
	cContaQry := "SELECT " + CRLF
	cContaQry += " SA6.A6_COD " + CRLF
	cContaQry += " FROM " + RetSqlName("SA6") + " SA6 " + CRLF
	cContaQry += " WHERE " + CRLF
	cContaQry += " " + RetSqlCond("SA6") + " " + CRLF

	If !Empty(cBanco)
		cContaQry += " AND SA6.A6_COD     	= '" + cBanco + "' " + CRLF
	Endif
	If !Empty(cAgencia)
		cContaQry += " AND SA6.A6_AGENCIA 	= '" + cAgencia + "' " + CRLF
	EndIf
	If !Empty(cConta)
		cContaQry += " AND SA6.A6_NUMCON  	= '" + cConta + "' " + CRLF
	Endif

	cContaQry := ChangeQuery(cContaQry)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cContaQry),cSA6Als,.T.,.T.)

	lRet := !(cSA6Als)->(Eof())
EndIf

If !lRet
	Help(" ",1,"RECNO")
EndIf

If Select(cSA6Als) > 0
	(cSA6Als)->(dbclosearea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761F3NEmp

Construção de Browse de Consulta Padrão das contas bancárias dos favorecidos e Beneficiários do Documento Hábil

@return lRet - Retorna se o campo onde a consulta padrão foi chamada será preecnhido.
 
@author Marylly Araújo Silva
@since 10/05/2016
@version 12.1.11 
/*/
//-------------------------------------------------------------------
Function F761F3NEmp()

Local lRet				:= .F.
Local oBrowse			:= Nil
Local cContaAls		:= GetNextAlias()
Local nSuperior		:= 0
Local nEsquerda		:= 0
Local nInferior		:= 0
Local nDireita		:= 0
Local oDlgTela		:= Nil
Local cContaQry		:= ""
Local cCampo			:= ReadVar()
Local oMdlGrid		:= FWModelActive(Nil,.T.)
Local oModel			:= oMdlGrid:GetModel()
Local cModel			:= oMdlGrid:GetID()
Local oMdlCab			:= oModel:GetModel("CABDI")
Local cNotaAux		:= ""
Local cSubItem		:= ""
Local cBanco			:= ""
Local cNomeFor		:= ""
Local cCpoNT			:= ""
Local cCpoItem		:= ""
Local cCpoFor			:= ""
Local cCpoNome		:= ""
Local cCpoItNe		:= ""

Local cFornec			:= oMdlCab:GetValue("FV0_FORNEC")
Local cLoja			:= oMdlCab:GetValue("FV0_LOJA")

Local bConfirm		:= {|| }
/*
 * Definição do índice da Consulta Padrão
 */
Local aIndex		:= {"CX0_CODNE"}

/*
 * Definição da Descrição da Chave de Pesquisa da Consulta Padrão
 */
Local aSeek			:= {{ "Nota", {{"","C",12,0,"Nota",,}} }} //"Banco"#"Banco"

If "FV5" $ cCampo
	cCpoNT			:= "FV5_NEMPE"
	cCpoItem		:= "FV5_SUBEMP"
	cCpoFor		:= "FV5_FONREC"
	cCpoNome		:= "FV5_NFONRE"
	cCpoItNe		:= 'FV5_ITEMP' 
ElseIf  "FVF" $ cCampo
	cCpoNT			:= "FVF_NEMPE"
	cCpoItem		:= "FVF_SUBEMP"
	cCpoFor		:= "FVF_FONREC"
	cCpoNome		:= "FVF_NFONRE"
ElseIf  "FVM" $ cCampo
	cCpoNT			:= "FVM_NEMPE"
	cCpoItem		:= "FVM_SUBEMP"
	cCpoFor		:= "FVM_FONREC"
	cCpoNome		:= "FVM_NFONRE"
ElseIf  "FVB" $ cCampo
	cCpoNT			:= "FVB_NEMPE"
	cCpoItem		:= "FVB_SUBEMP"
	cCpoFor		:= "FVB_FONREC"
	cCpoNome		:= "FVB_NFONRE"
EndIf

cNotaAux		:= oMdlGrid:GetValue(cCpoNT)
cSubItem		:= oMdlGrid:GetValue(cCpoItem)
cBanco			:= oMdlGrid:GetValue(cCpoFor)
cNomeFor		:= oMdlGrid:GetValue(cCpoNome)
bConfirm		:= {|| lRet := .T.,F761EmpF3(@cRetNotaF3,oBrowse,oMdlGrid,oDlgTela,cCpoItem,cCpoFor,cCpoItNe,cModel) }

If Select(cContaAls) > 0
	(cContaAls)->(dbclosearea())
EndIf

oMdlGrid:LoadValue(cCpoNT	, "")
oMdlGrid:LoadValue(cCpoItem, "")
oMdlGrid:LoadValue(cCpoFor	, "")
oMdlGrid:LoadValue(cCpoNome	, "")

cRetNotaF3 := ""

cContaQry += " SELECT DISTINCT  " + CRLF
cContaQry += " 	CX0_CODNE		, " + CRLF
cContaQry += " 	CX0_UGEMIT		, " + CRLF
cContaQry += " 	CPA_DESORG		, " + CRLF
cContaQry += " 	CX0_UGRESP		, " + CRLF
cContaQry += " 	FVO_DESCRI		, " + CRLF
cContaQry += " 	CX1_SUBITE		, " + CRLF
cContaQry += " 	CX0_FONREC		, " + CRLF
cContaQry += " 	A6_NOME		," + CRLF
cContaQry += " 	CX1_ITEM		," + CRLF
cContaQry += " 	CX1_VLRDIS" + CRLF
  
	
cContaQry += " FROM "+RetSQLName("CX0")+" CX0  " + CRLF

cContaQry += " JOIN "+RetSQLName("FVO")+" FVO ON " + CRLF
cContaQry += " FVO_FILIAL = '"+xFilial("FVO")+"' AND " + CRLF
cContaQry += " FVO_CODIGO =  CX0_UGRESP AND " + CRLF
cContaQry += " FVO.D_E_L_E_T_ = ' ' " + CRLF

cContaQry += " JOIN "+RetSQLName("CPA")+" CPA ON " + CRLF
cContaQry += " CPA_FILIAL = '"+xFilial("CPA")+"' AND " + CRLF
cContaQry += " CPA_CODORG =  CX0_UGEMIT AND " + CRLF
cContaQry += " CPA.D_E_L_E_T_ = ' ' " + CRLF

cContaQry += " JOIN "+RetSQLName("CX1")+" CX1 ON " + CRLF

cContaQry += " CX1_FILIAL = CX0_FILIAL AND " + CRLF
cContaQry += " CX1_CODNE = CX0_CODNE  AND " + CRLF
cContaQry += " CX1.D_E_L_E_T_ = ' ' " + CRLF

cContaQry += " JOIN "+RetSQLName("SA6")+" SA6 ON " + CRLF
cContaQry += " A6_FILIAL = '"+xFilial("SA6")+"' AND " + CRLF
cContaQry += " A6_NUMCON = CX0_FONREC AND " + CRLF
cContaQry += " SA6.D_E_L_E_T_ = ' ' " + CRLF

cContaQry += " WHERE " + CRLF

cContaQry += " CX0_FILIAL = '"+xFilial("CX0")+"' AND " + CRLF
cContaQry += " CX0_CODFOR = '"+cFornec+"' AND " + CRLF
cContaQry += " CX0_LOJFOR = '"+cLoja+"' AND " + CRLF
cContaQry += " CX0.D_E_L_E_T_ = ' ' " + CRLF

nSuperior := 0
nEsquerda := 0
nInferior := 460
nDireita  := 800

DEFINE MSDIALOG oDlgTela TITLE STR0263 FROM nSuperior, nEsquerda TO nInferior, nDireita PIXEL //"Notas de Empenho"

oBrowse := FWFormBrowse():New()
oBrowse:SetDescription(STR0263) // "Notas de Empenho"
oBrowse:SetAlias(cContaAls)
oBrowse:SetDataQuery()
oBrowse:SetQuery(cContaQry)
oBrowse:SetOwner(oDlgTela)

oBrowse:SetDoubleClick(bConfirm)

oBrowse:AddButton( OemTOAnsi(STR0046)	, bConfirm ,, 2 ) //"Confirmar"
oBrowse:AddButton( OemTOAnsi(STR0058), {|| cRetNotaF3 := "", lRet := .F., oDlgTela:End() } ,, 2 ) //"Cancelar"
oBrowse:DisableDetails()
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetSeek({||.T.},aSeek)

ADD COLUMN oColumn DATA { ||  CX0_CODNE	} 		TITLE F761X3Ti("CX0_CODNE")			SIZE TamSX3("CX0_CODNE")[1] 	OF oBrowse 
ADD COLUMN oColumn DATA { ||  CX1_SUBITE 	} 		TITLE F761X3Ti("CX1_SUBITE")		SIZE TamSX3("CX1_SUBITE")[1] 	OF oBrowse
ADD COLUMN oColumn DATA { ||  CX1_ITEM 	} 		TITLE F761X3Ti("CX1_ITEM")			SIZE TamSX3("CX1_ITEM")[1] 		OF oBrowse 
ADD COLUMN oColumn DATA { ||  CX0_UGEMIT	} 		TITLE F761X3Ti("CX0_UGEMIT")		SIZE TamSX3("CX0_UGEMIT")[1] 	OF oBrowse 
ADD COLUMN oColumn DATA { ||  CPA_DESORG 	} 		TITLE F761X3Ti("CPA_DESORG")		SIZE 20 							OF oBrowse 
ADD COLUMN oColumn DATA { ||  CX0_UGRESP 	} 		TITLE F761X3Ti("CX0_UGRESP")		SIZE TamSX3("CX0_UGRESP")[1] 	OF oBrowse 
ADD COLUMN oColumn DATA { ||  FVO_DESCRI 	} 		TITLE F761X3Ti("FVO_DESCRI")		SIZE 20							OF oBrowse 
ADD COLUMN oColumn DATA { ||  CX0_FONREC 	} 		TITLE F761X3Ti("CX0_FONREC")		SIZE TamSX3("CX0_FONREC")[1] 	OF oBrowse 
ADD COLUMN oColumn DATA { ||  A6_NOME 		} 		TITLE F761X3Ti("A6_NOME")			SIZE 20							OF oBrowse 
ADD COLUMN oColumn DATA { ||  TRANSFORM(CX1_VLRDIS ,PesqPict("CX1","CX1_VLRDIS") )}	TITLE F761X3Ti("CX1_VLRDIS") SIZE TamSX3("CX1_VLRDIS")[1] OF oBrowse 
		
oBrowse:Activate()

ACTIVATE MSDIALOG oDlgTela CENTERED

If !lRet
	oMdlGrid:LoadValue(cCpoNT	, cNotaAux)
	oMdlGrid:LoadValue(cCpoItem	, cSubItem)
	oMdlGrid:LoadValue(cCpoFor	, cBanco )
	oMdlGrid:LoadValue(cCpoNome	, cNomeFor)
EndIf

If Select(cContaAls) > 0
	(cContaAls)->(dbclosearea())
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F761F3NERe

Retorna a nota de empenho

@return cRetNotaF3 - Retorno da consulta padrão de conta bancária do favorecido
@author Marylly Araújo Silva
@since 11/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Function F761F3NERe()

Return cRetNotaF3

//-------------------------------------------------------------------
/*/{Protheus.doc} F761X3Ti

Retorna o titulo do campo

@author Alvaro Camillo Neto
@since 11/05/2015
@version 12.1.6
/*/
//-------------------------------------------------------------------
Static Function F761X3Ti(cCampo)	
Local cRet := ""
Local aArea:= GetArea()

dbSelectArea('SX3')
SX3->(dbSetOrder(2)) // X3_CAMPO

If SX3->(MSSeek( cCampo ))
	cRet := SX3->(X3Titulo())
EndIf

RestArea(aArea)
Return cRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761VlBGI
Validação do campo conta da AG

@author Alvaro Camillo Neto
@since 22/01/2015
@version 12.1.5
/*/
//-----------------------------------------------------------------------
Function F761VlNEmp()
Local lRet				:= .T.
Local cContaQry		:= ""
Local cSA6Als			:= GetNextAlias()
Local oModel			:= FWModelActive()
Local oMdlGrid		:= oModel:GetModel("PCOEMPENHO")
Local cNotaAux		:= oMdlGrid:GetValue("FV5_NEMPE")
Local cSubItem		:= oMdlGrid:GetValue("FV5_SUBEMP")

cContaQry := "SELECT " + CRLF
cContaQry += " CX1.CX1_CODNE " + CRLF
cContaQry += " FROM " + RetSqlName("CX1") + " CX1 " + CRLF
cContaQry += " WHERE " + CRLF
cContaQry += " " + RetSqlCond("CX1") + " " + CRLF

If !Empty(cNotaAux)
	cContaQry += " AND CX1.CX1_CODNE = '" + cNotaAux + "' " + CRLF
Endif
If !Empty(cSubItem)
	cContaQry += " AND CX1.CX1_SUBITE 	= '" + cSubItem + "' " + CRLF
EndIf

cContaQry := ChangeQuery(cContaQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cContaQry),cSA6Als,.T.,.T.)

lRet := !(cSA6Als)->(Eof())

If !lRet
	Help(" ",1,"RECNO")
EndIf

If Select(cSA6Als) > 0
	(cSA6Als)->(dbclosearea())
EndIf

Return lRet

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761EmpF3
Validação do campo conta da AG

@author Alvaro Camillo Neto
@since 22/01/2015
@version 12.1.5
/*/
//-----------------------------------------------------------------------
Function F761EmpF3(cRetNotaF3,oBrowse,oMdlGrid,oDlgTela,cCpoItem,cCpoFor,cCpoItNe,cModel)

Local oView := FWViewActive()

cRetNotaF3 := (oBrowse:Alias())->CX0_CODNE
oMdlGrid:LoadValue(cCpoItem,(oBrowse:Alias())->CX1_SUBITE) 
oMdlGrid:SetValue(cCpoFor,(oBrowse:Alias())->CX0_FONREC)
If !Empty(cCpoItNe)
	oMdlGrid:LoadValue(cCpoItNe,(oBrowse:Alias())->CX1_ITEM)
EndIF
oDlgTela:End()

oView:Refresh(cModel)

Return

//-----------------------------------------------------------------------
/*/{Protheus.doc} F761EmpMk
Tela de Marcação da nota de Empenho

@author Alvaro Camillo Neto
@since 22/01/2015
@version 12.1.5
/*/
//-----------------------------------------------------------------------
Function F761EmpMk(oView,oViewPai)
Local cNumLote	:= "" 
Local cIdCV8		:= ""
Local cQry			:= ""
Local aSize		:= {} 
Local aColumns	:= {}
Local nRet			:= 0
Local aStru		:= {}
Local oDlg			:= Nil
Local nX			:= 0
Local cChave		:= ""
Local oMrkBrowse	:= Nil
Local oModel		:= oViewPai:GetModel()
Local oFV1			:= oModel:GetModel('DOCORI')
Local oFV5			:= oModel:GetModel("PCOEMPENHO")
Local oFV2			:= oModel:GetModel("PCOSITUACA")
Local cItem		:= oFV2:GetValue("FV2_ITEM")
Local cAux			:= ""
Local nValor		:= 0
Local cSubModel	:= 'PCOSITUACA'
Local cCampo		:= 'FV2_ITEM'
Local cMarca		:= 'C '
Local bOk 			:= {||((nRet := F761VEmpMK(), oMrkBrowse:Deactivate(), oDlg:End()))}

Aadd(aStru,{"MRK_ITEM","C",4,0}) 
Aadd(aStru,{"E2_OK","C",TAMSX3("E2_OK")[1],0})
Aadd(aStru,{"CX0_FILIAL","C",TAMSX3("CX0_FILIAL")[1],0})
Aadd(aStru,{"CX0_CODNE","C",TAMSX3("CX0_CODNE")[1],0})
Aadd(aStru,{"CX1_SUBITE","C",TAMSX3("CX1_SUBITE")[1],0})
Aadd(aStru,{"CX1_ITEM","C",TAMSX3("CX1_ITEM")[1],0})
Aadd(aStru,{"CX1_CODPRO","C",TAMSX3("CX1_CODPRO")[1],0})
Aadd(aStru,{"CX0_UGEMIT","C",TAMSX3("CX0_UGEMIT")[1],0})
Aadd(aStru,{"CPA_DESORG","C",TAMSX3("CPA_DESORG")[1],0})
Aadd(aStru,{"CX0_UGRESP","C",TAMSX3("CX0_UGRESP")[1],0})
Aadd(aStru,{"FVO_DESCRI","C",TAMSX3("FVO_DESCRI")[1],0})
Aadd(aStru,{"CX0_FONREC","C",TAMSX3("CX0_FONREC")[1],0})
Aadd(aStru,{"A6_NOME","C",TAMSX3("A6_NOME")[1],0})
Aadd(aStru,{"CX1_VLRDIS","N",TAMSX3("CX1_VLRDIS")[1],TAMSX3("CX1_VLRDIS")[2]})
Aadd(aStru,{"D1_TOTAL","N",TAMSX3("D1_TOTAL")[1],TAMSX3("D1_TOTAL")[2]})

If Empty(__cArqEmp)
	FCriaTbEmp(cMarca,aStru,cItem,oModel)
EndIf

//Desliga campo obrigatório de valor
__lVlEmp := .F.


For nX := 1 To Len(aStru)
	If !(aStru[nX][1] $ 'MRK_ITEM/E2_OK')
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||" + aStru[nX][01] + "}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][01]))
		aColumns[Len(aColumns)]:SetSize(aStru[nX][03])
		aColumns[Len(aColumns)]:SetDecimal(aStru[nX][04])
		If aStru[nX][01] == "CX1_VLRDIS"
			aColumns[Len(aColumns)]:SetPicture(PesqPict("CX1","CX1_VLRDIS"))
		ElseIf aStru[nX][01] == "D1_TOTAL"
			aColumns[Len(aColumns)]:SetPicture(PesqPict("SD1","D1_TOTAL"))
		Endif
	EndIf
Next nX
	
	//Faz o calculo automatico de dimensoes de objetos
aSize := MSADVSIZE()
	
DEFINE MSDIALOG oDlg TITLE STR0048 From aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL
oDlg:lMaximized := .T.
oMrkBrowse := FWMarkBrowse():New()
oMrkBrowse:SetFieldMark("E2_OK")
oMrkBrowse:SetMark( cMarca, __cArqEmp, "E2_OK" )
oMrkBrowse:SetOwner(oDlg)
oMrkBrowse:SetAlias(__cArqEmp)
oMrkBrowse:SetValid({|| ValidMrk(oMrkBrowse,oModel,cSubModel,cCampo,__cArqEmp) })
oMrkBrowse:AddButton( OemTOAnsi(STR0046), bOk,, 2 ) //"Confirmar"
oMrkBrowse:bMark := {|| F761MrkItem(oMrkBrowse,oModel,cSubModel,cCampo,__cArqEmp) }					
oMrkBrowse:bAllMark	:= {|| InvertMrk(oMrkBrowse,__cArqEmp,"E2_OK"),F761MrkAll(oMrkBrowse,oModel,cSubModel,cCampo,__cArqEmp)}
oMrkBrowse:SetDescription(STR0264) // "Seleção de Notas de Empenho."
oMrkBrowse:SetColumns(aColumns)
oMrkBrowse:SetMenuDef("")
oMrkBrowse:Activate()
	
ACTIVATE MSDIALOG oDlg CENTERED

If nRet == 1 //Confirmou
	
	If oFV5:Length() > 1
		For nX := 1 to oFV5:Length()
			oFV5:GoLine(nX)
			oFV5:DeleteLine()
		Next nX
	EndIf

	dbSelectArea(__cArqEmp)
	(__cArqEmp)->(DbGoTop())
	
	//oFV5:GoLine(1)
	nX	:= 1
	nTamItem := TamSX3('FV5_ITEM')[1]
	cMark := oMrkBrowse:Mark()
	While !(__cArqEmp)->(Eof())
		
		cEmpenho	:= (__cArqEmp)->CX0_CODNE
		cSubIte	:= (__cArqEmp)->CX1_SUBITE
		cFornec	:= (__cArqEmp)->CX0_FONREC
		cItemPE	:= (__cArqEmp)->CX1_ITEM
		
		If (__cArqEmp)->E2_OK == cMark
		
			If (__cArqEmp)->MRK_ITEM == cItem
			
				If oFV5:GetLine() > 1 .or. nX > 1
					oFV5:Addline()
				EndIf
								
				oFV5:LoadValue('FV5_ITEM', STRZERO(nX, nTamItem ) )
				oFV5:LoadValue('FV5_NEMPE', (__cArqEmp)->CX0_CODNE )
				oFV5:LoadValue('FV5_SUBEMP', (__cArqEmp)->CX1_SUBITE )
				oFV5:LoadValue('FV5_FONREC', (__cArqEmp)->CX0_FONREC )
				oFV5:LoadValue('FV5_NFONRE', (__cArqEmp)->A6_NOME )
				oFV5:LoadValue('FV5_EVALOR', 0 )
				oFV5:LoadValue('FV5_ITEMP',  (__cArqEmp)->CX1_ITEM )
					
				nX++
			Endif
		EndIf
		(__cArqEmp)->(DbSkip())
	EndDo
	
EndIf

oFV5:GoLine(1)
oView:Refresh('SITUACEMPE')

__lVlEmp := .T.

Return

/*/{Protheus.doc} FCriaTbEmp
Cria arquivo de trabalho para titulos com impostos relacionados.
@author william.gundim
@since 14/01/2015
/*/
Static Function FCriaTbEmp(cMark,aStru,cItem,oModel)

Local nX		:= 0
Local aChave 	:= {"CX0_FILIAL","CX0_CODNE","CX1_ITEM","CX1_CODPRO"}
Local oMdlCab	:= oModel:GetModel("CABDI")
Local oAux		:= oModel:GetModel('DOCORI')

Local cSE2Als	:= ""
Local cSE2Qry	:= ""
Local cFilSE2	:= FWxFilial("SE2")

If !Empty(__cArqEmp)
	( __cArqEmp )->( dbCloseArea() )
	FErase( ( __cArqEmp ) + GetDBExtension() )
	__cArqEmp := ""
EndIf

If(_oFINA761C <> NIL)
	_oFINA761C:Delete()
	_oFINA761C := NIL
EndIf

__cArqEmp := GetNextAlias()

//Criando o objeto FwTemporaryTable
_oFINA761C := FwTemporaryTable():New(__cArqEmp)

//Setando a estrutura da tabela temporaria
_oFINA761C:SetFields(aStru)

//Cria os indices temporarios da tabela temporaria
_oFINA761C:AddIndex("1", aChave )

_oFINA761C:Create()
			
//Alimenta arquivo temporario
For nX := 1 To oAux:Length()

	cSE2Als := GetNextAlias()
	cSE2Qry := " SELECT DISTINCT " + CRLF
	cSE2Qry += " CX0_FILIAL		,  " + CRLF
	cSE2Qry += " CX0_CODNE		,  " + CRLF
	cSE2Qry += " CX0_UGEMIT		,  " + CRLF
	cSE2Qry += " CPA_DESORG		,  " + CRLF
	cSE2Qry += " CX0_UGRESP		,  " + CRLF
	cSE2Qry += " FVO_DESCRI		,  " + CRLF
	cSE2Qry += " CX1_SUBITE		, " + CRLF
	cSE2Qry += " CX1_ITEM		, " + CRLF
	cSE2Qry += " CX1_CODPRO		,  " + CRLF
	cSE2Qry += " CX0_FONREC		,  " + CRLF
	cSE2Qry += " A6_NOME			, " + CRLF
	cSE2Qry += " D1_TOTAL		, " + CRLF
	cSE2Qry += " CX1_VLRDIS " + CRLF
	cSE2Qry += "  FROM "+RetSqlName("SE2") +" SE2  " + CRLF
	cSE2Qry += "  INNER JOIN "+RetSqlName("SF1") +" SF1 ON  " + CRLF
	cSE2Qry += "  	E2_FILIAL  = F1_FILIAL AND  " + CRLF
	cSE2Qry += "  	E2_FORNECE = F1_FORNECE AND  " + CRLF
	cSE2Qry += "  	E2_LOJA    = F1_LOJA	AND  " + CRLF
	cSE2Qry += "  	E2_PREFIXO = F1_PREFIXO AND  " + CRLF
	cSE2Qry += "  	E2_NUM     = F1_DOC		AND  " + CRLF
	cSE2Qry += "  	SF1.D_E_L_E_T_ = ' '  " + CRLF
	cSE2Qry += "   INNER JOIN "+RetSqlName("SD1") +" SD1 ON  " + CRLF
	cSE2Qry += "  	F1_FILIAL = D1_FILIAL AND  " + CRLF
	cSE2Qry += "  	F1_DOC = D1_DOC AND  " + CRLF
	cSE2Qry += "  	F1_SERIE = D1_SERIE AND  " + CRLF
	cSE2Qry += "  	F1_FORNECE = D1_FORNECE AND  " + CRLF
	cSE2Qry += "  	F1_LOJA = D1_LOJA AND  " + CRLF
	cSE2Qry += "  	SD1.D_E_L_E_T_ = ' '  " + CRLF
	cSE2Qry += "   INNER JOIN "+RetSqlName("CX0") +" CX0 ON  " + CRLF
	cSE2Qry += "  	D1_FILIAL = CX0_FILIAL AND  " + CRLF
	cSE2Qry += "  	D1_CODNE  = CX0_CODNE AND  " + CRLF
	cSE2Qry += "  	CX0.D_E_L_E_T_ = ' '  " + CRLF
	cSE2Qry += "   INNER JOIN "+RetSqlName("CPA") +" CPA ON  " + CRLF
	cSE2Qry += "  	CPA_FILIAL = '"+xFilial("CPA")+"' AND  " + CRLF
	cSE2Qry += "  	CPA_CODORG  = CX0_UGEMIT AND  " + CRLF
	cSE2Qry += "  	CPA.D_E_L_E_T_ = ' ' " + CRLF
	cSE2Qry += "    INNER JOIN "+RetSqlName("CX1") +" CX1 ON  " + CRLF
	cSE2Qry += "    CX1_FILIAL = CX0_FILIAL AND " + CRLF
	cSE2Qry += "    CX1_CODNE = CX0_CODNE  AND " + CRLF
	cSE2Qry += "    CX1.D_E_L_E_T_ = ' ' " + CRLF
	cSE2Qry += "    INNER JOIN "+RetSqlName("FVO") +" FVO ON " + CRLF
	cSE2Qry += "    FVO_FILIAL = '"+xFilial("FVO")+"' AND " + CRLF
	cSE2Qry += "    FVO_CODIGO =  CX0_UGRESP AND " + CRLF
	cSE2Qry += "    FVO.D_E_L_E_T_ = ' ' " + CRLF
	cSE2Qry += "    INNER JOIN "+RetSqlName("SA6") +" SA6 ON " + CRLF
	cSE2Qry += "    A6_FILIAL = '"+xFilial("SA6")+"' AND " + CRLF
	cSE2Qry += "    A6_NUMCON = CX0_FONREC AND  " + CRLF
	cSE2Qry += "    SA6.D_E_L_E_T_ = ' ' " + CRLF
	cSE2Qry += "  WHERE " + CRLF
	cSE2Qry += " E2_FILIAL  = '"+xFilial("SE2")+"' AND " + CRLF
	cSE2Qry += " E2_PREFIXO = '"+oAux:GetValue('FV1_PREFIX', nX)+"' AND " + CRLF
	cSE2Qry += " E2_NUM     = '"+oAux:GetValue('FV1_NUMERO', nX)+"' AND " + CRLF
	cSE2Qry += " E2_PARCELA = '"+oAux:GetValue('FV1_PARCEL', nX)+"' AND " + CRLF
	cSE2Qry += " E2_TIPO    = '"+oAux:GetValue('FV1_TIPO'  , nX)+"' AND " + CRLF
	cSE2Qry += " E2_FORNECE = '"+oMdlCab:GetValue('FV0_FORNEC')+"' AND " + CRLF
	cSE2Qry += " E2_LOJA    = '"+oMdlCab:GetValue('FV0_LOJA'  )+"' AND " + CRLF
	cSE2Qry += " SE2.D_E_L_E_T_ = ' ' " + CRLF
	cSE2Qry := ChangeQuery(cSE2Qry)
	
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSE2Qry),cSE2Als,.T.,.T.)
	//"CX0_FILIAL+CX0_CODNE+CX1_ITEM+CX1_CODPRO"

	TcSetField(cSE2Als ,'D1_TOTAL',"N",TamSX3('D1_TOTAL')[1],TamSX3('D1_TOTAL')[2])
	TcSetField(cSE2Als ,'CX1_VLRDIS',"N",TamSX3('CX1_VLRDIS')[1],TamSX3('CX1_VLRDIS')[2])
	
	While (cSE2Als)->(!Eof())
		If (__cArqEmp)->(!dbSeek((cSE2Als)->(CX0_FILIAL+CX0_CODNE+CX1_ITEM+CX1_CODPRO) ))
			Reclock( (__cArqEmp) , .T.)
			(__cArqEmp)->E2_OK		:= cMark
			(__cArqEmp)->MRK_ITEM	:= cItem
			(__cArqEmp)->CX0_FILIAL	:= (cSE2Als)->CX0_FILIAL
			(__cArqEmp)->CX0_CODNE	:= (cSE2Als)->CX0_CODNE
			(__cArqEmp)->CX0_UGEMIT	:= (cSE2Als)->CX0_UGEMIT
			(__cArqEmp)->CPA_DESORG	:= (cSE2Als)->CPA_DESORG
			(__cArqEmp)->CX0_UGRESP	:= (cSE2Als)->CX0_UGRESP
			(__cArqEmp)->FVO_DESCRI	:= (cSE2Als)->FVO_DESCRI
			(__cArqEmp)->CX1_SUBITE	:= (cSE2Als)->CX1_SUBITE
			(__cArqEmp)->CX1_ITEM	:= (cSE2Als)->CX1_ITEM
			(__cArqEmp)->CX1_CODPRO	:= (cSE2Als)->CX1_CODPRO
			(__cArqEmp)->CX0_FONREC	:= (cSE2Als)->CX0_FONREC
			(__cArqEmp)->A6_NOME		:= (cSE2Als)->A6_NOME
			(__cArqEmp)->CX1_VLRDIS	:= (cSE2Als)->CX1_VLRDIS
			(__cArqEmp)->D1_TOTAL	:= (cSE2Als)->D1_TOTAL
			(__cArqEmp)->(MsUnlock())
		EndIf
		
		(cSE2Als)->(dbSkip())
	EndDo
	(cSE2Als)->(dbCloseArea())
Next nX

Return 
/*/{Protheus.doc} F761VLinEm
Validação de Linha da Nota de Empenho
@author Alvaro Camillo
@since 14/01/2015
/*/
Function F761VLinEm(oModelNEmp)
Local lRet		:= .T.
Local nValor	:= 0
 
If __lVlEmp
	nValor := oModelNEmp:GetValue('FV5_EVALOR')
	If Empty(nValor)
		Help(" ",1,"F761VLinEm",,STR0265,3,1)//"Por favor, informar um valor para o empenho."
		lRet := .F.
	Endif 
EndIf



Return lRet

/*/{Protheus.doc} F761VEmpMK
Validação de Linha da Nota de Empenho
@author Alvaro Camillo
@since 14/01/2015
/*/
Function F761VEmpMK()
Local nRet := 1

If !IsBlind()
	If !MsgYesNo(STR0266)//"O itens na tabela de empenho serão substituidos pela seleção. Confirma Operação?"
		nRet := 0
	EndIf
EndIf

Return nRet
