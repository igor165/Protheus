#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'CRMA190A.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} Funções
Relacionamento entre as funções de conexão

@author Paulo Figueira
@since		17/02/2014
@version P12
/*/
//-------------------------------------------------------------------
Function CRMA190A()
Local oBrowse

Private aRotina:= MenuDef()
Private aEntidade := {}
Private aEntClone := {}

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('AO8')

oBrowse:SetAttach( .T. )

oBrowse:SetTotalDefault('AO8_FILIAL','COUNT',STR0012 ) // "Total de Registros"

oBrowse:Activate()

Return NIL   

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()

MenuDef - Operações que serão utilizadas pela aplicação

@return   	aRotina - Array das operações

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.CRMA190A' OPERATION 2 ACCESS 0 //Visualizar
ADD OPTION aRotina TITLE STR0003    ACTION 'VIEWDEF.CRMA190A' OPERATION 3 ACCESS 0 //Incluir
ADD OPTION aRotina TITLE STR0004    ACTION 'VIEWDEF.CRMA190A' OPERATION 4 ACCESS 0 //Alterar
ADD OPTION aRotina TITLE STR0005    ACTION 'VIEWDEF.CRMA190A' OPERATION 5 ACCESS 0 //Excluir

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Modelo de dados (Regra de Negocio)

@return   	oModel - Objeto do modelo

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruAO8 := FWFormStruct( 1, 'AO8', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruAOA := FWFormStruct( 1, 'AOA', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('CRMA190A', /*bPreValidacao*/, { |oModel| Crma190aOk( oModel )},{ |oModel| Crma190aGrv( oModel ) })

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'AO8MASTER', /*cOwner*/, oStruAO8, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'AOADETAIL','AO8MASTER', oStruAOA ,,,,,)
    
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription( STR0001 ) //"Cadastro de Funções"
oModel:GetModel( 'AOADETAIL' ):SetUniqueLine({"AOA_CDFUNC" })

// Montagem do relacionamento
oModel:SetRelation("AOADETAIL",{{"AOA_FILIAL","xFilial('AOA')"},{"AOA_CODFUN","AO8_CODFUN"}},AOA->( IndexKey(1)))//AOA_FILIAL + AOA_CODFUN  + AOA_CDFUNC

oModel:GetModel( 'AOADETAIL' ):SetOptional( .T. )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

View - Interface de interacao com o Modelo de Dados (Model)

@return   	oView - Objeto da View

@author	Paulo Figueira
@since		17/02/2014
@version	P12 
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oModel   	:= FWLoadModel( 'CRMA190A' )
Local oStruAO8 	:= FWFormStruct( 2, 'AO8', /*bAvalCampo*/,/*lViewUsado*/ ) 
Local oStruAOA 	:= FWFormStruct( 2, 'AOA', /*bAvalCampo*/,/*lViewUsado*/ )  

Local oView

oView := FWFormView():New()
// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )
oView:AddField( 'VIEW_AO8', oStruAO8, 'AO8MASTER' )
oView:AddGrid( 'VIEW_AOA' , oStruAOA, 'AOADETAIL' )	// Adiciona no nosso View um controle do tipo Grid (antiga Getdados)

// Acrescenta um objeto externo ao View do MVC
oView:AddOtherObject("VIEW_ENTIDADE", {|oPanel| CRMA190Panel(oPanel,oModel)})

// Criar um "box" Horizontal
oView:CreateHorizontalBox( 'TELA_CAB' , 50 )
oView:CreateHorizontalBox( 'TELA_ROD' , 50 )

//Divide a tela superior em duas
oView:CreateVerticalBox( 'SUPERIORESQ', 60, 'TELA_CAB' )
oView:CreateVerticalBox( 'SUPERIORDIR', 40, 'TELA_CAB' )

// Relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView("VIEW_AO8","SUPERIORESQ")
oView:SetOwnerView("VIEW_ENTIDADE","SUPERIORDIR")
oView:SetOwnerView("VIEW_AOA","TELA_ROD")

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_AO8', STR0006 )//"Função" 
oView:EnableTitleView( 'VIEW_ENTIDADE',STR0007 )//"Entidade"
oView:EnableTitleView( 'VIEW_AOA', STR0008)//Funções Correpondentes

oView:SetCloseOnOk({|| .T.} )

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA190Panel()

View - Interface de interacao com o Modelo de Dados (Model)

@oPanel   	Objeto superior direito (Mark)

@return   	Nil

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function CRMA190Panel( oPanel, oModel )

Local aArea		:= GetArea()
Local oBrwEnt		:= Nil 
Local cCapital 	:= ""
Local oView 		:= FWViewActive()
Local lMark  		:= .F.
Local oColEnt		:= Nil
Local nOperation	:= oView:oModel:nOperation
Local aEntConex	:= {}
Local nX			:= 0

aEntidade := {}
//aEntClone := {}

//Filtra os dados da tabela AO2 para mostrar no Mark
DbSelectArea("AO2")
AO2->(DbSetOrder(1))
AO2->(DbGoTop())
While AO2->(!EOF())
	If xFilial("AO2")== AO2->AO2_FILIAL .And. AO2->AO2_CONEX == "1"
		aAdd(aEntConex,{lMark, AO2->AO2_ENTID, AO2->AO2_DESCR})
	EndIf	
	AO2->(DbSkip())
EndDo 	
//Regra para alteração e visualização do MARK
 If Len(aEntConex) > 0	
	For nX:=1 To Len(aEntConex) 
		If nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_VIEW .Or. nOperation == MODEL_OPERATION_DELETE 
			DbSelectArea("AO9")
			AO9->(DbSetOrder(1))
			If DbSeek(xFilial("AO9")+ oView:oModel:Getvalue( 'AO8MASTER', 'AO8_CODFUN' ) + aEntConex[nX][2]) 
				lMark := .T.
			Else
				lMark := .F.	
			EndIf
		Else
			lMark := .F.
		EndIf
		AAdd( aEntidade,{lMark,aEntConex[nX][2],aEntConex[nX][3]} )
	Next nX	
EndIf
 
aEntClone:= aClone(aEntidade)

//Cria a FWBrowse com a primeira coluna de marcação e o itens filtrados na SX5
DEFINE FWBROWSE oBrwEnt DATA ARRAY ARRAY aEntidade LINE BEGIN 1 OF oPanel
	ADD MARKCOLUMN oColEnt DATA {|| IIF(aEntidade[oBrwEnt:At()][1],"LBOK","LBNO") } DOUBLECLICK {||aEntidade[oBrwEnt:At()][1] := !aEntidade[oBrwEnt:At()][1]} HEADERCLICK {|| aEval(aEntidade,{|z| z[1] := !z[1]}) ,oBrwEnt:Refresh() } OF oBrwEnt 
	ADD COLUMN oColEnt DATA &("{ || AllTrim(aEntidade[oBrwEnt:At()][3]) }") TITLE STR0009 TYPE "C" SIZE 30 OF oBrwEnt  	// "Entidades"
ACTIVATE FWBROWSE oBrwEnt 

If nOperation == 4 
	oView:oModel:SetValue('AO8MASTER', "AO8_DESFUN" , oView:oModel:GetValue('AO8MASTER', "AO8_DESFUN"))
EndIf

RestArea( aArea )

Return   

//------------------------------------------------------------------------------
/*/{Protheus.doc} Crma190aOk()

Validação TudoOk
Valida se alguma entidade foi preenchida
@Return   	lRet

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function Crma190aOk( oModel )

Local lRet      	:= .T.
Local aEntOk		:= Aclone(aEntidade)
Local oView 		:= Nil
Local nOperation	:= 3

//-------------------------------------------------------------------
// Desvio necessário para o correto funcionamento do robô de testes
//------------------------------------------------------------------- 
If !IsBlind()
	oView 		:= FWViewActive()
	nOperation	:= oView:oModel:nOperation
	
	aEntOk:= aSort(aEntOk,,,{| x , y | x[1] > y[1] } )
Else
	nOperation 	:= oModel:GetOperation() 
EndIf

If Len(aEntOk)>0	.And. (nOperation	<> 5 .Or. nOperation	<> 2)
	If aEntOk[1][1] == .F.
		Help(" ",1,STR0011,,STR0010,1,0) // Atenção # "Selecione uma entidade correspondente"
		lRet := .F.
	EndIf		
EndIf	

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} Crma190aGrv()

Efetua a Gravação da tabela AO9 pois é um objeto não relacionado diretamente ao 
model. As tabelas AO8 e AOA já são gravadas pelo próprio commit do MVC
@Return    lRet

@author	Paulo Figueira
@since		17/02/2014
@version	P12
/*/
//------------------------------------------------------------------------------

Static Function Crma190aGrv( oModel )

Local aArea   		:= GetArea()         
Local aAreaAO9 		:= AO9->( GetArea() )
Local aAreaAO8 		:= AO8->( GetArea() )
Local aAreaAOA 		:= AOA->( GetArea() )
Local nX			:= 0
Local nI			:= 0
Local aEntOk		:= Aclone(aEntidade)
Local oView 		:= FWViewActive()
Local nOperation	:= oModel:GetOperation()
Local oMdlAO8		:= oModel:GetModel( 'AO8MASTER' )
Local oMdlAOA		:= oModel:GetModel( 'AOADETAIL' )
Local lRet			:= .T.

DbSelectArea( "AO9" )
AO9->( DbSetOrder( 1 ) )//AO9_FILIAL+AO9_CODFUN+AO9_ENTIDA                                                                                                                                                                                                                          

Begin Transaction

	Do Case
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inclusao 			                                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case nOperation ==  MODEL_OPERATION_INSERT
		aEntOk:= aSort(aEntOk,,,{| x , y | x[1] > y[1] } )
		If Len(aEntOk)>0
			For nX:=1 to Len(aEntOk)
				If aEntOk[nX][1] == .T.
					RecLock("AO9",.T.)
						AO9->AO9_FILIAL := xFilial( "AO9" )
						AO9->AO9_CODFUN := oModel:GetValue("AO8MASTER","AO8_CODFUN")
						AO9->AO9_ENTIDA := aEntOK[nX][2]
					AO9->(MsUnlock())	
				Else
					Exit
				EndIf		
			Next nX
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Alteracao            			                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case nOperation == MODEL_OPERATION_UPDATE
		If Len(aEntOk)>0
			For nX:= 1 To Len(aEntOK) 
				If DbSeek(xFilial("AO9") + oModel:GetValue("AO8MASTER","AO8_CODFUN")+ aEntOK[nX][2]) //AO9_FILIAL + AO9_CODFUN + AO9_ENTIDA 
					If aEntOK[nX][1] == .F.
						RecLock("AO9", .F.)
						AO9->(DbDelete())
						AO9->(MsUnlock())
					EndIf	
				Else
					If aEntOK[nX][1] == .T.
						RecLock("AO9", .T.)
						AO9->AO9_FILIAL := xFilial( "AO9" )
						AO9->AO9_CODFUN := oModel:GetValue("AO8MASTER","AO8_CODFUN")
						AO9->AO9_ENTIDA := aEntOK[nX][2]
						AO9->(MsUnlock())
					EndIf	
				EndIf
			Next nX
		EndIf
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Deleção            			                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Case nOperation == MODEL_OPERATION_DELETE	 
		    //Verifica se existe link para desfazer.
			For nI := 1 To oMdlAOA:Length()
				oMdlAOA:GoLine( nI )  
				DbSelectArea( "AOA" )
				AOA->( DbSetOrder( 1 ) )//AO8_FILIAL + AO8_CODFUN + AOA_CDFUNC
				If DbSeek( xFilial( "AOA" ) + oMdlAOA:GetValue( "AOA_CDFUNC" ) + oMdlAO8:GetValue( "AO8_CODFUN" ) )
					RecLock( "AOA", .F. )
					AOA->( DbDelete() )
					AOA->( MsUnLock() )
			    EndIf
			  Next( nI )
			If Len(aEntOk)>0
				For nX:= 1 To Len(aEntOK) 
					If DbSeek(xFilial("AO9") + oModel:GetValue("AO8MASTER","AO8_CODFUN")+ aEntOK[nX][2]) //AO9_FILIAL + AO9_CODFUN + AO9_ENTIDA
							RecLock("AO9", .F.)
							AO9->(DbDelete())
							AO9->(MsUnlock())	
					EndIf 
				Next nX
			EndIf	
	EndCase
		
	If lRet		
		lRet:= FwFormCommit(oModel)
		aEntidade:= aClone(aEntClone)
	EndIf	

	If nOperation <> MODEL_OPERATION_DELETE	 
		//-------------------------------------------------------------
		// Cria link da funcao correspondente com a funcao principal.
		//-------------------------------------------------------------
		DbSelectArea( "AO8" )
		DbSetOrder( 1 ) //AO8_FILIAL + AO8_CODFUN
		For nI := 1 To oMdlAOA:Length()
				
			oMdlAOA:GoLine( nI )                             
							
			If AO8->( DbSeek( xFilial( "AO8" ) + oMdlAOA:GetValue( "AOA_CDFUNC" ) ) )
			 	//Verifica se o link não foi efetuado para gravar corretamente
			 	DbSelectArea( "AOA" )
			 	DbSetOrder( 1 )//AO8_FILIAL + AO8_CODFUN + AOA_CDFUNC
				If !DbSeek( xFilial( "AOA" ) + oMdlAOA:GetValue( "AOA_CDFUNC" ) + oMdlAO8:GetValue( "AO8_CODFUN" ) )		
					RecLock( "AOA",.T. )
					
					AOA->AOA_FILIAL := xFilial( "AOA" )                	
					AOA->AOA_CDFUNC := oMdlAO8:GetValue( "AO8_CODFUN" )
					AOA->AOA_DESCOR := oMdlAO8:GetValue( "AO8_DESFUN" )
					AOA->AOA_CODFUN := oMdlAOA:GetValue( "AOA_CDFUNC" ) 
					
					AOA->( MsUnLock() )	
				EndIf				
			EndIf
									
		Next nI
	EndIf
	
	RestArea( aAreaAOA )	                     
	RestArea( aAreaAO8 ) 
	RestArea( aAreaAO9 )
		
	If !lRet
		DisarmTransaction()	
	EndIf
		
End Transaction
	
If !IsBlind()
	oView:Refresh()
EndIf

RestArea(aArea)

Return(.T.)
