#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BFD
Funcao para abrir a tela de cadastro de Grupos de Cobertura Procedimentos da Familia
Procedimentos/Co-Participação
@author DEV TOTVS
@since 10/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BFD(lAutomato)

    Local oBrowse
    Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BFD' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BFD 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

    Private aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BFD 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel         := NIL
	Local oStruBA1      := FWFormStruct(1,'BA1')
    Local oStruBFD      := FWFormStruct(1,'BFD')
    Local oStruBVF      := FWFormStruct(1,'BVF')
    Local aAux          := NIL
    Local aAuxBVF       := NIL   
    Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBFD	:= {"BFD_CODINT","BFD_CODEMP","BFD_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBVF	:= {"BVF_CODINT","BVF_CODEMP","BVF_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx 
    // Cria o objeto do Modelo de Dados	 
    oModel := MPFormModel():New('PLSA260BFD')

    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
        oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBFD)
        oStruBFD := CriaCampMVC(1,oStruBFD,aCamposBFD[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBVF)
        oStruBVF := CriaCampMVC(1,oStruBVF,aCamposBVF[nNx]) 
    Next

    //FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic )
    aAux := FwStruTrigger(;
        'BFD_CLACAR'     ,; 
        'BFD_DESCAR'     ,; 
        'BDL->BDL_DESCRI',;
        .F.              ,; 
        'BDL'            ,; 
        1                ,; 
        ''               ,;
        '')

    oStruBFD:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

    aAuxBVF := FwStruTrigger(;
        'BVF_TIPUSR'     ,; 
        'BVF_DESTIP'     ,; 
        'BIH->BIH_DESCRI',;
        .F.              ,; 
        'BIH'            ,; 
        1                ,; 
        ''               ,;
        '')

    oStruBVF:AddTrigger( aAuxBVF[1], aAuxBVF[2], aAuxBVF[3], aAuxBVF[4])

    aAuxBVF := FwStruTrigger(;
        'BVF_GRAUPA'     ,; 
        'BVF_DESGRA'     ,; 
        'BRP->BRP_DESCRI',;
        .F.              ,; 
        'BRP'            ,; 
        1                ,; 
        ''               ,;
        '')

    oStruBVF:AddTrigger( aAuxBVF[1], aAuxBVF[2], aAuxBVF[3], aAuxBVF[4])

    aAuxBVF := FwStruTrigger(;
        'BVF_FINATE'     ,; 
        'BVF_DESFIN'     ,; 
        'BGY->BGY_DESCRI',;
        .F.              ,; 
        'BGY'            ,; 
        1                ,; 
        ''               ,;
        '')

    oStruBVF:AddTrigger( aAuxBVF[1], aAuxBVF[2], aAuxBVF[3], aAuxBVF[4])
    
	oModel:addFields("BA1MASTER" , ,oStruBA1)
    oModel:AddGrid("BFDDETAIL" , "BA1MASTER", oStruBFD)
    oModel:AddGrid("BVFDETAIL" , "BFDDETAIL", oStruBVF)
	
    oModel:GetModel("BFDDETAIL"):SetOptional(.T.)
    oModel:GetModel("BVFDETAIL"):SetOptional(.T.)

	oModel:SetRelation( "BFDDETAIL", { {"BFD_FILIAL", 'xFilial("BFD")' },;
									{ "BFD_CODINT"	, "BA1_CODINT" },;
									{ "BFD_CODEMP"	, "BA1_CODEMP" },;
									{ "BFD_MATRIC"	, "BA1_MATRIC" } },;									
                                    BFD->( IndexKey(  ) ) ) 
    
    oModel:SetRelation( 'BVFDETAIL', { { 'BVF_FILIAL', 'xFilial( "BVF" )' },;
									{ "BVF_CODINT"	 , "BFD_CODINT" },;
									{ "BVF_CODEMP"	 , "BFD_CODEMP" },;
                                    { "BVF_MATRIC"	 , "BFD_MATRIC" },;
                                    { "BVF_CODPSA"	 , "BFD_CODPSA" },;
									{ "BVF_CODPAD"	 , "BFD_CODPAD" } },;									
									BVF->( IndexKey(  ) ) )  
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel("BA1MASTER"):SetDescription("Familia" )
    oModel:GetModel("BFDDETAIL"):SetDescription("Procedimentos" )
    oModel:GetModel("BVFDETAIL"):SetDescription("Co-Participação" )

	oModel:GetModel("BA1MASTER"):SetOnlyQuery(.T.)
    oModel:GetModel("BA1MASTER"):SetOnlyView(.T.)		
    
    oModel:SetPrimaryKey( { "BFD_FILIAL", "BFD_CODINT", "BFD_CODEMP", "BFD_MATRIC","BFD_CODPSA", "BFD_CODPAD" } )

    oStruBFD:setProperty( 'BFD_CODINT', MODEL_FIELD_INIT, { || BA1->BA1_CODINT} )
	oStruBFD:setProperty( 'BFD_CODEMP', MODEL_FIELD_INIT, { || BA1->BA1_CODEMP} )
	oStruBFD:setProperty( 'BFD_MATRIC', MODEL_FIELD_INIT, { || BA1->BA1_MATRIC} )
	
    oStruBFD:setProperty("BFD_CODPSA", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BFD_CODPSA"), AtuVarBFD(oModel)})
    oStruBFD:setProperty("BFD_CODPAD", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BFD_CODPAD")})
    
    oStruBFD:setProperty("BFD_CLACAR", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BFD_CLACAR")})            
    oStruBFD:setProperty("BFD_CODTAB", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BFD_CODTAB")})
    
    oStruBFD:setProperty("BFD_NIVCAR", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BFDDETAIL","BFD_CARENC") == 0 })
    oStruBFD:setProperty("BFD_PERCOP", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BFDDETAIL","BFD_VALCOP") == 0 })
    oStruBFD:setProperty("BFD_VALCOP", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BFDDETAIL","BFD_PERCOP") == 0 })

    oStruBVF:setProperty( 'BVF_CODINT', MODEL_FIELD_INIT, { || BA1->BA1_CODINT} )
	oStruBVF:setProperty( 'BVF_CODEMP', MODEL_FIELD_INIT, { || BA1->BA1_CODEMP} )
	oStruBVF:setProperty( 'BVF_MATRIC', MODEL_FIELD_INIT, { || BA1->BA1_MATRIC} )
	
    oStruBVF:setProperty("BVF_CODPSA", MODEL_FIELD_INIT ,{ || oModel:GetValue("BFDDETAIL","BFD_CODPSA")})
    oStruBVF:setProperty("BVF_CODPAD", MODEL_FIELD_INIT ,{ || oModel:GetValue("BFDDETAIL","BFD_CODPAD")})
    oStruBVF:setProperty("BVF_TIPUSR", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BVF_TIPUSR")})
    oStruBVF:setProperty("BVF_GRAUPA", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BVF_GRAUPA")})         
    
    oStruBVF:setProperty("BVF_IDAINI", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BVF_IDAINI")})
    oStruBVF:setProperty("BVF_IDAFIN", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BVF_IDAFIN")})
    oStruBVF:setProperty("BVF_FINATE", MODEL_FIELD_VALID,{ || BFDValid(oModel,"BVF_FINATE")})
    oStruBVF:setProperty("BVF_PERCOP", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BVFDETAIL","BVF_VALCOP") == 0   })
    oStruBVF:setProperty("BVF_VALCOP", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BVFDETAIL","BVF_PERCOP") == 0   })
    oStruBVF:setProperty("BVF_VALUS" , MODEL_FIELD_WHEN ,{ || oModel:GetValue("BVFDETAIL","BVF_PERCOP") > 0    })
    oStruBVF:setProperty("BVF_SOMCOM", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BVFDETAIL","BVF_PAGATO")$"0, "  })
    oStruBVF:setProperty("BVF_PAGATO", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BVFDETAIL","BVF_SOMCOM")$"0, "  })
    oStruBVF:setProperty("BVF_RDAPRE", MODEL_FIELD_WHEN ,{ || oModel:GetValue("BVFDETAIL","BVF_RDACRE") == "1" })    
    oStruBVF:setProperty("BVF_VIGINI", MODEL_FIELD_VALID,{ || PlsVldBVFMvc(oModel) })
    oStruBVF:setProperty("BVF_VIGFIN", MODEL_FIELD_VALID,{ || PlsVldBVFMvc(oModel) })    
    
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA1 := FWFormStruct(2,"BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|" } )
    Local oStruBFD := FWFormStruct(2,"BFD")	
    Local oStruBVF := FWFormStruct(2,"BVF")
    Local oModel   := FWLoadModel( "PLSA260BFD" )
    Local oView
    Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx

    oView := FWFormView():New()
    
    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
        oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
    Next

    oView:SetModel( oModel )        
	
    oView:AddField("VIEW_BA1" ,oStruBA1, "BA1MASTER")
    oView:AddGrid( "VIEW_BFD" ,oStruBFD, "BFDDETAIL")
    oView:AddGrid( "VIEW_BVF" ,oStruBVF, "BVFDETAIL")       
    
    oStruBA1:SetNoFolder()
    oStruBFD:SetNoFolder()
    oStruBVF:SetNoFolder()

	oView:CreateHorizontalBox("SUPERIOR", 20)
    oView:CreateHorizontalBox("INFERIOR", 35)
    oView:CreateHorizontalBox("RODAPE"  , 45)
	
	oView:SetOwnerView("VIEW_BA1", "SUPERIOR")
    oView:SetOwnerView("VIEW_BFD", "INFERIOR")
    oView:SetOwnerView("VIEW_BVF", "RODAPE")
	
	oView:EnableTitleView("VIEW_BA1","Familia")
    oView:EnableTitleView("VIEW_BFD","Procedimentos")
    oView:EnableTitleView("VIEW_BVF","Co-Participação")

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} AtuVarBFD
Inicializa campos
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------
Function AtuVarBFD(oModel)

    Local cCodPAD := oModel:GetValue("BFDDETAIL","BFD_CODPAD")
    Local cCodPSA := oModel:GetValue("BFDDETAIL","BFD_CODPSA")

    If !Empty(oModel:GetValue("BFDDETAIL","BFD_CODPSA"))
        oModel:GetModel("BVFDETAIL"):LoadValue("BVF_CODPSA", cCodPSA)
        oModel:GetModel("BVFDETAIL"):LoadValue("BVF_CODPAD", cCodPAD)
    EndIf

Return .T.

//----------------------------------------------------------------
/*/{Protheus.doc} PlsVldBVFMvc
Inicializa campos
Substitui a função PlsVldBVF
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------

Function PlsVldBVFMvc(oModel)

    Local lRet     := .T.
    Local aArea	   := GetArea()

        lRet := PLSVLDVIGMvc("BVF",oModel)

    RestArea(aArea)

Return lRet

//----------------------------------------------------------------
/*/{Protheus.doc} BFDValid
Função para Validar os Campos da Tabela BFD
@author  DEV TOTVS
@version P12
@since   09/01/20
/*/
//----------------------------------------------------------------

Function BFDValid(oModel,cCampo)

    Local lRet      := .F.

    If cCampo == "BVF_IDAINI"
        lRet := (Positivo(oModel:GetValue("BVFDETAIL","BVF_IDAINI")) .And. oModel:GetValue("BVFDETAIL","BVF_IDAINI") <= oModel:GetValue("BVFDETAIL","BVF_IDAFIN"))
    
    ElseIf cCampo == "BVF_IDAFIN"
        lRet := (Positivo( oModel:GetValue("BVFDETAIL","BVF_IDAFIN")) .And. If(Empty(oModel:GetValue("BVFDETAIL","BVF_IDAINI")),.T.,; // Branco retorna True
                oModel:GetValue("BVFDETAIL","BVF_IDAFIN") >= oModel:GetValue("BVFDETAIL","BVF_IDAINI"))) // Se não
    
    ElseIf cCampo == "BVF_TIPUSR"
        lRet := If(Empty(oModel:GetValue("BVFDETAIL","BVF_TIPUSR")),.T.,;
                ExistCpo("BIH",oModel:GetValue("BVFDETAIL","BVF_TIPUSR"),1))
    
    ElseIf cCampo == "BVF_GRAUPA"
        lRet := If(Empty(oModel:GetValue("BVFDETAIL","BVF_GRAUPA")),.T.,ExistCpo("BRP",oModel:GetValue("BVFDETAIL","BVF_GRAUPA"),1))

    ElseIf cCampo == "BVF_FINATE"
        lRet := Vazio() .Or. BGY->(ExistCpo("BGY",BA1->BA1_CODINT+oModel:GetValue("BVFDETAIL","BVF_FINATE"),1))

    ElseIf cCampo == "BFD_CODPSA"
        lRet := ExistCpo("BR8",oModel:GetValue("BFDDETAIL","BFD_CODPAD") +;
                oModel:GetValue("BFDDETAIL","BFD_CODPSA"),1) .And. PLSGATNIV(oModel:GetValue("BFDDETAIL","BFD_CODPAD");
                ,oModel:GetValue("BFDDETAIL","BFD_CODPSA"),"BFD",,,,"BFDDETAIL")

    ElseIf cCampo == "BFD_CODPAD"
        lRet := ExistCpo("BR4",oModel:GetValue("BFDDETAIL","BFD_CODPAD"),1) .And. ;
                ExistChav("BR8",oModel:GetValue("BFDDETAIL","BFD_CODPAD")+oModel:GetValue("BFDDETAIL","BFD_CODPSA"),1)

    ElseIf cCampo == "BFD_CLACAR"
        lRet := If(Empty(oModel:GetValue("BFDDETAIL","BFD_CLACAR")),.T.,PlsSeek("BDL",1,PLSINTPAD()+;
                oModel:GetValue("BFDDETAIL","BFD_CLACAR"),"BFD_DESCAR","BDL_DESCRI"))

    ElseIf cCampo == "BFD_CODTAB"
        lRet := ExistCpo("BF8",oModel:GetValue("BFDDETAIL","BFD_CODTAB"),1)

    EndIf

Return lRet