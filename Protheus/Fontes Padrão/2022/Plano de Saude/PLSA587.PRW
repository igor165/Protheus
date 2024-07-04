#include "PROTHEUS.CH"
#Include 'FWMVCDef.ch'
#include "PLSA587.CH"

Static lPLSUNI 	:= GetNewPar("MV_PLSUNI", "0") == "1"
static nSeque	:= 1	
static cMes		:= strzero(Month(Date()), 2)
static cAno		:= right(cvaltochar(Year(Date())), 2)
static cTamBAU	:= 15 //Nosso campo 14, mas no manual, cita tamanho 15.... tamSx3("BAU_CPFCGC")[1]
static cAliPad	:= "BLZ"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA587
RDA x Pacotes
@author Oscar Zanin
@since 04/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA587(lAutoma)
	Local cCampos 	:= ""
	Local oBrowse	:= nil

	Default lAutoma := .F.	 
	Private lReajuste := .F. 

    BLZ->(dbsetorder(1))
	BLY->(dbsetorder(1))

    cCampos += iif(BLZ->(fieldPos("BLZ_VIGINI")) <= 0, "BLZ_VIGINI,", "" ) 
    cCampos += iif(BLZ->(fieldPos("BLZ_VIGFIM")) <= 0, "BLZ_VIGFIM,", "" ) 
    cCampos += iif(BLZ->(fieldPos("BLZ_STATUS")) <= 0, "BLZ_STATUS,", "" ) 
	cCampos += iif(BLZ->(fieldPos("BLZ_REAJUS")) <= 0, "BLZ_REAJUS,", "" ) 
	cCampos += iif(BLY->(fieldPos("BLY_VERSAO")) <= 0, "BLY_VERSAO,", "" ) 

	if !empty(cCampos)
		If !lAutoma
			cCampos := substr(cCampos,1,len(cCampos)-1)
			aviso( STR0002,STR0013 + cCampos ,{ "Ok" }, 2 ) //Atenção / Para a execução da rotina, é necessária a criação do(s) campo(s):
			return
		Else
			return .F.
		EndIf	
	endIf

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('BLZ')
	oBrowse:SetDescription(STR0023) //"RDA x Pacotes"

	//Adiciona Legenda
	If lPLSUNI
		obrowse:AddLegend( "!(Vazio(BLZ_VIGFIM)) .AND. BLZ_VIGFIM <  dDataBase"							  		   , "BR_CANCEL"		,   STR0024) //Vigência encerrada
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. (Vazio(BLZ_STATUS))"		   , "BR_BRANCO"		,	STR0025) //Vigência aberta e PTUA1200 não gerado
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '1' ", "BR_AMARELO"		,	STR0026) //Em construção
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '2' ", "BR_AZUL"			,	STR0027) //Em análise Administrativo
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '3' ", "BR_AZUL_CLARO"	,	STR0028) //Em análise Médico
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '4' ", "BR_VIOLETA"		,	STR0029) //Em análise Enfermeiro
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '5' ", "BR_PINK"			,	STR0030) //Em análise Supervisor
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '6' ", "BR_LARANJA"		,	STR0031) //Exigência
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '7' ", "BR_VERDE"			,	STR0032) //Aprovado
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '8' ", "BR_VERDE_ESCURO"	,	STR0033) //Aprovado com ressalva
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) ==  '9' ", "BR_VERDE_ESCURO"	,	STR0034) //Publicado sem Aprovação
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '10' ", "BR_VERMELHO"		,	STR0035) //Reprovado
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '11' ", "BR_MARRON_OCEAN"	,	STR0036) //Reprovado Vigente
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '12' ", "BR_CINZA"			,	STR0037) //Cancelado
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '13' ", "BR_PRETO"			,	STR0038) //Inválido
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '14' ", "BR_PRETO_0"		,	STR0039) //Suspenso
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '15' ", "BR_PRETO_1"		,	STR0040) //Bloqueado
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '16' ", "BR_MARROM"		,	STR0041) //Duplicado
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '17' ", "BR_MARRON"		,	STR0042) //Reajuste em Análise
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase) .AND. ALLTRIM(BLZ_STATUS) == '18' ", "BR_PRETO_3"		,	STR0043) //Expirado
	Else
		obrowse:AddLegend( "!(Vazio(BLZ_VIGFIM)) .AND. BLZ_VIGFIM <  dDataBase"  , "BR_CANCEL", STR0024) //Vigência encerrada
		obrowse:AddLegend( " (Vazio(BLZ_VIGFIM)  .OR.  BLZ_VIGFIM >= dDataBase)" , "BR_VERDE" , STR0044) //Vigência aberta
	EndIf

	iif(!lAutoma, oBrowse:Activate(), '')

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
RDA x Pacotes
@author Oscar Zanin
@since 04/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	Add Option aRotina Title 	STR0016			Action 'VIEWDEF.PLSA587'			Operation 2 Access 0 //VISUALIZAR
	Add Option aRotina Title 	STR0017			Action 'VIEWDEF.PLSA587'			Operation 3 Access 0 //Incluir
	Add Option aRotina Title 	STR0018			Action "PLS587Veri(4,'Alterar')"	Operation 4 Access 0 //Alterar
	Add Option aRotina Title 	STR0019			Action "pl587ExReaj()"				Operation 5 Access 0 //Excluir
	ADD OPTION aRotina Title 	STR0020			Action 'pl587Reaju()'				Operation 6 Access 0 //Reajuste
	If lPLSUNI
		ADD OPTION aRotina Title 	STR0021			Action 'pl587StPac()'			Operation 2 Access 0 //Atualizar status do pacote
		Add Option aRotina Title 	STR0022 		Action 'PlBcCon587()'    		Operation 2 Access 0 //Anexos (Banco de Conhecimento)
	EndIf
	//ADD OPTION aRotina Title 	'Schedule'						Action 'plStatPac()'				OPERATION 2 ACCESS 0 // para testar a função configurada na schedule do Wizard Configurador

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
RDA x Pacotes
@author Oscar Zanin
@since 04/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel // Modelo de dados construído
	// Cria as estruturas a serem usadas no Modelo de Dados, ajustando os campos que irá considerar
	Local oStrBLZ	:= FWFormStruct(1,'BLZ',  )
	Local oStrBLY	:= FWFormStruct(1,'BLY',  ) 

	// Cria o objeto do Modelo de Dados e insere a funçao de pós-validação
	oModel := MPFormModel():New( 'PLSA587', , {|oModel| pl587VldOk(oModel)} , , )
	//MPFormModel():New( STR0038, /*bPreValidacao*/, /*bPosValidacao*/, {|oModel|PMGRVBOK(oModel)}/*bCommit*/, /*bCancel*/ ) //'Elegiveis/Inscritos' 

	// Adiciona ao modelo um componente de formulário
	oModel:addFields('MasterBLZ',/*cOwner*/,oStrBLZ)  

	// Adiciona ao modelo uma componente de grid
	oModel:AddGrid('BLYDetail', 'MasterBLZ', oStrBLY)

	// Define a quantidade maxima de linhas em um componente Grid, Pois por padrão a quantidade máxima é 990.
	oModel:GetModel('BLYDetail'):SetMaxLine(99999)

	// Faz relacionamento entre os componentes do model
	oModel:SetRelation( 'BLYDetail', { { 'BLY_FILIAL', 'xFilial( "BLY" )' } ,{ 'BLY_CODINT', 'BLZ->BLZ_CODINT' } ,{ 'BLY_CODRDA', 'BLZ->BLZ_CODRDA' } ,{ 'BLY_CODPAD', 'BLZ->BLZ_CODPAD' } ,{ 'BLY_CODPRO', 'BLZ->BLZ_CODPRO' },{ 'BLY_VERSAO', 'BLZ->BLZ_VERSAO' }}, BLY->( IndexKey( 3 ) ) )  

	oModel:SetPrimaryKey( {"BLZ_FILIAL", "BLZ_CODINT", "BLZ_CODRDA", "BLZ_CODPAD", "BLZ_CODPRO", "BLZ_VERSAO"} )

	oStrBLZ:SetProperty( 'BLZ_VERSAO' , MODEL_FIELD_INIT,  { || Iif(Inclui,"001",BLZ->BLZ_VERSAO) } )
	oStrBLZ:SetProperty( "BLZ_VIGINI" , MODEL_FIELD_VALID, { || pls587VlDt(oModel:GetValue("MasterBLZ","BLZ_VIGINI"),oModel:GetValue("MasterBLZ","BLZ_VIGFIM")) })
	oStrBLZ:SetProperty( "BLZ_VIGFIM" , MODEL_FIELD_VALID, { || pls587VlDt(oModel:GetValue("MasterBLZ","BLZ_VIGINI"),oModel:GetValue("MasterBLZ","BLZ_VIGFIM")) })

	oStrBLY:SetProperty( 'BLY_VERSAO' , MODEL_FIELD_INIT,  { || Iif(Inclui,"001",BLZ->BLZ_VERSAO) } )
	oStrBLY:SetProperty( "BLY_VALFIX" , MODEL_FIELD_WHEN,  { || .T. } )
	oStrBLY:SetProperty( "BLY_VIGDE"  , MODEL_FIELD_VALID, { || pls587VlDt(oModel:GetValue("BLYDetail","BLY_VIGDE"),oModel:GetValue("BLYDetail","BLY_VIGATE")) })
	oStrBLY:SetProperty( "BLY_VIGATE" , MODEL_FIELD_VALID, { || pls587VlDt(oModel:GetValue("BLYDetail","BLY_VIGDE"),oModel:GetValue("BLYDetail","BLY_VIGATE")) })
	

Return oModel // Retorna o Modelo de dados

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
RDA x Pacotes
@author Oscar Zanin
@since 04/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	// Interface de visualização construída
	Local oView 

	// Carrega o model existente
	Local oModel := FWLoadModel( 'PLSA587' )

	// Cria as estruturas a serem usadas na View 
	Local oStrBLZ:= FWFormStruct(2, 'BLZ', { |cCampo| PlsBLZView(cCampo) })
	Local oStrBLY:= FWFormStruct(2, 'BLY', { |cCampo| PlsBLYView(cCampo) })

	oView := FWFormView():New() // Cria o objeto de View

	// Define qual Modelo de dados será utilizado
	oView:SetModel(oModel)

	// Adiciona nas views um controle do tipo formulário 
	oView:AddField('ViewBLZ' , oStrBLZ,'MasterBLZ' ) 
	oView:AddGrid( 'ViewBLY' , oStrBLY,'BLYDetail' ) 

	// Cria um "box" horizontal para receber cada elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 40 ) 
	oView:CreateHorizontalBox( 'INFERIOR1', 60 ) 

	//Atribui a cada view os respectivos "box" criados acima
	oView:SetOwnerView('ViewBLZ','SUPERIOR') 
	oView:SetOwnerView('ViewBLY','INFERIOR1')

	//Filtro de pesquisa
	oView:SetViewProperty("BLYDetail", "GRIDFILTER", {.T.})
	oView:SetViewProperty("BLYDetail", "GRIDSEEK", {.T.})

    //Ordem dos campos (BLZ)
	oStrBLZ:SetProperty( 'BLZ_CODINT'  , MVC_VIEW_ORDEM, "00" )
	oStrBLZ:SetProperty( 'BLZ_DESINT'  , MVC_VIEW_ORDEM, "01" )
    oStrBLZ:SetProperty( 'BLZ_CODRDA'  , MVC_VIEW_ORDEM, "02" )
    oStrBLZ:SetProperty( 'BLZ_NOMRDA'  , MVC_VIEW_ORDEM, "03" )
    oStrBLZ:SetProperty( 'BLZ_CODPAD'  , MVC_VIEW_ORDEM, "04" )
    oStrBLZ:SetProperty( 'BLZ_CODPRO'  , MVC_VIEW_ORDEM, "05" )
    oStrBLZ:SetProperty( 'BLZ_DESPRO'  , MVC_VIEW_ORDEM, "06" )
	oStrBLZ:SetProperty( 'BLZ_VIGINI'  , MVC_VIEW_ORDEM, "07" )
	oStrBLZ:SetProperty( 'BLZ_VIGFIM'  , MVC_VIEW_ORDEM, "08" )
	oStrBLZ:SetProperty( 'BLZ_DTNEGO'  , MVC_VIEW_ORDEM, "09" )

    //Tornando campos editáveis apenas quando for inclusão
	oStrBLZ:SetProperty( 'BLZ_CODINT'  , MVC_VIEW_CANCHANGE, Iif(Inclui .AND. !lReajuste,.T.,.F.) )
    oStrBLZ:SetProperty( 'BLZ_CODRDA'  , MVC_VIEW_CANCHANGE, Iif(Inclui .AND. !lReajuste,.T.,.F.) )
    oStrBLZ:SetProperty( 'BLZ_CODPAD'  , MVC_VIEW_CANCHANGE, Iif(Inclui .AND. !lReajuste,.T.,.F.) )
    oStrBLZ:SetProperty( 'BLZ_CODPRO'  , MVC_VIEW_CANCHANGE, Iif(Inclui .AND. !lReajuste,.T.,.F.) )
	oStrBLZ:SetProperty( 'BLZ_VIGINI'  , MVC_VIEW_CANCHANGE, Iif(Inclui .AND. !lReajuste,.T.,.F.) )
	oStrBLZ:SetProperty( 'BLZ_VIGFIM'  , MVC_VIEW_CANCHANGE, Iif(Vazio(BLZ_VIGFIM) .OR. BLZ_VIGFIM >= dDataBase ,.T.,.F.) )
	
	//Ordem dos campos na grid (BLY)
	oStrBLY:SetProperty( 'BLY_CPADOC'  , MVC_VIEW_ORDEM, "00" )
	oStrBLY:SetProperty( 'BLY_CODOPC'  , MVC_VIEW_ORDEM, "01" ) 
	oStrBLY:SetProperty( 'BLY_DESOPC'  , MVC_VIEW_ORDEM, "02" ) 
	oStrBLY:SetProperty( 'BLY_VALFIX'  , MVC_VIEW_CANCHANGE, .T. ) 
	oStrBLY:SetProperty( 'BLY_TIPO'    , MVC_VIEW_CANCHANGE, .F. )
	
Return oView 

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS587Veri
Chamado pelo menuDef:
- nOpc: 4 = Alterar
@author Oscar Zanin
@since 04/09/2020
@version P12
/*/
//-------------------------------------------------------------------
function PLS587Veri(nOpc, ctitulo, lAutoma)
	Default lAutoma := .F.	 

	If nOpc == 4 .AND. ( empty(BLZ->BLZ_STATUS) .OR. !lPLSUNI)
		oExecView := FWViewExec():New() 		//Criamos o objeto que abre a View
		oExecView:SetTitle(ctitulo) 			//Define título da Janela
		oExecView:SetSource('PLSA587') 			//Definimos o Model que iremos utilizar
		oExecView:SetModal(.F.) 				//View não abre em janela Modal
		oExecView:SetCloseOnOk({|| .T.}) 		//A tela irá fechar ao confirmar o Ok
		oExecView:SetOperation(nOpc) 			//Como sempre haverá um registro, o cadastro abre sempre como alteração
		iif(!lAutoma, oExecView:OpenView(.F.), '') //Abrimos o cadastro
	elseIf nOpc == 4 .AND. !empty(BLZ->BLZ_STATUS) .AND. lPLSUNI
		if !lAutoma
			MsgAlert(STR0004) //"Alteração não permitida. Já foi gerado o PTUA1200 para este registro."
		EndIf
	endIf

return


//-------------------------------------------------------------------
/*/{Protheus.doc} pl587Reaju
RDA x Pacotes - Reajuste
Esta rotina cria um novo registro na BLZ e BLY, carregando os dados do último pacote vigente.
Ao final, ele fecha a vigência anterior com a Data de início - 1.
OBS: foi usada a operação de Cópia para criar o novo registro.
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
function pl587Reaju(lAutoma)

	Local aArea         := GetArea()
	Local cTitulo       := ""
	Local cPrograma     := ""
	Local nOperation    := 0
	Local cCodInt		:= BLZ->BLZ_CODINT
	Local cCodRda       := BLZ->BLZ_CODRDA
	Local cCodPad       := BLZ->BLZ_CODPAD
	Local cCodPro		:= BLZ->BLZ_CODPRO
	Local cVigFim		:= BLZ->BLZ_VIGFIM
	Local cVersao		:= BLZ->BLZ_VERSAO
	Local cSql			:= ""
	
	Local nLin			:= 0
	Local nTamanGrid	:= 0
	Local lRet			:= .T.
	Local nRet			:= 0
	Local lPerg			:= .T.

	Local aParamBox		:= {}
	Local aParam		:= {}
	Local lCentered     := .T.
	Local dDataIni		:= dDatabase
	Local cTpProc		:= ""
	
	
	Default lAutoma := .F.	 

	If !empty(cVigFim) .AND. cVigFim < dDataBase 
		if !lAutoma
			MsgAlert(STR0005) //"Vigência finalizada. Selecione um registro válido."
		EndIf
		lRet := .F.
	endIf

	If lRet
		cTitulo      := STR0014 //Reajuste de Pacotes
		cPrograma    := 'PLSA587'
		nOperation   := MODEL_OPERATION_INSERT

		aAdd( aParamBox,{ 1, STR0045, dDataIni, "", "", "", "", 50, .f.}) //Data Vigência Inicial:

		if !lAutoma	
			lPerg := ParamBox(aParamBox, cTitulo,@aParam ,,, lCentered,,, /*oMainDlg */, , , )
		Else
			aParam := {dDatabase}
		endif

		If lPerg

			lReajuste := .T.
		
			oModel := FWLoadModel( cPrograma )
			oModel:SetOperation( nOperation ) // Operaração de Inclusão.
			oModel:Activate(.T.) // Parâmetro=True : Informa se o model deve carregar os dados do registro posicionado em operações de inclusão. Essa opção é usada quando é necessário fazer uma operação de cópia.
			
			//Setando os campos do cabeçalho - BLZ.
			oModel:SetValue( "MasterBLZ", "BLZ_CODRDA", cCodRda )
			oModel:SetValue( "MasterBLZ", "BLZ_CODPAD", cCodPad )
			oModel:LoadValue("MasterBLZ", "BLZ_CODPRO", cCodPro ) //loadValue não executa os Valids e Gatilhos do campo.
			oModel:SetValue( "MasterBLZ", "BLZ_VIGINI", aParam[1] )
			oModel:SetValue( "MasterBLZ", "BLZ_DTNEGO", aParam[1] )
			oModel:SetValue( "MasterBLZ", "BLZ_VERSAO", Soma1(IIF(empty(BLZ->BLZ_VERSAO), "001", BLZ->BLZ_VERSAO)) )

			//Pegando os dados do filho - BLY.
			oModelGrid := oModel:GetModel("BLYDetail")
			nTamanGrid := Len(oModelGrid:aDataModel)

			For nLin := 1 To nTamanGrid
				oModelGrid:SetLine(nLin) //Setando a linha atual.
				If !Empty( oModelGrid:GetValue("BLY_VIGATE") ) .AND. oModelGrid:GetValue("BLY_VIGATE") <= aParam[1]
					oModelGrid:deleteline() //apaga BLY que tiver vigência encerrada antes de copiar.
				ElseIf !Empty( oModelGrid:GetValue("BLY_CODOPC") )
					oModelGrid:LoadValue("BLY_VIGDE", aParam[1]) //carrega a nova data de vigência inicial.
				EndIF
				oModelGrid:loadValue("BLY_VERSAO", oModel:GetValue( 'MasterBLZ', 'BLZ_VERSAO' )) //carrega a nova versão.

				// De-Para para carregar o tipo de procedimento:
				If Empty(oModelGrid:GetValue("BLY_TIPO"))
					cTpProc := RetBLYTipo(oModelGrid:GetValue("BLY_CPADOC"), oModelGrid:GetValue("BLY_CODOPC"))
					If cTpProc == "6"
						Loop
					EndIf
					oModelGrid:LoadValue("BLY_TIPO", cTpProc )
				EndIf

			Next nLin
			oModelGrid:SetLine(1)  

			if !lAutoma	
				//Executando a visualização dos dados para manipulação, passando o nOperation=inclusao e o oModel.
				nRet := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,/*bOk*/ , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, oModel )
			Else
				If oModel:VldData()
					oModel:CommitData()
				EndIf
				nRet := 0
			EndIf
			oModel:DeActivate()
			
			If nRet == 0 // Confirmada o reajuste, fecha a vigência anterior.
				cSql := " UPDATE " + RetSQLName('BLZ') + " SET BLZ_VIGFIM = '" + dtos(aParam[1]-1) + "' "
				cSql += "    WHERE BLZ_FILIAL = '" + xFilial('BLZ') + "' "
				cSql += "      AND BLZ_CODINT = '" + cCodInt + "' "
				cSql += "      AND BLZ_CODRDA = '" + cCodRda + "' "
				cSql += "      AND BLZ_CODPAD = '" + cCodPad + "' "
				cSql += "      AND BLZ_CODPRO = '" + cCodPro + "' "
				cSql += "      AND BLZ_VERSAO = '" + cVersao + "' "	
				cSql += "      AND D_E_L_E_T_ = ' ' "
				TCSQLExec(cSql)

				cSql := " UPDATE " + RetSQLName('BLY') + " SET BLY_VIGATE = '" + dtos(aParam[1]-1) + "' "
				cSql += "    WHERE BLY_FILIAL = '" + xFilial('BLY') + "' "
				cSql += "      AND BLY_CODINT = '" + cCodInt + "' "
				cSql += "      AND BLY_CODRDA = '" + cCodRda + "' "
				cSql += "      AND BLY_CODPAD = '" + cCodPad + "' "
				cSql += "      AND BLY_CODPRO = '" + cCodPro + "' "
				cSql += "      AND BLY_VERSAO = '" + cVersao + "' "	
				cSql += "      AND D_E_L_E_T_ = ' ' "
				TCSQLExec(cSql)

			EndIf

		EndIf //paramBox
	EndIf //lRet

	RestArea(aArea)
	lReajuste := .F.

return

//-------------------------------------------------------------------
/*/{Protheus.doc} pl587ExReaj
Ao excluir um reajuste, deve abrir a vigência anterior.
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
function pl587ExReaj(lAutoma)

	Local cTitulo       := ""
	Local cPrograma     := ""
	Local nOperation    := 0
	Local cCodInt		:= BLZ->BLZ_CODINT
	Local cCodRda       := BLZ->BLZ_CODRDA
	Local cCodPad       := BLZ->BLZ_CODPAD
	Local cCodPro		:= BLZ->BLZ_CODPRO
	Local cVigFim		:= BLZ->BLZ_VIGFIM
	Local cVersao		:= BLZ->BLZ_VERSAO
	Local cSql			:= ""

	Default lAutoma := .F.	 

	If empty(cVigFim) .OR. cVigFim >= dDataBase

		cTitulo		:= STR0014 //Reajuste de Pacotes
		cPrograma	:= 'PLSA587'
		nOperation	:= MODEL_OPERATION_DELETE

		oExecView := FWViewExec():New() 		//Criamos o objeto que abre a View
		oExecView:SetTitle(ctitulo) 			//Define título da Janela
		oExecView:SetSource(cPrograma) 			//Definimos o Model que iremos utilizar
		oExecView:SetModal(.F.) 				//View não abre em janela Modal
		oExecView:SetCloseOnOk({|| .T.}) 		//A tela irá fechar ao confirmar o Ok
		oExecView:SetOperation(nOperation) 		//Como sempre haverá um registro, o cadastro abre sempre como alteração
		iif(!lAutoma, oExecView:OpenView(.F.), '') //Abrimos o cadastro

		If lAutoma .OR. oExecView:getButtonPress() == VIEW_BUTTON_OK
			If cVersao <> "001"
				cSql := " UPDATE " + RetSQLName('BLZ') + " SET BLZ_VIGFIM = ' ' "
				cSql += "    WHERE BLZ_FILIAL = '" + xFilial('BLZ') + "' "
				cSql += "      AND BLZ_CODINT = '" + cCodInt + "' "
				cSql += "      AND BLZ_CODRDA = '" + cCodRda + "' "
				cSql += "      AND BLZ_CODPAD = '" + cCodPad + "' "
				cSql += "      AND BLZ_CODPRO = '" + cCodPro + "' "
				cSql += "      AND BLZ_VERSAO = '" + Tira1(cVersao) + "' "	
				cSql += "      AND D_E_L_E_T_ = ' ' "
				TCSQLExec(cSql)

				cSql := " UPDATE " + RetSQLName('BLY') + " SET BLY_VIGATE = ' ' "
				cSql += "    WHERE BLY_FILIAL = '" + xFilial('BLY') + "' "
				cSql += "      AND BLY_CODINT = '" + cCodInt + "' "
				cSql += "      AND BLY_CODRDA = '" + cCodRda + "' "
				cSql += "      AND BLY_CODPAD = '" + cCodPad + "' "
				cSql += "      AND BLY_CODPRO = '" + cCodPro + "' "
				cSql += "      AND BLY_VERSAO = '" + Tira1(cVersao) + "' "	
				cSql += "      AND D_E_L_E_T_ = ' ' "
				TCSQLExec(cSql)

			EndIf
		Endif

	elseIf !empty(cVigFim) .AND. cVigFim < dDataBase 
		if !lAutoma
			MsgAlert(STR0005) //"Vigência finalizada. Selecione um registro válido."
		EndIf
	endIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Pl587Stat
Retorna os status para os Itens de Pacote
Está no X3_CBOX do campo BLZ_STATUS
OBS: Esta função foi criada pois o tamanho do X3_CBOX era insuficiente
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Pl587Stat()
	LOCAL cStatus := ""

	cStatus := "1=Em construção;2=Em análise Administrativo;3=Em análise Médico;4=Em análise Enfermeiro;5=Em análise Supervisor;6=Exigência;7=Aprovado;8=Aprovado com ressalva;9=Publicado sem Aprovação;10=Reprovado;11=Reprovado Vigente;12=Cancelado;13=Inválido;14=Suspenso;15=Bloqueado;16=Duplicado;17=Reajuste em Análise;18=Expirado"
Return(cStatus)

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBLZView
Tratamento para definir os campos da BLZ que não serão usados na View
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PlsBLZView (cCampo)
	Local lRet	:= .T.
	cCampo := Alltrim(cCampo)

	If cCampo $ "BLZ_DTPUBL|BLZ_CDEDI|BLZ_NMEDI|BLZ_TIPACO|BLZ_TIPPAC|BLZ_ESPEC|BLZ_TIPINT|BLZ_IDANES|BLZ_IDAUX|BLZ_IDHON|BLZ_STATUS|BLZ_TPCARG" 
		If !lPLSUNI
			lRet := .F.
		EndIf 
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsBLYView
Tratamento para definir os campos da BLY que não serão usados na View
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PlsBLYView (cCampo)
	Local lRet	:= .T.
	cCampo := Alltrim(cCampo)

	If cCampo $ "BLY_VALCH|BLY_COMPAR|BLY_VERSAO|BLY_VIGDE|BLY_VIGATE" 
		lRet := .F.
	EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetBLYDesc
Atualiza descrição do procedimento quando o código é digitado
Está no X3_VALID do campo BLY_CODOPC
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION RetBLYDesc()
	Local cCodTbPrc := ""
	
	cCodTbPrc := xFilial("BR8") + FwFldGet("BLY_CPADOC") + FwFldGet("BLY_CODOPC")
	FWFldPut("BLY_DESOPC", SubStr(ALLTRIM(Posicione("BR8",1,cCodTbPrc,"BR8_DESCRI")),1,30) )

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} RetBLYTipo
De-Para para carregar o tipo de procedimento:
	BLY_TIPO:	0=Procedimentos;1=Medicamentos;2=Materiais;3=Taxas;4=Diarias;5=Ortese/Protese;7=Gases Medicinais;8=Alugueis;9=Outros
	BR8_TPPROC:	0=Procedimento;1=Material;2=Medicamento;3=Taxas;4=Diarias;5=Ortese/Protese;6=Pacote;7=Gases Medicinais;8=Alugueis;9=Outros
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION RetBLYTipo(cCPADOC, cCODOPC)
	Local cTpProc := ""

	BR8->(DbSetOrder(1))
	If BR8->(MsSeek(xFilial("BR8")+cCPADOC+cCODOPC))
		cTpProc := BR8->BR8_TPPROC
		If cTpProc == "1"
			cTpProc := "2"
		ElseIf cTpProc == "2"
			cTpProc := "1"
		EndIf
	EndIf

Return cTpProc

//-------------------------------------------------------------------
/*/{Protheus.doc} LoadBLYTipo
Carrega o tipo do procedimento (BLY_TIPO) quando o código é digitado
Está no X3_VALID do campo BLY_CODOPC
@author Silvia Sant'Anna
@since 11/2020
@version P12
/*/
//-------------------------------------------------------------------
FUNCTION LoadBLYTipo()
	Local lPacote	:= .F.
	Local cTipo		:= ""

	cTipo := RetBLYTipo(FwFldGet("BLY_CPADOC"), FwFldGet("BLY_CODOPC"))
	iF cTipo == "6"
		lPacote := .T.
	EndIf

	If !lPacote
		FWFldPut("BLY_TIPO", cTipo )
	EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} pls587VlDt
Valida se a data de validade inicial não é maior do que a data final. 
@author Silvia Sant'Anna
@since 12/2020
@version P12
/*/
//-------------------------------------------------------------------
Function pls587VlDt (dDatIn,dDatFin)
	Local lRet		:= .T.
	Local dDataFin	:= ""

	dDataFin := ALLTRIM(DTOS(dDatFin))

	If !Empty(dDataFin) .And. dDatFin < dDatIn
		lRet := .F.
		MsgInfo(STR0001, STR0002) //"A data de validade inicial não pode ser maior do que a data final." ### "Atenção"
	Endif
 
Return (lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Pl587Valid
Função que faz a validação e carrega os dados do grid quando o código do pacote é informado.
Está no X3_VALID do campo BLZ_CODPRO
@author Silvia Sant'Anna
@since 12/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Pl587Valid()
	Local oModel		:= nil
    Local lRet      	:= .T.
    Local nI        	:= 0
	Local nJ        	:= 0
    Local cCodint   	:= ""
    Local ccodpad   	:= ""
    Local ccodpro   	:= ""
    Local ccodrda   	:= ""
    Local oGridBLY  	:= nil
    Local acmpBLE   	:= {}

	oModel := FwModelActive()

    cCodint := oModel:getModel("MasterBLZ"):getValue("BLZ_CODINT")
    ccodpad := oModel:getModel("MasterBLZ"):getValue("BLZ_CODPAD")
    ccodpro := oModel:getModel("MasterBLZ"):getValue("BLZ_CODPRO")
    ccodrda := oModel:getModel("MasterBLZ"):getValue("BLZ_CODRDA")
    oGridBLY:= oModel:getModel("BLYDetail")
    acmpBLE := eval( { || dbSelectArea("BLE"), dbStruct() }) //Para pegar os campos do BLE. Este método não carrega os campos Virtuais.

	BLD->(DbSetOrder(1))//BLD_FILIAL, BLD_CODINT, BLD_CODPAD, BLD_CODPRO
	If !BLD->(MsSeek( xFilial("BLD") + cCodint+ccodpad+ccodpro ) )
		Aviso( OemtoAnsi(STR0007), OemtoAnsi(STR0008)  + Chr(13) + Chr(10) + OemtoAnsi(ccodpad) + "-" + OemtoAnsi(ccodpro) , { STR0009 }, 2 ) //"Procedimento Invalido" ### "Nao existe no cadastro de procedimento x pacote este procedimento! " ### "Ok"
		lRet:= .F. 
	Endif

	If lRet
		lRet := BLZ->(ExistChav("BLZ",cCodint+ccodrda+ccodpad+ccodpro ,1))
		If lRet
			BLE->(DbSetOrder(1))
			If BLE->(MsSeek(xFilial("BLE")+cCodint+ccodpad+ccodpro))
				// Para regarrecar os itens caso o código no cabeçalho fosse alterado. 
				// Irá deletar os atuais e incluir os novos
				For nJ := 1 to oGridBLY:length()
					oGridBLY:goline(nJ)
					oGridBLY:deleteline()
				Next

				While !BLE->(Eof()) .and. xFilial("BLE")+cCodint+ccodpad+ccodpro == BLE->(BLE_FILIAL+BLE_CODINT+BLE_CODPAD+BLE_CODPRO)
					oGridBLY:addLine() //adiciona linha na grid
					oGridBLY:goLine(oGridBLY:length()) //pra ele não gravar sempre a mesma linha

					For nI:=1 to Len(acmpBLE)
						cCampo := acmpBLE[nI,1]
						If BLE->( FieldPos( cCampo ) ) == 0 .OR. ;
							( StrTran(cCampo,'BLE','BLY') $ "BLY_FILIAL|BLY_CODINT|BLY_CODRDA|BLY_CODPAD|BLY_CODPRO|BLY_VERSAO" ) //|BLY_TIPO|BLY_QTDPAC
							Loop
						EndIf

						oGridBLY:loadValue( StrTran(cCampo,'BLE','BLY'), &('BLE->'+cCampo) )
						If StrTran(cCampo,'BLE','BLY') == "BLY_CODOPC" 
							oGridBLY:loadValue( "BLY_DESOPC", SubStr(AllTrim(Posicione("BR8",1,xFilial("BR8")+BLE->BLE_CPADOC+BLE->BLE_CODOPC,"BR8_DESCRI")),1,30) )
						EndIf

						// De-Para para carregar o tipo de procedimento:
						If StrTran(cCampo,'BLE','BLY') == "BLY_TIPO"  //Empty(oGridBLY:GetValue("BLY_TIPO"))
							cTpProc := RetBLYTipo(BLE->BLE_CPADOC, BLE->BLE_CODOPC)
							If cTpProc == "6"
								Loop
							EndIf
							oGridBLY:LoadValue("BLY_TIPO", cTpProc )
						EndIf
					Next
					BLE->( DbSkip() )
				Enddo
				//oGridBLY:refresh("BLYDetail") // Cannot find method FWFORMGRIDMODEL:REFRESH on PL587VALID(PLSA587.PRW)
				oGridBLY:SetLine(1)  
			Endif
		Endif
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} pl587VldOk
Valida a inclusão do Registro.
Chamada pelo bPosValidacao do ModelDef.
@since 12/2020
@version P12
/*/
//-------------------------------------------------------------------
Function pl587VldOk(oModel,lAutoma)
	Local lRet			:= .T.
	Local oBLZ			:= oModel:getModel("MasterBLZ")
	Local oGridBLY		:= oModel:getModel("BLYDetail")
	Local nQtPrincip	:= 0
	Local nI 			:= 0
	Local nOperation	:= oModel:GetOperation()
	local cChaveUn		:= ""
	local lReaUsuC		:= oBLZ:getValue("BLZ_REAJUS") == "1"
	local lCmpReaj		:= BLZ->(fieldPos("BLZ_REAJUS")) > 0

	Default lAutoma 	:= iif( isBlind(), .t., .F.)	 

	If nOperation <> MODEL_OPERATION_DELETE 
		for nI := 1 to oGridBLY:length()
			oGridBLY:goline(nI)
			if oGridBLY:getValue("BLY_PRINCI") == "1"
				nQtPrincip ++
			endIf
			// As datas de vigência dos itens (BLY) deverão ser as mesmas informadas no cabeçalho (BLZ)
			oGridBLY:LoadValue( 'BLY_VIGDE' , oBLZ:getValue("BLZ_VIGINI") )	
			oGridBLY:LoadValue( 'BLY_VIGATE', oBLZ:getValue("BLZ_VIGFIM") )
		next
		If nQtPrincip > 1
			If !lAutoma
				MsgAlert(STR0003,STR0002) //"Existe mais de um procedimento Principal cadastrado neste pacote." ### "Atencao"
			EndIf
			lRet := .F.
		EndIf
	EndIf

	//Verifica se é um reajuste, perguntando ao final
	if ( lRet .and. lPLSUNI .and. !lAutoma .and. lCmpReaj)
		if ( oModel:GetOperation() == MODEL_OPERATION_INSERT )
			if ( lReajuste .or. lReaUsuC .or. (empty(oBLZ:getValue("BLZ_REAJUS")) .and. msgyesno(STR0010)) )//"É reajuste de pacote? Se sim, é necessário anexar um contrato para o PTU A1200"
				cChaveUn := PlRetValCh(oBLZ, cAliPad)
				PLArqInc(lAutoma, oBLZ:getValue("BLZ_CODRDA"), cChaveUn, oBLZ)
				nSeque := 1
			endif
		elseif ( oModel:GetOperation() == MODEL_OPERATION_DELETE .and. !empty(oBLZ:getValue("BLZ_ARQREA")) )
			PlSrcBC587( {"D", StrTokArr2(oBLZ:getValue("BLZ_ARQREA"), "-")} )	
		endif
	endif
	lReajuste := .f.
Return (lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} pl587StPac
Atualiza o status do pacote selecionado com base no retorno do webservice.
Chama a função consPacUni() do fonte PLSUA1200.
/*/
//-------------------------------------------------------------------
function pl587StPac(lAutoma)
	Local cCodInt		:= BLZ->BLZ_CODINT
	Local cCodRda       := BLZ->BLZ_CODRDA
	Local cCodPad       := BLZ->BLZ_CODPAD
	Local cCodPro		:= BLZ->BLZ_CODPRO
	Local cDtVigIni		:= BLZ->BLZ_VIGINI
	Local cDtVigFim		:= BLZ->BLZ_VIGFIM
	Local cDatRef		:= ""
	Local lRet			:= .F.
	Local lVigencia		:= .T.
	Local lSchedule		:= .F.

	Default lAutoma := .F.	

	If !empty(cDtVigFim) .AND. cDtVigFim < dDataBase 
		If !lAutoma
			MsgAlert(STR0005) //"Vigência finalizada. Selecione um registro válido."
		EndIf
		lVigencia := .F.
	endIf

	If lVigencia

		cDatRef		:= DTOS(dDataBase)
		cDatRef		:= Substr(cDatRef,1,4) + "-" + Substr(cDatRef,5,2) + "-" + Substr(cDatRef,7,2) // Formatado YYYY-MM-DD

		cDtVigIni	:= DTOS(cDtVigIni)
		cDtVigIni	:= Substr(cDtVigIni,1,4) + "-" + Substr(cDtVigIni,5,2) + "-" + Substr(cDtVigIni,7,2) // Formatado YYYY-MM-DD

		lRet := consPacUni(cCodInt,cCodRda,cCodPad,cCodPro,cDatRef,cDtVigIni,lSchedule,lAutoma)
		If lRet .AND. !lAutoma
			MsgInfo(STR0006) //"O Status do pacote selecionado foi atualizado com sucesso." 
		EndIf
	EndIf 
Return



//-------------------------------------------------------------------
/*/{Protheus.doc} PLArqInc
Ao confirmar, indaga o usuário se é um reajuste e se deseja incluir os arquivos de contrato.
Since: 05/2021 
/*/
//-------------------------------------------------------------------
static function PLArqInc(lAutoma, cCodRda, cChave, oModel, cLocAuto)
local cArqInc		:= ""
local cArqGrv		:= ""
local lContinua		:= .t.
local lRetMsg		:= .t.
default oModel		:= nil
default lAutoma		:= .f.
default cLocAuto	:= plsmudsis("/schemas/") 

while lContinua
	cArqInc := ""
	cArqInc := iif( !lAutoma, cGetFile("*.*", STR0011, 0, "", .f., GETF_LOCALHARD+GETF_NETWORKDRIVE,.t.), cLocAuto) //Selecione o arquivo:
	cArqGrv += iif( !empty(cArqInc), PlNewNive4(cArqInc, cCodRda, "", cAliPad, cChave) + "-", "")
	lRetMsg := iif( !lAutoma, msgYesNo(STR0012), .f.) //"Adicionar mais arquivos?"
	if ( (!empty(cArqGrv) .and. !lRetMsg) .or. lAutoma )
		lContinua := .f.
		oModel:setValue("BLZ_REAJUS", "1")
		oModel:setValue("BLZ_ARQREA", substr(cArqGrv, 1, len(cArqGrv)-1))
	elseif ( (empty(cArqGrv) .and. !lRetMsg .and. !lAutoma) )
		MsgAlert(STR0046,STR0002)
	endif
enddo

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlNewNive4
Função que renomeia o arquivo, para o formato de 4º nível do manual de PTU, e copia para a base de conhecimento,
bem como é chamado na exclusão, para excluir o arquivo e registros pertinentes.
  FORMATO: PCRaammncccccccccccccccss.ext  ==  Nível 4 – Anexo válido para o reajuste de prestador (R205) 
  Espaços em branco devem ser preenchidos com "_"
  PC – indica anexo do arquivo de pacote / R – Indicação de reajuste / aamm – ano e mês da geração
  n – nível do anexo (1, 2, 3, 4 ou 5) / pppppppp – código do pacote / ccccccccccccccc – número do cpf/cnpj do prestador
  ss - sequencial de 01 a 99 no mesmo dia / ext – extensão
Since: 05/2021 
/*/
//-------------------------------------------------------------------
static function PlNewNive4(cArqInc, cCodRda, cNomeServ, cAlias, cChaveUn, aDelete)
local cNomeArq		:= ""
local aAreaBAU		:= BAU->(getarea())
local cCpfCnpj		:= ""
local cExten		:= ""
local cFile			:= ""
local cDirDocs		:= ""
local lRet			:= .t.
default cNomeServ	:= ""
default cAlias		:= cAliPad
default aDelete		:= {}

//Dados do Banco de Conhecimento
splitPath( cArqInc,,, @cFile, @cExten )
if findFunction( "MsMultDir" ) .and. MsMultDir()
	cDirDocs := MsRetPath( cFile+cExten )
else
	cDirDocs := MsDocPath()
endIf

if empty(aDelete)
	// CPF/CNPJ RDA
	if !empty(cCodRda)
		BAU->(dbsetorder(1))
		if BAU->( MsSeek(xFilial("BAU") + cCodRda) )
			cCpfCnpj := padl(alltrim(BAU->BAU_CPFCGC), cTamBAU, "0")
		endif	
	endif 

	//Nome default nível 4 - PCRaammncccccccccccccccss.ext
	cNomeArq := iif( empty(cNomeServ), "PCR" + cAno + cMes + "4" + cCpfCnpj + strzero(nSeque,2) + cExten, cNomeServ )
	nSeque++

	//grava no banco de conhecimento / "Transferindo objeto" / "Aguarde..." 
	Processa( { || __CopyFile( PLSMUDSIS(cArqInc), PLSMUDSIS(cDirDocs + "\" + cNomeArq) ), lRet := File( PLSMUDSIS(cDirDocs + "\" + cNomeArq) ) }, STR0047, STR0048,.F.)
endif 

if lRet	
	PlSrcBC587({"I", cNomeArq, cAlias, cChaveUn })  
else
	Help(nil, nil , STR0002, nil, STR0015, 1, 0, nil, nil, nil, nil, nil, {''} ) //Atenção / Erro ao anexar/excluir do Banco de Conhecimento
endif 

RestArea(aAreaBAU)
return cNomeArq


//-------------------------------------------------------------------
/*/{Protheus.doc} PlBcCon587
Chama o Banco de conhecimento  para o registro selecionado
Since: 05/2021 
/*/
//-------------------------------------------------------------------
Function PlBcCon587() 
Private aRotina := {}
aAdd( aRotina, { STR0016, 	"MsDocument", 0, 2 } ) //"Visualizar"
MsDocument(cAliPad, BLZ->( RecNo() ), 1 )
return 


//-------------------------------------------------------------------
/*/{Protheus.doc} PlRetValCh
Retorna o X2_UNICO da tabela ou índice, para servir como base de pesquisa, ao incluir o arquivo no Banco.
Since: 05/2021 
/*/
//-------------------------------------------------------------------
static function PlRetValCh(oModel, cTabela)
local aChaveTab	:= separa(PLGETUNIC(cTabela)[2], "+")
local cChaveRet	:= ""
local nFor 		:= 0

for nFor  := 1 to len(aChaveTab)
	cChaveRet += iif( ("_FILIAL" $ aChaveTab[nfor]), xFilial(cTabela), oModel:getValue(alltrim(aChaveTab[nfor])) )
next

return cChaveRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlSrcBC587
Função centralizadora de gravação, deleção e pesquisa de dados no Banco de Conhecimento
Recebe: aDadosPesq, de acordo com a ação, definida na primeira posição:
- Se for inclusão: 			{ "I" (Inclusão), Nome Arquivo, Alias, ChaveUnica }
- Se for deleção : 			{ "D" (Deleta)	, {Arquivos} }
- Se for Pesquisa e copia: 	{ "P" (pesquisa), {Arquivos}, Diretório final, cA1200PTU }
Since: 05/2021 
/*/
//-------------------------------------------------------------------
function PlSrcBC587(aDadosPesq)
local cCodObj	:= ""
local nFor 		:= 0
local cFile		:= ""
local cExten	:= ""
local cDirDocs	:= ""
local lRet 		:= .f.

//Dados do Banco de Conhecimento
if ( aDadosPesq[1] == "I" )
	splitPath( aDadosPesq[2],,, @cFile, @cExten )
endif
if findFunction( "MsMultDir" ) .and. MsMultDir()
	cDirDocs := MsRetPath( cFile+cExten )
else
	cDirDocs := MsDocPath()
endIf

//Inclusão no Banco de Conhecimento
if ( upper(aDadosPesq[1]) == "I" ) 

	cCodObj := ACB->(getSXENum( "ACB", "ACB_CODOBJ" ))
	ACB->(confirmSX8())

	ACB->(DbSetOrder(1))
	while ACB->( msSeek( xFilial("ACB") + cCodObj ) )
		cCodObj := ACB->(getSXENum( "ACB", "ACB_CODOBJ" ))
		ACB->(confirmSX8())
	endDo

	ACB->( RecLock( "ACB", .T. ) )
		ACB->ACB_FILIAL  := xFilial("ACB")
		ACB->ACB_CODOBJ := cCodObj
		ACB->ACB_OBJETO := Left( Upper( aDadosPesq[2] ), Len( ACB->ACB_OBJETO ) )
		ACB->ACB_DESCRI := aDadosPesq[2]
	ACB->( MsUnlock() )

	AC9->(RecLock( "AC9", .T. ))
		AC9->AC9_FILIAL := xFilial("AC9")
		AC9->AC9_FILENT := xFilial(aDadosPesq[3])
		AC9->AC9_ENTIDA := aDadosPesq[3]
		AC9->AC9_CODENT := aDadosPesq[4]
		AC9->AC9_CODOBJ := cCodObj
	AC9->( MsUnlock() )

else
	for nFor := 1 to len(aDadosPesq[2])
		ACB->(DbSetOrder(2))
		if ( upper(aDadosPesq[1]) == "D" )
			while ACB->( MsSeek(xFilial('ACB')+Upper(aDadosPesq[2, nFor])) )
				AC9->(dbsetorder(1))
				while AC9->(MsSeek(xFilial("AC9") + ACB->ACB_CODOBJ))
					AC9->(RecLock( "AC9", .f.))
						AC9->(DbDelete())
					AC9->(MsUnlock())
				Enddo
				ACB->(RecLock("ACB", .f.))
					ACB->(DbDelete())
				ACB->(MsUnlock())
			enddo
		endif
		if file( PLSMUDSIS(cDirDocs + "\" + aDadosPesq[2, nFor]) )
			if ( upper(aDadosPesq[1]) == "D" )
				fErase( PLSMUDSIS(cDirDocs + "\" + aDadosPesq[2, nFor])) 
			else
				//copia o arquivo do servidor para a pasta informada, para compactação. / "Transferindo objeto" / "Aguarde..." 
				Processa( { || __CopyFile( PLSMUDSIS(cDirDocs + "\" + aDadosPesq[2, nFor]), PLSMUDSIS(aDadosPesq[3] + "\" + aDadosPesq[2, nFor]) ),;
					lRet := File( PLSMUDSIS(aDadosPesq[3] + "\" + [2, nFor]) ) }, STR0047, STR0048, .f.)
			endif 
		endif
	next
endif 

return
