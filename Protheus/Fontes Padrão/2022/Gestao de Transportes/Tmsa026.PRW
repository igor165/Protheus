#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TMSA026.CH"
#INCLUDE "RWMAKE.CH"

Static cAliasMrk := "" // Alias Do Arquivo Temporário Da FWMarkBrowse
Static cAliasMbw := "" // Alias Do Arquivo Temporário da FWMBrowse

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA026
@autor		: Eduardo Alberti
@descricao	: Aprovadores TMS
@since		: Nov./2014
@using		: Rotina De Cadastramento/Manutencao Dos Aprovadores Do Modulo TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA026()

	Local oMBrowse	:= Nil
	Local aArea		:= GetArea()

	Private aRotina	:= MenuDef("P")

	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If !(AliasInDic("DDY"))
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf	

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('DDY')
	oMBrowse:SetDescription( STR0001 + ' TMS') // "Cadastro De Aprovadores"
	oMBrowse:DisableDetails()

	oMBrowse:Activate()

	RestArea(aArea)

Return NIL
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@autor		: Eduardo Alberti
@descricao	: Modelo de Dados
@since		: Oct./2014
@using		: Rotina De Cadastramento/Manutencao Dos Aprovadores Do Modulo TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local aArea       := GetArea()
	Local oStructCab  := Nil
	Local oStructGr1  := Nil
	Local oModel      := Nil
	Local lGrdLim     := AliasInDic('DJP')

	//-----------------------------------------
	//--Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructCab := FWFormStruct(1,"DDY",{ |cCampo|   AllTrim( cCampo ) + "|" $ "DDY_USUARI|DDY_NOME|DDY_EMAIL|"  } )
	oStructGr1 := FWFormStruct(1,"DDY",{ |cCampo| !(AllTrim( cCampo ) + "|" $ "DDY_USUARI|DDY_NOME|DDY_EMAIL|") } )

	//-- Verifica Se Tabela DJP Existe No Dicionário
	If lGrdLim
		oStructGr2 := FwFormStruct( 1,"DJP" )
	EndIf	

	//-----------------------------------------
	//--Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New("MSTMSA026", /*Pré-Validação*/, { |oMdl| DDYPosVl( oMdl ) }/*Pos-Validacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields("TMSA026_CAB",/*cOwner*/, oStructCab)

	oModel:SetPrimaryKey({"DDY_FILIAL","DDY_USUARI","DDY_ROTINA"})

	oModel:GetModel("TMSA026_CAB"):SetDescription( STR0002 ) // "Aprovadores"

	oModel:AddGrid("TMSA026_IT1", "TMSA026_CAB", oStructGr1,/*bLinePre*/, { |oMdlG,nLine| fGrdLinePos( oMdlG, nLine) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:GetModel("TMSA026_IT1"):SetDescription( STR0003 ) // "Rotinas"

	oModel:SetRelation("TMSA026_IT1",{	{"DDY_FILIAL","xFilial('DDY')"} ,;
											{"DDY_USUARI","DDY_USUARI"    } ,;
											{"DDY_EMAIL","DDY_EMAIL"      }},;
											"DDY_FILIAL + DDY_USUARI" ) //DDY_ROTINA

	oModel:GetModel( "TMSA026_IT1" ):SetUniqueLine( { "DDY_ROTINA" } )

	//-- Verifica Se Tabela DJP Existe No Dicionário
	If lGrdLim	

		oModel:AddGrid("TMSA026_IT2", "TMSA026_IT1", oStructGr2,/*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

		oModel:GetModel("TMSA026_IT2"):SetDescription( STR0021 ) // "Limites Por Cód. De Bloqueio"

		oModel:SetRelation("TMSA026_IT2",{	{"DJP_FILIAL","xFilial('DJP')"	} ,;
												{"DJP_USUARI","DDY_USUARI"		} ,;
												{"DJP_ROTINA","DDY_ROTINA"}		},;
												DJP->(IndexKey( 1 )) ) //-- "DJP_FILIAL + DJP_USUARI + DJP_ROTINA + DJP_TPBLQ"

		oModel:GetModel( "TMSA026_IT2" ):SetUniqueLine( { "DJP_USUARI", "DJP_ROTINA", "DJP_TPBLQ" } )
		
		oModel:GetModel("TMSA026_IT2"):SetNoInsertLine( .T. )
		oModel:GetModel("TMSA026_IT2"):SetNoDeleteLine( .T. )
		oModel:GetModel("TMSA026_IT2"):SetOptional( .T. )
		
	EndIf		

	RestArea(aArea)

Return(oModel)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@autor		: Eduardo Alberti
@descricao	: Retorna a View (tela) da rotina
@since		: Oct./2014
@using		: Rotina De Cadastramento/Manutencao Dos Aprovadores Do Modulo TMS
@review    :
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local aArea       := GetArea()
	Local oView       := Nil
	Local oStructCAB  := Nil
	Local oStructGr1  := Nil
	Local oStructGr2  := Nil //-- Grid De Limites Por Cód. De Bloqueio
	Local lGrdLim     := AliasInDic('DJP')
	Local oModel      := FWLoadModel("TMSA026")

	oStructCab := FwFormStruct( 2,"DDY", { |cCampo|  AllTrim( cCampo ) + "|" $ "DDY_USUARI|DDY_NOME|DDY_EMAIL|" } )
	oStructGr1 := FwFormStruct( 2,"DDY", { |cCampo| !AllTrim( cCampo ) + "|" $ "DDY_USUARI|DDY_NOME|DDY_EMAIL|" } )
	
	//-- Verifica Se Tabela DJP Existe No Dicionário
	If lGrdLim
		oStructGr2 := FwFormStruct( 2,"DJP" )
	EndIf

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)

	oView:AddField( "TMSA026_CAB",oStructCab)
	oView:CreateHorizontalBox("CABEC",15)
	oView:SetOwnerView( "TMSA026_CAB","CABEC")

	oView:AddGrid("TMSA026_IT1",oStructGr1)
	oView:CreateHorizontalBox("GRID1",Iif(lGrdLim,55,85))
	oView:SetOwnerView( "TMSA026_IT1","GRID1")

	//-- Verifica Se Tabela DJP Existe No Dicionário
	If lGrdLim
		oView:AddGrid("TMSA026_IT2",oStructGr2)
		oView:CreateHorizontalBox("GRID2",30)
		oView:SetOwnerView( "TMSA026_IT2","GRID2")
	EndIf	

	RestArea(aArea)

Return oView

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Funcao Para Montagem Do Menu Funcional Padrao Protheus
@since		: Oct./2014
@using		: Rotina De Cadastramento/Manutencao Dos Aprovadores Do Modulo TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef(cTipo,cOrigem)

	Local aArea      := GetArea()
	Local aRotina    := {}

	Default cTipo  := "P"
	Default cOrigem:= ""

	If cTipo == "M"
		If cOrigem == 'TMSA029'
			ADD OPTION aRotina TITLE STR0004	ACTION 'TmDDYGrv("TMSA029")'      OPERATION 3 ACCESS 0 // 'Confirmar'
		Else
			ADD OPTION aRotina TITLE STR0004	ACTION 'TmDDYGrv()'      OPERATION 3 ACCESS 0 // 'Confirmar'
		EndIf

	ElseIf cTipo == "B"

		ADD OPTION aRotina TITLE STR0005	ACTION 'Tm026Leg()'      OPERATION 2 ACCESS 0 // Legenda

	ElseIf cTipo == "P"

		ADD OPTION aRotina TITLE STR0006	  			ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 DISABLE MENU 	// Pesquisar
		ADD OPTION aRotina TITLE STR0007	 			ACTION 'VIEWDEF.TMSA026' OPERATION 2 ACCESS 0 DISABLE MENU 	// Visualizar
		ADD OPTION aRotina TITLE STR0008    			ACTION 'VIEWDEF.TMSA026' OPERATION 3 ACCESS 0					// Incluir
		ADD OPTION aRotina TITLE STR0009    			ACTION 'VIEWDEF.TMSA026' OPERATION 4 ACCESS 0 DISABLE MENU	// Alterar
		ADD OPTION aRotina TITLE STR0010    			ACTION 'VIEWDEF.TMSA026' OPERATION 5 ACCESS 0 DISABLE MENU	// Excluir
		ADD OPTION aRotina TITLE STR0011  				ACTION 'Tmsa026Map()'    OPERATION 6 ACCESS 0 DISABLE MENU	// Mapa Aprovadores
		ADD OPTION aRotina TITLE STR0012				ACTION 'VIEWDEF.TMSA026' OPERATION 9 ACCESS 0 DISABLE MENU	// Copiar

		//--ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//--³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
		//--ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CDDDYMNU")
			ExecBlock("CDDDYMNU",.F.,.F.)
		EndIf
	EndIf

	RestArea(aArea)

Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DDYPosVl
@autor		: Eduardo Alberti
@descricao	: Validação
@since		: Oct./2014
@using		: Rotina De Cadastramento/Manutencao Dos Aprovadores Do Modulo TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function DDYPosVl(oModel)

	Local lRet       	:= .T.
	Local aArea	 	:= GetArea()
	Local nOperation 	:= 0 //oModel:GetOperation()

	Default oModel	:= FWModelActive()

	nOperation 		:= oModel:GetOperation()


	RestArea(aArea)

Return lRet
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA026
@autor		: Eduardo Alberti
@descricao	: Funcao Para Validação Da Linha Do Grid Apos Digitacao
@since		: Oct./2014
@using		: Rotina De Cadastramento/Manutencao Dos Aprovadores Do Modulo TMS
@review	:
/*/
//------------------------------------------------------------------------------------------------
Static Function fGrdLinePos( oModelDDY, nLinha)

	Local aArea       := GetArea()
	Local lRet        := .T.
	Local oModel      := oModelDDY:GetModel()
	Local lGrdLim     := AliasInDic('DJP')
	Local oModelDDY   := oModel:GetModel( 'TMSA026_IT1' )
	Local oModelDJP   := Iif( lGrdLim , oModel:GetModel( 'TMSA026_IT2' ), Nil )
	Local nOperation  := oModel:GetOperation()
	Local aSaveLines  := FWSaveRows()
	Local nI          := 0
	Local nJ          := 0

	//-- Validação Da Linha Do Grid Apos Digitacao
	If nOperation == 3 .Or. nOperation == 4
	
		//-- Valida Inicialmente o Nivel
		lRet := TmsVlDDY("DDY_NIVEL","V",nLinha)
		
		//-- Valida Em Seguida o Tipo De Liberação
		If lRet
			lRet := TmsVlDDY("DDY_TIPLIB","V",nLinha)
		EndIf

		//-- Verifica Se Campos De Valor Foram Preenchidos No Grid DJP
		If lRet .And. lGrdLim
			For nI := 1 To oModelDDY:Length()
			
				oModelDDY:GoLine( nI )
				
				//-- Verifica Se a Linha Já Está Deletada
				If !oModelDDY:IsDeleted()
			
					For nJ := 1 To oModelDJP:Length()
			
						oModelDJP:GoLine( nJ )
	
						//-- Verifica Se a Linha Está Deletada
						If !oModelDJP:IsDeleted()
					
							//-- Procura o Código De Bloqueio Bo Vetor aVetBlq
							If !Empty(oModelDJP:GetValue('DJP_TPBLQ')) .And. oModelDJP:GetValue('DJP_LIMITE') <= 0
								Help(" ", 1, "TMSA02601", , " "  + STR0022 + " " + oModelDDY:GetValue("DDY_ROTINA");
								                          + ", " + STR0023 + " " + oModelDJP:GetValue("DJP_TPBLQ" ), 2, 1) //-- Valor não informado !
								lRet := .F.
								Exit 								
							EndIf
						EndIf
					Next nJ
				EndIf
			Next nI
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsVlDDY
Validacoes Da Tabela DDY
@author Eduardo Alberti
@since 25/11/2014
@version P11
/*/
//-------------------------------------------------------------------
Function TmsVlDDY(cCampo,cTipo,cParam,nLinha)

	Local aArea      := GetArea()
	Local xRet       := Nil
	Local lGrdLim    := AliasInDic('DJP')
	Local oModel	   := FWModelActive()
	Local oModelDJP  := Iif( lGrdLim , oModel:GetModel( 'TMSA026_IT2' ), Nil )
	Local aSaveLines := FWSaveRows()
	Local cRotPsq    := oModel:GetValue( 'TMSA026_IT1', 'DDY_ROTINA')
	Local cLibPsq    := oModel:GetValue( 'TMSA026_IT1', 'DDY_TIPLIB')
	Local nNivel     := oModel:GetValue( 'TMSA026_IT1', 'DDY_NIVEL' )
	Local cTpBlq     := oModel:GetValue( 'TMSA026_IT1', 'DDY_TPBLQ' )
	Local aVetBlq    := {}
	Local nI         := 0
	Local nLinDJP    := 1
	Local cCodBlq    := ""
	Local lAchou     := .f.

	Default cCampo := ""
	Default cTipo  := ""
	Default cParam := ""
	Default nLinha := 0

	cCampo := Upper(Alltrim(cCampo))
	cTipo  := Upper(Alltrim(cTipo))

	If cCampo == "DDY_TIPLIB"

		If cTipo == "V" //-- Validacao

			xRet := .t. //-- Define Retorno Padrão Para Modelo Do Bloco De Execucao

			DbSelectArea("DDX")
			DbSetOrder(1) //-- DDX_FILIAL + DDX_ROTINA
			If MsSeek(xFilial("DDX") + cRotPsq ,.f. )

				If DDX->DDX_TPLIB == "1" .And. cLibPsq <> '1'
					Help(" ", 1, "TMSA02602", , STR0022 + " " + AllTrim(cRotPsq) + ". ", 2, 1) //-- Rotina só aceita liberação simples!
					xRet := .F.
				ElseIf DDX->DDX_TPLIB <> "1" .And. cLibPsq == '1'
					Help(" ", 1, "TMSA02603", , STR0022 + " " + AllTrim(cRotPsq) + ". ", 2, 1) //-- Rotina só aceita liberação por hierarquia ou todos os níveis!
					xRet := .F.
				EndIf
			EndIf
			
			// Limpa o Campo de nível
			If xRet .AND. cLibPsq $ "1|3" .AND. nNivel > 0
				oModel:LoadValue( 'TMSA026_IT1', 'DDY_NIVEL',0)
			EndIf
			
		ElseIf cTipo == "G" //-- Gatilho

			DbSelectArea("DDX")
			DbSetOrder(1) //-- DDX_FILIAL + DDX_ROTINA
			MsSeek(xFilial("DDX") + cRotPsq ,.F.)

			If DDX->DDX_TPLIB == '1' .And. cLibPsq <> '1'
				xRet := '1'
			ElseIf DDX->DDX_TPLIB == '2' .And. cLibPsq == '1'
				xRet := '2'
			Else
				xRet := cLibPsq
			EndIf
		EndIf
	ElseIf cCampo == "DDY_NIVEL"

		If cTipo == "V" //-- Validacao

			xRet := .t. //-- Define Retorno Padrão Para Modelo Do Bloco De Execucao

			DbSelectArea("DDX")
			DbSetOrder(1) //-- DDX_FILIAL + DDX_ROTINA
			If MsSeek(xFilial("DDX") + cRotPsq ,.f. )

				If ((DDX->DDX_TPLIB == "1") .OR. (DDX->DDX_TPLIB == "2" .AND. cLibPsq == "3")) .And. nNivel <> 0
					Help(" ", 1, "TMSA02604", , STR0022 + " " + AllTrim(cRotPsq) + ". ", 2, 1) //-- Para liberações simples ou de todos os níveis, informe nível igual a zero!
					xRet := .F.
				ElseIf DDX->DDX_TPLIB == "2" .AND. cLibPsq == "2" .And. (nNivel = 0 .Or. nNivel > DDX->DDX_NIVEIS)
					Help(" ", 1, "TMSA02605", , " 1 a " + StrZero(DDX->DDX_NIVEIS,TamSX3("DDX_NIVEIS")[1]);
					                          + ". " + STR0022 + " " + AllTrim(cRotPsq) + ". ", 2, 1) //-- Esta rotina só aceita níveis entre a seguinte faixa:
					xRet := .F.
				EndIf
			EndIf
		EndIf
	ElseIf cCampo == "DDY_TPBLQ"

		If cTipo == "V" //-- Validacao

			aVetBlq := StrToKarr(cTpBlq,',')
			cCampo  := ""
			xRet    := .t.

			For nI := 1 To Len(aVetBlq)

				DbSelectArea("DDV")
				DbSetOrder(1) //-- Rotinas X Cod.Bloqueios
				If !MsSeek(xFilial("DDV") + PadR(cRotPsq,TamSX3("DDV_ROTINA")[1]) + PadR(aVetBlq[nI],TamSX3("DDV_CODBLQ")[1]) )

					cCampo += Iif(Empty(cCampo),"",",") + PadR(aVetBlq[nI],TamSX3("DDV_CODBLQ")[1])

				EndIf
			Next nI

			If !Empty(cCampo)
				Help(" ", 1, "TMSA02606", , cCampo + ". " + STR0022 + " " + AllTrim(cRotPsq) + ". ", 2, 1) //-- Rotina não possui s(s) seguinte(s) código(s):
				xRet := .F.
			EndIf
			
			//-- Se Validou Códigos De Bloqueio, Carrega Grid De "Limites Por Bloqueios"
			If xRet .And. lGrdLim 

				oModel:GetModel("TMSA026_IT2"):SetNoInsertLine(.F.)
				
				For nI := 1 To Len(aVetBlq)
				
					//-- Posiciona Rotina X Bloqueios
					DbSelectArea("DDV")
					DbSetOrder(1) //-- Rotinas X Cod.Bloqueios
					If MsSeek(xFilial("DDV") + PadR(cRotPsq,TamSX3("DDV_ROTINA")[1]) + PadR(aVetBlq[nI],TamSX3("DDV_CODBLQ")[1]) )
					
						//-- Verifica Se o Campo Utiliza Controle De Valor
						If DDV->DDV_USEVAL == '1'

							cCodBlq := PadR(aVetBlq[nI],TamSX3("DDV_CODBLQ")[1])
							lAchou  := .f.
						
							//-- Procura Os Códigos De Bloqueios No Grid
							If !oModel:GetModel("TMSA026_IT2"):SeekLine({{"DJP_TPBLQ",cCodBlq} })
							
								nLinDJP  := oModelDJP:Length()
						       
								If oModelDJP:Length() > 1 .Or. ( oModelDJP:Length() = 1 .And. !Empty(oModelDJP:GetValue('DJP_TPBLQ')))
									
									nLinDJP := oModelDJP:AddLine()	
									
								EndIf
								
								oModelDJP:GoLine( nLinDJP )
													
								//--oModelDJP:SetValue('DJP_ROTINA', cRotPsq )
								oModelDJP:SetValue('DJP_TPBLQ' , cCodBlq )
								oModelDJP:SetValue('DJP_DESCR' , Posicione("DDV",1,xFilial("DDV") + PadR(cRotPsq,TamSX3("DDV_ROTINA")[1]) + PadR(aVetBlq[nI],TamSX3("DDV_CODBLQ")[1]) ,"DDV_DESCB"))
		
							EndIf
						EndIf
					EndIf		
					
				Next nI
				
				oModel:GetModel("TMSA026_IT2"):SetNoInsertLine(.T.)
							
				//-- Deleta Linha Do Grid De Valores Caso o Usuário Tenha Removido Um Código
				For nI := 1 To oModelDJP:Length()

					oModelDJP:GoLine( nI )
					
					//-- Procura o Código De Bloqueio Bo Vetor aVetBlq
					If !Empty(oModelDJP:GetValue('DJP_TPBLQ')) .And. aScan( aVetBlq , oModelDJP:GetValue('DJP_TPBLQ')) == 0 

						//-- Verifica Se a Linha Já Está Deletada
						If !oModelDJP:IsDeleted()
									
							oModel:GetModel("TMSA026_IT2"):SetNoDeleteLine( .F. )
							oModelDJP:DeleteLine() //-- Deleta a Linha Do Grid
							oModel:GetModel("TMSA026_IT2"):SetNoDeleteLine( .T. )
							
						EndIf
					EndIf						
				Next nI				
			EndIf
		EndIf
	EndIf

	FWRestRows( aSaveLines )
	RestArea(aArea)

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDYTpBl
FWMarkBrowse Para Seleção Dos Tipos De Bloqueios Constantes Na Tabela DDY
@author Eduardo Alberti
@since 26/11/2014
@version P11
/*/
//-------------------------------------------------------------------
Function TmsDDYTpBl(cOrigem)   

	Local aArea      := GetArea()
	Local aAlias     := {}
	Local oDlgMrk    := Nil
	Local aColumns   := {}
	Local cTrbMark   := {}
	Local aRotOld	 := Iif(Type("aRotina") <> "U",aClone(aRotina),{})
	Local lRet		 := .T.
	Local oModel	 := Nil
	Local cRotPsq    := ""
	Local cMarca     := ""
	
	Default cOrigem  := ""   //--TMSA026 (Em Branco) ou TMSA029- Manutenção Bloqueios (DDV1)
	VAR_IXB:= ""  //--Retorno para a Consulta DDV1

	If Empty(cOrigem)
		oModel	 := FWModelActive()
		cRotPsq  := oModel:GetValue( 'TMSA026_IT1', 'DDY_ROTINA')
	EndIf
	
	aRotina := MenuDef("M",cOrigem)

	If lRet

		//----------------------------------------------------------
		//--Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias		:= TmDDYExcQr(cRotPsq,cOrigem)
		cAliasMrk	:= aAlias[1]
		aColumns 	:= aAlias[2]

		If !Empty (cAliasMrk) 
			If !(cAliasMrk)->(Eof())

				//------------------------------------------
				//--Criação da FWMarkBrowse
				//------------------------------------------
				oMrkBrowse:= FWMarkBrowse():New()
				oMrkBrowse:SetFieldMark("DDV_OK")
				oMrkBrowse:SetOwner(oDlgMrk)
				oMrkBrowse:SetAlias(cAliasMrk)
				If Empty(cOrigem)
					oMrkBrowse:SetIniWindow({|| TmsDDYCt(oMrkBrowse,cAliasMrk) }) //-- Carrega Os Dados Marcados Anteriormente
				EndIf
				oMrkBrowse:SetMenuDef("TmsA026")
				oMrkBrowse:bMark    := {|| TmsDDYMk(cAliasMrk )}
				oMrkBrowse:bAllMark := {|| TmsDDYIn(cAliasMrk) }
				oMrkBrowse:SetDescription( STR0013 ) // "Selecione Os Códigos De Bloqueio Da Rotina"
				oMrkBrowse:SetColumns(aColumns)
				oMrkBrowse:DisableReport()
				oMrkBrowse:DisableConfig()
				oMrkBrowse:DisableSaveConfig()
				oMrkBrowse:Activate()

			Else
				Help(" ", 1, "RECNO")
			EndIf

			If !Empty (cAliasMrk)
				dbSelectArea(cAliasMrk)
				dbCloseArea()
				Ferase(cAliasMrk+GetDBExtension())
				Ferase(cAliasMrk+OrdBagExt())
				cAliasMrk := ""
			EndIf
		EndIf	
	Endif

	RestArea(aArea)

	If Len(aRotOld) > 0
		aRotina := aClone(aRotOld)
	EndIf

Return(.t.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TmDDYGrv
Rotina Acionada Pelo Botao "Confirmar" Do FWMarkBrowse
@author Totvs
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmDDYGrv(cOrigem)

	Local aArea       := GetArea()
	Local cValor      := ""

	Default cOrigem   := ""

	DbSelectArea(cAliasMrk)
	(cAliasMrk)->(DbGoTop())

	While !(cAliasMrk)->(Eof())

		If !Empty((cAliasMrk)->DDV_OK)
			cValor += Iif(Empty(cValor),"",",") + (cAliasMrk)->DDV_CODBLQ
		EndIf

		DbSelectArea(cAliasMrk)
		(cAliasMrk)->(DbSkip())
	EndDo

	oMrkBrowse:GetOwner():End()

	If Empty(cOrigem)    
		//-- Carrega Variavel De Memória
		M->DDY_TPBLQ := PadR(cValor,TamSX3("DDY_TPBLQ")[1])  //Retorno para a Consulta DDVBLQ
	Else
		VAR_IXB :=  PadR(cValor,99)  //Retorno para a Consulta DDV2
	EndIf
	
	RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}TmDDYExcQr
Executa Query Pesquisando Codigos de Códigos De Bloqueio Disponíveis
@author Eduardo Alberti
@since  26/11/2014
@version 11
/*/
//-------------------------------------------------------------------
Static Function TmDDYExcQr(cRotPsq,cOrigem)

	Local aArea      := GetArea()
	Local aStru      := {}
	Local aColumns   := {}	//Array com as colunas a serem apresentadas
	Local nX         := 0
	Local cArqTrab   := ""
	Local cQuery	 := ""
	Local cRealName	 := ""
	Local lRet		 := .T. 
	Local cCampos    := "DDV_CODBLQ|DDV_DESCB"

	Default cRotPsq  := ""
	Default cOrigem  := ""

	If cOrigem == 'TMSA029' 
		cCampos:= "DDV_CODBLQ|DDV_DESCB|DDV_ROTINA|DDV_DESROT"
		If !Empty(MV_PAR04) .And. ExistFunc("TMS029Par")
			cRotPsq:= TMS029Par(AllTrim(MV_PAR04))
		EndIf
	EndIf
	
	cQuery += " SELECT      '  ' , DDV.DDV_CODBLQ,DDV.DDV_DESCB,DDV.DDV_ROTINA,DDX.DDX_DESCR DDV_DESROT "
	cQuery += " FROM        " +	RetSqlName("DDV") + " DDV "

	cQuery += " LEFT JOIN        " +	RetSqlName("DDX") + " DDX "
	cQuery += " ON          DDX.DDX_FILIAL =  '" + xFilial("DDX") + "' "
	cQuery += " AND         DDX.DDX_ROTINA =  DDV.DDV_ROTINA "
	cQuery += " AND         DDX.D_E_L_E_T_ =  ' ' "

	cQuery += " WHERE       DDV.DDV_FILIAL =  '" + xFilial("DDV") + "' "

	If Empty(cOrigem)
		cQuery += " AND         DDV.DDV_ROTINA =  '" + PadR(cRotPsq,TamSX3("DDY_ROTINA")[1]) + "' "
	Else
		If !Empty(cRotPsq)
			cQuery += " AND         DDV.DDV_ROTINA IN  " +  cRotPsq + " "
		EndIf	
	EndIf

	cQuery += " AND         DDV.D_E_L_E_T_ =  ' ' "
	cQuery += " ORDER BY    DDV.DDV_CODBLQ "
 	cQuery := ChangeQuery(cQuery)
	 
	cChave		:= "DDV_ROTINA + DDV_CODBLQ + DDV_DESCB"
	
	Aadd(aStru, {"DDV_OK"     ,"C",2                      ,0}) //-- Campo Para Marcação
	Aadd(aStru, {"DDV_CODBLQ" ,"C",TamSX3("DDV_CODBLQ")[1],0})
	Aadd(aStru, {"DDV_DESCB"  ,"C",TamSX3("DDV_DESCB")[1] ,0})
	Aadd(aStru, {"DDV_ROTINA" ,"C",TamSX3("DDV_ROTINA")[1] ,0})
	Aadd(aStru, {"DDV_DESROT" ,"C",TamSX3("DDX_DESCR")[1] ,0})

	cArqTrab	:= GetNextAlias()
	
	oTemp	:= FwTemporaryTable():New(cArqTrab)
	oTemp:SetFields( aStru )
	oTemp:AddIndex("01", {"DDV_ROTINA","DDV_CODBLQ" , "DDV_DESCB"} )
	oTemp:Create()
	
	cRealName	:= oTemp:GetRealName()
	
	Processa( {|| lRet := TMSSqlToTemp(cQuery, aStru, cRealName , .T.  ) } )
	
	If !lRet
		cArqTrab	:= ""
		aColumns	:= {} 
		oTemp:Delete()
	
	Else
		//-- Posiciona no primeiro registro
		(cArqTrab)->(dbGoTop()) 
		
		//--Define as colunas a serem apresentadas na FWMarkBrowse
		For nX := 1 To Len(aStru)
			If	aStru[nX][1] $ cCampos
				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
				aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
				aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
				If !(aStru[nX][1] $ "DDV_DESROT")
					aColumns[Len(aColumns)]:SetPicture(PesqPict("DDV",aStru[nX][1]))
				EndIf	
			EndIf
		Next nX
	EndIf
	RestArea(aArea)

Return({cArqTrab,aColumns})
//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDYMk
Marcacao de um registro
@author Totvs
@since 28/10/2013
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDDYMk(cAliasTRB)

	Local lRet		:= .T.
	//--Local cMarca	:= oMrkBrowse:cMark


Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDYIn
Marcacao de vários registros
@author Totvs
@since 08/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDDYIn(cAliasTRB)

	Local nReg		:= (cAliasTRB)->(Recno())
	Local cMarca	:= oMrkBrowse:cMark

	DbSelectArea(cAliasTRB)
	DbGoTop()

	While !(cAliasTRB)->(Eof())
		If (cAliasTRB)->(MsRLock())
			If	(cAliasTRB)->DDV_OK == cMarca
				(cAliasTRB)->DDV_OK := "  "
				(cAliasTRB)->(MsUnlock())
			Else
				(cAliasTRB)->DDV_OK := cMarca
			Endif
		Endif
		(cAliasTRB)->(dbSkip())
	Enddo

	(cAliasTRB)->(dbGoto(nReg))

	oMrkBrowse:oBrowse:Refresh(.t.)

Return .T.
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmsDDYCt
@autor		: Eduardo Alberti
@descricao	: Marca No FWMarkBrowse Os Campos Informados Anteriormente
@since		: Dez./2014
@using		: Captura Valores Do Campo DDY_TPBLQ e Traz Marcado Na FWMarkBrowse
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TmsDDYCt(oMrkBrowse,cAliasMrk)

	Local aArea    := GetArea()
	Local oModel	 := FWModelActive()
	Local cContOld := oModel:GetValue( 'TMSA026_IT1', 'DDY_TPBLQ')
	Local cMarca	 := oMrkBrowse:cMark
	Local nReg		 := (cAliasMrk)->(Recno())
	
	//--Atualiza FWMarkBrowse Com Dados Já Informados No Campo
	If !Empty(cContOld)

		DbSelectArea(cAliasMrk)
		(cAliasMrk)->(DbGoTop())

		While !(cAliasMrk)->(Eof())

			If Alltrim((cAliasMrk)->DDV_CODBLQ) $ cContOld
				RecLock(cAliasMrk,.f.)
				(cAliasMrk)->DDV_OK := cMarca
				(cAliasMrk)->(MsUnlock())
			EndIf

			DbSelectArea(cAliasMrk)
			(cAliasMrk)->(DbSkip())
		EndDo
	EndIf

	(cAliasMrk)->(dbGoto(nReg))

	RestArea(aArea)

	oMrkBrowse:oBrowse:Refresh(.t.)

Return(.t.)
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Tmsa026Map
@autor		: Eduardo Alberti
@descricao	: FWMBrowse Mostrando Mapa De Aprovadores e Níveis
@since		: Dec./2014
@using		:
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function Tmsa026Map()

	Local aArea      := GetArea()
	Local aAlias     := {}
	Local oDlgMrk    := Nil
	Local aColumns   := {}
	Local aRotOld	   := Iif(Type("aRotina") <> "U",aClone(aRotina),{})
	Local lRet		   := .T.

	aRotina := MenuDef("B")

	If lRet

		//----------------------------------------------------------
		//--Retorna as colunas para o preenchimento da FWMarkBrowse
		//----------------------------------------------------------
		aAlias		:= TmMapExcQr()
		cAliasMbw	:= aAlias[1]
		aColumns 	:= aAlias[2]

		//-- Inclui Nome Dos Liberadores No Browse
		dbSelectArea(cAliasMbw)
		(cAliasMbw)->(DbGoTop())
		While !(cAliasMbw)->(Eof())
		
			If !Empty((cAliasMbw)->DDY_USUARI)
			
				RecLock(cAliasMbw,.f.)
				(cAliasMbw)->DDY_NOME := UPPER(USRFULLNAME((cAliasMbw)->DDY_USUARI))
				(cAliasMbw)->(MsUnlock())				
				
			EndIf	
		
			(cAliasMbw)->(DbSkip())
		EndDo		

		// Proteção De Erro Caso Usuario Cancele a Consulta
		If !Empty(cAliasMbw)

			// Identifica Os Niveis Faltantes
			fIdentNiv(cAliasMbw)

			(cAliasMbw)->(DbGoTop())
			If !(cAliasMbw)->(Eof())

				//------------------------------------------
				//--Criação da FWMarkBrowse no Layer LISTA_DAC
				//------------------------------------------
				oMBrowse:= FWMBrowse():New()

				oMBrowse:AddLegend("!Empty(DDY_USUARI)", "GREEN"  ,"Sim" ,"DDY_USUARI")
				oMBrowse:AddLegend(" Empty(DDY_USUARI)", "RED"    ,"Não" ,"DDY_USUARI")

				oMBrowse:SetOwner(oDlgMrk)
				oMBrowse:SetAlias(cAliasMbw)
				oMBrowse:SetMenuDef("TmsA026")
				oMBrowse:SetDescription( STR0011 ) // "Mapa Aprovadores"
				oMBrowse:SetColumns(aColumns)
				oMBrowse:DisableDetails() // Desabilita Barra De Detalhes Acima Da FwMBrowse

				oMBrowse:Activate()

			Else
				Help(" ", 1, "RECNO")
			EndIf


			dbSelectArea(cAliasMbw)
			dbCloseArea()
			Ferase(cAliasMbw+GetDBExtension())
			Ferase(cAliasMbw+OrdBagExt())
			cAliasMbw := ""
		EndIf
	EndIf

	RestArea(aArea)

	If Len(aRotOld) > 0
		aRotina := aClone(aRotOld)
	EndIf

Return(.t.)
//-------------------------------------------------------------------
/*/{Protheus.doc}TmMapExcQr
Executa Query Pesquisando Codigos de Códigos De Bloqueio Disponíveis
@author Eduardo Alberti
@since  26/11/2014
@version 11
/*/
//-------------------------------------------------------------------
Static Function TmMapExcQr(cRotPsq)

	Local aArea      := GetArea()
	Local aStru      := {}
	Local aColumns   := {}	//Array com as colunas a serem apresentadas
	Local nX         := 0
	Local aCampos    := {"DDV_ROTINA","DDX_DESCR","DDV_CODBLQ","DDV_DESCB","DDX_TPLIB","DDX_NIVEIS","DDY_USUARI","DDY_NOME","DDY_NIVEL","DDX_REGRA"}
	Local cArqTrab   := ""
	Local cQuery	 := ""
	Local cFuncNull  := ""
	Local oTemp		 := Nil 
	Local lRet		 := .T. 
	Local cRealName	 := ""

	// Parametros ParamBox.
	Local cTitle		:= STR0015 //"Parâmetros Da Consulta"
	Local aRet			:= {}
	Local aPar 			:= {}
	Local lObrig 		:= .t.
	Local cDbType		:= TCGetDB()

	// Tratamento para ISNULL em diferentes BD's
	Do Case
		Case cDbType $ "DB2/POSTGRES"
			cFuncNull	:= "COALESCE"
		Case cDbType $ "ORACLE/INFORMIX"
	  		cFuncNull	:= "NVL"
	 	Otherwise
	 		cFuncNull	:= "ISNULL"
	EndCase

	aAdd(aPar, {1, STR0016 ,DDY->DDY_ROTINA,  "", "", "DDX", "", 0, .F.})		// "Rotina De  :"
	aAdd(aPar, {1, STR0017 ,DDY->DDY_ROTINA,  "", "", "DDX", "", 0, lObrig})	// "Rotina Até :"

	Begin Sequence

	// Se o usuario confirmou os parametros.
		If !ParamBox(aPar, cTitle, @aRet,,,,,,,, .F.)
			Break
		EndIf

		cQuery += " SELECT      DDV.DDV_ROTINA,DDX.DDX_DESCR , "
		cQuery += "             DDV.DDV_CODBLQ,DDV.DDV_DESCB , "
		cQuery += "             DDX.DDX_TPLIB ,DDX.DDX_NIVEIS, "
		cQuery += "             " + cFuncNull + "(DDY.DDY_USUARI,'      ') AS DDY_USUARI , "
		cQuery += "             '' AS DDY_NOME ,"
		cQuery += "             " + cFuncNull + "(DDY.DDY_NIVEL,1)         AS DDY_NIVEL  , "
		cQuery += "             DDX.DDX_REGRA "
		cQuery += " FROM        " +	RetSqlName("DDV") + " DDV " //-- Rotinas X Cod.Bloqueios
		cQuery += " INNER JOIN  " +	RetSqlName("DDX") + " DDX " //-- Rotinas X Tip.Lib X Niveis
		cQuery += " ON          DDX.DDX_FILIAL   =  '" + xFilial("DDX") + "' "
		cQuery += " AND         DDX.DDX_ROTINA   =  DDV.DDV_ROTINA "
		cQuery += " AND         DDX.D_E_L_E_T_   =  ' ' "
		cQuery += " LEFT  JOIN  " +	RetSqlName("DDY") + " DDY " //-- Rotinas X Usuarios X TipBloq
		cQuery += " ON          DDY.DDY_FILIAL   =  '" + xFilial("DDY") + "' "
		cQuery += " AND         DDY.DDY_ROTINA   =  DDV.DDV_ROTINA "
		cQuery += " AND         DDY.DDY_STATUS   =  '1' " // -- Status Do Aprovador
		cQuery += " AND         ((DDY.DDY_TPBLQ  LIKE '%' || DDV.DDV_CODBLQ || '%') "
		cQuery += "             OR "
		cQuery += "             (DDX.DDX_TPLIB   =  '2' AND DDY.DDY_TIPLIB = '3')) "
		//	cQuery += " AND         DDY.DDY_USUARI   BETWEEN '" + aRet[3] + "' AND '" + aRet[4] + "' "
		cQuery += " AND         DDY.D_E_L_E_T_   =  ' ' "
		cQuery += " WHERE       DDV.DDV_FILIAL   =  '" + xFilial("DDV") + "' "
		cQuery += " AND         DDV.DDV_ROTINA   BETWEEN '" + aRet[1] + "' AND '" + aRet[2] + "' "
		cQuery += " AND         DDV.D_E_L_E_T_   =  ' ' "

		cQuery := ChangeQuery(cQuery)

		cChave		:= "DDV_ROTINA + DDV_CODBLQ + Str(DDY_NIVEL,1) + DDY_USUARI"

		For nX := 1 To Len(aCampos)			
			If MsSeek(aCampos[nX])
				aAdd(aStru, {GetSX3Cache(aCampos[nX],"X3_CAMPO"),GetSX3Cache(aCampos[nX],"X3_TIPO"),GetSX3Cache(aCampos[nX],"X3_TAMANHO"),GetSX3Cache(aCampos[nX],"X3_DECIMAL")})
			EndIf
		Next nX
		
		cArqTrab	:= GetNextAlias()
		
		oTemp	:= FwTemporaryTable():New(cArqTrab)
		oTemp:SetFields( aStru )
		oTemp:AddIndex("01", {"DDV_ROTINA","DDV_CODBLQ" , "DDY_NIVEL" , "DDY_USUARI"} )
		oTemp:Create()
		
		cRealName	:= oTemp:GetRealName()
		
		Processa( {|| lRet := TMSSqlToTemp(cQuery, aStru, cRealName , .T.  ) } )	// Cria arquivo temporario
		
		If !lRet
			oTemp:Delete()
		Else
			//-- Posiciona no primeiro registro
			(cArqTrab)->(dbGoTop()) 
		EndIf		

		// Acrescenta Aprovadores De Niveis
		fIncLibAl(cArqTrab,aRet[1],aRet[2])

		//--Define as colunas a serem apresentadas na FWMarkBrowse
		For nX := 1 To Len(aStru)

			DbSelectArea("SX3")
			DbSetOrder(2)
			If MsSeek(aStru[nX,1])

				cTab := SubStr(aStru[nX][1],1,At("_",aStru[nX][1]) -1)

				AAdd(aColumns,FWBrwColumn():New())
				aColumns[Len(aColumns)]:SetData( &("{||"+aStru[nX][1]+"}") )
				aColumns[Len(aColumns)]:SetTitle(RetTitle(aStru[nX][1]))
				aColumns[Len(aColumns)]:SetSize(aStru[nX][3])
				aColumns[Len(aColumns)]:SetDecimal(aStru[nX][4])
				aColumns[Len(aColumns)]:SetPicture(PesqPict(cTab,aStru[nX][1]))

			EndIf
		Next nX

	End Sequence

	RestArea(aArea)

Return({cArqTrab,aColumns})
//-------------------------------------------------------------------
/*/{Protheus.doc}fIdentNiv
@descricao	: Identifica Niveis Faltantes Por Rotina
@author Eduardo Alberti
@since  03/12/2014
@version 11
/*/
//-------------------------------------------------------------------
Static Function fIdentNiv(cAliasT)

	Local aArea := GetArea()
	Local aRots := {}
	Local nPos  := 0
	Local nI    := 0
	Local nJ    := 0

	If Select(cAliasT) <= 0
		Return()
	EndIf

	DbSelectArea(cAliasT)
	(cAliasT)->(DbGoTop())
	While !(cAliasT)->(Eof())

		nPos := aScan(aRots,{|x| x[1]+x[2]+Str(x[3],1) == ((cAliasT)->DDV_ROTINA + (cAliasT)->DDV_CODBLQ + Str((cAliasT)->DDY_NIVEL,1)) })

		If nPos == 0

			aAdd(aRots,{;
				(cAliasT)->DDV_ROTINA	,;	// 01
			(cAliasT)->DDV_CODBLQ	,;	// 02
			(cAliasT)->DDY_NIVEL		,;	// 03
			(cAliasT)->DDX_DESCR		,;	// 04
			(cAliasT)->DDV_DESCB		,;	// 05
			(cAliasT)->DDX_TPLIB		,;	// 06
			(cAliasT)->DDX_NIVEIS	})	// 07

		EndIf

		(cAliasT)->(DbSkip())
	EndDo

	For nI := 1 To Len(aRots)

		DbSelectArea("DDX")
		DbSetOrder(1)
		If MsSeek(xFilial("DDX") + aRots[nI,01],.f.) .And. DDX->DDX_TPLIB == '2' // Hierarquia

			For nJ := 1 To DDX->DDX_NIVEIS

				DbSelectArea(cAliasT) // cChave		:= "DDV_ROTINA + DDV_CODBLQ + Str(DDY_NIVEL,1) + DDY_USUARI"
				If !MsSeek(aRots[nI,1] + aRots[nI,2] + Str(nJ,1) )

					DbSelectArea(cAliasT)
					RecLock(cAliasT,.T.)

					(cAliasT)->DDV_ROTINA := aRots[nI,01]
					(cAliasT)->DDV_CODBLQ := aRots[nI,02]
					(cAliasT)->DDY_NIVEL  := nJ
					(cAliasT)->DDX_DESCR  := aRots[nI,04]
					(cAliasT)->DDV_DESCB := aRots[nI,05]
					(cAliasT)->DDX_TPLIB	 := aRots[nI,06]
					(cAliasT)->DDX_NIVEIS := aRots[nI,07]

					(cAliasT)->(MsUnlock())
				EndIf
			Next nJ
		EndIf
	Next nI

	RestArea(aArea)

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc}fIncLibAl
@descricao	: Inclui No Arquivo Temporario Os Aprovadores De Todos Niveis
@author Eduardo Alberti
@since  03/12/2014
@version 11
/*/
//-------------------------------------------------------------------
Static Function fIncLibAl(cAliasT,cRotDe,cRotAte)

	Local aArea   := GetArea()
	Local cTmp		:= GetNextAlias()
	Local cQuery  := ""
	Local i       := 0
	Local cDbType		:= TCGetDB()
	Local cFuncNull	        := ""

	// Tratamento para ISNULL em diferentes BD's
	Do Case
		Case cDbType $ "DB2/POSTGRES"
			cFuncNull	:= "COALESCE"
		Case cDbType $ "ORACLE/INFORMIX"
	  		cFuncNull	:= "NVL"
	 	Otherwise
	 		cFuncNull	:= "ISNULL"
	EndCase

	cQuery += " SELECT      DDV.DDV_ROTINA,DDX.DDX_DESCR , "
	cQuery += " 	          DDV.DDV_CODBLQ,DDV.DDV_DESCB , "
	cQuery += "             DDX.DDX_TPLIB ,DDX.DDX_NIVEIS, "
	cQuery += "             " + cFuncNull + "(DDY.DDY_USUARI,'      ') AS DDY_USUARI , "
	cQuery += "             " + cFuncNull + "(DDY.DDY_NIVEL,1)         AS DDY_NIVEL  , "
	cQuery += "             DDX.DDX_REGRA "
	cQuery += " FROM        " +	RetSqlName("DDY") + " DDY " //-- Rotinas X Usuarios X TipBloq
	cQuery += " INNER JOIN  " +	RetSqlName("DDX") + " DDX " //-- Rotinas X Tip.Lib X Niveis
	cQuery += " ON          DDX.DDX_FILIAL =  '" + xFilial("DDX") + "' "
	cQuery += " AND         DDX.DDX_ROTINA =  DDY.DDY_ROTINA "
	cQuery += " AND         DDX.D_E_L_E_T_ =  ' ' "
	cQuery += " INNER JOIN  " +	RetSqlName("DDV") + " DDV " //-- Rotinas X Cod.Bloqueios
	cQuery += " ON          DDV.DDV_FILIAL =  '" + xFilial("DDV") + "' "
	cQuery += " AND         DDV.DDV_ROTINA =  DDY.DDY_ROTINA "
	cQuery += " AND         DDV.D_E_L_E_T_ =  ' ' "
	cQuery += " WHERE       DDY.DDY_FILIAL =  '" + xFilial("DDY") + "' "
	cQuery += " AND         DDV.DDV_ROTINA BETWEEN '" + cRotDe + "' AND '" + cRotAte + "' "
	cQuery += " AND         DDY.DDY_STATUS =  '1' " // -- Status Do Aprovador
	cQuery += " AND         DDY.DDY_TIPLIB =  '3' "
	cQuery += " AND         DDY.D_E_L_E_T_ =  ' ' "

	cQuery := ChangeQuery(cQuery)

	If Select(cTmp) > 0
		(cTmp)->(DbCloseArea())
	EndIf

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cTmp, .F., .T.)

	DbSelectArea(cTmp)
	(cTmp)->(DbGoTop())
	While !Eof()

		For i := 1 To (cTmp)->DDY_NIVEL

			DbSelectArea(cAliasT) // cChave		:= "DDV_ROTINA + DDV_CODBLQ + Str(DDY_NIVEL,1) + DDY_USUARI"
			If !MsSeek((cTmp)->DDV_ROTINA + (cTmp)->DDV_CODBLQ + Str(i,1) + (cTmp)->DDY_USUARI )

				DbSelectArea(cAliasT)
				RecLock(cAliasT,.T.)

				(cAliasT)->DDV_ROTINA := (cTmp)->DDV_ROTINA
				(cAliasT)->DDV_CODBLQ := (cTmp)->DDV_CODBLQ
				(cAliasT)->DDY_NIVEL  := i
				(cAliasT)->DDX_DESCR  := (cTmp)->DDX_DESCR
				(cAliasT)->DDV_DESCB  := (cTmp)->DDV_DESCB
				(cAliasT)->DDX_TPLIB  := (cTmp)->DDX_TPLIB
				(cAliasT)->DDX_NIVEIS := (cTmp)->DDX_NIVEIS
				(cAliasT)->DDY_USUARI := (cTmp)->DDY_USUARI
				(cAliasT)->(MsUnlock())

			EndIf

		Next i

		DbSelectArea(cTmp)
		(cTmp)->(DbSkip())
	EndDo

	(cAliasT)->(DbGoTop())

	If Select(cTmp) > 0
		(cTmp)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return()
//-------------------------------------------------------------------
/*/{Protheus.doc}Tm026Leg
@descricao	: Legenda Do Mapa De Aprovadores
@author Eduardo Alberti
@since  04/12/2014
@version 11
/*/
//-------------------------------------------------------------------
Function Tm026Leg()

	Local aLegenda  := {}
	Local cTitulo   := STR0011 // "Mapa Aprovadores"

	AADD(aLegenda,{"BR_VERDE"  		, STR0018	})	// "Informado"
	AADD(aLegenda,{"BR_VERMELHO" 	, STR0019	})	// "Sem Aprovador"

	BrwLegenda(cTitulo, STR0020 , aLegenda) // "Legenda"

Return()

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA026Val
@autor		: Eduardo Alberti
@descricao	: Funcao Para Validação Do Campo DJP_LIMITE
@since		: Nov./2016
@using		: Rotina De Cadastramento/Manutencao Dos Aprovadores Do Modulo TMS
@review	:
/*/
//------------------------------------------------------------------------------------------------
Function TMSA026Val()

	Local aArea       := GetArea()
	Local lRet        := .T.
	Local oModel      := FWModelActive()
	Local oModelDJP   := oModel:GetModel( 'TMSA026_IT2' )
	Local oModelDDY   := oModel:GetModel( 'TMSA026_IT1' )
	Local oModelCab   := oModel:GetModel( 'TMSA026_CAB' )
	Local cRotina     := oModelDDY:GetValue( 'DDY_ROTINA')
	Local cTpBlq      := oModel:GetValue( 'TMSA026_IT2', 'DJP_TPBLQ')
	Local cUsBlq      := oModelCab:GetValue( 'DDY_USUARI')
	Local nOperation  := oModel:GetOperation()
	Local cValRef     := Replicate("9", 12 )
	Local cQuery      := ""
	Local nTotReg     := 0
	Local cAliasT     := GetNextAlias()
	Local bQuery      := {|| Iif(Select(cAliasT) > 0, (cAliasT)->(dbCloseArea()), Nil) , dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T.), dbSelectArea(cAliasT), (cAliasT)->(dbEval({|| nTotReg++ })), (cAliasT)->(dbGoTop())  }

	//-- Validação Da Linha Do Grid Apos Digitacao
	If nOperation == 3 .Or. nOperation == 4
		
		//-- Verifica Se a Linha Está Deletada
		If !oModelDJP:IsDeleted()
		
			If oModel:GetValue( 'TMSA026_IT2', 'DJP_LIMITE') < Val(cValRef)
					
				//-- Pesquisa Se Existe Primeiro Valor (Limite)
				cQuery += " SELECT      DJP.DJP_LIMITE "
				cQuery += " FROM        	" +	RetSqlName("DJP") + " DJP " 
				cQuery += " WHERE       DJP.DJP_FILIAL  =  '" + FWxFilial("DJP") + "' "
				cQuery += " AND         DJP.DJP_ROTINA  =  '" + cRotina          + "' "
				cQuery += " AND         DJP.DJP_TPBLQ   =  '" + cTpBlq           + "' "
				cQuery += " AND         DJP.DJP_USUARI  <> '" + cUsBlq           + "' "
				cQuery += " AND         DJP.DJP_LIMITE  >=  " + cValRef          + "  "
				cQuery += " AND         DJP.D_E_L_E_T_ =  ' ' "
	
				cQuery := ChangeQuery(cQuery)
	
				//-- Executa Query
				Eval(bQuery)
	
				If nTotReg == 0
					Help(" ", 1, "TMSA02607", , "( " + Transform(Val(cValRef), PesqPict("DJP", "DJP_LIMITE")) + ")", 2, 1) //-- Obrigatório valor ilimitado (Administrador) para no mínimo um cadastro!
					lRet := .F.			
				EndIf
				
				If Select(cAliasT) > 0
					(cAliasT)->(DbCloseArea())
				EndIf
			EndIf	
		EndIf
	EndIf

	RestArea(aArea)

Return lRet

