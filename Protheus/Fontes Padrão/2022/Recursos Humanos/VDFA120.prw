#include "VDFA120.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH' 

/*/{Protheus.doc} VDFA120  
	Cadastro de Lançamentos Automaticos
	@owner Fabricio Amaro
	@author Fabricio Amaro
	@since 24/10/2013
	@version P11 Release 8
/*/
//	project GESTÃO DE PESSOAS E VIDA FUNCIONAL MP-MT (M12RHMP)

Function VDFA120()
	Local oBrowse
	Private cTab := chr(9)
	Private cEnt := chr(13)+chr(10)

	Private cCpoRet := ""	//ESSA VARIAVEL SERA UTILIZADA NA MONTAGEM DA CONSULTA PADRÃO FOPCSX2() 
							//XB_TIPO 	= 5
							//XB_CONTEM	= &cCpoRet
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('RIK')
	oBrowse:SetDescription(STR0001)//'Lançamentos Automáticos'
	oBrowse:DisableDetails()
	oBrowse:Activate()
	
Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0002	ACTION 'VIEWDEF.VDFA120' OPERATION 2 ACCESS 0//'Visualizar'
	ADD OPTION aRotina TITLE STR0003	ACTION 'VIEWDEF.VDFA120' OPERATION 3 ACCESS 0//'Incluir'
	ADD OPTION aRotina TITLE STR0004	ACTION 'VIEWDEF.VDFA120' OPERATION 4 ACCESS 0//'Alterar'
	ADD OPTION aRotina TITLE STR0005	ACTION 'VIEWDEF.VDFA120' OPERATION 5 ACCESS 0//'Excluir'
	ADD OPTION aRotina TITLE STR0006	ACTION 'VIEWDEF.VDFA120' OPERATION 8 ACCESS 0//'Imprimir'
	ADD OPTION aRotina TITLE STR0007	ACTION 'VIEWDEF.VDFA120' OPERATION 9 ACCESS 0//'Copiar'

Return aRotina

//-------------------------------------------------------------------
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruRIK := FWFormStruct( 1, 'RIK', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('VDFA120',/*bPreValidacao*/,{|oModel|VDFA120POS(oModel)},/*{|oModel|VDFA120GRV(oModel)}*/,/*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'RIKMASTER', /*cOwner*/, oStruRIK, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( STR0008 )//'Manutenção de Lançamentos Automáticos'
	
	oModel:SetPrimaryKey( { "RIK_FILIAL", "RIK_COD" } )
	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'RIKMASTER' ):SetDescription( STR0009 )//'Dados do Lançamento Automático/'
	
	// Liga a validação da ativacao do Modelo de Dados
	//oModel:SetVldActivate( { |oModel| xValid(oModel) } )
	
Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( 'VDFA120' )
	// Cria a estrutura a ser usada na View
	Local oStruRIK := FWFormStruct( 2, 'RIK' )
	//Local oStruRIK := FWFormStruct( 2, 'RIK', { |cCampo| VDFA120STRU(cCampo) } )
	Local oView  
	//Local cCampos := {}

	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( 'VIEW_RIK', oStruRIK, 'RIKMASTER' )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( 'VIEW_RIK', 'TELA' )
	
	//oView:SetViewAction( 'BUTTONOK'    , { |o| Help(,,'HELP',,'Ação de Confirmar ' + o:ClassName(),1,0) } )
	//oView:SetViewAction( 'BUTTONCANCEL', { |o| Help(,,'HELP',,'Ação de Cancelar '  + o:ClassName(),1,0) } )
Return oView

//FUNÇÃO DE VERIFICAÇÃO NA CONFIRMAÇÃO DA ROTINA
Static Function VDFA120POS(oModel)
	Local lRet 		:= .T.
	Local cMsg		:= ""
	Local nOperation := oModel:GetOperation()

	Local RIKCateg	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_CATEG'))
	Local RIKRegime	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_REGIME'))
	Local RIKFuncC	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_FUNCC'))
	Local RIKDeptoc	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_DEPTOC'))
	Local RIKComarc	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_COMARC'))
	Local RIKPercen	:= (oModel:GetValue('RIKMASTER','RIK_PERCEN'))
	Local RIKBaseca	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_BASECA'))
	Local RIKVerbas	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_VERBAS'))
	Local RIKTabela	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_TABELA'))
	Local RIKTabNiv	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_TABNIV'))
	Local RIKTabFai	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_TABFAI'))
	Local RIKValFix	:= (oModel:GetValue('RIKMASTER','RIK_VALFIX'))
	Local RIKAfasta	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_AFASTA'))
	Local RIKGerafa	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_GERAFA'))
	Local RIKFaltas	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_FALTAS'))
	Local RIKDFalta	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_DFALTA'))
	Local RIKMeses	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_MESES'))
	Local RIKObrAdm	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_OBRADM'))
	Local RIKAdmiss	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_ADMISS'))
	Local RIKDemiss	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_DEMISS'))
	Local RIKProcat	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_PROCAT'))
	Local RIKRoteir	:= Alltrim(oModel:GetValue('RIKMASTER','RIK_ROTEIR'))
	
	If nOperation == 3 .OR. nOperation == 4 //INCLUIR OU ALTERAR
		If Empty(RIKProcat)
			cMsg :=  STR0011 //'Por favor, informe o campo Proporcionaliza Categoria!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKDemiss)
			cMsg := STR0012 //'Por favor, informe o campo Na Rescisão!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKAdmiss)
			cMsg := STR0013 //'Por favor, informe o campo Na Admissão!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKObrAdm)
			cMsg := STR0014 //'Por favor, informe o campo Obrigatório na Admissão!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKFaltas)
			cMsg := STR0015 //'Por favor, informe o campo Abater Faltas!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKDFalta)
			cMsg := STR0016 //'Por favor, informe o campo Devolver Faltas!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKGerafa)
			cMsg := STR0017 //'Por favor, informe o campo Gerar para Dias Afastados'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If RIKPercen > 0  .AND. Empty(RIKBaseCa)
			cMsg := STR0018 //'Por favor, informe a Base de Cálculo, pois o campo % Calculo está preenchido!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If RIKPercen > 0
			If RIKBaseCa == "3" .AND. Empty(RIKVerbas)
				cMsg := STR0019 //'Por favor, informe as Verbas para a Base de Cálculo quando a opção for 3=Verbas Informadas!'
				Help(,,STR0010,,cMsg,1,0)//"Erro"
				Return .F. 
			EndIf
			If RIKBaseCa == "4" .AND. Empty(RIKTabela)
				cMsg := STR0020 //'Por favor, informe a Tabela Salarial para a Base de Cálculo quando a opção for 4=Tabela Salarial!'
				Help(,,STR0010,,cMsg,1,0)//"Erro"
				Return .F. 
			EndIf
			If RIKBaseCa == "4" .AND. !Empty(RIKTabela) .AND. ( Empty(RIKTabNiv) .OR. Empty(RIKTabFai)) 
				cMsg := STR0021 //'Por favor, informe o Nivel e Faixa da Tabela Salarial. Utilize a Consulta Padrão (F3) do campo Tabela Salarial!'
				Help(,,STR0010,,cMsg,1,0)//"Erro"
				Return .F. 
			EndIf
		EndIf
		If RIKPercen == 0 .AND. RIKValFix == 0
			cMsg := STR0022 //'Por favor, informe o % Calculo ou o Valor Fixo para a regra de cálculo!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If RIKPercen > 0 .AND. RIKValFix > 0
			cMsg := STR0023 //'Por favor, informe apenas o % Calculo ou o Valor Fixo!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKRegime)
			cMsg := STR0024 //'Por favor, informe o campo Regime ou selecione 3=Ambos!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf

		If Empty(RIKAfasta)
			cMsg := STR0025 //'Por favor, informe os Tipos de Afastamentos a Considerar. Para considerar todos, informe "*" !'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKComarC)
			cMsg := STR0026 //'Por favor, informe as Comarcas a Considerar. Para considerar todas, informe "*" !'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKDeptoC)
			cMsg := STR0027 //'Por favor, informe os Departamentos a Considerar. Para considerar todos, informe "*" !'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKFuncC)
			cMsg := STR0028 //'Por favor, informe as Funções a Considerar. Para considerar todas, informe "*" !'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKCateg)
			cMsg := STR0029 //'Por favor, informe as Categorias! Caso a regra seja para todas, na consulta padrão (F3) clique em Marca Todos <F4>!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKMeses)
			cMsg := STR0030 //'Por favor, informe os Meses de Lançamentos! Caso a regra seja para todos, na consulta padrão (F3) clique em Marca Todos <F4>!'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
		If Empty(RIKRoteir)
			cMsg := STR0031 //'Por favor, informe os Roteiros a Considerar. Para considerar todos, informe "*" !'
			Help(,,STR0010,,cMsg,1,0)//"Erro"
			Return .F. 
		EndIf
	EndIf
Return lRet


//------------------------------------------------------------------------------
/* {Protheus.doc} VerRIKFunc()
FUNÇÃO QUE RETORNA UM ARRAY COM OS LANÇAMENTOS AUTOMÁTICOS QUE O FUNCIONÁRIO POSSUI
@return		C
@author	    Fabricio Amaro
@since		25/10/2013
@version	P11.8
/*/
//------------------------------------------------------------------------------
Function VerRIKFunc(cCateg,cRegime,cCodFunc,cDepto,cPeriodo,cRoteiro,cMes)
		//VerRIKFunc("1","1","000010","000030","092013")
	Local aRet := {}
	
	dbSelectArea("RIK")
	RIK->(dbSetOrder(1))
	RIK->(dbGoTop())
	While !Eof()
		
		//VERIFICA A CATEGORIA		 
		If !(ALLTRIM(cCateg) $ RIK->RIK_CATEG)
			RIK->(dbSkip())
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ -Se a Categoria pesquisada nao for a Atual do funcionario e Nao for ³
		//³ pra Proporcionalizar o lancamento, Nao carrega pra pagamento.       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If RIK->RIK_PROCAT == "2" .And.; //-1=Sim;2=Nao
		   !( SRA->RA_CATFUNC $ ALLTRIM(cCateg) )
			RIK->(dbSkip())
			Loop
		EndIf
		
		//VERIFICA O REGIME
		If !(RIK->RIK_REGIME == "3")  //SE NÃO FOR PARA AMBOS, VERIFICA O REGIME
			If !(ALLTRIM(cRegime) $ RIK->RIK_REGIME)
				RIK->(dbSkip())
				Loop
			EndIf
		EndIf
		
		//VERIFICA AS FUNÇÕES
		If !(ALLTRIM(RIK->RIK_FUNCC) == "*")
		   If !(ALLTRIM(cCodFunc) $ RIK->RIK_FUNCC)
				RIK->(dbSkip())
				Loop
			EndIf
		EndIf

		If (ALLTRIM(cCodFunc) $ RIK->RIK_FUNCD)
			RIK->(dbSkip())
			Loop			 
		EndIf

		//VERIFICA OS DEPARTAMENTOS
		If !(ALLTRIM(RIK->RIK_DEPTOC) == "*") //SE NÃO FOR PARA TODOS
			If !(ALLTRIM(cDepto) $ RIK->RIK_DEPTOC)
				RIK->(dbSkip())
				Loop
			EndIf			 
		EndIf

		If (ALLTRIM(cDepto) $ RIK->RIK_DEPTOD)
			RIK->(dbSkip())
			Loop			 
		EndIf
		
		//VERIFICA A COMARCA VINCULADA AO DEPARTAMENTO
		cComarc := Posicione("SQB",1,xFilial("SQB") + cDepto,"QB_COMARC") 

		If !(ALLTRIM(RIK->RIK_COMARC) == "*") //SE NÃO FOR PARA TODOS
			If !(ALLTRIM(cComarc) $ RIK->RIK_COMARC)
				RIK->(dbSkip())
				Loop
			EndIf			 
		EndIf

		If (ALLTRIM(cComarc) $ RIK->RIK_COMARD)
			RIK->(dbSkip())
			Loop			 
		EndIf

		///VERIFICAR SE O PERIODO ABERTO FAZ PARTE DA COMPETENCIA, DESDE QUE PASSADO COMO PARAMETRO
		If !(Empty(cPeriodo))
			If !(cPeriodo >= RIK->RIK_PERIOD .AND. cPeriodo <= (IF(Alltrim(RIK->RIK_PERIOA) == "","999999",RIK->RIK_PERIOA))) 
				RIK->(dbSkip())
				Loop			 
			EndIf 
		EndIf
		
		//VERIFICA O ROTEIRO, DESDE QUE PASSADO COMO PARAMETRO
		If !(ALLTRIM(RIK->RIK_ROTEIR) == "*")
			If !Empty(cRoteiro)
				If !(Alltrim(cRoteiro) $ RIK->RIK_ROTEIR)
					RIK->(dbSkip())
					Loop
				EndIf
			EndIf			 
		EndIf

		//VERIFICA O MES, COMO TAMBÉM SE É OBRIGATÓRIO NA ADMISSÃO, DESDE QUE PASSADO COMO PARAMETRO
		If !(Empty(cMes))
			If !(MESANO(SRA->RA_ADMISSA) == CPERIODO .AND. RIK->RIK_OBRADM == "1") //SE FOR OBRIGATÓRIO NA ADMISSÃO, NÃO PRECISA VALIDAR O MES
				If !(Alltrim(cMes) $ RIK->RIK_MESES)
					RIK->(dbSkip())
					Loop
				EndIf
			EndIf
		EndIf

		//COMO PASSOU POR TODAS AS VALIDAÇÕES ACIMA, ARMAZENA NO ARRAY
		Aadd(aRet,{RIK->RIK_COD,RIK->RIK_DESC,RIK->RIK_PD})

		RIK->(dbSkip())
	EndDo
Return aRet

