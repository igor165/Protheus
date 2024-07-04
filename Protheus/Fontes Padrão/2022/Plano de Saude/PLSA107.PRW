#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "PLSA107.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA107
Rotina de cadastro Associacao x Classe

@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Function PLSA107()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B56' )
oBrowse:SetDescription( STR0002 ) //'Associação x Classe'
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Monta o menu

@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0003  Action 'PesqBrw'          OPERATION 1 ACCESS 0 //'Pesquisar'
ADD OPTION aRotina Title STR0004  Action 'VIEWDEF.PLSA107' 	OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0005  Action 'VIEWDEF.PLSA107' 	OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0006  Action 'VIEWDEF.PLSA107' 	OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0007  Action 'VIEWDEF.PLSA107' 	OPERATION 5 ACCESS 0 //'Excluir'
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Define o model

@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruB56 := FWFormStruct( 1, 'B56', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruB57 := FWFormStruct( 1, 'B57', /*bAvalCampo*/, /*lViewUsado*/ )
Local oStruB85 := FWFormStruct( 1, 'B85', /*bAvalCampo*/, /*lViewUsado*/ )

Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA107MD',/*bPreValidacao*/,Nil,/*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B56MASTER', /*cOwner*/, oStruB56 )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'B57DETAIL', 'B56MASTER', oStruB57, ,{ |oStruB57| PlsVldDfe("B57",.T.,'B57DETAIL',Nil) }, /*bPreVal*/,/*bPreVal*/, /*BLoad*/ )
oModel:AddGrid( 'B85DETAIL', 'B56MASTER', oStruB85, ,/*bLinhaOk*/, /*bPreVal*/,/*bPreVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B57DETAIL', { 	{ 'B57_FILIAL', 'xFilial( "B57" )' },{ 'B57_CODASS', 'B56_CODASS' },;
									{ 'B57_CLASSE', 'B56_CLASSE' } }, "B57_FILIAL+B57_CODASS+B57_CLASSE" )
									
oModel:SetRelation( 'B85DETAIL', { 	{ 'B85_FILIAL', 'xFilial( "B85" )' },{ 'B85_CODASS', 'B56_CODASS' },;
									{ 'B85_CLASSE', 'B56_CLASSE' } }, "B85_FILIAL+B85_CODASS+B85_CLASSE" )                                                   

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'B57DETAIL' ):SetOptional(.T.)
oModel:GetModel( 'B85DETAIL' ):SetOptional(.T.)

// Liga o controle de nao repeticao de linha
oModel:GetModel( 'B57DETAIL' ):SetUniqueLine( {'B57_SEQUEN'} )
oModel:GetModel( 'B85DETAIL' ):SetUniqueLine( {'B85_SEQUEN'} )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( STR0002 )//'Associação x Classe'

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B56MASTER' ):SetDescription( STR0002 ) //'Associação x Classe'
oModel:GetModel( 'B57DETAIL' ):SetDescription( STR0008 ) //'Desc Faixa - Classe x Assoc.' 
oModel:GetModel( 'B85DETAIL' ):SetDescription( 'Tabela de Preço' )  

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define a view

@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oStruB56 := FWFormStruct( 2, 'B56' )
Local oStruB57 := FWFormStruct( 2, 'B57' )
Local oStruB85 := FWFormStruct( 2, 'B85' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSA107' )
Local oView

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B56', oStruB56, 'B56MASTER' )

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B57', oStruB57, 'B57DETAIL' )
oView:AddGrid(  'VIEW_B85', oStruB85, 'B85DETAIL' )

oView:CreateHorizontalBox( 'SUPERIOR', 30 )
oView:CreateHorizontalBox( 'INFERIOR', 70 )

oView:CreateFolder("FOLDER_01",'INFERIOR')
oView:AddSheet("FOLDER_01", "ABA_01_01", "Desc Faixa - Classe x Assoc." )
oView:AddSheet("FOLDER_01", "ABA_01_02", "Tabela de Preço" ) 

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( "FORMDES"  , 100 ,,,"FOLDER_01","ABA_01_01")
oView:CreateHorizontalBox( "FORMTAB"  , 100 ,,,"FOLDER_01","ABA_01_02")

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B56', 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_B57', 'FORMDES' )
oView:SetOwnerView( 'VIEW_B85', 'FORMTAB' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_B57', 'B57_SEQUEN' )
oView:AddIncrementField( 'VIEW_B85', 'B85_SEQUEN' )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_B57','Desc Faixa - Classe x Assoc.') 

// Forcar o fechamento da tela ao salvar o model
oView:SetCloseOnOk({|| .T.})

Return oView    

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsVldDfe
Valida os acols diversos das rotinas de desconto por faixa de procedimento

@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Function PlsVldDfe(cAlias,lMVC,cModel,oObj)

Local nFor		:= 0
Local lRet 		:= .T.  
LOCAL oModel	:= Nil
LOCAL oStru		:= Nil
LOCAL nLine		:= 0
LOCAL cCodPadLi	:= ""
LOCAL cProIni 	:= ""
LOCAL cProIniLi := ""
LOCAL cProFim 	:= ""
LOCAL cProFimLi := ""
LOCAL dDataIni	:= CtoD("")
LOCAL dDataIniLi:= CtoD("")
LOCAL dDataFim	:= CtoD("")
LOCAL dDataFimLi:= CtoD("")

Default	cAlias	:= ""
Default	cAlias	:= ""
Default	lMVC	:= .F.
Default oObj	:= Nil
 
If lMVC
   
	// Obtem os dados do model
	oModel 	:= FWModelActive()
	oStru 	:= oModel:GetModel(cModel)
	nLine 	:= oStru:GetLine()
	
	// Recupero as informacoes da linha atual
	cProIni		:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0,FwFldGet( cAlias+'_CODINT',nLine),"")
	cProIni 	+= FwFldGet( cAlias+'_CODPAD',nLine)+FwFldGet( cAlias+'_PROINI',nLine)
	cProFim		:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0,FwFldGet( cAlias+'_CODINT',nLine),"")
	cProFim 	+= FwFldGet( cAlias+'_CODPAD',nLine)+FwFldGet( cAlias+'_PROFIM',nLine)
	dDataIni	:= FwFldGet( cAlias+'_DTFDPI',nLine)
	dDataFim	:= FwFldGet( cAlias+'_DTFDPF',nLine)
	
	For nFor := 1 To oStru:GetQtdLine() 
	
		// Valida primeira insercao de dados e linha atual
		If oStru:GetQtdLine() > 1 .And. nFor != nLine
			
			oStru:GoLine( nFor )
			
			// Valida deletados.
			If !oStru:IsDeleted() 
				// Recupero as informacoes das outras linhas
				cProIniLi	:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0,FwFldGet( cAlias+'_CODINT',nFor),"")
				cProIniLi 	+= FwFldGet( cAlias+'_CODPAD',nFor)+FwFldGet( cAlias+'_PROINI',nFor)
				cProFimLi	:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0,FwFldGet( cAlias+'_CODINT',nFor),"")
				cProFimLi 	+= FwFldGet( cAlias+'_CODPAD',nFor)+FwFldGet( cAlias+'_PROFIM',nFor)
				dDataIniLi	:= FwFldGet( cAlias+'_DTFDPI',nFor)
				dDataFimLi	:= FwFldGet( cAlias+'_DTFDPF',nFor)
																		
		 		// Data inicial no intervalo de uma data anterior nao deixa passar
	   			If dDataIni >= dDataIniLi .And.; 
		   			( dDataIni <= dDataFimLi .Or.; 
		   				Empty(dDataFimLi) ) //.Or. Empty(dDataFimLi)
			   		// Valida o intevalo de procedimentos
			   		If ( 	cProIniLi >= cProIni .And.; 
			   				cProIniLi <= cProFim) .Or.;
			   			( 	cProFimLi >= cProIni .And.; 
			   				cProFimLi <= cProFim 	)		   			
			   			Help( ,, 'HELP',, STR0001, 1, 0)//"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo da mesma vigência. Verifique os eventos das faixas!"
						lRet := .F.
						exit 
					EndIf
				EndIf
		  		// Data final no intervalo de uma data anterior nao deixa passar
		   		If (dDataFim >= dDataIniLi .Or. Empty(dDataFim)).And.; 
			   	   ( ( !Empty(dDataFimLi) .And. !Empty(dDataFim) .And. dDataFim <= dDataFimLi );
			   	   .Or. ( Empty(dDataFim) .And. Empty(dDataFimLi) ) )
		   			// Valida o intevalo de procedimentos
			   		If 	( 	cProIniLi >= cProIni .And.; 
			   				cProIniLi <= cProFim 	) .Or.;
			   			( 	cProFimLi >= cProIni .And.; 
			   				cProFimLi <= cProFim 	)		   			
			   			Help( ,, 'HELP',, STR0001, 1, 0) //"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo da mesma vigência. Verifique os eventos das faixas!"
						lRet := .F.
						exit 
					EndIf
				EndIf
			EndIf
		EndIf
	Next
Else
	// Recupero as informacoes da linha atual
	cProIni	:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0 .And. TYPE("M->"+cAlias+'_CODINT')<>'U',&("M->"+cAlias+'_CODINT'),"")
   	cProFim	+= Iif(TYPE("M->"+cAlias+'_CODPAD')<>'U' .And. TYPE("M->"+cAlias+'_PROINI')<>'U',&("M->"+cAlias+'_CODPAD')+&("M->"+cAlias+'_PROINI'),"")
	cProFim 	:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0 .And. TYPE("M->"+cAlias+'_CODINT')<>'U',&("M->"+cAlias+'_CODINT'),"")
	cProFim	+= Iif(TYPE("M->"+cAlias+'_CODPAD')<>'U' .And. TYPE("M->"+cAlias+'_PROFIM')<>'U',&("M->"+cAlias+'_CODPAD')+&("M->"+cAlias+'_PROFIM'),"")
	dDataIni  	:= Iif((cAlias)->(FieldPos(cAlias+'_DTFDPI')) > 0 .And. TYPE("M->"+cAlias+'_DTFDPI')<>'U',&("M->"+cAlias+'_DTFDPI'),"")
	dDataFim	:= Iif((cAlias)->(FieldPos(cAlias+'_DTFDPF')) > 0 .And. TYPE("M->"+cAlias+'_DTFDPF')<>'U',&("M->"+cAlias+'_DTFDPF'),"")	
	
	For nFor := 1 To Len(oObj:aCols) 
		// Valida deletados e primeira insercao de dados.
		If !oObj:IsDeleted(nFor) .And. nFor != n	.And. Iif(	Len(oObj:aCols) == 1,;
												   				!Empty(oObj:FieldGet(cAlias+"_DTFDPI", nFor)),;
																.T.)
																	
	 		// Recupero as informacoes das outras linhas
	 		cProIniLi	:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0 .And. ValType("M->"+cAlias+'_CODINT')<>'U',oObj:FieldGet(cAlias+'_CODINT', nFor),"")
 			cProIniLi 	+= oObj:FieldGet(cAlias+'_CODPAD', nFor)+oObj:FieldGet(cAlias+"_PROINI", nFor)
 			cProFimLi	:= Iif((cAlias)->(FieldPos(cAlias+'_CODINT')) > 0 .And. ValType("M->"+cAlias+'_CODINT')<>'U',oObj:FieldGet(cAlias+'_CODINT', nFor),"") 			
			cProFimLi 	+= oObj:FieldGet(cAlias+'_CODPAD', nFor)+oObj:FieldGet(cAlias+'_PROFIM', nFor)
			dDataIniLi	:= oObj:FieldGet(cAlias+'_DTFDPI', nFor)
			dDataFimLi	:= oObj:FieldGet(cAlias+'_DTFDPF', nFor)
																	
	 		// Data inicial no intervalo de uma data anterior nao deixa passar
	   		If dDataIni >= dDataIniLi .And.; 
		   		(	dDataIni <= dDataFimLi .Or.; 
		   			Empty(dDataFimLi) ) //.Or. Empty(dDataFimLi)
		   		// Valida o intevalo de procedimentos
		   		If ( 	cProIniLi >= cProIni .And.; 
		   				cProIniLi <= cProFim) .Or.;
		   			( 	cProFimLi >= cProIni .And.; 
		   				cProFimLi <= cProFim 	)		   			
		   			Help( ,, 'HELP',, STR0001, 1, 0)//"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo da mesma vigência. Verifique os eventos das faixas!"
					lRet := .F.
					exit 
				EndIf
			EndIf
	  		// Data final no intervalo de uma data anterior nao deixa passar
	   		If (dDataFim >= dDataIniLi .Or. Empty(dDataFim)).And.; 
		   	   ( ( !Empty(dDataFimLi) .And. !Empty(dDataFim) .And. dDataFim <= dDataFimLi );
		   	   .Or. ( Empty(dDataFim) .And. Empty(dDataFimLi) ) )
	   			// Valida o intevalo de procedimentos
		   		If 	( 	cProIniLi >= cProIni .And.; 
		   				cProIniLi <= cProFim 	) .Or.;
		   			( 	cProFimLi >= cProIni .And.; 
		   				cProFimLi <= cProFim 	)		   			
		   			Help( ,, 'HELP',, STR0001, 1, 0) //"Já existe outra faixa com pelo menos um evento apresentado nessa faixa, que pode estar em qualquer intervalo da mesma vigência. Verifique os eventos das faixas!"
					lRet := .F.
					exit 
				EndIf
			EndIf 
		EndIf
	Next
EndIf
		
Return( lRet ) 


//-------------------------------------------------------------------
/*/{Protheus.doc} FVBPSPLS
Realiza diversas validacoes de campo e consulta, no padrao MVC

@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Function FVBPSPLS(cCodPad,cCodPro,cAlias)

Local lRet 	  := .T. 
LOCAl cAlias    := Substr(ReadVar(),4,3)
Default cCodPad := ""
Default cCodPro := ""
  
If Empty(GetNewPar("MV_PLSTBPD","")) .And. Empty(cCodPad)
	BR8->(DbSetOrder(3))
	lRet := BR8->(MsSeek(xFilial("BR8")+cCodPro ))
	If lRet 
		If ReadVar() == "M->"+cAlias+"_PROFIM" .And. ;
			&("M->"+cAlias+"_PROFIM") < &("M->"+cAlias+"_PROINI")
			lRet:=.F.
			Help( ,, 'HELP',,"Procedimento final tem que ser maior ou igual ao procedimento inicial!", 1, 0)
			Return lRet
		Endif
		If &( cAlias+"->( FieldPos('"+cAlias+"_CODPAD') )" ) > 0  
			&("M->"+cAlias+"_CODPAD") := BR8->BR8_CODPAD
		EndIf
	Endif 
Else
	BR8->(DbSetOrder(1))
	lRet := BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodPro ))
	If lRet .And. ReadVar() == "M->"+cAlias+"_PROFIM" .And. ;
		&("M->"+cAlias+"_PROFIM") < &("M->"+cAlias+"_PROINI")
		lRet:=.F.
		Help( ,, 'HELP',,"Procedimento final tem que ser maior ou igual ao procedimento inicial!", 1, 0)
		Return lRet
	Endif
EndIf

IF !lRet
	Help( ,, 'HELP',,"Procedimento não encontrado!", 1, 0)
Endif 

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} FVBPSPLS
Realiza diversas validacoes de campo e consulta, no padrao MVC

@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Function FVB56PLS(nTipo)
LOCAL lRet      := .T.
LOCAL oModel    := FWModelActive()  
LOCAL oStru 	:= oModel:GetModel( 'B56MASTER' )

Do case
	Case nTipo == 1  
   		B56->(DbSetOrder(1))
   		If B56->(MsSeek(xFilial("B56")+FwFldGet('B56_CODASS')+FwFldGet('B56_CLASSE')))  
   			Help( ,, 'HELP',, "Esta Classe ja esta amarrada a esta associacao!", 1, 0)
			lRet := .F.
	   Endif					
EndCase

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetFxDes

Retona o valor de desconto de acordo com os niveis:
B61 - Produto / Rede Referenciada (RDA)
B60 - Produto x Desc Faixa Pagto
B58 - RDA X Local Atend                                              
B75 - Desc Faixa X RDA (Prestador)
B57 - Associacao x Classe x Desc Faixa
                                      
@author Diogo Ximenes
@since 01/01/11
@version P11
/*/
Function RetFxDes(	cCodInt, cCodRda, 	cCodTab, 	cCodPla,; 
					cCodPad, cCodPro,	nValor,		cCodUnd,;
					cCodLoc, dDatPro)

Local nValRet 		:= 0
Local cTabela		:= "" 
Local lAchou       	:= .F.
Local lAssoc        := .F.
Local cClasse		:= ""
Local nPerc         := 0

Default cCodint		:= ""
Default cCodRda		:= ""
Default cCodTab		:= ""
Default cCodPla		:= ""
Default cCodPad		:= ""
Default cCodPro		:= ""
Default nValor		:= 0
Default cCodUnd		:= ""
Default cCodLoc		:= ""
Default dDatPro		:= stod("")

//³ Produto / Rede Referenciada (RDA)
If !lAchou 

	BT4->(DbSetOrder(1)) // BT4_FILIAL, BT4_CODIGO, BT4_VERSAO, BT4_CODCRE
	If BT4->(MsSeek(xFilial("BT4")+cCodInt+cCodPla+"001"+cCodRda)) .And. BT4->BT4_PERM <> '1'

		B61->(DbSetOrder(1)) // B61_FILIAL, B61_CODINT, B61_CODPLA, B61_VERSAO, B61_CODRDA

		If B61->(MsSeek(xFilial("B61")+cCodInt+cCodPla+"001"+cCodRda))

			While !B61->(EoF()) .And. xFilial("B61")+cCodInt+cCodPla+"001"+cCodRda == B61->(B61_FILIAL+B61_CODINT+B61_CODPLA+B61_VERSAO+B61_CODRDA)

				//³ Verifico se está dentro da faixa
				If 	cCodPad+cCodPro >= B61->B61_CODPAD+B61->B61_PROINI .And. cCodPad+cCodPro <= B61->B61_CODPAD+B61->B61_PROFIM .And. stod(dDatPro) >= B61->B61_DTFDPI .And. (stod(dDatPro) <= B61->B61_DTFDPF .Or. Empty(B61->B61_DTFDPF))
				   	nPerc   := B61->B61_PERDES
				   	nValRet := round( (B61->B61_PERDES * nValor) / 100, 2) 
				   	cTabela	:= "B61"
					lAchou 	:= .T.
				   	Exit
				EndIf
			B61->(DbSkip())
	   		EndDo
	   		
		EndIf
		
	Endif
	
EndIf

//³ Produto 
If !lAchou

	B60->(DbSetOrder(1)) // B60_FILIAL+B60_CODINT+B60_CODPLA+B60_VERSAO

	If B60->(MsSeek(xFilial("B60")+cCodInt+cCodPla))

		While !B60->(EoF()) .And. xFilial("B60")+cCodInt+cCodPla == B60->(B60_FILIAL+B60_CODINT+B60_CODPLA)

			//³ Verifico se está dentro da faixa
			If 	cCodPad+cCodPro >= B60->B60_CODPAD+B60->B60_PROINI .And. cCodPad+cCodPro <= B60->B60_CODPAD+B60->B60_PROFIM .And. stod(dDatPro) >= B60->B60_DTFDPI .And. (stod(dDatPro) <= B60->B60_DTFDPF .Or. Empty(B60->B60_DTFDPF))
			   	
			   	nPerc   := B60->B60_PERDES
				nValRet := round( (B60->B60_PERDES * nValor) / 100, 2) 
			   	cTabela	:= "B60"
				lAchou 	:= .T.
			   	Exit
			
			EndIf
		B60->(DbSkip())
		EndDo
		
	EndIf
	
EndIf

//³ RDA X Local Atend
If !lAchou
	
	B58->(DbSetOrder(1)) // B58_FILIAL+B58_CODIGO+B58_CODINT+B58_CODLOC
	If B58->(MsSeek(xFilial("B58")+cCodRda+cCodint+cCodLoc))
	
		While 	!B58->(EoF()) .And. xFilial("B58")+cCodRda+cCodint+cCodLoc == B58->(B58_FILIAL+B58_CODIGO+B58_CODINT+B58_CODLOC)

			//³ Verifico se está dentro da faixa
			If 	cCodPad+cCodPro >= B58->B58_CODPAD+B58->B58_PROINI .And. cCodPad+cCodPro <= B58->B58_CODPAD+B58->B58_PROFIM .And. stod(dDatPro) >= B58->B58_DTFDPI .And. (stod(dDatPro) <= B58->B58_DTFDPF .Or. Empty(B58->B58_DTFDPF))
			
			   	nPerc   := B58->B58_PERDES
			   	nValRet := round( (B58->B58_PERDES * nValor) / 100, 2)
			   	cTabela	:= "B58"
				lAchou 	:= .T.
			   	Exit
		   
			EndIf
			
		B58->(DbSkip())
		EndDo
	EndIf
EndIf

//Desc Faixa X RDA (Prestador)
If !lAchou

	B75->(DbSetOrder(1)) // B75_FILIAL, B75_CODIGO, B75_CODINT, B75_CODPAD, B75_PROINI, B75_PROFIM, B75_PERDES, B75_DTFDPI
	If B75->(MsSeek(xFilial("B75")+cCodRda+cCodint+cCodPad))
		
		While !B75->(EoF()) .And. xFilial("B75")+cCodRda+cCodint+cCodPad == B75->(B75_FILIAL+B75_CODIGO+B75_CODINT+B75_CODPAD)

			//Verifico se está dentro da faixa
			If 	cCodPad+cCodPro >= B75->B75_CODPAD+B75->B75_PROINI .And. cCodPad+cCodPro <= B75->B75_CODPAD+B75->B75_PROFIM .And. stod(dDatPro) >= B75->B75_DTFDPI .And. (stod(dDatPro) <= B75->B75_DTFDPF .Or. Empty(B75->B75_DTFDPF))
			
			   	nPerc   := B75->B75_PERDES
			   	nValRet := round( (B75->B75_PERDES * nValor) / 100, 2)
			   	cTabela	:= "B75"
				lAchou 	:= .T.
			   	Exit
		   
			EndIf
		B75->(DbSkip())
		EndDo
		
	EndIf
	
EndIf

//³ Associação x Classe
If !lAchou
	
	B62->(DbSetOrder(1)) // B62_FILIAL, B62_CODIGO, B62_CODINT, B62_SEQUEN, R_E_C_D_E_L_
	
	If B62->(MsSeek(xFilial("B62")+cCodRda+cCodInt))
	
		While !B62->(EoF()) .And. xFilial("B62")+cCodRda+cCodInt == B62->(B62_FILIAL+B62_CODIGO+B62_CODINT)
		
			If stod(dDatPro) >= B62->B62_DTVGIN .And. (stod(dDatPro) <= B62->B62_DTVGF .Or. Empty(B62->B62_DTVGF))
				lAssoc := .T.
				cClasse:= B62->B62_ASSCLA
				Exit
			Endif
			
		B62->(dbSkip())
		EndDo
		
		If lAssoc
		
			B57->(DbSetOrder(1)) // B57_FILIAL+B57_CODASS+B57_CLASSE+B57_CODINT+B57_SEQUEN
			If B57->(MsSeek(xFilial("B57")+cClasse+cCodInt))
		
				While !B57->(EoF()) .And. xFilial("B57")+cClasse+cCodInt == B57->(B57_FILIAL+B57_CODASS+B57_CLASSE+B57_CODINT)

					//Verifico se está dentro da faixa
					If 	cCodPad+cCodPro >= B57->B57_CODPAD+B57->B57_PROINI .And. cCodPad+cCodPro <= B57->B57_CODPAD+B57->B57_PROFIM .And. stod(dDatPro) >= B57->B57_DTFDPI .And. (stod(dDatPro) <= B57->B57_DTFDPF .Or. Empty(B57->B57_DTFDPF))
					
					   	nPerc   := B57->B57_PERDES
					   	nValRet := round( (B57->B57_PERDES * nValor) / 100, 2)
					   	cTabela	:= "B57"
						lAchou 	:= .T.
					   	Exit
					
					EndIf
				B57->(DbSkip())
				EndDo
				
			EndIf
			 
		Endif
		
	EndIf
	
EndIf

Return({nValRet,cTabela,nPerc})

Function PLSCPCLEAR()
Local lRet     := .T.
Local cReadVar := ReadVar()
Local cAlias   := Substr(cReadVar,4,3)
LOCAL aArea    := GetArea()

If cReadVar == "M->"+cAlias+"_CODPAD" 
		oModel     := FWModelActive()
		oModelDet  := oModel:GetModel(cAlias+"DETAIL")
		nLine  	   := oModelDet:GetLine()
		aSaveLines := FWSaveRows()
				
		FWFldPut(cAlias+"_PROINI","",nLine,oModel,.F.,.T.)
		FWFldPut(cAlias+"_PROFIM","",nLine,oModel,.F.,.T.)
		
		FWRestRows( aSaveLines )
Endif

RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ValDtBC5    ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida data na digitacao da tabela de preco				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PlsLineB85(oGrid)
Local lRet		:= .T.
Local nOperation:= oGrid:GetOperation()
Local aArea 	:= GetArea()
Local aAcolsAx	:= aClone(oGrid:aCols)
Local nLines 	:= oGrid:GetQtdLine()
Local nPosDtIni := GdFieldPos("B85_VIGINI",oGrid:aHeader)
Local nPosDtFim := GdFieldPos("B85_VIGFIN",oGrid:aHeader)
Local nX
Local aMat 		:= {}
Local nPos		:= 0

If nOperation == 3 .OR. nOperation == 4 
                                              	
	// Essas são as datas da linha atual.
	dDtIni := oGrid:GetValue("B85_VIGINI",oGrid:nLine)
	dDtFim := oGrid:GetValue("B85_VIGFIN",oGrid:nLine)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se data inicio for maior que final nao permite									 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If dDtIni > dDtFim .And. ! Empty(dDtFim)
		Help("",1,"PLSANAFAI2")	// NAO OK
		lRet := .F.
	Endif
	
	If lRet
		For nX := 1 To nLines
			// Desconsidera a propria linha.
			If nX == oGrid:nLine
				Loop
			Endif

			// Compara a chave completa.
			If 	!(oGrid:GetValue("B85_TABPRE",oGrid:nLine) == oGrid:GetValue("B85_TABPRE",nX) )
			    
			    Loop
			Endif
			
		 
		 	// Atualiza a linha do grid para futuras verificações
			If (!Empty(oGrid:GetValue("B85_VIGINI", nX)) .OR. !Empty(oGrid:GetValue("B85_VIGFIN", nX))) .and. !oGrid:IsDeleted(nX)
				AaDd( aMat,{ aAcolsAx[nX][nPosDtIni],aAcolsAx[nX][nPosDtFim] } )
			Endif
		Next	

		If Len(aMat) > 0 
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se ja cadastrado												 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos := AsCan(aMat,{ |x| Empty(x[2])} )
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se tem vigencia com data final em aberta verifica se a data final e menor que a inicial³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nPos > 0
				If Empty(dDtFim)
					Help(" ",1,'PLSA112A')	// OK
					lRet := .F.
				EndIf
				
				If lRet .and. dDtFim >= aMat[nPos,1]
					Help(" ",1,'PLSA112B')	// NAO OK
					lRet := .F.
				EndIf
			
				nPos := AsCan(aMat,{ |x| dDtIni >= x[1] .And. dDtIni <= x[2] .Or. dDtIni < x[1] .And. dDtFim > x[1] } )
				If lRet .and. nPos > 0
					Help(" ",1,'PLSA112C')	// NAO OK
					lRet := .F.
				EndIf
			
				nPos := AsCan(aMat,{ |x| dDtIni >= x[1] .And. dDtFim <= x[2]  } )
				If lRet .and. nPos > 0
					Help(" ",1,'PLSA112C')	// NAO OK
					lRet := .F.
				EndIf
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se e valido o intervalo																   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPos := AsCan(aMat,{ |x| dDtIni <= x[2]  } )
				If lRet .and. nPos > 0
					Help(" ",1,'PLSA112D')	// OK
					lRet := .F.
				EndIf
			EndIf
		Endif		
	Endif
Endif

// Restaura area.
RestArea(aArea)
Return(lRet)
