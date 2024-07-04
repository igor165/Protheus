#Include 'PROTHEUS.ch' //include protheus
#Include 'FWMVCDEF.CH' //include mvc
#Include 'PCPA101.CH'  //include de tradução

//-----------------------------------------------------------------
/*/{Protheus.doc} PCPA101
Tela de Cadastro de Atributos para Ficha Técnica

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-----------------------------------------------------------------
Function PCPA101()
    Local oBrowse
	Default lAutoMacao := .F.

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('CZB')
	oBrowse:SetMenuDef('PCPA101')
    oBrowse:SetDescription(STR0017) //Atributos Ficha Técnica

	IF !lAutoMacao
    	oBrowse:Activate()
	ENDIF
Return nil

Static Function ModelDef()
    Local oStructCZB := FWFormStruct(1,'CZB')  //Atributo
    Local oStructCZC := FWFormStruct(1,'CZC')  //Valores para Lista
    Local oModel
	Local bPre := {|oFieldModel, cAction, cIDField, xValue| prevalCZB(oFieldModel, cAction, cIDField, xValue)}
   
    oModel := MPFormModel():New('PCPA101',,{|oModel| PCPA101POS(oModel)} /*bPos*/)

    oModel:addFields('CZBMASTER',/*cOwner*/,oStructCZB,bPre,/*bPos*/,/*bLoad*/)
    oModel:AddGrid( 'CZCDETAIL', 'CZBMASTER', oStructCZC)

    oModel:SetRelation( 'CZCDETAIL', { { 'CZC_FILIAL', 'xFilial( "CZC" )' }, { 'CZC_CDAB', 'CZB_CDAB' } }, CZC->( IndexKey(1)) )

    oModel:GetModel( 'CZCDETAIL' ):SetOptional( .T. )

    oModel:SetVldActivate( { |oModel| PCPA101ACT( oModel ) } )

    oModel:SetDescription(STR0015) //Cadastro de Atributos
    oModel:GetModel('CZBMASTER'):SetDescription(STR0016) //Dados do Atributo
Return oModel

/*/{Protheus.doc} prevalCZB
	pré validação do modelo czbmaster
	@type  Static Function
	@author mauricio.joao
	@since 17/04/2020
	@version 1.0

	/*/
Static Function prevalCZB(oFieldModel, cAction, cIDField, xValue)
Local lPreValida := .T.

Do Case
	Case cAction == "SETVALUE" .AND. cIDField $ "CZB_TPAB" 
		//Se o tipo de atributo estiver vaziu ou NAO for L R T (lista formula ou tabela) bloqueia o campo valor padrão.
		If !(xValue $ ("L|R|T"))
			//limpa os campos se preenchidos 
			oFieldModel:ClearField("CZB_VLPAAB")
			oFieldModel:ClearField("CZB_IDCDG")
			oFieldModel:ClearField("CZB_IDDS")
		EndIf
	Case cAction == "CANSETVALUE" .AND. cIDField $ "CZB_VLPAAB" 
		//Se o tipo de atributo estiver vaziu ou NAO for L R T (lista formula ou tabela) bloqueia o campo valor padrão.
		If Empty(oFieldModel:GetValue("CZB_TPAB")) .OR. !(oFieldModel:GetValue("CZB_TPAB") $ ("L|R|T"))
			lPreValida := .F.
		EndIf	
	Case cAction == "CANSETVALUE" .AND. cIDField $ "CZB_IDCDG|CZB_IDDS"
		//Se o tipo de atributo estiver vaziu ou NAO for  T ( tabela) bloqueia o campo codigo e descricao.	
		If Empty(oFieldModel:GetValue("CZB_VLPAAB")) .OR. !(oFieldModel:GetValue("CZB_TPAB") $ ("T"))
			lPreValida := .F.
		EndIf	
EndCase

Return lPreValida

Static Function ViewDef()
    Local oModel 		:= FWLoadModel('PCPA101')
    Local oStructCZB 	:= FWFormStruct(2,'CZB')
    Local oStructCZC 	:= FWFormStruct(2,'CZC')

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_CZB',oStructCZB,'CZBMASTER')
    oView:AddGrid('VIEW_CZC',oStructCZC,'CZCDETAIL')

    oView:CreateHorizontalBox('TELA1',100)
    oView:CreateHorizontalBox('TELA2',0)
    oView:SetOwnerView('VIEW_CZB','TELA1')
    oView:SetOwnerView('VIEW_CZC','TELA2')

	oStructCZB:AddGroup( 'GRUPO01', STR0001, '', 2 ) //Exibição
	oStructCZB:AddGroup( 'GRUPO02', STR0002, '', 2 ) //Tipo de Dados
	oStructCZB:AddGroup( 'GRUPO03', STR0003, '', 2 ) //'Valores'
	oStructCZB:AddGroup( 'GRUPO04', STR0004, '', 2 ) //'Valores - Faixa'
	oStructCZB:AddGroup( 'GRUPO05', STR0005, '', 2 ) //'Valores - Tabela'
	oStructCZB:AddGroup( 'GRUPO06', STR0006, '', 2 ) //'Outras Informações'

	oStructCZB:SetProperty( '*' , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

	oStructCZB:SetProperty( 'CZB_TPAB'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStructCZB:SetProperty( 'CZB_TMAB'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStructCZB:SetProperty( 'CZB_VLPRC' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStructCZB:SetProperty( 'CZB_UNMD'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStructCZB:SetProperty( 'CZB_RLAB'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStructCZB:SetProperty( 'CZB_TPTB'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

    oStructCZB:SetProperty( 'CZB_VLPAAB', MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

    oStructCZB:SetProperty( 'CZB_VLBGFX', MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
    oStructCZB:SetProperty( 'CZB_VLEDFX', MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )

    oStructCZB:SetProperty( 'CZB_IDCDG' , MVC_VIEW_GROUP_NUMBER, 'GRUPO05' )
    oStructCZB:SetProperty( 'CZB_IDDS' 	 , MVC_VIEW_GROUP_NUMBER, 'GRUPO05' )

    oStructCZB:SetProperty( 'CZB_NVAB' 	 , MVC_VIEW_GROUP_NUMBER, 'GRUPO06' )

    oStructCZB:SetProperty('CZB_VLPAAB',  MVC_VIEW_PICT, "@!")

    oView:AddUserButton( STR0007, 'PCPA101', { |oModel| PCPA101TLI(oModel) } )  // 'Lista de Valores'
    
Return oView

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0008 ACTION 'PesqBrw'          OPERATION 1 ACCESS 0    // 'Pesquisar'
	ADD OPTION aRotina TITLE STR0009 ACTION 'VIEWDEF.PCPA101' OPERATION 2 ACCESS 0    // 'Visualizar'
	ADD OPTION aRotina TITLE STR0010 ACTION 'VIEWDEF.PCPA101' OPERATION 3 ACCESS 0    // 'Incluir'
	ADD OPTION aRotina TITLE STR0011 ACTION 'VIEWDEF.PCPA101' OPERATION 4 ACCESS 0    // 'Alterar'
	ADD OPTION aRotina TITLE STR0012 ACTION 'VIEWDEF.PCPA101' OPERATION 5 ACCESS 0    // 'Excluir'
	ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.PCPA101' OPERATION 8 ACCESS 0    // 'Imprimir'
	ADD OPTION aRotina TITLE STR0014 ACTION 'VIEWDEF.PCPA101' OPERATION 9 ACCESS 0    // 'Copiar'

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101GTP
Gatilho para campo do tipo de atributo

@param
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101GTP()
   Local lRet
   Local oModel   		:= FWModelActive()
   Local oModelCZB 	:= oModel:GetModel( 'CZBMASTER' )
   Local oModelCZC   := oModel:GetModel( 'CZCDETAIL' )
   Local nI
   Local cFormula := Nil

   If oModelCZB:GetValue('CZB_TPAB') == 'D' //Data
      oModelCZB:LoadValue('CZB_TMAB',10)
      oModelCZB:LoadValue('CZB_VLPRC',0)
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)
   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'I' //Imagem
      oModelCZB:LoadValue('CZB_TMAB',20)
      oModelCZB:LoadValue('CZB_VLPRC',0)
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)
   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'F' //Flag
      oModelCZB:LoadValue('CZB_TMAB',1)
      oModelCZB:LoadValue('CZB_VLPRC',0)
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)
   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'A' //Faixa
      oModelCZB:LoadValue('CZB_TMAB',13)
      oModelCZB:LoadValue('CZB_VLPRC',4)
   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'L' //Lista
      oModelCZB:LoadValue('CZB_TMAB',20)
      oModelCZB:LoadValue('CZB_VLPRC',0)
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)
      oModelCZB:LoadValue('CZB_TPTB','1')
      lRet := PCPA101TLI(oModel)
   Else
   	  //aDadosCZC := {}
   	  For nI := 1 to oModelCZC:GetQtdLine()
   	  	 oModelCZC:GoLine(nI)
   	  	 oModelCZC:DeleteLine()
   	  Next
   	  oModelCZB:LoadValue('CZB_TPTB','')
   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'M' //Memo
      oModelCZB:LoadValue('CZB_TMAB',0)
      oModelCZB:LoadValue('CZB_VLPRC',0)
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)

   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'R' //Fórmula
      oModelCZB:LoadValue('CZB_VLPRC',0)
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)
      oModelCZB:LoadValue('CZB_TMAB',254)
      cFormula := PCPA101VLF(@oModelCZB)
   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'C' //Char
      oModelCZB:LoadValue('CZB_VLPRC',0)
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)
   Endif
   If oModelCZB:GetValue('CZB_TPAB') == 'N' .OR. oModelCZB:GetValue('CZB_TPAB') == 'O' //Numérico ou Tolerância
      oModelCZB:LoadValue('CZB_VLBGFX',0)
      oModelCZB:LoadValue('CZB_VLEDFX',0)
      If oModelCZB:GetValue('CZB_TMAB') > 13
      	 oModelCZB:LoadValue('CZB_TMAB',13)
      Endif
   Endif
   oModelCZB:LoadValue('CZB_VLPAAB',Space(TamSX3('CZB_VLPAAB')[1]))
   If cFormula != Nil .AND. oModelCZB:GetValue('CZB_TPAB') == 'R'
      oModelCZB:SetValue('CZB_VLPAAB',cFormula)
   EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101WCA
Modo exibição para campos Tamanho, Precisão e Unidade de Medida (indica
quando os mesmos poderão ser modificados).

@param
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101WCA(nTipo)
   Local oModel   := FWModelActive()

   Local oModelCZB := oModel:GetModel( 'CZBMASTER' )

   If nTipo == 1 //Validação Tamanho
   		If 	oModelCZB:GetValue('CZB_TPAB') == 'N' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'C' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'O'
			Return .T.
		Endif
   Endif
   If nTipo == 2 //Validação Precisão
		If 	oModelCZB:GetValue('CZB_TPAB') == 'N' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'O'
			Return .T.
		Endif
   Endif
   If nTipo == 3 //Validação Unidade de Medida
		If 	oModelCZB:GetValue('CZB_TPAB') == 'N' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'R' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'A'
			Return .T.
		Endif
   Endif
   If nTipo == 4 //Faixa de valores
   		If 	oModelCZB:GetValue('CZB_TPAB') == 'A'
			Return .T.
		Endif
   Endif
   If nTipo == 5 //Codigo e descricao de tabela
   		If 	oModelCZB:GetValue('CZB_TPAB') == 'T'
			Return .T.
		Endif
   Endif
   If nTipo == 6 //Valor padrão
   		If 	oModelCZB:GetValue('CZB_TPAB') == 'N' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'C' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'A' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'T' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'F' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'D' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'L' .Or. ;
			oModelCZB:GetValue('CZB_TPAB') == 'R'
			Return .T.
		Endif
   Endif
   If nTipo == 7 //Tipo Lista
   		If oModelCZB:GetValue('CZB_TPAB') == 'L'
   			Return .T.
   		Endif
   Endif
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101VLC
Validação dos campos de tela

@param 		nTipo		Identifica campo que está sendo validado
						1 - Nome Atributo
						2 - Tamanho Atributo
						3 - Precisão Atributo
						4 - Faixa de valores

@return 	lRet		Identifica se validação foi bem sucedida ou não

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101VLC(nTipo)
   Local oModel    := FWModelActive()
   Local oModelCZB := oModel:GetModel( 'CZBMASTER' )
   Local cCampo    := Space(10)
   Local nI        := 0
   Local lFlag     := .F.
   Local lHasFicha := .F.
      
   lHasFicha := PCPA101HASFC()

   If nTipo == 1 //Valida Nome Atributo
   		DbSelectArea("CZB")
   		CZB->(DbSetOrder(2))
   		CZB->(DbGoTop())
   		If CZB->(dbSeek(xFilial("CZB")+oModelCZB:GetValue('CZB_NMAB')))
   			PCPA101Msg(STR0018,"PCPA101",1) //"Nome de atributo já cadastrado."
   			Return .F.
   		Endif
   		If "/" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "*" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "-" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "+" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "^" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "(" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   ")" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "=" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "." $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "," $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "'" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "!" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "@" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "#" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "$" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "%" $ oModelCZB:GetValue('CZB_NMAB') .OR. ;
   		   "&" $ oModelCZB:GetValue('CZB_NMAB')
   			PCPA101Msg(STR0063,"PCPA101",1) //"Nome de atributo inválido, não permitido usar caracteres especiais."
   			Return .F.
   		EndIf
   		lFlag := .F.
   		For nI := 1 To Len(oModelCZB:GetValue('CZB_NMAB'))
   			If ISALPHA(SubStr(oModelCZB:GetValue('CZB_NMAB'),nI))
   				lFlag := .T.
   				Exit
   			EndIf
   		Next
   		If !lFlag
   			PCPA101Msg(STR0072,"PCPA101",1) //"Nome de atributo inválido, necessário utilizar ao menos uma letra."
   			Return .F.
   		EndIf
   Endif

   If nTipo == 2 //Valida Tamanho do Atributo
   		If oModel:getOperation() == 4 .AND. lHasFicha .AND. CZB->CZB_TMAB > oModelCZB:GetValue('CZB_TMAB')
   				PCPA101Msg(STR0096,"PCPA101",1)
   				Return .F.
   		EndIf
   		If oModelCZB:GetValue('CZB_TMAB') < 0
   			PCPA101Msg(STR0019,"PCPA101",1) //"Tamanho deve ser maior que 0."
   			Return .F.
   		Endif
		If (oModelCZB:GetValue('CZB_TPAB') == 'N' .Or.;
			oModelCZB:GetValue('CZB_TPAB') == 'O') .And. oModelCZB:GetValue('CZB_TMAB') > 13
   			If oModelCZB:GetValue('CZB_TPAB') == 'N'
   				PCPA101Msg(STR0020,"PCPA101",1) //"Tamanho deve ser menor ou igual a 13 para atributos numéricos."
   			Else
   				PCPA101Msg(STR0060,"PCPA101",1) //"Tamanho deve ser menor ou igual a 13 para atributos do tipo tolerância."
   			EndIf
   			Return .F.
   		Endif
   		If (oModelCZB:GetValue('CZB_TPAB') == 'N' .Or.;
			oModelCZB:GetValue('CZB_TPAB') == 'O') .And. oModelCZB:GetValue('CZB_TMAB') == 0
			If oModelCZB:GetValue('CZB_TPAB') == 'N'
   				PCPA101Msg(STR0021,"PCPA101",1) //"Tamanho deve ser maior que 0 para atributos numéricos."
   			Else
   				PCPA101Msg(STR0061,"PCPA101",1) //"Tamanho deve ser maior que 0 para atributos do tipo tolerância."
   			EndIf
   			Return .F.
   		Endif
   		If oModelCZB:GetValue('CZB_TPAB') == 'R' .And. oModelCZB:GetValue('CZB_TMAB') > 254
   			PCPA101Msg(STR0022,"PCPA101",1) //"Tamanho deve ser menor ou igual a 254 para atributos do tipo fórmula."
   			Return .F.
   		Endif
   		If oModelCZB:GetValue('CZB_TPAB') == 'R' .And. oModelCZB:GetValue('CZB_TMAB') == 0
   			PCPA101Msg(STR0023,"PCPA101",1) //"Tamanho deve ser maior que 0 para atributos do tipo fórmula."
   			Return .F.
   		Endif
   		If oModelCZB:GetValue('CZB_TPAB') == 'C' .And. oModelCZB:GetValue('CZB_TMAB') > 254
   			PCPA101Msg(STR0024,"PCPA101",1) //"Tamanho deve ser menor ou igual a 254 para atributos do tipo caracter."
   			Return .F.
   		Endif
   		If oModelCZB:GetValue('CZB_TPAB') == 'C' .And. oModelCZB:GetValue('CZB_TMAB') == 0
   			PCPA101Msg(STR0025,"PCPA101",1) //"Tamanho deve ser maior que 0 para atributos do tipo caracter."
   			Return .F.
   		Endif   		
   Endif

   If nTipo == 3 //Valida Precisao do Atributo
   		If oModel:getOperation() == 4 .AND. lHasFicha .AND. CZB->CZB_VLPRC > oModelCZB:GetValue('CZB_VLPRC')
   			PCPA101Msg(STR0097,"PCPA101",1)
   			Return .F.
   		EndIf
   		If oModelCZB:GetValue('CZB_VLPRC') < 0
   			PCPA101Msg(STR0026,"PCPA101",1) //"Precisão deve ser maior que 0."
   			Return .F.
   		Endif
   		If (oModelCZB:GetValue('CZB_TPAB') == 'N' .Or.;
			oModelCZB:GetValue('CZB_TPAB') == 'O') .And. oModelCZB:GetValue('CZB_VLPRC') > 4
   			If oModelCZB:GetValue('CZB_TPAB') == 'N'
   				PCPA101Msg(STR0027,"PCPA101",1) //"Precisão deve ser menor ou igual a 4 para atributos numéricos."
   			Else
   				PCPA101Msg(STR0062,"PCPA101",1) //"Precisão deve ser menor ou igual a 4 para atributos do tipo tolerância."
   			EndIf
   			Return .F.
   		Endif
   Endif

   If nTipo == 4 //Valida faixa de valores
   		If !Empty(oModelCZB:GetValue('CZB_VLBGFX')) .And. !Empty(oModelCZB:GetValue('CZB_VLEDFX'))
	   		If oModelCZB:GetValue('CZB_VLBGFX') >= oModelCZB:GetValue('CZB_VLEDFX')
	   			PCPA101Msg(STR0028,"PCPA101",1) //"Valor inicial da faixa deve ser menor que valor final."
	   			Return .F.
	   		Endif
	   	Endif
   Endif

   If nTipo == 5 //Valida codigo
	    cCampo := PADR(ALLTRIM(oModelCZB:GetValue('CZB_IDCDG')),10)

	    If !Empty(cCampo)	    	
		    lRet := (GetSx3Cache(cCampo, 'X3_ARQUIVO') == AllTrim(oModelCZB:GetValue('CZB_VLPAAB')))
	   		If !lRet
	   			PCPA101Msg(STR0029,"PCPA101",1) //"Campo 'Código' não existente para tabela informada."
		   		Return .F.
	   		Endif
	    Endif
   Endif

   If nTipo == 6 //Valida descricao
   		cCampo := PADR(ALLTRIM(oModelCZB:GetValue('CZB_IDDS')),10)

   		If !Empty(cCampo)  		
		    lRet := (GetSx3Cache(cCampo, 'X3_ARQUIVO') == AllTrim(oModelCZB:GetValue('CZB_VLPAAB')))
	   		If !lRet
	   			PCPA101Msg(STR0030,"PCPA101",1) //"Campo 'Descrição' não existente para tabela informada."
		   		Return .F.
		   	Endif
		Endif
   Endif
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101GVP
Abertura de tela para escolha de valor padrão quando tipo de atributo
for do tipo L-Lista, R-Formula ou T-Tabela.

@param

@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101GVP()
   Local lRet
   Local oModel     := FWModelActive()
   Local oModelCZB  := oModel:GetModel( 'CZBMASTER' )
   Local cFormula   := ""
   Private cVALPAD  := oModelCZB:GetValue('CZB_VLPAAB')

	If !(oModelCZB:GetValue('CZB_TPAB') $ "LTR")
		PCPA101Msg(STR0031,"PCPA101",1) //"Permitido somente para atributos do tipo 'Lista', 'Fórmula' e 'Tabela'."
		oModelCZB:SetValue('CZB_VLPAAB',cVALPAD)
		Return .T.
	Endif

	Do Case
		Case oModelCZB:GetValue('CZB_TPAB') $ "L"
			lRet:=PCPA101VLL()
			oModelCZB:SetValue('CZB_VLPAAB',cVALPAD)
		Case oModelCZB:GetValue('CZB_TPAB') $ "R"
			cFormula := PCPA101VLF(@oModelCZB)
			oModelCZB:SetValue('CZB_VLPAAB',cFormula)
		Case oModelCZB:GetValue('CZB_TPAB') $ "T"
			If ConPad1(,,,"SX2PAD")
				If FindFunction("FwX2Chave")
					oModelCZB:SetValue('CZB_VLPAAB',FwX2Chave())
				EndIf
			EndIf
	EndCase
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101TLI
Abertura de tela para escolha do valor padrão para atributo tipo
L-Lista.

@param 		oModel		Modelo de dados para tratamento das informações da tela

@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101TLI(oModel)
	Local oModelCZB := oModel:GetModel( 'CZBMASTER' )
	Local oModelCZC := oModel:GetModel( 'CZCDETAIL' )
	Local nX := 0
	Local nUsadCZC 	:= 0
	Local nOpcX	 	:= IIf(oModel:GetOperation() == 1 .Or. oModel:GetOperation() == 2,0,GD_INSERT+GD_UPDATE+GD_DELETE)
	Local cLinhaOk    	:= "PCPA101VLI()"  						// Funcao executada para validar o contexto da linha atual do aCols (Localizada no Fonte GS1008)
	Local cTudoOk     	:= "AllwaysTrue"							// Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
	Local cIniCpos    	:= "+CZC_SQTB"               			  	// Nome dos campos do tipo caracter que utilizarao incremento automatico.
	Local nFreeze     	:= 000              						// Campos estaticos na GetDados.
	Local nMax        	:= 999              						// Numero maximo de linhas permitidas.
	Local aAlter			:= {"CZC_VLTB","CZC_NMTB"}              	// Campos a serem alterados pelo usuario
	Local cFieldOk    	:= "PCPA101CZG"                        // Funcao executada na validacao do campo
	Local cSuperDel		:= "AllwaysTrue"          			  	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
	Local cDelOk  		:= "AllwaysTrue"    					 	// Funcao executada para validar a exclusao de uma linha do aCols
	Local aItens         := {STR0094,STR0095}
	Local cValid
	Local lTemDados, lHasFicha
	Local oComboBox
    Local lWhen 
    Local cItemBkp
    Local nCount
	Private cItem
	Private oDlg1
	Private oCZGBrw

	Default lAutoMacao := .F.
	
	lHasFicha := PCPA101HASFC()
	
        lWhen := Iif(lHasFicha .And. !INCLUI, .F., .T.)
        If oModel:GetOperation() == 1
           lWhen := .F.
        EndIf
	If !INCLUI
		cDelOk    := "PCPA101CZG()"
		cSuperDel := "PCPA101CZG()"
	EndIf

	If oModelCZB:GetValue('CZB_TPAB') != "L"
		PCPA101Msg(STR0032,"PCPA101",1) //"Permitido somente para atributos do tipo 'Lista'."
		Return
	Endif

	aCols		:= {}
	aHeaders 	:= {}

	aStruCZC := CZC->(DBStruct())
	For nCount := 1 To Len(aStruCZC)
		If X3USO(GetSx3Cache(aStruCZC[nCount,1],'X3_USADO')) .And. ;
			((AllTrim(aStruCZC[nCount,1]) == "CZC_SQTB") .Or. (AllTrim(aStruCZC[nCount,1]) == "CZC_VLTB") .Or. (AllTrim(aStruCZC[nCount,1]) == "CZC_NMTB")) 
		
			If (AllTrim(aStruCZC[nCount,1]) == "CZC_VLTB")
				cValid := "PCPA101VLT()"
			Else
				cValid := "AllwaysTrue()"
			EndIf

			aAdd(aHeaders,{ TRIM(GetSx3Cache(aStruCZC[nCount,1],'X3_TITULO')), aStruCZC[nCount,1], "@!",GetSx3Cache(aStruCZC[nCount,1],'X3_TAMANHO'),;
							GetSx3Cache(aStruCZC[nCount,1],'X3_DECIMAL'),cValid,GetSx3Cache(aStruCZC[nCount,1],'X3_USADO'), GetSx3Cache(aStruCZC[nCount,1],'X3_TIPO'), /*SX3->x3_arquivo*/, GetSx3Cache(aStruCZC[nCount,1],'X3_CONTEXT')} )
		Endif	
	Next nCount	
	
	nUsadCZC := Len(aHeaders)
	aAdd (aCols, Array (nUsadCZC+1))
	lTemDados := .F.
	For nX := 1 to oModelCZC:GetQtdLine()
		If !oModelCZC:IsDeleted() .AND. !empty(oModelCZC:GetValue('CZC_SQTB'))
			lTemDados := .T.
			Exit
		EndIf
	Next
	If !lTemDados
		aCols[Len (aCols)][1] := "00001"
		For nX := 2 To nUsadCZC
			aCols[Len (aCols)][nX] := CriaVar (aHeaders[nX][2], .T.)
		Next nX
		aCols[Len (aCols)][nUsadCZC+1] := .F.
	Else
		aCols := { }
		For nX := 1 To oModelCZC:GetQtdLine()
			oModelCZC:GoLine(nX)
			If !oModelCZC:IsDeleted() .And. !empty(oModelCZC:GetValue('CZC_SQTB'))
				aAdd(aCols, {oModelCZC:GetValue('CZC_SQTB'), oModelCZC:GetValue('CZC_NMTB'),;
							  oModelCZC:GetValue('CZC_VLTB'),.F.})
			EndIf
		Next
	Endif

	If oModelCZB:GetValue('CZB_TPTB') == "1"
		cItem := aItens[1]
	Else
		cItem := aItens[2]
	EndIf
  
        cItemBkp := cItem

	IF !lAutoMacao
		oDlg1 	:= MSDialog():New( 091,232,282,650,STR0032,,,.F.,,,,,,.T.,,,.T. ) //"Lista de Valores"
		oCZGBrw	:= 	MsNewGetDados():New(008,008,072,200,nOpcX,;
										cLinhaOk ,cTudoOk,cIniCpos,aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oDlg1,aHeaders,aCols)
		
		@ 081,010 SAY STR0093 SIZE 035,010 OF oDlg1 PIXEL //"Tipo lista:"
		@ 079,035 COMBOBOX oComboBox VAR cItem ITEMS aItens WHEN lWhen SIZE 40,10 VALID validCbox(@oModelCZB) PIXEL OF oDlg1

		oBtn1 	:= TButton():New( 078,122,STR0033,oDlg1,{ || PCPA101CLI(oModelCZB:GetValue('CZB_TPTB'),oModel:GetOperation()) },037,012,,,,.T.,,"",,,,.F. )
		oBtn2 	:= TButton():New( 078,163,STR0034,oDlg1,{|| PCPA101CNL(oDlg1, cItemBkp, lWhen, @oModelCZB)},037,012,,,,.T.,,"",,,,.F. )

		If !INCLUI .AND. lHasFicha
			oComboBox:lReadOnly := .T.
			oCZGBrw:oBrowse:bLDBlClick := &('{|| lVld := PCPA101CZG(), If(lVld, oCZGBrw:EDITCELL(), .F.) }')
			oCZGBrw:ForceRefresh()
		EndIF

		oDlg1:Activate(,,,.T.)
	ENDIF
Return

Function PCPA101CNL(oDlg1, cItemBkp, lWhen, oModelCZB)
Default lAutoMacao := .F.

  If lWhen
    If cItemBkp == STR0094
      oModelCZB:SetValue("CZB_TPTB","1")
    Else
      oModelCZB:SetValue("CZB_TPTB","2")
    EndIf
  EndIf
  IF !lAutoMacao
  	oDlg1:End()
  ENDIF
Return 

Static Function validCbox(oModelCZB)

	If cItem == STR0094 // Tipo simples
		oModelCZB:SetValue("CZB_TPTB","1")
	Else // Tipo Composto
		oModelCZB:SetValue("CZB_TPTB","2")
	EndIf

Return .T.

Function PCPA101VLT()
	If cItem == STR0094 .AND. !empty(M->CZC_VLTB)
		Alert(STR0092) //"Lista do tipo simples, não permitido informar valor."
		Return .F.
	EndIf
Return .T.

Function PCPA101VLI(nLinha, lHelp,cTipLista)
	Local lRet  	:= .T.
	Local nX        := 0
	Local aCols     := {{"",.T.}}
	Local aHeader   := {{"",""}}
	Local nPosConte := 1
	Local nPosValor	:= 1
	Local nPosSeque	:= 1
	
	Default nLinha     := oCZGBrw:nAt
	Default lHelp      := .T.		
	Default lAutoMacao := .F.		

	IF !lAutoMacao
		aCols     	:= oCZGBrw:aCols
		aHeader   	:= oCZGBrw:aHeader
		nPosConte   := aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("CZC_NMTB" )})
		nPosValor	:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("CZC_VLTB")})
		nPosSeque	:= aScan(aHeader,{|x|AllTrim(Upper(x[2]))==Upper("CZC_SQTB")})
	ENDIF

	If cItem == STR0094 // Tipo simples
		cTipLista := '1'
	Else
		cTipLista := '2'
	EndIf   

	If !aCols[nLinha][Len(aHeader)+1] .And. (Empty(aCols[nLinha][nPosConte]) .Or. (Empty(aCols[nLinha][nPosValor]) .AND. cTipLista == '2') .Or. Empty(aCols[nLinha][nPosSeque]))
	    lRet := .F.
	Else
		If !empty(aCols[nLinha][nPosValor]) .AND. cTipLista == '1'
			Alert(STR0092) //"Lista do tipo simples, não permitido informar valor."
			lRet := .F.
		Else
			For nX:= 1 to Len(aCols)
				If !aCols[nX][Len(aHeader)+1] .And. nX != nLinha .And. ALLTRIM(aCols[nX][nPosConte]) == ALLTRIM(aCols[nLinha][nPosConte])
					Alert(STR0035) //"Linha duplicada: não é possível inserir dois conteúdos iguais para itens da lista."
					lRet := .F.
					Exit
				EndIf
				If !aCols[nX][Len(aHeader)+1] .And. nX != nLinha .And. ALLTRIM(aCols[nX][nPosValor]) == ALLTRIM(aCols[nLinha][nPosValor]) .And. cTipLista == '2'
					Alert(STR0036) //"Linha duplicada: não é possível inserir dois valores iguais para itens da lista."
					lRet := .F.
					Exit
				Endif
			Next nX
		EndIf
	Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101CLI
Ação para botão de Confirmação da lista de valores para atributo
tipo L-Lista

@param 		cTipLista Tipo da lista
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101CLI(cTipLista, nOperation)
	Local nI        := 0
	Local oModel	:= FWModelActive()
	Local oModelCZC := oModel:GetModel("CZCDETAIL")
	Local nLinPre	:= oModelCZC:GetQtdLine()
	Local aDadosCZC := { }
	Local nOpcX	 	:= oModel:GetOperation()
	Local nCount    := 0

	Default lAutoMacao := .F.

    If nOperation == 1
    	oDlg1:End()
        Return .T.
    EndIf

	IF !lAutoMacao
		For nI := 1 To Len(oCZGBrw:aCols)
			If oCZGBrw:aCols[nI][4] == .F.  //Linha excluída
				If !PCPA101VLI(nI,1,cTipLista)
					Return .F.
				Endif
			Endif
		Next nI

		oDlg1:End()

		aDadosCZC := aClone(oCZGBrw:aCols)
	ENDIF

	If nOpcX == 3 .Or. nOpcX == 4
		//Exclui todos os dados do model, e insere novamente os dados que estão informados na grid da lista.
		For nI := 1 To oModelCZC:GetQtdLine()
		//--------------------------------
		// Estava dando erro de variável não declarada para as informações de aHeader e N
		// Por este motivo as variáveis foram inicializadas

			aHeader := {}
			N := nI
		
			aStruCZC := CZC->(DBStruct())
			For nCount := 1 To Len(aStruCZC)
				If X3USO(GetSx3Cache(aStruCZC[nCount,1],'X3_USADO'))
					aAdd(aHeader,{ TRIM(GetSx3Cache(aStruCZC[nCount,1],'X3_TITULO')), aStruCZC[nCount,1], GetSx3Cache(aStruCZC[nCount,1],'X3_PICTURE'),GetSx3Cache(aStruCZC[nCount,1],'X3_TAMANHO'),;
									GetSx3Cache(aStruCZC[nCount,1],'X3_DECIMAL'),"AllwaysTrue()",GetSx3Cache(aStruCZC[nCount,1],'X3_USADO'),  GetSx3Cache(aStruCZC[nCount,1],'X3_TIPO'), /*x3_arquivo*/,  GetSx3Cache(aStruCZC[nCount,1],'X3_CONTEXT') } )
				Endif
			Next nCount
			
			oModelCZC:GoLine(nI)
			If !oModelCZC:IsDeleted()
				oModelCZC:DeleteLine()
			EndIf
		Next
	EndIf

	IF !lAutoMacao
		For nI := 1 To Len(oCZGBrw:aCols)
			If aDadosCZC[nI][4] == .F. //Linha não excluida
				oModelCZC:AddLine()
				oModelCZC:LoadValue('CZC_CDAB',oModel:GetModel('CZBMASTER'):GetValue('CZB_CDAB'))
				oModelCZC:LoadValue('CZC_SQTB',aDadosCZC[nI][1])
				oModelCZC:LoadValue('CZC_NMTB',aDadosCZC[nI][2])
				oModelCZC:LoadValue('CZC_VLTB',aDadosCZC[nI][3])
			EndIf
		Next
	ENDIF

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101ACT
Ação para validação do carregamento da tela

@param 		oModel		Modelo de dados MVC
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101ACT(oModel)

	Local lDoAct := .T.

	If oModel:GetOperation()     == 5 
    	lDoAct := PCPA101EXC()
    ElseIf oModel:GetOperation() == 4
    	lDoAct := PCPA101UPD(oModel)
    ElseIf oModel:GetOperation() == 3
    	lDoAct := PCPA101INC(oModel)
    EndIf
    
Return lDoAct
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101POS
Validação das informações para confirmação dos dados

@param 		oModel		Modelo de dados MVC
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101POS(oModel)
	Local nOpc 		:= oModel:GetOperation()
	Local oModelCZB := oModel:GetModel("CZBMASTER")
	Local oModelCZC := oModel:GetModel("CZCDETAIL")
	Local nI 		:= 0

	If nOpc == 5 //Exclusão
	   return .T.
	Endif

	If nOpc != 4 // Alteração
		If !PCPA101VLC(1)
			Return .F.
		Endif
	EndIf

	If !PCPA101VLC(2)
		Return .F.
	Endif
	If !PCPA101VLC(3)
		Return .F.
	Endif
	If !PCPA101VLC(4)
		Return .F.
	Endif

	If oModelCZB:GetValue('CZB_TPAB') == 'T' //Tabela
		If !PCPA101VLC(5)
			Return .F.
		Endif
		If !PCPA101VLC(6)
			Return .F.
		Endif

		If Empty(oModelCZB:GetValue('CZB_VLPAAB'))
			PCPA101Msg(STR0037,"PCPA101",1) //"Valor padrão deve ser informado para atributo do tipo Tabela."
			Return .F.
		Endif
		If Empty(oModelCZB:GetValue('CZB_IDCDG'))
			PCPA101Msg(STR0038,"PCPA101",1) //"Código deve ser informado para atributo do tipo Tabela."
			Return .F.
		Endif
		If Empty(oModelCZB:GetValue('CZB_IDDS'))
			PCPA101Msg(STR0039,"PCPA101",1) //"Descrição deve ser informada para atributo do tipo Tabela."
			Return .F.
		Endif
	Endif

	If  oModelCZB:GetValue('CZB_TPAB') == 'L' //Lista
		If oModelCZC:GetQtdLine() == 1
			oModelCZC:GoLine(1)
			If Empty(oModelCZC:GetValue('CZC_NMTB'))
				PCPA101Msg(STR0040,"PCPA101",1) //"Necessário cadastro de valores possíveis para atributo tipo 'Lista'."
				Return .F.
			Endif
		Elseif oModelCZC:GetQtdLine() < 1
			PCPA101Msg(STR0040,"PCPA101",1) //"Necessário cadastro de valores possíveis para atributo tipo 'Lista'."
			Return .F.
		Endif
		If oModelCZB:GetValue('CZB_TPTB') == '1'
			For nI := 1 To oModelCZC:GetQtdLine()
				oModelCZC:goLine(nI)
				If oModelCZC:IsDeleted()
					Loop
				EndIf
				If !empty(oModelCZC:GetValue("CZC_VLTB"))
					PCPA101Msg(STR0086,"PCPA101",1) //"Atributo com lista do tipo Simples, não permitido informar o valor."
					Return .F.
				EndIf
				If empty(oModelCZC:GetValue("CZC_NMTB"))
					PCPA101Msg(STR0087,"PCPA101",1) //"Conteúdo da lista de valores não informado."
					Return .F.
				EndIf
			Next
		Else
			For nI := 1 To oModelCZC:GetQtdLine()
				oModelCZC:goLine(nI)
				If oModelCZC:IsDeleted()
					Loop
				EndIf
				If empty(oModelCZC:GetValue("CZC_VLTB"))
					PCPA101Msg(STR0088,"PCPA101",1) //"Valor da lista de valores não informado."
					Return .F.
				EndIf
				If empty(oModelCZC:GetValue("CZC_NMTB"))
					PCPA101Msg(STR0087,"PCPA101",1) //"Conteúdo da lista de valores não informado."
					Return .F.
				EndIf
			Next
		EndIf
	Endif
	If oModelCZB:GetValue('CZB_TPAB') $ "R" //Fórmula
		If !(validForm(oModelCZB:GetValue('CZB_VLPAAB'),oModelCZB:GetValue('CZB_RLAB')))
			Return .F.
		EndIf
	EndIf
	If !PCPA101VLP()
		Return .F.
	Endif
Return .T.

Function PCPA101CPA()
	PCPA101GVP()
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101VLP
Validação do campo Valor Padrão

@param
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101VLP()
	Local oModel   	:= FWModelActive()
   	Local oModelCZB := oModel:GetModel( 'CZBMASTER' )
   	Local oModelCZC	:= oModel:GetModel( 'CZCDETAIL' )
	Local cVLPAAB 	:= AllTrim(oModelCZB:GetValue('CZB_VLPAAB'))
	Local nI 		:= 0
	Local lDecimal	:= .F.
	Local nConVir	:= 0 //Valor considerando virgula
	Local lNumPrec	:= 0
	Local lNumTam	:= 0
	Local lNumAux	:= 0
	Local lPosVir	:= 0
	Local lEncontr 	:= .F.
	Local dData

	If Empty(cVLPAAB)
		Return .T.
	Endif

	If oModelCZB:GetValue('CZB_TPAB') $ "NA"
		For nI := 1 To Len(cVLPAAB)
			If !(SUBSTR(cVLPAAB,nI,1) $ "1234567890,")
				PCPA101Msg(STR0041,"PCPA101",1)
				Return .F.
			Endif
			If (SUBSTR(cVLPAAB,nI,1) $ ",")
				lPosVir  += 1
				lDecimal := .T.
			Else
				If lDecimal
					lNumPrec += 1
				Else
					lNumTam += 1
				Endif
			Endif
		Next nI

		If lPosVir > 1 //Mais de uma vírgula encontrada no número
			PCPA101Msg(STR0042,"PCPA101",1) //"Valor padrão inválido: formato inválido para campos numéricos."
			Return .F.
		Endif

		If lNumPrec > oModelCZB:GetValue('CZB_VLPRC')
			PCPA101Msg(STR0043,"PCPA101",1) //"Valor padrão inválido: número de casas decimais não compatível com precisão informada."
			Return .F.
		Endif
		If oModelCZB:GetValue('CZB_VLPRC') > 0
			nConVir := 1
		EndIf
		If lNumTam > (oModelCZB:GetValue('CZB_TMAB') - oModelCZB:GetValue('CZB_VLPRC')) - nConVir
			PCPA101Msg(STR0044,"PCPA101",1) //"Valor padrão inválido: tamanho não compatível com tamanho informado para atributo."
			Return .F.
		Endif

		If oModelCZB:GetValue('CZB_VLPRC') > 0
			If lPosVir < 1
				cVLPAAB = AllTrim(cVLPAAB)+","
			Endif

			For nI := lNumPrec+1 To oModelCZB:GetValue('CZB_VLPRC')
				cVLPAAB = AllTrim(cVLPAAB)+"0"
			Next nI

			oModelCZB:LoadValue('CZB_VLPAAB',cVLPAAB)
		Endif
	Endif

	If oModelCZB:GetValue('CZB_TPAB') $ "A" //Faixa
		For nI := 1 to Len(cVLPAAB)
			If SubStr(cVLPAAB,nI,1) == ","
				cVLPAAB := SubStr(cVLPAAB,1,nI-1) + "." + SubStr(cVLPAAB,nI+1)
			EndIf
		Next
		lNumAux := Val(cVLPAAB)
		If 	lNumAux < oModelCZB:GetValue('CZB_VLBGFX') .Or. ;
		   	lNumAux > oModelCZB:GetValue('CZB_VLEDFX')
		   	PCPA101Msg(STR0045,"PCPA101",1) //"Valor padrão inválido: valor deve estar entre a faixa de valores informada."
			Return .F.
		Endif
	Endif

	If oModelCZB:GetValue('CZB_TPAB') $ "CLF" //Char / Lista
		If Len(cVLPAAB) > oModelCZB:GetValue('CZB_TMAB')
			PCPA101Msg(STR0046,"PCPA101",1) //"Valor padrão inválido: tamanho não compatível com tamanho informado para atributo."
			Return .F.
		Endif
	Endif

	If oModelCZB:GetValue('CZB_TPAB') $ "T" //Tabela
		If Len(AllTrim(oModelCZB:GetValue('CZB_VLPAAB'))) != 3
			PCPA101Msg(STR0047,"PCPA101",1) //"Valor padrão inválido: tabela não existente."
			Return .F.
		Endif

		If !FwAliasInDic(PadR(oModelCZB:GetValue('CZB_VLPAAB'),3))
			PCPA101Msg(STR0047,"PCPA101",1) //"Valor padrão inválido: tabela não existente."
			Return .F.
		Endif
	Endif

	If oModelCZB:GetValue('CZB_TPAB') $ "D" //Data
		If Len(AllTrim(oModelCZB:GetValue('CZB_VLPAAB'))) != 10
			Help( ,, 'Help',, STR0089 , 1, 0 ) // "Data inválida. Informe uma data no formato DD/MM/AAAA"
			Return .F.
		EndIf

		//Verifica se as barras estão corretas.
		If SubStr(AllTrim(oModelCZB:GetValue('CZB_VLPAAB')),3,1) != "/" .OR. ;
			SubStr(AllTrim(oModelCZB:GetValue('CZB_VLPAAB')),6,1) != "/"
			Help( ,, 'Help',, STR0089 , 1, 0 ) // "Data inválida. Informe uma data no formato DD/MM/AAAA"
			Return .F.
		EndIf

		For nI := 1 To 10
			If nI == 3 .Or. nI == 6
				Loop
			EndIf
			If !(SubStr(AllTrim(oModelCZB:GetValue('CZB_VLPAAB')),nI,1) $ "0123456789" )
				Help( ,, 'Help',, STR0089 , 1, 0 ) // "Data inválida. Informe uma data no formato DD/MM/AAAA"
				Return .F.
			EndIf
		Next
		dData := cToD(AllTrim(oModelCZB:GetValue('CZB_VLPAAB')))
		If dToC(dData) == "  /  /    "
			Help( ,, 'Help',, STR0089 , 1, 0 ) // "Data inválida. Informe uma data no formato DD/MM/AAAA"
			Return .F.
		EndIf
	Endif

	If oModelCZB:GetValue('CZB_TPAB') $ "L" //Lista
		For nI := 1 To oModelCZC:GetQtdLine()
			oModelCZC:GoLine(nI)
			If !oModelCZC:isDeleted()
				If AllTrim(oModelCZC:GetValue('CZC_NMTB')) == AllTrim(cVLPAAB)
					lEncontr := .T.
				Endif
			Endif
		Next nI

		If !lEncontr
			PCPA101Msg(STR0049,"PCPA101",1)
			Return .F.
		Endif
	Endif

	If oModelCZB:GetValue('CZB_TPAB') $ "R" //Fórmula
		If !(validForm(oModelCZB:GetValue('CZB_VLPAAB'),oModelCZB:GetValue('CZB_RLAB')))
			Return .F.
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101SX3
Consulta padrão específica - campos de tabela (SX3)

@param
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101SX3()
	Local oMdl   	:= FWModelActive()
	Local oMdlF3 	:= oMdl:GetModel('CZBMASTER')
	Local aCpos   	:= {}       	//Array com os dados
	Local aRet    	:= {}       	//Array do retorno da opcao selecionada
	Local oDlg                  	//Objeto Janela
	Local oLbx                  	//Objeto List box
	Local cTitulo 	:= "Campos"  	//Titulo da janela --Campos do sitema
	Local cNoCpos 	:= ""
	Local cDescr  	:= "X3_TITULO"
	Local lRet    	:= .F.
	Local nCount    := 0
	Local cTabela

	Default lAutoMacao := .F.
	
	//=====================================================
	// Carrega o vetor com os campos da tabela selecionada
	//=====================================================
	
	aStruTab := SH1->(DBStruct())
	cTabela  := AllTrim(oMdlF3:GetValue('CZB_VLPAAB')) 		
	aStruTab := (cTabela)->(DBStruct())
	For nCount := 1 To Len(aStruTab)
		If X3USO(GetSx3Cache(aStruTab[nCount,1],'X3_USADO')) .AND. (GetSx3Cache(aStruTab[nCount,1],'X3_CONTEXT') <> "V") .AND. !(AllTrim(aStruTab[nCount,1])) $ cNoCpos
			aAdd( aCpos, { aStruTab[nCount,1], GetSx3Cache(aStruTab[nCount,1],'X3_TITULO') } )
		EndIf
	Next nCount	
	
	If Len( aCpos ) > 0
		IF !lAutoMacao
			DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

			@ 10,10 LISTBOX oLbx FIELDS HEADER "Campo", "Descrição"  SIZE 230,95 OF oDlg PIXEL

			oLbx:SetArray( aCpos )
			oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
			oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

			DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTER
		ENDIF
		If Len(aRet) > 0
			lRet := .T.	        
			VAR_IXB := aRet[1]	        	        
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101VLF
Tela para geração de fórmulas.

@param
@return

@author 	Lucas Konrad França
@since 		08/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101VLF(oModelCZB)
	Local aDados   	    := {}
	Local cFormuBkp     := AllTrim(oModelCZB:GetValue("CZB_VLPAAB"))
	Local cRelac        := oModelCZB:GetValue("CZB_RLAB")
	Local oLbx          := NIL
	Private cFormula    := AllTrim(oModelCZB:GetValue("CZB_VLPAAB"))
	Private oTMultiget1 := NIL
	Private oDlg        := NIL
	Default lAutoMacao  := .F.

	dbSelectArea("CZB")
	CZB->(dbSetOrder(1))
	CZB->(dbGoTop())
	While !(CZB->(Eof()))
		If CZB->CZB_TPAB == 'N' .And. (CZB->CZB_RLAB == '4' .Or. CZB->CZB_RLAB == cRelac .Or. cRelac == '4')
			aAdd(aDados, {CZB->CZB_CDAB, CZB->CZB_NMAB, CZB->CZB_DSAB})
		EndIf
		CZB->(dbSkip())
	End
	CZB->(dbCloseArea())
	If Len(aDados) > 0
		IF !lAutoMacao
			DEFINE MSDIALOG oDlg TITLE STR0064 FROM 0,0 TO 470,500 PIXEL

			@ 10,10 LISTBOX oLbx FIELDS HEADER STR0065, STR0066, STR0055  SIZE 230,95 OF oDlg PIXEL

			oLbx:SetArray( aDados )
			oLbx:bLine := {|| {aDados[oLbx:nAt][1],aDados[oLbx:nAt][2],aDados[oLbx:nAt][3]}}
			oLbx:bLDblClick := {|| addTexto(@cFormula,aDados[oLbx:nAt][2],@oTMultiget1)}

			oTMultiget1 := tMultiget():new( 120, 10, {| u | if( pCount() > 0, cFormula := UPPER(u), UPPER(cFormula) ) },oDlg, 230, 95, ,.T., , , , .T. )
			oTMultiget1:EnableHScroll(.T.)
			oTMultiget1:EnableVScroll(.T.)
			oTMultiget1:goEnd()

			TButton():New( 107,  10,  '+', oDlg, {|| addTexto(@cFormula,"+",@oTMultiget1)}, 10,10,,,,.T.)
			TButton():New( 107,  30,  '-', oDlg, {|| addTexto(@cFormula,"-",@oTMultiget1)}, 10,10,,,,.T.)
			TButton():New( 107,  50,  '*', oDlg, {|| addTexto(@cFormula,"*",@oTMultiget1)}, 10,10,,,,.T.)
			TButton():New( 107,  70,  '/', oDlg, {|| addTexto(@cFormula,"/",@oTMultiget1)}, 10,10,,,,.T.)
			TButton():New( 107,  90,  '^', oDlg, {|| addTexto(@cFormula,"^",@oTMultiget1)}, 10,10,,,,.T.)
			TButton():New( 107,  110, '(', oDlg, {|| addTexto(@cFormula,"(",@oTMultiget1)}, 10,10,,,,.T.)
			TButton():New( 107,  130, ')', oDlg, {|| addTexto(@cFormula,")",@oTMultiget1)}, 10,10,,,,.T.)

			TButton():New( 107,  177, STR0067, oDlg, {|| cFormula:=""}, 30,10,,,,.T.)
			TButton():New( 107,  210, STR0068, oDlg, {|| addTexto(@cFormula,aDados[oLbx:nAt][2],@oTMultiget1)}, 30,10,,,,.T.)

			DEFINE SBUTTON FROM 220,185 TYPE 2 ACTION ( eventBtn(@oDlg,"CANCEL",@cFormula,cFormuBkp,cRelac)) ENABLE OF oDlg
			DEFINE SBUTTON FROM 220,214 TYPE 1 ACTION ( eventBtn(@oDlg,"CONFIRM",@cFormula,cFormuBkp,cRelac)) ENABLE OF oDlg

			ACTIVATE MSDIALOG oDlg CENTER
		ENDIF
	EndIf
Return cFormula

//-------------------------------------------------------------------
/*/{Protheus.doc} eventBtn
Função de confirmação/cancelamento da tela de fórmulas

@param oDlg		Referência da tela
@param cTpBtn		Tipo do botão que foi clicado. CANCEL/CONFIRM
@param cFormula 	Fórmula a ser validada, no caso da confirmação.
@param cFormBkp   Backup da fórmula, caso cancele a edição.
@param cRelac		Relacionador do atributo
@return

@author 	Lucas Konrad França
@since 		09/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function eventBtn(oDlg,cTpBtn,cFormula,cFormBkp,cRelac)
Default lAutoMacao := .F.

	cFormula := AllTrim(cFormula)

	If cTpBtn == "CANCEL"
		cFormula := cFormBkp
		oDlg:End()
	Else
		If !(validForm(cFormula,cRelac))
			Return .F.
		Else
			IF !lAutoMacao
				oDlg:End()
			ENDIF
		EndIf
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} validForm
Função de validação da fórmula.

@param cFormula 	Fórmula que será validada.
@param cRelac		Relacionador do atributo.
@return

@author 	Lucas Konrad França
@since 		09/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function validForm(cFormula,cRelac)
	Local nI      := 0
	Local nI2     := 0
	Local nI3     := 0
	Local nCount  := 0
	Local nPosIni := 0
	Local cAtributo

	cFormula := AllTrim(cFormula)
	If Len(cFormula) > 254
		Help( ,, 'Help',, STR0073 , 1, 0 ) // "Fórmula deve conter no máximo 254 caracteres."
		Return .F.
	EndIf
	If !(valParente(cFormula))
		Return .F.
	EndIf
	If SubStr(cFormula,1,1) $ "/*+.=^"
		Help( ,, 'Help',, STR0074 , 1, 0 ) // ""Não permitido iniciar a fórmula com operadores diferentes de '-'.
		Return .F.
	EndIf
	If SubStr(cFormula,1,1) == "-"
		cFormula := SubStr(cFormula,2)
	EndIf
	For nI := 1 To Len(cFormula)
		If SubStr(cFormula,nI,1) $ "/*+.=^-"
			If SubStr(cFormula,nI+1,1) $ "/*+.=^-" //Verifica se colocou operadores repetidos
				Help( ,, 'Help',, STR0075 , 1, 0 ) // Existem operadores duplicados. Favor, verificar.
				Return .F.
			EndIf
		EndIf
		If SubStr(cFormula,nI,1) == "("
			For nI2 := nI+1 To Len(cFormula)
				If SubStr(cFormula,nI2,1) == "("
					nI := nI2
					Loop
				EndIf
				If SubStr(cFormula,nI2,1) == ")"
					If !(validForm(SubStr(cFormula,nI+1,(nI2-nI)-1),cRelac))
						Return .F.
					EndIf
					cFormula := AllTrim(SubStr(cFormula,1,nI-1) + SubStr(cFormula,nI2+1))
					If SubStr(cFormula,Len(cFormula),1) $ "/*-+"
						cFormula := SubStr(cFormula,1,(Len(cFormula)-1))
					EndIf
					nI := 1
					Exit
				EndIf
			Next
		EndIf

		If IsAlpha(SubStr(cFormula,nI))
			nCount := 0
			For nI2 := nI To Len(cFormula)
				If SubStr(cFormula, nI2+1,1) == "("
					Help( ,, 'Help',, STR0076 , 1, 0 ) // Parênteses aberto sem estar com um operador válido. Favor, verificar
					Return .F.
				EndIf
				nCount++
				If SubStr(cFormula, nI2+1,1) $ "/*+.=^-"
					Exit
				EndIf
			Next
			nPosIni := 1
			For nI3 := nI-1 To 1 Step -1
				If SubStr(cFormula, nI3,1) $ "0123456789"
					nCount++
				EndIf
				If SubStr(cFormula, nI3,1) $ "/*+.=^-("
					nPosIni := nI3 + 1
					Exit
				EndIf
			Next
			cAtributo := SubStr(cFormula, nPosIni, nCount)
			If !(vldAtrib(cAtributo,cRelac))
				Return .F.
			EndIf

			nI := nI2
		EndIf
	Next

	If SubStr(cFormula,Len(cFormula),1) $ "/*+.=^-("
		Help( ,, 'Help',, STR0077, 1, 0 ) // Fórmula incorreta, favor verificar
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} vldAtrib
Função de validação do atributo.

@param cAtributo 	Atributo que será validado.
@param cRelac		Relacionador do atributo
@return

@author 	Lucas Konrad França
@since 		10/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function vldAtrib(cAtributo,cRelac)
	Local lRet := .T.

	dbSelectArea("CZB")
	CZB->(dbSetOrder(2))
	If (CZB->(dbSeek(xFilial("CZB")+cAtributo)))
		If CZB->CZB_TPAB != 'N'
			Help( ,, 'Help',, STR0078 + cAtributo + STR0079 , 1, 0 ) // Atributo XXX não é numérico.
			lRet := .F.
		EndIf
		If CZB->CZB_RLAB != '4' .And. CZB->CZB_RLAB != cRelac .And. cRelac != '4'
			If lRet
				Help( ,, 'Help',, STR0080 + cAtributo + STR0081 , 1, 0 ) // Relacionador do atributo XXX inválido para este cadastro.
				lRet := .F.
			EndIf
		EndIf
	Else
		Help( ,, 'Help',, STR0078 + cAtributo + STR0082 , 1, 0 ) // Atributo XXX não cadastrado.
		lRet := .F.
	EndIf
	CZB->(dbCloseArea())
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} valParente
Função que valida se existem inconsistencias com os parênteses na fórmula.

@param cFormula 	Fórmula que será validada.
@return

@author 	Lucas Konrad França
@since 		09/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function valParente(cFormula)
	Local nI    := 0
	Local nCont := 0

	For nI := 1 To Len(AllTrim(cFormula))
		//Valida se existem parênteses abertos/fechados incorretamente
		If SubStr(cFormula,nI,1) == "("
			nCont++
			If nI < Len(cFormula)
				If SubStr(cFormula,nI+1,1) = ")"
					Help( ,, 'Help',, STR0069 , 1, 0 ) // "Existem parênteses sem conteúdo dentro. Favor, verificar."
					Return .F.
				END IF
				If SubStr(cFormula,nI+1,1) $ "/*+.=^"
					Help( ,, 'Help',, STR0083, 1, 0 ) // Existem operadores inválidos após a abertura do parênteses.
					Return .F.
				EndIf
			EndIf
		EndIf
		If SubStr(cFormula,nI,1) == ")"
			nCont--
			If nCont < 0
				Help( ,, 'Help',,STR0070, 1, 0 ) // "Existe fechamento de parênteses sem que esteja aberto. Favor, verificar."
				Return .F.
			EndIf
			If SubStr(cFormula,nI+1,1) == "("
				Help( ,, 'Help',,STR0084, 1, 0 ) // "Existem parênteses que não estão separados por um operador válido.
				Return .F.
			EndIf
			If SubStr(cFormula,nI-1,1) $ "/*+.=^-"
				Help( ,, 'Help',,STR0085, 1, 0 ) // Final de parênteses não está separado por um operador válido.
				Return .F.
			EndIf
		EndIf
	Next

	If nCont > 0
		Help( ,, 'Help',,STR0071, 1, 0 ) // "Existe fechamento de parênteses sem que esteja aberto. Favor, verificar."
		Return .F.
	EndIf
Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} addTexto
Função para adicionar um texto no campo Memo.

@param cTextOld	texto que já existe no Memo
@param cAdd		texto que será adicionado no memo
@param oMemo		referência do objeto Memo
@return

@author 	Lucas Konrad França
@since 		08/10/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function addTexto(cTextOld, cAdd, oMemo)
	If Len(AllTrim(cTextOld)) <= 0 .Or. oMemo:nPos >= Len(AllTrim(cTextOld))
		//adiciona o texto no fim do texto já existente
		cTextOld := AllTrim(cTextOld) + AllTrim(cAdd)
	Else
		//adiciona o texto onde o cursor está posicionado.
		cTextOld := AllTrim(SubStr(cTextOld, 1, oMemo:nPos)) + AllTrim(cAdd) + AllTrim(SubStr(cTextOld,(oMemo:nPos+1)))
	EndIf
	oMemo:Refresh()
	oMemo:goEnd()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101VLL
Consulta padrão específica - valor padrão da lista

@param
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101VLL()
	Local oMdl   	:= FWModelActive()
	Local oMdlF3 	:= oMdl:GetModel('CZBMASTER')
	Local oModelCZC := oMdl:GetModel('CZCDETAIL')
	Local aCpos   	:= {}      		//Array com os dados
	Local aRet    	:= {}       	//Array do retorno da opcao selecionada
	Local oDlg                  	//Objeto Janela
	Local oLbx                  	//Objeto List box
	Local cTitulo 	:= STR0056  	//Titulo da janela --Campos do sitema
	Local cNoCpos 	:= ""
	Local lRet    	:= .F.
	Local nI		:= 0
	Local aDadosCZC := { }
	Default lAutoMacao := .F.

	//=====================================================
	// Carrega o vetor com as opções cadastradas
	//=====================================================
	aDadosCZC := { }
	For nI := 1 To oModelCZC:GetQtdLine()
		oModelCZC:GoLine(nI)
		If !oModelCZC:IsDeleted() .And. !empty(oModelCZC:GetValue('CZC_SQTB'))
			aAdd(aDadosCZC, {oModelCZC:GetValue('CZC_SQTB'), oModelCZC:GetValue('CZC_NMTB'),;
							  oModelCZC:GetValue('CZC_VLTB'),.F.})
		EndIf
	Next
	For nI := 1 To Len(aDadosCZC)
	   If aDadosCZC[nI][4] == .F.
	   		aAdd( aCpos, { aDadosCZC[nI][2], aDadosCZC[nI][3] } )
	   Endif
	Next nI

	If Len( aCpos ) > 0
		IF !lAutoMacao
			DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL

			@ 10,10 LISTBOX oLbx FIELDS HEADER STR0057, STR0058  SIZE 230,95 OF oDlg PIXEL

			oLbx:SetArray( aCpos )
			oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
			oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}}

			DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg CENTER
		ENDIF

	    If Len(aRet) > 0
	        lRet 		:= .T.
	        cVALPAD 	:= aRet[1]
	    EndIf

	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101EXC
Valida se atributo já está sendo utilizado em um template

@param
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101EXC()
	DbSelectArea('CZE')
	CZE->(DbSetOrder(2))
	If !(CZE->(DbSeek(xFilial('CZE')+CZB->CZB_CDAB)))
		Return .T.
	Endif

	PCPA101Msg(STR0050,"PCPA101",1) //"Atributo já utilizado em um template. Exclusão não permitida."
Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101UPD
Valida se atributo já está sendo utilizado em uma ficha técnica

@param
@return

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Function PCPA101UPD(oModel)
	
   	Local oModelCZB     := oModel:GetModel( 'CZBMASTER' )
   	Local oStructCZB    := oModelCZB:GetStruct('CZBMASTER')
   	Local cTPABVal      := CZB->CZB_TPAB
   	Local lBloqTPAB     := lBloqVLPRC := lBloqTMAB := .F.
   	Local lIsValid      := .T.

	If PCPA101HASFC()
		
		MngFldEnble(oStructCZB, .F.)
		
		DO CASE	
			CASE cTPABVal == "C"
				lBloqTMAB  := .T.
				lBloqVLPRC := .F. 
			CASE cTPABVal == "N" .OR. cTPABVal == "O"	
				lBloqVLPRC := lBloqTMAB := .T.
			CASE cTPABVal == "L"
				//Do Nothing.
			OTHERWISE
				PCPA101Msg(STR0052,"PCPA101",1) //"Atributo já utilizado em uma ficha técnica. Alteração não permitida."
				lIsValid := .F.
		ENDCASE
		
		If lIsValid
			oStructCZB:SetProperty(   'CZB_TPAB', MODEL_FIELD_WHEN, {|| lBloqTPAB}  )	
			oStructCZB:SetProperty(   'CZB_TMAB', MODEL_FIELD_WHEN, {|| lBloqTMAB}  )
			oStructCZB:SetProperty(  'CZB_VLPRC', MODEL_FIELD_WHEN, {|| lBloqVLPRC} )
		EndIf		
	
	Else
		MngFldEnble(oStructCZB, .T.)
	EndIf
	
		

Return lIsValid
//-------------------------------------------------------------------
Function PCPA101INC(oModel)
	
	Local oModelCZB     := oModel:GetModel( 'CZBMASTER' )
   	Local oStructCZB    := oModelCZB:GetStruct('CZBMASTER')   	
   	Local nFieldIndex   := 1   
   	Local nCZBFieldSize := Len(oStructCZB:aFields)
   	//Whiles
   MngFldEnble(oStructCZB, .T.)
	
Return .T.
//-------------------------------------------------------------------
/*/{Protheus.doc} PCPA101Msg
Exibe Mensagem de erro.
Uso Geral.

@param     cMsg       	Mensagem de erro
@param     cRotina   	Nome da rotina a ser exibida na janela

@Return 	lRet       	.F. Sempre retorna .F. indicando um erro para poder
usar em gatilhos e validações onde exibira a mensagem e retornara .F.

@author 	Monique Madeira Pereira
@since 		01/09/2013
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function PCPA101Msg ( cMsg, cRotina, nTipo )
Default cMsg    	:= STR0051 //'Erro '
Default cRotina 	:= ProcName( 1 )
Default nTipo   	:= 1

if nTipo == 1
    Help( ,, 'HELP', cRotina, cMsg, 1, 0)
Else
    MsgAlert(cMsg, cRotina)
Endif

Return .F.
//-------------------------------------------------------------------
Function PCPA101CZG()

	Local lRet := .T.

	If !INCLUI .AND. PCPA101HASFC()
				DbSelectArea('CZC')
				CZC->(DbSetOrder(1))
				
				If  oCZGBrw:nAt <= Len(aCols) .AND. CZC->(DbSeek(xFilial("CZC")+CZB->CZB_CDAB+aCols[oCZGBrw:nAt][1]))
					Alert(STR0098)
					lRet := .F.
				EndIf
						
	EndIf
	
Return lRet
//-------------------------------------------------------------------
//Verifica se o registro está sendo utilizado em alguma ficha
Static Function PCPA101HASFC()
	DbSelectArea('CZG')
	CZG->(DbSetOrder(3))
Return CZG->(DbSeek(xFilial("CZG")+CZB->CZB_CDAB))
//-------------------------------------------------------------------
//Toggle fields
Static Function MngFldEnble(oTgtStruct, lEnbl)

		Local nFieldIndex   := 1
		Local nCZBFieldSize := Len(oTgtStruct:aFields)
		
		While (nFieldIndex <= nCZBFieldSize)
				oTgtStruct:SetProperty( oTgtStruct:aFields[nFieldIndex][3], MODEL_FIELD_WHEN, {|| lEnbl} )
				nFieldIndex++
		EndDo
		
Return Nil
