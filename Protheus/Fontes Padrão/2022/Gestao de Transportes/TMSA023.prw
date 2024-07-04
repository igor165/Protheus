#Include 'Protheus.ch'
#Include "FWMVCDEF.CH"
#Include 'TMSA023.ch'

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
TMSA023
Description
Cadastro Area de Restricao
@owner lucas.brustolin
@author lucas.brustolin
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

Function TMSA023()

Local oBrowse	:= Nil				// Recebe o objeto do Browse

Private aRotina   	:= MenuDef()	// Recebe as Rotinas do MenuDef

//-- Validação Do Dicionário Utilizado
If !AliasInDic("DIR") 
	MsgNextRel()	//-- É Necessário a Atualização Do Sistema Para a Expedição Mais Recente
	Return()
EndIf

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DIR")
oBrowse:SetDescription(STR0001) 	// "Cadastro Area de Restricao"
oBrowse:SetCacheView(.F.)
oBrowse:Activate()

Return Nil 

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Modelo de dados
@owner lucas.brustolin
@author lucas.brustolin
@since 24/07/2014
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

Local oStruDIR 	:= NIL        // Recebe a Estrutura da Tabela Area de Restricao
Local oStruRTA 	:= NIL		  // Recebe a Estrutura da Tabela Virtual - DefStrModel  
Local oStruDIS 	:= NIL        // Recebe a Estrutura da Tabela Restricao por CEP                            
Local oStruDIT 	:= NIL        // Recebe a Estrutura da Tabela Restricao por Rota
Local oModel   	:= NIL        // Objeto do Model

Local aRelacDIS	:= {}
Local aRelacDIT	:= {}

Local bPosValid 	:= { |oModel| PosVldMdl(oModel) }

// Validacoes da Grid
Local bLinePost	:= { |oModelGrid, nLinha| TMSA023LOK(oModelGrid, nLinha) }
//---------------------------+
// CRIA ESTRUTRA PARA oModel |
//---------------------------+
oStruDIR := FWFormStruct( 1, 'DIR' )
oStruRTA := FWFormModelStruct():New()
oStruDIS := FWFormStruct( 1, 'DIS' )
oStruDIT := FWFormStruct( 1, 'DIT' )

oStruRTA:AddTable("RTA",{},STR0010) //'Carrega CEP por Rota'

LoadStrRTA( oStruRTA )

oModel := MPFormModel():New ( "TMSA023",, bPosValid,, /*bCancel*/ )

oModel:SetDescription(STR0001) // "Cadastro da Area de Restricao"

// ------------------------------------------+
// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
// ------------------------------------------+
oModel:AddFields( 'MdFieldDIR',, oStruDIR )
oModel:AddFields( 'MdFieldRTA','MdFieldDIR', oStruRTA,,, {|| } )
oModel:AddGrid( 'MdGridDIS', 'MdFieldDIR', oStruDIS, /*bLinePre*/, bLinePost, /*bPre*/ , /*bPost*/, /*bLoad*/)
oModel:AddGrid( 'MdGridDIT', 'MdFieldDIR', oStruDIT,/*bLinePre*/, bLinePost, /*bPre*/ , /*bPost*/, /*bLoad*/)

// ----------------------------------------------------+
// NÃO GRAVA DADOS DE UM COMPONENTE DO MODELO DE DADOS |
// ----------------------------------------------------+
oModel:GetModel( 'MdFieldRTA' ):SetOnlyQuery ( .T. ) 

// -------------------------------------+
// DEFINE SE O CAMPONENTE E OBRIGATORIO |
// -------------------------------------+
oModel:GetModel( 'MdGridDIS' ):SetOptional( .T. )
oModel:GetModel( 'MdGridDIT' ):SetOptional( .T. )

// -------------------------------------------------+
// FAZ RELACIONAMENTO ENTRE OS COMPONENTES DO MODEL |
// -------------------------------------------------+
aAdd(aRelacDIS,{ 'DIS_FILIAL'	, 'xFilial( "DIS" )'	})
aAdd(aRelacDIS,{ 'DIS_CODARE'	, 'DIR_CODARE' 		})

aAdd(aRelacDIT,{ 'DIT_FILIAL'	, 'xFilial( "DIT" )'	})
aAdd(aRelacDIT,{ 'DIT_CODARE'	, 'DIR_CODARE' 		})

oModel:SetRelation( 'MdGridDIS', aRelacDIS , DIS->( IndexKey( 1 ) )  )
oModel:GetModel('MdGridDIS'):SetUniqueLine( { "DIS_CEPINI","DIS_CEPFIM"} )  
oModel:SetRelation( 'MdGridDIT', aRelacDIT , DIT->( IndexKey( 1 ) )  )
oModel:GetModel('MdGridDIT'):SetUniqueLine( { "DIT_ROTA"} )  

oModel:GetModel ( 'MdFieldDIR' )
oModel:SetPrimaryKey( { "DIR_FILIAL","DIR_CODARE" } )

oModel:SetActivate( )

Return (oModel)

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Exibe browse de acordo com a estrutura 
@owner lucas.brustolin
@author lucas.brustolin
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
Local oView      	:= NIL			// Recebe o objeto da View
Local oModel     	:= NIL			// Objeto do Model 
Local oStruDIR		:= NIL			// Recebe a Estrutura da Tabela Area de Restrição
Local oStruRTA		:= NIL			// Recebe a Estrutura da Tabela Virtual - 
Local oStruDIS   	:= NIL			// Recebe a Estrutura da Tabela Restricao por CEP
Local oStruDIT   	:= NIL			// Recebe a Estrutura da Tabela Restricao por Rota

oModel		:= FwLoadModel( "TMSA023" )

oStruDIR	:= FWFormStruct( 2, 'DIR' )
oStruRTA  	:= FWFormViewStruct():New() 
oStruDIS 	:= FWFormStruct( 2, 'DIS') 

oStruDIT 	:= FWFormStruct( 2, 'DIT') 

// Realiza a criação da estrutura com os campos que receberão as informações de pesquisa
LoadStrRTA( oStruRTA, .T. )

oView := FwFormView():New()
oView:SetModel(oModel)

//----------------------------+
// REMOVE CAMPOS DA ESTRUTURA |
//----------------------------+
oStruDIS:RemoveField('DIS_FILIAL')
oStruDIS:RemoveField('DIS_CODARE')
oStruDIT:RemoveField('DIT_FILIAL')
oStruDIT:RemoveField('DIT_CODARE')

//-------------------------------------------+
// ATRIBUI UM COMPONENTE PARA CADA ESTRUTURA |
//-------------------------------------------+
oView:AddField( 'VwFieldDIR' , oStruDIR , 'MdFieldDIR' )
oView:AddField( 'VwFieldRTA' , oStruRTA , 'MdFieldRTA' )
oView:AddGrid ( 'VwGridDIS'  , oStruDIS , 'MdGridDIS' )
oView:AddGrid ( 'VwGridDIT'  , oStruDIT , 'MdGridDIT' )

//------------------------------------------------+
// REALIZA AUTOPREENCHIMENTO PARA OS CAMPOS ITENS |
//------------------------------------------------+
oView:AddIncrementField('VwGridDIS','DIS_ITEM')
oView:AddIncrementField('VwGridDIT','DIT_ITEM')

//-------------------------------------------+
// DEFINE EM % A DIVISAO DA TELA, HORIZONTAL |
//-------------------------------------------+
oView:CreateHorizontalBox( 'TOPO'   , 20 )
oView:CreateHorizontalBox( 'FOLDER' , 80 )

//-------------------------+
// DEFINE FOLDER PARA TELA |
//-------------------------+
oView:CreateFolder( "PASTA", "FOLDER" )
oView:AddSheet( "PASTA", "ABA01", STR0007 ) //"CEP" 
oView:AddSheet( "PASTA", "ABA02", STR0008 ) //"ROTA"

oView:CreateHorizontalBox( "TAB_DIS_1"  , Iif(INCLUI .OR. ALTERA,25,0),,,"PASTA","ABA01" )
oView:CreateHorizontalBox( "TAB_DIS_2"  , 75,,,"PASTA","ABA01" )
oView:CreateHorizontalBox( "TAB_DIT"    , 100,,,"PASTA","ABA02" )

// Liga a identificacao do componente
oView:EnableTitleView ('VwFieldDIR', STR0009)	// 'Area de Restrição'
oView:EnableTitleView ('VwFieldRTA', STR0010)	// 'Carrega CEP por Rota'
oView:EnableTitleView ('VwGridDIS'	, STR0011)	// 'Restrição por CEP'
oView:EnableTitleView ('VwGridDIT'	, STR0012)	// 'Restrição por Rota'

// Cabecalho - Area de Restricoes
oView:SetOwnerView( 'VwFieldDIR' , 'TOPO' )

// Folder 1 - Campos para pesquisa de ROTA
oView:SetOwnerView( 'VwFieldRTA' , 'TAB_DIS_1' )

// Folder 1 - Inclusao de botão via OtherObject
oView:AddOtherObject("OTHER_PANEL1", {|oPanel| InsButton(oPanel)})
oView:SetOwnerView("OTHER_PANEL1",'TAB_DIS_1')

// Folder 1 - Grid Restricoes por CEP
oView:SetOwnerView( 'VwGridDIS' , 'TAB_DIS_2' )

// Folder 2 - Grid Restricoes por Rota
oView:SetOwnerView( 'VwGridDIT' , 'TAB_DIT' )

//Habilita o novo Grid

//Grid DIS
oView:SetViewProperty("VwGridDIS", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDIS", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDIS", "GRIDSEEK", {.T.})

//Grid DIT
oView:SetViewProperty("VwGridDIT", "ENABLENEWGRID")
oView:SetViewProperty("VwGridDIT", "GRIDFILTER", {.T.}) 
oView:SetViewProperty("VwGridDIT", "GRIDSEEK", {.T.})


Return ( oView )
//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Inclui botoes no PANEL
@owner lucas.brustolin
@author lucas.brustolin
@since 25/07/2014
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
Static Function InsButton( oPanel )
// + ---------------------------------------------------------------------------+
// + ANCORAMOS OS OBJETOS NO oPANEL PASSADO - DENTRO DO HORIZONTALBOX TAB_DIS_1 |
// + OBS: O ALINHAMENTO DEVE SER FEITO COM ALIGN E AS COORDENADAS 000,000       |
// + ---------------------------------------------------------------------------+

Local oSize := FwDefSize():New( .T.)
Local nLin := -6
Local nCol := 150

oSize:AddObject( "CAB" , 100, 20, .T., .T. ) // enchoice
oSize:AddObject( "CEP", 100, 20, .T., .T.  ) // enchoice
oSize:AddObject( "GRID", 100, 60, .T., .T. ) // enchoice
oSize:lProp := .T.
oSize:lLateral  := .T.
oSize:Process()

@ oSize:GetDimension("CEP","LININI") + nLin ,oSize:GetDimension("CEP","COLINI") + nCol  Button STR0013 	Size 40, 11 Message STR0013		Pixel; // "Adicionar"
	Action  AddCepGrid() of oPanel
		
Return
//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
MenuDef
Description
MenuDef com as rotinas do Browse
@owner lucas.brustolin
@author lucas.brustolin
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
Static Function MenuDef()

Private aRotina := {}

ADD OPTION aRotina TITLE STR0002 	ACTION "PesqBrw"         OPERATION 1 ACCESS 0  DISABLE MENU		//"Pesquisar"
ADD OPTION aRotina TITLE STR0003 	ACTION "VIEWDEF.TMSA023" OPERATION 2 ACCESS 0  DISABLE MENU		//"Visualizar"
ADD OPTION aRotina TITLE STR0004 	ACTION "VIEWDEF.TMSA023" OPERATION 3 ACCESS 0  					//"Incluir"
ADD OPTION aRotina TITLE STR0005 	ACTION "VIEWDEF.TMSA023" OPERATION 4 ACCESS 0  DISABLE MENU		//"Alterar"
ADD OPTION aRotina TITLE STR0006 	ACTION "VIEWDEF.TMSA023" OPERATION 5 ACCESS 0  DISABLE MENU		//"Excluir"

Return ( aRotina )  


//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
Description
Funcao de validacao da model (compatibilizacao)
@owner lucas.brustolin
@author lucas.brustolin
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
Static Function PosVldMdl(oMdl)

	Local lRet 		:= .T.
	Local nOperation	:= oMdl:GetOperation()
	Local cCodArea	:= FWFldGet("DIR_CODARE")
	Local nTotReg		:= 0
	Local cAliasTmp	:= GetNextAlias()
	Local bQuery		:= {|| Iif(Select(cAliasTmp) > 0, (cAliasTmp)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F.,.T.), dbSelectArea(cAliasTmp), (cAliasTmp)->(dbEval({|| nTotReg++ })), (cAliasTmp)->(dbGoTop())  }
	Local cCodRegs	:= ""


	If oMdl <> Nil
	
		IF nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

			// VALIDA A DIGITACAO DE PELO MENOS UM FOLDER.	
			lRet := TMSA023TOK(oMdl)

		ElseIf nOperation == MODEL_OPERATION_DELETE // Exclusão
	
			//-- Testa Se o Código De Área Está Em Uso Na Tabela DIU (Regras De Restrição)	
			cQuery := " SELECT	DISTINCT DIU.DIU_CODREG "
			cQuery += " FROM		" + RetSqlName("DIU") + " DIU "
			cQuery += " WHERE		DIU.DIU_FILIAL	=	'" + xFilial("DIU")	+ "' "
			cQuery += " AND		DIU.DIU_CODARE	=	'" + cCodArea		  	+ "' "
			cQuery += " AND		DIU.D_E_L_E_T_	=	' ' "

			Eval(bQuery)
			
			If nTotReg > 0

				DbSelectArea(cAliasTmp)
				While !(cAliasTmp)->(Eof())

					cCodRegs += Iif( !Empty(cCodRegs) , "," , "") + (cAliasTmp)->DIU_CODREG

					(cAliasTmp)->(DbSkip())
				EndDo
				(cAliasTmp)->(DbCloseArea())
				
				Help(" ",1,"TMSA02308",, STR0023 + cCodRegs ,1,0) // "Área De Restrição Em Uso Pela(s) Regra(s) De Restrição: "
				lRet := .F.
			
			EndIf
		Endif
	Endif

Return lRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
TMS023SX7
Description
Gatilho para atualização do campo RTA_DESC
@owner lucas.brustolin
@author lucas.brustolin
@since 28/07/2014
@param Params
@return cRet = Retorno com a descricao da Rota
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function TMS023SX7(oModel,cField,cValue,nLine)

Local cRet			:= ""
		
	cRet	  := Posicione('DA8',1,xFilial('DA8') + cValue, 'DA8_DESC')

Return( AllTrim(cRet) ) 	
//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
AddCepGrid
Description
Adiciona/Carrega Grid Restricoes por CEP
@owner lucas.brustolin
@author lucas.brustolin
@since 31/07/2014
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
Static Function AddCepGrid()

Local oModel	:= FWModelActive()
Local oView 	:= FWViewActive()
Local oGridDIS	:= oModel:GetModel('MdGridDIS')
Local oGridRTA	:= oModel:GetModel('MdFieldRTA')
Local cCodRota	:= oGridRTA:GetValue('RTA_XROTA')
Local cCodArea	:= FWFldGet("DIR_CODARE")
Local cCepIni	:= ""
Local cCepFim	:= ""
Local aCepDeAte	:= A023CepRot(cCodRota)
Local nLinhaDIS := 0
Local lRet		:= .T.
Local nCount	:= 0

For nCount := 1 To Len(aCepDeAte)
	
	If !Empty(aCepDeAte[nCount][1]) .And. !Empty(aCepDeAte[nCount][2])
		cCepIni := aCepDeAte[nCount][1]
		cCepFim	:= aCepDeAte[nCount][2]	
		// -------------------------------------------+
		// Adiciona os CEPs na Grid Restricoes por CEP| 
		// -------------------------------------------+			
		
		If lRet	.AND.  VldLinDIS(oGridDIS,cCepIni,cCepFim,cCodArea,0,.F.)
					
			nLinhaDIS  := oGridDIS:Length()
	       
			If oGridDIS:Length() > 1 .Or. ( oGridDIS:Length() = 1 .And. !Empty(oGridDIS:GetValue('DIS_CEPINI')) .And. ;
				 !Empty(oGridDIS:GetValue('DIS_CEPFIM')))
				
				nLinhaDIS := oGridDIS:AddLine()	
				
			EndIf
			
			oGridDIS:GoLine( nLinhaDIS )
								
			oGridDIS:SetValue('DIS_CEPINI', cCepIni)
			oGridDIS:SetValue('DIS_CEPFIM', cCepFim)

		EndIf				
	EndIf
	
	oView:Refresh()
	
Next nCount

// ------------------------------------------+
// Limpa os campos Rota e Descricao apos add |
// ------------------------------------------+	
oGridDIS:GoLine( 1 )
oView:Refresh()
oGridRTA:SetValue('RTA_XROTA','')
oGridRTA:SetValue('RTA_XDESC','') 

Return


//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
A023CepRot
Description
Retorna CepDe e CepAte de determinada Rota 
@owner lucas.brustolin
@author lucas.brustolin
@since 28/07/2014
@param cCodRota = Codigo da Rota
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function A023CepRot(cCodRota,lObrigat)
	
Local cQuery 		:= ""				// Recebe a Query
Local cAliasDA7		:= GetNextAlias()	// Recebe o Proximo Alias Disponivel
Local cCepIni		:= ""				// Recebe o CEP inicial
Local cCepFim		:= ""				// Recebe o CEP Final
Local aRet			:= {}				// Recebe o Retorno

Default cCodRota	:= ""				// Recebe o codigo da Rota		
Default lObrigat	:= .F.				// Recebe se deve trazer somente as faixas com passagem obrigatoria
// + ------------------------------------------------+
// + BUSCA O RANGE DE CEP A PARTIR DO CODIGO DA ROTA | 
// + ------------------------------------------------+

If !Empty(AllTrim(cCodRota))
	//-----------------------------------+
	// TRATAMENTO PARA TABELA TEMPORARIA |
	// ----------------------------------+
	If Select(cAliasDA7) > 0
		DbSelectArea(cAliasDA7)
		cAliasDA7->( DbCloseArea() )	
	EndIf	

	cQuery := ""
	cQuery +=" SELECT   DA7.DA7_CEPDE,"
	cQuery +="	       DA7.DA7_CEPATE,"
	cQuery +="	       DA7.DA7_PERCUR,"
	cQuery +="	       DA7.DA7_ROTA,"
	cQuery +="	       DA7.DA7_SEQUEN,"
	cQuery +="     	   DA9.DA9_ROTEIR,"
	cQuery +="	       DA9.DA9_SEQUEN,"
	cQuery +="	       DA9.DA9_PERCUR,"
	cQuery +="	       DA9.DA9_ROTA,"
	cQuery +="	       DA8.DA8_COD,"
	cQuery +="	       DA8.DA8_DESC,"
	cQuery +="	       DA8.DA8_SERTMS"
	cQuery +=" FROM   "+RetSqlName("DA7")+" DA7"
	cQuery +="	 INNER JOIN "+RetSqlName("DA9")+" DA9"
	cQuery +="	     ON DA9.DA9_FILIAL = '"+ xFilial("DA9") +"'"
	cQuery +="       AND DA9.DA9_PERCUR = DA7.DA7_PERCUR"
	cQuery +="	     AND DA9.DA9_ROTA = DA7.DA7_ROTA"

	cQuery +="	 INNER JOIN "+RetSqlName("DA8")+" DA8"
	cQuery +="       ON DA8.DA8_FILIAL = '"+ FwxFilial("DA8") +"'"
	cQuery +="	     AND DA8.DA8_COD = DA9.DA9_ROTEIR"

	cQuery +="	WHERE	DA7.DA7_FILIAL = '"+ FwxFilial("DA7") +"'"
	cQuery +="	 		AND DA9.DA9_ROTEIR = '"+cCodRota+"'"
	cQuery +="	        AND DA8.DA8_SERTMS IN ('1','2','3') "
	
	// Campo de Passagem Obrigatoria da Rota
	If lObrigat .AND. DA7->(ColumnPos("DA7_PEROBR")) > 0
		cQuery +="	    AND DA7.DA7_PEROBR = '1' "
	EndIf
		
	cQuery +="   		AND DA7.D_E_L_E_T_ = ' '"  
	cQuery +="	    	AND DA9.D_E_L_E_T_ = ' '"
	cQuery +="      	AND DA8.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery(cQuery)	
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDA7,.F.,.T.)	
	
	While (cAliasDA7)->( !EOF())
	
		// --------------------------------------------+
		// PEGA CEP DE / CEP ATE PARA CARREGAR NA GRID |
		// --------------------------------------------+
		cCepIni  := (cAliasDA7)->DA7_CEPDE
		cCepFim  := (cAliasDA7)->DA7_CEPATE			
		
		AADD(aRet,{cCepIni,cCepFim})
		cCepIni  := "" 
		cCepFim  := ""
		
		(cAliasDA7)->( DbSkip() )
	EndDo
	// FECHA TABELA TEMPORARIA	
	(cAliasDA7)->( DbCloseArea() )	
			
EndIf
	

Return aRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
TMSA023TOK
Description
VALIDA A DIGITACAO DE PELO MENOS UM FOLDER 
@owner lucas.brustolin
@author lucas.brustolin
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
Static Function TMSA023TOK( oModel )
Local lRet   		:= .T.
Local oModelDIS		:= oModel:GetModel("MdGridDIS")
Local oModelDIT		:= oModel:GetModel("MdGridDIT")

// --------------------------------------------+
// VALIDA A DIGITACAO DE PELO MENOS UM FOLDER  |
// --------------------------------------------+
If	( oModelDIS:Length(.T.) == 0 .OR. oModelDIS:IsEmpty() ) .AND. (oModelDIT:Length(.T.) == 0 .OR. oModelDIT:IsEmpty())
	Help(" ",1,"TMSA02302",,STR0020,1,0) // "É obrigatório o preenchimento de pelo menos uma pasta."
	lRet := .F.
EndIf

// Valida o Grid de CEP
If lRet
 lRet := TMSA023LOK(oModelDIS, oModelDIS:GetLine())
EndIf

// Valida o Grid de Rota
If lRet
	lRet :=  TMSA023LOK(oModelDIT, oModelDIT:GetLine())
EndIf

Return(lRet)


//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
TMSA023LOK
Description
 Valida‡Æo de Linha do Grid
@owner paulo.henrique
@author paulo.henrique
@since 30/12/2014
@param Params
	oModelGrid = Modelo do Grid
	nLinha	   = Linha posicionada no Grid
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Function TMSA023LOK(oModelGrid, nLinha)
Local lRet     	:= .T.			// Recebe o Retorno
Local aArea    	:= GetArea()	// Recebe a Area Posicionada
Local cCepIni   := ""			// Recebe o Cep Inicial
Local cCepFim  	:= ""  			// Recebe o Cep Final
Local cCodArea	:= ""  			// Recebe o Codigo da Area

Default oModelGrid   := NIL
Default nLinha	     := 0

oModelGrid:GoLine(nLinha)

If oModelGrid:cId  == "MdGridDIS"        

	//-- Nao avalia linhas deletadas
	If  !oModelGrid:IsDeleted()
						
		//-- Recupera valor dos campos
		cCepIni   	:= oModelGrid:GetValue('DIS_CEPINI',nLinha)
		cCepFim		:= oModelGrid:GetValue('DIS_CEPFIM',nLinha)
		cCodArea	:= oModelGrid:GetValue('DIS_CODARE',nLinha)
		
		lRet := VldLinDIS(oModelGrid,cCepIni,cCepFim,cCodArea,nLinha,.T.)
	EndIf
	
EndIf
RestArea(aArea)
Return lRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
VldLinDIS
Description
 Valida‡Æo das Informações dos CEPS
@owner paulo.henrique
@author paulo.henrique
@since 30/12/2014
@param Params
	oModelGrid = Modelo do Grid DIS
	cCepIni	   = Cep Inicial
	cCepFim	   = Cep Final
	cCodArea   = Codigo da Area
	nLinha	   = Linha do registro no Grid
	lExibMsg   = Condição de Exibição de Msgs na tela
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function VldLinDIS(oModelGrid,cCepIni,cCepFim,cCodArea,nLinha,lExibMsg)
Local aArea    	:= GetArea()  // Recebe a Area Atual
Local lRet     	:= .T.		  // Recebe o Retorno
Local nCount	:= 0		  // Recebe o Contador

Default oModelGrid   := NIL
Default cCepIni		 := ""
Default cCepFim		 := ""
Default cCodArea	 := ""
Default nLinha		 := 0
Default lExibMsg     := .T.

aSaveLines  := FWSaveRows()

oModelGrid:GoLine(0)

If oModelGrid:cId  == "MdGridDIS"        
	
	If !Empty(cCepIni) .AND. !Empty(cCepFim) 
		// ---------------------------------------------+
		// BLOCO DE VALIDACAO - GRID RESTRICOES POR CEP |
		// ---------------------------------------------+
		
		//-- Valida CEP De - Ate
		If cCepIni > cCepFim
			If lExibMsg
				Help("",1,'TMSA02303',,STR0016,1,0)//-- 'Cep final deve ser maior que o Cep inicial.'
			EndIf
			lRet := .F.
		EndIf
	  
		If lRet
			// Valida itens no GRID 
			For nCount := 1 To oModelGrid:Length()
				
				If  ( ( cCepIni >= oModelGrid:GetValue("DIS_CEPINI",nCount) .And. cCepIni <= oModelGrid:GetValue("DIS_CEPFIM",nCount) ) .OR. ;
					( cCepFim >= oModelGrid:GetValue("DIS_CEPINI",nCount) .And. cCepFim <= oModelGrid:GetValue("DIS_CEPFIM",nCount ) ) ) .AND. ;
					 !oModelGrid:IsDeleted(nCount) .AND.  Iif(nLinha > 0, nLinha != nCount, .T.)
				
					If lExibMsg
						Help(" ",1,"TMSA02304",,STR0019,1,0) //-- "Cep já cadastrado em um intervalo."
					EndIf 
					
					lRet := .F.  
					
					Exit
				EndIf
				
				If lRet .AND. ( ( oModelGrid:GetValue("DIS_CEPINI",nCount)  >= cCepIni .And. oModelGrid:GetValue("DIS_CEPINI",nCount) <= cCepFim ) .OR. ;
					( oModelGrid:GetValue("DIS_CEPFIM",nCount ) >= cCepIni .And. oModelGrid:GetValue("DIS_CEPFIM",nCount ) <= cCepFim ) ) .AND. ;
					 !oModelGrid:IsDeleted(nCount) .AND. Iif(nLinha > 0, nLinha != nCount, .T.)
				
					If lExibMsg
						Help(" ",1,"TMSA02305",,STR0017,1,0) //-- "Este intervalo já possui CEPs cadastrados."
					EndIf 
					
					lRet := .F.  
					
					Exit
				EndIf
				
				
			Next nCount	
			
			//-- Verifica se o intervalo ja foi cadastrado - Banco de dados
			If lRet .And. QRYCepIntr(cCepIni,cCepFim,cCodArea)
				If lExibMsg	
					Help(" ",1,"TMSA02306",,STR0018,1,0) //-- 'Todo ou parte do intervalo de CEP já consta cadastrado.'
				EndIf
				lRet := .F.
			EndIf
			
		EndIf
	ElseIf (Empty(cCepIni) .AND. !Empty(cCepFim)) .Or. (!Empty(cCepIni) .AND. Empty(cCepFim)) 
		Help(" ",1,"TMSA02307",,STR0022,1,0) //-- "Preencha o CEP Inicial e o CEP Final." 
		lRet := .F.
	EndIf	
EndIf 	
FWRestRows( aSaveLines ) 
RestArea(aArea)
Return lRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
QRYCepIntr
Description
Verifica no BD se o ( CEP Inicial/Final Digitado ) consta cadastrado.
Verifica no BD se o intervalo consta cadastrado.
@owner paulo.henrique
@author paulo.henrique
@since 23/12/2014
@param cCepIni  = CEP Inicial. 
	   cCepFim  = CEP Final
	   cCodArea = Codigo da Area
	   cItem    = Item da Area
@return lRet = .T. Se o CEP ou Intervalo consta cadastrado. 
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------
Static Function QRYCepIntr(cCepIni,cCepFim,cCodArea)
Local cQuery		:= ""				// Recebe a Query
Local lRet			:= .F.				// Recebe o Retorno
Local cAliasDIS		:= GetNextAlias()	// Recebe o Proximo Alias Disponivel 

Default cCepIni		:= ""				// Recebe o CEP Inicial
Default cCepFim		:= ""				// Recebe o CEP Final 
Default cCodArea	:= ""				// Recebe o Codigo da Area


If !Empty(cCodArea) .AND.  !Empty(cCepIni) .AND. !Empty(cCepFim)
	
	cQuery := "SELECT COUNT(*) AS QTDDIS FROM "
	cQuery += RetSQlName("DIS") + " DIS "
	cQuery += "WHERE "
	cQuery += "DIS_FILIAL = '"+xFilial("DIS")+"' "
	cQuery += " AND DIS_CODARE <> '"+ cCodArea +" ' AND ( "
	
	// Verifica se o CEP Final e Inicial já existem em alguma faixa de CEP
	cQuery += " ( ('"+cCepIni+"'  >= DIS_CEPINI  "
	cQuery += " AND  '"+cCepIni+"'  <= DIS_CEPFIM )"

	cQuery += " OR "

	cQuery += " ('"+cCepFim+"'  >= DIS_CEPINI  "
	cQuery += " AND  '"+cCepFim+"'  <= DIS_CEPFIM ) )"
	
	cQuery += " OR "
	
	// Verifica se a Faixa de CEP já possui algum CEP Cadastrado
	cQuery += " ( ( DIS_CEPINI  >=  '"+cCepIni+"'"
	cQuery += " AND  DIS_CEPINI <=  '"+cCepFim+"'  )"

	cQuery += " OR "

	cQuery += " ( DIS_CEPFIM >= '"+cCepIni+"'"  "
	cQuery += " AND  DIS_CEPFIM  <= '"+cCepFim+"' ) )"

	
	cQuery += " ) AND DIS.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasDIS,.F.,.T.)
	If	(cAliasDIS)->QTDDIS > 0
		lRet := .T.
	EndIf
	(cAliasDIS)->(dbCloseArea())
		
EndIf

Return lRet

//+--------------------------------------------------------------------------
/*/{Protheus.doc} 
LoadStrRTA
Description
Realiza a criação de campos para uma estrutura específica.
@owner lucas.brustolin
@author lucas.brustolin
@since 05/08/2014
@param Params
	oPar1  --> Objeto com a estrutura dos dados para alteração
		a passagem deve ocorrer por parametro
	lPar1  --> indica qual tipo de estrutura carregar
		-----> .T. = Model (Default)
		-----> .F. = View
@return Returns
@sample Samples
@project Projects
@menu Menu
@version Version
@obs Obs
@history History
/*/
//+--------------------------------------------------------------------------

Static Function LoadStrRTA(oStruct, lView)
Local aArea    := GetArea()
Local bValid   := { ||.T. }
Local bWhen    := { || }
Local bRelac   := { || }
Local aTamSX3  := {}

DEFAULT lView := .F.

//-------------------------------+
// lView = .T. - Estrutura Model |
//-------------------------------+
If !lView

aTamSX3 := TamSX3("DIT_ROTA")

	
	// RTA_ROTA - CODIGO DA ROTA 
	oStruct:AddField( ;
	                STR0008         		, ;		// [01] Titulo do campo   	// Rota
	                STR0008         		, ;     // [02] ToolTip do campo 	// Rota
	                "RTA_XROTA" 			, ;     // [03] Id do Field
	                'C'               		, ;     // [04] Tipo do campo
	                aTamSX3[01] 		, ;     // [05] Tamanho do campo
	                0                 		, ;     // [06] Decimal do campo
	                NIL         	   		, ;    	// [07] Code-block de validação do campo
	                Nil	          			, ;    	// [08] Code-block de validação When do campo
	                Nil             	 	, ;    	// [09] Lista de valores permitido do campo
	                Nil               		, ;     // [10] Indica se o campo tem preenchimento obrigatório
	                Nil               		, ;     // [11] Code-block de inicializacao do campo
	                Nil               		, ;    	// [12] Indica se trata-se de um campo chave
	                .F.               		, ;     // [13] Indica se o campo pode receber valor em uma operação de update.
	                .T.     )          				// [14] Indica se o campo é virtual
	                
	// RTA_DESC - DESCRIÇÃO DA ROTA                 
	oStruct:AddField( ;
	                STR0021 				, ;     // [01] Titulo do campo 	//"Praca Princ."
	                STR0021					, ;     // [02] ToolTip do campo 	//"Praca Princ."
	                "RTA_XDESC" 			, ;     // [03] Id do Field
	                'C'             	  	, ;     // [04] Tipo do campo
	                30                 		, ;     // [05] Tamanho do campo
	                0                 		, ;     // [06] Decimal do campo
	                Nil             		, ;     // [07] Code-block de validação do campo
	                Nil          			, ;     // [08] Code-block de validação When do campo
	                Nil              		, ;     // [09] Lista de valores permitido do campo
	                Nil               		, ;     // [10] Indica se o campo tem preenchimento obrigatório
	                Nil                		, ;     // [11] Code-block de inicializacao do campo
	                Nil               		, ;     // [12] Indica se trata-se de um campo chave
	                .F.                		, ;     // [13] Indica se o campo pode receber valor em uma operação de update.
	                .T.     )          				// [14] Indica se o campo é virtual
	                
	
	// GATILHO - RTA_ROTA                
	oStruct:AddTrigger( 		;
					'RTA_XROTA'  			, ;     // [01] Id do campo de origem
					'RTA_XDESC'  			, ;     // [02] Id do campo de destino
		 			{ || .T. } 				, ; 	// [03] Bloco de codigo de validação da execução do gatilho
		 			{ |oModel,cField,cValue,nLine| TMS023SX7(oModel,cField,cValue,nLine) } ) // [04] Bloco de codigo de execução do gatilho
		 

Else
//------------------------------+
// lView = .F. - Estrutura View |
//------------------------------+	
		
	// RTA_ROTA - CODIGO DA ROTA 
	oStruct:AddField( ;
					"RTA_XROTA"				, ;    	// [01] Campo
					"01"           			, ;    	// [02] Ordem
					STR0008          		, ;    	// [03] Titulo   	// Rota
					STR0008         		, ;   	// [04] Descricao	// Rota
					Nil	            		, ;   	// [05] Help
					"GET"           		, ;    	// [06] Tipo do campo   COMBO, Get ou CHECK
					"@!"        			, ;    	// [07] Picture
							         		, ;  	// [08] PictVar
					"DA8"			  		, ;		// [09] F3
					.T. 	 		  		, ;    	// [10] Editavel
						            		, ;    	// [11] Folder
					  	           			, ;    	// [12] Group
						 			 		, ;    	// [13] Lista Combo
						            		, ;    	// [14] Tam Max Combo
						         	  		, ;    	// [15] Inic. Browse
					.T.     )				 		// [16] Virtual	

	// RTA_DESC - DESCRIÇÃO DA ROTA 
	oStruct:AddField( ;
					"RTA_XDESC"		  		, ;    	// [01] Campo
					"02"            		, ;    	// [02] Ordem
					STR0021  				, ;    	// [03] Titulo 		//"Praca Princ."
					STR0021					, ; 	// [04] Descricao		//"Praca Princ."
					Nil	            		, ;   	// [05] Help
					"GET"           		, ;    	// [06] Tipo do campo   COMBO, Get ou CHECK
					"@!"        	  		, ;    	// [07] Picture
							         		, ;  	// [08] PictVar
					""  			  		, ;		// [09] F3
					.F. 	 		  		, ;    	// [10] Editavel
						            		, ;    	// [11] Folder
					  	           			, ;    	// [12] Group
						 			  		, ;    	// [13] Lista Combo
						            		, ;    	// [14] Tam Max Combo
						         	 		, ;    	// [15] Inic. Browse
					.T.     )				 		// [16] Virtual		 								
	
EndIf

	
RestArea( aArea )


Return
