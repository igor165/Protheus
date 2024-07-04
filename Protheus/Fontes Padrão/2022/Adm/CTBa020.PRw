#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CTBA020.CH"

Static cTipoCTS := NIL
Static __Release := NIL
//--------------------------------------------------
/*/{Protheus.doc} CTBA020
Cadastramento de Contas Contabeis - SIGACTB.

@author Pilar S Albaladejo
@since 29/10/1999
@version P12.1.18

@param array, dados do cabeçalho
@param numérico, opcao da rotina automatica
@param array, dados dos itens

@return objeto, definicoes do browse
/*/
//--------------------------------------------------
Function CTBA020()
Local oBrowse := Nil

//Retornado a variável como Private pois a função do MenuDef MSDocument()
//esta com uma validação que utiliza esse array para ver se é visualização
PRIVATE aRotina   := {}

//Carrega as variaveis estaticas
LoadVar020()

aRotina  := MenuDef()

oBrowse := BrowseDef()

//----------------------------------
// Tratamento incluso para proteger
// quando é utilizado o modo arvore
//----------------------------------
If oBrowse <> Nil
	oBrowse:Activate()
EndIf

Return

//--------------------------------------------------
/*/{Protheus.doc} BrowseDef
Tela de navegacao da rotina.

@author TOTVS
@since 24/07/2017
@version P12.1.18

@return objeto, definicoes do browse
/*/
//--------------------------------------------------
Static Function BrowseDef()
Local oMBrowse := Nil

SetFunName('CTBA020')

//---------------------------------
// Carrega o pergunte na tecla F12
//---------------------------------
SetKey(VK_F12,{|a,b|AcessaPerg("CTB020",.T.)})

//----------------------------------------------------
// Variaveis utilizadas para parametros
//----------------------------------------------------
// mv_par01 - Gera Cod. Reduz.? (Autom/Formula/Digit)
// mv_par02 - Formula Cod Reduzido
// mv_par03 - Gera Cta Sup? (Autom/Formula/Digit)
// mv_par04 - Formula Cta Sup
// mv_par05 - Cta Variacao Monetaria
// mv_par06 - Cta Redutora da Variacao
// mv_par07 - Conta de Lucros e Perdas
// mv_par08 - Conta Ponte de Lucros e Perdas
// mv_par09 - Cadastro em arvore (Nao/Sim/Perguntar)
//---------------------------------------------------
Pergunte("CTB020",.F.)

//----------------------------------------------------
// Tratamento para preservar a apresentação em arvore
//----------------------------------------------------
If MV_PAR09 == 2 .Or. (MV_PAR09 == 3 .And. MsgYesNo(STR0010)) //"Usa cadastro em arvore ?"

	CtbaTree("CT1")

Else

	DEFINE FWMBROWSE oMBrowse ALIAS "CT1" DESCRIPTION STR0006 //"Cadastro Plano de Contas"

	//-----------------------
	// Definicoes da Legenda
	//-----------------------
	oMBrowse:AddLegend("CT1_BLOQ == '1'"																																																													,"RED"		,STR0014) //"Bloqueado"
	oMBrowse:AddLegend("CT1_BLOQ == '2' .AND. ( ( Empty( CT1_DTEXIS ) .Or. CT1_DTEXIS <= dDatabase ) .AND. ( Empty( CT1_DTEXSF ) .Or. CT1_DTEXSF >= dDatabase ) ) .AND. ( ( Empty( CT1_DTBLIN ) .OR. CT1_DTBLIN >= dDatabase ) .Or. ( Empty( CT1_DTBLFI ) .Or. CT1_DTBLFI <= dDatabase ) )"	,"GREEN"	,STR0013) //"Sem Restrição"
	oMBrowse:AddLegend("CT1_BLOQ == '2' .AND. ( ! Empty( CT1_DTEXIS ) .AND. CT1_DTEXIS >= dDatabase )"																																														,"YELLOW"	,STR0015) //"Exercicio Não Inciado"
	oMBrowse:AddLegend("CT1_BLOQ == '2' .AND. ( ! Empty( CT1_DTEXSF ) .AND. CT1_DTEXSF <= dDatabase )"																																														,"GRAY"		,STR0016) //"Exercicio Finalizado"
	oMBrowse:AddLegend("CT1_BLOQ == '2' .AND. ( ( ! Empty( CT1_DTBLIN ) .AND. CT1_DTBLIN <= dDatabase ) .OR. ( ! Empty( CT1_DTBLFI ) .Or. CT1_DTBLFI >= dDatabase ) )"																														,"ORANGE"	,STR0017) //"Bloqueado no Periodo"

EndIf

Return oMBrowse

//--------------------------------------------------
/*/{Protheus.doc} MenuDef
Utilizacao de menu Funcional.

@author Paulo Carnelossi
@since 07/03/2007
@version P12.1.18

@return array, opcoes de menu da rotina
/*/
//--------------------------------------------------
Static Function MenuDef()

Local aRotina := {}
Local lPECT020ROT   := ExistBlock('CT020ROT')

ADD OPTION aRotina TITLE STR0002 ACTION 'VIEWDEF.CTBA020'	OPERATION MODEL_OPERATION_VIEW ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0003 ACTION 'VIEWDEF.CTBA020'	OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Incluir"
ADD OPTION aRotina TITLE STR0004 ACTION 'VIEWDEF.CTBA020'	OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Alterar"
ADD OPTION aRotina TITLE STR0005 ACTION 'Ctb020Excl'			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //"Excluir" 
ADD OPTION aRotina TITLE STR0034 ACTION 'Ctba020Imp'			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //"Importar"
ADD OPTION aRotina TITLE STR0035 ACTION 'Ctba020Exp'			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Exportar"
ADD OPTION aRotina TITLE STR0045 ACTION 'MSDocument'			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //"Conhecimento"

If lPECT020ROT
 	aRotina := ExecBlock("CT020ROT",.F.,.F.,{aRotina})
EndIf

Return (aRotina)

//--------------------------------------------------
/*/{Protheus.doc} ViewDef
Definições da interface grafica da rotina.

@author TOTVS
@since 25/07/2017
@version P12.1.18

@return objeto, interface grafica
/*/
//--------------------------------------------------
Static Function ViewDef()
Local oModel	:= FWLoadModel('CTBA020')
Local oStruCT1	:= FWFormStruct(2,'CT1')
Local oStruCTS	:= CTSFormVi(oModel,.F.)
Local oStruCVD	:= FWFormStruct(2,'CVD')
Local oView		:= Nil
Local cCampos	:= {}

//------------------------------------------
// Adequacoes da estrutura do submodelo CT1
//------------------------------------------
oStruCT1:SetProperty("CT1_DC",MVC_VIEW_CANCHANGE,.F.)

//--------------------------------------------------------------------------
// Adequacoes da Estrutura do submodelo CTS
// Nao foi alterado no dicionario por influenciar a apresentação da CTBA160
//--------------------------------------------------------------------------
oStruCTS:RemoveField("CTS_IDENT") //Removido pois é preenchido pelo gatilho do CTS_IDENTI

oStruCTS:SetProperty("CTS_NOME"		,MVC_VIEW_CANCHANGE,.F.)
oStruCTS:SetProperty("CTS_ORDEM"	,MVC_VIEW_CANCHANGE,.F.)


oStruCTS:SetProperty('CTS_CODPLA'	,MVC_VIEW_ORDEM ,'01')
oStruCTS:SetProperty('CTS_NOME'		,MVC_VIEW_ORDEM ,'02')
oStruCTS:SetProperty('CTS_CONTAG'	,MVC_VIEW_ORDEM ,'03')
oStruCTS:SetProperty('CTS_ORDEM'	,MVC_VIEW_ORDEM ,'04')
oStruCTS:SetProperty('CTS_LINHA'	,MVC_VIEW_ORDEM ,'05')
oStruCTS:SetProperty('CTS_FORMUL'	,MVC_VIEW_ORDEM ,'06')
oStruCTS:SetProperty('CTS_IDENTI'	,MVC_VIEW_ORDEM ,'07')
oStruCTS:SetProperty('CTS_TPSALD'	,MVC_VIEW_ORDEM ,'08')
oStruCTS:SetProperty('CTS_CTTINI'	,MVC_VIEW_ORDEM ,'09')
oStruCTS:SetProperty('CTS_CTTFIM'	,MVC_VIEW_ORDEM ,'10')
oStruCTS:SetProperty('CTS_CTDINI'	,MVC_VIEW_ORDEM ,'11')
oStruCTS:SetProperty('CTS_CTDFIM'	,MVC_VIEW_ORDEM ,'12')
oStruCTS:SetProperty('CTS_CTHINI'	,MVC_VIEW_ORDEM ,'13')
oStruCTS:SetProperty('CTS_CTHFIM'	,MVC_VIEW_ORDEM ,'14')


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Define que a tela sera um formulario continuo
oView:SetContinuousForm(.T.)

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField('VIEW_CT1', oStruCT1, 'CT1MASTER')

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid('VIEW_CVD', oStruCVD, 'CVDDETAIL')
oView:AddGrid('VIEW_CTS', oStruCTS, 'CTSDETAIL')

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox('SUPERIOR',50)
oView:CreateHorizontalBox('MEIO'	,25)
oView:CreateHorizontalBox('INFERIOR',25)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView('VIEW_CT1','SUPERIOR')
oView:SetOwnerView('VIEW_CVD','MEIO'	)
oView:SetOwnerView('VIEW_CTS','INFERIOR')

oView:EnableTitleView('VIEW_CVD')
oView:EnableTitleView('VIEW_CTS')

Return oView

//--------------------------------------------------
/*/{Protheus.doc} ModelDef
Definições do modelo de dados da rotina.

@author TOTVS
@since 25/07/2017
@version P12.1.18

@return objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function ModelDef()
Local oModel	:= Nil
Local oStruCT1	:= Nil
Local oStruCVD	:= Nil
Local oStruCTS	:= Nil


oStruCT1	:= FWFormStruct(1,"CT1")
oStruCVD	:= FWFormStruct(1,"CVD")
oStruCTS	:= CTSFormVi(nil,.T.)

//--------------------------------------------------------------
// Ajustes da estrutura da CTS
// Não foi adequado no dicionário por impactar a rotina CTBA160
//--------------------------------------------------------------
oStruCTS:AddTrigger('CTS_CODPLA','CTS_NOME',{||.T.},{|| Posicione("CVE",1,XFilial("CVE")+FWFldGet('CTS_CODPLA'),"CVE_DESCRI")})
oStruCTS:AddTrigger('CTS_IDENTI','CTS_IDENT',{||.T.},{|| FWFldGet('CTS_IDENTI')})

oStruCTS:SetProperty("CTS_NOME"		,MODEL_FIELD_WHEN,{|| .T.})
oStruCTS:SetProperty("CTS_ORDEM"	,MODEL_FIELD_WHEN,{|| .T.})


oStruCTS:SetProperty("CTS_CODPLA"	,MODEL_FIELD_OBRIGAT,.T.)
oStruCTS:SetProperty("CTS_CONTAG"	,MODEL_FIELD_OBRIGAT,.T.)
oStruCTS:SetProperty("CTS_ORDEM"	,MODEL_FIELD_OBRIGAT,.T.)
oStruCTS:SetProperty("CTS_LINHA"	,MODEL_FIELD_OBRIGAT,.T.)



//----------------------------------
// Cria o objeto do Modelo de Dados
//----------------------------------
oModel:= MPFormModel():New("CTBA020",{|oModel| CTB020Ver(oModel)}/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/{|oModel| CTBA020GRV(oModel)},/*Cancel*/)

//--------------------------------------------------------------------
// Adiciona ao modelo uma estrutura de formulário de edição por campo
//--------------------------------------------------------------------
oModel:AddFields("CT1MASTER",,oStruCT1,/*Pre-Validacao*/{|oFieldCT1| CT1PreVal(oFieldCT1) },/*Pos-Validacao*/{|oFieldCT1| CT1PosVal(oFieldCT1) },/*Carga*/)

//--------------------------------------------------------------------
// Adiciona ao modelo uma estrutura de formulário de edição por linha
//--------------------------------------------------------------------
oModel:AddGrid('CVDDETAIL', 'CT1MASTER', oStruCVD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid('CTSDETAIL', 'CT1MASTER', oStruCTS, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/{|oGridCTS| CTSPreVal(oGridCTS)}, /*bPosVal*/ {|oGridCTS| CTSPosVal(oGridCTS)}, /*BLoad*/{|oGridCTS| CTSLoad(oGridCTS)} )

//---------------------------------------------------
// Faz relacionamento entre os componentes do modelo
//---------------------------------------------------
oModel:SetRelation('CVDDETAIL', { {'CVD_FILIAL','XFilial("CVD")'},{'CVD_CONTA','CT1_CONTA'} }, CVD->(IndexKey(1)) )
oModel:SetRelation('CTSDETAIL', { {'CTS_FILIAL','XFilial("CTS")'} }, CTS->(IndexKey(1)) )

//----------------------------------------------------
// Define que é opcional ter dados informados na Grid
//----------------------------------------------------
oModel:GetModel('CVDDETAIL'):SetOptional(.T.)
oModel:GetModel('CTSDETAIL'):SetOptional(.T.)

//----------------------------------------------------------------
// DEfine o critério para nao haver repeticao de dados nas linhas
//----------------------------------------------------------------
oModel:GetModel("CVDDETAIL"):SetUniqueLine({'CVD_ENTREF','CVD_CODPLA','CVD_CTAREF','CVD_CUSTO','CVD_VERSAO'})
oModel:GetModel("CTSDETAIL"):SetUniqueLine({'CTS_FILIAL','CTS_CODPLA','CTS_ORDEM','CTS_LINHA'})

//-----------------------------------------
// Adiciona a descricao do Modelo de Dados
//-----------------------------------------
oModel:SetDescription(STR0006) //"Cadastro Plano de Contas"

//-------------------------------------------------------
// Adiciona a descricao dos submodelos de dados
//-------------------------------------------------------
oModel:GetModel("CT1MASTER"):SetDescription(STR0012) //"Conta Contabil"
oModel:GetModel("CVDDETAIL"):SetDescription(STR0069) //"Plano de Contas Referencial"
oModel:GetModel("CTSDETAIL"):SetDescription(STR0068) //"Visão Gerencial"

//Interceptação do Commit e Validação MVC - FWModelEvent
oModel:InstallEvent("CTBA020EVGFE",, CTBA020EVGFE():New())
oModel:InstallEvent("CTBA020EVPCO",, CTBA020EVPCO():New())

Return oModel

//--------------------------------------------------
/*/{Protheus.doc} CTBA020Grv
Gravacao dos dados do modelo.

@author TOTVS
@since 26/07/2017
@version P12.1.18

@param objeto, modelo de dados
/*/
//--------------------------------------------------
Static Function CTBA020Grv(oModel)
Local lRet			:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModelCT1		:= oModel:GetModel('CT1MASTER')
Local nY			:= 0
Local aCposHistor	:= {}
Local aCampos		:= {}
Local lGravaCW8		:= SuperGetMV("MV_CTBLGET",.F.,.F.)
Local aChv_CTS      := {}
Local oGridCTS      := oModel:GetModel( 'CTSDETAIL' )
Local nLinCTS

Pergunte("CTB020",.F.)

//------------------------------------------------------------------------
// Obtem os dados da CT1 antes da alteracao para geracao do historico CW8
//------------------------------------------------------------------------
If lRet .And. lGravaCW8 .And. nOperation == MODEL_OPERATION_UPDATE
	aCampos := oModelCT1:GetStruct():GetFields()

	DBSelectArea("CT1")
	CT1->(DBSetOrder(1)) //CT1_FILIAL+CT1_CONTA
	If CT1->(DBSeek(XFilial("CT1")+oModel:GetValue("CT1MASTER","CT1_CONTA")))
		For nY := 1 To Len(aCampos)
			If oModelCT1:IsFieldUpdated(aCampos[nY,3]) .And. CT1->&(aCampos[nY,3]) <> oModelCT1:GetValue(aCampos[nY,3])
				Aadd(aCposHistor,{aCampos[nY,3],CT1->&(aCampos[nY,3]),oModelCT1:GetValue(aCampos[nY,3])})
			EndIf
		Next nY
	EndIf
EndIf

//--------------------------
// Grava os Dados do Modelo
//--------------------------
If lRet
	If nOperation == MODEL_OPERATION_DELETE
		//Gravar no array os Recnos da tabela CTS que não deverão ser deletados
		For nLinCTS := 1 To oGridCTS:Length()
	
			oGridCTS:GoLine(nLinCTS)
	
			If !oGridCTS:IsDeleted()
				If !Empty( oGridCTS:GetValue("CTS_CODPLA") ) .And. !Empty( oGridCTS:GetValue("CTS_ORDEM") ) .And. !Empty( oGridCTS:GetValue("CTS_LINHA") )   
					CTS->( dbSetOrder(1) )
					If CTS->( dbSeek( xFilial("CTS")+oGridCTS:GetValue("CTS_CODPLA")+oGridCTS:GetValue("CTS_ORDEM")+oGridCTS:GetValue("CTS_LINHA") ) )
						If CTS->CTS_CT1INI <> CTS->CTS_CT1FIM 
							aAdd( aChv_CTS, CTS->( Recno() ) )
						Else
							//se for igual tem que avaliar se é a conta a ser excluida
						 	If CTS->CTS_CT1INI <> oModelCT1:GetValue("CT1_CONTA") 
						 		aAdd( aChv_CTS, CTS->( Recno() ) )
						 	EndIf
						EndIf
					EndIf 
				EndIf
			EndIf
	
		Next nLinCTS
		oGridCTS:GoLine(1)
	EndIf
	
	If nOperation == MODEL_OPERATION_INSERT
	
		//Verifica se a linha 1 possui informação de Conta, caso contrario efetua à exclusão.
		//Esse processo pe necesario por conta do Mercado Internacional que Grava a tabela 
		//CTS sem registro de conta.
		For nLinCTS := 1 To oGridCTS:Length()
		
			CTS->( dbSetOrder(1) )
			If CTS->( dbSeek( xFilial("CTS")+oGridCTS:GetValue("CTS_CODPLA")+oGridCTS:GetValue("CTS_ORDEM")+"001" ) )
				If Empty(CTS->CTS_CT1INI) .AND. Empty(CTS->CTS_CT1FIM) .AND. oGridCTS:GetValue("CTS_LINHA") != "001"
					oGridCTS:LoadValue("CTS_DESCCG", CTS->CTS_DESCCG)
					oGridCTS:LoadValue("CTS_LINHA", "001")				
				 
					CTS->( Reclock("CTS", .F., .T. ) )
					CTS->( DBDelete() )
					CTS->( MsUnlock() )					
				Endif					
				
			Endif
		
		Next nLinCTS
	
	Endif
	
	
	lRet := FwFormCommit(oModel)

	If lRet .And. nOperation == MODEL_OPERATION_DELETE .And. Len(aChv_CTS) > 0
		//Recuperar os registros da tabela CTS que não deveriam ser deletados, pois FwFormCommit persiste a exclusao
		For nLinCTS := 1 To Len(aChv_CTS)
			//Posiciona no registro que nao deve ser excluido
			CTS->( dbGoto(aChv_CTS[nLinCTS]) )
			//recall do registro 
			CTS->( Reclock("CTS", .F., .T. ) )
			CTS->( DBRecall() )
			CTS->( MsUnlock() )
			
		Next nLinCTS
	EndIf

EndIf

//------------------------------
// Grava historico da CT1 - CW8
//------------------------------
If lRet .And. lGravaCW8

	If nOperation == MODEL_OPERATION_INSERT
		//         cFilTabela    , cEntidade,cCodigo       ,cGrupo,cTipoCampo             ,cCampo     ,cValorAnt,cValorNovo    ,nOpc)
		CTBGrvHist(xFilial("CT1"), "CT1"    ,CT1->CT1_CONTA,      ,ValType(CT1->CT1_CONTA),"CT1_CONTA",""       ,CT1->CT1_CONTA,3   )

	ElseIf nOperation == MODEL_OPERATION_UPDATE
		For nY := 1 To Len(aCposHistor)
			//         cFilTabela    ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo                 ,cCampo            ,cValorAnt         ,cValorNovo        ,nOpc)
			CTBGrvHist(xFilial("CT1"),"CT1"     ,CT1->CT1_CONTA,      ,ValType(aCposHistor[nY][1]),aCposHistor[nY][1],aCposHistor[nY][2],aCposHistor[nY][3],4   )
		Next nY

	ElseIf nOperation == MODEL_OPERATION_DELETE
		//         cFilTabela    ,cEntidade ,cCodigo       ,cGrupo,cTipoCampo             ,cCampo     ,cValorAnt   ,cValorNovo,nOpc)
		CTBGrvHist(xFilial("CT1"),"CT1"     ,CT1->CT1_CONTA,      ,ValType(CT1->CT1_CONTA),"CT1_CONTA",M->CT1_CONTA,""        ,5   )
	EndIf

EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} Ctb020Prox
Devolve o proximo numero do codigo reduzido.
Validacao do SX3 do campo CT1_CLASSE

@author Pilar S Albaladejo
@since 04/11/1999
@version P12.1.18

@return logico, indica a validade do registro
/*/
//--------------------------------------------------
Function CTB020PROX()
Local aSaveArea		:= GetArea()
Local lRet			:= .T.
Local cMemMvs		:= Sv020Mem() // Funcao que salva os mv_par??
Local cRes			:= ""
Local cAliasCT1		:= ""
Local oModel
Local oModelCT1
Local nOperation
Local nTamanho		:= TamSX3("CT1_RES")[1]

//-------------------------------------
// Nao permite alterar Classe da Conta
//-------------------------------------
If FWIsInCallStack("CtbaTree")
      If !Inclui
            If M->CT1_CLASSE != CT1->CT1_CLASSE
                  Help(" ",1,"NALTCLASSE")
            EndIf

			lRet := .F.
	  Else
		oModel      := FWModelActive()
      	oModelCT1   := oModel:GetModel("CT1MASTER")
      	nOperation  := oModel:GetOperation()

      EndIf
Else
      oModel            := FWModelActive()
      oModelCT1   := oModel:GetModel("CT1MASTER")
      nOperation  := oModel:GetOperation()

      If nOperation == MODEL_OPERATION_UPDATE
            If oModelCT1:GetValue("CT1_CLASSE") != CT1->CT1_CLASSE
                  lRet := .F.
                  Help(" ",1,"NALTCLASSE")
            EndIf
      EndIf
EndIf

If lRet
	If oModelCT1:GetValue("CT1_CLASSE") == "2" //Analitica
		Pergunte("CTB020",.F.)
		If Empty(oModelCT1:GetValue("CT1_RES"))
			If MV_PAR01 != 3 // Automatico / Formula

				If MV_PAR01 == 1 // Automatico -> Formula Siga

					cAliasCT1 := GetNextAlias()

					BeginSQL Alias cAliasCT1
						SELECT MAX(CT1_RES) CT1RES
						FROM %Table:CT1%
						WHERE 	CT1_FILIAL = %XFilial:CT1%
								AND %NotDel%
					EndSQL

					If Select( cAliasCT1 ) > 0
						cRes := (cAliasCT1)->CT1RES
					EndIf

					(cAliasCT1)->(DBCloseArea())
					DBSelectArea("CT1")

					If Empty(Alltrim(cRes))
						oModelCT1:SetValue("CT1_RES",StrZero(Val(Soma1(cRes)),nTamanho))
					Else
						oModelCT1:SetValue("CT1_RES",Soma1(cRes))
					EndIf
				ElseIf MV_PAR01 == 2 // Formula -> Do Usuario
					If !Empty(MV_PAR02)
						oModelCT1:SetValue("CT1_RES",&(MV_PAR02))
					EndIf
				EndIf

			EndIf
		EndIf
	Else
		//-----------------------------------------------------
		// Caso a conta seja sintetica, limpa codigo reduzido.
		//-----------------------------------------------------
		oModelCT1:SetValue("CT1_RES",Space(nTamanho))
	EndIf
EndIf

Sv020Mem(cMemMvs)

RestArea(aSaveArea)

Return(lRet)

//--------------------------------------------------
/*/{Protheus.doc} Ctb020NoRe
Verifica se o codigo reduzido foi preenchido com Analiticas.
Validacao no SX3 do campo CT1_RES (Cod. Reduzido)

@author Pilar S Albaladejo
@since 04/11/1999
@version P12.1.18

@return logico, indica a validade do registro
/*/
//--------------------------------------------------
Function CTB020NoRe()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

If oModel:GetValue("CT1MASTER","CT1_CLASSE") == "1"	.And. !Empty(oModel:GetValue("CT1MASTER","CT1_RES"))// Se Sintético e código reduzido preenchido?
	lRet := .F.
	Help(" ",1,"CA020SINT")
EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} Ctb020cust
Preenche CT1_CC de acordo com o numero de bytes para C Custo.

@author Pilar S Albaladejo
@since 04/11/1999
@version P12.1.18

@return logico, indica a validade do registro
/*/
//--------------------------------------------------
Function Ctb020Cust()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelCT1	:= oModel:GetModel("CT1MASTER")
Local nNCusto	:= oModelCT1:GetValue("CT1_NCUSTO")
Local cConta	:= oModelCT1:GetValue("CT1_CONTA")

If nNCusto >= Len(AllTrim(cConta))
	lRet := .F.
	Help(" ",1,"DIGCCINVAL")
Else
	oModelCT1:SetValue("CT1_CC", If(nNCusto > 0, Right(AllTrim(cConta),nNCusto), ""))
Endif

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} Ctb020Sup
Gera o c¢digo da conta superior a partir da conta atual.
Validacao do SX3 do Campo CT1_Conta

@author Pilar S Albaladejo
@since 08/11/1999
@version P12.1.18

@return logico, indica a validade do registro
/*/
//--------------------------------------------------
Function Ctb020Sup(cCodigo)
Local cMemMvs	:= Sv020Mem() // Funcao que salva os mv_par??
Local oModel	:= FWModelActive()
Local oModelCT1	:= oModel:GetModel("CT1MASTER")

Pergunte("CTB020",.F.)

//------------------------------------------
// Chamada a funcao que gera o cta superior
//------------------------------------------
If MV_PAR03 != 3 // Automatico / Formula
	If MV_PAR03 == 1 // Automatico -> Formula Siga
		oModelCT1:SetValue("CT1_CTASUP",CtbCtaSup(cCodigo))
	ElseIf MV_PAR03 == 2 // Formula -> do usuario
		If !Empty(MV_PAR04)
			oModelCT1:SetValue("CT1_CTASUP",&(MV_PAR04))
		EndIf
	EndIf
EndIf

Sv020Mem(cMemMvs)

Return .T.

//--------------------------------------------------
/*/{Protheus.doc} Ctb020LP
Sugere conta de Lucros e Perdas
Validacao do SX3 do campo CT1_CLASSE

@author Pilar S Albaladejo
@since 04/11/1999
@version P12.1.18

@return logico, indica a validade do registro
/*/
//--------------------------------------------------
Function CTB020LP()
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local nTamanho	:= TamSX3("CT1_CONTA")[1]
Local cMemMvs 	:= Sv020Mem() // Funcao que salva os mv_par??
Local oModel	:= FWModelActive()
Local oModelCT1	:= oModel:GetModel("CT1MASTER")

If oModelCT1:GetValue("CT1_CLASSE") == "2" // Analitica
	Pergunte("CTB020",.F.)
	If Empty(oModelCT1:GetValue("CT1_CTALP"))
		oModelCT1:SetValue("CT1_CTALP",MV_PAR07) // Conta de Apuracao de Lucros e Perdas
	EndIf
	If Empty(oModelCT1:GetValue("CT1_CTAPON"))
		oModelCT1:SetValue("CT1_CTAPON",MV_PAR08) // Conta Ponte de Apuracao de Lucros e Perdas
	EndIf
Else
	//-------------------------------------
	// Caso a conta seja sintetica, limpa
	//-------------------------------------
	oModelCT1:SetValue("CT1_CTALP",Space(nTamanho))
	oModelCT1:SetValue("CT1_CTAPON",Space(nTamanho))
EndIf

Sv020Mem(cMemMvs)

RestArea(aSaveArea)

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} Ctb020Var
Sugere conta de Variacao Monetaria
Validacao do SX3 do campo CT1_CLASSE

@author Pilar S Albaladejo
@since 04/11/1999
@version P12.1.18

@return logico, indica a validade do registro
/*/
//--------------------------------------------------
Function CTB020Var()
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local nTamanho	:= TamSX3("CT1_CONTA")[1]
Local cMemMvs	:= Sv020Mem() // Funcao que salva os mv_par??
Local oModel
Local oModelCT1

If FWIsInCallStack("CtbaTree")
      If Altera
            If M->CT1_CLASSE != CT1->CT1_CLASSE
                  lRet := .F.
                  Help(" ",1,"NALTCLASSE")
            EndIf
	  ElseIF Inclui
	  		 	oModel      := FWModelActive()
      			oModelCT1   := oModel:GetModel("CT1MASTER")
      EndIf
Else
      oModel      := FWModelActive()
      oModelCT1   := oModel:GetModel("CT1MASTER")
EndIf

If oModelCT1:GetValue("CT1_CLASSE") == "2" // Analitica
	Pergunte("CTB020",.F.)
	If Empty(oModelCT1:GetValue("CT1_CTAVM"))
		oModelCT1:SetValue("CT1_CTAVM",MV_PAR05) // Conta de Variacao Monetaria
	EndIf
	If Empty(oModelCT1:GetValue("CT1_CTARED"))
		oModelCT1:SetValue("CT1_CTARED",MV_PAR06) // Conta Redutora da Variacao Monetaria
	EndIf
Else
	//------------------------------------
	// Caso a conta seja sintetica, limpa
	//------------------------------------
	oModelCT1:SetValue("CT1_CTAVM",Space(nTamanho))
	oModelCT1:SetValue("CT1_CTARED",Space(nTamanho))
EndIf

Sv020Mem(cMemMvs)

RestArea(aSaveArea)

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} Sv020Mem
Salva as variaveis mv_par?? caso seja via chamada externa
Validacao do SX3 do campo CT1_CLASSE

@author Wagner Mobile Costa
@since 12/11/2001
@version P12.1.18

@param array, dados do pergunte para restauracao
Caso nao for passado indica a gravacao dos MV_PAR??

@return array, dados do pergunte salvo
/*/
//--------------------------------------------------
Function Sv020Mem(aMemMvs)

If aMemMvs = Nil
	aMemMvs := {	MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04,;
					MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08,;
					MV_PAR09 }

ElseIf aMemMvs <> Nil

	MV_PAR01 := aMemMvs[1] // Restauro o conteudo anterior
	MV_PAR02 := aMemMvs[2]
	MV_PAR03 := aMemMvs[3]
	MV_PAR04 := aMemMvs[4]
	MV_PAR05 := aMemMvs[5]
	MV_PAR06 := aMemMvs[6]
	MV_PAR07 := aMemMvs[7]
	MV_PAR08 := aMemMvs[8]
	MV_PAR09 := aMemMvs[9]

EndIf

Return aMemMvs

//--------------------------------------------------
/*/{Protheus.doc} Ctb020Cta
Validacao da Conta digitada -> SX3

@author Pilar S. Albaladejo
@since 27/06/2003
@version P12.1.18

@return array, dados do pergunte salvo
/*/
//--------------------------------------------------
Function Ctb020cta()
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelCT1	:= oModel:GetModel("CT1MASTER")
Local cConta	:= oModelCT1:GetValue("CT1_CONTA")

lRet := If((	ExistChav("CT1",,1)	.And.;
				Ctb020Sup(cConta)	.And.;
				Ctb020Prox(.T.)		.And.;
				FreeForUse("CT1",cConta);
			),.T.,.F.)

RestArea(aSaveArea)

// Atualizacao do cache de validacao das entidades contabeis
AtuVldEnt("CT1",cConta)

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CT1PreVal
Funcao de pre-validacao do submodelo CT1.

@author TOTVS
@since 27/07/2017
@version P12.1.18

@param objeto, submodelo da CT1

@return logico, Indica se o submodelo CT1 está pré-validado
/*/
//--------------------------------------------------
Static Function CT1PreVal(oFieldCT1)
Local aAreaCT1		:= CT1->(GetArea())
Local lRet			:= .T.
Local nOperation	:= oFieldCT1:GetOperation()
Local cContaCT1		:= ""

//----------
// Exclusao
//----------
If lRet .And. nOperation == MODEL_OPERATION_DELETE

	cContaCT1 := oFieldCT1:GetValue("CT1_CONTA")

	// Se encontrar algum apostrofo no código
	If ValType(cContaCT1) == "C" .And. At("'", cContaCT1) > 0
		cContaCT1 := ClearAsp(cContaCT1) // Chama função ClearAsp para tratamento de apostrofo a ser usado em query
	EndIf 
	
	//---------------------------------------------------------
	// Verifica se o Saldo da Conta permite a delecao da mesma
	//---------------------------------------------------------
	If lRet .And. ExiSalCQ("CT1",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,cContaCT1,/*cCC*/,/*cItem*/,/*cClasse*/)
		lRet := .F.
		Help(" ",1,"CTAMOVIM")
	EndIf
	
	//------------------------------------------------
	// Verifica se existe sintetica em nivel superior
	//------------------------------------------------
	If  lRet .And. CT1->CT1_CLASSE == "1" // Sintetica
		DBSelectArea("CT1")
		CT1->(DBSetOrder(5)) //CT1_FILIAL+CT1_CTASUP
		If CT1->(DBSeek(XFilial("CT1")+oFieldCT1:GetValue("CT1_CONTA")))
			lRet:=.F.
			Help(" ",1,"020SUPERIO")
		EndIf
	EndIf
	
EndIf

RestArea(aAreaCT1)

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CT1PosVal
Funcao de Pós-validacao do submodelo CT1.

@author TOTVS
@since 27/07/2017
@version P12.1.18

@param objeto, submodelo da CT1

@return logico, Indica o submodelo CT1 esta valido
/*/
//--------------------------------------------------
Static Function CT1PosVal(oFieldCT1)
Local aAreaCT1		:= CT1->(GetArea())
Local lRet			:= .T.
Local nOperation	:= oFieldCT1:GetOperation()
Local oView			:= Nil

//-------------------------------------------------------------------
// Somente avisa na inclusao que a conta superior nao foi preenchida
//-------------------------------------------------------------------
If lRet .And. nOperation == MODEL_OPERATION_INSERT

	oView := FWViewActive()

	If oView <> Nil
		If Empty(oFieldCT1:GetValue("CT1_CTASUP"))
			oView:ShowInsertMsg(.T.)
			oView:SetInsertMessage(STR0057,STR0081) //"Atenção"###"Certifique-se que essa conta realmente não possui conta superior."
		Else
			oView:ShowInsertMsg(.F.)
		EndIf
	EndIf

EndIf

//------------------------------------------------------------------
// Somente avisa que na alteracao conta superior nao foi preenchida
//------------------------------------------------------------------
If lRet .And. nOperation == MODEL_OPERATION_UPDATE

	oView := FWViewActive()

	If oView <> Nil
		If Empty(oFieldCT1:GetValue("CT1_CTASUP"))
			oView:ShowUpdateMsg(.T.)
			oView:SetUpdateMessage(STR0057,STR0081) //"Atenção"###"Certifique-se que essa conta realmente não possui conta superior."
		Else
			oView:ShowUpdateMsg(.F.)
		EndIf
	EndIf

EndIf

RestArea(aAreaCT1)

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CTB020DTIN
Valida a data de inicio de bloqueio.
Validacao no SX3 do campo CT1_DTBLIN (Data de Bloqueio)

@author Eduardo Lima
@since 27/08/2013
@version P12.1.18

@return logico, Indica se o dado é valido
/*/
//--------------------------------------------------
Function CTB020DTIN()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelCT1	:= oModel:GetModel("CT1MASTER")

If !Empty(oModelCT1:GetValue("CT1_DTBLIN")) .And. !Empty(oModelCT1:GetValue("CT1_DTEXIS")) .And. oModelCT1:GetValue("CT1_DTBLIN") < oModelCT1:GetValue("CT1_DTEXIS")
	lRet := .F.
	Help(" ",1,"HELP","DTBLIN",STR0058,3,1) //A data de inicio bloqueio não pode ser menor que a data de inicio de existencia.
EndIf

If	lRet .And. !Empty(oModelCT1:GetValue("CT1_DTBLFI")) .And. !Empty(oModelCT1:GetValue("CT1_DTBLIN")) .And. oModelCT1:GetValue("CT1_DTBLFI") < oModelCT1:GetValue("CT1_DTBLIN")
	lRet := .F.
	Help(" ",1,"HELP","DTBLIN",STR0059,3,1) //A data de inicio bloqueio não pode ser maior que a data de final de bloqueio.
EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CTB020DTFI
Valida a data de fim de bloqueio.
Validacao no SX3 do campo CT1_DTBLFI (Data de Bloqueio)

@author Eduardo Lima
@since 27/08/2013
@version P12.1.18

@return logico, Indica se o dado é valido
/*/
//--------------------------------------------------
Function CTB020DTFI()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local oModelCT1	:= oModel:GetModel("CT1MASTER")

If !Empty(oModelCT1:GetValue("CT1_DTBLFI")) .And. !Empty(oModelCT1:GetValue("CT1_DTEXIS")) .And. oModelCT1:GetValue("CT1_DTBLFI") < oModelCT1:GetValue("CT1_DTEXIS")
	lRet := .F.
	Help(" ",1,"HELP","DTBLFI",STR0060,3,1) //A data de final de bloqueio não pode ser menor que a data de inicio de existencia.
EndIf

If lRet .And. !Empty(oModelCT1:GetValue("CT1_DTBLFI")) .And. !Empty(oModelCT1:GetValue("CT1_DTBLIN")) .And. oModelCT1:GetValue("CT1_DTBLFI") < oModelCT1:GetValue("CT1_DTBLIN")
	lRet := .F.
	Help(" ",1,"HELP","DTBLFI",STR0061,3,1) //A data de final de bloqueio não pode ser menor que a data de inicio de bloqueio
EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CTBA020Exp
Exporta o plano de contas para arquivo .CSV

@author Marcelo Akama
@since 11/08/2009
@version P12.1.18

@return logico, Indica se o dado é valido
/*/
//--------------------------------------------------
Function CTBA020Exp()
Local aRet := {}

SaveInter()

If ParamBox({{6,STR0021,padr("",150),"",,"",90 ,.T.,STR0022,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},; //"Estrut. de plano de contas"###"Arquivo .CSV |*.CSV"
		STR0023,@aRet) //"Exportar para estrutura de plano de contas"

	oProcess:= MsNewProcess():New( {|lEnd| CTBExpCSV( lEnd, oProcess, aRet[1], { {"CT1",1}, {"CVD",1} } )} )
	oProcess:Activate()

EndIf

RestInter()

Return .T.

//--------------------------------------------------
/*/{Protheus.doc} CTBA020Imp
Importa plano de contas de arquivo .CSV

@author Marcelo Akama
@since 11/08/2009
@version P12.1.18

@return logico, Indica se o dado é valido
/*/
//--------------------------------------------------
Function CTBA020Imp()
Local aRet			:= {}
Local aAreaCT1		:= CT1->(GetArea())
Local aAreaCVD		:= CVD->(GetArea())
Local aCfg			:= {}
Local cCampos		:= ""
Local lContinua		:= .T.
Local oModCT1Imp	:= Nil

//----------------------------
// Valida se não há registros
//----------------------------
If CT1->(DBSeek(xFilial("CT1"))) .Or. CVD->(DBSeek(xFilial("CVD")) )
	lContinua := .F.
	Aviso(STR0034,STR0036+CRLF+STR0037,{STR0033}) //"Importar"###"A importacao do plano de contas so pode ser"##"feita com o plano de contas vazio" //"Fechar"
EndIf

If lContinua

	SaveInter()

	Pergunte("CTB020",.F.)

	oModCT1Imp	:= FWLoadModel("CTBA020")

	cCampos:="CT1_CONTA,CT1_DESC01,CT1_DESC02,CT1_DESC03,CT1_DESC04,CT1_DESC05,CT1_CLASSE,CT1_NORMAL"

	If MV_PAR01 == 3 // Cod reduzido digitado
		cCampos += ",CT1_RES"
	EndIf

	cCampos += ",CT1_BLOQ,CT1_DTBLIN,CT1_DTBLFI,CT1_CVD02,CT1_CVD03,CT1_CVD04,CT1_CVD05,CT1_CVC02,CT1_CVC03,CT1_CVC04,CT1_CVC05,CT1_CTASUP,CT1_HP,CT1_ACITEM,CT1_ACCUST,CT1_ACCLVL,CT1_DTEXIS,CT1_DTEXSF,CT1_CTAVM,CT1_CTARED,CT1_CTALP,CT1_CTAPON,CT1_BOOK,CT1_GRUPO,CT1_RGNV1,CT1_RGNV2,CT1_RGNV3,CT1_CCOBRG,CT1_ITOBRG,CT1_CLOBRG,CT1_TRNSEF,CT1_LALUR,CT1_CTLALU,CT1_TPLALU,CT1_LALHIR,CT1_RATEIO,CT1_ACATIV,CT1_ATOBRG,CT1_ACET05,CT1_05OBRG"

	aCfg := { { "CT1", cCampos, {|| FWMVCRotAuto(oModCT1Imp, "CT1", 3, { {"CT1MASTER",xAutoCab} }, , .T.) } }, {"CVD",,} }

	If ParamBox({	{6,STR0021,PadR("",150),"",,"", 90 ,.T.,STR0022,"",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE}},;	 //"Estrut. plano de contas"###"Arquivo .CVE |*.CVE"
					STR0028,@aRet)  //"Importar estrutura de plano de contas"

		oProcess:= MsNewProcess():New( {|lEnd| CTBImpCSV( lEnd, oProcess, aRet[1], aCfg )} )
		oProcess:Activate()

	EndIf

	oModCT1Imp:Destroy()
	oModCT1Imp := Nil

	RestInter()

EndIf

RestArea(aAreaCVD)
RestArea(aAreaCT1)

Return Nil

//--------------------------------------------------
/*/{Protheus.doc} CTSPosVal
Pós-validacao do submodelo CTS

@author TOTVS
@since 25/07/2017
@version P12.1.18

@param objeto, submodelo da CTS

@return logico, indica se o submodelo está valido
/*/
//--------------------------------------------------
Static Function CTSPosVal(oGridCTS)
Local lRet			:= .T.
Local nOperation	:= oGridCTS:GetOperation()
Local cConta		:= ""
Local nLinCTS		:= 0
Local aSaveLines	:= {}

//-------------------------------------------------------------------------------
// Tratamento para preencher o CTS_CT1INI e CTS_CT1FIM quando inclusa nova linha
//-------------------------------------------------------------------------------
If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE

	cConta := oGridCTS:GetModel():GetValue('CT1MASTER','CT1_CONTA')

	aSaveLines := FWSaveRows()

	For nLinCTS := 1 To oGridCTS:Length()

		oGridCTS:GoLine(nLinCTS)

		If !oGridCTS:IsDeleted() .And. Empty(oGridCTS:GetValue("CTS_CT1INI")) .And. Empty(oGridCTS:GetValue("CTS_CT1FIM"))
			//----------------------------------------------------------
			// Utilizado LoadValue pois na inclusao o código nao existe
			// na tabela CT1 evitando o erro do ExistCpo do X3_VALID
			//----------------------------------------------------------
			oGridCTS:LoadValue("CTS_CT1INI",cConta)
			oGridCTS:LoadValue("CTS_CT1FIM",cConta)
		EndIf

	Next nLinCTS

	FWRestRows(aSaveLines)

EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CTSPreVal
Pré-validação do submodelo CTS

@author TOTVS
@since 25/07/2017
@version P12.1.18

@param objeto, submodelo da CTS

@return logico, indica se o submodelo está valido
/*/
//--------------------------------------------------
Static Function CTSPreVal(oGridCTS)
Local lRet			:= .T.
Local nOperation	:= oGridCTS:GetOperation()
Local cCT1Conta		:= ""
Local cGerIni		:= ""
Local cGerFim		:= ""
Local nLinCTS		:= 0

//-------------------------------------------------
// Nao permite excluir a conta caso ela seja igual
// a CTS_CT1INI ou CTS_CT1FIM, mas não ambos.
//-------------------------------------------------
If nOperation == MODEL_OPERATION_DELETE

	cCT1Conta := oGridCTS:GetModel():GetValue('CT1MASTER','CT1_CONTA')

	For nLinCTS := 1 To oGridCTS:Length()

		cGerIni := oGridCTS:GetValue('CTS_CT1INI',nLinCTS)
		cGerFim := oGridCTS:GetValue('CTS_CT1FIM',nLinCTS)

		If (cGerIni == cCT1Conta .Or. cGerFim == cCT1Conta) .And. (cGerIni <> cGerFim)
			lRet := .F.
			Help(" ",1,"CTSPreVal",,STR0082,1,0,,,,,,{STR0083}) //"A conta contábil faz parte do intevalo da conta gerencial."###"No cadastro de Visão Gerencial, altere o intevalo de contas contábeis."
		EndIf

	Next nLinCTS

EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} CTSLoad
Carga do painel Visao Gerencial com base na conta
contábil.

@author TOTVS
@since 25/07/2017
@version P12.1.18

@param objeto, submodelo da grid CTS

@return array, dados da tabela CTS
/*/
//--------------------------------------------------
Static Function CTSLoad(oGridCTS)
Local aArea		:= GetArea()
Local aFields	:= {}
Local aRet		:= {}
Local cFields	:= 'R_E_C_N_O_'
Local cTmp		:= ''
Local cCT1Conta	:= oGridCTS:GetModel():GetModel('CT1MASTER'):GetValue('CT1_CONTA')

//----------------------------------------------------------------------------------------
// Obtem os campos que fazem parte da estrutura do objeto, para otimizar retorno da query
//----------------------------------------------------------------------------------------
aFields := oGridCTS:GetStruct():GetFields()
aEval( aFields, { |aX| If( !aX[MODEL_FIELD_VIRTUAL], cFields += ',' + aX[MODEL_FIELD_IDFIELD],) } )

cFields := "%" + cFields + "%"

cTmp := GetNextAlias()

If ValType(cCT1Conta) == "C" .And. At("'", cCT1Conta) > 0
	cCT1Conta := ClearAsp(cCT1Conta)
Endif

BeginSQL Alias cTmp
	SELECT %Exp:cFields%
	FROM %Table:CTS%
	WHERE 	CTS_FILIAL = %XFilial:CTS%
			AND %Exp:cCT1Conta% BETWEEN CTS_CT1INI AND CTS_CT1FIM
			AND %NotDel%
	ORDER BY CTS_CODPLA
EndSQL

aRet := FWLoadByAlias(oGridCTS,cTmp)

(cTmp)->(DBCloseArea())

RestArea(aArea)

Return aRet

//--------------------------------------------------
/*/{Protheus.doc} CTBA020DIC
Valida el contenido del campo especificado en el parametro

@author Jesus Peñaloza
@since 20/01/2015
@version P12.1.18

@param caracter, campo da tabela CTS

@return logito, indica se o valor é valido
/*/
//--------------------------------------------------
Function CTBA020DIC(cCampo)
Local lRet := .T.

If cCampo == "CTS_CODPLA"
	lRet := ExistCpo("CVE",FWFldGet("CTS_CODPLA"))
ElseIf cCampo == "CTS_CONTAG"
	lRet := ValidaGest()
EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} ValidaGest
Valida que el codigo de entidad gerencial ingresada exista

@author Jesus Peñaloza
@since 20/01/2015
@version P12.1.18

@return logito, indica se o valor é valido
/*/
//--------------------------------------------------
Function ValidaGest()
Local lRet		:= .T.
Local cLinha	:= "001"
Local oModel	:= FWModelActive()
Local oModelCTS	:= oModel:GetModel("CTSDETAIL")

DBSelectArea("CVF")
CVF->(DBSetOrder(1))
If CVF->(DBSeek(xFilial("CVF")+oModelCTS:GetValue("CTS_CODPLA")+oModelCTS:GetValue("CTS_CONTAG")))

	If CVF->CVF_CLASSE != "2"
		lRet := .F.
		Help( , ,'ValidaGest', ,STR0072,1,0) //"Vision Gerencial inexistente o no es Analitica"
	Else

		oModelCTS:LoadValue("CTS_ORDEM"		,CVF->CVF_ORDEM			)
		oModelCTS:LoadValue("CTS_CTASUP"	,CVF->CVF_CTASUP		)
		oModelCTS:LoadValue("CTS_NORMAL"	,CVF->CVF_NORMAL		)
		If __Release .and. CTS->(FieldPos("CTS_COLUN2")) > 0  //12.1.2210
			oModelCTS:LoadValue("CTS_COLUN2"	,CVF->CVF_COLUNA)
		Else
			oModelCTS:LoadValue("CTS_COLUNA"	,GetCTSCol(CVF->CVF_COLUNA,cTipoCTS))//0
		EndIf
		oModelCTS:LoadValue("CTS_CLASSE"	,CVF->CVF_CLASSE		)

		DBSelectArea("CTS")
		CTS->(DBSetOrder(1))
		If CTS->(DBSeek(XFilial("CTS")+oModelCTS:GetValue("CTS_CODPLA")+CVF->CVF_ORDEM))
			cLinha := SigLinea(oModelCTS:GetValue("CTS_CODPLA"),CVF->CVF_ORDEM)
		
			oModelCTS:SetValue("CTS_TPSALD"	,CTS->CTS_TPSALD	)
			oModelCTS:SetValue("CTS_FORMUL"	,CTS->CTS_FORMUL	)
			oModelCTS:SetValue("CTS_IDENTI"	,CTS->CTS_IDENT		)
		EndIf
		oModelCTS:SetValue("CTS_LINHA",cLinha)

	EndIf
Else
	lRet := .F.
	Help( , ,'ValidaGest', ,STR0072,1,0) //"Vision Gerencial inexistente o no es Analitica"
EndIf

Return lRet

//--------------------------------------------------
/*/{Protheus.doc} SigLinea
Obtiene la linea siguiente de la vision en base al codigo
de plan y al orden de la vision.

@author Jesus Peñaloza
@since 20/01/2015
@version P12.1.18

@param caracter, Codigo del plan
@param caracter, Orden de la vision

@return caracter, Siguiente linea de la vision
/*/
//--------------------------------------------------
Static Function SigLinea(cCodPla, cOrdem)
Local aArea		:= GetArea()
Local cTempF	:= GetNextAlias()
Local cLinha	:= "001"

BeginSQL Alias cTempF
	SELECT Max(CTS_LINHA) CTS_LINHA
	FROM %Table:CTS%
	WHERE 	CTS_FILIAL = %XFilial:CTS%
			AND CTS_CODPLA = %Exp:cCodPla%
			AND CTS_ORDEM = %Exp:cOrdem%
			AND %NotDel%
EndSQL

If (cTempF)->(!Eof())
	cLinha := Soma1((cTempF)->(CTS_LINHA))
EndIf

(cTempF)->(DBCloseArea())

RestArea(aArea)

Return cLinha

//--------------------------------------------------
/*/{Protheus.doc} CTBA020F3cvf
Filtro de la consuta CVF

@author G Santacruz
@since 06/05/2015
@version P12.1.18

@return caracter, string del filtro
/*/
//--------------------------------------------------
Function CTBA020F3cvf()
Local cRet:= "@#.T.@#"//.t.

If FunName() == "CTBA020"
	cRet:="@#CVF->CVF_CODIGO == FWFldGet('CTS_CODPLA')  .And. CVF->CVF_CLASSE=='2'@#"
EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb020Filt
Função para filtro de código e versão no plano referencial na
consulta padrão da conta referencial (CVN3)

@author Simone Mie Sato Kakinoana
@since 17/03/2015
@version P12

@return  logico, indica se o registro atende o filtro
/*/
//-------------------------------------------------------------------
Function Ctb020Filt()
Local lRet := .T.

lRet :=	CVN->CVN_CODPLA == FWFldGet("CVD_CODPLA") .And.;
		CVN->CVN_VERSAO == FWFldGet("CVD_VERSAO")

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb020Vers
Função para verificar se a versão escolhida existe no plano
referencial escolhido.

@author Simone Mie Sato Kakinoana
@since  17/03/2015
@version P12

@return  logico, indica se a versao é valida
/*/
//-------------------------------------------------------------------
Function Ctb020Vers()
Local aSaveArea	:= GetArea()
Local aSaveCVN	:= CVN->(GetArea())
Local lRet		:= .T.
Local cCodPla	:= FWFldGet("CVD_CODPLA")
Local cVersao	:= FWFldGet("CVD_VERSAO")

If !Empty(cCodPla) .And. !Empty(cVersao)
	DbSelectArea("CVN")
	DbSetOrder(4) //CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF
	If !DbSeek(xFilial("CVN")+cCodPla+cVersao)
		lRet := .F.
		Help(" ",1,"Ctb020Vers",,STR0073,1,0) //"Versão não cadastrada no plano referencial."
	EndIf
EndIf

RestArea(aSaveCVN)
RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb020CRef
Função para verificar se a conta referencial escolhida existe no
plano e versão escolhidos.

@author Simone Mie Sato Kakinoana
@since 17/03/2015
@version P12

@return  logico, indica se a conta referencial é valida
/*/
//-------------------------------------------------------------------
Function Ctb020CRef()
Local aSaveArea	:= GetArea()
Local aSaveCVN	:= CVN->(GetArea())
Local lRet		:= .T.
Local cCodPla	:= FWFldGet("CVD_CODPLA")
Local cVersao	:= FWFldGet("CVD_VERSAO")
Local cCtaRef	:= FWFldGet("CVD_CTAREF")

If !Empty(cCodPla) .And. !Empty(cVersao) .And. !Empty(cCtaRef)
	DbSelectArea("CVN")
	DbSetOrder(4) //CVN_FILIAL+CVN_CODPLA+CVN_VERSAO+CVN_CTAREF
	If !DBSeek(xFilial("CVN")+cCodPla+cVersao+cCtaRef)
		lRet := .F.
		Help(" ",1,"Ctb020CRef",,STR0074,1,0) //"Conta referencial não cadastrada na versão desse plano referencial."
	EndIf
EndIf

RestArea(aSaveCVN)
RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Ctb020CSup
Valida Conta Superior na inclusao da conta contabil.
X3_VALID do campo CT1_CTASUP

@author Totvs
@since 18/04/2001
@version P12

@return  logico, indica se a conta superior é valida
/*/
//-------------------------------------------------------------------
Function Ctb020CSup()
Local aSaveArea	:= GetArea()
Local lRet		:= .T.
Local cConta	:= FWFldGet("CT1_CTASUP")
Local cCtaAtu	:= FWFldGet("CT1_CONTA")

DBSelectArea("CT1")
DBSetOrder(1)

If !Empty(cConta)
	Do Case
		Case cCtaAtu == cConta				//A conta atual (_CONTA) deve ser diferente da superior
			lRet := .F.
			Help(" ",1,"ENTPAIGUAL")
		Case !MsSeek(xFilial()+cConta)		//A conta digitada (CTASUP) deve existir no Plano de Contas.
			lRet := .F.
			Help("  ", 1, "NOCADCTASU")
		Case CT1->CT1_CLASSE != "1"			//A conta superior deve ser sintetica.
			lRet := .F.
			Help(" ",1,"NOCLASSESI")
	EndCase
EndIf

RestArea(aSaveArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função para a interação com EAI envio e recebimento

@author Wilson.Godoi
@since 23/01/2012
@version P12

@param caracter, Variavel com conteudo xml para envio/recebimento.
@param caracter, Tipo de transacao. (Envio/Recebimento)
@param caracter, Tipo de mensagem. (Business Type, WhoIs, etc)

@return  Array, Array contendo o resultado da execucao e a mensagem Xml de retorno.
         aRet[1] - (boolean) Indica o resultado da execução da função
         aRet[2] - (caracter) Mensagem Xml para envio
/*/
//-------------------------------------------------------------------
Static Function IntegDef( cXml, nType, cTypeMsg )
Local aRet := {}

	aRet:= CTBI020( cXml, nType, cTypeMsg )

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} CTB020Ver
 Protecao devido congelamento da 12.1.17 e necessidade de liberacao da conversao para MVC
 Validacao por amostragem de dicionario.
 Nao deve ser replicado para Main ou outras versoes.
 Pacote ATUSX: 003664 (será integrado na 12.1.17 - Outubro)
 Link Especificao: http://tdn.totvs.com/x/__1eE

@author TOTVS
@since 18/09/2017
@version P12
/*/
//-------------------------------------------------------------------
Function CTB020Ver(oModel)
Local lRet			:= .T.
Local oCT1			:= oModel:GetModel("CT1MASTER")
Local oStruCT1	:= oCT1:GetStruct()

If !"FWFldGet" $ GetCBSource(oStruCT1:GetProperty("CT1_CTALP",MODEL_FIELD_VALID))
	lRet := .F.
	Help(" ",1,"CTBA020",,STR0084,1,0,,,,,,{STR0085}) //"Ambiente desatualizado."###"Atualize o ambiente para a versão 12.1.17 (Outubro) ou superior."
EndIf

Return lRet
//--------------------------------------------------
/*/{Protheus.doc} CTSFormVi
Tela de carregamento de View / Model CTS

@author TOTVS
@since 27/11/2018
@version P12.1.23

@return objeto 
/*/
//--------------------------------------------------			

Static Function CTSFormVi(oModel,lModel)

Local oViewCTS := ""
Local cCampos  := 'CTS_CODPLA|CTS_NOME|CTS_CONTAG|CTS_ORDEM|CTS_LINHA|CTS_FORMUL|CTS_IDENTI|CTS_TPSALD|CTS_CTTINI|CTS_CTTFIM|CTS_CTDINI|CTS_CTDFIM|CTS_CTHINI|CTS_CTHFIM'

Local nJ 	   := 1
Local aCamposA := {}


Default oModel := nil
Default lModel:= .T.

IF !lModel
	If ValType(oModel) == 'O'
		For nJ := 1 to len(oModel:GetModel("CTSDETAIL"):OFORMMODELSTRUCT:AFIElDS)
			If X3Obrigat(oModel:GetModel("CTSDETAIL"):OFORMMODELSTRUCT:AFIElDS[nJ][3])		
				If !oModel:GetModel("CTSDETAIL"):OFORMMODELSTRUCT:AFIElDS[nJ][3] $ cCampos 
					cCampos	+= '|'+ oModel:GetModel("CTSDETAIL"):OFORMMODELSTRUCT:AFIElDS[nJ][3]
					aAdd(aCamposA,oModel:GetModel("CTSDETAIL"):OFORMMODELSTRUCT:AFIElDS[nJ][3])
				Endif
			Endif
		Next
		oViewCTS:= FWFormStruct(2,'CTS', { |x| AllTrim(x) $ cCampos } )

		For nJ := 1 to Len(aCamposA)
		oViewCTS:SetProperty(aCamposA[nJ]	,MVC_VIEW_CANCHANGE,.T.)
		Next
	EndIf
Else
	//Verifica se a linha 1 possui informação de Conta, caso contrario efetua à exclusão.
	//Esse processo pe necesario por conta do Mercado Internacional que Grava a tabela 
	//CTS sem registro de conta.
	cCampos+="|CTS_DESCCG"
	
	oViewCTS:= FWFormStruct(1,'CTS')
	For nJ := 1 to len(oViewCTS:aFields)
		If X3Obrigat(oViewCTS:aFields[nJ][3])		
			If !oViewCTS:aFields[nJ][3] $ cCampos 
				oViewCTS:SetProperty(oViewCTS:aFields[nJ][3],MODEL_FIELD_WHEN,{|| .T.})
			Endif
		Endif
	Next

EndIf

Return oViewCTS


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  Ctb020Excl  		³Gustavo Fernandes       º Data ³  02/05/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ctb020Excl                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/	
Function Ctb020Excl(cAlias,nReg,nOpc)
Local aAreaCT1		:= CT1->(GetArea())
Local lRet			:= .T.
Local cCV3			:= 	GetNextAlias()
Local oModel		:= FWLoadModel("CTBA020")
Local oCT1Model		:= Nil
Local cMsgError   	:= "" 
Local cContaCT1		:= ""

oModel:SetOperation( nOpc ) 
oModel:Activate() 
oCT1Model := oModel:GetModel("CT1MASTER")

cContaCT1 := oCT1Model:GetValue("CT1_CONTA")

If ValType(cContaCT1) == "C" .And. At("'", cContaCT1) > 0
	cContaCT1 := ClearAsp(cContaCT1)
Endif

If ExiSalCQ("CT1",/*cFiltro*/,/*dDtIni*/,/*dDtFin*/,cContaCT1,/*cCC*/,/*cItem*/,/*cClasse*/)
	lRet := .f.
 	cMsgError := STR0089
EndIf

If lRet
	//---------------------------------------------------------
	// Verifica se a conta se encontra na tabela CTK,CV3 se for não permite a delecao da mesma
	//----------------------------------------------------------
	BeginSQL Alias cCV3
		SELECT SUM(CTDREC) CTDREC
		FROM 
		(	SELECT COUNT(CTK_FILIAL) CTDREC
			FROM %Table:CTK% CTK 
			WHERE  CTK.CTK_FILIAL = %XFilial:CTK%
			AND (CTK.CTK_DEBITO = %Exp:cContaCT1%  OR CTK.CTK_CREDIT = %Exp:cContaCT1%  )
			AND CTK.D_E_L_E_T_= ' ' 
			UNION ALL
			SELECT COUNT(CV3_FILIAL) CTDREC
			FROM %Table:CV3% CV3 
			WHERE CV3.CV3_FILIAL = %XFilial:CV3%
			AND (CV3.CV3_DEBITO = %Exp:cContaCT1%  OR CV3.CV3_CREDIT = %Exp:cContaCT1%  )
			AND CV3.D_E_L_E_T_= ' ' 
		) QRYAUX
	EndSQL

	If (cCV3)->(! Eof()) .And. (cCV3)->CTDREC > 0
		lRet := .F.
		cMsgError += STR0087 // NÃO PERMITE EXCLUSÃO  -  HELP
	EndIf 
EndIf

If lRet
	FWExecView("","CTBA020",MODEL_OPERATION_DELETE,,{|| .T. },,,,,,)
Else
	If !Empty(cMsgError)
		Help(" ",1,STR0088,,STR0086,1,0,,,,,,{cMsgError}) 
	Else
		Help(" ",1,"020SUPERIO")
	EndIf
Endif

RestArea(aAreaCT1)

Return

//Carrega variaveis estaticas da rotina
Function LoadVar020()

If cTipoCTS == NIL
	cTipoCTS := FWSX3Util():GetFieldType('CTS_COLUNA')
EndIf

If __Release == NIL
	__Release := Iif(GetRPORelease() >= "12.1.2210" ,.T.,.F.) //// 2210
EndIf

return