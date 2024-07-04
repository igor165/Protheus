#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "OGX017.CH"

#DEFINE CRLF CHR(13)+CHR(10) // Salta linha

Static __oViewAct	:= Nil // View Ativa
Static __lExecAuto
Static __cProcess
Static __lWorkFl

/*{Protheus.doc} OGX017
//Rotina para Envio de e-mail.
@author roney.maia
@since 25/08/2017
@version 6
@param cEmails, characters, E-mails dos destinatários
@param cBody, characters, Corpo do e-mail
@param cAliasBrw, characters, Alias do browse que chamou a tela envio de email
@param cChave, characters, Chave utilizada como filtro do registro pai
@param cProcess, characters, Processo utilizado para filtro de template
@param aIndices, array, Array de indices para a tabela temporaria
@param nSetOrd, characters, Numero da ordem dos indices a ser utilizada
@param aAnexos, array, Array de anexos para o e-mail
### Estrutura do array de anexos###

aAnexos := { { "1", "arquivo.txt", "C:\arquivo.txt" } , { "1", "arquivos2.txt", "C:\arquivo2.txt" } }
-Contém 2 anexos 
aAnexos[nIt][1] = ("1" ou "" , sendo "1" Com o checkbox marcado na grid de anexos e "" desmarcado)
aAnexos[nIt][2] = nome do arquivo que aparecerá na grid de anexos
aAnexos[nIt][3] = caminho do arquivos que será usado para envio no e-mail

aWfRet ::: Exemplo: {"OGA700", "N79", cChave, "OGA700WFR(oProcess,aRet)"}
					 Rotina  , Alias, Chave ,  Função de Retorno
@Return
 aRet {Assunto                  char,
       Emails                   char, 
       IdTemplate               char, 
       Resultado execução       logical,  
       Msg de erro/informação   char
       }
##########################
@type function
*/
Function OGX017(cEmails, cBody, cAliasBrw, cChave, cProcess, aIndices, nSetOrd, aAnexos, cRemetent, cTemplate, lExecAuto, lWorkflow, aWfRet)

	Local aArea			:= GetArea()
	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0001},{.T., STR0002},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # Enviar # Fechar
	Local nRet			:= 0 // Variavel de retorno para a função FwExecView
	Local nIt			:= 0
	Local cUsuario		:= RetCodUsr() // Obtém o codigo do usuário logado
	Local cUsrMail		:= UsrRetMail(cUsuario) // Obtém o e-mail do usuário logado
    Local lRet          := .T.
	
	Default cEmails		:= ""
	Default cBody		:= ""
	Default cAliasBrw	:= ""
	Default cChave		:= ""
	Default cProcess	:= ""
	Default aIndices	:= {}
	Default nSetOrd		:= 0
	Default aAnexos		:= {}
	Default cRemetent	:= ""
	Default cTemplate	:= ""
	Default lExecAuto   := .F.
	Default lWorkFlow	:= .F.
	Default aWfRet		:= {}
	
	Private _oEditMail	:= Nil // Objeto Editor Html
	Private _cEmails	:= cEmails // E-mails dos destinatários
	Private _cBody		:= cBody // Corpo do e-mail
	Private _cAliasBrw	:= cAliasBrw // Alias do browse que chamou a tela envio de email
	Private _cChave		:= cChave // Chave utilizada para buscar o registro da tabela pai
	Private _aIndices	:= aIndices // Indices da tabela temporaria
	Private _oTempTab	:= Nil // Objeto da tabela temporaria
	Private _nSetOrd	:= nSetOrd // Ordem da tabela temporaria
	Private _aRet		:= {}	// Retorno de informações, retorna o Assunto e os Destinatários, para salvar no historico.
	Private _lAnexo		:= .F. // Controle de view por ação do botão de anexo
	Private _aAnexos	:= aAnexos // Arquivos anexados ao e-mail
	Private _cIniAnex	:= "" // Inicializador de campo para anexos de e-mail
	Private _cRemetent	:= cRemetent // Nome do remetente que irá disparar o e-mail
	Private _cTemplate	:= cTemplate //Template para o e-mail
	Private _cFldStru	:= ""
	Private _cWfProc	:= ""
	Private _cFormWork  := ""
	Private _aWfRet		:= aWfRet
	Private _cDescri	:= ""
	Private _cAssunt	:= ""
    
    Private _cMsg	:= ""
	
	__lExecAuto := lExecAuto
	__cProcess	:= cProcess // Processos de e-mail
	__lWorkFl   := lWorkflow //Indica se foi chamada para utilização via workflow
	
	If .Not. TableInDic('N7L')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		RestArea(aArea)
        aAdd(_aRet, {"", "", "", .F., "Tabela N7L não encontrada na base de dados."})
		Return _aRet
	Endif
	
	If Empty(_cRemetent) // Se o remetente não foi passado via parametro, atribui o email do usuario logado.
		If Empty(cUsrMail) // Se o usuário logado não possui e-mail cadastrado, atribui o e-mail padrão de envio previamente configurado no SIGACFG
			_cRemetent := AllTrim(SuperGetMV("MV_RELFROM",.F.,""))
		Else
			_cRemetent := AllTrim(cUsrMail)
		EndIf	
	EndIf
	
	If .NOT. Empty(_aAnexos)
		For nIt := 1 To Len(_aAnexos)	
			_cIniAnex += AllTrim(_aAnexos[nIt][2]) + "; " // Concatena os anexos para aplicar ao campo Anexos
		Next nIt
		
		_cIniAnex := SubStr(_cIniAnex, 0, Len(_cIniAnex) - 2)
	EndIf

	OGX017ASST(.f.)
	
	If !__lExecAuto   //IsInCallStack('UBAA070') 
		nRet = FWExecView(STR0003, 'OGX017', MODEL_OPERATION_INSERT, , {|| .T.}, {|oView| lRet := OGX017OK(oView, "bOk")}, 20 / 100, aButtons) // # "Envio de e-mail"
	Else
		lRet := OGX017OK(, "bOk") //chamada em background, forca ok
	EndIf
	
	If ValType(_oTempTab) != "U" // Deleta o objeto da tabela temporária e fecha o alias ligado ao mesmo
		_oTempTab:Delete()
	EndIf
	
	If nRet != 0 .or. !lRet // Se diferente de 0, então clicou em fechar, ou deu erro 
		_aRet := {}
		aAdd(_aRet, {"", "", "", .F., _cMsg})
	EndIf
	
	RestArea(aArea)
Return _aRet

/*{Protheus.doc} ModelDef
//ModelDef definido para rotina utilizar.
@author roney.maia
@since 25/08/2017
@version 6
@type function
*/
Static Function ModelDef()

	Local oModel    := MPFormModel():New("OGX017", , , {|| .T.}) // Instancia um objeto model
	Local oStruFld  := FWFormModelStruct():New() // Instancia uma Struct do Tipo Model
	Default _lAnexo := .F.

	oStruFld:AddField(STR0004, STR0005, 'FLDPROC', 'C' , 3 , 0, , , , .T., , , .F., .T.) // Campo Proc.E-mail # Proc.E-mail # Processo de e-mail
	oStruFld:AddField(STR0006, STR0012, 'FLDTMPLT', 'C' , 6 , 0, , , , .T., , , .F., .T.) // Campo Template # Template # Template de e-mail
	oStruFld:AddField(STR0007, STR0008, 'FLDDESCT', 'C' , 254 , 0, , , , .F., , , .F., .T.) // Campo Descrição # Template # Des.Template # Descrição do Template
	oStruFld:AddField(STR0037, STR0038, 'FLDREMETENTE', 'C' , 100 , 0, , , , .F., , , .F., .T.) // Campo Remetente # Remetente # Remente do e-mail
	oStruFld:AddField(STR0010, STR0015, 'FLDMAILS', 'M' , 1 , 0, , , , .T., , , .F., .T.) // Campo Para # E-mails # E-mails de envio
	oStruFld:AddField(STR0009, STR0014, 'FLDASSUNT', 'C' , 100 , 0, , , , .F., , , .F., .T.) // Campo Assunto # Assunto # Assunto do e-mail
	oStruFld:AddField(STR0039, STR0040, 'FLDANEXOS', 'C' , 254 , 0, , , , .F., , , .F., .T.) // Campo Anexos # Anexos # Anexos do e-mail
	oStruFld:AddField(""	 , ""	  , 'FLDMODIFY', 'C' , 254 , 0, , , , .F., , , .F., .T.) // Campo Anexos # Anexos # Anexos do e-mail
	
	
	If _lAnexo // Se anexo remove a obrigatoriedade de campos para a utilização do model
		oStruFld:SetProperty("*", MODEL_FIELD_OBRIGAT, .F.)
	Else
		//oStruFld:SetProperty( "FLDPROC", MODEL_FIELD_VALID, FWBuildFeature	( STRUCT_FEATURE_VALID, "OGX017VLD(a, b, c, d)" ) ) // Adiciona função para validação do campo
		oStruFld:SetProperty( "FLDTMPLT", MODEL_FIELD_VALID, FWBuildFeature( STRUCT_FEATURE_VALID, "OGX017VLD(a, b, c, d)" ) ) // Adiciona função para validação do campo	
		oStruFld:SetProperty( "FLDREMETENTE", MODEL_FIELD_INIT, { || _cRemetent})
		oStruFld:SetProperty( "FLDMAILS", MODEL_FIELD_INIT, { || _cEmails})		
		oStruFld:SetProperty( "FLDANEXOS", MODEL_FIELD_INIT, { || _cIniAnex})
		

		If __lWorkFl
			oStruFld:SetProperty( "FLDPROC",  MODEL_FIELD_INIT, { || __cProcess})
			oStruFld:SetProperty( "FLDTMPLT", MODEL_FIELD_INIT, { || _cTemplate})	
			oStruFld:SetProperty( "FLDDESCT", MODEL_FIELD_INIT, { ||  _cDescri })
			oStruFld:SetProperty( "FLDASSUNT", MODEL_FIELD_INIT, { || _cAssunt })
		EndIf
	EndIf
	
	
	oModel:AddFields("MODEL_FLD",/*cOwner*/,oStruFld,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
	
	//oModel:AddRules("MODEL_FLD", "FLDTMPLT", "MODEL_FLD", "FLDPROC", 3) // Regra de dependência entre o campo Proc.E-mail e o campo Template
	
	oModel:GetModel("MODEL_FLD"):SetDescription(STR0003)// "Envio de Email"

	oModel:SetPrimaryKey({"FLDTMP"})
	
	oModel:SetDescription(STR0003) //"Envio de e-mail"
	
return oModel


/*{Protheus.doc} ViewDef
//ViewDef que será chamada via FwExecView.
@author roney.maia
@since 25/08/2017
@version 6
@type function
*/
Static Function ViewDef()
	
	Local oView    	:= FWFormView():New()
	Local oModel	:= ModelDef() // Carrega o Model da rotina AGRA720
	Local oStruFld	:= FwFormViewStruct():New() // Instancia uma Struct do Tipo View
	Local oStruAnx	:= FwFormViewStruct():New() // Instancia uma Struct do Tipo View para o campo Anexo
	
	Default _lAnexo := .F.
	
	/* Estutura para a criação de campos na view    
        
            [01] C Nome do Campo
            [02] C Ordem
            [03] C Titulo do campo  
            [04] C Descrição do campo  
            [05] A Array com Help
            [06] C Tipo do campo
            [07] C Picture
            [08] B Bloco de Picture Var
            [09] C Consulta F3
            [10] L Indica se o campo é editável
            [11] C Pasta do campo
            [12] C Agrupamento do campo
            [13] A Lista de valores permitido do campo (Combo)
            [14] N Tamanho Maximo da maior opção do combo
            [15] C Inicializador de Browse
            [16] L Indica se o campo é virtual
            [17] C Picture Variável
    
    */
    
    oView:SetModel(oModel) // Seta o modelo
    __oViewAct := oView // Atribui a view utilizada
    
    If _lAnexo  // Se for a tela de Anexo  	
    	oView:AddOtherObject("VIEW_ANEXO", {|oPanel, oObj| OGX017VAN(oPanel, oObj)}) // Adiciona o campo e grid de anexos
    	_lAnexo := .F.
    Else  
	    oStruFld:AddField("FLDPROC", '01', STR0004, STR0005, {STR0011}, 'C', '@!', , 'N7W', .T.) // Campo Proc.E-mail # Proc.E-mail # Processo de e-mail # Processo utilizado em templates de e-mail.
		oStruFld:AddField("FLDTMPLT", '02', STR0006, STR0012, {STR0013}, 'C', '@!', , 'N7LN7W', .T.) // Campo Template # Template # Template de e-mail # Template que será utilizado no envio de e-mail.
		oStruFld:AddField("FLDDESCT", '03', STR0007, STR0008, {STR0008 + "."}, 'C', '@!', , , .F.) // Campo Des.Template # Template # Des.Template # Descrição do Template # Descrição do Template.
		oStruFld:AddField("FLDASSUNT", '04', STR0009, STR0014, {STR0014 + "."}, 'C', '@!', , , .T.) // Campo Assunto # Assunto # Assunto do e-mail # Assunto do e-mail.
		oStruFld:AddField("FLDMAILS", '05', STR0010, STR0015, {STR0016 + CRLF + "email1@email.com;" + CRLF + "email2@email.com;" }, 'M', '', , , .T.) // Campo E-mails # E-mails # E-mails de envio # E-mails de destinatários para o envio. Devem ser separados por (ponto e vírgula) conforme exemplo:
		oStruFld:AddField("FLDREMETENTE", '06', STR0037, STR0038, {STR0038 + "."}, 'C', '', , , .F.) // Campo Remetente # Remetente # Remente do e-mail
		
		oStruAnx:AddField("FLDANEXOS", '07', STR0039, STR0040, {STR0041 + "." }, 'C', '', , , .F.) // Campo Anexos # Anexos # Anexos do e-mail # Anexos que poderão ser enviados no e-mail.
		
		oView:AddField("VIEW_FIELDMAIL", oStruFld, "MODEL_FLD" )///,,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
		
		oView:AddField("VIEW_ANEXOBOT", oStruAnx, "MODEL_FLD") // View Anexo
		
		oView:AddOtherObject("VIEW_EMAIL", {|oPanel, oObj| OGX017EDT(oPanel, oObj)}) // Adiciona o editor de email a view
				
		oView:CreateHorizontalBox( 'BOXFIELDMAIL', 25 ) // Campos de Email
		oView:CreateHorizontalBox( 'BOXANEXO', 10 ) // Campo Anexo
		oView:CreateHorizontalBox( 'BOXEDITOR', 65 ) // Editor de e-mail
				
		oView:SetOwnerView("VIEW_FIELDMAIL", "BOXFIELDMAIL")
		oView:SetOwnerView("VIEW_EMAIL", "BOXEDITOR")
		oView:SetOwnerView("VIEW_ANEXOBOT", "BOXANEXO")
		
		oView:addUserButton(STR0042, 'MAGIC_BMP',{|oView| OGX017ANX(oView)}, STR0043 + ".", , {MODEL_OPERATION_INSERT}) // # Anexar arquivos # Menu para anexar arquivos ao e-mail	
		oView:addUserButton(STR0064, 'MAGIC_BMP2',{|oView| OGX017CTC()}, STR0066 + ".", , {MODEL_OPERATION_INSERT}) // # Anexar arquivos # Menu para anexar arquivos ao e-mail	

		oView:SetAfterViewActivate({|oView| OGX017VAC(oView)}) // Pós ativação da view
    EndIf
	
	oView:ShowInsertMsg(.F.) // Desabilita a mensagem de registro salvo com sucesso na inserção.
	oView:ShowUpdateMsg(.F.) // Desabilita a mensagem de registro salvo com sucesso no update.
		
	oView:SetCloseOnOk( {||.T.} )
	
Return oView

/*{Protheus.doc} OGX017EDT
//Função que ira adicionar o Objeto Editor Html para
a View.
@author roney.maia
@since 25/08/2017
@version 6
@param oPanel, object, Panel que será inserido o objeto
@param oObj, object, objeto generico que contém a view.
@type function
*/
Static Function OGX017EDT(oPanel, oObj)

	Local   oFwLayer    := Nil
	Local   oPnlEdt		:= Nil

	oFwLayer := FwLayer():New() // Cria uma Layer para divisão da dialog
	oFwLayer:Init(oPanel, .F., .T.) // Inicia a criação do Layer
	
	oFwLayer:AddCollumn('COL01', 100, .F.)
	oFwLayer:AddWindow('COL01', 'WIN01', STR0017, 100, .F., .F.) // # Editor de e-mail
		
	oPnlEdt := oFWLayer:GetWinPanel("COL01","WIN01",)
	
	_oEditMail := FWSimpEdit():New( 0, 0, 500,600, STR0018,,,.F.,.F. , oPnlEdt)// # Editor HTML
	
	_oEditMail:SetText(_cBody) // Seta o texto no objeto editor html
	
Return

/*{Protheus.doc} OGX017VLD
//Função de validação de campos do e-mail, é utilizado para montar o template.
@author roney.maia
@since 29/08/2017
@version 6
@param oModelFld, object, SubModel dos campos do header
@param cCampo, characters, Campo que disparou a validação
@param xNewValue, , Novo valor atribuido
@param xOldValue, , Valor anteriormente contido no campo
@type function
*/
Function OGX017VLD(oModelFld, cCampo, xNewValue, xOldValue)
	Local oModel := FwModelActive()
	Local lRet 	 := .F.
	
	Do Case	
		Case "FLDTMPLT" $ cCampo // Caso for o campo de template, monta o corpo do html conforme o template selecionado
			
			If lRet := ExistCpo("N7L", AllTrim(xNewValue) + AllTrim(__cProcess))			
				FwMsgRun(, {|tSay| lRet := OGX017PROC(oModelFld)}, STR0034) // # Processando o Template...
				_cTemplate := oModelFld:GetValue("FLDTMPLT")
			EndIf

			If !lRet
				oModel:SetErrorMessage( , , oModel:GetId() , "", "", STR0062, STR0063, "", "") //"Não foi informado relacionamento entre tabelas!" ### "Verificar o cadastro de 'Processo de e-mail'." 
			EndIf	
	EndCase
	
Return lRet

/*{Protheus.doc} OGX017PROC
//Aplica o Html no corpo do email.
@author roney.maia
@since 29/08/2017
@version 6
@param oModelFld, objeto, Objeto Model
@type function
*/
Static Function OGX017PROC(oModelFld)
	
	Local cAliasQry	:= ""
	Local cBody		:= ""

	cAliasQry 	:= OGX017QRY() // Pbtém o alias a partir da query nos processos
	If Empty(cAliasQry)
		Return .f.
	EndIf
	
	dBSelectArea("N7L")
	cBody		:= Posicione("N7L", 1, xFilial("N7L") + AllTrim(oModelFld:GetValue("FLDTMPLT")), "N7L_MENSAG")
	_cWfProc	:= Posicione("N7L", 1, xFilial("N7L") + AllTrim(oModelFld:GetValue("FLDTMPLT")), "N7L_PWORKF")
			
	_oEditMail:SetText(OGX017HTML(cAliasQry, cBody)) // Faz o replace do html e aplica ao corpo
	OGX017ASST(.t., cAliasQry)
	
	If Empty(_cAliasBrw) .AND. Select(cAliasQry) > 0 // Se o Alias do browse nao foi informado e o alias montado via query existir e estiver aberto, repassa o alias para o browse
		(cAliasQry)->(dBGoTop())
		_cAliasBrw := cAliasQry
	ElseIf Select(cAliasQry) > 0 // Senão somente fecha o alias e utiliza posteriormente para o parse do formulario o alias do browse
		(cAliasQry)->(dBCloseArea())
	EndIf
	
Return .t.

/*{Protheus.doc} OGX017FIL
//Filtro da consulta padrão do campo Template.
@author roney.maia
@since 25/08/2017
@version 6
@type function
*/
Function OGX017FIL()
	Local cFiltro := "" 	

	If (!__lExecAuto .OR. !Empty(__cProcess)) .And. !IsInCallStack('UBAA070')  ///IsInCallStack('UBAA070')
		cFiltro 	:= "@ N7L_PROCES = '" + AllTrim(__cProcess) + "' AND N7L_STATUS = '1'"
	Else
		cFiltro 	:= "@ N7L_STATUS = '1'"
	EndIf

Return cFiltro

/*{Protheus.doc} OGX017QRY
//Monta o Alias com as tabelas provenientes do processo de e-mail e a chave de filtro.
@author roney.maia
@since 25/08/2017
@version 6
@type function
*/
Static Function OGX017QRY()

	Local aArea		:= GetArea() // Area ativa
	Local cAliasQry := GetNextAlias() // Obtem o proximo alias disponivel, tabela query
	Local cAliasTmp	:= GetNextAlias() // Obtem o proximo alias disponivel, tabela temporaria
	Local cQuery 	:= "" // Query
	Local aGridN7Z	:= {}
	Local aPaiRel	:= {}
	Local nIt		:= 0
	Local nX		:= 0	
	Local aFields 	:= {} // Fields da tabela temporária
	Local aStruct	:= {} // estrutura de campos das tabelas do processo
	Local auXStruc	:= {} // Estrutura auxiliar de campos
	Local cTabName	:= "" // Nome da tabela a ser utilizada na query por filial, para o caso de for 2 ou 3 caracteres
	Local cQryN7Z   := ""
	Local cAliasN7Z := ""
	Local cConteudo := ""
	Local cTab      := ""
	Local nTam      := 0
	Local cTbPai	:= Nil
    Local aCombo    := Nil

    Local lRetErro := .f.
	
	//##### MONTA ARRAY DE TABELAS E RELACIONAMENTOS PARA QUERY #####
	//dBSelectArea("N7W")
	//N7W->(dbSetOrder(1))
	
	//Iif(Empty(__cProcess), __cProcess := N7L->N7L_PROCES,"")
	cQryN7Z := "SELECT * FROM " + RetSqlName("N7Z") + " N7Z " + ;
	           "WHERE N7Z_FILIAL = '" + fwxFilial("N7Z") + "' " + ;
	           "AND N7Z_PROCES = '" + __cProcess + "' " + ;
	           " AND N7Z.D_E_L_E_T_ = ' ' " + ;
	           "ORDER BY N7Z_ORDEM " 
	               
	cAliasN7Z :=  GetSqlAll(cQryN7Z)
	If (cAliasN7Z)->(Eof())
		_cMsg := STR0072 //"Não foi encontrado cadastro de template de e-mail para o workflow."
        Return ""
	Else
		While !(cAliasN7Z)->(Eof())
			aAdd(aGridN7Z, { (cAliasN7Z)->N7Z_TABELA, (cAliasN7Z)->N7Z_RELAC })
			aStruct := FwFormStruct(1, (cAliasN7Z)->N7Z_TABELA ) // obtem a estrutura da tabela da posiciana na grid do processo
			For nX := 1 To Len(aStruct:aFields) // popula com todos os campos da estrutura o array afields com o Nome do campo, Tipo, Tamanho, Decimal
				aCombo := X3CBOXAVET(aStruct:aFields[nX][3])
                If !Empty(aCombo) .and. Len(aCombo) > 1
					nTam := 20
				Else
					nTam := aStruct:aFields[nX][5]
				EndIf
				aadd(aFields,{aStruct:aFields[nX][3],aStruct:aFields[nX][4],nTam,aStruct:aFields[nX][6]})
				_cFldStru += aStruct:aFields[nX][3] + ";"
			Next nX
		    (cAliasN7Z)->(DbSkip())
		EndDo
	EndIf
	
	(cAliasN7Z)->(DbCloseArea())

	If ValType(_oTempTab) != "U" // Se ja existe o objeto de tabela temporária, deleta o mesmo, fechando o alias utilizado
		_oTempTab:Delete()
	EndIf

	_oTempTab	:= FWTemporaryTable():New(cAliasTmp) // Instancia a tabela temporária com o alias
	_oTempTab:SetFields( aFields ) // seta os campos que serão utilizados na tabela temporária
	
	For nIt := 1 To Len(_aIndices) // Aplica os indices provenientes do parametro da OGX017
		_oTempTab:AddIndex(_aIndices[nIt][1], _aIndices[nIt][2])
	Next nIt

	If Len(aFields) > 0 //Apenas para não dar errorlog, caso nenhuma tabela tenha sido selecionada
		_oTempTab:Create() // Cria a tabela temporária
	EndIf
	
	If .NOT. Empty(aGridN7Z)
		For nIt := 1 To Len(aGridN7Z)
			auXStruc 	:= FwFormStruct(1, aGridN7Z[nIt][1])
			For nX := 1 To Len(auXStruc:aFields) // Popula com todos os campos da estrutura o array afields com o Nome do campo, Tipo, Tamanho, Decimal
				If "_" $ auXStruc:aFields[nX][3]
					cTabName := SubStr(AllTrim(auXStruc:aFields[nX][3]), 0, At("_", AllTrim(auXStruc:aFields[nX][3])) - 1) // Pega o nome do campo inicial
					Exit
				EndIf
			Next nX
			
			If Empty(aGridN7Z[nIt][2]) // Se o relacionamento estiver vazio, então é considerado como a tabela pai
				cTbPai	:= aGridN7Z[nIt][1]
			Else
				aAdd(aPaiRel, {aGridN7Z[nIt][1], AllTrim(aGridN7Z[nIt][2]), cTabName})
				cTabName := "" // limpa variavel
			EndIf
				
		Next nIt
	//##### MONTA QUERY COM AS TABELAS PROVENIENTES DO PROCESSO DE EMAIL E OS DEVIDOS RELACIONAMENTOS #####
	If __lExecAuto .And. IsInCallStack("UBAA070")			
	    cQuery := "Select DXD_FILIAL, DXD_CODIGO, DXD_CLACOM, DXD_SAFRA, Min(DXD_FDINI) DXD_FDINI, Max(DXD_FDFIN) DXD_FDFIN "
	Else
		If Empty(cTbPai)
			//"Processo de e-mail cadastrado incorretamente para a rotina."
			//"Na linha de 'Ordem 001' devera ser informado apenas a tabela pai como referencia. 
			//Nela não devera ser informada a coluna 'Relacionamento'. 
			//Na linha de 'Ordem 002' deverá ser informada a tabela filho e na coluna 'Relacionamento', 
			//os campos relacionados com a tabela pai. Ex:(DXP_CODIGO=DXI_CODRES)."
			AGRHELP("OGX017001",STR0067,STR0068)
			Return ""
		EndIf
		cQuery += "SELECT " + Alltrim(cTbPai) + ".* "
		cQuery += ", "      + Alltrim(cTbPai) + ".R_E_C_N_O_ " + alltrim(cTbPai) + "_RECNO " 	    		

		If Len(aGridN7Z) > 1
	    	For nIt := 1 To Len(aPaiRel) // Adiciona as tabelas filhas e seus relacionamentos
	    		cQuery += ", " + Alltrim(aPaiRel[nIt][1]) + ".*"
	    		cQuery += ", " + Alltrim(aPaiRel[nIt][1]) + ".R_E_C_N_O_ " + alltrim(aPaiRel[nIt][1]) + "_RECNO " 	    		
	    	Next nIt
	    EndIf
	EndIf
	    cQuery += " FROM " + RetSqlName(cTbPai) + " " + cTbPai // Tabela Pai
	    
	    If Len(aGridN7Z) > 1
	    	For nIt := 1 To Len(aPaiRel) // Adiciona as tabelas filhas e seus relacionamentos
	    		While At("XFILIAL",aPaiRel[nIt][2]) > 0
	    			nPos     := At("XFILIAL",aPaiRel[nIt][2])
	    			cExecFil := &(SubStr(aPaiRel[nIt][2],nPos,14))
	    			aPaiRel[nIt][2] := SubStr(aPaiRel[nIt][2],1, nPos-1) + "'" + cExecFil + "' " + SubStr(aPaiRel[nIt][2], nPos+15, Len(aPaiRel[nIt][2]))
	    		EndDo
	    		cQuery += " LEFT JOIN " + RetSqlName(aPaiRel[nIt][1]) + " " + aPaiRel[nIt][1] + " ON " + AllTrim(aPaiRel[nIt][2])
	    		cQuery += " AND " + AllTrim(aPaiRel[nIt][1]) + ".D_E_L_E_T_ = '' " 
	    	Next nIt
	    EndIf
	    
	    If .NOT. Empty(_cChave) // Monta o filtro, sendo importante ter a chave para filtrar somente em cima do registro especifico.
	    	cQuery += " WHERE " + AllTrim(_cChave)
	    	cQuery += " AND " + AllTrim(cTbPai) + ".D_E_L_E_T_ = '' " 
	    Else
	    	cQuery += " WHERE " + AllTrim(cTbPai) + ".D_E_L_E_T_ = '' " 
	    EndIf
	    
	    If __lExecAuto .And. IsInCallStack("UBAA070")			
	    	cQuery += " GROUP BY DXD_FILIAL, DXD_SAFRA,DXD_CODIGO, DXD_CLACOM "
	    EndIf
	    
	// ####################################################################################################    
		cQuery := ChangeQuery( cQuery )
		
		If Select(cAliasQry) > 0 // Se o alias estiver aberto, fecha o alias
			(cAliasQry)->( dbCloseArea() )
		EndIf
        
        oError := ErrorBlock({|e| lRetErro := fTrataErro(e) })

        BEGIN SEQUENCE
		    dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasQry, .F., .T. ) // Executa a query            
        END SEQUENCE		        

        ErrorBlock(oError)                    

        If lRetErro
            Return ""
        EndIf

        aStruct := (cAliasQry)->(dBStruct()) // Obtém a estrutura da tabela query
		
		Do While .NOT. (cAliasQry)->(Eof()) // Popula a tabela temporária
			RecLock((cAliasTmp),.T.)
				if __lExecAuto .And. IsInCallStack("UBAA070")				
					For nIt := 1 To Len(aFields)
						If aScan(aStruct, {|x| AllTrim(x[1]) == AllTrim(aFields[nIt][1]) }) > 0// .or. aFields[nIt][2] == "M" // Verifica se o campo existe, para popular a tabela temporária												
							(cAliasTmp)->&(aFields[nIt][1])	:= OGX017TRT((cAliasQry)->&(aFields[nIt][1]), aFields[nIt][2], aFields[nIt][1])
						endIf
					Next nIt				
				else				
					For nIt := 1 To Len(aFields)
						If aScan(aStruct, {|x| AllTrim(x[1]) == AllTrim(aFields[nIt][1]) }) > 0 .or. aFields[nIt][2] == "M" // Verifica se o campo existe, para popular a tabela temporária												
							
							If aFields[nIt][2] == "M" 
							   cConteudo := ""
							   cTab := substr(aFields[nIt][1],1,3)
							   
							   If At("_", cTab) > 0
								 cTab := "S" + substr(cTab,1,2)
							   EndIf
							   
							   DbSelectArea(cTab)
							   If FieldPos(aFields[nIt][1])							  
							      DbGoTo((cAliasQry)->&(cTab+"_RECNO"))						   
								  cTab += "->"+aFields[nIt][1] 
								  cConteudo := &(cTab) 
							   EndIf						 
							Else
							   cConteudo := (cAliasQry)->&(aFields[nIt][1])
							EndIf						
							
							(cAliasTmp)->&(aFields[nIt][1])	:= OGX017TRT(cConteudo, aFields[nIt][2], aFields[nIt][1])					
						EndIf		
					Next nIt
				endIF
			MsUnlock()
			(cAliasQry)->(dbSkip())
		EndDo
		If .NOT. Empty(_nSetOrd) // Caso houver o parametro de ordem do indice, seta a ordem
			(cAliasTmp)->(dbSetOrder(_nSetOrd))
		EndIf
		(cAliasTmp)->(dbGoTop()) // Posiciona no topo	
	Else
		cAliasQry := ""
	EndIf
	
	RestArea(aArea)

Return cAliasTmp

/*{Protheus.doc} OGX017HTML
//Monta o novo html com os valores nos respectivos campos do template.
@author roney.maia
@since 25/08/2017
@version 6
@param cAliasQry, characters, Alias com os campos
@param cBody, characters, Corpo do HTML
@type function
*/
Static Function OGX017HTML(cAliasQry, cBody)
	
	Local aArea		:= GetArea()
	Local nPrToken	:= 0 // posição do primeiro token $! CAMPO
	Local nSegToken	:= 0 // posição do segundo Token CAMPO $1
	Local cCmpAux	:= "" // Auxiliar de campo
	Local cCmpToken	:= "" // Campo de token inteiro
	Local nBodyTam  := Len(cBody) // Tamanho do corpo do e-mail
    Local cValCmp   := "" // Valor real do campo
    Local xValCmp   := Nil // Valor obtido pelo alias correspondente do campo
    Local cBarras 	:= If(isSRVunix(),"/","\") // Verifica o sistema operacional e retorna a barra utilizada para o path
    Local cBarrasIn := If(!isSRVunix(),"\","/") // Verifica o sistema operacional e retorna a barra utilizada para o path
	Local cWfDir 	:= SuperGetMv("MV_WFDIRWF", .F., cBarras + "workflow")
    
    Local nTrToken	:= 0 // posição do token table
    Local nTrIni	:= 0
    Local nTrFim	:= 0
    Local cTrRep	:= ""
    Local cTrAux	:= ""
     
    Default cBody  		:= ""
    Default cAliasQry   := ""
    
    If !(cBarras $ cWfDir) // Validação de auxilio, caso receber um caminho no servidor no qual o caminho possa ser diferente devido ao sistema operacional.
		cWfDir :=  StrTran(cWfDir, cBarrasIn, cBarras)
	EndIf

    If !Empty(cBody) .AND. !Empty(cAliasQry) // Se o corpo do email e o alias não estiver vazio, então trata o html
               
        Do While (nPrToken := At("$!", cBody)) > 0 .OR. (nTrToken := At("##", cBody)) > 0
            If nPrToken > 0 // Se for campos padrões com o token $!
                cCmpAux   	:= SubStr(cBody, nPrToken + 2, nBodyTam)
                nSegToken 	:= At( "$!", cCmpAux)                
                cCmpToken   := SubStr(cBody, nPrToken, nSegToken + 3)                
                
                If __lWorkFl
	                If !("$!LINKFORM" $ cCmpToken) 
	                	xValCmp    	:= IIF(StrTran(cCmpToken,"$!","") $ _cFldStru, (cAliasQry)->&(StrTran(cCmpToken,"$!","")), "")
	                	cValCmp    	:= OGX017TRT(xValCmp,,StrTran(cCmpToken,"$!",""))
	                Else
	                	cPosTit1 := At( "#!", cCmpToken)         
						cPosTit2 := At( "!#", cCmpToken)         
						
						If cPosTit1 > 0 .And. cPosTit2 > 0
							cTitulo   := SubStr(cCmpToken, cPosTit1 + 2 , cPosTit2 - cPosTit1 - 2)
							_cFormWork := cWfDir + cBarras + "templates" + cBarras + Alltrim(SubStr(cCmpToken, cPosTit2 + 3 , len(cCmpToken) - cPosTit2 - 4 )) 
							cValCmp   := "<a href='%proclink%'>"+cTitulo+"</a>"
						EndIf
	                EndIf
	            Else
	            	xValCmp    	:= IIF(StrTran(cCmpToken,"$!","") $ _cFldStru, (cAliasQry)->&(StrTran(cCmpToken,"$!","")), "")
	                cValCmp    	:= OGX017TRT(xValCmp,,StrTran(cCmpToken,"$!",""))
	            EndIf
                
                cBody 		:= StrTran(cBody,cCmpToken,cValCmp)
                nPrToken	:= 0 // Limpa variavel
            ElseIf nTrToken > 0 // Se for campos de colunas em grids com o token ##
                
                nTrIni		:= RaT("<tr", SubStr(cBody, 0, nTrToken)) // Obtém a posição da tag <tr> que contem o campo em questão
            	nTrFim		:= At("</tr", SubStr(cBody, nTrIni, nBodyTam - nTrIni)) // Obtém a posição da tag </tr> que contem o campo em questão            	
            	cTrRep		:= SubStr(cBody, nTrIni, nTrFim + 4) // extrai do corpo do html a linha <tr></tr> que contem o campo em questão
            	cTrAux		:= cTrRep // atribui a uma variavel auxiliar
            	
            	// Alteração da <tr> e população dos campos
            	Do While (nPrToken := At("##", cTrAux)) > 0 
            		cCmpAux   	:= SubStr(cTrAux, nPrToken + 2, Len(cTrAux))
	                nSegToken 	:= At( "##", cCmpAux)
	                cCmpToken   := SubStr(cTrAux, nPrToken, nSegToken + 3)
	                xValCmp    	:= IIF(StrTran(cCmpToken,"##","") $ _cFldStru, (cAliasQry)->&(StrTran(cCmpToken,"##","")), "")
	                cValCmp    	:= OGX017TRT(xValCmp,,StrTran(cCmpToken,"$!",""))
	                cTrAux 		:= StrTran(cTrAux,cCmpToken,cValCmp)
	                
	                If .NOT. (At("##", cTrAux) > 0) .AND. .NOT. (cAliasQry)->(Eof())                		
	                	(cAliasQry)->(dBSkip())
	                	If .NOT. (cAliasQry)->(Eof()) // Incremento de linhas com base na quantidade do alias
	                		cTrAux += cTrRep
	                	EndIf	
	                EndIf
            	EndDo
            	cBody 		:= StrTran(cBody,cTrRep,cTrAux) // subistitui as linhas com os campos correspodentes substituidos
            	nBodyTam	:= Len(cBody) // Atualiza o tamanho do corpo do html
            	(cAliasQry)->(dBGoTop()) // Reposiciona no recno principal.
            	nTrToken	:= 0 // Limpa variavel
            EndIf
        EndDo
    EndIf
    
	RestArea(aArea)	
	
Return cBody

/*{Protheus.doc} OGX017TRT
//Converte valores de campos especificos para caracter.
@author roney.maia
@since 28/08/2017
@version 6
@param xValor, , Valor do campo
@param cType, , Tipo do campo
@type function
*/
Static Function OGX017TRT(xValor, cType, cCampo)
	Local cValCmp 	:= ""
    Local aCombo    := {}
	Default xValor 	:= Nil
	Default cType   := ""
	Default cCampo  := ""

	If .NOT. Empty(cType) // Trata valores do alias query
	
		Do Case
	        Case cType == "N"
	            cValCmp := xValor
	        Case cType == "M"
	            cValCmp := xValor
	        Case cType == "D"
	            cValCmp := STOD(xValor)
	        Case cType == "L"
	            If AllTrim(xValor) == "T"
	                cValCmp := .T.// # verdadeiro
	            Else
	                cValCmp := .F. // # falso
	            EndIf
	        Case cType == "C"
	        	aCombo := X3CBOXAVET(cCampo)
                If !Empty(aCombo) .and. Len(aCombo) > 1 
	        		cValCmp := X3CboxDesc( cCampo, xValor )
	        	Else
	        		cValCmp := xValor
	        	EndIf
	    EndCase
	    
	ElseIf xValor != Nil // Trata valores do parse html
	
	    Do Case
	        Case ValType(xValor) == "N"
	            cValCmp := cValToChar(xValor)
	        Case ValType(xValor) == "M"
	            cValCmp := xValor
	        Case ValType(xValor) == "D"
	            cValCmp := DTOC(xValor)
	        Case ValType(xValor) == "C"
	            If AllTrim(xValor) == "T"
	                cValCmp := STR0020 // # verdadeiro
	            ElseIf AllTrim(xValor) == "F"
	                cValCmp := STR0021 // # falso
	            Else
	        		cValCmp := xValor
		        EndIf
	    EndCase
	    
	EndIf

Return Iif(ValType(cValCmp) == "C" , AllTrim(cValCmp), cValCmp)

/*{Protheus.doc} OGX017Mail
//Função acionada ao clicar em Enviar, que envia o e-mail.
@author marcelo.wesan
@since 28/08/2017
@version 6
@param 
@param cAssunto, cEmails, cMesg
@type function
*/
Function OGX017MAIL(cAssunto,cEmails,cMesg, cRemetnt, aAnexos)  // MANDA E-MAIL PELA TOTVS
 
	Local oMail 		:= TMailManager():New()								// Gerenciador de e-mail
	Local nRet 			:= 0
	Local cSMTPAddr     := AllTrim( SuperGetMV("MV_RELSERV",.F.,"") )       // Endereco SMTP.
	Local cUser         := AllTrim( SuperGetMV("MV_RELACNT",.F.,"") )       // Conta a ser utilizada no envio de E-Mail para os relatorios, utilizado na autenticação.
	Local nSMTPPort     := SuperGetMV("MV_PORSMTP",.F.,25)					// Porta definida para o servidor smtp
	Local cPass         := SuperGetMV("MV_RELPSW" ,.F.,"")                  // Senha da Conta de E-Mail para envio de relatorios. 
	Local nSMTPTime     := SuperGetMV("MV_RELTIME",.F.,120)                 // Timeout no Envio de EMAIL.
	Local lTLS          := SuperGetMV("MV_RELTLS",.F.,.F.)					// Usa TLS ?
	Local lSSL          := SuperGetMV("MV_RELSSL",.F.,.F.)					// Usa SSL ?
	Local lAutentica    := SuperGetMV("MV_RELAUTH",.F.,.F.)                 // Servidor de EMAIL necessita de Autenticacao ?
	Local cBody         := cMesg											// Corpo do e-mail
	Local cRemet		:= SuperGetMV("MV_RELFROM",.F.,.F.) 				//cRemetnt //Remetente do e-mail
	Local cDest         := cEmails
	Local cSubj         := cAssunto
	Local cMsg			:= ""
	Local aAnexs		:= aAnexos
	Local nPortAddSr	:= 0
	Local oMessage		:= Nil
	Local nIt			:= 0
	Local lCompacta 	:= .T.
	Local cBarras 		:= If(isSRVunix(),"/","\") // Verifica o sistema operacional e retorna a barra utilizada para o path
   	Local cFoldTmMl		:= cBarras + "tempemail" // Pasta para e-mails, *necessario a barra no inicio
   	Local cTime			:= TIME()
   	Local cFolderTmp	:= DTOS(DATE()) + SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2) + SubStr(cTime, 7, 2) + RetCodUsr() + "mail" // Cria a pasta com a data hora atual
	Local cDirTemp		:= cFoldTmMl + cBarras + cFolderTmp // Concatena montando o diretorio para salvar os anexos temporarios
	Local aArea			:= GetArea()
	Local lContinua 	:= .T.
	
	If .NOT. ExistDir(cFoldTmMl) // se não existe a pasta de e-mails temporários, então cria a pasta
		MakeDir(cFoldTmMl) // cria a pasta
	EndIf
	
	If .NOT.Empty(aAnexs)  // Codição para copiar arquivos do ambiente smartclient para o ambiente servidor. Necessário para o envio de anexos
		MakeDir(cDirTemp) // Cria o diretorio para a cópia de arquivos
		For nIt := 1 To Len(aAnexs)
			If .NOT. CpyT2S(AllTrim(aAnexs[nIt][3]), cDirTemp + cBarras, lCompacta) // Copia os arquivos do smartclient para o server
				cMsg += STR0044 + ": " + aAnexs[nIt][2] + CRLF // # Não foi possível anexar o arquivo
			Else
				aAnexs[nIt][3] := cDirTemp + cBarras +  AllTrim(aAnexs[nIt][2])
			EndIf
		Next nIt
	EndIf
	 
    If Empty(nSMTPPort) // Se o parametro estiver vazio usa a porta default 25
    	nSMTPPort := 25 // Porta padrão SMTP
    EndIf

	If IsInCallStack('UBAX90') .and. !Empty(FwXFilial("NLO"))
		cSubj := cSubj + " [ "+FwXFilial("NLO")+" ] "
	EndIf
    
    oMessage := TMailMessage():New() // Gerenciador de mensagem
    oMessage:Clear()
   
  	oMessage:cDate := cValToChar( Date() ) // Data da mensagem
  	oMessage:cFrom := cRemet // Remetente:
  	oMessage:cTo := cDest // Para:
  	oMessage:cSubject := cSubj // Assunto:
  	oMessage:cBody := cBody // Corpo da mensagem
  	
  	For nIt := 1 To Len(aAnexs)
	  	nRet := oMessage:AttachFile(AllTrim(aAnexs[nIt][3]))
	  	If nRet < 0	
	  		conout( nRet )
	     	conout( oMail:GetErrorString( nRet ) )
	     	cMsg += STR0044 + ": " + aAnexs[nIt][2] + CRLF // # Não foi possível anexar o arquivo
	     	lContinua := .F.
	  	EndIf
	Next nIt

	If lSSL // Se usa SLL então seta o SLL como verdadeiro
		oMail:SetUseSSL(lSSL)
    ElseIf lTLS // Se usa lTLS então seta o lTLS como verdadeiro
    	oMail:SetUseTLS(lTLS)
    Endif
	
	nPortAddSr := AT(":",cSMTPAddr)
    
    If nPortAddSr > 0 // Se o endereço contem a porta, separa o endereço da porta
        nSMTPPort := Val(Substr(cSMTPAddr, nPortAddSrv + 1,Len(cSMTPAddr)))
        cSMTPAddr := Substr(cSMTPAddr, 0, nPortAddSrv - 1)
    EndIf
    
	nRet := oMail:Init( "", cSMTPAddr ,cUser,cPass, , nSMTPPort) // Inicializa o gerenciador smtp
	
	If nRet <> 0
        Conout(STR0022+ oMail:GetErrorString(nRet)) // Falha ao conectar:"
        cMsg := STR0023 // # Falha validar usuario e senha.
    EndIf
   
     // Define o Timeout SMTP
    If ( nRet == 0 .And. oMail:SetSMTPTimeout(nSMTPTime) <> 0 )
    	nRet := 1
    	conout(STR0024) // # Falha ao definir timeout
    	If Empty(cMsg)
    		cMsg := STR0024 // # Falha ao definir timeout
    	EndIf
    Else
    	conout(STR0025)// "SetSMTPTimeout Successful"
    EndIf
    
    nRet := oMail:SMTPConnect() // Conecta no servidor smtp
   
    If nRet == 0
     	conout(STR0026)//"Connect Successful"
    Else
     	conout( nRet )
     	conout( oMail:GetErrorString( nRet ) )
     	If Empty(cMsg)
    		cMsg :=  STR0031 // # Servidor smtp se encontra inacessível.
    	EndIf
    	
    	lContinua := .F.
    Endif
    
    If nRet == 0 .And. lAutentica // Se tem autenticação então
    	nRet  := oMail:SmtpAuth(cUser,cPass)
	    If nRet <> 0
	        conout(oMail:GetErrorString(nRet)) // Falha ao autenticar:
	        oMail:SMTPDisconnect()
	        If Empty(cMsg)
	        	cMsg := STR0035 // # Falha ao autenticar.
    		EndIf
    		
    		lContinua := .F.
	    EndIf
    EndIf
    
	nCont     := 0

	While lContinua .AND. nCont <= 2
		nRet := oMessage:Send(oMail) // Envia o e-mail
		nCont := nCont + 1
		If nRet == 0
			lContinua := .F.
			conout(STR0027)//"SendMail Successful"
			If .NOT. Empty(aAnexs) .AND. .NOT. Empty(cDirTemp) .AND. cFolderTmp $ cDirTemp .AND. ExistDir(cDirTemp)// Verificações de pasta para remoção apos envio de anexos
				For nIt := 1 To Len(aAnexs)
					If File(aAnexs[nIt][3]) .AND. FErase(aAnexs[nIt][3]) < 0
						conout(STR0045 + ": " + cDirTemp ) // # Falha ao apagar arquivos temporarios
					EndIf
				Next nIt
				DirRemove(cDirTemp) // Remove o diretorio de anexos
			EndIf
			If !IsInCallStack("EMAILALCAD") .And. !IsInCallStack("OGX820")
				OGX017MSG(STR0028, STR0030, "ALERT" )  // # Email enviado com sucesso."#Atencao
			EndIf
		Else
			conout( nret )
			conout( oMail:GetErrorString( nret ) )
			If Empty(cMsg)
				cMsg :=  STR0032 // # Falha no envio de e-mail.
			EndIf
		Endif
		If lContinua
			oMessage:cFrom := cUser // Remetente:
		EndIf
	EndDo
    
    nRet := oMail:SmtpDisconnect() // Desconecta o smtp
    
    If nRet == 0
     	conout(STR0029)//"Disconnect Successful" 
    Else
     	conout( nret )
     	conout( oMail:GetErrorString( nret ) )
     	If Empty(cMsg)
    		cMsg := STR0033 // # Falha ao desconectar do servidor smtp.
    	EndIf
    Endif
    
    If .NOT. Empty(cMsg) // Em caso de ocorrer qualquer falha, deleta os arquivos de anexo e o diretorio
		For nIt := 1 To Len(aAnexs)
			If File(aAnexs[nIt][3]) .AND. FErase(aAnexs[nIt][3]) < 0 // Remove os arquivos
				conout(STR0045 + ": " + cDirTemp ) // # Falha ao apagar arquivos temporarios
			EndIf
	 	Next nIt
	    DirRemove(cDirTemp) // Remove o diretorio de anexos
	EndIf
    
    RestArea(aArea)
    
Return cMsg

/*{Protheus.doc} OGX017OK
//Função acionada ao clicar em Enviar, que trata validações e
o envio do e-mail.
@author roney.maia
@since 25/08/2017
@version 6
@param oView, object, View Pai
@param cAcao, characters, Ação de chamada
@type function
*/
Static Function OGX017OK(oView, cAcao) 

	Local aArea		:= GetArea() // Area ativa	
	Local oModel  	:= Nil
	Local oModelFld := Nil
	Local cRemetnt	:= ""
	Local cEmails 	:= ""
	Local cAssunto 	:= ""
	Local cBody     := ""
	Local aAnexos	:= Iif(.NOT. Empty(_aAnexos), aClone(_aAnexos), {})
	Local nIt		:= 0
	Local cAliasQry	:= ""
	Local cTime			:= TIME()
	Local cNewMod		:= DTOS(DATE()) + SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2) + SubStr(cTime, 7, 2)
	
	__oViewAct := FwViewActive() // Obtém a view ativa devido a recursividade de views
		
	Do Case
		Case cAcao == "bOk"
		
			If !__lExecAuto //IsInCallStack('UBAA070')
		
				oModel  	:= oView:GetModel()
				oModelFld 	:= oModel:GetModel("MODEL_FLD")
				cRemetnt	:= AllTrim(oModelFld:GetValue("FLDREMETENTE"))
				cEmails 	:= oModelFld:GetValue("FLDMAILS")
				cAssunto 	:= oModelFld:GetValue("FLDASSUNT")
				cBody     	:= _oEditMail:GetText()
			Else
				("N7L")->(dBCloseArea())
				DbSelectArea("N7L")
				dbSetOrder(1)
				If dbSeek(xFilial("N7L")+_cTemplate)
					cAssunto := N7L->N7L_ASSUNT
					cBody	 := N7L->N7L_MENSAG //obtem padrao
					If _cWfProc == ''
						_cWfProc := N7L->N7L_PWORKF
					EndIf
				EndIf
				cRemetnt 	:= _cRemetent
				cEmails 	:= _cEmails
				cAliasQry 	:= OGX017QRY()
                If Empty(cAliasQry)
                    Return .F.
                EndIf   
				cBody		:= OGX017HTML(cAliasQry, cBody) //Formata a mensagem
				OGX017ASST(.t., cAliasQry)
				
				If Select(cAliasQry) > 0 // Se o Alias existir e estiver aberto, fecha o alias
					(cAliasQry)->(dBCloseArea())
				EndIf
			EndIf
			
			If Empty(cEmails)
  	  	       OGX017MSG("", STR0036 )  // # Campo ( Para ) não foi preenchido.
               Return .F.
			ElseIf Empty(cAssunto)
				IF !OGX017MSG("", STR0019, "YESNO", .T.)
				   //If !MsgYesNo(STR0019) // # Deseja enviar esta mensagem sem um assunto ?
				   Return .F.
				Else
				   If __lWorkFl // Se for envio atraves de workflow.
				   		If !__lExecAuto
				   			FwMsgRun(, {|tSay| _cMsg := OGX017WFML(_cWfProc, cBody, cAssunto ,cEmails, _cFormWork, aAnexos, _aWfRet, _cAliasBrw, tSay)}, STR0061) // # Enviando e-mail...
						Else
							_cMsg := OGX017WFML(_cWfProc, cBody, cAssunto ,cEmails, _cFormWork, aAnexos, _aWfRet, _cAliasBrw)
						EndIf
				   Else
				   		_cMsg := OGX017MAIL(cAssunto,cEmails,cBody, cRemetnt, aAnexos) /// envia o e-mail
				   EndIf
				   
				   If .NOT. Empty(_cMsg)
				      OGX017MSG("", _cMsg )
				      Return .F.
				   Else
				  	  aAdd(_aRet, {cAssunto, cEmails, _cTemplate, .T., _cMsg})
				   EndIf 
				   
				   If ValType(__oViewAct) == "O" .AND. __oViewAct:GetModel():GetId() == "OGX017"
				      __oViewAct:SetModified(.T.) // Seta a view como modificada
				      __oViewAct:GetModel():GetModel("MODEL_FLD"):SetValue("FLDMODIFY", cNewMod) 
				   EndIf
				   
				EndIf
			Else
				If __lWorkFl  // Se for envio atraves de workflow.
					If !__lExecAuto
						FwMsgRun(, {|tSay| _cMsg := OGX017WFML(_cWfProc, cBody, cAssunto ,cEmails, _cFormWork, aAnexos, _aWfRet, _cAliasBrw, tSay)}, STR0061) // # Enviando e-mail...
					Else
						_cMsg := OGX017WFML(_cWfProc, cBody, cAssunto ,cEmails, _cFormWork, aAnexos, _aWfRet, _cAliasBrw)
					EndIf
				Else
					_cMsg := OGX017MAIL(cAssunto,cEmails,cBody, cRemetnt, aAnexos) /// envia o e-mail
				EndIf
			   	
			   	If .NOT. Empty(_cMsg)
				  	OGX017MSG("", _cMsg )
				  	Return .F.
				Else
				  	aAdd(_aRet, {cAssunto, cEmails, _cTemplate,.T., _cMsg})
				EndIf
				
				If ValType(__oViewAct) == "O" .AND. __oViewAct:GetModel():GetId() == "OGX017"
				      __oViewAct:SetModified(.T.) // Seta a view como modificada
				      __oViewAct:GetModel():GetModel("MODEL_FLD"):SetValue("FLDMODIFY", cNewMod) 
				EndIf
				
			EndIf
		Case cAcao == "bAnexoOk" // Caso a ação for disparada pela view de Anexar arquivos
			If .NOT. Empty(_aBrwAnx) // Verifica o array do browse e popula o array de anexos do e-mail
				_cAnexos := ""
				_aAnexos := {}
				For nIt := 1 To Len(_aBrwAnx)
					If	_aBrwAnx[nIt][1] == "1" 
						_cAnexos += AllTrim(_aBrwAnx[nIt][2]) + "; " // Concatena os anexos para aplicar ao campo Anexos
						aAdd(_aAnexos, { _aBrwAnx[nIt][1], _aBrwAnx[nIt][2], _aBrwAnx[nIt][3]}) // Popula o array principal de Anexos com o check, nome do arquivo, caminho do arquivo
					EndIf
				Next nIt
				_cAnexos := SubStr(_cAnexos, 0, Len(_cAnexos) - 2)
			EndIF
			
			If ValType(__oViewAct) == "O" .AND. __oViewAct:GetModel():GetId() == "OGX017"
				__oViewAct:SetModified(.T.) // Seta a view como modificada
				__oViewAct:GetModel():GetModel("MODEL_FLD"):SetValue("FLDANEXOS", _cAnexos) // Seta o campo Anexos
			EndIf
			
	EndCase
	RestArea(aArea)
Return .T.

/*{Protheus.doc} OGX017ANX
//Função de menu utilizado para anexar arquivos ao e-mail.
@author roney.maia
@since 06/09/2017
@version 6
@return ${return}, ${.T. - VALIDO, .F. - INVALIDO}
@param oView, object, View que contem o botão
@type function
*/
Static Function OGX017ANX(oView)

	Local lRet 		:= .T.
	Local nRet		:= 0
	Local aAnxClon	:= {}
	Local aButtons 	:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T., STR0046},{.T., STR0002},{.F., Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} // # Anexar # Fechar
	
	Private _cAnexos	:= oView:GetModel():GetModel("MODEL_FLD"):GetValue("FLDANEXOS") // obtém os anexos contido no campo de Anexos
	Private _oBrwAnx	:= Nil // Objeto do browse presente na tela de Anexar arquivos
	Private _aBrwAnx	:= _aAnexos // Atribui o array de anexo ao array controlado e utilizado pelo Browse na tela de Anexar arquivos
	
	aAnxClon	:= aClone(_aAnexos) // Clona os anexos para um array auxiliar, caso na tela de Anexar arquivos, for clicado no botão fechar
	
	_lAnexo := .T.
	
	nRet = FWExecView(STR0042, 'OGX017', MODEL_OPERATION_INSERT, , {|| .T.}, {|oView| lRet := OGX017OK(oView, "bAnexoOk")}, 70, aButtons) // # Anexar arquivos
	
	If nRet == 0 // Se clicado no botão OK então, seta os anexos no campo Anexos
		oView:GetModel():GetModel("MODEL_FLD"):SetValue("FLDANEXOS", _cAnexos)
	Else // Se clicado no Fechar ou encerrar a janela, mantém o array de anexos anterior
		_aAnexos := aAnxClon
	EndIf
		
Return lRet

/*{Protheus.doc} OGX017VAC
(Pós ativação da view, permite alterar o campo FLDANEXOS para somente leitura)
@type function
@author roney.maia
@since 06/09/2017
@version 1.0
@param oView, objeto, (View Ativa)
@return ${lRet}, ${.T. - Valido, .F. - Inválido }
*/
Static Function OGX017VAC(oView)

	Local lRet 			:= .T.
	Local oGetTipAct 	:= Nil
	Local oModelFld     := Nil
	Local oModel		:= oView:GetModel() 
	
	oGetTipAct 	:= oView:GetViewObj("VIEW_ANEXOBOT")[3]:GetFwEditCtrl("FLDANEXOS"):OCTRL // Resgata o objeto FwTGet referente ao campo DXP_TIPACT
	oGetTipAct:lReadOnly := .T. // habilita somente leitura
	
	If __lWorkFl
	 	oModelFld    := oModel:GetModel('MODEL_FLD')
		If !Empty(__cProcess) .AND. !Empty(_cTemplate) .AND. (lRet := ExistCpo("N7L", AllTrim(_cTemplate) + AllTrim(__cProcess)))			
			Processa({|| lRet := OGX017PROC(oModelFld)}, STR0034) // # Processando o Template...						
		EndIf
	EndIf		
	
Return lRet

/*{Protheus.doc} OGX017VAN
//Função que cria os objetos para preencher a view.
@author roney.maia
@since 07/09/2017
@version 6
@param oPanel, object, Panel pai para a construção dos objetos
@param oObj, object, Objeto generico que contém a view pai
@type function
*/
Static Function OGX017VAN(oPanel, oObj)

	Local oFwLayPai   	:= FwLayer():New() // Cria uma Layer para divisão do Panel
	Local oFwLayLin		:= FwLayer():New() // Cria uma Layer para divisão do Panel Pai
	Local oFwLayPth		:= FwLayer():New() // Cria uma Layer para divisão do Panel Path
	Local oColPanel		:= Nil
	Local oPanelF		:= Nil // Panel que contem o GetFile
	Local oPanelGrd		:= Nil // Panel que contem o grid com anexos
	Local oBtnPth		:= Nil
	Local oGetPth		:= Nil
	Local oSayPth		:= Nil
	Local bPathF		:= {|| OGX017CAN(oGetPth)}
	Local oPanelLbl		:= Nil
	Local oPanelGet		:= Nil
	Local oPanelBtn		:= Nil
	Local oFont 		:= TFont():New('Courier new',,-12,.T.) // Cria um objeto tfont
		
	// ##### Cria os Layers com seus devidos Panels #####
	
	oFwLayPai:Init(oPanel, .F., .T.) // Inicia a criação do Layer
	
	oFwLayPai:AddCollumn('COL01', 100, .F., "LINHA") // Adiciona uma coluna ao panel pai
	
	oColPanel := oFwLayPai:getColPanel("COL01","LINHA") // Obtem o panel da coluna previamente adicionada
	
	oFwLayLin:init(oColPanel, .F.) // Inicia a criação de um novo Layer para a coluna obtida
	
	oFwLayLin:AddLine("GETFILE" ,20,.F.) // Adiciona uma linha de cabeçalho na coluna obtida
	oFwLayLin:AddLine("GRIDANEXOS" ,80,.F.) // adiciona uma linha para grid na coluna obtida
	
	oPanelF := oFwLayLin:GetLinePanel("GETFILE") // Obtem o panel da linha referente ao cabeçalho
	
	oFwLayPth:init(oPanelF, .F.) // Inicia a criação de uma nova Layer para a linha de cabeçalho
	
	// Adiciona colunas ao panel de cabeçalho
	oFwLayPth:AddCollumn('COLPTH01', 20, .F.)
	oFwLayPth:AddCollumn('COLPTH02', 60, .F.)
	oFwLayPth:AddCollumn('COLPTH03', 20, .F.)
	
	oPanelLbl := oFwLayPth:getColPanel("COLPTH01") // Obtém o panel da coluna 1 do cabeçalho
	oPanelGet := oFwLayPth:getColPanel("COLPTH02") // Obtém o panel da coluna 2 do cabeçalho
	oPanelBtn := oFwLayPth:getColPanel("COLPTH03") // Obtém o panel da coluna 3 do cabeçalho
	
	oPanelGrd 	:= oFwLayLin:GetLinePanel("GRIDANEXOS")	
	
	// ####################################################
	
	// ##### Criação de objetos utilizados em tela #####
	
	oSayPth := TSay():New(15, 30,{||STR0047 + ": "},oPanelLbl,,oFont,,,,.T.,CLR_RED,CLR_WHITE, 30,10) // Cria o lavel Arquivos # Arquivo
	
	oGetPth := TGet():New( 01, 01, {|| _cAnexos }, oPanelGet, 200, 12, '@', , , , , , , , , , , , , , .T.) // Cria o box de caminhos de arquivos
				
	oBtnPth := TButton():New( 10, 01, STR0048, oPanelBtn, bPathF, 35, 18, , , , .T.) // Cria o botão adicionar # Adicionar
	oBtnPth:SetCss(FwGetCss(oBtnPth, CSS_BUTTON_FOCAL)) // Seta um css para o botão
	
	_oBrwAnx := FWBrowse():New(oPanelGrd) // Cria um novo browse passando o objeto pai no qual o browse sera aplicado.
    _oBrwAnx:SetDataArray(.T.) // Seta o tipo como array
    _oBrwAnx:DisableFilter(.T.) 
    _oBrwAnx:DisableReport(.T.) 
    _oBrwAnx:DisableSeek(.T.) 
    _oBrwAnx:SetArray(_aBrwAnx)
    _oBrwAnx:SetProfileID("OGX017")
    _oBrwAnx:AddMarkColumns( { ||Iif( !Empty( _aBrwAnx[_oBrwAnx:nAt,1] = "1" ),"LBOK","LBNO" ) }, { || _aBrwAnx[_oBrwAnx:nAt,1] := IIF(_aBrwAnx[_oBrwAnx:nAt,1] == "", "1", "") , _oBrwAnx:LineRefresh()})  // Adiciona coluna de check-box   
    _oBrwAnx:AddColumn( {STR0049  , { || _aBrwAnx[_oBrwAnx:nAt,2] }    ,"C","@!",1,,,.f.,,,{|| _oBrwAnx:GoColumn(1), _oBrwAnx:DoubleClick() }} ) // Adiciona a coluna Anexo # Anexo
    _oBrwAnx:SetChange({|| Iif( .NOT. Empty( _aBrwAnx), _cAnexos := AllTrim(_aBrwAnx[_oBrwAnx:nAt, 3]), {} ), oGetPth:Refresh()}) // Evento de mudança de linha para atualiza o box com o caminho salvo no array do browse
    _oBrwAnx:Activate()
      
    // ##################################################
Return

/*{Protheus.doc} OGX017CAN
//Função chamada no clique do botão Adicionar.
@author roney.maia
@since 07/09/2017
@version 6
@param oGetPth, object, Objeto referente ao box de arquivo
@type function
*/
Static Function OGX017CAN(oGetPth)

	Local aAux		:= {}
	Local nIt		:= 0
	Local cSysPth	:= Iif( GetRemoteType() == 1, "\", "/") // Verifica qual sistema operacional o smartclient está rodando, 1 - Windows, 2 - Unix.
	Local cSmtp		:= AllTrim( SuperGetMV("MV_RELSERV",.F.,"") )
	Local cBlkExt	:= ".ZIP|.RAR|.GZ|.TGZ|.ADE|.ADP|.BAT|.CHM|.CMD|.COM|.CPL|.EXE|.HTA|.INS|.ISP|.JAR|.JS|.JSE|.LIB|.LNK|.MDE|.MSC|.MSI|.MSP|.MST|.NSH|.PIF|.SCR|.SCT|.SHB|.SYS|.VB|.VBE|.VBS|.VXD|.WSC|.WSF|.WSH|"				
	Local cExt		:= ""
	
	_cAnexos := cGetFile( STR0050, STR0050,,,,nOR(GETF_MULTISELECT/*,GETF_NETWORKDRIVE*/,GETF_LOCALHARD),.f.) // # Selecionar anexos # Selecionar anexos
	
	If .NOT. Empty(_cAnexos) // Se não estiver vazio, adiciona ao browse o anexo selecionado
		aAux := Separa(_cAnexos, "|")
		
		For nIt := 1 To Len(aAux)
		
			Do Case
				Case "gmail" $ cSmtp .OR. "GMAIL" $ cSmtp
					cExt := SubStr(AllTrim(aAux[nIt]), rAt(".", aAux[nIt]), Len(aAux[nIt]))
					If UPPER(cExt) $ UPPER(cBlkExt)
						OGX017MSG(STR0051 + ". (" + cExt + ")" ) // # Extensão de arquivo não permitida para o SMTP configurado
						If .NOT. Empty(_aBrwAnx)
							_cAnexos := AllTrim(_aBrwAnx[1][3]) // Atribui ao box o caminho do primeiro arquivo
							oGetPth:Refresh() // Atualiza o box de arquivo
						Else
							_cAnexos := ""
						EndIf
						Return
					EndIf 
			EndCase
			
			If aScan(_aBrwAnx, {|x| AllTrim(aAux[nIt]) == AllTrim(x[3]) }) == 0 // Se não existe o arquivo no browse, adiciona o mesmo
				aAdd(_aBrwAnx, { "1", AllTrim(SubStr(aAux[nIt], rAt(cSysPth, aAux[nIt]) + 1, Len(aAux[nIt]))), aAux[nIt]})
			EndIf
			
		Next nIt
	
	_oBrwAnx:SetArray(_aBrwAnx) // Seta o array novamente ao browse
	_oBrwAnx:UpdateBrowse() // Reconstroi o browse
	EndIf
	
	If .NOT. Empty(_aBrwAnx)
		_cAnexos := AllTrim(_aBrwAnx[1][3]) // Atribui ao box o caminho do primeiro arquivo
		oGetPth:Refresh() // Atualiza o box de arquivo
	EndIf
		
Return

/*{Protheus.doc} OGX017MSG
//Função para alerta de possíveis menssagens de erro.
@author roney.maia
@since 06/02/2018
@version 1.0
@param cTitulo, characters, titulo da mensagem
@param cMensagem, characters, mensagem de erro
@param cTipo, characters, tipo de mensagem
@param uRet, undefined, retorno
@type function
*/
Static Function OGX017MSG(cTitulo, cMensagem, cTipo, uRet )
   
   Local cMsg := ""
   
   Default cTipo := "INFO"
   Default uRet  := .T.
   
   If !__lExecAuto
      IF cTipo == "INFO" 
         MsgInfo(cMensagem)
      ElseIf cTipo == "ALERT"
         MsgAlert(cTitulo,cMensagem)
      ElseIf cTipo == "YESNO"
         uRet := MsgYesNo( cMensagem )
         Return uRet
      EndIf
   Else
      cMsg := cTipo + "=>[" + cTitulo + ": " + cMensagem + "]"
      CONOUT(cMsg)
      VarInfo("", cMsg)
      IF cTipo == "YESNO"
         Return uRet
      EndIF
   EndIF
Return
/*{Protheus.doc} OGX017WFML
//Função para o envio de e-mail através de workflows..
@author roney.maia
@since 07/02/2018
@version 1.0
@return ${return}, ${mensagem de erro caso ocorrer}
@param cWfProc, characters, Codigo do processo workflow cadastrado no sigacfg
@param cBody, characters, Corpo do e-mail
@param cAssunt, characters, Assunto do e-mail
@param cMailDest, characters, Destinatários do e-mail
@param cPath, characters, Caminho do arquivo de template com o nome do arquivo
@param aAnexos, Array, Array contendo os anexos para o envio
@param aWfRet, Array, Array contendo a rotina, alias, chave, e função de retorno do workflow
@param cAliasBrw, characters, Alias do browse ou query montada.
@type function
*/
Function OGX017WFML( cWfProc, cBody, cAssunt ,cMailDest, cPath, aAnexos, aWfRet, cAliasQry, tSay)

	Local aArea			:= GetArea()
	Local aAreaN8G		:= {}
	Local cMsg			:= ""
	Local cMailID		:= ""
	Local cBarras 		:= If(isSRVunix(),"/","\") // Verifica o sistema operacional e retorna a barra utilizada para o path
	Local cBarrasIn 	:= If(!isSRVunix(),"\","/") // Verifica o sistema operacional e retorna a barra utilizada para o path	
	Local cDirForm		:= ""
	Local cServWF		:= SuperGetMv("MV_AGRWFSV", .F., "")
	Local cFolder		:= SuperGetMv("MV_AGRWFFD", .F., STR0052) // # negociacao
	Local oProcess		:= Nil
	Local cFoldTmMl		:= cBarras + "tempemail" // Pasta para e-mails, *necessario a barra no inicio
   	Local cTime			:= TIME()
	Local cFolderTmp	:= DTOS(DATE()) + SubStr(cTime, 1, 2) + SubStr(cTime, 4, 2) + SubStr(cTime, 7, 2) + RetCodUsr() + "mail" // Cria a pasta com a data hora atual
	Local cDirTemp		:= cFoldTmMl + cBarras + cFolderTmp // Concatena montando o diretorio para salvar os anexos temporarios
	Local nIt			:= 0
	Local nX			:= 0
	Local nBarR			:= 0
	Local lRet			:= .F.
	Local cRet			:= ""
	Local lCompacta		:= .T.
	Local cSleep		:= 5 // Sleep para aguardar processo assincrono de envio e logo apos apagar os anexos temporarios
	Local cField		:= ""
	Local cFldStru		:= ""
	Local aStruct		:= ""	
	
	Default cWfProc 	:= ""
	Default cBody		:= ""
	Default cAssunt 	:= ""
	Default cMailDest 	:= ""
	Default cPath		:= ""
	Default aAnexos		:= {}
	Default cAliasQry	:= ""
	Default tSay		:= Nil
	
	Do Case // Dados obrigatórios
		Case Empty(cWfProc)
			cMsg := STR0053 // # "O Template informado não possui um processo workflow cadastrado."
			RestArea(aArea)
			Return cMsg
		Case Empty(cServWF) // Validação de obrigatoriedade do parametro com o endereco do servidor http para resposta de e-mails.
			cMsg := STR0054 // # "Parâmetro MV_AGRWFSV não contém informado o endereço do servidor http para os formulários de e-mails."
			RestArea(aArea)
			Return cMsg
		Case Empty(cPath)
			cMsg := STR0055 // # "Caminho do formulário de reposta para o e-mail. Não foi localizado no template especificado."
			RestArea(aArea)
			Return cMsg
		Case Empty(aWfRet) .OR. Len(aWfRet) != 5
			cMsg := STR0056 // # "Os dados informados para o retorno do workflow não foram totalmente contemplados."
			RestArea(aArea)
			Return cMsg
	EndCase
	
	oProcess:= TWFProcess():New(cWfProc) // Instancia um novo workflow com base no processo informado.
	
	If !(cBarras $ cPath) // Validação de auxilio, caso receber um caminho no servidor no qual o caminho possa ser diferente devido ao sistema operacional.
		cPath :=  StrTran(cPath, cBarrasIn, cBarras)
	EndIf
	
	nBarR		:= Rat(cBarras, cPath)
	cDirForm 	:= SubStr(cPath, 1, nBarR)
	cFormulario	:= SubStr(cPath, nBarR + 1, Len(cPath))
	
	
	If !ExistDir(cDirForm)
		cMsg := STR0057 // # "Template não localizado no caminho informado."
		RestArea(aArea)
		Return cMsg
	EndIf
		
	If !File(cPath)
		cMsg := STR0058 + " (" + cPath + ")" // # "Template de Formulário não encontrado no servidor"
		RestArea(aArea)
		Return cMsg
	EndIf
	
	//################### Anexos ##################################################
	If !ExistDir(cFoldTmMl) // se não existe a pasta de e-mails temporários, então cria a pasta
		MakeDir(cFoldTmMl) // cria a pasta
	EndIf
	
	If !Empty(aAnexos)  // Codição para copiar arquivos do ambiente smartclient para o ambiente servidor. Necessário para o envio de anexos
		If ValType(tSay) == "O"
	    	tSay:SetText(STR0059) // # "Anexando arquivos."
	    EndIf
		MakeDir(cDirTemp) // Cria o diretorio para a cópia de arquivos
		For nIt := 1 To Len(aAnexos)
			If !CpyT2S(AllTrim(aAnexos[nIt][3]), cDirTemp + cBarras, lCompacta) // Copia os arquivos do smartclient para o server
				cMsg += STR0044 + ": " + aAnexos[nIt][2] + CRLF // # Não foi possível anexar o arquivo
			Else
				aAnexos[nIt][3] := cDirTemp + cBarras +  AllTrim(aAnexos[nIt][2])
			EndIf
		Next nIt
	EndIf
	
	// ################### Formulário #############################################
	
	oProcess:NewTask(cFolder, cPath)
	oProcess:cTo := cFolder
	
	If !Empty(cAliasQry) .AND. ValType(cAliasQry) == "C" .AND. Select(cAliasQry) > 0 // Se o alias foi informado e está aberto
		
		(cAliasQry)->(DbGoTop())
		aStruct := (cAliasQry)->(dBStruct())
		
		For niT := 1 To Len(aStruct) 
			cFldStru += aStruct[nIt][1] + ";"
		Next nIt
		
		For nIt := 1 To Len(oProcess:oHTML:aListValues) // Popula o formulario de resposta com os dados provenientes do Alias do Browser cAliasBrw
			For nX := 1 To Len(oProcess:oHTML:aListValues[nIt])
				cField := oProcess:oHTML:aListValues[nIt][nX][1]
				If(cField $ cFldStru)
					oProcess:oHTML:ValByName(cField, (cAliasQry)->&(cField))
				Else
					oProcess:oHTML:ValByName(cField, "")
				EndIf
			Next nX
		Next nIt

		(cAliasQry)->(DbCloseArea())

	EndIf
	
	oProcess:bReturn :=  "OGX017WFRT()" // Função genérica de retorno dos processos
	
	cMailID := oProcess:Start() // Gera o formulário de reposta com o respectivo ID
	
	// ################### E-MAIL ##################################################
	
	// E-mail enviado com o link para o formulário presente no web server
	oProcess:NewTask("link")
	oProcess:cTo := Lower(AllTrim(cMailDest))
	oProcess:cSubject := cAssunt
	
	// ################## Inclusão de anexos caso existir ##########################
	For nIt := 1 To Len(aAnexos)
	  	lRet := oProcess:AttachFile(AllTrim(aAnexos[nIt][3]))
	  	If !lRet
	     	cMsg += STR0044 + ": " + aAnexos[nIt][2] + CRLF // # Não foi possível anexar o arquivo
	  	EndIf
	Next nIt
	
	If !Empty(cMsg) // Se possui erro ao anexar arquivos
		RestArea(aArea)
		Return cMsg
	EndIf
	
	// ################# Envio do e-mail contendo o link para o formulario #########
	
	oProcess:oHtml:cBuffer := StrTran(cBody, "%proclink%", cServWF +"/messenger/"+"emp"+Alltrim(SM0->M0_CODIGO)+"/" + cFolder + "/"+cMailId + ".htm")
	
	cRet := oProcess:Start() // Envia o e-mail
	
	// Gravação dos dados na tabela de workflow
	If !Empty(cRet)
		aAreaN8G := GetArea()

 		OGX017N8G( , , {FwXFilial("N8G"), cMailID, aWfRet[1], aWfRet[2], aWfRet[3], aWfRet[4], dDataBase, cRet}, "I") // Inclui na tabela de vinculos wf

 		RestArea(aAreaN8G)
    EndIf
    
    If !Empty(aAnexos) // Sleep para o caso de envio de anexos
	    For nIt := 1 To cSleep
	    	Sleep(1000)
	    Next nIt
	EndIf
     	
    OGX017MSG(STR0028, STR0030, "ALERT" )  // # Email enviado com sucesso."#Atencao
	
	If !Empty(cRet) // Se não houve falha no envio de e-mail, deleta os anexos temporarios
     	conout(STR0027)//"SendMail Successful"
     	If .NOT. Empty(aAnexos) .AND. .NOT. Empty(cDirTemp) .AND. cFolderTmp $ cDirTemp .AND. ExistDir(cDirTemp)// Verificações de pasta para remoção apos envio de anexos
     		For nIt := 1 To Len(aAnexos)
     			If File(aAnexos[nIt][3]) .AND. FErase(aAnexos[nIt][3]) < 0
     				conout(STR0045 + ": " + cDirTemp ) // # Falha ao apagar arquivos temporarios
     			EndIf
     		Next nIt
     		DirRemove(cDirTemp) // Remove o diretorio de anexos
     	EndIf   	
    Endif
	
	RestArea(aArea)
	
Return cMsg

/*{Protheus.doc} OGX017WFRT
//Função de retorno do workflow de e-mail.
@author roney.maia
@since 06/02/2018
@version 1.0
@param oProcess, object, Obejto Processo Workflow
@type function
*/
Function OGX017WFRT(oProcess)

	Local aArea		:= GetArea()
	Local lRet 		:= .T.
	Local cFolder	:= SuperGetMv("MV_AGRWFFD", .F., STR0052) // # negociacao
	Local cAliasN8G := ""
	Local nFim		:= 0
	Local bBloco	:= {||}
	Local cWfId		:= ""
	Local cBarras 	:= If(isSRVunix(),"/","\") // Verifica o sistema operacional e retorna a barra utilizada para o path
	Local cForm		:= "" 
	
	Private oProcess := oProcess
	Private aRet	 := {}  // não mudar o nome dessa variavel
	Private cFunc	 := ""
	
	Default oProcess := Nil
	
	If ValType(oProcess) == "O"
	
		cWfId := SubStr(oProcess:oHtml:RetByName("WFMAILID"), 3, Len(oProcess:oHtml:RetByName("WFMAILID"))) // Remove o WF inicial
		cForm := cBarras + "messenger"+ cBarras + "emp" + Alltrim(SM0->M0_CODIGO) + cBarras + cFolder + cBarras + cWfId + ".htm"
		
	    // ###################################### BUSCA DE PROCESSO ##############################################
	    
		cAliasN8G := GetSqlAll("SELECT N8G_CODIGO, N8G_ROTINA, N8G_CALIAS, N8G_CHAVE, N8G_FUNCAO FROM " + RetSqlName("N8G") +;
		 		" N8G WHERE N8G_FILIAL = '" + FwXFilial("N8G") + "' AND D_E_L_E_T_ = '' AND N8G_CODIGO = '" + cWfId + "'")
		
		If !(cAliasN8G)->(Eof())
			aRet := { (cAliasN8G)->N8G_ROTINA, (cAliasN8G)->N8G_CALIAS , (cAliasN8G)->N8G_CHAVE , (cAliasN8G)->N8G_FUNCAO }
		EndIf
		
		(cAliasN8G)->(dbCloseArea())
		
		// ######################################################################################################
		
		If Empty(aRet)
			RestArea(aArea)
			Return lRet			
		Else 
			nFim := Iif(aT("(", aRet[4]) > 0, aT("(", aRet[4]) - 1, Len(AllTrim(aRet[4]))) // Obtem o tamanho do nome da funcao
			cFunc := SubStr(aRet[4], 1, nFim) // Obtem o nome da funcao
			If FindFunction(cFunc) // Localiza e Executa a função preparada gravada na tabela de processos de workflow, como exemplo: OGA290(oProcess, aRet)
				cFunc += "(oProcess, aRet)" // Adiciona os parametros necessarios				
				bBloco := { |oProcess, aRet| &(cFunc) } // Monta o bloco de codigo
				Eval(bBloco, oProcess, aRet) // Executa a função
				
				If File(cForm) .AND. FErase(cForm) < 0
					conout(STR0060 + ": " + cForm) // # "Falha ao apagar formulário workflow de resposta."
				EndIf
				
				oProcess:Finish() // Finaliza o processo

			EndIf
		EndIf	
	EndIf
	
	RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*{Protheus.doc} function
Função de manipulação da tabela de vinculos workflow (e-mail)
@author  roney.maia
@since   13/03/2018
@version version
*/
//-------------------------------------------------------------------
Function OGX017N8G(cChave, nIndice, aDados, cIncUpdDel)

	Local aArea := GetArea()

	Default aDados 		:= {}
	Default cChave 		:= ""
	Default cIncUpdDel 	:= "I"
	Default nIndice 	:= 1

	dbSelectArea("N8G")
	N8G->(dbSetOrder(nIndice))

	Do Case
		Case cIncUpdDel == "I" // Caso Inclusão
			BEGIN TRANSACTION
				If RecLock("N8G", .T.)
					
					N8G->N8G_FILIAL := aDados[1]
					N8G->N8G_CODIGO := aDados[2]
					N8G->N8G_ROTINA := aDados[3] // Rotina que chamou a funcao de e-mail
					N8G->N8G_CALIAS := aDados[4] // Alias da tabela utilizado
					N8G->N8G_CHAVE 	:= aDados[5] // Chave do registro posicionado na tabela utilizada
					N8G->N8G_FUNCAO := aDados[6] // função de retorno do processo workflow
					N8G->N8G_DATAIN := aDados[7] // Data de inicialização do workflow
					N8G->N8G_PRCRET := aDados[8]
					N8G->(MsUnlock())
				EndIf
 			END TRANSACTION

		Case cIncUpdDel == "U" // Caso Alteração

		Case cIncUpdDel == "D" // Caso Delete
			If N8G->(dbSeek(xFilial("N8G")+cChave)) // pociciona a chave
				BEGIN TRANSACTION
					If RecLock("N8G", .F.)		 		
						dbDelete() //deleta o vinculo		
						MsUnlock()
					EndIf
				END TRANSACTION
			EndIf
	EndCase

	N8G->(dbCloseArea())

	RestArea(aArea)
Return

Function OGX017SETP(cProces)                                        
 
 __cProcess := cProces

Return

/*/{Protheus.doc} ValidMrk
Exibe markbrowse. Consulta especifica SU5CS1
@author gustavo.pereira
@since 09/02/2019
/*/
Function OGX017CTC()

	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local lRet      := .T.
	Local aCampos 	:= {'U5_CODCONT', 'U5_CONTAT'}
	Local nOpcA     := 0
	Local oBrwMrk 	:= Nil
	Local cContat   := ""


	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3] *0.8, oSize:aWindSize[4]*0.8,;
	STR0020 , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 10, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )

	oFWLayer:AddLine( 'DOWN', 90, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'DOWN' )
	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"),;
			 ,oDlg, , , , , ,oSize:GetDimension("ALL","COLEND")/1.26, oSize:GetDimension("ALL","LINEND")/1.5)

	cContat := sFCposCont()

	cFiltro := "SU5->U5_FILIAL = '" + FwXFilial("SU5") + "' .AND. SU5->U5_CODCONT $ '" + cContat +"'"

	oBrwMrk := FWMarkBrowse():New()   // Cria o objeto oMark - MarkBrowse
	oBrwMrk:SetDescription(STR0065) // "Tipos de Classificação Comercial" 
	oBrwMrk:SetFilterDefault(cFiltro)
	oBrwMrk:SetAlias("SU5") 
	oBrwMrk:SetFieldMark("U5_ATIVO")	// Define o campo utilizado para a marcacao 
	oBrwMrk:SetOnlyFields(aCampos)			
	oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	oBrwMrk:SetMenuDef("")	// Desabilita a opcao de imprimir
	oBrwMrk:Activate(oPnDown)	// Ativa oADMI MarkBrowse
	//MarkItens(oBrwMrk, __cRet)
	
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| SelContatos( oBrwMrk ), oDlg:End(), NIL},{|| nOpcA:= 0, oDlg:End() },,/* @aButtons */) } )
	
	RestArea(aArea)

Return lRet

/*/{Protheus.doc} SelContatos
//Realiza o preenchimento do campo de e-mail conforme preenchimento
//na consulta especifica SU5ES1
@author gustavo.pereira
@since 09/02/2019
@version undefined
@param oBrwMrk
@type function
/*/
Static Function SelContatos(oBrwMrk)
	Local lRet 			:= .T.
	Local aArea			:= GetArea()
    Local cEmails	:= ""
    
	SU5->(dbGoTop())
	While .Not. SU5->(Eof())
		If oBrwMrk:IsMark()		
			If(!Empty(Alltrim(SU5->U5_EMAIL)))
				cEmails += Alltrim(SU5->U5_EMAIL) + "; " 
			Endif
		EndIf
		SU5->(dbSkip())
	EndDo	

	__oViewAct:GetModel():GetModel("MODEL_FLD"):SetValue("FLDMAILS", cEmails) 
	
	RestArea(aArea)
	oBrwMrk:Refresh()
	oBrwMrk:GoTop()
Return lRet

/*{Protheus.doc} sFCposCons
Funcao cria consulta 
Função da consulta especifica - Contatos

@author 	gustavo.pereira
@since 		11/02/2018
*/
Static Function sFCposCont()

	Local aArea		:= GetArea() // Area ativa	
	Local cAliasN79 := GetNextAlias()
	Local cAliasAC8 := GetNextAlias()
	Local cContatos := ""

	If Empty(Alltrim(_aWfRet[5][1]))

		//Pego a entidade para buscar os contatos do cliente
		BeginSql Alias cAliasN79
			SELECT  A1_COD CODIGO, A1_LOJA LOJA
				FROM %Table:N79% N79
				INNER JOIN %Table:NJ0% NJ0 ON NJ0.NJ0_CODENT = N79.N79_CODENT
									AND NJ0.NJ0_LOJENT    = N79.N79_LOJENT
									AND NJ0.NJ0_FILIAL    = %xfilial:NJ0%
									AND NJ0.%notDel%
				INNER JOIN %Table:SA1% SA1  ON SA1.A1_COD  = NJ0.NJ0_CODCLI
									AND SA1.A1_LOJA     = NJ0.NJ0_LOJCLI
									AND SA1.A1_FILIAL   = %xfilial:SA1%
									AND SA1.%notDel%									  		
			WHERE N79_CODNGC = %exp:_aWfRet[5][3]%

		EndSQL
	Else
		//Pego a entidade para buscar os contatos do cliente
		BeginSql Alias cAliasN79
			SELECT A2_COD CODIGO, A2_LOJA LOJA
				FROM %Table:N79% N79				
				INNER JOIN %Table:SA2% SA2  ON SA2.A2_COD  = N79.N79_CODCOR
									AND SA2.A2_LOJA        = N79.N79_LOJCOR
									AND SA2.A2_FILIAL      = %xfilial:SA2%
									AND SA2.%notDel%									  		
			WHERE N79_CODNGC = %exp:_aWfRet[5][3]%

		EndSQL
	Endif	

	DbselectArea( cAliasN79 )
	DbGoTop()
			
	If (cAliasN79)->(!Eof())
		
		cCodEnt    := (cAliasN79)->CODIGO 			
		cEntidade  := Iif(Empty(Alltrim(_aWfRet[5][1])),'SA1','SA2' )		

		//Busco os contatos do Cliente (SA1)
		BeginSql Alias cAliasAC8
			SELECT AC8_CODCON
			FROM %Table:AC8% AC8
			WHERE AC8_FILIAL = %xfilial:AC8%
				AND SUBSTR(AC8_CODENT,1,9) = %exp:cCodEnt%
				AND AC8_ENTIDA = %exp:cEntidade% 
				AND AC8.%notDel%
		EndSQL

		If (cAliasAC8)->(!Eof())

			While !(cAliasAC8)->(EOF()) 
	
				dbSelectArea("SU5")
				dbSetOrder(1)

				//verifica se o contato está inativo
				If dbSeek(FwxFilial("SU5") + (cAliasAC8)->AC8_CODCON)
					cContatos += Alltrim(SU5->U5_CODCONT) + '|'							
				EndIf	

				(cAliasAC8)->(DbSkip())				
			EndDo
		Endif
		
	EndIf 
	(cAliasN79)->(dbCloseArea())
	(cAliasAC8)->(dbCloseArea())
	RestArea(aArea)

Return cContatos

/*{Protheus.doc} OGX017ASST
Função responsável por carregar o campo Assunto. 
@author 	marcos.wagner
@since 		25/02/2019
*/
/*/{Protheus.doc} OGX017ASST
//Função responsável por carregar o campo Assunto.
@author marcos.wagner
@since 25/02/2019
@param lRecarrega - Indica se irá recarregar o campo
@type function
/*/
Static Function OGX017ASST(lRecarrega, cAliasQry)
	Local oModel    := FwModelActive()
	Local oModelFld
	Local oMldView

	__oViewAct := FwViewActive() // Obtém a view ativa devido a recursividade de views

	If __lWorkFl // Para o inicializador padrão caso for workflow
		aAreaN7L := GetArea()
		dbSelectArea("N7L")
		N7L->(dBGoTop())

		If ValType(oModel) == "O"
			oModelFld  := oModel:GetModel('MODEL_FLD')
            If ValType(oModelFld) == "O"
			    _cTemplate := oModelFld:GetValue("FLDTMPLT")
            EndIf
		EndIf

		_cDescri := AllTrim(Posicione("N7L",1,xFilial("N7L")+_cTemplate+__cProcess,"N7L_DESCRI"))
		_cAssunt := AllTrim(Posicione("N7L",1,xFilial("N7L")+_cTemplate+__cProcess,"N7L_ASSUNT"))
		
		N7L->(dbCloseArea())
		RestArea(aAreaN7L)
	EndIf

	If lRecarrega
		(cAliasQry)->(dBGoTop())
		_cAssunt := OGX017HTML(cAliasQry, _cAssunt)
	EndIf

	If ValType(__oViewAct) == "O"
		oMldView := __oViewAct:GetModel():GetModel("MODEL_FLD")
		If  ValType(oMldView) == "O"
			oMldView:SetValue("FLDASSUNT", _cAssunt)
			__oViewAct:Refresh()
		Endif
	EndIf
Return

/*/{Protheus.doc} fTrataErro
    Função para tratar erro na execução da query.
    @type  Static Function
    @author user
    @since 23/06/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function fTrataErro(e)
    
    If !Empty(e)        
        AutoGrLog(STR0069 + chr(10) + chr(10)) //"Ocorreu um erro na consulta dos dados. A consulta é elaborada conforme as tabelas e relacionamentos indicados no cadastro de Processo de E-mail."
        AutoGrLog(STR0070 + alltrim(__cProcess) + chr(10) + chr(10)) //"Por favor, verifique as informações no cadastro OGA550 - Processo de E-mail. O processo deve estar vinculado ao template de e-mail (OGA540) que deseja utilizar. Código do processo: "
        AutoGrLog(STR0071 +chr(10) + e:Description) //"Informação técnica do erro: "
        MostraErro()
        Return .T.
    EndIf

Return .F.
