#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "TMSA024.ch"

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Cadastro Regras de Restrição
@owner paulo.henrique
@author paulo.henrique
@since 11/09/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function TMSA024()
Local oBrowse	:= Nil				// Recebe o objeto do Browse

Private aRotina   	:= MenuDef()	// Recebe as rotinas do MenuDef

//-- Validação Do Dicionário Utilizado
If !AliasInDic("DIU") 
	MsgNextRel()	//-- É Necessário a Atualização Do Sistema Para a Expedição Mais Recente
	Return()
EndIf

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DIU")
oBrowse:SetDescription(STR0001) // "Cadastro Regras de Restrição"


oBrowse:Activate()

Return Nil 

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Modelo de dados
@owner paulo.henrique
@author paulo.henrique
@since 06/08/2014
@param Params
@return oModel Objeto do Modelo
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function ModelDef()

Local oModel    := NIL       		  	// Objeto do Model
Local oStruDIU  := NIL       		  	// Estrutura Cabeçalho - Regra de Restrição
Local oStruDIV  := NIL       		  	// Estrutura Grid - Restricao Dia Semana
Local oStruDIX  := NIL 				  	// Estrutura Grid - Outras Restricões 
Local aRelacDIV	:= {}		 		  	// Recebe o Relation da DIV
Local aRelacDIX	:= {}				  	// Recebe o Relation da DIX
Local bPosValid := { || PosVldMdl() } 	// Recebe o PosValid
Local bLinePost	:= { || TMSA024LOK() }	// Recebe o valid na linha


//---------------------------+
// CRIA ESTRUTRA PARA oModel |
//---------------------------+
oStruDIU 	:= FWFormStruct( 1, 'DIU' )
oStruDIV 	:= FWFormStruct( 1, 'DIV' )
oStruDIX 	:= FWFormStruct( 1, 'DIX' )

oModel := MPFormModel():New ( "TMSA024",/*bPreValid*/, bPosValid,, /*bCancel*/ )

oModel:SetDescription(STR0001) // "Cadastro Regras de Restrição"

// ------------------------------------------+
// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
// ------------------------------------------+
oModel:AddFields( 'MdFieldDIU',			    , oStruDIU, /*bLinePre*/, bLinePost, /*bPre*/ , /*bPost*/,/* bLoad*/)				
oModel:AddGrid  ( 'MdGridDIV' , 'MdFieldDIU', oStruDIV, /*bLinePre*/, bLinePost, /*bPre*/ , /*bPost*/, /*bLoad*/)
oModel:AddGrid  ( 'MdGridDIX' , 'MdFieldDIU', oStruDIX,/*bLinePre*/, /*bLinePost*/, /*bPre*/ , /*bPost*/, /*bLoad*/)

// -------------------------------------+
// DEFINE SE O CAMPONENTE E OBRIGATORIO |
// -------------------------------------+
oModel:GetModel( 'MdGridDIV' ):SetOptional( .T. )
oModel:GetModel( 'MdGridDIX' ):SetOptional( .T. )

// -------------------------------------------------+
// FAZ RELACIONAMENTO ENTRE OS COMPONENTES DO MODEL |
// -------------------------------------------------+
aAdd(aRelacDIV,{ 'DIV_FILIAL'	, 'xFilial( "DIV" )'	})
aAdd(aRelacDIV,{ 'DIV_CODREG'	, 'DIU_CODREG' 		})

aAdd(aRelacDIX,{ 'DIX_FILIAL'	, 'xFilial( "DIX" )'	})
aAdd(aRelacDIX,{ 'DIX_CODREG'	, 'DIU_CODREG' 		})

oModel:SetRelation( 'MdGridDIV', aRelacDIV , DIV->( IndexKey( 1 ) )  )
oModel:SetRelation( 'MdGridDIX', aRelacDIX , DIX->( IndexKey( 1 ) )  )


oModel:GetModel ( 'MdFieldDIU' )
oModel:SetPrimaryKey( { "DIU_FILIAL","DIU_CODREG" } )

oModel:SetActivate( { |oModel| ActivMdl(oModel) } )

oModel:GetModel( 'MdGridDIV' ):SetUniqueLine( { 'DIV_DIASEM','DIV_SERTMS','DIV_TIPVEI','DIV_PLACA','DIV_HORINI','DIV_HORFIM' } )
oModel:GetModel( 'MdGridDIX' ):SetUniqueLine( { 'DIX_DESCRI','DIX_TIPREG','DIX_ACAO' } )

Return (oModel)

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Exibe browse de acordo com a estrutura 
@owner paulo.henrique
@author paulo.henrique
@since 24/07/2014
@param Params
@return oView do objeto oView
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------      
Static Function ViewDef()

Local oView    := NIL        // Recebe o objeto da View
Local oModel   := NIL        // Objeto do Model 
Local oStruDIU := NIL        // Estrutura Cabeçalho - Regra de Restrição
Local oStruDIV := NIL        // Estrutura Grid - Restricao Dia Semana
Local oStruDIX := NIL 		 // Estrutura Grid - Outras Restricões 

oModel     := FwLoadModel( "TMSA024" )

//---------------------------+
// CRIA ESTRUTRA PARA oView  |
//---------------------------+
oStruDIU 	:= FWFormStruct( 2, 'DIU' )
oStruDIV 	:= FWFormStruct( 2, 'DIV' )
oStruDIX 	:= FWFormStruct( 2, 'DIX' )

oView := FwFormView():New()
oView:SetModel(oModel)

//----------------------------+
// REMOVE CAMPOS DA ESTRUTURA |
//----------------------------+
oStruDIV:RemoveField('DIV_CODREG')
oStruDIX:RemoveField('DIX_CODREG')

// ----------------------------------------------+
// LIMPA OS CAMPOS NÃO RELACIONADOS COM O TIPRES |
// ----------------------------------------------+
oView:SetFieldAction('DIU_TIPRES', { || VldTIPRES(), oView:Refresh()})

oView:SetFieldAction('DIX_TIPREG', { || LimpAcao(), oView:Refresh()})

//-------------------------------------------+
// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
//-------------------------------------------+
oView:AddField( 'VwFieldDIU', oStruDIU , 'MdFieldDIU' )
oView:AddGrid( 'VwGridDIV' , oStruDIV , 'MdGridDIV' )
oView:AddGrid( 'VwGridDIX' , oStruDIX , 'MdGridDIX' )

//------------------------------------------------+
// REALIZA AUTOPREENCHIMENTO PARA OS CAMPOS ITENS |
//------------------------------------------------+
oView:AddIncrementField('VwGridDIV','DIV_ITEM')
oView:AddIncrementField('VwGridDIX','DIX_ITEM')

//-------------------------------------------+
// DEFINE EM % A DIVISAO DA TELA, HORIZONTAL |
//-------------------------------------------+
oView:CreateHorizontalBox( 'TOPO'   , 35 )
oView:CreateHorizontalBox( 'FOLDER' , 65 )

//-------------------------+
// DEFINE FOLDER PARA TELA |
//-------------------------+
oView:CreateFolder( "PASTA", "FOLDER" )
oView:AddSheet( "PASTA", "ABA01", STR0009)  	//-- 'Dia Semana(Placa)' 
oView:AddSheet( "PASTA", "ABA02", STR0011) 		//-- 'Outras Restrições'

oView:CreateHorizontalBox( "TAB_DIS_1"	, 100,,,"PASTA","ABA01" )
oView:CreateHorizontalBox( "TAB_DIS_2"	, 100,,,"PASTA","ABA02" )

// Liga a identificacao do componente
oView:EnableTitleView ('VwFieldDIU'	,STR0008)	//-- 'Regras de Restrições'
oView:EnableTitleView ('VwGridDIV' 	,STR0009) 	//-- 'Restrições' 
oView:EnableTitleView ('VwGridDIX'	,STR0011)	//-- 'Restrições de Usuário'

// Cabecalho - Restricoes
oView:SetOwnerView( 'VwFieldDIU' , 'TOPO' )

// Folder 1 - Campos para pesquisa de ROTA
oView:SetOwnerView( 'VwGridDIV' , 'TAB_DIS_1' )

// Folder 2 - Grid Restricoes por Rota
oView:SetOwnerView( 'VwGridDIX' , 'TAB_DIS_2' )

//Habilita o novo Grid
 
//Grid DIV
oView:SetViewProperty("VwGridDIV", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDIV", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDIV", "GRIDSEEK", {.T.})

//Grid DIX
oView:SetViewProperty("VwGridDIX", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDIX", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDIX", "GRIDSEEK", {.T.})
              
Return ( oView )

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
MenuDef
Description
MenuDef com as rotinas do Browse
@owner paulo.henrique
@author paulo.henrique
@since 06/08/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {} 		// Recebe as Rotinas do Menu	

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  DISABLE MENU		//"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA024" OPERATION 2 ACCESS 0  DISABLE MENU		//"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA024" OPERATION 3 ACCESS 0 					//"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA024" OPERATION 4 ACCESS 0  DISABLE MENU		//"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA024" OPERATION 5 ACCESS 0  DISABLE MENU		//"Excluir"
ADD OPTION aRotina TITLE STR0007 	ACTION "VIEWDEF.TMSA024" OPERATION 9 ACCESS 0  DISABLE MENU		//"Copiar"
ADD OPTION aRotina TITLE STR0028	ACTION "A024OutInf(.T.)" OPERATION 4 ACCESS 0  					//"Restrições Informativas"

Return ( aRotina )  

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A024Acao
Description
Valida a função no campo ação e verifica se o retorno é booleano
@owner paulo.henrique
@author paulo.henrique
@since 19/11/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A024Acao()
Local lRet  	:= .F.	 							// Recebe o Retorno
Local xRetFun	:= NIL 	 							// Recebe o Retorno da Função 
Local oError024	:= ErrorBlock({|e| A024Error(e)}) 	// Recebe o Erro de execução 

If FwFldGet("DIX_TIPREG") == "1"
	Begin Sequence 
		xRetFun := &(FwFldGet("DIX_ACAO"))
	
		If ValType(xRetFun) == "L" 
			lRet := .T.
		Else
			 Help('', 1,"TMSA02401",, STR0020,1) //"A função deve retornar um valor Logico"
		EndIf
	End Sequence
	ErrorBlock(oError024)
Else
	lRet := .T.
EndIf

Return lRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A024Error
Description
Exibe a Mensagem de Erro e sai fora da sequencia de execução
@owner paulo.henrique
@author paulo.henrique
@since 19/11/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function A024Error(oError024)

Help('', 1,"TMSA02402",, STR0021 + chr(10)+ oError024:Description,1) //"Erro encontrado na Função executada: " ##### 

Break
Return NIL
//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
ActivMdl
Description
Limpa os campos do cabeçalho ao realizar Copia da
Regra Restrição.
@owner paulo.henrique
@author paulo.henrique
@since 12/08/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function ActivMdl(oModel)

Local nOperation	:= oModel:GetOperation()			// Recebe a operação executada
Local oFieldDIU		:= oModel:GetModel("MdFieldDIU")	// Recebe o model da DIU 
Local lRet 			:= .T.								// Recebe o retorno

// ---------------------------------------------------------------+
// LIMPA OS CAMPOS DO CABEÇALHO CLIENTE/AREA AO REALIZAR A COPIA. |
// ---------------------------------------------------------------+

	// -- TRATAMENTO AO USAR O BOTAO COPIAR	
	// -- Botao Copiar carrega o nOperation com 3 inves de vir com 9.
	If nOperation == 3 .And. !INCLUI 	
	
		oFieldDIU:LoadValue("DIU_CODREG", GetSX8Num("DIU","DIU_CODREG") )
		

		oFieldDIU:LoadValue("DIU_TIPRES",CriaVar("DIU_TIPRES"))
		oFieldDIU:LoadValue("DIU_CODCLI",CriaVar("DIU_CODCLI") )
		oFieldDIU:LoadValue("DIU_LOJCLI",CriaVar("DIU_LOJCLI") )
		oFieldDIU:LoadValue("DIU_NOMCLI",CriaVar("DIU_NOMCLI") )
		oFieldDIU:LoadValue("DIU_ABRANG",CriaVar("DIU_ABRANG") )
		oFieldDIU:LoadValue("DIU_CODARE",CriaVar("DIU_CODARE") )
		oFieldDIU:LoadValue("DIU_DESARE",CriaVar("DIU_DESARE") )	
		oFieldDIU:LoadValue("DIU_INIVIG",CriaVar("DIU_INIVIG") )
		oFieldDIU:LoadValue("DIU_FIMVIG",CriaVar("DIU_FIMVIG") )
	EndIf

Return(lRet)

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Funcao de validacao da model (compatibilizacao)
@owner paulo.henrique
@author paulo.henrique
@since 24/07/2014
@param .T./.F. Logico
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function PosVldMdl()

Local oModel	:= FWModelActive()	// Recebe o model Ativo
Local lRet 	:= .T.					// Recebe o Retorno

If oModel <> Nil 
	
	IF oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
		// Valida Cadastro antes da gravacao.	
		lRet := TMSA024TOK( oModel:GetOperation() )		
	Endif

Endif

Return lRet
//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
TMSA024TOK
Description
VALIDA A DIGITACAO DE PELO MENOS UM FOLDER 
@owner paulo.henrique
@author paulo.henrique
@since 30/07/2014
@param oModel: Modelo de dados
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function TMSA024TOK( nOpc )

Local lRet   		:= .T. // Recebe o Retorno
Local oModel 		:= FWModelActive() 
Local oMdlGrdDIV 	:= oModel:GetModel('MdGridDIV') // Recebe o Modelo do GRID DIV
Local oMdlGrdDIX 	:= oModel:GetModel('MdGridDIX') // Recebe o Modelo do GRID DIX


	If lRet .And. FwFldGet("DIU_TIPRES") == "1" // CLIENTE
		If Empty( FwFldGet("DIU_CODCLI"))
			Help( " ", 1, "TMSA02403",, STR0022 + RetTitle( "DIU_CODCLI" ), 4, 1 ) //"Campo Obrigatório: "
			lRet := .F.
		EndIf
	ElseIf lRet .And. FwFldGet("DIU_TIPRES") == "2" // AREA
		If Empty(FwFldGet("DIU_CODARE"))
			Help( " ", 1, "TMSA02403",, STR0022 + RetTitle( "DIU_CODARE" ), 4, 1 ) //"Campo Obrigatório: "
			lRet := .F.
		EndIf	
	EndIf
	
	If lRet .And. FwFldGet("DIU_INIVIG") > FwFldGet("DIU_FIMVIG")
		Help("",1,'TMSA02405',,STR0012,1,0) //'Data de vigência inicial não pode ser maior que a data final.'
		lRet := .F.
	EndIf	

	If Empty(oMdlGrdDIV:GetValue('DIV_DESCRI',1)) .And. Empty(oMdlGrdDIX:GetValue('DIX_DESCRI',1))
		Help("",1,'TMSA02404',,STR0017,1,0) //// "É obrigatório o preenchimento de pelo menos uma pasta."
		lRet :=.F.
	Endif	

Return(lRet)

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
TMSA024LOK
Description
 Valida‡Æo de Linha da GetDados
@owner paulo.henrique
@author paulo.henrique
@since 24/07/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function TMSA024LOK()

Local oModel	:= Nil			// Recebe o Model
Local oView 	:= Nil			// Recebe a View
Local aArea    	:= GetArea()	// Recebe a Area Ativa
Local nFolder 	:= 0			// Recebe o Numero da Folder
Local cGridAtu	:= Nil			// Recebe o Grid Atual
Local oModelAtu	:= Nil			// Recebe o Model Atual
Local cHorIni   := ""			// Recebe a Hora inicial
Local cHorFim  	:= ""			// Recebe a Hora final
Local lRet     	:= .T.			// Recebe o Retorno

oModel	:= FwModelActive()
oView 	:= FwViewActive()

If oView <> Nil 
                                                      
   //-- 1= Retorna o ID do folder, 2 = Retorna o titulo do folder.                                                                                   
	nFolder 	:= oView:GetFolderActive("PASTA",2)[1]  
	                                                                                 
	// VERIFICAR O GRID ATUAL
	If nFolder == 1
		cGridAtu := "MdGridDIV"                                                                      
	ElseIf nFolder == 2
		cGridAtu := "MdGridDIX"
	EndIf
	                                                                    
	oModelAtu	:= oModel:GetModel( cGridAtu )                                                                         

	If	nFolder == 1
		// -----------------------------------------------+
		// BLOCO DE VALIDACAO - GRID DIA DA SEMANA (PLACA)|
		// -----------------------------------------------+
	
		//-- Nao avalia linhas deletadas
		If  !oModelAtu:IsDeleted()
						
			//-- Recupera valor dos campos
			cHorIni	:= oModelAtu:GetValue('DIV_HORINI')
			cHorFim	:= oModelAtu:GetValue('DIV_HORFIM')
			
			If !Empty(cHorIni) .And. !Empty(cHorFim)
				//-- Valida Hora Inicial maior que Hora Fim
				If	lRet .And. cHorIni > cHorFim
					lRet := .F.
					Help("",1,'TMSA02406',,STR0013,1,0) // 'Hora final deve ser maior que a inicial.'
				EndIf
				
				//-- Valida Hora Inicial e igual a hora final. 
				If lRet .And. cHorIni == cHorFim
					lRet := .F.
					Help("",1,'TMSA02407',,STR0014,1,0) // 'Hora Inicial / Final não podem ser iguais.'
				EndIf
			EndIf
					
		EndIf
	EndIf 	
EndIf

RestArea(aArea)
Return(lRet)

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A024VldVig
Description
Validacao dos campos de Data de Vigencia Inicial e Final. Não permite a duplicação
nos valores 
@owner paulo.henrique
@author rodrigo.pirolo
@since 08/08/2014
@param Params
@return lRet = .T./.F. Validação
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------

Function A024VldVig()
Local oModel 		:= FWModelActive()					// Recebe o Model Ativo
Local lRet			:= .T.								// Recebe o Retorno
Local cQry			:= ""								// Recebe a Query
Local cCodReg		:= FwFldGet("DIU_CODREG")			// Recebe o Codigo da Regra
Local cCodCli		:= FwFldGet("DIU_CODCLI")			// Recebe o codigo do cliente
Local cLojCli		:= FwFldGet("DIU_LOJCLI")			// Recebe a loja
Local cTipRes		:= FwFldGet("DIU_TIPRES")			// Recebe o tipo de Restrição
Local cCodArea		:= FwFldGet("DIU_CODARE")			// Recebe o codigo da area
Local cDesArea		:= FwFldGet("DIU_DESARE")			// Recebe a Descrição da area
Local cAbrange		:= FwFldGet("DIU_ABRANG")			// Recebe a Abrangencia:  1=cliente/loja; 2=cliente
Local cAliasDIU		:= GetNextAlias()					// Recebe o proximo alias disponivel
Local dIniVig		:= FwFldGet("DIU_INIVIG")			// Recebe a data inicial da vigencia
Local dFimVig		:= FwFldGet("DIU_FIMVIG")			// Recebe a data final da vigencia
Local nOperation	:= oModel:GetOperation()			// Recebe o operation
Local nCount		:= 0								// Recebe o contador


If !Empty(dIniVig) .AND. !Empty(dFimVig)

	If dFimVig >= dIniVig
	
		cQry := "SELECT DIU_CODREG,DIU_CODARE,DIU_CODCLI, DIU_LOJCLI, DIU_INIVIG, DIU_FIMVIG "
		cQry += "From "+ RetSqlName("DIU") +" DIU "
		cQry += "Where	DIU_FILIAL = '"+ xFilial("DIU") +"' AND "
		
		If cTipRes == "1"
			cQry += 		"DIU_CODCLI = '"+ FwFldGet("DIU_CODCLI") +"' AND "
			cQry += 		"DIU_CODCLI != '"+ Space(TamSX3("DIU_CODCLI")[1]) +"' AND "
			cQry += 		"DIU_ABRANG = '"+ cAbrange +"' AND "
			
			If cAbrange == "1"
				cQry +=	"DIU_LOJCLI = '"+ cLojCli +"' AND "
			EndIf
			  
		Else
			cQry += 		"DIU_CODCLI = '"+ Space(TamSX3("DIU_CODCLI")[1]) +"' AND "
			cQry += 		"DIU_CODARE = '"+ cCodArea +"' AND "
			cQry += 		"DIU_DESARE = '"+ cDesArea +"' AND "
		EndIf
		
		cQry += 			"DIU_TIPRES = '"+ cTipRes +"'  AND "
		cQry += 		"(('"+ DtoS(dIniVig)+"' >= DIU_INIVIG  AND '"+ DtoS(dIniVig)+"' <= DIU_FIMVIG) OR "
		cQry +=			"('"+ DtoS(dFimVig)+"' >= DIU_INIVIG  AND '"+ DtoS(dFimVig)+"' <= DIU_FIMVIG) OR "
		cQry +=			"('"+ DtoS(dIniVig)+"' <= DIU_INIVIG  AND '"+ DtoS(dFimVig)+"' >= DIU_FIMVIG)) "
		
		//-- NA ALTERACAO NAO DEVE CONSIDERAR O RESGISTRO ATUAL
		If nOperation == 4
			cQry +=		" AND DIU.DIU_CODREG <> '"+cCodReg+"' "
		EndIf
		
		cQry += 			" AND DIU.D_E_L_E_T_ = ' '
		
		cQry := ChangeQuery(cQry)
		DbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry),cAliasDIU,.T.,.T.)
		Count to nCount
		
		(cAliasDIU)->( DbGoTop() )
		
		If nCount > 0
			lRet := .F.
			Help("",1,'TMSA02408',,STR0016,1,0)//"Os dados informados para esta regra já se encontram cadastrados."
		EndIf
		
		(cAliasDIU)->( DbCloseArea() )
	Else  
		Help("",1,'TMSA02413',,STR0026,1,0)// data final da vigencia menor que a data inicial
		lRet := .F. 
	Endif
Endif
	
Return lRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A024VldPlc
Description
Validacao do campo Final Placa. Não permite a duplicação
nos valores 
@owner paulo.henrique
@author paulo.henrique
@since 08/08/2014
@param Params
@return lRet = .T./.F. Validação 
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A024VldPlc()

Local oModel		:= FWModelActive()  			 // Recebe o Model Ativo
Local oGridDIV		:= oModel:GetModel('MdGridDIV')	 //	Recebe o Model do Grid DIV
Local cFimPlac		:= ""							 //	Recebe a String contendo os finais de placa
Local aFimPlac		:= ""							 // Recebe um array com os finais de placa
Local nI			:= 1							 // Recebe os Contadores
Local lRet 			:= .T.							 // Recebe o retorno
Local nPos 			:= 0						     // Recebe a Posição do Item Procurado

cFimPlac := oGridDIV:GetValue("DIV_PLACA")
cFimPlac := TRANSFORM(cFimPlac,PESQPICT("DIV","DIV_PLACA") )
aFimPlac := StrToKarr(cFimPlac,",")

For nI := 1 To Len(aFimPlac)

	nPos := ASCAN(aFimPlac,ALLTRIM(aFimPlac[nI])) 

	If  ALLTRIM(aFimPlac[nI]) != '-'
		If nPos > 0 .AND. nPos != nI 
			Help("",1,'TMSA02409',,STR0018,1,0) // 'Não pode haver informações duplicadas.'
      		lRet := .F.
			EXIT
		EndIf
	Else
		Help("",1,'TMSA02410',,STR0015,1,0) // "Serão permitidos somente valores numéricos."
      	lRet := .F.
		EXIT
	EndIf
Next nI

Return (lRet)

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
VldTIPRES
Description
1. Limpa os campos nao relacionado ao tipo de regra de restrição.
@owner paulo.henrique
@author paulo.henrique
@since 12/08/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function VldTIPRES()
Local oView		 := FwViewActive()				  // Recebe o View Active
Local oModel 	 := FwModelActive()				  // Recebe o Modelo Ativo
Local oFieldDIU	 := oModel:GetModel('MdFieldDIU') // Recebe o modelo do Field DIU
Local oGridDIV	 := oModel:GetModel('MdGridDIV')  // Recebe o modelo do Grid DIV
Local lRet 		 := .T.							  // Recebe o Retorno
Local aSaveLines := FWSaveRows()				  // Recebe o backup das linhas do grid
Local nCount	 := 0							  // Recebe o contador do Grid

	//Se for Cliente Limpa os campos de Area
	If FwFldGet("DIU_TIPRES") == "1" 
			oFieldDIU:LoadValue("DIU_CODARE",Space(Len(FwFldGet('DIU_CODARE'))) ) 
			oFieldDIU:LoadValue("DIU_DESARE",Space(Len(FwFldGet('DIU_DESARE'))) )
			oFieldDIU:LoadValue("DIU_ABRANG",'1' )
			
			// Limpa o campo DIV_PLACA do GRID DIV
			For nCount := 1 To oGridDIV:Length()
				
				oGridDIV:GoLine(nCount)
				oGridDIV:LoadValue("DIV_PLACA", Space( TamSX3("DIV_PLACA")[1]))
				
			Next nCount
			
			Help("",1,'TMSA02414',,,1,0)//"Os valores digitados nos campos 'Placa' do Grid foram apagados, pois o mesmo não é utilizado para o tipo de restrição 'Cliente'." ### "Caso tenha salvado os dados, clique em  fechar para voltar aos valores anteriores."
	
	//Se for Area limpa os campos de cliente
	ElseIf FwFldGet("DIU_TIPRES") == "2" 	
	
			oFieldDIU:LoadValue("DIU_CODCLI", Space(Len(FwFldGet('DIU_CODCLI'))) )
			oFieldDIU:LoadValue("DIU_LOJCLI", Space(Len(FwFldGet('DIU_LOJCLI'))) ) 
			oFieldDIU:LoadValue("DIU_NOMCLI", Space(Len(FwFldGet('DIU_NOMCLI'))) )
			oFieldDIU:LoadValue("DIU_ABRANG", Space(Len(FwFldGet('DIU_ABRANG'))) )	
			
			// Limpa os campos DIV_SERTMS e DIV_DESSVT do GRID DIV
			For nCount := 1 To oGridDIV:Length()
				
				oGridDIV:GoLine(nCount)
				oGridDIV:LoadValue("DIV_SERTMS", Space( TamSX3("DIV_SERTMS")[1]))
				oGridDIV:LoadValue("DIV_DESSVT", Space( TamSX3("DIV_DESSVT")[1]))
			Next nCount
			
			Help("",1,'TMSA02415',,,1,0)//"Os valores digitados nos campos 'Serv. Transp.' do Grid foram apagados, pois o mesmo não é utilizado para o tipo de restrição 'Area'." ### "Caso tenha salvado os dados, clique em  fechar para voltar aos valores anteriores."
	EndIf

FWRestRows( aSaveLines ) 
	
Return (lRet)
//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
LimpAcao
Description
Limpa Campo ACAO quando for outras Restrições 
do tipo informativa 
@owner paulo.henrique
@author paulo.henrique
@since 09/09/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function LimpAcao()

Local oModel 	:= FwModelActive()				// Recebe o Modelo ativo
Local oGridDIX	:= oModel:GetModel('MdGridDIX')	// Recebe o Modelo do Grid DIX

//Limpa o Campo Ação
oGridDIX:LoadValue("DIX_ACAO", Space(Len(FwFldGet("DIX_ACAO"))))

Return

//+--------------------------------------------------------------------------

/*/{Protheus.doc} 
A024OutInf
Description
Apresenta a tela de Outras Restrições informativas
@owner paulo.henrique
@author paulo.henrique
@since 08/12/2014
@param Params	
	lExibeTela = Recebe se deve exibir a tela ou somente retornar os valores
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A024OutInf(lExibTela)
Local aRet		 := {}		// Recebe o Retorno
Local aRegras	 := {}		// Recebe as Regras
Local aCliLoj	 := {}		// Recebe os clientes e lojas
Local aAreasRes	 := {} 		// Recebe as Regras de Restrição
Local cTipReg	 := ""		// Recebe o tipo da Regra C = Cliente / A = Area / T = Todos
Local cCodCliDe  := ""		// Recebe o Cliente De
Local cCodCliAte := ""		// Recebe o Cliente Ate
Local cLojaDe	 := ""		// Recebe a Loja de
Local cLojaAte	 := ""		// Recebe a Loja Ate
Local cAreaDe	 := ""		// Recebe a Area De
Local cAreaAte	 := ""		// Recebe a Area Ate
Local cQuery	 := ""		// Recebe a Query
Local cAliasQry	 := ""		// Recebe o Proximo Alias Disponivel

Default lExibTela	:= .T.

If Pergunte( "TMA024OUT", .T. )

	//Cliente De
	If !EMPTY(MV_PAR01)
		cCodCliDe := MV_PAR01
	EndIf
	
	//Loja De
	If !EMPTY(MV_PAR02)
		cLojaDe := MV_PAR02
	EndIf
	
	// Cliente Ate
	If !EMPTY(MV_PAR03)
		cCodCliAte := MV_PAR03
	EndIf
	
	//Loja Ate
	If !EMPTY(MV_PAR04)
		cLojaAte := MV_PAR04
	EndIf

	// Area De
	If !EMPTY(MV_PAR05)
		cAreaDe := MV_PAR05
	EndIf
	
	//Area Ate
	If !EMPTY(MV_PAR06)
		cAreaAte := MV_PAR06
	EndIf
	
	// Tipo dr Regra	
	If !EMPTY(MV_PAR07)
		If MV_PAR07 == 1
			cTipReg := "A"
		ElseIf MV_PAR07 == 2
			cTipReg := "C"
		ElseIf MV_PAR07 == 3
			cTipReg := "T"
		EndIf
	EndIf
	
	// Busca Range de Clientes
	If cTipReg $ "C|T"
		cAliasQry := GetNextAlias()
		cQuery := ""
		cQuery+=" SELECT A1_COD									  							 "
		cQuery+=" 	    ,A1_LOJA                                   							 "
		cQuery+=" FROM "+ RetSqlName("SA1")
		cQuery+=" WHERE A1_FILIAL = '"+ FwxFilial("SA1") +"'							     "	
		cQuery+="	    AND A1_COD >= '"+ cCodCliDe +"'  AND	A1_COD <= '"+ cCodCliAte +"' "
		cQuery+=" 	    AND A1_LOJA >= '"+ cLojaDe +"' AND A1_LOJA <= '"+ cLojaAte +"'  	 "
		cQuery+=" 	    AND D_E_L_E_T_ = ' '                         						 "
		cQuery := ChangeQuery(cQuery)
	
		DbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry,.T.,.T.)
		
			(cAliasQry)->(DbGoTop())
			While (cAliasQry)->( !EOF() )
			
				aAdd(aCliLoj,{(cAliasQry)->A1_COD,(cAliasQry)->A1_LOJA })	
			
				(cAliasQry)->( DbSkip() )
			EndDo
		
		(cAliasQry)->( DbCloseArea() )
	EndIf
	
	// Busca Range de Areas
	If cTipReg $ "A|T"
		cAliasQry := GetNextAlias()
		cQuery := ""
		cQuery+=" SELECT DIR_CODARE 								  					 	   "
		cQuery+=" FROM "+ RetSqlName("DIR")
		cQuery+=" WHERE DIR_FILIAL = '"+ FwxFilial("DIR") +"'							   	   "	
		cQuery+="	    AND DIR_CODARE >= '"+ cAreaDe +"'  AND	DIR_CODARE <= '"+ cAreaAte +"' "
		cQuery+=" 	    AND D_E_L_E_T_ = ' '                         					   	   "
		cQuery := ChangeQuery(cQuery)
	
		DbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasQry,.T.,.T.)
		
			(cAliasQry)->(DbGoTop())
			While (cAliasQry)->( !EOF() )
			
				aAdd(aAreasRes,(cAliasQry)->DIR_CODARE)	
			
				(cAliasQry)->( DbSkip() )
			EndDo
		
		(cAliasQry)->( DbCloseArea() )
	EndIf
	
	// Busca as Regras de Restrição
	If	!Empty(aCliLoj) .OR. !Empty(aAreasRes)
		aRegras := A024BusReg(aCliLoj, aAreasRes,cTipReg, DTOS(Date()) )
	EndIf
	
	// Busca as regras Informativas
	If Len(aRegras) > 0
		aRet := A024BusInf(aRegras, lExibTela)
	EndIf 
	
EndIf

Return aRet

//+--------------------------------------------------------------------------

/*/{Protheus.doc} 
A024BusInf
Description
Monta a tela de Outras restrições informativas
@owner paulo.henrique
@author paulo.henrique
@since 15/08/2014
@param Params
	aRegras     = Recebe os codigos de regras que devem ser verificados
	lExibTela	= Recebe se deve exibir a tela ou somente retornar os valores
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------

Function A024BusInf(aRegras, lExibTela)

Local aObjects		:= {}	// Recebe os objetos do Dialog
Local aInfo			:= {}	// Recebe os tamanhos dos objetos do Dialog
Local aPosObj		:= {}	// Recebe as posiçãos dos objetos no Dialog
Local aSize			:= {}	// Array dos Tamanhos dos objetos
Local oDlg			:= Nil	// Recebe o Objeto do Dialog
Local aButtons		:= {}	// Recebe os Botões do EnchoiceBar
Local cLbx			:= ""	// Variavel do ListBox
Local oLbx			:= Nil	// Objeto do ListBox
Local aRestri		:= {}	// Recebe as Restrições informativas
Local nCount		:= 0	// Recebe o Contador

DEFAULT aRegras		:= {}
DEFAULT lExibTela	:= .T.


For nCount := 1 to Len(aRegras)

	dbSelectArea("DIU")
	DIU->( dbSetOrder(1) )
	
	If DIU->(dbSeek(FwxFilial("DIU")+ aRegras[nCount] ) )
		
		dbSelectArea("DIX")
		DIX->( dbSetOrder(1) )
		If DIX->(dbSeek(FwxFilial("DIX")+ DIU->DIU_CODREG ) )
			While DIX->( !EOF() ) .AND. DIX->DIX_FILIAL = FwxFilial("DIX") .AND. DIX->DIX_CODREG = DIU->DIU_CODREG
				If  DIX->DIX_TIPREG == '2'
					AADD(aRestri,{ 	 DIU->DIU_CODREG,;
									 Iif(DIU->DIU_TIPRES == "1",STR0024,STR0025),; //"Cliente" ### "Área"     
									 DIU->DIU_CODCLI,;
									 DIU->DIU_LOJCLI,;
									 DIU->DIU_NOMCLI,;
									 DIU->DIU_CODARE,;
									 DIU->DIU_DESARE,;
									 DIX->DIX_CODREG,;
									 DIX->DIX_ACAO,;
									 DIU->(Recno())	})
				EndIf
				DIX->( DbSkip() )
			EndDo
		EndIf
	EndIf

Next nCount

If	Len(aRestri) > 0
	DbSelectArea("DIU")
	// ---------------------------------+
	// Calcula as dimensoes dos objetos |
	// ---------------------------------+
	aSize  := MsAdvSize( .T. )
	
	AAdd( aObjects, { 100, 60,.T.,.T. } )
	
	aInfo  	:= { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
	
	aPosObj	:= MsObjSize( aInfo, aObjects,.T. )
	
	DEFINE MSDIALOG oDlg TITLE STR0019 FROM aSize[7],00 TO aSize[6],aSize[5] PIXEL //-- 'Outras Restrições - Informativas'
		@ aPosObj[1,1], aPosObj[1,2] LISTBOX oLbx VAR cLbx FIELDS HEADER ;
													Posicione('SX3',2,'DIU_CODREG'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIU_TIPRES'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIU_CODCLI'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIU_LOJCLI'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIU_NOMCLI'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIU_CODARE'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIU_DESARE'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIX_CODREG'	,'X3Titulo()')		,;
													Posicione('SX3',2,'DIX_ACAO'	,'X3Titulo()')		,;																							
													SIZE	aPosObj[1,4]-aPosObj[1,2],aPosObj[1,3]-aPosObj[1,1]-20 OF oDlg PIXEL
		oLbx:SetArray(aRestri)
		oLbx:bLine	:= { || {	aRestri[oLbx:nAT, 1]	,;
										aRestri[oLbx:nAT, 2]	,;
										aRestri[oLbx:nAT, 3]	,;
										aRestri[oLbx:nAT, 4]	,;
										aRestri[oLbx:nAT, 5]	,;
										aRestri[oLbx:nAT, 6]	,;
										aRestri[oLbx:nAT, 7]	,;
										aRestri[oLbx:nAT, 8]	,;
										aRestri[oLbx:nAT, 9]	} }
	
	Aadd( aButtons, { , {|| Iif( aRestri[oLbx:nAT,10] > 0, (DIU->( DbGoTo(aRestri[oLbx:nAT,10])),;
		 FWExecView(STR0008,'VIEWDEF.TMSA024',MODEL_OPERATION_VIEW,,,,)),) },; //-- 'Regras de Restrições'
		  STR0003, STR0003 , {|| .T.}} ) // Visualizar    
		  
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,,{||oDlg:End()},, aButtons,,,,,,.F. )

EndIf

Return aRestri

//+--------------------------------------------------------------------------

/*/{Protheus.doc} 
A024BusReg
Description
Busca as Regras de Restrição
@owner paulo.henrique
@author paulo.henrique
@since 04/12/2014
@param Params
	aCliLoj 	= Array bidimensional de {cliente , loja}
	aAreasRes	= Array com o codigo das areas de Restrição
	cTipReg 	= Tipo da Regra C = Cliente / A = Area / T = Todos
	cData 		= Data para verificar restrições.
@return Returns
	aRet =  Retorna os codigos das Regras de Restrição.
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A024BusReg(aCliLoj, aAreasRes,cTipReg,cData)
Local cQuery		:= ""				// Recebe a Query
Local cAliasTmp		:= GetNextAlias()	// Recebe o Proximo alias disponivel
Local nCount		:= 0				// Recebe o contador
Local nLenCliLoj	:= 0				// Recebe o tamanho do array aCliLoj
Local nLenAreas		:= 0				// Recebe o tamanho do array aAreasRes
Local cInAreas		:= ""				// Recebe a String para a clausula IN das Areas de Restrição
Local aRet			:= {}				// Recebe o Retorno

DEFAULT aCliLoj		:= {}
DEFAULT aAreasRes		:= {}
DEFAULT cTipReg		:= "T"
DEFAULT cData		:= DTOS(Date())

nLenCliLoj	:= Len(aCliLoj)
nLenAreas	:= Len(aAreasRes)	

// Busca as Regras de Restrição, apartir do cliente e ou Area de Restrição
cQuery	:=" SELECT  DIU_CODREG						"
cQuery  +=" FROM "+ RetSqlName("DIU")+ " DIU  		" 
cQuery  +=" WHERE 									"
cQuery  +="		DIU.D_E_L_E_T_ = ' ' 	AND			"

// Data de Vigencia
If !Empty(cData)
	cQuery +="		('"+ cData +"' >= DIU.DIU_INIVIG AND '"+ cData  +"' <= DIU.DIU_FIMVIG) AND "
EndIf

cQuery  +="		(									"

// Areas de Restrição
If nLenAreas > 0 .AND. cTipReg $ 'A|T'
	
	For nCount := 1 to nLenAreas
		
		cInAreas += "'"+aAreasRes[nCount]+"'"
		
		If nCount <  nLenAreas
			cInAreas += ","
		EndIf
	Next
	
	cQuery  +="			DIU.DIU_CODARE IN ("+ cInAreas +") "
EndIf

If  nLenCliLoj > 0 .AND. nLenAreas > 0 .AND.  cTipReg = 'T'
	cQuery  +="	 OR  "
EndIf 

// Cliente e Loja
If nLenCliLoj > 0 .AND. cTipReg $ 'C|T'
	
	For nCount := 1 to Len(aCliLoj)
		cQuery  +="		( ( DIU.DIU_CODCLI = '"+ aCliLoj[nCount][1] +"' AND DIU.DIU_LOJCLI = '"+ aCliLoj[nCount][2] +"' AND DIU.DIU_ABRANG = '1' ) "
		cQuery  +="	  OR  ( DIU.DIU_CODCLI = '"+ aCliLoj[nCount][1] +"' AND DIU.DIU_ABRANG = '2') )	
	
		If nCount <  Len(aCliLoj)
			cQuery  += " OR "
		EndIf
		
	Next nCount
EndIf

cQuery  +="		)			"

cQuery := ChangeQuery(cQuery)

If Select(cAliasTmp) > 0
	cAliasTmp->( DbCloseArea() )
	cAliasTmp := GetNextAlias()
EndIf

DbUseArea(.T.,"TOPCONN", TCGenQry(,,cQuery), cAliasTmp,.T.,.T.)

	(cAliasTmp)->(DbGoTop())
	While (cAliasTmp)->( !EOF() )
	
		aAdd(aRet,(cAliasTmp)->DIU_CODREG)	
	
		(cAliasTmp)->( DbSkip() )
	EndDo

(cAliasTmp)->( DbCloseArea() )

Return aRet



//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A024BusArs
Description
Monta cQuery Filtra Regra de Restrições a partir dos parametros.
@owner paulo.henrique
@author paulo.henrique
@since 28/11/2014
@param Params
aCepDeAte   = Array com  {Cep Inicial,Cep Final} existente na rota
cRota		= Recebe a Rota
aCepCliDoc 	= Array com {Cep} dos documentos da viagem

@return Returns
aRet = Retorna os codigos das areas encontradas
@sample Samples
@project Projects
@menu Menu
@version 11
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A024BusArs(aCepDeAte,cRota,aCepCliDoc)
Local aRet 			:= {}  				// Recebe o Retorno dos Codigos de Area Encontrados
Local cAliasQry		:= GetNextAlias()	// Recebe o Proximo alias Disponivel
Local cQuery		:= ""				// Recebe a Query
Local nLenACep		:= 0				// Recebe o Tamanho do Array aCep
Local nCount		:= 0				// Recebe o contador do for	
Local cTempCep      := ""				// Recebe o alias da tabela temporaria de cep's
Local aEstruCep		:= {}				// Recebe a Estrutura da tabela de Cep temporaria
Local nLenCepDoc	:= 0				// Recebe o Tamanho do Array aCepCliDoc
Local cInsert		:= ""				// Recebe a Query do Insert
Local oTemp			:= Nil
Local cRealName		:= ""
Local lCriouTab		:= .F. 

Default aCepDeAte 	:= {}
Default cRota		:= ""
Default aCepCliDoc	:= {}

nLenACep := Len(aCepDeAte)
nLenCepDoc := Len(aCepCliDoc) 

// Busca Areas de Restrição
If nLenACep > 0 .OR. nLenCepDoc > 0 

	aEstruCep	:= {}
				
	//-- Determina Características Do Campo Da Tab. Temporária 
	aAdd(aEstruCep,{"TRB_TIPO"	,"C",1,0})
	aAdd(aEstruCep,{"TRB_CEP"	,"C",TamSX3("DIS_CEPINI")[1],0})
	aAdd(aEstruCep,{"TRB_CEPINI","C",TamSX3("DIS_CEPINI")[1],0})
	aAdd(aEstruCep,{"TRB_CEPFIM","C",TamSX3("DIS_CEPFIM")[1],0})
	
	cTempCep	:= GetNextAlias()

	oTemp	:= FwTemporaryTable():New(cTempCep)
	oTemp:SetFields( aEstruCep )
	oTemp:AddIndex("01", {"TRB_TIPO","TRB_CEP","TRB_CEPINI","TRB_CEPFIM"} )
	oTemp:Create()
	
	lCriouTab	:= .T.
	cRealName	:= oTemp:GetRealName()
	
	// Verifica as faixas de CEP da Rota
	If nLenACep > 0
	
		//-- Inclui as faixas de cep na tabela temporaria
		For nCount := 1 To nLenACep
			cInsert := "INSERT INTO " + cRealName + " (TRB_TIPO, TRB_CEPINI, TRB_CEPFIM) "
			cInsert += "VALUES ('1','" + aCepDeAte[nCount][1] +"','" + aCepDeAte[nCount][2] +"' )"
			
			TcSqlExec(cInsert) 
		Next nCount
	
		//  Monta a Query de Faixas de Cep
		cQuery := " SELECT		DISTINCT(DIS.DIS_CODARE) AS CODAREA "
		cQuery += " FROM 			" + RetSqlName("DIS") + " DIS "
		cQuery += " INNER JOIN 	" + cRealName	  + " TEMP "
		cQuery += " ON			((   TRB_CEPINI  >=  DIS.DIS_CEPINI AND TRB_CEPINI  <= DIS.DIS_CEPFIM)   "
		cQuery += " 	 			OR ( TRB_CEPFIM  >=  DIS.DIS_CEPINI AND TRB_CEPFIM  <= DIS.DIS_CEPFIM)   "
		cQuery += " 				OR ( TRB_CEPINI  <=  DIS.DIS_CEPINI AND TRB_CEPFIM  >= DIS.DIS_CEPFIM) ) "
		cQuery += " AND 			TRB_TIPO         =   '1' "
		cQuery += " WHERE 		DIS.DIS_FILIAL   =   '"+xFilial("DIS")+"' "
		cQuery += " AND 			DIS.D_E_L_E_T_   =   ' ' "
	EndIf
	
	// Caso utilize os dois tipos na tabela
	If nLenACep > 0 .AND. nLenCepDoc > 0
		cQuery += " UNION ALL                                                   		"
	EndIf
	
	// Verifica CEP's dos documentos
	If nLenCepDoc > 0
		
		//-- Inclui Os CEP's dos documentos na tabela temporaria
		For nCount := 1 To nLenCepDoc
			cInsert := "INSERT INTO " + cRealName + " (TRB_TIPO, TRB_CEP) "
			cInsert += " VALUES ('2','" + aCepCliDoc[nCount] + "' )"
			
			TcSqlExec(cInsert) 
		Next nCount
		
		//  Monta a Query de CEP's dos documentos
		cQuery += " SELECT		DISTINCT(DIS_CODARE) AS CODAREA "
		cQuery += " FROM 			" +RetSqlName("DIS") + " DIS "
		cQuery += " INNER JOIN 	" + cRealName	  + " TEMP "
		cQuery += " ON			(TRB_CEP 			>=  DIS_CEPINI AND TRB_CEP <= DIS_CEPFIM ) "
		cQuery += " AND 			TRB_TIPO 			=   '2' "
		cQuery += " WHERE 		DIS_FILIAL 		=   '" + xFilial("DIS") + "' "
		cQuery += " AND 			DIS.D_E_L_E_T_ 	=   ' ' "
		
	EndIf

EndIf

If !Empty(cRota) .AND.( nLenACep > 0 .OR. nLenCepDoc > 0 )
	cQuery +=" 	UNION ALL "
EndIf

// Busca por Rota
If !Empty(cRota)
	cQuery +=" SELECT DISTINCT(DIT_CODARE) AS CODAREA  "	
	cQuery +=" FROM " +RetSqlName("DIT") 
	cQuery +=" WHERE 								  "
	cQuery +=" 		DIT_FILIAL = '"+xFilial("DIT")+"' "
	cQuery +=" 		AND D_E_L_E_T_ = ' '              "
	cQuery +=" 		AND	DIT_ROTA ='"+ cRota +"'		  "
EndIf 

If !Empty(cQuery)
	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry,.T.,.T.)
	
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->( !EOF() )
		
		If AScan(aRet,{|x| x == (cAliasQry)->CODAREA } ) <= 0 
			AADD( aRet,(cAliasQry)->CODAREA )
		EndIf
		
		(cAliasQry)->( DbSkip() )
	EndDo
	(cAliasQry)->( DbCloseArea() )
EndIf

If lCriouTab
	oTemp:Delete()
Endif

Return aRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A024QyRest
Description
Executa Query - Regra de Restricoes. Objetivo é carregar
um array com todas as restricoes encontradas na viagem.
as restricoes encontradas
@owner paulo.henrique
@author paulo.henrique
@since 18/08/2014
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A024QyRest(cTab,cQuery,aRestricoes)

Local cAliasTmp		:= GetNextAlias()						// Recebe o Alias Temporario
Local cAcao			:= ""									// Recebe a Ação
Local lRet				:= .F.									// Recebe o Retorno
Local oError024 		:= ErrorBlock({|e| A024Error(e)}) 	// Recebe o Erro de execução 
Local lTmsa029   		:= FindFunction("TMSA029USE")
Local cTmsa029		:= ""
Local nPos				:= 0

Default cTab  		:= ""
Default cQuery 		:= ""
Default aRestricoes 	:= {}

cTab	:= AllTrim(UPPER(cTab))

If Select(cAliasTmp) > 0
	cAliasTmp->( DbCloseArea() )
	cAliasTmp := GetNextAlias()
EndIf

cQuery := ChangeQuery(cQuery)

DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasTmp,.T.,.T.)

// --------------------------------+
//	CARREGA ARRAY COM AS RESTRICOES	|
// --------------------------------+

While (  (cAliasTmp)->(!EOF()) )	
	
	Do Case
		// --------------------------------+
		//	TRATAMENTO DIA SEMANA (PLACA)	|
		// --------------------------------+
		Case  cTab == "DIV"
		
			nPos:= aScan( aRestricoes , {|x| x[1] + x[2] + x[4] + x[6] + x[7] + x[8] == (cAliasTmp)->(DIU_CODCLI + DIU_LOJCLI + DIU_CODARE + DIU_CODREG + "1" + DIV_ITEM  )})
			
			//--- Formata Informação De Bloqueio Para Uso No TMSA029
			cTmsa029 := ""
			If lTmsa029 
				If Tmsa029Use("TMSA140")

					If nPos == 0
					
						//-- Dados Regra
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODREG) , Space(1) + AllTrim(RetTitle("DIU_CODREG")) + "#" + (cAliasTmp)->DIU_CODREG +"#"	,"")
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODREG) , Space(1) + AllTrim(RetTitle("DIV_ITEM")) + "#" + (cAliasTmp)->DIV_ITEM		,"")
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODREG) , " - " + Capital(Alltrim((cAliasTmp)->DIV_DESCRI)) + "#"								,"")
						
						
						//-- Dados Cliente
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODCLI) , AllTrim(RetTitle("DIU_CODCLI")) + "#" + (cAliasTmp)->DIU_CODCLI			,"")
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODCLI) , "/" + (cAliasTmp)->DIU_LOJCLI														,"")
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODCLI) , "-" + Capital(Alltrim((cAliasTmp)->DIU_NOMCLI))	+ "#"							,"")
						
						
						//-- Dados Area
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODARE) , Space(1) + AllTrim(RetTitle("DIU_CODARE")) + "#" + (cAliasTmp)->DIU_CODARE  ,"")
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODARE) , "- " + Capital(Alltrim((cAliasTmp)->DIU_DESARE)) + "#" 							  ,"")
							
						
						//-- Tipo Veículo
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIV_TIPVEI) , Space(1) + AllTrim(RetTitle("DIV_TIPVEI")) + "#" + Alltrim((cAliasTmp)->DIV_TIPVEI) 		,"")
						cTmsa029 += Iif(!Empty((cAliasTmp)->DIV_TIPVEI) , " - " + Capital(Alltrim(Posicione("DUT",1,xFilial("DUT") + (cAliasTmp)->DIV_TIPVEI,"DUT_DESCRI"))) + "#","")
						
						//-- Documento
						cTmsa029 += Iif(!Empty((cAliasTmp)->DUD_DOC)    , "DOCUMENTO(S)" + "#"																					,"")
						cTmsa029 += Iif(!Empty((cAliasTmp)->DUD_DOC)    , Space(1) + AllTrim(RetTitle("DUD_DOC")) + ": " + Alltrim((cAliasTmp)->DUD_FILDOC) + "/" + Alltrim((cAliasTmp)->DUD_DOC) + "/" + Alltrim((cAliasTmp)->DUD_SERIE),"")
					Else
						If !Empty((cAliasTmp)->DUD_DOC)
							aRestricoes[nPos,11] += "," + Alltrim((cAliasTmp)->DUD_FILDOC) + "/" + Alltrim((cAliasTmp)->DUD_DOC) + "/" + Alltrim((cAliasTmp)->DUD_SERIE)
						EndIf					
					EndIf					
				EndIf
			EndIf	
			
			If nPos == 0
				aAdd(aRestricoes,{	(cAliasTmp)->(DIU_CODCLI),;	//- 01
										(cAliasTmp)->(DIU_LOJCLI),;	//- 02
										(cAliasTmp)->(DIU_NOMCLI),;	//- 03
										(cAliasTmp)->(DIU_CODARE),;	//- 04
										(cAliasTmp)->(DIU_DESARE),;	//- 05
										(cAliasTmp)->(DIU_CODREG),;	//- 06
										"1",;							//- 07
										(cAliasTmp)->(DIV_ITEM),;	//- 08
										(cAliasTmp)->(DIV_DESCRI),;	//- 09
										(cAliasTmp)->(DIV_TIPVEI),; //- 10
										cTmsa029                }) //- 11
			EndIf							
			
		// --------------------------------+
		//	TRATAMENTO OUTRAS RESTRICOES	|
		// --------------------------------+
		Case  cTab == "DIX"
			//-- PARA OUTRAS RESTRICOES (TIPO BLOQUEIO) O ARRAY É CARREGADO 
			//-- APENAS QUANDO SUA EXECUÇÃO (MACRO) RESULTAR EM .T.
			If !Empty((cAliasTmp)->(DIX_ACAO)) .And. (cAliasTmp)->(DIX_TIPREG) == "1"
				Begin Sequence 
					cAcao := AllTrim((cAliasTmp)->(DIX_ACAO)) 
					If ValType( &(cAcao) ) == "L"
						lRet := &(cAcao)
						If lRet

							//--- Formata Informação De Bloqueio Para Uso No TMSA029
							cTmsa029 := ""
							If lTmsa029 
								If Tmsa029Use("TMSA140")
				
									//-- Dados Cliente
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODCLI) , AllTrim(RetTitle("DIU_CODCLI"))  + "#" + (cAliasTmp)->DIU_CODCLI				,"")
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODCLI) , "/" + (cAliasTmp)->DIU_LOJCLI														,"")
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODCLI) , "-" + Capital(Alltrim((cAliasTmp)->DIU_NOMCLI))									,"")
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODCLI) , "#"																					,"")
									
									//-- Dados Area
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODARE) , Space(1) + AllTrim(RetTitle("DIU_CODARE"))  + "#" + (cAliasTmp)->DIU_CODARE	,"")
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODARE) , "- " + Capital(Alltrim((cAliasTmp)->DIU_DESARE))								,"")
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODARE) ,  "#"																					,"")
				
									//-- Dados Regra
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODREG) , Space(1) + AllTrim(RetTitle("DIU_CODREG")) + "#" + (cAliasTmp)->DIU_CODREG	 + "#","")
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODREG) , Space(1) + AllTrim(RetTitle("DIX_ITEM"))  + "#" + (cAliasTmp)->DIX_ITEM		,"")
									cTmsa029 += Iif(!Empty((cAliasTmp)->DIU_CODREG) , " - " + Capital(Alltrim((cAliasTmp)->DIX_DESCRI))	 + "#"							,"")
									
									
								EndIf
							EndIf

							aAdd(aRestricoes,{	(cAliasTmp)->(DIU_CODCLI),;	//- 01
													(cAliasTmp)->(DIU_LOJCLI),;	//- 02
													(cAliasTmp)->(DIU_NOMCLI),;	//- 03
													(cAliasTmp)->(DIU_CODARE),;	//- 04
													(cAliasTmp)->(DIU_DESARE),;	//- 05
													(cAliasTmp)->(DIU_CODREG),;	//- 06
													"2",;							//- 07
													(cAliasTmp)->(DIX_ITEM),;	//- 08
													(cAliasTmp)->(DIX_DESCRI),;	//- 09
													"",;							//- 10
													cTmsa029   })					//- 11
						EndIf						
					Else
						Help("",1,'TMSA02411',,STR0023,1,0)//"A execução na Macro retornou um valor invalido."
					EndIf
				End Sequence
			EndIf
	EndCase
	
	(cAliasTmp)->( DbSkip() )
	
EndDo

//-- Exibe Erro Qdo Existir
ErrorBlock(oError024)
	
If Select(cAliasTmp) > 0
	(cAliasTmp)->( DbCloseArea() )
EndIf	

aSort(aRestricoes)

Return()
//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A24VldStms
Description
1. Valida o serviço de transporte para Tipo de restrição Cliente.
@owner gianni.furlan
@author gianni.furlan
@since 14/05/2015
@param Params
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A24VldStms()
Local lRet 		:= .T.

   	lRet:= TMSValField("M->DIV_SERTMS",.T.,"DIV_DESSVT") .OR. Vazio()
	
	If lRet
		//Se for Cliente, não permite escolher o SERTMS 2 "Transporte"
		If FwFldGet("DIU_TIPRES") == "1" .And.  FwFldGet("DIV_SERTMS") == "2"
			lRet := .F.	
		   	Help('', 1,"TMSA02412",, STR0027,1) //Serviço de transporte não permitido para Tipo de Restrição por Cliente   
		Endif
	
	Endif

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} A024VldFld
Valida os campos 

@author Paulo Henrique  

@since 27/10/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function A024VldFld(cCampo)
Local lRet        := .T.              // Recebe o Retorno
Local aArea       := GetArea()        // Recebe a Area Ativa 
Local oModel      := FwModelActive()  // Recebe o Model Ativo
Local aAreaSA1    := SA1->(GetArea()) // Recebe a Area do SA1 
Local cCliente    := ""               // Recebe o Cliente
Local cLoja       := ""               // Recebe a Loja do Cliente
Local oModelFld   := NIL              // Recebe o Modelo do Cabeçalho

Default cCampo    := ReadVar()        // Recebe o campo 


If cCampo $ "M->DIU_CODCLI|M->DIU_LOJCLI"

	oModelFld := oModel:GetModel( "MdFieldDIU" ) //grid do folder

	cCliente := oModelFld:GetValue("DIU_CODCLI")
	cLoja	  := oModelFld:GetValue("DIU_LOJCLI")
	
	// Verifica se o cliente e Loja estão preenchidos
	If !Empty( cCliente ) .AND. !Empty( cLoja )
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		lRet :=  SA1->(dbSeek(FwxFilial("SA1")+ cCliente + cLoja)) // Valida se os dados do cliente existem na tabela SA1
	
		If !lRet 
			Help(" ",1,"TMSA02416") //-- Cliente e Loja não encontrados.	
		EndIf
		
	EndIf
	
EndIf

RestArea(aAreaSa1)
RestArea(aArea)

Return lRet
