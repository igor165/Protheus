#INCLUDE "OGA840.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"

/*/{Protheus.doc} OGA840
Rotina de Cadastro de Volume Disponível Plano de Vendas
@author thiago.rover
@since 05/07/2018
@version undefined
@param pcSafra, , descricao
@param pcCod, , descricao
@type function
/*/
Function OGA840(  )
	Local oMBrowse
	
	Private _cUniNeg := ''
    Private _cGrProd := ''
    Private _cSafra  := ''
    Private _cProd  := ''
    Private _cCodPla  := ''
	
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "N8Y" )
	oMBrowse:SetSeek(.T.)
	oMBrowse:SetFilterDefault(" N8Y_ATIVO='1' ")
	oMBrowse:SetMenuDef( "OGA840" )
	oMBrowse:SetAttach( .T. ) //visualizações
	oMBrowse:Activate()
 
Return()

/*/{Protheus.doc} MenuDef
Rotina de Cadastro de Volume Disponível Plano de Vendas
@author thiago.rover
@since 05/07/2018
@version undefined
@param pcSafra, , descricao
@param pcCod, , descricao
@type function
/*/
Static Function MenuDef()
Local aRotina  := {}
Local aRotina1 := {}

aAdd( aRotina, { STR0002, 'PesqBrw'       , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0003, 'ViewDef.OGA840', 0, 2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0004, 'ViewDef.OGA840', 0, 3, 0, Nil } ) //'Incluir'
aAdd( aRotina, { STR0005, 'ViewDef.OGA840', 0, 4, 0, Nil } ) //'Alterar'
aAdd( aRotina, { STR0006, 'ViewDef.OGA840', 0, 5, 0, Nil } ) //'Excluir'
aAdd( aRotina, { STR0007, 'ViewDef.OGA840', 0, 8, 0, Nil } ) //'Imprimir'
aAdd( aRotina, { STR0017, "OGA840Atu()"   , 0, 9, 0, Nil } ) //'Atualizar Plano'
aAdd( aRotina, { STR0020, 'OGAA880()'     , 0,10, 0, Nil } ) //"Gestão Volumes/Preço"

aAdd( aRotina, { STR0022,  aRotina1 	  , 0, 11, 0, .F. } ) //"Importar"
	
aAdd( aRotina1, { STR0023, "OGX820IMP('1')" , 0, 12, 0, .F. } ) //"Itens do Plano de Vendas"
aAdd( aRotina1, { STR0024, "OGX820IMP('2')" , 0, 12, 0, .F. } ) //"Condições de Recebimento"

Return aRotina

/*/{Protheus.doc} ModelDef()
Rotina de Cadastro de Volume Disponível Plano de Vendas
@author thiago.rover
@since 05/07/2018
@version undefined
@param pcSafra, , descricao
@param pcCod, , descricao
@type function
/*/
Static Function ModelDef()
	Local oStruN8Y := FWFormStruct( 1, "N8Y" )
	Local oModel   := MPFormModel():New( "OGA840", , {| oModel | PosModelo( oModel ) }, )
	
	oStruN8Y:AddTrigger( "N8Y_CODPRO", "N8Y_GRPROD", { || .T. }, { | x | fTrgN8YProd( X ) } )
	oStruN8Y:SetProperty("N8Y_DTATUA", MODEL_FIELD_INIT , { | | dDataBase } )

	oModel:AddFields( 'N8YUNICO', Nil, oStruN8Y )
	oModel:SetDescription( STR0001 ) //"Volume  Disp Plano de Vendas"
	oModel:GetModel( 'N8YUNICO' ):SetDescription( STR0008 ) //"Dados Vol Disp Plano de Vendas"
Return oModel

/*/{Protheus.doc} ViewDef()
Rotina de Cadastro de Volume Disponível Plano de Vendas
@author thiago.rover
@since 05/07/2018
@version undefined
@param pcSafra, , descricao
@param pcCod, , descricao
@type function
/*/
Static Function ViewDef()
	Local oStruN8Y := FWFormStruct( 2, 'N8Y' )
	Local oModel   := FWLoadModel( 'OGA840' )
	Local oView    := FWFormView():New()
	
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_N8Y', oStruN8Y, 'N8YUNICO' )
	
	oView:CreateHorizontalBox( "SUPERIOR" , 100 )
	oView:SetOwnerView( "VIEW_N8Y", "SUPERIOR" )
	oView:EnableTitleView( "VIEW_N8Y" )
	
	oView:SetCloseOnOk( {||.t.} )
	oView:SetViewCanActivate({ | oView | PreActiva( oView ) })

Return oView
  
 /** {Protheus.doc} fTrgN8YProd
Função criada para o campo produto
@return:    cRet - conteudo do campo
@author:    Tamyris Ganzenmueller
@since:     03/07/2018
@Uso:       OGA830
*/
Static Function fTrgN8YProd( cOpc )
	Local oModel	:= FwModelActive()
	Local oN8Y		:= oModel:GetModel( "N8YUNICO" )
	Local cRet	
	
	cRet :=  POSICIONE("SB1",1,XFILIAL("SB1")+oN8Y:GetValue("N8Y_CODPRO"),"B1_GRUPO")
	If Empty(cRet)
		oN8Y:SetValue("N8Y_DGRPRO",  "" )
	 	oN8Y:LoadValue("N8Y_DGRPRO", "" ) 
	EndIf
return cRet

 
 /*/{Protheus.doc} PosModelo(oModel)
Rotina de Cadastro de Volume Disponível Plano de Vendas
@author thiago.rover
@since 05/07/2018
@version undefined
@param pcSafra, , descricao
@param pcCod, , descricao
@type function
/*/
Static Function PosModelo(oModel)
	Local lRet       := .T.
	Local oN8Y		 := oModel:GetModel( "N8YUNICO" )
	Local nOperation := oModel:GetOperation()
	Local cAliasQry  := GetNextAlias()
	Local lTemN8W    := .F.
	
	If oModel:GetOperation() == MODEL_OPERATION_INSERT
		
		If !Empty(oN8Y:GetValue("N8Y_CODPRO")) .And. oN8Y:GetValue("N8Y_GRPROD") <> POSICIONE("SB1",1,XFILIAL("SB1")+oN8Y:GetValue("N8Y_CODPRO"),"B1_GRUPO")
			//"Grupo de Produto "
			Help( , , STR0011, , STR0010, 1, 0 )
			Return .F.
		EndIF
		
		//VALIDAÇÃO PARA NÃO PERMITIR INCLUIR UM PLANO DE VENDAS COM A MESMA FILIAL, SAFRA, GRUPO PRODUTO E PRODUTO
		cQuery := "SELECT * "
		cQuery += " FROM " + RetSqlName("N8Y") + " N8Y "
		cQuery += " WHERE N8Y.N8Y_FILIAL = '" + FwxFilial('N8Y') + " '"
		cQuery += " AND   N8Y.N8Y_SAFRA  = '" + oN8Y:GetValue("N8Y_SAFRA ") + "' "
		cQuery += " AND   N8Y.N8Y_GRPROD = '" + oN8Y:GetValue("N8Y_GRPROD") + "' "
		cQuery += " AND   N8Y.N8Y_CODPRO = '" + oN8Y:GetValue("N8Y_CODPRO") + "' "
		cQuery += " AND   N8Y.N8Y_ATIVO  = '1'"
		cQuery += " AND   N8Y.D_E_L_E_T_ <> '*' "
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
	
		dbSelectArea(cAliasQry)
		(cAliasQry)->(dbGoTop())
		If (cAliasQry)->(!Eof() )
			lRet := .F.
		EndIf
		(cAliasQry)->(DbcloseArea())
		
		If !lRet
			//"AJUDA"#"Já existe Item para esta Filial, Safra, Grupo de Produto, Produto, Data de Atualização."
			Help( , , STR0011, , STR0012, 1, 0 )
			Return .F.
		EndIF
		
	ElseIF nOperation == MODEL_OPERATION_UPDATE
	
		//VALIDAR NAO PERMITIR ALTERAR MOEDA SE A MESMA ESTIVER UTILIZANDO NOS VOLUMES
		IF oN8Y:GetValue("N8Y_MOEDA") <> N8Y->N8Y_MOEDA 		
			cQuery := "SELECT * "
 			cQuery += " FROM " + RetSqlName("N8W") + " N8W "
			cQuery += " WHERE N8W.N8W_FILIAL = '" + FwxFilial('N8W') + " '"
			cQuery += "   AND N8W.N8W_CODPLA = '" + oN8Y:GetValue("N8Y_CODPLA") + "' "
			cQuery += "   AND N8W.N8W_MOEDA  =  " + alltrim(str(N8Y->N8Y_MOEDA )) 
			cQuery += "   AND N8W.D_E_L_E_T_ = '' "
			cQuery := ChangeQuery(cQuery)
			DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
		
			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbGoTop())
			If (cAliasQry)->(!Eof() )
				lTemN8w := .T.
			EndIf
			(cAliasQry)->(DbcloseArea())
			
			If lTemN8w
				//"AJUDA"#"Moeda não poderá ser alterada pois possui volume cadastrado"
				Help( , , STR0011, ,STR0021, 1, 0 )
				Return .F.
			EndIF
		EndIF
	EndIf

	If oModel:GetOperation() <> MODEL_OPERATION_DELETE .AND. SuperGetMV("MV_AGRO035",.F.,.T.)
		DbSelectArea("SB1")
		SB1->(DbSetOrder(4)) //B1_FILIAL+B1_GRUPO+B1_COD
		If SB1->(DbSeek(FwxFilial("SB1")+oN8Y:GetValue("N8Y_GRPROD")))
			While SB1->(!EOF()) .And. SB1->(B1_FILIAL + B1_GRUPO) == FwxFilial("SB1")+oN8Y:GetValue("N8Y_GRPROD")

				DbSelectArea("DXC")
				DXC->(DbSetOrder(5)) //DXC_FILIAL+DXC_CODPRO
				If DXC->(DbSeek(FwxFilial("DXC")+SB1->B1_COD)) .And. Empty(oN8Y:GetValue("N8Y_CODPRO"))

					cDescGrp := AllTrim(Posicione("SBM", 1, FwxFilial("SBM")+SB1->B1_GRUPO, "BM_DESC"))

					HELP(' ',1,STR0013,,STR0014+ cDescGrp +STR0015 +AllTrim(DXC_CODIGO)+".",2,0,,,,,, {STR0016+AllTrim(RetTitle("N8Y_CODPRO"))+"."})
							//"Grupo de Produtos"###"O grupo de Produtos "###" contém produtos que fazem parte do conjunto "###"Nos volumes disponíveis do Plano de Vendas onde o grupo de produto contém produtos que estão contidos em conjuntos é obrigatório informar o campo "
					Return .F.
				EndIf
				DXC->(DbcloseArea())

				SB1->(DbSkip())
			EndDo
		EndIf
		SB1->(DbcloseArea())
	EndIf
	
	Begin Transaction
	
	//Integridade das tabelas filhas do Plano de Vendas ao deletar o plano de vendas
	If nOperation = MODEL_OPERATION_DELETE

		//Itens do Plano de Vendas
		N8W->(DbSelectArea("N8W"))
		N8W->(DbSetOrder(1))
		If N8W->(DbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA ))
			While N8W->(!EOF()) .And. N8W->(N8W_FILIAL + N8W_CODPLA) == N8Y->(N8Y_FILIAL + N8Y_CODPLA)
					
				RecLock("N8W",.F.)
					N8W->(DbDelete())
				N8W->(MsUnlock())
					
				N8W->(DbSkip())
			EndDo
		EndIf
		N8W->(DbCloseArea())

		//Condições de Recebimento dos itens do plano de venda
		NCU->(DbSelectArea("NCU"))
		NCU->(DbSetOrder(1))//NCU_FILIAL+NCU_CODPLA+NCU_SEQITE+NCU_MESANO
		If NCU->(DbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA ))
			While NCU->(!EOF()) .And. NCU->(NCU_FILIAL + NCU_CODPLA) == N8Y->(N8Y_FILIAL + N8Y_CODPLA)
					
				RecLock("NCU",.F.)
				NCU->(DbDelete())
				NCU->(MsUnlock())
					
				NCU->(DbSkip())
			EndDo
		EndIf
		NCU->(DbCloseArea())
		
	EndIf
	
	End Transaction
		
Return lRet

/*/{Protheus.doc} PreActiva(oView)
Função de pré-validação do modelo
@type  Static Function
@author rafael.kleestadt
@since 09/07/2018
@version 1.0
@param oView, object, objeto da View de dados
@return .T., logycal, se o Plano de Vendas estiver encerrado não permite alteração.
@example
(examples)
@see (links_or_references)
/*/
Static Function PreActiva(oView)
Local nOperation := oView:GetOperation()

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

	If N8Y->N8Y_ATIVO == '3'

		Help(" ", 1, ".OGA840000001.") //##Problema: Plano de Vendas Encerrado.
		Return .F.                     //##Solução: Reabra o Plano de Vendas para utilizar essa opção.

	EndIf

EndIf

Return .T.


/*/{Protheus.doc} OGA840Atu
//Atualizar plano de vendas
@author tamyris.g
@since 08/01/2019
@version 1.0
@return ${return}, ${return_description}
@param nOpc, numeric, descricao
@type function
/*/
Function OGA840Atu()
    Default lAutomato := .F.
	Default cFilPV    := N8Y->N8Y_FILIAL  
	Default cGrProd   := N8Y->N8Y_GRPROD
	Default cSafra    := N8Y->N8Y_SAFRA
	Default cProd     := N8Y->N8Y_CODPRO
	Default cCodPla   := N8Y->N8Y_CODPLA
	Default cUnidNeg  := N8Y->N8Y_FILIAL  
 	
	_cUniNeg := cUnidNeg
	_cGrProd := cGrProd
	_cSafra  := cSafra
	_cProd   := cProd
	_cCodPla := cCodPla
	
	If !lAutomato 
		Processa({|| OGX820(.F.) }, STR0018, STR0019 ) //"Atualizando Plano de Vendas" ## "AGUARDE"
	Else 	 
	    dbSelectArea('N8Y')
	    N8Y->(DbGoTop()) 
	    N8Y->(DbSetOrder(1))
	    If N8Y->(dbSeek(cFilPV + cCodPla))
	       OGX820(.T.)
	    EndIf
	EndIf    
Return .T. 
