#Include "FisA096.ch"
#Include "Protheus.ch"
#Include "FwMvcDef.ch"

/*/{Protheus.doc} FISA096
Cadastro Vigencia Classe de Selos

@author Graziele Mendonça Paro
@since 25/02/2015
/*/

Function FISA096()

	Local oBrowse := Nil

	IF AliasIndic("CLY") 
		oBrowse := FWMBrowse():New()
		oBrowse:SetAlias("CLY")
		oBrowse:SetMenuDef("FISA096")
		oBrowse:SetDescription(STR0001)     // "Vigência da Classe de Selos"
		oBrowse:Activate()
	Else
		Help("",1,"Help","Help",STR0002,1,0) // Tabela CLY não cadastrada no sistema!
	EndIf
	
Return     

/*/{Protheus.doc} ModelDef
Retorna o Modelo de dados da rotina de Cadastro Vigencia Classe de Selos

@author Graziele Mendonça Paro
@since 25/02/2015

@return obejto, modelo definido
/*/
Static Function ModelDef()
	
	Local oModel   	:= Nil
	Local oStruCLY 	:= FwFormStruct( 1, "CLY" )
	
	// Instancia o modelo de dados
	oModel := MpFormModel():New( 'FISA096', ,{|oModel| ValidForm(oModel)})
	
	oModel:SetDescription( STR0001 ) // "Vigência da Classe de Selos"
	
	// Adiciona estrutura de campos no modelo de dados
	oModel:AddFields( 'CLYMASTER', /*cOwner*/, oStruCLY )
	oModel:SetDescription(STR0001) // Vigência da Classe de Selos
	
	// Seta chave primaria
	oModel:SetPrimaryKey( {"CLY_FILIAL","CLY_TIPO","CLY_CLASSE"} )
	
	oStruCLY:SetProperty('CLY_COD',MODEL_FIELD_WHEN,{|| ValidCamp(oModel,"PROD")})
	oStruCLY:SetProperty('CLY_PRODUT',MODEL_FIELD_WHEN,{|| ValidCamp(oModel,"PROD")})		
	oStruCLY:SetProperty('CLY_GRUPO',MODEL_FIELD_WHEN,{|| ValidCamp(oModel,"GRUPO")})	
	
Return oModel

/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina de Cadastro Vigencia Classe de Selos

@author Graziele Mendonça Paro
@since 25/02/2015

@return obejto, view definida
/*/
Static Function ViewDef()
	
	Local oView		:= Nil
	Local oModel	:= FwLoadModel("FISA096")
	Local oStruCLY 	:= FwFormStruct(2,"CLY")	// Cadastro Vigencia Classe de Selos
	
	// Instancia modelo de visualização
	oView := FwFormView():New()
	
	// Seta o modelo de dados
	oView:SetModel(oModel)
	
	// Adciona os campos na estrutura do modelo de dados
	oView:AddField('VIEW_CLY',oStruCLY,'CLYMASTER')
	
	// Cria o box
	oView:CreateHorizontalBox('TOTAL',100)
	
	// Seta o owner
	oView:SetOwnerView('VIEW_CLY','TOTAL')
	
Return oView

/*/{Protheus.doc} MenuDef
Retorna o Menu da rotina de Cadastro Vigencia Classe de Selos

@author Graziele Mendonça Paro
@since 25/02/2015

@return array, menu definido
/*/
Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.FISA096' OPERATION 2 ACCESS 0	// 'Visualizar'
	ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.FISA096' OPERATION 3 ACCESS 0	// 'Incluir'
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA096' OPERATION 4 ACCESS 0	// 'Alterar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA096' OPERATION 5 ACCESS 0	// 'Excluir'
	
Return aRotina

/*/{Protheus.doc} ValidForm
Validação das informações digitadas no form.

@author Graziele Mendonça Paro
@since 25/02/2015

@param oModel, objeto, modelo definido.

@return logico, se foi validado as informações digitadas.
/*/
Static Function ValidForm(oModel)

	Local lRet			:= .T.
	
	Local nOperation	:= oModel:GetOperation()
	
	Local cTipo			:= oModel:GetValue ('CLYMASTER','CLY_TIPO')
	Local cCodProd		:= oModel:GetValue ('CLYMASTER','CLY_COD')
	Local cClasse		:= oModel:GetValue ('CLYMASTER','CLY_CLASSE')
	Local cDTIni		:= oModel:GetValue ('CLYMASTER','CLY_DTINI')
	Local cDTfim		:= oModel:GetValue ('CLYMASTER','CLY_DTFIM')
	Local cGrupo		:= oModel:GetValue ('CLYMASTER','CLY_GRUPO')    
	Local cFiltro		:= ""
	Local cWhere		:= ""
	Local cRegisto		:= ""
	
	Default oModel		:= nil
	
	IF nOperation == 4 //Alteração
		dbSelectArea("CLY")
		cRegisto := CLY->(RECNO())
		cWhere := "%CLY.R_E_C_N_O_ <>"+ %Exp:Alltrim(Str(cRegisto))%+"%" 
		
		If !EMPTY(cCodProd) // Se o produto estiver preenchido
			CLY->(DbSetOrder (1))
			If  CLY->(DbSeek(xFilial("CLY")+cTipo+cClasse+cCodProd))
				IF CLY->(RECNO()) <> cRegisto
					Help(,,"Fisa096","",STR0007,1,0) //Já existe registro para este Tipo/Classe/Produto
					lRet := .F.
				EndIf	
			EndIf
		EndIf	
		
		If !EMPTY(cGrupo) //Se o grupo estiver preenchido
			CLY->(DbSetOrder (2))
			IF CLY->(DbSeek(xFilial("CLY")+cTipo+cClasse+cGrupo)) 
				IF CLY->(RECNO()) <> cRegisto
					Help(,,"Fisa096",,STR0008,1,0) //"Já existe registro para este Tipo/Grupo/Classe"
					lRet := .F.
				EndIf 
			EndIf
		EndIf	
		
		IF (Empty(cDTIni) .Or. Empty(cDTfim)) .And. lRet
			Help(,,"Fisa096",,STR0009,1,0) //Informe as Datas de Inicio e Fim da Vigência
			lRet := .F.
		EndIf
		
		IF (cDTIni > cDTfim) .And. lRet
			Help(,,"Fisa096",,STR0010,1,0) //A Data Inicial deve ser menor que a Data final
			lRet := .F.
		EndIf
	Else
		cWhere := "%1=1%"    	    
	Endif
	
	//Inclusao
	IF (nOperation == 3) .And. lRet
		If !EMPTY(cCodProd) // Se o produto estiver preenchido
			CLY->(DbSetOrder (1))
			If  CLY->(DbSeek(xFilial("CLY")+cTipo+cClasse+cCodProd))
				Help(,,"Fisa096","",STR0007,1,0) //Já existe registro para este Produto/Classe
				lRet := .F.
			EndIf
		EndIf	
		
		If !EMPTY(cGrupo) //Se o grupo estiver preenchido
			CLY->(DbSetOrder (2))
			IF CLY->(DbSeek(xFilial("CLY")+cTipo+cClasse+cGrupo)) 
					Help(,,"Fisa096",,STR0008,1,0) //Já existe registro para este Grupo/Classe
					lRet := .F.
			EndIf
		EndIf	
		
		IF (Empty(cDTIni) .Or. Empty(cDTfim)) .And. lRet
			Help(,,"Fisa096",,STR0009,1,0) //Informe as Datas de Inicio e Fim da Vigência
			lRet := .F.
		EndIf
		
		IF (cDTIni > cDTfim) .And. lRet
			Help(,,"Fisa096",,STR0010,1,0) //A Data Inicial deve ser menor que a Data final
			lRet := .F.
		EndIf 
	EndIf
	
	IF nOperation <> 5 .And. lRet 
		IF !EMPTY(cGrupo) .And. cTipo == "1"
			cFiltro := "%AND CLY.CLY_TIPO = "+ %Exp:Alltrim(cTipo)%+ " AND CLY.CLY_GRUPO = "+ %Exp:Alltrim(cGrupo)%+"%" 
		ElseIf !EMPTY(cCodProd) .And. cTipo == "2"
			cFiltro := "%AND CLY.CLY_TIPO = "+ %Exp:Alltrim(cTipo)%+ " AND CLY.CLY_COD = '"+ %Exp:Alltrim(cCodProd)%+"'%" 
		EndIf
		
		cAliasCLY	:=	GetNextAlias()
		BeginSql Alias cAliasCLY	
		
		SELECT  COUNT(*) AS CONTADOR 
		FROM 
			%Table:CLY% CLY 
		WHERE 
			CLY.CLY_FILIAL=%xFilial:CLY% AND 
			((CLY.CLY_DTINI >= %Exp:cDTIni% AND CLY.CLY_DTFIM <= %Exp:cDTfim%  ) OR (CLY.CLY_DTINI <= %Exp:cDTfim% AND CLY.CLY_DTFIM >= %Exp:cDTfim%  ) OR (CLY.CLY_DTINI <=  %Exp:cDTIni%  AND CLY.CLY_DTFIM >=  %Exp:cDTIni%   )) 
			%EXP:cFiltro%	AND
			%EXP:cWhere%	AND
			CLY.%NotDel%
		EndSql
		
		IF (cAliasCLY)->CONTADOR > 0
			Help(,,"Fisa096",,STR0011,1,0) //Já existe um cadastro no mesmo periodo para este 
			lRet := .F.
		EndIf 
		(cAliasCLY)->(DbCloseArea ())
	EndIf
	
Return lRet

/*/{Protheus.doc} ValidCamp
Validação das informações digitadas no form.

@author Graziele Mendonça Paro
@since 05.11.2014

@param oModel, objeto, modelo definido.
@param cRegra, caracter, contem a regra definida

@return logico, se foi validado as informações digitadas.
/*/
Static Function ValidCamp(oModel,cRegra)

	Local lRet	:= .T.
	
	Local cTipo	:= oModel:GetValue('CLYMASTER','CLY_TIPO')
	
	Default oModel := nil
	
	Default cRegra	:= ""
	
	If cTipo == "1" .And. !cRegra$"GRUPO"		// Grupo 
		lRet:= .F.
	ElseIf cTipo == "2" .And. !cRegra$"PROD"	// Produto
		lRet:= .F.
	EndIf
	
Return lRet