#Include 'TMSAF14.CH'
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

/*/-----------------------------------------------------------
{Protheus.doc} TMSAF14
Tela de Distância entre Clientes

Uso: TMSAF14

@sample
//TMSAF14()

@author Paulo Henrique Corrêa Cardoso
@since 18/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSAF14()

Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("DDO")
oBrowse:SetDescription(STR0001) //"Distância entre Clientes"
oBrowse:Activate()

Return NIL

 /*/-----------------------------------------------------------
{Protheus.doc} MenuDef()
Utilizacao de menu Funcional  
Uso: TMSAF14
@sample
//MenuDef()

@author Paulo Henrique Corrêa Cardoso.
@since 18/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function MenuDef()

Local aRotina := {}

	ADD OPTION aRotina TITLE STR0002  ACTION "AxPesqui"        OPERATION 1 ACCESS 0 // "Pesquisar"
	ADD OPTION aRotina TITLE STR0003  ACTION "VIEWDEF.TMSAF14" OPERATION 2 ACCESS 0 // "Visualizar"
	ADD OPTION aRotina TITLE STR0004  ACTION "VIEWDEF.TMSAF14" OPERATION 3 ACCESS 0 // "Incluir"
	ADD OPTION aRotina TITLE STR0005  ACTION "VIEWDEF.TMSAF14" OPERATION 4 ACCESS 0 // "Alterar"
	ADD OPTION aRotina TITLE STR0006  ACTION "VIEWDEF.TMSAF14" OPERATION 5 ACCESS 0 // "Excluir"

Return(aRotina)  


/*/-----------------------------------------------------------
{Protheus.doc} ModelDef()
Definição do Modelo

Uso: TMSAF14

@sample
//ModelDef()

@author Paulo Henrique Corrêa Cardoso.
@since 18/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function ModelDef()

Local oModel	 := NIL		// Objeto do Model
Local oStruDDO := NIL		// Recebe a Estrutura da tabela DDO

oStruDDO:= FWFormStruct( 1, "DDO" )

oModel := MPFormModel():New( "TMSAF14",,{|oModel|PosVldMdl(oModel)},/*bCommit*/, /*bCancel*/ ) 
oModel:AddFields( 'MdFieldDDO',, oStruDDO,,,/*Carga*/ ) 

oModel:SetDescription( STR0001 )							//"Distância entre Clientes"
oModel:GetModel( 'MdFieldDDO' ):SetDescription( STR0001 ) 	//"Distância entre Clientes" 

oModel:SetPrimaryKey({"DDO_FILIAL","DDO_CODCLI","DDO_LOJCLI","DDO_CLIDE","DDO_LOJDE","DDO_SEQDE","DDO_CLIATE","DDO_LOJATE","DDO_SEQATE"  })  
     
oModel:SetActivate()
     
Return oModel 

/*/-----------------------------------------------------------
{Protheus.doc} ViewDef()
Definição da View

Uso: TMSAF14

@sample
//ViewDef()

@author Paulo Henrique Corrêa Cardoso.
@since 18/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function ViewDef()     
Local oModel	 := NIL	// Objeto do Model 
Local oStruDDO := NIL	// Recebe a Estrutura da tabela DDO
Local oView	 := NIL	// Recebe o objeto da View

oModel   := FwLoadModel("TMSAF14")
oStruDDO := FWFormStruct( 2, "DDO" )

oView := FwFormView():New()
oView:SetModel(oModel)     

oView:AddField('VwFieldDDO', oStruDDO , 'MdFieldDDO') 

oView:CreateHorizontalBox('CABECALHO', 100)
oView:SetOwnerView('VwFieldDDO','CABECALHO')

Return oView 

/*/-----------------------------------------------------------
{Protheus.doc} PosVldMdl()
Validação do Modelo

Uso: TMSAF14

@sample
//PosVldMdl(oModel)

@author Paulo Henrique Corrêa Cardoso.
@since 19/05/2016
@version 1.0
-----------------------------------------------------------/*/
Static Function PosVldMdl(oModel)
Local lRet 	   := .T.    				// Recebe o Retorno
Local nOperation := 0					// Recebe a Operacao realizada
Local aAreaDDO   := DDO->(GetArea())	// Recebe a Area DDO Ativa
Local cChave     := ""					// Recebe a Chave de Seek DDO

nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_INSERT

	cChave := FwxFilial("DDO")
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_CODCLI' )
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_LOJCLI' )
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_CLIDE' )
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_LOJDE' )
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_SEQDE' )
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_CLIATE' )
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_LOJATE' )
	cChave += oModel:GetValue( 'MdFieldDDO', 'DDO_SEQATE' )

	dbSelectArea("DDO")
	DDO->(dbSetOrder(1))
	
	If  DDO->( dbSeek ( cChave ) )
		lRet := .F.
		oModel:SetErrorMessage (,,,,,STR0018)//"Ja existe distancia cadastrada para esses clientes." 
	EndIf
EndIf

RestArea( aAreaDDO )
Return lRet


/*/-----------------------------------------------------------
{Protheus.doc} TMSAF15Vld()
Validação de campos 

Uso: TMSAF14

@sample
//TMSAF15Vld()

@author Paulo Henrique Corrêa Cardoso.
@since 18/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function TMSAF14Vld() 
Local lRet   		:= .T.			// Recebe o Retorno
Local aArea  		:= GetArea()	// Recebe a Area Ativa 
Local cCampo 		:= ReadVar()	// Recebe o Campo
Local cCliente	:= ""			// Recebe o Cliente
Local cLoja	    := ""			// Recebe a Loja do Cliente
Local cSequen		:= ""			// Recebe a Sequencia do Cliente


If cCampo $ 'M->DDO_SEQDE|M->DDO_SEQATE'

	If cCampo $ 'M->DDO_SEQDE'
		cCliente  := M->DDO_CLIDE 
		cLoja	  := M->DDO_LOJDE	
		cSequen	  := M->DDO_SEQDE
		
	ElseIf  cCampo $ 'M->DDO_SEQATE'
		cCliente  := M->DDO_CLIATE 
		cLoja	  := M->DDO_LOJATE
		cSequen	  := M->DDO_SEQATE
	EndIf
	
	If !Empty(cCliente) .AND. !Empty(cLoja) .AND. !Empty(cSequen)
		
		DUL->(DbSetOrder(2))
		If !DUL->(MsSeek(xFilial("DUL")+cCliente+cLoja+cSequen))
				Help(" ",1,"TMSAF1401") //-- Sequencia de endereco nao encontrada para o Cliente.
				lRet := .F.   
		EndIf
	EndIf
EndIf

RestArea( aArea )

Return lRet      


/*/-----------------------------------------------------------
{Protheus.doc} AF14xAut()
Rotina automatica de Cadastro de Distancia entre Clientes

Uso: TMSAF14

@sample
// AF14xAut(aConteud,nOperat,lVisual)

@author Paulo Henrique Corrêa Cardoso.
@since 19/05/2016
@version 1.0
-----------------------------------------------------------/*/
Function  AF14xAut(aConteud,nOperat,lVisual)
Local lRet			:= .T.		// Recebe o Retorno Logico
Local aAreas		:= {}		// Recebe as Areas Ativas
Local aErro		:= {}		// Recebe o Array de Erros do MVC 
Local aErroAuto 	:= {}		// Recebe o Array de Erros do GetAutoGRLog()
Local cRetErro	:= ""		// Recebe o Erro de Retorno
Local oModel		:= NIL		// Recebe o modelo
Local oMdlFldDDO	:= Nil		// Recebe o Objeto do Modelo do Field DDO
Local oStrucDDO	:= Nil		// Recebe a Estrutura do Modelo do Grid DDW
Local aFldDDO		:= {}		// Recebe os Campos do Grid DDR
Local nPosCodCli	:= 0		// Recebe a posição do campo DDO_CODCLI
Local nPosLojCli	:= 0		// Recebe a posição do campo DDO_LOJCLI
Local nPosCliDe	:= 0 		// Recebe a posição do campo DDO_CLIDE
Local nPosLojDe	:= 0		// Recebe a posição do campo DDO_LOJDE
Local nPosSeqDe	:= 0		// Recebe a posição do campo DDO_SEQDE
Local nPosCliAte	:= 0		// Recebe a posição do campo DDO_CLIATE
Local nPosLojAte	:= 0		// Recebe a posição do campo DDO_LOJATE
Local nPosSeqAte	:= 0		// Recebe a posição do campo DDO_SEQATE
Local nPosKM		:= 0		// Recebe a posição do campo DDO_KM
Local nCount		:= 0		// Recebe o Contador
Local aNewCont	:= {}		// Recebe as alterações caso seja edição

Default aConteud := {}							// Recebe o Conteudo dos campos
Default nOperat  := MODEL_OPERATION_INSERT	// Recebe a Operação
Default lVisual  := .T.							// Recebe se deve exibir componentes de tela

aAreas	:= { DDO->(GetArea()), DDJ->(GetArea()), GetArea() }

If Len(aConteud) > 0
	
	
	nPosCodCli := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_CODCLI"})
	nPosLojCli := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_LOJCLI"})
	nPosCliDe  := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_CLIDE" })
	nPosLojDe  := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_LOJDE" })
	nPosSeqDe  := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_SEQDE" })
	nPosCliAte := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_CLIATE"})
	nPosLojAte := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_LOJATE"})
	nPosSeqAte := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_SEQATE"})
	nPosKM     := aScan(aConteud,{|x| AllTrim(x[1]) == "DDO_KM"})
	
	If nOperat == MODEL_OPERATION_UPDATE
		dbSelectArea("DDO")
		DDO->( dbSetOrder(1) )
		If DDO->( dbSeek (FwxFilial("DDO") + aConteud[nPosCodCli][2] + aConteud[nPosLojCli][2] + aConteud[nPosCliDe][2]+ ;
			aConteud[nPosLojDe][2] + aConteud[nPosSeqDe][2] + aConteud[nPosCliAte][2] + aConteud[nPosLojAte][2] + aConteud[nPosSeqAte][2] ) )
			
			AADD(aNewCont, {aConteud[nPosKM][1],aConteud[nPosKM][2]})
			
			aConteud := aClone(aNewCont)
		Else	
			AutoGrLog(STR0007) //"Resgistro não foi encontrado."
			cRetErro := STR0007 //"Resgistro não foi encontrado."
			lRet := .F.
		EndIf
		
	EndIf
	
	If lRet 
		// Inicializa o modelo
		oModel := FwLoadModel("TMSAF14") 
		oModel:SetOperation(nOperat)
		oModel:Activate()
		
		oMdlFldDDO := oModel:GetModel( "MdFieldDDO" )
		oStrucDDO  := oMdlFldDDO:GetStruct()
		aFldDDO    := oStrucDDO:GetFields()
		
		For nCount := 1 To Len( aConteud )
			If ( aScan( aFldDDO, { |x| AllTrim( x[3] ) == AllTrim( aConteud[nCount][1] ) } ) ) > 0
				If !Empty( aConteud[nCount][2])
					If !(oModel:SetValue( "MdFieldDDO" , aConteud[nCount][1], aConteud[nCount][2]))
						lRet := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nCount
	
		// Valida e grava as informações.
		If (lRet := oModel:VldData())
			lRet := oModel:CommitData()
		EndIf
		
		If !lRet		
			// Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
			aErro := oModel:GetErrorMessage()
	        
			If Len(aErro) > 0 
				AutoGrLog(STR0008 + ' [' + AllToChar(aErro[1] ) + ']' ) //"Id do formulário de origem:"
				AutoGrLog(STR0009 + ' [' + AllToChar(aErro[2] ) + ']' ) //"Id do campo de origem: "
				AutoGrLog(STR0010 + ' [' + AllToChar(aErro[3] ) + ']' ) //"Id do formulário de erro: " 
				AutoGrLog(STR0011 + ' [' + AllToChar(aErro[4] ) + ']' ) //"Id do campo de erro: "
				AutoGrLog(STR0012 + ' [' + AllToChar(aErro[5] ) + ']' ) //"Id do erro: " 
				AutoGrLog(STR0013 + ' [' + AllToChar(aErro[6] ) + ']' ) //"Mensagem do erro: "
				AutoGrLog(STR0014 + ' [' + AllToChar(aErro[7] ) + ']' ) //"Mensagem da solução: "
				AutoGrLog(STR0015 + ' [' + AllToChar(aErro[8] ) + ']' ) //"Valor atribuído: " 
				AutoGrLog(STR0016 + ' [' + AllToChar(aErro[9] ) + ']' ) //"Valor anterior: "
			EndIf	
			
			// Monta o Erro de Retorno	
			aErroAuto := GetAutoGRLog()	 
			
			For nCount := 1 To Len(aErroAuto)
				TMSLogMsg("ERROR",aErroAuto[nCount])
				cRetErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + (" ")
			Next
			cRetErro := EncodeUTF8(cRetErro)	
				
		EndIf
			
		oModel:DeActivate()
	EndIf
Else
	AutoGrLog(STR0017) //"Conteudo do registro DDO não foi preenchido"
	cRetErro := STR0017 //"Conteudo do registro DDO não foi preenchido"
	lRet := .F.
EndIf

// Exibe o Erro 	
If lVisual .AND. !lRet
	MostraErro()
EndIf

AEval( aAreas, { |x| RestArea(x) } )

Return({lRet,cRetErro})


