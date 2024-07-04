#INCLUDE "AGRA680.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE P_CAMPO   1
#DEFINE P_INICIO  2
#DEFINE P_TAM     3
#DEFINE P_COLUNA  4
#DEFINE P_TIPO    5
#DEFINE P_DECIMAL 6
#DEFINE P_TITULO  7    

Static __cContam := ""

//-----------------------------------------------------------
/*/{Protheus.doc} AGRA680
IMPORTACAO DE LABORATORIAL HVI

@param: Nil
@author: Aecio Ferreira Gomes
@since: 22/08/2012
@Uso: UBA
/*/
//-----------------------------------------------------------
Function AGRA680()

	/* VARIAVEIS LOCAIS*/
	Local aCoors 		:= FWGetDialogSize( oMainWnd )
	Local oSize	 		:= FWDefSize():New(.T.)
	Local oFWL			:= FwLayer():New()
	Local oWnd1			:= Nil
	Local oWnd2			:= Nil
	Local aTFolder		:= {}
	Local aMenu         := MenuDef()
		
	/* VARIAVEIS PRIVADAS*/
	Private DIRHVI 		:= "HVI\"
	Private DIRLIDO		:= "LIDO\"
	Private DIRERRO		:= "ERRO\"
	Private cGetPath	:= ""
	Private nProc 		:= 0
	Private nImp		:= 0
	Private oSay		:= Nil
	
	Private _oBrowse	:= Nil
	Private _oBrwCont	:= Nil	
	Private _LayImp		:= ""
	Private _aCpoKey 	:= {} // Armazena o campo chave do Layout
	Private _cGetSafra	
	Private _aStruLay 	:= {} // Armazena estrutura do Layout
	Private _cGetLayout	:= Space(TAMSX3("DX1_CODIGO")[1])
	Private _cGetDLay   := Space(TAMSX3("DX1_DESC")[1])
	Private _lNovSafra 	:= .F.
	
	if NN1->(ColumnPos('NN1_CODSAF' )) > 0
		_lNovSafra := .T.
	endIf
	
	if _lNovSafra
		_cGetSafra	:= Space(TAMSX3("NJU_CODSAF")[1])
	else
		_cGetSafra	:= Space(TAMSX3("NN1_ANO")[1]+TAMSX3("NN1_SEQ")[1])
	endif
	
	//Caso não exista, os diretorios padroes serao criados
	If !ExistDir(DIRHVI)
		MakeDir(DIRHVI)
		MakeDir(DIRHVI+DIRLIDO)
		MakeDir(DIRHVI+DIRERRO)
	EndIf

	//Dimenssiona a area do container principal
	oSize:AddObject("oLbx",100,100,.T.,.T.)
	oSize:SetWindowSize({aCoors[1],aCoors[2],aCoors[3],aCoors[4]})
	oSize:lProp 	:= .T.
	oSize:Process()

	/* Cria a Dialog - "Resultado Laboratorial HVI" */
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001)	FROM oSize:aWindSize[1], oSize:aWindSize[2];
	TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL STYLE nOR(WS_VISIBLE,WS_POPUP)

	oDlg:lEscClose := .F.

	oFWL:init( oDlg, .T. )
	//Divide a area da Dialog em colunas
	oFWL:addCollumn( "ESQ", 65, .F.)
	oFWL:addCollumn( "DIR", 35, .F.)

	//Recupera o Panel das colunas
	oPnl1 := oFWL:getColPanel("ESQ")
	oPnl3 := oFWL:getColPanel("DIR")
	
	if DX1->(ColumnPos('DX1_CONTAM'))
		// Cria a Folder
		aTFolder := { 'HVI', STR0052}
		oTFolder := TFolder():New( 0,0,aTFolder,,oPnl1,,,,.T.,,(oPnl1:NCLIENTWIDTH*0.50),(oPnl1:NCLIENTHEIGHT*0.50))
	else
		// Cria a Folder
		aTFolder := { 'HVI'}
		oTFolder := TFolder():New( 0,0,aTFolder,,oPnl1,,,,.T.,,(oPnl1:NCLIENTWIDTH*0.50),(oPnl1:NCLIENTHEIGHT*0.50))
	endIf
	
	//Acidiona janelas a direita
	oFWL:addWindow( "DIR" , "Wnd1", STR0002, 40, .F., .T.) //"Pesquisa arquivos"
	oFWL:addWindow( "DIR" , "Wnd2", STR0003, 60, .F., .T.) //"Importação de arquivos"

	//Monta o Browse onde serao visualizados os registros importados
	_oBrowse := FWMBrowse():New()
	_oBrowse:SetOwner( oTFolder:aDialogs[1] )
	_oBrowse:SetAlias('DX7')
	_oBrowse:SetDescription( STR0004 ) //"Resultado Laboratorial de HVI"
	_oBrowse:DisableDetail()
	_oBrowse:SetWalkThru(.F.)
	_oBrowse:SetSeek(.F.)
	_oBrowse:Activate()

	if DX1->(ColumnPos('DX1_CONTAM'))
		//Monta o Browse onde serao visualizados os registros importados de contaminantes
		_oBrwCont := FWMBrowse():New()
		_oBrwCont:SetOwner( oTFolder:aDialogs[2] )
		_oBrwCont:SetAlias('NPX')
		_oBrwCont:SetDescription( STR0053) //"Resultado Laboratorial de Análise de Contaminantes"
		_oBrwCont:DisableDetail()
		_oBrwCont:SetWalkThru(.F.)
		_oBrwCont:SetSeek(.F.)
		_oBrwCont:SetOnlyFields( { 'NPX_FILIAL', 'NPX_CODTA', 'NPX_BLOCO', 'NPX_ROMCLA', 'NPX_RESNUM', 'NPX_RESTXT', 'NPX_RESDTA' } )
		_oBrwCont:SetFilterDefault("@ NPX_ATIVO = '1' AND (NPX_CODVA <> 'DXD' AND NPX_CODVA <> 'DXJ' AND NPX_CODVA <> 'DXI') ")
		_oBrwCont:SetMenuDef('')
		_oBrwCont:Activate()
	
		_oBrwCont:SetColumnOrder(7,3)
		_oBrwCont:SetColumnOrder(6,4)
		_oBrwCont:UpdateBrowse()
	endIf

	//Recupera o Panel das janelas
	oWnd1 := oFWL:getWinPanel( "DIR", "Wnd1")
	oWnd2 := oFWL:getWinPanel( "DIR", "Wnd2")

	//Adiciona os componentes na janela da parte superior da coluna a direita
	A680PATH(@oWnd1,@oWnd2)

	//Adiciona os componentes na janela da parte inferior da coluna a direita
	A680LISTBX(@oWnd2)

	ACTIVATE MSDIALOG oDlg CENTERED

Return NIL

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina Title STR0035		Action 'VIEWDEF.AGRA680' 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina Title STR0036		Action 'VIEWDEF.AGRA680'	OPERATION 5 ACCESS 0
Return aRotina

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function ModelDef()

	Local oModel   	:= Nil
	Local oStruDX7 	:= FwFormStruct( 1, "DX7" ) // Resultado Laboratorial HVI

	oModel := MpFormModel():New( 'AGRA680',/*bPre*/,/*bPos*/, {|oModel| AGRA680GRV(oModel)} /*bGrav*/, /*bCancel*/ )
	oModel:SetDescription( STR0005 ) //'Modelo de dados do Resultado Laboratorial HVI'

	oModel:AddFields( 'DX7MASTER', /*cOwner*/, oStruDX7 )
	oModel:GetModel( 'DX7MASTER' ):SetDescription( STR0006 ) //'Dados do Resultado Laboratorial de HVI'

Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function ViewDef()

	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA680" )
	Local oStruDX7 	:= FwFormStruct( 2, "DX7" ) // Resultado Laboratorial HVI
	Local nX		:= 0

	oView := FwFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_DX7', oStruDX7, 'DX7MASTER' )
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'VIEW_DX7', 'TOTAL' )

	//Agrupamento de campos
	oStruDX7:AddGroup( 'GRUPO1', STR0037, '', 1 )
	oStruDX7:AddGroup( 'GRUPO2', STR0038, '', 2 )

	For nX:=1 To Len(oStruDX7:AFIELDS)
		If oStruDX7:AFIELDS[nX,1] $ "DX7_FILIAL|DX7_SAFRA|DX7_ETIQ|DX7_LAB|DX7_UNI|DX7_NMLAB"
			oStruDX7:SetProperty( oStruDX7:AFIELDS[nX,1] , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' ) // Dados da Fardo
		Else
			oStruDX7:SetProperty( oStruDX7:AFIELDS[nX,1] , MVC_VIEW_GROUP_NUMBER, 'GRUPO2' ) // Classificação HVI
		EndIf
	Next

Return oView


/*/{Protheus.doc} AGRA680GRV
//TODO Descrição auto-gerada.
@author silvana.torres
@since 18/09/2017
@version undefined

@type function
/*/
Static Function AGRA680GRV(oModel)
	
	Local aArea := getArea()
	Local nOperac 	:= oModel:GetOperation()
	Local lRet		:= .T.
	Local oMdlDXJ   := FwLoadModel('AGRA630')
	Local cTipo 	:= "2" //Romaneio tipo HVI
	Local lHviPend  := .F.

	Private cUserBenf
	
	lRet := oModel:VldData()
	
	If lRet .And. nOperac == 5 /*excluir importação*/
	
		if DXK->(ColumnPos('DXK_TIPO'))		
			dbSelectArea("DXK")
			DXK->(dbSetOrder(2)) //Filial+Safra+Etiqueta+Tipo
			
			if MsSeek(FWxFilial("DXK")+DX7->DX7_SAFRA+DX7->DX7_ETIQ+cTipo)
				dbSelectArea("DXJ")
				DXJ->(dbSetOrder(1)) //filial+codigo+tipo
	
				if MsSeek(FWxFilial("DXJ")+DXK->DXK_CODROM+DXK->DXK_TIPO)
				
					oMdlDXJ:SetOperation(4)
	
					If oMdlDXJ:Activate()
	
						//Limpa a data de classificação	
						oMdlDXJ:SetValue('MdFieldDXJ', 'DXJ_DTCLAS', ctod(''))
						
						A630RetSta(DX7->DX7_SAFRA, DX7->DX7_ETIQ)
						
						lHviPend := VerifImp(DXJ->DXJ_CODIGO, DX7->DX7_SAFRA)
						
						if lHviPend
							oMdlDXJ:SetValue('MdFieldDXJ', 'DXJ_STATUS', "4")
						else
							oMdlDXJ:SetValue('MdFieldDXJ', 'DXJ_STATUS', "5")
						endIf
												
						// Informa a data e hora da ataulização para atualizar/excluir a mala
						// do aplicativo do Beneficiamento
						if DXJ->(ColumnPos('DXJ_DATENV')) > 0						
							If !Empty(DXJ->DXJ_DATENV)
								oMdlDXJ:SetValue('MdFieldDXJ', 'DXJ_DATATU', dDatabase)
								oMdlDXJ:SetValue('MdFieldDXJ', 'DXJ_HORATU', Time())
							EndIf
						endIf
						
						If oMdlDXJ:VldData()
							lRet := FWFormCommit(oMdlDXJ)
						else
							lRet := .F.
						endIf
					Else
						oModel:GetModel():SetErrorMessage( oModel:GetId(), , oModel:GetId(), "", "", oMdlDXJ:GetErrorMessage()[3], oMdlDXJ:GetErrorMessage()[6], "", "")
						lRet := .F.
					endIf
					
					oMdlDXJ:DeActivate()	
									
				endIf
			endIf
		endIf	
	EndIf
	
	// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
	if lRet 
		lRet := FWFormCommit(oModel)
	endIf
	
	restArea(aArea)
	
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} A680PATH
Monta tela para permitir pesquisar os arquivos para importação

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function A680PATH(oWnd1,oWnd2)

	Local bSel		:= {|| }
	Local cRootPath := GetSrvProfString("RootPath","")
	Local oSize	 	:= FWDefSize():New(.F.)

	oSize:AddObject("PANEL",100,100,.T.,.T.)
	oSize:SetWindowSize({0,0,oWnd1:NHEIGHT,oWnd1:NWIDTH})
	oSize:lProp		:= .T.
	oSize:aMargins	:= {0,0,0,0}
	oSize:Process()

	bSel := {|| cGetPath := cGetFile( "" , OemToAnsi(STR0007) , 1 ,; //"Selecione o caminho onde estão localizados os arquivos"
	cRootPath +"\" +DIRHVI , .T. ,  nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ))}
	@ oSize:AposObj[1,1]+4, oSize:AposObj[1,2] SAY oLayout PROMPT OemToAnsi("Safra") SIZE 025, 07 OF oWnd1 PIXEL
	
	if _lNovSafra
		@ oSize:AposObj[1,1]+2, oSize:AposObj[1,2]+020 MSGET oGetSafra VAR _cGetSafra 	SIZE TamSX3("NJU_CODSAF")[1]*4+5, 10  F3 "NJU";
		VALID A680VldSF() OF oWnd1 PIXEL
	else	
		@ oSize:AposObj[1,1]+2, oSize:AposObj[1,2]+020 MSGET oGetSafra VAR _cGetSafra 	SIZE TamSX3("NN1_ANO")[1]+TamSX3("NN1_SEQ")[1]*4+5, 10  F3 "NN1";
		VALID A680VldSF() OF oWnd1 PIXEL
	endIf

	@ oSize:AposObj[1,1]+19, oSize:AposObj[1,2] SAY oLayout PROMPT OemToAnsi(STR0008) SIZE 025, 07 OF oWnd1 PIXEL			 //"Layout"
	@ oSize:AposObj[1,1]+17, oSize:AposObj[1,2]+020 MSGET oGetLayout VAR _cGetLayout 	SIZE TamSX3("DX1_CODIGO")[1]*4+5, 10  F3 "DX1";
	VALID ((nProc:=0,nImp:=0),A680LAYOUT(_cGetLayout), _cGetDLay := Posicione('DX1',1,FWxFilial('DX1')+_cGetLayout, 'DX1_DESC'))  OF oWnd1 PIXEL
	
	@ oSize:AposObj[1,1]+17, oSize:AposObj[1,2]+50 MSGET oGetLayout VAR _cGetDLay 	SIZE TamSX3("DX1_DESC")[1]*5, 10;
	OF oWnd1 PIXEL WHEN .F.

	@ oSize:AposObj[1,1]+34, oSize:AposObj[1,2] SAY oPath PROMPT OemToAnsi("Path:") 	SIZE 025, 07 OF oWnd1 PIXEL
	@ oSize:AposObj[1,1]+32, oSize:AposObj[1,2]+20 MSGET oGetPath VAR cGetPath 	SIZE oSize:AposObj[1,4]-40, 07 OF oWnd1 PIXEL WHEN .F.
	@ oSize:AposObj[1,1]+32, oSize:AposObj[1,4]-17 BUTTON oBtnSel PROMPT OemToAnsi("Path") Action((nProc:=0,nImp:=0),Eval(bSel)) 	SIZE 017, 010 OF oWnd1 PIXEL

	// Cria barra de botoes 
	DEFINE BUTTONBAR oBar SIZE 25,25  3D BOTTOM OF oWnd1
	TButton():New ( 35, oSize:AposObj[1,2], STR0009, oBar, {|| A680GETARQ(@oWnd2),(nProc:=0,nImp:=0)}, 35, 10,,,, .T.,, STR0010) //"Buscar"###"Buscar arquivos"

	nProc:=0
	nImp:=0
Return

//-----------------------------------------------------------
/*/{Protheus.doc} A680VldSF
Validação da Safra

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function A680VldSF()

	Local lRet := .T.

	if _lNovSafra
		NJU->(dbSetOrder(1))
		If !NJU->(MsSeek(fwxFilial("NJU")+_cGetSafra))
			lRet := .F.
			Help("",1,"REGNOIS",,,1)
		EndIf
	else
		NN1->(dbSetOrder(1))
		If !NN1->(DbSeek(FWxFilial("NN1")+_cGetSafra))
			lRet := .F.
			Help("",1,"REGNOIS",,,1)
		EndIf		
	endIf

Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} A680LAYOUT
Validação do Layout

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function A680LAYOUT()

	Local aArea 	:= DX2->(GetArea())
	Local lRet		:= .T.
	
	_aStruLay 		:= {}

	dbSelectArea("DX2")
	dbSetOrder(1) //Filial+Layout+campo
	If MsSeek(fwxFilial("DX2")+_cGetLayout)
		While !Eof()  .And. Alltrim(DX2_LAYOUT) == Alltrim(_cGetLayout)
			If DX2->DX2_CAMPO $ 'DX7_LAB|DX7_UNI|DX7_NMLAB'
				Loop
			EndIf

			If Alltrim(DX2->DX2_CAMPO) == "DX7_ETIQ"
				_LayImp := "HVI" //Constante - sem tradução
			elseIf Alltrim(DX2->DX2_CAMPO) == "CODUNICO"
				_LayImp := "Contaminante" //Contante - sem tradução
			endIf
			
			if _LayImp == "HVI" //Constante - sem tradução
				SX3->(dbSetOrder(2)) //X3_CAMPO
				SX3->(MsSeek(DX2->DX2_CAMPO))
			endIf
			
			If Alltrim(DX2->DX2_CAMPO) == "DX7_ETIQ" .Or. Alltrim(DX2->DX2_CAMPO) = "CODUNICO"
				_aCpoKey := {DX2->DX2_CAMPO,DX2->DX2_INICIO,DX2->DX2_TAM,DX2->DX2_COLUNA}				
			Else
				if _LayImp == "HVI" //Constante - sem tradução
					AADD(_aStruLay,{DX2->DX2_CAMPO,DX2->DX2_INICIO,DX2->DX2_TAM,DX2->DX2_COLUNA,TAMSX3(DX2->DX2_CAMPO)[3],DX2->DX2_OPE,DX2->DX2_FORM,DX2->DX2_MIN,DX2->DX2_MAX})
				elseIf _LayImp ==  "Contaminante" //Constante - sem tradução
					AADD(_aStruLay,{DX2->DX2_CAMPO,DX2->DX2_INICIO,DX2->DX2_TAM,DX2->DX2_COLUNA,DX2->DX2_TIPRES,DX2->DX2_DECIMA,DX2->DX2_NOME})
				endIF
			EndIf

			dbSkip()
		End

		If Empty(_aCpoKey)
			lRet := .F.
			If _LayImp = "Contaminante"
				Help(,,STR0039,,STR0040,1,0) //"O campo DX7_ETIQ não consta no Layout, sem ele não será possivel a importação dos dados"
			Else
				Help(,,STR0039,,STR0043,1,0) //"O campo CODUNICO não consta no Layout, sem ele não será possivel a importação dos dados"
			Endif	
		EndIf
	Else
		_aStruLay := {}
		lRet := .F.
		Help(,,"REGNOIS",,"",1,0)
	EndIf

	RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} A680LISTBX
Monta list Box para apresentar os arquivos encontrados

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function A680LISTBX(oWnd2)

	Local aVetor	:= {}
	Static oOk    	:= LoadBitmap( GetResources(), "LBOK" )
	Static oNo    	:= LoadBitmap( GetResources(), "LBNO" )
	Static oBar		:= Nil
	Static oLbx		:= Nil

	//Coordenadas da area total da Dialog
	oSize:= FWDefSize():New(.F.)
	oSize:AddObject("oLbx",100,100,.T.,.T.)
	oSize:SetWindowSize({0,0,oWnd2:NHEIGHT,oWnd2:NWIDTH})
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	aVetor := {{.F.,"","",""}}

	@ oSize:aPosObj[1,1],oSize:aPosObj[1,2] LISTBOX oLbx FIELDS HEADER " ", STR0011, STR0012, STR0013; //"Arquivo"###"Tamanho"###"Ultima Alteração"
	SIZE oSize:aPosObj[1,4]-1,oSize:aPosObj[1,3]-40 OF oWnd2 PIXEL

	oLbx:SetArray(aVetor)
	oLbx:bLine := {|| {IIF(aVetor[oLbx:nAt,1],oOk,oNo),;
	aVetor[oLbx:nAt,2],;
	aVetor[oLbx:nAt,3],;
	aVetor[oLbx:nAt,4]}}

	//Apresenta calculos de peso total dos Fardos selecionados e quantidade de itens do romaneio na tela
	oSay:= TSay():New(oSize:aPosObj[1,3]-30,oSize:AposObj[1,2],{|| Transform( STR0014, "@!" )},oWnd2,,,,,,.T.,,,84,25) //"Arquivos Processados:"
	oSay:= TSay():New(oSize:aPosObj[1,3]-30,oSize:AposObj[1,2]+84,{||  Alltrim(Transform( nProc, '@E 999') )},oWnd2,,,,,,.T.,,,12,25)
	oSay:= TSay():New(oSize:aPosObj[1,3]-20,oSize:AposObj[1,2],{|| Transform( STR0015, "@!" )},oWnd2,,,,,,.T.,,,84,25) //"Registros Importados:"
	oSay:= TSay():New(oSize:aPosObj[1,3]-20,oSize:AposObj[1,2]+84,{|| Alltrim(Transform( nImp, '@E 99999') )},oWnd2,,,,,,.T.,,,20,25)

	//Cria barra de botoes 
	DEFINE BUTTONBAR oBar SIZE 25,25  3D BOTTOM OF oWnd2
	TButton():New ( 35, oSize:AposObj[1,2], STR0016, oBar, {|| Processa({|| A680IMPORT(oWnd2) },STR0017)} , 35, 10,,,, .T.,, STR0017) //"Importar"###"Importar Arquivos"

	oLbx:AARRAY:={}
Return

//-----------------------------------------------------------
/*/{Protheus.doc} A680GETARQ
Retorna os arquivos encontrados no Diretorio      

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function A680GETARQ(oWnd2)

	Local aVetor	:= {}
	Local nX 		:= 0
	Local lRet  	:= .T.
	Local lMark		:= .T.

	lRet := !Empty(cGetPath)

	If !ExistDir(cGetPath + "\ERRO")
		MakeDir(cGetPath + "\ERRO")
	Endif
	If !ExistDir(cGetPath + "\LIDO")
		MakeDir(cGetPath + "\LIDO")
	EndIf

	If lRet
		aFiles := Directory(cGetPath+"*.TXT")

		For nX := 1 To Len(aFiles)
			AADD(aVetor,{.F.,aFiles[nX,1],aFiles[nX,2],aFiles[nX,3]})
		Next

		If Len( aVetor ) == 0
			oLbx:SetArray( aVetor )
			lRet := .F.
		Endif
	EndIf

	If lRet
		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {IIF(aVetor[oLbx:nAt,1],oOk,oNo),;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		aVetor[oLbx:nAt,4]}}
	EndIf

	oLbx:BLDBLCLICK 	:= {|| If(!Empty(oLbx:AARRAY), aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())}
	oLbx:BHEADERCLICK	:= {|| A680MarkTd(@lMark) }
	oLbx:Refresh()
Return

//-----------------------------------------------------------
/*/{Protheus.doc} A680IMPORT
Faz a importação dos resultados de HVI

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function A680IMPORT(oWnd2)

	Local aAreaDX7  	:= DX7->(GetArea())
	Local oModel		:= FwLoadModel( "AGRA680" )
	Local nX1			:= 0
	Local eX			:= 0
	Local lX			:= 0
	Local cFile			:= ""
	Local lRet			:= .T.
	Local lErro			:= .F.
	Local nCont  		:= 0
	Local nTotHvi		:= 0
	Local nLinha		:= 0
	Local nPriLin		:= 0
	Local lret2			:= .F.
	Local nY            := 0
	Local aErro         := {}
	Local cFilBkp       := cFilAnt
	
	Private _cLinha		:= ""
	Private _cSeparador	:= ""
	Private _aNimp		:= {}
	Private _aClassif   := {}
	Private _lNext		:= .T.
	Private _aLimite	:= {}
	
	nImp  := 0
	nProc := 0
	nArquivo := Len(oLbx:AARRAY)

	//Valida estrutura do Layout
	If Empty(_aStruLay) .And. Empty(_aCpoKey)
		lRet := .F.
		aAdd(aErro, { ''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0018, STR0019 }) //"ATENÇÃO!"###"A estrutura do Layout está vazia"
	EndIf

	//Posiciona no registro do Laboratorio
	If !DX1->(MsSeek(fwxFilial("DX1")+_cGetLayout))
		lRet := .F.
		aAdd(aErro, { ''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0018, STR0020 }) //"ATENÇÃO!"###"Código de Layout invalido"
	Else
		if DX1->(ColumnPos('DX1_CONTAM'))
			If DX1->DX1_TIPO = '2' //Contaminante
				If !Empty(DX1->DX1_CONTAM)
					__cContam := DX1->DX1_CONTAM
				Else
					aAdd(aErro, { ''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
					 			STR0018, STR0042 }) //"ATENÇÃO!"###'Contaminante não informado para o layout'
				Endif
			Endif
		Endif
		
		If !Empty(DX1->DX1_SPRDOR)
			//Se separador vazio ou 3, então, não tem separador
			If DX1->DX1_SPRDOR == "1"
				_cSeparador := ","
			ElseIf DX1->DX1_SPRDOR == "2"
				_cSeparador := ";"
			EndIf
		EndIf
		
		if DX1->(ColumnPos('DX1_PRILIN')) > 0
			If !Empty(DX1->DX1_PRILIN)
				nPriLin := DX1->DX1_PRILIN
			Else
				nPriLin	:= 1
			EndIf
		endIf
	EndIf

	DXI->(dbSetOrder(1)) // DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
	DX7->(dbSetOrder(1)) // DX7_FILIAL+DX7_SAFRA+DX7_ETIQ+DX7_LAB+DX7_UNI

	ProcRegua(nArquivo)

	If lRet
		For nX1 := 1 To Len(oLbx:AARRAY)
			If !oLbx:AARRAY[nX1,1]
				Loop
			EndIf

			nProc++
			cFile := oLbx:AARRAY[nX1,2]
											
			If (File(cGetPath + cFile))
				FT_FUse(cGetPath + cFile)
				nLinha := 0	
				if DX1->(ColumnPos('DX1_PRILIN')) > 0
					nTotHvi += (FT_FLASTREC() - nPriLin) + 1
					nCont   := (FT_FLASTREC() - nPriLin) + 1 
					ProcRegua((FT_FLASTREC() - nPriLin) + 1)
				else
					nTotHvi += FT_FLASTREC()
					nCont   := FT_FLASTREC()  
					ProcRegua(FT_FLASTREC())
				endIf
				FT_FGotop()
				
				While(!FT_FEof())
					IncProc(STR0029 + cFile + " -> " + alltrim(STR(nlinha)) + "/" + alltrim(Str(nCont))) //"Lendo arquivo..."
					nLinha++
					
					If nPriLin > nLinha
						FT_FSkip()
						Loop
					EndIf
					
					_cLinha	:= AllTrim(FT_FReadLN())

					If Empty(_cLinha)
						FT_FSkip()
						Loop
					EndIf
					
					If _LayImp == "HVI"
						lRet := A680ImpHVI(oModel,@aErro)
						
						If !lRet
							//Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso
							aAdd( aErro, oModel:GetErrorMessage())
						Endif
					ElseIf _LayImp == "Contaminante"
						lRet := A680ImpCnt(oModel,@aErro)						
					EndIf

					If !lRet
						lErro := .T.						
					Else
						nImp++
					EndIf
										
					FT_FSkip()
				End
				//Desativa o Model
				oModel:DeActivate()	
				If lErro
					For nY := 1 to Len(aErro)
						If !EmptY( aErro[nY,5])										
							AutoGrLog( STR0021	+ ' [' + AllToChar( _cGetLayout ) 	+ ']' ) //"Layout:"
							AutoGrLog( STR0011	+ ' [' + AllToChar( cFile	) 		+ ']' ) //"Arquivo"
							AutoGrLog( STR0022	+ ' [' + Alltrim(AllToChar( FT_FRecno ( ) ))	+ ']' ) //"Linha:"
							AutoGrLog( STR0023	+ ' [' + AllToChar( 'AGRA680' ) 	+ ']' ) //"Programa:"
							AutoGrLog( STR0024	+ ' [' + AllToChar( aErro[nY,2] ) 		+ ']' ) //"Id do campo de origem: "
							AutoGrLog( STR0025 	+ ' [' + AllToChar( aErro[nY,3] ) 		+ ']' ) //"Id do formulário de erro: "
							AutoGrLog( STR0026	+ ' [' + AllToChar( aErro[nY,4] ) 		+ ']' ) //"Id do campo de erro: "
							AutoGrLog( STR0027	+ ' [' + AllToChar( aErro[nY,5] ) 		+ ']' ) //"Id do erro: "
							AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[nY,6] ) 		+ ']' ) //"Mensagem do erro: "
							AutoGrLog( CRLF	)
						Endif			
						AutoGrLog( CRLF	)
					Next nY
					//Move arquivo para pasta de Erros
					Copy File &(cGetPath+cFile) To &(cGetPath+DIRERRO+cFile)
					FErase(cGetPath+cFile)
				Else
					//Move arquivo para pasta dos processados
					Copy File &(cGetPath+cFile) To &(cGetPath+DIRLIDO+cFile)
					FErase(cGetPath+cFile)
				EndIf
			EndIf

		Next nX1
		
		If Len(_aClassif) > 0
			AtuClassif(_aClassif,_cGetSafra)
		Endif
	Else
		//Apresenta os motivos de não ter passado nas validações iniciais
		If Len(aErro) > 0
			For nY := 1 to Len(aErro)
				AutoGrLog( STR0027	+ ' [' + AllToChar( aErro[nY,5] ) 		+ ']' ) //"Id do erro: "
				AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[nY,6] ) 		+ ']' ) //"Mensagem do erro: "
				AutoGrLog( CRLF	)
			Next nY
		Endif
	EndIf
	
	If lErro .And. Len(aErro) > 0
		MostraErro(cGetPath+DIRERRO)
	EndIf
	
	If nTotHvi > 0
		//Exibe resumo de HVI Importados e nao encontrados
		AutoGrLog(STR0030 + alltochar(nTotHvi)) //"Resultados Processados  "
		AutoGrLog(STR0031 + alltochar(nImp - len(_aLimite) - len(_aNimp))) //"Resultados Importados.: "
		
		// checa se houve descarte por validação de limites e exibe no log
		If Len(_aLimite) > 0
			AutoGrLog(STR0033 + ': ' + alltochar(len(_aLimite)) ) 
			For lX := 1 to Len(_aLimite)
				AutoGrLog(alltochar(_aLimite[lX,1]) + ' , ' + alltrim(alltochar(_aLimite[lX,2])) + ' , ' + alltochar(_aLimite[lX,3])) // etiqueta + campo de limite + valor alem do limite
			next
		Endif
		
		AutoGrLog(STR0032 + alltochar(Len(_aNimp))) //"Registros não localizados: "
		
		//Lista de Etiquetas não localizadas
		For eX := 1 to Len(_aNimp)
			AutoGrLog(alltochar(_aNimp[eX])) //"Nao Localizados : "
		next
		
		If Len(aErro) > 0
			AutoGrLog(STR0044) //"Lista de inconsistências"
			For nY := 1 to Len(aErro)
										
				If !EmptY( aErro[nY,5])										
					AutoGrLog( STR0027	+ ' [' + AllToChar( aErro[nY,5] ) 		+ ']' ) //"Id do erro: "
					AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[nY,6] ) 		+ ']' ) //"Mensagem do erro: "
				Endif			
			Next nY
		Endif
	Endif
	
	MostraErro()
			
	cFilAnt := cFilBkp		
	A680GETARQ(@oWnd2)
	_oBrowse:updateBrowse()
	
	if DX1->(ColumnPos('DX1_CONTAM'))
		_oBrwCont:updateBrowse()
	endIf
	
	RestArea(aAreaDX7)
Return lret2

//-----------------------------------------------------------
/*/{Protheus.doc} A680MarkTd
Marca/Desmaca Todos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 21/08/2012
@Uso: AGRA680
/*/
//-----------------------------------------------------------
Static Function A680MarkTd(lMark)
	Local nX := 0

	For nX := 1 To Len(oLbx:AARRAY)
		If lMark
			oLbx:AARRAY[nX,1] := .T.
		Else
			oLbx:AARRAY[nX,1] := .F.
		EndIf
	Next nX

	oLbx:Refresh()
	lMark := !lMark
Return

//--------------------------------------------------------------
/*/{Protheus.doc} Converte
Converte o conteudo importado conforme o tipo informado(N ou D).

@param: Nil
@author: Aecio Ferreira Gomes
@since: 07/06/2013
@Uso: AGRA680
/*/
//--------------------------------------------------------------
Static Function Converte(cTipo,cConteudo, nX, aErro)

	Local uRet := cConteudo

	Do Case

		Case cTipo == "N"
			if !Type(StrTran(cConteudo,'.','')) == "N"
				_lCnv := .F.
				aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
				 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique."
			else
				uRet := Val(cConteudo)
				
				if alltrim(cConteudo) != "0" .And. uRet = 0
					_lCnv := .F.
					aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
					 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique." 
				endIf
			endIf
		Case cTipo == "D"
			If AT("/" ,cConteudo ) > 0
				If Len(cConteudo) = 10
					uRet := CTOD(cConteudo) //conv caracter no formato "DD/MM/AAAA"" para uma var do tipo data
				Else
					_lCnv := .F.
					aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
					 			STR0045, STR0057 + cConteudo + STR0058 }) //'Erro'##"O conteúdo " está fora dos padrões de data permitidos: AAAAMMDD ou DD/MM/AAAA."   
				EndIf
			Else
				uRet := STod(cConteudo)
				
				if uRet = STOD("  /  /    ")
					_lCnv := .F.
					aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
					 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique." 
		 		endIf
			EndIf
	EndCase

Return uRet

//--------------------------------------------------------------
/*/{Protheus.doc} AtuClassif
Atualiza o status do romaneio de classificação relacionado aos
registros de HVI

@param: Nil
@author: Bruna Fagundes Rocio
@since: 22/12/2015
@Uso: AGRA680
/*/
//--------------------------------------------------------------
Static Function AtuClassif(aClassif, cSafra)
	Local nX    := 0
	Local cTipo := "2" //Romaneio tipo HVI
	Local nDXK  := 0
	Local nDX7  := 0
	Local dDatEnv
	Local cHorEnv   
	Local dDatRec
	Local cHorRec      
	Local cUsuario := UsrRetName(RetCodUsr())
	For nX := 1 to Len(aClassif)
		
		If AGRIFDbSeek("DXJ",aClassif[nX][1]+cTipo,1,.F.)
		
			While !Eof()                          .And. ; 
				DXJ->DXJ_CODIGO = aClassif[nX][1] .And.;
				DXJ->DXJ_TIPO   = cTipo
		
				If DXJ->DXJ_SAFRA = cSafra
						
					nDXK := 0
					nDX7 := 0
				
					if DXK->(ColumnPos('DXK_TIPO'))
						If AGRIFDbSeek("DXK",aClassif[nX][1]+DXJ->DXJ_TIPO+DXJ->DXJ_SAFRA,1,.F.)
							While !Eof()                          .And. ;
								DXK->DXK_CODROM = DXJ->DXJ_CODIGO .And. ;
								DXK->DXK_TIPO   = DXJ->DXJ_TIPO   .And. ;
								DXK->DXK_SAFRA  = DXJ->DXJ_SAFRA
								
								nDXK++
								
								If AGRIFDbSeek("DX7",cSafra+DXK->DXK_ETIQ+"1",2,.F.)
									nDX7++
									
									dDatEnv := DX7->DX7_DATENV
									cHorEnv := DX7->DX7_HORENV + ":00"
									dDatRec := DX7->DX7_DATREC
									cHorRec := DX7->DX7_HORREC + ":00"
								Endif
									
								dbSelectArea("DXK")
								DXK->(dbSkip())
							EndDo
							
							dbSelectArea("DXJ")
						Endif
					else
						If AGRIFDbSeek("DXK",aClassif[nX][1]+DXJ->DXJ_SAFRA,1,.F.)
							While !Eof()                          .And. ;
								DXK->DXK_CODROM = DXJ->DXJ_CODIGO .And. ;
								DXK->DXK_SAFRA  = DXJ->DXJ_SAFRA
								
								nDXK++							
								
								If AGRIFDBSEEK("DX7",cSafra+DXK->DXK_ETIQ,2,.F.)
									nDX7++
								Endif
																
								dbSelectArea("DXK")
								DXK->(dbSkip())
							EndDo
							
							dbSelectArea("DXJ")
						Endif
					endIf
					
					If nDXK > 0 .And. nDX7 > 0
					
						If nDXK = nDX7
							If RecLock("DXJ",.F.)
								DXJ->DXJ_STATUS := "6" //Hvi Total
								
								If A680VisCla(DXJ->DXJ_CODIGO)
									A680ClaDXI(DXJ->DXJ_CODIGO)
								EndIf
								
								if DXJ->(ColumnPos('DXJ_DTCLAS'))
									DXJ->DXJ_DTCLAS := ddatabase								
									
									DXJ->DXJ_DATREC := dDatRec
									DXJ->DXJ_HORREC := cHorRec
									DXJ->DXJ_USRREC := cUsuario
									DXJ->DXJ_DATANA := dDatEnv
									DXJ->DXJ_HORANA := cHorEnv
									DXJ->DXJ_USRANA := cUsuario
								endIf
								
								// Informa a data e hora da ataulização para atualizar/excluir a mala
								// do aplicativo do Beneficiamento
								if DXJ->(ColumnPos('DXJ_DATENV')) > 0
									If !Empty(DXJ->DXJ_DATENV)
										DXJ->DXJ_DATATU := dDatabase
										DXJ->DXJ_HORATU := Time()
									EndIf
								endIf
								
								MsUnlock()
							Endif
							
							If TableInDic('N73')
								AtuStaRems(DXJ->DXJ_SAFRA, DXJ->DXJ_CODIGO, DXJ->DXJ_TIPO, dDatRec, cHorRec)
							endIf
						Else
							if DXJ->DXJ_STATUS <> "8"
								If RecLock("DXJ",.F.)
									DXJ->DXJ_STATUS := "5" //Hvi Parcial
									
									// Informa a data e hora da ataulização para atualizar/excluir a mala
									// do aplicativo do Beneficiamento
									if DXJ->(ColumnPos('DXJ_DATENV')) > 0 
										If !Empty(DXJ->DXJ_DATENV)
											DXJ->DXJ_DATATU := dDatabase
											DXJ->DXJ_HORATU := Time()
										EndIf
									endIf
									
									msUnlock()
								Endif
							endIf
						Endif
					
					Endif
				Endif
				dbSkip()
			EndDo		
		Endif
	Next nX
Return .T.

/*/{Protheus.doc} VerifImp
Verifica se há algum registro com data de classificação
@author silvana.torres
@since 12/12/2017
@version undefined
@param cMala, characters, descricao
@param cSafra, characters, descricao
@type function
/*/
Static Function VerifImp(cMala, cSafra)
	
	Local aArea 	:= getArea()
	Local nDXK  	:= 0
	Local nDX7  	:= 0
	Local lRet		:= .F.			
	
	If AGRIFDbSeek("DXJ",cMala+"2",1,.F.)
	
		if !Eof() .And. DXJ->DXJ_CODIGO = cMala .And. DXJ->DXJ_TIPO = "2" .And. DXJ->DXJ_SAFRA = cSafra
	
			nDXK := 0
			nDX7 := 0
		
			if DXK->(ColumnPos('DXK_TIPO'))
				If AGRIFDbSeek("DXK",cMala+DXJ->DXJ_TIPO+DXJ->DXJ_SAFRA,1,.F.)
					While !Eof()                          .And. ;
						DXK->DXK_CODROM = DXJ->DXJ_CODIGO .And. ;
						DXK->DXK_TIPO   = DXJ->DXJ_TIPO   .And. ;
						DXK->DXK_SAFRA  = DXJ->DXJ_SAFRA
						
						nDXK++
						
						If AGRIFDbSeek("DX7",cSafra+DXK->DXK_ETIQ+"1",2,.F.)
							nDX7++							
						Endif
							
						dbSelectArea("DXK")
						DXK->(dbSkip())
					EndDo
					
					dbSelectArea("DXJ")
				Endif
			endIf
			
			If nDXK > 0 .And. nDX7 > 0
			
				nDX7 := nDX7 -1
				
				If nDX7 = 0
					lRet := .T. // pendente
				Else 
					lRet := .F. // parcial
				Endif
			Else
				lRet := .T. // pendente
			Endif		
		Endif
	EndIf
	
	dbCloseArea()
	
	RestArea(aArea)
	
Return lRet

/*/{Protheus.doc} A680ImpHvi
//TODO Descrição auto-gerada.
@author silvana.torres
@since 14/09/2017
@version undefined

@type function
/*/
Static Function A680ImpHvi(oModel, aErro)
	Local lSci 			:= .T.
	Local lRet			:= .T.
	Local aLinha		:= {}
	Local aParam		:= {}
	Local cEtiqueta		:= ""
	Local cConteudo		:= ""	
	Local nX			:= 0
	Local lLimite		:= .T.
	
	Private _lCnv		:= .T.

	//Ulitiliza separador para dividir as colunas do Layout
	If !Empty(_cSeparador)
		aLinha := StrTokArr(_cLinha,_cSeparador)
		If Empty(aLinha)
			//FT_FSkip()
			_lNext := .F.
		EndIf
		
		if Len(aLinha) <> (Len(_aStruLay) + 1) 
			aAdd(aErro, { ''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0018, STR0056 }) //"ATENÇÃO!"###"A estrutura do arquivo está diferente da estrutura do layout selecionado."
			//FT_FSkip()
			_lNext := .F.
			lRet := .F.
		endIf
		
		if _lNext
			If Len(aLinha) >= _aCpoKey[4]
				cEtiqueta := aLinha[_aCpoKey[4]] // _aCpoKey[4] - Coluna do Layout dividida pelo separador
				cEtiqueta := Padr(cEtiqueta,TamSX3("DX7_ETIQ")[1],'')
				
				
				If !DXI->(MsSeek(fwxFilial("DXI")+_cGetSafra+cEtiqueta))
					aadd(_aNimp,cEtiqueta)
					//FT_FSkip()
					_lNext := .F.
				EndIf
			Else
				//FT_FSkip()
				_lNext := .F.
			EndIf
		endIf
	Else
		cEtiqueta := SubStr(_cLinha,_aCpoKey[2],_aCpoKey[3])
		If !DXI->(MsSeek(fwxFilial("DXI")+_cGetSafra+cEtiqueta))
			aadd(_aNimp,cEtiqueta)
			//FT_FSkip()
			_lNext := .F.
		else
			_lNext := .T.
		EndIf
	EndIf
	
	if _lNext == .T.
		// posiciona e troca cEtiqueta para corte com 19 posições
		DXI->(MsSeek(fwxFilial("DXI")+_cGetSafra+cEtiqueta))
		cEtiqueta := DXI->DXI_ETIQ
		
		//Ponto de Entrada - criado em DAGROOGP-1716
		If ExistBlock('AGR680IMP1')
			aParam 	:= { FWxFilial("DXI"), _cGetSafra, cEtiqueta }
			lRet  	:= ExecBlock('AGR680IMP1',.F.,.F.,{aParam})
		EndIf
		/*
		USER FUNCTION AGR680IMP1()
			LOCAL cFilEmp 	:= PARAMIXB[1][1]
			LOCAL cSafra	:= PARAMIXB[1][2]
			LOCAL cEtiqueta	:= PARAMIXB[1][3]
			LOCAL lRetorno	:= .T.
			
			MSGINFO("Chave: "+ cFilEmp + cSafra + cEtiqueta)
		RETURN lRetorno
		*/
		If lRet
		
			//Inativa importações anteriores
			DX7->(dbSelectArea("DX7"))
			DX7->(dbSetOrder(2))
			DX7->(DbGotop())
			If DX7->(MsSeek(fwxFilial("DX7")+_cGetSafra+cEtiqueta+"1")) //Importacao de HVI Ativa
				While( !DX7->(Eof()) .and. DX7->DX7_FILIAL = FWxFilial("DX7") .and. DX7->DX7_SAFRA = _cGetSafra .and. DX7->DX7_ETIQ = cEtiqueta .and. DX7->DX7_ATIVO = "1")
					RecLock( "DX7", .F. )
					DX7->DX7_ATIVO := "2"
					DX7->(MsUnLock())
					DX7->(DbSkip())
				EndDo
			EndIf
			
			//Restaura Indice e continua importação
			DX7->(dbSetOrder(1)) // DX7_FILIAL+DX7_SAFRA+DX7_ETIQ+DX7_LAB+DX7_UNI
			DX7->(DbGotop())
			If !DX7->(MsSeek(fwxFilial("DX7")+_cGetSafra+cEtiqueta+DX1->DX1_LAB+DX1->DX1_UNI)) //Filial+cSafra+etiqueta+laboratorio+Unidade
				oModel:SetOperation( 3 )
			Else
				oModel:SetOperation( 4 )
			EndIf
			
			If lRet := oModel:Activate()
			
				If AGRIFDbSeek("DXK",_cGetSafra+cEtiqueta,2,.F.)
							
					While !Eof()                   .And. ;
						DXK->DXK_SAFRA = _cGetSafra .And. ;
						DXK->DXK_ETIQ  = cEtiqueta
						
						If AGRIFDbSeek("DXJ",DXK->DXK_CODROM,1,.F.)
							While !Eof()                    .And. ; 
								DXJ->DXJ_CODIGO = DXK->DXK_CODROM 
																	
								If DXJ->DXJ_TIPO = '2' .And. DXJ->DXJ_SAFRA  = DXK->DXK_SAFRA	
									If Len(_aClassif) > 0
										
										If Ascan(_aClassif,{|x| x[1] = DXJ->DXJ_CODIGO}) <= 0
											Aadd(_aClassif,{DXJ->DXJ_CODIGO})
										Endif
									Else
										Aadd(_aClassif,{DXJ->DXJ_CODIGO})
									Endif	
								Endif
								dbSkip()
							EndDo
						Endif
						dbSelectArea("DXK")
						dbSkip()
					EndDo
				Endif
			
				oModel:SetValue( 'DX7MASTER', 'DX7_FILIAL'	, FWxFilial("DX7")	)
				oModel:SetValue( 'DX7MASTER', 'DX7_SAFRA'	, _cGetSafra		 	)
				oModel:SetValue( 'DX7MASTER', 'DX7_ETIQ'	, cEtiqueta		 	)
				oModel:SetValue( 'DX7MASTER', 'DX7_FARDO'	, substr( cEtiqueta , 14 , 6 ) 		 	)
				oModel:SetValue( 'DX7MASTER', 'DX7_PRENSA'	, substr( cEtiqueta , 13 , 1 ) 		 	)
				oModel:SetValue( 'DX7MASTER', 'DX7_LAB'		, DX1->DX1_LAB 	 	)
				oModel:SetValue( 'DX7MASTER', 'DX7_UNI'		, DX1->DX1_UNI 	 	)
				oModel:SetValue( 'DX7MASTER', 'DX7_NMLAB'	, Posicione("SA2", 1, DX1->(DX1_LAB+DX1_UNI), "A2_NREDUZ"))
				oModel:SetValue( 'DX7MASTER', 'DX7_ATIVO' 	, "1"              )
				oModel:SetValue( 'DX7MASTER', 'DX7_DATU' 	, dDataBase)
				oModel:SetValue( 'DX7MASTER', 'DX7_HORA' 	, Substr( Time(), 1, 5 ))
				oModel:SetValue( 'DX7MASTER', 'DX7_USUATU'	, cUserName)
										
				//nHvi
				For nx := 1 To Len(_aStruLay)
			
					If !Empty(_cSeparador)
						
						If _aStruLay[nX,4] <= 0
							lRet := .F.
							Loop
						EndIf
						
						cConteudo := aLinha[_aStruLay[nX,4]]
						
						If _aStruLay[nX,5] == "N"
							cAux := StrTran(cConteudo,',','.')
							cConteudo := cAux
						Endif
		
						If !Empty(_aStruLay[nX,6]) .AND. !Empty(_aStruLay[nX,7])
							cAux1 := 0
		
							Do Case
								Case _aStruLay[nX,6] == "+"
								cAux1 := VAL(cConteudo) + VAL(alltrim(_aStruLay[nX,7]))
								Case _aStruLay[nX,6] == "-"
								cAux1 := VAL(cConteudo) - VAL(alltrim(_aStruLay[nX,7]))
								Case _aStruLay[nX,6] == "*"
								cAux1 := VAL(cConteudo) * VAL(alltrim(_aStruLay[nX,7]))
								Case _aStruLay[nX,6] == "/"
								cAux1 := VAL(cConteudo) / VAL(alltrim(_aStruLay[nX,7]))
							EndCase
							cConteudo := CVALTOCHAR(cAux1)
						EndIf
						
						_lCnv := .T.
		
						xConteudo := Converte(_aStruLay[nX,5], cConteudo, nX, aErro)
						
						if !_lCnv
							lRet := .F.
							Loop
						endIf
						
						oModel:SetValue('DX7MASTER',_aStruLay[nX,1],xConteudo)
					Else
						cConteudo := SubStr(_cLinha,_aStruLay[nX,2],_aStruLay[nX,3])
						//joga valor para variavel cConteudo
						If _aStruLay[nX,5] == "N"
							cAux := StrTran(cConteudo,',','.')
							cConteudo := cAux
						Endif
						If !Empty(_aStruLay[nX,6]) .AND. !Empty(_aStruLay[nX,7])
							cAux1 := 0
		
							Do Case
								Case _aStruLay[nX,6] == "+"
								cAux1 := VAL(cConteudo) + VAL(alltrim(_aStruLay[nX,7]))
								Case _aStruLay[nX,6] == "-"
								cAux1 := VAL(cConteudo) - VAL(alltrim(_aStruLay[nX,7]))
								Case _aStruLay[nX,6] == "*"
								cAux1 := VAL(cConteudo) * VAL(alltrim(_aStruLay[nX,7]))
								Case _aStruLay[nX,6] == "/"
								cAux1 := VAL(cConteudo) / VAL(alltrim(_aStruLay[nX,7]))
							EndCase
							cConteudo := CVALTOCHAR(cAux1)
						EndIf
						
						_lCnv := .T.
		
						xConteudo := Converte(_aStruLay[nX,5], cConteudo, nX, aErro)
						
						if !_lCnv
							lRet := .F.
							Loop
						endIf
						
						oModel:SetValue('DX7MASTER',_aStruLay[nX,1],xConteudo)
					EndIf
					//VALIDAR LIMITES DE VALORES
					If ((_aStruLay[nX,8] > 0 .and. xConteudo < _aStruLay[nX,8]) .or. (_aStruLay[nX,9] > 0 .and. xConteudo > _aStruLay[nX,9]))
						lLimite := .F.
						aadd(_aLimite,{cEtiqueta,_aStruLay[nX,1],xConteudo})
					Endif
					IF alltrim(_aStruLay[nX,1]) == "DX7_SCI"
						lSci := .F.
					EndIf
				Next
		
				if lRet 
					If (( lRet := oModel:VldData() ) .and. lLimite) 
						//Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
						oModel:CommitData()
						
						// Formula de SCI Fixa
						If lSci
							DX7->(dbSetOrder(1)) // DX7_FILIAL+DX7_SAFRA+DX7_ETIQ+DX7_LAB+DX7_UNI
							If DX7->(MsSeek(fwxFilial("DX7")+_cGetSafra+cEtiqueta+DX1->DX1_LAB+DX1->DX1_UNI)) //Filial+cSafra+etiqueta+laboratorio+Unidade
								If ((((2.9*DX7->(DX7_RES))-(9.32*DX7->(DX7_MIC))+(1.94*DX7->(DX7_FIBRA))+(4.8*DX7->(DX7_UI))+(0.65*DX7->(DX7_RD)))-412.7) > 0)
									RecLock( "DX7", .F. )
									DX7->(DX7_SCI) := (((2.9*DX7->(DX7_RES))-(9.32*DX7->(DX7_MIC))+(1.94*DX7->(DX7_FIBRA))+(4.8*DX7->(DX7_UI))+(0.65*DX7->(DX7_RD)))-412.7)
									DX7->(MsUnLock())
								Endif
							EndIf
						EndIF
			
					EndIf
				endIf
				lLimite := .T. // retorna valor padrao de validação de limites
			EndIf
			oModel:DeActivate()
		endIf
	EndIf
	
Return lRet


/*/{Protheus.doc} A680ImpCnt
//Função responsável pela importação de resultados de análise de contaminantes
@author silvana.torres
@since 14/09/2017
@version undefined
@param oModel, object, objeto do modelo do AGRA680
@param aErro, array, objeto que contém as mensagens de erro de forma generalizada
@type function
/*/
Static Function A680ImpCnt(oModel, aErro)
	Local cCodUnico	:= ""
	Local cEntidade := ""
	Local aBCode    := Array(4)
	Local cFilBkp   	
	Local aLinha	:= {}	
	
	//Ulitiliza separador para dividir as colunas do Layout
	If !Empty(_cSeparador)
		
		aLinha := StrTokArr(_cLinha,_cSeparador)
		
		If Empty(aLinha)
			//Validar linha vazia - @BRUNA
			aAdd(aErro, { ''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0045, STR0046 }) //"Erro"##"Linha do arquivo vazia, por gentileza verifique o arquivo de resultados."
			_lNext := .F.
		EndIf
		
		If Len(aLinha) >= _aCpoKey[4]
			_lNext := .T.	
			cCodUnico := aLinha[_aCpoKey[4]] // _aCpoKey[4] - Coluna do Layout dividida pelo separador
									
			if substr(alltrim(cCodUnico),len(alltrim(cCodUnico))-1,2) = "ML"
				cEntidade := "Mala"
			elseIf substr(alltrim(cCodUnico),len(alltrim(cCodUnico))-1,2) = "BL"
			 	cEntidade := "Bloco"
			else 
				aAdd(aErro, {''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0045, STR0047 + cCodUnico + STR0049 }) //'Erro'##'Código Único ' + cCodUnico + ' possui estrutura inválida, por gentileza, verifique.'
				aadd(_aNimp,cCodUnico)
				_lNext := .F.
			endIf
					
			If _lNext		
				//Quebra o código único para facilitar validações
				aBCode := STRTOKARR(cCodUnico,'-')
				
				//Recebe todos os campos do código quebrados para validação
				If Len(aBCode) > 0
					
					If aBCode[1] <> cFilAnt
						cFilBkp := cFilAnt
						cFilAnt := aBCode[1] 
					Endif
					
					If  PADR(aBCode[2],TamSX3('NJU_CODSAF')[1],'') /*Safra*/ <> _cGetSafra /*Safra da tela*/
						aAdd(aErro, {''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/,'' /*cCampo*/,;
							STR0045, STR0047 + cCodUnico + STR0048 }) //"Erro"##"Código Único " + cCodUnico + " tem safra diferente da informada em tela."
						aadd(_aNimp,cCodUnico)	 
						_lNext := .F.	
			 		Endif	
				Else
					aAdd(aErro, {''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0045, STR0047 + cCodUnico + STR0049 }) //'Erro'##'Código Único ' + cCodUnico + ' possui estrutura inválida, por gentileza, verifique.'
			 			aadd(_aNimp,cCodUnico)
			 			_lNext := .F.
				Endif	
			Endif
			
			If _lNext 
				if cEntidade == "Mala"
				 	cCodUnico := Padr(cCodUnico,TamSX3("DXJ_CODBAR")[1],'')
					dbSelectArea("DXJ")
					dbSetOrder(2) //Filial+codbar
					If !DXJ->(MsSeek(fwxFilial("DXJ")+PADR(cCodUnico,TamSX3('DXJ_CODBAR')[1],' ')))
						aadd(_aNimp,cCodUnico)
						_lNext := .F.
					EndIf
				elseIf cEntidade == "Bloco"
					cCodUnico := Padr(cCodUnico,TamSX3("DXD_CODUNI")[1],'')
					dbSelectArea("DXD")
					dbSetOrder(2) //Filial+codbar
					If !DXD->(MsSeek(fwxFilial("DXD")+cCodUnico))
						aadd(_aNimp,cCodUnico)
						_lNext := .F.
					EndIf				
				endIf
			Endif
		Else
			aAdd(aErro, {''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0045, STR0047 + _aCpoKey[4] + STR0049 }) //'Erro'##'Código Único ' + cCodUnico + ' possui estrutura inválida, por gentileza, verifique.'
			aadd(_aNimp,_aCpoKey[4]) 			
			//FT_FSkip()
			_lNext := .F.
		EndIf
	Else
		_lNext := .T.	
		cCodUnico := SubStr(_cLinha,_aCpoKey[2],_aCpoKey[3])
		
		if substr(alltrim(cCodUnico),len(alltrim(cCodUnico))-1,2) = "ML"
			cEntidade := "Mala"
		elseIf substr(alltrim(cCodUnico),len(alltrim(cCodUnico))-1,2) = "BL"
		 	cEntidade := "Bloco"
		else 
			aAdd(aErro, {''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 			STR0045, STR0047 + cCodUnico + STR0049 }) //'Erro'##'Código Único ' + cCodUnico + ' possui estrutura inválida, por gentileza, verifique.'
			aadd(_aNimp,cCodUnico)
			_lNext := .F.
		endIf
			
		If _lNext 	
			//Quebra o código único para facilitar validações
			aBCode := STRTOKARR(cCodUnico,'-')
			
			//Recebe todos os campos do código quebrados para validação
			If Len(aBCode) > 0
				If aBCode[1] <> cFilAnt
					cFilBkp := cFilAnt
					cFilAnt := aBCode[1] 
				Endif
				
				If PADR(aBCode[2],TamSX3('NJU_CODSAF')[1],'') /*Safra*/ <> _cGetSafra /*Safra da tela*/
					aAdd(aErro, {''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/,'' /*cCampo*/,;
						STR0045, STR0047 + cCodUnico + STR0048 }) //"Erro"##"Código Único " + cCodUnico + " tem safra diferente da informada em tela."
					aadd(_aNimp,cCodUnico) 
					_lNext := .F.	
		 		Endif	
			Else
				aAdd(aErro, {''/*cSubModel*/ , ''/*cCampo*/ , ''/*cSubModel*/, ''/*cCampo*/,;
			 		 STR0045, STR0047 + cCodUnico + STR0049 }) //'Erro'##'Código Único ' + cCodUnico + ' possui estrutura inválida, por gentileza, verifique.'
			 		 aadd(_aNimp,cCodUnico)
		 			_lNext := .F.
			Endif	
		Endif
		
		If _lNext	
			If cEntidade == "Mala"
				cCodUnico := Padr(cCodUnico,TamSX3("DXJ_CODBAR")[1],'')		
				dbSelectArea("DXJ")
				dbSetOrder(2) //Filial+codbar
				If !DXJ->(MsSeek(fwxFilial("DXJ")+cCodUnico))
					aAdd(_aNimp,cCodUnico)
					_lNext := .F.
				EndIf
			elseIf cEntidade == "Bloco"
				cCodUnico := Padr(cCodUnico,TamSX3("DXD_CODUNI")[1],'')
				dbSelectArea("DXD")
				dbSetOrder(2) //Filial+codbar
				If !DXD->(MsSeek(fwxFilial("DXD")+cCodUnico))
					aadd(_aNimp,cCodUnico)
					_lNext := .F.
				EndIf
			EndIf
		Endif
	EndIf
	
	If _lNext 
		If cEntidade == "Mala" 
			_lNext := MalaImport(cCodUnico, aLinha, @aErro)
		ElseIf cEntidade == "Bloco"
			_lNext := BlocoImport(cCodUnico, aLinha, @aErro)
		EndIf
		//Se a gravação dos resultados não aconteceu, põe o código na lista de não importados
		If .Not. _lNext
			aadd(_aNimp,cCodUnico)
		Endif		
	endIf
	
	dbCloseArea()
	cFilAnt := cFilBkp
Return _lNext


/*/{Protheus.doc} MalaImport
//Função responsável pela preparação dos dados para gravação dos resultados de análise da mala
@author bruna.rocio
@since 18/09/2017
@version undefined
@param cCodUnico, characters, descricao
@type function
/*/
Static Function MalaImport(cCodUnico, aLinha, aErro)
	Local lRet := .T.
	Local nX
	Local xConteudo
	Local cConteudo
		
	DXJ->(MsSeek(fwxFilial('DXJ')+cCodUnico)) //Localiza o registro de romaneio de classificação/mala
			
	For nX := 1 To Len(_aStruLay)
		If _aStruLay[nX,P_COLUNA] <= 0
			aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
			 			STR0045, STR0050 + cValToChar(nX) + STR0051  }) //'Erro'##'Número de coluna do ' + cValToChar(nX) + 'º campo do layout inválido, por gentileza, verifique.' 
			lRet := .F.
			Loop
		ElseIf Len(_aStruLay) > Len(aLinha)
		 	If !Empty(_cSeparador)
				lRet := .F.
				Loop
			EndIf
		EndIf

		If !Empty(_cSeparador)
			cConteudo := aLinha[_aStruLay[nX,P_COLUNA]]
			If _aStruLay[nX,P_TIPO] == "3" //Data
				If AT("/" ,cConteudo ) > 0
					If Len(cConteudo) = 10
						xConteudo := CTOD(cConteudo) //conv caracter no formato "DD/MM/AAAA"" para uma var do tipo data
					Else
						_lCnv := .F.
						aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
						 			STR0045, STR0057 + cConteudo + STR0058 }) //'Erro'##"O conteúdo " está fora dos padrões de data permitidos: AAAAMMDD ou DD/MM/AAAA."   
					EndIf
				Else
					xConteudo := STOD(cConteudo)
					
					if xConteudo = STOD("  /  /    ")
						aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
						 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique." 
						lRet := .F.
						Loop
			 		endIf
			 	EndIf
			ElseIf _aStruLay[nX,P_TIPO] == "2"//Numérico
				cAux := StrTran(cConteudo,',','.')
				
				if !Type(StrTran(cAux,'.','')) == "N"
					aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
					 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique."
					lRet := .F.
					Loop
				else				
					cConteudo := cAux
					xConteudo := Val(cConteudo)
					
					if alltrim(cAux) != "0" .And. xConteudo = 0
						aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
						 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique." 
						lRet := .F.
						Loop
					endIf
				endIf
			else 
				xConteudo := cConteudo	
			Endif
					
			Begin Transaction								
				lRet := CommitResult(DXJ->DXJ_SAFRA, DXJ->DXJ_CODBAR, __cContam,  _aStruLay[nX,P_CAMPO],  _aStruLay[nX,P_TITULO], _aStruLay[nX,P_TIPO], xConteudo,; 
						        	Recno(), DXJ->DXJ_CODIGO, DXJ->DXJ_PRDTOR, DXJ->DXJ_LJPRO, DXJ->DXJ_FAZ, DXJ->DXJ_CODPRO, "DXJ", @aErro )	
						        	
				If lRet
					
					lRet := FardinhoImport(DXJ->DXJ_SAFRA, DXJ->DXJ_CODIGO, __cContam, _aStruLay[nX,P_CAMPO],  _aStruLay[nX,P_TITULO], _aStruLay[nX,P_TIPO], xConteudo, @aErro )
				Endif
				
				If !lRet
					DisarmTransaction()
				Endif	
			End Transaction	        			
		Else
			cConteudo := SubStr(_cLinha,_aStruLay[nX, P_INICIO],_aStruLay[nX, P_TAM])
			//joga valor para variavel cConteudo
			If _aStruLay[nX,P_TIPO] == "3" //Data
				If AT("/" ,cConteudo ) > 0
					If Len(cConteudo) = 10
						xConteudo := CTOD(cConteudo) //conv caracter no formato "DD/MM/AAAA"" para uma var do tipo data
					Else
						_lCnv := .F.
						aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
						 			STR0045, STR0057 + cConteudo + STR0058 }) //'Erro'##"O conteúdo " está fora dos padrões de data permitidos: AAAAMMDD ou DD/MM/AAAA."   
					EndIf
				Else
					xConteudo := STOD(cConteudo)
					
					if xConteudo = STOD("  /  /    ")
						aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
						 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique." 
						lRet := .F.
						Loop
			 		endIf
		 		EndIf
			ElseIf _aStruLay[nX,P_TIPO] == "2"//Numérico
				cAux      := StrTran(cConteudo,',','.')
				
				if !Type(StrTran(cAux,'.','')) == "N"
					aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
					 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique."
					lRet := .F.
					Loop
				else				
					cConteudo := cAux
					xConteudo := Val(cConteudo)
					
					if alltrim(cAux) != "0" .And. xConteudo = 0
						aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
						 			STR0045, STR0054 + cValToChar(nX+1) + STR0055 }) //'Erro'##'O ' + cValToChar(nX+1) + "º campo do arquivo está com formato diferente do layout, por gentileza, verifique." 
						lRet := .F.
						Loop
					endIf
				endIf
			else 
				xConteudo := cConteudo	
			Endif
			
			Begin Transaction
				lRet := CommitResult(DXJ->DXJ_SAFRA, DXJ->DXJ_CODBAR, __cContam,  _aStruLay[nX,P_CAMPO],  _aStruLay[nX,P_TITULO], _aStruLay[nX,P_TIPO], xConteudo,; 
						        	Recno(), DXJ->DXJ_CODIGO, DXJ->DXJ_PRDTOR, DXJ->DXJ_LJPRO, DXJ->DXJ_FAZ, DXJ->DXJ_CODPRO, "DXJ", @aErro )
						        	
				If lRet
					lRet := FardinhoImport(DXJ->DXJ_SAFRA, DXJ->DXJ_CODIGO, __cContam, _aStruLay[nX,P_CAMPO],  _aStruLay[nX,P_TITULO], _aStruLay[nX,P_TIPO], xConteudo, @aErro )
				Endif			
				
				If !lRet
					DisarmTransction()
				Endif	
			End Transaction	        	
		EndIf			
	Next nX 
	
	dbCloseArea()
Return lRet


/*/{Protheus.doc} BlocoImport
//Função responsável pela preparação da gravação dos resultados de analise para o bloco
@author bruna.rocio
@since 18/09/2017
@version undefined
@param cCodUnico, characters, código único identificador do bloco
@type function
/*/
Static Function BlocoImport(cCodUnico, aLinha, aErro)
	Local lRet := .T.
	Local nX
	Local xConteudo
	Local cConteudo
	
	DXD->(MsSeek(fwxFilial('DXD')+cCodUnico)) //Localiza o registro de romaneio de classificação/mala
						
	For nX := 1 To Len(_aStruLay)
		If _aStruLay[nX,P_COLUNA] <= 0
			aAdd(aErro, {/*cSubModel*/ , /*cCampo*/ , /*cSubModel*/, /*cCampo*/,;
			 			STR0045, STR0050 + cValToChar(nX) + STR0051  }) //'Erro'##'Número de coluna do ' + cValToChar(nX) + 'º campo do layout inválido, por gentileza, verifique.' 
			lRet := .F.
			Loop
		ElseIf Len(_aStruLay) > Len(aLinha) 
		 	If !Empty(_cSeparador)
				lRet := .F.
				Loop
			EndIf
		EndIf

		If !Empty(_cSeparador)
			cConteudo := aLinha[_aStruLay[nX, P_COLUNA]]
			If _aStruLay[nX,P_TIPO] == "3" //Data
				If AT("/" ,cConteudo ) > 0
					If Len(cConteudo) = 10
						xConteudo := CTOD(cConteudo) //conv caracter no formato "DD/MM/AAAA"" para uma var do tipo data
					EndIf
				Else
					xConteudo := STOD(cConteudo)
				EndIf
			ElseIf _aStruLay[nX,P_TIPO] == "2"//Numérico
				cPicture := FormatDecPic(_aStruLay[nX,P_TAM],_aStruLay[nX,P_DECIMAL])
				
				cAux := StrTran(cConteudo,',','.')
				xConteudo := Val(cAux)
				xConteudo := TRANSFORM(xConteudo,cPicture)	
				xConteudo := StrTran(xConteudo,',','.')
				xConteudo := Val(xConteudo)
			else 
				xConteudo := cConteudo
			Endif
			
			lRet := CommitResult(DXD->DXD_SAFRA, DXD->DXD_CODUNI, __cContam, _aStruLay[nX,P_CAMPO], _aStruLay[nX,P_TITULO], _aStruLay[nX,P_TIPO], xConteudo,; 
								Recno(), DXD->DXD_CODIGO, DXD->DXD_PRDTOR, DXD->DXD_LJPRO, DXD->DXD_FAZ, DXD->DXD_CODPRO, "DXD", @aErro )
			
		Else
			cConteudo := SubStr(_cLinha,_aStruLay[nX,P_INICIO],_aStruLay[nX,P_TAM])
			//joga valor para variavel cConteudo
			If _aStruLay[nX,P_TIPO] == "3" //Data
				If AT("/" ,cConteudo ) > 0
					If Len(cConteudo) = 10
						xConteudo := CTOD(cConteudo) //conv caracter no formato "DD/MM/AAAA"" para uma var do tipo data
					EndIf
				Else
					xConteudo := STOD(cConteudo)
				EndIf
			ElseIf _aStruLay[nX,P_TIPO] == "2"//Numérico
				cPicture := FormatDecPic(_aStruLay[nX,P_TAM],_aStruLay[nX,P_DECIMAL])
				
				cAux := StrTran(cConteudo,',','.')
				xConteudo := Val(cAux)
				xConteudo := TRANSFORM(xConteudo,cPicture)	
				xConteudo := StrTran(xConteudo,',','.')
				xConteudo := Val(xConteudo)
			else 
				xConteudo := cConteudo	
			Endif

			lRet := CommitResult(DXD->DXD_SAFRA, DXD->DXD_CODUNI, __cContam, _aStruLay[nX,P_CAMPO], _aStruLay[nX,P_TITULO], _aStruLay[nX,P_TIPO], xConteudo,; 
								Recno(), DXD->DXD_CODIGO, DXD->DXD_PRDTOR, DXD->DXD_LJPRO, DXD->DXD_FAZ, DXD->DXD_CODPRO, "DXD", @aErro )
		EndIf			
	Next		
Return lRet

/*/{Protheus.doc} CommitResult
//Função responsável pela gravação dos dados de resultados de análise
@author bruna.rocio
@since 15/09/2017
@version undefined
@param cFilEnt, characters, filial da entidade do resultado de análise
@param cSafra, characters, safra da entidade do resultado de análise
@param cUniqueCode, characters, código único da entidade do resultado de análise
@param cContam, characters, contaminante analisado
@param cExame, characters, exame do contaminante
@param cExame, characters, descrição do exame
@param cTpResult, characters, tipo do resultado de análise
@param xResult, , resultado de análise
@param nRecno, numeric, recno do registro da entidade
@param cCodigo, characters, código da entidade (Mala ou Bloco)
@param cProdutor, characters, produtor da entidade do resultado de análise
@param cLoja, characters, loja do produtor da entidade do resultado de análise
@param cFaz, characters, fazenda do produtor da entidade do resultado de análise
@param cProduto, characters, produto da entidade analisada
@type function
/*/
Static Function CommitResult(cSafra, cUniqueCode, cContam, cExame, cTitulo, cTpResult, xResult, nRecno, cCodigo, cProdutor, cLoja, cFaz, cProduto, cEntidade, aErro )
	Local aArea  := GetArea()
	Local lRet   := .T.
	Local nSeq   := 1
	Local cRecno := cEntidade + cValtoChar(nRecno)
	
	cProduto := PADR(cProduto,TamSX3('NPX_CODPRO')[1], ' ')
	
	//Inativa os registros anteriores
	NPX->(DbSelectArea("NPX"))
	NPX->(dbGoTop())
	NPX->(dbSetOrder(1))
	NPX->(MsSeek(FWxFilial('NPX')+cSafra+PADR(cProduto,TamSX3('NPX_CODPRO')[1],'')+PADR(cRecno,TamSX3('NPX_LOTE')[1],'')+;
		   PADR(cContam,TamSX3('NPX_CODTA')[1],'')+PADR(cExame,TamSX3('NPX_CODVA')[1],'')))
		   
	While NPX->(!Eof())                      .And. ;
		  NPX->NPX_FILIAL = FWxFilial('NPX')   .And. ;
		  NPX->NPX_CODSAF = cSafra             .And. ;
		  NPX->NPX_CODPRO = PADR(cProduto,TamSX3('NPX_CODPRO')[1],'')   .And. ;
		  NPX->NPX_LOTE   = PADR(cRecno,TamSX3('NPX_LOTE')[1],' ')   	.And. ;
		  NPX->NPX_CODTA  = PADR(cContam,TamSX3('NPX_CODTA')[1],' ') 	.And. ;
		  NPX->NPX_CODVA  = PADR(cExame,TamSX3('NPX_CODVA')[1],' ') 	.AND. ;
		  NPX->NPX_ATIVO  = "1"       
						
		Reclock('NPX',.F.)
		NPX->NPX_ATIVO  := "2" //Não Ativo
		NPX->NPX_USUATU := SubStr(cusuario,7,15)
		NPX->(MsUnlock())	

		nSeq++
		NPX->(dbSkip())
	EndDo

	NXP->(dbCloseArea())

	/*----------------------------------------------------------------*/
	/* Trocado o uso de modelo por reclock em virtude da velocidade   */
	/* dispenda para instanciar e desativar o modelo a cada registro  */
	/* gravado, em testes básicos, a velocidade aumentou cerca de 10x */
	/*----------------------------------------------------------------*/

	NPX->(dbSelectArea('NPX'))
	If Reclock('NPX',.T.)
		
		NPX->NPX_FILIAL := fwxFilial('NPX')
		NPX->NPX_CODSAF := cSafra
		NPX->NPX_CODPRO := cProduto
		NPX->NPX_LOTE   := PADR(cRecno,TamSX3('NPX_LOTE')[1],' ')
		NPX->NPX_CODTA  := PADR(cContam,TamSX3('NPX_CODTA')[1],' ') 
		NPX->NPX_SEQ    := cValToChar(nSeq)
		NPX->NPX_CODVA  := PADR(cExame,TamSX3('NPX_CODVA')[1],' ')  
		NPX->NPX_DESVA  := PADR(cTitulo,TamSX3('NPX_DESVA')[1],' ') 
		NPX->NPX_TIPOVA := cTpResult	
		
		If cEntidade = "DXJ"
			NPX->NPX_CDUMAL := cUniqueCode 
			NPX->NPX_ROMCLA := cCodigo 
			NPX->NPX_PRDTOR := cProdutor 
			NPX->NPX_LJPRO  := cLoja 
			NPX->NPX_FAZ    := cFaz 	
		ElseIf cEntidade = "DXD"
			NPX->NPX_CDUBLC := cUniqueCode 
			NPX->NPX_BLOCO  := cCodigo 
			NPX->NPX_PRDTOR := cProdutor 
			NPX->NPX_LJPRO  := cLoja 
			NPX->NPX_FAZ    := cFaz 
		ElseIf cEntidade = "DXI"
			NPX->NPX_ETIQ   := cUniqueCode 
			NPX->NPX_FARDO  := cCodigo 
			NPX->NPX_PRDTOR := cProdutor 
			NPX->NPX_LJPRO  := cLoja 
			NPX->NPX_FAZ    := cFaz 
		Endif
		
		Do Case
			case cTpResult = '1' //Texto
				NPX->NPX_RESTXT := PADR(xResult,TamSX3('NPX_RESTXT')[1],' ')
			Case cTpResult = '2' //Numérico
				NPX->NPX_RESNUM := xResult
			Case cTpResult = '3' //Data
				NPX->NPX_RESDTA := xResult
		EndCase
		
		NPX->NPX_ATIVO  := '1' 
		NPX->NPX_DTATU  := dDatabase
		NPX->NPX_USUATU := cUserName
		
		MsUnlock()		
	Endif
	
	dbCloseArea()
	
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} FormatDecPic
//Função para formação de picture para resultados decimais
@author bruna.rocio
@since 18/09/2017
@version undefined
@param nTam, numeric, descricao
@param nDec, numeric, descricao
@type function
/*/
Static Function FormatDecPic(nTam, nDec)
	Local cPic := ""
	
	cPic := "@E " + Replicate("9",nTam-(nDec+1)) + "." + Replicate("9",nDec)
Return cPic


/*/{Protheus.doc} FardinhoImport
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 18/09/2017
@version undefined
@param cSafra, characters, descricao
@param cMala, characters, descricao
@param cContam, characters, descricao
@param cExame, characters, descricao
@param cTitulo, characters, descricao
@param cTpResult, characters, descricao
@param xConteudo, , descricao
@param aErro, array, descricao
@type function
/*/
Static Function FardinhoImport(cSafra, cMala, cContam, cExame, cTitulo, cTpResult, xConteudo, aErro )
	Local aArea := GetArea()
	Local lRet  := .T.
	Local cProdutor := ""
	Local cLoja := ""
	Local cFazenda := ""
		
	dbSelectArea('DXK')
	dbSetOrder(1)
	If MsSeek(fwxFilial('DXK')+cMala+"1"+cSafra)
		While DXK->(!Eof()) .And. ;
			DXK->DXK_FILIAL = fwxFilial('DXK') .And. ;
			DXK->DXK_CODROM = cMala            .And. ;
			DXK->DXK_SAFRA  = cSafra           .And.;
			DXK->DXK_TIPO   = "1"
		
			if DXK->(ColumnPos('DXK_TIPO')) 
			 	if DXK->DXK_TIPO   = "1"
			
					cProdutor := Posicione('DXI',1,fwxFilial('DXI')+DXK->DXK_SAFRA+DXK->DXK_ETIQ,'DXI_PRDTOR')
					cLoja     := Posicione('DXI',1,fwxFilial('DXI')+DXK->DXK_SAFRA+DXK->DXK_ETIQ,'DXI_LJPRO')
					cFazenda  := Posicione('DXI',1,fwxFilial('DXI')+DXK->DXK_SAFRA+DXK->DXK_ETIQ,'DXI_FAZ')
				
					lRet := CommitResult(DXK->DXK_SAFRA, DXK->DXK_ETIQ, cContam, cExame, cTitulo, cTpResult, xConteudo,; 
							        	Recno(), DXK->DXK_FARDO, cProdutor, cLoja, cFazenda, DXK->DXK_CODPRO, "DXI", @aErro )	
					
					
					DXK->(dbSkip())
				endIf
			else
				cProdutor := Posicione('DXI',1,fwxFilial('DXI')+DXK->DXK_SAFRA+DXK->DXK_ETIQ,'DXI_PRDTOR')
				cLoja     := Posicione('DXI',1,fwxFilial('DXI')+DXK->DXK_SAFRA+DXK->DXK_ETIQ,'DXI_LJPRO')
				cFazenda  := Posicione('DXI',1,fwxFilial('DXI')+DXK->DXK_SAFRA+DXK->DXK_ETIQ,'DXI_FAZ')
			
				lRet := CommitResult(DXK->DXK_SAFRA, DXK->DXK_ETIQ, cContam, cExame, cTitulo, cTpResult, xConteudo,; 
						        	Recno(), DXK->DXK_FARDO, cProdutor, cLoja, cFazenda, DXK->DXK_CODPRO, "DXI", @aErro )	
				
				
				DXK->(dbSkip())
			endIf
		EndDo
	Endif

	dbCloseArea()

	RestArea(aArea)
Return lRet 

/*/{Protheus.doc} AtuStaRems
//Função para atualizar o status da remessa se todas as malas tiverem sido recebidas
@author silvana.torres
@since 25/09/2017
@version undefined
@param cCodSaf, character
@param cCodMal, character
@param cTipo, character
@param dDatRec, date 
@param cHorRec, character
@type function
/*/
Static Function AtuStaRems(cCodSaf, cCodMal, cTipo, dDatRec, cHorRec)
	
	Local aArea 	:= GetArea()
	Local lRet 		:= .T.
	Local cAliasRem := GetNextAlias()
	Local cCodRem 	:= ''
	Local oMdlRemes := FwLoadModel('UBAA030')
	Local oFormN72  := oMdlRemes:GetModel('N72UBAA030')
	Local oGridN73  := oMdlRemes:GetModel('N73UBAA030')
	Local nX
	Local cUsuario := UsrRetName(RetCodUsr())		
	
	dbSelectArea("N73")
	N73->(dbSetOrder(2)) //Filial+Safra+Mala+Tipo
	
	if N73->(MsSeek(FWxFilial("N73")+cCodSaf+cCodMal+cTipo))
			
		cCodRem := N73->N73_CODREM
		
		dbSelectArea("N72")
		N72->(dbSetOrder(1)) //Filial+Safra+Remessa
		
		if N72->(MsSeek(FWxFilial("N72")+N73->N73_CODSAF+N73->N73_CODREM))
		
			if N72->N72_STATUS == '2' .Or. N72->N72_STATUS == '4' 
				oMdlRemes:SetOperation(4)
		
				If oMdlRemes:Activate()
				
					For nX:=1 To oGridN73:Length()
						
						oGridN73:goline(nX)
						
						if oGridN73:GetValue("N73_CODMAL") == cCodMal
							oGridN73:SetValue('N73_DATREC', dDatRec)
							oGridN73:SetValue('N73_HORREC', cHorRec)	
							oGridN73:SetValue('N73_USRREC',cUsuario)
											
						endIf
					next nX 
	
					BeginSql Alias cAliasRem
					  Select * 
					    From %table:N73% N73,
					         %table:DXJ% DXJ
					   where N73.%notDel%
					     and DXJ.%notDel%
					      and N73.N73_CODREM = %exp:cCodRem%
					      and N73.N73_FILIAL = DXJ.DXJ_FILIAL
			              and N73.N73_CODSAF = DXJ.DXJ_SAFRA
			              and N73.N73_CODMAL = DXJ.DXJ_CODIGO
			          	  and N73.N73_TIPO   = DXJ.DXJ_TIPO
			          	  and DXJ.DXJ_DATREC = %exp:CTOD('')%
					EndSql		  
					
					IF (cAliasRem)->(!Eof())
						oFormN72:SetValue('N72_STATUS', '4') /*Entregue parcial*/									
					else
						oFormN72:SetValue('N72_STATUS', '3') /*Entregue */
					Endif					
					
					oGridN73:addLine()		
												
				EndIf
				
				If oMdlRemes:VldData()
					lRet := FWFormCommit(oMdlRemes)
				EndIf	
				
				oMdlRemes:DeActivate()	
			endIf
		endIf
	endIf				
	
	dbCloseArea()						

	RestArea(aArea)	
Return lRet


/*/{Protheus.doc} A680VisCla
Verifica se a mala visual está classificada
@author silvana.torres
@since 23/05/2018
@version undefined
@param cCodMala, characters, descricao
@type function
/*/
Static Function A680VisCla(cCodMala)

	Local lRet 		:= .F.
	Local aSaveArea := GetArea()
	Local cAliasDXJ := GetNextAlias()	

	BeginSql Alias cAliasDXJ
	  SELECT 1
	    FROM %Table:DXJ% DXJ
	   WHERE DXJ.%NotDel%
	     AND DXJ_FILIAL 	= %xFilial:DXJ% 
	     AND DXJ.DXJ_TIPO 	= '1' //Visual
	     AND DXJ.DXJ_STATUS = '3' //Visual classificado
	     AND DXJ.DXJ_CODIGO	=  %exp:cCodMala%
	EndSQL
    
    (cAliasDXJ)->(dbGoTop())
    
    If (cAliasDXJ)->(!Eof())
    	lRet := .T.
	EndIf

    (cAliasDXJ)->(dbCloseArea())
    RestArea( aSaveArea )
    
Return lRet
    
/*/{Protheus.doc} A680ClaDXI
Altera o status dos fardinhos para classificado
@author silvana.torres
@since 24/05/2018
@version undefined
@param cCodMala, characters, descricao
@type function
/*/
Static Function A680ClaDXI(cCodMala)

	Local aSaveArea := GetArea()
	Local lRet 		:= .T.
	
	dbSelectArea('DXK')
	dbSetOrder(1)
	
	If MsSeek(FwXFilial('DXK')+cCodMala+"1")
		While DXK->(!Eof())           .And. ;
			DXK->DXK_CODROM = cCodMala .And. ;
			DXK->DXK_TIPO   = "1"
			
			dbSelectArea("DXI")
			DXI->(dbSetOrder(1)) // DXI_FILIAL+DXI_SAFRA+DXI_ETIQ
			
			If DXI->(MsSeek(FWxFilial("DXI")+DXK->DXK_SAFRA+DXK->DXK_ETIQ))
				RecLock("DXI",.F.)
				DXI->DXI_STATUS := '20 ' // Classificado
				DXI->(MsUnlock())
			EndIf
			
			DXI->(dbCloseArea())
			
			DXK->(dbSkip())
		EndDo
	EndIf
	
	DXK->(dbCloseArea())
	
	RestArea(aSaveArea)
		
Return lRet
