#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA056A.CH"

/*/{Protheus.doc} GPEA056A
Rotina de Programacao de Rateio em Lote.
@author esther.viveiro
@since 17/02/2016
@version 1.0
/*/
Function GPEA056A()
	
Return Nil

/*/{Protheus.doc} ModelDef
Definicao do modelo a ser utilizado
@author esther.viveiro
@since 17/02/2016
@version 1.0
/*/
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStructSRA 		:= FWFormStruct(1, 'SRA', {|cCampo| DefStrSRA(cCampo)}) // estrutura mae
Local oStructFunc		:= DefModSRA()//FWFormStruct(1, 'SRA', {|cCampo| DefStrSRA(cCampo)}/*,.T.*/) //estrutura filha /selecao de funcionarios
Local oStructRHQ 		:= FWFormStruct(1, 'RHQ')
// Blocos de codigo do modelo
Local bLinePos		:= {|oModel| Gp056PosLine(oModel)}
Local bPosValid 	:= {|oModel| Gp056PosVal(oModel)}
Local oModel

	// Remove campos da estrutura
	oStructRHQ:RemoveField('RHQ_MAT')

	// Adiciona campos a estrutura
	oStructFunc:AddField(OEMtoAnsi(STR0001), OEMtoAnsi(STR0001), 'SELECAO', 'L', 1, 0,,,{}, .F.,{|lRetorno| lRetorno := .T.}, NIL, .T., .F.)//Selecao
	oStructFunc:AddField('Grava', 'Grava', 'GRAVA_FUNC', 'L', 1, 0,,,{}, .F.,{|lRetorno| lRetorno := .T.}, NIL, .T., .F.)//GravaRegistro (para validacao)

	// Inicializador padrao
	oStructRHQ:SetProperty( 'RHQ_ORIGEM'  , MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, "'S'" ) ) 

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('GPEA056A', /*bPreValid*/, bPosValid, {|oModel| GP056AGRV(oModel)})

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields('SRALOTE', /*cOwner*/, oStructSRA)

	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	oModel:AddGrid( 'RHQLOTE', 'SRALOTE', oStructRHQ ,/*bLinePre*/, bLinePos, /*bPre*/, /*bPost*/, {|oGrid| CargaRHQ(oGrid) } )
	oModel:AddGrid( 'SRAFUNC', 'SRALOTE', oStructFunc,/*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/,{|oGrid| CargaView(oGrid) }/*bLoad*/)
	
	oModel:GetModel('SRAFUNC'):SetUseOldGrid()
	oModel:GetModel('RHQLOTE'):SetUseOldGrid()

	// Faz relaciomaneto entre os compomentes do model
	oModel:SetRelation('RHQLOTE', {{'RHQ_FILIAL','RA_FILIAL' },{'RHQ_MAT','RA_MAT'}}, RHQ->(IndexKey(1))) //manter uma relacao diferente para sempre incluir nova linha
	oModel:SetRelation('SRAFUNC', {{'RA_FILIAL','RA_FILIAL'}}, SRA->(IndexKey(1))) //relacao generica. A carga dos registro eh feita pelo grupo de perguntas

	// Define Chave Única
	oModel:GetModel('RHQLOTE'):SetUniqueLine({'RHQ_DEMES', 'RHQ_CC', 'RHQ_ITEM', 'RHQ_CLVL', 'RHQ_ORIGEM'})

	oModel:GetModel('SRALOTE'):SetOnlyView(.T.)
	oModel:GetModel('SRALOTE'):SetOnlyQuery(.T.)

	oModel:GetModel('SRAFUNC'):SetOnlyView(.T.)
	oModel:GetModel('SRAFUNC'):SetOnlyQuery(.T.)
	oStructFunc:SetProperty('SELECAO',MODEL_FIELD_NOUPD,.F.) //permite alteracao no campo selecao.

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription(OEMtoAnsi(STR0002))  // "Programação" (Rateio em Lote)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel('SRALOTE'):SetDescription(OEMtoAnsi(STR0003)) // "Funcionario"
	oModel:GetModel('RHQLOTE'):SetDescription(OEMtoAnsi(STR0004)) // "Programação de Rateio"
	oModel:GetModel('SRAFUNC'):SetDescription(OEMtoAnsi(STR0005)) // "Selecao de Funcionarios"

	oModel:SetOperation(4)
Return oModel


/*/{Protheus.doc} ViewDef
Definicao da View
@author esther.viveiro
@since 17/02/2016
@version 1.0
/*/
Static Function ViewDef()	
Local oView
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel('GPEA056A')
// Cria a estrutura a ser usada na View
Local oStructSRA  := FWFormStruct(2, 'SRA', {|cCampo| DefStrSRA(cCampo)})
Local oStructFunc := DefViewSRA()
Local oStructRHQ  := FWFormStruct(2, 'RHQ')
// Define se trabalha com item e classe contabil
Local lItemClVl   := SuperGetMv( "MV_ITMCLVL", .F., "2" ) $ "13"

	// Cria o objeto de View
	oView := FWFormView():New()

	// Remove campos da estrutura e ajusta ordem dos campos na view
	oStructRHQ:RemoveField('RHQ_MAT')

	// Ajusta exibicao dos campos
	oStructRHQ:SetProperty('RHQ_DEMES', MVC_VIEW_ORDEM,'02')
	oStructRHQ:SetProperty('RHQ_AMES' , MVC_VIEW_ORDEM,'03')
	oStructRHQ:SetProperty('RHQ_CC'   , MVC_VIEW_ORDEM,'04')
	If !lItemClVl
		// Remove
		oStructRHQ:RemoveField( 'RHQ_ITEM' )
		oStructRHQ:RemoveField( 'RHQ_CLVL' )
		oStructFunc:RemoveField( 'RHQ_ITEM' )
		oStructFunc:RemoveField( 'RHQ_CLVL' )
		// Ajusta		
		oStructRHQ:SetProperty('RHQ_PERC' , MVC_VIEW_ORDEM,'05')
	Else
		// Ajusta	
		oStructRHQ:SetProperty('RHQ_ITEM' , MVC_VIEW_ORDEM,'05')
		oStructRHQ:SetProperty('RHQ_CLVL' , MVC_VIEW_ORDEM,'06')
		oStructRHQ:SetProperty('RHQ_PERC' , MVC_VIEW_ORDEM,'07')
	EndIf
	
	oStructRHQ:RemoveField( 'RHQ_FILIAL' )

	// Define qual o Modelo de dados será utilizado
	oView:SetModel(oModel)

	oStructSRA:SetNoFolder()
	oStructFunc:SetNoFolder()

	// Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField('VIEW_SRA', oStructSRA, 'SRALOTE')

	oView:AddGrid('VIEW_RHQ' , oStructRHQ , 'RHQLOTE')
	oView:AddGrid('VIEW_FUNC', oStructFunc, 'SRAFUNC')

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox('GERAL', 100)

	oView:CreateVerticalBox('SRAGRID',50,'GERAL')
	oView:CreateVerticalBox('RHQGRID',50,'GERAL')
	
	oView:CreateHorizontalBox('INFERIOR', 0 ,'SRAGRID')
	oView:CreateHorizontalBox('TOPO'	,100,'SRAGRID')

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView('VIEW_SRA' , 'INFERIOR')
	oView:SetOwnerView('VIEW_RHQ' , 'RHQGRID')
	oView:SetOwnerView('VIEW_FUNC', 'TOPO')

	// Liga a identificacao do componente
	oView:EnableTitleView('VIEW_RHQ' , STR0006) // "Configuração de Rateio"
	oView:EnableTitleView('VIEW_FUNC', STR0007) // "Seleção de Funcionários"

	oView:SetCloseOnOk({ || .T. }) //fechar a tela apos o commit
Return oView


/*/{Protheus.doc} DefStrSRA
Definicao dos campos a serem utilizados nas estruturas SRALOTE e SRAFUNC
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample DefStrSRA(cCampo)
@param  cCampo  , caractere, nome do campo a ser validado
@return lRetorno, logico   , se campo fará parte ou nao da estrutura
/*/
Static Function DefStrSRA(cCampo)
Local lRetorno := .F.
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_FILIAL/RA_MAT/RA_NOME/RA_ADMISSA/RA_CC/RA_DESCCC/RA_DEPTO/RA_DDEPTO/RA_ITEM/RA_CLVL/'
		lRetorno := .T.
	EndIf
Return lRetorno


/*/{Protheus.doc} DefViewSRA
Definicao dos campos a serem utilizados na estrutura StructFunc 
@author esther.viveiro
@since 17/02/2016
@version 1.0
@return oStruct, objeto, estrutura composta com os campos pertencentes.
/*/
Static Function DefViewSRA()
Local oStruct := FWFormViewStruct():New()
	               //Campo			,Ordem	,Titulo	,Descricao,Help,Tipo,Picture,PictVar,F3,Editavel,Folder	,Group	,Combo	,Tam.Combo 	, Init. , Virtual
	oStruct:AddField('SELECAO'		,'01'	, ''	, STR0001 ,NIL ,'L'	,''		,NIL	,'',.T.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_FILIAL'	,'02'	,STR0008, STR0008 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_MAT'		,'03'	,STR0009, STR0009 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_NOME'		,'04'	,STR0010, STR0010 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_ADMISSA'	,'05'	,STR0011, STR0011 ,NIL ,'D'	,'@D'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_CC'		    ,'06'	,STR0012, STR0012 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_DESCCC'	,'07'	,STR0020, STR0020 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_DEPTO'		,'08'	,STR0013, STR0013 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_DDEPTO'	,'09'	,STR0020, STR0020 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_ITEM'		,'10'	,STR0014, STR0014 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
	oStruct:AddField('RA_CLVL'		,'11'	,STR0015, STR0015 ,NIL ,'C'	,'@!'	,NIL	,'',.F.		,''		,''		,{}		,0			,''		,.F.)
Return oStruct

/*/{Protheus.doc} DefModSRA
Definicao dos campos a serem utilizados na estrutura StructFunc 
@author esther.viveiro
@since 17/02/2016
@version 1.0
@return oStruct, objeto, estrutura composta com os campos pertencentes.
/*/
Static Function DefModSRA()
	Local oStruct := FWFormModelStruct():New()
	Local aArea   := GetArea()
	
	DbSelectArea("SRA")
	                //Título      , ToolTip ,IdField      ,Tipo ,Tamanho                   ,Decimal,bValid,bWhen,aValues,lObrig,bInit,lKey,lNoUpd,lVirtual,cValid
	oStruct:AddField(STR0008      , ""      ,'RA_FILIAL'  , 'C' ,Len(SRA->RA_FILIAL)       ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.T. )
	oStruct:AddField(STR0009      , ""      ,'RA_MAT'     , 'C' ,Len(SRA->RA_MAT)          ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.T. )
	oStruct:AddField(STR0010      , ""      ,'RA_NOME'    , 'C' ,Len(SRA->RA_NOME)         ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	oStruct:AddField(STR0011      , ""      ,'RA_ADMISSA' , 'D' ,Len(DToC(SRA->RA_ADMISSA)),NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	oStruct:AddField(STR0012      , ""      ,'RA_CC'      , 'C' ,Len(SRA->RA_CC)           ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	oStruct:AddField(STR0020      , ""      ,'RA_DESCCC'  , 'C' ,40                        ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	oStruct:AddField(STR0013      , ""      ,'RA_DEPTO'   , 'C' ,Len(SRA->RA_DEPTO)        ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	oStruct:AddField(STR0020      , ""      ,'RA_DDEPTO'  , 'C' ,30                        ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	oStruct:AddField(STR0014      , ""      ,'RA_ITEM'    , 'C' ,Len(SRA->RA_ITEM)         ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	oStruct:AddField(STR0015      , ""      ,'RA_CLVL'    , 'C' ,Len(SRA->RA_CLVL)         ,NIL    ,NIL   ,NIL  ,NIL    ,NIL   ,NIL  ,.F. )
	
	RestArea(aArea)
Return oStruct


/*/{Protheus.doc} CargaView
Carrega funcionarios selecionados atraves do pergunte GPEA056A
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample CargaView(oGrid)
@param oGrid, objeto, grid da estrutura a ser carregada
@return aRet, array , array com os funcionarios carregados
/*/
Static Function CargaView(oGrid)
Local aRet	:= {}
Local aArea := GetArea()
Local cFilDe, cFilAte, cMatDe, cMatAte, cCCDe, cCCAte, cDeptoDe, cDeptoAte, cSituacao, cCategoria,cDescCC, cDescDepto := ""
	
	If Pergunte("GPEA056A",.T.)
		cFilDe		:= mv_par01
		cFilAte		:= mv_par02
		cCCDe		:= mv_par03
		cCCAte		:= mv_par04
		cDeptoDe	:= mv_par05
		cDeptoAte	:= mv_par06
		cMatDe		:= mv_par07
		cMatAte		:= mv_par08
		cSituacao	:= mv_par09
		cCategoria	:= mv_par10

		// Monta matriz de visualizacao.
		SRA->( dbGoTop() )
		While SRA->(!Eof())
			If	(SRA->RA_FILIAL >= cFilDe)	 .AND. (SRA->RA_FILIAL  <= cFilAte)  .AND.;
				(SRA->RA_MAT >= cMatDe) 	 .AND. (SRA->RA_MAT 	<= cMatAte)	 .AND.;
				(SRA->RA_CC >= cCCDe)		 .AND. (SRA->RA_CC 	    <= cCCAte)	 .AND.;
				(SRA->RA_DEPTO >= cDeptoDe)  .AND. (SRA->RA_DEPTO   <= cDeptoAte).AND.;
				(SRA->RA_SITFOLH $ cSituacao).AND. (SRA->RA_CATFUNC $ cCategoria)

				cDescCC 	:= fDesc(If(CtbInUse(),'CTT','SI3'),SRA->RA_CC,If(CtbInUse(),'CTT_DESC01','I3_DESC'),,SRA->RA_FILIAL)
				cDescDepto 	:= fDesc('SQB',SRA->RA_DEPTO,'QB_DESCRIC')
				aAdd(aRet,{SRA->( Recno() ),{SRA->RA_FILIAL, SRA->RA_MAT, SRA->RA_NOME, SRA->RA_ADMISSA,SRA->RA_CC, cDescCC, ;
											   SRA->RA_DEPTO, cDescDepto , SRA->RA_ITEM, SRA->RA_CLVL, .T., .F. }})
			EndIf
			SRA->(dbSkip())
		Enddo
		If Empty(aRet)
			Help( ,, 'Help',, OEMtoAnsi(STR0016), 1, 0 ) //"Não foram encontrados funcionários para o filtro selecionado."
		EndIf
	EndIf
	RestArea( aArea )
Return aRet 

/*/{Protheus.doc} CargaRHQ
Carrega estrutura em branco da RHQ
@author Allyson Luiz Mesashi
@since 08/03/2022
@param oGrid, objeto, grid da estrutura a ser carregada
@return aRet, array , array com os funcionarios carregados
/*/
Static Function CargaRHQ(oGrid)

Local aRet	:= {}

Return aRet 

/*/{Protheus.doc} Gp056LinePos
Rotina de validacao da linha de configuracao do Rateio
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample Gp056LinePos(oModel)
@param  oModel , objeto, objeto do modelo a ser validado
@return lReturn, logico, linha valida ou nao
/*/
Static Function Gp056PosLine( oModel )	
Local lRetorno		:= .T.	
	// Valida se a dataAte e menor que a dataDe
	If ! valAteMenorDe( oModel )
		Help("",1,"GP056DTAMAIORD") //"O Campo 'A Mês/Ano' deve estar vazio, igual ou maior que o campo 'De Mês/Ano'." "Corrija o campo 'A Mês/Ano'".
		lRetorno := .F.
	EndIf
	// Valida se a data e retroativa a data atual
	If ! valDtRetro( oModel )
		lRetorno := .F.
	EndIf		
Return lRetorno


/*/{Protheus.doc} Gp056PosVal
Rotina de validacao do modelo pré-commit. Verifica se todas as linhas formam 100% de rateio
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample Gp056PosVal(oModel)
@param  oModel , objeto, objeto do modelo a ser validado
@return lReturn, logico, modelo valido ou nao
/*/
Static Function Gp056PosVal( oModel )
Local oMdlRHQ := oModel:GetModel('RHQLOTE')
Local aFunc   := oModel:GetModel('SRAFUNC'):aCols //array com os funcionarios
Local lRetorno := .F. //inicia falso pensando que nao ha funcionario selecionado
Local n := 0
	For n := 1 to Len(aFunc)
		If aFunc[n][11] //ha pelo menos um funcionario selecionado
			lRetorno := .T.
			Exit  
		EndIf
	Next n
	If lRetorno
		// Valida se todos os agrupamentos de Rateio totalizam 100% e se o retorno deve ser verdadeiro para efetuar a validacao.
		lRetorno := valRatEConflPer(oMdlRHQ)
		If lRetorno
			// Valida gravacao das linhas. Verifica se sera possivel realizar gravacao ou nao
			lRetorno := GP056AVLD(oModel)
		EndIf
	Else
		Help( "",1, '.GPEA056AV1.') ////"Não há funcionários selecionados." ### "Selecione pelo menos 1 funcionário."
	EndIf
Return lRetorno


/*/{Protheus.doc} valAteMenorDe
Funcao responsavel pela validação da dataAte não ser menor que a dataDe
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample valAteMenorDe(oModel)
@param  oModel , objeto, objeto do modelo a ser validado
@return lReturn, logico, data valida ou nao
/*/
Static Function valAteMenorDe( oModel )
Local lRetorno		:= .T.
Local nMesDe		:= 0
Local nAnoDe		:= 0
Local nMesAte		:= 0
Local nAnoAte		:= 0

	nMesDe 	:= Val(Substr(oModel:GetValue('RHQ_DEMES'),1,2))
	nAnoDe 	:= Val(Substr(oModel:GetValue('RHQ_DEMES'),3,4))

	nMesAte	:= Val(Substr(oModel:GetValue('RHQ_AMES'),1,2))
	nAnoAte := Val(Substr(oModel:GetValue('RHQ_AMES'),3,4))

	If !Empty(oModel:GetValue('RHQ_AMES'))	
		If nAnoAte < nAnoDe
			lRetorno := .F.
		ElseIf nAnoAte <= nAnoDe
			If nMesAte < nMesDe
				lRetorno := .F.
			EndIf
		EndIf
	EndIf
Return lRetorno


/*/{Protheus.doc} valPerAberto
Funcao responsavel pela validação se o periodo inserido nao esta sendo atendido em outra condicao
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample valPerAberto(dChkDtDe, dChkDtAte, dDeAnoMes, dAteAnoMes)
@param  dChkDtDe  , data, Data de a ser conferida
@param  dChkDtAte , data, Data de a ser conferida
@param  dDeAnoMes , data, Data de que servira de parametro na conferencia
@param  dAteAnoMes, data, Data de que servira de parametro na conferencia
@return lReturn   , logico, data valida ou nao
/*/
Static Function valPerAberto( dChkDtDe, dChkDtAte, dDeAnoMes, dAteAnoMes )
Local lRetorno := .T.
	If Empty(dChkDtAte) .AND. Empty(dAteAnoMes)
		Help("",1,"GP056DTCONFLIT")	//"A data informada no campo 'De Mês/Ano' é conflitante com um período previamente cadastrado."  "Revise os períodos."
		lRetorno := .F.
	ElseIf !Empty(dChkDtAte) .AND. !Empty(dAteAnoMes)
		If ConflictDate( dChkDtDe, dChkDtAte, dDeAnoMes, dAteAnoMes )
				Help("",1,"GP056DTCONFLIT")	//"A data informada no campo 'De Mês/Ano' é conflitante com um período previamente cadastrado."  "Revise os períodos."
				lRetorno := .F.
		EndIf
	ElseIf Empty(dChkDtAte) .AND. !Empty(dAteAnoMes)
		If dChkDtDe <= dAteAnoMes
				Help("",1,"GP056DTCONFLIT")	//"A data informada no campo 'De Mês/Ano' é conflitante com um período previamente cadastrado."  "Revise os períodos."
				lRetorno := .F.
		EndIf
	EndIf
Return lRetorno

/*/{Protheus.doc} valRatEConflPer
Monta o agrupamento dos rateios, valida se os mesmos totalizam 100% e validam se os períodos são conflitantes
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample valRatEConflPer( oModel )
@param  oModel , objeto, objeto a ser validado
@return lReturn, logico, data valida ou nao
/*/
Static Function valRatEConflPer(oModel)
Local nL
Local nLinGrid
Local nLinArray
Local nAcum
Local nTotLin 	:= oModel:GetQtdLine()
Local aAcum   	:= {}
Local lAchou	:= .F.
Local lRetorno	:= .T.

	For nLinGrid := 1 to nTotLin
		// A linha da Grid nao pode estar deletada
		If ! ( oModel:IsDeleted(nLinGrid) )
			If Empty(aAcum)
				// Na primeira passada insere o valor do primeiro agrupamento
				AADD(aAcum	,{oModel:GetValue('RHQ_DEMES', nLinGrid) + oModel:GetValue('RHQ_AMES' , nLinGrid),;
							  oModel:GetValue('RHQ_PERC' , nLinGrid),;
							  oModel:GetValue('RHQ_DEMES', nLinGrid),;
							  oModel:GetValue('RHQ_AMES' , nLinGrid)};
					)
			Else
				lAchou := .F.
				// Percorre o acumulado no Array para tentar encontrar se o agrupamento atual já existe
				For nLinArray := 1 to Len(aAcum) 
					If aAcum[nLinArray][1] == oModel:GetValue('RHQ_DEMES', nLinGrid) + oModel:GetValue('RHQ_AMES' , nLinGrid)
						aAcum[nLinArray][2] := aAcum[nLinArray][2] + oModel:GetValue('RHQ_PERC' , nLinGrid)
						lAchou := .T.
						Exit
					EndIf
				Next
				//Se não foi localizado o agrupamento atual nos existentes, insere-se um novo agrupamento no final do array 
				If !lAchou
						AADD(aAcum	,{oModel:GetValue('RHQ_DEMES', nLinGrid) + oModel:GetValue('RHQ_AMES' , nLinGrid),;
									  oModel:GetValue('RHQ_PERC' , nLinGrid),;
									  oModel:GetValue('RHQ_DEMES', nLinGrid),;
									  oModel:GetValue('RHQ_AMES' , nLinGrid)};
							)
				EndIf
			EndIf
		EndIf
	Next

	nAcum := Len(aAcum)
	For nLinArray := 1 to nAcum
		// Valida se a totalizacao dos agrupamentos de rateio estao em 100% 
		If aAcum[nLinArray][2] <> 100 .AND. lRetorno
			Help("",1,"GP056CEMPORC") //A soma dos percentuais de rateio não totaliza 100%." "Ajuste os percentuais a fim de atingirem 100% do rateio.
			lRetorno := .F.
			Exit
		EndIf

		// Valida se o periodo nao esta em conflito com outro ja cadastrado
		If lRetorno
			For nL := 1 to nAcum
				If nLinArray <> nL
					If !valPerAberto(;
										StoD(Substr(aAcum[nL][3],3,4) + Substr(aAcum[nL][3],1,2)+"01"),;
										If(Empty(aAcum[nL][4]),Nil,StoD(Substr(aAcum[nL][4],3,4) + Substr(aAcum[nL][4],1,2)+"01")),;
										StoD(Substr(aAcum[nLinArray][3],3,4) + Substr(aAcum[nLinArray][3],1,2)+"01"),;
										If(Empty(aAcum[nLinArray][4]),Nil,StoD(Substr(aAcum[nLinArray][4],3,4) + Substr(aAcum[nLinArray][4],1,2)+"01"));
									 )
						lRetorno := .F.
						Exit
					EndIf
				EndIf
			Next
		EndIf
		// Ao Encontrar um erro sai das validacoes
		If !lRetorno
			Exit
		EndIf	
	Next
Return lRetorno 


/*/{Protheus.doc} GP056AVLD
Funcao de validacao da gravacao do modelo
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample GP056AVLD( oModel )
@param  oModel , objeto, modelo a ser validado
@return lReturn, logico, status modelo gravado
/*/
Static Function GP056AVLD(oModel)
Local aColsFunc := oModel:GetModel('SRAFUNC'):aCols
Local aColsRHQ  := oModel:GetModel('RHQLOTE'):aCols
Local aLog 		:= {}
Local lSobrepoe := If(mv_par11 == 1, .T., .F.)
Local lGrava, lRegDif, lRetorno := .T.
Local nLinhaFunc:= Len(aColsFunc)
Local nLinhaRHQ := Len(aColsRHQ)
Local cMessage  := ""
Local nDeMesOld, nDeAnoOld, nAMesOld, nAAnoOld, nDeMesNew, nDeAnoNew := 0
Local x, n, y, nGrv	:= 0

	For x := 1 to nLinhaFunc
		If aColsFunc[x][11] // Se selecionado
			lGrava := .T.
			lRegDif:= .T.
			DbSelectArea('RHQ')
			RHQ->(DbSetOrder(1))
			If RHQ->(DbSeek(aColsFunc[x][1]+aColsFunc[x][2])) //Filial+Matricula
				While RHQ->(RHQ_MAT) == aColsFunc[x][2]
					For n := 1 to nLinhaRHQ
						//	Nao esta deletado			anoAtual == anoNovo												mesAteal >= mesNovo
						If !(aColsRHQ[n][9]) .AND. (SUBSTR(RHQ->RHQ_AMES,3,6) == SUBSTR(aColsRHQ[n][2],3,6) .AND. SUBSTR(RHQ->RHQ_AMES,1,2) >= SUBSTR(aColsRHQ[n][2],1,2)) ;
							.OR. (SUBSTR(RHQ->RHQ_AMES,3,6) > SUBSTR(aColsRHQ[n][2],3,6)) // anoAtual > anoNovo
							// Registro gravado RHQ
							nDeMesOld:= Val(SUBSTR(RHQ->RHQ_DEMES,1,2))
							nDeAnoOld:= Val(SUBSTR(RHQ->RHQ_DEMES,3,6))
							nAMesOld := Val(SUBSTR(RHQ->RHQ_AMES,1,2))
							nAAnoOld := Val(SUBSTR(RHQ->RHQ_AMES,3,6))

							// Registro do Grid RHQ
							nDeMesNew := Val(SUBSTR(aColsRHQ[n][2],1,2))
							nDeAnoNew := Val(SUBSTR(aColsRHQ[n][2],3,6))

							If (nAAnoOld < nDeAnoOld) .OR. (nAAnoOld == nDeAnoOld .AND. nAMesOld < nDeMesNew)
								lRegDif := .F. //Data final menor que data inicial
							EndIf

							//atualiza registro
							If !( lRegDif ) .or. !( lSobrepoe )
								lGrava := .F.
								Exit
							EndIf
						EndIf
					Next n
					RHQ->(DbSkip())
				EndDo
			EndIf
			For n := 1 to nLinhaRHQ //faz o loop separado para realizar toda validacao primeiro e depois gravar o novo registro
				If !(aColsRHQ[n][9]) .AND. lGrava //linha nao esta deletada e Gravacao OK
					oModel:GetModel('SRAFUNC'):aCols[x][12] := .T.
				EndIf
			Next n
		EndIf
		If !lRegDif .AND. aColsFunc[x][11] //se houve erro na atualizacao do registro, cria log
			AADD(aLog, aColsFunc[x][1] + ' - ' + aColsFunc[x][2]) 
		ElseIf lGrava //se realizou a gravacao 
			nGrv++
		EndIf
	Next x

	If !(Empty(aLog))
		cMessage := OEMtoAnsi(STR0017) + CRLF
		y:= 1
		While y <= len(aLog)
			If (y+1) <= len(aLog)
				cMessage += aLog[y] + ' / ' + aLog[y+1] + CRLF
			ElseIf Mod(y,2) == 1  //se numero impar
				cMessage += aLog[y] + CRLF
			EndIf
			y += 2
		EndDo
		cMessage += Replicate('-',50) + CRLF + OEMtoAnsi(STR0018)
		Help( ,, 'Help',, OEMtoAnsi(cMessage), 1, 0 )
		lRetorno := .F.
	ElseIf Empty(aLog) .AND. nGrv == 0
		Help( "",1, '.GPEA056AV3.')
		lRetorno := .F.
	EndIf
Return lRetorno


/*/{Protheus.doc} GP056AGRV
Funcao de gravacao do modelo
@author esther.viveiro
@since 17/02/2016
@version 1.0
@sample GP056AGRV( oModel )
@param  oModel , objeto, modelo a ser gravado
@return lReturn, logico, status modelo gravado
/*/
Static Function GP056AGRV(oModel)
Local aColsFunc := oModel:GetModel('SRAFUNC'):aCols
Local aColsRHQ  := oModel:GetModel('RHQLOTE'):aCols
Local lSobrepoe := If(mv_par11 == 1, .T., .F.)
Local nLinhaFunc:= Len(aColsFunc)
Local nLinhaRHQ := Len(aColsRHQ)
Local lGrava, lRegDif, lRetorno := .T.
Local nDeMesOld, nDeAnoOld, nAMesOld, nAAnoOld, nDeMesNew, nDeAnoNew := 0
Local x, n	:= 0

	For x := 1 to nLinhaFunc
		If aColsFunc[x][12] .AND. aColsFunc[x][11] // Se selecionado
			lGrava := .T.
			lRegDif:= .T.
			DbSelectArea('RHQ')
			RHQ->(DbSetOrder(1))
			If lSobrepoe
				If RHQ->(DbSeek(aColsFunc[x][1]+aColsFunc[x][2])) //Filial+Matricula
					While RHQ->(RHQ_MAT) == aColsFunc[x][2]
						For n := 1 to nLinhaRHQ
							//	Nao esta deletado			anoAtual == anoNovo												mesAtual >= mesNovo
							If !(aColsRHQ[n][9]) .AND. (SUBSTR(RHQ->RHQ_AMES,3,6) == SUBSTR(aColsRHQ[n][2],3,6) .AND. SUBSTR(RHQ->RHQ_AMES,1,2) >= SUBSTR(aColsRHQ[n][2],1,2)) ;
								.OR. (SUBSTR(RHQ->RHQ_AMES,3,6) > SUBSTR(aColsRHQ[n][2],3,6)) // anoAtual > anoNovo
								// Registro gravado RHQ
								nDeMesOld:= Val(SUBSTR(RHQ->RHQ_DEMES,1,2))
								nDeAnoOld:= Val(SUBSTR(RHQ->RHQ_DEMES,3,6))
								nAMesOld := Val(SUBSTR(RHQ->RHQ_AMES,1,2))
								nAAnoOld := Val(SUBSTR(RHQ->RHQ_AMES,3,6))

								// Registro do Grid RHQ
								nDeMesNew := Val(SUBSTR(aColsRHQ[n][2],1,2))
								nDeAnoNew := Val(SUBSTR(aColsRHQ[n][2],3,6))

								If (nAAnoOld < nDeAnoOld) .OR. (nAAnoOld == nDeAnoOld .AND. nAMesOld < nDeMesNew)
									lRegDif := .F. //Data final menor que data inicial
								EndIf

								//atualiza registro
								If lRegDif .AND. lSobrepoe
									RHQ->(Reclock("RHQ",.F.))
									RHQ->RHQ_DEMES	:= aColsRHQ[n][2]
									RHQ->RHQ_AMES	:= aColsRHQ[n][3]
									RHQ->RHQ_CC		:= aColsRHQ[n][4]
									RHQ->RHQ_ITEM	:= aColsRHQ[n][5]
									RHQ->RHQ_CLVL	:= aColsRHQ[n][6]
									RHQ->RHQ_PERC	:= aColsRHQ[n][7]
									RHQ->RHQ_ORIGEM	:= aColsRHQ[n][8]
									RHQ->(MsUnlock())
		   				 	  EndIf
							EndIf
							If RHQ->(RHQ_MAT) == aColsFunc[x][2]
								RHQ->(DbSkip())	
							Endif	
						Next n
						RHQ->(DbSkip())
					EndDo
				Endif	
			Else			
				For n := 1 to nLinhaRHQ //faz o loop separado para realizar toda validacao primeiro e depois gravar o novo registro
					If !(aColsRHQ[n][9]) .AND. lGrava //linha nao esta deletada e Gravacao OK
						RHQ->(RecLock("RHQ",.T.))
						RHQ->RHQ_FILIAL := aColsFunc[x][1]
						RHQ->RHQ_MAT 	:= aColsFunc[x][2]
						RHQ->RHQ_DEMES	:= aColsRHQ[n][2]
						RHQ->RHQ_AMES	:= aColsRHQ[n][3]
						RHQ->RHQ_CC		:= aColsRHQ[n][4]
						RHQ->RHQ_ITEM	:= aColsRHQ[n][5]
						RHQ->RHQ_CLVL	:= aColsRHQ[n][6]
						RHQ->RHQ_PERC	:= aColsRHQ[n][7]
						RHQ->RHQ_ORIGEM	:= aColsRHQ[n][8]
						RHQ->(MsUnlock())
					EndIf
				Next n
			Endif	
		EndIf
	Next x
Return lRetorno

/*/{Protheus.doc} valDtRetro
Valida se a data é retroativa ao período atual de cálculo
@author gabriel.almeida
@since 17/08/2017
@version 1.0
@sample valDtRetro( oModel )
@param  oModel , objeto, modelo a ser gravado
@return lReturn, logico, status modelo gravado
/*/
Static Function valDtRetro( oMdlRHQ )
	Local lRetorno 		:= .T.
	Local dChkDtDe		:= StoD(Substr(oMdlRHQ:GetValue('RHQ_DEMES'),3,4)+Substr(oMdlRHQ:GetValue('RHQ_DEMES'),1,2)+"01")
	Local cPer         := ""
	Local cSem         := ""
	Local cProc        := ""
	Local cRot         := ""
	Local dFolMes      := StoD("    /  /  ")
	
	cProc 	:= SRA->RA_PROCES
	cRot 	:= fGetCalcRot("1")
	//Carrega o periodo atual de calculo (aberto)                  
	fGetLastPer( @cPer,@cSem , cProc, cRot )
	dFolMes := StoD(Substr(cPer,1,4)+Substr(cPer,5,2)+"01")
	If dChkDtDe < dFolMes
	   	Help("",1,"GP056DTDERETRO") //"A data informada no campo 'De Mês/Ano' é inferior a data atual." "Ajuste o campo 'De Mês/Ano".
	   	lRetorno := .F.		
	EndIf

Return lRetorno
