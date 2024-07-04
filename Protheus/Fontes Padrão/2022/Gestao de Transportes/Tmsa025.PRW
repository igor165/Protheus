#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSA025.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA025
@autor		: Eduardo Alberti
@descricao	: Rotinas X Bloqueios
@since		: Dez./2014
@using		: Tela Cadastramento Rotinas X Bloqueios (TMSA025 - Rotinas X Bloqueios)
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA025()

	Local oMBrowse	:= Nil
	Local aArea		:= GetArea()

	//-- Proteção De Erro Da Rotina Caso o Dicionário Da Rotina Não Exista
	If !(AliasInDic("DDX"))
		//-- Mensagem genérica solicitando a atualização do sistema.
		MsgNextRel()
		Return()
	EndIf	

	Private aRotina	:= MenuDef()

	//-- Dá Carga Inicial As Tabelas DDX e DDV
	AjustaTab()

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias('DDX')
	oMBrowse:SetDescription( STR0001 + " TMS " ) // 'Cadastro De Rotinas X Bloqueios'
	oMBrowse:DisableDetails()

	oMBrowse:Activate()

	RestArea(aArea)

Return NIL
//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
@autor		: Eduardo Alberti
@descricao	: ModelDef da tela Rotinas X Bloqueios
@since		: Oct./2014
@using		: Cadastro Rotinas X Bloqueios TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ModelDef()

	Local aArea			:= GetArea()
	Local oStructCab 	:= Nil
	Local oStructVie 	:= Nil
	Local oModel     	:= Nil

	//-----------------------------------------
	//--Monta a estrutura do formulário com base no dicionário de dados
	//-----------------------------------------
	oStructCab := FWFormStruct(1,"DDX" )
	oStructVie := FWFormStruct(1,"DDV" )

	//-----------------------------------------
	//--Monta o modelo do formulário
	//-----------------------------------------
	oModel:= MPFormModel():New("MSTMSA025", /*Pré-Validação*/, { |oMdl| DDVPosVl( oMdl ) }/*Pos-Validacao*/, /*bCommit*/, /*bCancel*/ )

	oModel:AddFields("TMSA025_CAB",/*cOwner*/, oStructCab)

	oModel:SetPrimaryKey({"DDX_FILIAL","DDX_ROTINA"})

	oModel:GetModel("TMSA025_CAB"):SetDescription( STR0002 ) // "Rotina"

	oModel:AddGrid("TMSA025_ITM", "TMSA025_CAB", oStructVie,{ |oMdlG, nLine, cAction,cField| fGrdLinePre(oMdlG, nLine, cAction, cField) }/*bLinePre*/, { |oMdlG,nLine| fGrdLinePos( oMdlG, nLine) }/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

	oModel:GetModel("TMSA025_ITM"):SetDescription( STR0003 ) // "Códigos Bloqueio"

	oModel:SetRelation("TMSA025_ITM",{	{"DDV_FILIAL",'xFilial("DDV")'},;
		{"DDV_ROTINA","DDX_ROTINA"    } }, DDV->(IndexKey(1)))

	oModel:GetModel( "TMSA025_ITM" ):SetUniqueLine( { "DDV_CODBLQ" } )

	//-- oModel:GetModel("TMSA025_ITM"):SetNoInsertLine(.F.)

	RestArea(aArea)

Return(oModel)

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
@autor		: Eduardo Alberti
@descricao	: Retorna a View (tela) da rotina
@since		: Oct./2014
@using		: Cadastro Rotinas X Bloqueios TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function ViewDef()

	Local aArea			:= GetArea()
	Local oView			:= Nil
	Local oStructCAB	:= Nil
	Local oStructVie	:= Nil
	Local oModel     	:= FWLoadModel("TMSA025")

	oStructCab := FwFormStruct( 2,"DDX" )
	oStructVie := FwFormStruct( 2,"DDV" )

	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:EnableControlBar(.T.)

	oView:AddField( "TMSA025_CAB",oStructCab)
	oView:CreateHorizontalBox("CABEC",25)
	oView:SetOwnerView( "TMSA025_CAB","CABEC")

	oView:AddGrid("TMSA025_ITM",oStructVie)
	oView:CreateHorizontalBox("GRID",75)
	oView:SetOwnerView( "TMSA025_ITM","GRID")

	RestArea(aArea)

Return oView

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
@autor		: Eduardo Alberti
@descricao	: Funcao Para Montagem Do Menu Funcional Padrao Protheus
@since		: Oct./2014
@using		: Cadastro Rotinas X Bloqueios TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef(cTipo)

	Local aArea      := GetArea()
	Local aRotina    := {}

	Default cTipo    := ""

	If cTipo == "M"
		ADD OPTION aRotina TITLE STR0069   		ACTION 'TmsDDXGrv()' OPERATION 3 ACCESS 0 				// 'Confirmar'
	Else
		ADD OPTION aRotina TITLE STR0004	  	ACTION 'PesqBrw'         OPERATION 1 ACCESS 0 DISABLE MENU 	// 'Pesquisar'
		ADD OPTION aRotina TITLE STR0005	 	ACTION 'VIEWDEF.TMSA025' OPERATION 2 ACCESS 0 DISABLE MENU 	// 'Visualizar'
		ADD OPTION aRotina TITLE STR0006    	ACTION 'VIEWDEF.TMSA025' OPERATION 3 ACCESS 0 				// 'Incluir'
		ADD OPTION aRotina TITLE STR0007    	ACTION 'VIEWDEF.TMSA025' OPERATION 4 ACCESS 0 DISABLE MENU	// 'Alterar'
		ADD OPTION aRotina TITLE STR0008    	ACTION 'VIEWDEF.TMSA025' OPERATION 5 ACCESS 0 DISABLE MENU	// 'Excluir'
		ADD OPTION aRotina TITLE STR0009		ACTION 'VIEWDEF.TMSA025' OPERATION 8 ACCESS 0 DISABLE MENU	// 'Imprimir'
		ADD OPTION aRotina TITLE STR0010		ACTION 'VIEWDEF.TMSA025' OPERATION 9 ACCESS 0 DISABLE MENU	// 'Copiar'

		//--ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//--³ Ponto de entrada utilizado para inserir novas opcoes no array aRotina  ³
		//--ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If ExistBlock("CDDDVMNU")
			ExecBlock("CDDDVMNU",.F.,.F.)
		EndIf
	EndIf

	RestArea(aArea)

Return aRotina

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} DDVPosVl
@autor		: Eduardo Alberti
@descricao	: Nao Permite Excluir Dados Incluidos Pelo Sistema
@since		: Oct./2014
@using		: Cadastro Rotinas X Bloqueios TMS
@review	:
/*/
//-------------------------------------------------------------------------------------------------
Function DDVPosVl(oModel)

	Local lRet        := .T.
	Local aArea       := GetArea()
	Local aArDDV      := DDV->(GetArea())
	Local nOperation  := oModel:GetOperation()
	Local cRotina     := oModel:GetValue( 'TMSA025_CAB', 'DDX_ROTINA')
	Local cTpLib      := oModel:GetValue( 'TMSA025_CAB', 'DDX_TPLIB')
	Local nNiveis     := oModel:GetValue( 'TMSA025_CAB', 'DDX_NIVEIS')

	If nOperation == MODEL_OPERATION_DELETE // Exclusão

		DbSelectArea("DDV")
		DbSetOrder(1)
		If MsSeek(xFilial("DDV") + cRotina )

			While DDV->(!Eof()) .And. (DDV->DDV_ROTINA == cRotina)

				If DDV->DDV_PROPRI == '1'
					Help( ,, 'TMSA02503',, STR0011 , 1, 0)	// 'Cadastros Do Sistema Não Podem Ser Excluídos!'
					lRet := .F.
					Exit
				EndIf

				DbSelectArea("DDV")
				DDV->(DbSkip())
			EndDo
		EndIf
	ElseIf nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE 
	
		//-- Se a Forma De Liberação For Hierarquica o Nivel De Alçadas Deve Ser Maior Que 1
		If cTpLib == '2' .And. nNiveis <= 1
		
			lRet := .F.			
			Help( ,, 'TMSA02504',, STR0053 , 1, 0)	// 'Para Tipo De Liberação 2-Hierarquia o Nível De Liberação Deve Ser Maior Que 1 !'

		EndIf
	EndIf

	RestArea(aArDDV)
	RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA025
@autor		: Eduardo Alberti
@descricao	: Funcao Para Validação Da Linha Do Grid Apos Digitacao
@since		: Oct./2014
@using		: Cadastro Rotinas X Bloqueios TMS
@review	:
/*/
//------------------------------------------------------------------------------------------------
Static Function fGrdLinePos( oModelGrid, nLinha)

	Local aArea			:= GetArea()
	Local lRet   		:= .T.
	Local oModel     	:= oModelGrid:GetModel()
	Local nOperation 	:= oModel:GetOperation()
	Local cRotDDV 		:= ''
	Local cCodBlq 		:= ''
	Local cPropri 		:= ''

	//-- Validação Da Linha Do Grid Apos Digitacao
	If nOperation == 4

		cRotDDV := oModel:GetValue( 'TMSA025_CAB', 'DDX_ROTINA')
		cCodBlq := oModel:GetValue( 'TMSA025_ITM', 'DDV_CODBLQ')
		cPropri := oModel:GetValue( 'TMSA025_ITM', 'DDV_PROPRI')

		If cPropri == '1' // Registro Do Sistema

			// Se Posicionar Nao Foi Alterado o Código
			DbSelectArea("DDV")
			DbSetOrder(1) //-- DDV_FILIAL+DDV_ROTINA+DDV_CODBLQ
			If !MsSeek(xFilial("DDV") + cRotDDV + cCodBlq )

				Help( ,, 'HELP',, STR0012 , 1, 0)	// 'Somente Registros de Usuário Podem Ser Alterados!'
				lRet := .f.

			EndIf
		EndIf
	EndIf

	RestArea(aArea)

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} TmsVlDDV
Validação De Dados Padrão Do Sistema
@author Eduardo Alberti
@since 25/11/2014
@version P11
/*/
//-------------------------------------------------------------------
Function TmsVlDDV(cRotina,cCodBlq)

	Local aArea       := GetArea()
	Local lRet        := .t.
	Local oModel      := FWModelActive()
	Local oModelDDV   := oModel:GetModel( 'TMSA025_ITM' )
	Local nOperation  := oModel:GetOperation()
	Local cPropri     := oModel:GetValue( 'TMSA025_ITM','DDV_PROPRI')
	Local cCampo      := ReadVar()
	Local nI          := 0

	If "DDV_CODBLQ" $ cCampo .Or. "DDV_DESCB" $ cCampo

		If nOperation == 4 .And. cPropri == '1'
			Help( ,, 'HELP',, STR0012 , 1, 0)	// 'Somente Registros de Usuário Podem Ser Alterados!'
			lRet := .F.
		EndIf
	EndIf
	
	RestArea(aArea)

Return(lRet)
//-------------------------------------------------------------------
/*/{Protheus.doc} fGrdLinePre
Valida Exclusão De Linhas Dentro da Rotina.
@author Eduardo Alberti
@since 02/12/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function fGrdLinePre( oModelGrid, nLinha, cAcao, cCampo )

	Local lRet       := .T.
	Local oModel     := oModelGrid:GetModel()
	Local nOperation := oModel:GetOperation()
	Local cPropri    := oModel:GetValue( 'TMSA025_ITM','DDV_PROPRI')

	// Valida se pode ou não apagar uma linha do Grid
	If cAcao == 'DELETE' .AND. nOperation == MODEL_OPERATION_UPDATE

		If cPropri == '1'
			Help( ,, 'HELP',, STR0011 , 1, 0)	// 'Cadastros Do Sistema Não Podem Ser Excluídos!'
			lRet := .F.
		EndIf
	EndIf

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaTab
Carga Inicial - Atualiza Tabelas DDX e DDV Conforme Padrão Do Sistema.
@author Eduardo Alberti
@since 02/03/2014
@version P11
/*/
//-------------------------------------------------------------------
Static Function AjustaTab()

	Local aArea 	:= GetArea()
	Local aRots 	:= {}
	Local aCods 	:= {}
	Local nI    	:= 0
	Local nTamRot	:= 0
	Local cParDIV 	:= SuperGetMv("MV_TMSINCO",.F.,"" ) //-- A=Todas;B=Calculo Do Frete;C=Viagem;D=Solicitação De Coleta;E=Agendamento;F=Cotação;Em Branco=Nao Controla.
	Local cParRRE 	:= SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
	Local lAtivo	:= .f.

	//-- Verifica Dicionários
	If AliasInDic('DDX') .And. AliasInDic('DDV')

		//-- Verifica Disponibilidade Tabelas
		If ChkFile('DDX') .And. ChkFile('DDV')

			//-- Carrega Vetor De Rotinas
			aAdd(aRots,{ 'TMSA040' , STR0018 , STR0019 })	//-- 'COTACAO DE FRETE      '	,'COT. FRETE '

			aAdd(aRots,{ 'TMSA140' , STR0015 , STR0015 })	//-- 'VIAGEM                '	,'VIAGEM     '

			aAdd(aRots,{ 'TMSA200' , STR0013 , STR0014 })	//-- 'CALCULO DO FRETE      '	,'CALC. FRETE'

			aAdd(aRots,{ 'TMSA460' , STR0016 , STR0017 })	//-- 'SOLICITACAO DE COLETA '	,'SOL. COLETA'

			aAdd(aRots,{ 'TMSA055' , STR0049 , STR0050 })	//-- 'ETIQUETAS INTEGRAÇÃO  '	,'ETIQUETAS  '

			aAdd(aRots,{ 'TMSA310' , STR0054 , STR0055 })	//-- 'FECHAMENTO DE VIAGEM'  ,'FEC.VIAGEM  '

			//aAdd(aRots,{ 'TMSA055' , STR0043 , STR0044 })	//-- 'CONFERENCIA ETIQUETAS' ,'ETIQUETAS  '

			aAdd(aRots,{ 'TMSA360' , STR0056 , STR0057 })	//-- 'REGISTRO DE OCORRÊNCIAS'	,'OCORRÊNCIAS'

			//-- Carrega Vetor De Códigos De Bloqueios
			aAdd(aCods,{ 'TMSA040' , 'CR' , STR0020 , '2' })	//-- 'CLASSE DE RISCO DE PRODUTOS (ONU)	  		'
			aAdd(aCods,{ 'TMSA040' , 'DC' , STR0021 , '2' })	//-- 'DESCONTO MAIOR QUE CONTRATO    	    		'
			aAdd(aCods,{ 'TMSA040' , 'RR' , STR0042 , '2' })	//-- 'REGRA DE RESTRICAO DE EMBARQUE     	     	'

			aAdd(aCods,{ 'TMSA055' , 'EC' , STR0045 , '2' })	//-- 'ERRO CONFERENCIA ETIQUETAS                 '

			aAdd(aCods,{ 'TMSA140' , '10' , STR0022 , '2' })	//-- 'BLOQUEIO VALOR			     					'
			aAdd(aCods,{ 'TMSA140' , '20' , STR0023 , '2' })	//-- 'BLOQUEIO PESO.			     					'
			aAdd(aCods,{ 'TMSA140' , '30' , STR0024 , '2' })	//-- 'BLOQUEIO SEGURO.		     					'
			aAdd(aCods,{ 'TMSA140' , '40' , STR0025 , '2' })	//-- 'BLOQUEIO CAPACIDADE.		     				'
			aAdd(aCods,{ 'TMSA140' , '50' , STR0026 , '2' })	//-- 'ANO DE FABRICACAO DO VEICULO.	    		'
			aAdd(aCods,{ 'TMSA140' , '60' , STR0027 , '2' })	//-- 'MOTORISTA HABILITADO PARA CARGA PERIGOSA 	'
			aAdd(aCods,{ 'TMSA140' , '70' , STR0028 , '2' })	//-- 'BLOQUEIO DE CAPACIDADE DO CAVALO	  		   	'
			aAdd(aCods,{ 'TMSA140' , '80' , STR0029 , '2' })	//-- 'FRETE A PAGAR			     					'
			aAdd(aCods,{ 'TMSA140' , '90' , STR0030 , '2' })	//-- 'RENTABILIDADE DE ROTA			     			'
			aAdd(aCods,{ 'TMSA140' , '98' , STR0046 , '2' })	//-- 'FALHA CARREGAMENTO                 	     	'
			aAdd(aCods,{ 'TMSA140' , '99' , STR0047 , '2' })	//-- 'FALHA DESCARREGAMENTO              	     	'
			aAdd(aCods,{ 'TMSA140' , 'CR' , STR0020 , '2' })	//-- 'CLASSE DE RISCO DE PRODUTOS (ONU)	    	'
			aAdd(aCods,{ 'TMSA140' , 'D1' , STR0031 , '2' })	//-- 'DOC. PENDENTE - FORNEC. PROP. DO VEICULO 	'
			aAdd(aCods,{ 'TMSA140' , 'D2' , STR0032 , '2' })	//-- 'DOCUMENTACAO PENDENTE - FORNEC. AJUDANTE 	'
			aAdd(aCods,{ 'TMSA140' , 'D3' , STR0033 , '2' })	//-- 'DOCUMENTACAO PENDENTE - MOTORISTA	     	'
			aAdd(aCods,{ 'TMSA140' , 'D4' , STR0034 , '2' })	//-- 'PERIODO DE PREST. SERV. EXPIRADO		     	'
			aAdd(aCods,{ 'TMSA140' , 'D5' , STR0035 , '2' })	//-- 'MANUTENCAO DE ATIVOS		     				'
			aAdd(aCods,{ 'TMSA140' , 'D6' , STR0036 , '2' })	//-- 'MOTORISTA/VEICULO DE FILIAIS DIFERENTES.	'
			aAdd(aCods,{ 'TMSA140' , 'I1' , STR0037 , '2' })	//-- 'PERMISSO VENCIDO			     				'
			aAdd(aCods,{ 'TMSA140' , 'I2' , STR0038 , '2' })	//-- 'AUSENCIA DE PERMISSO		     				'
			aAdd(aCods,{ 'TMSA140' , 'I3' , STR0039 , '2' })	//-- 'AUSENCIA DE PERMISSO PARA A REGIAO	     	'
			aAdd(aCods,{ 'TMSA140' , 'J1' , STR0040 , '2' })	//-- 'JUSTIFICATIVA PENDENTE.		     			'
			aAdd(aCods,{ 'TMSA140' , 'RR' , STR0042 , '2' })	//-- 'REGRA DE RESTRICAO DE EMBARQUE     	     	'
			aAdd(aCods,{ 'TMSA140' , 'R1' , STR0048 , '2' })	//-- 'RESTRICOES						     	     	'

			aAdd(aCods,{ 'TMSA200' , 'CR' , STR0020 , '2' })	//-- 'CLASSE DE RISCO DE PRODUTOS (ONU)	     	'
			aAdd(aCods,{ 'TMSA200' , 'RR' , STR0042 , '2' })	//-- 'REGRA DE RESTRICAO DE EMBARQUE     	     	'

			aAdd(aCods,{ 'TMSA460' , 'CR' , STR0020 , '2' })	//-- 'CLASSE DE RISCO DE PRODUTOS (ONU)	     	'
			aAdd(aCods,{ 'TMSA460' , 'LC' , STR0041 , '2' })	//-- 'LIMITE CREDITO                           	'
			aAdd(aCods,{ 'TMSA460' , 'RR' , STR0042 , '2' })	//-- 'REGRA DE RESTRICAO DE EMBARQUE     	     	'

			aAdd(aCods,{ 'TMSA310' , 'RR' , STR0042 , '2' })	//-- 'REGRA DE RESTRICAO DE EMBARQUE     	     	'
			
			If TableInDic("DL3")
				aAdd(aCods,{ 'TMSA310' , 'RP' , STR0065 , '2' })	//-- 'RENTABILIDADE PREVIA     	     	'
			EndIf
			
			If TableInDic("DLU")
				aAdd(aCods,{ 'TMSA310' , 'RT' , STR0066 , '2' }) //-- ROTEIRIZADOR
			EndIf

			//-- Relaciona Criação Dos Códigos De Bloqueio à Existencia Dos Campos Da Rotina
			If DT2->(ColumnPos('DT2_CDPASR')) > 0
				aAdd(aCods,{ 'TMSA360' , '16' , STR0058 , '1' })	//-- 'RECEITA - CT-E COMPLEMENTO         	     	'
				aAdd(aCods,{ 'TMSA360' , '17' , STR0059 , '1' })	//-- 'DESPESA - COMPL.CONTR.CARRETEIRO   	     	'
				aAdd(aCods,{ 'TMSA360' , '18' , STR0060 , '1' })	//-- 'RECEITA/DESPESA - CTE COMPL. / COMPL.CTC  	'
				aAdd(aCods,{ 'TMSA360' , '19' , STR0061 , '1' })	//-- 'RECEITA - COBRANCA TENTATIVA ENTREGA     	'
				aAdd(aCods,{ 'TMSA360' , '20' , STR0062 , '1' })	//-- 'RECEITA - COBRANCA RETORNO        	     	'
			EndIf	
			If DT2->(ColumnPos('DT2_PRZENT')) > 0
				aAdd(aCods,{ 'TMSA360' , 'PR' , STR0067 , '2' })	//-- 'PRAZO DE ENTREGA'
			EndIf


			//-- Inicializa Controle Transacional
			Begin Transaction

				//-- Atualiza Tabela 'DDX'
				nTamRot := TamSX3("DDX_ROTINA")[1]
				For nI := 1 To Len(aRots)

					DbSelectArea('DDX')
					DbSetOrder(1)
					If !MsSeek(xFilial('DDX') + PadR(aRots[nI,01],nTamRot))

						RecLock('DDX',.T.)
						Replace DDX->DDX_FILIAL With xFilial('DDX')
						Replace DDX->DDX_ROTINA With PadR(aRots[nI,01],nTamRot)
						Replace DDX->DDX_DESCR  With aRots[nI,02]
						Replace DDX->DDX_DESCRS With aRots[nI,03]
						Replace DDX->DDX_TPLIB  With '1'			//-- Simples
						Replace DDX->DDX_NIVEIS With 0				//-- Zero Niveis
						Replace DDX->DDX_ATIVO  With '2'			//-- Desativado
						DDX->(MsUnlock())

					EndIf
				Next nI

				//-- Atualiza Tabela 'DDV'
				nTamRot := TamSX3("DDV_ROTINA")[1]
				nTamBlq := TamSX3("DDV_CODBLQ")[1]
				For nI := 1 To Len(aCods)

					DbSelectArea('DDV')
					DbSetOrder(1)
					If !MsSeek(xFilial('DDV') + PadR(aCods[nI,01],nTamRot) + PadR(aCods[nI,02],nTamBlq) )

						RecLock('DDV',.T.)
						Replace DDV->DDV_FILIAL With xFilial('DDV')
						Replace DDV->DDV_ROTINA With PadR(aCods[nI,01],nTamRot)
						Replace DDV->DDV_CODBLQ With PadR(aCods[nI,02],nTamBlq)
						Replace DDV->DDV_DESCB  With aCods[nI,03]
						Replace DDV->DDV_PROPRI With '1'          //-- Sistema
						
						//-- Utiliza Grid Para Controle De Valores Por Cód. Bloqueio
						Replace DDV->DDV_USEVAL With aCods[nI,04]					
						
						DDV->(MsUnlock())

					EndIf
				Next nI

				/*/
				--------------------------------------------------------------------------------------
				Ativa a Utilização Do Controle De Alçadas Quando Rotinas Nativas Foram Habilitadas
				--------------------------------------------------------------------------------------
				/*/
				
				//-- Controle De Erro Para Tratamento Antigo Do Parâmetro
				If ValType(cParDiv) == "L"
					If cParDiv
						cParDiv := "A" //-- Todos
					Else
						cParDiv := "" //-- Nenhum
					EndIf
				Else
					cParDiv := Upper(Alltrim(cParDiv)) //-- Formata Parametro
				EndIf
				
				For nI := 1 To Len(aRots)
				
					lAtivo := .f.
					
					//-- Diverg Produtos
					Do Case
					Case Alltrim(aRots[nI,01]) == "TMSA200" .And. ('A' $ cParDIV .Or. 'B' $ cParDIV) //-- Calc. Frete
						lAtivo := .t.
					Case Alltrim(aRots[nI,01]) == "TMSA140" .And. ('A' $ cParDIV .Or. 'C' $ cParDIV) //-- Viagem
						lAtivo := .t.
					Case Alltrim(aRots[nI,01]) == "TMSA460" .And. ('A' $ cParDIV .Or. 'D' $ cParDIV) //-- Sol. Coleta
						lAtivo := .t.
					Case Alltrim(aRots[nI,01]) == "TMSA040" .And. ('A' $ cParDIV .Or. 'F' $ cParDIV) //-- Cot. Frete
						lAtivo := .t.
					EndCase
					
					//-- RRE - Regras Restrição Embarque
					Do Case
					Case Alltrim(aRots[nI,01]) == "TMSA200" .And.  '1' $ cParRRE  //-- Calc. Frete
						lAtivo := .t.
					Case Alltrim(aRots[nI,01]) == "TMSA140" .And.  '3' $ cParRRE  //-- Viagem
						lAtivo := .t.
					Case Alltrim(aRots[nI,01]) == "TMSA310" .And.  '3' $ cParRRE  //-- Viagem
						lAtivo := .t.
					Case Alltrim(aRots[nI,01]) == "TMSA460" .And.  '4' $ cParRRE  //-- Sol.Coleta
						lAtivo := .t.
					Case Alltrim(aRots[nI,01]) == "TMSA040" .And.  '2' $ cParRRE  //-- Cot.Frete
						lAtivo := .t.
					EndCase
					
					//-- Altera Status Do Cadastro
					If lAtivo

						DbSelectArea('DDX')
						DbSetOrder(1)
						If MsSeek(xFilial('DDX') + PadR(aRots[nI,01],nTamRot)) .And. Alltrim(DDX->DDX_ATIVO) <> '1'
	
							RecLock('DDX',.F.)
							Replace DDX->DDX_ATIVO  With '1'			//-- Ativo
							DDX->(MsUnlock())
	
						EndIf
					EndIf
				Next nI

			//-- Finaliza Controle Transacional
			End Transaction
		EndIf
	EndIf

	RestArea(aArea)

Return(Nil)
//-------------------------------------------------------------------
/*/{Protheus.doc} TmsVlDDX
Validacoes Da Tabela DDX -> Inclusão Do X3_VALID Ex: Pertence("12") .And. IIF(FindFunction("TmsVlDDX"),TmsVlDDX("DDX_ATIVO","V"),.T.)
@author Eduardo Alberti
@since 19/10/2015
@version P11
/*/
//-------------------------------------------------------------------
Function TmsVlDDX(cCampo,cTipo,cParam)

	Local aArea    		:= GetArea()
	Local xRet     		:= Nil
	Local oModel		:= FWModelActive()
	Local cAtivo   		:= oModel:GetValue( 'TMSA025_CAB', 'DDX_ATIVO' )
	Local cRotina  		:= oModel:GetValue( 'TMSA025_CAB', 'DDX_ROTINA')
	Local nOperation	:= oModel:GetOperation()

	Default cCampo := ""
	Default cTipo  := ""
	Default cParam := ""

	cCampo := Upper(Alltrim(cCampo))
	cTipo  := Upper(Alltrim(cTipo))

	If cCampo == "DDX_ATIVO"

		If cTipo == "V" //-- Validacao

			xRet := .t. //-- Define Retorno Padrão Para Modelo Do Bloco De Execucao

			If cAtivo == '2'
			
				cParDIV := SuperGetMv("MV_TMSINCO",.F.,"" ) //-- A=Todas;B=Calculo Do Frete;C=Viagem;D=Solicitação De Coleta;E=Agendamento;F=Cotação;Em Branco=Nao Controla.
				cParRRE := SuperGetMv("MV_TMSRRE" ,.F.,"") // 1=Calculo Frete, 2=Cotação, 3=Viagem, 4=Sol.Coleta, Em Branco= Nao Utiliza
	
					//-- Controle De Erro Para Tratamento Antigo Do Parâmetro
				If ValType(cParDiv) == "L"
					If cParDiv
						cParDiv := "A" //-- Todos
					Else
						cParDiv := "" //-- Nenhum
					EndIf
				Else
					cParDiv := Upper(Alltrim(cParDiv)) //-- Formata Parametro
				EndIf

				//-- Diverg Produtos
				Do Case
				Case Alltrim(cRotina) == "TMSA200" .And. ('A' $ cParDIV .Or. 'B' $ cParDIV) //-- Calc. Frete
					xRet := .f.
				Case Alltrim(cRotina) == "TMSA140" .And. ('A' $ cParDIV .Or. 'C' $ cParDIV) //-- Viagem
					xRet := .f.
				Case Alltrim(cRotina) == "TMSA460" .And. ('A' $ cParDIV .Or. 'D' $ cParDIV) //-- Sol. Coleta
					xRet := .f.
				Case Alltrim(cRotina) == "TMSA040" .And. ('A' $ cParDIV .Or. 'F' $ cParDIV) //-- Cot. Frete
					xRet := .f.
				EndCase
				
				//-- RRE - Regras Restrição Embarque
				Do Case
				Case Alltrim(cRotina) == "TMSA200" .And.  '1' $ cParRRE //-- Calc. Frete
					xRet := .f.
				Case Alltrim(cRotina) == "TMSA140" .And.  '3' $ cParRRE //-- Viagem
					xRet := .f.
				Case Alltrim(cRotina) == "TMSA310" .And.  '3' $ cParRRE //-- Viagem
					xRet := .f.
				Case Alltrim(cRotina) == "TMSA460" .And.  '4' $ cParRRE //-- Sol.Coleta
					xRet := .f.
				Case Alltrim(cRotina) == "TMSA040" .And.  '2' $ cParRRE //-- Cotacao
					xRet := .f.															
				EndCase

				//-- Mensagem Help
				If !xRet
					Help("",1,"TMSA02501",/*Titulo*/, STR0051 /*Mensagem*/,1,0) //--  "Controle de Restrição De Embarque e/ou Incompatibilidade de Produtos Ativo Para esta Rotina."
				EndIf						

			EndIf
		EndIf
	ElseIf cCampo == "DDX_ROTINA"

		If cTipo == "V" //-- Validacao

			xRet := .t. //-- Define Retorno Padrão Para Modelo Do Bloco De Execucao
			
			If nOperation == MODEL_OPERATION_INSERT
			
				DbSelectArea("DDX")
				DbSetOrder(1)
				If MsSeek(xFilial("DDX") + cRotina ,.F.)
				
					xRet := .f.
					Help("",1,"TMSA02502",/*Titulo*/, STR0052 /*Mensagem*/,1,0) //-- "Já Existe Cadastro Para Esta Rotina!"
					
				EndIf
			EndIf			
		EndIf
	EndIf

	RestArea(aArea)

Return(xRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Tms025Rot
FWMarkBrowse Para Seleção das Rotinas De Bloqueios Constantes Na Tabela DDX
@author Katia
@since 13/05/20
@version P12
/*/
//-------------------------------------------------------------------
Function Tms025Rot()

	Local aArea      := GetArea()
	Local aAlias     := {}
	Local oDlgMrk    := Nil
	Local aColumns   := {}
	Local aRotOld	 := Iif(Type("aRotina") <> "U",aClone(aRotina),{})

	aRotina := MenuDef("M")
	
	//----------------------------------------------------------
	//--Retorna as colunas para o preenchimento da FWMarkBrowse
	//----------------------------------------------------------
	aAlias		:= TmsDDXQry()
	cAliasMrk	:= aAlias[1]
	aColumns 	:= aAlias[2]

	If !Empty (cAliasMrk) 
		If !(cAliasMrk)->(Eof())
			//------------------------------------------
			//--Criação da FWMarkBrowse
			//------------------------------------------
			oMrkBrowse:= FWMarkBrowse():New()
			oMrkBrowse:SetFieldMark("DDX_OK")
			oMrkBrowse:SetOwner(oDlgMrk)
			oMrkBrowse:SetAlias(cAliasMrk)
			oMrkBrowse:SetMenuDef("TMSA025")
			oMrkBrowse:bMark    := {|| TmsDDXMk(cAliasMrk )}
			oMrkBrowse:bAllMark := {|| TmsDDXIn(cAliasMrk) }
			oMrkBrowse:SetDescription( STR0068 ) // "Selecione as Rotinas"
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
	RestArea(aArea)

	If Len(aRotOld) > 0
		aRotina := aClone(aRotOld)
	EndIf

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDXQry
Executa Query Pesquisando Codigos Rotinas Disponíveis
@author Katia
@since 13/05/20
@version P12
/*/
//-------------------------------------------------------------------
Static Function TmsDDXQry()

	Local aArea      := GetArea()
	Local aStru      := {}
	Local aColumns   := {}	
	Local nX         := 0
	Local cArqTrab   := ""
	Local cQuery	 := ""
	Local cRealName	 := ""
	Local lRet		 := .T. 
	Local cCampos    := "DDX_ROTINA|DDV_DESCR|DDX_DESCRS"

	cQuery += " SELECT      '  ' , DDX.DDX_ROTINA, DDX.DDX_DESCR, DDX.DDX_DESCRS  "
	cQuery += " FROM        " +	RetSqlName("DDX") + " DDX "
	cQuery += " WHERE       DDX.DDX_FILIAL =  '" + xFilial("DDX") + "' "
	cQuery += " AND         DDX.D_E_L_E_T_ =  ' ' "
	cQuery += " ORDER BY    DDX_ROTINA "
 	cQuery := ChangeQuery(cQuery)
	 
	cChave		:= "DDX_ROTINA"
	
	Aadd(aStru, {"DDX_OK"     ,"C", 2                       ,0 }) //-- Campo Para Marcação
	Aadd(aStru, {"DDX_ROTINA" ,"C", TamSX3("DDX_ROTINA")[1] ,0 })
	Aadd(aStru, {"DDX_DESCR"  ,"C", TamSX3("DDX_DESCR")[1]  ,0 })
	Aadd(aStru, {"DDX_DESCRS" ,"C", TamSX3("DDX_DESCRS")[1] ,0 })

	cArqTrab	:= GetNextAlias()
	
	oTemp	:= FwTemporaryTable():New(cArqTrab)
	oTemp:SetFields( aStru )
	oTemp:AddIndex("01", {"DDX_ROTINA"} )
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
			EndIf
		Next nX
	EndIf
	RestArea(aArea)

Return({cArqTrab,aColumns})

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDXMk
Marcacao de um registro
@author Katia
@since 13/05/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDDXMk(cAliasTRB)

	Local lRet		:= .T.
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDXIn
Marcacao de vários registros
@author Katia
@since 13/05/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDDXIn(cAliasTRB)

	Local nReg		:= (cAliasTRB)->(Recno())
	Local cMarca	:= oMrkBrowse:cMark

	DbSelectArea(cAliasTRB)
	DbGoTop()

	While !(cAliasTRB)->(Eof())
		If (cAliasTRB)->(MsRLock())
			If	(cAliasTRB)->DDX_OK == cMarca
				(cAliasTRB)->DDX_OK := "  "
				(cAliasTRB)->(MsUnlock())
			Else
				(cAliasTRB)->DDX_OK := cMarca
			Endif
		Endif
		(cAliasTRB)->(dbSkip())
	Enddo

	(cAliasTRB)->(dbGoto(nReg))

	oMrkBrowse:oBrowse:Refresh(.t.)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} TmsDDXGrv
Rotina Acionada Pelo Botao "Confirmar" Do FWMarkBrowse
@author Katia
@since 13/05/20
@version 1.0
/*/
//-------------------------------------------------------------------
Function TmsDDXGrv()
	Local aArea       := GetArea()
	Local cValor      := ""

	DbSelectArea(cAliasMrk)
	(cAliasMrk)->(DbGoTop())

	While !(cAliasMrk)->(Eof())

		If !Empty((cAliasMrk)->DDX_OK)
			cValor += Iif(Empty(cValor),"",",") + AllTrim((cAliasMrk)->DDX_ROTINA)
		EndIf

		DbSelectArea(cAliasMrk)
		(cAliasMrk)->(DbSkip())
	EndDo

	oMrkBrowse:GetOwner():End()

	VAR_IXB:= PadR(cValor,99)  //Retorno para a Consulta DDV1

	RestArea(aArea)

Return()
