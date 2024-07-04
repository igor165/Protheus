#Include 'Protheus.ch'
#Include "ApWizard.ch"
#Include 'FWMVCDef.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "CTBA019.CH"
//
Function CTBA019() 
Local oBrowse  

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("CVT")                                          
oBrowse:SetDescription( STR0001 )  //"SubContas Correlatas"

oBrowse:SetCacheView(.F.)// Não realiza o cache da viewdef
oBrowse:SetMenuDef("CTBA019")
oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author pauloc

@since 17/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ModelDef()
Local oModel
Local oStr1:= FWFormStruct(1,'CVT') 

oModel := MPFormModel():New('CTBA019',/*PreValidacao*/,{ |oModel| CTB019TDOK(oModel)}/*PosValidacao*/,)

oModel:SetDescription( STR0001 )  //"SubContas Correlatas"

oModel:addFields('ModelCVT',,oStr1)
oModel:SetPrimaryKey({ 'CVT_FILIAL', 'CVT_CTAPAI', 'CVT_CODIDT', 'CVT_SUBCTA' })

//oModel:getModel('ModelCVT'):SetOnlyQuery(.F.)

//oModel:SetVldActivate( {|oModel| .T. } )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author pauloc

@since 17/03/2015
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel := ModelDef()
Local oStr1:= FWFormStruct(2,'CVT') 

oView := FWFormView():New()
oView:SetModel(oModel)

oView:AddField('Master_CVT' , oStr1,'ModelCVT' )

oView:EnableTitleView('Master_CVT' , STR0001 )  //"SubContas Correlatas"

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para criar do menu 

@author pauloc

@since 17/03/2015
@version 1.0
@return aRotina 
/*/
//-------------------------------------------------------------------

Static Function MenuDef()  
Local aRotina := {} //Array utilizado para controlar opcao selecionada

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.CTBA019"	OPERATION 2	ACCESS 0 		 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.CTBA019"	OPERATION 3  	ACCESS 0      //"Incluir"     
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.CTBA019"	OPERATION 4 	ACCESS 0      //"Alterar"     
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.CTBA019"	OPERATION 5  	ACCESS 3 	   //"Excluir"	 
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.CTBA019" 	OPERATION 8 	ACCESS 0 	   //"Imprimir"	

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF()
Função para validar formulario de acordo com as regras do ECD 

@author pauloc

@since 17/03/2015
@version 1.0
@return lRet
/*/
//-------------------------------------------------------------------

Function CTB019TDOK(oModel)
Local lRet := .F.
Local nRecCVT
Local nCountCVT

If oModel:GetOperation() == MODEL_OPERATION_INSERT .OR. ;//Incluir
	oModel:GetOperation() == MODEL_OPERATION_UPDATE //Alterar

	//Verifica se conta pai eh diferente da subconta
	lRet := (M->CVT_CTAPAI != M->CVT_SUBCTA )
	
	If !lRet
		Help( ,, 'Help',, STR0007, 1, 0 )  //"Conta pai e subconta correlata devem ser diferentes."
	Endif
	
	//Conta Pai deve ser analitica
	If lRet
		dbSelectArea("CT1")
		dbSetOrder(1)
		lRet := dbSeek(xFilial("CT1")+M->CVT_CTAPAI )
		If !lRet
			Help( ,, 'Help',, STR0008, 1, 0 )  //"Conta pai não encontrada no plano de contas."
		Else
			lRet := (CT1->CT1_CLASSE == "2")  //ANALITICA
			If !lRet
				Help( ,, 'Help',, STR0009, 1, 0 )  //"Conta pai deve ser analitica no plano de contas"
			Endif
		Endif		
	Endif
	
	//Subconta correlata deve ser analitica
	If lRet
		dbSelectArea("CT1")
		dbSetOrder(1)
		lRet := dbSeek(xFilial("CT1")+M->CVT_SUBCTA)
		If !lRet
			Help( ,, 'Help',, STR0010, 1, 0 )  //"Subconta correlata não encontrada no plano de contas."
		Else
			lRet := (CT1->CT1_CLASSE == "2")  //ANALITICA
			If !lRet
				Help( ,, 'Help',, STR0011, 1, 0 )  //"Subconta correlata deve ser analitica no plano de contas."
			Endif
		Endif		
	Endif

    //Pesquisa na tabela se subconta correlata será unica 
	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		dbSelectArea("CVT")
		dbSetOrder(3)  //ordem de subconta
		lRet := ! dbSeek(xFilial("CVT")+M->CVT_SUBCTA)
		dbSetOrder(1) //volta para ordem 1 - Ident + Conta Pai + Subconta

		If !lRet
			Help( ,, 'Help',, STR0012, 1, 0 )  //"Subconta correlata deve ser unica no cadastro de subcontas correlatas."
		Endif
	EndIf
	
    //Pesquisa na tabela se subconta correlata será unica 
	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		
		nRecCVT := CVT->( Recno() )
		nCountCVT := 0		
		dbSelectArea("CVT")
		dbSetOrder(3)  //ordem de subconta
		dbSeek(xFilial("CVT")+M->CVT_SUBCTA)
		While CVT->( !Eof() .And. CVT_SUBCTA == M->CVT_SUBCTA )
			//despreza a contagem para o proprio recno a ser alterado
			If CVT->( Recno() ) == nRecCVT
				CVT->( dbSkip() )
				Loop
			EndIf
			nCountCVT++
			CVT->( dbSkip() )
		EndDo
		dbSetOrder(1) //volta para ordem 1 - Ident + Conta Pai + Subconta
		dbGoto(nRecCVT)
		
		lRet := ( nCountCVT == 0 )
							
		If !lRet
			Help( ,, 'Help',, STR0012, 1, 0 )  //"Subconta correlata deve ser unica no cadastro de subcontas correlatas."
		Endif
		
	EndIf

	//Codigo de identificacao tem que estar na tabela ST (SX5)
	If lRet 
		lRet := ExistCpo("SX5","ST"+M->CVT_CODIDT)
	EndIf
	
	//Verificar se codigo de identificacao sempre aponta para mesma conta pai
	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		
		dbSelectArea("CVT")
		dbSetOrder(2)  //ordem de conta pai
		dbSeek(xFilial("CVT")+M->CVT_CTAPAI)
		While CVT->( !Eof() .And. CVT_CTAPAI == M->CVT_CTAPAI )
			If CVT->CVT_CODIDT != M->CVT_CODIDT
				lRet := .F.
				Exit
			EndIf
			CVT->( dbSkip() )
		EndDo
		dbSetOrder(1) //volta para ordem 1 - Ident + Conta Pai + Subconta
		
		If !lRet
			Help( ,, 'Help',, STR0013, 1, 0 )  //"Codigo de identificação deve sempre apontar para mesma conta pai."
		Endif
	
	EndIf
	
	//Verificar se codigo de identificacao sempre aponta para mesma conta pai
	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		
		nRecCVT := CVT->( Recno() )
		dbSelectArea("CVT")
		dbSetOrder(2)  //ordem de conta pai
		dbSeek(xFilial("CVT")+M->CVT_CTAPAI)
		While CVT->( !Eof() .And. CVT_CTAPAI == M->CVT_CTAPAI )
			//despreza o proprio recno a ser alterado para validacao
			If CVT->( Recno() ) == nRecCVT
				CVT->( dbSkip() )
				Loop
			EndIf
			If CVT->CVT_CODIDT != M->CVT_CODIDT
				lRet := .F.
				Exit
			EndIf
			CVT->( dbSkip() )
		EndDo
		dbSetOrder(1) //volta para ordem 1 - Ident + Conta Pai + Subconta
		dbGoto(nRecCVT)
		
		If !lRet
			Help( ,, 'Help',, STR0013, 1, 0 )  //"Codigo de identificação deve sempre apontar para mesma conta pai."
		Endif
		
	EndIf
		
	//Natureza da subconta correlata tem que estar na tabela SQ (SX5)
	If lRet
		lRet := ExistCpo("SX5","SQ"+M->CVT_NATSUB)
	EndIf

	//REGRA ECD --> 	REGRA_NAT_090_UNICA_POR_CONTA: Verifica se existe NO MAXIMO DUAS subcontas de 
	//														natureza 90 ou 91 ou 92 ou 93 ou 95 (I053.NAT_SUB_CNT) 
	//														para cada conta (I050.COD_CTA). 
	//               Se a regra não for cumprida, o PVA do Sped Contábil gera um erro.
	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_INSERT
		nCountCVT := 0
		dbSelectArea("CVT")
		dbSetOrder(2)  //ordem de conta pai
		dbSeek(xFilial("CVT")+M->CVT_CTAPAI)
		While CVT->( !Eof() .And. CVT_CTAPAI == M->CVT_CTAPAI )
			If M->CVT_NATSUB $ "90/91/92/93/95" .And. CVT->CVT_NATSUB $ "90/91/92/93/95" 
				nCountCVT++
				If nCountCVT > 2
					lRet := .F.
					Exit
				EndIf
			EndIf
			CVT->( dbSkip() )
		EndDo
		dbSetOrder(1) //volta para ordem 1 - Ident + Conta Pai + Subconta

		If !lRet
			Help( ,, 'Help',, STR0014, 1, 0 )  //"Apenas duas subcontas correlatas podem ter natureza com codigo 90/91/92/93/95."
		Endif

	EndIf


	If lRet .And. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		nCountCVT := 0
		nRecCVT := CVT->( Recno() )
		dbSelectArea("CVT")
		dbSetOrder(2)  //ordem de conta pai
		dbSeek(xFilial("CVT")+M->CVT_CTAPAI)
		While CVT->( !Eof() .And. CVT_CTAPAI == M->CVT_CTAPAI )
			//despreza o proprio recno a ser alterado para validacao
			If CVT->( Recno() ) == nRecCVT
				CVT->( dbSkip() )
				Loop
			EndIf
	
			If M->CVT_NATSUB $ "90/91/92/93/95" .And. CVT->CVT_NATSUB $ "90/91/92/93/95" 
				nCountCVT++
				If nCountCVT > 2
					lRet := .F.
					Exit
				EndIf
			EndIf
			CVT->( dbSkip() )
		EndDo
		dbSetOrder(1) //volta para ordem 1 - Ident + Conta Pai + Subconta
		dbGoto(nRecCVT)
		
		If !lRet
			Help( ,, 'Help',, STR0014, 1, 0 )  //"Apenas duas subcontas correlatas podem ter natureza com codigo 90/91/92/93/95."
		Endif

	EndIf

Else

	lRet := .T.

Endif

Return(lRet)
