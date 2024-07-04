#INCLUDE "AGRA601.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

Static cDXL_OP 		:= Space(TamSX3("D3_OP")[01])
Static __lRomUnif 	:= SuperGetMV("MV_AGRB001",.T.,.F.) /*Utiliza romaneio unificado*/
Static __lnewComerc	:= SuperGetMv('MV_AGRA001', , .F.) // Parametro novo modelo de comercialização
Static __MVAGRPRFA  := SuperGetMv("MV_AGRPRFA", ,.F.) //se irá gerar Ordem de Produção para o fardão
Static __lAutomato  := IsBlind() //automação

//-----------------------------------------------------------
/*/{Protheus.doc} AGRA601
Cadastro de fardoes

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: GENERICO
/*/
//-----------------------------------------------------------
Function AGRA601()
	Local aArea    	:= GetArea()
	Local bKeyF12 	:= { || Pergunte('AGRA60102', .T.) }
	Local bKeyF11 	:= { || Pergunte('AGRA60101', .T.,STR0051) }
	Local oBrowse	:= Nil
	Private cCodProdut
	Private _lNovSafra := .T.
	Private _cCLTTEMP //Cria a Temp Table de Consulta de Ordem de Colheita
	
	If _cCLTTEMP == Nil
		_cCLTTEMP := AGRA530TTO(@_cCLTTEMP)
	EndIf
	
	if TamSX3("DXL_SAFRA")[1] = 6
		_lNovSafra := .F.
	endIf

	//-----------------
	// Seta Hotkeys
	//-----------------
	If __MVAGRPRFA 
		SetKey( VK_F12, bKeyF12 )
	Endif	
	SetKey( VK_F11, bKeyF11 )
	SetKey( K_CTRL_F8, { || AGR601ALT() } )
	//-------------------------
	//Instancia o objeto Browse
	//-------------------------
	oBrowse := FWMBrowse():New( , , , , , , , , , ,)
	oBrowse:SetAlias('DXL')
	oBrowse:SetDescription( STR0001 ) //"Cadastro de Fardões"
	//-------------------------
	//Adiciona lengedas                
	//-------------------------
	oBrowse:AddLegend( 'DXL_STATUS == "1"'	,'WHITE'	, AGRTxtBox('1','DXL_STATUS') ) //"Previsto"
	oBrowse:AddLegend( 'DXL_STATUS == "2"'	,'BLUE'		, AGRTxtBox('2','DXL_STATUS') ) //"Em Romaneio de Entrada"
	oBrowse:AddLegend( 'DXL_STATUS == "3"'  ,'GREEN'	, AGRTxtBox('3','DXL_STATUS') ) //"Disponivel"
	oBrowse:AddLegend( 'DXL_STATUS == "4"'	,'YELLOW'	, AGRTxtBox('4','DXL_STATUS') ) //"Em Beneficiamento"
	oBrowse:AddLegend( 'DXL_STATUS == "5"'	,'RED'		, AGRTxtBox('5','DXL_STATUS') ) //"Beneficiado"
	oBrowse:AddLegend( 'DXL_STATUS == "6"'	,'BLACK'	, AGRTxtBox('6','DXL_STATUS') ) //"Finalizado"
	
	//Acerta código único nos registros que estiverem vazios
    If DXL->(ColumnPos("DXL_CODUNI")) > 0
       AGRA601CDU()
    EndIf
	
	//-------------------------
	//Ativa o Browse
	//-------------------------
	oBrowse:Activate()
	
	//Declara Hotkeys
	If __MVAGRPRFA 
		SetKey( VK_F12, Nil )
	Endif	
	SetKey( VK_F11, Nil )
	SetKey( K_CTRL_F8, Nil )
	RestArea(aArea)
Return()

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruDXL 	:= FwFormStruct( 1, 'DXL' )	// Cadastro de Fardao	
	
	If !__lnewComerc 
		//Verifica parametro "MV_AGRPRFA" para habilitar campo virtual de OP
		If __MVAGRPRFA .And. !IsIncallStack("AGR601ALT") 
			oStruDXL:AddField(/*cTitulo*/STR0053,/*"Ordem de produção"*/;
			/*cTooltip*/ STR0052,/*"Produção de fardão"*/;
			/*cIdField*/'DXL_OP',;
			/*cTipo*/'C',;
			/*nTamanho*/13,;
			/*nDecimal*/0,;
			/*bValid*/ ,;
			/*bWhen*/,;
			/*aValues*/,;
			/*lObrigat*/ .F.,;
			/*bInit*/ {||AGRA601PE()},;
			/*lKey*/,;
			/*lNoUpd */,;
			/*lVirtual */ .T.)
		Endif
	EndIf
	//-----------------------------
	// Instancia o Modelo de dados
	//-----------------------------
	oModel := MpFormModel():New( "AGRA601", { |oModel| PreMdl( oModel ) }, { |oModel| sfPost( oModel ) },{ |oModel| A601GRV( oModel ) }, )
	oModel:SetDescription( STR0008 ) //"Modelo de dados do Fardao"

	//--------------------------------
	// Adiciona a estrutura de dados
	//--------------------------------
	oModel:AddFields( 'DXLMASTER', 			, oStruDXL )
	oModel:GetModel( 'DXLMASTER' ):SetDescription( STR0015 ) //"Dados do Fardao"
			
	// Valida a ativação do model
	//----------------------------
	oModel:SetVldActivate( { |oMdl| A601VLDACT( oMdl ) } )
	
	//-------------------------------------
	// Valida apos a Ativação do model
	//-------------------------------------
	oModel:SetActivate( { |oMdl| A601ACTIVE( oMdl ) } )
Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna o modelo de visualização da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( 'AGRA601' )
	Local oStruDXL  := Nil
	
	if !IsIncallStack("AGR601ALT")
		oStruDXL := FwFormStruct( 2, 'DXL', {|cCampo| !(cCampo $ 'DXL_STATUS|DXL_OK')} )		
	else
		oStruDXL := FwFormStruct( 2, 'DXL')
		oStruDXL:SetProperty( '*' ,MVC_VIEW_CANCHANGE, .t.)	
	endif
			
	oView := FwFormView():New()

	oView:SetModel( oModel )

	oView:AddField( 'VIEW_DXL', oStruDXL, 'DXLMASTER' )
	
	If __lnewComerc
		//--Caso o parametro "MV_AGRPRFA" estiver como .T. habilita os campos LOTE - SUBLOTE e ENDEREÇO
		If .NOT. __MVAGRPRFA .AND. .NOT. IsIncallStack("AGR601ALT") 
			oStruDXL:RemoveField( "DXL_LOTCTL" )
			oStruDXL:RemoveField( "DXL_NMLOT" )
			oStruDXL:RemoveField( "DXL_LOCLIZ" )	
		Endif
	Else
		Pergunte('AGRA60102', .F.)
		//Verifica parametro "MV_AGRPRFA" para habilitar campo virtual de OP
		If __MVAGRPRFA .And. !IsIncallStack("AGR601ALT")  .and. (MV_PAR01 = 1 )

			oStruDXL:AddField(/*cIdField*/"DXL_OP",;
			/*cOrdem*/'40',;
			/*cTitulo*/STR0053,;
			/*cDescric*/STR0052,;
			/*aHelp*/,;
			/*cType*/"Get",;
			/*cPicture*/"@!",;
			/*bPictVar*/,;
			/*cLookUp*/'SC2',;
			/*lCanChange*/.T.,;
			/*cFolder*/,;
			/*cGroup*/,;
			/*aComboValues*/ ,;
			/*nMaxLenCombo*/,;
			/*cIniBrow*/,;
			/*lVirtual*/.T.,;
			/*cPictVar*/,;
			/*lInsertLine*/.F.,;
			/*nWidth*/)
		EndIf
	EndIf

	oView:CreateHorizontalBox( 'TOTAL', 100 )

	oView:SetOwnerView( 'VIEW_DXL', 'TOTAL' )
	
	oView:SetCloseOnOk( {||.f.} )

Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Retorna o Menu padrão da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	PRIVATE cCadastro := OemToAnsi("ADAD") // Aplicacoes de Servicos
		
	Pergunte('AGRA60102', .F.)

	ADD OPTION aRotina Title OemToAnsi(STR0009)	Action 'VIEWDEF.AGRA601A'	OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina Title OemToAnsi(STR0010)	Action 'VIEWDEF.AGRA601'	OPERATION 3 ACCESS 0 //"Incluir"
	ADD OPTION aRotina Title OemToAnsi(STR0011)	Action 'VIEWDEF.AGRA601A'	OPERATION 4 ACCESS 0 //"Alterar"
	ADD OPTION aRotina Title OemToAnsi(STR0012)	Action 'VIEWDEF.AGRA601A'	OPERATION 5 ACCESS 0 //"Excluir"
	ADD OPTION aRotina Title OemToAnsi(STR0048)	Action 'AGR601MANU()'		OPERATION 8 ACCESS 0 //"manutenção"
	ADD OPTION aRotina Title OemToAnsi(STR0013)	Action 'VIEWDEF.AGRA601'	OPERATION 6 ACCESS 0 //"Imprimir"
	ADD OPTION aRotina Title OemToAnsi(STR0088) Action 'StaticCall(AGRA601, GetMovProducao,/*params*/)' OPERATION 10  ACCESS 0  DISABLE MENU/*'Histórico de Fardão'*/
	If __lnewComerc
		ADD OPTION aRotina Title OemToAnsi(STR0089) Action 'AGRA601HFA()'       OPERATION 11  ACCESS 0  //Histórico de Fardos
		ADD OPTION aRotina Title OemToAnsi(STR0090) Action 'UBAC012'            OPERATION 12  ACCESS 0 //Status Consolidado Fardão
	EndIf
	
	If __MVAGRPRFA 
		If ValType(MV_PAR01) == 'N'
			If MV_PAR01 = 2 //Apontamento por Fardão = Não
				ADD OPTION aRotina Title OemToAnsi(STR0058) Action 'StaticCall(AGRA601, CriaTlProF,/*params*/)' OPERATION 9  ACCESS 0 /*"Produção"*/
			Endif
		EndIf			
	Endif
	
	If ExistBlock('AGR601BW')
		aRet := ExecBlock('AGR601BW',.F.,.F.,{aRotina})
		If ValType(aRet) == 'A'
			aRotina	:= aClone(aRet)
		EndIf
	EndIf

Return aRotina

/*/{Protheus.doc} AGR601MANU
Habilita edição do fardão, bloque acesso pelo cadatro de regras
@param: Nil
@author: Maicol Lange
@since: 31/10/2014
@Uso: AGRA601
/*/
Function AGR601MANU()
	Private CCADASTRO := ARGSX2NOME("DXL")
	dbSelectArea("DXL")
	AxAltera("DXL",Recno(),4)	
Return

/*/{Protheus.doc} AGR601ALT
Habilita edição do fardão, bloque acesso pelo cadatro de regras
@param: Nil
@author: Maicol Lange
@since: 31/10/2014
@Uso: AGRA601
/*/	
Function AGR601ALT()
	FWExecView(ARGSX2NOME("DXL"), 'AGRA601', MODEL_OPERATION_UPDATE)
Return

//-----------------------------------------------------------
/*/{Protheus.doc} A601VLDACT
Validação a inicialização do modelo de dados

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Static Function A601VLDACT(oModel)
	Local lRet 		:= .T.
	Local nAcao		:= oModel:GetOperation()

	If !IsIncallStack("AGR601ALT") .And. !IsInCallStack('AGRA620') .And. !IsInCallStack('AGRA610') .And. !IsInCallStack('AGRA615') .And. !IsInCallStack('AX520APFar') .And. !IsInCallStack('AGRA620EA')
		If nAcao == 4 .Or. nAcao == 5
			If DXL->DXL_STATUS <> "1"
				Help('',1,STR0014,,STR0016,1) //"ATENCAO"###""O regisro deste fardão já sofreu movimentações e não pode ser manipulado."
				lRet := .F.
			EndIf
		EndIf
	endif
Return(lRet)

/** -----------------------------------------------------------
{Protheus.doc} A601ACTIVE
Validação a ativação do modelo de dados

@param: Nil
@author: Aecio Ferreira Gomes
@since: 19/03/2013
@Uso: AGRA601
----------------------------------------------------------- **/
Static Function A601ACTIVE(oModel)
	Local aArea			:= GetArea()
	Local lRet			:= .T.
	Local lResult       := .F.

	Pergunte('AGRA60101',.F.)
	
	If FindFunction("AGRIsRest")
	   lResult := AGRIsRest()
	EndIf
	//Quando se vem de uma Requisição REST, todos os cmapos seguintes já vem com valor.
	If oModel:GetOperation() == MODEL_OPERATION_INSERT .AND. .Not. lResult

		If !Empty(MV_PAR01)
			FwFldPut( 'DXL_SAFRA' 		, MV_PAR01 ) // Safra
		EndIf
	
		if _lNovSafra
			If !Empty(MV_PAR02)
				FwFldPut( 'DXL_CODPRO'		, MV_PAR02 ) // Produto
			EndIf
			If !Empty(MV_PAR03)
				FwFldPut( 'DXL_PRDTOR'		, MV_PAR03 ) // Entidade
			EndIf
			If !Empty(MV_PAR04)
				FwFldPut( 'DXL_LJPRO' 		, MV_PAR04 ) // Loja
			EndIf
			If !Empty(MV_PAR05)
				FwFldPut( 'DXL_FAZ'   		, MV_PAR05 ) // Fazenda
			EndIf
			If !Empty(MV_PAR06)
				oModel:GetModel( 'DXLMASTER' ):LoadValue("DXL_TALHAO"		, MV_PAR06) // Talhão
			EndIf
			If !Empty(MV_PAR07)
				oModel:GetModel( 'DXLMASTER' ):LoadValue('DXL_CODVAR'   	, MV_PAR07 ) // Variedade
			EndIf
			If !Empty(MV_PAR08)
				FwFldPut( 'DXL_LOCAL'   	, MV_PAR08 ) // Local
			EndIf
			If !Empty(MV_PAR09)
				FwFldPut( 'DXL_BORDA'   	,  ALLTRIM(STR(MV_PAR09)) ) // Bordadura
			EndIf
			If !Empty(MV_PAR10)
				FwFldPut( 'DXL_TPRENS'   	,  ALLTRIM(STR(MV_PAR10)) ) // Tipo de prensagem
			EndIf
			If !Empty(MV_PAR11)
				FwFldPut( 'DXL_PSESTI'   	, MV_PAR11 ) // Peso Estimado
			EndIf
			If !Empty(MV_PAR12)
				FwFldPut( 'DXL_RDMTOP'   	, MV_PAR12 ) // Rendimento Previsto
			EndIf
			If !Empty(MV_PAR13)
				FwFldPut( 'DXL_OBS'   		, MV_PAR13 ) // Obs
			EndIf		
		else
			If !Empty(MV_PAR02)
				FwFldPut( 'DXL_PRDTOR'		, MV_PAR02 ) // Produtor
			EndIf
			If !Empty(MV_PAR03)
				FwFldPut( 'DXL_LJPRO' 		, MV_PAR03 ) // Loja
			EndIf
			If !Empty(MV_PAR04)
				FwFldPut( 'DXL_FAZ'   		, MV_PAR04 ) // Fazenda
			EndIf
			If !Empty(MV_PAR05)
				FwFldPut( 'DXL_TALHAO'   	, MV_PAR05 ) // Talhão
			EndIf
			If !Empty(MV_PAR06)
				FwFldPut( 'DXL_CODVAR'   	, MV_PAR06 ) // Variedade
			EndIf
			If !Empty(MV_PAR07)
				FwFldPut( 'DXL_LOCAL'   	, MV_PAR07 ) // Local
			EndIf
			If !Empty(MV_PAR08)
				FwFldPut( 'DXL_BORDA'   	,  ALLTRIM(STR(MV_PAR08)) ) // Bordadura
			EndIf
			If !Empty(MV_PAR09)
				FwFldPut( 'DXL_TPRENS'   	,  ALLTRIM(STR(MV_PAR09)) ) // Tipo de prensagem
			EndIf
			If !Empty(MV_PAR10)
				FwFldPut( 'DXL_PSESTI'   	, MV_PAR10 ) // Peso Estimado
			EndIf
			If !Empty(MV_PAR11)
				FwFldPut( 'DXL_RDMTOP'   	, MV_PAR11 ) // Rendimento Previsto
			EndIf
			If !Empty(MV_PAR12)
				FwFldPut( 'DXL_OBS'   		, MV_PAR12 ) // Obs
			EndIf
		endIf
	EndIf

	RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} AGRA601FLT
Filtro para a consulta padrao DXL

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: SIGAAGR
/*/
//-----------------------------------------------------------
Function AGRA601FLT()

	If IsInCallStack('AGRA600') // Romaneio de entrada
		if !__lRomUnif
			If !Empty(DXL->DXL_CODROM) .OR. DXL->(DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ) <> M->(DXM_SAFRA+DXM_PRDTOR+DXM_LJPRO+DXM_FAZ)	
				Return(.F.)
			EndIf
		else
			If !Empty(DXL->DXL_CODROM) .OR. DXL->(DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ) <> M->(NJJ_CODSAF+NJJ_CODENT+NJJ_LOJENT+NJJ_FAZ)	
				Return(.F.)
			EndIf
		endIf	
	ElseIf IsInCallStack('AGRA615') // Beneficiamento
		If Type('cSafra')    == 'U' .Or.;
		   Type('cProdutor') == 'U' .Or. ;
		   Type('cCodFaz')   == 'U' .Or.;
		   Type('cLJPro')    == 'U' .Or.;
		   Type('cCodVar')   == 'U'
			
			Return(.F.)
		EndIf
		If !(DXL->DXL_STATUS $ '3|4') .or. DXL->DXL_PSLIQU <= 0; //"Disponivel|Em Beneficiamento"
		.or. Alltrim(cSafra)+Alltrim(cProdutor)+Alltrim(cLjPro)+Alltrim(cCodFaz) <> ;
		Alltrim(DXL->DXL_SAFRA)+Alltrim(DXL->DXL_PRDTOR)+Alltrim(DXL->DXL_LJPRO)+Alltrim(DXL->DXL_FAZ);
		.or. (!Empty(cCodVar) .And. !Alltrim(cCodVar) == DXL->DXL_CODVAR)
			Return(.F.)
		EndIf
	EndIf
Return( .T. )

//-----------------------------------------------------------
/*/{Protheus.doc} UBANNVFil
Filtro da consulta padrão NNVUBA

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: SIGAAGR
/*/
//-----------------------------------------------------------
Function UBANNVFil()
	Local lRet := .T.

	If IsIncallStack('AGRA601')
		If !M->DXL_CODPRO == NNV->NNV_CODPRO
			lRet := .F.
		EndIf
	ElseIf IsIncallStack('AGRA615')

		If lRet .And. Type('cSafra') == 'U'
			lRet := .F.
		EndIf

		If _lNovSafra
			If !(cCodProdut == NNV->NNV_CODPRO)
				lRet := .F.
			EndIf		
		else
			NN1->(dbSetOrder(1))
			lRet := NN1->(dbSeek(xFilial('NN1')+cSafra))
			If lRet .And. !(NN1->NN1_CODPRO == NNV->NNV_CODPRO)
				lRet := .F.
			EndIf
		endIf
	EndIf

Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} AGRA601KEY
Valida o registro

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Function AGRA601KEY()
Return(ExistChav('DXL',M->(DXL_CODIGO+DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ)))

//-----------------------------------------------------------
/*/{Protheus.doc} AGRA601FAZ
Faz Valida a fazenda 

@param: Nil
@author: Aecio Ferreira Gomes
@since: 08/11/2012
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Function AGRA601FAZ()
	Local aArea := GetArea()
	Local lRet := .T.

	dbSelectArea('NN2')
	dbSetOrder(3)

	If !dbSeek(xFilial('NN2')+M->(DXL_PRDTOR+DXL_LJPRO+DXL_FAZ))
		Help(" ",1,"AGR601FAZ",,CHR(13)+STR0047,3,0)
		lRet := .F.
	EndIf

	RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} AGRA601NN4
Valida variedade
@param: Nil
@author: Maicol Lange
@since: 27/07/2015
@Uso: AGRA601
/*/
//-----------------------------------------------------------
Function AGRA601NN4()
	Local aArea := GetArea()
	Local lRet := .T.
	
	If _lNovSafra
		IF empty(mv_par06)
			lRet := VAZIO().OR. ExistCPO("NNV",mv_par07,2)
		Else 
			lRet := VAZIO().OR. ExistCPO("NNV",mv_par07,2).AND. ExistCPO("NN4",mv_par01+mv_par05+mv_par06+mv_par07,2)
		EndIf		
	else
		IF empty(mv_par05)
			lRet := VAZIO().OR. ExistCPO("NNV",mv_par06,2)
		Else 
			lRet := VAZIO().OR. ExistCPO("NNV",mv_par06,2).AND. ExistCPO("NN4",mv_par01+mv_par04+mv_par05+mv_par06,2)
		EndIf
	endIF
	
	RestArea(aArea)
Return(lRet)


/*/{Protheus.doc} AGRA601NN3
Valida talhão
@author silvana.torres
@since 15/01/2018
@version undefined

@type function
/*/
Function AGRA601NN3()
	Local aArea := GetArea()	
	Local lRet := .T.
	
	If _lNovSafra
		IF empty(mv_par02)
			lRet := VAZIO().OR. EXISTCPO("NN3",mv_par01+mv_par05+mv_par06,1)    
		Else 
			lRet := VAZIO().OR. EXISTCPO("NN3",mv_par01+mv_par05+mv_par02+mv_par06,3) /*safra+fazenda+produto+talhao*/
		EndIf		
	else
		lRet := VAZIO().OR. EXISTCPO("NN3",mv_par01+mv_par04+mv_par05,1)    
	endIF

	RestArea(aArea)
Return(lRet)

/*/{Protheus.doc} A601Produ	
@author joaquim.burjack
@since 11/04/2016
@version undefined
@param cFardao, characters, descricao
@type function
/*/
Static Function A601Produ(cProduto,cLocal,nQuant,cNumOP,cFardao,cSafra,cPrdtor,cLjpro,cFaz,cLoteCtl)
	Local aArea 		:= GetArea()
	Local aApont      	:= {}
	Local cTM        	:= SuperGetMV('MV_AGRTMPR',.F.,'')
	Local nModuloOld  	:= nModulo
	Local cNumDoc	    := ''
	Local nQtdGanho     := 0
	Local nQtdMaior     := 0	
	Local lRet          := .T.
	Local cD3_CC        := ''
	Private lMSErroAuto := .F.
	Private lMSHelpAuto := .T.
			
	//-----------------------------
	// Salva as Variaveis publicas
	//-----------------------------
	SaveInter()
	//-----------------------
	// Seta modulo para PCP  e coleta número a ser utilizado
	//-----------------------
	
	Begin Transaction 
		nModulo := 10
		If Empty(cNumOP)
			cNumOP := A601GERAOP( cProduto, cLocal, nQuant )		
		EndIf
	
		If !Empty(cNumOP)
		
			If Empty(cNumDoc)
				cNumDoc   := NextNumDoc()
			Endif
			
			Processa ( {|| lRet := A601Maior(cNumOP, nQuant, @nQtdGanho, @nQtdMaior)}, STR0055 /*"Gerando produção de fardão"*/, STR0085/*"Validando existência ganho de quantidade para a ordem"*/ )
			
			If lRet
				//ponto de entrada para manipular o  centro de custo 
				If ExistBlock("A601ProPE")
					cD3_CC := ExecBlock("A601ProPE",.F.,.F.)
				EndIf	
				//---------------------------------
				// Posiciona no codigo do produto
				//---------------------------------
				Posicione('SB1',1,xFilial('SB1')+cProduto,'B1_COD')
				//-------------------------------
				// Adiciona os dados em um vetor
				//-------------------------------
				AADD(aApont, {'D3_TM'     , cTM			,Nil})
				AADD(aApont, {'D3_COD'    , SB1->B1_COD	,Nil})
				AADD(aApont, {'D3_UM'     , SB1->B1_UM	,Nil})
				AADD(aApont, {'D3_LOCAL'  , cLocal		,Nil})
				AADD(aApont, {'D3_QUANT'  , nQuant		,Nil})
				AADD(aApont, {'D3_OP'     , cNumOP		,Nil})
				AADD(aApont, {'D3_DOC'    , cNumDoc     ,Nil})
				AADD(aApont, {'AUTPRTOTAL', 'S'			,Nil})
				AADD(aApont, {'D3_EMISSAO', dDataBase	,Nil})
				If __lnewComerc .AND. !EMPTY(cLoteCtl)
					AADD(aApont, {'D3_LOTECTL', cLoteCtl	,Nil})
				EndIf
				If nQtdGanho > 0
					AADD(aApont, {'D3_QTGANHO', nQtdGanho, Nil})
				Endif
				If !Empty(cD3_CC) .AND. ValType(cD3_CC) == "C"
					Aadd(aApont, {"D3_CC"     , cD3_CC	,Nil})				
				EndIf				
				If nQtdMaior > 0
					AADD(aApont, {'D3_QTMAIOR', nQtdMaior, Nil})
				Endif
				//-----------------------------
				// Executa rotina a automatica
				//-----------------------------
				Processa( {|| MsExecAuto( { |x,y| MATA250(x,y)},aApont, 3 )}, STR0055 /*"Gerando produção de fardão"*/, STR0086/*"Apontando produção para o fardão"*/)
				 // 3=Inclusao
				
				If lMsErroAuto 
					If  !FwIsInCallStack("AGRA601_02")
						MostraErro()
					EndIF
					RollBackSx8()
					DisarmTrans()
				Else
					dbSelectArea('SD3')
					dbSetOrder(2)
					dbSeek(FwXFilial('SD3')+PADR(cNumDoc,TamSX3('D3_DOC')[1],' ')+;
											PADR(cProduto,TamSX3('D3_COD')[1],' '))
				
					//Grava tabela de relacionamentos - DXB
					Processa ( {|| AGR605GRAVA() }, STR0055 /*"Gerando produção de fardão"*/, STR0087/*"Gravando rastro de produção para o fardão"*/)			
				EndIf
			Else
				lMsErroAuto := .T.
				DisarmTrans()			
			Endif	
		Else
			lMsErroAuto := .T.
			DisarmTrans()
		EndIf
	End Transaction

	nModulo := nModuloOld

	RestInter() // Restaura as variaveis publicas
	RestArea(aArea)
Return(!lMsErroAuto)

/*/{Protheus.doc} PreMdl
Função chamada antes de commitar o modelo
@author silvana.torres
@since 04/04/2018
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function PreMdl(oModel)
	Local lRetorno	:= .T.
	Local nOperac	:= oModel:GetOperation()
	
	If DXL->(ColumnPos("DXL_CODUNI")) > 0
	
		If nOperac == MODEL_OPERATION_INSERT .and. .NOT. Empty(M->DXL_CODIGO) .and. .NOT. Empty(M->DXL_SAFRA) .and.;
		   .NOT. Empty(M->DXL_PRDTOR) .and. .NOT. Empty(M->DXL_LJPRO) .and. .NOT. Empty(M->DXL_FAZ)
			//Grava código único no fardão
			oModel:LoadValue('DXLMASTER','DXL_CODUNI', AGRCdgFrd( M->DXL_CODIGO, M->DXL_SAFRA, M->DXL_PRDTOR, M->DXL_LJPRO, M->DXL_FAZ))
		EndIf
	EndIf
						  
Return lRetorno


/*/{Protheus.doc} sfPost
-- Função chamada depois de commitar o modelo

@author ana.olegini
@since 	16/04/2018
@param 	oModel, 	object, Modelo de dados 
@return lRetorno, 	logico,	retorno .t. ou .f.
/*/
Static Function sfPost(oModel)
	Local lRetorno	:= .T.
	Local nOperac	:= oModel:GetOperation()
	Local oDXL		:= oModel:GetModel():GetModel( "DXLMASTER" )
	Local cProduto	:= oDXL:GetValue( "DXL_CODPRO" )
	Local cLote		:= ''
	
	If __lnewComerc .and. __MVAGRPRFA 

		cLote:= oDXL:GetValue( "DXL_LOTCTL" )
		
		If nOperac == MODEL_OPERATION_INSERT  
			If Rastro(cProduto) .And. Empty(cLote) 
				//"Produto possui rastro por lote. Favor informar lote pra este produto!"
				Help ('',1, '.AGRA60100001.')
				lRetorno := .F.
			EndIf 
		EndIf

	EndIf

Return lRetorno


/*/{Protheus.doc} A601GRV
Gravação do Modelo
@author joaquim.burjack
@since 13/04/2016
@version undefined
@type function
/*/
Static Function A601GRV(oModel)
	Local lRet      := .T.
	Local oFieldDXL := oModel:GetModel("DXLMASTER")
	Local nOperac	:= oModel:GetOperation()
	Local cDoc      := ""
	Local cOP       := ""
	Local oMdDXB    := FwLoadModel('AGRA605')	
	Local aArea     := GetArea()
	Local cAQry     := GetNextAlias()
	
	Pergunte('AGRA60102', .F.)
			
	/*---------------------------------------------
	 * Importante: caso esteja configurado a 
	 * geração de produção no fardão e o processo 
	 * apresentar problema, toda a transação deve 
	 * ser desfeita
	 *--------------------------------------------*/		
	Begin Transaction EXTENDED	
		If nOperac == MODEL_OPERATION_INSERT  
			If __MVAGRPRFA .And. MV_PAR01 = 1 //Gera Producao 
				DbSelectArea("DXB")
				DXB->(DbSetOrder(1))
				If	!DXB->(MsSeek(FwXFilial('DXB')+M->DXL_CODIGO+M->DXL_SAFRA+M->DXL_PRDTOR+M->DXL_LJPRO+M->DXL_FAZ+"AGRA601"))
									
					cOP := oFieldDXL:GetValue("DXL_OP")
					If __lnewComerc //Proteção
						Processa( {|| lRet := A601Produ(M->DXL_CODPRO,M->DXL_LOCAL,M->DXL_PSESTI,If(!Empty(cOP), cOP,""),;
														M->DXL_CODIGO,M->DXL_SAFRA,M->DXL_PRDTOR,M->DXL_LJPRO,M->DXL_FAZ, M->DXL_LOTCTL)},;
														STR0055 /*"Gerando produção de fardão"*/, STR0056 /*"Apontamento de produção"*/ )
	 	        	else
						Processa( {|| lRet := A601Produ(M->DXL_CODPRO,M->DXL_LOCAL,M->DXL_PSESTI,If(!Empty(cOP), cOP,""),;
									 	            	M->DXL_CODIGO,M->DXL_SAFRA,M->DXL_PRDTOR,M->DXL_LJPRO,M->DXL_FAZ)},;
									 	            	STR0055 /*"Gerando produção de fardão"*/, STR0056 /*"Apontamento de produção"*/ )
					EndIf
				 Else
					oModel:SetErrorMessage( , , , , , STR0076 /*"Já existe apontamento para este fardão"*/)
					lRet := .F.		
				Endif	
				DXB->(dbCloseArea())	
			End			
		ElseIf nOperac == MODEL_OPERATION_DELETE

			If __MVAGRPRFA 
			
				//Valida se a exclusão  pode ser efetuada
				BeginSql Alias cAQry
				Select DXB_FILIAL From %Table:DXB% 
			 	Where %notDel%						AND
			 		DXB_SAFRA   = %exp:DXL_SAFRA%	AND
			 		DXB_PRDTOR  = %exp:DXL_PRDTOR%  AND
			 		DXB_LJPRO   = %exp:DXL_LJPRO%   AND
			 		DXB_FAZ 	= %exp:DXL_FAZ%     AND
			 		DXB_FARDAO  = %exp:DXL_CODIGO%
			 	EndSQL
			 			 	
			 	dbSelectArea(cAQry)
			 	
			 	(cAQry)->(dbGoTop()) 	
			 	If !(cAQry)->(Eof())
			 		if (FWCodFil()!= (cAQry)->DXB_FILIAL)			 			
			 			oModel:SetErrorMessage( , , , , , /*"Não é possivel excluir esse apontamendo pois ele pertence à Filial:"*/ +; 
			 								   STR0075+(cAQry)->DXB_FILIAL+" - "+FWFilialName(,(cAQry)->DXB_FILIAL))
			 			(cAQry)->(dbCloseArea())
			 			RestArea(aArea)
			 			lRet := .F.
			 		endif
			 	Endif
			 	
			 	If lRet
			 	
					//DXB_FILIAL+DXB_FARDAO+DXB_SAFRA+DXB_PRDTOR+DXB_LJPRO+DXB_FAZ+DXB_ROTINA
					cDoc := Posicione('DXB',1,FwXFilial('DXB')+DXL->DXL_CODIGO+DXL->DXL_SAFRA+DXL->DXL_PRDTOR+DXL->DXL_LJPRO+DXL->DXL_FAZ+"AGRA601",'DXB_DOC')	
					cOP  := Posicione('DXB',1,FwXFilial('DXB')+DXL->DXL_CODIGO+DXL->DXL_SAFRA+DXL->DXL_PRDTOR+DXL->DXL_LJPRO+DXL->DXL_FAZ+"AGRA601",'DXB_OP')
					
					//Posiciona nos movimentos relacionados a OP
					If !Empty(cDoc) 
						DbSelectArea("SD3")
						DbSetOrder(2)
						If	DbSeek(Xfilial("SD3")+cDoc+oFieldDXL:GetValue("DXL_CODPRO"))
		
							If !AGRDTFECHAEST(SD3->D3_EMISSAO, .T. )
								Help ('',1, 'FECHTO')
								lRet := .F.	
							EndIf
						End	
		
						If lRet
						 	Processa( {|| lRet := AGR601REOP( cOP, oFieldDXL:GetValue("DXL_CODPRO"), cDoc, Iif( MV_PAR02 = 1, .t., .f. ) ) }, STR0082/*"Excluindo fardão"*/, STR0083/*"Reabrindo produção para o fardão"*/ )
							
							If lRet
								dbSelectArea('DXB')
								dbSetOrder(1)
								If MsSeek(FwXFilial('DXB')+DXL->DXL_CODIGO+DXL->DXL_SAFRA+DXL->DXL_PRDTOR+DXL->DXL_LJPRO+DXL->DXL_FAZ+"AGRA601")
									oMdDXB:SetOperation(5)
									oMdDXB:Activate()
									
									If(lRet := oMdDXB:VldData())
										lRet := oMdDXB:CommitData()
									Else
										oMdDXB:SetErrorMessage( , , , , , oModel:GetErrorMessage()[6])
									Endif
								Endif	
							Endif						
						Endif
					EndIf
				Endif
			Endif
		Endif
	
		
			If lRet
				If __lnewComerc
					//--Salva o lote - sublote - endereço
					DbSelectArea("DXB")
					DXB->(DbSetOrder(1))
					If DXB->(MsSeek(FwXFilial('DXB')+M->DXL_CODIGO+M->DXL_SAFRA+M->DXL_PRDTOR+M->DXL_LJPRO+M->DXL_FAZ+"AGRA601"))
						oFieldDXL:LoadValue("DXL_LOTCTL"	, DXB->DXB_LOTCTL)
						oFieldDXL:LoadValue("DXL_NMLOT"		, DXB->DXB_NMLOT )
						oFieldDXL:LoadValue("DXL_LOCLIZ"	, DXB->DXB_LOCLIZ)
					EndIf
				EndIf 
				
				lRet := FWFormCommit(oModel)
			Else
				DisarmTransaction()	
			Endif
		
	End Transaction EXTENDED
	 
Return lRet

/*/{Protheus.doc} AGR601REOP
Remove Ordem de Produção do Fardão
@author bruna.rocio
@since 08/04/2016
@version undefined
@type function
/*/
Function AGR601REOP( cOP, cProd, cDoc, lIniciada )
	Local aArea     := GetArea()
	Local lRetorno  := .T.
	Local lOpOk     := .F.
	Local lExcluiOP := .F.
	Local cItemOP   := ""
	Local cSeqOp    := ""
	Local cBatRot   := ""
	Local cNumAx    := SubStr(cOP,1,len(SC2->C2_NUM))
	Local dDataFe   
	Local nx
	Local aApont    := {}
	Local aVetor    := {}

	Private lMsErroAuto := .f.
	Private lMSHelpAuto	:= .T.

	Begin Transaction
		// Reabre a OP
		lOpOk := .f.
		DbselectArea("SC2")
		DBClearFilter()
		If AGRIFDBSEEK("SC2",cNumAx+'01'+cProd,9,.f.)
			AGRTRAVAREG("SC2")
			dDataFe       := SC2->C2_DATRF
			SC2->C2_DATRF := AGRINICIAVAR("C2_DATRF")
			AGRDESTRAREG("SC2")

			lOpOk := .t.
		EndIf

		vVetRD3PR := {} //Informações de Produção
		vVetSD3PE := {} //Informações de Perda
		vVetRD3RE := {} //Informações de Requisição

		//Posiciona nos movimentos relacionados a OP 
		DbSelectArea("SD3")
		dbSetOrder(2)
		dbSeek(FwXFilial('SD3')+PADR(cDoc,TamSX3('D3_DOC')[1],' ')+;
								PADR(cProd,TamSX3('D3_COD')[1],' '))
		

		// Pesquisa e armazena movimentações de requisição e produção da ordem de produção
		While !Eof() .And. SD3->(D3_FILIAL+D3_DOC+D3_COD) = xFilial("SD3")+cDoc+cProd 

			If Substr(SD3->D3_CF,1,2) = "PR" .And. SD3->D3_ESTORNO <> 'S' 
				Aadd(vVetRD3PR,Recno())
			EndIf
			DbSkip()
		End

		// Estorna a produção	
		For nx := 1 To Len(vVetRD3PR)
			DbSelectArea("SD3")
			Dbgoto(vVetRD3PR[nx])

			Apont := {}
			lMsErroAuto := .F.
			Aadd(aApont,{"D3_DOC"	 ,SD3->D3_DOC		,Nil})
			Aadd(aApont,{"D3_OP"	 ,SD3->D3_OP		,Nil})
			Aadd(aApont,{"D3_COD"    ,SD3->D3_COD		,Nil})
			Aadd(aApont,{"D3_UM"     ,SD3->D3_UM		,Nil})
			Aadd(aApont,{"D3_QUANT"  ,SD3->D3_QUANT		,Nil}) 
			Aadd(aApont,{"D3_LOCAL"  ,SD3->D3_LOCAL		,Nil})
			Aadd(aApont,{"D3_CC"     ,SD3->D3_CC		,Nil})
			Aadd(aApont,{"D3_EMISSAO",SD3->D3_EMISSAO	,Nil}) 
			Aadd(aApont,{"D3_LOTECTL",SD3->D3_LOTECTL	,Nil})
			Aadd(aApont,{"D3_DTVALID",SD3->D3_DTVALID	,Nil}) 
			Aadd(aApont,{"D3_NUMSEQ" ,SD3->D3_NUMSEQ    ,Nil})
			Aadd(aApont,{"D3_CHAVE"	 ,SD3->D3_CHAVE		,Nil})
			If __lnewComerc
				Aadd(aApont,{'D3_LOTECTL',SD3->D3_LOTECTL	,Nil})
			EndIf
			Aadd(aApont,{"D3_CF"	 ,"PR0"				,Nil})
			aAdd(aApont,{"INDEX"     , 4                ,Nil})

			lMsErroAuto := .F.
			Processa({||MsExecAuto({|x,y| MATA250(x,y)},aApont,5)},STR0080,STR0079) //"Aguarde"##"Excluindo apontamento de produção"

			If lMsErroAuto .AND. !__lAutomato
				MostraErro()
				lRetorno := .F.
				DisarmTransaction()
				Break
			EndIf
			AGRQUEBRAFIL("SF5")
		Next nx

		// Refaz o tratamento da OP
		DbselectArea("SC2")
		DBClearFilter()
		If AGRIFDBSEEK("SC2",cNumAx+'01'+cProd,9,.f.)
			AGRTRAVAREG("SC2")
			If lIniciada
				SC2->C2_DATRF := If(SC2->C2_QUANT - SC2->C2_QUJE > 0,Ctod(''),dDataFe)
			Else
				SC2->C2_DATRF := If(SC2->C2_QUJE > 0,dDataFe,Ctod(''))
			Endif
			SC2->C2_QUJE  := If(SC2->C2_QUJE < 0,0,SC2->C2_QUJE)
			cItemOP       := SC2->C2_ITEM
			cSeqOP        := SC2->C2_SEQUEN
			cBatRot       := SC2->C2_BATROT
			AGRDESTRAREG("SC2")

			lExcluiOP := .F.
			If A650DefLeg(2)
				lExcluiOP := .T.
			Endif
		EndIf

		If lExcluiOP .And. (cBatRot <> "MATA650")
			AADD(aVetor,{'C2_NUM' 		, cNumAx , NIL}) //Numero da OP
			AADD(aVetor,{'C2_ITEM'		, cItemOP, NIL}) //Item da OP
			AADD(aVetor,{'C2_SEQUEN'	, cSeqOP , NIL}) //Sequencia da OP

			//-----------------------------
			// Executa rotina a automatica
			//-----------------------------
			Processa( {||MSExecAuto({|x,y| MATA650(x,y)},aVetor, 5)},STR0080,STR0081) //"Aguarde"##"Excluindo ordem de produção"

			If lMSErroAuto .AND. !__lAutomato
				MostraErro()
				lRetorno := .F.
				DisarmTransaction()
				Break
			EndIf

		Endif
	End Transaction

	RestArea(aArea)
Return lRetorno

/*/{Protheus.doc} CriaTlProF
@author bruna.rocio
@since 21/04/2016
@version undefined

@type function
/*/
Static Function CriaTlProF()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPnDown   := Nil
	Local oSize     := Nil
	Local oDXL_OP   := Nil
	Local oBrwMrk := Nil

	cDXL_OP := If( !Empty(AGRA601PE()), AGRA601PE(), Space(TamSX3("D3_OP")[01]))
	
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0054 /* 'Gerar produção de fardão' */ , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .f., .t. )

	oFWLayer:AddLine( 'UP', 8, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .F., 'UP' )
	oPnTOP := oFWLayer:GetColPanel( 'ALL', 'UP' )

	oFWLayer:AddLine( 'DOWN', 85, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .F., 'DOWN' )
	oPnDown := oFWLayer:GetColPanel( 'ALL', 'DOWN' )

	@ 08,008  Say STR0053 Of oPnTOP COLOR CLR_BLACK Pixel //"Ordem de produção: "
	@ 15,008 MSGET oDXL_OP  Var cDXL_OP Size 100,09  Picture X3Picture("D3_OP") F3 "SC2"  Of oPnTOP  Pixel When .T. Pixel  

	oBrwMrk:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	oBrwMrk:SetDescription(STR0054 /* Gerar produção de fardão */ ) // Define o titulo do MarkBrowse
	oBrwMrk:SetOwner(oPnDown)
	oBrwMrk:SetFilterDefault("@"+FiltraMark())
	oBrwMrk:SetAlias("DXL") 
	oBrwMrk:SetFieldMark("DXL_OK")	// Define o campo utilizado para a marcacao
	oBrwMrk:SetUseFilter(.F.)		
	oBrwMrk:SetSemaphore(.F.)	// Define se utiliza marcacao exclusiva
	oBrwMrk:DisableReport()	// Desabilita a opcao de imprimir
	oBrwMrk:SetMenuDef("")	// Desabilita a opcao de imprimir	    
	oBrwMrk:AddButton(STR0077 /*"Gerar Produção"*/, {||GeraProFardao( oBrwMrk )})
	oBrwMrk:AddButton(STR0078 /*"Sair"*/, {||oDlg:End()})
	oBrwMrk:Activate(oPnDown)	// Ativa o MarkBrowse
	
	oDlg:Activate( , , , .t., { || .t. }, , )
	
	RestArea(aArea)
Return .T.

/*/{Protheus.doc} FiltraMark
Busca os fardões que não foram gerados ordem de produção
@author maicol.lange
@since 14/04/2016
@version undefined
@type function
/*/
Static Function FiltraMark() 
	Local  cQuery := ""
	
	if !__lRomUnif
		cQuery :=  "NOT EXISTS ( "+;	
		"SELECT DX0_FARDAO "+; 
		"FROM "+RetSqlName('DX0')+" DX0 "+;  
		"INNER JOIN  "+RetSqlName('DXM')+" DXM on   "+;
		"DXM.DXM_FILIAL = '"+ FwxFilial("DXM")+"' AND "+;  
		"DXM.DXM_CODIGO  = DX0.DX0_CODROM AND  "+;
		"DXM.D_E_L_E_T_ = ' ' "+;
		"WHERE "+;	
		"DX0.D_E_L_E_T_ = ' ' AND "+;
		"DX0.DX0_FILIAL = '"+ FwxFilial("DX0")+"' AND "+;  
		"DXM.DXM_OP <> ' '	AND "+;	
		"DXM.DXM_SAFRA  = 	DXL_SAFRA AND "+;
		"DXM.DXM_PRDTOR =	DXL_PRDTOR AND "+;
		"DXM.DXM_LJPRO  =	DXL_LJPRO AND "+;
		"DXM.DXM_FAZ	=	DXL_FAZ  AND "+;
		"DX0_FARDAO	=	DXL_CODIGO) "+; 			
		"AND NOT EXISTS "+;
		"( SELECT DXB_FARDAO "+; 
		"FROM "+ RetSqlName('DXB')+ " DXB "+; 
		"WHERE  DXB.D_E_L_E_T_ = ' ' AND "+; 
		"DXB.DXB_FILIAL =	'"+ FwxFilial("DXB")+"' AND "+;
		"DXB.DXB_SAFRA  = 	DXL_SAFRA AND "+;
		"DXB.DXB_PRDTOR =	DXL_PRDTOR AND "+;
		"DXB.DXB_LJPRO  =	DXL_LJPRO AND "+;
		"DXB.DXB_FAZ	=	DXL_FAZ  AND "+;
		"DXB_FARDAO	=	DXL_CODIGO) "
	else
		cQuery :=  "NOT EXISTS ( "+;	
		"SELECT DX0_FARDAO "+; 
		"FROM "+RetSqlName('DX0')+" DX0 "+;  
		"INNER JOIN  "+RetSqlName('NJJ')+" NJJ on   "+;
		"NJJ.NJJ_FILIAL = '"+ FwxFilial("NJJ")+"' AND "+;  
		"NJJ.NJJ_CODROM  = DX0.DX0_CODROM AND  "+;
		"NJJ.D_E_L_E_T_ = ' ' "+;
		"WHERE "+;	
		"DX0.D_E_L_E_T_ = ' ' AND "+;
		"DX0.DX0_FILIAL = '"+ FwxFilial("DX0")+"' AND "+;  
		"NJJ.NJJ_NUMOP <> ' '	AND "+;	
		"NJJ.NJJ_CODSAF = 	DXL_SAFRA AND "+;
		"NJJ.NJJ_CODENT =	DXL_PRDTOR AND "+;
		"NJJ.NJJ_LOJENT =	DXL_LJPRO AND "+;
		"NJJ.NJJ_FAZ	=	DXL_FAZ  AND "+;
		"DX0_FARDAO	=	DXL_CODIGO) "+; 			
		"AND NOT EXISTS "+;
		"( SELECT DXB_FARDAO "+; 
		"FROM "+ RetSqlName('DXB')+ " DXB "+; 
		"WHERE  DXB.D_E_L_E_T_ = ' ' AND "+; 
		"DXB.DXB_FILIAL =	'"+ FwxFilial("DXB")+"' AND "+;
		"DXB.DXB_SAFRA  = 	DXL_SAFRA AND "+;
		"DXB.DXB_PRDTOR =	DXL_PRDTOR AND "+;
		"DXB.DXB_LJPRO  =	DXL_LJPRO AND "+;
		"DXB.DXB_FAZ	=	DXL_FAZ  AND "+;
		"DXB_FARDAO	=	DXL_CODIGO) "
	endIf

Return cQuery

/*/{Protheus.doc} GeraProFardao
Busca os fardões  selecionados para gerar produção
@author maicol.lange
@since 14/04/2016
@version undefined
@type function
/*/
Static Function GeraProFardao( oBrwMrk )
	Local aArea    := GetArea()
	Local lRest    := .T.
	Local nQuant   := 0
	Local cProduto := ""
	Local cLocal   := ""	
	Local cNumOP   := ""
				
	DXL->( dbGotop() )
	While .Not. DXL->( Eof() )
			
		If oBrwMrk:IsMark()
			cProduto := DXL->DXL_CODPRO
			cLocal   := DXL->DXL_LOCAL
			nQuant   += DXL->DXL_PSESTI		
		Endif
		DXL->( dbSkip() )
	EndDo
		
	//Verifica se o campo de ordem de produção está preenchido, se não, abre uma nova ordem com a quantidade total dos fardões selecionados	
	If Empty(cDXL_OP)
		Processa( {|| cDXL_OP := A601GERAOP( cProduto, cLocal, nQuant ) },  STR0055 /*"Gerando produção de fardão"*/, STR0084/*"Abrindo Ordem de Produção"*/) 
	Else 
		cNumOP := cDXL_OP
	Endif
			
	If lRest .And. !Empty(cNumOP) .OR. .NOT. Empty(cDXL_OP)
		DXL->( dbGotop() )
		While .Not. DXL->( Eof() ) .and. lRest
	
			If oBrwMrk:IsMark()
				If lRest
					//Manda o registro do fardão para o cache
					RegToMemory('DXL',.f.,.f.)
						
					Processa( {|| lRest := A601Produ(M->DXL_CODPRO,M->DXL_LOCAL,M->DXL_PSESTI,If(!Empty(cDXL_OP), cDXL_OP,""),;
									                 M->DXL_CODIGO,M->DXL_SAFRA,M->DXL_PRDTOR,M->DXL_LJPRO,M->DXL_FAZ,IIF (__lnewComerc, M->DXL_LOTCTL, ""))},;
									                 STR0055 /*"Gerando produção de fardão"*/, STR0056 /*"Apontamento de produção"*/ )
					If __lnewComerc 
					//--Apos gerar as OPs e Apontamentos - atualiza tabela DXL.
						If lRest
							//--Salva o lote - sublote - endereço
							DbSelectArea("DXB")
							DXB->(DbSetOrder(1))
							If DXB->( MsSeek( FwXFilial('DXB') + DXL->DXL_CODIGO + DXL->DXL_SAFRA + DXL->DXL_PRDTOR + DXL->DXL_LJPRO + DXL->DXL_FAZ + "AGRA601") )
								dbSelectArea( "DXL" )
								If DXL->( RecLock( "DXL", .f. ) ) 
									DXL->( DXL_LOTCTL ) := DXB->DXB_LOTCTL
									DXL->( DXL_NMLOT  ) := DXB->DXB_NMLOT
									DXL->( DXL_LOCLIZ ) := DXB->DXB_LOCLIZ		
									DXL->( MSUnLock() )
								EndIf	
							EndIf
						EndIf
					EndIf
				Endif				 									
			Endif
			DXL->( dbSkip() )
		EndDo
	Endif
	
	oBrwMrk:Refresh(.T.)
		
	RestArea(aArea)
Return lRest


/*/{Protheus.doc} GetMovProducao
Busca os fardões  selecionados para gerar produção
@author maicol.lange
@since 15/04/2016
@version undefined
@type function
/*/
Static Function GetMovProducao()
	Local aArea := GetArea()
	Local oBrw
	Local cFiltro 	:= " "
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oPanel	:= Nil
	Local oSize     := Nil

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos
	
	oDlg := MSDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], STR0088 /* 'Histórico de Fardão' */ , , , , , CLR_BLACK, CLR_WHITE, , , .t. )
	
	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlg, .t.)

	oFWLayer:AddLine( 'UP', 90, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	
	oPanel := oFWLayer:GetColPanel( 'ALL', 'UP' )

	cFiltro := "DXB_FARDAO	= '"+ DXL->DXL_CODIGO +"' AND "+;	
			   "DXB_SAFRA   = '"+ DXL->DXL_SAFRA  +"' AND "+;
	           "DXB_PRDTOR	= '"+ DXL->DXL_PRDTOR +"' AND "+;
	           "DXB_LJPRO 	= '"+ DXL->DXL_LJPRO  +"' AND "+;
	           "DXB_FAZ	    = '"+ DXL->DXL_FAZ    +"'"	

	oBrw := FWMBrowse():New()
	oBrw:SetAlias("DXB")
	oBrw:SetDescription(STR0088)	//'Histórico de Fardão'
	oBrw:SetFilterDefault( '@' + cfiltro )
	oBrw:DisableDetails(.F.)
	oBrw:SetMenuDef("")
	oBrw:Activate(oPanel)
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},,) } )
	
	RestArea(aArea)
return

/*/{Protheus.doc} AGRA601PE
Gatilha PE para campo virtual de Ordem de produção
@author joaquim.burjack
@since 19/04/2016
@version undefined

@type function
/*/
Function AGRA601PE()
	Local cRet := ''
	/* Permite manipular variavel de gatilho do numero de OP a ser utilizado na produção */
	If ExistBlock('AGR601P1')
		cRet := ExecBlock('AGR601P1',.F.,.F.,)
	EndIf
return Iif (ValType(cRet) == 'C',cRet,nil)


/*/{Protheus.doc} A601GERAOP
@author bruna.rocio
@since 26/04/2016
@version undefined

@type function
/*/
Function A601GERAOP(cProduto, cLocal, nQuant)
	Local aArea  := GetArea()
	Local cNumOP := ""
	Local aOp    := {}
	
	Private lMsErroAuto := .F.

	Begin Transaction 
	
		cNumOP := GetSXENum('SC2','C2_NUM')
		SC2->(dbSetOrder(1))
		While SC2->(dbSeek(xFilial("SC2")+cNumOP))
			If ( __lSx8 )
				ConfirmSX8()
			EndIf
			cNumOP := GetSxENum("SC2","C2_NUM")
		EndDo
	
		//-------------------------------
		// Adiciona os dados em um vetor
		//-------------------------------
		AADD(aOp, {'C2_NUM'		, cNumOP 	,Nil})
		AADD(aOp, {'C2_ITEM'	, '01'		,Nil})
		AADD(aOp, {'C2_SEQUEN' 	, '001'		,Nil})
		AADD(aOp, {'C2_PRODUTO'	, cProduto	,Nil})
		AADD(aOp, {'C2_QUANT'  	, nQuant	,Nil})
		AADD(aOp, {'C2_LOCAL'  	, cLocal	,Nil})
		AADD(aOp, {'C2_DATPRI' 	, ddatabase	,Nil})
		AADD(aOp, {'C2_DATPRF' 	, ddatabase	,Nil})
		AADD(aOp, {'C2_EMISSAO'	, ddatabase	,Nil})
		AADD(aOp, {'C2_TPOP'  	, 'F'		,Nil})
		AADD(aOp, {'AUTEXPLODE'	, 'S'		,Nil})
	
		//-----------------------------
		// Executa a rotina automatica de Geração de OP
		//-----------------------------
		MSExecAuto({|x,y| mata650(x,y)},aOp, 3)
		cNumOP := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
		If !lMsErroAuto
			ConfirmSx8()
		Else
			If !__lAutomato
				MostraErro()
				DisarmTransaction()
			endif
		Endif	
	End Transaction
		
	RestArea(aArea)
Return cNumOP

/*/{Protheus.doc} NextNumDoc
Retorna o proximo numero de documento disponivel
@author joaquim.burjack
@since 02/05/2016
@type function
/*/
Static Function NextNumDoc()
	Local aAreaAtu 	:= GetArea()
	Local cNumAux 	:= ''
	Local cMay		:= ''

	//----------------------------------------------------------------------------
	// Inicializa o numero do Documento com o ultimo + 1
	//----------------------------------------------------------------------------
	dbSelectArea('SD3')
	cNumAux := NextNumero('SD3',2,'D3_DOC',.T.)
	cNumAux := A261RetINV(cNumAux)
	dbSetOrder(2)
	dbSeek(cFilAnt+cNumAux)
	cMay := 'SD3'+Alltrim(cFilAnt)+cNumAux
	While SD3->(D3_FILIAL+D3_DOC) == cFilAnt + cNumAux .Or. !MayIUseCode(cMay)
		If SD3->D3_ESTORNO # 'S'
			cNumAux := Soma1(cNumAux)
			cMay := 'SD3'+Alltrim(cFilAnt)+cNumAux
		EndIf
		dbSkip()
	EndDo

	RestArea( aAreaAtu )
Return( cNumAux )


/*/{Protheus.doc} A601Maior
//Função para tratamento de quantidade a maior e/ou ganho
@author bruna.rocio
@since 14/06/2016
@version undefined
@param nOP, numeric, descricao
@param nQuant, numeric, descricao
@param nQtdGanho, numeric, descricao
@param nQtdMaior, numeric, descricao
@type function
/*/
Static Function A601Maior(nOP , nQuant, nQtdGanho, nQtdMaior)
	Local lRet		 	:= .T.
	Local nProduz	 	:= 0
	Local nExcede 		:= 0
	Local nExcedeAtu 	:= 0
	Local nPercExced 	:= SuperGetMV("MV_PERCPRM",.F.,0)
	Local oQtdGanho		:= Nil
	Local oQtdMaior		:= Nil 
	Local lOk		 	:= .F. 
	Local lGanho	 	:= SuperGetMV("MV_GANHOPR",.F.,.T.)
	Local nQtdApont     := 0
	Local nQtdEstor     := 0     
	Local nQtdTotal     := 0
	Local nQtdDisp      := 0  
	Local nQtdSaldo     := 0
	
	if nQtdMaior == nil
		nQtdMaior := 0
	endif 
	
	if nQtdGanho == nil
		nQtdGanho := 0
	endif				 

	//Posicionaliza a SD4  //Everton
	DbSelectArea("SC2")
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial('SC2') + nOP)) 
		nProduz :=	C2_QUANT - C2_QUJE 
	endif
	
	//nProduz    - saldo da quantidade que ja foi apontada ate o momento
	//nQuant     - quantidade que esta sendo apontada agora
	//nExcede    - quantidade que excedeu considerando todos os apontamentos
	//nExcedeAtu - quantidade que excedeu no apontamento corrente
			
	If nQuant > nProduz 
		nExcede    := nQuant - nProduz   
		
		If nProduz <= 0
			nExcedeAtu := nQuant 	 
		Else
			nExcedeAtu := nQuant - nProduz 	
		EndIf	
		
              
        If lGanho .and. nPercExced > 0               
			//---------------------------
		  	//Monta a tela
		  	//---------------------------
   			DEFINE MSDIALOG oDlg  FROM 000, 000  TO 180, 360 TITLE OemToAnsi(STR0066)/*"Classificação da quantidade produzida acima do previsto"*/ PIXEL STYLE DS_MODALFRAME //"Classificação da quantidade produzida acima do previsto"
			cTexto := OemToAnsi(STR0067) + ALLTRIM(STR(nExcedeAtu)) + OemToAnsi(STR0068) + ALLTRIM(STR(SC2->C2_QUANT)) + "." + OemToAnsi(STR0069)
			/*----------------------------
			Texto contido na variável cTexto que será exibida na tela
			"Foi produzida quantidade de <nExcede> ;
			" acima da quantidade prevista pela ordem de produção, que era <SC2->C2_QUANT>.
			" Classifique este excedente conforme abaixo:"
			------------------------------*/
			 
			@ 010, 015 SAY cTexto SIZE 160, 025 OF oDlg COLORS 0, 16777215 PIXEL
			
			@ 040, 015 SAY OemToAnsi(STR0070)/*"Ganho de produção:"*/ SIZE 055, 015 OF oDlg COLORS 0, 16777215 PIXEL
			@ 060, 015 SAY OemToAnsi(STR0071)/*"Produção a maior:"*/  SIZE 055, 015 OF oDlg COLORS 0, 16777215 PIXEL
			
			@ 040, 070 MSGET oQtdGanho VAR nQtdGanho Picture PesqPict("SD3","D3_QTGANHO") Valid (Positivo(nQtdGanho)) SIZE 070, 010 OF oDlg PIXEL						
			@ 060, 070 MSGET oQtdMaior VAR nQtdMaior Picture PesqPict("SD3","D3_QTMAIOR") Valid (Positivo(nQtdMaior)) SIZE 070, 010 OF oDlg PIXEL
		
			DEFINE SBUTTON FROM 075, 086 TYPE 01 OF oDlg ENABLE ACTION (lOK := .T.,oDlgOK(oDlg, lOk, nQtdGanho, nQtdMaior, nExcedeAtu))
			DEFINE SBUTTON FROM 075, 115 TYPE 02 OF oDlg ENABLE ACTION (lOK := .F.,oDlg:End())
			
			oDlg:lEscClose := .F.
			ACTIVATE MSDIALOG oDlg CENTERED	                     
       		//---------------------------	 
            lRet := lOk
            if lRet
            	If nExcedeAtu > nQtdMaior + nQtdGanho //Faz com que tudo que não seja produção a maior vire ganho de produção
    	        	nQtdGanho := nExcedeAtu - nQtdMaior
        	     endif
			EndIf	
	 	Else
	 		nQtdMaior := nExcedeAtu 
			nQtdGanho := 0		
		EndIf 						
	EndIf
	
	
	If nQtdMaior > 0 
		nQtdApont := 0
		cAliasSD3:=GetNextAlias()
		cQuery:="SELECT SUM(d3_qtmaior) qtd_normal FROM "+RetSqlName("SD3")+" "
		cQuery+="WHERE D3_FILIAL='"+xFilial("SD3")+"' "
		cQuery+="AND D3_OP='"+nOP+"' "
		cQuery+="AND D3_CF='PR0'"
	
		cQuery:=ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSD3,.F.,.T.)
		If (cAliasSD3)->(!Eof())
			nQtdApont := (cAliasSD3)->qtd_normal		
		EndIF
	
		If Empty(nQtdApont)
			nQtdApont := 0		
		EndIf
	
		nQtdEstor := 0
		cAliasSD3:=GetNextAlias()
		cQuery:="SELECT SUM(d3_qtmaior) qtd_estorno FROM "+RetSqlName("SD3")+" "
		cQuery+="WHERE D3_FILIAL='"+xFilial("SD3")+"' "
		cQuery+="AND D3_OP='"+nOP+"' "
		cQuery+="AND D3_CF='ER0'"
	
		cQuery:=ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSD3,.F.,.T.)
		If (cAliasSD3)->(!Eof())
			nQtdEstor := (cAliasSD3)->qtd_estorno		
		EndIF
	
		If Empty(nQtdEstor)
			nQtdEstor := 0		
		EndIf  
	
		nQtdTotal := nQtdApont - nQtdEstor //Quantidade que ja foi apontada de produção a maior
	
		nQtdDisp := (SC2->C2_QUANT * nPercExced) / 100 //Quantidade que pode apontar a maior conforme percentual
		nQtdSaldo := nQtdDisp - nQtdTotal
	    	    
		If nQtdTotal > 0
			If nQtdDisp <= nQtdTotal 
				//cMsg  := 'Já foi apontada toda a quantidade disponível de produção a maior permitida conforme parametrização ("MV_PERCPRM").'
				//cMsg1 := ' Quantidade permitida: ' + CVALTOCHAR(nQtdDisp) + '. Quantidade já apontada de produção a maior:' + CVALTOCHAR(nQtdTotal) 
				cMsg  := STR0061 + ' ' + STR0062 + CVALTOCHAR(nQtdDisp) + '. ' + STR0063 + CVALTOCHAR(nQtdTotal) + '.'
				MsgStop(cMsg,STR0014)	
				//Help(,,STR0014,,cMsg) //"ATENCAO"###				
	    		lRet := .F.	
	   		Else          		   		
		   		If nQtdSaldo < nQtdMaior    
					//cMsg  := 'Quantidade informada de produção a maior ultrapassa o limite permitido conforme parametrização ("MV_PERCPRM").' 
					//cMsg1 := ' Quantidade permitida: ' + CVALTOCHAR(nQtdDisp) + '. Quantidade disponível: ' + CVALTOCHAR(nQtdSaldo) + '.'
					cMsg := STR0064 + ' ' + STR0062 + CVALTOCHAR(nQtdDisp) + '. ' + STR0065 + CVALTOCHAR(nQtdSaldo) + '.'
					//Help(,,STR0014,,cMsg) //"ATENCAO"###
					MsgStop(cMsg,STR0014)
		    		lRet := .F.	
		   		EndIf
			EndIF		   		
		Else
			If nQtdSaldo < nQtdMaior    
				//cMsg  := 'Quantidade informada de produção a maior ultrapassa o limite permitido conforme parametrização ("MV_PERCPRM").' 
				//cMsg1 := ' Quantidade permitida: ' + CVALTOCHAR(nQtdDisp) + '. Quantidade disponível: ' + CVALTOCHAR(nQtdSaldo) + '.'
				cMsg := STR0064 + ' ' + STR0062 + CVALTOCHAR(nQtdDisp) + '. ' + STR0065 + CVALTOCHAR(nQtdSaldo) + '.'
				MsgStop(cMsg,STR0014)
				//Help(,1,STR0014,,cMsg,3,0) //"ATENCAO"###
				lRet := .F.	
			EndIF
		EndIf								
	EndIf

Return lRet


/*/{Protheus.doc} oDlgOK
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 15/06/2016
@version undefined
@param oDlg, object, descricao
@param lOk, logical, descricao
@param nQtdGanho, numeric, descricao
@param nQtdMaior, numeric, descricao
@param nExcede, numeric, descricao
@type function
/*/
Static Function oDlgOK(oDlg, lOk, nQtdGanho, nQtdMaior, nExcede)
	Local lRet := .T.
	
	If lOk       
		if nQtdGanho + nQtdMaior = nExcede
			oDlg:End()
		else
			//A quantidade classificada é diferente do excedente da produção.
		    Help(" ",1,"A250QTDDIF")
		endif
	Endif
return lRet

/*/{Protheus.doc} A601FDVAR
//Valid de consulta de variedades
@author joaquim.burjack
@since 20/06/2017
@version undefined

@type function
/*/
Function A601FDVAR()
	Local aArea  := GetArea()
	Local cRet := ""
	
	IF IsIncallStack("Pergunte")
		if empty(mv_par05)
			cRet := "@#(NN4->NN4_SAFRA  = mv_par01 .AND. NN4->NN4_FAZ = mv_par04)@#"
		else
			cRet := "@#(NN4->NN4_SAFRA  = mv_par01 .AND. NN4->NN4_FAZ = mv_par04 .AND. NN4->NN4_TALHAO = mv_par05)@#"
		endif
	Else
		If Empty(DXL->DXL_TALHAO)
			cRet := "@#(NN4->NN4_SAFRA = '" + DXL->DXL_SAFRA + "' .AND. NN4->NN4_FAZ='" + DXL->DXL_FAZ + "')@#"
		Else 
			cRet := "@#(NN4->NN4_SAFRA = '" + DXL->DXL_SAFRA + "' .AND. NN4->NN4_FAZ='" + DXL->DXL_FAZ + "' .AND. NN4->NN4_TALHAO = '" + DXL->DXL_TALHAO + "')@#"
		EndIf
	EndIf
	RestArea(aArea)	
Return cRet


/*/{Protheus.doc} AGRA601ORD
//Valida Ordem de Colheita
@author carlos.augusto
@since 31/01/2018
@version undefined
@type function
/*/
Function AGRA601ORD(cOrdCol, _cCLTTEMP)
	Local lRet		:= .T.
	Local oModel 	:= FWModelActive()
	Local aArea		:= GetArea()
	Local aLines	:= FWSaveRows()
	Local oFieldDXL := oModel:GetModel("DXLMASTER")
	Local cBanco	:= UPPER(TCGetDB()) //Retorna o banco de dados em uso pela conexão ativa com o DBAccess
	
	If !Empty(cOrdCol)
		If !(_cCLTTEMP)->(RecCount()) > 0
			AGRA530ODC(.F., @_cCLTTEMP)
		EndIf
	
		dbSelectArea(_cCLTTEMP)
		(_cCLTTEMP)->(dbSetOrder(1))
	
		//Valida Ordem de Colheita
		lRet := (_cCLTTEMP)->(DbSeek(cOrdCol))
		If !lRet
			Help('' ,1,".AGRA50000009.", , ,1,0) //"Ordem de Colheita não encontrada.."Verifique o cadastro de Ordens de Colheita.
		EndIf
	               
		//Pede Safra
		If lRet
			If Empty(oFieldDXL:GetValue( "DXL_SAFRA" ))
				lRet := .F.
				Help('' ,1,".AGRA50000010.", , ,1,0) //"O campo Safra não foi preenchido. Favor preencher o campo de Safra para realizarmos as valições de Ordem de Colheta.
			EndIf
		EndIf
	
		//Valida Fazenda
		If lRet
			dbSelectArea("NN2")
			NN2->(dbSetOrder(2))//Fazenda
			lRet := NN2->(DbSeek(fwxFilial("NN2")+ (_cCLTTEMP)->CODFAZ))
			If lRet 
				If .Not. Empty(oFieldDXL:GetValue( "DXL_PRDTOR" ))
					NN2->(dbSetOrder(3))//NN2_FILIAL+NN2_PRDTOR+NN2_LJPRO+NN2_CODIGO
					lRet := DbSeek(fwxFilial("NN2") + oFieldDXL:GetValue( "DXL_PRDTOR" ) + oFieldDXL:GetValue( "DXL_LJPRO" ) + (_cCLTTEMP)->CODFAZ)
					If .Not. lRet
						Help('' ,1,".AGRA60100002.", , ,1,0) //"Não foi encontrada a Entidade vinculada com a fazenda informada na Ordem de Colheita. Verifique o cadastro de Fazendas."
						lRet := .F.
					EndIf
				EndIf
				If lRet
					oFieldDXL:LoadValue( "DXL_FAZ", (_cCLTTEMP)->CODFAZ )
					oFieldDXL:LoadValue( "DXL_NMFAZ", NN2->NN2_NOME )
				EndIf
			Else
				Help('' ,1,".AGRA50000018.", , ,1,0) //"Não foi encontrada a Fazenda informada na Ordem de Colheita. Verifique o cadastro de Fazendas"
				lRet := .F.
			EndIf
			NN2->(dbCloseArea())
		EndIf
		
		//Valida OP
		If lRet .AND. !Empty(alltrim((_cCLTTEMP)->CODOPS))
			dbSelectArea("SC2")
			SC2->(dbSetOrder(9)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_PRODUTO 
			lRet := DbSeek(fwxFilial("SC2")+ (_cCLTTEMP)->CODOPS + StrZero( 1 , TamSX3('C2_ITEM')[1]) + (_cCLTTEMP)->CODPRO)
			
			If lRet
				oFieldDXL:LoadValue( "DXL_OP", (_cCLTTEMP)->CODOPS + SC2->C2_ITEM + SC2->C2_SEQUEN)
			Else
				Help('' ,1,".AGRA50000013.", , ,1,0) //"Não foi encontrada Ordem de Produção com o Produto informado. Verifique o cadastro de Ordens de Produção.
				lRet := .F.
			EndIf
			SC2->(dbCloseArea())
		EndIf
	
		//Valida Talhao 
		
		If lRet
			//Calcula o tamanho necessário do substring
			nSubs   := Len(AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL))
			//Prepara a informação do talhão com setor + talhão PIMS
			cTalhao := AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL)
			//A query busca o último talhão que atende as informações parciais de setor e talhão pims
			//validadas junto a safra, produto, fazenda e variedade especifica atrelada a OC, além de 
			//garantir que o talhão não esteja fechado, tendo em vista que processualmente, se já estivermos 
			//trabalhando com a OC de outro talhão com o mesmo código aberto
			If cBanco == 'ORACLE'
				BeginSql Alias "QryTLVar"
				Select * From %Table:NN3% NN3
				Inner Join %Table:NN4% NN4
					On NN4.%notDel%
				   And NN4.NN4_FILIAL = %xFilial:NN4%	
				   And NN4.NN4_SAFRA  = NN3.NN3_SAFRA
				   And NN4.NN4_FAZ    = NN3.NN3_FAZ
				   And NN4.NN4_TALHAO = NN3.NN3_TALHAO
					Where NN3.%notDel%
					  and NN3.NN3_FILIAL = %xFilial:NN3%
					  and NN3.NN3_SAFRA  = %exp:oFieldDXL:GetValue( "DXL_SAFRA" )% //Safra da OP relacionada a OC
					  and NN3.NN3_FAZ    = %exp:(_cCLTTEMP)->CODFAZ%
					  and SUBSTR(NN3.NN3_TALHAO,1,%exp:nSubs%) = %exp:cTalhao%
					  and NN3.NN3_CODPRO = %exp:(_cCLTTEMP)->CODPRO%
					  and NN3.NN3_FECHAD = 'N'	
				EndSql	  				
			ElseIf cBanco == 'MSSQL'
				BeginSql Alias "QryTLVar"
				Select * From %Table:NN3% NN3
				Inner Join %Table:NN4% NN4
					On NN4.%notDel%
				   And NN4.NN4_FILIAL = %xFilial:NN4%	
				   And NN4.NN4_SAFRA  = NN3.NN3_SAFRA
				   And NN4.NN4_FAZ    = NN3.NN3_FAZ
				   And NN4.NN4_TALHAO = NN3.NN3_TALHAO
					Where NN3.%notDel%
					  and NN3.NN3_FILIAL = %xFilial:NN3%
					  and NN3.NN3_SAFRA  = %exp:oFieldDXL:GetValue( "DXL_SAFRA" )% //Safra da OP relacionada a OC
					  and NN3.NN3_FAZ    = %exp:(_cCLTTEMP)->CODFAZ%
					  and SUBSTRING(NN3.NN3_TALHAO,1,%exp:nSubs%) = %exp:cTalhao%
					  and NN3.NN3_CODPRO = %exp:(_cCLTTEMP)->CODPRO%
					  and NN3.NN3_FECHAD = 'N'					  
				EndSql
			EndIf			  
			
			If QryTLVar->(!Eof())
				oFieldDXL:LoadValue( "DXL_TALHAO", PADR(AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL) ,TamSx3("NN3_TALHAO")[1] ," ") )
				//oNJJ:LoadValue( "NJJ_DESTAL", QryTLVar->NN3_DESCRI )	
				oFieldDXL:LoadValue( "DXL_CODVAR", (_cCLTTEMP)->CODVAR)
				//oNJJ:LoadValue( "NJJ_DESVAR", Posicione('NNV',1,fwxFilial('NNV')+(_cCLTTEMP)->CODPRO+(_cCLTTEMP)->CODVAR, NNV->NNV_DESCRI ))
			Else
				Help('' ,1,".AGRA50000011.", , ,1,0) //"Não foi encontrado o Talhão informado na Ordem de Colheita. Verifique o cadastro de Talhões
				lRet := .F.
			EndIf
			
			QryTLVar->(dbCloseArea())
		EndIf	
			//Fim tratamento talhão + variedade
		/** Como o mesmo Talhao e Variedade podem estar em duas Safras/Periodos diferentes, nao ha como gatilhar
		If lRet
			dbSelectArea("NN3")
			NN3->(dbSetOrder(2))//Fazenda + talhao
			lRet := DbSeek(fwxFilial("NN3")+ (_cCLTTEMP)->CODFAZ + PADR(AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL) ,TamSx3("NN3_TALHAO")[1] ," "))
			If lRet
				oFieldDXL:LoadValue( "DXL_TALHAO", PADR(AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL) ,TamSx3("NN3_TALHAO")[1] ," ") )
//				oFieldDXL:LoadValue( "NJJ_DESTAL", NN3->NN3_DESCRI )
				
			Else
				Help('' ,1,".AGRA50000011.", , ,1,0) //"Não foi encontrado o Talhão informado na Ordem de Colheita. Verifique o cadastro de Talhões
				lRet := .F.
			EndIf
			NN3->(dbCloseArea())
		EndIf
	
		//Valida Variedade
		If lRet
			dbSelectArea("NN4")
			NN4->(dbSetOrder(2))//NN4_FILIAL+NN4_SAFRA+NN4_FAZ+NN4_TALHAO+NN4_CODVAR
			lRet := DbSeek(fwxFilial("NN4")+ oFieldDXL:GetValue( "DXL_SAFRA" ) + (_cCLTTEMP)->CODFAZ;
							+ PADR(AllTrim((_cCLTTEMP)->CODSET) + "-" + AllTrim((_cCLTTEMP)->CODTAL) ,TamSx3("NN3_TALHAO")[1] ," ") ;
						    + (_cCLTTEMP)->CODVAR)
						   
			If lRet
				oFieldDXL:LoadValue( "DXL_CODVAR", (_cCLTTEMP)->CODVAR)
				oFieldDXL:LoadValue( "DXL_DESCVR", NNV->NNV_DESCRI )
			Else
				Help('' ,1,".AGRA50000012.", , ,1,0) //"Não foi encontrado a Variedade informada na Ordem de Colheita. Verifique o cadastro de Variedades no Talhão.
				lRet := .F.
			EndIf
			NN4->(dbCloseArea())
		EndIf **/
	
		
		//Valida Produto
		If lRet
			dbSelectArea("SB1")
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
			lRet := DbSeek(fwxFilial("SB1")+ (_cCLTTEMP)->CODPRO)
			
			If lRet
				oFieldDXL:LoadValue( "DXL_CODPRO", (_cCLTTEMP)->CODPRO)
			Else
				Help('' ,1,".AGRA50000017.", , ,1,0) //"Não foi encontrado o Produto informado na Ordem de Colheita. Verifique o cadastro de Produtos"
				lRet := .F.
			EndIf
			SB1->(dbCloseArea())
		EndIf
		
		If lRet
			If .Not. Empty((_cCLTTEMP)->PREINI)
				oFieldDXL:LoadValue( "DXL_INICOL", (_cCLTTEMP)->PREINI)
			Else
				oFieldDXL:LoadValue( "DXL_INICOL", CtoD( "  /  /  " ))
			EndIf
			If .Not. Empty((_cCLTTEMP)->PREENC)
				oFieldDXL:LoadValue( "DXL_ENCCOL", (_cCLTTEMP)->PREENC)
			Else
				oFieldDXL:LoadValue( "DXL_ENCCOL", CtoD( "  /  /  " ))
			EndIf		
		EndIf
		
		If !lRet
			oFieldDXL:LoadValue( "DXL_FAZ",    Space(TamSx3("DXL_FAZ")[1]) )
			oFieldDXL:LoadValue( "DXL_TALHAO", Space(TamSx3("DXL_TALHAO")[1]) )
			oFieldDXL:LoadValue( "DXL_CODVAR", Space(TamSx3("DXL_CODVAR")[1]) )
			oFieldDXL:LoadValue( "DXL_DESCVR", Space(TamSx3("DXL_DESCVR")[1]) )
		EndIf
	Else
		oFieldDXL:LoadValue( "DXL_OP",     Space(TamSx3("DXL_OP")[1]) )
		oFieldDXL:LoadValue( "DXL_INICOL", CtoD( "  /  /  " ))
		oFieldDXL:LoadValue( "DXL_ENCCOL", CtoD( "  /  /  " ))	
	EndIf
	
	RestArea(aArea)
	FwRestRows(aLines)

Return lRet


/*/{Protheus.doc} AGRA601CDU
//Responsável por fazer a inserção dos codigos unicos caso os registros não tenham
@author brunosilva
@since 15/03/2018
@version undefined

@type function
/*/
Static Function AGRA601CDU()
	Local lRet		  := .T.
	Local aArea       := GetArea()
	Local cAliasDXL   := GetNextAlias()	
	Local cCodUni     := ""

	BeginSql Alias cAliasDXL
	SELECT DXL_FILIAL, DXL_SAFRA, DXL_CODIGO, DXL_PRDTOR, DXL_LJPRO, DXL_FAZ
	FROM %Table:DXL% DXL
	WHERE DXL.%NotDel%
	  AND (DXL.DXL_CODUNI IS NULL
	   OR  DXL.DXL_CODUNI = '')
	EndSQL

    (cAliasDXL)->(dbGoTop())
    While (cAliasDXL)->(!Eof())
    	//gera código único para registro
    	cCodUni := AGRCdgFrd((cAliasDXL)->DXL_CODIGO,(cAliasDXL)->DXL_SAFRA, (cAliasDXL)->DXL_PRDTOR, (cAliasDXL)->DXL_LJPRO, (cAliasDXL)->DXL_FAZ)
        
        dbSelectArea('DXL')
        dbSetOrder(1)    	
    	If MsSeek((cAliasDXL)->DXL_FILIAL+(cAliasDXL)->DXL_CODIGO+(cAliasDXL)->DXL_SAFRA+(cAliasDXL)->DXL_PRDTOR+(cAliasDXL)->DXL_LJPRO+(cAliasDXL)->DXL_FAZ)
	    	RecLock("DXL",.F.)
	    	DXL->DXL_CODUNI := cCodUni 
	    	MsUnLock()
	    EndIf	
    	
    	(cAliasDXL)->(dbSkip())
    EndDo
    (cAliasDXL)->(dbCloseArea())
    RestArea( aArea )
	
Return lRet


/*/{Protheus.doc} A601INBFZ
//-- Criada função para inicialização de Browser
//-- Não coube o posicione no campo X3_INIBRW
//-- Função chamada no campo DXB_NOMFAZ [SX3 - X3_INIBRW]
@author ana.olegini
@since 	14/06/2018

@return cNomeFaz, Retorna o nome da fazenda
/*/
Function A601INBFZ() //NN2_FILIAL+NN2_PRDTOR+NN2_LJPRO+NN2_CODIGO 
	Local cNomeFaz := POSICIONE("NN2",3,FWXFILIAL("NN2")+DXB->(DXB_PRDTOR+DXB_LJPRO+DXB_FAZ),"NN2_NOME")
Return cNomeFaz


/*/{Protheus.doc} AGRA601HFA
//Função histórico do fardo (fardinho)
@author marina.muller
@since 19/06/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function AGRA601HFA()
	Local aArea       := GetArea()
    Local cFiltroDef  := ""
     
	cFiltroDef := "@" + "DXI_FARDAO  = '"+ DXL->DXL_CODIGO +"' AND "+;	
			      "DXI_SAFRA   = '"+ DXL->DXL_SAFRA  +"' AND "+;
	              "DXI_PRDTOR  = '"+ DXL->DXL_PRDTOR +"' AND "+;
	              "DXI_LJPRO   = '"+ DXL->DXL_LJPRO  +"' AND "+;
	              "DXI_FAZ     = '"+ DXL->DXL_FAZ    +"'"	
    
    OGC140(cFiltroDef)	              
	              
	RestArea(aArea)
Return 


/*/{Protheus.doc} A601ClFld
//Limpa Campos
@author carlos.augusto
@since 04/07/2018
@version undefined
@param cCampo, characters, descricao
@type function
/*/
Function A601ClFld(cCampo)
	Local oModel 	:= FwModelActive()
	Local oDXL		:= oModel:GetModel():GetModel( "DXLMASTER" ) 
	
	Do Case
		Case "DXL_PRDTOR" $ cCampo .Or. "DXL_LJPRO" $ cCampo 
			oDXL:LoadValue("DXL_ORDCLT", Space(TamSX3("DXL_ORDCLT")[01]))
			oDXL:LoadValue("DXL_FAZ",    Space(TamSX3("DXL_FAZ")[01]))
			oDXL:LoadValue("DXL_TALHAO", Space(TamSX3("DXL_TALHAO")[01]))
			oDXL:LoadValue("DXL_CODVAR", Space(TamSX3("DXL_CODVAR")[01]))
			oDXL:LoadValue("DXL_NMFAZ",  Space(TamSX3("DXL_NMFAZ")[01]))
		Case "DXL_FAZ" $ cCampo 
			oDXL:LoadValue("DXL_TALHAO", Space(TamSX3("DXL_TALHAO")[01]))
			oDXL:LoadValue("DXL_CODVAR", Space(TamSX3("DXL_CODVAR")[01]))
			
		Case "DXL_TALHAO" $ cCampo 
			oDXL:LoadValue("DXL_CODVAR", Space(TamSX3("DXL_CODVAR")[01]))
			
		Otherwise
			Return .T.

	EndCase

Return .T.
