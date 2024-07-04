#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'PLSA808.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA808
Funcao para abrir cadastro de Documento do motivo de alteração/solicitação contratual
@author Oscar Zanin
@since 21/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA808()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:setMainProc("PLSA808")
oBrowse:SetAlias('B9X')
oBrowse:SetDescription(STR0001) 	//Documentação
oBrowse:SetMenuDef('PLSA808')		//Define que este é o Browse que será utilizado na chamada da função
oBrowse:SetFilterDefault("B9X_CODMOT==B9G->B9G_COD") //Define o Filtro padrão
oBrowse:Activate()

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao para criar o menu da tela
@author Oscar Zanin
@since 21/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

Add Option aRotina Title STR0004 /*'Visualizar' */Action 'VIEWDEF.PLSA808' Operation 2 Access 0
Add Option aRotina Title STR0005 /*'Incluir'    */Action 'VIEWDEF.PLSA808' Operation 3 Access 0
Add Option aRotina Title STR0006 /*'Alterar'    */Action 'VIEWDEF.PLSA808' Operation 4 Access 0
Add Option aRotina Title STR0007 /*'Excluir'    */Action 'VIEWDEF.PLSA808' Operation 5 Access 0
Add Option aRotina Title STR0008 /*'Imprimir'   */Action 'VIEWDEF.PLSA808' Operation 8 Access 0
Add Option aRotina Title STR0009 /*'Copiar'     */Action 'VIEWDEF.PLSA808' Operation 9 Access 0

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados
@author Oscar Zanin
@since 21/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrB9X:= FWFormStruct(1,'B9X')

oModel := MPFormModel():New( 'PLSA808', , {|| PLSA808OK(oModel) } )
oModel:addFields('MasterB9X',/*cOwner*/,oStrB9X)
oModel:getModel('MasterB9X')
oModel:SetDescription(STR0002) //Documentos para o Motivo

oModel:SetPrimaryKey( {"B9X_FILIAL", "B9X_CODINT", "B9X_CODMOT", "B9X_SEQMOT"} )

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface
@author Oscar Zanin
@since 21/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView	
Local oModel 	:= ModelDef()
Local oStrB9X	:= FWFormStruct(2, 'B9X', { |cCampo| PLSA808CMP(cCampo) } )

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField('FrmB9X' , oStrB9X,'MasterB9X' ) 
oView:CreateHorizontalBox( 'BxB9X', 100)
oView:SetOwnerView('FrmB9X','BxB9X')

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA808OK
Validar botão confirmar
@author Oscar Zanin
@since 21/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA808OK(oModel)
LOCAL lRet     		:= .T.
LOCAL cMsg     		:= ""
LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9X' )
LOCAL cDescri  		:= ""
LOCAL nOpc				:= oModel:GetOperation()
LOCAL cCodMot  		:= oModelDetail:GetValue('B9X_CODMOT')
LOCAL cCodInt			:= PLSINTPAD()

If (nOpc <> 5) //Não para "Excluir"

	cDescri := oModelDetail:GetValue('B9X_DOCMOT')
	
	B9X->(DbSelectArea("B9X"))
	B9X->(DbSetOrder(4)) // B9X_FILIAL + B9X_CODMOT + B9X_DOCMOT
	
	//Busca se o a Descrição já foi cadastrada para o Código
	If 	B9X->(MsSeek(XFilial("B9X") + cCodInt + cCodMot + cDescri))
   		cMsg := STR0003 //"Documento já cadastrado para o Motivo!"
   		Help( ,, 'HELP',, cMsg, 1, 0)
   		lRet := .F.
	EndIf

	B9X->(DbCloseArea())
	
EndIf

Return (lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSSEQD808
Prenche o Campo B9X_SEQDOC, de modo a manter a sequência para os documentos relacionados ao mesmo Motivo
@author Oscar Zanin
@since 22/01/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSSEQD808(oModel, cCodMot)

LOCAL oModelDetail	:= oModel:GetModel( 'MasterB9X' )
LOCAL cSeqMot			:= ""
LOCAL cCodInt			:= PLSINTPAD()

B9X->(DbSelectArea("B9X"))
B9X->(DbSetOrder(3)) //B9X_FILIAL + B9X_CODINT + B9X_CODMOT
B9X->(MsSeek(xFilial("B9X") + cCodInt + cCodMot)) //Posiciona no primeiro registro do Código, caso houver

//Busca os valores do sequencial do motivo, ate o último cadastrado ou o fim do arquivo
//Atribuindo o valor para a variável
While((!B9X->(EOF())) .AND. B9X->(B9X_CODMOT) == cCodMot .AND. B9X->(B9X_CODINT) == cCodInt)
	cSeqMot	:=	B9X->(B9X_SEQMOT)
	B9X->(DbSkip())
End

//Incrementa o Sequencial, depois converte de volta pra caracter com 3 posições
cSeqMot := StrZero(Val(cSeqMot) + 1, 3)

//Atribui o valor ao Model
oModelDetail:SetValue('B9X_SEQMOT', cSeqMot)

B9X->(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS808SEQP
Prenche o Campo B9X_SEQDOC ao abrir a tela de inclusão, para mmelhorar a experiência do usuário
Esta função é utilizada como Inicializador padrão do campo B9X_SEQMOT
@author Oscar Zanin
@since 12/02/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLS808SEQP()

Local cCodInt			:= PLSINTPAD()
Local cCodMot			:= B9X->B9X_CODMOT
Local cSeqMot			:= ""

B9X->(DbSelectArea("B9X"))
B9X->(DbsetOrder(1))

//Verifica se já existe Documento cadastrado para o Motivo
If B9X->(MsSeek(B9X->B9X_FILIAL + B9X->B9X_CODINT + B9X->B9X_CODMOT))
	
	//Procura o Sequencial do último documento cadastrado para o motivo
	While((!B9X->(EOF())) .AND. B9X->(B9X_CODMOT) == cCodMot .AND. B9X->(B9X_CODINT) == cCodInt)
		cSeqMot	:=	B9X->(B9X_SEQMOT)
		B9X->(DbSkip())
	End

EndIf

B9X->(DbCloseArea())

//Incrementa o Sequencial, pois o documento sendo cadastrado é o próximo da lista (último Seq cadastrado + 1)
cSeqMot := StrZero(Val(cSeqMot)+1,3)

Return (cSeqMot)


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA808CMP
Tratamento para campos que devem ir na View
@author Oscar Zanin
@since 19/03/2015
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA808CMP(cCampo)

Local lRet	:= .F.

If cCampo == "B9X_SEQMOT"
	lRet := .T.
EndIf

If cCampo == "B9X_DOCMOT"
	lRet := .T.
EndIf

If cCampo == "B9X_OBRIG "
	lRet := .T.
EndIf

If cCampo == "B9X_CODDOC"
	lRet := .T.
EndIf

Return lRet