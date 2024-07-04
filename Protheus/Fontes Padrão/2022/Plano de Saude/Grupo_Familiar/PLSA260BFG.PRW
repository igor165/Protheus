#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BFG
Funcao para abrir a tela de cadastro de Grupos de Cobertura do
Beneficiario. Grupos Determinados->Classe de Carência/Co-participação
@author Totver
@since 17/09/19
@version P12.
/*/
//-------------------------------------------------------------------
Function PLSA260BFG(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BFG' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BFG 
@author  Totver
@version P12
@since   17/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BFG 
@author  Totver
@version P12
@since   17/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1      := FWFormStruct(1,'BA1')
    Local oStruBFG      := FWFormStruct(1,'BFG')
    Local oStruBVM      := FWFormStruct(1,'BVM')        
    Local aAux          := NIL
    Local aAuxBVM       := NIL
    Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBFG	:= {"BFG_CODINT","BFG_CODEMP","BFG_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBVM	:= {"BVM_CODINT","BVM_CODEMP","BVM_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx
    // Cria o objeto do Modelo de Dados	 
    oModel := MPFormModel():New('PLSA260BFG')

    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
        oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBFG)
        oStruBFG := CriaCampMVC(1,oStruBFG,aCamposBFG[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBVM)
        oStruBVM := CriaCampMVC(1,oStruBVM,aCamposBVM[nNx]) 
    Next
    
    //FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic 

    aAuxBVM := FwStruTrigger(;
        'BVM_FINATE'     ,; 
        'BVM_DESFIN'     ,; 
        'BGY->BGY_DESCRI',;
        .T.              ,; 
        'BGY'            ,; 
        1                ,; 
        'XFILIAL("BGY")+PLSINTPAD()+ FWFldGet("BVM_FINATE")',;
        '')

    oStruBVM:AddTrigger( aAuxBVM[1], aAuxBVM[2], aAuxBVM[3], aAuxBVM[4])

	oModel:addFields("BA1MASTER" , ,oStruBA1)
    oModel:AddGrid("BFGDETAIL","BA1MASTER", oStruBFG )
    oModel:AddGrid('BVMDETAIL','BFGDETAIL',oStruBVM,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - */)   
    
   
    oModel:GetModel("BFGDETAIL"):SetOptional(.T.)
    oModel:GetModel("BVMDETAIL"):SetOptional(.T.)

	oModel:SetRelation( "BFGDETAIL", { {"BFG_FILIAL", 'xFilial("BFG")' },;
									{ "BFG_CODINT"	, "BA1_CODINT" },;
                                    { "BFG_CODEMP"	, "BA1_CODEMP" },;
                                    { "BFG_MATRIC"	, "BA1_MATRIC" },;
									{ "BFG_TIPREG"	, "BA1_TIPREG" } },;									
                                    BFG->( IndexKey(  ) ) )
    
    oModel:SetRelation( 'BVMDETAIL', { { 'BVM_FILIAL', 'xFilial( "BVM" )'},;
									{ "BVM_CODINT"	 , "BFG_CODINT" },;
									{ "BVM_CODEMP"	 , "BFG_CODEMP" },;
                                    { "BVM_MATRIC"	 , "BFG_MATRIC" },;                                    
									{ "BVM_TIPREG"	 , "BFG_TIPREG" } },;									
                                    BVM->( IndexKey(  ) ) )                                                      
	
    oModel:SetDescription(FunDesc())	
	
	oModel:GetModel("BA1MASTER"):SetDescription("Familia" )
    oModel:GetModel("BFGDETAIL"):SetDescription("Procedimentos")
    oModel:GetModel("BVMDETAIL"):SetDescription("Co-Participação")

	oModel:GetModel("BA1MASTER"):SetOnlyQuery(.T.)
    oModel:GetModel("BA1MASTER"):SetOnlyView(.T.)		
    
    oModel:SetPrimaryKey( { "BFG_FILIAL", "BFG_CODINT", "BFG_CODEMP", "BFG_MATRIC", "BFG_TIPREG", "BFG_CODPSA", "BFG_CODPAD" } )
    
    oStruBFG:setProperty('BFG_TIPREG', MODEL_FIELD_INIT, { || BA1->BA1_TIPREG } )
    oStruBFG:setProperty('BFG_CODPSA', MODEL_FIELD_VALID,{ || ExistCpo("BR8",oModel:GetValue("BFGDETAIL","BFG_CODPAD")+oModel:GetValue("BFGDETAIL","BFG_CODPSA"),1);
                        .AND. PLSGATNIV(oModel:GetValue("BFGDETAIL","BFG_CODPAD"),oModel:GetValue("BFGDETAIL","BFG_CODPSA"),"BFG",,,,"BFGDETAIL")  .AND.  PLSVLDCOLMvc(oModel) } )
    

    oStruBFG:setProperty('BFG_DESPAD', MODEL_FIELD_INIT, { || Posicione("BR4",1,xFilial("BR4")+If(Inclui,"",GETMV("MV_PLSTBPD")),"BR4_DESCRI")  } )
    
    oStruBFG:setProperty('BFG_CLACAR', MODEL_FIELD_VALID, { || If(Empty(oModel:GetValue("BFGDETAIL","BFG_CLACAR")),.T.,PlsSeek("BDL",1,PLSINTPAD()+;
                         oModel:GetValue("BFGDETAIL","BFG_CLACAR"),"BFG_DESCAR","BDL_DESCRI")) .AND.  PLSVLDCOLMvc(oModel) } )
    
    //oStruBFG:setProperty('BFG_DESCAR', MODEL_FIELD_INIT, { || If(Inclui,"",Posicione("BDL",1,xFilial("BDL")+BA1->BA1_CODINT+oModel:GetValue("BFGDETAIL","BFG_CLACAR"),"BDL_DESCRI"))} )
    oStruBFG:setProperty( 'BFG_NIVCAR',  MODEL_FIELD_WHEN  , { || oModel:GetValue("BFGDETAIL","BFG_CARENC") == 0 } )
    oStruBFG:setProperty( 'BFG_PERCOP',  MODEL_FIELD_WHEN  , { || oModel:GetValue("BFGDETAIL","BFG_VALCOP") == 0 } )
    oStruBFG:setProperty( 'BFG_VALCOP',  MODEL_FIELD_WHEN  , { || oModel:GetValue("BFGDETAIL","BFG_PERCOP") == 0 } )
    oStruBVM:setProperty( 'BVM_TIPREG', MODEL_FIELD_INIT  , { || BA1->BA1_TIPREG } )
    oStruBVM:setProperty( 'BVM_CODPSA', MODEL_FIELD_INIT  , { || oModel:GetValue("BFGDETAIL","BFG_CODPSA") } )
    oStruBVM:setProperty( 'BVM_CODPAD', MODEL_FIELD_INIT  , { || oModel:GetValue("BFGDETAIL","BFG_CODPAD") } )
    oStruBVM:setProperty( 'BVM_CODTAB', MODEL_FIELD_VALID , { || Vazio() .or. ExistCpo("BF8",oModel:GetValue("BVMDETAIL","BVM_CODTAB"),1) } )
    oStruBVM:setProperty( 'BVM_VIGDE' , MODEL_FIELD_VALID , { || PlsVldBVMMvc(oModel) } )
    oStruBVM:setProperty( 'BVM_VIGATE', MODEL_FIELD_VALID , { || PlsVldBVMMvc(oModel) } )
    oStruBVM:setProperty( 'BVM_FINATE', MODEL_FIELD_VALID , { || Vazio() .or. BGY->(ExistCpo("BGY",BA1->BA1_CODINT+oModel:GetValue("BVMDETAIL","BVM_FINATE"),1)) .AND.  PLSVLDCOLMvc(oModel) } )
    oStruBVM:setProperty( 'BVM_DESFIN', MODEL_FIELD_VALID , { || .T.} )
    oStruBVM:setProperty( 'BVM_PERCOP', MODEL_FIELD_WHEN  , { || oModel:GetValue("BVMDETAIL", "BVM_VALCOP")==0 })
    oStruBVM:setProperty( 'BVM_VALCOP', MODEL_FIELD_WHEN  , { || oModel:GetValue("BVMDETAIL", "BVM_PERCOP")==0 })
    oStruBVM:setProperty( 'BVM_VALUS' , MODEL_FIELD_WHEN  , { || oModel:GetValue("BVMDETAIL", "BVM_PERCOP") >0 })
    oStruBVM:setProperty( 'BVM_SOMCOM', MODEL_FIELD_WHEN  , { || oModel:GetValue("BVMDETAIL", "BVM_PAGATO") $"0, " }) 
    oStruBVM:setProperty( 'BVM_PAGATO', MODEL_FIELD_WHEN  , { || oModel:GetValue("BVMDETAIL", "BVM_SOMCOM") $"0, " })
            
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P12
@since   17/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  
	Local oStruBA1 := FWFormStruct(2,"BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR|" } )
    Local oStruBFG := FWFormStruct(2,"BFG")	
    Local oStruBVM := FWFormStruct(2,"BVM")	    
    Local oModel   := FWLoadModel( "PLSA260BFG" )
    Local oView
    Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx

    oView := FWFormView():New()
    
    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
        oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
    Next

    oView:SetModel(oModel)    
	
    oView:AddField("VIEW_BA1",oStruBA1, "BA1MASTER" )
    oView:AddGrid("VIEW_BFG" ,oStruBFG, "BFGDETAIL" )
    oView:AddGrid("VIEW_BVM" ,oStruBVM, "BVMDETAIL" )           
    
    oStruBA1:SetNoFolder()
    oStruBFG:SetNoFolder()
    oStruBVM:SetNoFolder()    

	oView:CreateHorizontalBox( 'SUPERIOR', 30) 
	oView:CreateHorizontalBox( 'MEIO'	 , 40) 
	oView:CreateHorizontalBox( 'INFERIOR', 30)	
	
	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BFG', 'MEIO')	
	oView:SetOwnerView('VIEW_BVM', 'INFERIOR')	
	
	oView:EnableTitleView("VIEW_BA1","Familia")
    oView:EnableTitleView("VIEW_BFG","Procedimentos")
    oView:EnableTitleView("VIEW_BVM","Co-Participação")

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} PlsVldBVMMvc
Define o modelo de dados da aplicação 
@author  Totver
@version P12
@since   18/09/19
/*/
//----------------------------------------------------------------
Function PlsVldBVMMvc(oModel)
Local lRet     := .T.
Local aArea	   := GetArea()

lRet := PLSVLDVIGMvc("BVM",oModel)

RestArea(aArea)

Return(lRet)



//----------------------------------------------------------------
/*/{Protheus.doc} PLSVLDCOLMvc
Validação de registros repetidos no grid 
@author  Totver
@version P12
@since   19/09/19
/*/
//----------------------------------------------------------------
Static Function PLSVLDCOLMvc(oModel)
Local lRet    := .T.
Local cCodPsa := oModel:GetValue("BFGDETAIL","BFG_CODPSA") 
Local cCodPad := oModel:GetValue("BFGDETAIL","BFG_CODPAD")

oModel:SetValue("BVMDETAIL","BVM_CODPAD",cCodPad) 
oModel:SetValue("BVMDETAIL","BVM_CODPSA",cCodPsa)


Return lRet
