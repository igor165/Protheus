#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#Include "ATFA012.ch"
#Include "FWLIBVERSION.CH"

STATIC __cGrupoFNG      := ""
STATIC __aHeadAvp		:= {}		//Header da GetDados do AVP
STATIC __aColsAvp		:= {}		//Acols da GetDados do AVP
STATIC __aHeadMrg		:= {}		//Header da GetDados da Margem Gerencial
STATIC __aColsMrg		:= {}
STATIC __LinOK			:= .T.
STATIC __cProcPrinc	    := 'ATFA012'
STATIC lAFA012  		:= ExistBlock('ATFA012')
STATIC __lCopia 		:= .F.
Static __aRateio 		:= {}
STATIC __lIncluMan	    := .F.
STATIC __nQtMulti		:= 0
Static __nHdlPrv		:= 0
Static __nTotal		    := 0
Static __cArqCtb		:= ""
Static __lCTBFIM		:= .F.
Static __cLoteAtf		:= ""
Static __aCTB			:= {}
Static __lAltera		:= .F.
Static __lClassifica	:= .F.
Static __lContabiliza   := .T.
Static __lDelData		:= .F.
Static __oModelAut	    := Nil
Static __lAtfAuto		:= .F.
Static __aAutoItens	    := Nil
Static __lMultiATF	    := .F.
Static __lAmplia	    := .F.
Static __lReaval	    := .F.
Static _oATFA0121
Static _oATFA0122
STATIC lIsRussia	    := (cPaisLoc $ "RUS")// CAZARINI - Flag to indicate if is Russia location
Static lRetPE    	    := .F.		//Retorno do PE AF012COPY
Static aFlagCTB         := {}
Static __lMetric	:= FwLibVersion() >= "20210517" .And. GetSrvVersion() >= "19.3.0.6" //Metricas apenas em Lib a partir de 20210517 e Binario 19.3.0.6

#DEFINE OPC_VISUA 		2
#DEFINE OPC_INC 		3
#DEFINE OPC_ALTER 		4
#DEFINE OPC_CONVERSAO	4

//-------------------------------------------------------------------
/*/{Protheus.doc}ATFA012
Cadastro de Ativos Imobilizados
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Programador ³Data    ³Issue     ³Motivo da Alteracao                   ³
//ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
//³A.Rodriguez ³24/04/18³DMINA-2123³AF012ATDOK() Si A2_TIPDOC = 13 (tipo  ³
//³            ³        ³          ³doc identificación = Cédula ciudadaná)³
//³            ³        ³          ³, valida A2_PFISICA. COL              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//-------------------------------------------------------------------

Function ATFA012(xCab,xItens,nOpcAuto,aParam,aCtb)
Local oBrowse  	:= FWmBrowse():New()
Local lRet		  	:= .T.
Local cFilter   	:= Nil
Local lA010Brwt 	:= ExistBlock("A010BRWT")
Local cMoedaAtf 	:= Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))

Private cCadastro 	:= STR0092//'Atualização de Ativos Imobilizados'

Private aParamAuto	:= {}
Private lPadrao 		:= .F.
Private aRotina		:= {}
Private nOriginal 	:= 0

Default xCab 			:= Nil
Default xItens	  	:= Nil
Default nOpcAuto 	  	:= 0
Default aParam		:= {}
Default aCtb			:= {}

If !AtfVldMoed(cMoedaAtf)
	lRet := .F.
	Help(" ",1,"ATFVLDMOED",,STR0177,1,0)//"Parâmetro MV_ATFMOED configurado incorretamente"
EndIf

If lRet

	//Carrega valor do xParam
	aParamAuto := If(aParam <> Nil,aParam,Nil)
	//F12 - Ativa grupo de perguntas.
	SetKey( VK_F12, { || Pergunte("AFA012",.T.) } )

	__aRateio := {}

	//Limpa variavel static referente a ativos tipo 15 margem gerencial
	If len(__aColsMrg) > 0
		__aColsMrg := {}
	Endif

	/*
	* Verificação do Parâmetro da Contabilização On/Off Line
	*/
	pergunte("AFA012",.F.)
	AF012PerAut()

	If Type("MV_PAR05") == "N"
		__lContabiliza := MV_PAR05 == 1
	Else
		__lContabiliza := .T.
	EndIf

	///Ponto de Entrada - MBROWSE //ACRESCENTAR FILTRO NA BROWSE
	If lA010Brwt
		cFilter := ExecBlock( "A012BRWT", .F., .F. )
		cFilter := If(ValType(cFilter) == "C", cFilter, Nil )
	Endif
	//
	If xCab <> NIL .AND. !Empty(xCab)
		//Rotina automatica.
		If nOpcAuto == 3
			Inclui := .T.
			Altera := .F.
		ElseIf nOpcAuto == 4
			Inclui := .F.
			Altera := .T.
		Else
			Inclui := .F.
			Altera := .F.
		EndIf

		lRet := AF012AutRot(xCab,xItens,nOpcAuto,aParam,,,,aCTB)
		aCtb := Array(4)
		aCtb[1] := __nHdlPrv
		aCtb[2] := __nTotal
		aCtb[3] := __cArqCtb
		aCtb[4] := __cLoteAtf
	Else
		oBrowse := BrowseDef(cFilter)
		oBrowse :Activate()
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
Browse definition

@author Felipe Morais
@since 28/02/2016
@version P12/MA3 - Russia
/*/
//-------------------------------------------------------------------

Static Function BrowseDef(cFilter)
Local oBrowse as Object
Local aLegenda as Array
Local nX as Numeric
Private cCadastro
Default cCadastro := STR0092

//Default cFilter as Character

oBrowse := FWmBrowse():New()

//Graphics and Visions of Browse
If lIsRussia
	oBrowse:SetAttach( .F. )
	oBrowse:SetOpenChart( .F. )
else
	oBrowse:SetAttach( .T. )
	oBrowse:SetOpenChart( .T. )
endif

If cFilter <> Nil
	oBrowse:SetFilterDefault(cFilter)
EndIf
oBrowse:SetAlias('SN1')
oBrowse:SetDescription(cCadastro) //Atualização de Ativos Imobilizados.
aLegenda := AtfLegenda('SN1')
For nX := 1 To Len(aLegenda)
	oBrowse:AddLegend( aLegenda[nX,1],aLegenda[nX,2])
Next

aRotina := Nil
oBrowse:SetCacheView(.F.)// Não realiza o cache da viewdef

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012PerAut
Carrega o valor das variaveis da rotina automatica
@author William Matos Gundim Junior
@since  13/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012PerAut()
Local nX 		:= 0
Local cVarParam := ""

If Type("aParamAuto") != "U"
	For nX := 1 to Len(aParamAuto)
		cVarParam := Alltrim(Upper(aParamAuto[nX][1]))
		If "MV_PAR" $ cVarParam
			&(cVarParam) := aParamAuto[nX][2]
		EndIf
	Next nX
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Menu de Ativos Imobilizados
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef(lMarkBrw)
Local lAf012rot 	:= ExistBlock('AF012ROT')
Local aRotina 	:= {}
Default lMarkBrw	:= .F.

ADD OPTION aRotina TITLE STR0059	ACTION 'PesqBrw'            OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina TITLE STR0060	ACTION 'VIEWDEF.ATFA012'   	OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina TITLE STR0061	ACTION 'AF012Inclu'		   	OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina TITLE STR0062	ACTION 'AF012AltEx'   		OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina TITLE STR0063	ACTION 'AF012AltEx'   		OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina TITLE STR0064	ACTION 'AF012EXCLT'        	OPERATION 5 ACCESS 0 //'Excluir Lote'
ADD OPTION aRotina TITLE STR0065	ACTION 'AF012Cpy'     		OPERATION 9 ACCESS 0 //'Copia'
ADD OPTION aRotina TITLE STR0066	ACTION 'MSDOCUMENT'   	  	OPERATION 4 ACCESS 0 //'Conhecimento'
ADD OPTION aRotina TITLE STR0056	ACTION 'AF012LAUDO'   	  	OPERATION 4 ACCESS 0 //'Laudo'
ADD OPTION aRotina TITLE STR0067	ACTION 'ATFLEGENDA'		  	OPERATION 7 ACCESS 0 //Legenda
ADD OPTION aRotina TITLE STR0089	ACTION 'CTBC662'			OPERATION 8 ACCESS 0 //'Tracker Contabil'

If cPaisLoc == "BRA"
	ADD OPTION aRotina TITLE STR0068	ACTION 'AF012CVMET'   	  OPERATION 4 ACCESS 0 //'Converte Metodo'
	ADD OPTION aRotina TITLE STR0069	ACTION 'AF012CVMET'   	  OPERATION 5 ACCESS 0 //'Canc.Converte Metodo'
ElseIf cPaisLoc == "COL"
	ADD OPTION aRotina TITLE STR0070	ACTION 'AF012ACVCL'   	  OPERATION 4 ACCESS 0 //'Depreciacao'
	ADD OPTION aRotina TITLE STR0071	ACTION 'AF012ACVCL'   	  OPERATION 5 ACCESS 0 //'Canc.Depreciacao'
EndIf

If !lIsRussia
	ADD OPTION aRotina TITLE STR0072	    	ACTION 'Af012BlqDesb' 	OPERATION 3 ACCESS 0 //'Blq/Desb.'
	ADD OPTION aRotina TITLE STR0073			ACTION 'ATFA320'   	 	OPERATION 3 ACCESS 0 //'Contr. Terceiros'
	ADD OPTION aRotina TITLE STR0074			ACTION 'ATFA321'   	 	OPERATION 3 ACCESS 0 //'Contr.em Terceiros'
	ADD OPTION aRotina TITLE STR0075			ACTION 'AF012IMPCL'   	OPERATION 3 ACCESS 0 //'Import. Classificação'
	ADD OPTION aRotina TITLE STR0076			ACTION 'AFA012LOG'		OPERATION 3 ACCESS 0 //'Log Proc'
EndIf
if  IsInCallStack("CFGA530")//Privilegios
	ADD OPTION aRotina TITLE STR0077	ACTION "AF012ExcMa"			OPERATION 4 ACCESS 0         //'Confirmar'
EndIF

If lMarkBrw
	aRot := {}
	ADD OPTION aRot TITLE STR0077	ACTION "AF012ExcMa(1)"			OPERATION 4 ACCESS 0         //'Confirmar'

	aRotina := aClone(aRot)
Endif

If lAf012rot
	aRotina := ExecBlock("AF012ROT",.F.,.F.,{aRotina})
Endif

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface do cadastro de Ativos
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel 		:= FWLoadModel('ATFA012')
Local oView 		:= FWFormView():New()
Local oSN1  		:= FWFormStruct(2, 'SN1')
Local oSN3  		:= FWFormStruct(2, 'SN3')

Local lDetail 	:= .F.
Local lAtfxmvc := FWIsInCallStack("ATFxMVC_02")

pergunte("AFA012",.F.)
AF012PerAut()
lDetail :=  MV_PAR04 == 1

//-----------------------------------------------------------------------
// Desabilitada a edicao por tela dos campos do CIAP conforme orientacao
// do fiscal, os dados devem vir da NF. Complemento do chamado TUQZOM
//-----------------------------------------------------------------------
If cPaisLoc == "BRA" .AND. !lAtfxmvc
	oSN1:SetProperty('N1_CODCIAP',MVC_VIEW_CANCHANGE,.F.)
	oSN1:SetProperty('N1_ICMSAPR',MVC_VIEW_CANCHANGE,.F.)
EndIf

oSN3:RemoveField('N3_CBASE')
oSN3:RemoveField('N3_SEQ')
oSN3:RemoveField('N3_ITEM')
oView:SetModel(oModel)
oView:AddField('VIEW_SN1', oSN1,'SN1MASTER' )
oView:AddGrid ('VIEW_SN3', oSN3,'SN3DETAIL')
oView:CreateHorizontalBox( 'BOXSN1', 040)
oView:CreateHorizontalBox( 'BOXSN3', 060)
oView:SetOwnerView('VIEW_SN1','BOXSN1')
oView:SetOwnerView('VIEW_SN3','BOXSN3')

oView:AddIncrementField('VIEW_SN3','N3_SEQ' )


If __lAltera .Or. __lCopia .Or. __lIncluMan
	oSN3:RemoveField('N3_DTBAIXA')
Else
	oSN3:SetProperty('N3_DTBAIXA',MVC_VIEW_CANCHANGE,.F.)
EndIf

/* Cria botões na View*/
oView:AddUserButton( STR0078,'' , {|oView| Af012Margem()} ,,,{OPC_INC,OPC_ALTER}) //Margem Gerencial
If __lClassifica
	oView:AddUserButton( STR0079,'' , {|oView| Af012Avp()}    ,,,{OPC_INC,OPC_ALTER}) //Cálculo AVP
Else
	oView:AddUserButton( STR0079,'' , {|oView| Af012Avp()}    ,,,{OPC_INC}) //Cálculo AVP
EndIf
If __lIncluMan
	oView:AddUserButton( STR0080,'' , {|oView| Af12CrAuto()} ) //Múltiplos
EndIf

oView:AddUserButton( STR0084,'' , {|oView| AF012CeTer()} ,,,{OPC_INC,OPC_VISUA,OPC_ALTER} ) //Cont. em Terceiros
oView:AddUserButton( STR0083,'' , {|oView| AF012CdTer()} ,,,{OPC_INC,OPC_VISUA,OPC_ALTER} ) //Contr. Terceiros
oView:AddUserButton( STR0081,'' , {|oView| AF012Rateio()} ) //Rateio
oView:AddUserButton( STR0082,'' , {|oV| AF012RESP(oV) }  ) //Resp

If lDetail
	oView:SetViewProperty('VIEW_SN3','ENABLEDGRIDDETAIL', {45} )
EndIf
oView:EnableTitleView('VIEW_SN1' , IIF(lIsRussia,STR0175,STR0085) )
oView:EnableTitleView('VIEW_SN3' , STR0086 )

oView:SetViewAction( 'BUTTONCANCEL',{ |oView| AF012CanTer(oView:GetModel(),.T.)})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados do cadastro de ativos
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oSN1		:= Nil
Local oSN3		:= Nil
Local oSND		:= Nil
Local oModel	:= MPFormModel():New('ATFA012',Iif(IsInCallStack("ATFA240"),{|oModel|AFA012DtInDp(oModel)},)/*PreValidacao*/,{ |oModel|AF012ATDOK(oModel)}/*PosValidacao*/,{|oModel|AF012AGRV(oModel)})
Local aRelac	:= {}
local oStructSN4 as object

Private lMile	:= IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

//----------------------------------------------------------------------
// Os objetos de estrutura são carregados após a correção do dicionário
//----------------------------------------------------------------------
oSN1 := FWFormStruct(1,'SN1')
oSN3 := F012Struct('SN3')
oSND := FWFormStruct(1,"SND")

AF012Static()

If __lClassifica .Or. __lCopia .Or. __nQtMulti > 0
	oSN1:SetProperty('N1_GRUPO'		,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_PATRIM'	,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_CBASE'		,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_ITEM'		,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_AQUISIC'	,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_CHAPA'		,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_MARGEM'	,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_INDAVP'	,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_INIAVP'	,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_DTAVP'		,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_TPAVP'		,MODEL_FIELD_KEY, .F. )
	oSN1:SetProperty('N1_FORNEC'	,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_LOJA'		,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_NSERIE'	,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_NFISCAL'	,MODEL_FIELD_KEY, .T. )
	If __lClassifica //Só entra se for classificacao, tratamento para nao alterar a quantidade quando os bens que vem de integracao pois, a origem dos valores do campo N1_QUANTD vem do modulo origem
		oSN1:SetProperty('N1_QUANTD'   ,MODEL_FIELD_NOUPD, .T.)
	Endif
Else
	oSN1:SetProperty('N1_GRUPO'		,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_PATRIM'	,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_CBASE'		,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_ITEM'		,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_AQUISIC'	,MODEL_FIELD_KEY, .T. )
	If __lAltera .And. FunName() == "ATFA012" .And. Type("MV_PAR02") == "N" .And. MV_PAR02 == 1
		oSN1:SetProperty('N1_CHAPA'		,MODEL_FIELD_KEY, .F. )
	ElseIf lMile .And. Type("MV_PAR02") == "N" .And. MV_PAR02 == 1
		oSN1:SetProperty('N1_CHAPA'		,MODEL_FIELD_KEY, .F. )
	Else
		oSN1:SetProperty('N1_CHAPA'		,MODEL_FIELD_KEY, !lIsRussia )
	EndIf
	oSN1:SetProperty('N1_MARGEM'	,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_INDAVP'	,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_INIAVP'	,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_DTAVP'		,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_TPAVP'		,MODEL_FIELD_KEY, .T. )
	oSN1:SetProperty('N1_ICMSAPR'	,MODEL_FIELD_KEY, .T. )
EndIf
oSN1:SetProperty('N1_STATUS'		,MODEL_FIELD_KEY, .T. )
//Ativos que vem de documento de entrada
//Campo N1_ALIQPIS existe apenas no Brasil
If cPaisLoc == "BRA"
	oSN1:SetProperty('N1_ALIQPIS'		,MODEL_FIELD_WHEN, {|oModel| A012NOTA(oModel) } )
	oSN1:SetProperty('N1_ALIQCOF'		,MODEL_FIELD_WHEN, {|oModel| A012NOTA(oModel)} )
EndIf

// Ajuste da validação pois o X3_VALID esta incorreto na base do cliente (o espaço existe e funcionava na 11.80, mas parou de funcionar na 12),
// não subiremos para a MAIN pois este será um ajuste pontual e temporário para o cliente não precisar rodar o UPDDISTR.
If !lIsRussia
	oSN1:SetProperty('N1_STATUS'	,MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, 'Pertence("0|1|2|3|4")' ))
EndIf

//-- JRJ Ponto de entrada para permitir a configuracao de campos mantendo a integrida com o PE AT010SN1 na versão P11.80
If __lAltera .Or. __lClassifica
	If ExistBlock("AT012SN1")
		ExecBlock("AT012SN1",.F.,.F.,{oSN1})
	EndIf
EndIf

If findFunction("A103disObr") .And. A103disObr() //"Gustavo Mantovani"// Integração do compras
	oSN3:SetProperty('N3_CCONTAB',MODEL_FIELD_OBRIGAT, .F. )
	oSN3:SetProperty('N3_HISTOR',MODEL_FIELD_OBRIGAT, .F. )
EndIf

oSND:SetProperty('*' , MODEL_FIELD_INIT, NIL )
/*
Adiciona o campo N3_SEQ, caso nao esteja na estrutura */
If Ascan(oSN3:aFields,{|campo| AllTrim(campo[3]) == "N3_SEQ"}) == 0
	oSN3:AddField(SX3->(RetTitle("N3_SEQ")),SX3->(RetTitle("N3_SEQ")),"N3_SEQ","C",TamSX3("N3_SEQ")[1],TamSX3("N3_SEQ")[2],,,,.F.,,.F.,.F.,.F.,,)
Endif
If Ascan(oSN3:aFields,{|campo| AllTrim(campo[3]) == "N3_SEQREAV"}) == 0
	oSN3:AddField(SX3->(RetTitle("N3_SEQREAV")),SX3->(RetTitle("N3_SEQREAV")),"N3_SEQREAV","C",TamSX3("N3_SEQREAV")[1],TamSX3("N3_SEQREAV")[2],,,,.F.,,.F.,.F.,.F.,,)
Endif

oSN3:SetProperty("N3_DESCEST",MODEL_FIELD_INIT,FWBuildFeature(STRUCT_FEATURE_INIPAD,'AF012EST()'))

/*-*/
AFA012CriaGat(oSN3) //Função para criar gatilhos do model.
//
oModel:SetDescription(STR0085) //Atualização de Ativos Imobilizados
oModel:AddFields('SN1MASTER',/**/,oSN1)
oModel:AddGrid('SN3DETAIL','SN1MASTER',oSN3,{|oModel,nLinha,cAcao,cCampo| AF012PLNOK(oModel,nLinha,cAcao,cCampo)},{|oModel| AF012ALNOK(oModel)})
oModel:AddGrid('SNDDETAIL','SN1MASTER',oSND)
oModel:GetModel( 'SNDDETAIL' ):SetOptional( .T. )

If __lAltera .Or. __lCopia
	oModel:GetModel( 'SN3DETAIL' ):SetLoadFilter( , " N3_DTBAIXA = ' ' " )
EndIf

aAdd(aRelac,{'N3_FILIAL','xFilial("SN3")'})
aAdd(aRelac,{'N3_CBASE' ,'N1_CBASE'})
aAdd(aRelac,{'N3_ITEM'  ,'N1_ITEM'  })

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'SN3DETAIL', aRelac , SN3->(IndexKey(1)))

aRelac := {}
aAdd(aRelac,{'ND_FILIAL','xFilial("SND")'})
aAdd(aRelac,{'ND_CBASE' ,'N1_CBASE'})
aAdd(aRelac,{'ND_ITEM'  ,'N1_ITEM' })
// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'SNDDETAIL', aRelac , SND->(IndexKey(3)))


oSN3:SetProperty('N3_DINDEPR',MODEL_FIELD_WHEN,{|| A012DEPAC(oModel) })

//Não permite edição da conta se não for inclusão
oSN3:SetProperty('N3_CCONTAB',MODEL_FIELD_WHEN,{|| A012WHENCONTA(oModel)})
oSN3:SetProperty('N3_CDEPREC',MODEL_FIELD_WHEN,{|| A012WHENCONTA(oModel)})
oSN3:SetProperty('N3_CCDEPR',MODEL_FIELD_WHEN,{|| A012WHENCONTA(oModel) })
oSN3:SetProperty('N3_CDESP',MODEL_FIELD_WHEN,{|| A012WHENCONTA(oModel) })
oSN3:SetProperty('N3_CCORREC',MODEL_FIELD_WHEN,{|| A012WHENCONTA(oModel) })

oModel:GetModel( 'SNDDETAIL' ):SetLoadFilter( { { 'ND_STATUS', "'1'" } } )// Só os responsaveis ativos

oModel:SetPrimarykey({'N1_FILIAL','N1_CBASE','N1_ITEM'})

oModel:GetModel('SN1MASTER'):SetDescription(STR0085)

oModel:GetModel( 'SN3DETAIL' ):SetUseOldGrid( .T. )

// Valida se alterações de dicion?io para o campo N1_CODBEM est? aplicadas. Estas somente estaram disponiveis a partir da realese 12.1.33.
If Trim( Posicione( 'SX3', 2, 'N1_CODBEM', 'X3_WHEN' ) ) != 'MNT080WHEN()'

	// Altera VALID e WHEN utilizado no VIEW do campo N1_CODBEM.
	oSN1:SetProperty( 'N1_CODBEM', MODEL_FIELD_VALID, FwBuildFeature( STRUCT_FEATURE_VALID, 'MNTA080VLD( , .T. )' ) )
	oSN1:SetProperty( 'N1_CODBEM', MODEL_FIELD_WHEN , FwBuildFeature( STRUCT_FEATURE_WHEN , 'MNT080WHEN( , .T. )' ) )

EndIf

If !__lClassifica .And. !__lIncluMan
	oModel:lModify := .T.
EndIf

If lIsRussia .and. FWisincallstack("AF012ALTEX")
	oStructSN4	:= FWFormStruct(1, "SN4",)
	oModel:AddGrid("SN4DETAIL", "SN1MASTER", oStructSN4)
	aRelac := {}
	aAdd(aRelac,{'N4_FILIAL','xFilial("SN1")'})
	aAdd(aRelac,{'N4_CBASE' ,'N1_CBASE'})
	aAdd(aRelac,{'N4_ITEM'  ,'N1_ITEM' })
	oModel:SetRelation("SN4DETAIL", aRelac, SN4->(IndexKey(1)))
EndIf

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc}AFA012CriaGat
Função para criação dos gatilhos
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AFA012CriaGat(oSN3)
Local aCampos := {}
Local nX := 1

//Relação de campos com gatilhos.
aAdd(aCampos, 'N3_VORIG2')
aAdd(aCampos, 'N3_VORIG3')
aAdd(aCampos, 'N3_VORIG4')
aAdd(aCampos, 'N3_VORIG5')
aAdd(aCampos, 'N3_VRCBAL1')
aAdd(aCampos, 'N3_VRDBAL1')
aAdd(aCampos, 'N3_VRCMES1')
aAdd(aCampos, 'N3_VRDMES1')
aAdd(aCampos, 'N3_VRCACM1')
aAdd(aCampos, 'N3_VRDACM1')
aAdd(aCampos, 'N3_VRDBAL2')
aAdd(aCampos, 'N3_VRDMES2')
aAdd(aCampos, 'N3_VRCACM2')
aAdd(aCampos, 'N3_VRDACM2')
aAdd(aCampos, 'N3_VRDBAL3')
aAdd(aCampos, 'N3_VRDMES3')
aAdd(aCampos, 'N3_VRCACM3')
aAdd(aCampos, 'N3_VRDACM3')
aAdd(aCampos, 'N3_VRDBAL4')
aAdd(aCampos, 'N3_VRDMES4')
aAdd(aCampos, 'N3_VRCACM4')
aAdd(aCampos, 'N3_VRDACM4')
aAdd(aCampos, 'N3_VRDBAL5')
aAdd(aCampos, 'N3_VRDMES5')
aAdd(aCampos, 'N3_VRCACM5')
aAdd(aCampos, 'N3_VRDACM5')
aAdd(aCampos, 'N3_VRCDM1')
aAdd(aCampos, 'N3_VRCDB1')
aAdd(aCampos, 'N3_VRCDA1')

/* Criação de Gatilhos */
oSN3:AddTrigger( "N3_VRDBAL1" , "N3_VRDBAL1"	, {|| .T. }  , {|| AF012ADPBL() } )
oSN3:AddTrigger( "N3_VRDACM1" , "N3_VRDACM1"	, {|| .T. }  , {|| AF012ADPAC() } )
oSN3:AddTrigger( "N3_VRDMES1" , "N3_VRDMES1"  , {|| .T. }  , {|| AF012ADPMS() } )
oSN3:AddTrigger( 'N3_DEXAUST' , 'N3_TXDEPR1'	, {|| .T. }  , {|| A012GTEXST() } )
oSN3:AddTrigger( 'N3_VORIG1'  , 'N3_VORIG1'	, {|| .T. }  , {|| AF012ACONV('N3_VORIG1') } )
oSN3:AddTrigger( 'N3_TXDEPR1' , 'N3_TXDEPR1'  , {|| .T. }  , {|| AF012ATX()} )
oSN3:AddTrigger( 'N1_GRUPO'   , 'N1_GRUPO'     , {|| .T. }  , {|| AF012ATX(.T.)} )
For nX := 1 To Len(aCampos)
	oSN3:AddTrigger( aCampos[nX], aCampos[nX], {|| .T. }, {|| AF012VLAEC() })
Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012ExcLt
Exclusao em Lote de Imobilizados

@author pequim

@since 19/11/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF012ExcLt(cAlias,nReg,nOpc)
Local aAlias	:= {}
Local oDlgMrk 	:= Nil
Local aArea		:= GetArea()
Local aColumns 	:= {}
Local aRotOld	:= aClone(aRotina)
Local lMostraLcto := .F.
Local lAglut	  := .F.
Local lRet        := .T.
Local lPE         := If(ExistBlock('ATMOSCNT'), .T., .F.)
Local lMostra     := If( lPE .and. (Execblock('ATMOSCNT')),.T., .F.)  // PE para mostrar a tela de  lactos na exclusão em lote de ativos

aRotina	 	:= Menudef(.T.)

pergunte("AFA012",.F.)
AF012PerAut()

lMostraLcto	:= (MV_PAR01 == 1)
lAglut		:= (MV_PAR06 == 1)

//Verifica as configuracoes contabeis
If !lPE
	lRet := CTBINTRAN(1,.F.)
Endif

If lIsRussia
	if lRet == .F. .and. SN1->N1_STATUS=="0"
		lRet := .T.
	Endif
Endif

If lRet
	If Pergunte("AFA012EXLT",.T.)

		//----------------------------------------------------------
		//Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias 		:= AF012ExcQr()
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]

		Begin Transaction
			If !(cAliasMrk)->(Eof())
				//------------------------------------------
				//Criação da MarkBrowse no Layer LISTA_DAC
				//------------------------------------------
				oMrkBrowse:= FWMarkBrowse():New()
				oMrkBrowse:SetFieldMark("N1_OK")
				oMrkBrowse:SetOwner(oDlgMrk)
				oMrkBrowse:SetAlias(cAliasMrk)
				oMrkBrowse:SetMenuDef("ATFA012")
				oMrkBrowse:bMark    := {|| AF012Mark(cAliasMrk )}
				oMrkBrowse:bAllMark := {|| AF012Inv(cAliasMrk) }
				oMrkBrowse:SetDescription("")
				oMrkBrowse:SetColumns(aColumns)
				oMrkBrowse:Activate()

			Else
				Help(" ",1,"RECNO")
			EndIf
			// Deixar na transacão a contabilização - não ha como contabilizar posteriormente
			// pois as linhas são exlcuidas e não ha contabilização off
			If __lContabiliza .And. __nTotal > 0 .And. __lCTBFIM
				RodaProva(__nHdlPrv,__nTotal)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Envia para Lancamento Contabil
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cA100Incl(__cArqCtb,__nHdlPrv,3,__cLoteAtf,lMostra,lAglut)
			Endif
		End Transaction

		If !Empty (cAliasMrk)
			dbSelectArea(cAliasMrk)
			dbCloseArea()
			cAliasMrk := ""
			dbSelectArea("SN1")
			dbSetOrder(1)
		EndIf

	EndIf
	pergunte("AFA012",.F.)
	AF012PerAut()

Endif

//Deleta tabela temporária criada no banco de dados
If _oATFA0122 <> Nil
	_oATFA0122:Delete()
	_oATFA0122 := Nil
Endif

RestArea(aArea)
aRotina := aClone(aRotOld)
Return (.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012Mark
Marcacao de um registro
@author pequim
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF012Mark(cAliasTRB)

Local lRet		:= .F.
Local cMarca := oMrkBrowse:cMark


SN1->(dbGoto((cAliasTRB)->RECNO))

If SN1->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
	//Verifica se pode deletar
	lRet := AF012VExc(.T.) .AND. ATFRespVl( , (cAliasTRB)->(N1_FILIAL + N1_CBASE + N1_ITEM) , .F. )
	//A FWMarkBrowse() ja traz o registro com a marca quando bMark
	//Caso a exclusao não seja permitida, desmarca registro
	IF	!lRet .and. (cAliasTRB)->N1_OK == cMarca
		(cAliasTRB)->N1_OK := "  "
		(cAliasTRB)->(MsUnlock())
		SN1->(MsUnlock())

		//Caso tenha desmarcado registro selecionado anteriormente
		//a FWMarkBrowse() ja traz o registro sem a marca quando bMark.
		//Entao destravamos o mesmo para uso de outro terminal
	ElseIf Empty( (cAliasTRB)->N1_OK )
		(cAliasTRB)->(MsUnlock())
		SN1->(MsUnlock())
	Endif
Else
	lRet := .F.
Endif


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012Inv
Marcacao de vários registros
@author pequim
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF012Inv(cAliasTRB)

Local nReg 	 := (cAliasTRB)->(Recno())
Local cMarca := oMrkBrowse:cMark

dbSelectArea(cAliasTRB)
dbgotop()

While !(cAliasTRB)->(Eof())
	SN1->(dbGoto((cAliasTRB)->RECNO))
	If SN1->(MsRLock()) .AND. (cAliasTRB)->(MsRLock())
		If AF012VExc(.F.) .And. ATFRespVl( .F. , (cAliasTRB)->(N1_FILIAL + N1_CBASE + N1_ITEM) , .F. )
			IF	(cAliasTRB)->N1_OK == cMarca
				(cAliasTRB)->N1_OK := "  "
				(cAliasTRB)->(MsUnlock())
				SN1->(MsUnlock())
			Else
				(cAliasTRB)->N1_OK := cMarca
			Endif
	    Endif
	Endif
	(cAliasTRB)->(dbSkip())
Enddo

(cAliasTRB)->(dbGoto(nReg))

oMrkBrowse:oBrowse:Refresh(.t.)

Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} AF012LAUDO
Possibilitar anexar documentos aos itens do bem
@author William Matos Gundim Junior
@since 19/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF012LAUDO(cAlias,nReg,nOpc)
Local nI := 1
Local cCaption
Local aSN3:= {"N3_CBASE", "N3_ITEM", "N3_TIPO" , "N3_SEQ" , "N3_HISTOR"}
Local nSN3:= 0
Local aSize := MsAdvSize(,.F.,430) // MsAdvSize()
Local aObjects := {}
Local aInfo := {}
Local aPosObj := {}
Local nANT := 0
Local aSavSN3 := {}

Local oSize

Private nUsado:=0
Private aCols := {}
Private aHeader[0]
Private cAlias1 := "SN3"
Private xSN1
Private xSN3

Aadd( aObjects, { 100, 100, .T., .T. } )
Aadd( aObjects, { 315,  70, .T., .T. } )
aInfo   := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .F. )
nSN3    := LEN(aSN3)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a integridade dos campos de Bancos de Dados            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cAlias)
xSN1 := cFilial

IF Reccount() == 0
	Return (.T.)
EndIf

If SN1->N1_FILIAL != cFilial
	HELP(" ",1,"A000FI")
	Return (.T.)
EndIf


RegToMemory("SN1", .F.)

cAlias1 := "SN3"

dbSelectArea(cAlias1)
dbSetOrder( 1 )
xSN3 := cFilial
dbSeek( cFilial + SN1->N1_CBASE + SN1->N1_ITEM )

cCaption := "[ "+ SN1->N1_DESCRIC + " ]"

DbSelectArea("SX3")
DbSetOrder(2)
FOR nI := 1 TO nSN3
	IF DbSeek( aSN3[nI] )
		nUsado++
		AADD(aHeader,{Trim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			"",;
			SX3->X3_TIPO,;
			"",;
			"";
			};
			)
	EndIf
NEXT

dbSelectArea(cAlias1)
dbSetOrder( 1 )
nI := 1
While (xSN1 + SN1->(N1_CBASE + N1_ITEM )) == (xSN3 + SN3->(N3_CBASE + N3_ITEM )) .AND. (! SN3->(EOF()))

	aAdd( aCols , {SN3->N3_CBASE, SN3->N3_ITEM , SN3->N3_TIPO , SN3->N3_SEQ, SN3->N3_HISTOR, .F. })
	aAdd( aSavSN3 ,SN3->(RecNo()))
	nI++
	dbSelectArea(cAlias1)
	DbSkip()
End

//Faz o calculo automatico de dimensoes de objetos
oSize := FwDefSize():New(.T.)

oSize:lLateral := .F.
oSize:lProp	:= .T. // Proporcional

oSize:AddObject( "1STROW" ,  100, 95, .T., .T. ) // Totalmente dimensionavel
oSize:AddObject( "2NDROW" ,  100, 05, .T., .T. ) // Totalmente dimensionavel

oSize:Process() // Dispara os calculos

a1stRow := {oSize:GetDimension("1STROW","LININI"),;
			oSize:GetDimension("1STROW","COLINI"),;
			oSize:GetDimension("1STROW","LINEND"),;
			oSize:GetDimension("1STROW","COLEND")}

a2ndRow := {oSize:GetDimension("2NDROW","LININI"),;
			oSize:GetDimension("2NDROW","COLINI"),;
			oSize:GetDimension("2NDROW","LINEND"),;
			oSize:GetDimension("2NDROW","COLEND")}

DEFINE MSDIALOG oDlg TITLE cCaption FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] OF oMainWnd PIXEL

oGetDB := MsGetDados():New( oSize:GetDimension("1STROW","LININI") ,;                    // 01 nTop
oSize:GetDimension("1STROW","COLINI"),;	      // 02 nLeft
oSize:GetDimension("1STROW","LINEND"),;	// 03 nBottom,
 oSize:GetDimension("1STROW","COLEND"),;	// 04 nRight
2,;				         // 05 nOpc 4
".T.",;                 // 06 cLinhaOk
".T.",;	               // 07 cTudoOk
"+ITEM", ;	         	// 08 cIniCpos
.F.;                   // 09 lDelete , .T.
)

@ oSize:GetDimension("2NDROW","LININI"), oSize:GetDimension("2NDROW","COLINI") BUTTON STR0056 PIXEL OF oDlg ACTION (nANT := n,  MsDocument("SN3", aSavSN3[nANT], 4 ) , n := nANT , oGetDB:oBROWSE:SETFOCUS())
ACTIVATE MSDIALOG oDlg CENTER

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} AF012CVMet
Possibilitar a conversão entre métodos de depreciação.
@author William Matos Gundim Junior
@since 19/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF012CVMet(cAlias,nReg,nOpc)
Local nOpcRot := 0
Local nConfirma	:= 0
Local aBens	:= {}
Local dUltDepr		:= GetMV("MV_ULTDEPR")+1
Local cCalcDep		:= SuperGetMv("MV_CALCDEP",.F.,"")
Local lRet		:= .T.
Local aRotina	:= {}

ALTERA := .F.

aRotina := MenuDef()
nOpcRot := aRotina[nOpc][4]

//AVP2
//Verifica implementacao do AVP e AVP parcela
If lRet .and. (cCalcDep == "0" .and. !(dDataBase >= dUltDepr .and. dDataBase <= LastDay(dUltDepr))) .OR.;
	(cCalcDep == "1" .and. !(Year(dDataBase) == Year(dUltDepr)))
	Help(" ",1,"A012CONVDT") //"Periodo para conversao invalido."
	lRet := .F.
Endif

//AVP2
//Verifica se o bem foi gerado por AVP Parcela
If lRet  .and. SN1->N1_PATRIM = 'V' .and. Alltrim(SN1->N1_ORIGEM) == 'ATFA460'
	Help(" ",1,"AF012460CV")  //'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo não poderá sofrer revisão de metodo de depreciação.'
	lRet := .F.
Endif

If lRet
	//Atualiza a tabela SN0 - Configurações do Ativo Fixo
	ATFXTabela()

	If AF12SelConv(SN1->N1_CBASE,SN1->N1_ITEM,@aBens,nOpcRot)
	DEFINE WIZARD oWizard TITLE If(nOpcRot == 4 , STR0057, STR0058) ;//" Conversão de Método de Depreciação "##" Cancelamento da conversão de Método de Depreciação "
	        HEADER " " ;
	        MESSAGE STR0005;//" Apresentação "
	        TEXT If(nOpcRot == 4,' ',' ') + CRLF  + CRLF +;	//" Esse processo irá realizar a conversão dos métodos de depreciação do bem"##" Esse processo irá cancelar a conversão dos métodos de depreciação do bem"
	       		STR0006 + SN1->N1_CBASE   + CRLF +;	//"Código Base: "
	       		STR0007 + SN1->N1_ITEM    + CRLF +;	//"Item:        "
	       		STR0008 + SN1->N1_CHAPA   + CRLF +;				//"Chapa:       "
	       		STR0009 + SN1->N1_DESCRIC + CRLF;				//"Descrição:   "
	        NEXT {||.T.} ;
	        FINISH {|| .T. } ;
	        PANEL

		//Segunda Pagina
	   CREATE PANEL oWizard ;
	          HEADER  STR0010  ;//" Seleção dos bens"
	          MESSAGE  ;
	          BACK {|| .T. } ;
	          NEXT {|| .T. } ;
	          FINISH {|| AF12VLMkCv(aBens,@nConfirma) } ;
	          PANEL

			AF12MkConv(oWizard:GetPanel(2),aBens,nOpcRot)

	   ACTIVATE WIZARD oWizard CENTERED
	EndIf
	If nConfirma == 1
		AF012GdConv(aBens,nOpcRot)
	EndIf
Endif

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} AF12VLMkCv
Valida os bens marcados para conversao de metodos depreciação
@author Alvaro Camillo Neto
@since 19/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF12VLMkCv(aBens,nConfirma)
Local lRet := .F.
Local nX	:= 1

For nX := 1 to Len(aBens)
	If aBens[nX][1]
		lRet := .T.
		Exit
	EndIf
Next nX

If lRet
	nConfirma := 1
Else
	Help( " ", 1, "AF012CONV",, STR0127, 1, 0 )//"Por favor, marque um tipo de bem "
EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AF12SelConv
Seleção dos registros da tabela SN3 para conversão do método de depreciação.
@author William Matos Gundim Junior
@since 19/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF12SelConv(cBase,cItem,aBens,nOpcRot)
Local aArea := GetArea()
Local aAreaSN3 := SN3->(GetArea())
Local aAreaSN4 := SN4->(GetArea())
Local aAreaSX5 := SX5->(GetArea())
Local cDescMet	:= ""
Local cTipDepr	:= ""
Local lRet := .T.
Local dDtMovto	:= dDataBase
Local cTipoConv	:= '01/10/12' // Tipo que podem ser convertidos
Local cTipoCanc	:= '01/10/12/15'
Local cTipOri		:= ""
Local cDescTipo	:= ""

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
If nOpcRot == OPC_CONVERSAO //Conversão
	// Faz o Seek dos tipo de bens não baixados
	If SN3->(MsSeek( xFilial("SN3") + cBase + cItem ))
		While SN3->(!EOF()) .And. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == xFilial("SN3") + cBase + cItem
			If SN3->N3_BAIXA == '0' .And. (SN3->N3_TIPO $ cTipoConv) .And. Empty(SN3->N3_FIMDEPR)
				cTipDepr := IIF(Empty(SN3->N3_TPDEPR), '1', SN3->N3_TPDEPR)
				cDescMet := AllTrim(GetAdvFVal("SN0","N0_DESC01", xFilial("SN0") +'04'+ cTipDepr ,1))
				SX5->(MsSeek(xFilial("SX5") + "G1"+ SN3->N3_TIPO ))
				cDescTipo :=  Alltrim(SX5->(X5Descri()))
				aAdd(aBens,{.F., SN3->N3_FILIAL, SN3->N3_CBASE, SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cTipDepr,cDescMet,cDescTipo,"",SN3->N3_AQUISIC,""} )
			EndIf
			SN3->(dbSkip())
		EndDo
	EndIf
Else //Cancelamento
	If SN3->(MsSeek( xFilial("SN3") + cBase + cItem ))
		While SN3->(!EOF()) .And. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == xFilial("SN3") + cBase + cItem
			If SN3->N3_BAIXA == '0' .And. (SN3->N3_TIPO $ cTipoCanc) .And.  SN3->N3_AQUISIC >= FirstDay(dDtMovto) .And. SN3->N3_AQUISIC <= LastDay(dDtMovto)
				SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
				//Busca o registro de aquisição do SN3
				If SN4->(dbSeek( xFilial("SN4") + SN3->(N3_CBASE+N3_ITEM+N3_TIPO) + DTOS(SN3->N3_AQUISIC)+ "05" + SN3->N3_SEQ))
					SN4->(dbSetOrder(6)) //N4_FILIAL+N4_IDMOV+N4_OCORR
					// Busca um registro de baixa com o mesmo IDMOV
					If SN4->(dbSeek( xFilial("SN4") + SN4->N4_IDMOV + "01" ) )
						cTipDepr := IIF(Empty(SN3->N3_TPDEPR), '1', SN3->N3_TPDEPR)
						cDescMet := AllTrim(GetAdvFVal("SN0","N0_DESC01", xFilial("SN0") +'04'+ cTipDepr ,1))
						cTipOri := GetAdvFVal("SN3","N3_TPDEPR", xFilial("SN3") + SN4->(N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ) ,8)
						SX5->(MsSeek(xFilial("SX5") + "G1"+ SN3->N3_TIPO ))
						cDescTipo :=  Alltrim(SX5->(X5Descri()))
						aAdd(aBens,{.F., SN3->N3_FILIAL, SN3->N3_CBASE, SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,cTipDepr,cDescMet,cDescTipo,SN4->N4_IDMOV,SN3->N3_AQUISIC,cTipOri} )
					EndIf
				EndIf
			EndIf
			SN3->(dbSkip())
		EndDo
	EndIf
EndIf

If Len(aBens) <= 0
	lRet := .F.
	Help( " ", 1, "AF012CONVE")
EndIf

RestArea(aAreaSX5)
RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AF12MkConv
Tela para seleção dos registros para conversão do método de depreciação.
@author William Matos Gundim Junior
@since 19/01/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF12MkConv(oPanel,aBens,nOpcRot)
Local aArea := GetArea()
Local aAreaSN3  := SN3->(GetArea())
Local aAreaSN4  := SN4->(GetArea())
Local aAreaSX5  := SX5->(GetArea())
Local oCheck  	:= LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
Local oNoCheck	:= LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO
Local aHeader 	:= {"", /*STR0055*/ , /*STR0056*/ , /*STR0057*/ }
Local oMarkBem  := Nil

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
If Len(aBens) > 0
	oMarkBem := TwBrowse():New(005,3,200,100,,aHeader,,oPanel,,,,,,,,,,,,.T.,,.T.,,.F.,,,)
	oMarkBem:SetArray( aBens )
	oMarkBem:bLine := {|| {If(aBens[oMarkBem:nAt,1], oCheck , oNoCheck ),;
	                   aBens[oMarkBem:nAt,5],; // SN3->N3_TIPO
	                   aBens[oMarkBem:nAt,10],; //  cDescTipo - Descrição do tipo de depreciação
	                   aBens[oMarkBem:nAt,09]}} //  cDescMet  - Descrição do método de depreciação
	oMarkBem:BLDBLCLICK := { || IIf(A012vCanCv(aBens[oMarkBem:nAt],nOpcRot,aBens, oMarkBem:nAt),;
							 aBens[ oMarkBem:nAt , 1 ] := !aBens[ oMarkBem:nAt , 1 ], aBens[ oMarkBem:nAt , 1 ] := .F. ) , oMarkBem:Refresh() }
	oMarkBem:Align := CONTROL_ALIGN_ALLCLIENT
EndIf

RestArea(aAreaSX5)
RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aArea)
Return
//-------------------------------------------------------------------
/*/{Protheus.doc}A012vCanCv
Valida o cancelamento da conversão verificando se foi realizada alguma operação após a conversão
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function A012vCanCv(aBensLinha,nOpcRot,aBens, nLinhaAtu)
Local lRet	   := .T.
Local aArea    := GetArea()
Local aAreaSN4 := SN4->(GetArea())
Local cBase    := aBensLinha[3]
Local cItem    := aBensLinha[4]
Local cTipo    := aBensLinha[5]
Local cIdMov   := aBensLinha[11]
Local dDataConv:= aBensLinha[12]

SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
If nOpcRot != OPC_CONVERSAO
	If SN4->(dbSeek( xFilial("SN4") + cBase + cItem + cTipo + DTOS(dDataConv)  ) )
		While SN4->(!EOF()) .And. SN4->(N4_FILIAL + N4_CBASE + N4_ITEM + N4_TIPO ) == xFilial("SN4") + cBase + cItem + cTipo .And. SN4->N4_DATA >= dDataConv
			// Se tiver um movimento com IDMOV diferente da conversão, não será possivel cancelar a conversão
			If Alltrim(SN4->N4_IDMOV) > Alltrim(cIdMov)
				lRet := .F.
				Help( " ", 1, "AF012CANCV")//Help "Não é possível cancelar a conversão, pois existe movimentação após a operação"
				Exit
			EndIf
			SN4->(dbSkip())
		EndDo
	EndIf

	//AVP
	//Caso seja um tipo 10
	//Verifico se o mesmo possui tipo 14 (AVP)
	//Nesta caso nao se pode cancelar a conversao, mas deve ser feita uma nova conversao
	If  cTipo == '10'
		FNF->(DbSetOrder(4))  //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
		If FNF->(MsSeek(xFilial("FNF")+ cBase + cItem + "1"))
			lRet := .F.
			Help( " ", 1, "AF012CANCV")  //"Não é possível cancelar a conversão, pois existe movimentação de AVP para este bem"##"Para desfazer a operação para este tipo de bem, recomenda-se a realização de nova conversão"

		Endif
	Endif

	If lRet .And. aBenslinha[13] == 'A'
		If aBensLinha[5] == '10' .And. len(aBens) > nLinhaAtu
			aBens[nLInhaAtu+1][1] := !aBens[nLInhaAtu+1][1]
		ElseIf aBensLinha[5] == '15' .And. (ValType(aBens[nLInhaAtu-1])=='A')
			aBens[nLInhaAtu-1][1] := !aBens[nLInhaAtu-1][1]
		EndIf
	EndIf
EndIf

RestArea(aAreaSN4)
RestArea(aArea)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012GdConv
Mostra a tela de seleção dos bens  para processamento da conversão
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012GdConv(aBens,nOpcRot)
Local lRet 			:= .T.
Local nOpcA			:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aHeader  		:= {}
Local aCols		    := {}
Local nOpcGet			:= GD_UPDATE							 			   	// GD_INSERT+GD_UPDATE+GD_DELETE					// Opção da MsNewGetDados
Local cLinhaOk     	:= "AF012CvLin()"  										// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk      	:= "AllwaysTrue"									   	// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""			               			  		  		// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze      	:= 000              								   	// Campos estaticos na GetDados.
Local aAlter        	:= {}                                      		// Campos a serem alterados pelo usuario
Local cFieldOk     	:= "AllwaysTrue"						  				   // Funcao executada na validacao do campo
Local cSuperDel       := "AllwaysTrue"          			  			 		// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk          := "AllwaysTrue"    					 				   // Funcao executada para validar a exclusao de uma linha do aCols
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para a MsAdvSize e MsObjSize³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lEnchBar   		:= .F. // Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao    		:= .F. // Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY	    	:= 400 // Altura mínima da janela
Local aSize	   	    := MsAdvSize(lEnchBar, lPadrao, nMinY)
Local aInfo	 		:= {aSize[1],aSize[2],aSize[3],aSize[4],3,3} // Coluna Inicial, Linha Inicial
Local aObjects	  		:= {}
Local aPosObj	   	    := {}
Local aRecNo			:= {}
Local aCampos			:= {}
Local nQuantas	        := AtfMoedas()
Local oDlg		   	    := Nil
Local oPanelSup		:= Nil
Local oPanelMed		:= Nil
Local nX

Private oGetSN3 	:= Nil

cCadastro := STR0011 //"Conversão de Métodos de depreciação"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definição das posições dos objetos na tela³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para os dados Enchoice
aAdd(aObjects,{100,100,.T.,.T.})// Definicoes para a Getdados
aAdd(aObjects,{100,015,.T.,.F.})
aPosObj := MsObjSize(aInfo,aObjects) // Mantem proporcao - Calcula Horizontal


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem do acols da get de modificadores³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

aAdd(aCampos,"N3_TIPO")
aAdd(aCampos,"N3_HISTOR")
aAdd(aCampos,"N3_TPDEORI") // Campo Virtual
aAdd(aCampos,"N3_TPDEPR")
aAdd(aAlter,"N3_TPDEPR")

For nX := 1 to nQuantas
	aAdd(aCampos,"N3_VORIG" + cValToChar(nX))
	aAdd(aCampos,IIf(nX>9,'N3_TXDEP','N3_TXDEPR') + cValToChar(nX))
	aAdd(aAlter,IIf(nX>9,'N3_TXDEP','N3_TXDEPR') + cValToChar(nX))
	aAdd(aCampos,IIf(nX>9,'N3_VRDAC','N3_VRDACM') + cValToChar(nX))
Next nX

aAdd(aCampos,"N3_VMXDEPR")
aAdd(aAlter ,"N3_VMXDEPR")
aAdd(aCampos,"N3_PERDEPR")
aAdd(aAlter ,"N3_PERDEPR")
aAdd(aCampos,"N3_VLSALV1")
aAdd(aAlter ,"N3_VLSALV1")
aAdd(aCampos,"N3_PRODMES")
aAdd(aAlter ,"N3_PRODMES")
aAdd(aCampos,"N3_PRODANO")
aAdd(aAlter ,"N3_PRODANO")
aAdd(aCampos,"N3_CODIND")
aAdd(aAlter ,"N3_CODIND")

aHeader := AF012CvHeader(aCampos)
aCols   := AF012CvAcols( aHeader, aBens, @aRecNo,nOpcRot )

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Definiçãod dos Objetos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oDlg := MSDIALOG():New(aSize[7],aSize[2],aSize[6],aSize[5],cCadastro,,,,,,,,,.T.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Estrutura de Panels³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oPanelSup 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
	oPanelSup:Align 	:= CONTROL_ALIGN_TOP
	oPanelMed 			:= TPanel():New(0,0,'',oDlg,, .T., .T.,, ,100,100,.T.,.T. )
	oPanelMed:Align 	:= CONTROL_ALIGN_ALLCLIENT

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³MsNewGetDados³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nOpcRot == OPC_CONVERSAO
		nOpcGet 		:= GD_UPDATE
		cLinhaOk     	:= "AF012CvLin()"
	Else
		nOpcGet := 0
		cLinhaOk := ""
	EndIf

	oGetSN3	:= 	MsNewGetDados():New(0,0,100,100,nOpcGet,;
	cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,999,cFieldOk,cSuperDel,cDelOk,oPanelMed,aHeader,aCols)
	oGetSN3:obrowse:align:= CONTROL_ALIGN_ALLCLIENT

	oDlg:bInit 		:= EnchoiceBar(oDlg,{||nOpca:=1,If(AF012CvOk(nOpcRot),oDlg:End(),nOpca:=0)},{||oDlg:End()})
	oDlg:lCentered	:= .T.
	oDlg:Activate()

EndIf

If nOpcA == 1
	If nOpcRot == OPC_CONVERSAO
		MsgRun( STR0012,, {||	lRet := AF012CvGrv(oGetSN3,aRecNo) } )//"Processando Conversão..."
	Else
		MsgRun( STR0013,, {||	lRet := AF012CvCan(aRecNo) } )	//"Processando Cancelamento da Conversão..."
	EndIf
EndIf

Return
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CvLin
Realiza a validação de linha da get de conversão de bens
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CvLin(nLinha)
Local lRet 	   := .T.
Local aHeader   := oGetSN3:aHeader
Local aCols	   := oGetSN3:aCols
Local cMoedaAtf := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local nPosSalv  := aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VLSALV1"} )
Local nPosViUtil:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PERDEPR"} )
Local nPosPrdMes:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODMES"} )
Local nPosPrdAno:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODANO"} )
Local nPosTpDepr:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_TPDEPR"} )
Local nPosValMax:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VMXDEPR"} )
Local nMoedaVMax	:= Iif(Val(GetMv("MV_ATFMDMX",.F.," "))>0, Val(GetMv("MV_ATFMDMX")), Val(cMoedaAtf))
Local nPosVlDpMax := aScan(aHeader, {|x| AllTrim(x[2]) == IIf(nMoedaVMax>9,'N3_VRDAC','N3_VRDACM') + cValToChar(nMoedaVMax) } )
Local nPosVlDepSav:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VRDACM1" } )
Local nPosVlOriSav:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VORIG1" })
Local nPosTipo	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_TIPO"})
Local nPosTpSaldo:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_TPSALDO"})
Local nPosCodInd:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_CODIND"})
Local nI := 0

Default nLinha := oGetSN3:nAt

If lRet .And. nPosTpDepr > 0 .And. nPosViUtil > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] == "6" .And. aCols[nLinha][nPosViUtil] == 0
		Help("",1,"AF010VDUTI")  //"O campo de vida util é obrigatório para esse tipo de depreciação "
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosTpDepr > 0 .And. nPosSalv > 0 .And. nPosViUtil > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] == "2" .And. (aCols[nLinha][nPosSalv] == 0 .Or. aCols[nLinha][nPosViUtil] == 0)
		Help("",1,"AF010NOSAL")  //"Os campos de vida util do bem e valor de salvamento sao obrigatorios para esse tipo de depreciação"
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosTpDepr > 0 .And. nPosViUtil > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] == "3" .And. aCols[nLinha][nPosViUtil] == 0
		Help("",1,"AF010VDUTI") //"O campo de vida util é obrigatório para esse tipo de depreciação"
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosTpDepr > 0 .And. nPosPrdMes > 0 .And. nPosPrdAno > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] $ "4/5" .And. (aCols[nLinha][nPosPrdMes] == 0 .OR.  aCols[nLinha][nPosPrdAno] == 0)
		Help("",1,"AF010FPROD") //HELP Para calculo pelo método de produção de ativos é necessário informar o fator de produção.
		lRet := .F.
	EndIf
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] $ "4/5" .And. aCols[nLinha][nPosPrdMes] > aCols[nLinha][nPosPrdAno]
	  	Help(" ", 1, "AF012FPRA")//Help "Para calculo pelo método de produção de ativos a produção do periodo deve ser menor ou igual a produção prevista"
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosTpDepr > 0 .And. nPosValMax > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] == "7" .And. aCols[nLinha][nPosValMax] == 0
		Help("",1,"AF010VMXD") //Para o calculo pelo método Linear com valor maximo de depreciacao é obrigatorio o valor maximo de depreciacao
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosTpDepr > 0 .And. nPosValMax > 0 .And. nPosVlDpMax > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] == "7" .And.  aCols[nLinha][nPosValMax] < aCols[nLinha][nPosVlDpMax]
		Help( " ", 1, "AF012CVVMX" )  //"Para o calculo desse método de depreciação o valor máximo não pode ser menor que o valor depreciação acumulada atual "
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosTpDepr > 0 .And. nPosSalv > 0 .And. nPosVlDepSav > 0 .And. nPosVlOriSav > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTpDepr] == "2" .And. aCols[nLinha][nPosSalv] > aCols[nLinha][nPosVlOriSav] - aCols[nLinha][nPosVlDepSav]
		Help( " ", 1, "AF012CVSALV") // "Para o calculo desse método de depreciação, o valor de salvamento não pode ser maior que o valor contábil do bem "
		lRet := .F.
	EndIf
EndIf

If lRet .And. nPosTpSaldo > 0  .And. nPosTipo > 0 .and. M->N3_TIPO $ "10"
	For nI := 1 To Len(aCols)
		If nI != nLinha
			If (aCols[nI,nPosTipo] == aCols[nLinha,nPosTipo]) .and. (aCols[nI,nPosTpSaldo] == aCols[nLinha,nPosTpSaldo]) .and. !GDDeleted(nI,aHeader,aCols) .and. !GDDeleted(nLinha,aHeader,aCols)
				Help(" ",1,"AF012TP10") //"Tipo de Ativo com Depreciacao Gerencial e Tipo de Saldo duplicado"
		   		lRet := .F.
		   		Exit
			EndIf
		EndIf
	Next nI
EndIf

If lRet .And. nPosTipo > 0 .And. nPosTpDepr > 0 .And. nPosCodInd > 0
	If !aCols[nLinha][Len(aHeader)+1] .And. aCols[nLinha][nPosTipo] == "10" .And. aCols[nLinha][nPosTpDepr] == "A" .And. Empty(aCols[nLinha][nPosCodInd])
		HELP("",1,"AF010CODIN") // "Código do índice não informado."##"Informe o código do índice para bens com tipo de depreciação cálculo por índice."
		lRet := .F.
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CvHeader
Monta o aHeader da getdados de conversão
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function AF012CvHeader(aCampos)
Local aArea	  		:= GetArea()
Local aAreaSX3	  		:= SX3->(GetArea())
Local aHeader 		:= {}
Local nX				:= 0
Local aValid			:= {}
Local cValid			:= ""
Local nPosVal			:= 0

SX3->(dbSetOrder(2)) // X3_CAMPO

aAdd( aValid, { "N3_TIPO"	,'' })
aAdd( aValid, { "N3_TPDEPR"	, "Vazio() .Or. AF012CAVTIP(M->N3_TPDEPR)" })
aAdd( aValid, { "N3_TXDEPR1", ""})
aAdd( aValid, { "N3_VMXDEPR", "Positivo() .And. AF012CVlGr() .And. AF012CVlMax()"    })
aAdd( aValid, { "N3_PERDEPR", "Positivo() .And. AF012CVlGr()"})
aAdd( aValid, { "N3_VLSALV1", "Positivo() .And. AF012CVlGr()"})
aAdd( aValid, { "N3_PRODMES", "Positivo() .And. AF012CVlGr()"})
aAdd( aValid, { "N3_PRODANO", "Positivo() .And. AF012CVlGr()"})

For nX := 1 to Len(aCampos)
	If Alltrim(aCampos[nX]) == "N3_TPDEORI"
		Aadd( aHeader, {"Tipo Deprec Ori", ;//	"Tipo Deprec Ori"
						"N3_TPDEORI",;
						"",;
						30,;
						0,;
						"", 	;
						"€€€€€€€€€€€€€€ ",	;
						"C", 	;
						"",;
						"V" ;
						} )
	Else
		SX3->(dbSeek(aCampos[nX]))

		nPosVal := aScan(aValid,{ |x| Alltrim(x[1]) == Alltrim(aCampos[nX]) } )

		If nPosVal > 0
			cValid := aValid[nPosVal][2]
		Else
			cValid := SX3->X3_VALID
		EndIf

		Aadd( aHeader, {	Rtrim( SX3->(X3Titulo())), ;
						SX3->X3_CAMPO,;
						SX3->X3_PICTURE,;
						SX3->X3_TAMANHO,;
						SX3->X3_DECIMAL,;
						cValid, 	;
						SX3->X3_USADO,	;
						SX3->X3_TIPO, 	;
						SX3->X3_F3,;
						SX3->X3_CONTEXT ;
						} )
	EndIf
Next nX

RestArea(aAreaSX3)
RestArea(aArea)
Return(aHeader)

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CvAcols
Monta o aCols da getdados de conversão
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function AF012CvAcols( aHeader, aBens ,aRecNo ,nOpcRot)
Local nX			:= 0
Local nY			:= 0
Local nCols		    := 0
Local aArea			:= GetArea()
Local aCols			:= {}
Local cTipDepr   := ""
Local cDescMet   := ""
Local cTipOri		:= ""

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

For nY := 1 to Len(aBens)
	If aBens[nY][1] .And. SN3->(DbSeek( aBens[nY][2] + aBens[nY][3] + aBens[nY][4] + aBens[nY][5] + aBens[nY][6] + aBens[nY][7] ))
		cTipOri := IIF(Empty(aBens[nY][13]),'1',aBens[nY][13])
		aAdd(aCols,Array(Len(aHeader)+1))
		nCols ++
		For nX := 1 To Len(aHeader)
			If Alltrim(aHeader[nX][2]) == "N3_TPDEORI"
				cTipDepr := IIF(Empty(SN3->N3_TPDEPR), '1', SN3->N3_TPDEPR)
	 	   		cDescMet := AllTrim(GetAdvFVal("SN0","N0_DESC01", xFilial("SN0") +'04'+ cTipDepr ,1))
				aCols[nCols][nX] := cDescMet
			ElseIf Alltrim(aHeader[nX][2]) $ "N3_TPDEPR/N3_VMXDEPR/N3_PERDEPR/N3_VLSALV1/N3_PRODMES/N3_PRODANO/N3_CODIND" .And. nOpcRot == OPC_CONVERSAO
				aCols[nCols][nX] := CriaVar( aHeader[nX][2] , .T. )
			ElseIf Alltrim(aHeader[nX][2]) == "N3_TPDEPR"
				aCols[nCols][nX] := cTipOri
			Else
				aCols[nCols][nX] := SN3->( FieldGet( FieldPos( aHeader[nX][2]  ) ) )
			EndIf
		Next nX
		aCols[nCols][Len(aHeader)+1] := .F.
		aAdd( aRecNo, SN3->(Recno()) )
		/*
		Inclui os bens de tipo 11 */
		If aBens[nY,5] == "01"
			If SN3->(DbSeek(aBens[nY][2] + aBens[nY][3] + aBens[nY][4] + '11' + "0"))
				While SN3->N3_FILIAL == aBens[nY][2] .And. SN3->N3_CBASE == aBens[nY][3] .And. SN3->N3_ITEM == aBens[nY][4] .And. SN3->N3_TIPO == "11" .And. SN3->N3_BAIXA == "0"
					//Busca o registro de aquisição do SN3
					SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
					If SN4->(dbSeek( xFilial("SN4") + SN3->(N3_CBASE+N3_ITEM+N3_TIPO) + DTOS(SN3->N3_AQUISIC)+ "09" + SN3->N3_SEQ))
						SN4->(dbSetOrder(6)) //N4_FILIAL+N4_IDMOV+N4_OCORR
						// Busca um registro de baixa com o mesmo IDMOV
						If SN4->(dbSeek( xFilial("SN4") + SN4->N4_IDMOV + "01" ) )
							Aadd(aRecno,SN3->(Recno()))
						Endif
					Endif
					SN3->(DBSkip())
				Enddo
			Endif
		Endif
	EndIf
Next nY

RestArea( aArea )
Return aCols

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CvGrv
Realiza a conversão, realizando a baixa de um tipo e criando o novo
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CvGrv(oGetSN3,aRecNo)
Local aStru		:= {}
Local aDados		:= {}
Local aArea		:= GetArea()
Local aAreaSN3		:= SN3->(GetArea())
Local nQtdOrig		:= IIF(SN1->N1_QUANTD == 0,1,SN1->N1_QUANTD)
Local aRecAtf 		:= {}
Local cIDMOV		:= ""
Local cTpSaldo		:= ""
Local cOcorr 		:= ""
Local aDadosComp    := {}
Local aCols 	    := oGetSN3:aCols
Local aHeader 		:= oGetSN3:aHeader
Local nCampo 		:= 0
Local nLinha 		:= 0
Local dDtMovto		:= dDataBase
Local cPadrao	    := ""
Local lMostra	    := .T.
Local aRec14Bxd   := {} //Arrays de recnos dos registros do tipo 14 que forma incluidos ou baixados
Local aRec14New   := {}
Local aRecCtb     := {}
Local lMargem     := AFMrgAtf() //Verifica implementacao da Margem Gerencial
Local lAtClDepr   := .F. // Verificação da classificação de Ativo se sofre depreciação
Local cMoedaAtf := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local cPropbx		:= Iif(SuperGetMv('MV_ATFDPBX')=="1", "1", "0")
Local cTypesNM		:= IIF(lIsRussia,"," + AtfNValMod({1,2}, ","),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable model

Private lMsErroAuto := .F.

aStru := SN3->(dbStruct())
dbSelectArea("SN3")
dbSetOrder( 1 )

pergunte("AFA012",.F.)
AF012PerAut()
lMostra 	:= (MV_PAR01 == 1 .And. !IsBlind())
lAglut		:= MV_PAR06 == 1

//AVP
//Inclui os bens do tipo 14 no acols
AF012CV14(aCols,aHeader,aRecNo)


//MRG
//Inclui os bens do tipo 15 no acols
If lMargem
	AF012CV15(aCols,aHeader,aRecNo)
Endif

/* Inclui os bens do tipo 11 no acols */
AF012CV11(aCols,aHeader,aRecNo)

For nLinha := 1 to Len(aCols)
	SN3->(dbGoto(aRecNo[nLinha]))
	dDinDepr := SN3->N3_DINDEPR
	cIDMOV := ""

	//Salva os dados do SN3 atual
	For nCampo := 1 to Len(aStru)
		AAdd(aDados,{ aStru[nCampo,1] , SN3->&(aStru[nCampo,1]) })
	Next

	//AVP
	//Inclui os bens do tipo 14
	If SN3->N3_TIPO == '14'
		aAdd(aRec14Bxd,SN3->(RECNO()))
	Endif

	aCab :={ 	{"FN6_FILIAL"	,xFilial("SN3")		,NIL},;
				{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
				{"FN6_CITEM"	,SN3->N3_ITEM		,NIL},;
				{"FN6_MOTIVO"	,"13"				,NIL},;
				{"FN6_QTDATU"	,nQtdOrig			,NIL},;
				{"FN6_BAIXA"	, 100			    ,NIL},;
				{"FN6_QTDBX"	,0					,NIL},;
				{"FN6_DTBAIX"	,dDatabase			,NIL},;
				{"FN6_NUMNF"	,"" 				,NIL},;
				{"FN6_SERIE"	,""					,NIL},;
				{"FN6_PERCBX"	,100			    ,NIL},;
				{"FN6_DEPREC"	,cPropbx			,NIL} }


	aAtivo:={ 	{"N3_FILIAL"	, xFilial("SN3")	,NIL},;
				{"N3_CBASE"	    , SN3->N3_CBASE	    ,NIL},;
				{"N3_ITEM"		, SN3->N3_ITEM		,NIL},;
				{"N3_TIPO"		, SN3->N3_TIPO		,NIL},;
				{"N3_BAIXA"     , SN3->N3_BAIXA	    ,NIL},;
				{"N3_TPSALDO"	, SN3->N3_TPSALDO	,NIL} }


	MsExecAuto({|a,b,c,d,e|ATFA036(a,b,c,d,e)},aCab,aAtivo,3,,.F.)
	If lMsErroAuto
		MostraErro()
	Else
		SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR+N4_SEQ
		If SN4->(dbSeek( xFilial("SN4") + SN3->(N3_CBASE+N3_ITEM+N3_TIPO) + DTOS(dDatabase)+ "01" + SN3->N3_SEQ))
			cIDMOV := SN4->N4_IDMOV
		EndIf
		//Cria o novo item no SN3 com as mesmas informações do N3 original, exceto pelas informações da grid
		cSeq	 := AtfxUltSeq(SN3->N3_CBASE,SN3->N3_ITEM)
		cSeq := Soma1(AllTrim(cSeq))
		Reclock("SN3",.T.)
		For nCampo := 1 to Len(aDados)
			SN3->(&(aDados[nCampo][1])) := aDados[nCampo][2]
		Next nCampo

		SN3->N3_DINDEPR	:= dDinDepr
		SN3->N3_AQUISIC	:= dDtMovto
		SN3->N3_SEQ		:= cSeq
		SN3->N3_FILORIG	:= cFilAnt

		For nCampo := 1 To Len( aHeader )
			If aHeader[ nCampo, 10 ] <> "V"
				FieldPut( FieldPos( aHeader[ nCampo, 2 ] ), aCols[ nLinha, nCampo ] )
			Endif
		Next nCampo

		MsUnlock()

		//AVP
		//Inclui AVP para a nova sequencia.
		If SN3->N3_TIPO == '14'
			aAdd(aRec14New,SN3->(RECNO()))
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Movimento de Aquisição³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cOcorr 	    := If(SN3->N3_TIPO == "11","09","05")
		aDadosComp := ATFXCompl( 0 , &(If(Val(cMoedaAtf) > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
		aValorMoed := AtfMultMoe(,,{|x| SN3->&("N3_VORIG" + Alltrim(Str(x)) ) })
		cTpSaldo := SN3->N3_TPSALDO
		ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"1",SN1->N1_QUANTD,cTpSaldo,,aValorMoed,aDadosComp,,Inclui,/*lValSN1*/,/*lClassifica*/,/*lOnOff*/,/*cPadrao*/,"ATFA012"/*cOrigem*/)

		Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza arquivo movimenta‡„o (Corre‡„o)                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SN3->N3_VRCACM1 > 0
			cOcorr 	   := "07"
			aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
			aValorMoed   := AtfMultMoe(,,{|x| 0})
			aValorMoed[1] := Round(SN3->N3_VRCACM1 , X3Decimal("N4_VLROC1") )
			cTpSaldo := SN3->N3_TPSALDO
			ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"1",0,cTpSaldo,,aValorMoed,aDadosComp,,,/*lValSN1*/,/*lClassifica*/,/*lOnOff*/,/*cPadrao*/,"ATFA012"/*cOrigem*/)

			Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
		EndIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza arquivo movimenta‡„o (Corre‡„o)                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SN3->N3_VRCACM1 > 0
			cOcorr 	   := "07"
			aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
			aValorMoed   := AtfMultMoe(,,{|x| 0})
			aValorMoed[1] := Round(SN3->N3_VRCACM1 , X3Decimal("N4_VLROC1") )
			cTpSaldo := SN3->N3_TPSALDO
			ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"2",0,cTpSaldo,,aValorMoed,aDadosComp,,,/*lValSN1*/,/*lClassifica*/,/*lOnOff*/,/*cPadrao*/,"ATFA012"/*cOrigem*/)

			Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza arquivo Movimenta‡”es (Corre‡„o da Deprecia‡„o)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SN3->N3_VRCDA1 > 0
			cOcorr 	   := "08"
			aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
			aValorMoed   := AtfMultMoe(,,{|x| 0})
			aValorMoed[1] := Round(SN3->N3_VRCDA1 , X3Decimal("N4_VLROC1") )
			cTpSaldo := SN3->N3_TPSALDO
			ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"5",0,cTpSaldo,,aValorMoed,aDadosComp,,,/*lValSN1*/,/*lClassifica*/,/*lOnOff*/,/*cPadrao*/,"ATFA012"/*cOrigem*/)

			Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza arquivo Movimenta‡”es (Deprecia‡„o)                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If &('SN3->N3_VRDACM'+cMoedaAtf) > 0
			cOcorr 	   := IIF( SN3->N3_TIPO $ ("10,12,15,50,51,52,53,54" + cTypesNM), "20", IIF(SN3->N3_TIPO == "07","10",IIF(SN3->N3_TIPO=="08","12",IIF(SN3->N3_TIPO == "09","11","06"))))
			aDadosComp := ATFXCompl( SN3->N3_VRDACM1 / &(If(Val(cMoedaAtf)>9,'SN3->N3_VRDAC','SN3->N3_VRDACM')+cMoedaAtf) , &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
			aValorMoed := AtfMultMoe(,,{|x| SN3->&(IIf(x>9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })
			cTpSaldo := SN3->N3_TPSALDO
			ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"4",0,cTpSaldo,,aValorMoed,aDadosComp,,Inclui,/*lValSN1*/,/*lClassifica*/,/*lOnOff*/,/*cPadrao*/,"ATFA012"/*cOrigem*/)

			Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza arquivo Movimenta‡”es (Corre‡„o da Deprecia‡„o)               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SN3->N3_VRCDA1 > 0
			cOcorr 	   := "08"
			aDadosComp := ATFXCompl( 0 , &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
			aValorMoed := AtfMultMoe(,,{|x| SN3->&(IIf(x>9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })
			cTpSaldo := SN3->N3_TPSALDO
			ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"4",0,cTpSaldo,,aValorMoed,aDadosComp,,Inclui,/*lValSN1*/,/*lClassifica*/,/*lOnOff*/,/*cPadrao*/,"ATFA012"/*cOrigem*/)

			Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
		EndIf

		//Grava os Saldos

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava no SN5 o tipo da Imobiliza‡„o.                    ³
		//³ Se for imobiliza‡„o normal             = 1              ³
		//³ Se                  Reavali‡„o         = 3              ³
		//³ Se                  Capital            = A              ³
		//³ Se                  Capital Prejuizo   = B              ³
		//³ Se Baixa Capital                       = C              ³
		//³ Se ""               Capital Prejuizo   = D              ³
		//³ Se ""               Correcao de Capital= P              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lAtClDepr := AtClssVer(SN1->N1_PATRIM)
		IF lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)
			cTipoImob := Iif(SN3->N3_TIPO$"02/05","3","1")
			cTipoCorr := "6"
		Elseif SN1->N1_PATRIM $ "CSA"
			cTipoImob := "A"
			cTipoCorr := "O"
		Else
			cTipoImob := "B"
			cTipoCorr := "6"
		End

		If !(SN3->N3_TIPO $ "07,08,09")
			// *******************************
			// Controle de multiplas moedas  *
			// *******************************
			aValorMoed := AtfMultMoe("SN3","N3_VORIG")
			ATFSaldo(	SN3->N3_CCONTAB,dDtMovto,cTipoImob,SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3,;
				SN3->N3_VORIG4,SN3->N3_VORIG5,"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
			// *******************************
			// Controle de multiplas moedas  *
			// *******************************
			aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
			ATFSaldo(	SN3->N3_CCONTAB,dDtMovto,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
				"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
		Endif
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
		ATFSaldo(	SN3->N3_CCORREC,dDtMovto,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
			"+",,SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed )

		lAtClDepr := AtClssVer(SN1->N1_PATRIM)
		If lAtClDepr .OR. EMPTY(SN1->N1_PATRIM)

			cTipoImob := If( !SN3->N3_TIPO $ ("08,09,10,12,50,51,52,53,54" + cTypesNM), "4", If(SN3->N3_TIPO $ "10,12,50,51,52,53,54","Y",If(SN3->N3_TIPO=="09","L","K")))
			// *******************************
			// Controle de multiplas moedas  *
			// *******************************
			aValorMoed := AtfMultMoe("SN3","N3_VRDACM")
			ATFSaldo(	SN3->N3_CCDEPR ,dDtMovto,cTipoImob, SN3->N3_VRDACM1,SN3->N3_VRDACM2  ,;
				SN3->N3_VRDACM3,SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
			// *******************************
			// Controle de multiplas moedas  *
			// *******************************
			aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCDA1,0) })
			ATFSaldo(	SN3->N3_CCDEPR ,dDtMovto,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
				"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
			// *******************************
			// Controle de multiplas moedas  *
			// *******************************
			aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCDA1,0) })
			ATFSaldo(	SN3->N3_CDESP  ,dDtMovto,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
				"+",,SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed )
		Endif

		// Contabiliza a criação do novo tipo SN3
		cPadrao := "80C"
		If __nHdlPrv > 0 .And. VerPadrao(cPadrao)
			__nTotal += DetProva(__nHdlPrv,cPadrao,AllTrim("ATFA012"),__cLoteAtf)
		Endif
	Endif



Next nLinha


//AVP


//Gravacao do AVP da Conversao do metodo de depreciacao
If Len(aRec14Bxd) > 0 .and. Len(aRec14New) > 0
	aRecCtb :=	AF012AVPCV(aRec14Bxd,aRec14New,cIdMov)
Endif

//Contabilizacao do AVP da Conversao do metodo de depreciacao
If Len(aRecCtb) > 0
	//Contabiliza os movimentos de AVP gerados pela baixa
	AF450CtbAvp (aRecCTB,.F.,@__nTotal,@__nHdlPrv,@__cArqCtb,"ATFA010")
	aRecCtb := {}
Endif


If __nHdlPrv > 0 .And. ( __nTotal > 0 ) .And. __lCTBFIM
	RodaProva(__nHdlPrv, __nTotal)
	cA100Incl(__cArqCtb, __nHdlPrv,3,__cLoteAtf,lMostra,lAglut)
Endif

//integracao com modulo de planejamento e controle orcamentario
If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
	Atf_IntPco(aRecAtf)
EndIf

RestArea(aAreaSN3)
RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CV14
Inclui o Tipo 14 para conversao
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------

Function AF012CV14(aCols,aHeader,aRecNo)
Local nX 		:= 0
Local nY 		:= 0
Local aCols14	:= {}		//Acols dos Tipos 14
Local aTip14	:= {}		//Auxiliar do Acols
Local aRecno14	:= {}		//ARecno dos Tipos 14
Local aArea		:= GetArea()
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_ITEM/N3_SEQ/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON/N3_VMXDEPR/N3_VLSALV1"
local aCampos	:= STRTOKARR(cCampos,"/")
Local aPosCpos	:= {}
Local nPosVlr01:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VORIG1" } )
Local nPosVMax := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VMXDEPR" } )
Local nPosVSav := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VLSALV1" } )
Local nPosTipo := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" } )
Local nPropM 	:= 0
Local nPropS 	:= 0
Local nQuantas := AtfMoedas()
Local aPosVOrigX:= AtfMultPos(aHeader,"N3_VORIG")
//Monto array com posicao dos campos a serem atualizados no Tipo14
For nX := 1 to Len(aCampos)
	aadd(aPosCpos,Ascan(aHeader	, {|e| Alltrim(e[2]) == Alltrim(aCampos[nX]) } ))
Next

//Gero a linha de Tipo 14
For nY := 1 to Len(aCols)

	//Caso seja um bem do tipo 10 esteja selecionado para conversao
	If aCols[nY][nPosTipo] == '10'

		//Posiciono no SN3 - Tipo 10
		SN3->(dbGoto(aRecno[nY]))

		//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
		nPropM 	:= aCols[nY][nPosVMax] / aCols[nY][nPosVlr01]
		nPropS 	:= aCols[nY][nPosVSav] / aCols[nY][nPosVlr01]

		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		//Acho o TIPO 14 referente ao tipo 10
		If SN3->(MsSeek( xFilial("SN3")+SN3->(N3_CBASE+N3_ITEM) + '14' + "0" + SN3->N3_TPSALDO))

			//Copio os dados do Tipo 10
			aTip14 := aClone(aCols[nY])

			//Atualizo os dados do tipo 14
			For nX := 1 to Len(aCampos)
				If aPosCpos[nX] > 0
					aTip14[aPosCpos[nX]] := &(allTrim(aCampos[nX]))
				Endif
			Next

			//Atualizo os dados de valores do tipo 14
			For nX := 1 to nQuantas
				If aPosVOrigX[nX] > 0
					aTip14[aPosVOrigX[nX]] := &("N3_VORIG" + AllTrim(Str(nX)))
				Endif
			Next

			//Atualizo os valores de valor maximo de depreciacao e valor de salvamento
			//Mas apenas se os mesmos foram alterados
			If aTip14[nPosVMax] > 0
				aTip14[nPosVMax] := aTip14[nPosVlr01] * If(nPropM > 0, nPropM, 1)
			Endif
			If aTip14[nPosVSav] > 0
				aTip14[nPosVSav] := aTip14[nPosVlr01] * If(nPropS > 0, nPropS, 1)
			Endif

			//Guardo os dados para repassar ao array de bens
			aAdd(aCols14, aTip14)
			aAdd(aRecno14, SN3->(Recno()))

		Endif
	Endif

Next

//Adiciono os Bens do tipo 14 no aCols
If Len(aCols14) > 0
	For nY := 1 to Len(aCols14)
		aadd(aCols , aCols14[nY])
		aadd(aRecno, aRecno14[nY])
	Next
Endif

RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CV15
Inclui o Tipo 15 para conversao
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CV15(aCols,aHeader,aRecNo)
Local nX 		:= 0
Local nY 		:= 0
Local aCols15	:= {}		//Acols dos Tipos 15
Local aTip15	:= {}		//Auxiliar do Acols
Local aRecno15	:= {}		//ARecno dos Tipos 15
Local aArea		:= GetArea()
Local cCampos	:= "N3_TIPO|N3_HISTOR|N3_ITEM|N3_SEQ|N3_CCONTAB|N3_CUSTBEM|N3_SUBCCON|N3_CLVLCON|N3_VMXDEPR|N3_VLSALV1"
local aCampos	:= STRTOKARR(cCampos,"|")
Local aPosCpos	:= {}
Local nPosVlr01:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VORIG1"  })
Local nPosVMax := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VMXDEPR" })
Local nPosVSav := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VLSALV1" })
Local nPosTipo := aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" 	})
Local nPropM 	:= 0
Local nPropS 	:= 0
// *******************************
// Controle de multiplas moedas  *
// *******************************
Local nQuantas := AtfMoedas()
Local aPosVOrigX := AtfMultPos(aHeader,"N3_VORIG")

//Monto array com posicao dos campos a serem atualizados no Tipo14
For nX := 1 to Len(aCampos)
	aAdd(aPosCpos,Ascan(aHeader	, {|e| Alltrim(e[2]) == Alltrim(aCampos[nX]) } ))
Next

//Gero a linha de Tipo 15
For nY := 1 to Len(aCols)

	//Caso seja um bem do tipo 10 esteja selecionado para conversao
	If aCols[nY][nPosTipo] == '10'

		//Posiciono no SN3 - Tipo 10
		SN3->(dbGoto(aRecno[nY]))

		//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
		nPropM 	:= aCols[nY][nPosVMax] / aCols[nY][nPosVlr01]
		nPropS 	:= aCols[nY][nPosVSav] / aCols[nY][nPosVlr01]

		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		//Acho o TIPO 14 referente ao tipo 10
		If SN3->(MsSeek( xFilial("SN3")+SN3->(N3_CBASE+N3_ITEM)+'15'+"0"+SN3->N3_TPSALDO))

			//Copio os dados do Tipo 10
			aTip15 := aClone(aCols[nY])

			//Atualizo os dados do tipo 15
			For nX := 1 to Len(aCampos)
				If aPosCpos[nX] > 0
					aTip15[aPosCpos[nX]] := &(allTrim(aCampos[nX]))
				Endif
			Next

			//Atualizo os dados de valores do tipo 15
			For nX := 1 to nQuantas
				If aPosVOrigX[nX] > 0
					aTip15[aPosVOrigX[nX]] := &("N3_VORIG"+AllTrim(Str(nX)))
				Endif
			Next

			//Atualizo os valores de valor maximo de depreciacao e valor de salvamento
			//Mas apenas se os mesmos foram alterados
			If aTip15[nPosVMax] > 0
				aTip15[nPosVMax] := aTip15[nPosVlr01] * If(nPropM > 0, nPropM, 1)
			Endif
			If aTip15[nPosVSav] > 0
				aTip15[nPosVSav] := aTip15[nPosVlr01] * If(nPropS > 0, nPropS, 1)
			Endif

			//Guardo os dados para repassar ao array de bens
			aadd(aCols15, aTip15)
			aadd(aRecno15, SN3->(RECNO()))

		Endif
	Endif

Next

//Adiciono os Bens do tipo 15 no aCols
If Len(aCols15) > 0
	For nY := 1 to Len(aCols15)
		aadd(aCols , aCols15[nY])
		aadd(aRecno, aRecno15[nY])
	Next
Endif

RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CV11
Inclui o Tipo 11 para conversao
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CV11(aCols,aHeader,aRecNo)
Local nX		:= 0
Local nY		:= 0
Local aCols11	:= {}		//Acols dos Tipos 11
Local aTip11	:= {}		//Auxiliar do Acols
Local aRecno11	:= {}		//ARecno dos Tipos 11
Local aArea	:= GetArea()
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_ITEM/N3_SEQ/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON/N3_VMXDEPR/N3_VLSALV1"
local aCampos	:= STRTOKARR(cCampos,"/")
Local aPosCpos	:= {}
Local nPosVlr01:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VORIG1" } )
Local nPosVMax	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VMXDEPR" } )
Local nPosVSav	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_VLSALV1" } )
Local nPosTipo	:= aScan( aHeader, { |x| AllTrim( x[2] ) == "N3_TIPO" } )
Local nPropM	:= 0
Local nPropS	:= 0
Local cFilSN3	:= ""
Local cBase	:= ""
Local cItem	:= ""
Local cTpSaldo	:= ""
Local nQuantas	:= AtfMoedas()
Local aPosVOrigX	:= AtfMultPos(aHeader,"N3_VORIG")

//Monto array com posicao dos campos a serem atualizados no Tipo11
For nX := 1 to Len(aCampos)
	aadd(aPosCpos,Ascan(aHeader	, {|e| Alltrim(e[2]) == Alltrim(aCampos[nX]) } ))
Next

//Gero a linha de Tipo 11
cFilSN3 := xFilial("SN3")
For nY := 1 to Len(aCols)

	//Caso seja um bem do tipo 01 esteja selecionado para conversao
	If aCols[nY][nPosTipo] == '01'

		//Posiciono no SN3 - Tipo 11
		SN3->(dbGoto(aRecno[nY]))

		//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
		nPropM 	:= aCols[nY][nPosVMax] / aCols[nY][nPosVlr01]
		nPropS 	:= aCols[nY][nPosVSav] / aCols[nY][nPosVlr01]

		SN3->(dbSetOrder(11)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO+N3_SEQ+N3_SEQREAV
		//Acho o TIPO 11 referente ao tipo 01
		cBase := SN3->N3_CBASE
		cItem := SN3->N3_ITEM
		cTpSaldo := SN3->N3_TPSALDO
		If SN3->(DbSeek( cFilSN3 + cBase + cItem + '11' + "0" + cTpSaldo))
			While SN3->N3_FILIAL == cFilSN3 .And. SN3->N3_CBASE == cBase .And. SN3->N3_ITEM == cItem .And. SN3->N3_TIPO == "11" .And. SN3->N3_BAIXA == "0"
				//Copio os dados do Tipo 01
				aTip11 := aClone(aCols[nY])

				//Atualizo os dados do tipo 11
				For nX := 1 to Len(aCampos)
					If aPosCpos[nX] > 0
						aTip11[aPosCpos[nX]] := &(allTrim(aCampos[nX]))
					Endif
				Next

				//Atualizo os dados de valores do tipo 11
				For nX := 1 to nQuantas
					If aPosVOrigX[nX] > 0
						aTip11[aPosVOrigX[nX]] := &("N3_VORIG" + AllTrim(Str(nX)))
					Endif
				Next

				//Atualizo os valores de valor maximo de depreciacao e valor de salvamento
				aTip11[nPosVMax] := aTip11[nPosVlr01] * nPropM
				aTip11[nPosVSav] := aTip11[nPosVlr01] * nPropS

				//Guardo os dados para repassar ao array de bens
				aAdd(aCols11, aTip11)
				aAdd(aRecno11, SN3->(RECNO()))
				SN3->(DbSkip())
			Enddo
		Endif
	Endif

Next

//Adiciono os Bens do tipo 11 no aCols
If Len(aCols11) > 0
	For nY := 1 to Len(aCols11)
		aadd(aCols , aCols11[nY])
		aadd(aRecno, aRecno11[nY])
	Next
Endif

RestArea(aArea)

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AVPCV
Gera a constituicao de AVP para conversao de metodo de depreciacao
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AVPCV(aRec14Bxd,aRec14New,cIdMov)
Local nX			:= 0
Local nValAvp		:= 0
Local nValVp		:= 0
Local aRecFNF		:= {}
Local aRecCtb		:= {}
Local aArea		:= GetArea()
Local cIdProcAVP	:= GetSxeNum('FNF','FNF_IDPROC','FNF_IDPROC'+cEmpAnt,3)

//AVP
//Gero baixas de AVP - Conversao de metodo de depreciacao
For nX := 1 to Len(aRec14Bxd)

	SN3->(dbGoto(aRec14Bxd[nX]))

	//Posiciono no SN1
	If SN1->(MsSeek( xFilial("SN1") + SN3->( N3_CBASE + N3_ITEM ) ))

		//Posiciono tabela FNF no registro de constituicao ativo
		dbSelectArea("FNF")
		FNF->(dbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
		If MsSeek(xFilial("FNF")+SN3->(N3_CBASE+N3_ITEM)+"1"+"1")

			//Obtenho os valores
			nValAvp	:= FNF->(FNF_VALOR - FNF_ACMAVP)
			nValVP		:= FNF->FNF_AVPVLP
			aAdd(aRecFNF,{FNF->FNF_TPSALD,FNF->(RECNO()),nValVP})

			//Gravo a realizacao por transferencia
			AfGrvAvp(cFilAnt,"9",dDataBase,FNF->FNF_CBASE,FNF->FNF_ITEM,FNF->FNF_TIPO,FNF->FNF_TPSALD,SN3->N3_BAIXA,FNF->FNF_SEQ,,nValAvp,.F.,,,,SN3->(RECNO()),cIdProcAVP,aRecCTB,,cIdMov,nValVP)

		Endif
	Endif
Next


//AVP
//Gero constituicao de AVP
//Novos registros gerados pela Conversao de metodo de depreciacao
For nX := 1 to Len(aRec14New)

	//Posiciono no novo SN3 Tipo 14
	SN3->(dbGoto(aRec14New[nX]))

	//Posiciono no SN1
	If SN1->(MsSeek( xFilial("SN1") + SN3->( N3_CBASE + N3_ITEM ) ))

		nPos := Ascan(aRecFNF	, {|e| Alltrim(e[1]) == SN3->N3_TPSALDO } )

		If nPos > 0
			//Gravo o movimento de constituicao do AVP pela inclusao do bem na filial destino
			AfGrvAvp(cFilAnt,"1",dDatabase,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,;
				SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,SN3->N3_VORIG1,.F.,,,,SN3->(RECNO()),;
				cIdProcAVP,aRecCtb,/*lBxTotal*/,@cIdMov,aRecFNF[nX,3],/*cRotina*/,/*cArquivo*/,;
				aRecFNF[nX,2],.T.)
		Endif

	Endif

Next

//Confirmo o ID do processo nas tabelas de controle
ConfirmSX8()

RestArea(aArea)

Return aRecCtb

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CvCan
Realiza o cancelamento da conversão, realizando o cancelamento da baixa e excluindo o tipo atual
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CvCan(aRecNo)
Local aArea			:= GetArea()
Local aAreaSN3		:= SN3->(GetArea())
Local aAreaSN4		:= SN4->(GetArea())
Local nLinha 	:= 0
Local lCtbPrim	:= .T.
Local cPadrao	:= ""
Local cBase	:= ""
Local cItem	:= ""
Local cTipo	:= ""
Local cSeq	:= ""
Local nRecSn3	:= 0
Local lMostra	:= .T.
Local lRet		:= .T.

Private lMsErroAuto := .F.

pergunte("AFA012",.F.)
AF012PerAut()

lMostra	:= MV_PAR01 == 1
lAglut		:= MV_PAR06 == 1

SN3->(dbSetOrder(8)) //N3_FILIAL+N3_CODBAIX+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ


For nLinha := 1 to Len(aRecNo)
	Begin TRANSACTION

		SN3->(dbGoto(aRecNo[nLinha]))
		cBase	:= SN3->N3_CBASE
		cItem	:= SN3->N3_ITEM
		cTipo	:= SN3->N3_TIPO
		cSeq	:= SN3->N3_SEQ
		cIdMov := GetAdvFVal("SN4","N4_IDMOV", xFilial("SN4") + SN3->(N3_CBASE+N3_ITEM+N3_TIPO) + DTOS(SN3->N3_AQUISIC)+ If(SN3->N3_TIPO == "11","09","05") + SN3->N3_SEQ ,1)
		cPadrao := "80D"

		If __nHdlPrv <= 0
			lCtbPrim := .F.
		EndIf

		If lCtbPrim .And. VerPadrao(cPadrao)
			__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
			lCtbPrim := .F.
		EndIf

		If __nHdlPrv > 0 .And. VerPadrao(cPadrao)
			__nTotal += DetProva(__nHdlPrv,cPadrao,AllTrim("ATFA012"),__cLoteAtf)
		Endif

		//Exclui os movimentos do Bem
		SN4->(dbSetOrder(5)) //N4_FILIAL+N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ
		If SN4->(dbSeek(xFilial("SN4") + SN3->(N3_CODBAIX+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ) ))
			While SN4->(!EOF()) .And. SN4->(N4_FILIAL+N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ) == xFilial("SN4") + SN3->(N3_CODBAIX+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ)
				RecLock("SN4",.F.)
				SN4->(dbDelete())
				MsUnLock()
				SN4->(dbSkip())
			EndDo
		EndIf

		//Exclui o SN3
		RecLock("SN3",.F.)
		SN3->(dbDelete())
		MsUnLock()

		//Busco o Movimento de Baixa para cancelar a Baixa
		SN4->(dbSetOrder(6)) //N4_FILIAL+N4_IDMOV+N4_OCORR
		If SN4->(dbSeek( xFilial("SN4") + cIdMov + "01" ))
			If SN3->(dbSeek(xFilial("SN3") + SN4->(N4_CODBAIX+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQ) ))
				nRecSn3 := SN3->(Recno())
			EndIf
		EndIf

		//Cancela a Baixa do Bem
		If nRecSn3 > 0
			SN3->(dbGoto(nRecSn3))

			aCab :={ 	{"FN6_FILIAL"	,xFilial("SN3")		,NIL},;
				{"FN6_CBASE"	,SN3->N3_CBASE		,NIL},;
				{"FN6_CITEM"	,SN3->N3_ITEM			,NIL},;
				{"FN6_MOTIVO"	,"13"					,NIL},;
				{"FN6_DEPREC"	,'0'					,NIL} }

			aAtivo:={ {"N3_FILIAL"	, xFilial("SN3")		,NIL},;
				{"N3_CBASE"	, SN3->N3_CBASE	,NIL},;
				{"N3_ITEM"		, SN3->N3_ITEM		,NIL},;
				{"N3_TIPO"		, SN3->N3_TIPO		,NIL},;
				{"N3_BAIXA"   , SN3->N3_BAIXA	,NIL},;
				{"N3_TPSALDO"	, SN3->N3_TPSALDO	,NIL},;
				{"N3_SEQREAV"	, SN3->N3_SEQREAV	,NIL},;
				{"N3_SEQ"		, SN3->N3_SEQ	,NIL}}


			MsExecAuto({|a,b,c,d,e|ATFA036(a,b,c,d,e)},aCab,aAtivo,5,,.F.)
			If lMsErroAuto
				Help( " ", 1, "AF012CONV" )
				lRet := .F.
				DisarmTransaction()
			EndIf
		Else
			Help( " ", 1, "AF012CONV" )
			lRet := .F.
			DisarmTransaction()
		EndIf

	End Transaction

	If !lRet //Quando a transacao for desarmada sair do FOR
		Exit
	EndIf
Next nLinha

If lRet
	If __nHdlPrv > 0 .And. ( __nTotal > 0 ) .And. __lCTBFIM
		RodaProva(__nHdlPrv, __nTotal)
		cA100Incl(__cArqCtb,__nHdlPrv,3,__cLoteAtf,lMostra,lAglut)
	Endif
EndIf

RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}Af012BlqDesb
Bloqueia/Desbloqueia bens, atualizando campo N1_STATUS
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function Af012BlqDesb()
Local cAliasTrb	:= GetNextAlias()
Local aParam		:= {}
Local cBemDe		:= Space(Len(SN1->N1_CBASE))
Local cBemAte		:= cBemDe
Local cItemDe		:= Space(Len(SN1->N1_ITEM))
Local cItemAte	:= cItemDe
Local cGrupoDe	:= Space(Len(SN1->N1_GRUPO))
Local cGrupoAte	:= cGrupoDe
Local dAquisDe	:= Ctod("")
Local dAquisAte	:= Ctod("")
Local aTipos		:= {"1-" + STR0093 , "2-" + STR0094 } //"Desbloqueia"##"Bloqueia"
Local cWhere		:= ""
Local cMsg			:= ""
Local lRet			:= .T.
Local lAutomato	:= IsBlind()

//AVP2
//Verifica se o bem foi gerado por AVP Parcela
If SN1->N1_PATRIM = 'V' .AND. Alltrim(SN1->N1_ORIGEM) == 'ATFA460'
	Help(" ",1,"AF012460BQ") //Help 'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo não poderá ser alterado'
	lRet  := .F.
Endif

If lRet

	SaveInter()
	cCadastro := STR0014 //"Parâmetros"
	If !lAutomato
		If ParamBox( {		{ 1, STR0015, 	cBemDe  	,"@!",".T." ,"SN1",".T.",55,.F.	},; //"Do Código do Bem"
			{ 1, STR0016, 	cBemAte	,"@!",".T.","SN1",".T.",55,.T.	},; //"Até o Código do Bem"
			{ 1, STR0017, 	cItemDe	,"",".T.","",".T.",20,.F.		},; //"Do Item"
			{ 1, STR0018, 	cItemAte	,"",".T.","",".T.",20,.T.		},; //"Até o Item"
			{ 1, STR0019,	cGrupoDe	,"@!",".T.","SNG",".T.",25,.F.	},; //"Do Grupo"
			{ 1, STR0020,	cGrupoAte	,"@!",".T.","SNG",".T.",25,.T.	},; //"Até o Grupo"
			{ 1, STR0021,	dAquisDe	,"",".T.","",".T.",55,.F.		},; //"Da Data de Aquisição"
			{ 1, STR0022,	dAquisAte	,"",".T.","",".T.",55,.T.		},; //"Até a Data de Aquisição"
			{ 2, STR0023,	1			,aTipos,60,,.T.					}},STR0023,aParam,,,,,,,,.F.,.T.) //"Bloqueia/Desbloq"###"Bloqueio/Desbloqueio"

			// Ajusta parametro 09 (Bloqueia/Desbloq), pois a ParamBox hora retorna Caracter, hora retorna numerico,
			// por ser um parametro tipo Combo
			mv_par09:= If(Type("mv_par09")=="N", mv_par09,Val(Left(mv_par09,1)))

			If mv_par09 == 1
				cWhere := "%(N1_STATUS = '2'"
				cMsg := STR0024 //"Desbloqueando"
			Else
				cWhere := "%(N1_STATUS = '1' OR N1_STATUS = ' ' "
				cMsg := STR0025 //"Bloqueando"
			Endif

			cWhere += " OR N1_STATUS = '3')%"

			BeginSql Alias cAliasTrb
				SELECT R_E_C_N_O_ RECNOSN1
				FROM %table:SN1%
				WHERE N1_FILIAL = %xFilial:SN1%
				AND N1_CBASE >= %exp:mv_par01%
				AND N1_CBASE <= %exp:mv_par02%
				AND N1_ITEM  >= %exp:mv_par03%
				AND N1_ITEM  <= %exp:mv_par04%
				AND N1_GRUPO >= %exp:mv_par05%
				AND N1_GRUPO <= %exp:mv_par06%
				AND N1_AQUISIC >= %exp:mv_par07%
				AND N1_AQUISIC <= %exp:mv_par08%
				AND %exp:cWhere%
				AND %notDel%
			EndSql

			MsgRun( STR0026 + cMsg + STR0027 ,, { || ProcBlqDesb(cAliasTrb) } ) //"Aguarde " ## " ativos"

			(cAliasTrb)->(DbCloseArea())
		Endif
	Else
		SaveInter()
		If FindFunction("GetParAuto")
			mv_par01 	:= aRetAuto[1]
			mv_par02 	:= aRetAuto[2]
			mv_par03	:= aRetAuto[3]
			mv_par04	:= aRetAuto[4]
			mv_par05	:= aRetAuto[5]
			mv_par06	:= aRetAuto[6]
			mv_par07	:= aRetAuto[7]
			mv_par08	:= aRetAuto[8]
			mv_par09	:= aRetAuto[9]
		EndIf

		// Ajusta parametro 09 (Bloqueia/Desbloq), pois a ParamBox hora retorna Caracter, hora retorna numerico,
		// por ser um parametro tipo Combo
		mv_par09:= If(Type("mv_par09")=="N", mv_par09,Val(Left(mv_par09,1)))

		If mv_par09 == 1
			cWhere := "%(N1_STATUS = '2'"
			cMsg := STR0024 //"Desbloqueando"
		Else
			cWhere := "%(N1_STATUS = '1' OR N1_STATUS = ' '"
			cMsg := STR0025 //"Bloqueando"
		Endif

			cWhere += " OR N1_STATUS = '3')%"

		BeginSql Alias cAliasTrb
			SELECT R_E_C_N_O_ RECNOSN1
			FROM %table:SN1%
			WHERE N1_FILIAL = %xFilial:SN1%
			AND N1_CBASE >= %exp:mv_par01%
			AND N1_CBASE <= %exp:mv_par02%
			AND N1_ITEM  >= %exp:mv_par03%
			AND N1_ITEM  <= %exp:mv_par04%
			AND N1_GRUPO >= %exp:mv_par05%
			AND N1_GRUPO <= %exp:mv_par06%
			AND N1_AQUISIC >= %exp:mv_par07%
			AND N1_AQUISIC <= %exp:mv_par08%
			AND %exp:cWhere%
			AND %notDel%
		EndSql

		MsgRun( STR0026 + cMsg + STR0027 ,, { || ProcBlqDesb(cAliasTrb, lAutomato) } ) //"Aguarde " ## " ativos"

		(cAliasTrb)->(DbCloseArea())
	EndIf
	RestInter()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ImpCl
Importação de arquivo para classificação gerencial do ativo
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ImpCl(cAlias,nReg,nOpc)
Local aArea	:= GetArea()
Local aRet		:= {}			//Conteudo de retorno da ParamBox
Local aPerg	:= {}			//Array de parametros a serem passados para a ParamBox
Local nX		:= 0
Local nY		:= 0
Local aLogAux	:= {}
Local lRet		:= .T.
Local cIdCV8	:= ""
Local oDlg		:= Nil


If lRet
	lRet := CtbInTran( 1, .F. )
EndIf

If lRet

	__aEtapa := {}

	ProcLogIni( {},__cProcPrinc+"Imp",,@cIdCV8)
	ProcLogAtu( STR0038, STR0039,,,.T.) //"Log de processamento de Imp. CSV"

	aCfgImp  := {	{"SN3", , {||MSExecAuto({|x| AF012IClas(x)},xAutoCab )}} }

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Array a ser passado para ParamBox³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd(aPerg,{6,STR0040,PadR("",150),"","","",90,.T.,STR0042,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}) //"Nome do arquivo para importação"###"Arquivos .CSV |*.CSV"
	aAdd(aPerg,{2,STR0041,STR0044,{STR0043, STR0044 },60,"",.T.})//"Exclui classificação anterior"##"Não"##"Sim"##"Não"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso confirme a tela de parametros processa a rotina de exportacao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ParamBox(aPerg,STR0045,@aRet,/**/,/**/,/**/,/**/,/**/,oDlg) //"Importar Classificação Ativo"
		aRet := AjRetParam(aRet,aPerg)
		__lExcImp := aRet[2] == 1
		oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfgImp , .F.)} )
		oProcess:Activate()
	EndIf

	If Len(aRet) > 0
		For nX := 1 to Len(__aEtapa)
			cDetalhe := ""
			aLogAux  := __aEtapa[nX][3]
			For nY := 1 to Len(aLogAux)
				cDetalhe += aLogAux[nY]
			Next nY

			If Len(cDetalhe) > 0
				ProcLogAtu( "ERRO", STR0046+ Alltrim(__aEtapa[nX][1]) + STR0047 + Alltrim(__aEtapa[nX][2]) ,cDetalhe,,.T.)//"Classificacao do Codigo "##" Item:"
			Else
				ProcLogAtu( "MENSAGEM", STR0046 + Alltrim(__aEtapa[nX][1]) + STR0047 + Alltrim(__aEtapa[nX][2]) ,cDetalhe,,.T.)//"Classificacao do Codigo "##" Item:"
			Endif

		Next nX

		ProcLogAtu( "FIM",,,,.T. )
		ProcLogView(cFilAnt,'AF012Imp',,cIdCV8 )

	Endif
EndIf

__aEtapa := {}

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012IClas
Gravação da classificação gerencial do ativo
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012IClas(xAutoCab) //recebe o array já montado pela CTBIMPCSV
Local aArea			:= GetArea()
Local aAreaSN3	   	:= SN3->(GetArea())
Local aAreaSN1	   	:= SN1->(GetArea())
Local lRet		   		:= .T.
Local aAtfCab	   		:= {}
Local aAtfItens	   	:= {}
Local aStruSN1	   	:= CarregStru("SN1")
Local aStruSN3	   	:= CarregStru("SN3")
Local nPosBem			:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_CBASE"} )
Local nPosItem		:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_ITEM"} )
Local nPosSeq			:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_SEQ"} )
Local nPosTipo		:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_TIPO"} )
Local nPosTpSld		:= aScan(xAutoCab, {|x| AllTrim(x[1]) == "N3_TPSALDO"} )
Local nZ				:= 0
Local nX				:= 0
Local ncontItens		:= 1
Local nAchou			:= 0
Local nSeq				:= 0
Local aLog				:= {}
Local aParam			:= {}
Local lExcImp			:= __lExcImp  // Variavel static
Local cCodAtv			:= ""
Local cItemAtv			:= ""
Local cTipoAtv			:= ""
Local cTpSldAtv		:= ""

Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

dbSelectArea("SN1")
dbSetOrder(1) //FILIAL+CBASE+ITEM

//--------------------------------------------------------
// Trata as informações que serão utilizadas em pesquisas
//--------------------------------------------------------
cCodAtv		:= If(nPosBem > 0 .And. ValType(xAutoCab[nPosBem][2]) <> "U",PadR(xAutoCab[nPosBem][2],TamSX3("N3_CBASE")[1]),CriaVar("N3_CBASE",.F.))
cItemAtv	:= If(nPosItem > 0 .And. ValType(xAutoCab[nPosItem][2]) <> "U",PadR(xAutoCab[nPosItem][2],TamSX3("N3_ITEM")[1]),CriaVar("N3_ITEM",.F.))
cTipoAtv	:= If(nPosTipo > 0 .And. ValType(xAutoCab[nPosTipo][2]) <> "U",PadR(xAutoCab[nPosTipo][2],TamSX3("N3_TIPO")[1]),CriaVar("N3_TIPO",.F.))
cTpSldAtv	:= If(nPosTpSld > 0 .And. ValType(xAutoCab[nPosTpSld][2]) <> "U",PadR(xAutoCab[nPosTpSld][2],TamSX3("N3_TPSALDO")[1]),CriaVar("N3_TPSALDO",.F.))

Begin Transaction

If !Empty(cCodAtv) .And. !Empty(cItemAtv) .And. !Empty(cTipoAtv) .And. !Empty(cTpSldAtv)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Preparacao do array dos itens que ja EXISTAM.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SN1->(DbSeek(xFilial("SN1")+cCodAtv+cItemAtv))   //FILIAL+CBASE+ITEM

		If lRet
			lRet := AF12VLClas(cCodAtv,cItemAtv,cTipoAtv,cTpSldAtv,lExcImp)
		EndIf

		If lRet

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preparacao do cabecalho SN1.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nZ := 1 To Len(aStruSN1)
				AADD(aAtfCab,{aStruSN1[nZ,2],&(aStruSN1[nZ,2]),NIL})
			Next nZ
			dbSelectArea("SN3")
			dbSetOrder(1) //FILIAL+CBASE+ITEM+TIPO+BAIXA+SEQ

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Preparacao dos itens SN3.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			AADD(aAtfItens,{})

			For nX := 1 to Len(aStruSN3)
				For nZ := 1 to Len(xAutoCab)
					If AllTrim(aStruSN3[nX,2]) == AllTrim(xAutoCab[nZ][1])
						nAchou := nZ
						Exit
					Endif
				Next nZ

				If nAchou != 0
					AADD(aAtfItens[ncontItens],{xAutoCab[nAchou,1],xAutoCab[nAchou,2],NIL})
					nAchou := 0
				Endif
			Next nX

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Para utilizacao da rotina automatica e necessario a inclusao do campo N3_SEQ.  ³
			//³O Campo N3_SEQ serve para enumerar o tanto de linhas da grid(aCols)            ³
			//³Grava a sequencia de aquisição do bem.Cada vez que um novo tipo é gerado no SN3³
			//³a sequencia e acresida de um. Este nro e gerado qdo um tipo e incluido no SN3. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SN3")
			dbSetOrder(1) //FILIAL+CBASE+ITEM+TIPO+BAIXA+SEQ

			If SN3->(DbSeek(xFilial("SN3")+cCodAtv+cItemAtv))
				While SN3->(!EOF()) .AND. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM == xFilial("SN3") + cCodAtv + cItemAtv
					nSeq += 1         //incrementa de acordo com o total de linhas encontradas na "SN3"
					dbSkip()
				Enddo
			Endif

			nPosSeq := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_SEQ" })
			If nPosSeq > 0
				aAtfItens[Len(aAtfItens),nPosSeq,2]	:= STRZERO(nSeq+1,3)
			Else
				AADD(aAtfItens[ncontItens],{"N3_SEQ",STRZERO(nSeq+1,3),NIL})
			EndIf

			nPosDIn := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_DINDEPR" })
			If nPosDIn <= 0
				AADD(aAtfItens[ncontItens],{"N3_DINDEPR",dDataBase,NIL})
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Regras de importacao                     ³
			//³Execucao da rotina automatica 4 Alteracao³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAdd( aParam, {"MV_PAR01", 2} )
			aAdd( aParam, {"MV_PAR02", 1} )
			aAdd( aParam, {"MV_PAR03", 2} )
			MSExecAuto({|a,b,c,d| Atfa012(a,b,c,d)},aAtfCab,aAtfItens,4,aParam)

			aAtfCab 	:= 	{}
			aAtfItens	:= 	{}
		EndIf
	Else
		Help( " ", 1, "AF012NOREG") //'Não encontrou registros'
	Endif
Else
	Help( " ", 1, "AF012OBRIG")  //"Há campos obrigatórios utilizados para identificação do ativo não preenchidos."
EndIf

If lMsErroAuto
	aLog := GETAUTOGRLOG()
	lMsErroAuto := .F.
	lRet := .F.
Endif

aAdd(__aEtapa, {cCodAtv,cItemAtv,aLog} )

If !lRet
	DisarmTransaction()
EndIf

End Transaction

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF12VLClas
Validação/Adequação de classificações existentes.
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF12VLClas(cCodBase,cItem,cTipo,cTpSld,lExcImp)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local aAreaSN3  := SN3->(GetArea())

SN3->(dbSetOrder(11)) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO

// Busca se a classificacao a ser importada já existe na ficha do bem
If SN3->(MsSeek( xFilial("SN3") + cCodBase + cItem + cTipo + "0" + cTpSld ))

	If lExcImp
		If !AF12DEPRAC(cCodBase,cItem,cTipo,cTpSld) //Se o bem já possui movimentação faz a baixa do tipo
			lRet := AF012ExClas(cCodBase,cItem,cTipo,cTpSld)
		ElseIf ! RusCheckRevalFunctions()
			Help(" ",1, "AF010DEL")
			lRet := .F.
		EndIf
	Else
		Help(" ",1, "AF012CLASIMP") //Help "Já existe essa classificação para o bem. Verifique o tipo do bem e o tipo de saldo"
		lRet := .F.
	EndIf

EndIf

RestArea(aAreaSN3)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AFA012LOG

Gravação do Log da importação

@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AFA012LOG()

ProcLogView(,__cProcPrinc)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}AF12CrAuto
Função para geração múltipla de bens.
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------

Function AF12CrAuto()
Local nOpca 		:= 0
Local oDlg1
Local nBens     	:= 0
Local oModel 		:= FWModelActive()
Local lRet			:= .T.
Local aSaveLines	:= FWSaveRows()

If oModel:GetValue('SN1MASTER','N1_TPCTRAT') $ "2|3"
	Help(" ",1,"NOMULTERC")// "Opção de Multiplo não disponível para bens em controle de terceiros"
	lRet := .F.
EndIf

If lRet
	DEFINE MSDIALOG oDlg1 TITLE STR0048 FROM 33,25 TO 110,349 PIXEL
	@ 01,05 TO 032, 128 OF oDlg1 PIXEL
	@ 08,08 SAY STR0049 SIZE 55, 7 OF oDlg1 PIXEL
	@ 18,08 MSGET nBens SIZE 37, 11 OF oDlg1 PIXEL Picture "@E 9999" VALID If(nBens > 0, .T., .F.)

	DEFINE SBUTTON FROM 05, 132 TYPE 1 ACTION (nOpca := 1,oDlg1:End()) ENABLE OF oDlg1
	DEFINE SBUTTON FROM 18, 132 TYPE 2 ACTION (nOpca := 0,oDlg1:End()) ENABLE OF oDlg1
	ACTIVATE MSDIALOG oDlg1 CENTERED

	If  nOpca == 1
       __nQtMulti		:= nBens
	ElseIf nOpca == 0
       __nQtMulti		:= 0
	EndIf
Else
	__nQtMulti		:= 0
EndIf

FWRestRows(aSaveLines)

Return(.T.)



//-------------------------------------------------------------------
/*/{Protheus.doc}AF012PLNOK
Faz a pre-validação para operacoes sobre um item da ficha do bem.
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012PLNOK(oModel,nLinha,cAcao,cCampo)
Local lRet		:= .T.
Local oModAtv	:= Nil
Local oAux		:= Nil
Local cStatus	:= ""

If __LinOk
	oModAtv := FWModelActive()
	oAux := oModAtv:GetModel("SN3DETAIL")

	If !oModAtv:IsCopy() .And. !oAux:IsInserted() .And. !__lClassifica
		If oModAtv:GetOperation() == MODEL_OPERATION_UPDATE
			If cAcao == "DELETE"
				If lIsRussia
					cStatus := oModAtv:GetValue('SN1MASTER','N1_STATUS')
				EndIf
				If ATFV012RAC(oModAtv:GetValue('SN1MASTER','N1_CBASE'),oModAtv:GetValue('SN1MASTER','N1_ITEM'),oModAtv:GetValue('SN3DETAIL','N3_TIPO'),oModAtv:GetValue('SN3DETAIL','N3_TPSALDO'),,Iif(lIsRussia .And. cStatus=="0",.T.,.F.)) .And. ! RusCheckRevalFunctions() // Verifica se existe movimentos do ativo exceto a inclusão
					Help(" ",1, "AF010DEL")
					lRet := .F.
				Endif
			Else
				If cAcao == "SETVALUE"
					If Left(cCampo,9) == "N3_TXDEPR"
						If lIsRussia
							cStatus := oModAtv:GetValue("SN1MASTER","N1_STATUS")
							IF !(Empty(cStatus) .or. cStatus=="0") // allow edit when status == "0-Scheduled"
								lRet := !ATFV012RAC(oModAtv:GetValue('SN1MASTER','N1_CBASE'),oModAtv:GetValue('SN1MASTER','N1_ITEM'),oModAtv:GetValue('SN3DETAIL','N3_TIPO'),oModAtv:GetValue('SN3DETAIL','N3_TPSALDO')) // Verifica se existe movimentos do ativo exceto a inclusão
							Endif
						Else
							lRet := !ATFV012RAC(oModAtv:GetValue('SN1MASTER','N1_CBASE'),oModAtv:GetValue('SN1MASTER','N1_ITEM'),oModAtv:GetValue('SN3DETAIL','N3_TIPO'),oModAtv:GetValue('SN3DETAIL','N3_TPSALDO')) // Verifica se existe movimentos do ativo exceto a inclusão
						Endif
					Endif
				Endif
			Endif
		Endif
	Endif
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ALNOK
Valida a linha da SN3 - DETAIL
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ALNOK(oModelLin)
Local nValOri 		:= 0
Local nVorigAtf 		:= 0
Local nValCorAcu 		:= 0
Local nValDepAcu 		:= 0
Local nDepAcmUfir 	:= 0
Local nCorrDepAcum 	:= 0
Local nValAmpl 		:= 0
Local nI	 			:= 0
Local lRet	 			:= .T.
Local lSaida 			:= .F.
Local cCCdepr 		:= ""
Local cDesp   		:= ""
Local cDeprec 		:= ""
Local nDepr   		:= 0
Local dExaust 		:= ctod("")  // Data de exaust„o
Local dDindepr 		:= ctod("") // Inicio da deprecia‡„o
Local dN3_Aquisic 	:= ctod("") // Aquisicao
Local nLaco   		:= 0
Local cMoedaAtf 	:= Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local aDepAcm 		:= AtfMultMoe(,,{|x| 0})
Local aVorig  		:= AtfMultMoe(,,{|x| 0})
Local aValAmpl		:= AtfMultMoe(,,{|x| 0})
Local cSeq				:= ""
Local lOk				:= .F.
Local cN1TipoNeg  	:= Alltrim(SuperGetMv("MV_N1TPNEG",.F.,"")) // Tipos de N1_PATRIM que aceitam Valor originais negativos
Local cN3TipoNeg  	:= Alltrim(SuperGetMv("MV_N3TPNEG",.F.,"")) // Tipos de N3_TIPO que aceitam Valor originais negativos
Local nk				:= 0
Local cTipoDepr		:= ''
// Local cTpGerenc		:= ATFXTpBem(2)// Tipos de Ativos gerenciais trecho onde era utilizado foi comentado
Local nQuantas 		:= AtfMoedas()	// Controle de multiplas moedas

Local oModel 			:= FWModelActive()
Local oAux		 		:= oModel:GetModel('SN3DETAIL')
Local nAtual	 		:= oAux:GetLine()
Local nOper	 		:= oModel:GetOperation()
Local cTipo			:= oAux:GetValue('N3_TIPO')
Local cBase			:= If(Type(oModel:GetValue('SN1MASTER','N1_CBASE')) == "C",oModel:GetValue('SN1MASTER','N1_CBASE'), SN1->N1_CBASE)
Local cItem			:= If(Type(oModel:GetValue('SN1MASTER','N1_ITEM'))  == "C",oModel:GetValue('SN1MASTER','N1_ITEM') , SN1->N1_ITEM)
Local cGrupo			:= ""
Local aCposSN3		:= oAux:GetStruct():GetFields()
Local nX			:= 0
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
Local cTypesNM		:= IIF(lIsRussia,"|" + AtfNValMod({1,2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable model
Local cBmcontr 	    := IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , oModel:GetValue('SN1MASTER','N1_BMCONTR'),"")
Local lBmcontr 	    := IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , .T., .F.)

Local nPosPrdMes	:= 0
Local nPosPrdAno	:= 0
Local nPosTpDepr	:= 0

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Forcar posicionamento no SX1              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
pergunte("AFA012",.F.)
AF012PerAut()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³N„o deixar excluir o tipo 10 caso exista o tipo 14 nem o tipo 14
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __LinOk

	If oAux:IsDeleted() .AND. oAux:GetValue('N3_TIPO') $ ('10|14' + cTypes10) // aCols[n][nUsado+1]  // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
		If Ascan(oAux:aCols,{|x| AllTrim(x[4]) == '14'}) > 0 //existe um tipo 14, não permitir
			Help(" ",1,"AFDELT14",,STR0131+" " +STR0132+ " " +STR0133,1,0)//"Este item não pode ser excluído.""Itens de Tipo 10 só podem ser excluídos se não existirem itens de Tipo 14,""e itens de Tipo 14 não podem ser excluídos manualmente."
			lRet := .F.
		Endif
	EndIf

    If lRet .And. lIsRussia .And. ! oAux:IsDeleted()
        If oAux:GetValue("N3_TPDEPR") $ "1|2|6" .And. Empty(oAux:GetValue("N3_PERDEPR"))
            lRet    := .F.
            Help("",1,"ATFA012VTP",,STR0158,1,0)	// "If type of depreciation (N3_TPDEPR) is 1, 2 or 6, rate of depreciation (N3_PERDEPR) is mandatory"
        EndIf
    EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
	//³Validação das regras de informações por tipo de ativo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
	If lRet .AND. !AF012ATIPO(oAux:GetValue('N3_TIPO'), nAtual, .T.)
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validação para localizações POR / EUA            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. cPaisLoc $ "POR|EUA"
		If !oAux:IsDeleted() .AND. oAux:GetValue('N3_TIPO') == "01" .AND. Empty(oAux:GetValue('N3_TPDEPR'))
			Help("",1,"AF010TPDPR")
			lRet := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validação do preenchimento do campo N3_CODIND    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') == "A" .AND. Empty(oAux:GetValue('N3_CODIND'))
		Help( ,1, "AF010CODIN")		//"Campo Ind.calculo (N3_CODIND) não preenchido."##"Para o tipo de depreciação cálculo por índice é necessário informar o código do índice (N3_CODIND)."
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validação para não permitir nova linha em componentes  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lBmcontr
		If lRet .AND. !oAux:IsDeleted() .And. nOper == 3 .And. (oModel:GetValue('SN1MASTER','N1_BMCONTR')) == '1' .And. oAux:GetLine() > 1
			Help( " ", 1, "AF010BMCOM",,STR0183, 1, 0 )//"Não é possível adicionar uma nova linha Num bem em construção"
			lRet := .F.
		EndIf
		If lRet .AND. !oAux:IsDeleted() .AND. __lClassifica .AND. !Empty(oModel:GetValue('SN1MASTER','N1_SLBMCON')) .And. oAux:GetLine() > 1
			Help( " ", 1, "AF010BMCOM",,STR0179, 1, 0 )//"Não é possível adicionar uma nova linha no componente de um bem em construção"
			lRet := .F.
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validação para localização Colombia              ³
	//³O tipo de redução de saldos deve ter cadastrados ³
	//³o valor de salvamento e a vida util do bem       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "COL"

		If lRet .AND. oAux:GetValue('N3_TIPO') $ "50|51|52|53|54"
			For nK := 1 to  oAux:Length() //Len(aCols)
				If !oAux:IsDeleted(nK) .AND. nK != nAtual .AND. oAux:GetValue('N3_TIPO', nK) $ "50|51|52|53|54" .AND. Empty(oAux:GetValue('N3_DTBAIXA', nK))
					Help("",1,"A010JADIG")
					lRet := .F.
					Exit
				EndIf
			Next nK
		EndIf

		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TIPO') == "51" .AND. oAux:GetValue('N3_PERDEPR') == 0
			Help("",1,"AF010VDUTI")
			lRet := .F.
		EndIf
		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TIPO') == "52" .AND. oAux:GetValue('N3_PERDEPR') == 0
			Help("",1,"AF010VDUTI")
			lRet := .F.
		EndIf
		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TIPO') == "52" .AND. oAux:GetValue('N3_VLSALV1') == 0
			Help("",1,"AF010NOSAL")
			lRet := .F.
		EndIf
		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TIPO') == "53" .AND. oAux:GetValue('N3_PERDEPR') == 0
			Help("",1,"AF010VDUTI")
			lRet := .F.
		EndIf

		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TIPO') == "54" .AND. (oAux:GetValue('N3_PRODMES') == 0 .OR. oAux:GetValue('N3_PRODANO') == 0)
			Help("",1,"AF010FPROD")
			lRet := .F.
		EndIf
		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') $ "4|5" .AND. oAux:GetValue('N3_PRODMES') > oAux:GetValue('N3_PRODANO')
			Help( " ", 1, "AF012FPRA") //"Para calculo pelo método de produção de ativos a produção do periodo deve ser menor ou igual a produção prevista"
			lRet := .F.
		EndIf

	EndIf

	If cPaisLoc $ "BRA|DOM|ARG|COS"

		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') == "6" .AND. oAux:GetValue('N3_PERDEPR') == 0
			Help("",1,"AF010VDUTI")
			lRet := .F.
		EndIf

		If lRet	 .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') == "2" .And. (oAux:GetValue('N3_VLSALV1') == 0 .OR. oAux:GetValue('N3_PERDEPR')== 0)
			Help("",1,"AF010NOSAL")
			lRet := .F.
		EndIf

		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') == "3" .And. oAux:GetValue('N3_PERDEPR') == 0
			Help("",1,"AF010VDUTI")
			lRet := .F.
		EndIf

		If cPaisLoc $ "ARG|BRA|COS"

			If lRet .AND.!oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') $ "4|5|8|9" .AND. oAux:GetValue('N3_PRODANO') == 0
				Help("",1,"AF010FPROD")		//Para calculo pelo método de produção de ativos é necessário informar o fator de produção.
				lRet := .F.
			EndIf

			If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_PRODACM') > 0 .AND. oAux:GetValue('N3_VRDACM1') == 0 .AND. oAux:GetValue('N3_TPDEPR') $ "4|5|8|9"
				lRet := .F.
				Help("",1,"AF010PRACM")		//"O valor da depreciação acumulada não foi informado."##"Para bens com produção acumulada é necessário informar o valor da depreciação acumulada."
			EndIf

			If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_PRODACM') == 0 .AND. oAux:GetValue('N3_VRDACM1') > 0 .AND. oAux:GetValue('N3_TPDEPR') $ "4|5|8|9"
				lRet := .F.
				Help("",1,"AF010VRACM")		//"A produção acumulada não foi informada."##"Para bens com depreciação acumulada é necessário informar a produção acumulada."
			EndIf
		Else
			If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') $ "4|5" .AND. oAux:GetValue('N3_PRODMES') == 0 .OR. oAux:GetValue('N3_PRODANO')  == 0
				Help("",1,"AF010FPROD")
				lRet := .F.
			EndIf

			nPosPrdMes:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODMES"} )
			nPosPrdAno:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODANO"} )
			nPosTpDepr:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_TPDEPR"} )

			If lRet .And. !oAux:IsDeleted() .And. aCols[n][nPosTpDepr] $ "4/5" .And. aCols[n][nPosPrdMes] > aCols[n][nPosPrdAno]
				Help( " ", 1, "AF012FPRA") //"Para calculo pelo método de produção de ativos a produção do periodo deve ser menor ou igual a produção prevista"
				lRet := .F.
			EndIf
		EndIf

		If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') == "7" .AND. oAux:GetValue('N3_VMXDEPR') == 0
			Help("",1,"AF010VMXD")//Para o calculo pelo método Linear com valor maximo de depreciacao é obrigatorio o valor maximo de depreciacao
			lRet := .F.
		EndIf

	EndIf


	If lRet

		cGrupo := oModel:GetValue('SN1MASTER','N1_GRUPO')
		lRet   := AtfVldCpoCfg( cGrupo , .T. , nAtual )

		If lRet
			nDepr     		:= oAux:GetValue('N3_TXDEPR' + cMoedaAtf)
			cDesp   	 	:= oAux:GetValue('N3_CDESP')
			cCcDepr	 	:= oAux:GetValue('N3_CCDEPR')
			cDeprec	 	:= oAux:GetValue('N3_CDEPREC')
			nValOri		:= oAux:GetValue('N3_VORIG1')
			nVorigAtf		:= oAux:GetValue('N3_VORIG' + cMoedaAtf)
			nValAmpl		:= oAux:GetValue('N3_AMPLIA1')

			// *******************************
			// Controle de multiplas moedas  *
			// *******************************
			aVOrig  := AtfMultMoe(,,{|x| oAux:GetValue("N3_VORIG" + Alltrim(Str(x)))})

			nValCorAcu	   := oAux:GetValue('N3_VRCACM1')
			nValDepAcu	   := oAux:GetValue('N3_VRDACM1')
			nDepAcmUfir  := oAux:GetValue('N3_VRDACM' + cMoedaAtf)
			//
			aDepAcm  	   := AtfMultMoe(,,{|x| oAux:GetValue(If(x > 9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)))})
			nCorrDepAcum := oAux:GetValue('N3_VRCDA1')
			dDindepr 	   := oAux:GetValue('N3_DINDEPR')
			//
			aValAmpl 	:= AtfMultMoe(,,{|x| oAux:GetValue( If(x>9,"N3_AMPLI","N3_AMPLIA") + Alltrim(Str(x)))  })

			If !(cPaisLoc $ "ARG|BRA|COS")
				If !oAux:IsDeleted() .AND. dDindepr < oModel:GetValue('SN1MASTER','N1_AQUISIC') .AND. !Empty(dDindepr)
					lRet := .F.
					Help(" ",1,"AF010DDEPR")
				EndIf
			Else
				DbSelectArea("SX3")
				SX3->(DbSetOrder(2))
				If DbSeek("N1_CONSAB") .And. SX3->X3_USADO == "€€€€€€€€€€€€€€"
					If !oAux:IsDeleted() .AND. dDindepr < oModel:GetValue('SN1MASTER','N1_AQUISIC') .AND.;
					!Empty(dDindepr) .And.oModel:GetValue('SN1MASTER','N1_CONSAB') <> "1"
						lRet := .F.
						Help(" ",1,"AF010DDEPR")
					EndIf
				EndIf
			EndIf

			If lRet
				dExaust      := oAux:GetValue('N3_DEXAUST')
				dN3_Aquisic := oAux:GetValue('N3_AQUISIC')

				If cPaisLoc $ "URU|BOL" .AND. nOper == 4 .AND. oAux:IsDeleted()  .And. __lAtfAuto

					SN4->(dbSetOrder(1))
					If SN4->(dbSeek(xFilial("SN3")+ cBase + cItem + "02" +DTOS(GetMV("MV_ULTDEPR"))))
						cSeq	:=  oAux:GetValue('N3_SEQ')
						Do While SN4->N4_FILIAL+ SN4->N4_CBASE+ SN4->N4_ITEM == xFilial("SN3")+ cBase + cItem

							If SN4->N4_TIPO $ "02|41|42" .AND. SN4->N4_OCORR == "06" .AND. cSeq == SN4->N4_SEQ .And. ! RusCheckRevalFunctions()
								Help(" ",1, "AF010DEL")
								lRet := .F.
								Exit
							EndIf

							SN4->(dbSkip())
						EndDo
					EndIf

				ElseIf nOper == 4 .And. oAux:IsDeleted() .AND. ATFV012RAC(cBase,cItem,cTipo) .And. ! RusCheckRevalFunctions() // Verifica se existe movimentos do ativo exceto a inclusão
					Help(" ",1, "AF010DEL")
					lRet := .F.
				ElseIf oAux:IsDeleted()
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso nao tenha depreciacao Linha deletada n„o precisa ser validada  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lOk := .T.
				Endif

				If lSaida .Or. lOk
					lRet := .T.

				ElseIf lRet

					If !Empty( dExaust )
						If dDindepr > dExaust          // Inicio da deprecia‡„o n„o pode ser
							Help(" ",1,"AFA010EXA2")    // maior que a exaust„o do bem
						Endif
					Endif

					If ExistBlock("AF12VLR0")
						If !ExecBlock("AF12VLR0",.F.,.F.,{nValOri,nVorigAtf}) // Controlar Bens Valor Zerado - Inventario
							If (nVorigAtf == 0 .Or. nValOri == 0) .and. lRet
								Help(" ",1,"ATFVALORUF",,'Moeda:'+GetMV("MV_ATFMOED"),4,0) // "Moeda :"
								lRet := .F.
							EndIf
						Endif
					Else
						If (nVorigAtf == 0 .Or. nValOri == 0) .and. lRet .And. cBmcontr <> "1" //.and. !(ATFXPAcols("N3_TIPO","") $ cTpGerenc) // IFRS
							Help(" ",1,"ATFVALORUF",,'Moeda:'+GetMV("MV_ATFMOED"),4,0) // "Moeda :"
							lRet := .F.
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ NÆo aceita deprecia‡Æo acumulada maior que ³
					//³ o valor original do bem.                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Round(((nValOri + nValCorAcu + nValAmpl) - nValDepAcu ),2) < 0.00  .AND. lRet .AND.;
					oAux:GetValue('N3_TIPO') # "05" .AND. !(oModel:GetValue('SN1MASTER','N1_PATRIM') $ cN1TipoNeg);
					.AND. !(oAux:GetValue('N3_TIPO') $ cN3TipoNeg)
						Help(" ",1,"AF010VALOR")
						lRet := .F.
					End
					If lRet
						// Procura inconsistˆncia em outras moedas
						If lRet .And. oAux:GetValue('N3_TIPO') # "05" .AND.;
						!(oModel:GetValue('SN1MASTER','N1_PATRIM') $ cN1TipoNeg) .AND.;
						!(oAux:GetValue('N3_TIPO') $ cN3TipoNeg)

							For nlaco := 2 To nQuantas
								If aDepAcm[nLaco] > aVOrig[nLaco] + (nValCorAcu / &("SM2->M2_MOEDA" + AllTrim(STR(nLaco))));
								+ aValAmpl[nLaco]
									Help(" ",1,"AF010VALOR")
									lRet := .F.
									Exit
								Endif
							Next nLaco
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Consiste a rela‡„o entre o valor do bem em moeda nacional e   ³
					//³ o valor do bem em moeda forte.                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet
						// Quando come‡ou a lei da ufir do mˆs seguinte
						If dDataBase >= ctod("01/09/94","ddmmyy")
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Antigo PE AF10VLR0 - AF12VLR0 - Permite inclusao de bens com valor 0 (zero) ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If ExistBlock("AF12VLR0")
								If !ExecBlock("AF12VLR0",.F.,.F.,{nValOri,nVorigAtf}) // Controlar Bens Valor Zerado - Inventario
									If ExistBlock("A30EMBRA")
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ A30EMBRA- Espec¡fico para EMBRAER ³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If Abs((nValOri + nValCorAcu) / ExecBlock("A30EMBRA",.F.,.F.) - nVorigAtf ) > 1
											Help(" ",1,"AF010VORIG")
											lRet := .F.
										Endif
									EndIf
								Endif
							Else
								If  ExistBlock("A30EMBRA")
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ A30EMBRA- Espec¡fico para EMBRAER ³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									If Abs((nValOri + nValCorAcu) / ExecBlock("A30EMBRA",.F.,.F.) - nVorigAtf ) > 1
										Help(" ",1,"AF010VORIG")
										lRet := .F.
									Endif
								EndIf
							EndIf
						Endif
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Consistir a rela‡„o entre o valor da deprecia‡„o em moeda nacional e o  ³
					//³ valor da deprecia‡„o em moeda forte.                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					// Quando come‡ou a lei da ufir do mˆs seguinte
					If dDataBase >= ctod("01/09/94","ddmmyy") .AND. lRet
						If Type("dDataAqui") != "D" .AND. ExistBlock("A30EMBRA")
							If Abs((nValDepAcu + nCorrDepAcum) / (If(ExistBlock("A30EMBRA"),;
								ExecBlock("A30EMBRA",.F.,.F.),RecMoeda(dDataBase,cMoedaAtf))) -;
								nDepAcmUfir ) > 1
								Help(" ",1,"AF010DEPR")
								lRet := .F.
							Endif
						Endif
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se a data de in¡cio da deprecia‡„o for menor que a data         ³
					//³ do £ltimo c lculo, exigir a digita‡„o da deprecia‡„o acumulada. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .And. (nOper == 3 .Or. nOper == 4 .Or. __lClassifica) .And.;
						(dDindepr <= GetMv("MV_ULTDEPR") .And. nValDepAcu == 0 .And. nDepr <> 0 .And. !GetNewPar("MV_ZRADEPR",.F.))
						Help(" ",1,"AF010FALTD")
						lRet := .F.
					Endif

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se a data de in¡cio da deprecia‡„o for menor que a data         ³
					//³ do £ltimo c lculo, quando o parametro MV_TIPDEPR for igual a 2, ³
					//³ o tipo do ativo for igual a "01" e for uma inclusao             ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cTipoDepr := oAux:GetValue('N3_TIPO', nAtual)

					If dDindepr < SuperGetMv("MV_ULTDEPR") .And. GetMv("MV_TIPDEPR") == "2" .AND.;
					cTipoDepr $ "01|10" .AND. (nOper == 3 .Or. FwIsInCallStack("ATFA240"))//Adicionado a verificação do FwIsCallStack para verificar se foi chamado apartir da classifição o que não estava sendo validado
						Help( " ", 1, "AF012DT10",, STR0050 + DTOC(GetMV("MV_ULTDEPR")), 1, 0 ) //"A Data Inicial de Depreciação não pode ser menor que a data do último calculo = "
						lRet := .F.
					Endif
					If lRet
						If oModel:GetValue('SN1MASTER','N1_PATRIM') == "SAC"  // S=Patrimonio, A=Amortiza‡…o e C=Capital Social
							If !Empty( cDesp)     .or.  !Empty( cDeprec)  .or. ;
								!Empty( cCcdepr )  .or.  !Empty( nDepr )   .or. ;
								nValDepAcu # 0     .or.  nDepAcmUfir # 0   .or. ;
								nCorrDepAcum # 0
								Help(" ",1,"CTAPATRIM")
								lRet := .F.
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ BOPS 00000120962 - CENTRALIZACAO DA VALIDACAO DA CHAPA E P.E.³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				EndIf
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validacao para tipos 10 e 13                                                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. oAux:GetValue('N3_TIPO') $ ("10|13" + cTypes10) // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

		For nI := 1 To oAux:Length()
			If nI != nAtual
				If oAux:GetValue('N3_TIPO', nI) == oAux:GetValue('N3_TIPO', nAtual) .AND.;
				(oAux:GetValue('N3_TPSALDO',nI) == oAux:GetValue('N3_TPSALDO',nAtual)) .AND.;
				!oAux:IsDeleted(nI) .AND. !oAux:IsDeleted(nAtual)
					Help( " ", 1, "AF012TP10") //"Tipo de Ativo e Tipo de Saldo duplicado"
					lRet := .F.
					Exit
				EndIf
			EndIf
		Next nI

	EndIf

	If lRet .AND. Alltrim(oAux:GetValue('N3_CRIDEPR')) $ "03|04"
		If !oAux:GetValue('N3_TIPO') $ ("10|12" + cTypesNM)
			Help( " ", 1, "AF012DEP") //"Critério de depreciação não é valido para o tipo de ativo em questão"
			lRet:= .F.
		EndIf
	EndIf

	If lRet .AND. !oAux:IsDeleted()
		lRet:= ATFSALDEPR(oAux:GetValue('N3_TIPO'), oAux:GetValue('N3_TPSALDO'))
	EndIf

	If lRet .AND. lAFA012
		lRet := ExecBlock("ATFA012" ,.F.,.F.,{oAux, 'FORMLINEPOS', 'SN3DETAIL', nAtual })
	EndIf

	If lRet .AND. SuperGetMV("MV_PCOINTE",.F.,"2") == "1"  //se integra com pco
		lRet	:=	PcoVldLan('000154','02','ATFA012',/*lUsaLote*/,/*lDeleta*/, .T./*lVldLinGrade*/)
	EndIf

	//----------------------------------------------------------------------------------------------------------------------------
	// Verificacao do preenchimento dos campos obrigatorios. Este processo ocorre neste momento devido a desabilitacao temporaria
	// para o grupo de bens preencher todas as linhas da SN3 sem ser interrompido pelas validacao de preenchimento
	//----------------------------------------------------------------------------------------------------------------------------
	If lRet .And. !oAux:IsDeleted() .And. !Empty( cGrupo )

		For nX := 1 To Len(aCposSN3)

			If aCposSN3[nX][10] .And. Empty(oAux:GetValue(aCposSN3[nX][3]))
				Help(" ",1,"AF012ALNOK",,STR0145 + AllTrim(aCposSN3[nX][1]) + " (" + AllTrim(aCposSN3[nX][3])+ ") " + STR0146,1,0) //"O campo "###" não foi preenchido."
				lRet := .F.
				Exit
			EndIf

		Next nX

	EndIf


	If lRet .And. !oAux:IsDeleted()
		 lRet := lRet .and. CtbAmarra(oAux:GetValue('N3_CCONTAB'),oAux:GetValue('N3_CUSTBEM'),oAux:GetValue('N3_SUBCCON'),oAux:GetValue('N3_CLVLCON'),.T.,.T.)
		 lRet := lRet .and. CtbAmarra(oAux:GetValue('N3_CDEPREC'),oAux:GetValue('N3_CCDESP'),oAux:GetValue('N3_SUBCDEP'),oAux:GetValue('N3_CLVLDEP'),.T.,.T.)
		 lRet := lRet .and. CtbAmarra(oAux:GetValue('N3_CCDEPR'),oAux:GetValue('N3_CCCDEP'),oAux:GetValue('N3_SUBCCDE'),oAux:GetValue('N3_CLVLCDE'),.T.,.T.)
		 lRet := lRet .and. CtbAmarra(oAux:GetValue('N3_CDESP'),oAux:GetValue('N3_CCCDES'),oAux:GetValue('N3_SUBCDES'),oAux:GetValue('N3_CLVLDES'),.T.,.T.)
		 lRet := lRet .and. CtbAmarra(oAux:GetValue('N3_CCORREC'),oAux:GetValue('N3_CCCORR'),oAux:GetValue('N3_SUBCCOR'),oAux:GetValue('N3_CLVLCOR'),.T.,.T.)
		 lRet := lRet .and. CtbAmarra(oAux:GetValue('N3_CDEPREC'),oAux:GetValue('N3_CCUSTO'),oAux:GetValue('N3_SUBCTA'),oAux:GetValue('N3_CLVL'),.T.,.T.)
	EndIf

EndIf




Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AtfVldCpoCfg
Valida se o campo eh obrigatorio, conforme configuracao do grupo de campos
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function AtfVldCpoCfg(cGrupo, lHelp, nLinAtu)
Local lRet := .T.
Local lVazio := .F.
Local nX

Default nLinAtu := 1

If AliasInDic("SNK").And. SNK->(MsSeek(xFilial("SNK")+cGrupo))
	// Verifica todos os campos configurado para o grupo informado
	While SNK->NK_FILIAL == xFilial("SNK") .And.;
		SNK->NK_GRUPO == cGrupo
		// Se o campo estiver em memoria
		If Type("M->" + SNK->NK_CAMPO) # "U" .Or. "N3_" $ SNK->NK_CAMPO
			// Verifica se eh um campo da tabela SN1 e testa se esta vazio
			If "N1_" $ SNK->NK_CAMPO
				lVazio := Empty(&("M->" + SNK->NK_CAMPO))
			Else
				// Se for um campo da tabela SN3, verifica o aCols em busca do campo vazio e nao permite a inclusao
				If Type("aCols") == "A"
					nLen := Len(aCols)
					For nX := nLinAtu To nLen
						lVazio := !GdDeleted(nX,aHeader,aCols) .And. Empty(GdFieldGet(SNK->NK_CAMPO,nX,,aHeader,aCols))
						If lVazio
							Exit
						Endif
					Next
				Endif
			Endif
			If lVazio
				lRet := .F.
				If lHelp
					SX3->(DbSetOrder(2))
					SX3->(DbSeek(SNK->NK_CAMPO))
					Help("",1,"ATFCPOOBG",,X3Titulo()+"("+SNK->NK_CAMPO+")",1,0)
				Endif
				Exit
			Endif
		Endif
		SNK->(DbSkip())
	End
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ATDOK
Validação ates de realizar o commit do model
@author William Matos Gundim Junior
@since  21/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ATDOK(oModelOK)
Local lRet 			:= .T.
Local oModel 		:= FwModelActive()
Local nX			:= 0
Local n_SaveLin		:= 0
Local cMesCPis		:= AllTrim( SuperGetMv('MV_ATFMAPR',.T.,'0/12/24/48') )
Local lTemItem		:= .F.
Local lCompra 		:= .F.
Local nBaixado		:= 0
Local lProvis 		:= AFPrvAtf()
// Controle de moedas Contabil, Fiscal e Grupo Fiscal
Local cMoedaFisc 	:= Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local cNomeTFSN3 	:= Subs("N3_TXDEPRn",1,10-len(cMoedaFisc) ) +cMoedaFisc
Local cNomeTFSNG 	:= Subs("NG_TXDEPRn",1,10-len(cMoedaFisc) ) +cMoedaFisc
Local nTxMoedaC   	:= 0
Local nTxMoedaF   	:= 0
Local nTxMoedaGF  	:= 0
Local lMargem		:= AFMrgAtf() //Verifica implementacao da Margem Gerencial
Local lTp10ou13   	:= .F.
Local dDataBloq		:= GetNewPar("MV_ATFBLQM",CTOD("")) //Data de Bloqueio da Movimentação - MV_ATFBLQM
Local lAtfCusPrv  	:= AFXAtCsPrv() //Ativo Custo/Provisao
Local oAux			:= oModel:GetModel('SN3DETAIL')
Local oStruct  		:= oAux:GetStruct()
Local aAux      	:= oStruct:GetFields()
Local nOper			:= oModel:GetOperation()
Local nPosTipo		:= 0
Local nPosDel		:= 0
Local lAtfa460		:= IsInCallStack("ATFA460") .or. IsInCallStack("F460DELPRV")
Local cQuery		:= ""
Local cChapa        := ""
Local nTamChapa1    := 0
Local nTamChapa2    := 0
Local nCpo			:= 0
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
Local cTypes12		:= IIF(lIsRussia,"|" + AtfNValMod({2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable model
Local cTpDepr2		AS CHARACTER
Local nPerDepr2		AS NUMERIC
Local lDocEntr		:= FwIsInCallStack("MATA103") .Or. FWIsInCallStack("MATA101") .Or.;
					   FWIsInCallStack("MATA116")  .Or.;
					   FWIsInCallStack("MATA119") .Or. CallsOfEst() .or.  (FindFunction("CallsMI").and. CallsMI() );
					   .or. (FWIsInCallStack("A143GERANF") .and. cPaisLoc=="ARG"  )
Local lEfPlanej		:= FWIsInCallStack("ATFA310")

Local aPer          := {}
Local lExist        := .F.
Local lRuPermDel	:= .F. //Usada somente na RUSSIA
Local lBmcontr 	    := IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , .T., .F.)
Local dDataval		:= SN1->N1_AQUISIC
Local cIdMovFNR		:= ""
Local aArea_SN3		:= {} //Preservar SN3, quando vindo de outros fontes, exemplo atfa060

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

pergunte("AFA012",.F.)
AF012PerAut()

If nOper == 3 .OR. nOper == 4

	/* Validação de campos obrigatórios (não permite caracteres especiais) Felipe Mayer 03/11/2021 */
	If FunName() == 'ATFA012' .And. INCLUI  .And. !ATVldCpo('SN1')
		lRet := .F.
	EndIf

	If nOper == 3 .And. !CtbValiDt(,oModel:GetValue('SN1MASTER','N1_AQUISIC'),.F.,,,{"ATF001"},)
		Help(" ",1,"CTBBLOQ",,STR0135,1,0)//CTBBLOQ - "Calendário Contábil Bloqueado. Verfique o processo."
		lRet := .F.
	EndIf

	If !lIsRussia .AND. !lDocEntr .AND. !lEfPlanej
		If oModel:GetValue('SN1MASTER','N1_STATUS') $ '0' .and. nOper == 3
			Help(" ",1,"AF012STINV",,STR0166,1,0) //"Status Utilizado apenas quando Ativo incluso por Nota Fiscal de Entrada"
			lRet := .F.
		EndIf
	EndIf
	// multiplos nao esta vazio, e eh a primeira gravacao
	If lRetPE
		If !Empty(__nQtMulti) .And. !__lMultiATF
			// tira espaco do codigo da chapa
			cChapa := AllTrim(oModel:GetValue('SN1MASTER','N1_CHAPA'))

			// verifica tamanho de chapa informada
			// e tamanho de quantidade de multiplos
			nTamChapa1 := Len(cChapa)
			nTamChapa2 := Len(AsString(__nQtMulti))

			// caso o tamanho do codigo da chapa nao
			// suporte a quantidade de os multiplos aumenta o codigo
			If nTamChapa1 < nTamChapa2
				cChapa := PadL(cChapa, nTamChapa2, "0")
			EndIf

			lRet := oModel:SetValue('SN1MASTER','N1_CHAPA', cChapa)

		EndIf
	EndIf
	If oModel:GetValue('SN1MASTER','N1_STATUS') $ '3' .AND. Empty(oModel:GetValue('SN1MASTER','N1_LOCAL'))
		lRet := .F.
		If nOper == 4
			Help(" ",1,"AF010BLOQ") //Este bem está bloqueado. Bens bloqueados não podem ser alterados/excluidos.
		ElseIf nOper == 3
			Help(" ",1,"AF012ATDOK",,STR0157,1,0) //'Não é possivel definir o ativo como "Bloqueado por Local" (N1_STATUS), sem informar um local bloqueado (N1_LOCAL).'
		EndIf
	EndIf

	If nOper == 4
		If SN1->N1_STATUS $ '2|3'
			Help(" ",1,"AF010BLOQ")
			lRet := .F.
		EndIf
	Endif

	For nX := 1 To oAux:Length()

		If oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TIPO',nX) $ ('10|14' + cTypes10) // aCols[n][nUsado+1] // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
			If Ascan(oAux:aCols,{|x| AllTrim(x[4]) == '14'}) > 0 //existe um tipo 14, não permitir
				Help(" ",1,"AFDELT14",,STR0131+" " +STR0132+ " " +STR0133,1,0)//"Este item não pode ser excluído.""Itens de Tipo 10 só podem ser excluídos se não existirem itens de Tipo 14,""e itens de Tipo 14 não podem ser excluídos manualmente."
				lRet := .F.
			Endif
		EndIf

	Next nX

	//-- JRJ Valida a existencia da chave do ativo
	If lRet .And. __lCopia
		lRet := AF012AEXIS()
	EndIf

	If lRet
		If __lClassifica
			lRet := AF012ACHAP(oModel:GetValue('SN1MASTER','N1_CHAPA'))
		ElseIf mv_par02 == 2
			lRet := AF012ACHAP(oModel:GetValue('SN1MASTER','N1_CHAPA'),.F.)
		EndIf
	EndIf

	If lRet .And. lBmContr
		If __lClassifica .And. !Empty(oModel:GetValue('SN1MASTER','N1_SLBMCON')) .And. Empty(oModel:GetValue('SN1MASTER','N1_CDCONTR'))
			Help( " ", 1, "AF010BMCOM",,STR0185, 1, 0 )//"Selecione com F3 um Bem em construção para amarração. Aba Bem em construção"
			lRet := .F.
		EndIf
	EndIf

	If lRet .And. !Empty(dDataBloq) .AND. (oModel:GetValue('SN1MASTER','N1_AQUISIC') <= dDataBloq)
		Help(" ",1,"AF012ABLQM") //"A data de aquisição do bem é igual ou menor que a data de bloqueio de movimentação : "
		lRet := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validação da obrigatoriedade do preenchimento do campo N3_CODIND
	// Quando a opcao do tipo de depreciacao for "A"    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet .AND. !oAux:IsDeleted() .AND. oAux:GetValue('N3_TPDEPR') == "A" .And. Empty(oAux:GetValue('N3_CODIND'))
		Help("",1,"AF010CODIN") //"Campo Ind.calculo (N3_CODIND) não preenchido."##"Para o tipo de depreciação cálculo por índice é necessário informar o código do índice (N3_CODIND)."
		lRet := .F.
	EndIf

	If !lIsRussia .And. oModel:GetValue('SN1MASTER','N1_QUANTD') <= 0
		Help(" ",1,"AF012ZERO") //"Favor informar uma quantidade maior que zero."
		lRet := .F.
	EndIf

	If nOper == 3 .AND. !CheckSx3("N1_AQUISIC", oModel:GetValue('SN1MASTER','N1_AQUISIC'))	// Bops 59025
		lRet := .F.
	Endif

	If lRet .AND. cPaisLoc == "BRA"
		aPer := STRTOKARR(cMesCPis , "/")

		For nX := 1 to Len(aPer)
			 If aPer[nX] == AllTrim(STR(oModel:GetValue('SN1MASTER','N1_MESCPIS')))
		 		lExist:= .T.
				Exit
			 EndIf
		Next

		If M->N1_CALCPIS $ '1|2' .And. AllTrim(STR(oModel:GetValue('SN1MASTER','N1_MESCPIS'))) <> "0"
			Help(" ",1,"AF012MESPIS",,STR0167,1,0)// "O campo [Meses Cl.Pis] deve estar zerado para a condição de cálculo de PIS igual a (SIM ou NÃO)"
			lRet := .F.
		ElseIf M->N1_CALCPIS == '3' .And. !lExist
			Help(" ",1,"AF012MESPISV",,STR0168,1,0) // "É obrigatório o preenchimento do campo [Meses Cl.Pis] com um valor válido, verifique o parâmetro MV_ATFMAPR."
			lRet := .F.
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
	//³Validação das regras de informações por tipo de ativo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
	If lRet
		For nX := 1 to oAux:Length()

			If !AF012ATIPO(oAux:GetValue('N3_TIPO', nX), nX, .T.)
				lRet := .F.
				Exit
			EndIf
			If !oAux:IsDeleted(nX) .AND. !lTemItem
				lTemItem := .T.
			Endif
		Next nX
		If !lTemItem .and. lRet
			Help( " ", 1, "AF012LIN") //"O Cadastro do Bem deve possuir ao menos um item."
			lRet := .F.
		EndIf
	EndIf

	//MRG
	// Valida se existe um tipo gerencial se o campo de Margem (N1_MARGEM) foi preenchido
	If lRet .AND. lMargem .AND. !(Empty(oModel:GetValue('SN1MASTER','N1_MARGEM')))

		lTp10ou13 := .F.
		For nX := 1 To oAux:Length()
			If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TIPO', nX) $ ("10|13" + cTypes10) // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
				lTp10ou13 := .T.
				Exit
			Endif
		Next nx

		If !lTp10ou13
			Help(" ", 1, "AF012MARG")  //"Para aplicação de Margem Gerencial na ficha de imobilizado é necessário que seja cadastrado um bem do tipo gerencial (Tipo 10 ou 13)"
			lRet := .F.
		Endif
	Endif


	If lRet .AND. cPaisLoc $ "POR|EUA"

		For nX := 1 To oAux:Length()
			If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TIPO', nX) == "01" .And. Empty(oAux:GetValue('N3_TPDEPR', nX))
				Help("",1,"AF010TPDPR")
				lRet := .F.
				Exit
			EndIf
		Next nX

	EndIf

	If lRet .And. cPaisLoc == "COL"

		If Empty(oModel:GetValue('SN1MASTER','N1_FORNEC')) .OR. EMPTY(oModel:GetValue('SN1MASTER','N1_LOJA'))
			Help("",1,"AF010FORNE")
			lRet := .F.
		Else
			SA2->(DbSetOrder(1))
			If SA2->(DbSeek(xFilial("SA2")+ oModel:GetValue('SN1MASTER','N1_FORNEC') + oModel:GetValue('SN1MASTER','N1_LOJA')))
				If SA2->A2_TIPDOC == "31" .And. Empty(SA2->A2_CGC)
					Help("",1,"AF010NONIT")
					lRet := .F.
				ElseIf SA2->A2_TIPDOC == "13" .And. Empty(SA2->A2_PFISICA)
					Help("",1,"AF010NONIT","",STR0161,1,0) // Debe informar el Tipo de Documento en el catálogo de proveedores.
					lRet := .F.
				EndIf
			Else
				Help("",1,"AF010NOFORNEC")
				lRet := .F.
			EndIf
		EndIf

		If lRet .AND. oAux:GetValue('N3_TIPO') $ ("12|50|51|52|53|54" + cTypes12)

			For nX := 1 to oAux:Length()
				If !oAux:IsDeleted(nX) .AND. nX != n .AND. oAux:GetValue('N3_TIPO', nX) $ ("12|50|51|52|53|54" + cTypes12) .And. Empty(oAux:GetValue('N3_DTBAIXA', nX))
					Help("",1,"A010JADIG")
					lRet := .F.
					Exit
				EndIf
			Next nX

		EndIf

		If lRet

			For nX := 1 to oAux:Length()
				If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TIPO', nX) == "51" .AND. oAux:GetValue('N3_PERDEPR', nX) == 0
					Help("",1,"AF010VDUTI")
					lRet := .F.
					Exit
				EndIf
			Next nX

		EndIf

		If lRet

			For nX := 1 to oAux:Length()
				If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TIPO', nX) == "52" .AND. oAux:GetValue('N3_PERDEPR', nX) == 0
					Help("",1,"AF010VDUTI")
					lRet := .F.
					Exit
				EndIf
			Next nX

		EndIf
	ENDIF


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄas
	//³Validação do campo N3_TIPDEPR³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄas

	If lRet .And. cPaisLoc $ "ARG|BRA|COS"

		For nX := 1 to oAux:Length()
			If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TPDEPR', nX) == "6" .AND. oAux:GetValue('N3_PERDEPR', nX) == 0
				Help("",1,"AF010VDUTI") //" O campo de vida util é obrigatório para esse tipo de depreciação "
				lRet := .F.
				Exit
			EndIf
		Next nX

		If lRet

			For nX := 1 To oAux:Length()
				If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TPDEPR', nX) == "2" .AND.;
				(oAux:GetValue('N3_VLSALV1', nX) == 0 .OR. oAux:GetValue('N3_PERDEPR', nX) == 0)
					Help("",1,"AF010NOSAL") //"Os campos de vida util do bem e valor de salvamento sao obrigatorios para esse tipo de depreciação"
					lRet := .F.
					Exit
				EndIf
			Next nX

		EndIf

		If lRet

			For nX := 1 to oAux:Length()
				If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TPDEPR', nX) == "3" .And. oAux:GetValue('N3_PERDEPR', nX) == 0
					Help("",1,"AF010VDUTI")  //" O campo de vida util é obrigatório para esse tipo de depreciação "
					lRet := .F.
					Exit
				EndIf
			Next nX

		EndIf

		If lRet

			For nX := 1 to oAux:Length()
				If cPaisLoc $ "ARG|BRA|COS"
					If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TPDEPR') $ "4|5|8|9|" .AND. oAux:GetValue('N3_PRODANO') == 0
						Help("",1,"AF010FPROD") //Para calculo pelo método de produção de ativos é necessário informar o fator de produção.
						lRet := .F.
						Exit
					EndIf
					If !oAux:IsDeleted(nX) .AND. ((oAux:GetValue('N3_PRODACM', nX) > 0) .AND.;
					(oAux:GetValue('N3_VRDACM1', nX) == 0) .AND. oAux:GetValue('N3_TPDEPR', nX) $ "4|5|8|9|")
						lRet := .F.
						Help("",1,"AF010PRACM")  //"O valor da depreciação acumulada não foi informado."##"Para bens com produção acumulada é necessário informar o valor da depreciação acumulada."
						Exit
					EndIf

					If !oAux:IsDeleted(nX) .AND. ((oAux:GetValue('N3_VRDACM1', nX) > 0) .AND.;
					(oAux:GetValue('N3_PRODACM', nX) == 0) .AND. (oAux:GetValue('N3_TPDEPR', nX) $ "4|5|8|9|"))
						lRet := .F.
						Help("",1,"AF010VRACM") //"A produção acumulada não foi informada."##"Para bens com depreciação acumulada é necessário informar a produção acumulada."
						Exit
					EndIf
				Else
					If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TPDEPR', nX) $ "4|5" .AND.;
					(oAux:GetValue('N3_PRODMES', nX) == 0 .OR.  oAux:GetValue('N3_PRODANO', nX) == 0)
						Help("",1,"AF010FPROD")  //Para calculo pelo método de produção de ativos é necessário informar o fator de produção.
						lRet := .F.
						Exit
					EndIf
				EndIf
				If lRet .AND. !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TPDEPR',nX) $ "4|5" .AND.;
				oAux:GetValue('N3_PRODMES',nX) > oAux:GetValue('N3_PRODANO',nX)
					Help( " ", 1, "AF012FPRA")// "Para calculo pelo método de produção de ativos a produção do periodo deve ser menor ou igual a produção prevista"
					lRet := .F.
				EndIf
			Next nX

		EndIf

		If lRet

			For nX := 1 To oAux:Length()
				If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TPDEPR', nX) == "7"
					If  oAux:GetValue('N3_VMXDEPR', nX) == 0
						Help("",1,"AF010VMXD") // Para o calculo pelo método Linear com valor maximo de depreciacao é obrigatorio o valor maximo de depreciacao
						lRet := .F.
						Exit
					Else
						lRet := AF012VlMax(oAux:GetValue('N3_VMXDEPR', nX))
						Exit
					Endif
				EndIf
			Next nX

		EndIf

		If lRet
			For nX := 1 to oAux:Length()
				If !oAux:IsDeleted(nX) .AND. !AF012AVTIP(oAux:GetValue('N3_TPDEPR', nX), nX)
					lRet := .F.
					Exit
				EndIf
			Next nX
		EndIf
	EndIf

	If lRet
		If !Empty(oModel:GetValue('SN1MASTER','N1_GRUPO'))
			If !AtfVldCpoCfg(oModel:GetValue('SN1MASTER','N1_GRUPO'), .T.)
				lRet := .F.
			Endif
		Endif
	Endif

	If lRet
		if oModel:GetValue('SN1MASTER','N1_PATRIM') == 'E'
			nPosTipo	:= Ascan(aAux,{|cpo| AllTrim(cpo[3]) == "N3_TIPO"})
			nPosDel	:= Len(oAux:aCols[1])
			If Ascan(oAux:aCols,{|bematf|!(bematf[nPosTipo] $ ("03|13|10" + cTypes10) ) .And. !bematf[nPosDel] }) > 0  // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
				Help( " ", 1, "AF012EMP") //""Só são permitidos os tipos 03 ou 13 quando o Bem for classificado como Custo de Empréstimo"
				lRet := .F.
			Endif
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Validação das regras de tipo de ativo               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


	If lRet .AND. ExistBlock("AF010TOK")
		lRet := ExecBlock("AF010TOK",.F.,.F.)
	Endif

	If PcoBlqFim({{"000154","02"}})
		n_SaveLin := n
		For nX := 1 To oAux:Length()
			If !oAux:IsDeleted(nX)		//aCols[nX][Len(aCols[nX])]
				n := nX
				If lRet
					lRet	:=	PcoVldLan('000154','02','ATFA012',/*lUsaLote*/,/*lDeleta*/, .F./*lVldLinGrade*/)
					If !lRet
						Exit
					EndIf
				EndIf
			EndIf
		Next
		n := n_SaveLin
	EndIf

	If cPaisLoc == "PTG"
		If !Empty(cMoedaFisc) .AND. (!__lAtfAuto)
			If oModel:GetValue('SN1MASTER','N1_ART32') <> "S"
				// ****************************************************
				// Consistencia de moedas: Contabil e Fiscal Portugal *
				// ****************************************************
				nTxMoedaC := oAux:GetValue('N3_TXDEPR1', n)//aCols[n][nPosTxDepC]	N3_TXDEPR1// Taxa da Moeda 1/Contabil
				nTxMoedaF := oAux:GetValue(cNomeTFSN3  , n)//aCols[n][nPosTxDepF]	 // Taxa da Moeda 'n'/Fiscal
				nTxMoedaGF:= &("SNG->" + cNomeTFSNG)	// Taxa da Moeda 'n'/Grupo Fiscal

				If nTxMoedaF > nTxMoedaGF
					Help(" ",1,"AFXATUM01")  // Taxa Fiscal maior da taxa do grupo
				EndIf
				If nTxMoedaC > nTxMoedaGF .AND. nTxMoedaF <> nTxMoedaGF
					Help(" ",1,"AFXATUM02")	// Taxa Fiscal diferente da taxa do grupo
				EndIf
				If nTxMoedaC <= nTxMoedaGF .AND. nTxMoedaF <> nTxMoedaC
					Help(" ",1,"AFXATUM03") // Taxa Fiscal diferente da taxa da moeda Contabil
				EndIf
			Endif
		EndIf
	Endif

	//Ativos Custo/Provisao
	//Valida se existe um tipo gerencial se o campo que classifica o bem como Custo/Provisao foi preenchido
	If lRet .AND. lAtfCusPrv .AND. !(Empty(oModel:GetValue('SN1MASTER','N1_PROVIS')))

		For nX := 1 To oAux:Length()
			If !oAux:IsDeleted(nX) .AND. oAux:GetValue('N3_TIPO', nX) $ ("10|13" + cTypes10) .AND. oAux:GetValue('N3_ATFCPR') == '2' // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
				lRet := MsgYesNo (STR0001  + CRLF + STR0002, STR0003)  //'Existem ativos gerenciais de Custo/Provisão que não estão sendo considerados para os saldos de Custo/Provisão.'###'Deseja continuar assim mesmo?'###'Ativos de Custo/Provisão'
				If !lRet
					Exit
				Endif
			Endif
		Next nX

	Endif


	//-- AVP
	If lRet .AND. !__lCopia

		FA012VldAvp(oModel:GetValue('SN1MASTER','N1_DTAVP'),oModel:GetValue('SN1MASTER','N1_INDAVP'))
		//AVP2
		//Constituicao de provisao
		lRet := AF012TPAVP()
	Endif

	//MRG
	If lRet .AND. lMargem .AND. !__lCopia
		FA012MrgVld(oModel:GetValue('SN1MASTER','N1_MARGEM'),oModel:GetValue('SN1MASTER','N1_REVMRG'))
	Endif

	If lRet .AND. ExistBlock("ATFA012") //Ponto de entrada para validação antes da gravação.
		lRet := ExecBlock("ATFA012",.F.,.F., {oModel, 'MODELPOS', 'SN3DETAIL'})
	EndIf
	/*
	verifica o controle de/em  terceiros */
	If lRet
		If oModel:GetValue('SN1MASTER','N1_TPCTRAT') == "2"
			SNO->(DBSetOrder(2))
			If !SNO->(DBSeek(xFilial("SNO") + oModel:GetValue('SN1MASTER','N1_CBASE') + oModel:GetValue('SN1MASTER','N1_ITEM')))
				Help( " ", 1, "AF012TERC",, STR0125, 1, 0 )		//"É Necessário cadastrar dados de terceiro!"
				lRet := .F.
			Else
				If Empty(oModel:GetValue('SN1MASTER','N1_FORNEC')) .And. Empty(oModel:GetValue('SN1MASTER','N1_LOJA'))  // Incluir
					oModel:LoadValue('SN1MASTER','N1_FORNEC',SNO->NO_FORNEC)
					oModel:LoadValue('SN1MASTER','N1_LOJA',SNO->NO_LOJA)
				EndIf
			EndIf
		Else // Exclui o registro caso o usuario esteja na opcao Incluir
			AF012CanTer(oModel)
		EndIf

		If oModel:GetValue('SN1MASTER','N1_TPCTRAT') == "3"
			SNP->(DBSetOrder(2))
			If !SNP->(DBSeek(xFilial("SNP") + oModel:GetValue('SN1MASTER','N1_CBASE') + oModel:GetValue('SN1MASTER','N1_ITEM')))
				Help( " ", 1, "AF012TERC",, STR0126, 1, 0 )		//"É Necessário cadastrar dados de bens em terceiro!"
				lRet := .F.
			Else
				If Empty(oModel:GetValue('SN1MASTER','N1_FORNEC')) .And. Empty(oModel:GetValue('SN1MASTER','N1_LOJA'))  // Incluir
					oModel:LoadValue('SN1MASTER','N1_FORNEC',SNP->NP_FORNEC)
					oModel:LoadValue('SN1MASTER','N1_LOJA',SNP->NP_LOJA)
				EndIf
			EndIf
		Else // Exclui o registro caso o usuario esteja na opcao Incluir
			AF012CanTer(oModel)
		EndIf
	EndIf

	If lRet .And. ( !Empty(oModel:GetValue("SN1MASTER","N1_GRUPO")) .Or. __lClassifica )
		For nX := 1 To oAux:Length()
			If !oAux:IsDeleted(nX)
				For nCpo := 1 To Len(aAux)
					If aAux[nCpo][10] .And. Empty(oAux:GetValue(aAux[nCpo][3],nX))
						Help(" ",1,"AF012ATDOK",,STR0145 + AllTrim(aAux[nCpo][1]) + " (" + AllTrim(aAux[nCpo][3])+ ") " + STR0146,1,0) //"O campo "###" não foi preenchido."
						lRet := .F.
						Exit
					EndIf
				Next nCpo
			Endif
		Next nX
	EndIf

//Validações para exclusão

ElseIf nOper == 5

	If SN1->N1_STATUS $ '2|3'
		Help(" ",1,"AF010BLOQ")
		lRet := .F.
	EndIf

	If ATFXVerPrj(SN1->N1_CBASE,SN1->N1_ITEM, .T.) .AND. !lAtfa460
		lRet := .F.
	EndIf
	If lIsRussia
		cTpDepr2 := oAux:GetValue('N3_TPDEPR')
		nPerDepr2 := oAux:GetValue('N3_PERDEPR')
		if lRet
			if cTpDepr2=="1" .Or. cTpDepr2=="2" .Or. cTpDepr2=="6"
				if (empty(nPerDepr2) .Or. nPerDepr2==0)
					Help(" ",1,"ATFA012HM")//N3_TPDEPR = 1 or 2 or 6 and N3_PERDEPR empty or = 0
					lRet := .F.
				endif
			endif
		endif
	EndIf

	//Não exclui bens relacionados a Planejamento de Aquisição.
	dbSelectArea("SNN")
	cChaveSNN := IndexKey(2)
	If AllTrim(cChaveSNN) == "NN_FILIAL+NN_CODEFTV+NN_ITMEFTV+NN_CODIGO+NN_ITEM"
		dbSetOrder( 2 )
		If dbSeek(xFilial("SNN")+SN1->N1_CBASE+SN1->N1_ITEM)
			Help(" ",1,"AF012PLAT")	//"Este Ativo esta associado a um Planejamento de Aquisição e não pode ser excluido."
			lRet := .F.
		EndIf
	EndIf

	//Não exclui bens relacionados a controle de provisão
	If lProvis .AND. !Empty(SN1->N1_PROVIS) .AND. !lAtfa460
		Help(" ",1,"AF012PRV")	//'Este Ativo esta associado a controle de provisao e não pode ser excluido.'
		lRet := .F.
	EndIf

	If AFVCustEmp(SN1->N1_CBASE,SN1->N1_ITEM,.T.)
		lRet := .F.
	EndIf

	dbSelectArea("SF9")
	dbSetOrder(1)

	If lRet .AND. SN1->N1_FILIAL != xFilial("SN1")
		HELP(" ",1,"A000FI")
		lRet  := .F.
	EndIf

	If lRet .And. !IsInCallStack( "AF060ExcAu" )
		DbSelectArea("ST9")
		ST9->(dbSetOrder(8)) // T9_FILIAL+T9_CODIMOB
		If ST9->( dbSeek( xFilial() + SN1->N1_CBASE + SN1->N1_ITEM ) )
			Help(" ",1,"AF012EXAMNT")//'Este Ativo esta associado a um bem cadastrado no SIGAMNT.'
			lRet := .F.
		EndIf
	EndIf

	If lRet
		FNF->(dbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
		If FNF->(dbSeek(xFilial("FNF")+SN1->(N1_CBASE+N1_ITEM)+'2'+'1'))
			Help(" ",1,"AF010EXAVP")//'Este Ativo possui movimentos de aproppriação AVP e não poderá ser excluido.'
			lRet := .F.
		Endif
	Endif

	//Verifica se o bem foi gerado por constituição de provisão
	If Alltrim(SN1->N1_ORIGEM) == 'ATFA460' .AND. !lAtfa460
		Help(" ",1,"AF012460E") //'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo somente poderá ser cancelado a partir do processo que o gerou'
		lRet  := .F.
	EndIf

	If lRet
		dbSelectArea('SN3')
		dbSetOrder( 1 )

		If dbSeek(xFilial("SN1") + SN1->N1_CBASE + SN1->N1_ITEM)
			nSavRecSN3 := Recno()
			If lIsRussia
				dbSelectArea("SN4")	////N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR+DTOS(N4_DATA)
				dbSetOrder(4)
				If SN4->(dbSeek(xFilial("SN3") + SN3->N3_CBASE + SN3->N3_ITEM + SN3->N3_TIPO + "06")) ;
					.Or. ( !lIsRussia .and. SN4->(dbSeek(xFilial("SN3") + SN3->N3_CBASE + SN3->N3_ITEM + SN3->N3_TIPO + "61")))
					lRuPermDel := .T.
				EndIf
			EndIf
			// Se houver depreciacao acumulada ou
			// o bem estiver baixado, nao permite a exclusao.
			lTemDeprec := !Empty( SN1->N1_BAIXA) .Or. IIf(SN3->N3_VRDACM1 != 0,ATFV012RAC(SN3->N3_CBASE, SN3->N3_ITEM),.F.)
			If lTemDeprec .And. (! RusCheckRevalFunctions().or. lRuPermDel)
				Help(" ",1, "AF010DEL")
				lRet := .F.
			EndIf

			If(IsInCallStack("ATFA060"))
				aArea_SN3 := SN3->(GetArea())
				cIdMovFNR  := AF060IDFNR(SN1->(N1_CBASE), SN1->(N1_ITEM), xFilial('FNR',cFilAnt), 1)

				IF FNR->(!EOF()) .and. FNR->FNR_IDMOV == cIdMovFNR
					dDataval := FNR->FNR_DATA
				Else
					DbSelectArea("FNR")
					FNR->(DbSetOrder(2)) //FNR_FILIAL+FNR_IDMOV+FNR_CBADES+FNR_ITEDES
					If FNR->(DbSeek(FwXFilial("FNR")+ cIdMovFNR + SN1->(N1_CBASE)+ SN1->(N1_ITEM)))
						dDataval := FNR->FNR_DATA
					EndIf
				EndIf

				RestArea(aArea_SN3)

			EndIf

			If !Empty(dDataBloq) .AND. (dDataval <= dDataBloq)
				Help(" ",1,"AF012ABLQM",,STR0115 + DTOC(dDataBloq) ,1,0) //"A data de aquisição do bem é igual ou menor que a data de bloqueio de movimentação : "
				lRet := .F.
			EndIf
			//Validacao para o bloqueio do processo
			If lRet .And. !CtbValiDt(,dDataval ,.F.,,,{"ATF001"},)
				Help(" ",1,"CTBBLOQ",,STR0135,1,0)//CTBBLOQ - "Calendário Contábil Bloqueado. Verfique o processo."
				lRet := .F.
			EndIf

			If lRet .and. !lIsRussia
				While SN3->(!Eof() .And. XFILIAL("SN3")+SN3->N3_CBASE+SN3->N3_ITEM == XFILIAL("SN1")+SN1->N1_CBASE+SN1->N1_ITEM)
					If Val( SN3->N3_BAIXA ) # 0
						nBaixado++
					EndIf
					nX++
					SN3->(dbSkip( ))
				EndDo
				SN3->(dbGoto(nSavRecSN3))
				If nX == 0
					HELP(" ",1,"AF010NITEM")
					lRet := .F.
				EndIf
				If lRet
					If lCompra .And. SN1->N1_STATUS=="1"
						Help("  ",1,"AF240CLASS")
						lRet := .F.
					EndIf
					dbSelectArea('SN3')
					dbSetOrder(1)
					dbGoto(nSavRecSn3)
				EndIf
			EndIf
		EndIf
	EndIf
	If lRet .AND. SN1->N1_STATUS = '0'
		If Alltrim(SN1->N1_ORIGEM) == 'ATFA310'
	 	   If !IsInCallStack("A310GRVATF")
				Help(" ",1,"AF012EPA") //'Bem planejado somente poderá ser excluido através do estorno da efetivação na rotina de planejamento de ativo (ATFA310)'
				lRet := .F.
			Endif
		EndIf
	EndIf

	//-------------------------------------------------------------
	// Não permite a exclusão de bens originados de transferência
	// entre filiais exceto por meio da rotina ATFA060
	//-------------------------------------------------------------
	If lRet .And. GetMV("MV_ATFCATR",.F.,'2') == '1'
		cQuery := "SELECT * FROM "
		cQuery += RetSqlName("SN4") + " SN4 "
		cQuery += " WHERE "
		cQuery += "N4_FILIAL = '"	+ XFilial("SN4")	+ "' AND "
		cQuery += "N4_CBASE = '"	+ SN1->N1_CBASE		+ "' AND "
		cQuery += "N4_ITEM = '"		+ SN1->N1_ITEM		+ "' AND "
		cQuery += "N4_OCORR = '04' AND "
		cQuery += "SN4.D_E_L_E_T_ = ' ' "

		cQuery := ChangeQuery(cQuery)

		DBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBSN4",.F.,.T.)

		If TRBSN4->(!Eof()) .And. !FWIsInCallStack("ATFA060")
			lRet := .F.
			Help(" ",1,"AF012ATDOK",,STR0134,1,0) //"Bem originado do processo de transferência. Na rotina de transferência, utilize a opção de cancelamento de transferência."
		EndIf
		TRBSN4->(DbCloseArea())
	EndIf

EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CvOk
Realiza a validação da conversão de bens
@author William Matos Gundim Junior
@since  21/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CvOk(nOpcRot)
Local lRet 	  := .T.
Local aCols	  := oGetSN3:aCols
Local nX	  := 0

If nOpcRot == OPC_CONVERSAO

	For nX := 1 to Len(aCols)
		lRet := AF012CvLin(nX)
		If !lRet
			Exit
		EndIf
	Next nX

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AFNG
Preenchimento dos campos dos itens (SN3) de acordo com a tabela SNG
@author William Matos Gundim Junior
@since  21/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AFNG()
Local oModel 	:= FWModelActive()
Local oAux		:= oModel:GetModel( 'SN3DETAIL' )
Local cGrupo	:= oModel:GetValue('SN1MASTER','N1_GRUPO')
Local oSN1		:= oModel:GetModel('SN1MASTER')
Local aArea		:= GetArea()
Local aArea2	:= {}
Local lCont		:= .T.
Local lRet		:= .T.
Local nQtd		:= 0
Local nQtdx		:= 0
Local oStruct	:= oAux:GetStruct()
Local aAux 		:= AClone(oStruct:GetFields())
Local lAtfCusPrv:= AFXAtCsPrv()
Local nX		:= 0
Local aValGrupo	:= {}
Local aValorMoed:= {0,0,0,0,0}
Local aPosVOrig	:= AtfMultPos(aAux,"N3_VORIG",3)
Local lClaLote	:= FwIsInCallStack("AF240Lote") //Se veio por classificação em lote
Local nVeorig1	:= 0
Local nVeorig2	:= 0
Local nVeorig3	:= 0
Local nVeorig4	:= 0
Local nVeorig5	:= 0
Local l012AltGr := ExistBlock("A012ALTG")  //BLOCO PARA SALVAR ACOLS/AHEADER
Local l012aCols := ExistBlock("A012RCOL")  //BLOCO PARA MANIPULAR ACOLS APOS MUDAR GRUPO
Local l012FNG 	:= ExistBlock("A012FNG")  //PE para permitir gatilhar campos customizados
Local nProg		:= 0
Local lATFA012	:= .F.
Local nLinha	:= 1
Local nDepGrpRt AS NUMERIC
Local cDepGrp   AS CHARACTER
Local lFirst 	:= .T.
Local lAtualiza	:= .F.
Local lAltVOri  := GETNEWPAR("MV_ALTVORI", .F.)
Local aDadosNF	:= {}
Local dIniDepr  := ctod("")
Local aCTBEnt   := CTBEntArr()
Local nY        := 0
Local nEntDeb   := 0
Local nEntCre   := 0
Local cCmpCr    := ""
Local cCmpDb    := ""
Local cQuery    := ""
Local cAliFNG   := GetNextAlias()
__LinOK 		:= .F.

//--------------------------------------------------------------------------------------
// Tratamento para identificar se uma das rotinas do ATFA012 está executando o processo
// ex: ATFA012RUS ou ATFA012BRA
//--------------------------------------------------------------------------------------
While !(ProcName(nProg)) == ""
	If "ATFA012" $ Upper(AllTrim(ProcName(nProg)))
		lATFA012 := .T.
		Exit
	EndIf
	nProg++
EndDo

If (!IsBlind() .AND. (lATFA012 .OR. FwIsInCallStack("ATFA240") .Or. FwIsInCallStack("ATFA040"))) .Or. lClaLote .OR. (lIsRussia .AND. (FwIsInCallStack("A103GrvAtf")))
	If oModel:GetOperation() == 3 .Or. __lClassifica//Inclusao
		aArea2:=FNG->(GetArea())
		If !Empty(oModel:GetValue('SN3DETAIL','N3_TIPO'))  .And. !Empty(cGrupo)


			If __cGrupoFNG != cGrupo

				If MsgYesNo(STR0004) //"Essa alteração implicará na perda dos dados digitados, deseja continuar?"

					__cGrupoFNG := cGrupo

					If l012AltGr
						//PONTO DE ENTRADA PARA GUARDAR AHEADER / ACOLS ATUAL
						ExecBlock("A012ALTG",.F.,.F.,{oAux:aHeader, oAux:aCols})
					EndIf
					nQtdx := oAux:Length()

					For nX := 1 To nQtdx
						oAux:GoLine( nX )
				 		If !oAux:IsDeleted()
							aValorMoed := AtfMultMoe(,,{|x| oAux:GetValue(aAux[aPosVOrig[x], 3], nX) } )

							AAdd(aValGrupo,{oAux:GetValue("N3_TIPO"),oAux:GetValue("N3_TPSALDO"),aClone(aValorMoed) })

							//Tratativa para retornar os valores que vieram da NF quando os campos do grupo estiverem em branco
							//Esse ajuste foi necessário devido ao DeleteLine que é utilizado abaixo
							//Esta parte deve sempre ficar antes da deleção da linha
							If (IsInCallStack("ATFA240"))
								Aadd(aDadosNF,{'N3_CCONTAB',oAux:GetValue("N3_CCONTAB")})
								Aadd(aDadosNF,{'N3_CUSTBEM',oAux:GetValue("N3_CUSTBEM")})
								Aadd(aDadosNF,{'N3_CCUSTO',oAux:GetValue("N3_CCUSTO")})
								Aadd(aDadosNF,{'N3_SUBCCON',oAux:GetValue("N3_SUBCCON")})
								Aadd(aDadosNF,{'N3_CLVLCON',oAux:GetValue("N3_CLVLCON")})
								Aadd(aDadosNF,{'N3_AQUISIC',oAux:GetValue("N3_AQUISIC")})

								For nY := 1 To Len(aCTBEnt)
									Aadd(aDadosNF,{'N3_EC'+aCTBEnt[nY]+'CR',oAux:GetValue('N3_EC'+aCTBEnt[nY]+'CR')})
									Aadd(aDadosNF,{'N3_EC'+aCTBEnt[nY]+'DB',oAux:GetValue('N3_EC'+aCTBEnt[nY]+'DB')})
								Next nY
							EndIf
							nLinha	:= oAux:Length() +1

						EndIf
					Next nX
					If __lClassifica .Or. INCLUI
						dIniDepr := oAux:GetValue("N3_DINDEPR")

                        cQuery := "SELECT COUNT(FNG_TIPO) LINHA FROM " +RetSqlName("FNG")+" FNG "
                        cQuery += "WHERE FNG_FILIAL = '"+FWxFilial("FNG")+"' "
                        cQuery += "AND FNG_GRUPO = '"+__cGrupoFNG+"' "
                        cQuery += "AND FNG.D_E_L_E_T_ = '' "

                        dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliFNG,.F.,.T.)

	                    If (cAliFNG)->(!EOF())
                            nLinhaGrupo := (cAliFNG)->(LINHA)
                        EndIf
                        //compara linhas para ver se vai apagar ou nao
                        If  (nLinhaGrupo > 0) .And. (!IsInCallStack("ATFA240")) .And. (nQtdx >= nLinhaGrupo)
                            //Deleta as linhas
                            For nX:= 1 to nQtdx
                                oAux:GoLine( nX )
                                oAux:DeleteLine()
                                __lDelData:= .T.
                            Next nX
							oAux:SetNoInsertLine(.T.)
							oAux:SetNoUpdateLine(.T.)
							oAux:ClearData(.F.)
							oAux:SetNoInsertLine(.F.)
							oAux:SetNoUpdateLine(.F.)

                        EndIf

					EndIf
				Else
					lCont  := .F.
					lRet   := .T.
				EndIf

			Else
				lCont  := .F.
				lRet   := .T.
			EndIf

		EndIf
		If lCont

			//---------------------------------------
			// Preenchimento do cabeçalho (SNG x SN1)
			//---------------------------------------
			SNG->(DBSetOrder(1))
			If SNG->(DBSeek(XFilial("SNG")+cGrupo))

				oSN1:LoadValue('N1_DTBLOQ'	,SNG->NG_DTBLOQ)
				oSN1:LoadValue('N1_TAXAPAD'	,SNG->NG_TAXAPAD)

				If lIsRussia
                    cDepGrp     := SNG->NG_DEPGRP
                    nDepGrpRt   := 0
					nDepGrpRt	:= SNG->NG_PERDEP
					oSN1:SetValue('N1_DEPGRP' ,cDepGrp)
					oSN1:SetValue('N1_PATRIM' ,SNG->NG_PATRIM)
				Endif

				//Preenchimento dos campos (SN1) de acordo com a tabela SNG
				If cPaisLoc == "BRA"
					//Força a atualização do valor de aquisição
					oSN1:LoadValue('N1_VLAQUIS'    ,oAux:GetValue("N3_VORIG1"))

					oSN1:LoadValue('N1_DETPATR' ,SNG->NG_DETPATR)
					oSN1:LoadValue('N1_UTIPATR' ,SNG->NG_UTIPATR)

					If SNG->(ColumnPos("NG_ORIGCRD")) > 0 .AND. EMPTY(oSN1:GetValue("N1_ORIGCRD"))
						oSN1:LoadValue('N1_ORIGCRD' ,SNG->NG_ORIGCRD)
					EndIf

					If SNG->(ColumnPos("NG_CSTPIS")) > 0 .AND. EMPTY(oSN1:GetValue("N1_CSTPIS"))
						oSN1:LoadValue('N1_CSTPIS'  ,SNG->NG_CSTPIS)
					EndIf

					//Campo N1_ALIQPIS existe apenas no Brasil
					If cPaisLoc == "BRA"
						If SNG->(ColumnPos("NG_ALIQPIS")) > 0 .AND. EMPTY(oSN1:GetValue("N1_ALIQPIS"))
							oSN1:LoadValue('N1_ALIQPIS' ,SNG->NG_ALIQPIS)
						EndIf
					EndiF

					If SNG->(ColumnPos("NG_CSTCOFI")) > 0 .AND. EMPTY(oSN1:GetValue("N1_CSTCOFI"))
						oSN1:LoadValue('N1_CSTCOFI' ,SNG->NG_CSTCOFI)
					EndIf

					//Campo N1_ALIQCOF existe apenas no Brasil
					If cPaisLoc == "BRA"
						If SNG->(ColumnPos("NG_ALIQCOF")) > 0 .AND. EMPTY(oSN1:GetValue("N1_ALIQCOF"))
							oSN1:LoadValue('N1_ALIQCOF' ,SNG->NG_ALIQCOF)
						EndIf
					EndIf

					If SNG->(ColumnPos("NG_CODBCC")) > 0 .AND. EMPTY(oSN1:GetValue("N1_CODBCC"))
						oSN1:LoadValue('N1_CODBCC' 	,SNG->NG_CODBCC)
					EndIf

					If SNG->(ColumnPos("NG_CBCPIS")) > 0 .AND. EMPTY(oSN1:GetValue("N1_CBCPIS"))
						oSN1:LoadValue('N1_CBCPIS' 	,SNG->NG_CBCPIS)
					EndIf

					If SNG->(ColumnPos("NG_INDPRO")) > 0 .AND. EMPTY(oSN1:GetValue("N1_INDPRO"))
						oSN1:LoadValue('N1_INDPRO' 	,SNG->NG_INDPRO)
					EndIf
				EndIf
			EndIf

			//----------------------------------------------------------------------------------
			// Preenchimento dos itens (FNG x SN3 ou SNG x SN3 (quando proveniente do ATFA270))
			//----------------------------------------------------------------------------------
			FNG->(DbSetOrder(1))
			If FNG->(DbSeek(xFilial("FNG")+ cGrupo))

				//--------------------------------------------------------------------------------
				// Tira temporariamente a obrigatoriedade dos campos para funcionamento do método
				// AddLine() a validacao ocorrerá posteriormente no LinhaOK e TudoOK
				//--------------------------------------------------------------------------------
				For nX := 1 To Len(aAux)
					If aAux[nX][10]
						oStruct:SetProperty(aAux[nX][3],MODEL_FIELD_OBRIGAT,.F.)
					EndIf
				Next nX
				lFirst := .T.

				While FNG->(!EOF()) .and. cGrupo == FNG->FNG_GRUPO .AND. FNG->FNG_FILIAL == xFilial("FNG")
					nQtd ++
					If oAux:Length(.T.) < nQtd
						oAux:AddLine(.T.)
						oAux:GoLine(oAux:Length())
					Else
						oAux:GoLine(nQtd)
					EndIf

					oAux:LoadValue('N3_TIPO'    ,FNG->FNG_TIPO)
					oAux:LoadValue('N3_HISTOR'  ,FNG->FNG_HISTOR)
					oAux:LoadValue('N3_TPSALDO' ,If(!Empty(FNG->FNG_TPSALD),FNG->FNG_TPSALD,'1'))
					oAux:LoadValue('N3_TPDEPR'  ,If(!Empty(FNG->FNG_TPDEPR),FNG->FNG_TPDEPR,'1'))
					oAux:LoadValue('N3_TXDEPR1' ,If(!Empty(FNG->FNG_TXDEP1),FNG->FNG_TXDEP1,0))
					oAux:LoadValue('N3_TXDEPR2' ,If(!Empty(FNG->FNG_TXDEP2),FNG->FNG_TXDEP2,0))
					oAux:LoadValue('N3_TXDEPR3' ,If(!Empty(FNG->FNG_TXDEP3),FNG->FNG_TXDEP3,0))
					oAux:LoadValue('N3_TXDEPR4' ,If(!Empty(FNG->FNG_TXDEP4),FNG->FNG_TXDEP4,0))
					oAux:LoadValue('N3_TXDEPR5' ,If(!Empty(FNG->FNG_TXDEP5),FNG->FNG_TXDEP5,0))

					If lIsRussia
						oAux:LoadValue('N3_CCONTAB' ,Iif(!Empty(FNG->FNG_CCONTA)	,FNG->FNG_CCONTA,	SNG->NG_CCONTAB))
						oAux:LoadValue('N3_CCDEPR'	,Iif(!Empty(FNG->FNG_CCDEPR)	,FNG->FNG_CCDEPR,	SNG->NG_CCDEPR))
						oAux:LoadValue('N3_CDEPREC'	,Iif(!Empty(FNG->FNG_CDEPRE)	,FNG->FNG_CDEPRE,	SNG->NG_CDEPREC))
						oAux:LoadValue('N3_CDESP'	,Iif(!Empty(FNG->FNG_CDESP)		,FNG->FNG_CDESP,	SNG->NG_CDESP))
						oAux:LoadValue('N3_CCORREC'	,Iif(!Empty(FNG->FNG_CCORRE)	,FNG->FNG_CCORRE,	SNG->NG_CCORREC))
					EndIf

					If lIsRussia .And. nDepGrpRt >= 0
                        oAux:SetValue("N3_PERDEPR", Iif(!Empty(FNG->FNG_PERDEP),FNG->FNG_PERDEP,nDepGrpRt))
                    Endif

					nPos := aScan(aValGrupo , { |x| ALLTRIM(x[1]) == ALLTRIM(FNG->FNG_TIPO) .And. ALLTRIM(x[2]) == ALLTRIM(FNG->FNG_TPSALD)   } )

					//realiza tratamento para quando o bem tiver uma unica linha e mudar o tipo
					If FwIsInCallStack("ATFA240")  .And. nPos == 0 .And. oAux:Length(.T.) == 1
						nPos := 1
					End

					If nPos > 0  .And. len(aValGrupo) >=1
						aValorMoed := aValGrupo[nPos][3]
						AtfMultMoe(,, {|x| oAux:LoadValue(aAux[aPosVOrig[x], 3] , aValorMoed[x] ) })

						//Tratativa para retornar os valores que vieram da NF quando os campos do grupo estiverem em branco
						//Esse ajuste foi necessário devido ao DeleteLine que é utilizado abaixo
						//Esta parte deve sempre ficar antes da função que realiza o preenchimento das entidades pelo grupo (A012SNGCTB)
						If(IsInCallStack("ATFA240")) .And. aValGrupo[nPos][1] == "01" //Só volta os dados da nota para o tipo 01 q é o tipo que veio da nota
							oAux:LoadValue("N3_CCONTAB"	, aDadosNF[1][2])
							oAux:LoadValue("N3_CUSTBEM"	, aDadosNF[2][2])
							oAux:LoadValue("N3_CCUSTO"	, aDadosNF[3][2])
							oAux:LoadValue("N3_SUBCCON"	, aDadosNF[4][2])
							oAux:LoadValue("N3_CLVLCON"	, aDadosNF[5][2])
							oAux:LoadValue("N3_AQUISIC"	, aDadosNF[6][2])

							For nY := 1 To Len(aCTBEnt)
								cCmpCr := 'N3_EC'+aCTBEnt[nY]+'CR'
								cCmpDb := 'N3_EC'+aCTBEnt[nY]+'DB'

								nEntCre := aScan( aDadosNF, {|x| alltrim(x[1]) == cCmpCr} )
								nEntDeb := aScan( aDadosNF, {|x| alltrim(x[1]) == cCmpDb} )

								oAux:LoadValue( cCmpCr, aDadosNF[nEntCre][2] )
								oAux:LoadValue( cCmpDb, aDadosNF[nEntDeb][2] )
							Next nY
						EndIf
					EndIf

					//----------------------------------------
					// Preenchimentos das entidades contabeis
					//----------------------------------------
					A012SNGCTB(oAux,cGrupo,.T.)

                    //----------------------------------------
					// Preenchimentos das entidades adicionais
					//----------------------------------------
                    A012SetEAdc(oAux)

					If cPaisLoc == "ARG"
						oAux:LoadValue('N3_CRIDEPR' ,FNG->FNG_CRIDEP)
						oAux:LoadValue('N3_CALDEPR' ,FNG->FNG_CALDEP)
					EndIf
					//Ativos Custo/provisao
					If lAtfCusPrv
						oAux:LoadValue('N3_ATFCPR',FNG->FNG_ATFCPR)
					Endif

					oAux:LoadValue('N3_VMXDEPR',If(FNG->FNG_TPDEPR == '7',SNG->NG_VMXDEPR,0))

					If lAltVOri .AND. !FwIsInCallStack("ATFA240") //MV_ALTVORI e origem diferente de ATFA040
						If  lFirst
							If MsgNoYes(STR0165) // "Altera o valor original descontando a aliquota de PIS e COFINS?"
								lAtualiza := .T.
							EndIf
							lFirst := .F.

							If lAtualiza
								//Campo N1_ALIQPIS existe apenas no Brasil
								If cPaisLoc == "BRA"
									nVeorig1 := aValorMoed[1] - (aValorMoed[1] *  ((oSn1:GetValue("N1_ALIQPIS") + oSn1:GetValue("N1_ALIQCOF")) / 100))
									nVeorig2 := aValorMoed[2] - (aValorMoed[2] *  ((oSn1:GetValue("N1_ALIQPIS") + oSn1:GetValue("N1_ALIQCOF")) / 100))
									nVeorig3 := aValorMoed[3] - (aValorMoed[3] *  ((oSn1:GetValue("N1_ALIQPIS") + oSn1:GetValue("N1_ALIQCOF")) / 100))
									nVeorig4 := aValorMoed[4] - (aValorMoed[4] *  ((oSn1:GetValue("N1_ALIQPIS") + oSn1:GetValue("N1_ALIQCOF")) / 100))
									nVeorig5 := aValorMoed[5] - (aValorMoed[5] *  ((oSn1:GetValue("N1_ALIQPIS") + oSn1:GetValue("N1_ALIQCOF")) / 100))
								EndIf
							Else
								nVeorig1 := aValorMoed[1]
								nVeorig2 := aValorMoed[2]
								nVeorig3 := aValorMoed[3]
								nVeorig4 := aValorMoed[4]
								nVeorig5 := aValorMoed[5]
							EndIf
						EndIf

						//Moeda1
						oAux:LoadValue('N3_VORIG1',nVeorig1)

						//Moeda 2
						oAux:LoadValue('N3_VORIG2',nVeorig2)

						//Moeda 3
						oAux:LoadValue('N3_VORIG3',nVeorig3)

						//Moeda4
						oAux:LoadValue('N3_VORIG4',nVeorig4)

						//Moeda5
						oAux:LoadValue('N3_VORIG5',nVeorig5)
					EndIf

					//Quando for classificação em lote Atualiza os valores
					If lClaLote

						If !Empty(oAux:GetValue("N3_VORIG1"))
							//Obtem o valor da primeira linha
							nVeorig1 := oAux:GetValue("N3_VORIG1")
						Else
							//Atribui o valor da primeira linha nas demais que não possuem valor (Uso  Grupo de bens)
							oAux:LoadValue('N3_VORIG1',nVeorig1)
							cGrupo := "" //Limpa a variavel do grupa quando for lote.
						EndIf

						//Moeda 2
						If !Empty(oAux:GetValue("N3_VORIG2"))
							//Obtem o valor da primeira linha
							nVeorig2 := oAux:GetValue("N3_VORIG2")
						Else
							//Atribui o valor da primeira linha nas demais que não possuem valor (Uso  Grupo de bens)
							oAux:LoadValue('N3_VORIG2',nVeorig2)
						EndIf

						//Moeda 3
						If !Empty(oAux:GetValue("N3_VORIG3"))
							//Obtem o valor da primeira linha
							nVeorig3 := oAux:GetValue("N3_VORIG3")
						Else
							//Atribui o valor da primeira linha nas demais que não possuem valor (Uso  Grupo de bens)
							oAux:LoadValue('N3_VORIG3',nVeorig3)
						EndIf

						//Moeda 4
						If !Empty(oAux:GetValue("N3_VORIG4"))
							//Obtem o valor da primeira linha
							nVeorig4 := oAux:GetValue("N3_VORIG4")
						Else
							//Atribui o valor da primeira linha nas demais que não possuem valor (Uso  Grupo de bens)
							oAux:LoadValue('N3_VORIG4',nVeorig4)
						EndIf

						//Moeda 5
						If !Empty(oAux:GetValue("N3_VORIG5"))
							//Obtem o valor da primeira linha
							nVeorig5 := oAux:GetValue("N3_VORIG5")
						Else
							//Atribui o valor da primeira linha nas demais que não possuem valor (Uso  Grupo de bens)
							oAux:LoadValue('N3_VORIG5',nVeorig5)
						EndIf

						If lIsRussia
							If !Empty(FNG->FNG_CCDEPR)
								oAux:LoadValue('N3_CCDEPR' ,FNG->FNG_CCDEPR)
							Endif
							If !Empty(FNG->FNG_CCONTA)
								oAux:LoadValue('N3_CCONTAB' ,FNG->FNG_CCONTA)
							Endif
							If !Empty(FNG->FNG_CCORRE)
								oAux:LoadValue('N3_CCORREC' ,FNG->FNG_CCORRE)
							Endif
							If !Empty(FNG->FNG_CDEPRE)
								oAux:LoadValue('N3_CDEPREC' ,FNG->FNG_CDEPRE)
							Endif
							If !Empty(FNG->FNG_CDESP)
								oAux:LoadValue('N3_CDESP' ,FNG->FNG_CDESP)
							Endif
						Endif

					EndIf

					If l012FNG
						//Ponto de Entrada, para permitir gatilhar campos customizados
						ExecBlock("A012FNG",.F.,.F.,{oAux:aHeader, oAux:aCols, oAux})
					EndIf

					FNG->(DbSkip())
				EndDo
				__cGrupoFNG := cGrupo

				//--------------------------------------
				// Retorna a obrigatoriedade dos campos
				//--------------------------------------
				For nX := 1 To Len(aAux)
					If aAux[nX][10]
						oStruct:SetProperty(aAux[nX][3],MODEL_FIELD_OBRIGAT,.T.)
					EndIf
				Next nX

			ElseIf SNG->(MsSeek(xFilial("SNG")+cGrupo)) //Necessario para gatilhar os dados em cadastros de grupo de bens provenientes da rotina ATFA270(LEGADO) pois nesse caso terei apenas SNG e não terei FNG

				//Na alteracao do grupo, eh apagada a linha e precisa criar a nova
				If oAux:Length(.T.) == 0
					oAux:AddLine()
					oAux:GoLine(oAux:Length())
				EndIf

				For nX:= 1 to oAux:Length()
					oAux:GoLine(nX)
					If !oAux:IsDeleted()
						A012SNGCTB(oAux,cGrupo,.T.)

						//-----------------------------------------------
						//Complemente de preenchimento dos campos da SN3
						//-----------------------------------------------
						If SNG->(ColumnPos("NG_TPSALDO")) > 0 .And. SNG->(ColumnPos("NG_TPDEPR")) > 0 //Tratamento necessário até inclusão dos campos para o México no ATUSX (No Brasil já estão ok)
							oAux:LoadValue('N3_TPSALDO'	,If(!Empty(SNG->NG_TPSALDO)	,SNG->NG_TPSALDO	,'1'	))
							oAux:LoadValue('N3_TPDEPR'	,If(!Empty(SNG->NG_TPDEPR)	,SNG->NG_TPDEPR		,'1'	))
						EndIf
						oAux:LoadValue('N3_TXDEPR1'	,If(!Empty(SNG->NG_TXDEPR1)	,SNG->NG_TXDEPR1	,0		))
						oAux:LoadValue('N3_TXDEPR2'	,If(!Empty(SNG->NG_TXDEPR2)	,SNG->NG_TXDEPR2	,0		))
						oAux:LoadValue('N3_TXDEPR3'	,If(!Empty(SNG->NG_TXDEPR3)	,SNG->NG_TXDEPR3	,0		))
						oAux:LoadValue('N3_TXDEPR4'	,If(!Empty(SNG->NG_TXDEPR4)	,SNG->NG_TXDEPR4	,0		))
						oAux:LoadValue('N3_TXDEPR5'	,If(!Empty(SNG->NG_TXDEPR5)	,SNG->NG_TXDEPR5	,0		))
						If SNG->(ColumnPos("NG_TPDEPR")) > 0 //Tratamento necessário até inclusão dos campos para o México no ATUSX (No Brasil já estão ok)
							oAux:LoadValue('N3_VMXDEPR'	,If(SNG->NG_TPDEPR == '7'	,SNG->NG_VMXDEPR	,0		))
						EndIf
						If cPaisLoc <> "BRA"

	                        oAux:LoadValue("N3_CCONTAB"	,If(!Empty(SNG->NG_CCONTAB), SNG->NG_CCONTAB, Iif( Len(aDadosNF)>=1, aDadosNF[1][2],"" )))
							oAux:LoadValue("N3_CUSTBEM"	,If(!Empty(SNG->NG_CUSTBEM), SNG->NG_CUSTBEM, Iif( Len(aDadosNF)>=2, aDadosNF[2][2],"" )))
							oAux:LoadValue("N3_CCUSTO"	,If(!Empty(SNG->NG_CCUSTO),  SNG->NG_CCUSTO,  Iif( Len(aDadosNF)>=3, aDadosNF[3][2],"") ))
							oAux:LoadValue("N3_SUBCCON"	,If(!Empty(SNG->NG_SUBCCON), SNG->NG_SUBCCON,Iif( Len(aDadosNF)>=4,  aDadosNF[4][2],"") ))
							oAux:LoadValue("N3_CLVLCON"	,If(!Empty(SNG->NG_CLVLCON), SNG->NG_CLVLCON, Iif( Len(aDadosNF)>=5, aDadosNF[5][2],"") ))
							If Len(aDadosNF)>=6
								oAux:LoadValue("N3_AQUISIC"	, aDadosNF[6][2])
							EndIf
							If len(aValGrupo) >=1
								oAux:LoadValue('N3_TIPO'	,aValGrupo[len(aValGrupo),1]	)
								oAux:LoadValue('N3_TPSALDO'	,aValGrupo[len(aValGrupo),2]	)

								aValorMoed := aValGrupo[len(aValGrupo),3]
								AtfMultMoe(,, {|x| oAux:LoadValue(aAux[aPosVOrig[x], 3] , aValorMoed[x] ) })
							Endif
						Endif

					EndIf
				Next

			EndIf
			If l012aCols
				//PONTO DE ENTRADA PARA MANIPULAR ACOLS APOS CARGA DA FNG
				ExecBlock("A012RCOL",.F.,.F.,{oAux:aHeader, oAux:aCols, oAux})
			EndIf
		EndIf
		FNG->(RestArea(aArea2))
	EndIf
	RestArea(aArea)

EndIf

// Preenchimento da data inicio de depreciação de acordo com MV_PAR04
If oAux:Length() > 0 .And. __lClassifica .And. !Empty(cGrupo) .And. !Empty(dIniDepr)
	nQtdx := oAux:Length()
	For nX := 1 To nQtdx
		oAux:GoLine( nX )
		If !oAux:IsDeleted()
			oAux:LoadValue('N3_DINDEPR',dInidepr)
		EndIf
	Next nX
EndIf

//Posiciona na primeira linha não deletada
If oAux:Length(.T.) == oAux:Length()
	oAux:GoLine(1)
Else
	oAux:GoLine(nLinha)
Endif

__LinOK := .T.

//Limpa variavel statica grupo qndo for classificação em lote
If lClaLote
	__cGrupoFNG := ""
EndIf

/*/Recarrega os campos, pois por algum motivo quando ele busca o view na função abaixo pelo FWModelActive na view
ele perde os dados dos campos da aba das informações fiscais ao chamar FWModelActive na função AF012AVPWhen.
*///
/*
Alterado por Jeferson Couto em 01/11/2021
Incluído !IsBlind() para executar o refresh do formulário apenas quando não for executado pela rotina automática ExecAuto
*/
If !IsBlind() .And. !__lClassifica
	ATF012VIEW()
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ACTA
Verifica validade de uma determinada conta contabil.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ACTA()
Local lRet   := .T.
Local cAlias := Alias( )
Local oModel := FWModelActive()
Local oAux	 := Nil
Local cCampo := Strtran(ReadVar(),"M->","")

If oModel != Nil
	oAux:= oModel:GetModel('SN3DETAIL')
	If !oAux:IsInserted(oAux:GetLine()) .AND. !__lClassifica .AND. !__lCopia .AND. !IsInCallStack("ATFA040")
		Help(" ",1,"AF012VCTA", ,STR0163,1,0,,,,,,{STR0164} ) //Este campo não pode ser alterado####Se esta operação for inevitável, exclua e inclua novamente o registro ou utilize a rotina de transferência.
		lRet := .F.
	Endif

	If lRet
		If !Empty(&(ReadVar()))
			lRet := Ctb105Cta()
			If lRet
				oAux:LoadValue(cCampo ,&(ReadVar())) // Caso seja Conta reduzida commito no model o valor da conta completa
			EndIf
			dbSelectArea( cAlias )
		EndIf
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A012TxRAlt
Verifica se pode alterar a taxa regulamentada
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function A012TxRAlt(cGrupo)
Local aArea		:= GetArea()
Local aAreaSNG	:= SNG->(GetArea())
Local oModel  	:= FWModelActive()
Local lRet		:= If(oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4 .or. FwIsInCallStack("ATFA240") , .T., .F.)

//Retirado validações -  MSERV-810

RestArea(aAreaSNG)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AVPWhen
Permitir ou nao a digitacao do campo N1_INDAVP
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AVPWhen()
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local lMargem 	:= AFMrgAtf() //MRG
Local lProvis 	:= AFPrvAtf() //Verifica implementacao da Controle de Provisao
Local oModel 	:= FWModelActive()

//Se o tratamento de Margem Gerencial nao estiver implementado, nao se aplica esse controle
If lMargem .AND. !Empty(IIf(Valtype(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_MARGEM'),M->N1_MARGEM))
	lRet := .F.
Endif

//PRV
//Se o tratamento de controle de provisao estiver preenchido, nao se aplica esse controle
If lProvis .AND. lRet .AND. !Empty(IIf(Valtype(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_PROVIS'),M->N1_PROVIS))
	lRet := .F.
Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012PrvWhen
Permitir ou nao a digitacao do campo N1_PROVIS
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012PrvWhen()
Local lRet 		:= .T.
Local aArea 	:= GetArea()
Local aAreaSN3	:= SN3->(GetArea())
Local lProvis 	:= AFPrvAtf() //PRV
Local oModel 	:= FWModelActive()

//Se o tratamento de Controle de Provisao estiver implementado, nao posso alterar o campo N1_MARGEM
If !lProvis
	lRet := .F.
Endif

//Bens ligados a projeto nao podem ser relacionados a um controle de provisão
//Bens que possuam AVP nao podem ser relacionados a um controle de provisão
//Bens que possuam margem gerencial nao podem ser relacionados a um controle de provisão
If lRet .AND. (!Empty(IIF(VALTYPE(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_PROJETO'),M->N1_PROJETO)) .OR. ;
!Empty(IIF(VALTYPE(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_INDAVP'),M->N1_INDAVP)) ;
.OR. !Empty(IIF(VALTYPE(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_MARGEM'),M->N1_MARGEM)))
	lRet := .F.
Endif

//Se a ficha de imobilizado ja estiver relacionada a um controle de provisão, nao posso alterar o campo N1_PROVIS
If lRet .and. !Empty(SN1->N1_PROVIS)
	FNX->(dbSetOrder(2))  //FNX_FILIAL+FNX_CBASE+FNX_ITEM+FNX_TIPO+FNX_TPSALD
	If FNX->(MsSeek(xFilial("FNX")+;
	IIF(VALTYPE(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_CBASE'),M->N1_CBASE)+;
	IIF(VALTYPE(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_ITEM'),M->N1_ITEM)))  //Ja existe regra de margem gerencial
		lRet := .F.
	Endif
Endif

RestArea(aAreaSN3)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012MrgWhen
//Permitir ou nao a digitacao do campo N1_MARGEM
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012MrgWhen()
Local lRet 	   := .T.
Local aArea    := GetArea()
Local aAreaSN3 := SN3->(GetArea())
Local lMargem  := AFMrgAtf() //MRG
Local lProvis  := AFPrvAtf() //Verifica implementacao da Controle de Provisao
Local oModel   := FWModelActive()

//Se o tratamento de Margem Gerencial nao estiver implementado, nao posso alterar o campo N1_MARGEM
If !lMargem
	lRet := .F.
Endif

//PRV
//Se o tratamento de controle de provisao estiver preenchido, nao se aplica esse controle
If lProvis .and. lRet .and. !Empty(IIF(ValType(oModel) <>  "U",oModel:GetValue('SN1MASTER','N1_PROVIS'),M->N1_PROVIS))
	lRet := .F.
Endif

//Bens ligados a projeto nao tem margem gerencial
//Bens que possuam AVP nao podem ter margem gerencial
If lRet .AND. (!Empty(IIF(Valtype(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_PROJETO'),M->N1_PROJETO)) .OR. ;
!Empty(IIF(ValType(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_INDAVP'),M->N1_INDAVP)))
	lRet := .F.
Endif

//Se a ficha de imobilizado ja possuir bem do tipo 15, nao posso alterar o campo N1_MARGEM
If lRet
	SN3->(dbSetOrder(1))  //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
	If SN3->(MsSeek(xFilial("SN3") + ;
	IIF(Valtype(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_CBASE'), M->N1_CBASE) + ;
	IIF(Valtype(oModel) <> "U",oModel:GetValue('SN1MASTER','N1_ITEM'),M->N1_ITEM) + "15"))  //Ja existe regra de margem gerencial
		lRet := .F.
	Endif
Endif

RestArea(aAreaSN3)
RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}ATF012WHEN
When do campo N1_TPCTRAT
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function ATF012WHEN()
Local lRet 	  := .T.
Local oModel  := FWModelActive()
Local lInclui := If(oModel:GetOperation() == 3, .T., .F.)

If !lInclui
	If !Empty(SN1->N1_TPCTRAT) .AND. SN1->N1_TPCTRAT <> "1"
		lRet := .F.
	EndIf
EndIf


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012UPRJ
When do campo N1_PROJETO
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012UPRJ()
Local lRet 		:= .F.
Local lBpiAtf   := AFVldBpi() //Verifico se a Baixa de Provisao de Imobilizado esta implantada
Local oModel 	:= FWModelActive()

//Apenas bens que nao tenham sido geradas por projeto poderao ter acesso ao campo N1_PROJETO
If AllTrim(M->N1_ORIGEM) != "ATFA430"
	If lBpiAtf
		If oModel:GetOperation() == 3 //Inclusao
			lRet := .T.
		ElseIf oModel:GetOperation() == 4 //Alteracao
			If Empty( oModel:GetValue('SN1MASTER','N1_PROJETO'))
				lRet := .T.
			//Verifica se esse bem NAO possui relacionamento de execuao com projeto
			ElseIf !(FaVRelPrj(3,xFilial("FNJ")+oModel:GetValue('SN1MASTER','N1_PROJETO')+;
			oModel:GetValue('SN1MASTER','N1_CBASE') + oModel:GetValue('SN1MASTER','N1_ITEM')))
				lRet := .T.
			Endif
		Endif
	Endif
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}A012VInAVP
Validação da data do AVP.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function A012VInAVP()
Local lRet   := .T.
Local oModel := FWModelActive()

If oModel:GetValue('SN1MASTER','N1_INIAVP') < oModel:GetValue('SN1MASTER','N1_AQUISIC')
	Help( " ", 1, "AF012INIAVP") //"Data de Inicio do AVP deve ser maior ou igual que a data de aquisição do ativo"
	lRet := .F.
EndIf

oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ACHAP
Validações para o preenchimento da chapa.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ACHAP(nChapa,lRepChapa)
Local oModel		:= FWModelActive()
Local oSN1			:= oModel:GetModel("SN1MASTER")
Local oStruSN1		:= oSN1:GetStruct()
Local aArea 		:= GetArea()
Local aAreaSN1 		:= SN1->(GetArea())
Local lRet			:= .T.
Local cRotina		:= Alltrim(FunName())
Local cBase			:= oSN1:GetValue("N1_CBASE")
Local cItem			:= oSN1:GetValue("N1_ITEM")
Local cStatus		:= oSN1:GetValue("N1_STATUS")
Local cNomeCpo		:= oStruSN1:GetProperty("N1_CHAPA",MODEL_FIELD_TITULO)
Local cDescCpo		:= oStruSN1:GetProperty("N1_CHAPA",MODEL_FIELD_TOOLTIP)
Local lMile     	:= IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")

Default nChapa		:= oSN1:GetValue('N1_CHAPA')
Default lRepChapa	:= Nil

If lRepChapa == Nil
	If cRotina == "ATFA012" .or. cRotina == "ATFA040" .or. cRotina == "ATFA040"
		lRepChapa := MV_PAR02 == 1
	ElseIf cRotina == "ATFA250" .or. cRotina == "ATFA251"
		lRepChapa := MV_PAR03 == 1
	ElseIf cRotina == "ATFA240"
		Pergunte("AFA240",.F.)
		lRepChapa := MV_PAR02 == 1
		Pergunte("AFA012",.F.)
		AF012PerAut()
	Else
		lRepChapa := MV_PAR02 == 1
	EndIf
EndIf

If ExistBlock("AF012CHP")
	lRet := ExecBlock("AF012CHP",.F.,.F.,{nChapa,lRepChapa})
	lRet := If(ValType(lRet) == "L",lRet,.F.)
Else
	If !lRepChapa
		If Empty(nChapa)
			If !(cStatus == "0") .or. FwIsInCallStack("ATFA240")
				Help(" ",1,"AF012ACHAP",,cDescCpo + STR0152,1,0,,,,,,{STR0153 + cNomeCpo + "." }) //" não informado."###"Preencha o campo "
				lRet := .F.
			EndIf
		ElseIf lMile
			If AF12CHPMIL(nChapa)
				Help(" ",1,"AF012ACHAP",,cDescCpo + STR0154,1,0,,,,,,{STR0155 + cNomeCpo + "."}) //" já existente no sistema."###"Defina um novo código no campo "
				lRet:= .F.
			EndIf
		Else
			DBSelectArea("SN1")
			DBSetOrder(2)
			If DBSeek(XFilial("SN1") + nChapa) .And. cBase+cItem != SN1->(N1_CBASE+N1_ITEM)
				Help(" ",1,"AF012ACHAP",,cDescCpo + STR0154,1,0,,,,,,{STR0155 + cNomeCpo + "."}) //" já existente no sistema."###"Defina um novo código no campo "
				lRet := .F.
			EndIf
		EndIf
	EndIf
EndIf

RestArea(aAreaSN1)
RestArea(aArea)

Return lRet
//

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ACIAP
Validar o código CIAP informado.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ACIAP()
Local oModel   := FWModelActive()
Local cCodCiap := oModel:GetValue('SN1MASTER','N1_CODCIAP')
Local cICMS    := oModel:GetValue('SN1MASTER','N1_ICMSAPR')
Local nOper    := oModel:GetOperation() // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
Local lRet     := .T.
Local cCampo   := ReadVar()

dbSelectArea("SF9")
dbSetOrder(1)
If (dbSeek(xFilial("SF9")+ cCodCiap))
	If ( SF9->F9_VLESTOR != 0 .AND. SF9->F9_VALICMS - SF9->F9_ICMIMOB == 0 )
		Help(" ",1,"AF010CIAP1")// “Crédito de ICMS estornado não pode ser apropriado.”.
		lRet := .F.
	EndIf
EndIf
If ( "N1_ICMSAPR" $ AllTrim(cCampo) .AND. SF9->(Found()) )
	If ( SF9->F9_VALICMS - SF9->F9_ICMIMOB < cICMS )
		Help(" ",1,"AF010CIAP2") //“Valor da apropriação do Credito de ICMS maior que o saldo.”.
		lRet := .F.
	EndIf
	If ( nOper == 4 .And. lRet )
		If ( !Empty(SN1->N1_CODCIAP) .AND. SN1->N1_ICMSAPR != cICMS )
			Help(" ",1,"AF010CIAP3") //“Não é permitido à alteração do valor correspondente ao Crédito de ICMS do bem.”.
			lRet := .F.
		EndIf
	EndIf
EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ANALT
Validar a data de aquisição
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ANALT()
Local lRet  := (__lCopia .OR. __lClassifica .OR. IsBlind())
Local oModel := FWModelActive()
Local cBase := oModel:GetValue('SN1MASTER','N1_CBASE')
Local nItem := oModel:GetValue('SN1MASTER','N1_ITEM')

//Executar quando não forem os processos de Cópia ou Classificação.
If !lRet
	If xFilial("SN1")+ cBase + nItem == SN1->N1_FILIAL + SN1->N1_CBASE + SN1->N1_ITEM
		Help(" ",1,"AFA010NAOP") //“Este campo não pode ser alterado.”
		lRet := .F.
	Else
		lRet := .T.
	Endif
EndIf

oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012TPAVP
Validação do tipo de AVP
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012TPAVP()
Local lRet := .T.
Local oModel 	 := FWModelActive()

//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela
//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
If oModel:GetValue('SN1MASTER','N1_TPAVP') == '2' .AND. oModel:GetValue('SN1MASTER','N1_PATRIM') != 'O'
	Help( " ", 1, "AF012TPAVP" )
	lRet := .F.
Endif

oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}FA012PrvVld
Valida preenchimento dos campos necessarios para Provisao
@param cMargem -> Código da regra de margem gerencial
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FA012PrvVld(cProvis)
Local lRet		:= .F.
Local cRevPrv	:= ""
Local lProvis := AFPrvAtf() //Verifica implementacao do controle de provisao
DEFAULT cProvis := ""

//Se os campos referente a Provisao estiverem em branco
If !lProvis .or. Empty(cProvis)
	lRet := .T.
Else
	cRevPrv := AF490GetRev(cProvis,.F.)
	dbSelectArea('FNU')
	FNU->(dbSetOrder(1))
	If !(FNU->(MsSeek(xFilial("FNU")+cProvis+cRevPrv)))
		Help("  ",1,"AF12NOPROVIS") //Help "Controle de Provisão não cadastrado"
		lRet := .F.
	ElseIf FNU->FNU_MSBLQL == "1"  //Bloqueado
		Help("  ",1,"AF12PROVISBLQ")//Help "Controle de provisão bloqueado para uso. Utilize outro controle de provisão"
		lRet := .F.
	ElseIf (FNU->FNU_STATUS $ "0/3")  //1 = Ativo; A = Pendente Realizacao
		Help("  ",1,"AF12PROVISATV") //"Controle de provisão possui status que não permite relacionamento de bens de execução. Apenas controles de provisão com status Ativo ou Pendente Realização podem ser relacionadas a um imobilizado."
		lRet := .F.
	Else
		lRet := .T.
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AEXST
Valida a data de exaustao do bem
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AEXST( )
Local dExaust        := ctod("")
Local dInidepr       := ctod("")
Local lDtVazia, lRet := .T.
Local oModel         := FWModelActive()
Local cMoedEx	     := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))

dExaust  := &(ReadVar())
lDtVazia := Empty(dExaust)  // Se n„o houver data de exaust„o, retorna.

If !lDtVazia
	dIniDepr := oModel:GetValue('SN3DETAIL','N3_DINDEPR')
	If oModel:GetValue('SN3DETAIL','N3_VRDBAL' + cMoedEx) > 0
		Help(" ",1, "AFA010EXA1" ) 	//"Quando for informada a data de exaustão não é permitido digitar a depreciação acumulada."
		lRet := .F.
	Endif
	If lRet
		If dIniDepr >= dExaust
			Help(" ",1,"AFA010EXA2") //"Data de exaustão inválida. Verifique se esta data está menor ou igual à data base ou menor ou igual à data de início de depreciação, que são condições inválidas.”.
			lRet := .F.
		Endif
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012VLAEC
Valida o critério de depreciação
@author William Matos Gundim Junior
@since  22/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012VLAEC(nLinha) //AJUSTAR PARA POSICIONAR NA LINHA CORRETA DA SN3
Local cFldAcum := ""
Local cFldAmpl := ""
Local cFldCAcm := ""
Local nQtdMo	:= 0
Local nI		:= 0
Local nMeses	:= 0
Local aPeriodo	:= {}
Local aVlrAcum	:= {}
Local aVlrAmpl	:= {}
Local aVlrOrig	:= {}
Local aVlrCAcm	:= {}
Local aVlrCda	:= {}
Local aTaxaMes	:= {}
Local aTaxaAux	:= {}
Local aColsClon	:= {}
Local aParamN3	:= Array(9)
Local aCotaM	:= AtfMultMoe(,,{|x| 0})
Local aValores	:= {}
Local lRet		:= .T.
Local lResidual:= .F.

//ATFA012
Local cVrcda := ""
Local cOri   := ""
Local cTxDepr:= ""
Local oModel := Nil
Local nProdAcm
Local nProdAno
Local oAux		:= Nil
Local oStruct	:= Nil
Local aAux		:= Nil


//ATFA251
Local nPosAcum	:= 0
Local nPosAmpl	:= 0
Local nPosValor	:= 0
Local nPosTaxa	:= 0
Local nPosVar		:= 0
Local nPosCAcm	:= 0
Local nPosVrcda	:= 0
Local aHeader  	:= {}
Local nPCriDepr	:= 0
Local nPCalDepr	:= 0
Local nPAquisic	:= 0
Local nPTpDepr	:= 0
Local nPVmxDepr	:= 0
Local nPPerDepr	:= 0
Local nPVlSalv1	:= 0
Local nPProdMes	:= 0
Local nPProdAcm	:= 0
Local nPProdAno	:= 0
Local nPFimDepr	:= 0
Local nPDInDepr	:= 0
Local dDataCalc	:= stod("")


If FwIsInCallStack("ATFA251")

	nPCriDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_CRIDEPR"})
	nPCalDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_CALDEPR"})
	nPAquisic	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_AQUISIC"})
	nPTpDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_TPDEPR"})
	nPVmxDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_VMXDEPR"})
	nPPerDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PERDEPR"})
	nPVlSalv1	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_VLSALV1"})
	nPProdMes	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PRODMES"})
	nPProdAcm	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PRODACM"})
	nPProdAno	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_PRODANO"})
	nPFimDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_FIMDEPR"})
	nPDInDepr	:= aScan(aHeader,{|x| alltrim(x[2]) == "N3_DINDEPR"})

	If ValType(nLinha) == Nil
		nLinha := n
	EndIf


	If !(cPaisLoc $ "ARG|BRA|COS") .AND. (SN3->(FieldPos("N3_CRIDEPR")) == 0 .OR. SN3->(FieldPos("N3_CALDEPR")) == 0)
		Return(lRet)
	Endif

	If nPCriDepr == 0 .or. nPCalDepr == 0
		Return(lRet)
	Endif

	dDataCalc := M->N1_AQUISIC//dDataBase
	aColsClon := aClone(aCols)
	nPosVar := aScan(aHeader,{|x| alltrim(x[2]) == Alltrim(substr(ReadVar(),4)) })

	If nPosVar > 0
		aColsClon[nLinha,nPosVar] := &(ReadVar())
	Endif


	If alltrim(aColsClon[nLinha,nPCriDepr]) == "03"
		If ( Alltrim(aColsClon[nLinha,nPTpDepr]) <> "8" .and. !Empty(aColsClon[nLinha,nPCalDepr]) ) .or. Alltrim(aColsClon[nLinha,nPTpDepr]) == "8"
			nQtdMo := AtfMoedas()

			For nI := 1 to nQtdMo
				If nI <= 9
					cFldAcum := "N3_VRDACM" + ALLTRIM(Str(nI))
					cFldAmpl := "N3_AMPLIA" + ALLTRIM(Str(nI))
					cFldCAcm := "N3_VRCACM" + ALLTRIM(Str(nI))
				Else
					cFldAcum := "N3_VRDAC" + ALLTRIM(Str(nI))
					cFldAmpl := "N3_AMPLI" + ALLTRIM(Str(nI))
					cFldCAcm := "N3_VRCAC" + ALLTRIM(Str(nI))
				Endif

				nPosAcum 	:= aScan(aHeader, {|x| alltrim(x[2]) == cFldAcum } )
				nPosAmpl	:= aScan(aHeader, {|x| alltrim(x[2]) == cFldAmpl } )
				nPosCAcm	:= aScan(aHeader, {|x| alltrim(x[2]) == cFldCAcm } )

				nPosVrcda	:= aScan(aHeader, {|x| alltrim(x[2]) == "N3_VRCDA" + Alltrim(Str(nI)) } )
				nPosValor	:= aScan(aHeader, {|x| alltrim(x[2]) == "N3_VORIG" + Alltrim(Str(nI)) } )
				nPosTaxa	:= aScan(aHeader, {|x| alltrim(x[2]) == "N3_TXDEPR" + Alltrim(Str(nI))})

				If nPosAcum > 0
					Iif(aColsClon[nLinha,nPosAcum] == nil,aColsClon[nLinha,nPosAcum] := CriaVar(cFldAcum), nil )

					//se houver valor acumulado, nao efetua nenhum calculo
					//If aColsClon[n,nPosAcum] > 0
					//	Return(.t.)
					//Endif

					aAdd(aVlrAcum,0)
				Endif

				If nPosAmpl > 0
					Iif(aColsClon[nLinha,nPosAmpl] == nil,aColsClon[nLinha,nPosAmpl] := CriaVar(cFldAmpl), nil )
					aAdd(aVlrAmpl,aColsClon[nLinha,nPosAmpl])
				Endif

				If nPosValor > 0
					Iif(aColsClon[nLinha,nPosValor] == nil,aColsClon[nLinha,nPosValor] := CriaVar("N3_VORIG" + ALLTRIM(Str(nI))), nil)
					aAdd(aVlrOrig,{aColsClon[nLinha,nPosValor],X3Decimal("N3_VORIG" + ALLTRIM(Str(nI)))})
				Endif

				If nPosTaxa > 0
					Iif(aColsClon[nLinha,nPosTaxa] == nil,aColsClon[nLinha,nPosTaxa] := CriaVar("N3_TXDEPR" + ALLTRIM(Str(nI))), nil)
					aAdd(aTaxaMes,aColsClon[nLinha,nPosTaxa])
				Endif

				If nPosCAcm > 0
					Iif(aColsClon[nLinha,nPosCAcm] == nil,aColsClon[nLinha,nPosCAcm] := CriaVar(cFldCAcm), nil)
					aAdd(aVlrCAcm, aColsClon[nLinha,nPosCAcm])
				Endif

				If nPosVrcda > 0
					Iif(aColsClon[nLinha,nPosVrcda] == nil,aColsClon[nLinha,nPosVrcda] := CriaVar("N3_VRCDA" + Alltrim(Str(nI))), nil)
					aAdd(aVlrCda, aColsClon[nLinha,nPosVrcda])
				Endif

			Next nI
			aPeriodo := AtfXPerCal(dDataCalc,aColsClon[nLinha,nPCriDepr],aColsClon[nLinha,nPCalDepr])

			//aPeriodo := IIf (Valtype(aPeriodo) == "L",{},aPeriodo)

			If ValType(aPeriodo) == "A"
				If dDataCalc >= aPeriodo[1] .and. dDataCalc <= aPeriodo[2]
					nMesAnt := Month(dDataCalc) - 1

					If nMesAnt == 0
						nMesAnt	:= 12
						nAno 	:= Year(dDataCalc)-1
					Else
						nAno	:= Year(dDataCalc)
					Endif

					dLastDepr	:= LastDay( stod(Alltrim(Str(nAno)) + StrZero(nMesAnt,2) + "01") )
					dDataDepr	:= LastDay(aPeriodo[1])

					aParamN3[1]	:= aVlrOrig[1,1]
					aParamN3[3]	:= 	Iif(nPTpDepr  > 0,aColsClon[nLinha,nPTpDepr] ,0)
					aParamN3[4]	:= 	Iif(nPvmxDepr > 0,aColsClon[nLinha,nPVmxDepr],0)
					aParamN3[5]	:= 	Iif(nPPerDepr > 0,aColsClon[nLinha,nPPerDepr],0)
					aParamN3[6]	:=	Iif(nPVlSalv1 > 0,aColsClon[nLinha,nPVlSalv1],0)
					aParamN3[7]	:=	Iif(nPProdMes > 0,aColsClon[nLinha,nPProdMes],0)
					aParamN3[8]	:=	Iif(nPProdAno > 0,aColsClon[nLinha,nPProdAno],0)
					aParamN3[9] :=	Iif(nPFimDepr > 0,aColsClon[nLinha,nPFimDepr],0)

					If Alltrim(aParamN3[3]) <> "8"
						If Alltrim(aParamN3[3]) == "9"
							If nPProdAcm > 0
								nMeses := DateDiffMonth(dLastDepr,dDataDepr) + 1
								aParamN3[7] := aColsClon[nLinha,nPProdAcm] / nMeses //Af010MedProd(aColsClon[n,nPProdAcm],dLastDepr,dDataDepr)
								//lResidual := .t.
							Endif
						Endif

						While dDataDepr <= dLastDepr

							aParamN3[2]	:= aVlrAcum[1]

							aTaxaAux := aClone(aTaxaMes)
							aTaxaMes := AFatorCalc(aTaxaMes,aPeriodo[1],dDataDepr,,,,aParamN3)

							aValores := {	aVlrOrig,;
							aVlrAcum,;
							aVlrAmpl,;
							aVlrCAcm,;
							aVlrCda }

							Af010CotaDepr(aTaxaMes,aCotaM,aParamN3,aValores,dDataDepr,,lResidual,nLinha)

							If !lResidual
								lResidual := ( Alltrim(aParamN3[3]) == "9" )
							Endif

							For nI := 1 to len(aCotaM)
								aVlrAcum[nI] += aCotaM[nI]
							Next nI

							aTaxaMes := aClone(aTaxaAux)

							dDataDepr := LastDay(LastDay(dDataDepr)+1)
						EndDo
					Else
						If nPProdAcm > 0
							ATFCalcVR(aColsClon[nLinha,nPProdAcm], aColsClon[nLinha,nPProdAno], @aTaxaMes)

							For nI := 1 to len(aVlrAcum)
								aVlrAcum[nI] := Round(aTaxaMes[nI] * aVlrOrig[nI,1],aVlrOrig[nI,2])
							Next nI
						Endif
					Endif
				Endif
			Else
				lRet := aPeriodo
			Endif
		Endif

		If lRet
			If Len(aVlrAcum) > 0
				For nI := 1 to len(aVlrAcum)

					If nI <= 9
						cFldAcum := "N3_VRDACM" + Alltrim(Str(nI))
					Else
						cFldAcum := "N3_VRDAC" + Alltrim(Str(nI))
					Endif

					If ( nPosAcum := aScan(aHeader, {|x| alltrim(x[2]) == cFldAcum } ) ) > 0
						aCols[nLinha,nPosAcum] := aVlrAcum[nI]
					Endif
				Next nI
			Endif

			If nPDInDepr > 0
				aCols[nLinha,nPDInDepr] := FirstDay(dDataCalc)
			Endif

		Endif

	ElseIf alltrim(aColsClon[nLinha,nPCriDepr]) == "04"

		If nPDInDepr > 0
			aPeriodo := AtfXPerCal(dDataCalc,aColsClon[nLinha,nPCriDepr],aColsClon[nLinha,nPCalDepr])
			If ValType(aPeriodo) == "A"
				aCols[nLinha,nPDInDepr] := aPeriodo[1]
			Else
				lRet := aPeriodo
			Endif
		Endif
	Endif

Else

	oModel		:= FWModelActive()
	dDataCalc	:= oModel:GetValue('SN1MASTER','N1_AQUISIC')
	oAux		:= oModel:GetModel( 'SN3DETAIL' )
	oStruct	:= oAux:GetStruct()
	aAux		:= oStruct:GetFields()
	nLinha		:= oAux:GetLine()
	nProdAcm	:= oAux:GetValue('N3_PRODACM', nLinha)
	nProdAno	:= oAux:GetValue('N3_PRODANO', nLinha)

	If AllTrim(oAux:GetValue('N3_CRIDEPR', nLinha)) == '03'
		If (Alltrim(oAux:GetValue('N3_TIPDEPR', nLinha)) <> "8" .AND.;
		!Empty(oAux:GetValue('N3_CALDEPR', nLinha))) .OR. Alltrim(oAux:GetValue('N3_TIPDEPR', nLinha)) == "8"

			nQtdMo := AtfMoedas()

			For nI := 1 to nQtdMo
				If nI <= 9
					cFldAmpl := 'N3_AMPLIA' + AllTrim(Str(nI))
					cOri      := 'N3_VORIG'  + AllTrim(Str(nI))
					cTxDepr  := 'N3_TXDEPR' + AllTrim(Str(nI))
					cFldCAcm := 'N3_VRCACM' + AllTrim(Str(nI))
					cVrcda   := 'N3_VRCDA'  + Alltrim(Str(nI))
				Else
					cFldAmpl := 'N3_AMPLI'  + AllTrim(Str(nI))
					cFldCAcm := 'N3_VRCAC'  + AllTrim(Str(nI))
				EndIf

				dAquisic := oModel:GetValue('SN1MASTER','N1_AQUISIC')
				cCRIDEPR := oAux:GetValue('N3_CRIDEPR', nLinha)
				nCALDEPR := oAux:GetValue('N3_CALDEPR', nLinha)

				If(oAux:GetValue(cFldAcum) == NIL, oAux:SetValue(cFldAcum, CriaVar(cFldAcum)), NIL )

				aAdd(aVlrAcum,0)

				If oAux:GetValue(cFldAmpl) == NIL
					oAux:SetValue(cFldAmpl, CriaVar(cFldAmpl))
				EndIf
				aAdd(aVlrAmpl,oAux:GetValue(cFldAmpl))

				If oAux:GetValue(cOri) == NIL
					oAux:SetValue(cOri,CriaVar(cOri))
					aAdd(aVlrOrig,{oAux:GetValue(cOri)})
				EndIf

				If oAux:GetValue(cTxDepr) == NIL
					oAux:SetValue(cTxDepr, CriaVar(cTxDepr))
					aAdd(aTaxaMes,oAux:GetValue(cTxDepr))
				Endif

				If oAux:GetValue(cFldCAcm)  == NIL
					oAux:SetValue(cFldCAcm, CriaVar(cFldCAcm))
					aAdd(aVlrCAcm, oAux:GetValue(cFldCAcm))
				Endif

				If oAux:GetValue(cVrcda) == NIL
					oAux:SetValue(cVrcda, CriaVar(cVrcda))
					aAdd(aVlrCda, oAux:GetValue(cVrcda))
				Endif

			Next nI

			aPeriodo := AtfXPerCal(dAquisic,cCRIDEPR,nCALDEPR)

			If ValType(aPeriodo) == "A"
				If dAquisic >= aPeriodo[1] .AND. dAquisic <= aPeriodo[2]
					nMesAnt := Month(dDataCalc) - 1
					If nMesAnt == 0
						nMesAnt	:= 12
						nAno 	:= Year(dDataCalc)-1
					Else
						nAno	:= Year(dDataCalc)
					Endif

					dLastDepr	:= LastDay( stod(Alltrim(Str(nAno)) + StrZero(nMesAnt,2) + "01") )
					dDataDepr	:= LastDay(aPeriodo[1])

					aParamN3[1]	:= aVlrOrig[1,1]
					aParamN3[3]	:= 	oAux:GetValue('N3_TPDEPR',  nLinha)
					aParamN3[4]	:= 	oAux:GetValue('N3_VMXDEPR', nLinha)
					aParamN3[5]	:= 	oAux:GetValue('N3_PERDEPR', nLinha)
					aParamN3[6]	:=	oAux:GetValue('N3_VLSALV1', nLinha)
					aParamN3[7]	:=	oAux:GetValue('N3_PRODMES', nLinha)
					aParamN3[8]	:=	oAux:GetValue('N3_PRODANO', nLinha)
					aParamN3[9]	:=	oAux:GetValue('N3_FIMDEPR', nLinha)

					If oAux:GetValue('N3_TPDEPR', nLinha) <> "8"
						If oAux:GetValue('N3_TPDEPR', nLinha) == "9"
							nMeses       := DateDiffMonth(dLastDepr,dDataDepr) + 1
							aParamN3[7] := oAux:GetValue('N3_PRODACM', nLinha) / nMeses
						Endif

						While dDataDepr <= dLastDepr

							aParamN3[2]	:= aVlrAcum[1]
							aTaxaAux := aClone(aTaxaMes)
							aTaxaMes := AFatorCalc(aTaxaMes,aPeriodo[1],dDataDepr,,,,aParamN3)

							aValores := {	aVlrOrig,;
							aVlrAcum,;
							aVlrAmpl,;
							aVlrCAcm,;
							aVlrCda }

							AF012CotaDepr(aTaxaMes,aCotaM,aParamN3,aValores,dDataDepr,,lResidual,nLinha)

							If !lResidual
								lResidual := ( Alltrim(aParamN3[3]) == "9" )
							Endif

							For nI := 1 to Len(aCotaM)
								aVlrAcum[nI] += aCotaM[nI]
							Next nI

							aTaxaMes := aClone(aTaxaAux)
							dDataDepr := LastDay(LastDay(dDataDepr)+1)

						EndDo
					Else //Igual a 8
						If nPProdAcm > 0

							ATFCalcVR(nProdAcm, nProdAno, @aTaxaMes)

							For nI := 1 to len(aVlrAcum)
								aVlrAcum[nI] := Round(aTaxaMes[nI] * aVlrOrig[nI,1],aVlrOrig[nI,2])
							Next nI
						Endif
					EndIf
				Endif
			Else
				lRet := aPeriodo
			Endif
		Endif

		If lRet

			If Len(aVlrAcum) > 0
				For nI := 1 to Len(aVlrAcum)

					If nI <= 9
						cFldAcum := "N3_VRDACM" + Alltrim(Str(nI))
					Else
						cFldAcum := "N3_VRDAC" + Alltrim(Str(nI))
					Endif

					If ( nPosAcum := aScan(aAux, {|x| alltrim(x[3]) == cFldAcum } ) ) > 0
						oAux:SetValue(cFldAcum, aVlrAcum[nI])
					Endif

				Next nI
			Endif

			//Preenche campos da data de inicio da depreciação
			oAux:SetValue('N3_DINDEPR', FirstDay(dDataCalc))
		Endif

	ElseIf AllTrim(oAux:GetValue('N3_CRIDEPR', nLinha)) == "04"

		aPeriodo := AtfXPerCal(dAquisic,cCRIDEPR,nCALDEPR)

		If ValType(aPeriodo) == "A"
			oAux:SetValue('N3_DINDEPR',aPeriodo[1])
		Else
			lRet := aPeriodo
		Endif
	Endif
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012VlMax
Validação do valor máximo da depreciação.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012VlMax(nVlMaxDepr)
Local lRet			:= .T.
Local cMoedaAtf	:= Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local nMoedaVMax	:= If(Val(GetMv("MV_ATFMDMX",.F.," ")) > 0, Val(GetMv("MV_ATFMDMX")), Val(cMoedaAtf))
Local cCpoOrig	:= "N3_VORIG" + cValToChar(nMoedaVMax)
Local oModel		:= Nil

//ATFA251
Local nPosVMOrig := 0
Default nVlMaxDepr := M->N3_VMXDEPR

If FWIsInCallStack("ATFA251")

	nPosVMOrig := Ascan(aHeader, {|x| Alltrim(x[2]) == Alltrim(cCpoOrig) } )

	If nVlMaxDepr > aCols[n][nPosVMOrig]
		Help( " ", 1, "AF010VMXDEPR",,STR0027, 1, 0 ) // "Valor Máximo de Deprecição não pode ser maior que o valor original na moeda configurada no parametro MV_ATFMDMX "
		lRet := .F.
	EndIf
Else

	oModel		:= FWModelActive()
	nVlMaxDepr	:= oModel:GetValue('SN3DETAIL','N3_VMXDEPR')

	If nVlMaxDepr > oModel:GetValue('SN3DETAIL', cCpoOrig)
		Help(" ", 1, "AF012VMXDEPR")  //"Valor Máximo de Deprecição não pode ser maior que o valor original na moeda configurada no parametro MV_ATFMDMX "
		lRet := .F.
	EndIf
	oModel := Nil
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ATPSAL
Função de validação do campo N3_TPSALD
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ATPSAL()
Local lRet := .T.
Local oModel
Local oAux

If FunName() == "ATFA012" // Validacao valida apenas para a rotina ATFA012

	oModel := FWModelActive()
	oAux   := oModel:GetModel('SN3DETAIL')
	If !oAux:IsInserted()
		Help(" ",1,"AFA010NAOP") //"Não permitir a edição do campo para linhas já existentes".
		lRet := .F.
	EndIf

EndIf

oModel := Nil
oAux	:= Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ATXDP
Função utilizada como WHEN dos campos de taxa da depreciação.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ATXDP()
Local oModel      := FWModelActive()
Local lRet			:= .T.

If oModel != Nil .AND. oModel:IsActive()
	If oModel:GetValue('SN3DETAIL','N3_TPDEPR') == "A"
		lRet := .F.
	EndIf
	If lRet .and. lIsRussia
		If oModel:GetValue('SN3DETAIL','N3_TPDEPR') == "F"
			lRet := .F.
		EndIf
	Endif
EndIf

oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A012VLZERO
Validação de preenchimento do campo de valor máximo de depreciação.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function A012VLZERO(cNomeField)
Local oModel  := FWModelActive()
Local lRet    := .T.
Default cNomeField := " "

If oModel != Nil
	If oModel:GetOperation() == 4 .AND. !Empty(cNomeField) .AND. !__lClassifica
		If cNomeField == "N3_VMXDEPR"
			lRet := oModel:GetValue('SN3DETAIL','N3_VRDACM1') == 0
		Else
			lRet := Empty(oModel:GetValue('SN3DETAIL',cNomeField))
		EndIf
	Endif
	If lRet .and. cNomeField == "N3_VMXDEPR" .and. lIsRussia
		If oModel:GetValue('SN3DETAIL','N3_TPDEPR') == "F"
			lRet := .F.
		EndIf
	Endif
EndIf

oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A012AtuTxR
Preenchimento das taxas de depreciação.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function A012AtuTxR(cTaxa, nTaxa)
Local aArea		:= GetArea()
Local aAreaSNH	:= {}
Local oModel	:= Nil
Local oAux		:= Nil
Local oStruct	:= Nil
Local aAux		:= Nil
Local aPos		:= {}
Local nX		:= 0
Local cDesc		:= ''

//Tratamento para uso das rotinas relacionadas que não foram convertidas
//para MVC. Após adequacao este trecho nao sera necessario
If FwIsInCallStack("ATFA251")
	cTaxa := A010AtuTxR(cTaxa, nTaxa)
Else
	oModel	:= FWModelActive()
	oAux	:= oModel:GetModel( 'SN3DETAIL' )
	oStruct	:= oAux:GetStruct()
	aAux	:= oStruct:GetFields()
	aPos	:= AtfMultPos(aAux,"N3_TXDEPR",3) // Controle de multiplas moedas

	If !Empty(cTaxa)
		aAreaSNH :=SNH->(GetArea())
		If nTaxa == NIL
			dbSelectArea("SNH")
			SNH->(dbSetOrder(1))
			If !Empty(cTaxa) .and. SNH->(dbSeek(xFilial("SNH")+cTaxa))
				nTaxa := SNH->NH_TAXA
			Else
				nTaxa := 0
			EndIf

			For nX := 1 To Len(aPos)
				If aPos[nX] > 0
					cDesc := aAux[aPos[nX],3]
					oModel:SetValue('SN3DETAIL',cDesc,nTaxa)
				EndIf
			Next nX

		EndIf
		RestArea(aAreaSNH)
	EndIf
EndIf

RestArea(aArea)
Return cTaxa

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AAT32
Preenche as taxas de depreciação para todas as moedas.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AAT32()
Local nX
Local lRet := .T.
Local oModel := FWModelActive()
Local oAux := oModel:GetModel( 'SN3DETAIL' )
Local oStruct := oAux:GetStruct()
Local aAux := oStruct:GetFields()
Local aPosTaxa := AtfMultPos(aAux,"N3_TXDEPR",3)
Local cTaxa := ''

If Alltrim(oModel:GetValue('SN1MASTER','N1_ART32')) == "S"

	For nX := 1 to Len(aPosTaxa)
		If aPosTaxa[nX] > 0
			cTaxa := aAux[aPosTaxa[nX],3]
			oAux:SetValue(cTaxa,(100 / (13 - Month(M->N1_AQUISIC) ) ) * 12)
		EndIf
	Next

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ADPAC
Preenchimento da depreciação acumulada nas demais moedas.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ADPAC()
Local oModel     := FWModelActive()
Local oAux       := oModel:GetModel( 'SN3DETAIL' )
Local oStruct    := oAux:GetStruct()
Local aAux       := oStruct:GetFields()
Local nX		  := 1
Local nValor     := oAux:GetValue('N3_VRDACM1')
Local cMoedaAtf := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local nValTotal     := 0
Local nTaxa      := 0
Local nPosModAtf:= Ascan( aAux, {|e| Alltrim(e[3]) = SubStr("N3_VRDACM1",1,10-Len(cMoedaAtf)) + Alltrim(cMoedaAtf)} )
Local cVOrig	   := ''
Local aPosVOrigX := AtfMultPos(aAux,"N3_VRDACM",3)

For nX := 2 to Len(aPosVOrigX)

	If aPosVOrigX[nX] > 0

		nValTotal := nValor / RecMoeda(oModel:GetValue('SN1MASTER','N1_AQUISIC'),nX)
		oAux:SetValue(aAux[aPosVOrigX[nX],3], nValTotal)

		If cPaisLoc == 'PER|ARG'
			If nX == oModel:GetValue('SN1MASTER','N1_MOEDAQU')
				nTaxa := If(Empty(oModel:GetValue('SN1MASTER','N1_TXMOEDA')),;
				RecMoeda(oModel:GetValue('SN1MASTER','N1_AQUISIC'),nX),oModel:GetValue('SN1MASTER','N1_TXMOEDA'))
				cVOrig := aAux[aPosVOrigX[nX],3]
				oAux:SetValue(cVOrig, nValor / nTaxa)
			Endif
		EndIf
	Endif

Next

If nPosModAtf > 0 .AND. ExistBlock("A30EMBRA")
	oAux:SetValue(aAux[nPosModAtf][3], nValor / ExecBlock("A30EMBRA",.F.,.F.))
Endif

Return nValor


//-------------------------------------------------------------------
/*/{Protheus.doc}A012GTEXST
Preencher a taxa de depreciação.
@author Totvs
@since  20/06/2018
@version 12
/*/
//-------------------------------------------------------------------
Function A012GTEXST()
Local oModel      := FwModelActive()
Local dIniDepr    := oModel:GetValue('SN3DETAIL','N3_DINDEPR')
Local dExaust     := Ctod("")
Local nRet        := 0

dExaust := &(ReadVar())

If !Empty(dExaust)
	nRet := 12 * (100 / AtfMeses(dIniDepr ,dExaust ,1 ))
Endif

Return nRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A012ADEXST
Preencher a taxa de depreciação.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function A012ADEXST()
Local oModel      := FwModelActive()
Local dIniDepr    := oModel:GetValue('SN3DETAIL','N3_DINDEPR')
Local dExaust     := ctod("")
Local lDtVazia    := .T.
Local lRet        := .T.
Local cMoedEx	  := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))

dExaust := &(ReadVar())
lDtVazia := Empty( dExaust )  // Se não houver data de exaustão, retorna.

If !lDtVazia

	If oModel:GetValue('SN3DETAIL','N3_VRDBAL' + cMoedEx ) > 0
		Help(" ",1, "AFA010EXA1" )
		lRet := .F.
	Else
		If dIniDepr >= dExaust
			Help(" ",1,"AFA010EXA2")
			lRet := .F.
		EndIf
	EndIf
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ADPBL
Preenchimento da depreciação do último balanço nas demais moedas.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ADPBL()
Local oModel   := FWModelActive()
Local oAux     := oModel:GetModel( 'SN3DETAIL' )
Local oStruct  := oAux:GetStruct()
Local aAux     := oStruct:GetFields()
Local nValor   := oAux:GetValue('N3_VRDBAL1')
Local nAquisic := oModel:GetValue('SN1MASTER','N1_AQUISIC')
Local nX	     := 1
Local aPosVOrigX:= AtfMultPos(aAux,"N3_VRDBAL",3) // Controle de multiplas moedas
Local cVOrig	  := ''

For nX := 2 To Len(aPosVOrigX)

	If aPosVOrigX[nX] > 0
		cVOrig := aAux[aPosVOrigX[nX]][3]
		oAux:SetValue(cVOrig, nValor / RecMoeda(nAquisic,nX))

		If cPaisLoc $ 'ARG|PER'
			If nX == oModel:GetValue('SN1MASTER','N1_MOEDAQU')
				oAux:SetValue(cVOrig,;
				nValor / If(Empty(oModel:GetValue('SN1MASTER','N1_TXMOEDA')),RecMoeda(nAquisic,nX),oModel:GetValue('SN1MASTER','N1_TXMOEDA')))
			EndIf
		EndIf

	EndIf

Next nX

oModel := Nil
oAux	:= Nil
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AVTIP
Validação do tipo de depreciação.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AVTIP(cTpDepr, nLinha)
Local lRet 		:= .F.
Local cTipoGer   	:= ''
Local aArea		:= {}
Local aAreaSN0	:= {}
Local nI			:= 0
Local nX 			:= 0
Local lAquiTrf	:= IsInCallStack("ATFA251") //Se a chamada vier do ATFA251
Local oModel 		:= If (lAquiTrf, oModel := FWLoadModel('ATFA012'),FWModelActive())//Carregar o modelo ATFA012
Local oAuxSN3		:= oModel:GetModel('SN3DETAIL')
Local oStruct 	:= oAuxSN3:GetStruct()
Local aAux 		:= oStruct:GetFields()
Local aPosN3TxDp	:= AtfMultPos(aAux,"N3_TXDEPR", 3)
Local cTipDp		:= ''
Local nPosN3TpDp	:= 0
Local lAutomato	:= IsBlind()

Local cTypes10		:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable model
Local cTypes12		:= IIF(lIsRussia,"|" + AtfNValMod({2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable model
Default nLinha	:= oAuxSN3:GetLine()
Default cTpDepr 	:= oAuxBusca:GetValue('N3_TPDEPR')

If !lAquiTrf //A rotina ATFA251 não esta adaptada para o modelo MVC
	If !oAuxSN3:GetValue('N3_TIPO') $ '11'
		lRet := ATFSALDEPR(oAuxSN3:GetValue('N3_TIPO', nLinha),, If("N3_TPDEPR" $ cTpDepr, cTpDepr, oAuxSN3:GetValue('N3_TPDEPR', nLinha)))
	Else
		If oAuxSN3:GetValue('N3_TIPO') $ '01|02'
			cTipoGer := '1,7,8,9'
			If !(cPaisLoc $ "ARG|BRA|COS")
				If nLinha == 1
					oAuxSN3:SetValue('N3_TPDEPR', '1')
					cTpDepr := '1'
				Endif
			EndIf
		ElseIf oAuxSN3:GetValue('N3_TIPO') $ ('10|12' + cTypes10 + cTypes12) // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
			aArea := GetArea()
			aAreaSN0 := SN0->(GetArea())

			dbSelectArea("SN0")

			SN0->(dbSetOrder(1))
			SN0->( MsSeek( xFilial("SN0") + '04' ) )

			Do While !SN0->(Eof()) .And. xFilial("SN0") + '04' == SN0->N0_FILIAL + SN0->N0_TABELA
				cTipoGer += If(Empty(cTipoGer),'',',') + SN0->N0_CHAVE
				SN0->(dbSkip())
			EndDo

			RestArea(aAreaSN0)
			RestArea(aArea)
		ElseIf oAuxSN3:GetValue('N3_TIPO') $ '11'

			For nX := 1 To oAuxSN3:Length()
				//nPosTp01	:= aScan(aCols,{|aX| aX[nPosN3Tipo] $ "01"})
				If oAuxSN3:GetValue('N3_TIPO', nX) == '01'
					cTipoGer	:= oAuxSN3:GetValue('N3_TPDEPR', nX)
					Exit
			    EndIf
			Next nX
		Else
			cTipoGer := '1'
		EndIf

		lRet := cTpDepr $ cTipoGer
		If !lRet
			If  oAuxSN3:GetValue('N3_TIPO') $ '11'
				Help(" ",1,"AF010AVTIP",,I18N(STR0116,{AllTrim(RetTitle("N3_TPDEPR"))}),1,0) //'A alteração do campo "#1[Tipo deprec.]#" da ampliação deve ocorrer por meio do tipo de ativo "Depreciação Fiscal".'
			Else
				Help( " ", 1, "AF012TIPDEP") // "Esse método de depreciação não é válido para esse tipo de ativo."
			EndIf
		EndIf

	EndIf

	If lRet .AND. oAuxSN3:GetValue('N3_TIPO') == '01'

		For nI := 1 To oAuxSN3:Length()
			If oAuxSN3:GetValue('N3_TIPO', nI) == "11" //aCols[nI,nPosN3Tipo]
				 oAuxSN3:SetValue('N3_TPDEPR', cTpDepr) //aCols[nI,nPosN3TpDp]	:= cTpDepr
			EndIf
		Next nI

	EndIf

	If !lAutomato .And. lRet .AND. oAuxSN3:GetValue('N3_TIPO') $ ('10' + cTypes10) .AND. cTpDepr == 'A' // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

		For nI := 1 To Len(aPosN3TxDp)
			cTipDp := aAux[aPosN3TxDp[nI],3]
			oAuxSN3:SetValue(cTipDp, 0)  //aCols[nLinha,aPosN3TxDp[nI]] := 0
		Next nI

	EndIf
Else
	If Type( "aHeader" ) == "A"
		nPosN3TpDp := Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TPDEPR" } )
	EndIf

	If nPosN3TpDp > 0
		nLinha := n //validar o campo N3_TPDEPR na função AF010AVTIP, pois o ATFA251 não está preparado para o MVC
		aCols[nLinha,nPosN3TpDp] := cTpDepr //Atualiza aCols
		lRet := AF010AVTIP(cTpDepr,nLinha)
	EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ACONV
Converte o valor original da moeda 1 para as demais moedas.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ACONV(cCampo)
Local lRet := .T.
Local oModel   :=  FwModelActive()
Local oAux		:=  oModel:GetModel('SN3DETAIL')
Local oStruct :=  oAux:GetStruct()
Local aAux     :=  oStruct:GetFields()
Local nValor	:=	oAux:GetValue('N3_VORIG1')
Local cMoedaAtf := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local dDtConv := If(oAux:GetValue('N3_TIPO') == '02', dDataBase, oModel:GetValue('SN1MASTER','N1_AQUISIC'))
Local nPosVOrigAtf := Ascan(aAux, {|e| Alltrim(e[3]) = "N3_VORIG" + cMoedaAtf})
Local aPosVOrigX := AtfMultPos(aAux,"N3_VORIG",3)
Local nX	:= 1
Local cMoedaErr := ""
Local nValorconv:= 0
Default cCampo := ''

// Nao converte as linhas de reavaliacao, pois ela ja foi convertida pela rotina Af010Valor
If (!oAux:GetValue('N3_TIPO') $ "02|05" .OR. !GetNewPar("MV_ZRADEPR",.F.))

	//Converte apenas com base na moeda 1, pois o valor do ativo na outra moeda não necessita ter base na cotação do dia.
	If "N3_VORIG1" $ cCampo
		For nX := 2 to Len(aPosVOrigX)	// Checa se os valores convertidos vão ultrapassar o tamanho de casas Inteiras
			nValorConv:= nValor / RecMoeda(dDtConv,nX)

			If aPosVOrigX[nX]>0 .And. Len(AllTrim(Str(int(nValorConv)))) > TamSX3(aAux[aPosVOrigX[nX]][3])[1] - (TamSX3(aAux[aPosVOrigX[nX]][3])[2]+1)
				cMoedaErr += aAux[aPosVOrigX[nX]][1] + " ,"
				lRet := .F.
				Help( " ",1,"AF010ESTVAL",, STR0117+cMoedaErr,1, 0,nil,nil,nil,nil,nil,{STR0176} ) // "A conversão do valor Original na Moeda 1 para as seguintes moedas, ultrapassara o tamanho maximo permitido: "
			EndIf

		Next
		If lRet

			For nX := 2 to Len(aPosVOrigX)

				If aPosVOrigX[nX] > 0
					cCampo := aAux[aPosVOrigX[nX],3]
					oAux:SetValue(cCampo, nValor / RecMoeda(dDtConv,nX))
				Endif

				If cPaisLoc == 'ARG|PER'
					If nX == oModel:GetValue('SN1MASTER','N1_MOEDAQU')
						cCampo := aAux[aPosVOrigX[nX],3]
						oAux:SetValue(cCampo,;
						nValor / If(Empty(oModel:GetValue('SN1MASTER','N1_TXMOEDA')),RecMoeda(dDtConv,nX),oModel:GetValue('SN1MASTER','N1_TXMOEDA')))
					Endif
				EndIf
			Next nX
		EndIf
	EndIf

	If nPosVOrigAtf > 0 .AND. ExistBlock("A30EMBRA")
		oAux:SetValue(aAux[nPosVOrigAtf][3], If(ExistBlock("A30EMBRA"),nValor/ExecBlock("A30EMBRA",.F.,.F.),;
		nValor / RecMoeda(dDtConv,Val(cMoedaAtf))))
	Endif
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ATAXA
Gatilho de taxa de depreciação
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ATAXA(lGrupo)
Local nTaxa := 0, ny, aAreaSx3, uRet
Local aEntidade := {}
Local lRet := .T.
Local oModel 	   := FWModelActive()
Local nOper	   := oModel:GetOperation()
DEFAULT lGrupo   := .F.

//Validação para verificar se o grupo contabil é igual da tabela SN3 quando for alteração
//Não se aplica quando for Classificação de Compras
If lGrupo .And. !Empty(oModel:GetValue('SN1MASTER','N1_GRUPO')) .AND. nOper == 4 .AND. !__lClassifica
	// Cria array com os nomes dos campos do SNG (Cadastro de grupos)
	SX3->(MsSeek("SNG"))
	SX3->(DbEval( { || Aadd(aEntidade, SX3->X3_CAMPO ) }, , { || SX3->X3_ARQUIVO == "SNG" } ) )
	dbSelectArea("SN3")
	dbSeek(xFilial("SN3") + oModel:GetValue('SN1MASTER','N1_CBASE') + oModel:GetValue('SN1MASTER','N1_ITEM'))
	dbSelectArea("SNG")
	dbSeek(xFilial("SNG") + oModel:GetValue('SN1MASTER','N1_GRUPO'))

	For nY := 1 To Len(aEntidade)
		If SN3->(FieldPos("N3_" + Subs(aEntidade[nY], 4))) <> 0 .AND. aEntidade[nY] != "NG_FILIAL"
			lRet:= .T.
			If ExistBlock("ATLIBGRP")
				lRet:= ExecBlock("ATLIBGRP",.F.,.F.,{FunName()})
			EndIf
			If SN3->&("N3_" + Subs(aEntidade[nY], 4)) != &("SNG->NG_" + Subs(aEntidade[nY], 4)) .AND. lRet
				Help(" ",1,"AF010GRP") //“As Entidades Contábeis do Grupo são diferentes das Entidades Contábeis do Bem.”.
				Return .F.
			EndIf
		Endif
	Next
EndIf

If lRet .and. lIsRussia .and. !__lClassifica
	RU01XFN003("N3_TXDEPR1") // Update fields N3_PERDEPR or N3_TXDEPR1   Old AF012RUTAX
Endif
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ADPMS
Preenchimento da última depreciação nas moedas.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ADPMS()
Local oModel      := FWModelActive()
Local oAux         := oModel:GetModel( 'SN3DETAIL' )
Local oStruct     := oAux:GetStruct()
Local aAux        := oStruct:GetFields()
Local nValor 	   := oAux:GetValue('N3_VRDMES1')
Local aPosVOrigX := AtfMultPos(aAux,"N3_VRDMES",3)
Local nX			:= 1

For nX := 2 to Len(aPosVOrigX)

	If aPosVOrigX[nX-1] > 0

		If cPaisLoc $ 'ARG|PER'
			If (nX-1) == oModel:GetValue('SN1MASTER','N1_MOEDAQU')
				oAux:SetValue(aAux[aPosVOrigX[nX],3],;
				nValor / If(Empty(oModel:GetValue('SN1MASTER','N1_TXMOEDA')),RecMoeda(nAquisic,nX),oModel:GetValue('SN1MASTER','N1_TXMOEDA')))
			Endif
		EndIf

	Endif

Next

oModel := Nil
oAux   := Nil
Return nValor

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AGRP
Preenche entidades contabeis no bem de acordo com grupo [SNG].
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AGRP(cEntidade)
Local oModel	:= FWModelActive()
Local cGrupo
Local cRetorno	:= ""
Local lErr		:= .F.
Local lSemIndice
Local nOrdem
Local lAtfa240	:= Alltrim(FunName()) == "ATFA240"

If oModel != Nil .And. (IsInCallStack("ATFA012") .OR. IsInCallStack("ATFA012RUS"))
	cGrupo	:= oModel:GetValue('SN1MASTER','N1_GRUPO')

	If !Empty(cGrupo)
		lSemIndice := Upper( SubStr(SN3->(IndexKey()),1,26) ) <> "N3_FILIAL+N3_CBASE+N3_ITEM"
		If lSemIndice
			nOrdem := SN3->( IndexOrd() )
			SN3->( DbSetOrder(1) )
		EndIf
		If lAtfa240
			// Na rotina de classificacao, pesquisa o SN3 pelos dados do SN1, pois se o codigo foi alterado em tela,
			// este ainda nao foi gravado na tabela SN3 e consequentemente o registro nao eh encontrado
			SN3->(MsSeek(xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)))
		Else
			SN3->(MsSeek(xFilial("SN3")+oModel:GetValue('SN1MASTER','N1_CBASE')+oModel:GetValue('SN1MASTER','N1_ITEM')))
		Endif
		If !Empty(cGrupo)

			If SNG->NG_GRUPO <> cGrupo
				SNG->(DbSeek(xFilial("SNG") + cGrupo))
			Endif
			If SNG->(FieldPos("NG_" + Subs(cEntidade, 4))) > 0
				If Empty(&("SN3->N3_" + Subs(cEntidade, 4))) .OR. __lCopia
					cRetorno := &("SNG->NG_" + Subs(cEntidade, 4))
				Else
					cRetorno := &("SN3->N3_" + Subs(cEntidade, 4))
				Endif
			Else
				lErr := .T.
			Endif
		Else
			If cEntidade <> nil .and. TamSX3(cEntidade)[3] == "N"
				cRetorno := 0
			EndIf
		Endif
		If lSemIndice
			SN3->( DbSetOrder(nOrdem) )
		EndIf
	Endif
EndIf
Return cRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc}FA012MrgVld
Validação do código da margem gerencial.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FA012MrgVld(cMargem,cRevMrg)
Local lRet		:= .F.
Local lRet15	:= .F.
Local aReg15	:= {}  //Acols auxiliar da __aColsMrg em tempo de inclusao
Local nPosVlr	:= 0
Local nX        := 0
Local nY        := 0
Local nQtdEntid:= CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Local cCampos	:= "N3_TIPO/N3_HISTOR/N3_TPSALDO/N3_VORIG1/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"
Local nQuantas := AtfMoedas()
Local nPosTpSld
//MRG
//Verifica implementacao da Margem Gerencial
Local lMargem := AFMrgAtf()
Local oModel  := FWModelActive()
Local dDtConv := oModel:GetValue('SN1MASTER','N1_AQUISIC')

DEFAULT cMargem := ""
DEFAULT cRevMrg	:= ""

//Alimento aHeader da tela Margem Gerencial
If Len(__aHeadMrg) == 0

	For nX := 2 to nQuantas
		cCampos += "/N3_VORIG" + cValtoChar(nX)
	Next nX

	//novas entidades contaveis
	For nX := 5 to nQtdEntid
		cCampos += "/N3_EC"+StrZero(nX, 2)+"DB"
	Next

	//Monta aHeader da Margem Gerencial
	AtfX3Mrg( "SN3", cCampos )

Endif

nPosTpSld := aScan( __aHeadMrg, { |x| AllTrim( x[2] ) == "N3_TPSALDO" } )

//Se os campos referente a AVP estiverem em branco
//devo validar como OK mas sem calculos ou geracao do Tipo 15
If !lMargem .or. Empty(cMargem)

	//Caso o codigo de margem tenha sido zerado, limpo o campo de
	If lMargem .and. Empty(cMargem)
		oModel:SetValue('SN1MASTER','N1_REVMRG','')
		aReg15 := {}
		__aColsMrg := {}
	Endif

	lRet := .T.
Else

	aReg14 := {}
	__aColsAvp := {}
	If Empty(cRevMrg)
		cRevMrg := AF470GetRev(cMargem)
	Endif

	FNQ->(dbSetOrder(1))
	If !(FNQ->(MsSeek(xFilial("FNQ")+cMargem+cRevMrg)))
		Help("  ",1,"AF012NOMARGEM ")    //"Regra de Margem Gerencial não cadastrada"
		lRet := .F.
	ElseIf FNQ->FNQ_STATUS == "2"  //Revisado
		Help("  ",1,"AF12MARGEMREV")	//"Regra de Margem Gerencial possui revisão posterior. Utilize a ultima revisão ativa da regra de margem gerencial"
		lRet := .F.
	ElseIf FNQ->FNQ_MSBLQL == "1"  //Bloqueado
		Help("  ",1,"AF12MARGEMBLQ")	//"Regra de Margem Gerencial bloqueada para uso. Utilize outra regra cadastrada"
		lRet := .F.
	Else
		lRet := .T.
	Endif

	If lRet
		//Pego Indice - Ultimo valor
		cTipo  		:= FNQ->FNQ_TIPO
		nValTaxa  	:= If(cTipo == "1", FNQ->FNQ_PERCEN, FNQ->FNQ_VLRFIX)
		nRecno	:= 1

		//Carrego o codigo da revisao ativa
		oModel:SetValue('SN1MASTER','N1_REVMRG', FNQ->FNQ_REV)

		//Gera movimento tipo 15 para cada Tipo 10 existente no detalhe da ficha de ativo
		lRet15 := AF012Ger15(aReg15)

		//Se foi criado algum retistro Tipo 15, atualizo aCols
		If lRet15
			For nX := 1 to Len(aReg15)
				For nY := 1 to nQuantas
					nPosVlr	 := aScan( __aHeadMrg, { |x| AllTrim( x[2] ) == "N3_VORIG" + cValToChar(nY) } )
					If nPosVlr > 0
						nValItem := aReg15[nX][nPosVlr]

						//Atualizo o valor no __aColsAvp
						If nValTaxa > 0
							If cTipo == "1"		//Percenual
								aReg15[nX][nPosVlr] := aReg15[nX][nPosVlr] * (nValTaxa/100)
							Else
								aReg15[nX][nPosVlr] := nValTaxa / RecMoeda(dDtConv,nY)
							Endif

							nPos := aScan( __aColsMrg, { |x| AllTrim( x[nPosTpSld] ) == aReg15[nX][nPosTpSld] } )

							If nPos == 0
								AADD(__aColsMrg, aReg15[nX])
							Else
								__aColsMrg[nPos][nPosVlr] := aReg15[nX][nPosVlr]
							Endif
						Endif
					EndIf
				Next nY
			Next nX
		Endif
	Endif

Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012Ger15
Geração da linha da margem gerencial
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Ger15(aReg15)
Local lRet		:= .F.
Local nInc		:= 1
Local nX			:= 0
Local nPos		:= 0
Local nLinha	:= 0
Local nUsado2	:= 0
Local nPosDado := 0
Local nPosSald := 0
Local nPosTpMov  := aScan( __aHeadMrg, { |x| AllTrim( x[2] ) == "N3_TIPO"        } )
Local oModel 	 := FWModelActive()
Local oAux      := oModel:GetModel( 'SN3DETAIL' )
Local aHeader		:= oAux:aHeader
Local aSaveLines	:= FWSaveRows()
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
DEFAULT aReg15 := {}  //Acols auxiliar da __aColsAvp em tempo de inclusao
If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

For nInc := 1 To oAux:Length()
	oAux:GoLine(nInc)
	//Busca os tipos 10 para gerar os tipos 15
	If oAux:GetValue('N3_TIPO') $ ("10|13" + cTypes10) // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

		//Verifico se tenho registro do tipo 15 para o Tipo 10 + Tipo Saldo
		nPos := aScan( aReg15, { |x| AllTrim( x[nPosSald] ) == oAux:GetValue('N3_TPSALDO')})

		//Caso nao exista registro do tipo 15 para o Tipo 10 + Tipo Saldo
		//Incluo um registro tipo 15 + Tipo Saldo
		If nPos == 0
			nUsado2 := Len(__aHeadMrg)+1
			nLinha  := Len(aReg15)+1
			AADD(aReg15,Array( nUsado2 ))
			aReg15[nLinha][nUsado2] := .F.

			For nX := 1 to Len(__aHeadMrg)
				nPosDado	:= aScan( aHeader, { |x| AllTrim( x[2] ) == AllTrim(__aHeadMrg[nX][2])  } )
				aReg15[nLinha][nX] := oAux:GetValue(aHeader[nPosDado][2])
			Next
			aReg15[nLinha][nPosTpMov] := '15'
		Endif

		lRet := .T.

	Endif
Next

FWRestRows(aSaveLines)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012Ger14
Geração da linha do AVP
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Ger14(aReg14)
Local lRet      := .F.
Local nInc      := 1
Local nX        := 0
Local nPos      := 0
Local nLinha    := 0
Local nUsado2	  := 0
Local nPosDado  := 0
Local nPosTpSal := 0
Local nPosTipo  := 0
Local nPosSald  := 0
Local oModel 	  := FWModelActive()
Local oAux       := oModel:GetModel( 'SN3DETAIL' )
Local oStruct := oAux:GetStruct()
Local aAux := oStruct:GetFields()
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
DEFAULT aReg14 := {}  //Acols auxiliar da __aColsAvp em tempo de inclusao
If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

nPosTpSal  := aScan( __aHeadAvp, { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
nPosTpMov  := aScan( __aHeadAvp, { |x| AllTrim( x[2] ) == "N3_TIPO"     } )
nPosTipo   := aScan( aAux , { |x| AllTrim( x[3] )     == "N3_TIPO"     } )
nPosSald   := aScan( aAux , { |x| AllTrim( x[3] )     == "N3_TPSALDO" } )

For nInc := 1 To oAux:Length()
	//Busca os tipos 10 para gerar os tipos 14
	If oAux:GetValue('N3_TIPO', nInc) $ ("10" + cTypes10) // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

		//Verifico se tenho registro do tipo 14 para o Tipo 10 + Tipo Saldo
		nPos := aScan(aReg14, { |x| AllTrim( x[nPosSald] ) == oAux:GetValue('N3_TPSALDO') })

		//Caso nao exista registro do tipo 14 para o Tipo 10 + Tipo Saldo
		//Incluo um registro tipo 14 + Tipo Saldo
		If nPos == 0

			nUsado2 := Len(__aHeadAvp) + 1
			nLinha  := Len(aReg14) + 1
			AADD(aReg14,Array( nUsado2 ))
			aReg14[nLinha][nUsado2] := .F.

			For nX := 1 to Len(__aHeadAvp)
				nPosDado	:= aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim(__aHeadAvp[nX][2])  } )
				aReg14[nLinha][nX] := oAux:GetValue(aAux[nPosDado,3], nInc)
			Next
			aReg14[nLinha][nPosTpMov] := '14'
		Endif

		lRet := .T.

	Endif
Next

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AAQUI
Validação do tipo do ativo.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AAQUI()
Local lRet:=.T., nReg:=0,nx,n1
Local cAlias := Alias()
Local l01 :=.F.
Local oModel   := FwModelActive()
Local cBase	 := oModel:GetValue('SN1MASTER','N1_CBASE')
Local cItem 	 := oModel:GetValue('SN1MASTER','N1_ITEM')
Local oAux 	 := oModel:GetModel( 'SN3DETAIL' )
Local cTipo 	 := oAux:GetValue('N3_TIPO', oAux:GetLine())
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "*" + AtfNValMod({1}, "*")
Endif

If cTipo $ "02|04|07|08|09" .AND. AllTrim(FunName()) <> 'ATFA175'
	dbSelectArea( "SN3" )
	Reg := SN3->(RecNo())
	dbSetOrder( 1 )
	If !dbSeek( xFilial("SN3") + cBase + cItem + "01" ) .AND. !dbSeek( xFilial("SN3") + cBase + cItem + "10" )

		For nX := 1 To oAux:Length()
			If nX != n1
				Do Case
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar se eh a linha de edicao atual e aplicar validacao do que ³
				//³foi digitado atraves variavel do buffer.                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					Case nX == oAux:GetLine() //Verifico se é a linha atual e aplico a validacao na memoria
						If cTipo $ ("01*10" + cTypes10) .AND. !oAux:IsDeleted(nX)  //aCols[nX][nUsado+1]
							l01 := .T.
						EndIf
					Case oAux:GetValue('N3_TIPO', nX) == "01" .AND. !oAux:IsDeleted(nX)
						l01 := .T.
				EndCase
			EndIf
		Next nX

		If !l01
			Help( " ", 1, "AF010AQUIS",, If(cTipo $ "07,08,09","","")  )
			lRet := .F.
		End
	End
	If !Empty(oAux:GetValue('N3_DTBAIXA')) .AND. lRet
		Help( " ", 1, "AF010BAIXA" )
		lRet := .F.
	End
	dbGoTo(nReg)
End

If cPaisLoc == "ANG"
	If !(cTipo $ "01|03|07")
		Help( " ", 1, "AF010ANG" )
		lRet := .F.
	EndIf
EndIf

If !FwIsInCallStack("ATFA155")
	If lRet .And. cTipo $ "11" .AND. ( oModel:GetOperation() != 3 )
		Help(" ",1,"AF012TP11")		//"Tipo de ativo valido somente na inclusão de um ativo"
		lRet := .F.
	EndIf
EndIf

dbSelectArea( cAlias )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ATIPO
Validação do tipo do ativo.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ATIPO( cTipo, nLinha, lLinOk )
Local oModel  := FWModelActive()
Local cPatrim := oModel:GetValue('SN1MASTER','N1_PATRIM')
Local cGrupo  := oModel:GetValue('SN1MASTER','N1_GRUPO')
Local oAuxBusca := oModel:GetModel('SN3DETAIL')
Local oStruct := oAuxBusca:GetStruct()
Local aAux := oStruct:GetFields()
Local lRet:= .T.
Local nx, ny,nw
// *******************************
// Controle de multiplas moedas  *
// *******************************
Local nQuantas 	:= AtfMoedas()
Local aTipos 		:= {}
// ***********************************************************
// Tipos de ativo que podem possuir multiplas cópias ativas  *
// ***********************************************************
Local aTiposMulti 	:= {"02","03","05","10","11","12","15"}
Local aTiposBase   	:= {"01","03","10","13"}
Local aTiposTrans		:= {"01","10"}
Local nTipoUnico		:= 0
Local nVTip			:= 1
//AVP
Local aTipoADT   		:= {}

Local cNValMod		:= ""
Local aNValMod		:= {}
Local nNValMod		:= 0
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
Local cTypeAux		:= ""
Local nRecSN3Ant	:= 0
Local lBmcontr 	    := IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , .T., .F.)
// Local cBmcontr 	    := IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , oModel:GetValue('SN1MASTER','N1_BMCONTR'),"") // validar uso ao descer bem em construção atfa040


Default lLinOk := .F.
Default nLinha := oAuxBusca:GetLine()
Default cTipo  := oAuxBusca:GetValue('N3_TIPO', nLinha)
If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cNValMod := AtfNValMod({1,2,3}, ";")
	cNValMod := "10;16;17" + IIf(Empty(cNValMod), "", ";") + cNValMod
	aNValMod := Separa(cNValMod, ';', .f.)
	For nNValMod := 1 to len(aNValMod)
		cTypeAux := aNValMod[nNValMod]
		cTypes10 += "|" + cTypeAux

		Aadd(aTiposMulti	, cTypeAux)
		Aadd(aTiposBase	, cTypeAux)
		Aadd(aTiposTrans	, cTypeAux)
	Next nNValMod
Endif

If cPaisLoc == "COL"
	aTipos := {"01","02","03","05","07","10","12","50","51","52","53","54"}
EndIf

If cPaisLoc == "COS"
	aTipos := {"01","02","03","04","05","06","07","10"}
EndIf

//Expressão removida da validação direta do campo para contemplar os novos tipos incluido no SX5->TABELA G1
//PERTENCE("01\02\03\04\05\06\07")
If Len(aTipos) == 0
	SX5->(DbSetOrder(1))
	SX5->(DbSeek(xFilial("SX5")+"G1"))
	While SX5->(!Eof()) .AND. SX5->X5_TABELA == "G1"
		AADD(aTipos,AllTrim(SX5->X5_CHAVE))
		SX5->(DbSkip())
	End
EndIf

If __lAltera .And. ReadVar() == 'M->N3_TIPO' .And. !(oAuxBusca:IsInserted())

	If oAuxBusca:GetDataId(nLinha) > 0

		nRecSN3Ant := SN3->(Recno())
		SN3->(dbGoTo(oAuxBusca:GetDataId(nLinha)))
		If (cTipo <> SN3->N3_TIPO) .And. (! SN3->(EOF()))
			lRet := .F.
			oAuxBusca:GoLine(nLinha)
			oAuxBusca:SetValue("N3_TIPO", SN3->N3_TIPO)
		EndIf
		SN3->(dbGoTo(nRecSN3Ant))
	EndIf

EndIf

If cPatrim == "T" .AND. !oAuxBusca:GetValue('N3_TIPO',nLinha) $ ('01|10' + cTypes10) .AND. !oAuxBusca:IsDeleted(nLinha)
	Help( " ",1,"AF012PERM" ) // "Não é permitido usar o tipo nesta operação!"
	lRet := .F.
EndIf

If lRet .And. aScan(aTipos,{|cTipos| cTipos == cTipo}) == 0 .AND. !oAuxBusca:IsDeleted(nLinha)
	Help( " ",1,"AF012PERM" ) // "Não é permitido usar o tipo nesta operação!"
	lRet := .F.
EndIf

//AVP
If lRet .And. !lLinOk .and. (!__lCopia) .and. cTipo == "14" .And. !oAuxBusca:IsDeleted() //Linha nova
	Help( " ", 1, "AF012NOT14")	//"Não é permitida a inclusão manual de Tipo 14. Utilize o processo de AVP padrão."
	lRet := .F.
EndIf

//MRG
If lRet .And. !lLinOk .and. ( !__lCopia) .and. cTipo == "15" .And. !oAuxBusca:IsDeleted() //Linha nova
	Help( " ", 1, "AF012NOT15",,)	//"Não é permitida a inclusão manual de Tipo 15. Utilize o processo de Margem Gerencial padrão."
	lRet := .F.
EndIf
If lBmContr .And. __lClassifica
	If !Empty(oModel:GetValue('SN1MASTER','N1_SLBMCON')) .And. !Empty(oModel:GetValue('SN1MASTER','N1_CODCIAP'))
		If lRet .And. ( !__lCopia) .and. cTipo == "01" .And. !oAuxBusca:IsDeleted() //Linha nova
			Help( " ", 1, "AF010BMCOM",,STR0178, 1, 0 )//"Bem Tipo Construção só permite tipo 03"
			lRet := .F.
		EndIf
	EndIf
	If (cTipo == "01" .Or. cTipo == "03") .And. !Empty(oModel:GetValue('SN1MASTER','N1_SLBMCON')) .And. Empty(oModel:GetValue('SN1MASTER','N1_CODCIAP'))
		If lRet .And. ( !__lCopia) .And. !oAuxBusca:IsDeleted() //Linha nova
			Help( " ", 1, "AF010BMCOM",,STR0184, 1, 0 )//Componente deve possuir CIAP
			lRet := .F.
		EndIf
	EndIf
EndIf

// *********************************************************************
// Valida os tipos de ativo que podem possuir multiplas cópias ativas  *
// *********************************************************************
If lRet .And. !oAuxBusca:IsDeleted()
	nTipoUnico := 0
	For nX := 1 To oAuxBusca:Length()
		If !oAuxBusca:IsDeleted(nX) .And. Empty(oAuxBusca:GetValue('N3_DTBAIXA', nX))
			If oAuxBusca:GetValue('N3_TIPO', nX) == cTipo .AND. (aScan(aTiposMulti,{|x| oAuxBusca:GetValue('N3_TIPO', nX) == x}) == 0)
				nTipoUnico++
			Endif
		Endif
	Next nX

	If nTipoUnico > 1
		Help( " ", 1, "A010JADIG") //"O tipo já foi informado!"
		lRet := .F.
	EndIf
Endif



// ***************************************************************************************************
// Valida os tipos de bens base, ou seja bens que podem ser cadastrados independentes de outros tipos*
// ***************************************************************************************************
If lRet .AND. aScan(aTiposBase,{|x| cTipo == x}) == 0 .and. !Empty(cTipo) .AND. AllTrim(FunName()) <> 'ATFA175'

	nTipoUnico := 0
	For nX := 1 To oAuxBusca:Length()
		If !oAuxBusca:IsDeleted(nX) .And. Empty(oAuxBusca:GetValue('N3_DTBAIXA', nX))
			If aScan(aTiposBase,{|x| oAuxBusca:GetValue('N3_TIPO', nX) == x}) != 0
				nTipoUnico++
			Endif
		Endif
	Next nx

	If Empty(nTipoUnico)
		Help( " ", 1, "AF012TIP",, STR0113, 1, 0 ) //"Tipo de ativo não é um tipo base"
		lRet := .F.
	EndIf

Endif

If lRet
	// Na reavaliacao ou depreciacao acelerada, copia os itens
	If cTipo $ "02,05,07,08,11" .And. oAuxBusca:Length() > 1 .And. !IsInCallStack("ATFA175") .And. !oAuxBusca:IsDeleted() //Linha nova

		For nY := 1 To Len(aAux)

			If cTipo $ "11" .And. Trim(aAux[ny][3]) = "N3_TPDEPR"

				//Variavel nVTip armaneza a linha do N3_TIPO = 1
				For nVTip := 1 To oAuxBusca:Length()
					If oAuxBusca:GetValue('N3_TIPO', nVTip) == '01' //nVTip -> Linha Posicionada no Detail
						oAuxBusca:SetValue('N3_TPDEPR', oAuxBusca:GetValue('N3_TPDEPR',nVTip))
						Exit
					EndIf
				Next nVTip

			ElseIf Trim(aAux[nY][3]) != "N3_TIPO"    .AND. Trim(aAux[nY][3]) != "N3_HISTOR" .AND. Empty(oAuxBusca:GetValue(aAux[nY][3]))
				// Atribui ao valor original, o saldo remanescente para calculo da depreciacao acelerada
				If cTipo $ "07,08" .AND. Trim(aAux[nY][3]) = "N3_VORIG1"

					For nX := 1 To nQuantas
						oAuxBusca:SetValue("N3_VORIG" + AllTrim(Str(nX)), oAuxBusca:GetValue("N3_VORIG" + AllTrim(Str(nX)), nVTip))
					Next nX
				Endif
			EndIf

		Next nY

	Endif
EndIf


If cPaisLoc == "COL"
	If lRet .AND. cTipo $ "50|51|52|53|54"

		For nX := 1 to oAuxBusca:Length()
			If !oAuxBusca:IsDeleted(nX) .AND. nX != oAuxBusca:GetLine() .AND. oAuxBusca:GetValue('N3_TIPO', nX) $ "50|51|52|53|54"
				Help( " ", 1, "AF012CADATF") //“Este item já se encontra digitado no Cadastro de Ativos.”
				lRet := .F.
				Exit
			EndIf
		Next nX

	EndIf
EndIf

// Realiza a validação do tipo de ativo 03 ativo
If lRet .AND. lLinOk

	aAdd(aTipoADT,{"03","03/13/15" })
	aAdd(aTipoADT,{"13","03/13/15" })

	For nY := 1 to Len(aTipoADT)

		cTpAux := aTipoADT[nY][1]
		l03 := .F.

		For nX := 1 To oAuxBusca:Length()
			If !oAuxBusca:IsDeleted(nX) .AND. (oAuxBusca:GetValue('N3_TIPO', nX) == cTpAux )
				l03 := .T.
				Exit
			EndIf
		Next nX

		If l03
			For nX := 1 To oAuxBusca:Length()

				cTpAux := oAuxBusca:GetValue('N3_TIPO', nX)
				If !oAuxBusca:IsDeleted(nX) .AND. !( cTpAux $ aTipoADT[nY][2] )
					Help( " ", 1, "AF012TPADT",, STR0095 + " " +aTipoADT[nY][2]+" " + STR0096+ " "  + aTipoADT[nY][1] , 1, 0 ) //'Apenas os tipos' -- " podem ser cadastrados em conjunto com o tipo de ativo "
					lRet := .F.
					Exit
				EndIf

			Next nX
		EndIf

		If !lRet
			Exit
		EndIf
	Next nY

EndIf

If lRet .and. cPatrim = 'E' .and. !(cTipo $ "03/13/10"+cTypes10) .And. !oAuxBusca:IsDeleted()
	Help( " ", 1, "AF012EMP") //""Só permitidos os tipos 03 ou 13 quando o Bem for classificado como Custo de Emprestimo"
	lRet := .F.
Endif

If lRet .And. !oAuxBusca:IsDeleted() .And. "N3_TIPO"$ReadVar()
	//----------------------------------------
	// Preenchimentos das entidades contabeis
	//----------------------------------------
	A012SNGCTB(oAuxBusca,cGrupo,.T.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AVlGr
Validação do tipo do ativo.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AVlGr(cField)
Local oModel 		:= Nil
Local oAuxSN3 	:= Nil
Local cTpDepr		:= Nil
Local lRet 		:= .F.
Local lAtfctap	:= If(GetNewPar("MV_ATFCTAP","0")=="0",.F.,.T.)

//ATFA251
Local nPosTpDepr 	:= 0
Local nPosVlSalv1	:= 0
Local nPosPerDepr	:= 0
Local nPosProdMes	:= 0
Local nPosProdAno	:= 0
Local nPosVMxDepr	:= 0
Local nPosCodInd	:= 0

DEFAULT cField	:= ReadVar()


If FwIsInCallStack("ATFA251")

	nPosTpDepr 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "N3_TPDEPR" } )
	nPosVlSalv1	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VLSALV1"} )
	nPosPerDepr	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PERDEPR"} )
	nPosProdMes	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODMES"} )
	nPosProdAno	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_PRODANO"} )
	nPosVMxDepr	:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_VMXDEPR"} )
	nPosCodInd		:= aScan(aHeader, {|x| AllTrim(x[2]) == "N3_CODIND"} )

	If At("->",cField)>0
		cField := SubStr(cField,At("->",cField)+2,len(cField))
	EndIf

	If nPosTpDepr>0 .And. !Empty(&(ReadVar()))
		Do Case
			Case aCols[n][nPosTpDepr]=='2'
				lRet := cField $ "N3_PERDEPR,N3_VLSALV1"
			Case aCols[n][nPosTpDepr]=='3'
				lRet := cField $ "N3_PERDEPR"
			Case aCols[n][nPosTpDepr]=='4'
				If lAtfctap
					lRet := cField $ "N3_PRODANO"
				Else
					lRet := cField $ "N3_PRODMES,N3_PRODANO"
				EndIf
			Case aCols[n][nPosTpDepr]=='5'
				If lAtfctap
					lRet := cField $ "N3_PRODANO"
				Else
					lRet := cField $ "N3_PRODMES,N3_PRODANO"
				EndIf
			Case aCols[n][nPosTpDepr]=='6'
				lRet := cField $ "N3_PERDEPR"
			Case aCols[n][nPosTpDepr]=='7'
				lRet := cField $ "N3_VMXDEPR"
			Case aCols[n][nPosTpDepr]=='8'
				lRet := cField $ "N3_PRODANO"
			Case aCols[n][nPosTpDepr]=='9'
				lRet := cField $ "N3_PRODANO"
			Otherwise // =='1'
				lRet := .F.
		EndCase
		If !lRet .And. !IsBlind()
			Help( " ", 1, "AF010FDNTUS",, STR0144, 1, 0 ) // "Esse campo não é utilizado pelo método de depreciação selecionado, o valor informado não será considerado."
		EndIf
	EndIf

	AF012VLAEC()

Else

	oModel 	:= FWModelActive()
	oAuxSN3 	:= oModel:GetModel('SN3DETAIL')
	cTpDepr	:= oAuxSN3:GetValue('N3_TPDEPR')

	If At("->",cField)>0
		cField := SubStr(cField, At("->",cField) + 2, Len(cField))
	EndIf

	If !Empty(&(ReadVar()))
		Do Case
			Case cTpDepr == '2'
				lRet := cField $ "N3_PERDEPR,N3_VLSALV1"
			Case cTpDepr == '3'
				lRet := cField $ "N3_PERDEPR"
			Case cTpDepr == '4'
				If lAtfctap
					lRet := cField $ "N3_PRODANO"
				Else
					lRet := cField $ "N3_PRODMES,N3_PRODANO"
				EndIf
			Case cTpDepr == '5'
				If lAtfctap
					lRet := cField $ "N3_PRODANO"
				Else
					lRet := cField $ "N3_PRODMES,N3_PRODANO"
				EndIf
			Case cTpDepr == '6'
				lRet := cField $ "N3_PERDEPR"
			Case cTpDepr == '7'
				lRet := cField $ "N3_VMXDEPR"
			Case cTpDepr == '8'
				lRet := cField $ "N3_PRODANO"
			Case cTpDepr == '9'
				lRet := cField $ "N3_PRODANO"
				Otherwise // =='1'
					lRet := .F.
			EndCase
		If !lRet .And. !IsBlind()
			Help( " ", 1, "AF012FDNTUS",, STR0144) // "Esse campo não é utilizado pelo método de depreciação selecionado, o valor informado não será considerado."
		EndIf
	EndIf

	//Acrescentado por Fernando Radu Muscalu em 03/06/11
	AF012VLAEC()
	/*
	1-Linea	2-RedSl	3-SAnos	4-UnPrd	5-HrPrd	6-SDigi	7-LVlMx	8-ExLin	9-ExSld
	N3_PERDEPR			   X	   X					   X
	N3_VLSALV1			   X
	N3_PRODMES							   X	   X
	N3_PRODANO							   X	   X						X		X
	N3_VMXDEPR													   X
	*/

	If lIsRussia .and. !__lClassifica
		RU01XFN003("N3_PERDEPR") // Update fields N3_PERDEPR or N3_TXDEPR1 old AF012RUTAX
	Endif

	oModel  := Nil
	oAuxSN3 := Nil
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}Af012Margem
Validação do tipo do ativo.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function Af012Margem()
Local lEnchBar		:= .T.									// Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao		:= .F.									// Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY		:= 400									// Altura mínima da janela
Local aSize		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local cCadastro	:= "Margem Gerencial"
Local cLinhaOk		:= "AllwaysTrue"						// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk		:= "AllwaysTrue"						// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos		:= ""									// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze		:= 000									// Campos estaticos na GetDados.
Local aAlter		:= {}									// Campos a serem alterados pelo usuario
Local cFieldOk		:= "AllwaysTrue"						// Funcao executada na validacao do campo
Local cSuperDel	:= "AllwaysTrue"						// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk		:= "AllwaysTrue"						// Funcao executada para validar a exclusao de uma linha do aCols
Local nX			:= 0
Local lMargem 		:= AFMrgAtf()								// Verifica implementacao da Margem Gerencial
Local oModel 		:= FWModelActive()
Local oSN1			:= oModel:GetModel('SN1MASTER')
Local aSaveLines	:= FWSaveRows()

//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela,
//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
If lMargem .and. !Empty(oSN1:GetValue('N1_MARGEM')) .and. !Empty(oSN1:GetValue('N1_REVMRG'))

	If FA012MrgVld(oSN1:GetValue('N1_MARGEM'),oSN1:GetValue('N1_REVMRG'))

		//Monta tela da Margem Gerencial
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Definiçãod dos Objetos³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE MSDIALOG oDlgMrg TITLE cCadastro From aSize[7],aSize[2] to aSize[6],aSize[5] of oMainWnd PIXEL

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Estrutura de Panels³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oPanelMrg			:= TPanel():New(0,0,'',oDlgMrg,, .T., .T.,, ,100,100,.T.,.T. )
		oPanelMrg:Align 	:= CONTROL_ALIGN_ALLCLIENT

		If Len(__aHeadMrg) > 0
			For nX := 1 to Len(__aHeadMrg)
				If AllTrim( __aHeadMrg[nX][2] ) $ "N3_HISTOR/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"
					AADD(aAlter, __aHeadMrg[nX][2])
				Endif
			Next
		Endif

		oGetMrg	:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,Len(__aColsMrg),cFieldOk,cSuperDel,cDelOk,oPanelMrg,__aHeadMrg,__aColsMrg)
		oGetMrg:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

		ACTIVATE MSDIALOG oDlgMrg ON INIT EnchoiceBar(oDlgMrg,{||nOpca:=1,If(MsgYesNo(STR0090,STR0091),(__aColsMrg := aClone(oGetMrg:aCols),oDlgMrg:End()),nOpca:=0)},{||oDlgMrg:End()}) CENTERED	//"Confirma Alteracao?"###"Atenção"
	Endif
Endif

FWRestRows(aSaveLines)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}AtfX3MRG
Le a estrutura do arquivo SX3

@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AtfX3MRG( cAlias1, cCampos )

Local nOrdSx3	:= SX3->(IndexOrd())
Local cUsado	:= ""
Local aCampos	:= {}
Local nX			:= 0
Local nTamCpo	:= SX3->(Len(X3_CAMPO))

DEFAULT cAlias1 := ""
DEFAULT cCampos := ""

aCampos := STRTOKARR(cCampos,"/")

For nX := 1 to Len(aCampos)

	dbSelectArea("SX3")
	dbSetOrder(2)
	If SX3->(MsSeek( Padr(aCampos[nX],nTamCpo )))
		IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL

			cUsado := SX3->X3_USADO

			//Transformo em string o conteudo de SX3->X3_CBOX
			//Este tratamento eh feito pois a MsNewGetDados nao trata como combo
			// se SX3->X3_CBOX for igual a #Function()
			cCombo := SX3->X3_CBOX
			If Substr(cCombo,1,1) == "#"
				cCombo := &(Alltrim(Substr(cCombo,2)))
			Endif

			aAdd( __aHeadMrg ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
							,SX3->X3_PICTURE ,SX3->X3_TAMANHO ;
							,SX3->X3_DECIMAL ,SX3->X3_VALID ;
							,SX3->X3_USADO ,SX3->X3_TIPO ;
							,SX3->X3_F3 ,SX3->X3_CONTEXT ;
							,cCombo ,SX3->X3_RELACAO})
		EndIf
	EndIf
Next

SX3->(dbSetOrder(nOrdSx3))

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}Af012Avp
Tela de edição de AVP

@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function Af012Avp()
Local lEnchBar	:= .T.									// Se a janela de diálogo possuirá enchoicebar (.T.)
Local lPadrao		:= .F.									// Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nMinY		:= 400									// Altura mínima da janela
Local aSize		:= MsAdvSize(lEnchBar, lPadrao, nMinY)
Local cLinhaOk	:= "AllwaysTrue"						// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
Local cTudoOk		:= "AllwaysTrue"						// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos	:= ""									// Nome dos campos do tipo caracter que utilizarao incremento automatico.
Local nFreeze		:= 000									// Campos estaticos na GetDados.
Local aAlter		:= {}									// Campos a serem alterados pelo usuario
Local cFieldOk	:= "AllwaysTrue"						// Funcao executada na validacao do campo
Local cSuperDel	:= "AllwaysTrue"						// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk		:= "AllwaysTrue"						// Funcao executada para validar a exclusao de uma linha do aCols
Local nX			:= 0
Local oModel		:= FWModelActive()
Local lRet       	:= .T.
local oSN1 	   	:= Nil
local oSN3     	:= Nil
Local aSaveLines	:= FWSaveRows()

Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10		:= {}
Local nTypes10		:= 0
Local cTypeAux		:= ""
Local lType10		:= .F.

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := AtfNValMod({1}, "|")
	aTypes10 := Separa(cTypes10, '|', .f.)
Endif
aadd( aTypes10, "10")
oSN1 := oModel:GetModel("SN1MASTER")
oSN3 := oModel:GetModel("SN3DETAIL")

// CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
For nTypes10 := 1 to len(aTypes10)
	cTypeAux := aTypes10[nTypes10]

	//Verifica se há algum tipo 10 informado na Grid para que seja possível fazer o cálculo AVP
	//If oSN3:SeekLine( { {"N3_TIPO", "10" } } )
	If oSN3:SeekLine( { {"N3_TIPO", cTypeAux } } )
		lType10 := .T.
		If AllTrim( oSN3:GetValue("N3_CCONTAB") ) <> ""
			//Se não há um valor informado na depreciação gerencia
			If oSN3:GetValue("N3_VORIG1") == 0
				lRet := .F.
				Help( " ", 1, "AF012AVP01",, OemToAnsi(STR0121), 1, 0 ) //"O valor do bem na moeda legal não foi digitado."
			Endif
		Else //Não há uma conta contábil informada na depreciação gerencial
			lRet := .F.
			Help( " ", 1, "AF012AVP02",, OemToAnsi(STR0122), 1, 0 ) //"O campo Conta (N3_CCONTAB) não foi preenchido."
		Endif
	//Else //Não há nenhum tipo '10' informado (Depreciação Gerencial/Contabil)
	//	lRet := .F.
	//	Help( " ", 1, "AF012AVP03",, OemToAnsi(STR0123), 1, 0 ) //"Informe ao menos uma valor do tipo 10 (Depreciação Gerencial/Contabil) para realizar o cálculo AVP."
	Endif

	If !lRet
		Exit
	Endif
Next nTypes10

If !lType10
	lRet := .F.
	Help( " ", 1, "AF012AVP03",, OemToAnsi(STR0123), 1, 0 ) //"Informe ao menos uma valor do tipo 10 (Depreciação Gerencial/Contabil) para realizar o cálculo AVP."
Endif
FWRestRows( aSaveLines )

If lRet
	If AF012TPAVP() //Valida se o tipo de AVP e valido
		If FA012VldAvp( oSN1:GetValue('N1_DTAVP'), oSN1:GetValue('N1_INDAVP') )
			If oSN1:GetValue('N1_INIAVP') < oSN1:GetValue('N1_DTAVP')
				//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela,
				//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
				If !( oModel:GetValue('SN1MASTER','N1_TPAVP') == '2' .AND. oModel:GetValue('SN1MASTER','N1_PATRIM') = 'O')
					//Monta tela do AVP
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Definiçãod dos Objetos³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					DEFINE MSDIALOG oDlgAVP TITLE cCadastro From aSize[7],aSize[2] to aSize[6],aSize[5] of oMainWnd PIXEL

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Estrutura de Panels³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					oPanelAvp			:= TPanel():New(0,0,'',oDlgAVP,, .T., .T.,, ,100,100,.T.,.T. )
					oPanelAvp:Align 	:= CONTROL_ALIGN_ALLCLIENT

					If Len(__aHeadAvp) > 0
						For nX := 1 to Len(__aHeadAvp)
							If AllTrim( __aHeadAvp[nX][2] ) $ "N3_HISTOR/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"
								AADD(aAlter, __aHeadAvp[nX][2])
							Endif
						Next
					Endif

					oGetAvp	:= MsNewGetDados():New(0,0,100,100,GD_UPDATE,cLinhaOk,cTudoOk,cIniCpos,aAlter,nFreeze,Len(__aColsAvp),cFieldOk,cSuperDel,cDelOk,oPanelAvp,__aHeadAvp,__aColsAvp)
					oGetAvp:oBrowse:Align:= CONTROL_ALIGN_ALLCLIENT

					ACTIVATE MSDIALOG oDlgAvp ON INIT EnchoiceBar(oDlgAvp,{||nOpca:=1,If(MsgYesNo('Confirma Alteração?','Atenção'),(__aColsAvp := aClone(oGetAvp:aCols),oDlgAvp:End()),nOpca:=0)},{||oDlgAvp:End()}) CENTERED	//"Confirma Alteracao?"###"Atenção"
				Else
					Help(" ", 1, "AF012NOAVP")  //"Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela, o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões."
				Endif
			Else
				Help( " ", 1, "AF012AVP05",, OemToAnsi(STR0120), 1, 0 ) //"Informe uma Data Prevista de Execucao maior que a Data Inicio AVP."
			Endif
		Else
			Help( " ", 1, "AF012AVP04",, OemToAnsi(STR0124), 1, 0 ) //Informe corretamente os dados na aba 'AVP'."
		Endif
	Endif
Endif

FWRestRows(aSaveLines)

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc}AF012Rateio
Rotina de inclusão e alteração do rateio.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Rateio()
Local bFuncPanel	:= {|oWnd| FA012GetPn(oWnd)}
Local cCodRat		:= ""
Local lCont		:= .F.
Local oModel 		:= FWModelActive()
Local oAux			:= oModel:GetModel('SN3DETAIL')
Local nOper		:= oModel:GetOperation()
Local nLin	   		:= oAux:GetLine() //__oGet:obrowse:nAt
Local aSaveLines	:= FWSaveRows()
Local aCodRat		:= ""
Local cFilRat   := ""

If AFXVerRat()

	If nOper == 3
		AF011FRAT(__aRateio,nLin,nOper,bFuncPanel)
	ElseIf oModel:GetValue('SN3DETAIL','N3_RATEIO') == '1'

		cFilRat := oModel:GetValue('SN3DETAIL','N3_FILIAL')
		cCodRat := oModel:GetValue('SN3DETAIL','N3_CODRAT')
		If AsCan(__aRateio,{|aX| aX[1] == cCodRat}) == 0
			lCont:= .T.
		EndIf
		If lCont
			AF012LoadR(@__aRateio,cCodRat,nLin,cFilRat)
			AF011FRat(@__aRateio,nLin,nOper,bFuncPanel)
		Else
			AF011FRat(@__aRateio,nLin,nOper,bFuncPanel)
		EndIf
	Else
		AF011FRat(@__aRateio,nLin,nOper,bFuncPanel)
		//Atualiza grid SN3 (rateio e código rateio)
		If !Empty(__aRateio) .And. nOper != MODEL_OPERATION_VIEW
			aCodRat := AF011COD()
			oModel:SetValue('SN3DETAIL','N3_RATEIO', '1')
			oModel:SetValue('SN3DETAIL','N3_CODRAT', aCodRat[1])
		EndIf
	EndIf

Endif

FWRestRows(aSaveLines)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012LoadR
Carregar os dados do rateio
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012LoadR(aRateio,cCodRat,nLin,cFilRat)
Local aAreaSnv	:= {}//SNV->(GetArea())
Local cRev		:= ""
Local cStatus	:= ""
Local aAxRat	:= {}
Local aHdrSNV	:= {}
Local nJ		:= 0
Default cCodRat	:= ""
Default	nLin	:= 0
Default cFilRat := cFilAnt

If AFXVerRat()

	aAreaSnv := SNV->(GetArea())

	If !Empty(cCodRat) .and. nLin != 0

		aHdrSNV:=AF011HeadSNV()

		cRev :=  AF011GETREV(cCodRat)

		SNV->(DbSetOrder(1))

		If SNV->(DbSeek(xFilial("SNV")+PadR(cCodRat,TamSx3("NV_CODRAT")[1])+PadR(cRev,TamSx3("NV_REVISAO")[1]))) .and. AsCan(aRateio,{|aX| aX[1] == cCodRat}) == 0
			cStatus	:= SNV->NV_STATUS
			While SNV->(!EOF()) .and. SNV->NV_FILIAL+PadR(SNV->NV_CODRAT,TamSx3("NV_CODRAT")[1]) == cFilRat+PadR(cCodRat,TamSx3("NV_CODRAT")[1])
			 	aAdd(aAxRat,Array(Len(aHdrSNV)+1))
			 	For nJ := 1 To Len(aHdrSNV)
					If SNV->(FieldPos(aHdrSNV[nJ][2]))> 0
						aAxRat[Len(aAxRat),nJ] := SNV->(FieldGet(FieldPos(aHdrSNV[nJ][2])))
					Else
						aAxRat[Len(aAxRat),nJ] := CriaVar(aHdrSNV[nJ][2])
					Endif
				Next nJ
				aAxRat[Len(aAxRat),Len(aHdrSNV)+1]:=.F.
				SNV->(DbSkip())
			EndDo
			aAdd(aRateio,{;
							cCodRat,;
							cRev,;
							cStatus,;
					   		nLin,;
							aAxRat,;
							.F.})

		EndIf
	EndIf
	SNV->(RestArea(aAreaSnv))
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}FA012VldAvp
Validar o índice AVP e a data prevista de execução.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function FA012VldAvp(dDataAVP,cIndAVP)
Local lRet		   := .F.
Local lRet14	   := .F.
Local cVar		   := ReadVar()
Local aReg14	   := {}  //Acols auxiliar da __aColsAvp em tempo de inclusao
Local nPosVlr	   := 0
Local nX         := 0
Local nY         := 0
Local nQtdEntid  := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
Local cCampos	   := "N3_TIPO/N3_HISTOR/N3_TPSALDO/N3_VORIG1/N3_CCONTAB/N3_CUSTBEM/N3_SUBCCON/N3_CLVLCON"
Local nQuantas   := AtfMoedas()
Local nAVPMan    := 0
Local oModel 	   := FWModelActive()
Local cCodAvp    := oModel:GetValue('SN1MASTER','N1_INDAVP')
DEFAULT dDataAVP := Ctod("//")
DEFAULT cIndAVP  := ""

If !Empty(cCodAvp)
	DbSelectArea("FIT")
	FIT->(DbSetOrder(1))
	If !(lRet := FIT->(DbSeek(xFilial("FIT")+cCodAvp))  .And. FIT->FIT_BLOQ == "2" )
		Help( "", 1, "BLOQINDICE",, OemToAnsi(STR0130), 1, 0 )
	EndIf
EndIf

//Se for a validação do campo "N1_DTAVP" e a data for menor ou igual a data de inicio, apresenta um help e não valida
If lRet .And. "N1_DTAVP" $ ReadVar() .AND. oModel:GetValue('SN1MASTER','N1_INIAVP') >= oModel:GetValue('SN1MASTER','N1_DTAVP')
	Help( " ", 1, "AF012VldDtAVP",, OemToAnsi(STR0120), 1, 0 ) //"Informe uma Data Prevista de Execucao maior que a Data Inicio AVP."
ElseIf lRet
	//Alimento aHeader da tela APV
	If Len(__aHeadAvp) == 0

		For nX := 2 to nQuantas
			cCampos += "/N3_VORIG" + cValtoChar(nX)
		Next nX

		//novas entidades contaveis
		For nX := 5 to nQtdEntid
			cCampos += "/N3_EC" + StrZero(nX, 2) + "DB"
		Next

		//Monta aHeader do AVP
		AtfX3AVP( "SN3", cCampos , __lAtfAuto )

	EndIf

	nPosTpSld := aScan( __aHeadAvp, { |x| AllTrim( x[2] ) == "N3_TPSALDO" } )

	//Se os campos referente a AVP estiverem em branco
	//devo validar como OK mas sem calculos ou geracao do Tipo 14
	If __lCopia
		lRet := .T.
	ElseIf (cVar == "M->N1_INDAVP" .And. Empty(cIndAVP)) .Or. (cVar == "M->N1_DTAVP")
		lRet := .T.
	Else
		If cVar == "M->N1_INDAVP" .And. !Empty(cIndAVP)
			FIT->(dbSetOrder(1))
			If !(FIT->(MsSeek(xFilial("FIT")+ oModel:GetValue('SN1MASTER','N1_INDAVP'))))
				Help("  ",1,"NOINDAVP")  //"Código de indice financeiro não cadastrado."
			Else
				lRet := .T.
			Endif
		ElseIf !Empty(cIndAVP) .And. !Empty(dDataAVP)
			lRet := .T.
		Else
			oModel:SetValue('SN1MASTER','N1_TAXAVP',0)
			aReg14 := {}
			__aColsAvp:= {}
		Endif

		If lRet
			//Pego Indice - Ultimo valor
			cCodInd  := oModel:GetValue('SN1MASTER','N1_INDAVP')
			cPeriodo := GetAdvFVal("FIT","FIT_PERIOD", xFilial("FIT") + oModel:GetValue('SN1MASTER','N1_INDAVP'))
			nTaxa	  := AtfRetInd(cCodInd,oModel:GetValue('SN1MASTER','N1_INIAVP'), /*dDataProc*/)
			nValVP   := 0
			nValAVP  := 0
			nRecno	  := 1
			//Atualiza a taxa em tela
			oModel:SetValue('SN1MASTER','N1_TAXAVP', nTaxa)//M->N1_TAXAVP := nTaxa

			//Gera movimento tipo 14 para cada Tipo 10 existente no detalhe da ficha de ativo
			lRet14 := AF012Ger14(aReg14)

			//Se foi criado algum registro Tipo 14, atualizo aCols
			If lRet14

				For nX := 1 to Len(aReg14)

					For nY := 1 to nQuantas
						nPosVlr  := aScan( __aHeadAvp, { |x| AllTrim( x[2] ) == "N3_VORIG" + cValToChar(nY) } )
						nAVPMan  := Ascan( __aHeadAvp ,{ |e| AllTrim( e[2] ) == "N3AVPPLAN" } )

						If nPosVlr > 0

							nValItem := aReg14[nX][nPosVlr]
							If Alltrim(oModel:GetValue('SN1MASTER','N1_TPAVP')) != '2'
								If nValItem > 0 .And. nAVPMan > 0 .And. aReg14[nX][nAVPMan] > 0 .And. nY == 1
									nValAVP      := aReg14[nX][nAVPMan]
									nTaxa        := AFCalcTx(cCodInd,nValItem,nValAVP,oModel:GetValue('SN1MASTER','N1_INIAVP'),;
													 oModel:GetValue('SN1MASTER','N1_DTAVP'))
									oModel:SetValue('SN1MASTER','N1_TAXAVP', nTaxa)
								Else
									AFCalcAVP("C",nTaxa,cCodInd,nValItem,cPeriodo, oModel:GetValue('SN1MASTER','N1_INIAVP'),;
												@nValVP, @nValAVP, oModel:GetValue('SN1MASTER','N1_DTAVP'))
								EndIf

								//Atualizo o valor no __aColsAvp
								If nValAVP > 0

									aReg14[nX][nPosVlr] := nValAVp
									nPos	:= aScan( __aColsAvp, { |x| AllTrim( x[nPosTpSld] ) == aReg14[nX][nPosTpSld] } )
									If nPos == 0
										aAdd(__aColsAvp, aReg14[nX])
									Else
										__aColsAvp[nPos][nPosVlr] := aReg14[nX][nPosVlr]
									Endif
								Endif
							EndIf

						EndIf

					Next nY

				Next nX

			Endif
		Endif

	Endif

Endif

oModel := Nil
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF12VLRM
Valida Valores Negativos por Tipo de acordo com o parametro MV_N3TPNEG.
@author Wilson Possani de Godoi
@since  16/09/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF12VLRM(nValor)
Local oModel		:= FWModelActive()
Local oAux			:= oModel:GetModel('SN3DETAIL')
Local cTipo 		:= oAux:GetValue('N3_TIPO')
Local cN3TipoNeg	:= Alltrim(SuperGetMv("MV_N3TPNEG",.F.,"")) // Tipos de N3_TIPO que aceitam Valor originais negativos
Local lRet			:= .T.

Default nValor 	:= &(ReadVar())

If nValor < 0
	If !(cTipo $ cN3TipoNeg + "|05")
		Help(" ",1,"AF012TPNEG")//Valor deste item não pode ser negativo.###Informe um valor maior que zero ou zero.
		lRet := .F.
	Endif
EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AVLR
Preenche os valores do bem.
@author William Matos Gundim Junior
@since  10/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AVLR()
Local lZeraDepr := GetNewPar("MV_ZRADEPR",.F.)
Local lRet       := .T.
Local aTotVOrig := {0,0,0,0,0} // Soma dos valores originais
Local aTotDepAc := {0,0,0,0,0} // Soma da depreciacao acumulada
Local aAreaSn3  := SN3->(GetArea())
Local nX		  := 1
Local oModel 	  := FWModelActive()
Local oAux		  := oModel:GetModel('SN3DETAIL')
Local nOper 	  := oModel:GetOperation()
Local oStruct   := oAux:GetStruct()
Local aAux       := oStruct:GetFields()
Local aVOrig	  := AtfMultPos(aAux, "N3_VORIG" , 3)
Local aAmpli	  := AtfMultPos(aAux, "N3_AMPLIA", 3)
Local aVRDac	  := AtfMultPos(aAux, "N3_VRDACM", 3)
Local nLinha	  := oAux:GetLine()
Local cVOrig	  := ''
Local cDac		  := ''
Local lAtfClas  := IsInCallStack("AF240Class") //Por legado da versão 11, permitir a alteração do valor do bem na classificação de ativos (ATFA240)
Local lMile     	:= IsInCallStack("CFG600LMdl") .Or. IsInCallStack("FWMILEIMPORT") .Or. IsInCallStack("FWMILEEXPORT")
Local cStatus 	:= oModel:GetValue("SN1MASTER","N1_STATUS")

If !oModel:IsCopy() .AND. !oAux:IsInserted() .AND. !lAtfClas .AND. !(lIsRussia .AND. (Empty(cStatus) .OR. cStatus=="0")) // Se for c¢pia de registro, autorizar esta alteração
	Help(" ",1,"AFA010NAOP")
	lRet := .F.
Else
	lRet := AF12VLRM(oAux:GetValue("N3_VORIG1"))
	// Verifica tratamento para reavaliacoes, conforme parametro
	If lRet
		If oAux:GetValue('N3_TIPO') $ "02|05" .AND. lZeraDepr //.AND. "N3_VORIG1" $ ReadVar()
			SN3->(MsSeek(xFilial("SN3")+SN1->(N1_CBASE+N1_ITEM)))
			nI := 1
			// soma os valores originais e depreciacoes acumuladas
			While SN3->(!Eof()).AND. SN3->(N3_CBASE+N3_ITEM) == SN1->(N1_CBASE+N1_ITEM) .AND.;
					xFilial("SN3") == SN3->N3_FILIAL

				oAux:GoLine(nI)
				For nX := 1 To Len(aVOrig)

					If Val( SN3->N3_BAIXA ) == 0  // Baixas nao devem ser consideradas, pois nao aparecem na tela
						aTotVOrig[nX] += SN3->&(aAux[aVOrig[nX],3]) +SN3->&( aAux[aAmpli[nX],3])
						aTotDepAc[nX] += SN3->&(aAux[aVRDac[nX],3])
						cVOrig := aAux[aVOrig[nX],3]
						cDac	:= aAux[aVRDac[nX],3]
						//
						oAux:SetValue(cVOrig, (SN3->&(aAux[aVOrig[nX],3]) - SN3->&(aAux[aVRDac[nX],3])))
						oAux:SetValue(cDac  , 0) // Zera depreciacoes acumuladas
					EndIf

				Next
				nI++
				SN3->(DbSkip())
			EndDo

			oAux:GoLine(nLinha) //Volta para a linha atual
			For nX := 2 To Len(aVOrig)

				cVOrig := aAux[aVOrig[nX],3]
				oAux:SetValue(cVOrig,(oAux:GetValue('N3_VORIG1') / If(nX == 1, nX, RecMoeda(dDataBase,nX))) - (aTotVOrig[nX]-aTotDepAc[nX]))
				If cPaisLoc $ 'PER|ARG'
					If nX == oAux:GetValue('N3_MOEDAQU')
						oAux:SetValue(cVOrig, (oAux:GetValue('N3_VORIG1') /;
							If(Empty(M->N1_TXMOEDA),RecMoeda(dDtConv,nX),M->N1_TXMOEDA)))
					Endif
				EndIf

			Next
			SN3->(RestArea(aAreaSn3))
		Endif

		If oAux:GetValue('N3_TIPO') == "01" .And. nOper == MODEL_OPERATION_INSERT .And. !__lClassifica

			oModel:LoadValue("SN1MASTER","N1_VLAQUIS",oAux:GetValue("N3_VORIG1"))

		EndIf

		If ( ! __lAtfAuto).and.  ( ! lMile)
			If Dtos(oModel:GetValue('SN1MASTER','N1_AQUISIC')) <= "19951231" .And.;
					MsgYesNo(STR0129) //"Calcula valor atual do bem?"
					Af012aCalc()
					Af012aConv( )
			Endif
		Endif
	Endif
Endif

If lRet
	AF012VLAEC()
Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012aCalc
Função para calcular o valor do bem adquirido antes de 01/01/96
@author William Matos Gundim Junior
@since  23/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012aCalc()
Local aFator := {}
Local nIndice := 1
Local nX
Local aStru
Local oModel := FWModelActive()
Local dDatAquis := oModel:GetValue('SN1MASTER','N1_AQUISIC')
Local nValOrig  := oModel:GetValue('SN3DETAIL','N3_VORIG1')

// 01/01/1938 A 31/12/1977
AAdd(aFator,	{Ctod("31/12/1938"),  0.0693 });AAdd(aFator, {Ctod("31/12/1939"),  0.0732 })
AAdd(aFator,	{Ctod("31/12/1940"),  0.0777 });AAdd(aFator, {Ctod("31/12/1941"),  0.0854 })
AAdd(aFator,	{Ctod("31/12/1942"),  0.1053 });AAdd(aFator, {Ctod("31/12/1943"),  0.1220 })
AAdd(aFator,	{Ctod("31/12/1944"),  0.1398 });AAdd(aFator, {Ctod("31/12/1945"),  0.1636 })
AAdd(aFator,	{Ctod("31/12/1946"),  0.1876 });AAdd(aFator, {Ctod("31/12/1947"),  0.2024 })
AAdd(aFator,	{Ctod("31/12/1948"),  0.2136 });AAdd(aFator, {Ctod("31/12/1949"),  0.2331 })
AAdd(aFator,	{Ctod("31/12/1950"),  0.2652 });AAdd(aFator, {Ctod("31/12/1951"),  0.3204 })
AAdd(aFator,	{Ctod("31/12/1952"),  0.3495 });AAdd(aFator, {Ctod("31/12/1953"),  0.4046 })
AAdd(aFator,	{Ctod("31/12/1954"),  0.5124 });AAdd(aFator, {Ctod("31/12/1955"),  0.5916 })
AAdd(aFator,	{Ctod("31/12/1956"),  0.6990 });AAdd(aFator, {Ctod("31/12/1957"),  0.7688 })
AAdd(aFator,	{Ctod("31/12/1958"),  0.9046 });AAdd(aFator, {Ctod("31/12/1959"),  1.2407 })
AAdd(aFator,	{Ctod("31/12/1960"),  1.6349 });AAdd(aFator, {Ctod("31/12/1961"),  2.2616 })
AAdd(aFator,	{Ctod("31/12/1962"),  3.4965 });AAdd(aFator, {Ctod("31/12/1963"),  7.7040 })
AAdd(aFator,	{Ctod("31/12/1964"), 13.3872 });AAdd(aFator, {Ctod("31/12/1965"), 16.3000 })
AAdd(aFator,	{Ctod("31/12/1966"), 22.6900 });AAdd(aFator, {Ctod("31/12/1967"), 27.9600 })
AAdd(aFator,	{Ctod("31/12/1968"), 34.9500 });AAdd(aFator, {Ctod("31/12/1969"), 41.4200 })
AAdd(aFator,	{Ctod("31/12/1970"), 49.5400 });AAdd(aFator, {Ctod("31/12/1971"), 60.7700 })
AAdd(aFator,	{Ctod("31/12/1972"), 70.0700 });AAdd(aFator, {Ctod("31/12/1973"), 79.0700 })
AAdd(aFator,	{Ctod("31/12/1974"),105.4100 });AAdd(aFator, {Ctod("31/12/1975"),130.9300 })
AAdd(aFator,	{Ctod("31/12/1976"),179.6800 });AAdd(aFator, {Ctod("31/03/1977"),187.0000 })
AAdd(aFator,	{Ctod("30/06/1977"),200.7300 });AAdd(aFator, {Ctod("30/09/1977"),219.1100 })
AAdd(aFator,	{Ctod("31/12/1977"),230.4000 })

// 01/01/1978 a 31/01/1989
AAdd(aFator,	{Ctod("31/01/1978"),238.3200 });AAdd(aFator, {Ctod("28/02/1978"),243.3500 })
AAdd(aFator,	{Ctod("31/03/1978"),248.9900 });AAdd(aFator, {Ctod("30/04/1978"),255.4100 })
AAdd(aFator,	{Ctod("31/05/1978"),262.8700 });AAdd(aFator, {Ctod("30/06/1978"),270.8800 })
AAdd(aFator,	{Ctod("31/07/1978"),279.0400 });AAdd(aFator, {Ctod("31/08/1978"),287.5800 })
AAdd(aFator,	{Ctod("30/09/1978"),295.5700 });AAdd(aFator, {Ctod("31/10/1978"),303.2900 })
AAdd(aFator,	{Ctod("30/11/1978"),310.4900 });AAdd(aFator, {Ctod("31/12/1978"),318.4400 })
AAdd(aFator,	{Ctod("31/01/1979"),326.8200 });AAdd(aFator, {Ctod("28/02/1979"),334.2000 })
AAdd(aFator,	{Ctod("31/03/1979"),341.9700 });AAdd(aFator, {Ctod("30/04/1979"),350.5100 })
AAdd(aFator,	{Ctod("31/05/1979"),363.6400 });AAdd(aFator, {Ctod("30/06/1979"),377.5400 })
AAdd(aFator,	{Ctod("31/07/1979"),390.1000 });AAdd(aFator, {Ctod("31/08/1979"),400.7100 })
AAdd(aFator,	{Ctod("30/09/1979"),412.2400 });AAdd(aFator, {Ctod("31/10/1979"),428.8000 })
AAdd(aFator,	{Ctod("30/11/1979"),448.4700 });AAdd(aFator, {Ctod("31/12/1979"),468.7100 })
AAdd(aFator,	{Ctod("31/01/1980"),487.8300 });AAdd(aFator, {Ctod("29/02/1980"),508.3300 })
AAdd(aFator,	{Ctod("31/03/1980"),527.1400 });AAdd(aFator, {Ctod("30/04/1980"),549.6400 })
AAdd(aFator,	{Ctod("31/05/1980"),566.8600 });AAdd(aFator, {Ctod("30/06/1980"),586.1300 })
AAdd(aFator,	{Ctod("31/07/1980"),604.8900 });AAdd(aFator, {Ctod("31/08/1980"),624.2500 })
AAdd(aFator,	{Ctod("30/09/1980"),644.2300 });AAdd(aFator, {Ctod("31/10/1980"),663.5600 })
AAdd(aFator,	{Ctod("30/11/1980"),684.7900 });AAdd(aFator, {Ctod("31/12/1980"),706.7000 })
AAdd(aFator,	{Ctod("31/01/1981"),738.5000 });AAdd(aFator, {Ctod("28/02/1981"),775.4300 })
AAdd(aFator,	{Ctod("31/03/1981"),825.8300 });AAdd(aFator, {Ctod("30/04/1981"),877.8600 })
AAdd(aFator,	{Ctod("31/05/1981"),930.5600 });AAdd(aFator, {Ctod("30/06/1981"),986.3600 })
AAdd(aFator,	{Ctod("31/07/1981"),1045.5400});AAdd(aFator, {Ctod("31/08/1981"),1108.2700})
AAdd(aFator,	{Ctod("30/09/1981"),1172.5500});AAdd(aFator, {Ctod("31/10/1981"),1239.3900})
AAdd(aFator,	{Ctod("30/11/1981"),1310.0400});AAdd(aFator, {Ctod("31/12/1981"),1382.0900})
AAdd(aFator,	{Ctod("31/01/1982"),1453.9600});AAdd(aFator, {Ctod("28/02/1982"),1526.6600})
AAdd(aFator,	{Ctod("31/03/1982"),1602.9900});AAdd(aFator, {Ctod("30/04/1982"),1683.1400})
AAdd(aFator,	{Ctod("31/05/1982"),1775.7100});AAdd(aFator, {Ctod("30/06/1982"),1873.3700})
AAdd(aFator,	{Ctod("31/07/1982"),1976.4100});AAdd(aFator, {Ctod("31/08/1982"),2094.9900})
AAdd(aFator,	{Ctod("30/09/1982"),2241.6400});AAdd(aFator, {Ctod("31/10/1982"),2398.5500})
AAdd(aFator,	{Ctod("30/11/1982"),2566.4500});AAdd(aFator, {Ctod("31/12/1982"),2733.2700})
AAdd(aFator,	{Ctod("31/01/1983"),2910.9300});AAdd(aFator, {Ctod("28/02/1983"),3085.5900})
AAdd(aFator,	{Ctod("31/03/1983"),3292.3200});AAdd(aFator, {Ctod("30/04/1983"),3588.6300})
AAdd(aFator,	{Ctod("31/05/1983"),3911.6100});AAdd(aFator, {Ctod("30/06/1983"),4224.5400})
AAdd(aFator,	{Ctod("31/07/1983"),4554.0500});AAdd(aFator, {Ctod("31/08/1983"),4963.9100})
AAdd(aFator,	{Ctod("30/09/1983"),5385.8400});AAdd(aFator, {Ctod("31/10/1983"),5897.4900})
AAdd(aFator,	{Ctod("30/11/1983"),6469.5500});AAdd(aFator, {Ctod("31/12/1983"),7012.9900})
AAdd(aFator,	{Ctod("31/01/1984"),7545.9800});AAdd(aFator, {Ctod("29/02/1984"),8285.4900})
AAdd(aFator,	{Ctod("31/03/1984"),9304.6100});AAdd(aFator, {Ctod("30/04/1984"),10235.0700})
AAdd(aFator,	{Ctod("31/05/1984"),11145.9900});AAdd(aFator, {Ctod("30/06/1984"),12137.9800})
AAdd(aFator,	{Ctod("31/07/1984"),13254.6700});AAdd(aFator, {Ctod("31/08/1984"),14619.9000})
AAdd(aFator,	{Ctod("30/09/1984"),16619.6100});AAdd(aFator, {Ctod("31/10/1984"),17867.0000})
AAdd(aFator,	{Ctod("30/11/1984"),20118.7100});AAdd(aFator, {Ctod("31/12/1984"),22110.4600})
AAdd(aFator,	{Ctod("31/01/1985"),24432.0600});AAdd(aFator, {Ctod("28/02/1985"),27510.5000})
AAdd(aFator,	{Ctod("31/03/1985"),30316.5700});AAdd(aFator, {Ctod("30/04/1985"),34166.7700})
AAdd(aFator,	{Ctod("31/05/1985"),38208.4600});AAdd(aFator, {Ctod("30/06/1985"),42031.5600})
AAdd(aFator,	{Ctod("31/07/1985"),45901.9100});AAdd(aFator, {Ctod("31/08/1985"),49396.8800})
AAdd(aFator,	{Ctod("30/09/1985"),53437.4000});AAdd(aFator, {Ctod("31/10/1985"),58300.2000})
AAdd(aFator,	{Ctod("30/11/1985"),63547.2200});AAdd(aFator, {Ctod("31/12/1985"),70613.6700})
AAdd(aFator,	{Ctod("31/01/1986"),80047.6600});AAdd(aFator, {Ctod("28/02/1986"),93039.4000})
AAdd(aFator,	{Ctod("31/03/1986"),   99.3900});AAdd(aFator, {Ctod("30/04/1986"),  100.1600})
AAdd(aFator,	{Ctod("31/05/1986"),  101.5700});AAdd(aFator, {Ctod("30/06/1986"),  102.8600})
AAdd(aFator,	{Ctod("31/07/1986"),  104.0800});AAdd(aFator, {Ctod("31/08/1986"),  105.8300})
AAdd(aFator,	{Ctod("30/09/1985"),  107.6500});AAdd(aFator, {Ctod("31/10/1986"),  109.7000})
AAdd(aFator,	{Ctod("30/11/1986"),  113.3000});AAdd(aFator, {Ctod("31/12/1986"),  119.4900})
AAdd(aFator,	{Ctod("31/01/1987"),  129.8700});AAdd(aFator, {Ctod("28/02/1987"),  151.8200})
AAdd(aFator,	{Ctod("31/03/1987"),  181.6100});AAdd(aFator, {Ctod("30/04/1987"),  207.9700})
AAdd(aFator,	{Ctod("31/05/1987"),  251.5600});AAdd(aFator, {Ctod("30/06/1987"),  310.5300})
AAdd(aFator,	{Ctod("31/07/1987"),  366.4900});AAdd(aFator, {Ctod("31/08/1987"),  377.6700})
AAdd(aFator,	{Ctod("30/09/1987"),  401.6900});AAdd(aFator, {Ctod("31/10/1987"),  424.5100})
AAdd(aFator,	{Ctod("30/11/1987"),  463.4800});AAdd(aFator, {Ctod("31/12/1987"),  522.9900})
AAdd(aFator,	{Ctod("31/01/1988"),  596.9400});AAdd(aFator, {Ctod("29/02/1988"),  695.5000})
AAdd(aFator,	{Ctod("31/03/1988"),  820.4200});AAdd(aFator, {Ctod("30/04/1988"),  951.7700})
AAdd(aFator,	{Ctod("31/05/1988"), 1135.2700});AAdd(aFator, {Ctod("30/06/1988"), 1137.1200})
AAdd(aFator,	{Ctod("31/07/1988"), 1598.2600});AAdd(aFator, {Ctod("31/08/1988"), 1982.4800})
AAdd(aFator,	{Ctod("30/09/1988"), 2392.0600});AAdd(aFator, {Ctod("31/10/1988"), 2966.3900})
AAdd(aFator,	{Ctod("30/11/1988"), 3774.7300});AAdd(aFator, {Ctod("31/12/1988"), 4790.8900})
// Jan. a Jul/1989
AAdd(aFator,	{Ctod("31/01/1989"), 6170.1900});AAdd(aFator, {Ctod("28/02/1989"),    1.0000})
AAdd(aFator,	{Ctod("31/03/1989"),    1.0360});AAdd(aFator, {Ctod("30/04/1989"),    1.0991})
AAdd(aFator,	{Ctod("31/05/1989"),    1.1794});AAdd(aFator, {Ctod("30/06/1989"),    1.2966})

// Jul/1989 a 31/01/1991
Aadd(aFator,{Ctod("03/07/89"),1.618600});    Aadd(aFator,{Ctod("04/07/89"),1.635800})
Aadd(aFator,{Ctod("05/07/89"),1.653200});    Aadd(aFator,{Ctod("06/07/89"),1.670700})
Aadd(aFator,{Ctod("07/07/89"),1.688500});    Aadd(aFator,{Ctod("10/07/89"),1.707700})
Aadd(aFator,{Ctod("11/07/89"),1.727200});    Aadd(aFator,{Ctod("12/07/89"),1.746900})
Aadd(aFator,{Ctod("13/07/89"),1.767800});    Aadd(aFator,{Ctod("14/07/89"),1.789000})
Aadd(aFator,{Ctod("17/07/89"),1.810400});    Aadd(aFator,{Ctod("18/07/89"),1.832100})
Aadd(aFator,{Ctod("19/07/89"),1.854100});    Aadd(aFator,{Ctod("20/07/89"),1.876300})
Aadd(aFator,{Ctod("21/07/89"),1.898700});    Aadd(aFator,{Ctod("24/07/89"),1.921500})
Aadd(aFator,{Ctod("25/07/89"),1.944500});    Aadd(aFator,{Ctod("26/07/89"),1.970900})
Aadd(aFator,{Ctod("27/07/89"),1.997600});    Aadd(aFator,{Ctod("28/07/89"),2.024700})
Aadd(aFator,{Ctod("31/07/89"),2.054100});    Aadd(aFator,{Ctod("01/08/89"),2.084200})
Aadd(aFator,{Ctod("02/08/89"),2.106300});    Aadd(aFator,{Ctod("03/08/89"),2.128700})
Aadd(aFator,{Ctod("04/08/89"),2.151300});    Aadd(aFator,{Ctod("07/08/89"),2.174100})
Aadd(aFator,{Ctod("08/08/89"),2.197200});    Aadd(aFator,{Ctod("09/08/89"),2.220500})
Aadd(aFator,{Ctod("10/08/89"),2.244100});    Aadd(aFator,{Ctod("11/08/89"),2.267900})
Aadd(aFator,{Ctod("14/08/89"),2.293600});    Aadd(aFator,{Ctod("15/08/89"),2.319500})
Aadd(aFator,{Ctod("16/08/89"),2.345700});    Aadd(aFator,{Ctod("17/08/89"),2.372200})
Aadd(aFator,{Ctod("18/08/89"),2.399000});    Aadd(aFator,{Ctod("21/08/89"),2.426900})
Aadd(aFator,{Ctod("22/08/89"),2.455100});    Aadd(aFator,{Ctod("23/08/89"),2.483600})
Aadd(aFator,{Ctod("24/08/89"),2.512500});    Aadd(aFator,{Ctod("25/08/89"),2.541600})
Aadd(aFator,{Ctod("28/08/89"),2.570000});    Aadd(aFator,{Ctod("29/08/89"),2.598600})
Aadd(aFator,{Ctod("30/08/89"),2.627600});    Aadd(aFator,{Ctod("31/08/89"),2.661400})
Aadd(aFator,{Ctod("01/09/89"),2.695600});    Aadd(aFator,{Ctod("04/09/89"),2.730500})
Aadd(aFator,{Ctod("05/09/89"),2.767800});    Aadd(aFator,{Ctod("06/09/89"),2.805500})
Aadd(aFator,{Ctod("08/09/89"),2.845000});    Aadd(aFator,{Ctod("11/09/89"),2.885000})
Aadd(aFator,{Ctod("12/09/89"),2.925700});    Aadd(aFator,{Ctod("13/09/89"),2.966900})
Aadd(aFator,{Ctod("14/09/89"),3.008600});    Aadd(aFator,{Ctod("15/09/89"),3.053300})
Aadd(aFator,{Ctod("18/09/89"),3.098500});    Aadd(aFator,{Ctod("19/09/89"),3.144500})
Aadd(aFator,{Ctod("20/09/89"),3.191100});    Aadd(aFator,{Ctod("21/09/89"),3.238500})
Aadd(aFator,{Ctod("22/09/89"),3.286500});    Aadd(aFator,{Ctod("25/09/89"),3.342800})
Aadd(aFator,{Ctod("26/09/89"),3.400100});    Aadd(aFator,{Ctod("27/09/89"),3.458300})
Aadd(aFator,{Ctod("28/09/89"),3.517600});    Aadd(aFator,{Ctod("29/09/89"),3.584500})
Aadd(aFator,{Ctod("02/10/89"),3.664700});    Aadd(aFator,{Ctod("03/10/89"),3.718700})
Aadd(aFator,{Ctod("04/10/89"),3.773500});    Aadd(aFator,{Ctod("05/10/89"),3.829800})
Aadd(aFator,{Ctod("06/10/89"),3.887000});    Aadd(aFator,{Ctod("10/10/89"),3.945000})
Aadd(aFator,{Ctod("11/10/89"),4.003900});    Aadd(aFator,{Ctod("12/10/89"),4.063600})
Aadd(aFator,{Ctod("13/10/89"),4.125000});    Aadd(aFator,{Ctod("16/10/89"),4.185500})
Aadd(aFator,{Ctod("17/10/89"),4.246900});    Aadd(aFator,{Ctod("18/10/89"),4.309100})
Aadd(aFator,{Ctod("19/10/89"),4.372300});    Aadd(aFator,{Ctod("20/10/89"),4.436300})
Aadd(aFator,{Ctod("23/10/89"),4.501400});    Aadd(aFator,{Ctod("24/10/89"),4.573600})
Aadd(aFator,{Ctod("25/10/89"),4.646900});    Aadd(aFator,{Ctod("26/10/89"),4.721400})
Aadd(aFator,{Ctod("27/10/89"),4.797200});    Aadd(aFator,{Ctod("30/10/89"),4.878800})
Aadd(aFator,{Ctod("31/10/89"),4.961900});    Aadd(aFator,{Ctod("01/11/89"),5.043400})
Aadd(aFator,{Ctod("03/11/89"),5.124600});    Aadd(aFator,{Ctod("06/11/89"),5.207100})
Aadd(aFator,{Ctod("07/11/89"),5.291700});    Aadd(aFator,{Ctod("08/11/89"),5.377700})
Aadd(aFator,{Ctod("09/11/89"),5.465000});    Aadd(aFator,{Ctod("10/11/89"),5.556500})
Aadd(aFator,{Ctod("13/11/89"),5.649500});    Aadd(aFator,{Ctod("14/11/89"),5.744100})
Aadd(aFator,{Ctod("16/11/89"),5.840300});    Aadd(aFator,{Ctod("17/11/89"),5.940000})
Aadd(aFator,{Ctod("20/11/89"),6.041400});    Aadd(aFator,{Ctod("21/11/89"),6.144500})
Aadd(aFator,{Ctod("22/11/89"),6.249400});    Aadd(aFator,{Ctod("23/11/89"),6.356100})
Aadd(aFator,{Ctod("24/11/89"),6.464600});    Aadd(aFator,{Ctod("27/11/89"),6.584300})
Aadd(aFator,{Ctod("28/11/89"),6.706300});    Aadd(aFator,{Ctod("29/11/89"),6.830600})
Aadd(aFator,{Ctod("30/11/89"),6.957100});    Aadd(aFator,{Ctod("01/12/89"),7.132400})
Aadd(aFator,{Ctod("04/12/89"),7.259800});    Aadd(aFator,{Ctod("05/12/89"),7.389500})
Aadd(aFator,{Ctod("06/12/89"),7.521500});    Aadd(aFator,{Ctod("07/12/89"),7.655900})
Aadd(aFator,{Ctod("08/12/89"),7.792700});    Aadd(aFator,{Ctod("11/12/89"),7.931900})
Aadd(aFator,{Ctod("12/12/89"),8.083700});    Aadd(aFator,{Ctod("13/12/89"),8.251300})
Aadd(aFator,{Ctod("14/12/89"),8.422400});    Aadd(aFator,{Ctod("15/12/89"),8.597100})
Aadd(aFator,{Ctod("18/12/89"),8.775400});    Aadd(aFator,{Ctod("19/12/89"),8.957400})
Aadd(aFator,{Ctod("20/12/89"),9.143100});    Aadd(aFator,{Ctod("21/12/89"),9.368400})
Aadd(aFator,{Ctod("22/12/89"),9.620100});    Aadd(aFator,{Ctod("26/12/89"),9.878600})
Aadd(aFator,{Ctod("27/12/89"),10.14400});    Aadd(aFator,{Ctod("28/12/89"),10.40750})
Aadd(aFator,{Ctod("29/12/89"),10.67620});    Aadd(aFator,{Ctod("02/01/90"),10.95180})
Aadd(aFator,{Ctod("03/01/90"),11.16740});    Aadd(aFator,{Ctod("04/01/90"),11.38720})
Aadd(aFator,{Ctod("05/01/90"),11.60360});    Aadd(aFator,{Ctod("08/01/90"),11.82400})
Aadd(aFator,{Ctod("09/01/90"),12.04870});    Aadd(aFator,{Ctod("10/01/90"),12.27760})
Aadd(aFator,{Ctod("11/01/90"),12.51090});    Aadd(aFator,{Ctod("12/01/90"),12.74860})
Aadd(aFator,{Ctod("15/01/90"),12.99080});    Aadd(aFator,{Ctod("16/01/90"),13.23760})
Aadd(aFator,{Ctod("17/01/90"),13.48910});    Aadd(aFator,{Ctod("18/01/90"),13.74540})
Aadd(aFator,{Ctod("19/01/90"),14.00660});    Aadd(aFator,{Ctod("22/01/90"),14.27270})
Aadd(aFator,{Ctod("23/01/90"),14.58540});    Aadd(aFator,{Ctod("24/01/90"),14.90510})
Aadd(aFator,{Ctod("25/01/90"),15.23170});    Aadd(aFator,{Ctod("26/01/90"),15.56540})
Aadd(aFator,{Ctod("29/01/90"),15.91930});    Aadd(aFator,{Ctod("30/01/90"),16.28130})
Aadd(aFator,{Ctod("31/01/90"),16.68410});    Aadd(aFator,{Ctod("01/02/90"),17.09680})
Aadd(aFator,{Ctod("02/02/90"),17.52510});    Aadd(aFator,{Ctod("05/02/90"),17.96420})
Aadd(aFator,{Ctod("06/02/90"),18.49200});    Aadd(aFator,{Ctod("07/02/90"),19.03530})
Aadd(aFator,{Ctod("08/02/90"),19.59460});    Aadd(aFator,{Ctod("09/02/90"),20.17030})
Aadd(aFator,{Ctod("12/02/90"),20.76300});    Aadd(aFator,{Ctod("13/02/90"),21.43040})
Aadd(aFator,{Ctod("14/02/90"),22.11940});    Aadd(aFator,{Ctod("15/02/90"),22.83040})
Aadd(aFator,{Ctod("16/02/90"),23.56430});    Aadd(aFator,{Ctod("19/02/90"),24.34200})
Aadd(aFator,{Ctod("20/02/90"),25.14530});    Aadd(aFator,{Ctod("21/02/90"),25.98710})
Aadd(aFator,{Ctod("22/02/90"),26.85710});    Aadd(aFator,{Ctod("23/02/90"),27.75630})
Aadd(aFator,{Ctod("28/02/90"),28.68550});    Aadd(aFator,{Ctod("01/03/90"),29.53990})
Aadd(aFator,{Ctod("02/03/90"),30.28330});    Aadd(aFator,{Ctod("05/03/90"),31.04550})
Aadd(aFator,{Ctod("06/03/90"),31.82690});    Aadd(aFator,{Ctod("07/03/90"),32.62790})
Aadd(aFator,{Ctod("08/03/90"),33.44910});    Aadd(aFator,{Ctod("09/03/90"),34.31090})
Aadd(aFator,{Ctod("12/03/90"),35.19500});    Aadd(aFator,{Ctod("13/03/90"),36.10180})
Aadd(aFator,{Ctod("14/03/90"),37.03200});    Aadd(aFator,{Ctod("15/03/90"),37.98620})
Aadd(aFator,{Ctod("16/03/90"),38.96490});    Aadd(aFator,{Ctod("19/03/90"),39.96890})
Aadd(aFator,{Ctod("20/03/90"),40.14200});    Aadd(aFator,{Ctod("21/03/90"),40.31580})
Aadd(aFator,{Ctod("22/03/90"),40.49040});    Aadd(aFator,{Ctod("23/03/90"),40.66580})
Aadd(aFator,{Ctod("26/03/90"),40.84190});    Aadd(aFator,{Ctod("27/03/90"),41.01880})
Aadd(aFator,{Ctod("28/03/90"),41.19650});    Aadd(aFator,{Ctod("29/03/90"),41.37490})
Aadd(aFator,{Ctod("30/03/90"),41.55410});    Aadd(aFator,{Ctod("02/04/90"),41.73400})
Aadd(aFator,{Ctod("03/04/90"),41.73400});    Aadd(aFator,{Ctod("04/04/90"),41.73400})
Aadd(aFator,{Ctod("05/04/90"),41.73400});    Aadd(aFator,{Ctod("06/04/90"),41.73400})
Aadd(aFator,{Ctod("09/04/90"),41.73400});    Aadd(aFator,{Ctod("10/04/90"),41.73400})
Aadd(aFator,{Ctod("11/04/90"),41.73400});    Aadd(aFator,{Ctod("16/04/90"),41.73400})
Aadd(aFator,{Ctod("17/04/90"),41.73400});    Aadd(aFator,{Ctod("18/04/90"),41.73400})
Aadd(aFator,{Ctod("19/04/90"),41.73400});    Aadd(aFator,{Ctod("20/04/90"),41.73400})
Aadd(aFator,{Ctod("23/04/90"),41.73400});    Aadd(aFator,{Ctod("24/04/90"),41.73400})
Aadd(aFator,{Ctod("25/04/90"),41.73400});    Aadd(aFator,{Ctod("26/04/90"),41.73400})
Aadd(aFator,{Ctod("27/04/90"),41.73400});    Aadd(aFator,{Ctod("30/04/90"),41.73400})
Aadd(aFator,{Ctod("02/05/90"),41.73400});    Aadd(aFator,{Ctod("03/05/90"),41.74930})
Aadd(aFator,{Ctod("04/05/90"),41.76470});    Aadd(aFator,{Ctod("07/05/90"),41.78000})
Aadd(aFator,{Ctod("08/05/90"),41.79530});    Aadd(aFator,{Ctod("09/05/90"),41.81060})
Aadd(aFator,{Ctod("10/05/90"),41.82600});    Aadd(aFator,{Ctod("11/05/90"),41.84130})
Aadd(aFator,{Ctod("14/05/90"),41.88940});    Aadd(aFator,{Ctod("15/05/90"),41.93760})
Aadd(aFator,{Ctod("16/05/90"),41.98580});    Aadd(aFator,{Ctod("17/05/90"),42.05120})
Aadd(aFator,{Ctod("18/05/90"),42.13530});    Aadd(aFator,{Ctod("21/05/90"),42.21960})
Aadd(aFator,{Ctod("22/05/90"),42.30410});    Aadd(aFator,{Ctod("23/05/90"),42.38880})
Aadd(aFator,{Ctod("24/05/90"),42.47360});    Aadd(aFator,{Ctod("25/05/90"),42.55860})
Aadd(aFator,{Ctod("28/05/90"),42.64370});    Aadd(aFator,{Ctod("29/05/90"),42.83240})
Aadd(aFator,{Ctod("30/05/90"),43.02190});    Aadd(aFator,{Ctod("31/05/90"),43.49800})
Aadd(aFator,{Ctod("01/06/90"),43.97930});    Aadd(aFator,{Ctod("04/06/90"),44.07620})
Aadd(aFator,{Ctod("05/06/90"),44.17330});    Aadd(aFator,{Ctod("06/06/90"),44.27070})
Aadd(aFator,{Ctod("07/06/90"),44.36820});    Aadd(aFator,{Ctod("08/06/90"),44.46600})
Aadd(aFator,{Ctod("11/06/90"),44.56390});    Aadd(aFator,{Ctod("12/06/90"),44.70760})
Aadd(aFator,{Ctod("13/06/90"),44.85170});    Aadd(aFator,{Ctod("15/06/90"),44.99640})
Aadd(aFator,{Ctod("18/06/90"),45.18000});    Aadd(aFator,{Ctod("19/06/90"),45.36430})
Aadd(aFator,{Ctod("20/06/90"),45.54950});    Aadd(aFator,{Ctod("21/06/90"),45.78860})
Aadd(aFator,{Ctod("22/06/90"),46.02890});    Aadd(aFator,{Ctod("25/06/90"),46.27050})
Aadd(aFator,{Ctod("26/06/90"),46.51340});    Aadd(aFator,{Ctod("27/06/90"),46.86540})
Aadd(aFator,{Ctod("28/06/90"),47.30650});    Aadd(aFator,{Ctod("29/06/90"),47.75400})
Aadd(aFator,{Ctod("02/07/90"),48.20570});    Aadd(aFator,{Ctod("03/07/90"),48.40720})
Aadd(aFator,{Ctod("04/07/90"),48.60950});    Aadd(aFator,{Ctod("05/07/90"),48.81270})
Aadd(aFator,{Ctod("06/07/90"),49.01670});    Aadd(aFator,{Ctod("09/07/90"),49.22160})
Aadd(aFator,{Ctod("10/07/90"),49.42730});    Aadd(aFator,{Ctod("11/07/90"),49.63390})
Aadd(aFator,{Ctod("12/07/90"),49.84140});    Aadd(aFator,{Ctod("13/07/90"),50.04970})
Aadd(aFator,{Ctod("16/07/90"),50.25880});    Aadd(aFator,{Ctod("17/07/90"),50.46890})
Aadd(aFator,{Ctod("18/07/90"),50.67980});    Aadd(aFator,{Ctod("19/07/90"),50.95580})
Aadd(aFator,{Ctod("20/07/90"),51.23330});    Aadd(aFator,{Ctod("23/07/90"),51.51230})
Aadd(aFator,{Ctod("24/07/90"),51.79290});    Aadd(aFator,{Ctod("25/07/90"),52.07490})
Aadd(aFator,{Ctod("26/07/90"),52.35850});    Aadd(aFator,{Ctod("27/07/90"),52.66730})
Aadd(aFator,{Ctod("30/07/90"),52.97800});    Aadd(aFator,{Ctod("31/07/90"),53.19210})
Aadd(aFator,{Ctod("01/08/90"),53.40710});    Aadd(aFator,{Ctod("02/08/90"),53.59690})
Aadd(aFator,{Ctod("03/08/90"),53.78740});    Aadd(aFator,{Ctod("06/08/90"),53.97850})
Aadd(aFator,{Ctod("07/08/90"),54.17030});    Aadd(aFator,{Ctod("08/08/90"),54.36280})
Aadd(aFator,{Ctod("09/08/90"),54.55590});    Aadd(aFator,{Ctod("10/08/90"),54.74980})
Aadd(aFator,{Ctod("13/08/90"),54.94430});    Aadd(aFator,{Ctod("14/08/90"),55.13950})
Aadd(aFator,{Ctod("15/08/90"),55.33550});    Aadd(aFator,{Ctod("16/08/90"),55.53210})
Aadd(aFator,{Ctod("17/08/90"),55.72940});    Aadd(aFator,{Ctod("20/08/90"),55.92740})
Aadd(aFator,{Ctod("21/08/90"),56.12620});    Aadd(aFator,{Ctod("22/08/90"),56.32560})
Aadd(aFator,{Ctod("23/08/90"),56.52570});    Aadd(aFator,{Ctod("24/08/90"),56.76380})
Aadd(aFator,{Ctod("27/08/90"),57.00300});    Aadd(aFator,{Ctod("28/08/90"),57.29550})
Aadd(aFator,{Ctod("29/08/90"),57.58960});    Aadd(aFator,{Ctod("30/08/90"),57.88510})
Aadd(aFator,{Ctod("31/08/90"),58.39440});    Aadd(aFator,{Ctod("03/09/90"),59.05760})
Aadd(aFator,{Ctod("04/09/90"),59.37110});    Aadd(aFator,{Ctod("05/09/90"),59.68610})
Aadd(aFator,{Ctod("06/09/90"),60.00290});    Aadd(aFator,{Ctod("10/09/90"),60.32130})
Aadd(aFator,{Ctod("11/09/90"),60.64150});    Aadd(aFator,{Ctod("12/09/90"),60.96330})
Aadd(aFator,{Ctod("13/09/90"),61.28690});    Aadd(aFator,{Ctod("14/09/90"),61.61210})
Aadd(aFator,{Ctod("17/09/90"),61.93910});    Aadd(aFator,{Ctod("18/09/90"),62.26780})
Aadd(aFator,{Ctod("19/09/90"),62.59830});    Aadd(aFator,{Ctod("20/09/90"),62.93050})
Aadd(aFator,{Ctod("21/09/90"),63.29880});    Aadd(aFator,{Ctod("24/09/90"),63.66920})
Aadd(aFator,{Ctod("25/09/90"),64.04170});    Aadd(aFator,{Ctod("26/09/90"),64.48890})
Aadd(aFator,{Ctod("27/09/90"),64.93920});    Aadd(aFator,{Ctod("28/09/90"),65.68520})
Aadd(aFator,{Ctod("01/10/90"),66.64650});    Aadd(aFator,{Ctod("02/10/90"),67.00720})
Aadd(aFator,{Ctod("04/10/90"),67.36980});    Aadd(aFator,{Ctod("05/10/90"),67.73430})
Aadd(aFator,{Ctod("09/10/90"),68.10080});    Aadd(aFator,{Ctod("10/10/90"),68.46930})
Aadd(aFator,{Ctod("11/10/90"),68.83980});    Aadd(aFator,{Ctod("12/10/90"),69.21230})
Aadd(aFator,{Ctod("15/10/90"),69.58690});    Aadd(aFator,{Ctod("16/10/90"),69.96340})
Aadd(aFator,{Ctod("17/10/90"),70.34200});    Aadd(aFator,{Ctod("18/10/90"),70.72260})
Aadd(aFator,{Ctod("19/10/90"),71.10530});    Aadd(aFator,{Ctod("22/10/90"),71.49010})
Aadd(aFator,{Ctod("23/10/90"),71.87690});    Aadd(aFator,{Ctod("24/10/90"),72.26590})
Aadd(aFator,{Ctod("25/10/90"),72.76460});    Aadd(aFator,{Ctod("26/10/90"),73.26680})
Aadd(aFator,{Ctod("29/10/90"),73.85400});    Aadd(aFator,{Ctod("30/10/90"),74.44580})
Aadd(aFator,{Ctod("31/10/90"),75.11180});    Aadd(aFator,{Ctod("01/11/90"),75.78370})
Aadd(aFator,{Ctod("05/11/90"),76.24820});    Aadd(aFator,{Ctod("06/11/90"),76.71560})
Aadd(aFator,{Ctod("07/11/90"),77.18580});    Aadd(aFator,{Ctod("08/11/90"),77.65890})
Aadd(aFator,{Ctod("09/11/90"),78.17800});    Aadd(aFator,{Ctod("12/11/90"),78.70050})
Aadd(aFator,{Ctod("13/11/90"),79.22650});    Aadd(aFator,{Ctod("14/11/90"),79.78290})
Aadd(aFator,{Ctod("16/11/90"),80.34320});    Aadd(aFator,{Ctod("19/11/90"),80.90750})
Aadd(aFator,{Ctod("20/11/90"),81.47560});    Aadd(aFator,{Ctod("21/11/90"),82.04780})
Aadd(aFator,{Ctod("22/11/90"),82.66900});    Aadd(aFator,{Ctod("23/11/90"),83.29500})
Aadd(aFator,{Ctod("26/11/90"),83.98630});    Aadd(aFator,{Ctod("27/11/90"),84.68340})
Aadd(aFator,{Ctod("28/11/90"),85.38630});    Aadd(aFator,{Ctod("29/11/90"),86.21910})
Aadd(aFator,{Ctod("30/11/90"),87.29980});    Aadd(aFator,{Ctod("03/12/90"),88.39410})
Aadd(aFator,{Ctod("04/12/90"),89.01400});    Aadd(aFator,{Ctod("05/12/90"),89.63820})
Aadd(aFator,{Ctod("06/12/90"),90.26680});    Aadd(aFator,{Ctod("07/12/90"),90.89980})
Aadd(aFator,{Ctod("10/12/90"),91.53720});    Aadd(aFator,{Ctod("11/12/90"),92.17910})
Aadd(aFator,{Ctod("12/12/90"),92.82550});    Aadd(aFator,{Ctod("13/12/90"),93.47650})
Aadd(aFator,{Ctod("14/12/90"),94.13200});    Aadd(aFator,{Ctod("17/12/90"),94.79210})
Aadd(aFator,{Ctod("18/12/90"),95.45680});    Aadd(aFator,{Ctod("19/12/90"),96.17260})
Aadd(aFator,{Ctod("20/12/90"),96.89370});    Aadd(aFator,{Ctod("21/12/90"),97.62020})
Aadd(aFator,{Ctod("24/12/90"),98.42300});    Aadd(aFator,{Ctod("26/12/90"),99.23240})
Aadd(aFator,{Ctod("27/12/90"),100.3704});    Aadd(aFator,{Ctod("28/12/90"),101.5214})
Aadd(aFator,{Ctod("31/12/90"),103.5081});    Aadd(aFator,{Ctod("02/01/91"),105.5337})
Aadd(aFator,{Ctod("03/01/91"),106.2481});    Aadd(aFator,{Ctod("04/01/91"),106.9673})
Aadd(aFator,{Ctod("07/01/91"),107.6914});    Aadd(aFator,{Ctod("08/01/91"),108.4203})
Aadd(aFator,{Ctod("09/01/91"),109.1543});    Aadd(aFator,{Ctod("10/01/91"),109.8931})
Aadd(aFator,{Ctod("11/01/91"),110.6370});    Aadd(aFator,{Ctod("14/01/91"),111.3860})
Aadd(aFator,{Ctod("15/01/91"),112.1399});    Aadd(aFator,{Ctod("16/01/91"),112.8990})
Aadd(aFator,{Ctod("17/01/91"),113.6633});    Aadd(aFator,{Ctod("18/01/91"),114.4327})
Aadd(aFator,{Ctod("21/01/91"),115.2073});    Aadd(aFator,{Ctod("22/01/91"),115.9872})
Aadd(aFator,{Ctod("23/01/91"),116.7723});    Aadd(aFator,{Ctod("24/01/91"),117.7787})
Aadd(aFator,{Ctod("25/01/91"),118.7938});    Aadd(aFator,{Ctod("28/01/91"),119.8177})
Aadd(aFator,{Ctod("29/01/91"),120.8504});	 Aadd(aFator,{Ctod("30/01/91"),121.8919})
Aadd(aFator,{Ctod("31/01/91"),123.9844})

// Fev. a Dez/1991
AAdd(aFator, {Ctod("28/02/1991"),  152.4881});AAdd(aFator, {Ctod("31/03/1991"),  170.4666})
AAdd(aFator, {Ctod("30/04/1991"),  179.0070});AAdd(aFator, {Ctod("31/05/1991"),  190.9647})
AAdd(aFator, {Ctod("30/06/1991"),  211.6462});AAdd(aFator, {Ctod("31/07/1991"),  237.3400})
AAdd(aFator, {Ctod("31/08/1991"),  274.4125});AAdd(aFator, {Ctod("30/09/1991"),  317.2757})
AAdd(aFator, {Ctod("31/10/1991"),  384.1574});AAdd(aFator, {Ctod("30/11/1991"),  481.5797})
AAdd(aFator, {Ctod("31/12/1991"),  597.0600})
// Set. a Dez/1994
AAdd(aFator, {Ctod("30/09/1994"),    0.6207});AAdd(aFator, {Ctod("31/10/1994"),    0.6308})
AAdd(aFator, {Ctod("30/11/1994"),    0.6428});AAdd(aFator, {Ctod("31/12/1994"),    0.6618})
// 1o. ao 4o. trimestre de 1995
AAdd(aFator, {Ctod("31/03/1995"),    0.6767});AAdd(aFator, {Ctod("30/06/1995"),    0.7061})
AAdd(aFator, {Ctod("30/09/1995"),    0.7564});AAdd(aFator, {Ctod("31/12/1995"),    0.7952})
aStru := {	{"DTFINAL","D",08,0},;
{"Fator"	 ,"N",15,7},;
{"Indice" ,"N",12,3}}

If _oATFA0121 <> Nil
	_oATFA0121:Delete()
	_oATFA0121 := Nil
Endif

_oATFA0121 := FWTemporaryTable():New( "ATFCOE" )
_oATFA0121:SetFields(aStru)
_oATFA0121:AddIndex("1", {"DTFINAL"})

//------------------
//Criação da tabela temporaria
//------------------
_oATFA0121:Create()

For nX := 1 To Len(aFator)
	RecLock("ATFCOE",.T.)
	AtfCoe->DTFINAL := aFator[nX][1]
	AtfCoe->Fator	  := aFator[nX][2]

	If aFator[nX][1] <= Ctod("31/01/1989")
		nIndice := 6.92
	Else
		nIndice := 1
	EndIf

	AtfCoe->Indice	:= nIndice
Next

// Calcula o valor atualizado do bem
AtfCoe->(MsSeek(Dtos(dDatAquis),.T.))
If AtfCoe->(!Eof()) .AND. AtfCoe->DTFINAL >= dDatAquis
	oModel:SetValue('SN3DETAIL','N3_VORIG1',Round((Round((nValOrig / AtfCoe->Fator),4) * AtfCoe->Indice) * 0.8287,4))
Endif

//Deleta tabela temporaria criada no banco de dados
If _oATFA0121 <> Nil
	_oATFA0121:Delete()
	_oATFA0121 := Nil
Endif

oModel := Nil
Return Nil
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CDTER
Tratamento da chamada do cadastro de bens de terceiros.
@author William Matos Gundim Junior
@since  20/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CDTER()

Local aAutoCab			:= {}
Local aArea			:= GetArea()
Local lContinua		:= .T.
Local lFound			:= .F.
Local oModel 			:= FWModelActive()
Local cBase			:= oModel:GetValue('SN1MASTER','N1_CBASE')
Local cItem 			:= oModel:GetValue('SN1MASTER','N1_ITEM')
Local cFornec			:= oModel:GetValue('SN1MASTER','N1_FORNEC')
Local cLoja			:= oModel:GetValue('SN1MASTER','N1_LOJA')
Local nOper			:= oModel:GetOperation()
Local nOpcx			:= If(nOper == 2, 2, 3)
Local nOpcA			:= 0
Local aSaveLines		:= FWSaveRows()

// Valida a utilizacao do controle de terceiros para o bem
If oModel:GetValue('SN1MASTER','N1_TPCTRAT') != "2"
	lContinua := .F.
	Help(" ",1,"AF010CDTER",,STR0097+CRLF+STR0098,1,0)	 //"Controle de terceiros nao disponivel para este bem."###"Avaliar as configuracao do campo Tipo de Controle."
EndIf

If Empty(cBase) .OR. Empty(cItem)
	lContinua := .F.
	Help(" ",1,"AF012CDBAS") //"Campo de código base ou Item não preenchido, por favor verifique."
EndIf

If lContinua
	// Valida a existencia do controle de terceiros
	DbSelectArea("SNO")
	DbSetOrder(2)
	If DbSeek(xFilial('SN1') + cBase + cItem)
		While SNO->(!Eof()) .AND. 	SNO->NO_FILIAL 	== xFilial('SN1') .AND.;
										SNO->NO_CBASE  	== cBase 			.AND.;
										SNO->NO_ITEM	    == cItem

			If SNO->NO_STATUS == "1" // Controle Ativo
				lFound := .T.
				Exit
			EndIf
			SNO->(DbSkip())
		End
	EndIf

	If lFound .AND. nOper == 3

		/*nOpcA := Aviso(STR0095,	STR0096+CRLF+; //"Controle de bens de terceiros"###"Ja existe um controle de terceiros ativo para este bem."
												STR0097+CRLF+; //"Manutencoes devem ser realizadas pelo cadastro de controle de terceiros."
												STR0098,{STR0002,STR0099}) //"Opcoes disponiveis pelo cadastro do bem: Visualizar."###"Visualizar"###"Sair"
		*/
		If nOpcA == 1
			nOpcx := 2 // Visualizar
		Else
			lContinua := .F.
		EndIf

	ElseIf !lFound .AND. nOpcx == 2
		Help(" ",1,"AF010NOTER",,STR0099+CRLF+STR0100,1,0) //"Nao existe controle de terceiros para este bem."###"Efetuar manutencao pelo cadastro de controle de terceiros."
		lContinua := .F.
	EndIf

	If lContinua

		If nOpcx == 3
			aAdd(aAutoCab,{"NO_CBASE"  , cBase	 ,NIL})
			aAdd(aAutoCab,{"NO_ITEM"	  , cItem	 ,NIL})
			aAdd(aAutoCab,{"NO_FORNEC", cFornec	 ,NIL})
			aAdd(aAutoCab,{"NO_LOJA"	  , cLoja	 ,NIL})
		EndIf

		SaveInter()
		ATF320Cad("SNO",If(nOpcx==2,SNO->(RECNO()),0),nOpcx,aAutoCab,,.T.)
		RestInter()
	EndIf
EndIf

FWRestRows(aSaveLines)
RestArea(aArea)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CETER
Tratamento do cadastro de bens em terceiros.
@author William Matos Gundim Junior
@since  20/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CETER(nOpc)
Local aAutoCab			:= {}
Local aArea			:= GetArea()
Local lContinua		:= .T.
Local lFound			:= .F.
Local oModel 			:= FWModelActive()
Local cBase			:= oModel:GetValue('SN1MASTER','N1_CBASE')
Local cItem 			:= oModel:GetValue('SN1MASTER','N1_ITEM')
Local cFornec			:= oModel:GetValue('SN1MASTER','N1_FORNEC')
Local cLoja			:= oModel:GetValue('SN1MASTER','N1_LOJA')
Local nOper 			:= oModel:GetOperation()
Local nOpcx			:= If(nOper == 2, 2, 3)
Local nOpcA			:= 0
Local aSaveLines	:= FWSaveRows()

// Valida a utilizacao do controle de terceiros para o bem
If oModel:GetValue('SN1MASTER','N1_TPCTRAT') != "3"
	lContinua := .F.
	Help(" ",1,"AF010CETER",,STR0101+CRLF+STR0102,1,0) //"Controle em terceiros nao disponivel para este bem."##"Avaliar as configuracao do campo Tipo de Controle."
EndIf

If Empty(cBase) .OR. Empty(cItem)
	lContinua := .F.
	Help(" ",1,"AF010CEBAS")
EndIf

If lContinua
	// Valida a existencia do controle em terceiros
	DbSelectArea("SNP")
	DbSetOrder(2)
	If DbSeek(xFilial("SN1")+cBase+cItem)
		While SNP->(!Eof()) .AND. SNP->NP_FILIAL == xFilial("SN1") .AND.;
									 SNP->NP_CBASE  == cBase .AND.;
									 SNP->NP_ITEM	  == cItem

			If SNP->NP_STATUS == "1" // Controle Ativo
				lFound := .T.
				Exit
			EndIf
			SNP->(DbSkip())
		End
	EndIf

	If lFound .AND. nOpcx == 3

		nOpcA := Aviso(STR0103,	STR0104+CRLF+; //"Controle de bens em terceiros"##"Ja existe um controle de terceiros ativo para este bem."
		               STR0105+CRLF+; //"Manutencoes devem ser realizadas pelo cadastro de controle de terceiros."
		               STR0106,{STR0107,STR0108}) //"Opcoes disponiveis pelo cadastro do bem:"##"Visualizar" ##"Sair"

		If nOpcA == 1
			nOpcx := 2 // Visualizar
		Else
			lContinua := .F.
		EndIf

	ElseIf !lFound .AND. nOpcx == 2
		Help(" ",1,"AF010NOTER",,STR0109+CRLF+STR0110,1,0)//"Nao existe controle de terceiros para este bem." ##"Efetuar manutencao pelo cadastro de controle de terceiros."
		lContinua := .F.
	EndIf

	If lContinua

		If nOpcx == 3
			AADD(aAutoCab,{"NP_CBASE"	,cBase	    ,NIL})
			AADD(aAutoCab,{"NP_ITEM"		,cItem	    ,NIL})
			AADD(aAutoCab,{"NP_FORNEC"	,cFornec	,NIL})
			AADD(aAutoCab,{"NP_LOJA"		,cLoja  	,NIL})
		EndIf

		SaveInter()
		ATF321Cad("SNP",If(nOpcx==2,SNP->(RECNO()),0),nOpcx,aAutoCab,,.T.)
		RestInter()
	EndIf
EndIf

RestArea(aArea)
FWRestRows(aSaveLines)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ATX
Tratamento do cadastro de bens em terceiros.
@author William Matos Gundim Junior
@since  20/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ATX(lGrupo)
Local lZeraDepr := GetNewPar("MV_ZRADEPR",.F.)
Local nTaxa := 0, ny, aAreaSx3, uRet
Local alMoeda	:= {}
Local nX
Local lOk 		  := .T.
Local aEntidade := {}
Local lRet := .T.
Local nPosSNG := 0
Local nQuantas    := AtfMoedas() //Controle de multiplas moedas
Local cMoedaFisc := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1")) // Controle da moeda Fiscal/PTG  *
Local cNomeTFSN3 := Subs("N3_TXDEPRn",1,10 - Len(cMoedaFisc) ) + cMoedaFisc
Local cNomeTFSNG := Subs("NG_TXDEPRn",1,10 - Len(cMoedaFisc) ) + cMoedaFisc
Local nTxMoedaGF := 0
Local nTxMoedaC  := 0
Local cNestaCOL  := ""
Local nInc		   := 0
Local lCcdp	   := GetMv("MV_ATFCCDP",.F.,.F.) // Se .T. e utilizar grupo de bens o conteudo do campo N3_CCCUSTO sera replicado para o campo N3_CCDESP
Local lSCdp 	   := GetMv("MV_ATFSCDP",.F.,.F.) // Se .T. e utilizar grupo de bens o conteudo do campo N3_SUBCTA sera replicado para o campo N3_SUBCDEP
Local lCVDP 	   := GetMv("MV_ATFCVDP",.F.,.F.) // Se .T. e utilizar grupo de bens o conteudo do campo N3_CLVL sera replicado para o campo N3_CLVLDEP
Local oModel 	   := FWModelActive()
Local oAux 	   := oModel:GetModel('SN3DETAIL')
Local nOper	   := oModel:GetOperation()
Local oStruct    := oAux:GetStruct()
Local aAux       :=  oStruct:GetFields()
Local aPosTaxa	   := AtfMultPos(aAux, "N3_TXDEPR", 3)
Local nLinha 		:= oAux:GetLine()
Local cTaxa		:= ''
Default lGrupo   := .F.

// *******************************
// Controle de multiplas moedas  *
// *******************************
aAdd( alMoeda , nil )
For nX := 2 To nQuantas
	aAdd( alMoeda , Empty(GETMV("MV_MOEDA" + ALLTRIM(Str(nX)))) )
Next

If lGrupo .And. (Empty(oModel:GetValue('SN1MASTER','N1_GRUPO')) .OR. !(nOper == 3 .OR. __lClassifica ))
	lOk := .F.
Endif

If lOk
	If lGrupo
		SNG->(DbSeek(xFilial("SNG") + oModel:GetValue('SN1MASTER','N1_GRUPO')))
	EndIf
	// Cria array com os nomes dos campos do SNG (Cadastro de grupos)
	If Len(aEntidade) == 0
		SX3->(MsSeek("SNG"))
		SX3->(DbEval( { || Aadd(aEntidade, SX3->X3_CAMPO ) }, , { || SX3->X3_ARQUIVO == "SNG" } ) )
	EndIf

	For nY := 1 To Len(aAux)
		If lGrupo //.And. "AF012GRUPO" $ Upper(aHeader[ny][11])
			If aAreaSx3 = Nil
				aAreaSx3 := SX3->(GetArea())
				SX3->(DbSetOrder(2))
			EndIf
			SX3->(DbSeek(aAux[nY][3]))
			uRet := CriaVar(aAux[nY][3])
			If uRet <> Nil
			 	oAux:SetValue(aAux[nY,3], uRet) //aCols[n][ny] := uRet
			Endif
		ElseIf Trim(aAux[nY][3]) != "N3_FILIAL" .AND. aAux[nY][4] == "C" .AND.; // SOMENTE CAMPOS CARACTER
			(nPosSNG := aScan(aEntidade,{|cEntidade| ALLTRIM(SUBSTR(cEntidade,4,10)) == ALLTRIM(SUBSTR(aAux[nY][3],4,10))})) > 0

			If lGrupo .AND. !Empty(&("SNG->"+AllTrim(aEntidade[nPosSNG])))

				oAux:SetValue(aAux[nY,3],&("SNG->"+aEntidade[nPosSNG])) //aCols[n][ny] := &("SNG->"+aEntidade[nPosSNG])

			EndIf

		EndIf
	Next nY

	If !lGrupo
		cTaxa := aAux[aPosTaxa[1],3]
		oAux:SetValue(cTaxa, oAux:GetValue('N3_TXDEPR1'))  //aCols[n][aPosTaxa[1]] := &(ReadVar())
	Else
		oAux:SetValue(cTaxa, SNG->NG_TXDEPR1)                //aCols[n][aPosTaxa[1]] := SNG->NG_TXDEPR1
	Endif

	If lZeraDepr .AND. !lGrupo
		nTaxa := oAux:GetValue('N3_TXDEPR1')
	EndIf

	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	For nX := 2 to nQuantas
		If aPosTaxa[nX] <= 0
			Loop
		EndIf
		cTaxa := aAux[aPosTaxa[nX],3]
		If alMoeda[nX]	/// Se não tem a moeda informada no parâmetro (Moeda em branco)
			If nX > 9
				If SNG->(FieldGet(FieldPos("NG_TXDEP" + Alltrim(Str(nX)) ))) > 0
					oAux:SetValue(cTaxa, 0)   //aCols[n][aPosTaxa[nX]] := 0
				Endif
			Else
				If SNG->(FieldGet(FieldPos("NG_TXDEPR" + Alltrim(Str(nX)) ))) > 0
					oAux:SetValue(cTaxa, 0)   //aCols[n][aPosTaxa[nX]] := 0
				Endif
			Endif
		Elseif !lGrupo
			oAux:SetValue(cTaxa, oAux:GetValue('N3_TXDEPR1'))//aCols[n][aPosTaxa[nX]] :=&(ReadVar())
		Else
			If nX > 9
				If SNG->(FieldGet(FieldPos("NG_TXDEP" + Alltrim(Str(nX)) ))) > 0
					oAux:SetValue(cTaxa, SNG->(FieldGet(FieldPos("NG_TXDEP" + Alltrim(Str(nX))))))   //aCols[n][aPosTaxa[nX]]
				Endif
			Else
				If SNG->(FieldGet(FieldPos("NG_TXDEPR" + Alltrim(Str(nX)) ))) > 0
					oAux:SetValue(cTaxa, SNG->(FieldGet(FieldPos("NG_TXDEPR" + Alltrim(Str(nX)))))) //aCols[n][aPosTaxa[nX]]
				Endif
			EndIf
		EndIf
	Next

	If aAreaSx3 <> Nil
		SX3->(RestArea(aAreaSx3))
	Endif

	If lZeraDepr .and. !lGrupo .And. oAux:GetValue('N3_TIPO') $ "02|05"
		// Assume a ultima taxa para todos os itens
		For nInc := 1 To oAux:Length()
			oAux:GoLine(nInc)
			For nX := 1 To nQuantas
				cTaxa := aAux[aPosTaxa[nX],3]
				aEval( aPosTaxa, { |x| oAux:SetValue(cTaxa , nTaxa) } )
			Next nX
		Next nInc
	EndIf
	oAux:GoLine( nLinha )

	// ************************************
	//*  Regra na moeda Fiscal /PORTUGAL  *
	//*  eh usado como gatilho no valor   *
	//*  inicial na taxa da moeda Fiscal  *
	//   Adilson Soeiro em 18/02/2010     *
	// ************************************
	If cPaisLoc == "PTG" .AND. !Empty(cMoedaFisc)
		If oModel:GetValue('SN1MASTER','N1_ART32') == "S"
			AF012AAT32()
		Else
			cNestaCOL := ReadVar()
			If 'N3_TXDEPR1' $ cNestaCOL				// Moeda 1/Contabil
				nTxMoedaGF := &("SNG->"+cNomeTFSNG)	// Taxa do Grupo Fiscal
				nTxMoedaC  := &(ReadVar())			// Moeda 1/Contabil
				If nTxMoedaC > nTxMoedaGF
					oAux:SetValue(cNomeTFSN3, nTxMoedaGF)
				Else
					oAux:SetValue(cNomeTFSN3, oAux:GetValue('N3_TXDEPR1'))  //&(ReadVar())
				Endif
			Endif
		EndIf
	Endif

	If lGrupo
		If cPaisLoc == "BRA"
			oModel:SetValue('SN1MASTER','N1_DETPATR', SNG->NG_DETPATR)
			oModel:SetValue('SN1MASTER','N1_UTIPATR', SNG->NG_UTIPATR)
		EndIf

		If cPaisLoc == "PTG" .And. lGrupo
			oModel:SetValue('SN1MASTER','N1_PRZDEPR', SNG->NG_PRZDEPR)
		EndIf

		oAux:GoLine(1)
		If lCcdp
			oAux:SetValue('N3_CCDESP', SNG->NG_CCUSTO)  // aCols[1][nPos]
		Endif

		If lSCdp
			oAux:SetValue("N3_SUBCDEP", SNG->NG_SUBCTA) //"N3_SUBCDEP"
		EndIf

		If lCVDP
			oAux:SetValue('N3_CLVLDEP', SNG->NG_CLVL)
		Endif

		oAux:SetValue('N3_VMXDEPR', SNG->NG_VMXDEPR)
	Endif

EndIf

oAux:GoLine( nLinha )
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}AF12DEPRAC
Valida se houve depreciação após a inclusão
@author William Matos Gundim Junior
@since  27/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF12DEPRAC(cCodigoBem,cCdgItem,cTipo,cTipoSld,cOcorAquis)
Local lRetorno     := .T.
Local aSaveArea    := GetArea()
Local aAreaSn4     := SN4->(GetArea())
Local bWhile	     := {|| }
Local cIdAquisic   := ""
Default cTipo       := ""
Default cTipoSld   := ""
Default cOcorAquis := "05" // 05- Aquisicao ou 16 - Aquisicao por transf

dbSelectArea("SN4")
SN4->(dbSetOrder(4)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR+DTOS(N4_DATA)


If Empty(cTipo)
	SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem ))
	While !SN4->(Eof()) .AND. AllTrim(cCodigoBem + cCdgItem) == AllTrim(SN4->(N4_CBASE + N4_ITEM))
		If SN4->N4_OCORR == cOcorAquis
			cIdAquisic := AllTrim(SN4->N4_IDMOV)
			Exit
		EndIf
		SN4->(dbSkip())
	EndDo
Else
	SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem + cTipo + cOcorAquis ))
	If Empty(cTipoSld)
		cIdAquisic := AllTrim(SN4->N4_IDMOV)
	Else
		While !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem + cTipo + cOcorAquis) == AllTrim(SN4->(N4_CBASE + N4_ITEM + N4_TIPO + N4_OCORR ))
			If  Alltrim(SN4->N4_TPSALDO) == Alltrim(cTipoSld)
				cIdAquisic := AllTrim(SN4->N4_IDMOV)
			EndIf
			SN4->(dbSkip())
		EndDo
	EndIf
EndIf

If !Empty(cIdAquisic)
	If Empty(cTipo)
		bWhile := {|| !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem) == AllTrim(SN4->(N4_CBASE + N4_ITEM)) }
	Else
		bWhile := {|| !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem + cTipo ) == AllTrim(SN4->(N4_CBASE + N4_ITEM + N4_TIPO )) }
	EndIf
	SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR
	SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem + cTipo ,.T.))
	lRetorno := .F.
	While Eval(bWhile)
		If AllTrim(cIdAquisic) != AllTrim(SN4->N4_IDMOV) .and. (If (Empty(cTipoSld) , .T., Alltrim(SN4->N4_TPSALDO) == Alltrim(cTipoSld)))
			lRetorno := .T.
			Exit
		EndIf
		SN4->( DBSkip() )
	EndDo
EndIf


RestArea(aAreaSn4)
RestArea(aSaveArea)

Return(lRetorno)
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ExClas
Realiza a exclusao da ficha do ativo para a importacao de classificacao de ativo
@author William Matos
@since  11/10/2011
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ExClas(cCodBase,cItem,cTipo,cTpSld)
Local aArea				:= GetArea()
Local aAreaSN3				:= SN3->(GetArea())
Local aAreaSN1				:= SN1->(GetArea())
Local lRet					:= .T.
Local aAtfCab				:= {}
Local aAtfItens			:= {}
Local aStruSN1				:= CarregStru("SN1")
Local aStruSN3				:= CarregStru("SN3")
Local nZ					:= 0
Local nA					:= 0
Local aLog					:= {}
Local aParam				:= {}
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .T.

dbSelectArea("SN1")
dbSelectArea("SN3")

SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(11)) // N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_TPSALDO

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³Preparacao do array dos itens que ja EXISTAM.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If SN1->(dbSeek(xFilial("SN1")+cCodBase+cItem ))   //FILIAL+CBASE+ITEM

	If SN3->(MsSeek(xFilial("SN3") + cCodBase + cItem + cTipo +"0"+cTpSld ))

		/*/ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Preparacao do cabecalho SN1                            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
		For nZ := 1 To Len(aStruSN1)
			AADD(aAtfCab,{aStruSN1[nZ,2],SN1->(&(aStruSN1[nZ,2])),NIL})
		Next nZ

		SN3->(dbSeek(SN1->N1_FILIAL+SN1->N1_CBASE+SN1->N1_ITEM+ "01"))

		Do While SN3->(!Eof()) .And. SN1->(N1_FILIAL+N1_CBASE+N1_ITEM) == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM)
			/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Preparacao dos itens  SN3                                ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			AADD(aAtfItens,{})
			For nZ := 1 To Len(aStruSN3)
				If Alltrim(aStruSN3[nZ] [10]) <> "V" .And. X3Uso(aStruSN3[nZ] [7])
					AADD(aAtfItens[Len(aAtfItens)],{aStruSN3[nZ,2], SN3->(&(aStruSN3[nZ,2])) ,NIL})
				EndIf
			Next nZ
			SN3->(dbSkip())
		EndDo

		/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Localizar a ultima reavalicao para exclusao.             |
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		nPosTipo := Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_TIPO" })
		nPosTpSLD:= Ascan(aAtfItens[Len(aAtfItens)],{|aItens| Alltrim(aItens[1]) == "N3_TPSALDO" })

		For nA := 1 To Len(aAtfItens)
			If Alltrim(aAtfItens[nA,nPosTipo,2]) == cTipo .And. Alltrim(aAtfItens[nA,nPosTpSLD,2]) ==  cTpSld
				AADD(aAtfItens[nA] ,{"AUTDELETA","S",NIL})
				aAtfItens	:= {aAtfItens[nA]}
				Exit
			EndIf
		Next nA

		aAdd( aParam, {"MV_PAR01", 2} )
		aAdd( aParam, {"MV_PAR02", 1} )
		aAdd( aParam, {"MV_PAR03", 2} )
		 MSExecAuto({|a,b,c,d| Atfa012(a,b,c,d)},aAtfCab,aAtfItens,4,aParam)
		aAtfCab 	:= 	{}
		aAtfItens	:= 	{}
	EndIf
Else
	Help(" ",1,"RECNO")
Endif

If lMsErroAuto
	aLog := GETAUTOGRLOG()
	lMsErroAuto := .F.
	lRet := .F.
	aAdd(__aEtapa, {cCodBase,cItem,aLog} )
Endif

RestArea(aAreaSN1)
RestArea(aAreaSN3)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012Grv14
Realiza a gravação da linha 14 - AVP
@author William Matos
@since  11/10/2011
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Grv14(aCols14)
Local lRet       := .F.
Local nInc       := 1
Local nX         := 1
Local nY		  := 0
Local nPos       := 0
Local nLinha     := 0
Local nPosDado   := 0
Local nPosTpSal  := 0
Local nPosTipo   := 0
Local nPosSald   := 0
Local nPosVMax   := 0
Local nPosVSav   := 0
Local nVlrTp10   := 0
Local nVlrMax    := 0
Local nVlrSav    := 0
Local nProp      := 0
Local nMoedaAtf  := Val( Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1")) )
Local nMoedaVMax := Iif(Val(GetMv("MV_ATFMDMX",.F.," ")) > 0, Val(GetMv("MV_ATFMDMX")), nMoedaAtf )
Local oModel 	   := FWModelActive()
Local oAux		   := oModel:GetModel('SN3DETAIL')
Local oStruct     :=  oAux:GetStruct()
Local aAux        := oStruct:GetFields()
Local nQuantas   := AtfMoedas()
Local aPosVOrigX := AtfMultPos(aAux,"N3_VORIG", 3)
Local aPosVDep   := AtfMultPos(aAux,"N3_VRDACM",3)
Local cVDep	   := ''
Local cOrig	   := ''
Local aAux14	   := {}
DEFAULT aCols14 := {}    //Acols auxiliar da Acols em tempo de gravacao

//Para classificação patrimonial 'Orçamento de Provisão de despesas' que possua Tipo de AVP por parcela
//o cálculo do AVP será realizado posteriormente através da rotina de apuração de provisões.
If !( oModel:GetValue('SN1MASTER', 'N1_TPAVP') == '2' .AND. oModel:GetValue('SN1MASTER', 'N1_PATRIM') == 'O' )

	//Arrays utilizados nesta rotina
	//aCols = aCols da GetDados do SN3 da inclusao do imobilizado (PRIVATE)
	//aCols14 = array contendo copia do registro SN3 tipo 10 e depois atualizado com os dados do AVP (LOCAL POR REFERENCIA)
	//__aColsAvp = aCols da Getdados da tela de AVP (STATIC)

	//Valida os dados do AVP
	FA012VldAvp(oModel:GetValue('SN1MASTER','N1_DTAVP'),oModel:GetValue('SN1MASTER','N1_INDAVP'))

	nPosTpSal := aScan( __aHeadAvp, { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
	nPosTipo  := aScan( aAux 		, { |x| AllTrim( x[3] ) == "N3_TIPO"  } )
	nPosSald  := aScan( aAux 		, { |x| AllTrim( x[3] ) == "N3_TPSALDO"  } )
	nPosVlr01 := aScan( aAux 		, { |x| AllTrim( x[3] ) == "N3_VORIG1"  } )
	nPosVMax  := aScan( aAux 		, { |x| AllTrim( x[3] ) == "N3_VMXDEPR" } )
	nPosVSav  := aScan( aAux 		, { |x| AllTrim( x[3] ) == "N3_VLSALV1" } )

	For nInc := 1 To oAux:Length() //Len( aCols )
		//Busca os tipos 10 para gerar os tipos 14
		If oAux:GetValue('N3_TIPO', nInc) $ "10"

			//Verifico se tenho registro do tipo 14 para o Tipo 10 + Tipo Saldo
			nPos := aScan( __aColsAvp, { |x| AllTrim( x[nPosTpSal] ) == oAux:GetValue('N3_TPSALDO', nInc)}) //Alltrim(aCols[nInc][nPosSald]) } )

			//Caso exista registro do tipo 14 para o Tipo 10 + Tipo Saldo
			//Incluo um registro tipo 14 + Tipo Saldo no aCols14
			If nPos > 0

				For nY := 1 To Len(aAux)
					aAdd(aAux14, oAux:GetValue(aAux[nY,3], nInc))
				Next nY
				aAdd(aCols14, aAux14)

				//AADD(aCols14,aClone(aCols[nInc])) //Copio a linha do tipo 10
				nLinha  := Len(aCols14)

				//Se a linha nao esta deletada, vou gravar no array aCols14
				//Que posteriormente sera incluido no aCols do SN3 antes de gravar a tabela
				If !oAux:IsDeleted(nInc)

					For nX := 1 to Len(__aHeadAvp)
						cCpo		:=  AllTrim(__aHeadAvp[nX][2])
						nPosDado	:= aScan( aAux, { |x| AllTrim( x[3] ) == cCpo  } )
						aCols14[nLinha][nPosDado] := __aColsAvp[nPos,nX]
					Next

				Endif

				For nX := 1 To nQuantas

					//Acerto o valor maximo de depreciacao e valor de salvamento
					//Acho a proporcao entre o valor do Tipo 10 liquido e Bruto
					//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento

					nVlrTp10 := oAux:GetValue(aAux[aPosVOrigX[nX],3], nInc) - aCols14[nLinha][aPosVOrigX[nX]]
					nProp 	  := (nVlrTp10 / oAux:GetValue(aAux[aPosVOrigX[nX],3], nInc))

					//nVlrTp10 := aCols[nInc][aPosVOrigX[nX]] - aCols14[nLinha][aPosVOrigX[nX]]
					//nProp 	:= (nVlrTp10 / aCols[nInc][aPosVOrigX[nX]])

					oAux:GoLine( nInc )

					If nX == nMoedaVMax
						nVlrMax  :=  oAux:GetValue('N3_VMXDEPR', nInc) //aCols[nInc][nPosVMax]
						oAux:LoadValue('N3_VMXDEPR', nVlrMax * nProp)  	//aCols[nInc][nPosVMax]     := nVlrMax * nProp
						aCols14[nLinha][nPosVMax]   := nVlrMax - oAux:GetValue('N3_VMXDEPR', nInc) //aCols[nInc][nPosVMax]
					EndIf

					If nX == 1
						nVlrSav := oAux:GetValue('N3_VLSALV1', nInc)  //aCols[nInc][nPosVSav] N3_VLSALV1
						oAux:LoadValue('N3_VLSALV1', nVlrSav * nProp) // aCols[nInc][nPosVSav]
						aCols14[nLinha][nPosVSav] := nVlrSav - oAux:GetValue('N3_VLSALV1', nInc) //aCols[nInc][nPosVSav]
					EndIf

					//Calcula a Depreciação Acumulada
					cVDep := aAux[aPosVDep[nX], 3]
					cOrig := aAux[aPosVOrigX[nX],3]
					oAux:LoadValue(cVDep, oAux:GetValue(cVDep, nInc) * nProp)       //aCols[nInc][aPosVDep[nX]] := aCols[nInc][aPosVDep[nX]] * nProp
					aCols14[nLinha][aPosVDep[nX]]   -= oAux:GetValue(cVDep, nInc) //aCols[nInc][aPosVDep[nX]]

					//Atualizo os valores da linha do tipo 10 diminuindo o valor de AVP Constituicao
					oAux:LoadValue(cOrig, oAux:GetValue(cOrig, nInc) - aCols14[nLinha][aPosVOrigX[nX]])
				Next nX

			EndIf

			lRet := .T.

		Endif
	Next nInc
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012Grv15
Função que realiza a gravação da linha 15
@author William Matos
@since  11/10/2011
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Grv15(aCols15)
Local lRet       := .F.
Local nInc       := 1
Local nX         := 0
Local nY		  := 0
Local nPos       := 0
Local nLinha     := 0
Local nPosDado   := 0
Local nPosTpSal  := 0
Local nPosTipo   := 0
Local nPosSald   := 0
Local nPosVMax   := 0
Local nPosVSav   := 0
Local nVlrMax    := 0
Local nVlrSav    := 0
Local nProp      := 0
Local nMoedaAtf  := Val( Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1")) )
Local nMoedaVMax := Iif(Val(GetMv("MV_ATFMDMX",.F.," ")) > 0, Val(GetMv("MV_ATFMDMX")), nMoedaAtf )
Local nQuantas   := AtfMoedas()
Local cVOrig	   := ''
Local cVDep	   := ''
Local lMargem	   := AFMrgAtf() //Verifica implementacao da Margem Gerencial
Local nPos15	   := 0
Local oModel	   := FWModelActive()
Local oAux 	   := oModel:GetModel('SN3DETAIL')
Local oStruct    := oAux:GetStruct()
Local aAux       := oStruct:GetFields()
Local aPosVOrigX := AtfMultPos(aAux,"N3_VORIG", 3)
Local aPosVDep   := AtfMultPos(aAux,"N3_VRDACM",3)
Local aAux15	   := {}
Local aCols		:= oAux:aCols
Local aHeader		:= oAux:aHeader
Local aSaveLines	:= FWSaveRows()
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

DEFAULT aCols15 := {}    //Acols auxiliar da Acols em tempo de gravacao
If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//Arrays utilizados nesta rotina
//aCols15 = array contendo copia do registro SN3 tipo 10 e depois atualizado com os dados da Margem Gerencial (LOCAL POR REFERENCIA)
//__aColsMrg = aCols da Getdados da tela de Margem Gerencial (STATIC)
If lMargem .AND. !Empty(oModel:GetValue('SN1MASTER','N1_MARGEM')) .AND. !Empty(oModel:GetValue('SN1MASTER','N1_REVMRG'))

	nPosTpSal := aScan( __aHeadMrg, { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
	nPosTipo  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TIPO"     } )
	nPosSald  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_TPSALDO"  } )
	nPosVMax  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VMXDEPR"  } )
	nPosVSav  := aScan( aHeader , { |x| AllTrim( x[2] ) == "N3_VLSALV1"  } )

	For nInc := 1 To oAux:Length()

		oAux:GoLine(nInc)

		//Busca os tipos 10 para gerar os tipos 15
		If oAux:GetValue('N3_TIPO') $ ("10|13" + cTypes10) // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

			//Verifico se tenho registro do tipo 15 para o Tipo 10 + Tipo Saldo preexistente
			nPos15 := aScan( aCols , { |x| AllTrim( x[nPosTipo] ) + AllTrim( x[nPosSald] ) == "15" + Alltrim(oAux:GetValue('N3_TPSALDO'))})
			If nPos15 == 0

				//Verifico se tenho registro do tipo 15 para o Tipo 10 + Tipo Saldo
				nPos := aScan( __aColsMrg, { |x| AllTrim( x[nPosTpSal] ) == Alltrim(oAux:GetValue('N3_TPSALDO'))})
				If nPos > 0 //Caso exista registro do tipo 15 para o Tipo 10 + Tipo Saldo

					For nY := 1 To Len(aHeader)
						aAdd(aAux15, oAux:GetValue(aHeader[nY,2]))
					Next nY
					aAdd(aCols15, aAux15)

					nLinha  := Len(aCols15)

					//Se a linha nao esta deletada, vou gravar no array aCols15
					//Que posteriormente sera incluido no aCols do SN3 antes de gravar a tabela
					If !oAux:IsDeleted()

						For nX := 1 to Len(__aHeadMrg)
							cCpos 	:= AllTrim(__aHeadMrg[nX][2])
							nPosDado  := aScan( aHeader, { |x| AllTrim( x[2] ) == cCpos })
							If !Empty(__aColsMrg[nPos,nX]) .And. nPosDado > 0
								aCols15[nLinha][nPosDado] := __aColsMrg[nPos,nX]
							EndIf
						Next

					Endif

					For nX := 1 To nQuantas

						//Acerto o valor maximo de depreciacao e valor de salvamento
						//Acho a proporcao entre o valor do Tipo 10 liquido e Bruto
						//Esse proporcao sera aplicada ao valor maximo de depreciacao e de salvamento
						cVDep	:= aHeader[aPosVDep[nX],2]
						cVOrig := aHeader[aPosVOrigX[nX],2]
						nProp 	:= (aCols15[nLinha][aPosVOrigX[nX]] / oAux:GetValue(cVOrig))

						If nX == nMoedaVMax
							nVlrMax := oAux:GetValue('N3_VMXDEPR')
							aCols15[nLinha][nPosVMax] := nVlrMax * nProp
						EndIf

						If nX == 1
							nVlrSav := oAux:GetValue('N3_VLSALV1')
							aCols15[nLinha][nPosVSav] := nVlrSav * nProp
						EndIf

					Next nX
				Endif

				lRet := .T.
			Endif

			//Metrica - Qtd de acesso a gravacao de tipos 15
			If __lMetric
				ATF012Metrics("01" /*cEvent*/,/*nStart*/, "001" /*cSubEvent*/, Alltrim(ProcName()) /*cSubRoutine*/)
			Endif

		Endif
	Next
EndIf

FWRestRows(aSaveLines)
Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}ATFV012RAC
Função que verifica se o N4_IDMOV da depreciação é o mesmo que o da inclusão, ou se houve depreciação após a inclusão.
@author Rodrigo Gimenez
@since  11/10/2011
@version 12
@change Alexandra Menyashina (20/09/18)
@param		lUnPutInOp	LOGICAL	If FA is not put into operation it need to use ocorr = 05 (only for Russia)
/*/
//-------------------------------------------------------------------
Function ATFV012RAC(cCodigoBem,cCdgItem,cTipo,cTipoSld,cOcorAquis,lUnPutInOp)
Local lRetorno := .T.
Local aSaveArea:= GetArea()
Local aAreaSn4 := SN4->(GetArea())
Local lIdMovCpo := .T.
Local bWhile	:= {|| }
Local cIdAquisic:= ""
Local cFilSN4 := xFilial("SN4")
Local nX		:= 0
Local cOcorren	:= ""
Local nQtdMovTrf:= 0
Local aValorMoed:= {}
Local lCancTrf	:= IsInCallStack("AF060CaTra")

Default cTipo    := ""
Default cTipoSld := ""
Default lUnPutInOp := .F.
Default cOcorAquis := IIf(lIsRussia,Iif(!lUnPutInOp,"05","05/04"),"05") // 05- Aquisicao ou 16 - Aquisicao por transf

dbSelectArea("SN4")
SN4->(dbSetOrder(4)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR+DTOS(N4_DATA)

If lIdMovCpo
	If lIsRussia
		aOcorAquis := Separa(cOcorAquis,'/')
		If Empty(cTipo)
			SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem ))
			While !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem) == AllTrim(SN4->(N4_CBASE + N4_ITEM))
				If SN4->N4_OCORR $ cOcorAquis
					cIdAquisic := AllTrim(SN4->N4_IDMOV)
					Exit
				EndIf
				SN4->(dbSkip())
			EndDo
		Else
			For nX := 1 to len(aOcorAquis)
				SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem + cTipo + aOcorAquis[nX] ))
				If Empty(cTipoSld)
					cIdAquisic := AllTrim(SN4->N4_IDMOV)
				Else
					While !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem + cTipo + aOcorAquis[nX]) == AllTrim(SN4->(N4_CBASE + N4_ITEM + N4_TIPO + N4_OCORR ))
						If  Alltrim(SN4->N4_TPSALDO) == Alltrim(cTipoSld)
							cIdAquisic := AllTrim(SN4->N4_IDMOV)
						EndIf
						SN4->(dbSkip())
					EndDo
				EndIf
			Next nX
		EndIf
	Else
		If Empty(cTipo)
			SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem ))
			While !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem) == AllTrim(SN4->(N4_CBASE + N4_ITEM))
				If SN4->N4_OCORR $ cOcorAquis + "/04"
					cIdAquisic := AllTrim(SN4->N4_IDMOV)
					cOcorren :=  SN4->N4_OCORR
					Exit
				EndIf
				SN4->(dbSkip())
			EndDo
		Else
			SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem + cTipo + cOcorAquis ))
			If Empty(cTipoSld)
				cIdAquisic := AllTrim(SN4->N4_IDMOV)
			Else
				While !SN4->( EOF() ) .and.	AllTrim(cCodigoBem + cCdgItem + cTipo + cOcorAquis) == AllTrim(SN4->(N4_CBASE + N4_ITEM + N4_TIPO + N4_OCORR ))
					If  Alltrim(SN4->N4_TPSALDO) == Alltrim(cTipoSld)
						cIdAquisic := AllTrim(SN4->N4_IDMOV)
						cOcorren :=  SN4->N4_OCORR
					EndIf
					SN4->(dbSkip())
				EndDo
			EndIf
		EndIf
	EndIf

	If !Empty(cIdAquisic)
		If Empty(cTipo)
			bWhile := {|| !SN4->( EOF() ) .and.	AllTrim(cFilSN4 + cCodigoBem + cCdgItem) == AllTrim(SN4->(N4_FILIAL + N4_CBASE + N4_ITEM)) }
		Else
			bWhile := {|| !SN4->( EOF() ) .and.	AllTrim(cFilSN4 + cCodigoBem + cCdgItem + cTipo ) == AllTrim(SN4->(N4_FILIAL + N4_CBASE + N4_ITEM + N4_TIPO )) }
		EndIf

		SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR
		SN4->(MsSeek(xFilial("SN4") + cCodigoBem + cCdgItem + cTipo ,.T.))
		lRetorno := .F.
		While Eval(bWhile)
			If !lCancTrf .And. cOcorren == "04" .And. SN4->N4_OCORR == "04" .And. !(SN4->N4_TIPOCNT == "1")
				aValorMoed := AtfMultMoe(,,{|x| SN4->&("N4_VLROC" + Alltrim(Str(x)) ) })
				If aScan(aValorMoed, {|x| x > 0}) > 0
					nQtdMovTrf++
				EndIf
			EndIf
			If AllTrim(cIdAquisic) != AllTrim(SN4->N4_IDMOV) .and. (If (Empty(cTipoSld) , .T., Alltrim(SN4->N4_TPSALDO) == Alltrim(cTipoSld)))
				lRetorno := .T.
				Exit
			EndIf
			SN4->( DBSkip() )
		EndDo
		If !lRetorno .And. nQtdMovTrf > 0
			lRetorno := .T.
		EndIf
	EndIf
EndIf

If FwIsInCallStack("ATFA155")
	lRetorno := .F.
EndIf

RestArea(aAreaSn4)
RestArea(aSaveArea)
Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc}AtfX3AVP
Le a estrutura do arquivo SX3
@author Pequim
@since  11/10/2011
@version 12
/*/
//-------------------------------------------------------------------
Function AtfX3AVP( cAlias1, cCampos ,lAuto )
Local nOrdSx3	:= SX3->(IndexOrd())
Local cUsado	:= ""
Local aCampos	:= {}
Local nX			:= 0
Local nTamCpo	:= SX3->(Len(X3_CAMPO))
Default cAlias1 := ""
Default cCampos := ""
Default lAuto   := .F.

aCampos := STRTOKARR(cCampos,"/")

For nX := 1 to Len(aCampos)

	dbSelectArea("SX3")
	dbSetOrder(2)
	If SX3->(MsSeek( Padr(aCampos[nX],nTamCpo )))
		IF X3USO(SX3->X3_USADO) .and. cNivel >= SX3->X3_NIVEL

			cUsado := SX3->X3_USADO

			//Transformo em string o conteudo de SX3->X3_CBOX
			//Este tratamento eh feito pois a MsNewGetDados nao trata como combo
			// se SX3->X3_CBOX for igual a #Function()
			cCombo := SX3->X3_CBOX
			If Substr(cCombo,1,1) == "#"
				cCombo := &(Alltrim(Substr(cCombo,2)))
			Endif

			aAdd( __aHeadAvp ,{ AllTrim(X3Titulo()) ,SX3->X3_CAMPO ;
				,SX3->X3_PICTURE ,SX3->X3_TAMANHO ;
				,SX3->X3_DECIMAL ,SX3->X3_VALID ;
				,SX3->X3_USADO ,SX3->X3_TIPO ;
				,SX3->X3_F3 ,SX3->X3_CONTEXT ;
				,cCombo ,SX3->X3_RELACAO})
		EndIf
	EndIf
Next


If lAuto
	AADD( __aHeadAvp, { "N3AVPPLAN","N3AVPPLAN", "", TamSX3("N3_VORIG1")[1], TamSX3("N3_VORIG1")[2],, cUsado, "N", cAlias1, "V", ""} )
	AADD( __aHeadAvp, { "N3AVPREAL","N3AVPREAL", "", TamSX3("N3_VORIG1")[1], TamSX3("N3_VORIG1")[2],, cUsado, "N", cAlias1, "V", ""} )
EndIf

SX3->(dbSetOrder(nOrdSx3))


Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AGRV
Gravação e atualização dos dados
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AGRV(oModelPar)
Static lZeraDepr
Local nCntItem  := 1
Local aAnterior := {}
Local nCntDel   := 0
Local dAquisic
Local lGravaSn4 := .F.
Local cTipoImob :=""
Local cTipoCorr :=""
Local cSeq      := ""
Local cSeqReav  := "  "
Local nMaior    := 0
Local lDeleta   := .T.
Local ny
Local nX        := 1
Local lRet 		:= .T.
Local aRecAtf   := {}
Local lDigReav  := .F.
Local nRECSN3Exc:= -1 // Recno da linha do SN3 se estiver excluída , para excluir registros no MSdocument.
Local cTpSaldo	:= ""
Local cOcorr    := ""
Local aDadosComp:={}

Local cTipoReav := "02|03|05|10|11|14"
Local aValorMoed // Controle de multiplas moedas
Local aPosVOrig
Local aPosDeprAc
Local nOpcao	:= 1
Local nPosnAt	:= 0
//APONTAMENTO DE PRODUCAO
Local cPadAnt	:= ""
Local lPadAnt
Local aValDepr	:= {}
Local lAtClDepr := .F. // Verificação da classificação de Ativo se sofre depreciação
Local lMargem   := AFMrgAtf() //Verifica implementacao da Margem Gerencial
Local oModel 	:= Iif(lIsRussia .And. ValType(oModelPar) == "O", oModelPar, FWModelActive())
Local oSN1		:= oModel:GetModel('SN1MASTER')
Local oSN3		:= oModel:GetModel('SN3DETAIL')
Local nOper	    := oModel:GetOperation()
Local oStruct   :=  oSN3:GetStruct()
Local aAux      := oStruct:GetFields()
Local aHeaderSN3:= oSN3:aHeader
Local aCols14   := {}
Local aCols15	:= 	{}
Local nOldn     := oSN3:GetLine()
Local aCIAP     := {}
Local lFirstAvp := .T.
Local lFirstMrg := .T.
Local nInc      := 0
Local nTam      := 0
Local lMostra	:= .F.
Local cIdMov 	:= ""
Local aPadPCO 	:= {}
Local lProva    := .T.
Local lCprova 	:= .F.
Local cCodAnt	:= ""
Local aRecProc  := {}
Local cCodigo 	:= oSN1:GetValue('N1_CBASE') + oSN1:GetValue('N1_ITEM')
Local lMATA240	:= FwIsInCallStack("MATA241") .Or. FwIsInCallStack("MATA240")
Local lClaLote	:= IsInCallStack("AF240Lote") //Se a rotina foi chamada atraves da classificacao em lote
Local cTypes10	:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable model
Local cTypes12	:= IIF(lIsRussia,"|" + AtfNValMod({2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable model
Local nVlCur	:= 1
Local nRecSn1   := 0
Local lPadrao   := .F. // Se a janela deve respeitar as medidas padrões do Protheus (.T.) ou usar o máximo disponível (.F.)
Local nSeq		:= 0
Local nSeqAux	:= 0
Local cSeqSn3   := ""
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local cChvNfe := ""
Local lNGMNTAT := ( SuperGetMv("MV_NGMNTAT", .F., "") $ "1#3" )
Local cPadrao 	:= ""
Local aContbSN3 := {}
Local nPosSn3   := ""
Local cCodSN3   := ""
Local lBmContr 	:= IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , .T., .F.)
Local cBmcontr 	:= IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , oSN1:GetValue('N1_BMCONTR'),"")
Local cBmCnRot   := Alltrim(FunName())//Recupera o nome da rotina
Local cFunCit    := ""
// Local aCabecCiap :={} // validar uso quando descer atfa040 bem em contrução para a master
Local cCiapBmCon := ""
Local cAntCbase  := ""
Local cAntItem   := ""
Local cAntCiap   := ""
Local aBmContr   := {}



If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTipoReav	+= cTypes10
Endif

pergunte("AFA012",.F.)
AF012PerAut()

lMostra	:= MV_PAR01 == 1
lAglut		:= MV_PAR06 == 1

cMoedaAtf := Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))

oSN3 := oModel:GetModel("SN3DETAIL")

//verifica se e uma classificação realmente
__lClassifica	:= (IsInCallStack("ATFA240") .And. nOper == MODEL_OPERATION_UPDATE)

If __lClassifica
	cCodAnt := SN1->N1_CBASE
	cCodSN3 := cCodAnt + SN1->N1_ITEM
    If __lDelData //.Or. cCodSN3 <> cCodigo //.Or. !Empty(FWFldGet("N1_GRUPO"))
        SN3->(dbSetOrder(1))
        If SN3->(DbSeek(FWxFilial("SN3")+cCodSN3))
            While(FWxFilial("SN3")+cCodSN3 == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM))
                Reclock("SN3",.F.)
                SN3->(dbDelete())
                SN3->(MSUNLOCK())
                SN3->(DBSkip())
            End
        EndIf
    EndIf
EndIf
//------------------------------------------------------------------------------------------
// Tratamento para adequação do N3_SEQ
// Durante a inclusao, uma linha pode ser exclusa, e não deve ser considerada para o N3_SEQ
// Na alteracao de um dado, o N3_SEQ precisa ser mantido
//------------------------------------------------------------------------------------------
If nOper != MODEL_OPERATION_DELETE
	For nX := 1 To oSN3:Length()


		oSN3:GoLine(nX)

		If oSN3:IsDeleted(nX)
			Loop
		EndIf

		//--------------------------------------------------------------------------------------------------------------
		// Na inclusao incrementa o N3_SEQ, tratamento necessário pois ao deletar uma linha, a sequencia fica incorreta
		//--------------------------------------------------------------------------------------------------------------
		If nOper == MODEL_OPERATION_INSERT
			nSeq++

		//-------------------------------------------------------------------------------------------------------------
		// Na alteracao avalia se já era linha existente para não mudar o N3_SEQ, não perdendo a referencia com a SN4.
		// Caso seja linha nova, obtém a última sequencia para incrementar
		//-------------------------------------------------------------------------------------------------------------
		ElseIf nOper == MODEL_OPERATION_UPDATE
			DBSelectArea("SN3")
			SN3->(DBSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
			If !SN3->(MSSeek(XFilial("SN3")+oSN1:GetValue("N1_CBASE")+oSN1:GetValue("N1_ITEM")+oSN3:GetValue("N3_TIPO")+oSN3:GetValue("N3_BAIXA")+oSN3:GetValue("N3_SEQ")))

				nSeqAux := Val(Soma1(AllTrim(AtfxUltSeq(oSN1:GetValue("N1_CBASE"),oSN1:GetValue("N1_ITEM")))))

				//--------------------------------------------------------------------------------------
				// Tratamento necessario para classificacao de ativo com mudanca do código base ou item
				//--------------------------------------------------------------------------------------
				If Empty(nSeqAux) .Or. nSeq >= nSeqAux
					nSeq++
				Else
					nSeq := nSeqAux
				EndIf

			EndIf
		EndIf

		If !Empty(nSeq) .And. !RusCheckRevalFunctions()
			oSN3:LoadValue("N3_SEQ", STRZero(nSeq,3))
		EndIf

	Next nX

	//Restauro a posicao
	oSN3:GoLine(nOldn)

EndIf

For nX := 1 To oSN3:Length()

	cChvNfe := SN1->N1_FILIAL+SN1->N1_PRODUTO+SN1->N1_NFISCAL+SN1->N1_NSERIE+SN1->N1_FORNEC+SN1->N1_LOJA
	oSN3:GoLine(nX)

	If nOper != MODEL_OPERATION_DELETE
		oSN3:SetValue("N3_FILORIG",cFilAnt)
		oSN3:SetValue("N3_LOCAL", oSN1:GetValue("N1_LOCAL"))
	EndIf

	//Gera as linhas do tipo 14 a partir do tipo 10 na Inclusao
	If (nOper == MODEL_OPERATION_INSERT .Or. __lClassifica ) .AND. oSN3:GetValue('N3_TIPO') $ ("10" + cTypes10) .AND. lFirstAvp
		//A rotina de geracao dos registros Tipo 14 sera executada apenas uma vez
		If !__lMultiATF
			lFirstAvp := .F.
			AF012Grv14(aCols14)
			//
			If Len(aCols14) > 0

				For nTam := 1 To Len(aCols14)

					oSN3:AddLine()
					For nInc := 1 to Len(aCols14[nTam])
						If aScan( __aHeadAvp, { |x| AllTrim( x[2] ) == aAux[nInc,3]  } ) > 0
							oSN3:LoadValue(aAux[nInc,3], aCols14[nTam,nInc]) //aAdd(aCols, aCols14[nInc])
						Else //Exceto os dados editaveis os demais são copias exatadas do tipo 10
							oSN3:LoadValue(aAux[nInc,3], aCols14[nTam,nInc])
						EndIf
					Next nInc
					oSN3:LoadValue("N3_FILORIG",cFilAnt)
				Next nTam

			EndIf
		EndIf
	Endif

	//Gera as linhas do tipo 15 a partir do tipo 10 na Inclusao
	If lMargem .and. (nOper == 3 .or. nOper == 4) .AND. oSN3:GetValue('N3_TIPO') $ ("10|13" + cTypes10) .AND. lFirstMrg
		If !__lMultiATF
			lFirstMrg := .F.
			AF012Grv15(aCols15)

			If Len(aCols15) > 0

				For nTam := 1 To Len(aCols15)

					oSN3:AddLine()

					For nY := 1 to Len(aHeaderSN3)
						oSN3:LoadValue(aHeaderSN3[nY,2], aCols15[nTam,nY])
					Next nY
					oSN3:LoadValue("N3_FILORIG",cFilAnt)
				Next nTam
			EndIf
		EndIf
	EndIf

Next nX

//Restauro a posicao
oSN3:GoLine(nOldn)

// Obter os numeros dos registros originais antes de comitar o modelo
dbSelectArea("SN3")
SN3->(dbSetOrder(1))

For nX := 1 To oSN3:Length()
	aadd(aRecProc, oSN3:GetDataId(nX))
next nX

//Busca de registros anteriores para verficar a alteração
dbSelectArea('SN3')
dbSetOrder(1)

If dbSeek(xFilial('SN3')+cCodigo)
	While SN3->(!Eof()) .And. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM == xFilial('SN3') + cCodigo
		aAdd(aAnterior,Recno())
		SN3->(dbSkip())
	End
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Cadastro do CIAP                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( nOper == 4 ) .AND. !__lClassifica
	dbSelectArea("SF9")
	dbSetOrder(1)
	If (Empty(oSN1:GetValue('N1_CODCIAP')) .AND. !Empty(oSN1:GetValue('N1_CODCIAP')) )
		If ( dbSeek(xFilial("SF9") + oSN1:GetValue('N1_CODCIAP')) )
			RecLock("SF9")
			SF9->F9_ICMIMOB -= oSN1:GetValue('N1_ICMSAPR')
			MsUnLock()
			oSN1:LoadValue('N1_CODCIAP', "")
			oSN1:LoadValue('N1_ICMSAPR', 0)

		EndIf
	ElseIf (!Empty(oSN1:GetValue('N1_CODCIAP')) .And. Empty(SN1->N1_CODCIAP) )
		dbSelectArea("SF9")
		dbSetOrder(1)
		If ( dbSeek(xFilial("SF9")+oSN1:GetValue('N1_CODCIAP')))
			If ( SF9->F9_ICMIMOB+ oSN1:GetValue('N1_ICMSAPR') <= SF9->F9_VALICMS )
				RecLock("SF9")
				SF9->F9_ICMIMOB += oSN1:GetValue('N1_ICMSAPR')
				MsUnLock()
			Else
				oSN1:LoadValue('N1_CODCIAP', "")
				oSN1:LoadValue('N1_ICMSAPR', 0)
			EndIf
		EndIf
	ElseIf nOper != 5
		oSN1:LoadValue('N1_ICMSAPR', SN1->N1_ICMSAPR)
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava arquivo SN1 (Ativos Imobilizados)             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If __lClassifica
	oSN1:LoadValue('N1_DTCLASS', dDataBase) // Data de classificacao do Bem.
Endif
If __lClassifica .and. nOper <> 5
	oSN1:LoadValue('N1_STATUS', "1")       // Colocação do bem em Uso.
Else
	If nOper <> 5 .And. (IsInCallStack("MATA103") .Or. lMATA240 .Or. IsInCallStack("MATA101"))
		oSN1:LoadValue('N1_STATUS', "0")       // Colocação do bem em Uso.
	Endif
Endif

If lBmContr .And. cBmcontr == '1' .And. nOper <> 5
	If (!Empty(AllTrim(oSN1:GetValue('N1_UTIPATR'))))
		dbSelectArea("SN0")
		dbSetOrder(1)
		SN0->(DbSeek(FWxFilial("SN0")+"12"+AllTrim(oSN1:GetValue('N1_UTIPATR'))))
		cFunCit:=alltrim(SN0->N0_DESC01)
	Else
		cFuncit:= ""
	EndIf

	If nOper != 4
		oSN1:LoadValue('N1_STATUS', "0")//Atualizo o Status do bem para 0
		oSN1:LoadValue('N1_CODCIAP', GetSx8Num('SF9','F9_CODIGO'))
		ConfirmSX8()
	EndIf

	aAdd(aBmContr,AllTrim(oSN1:GetValue('N1_CODCIAP')))
	aAdd(aBmContr,AllTrim(oSN1:GetValue('N1_DESCRIC')))
	aAdd(aBmContr,AllTrim(oSN1:GetValue('N1_FORNEC')))
	aAdd(aBmContr,AllTrim(oSN1:GetValue('N1_LOJA')))
	aAdd(aBmContr,AllTrim(oSN1:GetValue('N1_NFISCAL')))
	aAdd(aBmContr,AllTrim(oSN1:GetValue('N1_NSERIE')))
	aAdd(aBmContr,cBmCnRot)
	aAdd(aBmContr,cFuncit)

	CIAPBMCONT(aBmContr)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Bloqueia ou desbloqueia o bem de acordo com o local informado.      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOper <> 5 .and. !Empty(oSN1:GetValue('N1_LOCAL')) .And. oSN1:GetValue('N1_STATUS') != "0"
	dbSelectArea("SNL")
	SNL->(dbSetOrder(1))
	If SNL->(dbSeek( xFilial("SNL") + oSN1:GetValue('N1_LOCAL')))
		If SNL->NL_BLOQ == "1"
			oSN1:LoadValue('N1_STATUS', "3")
		ElseIf SNL->NL_BLOQ == "2"
			oSN1:LoadValue('N1_STATUS', "1")
		EndIf
	EndIf
EndIf

If !Empty(oSN1:GetValue('N1_GRUPO'))
	AtfGrv12Cfg(oSN1:GetValue('N1_GRUPO'), oSN1:GetValue('N1_CBASE'))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Cadastro do CIAP                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ( !Empty(oSN1:GetValue('N1_CODCIAP')) .And. nOper == 3 .And. !__lClassifica ) .And. cBmcontr <>'1'
	dbSelectArea("SF9")
	dbSetOrder(1)
	If ( dbSeek(xFilial("SF9")+oSN1:GetValue('N1_CODCIAP')) )
		If ( SF9->F9_ICMIMOB+oSN1:GetValue('N1_ICMSAPR') <= SF9->F9_VALICMS )
			RecLock("SF9")
			SF9->F9_ICMIMOB += oSN1:GetValue('N1_ICMSAPR')
			MsUnLock()
		Else
			oSN1:SetValue('N1_CODCIAP', "")
			oSN1:SetValue('N1_ICMSAPR', 0.00)
		Endif
	EndIf
EndIf
If lBmContr
	If __lClassifica .And. (!Empty(N1_SLBMCON) .And. !Empty(N1_CDCONTR)) // é uma classificação onde se faz um relacionamento com um bem em construção

		//Guardo os Códigos cbase+item e ciap do bem posicionado para reposicionar após a atualização da SF9
		cAntCbase := oSN1:GetValue('N1_CBASE')
		cAntItem  := oSN1:GetValue('N1_ITEM')
		cAntCiap  := oSN1:GetValue('N1_CODCIAP')

		//Posiciona no bem em construção com o n1_slbmcon e n1_cdcontr da amarração que está sendo realizada na classificação
		//para recuperar o código ciap
		dbSelectArea("SN1")
		SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM
		If (dbSeek(xFilial("SN1")+oSN1:GetValue('N1_SLBMCON')+oSN1:GetValue('N1_CDCONTR')))
			cCiapBmCon:= SN1->N1_CODCIAP//recupero o código ciap do bem em construção
		EndIf
		//Reposiciono no bem que está sendo classificado
		dbSeek(xFilial("SN1")+cAntCbase+cAntItem)

		//Posiciono no registro do componente para atualizar o f9_codbaix com o código ciap do bem em construção
		dbSelectArea("SF9")
		dbSetOrder(1)
		If ( dbSeek(xFilial("SF9")+cAntCiap) )
			RecLock("SF9",.F.)
			SF9->F9_CODBAIX := cCiapBmCon
			MsUnLock()
		EndIf
	EndIf
EndIf
//Grava no Model
If nOper != 5
	FWFormCommit( oModel )
EndIf

// Obter os numeros dos registros depois de comitar o modelo
dbSelectArea("SN3")
SN3->(dbSetOrder(12)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ

For nX := 1 To oSN3:Length()
	If aRecProc[nX] == 0
		If SN3->(dbSeek(xFilial('SN3') + oSN1:GetValue('N1_CBASE') + oSN1:GetValue('N1_ITEM') + oSN3:GetValue('N3_TIPO', nX) + oSN3:GetValue('N3_SEQ', nX)))
			While SN3->(!Eof()) .and. SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ) = xFilial('SN3') + oSN1:GetValue('N1_CBASE') + oSN1:GetValue('N1_ITEM') + oSN3:GetValue('N3_TIPO', nX) + oSN3:GetValue('N3_SEQ', nX)
				If SN3->N3_TPSALDO = oSN3:GetValue('N3_TPSALDO', nX)
					aRecProc[nX] := SN3->(Recno())
					Exit
				EndIf
				SN3->(dbSkip())
			EndDo
		EndIf
	EndIf
Next nX

SN3->(dbSetOrder(1))

If FindFunction( 'MNTXATF2' ) .And. SuperGetMv( "MV_NGMNTAT", .F., "N" ) $ '1/3'

	// Atualiza campos da integração SIGAATF x SIGAMNT na tabela de Bens - ST9.
	MNTXATF2( SN1->N1_CBASE + SN1->N1_ITEM, SN1->N1_CODBEM )

EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o n£mero de itens de Ativo Imobilizado                           ³
//³ Dever  conter 1 item (SN1) e no m¡nimo mais 1 item (SN3)                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

If oSN3:Length() > 0
	If nOper == 4 .AND. lRet
		dbSelectArea("SN1")
		dbSetOrder(1)  //setar indice 1 para dbSeek pois pode ser que usuario utilize outra chave para pesquisa na mbrowse

		If !lClaLote
			dbSeek(xFilial("SN1")+cCodigo)
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso seja altera‡„o, guarda valores anteriores               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea ( "SN3" )
		dAquisic := oSN1:GetValue('N1_AQUISIC')
	End
EndIf

If lRet
	/*
	* Geração de Lançamentos Contábeis conforme o Tipo de Ativo
	*/
	If nOper != MODEL_OPERATION_DELETE .AND. !__lAmplia
		cPadrao := AF012AQPAD(oSN3:GetValue('N3_TIPO') , .F. )
	Endif
	//grava em array os recnos utilizados para integracao com PCO
	Pco_aRecno(aRecAtf, "SN1", 2)  //inclusao

	If !Empty(__aRateio)
		AF012ADELR(__aRateio,oSN3:Length(), oSN3)
	EndIf

	//Inicio da Prote‡„o Via TTS
	Begin Transaction

		If nOper != 5
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava Rateio			                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nOper == 3
				nOpcao := 3
			Else
				nOpcao := 4
			EndIf

			AF011GRV(nOpcao, __aRateio)

			For nX := 1 To oSN3:Length()
				If IsInCallStack("ATFA155") .and. nX != oSN3:Length() .and. oSN3:GetValue('N3_TIPO', nX) != "01"
					Loop
				EndIf

				//---------------------------------
				// Trata linha exclusa na inclusão
				//---------------------------------
				If aRecProc[nX] == 0
					Loop
				EndIf

				SN3->(dbGoto(aRecProc[nX]))

				lDeleta := !(A012ATFNovo(aAnterior,SN3->(Recno())))

				RecLock('SN3',.F.)

				If oSN3:IsDeleted(nX) .AND. lDeleta
					If lIsRussia .Or. (cPaisLoc == "BRA")
						oSN3:GoLine(nX)
					EndIF
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Excluo o valor da correcao do bem do SN4.           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SN4")
					dbSetOrder(1)
					If dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+DtoS(If(oSN3:GetValue('N3_TIPO', nX) $ "02|05", SN3->N3_DINDEPR,SN3->N3_AQUISIC))+"07"+SN3->N3_SEQ)
						RecLock("SN4",.F.)
						SN4->(dbDelete())
						SN4->(FkCommit())
						SN4->(msUnlock())

						//grava em array os recnos utilizados para integracao com PCO
						Pco_aRecno(aRecAtf, "SN4", 3)  //exclusao

					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Excluo o valor do bem da conta do SN4.              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If dbSeek(xFilial("SN4")+oSN3:GetValue('N3_CBASE')+oSN3:GetValue('N3_ITEM')+oSN3:GetValue('N3_TIPO'))
						If AllTrim(SN4->N4_ORIGEM) == 'ATFA380'

							// Exclui todos os movimentos com o mesmo IDMOV
							If !Empty(SN4->(IndexKey(9)))
								AF12aExcId(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_SEQREAV,SN3->N3_SEQ,SN4->N4_IDMOV,@aRecAtf)
							Else
								RecLock("SN4",.F.)
								SN4->(dbDelete())
								SN4->(FkCommit())
								SN4->(msUnlock())

								//grava em array os recnos utilizados para integracao com PCO
								Pco_aRecno(aRecAtf, "SN4", 3)  //exclusao
							EndIf

						ElseIf dbSeek(xFilial("SN4")+oSN3:GetValue('N3_CBASE')+oSN3:GetValue('N3_ITEM')+oSN3:GetValue('N3_TIPO') + DtoS(If(oSN3:GetValue('N3_TIPO', nX) $ "02|05", SN3->N3_DINDEPR,SN3->N3_AQUISIC))+IiF(ALLTRIM(SN3->N3_TIPO) == "11","09","05")+SN3->N3_SEQ)
							// Exclui todos os movimentos com o mesmo IDMOV
							If !Empty(SN4->(IndexKey(9)))
								AF12aExcId(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_SEQREAV,SN3->N3_SEQ,SN4->N4_IDMOV,@aRecAtf)
							Else
								RecLock("SN4",.F.)
								SN4->(dbDelete())
								SN4->(FkCommit())
								SN4->(msUnlock())

								//grava em array os recnos utilizados para integracao com PCO
								Pco_aRecno(aRecAtf, "SN4", 3)  //exclusao
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Excluo o bem do SN5 se o bem excluido do SN3.       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SN5")
					dbSetOrder(1)
					If dbSeek(xFilial("SN5")+SN3->N3_CCONTAB+DtoS(If(oSN3:GetValue('N3_TIPO', nX) $ "02|05",;
							SN3->N3_DINDEPR,SN3->N3_AQUISIC))+If(oSN3:GetValue('N3_TIPO', nX) $ "02|05", "3", "1")) .And.;
							!oSN3:GetValue('N3_TIPO', nX) $ "07,08, 09" // Nao atualiza o saldo da conta para os tipos 07, 08 e 09
						// *******************************
						// Controle de multiplas moedas  *
						// *******************************
						aValorMoed := AtfMultMoe("SN3","N3_VORIG")
						ATFSaldo(SN3->N3_CCONTAB,If(oSN3:GetValue('N3_TIPO', nX) $ "02|05", SN3->N3_DINDEPR,SN3->N3_AQUISIC),;
							If(oSN3:GetValue('N3_TIPO', nX) $ "02|05", "3", "1"), SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3,;
							SN3->N3_VORIG4,SN3->N3_VORIG5 ,"-",,SN3->N3_SUBCCON,,;
							SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed, oSN3:GetValue('N3_TPSALDO', nX))
					Endif
					If	(dbSeek(xFilial("SN5")+SN3->N3_CCONTAB + DtoS(If(oSN3:GetValue('N3_TIPO', nX) $ "02|05",;
							SN3->N3_DINDEPR,SN3->N3_AQUISIC))+"6") .OR. dbSeek(xFilial("SN5")+SN3->N3_CCONTAB +;
							DtoS(If(oSN3:GetValue('N3_TIPO', nX) $ "02/05", SN3->N3_DINDEPR,SN3->N3_AQUISIC))+ "O")) .AND.;
							!oSN3:GetValue('N3_TIPO', nX) $ "07,08, 09" // Nao atualiza o saldo da conta para os tipos 07, 08 e 09
						// *******************************
						// Controle de multiplas moedas  *
						// *******************************
						aValorMoed := AtfMultMoe(,,{|x| If(x == 1,SN3->N3_VRCACM1,0)})
						ATFSaldo(SN3->N3_CCONTAB,If(oSN3:GetValue('N3_TIPO', nX) $ "02/05",;
							SN3->N3_DINDEPR,SN3->N3_AQUISIC),"",SN3->N3_VRCACM1,0,0,0,0,;
							"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed,;
							oSN3:GetValue('N3_TPSALDO'))

					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exclui apontamento de estimativa inicial de produção	³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("FNA")
					dbSetOrder(2)		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
					dbGoTop()
					If FNA->(MsSeek(xFilial("FNA")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)))
						While FNA->(!EoF()) .And.;
								FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)
							RecLock("FNA",.F.)

							//Salva o LP anterior
							cPadAnt := cPadrao
							lPadAnt := lPadrao

							Do Case
							Case FNA->FNA_OCORR == "P0"
								cPadrao := "875"		//Estorno de apontamento de estimativa de produção
							Case FNA->FNA_OCORR == "P1"
								cPadrao := "876"		//Estorno de apontamento de revisão de estimativa de produção
							Case FNA->FNA_OCORR == "P2"
								cPadrao := "877"		//Estorno de apontamento de produção
							Case FNA->FNA_OCORR == "P3"
								cPadrao := "878"		//Estorno de apontamento de encerramento de produção
							Case FNA->FNA_OCORR == "P4"
								cPadrao := "879"		//Estorno de apontamento de complemento de produção
							EndCase

							lPadrao := VerPadrao(cPadrao)

							If __nHdlPrv <= 0
								__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
							EndIf

							If lPadrao .And. __nHdlPrv > 0
								__nTotal += DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf)
							EndIf

							//Restaura o LP anterior
							cPadrao := cPadAnt
							lPadrao := lPadAnt

							dbDelete()
							MsUnlock()
							FNA->(dbSkip())
						EndDo
					EndIf
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Exclui a linha do SN3 se esta for deletada.               ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If oSN3:IsDeleted(nX) .And. lDeleta
					RecLock('SN3',.F.,.T.)

					// Contabilizacao da Exclusao >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Gera‡„o de lan‡amentos cont beis conforme o tipo do ativo           ³
					//³ 01 - Aquisi‡„o        03 - Adiantamento                             ³
					//³ 02 - Reavalia‡„o      04 - Lei 8200                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cPadrao:=	AF012AQPAD(SN3->N3_TIPO , .T. )

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Verifica se existe lan‡amento padr„o.                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					lPadrao:= !lZeraDepr .And. VerPadrao(cPadrao)

					If lPadrao .And. __lContabiliza .And. !__lClassifica
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Monta lan‡amento cont bil. No Cria Automatico, cria o     ³
						//³ HeadProva e o RodaProva uma unica vez.                    ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !lCprova .And. __nHdlPrv <= 0
							If lProva   // Em Criar Automatico, e' .T., so na 1a vez
								// Na Inclusao simples e sempre .T.
								__nHdlPrv:=HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
							EndIf
						EndIf
						lCprova := .T.
						If __nHdlPrv > 0
							__nTotal += DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf)
						EndIf
					EndIf
					// Contabilizacao da Exclusao <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

					('SN3')->(dbDelete())
					('SN3')->(FkCommit())
					nRECSN3Exc := SN3->(RECNO()) // Recno da linha do SN3 se estiver excluída , para excluir registros no MSdocument.
					nCntDel++

					//grava em array os recnos utilizados para integracao com PCO
					Pco_aRecno(aRecAtf, "SN3", 3)  //exclusao

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Exclui a amarracao com os conhecimentos SN3 - LAUDO          ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					MsDocument( "SN3", nRECSN3Exc, 2, , 3 )

				ElseIf !oSN3:IsDeleted(nX) .OR. __lCopia
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza dados do SN3 (saldos/valores ) se linha Nao delet³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lZeraDepr == Nil
						lZeraDepr := GetNewPar("MV_ZRADEPR",.F.)
					Endif

					dDtLancto	:= If(oSN3:GetValue('N3_TIPO', nX) $ "02|05", SN3->N3_DINDEPR,SN3->N3_AQUISIC)
					lDigReav   := If(!("MATA" $ Alltrim(FunName())) .And. oSN3:GetValue('N3_TIPO') $ "02|05",.T.,.F.)	/// SE O ULTIMO REGISTRO DIGITADO FOR DE REAVALIACAO
					If lDigReav 	/// Se estiver digitando uma reavaliacao
						dDtLancto	:= oSN3:GetValue('N3_DINDEPR', nX) /// OBTEM A DATA DA REAVALIACAO DIGITADA
					EndIf

					For nY := 1 to Len(aAux)

						If !aAux[nY][14] //Campo Virtual
							cATFVar := Trim(aAux[nY][3])
							// Se houve alteracao do valor original ou da depreciacao acumulada
							// (Reavaliacao)
							If (cAtfVar == "N3_VORIG1" .OR. cAtfVar == "N3_VRDACM1") .AND. oSN3:GetValue('N3_TIPO', nX) $ ("01,02,05,10" + cTypes10) .AND. lZeraDepr
								If Str(&("SN3->"+cATFVar),19,2) != Str(oSN3:GetValue(aAux[nY,3], nX),19,2)
									//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
									//³ Gera‡„o de lan‡amentos cont beis conforme o tipo do ativo           ³
									//³ 01 - Aquisicao 																		³
									//³ 02 - Reavalia‡„o      																³
									//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
									cPadrao :=	If(oSN3:GetValue('N3_TIPO', nX) $ ("01|10" + cTypes10), "801",;
										If(oSN3:GetValue('N3_TIPO', nX) $ "02|05","802",""))


									// *******************************
									// Controle de multiplas moedas  *
									// *******************************
									aPosVOrig	:= AtfMultPos(aAux,"N3_VORIG", 3)
									aPosDeprAc	:= AtfMultPos(aAux,"N3_VRDACM",3)

									// Na alteracao, quando incluida uma nova linha no SN3, contabiliza apenas
									// o valor original

									If nOper == 4 .AND. A012ATFNovo(aAnterior,SN3->(Recno()))
										VALOR  := oSN3:GetValue(aAux[aPosVOrig[1],3], nX)	// Contabiliza valor original
										VALOR2 := 0					 			// Contabiliza Valor da depreciacao acumulada
									Else
										VALOR  := 0
										VALOR2 := SN3->N3_VRDACM1	// Contabiliza Valor da depreciacao acumulada
									Endif
									// Atualiza saldo da conta do bem
									If cAtfVar $ "N3_VORIG" .And. nX != n
										// Atualiza saldo da conta do bem
										// *******************************
										// Controle de multiplas moedas  *
										// *******************************
										aValorMoed := AtfMultMoe(,,{|x| SN3->&("N3_VORIG" + Alltrim(Str(x)) ) - oSN3:GetValue(aAux[aPosVOrig[x], 3], nX)})
										ATFSaldo(	SN3->N3_CCONTAB,dDtLancto,If(oSN3:GetValue('N3_TIPO', nX) $ "02,05", "3", "1"),;
											SN3->N3_VORIG1 - oSN3:GetValue(aAux[aPosVOrig[1], 3], nX),;
											SN3->N3_VORIG2 - oSN3:GetValue(aAux[aPosVOrig[2], 3], nX),;
											SN3->N3_VORIG3 - oSN3:GetValue(aAux[aPosVOrig[3], 3], nX),;
											SN3->N3_VORIG4 - oSN3:GetValue(aAux[aPosVOrig[4], 3], nX),;
											SN3->N3_VORIG5 - oSN3:GetValue(aAux[aPosVOrig[5], 3], nX),;
											"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed, oSN3:GetValue('N3_TPSALDO', nX))
									ElseIf cAtfVar = "N3_VRDACM" .And. nX != n
										//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
										//³ Gera registro de baixa na conta de Depreciacao Acumulada, caso seja preciso refazer SN5³
										//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
										If lZeraDepr .AND. SN3->N3_VRDACM1 - oSN3:GetValue(aAux[aPosDeprAc[1],3], nX) != 0
											cOcorr 	   := "01"
											aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf), '08',/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
											aValorMoed := AtfMultMoe(,,{|x| SN3->&(If(x > 9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) - oSN3:GetValue(aAux[aPosDeprAc[x],3], nX) })
											cTpSaldo := SN3->N3_TPSALDO
											ATFXMOV(cFilAnt,@cIDMOV,dDtLancto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"4",0,cTpSaldo,,aValorMoed,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,__lContabiliza,cPadrao, "ATFA012")
											// Atualiza saldo da conta de depreciacao acumulada
											// Atualiza saldo da conta de depreciacao acumulada com a diferenca do valor
											// antigo a o valor atual (Valor do estorno) - Gera registro de baixa no SN5
											// *******************************
											// Controle de multiplas moedas  *
											// *******************************
											If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
												aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
											EndIf
											If AFXVerRat()
												If Alltrim(SN3->N3_CRIDEPR) == "03" .AND. SN3->N3_VRDACM1 > 0
													aAreaSN4 := SN4->(GetArea())
													ATFXMOV(cFilAnt,@cIDMOV,dDtLancto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"3",0,cTpSaldo,,aValorMoed,aDadosComp,/*nRecnoSN4*/,/*lComple*/,/*lValSN1*/,/*lClassifica*/,__lContabiliza,cPadrao, "ATFA012")

													If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
														aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
													EndIf
													aValDepr := AtfMultMoe(,,{|x| SN3->&( If( x > 9,"N3_VRDAC","N3_VRDACM") + AllTrim( Str(x) ) ) })

													If AllTrim(SN3->N3_RATEIO) == "1" .and. !Empty(SN3->N3_CODRAT)

														If __nHdlPrv <= 0
															If __lContabiliza .AND. VerPadrao("823") //CALCULO DE DEPRECIACAO: RATEIO DE DESPESAS
																__nHdlPrv := 	HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
															Endif
														Endif

														ATFRTMOV(	SN3->N3_FILIAL,;
															SN3->N3_CBASE,;
															SN3->N3_ITEM,;
															SN3->N3_TIPO,;
															SN3->N3_SEQ,;
															SN4->N4_DATA,;
															cIDMOV,;
															aValDepr,;
															__lContabiliza,;
															"1",;
															__nHdlPrv,;
															__cLoteATF,;
															@__nTotal,;
															,;
															FunName(),;
															"823",;
															__lContabiliza )

														If __nTotal > 0
															lCprova := .T.
														Endif
													Endif
													RestArea(aAreaSN4)
												Endif
											Endif
											aValorMoed := AtfMultMoe(,,{|x| SN3->&(If(x>9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) - oSN3:GetValue(aAux[aPosDeprAc[x],3], nX) })
											ATFSaldo(	SN3->N3_CCDEPR, dDtLancto/*SN3->N3_DINDEPR*/,"5",;
												SN3->N3_VRDACM1 - oSN3:GetValue(aAux[aPosDeprAc[1],3], nX),;
												SN3->N3_VRDACM2 - oSN3:GetValue(aAux[aPosDeprAc[2],3], nX),;
												SN3->N3_VRDACM3 - oSN3:GetValue(aAux[aPosDeprAc[3],3], nX),;
												SN3->N3_VRDACM4 - oSN3:GetValue(aAux[aPosDeprAc[4],3], nX),;
												SN3->N3_VRDACM5 - oSN3:GetValue(aAux[aPosDeprAc[5],3], nX),;
												"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CUSTBEM,"4", aValorMoed , oSN3:GetValue('N3_TPSALDO', nX))
										Else
											// Atualiza saldo da conta de depreciacao acumulada
											// Atualiza saldo da conta de depreciacao acumulada com a diferenca do valor
											// antigo a o valor atual (Valor do estorno)
											// *******************************
											// Controle de multiplas moedas  *
											// *******************************
											aValorMoed := AtfMultMoe(,,{|x| SN3->&(If(x > 9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) - oSN3:GetValue(aAux[aPosDeprAc[x],3], nX) })
											ATFSaldo(	SN3->N3_CCDEPR, dDtLancto/*SN3->N3_DINDEPR*/,"4",;
												SN3->N3_VRDACM1 - aCols[nx][aPosDeprAc[1]],;
												SN3->N3_VRDACM2 - aCols[nx][aPosDeprAc[2]],;
												SN3->N3_VRDACM3 - aCols[nx][aPosDeprAc[3]],;
												SN3->N3_VRDACM4 - aCols[nx][aPosDeprAc[4]],;
												SN3->N3_VRDACM5 - aCols[nx][aPosDeprAc[5]],;
												"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CUSTBEM,"4", aValorMoed, oSN3:GetValue('N3_TPSALDO', nX) )
										EndIf

										//grava em array os recnos utilizados para integracao com PCO
										Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao

									EndiF
								EndIf

							Endif
							If lIsRussia
								If !(RusCheckRevalFunctions() .And. AllTrim(cATFVar) $ "N3_BAIXA|N3_SEQ|N3_TIPO|N3_TPSALDO")
									Replace &("SN3->"+cATFVar) With  oSN3:GetValue(aAux[nY,3], nX) //aCols[nx][ny]
								EndIf
							Else
								Replace &("SN3->"+cATFVar) With  oSN3:GetValue(aAux[nY,3], nX) //aCols[nx][ny]
							EndIf



							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Grava campos referente a Rateio da SN3		              ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If AFXVerRat()
								If (nPosnAt := If(!Empty(__aRateio), aScan(__aRateio,{|x| x[4] == nX }),0)) > 0
									Replace SN3->N3_RATEIO With "1"
									Replace SN3->N3_CODRAT With __aRateio[nPosnAt,1]
								EndIf
							Endif
						EndIf
					Next nY

					// Na aquisicao, atualiza MNT, caso o parametro MV_NGMNTAT for igual a 1 ou 3.
					If oSN3:GetValue('N3_TIPO', nX) $ ("01|10" + cTypes10) .AND. lNGMNTAT //( SuperGetMv("MV_NGMNTAT", .F., "") $ "1#3" )
						nRecSn1:= SN1->(Recno())
						aCentro  := {}
						aAdd(aCentro,{SN3->N3_CUSTBEM})
						cCodBem := NGSEEK("SN1",SN3->N3_CBASE+SN3->N3_ITEM,1,"N1_CODBEM")
						If !Empty(cCodBem)

							If !MNTTRACCAT(xFilial("SN3"),cCodBem,dDataBase,aCentro[1]) .And. FindFunction( 'MNTXATF2' )
								MNTXATF2( SN1->N1_CBASE + SN1->N1_ITEM, SN1->N1_CODBEM )
							EndIf

						EndIf
						SN1->(dbGoto(nRecSn1))
					EndIf
					If lZeraDepr .And. !__lClassifica
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Verifica se existe lan‡amento padr„o.                     ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lPadrao:=VerPadrao(cPadrao)

						If lPadrao .and. __lContabiliza
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Monta lan‡amento cont bil. No Cria Automatico, cria o     ³
							//³ HeadProva e o RodaProva uma unica vez.                    ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !lCprova  .And. __nHdlPrv <= 0
								If lProva   // Em Criar Automatico, e' .T., so na 1a vez
									// Na Inclusao simples e sempre .T.
									__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
								EndIf
							EndIf
							lCprova := .T.
							If __nHdlPrv > 0
								__nTotal+=DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf)
							Endif
							VALOR  := 0
							VALOR2 := 0
						EndIf
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza dados padr”es do SN3 (saldos / valores )         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Empty(SN3->N3_SEQ) .Or. __lCopia
						cSeq := StrZero(nx,3)
					Else
						cSeq := SN3->N3_SEQ
					Endif
					SN3->N3_FILIAL   :=  xFilial("SN3")
					SN3->N3_CBASE    :=  SN1->N1_CBASE
					SN3->N3_ITEM     :=  SN1->N1_ITEM
					If ! RusCheckRevalFunctions()
						SN3->N3_BAIXA    :=  If(Empty(SN3->N3_BAIXA),"0",SN3->N3_BAIXA )
						SN3->N3_SEQ      :=  cSeq
					EndIf
					SN3->N3_AQUISIC :=   If(Empty(SN3->N3_AQUISIC) .OR. __lCopia,SN1->N1_AQUISIC,SN3->N3_AQUISIC)

					// se for uma reavaliacao, a data utilizada eh a data de inicio da depreciacao, se for
					// outro tipo a data eh a data de aquisicao, para nao gerar saldos e movimentos em datas incorretas
					FKCommit()
					If nOper == MODEL_OPERATION_INSERT
						AfAtuComple("SN3")
					Endif
					SN3->(MsUnlock())

					dDtMovto := If(oSN3:GetValue('N3_TIPO', nX) $ "02|05", SN3->N3_DINDEPR,SN3->N3_AQUISIC)

					//grava em array os recnos utilizados para integracao com PCO
					Pco_aRecno(aRecAtf, "SN3", 2)  //inclusao ou alteracao



					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso o tipo permita mais de um N3 gravo a sequencia de    ³
					//³ reavaliacao, ( N3_SEQREAV, N4_SEQREAV ). Esta sequencia   ³
					//³ permite a identificacao em casos de baixas parciais, qual ³
					//³ reavaliacao esta sendo baixada parcialmente.              ³
					//³ Incluido tipo 10 -  Depreciacao Gerencial	              ³
					//³ Incluido tipo 11 -  Ampliacao				              ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					nPosSn3 := SN3->(Recno())
					cSeqREav := "  "
					cChave := xFilial("SN3")+SN3->N3_CBASE+SN3->N3_ITEM + oSN3:GetValue('N3_TIPO', nX)
					If oSN3:GetValue('N3_TIPO', nX) $ cTipoReav .And. nOper == 3
						nMaior := 1
						SN3->(DbSeek(cChave))
						While cChave = SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO .And. !SN3->(Eof())
							nMaior := If(!Empty(Val(SN3->N3_SEQREAV)), Val(SN3->N3_SEQREAV)+1, nMaior++ )
							SN3->(DbSkip())
						EndDo
						cSeqREav := StrZero(nMaior,2)
						SN3->(dbGoto(nPosSn3))
					Else
						If nOper == 4 .And. A012ATFNovo(aAnterior,SN3->(Recno()))
							If oSN3:GetValue('N3_TIPO', nX) $ cTipoReav
								SN3->(DbSeek(cChave))
								nMaior := 0
								While cChave = SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO .And. ! SN3->(Eof())
									nMaior := IIf(!Empty(Val(SN3->N3_SEQREAV)), Val(SN3->N3_SEQREAV)+1, nMaior++ )
									SN3->(DbSkip())
								EndDo
								If nMaior = 0
									nMaior := 1
								Endif
								cSeqREav := StrZero(nMaior,2)
							EndIf
						EndIf
						SN3->(dbGoto(nPosSn3))
					Endif

					RecLock("SN3",.F.)
					SN3->N3_SEQREAV := If(Empty(SN3->N3_SEQREAV),cSeqReav,SN3->N3_SEQREAV)
					MsUnlock()
					nCntItem++


					//Preenche descrição estendida
					If nOper != 5
						cSeqSn3 := SN3->N3_SEQ
						AF012SN2(oModel,nX,cSeqSn3)
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava apontamento de produção ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SN3->N3_TPDEPR $ "4|5|8|9|" .and. (nOper != 4 .Or. __lClassifica) /*(correção pontual) criada proteção para não gravar
																apontamentos quando for alteração necessário ajustar a função
																AF110GrvAp para que possa atualizar os valores na tabela FNA ao
																invés de criar uma linha nova a cada chamada quando for alteração
																Verifica se está tratando uma classificação de Ativo*/

						//Apontamento inicial de estimativa de produção - P0
						AF110GrvAp(nPosSn3,"P0")

						//Salva o LP anterior
						cPadAnt := cPadrao
						lPadAnt := lPadrao

						cPadrao := "870"		//Apontamento de estimativa de produção
						lPadrao := VerPadrao(cPadrao)

						If __nHdlPrv <= 0
							__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
						EndIf

						If lPadrao .And. __nHdlPrv > 0
							__nTotal += DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf)
						EndIf

						//Restaura o LP anterior
						cPadrao := cPadAnt
						lPadrao := lPadAnt

						If (SN3->N3_PRODACM > 0) .And. (SN3->N3_VRDACM1 > 0)
							//Apontamento de produção acumulada - P5
							AF110GrvAp(nPosSn3,"P5")
						EndIf
					EndIf
				EndIf

				If !oSN3:IsDeleted(nX)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza Arquivo de Movimenta‡”es                   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lIsRussia
						SN4->(DbSetOrder(1))
						SN4->(DBSeek(xFilial("SN4") + oSN1:GetValue('N1_CBASE') + oSN1:GetValue('N1_ITEM')))
						dbSelectArea("SN4")
					EndIf
					If nOper == 4
						lGravaSN4 := .F.
						If ! __lClassifica
							SN4->(dbSetOrder(1))
							If SN4->(dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM))
								If  ! (SN4->N4_OCORR == "04") .And. ! (SN4->N4_OCORR == "16")
									If !SN4->(dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+DtoS(dDtMovto) + If(AllTrim(SN3->N3_TIPO) == "11","09","05")+SN3->N3_SEQ))
										lGravaSN4 := .T.
									Elseif !(FWisincallstack('ATFA036RUS') .or. FWisincallstack('RU01T02P'))
										If lIsRussia
											aValorMoed := AtfMultMoe("SN3","N3_VORIG")
										EndIf
										SN4->(RecLock("SN4",.F.))
											Replace SN4->N4_TXDEPR With &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf)
											If lIsRussia
												If Len(aValorMoed)> 0
													For nVlCur := 1 to Len(aValorMoed)
														SN4->&( "N4_VLROC" + cValToChar(nVlCur) ) := aValorMoed[nVlCur]
													Next nVlCur
												EndIf
											EndIf
										SN4->(MsUnLock())
									EndIf
								EndIf
							ElseIf (cPaisLoc == "BRA")
								lGravaSN4 := .T.
							EndIf
						ElseIf !SN4->(dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+DtoS(dDtMovto) + If(AllTrim(SN3->N3_TIPO) == "11","09","05")+SN3->N3_SEQ))
							lGravaSN4 := .T.
						EndIf
					Else
						lGravaSN4 := .T.
					EndIf

					If nOper == 3 .Or. lGravaSN4 .Or. nOper == 4
						If ! SN3->N3_TIPO $ "07|08|09"
							nRecnoSN4 := 0
							If Empty(cCodAnt)
								If nOper == 3  .or. lGravaSn4
									nRecnoSN4 := 0
								Else
									nRecnoSN4 := SN4->(Recno())
								EndIf
							Else // Classificacao
								dbSelectArea("SN4")
								SN4->(dbSetOrder(1))
								If dbSeek(xFilial("SN4")+cCodSN3)
									nRecnoSN4 := SN4->(Recno())
								Else
									nRecnoSN4 := 0
								EndIf
							EndIf

							If AF012VlGrM(If(nOper ==3, .T.,.F.),SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,cSeq,SN3->N3_SEQREAV) .Or. __lClassifica
								cOcorr 	   := If(AllTrim(SN3->N3_TIPO) == "11","09","05")
								aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),;
								 Iif(lIsRussia,(iif(FWisincallstack("AF036BXLOTE") .and. !empty(FN8->FN8_MOTIVO),FN8->FN8_MOTIVO,)),),/*cCodBaix*/,/*cFilOrig*/,SN1->N1_NSERIE,SN1->N1_NFISCAL,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
								If lIsRussia .And. (FWisincallstack('RU01T02P') .or. FWisincallstack('AF012Inclu'))
									aValorMoed:={}
								Else
									aValorMoed := AtfMultMoe(,,{|x| SN3->& ("N3_VORIG" + Alltrim(Str(x)) ) })
								Endif

								cTpSaldo := SN3->N3_TPSALDO
								If lIsRussia .and. cOcorr=='05' .and. Fwisincallstack('AF036GRVLT')
									cOcorr:='01'
									dDtMovto:=dDataBase
								Endif

								ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,cSeq,SN3->N3_SEQREAV,"1",SN1->N1_QUANTD,cTpSaldo,,aValorMoed,aDadosComp,nRecnoSN4,Inclui,,__lClassifica,__lContabiliza,cPadrao,"ATFA012")
								Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
								If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
									aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
								EndIf

								If lGravaSN4 .And. SN3->N3_TIPO$"02/05"
									__lReaval := .T.
									If __nHdlPrv <= 0
										__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
									EndIf
									If __nHdlPrv > 0
										__nTotal := DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf,,,,,,,, @aFlagCTB)
									EndIf
									If __nTotal > 0
										lCprova := .T.
									EndIf
								EndIf
							EndIf
						Endif
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Atualiza arquivo movimenta‡„o (Corre‡„o)                               ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						IF SN3->N3_VRCACM1 > 0
							nRecnoSN4 := 0

							If nOper == 3 .OR. lGravaSn4
								nRecnoSN4 := 0
							Else
								nRecnoSN4 := SN4->(Recno())
							EndIf

							If lGravaSN4 .Or. nOper == 3

								cOcorr 	   := "07"
								aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
								aValorMoed   := AtfMultMoe(,,{|x| 0})
								aValorMoed[1] := Round(SN3->N3_VRCACM1 , X3Decimal("N4_VLROC1") )
								cTpSaldo := SN3->N3_TPSALDO
								ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,"1",0,cTpSaldo,,aValorMoed,aDadosComp,nRecnoSN4,Inclui,/*lValSN1*/,/*__lClassifica*/,__lContabiliza,cPadrao,"ATFA012")

								Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
								If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
									aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
								EndIf


							EndIf
						EndIF
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza arquivo movimenta‡„o (Corre‡„o)                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					IF SN3->N3_VRCACM1 > 0
						If nOper == 4
							If !dbSeek(xFilial("SN4") + SN3->N3_CBASE + SN3->N3_ITEM + SN3->N3_TIPO+;
									DtoS(dDtMovto) + "07" + SN3->N3_SEQ)   //dAquisic
								lGravaSN4 := .T.
							EndIf
						EndIf
						nRecnoSN4 := 0

						If lGravaSN4 .And. nOper == 3
							cOcorr 	   := "07"
							aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(IIF(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/,SN3->N3_PRODMES)
							aValorMoed   := AtfMultMoe(,,{|x| 0})
							aValorMoed[1] := Round(SN3->N3_VRCACM1 , X3Decimal("N4_VLROC1") )
							cTpSaldo := SN3->N3_TPSALDO
							ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,cSeq,SN3->N3_SEQREAV,"2",0,cTpSaldo,,aValorMoed,aDadosComp,,If(nOper == 3,.T.,.F.),/*lValSN1*/,/*__lClassifica*/,__lContabiliza,cPadrao,"ATFA012")
							Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
							EndIf
						EndIf
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza arquivo Movimenta‡”es (Corre‡„o da Deprecia‡„o)               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					If SN3->N3_VRCDA1 > 0

						lGravaSN4 := ! If(nOper == 4 ,dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+DtoS(dDtMovto)+"08"+SN3->N3_SEQ), .F.)   //dAquisic
						If lGravaSN4 .And. nOper == 3
							cOcorr 	   := "08"
							aDadosComp := ATFXCompl( /*nTaxaMedia*/, &(If(Val(cMoedaAtf) > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES)
							aValorMoed   := AtfMultMoe(,,{|x| 0})
							aValorMoed[1] := Round(SN3->N3_VRCDA1 , X3Decimal("N4_VLROC1") )
							cTpSaldo := SN3->N3_TPSALDO
							ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,cSeq,SN3->N3_SEQREAV,"5",0,cTpSaldo,,aValorMoed,aDadosComp,,If(nOper == 3,.T.,.F.),/*lValSN1*/,/*__lClassifica*/,__lContabiliza,cPadrao, "ATFA012")
							Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							   aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza arquivo Movimenta‡”es (Deprecia‡„o)                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If &('SN3->N3_VRDACM' + cMoedaAtf) > 0
						cOcorr 	   := If(SN3->N3_TIPO $ ("10|12|14|50|51|52|53|54" + cTypes10 + cTypes12), "20", If(SN3->N3_TIPO == "07","10",If(SN3->N3_TIPO=="08","12",If(SN3->N3_TIPO == "09","11","06"))))

						If nOper == MODEL_OPERATION_UPDATE
							If dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+DTOS(dDtMovto)+cOcorr+SN3->N3_SEQ)
								lGravaSN4 := .F.
							EndIf
						Else
							lGravaSN4 := .T.
						EndIf

						If lGravaSN4 .And. (nOper == 3 .or. nOper == 4)

							aDadosComp := ATFXCompl( SN3->N3_VRDACM1 / &(If(Val(cMoedaAtf)>9,'SN3->N3_VRDAC','SN3->N3_VRDACM')+cMoedaAtf) , &(If(Val(cMoedaAtf)>9,'SN3->N3_TXDEP','SN3->N3_TXDEPR')+cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
							aValorMoed := AtfMultMoe(,,{|x| SN3->&(IIf(x>9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })
							cTpSaldo := SN3->N3_TPSALDO
							ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,cSeq,SN3->N3_SEQREAV,"4",0,cTpSaldo,,aValorMoed,aDadosComp,,If(nOper == 3,.T.,.F.),/*lValSN1*/,/*__lClassifica*/,__lContabiliza,cPadrao,"ATFA012")
							//Acrescentado por Fernando Radu Muscalu em 07/06/11
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
							   aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
							EndIf
							If AFXVerRat()

								If AllTrim(SN3->N3_CRIDEPR) == "03"
									aAreaSN4 := SN4->(GetArea())

									ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,cSeq,SN3->N3_SEQREAV,"3",0,cTpSaldo,,aValorMoed,aDadosComp,,If(nOper == 3,.T.,.F.),/*lValSN1*/,/*__lClassifica*/,__lContabiliza,cPadrao,"ATFA012")
									If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
									   aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
									EndIf
									If AllTrim(SN3->N3_RATEIO) == "1" .and. !Empty(SN3->N3_CODRAT)

										aValDepr := AtfMultMoe(,,{|x| SN3->&( If( x > 9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })

										If __nHdlPrv <= 0
											If __lContabiliza .AND. VerPadrao("823") //CALCULO DE DEPRECIACAO: RATEIO DE DESPESAS
												__nHdlPrv := 	HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
											Endif
										Endif

										ATFRTMOV(	SN3->N3_FILIAL,;
											SN3->N3_CBASE,;
											SN3->N3_ITEM,;
											SN3->N3_TIPO,;
											SN3->N3_SEQ,;
											SN4->N4_DATA,;
											cIDMOV,;
											aValDepr,;
											__lContabiliza,;
											"1",;
											__nHdlPrv,;
											__cLoteATF,;
											@__nTotal,;
											,;
											FunName(),;
											"823",;
											__lContabiliza )

										If __nTotal > 0
											lCprova := .T.
										Endif
									Endif
									RestArea(aAreaSN4)
								EndIf

							Endif

							Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Atualiza arquivo Movimenta‡”es (Corre‡„o da Deprecia‡„o)               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SN3->N3_VRCDA1 > 0
						lGravaSN4 := ! If(nOper == 4,dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO + DtoS(dDtMovto) + "08" + SN3->N3_SEQ), .F.)   //dAquisic
						If lGravaSN4 .AND. nOper == 3
							cOcorr 	   := "08"
							aDadosComp := ATFXCompl( 0 , &(If(Val(cMoedaAtf) > 9,'SN3->N3_TXDEP','SN3->N3_TXDEPR') + cMoedaAtf),/*cMotivo*/,/*cCodBaix*/,/*cFilOrig*/,/*cSerie*/,/*cNota*/,/*nVenda*/,/*cLocal*/, SN3->N3_PRODMES )
							aValorMoed := AtfMultMoe(,,{|x| SN3->&(If(x > 9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })
							cTpSaldo := SN3->N3_TPSALDO
							ATFXMOV(cFilAnt,@cIDMOV,dDtMovto,cOcorr,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_BAIXA,cSeq,SN3->N3_SEQREAV,"4",0,cTpSaldo,,aValorMoed,aDadosComp,,Inclui,/*lValSN1*/,/*__lClassifica*/,__lContabiliza,cPadrao,"ATFA012")
							Pco_aRecno(aRecAtf, "SN4", 2)  //inclusao ou alteracao
							If lUsaFlag  // Armazena em aFlagCTB para atualizar no modulo Contabil
								aAdd(aFlagCTB,{"N4_LA","S","SN4",SN4->(Recno()),0,0,0})
							EndIf
						EndIf
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se for opera‡„o de inclus„o verifica se vai gerar lancamento contabil  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOper == 3 .OR. (nOper == 4 .AND. A012ATFNovo(aAnterior,SN3->(Recno())) ) .OR. __lClassifica //nX > Len(aAnterior)

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Grava no SN5 o tipo da Imobiliza‡„o.                    ³
						//³ Se for imobiliza‡„o normal             = 1              ³
						//³ Se                  Reavali‡„o         = 3              ³
						//³ Se                  Capital            = A              ³
						//³ Se                  Capital Prejuizo   = B              ³
						//³ Se Baixa Capital                       = C              ³
						//³ Se ""               Capital Prejuizo   = D              ³
						//³ Se ""               Correcao de Capital= P              ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						lAtClDepr := AtClssVer(SN1->N1_PATRIM)
						If lAtClDepr .OR. Empty(SN1->N1_PATRIM)
							cTipoImob := If(SN3->N3_TIPO $ "02|05" ,"3","1")
							cTipoCorr := "6"
						Elseif SN1->N1_PATRIM $ "CSA"
							cTipoImob := "A"
							cTipoCorr := "O"
						Else
							cTipoImob := "B"
							cTipoCorr := "6"
						EndIf

						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Se for capital social negativo, s¢ ir  gerar o registro ³
						//³ no SE5 referente a Impobiliza‡„o.                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If A012ATFNovo(aAnterior,SN3->(Recno())) .OR. __lClassifica
							If !SN3->N3_TIPO $ "07|08|09"
								// *******************************
								// Controle de multiplas moedas  *
								// *******************************
								aValorMoed := AtfMultMoe("SN3","N3_VORIG")
								ATFSaldo(	SN3->N3_CCONTAB,dDtMovto,cTipoImob,SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3,;
									SN3->N3_VORIG4,SN3->N3_VORIG5,"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed,oSN3:GetValue('N3_TPSALDO', nX))
								// *******************************
								// Controle de multiplas moedas  *
								// *******************************
								aValorMoed := AtfMultMoe(,,{|x| If(x = 1,SN3->N3_VRCACM1,0) })
								ATFSaldo(	SN3->N3_CCONTAB,dDtMovto,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
									"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed ,oSN3:GetValue('N3_TPSALDO', nX))
							Endif
							// *******************************
							// Controle de multiplas moedas  *
							// *******************************
							aValorMoed := AtfMultMoe(,,{|x| If(x = 1,SN3->N3_VRCACM1,0) })
							ATFSaldo(	SN3->N3_CCORREC,dDtMovto,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
								"+",,SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed ,oSN3:GetValue('N3_TPSALDO', nX))

							lAtClDepr := AtClssVer(SN1->N1_PATRIM)
							If lAtClDepr .OR. Empty(SN1->N1_PATRIM)

								cTipoImob := If( !SN3->N3_TIPO $ ("08|09|10|12|14|50|51|52|53|54" + cTypes10 + cTypes12), "4", If(SN3->N3_TIPO $ ("10|12|14|50|51|52|53|54" + cTypes10),"Y",If(SN3->N3_TIPO == "09","L","K")))
								aValorMoed := AtfMultMoe("SN3","N3_VRDACM")
								ATFSaldo(	SN3->N3_CCDEPR ,dDtMovto,cTipoImob, SN3->N3_VRDACM1,SN3->N3_VRDACM2  ,;
									SN3->N3_VRDACM3,SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed,oSN3:GetValue('N3_TPSALDO', nX) )
								aValorMoed := AtfMultMoe(,,{|x| If(x == 1,SN3->N3_VRCDA1,0)})
								ATFSaldo(	SN3->N3_CCDEPR ,dDtMovto,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
									"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed , oSN3:GetValue('N3_TPSALDO', nX) )
								aValorMoed := AtfMultMoe(,,{|x| If(x = 1,SN3->N3_VRCDA1,0) })
								ATFSaldo(	SN3->N3_CDESP  ,dDtMovto,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
									"+",,SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed , oSN3:GetValue('N3_TPSALDO', nX))
							Endif
						EndIf
						//--------------------------------------------------------
						//AVP
						//GRAVA AVP INCLUSAO - Constituicao
						If SN3->N3_TIPO == '14'
							// Confirma a taxa no SN1
							RecLock("SN1" , .F. )
							SN1->N1_TAXAVP := oSN1:GetValue('N1_TAXAVP')
							MsUnLock()
							A012GrvAVP(__lContabiliza,__nTotal,__nHdlPrv,__cLoteAtf)

							lCprova := .T.
						Endif
					EndIf
				EndIf
                If !Empty(nPosSn3)
                    aAdd(aContbSN3,nPosSn3)
                EndIf
			Next nX
		EndIf

		If lAFA012
			ExecBlock("ATFA012",.F.,.F.,{oModel, 'FORMCOMMITTTSPOS', 'SN3DETAIL', If(nOper == 3, .T., .F.)})
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Final  da Prote‡„o Via TTS                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		//-- Alterar o CBase do ativo na NF.
		//-D1_FILIAL+D1_COD+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
		//-SN1->N1_FILIAL+SN1->N1_PRODUTO+SN1->N1_NFISCAL+SN1->N1_NSERIE+SN1->N1_FORNEC+SN1->N1_LOJA
		If __lClassifica
			DBSelectArea("SD1")
			SD1->(DBSetOrder(2))
			If(SD1->(DBSeek(cChvNfe)))
				If (oSN1:GetValue("N1_CBASE") + oSN1:GetValue("N1_ITEM")) != SD1->D1_CBASEAF //apenas se for diferente
					RecLock("SD1", .F.)
					SD1->D1_CBASEAF := oSN1:GetValue("N1_CBASE") + oSN1:GetValue("N1_ITEM")
					SD1->(MsUnlock())
				Endif
			EndIf
		EndIf

	End Transaction

	If !lDeleta .OR. __lClassifica
		cPadrao:=	AF012AQPAD(SN3->N3_TIPO, .F. )
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe lan‡amento padr„o.                     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lPadrao:= (!lZeraDepr .Or. __lClassifica) .And. VerPadrao(cPadrao)

	If lPadrao .and. __lContabiliza .And. !lClaLote .And. !__lReaval .And. ( !lDeleta .OR. (lDeleta .And. __lClassifica)) //Ajuste realizado para contabilizar ampliação e classificação
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta lan‡amento cont bil. No Cria Automatico, cria o     ³
		//³ HeadProva e o RodaProva uma unica vez.   	                 ³
		//³ Menos quando for classificação em lote	                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//Contabilização inclusão percorrendo SN3
		lCprova := F012CONTIN(lCprova,lProva,cPadrao, aContbSN3)
	EndIf


	If lCprova
		If __nTotal > 0 .And. __lCTBFIM
			RodaProva(__nHdlPrv,__nTotal)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lan‡amento Contabil                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			// Salva os parametros(mv_par..) antes da chamada da funcao, pois o botao Excel da tela de lancamentos os sobrepoe
			//Apenas em modo de Inclusao
			If nOper == 3 .Or. __lClassifica .Or. __lAmplia .Or. __lReaval
				SaveInter()
				cA100Incl(__cArqCtb,__nHdlPrv,3,__cLoteAtf,lMostra,lAglut,,,, @aFlagCTB)
				RestInter() //Restaura os parametros utilizados anteriormente
			Endif
			lCprova := .F.
		EndIf
	EndIf

	//AVP2
	//Incluo o bem provisao referente ao valor da depreciacao acumulada informada na inclusao do
	//bem classificado como orcamento e AVP em parcelas
	If SN1->N1_TPAVP == '2' .AND. SN1->N1_PATRIM == 'O'
		lRet := AF012Provis(SN1->N1_CBASE , SN1->N1_ITEM)
	Endif

	//integracao com modulo de planejamento e controle orcamentario
	If SuperGetMV("MV_PCOINTE",.F.,"2") == "1"
		Atf_IntPco(aRecAtf,aPadPCO)
	EndIf

	If lAFA012 //Ponto de entrada após commit do model
		ExecBlock("ATFA012",.F.,.F., {oModel, 'MODELCOMMITNTTS', 'SN3DETAIL'})
	Endif
	If lBmContr
		If nOper == MODEL_OPERATION_DELETE .And. cBmcontr == '1' .And. oSN1:GetValue("N1_STATUS") == '0' .And. len(CompDoBemC(SN1->N1_CBASE,SN1->N1_ITEM)) == 0//Condições de um bem em construção que não tem componentes amarrados e não foi agrupado
			BmcDelCiap(AllTrim(oSN1:GetValue('N1_CODCIAP')))
		EndIf
	EndIf

	dbSelectArea('SN3')
	oSN3:GoLine(nOldn)

	If nOper == MODEL_OPERATION_DELETE
		AF012DLAT(/*SN3*/, lCprova,lMostra,__lContabiliza,aCIAP,__aRateio,lAglut) //Atualiza os arquivos apos a exclusao
	EndIf

EndIf


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012VlGrM
Verifica se o movimento de implantação pode ser gravado protegendo a alteracao do registro de movimentacao
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012VlGrM(lInclui,cBase,cItem,cTipo,cSeq,cSeqReav)
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaSN4 := SN4->(GetArea())

If !lInclui
	// Caso o indice exista, busca pelo indice para o tratamento de multiplos tipos de saldo
	If !Empty(SN4->(IndexKey(9)))
		SN4->(dbSetOrder(9)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ+DTOS(N4_DATA)+N4_OCORR
		If SN4->(MsSeek(xFilial("SN4") +cBase+cItem+cTipo+cSeqReav+cSeq ))
			lRet := .F.
		EndIf
	Else // Caso contrario, busca no indice antigo
		SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DTOS(N4_DATA)+N4_OCORR
		If SN4->(MsSeek(xFilial("SN4") +cBase+cItem+cTipo ))
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea(aAreaSN4)
RestArea(aArea)
Return  lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012Provis
Gero os provisorios caso o bem de orcamento possua depreciacao acumulada
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Provis(cBase,cItem)
Local aArea    := GetArea()
Local aAreaSN4 := SN4->(GetArea())
Local aAreaSN1 := SN1->(GetArea())
Local aAVPMan  := {}
Local lRet     := .T.

If __lAtfAuto .And. Type('__aAutoItens')== "A"
	aAVPMan := aClone(__aAutoItens)
Else
	aAVPMan := {}
EndIf

//Posiciono no SN4
SN4->(DBSETORDER(1))
SN1->(DBSETORDER(1))

If SN1->(MsSeek(xFilial("SN1") + cBase + cItem ))
	If SN4->(MsSeek(xFilial("SN4")+SN1->(N1_CBASE+N1_ITEM)+'01'+Dtos(dDatabase)+'06')) .Or. SN4->(MsSeek(xFilial("SN4")+SN1->(N1_CBASE+N1_ITEM)+'10'+Dtos(dDatabase)+'20'))
		//Incluo os novo bens (se houve depreciacao)
		//Se o bem for classificado como Orcamento e o AVP deste for por parcela
		//Verifico se ouve depreciacao e gero o ativo de provisao
		If SN1->N1_PATRIM == 'O' .and. SN1->N1_TPAVP == '2'
			MsgRun(STR0128,"",{|| lRet := AF460Apur(.T.,SN1->N1_GRUPO,SN4->N4_IDMOV,dDatabase,aAVPMan) })//"Convertendo Bem Aguarde"
			pergunte("AFA012",.F.)
			AF012PerAut()
		Endif
	EndIf
EndIf

RestArea(aAreaSN1)
RestArea(aAreaSN4)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A012GrvAVP
Gravação do movimento AVP
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function A012GrvAVP(lContabiliza,nTotal,nHdlPrv,cLoteAtf)
Local cIdProcAVP := ""
Local cTipoSLD     := SN3->N3_TPSALDO
Local nPosTipo   := 0
Local nPosTipSld := 0
Local nX         := 0
Local aAux       := {}
Local nValRlz    := 0
Local cTypes10   := "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

//Obtenho o ID de processo
cIdProcAVP	:= GetSxeNum('FNF','FNF_IDPROC','FNF_IDPROC'+cEmpAnt,3)
//Gravo o movimento de constituicao do AVP pela inclusao do bem
AfGrvAvp(cFilAnt,"1",SN1->N1_INIAVP,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,SN3->N3_VORIG1,lContabiliza,@nTotal,@nHdlPrv,cLoteAtf,SN3->(RECNO()),cIdProcAVP,/*aRecCtb*/,/*lBxTotal*/,SN4->N4_IDMOV)


If __lAtfAuto .And. Type('__aAutoItens')== "A"
	aAVPMan := aClone(__aAutoItens)

	For nX := 1 to Len(aAVPMan)
		aAux       := aAVPMan[nX]
		nPosTipSld := ascan(aAux,{|x| Alltrim(x[1]) == 'N3_TPSALDO'})
		nPosTipo   := ascan(aAux,{|x| Alltrim(x[1]) == 'N3_TIPO'})
		nPosAVPRZ  := ascan(aAux,{|x| Alltrim(x[1]) == 'N3AVPREAL'})
		If nPosTipSld > 0 .And. nPosAVPRZ > 0
			If Alltrim(aAux[nPosTipSld][2]) == Alltrim(cTipoSLD) .And. Alltrim(aAux[nPosTipo][2]) $ ("10" + cTypes10)
				// CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
				//nValRlz := aAux[nPosAVPRZ][2]
				//Exit
				nValRlz += aAux[nPosAVPRZ][2]
			EndIf
		EndIf
	Next nX

	If nValRlz > 0
		//Gravo o movimento de realização do AVP pela inclusao do bem
		//a taxa será zero, pois o valor foi informado
		AfGrvAvp(cFilAnt,"2",SN1->N1_INIAVP,SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_TPSALDO,SN3->N3_BAIXA,SN3->N3_SEQ,SN3->N3_SEQREAV,nValRlz,lContabiliza,@nTotal,@nHdlPrv,cLoteAtf,SN3->(RECNO()),cIdProcAVP,/*aRecCtb*/,/*lBxTotal*/,SN4->N4_IDMOV,/*nValPres*/,/*cRotina*/,/*cArquivo*/,/*nRecFNF*/,/*lCvMtdDpr*/,/*cIndAvp*/,/*cPerInd*/,0.0,/*dDtExecAVP*/)

	EndIf
EndIf

//Confirmo o ID do processo nas tabelas de controle
ConfirmSX8()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AQPAD
Função para determinar qual o códido do lançamento padrão
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AQPAD(cTipoATF,lEstorno)
Local cPadrao := ""
Local cTypes10   := "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models
Default lEstorno := .F.

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "*" + AtfNValMod({1}, "*")
Endif
If lEstorno
	If cTipoATF $ ("01*10" + cTypes10)
		cPadrao := "805"
	ElseIf cTipoATF $ "02,05"
		cPadrao := "806"
	ElseIf cTipoATF $ "03*13"
	    cPadrao := "807"
	ElseIf cTipoATF == "04"
		cPadrao := "808"
	ElseIf cTipoATF == "11"
		cPadrao := "822"
	Else
		cPadrao := "80B"
	EndIf
Else
	If cTipoATF $ ("01*10" + cTypes10)
		cPadrao := "801"
	ElseIf cTipoATF $ "02,05"
		cPadrao := "802"
	ElseIf cTipoATF $ "03*13"
	    cPadrao := "803"
	ElseIf cTipoATF == "04"
		cPadrao := "804"
	ElseIf cTipoATF == "11"
		cPadrao := "821"
	Else
		cPadrao := "80A"
	EndIf
EndIf

Return cPadrao

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ADELR
Prepara array de rateio para exclusao
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012ADELR(aRateio,nMaxArray, oAux)
Local nX := 0

For nX := 1 To nMaxArray

	If oAux:IsDeleted(nx)   //aCols[nx][Len(aCols[nx])]
		If (nPosnAt := If(!Empty(aRateio), aScan(aRateio,{|x| x[4] == nx }),0)) > 0
			aRateio[nPosnAt,6] := .T.
		EndIf
	EndIf

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CotaDepr
Funcao executa os calculos de depreciacao
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CotaDepr(aTaxaRef,aCotaM,aParam,aValores,dInDepr,nMoedaVMax,lResid,nLinha)
Local aVlrOrig		:= aClone(aValores[1])
Local aVlrAcum		:= aClone(aValores[2])
Local aVlrAmpl		:= aClone(aValores[3])
Local aVlrCAcm		:= aClone(aValores[4])
Local aVlrCda		:= aClone(aValores[5])
Local cMoedaAtf 	:= Alltrim(SuperGetMv("MV_ATFMOED",.F.,"1"))
Local cTCalcAF		:= GetMV("MV_TCALCAF",.F.,"0")`
Local nDiferenca	:= 0				// Auxiliar na verificacao de saldo residual.
Local nCusto		:= 0				// Auxiliar Custo de Aquisição
Local nDecimal		:= 0				// Auxiliar número de decimais
Local nI			:= 0				// Auxiliar Contador
Local nMFiscal		:= 0
Local nDecTax		:= 0
Local nPropBase	:= 0
Local nVlrOriSal	:= 0
Local lVlrMxDp		:= .F.
Local lVlrSalv		:= .F.
Default nMoedaVMax  := Iif(Val(GetMv("MV_ATFMDMX",.F.," ")) > 0, Val(GetMv("MV_ATFMDMX")), Val(cMoedaAtf))
Default aParam		:= {}
Default lResid		:= .F.


//³Mapeamento do conteudo de aParam					  ³
//³aParam[1] - N3_VORIG1							  ³
//³aParam[2] - N3_VRDACM1							  ³
//³aParam[3] - N3_TPDEPR							  ³
//³aParam[4] - N3_VMXDEPR							  ³
//³aParam[5] - N3_PERDEPR							  ³
//³aParam[6] - N3_VLSALV1							  ³
//³aParam[7] - N3_PRODMES							  ³
//³aParam[8] - N3_PRODANO							  ³
//³aParam[9] - N3_FIMDEPR							  ³

/*

N3_VRCDA1	- Corr Depr Acumulada
N3_VRCACM1  - Correcao Acumulada Moeda1

*/

If cPaisLoc == 'PTG'
	nMFiscal := Val(cMoedaAtf) // O vlr zero exclui a condicao da moeda fiscal
EndIf

lVlrSalv := aParam[3] == "2" //SN3->N3_TPDEPR == '2'

/*Verificacao do tratamento de valor maximo de depreciacao*/
lVlrMxDp := nMoedaVMax > 0 .AND. aParam[4] > 0 //SN3->N3_VMXDEPR > 0

/*Define regra de proporcionalizacao para outras moedas*/
If lVlrMxDp
	nPropBase 	:= aParam[4] / aVlrOrig[nMoedaVMax,1] + aVlrAmpl[nMoedaVMax]	 //SN3->N3_VMXDEPR /(&("N3_VORIG"  + Str(nMoedaVMax,1)) + &("N3_AMPLI" + Str(nMoedaVMax,1)))
ElseIf lVlrSalv
	nPropBase 	:= aParam[6] / (aVlrOrig[1,1] + aVlrAmpl[1])					 //SN3->N3_VLSALV1 / SN3->(N3_VORIG1+N3_AMPLIA1)
Endif

/*Implementation*/
If dInDepr <= dDataBase

	For nI := 1 to Len( aCotaM )

		nDecimal := aVlrOrig[nI,2]	//X3Decimal( "N3_VORIG" + AllTrim(Str(nI)) )

		If aTaxaRef[ nI ] # 0


			nDecTax	:= aVlrOrig[nI,2]	//TAMSX3("N3_VORIG"  + AllTrim(Str(nI)))[2]
			nDeprAcum	:= aVlrAcum[nI] + AF012GetSldAcel(Str(nI,1), nLinha)	//&("N3_VRDACM" + Str(nI,1)) + GetSldAcel( Str(nI,1) )
			nCusto		:= aVlrOrig[nI,1] + aVlrAmpl[nI]					//&("N3_VORIG"  + Str(nI,1)) + &("N3_AMPLIA" + Str(nI,1))

			// Tratamento da correção Monetária
			If nI == 1
				nDeprAcum	+= aVlrCda[1]	//N3_VRCDA1	// Round( N3_VRCDA1 / RecMoeda( dDataBase, i ), nDecimal )
				nCusto		+= aVlrCAcm[1]	//N3_VRCACM1	// Round( N3_VRCACM1 / RecMoeda( dDataBase, i ), nDecimal )
			Endif

			If  nI == nMoedaVMax .AND. lVlrMxDp
				//habilita o "Valor maximo de depreciação" no calculo de depreciação na moeda definida
				nCusto	:=	If(Empty(aParam[4]),nCusto, aParam[4])	//iif(Empty(SN3->N3_VMXDEPR),nCusto, SN3->N3_VMXDEPR)
			ElseIf nI != nMoedaVMax .AND. lVlrMxDp
				// Proporcionaliza a base para as outras moedas
				nCusto := Round(NOROUND(nCusto * Round(NoRound(nPropBase,nDecTax+1),nDecTax),nDecTax+1),nDecTax)
			Endif

			If lVlrSalv .And. nI == 1
				nVlrOriSal := nCusto - aParam[6]	//SN3->N3_VLSALV1
				nCusto := Abs(nCusto - nDeprAcum)
			ElseIf lVlrSalv .And. nI >= 2
				nVlrOriSal := nCusto - Round(NOROUND(nCusto * Round(NoRound(nPropBase,nDecTax+1),nDecTax),nDecTax+1),nDecTax)
				nCusto := Abs(nCusto - nDeprAcum)
			EndIf

			// Se possuir valor residual, efetua o calculo da cota.
			If  ( !lVlrSalv .And. Abs( nDeprAcum ) <= Abs( nCusto ) ) .Or. ( lVlrSalv .And. Abs( nDeprAcum ) <= Abs( nVlrOriSal ) )

				aCotaM[nI] := If( Empty( aParam[9] ),Round( nCusto * aTaxaRef[nI], nDecimal ), 0 )

				// Verifica se o valor da cota eh maior do que o valor residual.
				If lVlrSalv
					nDiferenca := Abs(nVlrOriSal) - ( Abs(aCotaM[nI]) + Abs(nDeprAcum) )
				Else
					nDiferenca := Abs(nCusto) - ( Abs(aCotaM[nI]) + Abs(nDeprAcum) )
				EndIf

				// Residuo inferior a 1 (uma) unidade monetaria sera adicionado a cota atual.
				If !lVlrSalv .And. Round( nDiferenca, nDecimal ) <= 0.99
					aCotaM[nI] := nCusto - nDeprAcum
				ElseIf lVlrSalv .And. Round( nDiferenca, nDecimal ) <= 0.99
					aCotaM[nI] := nVlrOriSal - nDeprAcum
				ElseIf lResid
					aCotaM[nI] := Round( (nCusto - nDeprAcum) * aTaxaRef[nI],nDecimal )		//Round(nDiferenca * aTaxaRef[nI],nDecimal)
				Endif
			Endif
		Endif
	Next nI
Endif

//a funcao abaixo precisa ser analisada pois nao tem efeito os calculos que sao realizados por ela
If cTCalcAF == "1"	// Saldos Decrescentes
	Degressiva( cMoedaATF, cPerRegres, nMesRegres, aCotaM, aValores, nLinha )
EndIf

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}FA012GetPn
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------

Function FA012GetPn(oWnd)
Local oTPanel	:= Nil
Local oSay1	:= Nil
Local oSay2	:= Nil
Local oSay3	:= Nil
Local oSay4	:= Nil
Local oSay5	:= Nil
Local oSay6	:= Nil
Local oSay7	:= Nil
Local oSay8	:= Nil
Local oAriaN	:= tFont():New("Arial",,-12,,.T.)
Local oAriaI	:= tFont():New("Arial",,-12,,.F.,,,,.T.)
Local cTpS		:= ""
Local oModel 	:= FWModelActive()
Local oAux		:= oModel:GetModel('SN3DETAIL')
Local nLin		:= oAux:GetLine()

SX5->(dbSetOrder(1))
If SX5->(dbSeek(xFilial("SX5")+"SL"+oAux:GetValue('N3_TPSALDO', nLin)))
   cTpS := X5Descri()
EndIf

oTPanel:= TPanel():New(10,10,"",oWnd,,,,,,20,20)
oTPanel:Align := CONTROL_ALIGN_TOP

oSay1 := TSay():New(05,005,{|| ATF012X3Titulo("N1_CBASE") + ": "},oTPanel,,oAriaN,,,,.T.)
oSay2 := TSay():New(05,050,{|| oModel:GetValue('SN1MASTER','N1_CBASE')}  	  		,oTPanel,,oAriaI,,,,.T.)

oSay3 := TSay():New(05,105,{|| ATF012X3Titulo("N1_ITEM") + ": "},oTPanel,,oAriaN,,,,.T.)
oSay4 := TSay():New(05,135,{||oModel:GetValue('SN1MASTER','N1_ITEM')}	 			,oTPanel,,oAriaI,,,,.T.)

oSay5 := TSay():New(05,160,{|| ATF012X3Titulo("N3_TIPO") + ": "},oTPanel,,oAriaN,,,,.T.)
oSay6 := TSay():New(05,195,{|| oAux:GetValue('N3_TIPO', nLin)}	,oTPanel,,oAriaI,,,,.T.)

oSay7 := TSay():New(05,215,{|| ATF012X3Titulo("N3_TPSALDO") + ": "},oTPanel,,oAriaN,,,,.T.)
oSay8 := TSay():New(05,260,{|| cTpS},oTPanel,,oAriaI,,,,.T.)

Return oTPanel

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012GetSldAcel
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012GetSldAcel( cMoedaATF, nLinha )
Local cFieldAcum	:= 	If( Val(cMoedaATF) > 9, "N3_VRDAC", "N3_VRDACM" ) + cMoedaAtf
Local nResult 		:= 0.00
Local oAux
Local nX := 1
Local cTypes10		:= "" // CAZARINI - 13/03/2017 - If is Russia, add new valuations models - main models

If lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cTypes10 := "|" + AtfNValMod({1}, "|")
Endif

oAux := FWModelActive()
oAux := oAux:GetModel('SN3DETAIL')

If Alltrim(oAux:GetValue('N3_TIPO', nLinha)) == "07"

	For nX := 1 To oAux:Length()
		If oAux:GetValue('N3_TIPO') $ ("01|10" + cTypes10)
			nResult += oAux:GetValue(cFieldAcum, nX)
			Exit
		EndIf
	Next nX

Endif

If Alltrim(oAux:GetValue('N3_TIPO', nLinha)) $ ("01|10" + cTypes10)

	For nX := 1 To oAux:Length()
		If oAux:GetValue('N3_TIPO', nX) == '07'
			nResult += oAux:GetValue(cFieldAcum, nX)
		EndIf
	Next nX

Endif

Return(nResult)

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CDegres
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CDegres(cMoedaATF,cPeriodo,nMes)
Local aResult		:= AtfMultMoe(,,{|x| 0})		//Valor de Retorno
Local aLiquido		:= AtfMultMoe(,,{|x| 0})		//Valor Liquido - Auxiliar
Local nAnosDecor	:= 0							//Tempo Decorrido em anos desde o início dos cálculos.
Local nAnosRest	:= 0		  					//Tempo restante em anos para o término dos cálculos.
Local aTaxaMax		:= AtfMultMoe(,,{|x| 0})
Local i, j			:= 0							//Contador - Auxiliar
Local lUsaCoefic	:= .T.							//Coeficiente aplicado sobre a Taxa de Depreciação
Local nQuantas 	:= AtfMoedas

aTaxaMax   := MaxTxDegr( lUsaCoefic )
nAnosDecor := 1 + ( Year( dDataBase ) - Year( SN3->( N3_DINDEPR ) ) )
nAnosRest  := PrzTotPrev(cMoedaATF) - nAnosDecor

For i := 1 to nQuantas

	aLiquido[ i ] := SN3->&('N3_VORIG' + Alltrim(Str(i)) )
	For j := 1 to nAnosDecor
		//Regra: Quando a Cota Anual (VlLiquido * Taxa) FOR MENOR QUE (VlLiquido/Anos Restantes)
		//de vida util, considerar (VlLiquido/Anos Restantes).
		If (aLiquido[ i ] * ( aTaxaMax[ i ] / 100 )) < ( aLiquido[ i ] / nAnosRest )
			aResult[ i ] := aLiquido[ i ] / nAnosRest
			aLiquido[ i ] -= aResult[ i ]
		Else
			aResult[ i ] := ( aLiquido[ i ] * ( aTaxaMax[ i ] / 100 ) )
			aLiquido[ i ] -= aResult[ i ]
		EndIf
	Next j
	If cPeriodo == 'M'
		aResult[ i ] /= 12
	EndIf

Next i

Return aResult

//-------------------------------------------------------------------
/*/{Protheus.doc}Degressiva
Saldos Decrescentes
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function Degressiva(cMoedaATF, cPeriodo, nMes, aCotaM, aValores, nLinha )
Local aVlrOrig		:= aClone(aValores[1])
Local aVlrAcum		:= aClone(aValores[2])
Local aVlrAmpl		:= aClone(aValores[3])
Local aVlrCAcm		:= aClone(aValores[4])
Local aVlrCda		:= aClone(aValores[5])
Local aVlDepr		:= AtfMultMoe(,,{|x| 0})
Local aCotas		:= AF012CDegres(cMoedaATF, cPeriodo, nMes)
Local nI			:= 0						//Contador - Auxiliar
Local nVlAtivo		:= 0
Local nDeprAcum	:= 0
Local nDif			:= 0
Local nQuantas 	:= AtfMoedas()

For nI := 1 To nQuantas

	//Saldo de depreciação acumulada na moeda i --------------------
	nDeprAcum := aVlrAcum[nI]
	nDeprAcum += Af012GetSldAcel( Alltrim(Str(nI)), nLinha )

	If nI == 1

		nDeprAcum += aVlrCda[1] //Este campo é tratado apenas na moeda 1
	Endif

	//Valor Total do Ativo na moeda i ------------------------------
	nVlAtivo := aVlrOrig[nI,1]
	nVlAtivo += aVlrAmpl[nI]

	If nI == 1
		nVlAtivo += aVlrCAcm[1]	//Este campo é tratado apenas na moeda 1
	Endif

	//--------------------------------------------------------------

	If Abs( nDeprAcum ) < Abs( nVlAtivo )

		aVlDepr[nI] := Round( aCotas[nI], aVlrOrig[nI,2] )

		nDif := Abs( nVlAtivo ) - ( Abs( aValDepr[2] ) + Abs( nDeprAcum ) )

		If Round( nDif, aVlrOrig[nI,2] ) <= 0
			aVlDepr[nI] := nVlAtivo - nDeprAcum
		Endif
	Endif

next nI

AtfMultMoe(,, {|x| aCotaM[x] := aCotaDepr[x] })

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF012X3Titulo
Titulo de campo
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function ATF012X3Titulo(cCampo)

Local cRet		:= ""

Local aAreaSX3	:= SX3->(GetArea())

Default cCampo := ReadVar()

If Valtype(cCampo) == "C"
	SX3->(DbSetOrder(2))
	SX3->(DbSeek(cCampo))
	cRet := SX3->(X3TITULO())
Endif

RestArea(aAreaSX3)
Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ExcQr
Seleção da exclusão em lote

@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function AF012ExcQr()
Local aArea			:= GetArea()
Local aStru			:= SN1->(DBSTRUCT())	//Estrutura da Tabela SN1 - Ativos
Local aColumns		:= {}					//Array com as colunas a serem apresentadas
Local nX			:= 0
Local cArqTrab		:= ""
Local cCodIni		:= mv_par01
Local cCodFim		:= mv_par02
Local cItemIni		:= mv_par03
Local cItemFim		:= mv_par04
Local cDataIni		:= DTOS(mv_par05)
Local cDataFim		:= DTOS(mv_par06)
Local cGrupoIni		:= mv_par07
Local cGrupoFim		:= mv_par08
Local cQuery		:= ""

cQuery += "SELECT "
For nX:= 1 to Len(aStru)
	cQuery += aStru[nX,1]+", "
Next
cQuery += "R_E_C_N_O_ RECNO "
cQuery += " FROM "+	RetSqlName("SN1") + " SN1 "
If lIsRussia
	cQuery += " INNER JOIN ("
	cQuery += " SELECT DISTINCT A.N4_CBASE, A.N4_ITEM "
	cQuery += " FROM " + RetSqlName("SN4") + " A"
	cQuery += " WHERE A.n4_ocorr = '05' AND A.D_E_L_E_T_ = ' '"
	cQuery += " EXCEPT"
	cQuery += " SELECT DISTINCT B.N4_CBASE,  B.N4_ITEM  "
	cQuery += " FROM " + RetSqlName("SN4") + " B"
	cQuery += " WHERE B.N4_OCORR <> '05' AND B.D_E_L_E_T_ = ' ') C"
	cQuery += " ON SN1.N1_CBASE = C.N4_CBASE AND SN1.N1_ITEM = C.N4_ITEM "
EndIf
cQuery += " WHERE N1_FILIAL = '" + xFilial("SN1") + "' "
cQuery += " AND N1_CBASE   Between '" + cCodIni   + "' AND '" + cCodFim   + "' "
cQuery += " AND N1_ITEM    Between '" + cItemIni  + "' AND '" + cItemFim  + "' "
cQuery += " AND N1_AQUISIC Between '" + cDataIni  + "' AND '" + cDataFim  + "' "
cQuery += " AND N1_GRUPO   Between '" + cGrupoIni + "' AND '" + cGrupoFim + "' "
cQuery += " AND N1_BAIXA  = ' ' "
cQuery += " AND N1_STATUS NOT IN ('2','3') "
If lIsRussia
	cQuery += " AND SN1.D_E_L_E_T_ = ' ' "
Else
	cQuery += " AND D_E_L_E_T_ = ' ' "
Endif
cQuery += " ORDER BY "+ SqlOrder(SN1->(IndexKey()))

cChave		:= SN1->(IndexKey())
Aadd(aStru, {"RECNO","N",10,0})

If _oATFA0122 <> Nil
	_oATFA0122:Delete()
	_oATFA0122 := Nil
Endif

cArqTrab := GetNextAlias()

_oATFA0122 := FWTemporaryTable():New( cArqTrab )
_oATFA0122:SetFields(aStru)
_oATFA0122:AddIndex("1", {"N1_FILIAL","N1_CBASE","N1_ITEM"})

//------------------
//Criação da tabela temporaria
//------------------
_oATFA0122:Create()

Processa({||SqlToTrb(cQuery, aStru, cArqTrab)})	// Cria arquivo temporario

DbSetOrder(0) // Fica na ordem da query

//Define as colunas a serem apresentadas na markbrowse
For nX := 1 To Len(aStru)
	If	aStru[nX][1] $ "N1_CBASE|N1_ITEM|N1_QUANTD|N1_AQUISIC|N1_DESCRIC"
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
		aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
		aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
		aColumns[Len(aColumns)]:SetPicture(PesqPict("SN1",aStru[nX][1]))
	EndIf
Next nX

RestArea(aArea)

Return({cArqTrab,aColumns})

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012VExc
Valida a possibilidade de se excluir um imobilizado
@author pequim
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF012VExc(lHelp,lLote)
Local aArea 	:= GetArea()
Local lAtfa460  := IsInCallStack("ATFA460") .or. IsInCallStack("F460DELPRV")
Local cQuery	:= ""
Local cChaveSNN := ""
Local lRet		:= .T.
Local nSaveSx8Len := GetSx8Len()

Default lHelp		:= .T.
Default lLote		:= .T.

If ExistBlock("AF012EXC")
	lRet:= ExecBlock("AF012EXC",.F.,.F.)
EndIf

//Não Altera bens Bloqueados
If SN1->N1_STATUS $ '2/3'
	If lHelp
		Help(" ",1,"AF010BLOQ")
		lRet := .F.
	EndIf
EndIf

If ATFXVerPrj(SN1->N1_CBASE,SN1->N1_ITEM, lHelp ) .and. !lAtfa460
	lRet := .F.
EndIf

//Não exclui bens relacionados a Planejamento de Aquisição.
dbSelectArea("SNN")
cChaveSNN:=IndexKey(2)
If AllTrim(cChaveSNN) == "NN_FILIAL+NN_CODEFTV+NN_ITMEFTV+NN_CODIGO+NN_ITEM"
	dbSetOrder( 2 )
	If MsSeek(xFilial("SNN")+SN1->N1_CBASE+SN1->N1_ITEM)
		If lHelp
			Help(" ",1,"AF012PLAT")	//"Este Ativo esta associado a um Planejamento de Aquisição e não pode ser excluido."
		Endif
		lRet := .F.
	EndIf
EndIf

dbSelectArea("SN1")
//Não exclui bens relacionados a controle de provisão
If !Empty(SN1->N1_PROVIS) .and. !lAtfa460
	If lHelp
		Help(" ",1,"AF012PRV") //'Este Ativo esta associado a controle de provisao e não pode ser excluido.'
	Endif
	lRet := .F.
EndIf

//Não exclui bens relacionados a Base instalada (SIGATEC)
If lRet .And. AliasInDic("AA3")
	If Select("TRBAA3") > 0
		DbSelectArea("TRBAA3")
		dbCloseArea()
	Endif

	cQuery := "SELECT COUNT(*) RECAA3 FROM "
	cQuery += RetSqlName("AA3") + " AA3 "
	cQuery += " WHERE "
	cQuery += "AA3_FILIAL = '"+xFilial("AA3")+"' AND "
	cQuery += "AA3_CBASE = '" + SN1->N1_CBASE + "' AND "
	cQuery += "AA3.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRBAA3",.F.,.T.)

	If TRBAA3->RECAA3 > 0
		lRet := .F.
		If lHelp
			Help(" ",1,"AF010BASE") // Este Ativo esta associado a base instalada, e não pode ser excluido.
		Endif
	Endif
	TRBAA3->(dbCloseArea())
EndIf

//Verifica se o ativo foi gerado a partir de um custo de emprestimo
If lRet .and. AFVCustEmp(SN1->N1_CBASE,SN1->N1_ITEM,lHelp)
	lRet := .F.
EndIf

//Nao permite a exclusão de bens com CIAP associado.
dbSelectArea("SF9")
dbSetOrder(1)
If lRet .AND. (!Empty(SN1->N1_CODCIAP) ) .AND. ( MsSeek(xFilial("SF9")+SN1->N1_CODCIAP) )
	If !IsBlind()
		lRet := MsgYesNo(STR0111 + SN1->N1_CODCIAP,STR0112)//"O Bem possui um CIAP associado deseja Continuar a exclusão ?"##"Atenção"
	Else
		lRet := .F.
	Endif
Endif

If lRet .and. SN1->N1_FILIAL != xFilial("SN1")
	If lHelp
		HELP(" ",1,"A000FI")
	Endif
	lRet  := .F.
	xRet := .T.
Endif

//Nao permite exclusao de bem cadastrado via SIGAMNT
If lRet .And. !IsInCallStack( "AF060ExcAu" )
	ST9->(dbSetOrder(1))
	IF ST9->(dbSeek(xFilial()+SN1->N1_CBASE))
		If lHelp
			Help(" ",1,"AF012EXAMNT")//'Este Ativo esta associado a um bem cadastrado no SIGAMNT.'
		Endif
		lRet  := .F.
		xRet := .T.
	Endif
Endif

//Verifica se o bem possui AVP apropriado
//Neste caso, o bem não podera ser excluido, mas apenas baixado
If lRet
	FNF->(dbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
	IF FNF->(dbSeek(xFilial("FNF")+SN1->(N1_CBASE+N1_ITEM)+'2'+'1'))
		Help(" ",1,"AF012EXAVP") //'Este Ativo possui movimentos de aproppriação AVP e não poderá ser excluido.'
		lRet  := .F.
		xRet := .T.
	Endif
Endif

//Verifica se o bem foi gerado por constituição de provisão
If lRet .and. Alltrim(SN1->N1_ORIGEM) == 'ATFA460' .and. !lAtfa460
	If lHelp
		Help(" ",1,"AF012460E") //'Este ativo foi gerado a partir do processo de constituição de provisão. Este tipo de ativo somente poderá ser cancelado a partir do processo que o gerou'
	Endif
	lRet  := .F.
	xRet := .T.
Endif

//Verificacao de possibilidade de deleção
If lRet .and. !AF012AVLDL("SN3",,lHelp)
	If !lLote
		While GetSx8Len() > nSaveSx8Len
			RollBackSX8()
		EndDo
	Endif
	lRet  := .F.
	xRet := .T.
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012ExcMa
Exclusao dos imobilizados selecionados

@author pequim

@since 28/10/2013
@version 1.0
/*/
//---------------------------------------------------------------------
Function AF012ExcMa(nOpcao)

Local aArea			:= GetArea()

If nOpcao == 1
	(cAliasMrk)->(dbGoTop())

   	BEGIN TRANSACTION

		While (cAliasMrk)->(!Eof())

			If !EMPTY((cAliasMrk)->(N1_OK))

				SN1->(dbGoto((cAliasMrk)->RECNO))

				AF012ExcAu(SN1->N1_CBASE, SN1->N1_ITEM)

			EndIf

			(cAliasMrk)->(DbSkip())
		EndDo

	END TRANSACTION

EndIf

oMrkBrowse:GetOwner():End()

RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012ExcAu
Rotina automatica para exclusao dos imobilizados selecionados
@author pequim
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF012ExcAu(cCBase,cItem)
Local aArea := GetArea()
Local aCab := {}
Local aItens := {}
Local aParam := {}
Local lRet := .T.

//Controle de rotina automatica
Private lMsErroAuto		:= .F.
Private lMsHelpAuto		:= .T.
Private lAutoErrNoFile	:= .F.

aAdd( aParam, {"MV_PAR01", 2} )
aAdd( aParam, {"MV_PAR02", 1} )
aAdd( aParam, {"MV_PAR03", 2} )

AAdd(aCab,{"N1_CBASE"  	, cCBase			,NIL})
AAdd(aCab,{"N1_ITEM"   	, cItem				,NIL})

MSExecAuto({|x,y,z,w| Atfa012(x,y,z,w)},aCab,aItens,5,aParam)

If lMsErroAuto
	lMsErroAuto := .F.
	DisarmTransaction()
	lRet := .F.

	cFileLog := NomeAutoLog()
	cPath := ""
	If !Empty(cFileLog) .And. !lRet
		MostraErro(cPath,cFileLog)
	Endif
EndIf

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AutRot
Rotina automatica que faz a gravação dos dados na SN3 e SN1.
@author William Matos Gundim Junior
@since  10/02/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AutRot(xCab,xItens,nOpcAuto,aParam,aPadPCO,aRateio,aRecBaixa,aCTB)
Local cLog := ''
Local lRet := .T.
Local nX := 1
Local nY := 1
Local nBase := aScan(xCab, {|x| AllTrim(x[1]) == "N1_CBASE"})
Local nItem := aScan(xCab, {|x| AllTrim(x[1]) == "N1_ITEM" })
Local oSN1		:= Nil
Local oSN3		:= Nil
Local lClaLote	:= IsInCallStack("AF240Lote") //Se a rotina foi chamada atraves da classificacao em lote

DEFAULT aPadPco		:= {}
DEFAULT aRateio		:= {}
DEFAULT aRecBaixa		:= {}
DEFAULT aCTB			:= {}

dbSelectArea('SN1')

__lAtfAuto 	:= .T.
__aAutoItens	:= xItens

If nOpcAuto == MODEL_OPERATION_DELETE .OR. nOpcAuto == MODEL_OPERATION_UPDATE
	If !lClaLote
		DbSetOrder(1)
		lRet := DbSeek(xFilial('SN1') + xCab[nBase,2] + If(nItem > 0, xCab[nItem,2] , ''))
	EndIf
EndIf
//xCab - Master | xItens - Detail
If lRet .AND. xCab <> Nil
	If __oModelAut == Nil
		__oModelAut := FWLoadModel('ATFA012')
	EndIf
	__oModelAut:SetOperation(nOpcAuto)  // 3 - Inclusão | 4 - Alteração | 5 - Exclusão
	__oModelAut:Activate()
	oSN1 := __oModelAut:GetModel('SN1MASTER')
	oSN3 := __oModelAut:GetModel('SN3DETAIL')
	If nOpcAuto == MODEL_OPERATION_INSERT .Or. nOpcAuto == MODEL_OPERATION_UPDATE .Or. lClaLote
		For nX := 1 To Len(xCab)
			If oSN1:CanSetValue(xCab[nX,1])
				oSN1:SetValue(xCab[nX,1], xCab[nX,2])
			ElseIf xCab[nX,1] == "N1_AQUISIC" .And. lClaLote
			//Se for classificação em lote força salvar data de aquisição
				oSN1:LoadValue(xCab[nX,1], xCab[nX,2])
			EndIf
		Next nX
	EndIf

	If xItens <> Nil
		For nX := 1 To Len(xItens)

			nPosSeq	 	:= aScan(xItens[nX],		{|x| AllTrim(x[1]) == "N3_SEQ"})

			If IsInCallStack("AF012ExClas")
				If !oSN3:SeekLine(	{{"N3_SEQ",xItens[nX,nPosSeq,2] } }	)
					lRet := .F.
					Help("", "")
				Else
					If xItens[nX,Len(xItens[nX]),1] == "AUTDELETA"
						If  xItens[nX,Len(xItens[nX]),2] == "S"
							oSN3:DeleteLine()
						EndIf
					EndIf
				EndIF
			Else
				if 	nPosSeq > 0
					If !oSN3:SeekLine(	{{"N3_SEQ",xItens[nX,nPosSeq,2] } }	)

						 oSN3:AddLine()
						 oSN3:GoLine(Len(oSN3:aCols))
					EndIf
				Else
					If nX <> 1
						oSN3:AddLine()
						oSN3:GoLine(Len(oSN3:aCols))
					EndIf
					oSN3:SetValue("N3_SEQ", STRZero(nX,3) )
				EndIf

				If xItens[nX,Len(xItens[nX]),1] == "AUTDELETA"
					If  xItens[nX,Len(xItens[nX]),2] == "S"
						oSN3:DeleteLine()
					EndIf
				else
					For nY := 1 To Len(xItens[nX])
						If oSN3:CanSetValue(xItens[nX, nY, 1])
							oSN3:SetValue(xItens[nX, nY,1], xItens[nX,nY,2])
						ElseIf  lClaLote .And. xItens[nX, nY, 1] $ ("N3_DINDEPR|N3_AQUISIC")
						//Se for classificação em lote força salvar data de aquisição e data de inicio da depreciação
							oSN3:LoadValue(xItens[nX, nY,1], xItens[nX,nY,2])
						EndIf
					Next nY
					cGrupo := oSN1:GetValue("N1_GRUPO")
					If !Empty(cGrupo)
						A012SNGCTB(oSN3,cGrupo,.F.)
					EndIf
				EndIf
			EndIf

		Next nX

	EndIf

	If __oModelAut:VldData()
		__aCTB := aCTB
		__oModelAut:CommitData()
		aCTB	:= {__nHdlPrv,__nTotal,__cArqCtb,__cLoteATF}
	Else
		aLog := __oModelAut:GetErrorMessage()
		For nX := 1 to Len(aLog)
			If !Empty(aLog[nX])
				cLog += Alltrim(aLog[nX]) + CRLF
			EndIf
		Next nX
		lMsErroAuto := .T.
		AutoGRLog(cLog)
		lRet := .F.
	EndIf

	__oModelAut:DeActivate()
Else
	If !lClaLote
		lMsErroAuto := .T.
		AutoGRLog(STR0028)
	EndIf
EndIf

__lAtfAuto 	:= .F.
__aAutoItens	:= Nil


Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012DLAT
Atualiza arquivos após exclusão
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012DLAT(cAlias1, lCprova,lMostra,lContab,aCIAP,aRateio,lAglut)
Local aArea := { Alias(), IndexOrd() }
Local lPadrao := .F.
Local cPadrao
Local cTipoImob := ""
Local cTipoCorr := ""
Local aRecAtf  := {}
Local aValorMoed
Local aValDepr	:= {}
Local cPadAnt	:= ""
Local lPadAnt
Local lAtClDepr := .F.
Local lCancTrans := FWIsInCallStack("AF060ExcAu") //A Contabilizacao do Cancelamento da Transferencia e executada na rotina ATFA060
Local lIntMnt	:= GetMv("MV_NGMNTAT") $ "1#3"
Local cBase		:= ""
//Integração
Local lIntATFA12 := FindFunction("GETROTINTEG") .And. FindFunction("FwHasEAI") .And. FWHasEAI("ATFA012",.T.,,.T.)
Local cTypesNM	:= IIF(lIsRussia,"|" + AtfNValMod({1,2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - main and recoverable model
Local lAutomato := IsBlind() //Para execuções sem tela, Robo, Exec
Local oModel 	:= FWModelActive()
Local cBmcontr  := IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , oModel:GetValue('SN1MASTER','N1_BMCONTR'),"")
Local dDataSld  := CtoD("")
Default aCIAP	:= {}
Default aRateio := {}
Default cAlias1 := 'SN3'
Default lAglut  := .F.

lCprova := If(lCprova == nil, .F. , lCprova)
lMostra := If(lMostra == nil, .F. , lMostra)
lContab := If(lContab == nil .Or. lCancTrans, .F. , lContab)

If  ExistBlock("AF010DEL")
	ExecBlock("AF010DEL",.F.,.F.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da Prote‡„o Via TTS                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Begin Transaction

dbSelectArea(cAlias1)
dbSeek( xFilial(cAlias1) + SN1->N1_CBASE + SN1->N1_ITEM )
While !EOF() .AND. SN3->N3_FILIAL+SN3->N3_CBASE+SN3->N3_ITEM == xFilial(cAlias1)+SN1->N1_CBASE+SN1->N1_ITEM

	dbSelectArea(cAlias1)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera‡„o de lancamentos Contabeis                          ³
	//³ Devera' ser gerado de acordo com o tipo de ativo cadastra-³
	//³ do.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cPadrao := AF012AQPAD(SN3->N3_TIPO,.T.)

	lPadrao := VerPadrao(cPadrao)

	If lContab
		IF lPadrao
			If __nHdlPrv > 0
				lCprova := .T.
			EndIf

			IF !lCprova
				lCprova := .T.
				__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
			EndIf
			If __nHdlPrv > 0
				__nTotal += DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf)
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Saldos do Ativo          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	lAtClDepr := AtClssVer(SN1->N1_PATRIM)
	If lAtClDepr .OR. Empty(SN1->N1_PATRIM)
		cTipoImob := If(SN3->N3_TIPO $ "02|05","3","1")
		cTipoCorr := "6"
	ElseIf SN1->N1_PATRIM $ "CSA"
		cTipoImob := "A"
		cTipoCorr := "O"
	Else
		cTipoImob := "B"
		cTipoCorr := "6"
	EndIf

	dDataSld := SN1->N1_AQUISIC
	If lCancTrans   //se for cancelamento de transferencia pega data da transferencia
		dDataSld := FNR->FNR_DATA
		cTipoImob := "9"   //N5_TIPO = 9 eh transferencia entre filiais (destino)
	EndIf

	dbSelectArea( "SN3" )
	// Pela implanta‡„o
	If !SN3->N3_TIPO $ "07, 08, 09"
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		aValorMoed := AtfMultMoe("SN3","N3_VORIG")
		ATFSaldo(	SN3->N3_CCONTAB,dDataSld,cTipoImob, SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3 ,;
		SN3->N3_VORIG4,SN3->N3_VORIG5 ,"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
		ATFSaldo(	SN3->N3_CCONTAB,dDataSld,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
	Endif
	// Pelo calculo mensal
	// *******************************
	// Controle de multiplas moedas  *
	// *******************************
	aValorMoed := AtfMultMoe(,,{|x| If(x=1,SN3->N3_VRCACM1,0) })
	ATFSaldo(	SN3->N3_CCORREC,dDataSld,cTipoCorr, SN3->N3_VRCACM1,0,0,0,0 ,;
	"-",,SN3->N3_SUBCCOR,,SN3->N3_CLVLCOR,SN3->N3_CCCORR,"2", aValorMoed )

	lAtClDepr := AtClssVer(SN1->N1_PATRIM)

	If lAtClDepr .OR. Empty(SN1->N1_PATRIM)
		// Pelo calculo mensal
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se for conta de Capital social, nÆo lan‡a contra-partida da corre‡Æo monet ria. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		// *******************************
		// Controle de multiplas moedas  *
		// *******************************
		aValorMoed := AtfMultMoe("SN3","N3_VRDACM")
		cTipoImob := If( !SN3->N3_TIPO $ ("08|09|10|12|14|50|51|52|53|54" + cTypesNM), "4", If(SN3->N3_TIPO $ ("10|12|14|50|51|52|53|54" + cTypesNM),"Y",If(SN3->N3_TIPO=="09","L","K")))
		If lCancTrans   //se for cancelamento de transferencia pega data da transferencia
			cTipoImob := "9" //N5_TIPO = 9 eh transferencia entre filiais (destino)
			ATFSaldo(	SN3->N3_CDEPREC,dDataSld,cTipoImob, SN3->N3_VRDACM1,SN3->N3_VRDACM2,SN3->N3_VRDACM3 ,;
							SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"3", aValorMoed )
		EndIf
		ATFSaldo(	SN3->N3_CCDEPR ,dDataSld,cTipoImob, SN3->N3_VRDACM1,SN3->N3_VRDACM2,SN3->N3_VRDACM3 ,;
		SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )

		aValorMoed := AtfMultMoe(,,{|x| if(x=1,SN3->N3_VRCDA1,0) })

		ATFSaldo(	SN3->N3_CDESP  ,dDataSld,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCDES,,SN3->N3_CLVLDES,SN3->N3_CCCDES,"5", aValorMoed )

		aValorMoed := AtfMultMoe(,,{|x| if(x=1,SN3->N3_VRCDA1,0) })

		ATFSaldo(	SN3->N3_CCDEPR ,dDataSld,"7", SN3->N3_VRCDA1,0,0,0,0 ,;
		"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )

	End
	//Acrescentado Por Fernando Radu Muscalu em 08/06/11
	If AFXVerRat()

		If Alltrim(SN3->N3_CRIDEPR) == "03" .AND. Alltrim(SN3->N3_RATEIO) == "1" .AND. !Empty(SN3->N3_CODRAT)

			aValDepr := AtfMultMoe(,,{|x| SN3->&( If( x > 9,"N3_VRDAC","N3_VRDACM") + Alltrim(Str(x)) ) })

			If __nHdlPrv <= 0
				If __lContabiliza .AND. VerPadrao("828") //ESTORNO CALCULO DE DEPRECIACAO: RATEIO DE DESPESAS
					__nHdlPrv := 	HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
				Endif
			Endif

			ATFRTMOV(	SN3->N3_FILIAL,;
			SN3->N3_CBASE,;
			SN3->N3_ITEM,;
			SN3->N3_TIPO,;
			SN3->N3_SEQ,;
			SN4->N4_DATA,;
			SN4->N4_IDMOV,;
			aValDepr,;
			__lContabiliza,;
			"2",;
			__nHdlPrv,;
			__cLoteATF,;
			@__nTotal,;
			,;
			FunName(),;
			"828",;
			__lContabiliza )

			If __nTotal > 0
				lCprova := .T.
			Endif

		Endif
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Registro Movimenta‡„o      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SN4")
	SN4->(DbSetOrder(1))
	dbSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO)
	cChave := xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO
	While !Eof() .And. SN4->N4_FILIAL+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO == cChave

		If SN4->N4_OCORR == "09"
	        nRecno := SN4->(Recno())
			Af251DelSn4(xFilial("SN4")+SN4->N4_CBASE+SN4->N4_ITEM+SN4->N4_TIPO+DtoS(SN4->N4_DATA), SN4->N4_CODBAIX,, { "09", "" },.T.)
        	DbGoTo(nRecno)
   		Else
			If lIntMnt .And. FindFunction("A550VLDCAN") .AND. SN4->N4_OCORR == '04' .And. SN4->N4_TIPOCNT == '1'  .And. !Empty(SN1->N1_CODBEM)
				nRecno := SN4->(Recno())
				If SN3->N3_CBASE <> cBase
					aRet := A550VLDCAN(SN1->N1_CODBEM, SN1->N1_CBASE, SN4->N4_DATA, SN4->N4_HORA, SN4->N4_FILORIG, SN4->N4_FILIAL,.F.)
					If !aRet[1]
						cLogErro := aRet[2]
						DisarmTransaction()
						Break
					EndIf
					cBase := SN3->N3_CBASE
				EndIf
				DbGoTo(nRecno)
			EndIf
			Reclock("SN4",.F.,.T.)
			dbDelete()
			FkCommit()
   		EndIf

		//grava em array os recnos utilizados para integracao com PCO
		Pco_aRecno(aRecAtf, "SN4", 3)  //exclusao
		dbSkip()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Descricoes Analiticas³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SN2")
	dbSeek( xFilial("SN2")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO )
	cChave := xFilial("SN2")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO
	While !Eof() .and. SN2->N2_FILIAL+SN2->N2_CBASE+SN2->N2_ITEM+SN2->N2_TIPO == cChave
		Reclock("SN2" ,.F.,.T.)
		dbDelete()
		FkCommit()
		dbSkip()
	End

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui apontamento de estimativa inicial de produção	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc $ "ARG|BRA|COS"
		dbSelectArea("FNA")
		dbSetOrder(2)		//FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD+DTOS(FNA_DATA)
		dbGoTop()
		If FNA->(MsSeek(xFilial("FNA")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)))
			While FNA->(!EoF()) .And.;
				FNA->(FNA_FILIAL+FNA_CBASE+FNA_ITEM+FNA_TIPO+FNA_SEQ+FNA_SEQREA+FNA_TPSALD) == SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_SEQ+N3_SEQREAV+N3_TPSALDO)
				RecLock("FNA",.F.)

				//Salva o LP anterior
				cPadAnt := cPadrao
				lPadAnt := lPadrao

				Do Case
					Case FNA->FNA_OCORR == "P0"
						cPadrao := "875"		//Estorno de apontamento de estimativa de produção
					Case FNA->FNA_OCORR == "P1"
						cPadrao := "876"		//Estorno de apontamento de revisão de estimativa de produção
					Case FNA->FNA_OCORR == "P2"
						cPadrao := "877"		//Estorno de apontamento de produção
					Case FNA->FNA_OCORR == "P3"
						cPadrao := "878"		//Estorno de apontamento de encerramento de produção
					Case FNA->FNA_OCORR == "P4"
						cPadrao := "879"		//Estorno de apontamento de complemento de produção
				EndCase

				lPadrao := VerPadrao(cPadrao)

				If __nHdlPrv <= 0
					__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
				EndIf

				If lPadrao .And. __nHdlPrv > 0
					__nTotal += DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf)
				EndIf

				//Restaura o LP anterior
				cPadrao := cPadAnt
				lPadrao := lPadAnt

				dbDelete()
				MsUnlock()
				FNA->(dbSkip())
			EndDo
		EndIf
	EndIf

	If AFXVerRat()
		If SN3->N3_RATEIO == "1"
			//alterado por Fernando Radu Muscalu em 01/11/2011
			//Estava gerando duplicidades de rateios no array aRateio
			If aScan(aRateio,{|x| alltrim(x[1]) == alltrim(SN3->N3_CODRAT) }) == 0
				aAdd(aRateio,{SN3->N3_CODRAT})
			EndIf
		Endif
	EndIf
	//AVP
	//Verifica se o bem possui AVP constituido
	//Neste caso, o bem podera ser excluido
	If  SN3->N3_TIPO == '14'
		FNF->(DbSetOrder(4)) //FNF_FILIAL+FNF_CBASE+FNF_ITEM+FNF_TPMOV+FNF_STATUS
		If FNF->(DbSeek(XFilial("FNF")+SN1->(N1_CBASE+N1_ITEM)+'1'))

			While !(FNF->(EOF())) .AND. FNF->(FNF_FILIAL+FNF_CBASE+FNF_ITEM) == ;
				XFilial("FNF")+SN1->(N1_CBASE+N1_ITEM)

				If FNF->FNF_TPMOV == '1' //Exclusao de Constituicao
					RecLock("FNF",.F.)
					//Movimento de constituicao ativo e contabilizado
					If FNF->FNF_STATUS == '1' .and. !Empty(FNF->FNF_DTCONT)

						//Salva o LP anterior
						cPadAnt := cPadrao
						lPadAnt := lPadrao

						cPadrao	:= "867" //Estorno de constituição de AVP
						lPadrao 	:= VerPadrao(cPadrao)

						If __nHdlPrv <= 0
							__nHdlPrv := HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
							lCprova := .T.
						Else
							lCprova := .T.
						EndIf

						If lPadrao .And. __nHdlPrv > 0
							__nTotal += DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf)
						EndIf

						//Restaura o LP anterior
						cPadrao := cPadAnt
						lPadrao := lPadAnt

					Endif

					cBaseAVP    := FNF->FNF_CBASE
					cItemAVP    := FNF->FNF_ITEM
					cTpSLDAVP   := FNF->FNF_TPSALD

					//Excluo o registro
					FNF->(dbDelete())
					FNF->(MsUnlock())

					AFGrvPrjAvp(cBaseAVP,cItemAVP,'10',cTpSLDAVP)

				ElseIf FNF->FNF_TPMOV $ '9|A' //Exclusao de Ajuste de AVP por Revisão
					RecLock("FNF",.F.)
					FNF->(DbDelete())
					FNF->(MsUnlock())
				EndIf

			FNF->(DbSkip())
			EndDo
		Endif
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta Ativos Imobilizados        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SN3" )
	RecLock( "SN3" ,.F.,.T.)
	dbDelete()
	FkCommit()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui a amarracao com os conhecimentos SN3 - LAUDO          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsDocument( Alias(), RecNo(), 2, , 3 )

	//grava em array os recnos utilizados para integracao com PCO
	Pco_aRecno(aRecAtf, "SN3", 3)  //inclusao

	dbSeek( xFilial("SN1")+SN1->N1_CBASE+SN1->N1_ITEM )
EndDo
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Rateio			          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cPaisLoc $ "ARG|BRA|COS" .AND. Len(aRateio) > 0
	If !AF011DEL(aRateio,.T.)//AF011GRAVA(5, aRateio) //mudar para a chamada da funcao - AF011DEL(aRateio,.t.)
		Help(" ",1,"AF012EEXR") //"Erro ao excluir rateio"
	EndIf

	aRateio := {}
Endif

//	IF nCnt != 0
// ****************** CIAP *********************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza Cadastro do CIAP                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( !Empty(SN1->N1_CODCIAP) ) .And. cBmcontr <> '1'
	dbSelectArea("SF9")
	dbSetOrder(1)
	If ( dbSeek(xFilial("SF9")+SN1->N1_CODCIAP) )
		RecLock("SF9")
		SF9->F9_ICMIMOB -= SN1->N1_ICMSAPR
	EndIf
EndIf
If cBmcontr <> '1'
	AADD(aCIAP,{SN1->N1_CODCIAP})
EndIf
// ****************** CIAP *********************

//AVP2
//Excluo os bens de provisao relacionados ao bem de orcamento com AVP parcela
dbSelectArea( "SN1" )
If SN1->N1_TPAVP == '2' .AND. SN1->N1_PATRIM = 'O'
	AF012CANPrv(SN1->N1_CBASE,SN1->N1_ITEM)
Endif

// Exclui os registros da tabela de responsável SND.
ATF012SND(SN1->N1_CBASE,SN1->N1_ITEM)

dbSelectArea( "SN1" )
RecLock( "SN1", .F., .T.)
dbDelete( )

/* -----------------------------------------
	Se for exclusão de um ativo
   ----------------------------------------- */
If (FWIsInCallStack("AF012AltEx") .Or. lAutomato) .and. lCProva .And. lContab .And. __nTotal > 0 .And. __lCTBFIM
	RodaProva(__nHdlPrv,__nTotal)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Envia para Lancamento Contabil                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cA100Incl(__cArqCtb,__nHdlPrv,3,__cLoteAtf,lMostra,lAglut,,,, @aFlagCTB)
End

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Exclui a amarracao com os conhecimentos SN1                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsDocument( Alias(), RecNo(), 2, , 3 )

//grava em array os recnos utilizados para integracao com PCO
Pco_aRecno(aRecAtf, "SN1", 3)  //exclusao

//Chamada da função FwIntegDef para realizar a exclusão em casos que exista integração EAI.
If lIntATFA12
	FwIntegDef("ATFA012")
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Final  da Prote‡„o Via TTS                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
End Transaction

//integracao com modulo de planejamento e controle orcamentario
If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"
	Atf_IntPco(aRecAtf)
EndIf

dbSelectArea( aArea[1] )
dbSetOrder( aArea[2] )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012CANPrv
Cancelamento da provisão de avp

@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CANPrv(cBaseSup,cItemSup)
Local lRet := .T.
Local aArea := GetArea()
Local aRecFNO := {}
Default cBaseSup := ""
Default cItemSup := ""

If Empty(cBaseSup) .or. Empty(cItemSup)
	lRet := .F.
Endif

//Posiciono no SN4
//Incluo os novo bens (se houve depreciacao)
If lRet

	dbSelectArea("FNO")
	FNO->(dbSetOrder(3)) //Filial + BaseSup + ItemSup
	If FNO->(MsSeek(xFilial("FNO")+cBaseSup+cItemSup))

		//Enquanto for o mesmo ATIVO SUPERIOR
		While !( FNO->(Eof()) ) .AND. xFilial("FNO")+cBaseSup+cItemSup == FNO->(FNO_FILIAL+FNO_BASESP+FNO_ITEMSP)

			SN1->(dbSetOrder(1))
			If SN1->(MsSeek(xFilial("SN1")+FNO->(FNO_CBASE+FNO_ITEM)))
				//Obtenho os recnos dos filhos para posterior exclusao
				aadd(aRecFNO,{ FNO->(Recno()) } )
			Endif
			FNO->(dbSkip())
		Enddo
	Endif

	//Estorno o provisorio
	If Len(aRecFNO) > 0
		MsgRun(STR0058,"",{|| AF460EstPrv(aRecFNO,1,.T.) })//"Convertendo Bem Aguarde"
	Endif

	pergunte("AFA012",.F.)
	AF012PerAut()

Endif

RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc}AF012Texto
Recupera um texto do arquivo de descrição extendidas
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Texto(cChave)
cTexto:=""
dbSelectArea("SN2")
If dbSeek(cChave)
	nAnterior:=0
	While !Eof() .AND. SN2->N2_FILIAL+SN2->N2_CBASE+SN2->N2_ITEM==cChave
		If SN2->N2_SEQ = SN3->N3_SEQ
			cTexto += Iif(!Empty(SN2->N2_HISTOR),SN2->N2_HISTOR,"") + Chr(13) + Chr(10)
			nAnterior++
			dbSkip( )
			Loop
		Endif
		dbSkip()
	End
EndIf

Return cTexto

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012EST
Gatilho que realiza a busca na SN2 para preencher a descrição estendida
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012EST()
Local aArea			:= GetArea()
Local oModel		:= FwModelActive()
Local nOperation	:= oModel:GetOperation()
Local cDesc			:= ''
Local cChave		:= xFilial('SN2') + SN1->N1_CBASE + SN1->N1_ITEM + SN3->N3_TIPO + SN3->N3_SEQ


If INCLUI
	If ExistBlock("AF10DESC")
		cDesc := ExecBlock("AF10DESC",.F.,.F., {cDesc})
	Endif
Endif

If nOperation <> MODEL_OPERATION_INSERT
	SN2->(DBSetOrder(2))
	SN2->(DBSeek(cChave))
	While SN2->(!EOF()) .And. cChave == SN2->( N2_FILIAL + N2_CBASE + N2_ITEM + N2_TIPO + N2_SEQ)
		cDesc += IIF(lIsRussia,Alltrim(SN2->N2_HISTOR),SN2->N2_HISTOR)
		SN2->(DBSkip())
	EndDo
EndIf

RestArea(aArea)

Return cDesc

//-------------------------------------------------------------------
/*/{Protheus.doc}ProcBlqDesb
Bloqueia/Desbloqueia bens, atualizando campo N1_STATUS
@author William Matos Gundim Junior
@since  09/01/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function ProcBlqDesb(cAliasTrb,lAutomato)
Local aArea     := GetArea()
Local nTam 		:= Len(SN1->N1_STATUS)
Local cAtivo	:= ""
Local cCabec	:= ""
Local cTexto	:= ""
Local lExitSNL  := AliasInDic("SNL")
Local cStatusLoc:= ""
Local cLocBloq  := ""
Local lRet		:= .T.
Local cEmInvent	:= ""
Local nTamFil	:= 0
Local nTamCBase	:= 0
Local nTamItem		:= 0
Local nTamDesc		:= 0

Default lAutomato := .F.

//Monta o cabeçalho com os nomes dos campos chave da tabela SN1
dbSelectArea("SX3")
SX3->(dbSetOrder(2))		//X3_CAMPO
SX3->(dbSeek("N1_FILIAL"))
nTamFil := Max(TamSX3("N1_FILIAL")[1],Len(X3Titulo()))
cCabec += Padr(X3Titulo(),nTamFil)
SX3->(dbSeek("N1_CBASE"))
nTamCBase := Max(TamSX3("N1_CBASE")[1],Len(X3Titulo()))
cCabec += " / " + Padr(X3Titulo(),nTamCBase)
SX3->(dbSeek("N1_ITEM"))
nTamItem := Max(TamSX3("N1_ITEM")[1],Len(X3Titulo()))
cCabec += " / " + Padr(X3Titulo(),nTamItem)
SX3->(dbSeek("N1_DESCRIC"))
nTamDesc := Max(TamSX3("N1_DESCRIC")[1],Len(X3Titulo()))
cCabec += " / " + Padr(X3Titulo(),nTamDesc)

While (cAliasTrb)->(!Eof())
	SN1->(MsGoto((cAliasTrb)->RECNOSN1))
	lRet := .T.

	dbSelectArea("SN8")
	SN8->(dbSetOrder(1))
	SN8->(dbSeek(xFilial("SN8")+SN1->N1_CBASE+SN1->N1_ITEM))
	While SN8->(!Eof()) .And. SN8->(xFilial("SN8")+N8_CBASE+N8_ITEM) == SN1->(N1_FILIAL+N1_CBASE+N1_ITEM)
		If Empty(SN8->N8_DTAJUST)
			lRet := .F.
			cEmInvent += Padr(SN1->N1_FILIAL,nTamFil) + " / " + Padr(SN1->N1_CBASE,nTamCBase) + " / " + Padr(SN1->N1_ITEM,nTamItem) + " / " + Padr(SN1->N1_DESCRIC,nTamDesc) + CRLF
			Exit
		EndIf
		SN8->(DbSkip())
	EndDo

	If lRet .And. lExitSNL
    	cStatusLoc := GetAdvFval("SNL","NL_BLOQ",xFilial("SNL") + SN1->N1_LOCAL ,1,"")
    	If Alltrim(cStatusLoc) == '1'
    		cLocBloq += Padr(SN1->N1_FILIAL,nTamFil) + " / " + Padr(SN1->N1_CBASE,nTamCBase) + " / " + Padr(SN1->N1_ITEM,nTamItem) + " / " + Padr(SN1->N1_DESCRIC,nTamDesc) + " / " + "" + SN1->N1_LOCAL + CRLF
    		(cAliasTrb)->(DbSkip())
    		Loop
    	EndIf
	EndIf

	If lRet
		RecLock("SN1",.F.)
		SN1->N1_STATUS := Str(If(mv_par09==1,1,2),nTam)
		SN1->N1_DTBLOQ := If(mv_par09==1,CTOD(""),dDataBase)
		cAtivo += Padr(SN1->N1_FILIAL,nTamFil) + " / " + Padr(SN1->N1_CBASE,nTamCBase) + " / " + Padr(SN1->N1_ITEM,nTamItem) + " / " + Padr(SN1->N1_DESCRIC,nTamDesc) + CRLF
		MsUnlock()
	EndIf

	(cAliasTrb)->(DbSkip())
EndDo

If !lAutomato
	//Resumo do bloqueio/desbloqueio de bens
	DEFINE FONT oFont NAME "Mono AS" SIZE 005,012
	DEFINE MSDIALOG oDlg TITLE STR0055 From 003,000 TO 340,417 PIXEL		//"Bloqueio / desbloqueio de bens"

	If Empty(cAtivo)
		cTexto += AllTrim(STR0028) + " " + IIF(MV_PAR09 == 2, STR0030, STR0029) + CRLF		//"Não foram encontrados bens de acordo com os parâmetros informados"##"ou os bens já encontram-se bloqueados/desbloqueados."
		cTexto += CRLF + IIF(MV_PAR09 == 2, STR0032, STR0031)		//"Nenhum bem foi bloqueado/desbloqueado."
	Else
		cTexto += IIF(MV_PAR09 == 2, STR0034, STR0033) + CRLF		//"Os seguintes bens foram bloqueados/desbloqueados:"
		cTexto += CRLF
		cTexto += cCabec + CRLF
	EndIf

	cTexto += cAtivo + CRLF

	If !Empty(cEmInvent)
		cTexto += STR0052 + CRLF //" Os seguintes ativos não foram efetivados porque estão em processo de inventário. "
		cTexto += cEmInvent + CRLF
	EndIf

	If !Empty(cLocBloq)
		cTexto += STR0051 + CRLF //" Os seguintes ativos não foram efetivados porque os locais cadastrados estão bloqueados "
		cTexto += cLocBloq + CRLF
	EndIf

	@ 005,005 GET oMemo VAR cTexto MEMO SIZE 200,145 OF oDlg PIXEL
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont := oFont
	DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlg:End() ENABLE OF oDlg PIXEL //Apaga
	ACTIVATE MSDIALOG oDlg CENTER
EndIf

RestArea(aArea)

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} F012Struct
Monta estrutura do Model

@author pequim
@since  15/04/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function F012Struct(cAlias)
Local __nQuantas	:= AtfMoedas()
Local i				:= 0
Local oStruct 		:= FWFormStruct( 1, cAlias, /*bAvalCampo*/, /*lViewUsado*/ )

If cAlias == "SN3"
	oStruct:AddField('AVP Planejad' ,'AVP Planejad'  ,'N3AVPPLAN', 'N', 16, 2, , , ,.F., , .F., .F., .T., , )
	oStruct:AddField('AVP Realiz'   ,'AVP Realiz'    ,'N3AVPREAL', 'N', 16, 2, , , ,.F., , .F., .F., .T., , )
	If !lIsRussia
		oStruct:AddField(SX3->(RetTitle("N3_BAIXA")),SX3->(RetTitle("N3_BAIXA")),"N3_BAIXA","C",TamSX3("N3_BAIXA")[1],TamSX3("N3_BAIXA")[2],,,,.F.,,.F.,.F.,.F.,,)
	EndIf
EndIf

//--------------------------------------------------
//Implementado bloqueio dos campos de valores
// Esta alteração não deve ocorrer, pois podem
// impactar nos processos de depreciação do bem
//--------------------------------------------------
If __lAltera
	If lAFA012
		ExecBlock("ATFA012" ,.F.,.F.,{oStruct, 'FORMSTRUCT', 'SN3DETAIL' })
	Else
		For i:= 1 to __nQuantas
			cMoed := Alltrim(Str(i))
			oStruct:SetProperty('N3_VORIG'  + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) })   //Valor Original do Bem
			oStruct:SetProperty(Iif(i<10,'N3_VRDBAL','N3_VRDBA') + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da depreciação referente ao último balanço na Moeda.
			oStruct:SetProperty(Iif(i<10,'N3_VRDMES','N3_VRDME') + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da última depreciaçâo na Moeda
			oStruct:SetProperty(Iif(i<10,'N3_VRCACM','N3_VRCAC') + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da Correção acumulada do Bem
			oStruct:SetProperty(Iif(i<10,'N3_VRDACM','N3_VRDAC') + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da Depreciação Acumulada na Moeda.
			oStruct:SetProperty(Iif(i<10,'N3_TXDEPR','N3_TXDEP') + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Taxa Anual de Depreciação
			oStruct:SetProperty(Iif(i<10,'N3_AMPLIA','N3_AMPLI') + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da ampliação na Moeda

			oStruct:SetProperty(Iif(i<10,'N3_VRDMES','N3_VRDME') + cMoed,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da última depreciaçâo na Moeda
		Next

		oStruct:SetProperty('N3_VRCBAL1',MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da correção referente ao último balanço.
		oStruct:SetProperty('N3_VRCMES1',MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da última correção.
		oStruct:SetProperty('N3_VRCDM1' ,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da última correção.
		oStruct:SetProperty('N3_VRCDB1' ,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da última correção.
		oStruct:SetProperty('N3_VRCDA1' ,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Valor da última correção.
		If lIsRussia
			oStruct:SetProperty('N3_TPSALDO' ,MODEL_FIELD_WHEN, {|| Af12Bloq(oStruct) }) //Balance type
		Endif
	EndIf
EndIf

Return oStruct


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF12aExcId ºAutor ³Microsiga           º Data ³  02/29/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Realiza a exclusao dos movimentos do SN4 do bem quando      º±±
±±º          ³com o mesmo ID                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AF12aExcId(cBase,cItem,cTipo,cSeqReav,cSeq,cIdMov,aRecAtf)
Local aArea    := GetArea()
Local aAreaSN4 := SN4->(GetArea())

SN4->(dbSetOrder(9))//N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ+DTOS(N4_DATA)+N4_OCORR

If SN4->(MsSeek(xFilial("SN4") + cBase + cItem + cTipo + cSeqReav + cSeq ))
	While SN4->(!EOF()) .And. SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_SEQREAV+N4_SEQ) == xFilial("SN4") + cBase + cItem + cTipo + cSeqReav + cSeq
		If Alltrim(SN4->N4_IDMOV) == Alltrim(cIdMov)
			RecLock("SN4",.F.)
			dbDelete()
			FkCommit()
			msUnlock()
			//grava em array os recnos utilizados para integracao com PCO
			Pco_aRecno(aRecAtf, "SN4", 3)  //exclusao
		EndIf
		SN4->(dbSkip())
	EndDo
EndIf

RestArea(aAreaSN4)
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012Static
Inicializa as variaveis static

@author caique.ferreira
@since  05/05/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function AF012Static()

If !IsInCallStack("AF012Multi")
	__nQtMulti := 0
	__lMultiATF:= .F.
Else
	__lMultiATF:= .T.
EndIf

If __nQtMulti == 0 .And. !FWIsInCallStack("AF012Cpy") //Nao limpa o array de rateio no processo de copia, pois ha tratamento na funcao AF012Cpy
	__aRateio	:= {}
EndIf
__aHeadAvp		:= {}
__aColsAvp		:= {}
__aHeadMrg		:= {}
__aColsMrg		:= {}
__lClassifica	:= IsInCallStack("ATFA240")
__cGrupoFNG := ""
__lAmplia		:= FWIsInCallStack("ATFA155")

pergunte("AFA012",.F.)
AF012PerAut()
If Type("MV_PAR05") == "N"
	__lContabiliza := MV_PAR05 == 1
Else
	__lContabiliza := .T.
EndIf

If Empty(__aCTB)
	__nHdlPrv		:= 0
	__nTotal		:= 0
	__cArqCtb		:= ""
	__lCTBFIM		:= .T.
	__cLoteAtf		:= LoteCont("ATF")
Else
	__nHdlPrv		:= IIF(Len(__aCTB) >= 1,__aCTB[1] , 0)
	__cArqCtb		:= IIF(Len(__aCTB) >= 3,__aCTB[3] , "")
	__cLoteAtf		:= IIF(Len(__aCTB) >= 4,__aCTB[4] , LoteCont("ATF"))
	__lCTBFIM		:= .F.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012Inclu
Inclusão de ativos contábeis

@author caique.ferreira
@since  05/05/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Inclu()
Local cTitulo			:= ""
Local cPrograma		:= ""
Local nOperation		:= 0
Local lRet				:= .T.
Local lMostra			:= .F.
Local lContab			:= .F.
Local lAglut			:= .F.

pergunte("AFA012",.F.)
AF012PerAut()

SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

__lIncluMan	:= .T.
lMostra		:= MV_PAR01 == 1
lContab		:= MV_PAR05 == 1
lAglut			:= MV_PAR06 == 1

If lContab
	cLoteCTB	:= LoteCont("ATF")
	nTotCTB	:= 0
	cTrbCTB	:= ""
	nHandle	:= HeadProva(cLoteCTB,"ATFA012",Substr(cUsername,1,6),@cTrbCTB)
	__aCtb		:= Array(4)
	__aCtb[1]	:= nHandle
	__aCtb[2]	:= nTotCTB
	__aCtb[3]	:= cTrbCTB
	__aCtb[4]	:= cLoteCTB
EndIf

//Validacao para o bloquei do processo
If lRet .And. !CtbValiDt(,dDatabase,.F.,,,{"ATF001"},)
	Help(" ",1,"CTBBLOQ",,STR0135,1,0)//CTBBLOQ - "Calendário Contábil Bloqueado. Verfique o processo."
	lRet := .F.
EndIf

If lRet
	cTitulo      	:= IIF(lIsRussia, STR0171, STR0061) //'Inclusão'
	cPrograma    	:= 'ATFA012'
	nOperation   	:= MODEL_OPERATION_INSERT
	oModel       	:= FWLoadModel( cPrograma )
	nRet         	:= FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, /*bCloseOnOk*/ ,{ |oModel|AF012ATDOK(oModel)}/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
	__lIncluMan  	:= .F.

	If nRet == 0 // OK
		MsgRun( STR0114 ,, {|| AF012Multi() } ) //"Gerando fichas de ativos ..."
		If __nHdlPrv > 0 .And. ( __nTotal > 0 )
			RodaProva(__nHdlPrv, __nTotal)
			cA100Incl(__cArqCtb,__nHdlPrv,3,__cLoteAtf,lMostra,lAglut,,,, @aFlagCTB)
			aFlagCTB := {}
			RECLOCK("SN4",.F.)
				SN4->N4_LA := "S"
			SN4->(MSUNLOCK())

		Endif
	EndIf
EndIf

__aCtb := {}
AF012Static()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012AltExc
Verifica o status do bem e nao permite a alteracao ou exclusao se ele estiver bloqueado.

@author Marcello
@since  23/07/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AltEx(cAlias,nReg,nOpc)
Local nRet  := 0
Local lAltr := .F.
Local cPrograma := ""
Local cBaseAltEx  := ""
Local cItemAltEx  := ""
Local lBmcontr 	  := IIf(SN1->(FieldPos("N1_BMCONTR")) > 0 , .T., .F.)

cPrograma    := 'ATFA012'
oModel       := FWLoadModel( cPrograma )

oModel:SetOperation( nOpc )
oModel:Activate()

If !Empty( nOpc )
	lAltr := ( nOpc == 4 )
EndIf

If lBmcontr
	If len(CompDoBemC(SN1->N1_CBASE,SN1->N1_ITEM)) > 0 .And. (SN1->N1_STATUS == '0') .And. (SN1->N1_BMCONTR == '1') .And. nOPc == 5
		Help("",1,"AF251BMCON",,STR0182,1,0)//Bem em Construção possui amarrações. Exclua os componentes para logo excluir o bem
		Return
	EndIf
EndIf

If lIsRussia .and. !lAltr .and. !RU01XFN001() // RU01XFN001_CheckN4OCORR
	Help(" ",1,"AFDELL_RUS")
ElseIf !lIsRussia .and. SN1->N1_STATUS $ '2|3'		/* nao permite alterar ou excluir se o bem estiver bloqueado. */
	Help(" ",1,"AF010BLOQ")
ElseIf !AtfEstaBxd(,,lAltr) .And. ATFRespVl(,,lAltr)
	__lAltera := lAltr
	cBaseAltEx := SN1->N1_CBASE
	cItemAltEx := SN1->N1_ITEM
	If lIsRussia
		nRet := FWExecView(Iif(lAltr, STR0072, ""),"ATFA012",nOpc, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
	Else
		nRet := FWExecView("","ATFA012",If(lAltr,MODEL_OPERATION_UPDATE,MODEL_OPERATION_DELETE), /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/)
	Endif
	__lAltera := .F.
	If nRet == 0
		AF012CanTer(oModel,,nOpc,cBaseAltEx,cItemAltEx)
		If !lAltr
			AF012CanRes(oModel,,nOpc,cBaseAltEx,cItemAltEx)
		Endif
	EndIf
	If lIsRussia .and. lAltr .AND. (SN1->N1_STATUS == '0')
		RU01XFN002(oModel) ///RU01XFN002_updateSN4accounts
	Endif
Endif

Return()



//-------------------------------------------------------------------
/*/{Protheus.doc} AF012Cpy
Realiza a cópia do Ativo

@author caique.ferreira
@since  05/05/2014
@version 12
/*/
//-------------------------------------------------------------------

Function AF012Cpy(cAlias,nReg,nOpc,aAut012Cpy)

Local cBase			:= SN1->N1_CBASE
Local cItem			:= SN1->N1_ITEM
Local cTitulo			:= ""
Local cPrograma		:= ""
Local nOperation		:= 0
Local nX				:= 0
Local oAux 			:= Nil
Local oStruct			:= Nil
Local aAux				:= {}
Local nLin 			:= 1
Local nAux          AS NUMERIC
Local nRecSn1		AS NUMERIC
Local nQtMoed		AS NUMERIC
Local cNValM1		AS CHARACTER
Local aNValM1		AS ARRAY
Local aNValMA		AS ARRAY
Local aNumber		AS ARRAY
Local aModerVal		AS ARRAY

Default aAut012Cpy := {}

aNumber		:= {}
nQtMoed		:= AtfMoedas()
aModerVal	:= Array(nQtMoed)
Afill(aModerVal,0)

SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

If SN1->(MsSeek(xFilial("SN1") + cBase + cItem ))
	__lCopia		:= .T.
	__lIncluMan	:= .T.
	__aRateio		:= {}
	cTitulo      := STR0065 //"Cópia"
	cPrograma    := 'ATFA012'
	nOperation   := MODEL_OPERATION_INSERT

	oModel       := FWLoadModel( cPrograma )
	oModel:SetOperation( nOperation ) // Inclusão
	oModel:Activate(.T.) // Ativa o modelo com os dados posicionados

	oAux		:= oModel:GetModel("SN3DETAIL")
	oStruct	:= oAux:GetStruct()
	aAux		:= oStruct:GetFields()

	//-- JRJ 20171005#Ai
	If (ExistBlock("AF012COPY"))
		lRetPE	:= ExecBlock("AF012COPY",.F.,.F.)
		If VALTYPE(lRetPE) <> "L"
			lRetPE := .T.
		EndIf
	EndIf

	If lIsRussia .And. ! Empty(SN1->N1_GRUPO)
        oModel:SetValue("SN1MASTER", "N1_GRUPO", SN1->N1_GRUPO)
    ElseIf lIsRussia
		cBase	:= InFieldSN1(oModel, "N1_CBASE", .T.)
		cItem	:= InFieldSN1(oModel, "N1_ITEM", .T.)
	EndIf

	If lIsRussia .And. lRetPE
		oModel:LoadValue("SN1MASTER","N1_CHAPA"		,SN1->N1_CHAPA)
		oModel:LoadValue("SN1MASTER","N1_FORNEC"	,SN1->N1_FORNEC)
		oModel:LoadValue("SN1MASTER","N1_LOJA"		,SN1->N1_LOJA)
		oModel:LoadValue("SN1MASTER","N1_NSERIE"	,SN1->N1_NSERIE)
		oModel:LoadValue("SN1MASTER","N1_NFISCAL"	,SN1->N1_NFISCAL)
	ElseIf lIsRussia
    	If ! Empty(SN1->N1_GRUPO)
			nRecSN1	:= SN1->(Recno())
            aNumber	:= RU01NEXTNU(SN1->N1_GRUPO)
			cBase	:= aNumber[1]
			cItem	:= aNumber[2]
			SN1->(dbGoto(nRecSN1))
        Else
    		cBase	:= InFieldSN1(oModel, "N1_CBASE", .T.)
    		cItem	:= InFieldSN1(oModel, "N1_ITEM", .T.)
        EndIf
       	oModel:LoadValue("SN1MASTER","N1_CBASE"		,IIf(Empty(cBase), "", cBase))
    	oModel:LoadValue("SN1MASTER","N1_ITEM" 		,IIf(Empty(cItem), "", cItem))
    	oModel:LoadValue("SN1MASTER","N1_CHAPA"		,IIf(Empty(cBase), "", cBase))
		oModel:LoadValue("SN1MASTER","N1_CODBAR"	,IIf(Empty(cBase) .AND. Empty(cItem), "", Alltrim(cBase) + "-" + AllTrim(cItem)))
	ElseIf lRetPE
		oModel:LoadValue("SN1MASTER","N1_CBASE"		,cBase)
		oModel:LoadValue("SN1MASTER","N1_ITEM" 		,cItem)
		oModel:LoadValue("SN1MASTER","N1_CHAPA"		,SN1->N1_CHAPA)
		oModel:LoadValue("SN1MASTER","N1_FORNEC"	,SN1->N1_FORNEC)
		oModel:LoadValue("SN1MASTER","N1_LOJA"		,SN1->N1_LOJA)
		oModel:LoadValue("SN1MASTER","N1_NSERIE"	,SN1->N1_NSERIE)
		oModel:LoadValue("SN1MASTER","N1_NFISCAL"	,SN1->N1_NFISCAL)
	Else
		oModel:LoadValue("SN1MASTER","N1_CBASE"		,"")
		oModel:LoadValue("SN1MASTER","N1_ITEM" 		,"")
		oModel:LoadValue("SN1MASTER","N1_CHAPA"		,"")
	EndIf

	If lIsRussia
		oModel:LoadValue("SN1MASTER","N1_AQUISIC"	,dDatabase)
	EndIf
	If ! lIsRussia
		SX3->(DbSetOrder(2))
		SX3->( dbSeek( 'N1_ITEM' ), .F.)
		If !Empty(SX3->X3_RELACAO)
			cItem := InitPad(SX3->X3_RELACAO)
			oModel:LoadValue("SN1MASTER","N1_ITEM" 		,cItem)
		Endif

		SX3->( dbSeek( 'N1_CBASE' ), .F.)
		If !Empty(SX3->X3_RELACAO)
			cBase := InitPad(SX3->X3_RELACAO)
			oModel:LoadValue("SN1MASTER","N1_CBASE" 		,cBase)
		Endif
	EndIf

	pergunte("AFA012",.F.)
	AF012PerAut()
	If MV_PAR03 == 2 // Cópia Sem Acumulados
		For nLin := 1 to Len(oAux:aCols)
			oAux:SetLine(nLin)
			For nX := 1 to Len(aAux)
				If "N3_DINDEPR" $  aAux[nX,3]
					oAux:LoadValue( aAux[nX,3] , dDatabase )
				//Zera os campos acumulados
				ElseIf "N3_VRDACM" $  aAux[nX,3] .Or. "N3_VRCACM" $  aAux[nX,3] .Or. "N3_VRCBAL" $  aAux[nX,3] .Or. "N3_VRDBAL" $  aAux[nX,3] .Or. "N3_VRCMES" $  aAux[nX,3] .Or. "N3_VRDMES" $  aAux[nX,3]
					oAux:aCols[nLIn][nX] := 0
				ElseIf lIsRussia .AND. "N3_OPER" $  aAux[nX,3]
					oAux:aCols[nLIn][nX] := "2"
				ElseIf lIsRussia .AND. "N3_AQUISIC" $  aAux[nX,3]
					oAux:aCols[nLIn][nX] := dDatabase
				EndIf
			Next nX
		Next nLin
		oAux:SetLine(1)
	EndIf

    // Recreate types based on revaluation models
    If lIsRussia
		cNValM1 := AtfNValMod({1, 2, 3}, "|")
		aNValM1 := Separa(cNValM1, "|", .T.)
        aNValMA := {}
        nLin    := 1
        While nLin < Len(aNValM1)
            aAdd(aNValMA, {;
                aNValM1[nLin],;
                aNValM1[nLin+1],;
                aNValM1[nLin+2];
            })
            nLin    += 3
        EndDo
        For nLin := 1 To oAux:Length()
            If ! Empty(oAux:GetValue("N3_DTBAIXA", nLin))
                oAux:GoLine(nLin)
                oAux:DeleteLine()
            Else
                nAux    := AScan(aNValMA, {|x| AllTrim(oAux:GetValue("N3_TIPO", nLin)) $ x[2] + "|" + x[3]})
                If ! Empty(nAux)
                    oAux:GoLine(nLin)
                    oAux:SetValue("N3_TIPO", aNValMA[nAux, 1])
                EndIf
            EndIf
        Next nLin
		For nLin := 1 To oAux:Length()
			oAux:GoLine(nLin)
			oAux:SetValue("N3_OPER", "2")
			oAux:SetValue("N3_INCOST", 0)
			For nX	:= 1 To nQtMoed
				If nQtMoed > 9
					oAux:SetValue("N3_AMPLI" + Alltrim(Str(nX)),aModerVal[nX])
				Else
					oAux:SetValue("N3_AMPLIA" + Alltrim(Str(nX)),aModerVal[nX])
				EndIf
			Next nX
			oAux:SetValue("N3_DINDEPR",RetDinDepr(dDataBase))
			oAux:SetValue("N3_AQUISIC",dDatabase)
			oAux:SetValue("N3_UUID",RU01UUIDV4())
		Next nLin
    Else
		//-------------------------------------------------------
		// Realiza tratamento para copia do rateio do Ativo (SNV)
		//-------------------------------------------------------
		For nLin := 1 to Len(oAux:aCols)
			oAux:GoLine(nLin)

			If oAux:GetValue("N3_RATEIO") == "1" .And. !Empty(oAux:GetValue("N3_CODRAT"))
				AF012LoadR(@__aRateio,oAux:GetValue("N3_CODRAT"),nLin)

				//-------------------------------------------------------------------------------------------------
				// Limpa o codigo do rateio e a versao para ser gerados novos codigos para o ativo gerado na copia
				//-------------------------------------------------------------------------------------------------
				__aRateio[Len(__aRateio)][1] := "" //Codigo
				__aRateio[Len(__aRateio)][2] := "" //Versao

			EndIf

		Next nLin
		oAux:GoLine(1)
	EndIf

	lMostra		:= MV_PAR01 == 1
	lContab		:= MV_PAR05 == 1
	lAglut			:= MV_PAR06 == 1

	If lContab
		cLoteCTB	:= LoteCont("ATF")
		nTotCTB	:= 0
		cTrbCTB	:= ""
		nHandle	:= HeadProva(cLoteCTB,"ATFA012",Substr(cUsername,1,6),@cTrbCTB)
		__aCtb		:= Array(4)
		__aCtb[1]	:= nHandle
		__aCtb[2]	:= nTotCTB
		__aCtb[3]	:= cTrbCTB
		__aCtb[4]	:= cLoteCTB
	EndIf

	If IsBlind() .And. Len(aAut012Cpy) > 0
		MSExecAuto({|a,b,c| Atfa012(a,b,c)},aAut012Cpy[1],aAut012Cpy[2],3,{})
		nRet := Iif(!lMsErroAuto,0,-1)
	Else
		nRet := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/,oModel)
	EndIf

	oModel:DeActivate()
	__lCopia		:= .F.
	__lIncluMan	:= .F.

	If nRet == 0 // OK
		If !IsBlind()
			MsgRun( STR0114 ,, {|| AF012Multi() } ) //"Gerando fichas de ativos ..."
		Else
			AF012Multi()
		EndIf

		If __nHdlPrv > 0 .And. ( __nTotal > 0 )
			RodaProva(__nHdlPrv, __nTotal)
			cA100Incl(__cArqCtb,__nHdlPrv,3,__cLoteAtf,lMostra,lAglut,,,,@aFlagCTB)
		Endif
	EndIf

EndIf

__aCtb := {}
AF012Static()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012Multi
Realiza a cópia do Ativo

@author caique.ferreira
@since  05/05/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012Multi()
Local aArea			:= GetArea()
Local cBase			:= SN1->N1_CBASE
Local cItem			:= SN1->N1_ITEM
Local cPrograma		:= ""
Local nOperation	:= 0
Local nX			:= 0
Local cChapa		:= ""
Local cItemOri		:= ""
Local nY			:= 0
Local oModelSN3		:= Nil
Local oModelSN1		:= Nil
Local oModel		:= Nil
Local cFornc		:= ""
Local cLoja			:= ""
Local cNSerie		:= ""
Local cNFiscal		:= ""
Local lAf012Copy	:= .f.
Local lContinua		:= .t.
Local nRecno		:= 0

pergunte("AFA012",.F.)
AF012PerAut()

If (ExistBlock("AF012COPY"))

	lAf012Copy	:= ExecBlock("AF012COPY",.F.,.F.)

	If VALTYPE(lAf012Copy) <> "L"
		lAf012Copy := .T.
	EndIf

EndIf

SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

__nQtMulti--
If __nQtMulti > 0
	cItemOri	:= SN1->N1_ITEM
	cChapa		:= SN1->N1_CHAPA
	nOperation	:= MODEL_OPERATION_INSERT
	cPrograma	:= "ATFA012"

	oModel 	:= FWLoadModel( cPrograma )

	oModelSN3:= oModel:GetModel("SN3DETAIL")
	oModelSN1:= oModel:GetModel("SN1MASTER")

	If lAf012Copy //Retorno do PE AF012COPY

		If ( oModelSN1:GetStruct():GetProperty("N1_FORNEC",MODEL_FIELD_OBRIGAT) .And. Empty(SN1->N1_FORNEC) )
			lContinua := .F.
		ElseIf ( oModelSN1:GetStruct():GetProperty("N1_LOJA",MODEL_FIELD_OBRIGAT) .And. Empty(SN1->N1_LOJA) )
			lContinua := .F.
		ElseIf ( oModelSN1:GetStruct():GetProperty("N1_NSERIE",MODEL_FIELD_OBRIGAT) .And. Empty(SN1->N1_NSERIE) )
			lContinua := .F.
		ElseIf ( oModelSN1:GetStruct():GetProperty("N1_NFISCAL",MODEL_FIELD_OBRIGAT) .And. Empty(SN1->N1_NFISCAL) )
			lContinua := .F.
		EndIf

	EndIf

	If ( lContinua )

		cFornc 		:= SN1->N1_FORNEC
		cLoja		:= SN1->N1_LOJA
		cNSerie		:= SN1->N1_NSERIE
		cNFiscal	:= SN1->N1_NFISCAL
		SN1->(MsSeek(xFilial("SN1") + cBase + cItemOri ))
		cChapa := IIf( mv_par02 == 2, Soma1(AllTrim(cChapa)), cChapa)
		cItem 	:= Soma1(AllTrim(cItem))
		nRecno := SN1->(Recno())

		For nX := 1 to __nQtMulti
			While SN1->(MsSeek(xFilial("SN1") + cBase + cItem ))
				cItem 	:= Soma1(AllTrim(cItem))
			EndDo
			SN1->(dbGoto(nRecno))
			oModel:SetOperation( nOperation )	// Inclusão

			oModel:Activate(.T.) 				// Ativa o modelo com os dados posicionados

			oModelSN1:LoadValue("N1_CBASE"	,cBase)
			oModelSN1:LoadValue("N1_ITEM"	,cItem)
			oModelSN1:LoadValue("N1_CHAPA"	,cChapa)
			oModelSN1:LoadValue("N1_FORNEC"	,cFornc)
			oModelSN1:LoadValue("N1_LOJA"	,cLoja)
			oModelSN1:LoadValue("N1_NSERIE"	,cNSerie)
			oModelSN1:LoadValue("N1_NFISCAL",cNFiscal)

			If !Empty(__aRateio)

				For nY := 1 to oModelSN3:Length()
					oModelSN3:SetLine(nY)
					oModelSN3:LoadValue("N3_RATEIO","")
				Next nY

				For nY := 1 to Len(__aRateio)
					__aRateio[nY][1] := ""
					__aRateio[nY][2] := ""
				Next nY
			EndIf

			lGrava := oModel:VldData()

			While ! lGrava

				// limpa erro que ja existe
				oModel:GetErrorMessage(.T.)

				// Se proxima chapa zera aumenta sequencia
				If cChapa > Soma1(AllTrim(cChapa))
					cChapa := "0" + cChapa
				// caso nao seja o ultimo soma1
				Else
					cChapa := Soma1(AllTrim(cChapa))
				EndIf

				// o tamanho da chapa esta maior que o campo, entao para...
				If Len(AllTrim(cChapa)) > TamSX3("N1_CHAPA")[1]
					Exit
				EndIf

				// atualiza chapa
				oModelSN1:LoadValue("N1_CHAPA",cChapa)

				// revalida
				lGrava :=  oModel:VldData()
			EndDo

			// caso seja possivel gravar
			If lGrava
				oModel:CommitData()
			EndIf

			oModel:DeActivate()
			cItem 	:= Soma1(AllTrim(cItem))
			cChapa := IIf( mv_par02 == 2, Soma1(AllTrim(cChapa)), cChapa)
		Next nX

	EndIf

EndIf

__nQtMulti	 := 0

RestArea(aArea)
aSize(aArea,0)
aArea := nil
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012SN2
Grava descrição extendida

@author caique.ferreira
@since  05/05/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function AF012SN2(oModel,nCols,cSeqSn3)
Local aArea		:= GetArea()
Local aAreaSN3	:= SN3->(GetArea())
Local oSN1		:= oModel:GetModel("SN1MASTER")
Local oSN3 		:= oModel:GetModel("SN3DETAIL")
Local cBaseX 	:= ""
Local cItemX 	:= ""
Local cTipoX 	:= ""
Local cDescX	:= ""
Local cSeqSn2   := ""

Default cSeqSn3 := ""

dbSelectArea('SN2')
SN2->(dbSetOrder(2))
SN3->(DbSetOrder(1))

SN3->(dbSeek(cChave))	//Utiliza posicionamento da chave
	cBaseX  := oSN1:GetValue('N1_CBASE')
	cItemX  := oSN1:GetValue('N1_ITEM')
	cTipoX  := oSN3:GetValue('N3_TIPO',nCols)
	cDescX  := oSN3:GetValue('N3_DESCEST',nCols)
	cSeqSn2 := oSN3:GetValue('N3_SEQ',nCols)

	If SX3->( DBSeek( 'N2_HISTOR ' )) .And. AllTrim(SX3->X3_PICTURE)=="@!"
		cDescX:= Upper(cDescX)
	Endif

	lAlt := SN2->(dbSeek( xFilial('SN2') + cBaseX + cItemX + cTipoX + cSeqSn2 ))
	Af160Grav('SN3' , cDescX , lAlt, ,cSeqSn3)
RestArea(aAreaSN3)
RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012AVLDL
Verifica se o Ativo pode ser excluido

@author caique.ferreira
@since  05/05/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012AVLDL(cAlias1, lCompra,lHelp, dDataProc)
Local aArea := { Alias(), IndexOrd() }
Local lREt := .T.
Local nCont := 0
Local nBaixado := 0
Local nSavRecSN3
Local lOk := .F.
Local aAreaSN4 := SN4->(GetArea())
Local lTemDeprec :=  .F.
//Data de Bloqueio da Movimentação - MV_ATFBLQM
Local dDataBloq := GetNewPar("MV_ATFBLQM",CTOD(""))
Default lHelp := .T.
Default dDataProc := SN1->N1_AQUISIC

If ExistBlock("F010VldDel")
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Este PE sera executado em substituicao a rotina de validacao³
	//³da exclusao do ativo. Devera retornar .T. para prosseguir a ³
	//³exclusao, ou .F. caso contrario.                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	*/
	lRet := ExecBlock("F010VldDel",.F.,.F.,{cAlias1, lCompra})

Else
	If FindFunction("NGINTIMOBIL") .And. !FWIsInCallStack("AF060CaTra")
		lRet := NGINTIMOBIL(SN1->N1_CBASE,SN1->N1_ITEM,.T.) // INTEGRACAO NG - VERIFICA SE EXISTE O REGISTRO NAS TABELAS DA NG
	Endif
	If lRet
		lCompra := IIf(lCompra = Nil,.F.,lCompra)
		dbSelectArea(cAlias1)
		dbSetOrder( 1 )

		If dbSeek(xFilial("SN1")+SN1->N1_CBASE+SN1->N1_ITEM)
			nSavRecSN3 := Recno()
			// Se houver depreciacao acumulada ou
			// o bem estiver baixado, nao permite a exclusao.
			lTemDeprec := !Empty( SN1->N1_BAIXA) .Or. IIf(SN3->N3_VRDACM1 != 0,ATFV012RAC(SN3->N3_CBASE, SN3->N3_ITEM),.F.)
			//---------------------------------------------------------------------------------------------------------------
			// Caso seja a rotina de cancelamento de transferência, permite, pois a query avalia se o bem já veio depreciado
			// e nao sofreu depreciações na filial destino, permitindo a exclusão e retorno pra filial origem
			//----------------------------------------------------------------------------------------------------------------
			If lTemDeprec .And. !IsInCallStack("AF060CaTra") .And. ! RusCheckRevalFunctions()
				If (lHelp,Help(" ",1, "AF010DEL"),)
				lRet := .F.
			EndIf
			If !Empty(dDataBloq) .AND. (dDataProc <= dDataBloq)
				If (lHelp,Help(" ",1,"AF010ABLQM",,STR0118 + DTOC(dDataBloq) ,1,0),) //"A data de aquisição do bem é igual ou menor que a data de bloqueio de movimentação : "
				lRet := .F.
			EndIf
			//Validacao para o bloquei do processo
			If lRet .And. !CtbValiDt(,dDataProc ,.F.,,,{"ATF001"},)
				Help(" ",1,"CTBBLOQ",,STR0135,1,0)//CTBBLOQ - "Calendário Contábil Bloqueado. Verfique o processo."
				lRet := .F.
			EndIf
			If lRet
				While SN3->(!Eof() .And. XFILIAL("SN3")+SN3->N3_CBASE+SN3->N3_ITEM == XFILIAL("SN1")+SN1->N1_CBASE+SN1->N1_ITEM)
					IF Val( SN3->N3_BAIXA ) # 0
						nBaixado++
					EndIf
					nCont++
					SN3->(dbSkip( ))
				EndDo
				SN3->(dbGoto(nSavRecSN3))
				If nCont == 0
					If (lHelp,HELP(" ",1,"AF010NITEM"),)
					lRet := .F.
				EndIf
				If lRet
					If lCompra .And. SN1->N1_STATUS=="1"
						If (lHelp,Help("  ",1,"AF240CLASS"),)
						lRet := .F.
						lOk  := .T.
					EndIf
					dbSelectArea(cAlias1)
					dbSetOrder(1)
					dbGoto(nSavRecSn3)
				EndIf
			EndIf
		EndIf
		If lRet .Or. lOk
			dbSelectArea( aArea[1] )
			dbSetOrder( aArea[2] )
		EndIf
	EndIf
EndIf
//Não Excluir Bem Efetivado pela Rotina ATFA310 se o campo N1_ORIGEM igual "ATFA310" e N1_STATUS = '0' e Rotina que chamou se for diferente de "A310GRVATF"
If lRet .And. SN1->(FieldPos("N1_STATUS")) > 0 .And.  SN1->N1_STATUS = '0'
	If Alltrim(SN1->N1_ORIGEM) == 'ATFA310'
	    If !IsInCallStack("A310GRVATF")
			If (lHelp, Help(" ",1,"AF010EPA",,STR0119,1,0),)	//'Bem planejado somente poderá ser excluido através do estorno da efetivação na rotina de planejamento de ativo (ATFA310)'
			lRet := .F.
		Endif
	EndIf
EndIf
RestArea(aAreaSN4)
Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³AtfVldCpoCfg³ Autor ³ Claudio Donizete Souza³ Data ³ 29.07.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida se o campo eh obrigatorio, conforme configuracao do   ³±±
±±³          ³ grupo de campos                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ ATFA010                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AtfGrv12Cfg(cGrupo, cBase)
Local lAtualiza := .T.

If AliasInDic("SNK").And. SNK->(MsSeek(xFilial("SNK")+cGrupo))
	If "EXECBLOCK" $ Upper(SNK->NK_CBASE) .Or. "U_" $ Upper(SNK->NK_CBASE)
		lAtualiza := .F.
	Endif
	While SNK->NK_FILIAL == xFilial("SNK") .And.;
		SNK->NK_GRUPO == cGrupo
		RecLock("SNK",.F.)
		SNK->NK_UCBASE := cBase
		If lAtualiza
			SNK->NK_CBASE := '"'+Soma1(Alltrim(cBase))+'"'
		Endif
		MsUnlock()
		SNK->(DbSkip())
	End
Endif

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjRetParamºAutor  ³Alvaro Camillo Neto º Data ³  17/12/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ajusta as repostas do aParambox                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ 		                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjRetParam(aRet,aParamBox)
Local nX := 0

If ValType(aRet) == "A" .And. Len(aRet) == Len(aParamBox)
	For nX := 1 To Len(aParamBox)
		If aParamBox[nX][1] == 2 .AND. ValType(aRet[nX]) == "C"
			aRet[nX] := aScan(aParamBox[nX][4],{|x| Alltrim(x) == aRet[nX]})
		Endif
	Next nX
EndIf

Return aRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CarregStruºAutor  ³Ramon Neves         º Data ³  18/11/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta o a Header especifico para a rotina automatica.      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AF010Exec                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CarregStru(cAlias,aStru)
Local aAreaAnt		:= GetArea()
Local cCampoZero	:= "Zero"

Default aStru		:= {}

dbSelectArea("SX3")
dbSetOrder(1)
SX3->(dbSeek(cAlias))

While ! SX3->(Eof()) .And. (SX3->X3_ARQUIVO == cAlias)
	If  X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .Or.;
		Rtrim(X3_CAMPO) == "N3_SEQ" .Or. Rtrim(X3_CAMPO) == "N3_CBASE" .Or. Rtrim(X3_CAMPO) == "N3_ITEM".Or. Rtrim(X3_CAMPO) == "N3_TIPREAV" .Or. Rtrim(X3_CAMPO) == "N3_SEQREAV"
		If cAlias == "SN1"
			If Alltrim(X3_CAMPO) == "N1_CBASE" .Or. Alltrim(X3_CAMPO) == "N1_ITEM"
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,SX3->X3_ARQUIVO ,SX3->X3_CONTEXT})
			EndIF
		Else
			// Alterado para conter parte do nome do campo "N3_VORIG" ou nome do arquivo "SN3" .Procura se o nome finaliza com numeros
			If !( SX3->X3_CAMPO $ "N3_CRIDEPR/N3_CALDEPR")
				cCampoZero := SX3->X3_ARQUIVO
				if Subs(X3_CAMPO, Len(Trim(X3_CAMPO)),1) $ "0123456789"
					cCampoZero := "Zero"
				Endif
				AADD(aStru,{TRIM(X3TITULO()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID ,SX3->X3_USADO ,SX3->X3_TIPO ,cCampoZero ,SX3->X3_CONTEXT})
			EndIf
		EndIf
	EndIf
	SX3->(dbSkip())
EndDo

RestArea(aAreaAnt)

Return aStru

//-------------------------------------------------------------------
/*/{Protheus.doc} AF12CanTer
Exclui o Bem de terceiro caso o usuário cancele a operação ou altere o controle
 de terceiros antes de confirmar

@since  25/07/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CanTer(oModel,lCancela,nOpc,cBaseTer,cItemTer)
Local aArea			:= GetArea()
Local cCbase		:= ""
Local cItem			:= ""
Local cTipCon		:= ""
Local cFilSN		:= ""
Local nOper	 		:= 0

Default oModel		:= FWModelActive()
Default lCancela	:= .F.
Default cBaseTer	:= ""
Default cItemTer	:= ""

If lIsRussia .AND. !oModel:isActive()	//(15/11/18): Fix problem with not active model which return FwExecView
	oModel:Activate()
EndIf
nOper := oModel:GetOperation()

If (nOper == MODEL_OPERATION_INSERT .And. lCancela) .Or. nOper == MODEL_OPERATION_DELETE
	cCBase := oModel:GetValue('SN1MASTER','N1_CBASE')
	If Empty(cBaseTer)
		cBaseTer := cCBase
	EndIf
	cItem := oModel:GetValue('SN1MASTER','N1_ITEM')
	If Empty(cItemTer)
		cItemTer := cItem
	EndIf
	cTipCon := oModel:GetValue('SN1MASTER','N1_TPCTRAT')
	If cTipCon == "2"
		cFilSN := xFilial("SNO")
		SNO->(dbSetOrder(2))	//NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
		If SNO->(dbSeek(cFilSN + cBaseTer + cItemTer))
			While SNO->(!Eof()) .And. SNO->NO_FILIAL == cFilSN .And. SNO->NO_CBASE == cBaseTer .And. SNO->NO_ITEM == cItemTer
				RecLock("SNO",.F.)
				SNO->(DbDelete())
				MsUnLock()
				SNO->(dbSkip())
			EndDo
		EndIf
	Else
		If cTipCon == "3"
			cFilSN := xFilial("SNP")
			SNP->(dbSetOrder(2))	//NP_FILIAL+NP_CBASE+NP_ITEM+NP_CODIGO+NP_SEQ
			If SNP->(dbSeek(cFilSN + cBaseTer + cItemTer))
				While SNP->(!Eof()) .And. SNP->NP_FILIAL == cFilSN .And. SNP->NP_CBASE == cBaseTer .And. SNP->NP_ITEM == cItemTer
					RecLock("SNP",.F.)
					SNP->(DbDelete())
					MsUnLock()
					SNP->(dbSkip())
				EndDo
			EndIf
		EndIf
	Endif
Endif
RestArea(aArea)
Return(.T.)
//-------------------------------------------------------------------
/*/{Protheus.doc} AF012RESP
Rotina de responsável do ativo

@since  25/07/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012RESP(oView)
Local aSaveLines	:= FWSaveRows()
Local cBaseCpy	:= Nil
Local cItemCpy	:= Nil
Local lCopy		:= IsInCallStack("AF012CPY")

If lCopy
	cBaseCpy	:= SN1->N1_CBASE
	cItemCpy	:= SN1->N1_ITEM
EndIf

oView:SetModified(Af190N1xR0(cBaseCpy, cItemCpy))
FWRestRows(aSaveLines)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012CAVTIP
Validação do campo When do campo N3_TIPDEPR para conversao de metodo de depreciação

@since  25/07/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CAVTIP(cTpDepr,nLinha)
Local lRet 			:= .F.
Local nPosN3Tipo 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TIPO" } )
Local nPosN3TpDp 	:= Ascan(aHeader, {|e| Alltrim(e[2]) == "N3_TPDEPR" } )
Local aPosN3TxDp	:= AtfMultPos(aHeader,"N3_TXDEPR")
Local cTipoGer   	:= ''
Local aArea		:= {}
Local aAreaSN0	:= {}
Local nPosTp01	:= 0
Local nI			:= 0
Local cTypes10		:= IIF(lIsRussia,"|" + AtfNValMod({1}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable model
Local cTypes12		:= IIF(lIsRussia,"|" + AtfNValMod({2}, "|"),"") // CAZARINI - 10/04/2017 - If is Russia, add new valuations models - recoverable model

DEFAULT cTpDepr := IIf(nPosN3TpDp>0, aCols[n][nPosN3TpDp], '')
DEFAULT nLinha := n

If nPosN3Tipo>0 .And. nPosN3TpDp>0
	If FindFunction("ATFSALDEPR") .and. !(aCols[nLinha][nPosN3Tipo] $ '|11')
		lRet := ATFSALDEPR(aCols[nLinha][nPosN3Tipo],,IiF("N3_TPDEPR" $ ReadVar(),&(ReadVar()),aCols[nLinha][nPosN3TpDp]))
	Else
		If aCols[nLinha][nPosN3Tipo] $ '01,02'
			cTipoGer := '1,7,8,9'
			If !(cPaisLoc $ "ARG|BRA|COS")
				If nLinha == 1
					aCols[nLinha][nPosN3TpDp] := '1'
					cTpDepr := '1'
				Endif
			EndIf
		ElseIf aCols[nLinha][nPosN3Tipo] $ ('10/12/16/17' + cTypes10 + cTypes12)
			aArea := GetArea()
			aAreaSN0 := SN0->(GetArea())

			dbSelectArea("SN0")

			SN0->(dbSetOrder(1))
			SN0->( MsSeek( xFilial("SN0") + '04' ) )

			Do While !SN0->(Eof()) .And. xFilial("SN0") + '04' == SN0->N0_FILIAL + SN0->N0_TABELA
				cTipoGer += IIf(empty(cTipoGer),'',',') + SN0->N0_CHAVE
				SN0->(dbSkip())
			EndDo

			RestArea(aAreaSN0)
			RestArea(aArea)
		ElseIf aCols[nLinha][nPosN3Tipo] $ '|11'
			nPosTp01	:= aScan(aCols,{|aX| aX[nPosN3Tipo] $ "01"})
			If nPosTp01 > 0
				cTipoGer	:= aCols[nPosTp01][nPosN3TpDp]
			EndIf
		Else
			cTipoGer := '1'
		EndIf
		lRet := cTpDepr $ cTipoGer
		If !lRet
			If aCols[nLinha][nPosN3Tipo] == '11'
				Help(" ",1,"AF010AVTIP",,I18N(STR0088,{AllTrim(RetTitle("N3_TPDEPR"))}),1,0) //'A alteração do campo "#1[Tipo deprec.]#" da ampliação deve ocorrer por meio do tipo de ativo "Depreciação Fiscal".'
			Else
				Help( " ", 1, "AF010TIPDEP",, STR0024, 1, 0 ) // "Esse método de depreciação não é válido para esse tipo de ativo."
			EndIf
		EndIf
	EndIf
EndIf

If lRet .and. aCols[nLinha][nPosN3Tipo] == '01'
	For nI := 1 To Len(aCols)
		If aCols[nI,nPosN3Tipo] == "11"
			aCols[nI,nPosN3TpDp]	:= cTpDepr
		EndIf
	Next nI
EndIf

If lRet .And. (aCols[nLinha][nPosN3Tipo] $ ('10' + cTypes10) ) .And. (cTpDepr == 'A')
	For nI := 1 To Len(aPosN3TxDp)
		aCols[nLinha,aPosN3TxDp[nI]] := 0
	Next nI
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012CVlMax
Validação do valor máximo da depreciação    para conversao de metodo de depreciação

@since  25/07/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CVlMax(nVlMaxDepr)
Local lRet := .T.
Local nMoedaVMax := Iif(Val(GetMv("MV_ATFMDMX",.F.," "))>0, Val(GetMv("MV_ATFMDMX")), Val(cMoedaAtf))
Local cCpoOrig   := "N3_VORIG"+cValToChar(nMoedaVMax)
Local nPosVMOrig := Ascan(aHeader, {|x| Alltrim(x[2]) == Alltrim(cCpoOrig) } )

Default nVlMaxDepr := M->N3_VMXDEPR

If nVlMaxDepr > aCols[n][nPosVMOrig]
	Help( " ", 1, "AF010VMXDEPR",,STR0136, 1, 0 ) // "Valor Máximo de Deprecição não pode ser maior que o valor original na moeda configurada no parametro MV_ATFMDMX "
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012CVlGr
Validação dos campos dos métodos de depreciacao gerencial para conversao de metodo

@since  25/07/2014
@version 12
/*/
//-------------------------------------------------------------------
Function AF012CVlGr(cField)
Local lRet 			:= .F.
Local nPosTpDepr 	:= Ascan(aHeader, {|x| Alltrim(x[2]) == "N3_TPDEPR" } )
Local lAtfctap		:= IIF(GetNewPar("MV_ATFCTAP","0")=="0",.F.,.T.)

DEFAULT cField := ReadVar()

If At("->",cField)>0
	cField := SubStr(cField,At("->",cField)+2,len(cField))
EndIf

If nPosTpDepr>0 .And. !Empty(&(ReadVar()))
	Do Case
		Case aCols[n][nPosTpDepr]=='2'
			lRet := cField $ "N3_PERDEPR,N3_VLSALV1"
		Case aCols[n][nPosTpDepr]=='3'
			lRet := cField $ "N3_PERDEPR"
		Case aCols[n][nPosTpDepr]=='4'
			If lAtfctap
				lRet := cField $ "N3_PRODANO"
			Else
				lRet := cField $ "N3_PRODMES,N3_PRODANO"
			EndIf
		Case aCols[n][nPosTpDepr]=='5'
			If lAtfctap
				lRet := cField $ "N3_PRODANO"
			Else
				lRet := cField $ "N3_PRODMES,N3_PRODANO"
			EndIf
		Case aCols[n][nPosTpDepr]=='6'
			lRet := cField $ "N3_PERDEPR"
		Case aCols[n][nPosTpDepr]=='7'
			lRet := cField $ "N3_VMXDEPR"
		Case aCols[n][nPosTpDepr]=='8'
			lRet := cField $ "N3_PRODANO"
		Case aCols[n][nPosTpDepr]=='9'
			lRet := cField $ "N3_PRODANO"
		Otherwise // =='1'
			lRet := .F.
	EndCase
	If !lRet .And. !IsBlind()
		Help( " ", 1, "AF012FDNTUS") // "Esse campo não é utilizado pelo método de depreciação selecionado, o valor informado não será considerado."
	EndIf
EndIf

/*
1-Linea	2-RedSl	3-SAnos	4-UnPrd	5-HrPrd	6-SDigi	7-LVlMx	8-ExLin	9-ExSld
N3_PERDEPR			   X	   X					   X
N3_VLSALV1			   X
N3_PRODMES							   X	   X
N3_PRODANO							   X	   X						X		X
N3_VMXDEPR													   X
*/
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} A012ATFNovo
Verifica se o tipo do ativo é novo ou é alteração

@since  25/07/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function A012ATFNovo(aAnterior,nRecno)
Local lRet := .F.

lRet := aScan(aAnterior , {|x| x == nRecno }) <= 0

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} A012SNGCTB
Gatilha Valores Referente a Cadastro de Grupo de bens
@author Alvaro Camillo Neto
@since  13/09/2014
@version 12
/*/
//-------------------------------------------------------------------
Static Function A012SNGCTB(oLinha,cGrupo,lApaga)
	Local aArea := GetArea()

	Default cGrupo := ""
	Default lApaga := .T.

	SNG->(DbSetOrder(1))
	If SNG->(dbSeek(xFilial("SNG") + cGrupo))
		//Gatilha Contas Contabeis
		A012SetEnt(oLinha,'CCONTAB',"CT1",lApaga,Iif(lIsRussia,"CCONTA",""))
		A012SetEnt(oLinha,'CDEPREC',"CT1",lApaga,Iif(lIsRussia,"CDEPRE",""))
		A012SetEnt(oLinha,'CCDEPR' ,"CT1",lApaga,Iif(lIsRussia,"CCDEPR",""))
		A012SetEnt(oLinha,'CDESP'  ,"CT1",lApaga,Iif(lIsRussia,"CDESP" ,""))
		A012SetEnt(oLinha,'CCORREC',"CT1",lApaga,Iif(lIsRussia,"CCORRE",""))
		//Gatilha Centro de Custos
		A012SetEnt(oLinha,'CCUSTO', "CTT",lApaga)
		A012SetEnt(oLinha,'CUSTBEM',"CTT",lApaga)
		A012SetEnt(oLinha,'CCDESP', "CTT",lApaga)
		A012SetEnt(oLinha,'CCCDEP', "CTT",lApaga)
		A012SetEnt(oLinha,'CCCDES', "CTT",lApaga)
		A012SetEnt(oLinha,'CCCORR', "CTT",lApaga)
		//Gatilha Item Contabil
		A012SetEnt(oLinha,'SUBCTA', "CTD",lApaga)
		A012SetEnt(oLinha,'SUBCCON',"CTD",lApaga)
		A012SetEnt(oLinha,'SUBCDEP',"CTD",lApaga)
		A012SetEnt(oLinha,'SUBCCDE',"CTD",lApaga)
		A012SetEnt(oLinha,'SUBCDES',"CTD",lApaga)
		A012SetEnt(oLinha,'SUBCCOR',"CTD",lApaga)
		//Gatilha Classe de Valor
		A012SetEnt(oLinha,'CLVLCON',"CTH",lApaga)
		A012SetEnt(oLinha,'CLVLDEP',"CTH",lApaga)
		A012SetEnt(oLinha,'CLVLCDE',"CTH",lApaga)
		A012SetEnt(oLinha,'CLVLDES',"CTH",lApaga)
		A012SetEnt(oLinha,'CLVLCOR',"CTH",lApaga)
		A012SetEnt(oLinha,'CLVL'   ,"CTH",lApaga)
	EndIf
	RestArea(aArea)
Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AtvIsBaixd ³ Autor ³Daniel Mendes ³        Data ³ 29/06/15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Verifica se o ativo esta baixado sem consistir a data, com ³±±
±±³          ³ base na SN1 posicionada ou parâmetro de chave              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ ATFA012                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtfEstaBxd( lHelp , cChave , lAlt )
Local aArea     := {}
Local aAreaSN3  := {}
Local nCnt      := 0
Local nBaixados := 0
Local lRet      := .F.

Default lHelp  := .T.
Default cChave := SN1->N1_FILIAL + SN1->N1_CBASE + SN1->N1_ITEM
Default lAlt   := .T.

aArea    := GetArea()
aAreaSN3 := SN3->( GetArea() )

SN3->( dbSetOrder( 1 ) )
SN3->( dbSeek( cChave ) )

While !SN3->( Eof() ) .And. cChave == SN3->N3_FILIAL + SN3->N3_CBASE + SN3->N3_ITEM
    If SN3->N3_BAIXA <> "0"
        nBaixados ++
    Else
        nCnt ++
    EndIf

    SN3->( dbSkip() )
EndDo

//Nao altera bem totalmente baixado
If nCnt == 0 .And. nBaixados > 0
	If lHelp
		If lAlt
			Help( " " , 1 , "AF010JABAI" )
		Else
			Help( " " , 1 , "AF012DEL" )
		EndIf
	EndIf

	lRet := .T.
EndIf

RestArea( aAreaSN3 )
RestArea( aArea )

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} A012DEPAC
Função chamada do WHEN do campo N3_DINDEPR
1-Não permitir alterar a data de inicio da depreciação
apos o bem já ser depreciado
2-Não permitir que a depreciação inicie antes da data de aquisição

@since  21/10/15
@version 12
/*/
//-------------------------------------------------------------------
Function A012DEPAC(oModel)
Local lRet := .T.
Local oModel 		:= FWModelActive()
Local oModelSN1 := oModel:GetModel("SN1MASTER")
Local oModelSN3	:= oModel:GetModel("SN3DETAIL")
Local aAreaSX3	:= {}
Local cWhen		:= ""

If ALTERA
	//Verefica se existe depreciação para o bem na alteração
	If !Empty(oModelSN3:GetValue("N3_VRDACM1")) .Or.  !Empty(oModelSN3:GetValue("N3_VRDACM2")) .Or.  !Empty(oModelSN3:GetValue("N3_VRDACM3")) ;
	.Or.  !Empty(oModelSN3:GetValue("N3_VRDACM4")) .Or.  !Empty(oModelSN3:GetValue("N3_VRDACM4")) ; //DEPRECIACAO ACUMULADA
	.Or. !Empty(oModelSN3:GetValue("N3_VRDMES1")) .Or.  !Empty(oModelSN3:GetValue("N3_VRDMES2")) .Or.  !Empty(oModelSN3:GetValue("N3_VRDMES3")) ;
	.Or.  !Empty(oModelSN3:GetValue("N3_VRDMES4")) .Or.  !Empty(oModelSN3:GetValue("N3_VRDMES5")) //DEPRECIACAO ACUMULADA MES
	    lRet := .F.
	EndIf
EndIf

If lIsRussia .and. lRet
	aAreaSX3 := SX3->( GetArea() )
	SX3->(DbSetOrder(2))
	SX3->(DbSeek("N3_DINDEPR"))
	cWhen := If(Empty(SX3->X3_WHEN),"(.t.)","(" + AllTrim(SX3->X3_WHEN) + ")")
	SX3->(RestArea(aAreaSX3))

	lRet := &cWhen
Endif

If lRet .And. !Empty(M->N3_DINDEPR) .And.( M->N3_DINDEPR < oModelSN1:GetValue("N1_AQUISIC"))
	MsgAlert(STR0156) // "Data a Depreciação não pode ser superior a data da aquisição do ativo, digite uma data menor ou igual a data da aquisição"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATFRespVl
Validação de responsável pelo bem

@since  07/11/15
@version 12
/*/
//-------------------------------------------------------------------
Static Function ATFRespVl( lHelp , cChave , lAlt )
Local aArea     := {}
Local aAreaSND  := {}
Local lRet      := .T.
Local cResp     := ""

Default lHelp  := .T.
Default cChave := SN1->N1_FILIAL + SN1->N1_CBASE + SN1->N1_ITEM
Default lAlt   := .T.

aArea    := GetArea()
aAreaSND := SND->( GetArea() )

If !lAlt
	SND->( dbSetOrder( 3 ) ) //ND_FILIAL+ND_CBASE+ND_ITEM+ND_SEQUENC
	SND->( dbSeek( cChave ) )

	While !SND->( Eof() ) .And. cChave == SND->(ND_FILIAL+ND_CBASE+ND_ITEM)
		If SND->ND_STATUS == '1'
			cResp := SND->ND_CODRESP
			Exit
		EndIf
		SND->( dbSkip() )
	EndDo

	If !Empty(cResp)
		cNome := Posicione("RD0",1,xFilial("RD0")+cResp,"RD0_NOME")
		If lHelp
			lRet := MsgYesNo(STR0137 + cNome + STR0138 )//"O ativo está com o seguinte participante como responsável: "##" Procede com a operação?"
		Else
			lRet := .F.
		EndIf
	EndIf
EndIf

RestArea( aAreaSND )
RestArea( aArea )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ATF012SND
Realiza a exclusao da tabela SND

@since  07/11/15
@version 12
/*/
//-------------------------------------------------------------------
Static Function ATF012SND(cBase,cItem)
Local aArea		:= GetArea()
Local aAreaSND	:= SND->( GetArea() )
Local cChave		:= xFilial("SND") + cBase + cItem


SND->( dbSetOrder( 3 ) ) //ND_FILIAL+ND_CBASE+ND_ITEM+ND_SEQUENC
If SND->( dbSeek( cChave  ) )
	While !SND->( Eof() ) .And. cChave == SND->(ND_FILIAL+ND_CBASE+ND_ITEM)
		RecLock("SND",.F.)
		SND->(dbDelete())
		MsUnLock()
		SND->( dbSkip() )
	EndDo
EndIf

RestArea( aAreaSND )
RestArea( aArea )


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef

Funcao de integracao com o adapter EAI para envio e recebimento do
cadastro de ativos (SN1, SN3) utilizando o conceito de mensagem unica.

@param   Caracter, cXML, Variavel com conteudo xml para envio/recebimento.
@param   Caracter, cTypeTrans, Tipo de transacao. (Envio/Recebimento)
@param   Caracter, cTypeMsg, Tipo de mensagem. (Business Type, WhoIs, etc)
@param   Caracter, cVersion, Versão da mensagem.

@author  Diego Rodolfo dos Santos
@version P12
@since   11/09/2015
@return  Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio

@obs
O método irá retornar um objeto do tipo TOTVSBusinessEvent caso
o tipo da mensagem seja EAI_BUSINESS_EVENT ou um tipo
TOTVSBusinessRequest caso a mensagem seja do tipo TOTVSBusinessRequest.
O tipo da classe pode ser definido com a função EAI_BUSINESS_REQUEST.
/*/
//-------------------------------------------------------------------

Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion)

Local aReturn := {}

aReturn := ATFI012(cXml, cTypeTrans, cTypeMsg, cVersion )

Return aReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} Af12Bloq
//Verifica se deve bloquear os campos de valores na alteração
//- Sim, quando alterado registro ja existente
//- Não quando incluido novo tipo de ativo

//@since  30/12/2015
//@version 12
/*/
//-------------------------------------------------------------------
Static Function Af12Bloq(oStruct)
Local aArea	:= GetArea()
Local lBloq := .T.

Local oModel	:= FWModelActive()
Local oAux		:= oModel:GetModel( 'SN3DETAIL' )
Local cTIPO		:= oAux:GetValue('N3_TIPO')
Local cStatus	:= ""

If lIsRussia
	dbSelectArea("SN3")
	dbSetOrder( 1 )
	If DbSeek(SN1->N1_FILIAL + SN1->N1_CBASE + SN1->N1_ITEM + cTIPO)
		cStatus := oModel:GetValue('SN1MASTER','N1_STATUS')
		IF Empty(cStatus) .or. cStatus=="0" // allow edit when status == "0-Scheduled"
			lBloq := .T.
		Else
			lBloq := .F.
		Endif
	EndIf
Else
	SN3->(DbSetOrder(1))
	If SN3->(DbSeek(SN1->(N1_FILIAL+N1_CBASE+N1_ITEM)+ ;
		FWFldGet("N3_TIPO")+FWFldGet("N3_BAIXA")+FWFldGet("N3_SEQ")))
		lBloq := .F.
	EndIf
EndIf

RestArea(aArea)

Return lBloq
//-------------------------------------------------------------------
/*/{Protheus.doc} AF012CanRes
Exclui a vinculação do bem com o responsavel no momento da exclusão do bem

@since  26/01/2016
@version 12.7
/*/
//-------------------------------------------------------------------
Function AF012CanRes(oModel,lCancela,nOpc,cBaseTer,cItemTer)
Local aArea			:= GetArea()
Local cCbase		:= ""
Local cItem			:= ""
Local cFilSD		:= ""
Local nOper	 		:= 0

Default oModel		:= FWModelActive()
Default lCancela	:= .F.
Default cBaseTer	:= ""
Default cItemTer	:= ""

If lIsRussia .AND. !oModel:isActive()	//(15/11/18): Fix problem with not active model which return FwExecView
	oModel:Activate()
EndIf
nOper := oModel:GetOperation()

cCBase := oModel:GetValue('SN1MASTER','N1_CBASE')
If Empty(cBaseTer)
	cBaseTer := cCBase
EndIf
cItem := oModel:GetValue('SN1MASTER','N1_ITEM')
If Empty(cItemTer)
	cItemTer := cItem
EndIf
cFilSD := xFilial("SND")
SND->(dbSetOrder(2))	//NO_FILIAL+NO_CBASE+NO_ITEM+NO_CODIGO+NO_SEQ
If SND->(dbSeek(cFilSD + cBaseTer + cItemTer))
	While SND->(!Eof()) .And. SND->ND_FILIAL == cFilSD .And. SND->ND_CBASE == cBaseTer .And. SND->ND_ITEM == cItemTer
		RecLock("SND",.F.)
		SND->(DbDelete())
		MsUnLock()
		SND->(dbSkip())
	EndDo
EndIf
RestArea(aArea)
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} AF12Tpdepr
Validação do tipo de depreciacao

@since  24/04/2017
@version 12.17
/*/
//-------------------------------------------------------------------
Function AF12Tpdepr()
Local lRet := .T.
Local oModel := FWModelActive()

If oModel <> Nil
	(FWFldGet("N3_TPDEPR") == "A", .T.,.F.)
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ACC
Verifica validade de um determinado centro de Custo.
@author Eduardo.FLima
@since  26/07/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function AF012ACC()
Local lRet   := .T.
Local cAlias := Alias( )
Local oModel := FWModelActive()
Local oAux	   := Nil
Local cCampo := Strtran(ReadVar(),"M->","")

If !Empty(&(ReadVar()))
	lRet := CTB105CC()
	If lRet
		If oModel != Nil
			oAux  :=  oModel:GetModel('SN3DETAIL')
			oAux:LoadValue(cCampo ,&(ReadVar())) // Caso seja Centro de Custo reduzido commito no model o valor do CC completo
		EndIf
	Endif
	dbSelectArea( cAlias )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012AITC
Verifica validade de um determinado Item Contabil.
@author Eduardo.FLima
@since  26/07/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function AF012AITC()
Local lRet   := .T.
Local cAlias := Alias( )
Local oModel := FWModelActive()
Local oAux	 := Nil
Local cCampo := Strtran(ReadVar(),"M->","")

If !Empty(&(ReadVar()))
	lRet := CTB105Item()
	If lRet
		If oModel != Nil
			oAux:= oModel:GetModel('SN3DETAIL')
			oAux:LoadValue(cCampo ,&(ReadVar())) // Caso seja Item Contabil reduzido commito no model o valor do Item Contabil completo
		EndIf
	EndIf
	dbSelectArea( cAlias )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}AF012ACVL
Verifica validade de uma determinada Classe de Valor.
@author Eduardo.FLima
@since  26/07/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function AF012ACVL()
Local lRet   := .T.
Local cAlias := Alias( )
Local oModel := FWModelActive()
Local oAux	 := Nil
Local cCampo := Strtran(ReadVar(),"M->","")

If !Empty(&(ReadVar()))
	lRet := CTB105CLVL()
	If lRet
		If oModel != Nil
			oAux:= oModel:GetModel('SN3DETAIL')
			oAux:LoadValue(cCampo ,&(ReadVar())) // Caso seja Classe de Valor reduzida commito no model a Classe de Valor completa
		EndIf
	Endif
	dbSelectArea( cAlias )
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc}A012SetEnt
Carrega valores nas entidades de Conta Contabil\Centro de Custo\Item Contabil\Classe de Valor para gatilhos
@author Eduardo.FLima
@since  27/07/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function A012SetEnt(oLinha,cField,cEnt,lApaga,cFldFNG)
	Local aSaveArea := GetArea()
	Local aSaveEnt  := (cEnt)->(GetArea())
	Local  cRet		:= ""
	Local cEntN3 := "N3_"+cField
	Local cEntNg := "SNG->NG_"+cField
	Local cEntFNG	:= "FNG->FNG_"+IIf(!Empty(cFldFNG), cFldFNG, "")
	Local cReduzi :=cEnt+"->"+cEnt+"_RES"
	Local cComplet :=""
	Local lMovSald := .T.

	dbSelectArea(cEnt)
	dbSetOrder(3)
	If cEnt=="CT1"
		dbSetOrder(2)
		cComplet:="CT1->CT1_CONTA"
	ElseIF cEnt=="CTT"
		cComplet:="CTT->CTT_CUSTO"
		lMovSald :=CtbMovSaldo('CTT')
	ElseIF cEnt=="CTD"
		cComplet:="CTD->CTD_ITEM"
		lMovSald :=CtbMovSaldo('CTD')
	ElseIF cEnt=="CTH"
		cComplet:="CTH->CTH_CLVL"
		lMovSald :=CtbMovSaldo('CTH')
	Endif

	If lIsRussia .AND. !Empty(cFldFNG)
		DbSelectArea("FNG")
		FNG->(DbSetOrder(1))
		If FNG->(DBSeek(xFilial('FNG') + SNG->NG_GRUPO + oLinha:GetValue('N3_TIPO') ))
			cRet:= &(cEntFNg)
			If Empty(cRet)
				cRet:= &(cEntNg)
			EndIf
		Else
			cRet:= &(cEntNg)
		EndIf
		dbSelectArea(cEnt)
		dbSetOrder(3)
	Else
		cRet:= &(cEntNg)
	EndIf
	//Ajuste para que os valores que estejam em branco no cadastro do grupo de bens não sobreponha o que já esta preenchido
	If Empty(Alltrim(cRet))
		lApaga	:= .F.
	Endif

	If (lApaga .OR.(Empty(oLinha:GetValue(cEntN3)))) // Verifica se deve sobre-escrever o campo, caso esteja em branco a informação é colocada de qualquer maneira
		If GetMv("MV_REDUZID") == "S"
			If (!Empty(&(cEntNg))).AND.  dbSeek(xFilial()+&(cEntNg))
				cRet := &(cComplet)
			EndIf
		ElseIf Substr(&(cEntNg),1,1)=="*"
			cRet :=Trim(SubStr(&(cEntNg),2))
			cRet += Space(Len(cReduzi)-Len(cRet))
			If dbSeek(xFilial()+cRet)
				cRet := &(cComplet)
			EndIf
		EndIf
	EndIf
	If lMovSald .and. lApaga
		oLinha:LoadValue(cEntN3 ,cRet)
	Endif
	(cEnt)->(RestArea(aSaveEnt))
	RestArea(aSaveArea)

Return cRet



//-------------------------------------------------------------------
/*/{Protheus.doc} ATF012VIEW

Model and View refresh in:
N1_STATUS -> X3_VALID

@param
@return
@author		Fabio Cazarini
@since		05/05/2017
@version	12
@project	MA3
/*/
//-------------------------------------------------------------------
Function ATF012VIEW()
Local lRet as logical
Local oView as object

lRet := .T.

oView := FWViewActive()
If oView <> Nil
	oView:Refresh()
Endif

Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ PrzTotPrev  ³ Autor ³ Norberto M Melo       ³ Data ³01/06/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Tempo total para a depreciação em anos                        ³±±
±±³          ³ Se não informada através de N1_PRZDEPR efetua um cálculo utili³±±
±±³          ³ zando a taxa anual cadastrada no N3                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Valor numérico representado a quantidade em anos.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DATA      ³ Programador   ³ Manutencao Efetuada                           ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function PrzTotPrev( cMoedaATF )

Local 	nPrzTotPrev	:= 1	//Valor de Retorno

If (cPaisLoc == "PTG")
	if Empty( SN1->N1_PRZDEPR )
		nPrzTotPrev := 100 / SN3->&(IIf(Val(cMoedaATF)>9,"N3_TXDEP","N3_TXDEPR") + cMoedaATF)
	endif
endif

Return nPrzTotPrev

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MaxTxDegr   ³ Autor ³ Norberto M Melo       ³ Data ³01/06/08  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Taxa Máxima de Depreciação que via de regra deverá ser infor  ³±±
±±³          ³ mada no cadastro de grupos, porém na falta deste cadastro     ³±±
±±³          ³ será considerado o valor informado no N3                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExprL1 - Aplicar o coeficiente sobre a taxa                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com cinco elementos contendo a taxa respectiva de cada  ³±±
±±³          ³ moeda.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³DATA      ³ Programador   ³ Manutencao Efetuada                           ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±³          ³               ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MaxTxDegr( lUsaCoefic )

Local aMaxTxDegr:= IIf(lMultMoed, AtfMultMoe(,,{|x| 0}) , {0,0,0,0,0} ) //Valor de Retorno
Local aAreaNG	:= SNG->( GetArea( ) )		//Tabela de Grupos
Local i 		:= 0								//Contador - Auxiliar

SNG->( dbSetOrder( 1 ) )
SNG->( DBSeek( xFilial( "SN1" ) + SN1->N1_GRUPO ) )
for i := 1 to Len( aMaxTxDegr )
	if !SNG->( EOF() )
		aMaxTxDegr[ i ] := SNG->&( IIf(i>9,"NG_TXDEP","NG_TXDEPR") + Alltrim(Str(i)) )
	else
		aMaxTxDegr[ i ] := SN3->&( IIf(i>9,"N3_TXDEP","N3_TXDEPR") + Alltrim(Str(i)) )
	endif

	if lUsaCoefic
		aMaxTxDegr[ i ] *= IIf( SN3->N3_COEFICI > 0,SN3->N3_COEFICI, IIf( SNG->NG_COEFICI > 0, SNG->NG_COEFICI,1 ) )
	endif

Next i

SNG->( RestArea( aAreaNG ) )
Return aMaxTxDegr

//-------------------------------------------------------------------
/*/{Protheus.doc} AF012AEXIS
Valida a existencia do ativo/item
@author: 	Jose Renato July - JRJ
@since:  	05/10/2017
@version: 	12
/*/
//-------------------------------------------------------------------
Function AF012AEXIS()

Local aSaveArea	:= GetArea()
Local oModel 	:= FWModelActive()
Local cBase 	:= oModel:GetValue('SN1MASTER','N1_CBASE')
Local nItem 	:= oModel:GetValue('SN1MASTER','N1_ITEM')
Local lRet  	:= .T.

If lRet
	dbSelectArea("SN1")
	SN1->(dbSetOrder(1)) 		// N1_FILIAL + N1_CBASE + N1_ITEM
	If SN1->(dbSeek( xFilial("SN1") + cBase + nItem))
		Help(" ",1,"JAGRAVADO")		//"Já existe registro com esta informação.###Troque a chave principal deste registro."
		lRet := .F.
	EndIf
EndIf

RestArea(aSaveArea)
oModel := Nil

Return(lRet)
/*/{Protheus.doc} RusCheckRevalFunctions()

Check for Russian revaluation functions

@param		None
@return		None
@author 	victor.rezende
@since 		18/09/2017
@version 	1.0
@project	MA3
@see        None
/*/
//-----------------------------------------------------------------------
Static Function RusCheckRevalFunctions()
Return lIsRussia .And. IsInCallStack("RU01T04COM")

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AF012ACHCCºAutor  ³TOTVS SA            º Data ³  10/01/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação do campo N3_CCUSTO, de forma que o Centro de     º±±
±±º          ³ de despesa de depreciacao tenha o mesmo valor.             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATF012                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF012ACHCC(lGrupo)

Local nI
Local lCcdp	   	:= GetMv("MV_ATFCCDP",.F.,.F.) // Se .T. e utilizar grupo de bens o conteudo do campo N3_CCCUSTO sera replicado para o campo N3_CCDESP
Local oModel 		:= FwModelActive()
Local oAux			:= oModel:GetModel('SN3DETAIL')
Local cGrupo		:= oModel:GetValue('SN1MASTER','N1_GRUPO')
Local nAtual	 	:= oAux:GetLine()

Default lGrupo := .T.

If lCcdp

	If lGrupo
		For nI := 1 To Len(oAux:aCols)
			oAux:GoLine(nI)

			If ! Empty(cGrupo)

				If Empty (oAux:GetValue('N3_CCDESP'))
					If SNG->(DbSeek(xFilial("SNG") + cGrupo) )
						oAux:SetValue('N3_CCDESP', SNG->NG_CCUSTO)
					Endif
				Else
					oAux:SetValue('N3_CCDESP', oAux:GetValue('N3_CCUSTO'))
				Endif

			Endif
		Next nI

		oAux:GoLine(nAtual)

	Else
		oAux:SetValue('N3_CCDESP', oAux:GetValue('N3_CCUSTO'))
		oAux:GoLine(nAtual)
	Endif

Endif

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³A012NOTA  		³TOTVS SA            º Data ³  17/01/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida se o Ativo veio de documento de entrada para        º±±
±±           ³ bloquear os campos de N1_ALIQPIS e N1_ALIQCOF		      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA012                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A012NOTA(oModel)
Local lRet 		:= .T.
Local cNFiscal 	:= ""
Local cSerie	:= ""
Local nOpc		:= oModel:GetOperation()

Default oModel := Nil

cNFiscal 	:= oModel:GetValue('N1_NFISCAL')
cSerie 		:= oModel:GetValue('N1_NSERIE')

If nOpc == 4 .And. !Empty(cNFiscal) .And. !Empty(cSerie)
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AFA012DtInDp 		³TOTVS SA            º Data ³  22/10/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche data Inicio de depreciação de acordo com MV_PAR04 º±±
±±           ³ na classificação 										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA012                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AFA012DtInDp(oModel)

Local lRet := .T.
Local oModelSN3	:= oModel:GetModel("SN3DETAIL")

If __lClassifica .And. inclui
	oModelSN3:LoadValue("N3_DINDEPR",RetDinDepr(dDataBase))
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  F012CONTIN 		³TOTVS SA            º Data ³  21/11/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Realiza contabilização do ativo apartir da SN3             º±±
±±           ³                   										  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA012                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F012CONTIN(lCprova,lProva,cPadrao,aContbSN3)
Local nLinha    := 0
Local aArea     := GetArea()
Local aAreaSN3  := SN3->(GetArea())
Local aAreaSN4  := SN4->(GetArea())

Default lCprova := .F.
Default lProva  := .F.
Default aContbSN3    := {}
Default cPadrao := ""

For nLinha:= 1 to Len(aContbSN3)
    //Pocisiona SN3
    SN3->(dbGoTo(aContbSN3[nLinha]))

	//Posiciono o SN4 para gravar o RECNO correto na CTK, CV3
	If cPaisLoc == "BRA" .And. cPadrao == "801"
		SN4->(dbSetOrder(1))
		SN4->(dbSeek(xFilial("SN4")+SN3->(N3_CBASE+N3_ITEM+N3_TIPO)+DtoS(SN3->N3_AQUISIC)+"05"+SN3->N3_SEQ))
	EndIf

    //Se for ampliação ATFA155 só contabiliza tipo 11
    If __lAmplia .And. SN3->N3_TIPO <> '11' .And. cPadrao = '821'
        Loop
    EndIf

    If !lCprova  //!oSN3:IsDeleted(nLinha) .And. !lCprova
        If lProva .And. __nHdlPrv <= 0
        // Na Inclusao simples e sempre .T.
            __nHdlPrv:=HeadProva(__cLoteAtf,"ATFA012",Substr(cUsername,1,6),@__cArqCtb)
        EndIf
    EndIf

    lCprova := .T.

    If __nHdlPrv > 0
        __nTotal += DetProva(__nHdlPrv,cPadrao,"ATFA012",__cLoteAtf,,,,,,,, @aFlagCTB)
    EndIf

Next nLinha

RestArea(aAreaSN4)
RestArea(aAreaSN3)
RestArea(aArea)
Return lCprova

//-------------------------------------------------------------------
/*/{Protheus.doc}A012SetEnt
Carrega valores nas entidades adicionais
@author mayara.alves
@since  12/11/19
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function A012SetEAdc(oLinha )
Local aCTBEnt   := CTBEntArr()
Local nQtdEntid := 0

    For nQtdEntid := 1 To Len(aCTBEnt)
        If SNG->(ColumnPos("NG_EC"+aCTBEnt[nQtdEntid]+"DB")) > 0  .And. !Empty( &("SNG->NG_EC"+aCTBEnt[nQtdEntid]+"DB"))
            oLinha:LoadValue('N3_EC'+aCTBEnt[nQtdEntid]+'DB'	, &("SNG->NG_EC"+aCTBEnt[nQtdEntid]+"DB"))
        EndIf
        If SNG->(ColumnPos("NG_EC"+aCTBEnt[nQtdEntid]+"CR")) > 0  .And. !Empty( &("SNG->NG_EC"+aCTBEnt[nQtdEntid]+"CR"))
            oLinha:LoadValue('N3_EC'+aCTBEnt[nQtdEntid]+'CR'	, &("SNG->NG_EC"+aCTBEnt[nQtdEntid]+"CR"))
        EndIf
	Next nQtdEntid

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ATFA012   ºAutor  ³Microsiga           º Data ³  29/10/20   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida se o bem selecionado é do tipo bem em construção     º±±
±±º          ³para amarrá-lo com o componente                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ ATFA012                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function AF012VLBC(cBase,cItem)
Local lRet      := .T.
Local aArea     := GetArea()
Local aAreaSN1  := SN1->(GetArea())
Local aAreaSn3  := SN3->(GetArea())
Local oModel 	:= FWModelActive()
Local oModelSN1 := oModel:GetModel("SN1MASTER")
Local oModelSN3	:= oModel:GetModel("SN3DETAIL")
Local cTipo		:= oModelSN3:GetValue("N3_TIPO")

dbSelectArea("SN1")
dbSelectArea("SN3")

SN1->(dbSetOrder(1))//N1_FILIAL+N1_CBASE+N1_ITEM
SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

If !Empty(cBase) .And. !Empty(cItem)
	If lRet .And. !SN1->(dbSeek(xFilial("SN1") + cBase + cItem ))
		Help(" ",1,"REGNOIS")
		lRet := .F.
	EndIf

	If lRet .And. Alltrim(SN1->N1_BMCONTR) != "1"
		oModelSN1:LoadValue('N1_CDCONTR'	,Space(Len(SN1->N1_CDCONTR)))
		Help(" ",1,"ATFA012BC",,STR0180,1,0)  //O Bem deve ser Tipo em construção
		lRet := .F.
	EndIf

	If cTipo == '01'
		Help(" ",1,"ATF012TP",,STR0180,1,0)  //"Altere o Tipo do Ativo para 03"
		lRet := .F.
	EndIf
EndIf

RestArea(aAreaSN3)
RestArea(aAreaSN1)
RestArea(aArea)
Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    AF12CHPMIL ³ Autor ³ TOTVS SA              ³ Data ³ 25.11.20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica se a chapa já existe. A função é Chamada quando   ³±±
±±³            a alteração é executada via MILE                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ AF12CHPMIL(nChapa)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atfa012                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function AF12CHPMIL(nChapa)
LOCAL aArea		:= GetArea()
Local cQuery	:= ""
Local cTab		:= GetNextAlias()
Local lRet		:= .F.

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

cQuery := " SELECT N1_CBASE, N1_CHAPA "
cQuery += " FROM " + RetSqlName("SN1")
cQuery += " 	WHERE N1_FILIAL = '" + xFilial("SN1") + "'"
cQuery += " 	AND N1_CHAPA = '" + nChapa + "'"
cQuery += " 	AND D_E_L_E_T_ = '' "

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cTab)

If (cTab)->(!EOF())
	lRet:= .T.
EndIf

(cTab)->(dbCloseArea())

RestArea(aArea)
Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    A012WHENCONTA ³ Autor ³ TOTVS SA              ³ Data ³ 25.11.20 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Não permite alterar conta		                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A012WHENCONTA(oModel)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Atfa012                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A012WHENCONTA(oModel)
Local lRet := .T.
Local oModel 		:= FWModelActive()
Local oAux	:= oModel:GetModel("SN3DETAIL")

If !oAux:IsInserted(oAux:GetLine()) .AND. !__lClassifica .AND. !__lCopia .AND. !IsInCallStack("ATFA040")
	//Help(" ",1,"AF012VCTA", ,STR0163,1,0,,,,,,{STR0164} ) //Este campo não pode ser alterado####Se esta operação for inevitável, exclua e inclua novamente o registro ou utilize a rotina de transferência.
	lRet := .F.
Endif

Return lRet


/*/{Protheus.doc} ATF012Metrics

	ATF012Metrics - Funç?o utilizada para metricas no CTBR400

	@type  Static Function
	@author user
	@since date
	@version version
	@param param, param_type, param_descr
	@return return, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function ATF012Metrics(cEvent, nStart, cSubEvent, cSubRoutine, nQtdReg)

Local cFunBkp	:= ""
Local cFunMet	:= ""

// Local nFim := 0

Local cIdMetric  := ""
Local dDateSend := CtoD("")
Local nLapTime := 0
Local nTotal := ""

Default cEvent := ""
Default nStart := Seconds() //Caso futuramente exista metrica de tempo medio
Default cSubEvent := ""
Default cSubRoutine := Alltrim(ProcName(1))
Default nQtdReg := 0

//Só capturar metricas se a vers?o da lib for superior a 20210517
If __lMetric .And. !Empty(cEvent)

	//grava funname atual na variavel cFunBkp
	cFunBkp := FunName()

	If cEvent == "01" //Evento 01 - Metrica de tempo médio


		//Evento 01 - Metrica de quantidade total de gravacao do tipo 15 - AF012Grv15
		If cEvent == "01"

			If cSubEvent == '001'

				cFunMet := Iif(AllTrim(cFunBkp)=='RPC',"RPCATFA012",cFunBkp)
				SetFunName(cFunMet)

				//atribuicao das variaveis que serao utilizadas pelo FwCustomMetrics
				cSubRoutine := Alltrim(cSubRoutine)
				cIdMetric  := "ativo-fixo--protheus_ativofixoprotheus_cadastrodeativosimobilizados_total_total"
				nTotal := 1 //nTotal
				dDateSend := LastDay( Date() )
				FWCustomMetrics():SetSumMetric(cSubRoutine, cIdMetric, nTotal, dDateSend, nLapTime)
			EndIf
		EndIf
	EndIf

	//Restaura setfunname a partir da variavel salva cFunBkp
	SetFunName(cFunBkp)
EndIf

Return



/*/{Protheus.doc} AF012For
	@description  Gatilho entre fornecedor e loja
	@type Function
	@author Felipe Mayer
	@since 21/10/2021
	@version 1
	@return A2_LOJA
/*/

Function AF012For(cForAF012)

Local aArea := GetArea()
Local cRet  := ''

Default cForAF012 := ''

	If Inclui .Or. Altera
		If !Empty(cForAF012)
			DbSelectArea('SA2')
			DbSetOrder(1)

			If SA2->(DbSeek(xFilial('SA2')+cForAF012,.T.))
				While SA2->(!EoF()) .And. SA2->(A2_FILIAL+A2_COD) == xFilial('SA2')+cForAF012
					If SA2->A2_MSBLQL != '1'
						cRet := SA2->A2_LOJA
						Exit
					EndIf

					SA2->(DbSkip())
				EndDo
			EndIf

			SA2->(DbCloseArea())
		EndIf
	EndIf

RestArea(aArea)

Return cRet


/*/{Protheus.doc} ATVldCpo
	@description Função responsável por localizar caracteres especiais em campos obrigatórios
	@type Function
	@author Felipe Mayer
	@since 03/11/2021
	@param cAlias -> Passar alias por parâmetro - String (ex: ATVldCpo("SN1"))
	@return lRet
/*/
Function ATVldCpo(cAlias)

Local nCont 	:= 0
Local lRet		:= .T.
Local aCarcEsp  := {"!","@","#","$","'","%","¨","&","*","(",")","=","´","`","{","}","[","]",;
					"ç","Ç","^","~","ª","º","?","/","°","§",";",":",".",",","|","\",">","<","+",'"'}
Local lVldSX2 	:= FwSX2Util():SeekX2File(cAlias)
Local aCpoAlias := Iif(lVldSX2,&(cAlias+"->(DbStruct())"),{})

	If !lVldSX2
		MsgAlert(STR0186,'ATVldCpo')
		lRet :=  .F.
	EndIf

	If Len(aCpoAlias) > 0 .and. lRet
		For nCont := 1 To Len(aCpoAlias)
			If X3Obrigat(aCpoAlias[nCont,1]) .And. aCpoAlias[nCont,2] == 'C' .And. &('M->'+aCpoAlias[nCont,1]) != Nil
				If aScan(aCarcEsp, {|x| AllTrim(x) $ Alltrim(&('M->'+aCpoAlias[nCont,1])) }) > 0
					If aCpoAlias[nCont,1] != "N1_DESCRIC" .And. cAlias = "SN1"
						MsgAlert(STR0187+'<b>'+aCpoAlias[nCont,1]+'</b>')
						lRet := .F.
					Endif
					Exit
				EndIf
			EndIf
		Next nCont
	EndIf

Return lRet
