#INCLUDE "AGRA930.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "Fileio.CH"
#DEFINE DIRANA  "ANA\"
#DEFINE DIRPEND "PENDENTE\"
#DEFINE DIRLIDO "LIDO\"
#DEFINE DIRERRO "ERRO\"

//-----------------------------------------------------------
/*/{Protheus.doc} AGRA930
IMPORTACAO ANÁLISE LOTE DE SEMENTES

@param: Nil
@author: Fabiane Schulze
@since: 12/12/2013
@Uso: UBS
/*/

//-----------------------------------------------------------
Function AGRA930()
	Local aCoors 	:= FWGetDialogSize( oMainWnd )
	Local oSize	:= FWDefSize():New(.T.)
	Local oFWL		:= FwLayer():New()
	Local oWnd1	:= Nil
	Local oWnd2	:= Nil

	Private cGetSafra	 := Space(TAMSX3("NJU_CODSAF")[1])
	Private cGetLayout	 := Space(TAMSX3("NPV_CODIGO")[1])
	Private cGetPath	 := ""
	Private aStruLay 	 := {} // Armazena estrutura do Layout
	Private aCpoKey 	 := {} // Armazena o campo chave do Layout
	Private nProc 		 := 0
	Private nImp		 := 0
	Private oSay		 := Nil
	Private oBrowse		 := Nil
		

//³Caso não exista, os diretorios padroes serao criados³
	If !ExistDir(DIRANA)
		MakeDir(DIRANA)
		MakeDir(DIRANA+DIRPEND)
		MakeDir(DIRANA+DIRLIDO)
		MakeDir(DIRANA+DIRERRO)
	EndIf

//Dimensiona a area do container principal
	oSize:AddObject("OLBX",100,100,.T.,.T.)
	oSize:SetWindowSize({aCoors[1],aCoors[2],aCoors[3],aCoors[4]})
	oSize:lProp 	:= .T.
	oSize:Process()

//Cria a Dialog
	DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0001) FROM oSize:aWindSize[1], oSize:aWindSize[2];  //"Resultado Análise"
	TO oSize:aWindSize[3], oSize:aWindSize[4] PIXEL
	oDlg:lEscClose := .F.

	oFWL:init( oDlg, .T. )

//Divide a area da Dialog em colunas
	oFWL:addCollumn( "ESQ", 65, .F.)
	oFWL:addCollumn( "DIR", 35, .F.)

//Recupera o Panel das colunas
	oPnl1 := oFWL:getColPanel("ESQ")
	oPnl3 := oFWL:getColPanel("DIR")

//Acidiona janelas a direita
	oFWL:addWindow( "DIR" , "Wnd1", STR0002, 40, .F., .T.)  //"Pesquisa arquivos"
	oFWL:addWindow( "DIR" , "Wnd2", STR0003, 60, .F., .T.)  //"Importação de arquivos"

//Monta o Browse onde serao visualizados os registros importados
	oBrowse := FWMBrowse():New()
	oBrowse:SetOwner( oPnl1 )
	oBrowse:SetAlias('NPX')
	oBrowse:SetDescription( STR0001 )  //"Resultado Análise"
	oBrowse:DisableDetails()
	oBrowse:SetWalkThru(.F.)
	oBrowse:SetSeek(.F.)
	oBrowse:SetAmbiente(.F.)
	oBrowse:SetOnlyFields( { 'NPX_CODSAF', 'NPX_CODPRO', 'NPX_LOTE','NPX_CODTA','NPX_DESVA','NPX_RESNUM','NPX_RESTXT','NPX_RESDTA' } )
	oBrowse:SetFilterDefault("NPX_ATIVO=='1' .and. NPX_OFI=='2'")
	oBrowse:Activate()

//Recupera o Panel das janelas
	oWnd1 := oFWL:getWinPanel( "DIR", "Wnd1")
	oWnd2 := oFWL:getWinPanel( "DIR", "Wnd2")

//Adciona os componentes na janela da parte superior da coluna a direita
	A930PATH(@oWnd1,@oWnd2)

//Adciona os componentes na janela da parte inferior da coluna a direita
	A930LISTBX(@oWnd2)

	ACTIVATE MSDIALOG oDlg CENTERED

Return NIL

//-----------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Padrao da Rotina

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

//ADD OPTION aRotina Title 'Visualizar'		Action 'VIEWDEF.AGRA930' 	OPERATION 2 ACCESS 0
//ADD OPTION aRotina Title 'Excluir'			Action 'VIEWDEF.AGRA930' 	OPERATION 5 ACCESS 0

Return aRotina

//-----------------------------------------------------------
/*/{Protheus.doc} ModelDef
Retorna o modelo de Dados da rotina

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStruNPX 	:= FwFormStruct( 1, "NPX" ) // Resultado Laboratorial ANA
	oModel := MpFormModel():New( 'AGRA930',/*bPre*/,,, /*bCancel*/ )
	oModel:SetDescription( STR0004 ) //'Modelo de dados do Resultado Laboratorial ANA' //"Modelo de dados da Análise"

	oModel:AddFields( 'NPXMASTER', /*cOwner*/, oStruNPX )
	oModel:GetModel( 'NPXMASTER' ):SetDescription( STR0005 ) //'Dados do Resultado Laboratorial de ANA' //"Dados do Resultado Análise"
	oModel:SetPrimaryKey({"NPX_FILIAL","NPX_CODSAF","NPX_CODPRO","NPX_LOTE","NPX_CODTA","NPX_CODVA","NPX_SEQ"})
Return oModel

//-----------------------------------------------------------
/*/{Protheus.doc} ViewDef
Retorna a View (tela) da rotina

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FwLoadModel( "AGRA930" )
	Local oStruNPX 	:= FwFormStruct( 2, "NPX" ) // Resultado Laboratorial ANA
	Local nX		:= 0

	oView := FwFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_NPX', oStruNPX, 'NPXMASTER' )
	oView:CreateHorizontalBox( 'TOTAL', 100 )
	oView:SetOwnerView( 'VIEW_NPX', 'TOTAL' )

//Agrupamento de campos
	oStruNPX:AddGroup( 'GRUPO1', 'Dados do Lote', '', 1 )
	For nX:=1 To Len(oStruNPX:AFIELDS)
		oStruNPX:SetProperty( oStruNPX:AFIELDS[nX,1] , MVC_VIEW_GROUP_NUMBER, 'GRUPO1' )
	Next
Return oView

//-----------------------------------------------------------
/*/{Protheus.doc} A930PATH
Monta tela para permitir pesquisar os arquivos para importação

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function A930PATH(oWnd1,oWnd2)
	Local bSel		  := {|| }
	Local cRootPath := GetSrvProfString("RootPath","")
	Local oSize	  := FWDefSize():New(.T.)

	oSize:AddObject("PANEL",100,100,.T.,.T.)
	oSize:SetWindowSize({0,0,oWnd1:NHEIGHT,oWnd1:NWIDTH})
	oSize:lProp 	 := .T.
	oSize:aMargins := {3,3,3,3}
	oSize:Process()

	bSel := {|| cGetPath := cGetFile( "" , OemToAnsi(STR0006) , 1 ,; //"Selecione o caminho onde estão localizados os arquivos" //"Selecione o caminho onde estão localizados os arquivos"
	cRootPath +"\" +DIRANA , .F. ,  nOR( GETF_LOCALHARD, GETF_RETDIRECTORY ))}
	@ oSize:AposObj[1,1]+4, oSize:AposObj[1,2] SAY oLayout PROMPT OemToAnsi(STR0007) SIZE 040, 07 OF oWnd1 PIXEL //"Safra"
	@ oSize:AposObj[1,1]+2, oSize:AposObj[1,2]+030 MSGET oGetSafra VAR cGetSafra 	SIZE TamSX3("NJU_CODSAF")[1]*4+5, 10  F3 "NJU";
		VALID A930VldSF() OF oWnd1 PIXEL

	@ oSize:AposObj[1,1]+19, oSize:AposObj[1,2] SAY oLayout PROMPT OemToAnsi("Layout") SIZE 040, 07 OF oWnd1 PIXEL
	@ oSize:AposObj[1,1]+17, oSize:AposObj[1,2]+030 MSGET oGetLayout VAR cGetLayout 	SIZE TamSX3("NPV_CODIGO")[1]*4+5, 10  F3 "NPV";
		VALID ((nProc:=0,nImp:=0),A930LAYOUT(cGetLayout)) OF oWnd1 PIXEL

	@ oSize:AposObj[1,1]+34, oSize:AposObj[1,2] SAY oPath PROMPT OemToAnsi("Path:") 	SIZE 040, 07 OF oWnd1 PIXEL
	@ oSize:AposObj[1,1]+32, oSize:AposObj[1,2]+30 MSGET oGetPath VAR cGetPath 	SIZE oSize:AposObj[1,4]-40, 07 OF oWnd1 PIXEL WHEN .F.
	@ oSize:AposObj[1,1]+32, oSize:AposObj[1,4]-17 BUTTON oBtnSel PROMPT OemToAnsi("Path") Action((nProc:=0,nImp:=0),Eval(bSel)) 	SIZE 017, 010 OF oWnd1 PIXEL

// Cria barra de botoes 
	DEFINE BUTTONBAR oBar SIZE 25,25  3D BOTTOM OF oWnd1
	TButton():New ( 35, oSize:AposObj[1,2], STR0008, oBar, {|| A930GETARQ(@oWnd2),(nProc:=0,nImp:=0)}, 35, 10,,,, .T.,, STR0009) //"Buscar"###"Buscar arquivos" //"Buscar"###"Buscar Arquivos"

	nProc:=0
	nImp:=0
Return

//-----------------------------------------------------------
/*/{Protheus.doc} A930VldSF
Validação da Safra

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function A930VldSF()
	Local lRet := .T.

	NJU->(dbSetOrder(1))
	If !NJU->(DbSeek(xFilial("NJU")+cGetSafra))
		lRet := .F.
		Help("",1,"REGNOIS",,,1)
	EndIf

Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} A930LAYOUT
Validação do Layout

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function A930LAYOUT()
	Local aArea := NPW->(GetArea())
	Local lRet	:= .T.

	dbSelectArea("NPW")
	dbSetOrder(1) //Filial+Layout+campo
	If dbSeek(xFilial("NPW")+cGetLayout)
		While !Eof()  .And. Alltrim(NPW_LAYOUT) == Alltrim(cGetLayout)
			dbSkip()
		End
	Else
		aStruLay := {}
		lRet := .F.
		Help(,,"REGNOIS",,"",1,0)
	EndIf

	RestArea(aArea)
Return(lRet)

//-----------------------------------------------------------
/*/{Protheus.doc} A930LISTBX
Monta list Box para apresentar os arquivos encontrados

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function A930LISTBX(oWnd2)
	Local aVetor	:= {}

	Static oOk    	:= LoadBitmap( GetResources(), "LBOK" )
	Static oNo    	:= LoadBitmap( GetResources(), "LBNO" )
	Static oBar		:= Nil
	Static oLbx		:= Nil

//Coordenadas da area total da Dialog
	oSize:= FWDefSize():New(.T.)
	oSize:AddObject("OLBX",100,100,.T.,.T.)
	oSize:SetWindowSize({0,0,oWnd2:NHEIGHT,oWnd2:NWIDTH})
	oSize:lProp 	:= .T.
	oSize:aMargins := {0,0,0,0}
	oSize:Process()

	aVetor := {{.F.,"","",""}}

	@ oSize:aPosObj[1,1],oSize:aPosObj[1,2] LISTBOX oLbx FIELDS HEADER " ", STR0010,STR0011,STR0012; //"Arquivo"###"Tamanho"###"Ultima Alteração"
	SIZE oSize:aPosObj[1,4]-1,oSize:aPosObj[1,3]-40 OF oWnd2 PIXEL

	oLbx:SetArray(aVetor)
	oLbx:bLine := {|| {IIF(aVetor[oLbx:nAt,1],oOk,oNo),;
		aVetor[oLbx:nAt,2],;
		aVetor[oLbx:nAt,3],;
		aVetor[oLbx:nAt,4]}}

//Apresenta na tela arquivos e lotes processados 
	oSay:= TSay():New(oSize:aPosObj[1,3]-18,oSize:AposObj[1,2],{|| Transform( STR0013, "@!" )},oWnd2,,,,,,.T.,,,84,25) //"Arquivos Processados:" //"Arquivos Processados:"
	oSay:= TSay():New(oSize:aPosObj[1,3]-18,oSize:AposObj[1,2]+84,{||  Alltrim(Transform( nProc, '@E 999') )},oWnd2,,,,,,.T.,,,12,25)
	oSay:= TSay():New(oSize:aPosObj[1,3]-10,oSize:AposObj[1,2],{|| Transform( STR0014, "@!" )},oWnd2,,,,,,.T.,,,84,25) //"Registros Importados:" //"Registros Importados:"
	oSay:= TSay():New(oSize:aPosObj[1,3]-10,oSize:AposObj[1,2]+84,{|| Alltrim(Transform( nImp, '@E 99999') )},oWnd2,,,,,,.T.,,,20,25)

//Cria barra de botoes 
	DEFINE BUTTONBAR oBar SIZE 25,25  3D BOTTOM OF oWnd2
	TButton():New ( 35, oSize:AposObj[1,2], STR0015, oBar, {|| Processa({||A930IMPORT(oWnd2)})}, 35, 10,,,, .T.,, STR0016) //"Importar"###"Importar Arquivos" //"Importar"###"Importar Arquivos"

	oLbx:AARRAY:={}
Return

//-----------------------------------------------------------
/*/{Protheus.doc} A930GETARQ
Retorna os arquivos encontrados no Diretorio      

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function A930GETARQ(oWnd2)
	Local aVetor	:= {}
	Local nX 		:= 0
	Local lRet  	:= .T.
	Local lMark		:= .T.

	lRet := !Empty(cGetPath)

	If lRet
		aFiles := Directory(cGetPath+"*.*")

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
	oLbx:BHEADERCLICK	:= {|| A930MarkTd(@lMark) }
	oLbx:Refresh()
Return

//-----------------------------------------------------------
/*/{Protheus.doc} A930IMPORT
Faz a importação dos resultados das análises

@param: Nil
@author: Fabiane Schulze
@since:10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function A930IMPORT(oWnd2)
	Local aAreaNPX   := NPX->(GetArea())
	Local aLinha	   := {}
	Local oModel	   := FwLoadModel( "AGRA930" )
	Local cLinha	   := ""
	Local nX		   := 0
	Local nY		   := 0
	Local cFile	   := ""
	Local lRet		   := .T.
	Local lErro      := .F.
	Local cSeparador := ""
	Local cResult    := ''
	Local nResult    := 0
	local cProduto   := Space(TAMSX3("NP9_PROD")[1])
	Local cLote       := Space(TAMSX3("NP9_LOTE")[1])
	local cTipoAn		:=	Space(TAMSX3("NPW_CODTA")[1])
	local cCampo		:=	Space(TAMSX3("NPW_CAMPO")[1])
	Local nl		  := 0
	Local nSeq       	:= 1
	Local lAprova	 	:= .T.
	Local cCond			:= ''
	Local cPadrao		:= 0
	Local cTipoVA		:=''
	Local cIr			:=''
	Local vLog			:={}
	Local nAprova		:= 0
	Local nReprova	:= 0
	Local nLinha		:= 0
	Local nTotLote	:= 0
	nImp  := 0
	nProc := 0
							cFiltro := oBrowse:GetFilterDefault()
							oBrowse:SetFilterDefault("")
							oBrowse:Refresh()
	DbselectArea('NPV')
	NPV->(dbSetOrder(1))
	If !NPV->(DBSeek(xFilial("NPV")+cGetLayOut))
		lRet := .F.
		Help(,,STR0017,,STR0018,1,0) //"ATENÇÃO!"###"Código de Layout invalido" //"ATENÇÃO!"###"Código de Layout inválido"
	else
		if !empty(NPV->NPV_SPRDOR)
			cSeparador := IIf ( NPV->NPV_SPRDOR = '1',',',';')
		else
			lRet := .F.
			Help(,,STR0017,,STR0019,1,0) //"ATENÇÃO!"###"Código de Layout invalido"	 //"ATENÇÃO!"###"Layout não possui separador cadastrado"
		endif
	EndIf

	DbselectArea('NPW')
	NPW->(dbSetOrder(1)) // NPW_FILIAL+NPW_LAYOUT+NPW_COL
	NPW->(dbseek(xFilial('NPW') + cGetLayout))
	While !EOF() .and. NPW->NPW_FILIAL == xFilial('NPW') .AND. NPW->NPW_LAYOUT == cGetLayout

		if alltrim(NPW->NPW_CAMPO) == 'NP9_LOTE'
			iLote := NPW->NPW_COL
		Endif
		
		NPW->(DBSKIP())
	EndDo


	If lRet
		For nX := 1 To Len(oLbx:AARRAY)
			If !oLbx:AARRAY[nX,1]
				Loop
			EndIf
			nProc++
			cFile		:= oLbx:AARRAY[nX,2]
			/*
			cConteudo 	:= MemoRead(cGetPath +cFile,.F.)
			If Empty(cConteudo)
				cConteudo 	:= MemoRead(cGetPath +cFile,.T.)
			EndIF
			cArqTXT 	:= CriaTrab(,.F.)
		
			MemoWrit(cArqTXT+".TXT",cConteudo)
		*/
			If (File(cGetPath +cFile))
				FT_FUse(cGetPath +cFile)
				nTotLote := FT_FLASTREC()
				ProcRegua(FT_FLASTREC())
				FT_FGotop()
				While(!FT_FEof())
				
				IncProc(STR0020 + ": " + alltrim(STR(nlinha)) + "/" + alltrim(Str(nTotLote))) //"Lendo arquivo..."
				cLinha	:= AllTrim(FT_FReadLN())
				nLinha++
				If Empty(cLinha)
					FT_FSkip()
					Loop
				EndIf
				//Utiliza separador para dividir as colunas do Layout
				If !Empty(cSeparador)
					aLinha := Separa(cLinha,cSeparador,.t.)
					
					If Empty(aLinha)
						FT_FSkip()
						Loop
					EndIf
				Endif
				lRet := .F.
				DbselectArea('NP9')
				NP9->(dbSetOrder(3))
				//Busca somente lote que não é tratado caso lote for tratado não é importado analise
				While(dbseek(xFilial('NP9') + cGetSafra + padr(aLinha[iLote], tamSX3('NP9_LOTE')[1])) .and. !lRet)
				if (NP9->NP9_TRATO = '2' )
					cProduto := NP9->NP9_PROD
					cLote    := NP9->NP9_LOTE
					lRet := .T.
				Else
					lRet := .F.
				endif
				NP9->(DBSKIP())
			EndDo
				
			If lRet
				
				for nY := 1 to len(aLinha)

					nSeq := 1
					
					if nY <> iLote
						lfound = .F.
						DbselectArea('NPW')
						NPW->(dbSetOrder(1))
						NPW->(dbseek(xFilial('NPW') + cGetLayout))
						While !EOF() .and. NPW->NPW_FILIAL == xFilial('NPW') .AND. NPW->NPW_LAYOUT == cGetLayout .and. !lfound
							if NPW->NPW_COL == nY
								lfound = .T.
								cCampo := NPW->NPW_CAMPO
								cDesc  := Posicione("NPU",1,xFilial("NPU")+NPW->NPW_CODTA+NPW->NPW_CAMPO,"NPU_DESVA")
								cTipoAn := NPW->NPW_CODTA
								
								DbselectArea('NPU')
								NPU->(dbSetOrder(1))
								if dbseek(xFilial('NPU') + NPW->NPW_CODTA + NPW->NPW_CAMPO	 )
									cTipoVa := NPU->NPU_TIPOVA
									cIr     := NPU->NPU_IR // participa da aprovação(1=Não;2=Sim)
									 // condição matematica
									If	 NPU->NPU_COND = '1' //1=Igual a;
											cCOnd	:= '=='
									ElseIf	 NPU->NPU_COND = '2' //2=Diferente de;
											cCOnd	:= '<>'
									ElseIf	 NPU->NPU_COND = '3' //3=Menor que;
											cCOnd	:= '<'
									ElseIf	 NPU->NPU_COND = '4' //4=Menor ou igual que;
											cCOnd	:= '<='
									ElseIf	 NPU->NPU_COND = '5' //5=Maior que;
											cCOnd	:= '>'
									Elseif	 NPU->NPU_COND = '6' //6=Maior ou igual que
										cCOnd	:= '>='
									EndIf
									cPadrao := NPU->NPU_EXPR
								ENDIF
								
								//zera variaves	
								nResult := 0
								cResult:= ""
								dtResult := nil
								
								IF cTipoVa = '1'
									nResult := VAL(aLinha[nY])
								ELSEIF cTipoVa = '2'
									cResult := aLinha[nY]
								else
									dtResult := CTOD(aLinha[nY])
								endif
							
							endif
							NPW->(DBSKIP())
						EndDo
						
						if lfound .and. !Empty(cTipoAn)
							// Verifica se a análise já foi importada
							// Caso exista ela será alterada para "inativa"
							DbSelectArea("NPX")
							dbSetOrder(1)
							while (NPX->( dbSeek( xFilial( "NPX" )+cGetSafra+cProduto+cLote+cTipoAn+cCampo+ CVALTOCHAR(nSeq))))
								if (NPX->NPX_ATIVO  = "1")
									AGRTRAVAREG("NPX",.f.)
									NPX->NPX_ATIVO  := "2"
									NPX->NPX_USUATU := SubStr(cusuario,7,15)
									AGRDESTRAREG("NPX")
								endif
								nSeq++
								NPX->(DBSKIP())
							ENDDO
														
//							IncProc(STR0021) //"Importando Analises..."
							
							oModel:SetOperation( 3 )
							If lRet := oModel:Activate()
								oModel:SetValue( 'NPXMASTER', 'NPX_FILIAL'	, xFilial("NPX"))
								oModel:SetValue( 'NPXMASTER', 'NPX_CODSAF'	, cGetSafra)
								oModel:SetValue( 'NPXMASTER', 'NPX_CODPRO'	, cProduto	)
								oModel:SetValue( 'NPXMASTER', 'NPX_LOTE'	, cLote)
								oModel:SetValue( 'NPXMASTER', 'NPX_CODTA'	, cTipoAn  )
								oModel:SetValue( 'NPXMASTER', 'NPX_SEQ'	, CVALTOCHAR(nSeq) )
								oModel:SetValue( 'NPXMASTER', 'NPX_CODVA'	, cCampo	)
								oModel:SetValue( 'NPXMASTER', 'NPX_DESVA'	, cDesc		)
								oModel:SetValue( 'NPXMASTER', 'NPX_TIPOVA'	, cTipoVa	)
								Do	case
							case cTipoVa = '1'
								oModel:SetValue( 'NPXMASTER', 'NPX_RESNUM'	, nResult)
							case cTipoVa = '2'
								oModel:SetValue( 'NPXMASTER', 'NPX_RESTXT'	, cResult)
							case cTipoVa = '3'
								oModel:SetValue( 'NPXMASTER', 'NPX_RESDTA'	, dtResult)
							EndCase
							oModel:SetValue( 'NPXMASTER', 'NPX_IR'		, cIr 	 	)
							oModel:SetValue( 'NPXMASTER', 'NPX_ATIVO'	, '1'	 	)
							oModel:SetValue( 'NPXMASTER', 'NPX_OFI'	, '2'	 	)
							oModel:SetValue( 'NPXMASTER', 'NPX_DTATU'	, dDatabase)
							oModel:SetValue( 'NPXMASTER', 'NPX_USUATU'	, cUserName)
						endif
									
						If ( lRet := oModel:VldData() )
								//Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
							oModel:CommitData()
							oModel:DeActivate()
													// Matriz armazena aprovação
							if (cTipoVA = '1' .and. cIr = '2')
								if !&(alltrim(str(nresult)) +@cCond+alltrim(str(cPadrao)))
									lAprova := .F.
								Else
									lAprova := .T.
								Endif
							endif
						EndIf
					endif
				endif
						//atualiza data de validade caso exista no layout
				if (cTipoVA = '3' .and. cIr = '2')
					DbselectArea("NP9")
					NP9->(dbSetOrder(1))
					if DbSeek(xFilial("NP9") + cGetSafra + cProduto + cLote)
						RecLock("NP9",.F.)
						NP9->NP9_DTVAL := dtResult + cPadrao// Data de Validade do Beneficiamento
						NP9->(MsUnlock())
					endif
					DbselectArea("SB8")
					SB8->(dbSetOrder(5))
					if DbSeek(xFilial("SB8") + cProduto + cLote)
						RecLock("SB8",.F.)
						SB8->B8_DTVALID := dtResult+ cPadrao// Data de Validade do saldo de Lote
						SB8->(MsUnlock())
					endif
				endif
				
			Next nY

			If !lRet
					//³Se os dados não foram validados obtemos a descrição do erro para gerar LOG ou mensagem de aviso³
				aErro := oModel:GetErrorMessage()
				AutoGrLog( "Layout:"	+ ' [' + AllToChar( cGetLayout ) 	+ ']' ) //"Layout:"
				AutoGrLog( STR0010	+ ' [' + AllToChar( cFile	) 		+ ']' ) //"Arquivo" //"Arquivo"
				AutoGrLog( STR0022	+ ' [' + Alltrim(AllToChar( FT_FRecno ( ) ))	+ ']' ) //"Linha:" //"Linha:"
				AutoGrLog( STR0023	+ ' [' + AllToChar( 'AGRA930' ) 	+ ']' ) //"Programa:" //"Programa:"
				AutoGrLog( STR0024	+ ' [' + AllToChar( aErro[2] ) 		+ ']' ) //"Id do campo de origem: " //"Id do campo de origem: "
				AutoGrLog( STR0025 	+ ' [' + AllToChar( aErro[3] ) 		+ ']' ) //"Id do formulário de erro: " //"Id do formulário de erro: "
				AutoGrLog( STR0026	+ ' [' + AllToChar( aErro[4] ) 		+ ']' ) //"Id do campo de erro: " //"Id do campo de erro: "
				AutoGrLog( STR0027	+ ' [' + AllToChar( aErro[5] ) 		+ ']' ) //"Id do erro: " //"Id do erro: "
				AutoGrLog( STR0028	+ ' [' + AllToChar( aErro[6] ) 		+ ']' ) //"Mensagem do erro: " //"Mensagem do erro: "
				AutoGrLog( CRLF	)
				lErro := .T.
			Else
										//Aprova ou Reprova o lote antes de ir ao proximo lote
				if !lAprova
					DbselectArea("NP9")
					NP9->(dbSetOrder(1))
					if DbSeek(xFilial("NP9") + cGetSafra + cProduto + cLote)
						RecLock("NP9",.F.)
						NP9->NP9_STATUS :='3'// Status 3 - Rejeitado CQ
						NP9->(MsUnlock())
						aadd(vLog,{cLote,'Rejeitado CQ'})
						nReprova += 1
						AGRGRAVAHIS(,,,,{"NP9",xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"C",'Reprovado via Boletim Oficial'})
					endif
				ELSE
					DbselectArea("NP9")
					NP9->(dbSetOrder(1))
					if DbSeek(xFilial("NP9") + cGetSafra + cProduto + cLote)
						RecLock("NP9",.F.)
						NP9->NP9_STATUS :='2'// Status 2 - Disponivel
						NP9->(MsUnlock())
						aadd(vLog,{cLote,'Aprovado CQ'})
						nAprova += 1
						AGRGRAVAHIS(,,,,{"NP9",xFilial("NP9")+NP9->NP9_CODSAF+NP9->NP9_PROD+NP9->NP9_LOTE,"A",'Aprovado via Boletim Oficial'})
					endif
				endif

						// Limpa variavel
				cTipoVA		:=''
				nImp++
			EndIf
		endif
		FT_FSkip()

	End
			
	If lErro
				//³Move arquivo para pasta de Erros³
		Copy File &(cGetPath+cFile) To &(DIRANA+DIRERRO)
		FErase(cGetPath+cFile)
	Else
				//³Move arquivo para pasta dos processados ³
		Copy File &(cGetPath+cFile) To &(DIRANA+DIRLIDO)
		FErase(cGetPath+cFile)
	EndIf
EndIf
	
Next nX
EndIf

If lErro
	MostraErro()
EndIf
	//Exibe resumo de lotes processados e importados
AutoGrLog(STR0029 + alltochar(nImp)) //"Lotes Processados: "
AutoGrLog(STR0030 + alltochar(nAprova)) //"Lotes Aprovados  : "
AutoGrLog(STR0031 + alltochar(nReprova)) //"Lotes Reprovados : "
for nl :=1  to len(vLog)
	AutoGrLog(alltochar(vlog[nl,1]) + '-->' + alltochar(vlog[nl,2]))
next nl
MostraErro()
A930GETARQ(@oWnd2)
//oBrowse:SetFilterDefault(cfiltro)
//oBrowse:ExecuteFilter()
oBrowse:Refresh(.T.)
RestArea(aAreaNPX)

Return

//-----------------------------------------------------------
/*/{Protheus.doc} A930IMPORT
Marca/Desmaca Todos

@param: Nil
@author: Fabiane Schulze
@since: 10/12/2013
@Uso: AGRA930
/*/
//-----------------------------------------------------------
Static Function A930MarkTd(lMark)
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
