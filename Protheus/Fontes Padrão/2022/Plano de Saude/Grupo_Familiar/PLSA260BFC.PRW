#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BFC
Funcao para abrir a tela de cadastro de Grupos de Cobertura da Familia
@author DEV TOTVS
@since 06/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BFC(lAutomato)

    Local oBrowse
    Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BFC' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BFC 
@author  DEV TOTVS
@version P12
@since   06/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

    Private aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BFC 
@author  DEV TOTVS
@version P12
@since   06/09/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel
	Local oStruBA1      := FWFormStruct(1,'BA1', {|x|  Alltrim(x)+"|" $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|"})
    Local oStruBFC      := FWFormStruct(1,'BFC')
    Local oStruBVC      := FWFormStruct(1,'BVC')
    Local aAux          := NIL
    Local aAuxBVC       := NIL
    Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBFC	:= {"BFC_CODINT","BFC_CODEMP","BFC_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBVC	:= {"BVC_CODINT","BVC_CODEMP","BVC_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx
  

    // Cria o objeto do Modelo de Dados	 
    oModel := MPFormModel():New('PLSA260BFC')

    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
        oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBFC)
        oStruBFC := CriaCampMVC(1,oStruBFC,aCamposBFC[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBVC)
        oStruBVC := CriaCampMVC(1,oStruBVC,aCamposBVC[nNx]) 
    Next
    
    //FwStruTrigger: ( cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic )
    aAux := FwStruTrigger(;
        'BFC_CODGRU'     ,; 
        'BFC_DESGRU'     ,; 
        'BG7->BG7_DESCRI',;
        .F.              ,; 
        'BG7'            ,; 
        1                ,; 
        ''               ,;
        '')//condicao

    oStruBFC:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4])

    aAuxBVC := FwStruTrigger(;
        'BVC_FINATE'     ,; 
        'BVC_DESFIN'     ,; 
        'BGY->BGY_DESCRI',;
        .F.              ,; 
        'BGY'            ,; 
        1                ,; 
        ''               ,;
        '')//condicao

    oStruBVC:AddTrigger( aAuxBVC[1], aAuxBVC[2], aAuxBVC[3], aAuxBVC[4])


        aAuxBVC := FwStruTrigger(;
        'BVC_TIPO'     ,; 
        'BVC_CODGRU'     ,; 
        "FwFldGet('BFC_CODGRU')",;
        .F.              ,; 
        ''            ,; 
        1                ,; 
        ''               ,;
        '')//condicao

    oStruBVC:AddTrigger( aAuxBVC[1], aAuxBVC[2], aAuxBVC[3], aAuxBVC[4])


    RegToMemory("BA3",.T.,.T.,.F.)
    M->BA3_CODINT := BA1->BA1_CODINT
    
	oModel:addFields("BA1MASTER" , ,oStruBA1)
    oModel:AddGrid(  "BFCDETAIL" , "BA1MASTER", oStruBFC )
    oModel:AddGrid(  "BVCDETAIL" , "BFCDETAIL", oStruBVC )
	
    oModel:GetModel( "BFCDETAIL" ):SetOptional( .T. )
    oModel:GetModel( "BVCDETAIL" ):SetOptional( .T. )
	
    oStruBFC:RemoveField("BFC_NOMRES")

	oModel:SetRelation( "BFCDETAIL", { {"BFC_FILIAL", 'xFilial("BFC")' },;
									{ "BFC_CODINT"	, "BA1_CODINT" },;
									{ "BFC_CODEMP"	, "BA1_CODEMP" },;
									{ "BFC_MATRIC"	, "BA1_MATRIC" } },;									
                                    BFC->( IndexKey(  ) ) ) 
    
    oModel:SetRelation( 'BVCDETAIL', { { 'BVC_FILIAL', 'xFilial( "BVC" )' },;
									{ "BVC_CODINT"	 , "BFC_CODINT" },;
									{ "BVC_CODEMP"	 , "BFC_CODEMP" },;
									{ "BVC_MATRIC"	 , "BFC_MATRIC" },;
									{ "BVC_CODGRU"	 , "BFC_CODGRU" } },;									
									BVC->( IndexKey(  ) ) )  
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel("BA1MASTER"):SetDescription("Familia" )
    oModel:GetModel("BFCDETAIL"):SetDescription("Grupos de Cobertura" )
    oModel:GetModel("BVCDETAIL"):SetDescription("Co-Participação" )

	oModel:GetModel("BA1MASTER"):SetOnlyQuery(.T.)
    oModel:GetModel("BA1MASTER"):SetOnlyView(.T.)		
    
    oModel:SetPrimaryKey( { "BFC_FILIAL", "BFC_CODINT", "BFC_CODEMP", "BFC_MATRIC","BFC_CODGRU" } )
    
    oStruBFC:setProperty( "BFC_CODGRU", MODEL_FIELD_VALID ,{ || ExistCpo("BG7",BA1->BA1_CODINT+oModel:GetModel("BFCDETAIL"):GetValue("BFC_CODGRU"),1) .and. AtuVarBVC(oModel)} )
    
    oStruBFC:setProperty( "BFC_CODINT", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODINT} )
    oStruBFC:setProperty( "BFC_CODEMP", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODEMP} )
    oStruBFC:setProperty( "BFC_MATRIC", MODEL_FIELD_INIT  ,{ || BA1->BA1_MATRIC} )
    

    oStruBVC:setProperty( "BVC_CODINT", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODINT} )
    oStruBVC:setProperty( "BVC_CODEMP", MODEL_FIELD_INIT  ,{ || BA1->BA1_CODEMP} )
    oStruBVC:setProperty( "BVC_MATRIC", MODEL_FIELD_INIT  ,{ || BA1->BA1_MATRIC} )

    oStruBVC:setProperty( "BVC_CODGRU", MODEL_FIELD_INIT  ,{ || oModel:GetModel("BFCDETAIL"):GetValue("BFC_CODGRU")} )
    oStruBVC:setProperty( "BVC_PERCOP", MODEL_FIELD_WHEN  ,{ || oModel:GetModel("BVCDETAIL"):GetValue("BVC_VALCOP") == 0 })
    oStruBVC:setProperty( "BVC_VALCOP", MODEL_FIELD_WHEN  ,{ || oModel:GetModel("BVCDETAIL"):GetValue("BVC_PERCOP") == 0 })
    oStruBVC:setProperty( "BVC_VIGINI", MODEL_FIELD_VALID ,{ || PlsVldBVCMvc(oModel) })
    oStruBVC:setProperty( "BVC_VIGFIN", MODEL_FIELD_VALID ,{ || PlsVldBVCMvc(oModel) })
    oStruBVC:setProperty( "BVC_FINATE", MODEL_FIELD_VALID ,{ || Vazio() .or. BGY->(ExistCpo("BGY",BA1->BA1_CODINT+oModel:GetModel("BVCDETAIL"):GetValue("BVC_FINATE"),1)) })  

 Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P12
@since   06/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA1 := FWFormStruct(2,"BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|" } )
    Local oStruBFC := FWFormStruct(2,"BFC")	
    Local oStruBVC := FWFormStruct(2,"BVC")	
    Local oModel   := FWLoadModel( "PLSA260BFC" )
    Local oView
    Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx

    oView := FWFormView():New()
    
    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
        oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
    Next

    oView:SetModel( oModel )
    
    oStruBVC:RemoveField("BVC_CODGRU")
	
    oView:AddField("VIEW_BA1",oStruBA1, "BA1MASTER" )
    oView:AddGrid("VIEW_BFC" ,oStruBFC, "BFCDETAIL" )
    oView:AddGrid("VIEW_BVC" ,oStruBVC, "BVCDETAIL" )       
    
    oStruBA1:SetNoFolder()
    oStruBFC:SetNoFolder()
    oStruBVC:SetNoFolder()

	oView:CreateHorizontalBox("SUPERIOR", 15)
    oView:CreateHorizontalBox("INFERIOR", 45)
    oView:CreateHorizontalBox("RODAPE"  , 40)
	
	oView:SetOwnerView("VIEW_BA1", "SUPERIOR")
    oView:SetOwnerView("VIEW_BFC", "INFERIOR")
    oView:SetOwnerView("VIEW_BVC", "RODAPE")
	
	oView:EnableTitleView("VIEW_BA1","Familia")
    oView:EnableTitleView("VIEW_BFC","Grupos de Cobertura")
    oView:EnableTitleView("VIEW_BVC","Co-Participação")

Return oView

//----------------------------------------------------------------
/*/{Protheus.doc} PlsVldBVCMvc
--Substitui a função PlsVldBVC
Funca de validacao das datas de vigencia, chamada no 
botao de OK da Rotina Cobertura / Co-Participacao.
Tabela - BVC - Grupos x Co-Participacao.
@author  DEV TOTVS
@version P12
@since   06/09/19
/*/
//----------------------------------------------------------------
Function PlsVldBVCMvc(oModel)

    Local lRet    := .T.
    Local lQtd    := .F.
    Local aArea	  := GetArea()
    Local cCodGru := oModel:GetModel("BVCDETAIL"):GetValue("BVC_CODGRU")

   
    oModel:GetModel("BVCDETAIL"):LoadValue("BVC_CODGRU",cCodGru)


    lQtd := PLSQTDBVCMvc(oModel)

   
    RestArea(aArea)

Return(lRet)

//----------------------------------------------------------------
/*/{Protheus.doc} PLSQTDBVCMvc
--Substitui a função PLSQTDBVC
Valida a quantidade quando nao existe data de vigencia 
Informada e nao permite quantidade duplicada.
@author  DEV TOTVS
@version P12
@since   06/09/19
/*/
//----------------------------------------------------------------
Function PLSQTDBVCMvc(oModel)

    Local lRet := .T.
    Local nX   := 0
    Local aArea	  := GetArea()
    Local nLinha  := oModel:GetModel("BVCDETAIL"):GetLine()
    Local nBVCQtd := oModel:GetModel("BVCDETAIL"):GetValue("BVC_QTD")
    Local nTam    := oModel:GetModel("BVCDETAIL"):Length(.T.)
    Local dVigIni := oModel:GetModel("BVCDETAIL"):GetValue("BVC_VIGINI")
    Local dVigFim := oModel:GetModel("BVCDETAIL"):GetValue("BVC_VIGFIN")

    If nTam > 1 
        For nX := 1 To nTam
            If nX <> nLinha
                oModel:GetModel("BVCDETAIL"):GoLine(nX)
                    If nBVCQtd == oModel:GetModel("BVCDETAIL"):GetValue("BVC_QTD")
                        Help( ,, "Atenção",, "Quantidade já informada para vigência vazia.", 1, 0 )
                        lRet := .F.
                    EndIf
            EndIf
        Next nX
    EndIf

    If nTam > 1
        oModel:GetModel("BVCDETAIL"):GoLine(nLinha)
    EndIf

    RestArea(aArea)

Return lRet


//----------------------------------------------------------------
/*/{Protheus.doc} AtuVarBVC
Inicializa campos
@author  DEV TOTVS
@version P12
@since   10/09/19
/*/
//----------------------------------------------------------------
Function AtuVarBVC(oModel)

    Local cCodGru := oModel:GetValue("BFCDETAIL","BFC_CODGRU")

    If !Empty(oModel:GetValue("BFCDETAIL","BFC_CODGRU"))
        oModel:GetModel("BVCDETAIL"):LoadValue("BVC_CODGRU", cCodGru)        
    EndIf

Return .T.