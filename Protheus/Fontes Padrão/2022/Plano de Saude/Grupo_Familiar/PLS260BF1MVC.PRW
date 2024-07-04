#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLS260BF1MVC
Funcao para abrir a tela de cadastro de Opcionais da Familia
@author DEV TOTVS.
@since 05/04/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260BF1MVC(lAutomato)
Local oBrowse
Default lAutomato := .F.
	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLS260BF1MVC' )
	If(!lAutomato,oBrowse:Activate(),)

Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLS260BF1MVC 
@author DEV TOTVS
@version P12
@since   05/04/2020
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}
Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260BH5 
@author DEV TOTVS
@version P12
@since   16/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Local oModel
	Local oStruBA1		:= FWFormStruct(1,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
	Local oStruBF1 		:= FWFormStruct(1,'BF1')	
    Local oStruBK0		:= FWFormStruct(1,'BK0')	
    Local oStruBBY 		:= FWFormStruct(1,'BBY')	
    Local oStruBG0 		:= FWFormStruct(1,'BG0')	
    Local cVerOpc  		:= BF1->BF1_VERSAO
	Local cCodOpc  		:= BF1->BF1_CODPRO
  	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBF1	:= {"BF1_CODINT","BF1_CODEMP","BF1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBK0	:= {"BK0_CODOPE","BK0_CODEMP","BK0_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBBY	:= {"BBY_CODOPE","BBY_CODEMP","BBY_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBG0	:= {"BG0_CODOPE","BG0_CODEMP","BG0_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
    Local oEvent		:= Nil   
	
	BA3->(DbSetOrder(1))
	BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)	))

	BI3->(DbSetOrder(1))
	BI3->(DbSeek(xFilial("BI3")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CODPLA)	))
	
	oEvent    := PL260BF1EVDEF():New()	
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLS260BF1MVC')

	
	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBF1)
		oStruBF1 := CriaCampMVC(1,oStruBF1,aCamposBF1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBK0)
		oStruBK0 := CriaCampMVC(1,oStruBK0,aCamposBK0[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBBY)
		oStruBBY := CriaCampMVC(1,oStruBBY,aCamposBBY[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBG0)
		oStruBG0 := CriaCampMVC(1,oStruBG0,aCamposBG0[nNx]) 
	Next
    
	oModel:addFields('MasterBA1' , ,oStruBA1) 
   	oModel:AddGrid( 'BF1DETAIL' , 'MasterBA1', oStruBF1 )
    oModel:AddGrid( 'BK0DETAIL' , 'BF1DETAIL', oStruBK0 )
    oModel:AddGrid( 'BBYDETAIL' , 'BK0DETAIL', oStruBBY )
    oModel:AddGrid( 'BG0DETAIL' , 'BBYDETAIL', oStruBG0 )


	oModel:GetModel( "BF1DETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BK0DETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BBYDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BG0DETAIL" ):SetOptional(.T.)

	oModel:SetRelation( 'BF1DETAIL', { { 'BF1_FILIAL' , 'xFilial( "BF1" )' },;
									{ 'BF1_CODINT'	  , 'BA1_CODINT'       },;
									{ 'BF1_CODEMP'	  , 'BA1_CODEMP'       },;
									{ 'BF1_MATRIC'	  , 'BA1_MATRIC'       } },;
									BF1->( IndexKey(1) ) ) 

	oModel:SetRelation( 'BK0DETAIL', { { 'BK0_FILIAL', 'xFilial( "BK0" )' },;
									{ 'BK0_CODOPE'	 , 'BF1_CODINT'       },;
									{ 'BK0_CODEMP'	 , 'BF1_CODEMP'       },;
									{ 'BK0_MATRIC'	 , 'BF1_MATRIC'       },;
									{ 'BK0_CODOPC'	 , 'BF1_CODPRO'       },;
									{ 'BK0_VEROPC'	 , 'BF1_VERSAO'       } },;																	
									BK0->( IndexKey(1) ) )  

	oModel:SetRelation( 'BBYDETAIL', { { 'BBY_FILIAL', 'xFilial( "BBY" )' },;
									{ 'BBY_CODOPE'	 , 'BK0_CODOPE'       },;
									{ 'BBY_CODEMP'	 , 'BK0_CODEMP'       },;
									{ 'BBY_MATRIC'	 , 'BK0_MATRIC'       },;
									{ 'BBY_CODOPC'	 , 'BK0_CODOPC'       },;
									{ 'BBY_VEROPC'	 , 'BK0_VEROPC'       },;
									{ 'BBY_CODFOR'	 , 'BK0_CODFOR'       } },;
									BBY->( IndexKey(1) ) )
    
    oModel:SetRelation( 'BG0DETAIL', { { 'BG0_FILIAL', 'xFilial( "BG0" )' },;
									{ 'BG0_CODOPE'	 , 'BBY_CODOPE'       },;
									{ 'BG0_CODEMP'	 , 'BBY_CODEMP'       },;
									{ 'BG0_MATRIC'	 , 'BBY_MATRIC'       },;
									{ 'BG0_CODOPC'	 , 'BBY_CODOPC'       },;
									{ 'BG0_VEROPC'	 , 'BBY_VEROPC'       },;
									{ 'BG0_CODFOR'	 , 'BBY_CODFOR'       } },;									
									BG0->( IndexKey(1) ) )                                    
	
    oModel:SetDescription( FunDesc() )	
	
	oModel:GetModel( 'MasterBA1' ):SetDescription( 'Familia' )
    oModel:GetModel( 'BF1DETAIL' ):SetDescription( 'Opcionais da Familia' )	
    oModel:GetModel( 'BK0DETAIL' ):SetDescription( 'Forma de Cobrança do opcional' )	
    oModel:GetModel( 'BBYDETAIL' ):SetDescription( 'Faixa Etárias Famílias' )	
    oModel:GetModel( 'BG0DETAIL' ):SetDescription( 'Descontos Família Opcional' )	

	oModel:GetModel( 'MasterBA1' ):SetOnlyQuery(.T.)
    oModel:GetModel( 'MasterBA1' ):SetOnlyView(.T.)	
	    
	oModel:SetPrimaryKey({})
	
	oStruBF1:setProperty( 'BF1_CODINT', MODEL_FIELD_INIT , { || BA3->BA3_CODINT } )
	oStruBF1:setProperty( 'BF1_CODEMP', MODEL_FIELD_INIT , { || BA3->BA3_CODEMP } )
	oStruBF1:setProperty( 'BF1_MATRIC', MODEL_FIELD_INIT , { || BA3->BA3_MATRIC } )
	oStruBF1:setProperty( 'BF1_CODPRO', MODEL_FIELD_VALID, { || PL260ValMVC('BF1_CODPRO',oModel,,oModel:GetModel('BF1DETAIL'):GetValue('BF1_CODPRO'))} )
	oStruBF1:setProperty( 'BF1_DATBAS', MODEL_FIELD_VALID, { || PLChkOpcMvc(1, oModel)} )
	oStruBF1:setProperty( 'BF1_MOTBLO', MODEL_FIELD_VALID, { || ExistCpo("BG1",oModel:GetModel('BF1DETAIL'):GetValue('BF1_MOTBLO'),1) .And. PLSBLOAUT(oModel:GetModel('BF1DETAIL'):GetValue('BF1_MOTBLO'),2) } )
	oStruBF1:setProperty( 'BF1_MOTBLO', MODEL_FIELD_WHEN , {|| .T. } )
	oStruBF1:setProperty( 'BF1_DATBLO', MODEL_FIELD_WHEN , {|| .T. } )
	                                     
	
	oStruBK0:setProperty( 'BK0_CODOPC', MODEL_FIELD_INIT, { || cCodOpc } )
	oStruBK0:setProperty( 'BK0_VEROPC', MODEL_FIELD_INIT, { || cVerOpc} )
	oStruBK0:setProperty( 'BK0_CODOPE', MODEL_FIELD_INIT, { || BA3->BA3_CODINT} )//r7
	oStruBK0:setProperty( 'BK0_CODEMP', MODEL_FIELD_INIT, { || BA3->BA3_CODEMPT} )//r7
	oStruBK0:setProperty( 'BK0_CODFOR', MODEL_FIELD_WHEN , {|| .T. } )
	oStruBK0:SetProperty( 'BK0_CODFOR', MODEL_FIELD_VALID , { || PlsVldCbMVC("3", "3","BK0_CODFOR",,oModel)  })
	
	
	oStruBBY:setProperty( 'BBY_CODOPE', MODEL_FIELD_INIT , { || BA3->BA3_CODINT } )
	oStruBBY:setProperty( 'BBY_CODEMP', MODEL_FIELD_INIT , { || BA3->BA3_CODEMP } )
	oStruBBY:setProperty( 'BBY_MATRIC', MODEL_FIELD_INIT , { || BA3->BA3_MATRIC } )
	oStruBBY:setProperty( 'BBY_CODOPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")} )
	oStruBBY:setProperty( 'BBY_VEROPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")} )
	oStruBBY:setProperty( 'BBY_CODFOR', MODEL_FIELD_INIT, { || oModel:GetModel("BK0DETAIL"):GetValue("BK0_CODOPC")} )
	oStruBBY:setProperty( 'BBY_IDAINI', MODEL_FIELD_VALID, { || .T.} )
	oStruBBY:setProperty( 'BBY_IDAFIN', MODEL_FIELD_VALID, { || .T.} )
	oStruBBY:setProperty(  '*' ,MODEL_FIELD_WHEN, {|| .T. }  )
	oStruBBY:setProperty( 'BBY_VLSLFN', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_TIPUSR', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_GRAUPA', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_IDAFIN', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )
	oStruBBY:setProperty( 'BBY_VALFAI', MODEL_FIELD_VALID, { || PL260BF1Valid(oModel)} )

	
	oStruBG0:setProperty( 'BG0_CODOPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")} )
	oStruBG0:setProperty( 'BG0_VEROPC', MODEL_FIELD_INIT, { || oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")} )
	oStruBG0:setProperty( 'BG0_CODFOR', MODEL_FIELD_INIT, { || oModel:GetModel("BBYDETAIL"):GetValue("BBY_CODFOR")} )
	oStruBG0:setProperty(  '*' ,MODEL_FIELD_WHEN, {|| .T. }  )
	
	
    //Instala o evento padrão do programa.
	oModel:InstallEvent("PL260BF1EVDEF",/*cOwner*/,oEvent)
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view da aplicação 
@author DEV TOTVS
@version P2
@since   16/08/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()     
    Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
	Local oStruBF1 := FWFormStruct(2,'BF1')	
    Local oStruBK0 := FWFormStruct(2,'BK0')	
    Local oStruBBY := FWFormStruct(2,'BBY')	
    Local oStruBG0 := FWFormStruct(2,'BG0')	
	Local oModel   := FWLoadModel( 'PLS260BF1MVC' )
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
	
	oView := FWFormView():New()

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next

	oStruBK0:RemoveField( 'BK0_CODOPC' )
	oStruBK0:RemoveField( 'BK0_VEROPC' )



	oStruBBY:RemoveField( 'BBY_CODOPC' )
	oStruBBY:RemoveField( 'BBY_VEROPC' )
	oStruBBY:RemoveField( 'BBY_CODFOR' )
	
	oStruBG0:RemoveField( 'BG0_CODOPC' )
	oStruBG0:RemoveField( 'BG0_VEROPC' )
	oStruBG0:RemoveField( 'BG0_CODFOR' )


	oView:SetModel( oModel )

	oView:addField('VIEW_BA1', oStruBA1, 'MasterBA1') 
   	oView:AddGrid('VIEW_BF1'  , oStruBF1 , 'BF1DETAIL' )
    oView:AddGrid('VIEW_BK0'  , oStruBK0 , 'BK0DETAIL' )
    oView:AddGrid('VIEW_BBY'  , oStruBBY , 'BBYDETAIL' )
    oView:AddGrid('VIEW_BG0'  , oStruBG0 , 'BG0DETAIL' )

    oStruBA1:SetNoFolder()
    oStruBF1:SetNoFolder()
   	oStruBK0:SetNoFolder()
	oStruBBY:SetNoFolder()
	oStruBG0:SetNoFolder()

   	oView:CreateHorizontalBox( 'SUPERIOR',15) 
	oView:CreateHorizontalBox( 'MEIO'	 ,20) 
	oView:CreateHorizontalBox( 'INFERIOR',25)
    oView:CreateHorizontalBox( 'RODAPE'  ,40)

    oView:CreateFolder( 'ABA', 'RODAPE' ) //Cria estrutura de abas

    oView:CreateHorizontalBox( 'A', 100,,, 'ABA', 'T1'  ) 
    oView:CreateHorizontalBox( 'B', 100,,, 'ABA', 'T2'  ) 

    oView:AddSheet( 'ABA', 'T1', '' ) 
    oView:AddSheet( 'ABA', 'T2', '' ) 

    oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
    oView:SetOwnerView('VIEW_BF1' , 'MEIO')
    oView:SetOwnerView('VIEW_BK0' , 'INFERIOR')
    oView:SetOwnerView('VIEW_BBY' , 'A') 
	oView:SetOwnerView('VIEW_BG0' , 'B') 

	oView:EnableTitleView('VIEW_BA1','Familia' )
	oView:EnableTitleView('VIEW_BF1','Opcionais da Familia' )
	oView:EnableTitleView('VIEW_BK0','Forma de Cobrança do opcional' )
	oView:EnableTitleView('VIEW_BBY','Faixa Etárias Famílias' )
	oView:EnableTitleView('VIEW_BG0','Descontos Família Opcional' )

    
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Atualiza inicializadores da tabela BK0 
@author DEV TOTVS
@version P2
@since   05/04/2020
/*/
//-------------------------------------------------------------------

Function PL260BF1Valid(oModel)

oModel:SetValue("BK0DETAIL","BK0_CODOPE" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODINT")) 
oModel:SetValue("BK0DETAIL","BK0_CODEMP" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODEMP")) 
oModel:SetValue("BK0DETAIL","BK0_MATRIC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_MATRIC")) 
oModel:SetValue("BK0DETAIL","BK0_CODOPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")) 
oModel:SetValue("BK0DETAIL","BK0_VEROPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")) 


oModel:SetValue("BBYDETAIL","BBY_CODOPE" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODINT")) 
oModel:SetValue("BBYDETAIL","BBY_CODEMP" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODEMP")) 
oModel:SetValue("BBYDETAIL","BBY_MATRIC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_MATRIC")) 
oModel:SetValue("BBYDETAIL","BBY_CODOPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")) 
oModel:SetValue("BBYDETAIL","BBY_VEROPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")) 
oModel:SetValue("BBYDETAIL","BBY_CODFOR" ,oModel:GetModel("BK0DETAIL"):GetValue("BK0_CODFOR")) 


oModel:SetValue("BG0DETAIL","BG0_CODOPE" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODINT")) 
oModel:SetValue("BG0DETAIL","BG0_CODEMP" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODEMP")) 
oModel:SetValue("BG0DETAIL","BG0_MATRIC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_MATRIC")) 
oModel:SetValue("BG0DETAIL","BG0_CODOPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_CODPRO")) 
oModel:SetValue("BG0DETAIL","BG0_VEROPC" ,oModel:GetModel("BF1DETAIL"):GetValue("BF1_VERSAO")) 
oModel:SetValue("BG0DETAIL","BG0_CODFOR" ,oModel:GetModel("BBYDETAIL"):GetValue("BBY_CODFOR")) 



Return .t.

