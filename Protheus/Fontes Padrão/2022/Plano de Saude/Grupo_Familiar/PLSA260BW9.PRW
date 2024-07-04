#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BW9
Funcao para abrir a tela de cadastro de Grupos de Cobertura do
Beneficiario. Grupos Determinados->Classe de Carência/Co-participação
@author Totver.
@since 19/09/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BW9(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BW9' )
	iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BW9 
@author  Totver
@version P12
@since   19/09/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BW9 
@author  Totver
@version P12
@since   19/09/19
/*/
//-------------------------------------------------------------------

Static Function ModelDef()											
	Local oModel
	Local oStruBA1      := FWFormStruct(1,'BA1')
    Local oStruBW9      := FWFormStruct(1,'BW9')
    Local oStruBWA      := FWFormStruct(1,'BWA')        
    Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBW9	:= {"BW9_CODINT","BW9_CODEMP","BW9_MATRIC"} // Campos a serem adicionado na estrutura
    Local aCamposBWA	:= {"BWA_CODINT","BWA_CODEMP","BWA_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx

    // Cria o objeto do Modelo de Dados	 
    oModel := MPFormModel():New('PLSA260BW9')

    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
        oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBW9)
        oStruBW9 := CriaCampMVC(1,oStruBW9,aCamposBW9[nNx]) 
    Next

    // Cria os campos na estrutura que estão como não usados no dicionario
    For nNx := 1 To Len(aCamposBWA)
        oStruBWA := CriaCampMVC(1,oStruBWA,aCamposBWA[nNx]) 
    Next
    
	oModel:addFields("BA1MASTER" , ,oStruBA1)
    oModel:AddGrid("BW9DETAIL","BA1MASTER", oStruBW9)    
    oModel:AddGrid('BWADETAIL','BW9DETAIL', oStruBWA,/*bLinePre*/,{|oGrid|fLinOK(oGrid)},/*bPre - Grid Inteiro*/,{|oGrid|fLinOK(oGrid)},,/*bLoad - */)   
    
   
    oModel:GetModel("BW9DETAIL"):SetOptional(.T.)
    oModel:GetModel("BWADETAIL"):SetOptional(.T.)

	oModel:SetRelation( "BW9DETAIL", { {"BW9_FILIAL", 'xFilial("BW9")' },;
									{ "BW9_CODINT"	, "BA1_CODINT" },;
                                    { "BW9_CODEMP"	, "BA1_CODEMP" },;
                                    { "BW9_MATRIC"	, "BA1_MATRIC" },;
									{ "BW9_TIPREG"	, "BA1_TIPREG" } },;
                                    BW9->( IndexKey(  ) ) )
    
    oModel:SetRelation( 'BWADETAIL', { { 'BWA_FILIAL', 'xFilial( "BWA" )'},;
									{ "BWA_CODINT"	 , "BW9_CODINT" },;
									{ "BWA_CODEMP"	 , "BW9_CODEMP" },;
                                    { "BWA_MATRIC"	 , "BW9_MATRIC" },;
                                    { "BWA_TIPREG"	 , "BW9_TIPREG" },;
									{ "BWA_CODGRU"	 , "BW9_CODGRU" } },;									
                                    BWA->( IndexKey(  ) ) )                                                      
	
    oModel:SetDescription(FunDesc())	
	
	oModel:GetModel("BA1MASTER"):SetDescription("Familia" )
    oModel:GetModel("BW9DETAIL"):SetDescription("Grupo de Quantidade")
    oModel:GetModel("BWADETAIL"):SetDescription("Co-Participação")

	oModel:GetModel("BA1MASTER"):SetOnlyQuery(.T.)
    oModel:GetModel("BA1MASTER"):SetOnlyView(.T.)		
    
    oModel:SetPrimaryKey( { "BW9_FILIAL", "BW9_CODINT", "BW9_CODEMP", "BW9_MATRIC", "BW9_TIPREG", "BW9_CODPSA", "BW9_CODPAD" } )
     
    oStruBW9:setProperty('BW9_CODGRU', MODEL_FIELD_VALID, { || ExistCpo("BW2",BA1->BA1_CODINT+oModel:GetValue("BW9DETAIL","BW9_CODGRU"),1) } )
    oStruBW9:setProperty('BW9_DESGRU', MODEL_FIELD_INIT , { || If(Inclui .OR. Empty(BW9->BW9_CODGRU),"",Posicione("BW2",1,xFilial("BW2")+BG9->BG9_CODINT+BW9->BW9_CODGRU,"BW2_DESCRI")) } )
    oStruBW9:setProperty('BW9_CODINT', MODEL_FIELD_INIT , { || oModel:GetValue('BA1MASTER','BA1_CODINT') } )
    oStruBW9:setProperty('BW9_CODEMP', MODEL_FIELD_INIT , { || oModel:GetValue('BA1MASTER','BA1_CODEMP') } )
    oStruBW9:setProperty('BW9_MATRIC', MODEL_FIELD_INIT , { || oModel:GetValue('BA1MASTER','BA1_MATRIC') } )
    oStruBW9:setProperty('BW9_TIPREG', MODEL_FIELD_INIT , { || BA1->BA1_TIPREG } )

    oStruBWA:setProperty('BWA_CODGRU', MODEL_FIELD_INIT , { || oModel:GetValue("BW9DETAIL","BW9_CODGRU") } )
    oStruBWA:setProperty('BWA_TIPREG', MODEL_FIELD_INIT , { || BA1->BA1_TIPREG } )
    oStruBWA:setProperty('BWA_TIPO'  , MODEL_FIELD_VALID, { || PLSVLDCOLMvc(oModel) } )
    oStruBWA:setProperty('BWA_QTD'   , MODEL_FIELD_VALID, { || PLSVLDCOLMvc(oModel) } )
    oStruBWA:setProperty('BWA_PERCOP', MODEL_FIELD_WHEN,  { || oModel:GetValue("BWADETAIL","BWA_VLRCOP") == 0 } )
    oStruBWA:setProperty('BWA_VLRCOP', MODEL_FIELD_WHEN,  { || oModel:GetValue("BWADETAIL","BWA_PERCOP") == 0 } )  
        
Return oModel

//----------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P12
@since   19/09/19
/*/
//----------------------------------------------------------------
Static Function ViewDef()  
	Local oStruBA1 := FWFormStruct(2,"BA1", { |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR|" } )
    Local oStruBW9 := FWFormStruct(2,"BW9")	
    Local oStruBWA := FWFormStruct(2,"BWA")	    
    Local oModel   := FWLoadModel("PLSA260BW9")
    Local oView
    Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
    Local nNx

    oView := FWFormView():New()
    
    // Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
        oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
    Next

    oView:SetModel(oModel)    
	
    oView:AddField("VIEW_BA1",oStruBA1, "BA1MASTER")
    oView:AddGrid("VIEW_BW9" ,oStruBW9, "BW9DETAIL")
    oView:AddGrid("VIEW_BWA" ,oStruBWA, "BWADETAIL")           
    
    oStruBA1:SetNoFolder()
    oStruBW9:SetNoFolder()
    oStruBWA:SetNoFolder()    

	oView:CreateHorizontalBox('SUPERIOR', 30) 
	oView:CreateHorizontalBox('MEIO'	, 40) 
	oView:CreateHorizontalBox('INFERIOR', 30)	
	
	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BW9', 'MEIO')	
	oView:SetOwnerView('VIEW_BWA', 'INFERIOR')	
	
	oView:EnableTitleView("VIEW_BA1","Beneficiário")
    oView:EnableTitleView("VIEW_BW9","Grupo de Quantidade")
    oView:EnableTitleView("VIEW_BWA","Co-Participação")

Return oView

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
Local cCodGru := oModel:GetValue("BW9DETAIL","BW9_CODGRU") 

oModel:SetValue("BWADETAIL","BWA_CODGRU",cCodGru)

Return lRet


//----------------------------------------------------------------
/*/{Protheus.doc} fLinOK
Validação de registros repetidos no grid 
@author  Totver
@version P12
@since   19/09/19
/*/
//----------------------------------------------------------------
Static Function fLinOK(oGrid)
Local lRet    := .T.
Local nLinha  := oGrid:GetLine()
Local nTam    := oGrid:GetQtdLine()
Local nI      := 0
Local aArea	  := GetArea()
Local dVigIni := oGrid:GetValue("BWA_VIGDE")
Local dVigFim := oGrid:GetValue("BWA_VIGATE")
Local nQtd    := oGrid:GetValue("BWA_QTD")


If nTam > 1
    For nI := 1 TO nTam
        If nLinha <> nI
            oGrid:GoLine(nI)
            If !Empty(dVigFim) .and. (dVigIni >= oGrid:GetValue("BWA_VIGDE") .and. dVigIni <=  oGrid:GetValue("BWA_VIGATE");
                .AND. nQtd == oGrid:GetValue("BWA_QTD") )//Verifico se estão no mesmo intervalo                
                lRet  := .F.                        
            EndIf
            
        EndIf
    Next 
EndIf

If !lRet 
    Help( ,, "Atenção",, "Já existe um intervalo de data que compreende a data selecionada com a mesma quantidade!", 1, 0 )
Endif

If nTam > 1
     oGrid:GoLine(nLinha)
EndIf

RestArea(aArea)

Return lRet
