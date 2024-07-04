#include "PROTHEUS.ch"
#Include "FWMVCDEF.CH"
#Include "TMSAF16.CH"


Static aDataMdl  := {}
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSAF16
Tela de Percursos da Viagem

Uso: TMS

@sample
//TMSAF16()

@author Paulo Henrique
@since 27/04/2017
@version 1.0	
/*/
//-------------------------------------------------------------------
Function TMSAF16()
Local oBrowse := Nil
Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DL0")
oBrowse:SetDescription(STR0001) //'Percursos da Viagem'	
oBrowse:Activate()

// Desabilita o cache do View, para que o mesmo seja sempre atualizado.
oBrowse:SetCacheView( .F. )

Return NIL


 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSAF16

@sample
//MenuDef()

@author Paulo Henrique Corrêa Cardoso.
@since 08/05/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" ACTION "VIEWDEF.TMSAF16" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE "Incluir"  ACTION "VIEWDEF.TMSAF16" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE "Alterar"  ACTION "VIEWDEF.TMSAF16" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE "Excluir"  ACTION "VIEWDEF.TMSAF16" OPERATION 5 ACCESS 0 // "Excluir"
	ADD OPTION aRotina TITLE "Copiar"  ACTION "VIEWDEF.TMSAF16" OPERATION 9 ACCESS 0 // "Copiar"

Return(aRotina)  

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Tela de Percursos da viagem

Uso: TMSAF16

@sample
//ModelDef()

@author Paulo Henrique
@since 27/04/2017
@version 1.0	
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel     := Nil                      // Recebe o objeto do Modelo
	Local oStruDL0   := FwFormStruct( 1 , "DL0") // Recebe o objeto da estrutura da tabela DL0
	Local oStruDL1   := FwFormStruct( 1 , "DL1") // Recebe o objeto da estrutura da tabela DL1 
	Local oStruDL2   := FwFormStruct( 1 , "DL2") // Recebe o objeto da estrutura da tabela DL2
	
	// Adicona o campo de Legenda
	oStruDL1:AddField(  ""			    , ; // Titulo do campo    
 						""			    , ; // ToolTip do campo 
						'DL1_LEGORI' 	, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						20	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						{||.F.}		, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||"BR_AMARELO" }, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
	
	oStruDL2:AddField(  "Seq. Pai"	    , ; // Titulo do campo    
 						""			    , ; // ToolTip do campo 
						'DL2_SEQPAI' 	, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						TamSx3('DL1_SEQUEN')[1]	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						NIL      		, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||FwFldGet("DL1_SEQUEN") }, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
	
	
	oModel := MPFormModel():New( "TMSAF16",,/*{|oModel|PosVldMdl(oModel)}*/,/*bCommit*/, /*bCancel*/ ) 
	
	// Adiciona Cabeçalho
	oModel:AddFields("MdFieldDL0",Nil,oStruDL0,/*prevalid*/,,/*bCarga*/) 
	oModel:GetModel("MdFieldDL0"):SetDescription( "CAB" )//-- "Cabeçalho"
	oModel:SetPrimaryKey({ "DL0_FILIAL","DL0_PERCUR","DL0_FILORI","DL0_VIAGEM"})
	
	// Adiciona o grid de Estados do Percurso
	oModel:AddGrid("MdGridDL1", "MdFieldDL0", oStruDL1 , {|oModelGrid,nLine,cAction| PreVldMdl(oModelGrid,nLine,cAction)} , /*bLinePost*/	 , /*bPre*/,/*bpos*/,)
	oModel:GetModel("MdGridDL1"):SetUniqueLine( { "DL1_PERCUR","DL1_SEQUEN","DL1_IDLIN"} )
	oModel:GetModel("MdGridDL1"):SetDescription( STR0002 )//-- "Estados do Percurso"
	oModel:SetRelation('MdGridDL1',{ {"DL1_FILIAL","FWxFilial('DL1')"},{"DL1_PERCUR","DL0_PERCUR"} }, DL1->( IndexKey( 5 ) ) )
	
	// Adiciona o grid de Documentos do Manifesto
	oModel:AddGrid("MdGridDL2", "MdGridDL1", oStruDL2 , /*bLinePre*/	 , /*bLinePost*/	 , /*bPre*/,/*bpos*/,)
	oModel:GetModel("MdGridDL2"):SetDescription( STR0003 )//-- "Documentos do Manifesto"
	oModel:SetRelation('MdGridDL2',{ {"DL2_FILIAL","FWxFilial('DL2')"},{"DL2_PERCUR","DL1_PERCUR"}, {"DL2_IDLIN","DL1_IDLIN"} }, DL2->( IndexKey( 1 ) ) ) 
	oModel:GetModel("MdGridDL2"):SetOptional( .T. )
	oModel:GetModel("MdGridDL2"):SetNoInsertLine(.T.)
	oModel:GetModel("MdGridDL2"):SetNoDeleteLine(.T.)
	oModel:GetModel("MdGridDL2"):SetMaxLine(9999)
	oModel:SetActivate()

Return oModel 



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da View da Tela de Percursos da viagem

Uso: TMSAF16

@sample
//ViewDef()

@author Paulo Henrique
@since 03/05/2017
@version 1.0	
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
	Local oModel     := NIL	// Objeto do Model 
	Local oView      := NIL	// Recebe o objeto da View
	Local oStruDL0   := NIL // Recebe o objeto da estrutura da tabela DL0
	Local oStruDL1   := NIL // Recebe o objeto da estrutura da tabela DL1 
	Local oStruDL2   := NIL // Recebe o objeto da estrutura da tabela DL2
	
	oModel   := FwLoadModel("TMSAF16")
	// Carrega estruturas
	oStruDL0   := FwFormStruct( 2 , "DL0",{|cCampo| !( AllTrim(cCampo)+"|" $ "DL0_USRINC|DL0_FILINC|DL0_DATINC|DL0_HORINC|" )})
    oStruDL1   := FwFormStruct( 2 , "DL1",{|cCampo| !( AllTrim(cCampo)+"|" $ "DL1_PERCUR|DL1_IDLIN|DL1_ORIGEM|DL1_MUNMAN|" ) })
	oStruDL2   := FwFormStruct( 2 , "DL2",{|cCampo| !( AllTrim(cCampo)+"|" $ "DL2_PERCUR|DL2_FILMAN|DL2_MANIFE|DL2_SERMAN|DL2_IDLIN|DL2_MUNMAN|" ) })
	
	// Adicona o campo de Legenda
	oStruDL1:AddField(	'DL1_LEGORI' , ; // Nome do Campo
				'01' 				 , ; // Ordem   
				 ""					 , ; // Titulo do campo  
				 "" 				 , ; // Descrição do campo 
				{''} 				 , ; // Array com Help
				'C' 				 , ; // Tipo do campo
				'@BMP' 				 , ; // Picture
				NIL 				 , ; // Bloco de Picture Var
				'' 					 , ; // Consulta F3
				.T. 				 , ; // Indica se o campo é evitável
				NIL 				 , ; // Pasta do campo
				NIL 				 , ; // Agrupamento do campo
				{ }					 , ; // Lista de valores permitido do campo (Combo)
				NIL 			 	 , ; // Tamanho Maximo da maior opção do combo
				"" 					 , ; // Inicializador de Browse
				.T. 				 , ; // Indica se o campo é virtual
				"" 					   ) // Picture Variável

	oStruDL2:AddField(	'DL2_SEQPAI' , ; // Nome do Campo
				'01' 				 , ; // Ordem   
				"Seq. Pai"					 , ; // Titulo do campo  
				"Seq. Pai" 				 , ; // Descrição do campo 
				{''} 				 , ; // Array com Help
				'C' 				 , ; // Tipo do campo
				'99' 				 , ; // Picture
				NIL 				 , ; // Bloco de Picture Var
				'' 					 , ; // Consulta F3
				.T. 				 , ; // Indica se o campo é evitável
				NIL 				 , ; // Pasta do campo
				NIL 				 , ; // Agrupamento do campo
				{ }					 , ; // Lista de valores permitido do campo (Combo)
				NIL 			 	 , ; // Tamanho Maximo da maior opção do combo
				"" 					 , ; // Inicializador de Browse
				.T. 				 , ; // Indica se o campo é virtual
				"" 					   ) // Picture Variável				

    oView := FwFormView():New()
    oView:SetModel(oModel)     
    
	oView:AddField('VwFieldDL0', oStruDL0 , 'MdFieldDL0') 
    oView:AddGrid( 'VwGridDL1' , oStruDL1 , 'MdGridDL1' )   
	oView:AddGrid( 'VwGridDL2' , oStruDL2 , 'MdGridDL2' )   
	
	oView:CreateHorizontalBox('CABECALHO', 20)
    oView:CreateHorizontalBox('GRID1'	 , 40)  
	oView:CreateHorizontalBox('GRID2'	 , 40)  
	
	oView:SetOwnerView('VwFieldDL0','CABECALHO')
    oView:SetOwnerView('VwGridDL1' ,'GRID1'    )
    oView:SetOwnerView('VwGridDL2' ,'GRID2'    )

	oView:EnableTitleView("VwFieldDL0" ,STR0001) // "Percurso da Viagem"
	oView:EnableTitleView("VwGridDL1"  ,STR0002) // "Estados do Percurso"
	oView:EnableTitleView("VwGridDL2"  ,STR0003) // "Documentos do Manifesto"
	
	oView:AddIncrementField('VwGridDL1','DL1_SEQUEN')
	
	//Adiciona botões de Usuario
	oView:addUserButton(STR0020, 'CLIPS', { || AF16Legend() } ) //"Legenda."

	// Adiciona a chamada da função de Reordenação.)
	oView:SetFieldAction( 'DL1_SEQUEN' , { |oView,cIdForm,cIdCampo,cValue| Af16Reord(oView,cIdForm,cIdCampo,cValue) } )
	oView:SetFieldAction( 'DL1_UF' , { |oView,cIdForm,cIdCampo,cValue| Af16CarPer(oView,cIdForm,cIdCampo,cValue) } )
	oView:SetFieldAction( 'DL2_SEQPAI' , { |oView,cIdForm,cIdCampo,cValue| Af16MovEst(oView,cIdForm,cIdCampo,cValue) } )
	// Adiciona função de duplo clique na linha do grid de estados
	oView:SetViewProperty("VwGridDL1", "GRIDDOUBLECLICK", {{ |oGrdView,cFieldName,nLineGrid,nLineModel| F16DbClick(oGrdView,cFieldName,nLineGrid,nLineModel)}}) 

	// Ações após ativação da view e do model antes da abertura da tela
	oView:SetAfterViewActivate({|oView| AfterVwAct(oView)}) 

Return oView

/*/-----------------------------------------------------------
{Protheus.doc} AfterVwAct
Ações apos a ativação da View e do Model antes de abrir a tela

Uso: TMSAF16

@sample
//AfterVwAct(oView)

@author Paulo Henrique Corrêa Cardoso.
@since 09/05/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function AfterVwAct(oView)
	Local oModel     := FwModelActive()
	Local oMdlGrdDL1 := NIL               // Recebe o Modelo do Grid de Estados
	Local nCount     := 0   

	Default oView    := FwViewActive()

	oMdlGrdDL1 := oModel:GetModel("MdGridDL1")  
	
	For nCount := 1 To oMdlGrdDL1:GetQTDLine()
	
		oMdlGrdDL1:GoLine(nCount)	
		oMdlGrdDL1:LoadValue("DL1_LEGORI",AF16Cor(oModel))

	Next nCount
	oMdlGrdDL1:GoLine(1)
	oView:Refresh("VwGridDL1")
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AF16WhnDL1
Propriedade When do Grid de Estados

Uso: TMSAF16

@sample
//AF16WhnDL1(cCampo)

@author Paulo Henrique
@since 03/05/2017
@version 1.0	
/*/
//-------------------------------------------------------------------
Function AF16WhnDL1(cCampo)
	Local lRet       := .F.             // Recebe o Retorno
	Local oModel     := FwModelActive()	// Recebe o Model Ativo
	Local oModelGrid := NIL				// Recebe o Modelo do Grid 

	Default cCampo := ReadVar()
	
	oModelGrid := oModel:GetModel( "MdGridDL1" ) //grid de Estados

	If IsInCallStack("AF16Load")
		lRet := .T.
	Else

		If cCampo $ "M->DL1_UF
			If oModelGrid:GetValue("DL1_ORIGEM") == "1"
				lRet := .T.
			EndIf
		EndIf

	EndIf
	 
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} AF16WhnDL2
Propriedade When do Grid de Documentos

Uso: TMSAF16

@sample
//AF16WhnDL2(cCampo)

@author Paulo Henrique
@since 03/05/2017
@version 1.0	
/*/
//-------------------------------------------------------------------
Function AF16WhnDL2(cCampo)
	Local lRet := .F.           // Recebe o Retorno
	
	Default cCampo := ReadVar()
	
	If IsInCallStack("AF16Load") .OR. IsInCallStack("Af16MovEst")
		lRet := .T.
	EndIf
  
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF16Load
Carrega o Modelo.

Uso: TMSAF16

@sample
// AF16Load(nOpcx,aCab,aItens)

@author Paulo Henrique
@since 03/05/2017
@version 1.0	
/*/
//-------------------------------------------------------------------
Function AF16IncPer(nOpcx,aCab,aItens,lAuto,aDelDocs)

	Local lRet        := .T.                     // Recebe a variavel logica de Retorno
	Local aRet        := {}                      // Recebe o Array de Retorno
	Local oModel      := NIL                     // Recebe o Modelo 
	Local nLnEstErr   := 0                       // Recebe a Linha com erro do grid de Estados
	Local nLnDocErr   := 0                       // Recebe a Linha com erro do grid de Documentos
	Local aErro       := {}                      // Recebe o array de erros do modelo
	Local cRetErro    := ""                      // Recebe a string de retorno de erro
	Local nExec       := 0                       // Recebe o botão da tela de Percurso
	Local nItErro     := 0                       // Recebe a linha de erro

	Default nOpcx     := MODEL_OPERATION_INSERT  // Recebe o Operation do Modelo
	Default aCab      := {}                      // Recebe o array com os dados de cabeçalho
	Default aItens    := {}                      // Recebe o array com os dados dos grids
	Default lAuto     := .F.                     // Recebe se a gravacao de ve ser via rotina automatica
	Default aDelDocs  := {}                      // Recebe o Array com os Itens deletados


	// Carrega o Modelo
	aRet := AF16Load(nOpcx,aCab,aItens,@nLnEstErr,@nLnDocErr,aDelDocs)
	
	lRet   := aRet[1]
	oModel := aRet[2]
	
	If lRet
		If lAuto
			// Valida e grava as informações.
			If (lRet := oModel:VldData())
				lRet := oModel:CommitData()
			EndIf
		Else
			nExec := FWExecView( STR0001 ,'TMSAF16',nOpcx,, { || .T. },{ || .T. },,,{ || .T. },,,oModel) //"Percursos da Viagem"
		EndIf
	EndIf
	
	If !lRet		
		// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
		aErro := oModel:GetErrorMessage()
       
		If Len(aErro) > 0 

			AutoGrLog(STR0004 + ' [' + AllToChar(aErro[1] ) + ']' ) //"Id do formulário de origem:"
			AutoGrLog(STR0005 + ' [' + AllToChar(aErro[2] ) + ']' ) //"Id do campo de origem: "
			AutoGrLog(STR0006 + ' [' + AllToChar(aErro[3] ) + ']' ) //"Id do formulário de erro: " 
			AutoGrLog(STR0007 + ' [' + AllToChar(aErro[4] ) + ']' ) //"Id do campo de erro: "
			AutoGrLog(STR0008 + ' [' + AllToChar(aErro[5] ) + ']' ) //"Id do erro: " 
			AutoGrLog(STR0009 + ' [' + AllToChar(aErro[6] ) + ']' ) //"Mensagem do erro: "
			AutoGrLog(STR0010 + ' [' + AllToChar(aErro[7] ) + ']' ) //"Mensagem da solução: "
			AutoGrLog(STR0011 + ' [' + AllToChar(aErro[8] ) + ']' ) //"Valor atribuído: " 
			AutoGrLog(STR0012 + ' [' + AllToChar(aErro[9] ) + ']' ) //"Valor anterior: "
			
			//Se o Erro ocorrer nos Estados
			If nLnEstErr > 0
				AutoGrLog(STR0013 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) //"Erro no Estado: "	
			EndIf
			//Se o Erro ocorrer nos Documentos
			If nLnDocErr > 0
				AutoGrLog(STR0014 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) //"Erro no Documento: "	
			EndIf
		EndIf	
		
		// Monta o Erro de Retorno	
		If !IsBlind()
			cRetErro := MostraErro()
			cRetErro := EncodeUTF8(cRetErro)	
		EndIf
			
	EndIf
	
	If nExec > 0
		lRet := .F.
		cRetErro := STR0015 //"Cancelado pelo Operador"
	EndIf

Return {lRet,cRetErro}

//-------------------------------------------------------------------
/*/{Protheus.doc} AF16Load
Carrega o Modelo.

Uso: TMSAF16

@sample
// AF16Load(nOpcx,aCab,aItens,nLnEstErr,nLnDocErr,aDelDocs)

@author Paulo Henrique
@since 03/05/2017
@version 1.0	
/*/
//-------------------------------------------------------------------
Static Function AF16Load(nOpcx,aCab,aItens,nLnEstErr,nLnDocErr,aDelDocs)
	Local lRet        := .T.                      // Recebe o Retorno
	Local oModel      := NIL                      // Recebe o Modelo
	Local oMdlFldDL0  := NIL                      // Recebe o Modelo do cabeçalho
	Local oMdlGrdDL1  := NIL                      // Recebe o Modelo do Grid de Estados
	Local oMdlGrdDL2  := NIL                      // Recebe o Modelo do Grid de Documentos
	Local oStrucDL0   := NIL                      // Recebe a estrutura do Cabeçalho
	Local oStrucDL1   := NIL                      // Recebe a estrutura do Grid de Estados
	Local oStrucDL2   := NIL                      // Recebe a estrutura do Grid de Documentos
	Local aFldDL0     := {}                       // Recebe o array de campos do Cabeçalho
	Local aGrdDL1     := {}                       // Recebe o array de campos do Grid de Estados
	Local aGrdDL2     := {}                       // Recebe o array de campos do Grid de Documentos
	Local nCount      := 0                        // Recebe o contador 1
	Local nCount2     := 0                        // Recebe o contador 2
	Local nCount3     := 0                        // Recebe o contador 3
	Local nCount4     := 0                        // Recebe o contador 4
	Local aDoctos     := {}                       // Recebe o array de Documentos
	Local nPosUFDL1   := 0                        // Recebe a posicao do campo DL1_UF na tabela DL1
	Local nPosUFODL1  := 0                        // Recebe a posicao do campo DL1_UFORI na tabela DL1
	Local nPosSeqDL1  := 0                        // Recebe a posicao do campo DL1_SEQUEN  na tabela DL1
	Local nLenGrdDL1  := 0                        // Recebe a o tamanho do Grid de Estados
	Local nPosFlVDL2  := 0                        // Recebe a posicao do campo DL2_FILORI na tabela DL2
	Local nPosVgeDL2  := 0                        // Recebe a posicao do campo DL2_VIAGEM na tabela DL2  
	Local nPosFDcDL2  := 0                        // Recebe a posicao do campo DL2_FILDOC na tabela DL2
	Local nPosDocDL2  := 0                        // Recebe a posicao do campo DL2_DOC na tabela DL2
	Local nPosSDcDL2  := 0                        // Recebe a posicao do campo DL2_SERIE na tabela DL2
	Local nLenGrdDL2  := 0                        // Recebe a o tamanho do Grid de Documentos
	Local nDelete     := 0                        // Recebe o contador de registros deletados
	Local lCopia      := .F.                      // Recebe se é uma copia.
	Local aLinDL1Del  := {}                       // Recebe as Linhas de estado que devem ser deletadas no final.
	
	Default nOpcx     := MODEL_OPERATION_INSERT   // Recebe a operation do Modelo
	Default aCab      := {}                       // Recebe o Array contendo os dados do cabeçalho
	Default aItens    := {}                       // Recebe o Array contendo os dados dos Grids
	Default nLnEstErr := 0                        // Recebe a Variavel de Referencia de linha com erro no grid de Estados
	Default nLnDocErr := 0                        // Recebe a Variavel de Referencia de linha com erro no grid de Documentos
	Default aDelDocs  := {}                       // Recebe o Array com os Itens deletados

	// Inicializa o Modelo
	oModel := FwLoadModel("TMSAF16") 
	

	If nOpcx == 9 // Copia
		oModel:SetOperation(3)
		oModel:Activate(.T.)
		lCopia := .T.
	Else // Demais operações
		oModel:SetOperation(nOpcx)
		oModel:Activate()
	EndIf
	
	If nOpcx == MODEL_OPERATION_INSERT .OR. nOpcx == MODEL_OPERATION_UPDATE .OR. nOpcx == 9 // Inserção, alteração ou copia
		// Pega a estrutura do Cabeçalho
		oMdlFldDL0 := oModel:GetModel( "MdFieldDL0" )
		oStrucDL0  := oMdlFldDL0:GetStruct()
		aFldDL0    := oStrucDL0:GetFields()
		
		// Pega a estrutura do Grid de Estados
		oMdlGrdDL1 := oModel:GetModel( "MdGridDL1" )
		oStrucDL1  := oMdlGrdDL1:GetStruct()
		aGrdDL1    := oStrucDL1:GetFields()
		
		// Pega a estrutura do Grid de Documentos
		oMdlGrdDL2 := oModel:GetModel( "MdGridDL2" )
		oStrucDL2  := oMdlGrdDL2:GetStruct()
		aGrdDL2    := oStrucDL2:GetFields()

		// habilita a inserção de linhas
		oMdlGrdDL2:SetNoInsertLine(.F.)
		oMdlGrdDL2:SetNoDeleteLine(.F.)

		// Zera os campos de gravação.
		If lCopia
			oMdlFldDL0:SetValue("DL0_USRINC", CriaVar("DL0_USRINC"))
			oMdlFldDL0:SetValue("DL0_FILINC", CriaVar("DL0_FILINC"))
			oMdlFldDL0:SetValue("DL0_DATINC", CriaVar("DL0_DATINC"))
			oMdlFldDL0:SetValue("DL0_HORINC", CriaVar("DL0_HORINC"))
		EndIf

		// Carrega o Cabeçalho
		For nCount := 1 To Len( aCab )
			If ( aScan( aFldDL0, { |x| AllTrim( x[3] ) == AllTrim( aCab[nCount][1] ) } ) ) > 0
				If !Empty( aCab[nCount][2])
					If !(oMdlFldDL0:SetValue(aCab[nCount][1], aCab[nCount][2]))
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nCount
			
		If lRet
			// Grid
			For nCount := 1 To Len( aItens )	
				
				// Busca se a Linha de Estado ja existe
				nPosUFDL1  := aScan(aItens[nCount],{|x| AllTrim(x[1]) == "DL1_UF"})
				nPosSeqDL1 := aScan(aItens[nCount],{|x| AllTrim(x[1]) == "DL1_SEQUEN"})
				nPosUFODL1 :=  aScan(aItens[nCount],{|x| AllTrim(x[1]) == "DL1_UFORIG"})

				DL1->( DbSetOrder(3) ) //DL1_FILIAL+DL1_PERCUR+DL1_UF+ DL1_SEQUEN
				If ! oMdlGrdDL1:SeekLine( {{ "DL1_UF", aItens[nCount][nPosUFDL1][2]},{ "DL1_SEQUEN", aItens[nCount][nPosSeqDL1][2]}} )
					nLenGrdDL1 := oMdlGrdDL1:Length()
					If nLenGrdDL1 > 0 .AND. !Empty(oMdlGrdDL1:GetValue("DL1_UF",1))
						// Adiciona uma nova linha no Grid de Estado
						nLenGrdDL1 := oMdlGrdDL1:AddLine()
					EndIf
					
					// Posiciona na linha
					oMdlGrdDL1:GoLine(nLenGrdDL1)
				EndIf
				
				// Preenche o campo de Percurso DL1
				If Empty(oMdlGrdDL1:GetValue("DL1_PERCUR"))
					oMdlGrdDL1:LoadValue("DL1_PERCUR",oMdlFldDL0:GetValue("DL0_PERCUR"))
				EndIf

				// Insere os valores do Grid 1
				For nCount2 := 1 To Len( aItens[nCount] )
					If ValType(aItens[nCount][nCount2]) == "A" .AND. Len(aItens[nCount][nCount2])  > 0
						If  ValType (aItens[nCount][nCount2][1]) == "C"
						
							If ( aScan( aGrdDL1, { |x| AllTrim( x[3] ) == AllTrim( aItens[nCount][nCount2][1] ) } ) ) > 0
								If !Empty( aItens[nCount][nCount2][2])
									If !(oMdlGrdDL1:SetValue(aItens[nCount][nCount2][1], aItens[nCount][nCount2][2]))
										lRet := .F.
										nLnEstErr := nCount
										nLnDocErr := 0
										
										// Sai da Estrutura do For em caso de erro
										Exit
									EndIf
								EndIf
							EndIf
						
						ElseIf ValType (aItens[nCount][nCount2]) == "A" .And. !Empty(aItens[nCount][nCount2])
							
							aDoctos := aItens[nCount][nCount2]
							nDelete := 0
							For nCount3 := 1 To Len(aDoctos) 
								
								
								// Busca se a Linha de Documento ja existe  
								nPosFlVDL2 := aScan(aDoctos[nCount3],{|x| AllTrim(x[1]) == "DL2_FILORI"})
								nPosVgeDL2 := aScan(aDoctos[nCount3],{|x| AllTrim(x[1]) == "DL2_VIAGEM"})                                                                                    
								nPosFDcDL2 := aScan(aDoctos[nCount3],{|x| AllTrim(x[1]) == "DL2_FILDOC"})
								nPosDocDL2 := aScan(aDoctos[nCount3],{|x| AllTrim(x[1]) == "DL2_DOC"})
								nPosSDcDL2 := aScan(aDoctos[nCount3],{|x| AllTrim(x[1]) == "DL2_SERIE"})
								
								DL2->( DbSetOrder(2) ) //DL2_FILIAL+DL2_FILORI+DL2_VIAGEM+DL2_FILDOC+DL2_DOC+DL2_SERIE+DL2_PERCUR 
								If !oMdlGrdDL2:SeekLine( {{ "DL2_FILORI",  aDoctos[nCount3][nPosFlVDL2][2] },{ "DL2_VIAGEM", aDoctos[nCount3][nPosVgeDL2][2] },{ "DL2_FILDOC", aDoctos[nCount3][nPosFDcDL2][2]},;
														{ "DL2_DOC", aDoctos[nCount3][nPosDocDL2][2]},{ "DL2_SERIE", aDoctos[nCount3][nPosSDcDL2][2]}} )
																
									nLenGrdDL2 := oMdlGrdDL2:Length()
									If nLenGrdDL2 > 0 .AND. !Empty(oMdlGrdDL2:GetValue("DL2_FILORI",1))
										// Adiciona uma nova linha no Grid de Documentos
										nLenGrdDL2 := oMdlGrdDL2:AddLine()
									EndIf

									// Posiciona na linha
									oMdlGrdDL2:GoLine(nLenGrdDL2)
								EndIf
								
								// Preenche o campo de Percurso DL2
								If Empty(oMdlGrdDL2:GetValue("DL2_PERCUR"))
									oMdlGrdDL2:LoadValue("DL2_PERCUR",oMdlFldDL0:GetValue("DL0_PERCUR"))
								EndIf

								// Preenche o campo de Sequencia Pai DL2
								If Empty(oMdlGrdDL2:GetValue("DL2_SEQPAI"))
									oMdlGrdDL2:LoadValue("DL2_SEQPAI",oMdlGrdDL1:GetValue("DL1_SEQUEN"))
								EndIf

								// Preenche o campo de Id da Linha DL2
								If Empty(oMdlGrdDL2:GetValue("DL2_IDLIN"))
									oMdlGrdDL2:LoadValue("DL2_IDLIN",oMdlGrdDL1:GetValue("DL1_IDLIN"))
								EndIf

								For nCount4 := 1 To Len( aDoctos[nCount3] )
									If ( aScan( aGrdDL2, { |x| AllTrim( x[3] ) == AllTrim( aDoctos[nCount3][nCount4][1] ) } ) ) > 0
										If !Empty( aDoctos[nCount3][nCount4][2])
											If !(oMdlGrdDL2:SetValue(aDoctos[nCount3][nCount4][1], aDoctos[nCount3][nCount4][2]))
												lRet := .F.
												nLnEstErr := nCount
												nLnDocErr := nCount3
												
												// Sai da Estrutura do For em caso de erro
												Exit
											EndIf
										EndIf
									EndIf
								Next nCount4
								
								// Verifica se o documento foi deletado da viagem
								If aScan(aDelDocs, aDoctos[nCount3][nPosFDcDL2][2]+aDoctos[nCount3][nPosDocDL2][2]+aDoctos[nCount3][nPosSDcDL2][2]) > 0
									oMdlGrdDL2:DeleteLine()
									nDelete += 1
								EndIf
								// Posiciona na Linha 1
								oMdlGrdDL2:GoLine(1)

								//  Sai da Estrutura do For em caso de erro
								If !lRet
									Exit
								EndIf
							Next nCount3
							
							// Caso todos os documentos forem deletados, adiciona a linha de estados para ser deletada
							If nDelete == Len(aDoctos) .AND. nDelete > 0
								AADD(aLinDL1Del,oMdlGrdDL1:GetLine())
							EndIf
							// Sai da Estrutura do For em caso de erro
							If !lRet
								Exit
							EndIf
							
						EndIf
					EndIf
				Next nCount2
			

				// Sai da Estrutura do For em caso de erro
				If !lRet
					Exit
				EndIf
			Next nCount

			If Len(aLinDL1Del) > 0
				For nCount := 1 To Len(aLinDL1Del)
					oMdlGrdDL1:GoLine(aLinDL1Del[nCount])
					If oMdlGrdDL1:GetValue("DL1_ORIGEM") == "3" // Não Previsto
						oMdlGrdDL1:DeleteLine()
					EndIf
				Next nCount
			EndIf
			
			// Posiciona na Linha 1
			oMdlGrdDL1:GoLine(1)

		EndIf

		// Desabilita a inserção de linhas
		oMdlGrdDL2:SetNoInsertLine(.T.)
		oMdlGrdDL2:SetNoDeleteLine(.T.)
	EndIf
Return {lRet,oModel}

/*/-----------------------------------------------------------
{Protheus.doc} Af16CarPer
Realiza a Reordenação do Grid de Estados

Uso: TMSAF16

@sample
//Af16CarPer(oView,cIdForm,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso.
@since 05/05/2017
@version 1.0
-----------------------------------------------------------/*/
Function Af16CarPer(oView,cIdForm,cIdCampo,cValue)
	Local oModel     := NIL            // Recebe o modelo
	Local oMdlFldDL0 := NIL            // Recebe o Modelo Percurso 
	Local oMdlGrdDL1 := NIL            // Recebe o Modelo de estados 
    Local nLineAtu   := 0              // Recebe a linha atual
	Local nAntLine   := 0              // Recebe a linha anterior
    Local cSeqAtu    := ""             // Recebe a sequencia Atual
	Local cSeqAnt    := ""             // Recebe a Sequencia Anterior
	
	Default oView    := FwViewActive() // Recebe a View ativa
	Default cIdForm  := ""             // Recebe o Id do formulario
	Default cIdCampo := ""             // Recebe o Id do Campo
	Default cValue   := ""             // Recebe o valor do campo

	// Monta o objeto do ModelGrid
	oModel := oView:GetModel()
	oMdlGrdDL1 := oModel:GetModel( "MdGridDL1" )
	oMdlFldDL0 := oModel:GetModel( "MdFieldDL0" )
	
	// recebe a linha atual
	nLineAtu := oMdlGrdDL1:GetLine()

	If Empty(oMdlGrdDL1:GetValue("DL1_PERCUR"))
		oMdlGrdDL1:LoadValue("DL1_PERCUR", oMdlFldDL0:GetValue("DL0_PERCUR") )
		oMdlGrdDL1:LoadValue("DL1_UFORIG", Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_ESTENT"))

		// Ajusta a Sequencia da linha 	
		nAntLine := LinValida(oMdlGrdDL1,nLineAtu,.F.)
		cSeqAtu :=  oMdlGrdDL1:GetValue("DL1_SEQUEN",nLineAtu)

		If nAntLine > 0	
			cSeqAnt :=  oMdlGrdDL1:GetValue("DL1_SEQUEN",nAntLine)	
		EndIf

		If Val(cSeqAnt) + 1 != Val(cSeqAtu)  
			oMdlGrdDL1:LoadValue("DL1_SEQUEN", STRZERO( Val(cSeqAnt) + 1 , TamSx3('DL1_SEQUEN')[1]) )	
		EndIf

		oView:Refresh("VwGridDL2") 
	EndIf

Return

/*/-----------------------------------------------------------
{Protheus.doc} Af016Reord
Realiza a Reordenação do Grid de Estados

Uso: TMSAF16

@sample
//Af016Reord(oView,cIdForm,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso.
@since 05/05/2017
@version 1.0
-----------------------------------------------------------/*/
Function Af16Reord(oView,cIdForm,cIdCampo,cValue)
	Local aArea      := GetArea()      // Recebe a Area Atual
	Local oModel     := NIL            // Recebe o modelo
	Local nLine  

	Default oView    := FwViewActive() // Recebe a View ativa
	Default cIdForm  := ""             // Recebe o Id do formulario
	Default cIdCampo := ""             // Recebe o Id do Campo
	Default cValue   := ""             // Recebe o valor do campo

	// Monta o objeto do ModelGrid
	oModel 		:= oView:GetModel()
	oViewObj 	:= oView:GetViewObj(cIdForm)     
	oModelGrid 	:= oModel:GetModel( oViewObj[6] )
	nLine 		:= oModelGrid:GetLine()

	// Chama a Função de Reordenação 
	TMSOrdGrd(oView,oModelGrid,cIdForm,cIdCampo,cValue/*,"Af16VldUf",{oModelGrid,cIdCampo,cValue,nLine}*/)

	//Atualiza a tela     
	oView:GoLine(oModelGrid:getId(),nLine)
	oView:Refresh(cIdForm) //Atualiza a tela   
	oView:Refresh("VwGridDL2") 

	RestArea(aArea)
Return

//==========================================================================================
/*/{Protheus.doc} Af16VldUf
Valida a sequencia digitada no Grid de Estados.
@author 	arume.alexandre
@version    1.0
@since      19/11/18
@return     lRet: Valido ou não.
@param  	oModelGrid: Objeto do modelo da Grid
@param		cIdCampo: Codigo do campo
@param		cValue: Valor do campo
@param		nLine: Linha que esta sendo alterada
/*/
//==========================================================================================
Function Af16VldUf(oModelGrid, cIdCampo, cValue, nLine)

	Local lRet			:= .T.
	Local nCount		:= 0
	Local nSeqMaior		:= 0
	Local nValue		:= 0	
	Local oView			:= Nil			// Recebe a view
	Local oModel     	:= Nil          // Recebe o modelo
	Local oMdlGrdDL1 	:= Nil          // Recebe o Modelo de estados 
	Local oMdlGrdDL2 	:= Nil          // Recebe o Modelo de Documentos dos estados

	Default oModelGrid	:= Nil			
	Default cIdCampo 	:= ""			
	Default cValue   	:= ""
	Default nLine  		:= 0			

	oView := FwViewActive()
	oModel := oView:GetModel()
	oMdlGrdDL1 := oModel:GetModel( "MdGridDL1" )
	oMdlGrdDL2 := oModel:GetModel( "MdGridDL2" )
	
	If DTQ->DTQ_STATUS $ "1,5" //1-Em Aberto; 2-Em Transito; 5-Fechada.
		For nCount := 1 To oMdlGrdDL1:GetQTDLine()
			oMdlGrdDL1:GoLine(nCount)
			If !Empty(oMdlGrdDL2:GetValue("DL2_SEQPAI"))
				If Val(oMdlGrdDL1:GetValue("DL1_SEQUEN")) > nSeqMaior
					nSeqMaior := Val(oMdlGrdDL1:GetValue("DL1_SEQUEN"))
				EndIf
			EndIf
		Next

		oMdlGrdDL1:GoLine(nLine)
		nValue := Val(TMSOrdValD(oModelGrid, cIdCampo, cValue))
		If (nLine <= nSeqMaior .OR. nValue <= nSeqMaior) .AND. nLine <> nValue
			Help(" ", 1, "TMSAF1607")	// Não é possível alterar para esta sequencia.
			oMdlGrdDL1:LoadValue(cIdCampo,STRZERO(nLine, TamSx3(cIdCampo)[1]))
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PreVldMdl
Pré-valida a Linha do grid

Uso: TMSAF16

@sample
//PreVldMdl(oModelGrid)

@author Paulo Henrique Corrêa Cardoso.
@since 05/05/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldMdl(oModelGrid,nLine,cAction)
	Local lRet 		:= .T.				// Recebe o Retorno
	Local aAreaDL1	:= DL1->(GetArea())	// Recebe a Area da tebela DL1
	Local oView		:= FwViewActive()   // Recebe a View Ativa
	Local cOrigem		:= ""
	Local nLenGrdDL2	:= 0
	Local oMdlGrdDL2	:= Nil
	Local oModel		:= Nil 
	
	oModelGrid:GoLine(nLine)
		
	cOrigem		:= oModelGrid:GetValue("DL1_ORIGEM")
		
	If cAction == 'DELETE' // Reordenação quando linha estiver sendo excluida
		
		If cOrigem == "1" .Or. cOrigem == "4" .Or. IsInCallStack("AF16Load") .OR. DTQ->DTQ_STATUS $ "1,5" //-- Origem = 1=Manual;4=Percurso MDF-e | Status da viagem 1=Em aberto;5=Fechada
			oModel		:= oView:GetModel()
			oMdlGrdDL2	:= oModel:GetModel( "MdGridDL2" )
			nLenGrdDL2	:= oMdlGrdDL2:Length()
			 
			If nLenGrdDL2 > 0 .AND. !Empty(oMdlGrdDL2:GetValue("DL2_DOC",1))
				Help(" ",1,"TMSAF1606") //-- O Estado não pode ser excluido, pois existem documentos vinculados.				           
				lRet := .F.	
			EndIf
		
			TMSOrdDel(oView,oModelGrid,"DL1_SEQUEN",nLine,!lRet)
		Else
			Help(" ",1,"TMSAF1601") //-- O Estado não pode ser excluido! Somente Estados incluidos manualmente e Estados cuja origem seja referente ao percurso MDF-e cadastrado na Rota; poderão ser excluidos.           
			lRet := .F.
		EndIf
	ElseIf cAction == 'UNDELETE' // Reordenação quando linha estiver sendo Recuperada
		If cOrigem == "1" .Or. cOrigem == "4" //-- Origem = 1=Manual;4=Percurso MDF-e
			TMSOrdDel(oView,oModelGrid,"DL1_SEQUEN",nLine,.T.)
		Else
			Help(" ",1,"TMSAF1602") //-- O Estado não pode ser recuperado! Somente Estados incluidos manualmente, e Estados cuja origem seja referente ao percurso MDF-e cadastrado na Rota; poderão ser recuperados.
			lRet := .F.
		EndIf
	EndIf

	RestArea(aAreaDL1)	

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} F16DbClick
Ação de Duplo clique na campo

Uso: TMSAF16

@sample
//F16DbClick(oForm,cFieldName,nLineGrid,nLineModel)

@author Paulo Henrique Corrêa Cardoso
@since 05/05/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function F16DbClick(oGrdView,cFieldName,nLineGrid,nLineModel)
	Local aArea         := GetArea()
	Local oModelGrid    := NIL

	Default oGrdView    := NIL
	Default cFieldName  := ""
	Default nLineGrid   := 0
	Default nLineModel  := 0

	oModelGrid := oGrdView:GetModel()
	oModelGrid:GoLine(nLineModel)

	If cFieldName == "DL1_LEGORI"
		AF16Legend()
	EndIf
	RestArea(aArea)

Return .T.

/*/-----------------------------------------------------------
{Protheus.doc} AF16Legend
Abre a Legenda

Uso: TMSAF16

@sample
//AF16Legend()

@author Paulo Henrique Corrêa Cardoso.
@since 05/05/2017
@version 1.0
-----------------------------------------------------------/*/
Function AF16Legend()
	Local aLegenda := {}
	Local cTitulo  := ""

	Aadd(aLegenda,{"BR_VERDE"   , STR0016}) //-- "Estado definido no percurso Original da Viagem"
	Aadd(aLegenda,{"BR_AZUL"    , STR0017}) //-- "Estado não previsto no percurso Original da Viagem"
	Aadd(aLegenda,{"BR_AMARELO" , STR0018}) //-- "Estado Incluido Manualmente"
	Aadd(aLegenda,{"BR_LARANJA"	, STR0021 })	//-- Estado previso no percurso MDF-e
	
	cTitulo:= STR0019 //-- "Origem do estado no percurso"

	If Len(aLegenda) > 0  
		BrwLegenda(cTitulo, STR0020 , aLegenda) //"Legenda"
	EndIf
Return

/*/-----------------------------------------------------------
{Protheus.doc} AF16Cor()
Retorna a Legenda para o Grid

Uso: TMSAF16

@sample
//AF16Cor()

@author Paulo Henrique Corrêa Cardoso.
@since 05/05/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function AF16Cor(oModel)
Local cLegenda   := ""               // Recebe a Legenda            
Local oMdlGrdDL1 := NIL              // Recebe o Modelo do Grid de Estados

Default  oModel  := FwModelActive()  // Recebe o Modelo Ativo

oMdlGrdDL1 := oModel:GetModel("MdGridDL1")  

If oMdlGrdDL1:GetValue("DL1_ORIGEM") == "1" 		//-- "Manual"
	cLegenda 	:= "BR_AMARELO" 
	
ElseIf oMdlGrdDL1:GetValue("DL1_ORIGEM") == "2" 	//-- "Rota"
	cLegenda 	:= "BR_VERDE"
	
ElseIf oMdlGrdDL1:GetValue("DL1_ORIGEM") == "3" 	//-- "Não Previsto"
	cLegenda 	:= "BR_AZUL"
	
ElseIf oMdlGrdDL1:GetValue("DL1_ORIGEM") == "4" 	//-- Estado previsto percurso MDF-e
	cLegenda	:= "BR_LARANJA"
	
EndIf

Return cLegenda


/*/-----------------------------------------------------------
{Protheus.doc} AF16AtuMan()
Atualiza o Manifesto.

Uso: TMSAF16

@sample
//AF16AtuMan(cPercurso,cUFORI,cUFDest,cManife)

@author Paulo Henrique Corrêa Cardoso.
@since 18/05/2017
@version 1.0
-----------------------------------------------------------/*/

Function AF16AtuMan(cPercurso,cUFORI,cUFDest,cFilMan,cManife,cSerMan,lDel)
	Local lRet          := .T.         // Recebe o Retorno
	Local lDocs         := .F.         // Recebe se o estado possui documentos

	Default cPercurso   := ""          // Recebe o Código de Percurso
	Default cUFORI      := ""          // Recebe a Uf de Origem
	Default cUFDest     := ""          // Recebe a Uf de Destino
	Default cManife     := ""          // Recebe o código do Manifesto Eletronico
	Default lDel        := .F.         // Recebe se o registro deverá ser excluido

	dbSelectArea("DL1")
	dbSelectArea("DL2")
	// Remove o Código do manifesto em caso de exclusão
	If lDel
		
		DL1->(dbSetOrder(2)) //DL1_FILIAL+DL1_PERCUR+DL1_FILMAN+DL1_MANIFE+DL1_SERMAN
		DL2->(dbSetOrder(3))//DL2_FILIAL+DL2_PERCUR+DL2_FILMAN+DL2_MANIFE+DL2_SERMAN

		// Limpa o Manifesto dos documento do percurso
		If DL2->( dbSeek(FwxFilial("DL2") + cPercurso + cFilMan + cManife + cSerMan ))
			While DL2->(!EOF()) .AND. DL2->DL2_FILIAL == FwxFilial("DL2") .AND. DL2->DL2_PERCUR == cPercurso .AND. DL2->DL2_FILMAN == cFilMan ;
						.AND. DL2->DL2_MANIFE == cManife .AND. DL2->DL2_SERMAN == cSerMan
				RecLock("DL2",.F.)
				DL2->DL2_FILMAN := CriaVar("DL2_FILMAN")
				DL2->DL2_MANIFE := CriaVar("DL2_MANIFE")
				DL2->DL2_SERMAN := CriaVar("DL2_SERMAN")
				DL2->(MsUnLock())

				DL2->(dbSkip())	
			EndDo
		EndIf

		// Limpa o Manifesto dos Estados do percurso
		If DL1->( dbSeek(FwxFilial("DL1") + cPercurso + cFilMan + cManife + cSerMan ))
			While DL1->(!EOF()) .AND. DL1->DL1_FILIAL == FwxFilial("DL1") .AND. DL1->DL1_PERCUR == cPercurso .AND. DL1->DL1_FILMAN == cFilMan ;
						.AND. DL1->DL1_MANIFE == cManife .AND. DL1->DL1_SERMAN == cSerMan
				RecLock("DL1",.F.)
				DL1->DL1_FILMAN := CriaVar("DL1_FILMAN")
				DL1->DL1_MANIFE := CriaVar("DL1_MANIFE")
				DL1->DL1_SERMAN := CriaVar("DL1_SERMAN")
				DL1->(MsUnLock())

				DL1->(dbSkip())	
			EndDo
		EndIf

	Else // Preenche o codigo do manifesto.
		DL1->(dbSetOrder(4)) //DL1_FILIAL+DL1_PERCUR+DL1_UF+DL1_UFORIG
		DL2->(dbSetOrder(1)) //DL2_FILIAL+DL2_PERCUR+DL2_IDLIN

		// Busca o Estado para Atualizar o MDF-e
		If DL1->( dbSeek(FwxFilial("DL1") + cPercurso + cUFDest + cUFORI ))
			While DL1->(!EOF()) .AND. DL1->DL1_FILIAL == FwxFilial("DL1") .AND. DL1->DL1_PERCUR == cPercurso .AND. DL1->DL1_UF == cUFDest .AND. DL1->DL1_UFORIG == cUFORI
				
				lDocs := .F.

				// Busca os Documentos do Estado
				If DL2->( dbSeek(FwxFilial("DL2") + cPercurso + DL1->DL1_IDLIN ))
					lDocs := .T.
					While DL2->(!EOF()) .AND. DL2->DL2_FILIAL == FwxFilial("DL2") .AND. DL2->DL2_PERCUR == cPercurso .AND. DL2->DL2_IDLIN == DL1->DL1_IDLIN
						
						If DL2->DL2_SERIE != "COL"
							RecLock("DL2",.F.)
							DL2->DL2_FILMAN := cFilMan
							DL2->DL2_MANIFE := cManife
							DL2->DL2_SERMAN := cSerMan
							DL2->(MsUnLock())
						EndIf

						DL2->(dbSkip())
					EndDo
				EndIf

				If lDocs
					RecLock("DL1",.F.)
					DL1->DL1_FILMAN := cFilMan
					DL1->DL1_MANIFE := cManife
					DL1->DL1_SERMAN := cSerMan
					DL1->(MsUnLock())
				EndIf

				DL1->(dbSkip())
			EndDo
		EndIf
	EndIf

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} Af16MovEst()
Move o Documento para outra sequencia de estado.

Uso: TMSAF16

@sample
//Af16MovEst(oView,cIdForm,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso.
@since 22/05/2017
@version 1.0
-----------------------------------------------------------/*/
Static Function Af16MovEst(oView,cIdForm,cIdCampo,cValue)
	Local aArea     := GetArea()      // Recebe a Area Atual
	Local oModel     := NIL            // Recebe o modelo
	Local oMdlGrdDL1 := NIL            // Recebe o Modelo de estados 
	Local oMdlGrdDL2 := NIL            // Recebe o Modelo de Documentos dos estados 
	Local nLineAtuUF := 0              // Recebe a linha anterior
    Local nCount     := 0              // Recebe o Contador 
	Local oStrucDL2  := NIL            // Recebe o objeto com a estrutura de campos da tabela DL2
	Local aGrdDL2    := {}             // Recebe o array com a estrutura de campos da tabela DL2
	Local nLineDest  := 0              // Recebe a linha de Destino da tabela DL1
	Local aData      := {}             // Recebe o Array de dados
	Local cUf        := ""             // Recebe a Uf do Estado atual.
	Local cSeqOri    := ""             // Recebe a Sequencia Atual.

	Default oView    := FwViewActive() // Recebe a View ativa
	Default cIdForm  := ""             // Recebe o Id do formulario
	Default cIdCampo := ""             // Recebe o Id do Campo
	Default cValue   := ""             // Recebe o valor do campo

	// Monta o objeto do ModelGrid
	oModel := oView:GetModel()
	oMdlGrdDL1 := oModel:GetModel( "MdGridDL1" )
	oMdlGrdDL2 := oModel:GetModel( "MdGridDL2" )
	
	oStrucDL2  := oMdlGrdDL2:GetStruct()
	aGrdDL2    := oStrucDL2:GetFields()

	// recebe a linha do estado posicionado
	nLineAtuUF := oMdlGrdDL1:GetLine()
	oModel:GetModel("MdGridDL2"):SetNoInsertLine(.F.)		
	oModel:GetModel("MdGridDL2"):SetNoDeleteLine(.F.)

	cUf     := oMdlGrdDL1:GetValue("DL1_UF")
    cSeqOri := oMdlGrdDL1:GetValue("DL1_SEQUEN")
	// Busca a sequencia digitada
	cValue := STRZERO(Val(cValue),TamSx3('DL1_SEQUEN')[1])
	If oMdlGrdDL1:SeekLine( {{ "DL1_SEQUEN", cValue  }} )
		If cUf ==  oMdlGrdDL1:GetValue("DL1_UF")
			nLineDest := oMdlGrdDL1:GetLine()
			
			oMdlGrdDL1:GoLine(nLineAtuUF)
			For nCount := 1 To	Len(aGrdDL2)
				AADD(aData,{aGrdDL2[nCount][3],oMdlGrdDL2:GetValue(aGrdDL2[nCount][3])})
			Next nCount

			oMdlGrdDL2:DeleteLine()	
			
			oMdlGrdDL1:GoLine(nLineDest)

			If !Empty(oMdlGrdDL2:GetValue("DL2_DOC"))
				oMdlGrdDL2:AddLine()
			EndIf
			
			For nCount := 1 To	Len(aData)
				If aData[nCount][1] != "DL1_IDLIN"
					oMdlGrdDL2:LoadValue(aData[nCount][1],aData[nCount][2])
				EndIf
			Next nCount
			oMdlGrdDL1:GoLine(nLineAtuUF)
			oView:Refresh("VwGridDL2") //Atualiza a tela 
		Else
			oMdlGrdDL1:GoLine(nLineAtuUF)
			oMdlGrdDL2:LoadValue("DL2_SEQPAI",cSeqOri)
			oView:Refresh("VwGridDL2") //Atualiza a tela 
			Help(" ",1,"TMSAF1603") // Só será permido mover os documentos para sequências de mesmo estado.
		EndIf
		
	Else
		oMdlGrdDL2:LoadValue("DL2_SEQPAI",cSeqOri)
		Help(" ",1,"TMSAF1604") // Sequência digitada não foi encontrada nos estados.
	EndIf
	oModel:GetModel("MdGridDL2"):SetNoInsertLine(.T.)
	oModel:GetModel("MdGridDL2"):SetNoDeleteLine(.T.)

	RestArea(aArea)
Return

/*/-----------------------------------------------------------
{Protheus.doc} F16ExbPerc()
Exibe o Percurso

Uso: TMS

@sample
//F16ExbPerc(cFilOri, cViagem)

@author Paulo Henrique Corrêa Cardoso.
@since 09/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function F16ExbPerc(cFilOri, cViagem, lEdit)
	
	Local cAtvChgCli	:= SuperGetMv('MV_ATVCHGC',,'')
	Local cAtvChgApo    := SuperGetMv('MV_ATVCHPA',,'')   //-- Atividade de Chegada no Ponto de Apoio

	Default cFilOri 	:= ""
	Default cViagem 	:= ""
	Default lEdit		:= .F.

	dbSelectArea("DL0")
	DL0->(dbSetOrder(2))

	dbSelectArea("DL2")
	DL2->(dbSetOrder(2))

	If DL0->(MsSeek( FWxFilial("DL0")+cFilOri+cViagem ))
		DL0->(MsSeek( FWxFilial("DL0")+cFilOri+cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
		DL0->(DbSkip(-1))
		If lEdit 
			If DTQ->DTQ_STATUS == "2" // Em Transito.
				If !TMSA350Ope(cFilOri, cViagem) $ cAtvChgCli + "," + cAtvChgApo
					Help(" ",1,"TMSAF1608") //Não é possível Editar o Percurso com o status da viagem Em Transito e com operação diferente de Chegada em Cliente/Apoio.
					Return
				EndIf
			EndIf
			AF16IncPer(MODEL_OPERATION_UPDATE,,,.F.,) // Edita o Registro.			
		Else
			AF16IncPer(MODEL_OPERATION_VIEW,,,.F.,) // Visualiza o Registro.
		EndIf
	
	ElseIf DL2->(MsSeek( FWxFilial("DL2")+cFilOri+cViagem ))

		DL2->(MsSeek( FWxFilial("DL2")+cFilOri+cViagem +  Replicate("Z",Len(DL2->DL2_FILDOC)) +  Replicate("Z",Len(DL2->DL2_DOC))  +  Replicate("Z",Len(DL2->DL2_SERIE)) + Replicate("Z",Len(DL2->DL2_PERCUR)),.T.))
		DL2->(DbSkip(-1))

		DL0->(dbSetOrder(2))
		If DL0->(MsSeek( FWxFilial("DL0")+cFilOri+cViagem+DL2->DL2_PERCUR ))
			AF16IncPer(MODEL_OPERATION_VIEW,,,.F.,) // Visualiza o Registro.
		EndIf
	Else
		Help(' ', 1, 'TMSAF1605')	//Não Existe percurso para essa viagem, É necessario gerar o manifesto primeiro
	EndIf
Return

/*/-----------------------------------------------------------
{Protheus.doc} F16DocDel()
Busca no percurso os documentos deletados na viagem

Uso: TMS.

@sample
//F16DocDel(cFilOri, cViagem, cPercurso)

@author Paulo Henrique Corrêa Cardoso.
@since 20/03/2018
@version 1.0
-----------------------------------------------------------/*/
Function F16DocDel(cFilOri, cViagem, cPercurso)
	Local aRet        := {}                 // Recebe o array de retorno
	Local cQuery      := ""                 // Recebe a Query
	Local cAliasQry   := GetNextAlias()     // Recebe o proximo alias disponivel
	Local aItens      := {}                 // Recebe as informações dos documentos
 
	Default cFilOri   := ""                 // Recebe a filial de origem da viagem 
	Default cViagem   := ""                 // Recebe o código da viagem
	Default cPercurso := ""                 // Recebe o código do percurso

	// Busca os documentos do percurso que foram deletados da viagem
	If !Empty(cFilOri) .AND. !Empty(cViagem) .AND.!Empty(cPercurso) 
		cQuery += " SELECT DL2_FILDOC,DL2_DOC, DL2_SERIE , DL2_CLIREM, DL2_LOJREM, DL2_CLIDES,DL2_LOJDES "
		cQuery += " FROM " + RetSqlName("DL2") + " DL2 "
		cQuery += " WHERE  DL2_FILIAL = '"+ FwxFilial("DL2") +"' "
		cQuery += " 	AND DL2_FILORI = '"+ cFilOri +"'"
		cQuery += " 	AND DL2_VIAGEM = '"+ cViagem +"'"
		cQuery += " 	AND DL2_PERCUR = '"+ cPercurso +"' "
		cQuery += " 	AND DL2_FILDOC || DL2_DOC || DL2_SERIE NOT IN ( SELECT  DUD_FILDOC || DUD_DOC || DUD_SERIE "
		cQuery += " 													FROM " + RetSqlName("DUD") + " DUD "
		cQuery += " 													WHERE  DUD_FILIAL = '"+ FwxFilial("DUD") +"' "
		cQuery += " 															AND DUD_FILORI = '"+ cFilOri +"'"
		cQuery += " 															AND DUD_VIAGEM = '"+ cViagem +"'"
		cQuery += " 															AND DUD.D_E_L_E_T_ = ' ' )"
		cQuery += " 	AND DL2.D_E_L_E_T_ = ' '
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. )

		While (cAliasQry)->(!Eof())

			// Adiciona as informações do documento
			AADD(aItens,(cAliasQry)->DL2_FILDOC )
			AADD(aItens,(cAliasQry)->DL2_DOC    )
			AADD(aItens,(cAliasQry)->DL2_SERIE  )
			AADD(aItens,(cAliasQry)->DL2_CLIREM )
			AADD(aItens,(cAliasQry)->DL2_LOJREM )
			AADD(aItens,(cAliasQry)->DL2_CLIDES )
			AADD(aItens,(cAliasQry)->DL2_LOJDES )

			// Adiciona no array de retorno
			AADD(aRet,aItens)
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(dbCloseArea())
	EndIf

Return aRet


/*/-----------------------------------------------------------
{Protheus.doc} F16LdVia()
Carrega percurso com base na viagem

Uso: Generico com a viagem posicionada.

@sample
//F16LdVia(cFilOri,cViagem)

@author Paulo Henrique Corrêa Cardoso.
@since 19/03/2018
@version 1.0
-----------------------------------------------------------/*/
Function F16LdVia(cFilOri,cViagem,aViagCol)
	Local aRet        := {}                 // Recebe o array de retorno 
	Local lRet        := .F.                // Recebe a vaiavel lógca de retorno
	Local aArea       := GetArea()          // Recebe a area atual
	Local aAreaDTQ    := DTQ->(GetArea())   // Recebe a area do DTQ
	Local lExbPerc    := .F.				// Verifica se sempre exibe a tela de percurso
	Local cRegOriMDF  := ""                 // Recebe a Região de Origem do MDF-e existente no cadastro de Rotas
	Local cUfAtu      := ""                 // Recebe o estado de Inicio do percurso
	Local cUFOri      := ""                 // Recebe o estado de origem 
	Local cUfDes      := ""                 // Recebe o estado de destino
	Local cMunAtu     := ""                 // Recebe o municipio de Inicio do percurso
	Local cMunMan     := ""                 //  Recebe o municipio do manifesto 
	Local lPerc       := .F.				// Recebe se a Viagem já possui percurso.
	Local aItens      := {}                 // Recebe os dados do Estado
	Local aEstados    := {}                 // Recebe os Estados
	Local cUfAnt      := ""					// Recebe o Estado anterior
	Local lPrevist    := .F.                // Recebe se é um documento não previsto
	Local nPosEst     := 0                  // Recebe a posição dos estados no Array aEstados
	Local nPosMunic   := 0                  // Recebe a posição dos municipios no array aItens
	Local nPosUfOri   := 0                  // Recebe a posição dos estados de origem no array aIten
	Local nTamEst     := 0                  // Recebe o tamanho do do array de itens
	Local aItmPerc    := {}                 // Recebe os documentos dos trechos do percurso
	Local aCab        := {}                 // Recebe o cabeçalho do percurso de viagem
	Local nOpcPer     := 0                  // Recebe a opção de execução da rotina de percurso
	Local aDelDocs    := {}                 // Recebe os documentos deletados
	Local nCount      := 0                  // Recebe o contador
	Local cRota       := ""                 // Recebe o codigo da rota
	Local lRoteiro    := .F.                // Recebe se a rota é de roteiro
	Local nSequen	  :=  1 
	Local lPercurso	  := SuperGetMv("MV_TMSPERC",.F.,.F.)
	Local cCdrOri	  := ""
	Local aAreaSM0    := SM0->(GetArea())
	Local cRotCnt0    := ""

	Default cFilOri   := ""                 // Recebe a Filial de Origem da Viagem
	Default cViagem   := ""					// Recebe o código da viagem
	Default aViagCol  := {}                 // Recebe as viagens coligadas
	
	If !Empty(cFilOri) .AND. !Empty(cViagem)
		
		// Busca a viagem
		dbSelectArea("DTQ")
		DTQ->(dbSetOrder(2)) //DTQ_FILIAL+DTQ_FILORI+DTQ_VIAGEM+DTQ_ROTA

		If DTQ->( dbSeek( FWxFilial("DTQ") + cFilOri + cViagem  ) )

			// Busca se ja possui percurso pra viagem
			dbSelectArea("DL0")
			DL0->(dbSetOrder(2))//DL0_FILIAL+DL0_FILORI+DL0_VIAGEM+DL0_PERCUR
			lPerc :=  DL0->(dbSeek( FWxFilial("DL0")+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ))

			If lRoteiro := F11RotRote(DTQ->DTQ_ROTA) //Rota Roteiro
				//......
			Else  // Rota Cep

				If DTQ->DTQ_STATUS == "2" //2-Em Transito
					// Verifica se exibe a tela de Percurso com a viagem em transito.
					Pergunte("TMB144", .F.) 
					If Type("MV_PAR05") != "U"
						lExbPerc := MV_PAR05 == 1
					Else
						lExbPerc := .F.
					EndIf
				EndIf
				
				// Pega o Estado de Origem da Rota para geração do MDF-e
				If DTQ->DTQ_STATUS $  '1,5' .AND. DA8->(ColumnPos('DA8_CDOMDF')) > 0
					cRegOriMDF := Posicione("DA8",1,xFilial("DA8") + DTQ->DTQ_ROTA ,"DA8_CDOMDF")
					If !Empty(cRegOriMDF)
						cUfAtu   := Posicione("DUY",1,xFilial("DUY") + cRegOriMDF ,"DUY_EST")  
						cMunAtu  := Posicione("DUY",1,xFilial("DUY") + cRegOriMDF ,"DUY_CODMUN")  
					EndIf
				EndIf

				// Caso Estado do MDF-e esteja vazio, pega o Estado da Filial 
				If Empty(cUfAtu)
					cUfAtu  := Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_ESTENT") 
					cMunAtu := Substr(Posicione("SM0",1,cEmpAnt+cFilAnt,"M0_CODMUN"),3,5)
				EndIf

				// Prepara o Preenchimento dos Estados
				If !lPerc  // Não Possui Percurso

					// Adiciona o estado de Origem da Filial.	
					AAdd( aItens, { {"DL1_SEQUEN", StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] ) },;
									{"DL1_UF",cUfAtu} ,;
									{"DL1_UFORIG",cUfAtu} ,;
									{"DL1_ORIGEM",Iif( DTQ->DTQ_STATUS == '5',"2","3")} ,; // Caso viagem em aberto ou fechada Origem = 2 -Rota | caso em transito Origem = 3 - Não previsto
									{"DL1_MUNMAN",cMunAtu},;
									{} } ) // Dever ser a ultima posição do Array
					Aadd(aEstados,{cUfAtu,cUfAtu, StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] ) })	
					nSequen++
					cUfAnt := cUfAtu
					
					//-- Busca Estados da DIQ
					dbSelectArea("DIQ")
					DIQ->(dbSetOrder(1))


					For nCount := 0 To Len(aViagCol)

						If nCount == 0
							cRota    := DTQ->DTQ_ROTA
							cRotCnt0 := DTQ->DTQ_ROTA
						Else
							If DTQ->( dbSeek( FWxFilial("DTQ") + aViagCol[nCount][1] + aViagCol[nCount][2]  ) ) .AND. cRotCnt0 != DTQ->DTQ_ROTA
								cRota :=  DTQ->DTQ_ROTA
							Else
								Loop
							EndIf
						EndIf

						DIQ->(dbSeek(FWxFilial("DIQ") + cRota ))
						While DIQ->(!Eof()) .And. DIQ->( DIQ_FILIAL + DIQ_ROTA ) == FWxFilial("DIQ") + cRota
							nPosEst := AScan(aEstados, { |a| a[1] == DIQ->DIQ_EST } )
							If  Iif( nCount == 1 , DIQ->DIQ_EST != cUfAnt, (nPosEst <= 0 .Or. (nPosEst > 0 .And. nSequen > 2)))							
								AAdd( aItens, { {"DL1_SEQUEN", 	StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] )  },;
												{"DL1_UF",		DIQ->DIQ_EST} 	,;
												{"DL1_UFORIG",	cUfAtu} 		,;
												{"DL1_ORIGEM",	"4"} 			,; 	//-- 4=Percurso MDF-e
												{"DL1_MUNMAN", 	cMunAtu}		,;
												{} } ) 								//-- Dever ser a ultima posição do Array

								Aadd(aEstados,{DIQ->DIQ_EST,cUfAtu,  StrZero( nSequen ,  TamSX3("DL1_SEQUEN")[1] ) })				
								cUfAnt := DIQ->DIQ_EST
								nSequen++								
							EndIf	
							DIQ->(dbSkip())
						EndDo
					Next nCount

					// Reposiciona na viagem principal
					DTQ->( dbSeek( FWxFilial("DTQ") + cFilOri + cViagem  ) )

				Else  // Já Possui percurso.
					dbSelectArea("DL0")
					DL0->(dbSetOrder(2))
					If DL0->(MsSeek( FWxFilial("DL0")+ cFilOri + cViagem ))
						DL0->(MsSeek( FWxFilial("DL0")+ cFilOri + cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
						DL0->(DbSkip(-1))

						dbSelectArea("DL1")
						DL1->(dbSetOrder(5))
						DL1->(dbSeek(FWxFilial("DL1") + DL0->DL0_PERCUR))
						While DL1->(!Eof()) .And. DL1->DL1_FILIAL + DL1->DL1_PERCUR == FWxFilial("DL1") + DL0->DL0_PERCUR 
							AAdd( aItens, { {"DL1_SEQUEN", DL1->DL1_SEQUEN},;
										{"DL1_UF",		DL1->DL1_UF} ,;
										{"DL1_UFORIG",	DL1->DL1_UFORIG} ,;
										{"DL1_ORIGEM",	DL1->DL1_ORIGEM} ,; // Origem - Rota
										{"DL1_MUNMAN", 	DL1->DL1_MUNMAN },;
										{} } ) // Dever ser a ultima posição do Array

							Aadd(aEstados,{DL1->DL1_UF,DL1->DL1_UFORIG,DL1->DL1_SEQUEN})		
							DL1->(dbSkip())		
						EndDo

						// Busca diferenças de documentos do percurso
						aDelDocs := F16DocDel(cFilOri, cViagem, DL0->DL0_PERCUR)

					EndIf
				EndIf
				
				dbSelectArea("DT6")
				DT6->(dbSetOrder(1)) //DT6_FILIAL+DT6_FILDOC+DT6_DOC+DT6_SERIE
				
				dbSelectArea("DUE")
				DUE->(dbSetOrder(1)) //DUE_FILIAL+DUE_CODSOL

				dbSelectArea("DUL")
				DUL->(dbSetOrder(3)) //DUL_FILIAL+DUL_CODSOL+DUL_SEQEND

				dbSelectArea("DT5")
				DT5->(dbSetOrder(4)) //DT5_FILIAL+DT5_FILDOC+DT5_DOC+DT5_SERIE

				For nCount := 0 To Len(aViagCol)
						
					If nCount > 0
						If DTQ->( dbSeek( FWxFilial("DTQ",DTQ->DTQ_FILORI) + aViagCol[nCount][1] + aViagCol[nCount][2]  ) ) .AND. cFilOri + cViagem == DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM
							Loop
						EndIf
					EndIf

					// Busca os documentos da viagem
					dbSelectArea("DUD") 
					DUD->(dbSetOrder(2)) //DUD_FILIAL+DUD_FILORI+DUD_VIAGEM+DUD_SEQUEN+DUD_FILDOC+DUD_DOC+DUD_SERIE
					If DUD->( dbSeek( FWxFilial("DUD",DTQ->DTQ_FILORI)+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM ) )
			
						While DUD->(!Eof()) .And. DUD->DUD_FILIAL + DUD->DUD_FILORI + DUD->DUD_VIAGEM  == FWxFilial("DUD",DTQ->DTQ_FILORI) + DTQ->DTQ_FILORI + DTQ->DTQ_VIAGEM 

							If DT6->(dbSeek( FWxFilial("DT6",DTQ->DTQ_FILORI) + DUD->DUD_FIlDOC + DUD->DUD_DOC + DUD->DUD_SERIE ))
								
								If Empty(DUD->DUD_DTRNPR) // Documento previsto
									cUFOri  := cUfAtu
									cMunMan  := cMunAtu
									lPrevist := .T. // Marca como documento Previsto
								Else // Documento não previsto
									lPrevist := .F.	 // Marca como documento Não Previsto
									If DTA->(ColumnPos('DTA_ORIGEM')) > 0
										cCdrOri := MunOriCar(DT6->DT6_FILDOC,  DT6->DT6_DOC,  DT6->DT6_SERIE)
									Else
										cCdrOri := DT6->DT6_CDRORI
									EndIf
									cUFOri  := Posicione("DUY",1,xFilial("DUY",DTQ->DTQ_FILORI) + cCdrOri ,"DUY_EST")
									cMunMan := DUY->DUY_CODMUN
								EndIf

								If DUD->DUD_SERTMS == '2'
									cUfDes := Posicione("SM0",1,cEmpAnt+DUD->DUD_FILDCA,"M0_ESTENT")
								Else
									cUfDes := Posicione('DUY',1,xFilial('DUY',DTQ->DTQ_FILORI)+DUD->DUD_CDRCAL,'DUY_EST')
								EndIf

								If Empty(cUfDes)
									If DT6->DT6_SERTMS == '1' //Coleta 
										If DT5->(dbSeek(FwxFilial('DT5',DTQ->DTQ_FILORI)+DUD->(DUD_FILDOC+DUD_DOC+DUD_SERIE)))
											If Empty(DT5->DT5_SEQEND) //Sem Sequencia de endereço
												//-- Posiciona no solicitante
												If DUE->(dbSeek(FwxFilial('DUE',DTQ->DTQ_FILORI)+DT5->DT5_CODSOL))
													cUfDes := DUE->DUE_EST
												EndIf
											Else //Com Sequencia de endereço
												// Posiciona na sequencia
												If DUL->(MsSeek(FwxFilial('DUL',DTQ->DTQ_FILORI)+DT5->(DT5_CODSOL+DT5_SEQEND)))
													cUfDes := DUL->DUL_EST
												EndIf
											EndIf
										EndIf
									EndIf
								EndIf
								
								// Adiciona o estado no array, caso o mesmo não exita
								If (nPosEst := AScan(aEstados, { |a| a[1] == cUfDes .AND. Iif( !lPrevist, a[3] > STRZERO(1,2),.T.) } ) ) <= 0
									
									AAdd( aItens, { {"DL1_SEQUEN",STRZERO(Len(aEstados)+1,2)},;
													{"DL1_UF",cUfDes} ,;
													{"DL1_UFORIG",cUFOri} ,;
													{"DL1_ORIGEM",Iif( DTQ->DTQ_STATUS == '5',"2","3")} ,; // Caso viagem em aberto ou fechada  Origem = 2 -Rota | caso em transito Origem = 3 - Não previsto
													{"DL1_MUNMAN", cMunMan },;
													{} } ) // Dever ser a ultima posição do Array

									Aadd(aEstados,{cUfDes,cUFOri,STRZERO(Len(aEstados)+1,2)})		
									nPosEst := AScan(aEstados, { |a| a[1] == cUfDes .AND. Iif(!lPrevist,  a[3] > STRZERO(1,2),.T.) } )
                                    
								Else // Caso ja exista manipula o estado de origem e o municipio
									nPosMunic := aScan(aItens[nPosEst],{|x| AllTrim(x[1]) == "DL1_MUNMAN"}) 
									nPosUfOri := aScan(aItens[nPosEst],{|x| AllTrim(x[1]) == "DL1_UFORIG"})  
									aItens[nPosEst][nPosMunic][2] := cMunMan
									aItens[nPosEst][nPosUfOri][2] := cUFOri
								EndIf

								nTamEst := Len(aItens[nPosEst])
								aItmPerc := {}

								// Preenche o array de documentos validos.
								Aadd(aItmPerc,{"DL2_FILORI", DTQ->DTQ_FILORI })
								Aadd(aItmPerc,{"DL2_VIAGEM", DTQ->DTQ_VIAGEM })
								Aadd(aItmPerc,{"DL2_FILDOC", DT6->DT6_FILDOC })
								Aadd(aItmPerc,{"DL2_DOC"   , DT6->DT6_DOC    })
								Aadd(aItmPerc,{"DL2_SERIE" , DT6->DT6_SERIE  })
								Aadd(aItmPerc,{"DL2_CLIREM", DT6->DT6_CLIREM })
								Aadd(aItmPerc,{"DL2_LOJREM", DT6->DT6_LOJREM })
								Aadd(aItmPerc,{"DL2_CLIDES", DT6->DT6_CLIDES })
								Aadd(aItmPerc,{"DL2_LOJDES", DT6->DT6_LOJDES })
								Aadd(aItmPerc,{"DL2_MUNMAN", cMunMan })
							

								Aadd(aItens[nPosEst][nTamEst],aItmPerc)

							EndIf

							DUD->(dbSkip())		
						EndDo

					EndIf
				Next nCount
			EndIf

			If Len(aItens) > 0
				Aadd(aCab,{"DL0_FILORI",cFilOri})
				Aadd(aCab,{"DL0_VIAGEM",cViagem})
				
				// Montar Tela
				dbSelectArea("DL0")
				DL0->(dbSetOrder(2))
				If lRoteiro
					nOpcPer := 3
					// Não exibe a tela de Percurso quando for rota de Roteiro.
					lExbPerc := .F.
				ElseIf lPerc
					DL0->(MsSeek( FWxFilial("DL0")+cFilOri+cViagem + Replicate("Z",Len(DL0->DL0_PERCUR)),.T.))
					DL0->(DbSkip(-1))
					nOpcPer := 4
					If DTQ->DTQ_STATUS == '5' // Status fechado
						Aadd(aCab,{"DL0_PERCUR",DL0->DL0_PERCUR})
					EndIf
				Else	
					nOpcPer := 3
				EndIf

				If DTQ->DTQ_STATUS $ "1,5" // Status em aberto ou fechado
					lExbPerc := lPercurso
				EndIf

				//-- Chama a rotina de processamento de percurso
				aRet := AF16IncPer(nOpcPer,aCab,aItens,!lExbPerc,aDelDocs)
				lRet := aRet[1]
			EndIf

		EndIf

	EndIf

	RestArea(aAreaDTQ)
	RestArea(aArea)
	RestArea(aAreaSM0)
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} MunOriCar()
Determina a região de Origem do municipio de carregamento
@author Rafael Souza
@since 04/01/2019
@version 1.0
-----------------------------------------------------------/*/
Static Function MunOriCar(cFilDoc, cDoc, cSerie)

Local cQuery 	:= ""
Local cAliasQry := ""
Local cRegMun	:= ""
Local aArea	 	:= GetArea()
Local cFNull	:= ""
Local cDbType	:= TCGetDB()
Local lNumSol   := .F.

Default cFilDoc := ""
Default cDoc	:= ""
Default cSerie	:= ""

// Tratamento para ISNULL em diferentes BD's
Do Case
Case cDbType $ "DB2/POSTGRES"
	cFNull	:= "COALESCE"
Case cDbType $ "ORACLE/INFORMIX"
	cFNull	:= "NVL"
Otherwise
	cFNull	:= "ISNULL"
EndCase

DTA->(dbSetOrder(1)) // DTA_FILIAL+DTA_FILDOC+DTA_DOC+DTA_SERIE+DTA_FILORI+DTA_VIAGEM
If DTA->(MsSeek(xFilial("DTA")+cFilDoc+cDoc+cSerie+DTQ->DTQ_FILORI+DTQ->DTQ_VIAGEM))
    If DTA->DTA_ORIGEM == "3"
        DTC->(dbSetOrder(3)) // DTC_FILIAL+DTC_FILDOC+DTC_DOC+DTC_SERIE+DTC_SERVIC+DTC_CODPRO
        If DTC->(MsSeek(xFilial("DTC")+cFilDoc+cDoc+cSerie))
            If !Empty(DTC->DTC_NUMSOL)
                lNumSol := .T.
            EndIf
        EndIf
    EndIf
EndIf

cQuery := "SELECT CASE " + CRLF
cQuery += " WHEN DTA_ORIGEM = '1' THEN " + cFNull + "(DA8.DA8_CDRORI,'') " + CRLF
cQuery += " WHEN DTA_ORIGEM = '2' THEN " + cFNull + "(SA1.A1_CDRDES,'') " + CRLF
cQuery += " WHEN DTA_ORIGEM = '3' THEN " + cFNull + "(DT5.DT5_CDRORI,'') " + CRLF 
cQuery += " END CDRORI " + CRLF
cQuery += "FROM " + RetSqlName("DTA") + " DTA " + CRLF
cQuery += "INNER JOIN " + RetSqlName("DA8") + " DA8 " + CRLF
cQuery += "	ON DA8_FILIAL = '" + xFilial("DA8") + "' " + CRLF
cQuery += "	AND DA8_COD = '" + DTQ->DTQ_ROTA + "' " + CRLF
cQuery += "	AND DA8.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("DT6") + " DT6 " + CRLF
cQuery += "	ON DT6_FILIAL = '" + xFilial("DT6") + "' " + CRLF
cQuery += "	AND DT6_FILDOC = DTA_FILDOC " + CRLF
cQuery += "	AND DT6_DOC = DTA_DOC " + CRLF
cQuery += "	AND DT6_SERIE = DTA_SERIE " + CRLF
cQuery += "	AND DT6.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN " + RetSqlName("SA1") + " SA1 " + CRLF
cQuery += "	ON A1_FILIAL = '" + xFilial("SA1") + "' " + CRLF
cQuery += "	AND A1_COD = DT6_CLIREM " + CRLF
cQuery += "	AND A1_LOJA = DT6_LOJREM " + CRLF
cQuery += "	AND SA1.D_E_L_E_T_ = ' ' " + CRLF

If lNumSol
    cQuery += "INNER JOIN " + RetSqlName("DTC") + " DTC " + CRLF
    cQuery += " ON DTC_FILIAL = '" + xFilial("DTC") + "' " + CRLF
    cQuery += " AND DTC_FILDOC = DT6_FILDOC " + CRLF
    cQuery += " AND DTC_DOC = DT6_DOC " + CRLF
    cQuery += " AND DTC_SERIE = DT6_SERIE " + CRLF
    cQuery += "	AND DTC.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += "LEFT JOIN " + RetSqlName("DT5") + " DT5 " + CRLF
    cQuery += "	ON DT5_FILIAL = '" + xFilial("DT5") + "' " + CRLF
    cQuery += "	AND DT5_FILORI = DTC_FILCFS " + CRLF
    cQuery += "	AND DT5_NUMSOL = DTC_NUMSOL " + CRLF
    cQuery += "	AND DT5.D_E_L_E_T_ = ' ' " + CRLF
Else
    cQuery += "LEFT JOIN " + RetSqlName("DT5") + " DT5 " + CRLF
    cQuery += "	ON DT5_FILIAL = '" + xFilial("DT5") + "' " + CRLF
    cQuery += "	AND DT5_FILORI = DT6_FILDOC " + CRLF
    cQuery += "	AND DT5_NUMSOL = DT6_DOC " + CRLF
    cQuery += "	AND DT5.D_E_L_E_T_ = ' ' " + CRLF
EndIf

cQuery += "WHERE DTA_FILIAL = '" + xFilial("DTA") + "' " + CRLF
cQuery += " AND DTA_FILDOC = '" + cFilDoc + "' " + CRLF
cQuery += " AND DTA_DOC = '" + cDoc + "' " + CRLF
cQuery += " AND DTA_SERIE = '" + cSerie + "' " + CRLF
cQuery += " AND DTA.D_E_L_E_T_ = ' '" + CRLF

cQuery	:= ChangeQuery(cQuery)
cAliasQry 	:= GetNextAlias()
dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)

If (cAliasQry)->(!Eof())
	cRegMun := (cAliasQry)->CDRORI  
EndIf 

(cAliasQry)->(DbCloseArea())

RestArea(aArea)

Return (cRegMun) 
