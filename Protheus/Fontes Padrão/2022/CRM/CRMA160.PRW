#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'CRMA160.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA160()

Rotina de inclusão rápida de produtos na tabela de preçoes.

@author  Thamara Villa Jacomo

@since   22/01/2014
@version 1.0
/*/                
//-------------------------------------------------------------------
Function CRMA160()

Local aSize			:= FWGetDialogSize( oMainWnd ) 
Local oFWMVCWin		:= Nil
Local oModel		:= Nil   

oModel := FWLoadModel( "CRMA160" )
oModel:SetOperation( 4 )                                                 

oModel:GetModel( "XXZDETAIL" ):bLoad := { |oModel| CarregaTab(oModel) }
oModel:GetModel( "DA1DETAIL" ):bLoad := { |oModel| CRM160Init(oModel) }

oModel:GetModel( 'DA1DETAIL' ):SetUseOldGrid(.T.)
oModel:Activate()      
                  
oView := FWLoadView( "CRMA160" )
oView:SetModel( oModel )
oView:SetOperation( 4 )

oFWMVCWin := FWMVCWindow():New()
oFWMVCWin:SetUseControlBar( .T. )
oFWMVCWin:SetView( oView )
oFWMVCWin:SetCentered( .T. )
oFWMVCWin:SetPos( aSize[1], aSize[2] )
oFWMVCWin:SetSize( aSize[3], aSize[4])
oFWMVCWin:SetTitle( STR0001 )//"Inclusão Rápida de Produto na Tabela de Preços"
oFWMVCWin:oView:BCloseOnOk := {|oView|  CRM160AddIt( oView ) }  
oFWMVCWin:Activate()

Return         
           
//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de Dados - Regra de Negócio	

@return   	oModel - Objeto do Modelo

@author	Thamara Villa Jacomo
@since		23/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStruXXT	 := FWFormModelStruct():New()
Local oStruXXZ	 := FWFormModelStruct():New()

Local oStruDA1	 := FWFormStruct( 1, 'DA1' )
Local oModel		 := Nil                         
Local aAux			 := {}   

oStruDA1:SetProperty( 'DA1_CODTAB', MODEL_FIELD_VALID,FwBuildFeature( STRUCT_FEATURE_VALID,'ExistCpo("DA0")' ) )
oStruDA1:SetProperty( 'DA1_PRCVEN', MODEL_FIELD_OBRIGAT, .F. ) 

oStruDA1:SetProperty( 'DA1_CODPRO' , MODEL_FIELD_INIT,{|| SB1->B1_COD   })
oStruDA1:SetProperty( 'DA1_DESCRI' , MODEL_FIELD_INIT,{|| SB1->B1_DESC  })
oStruDA1:SetProperty( 'DA1_PRCBAS' , MODEL_FIELD_INIT,{|| SB1->B1_PRV1  })
                           
oStruXXT:AddField( STR0016, STR0017,"XXT_FILIAL", "C", FwSizeFilial(), 0)//"Filial"//"Filial do sistema"

oStruXXZ:AddField( STR0016, STR0017,"XXZ_FILIAL", "C", FwSizeFilial(), 0)//"Filial"//"Filial do sistema"
oStruXXZ:AddField( STR0018, STR0019,"XXZ_CODTAB", "C", 6, 0)//"Cod. Tab"//"Código Tab. Preço""
oStruXXZ:AddField( STR0020, STR0021,"XXZ_DESCRI", "C", 60, 0)//"Descrição"//""Descrição da Tabela de Preço"


aAux := FWStruTrigger( 'DA1_CODTAB', 'DA1_DESTAB', 'DA0->DA0_DESCRI', .T., 'DA0', 1, "xFilial('DA0')+FwFldGet('DA1_CODTAB')")
oStruDA1:AddTrigger( aAux[1], aAux[2], aAux[3], aAux[4] )

//Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'CRMA160',/*bPreValidacao*/,/*bPosValidacao*/, /*bCommit*/,/*bCancel*/ ) 

oModel:AddFields( 'DA0MASTER', /*cOwner*/, oStruXXT,/*bPreValidacao*/,/*bPosValidacao*/,{|| { xFilial( "DA0" ) } } )

oModel:AddGrid( 'DA1DETAIL', 'DA0MASTER', oStruDA1, { |oModelGrid| ValidaLin(oModelGrid) })
oModel:AddGrid( 'XXZDETAIL', 'DA0MASTER', oStruXXZ )


oModel:SetRelation( 'DA1DETAIL', { { 'DA1_FILIAL', 'xFilial( "DA1" )' } }, DA1->( IndexKey( 1 ) ) )
oModel:SetRelation( 'XXZDETAIL', { { 'XXZ_FILIAL', 'xFilial( "DA1" )' } }, DA1->( IndexKey( 1 ) ) )

oModel:GetModel("DA1DETAIL"):SetUniqueLine( {"DA1_CODTAB","DA1_CODPRO"} )

oModel:GetModel("DA1DETAIL"):SetUseOldGrid(.T.)
oModel:GetModel("DA1DETAIL"):SetUseOldGrid(.T.)
oModel:GetModel("DA1DETAIL"):SetOnlyQuery(.T.)

oModel:GetModel("DA0MASTER"):SetOnlyQuery(.T.)

//Setando propriedades do model XXZDETAIL
oModel:GetModel("XXZDETAIL"):SetNoInsertLine(.T.)
oModel:GetModel("XXZDETAIL"):SetNoDeleteLine(.T.)
oModel:GetModel("XXZDETAIL"):SetNoUpdateLine(.T.)
oModel:GetModel("XXZDETAIL"):SetOptional(.T.)
oModel:GetModel("XXZDETAIL"):SetUniqueLine( {"XXZ_FILIAL","XXZ_CODTAB"} )

oModel:SetDescription ( STR0025 )//"Atualização de Produtos"
oModel:SetPrimaryKey({})
                                     
oModel:GetModel( 'DA0MASTER' ):SetDescription( STR0022 )// "Tabela"
oModel:GetModel( 'DA1DETAIL' ):SetDescription( STR0023 )//""Adicionar Produto""

oModel:GetModel( 'XXZDETAIL' ):SetDescription( STR0024 )//"Tabelas de Preço Adicionadas"

 
Return( oModel )

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

Inteface

@return   	oView - Objeto da View

@author	Thamara Villa Jacomo
@since		23/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel	  := FWLoadModel( 'CRMA160' )
Local oStruDA1  := FWFormStruct( 2, 'DA1' )

Local oStruXXZ  := FWFormViewStruct():New()

Local oView     := Nil

oStruDA1:RemoveField( "DA1_ITEM" )    
oStruDA1:RemoveField( "DA1_GRUPO" )

oStruDA1:SetProperty( 'DA1_CODTAB', MVC_VIEW_LOOKUP, 'DA1IRP' )//Adiciona Consulta Padrão 
oStruDA1:SetProperty( "DA1_CODPRO", MVC_VIEW_CANCHANGE, .F. )  //Não deixa alterar  o campo

oStruXXZ:AddField("XXZ_CODTAB","02",STR0012,STR0012,{STR0013},"C","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)//"Código"//"Código da Tabela de Preço"
oStruXXZ:AddField("XXZ_DESCRI","03",STR0014,STR0014,{STR0015},"C","",Nil,Nil,.T.,Nil,Nil,Nil,Nil,Nil,.T.)//"Descrição"//""Descrição da tabela de preço""

//Cria o objeto da View
oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddGrid( 'VIEWDA1', oStruDA1, 'DA1DETAIL' )
oView:AddGrid( 'VIEWXXZ', oStruXXZ, 'XXZDETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 25 )
oView:CreateHorizontalBox( 'INFERIOR', 75 )

oView:SetOwnerView( 'VIEWXXZ', 'SUPERIOR' )
oView:SetOwnerView( 'VIEWDA1', 'INFERIOR' )	

oView:EnableTitleView("VIEWXXZ")
oView:EnableTitleView("DA1DETAIL")


Return( oView )

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Operações que serão utilizadas pela aplicação.
	
@return   	aRotina - Array das operações

@author	Thamara Villa Jacomo
@since		24/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
                          
Local aRotina 	:= {}

ADD OPTION aRotina Title  	STR0003	ACTION "PesqBrw" 	   OPERATION 1 ACCESS 0 //"Pesquisar"  
ADD OPTION aRotina Title 	STR0004	Action 'VIEW.CRMA160'  OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title 	STR0005 Action 'VIEW.CRMA160'  OPERATION 3 ACCESS 0 //"Incluir"

Return( aRotina )

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM160Init

Trata da inicialização automãtica de alguns campos do item

@sample 	CRM160Init( oModel )

@param		oModel -  Modelo de Dados
		

@return   	aLoadDA1 - Array dos campos 

@author	Thamara Villa Jacomo
@since		15/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM160Init( oModel )

Local oStruct		:= oModel:GetStruct()                               
Local aCamposDA1	:= aClone( oStruct:GetFields() )
Local aLoadDA1		:= { { 1, Array( Len( aCamposDA1 ) ) } }
Local nY := 0

Private INCLUI := .T.
Private n

For nY := 1 To Len( aCamposDA1 )    
	If aCamposDA1[nY][MODEL_FIELD_IDFIELD] == "DA1_CODPRO"
		aLoadDA1[1][2][nY] := SB1->B1_COD
	ElseIf aCamposDA1[nY][MODEL_FIELD_IDFIELD] == "DA1_DESCRI"	  
		aLoadDA1[1][2][nY] := SB1->B1_DESC
	ElseIf aCamposDA1[nY][MODEL_FIELD_IDFIELD] == "DA1_PRCBAS"	  
		aLoadDA1[1][2][nY] := SB1->B1_PRV1
	Else
		aLoadDA1[1][2][nY]	:= CriaVar(aCamposDA1[nY][MODEL_FIELD_IDFIELD],.T.)
	EndIf
Next nY

Return( aLoadDA1 )                     

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM160AddIt

Trata da confirmação dos dados(TudoOK)

@sample 	CRM160AddIt( oView )

@param		oView -  Interface
		

@return   	lRet - Se o processo foi efetivado com suceso.

@author	Thamara Villa Jacomo
@since		28/01/2014
@version	11.90
/*/
//------------------------------------------------------------------------------
Static Function CRM160AddIt( oView )

Local oMldTmpDA1 	:= oView:GetModel('DA1DETAIL')
Local oMdlOMS		:= Nil
Local oMdlDA1		:= Nil
Local oStruct		:= oMldTmpDA1:GetStruct()
Local aCamposDA1	:= aClone( oStruct:GetFields() )
Local aErro			:= {}
Local lRet			:= .T.
Local cCampo 		:= ""
Local nY			:= 0
Local nX			:= 0
Local nLinAtu		:= 0

Private oGrade 		:= Nil


DbSelectArea("DA0")
DbSetOrder(1)

		 
For nY := 1 To oMldTmpDA1:Length()

	oMldTmpDA1:GoLine(nY)
	
	If DA0->(DbSeek(xFilial("DA0")+oMldTmpDA1:GetValue("DA1_CODTAB")))
	
		oMdlOMS:= FWLoadModel('OMSA010')
		oMdlOMS:SetOperation(4)
		oMdlOMS:Activate()
		oMdlDA1 := oMdlOMS:GetModel( 'DA1DETAIL' )		
			
		
		nLinAtu := oMdlDA1:AddLine()
		
		If nLinAtu > 0
			oMdlDA1:GoLine(nLinAtu)
			//Valida os dados do model (Tabela de Preços X Inc. Rápida)
			For nX := 1 To Len( aCamposDA1 )
				If !aCamposDA1[nX][MODEL_FIELD_VIRTUAL] .AND. aCamposDA1[nX][MODEL_FIELD_IDFIELD] <> "AD1_ITEM"
					cCampo := aCamposDA1[nX][MODEL_FIELD_IDFIELD]
					oMdlDA1:SetValue( cCampo, oMldTmpDA1:GetValue( cCampo ) )
				EndIf	 
			Next nX	
		EndIf
		
		If ( lRet:= oMdlOMS:VldData() )
			lRet := oMdlOMS:CommitData()
		EndIf
		
		If !lRet
			aErro := oMdlOMS:GetErrorMessage()
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//|   			Estrutura do aErro                 |
			//| [1] identificador (ID) do formulário de origem |
			//| [2] identificador (ID) do campo de origem      |
			//| [3] identificador (ID) do formulário de erro   |
			//| [4] identificador (ID) do campo de erro        |
			//| [5] identificador (ID) do erro                 |
			//| [6] mensagem do erro                           |
			//| [7] mensagem da solução                        |
			//| [8] Valor atribuído                            |
			//| [9] Valor anterior		        	           |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
			//aErro[1] ao [5] Comentado para melhor apresentacao ao usuario. Mantido para facilitar posterior Debug.
			//AutoGrLog( "Id do formulário de origem:" + ' [' + AllToChar( aErro[1]  ) + ']' )
			//AutoGrLog( "Id do campo de origem:     " + ' [' + AllToChar( aErro[2]  ) + ']' )
			//AutoGrLog( "Id do formulário de erro:  " + ' [' + AllToChar( aErro[3]  ) + ']' )
			//AutoGrLog( "Id do campo de erro:       " + ' [' + AllToChar( aErro[4]  ) + ']' )
			//AutoGrLog( "Id do erro:                " + ' [' + AllToChar( aErro[5]  ) + ']' )
			AutoGrLog( STR0008 + ' [' + AllToChar( aErro[6]  ) + ']' )
			AutoGrLog( STR0009 + ' [' + AllToChar( aErro[7]  ) + ']' )
			AutoGrLog( STR0010 + ' [' + AllToChar( aErro[8]  ) + ']' )
			AutoGrLog( STR0011 + ' [' + AllToChar( aErro[9]  ) + ']' )
					
			MostraErro()	
		EndIf
	
	
		oMdlOMS:DeActivate()
	
	EndIf
	
Next nY


Return( lRet )


//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaTab

rotina para carregar as tabelas que o produto já está cadastrado

@sample	CarregaTab(oModel)

@param		oModel - objeto do modelo de dados
			
@return	aLoadDA1 - Array com os dados das tabelas que deveram ser carregadas no grid

@author	Victor Bitencourt		
@since		12/02/2015
@version	12.1.4

/*/
//---------------------------------------------------------------------------------------------------------------
Static Function CarregaTab(oModel)

Local aArea   	:= GetArea()
Local oStructDA1 :=  oModel:GetStruct()
Local aCamposDA1	:= aClone(oStructDA1:GetFields())

Local aLoadDA1   := {}
Local nLinha		:= 0
Local nY			:= 0

Private INCLUI	:= .F.

DbSelectArea("DA1")
DA1->(DbSetOrder(2)) //DA1_FILIAL+DA1_CODPRO+DA1_CODTAB+DA1_ITEM

If DA1->(DbSeek(xFilial("DA1")+ SB1->B1_COD))
	While DA1->(!Eof()) .AND. DA1->DA1_FILIAL == xFilial("DA1") .AND. DA1->DA1_CODPRO == SB1->B1_COD  
	
		Aadd(aLoadDA1,{nLinha++,Array(Len(aCamposDA1))})
		For nY := 1 To Len( aCamposDA1 )    
			If aCamposDA1[nY][MODEL_FIELD_IDFIELD] == "XXZ_CODTAB"
				aLoadDA1[nLinha][2][nY] := DA1->DA1_CODTAB
			ElseIf aCamposDA1[nY][MODEL_FIELD_IDFIELD] == "XXZ_DESCRI"	  
				aLoadDA1[nLinha][2][nY] := POSICIONE("DA0",1,XFILIAL("DA0")+DA1->DA1_CODTAB,"DA0_DESCRI")
		 	EndIf
		Next nY
		DA1->(DbSkip())
	EndDo
EndIf

RestArea(aArea)

Return( aLoadDA1 )


//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ValidaLin

Rotina para validar a linha que está sendo incluida

@sample	ValidaLin(oMdlDA1)

@param		oMdlDA1 - objeto do modela de dados ativo
			
@return	lRet - retorno lógico

@author	Victor Bitencourt		
@since		12/02/2015
@version	12.1.4

/*/
//---------------------------------------------------------------------------------------------------------------
Static Function ValidaLin(oMdlDA1)

Local aArea := GetArea()
Local lRet  := .T.

DbSelectArea( "DA0" )
DA0->( DbSetOrder( 1 ) )

DbSelectArea( "DA1" )
DA1->( DbSetOrder( 1 ) )

If !Empty(oMdlDA1:GetValue("DA1_CODTAB"))
	If DbSeek( xFilial( "DA0" ) + oMdlDA1:GetValue("DA1_CODTAB") )
		If DbSeek( xFilial( 'DA1' ) + oMdlDA1:GetValue("DA1_CODTAB") + PADR( SB1->B1_COD, TamSx3( "B1_COD" )[1] ) )
			lRet := .F.
			Help("",1,"CRM160VLDTAB")
		EndIf
	EndIf
EndIf

RestArea(aArea)

Return lRet
