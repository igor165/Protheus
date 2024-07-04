#Include 'Protheus.CH'
#Include 'FWMVCDef.CH'
#Include 'FINA010.CH'

#DEFINE SOURCEFATHER "FINA010"

Static _lTemMR := .F.

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010BRA
Cadastro de Natureza especifico para o Brasil

@author  jose.aribeiro
@since   17/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Function FINA010BRA()
Local oBrowse As Object
Private lTree As Logical

	oBrowse 	:= NIL
	lTree 		:= .F.

	_lTemMR := If(FindFunction("FTemMotor"), FTemMotor(), .F.) 

	//Caso não tenha nenhuma regra financeira cadastrada, não apresento o browse de amarração Natureza x Regra de Retenção
	If _lTemMR
		FKK->(dbGoTop())
		If Empty(FKK->FKK_CODIGO)
			_lTemMR := .F.
		EndIf
	EndIf

	oBrowse := BrowseDef() 
	
	If(!lTree)	
		oBrowse:Activate()
	EndIf

Return

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010BRA
BrowseDef da rotina FINA010 Brasil

@author  jose.aribeiro
@since   17/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function BrowseDef() As Object
Local oBrowse As Object

	oBrowse := FwLoadBrw(SOURCEFATHER)

	SetKey ( VK_F12, { |a,b| AcessaPerg( "FIN010", .T. ) } )
	Pergunte( "FIN010", .F. )
	
	If(MV_PAR01 == 2)

		FINA010N()
		lTree := .T.

	EndIf

Return oBrowse

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
ModelDef da rotina FINA010 Brasil

@author  jose.aribeiro
@since   17/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ModelDef() As Object
Local oModel  	As Object 
Local oEvent  	As Object 
Local oStruct 	As Object 
Local oStruFOI	As Object
Local bWhen	  	As Block
Local aRelacFOI	As Array

oModel  	:= FwLoadModel(SOURCEFATHER)
oEvent  	:= FINA010EVBRA():New(oModel)
oStruct 	:= FWFormStruct(1, "SED") 
bWhen		:= FwBuildFeature( STRUCT_FEATURE_WHEN,"ValidIrfTms(oModel)")

oStruct:SetProperty("ED_IRRFCAR",MODEL_FIELD_WHEN,bWhen)

oModel:InstallEvent("BRASIL",,oEvent)

If _lTemMR .And. !FwIsInCallStack("NatColar") //Cópia da natureza não copia regra de motor
	oStruFOI 	:= FStructFOI(1)
	aRelacFOI 	:= {}
	oModel:AddGrid("FOIDETAIL", "SEDMASTER", oStruFOI, /*bLinePre*/, /*bLinePos*/, /*bPre*/, /*bPos*/, /*bLoad*/)

	//Define o Relacionamentos
	aAdd(aRelacFOI, {"FOI_FILIAL", "xFilial('FOI')"})
	aAdd(aRelacFOI, {"FOI_NATURE", "SED->ED_CODIGO"})
	oModel:SetRelation("FOIDETAIL", aRelacFOI, FOI->(IndexKey(1)))

	//Define uma linha única para a grid
	oModel:GetModel("FOIDETAIL"):SetUniqueLine({"FOI_CODIGO"})
	oModel:GetModel("FOIDETAIL"):SetDelAllLine(.F.)

	//Preenchimento da grid opscional
	oModel:GetModel( 'FOIDETAIL' ):SetOptional( .T. )
EndIf

Return oModel

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINA010BRA
ViewDef do FINA010 Brasil

@author  jose.aribeiro
@since   17/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ViewDef() As Object
Local oView		As Object
Local oStruFOI	As Object
Local oStruSED  As Object

oStruSED := FWFormStruct( 2, 'SED' )
oView    := FwLoadView(SOURCEFATHER)

oStruSED:SetProperty( 'ED_JURCAP'	, MVC_VIEW_HELP    , {STR0088 } )	

If _lTemMR
	oStruFOI := FStructFOI(2)

	oView:AddGrid('VIEWFOI', oStruFOI, 'FOIDETAIL')
	oView:CreateHorizontalBox('FORM', 50, 'BOXMAIN')
	oView:CreateHorizontalBox('GRID', 50, 'BOXMAIN')
Else
	oView:CreateHorizontalBox('FORM', 100, 'BOXMAIN')
EndIf

oView:SetOwnerView('SEDMASTER', 'FORM')

If _lTemMR
	oView:SetOwnerView('VIEWFOI', 'GRID')
	oView:EnableTitleView( "VIEWFOI", STR0075)

	//Remove campo da view
	oStruFOI:RemoveField('FOI_NATURE')
	oStruFOI:RemoveField('FOI_IDFKK')
	oStruFOI:SetProperty('FOI_DESCR',  MVC_VIEW_ORDEM, '04')
	oStruFOI:SetProperty('FOI_CODIGO', MVC_VIEW_LOOKUP, 		{ || FIN010CF3("FOI_CODIGO") } )
EndIf

Return oView

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do FINA010 Brasil

@author  jose.aribeiro
@since   17/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function MenuDef() As Array
Local aRotina As Array 
Local lHistFiscal As Logical

	aRotina		 := {}
	lHistFiscal	 := HistFiscal()

	aRotina := FWLoadMenuDef(SOURCEFATHER)
	aAdd(aRotina,{STR0011,'StaticCall(FINA010BRA, F010SldCTb)',0,2})
	aAdd(aRotina,{STR0060,"FA010Hist",0,2})

Return aRotina

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FA010Hist
Função responsavel pela

@author  jose.aribeiro
@since   17/05/2017
@version 12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Function FA010Hist() As Logical
Local lRet As Logical
	
	lRet:= .F.
	lRet := HistOperFis("SS7",SED->ED_CODIGO,SED->ED_DESCRIC,"S7_CODIGO")

Return lRet

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} F010SldCtb
Cadastro de Natureza localizado para MÉXICO.
Botoes especificos da consulta de naturezas

@type function
@author Mauricio Pequim Jr
@since 23.11.2009
@version P12.1.17
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function F010SldCtb()
Local oDlg  As Object

	oDlg := NIL
	If !Empty (SED->ED_CONTA)
		
		//Saldo da conta contabil relacionada a Natureza
		//Saldo inicial ( ultimo dia do mes anterior )
		bSldCTBAnt	:= {||SaldoCT7(SED->ED_CONTA,FirstDay(dDatabase)-1,"01")}
		//Saldo atual ( database )
		bSldCTBAtu	:= {||SaldoCT7(SED->ED_CONTA,dDatabase,"01")}
		
		// Retorno SaldoCT7:              
		// [1] Saldo Atual (com sinal)    
		// [2] Debito na Data             
		// [3] Credito na Data            
		// [4] Saldo Atual Devedor        
		// [5] Saldo Atual Credor         
		// [6] Saldo Anterior (com sinal) 
		// [7] Saldo Anterior Devedor     
		// [8] Saldo Anterior Credor      
		
		// Adiciona botoes do usuario na EnchoiceBar   
		If ExistBlock( "F010BUT" )

			bSldCTBAnt := ExecBlock( "F010BUT", .F., .F.,{1} )
			bSldCTBAtu := ExecBlock( "F010BUT", .F., .F.,{2} )

		EndIf
		
		aSaldosAnt := Eval(bSldCTBAnt)
		aSaldosAtu := Eval(bSldCTBAtu)
			
		cSalAnt :=  ValorCtb(aSaldosAnt[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
		cMovPer :=  ValorCtb(aSaldosAtu[1] - aSaldosAnt[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
		cSalAtu := 	ValorCtb(aSaldosAtu[1],0,0,17,2,.T.,,,SED->ED_CONTA,,,,,.T.,.F.)
		
		DEFINE MSDIALOG oDlg FROM 00,00 TO 120, 300 TITLE STR0012 PIXEL //"Saldo Contábil"
		@	003,003 	Say STR0013  OF oDlg PIXEL //"Saldo Anterior: "
		@	003,095	Say cSalAnt OF oDlg PIXEL
		@	015,003 	Say STR0014  OF oDlg PIXEL //"Movimento no periodo: "
		@	015,095	Say cMovPer OF oDlg PIXEL
		@	029,003 	Say STR0015  OF oDlg PIXEL //"Saldo Atual: "
		@	029,095	Say cSalAtu OF oDlg PIXEL
		
		@	001,001 TO 40,150 OF oDlg PIXEL
		
		DEFINE SBUTTON FROM 045,100	TYPE 1 ACTION oDlg:End() ENABLE OF oDlg
		
		ACTIVATE MSDIALOG oDlg CENTERED
		
	Else

	Help("  ",1,"EMPTYCC",,STR0016,1,1) //"Conta contábil não preenchida para esta natureza"

	Endif

Return 

//-------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidIrfTms
Função Responsavel para validar o Valid do calculo do IRRF do módulo  TMS

@type Function
@author Jose.Aribeiro
@since 29/05/2017
@version 12.1.17
@return lret, Logico, Retorna .T. para validado e .F. para nao validado
/*/
//-------------------------------------------------------------------------------------------------------------
Static Function ValidIrfTms(oModel) As Logical
Local lRet		As Logical	 
Local oModelSED	As Object	 

	lRet		 := .F.
	oModelSED	 := oModel:GetModel("SEDMASTER")

	If(oModelSED:GetValue("ED_CALCIRF") == "S")
		lRet := .T.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FStructFOI
Funcao de preparacao da estrutura da tabela FOI para Model/View.

@aparam	nTipo, indica se ‚ 1 = model ou 2 = view 
@Return	oFOI Estrutura de campos da tabela FOI

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FStructFOI(nTipo As Numeric) As Object
Local oFOI 		As Object
Local nTamDesc 	As Numeric	

DEFAULT nTipo := 1
nTamDesc := TamSx3("FKK_DESCR")[1]

If nTipo == 1
	oFOI := FWFormStruct(1, "FOI", /*bAvalCampo*/,/*lViewUsado*/ )

	oFOI:AddField(;
	STR0073,;											//[01] Titulo do campo "Detalhamento do tipo de retenção"
	STR0074,;																		//[02] ToolTip do campo 	//"Descrição"
	"FOI_DESCR",;																		//[03] Id do Field
	"C"	,;																				//[04] Tipo do campo
	nTamDesc,;																			//[05] Tamanho do campo
	0,;																					//[06] Decimal do campo
	{ || .T. }	,;																		//[07] Code-block de validação do campo
	{ || .T. }	,;																		//[08] Code-block de validação When do campo
				,;																		//[09] Lista de valores permitido do campo
	.F.	,;																				//[10]	Indica se o campo tem preenchimento obrigatório
	FWBuildFeature(STRUCT_FEATURE_INIPAD, "FGetTpRet(1)") ,,,;// [11] Inicializador Padrão do campo
	.T.) 																				//[14] Virtual			
	
	oFOI:AddTrigger("FOI_CODIGO", "FOI_DESCR", { || .T.}, { || FGetTpRet(2) })	
Else
	oFOI := FWFormStruct(2, "FOI", /*bAvalCampo*/,/*lViewUsado*/ )
	oFOI:AddField("FOI_DESCR", "04", STR0074, STR0074, {}, "C", "@!", /*bPictVar*/, /*cLookUp*/, .F./*lCanChange*/,;
					 /*cFolder*/, /*cGroup*/, /*aComboValues*/, /*nMaxLenCombo*/,/*cIniBrow*/, .T., /*cPictVar*/, /*lInsertLine*/)
EndIf

Return oFOI

//-------------------------------------------------------------------
/*/{Protheus.doc} FGetTpRet()
Funcao para preenchimento dos campos virtuais do tipo retenção

@param cField - Campo a ser preenchido do campo FOI_CODIGO
@param nProperty - 1 = Inicializador padrao / 2 = Gatilho 

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Function FGetTpRet(nProperty As Numeric) As Character
	Local cRet 		As Character
	Local nOper		As Numeric
	Local cCodigo 	As Character
	Local cIdRet 	As Character
	
	DEFAULT nProperty	:= 1
	
	oModel		:= FWModelActive()
	nOper		:= oModel:GetOperation()
	cRet		:= ""
	
	If nProperty == 1 
		If nOper <> MODEL_OPERATION_INSERT .And. !Empty(FOI->FOI_CODIGO) 
			cRet := Posicione("FKK", 1, xFilial("FKK") + FOI->FOI_IDFKK, "FKK_DESCR")
		EndIf
	Else
		cCodigo := oModel:GetValue("FOIDETAIL", "FOI_CODIGO")	
		cIdRet 	:= oModel:GetValue("FOIDETAIL", "FOI_IDFKK")
		
		If !Empty(cCodigo)
			cRet := Posicione("FKK", 1, xFilial("FKK") + cIdRet, "FKK_DESCR")
		EndIf
	
	EndIf
Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN010CF3()
consulta Padrão SXB

@author Totvs Sa
@since	14/09/2017
@version 12
/*/
//-------------------------------------------------------------------
Static Function FIN010CF3 (cCmpF3 As Character) AS Character
Local cF3 As Character

DEFAULT cCmpF3  := ""

cF3		:=	""

If cCmpF3 $ 'FOI_CODIGO'
	cF3 :=	"FKK"
EndIf

Return cF3

//-------------------------------------------------------------------
/*/{Protheus.doc} FIN010CDI
validação do código (FOI_CODIGO)

@author Totvs Sa
@since 14/09/2017

@return Logico
/*/
//-------------------------------------------------------------------
Function FIN010CDI()
	Local lRet 		As Logical
	Local oModel 	As Object
	Local cCodigo 	As Character
	Local cIdRet	As Numeric
	Local nOper		As Numeric
	Local cIdRet	AS Character
	Local lInsrt	As Logical
	
	lRet 	:= .F.
	
	oModel 	:= FWModelActive()
	
	nOper	:= oModel:GetOperation()
	cCodigo := oModel:GetValue("FOIDETAIL","FOI_CODIGO")
	If lInsrt := (nOper == MODEL_OPERATION_INSERT) .And. cCodigo == FKK->FKK_CODIGO
		cIdRet 	:= oModel:GetValue("FOIDETAIL","FOI_IDFKK")
	Else
		cIdRet := Posicione("FKK", 3, xFilial("FKK") + '1' + cCodigo + ;
		Iif(!lInsrt .And. cCodigo == FKK->FKK_CODIGO, FKK->FKK_VERSAO,""), "FKK_IDRET")
	EndIf
	
	If !Empty(cCodigo )
		aArea := GetArea()
		DbSelectArea("FKK")	
		FKK->(DBSETORDER(1))
		If FKK->(MsSeek(xFilial('FKK') + Iif(nOper == MODEL_OPERATION_INSERT, FKK->FKK_IDRET, cIdRet) ) )
			lRet := .T.
		Else
			HELP(' ',1,"COD_RET" ,,STR0076 ,2,0,,,,,, {STR0077})	//"Código de retenção informado não se encontra cadastrado ou não possui uma versão ativa."###"Por favor, informe um código de retenção existente ou ativo."
		Endif
		If lRet
			oModel:LoadValue('FOIDETAIL','FOI_IDFKK', FKK->FKK_IDRET)
		EndIf
		RestArea(aArea)
	EndIf
Return lRet
