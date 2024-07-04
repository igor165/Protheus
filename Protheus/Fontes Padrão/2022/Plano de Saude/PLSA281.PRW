#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'

static oCmpExBZ8 := NIL
//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSA281
Tela Ficha de Matrícula
@since 02/2020
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSA281(lAutoma)
local cFiltro   := "@(BAU_FILIAL = '" + xFilial("BAU") + "') "
local oBrowse	:= nil
default lAutoma := iif( valtype(lAutoma) <> "L", .f., lAutoma )	 

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('BAU')
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetOnlyFields( { 'BAU_FILIAL', 'BAU_CODIGO', 'BAU_NOME', 'BAU_NREDUZ', 'BAU_CPFCGC', 'BAU_NFANTA'} )
oBrowse:AddLegend("BAU->BAU_CODBLO==Space(03) .Or. BAU->BAU_DATBLO > DDATABASE", "GREEN", "Autorizado" ) //Autorizado
oBrowse:AddLegend("BAU->BAU_CODBLO<>Space(03) .AND. BAU->BAU_DATBLO <= DDATABASE", "RED", "Negado" ) //Negado
oBrowse:SetDescription("Lançamento Movimento")
iif(!lAutoma, oBrowse:Activate(), '')

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menus
@since 09/2019
@version P12 
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina 	:= {}

Add Option aRotina Title "Lançamento de Movimentação"	Action "STATICCALL(PLSA281,PlsMid)" 	Operation 9 Access 0 

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definição do modelo de Dados.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oModel 
Local oStrBZ4	:= FWFormStruct(1,'BZ4')
Local oStrBZ5	:= FWFormStruct(1,'BZ5')
Local oStrBZ8	:= FWFormStruct(1,'BZ8')
Local oStrVal	:= FWFORMMODELSTRUCT():New()
Local oStrVal2	:= FWFORMMODELSTRUCT():New()
Local oStrVal3	:= FWFORMMODELSTRUCT():New()

oModel := MPFormModel():New( 'PLSA281' , , { |oModel| PlFimConf(oModel) } , {|oModel|FWFORMCOMMIT(oModel, , { || PlComBz4(oModel) }  )} ) 
//     := MPFormModel():New( 'PLSA281' , , 			Pós Validação		  , {|Bloco de comite    (oModel, , { Pós Comit				  } ) 

//Campos de saldo
oStrVal:AddField('Valor_Crédito', 'Valor Total de Crédito'	, 'VLRCRED' , 'N', 16,2, , , {}, .F.,{||CarregaSaldo(oModel,"cre") } , .F., .F., .T., , )
oStrVal2:AddField('Valor_Débito', 'Valor Total de Débito'	, 'VLRDEBI'	, 'N', 16,2, , , {}, .F.,{||CarregaSaldo(oModel,"deb") } , .F., .F., .T., , )
oStrVal3:AddField('Valor_Saldo'	, 'Valor Saldo Final'		, 'VLRSLD'	, 'N', 16,2, , , {}, .F.,{||CarregaSaldo(oModel,"sal") } , .F., .F., .T., , )

//Campos para modo de exclusão
oStrBZ5:AddField('Observação_Exclusão'	, 'Observação de exclusão'	, 'OBSEXC'				, 'C', 80	,, ,{||PlHabEdit(oModel) }, {}, .F.,, .F., .F., .T., , )
oStrBZ5:AddField('Check_Exclusão'		, 'Check para Exclusão'		, 'CHKEXC'				, 'L', 1	,, ,, {}, .F.,{||.F.}, .F., .F., .T., , )

//Adição dos campos e Grids
oModel:AddFields( 'BZ4MASTER' , /*cOwner*/  , oStrBZ4 )
oModel:AddFields( 'ValDetail' , 'BZ4MASTER' , oStrVal  ,,,{|| Load() })
oModel:AddFields( 'ValDetail2', 'BZ4MASTER' , oStrVal2 ,,,{|| Load() })
oModel:AddFields( 'ValDetail3', 'BZ4MASTER' , oStrVal3 ,,,{|| Load() })
oModel:AddGrid( 'BZ5Detail'   , 'BZ4MASTER' , oStrBZ5  ,,{||PlValBZ5(oModel)})
oModel:AddGrid( 'BZ8Detail'   , 'BZ4MASTER' , oStrBZ8  ,, ) 

//Relacionamentos
oModel:SetRelation( 'BZ5Detail', { ;
	{ 'BZ5_FILIAL'	, 'xFilial( "BZ5" )' },;
	{ 'BZ5_CODIGO'	, 'BZ4_CODIGO'		 },;
	{ 'BZ5_FICMAT'	, 'BZ4_FICMAT'		 }},;
	BZ5->( IndexKey(2) ) )
oModel:SetRelation( 'BZ8Detail', { ;
	{ 'BZ8_FILIAL'	, 'xFilial( "BZ8" )' },;
	{ 'BZ8_CODIGO'	, 'BZ4_CODIGO'		 }})

//Propriedades especificas de campo
oStrBZ5:setProperty( "BZ5_CODIGO" , MODEL_FIELD_INIT, { || BAU->BAU_CODIGO} )
oStrBZ5:setProperty( "BZ5_FICMAT" , MODEL_FIELD_INIT, { || oModel:getModel("BZ4MASTER"):getValue("BZ4_FICMAT")} )
oStrBZ5:SetProperty( 'BZ5_VLRLCT' , MODEL_FIELD_VALID, { || ValidaVlrlct (oModel) } )
oStrBZ5:setProperty( "BZ5_CODLCT" , MODEL_FIELD_OBRIGAT, .F. )

//Restrições de CRUD
oModel:GetModel( 'BZ5Detail' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'BZ8Detail' ):SetNoDeleteLine( .T. )
oModel:GetModel( 'BZ8Detail' ):SetNoInsertLine( .T. )
oModel:GetModel( 'BZ8Detail' ):SetNoUpdateLine( .T. )

//Apenas BZ4 é obrigatório
oModel:GetModel( 'BZ5Detail' ):setOptional(.T.)
oModel:GetModel( 'BZ8Detail' ):setOptional(.T.)
oModel:GetModel( 'ValDetail' ):setOptional(.T.)
oModel:GetModel( 'ValDetail2'):setOptional(.T.)
oModel:GetModel( 'ValDetail3'):setOptional(.T.)

//Descrição
oModel:GetModel( 'BZ4MASTER' ):SetDescription( "Ficha de Matrícula"	 	)
oModel:GetModel( 'BZ5Detail' ):SetDescription( "Lançamentos"			)
oModel:GetModel( 'BZ8Detail' ):SetDescription( "Histórico de Exclusão"	)
oModel:GetModel( 'ValDetail' ):SetDescription( "Resumo de Totais" 		)
oModel:GetModel( 'ValDetail2'):SetDescription( "Resumo de Totais"		)
oModel:GetModel( 'ValDetail3'):SetDescription( "Resumo de Totais"		)

//alimentar a variável estática oCmpExBZ8, para não chamar FieldPos várias vezes
PlExsBZ8()
	
Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição da interface.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView 
Local oModel	:= FWLoadModel( 'PLSA281' )
Local oStrBZ4	:= FWFormStruct(2,'BZ4',{ |cCampo| FilExibe(cCampo) })
Local oStrBZ5	:= FWFormStruct(2,'BZ5')
Local oStrBZ8	:= FWFormStruct(2,'BZ8')
Local oStrVal	:= FWFORMVIEWSTRUCT():New()
Local oStrVal2	:= FWFORMVIEWSTRUCT():New()
Local oStrVal3	:= FWFORMVIEWSTRUCT():New()

oView := FWFormView():New()
oView:SetModel( oModel )

//Vistas Principais
oView:AddField( 'VIEW_BZ4', oStrBZ4, 'BZ4MASTER')
oView:AddGrid( 'VIEW_BZ5', oStrBZ5, 'BZ5Detail' )
oView:AddGrid( 'VIEW_BZ8', oStrBZ8, 'BZ8Detail' )
oView:AddField( 'VIEW_VAL', oStrVal, 'ValDetail')
oView:AddField( 'VIEW_VAL2', oStrVal2, 'ValDetail2')
oView:AddField( 'VIEW_VAL3', oStrVal3, 'ValDetail3')

//Campos criados
oStrVal:AddField( 'VLRCRED'	, '97' , ''	, 'Valor Total de Crédito'	,, 'N' ,'@E 999,999,999,999.99',,,.F.,,,,,,.T.,,, )
oStrVal2:AddField( 'VLRDEBI', '98' , ''	, 'Valor Total de Débito'	,, 'N' ,'@E 999,999,999,999.99',,,.F.,,,,,,.T.,,, )
oStrVal3:AddField( 'VLRSLD', '99' , ''	, 'Valor Saldo Final'		,, 'N' ,'@E 999,999,999,999.99',,,.F.,,,,,,.T.,,, )
oStrBZ5:AddField( 'OBSEXC'	, '96' , 'Observação de Exclusão'	, 'Observação de Exclusão'	,, 'C' ,,,,,,,,,,.T.,, 	 )
oStrBZ5:AddField( 'CHKEXC'	, '95' , 'Exclusão'					, 'Exclusão'				,, 'L' ,,,,.T.,,,,,,.T.,,)

//Divisão das Vistas
oView:CreateHorizontalBox( 'SUPERIOR' , 40 )
oView:CreateHorizontalBox( 'BAIXO'	  , 60 )
oView:CreateVerticalBox( 'BAIXOESQ'	, 60 , 'BAIXO' )
oView:CreateVerticalBox( 'BAIXODIR' , 40 , 'BAIXO' )
oView:CreateHorizontalBox( 'RESSUPERIOR' , 30 ,'BAIXODIR' )
oView:CreateHorizontalBox( 'RESCENTRAL'  , 30 ,'BAIXODIR' )
oView:CreateHorizontalBox( 'RESBAIXO'    , 40 ,'BAIXODIR' )

//Folders
oView:CreateFolder( 'ABA', 'BAIXOESQ' )
oView:CreateHorizontalBox( 'A1' , 100 ,,, 'ABA' , 'V1' )
oView:CreateHorizontalBox( 'A2' , 100 ,,, 'ABA' , 'V2' )
oView:AddSheet( 'ABA', 'V1' ,"Lançamento de Movimentos") 
oView:AddSheet( 'ABA', 'V2', "Histórico de Exclusão" ) 

//Vistas
oView:SetOwnerView('VIEW_BZ5' , 'A1'		 )
oView:SetOwnerView('VIEW_BZ8' , 'A2' 		 )	
oView:SetOwnerView('VIEW_BZ4' , 'SUPERIOR'	 )
oView:SetOwnerView('VIEW_VAL' , 'RESSUPERIOR')
oView:SetOwnerView('VIEW_VAL2', 'RESCENTRAL' )
oView:SetOwnerView('VIEW_VAL3', 'RESBAIXO' 	 )

//Desabilita para edição o campo Ficha de Matricula (possui inicializador no SX3)
oStrBZ4:setProperty( "BZ4_FICMAT" , MVC_VIEW_CANCHANGE, .F. )

//Títulos
oView:EnableTitleView('VIEW_BZ4' , "Ficha de Matrícula"	     ) 
oView:EnableTitleView('VIEW_BZ5' , "Lançamento de Movimentos") 
oView:EnableTitleView('VIEW_BZ8' , "Histórico de Exclusão" 	 )
oView:EnableTitleView('VIEW_VAL' , "Valor Total de Crédito"	 ) 
oView:EnableTitleView('VIEW_VAL2', "Valor Total de Débito"	 ) 
oView:EnableTitleView('VIEW_VAL3', "Valor Saldo Final"	 	 ) 

//Atualiza Saldo no grid
oView:SetFieldAction('BZ5_VLRLCT', { |oView| CarregaSaldo(oModel) } ) 

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} PlsMid
Carrega tela de Inclusão ou Alteração
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlsMid()
local aButtons 	:= {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}	
BZ4->(dbsetorder(1))
If ( BZ4->(dbSeek(xFilial("BZ4") + BAU->BAU_CODIGO)) )
	FWExecView('Lançamento de Movimentos','PLSA281', 4,,,,,aButtons ) 
Else
	FWExecView('Lançamento de Movimentos','PLSA281', 3,,,,,aButtons ) 
Endif 	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FilExibe
Function para ocultar os campos que não podem ser exibidos em tela
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function FilExibe(cCampo)
Local lRet := .T.

if alltrim(cCampo) $ "BZ4_CDMEM1,BZ4_CDMEM2"
	lRet := .F.
endif

return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlValBZ5
Valida se todos os campos obrigatórios estão preenchidos
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlValBZ5(oModel)

local nFor 		:= 0
local aCmpVld	:= {"BZ5_DATLCT","BZ5_CODLCT","BZ5_DESLCT","BZ5_VLRLCT","BZ5_TIPLCT","BZ5_TIPCLA"}
local lRet		:= .T.
Local oBZ5		:= oModel:getmodel("BZ5Detail")

//Verifica se campos estão preenchidos
For nFor := 1 to Len(aCmpVld)
	If empty (oBZ5:getValue(aCmpVld[nFor]))
		lRet := .F.
		Help(nil, nil , "Aviso" , nil, "O campo " + aCmpVld[nFor] + " é obrigatório.", 1, 0, NIL, NIL, NIL, NIL, NIL, )
		Exit
	Endif
Next

//Atualiza saldos
If lRet
	PlHabEdit(oModel) //Apaga campo observação de exclusão caso o item não esteja marcado como 'excluir'
	PlSaldoGr(oModel)
Endif

Iif(lRet,CriaNumLct(oBZ5),) //Insere campo NumLct em uma linha validada

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlSaldoBZ5
Atualiza saldo dos lançamentos de movimento ao carregar o grid
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PlSaldoBZ5(oModel)

Local aSaldo 	:= {0, 0}
Local nSaldo 	:= 0 
Local nReg 		:= BZ5->(Recno())

BZ5->(dbSetOrder(1))

If !Empty(BZ4->BZ4_CODIGO+BZ4->BZ4_FICMAT)
	If BZ5->(dbSeek(xFilial("BZ4")+BZ4->BZ4_CODIGO+BZ4->BZ4_FICMAT))
		While BZ5->(!Eof() .And. BZ5_FILIAL+BZ5->BZ5_CODIGO+BZ5->BZ5_FICMAT == xFilial("BZ4")+BZ4->BZ4_CODIGO+BZ4->BZ4_FICMAT)
																		
			nSaldo += ( BZ5->BZ5_VLRLCT * IIF(BZ5->BZ5_TIPLCT == "1", 1, -1))
			If BZ5->BZ5_TIPLCT=="1"
				aSaldo[1] += BZ5->BZ5_VLRLCT
			Else
				aSaldo[2] += BZ5->BZ5_VLRLCT
			EndIf

			BZ5->(dbSkip())
		End
	Endif
Endif
BZ5->(dbGoto(nReg)) //Reposiciona na BZ5

Return aSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} PlSaldoGr
Atualiza saldo dos lançamentos de movimento dinamicamente (aciona ao mudar de linha)
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PlSaldoGr(oModel)

Local oBZ5		:= oModel:getmodel("BZ5Detail")
Local aSaldo	:= {0,0}
Local nSaldo	:= 0
Local nI		:= 0
Local nValorCota:= 0
Local nLnAtual	:= 0
Local cTipclt	:= ""

nLnAtual := oBZ5:GetLine()

For nI := 1 to oBZ5:Length()
	oBZ5:GoLine(nI)
	nValorCota := oBZ5:getValue("BZ5_VLRLCT")
	cTipclt	:= oBZ5:getValue("BZ5_TIPLCT")
	If !(Empty(nValorCota) .And. !(Empty(cTipclt))) //Se não houver valores a serem somados ou a direção, não é somado o saldo. 
		nSaldo += ( nValorCota * IIF(cTipclt == "1", 1, -1))
		If cTipclt == "1"
			aSaldo[1] += nValorCota
		Else
			aSaldo[2] += nValorCota
		Endif
		oModel:getModel("BZ5Detail"):loadvalue("BZ5_SALDO",nSaldo)
	Endif
Next

oBZ5:GoLine(nLnAtual) //Restaura posição no grid

Return aSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} CarregaSaldo
Carrega o saldo dos valores em cota
Obs: Deve ser usado o parametro 'cTipo' para realizar o primeiro carregamento da tela. Os métodos MVC não funcionam neste ponto.
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function CarregaSaldo(oModel,cTipo)

Local aSaldo	:= {}
Local nSaldo 	:= 0
Local oViewAtiva:= Nil

//Altera saldo no carregamento da tela
If !Empty(cTipo)
	aSaldo := PlSaldoBZ5(oModel)
	If cTipo == "cre"
		nSaldo := aSaldo[1]
	ElseIf cTipo == "deb"
		nSaldo := aSaldo[2]
	ElseIf cTipo == "sal"
		nSaldo := aSaldo[1]-aSaldo[2]
	Endif

//Altera saldo dinamicamente
Else
	oViewAtiva:= FWViewActive()
	aSaldo := PlSaldoGr(oModel)

	oModel:getModel("ValDetail" ):loadvalue("VLRCRED",aSaldo[1]				)
	oModel:getModel("ValDetail2"):loadvalue("VLRDEBI",aSaldo[2]				)
	oModel:getModel("ValDetail3"):loadvalue("VLRSLD" ,aSaldo[1]-aSaldo[2]	)
	oViewAtiva:Refresh()
	Return
Endif

Return nSaldo

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidaVlrlct
Valida se o campo Código de Lançamento já foi preenchido para que possa inserir um valor em cotas
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Function ValidaVlrlct (oModel)

Local lRet := .T.
Local cTipclt	:= oModel:getmodel("BZ5Detail"):getValue("BZ5_TIPLCT")

If Empty(cTipclt)
	Help(nil, nil , 'Atenção' , nil, 'Insira um código de lançamento antes de inserir um valor', 1, 0, nil, nil, nil, nil, nil, {""} )
	lRet := .F.
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Load
Carrega os campos sem estruturas
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Load()
Local aLoad := {}
   aAdd(aLoad, {""}) //dados
   aAdd(aLoad, 0) //recno  
Return aLoad

//-------------------------------------------------------------------
/*/{Protheus.doc} SlvObsBZ4
Salva nas tabelas os campos de observação da BZ4 (Modelo antigo de salvamento)
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function SlvObsBZ4(oBZ4)

If !Empty(oBZ4:getValue("BZ4_OBSADM"))
	MSMM(,TamSx3("BZ4_OBSADM")[1],,oBZ4:getValue("BZ4_OBSADM"),1,,,"BZ4","BZ4_CDMEM1")	
Endif

If !Empty(oBZ4:getValue("BZ4_OBSDEM"))
	MSMM(,TamSx3("BZ4_OBSDEM")[1],,oBZ4:getValue("BZ4_OBSDEM"),1,,,"BZ4","BZ4_CDMEM2")	
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CriaNumLct
Insere o registro de número de lançamento em linhas criadas
@since 02/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function CriaNumLct(oBZ5)

If Empty(oBZ5:getValue("BZ5_NUMLCT"))
	oBZ5:loadvalue("BZ5_NUMLCT",GETSX8Num("BZ5","BZ5_NUMLCT",,2))
	BZ5->(ConfirmSX8())
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PlFimConf
Função que realizaos processos de validações e procedimentos finais da tela 
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlFimConf(oModel)

Local oBZ5		:= oModel:getmodel("BZ5Detail")
Local aValidBZ8	:= {}
Local nLnAtual	:= 0
Local nI		:= 0
Local lBZ8ok	:= .T. //Permite excluir os itens da BZ5 e incluir na BZ8
Local lHaExc	:= .F. //Flag que avisa se haverá exclusão
Local lRet		:= .T.

nLnAtual := oBZ5:GetLine()

For nI := 1 To oBZ5:Length()
	oBZ5:GoLine(nI)
	CriaNumLct(oBZ5) //Cria um número de lançamento caso ainda não tenha
	aadd(aValidBZ8,VldBZ5BZ8(oBZ5,@lBZ8ok,@lHaExc)) //Verifica e valida linhas para excluir - {{nLinha,lMarcadoExcluit,lCampoObservação}}
Next

//Exclui linhas da BZ5 e grava na BZ8
If lHaExc
	If lBZ8ok
		PlExcLanc(oBZ5,aValidBZ8) //Exclui da BZ5 e inclui na BZ8
	Else
		Help(nil, nil , "Aviso" , nil, 'Para excluir um lançamento é obrigatório preencher o campo "Observação de Exclusão"', 1, 0, NIL, NIL, NIL, NIL, NIL,{'Insira uma "Observação de Exclusão" ou desmarque a opção de "Excluir"'} )
		lRet := PlListErro(aValidBZ8) //Exibe campos com erros
	Endif
Endif

//Retorna para linha que estava
oBZ5:GoLine(nLnAtual)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PlExcLanc
Exclui lançamentos da BZ5, Inclui em registros excluídos na BZ8 e SYP
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlExcLanc(oBZ5,aValidBZ8)

Local nI	:= 0
//Verifico se o objeto oCmpExBZ8 está preenchido, se não, carrego
PlExsBZ8()

For nI := 1 To len(aValidBZ8)

	oBZ5:GoLine(aValidBZ8[nI][1])
	If aValidBZ8[nI][2]

		//Grava dados na BZ8
		dbSelectArea("BZ8")
   		BZ8->(RecLock("BZ8",.T.)) 
			BZ8->BZ8_FILIAL := xFilial("BZ5")
			BZ8->BZ8_CODIGO := oBZ5:getValue("BZ5_CODIGO")
			BZ8->BZ8_NUMLCT := oBZ5:getValue("BZ5_NUMLCT")
			BZ8->BZ8_CODLCT := oBZ5:getValue("BZ5_CODLCT")
			
			//Campos existem no cliente, mas não no ATUSX ou compatibilizador......
			iif(oCmpExBZ8["FICMAT"], BZ8->BZ8_FICMAT := oBZ5:getValue("BZ5_FICMAT"), "")
			iif(oCmpExBZ8["DATLCT"], BZ8->BZ8_DATLCT := oBZ5:getValue("BZ5_DATLCT"), "")
			iif(oCmpExBZ8["VLRLCT"], BZ8->BZ8_VLRLCT := oBZ5:getValue("BZ5_VLRLCT"), "")
			iif(oCmpExBZ8["TIPLCT"], BZ8->BZ8_TIPLCT := oBZ5:getValue("BZ5_TIPLCT"), "")
			iif(oCmpExBZ8["SALDO" ], BZ8->BZ8_SALDO  := oBZ5:getValue("BZ5_SALDO") , "")
			iif(oCmpExBZ8["TIPCLA"], BZ8->BZ8_TIPCLA := oBZ5:getValue("BZ5_TIPCLA"), "")
		BZ8->(MsUnLock())
		//Registra campo na SYP
		MSMM(,TamSx3("BZ8_OBSEXC")[1],,oBZ5:getValue("OBSEXC")  ,1,,,"BZ8","BZ8_CODMEM")

		//Deleta registro no grid da BZ5
		oBZ5:SetNoDeleteLine( .F. )
		oBZ5:DeleteLine()
		oBZ5:SetNoDeleteLine( .T. )

	Endif
Next

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldBZ5BZ8
Valida se o campo observação de exclusão foi preenchido e armazena 
linhas que deverão ser deletadas. Caso haja erros, devolverá uma 
lista com os itens críticados 
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function VldBZ5BZ8(oBZ5,lBZ8ok,lHaExc)

Local aRetorno 	:= {,,,}	//Estrutura de retorno {nLinha,lMarcadoExcluit,lCampoObservação}
Local nLinhaExe	:= 0 	//Linha que está sendo tratada
Local cObserExcl:= ""	//Campo observação de exclusão
Local lExcluir	:= .F.	//CheckBox de Excluir
Local lValidOk	:= .F. 	//Campo de observação preenchido corretamente
Local cNumLct	:= ""

nLinhaExe	:= oBZ5:GetLine()
cObserExcl	:= oBZ5:getValue("OBSEXC")
lExcluir	:= oBZ5:getValue("CHKEXC")
cNumLct		:= oBZ5:getValue("BZ5_NUMLCT")

//Verifica se o campo de observação foi preenchido
If lExcluir
	lHaExc := .T.
	If !Empty(cObserExcl)
		lValidOk := .T.
	Else
		lBZ8ok := .F. //Se há pelo menos um item errado, não chamará a função que exclui lançamentos
	Endif
Endif

aRetorno := {nLinhaExe,lExcluir,lValidOk,cNumLct}

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} PlListErro
Lista linhas com problemas
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlListErro(aValidBZ8)

Local aErros	:= {}
Local nI 		:= 0

For nI := 1 To len(aValidBZ8)
	
	If !aValidBZ8[nI][3] .And. aValidBZ8[nI][2]
		aadd(aErros,{aValidBZ8[nI][1],aValidBZ8[nI][4],"Campo 'Observação de Exclusão' obrigatório para excluir."})
	Endif
Next

PLSCRIGEN(aErros,{ {"Linha","@N",3},{"Num. Lançamento","@C",10},{"Descrição","@C",60} },"Não foi possível excluir os itens selecionados devido aos seguintes erros")

Return .F.

//-------------------------------------------------------------------
/*/{Protheus.doc} PlHabEdit
Habilita para edição o campo de observação de exlusão
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function PlHabEdit(oModel)

Local oBZ5		:= oModel:getmodel("BZ5Detail")
Local lChkExc	:= oBZ5:getValue("CHKEXC")

If lChkExc == .T.
	Return .T.
Else
	oBZ5:loadvalue("OBSEXC","")
	Return .F.
Endif

//-------------------------------------------------------------------
/*/{Protheus.doc} PlComBz4
Commita o modelo e invoca as funções que dependem de um commit antes.
@since 03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlComBz4(oModel)

Local oBZ4 := oModel:getmodel("BZ4MASTER")

SlvObsBZ4(oBZ4)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlExsBZ8
Verifica se existe os campos abaixo na BZ8, pois os campos existem na base do cliente, mas no ATUSX e compatibilizadores não, 
mas em histórico de fontes, encontramos menção....
Então, fazemos fieldpos, se existir, vai gravar.....
@since 07/2022
@version P12
/*/
//-------------------------------------------------------------------
Static Function PlExsBZ8()
local oDados := JsonObject():New()

if (oCmpExBZ8 == NIL )	
	oDados["FICMAT"] := BZ8->(FieldPos('BZ8_FICMAT')) > 0
	oDados["DATLCT"] := BZ8->(FieldPos('BZ8_DATLCT')) > 0
	oDados["VLRLCT"] := BZ8->(FieldPos('BZ8_VLRLCT')) > 0
	oDados["TIPLCT"] := BZ8->(FieldPos('BZ8_TIPLCT')) > 0
	oDados["SALDO"]  := BZ8->(FieldPos('BZ8_SALDO'))  > 0
	oDados["TIPCLA"] := BZ8->(FieldPos('BZ8_TIPCLA')) > 0
	oCmpExBZ8 := oDados
endif	
Return 
