#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/** {Protheus.doc} OGAA970
Cadastro de permissões de relatorio para portal
@param:     Nil
@return:    nil
@since:     23/11/2018
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGAA970( )
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NJ0")			// Alias da tabela utilizada
	oBrowse:SetMenuDef("OGAA970")	// Nome do fonte onde esta a função MenuDef
	oBrowse:SetDescription("Regras de Qualidade por Clientes")	// Descrição do browse 
	
	oBrowse:Activate()                                       
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@Uso: 		OGAA970
*/
/*
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"        OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGAA970" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGAA970" OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE STR0005   ACTION "VIEWDEF.OGAA970" OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE STR0006   ACTION "VIEWDEF.OGAA970" OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina TITLE STR0007   ACTION "VIEWDEF.OGAA970" OPERATION 8 ACCESS 0 //"Imprimir"
	
	Return aRotina
	*/
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@Uso: 		OGAA970
*/
Static Function ModelDef()
	Local oStruNJ0 := FWFormStruct( 1, "NJ0" , {|cCampo|  ALLTRIM(cCampo) $ "NJ0_CGC|NJ0_CODENT|NJ0_LOJENT|NJ0_NOME|NJ0_CODFOR|NJ0_LOJFOR|NJ0_NOMFOR|NJ0_CODCLI|NJ0_LOJCLI|NJ0_NOMCLI|" } )
	Local oStruNLJ := FWFormStruct( 1, "NLJ" )
	Local oModel
	
	oStruNJ0:SetProperty("NJ0_CGC"    , MODEL_FIELD_WHEN, { || .F.  }  )
    oStruNJ0:SetProperty("NJ0_CODENT" , MODEL_FIELD_WHEN, { || .F.  }  )
    oStruNJ0:SetProperty("NJ0_LOJENT" , MODEL_FIELD_WHEN, { || .F.  }  )
    oStruNJ0:SetProperty("NJ0_NOME"   , MODEL_FIELD_WHEN, { || .F.  }  )
    oStruNJ0:SetProperty("NJ0_CODFOR"   , MODEL_FIELD_WHEN, { || .F.  }  )
    oStruNJ0:SetProperty("NJ0_LOJFOR"   , MODEL_FIELD_WHEN, { || .F.  }  )
    oStruNJ0:SetProperty("NJ0_CODCLI"   , MODEL_FIELD_WHEN, { || .F.  }  )
    oStruNJ0:SetProperty("NJ0_LOJCLI"   , MODEL_FIELD_WHEN, { || .F.  }  )
    
	oModel :=  MPFormModel():New( "OGAA970", /*<bPre >*/ ,, {| oModel | GrvModelo( oModel ) }  , /*bCancel*/ )
	
	//oStruN9L:AddTrigger( "N9L_CODUSU", "N9L_CODCON", { || .T. }, { | x | fTrgN9LCon( x ) } )
        
	oModel:AddFields("OGAA970_NJ0", Nil, oStruNJ0 ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid ( 'MODEL_GRID', 'OGAA970_NJ0', oStruNLJ, ,  ,{|oGridModel, nLine, cAction| PreGrid(oGridModel, nLine, cAction)}/**/ , , ) 
	
	oModel:GetModel( "MODEL_GRID" ):SetUniqueLine( { "NLJ_CODENT","NLJ_TPRELA" } )
	oModel:SetPrimaryKey({"NJ0_FILIAL","NJ0_CGC"})
	oModel:SetRelation( "MODEL_GRID", { { "NLJ_FILIAL", "xFilial( 'NLJ' )" }, { "NLJ_CODENT", "NJ0_CODENT" } }, NLJ->( IndexKey( 1 ) ) )
		
Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@Uso: 		OGAA970/
*/
Static Function ViewDef()

	Local oModel := FWLoadModel("OGAA970")
	Local oView  := Nil
	Local oStruNJ0 := FWFormStruct( 2, "NJ0" , {|cCampo|  ALLTRIM(cCampo) $ "NJ0_CGC|NJ0_CODENT|NJ0_LOJENT|NJ0_NOME|NJ0_CODFOR|NJ0_LOJFOR|NJ0_NOMFOR|NJ0_CODCLI|NJ0_LOJCLI|NJ0_NOMCLI|" } )
	Local oStruNLJ := FWFormStruct( 2, "NLJ" )
	
	oStruNLJ:RemoveField("NLJ_IDUSR")
	oStruNLJ:RemoveField("NLJ_CODENT")
		              
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "OGAA970_NJ0" , oStruNJ0, /*cLinkID*/ )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	
	oView:AddGrid( 'VIEW_GRID', oStruNLJ, 'MODEL_GRID' )
	  
	//oView:CreateHorizontalBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( 'TELA', 40 )
    oView:CreateHorizontalBox( 'GRID', 60 )   
  
	// Associa um View a um box
	oView:SetOwnerView( 'OGAA970_NJ0', 'TELA' )
    oView:SetOwnerView( 'VIEW_GRID', 'GRID' )
Return oView

Function OGAA970POR()

    FWExecView('', 'VIEWDEF.OGAA970', 9, , {|| .T. }) //executado para refazer a view - reload da estrutura de campos

Return


/** {Protheus.doc} PreGrid
Validação do model
@param: 	Nil
@Uso: 		OGAA970
*/

Static Function PreGrid(oModelNLJ, nLine, cAction) 
	Local oModel		:= FwModelActivate()
	Local oModelNJ0     := oModel:GetModel( "OGAA970_NJ0" )
	Local cQuery        := ""
	Local cAliasQry     := GetNextAlias()
	
	//Preenche o valor dos campos Cod Ent e Codigo de usuario portal	
	If cAction == "ADDLINE" .OR. (cAction == "CANSETVALUE" .AND. Empty(oModelNLJ:GetValue("NLJ_IDUSR",nLine) ) )
		If !EMPTY( oModelNJ0:GetValue("NJ0_CODCLI") ) 
		
			cQuery := " SELECT N9L_IDUSR FROM " + RetSqlName('N9L') + " N9L " 
			cQuery += " INNER JOIN " + RetSqlName('AC8') + " AC8 ON AC8.AC8_CODCON = N9L.N9L_CODCON  AND AC8.AC8_ENTIDA = 'SA1' AND AC8.D_E_L_E_T_ = ' '  "
			cQuery += " INNER JOIN " + RetSqlName('SA1') + " SA1 ON AC8.AC8_CODENT LIKE SA1.A1_COD + '%' "
			cQuery += " INNER JOIN " + RetSqlName('NJ0') + " NJ0 ON NJ0.NJ0_CODCLI = SA1.A1_COD AND NJ0.NJ0_LOJCLI = SA1.A1_LOJA AND NJ0.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE N9L.D_E_L_E_T_ = ' '  AND NJ0.NJ0_CODCLI = '" + oModelNJ0:GetValue("NJ0_CODCLI") + "' AND NJ0.NJ0_LOJCLI = '"+oModelNJ0:GetValue("NJ0_LOJCLI")+"' "

		ElseIf !EMPTY( oModelNJ0:GetValue("NJ0_CODFOR") ) 
		
			cQuery := " SELECT N9L_IDUSR FROM " + RetSqlName('N9L') + " N9L " 
			cQuery += " INNER JOIN " + RetSqlName('AC8') + " AC8 ON AC8.AC8_CODCON = N9L.N9L_CODCON  AND AC8.AC8_ENTIDA = 'SA2' AND AC8.D_E_L_E_T_ = ' '  "
			cQuery += " INNER JOIN " + RetSqlName('SA2') + " SA2 ON AC8.AC8_CODENT LIKE SA2.A2_COD + '%'  "
			cQuery += " INNER JOIN " + RetSqlName('NJ0') + " NJ0 ON NJ0.NJ0_CODCLI = SA2.A2_COD AND NJ0.NJ0_LOJCLI = SA2.A2_LOJA AND NJ0.D_E_L_E_T_ = ' ' "
			cQuery += " WHERE N9L.D_E_L_E_T_ = ' '  AND NJ0.NJ0_CODCLI = '" + oModelNJ0:GetValue("NJ0_CODCLI") + "' AND NJ0.NJ0_LOJCLI = '"+oModelNJ0:GetValue("NJ0_LOJCLI")+"' "
	
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasQry,.T.,.T.)
		
		DbSelectArea( cAliasQry )
		DbGoTop()
		
		oModelNLJ:Goline(nLine)	
		oModelNLJ:LoadValue("NLJ_IDUSR", (cAliasQry)->N9L_IDUSR )		
		oModelNLJ:LoadValue("NLJ_CODENT", oModelNJ0:GetValue("NJ0_CODENT") )		
	
	EndIf

Return .T.
/** {Protheus.doc} GrvModelo
Função que grava o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	.t. - sempre verdadeiro
@author: 	Equipe Agroindustria
*/
Static Function GrvModelo( oModel )
	Local oModelNJ0	    := oModel:GetModel( "OGAA970_NJ0" )
	Local oModelNLJ	    := oModel:GetModel( "MODEL_GRID" )
	Local lRetorno      := .T.
	Local nX            := 1
	
	For nX = 1 To oModelNLJ:Length()
		oModelNLJ:Goline(nX)	
		
		GravacaoNLJ(oModelNLJ,oModelNJ0)
		
	Next
	
Return lRetorno

Static Function GravacaoNLJ(oModelNLJ,oModelNJ0)

	DbSelectArea("NLJ")
	DbSetOrder(2)
	If DbSeek( xFilial("NLJ") + oModelNJ0:GetValue("NJ0_CODENT") + oModelNLJ:GetValue("NLJ_TPRELA") )
		While NLJ->(!Eof()) .AND. xFilial("NLJ") + oModelNJ0:GetValue("NJ0_CODENT") + oModelNLJ:GetValue("NLJ_TPRELA") == NLJ->NLJ_FILIAL + NLJ->NLJ_CODENT + NLJ->NLJ_TPRELA
			
			Reclock("NLJ",.F.)
	
				NLJ->NLJ_EXIBTK 	:= oModelNLJ:GetValue("NLJ_EXIBTK")
				NLJ->NLJ_EXIBLS 	:= oModelNLJ:GetValue("NLJ_EXIBLS")
				NLJ->NLJ_EXIBLA 	:= oModelNLJ:GetValue("NLJ_EXIBLA")
				NLJ->NLJ_EXIBDF 	:= oModelNLJ:GetValue("NLJ_EXIBDF")
				NLJ->NLJ_FORMAT 	:= oModelNLJ:GetValue("NLJ_FORMAT")
				NLJ->NLJ_STFARD 	:= oModelNLJ:GetValue("NLJ_STFARD")
				NLJ->NLJ_EXDES 		:= oModelNLJ:GetValue("NLJ_EXDES") 
				NLJ->NLJ_EXFIB 		:= oModelNLJ:GetValue("NLJ_EXFIB") 
				NLJ->NLJ_EXPSO 		:= oModelNLJ:GetValue("NLJ_EXPSO") 
				NLJ->NLJ_EXMIC 		:= oModelNLJ:GetValue("NLJ_EXMIC") 
				NLJ->NLJ_EXRES 		:= oModelNLJ:GetValue("NLJ_EXRES") 
				NLJ->NLJ_EXSFC 		:= oModelNLJ:GetValue("NLJ_EXSFC") 
				NLJ->NLJ_EXUR 		:= oModelNLJ:GetValue("NLJ_EXUR")  
				NLJ->NLJ_EXUI 		:= oModelNLJ:GetValue("NLJ_EXUI")  
				NLJ->NLJ_EXS25 		:= oModelNLJ:GetValue("NLJ_EXS25") 
				NLJ->NLJ_EXS50 		:= oModelNLJ:GetValue("NLJ_EXS50") 
				NLJ->NLJ_EXCSP 		:= oModelNLJ:GetValue("NLJ_EXCSP") 
				NLJ->NLJ_EXELN 		:= oModelNLJ:GetValue("NLJ_EXELN") 
				NLJ->NLJ_EXRD 		:= oModelNLJ:GetValue("NLJ_EXRD")  
				NLJ->NLJ_EXB 		:= oModelNLJ:GetValue("NLJ_EXB")   
				NLJ->NLJ_EXCOR 		:= oModelNLJ:GetValue("NLJ_EXCOR") 
				NLJ->NLJ_EXLF 		:= oModelNLJ:GetValue("NLJ_EXLF")  
				NLJ->NLJ_EXSCN 		:= oModelNLJ:GetValue("NLJ_EXSCN") 
				NLJ->NLJ_EXARE 		:= oModelNLJ:GetValue("NLJ_EXARE") 
				NLJ->NLJ_EXCON 		:= oModelNLJ:GetValue("NLJ_EXCON") 
				NLJ->NLJ_EXFGR 		:= oModelNLJ:GetValue("NLJ_EXFGR") 
				NLJ->NLJ_EXSTA 		:= oModelNLJ:GetValue("NLJ_EXSTA") 
				NLJ->NLJ_EXMAT 		:= oModelNLJ:GetValue("NLJ_EXMAT") 
				NLJ->NLJ_EXMTE 		:= oModelNLJ:GetValue("NLJ_EXMTE") 
				NLJ->NLJ_EXCC 		:= oModelNLJ:GetValue("NLJ_EXCC")  
				NLJ->NLJ_EXCV 		:= oModelNLJ:GetValue("NLJ_EXCV")  
				
			NLJ->(MsUnlock())
							
			NLJ->(DbSkip())
		EndDo
	Else
		Reclock("NLJ",.T.)
			NLJ->NLJ_FILIAL     := xFilial("NLJ")
			NLJ->NLJ_IDUSR 		:= oModelNLJ:GetValue("NLJ_IDUSR")
			NLJ->NLJ_TPRELA 	:= oModelNLJ:GetValue("NLJ_TPRELA")
			NLJ->NLJ_EXIBTK 	:= oModelNLJ:GetValue("NLJ_EXIBTK")
			NLJ->NLJ_EXIBLS 	:= oModelNLJ:GetValue("NLJ_EXIBLS")
			NLJ->NLJ_EXIBLA 	:= oModelNLJ:GetValue("NLJ_EXIBLA")
			NLJ->NLJ_EXIBDF 	:= oModelNLJ:GetValue("NLJ_EXIBDF")
			NLJ->NLJ_FORMAT 	:= oModelNLJ:GetValue("NLJ_FORMAT")
			NLJ->NLJ_STFARD 	:= oModelNLJ:GetValue("NLJ_STFARD")
			NLJ->NLJ_EXDES 		:= oModelNLJ:GetValue("NLJ_EXDES") 
			NLJ->NLJ_EXFIB 		:= oModelNLJ:GetValue("NLJ_EXFIB") 
			NLJ->NLJ_EXPSO 		:= oModelNLJ:GetValue("NLJ_EXPSO") 
			NLJ->NLJ_EXMIC 		:= oModelNLJ:GetValue("NLJ_EXMIC") 
			NLJ->NLJ_EXRES 		:= oModelNLJ:GetValue("NLJ_EXRES") 
			NLJ->NLJ_EXSFC 		:= oModelNLJ:GetValue("NLJ_EXSFC") 
			NLJ->NLJ_EXUR 		:= oModelNLJ:GetValue("NLJ_EXUR")  
			NLJ->NLJ_EXUI 		:= oModelNLJ:GetValue("NLJ_EXUI")  
			NLJ->NLJ_EXS25 		:= oModelNLJ:GetValue("NLJ_EXS25") 
			NLJ->NLJ_EXS50 		:= oModelNLJ:GetValue("NLJ_EXS50") 
			NLJ->NLJ_EXCSP 		:= oModelNLJ:GetValue("NLJ_EXCSP") 
			NLJ->NLJ_EXELN 		:= oModelNLJ:GetValue("NLJ_EXELN") 
			NLJ->NLJ_EXRD 		:= oModelNLJ:GetValue("NLJ_EXRD")  
			NLJ->NLJ_EXB 		:= oModelNLJ:GetValue("NLJ_EXB")   
			NLJ->NLJ_EXCOR 		:= oModelNLJ:GetValue("NLJ_EXCOR") 
			NLJ->NLJ_EXLF 		:= oModelNLJ:GetValue("NLJ_EXLF")  
			NLJ->NLJ_EXSCN 		:= oModelNLJ:GetValue("NLJ_EXSCN") 
			NLJ->NLJ_EXARE 		:= oModelNLJ:GetValue("NLJ_EXARE") 
			NLJ->NLJ_EXCON 		:= oModelNLJ:GetValue("NLJ_EXCON") 
			NLJ->NLJ_EXFGR 		:= oModelNLJ:GetValue("NLJ_EXFGR") 
			NLJ->NLJ_EXSTA 		:= oModelNLJ:GetValue("NLJ_EXSTA") 
			NLJ->NLJ_EXMAT 		:= oModelNLJ:GetValue("NLJ_EXMAT") 
			NLJ->NLJ_EXMTE 		:= oModelNLJ:GetValue("NLJ_EXMTE") 
			NLJ->NLJ_EXCC 		:= oModelNLJ:GetValue("NLJ_EXCC")  
			NLJ->NLJ_EXCV 		:= oModelNLJ:GetValue("NLJ_EXCV")  
			NLJ->NLJ_CODENT 	:= oModelNJ0:GetValue("NJ0_CODENT")	
		NLJ->(MsUnlock())
	EndIf
 
Return
 
