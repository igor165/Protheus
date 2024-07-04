#Include "Protheus.ch"
#INCLUDE "MNTA945.ch"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA945
Cadastro de Rotas do MNT

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return Sempre Verdadeiro
/*/
//------------------------------------------------------------------------------
Function MNTA945()

	Local oBrowse
	Local aArea	  	:= GetArea()
	Local cMVEntIn 	:= GetNewPar("MV_NGENTIN","")
	Local cFunBkp 	:= FunName()
	Local lStart 	:= .T.

	//|------------------------------------------------|
	//| Validacoes basicas para iniciar a rotina       |
	//|------------------------------------------------|
	If Empty(cMVEntIn)
		APMSGINFO(STR0002+CHR(13)+; //"Para utilizacao da rotina � necess�rio configurar o par�metro do SX6 MV_NGENTIN,"
				  STR0003,STR0004) //"que define o codigo da entrada inicial para o Controle de Portaria."###"ATEN��O"
		lStart := .F.
	EndIf

	If lStart //Verifica se abrir� o Browse

		//Inst�nciando FWMBrowse
		oBrowse := FWMBrowse():New()
		�����
		//Setando a tabela de cadastro de CDs
		oBrowse:SetAlias("TTT")
		�
		//Setando a descri��o da rotina
		oBrowse:SetDescription(STR0001) //"Cadastro de Rotas do MNT"
		�����
		//Ativa a Browse
		oBrowse:Activate()

	EndIf

	SetFunName(cFunBkp)
	RestArea(aArea)

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return aRotina, Array, Cont�m as op��es do menu.
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE�STR0022 ACTION�'AxPesqui' 	   	  OPERATION 1 ACCESS 0�//"Pesquisar"
	ADD OPTION aRotina TITLE�STR0023 ACTION�'VIEWDEF.MNTA945' OPERATION 2 ACCESS 0�//"Visualizar"
	ADD OPTION aRotina TITLE�STR0024�ACTION�'VIEWDEF.MNTA945' OPERATION 3 ACCESS 0�//"Incluir"
	ADD OPTION aRotina TITLE�STR0025�ACTION�'VIEWDEF.MNTA945' OPERATION 4 ACCESS 0�//"Alterar"
	ADD OPTION aRotina TITLE�STR0026�ACTION�'VIEWDEF.MNTA945' OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Cria��o do modelo de dados MVC

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return oModel, Objeto, Contem a montagem do modelo.
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
���
	Local oModel	:= Nil
	Local oStruTTT	:= FWFormStruct(1,�'TTT')
	Local oStruTTS	:= FWFormStruct(1,�'TTS')
	Local aRealc 	:= {} //Vari�vel utiliza para rela��o da tabela Pai e Filha
	Local bSetActiv := {|oModel| fSetActv(oModel)   } // Grava��o do formulario

	����
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New( 'MNTA945' ,/*bPre*/ , /*bPos*/ , /*bCommit*/ , /*bCancel*/ )
	oModel:AddFields('TTTMASTER',/*cOwner*/,oStruTTT)
	oModel:AddGrid('TTSDETAIL','TTTMASTER',oStruTTS,/*bLinePre*/,{ |oStruTTS| fLinePos() } /*bLinePost*/,/*bPre - Grid Inteiro*/,{ |oStruTTS| fTudoOk() }/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)��

	//Determina o inicializador padr�o do campo TTS_FILIAL
	oStruTTS:SetProperty('TTS_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD,��'xFilial("TTS")'))�//Ini Padr�o

	//Retira a obrigatoriedade de preenchimento da Grid.
	oModel:GetModel( 'TTSDETAIL' ):SetOptional( .T. )

	//Fun��o de ativa��o
	oModel:SetActivate(bSetActiv)

	//Fazendo o relacionamento entre a tabela Pai e a tabela Filho
	aAdd(aRealc, {'TTS_FILIAL','xFilial("TTS")'}) //Filial
	aAdd(aRealc, {'TTS_CODROT','TTT_CODROT'}) //Codigo Rota
�����
����//Criando o relacionamento
	oModel:SetRelation('TTSDETAIL', aRealc, TTS->(IndexKey(1)))�//IndexKey -> Indica o indice para relacionamento.
	oModel:SetPrimaryKey({"TTT_FILIAL","TTT_CODROT"}) //Determina chave prim�ria.
	����
	//Setando as descri��es
	oModel:SetDescription(STR0001) //"Cadastro de Rotas do MNT"
	oModel:GetModel('TTTMASTER'):SetDescription(STR0027) //'Rota'
	oModel:GetModel('TTSDETAIL'):SetDescription(STR0028) //'Percurso da rota'

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Cria��o da vis�o MVC�������

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return oView, Objeto, Contem a montagem da view.
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
����
	Local oView		:= Nil
	Local oModel	:= FWLoadModel('MNTA945')
	Local oStruTTT	:= FWFormStruct(2,�'TTT')
	Local oStruTTS	:= FWFormStruct(2,�'TTS')
	�����
	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	���
	//Adicionando os campos do cabe�alho e o grid dos filhos
	oView:AddField('VIEW_TTT',oStruTTT,'TTTMASTER')
	oView:AddGrid('VIEW_TTS',oStruTTS,'TTSDETAIL')
	�����
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('SUPERIOR',50)
	oView:CreateHorizontalBox('INFERIOR',50)
	�����
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_TTT','SUPERIOR')
	oView:SetOwnerView('VIEW_TTS','INFERIOR')
	�����
	//Habilitando t�tulo
	oView:EnableTitleView('VIEW_TTT','Rotas do MNT')
	oView:EnableTitleView('VIEW_TTS','Percurso da rota do MNT')
	�����
	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})
	�
	//Campos da tabela TTT - ROTAS DO MNT que ser�o removidos
	oStruTTT:RemoveField('TTT_FILIAL')
	oStruTTT:RemoveField('TTT_EMPROP')
	oStruTTT:RemoveField('TTT_FILPRO')

	//Casmpos da tabela TTS - PERCURSOS DA ROTA DO MNT que ser�o removidos
	oStruTTS:RemoveField('TTS_FILIAL')
	oStruTTS:RemoveField('TTS_EMPROP')
	oStruTTS:RemoveField('TTS_FILPRO')
	oStruTTS:RemoveField('TTS_EMPESC')
	oStruTTS:RemoveField('TTS_CODROT')
	oStruTTS:RemoveField('TTTS_EMPFIL')

	//Inclus�o de itens nas A��es Relacionadas de acordo com O NGRightClick
	NGMVCUserBtn(oView)

Return oView

//------------------------------------------------------------------------------
/*/{Protheus.doc} fTudoOk
Realiza valida��es antes da grava��o. �

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return lRet, L�gica, Retorna .T. caso verifica��es estejam corretas.
/*/
//------------------------------------------------------------------------------
Static Function fTudoOk()

	Local aOldArea	:= GetArea()
	Local aGrid 	:= {}
	Local lRet 		:= .T.
	Local oModel	:= FWModelActive() //Ativa o ultimo modelo aberto.
	Local oGrid 	:= oModel:GetModel('TTSDETAIL') //Abre a Grid.
	Local nX 		:= 0
	Local nSaid 	:= 0
	Local nEntr		:= 0
	Local nLenGrid  := oGrid:Length()   //Quantidade Total de linhas do oGrid.


	If nLenGrid > 1 //Caso grid possua mais de 1 linha.

		//|----------------------------------------------------------------|
		//| A primeira linha possui valor padr�o e n�o deve ser deletada.  |
		//|----------------------------------------------------------------|
		oGrid:GoLine(1) //Posiciona na primeira linha
		If oGrid:IsDeleted() //Caso esteja deletada.
			Help(Nil, Nil, STR0004, Nil, STR0013, 1, 0) //"ATEN��O"##"A escala padrao nao-programada '000' n�o pode ser exclu�da!"
			lRet := .F.
		EndIf

		//|-------------------------------------------------------------------|
		//| A segunda linha deve possuir o valor de Sa�da, obrigatoriamente.  |
		//|-------------------------------------------------------------------|
		If lRet
			oGrid:GoLine(2) //Posiciona na segunda linha
			If !(oGrid:IsDeleted()) .And. oGrid:GetValue("TTS_TIPESC") <> "1"
				Help(Nil, Nil, STR0004, Nil, STR0005 + CRLF + STR0006, 1, 0)//"� necess�rio que a primeira escala seja uma sa�da!"###"Informe uma escala v�lida, do tipo 'Sa�da'."
				lRet := .F.
			EndIf
		EndIf

		//|-----------------------------------------------------------------------|
		//| A ultima linha deve possuir o valor de Entrada, obrigatoriamente.     |
		//|-----------------------------------------------------------------------|
		If lRet
			oGrid:GoLine(nLenGrid) //Posiciona na segunda linha
			If !(oGrid:IsDeleted()) .And. oGrid:GetValue("TTS_TIPESC") <> "3"
				Help(Nil, Nil, STR0004, Nil, STR0009 + CRLF + STR0010, 1, 0)//"� necess�rio que a �ltima escala seja uma entrada!"###"Informe uma escala v�lida, do tipo 'Entrada'."
				lRet := .F.
			EndIf
		EndIf

		If lRet
			For nX := 1 To nLenGrid
				oGrid:GoLine(nX)
				If !(oGrid:IsDeleted())
					aAdd( aGrid,{ oGrid:GetValue("TTS_CODIGO") , oGrid:GetValue("TTS_TIPESC") } )
				EndIf
			Next nX

			If Len(aGrid) > 0
				//Percorre a grid para identificar se possui mais de uma Sa�da ou Entrada.
				aEVAL(aGrid,{|x| If(x[2] == "1",nSaid++,Nil)})
				aEVAL(aGrid,{|x| If(x[2] == "3",nEntr++,Nil)})
				If nSaid > 1
					Help(Nil, Nil, STR0004, Nil, STR0007 + CRLF + STR0008, 1, 0)//"S� � permitido informar 1 sa�da!"###"Altere a escala para tipo 'Intermediario'."
					lRet := .F.
				ElseIf nEntr > 1
					Help(Nil, Nil, STR0004, Nil, STR0011 + CRLF + STR0012, 1, 0)//"S� � permitido informar 1 entrada!"###"Altere a escala para tipo 'Intermedi�rio'."
					lRet := .F.
				ElseIf nSaid == 0
					Help(Nil, Nil, STR0004, Nil, STR0005 + CRLF + STR0006, 1, 0)//"� necess�rio que a primeira escala seja uma sa�da!"###"Informe uma escala v�lida, do tipo 'Sa�da'."
					lRet := .F.
				ElseIf nEntr == 0
					Help(Nil, Nil, STR0004, Nil, STR0009 + CRLF + STR0010, 1, 0)//"� necess�rio que a �ltima escala seja uma entrada!"###"Informe uma escala v�lida, do tipo 'Entrada'."
					lRet := .F.
				Endif
			EndIf
			aGrid := {} //Limpa o array.
		EndIf
	Else
		Help(Nil, Nil, STR0004, Nil, STR0030, 1, 0)//"� necess�rio possuir uma Entrada e uma Sa�da."
		lRet := .F.
	EndIf

	RestArea(aOldArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} M945SEQ
Retorna o numero sequencia da chave para tabela TTS ������

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return cSeq, Caracter, Numero da pr�xima sequ�ncia.
/*/
//------------------------------------------------------------------------------
Function M945SEQ()

	Local cSeq 	  := Replicate("0",TamSX3('TTS_CODIGO')[1])
	Local oModel  := FWModelActive() //Ativa o ultimo modelo aberto.
	Local oGrid   := oModel:GetModel('TTSDETAIL') //Abre a Grid.
	Local nLinAtu := oGrid:GetLine() //Linha posicionada
�����
	If nLinAtu >= 1
		cSeq := oGrid:GetValue( "TTS_CODIGO" )
		cSeq := Soma1(cSeq)
����EndIf

Return cSeq

//------------------------------------------------------------------------------
/*/{Protheus.doc} M945When
X3_WHEN dos campos da tabela TTS ������

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return lRet, L�gico, Retorna verdadeiro mediante as condi��es de verifica��o.
/*/
//------------------------------------------------------------------------------
Function M945When(cCampo)

	Local lRet 	:= .F.
	Local cSeq 	:= Replicate("0",TamSX3('TTS_CODIGO')[1])
	Local oModel:= FWModelActive() //Ativa o ultimo modelo aberto.
	Local oGrid := oModel:GetModel('TTSDETAIL') //Abre a Grid.

	If oGrid:GetValue( "TTS_CODIGO" ) <> cSeq
		lRet := .T.
	Endif

	//|----------------------------------------------------------------------------------------------|
	//|Realiza tratativa para preenchimento do campo TTS_CODROT e TTS_EMPESC, pois o mesmo n�o       |
	//| faz parte de grid, mas deve ser preenchido sempre, conforme o campo TTT_CODROT.              |
	//|----------------------------------------------------------------------------------------------|
	If Empty(oGrid:GetValue( "TTS_CODROT" ))
		oGrid:LoadValue("TTS_CODROT", oModel:GetValue("TTTMASTER","TTT_CODROT"))
	Endif
	If Empty(oGrid:GetValue( "TTS_EMPESC" ))
		oGrid:LoadValue("TTS_EMPESC", SM0->M0_CODIGO)
	Endif
	If Empty(oGrid:GetValue( "TTS_EMPROP" ))
		oGrid:LoadValue("TTS_EMPROP", SM0->M0_CODIGO)
	Endif
	If Empty(oGrid:GetValue( "TTS_FILPRO" ))
		oGrid:LoadValue("TTS_FILPRO", xFilial("TTT"))
	Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} M945Relac
X3_RELACAO dos campos da tabela TTS   ������

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return cRet, Caracter, Retorna o valor do rela��o do campo.
/*/
//------------------------------------------------------------------------------
Function M945Relac(cCampo)

	Local cRet		:= ""
	Local oModel	:= FWModelActive() //Ativa o ultimo modelo aberto.
	Local oGrid 	:= oModel:GetModel('TTSDETAIL') //Abre a Grid.
	Local nLenGrid  := oGrid:Length()

	If nLenGrid == 0
		If cCampo == "TTS_TIPESC"
			cRet := "4"
		ElseIf cCampo == "TTS_FILESC"
			cRet := Replicate("0",Len(TTS->TTS_FILESC))
		ElseIf cCampo == "TTS_DESCRI"
			cRet := STR0014 //"NAO-PROGRAMADO"
		ElseIf cCampo == "TTS_HORARI"
			cRet := "00:00"
		EndIf
	EndIf

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} M945Valid
X3_VALID de alguns campos da tabela TTT/TTS  ������

@param cCampo, Caracter, Campo posicionado que ser� validado.

@author Guilherme Freudenburg
@since 13/02/2018
@version P12

@return lRet, L�gico, Retorna verdadeiro mediante as valida��es.
/*/
//------------------------------------------------------------------------------
Function M945Valid(cCampo)

	Local lRet 		:= .T.
	Local cMVEntIn 	:= GetNewPar("MV_NGENTIN","")
	Local oModel	:= FWModelActive() //Ativa o ultimo modelo aberto.
	Local oGrid 	:= oModel:GetModel('TTSDETAIL') //Abre a Grid.
	Local aAreaTTT	:= GetArea()
	Local nOperation:= oModel:GetOperation() //Qual a opera��o selecionada.

	If cCampo == "TTS_FILESC"
		If !Empty(oGrid:GetValue("TTS_FILESC"))
			If (lRet := EXISTCPO("SM0",cEmpAnt+oGrid:GetValue("TTS_FILESC")))
				oGrid:LoadValue( "TTS_DESCRI"  , Padr( NGSEEKSM0(cEmpAnt+oGrid:GetValue("TTS_FILESC"),{"M0_NOME"})[1] ,Len( oGrid:GetValue("TTS_DESCRI") ))  )
			EndIf
		EndIf
	ElseIf cCampo == "TTT_CODROT"
		If oModel:GetValue("TTTMASTER" , "TTT_CODROT") == cMVEntIn
			Help(Nil, Nil, STR0004, Nil, STR0017 + CRLF + STR0018, 1, 0)//"O codigo informado nao pode ser o mesmo definido para a entrada padr�o do Controle de Portaria."###"Informe um c�digo v�lido."
			lRet := .F.
		EndIf
		If nOperation = MODEL_OPERATION_INSERT //Caso seja inclus�o.
			dbSelectArea("TTT")
			dbSetOrder(2)
			If dbSeek(xFilial("TTT")+oModel:GetValue("TTTMASTER","TTT_CODROT"))
				Help(Nil, Nil, STR0004, Nil, STR0029, 1, 0)//"C�digo de rota j� utilizado."
				lRet := .F.
			EndIf
		EndIf
	EndIf

	RestArea(aAreaTTT)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA945FIL
Filtro especifico para a consulta EMPMUL   ������

@author Felipe N. Welter
@since 26/05/09
@version P12

@return Sempre Verdadeiro.
/*/
//------------------------------------------------------------------------------
Function MNTA945FIL()

	Return SM0->M0_CODIGO == cEmpAnt

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} MNTA945RET
Retorno especifico para a consulta EMPMUL  ����

@author Felipe N. Welter
@since 26/05/09
@version P12

@return Vazio
/*/
//------------------------------------------------------------------------------
Function MNTA945RET()

	Return SM0->M0_CODFIL

Return ""

//-----------------------------------------------------------------------//
/*/{Protheus.doc} fSetActv()
Fun��o para altera��es de registros em tela antes da apresenta��o da mesmo.
� chamada na ativa��o do Model.

@obs Os valores ser�o apenas enviados para a primeira linha, quando for
	   a inclus�o de um novo registro.

@author Guilherme Freudenburg
@since 14/02/2018
@version P12

@return True
/*/
//-----------------------------------------------------------------------//
Static Function fSetActv(oModel)

	Local oGrid 	:= oModel:GetModel('TTSDETAIL') //Busca a grid utilizada.
	Local nLenGrid	:= oGrid:Length() //Busca a quantidade de linhas na grid
	Local nOperation:= oModel:GetOperation() //Qual a opera��o selecionada.
	Local cCodRot 	:= Replicate("0",TamSX3('TTS_CODROT')[1]) //C�digo para preenchimento padr�o do campo TTS_CODROT



	If nLenGrid == 1 .And.; //Caso contenha apenas 1 linha.
		nOperation == MODEL_OPERATION_INSERT //Seja operacao de inclus�o.

		oModel:LoadValue("TTTMASTER","TTT_EMPROP", SM0->M0_CODIGO)
		oModel:LoadValue("TTTMASTER","TTT_FILPRO", xFilial("TTT"))

		oGrid:LoadValue("TTS_CODROT", cCodRot)
		oGrid:LoadValue("TTS_CODIGO", "000")
		oGrid:LoadValue("TTS_TIPESC", "4")
		oGrid:LoadValue("TTS_FILESC", Replicate("0",Len(TTS->TTS_FILESC)))
		oGrid:LoadValue("TTS_DESCRI", STR0014)//"NAO-PROGRAMADO"
		oGrid:LoadValue("TTS_HORARI", "00:00")
		oGrid:LoadValue("TTS_EMPESC", SM0->M0_CODIGO)
		oGrid:LoadValue("TTS_EMPROP", SM0->M0_CODIGO)
		oGrid:LoadValue("TTS_FILPRO", xFilial("TTT"))
	EndIf

Return .T.

//-----------------------------------------------------------------------//
/*/{Protheus.doc} fLinePos()
Fun��o para valida��o da grid, antes do preenchimento de qualquer linha.

@obs Somente ser� permitido incluir uma linha na grid, mediante ao
		preenchimento do campo TTT_CODROT.

@author Guilherme Freudenburg
@since 14/02/2018
@version P12

@return lRet, L�gico, Determinar se poderia ser preenchido a grid.
/*/
//-----------------------------------------------------------------------//
Static Function fLinePos()

	Local oModel	:= FWModelActive() //Ativa o ultimo modelo aberto.
	Local nOperation:= oModel:GetOperation() //Qual a opera��o selecionada.
	Local lRet := .T.

	If nOperation == MODEL_OPERATION_INSERT .And.;//Se for inclus�o.
		Empty(oModel:GetValue("TTTMASTER","TTT_CODROT"))
		Help(Nil, Nil, STR0004, Nil, STR0031, 1, 0)//"Antes de informar o percurso, favor preencher o c�digo da rota."
		lRet := .F.
	EndIf

Return lRet
