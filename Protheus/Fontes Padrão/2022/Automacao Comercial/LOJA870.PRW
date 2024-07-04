#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'LOJA870.CH'

Static cRetCpo := ""
Static cRotina := "LOJA870" 
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA870
Cadastro de Linhas para configuracao de arquivos texto ( txt ).
@author Varejo
@since 27/05/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function LOJA870()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'MFE' )
oBrowse:SetDescription( STR0001 ) //"Cadastro de Linhas"
oBrowse:AddLegend( "MFE_TIPO=='1'", "YELLOW", STR0002)//"Cabeçalho"
oBrowse:AddLegend( "MFE_TIPO=='2'", "BLUE"  , STR0003)//"Registro"
oBrowse:AddLegend( "MFE_TIPO=='3'", "RED"   , STR0004)//"Rodape"
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Menu Funcional

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function MenuDef()     
Local aRotina        := {}  // Array de rotina

ADD OPTION aRotina TITLE STR0016 ACTION "PesqBrw"  			  OPERATION 0                         ACCESS 0 //"Pesquisar"
ADD OPTION aRotina TITLE STR0017 ACTION "VIEWDEF.LOJA870"     OPERATION MODEL_OPERATION_VIEW      ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0018 ACTION "VIEWDEF.LOJA870"     OPERATION MODEL_OPERATION_INSERT    ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0019 ACTION "VIEWDEF.LOJA870"     OPERATION MODEL_OPERATION_UPDATE    ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0020 ACTION "VIEWDEF.LOJA870"     OPERATION MODEL_OPERATION_DELETE    ACCESS 0 //"Excluir"
ADD OPTION aRotina TITLE STR0021 ACTION 'Lj870Leg' 	      OPERATION 9 ACCESS 0  //'Legenda'

Return aRotina

//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStructMFE := FWFormStruct(1,"MFE",{|cCampo| (AllTrim(cCampo) $ "MFE_CODIGO|MFE_DESCRI|MFE_TIPO|MFE_CARACT|MFE_RETSEP")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(1,"MFE",{|cCampo| !(AllTrim(cCampo) $ "MFE_FILIAL|MFE_CODIGO|MFE_DESCRI|MFE_TIPO")})// Informe que os campos do cabecalho nao devem aparecer nos itens
Local oModel := Nil  // objeto modelo

//-----------------------------------------
//Monta o modelo do formulário 
//-----------------------------------------
oModel:= MPFormModel():New("LOJA870",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
//colocar validacao da linha depois de digitar colocar aspas ""
oModel:AddFields("MFEMASTER", Nil/*cOwner*/, oStructMFE ,/*Pre-Validacao*/,{||LJ870LinOk(oModel)},/*Carga*/)

oModel:SetPrimaryKey( { "MFE_FILIAL","MFE_CODIGO","MFE_ITEM" } )

oModel:AddGrid  ('MFEGRID' , 'MFEMASTER',     oStructIt, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
                       
oModel:SetRelation( "MFEGRID", { { "MFE_FILIAL", "xFilial('MFE')" }, { "MFE_CODIGO", "MFE_CODIGO" } }, MFE->( IndexKey( 1 ) ) )
                                                                 
oModel:GetModel("MFEMASTER"):SetDescription(STR0005)//"Linhas"

oModel:GetModel("MFEGRID"  ):SetDescription(STR0006)//"Itens da Linhas"

Return oModel

//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da Visao

@author Varejo
@since 23/05/2013
@version versao
*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView        := Nil   // view do modelo
Local oModel       := FWLoadModel("LOJA870")
Local oStructMFE := FWFormStruct(2,"MFE",{|cCampo| (AllTrim(cCampo) $ "MFE_CODIGO|MFE_DESCRI|MFE_TIPO|MFE_CARACT|MFE_RETSEP")}) // Informe os campos que eu quero no cabecalho
Local oStructIt  := FWFormStruct(2,"MFE",{|cCampo| !(AllTrim(cCampo) $ "MFE_FILIAL|MFE_CODIGO|MFE_DESCRI|MFE_TIPO|MFE_CARACT|MFE_RETSEP")})// Informe que os campos do cabecalho nao devem aparecer nos itens

//-----------------------------------------
//Monta o modelo da interface do formulário
//-----------------------------------------
oView := FWFormView():New()
oView:SetModel(oModel)  
oView:AddField( "VIEWMFE" , oStructMFE, "MFEMASTER" )
oView:AddGrid (  "VIEWGMFE", oStructIt,  "MFEGRID" )

oView:AddIncrementField( 'VIEWGMFE', 'MFE_ITEM' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR', 40 )
oView:CreateHorizontalBox( 'INFERIOR', 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEWMFE' , 'SUPERIOR' )
oView:SetOwnerView( 'VIEWGMFE', 'INFERIOR' )
                               
oView:EnableTitleView( 'VIEWMFE' )
oView:EnableTitleView( 'VIEWGMFE')
                                                       	
Return oView

//-------------------------------------
/*LJ870LinOk()
Pós Valid do grid

@author Varejo
@since 26/07/2013
@return lRet
 */
//-------------------------------------
Static Function LJ870LinOk(oModel)

Local lRet       := .T.                           	//variavel que controla retorno
Local aSaveLine  := FWSaveRows()                	//armazena posicionamento atual do modelo
Local aArea      := GetArea()                    	//armazena posicionamento atual da tabela
Local nCount     := 0                           	//contador
Local cIdChave   := ''                          	// Armazena campo MFE_chave
Local cIdErro    := '' 	                       		//  Armazena campo MFE_IDERRO 
Local oModelCb   := oModel:GetModel('MFEMASTER') 	// Modelo Cabecalho
Local oModelIt   := oModel:GetModel('MFEGRID'  ) 	// Modelo Itens
Local cRegistro  := oModelCb:GetValue('MFE_TIPO')	// Pega valor do campo  
Local nErro      := 0                            	// Contador de retorno
Local nChave     := 0                            	// Contador de chave
Local aInconsist := {}				           		// Array com as Colunas Iniciais e Finais com Inconsistências de Valores
Local cCaractSep := oModelCb:GetValue('MFE_CARACT')	// Conteúdo do campo MFE_CARACT
Local cCaractRet := oModelCb:GetValue('MFE_RETSEP')	// Conteúdo do campo MFE_RETSEP
Local nI		 := 0								// Contador do For / Next
Local cItemAtu	 := ""								// Número do Item no Grid
Local nColIniAtu := 0								// Valor da coluna Inicial no Grid
Local nColFinAtu := 0								// Valor da coluna Final no Grid
Local cItemPrx	 := ""								// Número do Item no Grid
Local nColIniPrx := 0								// Valor da coluna Inicial no Grid
Local nColFinPrx := 0								// Valor da coluna Final no Grid
Local cTextoMsg	 := ""								/// Texto com itens digergentes que serão exibidos
Local nTamColIni := TamSX3("MFE_COLINI")[1]			// Tamanho do campo MFE_COLINI
Local nTamColFin := TamSX3("MFE_COLFIN")[1]			// Tamanho do campo MFE_COLFIN

For nCount := 1 To oModelIt:Length()      
	oModelIt:GoLine(nCount)
	If !oModelIt:IsDeleted()
		// Guarda os valores da linha atual
		cItemAtu	:= oModelIt:GetValue('MFE_ITEM')
		nColIniAtu	:=  oModelIt:GetValue('MFE_COLINI')
		nColFinAtu 	:= oModelIt:GetValue('MFE_COLFIN')

		// Verifica se está no ultimo item
		If nCount < oModelIt:Length()
			// Guarda os valores da próxima linha para realizar a comparação
			oModelIt:GoLine(nCount+1)
			cItemPrx	:= oModelIt:GetValue('MFE_ITEM')
			nColIniPrx	:=  oModelIt:GetValue('MFE_COLINI')
			nColFinPrx 	:= oModelIt:GetValue('MFE_COLFIN')

			// Verifica se o valor informado da coluna Final, é maior ou igual, o valor da coluna Inicial da próxima linha
			If nColFinAtu >= nColIniPrx
				// Guarda as informações no array, para apresentar ao usuário
				aadd(aInconsist, STR0022 + cItemAtu + "   -   " + STR0023 + Alltrim(Str(nColIniAtu,nTamColIni,0)) + "   -   " + STR0024 + Alltrim(Str(nColFinAtu,nTamColIni,0)))
				aadd(aInconsist, STR0022 + cItemPrx + "   -   " + STR0023 + Alltrim(Str(nColIniPrx,nTamColFin,0)) + "   -   " + STR0024 + Alltrim(Str(nColFinPrx,nTamColFin,0)))
				aadd(aInconsist,Replicate("-",70))
			EndIf
		EndIf	
	EnDif	
Next nCount  

If len(aInconsist) > 0
	cTextoMsg		:= STR0026  +  CRLF + CRLF    //"Encontradas divergências de valores, nas colunas Inicial e Final, nos seguintes Itens:"

	For nI := 1 to Len(aInconsist)
		cTextoMsg += aInconsist[nI] + CRLF
	Next nI

	Help( ,, STR0025,, cTextoMsg, 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0027})    //"Inconsistencias nas informações" #  "Necessário ajustar as informações das colunas Inicial e Final dos Itens acima." 
	lRet:= .F.	
EndIf

If cRegistro == '2' .AND. lRet
	For nCount := 1 To oModelIt:Length()      
		oModelIt:GoLine(nCount)
		cIdChave:= oModelIt:GetValue('MFE_CHAVE')
		cIdErro := oModelIt:GetValue('MFE_IDERRO')
		If !oModelIt:IsDeleted()
	    	If cIdChave == '1'
	    		nChave++
	    	EndIf 
	    	If cIdErro == '1' 
	    		nErro++	
	    	EndIf
		EndIf
	Next nCount  
	
	Do Case 
		Case nChave == 0  	
			Help( ,, 'HELP',, STR0010, 1, 0)    //"O campo chave não foi informado !"
			lRet:= .F.		
		Case nErro == 0   	
			Help( ,, 'HELP',, STR0012, 1, 0)    //"O campo chave retorno não foi informado !"
			lRet:= .F.
		Case nChave > 1
			Help( ,, 'HELP',, STR0013, 1, 0)    //"Apenas um campo deve ser chave"
			lRet:= .F.	
		Case nErro > 1
			Help( ,, 'HELP',, STR0014, 1, 0)    //"Apenas um campo deve ser chave de retorno"
			lRet:= .F.			  			  						  	
	EndCase
		
EndIf

// Realiza a atualização dos campos separados
If lRet
	For nCount := 1 To oModelIt:Length()      
		oModelIt:GoLine(nCount)
		If !oModelIt:IsDeleted()
			oModel:SetValue('MFEGRID','MFE_CARACT', cCaractSep)	
			oModel:SetValue('MFEGRID','MFE_RETSEP', cCaractRet)	
		EndIf	
	Next nCount		
EndIf

FWRestRows( aSaveLine )
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} MFEVldCpo
Valida os campos digitados na grid

@author Varejo
@since 23/05/2013
@version versao
@param  cCpo - Campo da grid
*/
//-------------------------------------------------------------------
Function MFEVldCpo(cCpo)

Local aArea  	  := MFE->(GetArea()) //armazena posicionamento atual da tabela
Local oView	  	 
Local oModel     
Local cAlias	  := ""                // Pega o valor do do MFE_ALIAS
Local cCampo      := ""                // Pega o valor do do MFE_CAMPO 
Local cTabelas    := "SB1|SA1|MFI|SL1|SL2|SL4|MFO" // Possiveis tabelas que podem ser informadas
Local cChave      := ''   // Campo chave de registro
Local cFormula    := ''  // Validacao do campo formula
Local lRet   	  := .T.    // Variavel de retorno
Local lExclui     := (!INCLUI .AND. !ALTERA)  //Condição para excluir                        
Local lAutomato := If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)

If !lAutomato
	oView	  	:= FwViewActive()   // Pega view ativa
	oModel      := oView:GetModel()  // Pega o modelo
Else
	oModel := FWModelActive()
EndIf 

//Valida se é exclucao
If lExclui
	Return lRet
EndIf
oModel 	:= oModel:GetModel('MFEGRID')   
Do Case
	Case cCpo == 'MFE_ALIAS' 	
		//-- valida se existe na sx2
		cAlias  := oModel:GetValue('MFE_ALIAS')
		If !Empty(cAlias)		
			If  !ExistCpo("SX2",cAlias)		
				lRet:=	.F.
				Alert(STR0007)//"Alias não existe"
			EndIf
			If !cAlias $ cTabelas
				Alert(STR0015)//"Alias não permitido"
				lRet:=	.F.
			EndIf
		EndIf
	
	Case cCpo == 'MFE_CAMPO'  	
		cAlias  := oModel:GetValue('MFE_ALIAS')
		
		If Empty(cAlias)
			Return lRet
		EndIf
		//-- valida se existe na sx3
		cCampo:= oModel:GetValue('MFE_CAMPO')
		If (cAlias)->(FieldPos(cCampo)) == 0
			lRet:=	.F.
			Alert(STR0008)//"Campo não existe" 
		Else   
			dbSelectArea("SX3")
			dbSetOrder(2)
			dbSeek(cCampo)   
			oModel:SetValue('MFE_DCRCPO', X3Titulo() )				
		EndIf	
	
	Case cCpo == 'MFE_CHAVE'  	
		cChave  := oModel:GetValue('MFE_CHAVE')
		If cChave == '1' 
			oModel:SetValue('MFE_FORMUL', 'Alltrim(Str(nRecno))' )
	    EndIf
	Case cCpo == 'MFE_FORMUL'    
		cFormula := Alltrim(oModel:GetValue('MFE_FORMUL'))
		If cFormula $ 'Alltrim(Str(nRecno))' .OR. "U_" $ UPPER(cFormula) .OR. ( "(" $ cFormula .AND. ")" $ cFormula )  
			oModel:SetValue('MFE_FORMUL',cFormula )
		Else
			cFormula := Alltrim(StrTran(oModel:GetValue('MFE_FORMUL'),'"',' ' ))
			oModel:SetValue('MFE_FORMUL', Iif(Empty(cFormula),"",'"'+cFormula+'"') )		
		EndIf	
EndCase


RestArea(aArea)
Return lRet


//-------------------------------------------------------------------
/* LJ870A
Efetua Consulta Especifica SX3
                  
@author  Varejo
@since   27/05/2013
@version 1.0
*/
//------------------------------------------------------------------- 
Function LJ870A()

Local aAreaAtu    := GetArea()                   	//Armazena posicionamento atual da tabela
Local aArray      := {}                           	//Opcoes de Escolha (Array de Opcoes)
Local cEntida 	  := ""                           	//alias para filtro
Local MvPar       := ""                           	//String de Opcoes para Retorno
Local mvRet       := ""                          	 	//String de Opcoes para Retorno  
Local MvParDef    := ""                          	//String de Opcoes para Retorno
Local cTitulo 	  := STR0009	//"Campos do Sistema" Titulo da Coluna com as opcoes
Local nX          := 1                          		//contador
Local nTamChave   := 0                           	//Tamanho da Chave
Local oView	  	  := FwViewActive()             	//View ativa
Local oModel      := oView:GetModel()           	//Pega o modelo

oModel 	:= oModel:GetModel('MFEGRID')   
cEntida := oModel:GetValue('MFE_ALIAS') //Seta o alias para filtro

SX3->( DbSetOrder(1) )
nTamChave:= Len(SX3->X3_CAMPO)+1
//Carrega array com a estrutura da tabela
If SX3->( DbSeek(cEntida) )
	While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == cEntida
		Aadd(aArray, SX3->X3_ARQUIVO , SX3->X3_CAMPO )
		MvParDef += SX3->X3_CAMPO+"|"
		SX3->(DbSkip())
	EndDo
EndIf 
MvPar:=&(Alltrim(ReadVar()))	// Carrega Nome da Variavel do Get em Questao
mvRet:=Alltrim(ReadVar())
	
If f_Opcoes(   	@MvPar   ,; 	//Variavel de Retorno
	cTitulo         ,;             //Titulo da Coluna com as opcoes
	aArray          ,;             //Opcoes de Escolha (Array de Opcoes)
	MvParDef        ,;             //String de Opcoes para Retorno
					,;             	//Nao Utilizado
					,;             	//Nao Utilizado
	.T.            	,;             	//Se a Selecao sera de apenas 1 Elemento por vez
	nTamChave      	,;         	//Tamanho da Chave
	9999          	,;             	//No maximo de elementos na variavel de retorno
	.F.            	,;             	//Inclui Botoes para Selecao de Multiplos Itens
	.F.            	,;             	//Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
					,;             	//Qual o Campo para a Montagem do aOpcoes
	.F.            	,;             	//Nao Permite a Ordenacao
	.F.            	,;             	//Nao Permite a Pesquisa
	.T.            	,;             	//Forca o Retorno Como Array
	""          	)				//Consulta F3
	
	For nX:=1 To Len(MvPar)
		cRetCpo:= SubStr(MvPar[nX],1,Len(MvPar[nX])-1)
	Next nX
EndIf

If !Empty(cRetCpo)
	oModel:SetValue('MFE_CAMPO',cRetCpo)
	oView:Refresh()
EndIf


RestArea( aAreaAtu )

Return .T.

//-------------------------------------------------------------------
/* LJ870B
Retorno Consulta Especifica SX3                  
@author  Varejo
@since   27/05/2013
@version 1.0
*/
//------------------------------------------------------------------- 
Function LJ870B()
Return cRetCpo

//-------------------------------------------------------------------
/* Lj870IVlIn
Funcao de retorno do Col. Inicial da linha     
@author  Varejo
@since   27/05/2013
@version 1.0
*/
//------------------------------------------------------------------- 
Function Lj870IVlIn()
Local nValor 		:= 0        //Valor de Retorno da Rotina
Local nOperation 	:= 0        //Operação do Modelo
Local nLinhas		:= 0        //Linhas do Grid de Itens
Local oModel 		:= Nil      //Modelo                          
Local oModelD  	:= Nil          //Modelo Detalhe
Local aSaveLines 	:= Nil      //Similar ao GetArea()  

If IsInCallStack(cRotina)    

	oModel := FWModelActive()
	oModelD  := oModel:GetModel( 'MFEGRID' )
	nOperation := oModel:GetOperation()
	
	If (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE) .AND. oModelD:Length(.t.) >= 1
			aSaveLines := FWSaveRows()
			
			nLinhas := oModelD:Length()
						  
			Do While nLinhas > 0
					
				oModelD:GoLine( nLinhas )
				
				If !oModelD:IsDeleted()// Deletada e não é nova, inserida
					nValor := oModelD:GetValue( 'MFE_COLFIN') 
					nLinhas := 0
				Else
					nLinhas--
				EndIf

			End
				
			
			FWRestRows( aSaveLines ) 
	EndIf
EndIf

nValor += 1/( 10 ^ TamSx3("MFE_COLINI")[2])

Return nValor 

//-------------------------------------------------------------------
/* Lj870Leg
Aciona legenda.
@author  Varejo
@since   08/04/2014
@version 1.0
*/

//------------------------------------------------------------------- 
Function Lj870Leg()

lOCAL aLegenda:={{"BR_AMARELO"  , STR0002},;//"Cabeçalho"
				{"BR_AZUL"       , STR0003},;//"Registro"
				{"BR_VERMELHO"   , STR0004}}//"Rodape"					

BrwLegenda(STR0001,STR0021,aLegenda)//"Cadastro de Linhas"###"Legenda"
	      

Return Nil

