#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#Include "FINA382.CH"

Static __aImpos  := {}
Static __oControl  

//---------------------------------------------------------------------------------------
/*/{Protheus.doc}FINMRET
Model de montagem de tela de totalizadores da rotina FINA382 (Aglutinação de Impostos)

@author Mauricio Pequim Jr/Fabio Casagrande
@since  22/11/2017
@version 12	
/*/	
//---------------------------------------------------------------------------------------
Function FINM382(aImp As Array,oPanel As Object, lWizard As Logical) As Logical

	Local aEnableButtons As Array
	Local nOpc 			 As Numeric
	Local lRet 			 As Logical

	Default aImp      := {}
	Default oPanel    := NIL
	Default lWizard := .F.
	
	__oControl := oPanel

	lRet := .F.
	aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"

	nOpc := 1 // 0 - Confirmar / 1 - Cancelar

	__aImpos := aImp

	If !lWizard 
		nOpc := FWExecView( "Titulos a Gerar" ,"FINM382", MODEL_OPERATION_INSERT,oPanel,/**/,/**/,,aEnableButtons )	//'Retenção de Impostos por Título'
	Else	
		oModAg := FWLoadModel("FINM382")
		oModAg:SetOperation(MODEL_OPERATION_INSERT)
		oModAg:Activate()

		oViewAg := FWLoadView("FINM382")
		oViewAg:SetModel(oModAg)
		oViewAg:SetOperation(MODEL_OPERATION_INSERT)
		oViewAg:SetOwner(oPanel)
		oViewAg:Activate()
	Endif	

	aImp := __aImpos

	If nOpc = 0 .or. lWizard
		lRet := .T.	
    Endif

Return lRet

//---------------------------------------------------------------------------------------
/*/{Protheus.doc}F382Reload
Model de montagem de tela de totalizadores da rotina FINA382 (Aglutinação de Impostos)

@author Mauricio Pequim Jr/Fabio Casagrande
@since  22/11/2017
@version 12	
/*/	
//---------------------------------------------------------------------------------------
Function F382Reload(aImp As Array)

	Default aImp      := {}

	__aImpos := aImp

	oModAg := FWLoadModel("FINM382")
	oModAg:SetOperation(MODEL_OPERATION_INSERT)
	oModAg:Activate()

	oViewAg := FWLoadView("FINM382")
	oViewAg:SetModel(oModAg)
	oViewAg:SetOperation(MODEL_OPERATION_INSERT)
	oViewAg:SetOwner(__oControl)
	oViewAg:Activate()

	aImp := __aImpos

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@author Mauricio Pequim Jr/Fabio Casagrande
@since  22/11/2017
@version 12
/*/	
//-----------------------------------------------------------------------------
Static Function ViewDef() As Object

	Local oView   As Object
	Local oModel  As Object
	Local oImpos  As Object

	oView   := FWFormView():New()
	oModel  := FWLoadModel("FINM382")

	oView:SetModel( oModel )			
	oImpos  := FStructIMP(2)	
	oView:AddGrid("VIEWIMP"  , oImpos , "IMPDETAIL" )
	
	oView:CreateHorizontalBox( 'BOXIMP', 100 )
	oView:SetOwnerView('VIEWIMP', 'BOXIMP')
	
	oView:EnableTitleView('VIEWIMP' , "Impostos a Gerar" )	
	oView:SetNoDeleteLine('VIEWIMP')

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Mauricio Pequim Jr/Fabio Casagrande
@since  22/11/2017
@version 12
/*/	
//-----------------------------------------------------------------------------
Static Function ModelDef() As Object 

	Local oModel    As Object
	Local oMaster   As Object
	Local oImpos    As Object
	Local bLinePost As Codeblock

	bLinePost := {|| F382LINE(oModel) }

	oModel  := MPFormModel():New('FINM382',/*Pre*/,/*bPos*/,{|oModel| FINAGLGRV(oModel)}/*Commit*/)
	oMaster := FWFormModelStruct():New()
	oImpos  := FStructIMP(1,oModel)

	//Criado master falso para a alimentação dos detail.
	oMaster:AddTable('TITMASTER',,"Aglutinação de Impostos" )
	oMaster:AddField("IDPROC"  ,"","IDPROC"  ,"C",20,0,/*bValid*/,/*When*/,/*aValues*/,.F.,{||""} ,/*Key*/,.F.,.T.,)

	oModel:AddFields('TITMASTER', /*cOwner*/, oMaster , , ,{|o|{}} )
	oModel:AddGrid("IMPDETAIL"  ,"TITMASTER", oImpos, /*bLinePre*/, bLinePost, /*bPre*/, /*bLinePost*/, /*bLoadIMP*/ )	

	//Cria os modelos relacionados.
	oModel:SetPrimaryKey( {} )
	
	oModel:GetModel('TITMASTER'):SetOnlyQuery(.T.)
	oModel:GetModel('IMPDETAIL'):SetNoDeleteLine( .T. )
	oMaster:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oModel:SetActivate( {|oModel| LoadIMP(oModel) } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} FStructIMP()
Retorna estrutura do tipo FWformModelStruct.

@author pequim

@since 05/12/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static function FStructIMP(nStruc,oModel) As Object

	Local oStruct  As Object
	Local nTamFor  As Numeric
	Local nTamLoj  As Numeric
	Local nTamCod  As Numeric
	Local nTamNat  As Numeric
	Local nTamTip  As Numeric
	Local nTamFil  As Numeric
	Local cPictVal As Character
	Local cVldNat  As Character
	Local cVldDt   As Character
	Local cVldFil  As Character
	Local cVldTip  As Character

	oStruct  := NIL
	nTamFor  := TamSx3("E2_FORNECE")[1]
	nTamLoj  := TamSx3("E2_LOJA")[1]
	nTamCod  := TamSx3("E2_CODRET")[1]
	nTamNat  := TamSx3("E2_NATUREZ")[1]
	nTamTip  := TamSx3("E2_TIPO")[1]
	nTamFil  := TamSx3("E2_FILIAL")[1]
	cPictVal := PesqPict("SE2","E2_VALOR")
	cVldNat  := "F382VldNat()"
	cVldDt   := "F382VldVen()"
	cVldFil  := "F382VldFil(oModel)"
	cVldTip  := "F382VldTip()"	

	If nStruc == 1		//Model

		oStruct		:= FWFormModelStruct():New()

		//Criado Grid falso para a alimentação dos detail.
		oStruct:AddTable('FK0',,"Titulos a Gerar" )
		oStruct:AddField( "Imposto" 		,"Imposto"		    , 'IMPOSTO'	, 'C', nTamFor	, 0, 		      ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	
		oStruct:AddField( "Fornecedor" 		,"Fornecedor"		, 'FORNECE'	, 'C', nTamFor	, 0, 			  ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	
		oStruct:AddField( "Loja" 			,"Loja"				, 'LOJA' 	, 'C', nTamLoj	, 0, 			  ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	
		oStruct:AddField( "Valor"			,"Valor"			, 'VALOR' 	, 'N', 16	    , 2, 			  ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	            
		oStruct:AddField( "Cod. Retenção"	,"Cod.Retenção" 	, 'CODRET' 	, 'C', nTamCod	, 0,              ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .F.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )
		oStruct:AddField( "Tipo" 		    ,"Tipo"			    , 'TIPO'	, 'C', nTamTip	, 0, {||&cVldTip} ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".T.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )		         
		oStruct:AddField( "Natureza" 		,"Natureza"			, 'NATUREZ'	, 'C', nTamNat	, 0, {||&cVldNat} ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".T.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	
		oStruct:AddField( "Data Vencimento" ,"Data Vencimento"	, 'VENCTO' 	, 'D', 8		, 0, {||&cVldDt}  ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".T.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	
		oStruct:AddField( "Filial Destino"	,"Filial Destino"	, 'FILORIG' , 'C', nTamFil	, 0, {||&cVldFil} ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".T.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	
		oStruct:AddField( "Descr. Filial"	,"Descr. Filial"	, 'DESCFIL' , 'C', 50	    , 0,              ,FWBuildFeature( STRUCT_FEATURE_WHEN, ".F.") , {}, .T.,FWBuildFeature( STRUCT_FEATURE_INIPAD, "") , .F., .F., .F., , )	

		oStruct:SetProperty('NATUREZ',MODEL_FIELD_OBRIGAT, .T.)
		oStruct:SetProperty('VENCTO' ,MODEL_FIELD_OBRIGAT, .T.)
		oStruct:SetProperty('FILORIG',MODEL_FIELD_OBRIGAT, .T.)

		aAux := FwStruTrigger(;
			"FILORIG", ;                                                     // [01] Id do campo de origem
			"DESCFIL" , ;                                                   // [02] Id do campo de destino
			'ALLTRIM(FWFilialName(cEmpAnt, M->FILORIG))')

		oStruct:AddTrigger( ;
			aAux[1], ;                                                      // [01] Id do campo de origem
			aAux[2], ;                                                      // [02] Id do campo de destino
			aAux[3], ;                                                      // [03] Bloco de codigo de validação da execução do gatilho
			aAux[4] )                                                       // [04] Bloco de codigo de execução do gatilho
			
	ElseIf nStruc == 2		//View

		oStruct:= FWFormViewStruct():New()

		oStruct:AddField( "IMPOSTO"	,"01", "Imposto" 	    , "Imposto"		    , NIL, "G",    "@!",/*bPictVar*/,		  ,.F./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "FORNECE"	,"02", "Fornecedor" 	, "Fornecedor"		, NIL, "G",    "@!",/*bPictVar*/,		  ,.F./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "LOJA" 	,"03", "Loja" 			, "Loja"			, NIL, "G",    "@!",/*bPictVar*/,		  ,.F./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "VALOR"	,"04", "Valor"			, "Valor"			, NIL, "G",cPictVal,/*bPictVar*/,		  ,.F./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "CODRET"	,"05", "Cod. Retenção"	, "Cod. Retenção"	, NIL, "G",    "@!",/*bPictVar*/,		  ,.F./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "TIPO"	,"06", "Tipo"		    , "Tipo"    		, NIL, "G",    "@!",/*bPictVar*/,"05"     ,.T./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "NATUREZ"	,"07", "Natureza"		, "Natureza"		, NIL, "G",    "@!",/*bPictVar*/,"SED"	  ,.T./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "VENCTO"	,"08", "Data Vencimento", "Data Vencimento" , NIL, "G",    "@!",/*bPictVar*/,		  ,.T./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "FILORIG"	,"09", "Filial Destino" , "Filial Destino"	, NIL, "G",    "@!",/*bPictVar*/,"FWSM0"  ,.T./*lCanChange*/,/*cFolder*/)
		oStruct:AddField( "DESCFIL"	,"10", "Descr. Filial"  , "Descr. Filial"	, NIL, "G",    "@!",/*bPictVar*/,    	  ,.F./*lCanChange*/,/*cFolder*/)

	Endif

Return oStruct


//-------------------------------------------------------------------
/*/ {Protheus.doc} LoadIMP
Funcao de carregamento das informacoes de baixas

@param oGridModel - Model que chamou o bLoad

@author Mauricio Pequim Jr/Fabio Casagrande
@since 22/11/2017

/*/
//-------------------------------------------------------------------
Static Function LoadIMP(oModel) 

	Local oView   As Object
	Local oMstIMP As Object
	Local oSubIMP As Object
	Local nX      As Numeric

	oView := FWViewActive()
	oMstIMP := oModel:GetModel("TITMASTER")
	oSubIMP := oModel:GetModel("IMPDETAIL")
	nX := 0	

	// Prepara estrutura de composicao do grid
	For nX := 1 to Len(__aImpos)

		If !oSubIMP:IsEmpty() .And. oSubIMP:CanInsertLine()
			//Inclui a quantidade de linhas necessárias
			oSubIMP:AddLine()		
			//Vai para linha criada
			oSubIMP:GoLine( oSubIMP:Length() )	
		Endif	

		oMstIMP:LoadValue("IDPROC" ,'1')

		oSubIMP:LoadValue("IMPOSTO" ,__aImpos[nX,1])
		oSubIMP:LoadValue("FORNECE" ,__aImpos[nX,2])
		oSubIMP:LoadValue("LOJA" 	,__aImpos[nX,3])
		oSubIMP:LoadValue("VALOR" 	,__aImpos[nX,4])
		oSubIMP:LoadValue("CODRET"	,__aImpos[nX,5])
		oSubIMP:LoadValue("TIPO"	,__aImpos[nX,6])		
		oSubIMP:LoadValue("NATUREZ"	,__aImpos[nX,7])
		oSubIMP:LoadValue("VENCTO"	,__aImpos[nX,8])
		oSubIMP:LoadValue("FILORIG"	,__aImpos[nX,9])
		oSubIMP:LoadValue("DESCFIL"	,FWFilialName(cEmpAnt,__aImpos[nX,9]))

	Next

	oSubIMP:SetNoInsertLine( .T. )	

Return 


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FINMRETGRV
Gravação do modelo de dados.

@author Mauricio Pequim Jr/Fabio Casagrande
@since  07/12/2017
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FINAGLGRV() As Logical

	Local oModel  As Object
	Local oSubIMP As Object
	Local oSubMst As Object
	Local nX      As Numeric
	Local dVencto As Date
	Local cNature As Character
	Local cFilDes As Character
	Local cTipo   As Character

	oModel  := FWModelActive()
	oSubIMP := oModel:GetModel("IMPDETAIL")
	oSubMst := oModel:GetModel("TITMASTER")

	nX := 0

	oSubMst:SetValue("IDPROC", "1" )	

	For nX := 1 To oSubIMP:Length()

		cTipo   := oSubIMP:GetValue("TIPO", nX )		
		cNature := oSubIMP:GetValue("NATUREZ", nX )	
		dVencto := oSubIMP:GetValue("VENCTO", nX ) 	
		cFilDes := oSubIMP:GetValue("FILORIG", nX )	

		__aImpos[nX,6] := cTipo	
		__aImpos[nX,7] := cNature		
		__aImpos[nX,8] := dVencto
		__aImpos[nX,9] := cFilDes		
		
	Next nX

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} F382VldTip()
Validação do Tipo de Título

@author Fabio Casagrande Lima
@since	03/04/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F382VldTip() as Logical

	Local cTipo     As Character
	Local cTipoAVld As Character
	Local lRet      As Logical

	cTipo		:= M->TIPO
	cTipoAVld	:= SuperGetMv("MV_TIPIMP",.T.,"ISS|INS|IRF|PIS|TX |COF|CSL")
	lRet		:= .F.

	If !Empty(cTipo)
		If SX5->(MsSeek(xFilial("SX5") + "05"+ cTipo ))
			lRet := (cTipo $ cTipoAVld)
		Endif
		
		If !lRet
			HELP(' ',1,"COD_TIPO" ,,STR0073 ,2,0,,,,,, {STR0074}) //"O tipo de título informado não é válido."###"Por favor, informe um tipo válido ou utilize a consulta (F3)."
			lRet := .F.
		Endif
	Endif	

	If lRet //Atualiza informação no array
		FINAGLGRV()
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F382VldVen()
Validação do Tipo de Título

@author Fabio Casagrande Lima
@since	03/04/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F382VldVen() as Logical

	Local lRet As Logical

	lRet := .T.

	If M->VENCTO<dDatabase
		HELP(' ',1,"DTVENC382" ,,STR0082,2,0,,,,,, {STR0083}) //"O vencimento informado não é válido."###""Por favor, informe uma data igual ou posterior a data base do sistema."
		lRet := .F.
	Endif	

	If lRet //Atualiza informação no array
		FINAGLGRV()
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F382VldVen()
Validação do Tipo de Título

@author Fabio Casagrande Lima
@since	03/04/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F382VldNat() as Logical

	Local lRet    As Logical
	Local oVld1   As Object 
	Local oVld2   As Object 
	Local cFilDes As Character 

	lRet := .T.
	oVld1 := FWModelActive()
	oVld2 := oVld1:GetModel("IMPDETAIL")
	cFilDes := oVld2:GetValue("FILORIG")

	cFilAnt := cFilDes //Seta filial da linha como vigente para validar corretamente considerando o compartilhamento da SED

	If !FinVldNat( .T. )
		lRet := .F.
	Endif	

	If lRet //Atualiza informação no array
		FINAGLGRV()
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F382VldFil()
Validação da filial

@author Fabio Casagrande Lima
@since	03/04/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F382VldFil(oModel) as Logical

	Local cFil     As Character
	Local lRet      As Logical
	Local cNatur    As Character

	cFil	:= M->FILORIG
	//cNatur	:= oModel:GetValue("IMPDETAIL","NATUREZ")
	lRet	:= .T.

	If Empty(cFil) .or. !ExistCpo('SM0',cEmpAnt + M->FILORIG)
		lRet := .F.
	Endif

	If lRet //Atualiza informação no array
		FINAGLGRV()
		cFilAnt := cFil //Seta filial destino como corrente para que funcione corretamente a consulta padrão
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F382LINE()
Validação da filial

@author Fabio Casagrande Lima
@since	03/04/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function F382LINE(oModel) as Logical

	Local cFil      As Character
	Local lRet      As Logical
	Local nTamEmp   As Numeric
	Local cNatur    As Character
	Local cFilOri   As Character

	lRet    := .T.
	cFil	:= oModel:GetValue("IMPDETAIL","FILORIG")
	cNatur	:= oModel:GetValue("IMPDETAIL","NATUREZ")
	cFilOri := cFilAnt

	cFilAnt := cFil //Seta filial destino como corrente para que funcione a consulta padrão de acordo com o compartilhamento da SED
	
	//Verifica se a natureza é valida para a filial destino
	If !SED->(MsSeek(xFilial('SED',cFil)+cNatur))
		HELP(' ',1,"AVISNAT2" ,,STR0084,2,0,,,,,, {STR0085}) //"A natureza informada não é válida." ###""Por favor, informe uma natureza valida de acordo com a filial destino.
		lRet := .F.
	Endif

	cFilAnt := cFilOri

Return lRet


