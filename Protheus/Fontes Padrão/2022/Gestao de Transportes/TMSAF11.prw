#Include 'TMSAF11.CH'
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

Static lNoUpd := .F.

/*/-----------------------------------------------------------
{Protheus.doc} TMSAF11
Tela de Distância entre Clientes

Uso: TMSAF11

@sample
//TMSAF11()

@author Paulo Henrique Corrêa Cardoso
@since 30/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSAF11()

Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DJG")
oBrowse:SetDescription(STR0001) //"Roteiro"
oBrowse:Activate()

// Desabilita o cache do View, para que o mesmo seja sempre atualizado.
oBrowse:SetCacheView( .F. )

Return NIL

 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  

Uso: TMSAF11

@sample
//MenuDef()

@author Paulo Henrique Corrêa Cardoso.
@since 30/08/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0003  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAF11" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAF11" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAF11" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0007  ACTION "VIEWDEF.TMSAF11" OPERATION 5 ACCESS 0 // "Excluir"

Return(aRotina)  


/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSAF11

@sample
//ModelDef()

@author Paulo Henrique Corrêa Cardoso.
@since 30/08/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()

Local oModel	 := NIL		// Objeto do Model
Local oStruDJG := NIL		// Recebe a Estrutura da tabela DJG
Local oStruDDJ := NIL		// Recebe a Estrutura da tabela DDJ

oStruDJG := FWFormStruct( 1, "DJG" )
oStruDDJ := FWFormStruct( 1, "DDJ" )

// Desabilita campos do grid em caso do roteiro já estar sendo utilizado em viagem
oStruDDJ:SetProperty( '*' , MODEL_FIELD_WHEN ,{|| ! lNoUpd  })

oModel := MPFormModel():New( "TMSAF11",,{|oModel|PosVldMdl(oModel)},/*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDJG',, oStruDJG,,,/*Carga*/ ) 

oModel:AddGrid("MdGridDDJ", "MdFieldDJG", oStruDDJ , {|oModelGrid,nLine,cAction| PreVldMdl(oModelGrid,nLine,cAction)} , /*bLinePost*/ , /*bPre*/,/*bpos*/, /*bLoad*/ )

oModel:SetRelation('MdGridDDJ',{ {"DDJ_FILIAL","FWxFilial('DDJ')"},{"DDJ_ROTEIR","DJG_ROTEIR"} }, DDJ->( IndexKey( 1 ) ) )

oModel:GetModel( "MdGridDDJ" ):SetUniqueLine( { "DDJ_ROTEIR","DDJ_SEQUEN","DDJ_CLIENT", "DDJ_LOJA", "DDJ_SEQEND"  } )


oModel:SetDescription( STR0001 )							  //"Roteiro
oModel:GetModel( 'MdFieldDJG' ):SetDescription( STR0001 ) //"Roteiro

oModel:GetModel( 'MdGridDDJ' ):SetDescription( STR0002 ) //"Pontos do Roteiro"

oModel:SetPrimaryKey({"DJG_FILIAL","DJG_ROTEIR"})  
     
// Valida a Ativação do Modelo
oModel:SetVldActivate( { |oModel| VldActMdl( oModel ) } )
     
oModel:SetActivate()
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAF11

@sample
//ViewDef()

@author Paulo Henrique Corrêa Cardoso.
@since 30/08/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	 := NIL	// Objeto do Model 
Local oStruDJG := NIL	// Recebe a Estrutura da tabela DJG
Local oStruDDJ := NIL	// Recebe a Estrutura da tabela DDJ
Local oView	 := NIL	// Recebe o objeto da View

oModel   := FwLoadModel("TMSAF11")
oStruDJG := FWFormStruct( 2, "DJG" )
oStruDDJ := FWFormStruct( 2, "DDJ",{|cCampo| !( AllTrim(cCampo)+"|" $ "DDJ_ROTEIR|DDJ_DESCRI|" ) })

oView := FwFormView():New()
oView:SetModel(oModel)     

VldActMdl( oModel )

oView:AddField('VwFieldDJG', oStruDJG , 'MdFieldDJG') 
oView:AddGrid( 'VwGridDDJ' , oStruDDJ , 'MdGridDDJ' )   

oView:CreateHorizontalBox('CABECALHO', 30)
oView:CreateHorizontalBox('GRID'	  , 70)  

oView:SetOwnerView('VwFieldDJG','CABECALHO')
oView:SetOwnerView('VwGridDDJ' ,'GRID'     )

oView:AddIncrementField('VwGridDDJ','DDJ_SEQUEN') 

// Adiciona a chamada da função de Reordenação.)
oView:SetFieldAction( 'DDJ_SEQUEN'		, { |oView,cIdForm,cIdCampo,cValue| Af011Reord(oView,cIdForm,cIdCampo,cValue) } )
oView:SetFieldAction( 'DDJ_CLIENT'		, { |oView,cIdForm,cIdCampo,cValue| Af11GatCli(oView,cIdForm,cIdCampo,cValue) } )
oView:SetFieldAction( 'DDJ_LOJA'		, { |oView,cIdForm,cIdCampo,cValue| Af11GatCli(oView,cIdForm,cIdCampo,cValue) } )
oView:SetFieldAction( 'DDJ_SEQEND'		, { |oView,cIdForm,cIdCampo,cValue| Af11GatCli(oView,cIdForm,cIdCampo,cValue) } )

Return oView 

/*/-----------------------------------------------------------
{Protheus.doc} VldActMdl
Pré-valida a Linha do grid

Uso: TMSAF11

@sample
//VldActMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 31/08/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function VldActMdl(oModel)
Local lRet       := .T.         // Recebe o Retorno         
Local nOperation := 0           // Recebe a Operacao realizada
Local aAreas     := {}          // Recebe as Areas Ativas

// Limpa a Variavel Static
lNoUpd := .F.

aAreas := { DJG->(GetArea()),DDJ->(GetArea()), GetArea() }

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE // Exclusão

	// Verifica se o roteiro ja é utilizado em alguma viagem
	If DJG->(!EOF()) .AND. RoteiInRot(DJG->DJG_ROTEIR)
		 lRet := .F. // Não permite a exclusão do roteiro
		 Help( "", 1, "TMSAF11001" ,,,5,11) // "O Registro não poderá ser excluido pois já esta sendo utilizado em rotas"
	EndIf
	
ElseIf nOperation == MODEL_OPERATION_UPDATE // Alteração

	// Verifica se o roteiro ja é utilizado em alguma viagem
	If !DJG->(EOF()) .AND. RoteiInRot(DJG->DJG_ROTEIR)
		lNoUpd := .T. // Só permite a Edição do campo Descrição do Reteiro
		Aviso(STR0020,STR0021,{ STR0022 },2) // "Alteração"### "Somente o campo 'Desc.Roteiro(DJG_DESCRI)' poderá ser alterado pois o registro já esta sendo utilizado em rotas" ### "OK"
	EndIf
	
EndIf

AEval( aAreas, { |x| RestArea(x) } )

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} RoteiInRot
Busca se o roteiro já esta em sendo utilizado em Rotas

Uso: TMSAF11

@sample
//RoteiInRot(nRecDJG)

@author Paulo Henrique Corrêa Cardoso.
@since 31/08/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function RoteiInRot(cRoteir)
Local lRet      := .F.              // Recebe o Retorno
Local aAreaDJH  := DJH->(GetArea()) // Recebe a Area da DJH

Default cRoteir := ""               // Recebe o codigo do roteiro

dbSelectArea("DJH")
DJH->(dbSetOrder(2)) // Filial + Codigo Roteiro

If DJH->( dbSeek( FwxFilial("DJH")+ cRoteir ) )
	lRet := .T.
EndIf

RestArea(aAreaDJH)

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PreVldMdl
Pré-valida a Linha do grid

Uso: TMSAF11

@sample
//PreVldMdl(oModelGrid)

@author Paulo Henrique Corrêa Cardoso.
@since 30/08/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PreVldMdl(oModelGrid,nLine,cAction)
Local lRet 		:= .T.					// Recebe o Retorno
Local aAreaDDJ	:= DDJ->(GetArea())	// Recebe a Area da tebela DDJ
Local oView       := FwViewActive()   // Recebe a View Ativa

oModelGrid:GoLine(nLine)

If cAction == 'DELETE' // Reordenação quando linha estiver sendo excluida

	TMSOrdDel(oView,oModelGrid,"DDJ_SEQUEN",nLine,.F.)
	
ElseIf cAction == 'UNDELETE' // Reordenação quando linha estiver sendo Recuperada

	TMSOrdDel(oView,oModelGrid,"DDJ_SEQUEN",nLine,.T.)
	
EndIf

RestArea(aAreaDDJ)	
Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Validação do Modelo

Uso: TMSAF11

@sample
//PosVldMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 30/08/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet 	   := .T.         // Recebe o Retorno
Local nOperation := 0           // Recebe a Operacao realizada
Local aAreas     := {}          // Recebe as Areas Ativas

aAreas := { DJG->(GetArea()),DDJ->(GetArea()), GetArea() }

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT

	
EndIf

AEval( aAreas, { |x| RestArea(x) } )

Return lRet

/*/-----------------------------------------------------------
{Protheus.doc} AF11xAut()
Rotina automatica de Cadastro de Distancia entre Clientes

Uso: TMSAF11

@sample
// AF11xAut(aCab,aItens,nOperat,lVisual)

@author Paulo Henrique Corrêa Cardoso.
@since 30/08/2016
@version 1.0
-----------------------------------------------------------/*/
Function  AF11xAut(aCab,aItens,nOperat,lVisual)
Local lRet        := .T.    // Recebe o Retorno Logico
Local aAreas      := {}     // Recebe as Areas Ativas
Local aErro       := {}     // Recebe o Array de Erros do MVC 
Local aErroAuto   := {}     // Recebe o Array de Erros do GetAutoGRLog()
Local cRetErro    := ""     // Recebe o Erro de Retorno
Local oModel      := NIL    // Recebe o modelo
Local oMdlFldDJG  := Nil    // Recebe o Objeto do Modelo do Field DJG
Local oStrucDJG   := Nil    // Recebe a Estrutura do Modelo do Field DJG
Local aFldDJG     := {}     // Recebe os Campos do Field DJG
Local oMdlGrdDDJ  := NIL    // Recebe o Objeto do Modelo do Grid DDJ	
Local oStrucDDJ   := NIL    // Recebe a Estrutura do Modelo do Grid DDJ
Local aGrdDDJ     := {}     // Recebe os Campos do Grid DDJ
Local nCount      := 0      // Recebe o Contador
Local nCount2     := 0      // Recebe o Contador 2
Local nItErro     := 0      // Recebe a linha de erro do grid
Local nPosRotei   := 0      // Recebe a Posição do campo de Roteiro
Local nPosDesc    := 0      // Recebe a Posição do campo de Descrição
Local nPosRotDDJ  := 0      // Recebe a Posição do campo de Roteiro do Grid
Local nPosSeqDDJ  := 0      // Recebe a Posição do campo de Sequencia do Grid
Local nLenGrdDDJ  := 0      // Recebe a linha do grid que foi adicionada

Default aCab     := {}                      // Recebe o Conteudo dos campos do cabeçalho
Default aItens   := {}                      // Recebe o Conteudo dos campos
Default nOperat  := MODEL_OPERATION_INSERT  // Recebe a Operação
Default lVisual  := .T.                     // Recebe se deve exibir componentes de tela

aAreas	:= { DJG->(GetArea()), DDJ->(GetArea()), GetArea() }

If Len(aCab) > 0 .AND. Len(aItens) > 0
	
	
	nPosRotei := aScan(aCab,{|x| AllTrim(x[1]) == "DJG_ROTEIR"})
	nPosDesc  := aScan(aCab,{|x| AllTrim(x[1]) == "DJG_DESCRI"})
	
	
	If nOperat == MODEL_OPERATION_UPDATE
		dbSelectArea("DJG")
		DJG->( dbSetOrder(1) )
		If !DJG->( dbSeek (FwxFilial("DJG") + aCab[nPosRotei][2]   ) )
			AutoGrLog(STR0008)  //"Resgistro não foi encontrado."
			cRetErro := STR0008 //"Resgistro não foi encontrado."
			lRet := .F.
		EndIf
		
	EndIf
	
	If lRet 
		// Inicializa o modelo
		oModel := FwLoadModel("TMSAF11") 
		oModel:SetOperation(nOperat)
		oModel:Activate()
		
		oMdlFldDJG := oModel:GetModel( "MdFieldDJG" )
		oStrucDJG  := oMdlFldDJG:GetStruct()
		aFldDJG    := oStrucDJG:GetFields()
		
		oMdlGrdDDJ := oModel:GetModel( "MdGridDDJ" )
		oStrucDDJ  := oMdlGrdDDJ:GetStruct()
		aGrdDDJ    := oStrucDDJ:GetFields()
		
		// Cabeçalho
		For nCount := 1 To Len( aCab )
			If ( aScan( aFldDJG, { |x| AllTrim( x[3] ) == AllTrim( aCab[nCount][1] ) } ) ) > 0
				If !Empty( aCab[nCount][2])
					If !(oModel:SetValue( "MdFieldDJG" , aCab[nCount][1], aCab[nCount][2]))
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nCount
		
		If lRet
			// Grid
			For nCount := 1 To Len( aItens )	
				
				nPosRotDDJ := aScan(aItens[nCount],{|x| AllTrim(x[1]) == "DDJ_ROTEIR"})
				nPosSeqDDJ := aScan(aItens[nCount],{|x| AllTrim(x[1]) == "DDJ_SEQUEN"})
				
				DDJ->( DbSetOrder(1) ) //DDR_FILIAL+DDR_FILORI+DDR_CODETI 
				If DDJ->( MsSeek(xFilial("DDJ") + aItens[nCount][nPosRotDDJ][2] + aItens[nCount][nPosSeqDDJ][2] ) )
					// Posiciona na etiqueta
					oMdlGrdDDJ:SeekLine( {{ "DDJ_ROTEIR", aItens[nCount][nPosRotDDJ][2]},{ "DDJ_SEQUEN", aItens[nCount][nPosSeqDDJ][2]}} )
				Else
					// Adiciona uma nova linha no Grid DDR
					nLenGrdDDJ := oMdlGrdDDJ:AddLine()
					
					// Posiciona na linha
					oMdlGrdDDJ:GoLine(nLenGrdDDJ)
				EndIf
				
				// Insere os valores do Grid DDJ
				For nCount2 := 1 To Len( aItens[nCount] )
					If ( aScan( aGrdDDJ, { |x| AllTrim( x[3] ) == AllTrim( aItens[nCount][nCount2][1] ) } ) ) > 0
						If !Empty( aItens[nCount][nCount2][2])
							If !(oModel:SetValue( "MdGridDDJ" , aItens[nCount][nCount2][1], aItens[nCount][nCount2][2]))
								lRet := .F.
								nItErro := nCount
								Exit
							EndIf
						EndIf
					EndIf
				Next nCount2
				
			Next nCount
		EndIf
		
		// Valida e grava as informações.
		If (lRet := oModel:VldData())
			lRet := oModel:CommitData()
		EndIf
		
		If !lRet		
			// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
			aErro := oModel:GetErrorMessage()
	        
			If Len(aErro) > 0 
				AutoGrLog(STR0009 + ' [' + AllToChar(aErro[1] ) + ']' ) //"Id do formulário de origem:"
				AutoGrLog(STR0010 + ' [' + AllToChar(aErro[2] ) + ']' ) //"Id do campo de origem: "
				AutoGrLog(STR0011 + ' [' + AllToChar(aErro[3] ) + ']' ) //"Id do formulário de erro: " 
				AutoGrLog(STR0012 + ' [' + AllToChar(aErro[4] ) + ']' ) //"Id do campo de erro: "
				AutoGrLog(STR0013 + ' [' + AllToChar(aErro[5] ) + ']' ) //"Id do erro: " 
				AutoGrLog(STR0014 + ' [' + AllToChar(aErro[6] ) + ']' ) //"Mensagem do erro: "
				AutoGrLog(STR0015 + ' [' + AllToChar(aErro[7] ) + ']' ) //"Mensagem da solução: "
				AutoGrLog(STR0016 + ' [' + AllToChar(aErro[8] ) + ']' ) //"Valor atribuído: " 
				AutoGrLog(STR0017 + ' [' + AllToChar(aErro[9] ) + ']' ) //"Valor anterior: "
				
				//Se o Erro ocorrer nos itens
				If nItErro > 0
					AutoGrLog(STR0018 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) //"Erro no Item: "	
				EndIf
				
			EndIf	
			
			// Monta o Erro de Retorno	
			aErroAuto := GetAutoGRLog()	 
			
			For nCount := 1 To Len(aErroAuto)
				TmsLogMsg('ERROR',aErroAuto[nCount])
				cRetErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + (" ")
			Next
			cRetErro := EncodeUTF8(cRetErro)	
				
		EndIf
			
		oModel:DeActivate()
	EndIf
Else
	AutoGrLog(STR0019) //"Conteudo do registro DJG e/ou DDJ não foi preenchido"
	cRetErro := STR0019 //"Conteudo do registro DJG e/ou DDJ não foi preenchido"
	lRet := .F.
EndIf

// Exibe o Erro 	
If lVisual .AND. !lRet
	MostraErro()
EndIf

AEval( aAreas, { |x| RestArea(x) } )

Return({lRet,cRetErro})

/*/-----------------------------------------------------------
{Protheus.doc} Af011Reord
Realiza a Reordenação do Grid de Roteiros

Uso: TMSAF11

@sample
//Af012Reord(oView,cIdForm,cIdCampo,cValue)

@author Paulo Henrique Corrêa Cardoso.
@since 08/06/2016
@version 1.0
-----------------------------------------------------------/*/
Function Af011Reord(oView,cIdForm,cIdCampo,cValue)
Local aArea      := GetArea()      // Recebe a Area Atual
Local oModel     := NIL            // Recebe o modelo
Local nLine  

Default oView    := FwViewActive() // Recebe a View ativa
Default cIdForm  := ""             // Recebe o Id do formulario
Default cIdCampo := ""             // Recebe o Id do Campo
Default cValue   := ""             // Recebe o valor do campo

// Monta o objeto do ModelGrid
oModel := oView:GetModel()
oViewObj := oView:GetViewObj(cIdForm)     
oModelGrid := oModel:GetModel( oViewObj[6] )
nLine := oModelGrid:GetLine()

// Chama a Função de Reordenação 
TMSOrdGrd(oView,oModelGrid,cIdForm,cIdCampo,cValue)

 //Atualiza a tela     
oView:Refresh(cIdForm) //Atualiza a tela   
oView:GoLine(oModelGrid:getId(),nLine)


RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Af11GatCli
Gatilha os Campos apartir do Cliente

@author Paulo Henrique  

@since 07/05/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function Af11GatCli(oView,cIdForm,cIdCampo,cValue)
Local oModel		 := NIL				// Recebe o Modelo 
Local oModelGrid	 := NIL				// Recebe o Modelo do Grid
Local aArea		 := GetArea()			// Recebe a area Ativa
Local oViewObj   	 := NIL				// Recebe o Objeto contendo dados da View
Local cClient		 := ""					// Recebe o Cliente
Local cLoja		 := ""					// Recebe a loja do Cliente
Local nLineAtu	 := 0					// Recebe a Linha atual
Local nAntLine	 := 0					// Recebe a linha anterior
Local cSeqEnd		 := ""					// Recebe a Sequencia de Endereço
Local cSeqAtu		 := ""               // Recebe a Sequencia Atual
Local cSeqAnt		 := ""               // Recebe a Sequencia do Anterior

Default oView		 := FwViewActive() 	// Recebe o Objeto do View
Default cIdForm	 := "VwGridDDJ"		// Recebe o Id do Formulario
Default cIdCampo	 := "" 				// Recebe o Id do Campo
Default cValue	 := "" 				// Recebe o Valor do campo

// Recebe o Modelo do Grid
oModel := oView:GetModel()

// Recebe as Informações da view apartir do nome do formulario
oViewObj := oView:GetViewObj(cIdForm)

// Recebe o modelo do grid     
oModelGrid := oModel:GetModel( oViewObj[6] ) //Grid do folder

// recebe a linha atual
nLineAtu := oModelGrid:GetLine()


// Ajusta a Sequencia da linha 	
nAntLine := LinValida(oModelGrid,nLineAtu,.F.)
cSeqAtu :=  oModelGrid:GetValue("DDJ_SEQUEN",nLineAtu)
If nAntLine > 0
	cSeqAnt :=  oModelGrid:GetValue("DDJ_SEQUEN",nAntLine)	
EndIf

If Val(cSeqAnt) + 1 != Val(cSeqAtu)  
	oModelGrid:LoadValue("DDJ_SEQUEN", STRZERO( Val(cSeqAnt) + 1 , TamSx3('DDJ_SEQUEN')[1]) )	
EndIf


//Preenche as variaveis de Cliente e loja
If cIdCampo == "DDJ_CLIENT"
	
	cClient := cValue
	cLoja	 := oModelGrid:GetValue("DDJ_LOJA")
	cSeqEnd := oModelGrid:GetValue("DDJ_SEQEND")
	
ElseIf cIdCampo == "DDJ_LOJA"
	
	cClient := oModelGrid:GetValue("DDJ_CLIENT")
	cLoja	 := cValue
	cSeqEnd := oModelGrid:GetValue("DDJ_SEQEND")
	
ElseIf cIdCampo == "DDJ_SEQEND"

	cClient := oModelGrid:GetValue("DDJ_CLIENT")
	cLoja	 := oModelGrid:GetValue("DDJ_LOJA")
	cSeqEnd := cValue
EndIf

If !Empty(cClient) .AND. !Empty(cLoja)
	
	dbSelectArea("SA1")
	SA1->(dbSetOrder(1))
	
	If SA1->( dbSeek(FwxFilial("SA1") + cClient + cLoja) )
		
		// Preenche os dados do Cliente
		oModelGrid:LoadValue("DDJ_NOME",	SA1->A1_NOME)
		oModelGrid:LoadValue("DDJ_END",		SA1->A1_END)
		oModelGrid:LoadValue("DDJ_BAIRRO",	SA1->A1_BAIRRO)
		oModelGrid:LoadValue("DDJ_MUN",		SA1->A1_MUN)
		oModelGrid:LoadValue("DDJ_EST",		SA1->A1_EST)
		
		// Verifica campo sequencia de Endereço
		If !Empty(cSeqEnd)
			dbSelectArea("DUL")
			DUL->(dbSetOrder(2))
			If DUL->( dbSeek(FwxFilial("DUL") + cClient + cLoja +  cSeqEnd ) )
				oModelGrid:LoadValue("DDJ_END",		DUL->DUL_END)
				oModelGrid:LoadValue("DDJ_BAIRRO",	DUL->DUL_BAIRRO)
				oModelGrid:LoadValue("DDJ_MUN",		DUL->DUL_MUN)
				oModelGrid:LoadValue("DDJ_EST",		DUL->DUL_EST)
			EndIf
		EndIf
	EndIf
Else
	// Limpa os dados do Cliente 
	oModelGrid:LoadValue("DDJ_NOME",	"")
	oModelGrid:LoadValue("DDJ_END",		"")
	oModelGrid:LoadValue("DDJ_BAIRRO",	"")
	oModelGrid:LoadValue("DDJ_MUN",		"")
	oModelGrid:LoadValue("DDJ_EST",		"")		
EndIf

oModelGrid:GoLine(nLineAtu) //posiciona na linha    
oView:Refresh(cIdForm) //Atualiza a tela 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} F11RotRote
Verifica se é uma Rota com Roteiro

@author Katia
@since 26/10/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function F11RotRote(cRota)
Local lRet:= .F.

Default cRota:= ""

If AliasIndic("DJH")
	DbSelectArea("DJH")
	DJH->(DbSetOrder(1))
	If DJH->(DbSeek(xFilial("DJH")+cRota))
		lRet:= .T.
	EndIf
EndIf
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AF11RetInf
Verifica se é uma Rota com Roteiro

@author Leandro Paulino
@since 07/05/17
@version 1.0
/*/
//-------------------------------------------------------------------
Function AF11RetInf(cFilOri, cViagem)

Local cQuery := ''
Local cAlias := GetNextAlias()
Local aAreas := { DTC->(GetArea()), DT5->(GetArea()), DJJ->(GetArea()),  DDJ->(GetArea()) , DJK->(GetArea()), DJF->(GetArea()), GetArea() }
Local aRetInf:= {}

    //-- Recarrega Variaveis Antes Da Execução
	//Pergunte( cPerg , .f. )
    cQuery := " SELECT DISTINCT	DJK.DJK_SEQUEN, DJK.DJK_EST , DTC.DTC_CLIREM , DTC.DTC_LOJREM , DTC.DTC_CLIDES , DTC.DTC_LOJDES , DJF.DJF_TIPOPE , "

	cQuery += " CASE "
	cQuery += " 	WHEN DTC.DTC_FILDOC <> 'NULL' AND DJF.DJF_TIPOPE <> '1' THEN DTC.DTC_FILDOC "
    cQuery += "   	WHEN DTC.DTC_FILDOC <> 'NULL' AND DJF.DJF_TIPOPE  = '1' THEN '' 			"
    cQuery += " 	WHEN DT5.DT5_FILDOC <> 'NULL' AND DJF.DJF_TIPOPE  = ''  THEN ''				"                                    
    cQuery += "		ELSE DT5.DT5_FILDOC 														"
    cQuery += " END AS DT6_FILDOC, 																"
    
	cQuery += " CASE "
	cQuery += " 	WHEN DTC.DTC_DOC <> 'NULL' AND DJF.DJF_TIPOPE <> '1' THEN DTC.DTC_DOC "
    cQuery += "   	WHEN DTC.DTC_DOC <> 'NULL' AND DJF.DJF_TIPOPE  = '1' THEN '' 		  "
    cQuery += " 	WHEN DT5.DT5_DOC <> 'NULL' AND DJF.DJF_TIPOPE  = ''  THEN ''		  "                                    
    cQuery += "		ELSE DT5.DT5_DOC 													  "	
    cQuery += " END AS DT6_DOC, "
    
	cQuery += " CASE "
	cQuery += " 	WHEN DTC.DTC_SERIE <> 'NULL' AND DJF.DJF_TIPOPE <> '1' THEN DTC.DTC_SERIE "
    cQuery += "   	WHEN DTC.DTC_SERIE <> 'NULL' AND DJF.DJF_TIPOPE  = '1' THEN '' 			  "
    cQuery += " 	WHEN DT5.DT5_SERIE <> 'NULL' AND DJF.DJF_TIPOPE  = ''  THEN ''			  "                                    
    cQuery += "		ELSE DT5.DT5_SERIE 
    cQuery += " END AS DT6_SERIE "

	cQuery += " FROM        " + RetSqlName("DDJ") 	+ " DDJ "  			//--ROTEIROS

	cQuery += " INNER JOIN	" + RetSqlName("DJF") 	+ " DJF "			//--ROTEIROS DA VIAGEM
	cQuery += " ON 			DJF.DJF_FILIAL = '" 	+ FwxFilial('DJF')	+ "' "
	cQuery += " AND 		DJF.DJF_TIPOPE <> '1' 							 "
	cQuery += " AND 		DJF.DJF_ROTEIR = DDJ_ROTEIR 					 "
	cQuery += " AND 		DJF.D_E_L_E_T_ = ' ' 							 "

	cQuery += " INNER JOIN	" + RetSqlName("DJK") 	+ " DJK "  			//--ESTADOS DE PASSAGEM DO ROTEIRO 
	cQuery += "	ON 			DJK.DJK_FILIAL = '"		+ FwXFilial('DJK')	+ "' "
	cQuery += " AND 		DJK.DJK_IDDJF  = DJF.DJF_IDLIN "
	cQuery += " AND 		DJK.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN  " + RetSqlName("DJJ")	+ " DJJ " 			//-- DOCUMENTOS DO TRECHO
	cQuery += " ON			DJJ.DJJ_FILIAL = '"		+ FwxFilial('DJJ')	+ "' "
	cQuery += " AND			DJJ.DJJ_FILORI = DJF.DJF_FILORI	"
	cQuery += " AND			DJJ.DJJ_VIAGEM = DJF.DJF_VIAGEM "
	cQuery += " AND			DJJ.DJJ_CLIENT = DJF.DJF_CLIENT "
	cQuery += " AND			DJJ.DJJ_LOJA   = DJF.DJF_LOJA   "
	cQuery += " AND 		DJJ.D_E_L_E_T_ = ' ' "

	cQuery += " LEFT JOIN  " + RetSqlName("DTC") 	+ " DTC " 			//-- DOCUMENTOS DE TRANSPORTE
	cQuery += " ON			DTC.DTC_FILIAL = '" + FwxFilial('DTC')		+ "' "
	cQuery += "	AND 		DTC.DTC_FILIAL||DTC.DTC_FILORI||DTC.DTC_LOTNFC+DTC.DTC_CLIREM||DTC.DTC_LOJREM||DTC.DTC_CLIDES||DTC.DTC_LOJDES||DTC.DTC_SERVIC||DTC.DTC_CODPRO||DTC.DTC_NUMNFC||DTC.DTC_SERNFC = DJJ.DJJ_CHAVE "
	cQuery += "	AND 		DTC.DTC_CLIDES = DJJ.DJJ_CLIENT "
	cQuery += " AND			DTC.DTC_LOJDES = DJJ.DJJ_LOJA	"
	cQuery += "	AND			DTC.D_E_L_E_T_ = ' ' 			"

	cQuery += " LEFT JOIN  " + RetSqlName("DT5")	+ " DT5 "			//--Solicitações de Coleta
	cQuery += "	ON          DT5.DT5_FILIAL = '" + FwxFilial("DT5") 		+ "' "
	cQuery += " AND         DT5.DT5_FILIAL+DT5.DT5_FILORI+DT5.DT5_NUMSOL = DJJ.DJJ_CHAVE "
	cQuery += " AND         DT5.DT5_CLIREM = DJJ.DJJ_CLIENT "
	cQuery += " AND         DT5.DT5_LOJREM = DJJ.DJJ_LOJA   "
	cQuery += " AND			DT5.DT5_SEQEND = DDJ.DDJ_SEQEND "
	cQuery += " AND         DT5.D_E_L_E_T_ = ' ' 			"

	cQuery += " LEFT JOIN " + RetSqlName("DT6") + " DT6 "
	cQuery += " ON  		DT6.DT6_FILIAL  = '" + FwxFilial('DT6') + "' "
	cQuery += "	AND 		DT6.DT6_FILDOC  = DTC.DTC_FILDOC		     "
	cQuery += " AND 		DT6.DT6_DOC		= DTC.DTC_DOC				 " 
	cQuery += " AND 		DT6.DT6_SERIE	= DTC.DTC_SERIE				 " 
	cQuery += " OR 		(	DT6.DT6_FILDOC  = DT5.DT5_FILDOC			 "
	cQuery += "	AND 		DT6.DT6_DOC		= DT5.DT5_DOC 				 "
	cQuery += " AND 		DT6.DT6_SERIE	= DT5.DT5_SERIE )			 "

	cQuery += " INNER JOIN " + RetSqlName("SA1") 	+ " SA1 "
	cQuery += "	ON 			SA1.A1_FILIAL = '" + FWxFilial('SA1') 		+ "' "
	cQuery += " AND 		SA1.A1_COD	  = DJF.DJF_CLIENT	"
	cQuery += " AND			SA1.A1_LOJA   = DJF.DJF_LOJA	"
	cQuery += " AND 		SA1.A1_EST 	  = DJK.DJK_EST 	"		
	cQuery += " AND			SA1.D_E_L_E_T_= ' '			"
	
    cQuery += " WHERE       DJF.DJF_FILORI  =   '" + cFilOri   + "' " 
    cQuery += " AND         DJF.DJF_VIAGEM  =   '" + cViagem   + "' "
    cQuery += " AND         DJF.DJF_CLIENT  <> 'FILIAL ' "
	cQuery += " AND 		DJF.DJF_CLIDEV  = '" + Space(Len(DJF->DJF_CLIDEV)) + "' "
	cQuery += " AND 		DJF.DJF_LOJDEV  = '" + Space(Len(DJF->DJF_LOJDEV)) + "' "
	cQuery += " AND 		DJJ.DJJ_CLIDEV  = '" + Space(Len(DJJ->DJJ_CLIDEV)) + "' "
	cQuery += " AND         DJJ.DJJ_LOJDEV  = '" + Space(Len(DJJ->DJJ_LOJDEV)) + "' "
    cQuery += "	AND         DDJ.DDJ_FILIAL  =  '" + FwxFilial("DDJ") 		+ "' "
	cQuery += " AND         DDJ.D_E_L_E_T_  =  ' '"
	cQuery += " AND			(DTC.DTC_DOC <> 'NULL' OR DT5.DT5_DOC <> 'NULL') "

	cQuery += " UNION ALL " 
	
	cQuery += " SELECT DISTINCT DJK.DJK_SEQUEN			, DJK.DJK_EST					, DJK.D_E_L_E_T_ DTC_CLIREM, DJK.D_E_L_E_T_ DTC_LOJREM	, DJK.D_E_L_E_T_ DTC_CLIDES, DJK.D_E_L_E_T_ DTC_LOJDES, "
	cQuery += " 				DJK_ORIGEM DJF_TIPOPE	, DJK.D_E_L_E_T_ DT6_FILDOC, DJK.D_E_L_E_T_ DTC_DOC		, DJK.D_E_L_E_T_ DTC_SERIE "   
	
	cQuery += " FROM " + RetSqlName("DJK") + " DJK " 
	
	cQuery += " WHERE 		DJK.DJK_FILIAL =    '" + FWxFilial('DJK') + "' "
	cQuery += " AND 		DJK.DJK_FILORI = 	'" + cFilOri + "' "
	cQuery += " AND 		DJK.DJK_VIAGEM = 	'" + cViagem + "' "
	cQuery += " AND 		DJK.DJK_ORIGEM = '1' "
	cQuery += " AND 		DJK.D_E_L_E_T_ = ' ' " 
	
	cQuery += " UNION ALL	
	
	cQuery += " SELECT DISTINCT DJK.DJK_SEQUEN,	DJK.DJK_EST, DJF.DJF_CLIENT	DTC_CLIREM, DJF.DJF_LOJA	DTC_LOJA	, DJF.DJF_CLIDEV	DTC_CLIDES, "
	cQuery += "					DJF.DJF_LOJDEV	DTC_LOJDES , DJF.DJF_TIPOPE	DJF_TIPOPE, DJF.D_E_L_E_T_	DT6_FILDOC	, DJF.D_E_L_E_T_	DTC_DOC	  , " 
	cQuery += "					DJF.D_E_L_E_T_	DTC_SERIE "

	cQuery += " FROM " + RetSqlName("DJF") + " DJF"
	
	cQuery += "	INNER JOIN " + RetSqlName("DJK") + " DJK " 		//--ESTADOS DE PASSAGEM DO ROTEIRO
	cQuery += "	ON 			DJK.DJK_FILIAL = 				'"		+ FwXFilial('DJK')	+ "' "
	cQuery += " AND 		DJK.DJK_IDDJF  = DJF.DJF_IDLIN 	 "
	cQuery += " AND 		DJK.D_E_L_E_T_ = ' ' 			 "

	cQuery += " WHERE 		DJK.DJK_FILORI = '" + cFilOri + "' "
	cQuery += " AND 		DJK.DJK_VIAGEM = '" + cViagem + "' "
	cQuery += " AND 		DJF.DJF_CLIDEV = '" + Space(Len(DJF->DJF_CLIDEV)) + "' "
	cQuery += " AND 		DJF.DJF_LOJDEV = '" + Space(Len(DJF->DJF_LOJDEV)) + "' "
	cQuery += " AND 		DJF.DJF_TIPOPE IN ('1','6') "
	cQuery += " AND   		DJF.D_E_L_E_T_ = ' ' "
	
	cQuery += " ORDER BY	DJK.DJK_SEQUEN "	

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	While (cAlias)->(!Eof())
		AADD(aRetInf,{	(cAlias)->DJK_EST	   	,(cAlias)->DT6_FILDOC,(cAlias)->DT6_DOC,(cAlias)->DT6_SERIE,(cAlias)->DTC_CLIREM,(cAlias)->DTC_LOJREM,(cAlias)->DTC_CLIDES, ;
						(cAlias)->DTC_LOJDES	,(cAlias)->DJF_TIPOPE} )
		(cAlias)->(dbSkip())
	End

	(cAlias)->(DbCloseArea())

AEval( aAreas, { |x| RestArea(x) } )

Return aRetInf


/*
============================================================================================================
/{Protheus.doc} TMSAF11Vld
//TODO validação de campos X3_VALID
@author Kati Bianchi
@since 31/07/2018
@version undefined

@type function
============================================================================================================
/*/
Function TMSAF11Vld()
Local cCampo     := ReadVar()
Local lRet       := .T.
Local aArea      := GetArea()

If	cCampo $ 'M->DDJ_CLIENT'
	SA1->(DBSETORDER(1))
	If SA1->(MSSEEK( XFILIAL("SA1") + FwFldGet("DDJ_CLIENT")  ))
		lRet	:= .T. 
	Else 
		lRet	:= .F. 
	EndIf 

ElseIf cCampo $ 'M->DDJ_LOJA'
	If !Empty(FwFldGet("DDJ_LOJA"))
		lRet	:= ExistCpo("SA1",FwFldGet("DDJ_CLIENT") + RTrim(FwFldGet("DDJ_LOJA")) ,1)
	EndIf 
EndIf


If !lRet
	HELP(" ",1,"REGNOIS")
EndIf

RestArea(aArea)
Return lRet
