#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BJK
Funcao para abrir a tela de cadastro da Forma de Cobrança
@author DEV TOTVS
@since 26/07/19
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BJK(lAutomato)

	Local oBrowse
	Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260BJK' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260BJK 
@author  DEV TOTVS
@version P12
@since   26/07/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'  , 				'PesqBrw'         , 0, 1, 0, .T. } )//'Pesquisar'
	aAdd( aRotina, { 'Visualizar'  , 				'VIEWDEF.PLSA260BJK' , 0, 2, 0, NIL } ) //'Visualizar'
	aAdd( aRotina, { 'Alterar'  , 				'VIEWDEF.PLSA260BJK' , 0, 4, 0, NIL } )//'Alterar'
	aAdd( aRotina, { 'Incluir'  , 				'VIEWDEF.PLSA260BJK' , 0, 3, 0, NIL } )//'Alterar'

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260BJK 
@author  DEV TOTVS
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel	
	Local oStruBA1 		:= FWFormStruct(1,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_FILIAL|BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
	Local oStruBJK 		:= FWFormStruct(1,'BJK')	
	Local oStruBBU 		:= FWFormStruct(1,'BBU')
	Local oStruBFY 		:= FWFormStruct(1,'BFY')
	Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBJK	:= {"BJK_CODOPE","BJK_CODEMP","BJK_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBBU	:= {"BBU_CODOPE","BBU_CODEMP","BBU_MATRIC"} // Campos a serem adicionado na estrutura
	Local aCamposBFY	:= {"BFY_CODOPE","BFY_CODEMP","BFY_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx
	Local cCodFor		:=''
	//Local oEvent   := PL260BJKEVDEF():New()
	
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260BJK')
	
	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBA1)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBJK)
		oStruBJK := CriaCampMVC(1,oStruBJK,aCamposBJK[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBBU)
		oStruBBU := CriaCampMVC(1,oStruBBU,aCamposBBU[nNx]) 
	Next

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCamposBFY)
		oStruBFY := CriaCampMVC(1,oStruBFY,aCamposBFY[nNx]) 
	Next
	
	// Adiciona as estruturas no modelo
	oModel:addFields('MasterBA1' ,NIL,oStruBA1) 
	oModel:AddGrid('BJKDETAIL','MasterBA1',oStruBJK,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/{ |oModel| GridBJKOk(oModel) },/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:AddGrid('BBUDETAIL','BJKDETAIL', oStruBBU,/*bLinePre*/,/*bLinePost*/{ || GridBJKLinOk("BBU_IDAINI","BBU_IDAFIN",'BBUDETAIL') },/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
	oModel:AddGrid('BFYDETAIL','BBUDETAIL', oStruBFY,/*bLinePre*/,/*bLinePost*/{ || GridBJKLinOk("BFY_QTDDE" ,"BFY_QTDATE",'BFYDETAIL') .And. GridBJKLinOk("BFY_DATDE" ,"BFY_DATATE",'BFYDETAIL')  },/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)

	oModel:GetModel( "BJKDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BBUDETAIL" ):SetOptional(.T.)
	oModel:GetModel( "BFYDETAIL" ):SetOptional(.T.)

	// Relacionamento entre as tabelas
	oModel:SetRelation( 'BJKDETAIL', { { 'BJK_FILIAL' 	, 'xFilial( "BJK" )'},;
									{ 'BJK_CODOPE'	, 'BA1_CODINT'       },;
									{ 'BJK_CODEMP'	, 'BA1_CODEMP'       },;
									{ 'BJK_MATRIC'	, 'BA1_MATRIC'       } },;									
									BJK->( IndexKey(  ) ) ) 

	oModel:SetRelation( 'BBUDETAIL', { { 'BBU_FILIAL' 	, 'xFilial( "BBU" )'},;
									{ 'BBU_CODOPE'	, 'BJK_CODOPE'       },;
									{ 'BBU_CODEMP'	, 'BJK_CODEMP'       },;
									{ 'BBU_MATRIC'	, 'BJK_MATRIC'       },;
									{ 'BBU_CODFOR'	, 'BJK_CODFOR'} },;
									BBU->( IndexKey(  ) ) )

	oModel:SetRelation( 'BFYDETAIL', { { 'BFY_FILIAL' 	, 'xFilial( "BFY" )'},;
									{ 'BFY_CODOPE'	, 'BBU_CODOPE'       },;
									{ 'BFY_CODEMP'	, 'BBU_CODEMP'       },;
									{ 'BFY_MATRIC'	, 'BBU_MATRIC'       },;
									{ 'BFY_CODFOR'	, 'BBU_CODFOR'       },;
									{ 'BFY_CODFAI'	, 'BBU_CODFAI'} },;
									BFY->( IndexKey(  ) ) )  								
	
    oModel:SetDescription( FunDesc() )	

	// Controle de repetição de linha
	oModel:GetModel( 'BJKDETAIL' ):SetUniqueLine( { 'BJK_CODFOR' } ) 
	oModel:GetModel( 'BBUDETAIL' ):SetUniqueLine( { 'BBU_CODFAI' } )  
	
	oModel:GetModel('MasterBA1'):SetDescription('Familia' )
    oModel:GetModel('BJKDETAIL'):SetDescription('Forma de Cobrança' )	
	oModel:GetModel('BBUDETAIL'):SetDescription('Faixa Etaria' )	
	oModel:GetModel('BFYDETAIL'):SetDescription('Desconto' )

	
	// Chave primaria
	oModel:SetPrimaryKey({"BJK_FILIAL","BJK_CODOPE","BJK_CODEMP","BJK_MATRIC","BJK_CODFOR"})

    //Instala o evento padrão do programa.
	PosicionaBJ1()

	oStruBA1:SetProperty('BA1_MATRIC' , MODEL_FIELD_INIT  , { || PlsBusMatric()})

	// Substitui o dicionario da tabela BJK para MVC
	oStruBJK:SetProperty('BJK_CODFOR' , MODEL_FIELD_VALID , { || PlsVldCbMVC("1", "3",,,oModel,@cCodFor)  .And.  PLSVLDCOLMvc(oModel) })
	oStruBJK:SetProperty('BJK_CODFOR' , MODEL_FIELD_WHEN  , { || PlM260NAlMVC(oModel, "BJK") } )
	
	oStruBJK:SetProperty('BJK_CODOPE' , MODEL_FIELD_INIT , { || oModel:GetValue('MasterBA1','BA1_CODINT') })
	oStruBJK:SetProperty('BJK_CODEMP' , MODEL_FIELD_INIT , { || oModel:GetValue('MasterBA1','BA1_CODEMP') })
	oStruBJK:SetProperty('BJK_MATRIC' , MODEL_FIELD_INIT , { || oModel:GetValue('MasterBA1','BA1_MATRIC') })

	oStruBBU:SetProperty('BBU_TIPUSR' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('BBUDETAIL','BBU_TIPUSR')),.T.,ExistCpo("BIH",oModel:GetValue('BBUDETAIL','BBU_TIPUSR'),1)) .And. PLSVLDCOLMvc(oModel)})
	oStruBBU:SetProperty('BBU_GRAUPA' , MODEL_FIELD_VALID , { || If(Empty(oModel:GetValue('BBUDETAIL','BBU_GRAUPA')),.T.,ExistCpo("BRP",oModel:GetValue('BBUDETAIL','BBU_GRAUPA'),1)) .And. PLSVLDCOLMvc(oModel)})
	oStruBBU:SetProperty('BBU_IDAINI' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai
	oStruBBU:SetProperty('BBU_IDAFIN' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai
	oStruBBU:SetProperty('BBU_QTDMIN' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai
	oStruBBU:SetProperty('BBU_QTDMAX' , MODEL_FIELD_VALID , { || .T.}) // Falta fazer PlVerFai	
	oStruBBU:SetProperty('BBU_CODFOR' , MODEL_FIELD_INIT  , { || '101'})
	oStruBBU:SetProperty('BBU_CODFAI' , MODEL_FIELD_INIT  , { || PlsIncreMVC(oModel,"BBUDETAIL","BBU_CODFAI")})
	oStruBBU:SetProperty('BBU_FAIFAM' , MODEL_FIELD_INIT  , { || If(BJ1->BJ1_FAIFAM == "1", "1", "0") })
	oStruBBU:SetProperty('BBU_DESTIP' , MODEL_FIELD_INIT  , { || If(oModel:GetModel('BBUDETAIL'):nLine == 0,"",;
							BIH->(Posicione("BIH",1,xFilial("BIH")+BBU->BBU_TIPUSR,"BIH_DESCRI")))})
	oStruBBU:SetProperty('BBU_DESGRA' , MODEL_FIELD_INIT  , { || If(oModel:GetModel('BBUDETAIL'):nLine == 0,"",;
							BRP->(Posicione("BRP",1,xFilial("BRP")+BBU->BBU_GRAUPA,"BRP_DESCRI")))})
	oStruBBU:SetProperty('BBU_TIPUSR' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_GRAUPA' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_SEXO'   , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_IDAINI' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_IDAFIN' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "0"})
	oStruBBU:SetProperty('BBU_FAIFAM' , MODEL_FIELD_WHEN  , { || BJ1->BJ1_FAIFAM == "2"})
	oStruBBU:SetProperty('BBU_QTDMIN' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "1"})
	oStruBBU:SetProperty('BBU_QTDMAX' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BBUDETAIL','BBU_FAIFAM') == "1"})
	
	// Substitui o dicionario da tabela BFY para MVC
	oStruBFY:SetProperty('BFY_CODFOR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BJKDETAIL','BJK_CODFOR')})
	oStruBFY:SetProperty('BFY_CODFAI' , MODEL_FIELD_INIT  , { || oModel:GetValue('BBUDETAIL','BBU_CODFAI')})
	oStruBFY:SetProperty('BFY_TIPUSR' , MODEL_FIELD_INIT  , { || oModel:GetValue('BBUDETAIL','BBU_TIPUSR')})

	oStruBFY:SetProperty('BFY_GRAUPA' , MODEL_FIELD_INIT  , { || oModel:GetValue('BBUDETAIL','BBU_GRAUPA')})

	oStruBFY:SetProperty('BFY_PERCEN' , MODEL_FIELD_WHEN  , { || oModel:GetValue('BFYDETAIL','BFY_VALOR') == 0})
	oStruBFY:SetProperty('BFY_VALOR'  , MODEL_FIELD_WHEN  , { || oModel:GetValue('BFYDETAIL','BFY_PERCEN') == 0})
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view da aplicação 
@author  DEV TOTVS
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA1 := FWFormStruct(2,'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_FILIAL|BA1_CODINT|BA1_CODEMP|BA1_MATRIC|' } )
	Local oStruBJK := FWFormStruct(2,'BJK' )	
	Local oStruBBU := FWFormStruct(2,'BBU')
    Local oStruBFY := FWFormStruct(2,'BFY')
    Local oModel   := FWLoadModel( 'PLSA260BJK')
	Local oView
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
	Local nNx	

	oView := FWFormView():New()
	
	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next

	oView:SetModel( oModel )
	
    oView:AddField( 'VIEW_BA1' , oStruBA1, 'MasterBA1' )
    oView:AddGrid(  'VIEW_BJK' , oStruBJK, 'BJKDETAIL' )
	oView:AddGrid(  'VIEW_BBU' , oStruBBU, 'BBUDETAIL' )
	oView:AddGrid(  'VIEW_BFY' , oStruBFY, 'BFYDETAIL' ) 

    oStruBA1:SetNoFolder()
   	oStruBJK:SetNoFolder()
	oStruBBU:SetNoFolder()
	oStruBFY:SetNoFolder()

	//Removo campos que são preenchidos automaticamente da tela
	oStruBBU:RemoveField('BBU_CODFOR')
	oStruBFY:RemoveField('BFY_CODFOR')

	oView:CreateHorizontalBox( 'SUPERIOR', 15) 
	oView:CreateHorizontalBox( 'MEIO'	 , 20) 
	oView:CreateHorizontalBox( 'INFERIOR1', 35)
	oView:CreateHorizontalBox( 'INFERIOR2', 30)

	oView:SetOwnerView('VIEW_BA1', 'SUPERIOR')
	oView:SetOwnerView('VIEW_BJK', 'MEIO')	
	oView:SetOwnerView('VIEW_BBU', 'INFERIOR1')
	oView:SetOwnerView('VIEW_BFY', 'INFERIOR2') 
	
	oView:EnableTitleView('VIEW_BA1','Familia')
	oView:EnableTitleView('VIEW_BJK','Forma de Cobrança')
	oView:EnableTitleView('VIEW_BBU','Faixas Etárias Famílias')
	oView:EnableTitleView('VIEW_BFY','Forma para Família de Desconto')
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GridBJKOk
Carrega os registro no Grid BBU BFY se encontrar no subcontrato
@author  DEV TOTVS
@version P12
@since   21/08/19
/*/
//-------------------------------------------------------------------
Static Function GridBJKOk(oModel)

	Local oModelBJK		:= FWModelActive()
	Local oBJK			:= oModelBJK:GetModel( 'BJKDETAIL' )
	Local oBBU			:= oModelBJK:GetModel( 'BBUDETAIL' )
	Local oBFY			:= oModelBJK:GetModel( 'BFYDETAIL' )
	Local nOperation	:= oModelBJK:GetOperation()
	Local cChave		:= ""
	Local aSaveLines	:= FWSaveRows()
	Local lRet			:= .T.
	Local nContProds	:= 0
	Local nContForma	:= 0

	If oBJK:IsInserted() .and. !Empty(oBJK:GetValue('BJK_CODFOR'))
		If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE)         

			//Identifico que como só Digitei o bjk_codfor ele entende que tenho que carregar as outras Grids 
			//com base no subcontradot pessoa Juridica ou produto pessoa fisica
			If Empty(oBBU:GetValue( 'BBU_VALFAI')) .AND. !Empty(oBJK:GetValue('BJK_CODFOR'))
			
				//Posiciono a BA3, pois necessito do CODPLA da familia
				BA3->(DbSetOrder(1))
				BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
				cChave := BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB+BA3_CODPLA+BA3_VERSAO)

				If lJuridico
					
					//Verifico se existe apenas 1 produto no subcontrato.
					BT6->( dbSetorder(1) )
					If BT6->( MsSeek(xFilial("BT6")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB) ) )
						While !BT6->(Eof()) .and. BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB) == BA3->(BA3_CODINT+BA3_CODEMP+BA3_CONEMP+BA3_VERCON+BA3_SUBCON+BA3_VERSUB)
							nContProds++
							BT6->( dbSkip() )
						Enddo
					EndIF
					
					If nContProds >= 1
						//Verifico se existe apenas uma forma de cobrança atrelada ao produto
						BT9->( dbSetorder(01) )
						If BT9->( MsSeek(xFilial("BT9")+BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO)))
							While !BT9->(Eof()) .and. Substr(BT9->BT9_CODIGO,1,4)+Substr(BT9->BT9_CODIGO,5,4)+BT9->(BT9_NUMCON+BT9_VERCON+;
									BT9_SUBCON+BT9_VERSUB+BT9_CODPRO+BT9_VERSAO) == BT6->(BT6_CODINT+BT6_CODIGO+BT6_NUMCON+BT6_VERCON+;
										BT6_SUBCON+BT6_VERSUB+BT6_CODPRO+BT6_VERSAO)
								nContForma++						
								BT9->( dbSkip() )
							Enddo
						Endif				
					EndIF
				
					If nContForma >= 1
				
						//Verifico se existe Faixa etaria no SubContrato, caso exista, adiciono no grid da BBU
						BTN->(dbSetOrder(3))
						If BTN->(msSeek( xFilial('BTN')+cChave))
							while !BTN->(eof()) .and. BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB+BTN_CODPRO+BTN_VERPRO) ==;
													xFilial('BTN')+cChave
							
									
								oBBU:LoadValue("BBU_CODOPE"	,	BA3->BA3_CODINT)
								oBBU:LoadValue("BBU_CODEMP"	,	BA3->BA3_CODEMP)
								oBBU:LoadValue("BBU_MATRIC"	,	BA3->BA3_MATRIC)
								oBBU:LoadValue("BBU_CODFOR"	, 	BTN->BTN_CODFOR)
								oBBU:LoadValue("BBU_CODFAI"	, 	BTN->BTN_CODFAI)
								oBBU:LoadValue("BBU_TABVLD"	, 	BTN->BTN_TABVLD)
								oBBU:LoadValue("BBU_TIPUSR"	, 	BTN->BTN_TIPUSR)
								oBBU:LoadValue("BBU_GRAUPA"	, 	BTN->BTN_GRAUPA)
								oBBU:LoadValue("BBU_SEXO"		, 	BTN->BTN_SEXO)
								oBBU:LoadValue("BBU_IDAINI"	, 	BTN->BTN_IDAINI)
								oBBU:LoadValue("BBU_IDAFIN"	, 	BTN->BTN_IDAFIN)
								oBBU:LoadValue("BBU_VALFAI"	, 	BTN->BTN_VALFAI)
								oBBU:LoadValue("BBU_FAIFAM"	, 	BTN->BTN_FAIFAM)
								oBBU:LoadValue("BBU_QTDMIN"	, 	BTN->BTN_QTDMIN)
								oBBU:LoadValue("BBU_QTDMAX"	, 	BTN->BTN_QTDMAX)
								oBBU:LoadValue("BBU_REJAPL"	, 	BTN->BTN_REJAPL)
								oBBU:LoadValue("BBU_AUTOMA"	, 	BTN->BTN_AUTOMA)
								oBBU:LoadValue("BBU_PERREJ"	, 	BTN->BTN_PERREJ)
								oBBU:LoadValue("BBU_ANOMES"	, 	BTN->BTN_ANOMES)
						


								//Verifico se Existe dados na BFT e carrego na BFY 
								BFT->(DBSetOrder(1))
								If BFT->(MsSeek( xFilial("BFT") + cChave+BTN->BTN_CODFOR+BTN->BTN_CODFAI))
									while !BFT->(eof()) .and. BFT->(BFT_FILIAL+BFT_CODIGO+BFT_NUMCON+BFT_VERCON+BFT_SUBCON+BFT_VERSUB+BFT_CODPRO+BFT_VERPRO+BFT_CODFOR+BFT_CODFAI) ==	xFilial('BFT')+cChave+BTN->BTN_CODFOR+BTN->BTN_CODFAI
											
										oBFY:LoadValue("BFY_CODFOR"	,BFT->BFT_CODFOR)
										oBFY:LoadValue("BFY_CODFAI"	,BFT->BFT_CODFAI)
										oBFY:LoadValue("BFY_TIPUSR"	,BFT->BFT_TIPUSR)
										oBFY:LoadValue("BFY_GRAUPA"	,BFT->BFT_GRAUPA)
										oBFY:LoadValue("BFY_PERCEN"	,BFT->BFT_PERCEN)
										oBFY:LoadValue("BFY_VALOR"		,BFT->BFT_VALOR)				
										oBFY:LoadValue("BFY_QTDDE"		,BFT->BFT_QTDDE)
										oBFY:LoadValue("BFY_TIPO"		,BFT->BFT_TIPO)
										oBFY:LoadValue("BFY_DATDE"		,BFT->BFT_DATDE)
										oBFY:LoadValue("BFY_DATATE"	,BFT->BFT_DATATE)
									
										BFT->(dbSkip())
										If BFT->(BFT_FILIAL+BFT_CODIGO+BFT_NUMCON+BFT_VERCON+BFT_SUBCON+BFT_VERSUB+BFT_CODPRO+BFT_VERPRO+BFT_CODFOR+BFT_CODFAI) ==	xFilial('BFT')+cChave+BTN->BTN_CODFOR+BTN->BTN_CODFAI
											oBFY:AddLine()
										Endif
									EndDo
								EndIf

								BTN->(dbSkip())
								If BTN->(BTN_FILIAL+BTN_CODIGO+BTN_NUMCON+BTN_VERCON+BTN_SUBCON+BTN_VERSUB+BTN_CODPRO+BTN_VERPRO) ==	xFilial('BTN')+cChave
									oBBU:AddLine()
								Endif
							
							EndDo  				
						EndIf
					Endif	
				Else
					BB3->(DbSetOrder(1))
					If BB3->(msSeek( xFilial('BB3')+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)))
						while !BB3->(eof()) .and. BB3->(BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
							
							oBBU:LoadValue("BBU_CODOPE"	,BA3->BA3_CODINT)
							oBBU:LoadValue("BBU_CODEMP"	,BA3->BA3_CODEMP)
							oBBU:LoadValue("BBU_MATRIC"	,BA3->BA3_MATRIC)
							oBBU:LoadValue("BBU_CODFOR"	,BB3->BB3_CODFOR)
							oBBU:LoadValue("BBU_CODFAI"	,BB3->BB3_CODFAI)
							oBBU:LoadValue("BBU_TABVLD"	,Date())
							oBBU:LoadValue("BBU_TIPUSR"	,BB3->BB3_TIPUSR)
							oBBU:LoadValue("BBU_GRAUPA"	,BB3->BB3_GRAUPA)
							oBBU:LoadValue("BBU_SEXO"		,BB3->BB3_SEXO)
							oBBU:LoadValue("BBU_IDAINI"	,BB3->BB3_IDAINI)
							oBBU:LoadValue("BBU_IDAFIN"	,BB3->BB3_IDAFIN)
							oBBU:LoadValue("BBU_VALFAI"	,BB3->BB3_VALFAI)
							oBBU:LoadValue("BBU_FAIFAM"	,BB3->BB3_FAIFAM)
							oBBU:LoadValue("BBU_QTDMIN"	,BB3->BB3_QTDMIN)
							oBBU:LoadValue("BBU_QTDMAX"	,BB3->BB3_QTDMAX)
							oBBU:LoadValue("BBU_REJAPL"	,BB3->BB3_REJAPL)
							oBBU:LoadValue("BBU_AUTOMA"	,"1")
							oBBU:LoadValue("BBU_PERREJ"	,BB3->BB3_PERREJ)
							oBBU:LoadValue("BBU_ANOMES"	,BB3->BB3_ANOMES)

							//Incluindo BFY
							BFS->(DbSetOrder(1))//BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR+BFS_CODFAI+BFS_TIPUSR
							If BFS->(MsSeek(xFilial("BFS")+BA3->(BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG+BB3->BB3_CODFAI)))
								while !BFS->(eof()) .and. BFS->(BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR+BFS_CODFAI) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)+BB3->BB3_CODFAI
									oBFY:LoadValue("BFY_CODOPE"	,BA3->BA3_CODINT) //
									oBFY:LoadValue("BFY_CODEMP"	,BA3->BA3_CODEMP) //
									oBFY:LoadValue("BFY_CODFOR"	,BFS->BFS_CODFOR)
									oBFY:LoadValue("BFY_CODFAI"	,BFS->BFS_CODFAI)
									oBFY:LoadValue("BFY_TIPUSR"	,BFS->BFS_TIPUSR)
									oBFY:LoadValue("BFY_GRAUPA"	,BFS->BFS_GRAUPA)
									oBFY:LoadValue("BFY_PERCEN"	,BFS->BFS_PERCEN)
									oBFY:LoadValue("BFY_VALOR"	,BFS->BFS_VALOR)				
									oBFY:LoadValue("BFY_QTDDE"	,BFS->BFS_QTDDE)
									oBFY:LoadValue("BFY_TIPO"	,BFS->BFS_TIPO)
									oBFY:LoadValue("BFY_DATDE"	,BFS->BFS_DATDE)
									oBFY:LoadValue("BFY_DATATE"	,BFS->BFS_DATATE)
									BFS->(dbSkip())
									If BFS->(BFS_FILIAL+BFS_CODIGO+BFS_VERSAO+BFS_CODFOR+BFS_CODFAI) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)+BB3->BB3_CODFAI
										oBFY:AddLine()
									EndIF
								EndDo
							EndIF

							BB3->(dbSkip())
							If BB3->(BB3_FILIAL+BB3_CODIGO+BB3_VERSAO+BB3_CODFOR) == BA3->(BA3_FILIAL+BA3_CODINT+BA3_CODPLA+BA3_VERSAO+BA3_FORPAG)
								oBBU:AddLine()	
							Endif
						EndDo
					EndIf
				EndIf   
			EndIf
		EndIf
	Endif	

	FWRestRows( aSaveLines )

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsIncreMVC
Gera o próximo numero para o campo
@author  DEV TOTVS
@version P12
@since   02/09/19
/*/
//-------------------------------------------------------------------
Function PlsIncreMVC(oModel,cDETAIL,cCampo)

	Local cCodFai   := "000"
	Local nTam	
	Local nNX	
	Local cMaior	:= "000" 

	nTam := TamSX3(cCampo)[1]

	If oModel:GetModel(cDETAIL):nLine == 0
		cCodFai := Padl(Soma1(cCodFai),nTam,'0')
	Else
		// Busco o ultimo codFai digitado
		For nNx := 1 To oModel:GetModel(cDETAIL):Length()
			oModel:GetModel(cDETAIL):GoLine(nNx)
			If !oModel:GetModel(cDETAIL):IsDeleted() // Verifica se a linha esta deletada
				If VAL(oModel:GetValue(cDETAIL,cCampo)) > VAL(cMaior)
						cMaior := oModel:GetValue(cDETAIL,cCampo)
				EndIf
			EndIf
		Next

		cCodFai := PadL(Soma1(cMaior), nTam,'0')	
	EndIf

Return cCodFai

//-------------------------------------------------------------------
/*/{Protheus.doc} PosicionaBJ1
Posiciono a tabela BJ1 para utilização das funções de dic dos campos
@author  DEV TOTVS
@version P12
@since   05/09/19
/*/
//-------------------------------------------------------------------
Function PosicionaBJ1()

	BA3->(DbSetOrder(1))
	BA3->(MsSeek(xFilial('BA3')+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))

	BJ1->(DbSetOrder(1))
	BJ1->(MsSeek(xFilial("BJ1")+BA3->BA3_FORPAG))

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} GridBJKLinOk
Validador de Quantidade de/ate e de  Data de Ate
@author  DEV TOTVS
@version P12
@since   10/01/2020
/*/
//-------------------------------------------------------------------
Function GridBJKLinOk(cCampoIni,cCampoFim,cModel)
Local oModel		:= FWModelActive()
Local oModelAux		:= oModel:GetModel(cModel)
Local nx 			:= 0
Local ny 			:= 0
Local lRet			:= .T.
Local nLineAtu		:= oModelAux:GetLine()


cCmpIni		:= oModelAux:GetValue(cCampoIni)
cCmpFim		:= oModelAux:GetValue(cCampoFim)

If Empty(cCmpIni) .and. Empty(cCmpFim)
	Return(.T.)
Endif


oModelAux:GoLine(1)
For nx := 1 to oModelAux:Length()

	oModelAux:GoLine(nx)

	
	For ny := 1 to oModelAux:Length()
		oModelAux:GoLine(ny)
		If nLineAtu <> oModelAux:GetLine() .and. !oModelAux:IsDeleted()
			If 	cCmpIni  >= oModelAux:GetValue(cCampoIni)  .and.    cCmpIni <= oModelAux:GetValue(cCampoFim) .or.  ;
				cCmpFim  >= oModelAux:GetValue(cCampoIni)  .and.    cCmpFim <= oModelAux:GetValue(cCampoFim) 
				Return(.F.)
			Endif
		Endif	
	Next ny 

Next nx

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
Local lRet		:= .T.
Local oBFY  	:= oModel:GetModel( 'BFYDETAIL' )
Local oBBU  	:= oModel:GetModel( 'BBUDETAIL' )
Local cCodGrau	:= oModel:GetValue('BBUDETAIL','BBU_GRAUPA') 
Local cTipUsr	:= oModel:GetValue('BBUDETAIL','BBU_TIPUSR')
Local cCodFai	:= oModel:GetValue('BBUDETAIL','BBU_CODFAI')
Local cCodFor	:= oModel:GetValue('BJKDETAIL','BJK_CODFOR')
Local nLin		:= 0


For nLin:= 1 to oBBU:Length() 
	If oBBU:GetValue( "BBU_CODFAI" ) == cCodFai
		oBBU:GoLine( nLin )
		oBBU:SetValue( "BBU_CODFOR" , cCodFor )
		oBBU:SetValue( "BBU_GRAUPA" , cCodGrau )
		oBBU:SetValue( "BBU_TIPUSR" , cTipUsr )
	Endif	
Next	


For nLin:= 1 to oBFY:Length() 
	If oBFY:GetValue( "BFY_CODFAI" ) == cCodFai
		oBFY:GoLine( nLin )
		oBFY:SetValue( "BFY_CODFOR" , cCodFor )
		oBFY:SetValue( "BFY_GRAUPA" , cCodGrau )
		oBFY:SetValue( "BFY_TIPUSR" , cTipUsr )
	Endif	
Next	


Return lRet


