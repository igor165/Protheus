#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BFE
Funcao para abrir a tela de cadastro de Grupos de Cobertura do
Beneficiario. Grupos Determinados->Classe de Carência/Co-participação
@author Totver
@since 17/09/19
@version P12.
/*/
//-------------------------------------------------------------------
Function PLSA260BFE(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BFE' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BFE 
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
Definicao do modelo MVC PLSA260BFE 
@author  Totver
@version P12
@since   17/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1      := FWFormStruct(1,'BA1')
    Local oStruBFE      := FWFormStruct(1,'BFE')
    Local oStruBVI      := FWFormStruct(1,'BVI')    
    Local oStruBVJ      := FWFormStruct(1,'BVJ')
    Local aAux          := NIL
    Local aAuxBVI       := NIL
    Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBFE	:= {"BFE_CODINT","BFE_CODEMP","BFE_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBVI	:= {"BVI_CODINT","BVI_CODEMP","BVI_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBVJ	:= {"BVJ_CODINT","BVJ_CODEMP","BVJ_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx
	//Local oEvent   := PL260BFEEVDEF():New()
    // Cria o objeto do Modelo de Dados	 
    oModel := MPFormModel():New('PLSA260BFE')

    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
        oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBFE)
        oStruBFE := CriaCampMVC(1,oStruBFE,aCamposBFE[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBVI)
        oStruBVI := CriaCampMVC(1,oStruBVI,aCamposBVI[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBVJ)
        oStruBVJ := CriaCampMVC(1,oStruBVJ,aCamposBVJ[nNx]) 
    Next
    
    //FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic )

    aAux := FwStruTrigger(;
        'BFE_CODGRU'     ,; 
        'BFE_DESGRU'     ,; 
        'BG7->BG7_DESCRI',;
        .F.              ,; 
        'BG7'            ,; 
        1                ,; 
        'xFilial("BG7")+BA1->BA1_CODINT+oModel:GetValue("BFEDETAIL","BFE_CODGRU")',;
        '')
    
    oStruBFE:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

    aAuxBVI := FwStruTrigger(;
        'BVI_CLACAR'     ,; 
        'BVI_DESCAR'     ,; 
        'BDL->BDL_DESCRI',;
        .F.              ,; 
        'BDL'            ,; 
        1                ,; 
        '',;
        '')
    oStruBVI:AddTrigger( aAuxBVI[1], aAuxBVI[2], aAuxBVI[3], aAuxBVI[4])

	oModel:addFields("BA1MASTER" , ,oStruBA1)
    oModel:AddGrid("BFEDETAIL","BA1MASTER", oStruBFE )
    oModel:AddGrid('BVIDETAIL','BFEDETAIL',oStruBVI,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:AddGrid("BVJDETAIL","BFEDETAIL", oStruBVJ )
	
    oModel:GetModel("BFEDETAIL"):SetOptional(.T.)
    oModel:GetModel("BVIDETAIL"):SetOptional(.T.)
    oModel:GetModel("BVJDETAIL"):SetOptional(.T.)    

	oModel:SetRelation( "BFEDETAIL", { {"BFE_FILIAL", 'xFilial("BFE")' },;
									{ "BFE_CODINT"	, "BA1_CODINT" },;
                                    { "BFE_CODEMP"	, "BA1_CODEMP" },;
                                    { "BFE_MATRIC"	, "BA1_MATRIC" },;
									{ "BFE_TIPREG"	, "BA1_TIPREG" } },;									
                                    BFE->( IndexKey(  ) ) ) 
    
    oModel:SetRelation( 'BVIDETAIL', { { 'BVI_FILIAL', 'xFilial( "BVI" )'},;
									{ "BVI_CODINT"	 , "BFE_CODINT" },;
									{ "BVI_CODEMP"	 , "BFE_CODEMP" },;
                                    { "BVI_MATRIC"	 , "BFE_MATRIC" },;
                                    { "BVI_TIPREG"	 , "BFE_TIPREG" },;
									{ "BVI_CODGRU"	 , "BFE_CODGRU" } },;									
                                    BVI->( IndexKey(  ) ) )  
                                    
    oModel:SetRelation( 'BVJDETAIL', { { 'BVJ_FILIAL', 'xFilial( "BVI" )' },;
									{ "BVJ_CODINT"	 , "BFE_CODINT" },;
									{ "BVJ_CODEMP"	 , "BFE_CODEMP" },;
                                    { "BVJ_MATRIC"	 , "BFE_MATRIC" },;
                                    { "BVJ_TIPREG"	 , "BFE_TIPREG" },;
									{ "BVJ_CODGRU"	 , "BFE_CODGRU" } },;									
									BVJ->( IndexKey(  ) ) )                                    
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel("BA1MASTER"):SetDescription("Familia" )
    oModel:GetModel("BFEDETAIL"):SetDescription("Grupos Determinados")
    oModel:GetModel("BVIDETAIL"):SetDescription("Classe de Carência")
    oModel:GetModel("BVJDETAIL"):SetDescription("Co-Participação")

	oModel:GetModel("BA1MASTER"):SetOnlyQuery(.T.)
    oModel:GetModel("BA1MASTER"):SetOnlyView(.T.)		
    
    oModel:SetPrimaryKey( { } )

    oStruBFE:setProperty( "BFE_CODINT", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODINT} )
    oStruBFE:setProperty( "BFE_CODEMP", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODEMP} )
    oStruBFE:setProperty( "BFE_MATRIC", MODEL_FIELD_INIT  ,{ || BA1->BA1_MATRIC} )

    oStruBFE:setProperty("BFE_CODGRU", MODEL_FIELD_VALID , { || ExistCpo("BG7",BA1->BA1_CODINT+oModel:GetValue("BFEDETAIL","BFE_CODGRU"),1) .AND. PLSVLDCOLMvc(oModel) })
    oStruBFE:setProperty("BFE_TIPREG", MODEL_FIELD_INIT  , { || BA1->BA1_TIPREG })
    oStruBVI:setProperty("BVI_CLACAR", MODEL_FIELD_VALID , { || PlsSeek("BDL",1,BA1->BA1_CODINT+oModel:GetValue("BVIDETAIL","BVI_CLACAR"),"BVI_DESCAR","BDL_DESCRI")})
    
    oStruBVI:setProperty( "BVI_CODINT", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODINT} )
    oStruBVI:setProperty( "BVI_CODEMP", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODEMP} )
    oStruBVI:setProperty( "BVI_MATRIC", MODEL_FIELD_INIT  ,{ || BA1->BA1_MATRIC} )
    
    
    oStruBVI:setProperty("BVI_TIPREG", MODEL_FIELD_INIT  , { || BA1->BA1_TIPREG })
    oStruBVI:setProperty("BVI_CODGRU", MODEL_FIELD_INIT  , { || oModel:GetValue("BFEDETAIL","BFE_CODGRU") })
    
    oStruBVJ:setProperty("BVJ_CODTAB", MODEL_FIELD_VALID , { || ExistCpo("BF8",oModel:GetValue("BVJDETAIL","BVJ_CODTAB"),1) })
    oStruBVJ:setProperty("BVJ_CODINT", MODEL_FIELD_INIT  , { || BA1->BA1_CODINT} )
    oStruBVJ:setProperty("BVJ_CODEMP", MODEL_FIELD_INIT  , { || BA1->BA1_CODEMP} )
    oStruBVJ:setProperty("BVJ_MATRIC", MODEL_FIELD_INIT  , { || BA1->BA1_MATRIC} )
    oStruBVJ:setProperty("BVJ_TIPREG", MODEL_FIELD_INIT  , { || BA1->BA1_TIPREG })    
    oStruBVJ:setProperty("BVJ_CODGRU", MODEL_FIELD_INIT  , { || oModel:GetValue("BFEDETAIL","BFE_CODGRU") })
    oStruBVJ:setProperty("BVJ_PERCOP", MODEL_FIELD_WHEN  , { || oModel:GetValue("BVJDETAIL","BVJ_VALCOP") == 0 })
    oStruBVJ:setProperty("BVJ_VALCOP", MODEL_FIELD_WHEN  , { || oModel:GetValue("BVJDETAIL","BVJ_PERCOP") == 0 })
    oStruBVJ:setProperty("BVJ_VIGDE" , MODEL_FIELD_VALID , { || PlsVldBVJMvc(oModel)})
    oStruBVJ:setProperty("BVJ_VIGATE", MODEL_FIELD_VALID , { || Vazio() .or. PlsVldBVJMvc(oModel)})
    oStruBVJ:setProperty("BVJ_FINATE", MODEL_FIELD_VALID , { || Vazio() .or. BGY->(ExistCpo("BGY",BA1->BA1_CODINT+oModel:GetValue("BVJDETAIL","BVJ_FINATE"),1))  .AND. PLSVLDCOLMvc(oModel) })
    oStruBVJ:setProperty("BVJ_IDAINI", MODEL_FIELD_VALID , { || Positivo() .and. oModel:GetValue("BVJDETAIL","BVJ_IDAINI") <= oModel:GetValue("BVJDETAIL","BVJ_IDAFIN") })
    oStruBVJ:setProperty("BVJ_IDAFIN", MODEL_FIELD_VALID , { || Positivo() .and. oModel:GetValue("BVJDETAIL","BVJ_IDAINI") <= oModel:GetValue("BVJDETAIL","BVJ_IDAFIN") }) 
    
		
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
    Local oStruBFE := FWFormStruct(2,"BFE")	
    Local oStruBVI := FWFormStruct(2,"BVI")	
    Local oStruBVJ := FWFormStruct(2,"BVJ")
    Local oModel   := FWLoadModel( "PLSA260BFE" )
    Local oView
    Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx

    oView := FWFormView():New()
    
    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
        oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
    Next

    oView:SetModel( oModel )

    //oStruBVI:RemoveField("BVI_CODGRU")
	
    oView:AddField("VIEW_BA1",oStruBA1, "BA1MASTER" )
    oView:AddGrid("VIEW_BFE" ,oStruBFE, "BFEDETAIL" )
    oView:AddGrid("VIEW_BVI" ,oStruBVI, "BVIDETAIL" )       
    oView:AddGrid("VIEW_BVJ" ,oStruBVJ, "BVJDETAIL" )    
    
    oStruBA1:SetNoFolder()
    oStruBFE:SetNoFolder()
    oStruBVI:SetNoFolder()
    oStruBVJ:SetNoFolder()    

	oView:CreateHorizontalBox( 'SUPERIOR', 30) 
	oView:CreateHorizontalBox( 'MEIO'	 , 30) 
	oView:CreateHorizontalBox( 'INFERIOR', 40)

	oView:CreateFolder( 'ABA', 'INFERIOR' ) //Cria estrutura de abas

	oView:CreateHorizontalBox('A', 100,,,'ABA','T1')
	oView:CreateHorizontalBox('B', 100,,,'ABA','T2')

	oView:AddSheet( 'ABA', 'T1', 'Classe de Carência')
	oView:AddSheet( 'ABA', 'T2', 'Co-Participação')

	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BFE', 'MEIO')	
	oView:SetOwnerView('VIEW_BVI', 'A')
	oView:SetOwnerView('VIEW_BVJ', 'B')
	
	oView:EnableTitleView("VIEW_BA1","Familia")
    oView:EnableTitleView("VIEW_BFE","Grupos determinados")
    oView:EnableTitleView("VIEW_BVI","Classe de Carência")
    oView:EnableTitleView("VIEW_BVJ","Co-Participação")

Return oView

//-------------------------------------------------------------
/*/{Protheus.doc} PlsVldBVJMvc
--Substitui a função PlsVldBVJ
Funca de validacao das datas de vigencia, chamada no
botao de OK da Rotina Cobertura / Co-Participacao.
Tabela - BVJ - Usr x Grp Cob x Co-Particip.
@author  Totver
@version P12
@since   17/09/19
/*/
//----------------------------------------------------------------
Function PlsVldBVJMvc(oModel)
Local lRet    := .T.
Local lQtd    := .F.
Local aArea	  := GetArea()

lQtd := PLSQTDBVJMvc(oModel)


RestArea(aArea)


Return(lRet)

//----------------------------------------------------------------
/*/{Protheus.doc} PLSQTDBVJMvc
--Substitui a função PLSQTDBVJ
Valida a quantidade quando nao existe data de vigencia 
Informada e nao permite quantidade duplicada.
@author  Totver
@version P12
@since   17/09/19
/*/
//----------------------------------------------------------------
Function PLSQTDBVJMvc(oModel)
Local lRet := .F.
Local nX   := 0
Local aArea	  := GetArea()
Local nLinha  := oModel:GetModel("BVJDETAIL"):GetLine()
Local nBVCQtd := oModel:GetModel("BVJDETAIL"):GetValue("BVJ_QTD")
Local nTam    := oModel:GetModel("BVJDETAIL"):Length(.T.)
Local dVigIni := oModel:GetModel("BVJDETAIL"):GetValue("BVJ_VIGDE")
Local dVigFim := oModel:GetModel("BVJDETAIL"):GetValue("BVJ_VIGATE")

If nTam > 1 
    For nX := 1 To nTam
        If nX <> nLinha
            oModel:GetModel("BVJDETAIL"):GoLine(nX)
            If nBVCQtd == oModel:GetModel("BVJDETAIL"):GetValue("BVJ_QTD")
                Help( ,, "Atenção",, "Quantidade já informada para vigência vazia.", 1, 0 )
                lRet := .T.
            Endif
        EndIf
    Next nX
EndIf

If nTam > 1
    oModel:GetModel("BVJDETAIL"):GoLine(nLinha)
EndIf

RestArea(aArea)

Return lRet

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
Local cCodGru := oModel:GetValue("BFEDETAIL","BFE_CODGRU") 
                             

oModel:SetValue("BVIDETAIL","BVI_CODGRU",cCodGru)
oModel:SetValue("BVJDETAIL","BVJ_CODGRU",cCodGru)
oModel:SetValue("BVJDETAIL","BVJ_DESFIN",BGY->BGY_DESCRI)

Return lRet
