#include "CRMA600.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWEVENTVIEWCONSTS.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA600 

Rotina que faz a chamada para o cadastro de Papéis de Usuários Perfil 360

@sample		CRMA600()

@param 		oModel - Model da rotina

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CRMA600( nOpcAuto)

Local oBrowse 		:= Nil

Private lMsErroAuto := .F.

oBrowse := FWMBrowse():New()
oBrowse:SetCanSaveArea(.T.)
oBrowse:SetAlias('AOP')
oBrowse:SetDescription( STR0001 )// "Controle de Entidades"//"Papeis de Usuarios do Perfil 360"
oBrowse:Activate()

Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef 

Funcao de chamada do menu.

@sample		ModelDef()

@param 		oModel - Model da rotina

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStruAOP   := FWFormStruct( 1, 'AOP')
Local oStruAOQ   := FWFormStruct( 1, 'AOQ')
Local oStruAOR   := FWFormStruct( 1, 'AOR')
Local oStruAOS_G := FWFormStruct( 1, 'AOS')
Local oStruAOS_U := FWFormStruct( 1, 'AOS')
Local aSaveLines := FWSaveRows()
Local oModel     := Nil

oModel := MPFormModel():New('CRMA600',,{|oModel| CA600TOK(oModel)} )
oModel:AddFields( 'AOPMASTER',,oStruAOP)
oModel:GetModel( 'AOPMASTER' ):SetDescription( STR0002 ) //'Papeis do Usuário Perfil 360'

oModel:AddGrid( 'AOQDETAIL', 'AOPMASTER', oStruAOQ)

oModel:SetRelation( 'AOQDETAIL', { { 'AOQ_FILIAL', 'xFilial( "AOQ" )' }, { 'AOQ_CODPAP', 'AOP_CODIGO' } }, AOQ->( IndexKey( 1 ) ) )

oModel:GetModel("AOQDETAIL"):SetUniqueLine({"AOQ_CODPAP","AOQ_CODIGO"})
oModel:GetModel( 'AOQDETAIL' ):SetDescription( STR0003 )//'Contexto'

oModel:AddGrid( 'AORDETAIL', 'AOQDETAIL', oStruAOR)
oModel:GetModel("AORDETAIL"):SetUniqueLine({"AOR_CODNIV","AOR_CODROT"})
oModel:GetModel( 'AORDETAIL' ):SetDescription( STR0004  )//'Rotinas'

oModel:GetModel("AORDETAIL"):SetOptional( .T. )

oModel:AddGrid( 'AOSDETAIL_G', 'AOPMASTER', oStruAOS_G)
oModel:SetRelation( 'AOSDETAIL_G', { { 'AOS_FILIAL', 'xFilial( "AOS" )' }, { 'AOS_CODPAP', 'AOP_CODIGO' } , { 'AOS_TIPO', "'1'" } }, AOS->( IndexKey( 1 ) ) )

oModel:AddGrid( 'AOSDETAIL_U', 'AOPMASTER', oStruAOS_U)
oModel:SetRelation( 'AOSDETAIL_U', { { 'AOS_FILIAL', 'xFilial( "AOS" )' }, { 'AOS_CODPAP', 'AOP_CODIGO' } , { 'AOS_TIPO', "'2'" }}, AOS->( IndexKey( 1 ) ) )

oModel:SetDescription( STR0005 )//'Papeis do Usuário Perfil 360'

oModel:SetRelation( 'AORDETAIL', { { 'AOR_FILIAL', 'xFilial( "AOR" )' }, { 'AOR_CODPAP', 'AOP_CODIGO' }, { 'AOR_CODNIV', 'AOQ_CODIGO' } }, AOR->( IndexKey( 1 ) ))

oModel:GetModel('AORDETAIL'):SetUniqueLine({"AOR_CODPAP","AOR_CODNIV","AOR_CODROT"})

oModel:GetModel('AOSDETAIL_G'):SetUniqueLine({"AOS_CODPAP","AOS_CODIGO","AOS_TIPO"})
oModel:GetModel('AOSDETAIL_U'):SetUniqueLine({"AOS_CODPAP","AOS_CODIGO","AOS_TIPO"})
oStruAOR:SetProperty("AOR_CODROT",MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"ExistCpo('AOO',FwFldGet('AOR_CODROT'),1)"))

oModel:GetModel("AOSDETAIL_U"):SetOptional( .T. )
oModel:GetModel("AOSDETAIL_G"):SetOptional( .T. )

oStruAOS_G:SetProperty('AOS_TIPO' , MODEL_FIELD_INIT, {||"1"})
oStruAOS_U:SetProperty('AOS_TIPO' , MODEL_FIELD_INIT, {||"2"})  

oModel:GetModel('AOSDETAIL_G'):SetLoadFilter({{'AOS_TIPO',"'1'",MVC_LOADFILTER_EQUAL}})
oModel:GetModel('AOSDETAIL_U'):SetLoadFilter({{'AOS_TIPO',"'2'",MVC_LOADFILTER_EQUAL}})

oStruAOS_G:SetProperty("AOS_CODIGO" ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"CA600ExGrp(FwFldGet('AOS_CODIGO'),'1')"))
oStruAOS_U:SetProperty("AOS_CODIGO" ,MODEL_FIELD_VALID,FwBuildFeature(STRUCT_FEATURE_VALID,"CA600ExGrp(FwFldGet('AOS_CODIGO'),'2')"))

oStruAOS_G:SetProperty("AOS_DESCRI" ,MODEL_FIELD_INIT,{|| CRM600INIT("1") })
oStruAOS_U:SetProperty("AOS_DESCRI" ,MODEL_FIELD_INIT,{|| CRM600INIT("2") })


oModel:SetActivate({|oModel| CA600Activ(oModel)})

Return oModel

//-----------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef 

Interface do Cadastro de Rotinas Perfil 360.

@sample		ViewDef()

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oModel     := FWLoadModel( 'CRMA600' )
Local oStruAOP   := FWFormStruct(2, 'AOP' )
Local oStruAOQ   := FWFormStruct(2, 'AOQ' )
Local oStruAOR   := FWFormStruct(2, 'AOR' )
Local oStruAOS_G := FWFormStruct(2, 'AOS' )
Local oStruAOS_U := FWFormStruct(2, 'AOS' )
Local cCampos    := {}
Local oView 	 := Nil

oStruAOS_G:SetProperty('AOS_CODIGO',MVC_VIEW_LOOKUP,'GRP')
oStruAOS_U:SetProperty('AOS_CODIGO',MVC_VIEW_LOOKUP,'USRPER')

oView  := FWFormView():New()
oView:SetContinuousForm()
oView:SetModel( oModel )
oView:AddField('VIEW_AOP', oStruAOP, 'AOPMASTER' )
oView:AddGrid( 'VIEW_AOQ', oStruAOQ, 'AOQDETAIL' )
oView:AddGrid( 'VIEW_AOR', oStruAOR, 'AORDETAIL' )
oView:AddGrid( 'VIEW_AOS_G', oStruAOS_G, 'AOSDETAIL_G' )
oView:AddGrid( 'VIEW_AOS_U', oStruAOS_U, 'AOSDETAIL_U' )

oView:CreateHorizontalBox( 'SUPERIOR', 15 )
oView:CreateHorizontalBox( 'CENTRO1' , 25 )
oView:CreateHorizontalBox( 'CENTRO2' , 15 )
oView:CreateHorizontalBox( 'INFERIOR', 45 )

oView:SetOwnerView( 'VIEW_AOP' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_AOQ' , 'CENTRO1' )
oView:SetOwnerView( 'VIEW_AOR' , 'CENTRO2' )

oView:CreateFolder( 'PASTAS','INFERIOR' )
oView:AddSheet( 'PASTAS', 'ABA01', STR0006 )//'Grupos'
oView:AddSheet( 'PASTAS', 'ABA02', STR0007 )//'Usuários'

oView:CreateVerticalBox( 'DIREITO', 100,,, 'PASTAS', 'ABA01' )
oView:CreateVerticalBox( 'ESQUERDO', 100,,, 'PASTAS', 'ABA02' )
oView:SetOwnerView( 'VIEW_AOS_G' , 'DIREITO' )
oView:SetOwnerView( 'VIEW_AOS_U' , 'ESQUERDO' )

oStruAOP:SetProperty('AOP_CODIGO', MVC_VIEW_CANCHANGE ,.F.)
oStruAOQ:Removefield('AOQ_CODPAP')
oStruAOR:Removefield('AOR_CODPAP')
oStruAOR:Removefield('AOR_CODNIV')
oStruAOS_G:Removefield('AOS_CODPAP')
oStruAOS_G:Removefield('AOS_TIPO')

oStruAOS_U:Removefield('AOS_CODPAP')
oStruAOS_U:Removefield('AOS_TIPO')
                                                                                                  
oView:AddIncrementField('VIEW_AOQ','AOQ_CODIGO')
oView:AddIncrementField('VIEW_AOR','AOR_CODNIV')

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef 

Funcao de chamada do menu.

@sample		MenuDef()

@return		aRotina - Array com os menus

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/

//------------------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0008 	ACTION "VIEWDEF.CRMA600" OPERATION 3 ACCESS 0		// STR0008 //"Incluir"
ADD OPTION aRotina TITLE STR0009 	ACTION "VIEWDEF.CRMA600" OPERATION 4 ACCESS 0		// STR0009 //"Alterar"
ADD OPTION aRotina TITLE STR0010 	ACTION "VIEWDEF.CRMA600" OPERATION 5 ACCESS 0		// STR0010 //"Excluir"
ADD OPTION aRotina TITLE STR0011    ACTION "VIEWDEF.CRMA600" OPERATION 2 ACCESS 0		// STR0011 //"Visualizar"
ADD OPTION aRotina TITLE STR0042	ACTION "VIEWDEF.CRMA600" OPERATION 9 ACCESS 0		// STR0042 //"Copiar" 

Return( aRotina ) 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600GetUsr 

Retorna Grupo ou Nome do Usuário

@sample		CA600GetUsr()

@return		cNome - Nome do Grupo de Usuários

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CA600GetUsr(cCodigo,cTipo) 

Local cNome := ""
Local oView := FwViewActive()
Local oModel:= FwModelActive()
Local aGrps := {}
Local nPos  := 0 
Local lGrupo := .F.
Local lUser  := .F.

Default cCodigo := ''
Default cTipo   := '2'

If  !(oView==Nil)  
	lGrupo := oView:GetFolderActive("PASTAS", 2)[1] == 1 
Else
	lGrupo := IIF(cTipo == '1',.T.,.F.)
EndIf

If lGrupo// Aba de Lote
	aGrps    := AllGroups()//Grupos
	If (nPos:=ascan(aGrps,{|x| x[1,1] = cCodigo}))>0
		cNome := aGrps[nPos,1,2]
	EndIF
EndIf

If  !(oView==Nil)  
	lUser := oView:GetFolderActive("PASTAS", 2)[1] == 2 
Else
	lUser := IIF(cTipo == '2',.T.,.F.)
EndIf

If lUser
	cNome:= UsrFullName(cCodigo)
EndIf

Return cNome
 
//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600Tracker 

Executa Rastreador de Contas

@sample		CA600Tracker()

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CA600Tracker(  )

Local aArea	   := GetArea()
Local aObjects := {}                        
Local aSize    := MsAdvSize( .F. ) 
Local aObj      	:= {}  

Local nLinIni  := 0 
Local nRight   := 0 

Local oDlg     := Nil
Local oSay     := Nil
Local oMenu    := Nil
Local oPnlFol  := Nil
Local oTree    := Nil
Local CCADASTRO := STR0012//"Rastreador de Contas"
	
AAdd( aObjects, { 100, 100, .t., .t. } )
AAdd( aObjects, {  50, 100, .f., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 4, 4 } 
aObj := MsObjSize( aInfo, aObjects, , .t. ) 

oDlg := FWDialogModal():New()
	oDlg:SetBackground( .F. )  
	oDlg:SetTitle( CCADASTRO )		// "Rastreador de Contas"
	oDlg:SetEscClose( .T. )
	oDlg:EnableAllClient() 
	oDlg:CreateDialog()
	oDlg:EnableFormBar( .T. )
	oDlg:CreateFormBar()

	oDlg:addCloseButton({||oDlg:DeActivate() })

oPnlFol := oDlg:GetPanelMain()

// Cria a Tree    
oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,3], aObj[1,4], oPnlFol, , , .T.)
oTree:lShowHint := .F. 

oTree:bRClicked := { || MaPrepView(oTree) } 
                           
nLinIni := aObj[2,1] 
nRight  := aObj[2,2] + 5

@ aObj[2,1],aObj[2,2] TO aObj[2,3],aObj[2,4] 	

@ nLinIni + 12, nRight BUTTON OemToAnsi(STR0013) SIZE 040,012 ACTION MaPrepView(oTree)	OF oPnlFol PIXEL //STR0013//"Visualizar"
@ nLinIni + 28, nRight BUTTON OemToAnsi(STR0014) SIZE 040,012 ACTION CAC600Pesq(oTree)	OF oPnlFol PIXEL //STR0014//"Pesquisar"

MENU oMenu POPUP 
	MENUITEM STR0015 Action MaPrepView(oTree) //"Visualizar"
	MENUITEM STR0016 Action CAC600Pesq(oTree) //"Buscar"
ENDMENU

oTree:bRClicked   := { |oObject,nx,ny| oMenu:Activate( nX, nY - 145, oObject ) }

          
CA600proc(oTree,oDlg,oSay )

oDlg:Activate() 


RestArea( aArea ) 

Return(Nil)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600proc 

Executa Rastreador de Contas

@sample		CA600proc()

@param 		oTree - Objeto Tree 
@param 		oDlg - Objeto da Janela 
@param 		oSay - Objeto da Janela 

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function CA600proc(oTree,oDlg,oSay)
Processa({||CA600Reca(oTree,oDlg,oSay)})
                                            
Return( .T. ) 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600Reca 

Recalcula os sinalizadores do Tree 

@sample		CA600Reca()

@param 		oTree - Objeto Tree 
@param 		oDlg - Objeto da Janela 
@param 		oSay - Objeto da Janela 

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function CA600Reca(oTree,oDlg,oSay)

LOCAL cQuery     := '' 
LOCAL cAliasQry  := ''
Local cChaveSA1  := ''
LOCAL nLevel     := 0 
Local nSA1Recno  := SA1->(Recno())
Private aTitulos := {}
                                
oTree:BeginUpdate()	
oTree:Reset()      
oTree:EndUpdate()

oTree:BeginUpdate()

SA1->( dbGoto( nSA1Recno ) ) 
   
cAliasQry := GetNextAlias()
	        
cQuery := ""
cQuery += "SELECT ACH.R_E_C_N_O_ ACHRECNO FROM " 	
cQuery += RetSqlName("ACH") + " ACH, "
cQuery += RetSqlName("SUS") + " SUS "          
cQuery += "WHERE "                           
cQuery += " ACH.ACH_FILIAL = '"+ xFilial( "ACH" ) + "' AND "
cQuery += " SUS.US_FILIAL  = '"+ xFilial( "SUS" ) + "' AND "  
cQuery += " ACH.ACH_CODPRO = SUS.US_COD  AND "
cQuery += " ACH.ACH_LOJPRO = SUS.US_LOJA AND "
cQuery += " SUS.US_CODCLI  = '"+ SA1->A1_COD      + "' AND "
cQuery += " SUS.US_LOJACLI = '"+ SA1->A1_LOJA     + "' AND "
cQuery += " ACH.D_E_L_E_T_ = '' AND "
cQuery += " SUS.D_E_L_E_T_ = '' "

cQuery := ChangeQuery( cQuery ) 

dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasQry, .F., .T. ) 
If ( cAliasQry )->( Eof() ) 
	cChaveSA1 := SA1->A1_COD+SA1->A1_LOJA
	MATRKSA1( cChaveSA1, oTree, , @nLevel, NIL, .F., NIL,.f.)
	oTree:TreeSeek( "" ) 
 	oTree:CurrentNodeId := ""
 	
Else
	If Alias() == cAliasQry 
		TcSetField( cAliasQry, "ACHRECNO", "N", 10, 0 ) 
		While !( cAliasQry )->( Eof() ) 
			ACH->( dbGoto( ( cAliasQry )->ACHRECNO ) ) 
			
			MATRKACH( ACH->ACH_CODIGO, oTree,, @nLevel, NIL, .F., NIL )
	
		 	oTree:TreeSeek( "" ) 
		 	oTree:CurrentNodeId := ""
			( cAliasQry )->( dbSkip() ) 
		EndDo     
		dbSelectArea( "ACH" ) 
	EndIf 			
EndIf

( cAliasQry )->( dbCloseArea() )                                             
oTree:EndUpdate()   
	
Return( .T. ) 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CAC600Pesq 

Pesquisa por entidades no Tree  

@sample		CAC600Pesq()

@param 		oTree - Objeto Tree 

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function CAC600Pesq( oTree )                                                       

LOCAL aItems     := {} 
LOCAL aSeek      := {} 

LOCAL cChavePesq := Space( 20 )        
LOCAL cChave     := Space( 20 )        		
LOCAL cVar       := ""

LOCAL nCombo     := 1 
LOCAL nOpca      := 0 

LOCAL oCombo          
LOCAL oDlg   
LOCAL oBut1 
LOCAL oBut2 
LOCAL oGetPesq 
Local oSay

AAdd( aItems, STR0017 ) // STR0017//"Suspect"
AAdd( aItems, STR0018 ) // STR0018//"Prospect"
AAdd( aItems, STR0019 ) // STR0019//"Cliente"
AAdd( aItems, STR0020 ) // STR0020//"Oportunidade"
AAdd( aItems, STR0021 ) // STR0021//"Proposta Comercial"
AAdd( aItems, STR0022 ) // STR0022//"Orçamento"
AAdd( aItems, STR0023 ) // STR0023//"Pedido de Vendas"
AAdd( aItems, STR0024 ) // STR0024//"Nota de Saida"

AAdd( aSeek, { "ACH", 1, "@R XXXXXX/XX"      , STR0025   ,  8 } )  // STR0025 //"Cod Suspect + Loja"
AAdd( aSeek, { "SUS", 1, "@R XXXXXX/XX"      , STR0026   ,  8 } )  // STR0026 //"Cod Prospect + Loja"
AAdd( aSeek, { "SA1", 1, "@R XXXXXX/XX"      , STR0027   ,  8 } )  // STR0027 //"Cod Cliente + Loja"
AAdd( aSeek, { "AD1", 1, "@R XXXXXX/XX"      , STR0028   ,  8 } )  // STR0028 //"Num Oportun + Revisão"//"Nro Oport + Revisão"
AAdd( aSeek, { "ADY", 1, "@R XXXXXX"         , STR0029	 ,  6 } )  // STR0029 //"Proposta"//"Nro Proposta"
AAdd( aSeek, { "SCK", 1, "@R XXXXXX/XX"      , STR0030   ,  8 } )  // STR0030 //"Nro Orçamento + Item"
AAdd( aSeek, { "SC6", 1, "@R XXXXXX/XX"      , STR0031   ,  8 } )  // STR0031 //"Num Pedido + Item"
AAdd( aSeek, { "SD2", 1, "@R XXXXXXXXX/XX/XX", STR0032   , 13 } )  // STR0032 //"Num Doc + Serie + Item"

oDlg := FWDialogModal():New()
	oDlg:SetBackground( .F. )  
	oDlg:SetTitle( CCADASTRO )	// "Rastreador de Contas"
	oDlg:SetEscClose( .T. )
	oDlg:SetSize(150,300) 
	oDlg:CreateDialog()
	oDlg:EnableFormBar( .T. )
	oDlg:CreateFormBar()
	
	oPnlFol := oDlg:GetPanelMain()
	@ 20, 15 SAY STR0035 SIZE 40, 09 OF oPnlFol PIXEL // STR0035//"Entidade"
	@ 20, 80 COMBOBOX oCombo VAR cVar ITEMS aItems SIZE 80, 10 OF oPnlFol PIXEL 
	
	oCombo:bChange := { || cChavePesq := Space( aSeek[ oCombo:nAt, 5 ] ),oGetPesq:oGet:Picture := aSeek[ oCombo:nAt, 3 ], oGetPesq:Refresh(), cChave := aSeek[ oCombo:nAt, 4 ], oGetPesq1:Refresh() }  
	                                                      
	@ 40, 15 SAY STR0036 SIZE 40, 09  OF oPnlFol   PIXEL // STR0036//"Chave "
	@ 40, 80 MSGET oGetPesq1 VAR cChave WHEN .F. SIZE 150, 10 VALID .T. OF oPnlFol PIXEL 
	
	@ 60, 15 SAY STR0037 SIZE 40, 09 OF oPnlFol    PIXEL // STR0037//"Pesquisa "
	@ 60, 80 MSGET oGetPesq VAR cChavePesq SIZE 150, 10 VALID .T. OF oPnlFol  PIXEL 
	
	oDlg:AddButton( STR0040,{|| Iif(!oTree:TreeSeek( aSeek[ oCombo:nAt, 1 ] + "-" + RTRIM(cChavePesq) ) , ;
 																				Aviso( STR0038, STR0039, { STR0040  }, 2 ), ;//"Atenção"//"Entidade não encontrada."
 																				  oDlg:Deactivate())}, STR0044, , .T., .F., .T., )//"Confirma Pesquisa"	

	oDlg:AddButton( STR0043,{|| oDlg:Deactivate() }, STR0045 , , .T., .F., .T., )//"Sair da pesquisa"

oDlg:Activate() 


Return( .T. ) 

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600ExGrp 

Verifica se usuário ou grupo já esta cadastrado

@sample		CA600ExGrp()

@param 		cCodigo - Codigo do usuário ou grupo

@return		Nenhum

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CA600ExGrp(cCodigo,cTipo)
Local lRet      := .T.
Local aGrps     := AllGroups()//Grupos
Local cNome     := '' 

If cTipo=='1'
	If (nPos:=ascan(aGrps,{|x| x[1,1] = cCodigo}))>0
		cNome := aGrps[nPos,1,2]
	EndIF
Else
	cNome := UsrFullName(cCodigo)
EndIf

If Empty(cNome)
	Help('',1,'CRM600USR',,STR0041,1) // Usuário e/ou Grupo inválido.//"Usuário e/ou Grupo inválido."
	lRet := .F.
EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600TOK 

Rotina para validacao antes da gravacao do papel
Valida Grid de usuários de Grupos, verifica se ambos estao vazios

@sample		CA600TOK()

@param 		oModel - - Model da rotina

@return		lRet - .T. - Confirma o cadastro; .F. - Não confirma o cadastro

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function CA600TOK(oModel)
Local lRet 		:= .T.
Local oModelGRP	:= oModel:GetModel("AOSDETAIL_G")
Local oModelUSR	:= oModel:GetModel("AOSDETAIL_U")
Local lDelG     := .F.
Local lDelU     := .F.

If oModelGRP:isempty() .And. oModelUSR:isempty()
	lRet := .F.
EndIf

If lRet
	lDelG := CA600TudDel(oModel,oModelGRP)
	lDelU := CA600TudDel(oModel,oModelUSR)
EndIf

If lRet .And. (lDelG .And. oModelUSR:isempty()) .Or.;
	(lDelU .And. oModelGRP:isempty()) .Or. (lDelU .And. lDelG)
	lRet := .F.
EndIf

If !lRet
    Help('',1,'CRM600VUS',,STR0046,1) // Usuário e/ou Grupo de Usuários não definido no papel
EndIf

Return lRet

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600TudDel 

Verifica se as grids de usuario e grupo estao deletadas

@sample		CA600TudDel()

@param 		oModel- Model da rotina
@param 		oGrid - Grid do usuário ou grupo

@return		lDel - .T. Todas as linhas deletadas; .F. - Todas as linhas não deletadas

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function CA600TudDel(oModel,oGrid)
Local nCount    := 0
Local nFor      := 0
Local lDel	    := .F.

For nFor := 1 To oGrid:Length()
	oGrid:GoLine(nFor)
	
	If oGrid:IsDeleted() .or. Empty(oGrid:GetValue("AOS_CODIGO"))
		nCount++
	EndIf
	
Next nFor


If (nCount==oGrid:Length()) 
	lDel := .T.
EndIf

Return lDel

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CA600Activ 

Ajustes na ativação do modelo

@sample		CA600Activ()

@param 		oModel - - Model da rotina

@author		Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Static Function CA600Activ(oModel)
Local oModelUSR	:= oModel:GetModel("AOSDETAIL_U")
Local oModelGRP	:= oModel:GetModel("AOSDETAIL_G")

If oModel:IsCopy()
	oModelUSR:SetNoInsertLine(.F.)
	oModelUSR:ClearData(.T.)
	
	oModelGRP:SetNoInsertLine(.F.)
	oModelGRP:ClearData(.T.)
EndIf

Return Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM600INIT 

Rotina para Inicializar os campos virtuais de descrição

@sample	CRM600INIT()

@param 		cTipo -  Model da rotina

@return    cRet - Descrição do registro

@author	Aline Sebrian Damasceno
@since		30/03/2015
@version	12.1.5
/*/
//------------------------------------------------------------------------------
Function CRM600INIT(cTipo)

Local oModel		:= FwModelActive()
Local nOperation 	:= oModel:GetOperation()
Local cRet 			:= ""

Local lGrupo := .F. 

Default cTipo   := ""

If nOperation <> MODEL_OPERATION_INSERT 

	lGrupo := IIF(cTipo == "1", .T.,.F.)
	
	If lGrupo// Aba de Lote
		aGrps := AllGroups()//Grupos
		nPos := Ascan(aGrps,{|x| AllTrim(x[1,1]) == AOS->AOS_CODIGO })
		If  nPos > 0
			cRet := aGrps[nPos,1,2]
		EndIf
	Else	
		cRet := UsrFullName(AOS->AOS_CODIGO)
	EndIf

EndIf

Return cRet