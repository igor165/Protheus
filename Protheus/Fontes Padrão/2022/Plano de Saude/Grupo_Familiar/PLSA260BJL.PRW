#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BJL
Funcao para abrir a tela de cadastro da Taxa de Adesão
@author DEV TOTVS
@since 15/08/19.
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260BJL(lAutomato)

	Local oBrowse
	Default lAutomato:= .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BJL' )
	iF(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicao de menu PLSA260BJL 
@author  DEV TOTVS
@version P12
@since   15/08/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260BJL 
@author  DEV TOTVS
@version P12
@since   15/08/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel
	Local oStruBA1 		:= FWFormStruct(1,'BA1',{ |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' 	} )
	Local oStruBJL 		:= FWFormStruct(1,'BJL',{ |cCampo| AllTrim(cCampo) $ 'BJL_FILIAL|BJL_CODFOR|BJL_DESFOR|BJL_AUTOMA|BJL_CODEMP' 	} )	
	Local oStruBRX 		:= FWFormStruct(1,'BRX')
	Local oStruBFZ 		:= FWFormStruct(1,'BFZ')
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBJL	:= {"BJL_CODOPE","BJL_CODEMP","BJL_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBRX	:= {"BRX_CODOPE","BRX_CODEMP","BRX_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBFZ	:= {"BFZ_CODOPE","BFZ_CODEMP","BFZ_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
	
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BJL')
	
	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBJL)
		oStruBJL := CriaCampMVC(1,oStruBJL,aCamposBJL[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBRX)
		oStruBRX := CriaCampMVC(1,oStruBRX,aCamposBRX[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBFZ)
		oStruBFZ := CriaCampMVC(1,oStruBFZ,aCamposBFZ[nNx]) 
	Next
    
	oModel:addFields('MasterBA1' , ,oStruBA1) 
	oModel:AddGrid(  'BJLDETAIL' , 'MasterBA1', oStruBJL,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/{ |oGrid| GridBJLOk(oGrid) },/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  
    oModel:AddGrid(  'BRXDETAIL' , 'BJLDETAIL', oStruBRX)
	oModel:AddGrid(  'BFZDETAIL' , 'BRXDETAIL', oStruBFZ)
	
	// Permite a grid com dados em branco
	oModel:GetModel( "BJLDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BRXDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BFZDETAIL" ):SetOptional(.T.)

	oModel:SetRelation( 'BJLDETAIL', { { 'BJL_FILIAL' 	, 'xFilial( "BJL" )' },;
									{ 'BJL_CODOPE'	, 'BA1_CODINT'       },;
									{ 'BJL_CODEMP'	, 'BA1_CODEMP'       },;
									{ 'BJL_MATRIC'	, 'BA1_MATRIC'       } },;									
									BJL->( IndexKey(  ) ) ) 

	oModel:SetRelation( 'BRXDETAIL', { { 'BRX_FILIAL' 	, 'xFilial( "BRX" )' },;
									{ 'BRX_CODOPE'	, 'BJL_CODOPE'       },;
									{ 'BRX_CODEMP'	, 'BJL_CODEMP'       },;
									{ 'BRX_MATRIC'	, 'BJL_MATRIC'       },;
									{ 'BRX_CODFOR'	, 'BJL_CODFOR'		} },;
									BRX->( IndexKey(  ) ) )								

	oModel:SetRelation( 'BFZDETAIL', { { 'BFZ_FILIAL' 	, 'xFilial( "BFZ" )' },;
									{ 'BFZ_CODOPE'	, 'BRX_CODOPE'       },;
									{ 'BFZ_CODEMP'	, 'BRX_CODEMP'       },;
									{ 'BFZ_MATRIC'	, 'BRX_MATRIC'       },;
									{ 'BFZ_CODFOR'	, 'BRX_CODFOR'		 },;
									{ 'BFZ_CODFAI'	, 'BRX_CODFAI'		}},;
									BFZ->( IndexKey(  ) ) )  								
	
	oModel:SetDescription( FunDesc() )
	
	// Controle de repetição de linha
	oModel:GetModel( 'BJLDETAIL' ):SetUniqueLine( { 'BJL_CODFOR' } ) 
	oModel:GetModel( 'BRXDETAIL' ):SetUniqueLine( { 'BRX_CODFAI' } ) 
	
	oModel:GetModel( 'MasterBA1' ):SetDescription( 'Familia' )
    oModel:GetModel( 'BJLDETAIL' ):SetDescription( 'Forma de Cobrança' )	
	oModel:GetModel( 'BRXDETAIL' ):SetDescription( 'Faixa Etaria' )	
	oModel:GetModel( 'BFZDETAIL' ):SetDescription( 'Desconto' )

	oModel:SetPrimaryKey({"BJL_FILIAL","BJL_CODOPE","BJL_CODEMP","BJL_MATRIC","BJL_CODFOR"})
	
	oStruBA1:SetProperty('BA1_CODINT' , MODEL_FIELD_INIT  , { || BA3->BA3_CODINT})
	oStruBA1:SetProperty('BA1_CODEMP' , MODEL_FIELD_INIT  , { || BA3->BA3_CODEMP})
	oStruBA1:SetProperty('BA1_MATRIC' , MODEL_FIELD_INIT  , { || BA3->BA3_MATRIC})
	
	// Substitui o dicionario da tabela BJL para MVC
	oStruBJL:SetProperty('BJL_CODFOR' , MODEL_FIELD_WHEN  , { || PlM260NAlMVC(oModel, "BJL") } )
	oStruBJL:SetProperty('BJL_CODFOR' , MODEL_FIELD_VALID , { || PlsVldCbMVC("2", "3","BJL_DESFOR",,oModel) })
	oStruBJL:setProperty('BJL_CODEMP' , MODEL_FIELD_INIT	, { || BA1->BA1_CODEMP} )
	oStruBJL:setProperty('BJL_CODFOR' , MODEL_FIELD_INIT	, { || "103"} )

	//Inicializador para os campos
	oStruBJL:SetProperty('BJL_CODOPE' , MODEL_FIELD_INIT  , { || oModel:GetValue('MasterBA1','BA1_CODINT')})
	oStruBJL:SetProperty('BJL_MATRIC' , MODEL_FIELD_INIT  , { || oModel:GetValue('MasterBA1','BA1_MATRIC')})

	oStruBRX:SetProperty('BRX_CODOPE' , MODEL_FIELD_INIT , { || oModel:GetValue('MasterBA1','BA1_CODINT')}) // Falta fazer PlVerFai
	oStruBRX:SetProperty('BRX_CODEMP' , MODEL_FIELD_INIT , { || oModel:GetValue('MasterBA1','BA1_CODEMP')}) // Falta fazer PlVerFai	
	oStruBRX:SetProperty('BRX_MATRIC' , MODEL_FIELD_INIT , { || oModel:GetValue('MasterBA1','BA1_MATRIC')}) // Falta fazer PlVerFai


	// Substitui o dicionario da tabela BRX para MVC
	oStruBRX:SetProperty('BRX_CODFAI' , MODEL_FIELD_INIT  , { || PlsIncreMVC(oModel,"BRXDETAIL","BRX_CODFAI")})
	oStruBRX:SetProperty('BRX_CODFOR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BJLDETAIL','BJL_CODFOR')})
	oStruBRX:SetProperty('BRX_TIPUSR' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('BRXDETAIL','BRX_TIPUSR')),.T.,ExistCpo("BIH",oModel:GetValue('BRXDETAIL','BRX_TIPUSR'),1))})
	oStruBRX:SetProperty('BRX_GRAUPA' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('BRXDETAIL','BRX_GRAUPA')),.T.,ExistCpo("BRP",oModel:GetValue('BRXDETAIL','BRX_GRAUPA'),1))})	
	oStruBRX:SetProperty('BRX_IDAINI' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai	
	oStruBRX:SetProperty('BRX_IDAFIN' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai	
	
	
	// Substitui o dicionario da tabela BFZ para MVC
	oStruBFZ:SetProperty('BFZ_CODFOR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BJLDETAIL','BJL_CODFOR')})
	oStruBFZ:SetProperty('BFZ_CODFAI' , MODEL_FIELD_INIT  , { || oModel:GetValue('BRXDETAIL','BRX_CODFAI')})

	/*Não permito adicionar linhas no Grid*/
		
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P2
@since   15/08/19
/*/
//-------------------------------------------------------------------

Static Function ViewDef()  

	Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
	Local oStruBJL := FWFormStruct(2,'BJL', { |cCampo| AllTrim(cCampo) $ 'BJL_CODFOR|BJL_DESFOR|BJL_AUTOMA' } ) 
	Local oStruBRX := FWFormStruct(2,'BRX')
    Local oStruBFZ := FWFormStruct(2,'BFZ')
    Local oModel   := FWLoadModel( 'PLSA260BJL' )
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx

	oView := FWFormView():New()

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2)) 
	Next

	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA1' ,  oStruBA1,  'MasterBA1' )
    oView:AddGrid(  'VIEW_BJL' ,  oStruBJL,  'BJLDETAIL' )
	oView:AddGrid(  'VIEW_BRX' ,  oStruBRX,  'BRXDETAIL' )
	oView:AddGrid(  'VIEW_BFZ' ,  oStruBFZ,  'BFZDETAIL' ) 

    oStruBA1:SetNoFolder()
   	oStruBJL:SetNoFolder()
	oStruBRX:SetNoFolder()
	oStruBFZ:SetNoFolder()

	//Removo campos que são preenchidos automaticamente da tela
	oStruBRX:RemoveField('BRX_CODFOR')
	oStruBFZ:RemoveField('BFZ_CODFOR')

	oView:CreateHorizontalBox( 'SUPERIOR' , 15) 
	oView:CreateHorizontalBox( 'MEIO'	  , 20) 
	oView:CreateHorizontalBox( 'INFERIOR1', 35)
	oView:CreateHorizontalBox( 'INFERIOR2', 30)

	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BJL', 'MEIO')	
	oView:SetOwnerView('VIEW_BRX', 'INFERIOR1')
	oView:SetOwnerView('VIEW_BFZ', 'INFERIOR2') 
	
	oView:EnableTitleView('VIEW_BA1','Familia')
	oView:EnableTitleView('VIEW_BJL','Taxa de Adesão')
	oView:EnableTitleView('VIEW_BRX','Familias x Valores de Adesao')
	oView:EnableTitleView('VIEW_BFZ','Tx Adesao x Desc x Familia')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GridBJLOk
Carrega a taxa de adesão do subcontrato se tiver.
@author  DEV TOTVS
@version P2
@since   28/10/19
/*/
//-------------------------------------------------------------------
Static Function GridBJLOk(oGrid)

	Local oModel     := FWModelActive()
	Local oModelBJL  := oModel:GetModel( 'BJLDETAIL' )
	Local oModelBRX  := oModel:GetModel( 'BRXDETAIL' )
	Local oModelBFZ  := oModel:GetModel( 'BFZDETAIL' )
	Local nOperation := oModel:GetOperation()
	Local cChave     := ""
	Local nLine      := 0
	Local nLineBFV   := 0
	Local aSaveLines := FWSaveRows()

	If oModelBJL:IsInserted() .AND. !Empty(oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')) .and. !oModelBJL:isDeleted(oModelBJL:GetLine())
		If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)
			//Posiciono a BA3, pois necessito do CODPLA da familia
			BA3->(DbSetOrder(1))
			BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
			cChave := BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)
			     
		
			If lJuridico
				//Verifico se existe taxa de adesão no SubContrato, caso exista, adiciono no grid da BRX
				BR6->(dbSetOrder(1))
				if BR6->(msSeek( xFilial('BR6')+cChave+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')))

					while !BR6->(eof()) .and. BR6->(BR6_FILIAL+BR6_CODIGO+BR6_NUMCON+BR6_VERCON+BR6_SUBCON+BR6_VERSUB+BR6_CODPRO+BR6_VERPRO+BR6_CODFOR) ==;
											xFilial('BR6')+cChave+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')
						If(nLine == 0)
							
							oModel:LoadValue( 'BJLDETAIL', 'BJL_FILIAL' , xFilial("BJL"))
							oModel:LoadValue( 'BJLDETAIL', 'BJL_CODOPE' , PLSINTPAD())
							oModel:LoadValue( 'BJLDETAIL', 'BJL_CODEMP' , BA1->BA1_CODEMP)
							oModel:LoadValue( 'BJLDETAIL', 'BJL_MATRIC' , BA1->BA1_MATRIC)   
							oModel:LoadValue( 'BJLDETAIL', 'BJL_CODFOR' , BR6->BR6_CODFOR)  
						EndIf	
						nLine:=oModelBRX:getline()	

						If(nLine > 0)
							oModelBRX:GoLine(nLine)
							oModelBRX:LoadValue('BRX_FILIAL', xFilial('BRX'))
							oModelBRX:LoadValue('BRX_CODOPE', PLSINTPAD())
							oModelBRX:LoadValue('BRX_CODEMP', BA1->BA1_CODEMP)
							oModelBRX:LoadValue('BRX_MATRIC', BA1->BA1_MATRIC)      
							oModelBRX:LoadValue('BRX_CODFOR', BR6->BR6_CODFOR)
							oModelBRX:LoadValue('BRX_CODFAI', BR6->BR6_CODFAI)			    	
							oModelBRX:LoadValue('BRX_TIPUSR', BR6->BR6_TIPUSR)						
							oModelBRX:LoadValue('BRX_GRAUPA', BR6->BR6_GRAUPA)						
							oModelBRX:LoadValue('BRX_VLRADE', BR6->BR6_VLRADE)
							oModelBRX:LoadValue('BRX_PERADE', BR6->BR6_PERADE)
							oModelBRX:LoadValue('BRX_SEXO'  , BR6->BR6_SEXO)
							oModelBRX:LoadValue('BRX_IDAINI', BR6->BR6_IDAINI)
							oModelBRX:LoadValue('BRX_IDAFIN', BR6->BR6_IDAFIN)
							oModelBRX:LoadValue('BRX_AUTOMA', BR6->BR6_AUTOMA)
							oModelBRX:LoadValue('BRX_ANOMES', BR6->BR6_ANOMES)
							oModelBRX:LoadValue('BRX_VLRANT', BR6->BR6_VLRANT)
						EndIf  
						
						//Verifico se Existe dados na BFV e carrego na BFZ 
						BFV->(DBSetOrder(1))
						If BFV->(MsSeek( xFilial("BFV") + cChave+oModel:GetValue( "BRXDETAIL",  'BRX_CODFOR') + oModel:GetValue( "BRXDETAIL",  'BRX_CODFAI')))
							while !BFV->(eof()) .and. BFV->(BFV_FILIAL+BFV_CODIGO+BFV_NUMCON+BFV_VERCON+BFV_SUBCON+BFV_VERSUB+BFV_CODPRO+BFV_VERPRO+BFV_CODFOR+BFV_CODFAI) ==;
										xFilial('BFV')+cChave+oModel:GetValue( "BRXDETAIL",  'BRX_CODFOR')+oModel:GetValue( "BRXDETAIL",  'BRX_CODFAI')
									
								nLineBFV := oModelBFZ:GetLine()
			

								If(nLineBFV > 0)
									oModelBFZ:GoLine(nLineBFV)
									oModelBFZ:LoadValue('BFZ_FILIAL', xFilial('BRX'))
									oModelBFZ:LoadValue('BFZ_CODOPE', PLSINTPAD())
									oModelBFZ:LoadValue('BFZ_CODEMP', BA1->BA1_CODEMP)
									oModelBFZ:LoadValue('BFZ_MATRIC', BA1->BA1_MATRIC)   
									oModelBFZ:LoadValue('BFZ_CODFOR', BFV->BFV_CODFOR)							
									oModelBFZ:LoadValue('BFZ_CODFAI', BFV->BFV_CODFAI)
									oModelBFZ:LoadValue('BFZ_TIPUSR', BFV->BFV_TIPUSR)
									oModelBFZ:LoadValue('BFZ_GRAUPA', BFV->BFV_GRAUPA)
									oModelBFZ:LoadValue('BFZ_PERCEN', BFV->BFV_PERCEN)
									oModelBFZ:LoadValue('BFZ_VALOR' , BFV->BFV_VALOR)
									oModelBFZ:LoadValue('BFZ_QTDDE' , BFV->BFV_QTDDE)
									oModelBFZ:LoadValue('BFZ_QTDATE', BFV->BFV_QTDATE)
									oModelBFZ:LoadValue('BFZ_TIPO'  , BFV->BFV_TIPDES)
									oModelBFZ:LoadValue('BFZ_AUTOMA', BFV->BFV_AUTOMA)							
								EndIf

								BFV->(dbSkip()) 
								If BFV->(BFV_FILIAL+BFV_CODIGO+BFV_NUMCON+BFV_VERCON+BFV_SUBCON+BFV_VERSUB+BFV_CODPRO+BFV_VERPRO+BFV_CODFOR+BFV_CODFAI) ==	xFilial('BFV')+cChave+oModel:GetValue( "BRXDETAIL",  'BRX_CODFOR')+oModel:GetValue( "BRXDETAIL",  'BRX_CODFAI')
									nLineBFV := oModelBFZ:AddLine()
								Endif
							EndDo
	
							
						EndIf
					
						BR6->(dbSkip())
						If BR6->(BR6_FILIAL+BR6_CODIGO+BR6_NUMCON+BR6_VERCON+BR6_SUBCON+BR6_VERSUB+BR6_CODPRO+BR6_VERPRO+BR6_CODFOR) ==	xFilial('BR6')+cChave+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')
							nLine := oModelBRX:AddLine()
						Endif

					EndDo  
				Endif
			Else
				
				BJ9->(dbSetOrder(1))
				BRY->(dbSetOrder(1))
				BFZ->(dbSetOrder(1))

				if BJ9->(msSeek( xFilial('BJ9')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')))

					while !BJ9->(eof()) .and. BJ9->(BJ9_FILIAL+BJ9_CODIGO+BJ9_VERSAO+BJ9_CODFOR) ==xFilial('BJ9')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')
						oModel:LoadValue( 'BJLDETAIL', 'BJL_FILIAL' , xFilial("BJL"))
						oModel:LoadValue( 'BJLDETAIL', 'BJL_CODOPE' , PLSINTPAD())
						oModel:LoadValue( 'BJLDETAIL', 'BJL_CODEMP' , BA3->BA3_CODEMP)
						oModel:LoadValue( 'BJLDETAIL', 'BJL_MATRIC' , BA3->BA3_MATRIC)   
						oModel:LoadValue( 'BJLDETAIL', 'BJL_CODFOR' , BJ9->BJ9_CODFOR) 
						

						if BRY->(msSeek( xFilial('BRY')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')))
				
							while !BRY->(eof()) .and. BRY->(BRY_FILIAL+BRY_CODIGO+BRY_VERSAO+BRY_CODFOR) ==xFilial('BJ9')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')

								oModelBRX:LoadValue('BRX_FILIAL', xFilial('BRX'))
								oModelBRX:LoadValue('BRX_CODOPE', PLSINTPAD())
								oModelBRX:LoadValue('BRX_CODEMP', BA3->BA3_CODEMP)
								oModelBRX:LoadValue('BRX_MATRIC', BA3->BA3_MATRIC)      
								oModelBRX:LoadValue('BRX_CODFOR', BRY->BRY_CODFOR)
								oModelBRX:LoadValue('BRX_CODFAI', BRY->BRY_CODFAI)			    	
								oModelBRX:LoadValue('BRX_TIPUSR', BRY->BRY_TIPUSR)						
								oModelBRX:LoadValue('BRX_GRAUPA', BRY->BRY_GRAUPA)						
								oModelBRX:LoadValue('BRX_VLRADE', BRY->BRY_VLRADE)
								oModelBRX:LoadValue('BRX_PERADE', BRY->BRY_PERADE)
								oModelBRX:LoadValue('BRX_SEXO'  , BRY->BRY_SEXO)
								oModelBRX:LoadValue('BRX_IDAINI', BRY->BRY_IDAINI)
								oModelBRX:LoadValue('BRX_IDAFIN', BRY->BRY_IDAFIN)
								oModelBRX:LoadValue('BRX_AUTOMA', "1")
								oModelBRX:LoadValue('BRX_ANOMES', BRY->BRY_ANOMES)
								oModelBRX:LoadValue('BRX_VLRANT', BRY->BRY_VLRANT)
							
								if BFX->(msSeek( xFilial('BFX')+BRY->(+BRY_CODIGO+BRY_VERSAO+BRY_CODFOR)))
				
									while !BFX->(eof()) .and. BFX->(BFX_FILIAL+BFX_CODIGO+BFX_VERSAO+BFX_CODFOR) ==BRY->(BRY_FILIAL+BRY_CODIGO+BRY_VERSAO+BRY_CODFOR)
										oModelBFZ:LoadValue('BFZ_FILIAL', xFilial('BRX'))
										oModelBFZ:LoadValue('BFZ_CODOPE', PLSINTPAD())
										oModelBFZ:LoadValue('BFZ_CODEMP', BA3->BA3_CODEMP)
										oModelBFZ:LoadValue('BFZ_MATRIC', BA3->BA3_MATRIC)   
										oModelBFZ:LoadValue('BFZ_CODFOR', BFX->BFX_CODFOR)							
										oModelBFZ:LoadValue('BFZ_CODFAI', BFX->BFX_CODFAI)
										oModelBFZ:LoadValue('BFZ_TIPUSR', BFX->BFX_TIPUSR)
										oModelBFZ:LoadValue('BFZ_GRAUPA', BFX->BFX_GRAUPA)
										oModelBFZ:LoadValue('BFZ_PERCEN', BFX->BFX_PERCEN)
										oModelBFZ:LoadValue('BFZ_VALOR' , BFX->BFX_VALOR)
										oModelBFZ:LoadValue('BFZ_QTDDE' , BFX->BFX_QTDDE)
										oModelBFZ:LoadValue('BFZ_QTDATE', BFX->BFX_QTDATE)
										oModelBFZ:LoadValue('BFZ_TIPO'  , BFX->BFX_TIPO)
										oModelBFZ:LoadValue('BFZ_AUTOMA', "1")		

										BFX->(DBSkip())	
										If BFX->(BFX_FILIAL+BFX_CODIGO+BFX_VERSAO+BFX_CODFOR) ==BRY->(BRY_FILIAL+BRY_CODIGO+BRY_VERSAO+BRY_CODFOR)
											oModelBFZ:AddLine()
										EndIf	
									Enddo
								Endif

								BRY->(DBSkip())
								If BRY->(BRY_FILIAL+BRY_CODIGO+BRY_VERSAO+BRY_CODFOR) ==xFilial('BJ9')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')
									oModelBRX:AddLine()
	
								EndIf
							Enddo	
						Endif
						BJ9->(dbSkip())
						If  BJ9->(BJ9_FILIAL+BJ9_CODIGO+BJ9_VERSAO+BJ9_CODFOR) ==xFilial('BJ9')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO)+oModel:GetValue( "BJLDETAIL",  'BJL_CODFOR')
							oModel:AddLine()
						Endif
					EndDo 
				EndIf
			EndIf   
		EndIf
	EndIf

	FWRestRows( aSaveLines )

Return .T.
